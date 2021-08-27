function DeleteContactsByID {
    param ($userId, $contactId )
    $apiUrl = "https://graph.microsoft.com/beta/users/$userId/contacts?`$top=10000" #&skip=1000
    $Data = Invoke-RestMethod -Headers @{Authorization = "Bearer $($global:TokenResponse.access_token)"} -Uri $apiUrl -Method "GET"
    $Contacts = ($Data | Select-Object Value).Value 

    foreach ($contact in $Contacts) {
        $idContact = $contact.id
        $displayName = $contact.displayName
        
        if ($contactId -ceq $idContact ) {
            write-host "Contact found: " $displayName -ForegroundColor Green
            Write-Host "Delete Contact" -ForegroundColor Red
            LogMessage -Message "Contact deleted: " $displayName
            $apiUrl = "https://graph.microsoft.com/beta/users/$userId/contacts/$contactId"
            Invoke-RestMethod -Headers @{Authorization = "Bearer $($global:TokenResponse.access_token)"} -Uri $apiUrl -Method "DELETE"
        }elseif (!$idContact) {
            write-host "Contact id not match" -ForegroundColor Red
        }else{
            #Write-host "No contacts found"
        }

    }

}

DeleteContactsByID -userId "user1@domain.com" -contactId "xxxx"
