function Create-ContactsAllUsers {
    $users = @("user1@domain.com","user2@domain.com") 

    foreach ($user in $users) {
        #Get data from user selected
        $Data = GetUserData -userId $user  
        
        #Save all data from user
        #Check your extension id on https://graph.microsoft.com/beta/users
        $pager = $Data.extension_xxxx_pager
        $ipPhone = $Data.extension_xxxx_ipPhone
        $homePhone = $Data.extension_xxxx_homePhone
        $mobilePhone = $Data.mobilePhone
        $userPrincipalName = $Data.userPrincipalName
        $displayName = $Data.displayName
        $department = $Data.department
        $jobTitle = $Data.jobTitle
        
        #Create contacts to current user
        CreateContact -userId $userPrincipalName -displayName $displayName -userPrincipalName $userPrincipalName -mobilePhone $mobilePhone -homePhone $homePhone -ipPhone $ipPhone -pager $pager -department $department -jobTitle $jobTitle    
    }
}
#Execute function
#Create-ContactsAllUsers
