
#start powershell as admin and install following following:
#Legacy MSONLINE - msonline module deprecated
#Find-Module -Name "msonline*" | Install-Module

Find-Module -Name "Lync 2013*" | Install-Module
Find-Module -Name "Skype*" | Install-Module

#på server/PC hvor man magler psgallery: https://stackoverflow.com/questions/43323123/warning-unable-to-find-module-repositories
Get-PSRepository
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
Register-PSRepository -Default -Verbose
Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted
Get-PSRepository 
Get-Module -Name PowerShellGet
Update-Module -Name PowerShellGet

#ExchangeOnline
Find-Module -Name "ExchangeOnl*" | Install-Module
Install-Module -Name ExchangeOnlineManagement
Import-Module ExchangeOnlineManagement; Get-Module ExchangeOnlineManagement


#Install the PowerShellGet module for the first time or run your current version of the PowerShellGet module side-by-side with the latest version:
Install-Module PowershellGet -Force

#Update your existing version of the PowerShellGet module to the latest version
Update-Module -Name ExchangeOnlineManagement

#check
Get-InstalledModule -Name ExchangeOnline*
Import-Module ExchangeOnlineManagement; Get-Module ExchangeOnlineManagement

#In this example, modules with a name that starts with Msonline that are found by Find-Module in the online gallery are #installed to the default folder, C:\Program Files\WindowsPowerShell\Modules

<#----------------------------------------------------------------------------
We have released new management cmdlets which are faster and more reliable.

|--------------------------------------------------------------------------|
|    Old Cmdlets                    |    New/Reliable/Faster Cmdlets       |
|--------------------------------------------------------------------------|
|    Get-CASMailbox                 |    Get-EXOCASMailbox                 |
|    Get-Mailbox                    |    Get-EXOMailbox                    |
|    Get-MailboxFolderPermission    |    Get-EXOMailboxFolderPermission    |
|    Get-MailboxFolderStatistics    |    Get-EXOMailboxFolderStatistics    |
|    Get-MailboxPermission          |    Get-EXOMailboxPermission          |
|    Get-MailboxStatistics          |    Get-EXOMailboxStatistics          |
|    Get-MobileDeviceStatistics     |    Get-EXOMobileDeviceStatistics     |
|    Get-Recipient                  |    Get-EXORecipient                  |
|    Get-RecipientPermission        |    Get-EXORecipientPermission        |
|--------------------------------------------------------------------------|

To get additional information, run: Get-Help Connect-ExchangeOnline
Please send your feedback and suggestions to exocmdletpreview@service.microsoft.com
----------------------------------------------------------------------------#>


#Connect exchange online v2 mfa enabled
Connect-ExchangeOnline -UserPrincipalName adm-rufr@dksund.dk -ShowProgress $true
Connect-ExchangeOnline -UserPrincipalName adm-rufr@dksund.dk -ShowBanner:$false -ShowProgress $true

Get-EXOMailbox rufr
Get-Help Connect-ExchangeOnline
get-help Connect-ExchangeOnline -examples