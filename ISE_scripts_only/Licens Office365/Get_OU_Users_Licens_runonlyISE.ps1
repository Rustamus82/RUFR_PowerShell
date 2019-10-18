<#Script made/assembled by Rust@m 14-05-2019
##Login RUFR all AD login, Hybrid and o365
$CommandPath = (Get-Location).Path | Split-Path -Parent|Split-Path -Parent; $script = "$CommandPath\Logins\Login_SSI_SST_exch2010_DKSUND_Exchange365_RUFR.ps1"; & $script

#Requires -Version 5 - $PSVersionTable

#Login RUFR only office365
Import-Module MSOnline
$Global:credo365 = Get-Credential adm-rufr@dksund.onmicrosoft.com -Message "login til  Office 365"
$Global:sessiono365 = New-PSSession -ConfigurationName Microsoft.Exchange -Authentication Basic -ConnectionUri https://ps.outlook.com/powershell -AllowRedirection:$true  -Credential $Global:credo365
Import-PSSession $Global:sessiono365 -Prefix o365 -AllowClobber
Connect-MsolService -Credential $Global:credo365
cls
#>

#*********************************************************************************************************************************************
Write-Host "Du har valgt at se licens for users i specifik ou" -ForegroundColor Gray -BackgroundColor DarkCyan
#*********************************************************************************************************************************************
#Script
#*********************************************************************************************************************************************
#Fællespostkasser
$OUPathSharedMailSSI = 'OU=Faelles postkasser,OU=Ressourcer,DC=SSI,DC=ad'
$OUPathSharedMailSSI_ikke_type = 'OU=Faelles postkasser ikke type shared,OU=Ressourcer,DC=SSI,DC=ad'
$OUPathSharedMailSDS = 'OU=Faelles postkasser,OU=Sundhedsdatastyrelsen,OU=Ressourcer,DC=SSI,DC=ad'
$OUPathSharedMailSDS_ikke_type  = 'OU=Faelles postkasser ikke type shared,OU=Sundhedsdatastyrelsen,OU=Ressourcer,DC=SSI,DC=ad'

#ssi.ad/Ressourcer/Equipment
$OUPathEquipmentSSI = 'OU=Equipment,OU=Ressourcer,DC=SSI,DC=ad'

#ssi.ad/Ressourcer/Rooms
$OUPathRoomsSSI = 'OU=Rooms,OU=Ressourcer,DC=SSI,DC=ad'

#dksund.dk/Organisationer/SSI/SSI Migrated Equipment
$OUPathEquipmentDKSUND = 'OU=SSI Migrated Equipment,OU=SSI,OU=Organisationer,DC=dksund,DC=dk'

#dksund.dk/Organisationer/STPK/Brugere/
$OUPathSTPKUsers = 'OU=Brugere,OU=STPK,OU=Organisationer,DC=dksund,DC=dk'

#opret forbindelse til domæner og PSdrivers via login
<#Get-PSDrive
Set-Location -Path 'SSIAD:' 
Set-Location -Path 'SSTAD:'
Set-Location -Path 'DKSUNDAD:' 
#>

#Get all Users in specified OU and get licens SSI.
#Count:
(Get-ADUser -SearchBase "$OUPathSharedMailSSI_ikke_type" -Filter *).count

$ResultQuery = (Get-ADUser -SearchBase "$OUPathSharedMailSSI_ikke_type" -Filter * -Properties mailNickname |foreach{$_.mailNickname + "@dksund.dk"} )

$ResultLicensedUsers = Foreach ($aduser in $ResultQuery) 
{   
     
     #Write-host -Object $("Udfører handling på {0}" -f  $ADuser) -ForegroundColor Cyan
     
     Get-MSOLUser -UserPrincipalName $ADuser |  Where-Object { $_.isLicensed -eq $true } | Select-Object UserPrincipalName, DisplayName, Department, {$_.Licenses.AccountSkuId}, isLicensed, WhenCreated 
     
     
}; $ResultLicensedUsers |ogv

#Count:
(Get-ADUser -SearchBase "$OUPathSharedMailSSI" -Filter *).count

$ResultQuery = (Get-ADUser -SearchBase "$OUPathSharedMailSSI" -Filter * -Properties mailNickname |foreach{$_.mailNickname + "@dksund.dk"} )

$ResultLicensedUsers = Foreach ($aduser in $ResultQuery) 
{   
     
     #Write-host -Object $("Udfører handling på {0}" -f  $ADuser) -ForegroundColor Cyan
     
     Get-MSOLUser -UserPrincipalName $ADuser |  Where-Object { $_.isLicensed -eq $true } | Select-Object UserPrincipalName, DisplayName, Department, {$_.Licenses.AccountSkuId}, isLicensed, WhenCreated 
     
     
}; $ResultLicensedUsers |ogv


#Get All users in specified OU and get linces for STPK
#Count:
(Get-ADUser -SearchBase "$OUPathSTPKUsers" -Filter * ).count
$ResultQuery = (Get-ADUser -SearchBase "$OUPathSTPKUsers" -Filter * )

$ResultLicensedUsers = Foreach ($aduser in $ResultQuery) 
{   
     
     #Write-host -Object $("Udfører handling på {0}" -f  $ADuser) -ForegroundColor Cyan
     
     Get-MSOLUser -UserPrincipalName $ADuser.UserPrincipalName |  Where-Object { $_.isLicensed -eq $true } | Select-Object UserPrincipalName, DisplayName, Department, {$_.Licenses.AccountSkuId}, isLicensed, WhenCreated 
     
     
}; $ResultLicensedUsers |ogv


#Get licensed users 
Get-MSOLUser -All | Where-Object { $_.isLicensed -eq $true } | Select-Object UserPrincipalName, DisplayName, Department, {$_.Licenses.AccountSkuId}, isLicensed, WhenCreated |  Export-CSV C:\RUFR_PowerShell_v1.23\Logs\LicensedUsers.csv -NoTypeInformation -Encoding UTF8
Get-MSOLUser -All | Where-Object { $_.isLicensed -eq $true } | Select-Object UserPrincipalName, DisplayName, Department, {$_.Licenses.AccountSkuId}, isLicensed, WhenCreated | ogv
get-MSOLUser -All | where {$_.isLicensed -eq "TRUE" -and $_.Licenses.AccountSKUID } | select UserPrincipalName, DisplayName, Department, {$_.Licenses.AccountSkuId}, Licensesd, isLicense | ogv



# Get all Users in specified OU and get licens SDS.
#Count:
(Get-ADUser -SearchBase "$OUPathSharedMailSDS" -Filter * | select SamAccountName).count

(Get-ADUser -SearchBase "$OUPathSharedMailSDS" -Filter * | select SamAccountName)
