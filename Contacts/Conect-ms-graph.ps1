#conect to ms graph API with app credentials

#edit here
$clientID = "xxxx"
$tenantName = "xxxx.onmicrosoft.com"
$clientSecret = "xxxxx"
$resource = "https://graph.microsoft.com/"


$ReqTokenBody = @{
    Grant_Type    = "client_credentials"
    Scope         = "https://graph.microsoft.com/.default"
    client_Id     = $clientID
    Client_Secret = $clientSecret
} 

Function Get-AuthorizationHeader {
    <#
    .SYNOPSIS
    Gets bearer access token and builds REST method authorization header.
    .DESCRIPTION
    Uses Office 365 Application ID and Application Secret to generate an authentication header for Microsoft Graph.
    .PARAMETER AppId
    Microsoft Azure Application ID.
    .PARAMETER AppSecret
    Microsoft Azure Application secret.
    #>
    Param (
        [parameter(Mandatory = $true)]
        [string]$AppId,

        [parameter(Mandatory = $true)]
        [string]$AppSecret,

        [parameter(Mandatory = $true)]
        [pscredential]$Credential
    )

    $Uri = "https://login.microsoftonline.com/tunelcom.onmicrosoft.com/oauth2/v2.0/token"
    $Body = @{
        grant_type = 'password'
        username = $Credential.UserName
        password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Credential.Password))
        client_id = $AppId
        client_secret = $AppSecret
        scope = 'https://graph.microsoft.com/.default'
        redirect_uri = 'https://localhost/'
    }
    $AuthResult = Invoke-RestMethod -Method Post -Uri $Uri -Body $Body

    #Function output
    @{
        'Authorization' = 'Bearer ' + $AuthResult.access_token
        'Content-type'  = "application/json;odata.metadata=minimal;odata.streaming=true;IEEE754Compatible=false;charset=utf-8"
    }
}

#execute function
Get-AuthorizationHeader -AppId $clientID -AppSecret $clientSecret -Credential "username@domain.com"
