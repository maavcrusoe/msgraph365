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

        write-host "id:" $idContact -BackgroundColor Blue
        write-host "Name:" $displayName -BackgroundColor Blue
        write-host "Mobile:" $mobilePhone -BackgroundColor Blue   #largo tlf xxx xx xx xx
        write-host "ext movil:" $businessPhones -BackgroundColor Blue  #extension movil xxx
        write-host "ext:" $homePhones -BackgroundColor Blue       #extension fija xxxx

        foreach ($User in $contact) {
            $contactid = $User.id
            $userdisplayName = $User.displayName
            $userPrincipalName = $User.userPrincipalName
            
            #write-host $usersdisplayName,$usersmobile -ForegroundColor green
            $ListContact = [PSCustomObject]@{
                contactid    = $contactid
                userdisplayName    = $userdisplayName
                userPrincipalName    = $userPrincipalName
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
