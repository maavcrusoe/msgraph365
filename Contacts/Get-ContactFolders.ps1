function Get-ContactsFolderByUPN {
    param ($userId)
    
    $apiUrl = "https://graph.microsoft.com/v1.0/users/$userId/contactFolders" #test
    $Data = Invoke-RestMethod -Headers @{Authorization = "Bearer $($Tokenresponse.access_token)"} -Uri $apiUrl -Method Get
    $Contact = ($Data | Select-Object Value).Value 
    
    write-host $Contact.displayName
    $Contact | Out-GridView
}
