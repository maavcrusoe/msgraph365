Function GetSPOSites {
      $SPOSites =  Get-SPOSite -Limit All | Select Title, URL
      return $SPOSites.count
}
function ReportOneDriveStorageUsage {
      # You need to import the SharePoint Online PowerShell module into your session and connect to SharePoint with an Admin account before 
      # running this code. Something like the command below will do fine, substituting your tenant name...
      # if(-not(Get-Module -name Microsoft.Online.Sharepoint.PowerShell)) {Import-Module Microsoft.Online.Sharepoint.PowerShell} 
      # Connect-SPOService -url https://tenant-admin.sharepoint.com -Credential $O365Cred
      # Now that we're connected, we can run this code
      # Get a list of OneDrive for Business sites in the tenant sorted by the biggest consumer of quota
      $ODFBSites = Get-SPOSite -IncludePersonalSite $True -Limit All -Filter "Url -like '-my.sharepoint.com/personal/'" | Select Owner, Title, URL, StorageQuota, StorageUsageCurrent | Sort StorageUsageCurrent -Desc
      $TotalODFBGBUsed = [Math]::Round(($ODFBSites.StorageUsageCurrent | Measure-Object -Sum).Sum /1024,2)
      $Report = @()
      ForEach ($Site in $ODFBSites) {
            $ReportLine = [PSCustomObject][Ordered]@{
                  Owner    = $Site.Title
                  Email    = $Site.Owner
                  URL      = $Site.URL
                  QuotaGB  = [Math]::Round($Site.StorageQuota/1024,2) 
                  UsedGB   = [Math]::Round($Site.StorageUsageCurrent/1024,4) }
            $Report += $ReportLine }

      $OutputFile = "OneDriveStorage-Report$((Get-Date -format yyyy-MMM-dd-ddd` hh-mm` tt).ToString()).csv"      
      $Report | Export-CSV -NoTypeInformation $PSScriptRoot\export\$OutputFile
      Write-Host "Current OneDrive for Business storage consumption:" $TotalODFBGBUsed " Report is in $PSScriptRoot\export\$OutputFile"
}

Function SPOSitesRetention {
      # A script to display details of the retention policies applying to SharePoint and OneDrive for Business sites in an Office 365 tenant.
      # Uses the Security and Compliance Center PowerShell module
      $Report = @()
      # Fetch a set of retention policies that apply to SharePoint and aren't to publish labels
      $Policies = (Get-RetentionCompliancePolicy -ExcludeTeamsPolicy -DistributionDetail -RetentionRuleTypes | ? {$_.SharePointLocation -ne $Null -and $_.RetentionRuleTypes -ne "Publish"})
      ForEach ($P in $Policies) {
            $Duration = $Null
            Write-Host "Processing retention policy" $P.Name
            $Rule = Get-RetentionComplianceRule -Policy $P.Name 
            $Settings = "Simple"
            $Duration = $Rule.RetentionDuration
            # Check whether a rule is for advanced settings - either a KQL query or sensitive data types
            If (-not [string]::IsNullOrWhiteSpace($Rule.ContentMatchQuery) -and -not [string]::IsNullOrWhiteSpace($Rule.ContentMatchQuery)) {
                  $Settings = "Advanced/KQL" }
            Elseif (-not [string]::IsNullOrWhiteSpace($Rule.ContentContainsSensitiveInformation) -and -not [string]::IsNullOrEmpty($Rule.ContentContainsSensitiveInformation)) {
                  $Settings = "Advanced/Sensitive Data" }
            # Handle retention policy that simply retains and doesn't do anything else
            If ($Rule.RetentionDuration -eq $Null -and $Rule.ApplyComplianceTag -ne $Null) {
            $Duration = (Get-ComplianceTag -Identity $Rule.ApplyComplianceTag | Select -Expandproperty RetentionDuration) }
            $RetentionAction = $Rule.RetentionComplianceAction
            If ([string]::IsNullOrEmpty($RetentionAction)) {
            $RetentionAction = "Retain" }
            If ($P.SharePointLocation.Name -eq "All") {
                  $ReportLine = [PSCustomObject][Ordered]@{
                  PolicyName        = $P.Name
                  SiteName          = "All SharePoint Sites"
                  SiteURL           = "All SharePoint Sites"
                  RetentionTime     = $Rule.RetentionDurationDisplayHint
                  RetentionDuration = $Duration
                  RetentionAction   = $RetentionAction 
                  Settings           = $Settings}
                  $Report += $ReportLine } 
                  If ($P.SharePointLocationException -ne $Null) {
                  $Locations = ($P | Select -ExpandProperty SharePointLocationException)
                  ForEach ($L in $Locations) {
                        $Exception = "*Exclude* " + $L.DisplayName
                        $ReportLine = [PSCustomObject][Ordered]@{
                        PolicyName = $P.Name
                        SiteName   = $Exception
                        SiteURL    = $L.Name }
                  $Report += $ReportLine }
            }
            ElseIf ($P.SharePointLocation.Name -ne "All") {
            $Locations = ($P | Select -ExpandProperty SharePointLocation)
            ForEach ($L in $Locations) {
                  $ReportLine = [PSCustomObject][Ordered]@{
                        PolicyName        = $P.Name
                        SiteName          = $L.DisplayName
                        SiteURL           = $L.Name 
                        RetentionTime     = $Rule.RetentionDurationDisplayHint
                        RetentionDuration = $Duration
                        RetentionAction   = $RetentionAction
                        Settings          = $Settings}
                  $Report += $ReportLine  }                    
            }
      }
      $Report | Sort SiteName| Format-Table PolicyName, SiteName, RetentionDuration, RetentionAction, Settings -AutoSize
}

