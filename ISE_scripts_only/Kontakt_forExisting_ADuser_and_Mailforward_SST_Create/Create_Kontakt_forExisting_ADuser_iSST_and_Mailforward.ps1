#PSVersion 5 Script made/assembled by Rust@m 02-05-2018
<#Login RUFR all AD login, Hybrid and o365
$CommandPath = (Get-Location).Path | Split-Path -Parent; $script = "$CommandPath\Logins\Login_SSI_SST_exch2010_DKSUND_Exchange365_RUFR.ps1"; & $script

#Login RUFR only office365
Import-Module MSOnline
$Global:credo365 = Get-Credential adm-rufr@dksund.onmicrosoft.com -Message "login til  Office 365"
$Global:sessiono365 = New-PSSession -ConfigurationName Microsoft.Exchange -Authentication Basic -ConnectionUri https://ps.outlook.com/powershell -AllowRedirection:$true  -Credential $Global:credo365
Import-PSSession $Global:sessiono365 -Prefix o365 -AllowClobber
Connect-MsolService -Credential $Global:credo365
cls
#>

#*********************************************************************************************************************************************
#Function progressbar for timeout by ctigeek:
function Start-Sleep($seconds) {
    $doneDT = (Get-Date).AddSeconds($seconds)
    while($doneDT -gt (Get-Date)) {
        $secondsLeft = $doneDT.Subtract((Get-Date)).TotalSeconds
        $percent = ($seconds - $secondsLeft) / $seconds * 100
        Write-Progress -Activity "Sleeping" -Status "Sleeping..." -SecondsRemaining $secondsLeft -PercentComplete $percent
        [System.Threading.Thread]::Sleep(500)
    }
    Write-Progress -Activity "Sleeping" -Status "Sleeping..." -SecondsRemaining 0 -Completed
}
#*********************************************************************************************************************************************
#*********************************************************************************************************************************************
#LOGIN
#*********************************************************************************************************************************************
#SST AD login og import af AD modulet.
$UserCredSST = Get-Credential sst.dk\adm-rufr

#exchange 2010
$Exchange2010_SST = "S-EXC-MBX01-P.sst.dk"

$SessionExchangeSST= New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://S-EXC-MBX01-P.sst.dk/PowerShell/ -Authentication Kerberos -Credential $UserCredSST
Import-PSSession $SessionExchangeSST -Prefix SST
#Write-Verbose "Loading the Exchange snapin (module)"
Add-PSSnapin Microsoft.Exchange.Management.PowerShell.E2010 -ErrorAction SilentlyContinu

sleep 4
#*********************************************************************************************************************************************
#Activer Directory Modules import
#*********************************************************************************************************************************************
Import-Module -Name ActiveDirectory 
#Remove-Module -Name ActiveDirectory

#*********************************************************************************************************************************************
#Discover Domain Controllers
#*********************************************************************************************************************************************
Write-Host "Finder SSI, SST og DKSUND Domain Controllere" -foregroundcolor Yellow
#$ServerNameSST = "dc01.sst.dk"
$ServerNameSST = (Get-ADDomainController -DomainName sst.dk -Discover -NextClosestSite).HostName

#*********************************************************************************************************************************************
#PS driver creattion
#*********************************************************************************************************************************************
#PSdrive AD to SST
#PSdrive blev oprettet ved login script, som er ikke en del af den her execution.
Write-Host " Opretter PSdrive til SST AD" -foregroundcolor Cyan
if (-not(Get-PSDrive 'SSTAD' -ErrorAction SilentlyContinue)) {
    New-PSDrive –Name 'SSTAD' –PSProvider ActiveDirectory –Server "$ServerNameSST" -Credential $UserCredSST –Root '//RootDSE/' -Scope Global
    #alternativet creds: –Credential $(Get-Credential -Message 'Enter Password' -UserName 'SST.DK\adm-RUFR') 
     
} Else {
    Write-Output -InputObject "PSDrive SSTAD already exists"
}


#Set-Location -Path 'SSTAD:'


cls

<# get OU? 

#AD
$User = "depAFF"
$aduserinfo = Get-ADUser -Identity "$User" -Properties Canonicalname
$Oupath = ($aduserinfo.DistinguishedName -split “,”, 2)[1]
$Oupath


#Exchange 2010
$email = "aff@sum.dk"
$aduserinfo = (Get-ExchSSTMailbox -Identity "$email").DistinguishedName 
$Oupath = ($aduserinfo -split “,”, 2)[1]
$Oupath

#se more: http://www.oxfordsbsguy.com/2015/05/06/exchange-powershell-how-to-bulk-import-create-mail-contacts/
# Create 1 mailcontact:
Set-Location -Path 'SSTAD:'
New-SSTMailContact -Name “Rustam Frusts” -Alias "SSIRUFR" -tel  -ExternalEmailAddress “rufr@live.dk” -OrganizationalUnit "Koncern HR" 



$impCSV = Import-CSV C:\RUFR_PowerShell\_UnderUdvikling\CSV\MailContacts2.csv  -Delimiter ";"
$impCSV.Count
Import-CSV C:\RUFR_PowerShell\_UnderUdvikling\CSV\MailContacts2.csv  -Delimiter ";"| foreach { Get-SSTMailbox -Identity $_.InternalEmails | select name, RecipientTypeDetails}
Import-CSV C:\RUFR_PowerShell\_UnderUdvikling\CSV\MailContacts_1.csv  -Delimiter ";" | foreach { Get-SSTMailbox  $_.name}
$impCSV.InternalEmails
$impCSV.ExternalEmailAddress
$impCSV.OU
$impCSV.Name
$impCSV.Alias

#>

cls


#bulck import and crate mailcontact 
Import-CSV C:\RUFR_PowerShell\ISE_scripts_only\Create_Kontakt_forExisting_ADuser_and_Mailforward_SST\MailContacts_1.csv  -Delimiter ";" 
Import-CSV C:\RUFR_PowerShell\ISE_scripts_only\Create_Kontakt_forExisting_ADuser_and_Mailforward_SST\MailContacts2.csv  -Delimiter ";" | ForEach-Object {New-SSTMailContact -Name $_.Name  -Alias $_.Alias -ExternalEmailAddress $_.ExternalEmailAddress -OrganizationalUnit $_.OU -WhatIf;}
Import-CSV C:\RUFR_PowerShell\ISE_scripts_only\Create_Kontakt_forExisting_ADuser_and_Mailforward_SST\MailContacts2.csv  -Delimiter ";" | ForEach-Object {New-SSTMailContact -Name $_.Name  -Alias $_.Alias -ExternalEmailAddress $_.ExternalEmailAddress -OrganizationalUnit $_.OU}
#Import-CSV C:\RUFR_PowerShell\ISE_scripts_only\Create_Kontakt_forExisting_ADuser_and_Mailforward_SST\MailContacts2.csv  -Delimiter ";" | ForEach-Object {$_.name +" SSI"} 




#forward from internal to external emails example:
#Set-Mailbox -Identity "Douglas Kohn" -DeliverToMailboxAndForward $true -ForwardingSMTPAddress "douglaskohn.parents@fineartschool.net" 

#bulck Forward emails from internal to external emails

$impCSV = Import-CSV C:\RUFR_PowerShell\ISE_scripts_only\Create_Kontakt_forExisting_ADuser_and_Mailforward_SST\MailContacts_1.csv -Delimiter ";"
ForEach($email in $impCSV)
{
    Set-SSTMailbox $email.InternalEmails -ForwardingAddress $email.ExternalEmailAddress -DeliverToMailboxAndForward $true
}



