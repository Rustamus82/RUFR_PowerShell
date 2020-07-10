#PSVersion 5 Script made/assembled by Rust@m 13-07-2017
Write-Host "Du har valgt OpretBrugerSSI.ps1" -ForegroundColor Gray -BackgroundColor DarkCyan
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

<# G drev kopiering som aftalt kopiere vi ikke mere.... for vi mener det ikke bliver brugt.
Write-Host "Kopiere skabeloner til G drev" -foregroundcolor Cyan
Set-Location $PSScriptRoot
$GdriverPath = "\\msfc-gvs\gvl\$ADuser"
Copy-Item "\\msfc-pvs\pvl\install\stdpc\gdrev\*"  "$GdriverPath" -Recurse -Force -Verbose
#>

Write-Host "Skifter til SSI AD." -foregroundcolor Cyan  
Set-Location -Path 'SSIAD:'

Write-Host "Checker om ADobjekt findes i forvejen...." -foregroundcolor Cyan
if ([bool](Get-ADUser -Filter  {SamAccountName -eq $ADuser})) 
{   
    $ADSeaerch = Get-ADUser $ADuser -Properties Canonicalname | Select-Object CanonicalName
    Write-Host "Bruger findes i AD:" -foregroundcolor Green
    Write-Host  $ADSeaerch.CanonicalName -foregroundcolor Green

    Write-Host "Tilføjer $ADuser til Distributionsliste Concierge_MOB medlemskab." -foregroundcolor Cyan
    Add-ADGroupMember -Identity 'Concierge_MOB'  $ADuser
} 
else { 
    
    Write-Host "Objekt $ADuser Findes ikke i AD eller konto i forvejen mailenablet, script afsluttes" -foregroundcolor red
    pause
    exit
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
Else { Write-Warning "Mislykkedes at Tildele Kintra Privilegier, bruger muligvis findes ikke i DKSUND AD"}


Write-Host "Connecting to Sessions" -ForegroundColor Magenta
$reconnect =  $PSScriptRoot | Split-Path -Parent | Split-Path -Parent; Invoke-Expression "$reconnect\Logins\Session_reconnect.ps1"


Write-Host "Forsøger at E-Mail aktivere fællesposkasse $ADuser på Exchange 2016" -foregroundcolor Cyan       
if ([bool](Get-ADuser -Filter  {SamAccountName -eq $ADuser}))
{
    Enable-SSIRemoteMailbox "$ADuser" -RemoteRoutingAddress "$ADuser@dksund.mail.onmicrosoft.com"
    Write-Host "Time Out 1 min..."  -foregroundcolor Yellow  
    Start-Sleep 60
    #som resultat vil den være synlig på Exchnage 2016 onprem men ikke i Offic365 , da den ikke endnu har en licens.
}
Else { Write-Warning "Fejlede at E-Mail aktivere fællespostkasse/bruger: $ADuser, noget gik galt..." }


Write-Host "Connecting to Sessions" -ForegroundColor Magenta
$reconnect =  $PSScriptRoot | Split-Path -Parent | Split-Path -Parent; Invoke-Expression "$reconnect\Logins\Session_reconnect.ps1"


Write-Host "Tildeler licens for $ADuser" -foregroundcolor Cyan  
if ([bool](Get-ADuser -Filter  {SamAccountName -eq $ADuser}))
{
		#Write-Host "Tilføjer $ADuser til  gruppen 'O365_E5STD_U' medlemskab." -foregroundcolor Cyan
        #Add-ADGroupMember -Identity 'O365_E5STD_U' -Members  $ADuser -ErrorAction SilentlyContinue
        
        $x = New-MsolLicenseOptions -AccountSkuId "dksund:ENTERPRISEPREMIUM" -DisabledPlans "PROJECTWORKMANAGEMENT","YAMMER_ENTERPRISE","MCOSTANDARD","SHAREPOINTWAC", "SWAY", "RMS_S_ENTERPRISE"
 		Set-MsolUser -UserPrincipalName "$ADuser@dksund.dk" -UsageLocation DK
		Set-MsolUserLicense -UserPrincipalName "$ADuser@dksund.dk" -AddLicenses dksund:WIN_DEF_ATP, dksund:ENTERPRISEPREMIUM, dksund:EMSPREMIUM
		Set-MsolUserLicense -UserPrincipalName "$ADuser@dksund.dk" -LicenseOptions $x
        
        Write-Host "Time out 5 min..." -foregroundcolor Yellow 
        Start-Sleep 300
        #som resultat vil den være synlig i Offic365 , da den fik licens.
}
Else { Write-Warning "Bruger '$ADuser' kunne ikke findes i AD, tjek om det er korrekt fællespostkasse/bruger" }

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
Get-o365Mailbox $ADuser | set-o365Clutter -Enable $false


Write-Host "Sætter standard sprog til DK" -foregroundcolor Cyan 
Set-o365MailboxRegionalConfiguration –identity $ADuser –language da-dk -LocalizeDefaultFolderName


Start-Sleep 180
Write-Host "Connecting to Sessions" -ForegroundColor Magenta
$reconnect =  $PSScriptRoot | Split-Path -Parent | Split-Path -Parent; Invoke-Expression "$reconnect\Logins\Session_reconnect.ps1"


Write-Host "Ændre kalender rettighed for $ADuser til 'LimitedDetails' og tilføjer 'ConciergeMobile' som kalender 'editor' " -foregroundcolor Cyan 
$MailCalenderPath = "$ADuser" + ":\Kalender"
Set-o365mailboxfolderpermission –identity  $MailCalenderPath –user Default –Accessrights LimitedDetails
Start-Sleep 1 
Add-o365MailboxFolderPermission –Identity $MailCalenderPath –User ConciergeMobile –AccessRights Editor
Start-Sleep 1 
Add-o365MailboxFolderPermission $ADuser -User conciergemobile -AccessRights foldervisible -ErrorAction SilentlyContinue
Start-Sleep 1 
Set-o365MailboxFolderPermission $ADuser -User conciergemobile -AccessRights foldervisible -ErrorAction SilentlyContinue
Start-Sleep 1 
Get-o365MailboxFolderPermission -Identity $MailCalenderPath

Write-Host "Connecting to Sessions" -ForegroundColor Magenta
$reconnect =  $PSScriptRoot | Split-Path -Parent | Split-Path -Parent; Invoke-Expression "$reconnect\Logins\Session_reconnect.ps1"


Write-Host "Noter følgende i Nilex løsningsbeksrivelse:" -foregroundcolor Yellow -backgroundcolor DarkCyan
$ResultADuser = (Get-o365Mailbox "$ADuser").PrimarySmtpAddress
Write-Host "Bruger oprettet: $ResultADuser" -foregroundcolor Green -backgroundcolor DarkCyan
Pause

#Fejlfinding
#Get-o365Mailbox $ADuser | fl
#Get-ADGroup -Filter  {SamAccountName -eq 'samarbejdsogarbejdsmiljoeudvalget'} -Server $ServerNameDKSUND #http://stackoverflow.com/questions/6307127/hiding-errors-when-using-get-adgroup
#Get-ADGroup -Filter  {SamAccountName -eq 'samarbejdsogarbejdsmiljoeudvalget'} -Credential $UserCredDksund -AuthType Negotiate -Server $ServerNameDKSUND