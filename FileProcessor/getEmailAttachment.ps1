# steps to use
# put your clientID and clientSecret with your tenant
# put your user UPN and your mailfolder ID in the while loop
# works using a subfolder in a mailbox, only receive emails with an specific title and 1 attachment
# title is used to select destination folder, each title is a queue in FileProcessor to print attachment with specific tray
# to retreive subfolder id on mailbox you can use this query https://graph.microsoft.com/beta/users/UPN/mailFolders/



#Application (client) ID, tenant Name and secret
$clientID = "xxxxx"
$TenantName = "tenant.onmicrosoft.com"
$clientSecret = "xxxxx"
$resource = "https://graph.microsoft.com/"

$ReqTokenBody = @{
    Grant_Type    = "client_credentials"
    Scope         = "https://graph.microsoft.com/.default"
    client_Id     = $clientID
    Client_Secret = $clientSecret
} 

# create token
$global:TokenResponse = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$($TenantName)/oauth2/v2.0/token" -Method POST -Body $ReqTokenBody

$path = "C:\hotfolder\"                  # set up folder path
$global:StartMS = (Get-Date)             # start date
$LogFile = "C:\Log\fileprocessor.txt"    #log file


function LogMessage {
    param([string]$Message)
    ((Get-Date).ToString() + " - " + $Message) >> $LogFile;
}

# Refresh token
function timeExecution {
    $global:EndMS = (Get-Date)
    $global:timeExecution = $global:EndMS - $global:StartMS 
    #Write-Host "time: " $global:timeExecution -fore Blue

    if ($global:timeExecution -gt "00:59:00.00") {
        write-host "create new token" -BackgroundColor  DarkCyan
        $newTokenResponse = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$($TenantName)/oauth2/v2.0/token" -Method POST -Body $ReqTokenBody
        write-host "old token" $global:TokenResponse -for red
        write-host "new token" $newTokenResponse  -for green

        $global:StartMS  = (Get-Date)
        $global:EndMS = (Get-Date)
        $global:timeExecution = $global:EndMS - $global:StartMS #"00:00:00.00"
        $global:TokenResponse = $newTokenResponse
        write-host $global:TokenResponse -ForegroundColor blue
    }else {
        return $global:timeExecution
    }
}

# delete email 
function DeleteEmail {
    param ($userId,$folderId,$mailId)
    Try {
        $apiUrl = "https://graph.microsoft.com/v1.0/users/$($userId)/mailFolders/$($folderId)/messages/$($mailId)"
        write-host $apiUrl
        Invoke-RestMethod -Headers @{Authorization = "Bearer $($TokenResponse.access_token)"} -Uri $apiUrl -Method "DELETE"
    }Catch {
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# get email attachment 
function getEmailAttachment {
    param($user,$mailFolders,$messages,$attachments)
    $headers = @{
        "Content-Type" = "application/pdf"
        "Authorization" = "Bearer $($global:TokenResponse.access_token)"
    }
    
    $query = "https://graph.microsoft.com/beta/users/$($user)/mailFolders/$($mailFolders)/messages/$($messages)/attachments/$($attachments)"
    $r = Invoke-RestMethod -Method 'GET' -Uri $query -Body $fileInBytesFinal -Headers $headers

    if ($r){
        write-host "File detected: $($r.name) - $($r.size)" -ForegroundColor Green
        $time = $r.lastModifiedDateTime -replace(":","-")

        # Get Attachment as Base64
        $Base64B = ($r.contentBytes)

        # Save Base64 to file
        $Bytes = [Convert]::FromBase64String($Base64B)
        [IO.File]::WriteAllBytes($path+"\"+$subject+"\"+$time+$r.name, $Bytes) 

        LogMessage -Message "File stored in: $($path+"\"+$subject+"\"+$time+$r.name)"
        
        # delete email
        DeleteEmail -userId $user -mailId $messages -folderId $mailFolders
    }else {
        Write-host "No file detected!" -ForegroundColor Red
    }
}

# get unread Emails  
function getEmails {
    param ($user,$mailFolders)
    $headers = @{
        "Content-type"  = "application/json;charset=utf-8"
        "Authorization" = "Bearer $($global:TokenResponse.access_token)"
    }
    $count = 0
    $query = "https://graph.microsoft.com/beta/users/$($user)/mailFolders/$($mailFolders)/messages/?`$orderby=lastModifiedDateTime&`$filter=isRead%20eq%20false"

    $response = Invoke-RestMethod -Method 'GET' -Uri $query -Headers $headers
    if ($response){     
        if ($response.value.Count -ge 1) {
            write-host "Emails found: $($response.value.Count)" -ForegroundColor Yellow
            $email = $response.value
            $email | ForEach-Object {
                write-host $count
                $sender = $_.sender.emailAddress.address
                $from = $_.from.emailAddress.address
                $subject = $_.subject
                $isRead = $_.isRead
                $mailId = $_.id
                $receivedDateTime = $_.receivedDateTime
                
                if($isRead -eq $False){
                    write-host "ID:" $mailId 
                    write-host "Sender:" $sender
                    write-host "From:" $from
                    write-host "Subject:" $subject
                    write-host "date:" $receivedDateTime
                    $query = "https://graph.microsoft.com/beta/users/$($user)/mailFolders/$($mailFolders)/messages/$($_.id)/attachments"
                    $emailresponse = Invoke-RestMethod -Method 'GET' -Uri $query -Headers $headers
                    
                    # obtain attachmet
                    getEmailAttachment -user $user -mailFolders $mailFolders -messages $_.id -attachments $emailresponse.value[0].id
                    start-sleep 5
                    $count += 1
                }
            }
        }
    }
}

# manually execution
#getEmails -user "user@email.com" -mailFolders "xxxxxx="    

# loop for fileprocessor
while ($true) {
    timeExecution
    write-host "start"
    getEmails -user "user@email.com" -mailFolders "xxxxxx"    
    write-host "Start sleep 20s"
    start-sleep 20
}