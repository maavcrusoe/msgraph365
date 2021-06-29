#insert into a SharePoint List
#be carefull if you have a SPList in a Group check $url
function AddItemSPO {
  param ($site, $list, $name, $value)
  
  $url = "https://graph.microsoft.com/v1.0/sites/$site/lists/$list/items"
  $newItem = "{ 'fields': {'Title': '"+$name+"' ,'value': '"+$value+"'}}" 
  write-host $newItem -f 'g'
  
  Invoke-RestMethod -Headers @{Authorization = "Bearer $($Tokenresponse.access_token)"} -Uri $url -Method "POST" -Body $newItem -ContentType "application/json;charset=utf-8"
}
