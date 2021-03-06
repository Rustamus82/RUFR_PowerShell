﻿Write-Host "Reconnecting to Hybrid Exchange ON Premises i DKSUND" -foregroundcolor Cyan 
#DKSUND AD login og session til Exchange ON Premises (Hvis installeret opdatering KB3134758  giver fejl ved forbindelse til HybridServere.)
Get-PSSession  | ?{$_.ComputerName -like "s-exc-hyb*"} | Remove-PSSession
#$Global:SessionHyb = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://s-exc-hyb-02p.dksund.dk/PowerShell/ -Authentication Kerberos -SessionOption $Global:PSSessionOption -Credential $Global:UserCredDksund
$Global:SessionHyb = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://s-exc-hyb-01p.dksund.dk/PowerShell/ -Authentication Kerberos -SessionOption $Global:PSSessionOption -Credential $Global:UserCredDksund
Import-PSSession $Global:SessionHyb -Prefix SSI -AllowClobber


Write-Host "Reconnecting to Lync server i SSI" -foregroundcolor Cyan 
#reconnect Lync servere session to avoid connectivetty and exparation issues.
Get-PSSession | ?{$_.ComputerName -like "SRV-LYNC-FE0*"} | Remove-PSSession
$Global:sessionLync = New-PSSession -ConnectionURI “https://srv-Lync-FE03.SSI.AD/OcsPowershell” -Credential $Global:UserCredSSI -SessionOption $Global:sessionOptionLync
Import-PSSession $Global:sessionLync -Prefix LYNC -AllowClobber 

Write-Host "reconnect Office 365 session i skyen" -foregroundcolor Cyan 
#reconnect office 365 session to avoid connectivetty and exparation issues.
Get-PSSession  | ?{$_.ComputerName -like "*.outlook.com"} | Remove-PSSession
$Global:sessiono365 = New-PSSession -ConfigurationName Microsoft.Exchange -Authentication Basic -ConnectionUri https://ps.outlook.com/powershell -AllowRedirection:$true -Credential $Global:credo365
Import-PSSession $Global:sessiono365 -Prefix o365 -AllowClobber
Connect-MsolService -Credential $Global:credo365
