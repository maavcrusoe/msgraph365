#if we need to retreive more than 1k results from MS graph
function pagination {
    param($userId)
    $apiUrl = "https://graph.microsoft.com/v1.0/users/$userId/contacts?`$top=1000" #test
    $Data = Invoke-RestMethod -Headers @{Authorization = "Bearer $($global:TokenResponse.access_token)"} -Uri $apiUrl -Method Get
    #$Contacts = ($Data | Select-Object Value).Value 
    
    $Results = @()
    $Results += $Data.value

    $Pages = $Data.'@odata.nextLink'
    while($null -ne $Pages) {

    Write-Warning "Checking Next page"
    $Addtional = Invoke-RestMethod -Headers @{Authorization = "Bearer $($global:TokenResponse.access_token)" } -Uri $Pages -Method Get

    if ($Pages){
        $Pages = $Addtional."@odata.nextLink"
    }
    
    $Results += $Addtional.value
    }
    
    write-host "Total results: $($Results.count)"
    $Results | Out-GridView
    return $Results
}
