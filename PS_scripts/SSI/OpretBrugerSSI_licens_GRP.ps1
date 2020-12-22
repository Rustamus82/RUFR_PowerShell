#PSVersion 5 Script made/assembled by Rust@m 13-07-2017
cls; Write-Host "Du har valgt OpretBrugerSSI.ps1" -ForegroundColor Gray -BackgroundColor DarkCyan
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
#***************************************************************************
#script execution 
#***************************************************************************
#Variabler
$ADuser = Read-Host -Prompt "Tast Initialer for Bruger, som skal oprettes:"
$UPN = "$ADuser@ssi.dk"

Write-Host "Angivet Bruger værdi: ""$ADuser"" for SSI/SDS oprettelse script" -foregroundcolor Yellow

<# G drev kopiering som aftalt kopiere vi ikke mere.... for vi mener det ikke bliver brugt.
Write-Host "Kopiere skabeloner til G drev" -foregroundcolor Cyan
Set-Location $PSScriptRoot
$GdriverPath = "\\msfc-gvs\gvl\$ADuser"
Copy-Item "\\msfc-pvs\pvl\install\stdpc\gdrev\*"  "$GdriverPath" -Recurse -Force -Verbose
#>

Write-Host "Skifter til SSI AD." -foregroundcolor Cyan  
Set-Location -Path 'SSIAD:'

Write-Host "Checker om ADobjekt findes i Azure" -foregroundcolor Yellow
IF([bool](Get-AzureADUser -Filter "MailNickName eq '$ADuser'"))
{   
    $ADSeaerch = Get-ADUser $ADuser -Properties Canonicalname | Select-Object CanonicalName
    Write-Host "Bruger findes i AD:" -foregroundcolor Green
    Write-Host  $ADSeaerch.CanonicalName -foregroundcolor Green

    Write-Host "Tilføjer $ADuser til Distributionsliste Concierge_MOB medlemskab." -foregroundcolor Cyan
    Add-ADGroupMember -Identity 'Concierge_MOB'  $ADuser
} 
else { 
    
    Write-Host "Objekt $ADuser Findes ikke i Azure, script skifter til hoved menu" -foregroundcolor red
    & "$PSScriptRoot\BrugeradmSDmenu.ps1"
} 


Write-Host "Skifter til DKSUND AD." -foregroundcolor Cyan   
Set-Location -Path 'DKSUNDAD:'


Write-Host "Tilføjer Kintra rettigheder i DKSUND AD." -foregroundcolor Cyan 
if ([bool](Get-ADuser -Filter  {SamAccountName -eq $ADuser})){
    
    
    If ((Get-ADUser $ADuser -Properties *).Company  -eq 'Statens Serum Institut'){
    (Get-ADUser $ADuser -Properties * | Select-Object Company)
    Add-ADGroupMember -Identity kintra_g_KoncernHR_site-visitor_r $ADuser
    Add-ADGroupMember -Identity kintra_g_KoncernIT_site-visitor_r $ADuser
    Add-ADGroupMember -Identity kintra_g_SSI_site-visitor_r $ADuser
    Add-ADGroupMember -Identity kintra_g_SSI_site-visitor_w $ADuser
    Add-ADGroupMember -Identity Concierge_MOB $ADuser
    }
    elseif((Get-ADUser $ADuser -Properties *).Company  -eq 'Sundhedsdatastyrelsen') {
    (Get-ADUser $ADuser -Properties * | Select-Object Company)
    Add-ADGroupMember -Identity kintra_g_KoncernHR_site-visitor_r $ADuser
	Add-ADGroupMember -Identity kintra_g_KoncernIT_driftsstatus-member_w $ADuser
	Add-ADGroupMember -Identity kintra_g_KoncernIT_site-visitor_r $ADuser
	Add-ADGroupMember -Identity kintra_g_SDS_site-visitor_r $ADuser
    Add-ADGroupMember -Identity Concierge_MOB $ADuser
    Add-ADGroupMember -Identity CM_G_DKS_CM-Users-r $ADuser
    }

}
Else { Write-Warning "Mislykkedes at Tildele Kintra Privilegier, bruger muligvis findes ikke i DKSUND AD, skifter til hoved menu"; & "$PSScriptRoot\BrugeradmSDmenu.ps1"}


