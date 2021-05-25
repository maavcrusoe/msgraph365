function CreateAllContactsCustom {
    $listUsers = @("user1@domain.com","user2@domain.com")
    #call all users and store to var1
    $var1 = Get-AllUsers 

    foreach ($listUser in $listUsers) {
        write-host "Creating contacts to: "$listUser -ForegroundColor Yellow
        Start-sleep 5

        foreach ($item in $var1.userPrincipalName) {
            #Get user info like tlf number (xxx, xxxx, xxx xx xx xx), department...
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
    
            CreateContact -userId $listUser -displayName $displayName -userPrincipalName $userPrincipalName -mobilePhone $pager -homePhone $homePhone -ipPhone $ipPhone -pager $mobilePhone -department $department -jobTitle $jobTitle -category $category -companyName $companyName        
        }
    
        #If you have OrgContacts
        #Get user info like tlf number (xxx, xxxx, xxx xx xx xx), department...
        $Data = GetOrgContacts

        foreach ($item in $Data) {
            #Store data on var
            write-host "Add OrgContact: " $item.displayName -ForegroundColor green
            $pager    = $item.pager
            $mobile    = $item.mobile
            $mail    = $item.mail
            $companyName    = $item.companyName
            $displayName    = $item.displayName
            $department    = $item.department
            
            #write-host "add contacts to $listUser" -displayName $displayName -userPrincipalName $mail -mobilePhone $mobile -homePhone $homePhone -ipPhone $ipPhone -pager $pager -department $department -jobTitle $companyName        
            CreateContact -userId $listUser -displayName $displayName -userPrincipalName $mail -mobilePhone $mobile -homePhone $homePhone -ipPhone $ipPhone -pager $pager -department $department -jobTitle $companyName               
        }
    }   

}
CreateAllContactsCustom
