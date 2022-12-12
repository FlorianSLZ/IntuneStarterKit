[![Twitter Follow](https://img.shields.io/badge/Twitter-1DA1F2?style=for-the-badge&logo=twitter&logoColor=white)](https://twitter.com/FlorianSLZ/)  [![LinkedIn](https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/fsalzmann/)  [![Website](https://img.shields.io/badge/website-000000?style=for-the-badge&logo=About.me&logoColor=white)](https://scloud.work/en/about)

# IntuneStarterKit (ISK)
![PowerShell Gallery](https://img.shields.io/powershellgallery/dt/IntuneStarterKit)

This module was created to have a kick start with Intune for managin WIndows devices. 
You will habe an Autopilot Profile, some basisc WIndows & Security Settings as well as some apps. 


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
- IntuneBackupAndRestore
- IntuneWin32App

# Functions / Examples

Here are all functions and some examples to start with:

- Add-ISK

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
# Import predefinied configuration
Add-ISK

```

## Create your own App repository

xxxxxxxxxxxxxxxxx

### only import apps

```PowerShell
Invoke-IDIDeviceSync -All
```

## Create your own configuration repository

xxxxxxxxxxxxxxxxx



