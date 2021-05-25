function Get-ContactsByUPN {
    param ($userId)
    $apiUrl = "https://graph.microsoft.com/v1.0/users/$userId/contacts" #test
    $Data = Invoke-RestMethod -Headers @{Authorization = "Bearer $($Tokenresponse.access_token)"} -Uri $apiUrl -Method Get
    $Contacts = ($Data | Select-Object Value).Value 
    #$Contacts | Out-GridView
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

        write-host "id:" $idContact -BackgroundColor Blue
        write-host "userPrincipalName:" $userPrincipalName -BackgroundColor Blue
        write-host "emailAddresses:" $emailAddresses -BackgroundColor Blue
        write-host "Name:" $displayName 
        write-host "Mobile:" $mobilePhone  #largo tlf xxx xx xx xx
        write-host "ext movil:" $businessPhones  #extension movil xxx
        write-host "ext:" $homePhones        #extension fija xxxx
        write-host "categories:" $categories

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
                emailAddresses    = $emailAddresses
            }      
            $Report.Add($ListContact)     
        }
    }
    if (!$Report) {
        write-host "Any contacts found on this user"
    }
    $Report | Out-GridView
    return $Report
}
