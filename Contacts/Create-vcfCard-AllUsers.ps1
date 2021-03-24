#This function can obtain data from all users and export to one vcfCard
function Add-vcfCard-AllUsers {
    #call all users
    $var1 = Get-AllUsers 
    #write-host $var1.userPrincipalName  
    
    foreach ($item in $var1.userPrincipalName) {
        #Get user info like tlf number (xxx, xxxx, xxx xx xx xx), department...
        $user = GetUserData -userId $item
        #Export all data to one vCard
        $u = $user.userPrincipalName | Out-vCard 
    }
    
}
#Add-vcfCard-AllUsers