Write-Host "Forsøger at E-Mail aktivere fællesposkasse $ADuser på Exchange 2016" -foregroundcolor Cyan       
if ([bool](Get-ADuser -Filter  {SamAccountName -eq $ADuser}))
{
    Write-Host "Connecting to Sessions" -ForegroundColor Magenta
    $reconnect =  $PSScriptRoot | Split-Path -Parent | Split-Path -Parent; Invoke-Expression "$reconnect\Logins\Session_reconnect.ps1"
        
    Enable-SSIRemoteMailbox "$ADuser" -RemoteRoutingAddress "$ADuser@dksund.mail.onmicrosoft.com"
    Write-Host "Time Out 1 min..."  -foregroundcolor Yellow  
    Start-Sleep 60
    #som resultat vil den være synlig på Exchnage 2016 onprem men ikke i Offic365 , da den ikke endnu har en licens.
}
Else { Write-Warning "Fejlede at E-Mail aktivere fællespostkasse/bruger: $ADuser, skifter til hoved menu"; & "$PSScriptRoot\BrugeradmSDmenu.ps1"}


<## Direct Licens assignment
Write-Host "Tildeler licens for $ADuser" -foregroundcolor Cyan  
if ([bool](Get-ADuser -Filter  {SamAccountName -eq $ADuser}))
{
		
        #Write-Host "Tilføjer $ADuser til  gruppen 'O365_E5STD_U' medlemskab." -foregroundcolor Cyan
        #Add-ADGroupMember -Identity 'O365_E5STD_U' -Members  $ADuser -ErrorAction SilentlyContinue
        
        $x = New-MsolLicenseOptions -AccountSkuId "dksund:ENTERPRISEPREMIUM" -DisabledPlans "PROJECTWORKMANAGEMENT","YAMMER_ENTERPRISE","MCOSTANDARD","SHAREPOINTWAC", "SWAY", "RMS_S_ENTERPRISE"
 		Set-MsolUser -UserPrincipalName "$ADuser@dksund.dk" -UsageLocation DK
		#Set-MsolUserLicense -UserPrincipalName "$ADuser@dksund.dk" -AddLicenses dksund:WIN_DEF_ATP, dksund:ENTERPRISEPREMIUM, dksund:EMSPREMIUM
        Set-MsolUserLicense -UserPrincipalName "$ADuser@dksund.dk" -AddLicenses dksund:ENTERPRISEPREMIUM
		Set-MsolUserLicense -UserPrincipalName "$ADuser@dksund.dk" -LicenseOptions $x
        
        Write-Host "Time out 5 min..." -foregroundcolor Yellow 
        Start-Sleep 300
        #som resultat vil den være synlig i Offic365 , da den fik licens.
}
Else { Write-Warning "Bruger '$ADuser' kunne ikke findes i AD, tjek om det er korrekt fællespostkasse/bruger" }
##>

########################################
## Group based licens assignment OU dksund.dk/Tier2/T2Groups/AAD/
#$GroupLicensesOU = 'OU=AAD,OU=T2Groups,OU=Tier2,DC=dksund,DC=dk'
#(Get-ADGroup -SearchBase "$GroupLicensesOU" -Filter *).count

Write-Host "Vælger licens for Bruger $ADuser" -foregroundcolor Cyan 
$Licens = Get-ADGroup -filter {name -like "*M365_LIC_U_Full*"} -Properties *| select Name,Description | ogv -PassThru
#$GroupLicenses.Count
$LicensName = $Licens.Name
#$ADuser = "ssiprep"

Write-Host "Connecting to Sessions" -ForegroundColor Magenta
$reconnect =  $PSScriptRoot | Split-Path -Parent | Split-Path -Parent; Invoke-Expression "$reconnect\Logins\Session_reconnect.ps1"

