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

            Invoke-GitHubDownload -Owner $Owner -Repository $Repository -Path $RepoPath -DestinationPath $DestinationPath | Out-Null
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

    
        
        # Connect
        Connect-MSGraph -Quiet 

        # Configurations Restore
        $DeviceConfiguration = Invoke-IntuneRestoreDeviceConfiguration -Path $PathLocal
        $DeviceCompliancePolicy = Invoke-IntuneRestoreDeviceCompliancePolicy -Path $PathLocal 
        # $DeviceManagementIntent = Invoke-IntuneRestoreDeviceManagementIntent -Path $PathLocal 
        $DeviceManagementScript = Invoke-IntuneRestoreDeviceManagementScript -Path $PathLocal
        # $GroupPolicyConfiguration = Invoke-IntuneRestoreGroupPolicyConfiguration -Path $PathLocal
        $ConfigurationPolicy = Invoke-IntuneRestoreConfigurationPolicy -Path $PathLocal

        if($AssignTo){

            # Assign Device Configuration
            foreach($Configuration in $DeviceConfiguration){
                $uri = "https://graph.microsoft.com/beta/deviceManagement/deviceConfigurations?`$filter=displayName%20eq%20'$($Configuration.Name)'"
                $Method = "GET"     
                $ConfigId = (Invoke-PagingRequest -Method $Method -uri $uri).id

                if($ConfigId.count -eq 1){
                    Add-DeviceConfigurationPolicyAssignment -ConfigurationPolicyId $ConfigId -TargetGroupId $AssignTo -AssignmentType Included
                }else{
                    Write-Warning "There are multiple policies with the same name, please clean them up first: $($Configuration.Name)" 
                }
            }

            # Assign Device Compliance Policy
            foreach($Configuration in $DeviceCompliancePolicy){
                $uri = "https://graph.microsoft.com/beta/deviceManagement/deviceCompliancePolicies?`$filter=displayName%20eq%20'$($Configuration.Name)'"
                $Method = "GET"     
                $ConfigId = (Invoke-PagingRequest -Method $Method -uri $uri).id

                if($ConfigId.count -eq 1){
                    Add-DeviceCompliancePolicyAssignment -CompliancePolicyId $ConfigId -TargetGroupId $AssignTo
                }else{
                    Write-Warning "There are multiple compliance policies with the same name, please clean them up first: $($Configuration.Name)" 
                }

                
            }

            # Assign Device Device Management Script
            foreach($Script in $DeviceManagementScript){ 
                $uri = "https://graph.microsoft.com/beta/deviceManagement/deviceManagementScripts?`$filter=displayName%20eq%20'$($Script.Name)'"
                $Method = "GET"     
                $ScriptId = (Invoke-PagingRequest -Method $Method -uri $uri).id

                if($ScriptId.count -eq 1){
                    Add-DeviceManagementScriptAssignment -ScriptId $ScriptId -TargetGroupId $AssignTo
                }else{
                    Write-Warning "There are multiple scripts with the same name, please clean them up first: $($Script.Name)" 
                }

            }

            # Assign Configuration Policy (Settings catalog)
            foreach($Configuration in $ConfigurationPolicy){
                $SCName = $($Configuration.path.replace('Settings Catalog\','')).replace('.json','')
                $uri = "https://graph.microsoft.com/beta/deviceManagement/configurationPolicies?`$filter=name%20eq%20'$($SCName)'"
                $Method = "GET"     
                $ConfigId = (Invoke-PagingRequest -Method $Method -uri $uri).id

                if($ConfigId.count -eq 1){
                    Add-ConfigurationPolicyAssignment -ConfigurationPolicyId $ConfigId -TargetGroupId $AssignTo -AssignmentType Included
                }else{
                    Write-Warning "There are multiple policies with the same name, please clean them up first: $($SCName)" 
                }


            }

        }

        Write-Host "Configuration imported:" -ForegroundColor Green
        $DeviceConfiguration.Name
        $DeviceCompliancePolicy.Name
        $DeviceManagementScript.Name
        $($ConfigurationPolicy.path.replace('Settings Catalog\','')).replace('.json','')

    }catch{
        Write-Error $_
    }
    
        
    
}