#PSVersion 5 Script made/assembled by Rust@m 10-07-2020
<#Login RUFR all AD login, Hybrid and EXO
$CommandPath = (Get-Location).Path | Split-Path -Parent; $script = "$CommandPath\Logins\Login_SSI_SST_exch2010_DKSUND_Exchange365_RUFR.ps1"; & $script

#Import-Module exhcnage online & Azure AD
Import-Module ExchangeOnlineManagement
Import-Module AzureAD
$Global:UserCredDksund = Get-Credential adm-rufr@dksund.dk -Message "DKSUND AD login, Exchange Online & Hybrid"
Connect-ExchangeOnline -Credential $Global:UserCredDksund -ShowProgress $true -ShowBanner:$false
Connect-AzureAD -Credential $Global:UserCredDksund
Connect-MsolService -Credential $Global:UserCredDksund
cls
#>


#colores for write-host
[enum]::GetValues([System.ConsoleColor]) | Foreach-Object {Write-Host $_ -ForegroundColor $_ } 


#Filter ways to do
Get-ADuser -Filter  "sAMAccountName -eq 'rufr'"
Get-ADuser -Filter  {SamAccountName -eq "rufr"}
Get-ADUser rufr -Properties * | Select-Object *

$MSOLSKU = (Get-MsolUser -UserPrincipalName "rufrsharedm_u@dksund.dk").Licenses.AccountSkuId

Write-Host "Skifter til DKSUND AD" -foregroundcolor Yellow
    Set-Location -Path 'DKSUNDAD:'

$ADuser = "rufrsharedm_u"
Write-Host "Tildeler licens for $ADuser" -foregroundcolor Cyan  
if ([bool](Get-ADuser -Filter  {SamAccountName -eq $ADuser}))
{
	    #$x = New-MsolLicenseOptions -AccountSkuId "dksund:ENTERPRISEPREMIUM" -DisabledPlans "PROJECTWORKMANAGEMENT","YAMMER_ENTERPRISE","MCOSTANDARD","SHAREPOINTWAC", "OFFICESUBSCRIPTION", "SWAY", "RMS_S_ENTERPRISE"
	    Set-MsolUser -UserPrincipalName "$ADuser@dksund.dk" -UsageLocation DK
	    Set-MsolUserLicense -UserPrincipalName "$ADuser@dksund.dk" -AddLicenses dksund:STANDARDPACK
	    #Set-MsolUserLicense -UserPrincipalName "$ADuser@dksund.dk" -LicenseOptions $x
    
        Write-Host "Time out 5 min..." -foregroundcolor Yellow 
        Start-Sleep 300
    
}
Else { Write-Warning "Bruger '$ADuser' kunne ikke findes i AD, tjek om det er korrekt f�llespostkasse/bruger" }


Write-host -Object $("Removing Licens for SharedMailBox User: {0}" -f  $ADuser) -ForegroundColor Cyan
#Remove-ADGroupMember -Identity 'O365_E5STD_U' -Members $ADuser -ErrorAction SilentlyContinue -Confirm:$false -Credential $Global:UserCredDksund
$MSOLSKU = (Get-MsolUser -UserPrincipalName "$ADuser@dksund.dk").Licenses.AccountSkuId
Set-MsolUserLicense -UserPrincipalName "$ADuser@dksund.dk" -RemoveLicenses $MSOLSKU


#true or False - filter
if ([bool](Get-ADGroup -Filter  {SamAccountName -eq $ExchangeSikkerhedsgruppe}))  {}
if ([bool](Get-ADuser -Filter  {SamAccountName -eq $ADuser}))   {}


#view type of mailboxs - SSI
Get-Mailbox adm-rufr | Select-Object PrimarySmtpAddress,  RecipientTypeDetails, UsageLocation
Get-exoMailbox afkh | Select-Object PrimarySmtpAddress,  RecipientTypeDetails, UsageLocation

#convert to other type
$ADuser = "rufrsharedm_u"
Set-Mailbox 207-3-vku -Type Room
Set-Mailbox 207-3-vku -Type Equipment

Set-Mailbox -Identity "$ADuser@dksund.onmicrosoft.com" -Type Shared

get-command *set*


#unhide from adresse book
Set-SSIRemoteMailbox  -Identity rufr -HiddenFromAddressListsEnabled $false
#hide from address book
Set-SSIRemoteMailbox  -Identity "adm-rufr@dksund.dk" -HiddenFromAddressListsEnabled $true

#coopy from one group member to other
Set-Location -Path 'SSIAD:' 
$GroupSource ="grp-tmp"
$GroupTarget ="GRP-kkdatabaser"

#get members
$GroupSourceMembers = Get-ADGroupMember $GroupSource
$GroupSourceMembers.SamAccountName |Measure-Object

