function Test-O365Connections {
<#
    .Synopsis
    This CMDLET test connections to O365 services.
     
    .DESCRIPTION
    This CMDLET is design to test if you are connected to specify O365 services. You can test your connections to all, few or single service in O365 by using Parameters.
    By default it will put on screen result and return hash table with results.
    
    Avalible services for now:
    MSOL
    SharePoint Online
    Exchange Online
    Microsoft TeamsSecurity & Compliance Center
    Skype for Bussines Online
    Azure Active Directory
    Microsoft Teams
    
    It can test single service, few or all.
    
    .PARAMETER MSOL
    Check if connected to MSOL.

    .PARAMETER SPO
    Check if connected to SharePoint Online.

    .PARAMETER ExO
    Check if connected to Exchange Online.

    .PARAMETER SCC
    Check if connected to Security & Compliance Center.

    .PARAMETER SfB
    Check if connected to Skype for Business Online.

    .PARAMETER Teams
    Check if connected to Teams Online.    

    .PARAMETER AAD
    Check if connected to Azure Active Directory.
        
    .PARAMETER All
    Test connections to all services.
    
    .PARAMETER Quiet
    This parm will turn off screen results.

    .PARAMETER NoResults
    This will disable returning hash table results

    .EXAMPLE
    Test-O365Connections -All

    This will test your connestions to all services.

    .EXAMPLE
    Test-O365Connections -MSOL -SPO -AAD -NoResults

    This will test your connections to MSOL, SharePoint Online and Azure AD. But will result just on screen.

    .EXAMPLE
    Test-O365Connections -MSOL -SPO -AAD -Quiet

    This will test your connections to MSOL, SharePoint Online and Azure AD. But will return only hash table whit results. 

#>
param(
    [Parameter(Mandatory=$false)]
        [switch]$All,
    [Parameter(Mandatory=$false)]
        [switch]$MSOL,
    [Parameter(Mandatory=$false)]
        [switch]$SPO,
    [Parameter(Mandatory=$false)]
        [switch]$ExO,
    [Parameter(Mandatory=$false)]
        [switch]$SCC,
    [Parameter(Mandatory=$false)]
        [switch]$SfB,
    [Parameter(Mandatory=$false)]
        [switch]$AAD,
    [Parameter(Mandatory=$false)]
        [switch]$Teams,
    [Parameter(Mandatory=$false)]
        [switch]$Quiet,
    [Parameter(Mandatory=$false)]
        [switch]$NoResults
)

$connections=@{}

if ($All -and ($MSOL -or $SPO -or $ExO -or $SfB -or $Teams -or $SCC)){
Write-Host "You canot use -All with other parameters" -ForegroundColor Red
break
}
if ($All) { $MSOL = $SPO = $ExO = $SfB = $Teams = $AAD = $SCC = $true}
if($MSOL){
        if(![bool]((Get-Module MsOnline).count)){
                if(![bool]((Get-Module MsOnline -ListAvailable).count)){
                Write-Host "MSOL module not installed. Disabling connection checking for it." -ForegroundColor Red
                $MSOL = $false    
                }
                else
                {
                Write-Host "Importing MSOL module" -ForegroundColor Green
                Import-Module MsOnline
                }
            }
        }

if($SPO){
        if(![bool]((Get-Module Microsoft.Online.SharePoint.PowerShell).count)){
                if(![bool]((Get-Module Microsoft.Online.SharePoint.PowerShell -ListAvailable).count)){
                Write-Host "SPO module not installed. Disabling connection checking for it." -ForegroundColor Red
                $SPO = $false    
                }
                else
                {
                Write-Host "Importing SPO module" -ForegroundColor Green
                Import-Module Microsoft.Online.SharePoint.PowerShell
                }
            }
        }

if($ExO){
        #Well not realy needed :D
        }

if($SCC){
        #Well not realy needed :D
        }

if($SfB){
        if(![bool]((Get-Module SkypeOnlineConnector).count)){
                if(![bool]((Get-Module SkypeOnlineConnector -ListAvailable).count)){
                Write-Host "Skype for Buisness module not installed. Disabling connection checking for it." -ForegroundColor Red
                $SfB = $false    
                }
                else
                {
                Write-Host "Importing Skype for Buisness module" -ForegroundColor Green
                Import-Module SkypeOnlineConnector
                }
            }
        }

if($AAD){
        if(![bool]((Get-Module AzureAD).count)){
                if(![bool]((Get-Module AzureAD -ListAvailable).count)){
                Write-Host "Azure AD module not installed. Disabling connection checking for it." -ForegroundColor Red
                $AAD = $false    
                }
                else
                {
                Write-Host "Importing Azure AD module" -ForegroundColor Green
                Import-Module AzureAD
                }
            }
        }

if($Teams){
        if(![bool]((Get-Module MicrosoftTeams).count)){
                if(![bool]((Get-Module MicrosoftTeams -ListAvailable).count)){
                Write-Host "Microsoft Teams module not installed. Disabling connection checking for it." -ForegroundColor Red
                $AAD = $false    
                }
                else
                {
                Write-Host "Importing Microsoft Teams module" -ForegroundColor Green
                Import-Module MicrosoftTeams
                }
            }
        }


#------Check if connected to MSOL--------#
    if($MSOL){


    Get-MsolDomain -ErrorAction SilentlyContinue | out-null
    $result = $?
    $connections.Add("MSOL",$result)
    if(!$Quiet){
        Write-Host "MSOL:"$result -ForegroundColor Cyan
        }
    }

#------Check if connected to SPO--------#
    if($SPO){
    try{
        Get-SPOTenant -ErrorAction SilentlyContinue | Out-Null
        $result = $true
    }
    catch{
        $result = $false
    }
    $connections.Add("SPO",$result)
    if(!$Quiet){
        Write-Host "SPO:"$result -ForegroundColor Cyan
        }
    }

#------Check if connected to Exchange--------#
    if($ExO){
    $result = [bool]((Get-PSSession | Where-Object {$_.ConfigurationName -eq "Microsoft.Exchange" -and $_.Availability -eq "Available" -and $_.State -eq "Opened" -and $_.ComputerName -eq "outlook.office365.com"}).count)
    $connections.Add("ExO",$result)
    if(!$Quiet){
        Write-Host "Exchange:"$result -ForegroundColor Cyan
        }
    }

#------Check if connected to SfB--------#
    if($SfB){
    $result = [bool]((Get-PSSession | Where-Object {$_.ConfigurationName -eq "Microsoft.PowerShell" -and $_.Availability -eq "Available" -and $_.State -eq "Opened" -and $_.ComputerName -eq "admin1a.online.lync.com"}).count)
    $connections.Add("SfB",$result)
    if(!$Quiet){
        Write-Host "Skype for Buisness:"$result -ForegroundColor Cyan
        }
    }

#------Check if connected to Teams--------#
    if($Teams){
    $result = $true
    try{
    $t = Get-Team -MailNickName "SSII"
    }
    catch
    {
    $result = $false
    }

    $connections.Add("Teams",$result)
    if(!$Quiet){
        Write-Host "Microsoft Teams:"$result -ForegroundColor Cyan
        }
    }

#------Check if connected to Azure AD--------#
    if($AAD){
    $result = $True
    try{
    $tenant = Get-AzureADTenantDetail -ErrorAction SilentlyContinue
    }
    catch{
    $result = $?
    }
    $connections.Add("AAD",$result)
    if(!$Quiet){
        Write-Host "Azure AD:"$result -ForegroundColor Cyan
        }
    }

#------Check if connected to Security & Compliance Center--------#
    if($SCC){
    $result = [bool]((Get-PSSession | Where-Object {$_.ConfigurationName -eq "Microsoft.Exchange" -and $_.Availability -eq "Available" -and $_.State -eq "Opened" -and $_.ComputerName -like "*compliance.protection.outlook.com8"}).count)
    $connections.Add("SCC",$result)
    if(!$Quiet){
        Write-Host "Security & Compliance Center:"$result -ForegroundColor Cyan
        }
    }

if(!$NoResults){
    #return connections status
    #return $connections
    #Write-Host $connections
    }
}