#import all funcions from others ps1
. $PSScriptRoot\msgraph.ps1
Import-Module $PSScriptRoot\msgraph.ps1 -Force             #MS graph


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
        Write-Host "=================== Start ==================="
        Write-Host "Iniciando..."
        Write-Host $PSScriptRoot

        write-host ($start)
        Write-Host "================ CREAR ================"
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
        Write-Host "-----------------"
        Write-Host "E. Export AllUsers to vcf"
        Write-Host "-----------------"
        Write-Host "D. debug"  -ForegroundColor Cyan
        Write-Host "S. sesions"
        Write-Host "Q. Exit"  -ForegroundColor Red
        $menuresponse = read-host [Enter Selection]
        Switch ($menuresponse) {
            "0" {CreateAllContactsManual}
            "1" {CreateAllContactsByUser}
            "2" {QueryFunction -selection "2"}
            "3" { UpdateAllContacts 
                return }
            "4" {QueryFunction -selection "3"}
            "5" {QueryFunction -selection "4"}
            "6" {QueryFunction -selection "5"}
            "7" {GetOrgContacts
                pause }
            "8" {QueryFunction -selection "7"}
            "9" {QueryFunction -selection "8"}
            
            "E" {Add-vcfCard-AllUsers}
            
            "D" {debugMode}
            "O" {ConnectOnPremise}
            "close" {CloseSesions}
            'Q' {
                    #CloseSesions
                    #Disconnect-O365
                    return
                }
       }
       #pause
    }
    until ($menuresponse -eq 'q') 
}


function QueryFunction {
    param ($selection)
    $prompt = Read-Host -Prompt "Please enter username to take action"
    $domain = "@domain.com"
    $userId = $prompt + $domain

    Write-Host $userId -fore blue

    do { 
        switch ($selection) {
            "2" { UpdateContactsByUPN -userId $userId 
                pause
                return }
            "3" { DeleteContactsByCategory -userId $userId -category "empresa" 
                return }
            "4" { 
                $contactId = Read-Host -Prompt "Now please give me a ContactId:"
                DeleteContactsByID -userId $userId -contactId $contactId
                return }
            "5" { Get-ContactsByUPN -userId $userId 
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
