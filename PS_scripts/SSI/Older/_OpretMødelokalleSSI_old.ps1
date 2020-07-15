#PSVersion 5 Script made/assembled by Rust@m 13-07-2017
Write-Host "Du har valgt OpretMødelokalleSSI.ps1" -ForegroundColor Gray -BackgroundColor DarkCyan
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
#script
#*********************************************************************************************************************************************
$userDisplayName = Read-Host -Prompt "Tast Displayname på mødelokale eksempel: (202-213 Mødelokale)"
[string]$ADuser =  Read-Host -Prompt "Tast 'Alias' på nyt mødelokaleminimum 5 og max 20 karaktere, Må IKKE indeholde: mellemrum, komma, ÆØÅ / \ (eksempel: 202-213)"
$Manager =  Read-Host -Prompt "Angiv Ejers INITIALER på Mødelokalle/sikkerhedsgruppen"
$Capacity =  Read-Host -Prompt "Tast 'antal' personer for Kapacitet af mødeloaket. Skriv tal:"

$OUpathRoomSSI = 'OU=Rooms,OU=Ressourcer,DC=ssi,DC=ad'
#$OUpathEquipmentSSI = 'OU=Equipment,OU=Ressourcer,DC=ssi,DC=ad'

$OUPathForExchangeSikkerhedsgrupperSSI = 'OU=ResourceGroups,OU=Exchange,OU=Groups,OU=SSI,DC=SSI,DC=ad'
#$OUPathSharedMailSSI = 'OU=Faelles postkasser,OU=Ressourcer,DC=SSI,DC=ad'

#$OUPathForExchangeSikkerhedsgrupperSDS = 'OU=Exchange Sikkerhedsgrupper,OU=Sundhedsdatastyrelsen,OU=Ressourcer,DC=SSI,DC=ad'
#$OUPathSharedMailSDS = 'OU=Faelles postkasser,OU=Sundhedsdatastyrelsen,OU=Ressourcer,DC=SSI,DC=ad'

$ADuserDescription = 'Mødelokale'
$ExchangeSikkerhedsgruppe = 'GRP-'+$ADuser
Write-Host "Sikkerhedsgruppe bliver til $ExchangeSikkerhedsgruppe" -ForegroundColor Yellow

#$company = "1"
#Read-Host "Tast 1 for @ssi.dk eller 2 for @sundhedsdata.dk for den nye postkasse"
$SikkerhedsgrupperDescription = "Giver fuld adgang til Mødelokalle $ADuser"


#Check for illegal characters - legal are a-zA-Z0-9-_.  also check for aloowed lenght from 5 to 20
if($ADuser -match '[^a-zA-Z0-9\-_\.]' -or $ADuser.Length -lt 5 -or $ADuser.Length -gt 20){

    Write-Host "Whoops --> You have used illegal characters in email alias!" -foregroundcolor red
    Write-Host "Mødelokale ALIAS på minimum 5 og max 20 karaktere, Må IKKE indeholde: mellemrum, komma, ÆØÅ / \ (eksempel: 202-213):" -ForegroundColor Yellow
    Write-Host "Better luck next time, exiting script!" -ForegroundColor Cyan
    pause
    exit
}


Write-Host "Opretter AD objekt $ExchangeSikkerhedsgruppe i SSI AD" -foregroundcolor Cyan
Set-Location -Path 'SSIAD:'
New-ADGroup -Name $ExchangeSikkerhedsgruppe -GroupScope Universal -GroupCategory Security -ManagedBy $Manager -Description $SikkerhedsgrupperDescription -Path $OUPathForExchangeSikkerhedsgrupperSSI
   
Write-Host "TimeOut for 20 sek." -foregroundcolor Yellow 
Start-Sleep 20

Write-Host "Tilføjer $Manager til gruppen $ExchangeSikkerhedsgruppe medlemskab." -foregroundcolor Cyan
Add-ADGroupMember -Identity $ExchangeSikkerhedsgruppe -Members $Manager 

