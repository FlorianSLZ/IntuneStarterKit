[![Twitter Follow](https://img.shields.io/badge/Twitter-1DA1F2?style=for-the-badge&logo=twitter&logoColor=white)](https://twitter.com/FlorianSLZ/)  [![LinkedIn](https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/fsalzmann/)  [![Website](https://img.shields.io/badge/website-000000?style=for-the-badge&logo=About.me&logoColor=white)](https://scloud.work/en/about)

# IntuneStarterKit (ISK)
![PowerShell Gallery](https://img.shields.io/powershellgallery/dt/IntuneStarterKit)

This module was created to have a kick start with Intune for managin WIndows devices. 
You will habe an Autopilot Profile, some basisc Windows & Security Settings as well as some apps. 

**More Infos at: [IntuneStarterKit | scloud.work](https://scloud.work/en/intunestarterkit/)**


## Installing the module from PSGallery

The IntuneStarterKit module is published to the [PowerShell Gallery](https://www.powershellgallery.com/packages/IntuneStarterKit). Install it on your system by running the following in an elevated PowerShell console:
```PowerShell
Install-Module -Name IntuneStarterKit
```

## Import the module for testing

As an alternative to installing, you chan download this Repository and import it in a PowerShell Session. 
*The path may be different in your case*
```PowerShell
Import-Module -Name "C:\GitHub\IntuneStarterKit\Module\IntuneStarterKit" -Verbose -Force
```

## Module dependencies

IntuneStarterKit module requires the following modules, which will be automatically installed as dependencies:
- Microsoft.Graph.Authentification
- Microsoft.Graph.Groups
- Microsoft.Graph.Intune
- IntuneBackupAndRestore
- IntuneWin32App


# Functions / Examples

Here are all functions and some examples to start with:

- Add-ConfigurationPolicyAssignment
- Add-DeviceCompliancePolicyAssignment
- Add-DeviceConfigurationPolicyAssignment
- Add-DeviceManagementScriptAssignment
- Add-ISK
- Add-ISKAPProfile
- Add-ISKApps
- Add-ISKConfiguration
- Add-ISKESP
- Connect-ISK
- Get-ConfigurationPolicyAssignment
- Get-DeviceConfigurationPolicyAssignment
- Invoke-GitHubDownload
- Invoke-PagingRequest- 

## Authentication
Before using any of the functions within this module that interacts with Graph API, ensure you are authenticated. 

With this command, you'll be connected to the Graph API and be able to use all commands
```PowerShell
# Authentication as User
Connect-ISK
```

## Basic commands
### Get Devices

```PowerShell
# Creates predefinied groups, configurations and apps, AP Profile language "de-CH"
Add-ISK -Language = "de-CH"

```

## Create your own App repository

Build you apps with the following schema:

| File | purpose |
|--|--|
| install.ps1 | installatoin routine |
| uninstall.ps1 | uninstallatoin routine |
| check.ps1 | validation script |
| AppName.intunewin | Intunewinfile of the app |

And save the output in a stucture like this:
![App repo](https://scloud.work/wp-content/uploads/2022/12/image-20-300x283.webp)

Here is a blogpost which describes the whole process: [My take on Intune Win32 apps - scloud.work](https://scloud.work/en/my-take-on-win32-apps/)

### only import apps

```PowerShell
Add-ISKApps -Path # GitHub or local path
```

## Create your own configuration repository

```PowerShell
# export config
Start-IntuneBackup -Path "C:\temp\IntuneBackup"

# Add and assign
Add-ISKConfiguration -Path # GitHub or local path
```

## Create your own deployment

```PowerShell
# Option 1: Custom Language, Apps, Config and Group names
Add-ISK `
-APGroupName "My-AP-Group" `
-StdGroupName "My-Default-Group" `
-Language "de-CH" `
-AppGroupPrefix "My-App-" `
-AppRepoPath "C:\ISK\Apps" `
-ConfigRepoPath "C:\ISK\Configuration"

# Option 2: Only Autopilot Profile, Apps and Configuration with custom dynamic "marketing" Group
## create dynamic group based on group tag "Marketing"
$APGroupTag = New-MgGroup -DisplayName "DEV-WIN-Marketing" `
-Description "Autopilot group tag: Marketing" `
-MailEnabled:$false `
-SecurityEnabled:$true `
-MailNickname "DEV-WIN-Marketing" `
-GroupTypes "DynamicMembership" `
-MembershipRule '(device.devicePhysicalIds -any (_ -eq "[OrderID]:Marketing"))' `
-MembershipRuleProcessingState "On"
## create Autopilot profile for Marketing
Add-ISKAPProfile -Name "Marketing" -AssignTo $APGroupTag.id -Language "en-UK"
## Import configuration and assign to Marketing group
Add-ISKConfiguration -Path "C:\ISK\Configuration" -AssignTo $APGroupTag.id
## Import Apps for marketing and assign them
Add-ISKApps -Path "C:\ISK\Apps" -AssignTo $APGroupTag.id
```