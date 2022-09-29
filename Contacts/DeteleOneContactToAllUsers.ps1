function DeteleOneContactToAllUsers {
    param($filter)
    Write-host "deleting one contact to all users"
    $var1 = Get-AllUsers 
    $category = "empresa"
    
    foreach ($item in $var1.userPrincipalName) {
        write-host $item
        if ($OnlyUserADlist -contains $item) {
            Write-Host "ignore user"
        }else {
            DeleteContactsByFilter -userId $item -filter $filter
        }
    }  
}
