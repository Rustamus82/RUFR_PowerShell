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

#login til  Office 365 og session.
Import-Module MSOnline
# Save credential to a file
$Global:credo365 = Get-Credential adm-rufr@dksund.onmicrosoft.com #| Export-Clixml C:\RUFR_PowerShell\Logins\xml\adm-rufr_o365.xml
# Load credential
#$credo365 =  Import-Clixml C:\RUFR_PowerShell\Logins\xml\adm-rufr_o365.xml
#reconnect office 365 session to avoid connectivetty and exparation issues.
Get-PSSession  | ?{$_.ComputerName -like "*.outlook.com"} | Remove-PSSession
$sessiono365 = New-PSSession -ConfigurationName Microsoft.Exchange -Authentication Basic -ConnectionUri https://ps.outlook.com/powershell -AllowRedirection:$true -Credential $Global:credo365
Import-PSSession $sessiono365 -Prefix o365 -AllowClobber
Connect-MsolService -Credential $Global:credo365;cls


# ConciergeMobile get granted access to  alle Rooms mailbox Calendar right - Reviewer
#*******************************************************************************************************************************************************************************

#Get-o365Mailbox -ResultSize Unlimited | Where-Object { $_.RecipientTypeDetails -eq "UserMailbox" }| Select-Object WindowsEmailAddress,Identity , DisplayName | Export-CSV -delimiter ";" C:\RUFR_PowerShell\_UnderUdvikling\CSV\MailBoxes.csv -NoTypeInformation -Encoding UTF8
$allmailbox = Get-o365Mailbox -ResultSize Unlimited| Where-Object { $_.RecipientTypeDetails -eq "RoomMailbox" } 
#if want to export to list csv
$allmailbox | Where-Object { $_.RecipientTypeDetails -eq "RoomMailbox" }| Select-Object WindowsEmailAddress,Identity , DisplayName | Export-CSV -delimiter ";" "$WorkingDir\RoomMailbox.csv" -NoTypeInformation -Encoding UTF8
<#
$allmailbox.Count
$allmailbox.alias | Sort-Object -Descending
#>

Foreach ($Mailbox in $allmailbox)
{
     Connect-MsolService -Credential $Global:credo365
     $path = $Mailbox.alias + ":\" + (Get-o365MailboxFolderStatistics $Mailbox.alias | Where-Object { $_.Foldertype -eq "Calendar" }).Name
     #org: $path = $Mailbox.alias + ":\" + (Get-o365MailboxFolderStatistics $Mailbox.alias | Where-Object { $_.Foldertype -eq "Calendar" } | Select-Object -First 1).Name
     #$pathRUFR = "rufr" + ":\" + (Get-o365MailboxFolderStatistics rufr | ? { $_.Foldertype -eq "Calendar"}).Name
     #Set-o365mailboxfolderpermission –identity ($path) –user Default –Accessrights LimitedDetails
     Write-host -Object $("Udfører handling på {0}" -f  $Mailbox.alias) -ForegroundColor Cyan
     Add-o365MailboxFolderPermission $Mailbox.alias -User conciergemobile -AccessRights foldervisible -ErrorAction SilentlyContinue
     Set-o365mailboxfolderpermission $Mailbox.alias -User conciergemobile -AccessRights foldervisible
     Add-o365MailboxFolderPermission –Identity ($path) –User ConciergeMobile –AccessRights Editor -ErrorAction SilentlyContinue
     Set-o365mailboxfolderpermission –identity ($path) –User ConciergeMobile –AccessRights Editor
     Start-Sleep -milliseconds 800
     
}
#*******************************************************************************************************************************************************************************


<#
#Run on one praricular user
$allmailbox = Get-o365Mailbox 202-207
$MailCalenderPath = $allmailbox.alias + ":\Kalender"
Write-Host "Sætter standard sprog til DK" -foregroundcolor Cyan 
Set-o365MailboxRegionalConfiguration –identity $allmailbox.alias –language da-dk -LocalizeDefaultFolderName
get-o365MailboxFolderPermission $allmailbox.alias
Add-o365MailboxFolderPermission $allmailbox.alias -User conciergemobile -AccessRights foldervisible
Set-o365mailboxfolderpermission $allmailbox.alias -User conciergemobile -AccessRights foldervisible
Add-o365MailboxFolderPermission -Identity $MailCalenderPath -User ConciergeMobile -AccessRights Editor
Set-o365mailboxfolderpermission -identity $MailCalenderPath -User ConciergeMobile -AccessRights Editor

# get list of users from content only initials
$allmailbox = Get-Content .\CSV\roomserrors.txt  |  get-o365Mailbox
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


