# [‎27-‎03-‎2017 10:19] Jan Pries - GT: 

# https://technet.microsoft.com/da-dk/library/jj984289(v=exchg.160).aspx

$UserCredential = Get-Credential

$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection

Import-PSSession $Session 
