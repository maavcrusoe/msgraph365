function DeleteContactsByID {
    param ($userId, $contactId )
    $apiUrl = "https://graph.microsoft.com/beta/users/$userId/contacts/"
    $Data = Invoke-RestMethod -Headers @{Authorization = "Bearer $($Tokenresponse.access_token)"} -Uri $apiUrl -Method "GET"
    $Contacts = ($Data | Select-Object Value).Value 
    
    foreach ($contact in $Contacts) {
        $idContact = $contact.id
        $displayName = $contact.displayName

        if ($contactId -eq $idContact ) {
            write-host "Contact found: " $displayName -ForegroundColor Green
            Write-Host "Delete Contact" -ForegroundColor Red
            $apiUrl = "https://graph.microsoft.com/beta/users/$userId/contacts/$contactId"
            Invoke-RestMethod -Headers @{Authorization = "Bearer $($Tokenresponse.access_token)"} -Uri $apiUrl -Method "DELETE"
        }elseif (!$idContact) {
            write-host "Contact id not match" -ForegroundColor Red
        }else{
            write-host "Contact not found"
        }
    }
}

DeleteContactsByID -userId "user1@domain.com" -contactId "xxxx"
