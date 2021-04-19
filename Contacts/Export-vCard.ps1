#On some devices you need to use this
#Add-Content -Path $vCardPath -Value "TEL;WORK:$($user.mobilePhone)"

function Out-vCard {
    $input | ForEach-Object {
  
    $vCardPath = "c:\tmp\vcard\" + $input + ".vcf"
    Remove-Item $vCardPath -ErrorAction SilentlyContinue
    
    Add-Content -Path $vCardPath -Value "BEGIN:VCARD"
    Add-Content -Path $vCardPath -Value "VERSION:3.0"
    Add-Content -Path $vCardPath -Value "N:$($user.displayName)"    
    #use this if you have Spanish characters like (ñ,á,à)
    #Add-Content -Path $vCardPath -Value "N;LANGUAGE=es;CHARSET=Windows-1252:$($user.displayName)"
    Add-Content -Path $vCardPath -Value "ORG:$($user.department)"
    Add-Content -Path $vCardPath -Value "TITLE:$($user.jobTitle)"
    Add-Content -Path $vCardPath -Value "TEL;WORK;VOICE:$($user.mobilePhone)"
    Add-Content -Path $vCardPath -Value "TEL;HOME;VOICE:$($user.extension_xxx_ipPhone)"
    Add-Content -Path $vCardPath -Value "TEL;CELL;VOICE:$($user.extension_xxx_pager)"
    Add-Content -Path $vCardPath -Value "ADR;WORK;PREF:$($user.streetAddress)"
    Add-Content -Path $vCardPath -Value "EMAIL;PREF;INTERNET:$($user.userPrincipalName)"
    Add-Content -Path $vCardPath -Value "END:VCARD"
    }
}
#list of users
$users = @("user1@domain.com","user2@domain.com","user3@domain.com")

foreach ($item in $users) {
    #Function to obtain user data from MS Graph API
    $user = GetUserData -userId $item
    $u = $user.userPrincipalName | Out-vCard 
}
