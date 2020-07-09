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


#colores for write-host
[enum]::GetValues([System.ConsoleColor]) | Foreach-Object {Write-Host $_ -ForegroundColor $_ } 


#Filter ways to do
Get-ADuser -Filter  "sAMAccountName -eq 'rufr'"
Get-ADuser -Filter  {SamAccountName -eq "rufr"}
Get-ADUser rufr -Properties * | Select *


Write-Host "Skifter til DKSUND AD" -foregroundcolor Yellow
    Set-Location -Path 'DKSUNDAD:'

 $ADuser = "epiMRSA"
 Write-Host "Tildeler licens for $ADuser" -foregroundcolor Cyan  
    if ([bool](Get-ADuser -Filter  {SamAccountName -eq $ADuser}))
    {
		    $x = New-MsolLicenseOptions -AccountSkuId "dksund:ENTERPRISEPACK" -DisabledPlans "PROJECTWORKMANAGEMENT","YAMMER_ENTERPRISE","MCOSTANDARD","SHAREPOINTWAC", "OFFICESUBSCRIPTION", "SWAY", "RMS_S_ENTERPRISE"
 		    Set-MsolUser -UserPrincipalName "$ADuser@dksund.dk" -UsageLocation DK
		    Set-MsolUserLicense -UserPrincipalName "$ADuser@dksund.dk" -AddLicenses dksund:ENTERPRISEPACK
		    Set-MsolUserLicense -UserPrincipalName "$ADuser@dksund.dk" -LicenseOptions $x
        
            Write-Host "Time out 5 min..." -foregroundcolor Yellow 
            sleep 300
        
    }
    Else { Write-Warning "Bruger '$ADuser' kunne ikke findes i AD, tjek om det er korrekt fï¿½llespostkasse/bruger" }


#true or False - filter
if ([bool](Get-ADGroup -Filter  {SamAccountName -eq $ExchangeSikkerhedsgruppe}))  {}
if ([bool](Get-ADuser -Filter  {SamAccountName -eq $ADuser}))   {}


#view type of mailboxs - SSI
Get-o365Mailbox adm-rufr | select PrimarySmtpAddress,  RecipientTypeDetails, UsageLocation
Get-exoMailbox rufr | select PrimarySmtpAddress,  RecipientTypeDetails, UsageLocation

#convert to other type
Set-o365Mailbox 207-3-vku -Type Room
Set-o365Mailbox 207-3-vku -Type Equipment


Get-EXOMailbox rufr


#unhide from adresse book
Set-SSIRemoteMailbox  -Identity rufr -HiddenFromAddressListsEnabled $false
#hide from address book
Set-SSIRemoteMailbox  -Identity "adm-rufr@dksund.dk" -HiddenFromAddressListsEnabled $true

#coopy from one group member to other
Set-Location -Path 'SSIAD:' 
$GroupSource ="grp-tmp"
$GroupTarget ="GRP-kkdatabaser"

#get members
$GroupSourceMembers = Get-ADGroupMember "grp-tmp"
$GroupSourceMembers.SamAccountName |measure

#Add members
Add-ADGroupMember -Identity $GroupTarget -Member ($GroupSourceMembers.SamAccountName)

$Email = Get-o365Mailbox rufr | select PrimarySmtpAddress 

$Email.PrimarySmtpAddress

$Email = Get-o365Group 'RUFR test pære og æbler' | select WindowsEmailAddress
$Email.WindowsEmailAddress



$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $Global:UserCredDksund -Authentication Basic -AllowRedirection
Import-PSSession $Session




Write-Host "Opretter reggel at Mail som er sendt fra postkasse, bliver lagt 2 steder, nemlig i sendt items hos bruger og i selve fï¿½llespostkasse." -foregroundcolor Cyan 
$ADuser = 'testservicedesk@sundhedsdata.dk'
cls
Get-EXOMailbox -Identity $ADuser -PropertySets Delivery |fl Message*
#Get-EXOMailbox -Identity $ADuser -PropertySets All

Get-o365Mailbox -Identity $ADuser | FL message*

Set-Mailbox -Identity

Set-Mailbox -Identity $ADuser -MessageCopyForSendOnBehalfEnabled $true -MessageCopyForSentAsEnabled $true
Set-Mailbox -Identity $ADuser -MessageCopyForSendOnBehalfEnabled $false -MessageCopyForSentAsEnabled $false
Get-Mailbox -Identity $ADuser | FL message*

Write-Host "Opretter reggel at Mail som er sendt fra shared postkasse, bliver lagt 2 steder, nemlig i sendt items hos bruger og i selve fï¿½llespostkasse." -foregroundcolor Cyan 
Set-o365Mailbox $ADuser -MessageCopyForSentAsEnabled $True 


Add-PSSnapin Microsoft.Exchange.Management.PowerShell.E2010

Import-Module activedirectory

Get-user JMAD | fl name, Linkedmasteraccount

Set-user JMAD -LinkedMasterAccount dksund\JMAD -LinkedDomainController s-ad-dc-01p.dksund.dk

Enable-ADAccount -Identity JMAD

#Get-user -ResultSize unlimited | ft name, Linkedmasteraccount


#see and export from dynamic distribution liste
$dynamicgroup= Get-o365DynamicDistributionGroup SSI-Alle-Mailbokse

$dynamicgroup.RecipientContainer
$dynamicgroup.RecipientFilter

Get-o365Recipient -ResultSize Unlimited -RecipientPreviewFilter $dynamicgroup.RecipientFilter -OrganizationalUnit $dynamicgroup.RecipientContainer | Format-Table Name,Primary*

Get-o365Recipient -ResultSize Unlimited -RecipientPreviewFilter $dynamicgrou




#Import-Module exhcnage online & Azure AD
Import-Module ExchangeOnlineManagement

Import-Module AzureAD
$Global:UserCredDksund = Get-Credential adm-rufr@dksund.dk -Message "DKSUND AD login, Exchange Online & Hybrid"
Connect-ExchangeOnline -Credential $Global:UserCredDksund -ShowProgress $true -ShowBanner:$false
Connect-AzureAD -Credential $Global:UserCredDksund
#Connect-ExchangeOnlineShell -Credential $Global:UserCredDksund

get-command *exo*


IF([bool](Get-AzureADUser -SearchString "balalaika")){}

Get-SSIMailbox rufr