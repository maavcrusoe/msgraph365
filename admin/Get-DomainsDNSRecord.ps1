# Application (client) ID, tenant Name and secret
$clientID = "YOUT CLIENT ID"
$tenantName = "YOUR TENANT ID"
$clientSecret = "YOUR SECRET KEY"
$resource = "https://graph.microsoft.com/"

$from = "from@domain.com"
$to = "to@domain.com"
$subject = "TITTLE"
$smtpServer = "SERVER"

$ReqTokenBody = @{
    Grant_Type    = "client_credentials"
    Scope         = "https://graph.microsoft.com/.default"
    client_Id     = $clientID
    Client_Secret = $clientSecret
} 

$TokenResponse = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$TenantName/oauth2/v2.0/token" -Method POST -Body $ReqTokenBody
#write-host $TokenResponse

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

function Get-Domains {
    #Obtain all domains from ms graph
    $apiUrl = "https://graph.microsoft.com/v1.0/domains/"
    $Data = Invoke-RestMethod -Headers @{Authorization = "Bearer $($Tokenresponse.access_token)"} -Uri $apiUrl -Method Get
    $domain = ($Data | Select-Object Value).Value 
    write-host "We found :" $domain.count

    return $domain.id
}


function Get-DomainsDNSRecord {
    $msglist = [System.Collections.Generic.List[Object]]::new()
    $365Domains = [System.Collections.Generic.List[Object]]::new()
    $StoredData = @(
       [pscustomobject]@{domain='DOMAIN.com';mailExchange='DOMAIN.mail.protection.outlook.com';text='v=spf1 include:spf.protection.outlook.com -all';canonicalName='autodiscover.outlook.com';}
        #...
   )

    $domains = @()
    $domains = Get-Domains
    foreach ($item in $domains) {
        
        write-host $item -ForegroundColor yellow
        $apiUrl = "https://graph.microsoft.com/v1.0/domains/$item/serviceConfigurationRecords"
        $Data = Invoke-RestMethod -Headers @{Authorization = "Bearer $($Tokenresponse.access_token)"} -Uri $apiUrl -Method Get
        $domain = ($Data | Select-Object Value).Value 

        if ($item -eq "DOMAIN.mail.onmicrosoft.com") {

        }else{
            #Write-host  $domain[0]
            write-host "mailExchange: " $domain[0].mailExchange

            #Write-host  $domain[1]
            write-host "text: " $domain[1].text

            #Write-host  $domain[2]
            write-host "canonicalName: " $domain[2].canonicalName

            $365DomainData = [PSCustomObject]@{
                domain    = $item
                mailExchange    = $domain[0].mailExchange
                text    = $domain[1].text
                canonicalName    = $domain[2].canonicalName
            }      
            $365Domains.Add($365DomainData) 
        }

    }

    $i = 0
    foreach ($item in $StoredData) {
        $a = Compare-Object -ReferenceObject $item.domain -DifferenceObject $365Domains[$i].domain -IncludeEqual 
        $b = Compare-Object -ReferenceObject $item.mailExchange -DifferenceObject $365Domains[$i].mailExchange -IncludeEqual 
        $c = Compare-Object -ReferenceObject $item.text -DifferenceObject $365Domains[$i].text -IncludeEqual 
        $i = $i + 1
        if ($a.SideIndicator -eq '=>' -or $b.SideIndicator -eq '=>' -or $c.SideIndicator -eq '=>') {
            write-host $item.domain -ForegroundColor Red
            write-host $item.SideIndicator
            $msglist.Add($item)
        }else {
            Write-Host $item.domain "OK" -ForegroundColor green
        }
    }
    if ($msglist) {
        #variables SMTP
        $msg = "Domain: "+ $msglist.domain + "`n" + "mailExchange:" + $msglist.mailExchange + "`n" + "text:" + $msglist.text + "`n" + "canonicalName:" + $msglist.canonicalName
        Send-MailMessage -From $from -To $to -Subject $subject -Body $msg  -smtpserver $smtpServer
    }
    
}


Get-DomainsDNSRecord
