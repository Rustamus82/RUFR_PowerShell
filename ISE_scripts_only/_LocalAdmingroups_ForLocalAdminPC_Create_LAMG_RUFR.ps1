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


#Hent nyeste inhold fra Lasses script (H:\SFNSI\DOSAFD\LocalAdminGroups) til lokalt sted C:\RUFR_PowerShell\PS_scripts\LocalAdminGroups\
Copy-Item \\s-inf-fil03p\hvl\SFNSI\IOSAFD\LocalAdminGroups\ .\ISE_scripts_only -recurse -Force -Verbose; sleep 3; cls


#login & importer AD modul cmdlets
# 1 Log på SSI
$credsSSI = Get-Credential -Message "Angiv brugernavn og password" -UserName ’ssi\adm-rufr’;Remove-Module -Name ActiveDirectory; Import-Module -Name ActiveDirectory 

# 1 Log på DKSUND
$credsDKsund = Get-Credential -Message "Angiv brugernavn og password" -UserName ’dksund\adm-rufr’ ;Remove-Module -Name ActiveDirectory; Import-Module -Name ActiveDirectory 

# 1 Log på SST
$credsSST = Get-Credential -Message "Angiv brugernavn og password" -UserName ’sst.dk\adm-rufr’ ;Remove-Module -Name ActiveDirectory; Import-Module -Name ActiveDirectory 


#********************************
 

# 2 En pc ad gangen - SSI
.\LocalAdminGroups\Create-LocaladminGroups.ps1 -DomainName SSI -UserName 'adm-smr' -ComputerName SSI000248 -Credential $CredsSSI

# 2 En pc ad gangen - DKSUND
.\LocalAdminGroups\Create-LocaladminGroups.ps1 -DomainName DKSUND -UserName 'adm_SSAT' -ComputerName SDS000694 -Credential $credsDKsund

# 2 En pc ad gangen - SST
.\LocalAdminGroups\Create-LocaladminGroups.ps1 -DomainName SST -UserName 'adm-asp' -ComputerName SST09902 -Credential $credsSST

cls
#********************************************** CSV ******************************************************************************************************************
# 3 åbn csv fil for redigering af korrekte domæn, adm-konto og pcnavn
.\LocalAdminGroups\LocalAdmins.csv

# 3 Flere PC på ad gang for SSI
.\LocalAdminGroups\Create-LocaladminGroups.ps1 -FilePath .\LocalAdminGroups\LocalAdmins.csv -Credential $CredsSSI

# 3 Flere PC på ad gang for DKSUND
.\LocalAdminGroups\Create-LocaladminGroups.ps1 -FilePath .\LocalAdminGroups\LocalAdmins.csv -Credential $credsDKsund

# 3 Flere PC på ad gang for SST
.\LocalAdminGroups\Create-LocaladminGroups.ps1 -FilePath .\LocalAdminGroups\LocalAdmins.csv -Credential $credsSST

#********************************************** se logs **************************************************************************************************************
# Locale gruppe skulle være her: sst.dk/Sikkerhedsgrupper/Local Administrator Groups
#Se logs her via stifinder/KØR: C:\Users\%username%\AppData\Local\Temp\Create-LocalAdminGroups.log
& "C:\Users\$([Environment]::UserName)\AppData\Local\Temp\Create-LocalAdminGroups.log"

cls