#PSVersion 5 Script made/assembled by Rust@m 02-05-2018
<#Login RUFR all AD login, Hybrid and o365
$CommandPath = (Get-Location).Path | Split-Path -Parent|Split-Path -Parent; $script = "$CommandPath\Logins\Login_SSI_SST_exch2010_DKSUND_Exchange365_RUFR.ps1"; & $script

#Login RUFR only office365
Import-Module MSOnline
$Global:credo365 = Get-Credential adm-rufr@dksund.onmicrosoft.com -Message "login til  Office 365"
$Global:sessiono365 = New-PSSession -ConfigurationName Microsoft.Exchange -Authentication Basic -ConnectionUri https://ps.outlook.com/powershell -AllowRedirection:$true  -Credential $Global:credo365
Import-PSSession $Global:sessiono365 -Prefix o365 -AllowClobber
Connect-MsolService -Credential $Global:credo365
$WorkingDir = Convert-Path .

cls
#>

$Global:WorkingDir
$Global:WorkingDir = Convert-Path .

#Get-PSDrive
Set-Location -Path 'SSIAD:' 
Set-Location -Path 'SSTAD:'


#SST mailbox
Get-SSTMailbox adm-rufr |FL
Get-SSTMailbox bpo |FL


#SSI mailbox
Get-o365MailboxFolderPermission  rufr:\kalender
Get-o365MailboxFolderPermission  rufr:\Calendar
Get-o365MailboxFolderPermission  rufr
Get-o365MailboxFolderPermission  Concierge:\kalender
Get-o365MailboxFolderPermission  Concierge:\indbakke
Add-o365MailboxFolderPermission concierge:\indbakke -User rufr -AccessRights editor

$ADuser = 'HBI'
Get-o365Mailbox $ADuser |fl 
Get-RemoteMailbox $ADuser
Get-ADUser $ADuser
Get-o365MailboxFolderStatistics $ADuser | Out-File "$Global:WorkingDir\stats$User.txt"

#Add premmission
$MailCalenderPath = "$ADuser" + ":\Kalender"
Set-o365mailboxfolderpermission –identity  $MailCalenderPath –user Default –Accessrights LimitedDetails
Add-o365MailboxFolderPermission –Identity $MailCalenderPath –User ConciergeMobile –AccessRights Editor
Add-o365MailboxFolderPermission $ADuser -User conciergemobile -AccessRights foldervisible -ErrorAction SilentlyContinue
Set-o365MailboxFolderPermission $ADuser -User conciergemobile -AccessRights foldervisible -ErrorAction SilentlyContinue
Get-o365MailboxFolderPermission -Identity $MailCalenderPath


#Remove premmission
$ADuser = 'hbi'
Get-o365MailboxFolderPermission $ADuser |select user
Remove-o365MailboxFolderPermission $ADuser -User 'NT:S-1-5-21-1577934378-2410581259-444889973-1165' -Confirm:$false




#SST AD login og import af AD modulet.
$Global:UserCredSST = Get-Credential sst.dk\adm-rufr -Message "SST AD login og import af AD modulet"
#exchange 2010 - STPS, SST
$Global:Exchange2010_SST = "S-EXC-MBX01-P.sst.dk"
$Global:SessionExchangeSST= New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://S-EXC-MBX01-P.sst.dk/PowerShell/ -Authentication Kerberos -Credential $Global:UserCredSST
Import-PSSession $Global:SessionExchangeSST -Prefix SST
#Write-Verbose "Loading the Exchange snapin (module)"
Add-PSSnapin Microsoft.Exchange.Management.PowerShell.E2010 -ErrorAction SilentlyContinue

#SST mailbox
Get-SSTMailboxFolderPermission  KMLR:\kalender
Get-SSTMailboxFolderPermission  KMLR:\Calendar
Get-SSTMailboxFolderPermission  KMLR
Get-SSTMailboxPermission KMLR
Add-SSTMailboxFolderPermission test:\indbakke -User rufr -AccessRights editor
Remove-SSTMailboxFolderPermission  KMLR:\kalender -User 'Jane Madsen' -Confirm:$false
Remove-SSTMailboxFolderPermission  KMLR:\kalender -User 'stps_g_troest_kalenderred' -Confirm:$false

$ADuser = 'amv'
Get-SSTMailbox $ADuser |fl 
Get-ADUser $ADuser
Get-SSTMailboxFolderStatistics $ADuser | Out-File "$Global:WorkingDir\stats$User.txt"

#Add premmission
$MailCalenderPath = "$ADuser" + ":\Kalender"
Set-SSTmailboxfolderpermission –identity  $MailCalenderPath –user Default –Accessrights LimitedDetails
Add-SSTMailboxFolderPermission –Identity $MailCalenderPath –User ConciergeMobile –AccessRights Editor
Add-SSTMailboxFolderPermission $ADuser -User conciergemobile -AccessRights foldervisible -ErrorAction SilentlyContinue
Set-SSTMailboxFolderPermission $ADuser -User conciergemobile -AccessRights foldervisible -ErrorAction SilentlyContinue
Get-SSTMailboxFolderPermission -Identity $MailCalenderPath


#Remove premmission
$ADuser = 'KMLR'
Get-SSTMailboxFolderPermission $ADuser |select user
$MailCalenderPath = "$ADuser" + ":\Kalender"
$MailCalenderPath = "$ADuser" + ":\Calendar"
Get-SSTMailboxFolderPermission  –identity  $MailCalenderPath

Remove-SSTMailboxFolderPermission $ADuser -User 'S-1-5-21-1142715587-1998998323-1238779560-2493' -Confirm:$false

