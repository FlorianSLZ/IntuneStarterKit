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
        [string]$DestinationPath = "$env:temp\IntuneStarterKit\Config\",

        [parameter(Mandatory = $false, HelpMessage = "Assign configuration to group with specified ID")]
        [ValidateNotNullOrEmpty()]
        [string]$AssignTo
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
        Invoke-IntuneRestoreDeviceCompliancePolicy -Path $PathLocal 
        Invoke-IntuneRestoreDeviceConfiguration -Path $PathLocal
        Invoke-IntuneRestoreDeviceManagementIntent -Path $PathLocal 
        Invoke-IntuneRestoreDeviceManagementScript -Path $PathLocal
        Invoke-IntuneRestoreGroupPolicyConfiguration -Path $PathLocal
        Invoke-IntuneRestoreConfigurationPolicy -Path $PathLocal

        if($AssignTo){
            foreach($Configuration in $AllConfigs){
            
                Write-Verbose "Assign configuration to:"
                Write-Verbose "Add Member to $GroupName, Member ID: $Member"
                $Method = "POST"
                $uri = "https://graph.microsoft.com/beta/deviceManagement/deviceConfigurations/$Configuration/assign"
                $ConfPolAssign = "$Configuration" + "_" + "$AssignTo"
                $JSON = @"
     
    {
        "deviceConfigurationGroupAssignments": [
            {
                "@odata.type": "#microsoft.graph.deviceConfigurationGroupAssignment",
                "id": "$ConfPolAssign",
                "targetGroupId": "$AssignTo"
            }
        ]
    }
"@


                $AssignConfigRespond = Invoke-MgGraphRequest -Method $Method -uri $uri -Body $JSON
                Write-Verbose $AssignConfigRespond
            }
        }

    }catch{
        Write-Error $_
    }
    
        
    
}