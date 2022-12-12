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

        }else{
            # check path
        }

    
    
        # Configurations Restore
        Invoke-IntuneRestoreDeviceCompliancePolicy -Path $DestinationPath # Basic Requirements
        Invoke-IntuneRestoreDeviceConfiguration -Path $DestinationPath
        Invoke-IntuneRestoreDeviceManagementIntent -Path $DestinationPath # Defender, Firewall und Bitloker
        Invoke-IntuneRestoreDeviceManagementScript -Path $DestinationPath # PowerShell Scripte
        Invoke-IntuneRestoreGroupPolicyConfiguration -Path $DestinationPath
        Invoke-IntuneRestoreConfigurationPolicy -Path $DestinationPath # Settings Catalog

    }catch{
        Write-Error $_
    }
    
        
    
}