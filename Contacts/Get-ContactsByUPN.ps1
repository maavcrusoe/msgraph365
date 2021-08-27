$OnlyUserADlist =  @(
    "user1@domain.com",
    "user2@domain.com"
    )


function Get-ContactsByUPN {
    param ($userId,$showgrid)
    #check execution time because MS Graph Token only lasts 1 hour
    timeExecution
    $apiUrl = "https://graph.microsoft.com/v1.0/users/$userId/contacts?`$top=1000" #test
    
    $Data = Invoke-RestMethod -Headers @{Authorization = "Bearer $($global:TokenResponse.access_token)"} -Uri $apiUrl -Method Get
    $Contacts = ($Data | Select-Object Value).Value 
    write-host "Total local contacts: "$Contacts.Count -ForegroundColor Yellow
    
    #debug if your need
    #$Contacts | Out-GridView
    #$Data | Out-GridView
    
    #array of users to ignore
    if ($OnlyUserADlist -contains $userId) {
        #Write-Host "user in ignore list"
    }else {
        if ($Contacts.Count -eq 0) {
            LogMessage -Message "NEW USER DETECTED CREATING CONTACTS:  $userId "
            CreateAllContactsByUser -userId $userId
        }
        
        $Report = [System.Collections.Generic.List[Object]]::new()
        foreach ($contact in $Contacts) {
            $idContact = $contact.id
            $displayName =  $contact.displayName
            $mobilePhone =  $contact.mobilePhone
            $businessPhones =  $contact.businessPhones
            $homePhones =  $contact.homePhones
            $categories =  $contact.categories
            $userPrincipalName = $contact.userPrincipalName
            $emailAddresses = $contact.emailAddresses[0].address
            
            foreach ($User in $contact) {
                $contactid = $User.id
                $userdisplayName = $User.displayName
                $userPrincipalName = $User.userPrincipalName
                $businessPhones = $User.businessPhones
                $mobilePhone = $User.mobilePhone
                $homePhones = $User.homePhones
                $categories = $User.categories
                $emailAddresses = $User.emailAddresses
                
                #write-host $usersdisplayName,$usersmobile -ForegroundColor green
                $ListContact = [PSCustomObject]@{
                    contactid    = $contactid
                    userdisplayName    = $userdisplayName
                    userPrincipalName    = $userPrincipalName
                    businessPhones    = $businessPhones
                    mobilePhone    = $mobilePhone
                    homePhones    = $homePhones
                    categories    = $categories
                    emailAddresses    = $emailAddresses[0].address
                }      
                $Report.Add($ListContact)     
            }
        }
    }
    if (!$Report) {
        write-host "Any contacts found on this user"
    }

    if ($showgrid -eq $true) {
        $Report | Out-GridView   
    }

    return $Report
    
}
