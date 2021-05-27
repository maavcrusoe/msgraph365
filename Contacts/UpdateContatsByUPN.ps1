function UpdateContactsByUPN {
    param ($userId)
    #call all users and store to var1
    $LocalContacts = Get-ContactsByUPN -userId $userId

    #update local contacts
    foreach ($u in $LocalContacts) {
        write-host $u.userdisplayName -fore blue

        #Write-Output $Data
        if ($u.categories -eq "empresa") {
            
            $Data = GetUserData -userId $u.emailAddresses

            if ($u.emailAddresses -NotIn $Data.userPrincipalName) {
                write-host "Usuario no encontrado" -fore red
                write-host "delete local contact" $u.emailAddresses $u.contactid "to user " $userId
                DeleteContactsByID -userId $userId -contactId $u.contactid
            
            }else {
                if ($Data.mobilePhone -eq $u.businessPhones) {
                    write-host "Concato local OK" $u.businessPhones -fore green
                    
                }else {
                    write-host "Concato local " $u.businessPhones -fore red
                    write-host "Update local contact" $u.businessPhones " to " $Data.mobilePhone -fore darkyellow
                    UpdateContact -userId $userId -contactId $u.contactid -mobilePhone $Data.pager -businessPhone $Data.mobilePhone
                }
            }
        }else {
            write-host "no es empresa"
        }
    
    }
    #add new contacts
    CreateNewContacts -userId $userId -LocalContacts $LocalContacts 
}
