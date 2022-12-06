$PackageName = "Bloatware-Removal_Windows"

$Path_local = "$Env:Programfiles\_MEM"
Start-Transcript -Path "$Path_local\Log\$PackageName-install.log" -Force
try{
    $AppList = Get-Content "WindowsApps.txt"
    Write-Host "----------------------------------------------"
    Write-Host "APPs to REMOVE"
    Write-Host "----------------------------------------------"
    $AppList
    Write-Host "----------------------------------------------"


    ForEach ($App in $AppList) {
        $App = $App.TrimEnd()
        $PackageFullName = (Get-AppxPackage $App).PackageFullName
        $ProPackageFullName = (Get-AppxProvisionedPackage -online | where {$_.Displayname -eq $App}).PackageName

        if ($PackageFullName) {
            Write-Host "Removing Package: $App"
            Start-Sleep -Seconds 5
            Remove-AppxPackage -package $PackageFullName
        }
        else {
            "Unable to find package: $App" 
        }

        if ($ProPackageFullName) {
            Write-Host "Removing Provisioned Package: $ProPackageFullName"
            Start-Sleep -Seconds 5 
            Remove-AppxProvisionedPackage -online -packagename $ProPackageFullName  
        }
        else {
            "Unable to find provisioned package: $App"
        }
    }

    # Validation file
    New-Item -Path "$Path_local\Validation\$PackageName" -ItemType "file" -Force 
    
}catch{
    Write-Error $_
}


Stop-Transcript