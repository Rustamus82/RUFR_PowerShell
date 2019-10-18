$cred = Get-Credential
$session = New-PSSession -ConfigurationName Microsoft.Exchange -Authentication Basic -ConnectionUri https://ps.outlook.com/powershell -AllowRedirection:$true -Credential $cred
Import-PSSession $session
Connect-MsolService
