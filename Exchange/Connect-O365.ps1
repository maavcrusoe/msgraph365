function Connect-O365 {
    <#
        .Synopsis
        This CMDLET connects you to O365 services.
         
        .DESCRIPTION
        This CMDLET is design to connect you to specify O365 services. You can do it for all, few or single service in O365 by using Parameters.
            
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
        Connects you to MSOL.
    
        .PARAMETER SPO
        Connects you to SharePoint Online.
    
        .PARAMETER ExO
        Connects you to Exchange Online.
    
        .PARAMETER SCC
        Connects you to Security & Compliance Center.
        
        .PARAMETER SfB
        Connects you to Skype for Business Online.
    
        .PARAMETER Teams
        Connects you to Teams Online.    
    
        .PARAMETER AAD
        Connects you to Azure Active Directory.
            
        .PARAMETER All
        Connects you to all services.
        
        .EXAMPLE
        $credential = Get-Credential
        Connect-O365 -All -Credential $credential
    
        Connects you to all services. You will be ask to provied tenant name
    
        .EXAMPLE
        $credential = Get-Credential
        Connect-O365 -MSOL -SfB -SPO -Credential $credential -Tenant MyTenant
    
        Connects you MSOL, SPO and SfB with given credentials.
    
    
    #>
    
    param (
        [Parameter(Mandatory=$false)]
            [string]$Username=$null,
        [Parameter(Mandatory=$false)]
            [PSCredential]$Credential=$null,
        [Parameter(Mandatory=$false,HelpMessage="Example https://[your tenant name]-admin.sharepoint.com")]
            [string]$Tenant=$null,
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
            [switch]$CSOM
    )
    
    #Check for credential
        if($Credential -eq $null){
        $Credential = Get-Credential -UserName $Username -Message "Put ypur creds"
        }
    
    #Check for Modules and Extensions if not loaded then load them
        if ($All) { $MSOL = $SPO = $ExO = $SfB = $Teams = $AAD = $CSOM = $SCC = $true}
    $connections=@{}
    
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
            if($MSOL){
                $connections += Test-O365Connections -MSOL -Quiet
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
            if($SPO){
                $connections += Test-O365Connections -SPO -Quiet
                }
            }
    
    if($ExO){
            $connections += Test-O365Connections -ExO -Quiet
    
            #Well not realy needed :D
            }
    
    if($SCC){
            $connections += Test-O365Connections -SCC -Quiet
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
            if($SfB){
                $connections += Test-O365Connections -SfB -Quiet
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
            if($AAD){
                $connections += Test-O365Connections -AAD -Quiet
                }
            }
    
    if($Teams){
            if(![bool]((Get-Module MicrosoftTeams).count)){
                    if(![bool]((Get-Module MicrosoftTeams -ListAvailable).count)){
                    Write-Host "Microsoft Teams module not installed. Disabling connection checking for it." -ForegroundColor Red
                    $Teams = $false    
                    }
                    else
                    {
                    Write-Host "Importing Microsoft Teams module" -ForegroundColor Green
                    Import-Module MicrosoftTeams
                    }
                }
            if($Teams){
                $connections += Test-O365Connections -Teams -Quiet
                }
            }
    
    if($CSOM){
            if(Test-Path -Path "C:\Program Files\Common Files\microsoft shared\Web Server Extensions"){
                $CSOM_ver = Get-ChildItem  "C:\Program Files\Common Files\microsoft shared\Web Server Extensions" -Name | Sort-Object -Descending | select -First 1
                $CSOM_path = "C:\Program Files\Common Files\microsoft shared\Web Server Extensions\" + $CSOM_ver + "\ISAPI"
                if (Test-Path -Path $CSOM_path){
                    Get-ChildItem -Path $CSOM_path -Name -Include *.dll | foreach { Add-Type -Path (Join-Path $CSOM_path $_)}
                    }
                }
                else{
                    Write-Host "Missing CSOM files. CSOM not loaded." -ForegroundColor Red
                    }
                
            }
    
    
    #Connect to MSOL
    if(($MSOL -eq $true) -and ($connections["MSOL"]  -cin $null, $false, "NotSupported")){
        Write-Host "Connecting to MSOL..." -ForegroundColor DarkCyan
        Connect-MsolService -Credential $credential
        }
    
    #Connect to SPO
    if(($SPO -eq $true) -and ($connections["SPO"]  -cin $null, $false, "NotSupported")){
    
        if($tenant -eq $null)
            {
            Write-Host "You need to provide tenant name." -ForegroundColor Blue
            $tenant = Read-Host -Prompt "Tenant"
            }
        Write-Host "Connecting to SPO Tenant ($tenant) site... " -ForegroundColor DarkCyan
        Do{
            $retry_connect="0"
            try{
            Connect-SPOService -Url https://$tenant-admin.sharepoint.com -credential $credential
            }
            catch
            {
            #Check if SSL/TSL error
            $error_text = $ErrorMessage = $_.Exception.Message
            if($error_text -like "*SSL/TLS*")
                    {
                    $retry_connect = "1"
                    Write-Host "Retring..." -ForegroundColor Cyan
                    }
                    else
                    {
                    Write-Host "Unsupported error..." -ForegroundColor Red
                    Write-Host "Error is" $_.Exception.Message -ForegroundColor Gray
                    }
            }
    
    
            }
        While($retry_connect -eq "1")
        }
    
    #Connect to Exchange Online
    if(($ExO -eq $true) -and ($connections["ExO"]  -cin $null, $false, "NotSupported")){    
    
        Write-Host "Connecting to Exchange Online..." -ForegroundColor DarkCyan
        $exchangeSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "https://outlook.office365.com/powershell-liveid/" -Credential $credential -Authentication "Basic" -AllowRedirection
        Import-PSSession $exchangeSession -DisableNameChecking
        }
    
    #Connect to SfB Online
    if(($SfB -eq $true) -and ($connections["SfB"]  -cin $null, $false, "NotSupported")){
           Write-Host "Connecting to SkypeOnline..." -ForegroundColor DarkCyan
           Do{
                $retry=0
                
                try{
                    $sfboSession = New-CsOnlineSession -Credential $credential
                    }
                catch {
                    $retry=1
                    Write-Host "Retring..." -ForegroundColor Cyan
                    }
        } While($retry)
        Import-PSSession $sfboSession -DisableNameChecking
        }
    
    #Connect to Azure AD wiht PS module v2
    if(($AAD -eq $true) -and ($connections["AAD"]  -cin $null, $false, "NotSupported")){
        Write-Host "Connecting to Azure AD..." -ForegroundColor DarkCyan
        Connect-AzureAD -Credential $Credential
        }
    
    #Connect to Microsoft Teams
    if(($Teams -eq $true) -and ($connections["MSOL"]  -cin $null, $false, "NotSupported")){
        Write-Host "Connecting to Microsoft Teams..." -ForegroundColor DarkCyan
        Connect-MicrosoftTeams -Credential $Credential
        }
    
    #Connect to Security & Compliance Center
    if(($SCC -eq $true) -and ($connections["SSC"]  -cin $null, $false, "NotSupported")){    
        Write-Host "Connecting to Security & Compliance Center..." -ForegroundColor DarkCyan
     try{
        $SCC_conected = [bool]($ccSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.compliance.protection.outlook.com/powershell-liveid/ -Credential $credential -Authentication Basic -AllowRedirection -ErrorAction SilentlyContinue)
        if($SCC_conected){
            Import-PSSession $ccSession -Prefix cc -ErrorAction SilentlyContinue
            }
            else
            {
            Write-Host "Connection faild." -ForegroundColor Red
            Write-Host $Error[0].Exception.Message -ForegroundColor Red
            }
        }
        catch {
            Write-Host $_.Exception.Message -ForegroundColor Red
            }
          
        }
    
    }