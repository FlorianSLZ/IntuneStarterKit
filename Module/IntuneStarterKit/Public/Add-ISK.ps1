function Add-ISK {
    <#
    .SYNOPSIS
        Call all functions to create the IntuneStarterKit

    .DESCRIPTION
        Call all functions to create the IntuneStarterKit
        
    .PARAMETER APGroupName
        Name of the group which contains all Autopilot devices

    .PARAMETER Language
        Language of the AP Profile

    .PARAMETER AppGroup
        If set, a install group will be added per app

    .PARAMETER AppGroupPrefix
        Prefix for the apps install group (if -AppGroup in in place)


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
        [string]$Language = "de-CH",

        [parameter(Mandatory = $false, HelpMessage = "If set, a install group will be added per app")]
        [ValidateNotNullOrEmpty()]
        [switch]$AppGroup, 

        [parameter(Mandatory = $false, HelpMessage = "Prefix for the apps install group (if -AppGroup in in place)")]
        [ValidateNotNullOrEmpty()]
        [string]$AppGroupPrefix = "APP-WIN-",

        [parameter(Mandatory = $false, HelpMessage = "Prefix for the apps install group (if -AppGroup in in place)")]
        [ValidateNotNullOrEmpty()]
        [string]$AppRepoPath = "https://github.com/FlorianSLZ/IntuneStarterKit/tree/main/Samples/Apps",

        [parameter(Mandatory = $false, HelpMessage = "Prefix for the apps install group (if -AppGroup in in place)")]
        [ValidateNotNullOrEmpty()]
        [string]$ConfigRepoPath = "https://github.com/FlorianSLZ/IntuneStarterKit/tree/main/Samples/Configuration"
        
    )

    $ErrorActionPreference = "Stop"

    try{
        ############################################################################
        #   Groups
        ############################################################################
        Write-Verbose "Calling New-MgGroup for basic Groups ..."
        $APGroup = New-MgGroup -DisplayName $APGroupName -Description "Group containing all Autopilot registered devices" -MailEnabled:$false -SecurityEnabled:$true -MailNickname $APGroupName -GroupTypes "DynamicMembership" -MembershipRule '(device.devicePhysicalIDs -any (_ -contains "[ZTDID]"))' -MembershipRuleProcessingState "On"
        Write-Host "Dynamic Autopilot group created: $APGroupName" -ForegroundColor Green

        $StdGroup = New-MgGroup -DisplayName $StdGroupName -Description "Group for standard configuration and apps" -MailEnabled:$false -SecurityEnabled:$true -MailNickname $StdGroupName
        Write-Host "Security group for assigments created: $StdGroupName" -ForegroundColor Green

        New-MgGroupMember -GroupId $StdGroup.id -DirectoryObjectId $APGroup.id
        Write-Host "Added ""$APGroupName"" as a Memeber of ""$StdGroupName""." -ForegroundColor Green



        ############################################################################
        #   Autopilot profile
        ############################################################################
        Write-Verbose "Calling Add-ISKAPProfile ..."
        Add-ISKAPProfile -AssignTo $APGroup.id -Language $Language


        ############################################################################
        #   ESP
        ############################################################################
        Write-Verbose "Calling Add-ISKESP ..."
        Add-ISKESP -AssignTo $APGroup.id


        ############################################################################
        #   Intune Policies
        ############################################################################
        Write-Verbose "Calling Add-ISKConfiguration ..."
        Add-ISKConfiguration -Path $ConfigRepoPath -AssignTo $StdGroup.id

        
        ############################################################################
        #   Win32 Apps
        ############################################################################
        Write-Verbose "Calling Add-ISKApps ..."
        if($AppGroup -eq $false){
            Add-ISKApps -Path $AppRepoPath -AssignTo $StdGroup.id
        }else{
            Add-ISKApps -Path $AppRepoPath -AssignTo $StdGroup.id -AppGroup
        }
        

        Write-Host "Done. Your Intune environment is ready!" -BackgroundColor Green -ForegroundColor Black

    }catch{
        Write-Error $_
    }
    
            
   

}
