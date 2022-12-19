
Function Add-DeviceCompliancePolicyAssignment(){

<#
.SYNOPSIS
This function is used to add a device compliance policy assignment using the Graph API REST interface
.DESCRIPTION
The function connects to the Graph API Interface and adds a device compliance policy assignment
.EXAMPLE
Add-DeviceCompliancePolicyAssignment -CompliancePolicyId $CompliancePolicyId -TargetGroupId $TargetGroupId
Adds a device compliance policy assignment in Intune
.NOTES
NAME: Add-DeviceCompliancePolicyAssignment
#>

[cmdletbinding()]

param
(
    $CompliancePolicyId,
    $TargetGroupId
)

$graphApiVersion = "v1.0"
$Resource = "deviceManagement/deviceCompliancePolicies/$CompliancePolicyId/assign"
    
    try {

        if(!$CompliancePolicyId){

        write-host "No Compliance Policy Id specified, specify a valid Compliance Policy Id" -f Red
        break

        }

        if(!$TargetGroupId){

        write-host "No Target Group Id specified, specify a valid Target Group Id" -f Red
        break

        }

$JSON = @"
    {
        "assignments": [
        {
            "target": {
            "@odata.type": "#microsoft.graph.groupAssignmentTarget",
            "groupId": "$TargetGroupId"
            }
        }
        ]
    }
    
"@

    $uri = "https://graph.microsoft.com/$graphApiVersion/$($Resource)"
    $Method = "POST"
    Invoke-MgGraphRequest -Method $Method -uri $uri -Body $JSON

    }
    
    catch {

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