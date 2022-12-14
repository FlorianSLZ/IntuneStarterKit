$RegPath = 'HKLM:\SOFTWARE\Microsoft\Office\ClickToRun\Configuration'
$Name = "ClientCulture"
$Value = "de-de"

$RegContent = Get-ItemPropertyValue -Path $RegPath -Name $Name
if($RegContent -eq $Value){

    $RegPath = 'HKLM:\SOFTWARE\Microsoft\Office\ClickToRun\Configuration'
    $Name = "SharedComputerLicensing"
    $Value = "0"

    $RegContent = Get-ItemPropertyValue -Path $RegPath -Name $Name
    if($RegContent -eq $Value){
    Write-Host "Found it!"
    }
}
