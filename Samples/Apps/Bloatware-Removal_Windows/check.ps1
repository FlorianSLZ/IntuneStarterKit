######################################################################################################################
# Program EXE/File exists
######################################################################################################################
$ProgramPath = Test-Path "C:\Program Files\_MEM\Validation\Bloatware-Removal_Windows"

if($ProgramPath){
    Write-Host "Found it!"
}