#Opdatere 'Company' felt for ExchangeSikkerhedsgrupper og email
if ([bool](Get-ADGroup -Filter  {Name -eq $ExchangeSikkerhedsgruppe}))
{
  #Set-ADGroup -Identity $GroupName -Clear Company
  Write-Host "Opdaterer 'Company' felt og tilføje  email adresse til gruppen" -foregroundcolor Cyan
  $GroupMail = $ExchangeSikkerhedsgruppe+'@ssi.dk'
  Set-ADGroup -Identity $ExchangeSikkerhedsgruppe -Add @{company="Statens Serum Institut";mail="$GroupMail"}
}
Else
{
    Write-Warning "Mislykkedes opdatere 'Company' felt for $ExchangeSikkerhedsgruppe fordi gruppen
    findes ikke i AD, eller der er ikke valgt korrekt 'Company' værdi." -ErrorAction Stop
}

Start-Sleep 6

Write-Host "Opretter Mødedelokale $ADuser objekt i SSI AD." -foregroundcolor Cyan
New-ADUser -Name $ADuser -DisplayName $userDisplayName -GivenName $ADuserDescription -Manager $Manager -Description $ADuserDescription -UserPrincipalName (“{0}@{1}” -f $ADuser,”ssi.dk”) -ChangePasswordAtLogon $true -Path $OUpathRoomSSI

Write-Host "time out 2 min (Synkroniserer i AD)" -foregroundcolor Yellow 
Start-Sleep 120


if ([bool](Get-ADuser -Filter  {Name -eq $ADuser}))
{
   Write-Host "Tilføje 'samaccount' (email) felt for $ADuser i SSI AD." -foregroundcolor Cyan
   Set-ADUser $ADuser -SamAccountName $ADuser -EmailAddress $ADuser'@ssi.dk' -Company 'Statens Serum Institut' 
    
}
Else
{
    Write-Warning "Mislykkedes at tilføje 'samaccount' (email) felt for ad user $ADuser i SSI AD."
}

#new added, need to see it works...?!
Write-Host "Omdøber bruger..." -foregroundcolor Cyan
    Get-ADUser -Identity $ADuser | Rename-ADObject -NewName "$userDisplayName"
    Start-Sleep 6


#Venter Synkronisering til DKSUND
Write-Host "Time out 3 timer. venter til konti synkroniseret til DKSUND" -foregroundcolor Yellow 
Start-Sleep 10800

Write-Host "Skifter til DKSUND AD" -foregroundcolor Yellow
Set-Location -Path 'DKSUNDAD:'

Write-Host "Connecting to Sessions" -ForegroundColor Magenta
$reconnect =  $PSScriptRoot | Split-Path -Parent | Split-Path -Parent; Invoke-Expression "$reconnect\Logins\Session_reconnect.ps1"

Write-Host "E-Mail aktivering af $ExchangeSikkerhedsgruppe i Exchange 2016" -foregroundcolor Cyan
if ([bool](Get-ADGroup -Filter  {SamAccountName -eq $ExchangeSikkerhedsgruppe}))
{
    Enable-SSIDistributionGroup -Identity $ExchangeSikkerhedsgruppe
    #Disable-SSIDistributionGroup -Identity $ExchangeSikkerhedsgruppe
    $new = $ExchangeSikkerhedsgruppe + "@ssi.dk"
    Write-Host "Disabled email politik på Exchange 2016 $ExchangeSikkerhedsgruppe" -foregroundcolor Cyan
    Set-SSIDistributionGroup $ExchangeSikkerhedsgruppe -PrimarySMTPAddress $new -EmailAddressPolicyEnabled $false
        
}
Else
{
    Write-Warning "Kunne ikke e-mail aktivere $ExchangeSikkerhedsgruppe, da gruppen muligvis ikke findes i DKSUND/Exchange 2016, eller noget gik  galt." -ErrorAction Stop
}

Write-Host "Connecting to Sessions" -ForegroundColor Magenta
$reconnect =  $PSScriptRoot | Split-Path -Parent | Split-Path -Parent; Invoke-Expression "$reconnect\Logins\Session_reconnect.ps1"


Write-Host "Forsøger at E-Mail aktivere Mødelokalle på Exchange 2016" -foregroundcolor Cyan       
if ([bool](Get-ADuser -Filter  {SamAccountName -eq $ADuser})) {
    #$RemoteMail = $ADuser+'@dksund.mail.onmicrosoft.com'
    Enable-SSIRemoteMailbox $ADuser -RemoteRoutingAddress  "$ADuser@dksund.mail.onmicrosoft.com"
    #Disable-ssiRemoteMailbox $ADuser
    Write-Host "Time Out 1 min..."  -foregroundcolor Yellow  
    Start-Sleep 60
    #som resultat vil den være synlig på Exchnage 2016 onprem men ikke i Offic365 , da den ikke endnu har en licens.
}
Else { Write-Warning "Misslykedes at E-Mail aktivere Mødelokalle/Bruger: $ADuser, noget gik galt..." }


