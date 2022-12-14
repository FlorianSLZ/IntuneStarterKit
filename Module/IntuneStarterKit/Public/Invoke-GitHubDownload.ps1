function Invoke-GitHubDownload {

    <#
    .SYNOPSIS
        Download files and folders inside a GitHub repository

    .DESCRIPTION
        Download files and folders inside a GitHub repository
        
    .PARAMETER Owner
        DestinationPath

    .PARAMETER Repository
        GitHub repository name

    .PARAMETER Path
        Path inside the Repository

    .PARAMETER DestinationPath
        Path where the files will be stored localy


    #>

    param (
        [parameter(Mandatory = $true, HelpMessage = "DestinationPath")]
        [ValidateNotNullOrEmpty()]
        [string]$Owner,

        [parameter(Mandatory = $true, HelpMessage = "GitHub repository name")]
        [ValidateNotNullOrEmpty()]
        [string]$Repository,

        [parameter(Mandatory = $true, HelpMessage = "Path inside the Repository")]
        [ValidateNotNullOrEmpty()]
        [string]$Path,

        [parameter(Mandatory = $true, HelpMessage = "Path where the files will be stored localy")]
        [ValidateNotNullOrEmpty()]
        [string]$DestinationPath

    )

    $baseUri = "https://api.github.com/"
    $args = "repos/$Owner/$Repository/contents/$Path"
    $wr = Invoke-WebRequest -Uri $($baseuri+$args)
    $objects = $wr.Content | ConvertFrom-Json
    $files = $objects | where {$_.type -eq "file"} | Select -exp download_url
    $directories = $objects | where {$_.type -eq "dir"}
    
    $directories | ForEach-Object { 
        Invoke-GitHubDownload -Owner $Owner -Repository $Repository -Path $_.path -DestinationPath $($DestinationPath+$_.name)
    }

    
    if (-not (Test-Path $DestinationPath)) {
        # Destination path does not exist, let's create it
        try {
            New-Item -Path $DestinationPath -ItemType Directory -ErrorAction Stop
        } catch {
            throw "Could not create path '$DestinationPath'!"
        }
    }

    foreach ($file in $files) {
        $fileDestination = Join-Path $DestinationPath (Split-Path $file -Leaf)
        try {
            Invoke-WebRequest -Uri $file -OutFile $fileDestination -ErrorAction Stop
        } catch {
            throw "Unable to download '$($file.path)'"
        }
    }

}