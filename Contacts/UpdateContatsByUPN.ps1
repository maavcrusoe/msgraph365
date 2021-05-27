function CreateNewContacts {
    param($userId, $LocalContacts)
    #call all users and store to var1
    $var1 = Get-AllUsers 
    $category = "empresa"
    
    foreach ($item in $var1.userPrincipalName) {
        #filter by empresa tag
        if ($LocalContacts.categories -eq "empresa") {
            #if item is in local contacts then ignore
            if ($item -in $LocalContacts.emailAddresses) {
                write-host "Local Contact found" $item
                
            }else {
                #else item isn't in local contacts then get user data and import it
                ##Get user info like tlf number (xxx, xxxx, xxx xx xx xx), department...
                $Data = GetUserData -userId $item
                Write-Host "Add contact name: " $item -ForegroundColor green

                #Store data on var
                $pager = $Data.pager
                $ipPhone = $Data.ipPhone
                $homePhone = $Data.homePhone
                $mobilePhone = $Data.mobilePhone
                $userPrincipalName = $Data.userPrincipalName
                $displayName = $Data.displayName
                $department = $Data.department
                $jobTitle = $Data.jobTitle 
                $companyName = $Data.companyName
                
                #write-host "add contacts to $listUser" -displayName $displayName -userPrincipalName $userPrincipalName -mobilePhone $mobilePhone -homePhone $homePhone -ipPhone $ipPhone -pager $pager -department $department -jobTitle $jobTitle        
                CreateContact -userId $userId -displayName $displayName -userPrincipalName $userPrincipalName -mobilePhone $pager -homePhone $homePhone -ipPhone $ipPhone -pager $mobilePhone -department $department -jobTitle $jobTitle -category $category -companyName $companyName        
                }
        }
    }
}


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
