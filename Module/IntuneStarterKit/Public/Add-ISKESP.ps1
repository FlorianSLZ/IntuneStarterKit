function Add-ISKESP {
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
        [string]$Name = "Autopilot ESP",

        [parameter(Mandatory = $true, HelpMessage = "ID of the Autopilot Profile")]
        [ValidateNotNullOrEmpty()]
        [string]$AssignTo,

        [parameter(Mandatory = $false, HelpMessage = "ID of the Autopilot Profile")]
        [ValidateNotNullOrEmpty()]
        [string]$description = "Custom Enrollment Status Page by ISK",

        [parameter(Mandatory = $false, HelpMessage = "ID of the Autopilot Profile")]
        [ValidateNotNullOrEmpty()]
        [string]$customErrorMessage = "There was an error, please press CONTINUE. We will fix the issue after the setup. ",

        [parameter(Mandatory = $false, HelpMessage = "ID of the Autopilot Profile")]
        [ValidateNotNullOrEmpty()]
        [string]$Timeout = "30"

    )

    try{

$json_esp = @"
    {
        "@odata.type": "#microsoft.graph.windows10EnrollmentCompletionPageConfiguration",
        "displayName": "$Name",
        "description": "$description",
        "showInstallationProgress": true,
        "blockDeviceSetupRetryByUser": false,
        "allowDeviceResetOnInstallFailure": false,
        "allowLogCollectionOnInstallFailure": true,
        "customErrorMessage": "$customErrorMessage",
        "installProgressTimeoutInMinutes": $Timeout,
        "allowDeviceUseOnInstallFailure": true
}
"@


        $uri = "https://graph.microsoft.com/beta/deviceManagement/deviceEnrollmentConfigurations"
        $Method = "POST"
        Write-Verbose "Send Graph request to set ESP profile."
        Write-Verbose $json_esp
        $MgRequest = Invoke-MgGraphRequest -Method $Method -uri $uri -Body $json_esp
        Write-Verbose $MgRequest

        $id = $MgRequest.id
        $uri = "https://graph.microsoft.com/beta/deviceManagement/deviceEnrollmentConfigurations/$id/assign" 
        $Method = "POST"      
$json_assigment = @"
    {
        "enrollmentConfigurationAssignments": [
            {
                "target": {
                    "@odata.type": "#microsoft.graph.groupAssignmentTarget",
                    "groupId": "$AssignTo"
                }
            }
        ]
    }
"@

        $MgRequest = Invoke-MgGraphRequest -Method $Method -uri $uri -Body $json_assigment 

        Write-Host "Enrollment Status Page (ESP) profile created: $Name" -ForegroundColor Green

    }catch{
        Write-Error $_
    }

    

}














