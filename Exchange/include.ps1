#CONEXION
#declare global variables
$global:o365 = $false
$global:o365v2 = $false
$global:o365maav = $false
$global:o365Security = $false
$global:ConnectOnPremise = $false
$global:o365SPO = $false

function MSOLConnected {
    Get-MsolDomain -ErrorAction SilentlyContinue | out-null
    $result = $?
    return $result
}

function checkCompilanceSecurity {
    $get = Get-ComplianceSearch -ErrorAction SilentlyContinue
    if ($get.count -ge 1) {
        $result = $true
        #write-host "Conectado" -ForegroundColor Green
        return $result
    }else {
        $result = $false
        #write-host "No estas conectado" -ForegroundColor red
        return $result
    }
}

function ConnectO365 {
    Import-Module MSOnline

    Connect-MsolService -Credential $cred
    #Connect-ExchangeOnline
    $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $cred -Authentication Basic -AllowRedirection
    #Import-PSSession $Session
    Import-Module (Import-PSSession $Session -AllowClobber) -Global

    $global:o365 = $true

}

function ConnectO365v2 {

    Import-Module MSOnline
    #$UserCredential = Get-Credential
    $upn = "user@domain.org"
    $sUserName="user@domain.org"
    $Password = ConvertTo-SecureString -String "" -AsPlainText -Force
    $UserCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $sUserName, $Password
    
    #Connect-ExchangeOnline -UserPrincipalName $upn -ShowProgress $true

    Connect-ExchangeOnline -Credential $UserCredential -ShowProgress $false

    $global:o365v2 = $true
    
}

function ConnectO365maav {

    Import-Module MSOnline

    #declare variables
    $upn = "user@domain.org"
    $sUserName="user@domain.org"
    $Password = ConvertTo-SecureString -String "" -AsPlainText -Force
    $cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $sUserName, $Password

    Connect-MsolService -Credential $cred
 
    $Sessionmaav = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $cred -Authentication Basic -AllowRedirection
 
    Import-PSSession $Sessionmaav -AllowClobber

    #define global variable
    $global:o365maav = $true
}

function ConnectSecurity {
    Connect-MsolService -Credential $UserCredential

    $SessionSecurity = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.compliance.protection.outlook.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic –AllowRedirection

    Import-Module (Import-PSSession $SessionSecurity -AllowClobber) -Global

    $global:o365Security = $false
}

function ConnectSPO {
    $adminUPN="user@domain.org"
    $orgName="domain.org"
    $userCredential = Get-Credential -UserName $adminUPN -Message "Type the password."
    Connect-SPOService -Url https://$orgName-admin.sharepoint.com -Credential $userCredential

    $global:o365SPO = $true
}

function ConnectOnPremise {
    $adminUPN = "user@domain.org"
    $cred = Get-Credential -UserName $adminUPN -Message "Type the password."

    Import-Module MSOnline

    Connect-MsolService -Credential $cred

    $SessionOnPremise = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://exchange.domain.org/PowerShell/ -Authentication Kerberos -Credential $UserCredential
    Import-PSSession $SessionOnPremise -AllowClobber

    $global:ConnectOnPremise = $true
}

function CloseSesions {
    Get-PSSession | Remove-PSSession
    Remove-PSSession -Session (Get-PSSession)
    $s = Get-PSSession
    Remove-PSSession -Session $s
}
