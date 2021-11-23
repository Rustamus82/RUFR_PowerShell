#PSVersion 5 Script made/assembled by Rust@m 02-05-2018
#LinkedMailBox_SST_STPS_DEP_NGC_DKETIK
<#Login RUFR all AD login, Hybrid and o365
$CommandPath = (Get-Location).Path | Split-Path -Parent; $script = "$CommandPath\Logins\Login_SSI_SST_exch2010_DKSUND_Exchange365_RUFR.ps1"; & $script

#Login RUFR only office365
Import-Module MSOnline
$Global:credo365 = Get-Credential adm-rufr@dksund.onmicrosoft.com -Message "login til  Office 365"
$Global:sessiono365 = New-PSSession -ConfigurationName Microsoft.Exchange -Authentication Basic -ConnectionUri https://ps.outlook.com/powershell -AllowRedirection:$true  -Credential $Global:credo365
Import-PSSession $Global:sessiono365 -Prefix o365 -AllowClobber
Connect-MsolService -Credential $Global:credo365
cls

SST:
#Exchange 2016 SST
$Global:SessionExchangeSST = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri 'http://s-exc-mbx02-p/PowerShell/' -Authentication Kerberos -Credential $Global:UserCredSST
#$Global:SessionExchangeSST = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri 'http://s-exc-mbx03-p/PowerShell/' -Authentication Kerberos -Credential $Global:UserCredSST
Import-PSSession $Global:SessionExchangeSST -Prefix SST
#>

#Exchange 2010
#Add-PSSnapin Microsoft.Exchange.Management.PowerShell.E2010

#Exchange 2013 & 2016
#Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn


#Exchange 2016 SST
#SST AD login og import af AD modulet.
$Global:UserCredSST = Get-Credential "sst.dk\adm-rufr" -Message "SST AD login og import af AD modulet"
$Global:SessionExchangeSST = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri 'http://s-exc-mbx02-p/PowerShell/' -Authentication Kerberos -Credential $Global:UserCredSST
#$Global:SessionExchangeSST = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri 'http://s-exc-mbx03-p/PowerShell/' -Authentication Kerberos -Credential $Global:UserCredSST
Import-PSSession $Global:SessionExchangeSST -AllowClobber

Import-Module activedirectory

#remove linked account:
#Set-user KMLR -LinkedMasterAccount $null
 
Get-user DEPAKBO | fl name, Linkedmasteraccount

Set-user KMLR -LinkedMasterAccount dksund\KMLR -LinkedDomainController s-ad-dc-01p.dksund.dk

Enable-ADAccount -Identity KMLR
 
#Get-user -ResultSize unlimited | ft name, Linkedmasteraccount  