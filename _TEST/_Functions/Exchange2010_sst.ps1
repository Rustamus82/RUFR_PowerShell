#exchange 2010

$Exchange2010_SST = "S-EXC-MBX01-P.sst.dk"

$SessionExchangeSST= New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://S-EXC-MBX01-P.sst.dk/PowerShell/ -Authentication Kerberos -Credential sst.dk\adm-rufr
Import-PSSession $SessionExchangeSST
#Write-Verbose "Loading the Exchange snapin (module)"
Add-PSSnapin Microsoft.Exchange.Management.PowerShell.E2010 -ErrorAction SilentlyContinu

#Get-Mailbox adm-rufr | fl
