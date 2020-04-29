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
$WorkingDir = Convert-Path .
#>


#$pathRUFR = "rufr" + ":\" + (Get-o365MailboxFolderStatistics rufr | ? { $_.Foldertype -eq "Calendar"}).Name

Get-ADUser rufr -Properties * | Select *
Get-o365Mailbox -Identity "C_SLF.NGC" | Select-Object *


# ConciergeMobile get granted access to  alle user mailbox Calendar right - Editor
#*******************************************************************************************************************************************************************************

$mailboxes = Get-o365Mailbox -ResultSize Unlimited -Filter {(RecipientTypeDetails -eq "UserMailbox") -or (RecipientTypeDetails -eq "SharedMailbox") -and (Alias -ne 'ConciergeMobile')} #| Where-Object { ($_.RecipientTypeDetails -eq "UserMailbox") -and ($_.Alias -ne 'ConciergeMobile') } 
$allmailbox =  $mailboxes | where {$_.UserPrincipalName -notlike "*C_*"}
$allmailbox |  Select-Object WindowsEmailAddress,Identity , DisplayName | Export-CSV -delimiter ";" "$WorkingDir\MailBoxes.csv" -NoTypeInformation -Encoding UTF8



<#
# if want to export to list csv

$allmailbox |  Select-Object WindowsEmailAddress,Identity , DisplayName | Sort-Object -Descending |ogv

$allmailbox.Count
$allmailbox.alias | Sort-Object -Descending |ogv
#>
 
Foreach ($Mailbox in $allmailbox) 
{   
     #reconnect office 365 session to avoid connectivetty and exparation issues.
     #Get-PSSession  | ?{$_.ComputerName -like "*.outlook.com"} | Remove-PSSession
     #$Global:sessiono365 = New-PSSession -ConfigurationName Microsoft.Exchange -Authentication Basic -ConnectionUri https://ps.outlook.com/powershell -AllowRedirection:$true -Credential $Global:credo365
     #Import-PSSession $Global:sessiono365 -Prefix o365 -AllowClobber
     #Connect-MsolService -Credential $Global:credo365

     
     $path = $Mailbox.alias + ":\" + (Get-o365MailboxFolderStatistics $Mailbox.alias | Where-Object { $_.Foldertype -eq "Calendar" }).Name
     #org: $path = $Mailbox.alias + ":\" + (Get-o365MailboxFolderStatistics $Mailbox.alias | Where-Object { $_.Foldertype -eq "Calendar" } | Select-Object -First 1).Name
     #$pathRUFR = "rufr" + ":\" + (Get-o365MailboxFolderStatistics rufr | ? { $_.Foldertype -eq "Calendar"}).Name
     #Set-o365mailboxfolderpermission -identity ($path) -user Default -Accessrights LimitedDetails
     Write-host -Object $("Udfører handling på {0}" -f  $Mailbox.alias) -ForegroundColor Cyan
     Add-o365MailboxFolderPermission $Mailbox.alias -User conciergemobile -AccessRights foldervisible -ErrorAction SilentlyContinue
     Set-o365mailboxfolderpermission $Mailbox.alias -User conciergemobile -AccessRights foldervisible
     Add-o365MailboxFolderPermission -Identity ($path) -User ConciergeMobile -AccessRights Editor -ErrorAction SilentlyContinue
     Set-o365mailboxfolderpermission -identity ($path) -User ConciergeMobile -AccessRights Editor
     Start-Sleep -milliseconds 800
     
}

#*******************************************************************************************************************************************************************************

<#
#Run on one praricular user
$allmailbox = Get-o365Mailbox mran
$MailCalenderPath = $allmailbox.alias + ":\Kalender"
Write-Host "Sætter standard sprog til DK" -foregroundcolor Cyan 
Set-o365MailboxRegionalConfiguration –identity $allmailbox.alias –language da-dk -LocalizeDefaultFolderName
get-o365MailboxFolderPermission $allmailbox.alias
Add-o365MailboxFolderPermission $allmailbox.alias -User conciergemobile -AccessRights foldervisible
Set-o365mailboxfolderpermission $allmailbox.alias -User conciergemobile -AccessRights foldervisible
Add-o365MailboxFolderPermission -Identity $MailCalenderPath -User ConciergeMobile -AccessRights Editor
Set-o365mailboxfolderpermission -identity $MailCalenderPath -User ConciergeMobile -AccessRights Editor

# get list of users from content only initials
$allmailbox = Get-Content .\CSV\conusererrors.txt |  get-o365Mailbox
Foreach ($Mailbox in $allmailbox) 
{   
     #reconnect office 365 session to avoid connectivetty and exparation issues.
     Get-PSSession  | ?{$_.ComputerName -like "*.outlook.com"} | Remove-PSSession
     $Global:sessiono365 = New-PSSession -ConfigurationName Microsoft.Exchange -Authentication Basic -ConnectionUri https://ps.outlook.com/powershell -AllowRedirection:$true -Credential $Global:credo365
     Import-PSSession $Global:sessiono365 -Prefix o365 -AllowClobber
     Connect-MsolService -Credential $Global:credo365

     Add-o365MailboxFolderPermission $Mailbox.alias -User conciergemobile -AccessRights foldervisible -ErrorAction SilentlyContinue
     Set-o365mailboxfolderpermission $Mailbox.alias -User conciergemobile -AccessRights foldervisible
     $path = $Mailbox.alias + ":\" + (Get-o365MailboxFolderStatistics $Mailbox.alias | Where-Object { $_.Foldertype -eq "Calendar" }).Name
     #org: $path = $Mailbox.alias + ":\" + (Get-o365MailboxFolderStatistics $Mailbox.alias | Where-Object { $_.Foldertype -eq "Calendar" } | Select-Object -First 1).Name
     #$pathRUFR = "rufr" + ":\" + (Get-o365MailboxFolderStatistics rufr | ? { $_.Foldertype -eq "Calendar"}).Name
     #Set-o365mailboxfolderpermission -identity ($path) -user Default -Accessrights LimitedDetails
     Write-host -Object $("Udfører handling på {0}" -f  $Mailbox.alias) -ForegroundColor Cyan
     Add-o365MailboxFolderPermission -Identity ($path) -User ConciergeMobile -AccessRights Editor -ErrorAction SilentlyContinue
     Set-o365mailboxfolderpermission -identity ($path) -User ConciergeMobile -AccessRights Editor
     Start-Sleep -milliseconds 800
     
}

#>
