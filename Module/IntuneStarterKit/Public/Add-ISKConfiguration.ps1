function Add-ISKConfiguration {
        <#
    .SYNOPSIS
        Connect to the MSGraph

    .DESCRIPTION
        Connect to the MSGraph
        
    .PARAMETER Path
        Path to the Repository or a local path

    .PARAMETER DestinationPath
        Path where online files will be stored


    #>
    Param (
        [parameter(Mandatory = $false, HelpMessage = "Path to the Repository or a local path")]
        [ValidateNotNullOrEmpty()]
        [string]$Path = "https://github.com/FlorianSLZ/IntuneStarterKit/tree/main/Samples/Configuration",
        
        [parameter(Mandatory = $false, HelpMessage = "Path where online files will be stored")]
        [ValidateNotNullOrEmpty()]
        [string]$DestinationPath = "$env:temp\IntuneStarterKit\Config\"
    )


    try{
        if($Path -like "https://github.com/*"){

            $Owner = $($Path.Replace("https://github.com/","")).Split("/")[0]
            $Repository = $($Path.Replace("https://github.com/$Owner/","")).Split("/")[0]
            $RepoPath = $($Path.Replace("https://github.com/$Owner/$Repository/tree/main/",""))

            Invoke-GitHubDownload -Owner $Owner -Repository $Repository -Path $RepoPath -DestinationPath $DestinationPath
            $PathLocal = $DestinationPath

        }else{
            if(Test-Path $Path){
                Write-Verbose "Found path: $Path"
                $PathLocal = $Path
            }else{
                Write-Error "Path not found: $Path"
                break
            }
        }

    
        
        # Configurations Restore
        Connect-MSGraph -Quiet
        Invoke-IntuneRestoreDeviceCompliancePolicy -Path $PathLocal # Basic Requirements
        Invoke-IntuneRestoreDeviceConfiguration -Path $PathLocal
        Invoke-IntuneRestoreDeviceManagementIntent -Path $PathLocal # Defender, Firewall und Bitloker
        Invoke-IntuneRestoreDeviceManagementScript -Path $PathLocal # PowerShell Scripte
        Invoke-IntuneRestoreGroupPolicyConfiguration -Path $PathLocal
        Invoke-IntuneRestoreConfigurationPolicy -Path $PathLocal # Settings Catalog

    }catch{
        Write-Error $_
    }
    
        
    
}