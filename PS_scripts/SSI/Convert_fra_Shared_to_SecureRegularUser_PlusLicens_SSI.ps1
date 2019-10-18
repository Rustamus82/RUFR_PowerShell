#PSVersion 5 Script made/assembled by Rust@m 13-07-2017
Write-Host "Du har valgt Convert_fra_Shared_to_SecureRegularUser_PlusLicens_SSI.ps1" -ForegroundColor Gray -BackgroundColor DarkCyan
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
$SharedMail = Read-Host -Prompt 'Angiv fællespostkasse navn som skal konverteres til type RegularUser og placeres for sikkermail OU - (f.eks Servicedesk):'
#$OUPathForExchangeSikkerhedsgrupperSSI = 'OU=ResourceGroups,OU=Exchange,OU=Groups,OU=SSI,DC=SSI,DC=ad'
$OUPathSharedMailSSI = 'OU=Faelles postkasser,OU=Ressourcer,DC=SSI,DC=ad'
$OUPathSharedMailSSI_ikke_type = 'OU=Faelles postkasser ikke type shared,OU=Ressourcer,DC=SSI,DC=ad'
$OUPathSharedMailSSI_Sikkermail = 'OU=Sikkermail postkasser,OU=Ressourcer,DC=ssi,DC=ad'
#$OUPathForExchangeSikkerhedsgrupperSDS = 'OU=Exchange Sikkerhedsgrupper,OU=Sundhedsdatastyrelsen,OU=Ressourcer,DC=SSI,DC=ad'
$OUPathSharedMailSDS = 'OU=Faelles postkasser,OU=Sundhedsdatastyrelsen,OU=Ressourcer,DC=SSI,DC=ad'
$OUPathSharedMailSDS_ikke_type  = 'OU=Faelles postkasser ikke type shared,OU=Sundhedsdatastyrelsen,OU=Ressourcer,DC=SSI,DC=ad'
$OUPathSharedMailSDS_Sikkermail = 'OU=Sikkermail Postkasser,OU=Sundhedsdatastyrelsen,OU=Ressourcer,DC=SSI,DC=ad'
$SharedmailDescription = "Sikkermail  (skal have licens for sikkermail løsning fungere, direkte login muligt)"

Write-Host "Konverter Fællespostkasse '$SharedMail' til type Ikke Shared"
set-o365Mailbox $SharedMail -Type Regular

Write-Host "Tildeler licens til kontoen"
if (-not ($SharedMail -eq "*")) {
		 $x = New-MsolLicenseOptions -AccountSkuId "dksund:ENTERPRISEPACK" -DisabledPlans "PROJECTWORKMANAGEMENT","YAMMER_ENTERPRISE","MCOSTANDARD","SHAREPOINTWAC", "OFFICESUBSCRIPTION", "SWAY", "RMS_S_ENTERPRISE"
 		Set-MsolUser -UserPrincipalName $SharedMail@dksund.dk -UsageLocation DK
		Set-MsolUserLicense -UserPrincipalName $SharedMail@dksund.dk -AddLicenses dksund:ENTERPRISEPACK
		Set-MsolUserLicense -UserPrincipalName $SharedMail@dksund.dk -LicenseOptions $x

        Set-Location -Path 'SSIAD:'
        if ((Get-ADUser $SharedMail -Properties "Company").company -eq "Statens Serum Institut"){
                Write-Host "Forsøger at flytte objekt $SharedMail korrekte OU " -foregroundcolor Cyan
                Set-Location -Path 'SSIAD:'
                Get-ADUser $SharedMail | Move-ADObject -TargetPath "$OUPathSharedMailSSI_Sikkermail"
                Get-ADUser $SharedMail |Set-ADUser -Description "$SharedmailDescription"
        }
        Elseif ((Get-ADUser $SharedMail -Properties "Company").company -eq "Sundhedsdatastyrelsen") {
                Write-Host "Forsøger at flytte objekt $SharedMail korrekte OU " -foregroundcolor Cyan
                Get-ADUser $SharedMail | Move-ADObject -TargetPath "$OUPathSharedMailSDS_Sikkermail"
                Get-ADUser $SharedMail |Set-ADUser -Description "$SharedmailDescription"
        }
        Else 
        { Write-Warning "'Copmany' felt er ikke defineret! Flyt manuelt objekt: $SharedMail  til korrekte OU i SSI AD og udfyld korrekte 'Company' felt!!"} 

}
Else { write-host "du har tastet * i username, tjek om det er korrekt fællespostkasse/bruger" }

Write-Host "Connecting to Sessions" -ForegroundColor Magenta
$reconnect =  $PSScriptRoot | Split-Path -Parent | Split-Path -Parent; Invoke-Expression "$reconnect\Logins\Session_reconnect.ps1"

Write-Host "Opdaterer reggel at email som er sendt fra shared postkasse, at 'sendt post' bliver i selve fællespostkassen." -foregroundcolor Cyan
Set-o365Mailbox $SharedMail -MessageCopyForSentAsEnabled $false
Write-Host "Sætter standard sprog til DK" -foregroundcolor Cyan
Set-o365MailboxRegionalConfiguration –identity $SharedMail –language da-dk -LocalizeDefaultFolderName

Write-Host "Connecting to Sessions" -ForegroundColor Magenta
$reconnect =  $PSScriptRoot | Split-Path -Parent | Split-Path -Parent; Invoke-Expression "$reconnect\Logins\Session_reconnect.ps1"

Write-Host "Ændre kalender rettighed af $ADuser til LimitedDetails " -foregroundcolor Cyan 
    $MailCalenderPath = "$ADuser" + ":\Kalender"
    Set-o365mailboxfolderpermission –identity $MailCalenderPath –user Default –Accessrights LimitedDetails
    Add-o365MailboxFolderPermission –Identity $MailCalenderPath –User ConciergeMobile –AccessRights Editor
    Get-o365MailboxFolderPermission -Identity $MailCalenderPath


Pause

#get-o365mailbox Vaccinationsreminder
#set-o365mailbox Vaccinationsreminder -MessageCopyForSentAsEnabled $false