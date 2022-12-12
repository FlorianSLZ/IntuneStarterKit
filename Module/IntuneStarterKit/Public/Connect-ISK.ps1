function Connect-ISK {
    <#
    .SYNOPSIS
        Connect to the MgGraph with permissions needed by the IntuneStarterKit Module

    .DESCRIPTION
        Connect to the MgGraph with permissions needed by the IntuneStarterKit Module
        

    #>

    param (

    )


    try{
      
        Connect-MgGraph -Scopes "User.Read.All","Group.ReadWrite.All","DeviceManagementServiceConfig.ReadWrite.All"

    }catch{
        Write-Error $_
    }
    

    
}