# Application (client) ID, tenant Name and secret
$clientID = "xxxxxx"
$tenantName = "tenant.onmicrosoft.com"
$clientSecret = "xxxxxx"
$resource = "https://graph.microsoft.com/"
$LogFile = "C:\Log\Contactos.txt"

$ReqTokenBody = @{
    Grant_Type    = "client_credentials"
    Scope         = "https://graph.microsoft.com/.default"
    client_Id     = $clientID
    Client_Secret = $clientSecret
} 


$TokenResponse = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$TenantName/oauth2/v2.0/token" -Method POST -Body $ReqTokenBody
#write-host "Token: " $TokenResponse.access_token
#write-host "Expires in: " $TokenResponse.ext_expires_in

function DeleteEmail {
    param ($userId, $mailId)

    Try {
        $apiUrl = "https://graph.microsoft.com/v1.0/users/$userId/mailFolders/$folderId/messages/$mailId"
        write-host $apiUrl
        Invoke-RestMethod -Headers @{Authorization = "Bearer $($TokenResponse.access_token)"} -Uri $apiUrl -Method "DELETE"
    }
        Catch {
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    }

}


function Get-LastEmail {
    param ($userId, $folderId)
    #GET /users/{id | userPrincipalName}/mailFolders/{id}/messages/{id}/$value 
    #https://graph.microsoft.com/v1.0/users/$userId/mailFolders?`$top=250&`$expand=childFolders
    #write-host $email.childFolders[0] -ForegroundColor yellow
    #$email.childFolders | Out-GridView
    
    $apiUrl = "https://graph.microsoft.com/v1.0/users/$userId/mailFolders/$folderId/messages"#?`$top=900" #test
    write-host $apiUrl
    $Data = Invoke-RestMethod -Headers @{Authorization = "Bearer $($TokenResponse.access_token)"} -Uri $apiUrl -Method Get
    $email = ($Data | Select-Object Value).Value 

    write-host $email.count -ForegroundColor yellow
    
    foreach ($x in $email) {
        $sender = $x.sender.emailAddress.address
        $from = $x.from.emailAddress.address
        $emailAddresses = $x.emailAddresses.address
        $subject = $x.subject
        $bodyPreview = $x.bodyPreview
        $isRead = $x.isRead
        $mailId = $x.id

        write-host $sender
        write-host $from
        write-host $emailAddresses
        write-host $subject
        write-host $bodyPreview
        write-host $isRead
        write-host $mailId
    }
    
    DeleteEmail -userId $userId -mailId $mailId
    
    $email | Out-GridView
}

$userId = "alertas@tunel.com"
$folderId = "AAMkAGEwOWVlY2QzLWU4YjktNDNkNy04OWUzLWQ0NmZmNmY1OTBiMgAuAAAAAAC6yLo0HmS0QrohcwyVOw6UAQBAkH6rluENSJ1fbS5ozEtmAANzKfU-AAA="
$mailId = "AAMkAGEwOWVlY2QzLWU4YjktNDNkNy04OWUzLWQ0NmZmNmY1OTBiMgBGAAAAAAC6yLo0HmS0QrohcwyVOw6UBwBAkH6rluENSJ1fbS5ozEtmAANzKfU-AABAkH6rluENSJ1fbS5ozEtmAAPD-9kKAAA="
Get-LastEmail -userId $userId -folderId $folderId