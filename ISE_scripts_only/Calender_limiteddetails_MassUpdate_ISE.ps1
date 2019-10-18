#PSVersion 5 Script made/assembled by Rust@m 02-05-2018
<#Login RUFR all AD login, Hybrid and o365
$CommandPath = (Get-Location).Path | Split-Path -Parent; $script = "$CommandPath\Logins\Login_SSI_SST_exch2010_DKSUND_Exchange365_RUFR.ps1"; & $script

#Login RUFR only office365
Import-Module MSOnline
$Global:credo365 = Get-Credential adm-rufr@dksund.onmicrosoft.com -Message "login til  Office 365"
$Global:sessiono365 = New-PSSession -ConfigurationName Microsoft.Exchange -Authentication Basic -ConnectionUri https://ps.outlook.com/powershell -AllowRedirection:$true  -Credential $Global:credo365
Import-PSSession $Global:sessiono365 -Prefix o365 -AllowClobber
Connect-MsolService -Credential $Global:credo365
cls
#>

Get-o365Mailbox rufr | fl
Get-o365MailboxFolderPermission -Identity rufr:\Calendar
Get-o365MailboxFolderPermission -Identity rufr:\Kalender
Get-o365MailboxFolderStatistics rufr  -FolderScope calendar | ft Name | out-file .\Export\1.txt
Set-o365MailboxRegionalConfiguration –identity rufr –language da-dk -LocalizeDefaultFolderName 
Get-o365MailboxFolderPermission -Identity rufr:\Kalender
Set-o365mailboxfolderpermission –identity rufr:\Kalender –user Default –Accessrights LimitedDetails

Get-o365MailboxFolderPermission -Identity 092-343:\Kalender
Set-o365mailboxfolderpermission –identity 092-343:\Kalender –user Default –Accessrights LimitedDetails


Get-o365MailboxFolderPermission -Identity HIN:\Kalender
Set-o365mailboxfolderpermission –identity HIN:\Kalender –user Default –Accessrights AvailabilityOnly


Get-o365MailboxFolderPermission -Identity OLJ:\Kalender
Set-o365mailboxfolderpermission –identity OLJ:\Kalender –user Default –Accessrights AvailabilityOnly

Get-o365MailboxFolderPermission -Identity SHA:\Kalender
Set-o365mailboxfolderpermission –identity SHA:\Kalender –user Default –Accessrights AvailabilityOnly

Get-o365MailboxFolderPermission -Identity AMS:\Kalender
Set-o365mailboxfolderpermission –identity AMS:\Kalender –user Default –Accessrights AvailabilityOnly

Get-o365MailboxFolderPermission -Identity MME:\Calendar
Set-o365mailboxfolderpermission –identity MME:\Calendar –user Default –Accessrights AvailabilityOnly

Get-o365MailboxFolderPermission -Identity HBI:\Kalender
Set-o365mailboxfolderpermission –identity HBI:\Kalender –user Default –Accessrights AvailabilityOnly

Get-o365MailboxFolderPermission -Identity cht:\Kalender



$pathRUFR = "rufr" + ":\" + (Get-o365MailboxFolderStatistics rufr | ? { $_.Foldertype -eq "Calendar"}).Name

#for alle - limited details
#*******************************************************************************************************************************************************************************
$allmailbox = Get-o365Mailbox $CSV 
$allmailbox.Count
$allmailbox.alias
 
Foreach ($Mailbox in $allmailbox)
{
     $path = $Mailbox.alias + ":\" + (Get-o365MailboxFolderStatistics $Mailbox.alias | Where-Object { $_.Foldertype -eq "Calendar" }).Name
     #org: $path = $Mailbox.alias + ":\" + (Get-o365MailboxFolderStatistics $Mailbox.alias | Where-Object { $_.Foldertype -eq "Calendar" } | Select-Object -First 1).Name
     #$pathRUFR = "rufr" + ":\" + (Get-o365MailboxFolderStatistics rufr | ? { $_.Foldertype -eq "Calendar"}).Name
     Set-o365mailboxfolderpermission –identity ($path) –user Default –Accessrights LimitedDetails
}
#*******************************************************************************************************************************************************************************


