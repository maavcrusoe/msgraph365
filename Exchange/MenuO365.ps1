#This Script works with Azure, exchange modules developed few years ago, with this script in one click have PS connected to O365 enviroment easy.
#Useful for execute commands in debug or easy commands, at the moment I'm not developing this.

#. $PSScriptRoot \ include.ps1
#import all funcions from others ps1
. $PSScriptRoot\exchange.ps1
. $PSScriptRoot\SPO.ps1
. $PSScriptRoot\Teams.ps1

Import-Module $PSScriptRoot\exchange.ps1 -Force             #connects basics services
Import-Module $PSScriptRoot\O365_Logon.ps1 -Force           #connects basics services
Import-Module $PSScriptRoot\Connect-O365.ps1 -Force         #connects custom services
Import-Module $PSScriptRoot\Test-O365Connections.ps1 -Force #test all services

$global:conected = $false
$domain = "domain"

function checkConnections {
    #test include
    #addOne -intIn 3
    if ($global:conected -eq $false) {
        Connect-O365Basic
        Connect-O365 -AAD -SCC -Credential $credential -Tenant $domain 
        $global:conected = $true
    }else {
        write-host $global:conected -ForegroundColor Red 
    }
    
    Clear-Host 
    Write-Host "=================== Conection ==================="
    Test-O365Connections -All
}

#OTROS
function debugMode {
    $prompt = Read-Host -Prompt "Introduce el comando deseado"
    Write-Host "Command to execute: " $prompt -ForegroundColor yellow
    $v = Invoke-Expression $prompt
    Write-Output $v
    #& $prompt
    pause
}

function sendEmail {
    Param($body,$uMail)
    #componemos mail
    
    write-host $body
    #write-host $uMail
    #enviar email confirmación
    $Username =""
    $Password = ConvertTo-SecureString "" -AsPlainText -Force
    $credential = New-Object System.Management.Automation.PSCredential $Username, $Password
    $SMTPServer = ""
    $EmailFrom = ""
    $Subject = ""
    $EmailTo = "$uMail"

    #Send-MailMessage -smtpServer $SMTPServer -Credential $credential -Usessl -port 587 -from $EmailFrom -to $EmailTo -subject $Subject -Body $body -BodyAsHtml
}

function uptimeConsole {
    Param($inicio)
    $now = Get-Date
    $tTotal = $now - $inicio
    write-host $tTotal
}

function getSesion {
    $sessions = Get-PSSession | Select-Object -Property Id,Name,IdleTimeout,State
    write-host "All sessions"
    foreach ($s in $sessions) {
        Write-Host "ID: "$s.Id "Name: " $s.Name "Time:" $s.IdleTimeout "Status" $s.State -ForegroundColor Yellow
    }
    pause
}

function Main-Menu {
    $start = Get-Date
    $PSScriptRoot #get root folder 
    do { 
        cls
        Write-Host "=================== Start ==================="
        Write-Host "Iniciando..."
        Write-Host $PSScriptRoot
        checkConnections

        write-host (uptimeConsole -inicio $start)
        Write-Host "================ PRINCIPAL ================"
        Write-Host "1. Exchange" 
        Write-Host "2. SharepPoint" 
        Write-Host "3. Teams"
        Write-Host "4. Admin Tools"
        Write-Host "-----------------"
        Write-Host "D. debug"  -ForegroundColor Cyan
        Write-Host "S. sesions"
        Write-Host "Q. Exit"  -ForegroundColor Red
        $menuresponse = read-host [Enter Selection]
        Switch ($menuresponse) {
            "1" {menuExchange}
            "2" {menuSPO}
            "3" {menuTeams}
            "4" {menuAdminTools}
            "D" {debugMode}
            "S" {getSesion}
            "0" {ConnectO365maav}
            "O" {ConnectOnPremise}
            "close" {CloseSesions}
            'Q' {
                    #CloseSesions
                    Disconnect-O365
                    return
                }
       }
       #pause
    }
    until ($menuresponse -eq 'q') 
}