#Add members
Add-ADGroupMember -Identity $GroupTarget -Member ($GroupSourceMembers.SamAccountName)

$Email = Get-Mailbox rufr | Select-Object PrimarySmtpAddress 

$Email.PrimarySmtpAddress

$Email = Get-Group 'RUFR test p�re og �bler' | Select-Object WindowsEmailAddress
$Email.WindowsEmailAddress



$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $Global:UserCredDksund -Authentication Basic -AllowRedirection
Import-PSSession $Session




Write-Host "Opretter reggel at Mail som er sendt fra postkasse, bliver lagt 2 steder, nemlig i sendt items hos bruger og i selve f�llespostkasse." -foregroundcolor Cyan 
$ADuser = 'testservicedesk@sundhedsdata.dk'
Clear-Host
Get-EXOMailbox -Identity $ADuser -PropertySets Delivery |Format-List Message*
#Get-EXOMailbox -Identity $ADuser -PropertySets All

Get-Mailbox -Identity $ADuser | Format-List message*

Set-Mailbox -Identity

Set-Mailbox -Identity $ADuser -MessageCopyForSendOnBehalfEnabled $true -MessageCopyForSentAsEnabled $true
Set-Mailbox -Identity $ADuser -MessageCopyForSendOnBehalfEnabled $false -MessageCopyForSentAsEnabled $false
Get-Mailbox -Identity $ADuser | Format-List message*

Write-Host "Opretter reggel at Mail som er sendt fra shared postkasse, bliver lagt 2 steder, nemlig i sendt items hos bruger og i selve f�llespostkasse." -foregroundcolor Cyan 
Set-Mailbox $ADuser -MessageCopyForSentAsEnabled $True 


Add-PSSnapin Microsoft.Exchange.Management.PowerShell.E2010

Import-Module activedirectory

Get-user JMAD | Format-List name, Linkedmasteraccount

Set-user JMAD -LinkedMasterAccount dksund\JMAD -LinkedDomainController s-ad-dc-01p.dksund.dk

Enable-ADAccount -Identity JMAD

#Get-user -ResultSize unlimited | ft name, Linkedmasteraccount


#see and export from dynamic distribution liste
$dynamicgroup= Get-DynamicDistributionGroup SSI-Alle-Mailbokse

$dynamicgroup.RecipientContainer
$dynamicgroup.RecipientFilter

Get-Recipient -ResultSize Unlimited -RecipientPreviewFilter $dynamicgroup.RecipientFilter -OrganizationalUnit $dynamicgroup.RecipientContainer | Format-Table Name,Primary*

Get-Recipient -ResultSize Unlimited -RecipientPreviewFilter $dynamicgrou



get-command *exo*
Clear-Host
$ADuser = "rufrsharedm_u"
$ADuser = "Nonexistent"
$ADgroup = "grp-rufrsharedm_u"

IF([bool](Get-AzureADUser -SearchString "$ADuser")){Write-Host "Found!"}
IF([bool](Get-AzureADUser -ObjectId "$ADuser@dksund.dk")){Write-Host "Found!"}
IF([bool](Get-AzureADGroup -SearchString "$ADgroup")){Write-Host "Found!"}
IF([bool](Get-AzureADGroup -Filter "DisplayName eq '$ADgroup'")){Write-Host "Found!"}

Get-AzureADUser -SearchString "$ADuser" | Select-Object -Property "*"
Get-AzureADGroup -SearchString "$ADgroup" | Select-Object -Property "*"

Get-AzureADGroup -Filter "DisplayName eq '$ADgroup'"
Get-AzureADGroup -Filter "DisplayName eq 'grp-rufrsharedm_u'"

Get-AzureADUser -SearchString "$ADuser"
Get-AzureADUser -Filter "MailNickName eq 'rufr'"

#azure & cloud if test
IF([bool](Get-AzureADUser -ObjectId "$ADuser@dksund.dk")){Write-Host "Found!"}
IF([bool](Get-AzureADUser -SearchString "balalaika")){}
IF([bool](Get-EXOMailbox  "$ADuser@dksund.dk")){Write-Host "Found!"}
IF([bool](Get-EXOMailbox  "Testcenter-IT")){Write-Host "Found!"}
IF([bool](Get-EXOMailbox  "balalajka")){Write-Host "Found!"}
IF([bool](Get-MSOLUser -UserPrincipalName "afkh@dksund.dk" |  Where-Object { $_.isLicensed -eq $true })){Write-Host "do something"}
IF([bool](Get-MSOLUser -UserPrincipalName "$ADuser@dksund.dk" |  Where-Object { $_.isLicensed -eq $true })){Write-Host "Do something"}

#ad if test
if ([bool](Get-ADuser -Filter  {SamAccountName -eq $ADuser})){Write-Host "Found!"}
