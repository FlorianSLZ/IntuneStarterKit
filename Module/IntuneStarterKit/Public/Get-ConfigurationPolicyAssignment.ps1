Function Get-ConfigurationPolicyAssignment(){

<#
.SYNOPSIS
This function is used to get device configuration policy assignment from the Graph API REST interface - SETTINGS CATALOG Version
.DESCRIPTION
The function connects to the Graph API Interface and gets a device configuration policy assignment
.EXAMPLE
Get-ConfigurationPolicyAssignment $id guid
Returns any device configuration policy assignment configured in Intune
.NOTES
NAME: Get-ConfigurationPolicyAssignment
#>

[cmdletbinding()]

param
(
    [Parameter(Mandatory=$true,HelpMessage="Enter id (guid) for the Device Configuration Policy you want to check assignment")]
    $id
)

$graphApiVersion = "Beta"
$DCP_resource = "deviceManagement/configurationPolicies"

    try {

    $uri = "https://graph.microsoft.com/$graphApiVersion/$($DCP_resource)/$id/Assignments"
    $Method = "GET"
    (Invoke-MgGraphRequest -Method $Method -uri $uri).Value
    
    } catch {

    $ex = $_.Exception
    $errorResponse = $ex.Response.GetResponseStream()
    $reader = New-Object System.IO.StreamReader($errorResponse)
    $reader.BaseStream.Position = 0
    $reader.DiscardBufferedData()
    $responseBody = $reader.ReadToEnd();
    Write-Host "Response content:`n$responseBody" -f Red
    Write-Error "Request to $Uri failed with HTTP Status $($ex.Response.StatusCode) $($ex.Response.StatusDescription)"
    write-host
    break

    }

}
