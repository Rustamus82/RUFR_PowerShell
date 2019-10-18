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


#Update Company for all groups in specifik OU
#Variables
#ssi.ad/SSI/Groups/Exchange/ResourceGroups
$OUPathForExchangeSikkerhedsgrupperSSI = 'OU=ResourceGroups,OU=Exchange,OU=Groups,OU=SSI,DC=SSI,DC=ad'

#ssi.ad/Ressourcer/Sundhedsdatastyrelsen/Exchange Sikkerhedsgrupper
$OUPathForExchangeSikkerhedsgrupperSDS = 'OU=Exchange Sikkerhedsgrupper,OU=Sundhedsdatastyrelsen,OU=Ressourcer,DC=SSI,DC=ad'

#dksund.dk/Organisationer/SSI/Mail-enabled Security Groups
$OUPathForExchangeSikkerhedsgrupperSSI = 'OU=Mail-enabled Security Groups,OU=SSI,OU=Organisationer,DC=dksund,DC=dk'

#opret forbindelse til domæner og PSdrivers via login
#Get-PSDrive
Set-Location -Path 'SSIAD:' 
Set-Location -Path 'SSTAD:'
Set-Location -Path 'DKSUNDAD:' 


# Get all groups in specified OU update company to SSI.
#Count:
(Get-ADGroup -SearchBase "$OUPathForExchangeSikkerhedsgrupperSSI" -Filter *).count

$GroupsSSI =  (Get-ADGroup -SearchBase "$OUPathForExchangeSikkerhedsgrupperSSI" -Filter * )| ForEach-Object {Set-ADGroup $_ -Add @{company="Statens Serum Institut"} }


# Get all groups in specified OU update company to SDS.
#Count:
(Get-ADGroup -SearchBase "$OUPathForExchangeSikkerhedsgrupperSDS" -Filter *).count

$GroupsSDS =  (Get-ADGroup -SearchBase "$OUPathForExchangeSikkerhedsgrupperSDS" -Filter * )| ForEach-Object {Set-ADGroup $_ -Add @{company="Sundhedsdatastyrelsen"} }
