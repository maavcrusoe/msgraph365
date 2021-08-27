#Export all local contacts by UPN in one vCard

#Search local contacts by UPN
function ExportContactsByUPN {
    param ($userId)
    Write-host "Exporting all contacts from " $userId 
    $users = Get-ContactsByUPN -userid $userId -showgrid $false 
    #Loop of local contacts
    foreach ($user in $users) {
        #search emailAddress and send to export function
        $user.emailAddresses | Out-vCardLocalContacts
    }   
}

function Out-vCardLocalContacts {
    $input | ForEach-Object {
    write-host $input
    #$vCardPath = "c:\tmp\vcard\" + $input + ".vcf"     #guarda un vcard por cada usuario
    $vCardPath = "c:\tmp\vcard\Contacts.vcf"    #guarda un solo vcard

    #Remove-Item $vCardPath -ErrorAction SilentlyContinue
    Add-Content -Path $vCardPath -Value "BEGIN:VCARD"
    Add-Content -Path $vCardPath -Value "VERSION:3.0"
    Add-Content -Path $vCardPath -Value "N;LANGUAGE=es;CHARSET=Windows-1252:$($user.userdisplayName)"
    Add-Content -Path $vCardPath -Value "CATEGORIES;LANGUAGE=es;CHARSET=Windows-1252:$($user.department)"
    Add-Content -Path $vCardPath -Value "TITLE;LANGUAGE=es;CHARSET=Windows-1252:$($user.jobTitle)"
    Add-Content -Path $vCardPath -Value "ORG;LANGUAGE=es;CHARSET=Windows-1252:$($user.companyName)"
    Add-Content -Path $vCardPath -Value "TEL;WORK:$($user.mobilePhone)"
    Add-Content -Path $vCardPath -Value "TEL;HOME:$($user.homePhones)"
    Add-Content -Path $vCardPath -Value "TEL;CELL:$($user.businessPhones)"
    Add-Content -Path $vCardPath -Value "ADR;WORK;PREF:$($user.streetAddress)"
    Add-Content -Path $vCardPath -Value "EMAIL;PREF;INTERNET:$($user.emailAddresses)"
    Add-Content -Path $vCardPath -Value "END:VCARD"
    }
}
