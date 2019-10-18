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
Write-Host "Du har valgt Mass convert and RemoveLicens" -ForegroundColor Gray -BackgroundColor DarkCyan
#*********************************************************************************************************************************************
#Script
#*********************************************************************************************************************************************
#variabler
#$OUPathForExchangeSikkerhedsgrupperSSI = 'OU=ResourceGroups,OU=Exchange,OU=Groups,OU=SSI,DC=SSI,DC=ad'
$OUPathSharedMailSSI = 'OU=Faelles postkasser,OU=Ressourcer,DC=SSI,DC=ad'
$OUPathSharedMailSSI_ikke_type = 'OU=Faelles postkasser ikke type shared,OU=Ressourcer,DC=SSI,DC=ad'

#$OUPathForExchangeSikkerhedsgrupperSDS = 'OU=Exchange Sikkerhedsgrupper,OU=Sundhedsdatastyrelsen,OU=Ressourcer,DC=SSI,DC=ad'
$OUPathSharedMailSDS = 'OU=Faelles postkasser,OU=Sundhedsdatastyrelsen,OU=Ressourcer,DC=SSI,DC=ad'
$OUPathSharedMailSDS_ikke_type  = 'OU=Faelles postkasser ikke type shared,OU=Sundhedsdatastyrelsen,OU=Ressourcer,DC=SSI,DC=ad'

#ssi.ad/Ressourcer/Equipment
$OUPathEquipmentSSI = 'OU=Equipment,OU=Ressourcer,DC=SSI,DC=ad'
#ssi.ad/Ressourcer/Rooms
$OUPathRoomsSSI = 'OU=Rooms,OU=Ressourcer,DC=SSI,DC=ad'

#dksund.dk/Organisationer/SSI/SSI Migrated Equipment
$OUPathEquipmentDKSUND = 'OU=SSI Migrated Equipment,OU=SSI,OU=Organisationer,DC=dksund,DC=dk'

 

#login til  Office 365 og session.
$credo365 = Get-Credential adm-rufr@dksund.onmicrosoft.com
$sessiono365 = New-PSSession -ConfigurationName Microsoft.Exchange -Authentication Basic -ConnectionUri https://ps.outlook.com/powershell -AllowRedirection:$true -Credential $credo365
Import-PSSession $sessiono365 -Prefix o365
Connect-MsolService -Credential $credo365


# Get content and convert to Room.
$Rooms  = Get-Content C:\RUFR_PowerShell\_UnderUdvikling\CSV\Emails_Rooms.txt | Set-o365Mailbox -Type room

#Get content and convert to Equipment
$Equipment  = Get-Content C:\RUFR_PowerShell\_UnderUdvikling\CSV\Emails_Equipment.txt | Set-o365Mailbox -Type Equipment

#Get content and convert to SharedMails
$SharedMails = Get-Content C:\RUFR_PowerShell\_UnderUdvikling\CSV\Emails_shared.txt | Set-o365Mailbox -Type shared
$SharedMails.Count



#Get all licens
Get-MSOLUser -All | select userprincipalname,islicensed,{$_.Licenses.AccountSkuId}| ogv

# get Licens Value for: $AccountSkuId and then remove Licens
$AccountSkuId = (Get-MsolUser -UserPrincipalName rufr@dksund.dk  ).Licenses[0].AccountSkuId
$UsageLocation = (Get-MsolUser -UserPrincipalName rufr@dksund.dk ).UsageLocation 

Get-MsolUser -UserPrincipalName "rufr@dksund.dk" |gm |ogv





#remove Licens
$Rooms = Get-Content C:\RUFR_PowerShell\_UnderUdvikling\CSV\Emails_Rooms.txt 
$Rooms | ForEach-Object {
Set-MsolUser -UserPrincipalName $_ -UsageLocation $UsageLocation
Set-MsolUserLicense -UserPrincipalName $_ -RemoveLicenses $AccountSkuId
}



#remove Licens
$Equipment  = Get-Content C:\RUFR_PowerShell\_UnderUdvikling\CSV\Emails_Equipment.txt
$Equipment | ForEach-Object {
Set-MsolUser -UserPrincipalName $_ -UsageLocation $UsageLocation
Set-MsolUserLicense -UserPrincipalName $_ -RemoveLicenses $AccountSkuId
}


#remove Licens
$SharedMails = Get-Content C:\RUFR_PowerShell\_UnderUdvikling\CSV\Emails_shared.txt
$SharedMails.Count
$SharedMails | ForEach-Object {
Set-MsolUser -UserPrincipalName $_ -UsageLocation $UsageLocation
Set-MsolUserLicense -UserPrincipalName $_ -RemoveLicenses $AccountSkuId
}



#(Get-MsolUser -UserPrincipalName Ultimate01@dksund.dk ).Licenses[0].AccountSkuId



<# get spevifik info
($Room  = Get-Content C:\RUFR_PowerShell\_UnderUdvikling\CSV\Emails_Rooms.txt )  | get-o365Mailbox | select UserPrincipalName, RecipientTypeDetails | Out-File C:\RUFR_PowerShell\_UnderUdvikling\Emails_Rooms1.txt
($Equipment  = Get-Content C:\RUFR_PowerShell\_UnderUdvikling\CSV\Emails_Equipment.txt)   | get-o365Mailbox | select UserPrincipalName, RecipientTypeDetails | Out-File C:\RUFR_PowerShell\_UnderUdvikling\Emails_Equipment1.txt

#Count:
($Equipment  = Get-Content C:\RUFR_PowerShell\_UnderUdvikling\CSV\Emails_Equipment.txt).count
($Room  = Get-Content C:\RUFR_PowerShell\_UnderUdvikling\CSV\Emails_Rooms.txt ).count
$Equipment.Count
$Room.Count
#>



