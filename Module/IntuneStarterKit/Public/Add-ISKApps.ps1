function Add-ISKApps {
    <#
    .SYNOPSIS
        Connect to the MSGraph

    .DESCRIPTION
        Connect to the MSGraph
        
    .PARAMETER Path
        Path to the installwin(s)

    .PARAMETER Publisher
        App publisher


    #>

    param (
        [parameter(Mandatory = $false, HelpMessage = "Path to the installwin(s)")]
        [ValidateNotNullOrEmpty()]
        [string]$Path = "https://github.com/FlorianSLZ/IntuneStarterKit/tree/main/Samples/Apps",

        [parameter(Mandatory = $false, HelpMessage = "App publisher")]
        [ValidateNotNullOrEmpty()]
        [string]$Publisher = "scloud.work",

        [parameter(Mandatory = $false, HelpMessage = "Path where online files will be stored")]
        [ValidateNotNullOrEmpty()]
        [string]$DestinationPath = "$env:temp\IntuneStarterKit\Apps\",

        [parameter(Mandatory = $false, HelpMessage = "Assign configuration to group with specified ID")]
        [ValidateNotNullOrEmpty()]
        [string]$AssignTo

    )


    try{

        if($Path -like "https://github.com/*"){

            $Owner = $($Path.Replace("https://github.com/","")).Split("/")[0]
            $Repository = $($Path.Replace("https://github.com/$Owner/","")).Split("/")[0]
            $RepoPath = $($Path.Replace("https://github.com/$Owner/$Repository/tree/main/",""))

            Invoke-GitHubDownload -Owner $Owner -Repository $Repository -Path $RepoPath -DestinationPath $DestinationPath
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
        
        <# Get TenantID
        Write-Verbose "Get Tenant ID"
        $uri = "https://graph.microsoft.com/v1.0/organization"
        $Method = "GET"
        $TenantID = (Invoke-MgGraphRequest -Method $Method -uri $uri).value.id
        #>
        
        # Create Acces Token for MSIntuneGraph
        Write-Verbose "Connect to MS Intune Enviroment via Connect-MSIntuneGraph"
        $Current_MgContext = Get-MgContext
        $Global:AccessToken = Get-MsalToken -ClientID $Current_MgContext.ClientId -TenantId $Current_MgContext.TenantId

        $Global:AuthenticationHeader = @{
                    "Content-Type" = "application/json"
                    "Authorization" = $AccessToken.CreateAuthorizationHeader()
                    "ExpiresOn" = $AccessToken.ExpiresOn.LocalDateTime
                }
        Write-Verbose $Global:AuthenticationHeader

        $AllAppFolders = Get-ChildItem $PathLocal 
    
        foreach($AppFolder in $AllAppFolders){
            # Read intunewin file
            $IntuneWinFile = (Get-ChildItem $AppFolder.FullName -Filter "*.intunewin").FullName
    
            # Create requirement rule for all platforms and Windows 10 2004
            $RequirementRule = New-IntuneWin32AppRequirementRule -Architecture "x64" -MinimumSupportedWindowsRelease "2004"
    
            # Create PowerShell script detection rule
            $DetectionScriptFile = (Get-ChildItem $AppFolder.FullName -Filter "check.ps1").FullName
            $DetectionRule = New-IntuneWin32AppDetectionRuleScript -ScriptFile $DetectionScriptFile -EnforceSignatureCheck $false -RunAs32Bit $false
    
            # Add new EXE Win32 app
            $InstallPS1 = (Get-ChildItem $AppFolder.FullName -Filter "*.intunewin").Name -replace(".intunewin","")
            $InstallCommandLine = "powershell.exe -ExecutionPolicy Bypass -File .\$InstallPS1.ps1"
            $UninstallCommandLine = "powershell.exe -ExecutionPolicy Bypass -File .\uninstall.ps1"
            $AppUpload = Add-IntuneWin32App -FilePath $IntuneWinFile -DisplayName $AppFolder.Name -Description $AppFolder.Name -Publisher $Publisher -InstallExperience "system" -RestartBehavior "suppress" -DetectionRule $DetectionRule -RequirementRule $RequirementRule -InstallCommandLine $InstallCommandLine -UninstallCommandLine $UninstallCommandLine
            Write-Verbose $AppUpload

            if($AssignTo){
                Add-IntuneWin32AppAssignmentGroup -Include -ID $AppUpload.id -GroupID $AssignTo -Intent "required" -Notification "showAll" -Verbose
            }
        }

        Write-Host "Apps imported and assigned: " -ForegroundColor Green
        $($AllAppFolders.Name)

    }catch{
        Write-Error $_
    }
    

    
}