#PSVersion 5 Script made/assembled by Rust@m 02-05-2018
<#Login RUFR all AD login, Hybrid and o365
$CommandPath = (Get-Location).Path | Split-Path -Parent |Split-Path -Parent; $script = "$CommandPath\Logins\Login_SSI_SST_exch2010_DKSUND_Exchange365_RUFR.ps1"; & $script

#Login RUFR only office365
Import-Module MSOnline
$Global:credo365 = Get-Credential adm-rufr@dksund.onmicrosoft.com -Message "login til  Office 365"
$Global:sessiono365 = New-PSSession -ConfigurationName Microsoft.Exchange -Authentication Basic -ConnectionUri https://ps.outlook.com/powershell -AllowRedirection:$true  -Credential $Global:credo365
Import-PSSession $Global:sessiono365 -Prefix o365 -AllowClobber
Connect-MsolService -Credential $Global:credo365
$WorkingDir = Convert-Path .
cls
#>

Invoke-RestMethod "http://s-exccon-p.dksund.dk/reportingservice/api/servicestatus"

#user errors
$a = Invoke-RestMethod "http://s-exccon-p.dksund.dk/reportingservice/api/errors/meeting"
$CommandPath = (Get-Location).Path |Split-Path -Parent 
($a).smtp | Out-File $CommandPath\CSV\conusererrors.txt
[array]$allmailbox =  get-content $CommandPath\CSV\conusererrors.txt
$allmailbox.Count
cls



#rooms errors
Invoke-RestMethod "http://s-exccon-p.dksund.dk/reportingservice/api/errors/room"
$CommandPath = (Get-Location).Path |Split-Path -Parent
($a).smtp | Out-File $CommandPath\CSV\roomserrors.txt
[array]$allmailbox =  get-content $CommandPath\CSV\roomserrors.txt 
$allmailbox.Count
cls


#C:\Users\Concierge\AppData\Roaming\Fischer & Kerrn\Logs


# if want to export to list csv
Get-o365Mailbox -ResultSize Unlimited | Where-Object { $_.RecipientTypeDetails -eq "UserMailbox" }| Select-Object WindowsEmailAddress,Identity , DisplayName | Export-CSV -delimiter ";" C:\RUFR_PowerShell\_UnderUdvikling\CSV\MailBoxes.csv -NoTypeInformation -Encoding UTF8
$allmailbox | Where-Object { $_.RecipientTypeDetails -eq "UserMailbox" }| Select-Object WindowsEmailAddress,Identity , DisplayName | Export-CSV -delimiter ";" "$WorkingDir\MailBoxes.csv" -NoTypeInformation -Encoding UTF8
<#
$allmailbox.Count
$allmailbox.alias | Sort-Object -Descending
#>


#Get-o365Mailbox -ResultSize Unlimited | Where-Object { $_.RecipientTypeDetails -eq "UserMailbox" }| Select-Object WindowsEmailAddress,Identity , DisplayName | Export-CSV -delimiter ";" C:\RUFR_PowerShell\_UnderUdvikling\CSV\MailBoxes.csv -NoTypeInformation -Encoding UTF8
$allmailbox = Get-o365Mailbox -ResultSize Unlimited| Where-Object { $_.RecipientTypeDetails -eq "RoomMailbox" } 
#if want to export to list csv
$allmailbox | Where-Object { $_.RecipientTypeDetails -eq "RoomMailbox" }| Select-Object WindowsEmailAddress,Identity , DisplayName | Export-CSV -delimiter ";" "$WorkingDir\RoomMailbox.csv" -NoTypeInformation -Encoding UTF8
<#
$allmailbox.Count
$allmailbox.alias
#>