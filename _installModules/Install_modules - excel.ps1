#start powershell as admin and install following following:
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




# improt excel module
Find-Module -Name "importexc*" | Install-Module
Install-Module -Name "ImportExcel" -Scope AllUsers -AllowClobber
Import-Module -Name "ImportExcel"
Uninstall-Module -Name "ImportExcel" -Force




# improt excel module
Find-Module -Name "importexc*" | Install-Module
Install-Module -Name "importexc*" -Scope AllUsers -AllowClobber
Install-Module -Name "importexc*" -Scope AllUsers -AllowClobber 
Import-Module ImportExcel; Get-Module ImportExcel 

Find-Module -Name "AzureAD" | Install-Module
Install-Module -Name "AzureAD" -Scope AllUsers -AllowClobber
Import-Module -Name "AzureAD"; Get-Module AzureAD


#Update your existing version of the PowerShellGet module to the latest version
Update-Module -Name ImportExcel
Update-Module -Name PowerShellGet
Update-Module -Name AzureAD
#Update-Module -Name msonline
#Update-Module -Name ActiveDirectory


#Import and check
Clear-Host
Get-InstalledModule
Import-Module ImportExcel; Get-Module ImportExcel