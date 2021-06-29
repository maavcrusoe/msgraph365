#inserta en la lista de SPO los valores que le pasemos
function AddItemSPO {
  param ($site, $list, $idgroup, $value)
  
  $url = "https://graph.microsoft.com/v1.0/sites/$site/lists/$list/items"
  $newItem = "{ 'fields': {'Title': '"+$idgroup+"' ,'value': '"+$value+"'}}" 
  write-host $newItem -f 'g'
  
  Invoke-RestMethod -Headers @{Authorization = "Bearer $($Tokenresponse.access_token)"} -Uri $url -Method "POST" -Body $newItem -ContentType "application/json;charset=utf-8"
}
