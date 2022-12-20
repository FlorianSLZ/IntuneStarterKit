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
      
        #Connect-MgGraph -Scopes "User.Read.All","Group.ReadWrite.All","DeviceManagementServiceConfig.ReadWrite.All"
        Connect-MgGraph 

        Connect-MSGraph -Quiet 

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
        
    }catch{
        Write-Error $_
    }
    

    
}