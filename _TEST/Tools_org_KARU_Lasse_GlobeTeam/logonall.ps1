Write-Host "Husk du får 2 logins."
Write-Host
Write-Host "Første login er til Hybrid server i DKSUND. Benyt dksund\<din adminkonto>"
Write-Host "Andet login er til Office365. Benyt <din adminkonto>@dksund.onmicrosoft.com"
Write-Host

#Set-ExecutionPolicy RemoteSigned
$UserCredential = Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://s-exc-hyb-01p.dksund.dk/PowerShell/ -Authentication Kerberos -Credential $UserCredential
Import-PSSession $session

$credo365 = Get-Credential
$sessiono365 = New-PSSession -ConfigurationName Microsoft.Exchange -Authentication Basic -ConnectionUri https://ps.outlook.com/powershell -AllowRedirection:$true -Credential $credo365
Import-PSSession $sessiono365 -Prefix o365
Connect-MsolService -Credential $credo365
