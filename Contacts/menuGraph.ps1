#import all funcions from others ps1
. $PSScriptRoot\msgraph.ps1
Import-Module $PSScriptRoot\msgraph.ps1 -Force             #MS graph

$global:StartMS = (Get-Date)
$global:EndMS = (Get-Date)
$global:timeExecution = 00:00:00.0;

function debugMode {
    $prompt = Read-Host -Prompt "Introduce el comando deseado"
    Write-Host "Command to execute: " $prompt -ForegroundColor yellow
    $v = Invoke-Expression $prompt
    Write-Output $v
    #& $prompt
    pause
}

function StartMenu {
    $start = Get-Date
    $PSScriptRoot #get root folder 
    do { 
        Clear-Host
        Write-host "

        _____  __  ____  
       |___ / / /_| ___| 
          |_ \| '_ \___ \ 
         ___) | (_) |__) |
        |____/ \___/____/ 
                                                   
       "
        Write-Host "=================== Start ==================="
        Write-Host "Iniciando..."
        write-host ($start)
        #write-host $StartMS -ForegroundColor blue
        #write-host $timeExecution
        $timeExecution = timeExecution
        #write-host "Token: " $TokenResponse.access_token
        $TimeDif = $global:TokenResponse.expires_in - $timeExecution.TotalSeconds
        write-host "Expires in: " $TimeDif "seconds"
        #Write-Host $PSScriptRoot
        #write-host $global:TokenResponse
        
        Write-Host "================ CREATE ================"
        Write-Host "0. Create All Contacts [1st time]"  -fore Green
        Write-Host "1. Create All Contacts to new user (type UPN miquel.aloy)"  -fore Green
        Write-Host "================ UPDATE ================" 
        Write-Host "2. Update All Contacts by User" 
        Write-Host "3. Update All Contacts All Users" 
        Write-Host "================ DELETE ================" 
        Write-Host "4. Delete All Contacts by User" -fore red
        Write-Host "5. Delete Contacts by User and contactId" -fore red 
        Write-Host "================ INFO ================" 
        Write-Host "6. Get Contacts by User"
        Write-Host "7. Get OrgContacts" 
        Write-Host "8. Get User Contact data"
        Write-Host "9. Get Contacts Folder by User"
        Write-Host ""
        Write-Host "================ EXPORT ================"
        Write-Host "E. Export AllUsers to vcf"
        Write-Host "Ex. Export Contacts to vcf by UPN"
        Write-Host ""
        Write-Host "----------------------------------"
        Write-Host "All. Obtain all users to import"
        Write-Host "D. debug"  -ForegroundColor Cyan
        Write-Host "S. sesions"
        Write-Host "T. Current token"
        Write-Host "Q. Exit"  -ForegroundColor Red
        $menuresponse = read-host [Enter Selection]
        Switch ($menuresponse) {
            "0" {CreateAllContactsManual}
            "1" { 
                $userId = Read-Host -Prompt "Please enter name of user to update contacts!"
                write-host  "-userId" $userId 
                CreateAllContactsByUser -userId $userId
            }
            "2" {QueryFunction -selection "2"}
            "3" { UpdateAllContacts 
                pause }
            "4" {QueryFunction -selection "3"}
            "5" {QueryFunction -selection "4"}
            "6" {QueryFunction -selection "5"}
            "7" {GetOrgContacts
                pause }
            "8" {QueryFunction -selection "7"}
            "9" {QueryFunction -selection "8"}
            
            "E" {Add-vcfCard-AllUsers}
            "ex" {
                $contactId = Read-Host -Prompt "Now please give me a ContactId:"
                ExportContactsByUPN -userid $contactId
                pause}
            #Other commands
            "D" {debugMode}
            "All" {Get-AllUsers2
                    pause
                }
            "T" { $TokenResponse = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$TenantName/oauth2/v2.0/token" -Method POST -Body $ReqTokenBody
                    write-host $TokenResponse
                    pause
                }
            "close" {CloseSesions}
            'Q' {
                    #CloseSesions
                    Exit
                }
       }
       #pause
    }
    until ($menuresponse -eq 'q') 
}


function QueryFunction {
    param ($selection)
    $prompt = Read-Host -Prompt "Please enter username to take action"
    #$domain = "@tunel.com"
    $userId = $prompt

    Write-Host $userId -fore blue

    do { 
        switch ($selection) {
            "2" {UpdateContactsByUPN -userId $userId 
                pause
                return }
            "3" { DeleteContactsByCategory -userId $userId -category "empresa" 
                pause
                return }
            "4" { 
                $contactId = Read-Host -Prompt "Now please give me a ContactId:"
                DeleteContactsByID -userId $userId -contactId $contactId
                pause
                return }
            "5" {$a= Get-ContactsByUPN -userId $userId -showgrid $true
                $a | Out-GridView
                pause
                return }
            "7" { GetUserData -userId $userId 
                pause
                return }
            "8" { Get-ContactsFolderByUPN -userId $userId 
                return }
            'Q' {
                #CloseSesions
                #Disconnect-O365
                return
            }

        }
    }
    until ($selection -eq 'q') 
    
}



StartMenu
