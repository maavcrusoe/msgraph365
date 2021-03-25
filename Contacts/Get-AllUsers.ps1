function Get-AllUsers {
    #Get all users
    $apiUrl = "https://graph.microsoft.com/beta/users?`$select=id,userPrincipalName,displayName,mobilePhone&`$top=900"#&`$filter=mobilePhone%20ne%20null&`$count=true"   #$character = "%2B34" 
    
    $Data = Invoke-RestMethod -UseBasicParsing -Headers $headers -Uri $query -Method Get
    $Users = ($Data | Select-Object Value).Value  
    #$users  | Out-GridView
    $var = 1
    $Report = [System.Collections.Generic.List[Object]]::new()
    foreach ($User in $Users) {
        $usersmobile = $User.mobilePhone
        $usersdisplayName = $User.displayName
        $userPrincipalName = $User.userPrincipalName
        
        if (!$usersmobile) {
            #Write-Host $usersmobile,$usersdisplayName
        }else {
            #write-host $usersdisplayName,$usersmobile -ForegroundColor green
            $var +=1  
            $ListUsers = [PSCustomObject]@{
                usersdisplayName    = $usersdisplayName
                usersmobile    = $usersmobile
                userPrincipalName    = $userPrincipalName
            }      
            $Report.Add($ListUsers) 
        }
        
    }
    write-host $var -for yellow
    #$Report | Out-GridView
    return $Report 
}
