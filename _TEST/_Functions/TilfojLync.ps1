# Peter Toldam, 02-11-12

# Import-Module activedirectory
Import-Module lync

cls
cd C:\scripts
$UPN = Read-Host “Angiv login-navn"
$UPN2=$UPN + "@ssi.dk"

Enable-CsUser -Identity $UPN2 -RegistrarPool "pool02.ssi.dk" -SipAddressType SamAccountName -SipDomain ssi.dk
start-sleep -s 15
write-host ........
start-sleep -s 15
write-host .........
start-sleep -s 15
write-host ".........  :-)"

# Set-CsUser -Identity $UPN2 –RemoteCallControlTelephonyEnabled $False –EnterpriseVoiceEnabled $False
Grant-CsClientPolicy -Identity $UPN2 -PolicyName  KunADfoto
