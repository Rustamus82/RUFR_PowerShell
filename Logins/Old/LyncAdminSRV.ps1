$cred = Get-Credential “ssi\adm-rufr” 
$sessionOption = New-PSSessionOption -SkipCACheck -SkipRevocationCheck -SkipCNCheck
$session = New-PSSession -ConnectionURI “https://srv-Lync-FE05.SSI.AD/OcsPowershell” -Credential $cred -SessionOption $sessionOption
Import-PSSession $session -Prefix SSI -AllowClobber  
Get-SSICsUser 
