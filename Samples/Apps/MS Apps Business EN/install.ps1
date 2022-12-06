$PackageName = "MSApps_Business_DE_x64"

$Path_local = "$Env:Programfiles\_MEM"
Start-Transcript -Path "$Path_local\Log\$PackageName-install.log" -Force

$install_path = "$Path_local\Data\M365Apps"
New-Item -Type Directory -Path $install_path -Force

Start-Process "setup.exe" -Argument "/configure $PackageName.xml" -wait

Stop-Transcript
