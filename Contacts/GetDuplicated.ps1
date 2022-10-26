function GetDuplicated {
    param ($userId)
    $localContacts = $null
    $localContacts2 = $null
    $t = $null
    $localContacts = Get-ContactsByUPN -userId $userId -showgrid $false
    $localContacts = $localContacts[1..$localContacts.count]

    $localContacts=$localContacts | Select-Object -Property * 

    $localContacts2 = $localContacts.PsObject.Copy()
    $localContacts2 = $localContacts2 | Sort-Object -Property @{Expression={$_.emailAddresses}} -Unique
    
    #$localContacts | Out-GridView
    #$localContacts2 | Out-GridView

    $a = Compare-object $localContacts $localContacts2 -Property contactid,emailAddresses,categories -IncludeEqual #| Out-GridView 
    $a | ForEach-Object {
        if ($_.SideIndicator -eq "<=" -and $_.categories -eq "empresa" -and $_.emailAddresses -ne ""){
            $t += 1 
        }
    }
    
    if($t -ne $null){write-host "Found $($t) duplicated"}

    $a | ForEach-Object {
        if ($_.SideIndicator -eq "<=" -and $_.categories -eq "empresa" -and $_.emailAddresses -ne "") {
            write-host "Going to delete:  $($_.contactid)" -ForegroundColor Yellow
            write-host " $($_.emailAddresses) | $($_.SideIndicator) $($_.categories)" -ForegroundColor Yellow
            DeleteContactsByID -userId $userId -contactId $_.contactid
        }
    }
}