Function FindWhenAnonymousLinkUsed {
      $Days = Read-Host -Prompt "Please enter how many days you want to export"
      # Find out when an anonymous link is used by someone outside an Office 365 tenant to access SharePoint Online and OneDrive for Business documents
      $StartDate = (Get-Date).AddDays(-$Days); $EndDate = (Get-Date) #Maximum search range for audit log for E3 users
      CLS; Write-Host "Searching Office 365 Audit Records to find anonymous sharing activity"
      $Records = (Search-UnifiedAuditLog -Operations AnonymousLinkUsed -StartDate $StartDate -EndDate $EndDate -ResultSize 1000)
      If ($Records.Count -eq 0) {
      Write-Host "No anonymous share records found on last" $Days "days" }
      Else {
      Write-Host "Processing" $Records.Count "audit records..."
      $Report = @() # Create output file for report
      # Scan each audit record to extract information
      ForEach ($Rec in $Records) {
            $AuditData = ConvertFrom-Json $Rec.Auditdata
            $ReportLine = [PSCustomObject][Ordered]@{
            TimeStamp = Get-Date($AuditData.CreationTime) -format g
            User      = $AuditData.UserId
            Action    = $AuditData.Operation
            Object    = $AuditData.ObjectId
            IPAddress = $AuditData.ClientIP
            Workload  = $AuditData.Workload
            Site      = $AuditData.SiteUrl
            FileName  = $AuditData.SourceFileName 
            SortTime  = $AuditData.CreationTime }
      $Report += $ReportLine }
      # Now that we have parsed the information for the link used audit records, let's track what happened to each link
      $RecNo = 0; CLS; $TotalRecs = $Report.Count
      ForEach ($R in $Report) {
      $RecNo++
      $ProgressBar = "Processing audit records for " + $R.FileName + " (" + $RecNo + " of " + $TotalRecs + ")" 
      Write-Progress -Activity "Checking Sharing Activity With Anonymous Links" -Status $ProgressBar -PercentComplete ($RecNo/$TotalRecs*100)
      $StartSearch = $R.TimeStamp; $EndSearch = (Get-Date $R.TimeStamp).AddDays(+7) # We'll search for any audit records 
      $AuditRecs = (Search-UnifiedAuditLog -StartDate $StartSearch -EndDate $EndSearch -IPAddresses $R.IPAddress -Operations FileAccessedExtended, FilePreviewed, FileModified, FileAccessed, FileDownloaded -ResultSize 100)
      Foreach ($AuditRec in $AuditRecs) {
            If ($AuditRec.UserIds -Like "*urn:spo:*") { # It's a continuation of anonymous access to a document
            $AuditData = ConvertFrom-Json $AuditRec.Auditdata
            $ReportLine = [PSCustomObject][Ordered]@{
                  TimeStamp = Get-Date($AuditData.CreationTime) -format g
                  User      = $AuditData.UserId
                  Action    = $AuditData.Operation
                  Object    = $AuditData.ObjectId
                  IPAddress = $AuditData.ClientIP
                  Workload  = $AuditData.Workload
                  Site      = $AuditData.SiteUrl
                  FileName  = $AuditData.SourceFileName 
                  SortTime  = $AuditData.CreationTime }}
            $Report += $ReportLine }
      }}
      $OutputFile = "AnonymousLinksUsed$((Get-Date -format yyyy-MMM-dd-ddd` hh-mm` tt).ToString()).csv"      
      $Report | Sort FileName, IPAddress, User, SortTime | Export-CSV -NoTypeInformation "$PSScriptRoot\export\$OutputFile"
      Write-Host "All done. Output file is available in $PSScriptRoot\export\$OutputFile" -ForegroundColor Yellow
      # Output in grid, making sure that any duplicates created at the same time are ignored
      $Report | Sort FileName, IPAddress, User, SortTime -Unique | Select Timestamp, Action, Filename, IPAddress, Workload, Site | Out-Gridview  
}
