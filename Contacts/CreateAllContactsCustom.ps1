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
    
            CreateContact -userId $listUser -displayName $displayName -userPrincipalName $userPrincipalName -mobilePhone $mobilePhone -homePhone $homePhone -ipPhone $ipPhone -pager $pager -department $department -jobTitle $jobTitle        
        }

    }   

}
CreateAllContactsCustom
