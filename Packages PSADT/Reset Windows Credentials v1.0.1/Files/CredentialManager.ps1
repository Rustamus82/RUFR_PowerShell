#Install-Module -Name CredentialManager
<#
Get-Command -Module CredentialManager
#Import-Module -Name CredentialManager
#>
#Remove-Module -Name CredentialManager
#Get-InstalledModule -Name CredentialManager | Uninstall-Module



$installdir =  (Get-Location).Path
Import-Module ((Get-ChildItem "$installdir" -Recurse -Filter "CredentialManager.psd1").FullName)

help Remove-StoredCredential -Detailed


$creds =  Get-StoredCredential -AsCredentialObject
$creds.Count
foreach ($item in $creds)
{
    $item.Type
    Remove-StoredCredential -Target $item.TargetName -ErrorAction SilentlyContinue
}

Remove-Module -Name CredentialManager -Force -ErrorAction SilentlyContinue