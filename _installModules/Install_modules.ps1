
#start powershell as admin and install following following:
#Legacy MSONLINE - msonline module deprecated
Find-Module -Name "msonline*" | Install-Module
Install-Module -Name "msonline" -Scope AllUsers -AllowClobber
Import-Module -Name "msonline"
Uninstall-Module -Name "msonline" -Force

Get-PSRepository 
#på server/PC hvor man magler psgallery: https://stackoverflow.com/questions/43323123/warning-unable-to-find-module-repositories
Get-PSRepository
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
Register-PSRepository -Default -Verbose
Get-PSRepository

#Install the PowerShellGet module for the first time or run your current version of the PowerShellGet module side-by-side with the latest version:
Install-Module PowershellGet -Force
Install-Module PowershellGet -Force -Scope AllUsers -AllowClobber
Get-Module -Name PowerShellGet
Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted;Get-PSRepository

#installer manuelt som admin MS sign in assistant:
#.\_installModules\Microsoft Online Services Sign-In Assistant
#https://www.microsoft.com/en-us/download/details.aspx?id=41950

#ExchangeOnline
Find-Module -Name "ExchangeOnl*" | Install-Module
Install-Module -Name "ExchangeOnlineManagement" -Scope AllUsers -AllowClobber
Install-Module -Name "ExchangeOnlineShell" -Scope AllUsers -AllowClobber 
Import-Module ExchangeOnlineManagement; Get-Module ExchangeOnlineManagement

Find-Module -Name "AzureAD" | Install-Module
Install-Module -Name "AzureAD" -Scope AllUsers -AllowClobber
Import-Module -Name "AzureAD"; Get-Module AzureAD


#Update your existing version of the PowerShellGet module to the latest version
Update-Module -Name ExchangeOnlineManagement
Update-Module -Name PowerShellGet
Update-Module -Name AzureAD
#Update-Module -Name msonline
#Update-Module -Name ActiveDirectory


#Import and check
Clear-Host
Get-InstalledModule
Import-Module ExchangeOnlineManagement; Get-Module ExchangeOnl*
Import-Module ExchangeOnlineShell; Get-Module ExchangeOnlineShell
Import-Module AzureAD; Get-Module AzureAD
Import-Module ActiveDirectory; Get-Module ActiveDirectory


#don't know if needed this is seems for a basic one:
$MFAExchangeModule = ((Get-ChildItem -Path $($env:LOCALAPPDATA+"\Apps\2.0\") -Filter CreateExoPSSession.ps1 -Recurse ).FullName | Select-Object -Last 1); "$MFAExchangeModule"
Import-Module "$MFAExchangeModule"

Clear-Host
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

#Load module:
#Import and check
Get-InstalledModule
Import-Module ExchangeOnlineManagement; Get-Module ExchangeOnl*
Import-Module ExchangeOnlineShell; Get-Module ExchangeOnlineShell
Import-Module AzureAD; Get-Module AzureAD

#Connect exchange online v2 mfa enabled
#Connect-ExchangeOnline -UserPrincipalName adm-rufr@dksund.dk -ShowProgress $true
Connect-ExchangeOnline -UserPrincipalName adm-rufr@dksund.dk -ShowBanner:$false -ShowProgress $true

#Get-PSSession | Remove-PSSession
Disconnect-ExchangeOnline
Get-EXOMailbox rufr
Get-Help Connect-ExchangeOnline
get-help Connect-ExchangeOnline -examples