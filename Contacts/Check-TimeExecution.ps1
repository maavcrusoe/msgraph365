function timeExecution {

    $global:EndMS = (Get-Date)
    $global:timeExecution = $global:EndMS - $global:StartMS 
    #Write-Host "execution time: " $global:timeExecution   -fore Blue

    if ($global:timeExecution -gt "00:60:00.00") {
        write-host "Create new token" -BackgroundColor  DarkCyan
        write-host "old token" $global:TokenResponse -for red
        $newTokenResponse = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$TenantName/oauth2/v2.0/token" -Method POST -Body $ReqTokenBody
        
        $global:StartMS  = (Get-Date)
        $global:EndMS = (Get-Date)
        $global:timeExecution = $global:EndMS - $global:StartMS #"00:00:00.00"
        
        write-host "new token" $newTokenResponse  -for green
        $global:TokenResponse = $newTokenResponse
        write-host $global:TokenResponse -ForegroundColor blue
        
    }else {
        #Write-Host "tiempo de ejecucion: " $global:timeExecution   -fore Blue
        return $global:timeExecution
    }
    
    
}
