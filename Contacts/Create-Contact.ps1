function CreateContact {
    param ($userId,$displayName,$userPrincipalName,$mobilePhone,$homePhone,$ipPhone,$pager,$department,$jobTitle,$category,$companyName)

    Write-Host "Create Contact" -ForegroundColor Green
    $newcontact = "{'givenName': '"+$displayName+"' ,'emailAddresses': [{'address':  '"+$userPrincipalName+"','name': '"+$displayName+"'}], 'homePhones': ['"+$ipPhone+"','"+$homePhone+"'],'department': '"+$department+"','jobTitle': '"+$jobTitle+"', 'mobilePhone': '"+$mobilePhone+"','businessPhones': ['"+$pager+"'],'categories': ['"+$category+"'],'companyName': '"+$companyName+"'}" #,'otherAddress': {'street': '','city': '39.62540063774273','state': '2.7165319720767873','countryOrRegion': '','postalCode': ''}
    
    #write-host $newcontact
    $apiUrl = "https://graph.microsoft.com/v1.0/users/$userId/contacts"
    Invoke-RestMethod -Headers @{Authorization = "Bearer $($Tokenresponse.access_token)"} -Uri $apiUrl -Method "POST" -Body $newcontact -ContentType "application/json;charset=utf-8"
    Write-Host "Contact created" -ForegroundColor Green
}
