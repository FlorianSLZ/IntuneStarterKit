function Add-ISK {
    <#
    .SYNOPSIS
        Call all functions to create the IntuneStarterKit

    .DESCRIPTION
        Call all functions to create the IntuneStarterKit
        
    .PARAMETER APGroupName
        Name of the group which contains all Autopilot devices


    #>

    param (
        [parameter(Mandatory = $false, HelpMessage = "Name of the group which contains all Autopilot devices")]
        [ValidateNotNullOrEmpty()]
        [string]$APGroupName = "DEV-WIN-Autopilot",

        [parameter(Mandatory = $false, HelpMessage = "Name of the group which contains all Autopilot devices")]
        [ValidateNotNullOrEmpty()]
        [string]$StdGroupName = "DEV-WIN-Standard",

        [parameter(Mandatory = $false, HelpMessage = "Language of the AP Profile")]
        [ValidateNotNullOrEmpty()]
        [string]$Language = "de-CH"
        
    )


    try{
        Write-Verbose "Calling Add-ISKAPGroup for basic Groups ..."
        $APGroup = Add-ISKGroup -GroupName $APGroupName -GroupDescription "Group containing all Autopilot registered devices" -GroupType "DynamicMembership" -GroupRule '(device.devicePhysicalIDs -any (_ -contains "[ZTDID]"))'
        Write-Host "Dynamic Autopilot group created: $APGroupName" -ForegroundColor Green
        #$StdGroup = Add-ISKGroup -GroupName $StdGroupName -GroupDescription "Group for standard policies and applications" -Members $APGroup

        Write-Verbose "Calling Add-ISKAPProfile ..."
        Add-ISKAPProfile -AssignTo $APGroup -Language $Language

        Write-Verbose "Calling Add-ISKESP ..."
        Add-ISKESP -AssignTo $APGroup

        Write-Verbose "Calling Add-ISKConfiguration ..."
        Add-ISKConfiguration -AssignTo $APGroup

        Write-Verbose "Calling Add-ISKApps ..."
        Add-ISKApps -AssignTo $APGroup

    }catch{
        Write-Error $_
    }
    
            
   

}
