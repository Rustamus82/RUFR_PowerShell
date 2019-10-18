#PSVersion 5 Script made/assembled by Rust@m 13-07-2017
Write-Host "Du har valgt Convert_fra_Shared_to_RegularlUser_plusLicensSSI.ps1" -ForegroundColor Gray -BackgroundColor DarkCyan
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
$ADuser = Read-Host -Prompt "Angiv fællespostkasse navn som skal konverteres fra type 'shared' til type 'Regular' og Tildele Licens. - (f.eks Servicedesk)"
#$ExchangeSikkerhedsgruppe = 'GRP-'+$ADuser
$OUPathForExchangeSikkerhedsgrupperSSI = 'OU=ResourceGroups,OU=Exchange,OU=Groups,OU=SSI,DC=SSI,DC=ad'
$OUPathForExchangeSikkerhedsgrupperSDS = 'OU=Exchange Sikkerhedsgrupper,OU=Sundhedsdatastyrelsen,OU=Ressourcer,DC=SSI,DC=ad'

$OUPathSharedMailSSI = 'OU=Faelles postkasser,OU=Ressourcer,DC=SSI,DC=ad'
$OUPathSharedMailSSI_ikke_type = 'OU=Faelles postkasser ikke type shared,OU=Ressourcer,DC=SSI,DC=ad'
$OUPathSharedMailSDS = 'OU=Faelles postkasser,OU=Sundhedsdatastyrelsen,OU=Ressourcer,DC=SSI,DC=ad'
$OUPathSharedMailSDS_ikke_type  = 'OU=Faelles postkasser ikke type shared,OU=Sundhedsdatastyrelsen,OU=Ressourcer,DC=SSI,DC=ad'
$ADuserDescription = "Fællesbruger, direkte logine er mulig, skal have licens for Office 365"


if (-not ($ADuser -eq "*")) {
        Write-Host "Konverterer $ADuser fællespostkasse af type 'shared'  til 'regular' Normal User..." -foregroundcolor Cyan
        set-o365Mailbox $ADuser -Type Regular
		
        sleep 6
        Write-Host "Tildeler licens til kontoen..." -foregroundcolor Cyan
		$x = New-MsolLicenseOptions -AccountSkuId "dksund:ENTERPRISEPREMIUM" -DisabledPlans "PROJECTWORKMANAGEMENT","YAMMER_ENTERPRISE","MCOSTANDARD","SHAREPOINTWAC", "SWAY", "RMS_S_ENTERPRISE"
 		Set-MsolUser -UserPrincipalName "$ADuser@dksund.dk" -UsageLocation DK
		Set-MsolUserLicense -UserPrincipalName "$ADuser@dksund.dk" -AddLicenses dksund:WIN_DEF_ATP, dksund:ENTERPRISEPREMIUM, dksund:EMSPREMIUM
		Set-MsolUserLicense -UserPrincipalName "$ADuser@dksund.dk" -LicenseOptions $x

        Set-Location -Path 'SSIAD:'
        if ((Get-ADUser $ADuser -Properties "Company").company -eq "Statens Serum Institut"){
                Write-Host "Forsøger at flytte objekt $ADuser korrekte OU " -foregroundcolor Cyan
                Get-ADUser $ADuser | Move-ADObject -TargetPath "$OUPathSharedMailSSI_ikke_type"
                Get-ADUser $ADuser |Set-ADUser -Description "$ADuserDescription"
        }
        Elseif ((Get-ADUser $ADuser -Properties "Company").company -eq "Sundhedsdatastyrelsen") {
                Write-Host "Forsøger at flytte objekt $ADuser korrekte OU " -foregroundcolor Cyan
                Get-ADUser $ADuser | Move-ADObject -TargetPath "$OUPathSharedMailSDS_ikke_type"                
        }
        Else 
        { Write-Warning "'Copmany' felt er ikke defineret! Flyt manuelt objekt: $ADuser og dens tilhørende $ExchangeSikkerhedsgruppe gruppe til korrekte OU i SSI AD og udfyld korrekte 'Company' felt!!"} 



}
Else {write-host "Du har tastet * i username, tjek om det er korrekt fællespostkasse, prøv igen" -foregroundcolor Red}

Write-Host "Connecting to Sessions" -ForegroundColor Magenta
$reconnect =  $PSScriptRoot | Split-Path -Parent | Split-Path -Parent; Invoke-Expression "$reconnect\Logins\Session_reconnect.ps1"

Write-Host "Opdaterer reggel at email som er sendt fra shared postkasse, at 'sendt post' bliver i selve fællespostkassen." -foregroundcolor Cyan
Set-o365Mailbox $ADuser -MessageCopyForSentAsEnabled $false
Write-Host "Sætter standard sprog til DK" -foregroundcolor Cyan
Set-o365MailboxRegionalConfiguration –identity $ADuser –language da-dk -LocalizeDefaultFolderName

Write-Host "Connecting to Sessions" -ForegroundColor Magenta
$reconnect =  $PSScriptRoot | Split-Path -Parent | Split-Path -Parent; Invoke-Expression "$reconnect\Logins\Session_reconnect.ps1"

Write-Host "Ændre kalender rettighed af $ADuser til LimitedDetails " -foregroundcolor Cyan 
    $MailCalenderPath = "$ADuser" + ":\Kalender"
    Set-o365mailboxfolderpermission –identity $MailCalenderPath –user Default –Accessrights LimitedDetails
    Add-o365MailboxFolderPermission –Identity $MailCalenderPath –User ConciergeMobile –AccessRights Editor
    Get-o365MailboxFolderPermission -Identity $MailCalenderPath

Pause