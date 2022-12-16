function Add-ISKGroup {
    <#
    .SYNOPSIS
        Create Groups via Graph API

    .DESCRIPTION
        Create Groups via Graph API
        
    .PARAMETER GroupName
        Name of the Group

    .PARAMETER GroupRule
        Rule (if dynamic)

    .PARAMETER GroupDescription
        Group Description

    .PARAMETER GroupType
        Type of the group


    #>

    param (
        [parameter(Mandatory = $true, HelpMessage = "Name of the Group")]
        [ValidateNotNullOrEmpty()]
        [string]$GroupName,

        [parameter(Mandatory = $false, HelpMessage = "Rule (if dynamic)")]
        [ValidateNotNullOrEmpty()]
        [string]$GroupRule,

        [parameter(Mandatory = $false, HelpMessage = "Group Description")]
        [ValidateNotNullOrEmpty()]
        [string]$GroupDescription,

        [parameter(Mandatory = $false, HelpMessage = "Type of the group")]
        [ValidateNotNullOrEmpty()]
        [ValidateSet("DynamicMembership","[]")]
        [string]$GroupType,

        [parameter(Mandatory = $false, HelpMessage = "Type of the group")]
        [ValidateNotNullOrEmpty()]
        [string]$Members        
        
    )


    try{
        if(!$GroupType){
            $GroupType = "[]"
        }else{
            $GroupType = @("$GroupType")
        }

        if($GroupRule){
            $group = @{
                "displayName" = $GroupName;
                "description" = $GroupDescription;
                "groupTypes" = $GroupType;
                "mailEnabled" = $False;
                "mailNickname" = "$GroupName";
                "membershipRule" = $GroupRule;
                "membershipRuleProcessingState" = "On";
                "securityEnabled" = $True
            }
        }else{
            $group = @{
                "deletedDateTime" = "null";
                "classification"= "null";
                "description" = $GroupDescription;
                "displayName" = $GroupName;
                "groupTypes" = "[]";
                "mail" = "null";
                "mailEnabled" = $false;
                "mailNickname" = "";
                "preferredLanguage" = "null";
                "proxyAddresses"= "[]";
                "securityEnabled" = $true
            }
  
        }
       

        $requestBody = $group | ConvertTo-Json 

        $Method = "POST"
        $uri = "https://graph.microsoft.com/beta/groups/" 
        $GroupRequestRespond = Invoke-MgGraphRequest -Method $Method -uri $uri -Body $requestBody -ContentType 'application/json'
        Write-Verbose "Group created: $($GroupRequestRespond.id)!"
        
        if($Members){
            foreach($Member in $Members){
                Write-Verbose "Add Member to $GroupName, Member ID: $Member"
                $Method = "POST"
                $uri = "https://graph.microsoft.com/v1.0/groups/$($GroupRequestRespond.id)/members/`$ref"
                $requestBody  = @{
                    "@odata.id" = "https://graph.microsoft.com/v1.0/directoryObjects/$Member"
                }
                $AddMembersRequestRespond = Invoke-MgGraphRequest -Method $Method -uri $uri -Body $($requestBody | convertto-json)
                Write-Verbose $AddMembersRequestRespond
                   

            }
        }
        return $GroupRequestRespond.id

    }catch{
        Write-Error $_
    }
    
            
    

}
