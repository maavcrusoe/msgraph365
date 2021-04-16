function DeleteContactsByCategory {
    param ($userId, $category )
    $apiUrl = "https://graph.microsoft.com/v1.0/users/$userId/contacts?`$top=1000"
    $Data = Invoke-RestMethod -Headers @{Authorization = "Bearer $($Tokenresponse.access_token)"} -Uri $apiUrl -Method "GET"
    $Contacts = ($Data | Select-Object Value).Value 

    foreach ($contact in $Contacts) {
        $idContact = $contact.id
        $displayName = $contact.displayName
        $cat = $contact.categories
        Write-Host $displayName -ForegroundColor Yellow
        if ($cat -eq $category ) {
            write-host "Contact found: " $displayName -ForegroundColor Green
            Write-Host "Delete Contact" -ForegroundColor Red
            $apiUrl = "https://graph.microsoft.com/beta/users/$userId/contacts/$idContact"
            Invoke-RestMethod -Headers @{Authorization = "Bearer $($Tokenresponse.access_token)"} -Uri $apiUrl -Method "DELETE"
        }elseif (!$idContact) {
            write-host "Contact id not match" -ForegroundColor Red
        }else{
            Write-host "No contacts found"
        }

    }
}
#DeleteContactsByCategory -userId "user@domain.com" -category "business"