function menuExchange {
    do {
        cls
        
        Write-Host "================ 1. EXHANGE ================"
        Write-Host "users:" (Get-TotalUsers) -ForegroundColor Cyan

        Write-Host "1. Find Groups" 
        Write-Host "2. Update Contacts" 
        Write-Host "3. Update Contacts By Group" 
        Write-Host "4. Get Outlook Folder's By User" 
        Write-Host "5. Make Signature by User"
        Write-Host "-----------------"
        Write-Host "6. Stadistics"      
        Write-Host "7. Show last Logins" 
        Write-Host "8. Find Older Guests Users"
        Write-Host "9. Get Licensed and Blocked"
        Write-Host "10. Find Guest Users Obsolete"
        Write-Host "11. Show last Login by User"
        Write-Host "12. Get Login OWA?"
        Write-Host "-----------------"
        
        Write-Host "B -> Return to Main Menu" -ForegroundColor Yellow
        $menuresponse = read-host [Enter Selection]
        Switch ($menuresponse) {
            "1" {FindGroups}
            "2" {UpdateContactSolo}
            "3" {ImportByGroups}
            "4" {GetMailboxFolderStatistics  –Title 'Get Folders by user'}
            "5" {makesignature}
            "6" {GetStadistics  –Title 'Stadistics'}
            "7" {& "$PSScriptRoot\O365UserLoginHistory.ps1"}
            "8" {& "$PSScriptRoot\FindOldGuestUsers.ps1"}
            "9" {GetLicensedAndBloqued –Title 'Get Licensed & Blocked'}
            "10" {& "$PSScriptRoot\FindObsoleteGuestsByActivityV2.ps1"}
            "11" {ShowLastLogin}
            "12" {GetLoginOWA}
            
            "B" {return}
        }
        pause
    }
    until ($menuresponse -eq 'q')
}

function menuSPO {
    do {
        cls
    
        write-host (uptimeConsole -inicio $start)
        Write-Host "================ 2. SharePoint ================"
        write-host "Sites:" (GetSPOSites) -ForegroundColor Cyan

        Write-Host "1. OneDrive Storage Usage" 
        Write-Host "2. SPO Sites Storage Usage" 
        Write-Host "3. Find When Anonymous Link Used" 

        Write-Host "-----------------"
        Write-Host "B -> Return to Main Menu" -ForegroundColor Yellow
        $menuresponse = read-host [Enter Selection]
        Switch ($menuresponse) {
            "1" {ReportOneDriveStorageUsage}
            "2" {& "$PSScriptRoot\ReportSPOSiteStorageUsage.ps1"}
            "3" {FindWhenAnonymousLinkUsed}
            "B" {return}
        }
        pause
    }
    until ($menuresponse -eq 'q')
}

function menuTeams {
    do {
        cls
        Write-Host "================ 3. Teams ================"
        write-host "Teams:" (GetTeams) -ForegroundColor Cyan

        Write-Host "1. ?" 

        Write-Host "-----------------"
        Write-Host "B -> Return to Main Menu" -ForegroundColor Yellow
        $menuresponse = read-host [Enter Selection]
        Switch ($menuresponse) {
            "1" {FindGroups}
            "2" {Option-2}
            "3" {Main-Menu}
            "B" {return}
        }
        pause
    }
    until ($menuresponse -eq 'q')
}

function menuAdminTools {
    do {
        cls

        checkConnections
        
        write-host (uptimeConsole -inicio $start)
        Write-Host "================ 4. Admin Tools ================"
        Write-Host "1. Get Lisenced And Bloqued" 
        Write-Host "2. Get Lisenced And Bloqued" 
        Write-Host "-----------------"
        Write-Host "B -> Return to Main Menu" -ForegroundColor Yellow
        $menuresponse = read-host [Enter Selection]
        Switch ($menuresponse) {
            "1" {1}
            "2" {GetLastLogon}
            "3" {Main-Menu}
            "B" {return}
        }
        pause
    }
    until ($menuresponse -eq 'q')
}

Main-Menu

for ($i = 0; $i -lt $array.Count; $i++) {
    
}