Write-Host "Connecting to Sessions" -ForegroundColor Magenta
$reconnect =  $PSScriptRoot | Split-Path -Parent | Split-Path -Parent; Invoke-Expression "$reconnect\Logins\Session_reconnect.ps1"


Write-Host "Tildeler licens for $ADuser" -foregroundcolor Cyan
if ([bool](Get-ADuser -Filter  {SamAccountName -eq $ADuser})) {
		 
    #Write-Host "Tilføjer $ADuser til  gruppen 'O365_E5STD_U' medlemskab." -foregroundcolor Cyan
    #Add-ADGroupMember -Identity 'O365_E5STD_U' -Members  $ADuser -ErrorAction SilentlyContinue
    Set-MsolUser -UserPrincipalName "$ADuser@dksund.dk" -UsageLocation DK
    Set-MsolUserLicense -UserPrincipalName "$ADuser@dksund.dk" -AddLicenses dksund:STANDARDPACK
    #$x = New-MsolLicenseOptions -AccountSkuId "dksund:ENTERPRISEPREMIUM" -DisabledPlans "PROJECTWORKMANAGEMENT","YAMMER_ENTERPRISE","MCOSTANDARD","SHAREPOINTWAC", "SWAY", "RMS_S_ENTERPRISE"
    #Set-MsolUserLicense -UserPrincipalName "$ADuser@dksund.dk" -LicenseOptions $x
    Write-Host "Time out 16 min..." -foregroundcolor Yellow 
    Start-Sleep 960
}
Else { Write-Warning "Tjek om det er korrekt Mødelokalle/bruger, da den ikke kunne findes og Licens kunne ikke tildeles" }


Write-Host "Connecting to Sessions" -ForegroundColor Magenta
$reconnect =  $PSScriptRoot | Split-Path -Parent | Split-Path -Parent; Invoke-Expression "$reconnect\Logins\Session_reconnect.ps1"


Write-Host "Deaktiverer Clutter..." -foregroundcolor Cyan 
Get-Mailbox $ADuser | set-Clutter -Enable $false


Write-Host "Tilføjer sikkerhedsgruppe $ExchangeSikkerhedsgruppe som 'FUll access & Send As' på $ADuser" -foregroundcolor Cyan     
if ([bool](Get-ADuser -Filter  {SamAccountName -eq $ADuser})) {
     
     Get-Mailbox -identity $ADuser | add-mailboxpermission -user $ExchangeSikkerhedsgruppe -accessrights FullAccess -inheritancetype All
     Add-recipientPermission $ADuser -AccessRights SendAs -Trustee $ExchangeSikkerhedsgruppe -Confirm:$false
     Set-Mailbox -Identity $ADuser -GrantSendOnBehalfTo $ExchangeSikkerhedsgruppe
}
Else { write-host "Mislykkedes at tilknytte sikkerhedsgruppe: $ExchangeSikkerhedsgruppe adgang til Mødelokalle: $ADuser..." }
           

Write-Host "Connecting to Sessions" -ForegroundColor Magenta
$reconnect =  $PSScriptRoot | Split-Path -Parent | Split-Path -Parent; Invoke-Expression "$reconnect\Logins\Session_reconnect.ps1"


Write-Host "Konverterer postkasse $ADuser til type Room og sætter kapacitet til: $Capacity" -foregroundcolor Cyan 
Set-Mailbox -Identity "$ADuser@dksund.onmicrosoft.com" -Type room -ResourceCapacity $Capacity
Set-Mailbox -Identity $ADuser -Type room -ResourceCapacity $Capacity

#Get-Mailbox $ADuser | fl

Write-Host "Connecting to Sessions" -ForegroundColor Magenta
$reconnect =  $PSScriptRoot | Split-Path -Parent | Split-Path -Parent; Invoke-Expression "$reconnect\Logins\Session_reconnect.ps1"