Get-SSTMailboxPermission $ADuser |select user
Remove-SSTMailboxPermission $ADuser -User 'S-1-5-21-1142715587-1998998323-1238779560-15141' -Confirm:$false


##grant on behalf DPG tunnel mail/e-Boks

Set-Location -Path 'DKSUNDAD:' 

Get-SSIMailbox stpk@stpk.dk
Get-ADGroup "Alle STPK"
$alias = "stpk@stpk.dk"
$ADgroup = "DPG Tunnelmail STPK"
#$ADgroup = "Alle STPK"
Get-SSIMailbox $alias
Get-ADGroup $ADgroup

#Get-Mailbox -identity $alias | add-mailboxpermission -user $ADgroup -accessrights FullAccess -inheritancetype All
#Add-recipientPermission $alias -AccessRights SendAs -Trustee $ADgroup -Confirm:$false
Set-SSIMailbox -Identity $alias -GrantSendOnBehalfTo $ADgroup
Get-SSIMailbox -Identity $alias | Format-List *GrantSendOnBehalfTo*
#get-SSIMailbox -Identity $alias |fl
#Get-SSIMailboxPermission -Identity $alias | ogv


Set-Location -Path 'SSTAD:'

$alias = "sst@sst.dk"
$ADgroup = "DPG Tunnelmail SST"
#$ADgroup = "SST alle Sundhedsstyrelsen"
Get-SSTMailbox $alias
Get-ADGroup $ADgroup

#Get-Mailbox -identity $alias | add-mailboxpermission -user $ADgroup -accessrights FullAccess -inheritancetype All
#Add-recipientPermission $alias -AccessRights SendAs -Trustee $ADgroup -Confirm:$false
Set-SSTMailbox -Identity $alias -GrantSendOnBehalfTo $ADgroup
Get-SSTMailbox -Identity $alias | Format-List *GrantSendOnBehalfTo*
#get-SSTMailbox -Identity $alias |fl
#Get-SSTMailboxPermission -Identity $alias | ogv



$alias = "sum@sum.dk"
$ADgroup = "DPG tunnelmail SUM"
Get-SSTMailbox $alias
Get-ADGroup $ADgroup

#Get-Mailbox -identity $alias | add-mailboxpermission -user $ADgroup -accessrights FullAccess -inheritancetype All
#Add-recipientPermission $alias -AccessRights SendAs -Trustee $ADgroup -Confirm:$false
Set-SSTMailbox -Identity $alias -GrantSendOnBehalfTo $ADgroup
Get-SSTMailbox -Identity $alias | Format-List *GrantSendOnBehalfTo*
#get-SSTMailbox -Identity $alias |fl
#Get-SSTMailboxPermission -Identity $alias | ogv


$alias = "kontakt@ngc.dk"
$ADgroup = "DPG tunnelmail NGC"
#$ADgroup = "Nationalt Genom Center All"
Get-SSTMailbox $alias
Get-ADGroup $ADgroup

#Get-Mailbox -identity $alias | add-mailboxpermission -user $ADgroup -accessrights FullAccess -inheritancetype All
#Add-recipientPermission $alias -AccessRights SendAs -Trustee $ADgroup -Confirm:$false
Set-SSTMailbox -Identity $alias -GrantSendOnBehalfTo $ADgroup
Get-SSTMailbox -Identity $alias | Format-List *GrantSendOnBehalfTo*
#get-SSTMailbox -Identity $alias |fl
#Get-SSTMailboxPermission -Identity $alias | ogv


$alias = "dketik@dketik.dk"
$ADgroup = "DPG tunnelmail DKETIK"
Get-SSTMailbox $alias
Get-ADGroup $ADgroup

#Get-Mailbox -identity $alias | add-mailboxpermission -user $ADgroup -accessrights FullAccess -inheritancetype All
#Add-recipientPermission $alias -AccessRights SendAs -Trustee $ADgroup -Confirm:$false
Set-SSTMailbox -Identity $alias -GrantSendOnBehalfTo $ADgroup
Get-SSTMailbox -Identity $alias | Format-List *GrantSendOnBehalfTo*
#get-SSTMailbox -Identity $alias |fl
#Get-SSTMailboxPermission -Identity $alias | ogv

$alias = "stps@stps.dk"
$ADgroup = "DPG Tunnelmail STPS"
Get-SSTMailbox $alias
Get-ADGroup $ADgroup

#Get-Mailbox -identity $alias | add-mailboxpermission -user $ADgroup -accessrights FullAccess -inheritancetype All
#Add-recipientPermission $alias -AccessRights SendAs -Trustee $ADgroup -Confirm:$false
Set-SSTMailbox -Identity $alias -GrantSendOnBehalfTo $ADgroup
Get-SSTMailbox -Identity $alias | Format-List *GrantSendOnBehalfTo*
#get-SSTMailbox -Identity $alias |fl
#Get-SSTMailboxPermission -Identity $alias | ogv


$alias = "sis@sis.dk"
$ADgroup = "DPG Tunnelmail SIS"
#$ADgroup = "SIS Alle medarbejdere"
Get-SSTMailbox $alias
Get-ADGroup $ADgroup

#Get-Mailbox -identity $alias | add-mailboxpermission -user $ADgroup -accessrights FullAccess -inheritancetype All
#Add-recipientPermission $alias -AccessRights SendAs -Trustee $ADgroup -Confirm:$false
Set-SSTMailbox -Identity $alias -GrantSendOnBehalfTo $ADgroup
Get-SSTMailbox -Identity $alias | Format-List *GrantSendOnBehalfTo*
#get-SSTMailbox -Identity $alias |fl
#Get-SSTMailboxPermission -Identity $alias | ogv