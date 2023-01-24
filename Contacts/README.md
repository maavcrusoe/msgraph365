# Contacts 365

Sync all Active Directory users that have mobile to all users in your company using MS Graph API. Easy to use and free!
Save your time SysAdmin and keep your GAL updated!

<p align="center">
  <img  src="https://github.com/maavcrusoe/msgraph365/blob/main/Contacts/start.png">
</p>


## Steps
1. Create file with all funtcions import at line 3 > "Import-Module $PSScriptRoot\msgraph.ps1 -Force"
2. Create an Business APP in your Azure AD Portal
3. Edit local variables using your business app data
   1. $clientSecret
   1. $clientID
   1. $tenantName
4. Start ./menuGraph.ps1

## Tasks

- [x] Update all contacts to all users  (include news contacts and any changes)
- [x] Update all contacts to 1 user (include news contacts and any changes)
- [x] Delete contact to 1 user
- [x] Delete contact to all users
- [x] Delete 1 contact to all users
- [x] Find duplicated contacts to 1 user
- [x] Find contact from 1 user
- [x] Find contact folders from 1 user
- [x] Obtain contact data from user
- [x] Import contacts using .vcf
- [x] Export all contacts from your AD
- [x] Export all contacts from 1 contact
- [x] Export formated contacts easy to import in low android versions (useful with MDM and users without 365 license)
- [x] Token refresh every 60min
- [x] Ignore user list 
- [x] GetUserData with | outpud-gridview useful for view all contacts
- [x] /debug you can execute any funcion individually or send custom querys to MS Graph using current Token
- [x] Write Log details when you start the program

> **Note**
> 
> If you have any suggestions or news ideas to implement feel free to contact me! :e-mail:
