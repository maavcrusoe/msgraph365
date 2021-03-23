function Get-ContactsByUPN {
    param ($userId)
    
    $apiUrl = "https://graph.microsoft.com/v1.0/users/$userId/contacts" #test
    $Data = Invoke-RestMethod -Headers @{Authorization = "Bearer $($Tokenresponse.access_token)"} -Uri $apiUrl -Method Get
    $Contacts = ($Data | Select-Object Value).Value 
    #$Contacts | Out-GridView

    foreach ($contact in $Contacts) {
        $idContact = $contact.id
        $displayName =  $contact.displayName
        $mobilePhone =  $contact.mobilePhone
        $businessPhones =  $contact.businessPhones
        $homePhones =  $contact.homePhones

        #write-host "id:" $idContact
        #write-host "Name:" $displayName
        #write-host "Mobile:" $mobilePhone         #largo tlf xxx xx xx xx
        #write-host "ext movil:" $businessPhones   #extension movil xxx
        #write-host "ext:" $homePhones             #extension fija xxxx
    }
    return $Contacts  
}
