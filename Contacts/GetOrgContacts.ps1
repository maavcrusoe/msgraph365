function GetOrgContacts {
    $apiUrl = "https://graph.microsoft.com/v1.0/contacts"
    $Data = Invoke-RestMethod -Headers @{Authorization = "Bearer $($Tokenresponse.access_token)"} -Uri $apiUrl -Method Get
    $Users = ($Data | Select-Object Value).Value 
    $ContactInfo = [System.Collections.Generic.List[Object]]::new()

    foreach ($user in $Users) {
        #obtain data 
        $mobile = $User.phones[1].number
        $pager = $User.phones[2].number
        $mail = $User.mail
        $department = $User.department
        $companyName = $User.companyName
        $displayName = $User.displayName

        Write-Host $displayName -ForegroundColor Yellow 
        Write-Host $mail   -BackgroundColor Blue
        Write-Host "mobile: " $mobile -BackgroundColor Blue
        Write-Host "ext: " $pager -BackgroundColor Blue
        Write-Host "department: " $department -BackgroundColor Blue
        Write-Host "companyName: " $companyName -BackgroundColor Blue

        $OrgUserData = [PSCustomObject]@{
            pager    = $pager
            mobile    = $mobile
            mail    = $mail
            companyName    = $companyName
            displayName    = $displayName
            department    = $department

        }      
        $ContactInfo.Add($OrgUserData) 
    }
    return $ContactInfo
}
