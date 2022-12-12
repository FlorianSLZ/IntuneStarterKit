function Invoke-PagingRequest {

    <#
    .SYNOPSIS
        Invoke Graph API reguest with paging

    .DESCRIPTION
        Invoke Graph API reguest with paging
        
    .PARAMETER URI
        Graph API uri

    .PARAMETER Method
        Graph API methode


    #>

    param (
        [parameter(Mandatory = $true, HelpMessage = "Graph Request URI")]
        [ValidateNotNullOrEmpty()]
        [string]$URI,

        [parameter(Mandatory = $true, HelpMessage = "Graph Request Methode")]
        [ValidateNotNullOrEmpty()]
        [ValidateSet("GET","POST","UPDATE")]
        [string]$Method

    )

    $GraphResponse = Invoke-MgGraphRequest -Method $Method -uri $uri

    $GraphResponseCollection = $GraphResponse.value 
    $UserNextLink = $GraphResponse."@odata.nextLink"


    while($UserNextLink -ne $null){

        $GraphResponse = (Invoke-MgGraphRequest -uri $UserNextLink -Method $Method)
        $UserNextLink = $GraphResponse."@odata.nextLink"
        $GraphResponseCollection += $GraphResponse.value

    }

    return $GraphResponseCollection
   
}