#Write-Host "Opretter reggel at Mail som er sendt fra shared postkasse, bliver lagt 2 steder, nemlig i sendt items hos bruger og i selve Mødelokalle." -foregroundcolor Cyan 
#Set-Mailbox $ADuser -MessageCopyForSentAsEnabled $True 

Write-Host "Sætter standard sprog til DK" -foregroundcolor Cyan 
Set-MailboxRegionalConfiguration –identity $ADuser –language da-dk -LocalizeDefaultFolderName

Start-Sleep 120
Write-Host "Connecting to Sessions" -ForegroundColor Magenta
$reconnect =  $PSScriptRoot | Split-Path -Parent | Split-Path -Parent; Invoke-Expression "$reconnect\Logins\Session_reconnect.ps1"


Write-Host "Ændre kalender rettighed af $ADuser til LimitedDetails " -foregroundcolor Cyan 
$ADuserCalenderPath = "$ADuser" + ":\Kalender"
Set-mailboxfolderpermission –identity $ADuserCalenderPath –user Default –Accessrights LimitedDetails
Add-MailboxFolderPermission –Identity $ADuserCalenderPath –User ConciergeMobile –AccessRights Editor
Add-MailboxFolderPermission $ADuser -User conciergemobile -AccessRights foldervisible -ErrorAction SilentlyContinue
Get-MailboxFolderPermission -Identity $ADuserCalenderPath

Write-Host "time out 20 min..." -foregroundcolor Yellow 
Start-Sleep 1200

Write-Host "Fjerner Licensen fra $ADuser, da den nu blevet konverteret til type 'shared' Mødelokalle..." -foregroundcolor Cyan 
#Get-MsolUser -UserPrincipalName $ADuser@dksund.dk |Select-Object UserPrincipalName, DisplayName, Department, {$_.Licenses.AccountSkuId}, WhenCreated
#Remove-ADGroupMember -Identity 'O365_E5STD_U' -Members $ADuser -ErrorAction SilentlyContinue -Confirm:$false -Credential $Global:UserCredDksund
$MSOLSKU = (Get-MsolUser -UserPrincipalName "$ADuser@dksund.dk").Licenses.AccountSkuId
Set-MsolUserLicense -UserPrincipalName "$ADuser@dksund.dk" -RemoveLicenses $MSOLSKU


Write-Host "Time out 5 min..." -foregroundcolor Yellow 
Start-Sleep 300

Write-Host "Connecting to Sessions" -ForegroundColor Magenta
$reconnect =  $PSScriptRoot | Split-Path -Parent | Split-Path -Parent; Invoke-Expression "$reconnect\Logins\Session_reconnect.ps1"


Write-Host "Obs!" -foregroundcolor Yellow -backgroundcolor DarkCyan
Write-Host "Husk at sætte hak i Manager må godt opdatere medlemskabsliste på sikkerhedsgruppe $ExchangeSikkerhedsgruppe, da dette kan ikke automatiseres pt. !!!!" -foregroundcolor Yellow -backgroundcolor DarkCyan
Write-Host "Husk at oprette Mødelokalle $ResultRoom i Conciegre system, hvis den skulle bookes derfra..." -foregroundcolor Yellow -backgroundcolor DarkCyan
Write-Host
Write-Host "Noter følgende i Nilex løsningsbeksrivelse:" -foregroundcolor Yellow -backgroundcolor DarkCyan
$ResultMailboxType = (Get-Mailbox $ADuser).RecipientTypeDetails
Write-Host "Postkasse type: $ResultMailboxType" -foregroundcolor Green -backgroundcolor DarkCyan
$ResultRoom = (Get-Mailbox $ADuser).PrimarySmtpAddress
Write-Host "Mødelokalle oprettet: $ResultRoom" -foregroundcolor Green -backgroundcolor DarkCyan
$ResultGroup = (Get-Group $ExchangeSikkerhedsgruppe).WindowsEmailAddress
Write-Host "Tilhørende sikkerhedsgruppe oprettet: $ResultGroup" -foregroundcolor Green -backgroundcolor DarkCyan
Write-Host "Oprettet i Conciegre system?: Ja/Nej" -foregroundcolor Green -backgroundcolor DarkCyan
Write-Host "Kapacitet: $Capacity" -foregroundcolor Green -backgroundcolor DarkCyan
Write-Host "Ejer: $Manager" -foregroundcolor Green -backgroundcolor DarkCyan
Pause




