function Get-UserData {
    param ($userId)
    $api = "https://graph.microsoft.com/beta/users/$userId"
    $apiFulter = "?$select=displayName,mobilePhone,userPrincipalName,extension_353df732295346438b73c198768a0cd5_pager,department,jobTitle" #test
    $apiUrl = $api + $apiFulter
    Write-Host $apiUrl
    $Data = Invoke-RestMethod -Headers @{Authorization = "Bearer $($Tokenresponse.access_token)"} -Uri $apiUrl -Method Get
    $Users = ($Data | Select-Object Value).Value 
    $ContactInfo = [System.Collections.Generic.List[Object]]::new()
    
    foreach ($user in $Users) {
        $pager = $user.extension_xxxx_pager
        $ipPhone = $user.extension_xxxx_ipPhone
        $homePhone = $user.extension_xxxx_homePhone
        $mobilePhone = $user.mobilePhone
        $userPrincipalName = $user.userPrincipalName
        $displayName = $user.displayName
        $department = $user.department 
        $jobTitle = $user.jobTitle

        Write-Host $displayName -ForegroundColor Yellow 
        Write-Host $userPrincipalName   -BackgroundColor Blue
        Write-Host "mobile: " $mobilePhone -BackgroundColor Blue
        Write-Host "Pager: " $pager -BackgroundColor Blue
        Write-Host "IPPhone: " $ipPhone -BackgroundColor Blue
        Write-Host "HomePhone: " $homePhone -BackgroundColor Blue
        Write-Host "department: " $department -BackgroundColor Blue
        Write-Host "jobTitle: " $jobTitle -BackgroundColor Blue

        $UserData = [PSCustomObject]@{
            pager    = $pager
            ipPhone    = $ipPhone
            homePhone    = $homePhone
            mobilePhone    = $mobilePhone
            displayName    = $displayName
            userPrincipalName    = $userPrincipalName
            department    = $department
            jobTitle    = $jobTitle

        }      
        $ContactInfo.Add($UserData)
    }
    return $ContactInfo
}

Get-UserData -userId "user@domain.com"