#Remove-ADGroupMember -Identity ($Licens.Name) $ADuser -Confirm:$false
#Get-AzureADUser -ObjectId "$ADuser@dksund.dk"
$AzureUserObjectId = Get-AzureADUser -Filter "MailNickName eq '$ADuser'" | select ObjectId; $AzureUserObjectId.ObjectId
$AzureADGroupId = Get-AzureADGroup -SearchString ($Licens.Name) | select ObjectId; $AzureADGroupId.ObjectId
$AzureADGroupmember = Get-AzureADGroupMember -ObjectId ($AzureADGroupId.ObjectId)

do
   {
       
       Start-Sleep 120
       #Start-Sleep 3
       Write-Host "Connecting to Sessions" -ForegroundColor Magenta
       $reconnect =  $PSScriptRoot | Split-Path -Parent | Split-Path -Parent; Invoke-Expression "$reconnect\Logins\Session_reconnect.ps1"
       $i++
       IF([bool](Get-AzureADUser -Filter "MailNickName eq '$ADuser'"))
       {
           Write-Host "Tildeler Group based Licens for $ADuser forsøg $i" -foregroundcolor Cyan
           Add-ADGroupMember -Identity ($Licens.Name) $ADuser  -Verbose

       }
    
       if ($i -eq 67) {
       Write-Warning "Kunne ikke tildele licen til $ADuser, da den findes ikke i Exchange online."}
   }
   until ( ([bool]($AZmember.ObjectId) -contains ($AzureUserObjectId)) -or ($i -ge 67 ) )
#######################################

Write-Host "Connecting to Sessions" -ForegroundColor Magenta
$reconnect =  $PSScriptRoot | Split-Path -Parent | Split-Path -Parent; Invoke-Expression "$reconnect\Logins\Session_reconnect.ps1"


Write-Host "Enable Lync til Lync" -foregroundcolor Cyan 
Enable-LYNCCsUser -Identity $UPN -RegistrarPool 'pool02.ssi.ad' -SipAddressType SamAccountName -SipDomain ssi.dk; Start-Sleep 45

Write-Host "Client Policy set to 'KunADfoto' " -foregroundcolor Cyan 
Grant-LYNCCsClientPolicy -PolicyName 'KunADfoto' -Identity $UPN
#Get-LYNCCsClientPolicy; cls


Write-Host "Connecting to Sessions" -ForegroundColor Magenta
$reconnect =  $PSScriptRoot | Split-Path -Parent | Split-Path -Parent; Invoke-Expression "$reconnect\Logins\Session_reconnect.ps1"


Write-Host "Deaktiverer Clutter..." -foregroundcolor Cyan 
Get-Mailbox $ADuser | set-Clutter -Enable $false


#Write-Host "Sætter standard sprog til DK" -foregroundcolor Cyan 
Set-MailboxRegionalConfiguration –identity $ADuser –language da-dk -LocalizeDefaultFolderName


Start-Sleep 180
Write-Host "Connecting to Sessions" -ForegroundColor Magenta
$reconnect =  $PSScriptRoot | Split-Path -Parent | Split-Path -Parent; Invoke-Expression "$reconnect\Logins\Session_reconnect.ps1"


Write-Host "Ændre kalender rettighed for $ADuser til 'LimitedDetails' og tilføjer 'ConciergeMobile' som kalender 'editor' " -foregroundcolor Cyan 
$MailCalenderPath = "$ADuser" + ":\Kalender"
Set-mailboxfolderpermission –identity  $MailCalenderPath –user Default –Accessrights LimitedDetails
#Start-Sleep 1 
#Add-MailboxFolderPermission –Identity $MailCalenderPath –User ConciergeMobile –AccessRights Editor
#Start-Sleep 1 
#Add-MailboxFolderPermission $ADuser -User conciergemobile -AccessRights foldervisible -ErrorAction SilentlyContinue
#Start-Sleep 1 
#Set-MailboxFolderPermission $ADuser -User conciergemobile -AccessRights foldervisible -ErrorAction SilentlyContinue
Start-Sleep 1 
Get-MailboxFolderPermission -Identity $MailCalenderPath

