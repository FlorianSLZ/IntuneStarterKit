function Add-ISK {
    <#
    .SYNOPSIS
        Call all functions to create the IntuneStarterKit

    .DESCRIPTION
        Call all functions to create the IntuneStarterKit
        
    .PARAMETER ClientId
        Name of the group which contains all Autopilot devices


    #>

    param (
        [parameter(Mandatory = $false, HelpMessage = "Name of the group which contains all Autopilot devices")]
        [ValidateNotNullOrEmpty()]
        [string]$APGroupName = "DEV-WIN-Autopilot",
        
    )


    try{
        Write-Verbose "Calling Add-ISKAPGroup for basic Groups ..."
        $APGroup = Add-ISKGroup -GroupName $APGroupName -GroupDescription "Group containing all Autopilot registered devices" -GroupType "DynamicMembership" -GroupRule "(device.devicePhysicalIds -any _ -eq ""[OrderID]:$OrderID"")"
        #Add-ISKGroup -GroupName "DEV-WIN-Standard" -GroupDescription "Group for standard policies and applications" -GroupRule ""

        Write-Verbose "Calling Add-ISKAPProfile ..."
        Add-ISKAPProfile -AssignTo $APGroup

        Write-Verbose "Calling Add-ISKApps ..."
        Add-ISKApps -Path "https://github.com/FlorianSLZ/IntuneStarterKit/tree/main/Samples/Apps"

    }catch{
        Write-Error $_
    }
    
            
   

}
