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

#opret forbindelse til domæner og PSdrivers via login

#Variables
$OUpathRoomSSI = 'OU=Rooms,OU=Ressourcer,DC=ssi,DC=ad'
$OUpathEquipmentSSI = 'OU=Equipment,OU=Ressourcer,DC=ssi,DC=ad'


Set-Location -Path 'SSIAD:' 


# Get all rooms in specified OU update Rooms Family name to Mødelokale.
$RoomsSSI =  (Get-ADUser -SearchBase "$OUpathRoomSSI" -Filter * )| ForEach-Object { Write-host -Object $("Udfører handling på {0}" -f  $_.SamAccountName) -ForegroundColor Yellow; Set-ADUser $_ -Surname $null -GivenName "Mødelokale" }
#to clear Surname to NULL
#Set-ADUser rufr -Surname $null
#Count:
(Get-ADUser -SearchBase "$OUpathRoomSSI" -Filter *).count



# Get all groups in specified OU update Equipment Family name to Udstyr.
$EquipmentSSI =  (Get-ADUser -SearchBase "$OUpathEquipmentSSI" -Filter * )| ForEach-Object {Write-host -Object $("Udfører handling på {0}" -f  $_.SamAccountName) -ForegroundColor Yellow;Set-ADUser $_ -Surname $null -GivenName "Udstyr" }
#Count:
(Get-ADUser -SearchBase "$OUpathEquipmentSSI" -Filter *).count