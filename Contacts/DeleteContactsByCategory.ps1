function DeleteContactsByCategory {
    param ($userId, $category )
    $apiUrl = "https://graph.microsoft.com/v1.0/users/$userId/contacts?`$top=1000"
    $Data = Invoke-RestMethod -Headers @{Authorization = "Bearer $($global:TokenResponse.access_token)"} -Uri $apiUrl -Method "GET"
    $Contacts = ($Data | Select-Object Value).Value 
    Write-Host "Deleteing contacts to: "$userId -ForegroundColor Yellow
    LogMessage -Message "Deleteing contacts to: " $userId
   
   foreach ($contact in $Contacts) {
        $idContact = $contact.id
        $displayName = $contact.displayName
        $cat = $contact.categories
        
        if ($cat -ceq $category ) {
            #write-host "Contact found: " $displayName -ForegroundColor Green
            Write-Host "Delete Contact $displayName" -ForegroundColor Red
            LogMessage -Message "Delete Contact: " $displayName
            $apiUrl = "https://graph.microsoft.com/beta/users/$userId/contacts/$idContact"
            Invoke-RestMethod -Headers @{Authorization = "Bearer $($global:TokenResponse.access_token)"} -Uri $apiUrl -Method "DELETE"
            
        }elseif (!$idContact) {
            write-host "Contact id not match" -ForegroundColor Red
        }else{
            Write-host "No match category"
        }
    }
}

#DeleteContactsByCategory -userId "user@domain.com" -category "business"
