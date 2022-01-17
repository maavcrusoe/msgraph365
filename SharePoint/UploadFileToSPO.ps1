function GetMSGraphToken {
   #MSGRAPH
    $clientID = "xxxxxxxx"
    $tenantName = "xxxxxx.onmicrosoft.com"
    $clientSecret = "xxxxxxxxxxxx"
    $resource = "https://graph.microsoft.com/"

    $ReqTokenBody = @{
        Grant_Type    = "client_credentials"
        Scope         = "https://graph.microsoft.com/.default"
        client_Id     = $clientID
        Client_Secret = $clientSecret
    } 
    $global:TokenResponse = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$TenantName/oauth2/v2.0/token" -Method POST -Body $ReqTokenBody
    return $global:TokenResponse    
}

GetMSGraphToken

function LogMessage {
    param([string]$Message)
    
    ((Get-Date).ToString() + " - " + $Message) >> $LogFile;
}


function uploadFileSPO {
    param ($fileInBytes, $filename, $remotePath)
    $headers = @{
        "Content-type"  = "application/json;charset=utf-8"
        "Authorization" = "Bearer $($global:TokenResponse.access_token)"
    }
    
    $url = "$($remotepath)$($filename):/content"
    #put files on SPO
    $response = Invoke-RestMethod -Method 'Put' -Uri $url -Body $fileInBytes -Headers $headers
    
    if (!$response.webUrl){
        write-host "Problem uploading.." -ForegroundColor Red
        LogMessage -Message " $($remotePath) "
        LogMessage -Message " $($path) "
        LogMessage -Message "  $($filename) "
    }else {
        Write-host "Upload completed!" -ForegroundColor Green
        Write-host $response.webUrl -ForegroundColor Green
    }
}

function GetFile {
    param($fullPath)
    #obtain file datainfo
    $fileInBytes = [System.IO.File]::ReadAllBytes($fullPath)
    $fileLength = $fileInBytes.Length

    #write-host $fileInBytes
    return $fileInBytes
}

$driveID = "xxxx"
$fullPath = "xxxx"
$remotePath = "https://graph.microsoft.com/v1.0/drives/$driveID/root:/AND/"
$fileInBytes = GetFile -fullPath $fullPath
$filename = Get-ChildItem -Path $fullPath -Name

uploadFileSPO -fileInBytes $fileInBytes -filename $item -remotePath $remotePathSPO
