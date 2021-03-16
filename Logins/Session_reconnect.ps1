Write-Host "Reconnecting to Hybrid Exchange ON Premises i DKSUND" -foregroundcolor Cyan 
#DKSUND AD login og session til Exchange ON Premises (Hvis installeret opdatering KB3134758  giver fejl ved forbindelse til HybridServere.)
Get-PSSession  | Where-Object{$_.ComputerName -like "s-exc-hyb*"} | Remove-PSSession
#$Global:SessionHyb = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://s-exc-hyb-02p.dksund.dk/PowerShell/ -Authentication Kerberos -SessionOption $Global:PSSessionOption -Credential $Global:UserCredDksund
$Global:SessionHyb = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://s-exc-hyb-01p.dksund.dk/PowerShell/ -Authentication Kerberos -SessionOption $Global:PSSessionOption -Credential $Global:UserCredDksund
Import-PSSession $Global:SessionHyb -Prefix SSI -AllowClobber


#Exchange 2016 SST
Get-PSSession  | Where-Object{$_.ComputerName -like "s-exc-mbx0*"} | Remove-PSSession -ErrorAction SilentlyContinue
$Global:SessionExchangeSST = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri 'http://s-exc-mbx02-p/PowerShell/' -Authentication Kerberos -Credential $Global:UserCredSST
#$Global:SessionExchangeSST = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri 'http://s-exc-mbx03-p/PowerShell/' -Authentication Kerberos -Credential $Global:UserCredSST
Import-PSSession $Global:SessionExchangeSST -Prefix SST


Write-Host "Reconnecting to Lync server i SSI" -foregroundcolor Cyan 
#reconnect Lync servere session to avoid connectivetty and exparation issues.
Get-PSSession | Where-Object{$_.ComputerName -like "SRV-LYNC-FE0*"} | Remove-PSSession
#$Global:sessionLync = New-PSSession -ConnectionURI “https://srv-Lync-FE03.SSI.AD/OcsPowershell” -Credential $Global:UserCredSSI -SessionOption $Global:sessionOptionLync
$Global:sessionLync = New-PSSession -ConnectionURI "https://srv-lync-fe07.ssi.ad/OcsPowershell" -Credential $Global:UserCredSSI -SessionOption $Global:sessionOptionLync
#$Global:sessionLync = New-PSSession -ConnectionURI "https://srv-lync-fe08.ssi.ad/OcsPowershell" -Credential $Global:UserCredSSI -SessionOption $Global:sessionOptionLync -ErrorAction SilentlyContinue
Import-PSSession $Global:sessionLync -Prefix LYNC -AllowClobber -ErrorAction SilentlyContinue


Write-Host "reconnecting to ExchangeOnline session" -foregroundcolor Cyan
Get-PSSession | ?{$_.ComputerName -like "*office365.com"} | Remove-PSSession
Connect-ExchangeOnline -Credential $Global:UserCredDksund -ShowProgress $true -ShowBanner:$false
Connect-AzureAD -Credential $Global:UserCredDksund
Connect-MsolService -Credential $Global:UserCredDksund
#Get-PSSession | select name, ComputerName,state

<#
Write-Host "reconnect Office 365 session i skyen" -foregroundcolor Cyan 
#reconnect office 365 session to avoid connectivetty and exparation issues.
Get-PSSession  | ?{$_.ComputerName -like "*.outlook.com"} | Remove-PSSession
$Global:sessiono365 = New-PSSession -ConfigurationName Microsoft.Exchange -Authentication Basic -ConnectionUri https://ps.outlook.com/powershell -AllowRedirection:$true -Credential $Global:UserCredDksund
Import-PSSession $Global:sessiono365 -Prefix o365 -AllowClobber
Connect-MsolService -Credential $Global:UserCredDksund
#>