Write-Host "Connecting to Sessions" -ForegroundColor Magenta
$reconnect =  $PSScriptRoot | Split-Path -Parent | Split-Path -Parent; Invoke-Expression "$reconnect\Logins\Session_reconnect.ps1"

Get-AzureADUser -ObjectId "$ADuser@dksund.dk" | select * 
$ResultADuser = Get-AzureADUser -ObjectId "$ADuser@dksund.dk" | select DisplayName, UserPrincipalName, mail, Mobile,TelephoneNumber 
$DisplayName = $ResultADuser.DisplayName
$UserPrincipalName = $ResultADuser.UserPrincipalName
$mail = $ResultADuser.mail
$Mobile = $ResultADuser.Mobile
$TelephoneNumber = $ResultADuser.TelephoneNumber
Write-Host "Noter følgende i ServiecNow løsningsbeksrivelse:" -foregroundcolor Yellow -backgroundcolor DarkCyan
#$ResultADuser = (Get-Mailbox "$ADuser").PrimarySmtpAddress
Set-Location -Path 'SSIAD:'
$ADSeaerch = Get-ADUser $ADuser -Properties Canonicalname | Select-Object CanonicalName 
$accountexpirationdate = Get-ADUser $ADuser -Properties * | select accountexpirationdate
$AccountExpiressi = $accountexpirationdate.accountexpirationdate
$CanonicalNameSSI = $ADSeaerch.CanonicalName
#Write-Host  $ADSeaerch.CanonicalName -foregroundcolor Green
Set-Location -Path 'DKSUNDAD:'
$ADSeaerch = Get-ADUser $ADuser -Properties Canonicalname | Select-Object CanonicalName
$CanonicalNameDKSUND = $ADSeaerch.CanonicalName
$accountexpirationdate = Get-ADUser $ADuser -Properties * | select accountexpirationdate
$AccountExpireDksund = $accountexpirationdate.accountexpirationdate
#Write-Host  $ADSeaerch.CanonicalName -foregroundcolor Green
Write-Host
Write-Host
#Write-Host "Bruger oprettet: $ResultADuser" -foregroundcolor Green -backgroundcolor DarkCyan

@"
Kære 

Ny medarbejder er nu oprettet.

Fulde Navn: $DisplayName
Medarbejderens konto loginnavn: $UserPrincipalName 
E-mail adresse: $mail

Organization placering i SSI AD: $CanonicalNameSSI
Udløbsdato: $AccountExpiressi

Organization placering i DKSUND AD: $CanonicalNameDKSUND
Udløbsdato: $AccountExpireDKSUND

Første gang medarbejderen logger på netværket:
Du skal skifte dit password første gang, du logger på nettet.
Dit første midlertidige password er:

Herefter bliver du bedst om at lave dit eget password. 

Hvis dit password ikke virker, skal du kontakte Servicedesk og bede om hjælp. 
Da dit password er strengt fortroligt, kan dine kolleger ikke gøre det på dine vegne.

Konto har fået tildelt følgende Lync tlf.: $TelephoneNumber
Registreret Mobil: $Mobile

IT velkomstbrev kan findes på Koncernnet - Koncern IT
https://dksund.sharepoint.com/sites/koncernnet/IT/Sider/velkomstbrev.aspx

Venlig hilsen
SDS Servicedesk 

"@

Pause

#Fejlfinding
#Get-Mailbox $ADuser | fl
#Get-ADGroup -Filter  {SamAccountName -eq 'samarbejdsogarbejdsmiljoeudvalget'} -Server $ServerNameDKSUND #http://stackoverflow.com/questions/6307127/hiding-errors-when-using-get-adgroup
#Get-ADGroup -Filter  {SamAccountName -eq 'samarbejdsogarbejdsmiljoeudvalget'} -Credential $UserCredDksund -AuthType Negotiate -Server $ServerNameDKSUND