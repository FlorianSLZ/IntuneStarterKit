function Add-ISKAPProfile {
    <#
    .SYNOPSIS
        Add an Autopilot Profile to Intune

    .DESCRIPTION
        Add an Autopilot Profile to Intune
        
    .PARAMETER Name
        Name ot the Autopilot profile

    .PARAMETER AssignTo
        Group to assignt the profile to

    .PARAMETER Language
        Langegae of the Profile, eg. de-CH

    .PARAMETER userType
        User Type of the primary USer (standard or administrator)

    .PARAMETER description
        Description of the Autopilot profile

    #>

    param (
        [parameter(Mandatory = $false, HelpMessage = "Name of the Autopilot Profile")]
        [ValidateNotNullOrEmpty()]
        [string]$Name = "Default ISK Profile",

        [parameter(Mandatory = $false, HelpMessage = "ID of the Autopilot Profile")]
        [ValidateNotNullOrEmpty()]
        [string]$AssignTo,

        [parameter(Mandatory = $false, HelpMessage = "ID of the Autopilot Profile")]
        [ValidateNotNullOrEmpty()]
        [string]$Language = "de-CH",

        [parameter(Mandatory = $false, HelpMessage = "ID of the Autopilot Profile")]
        [ValidateNotNullOrEmpty()]
        [string]$userType = "standard",

        [parameter(Mandatory = $false, HelpMessage = "ID of the Autopilot Profile")]
        [ValidateNotNullOrEmpty()]
        [string]$description = "Profile created with the IntuneStarterKit"

    )

    try{

        # Get current Profiles
        Write-Verbose "Checking for Profile with Name: $Name"

        $uri = "https://graph.microsoft.com/beta/deviceManagement/windowsAutopilotDeploymentProfiles?`$filter=displayName eq '$Name'"
        $Method = "GET"
        $APProfile = (Invoke-MgGraphRequest -Method $Method -uri $uri).value.displayName
        Write-Verbose "  found: $APProfile"

        if($APProfile -eq $Name){
            Write-Error "Profile with the Name $Name alreade exists. To overrwite use -Force"
            break  
        }
        

    
$json_ap = @"
{
    "@odata.type": "#microsoft.graph.azureADWindowsAutopilotDeploymentProfile",
    "displayName": "$Name",
    "description": "$description",
    "language": "$Language",
    "extractHardwareHash": true,
    "deviceNameTemplate": "%SERIAL%",
    "deviceType": "windowsPc",
    "enableWhiteGlove": true,
    "outOfBoxExperienceSettings": {
        "hidePrivacySettings": true,
        "hideEULA": true,
        "userType": "standard",
        "deviceUsageType": "singleUser",
        "skipKeyboardSelectionPage": false,
        "hideEscapeLink": true
    },
    "enrollmentStatusScreenSettings": {
        "@odata.type": "microsoft.graph.windowsEnrollmentStatusScreenSettings",
        "hideInstallationProgress": false,
        "allowDeviceUseBeforeProfileAndAppInstallComplete": true,
        "blockDeviceSetupRetryByUser": true,
        "allowLogCollectionOnInstallFailure": true,
        "installProgressTimeoutInMinutes": 120,
        "allowDeviceUseOnInstallFailure": true
    }
}
"@
            
        
        Write-Verbose "Send Graph request to create AP profile: $Name"
        Write-Verbose $json_ap
        $Resource = "deviceManagement/windowsAutopilotDeploymentProfiles"
        $uri = "https://graph.microsoft.com/beta/$Resource"
        $Method = "POST"
        $Create_Profile = Invoke-MgGraphRequest -Method $Method -uri $uri -Body $json_ap     
        $Get_Profile_ID = $Create_Profile.ID

        # Assign Profile 
        Write-Verbose "Assign AP profile to $AssignTo"
        $Assignment_Body = @"
{"target":{"@odata.type":"#microsoft.graph.groupAssignmentTarget","groupId":"$AssignTo"}}
"@

        $uri = "https://graph.microsoft.com/beta/deviceManagement/windowsAutopilotDeploymentProfiles/$($Get_Profile_ID)/assignments"
        $Method = "POST"
        $MgRequest = Invoke-MgGraphRequest -Uri $uri -Method $Method -Body $Assignment_Body
        Write-Verbose $MgRequest

    }catch{
        Write-Error $_
    }

    

}














