Import-Csv .\import\disableOWAlist.csv | ForEach-Object {
    Write-Host "User: $($_.Identity),  $($_.lang) - Disabled" -ForegroundColor red
    Set-CasMailbox -Identity $_.Identity -OWAEnabled $false
}