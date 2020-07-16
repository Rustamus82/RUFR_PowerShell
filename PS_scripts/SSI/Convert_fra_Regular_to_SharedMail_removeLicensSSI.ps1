#PSVersion 5 Script made/assembled by Rust@m 13-07-2017
Write-Host "Du har valgt Convert_fra_Regular_to_SharedMail_removeLicensSSI.ps1" -ForegroundColor Gray -BackgroundColor DarkCyan
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
#Script
#*********************************************************************************************************************************************

#variabler
$SharedMail = Read-Host -Prompt "Angiv fællespostkasse navn, som skal konverteres til delt postkasse og Fjerne Licens - f.eks Servicedesk"
#$OUPathForExchangeSikkerhedsgrupperSSI = 'OU=ResourceGroups,OU=Exchange,OU=Groups,OU=SSI,DC=SSI,DC=ad'
$OUPathSharedMailSSI = 'OU=Faelles postkasser,OU=Ressourcer,DC=SSI,DC=ad'
#$OUPathSharedMailSSI_ikke_type = 'OU=Faelles postkasser ikke type shared,OU=Ressourcer,DC=SSI,DC=ad'

#$OUPathForExchangeSikkerhedsgrupperSDS = 'OU=Exchange Sikkerhedsgrupper,OU=Sundhedsdatastyrelsen,OU=Ressourcer,DC=SSI,DC=ad'
$OUPathSharedMailSDS = 'OU=Faelles postkasser,OU=Sundhedsdatastyrelsen,OU=Ressourcer,DC=SSI,DC=ad'
#$OUPathSharedMailSDS_ikke_type  = 'OU=Faelles postkasser ikke type shared,OU=Sundhedsdatastyrelsen,OU=Ressourcer,DC=SSI,DC=ad'

#$ExchangeSikkerhedsgruppe = 'GRP-'+$SharedMail

$SharedmailDescription = "Fællespostkasse af type Shared, uden Office 365 licens, direkte login er ikke muligt"

if (-not ($SharedMail -eq "*")) {
		Write-Host "Konverterer postkasse $SharedMail til type 'Shared'" -foregroundcolor Cyan
        Set-Mailbox $SharedMail -Type Shared 
        
        Write-Host "Fjerner Licens fra $SharedMail" -foregroundcolor Cyan
        #Get-MsolUser -UserPrincipalName $SharedMail@dksund.dk |Select-Object UserPrincipalName, DisplayName, Department, {$_.Licenses.AccountSkuId}, WhenCreated
        $MSOLSKU = (Get-MsolUser -UserPrincipalName $SharedMail@dksund.dk).Licenses[0].AccountSkuId
        Set-MsolUserLicense -UserPrincipalName $SharedMail@dksund.dk -RemoveLicenses $MSOLSKU 
}
Else {write-host "Du har tastet * i username, tjek om det er korrekt fællespostkasse defineret, prøv igen" -foregroundcolor Red}


 Set-Location -Path 'SSIAD:'
if ((Get-ADUser $SharedMail -Properties "Company").company -eq "Statens Serum Institut")
{
        Write-Host "Forsøger at flytte objekt $SharedMail korrekte OU " -foregroundcolor Cyan
        Get-ADUser $SharedMail | Move-ADObject -TargetPath "$OUPathSharedMailSSI"
        Get-ADUser $SharedMail |Set-ADUser -Description "$SharedmailDescription"
}
Elseif ((Get-ADUser $SharedMail -Properties "Company").company -eq "Sundhedsdatastyrelsen") 
{
        Write-Host "Forsøger at flytte objekt $SharedMail korrekte OU " -foregroundcolor Cyan
        Get-ADUser $SharedMail | Move-ADObject -TargetPath "$OUPathSharedMailSDS"
        Get-ADUser $SharedMail |Set-ADUser -Description "$SharedmailDescription"
}
Else 
{Write-Warning "'Copmany' felt er ikke defineret! Flyt manuelt objekt: $SharedMail  til korrekte OU i SSI AD og udfyld korrekte 'Company' felt!!"}


Write-Host "Connecting to Sessions" -ForegroundColor Magenta
$reconnect =  $PSScriptRoot | Split-Path -Parent | Split-Path -Parent; Invoke-Expression "$reconnect\Logins\Session_reconnect.ps1"


Write-Host "Opretter reggel at email som er sendt fra shared postkasse, bliver lagt 2 steder, nemlig i sendt items hos bruger og i selve fællespostkasse." -foregroundcolor Cyan
Set-Mailbox $SharedMail -MessageCopyForSentAsEnabled $True 

Write-Host "Sætter standard sprog til DK" -foregroundcolor Cyan
Set-MailboxRegionalConfiguration –identity $SharedMail –language da-dk -LocalizeDefaultFolderName

Write-Host "Connecting to Sessions" -ForegroundColor Magenta
$reconnect =  $PSScriptRoot | Split-Path -Parent | Split-Path -Parent; Invoke-Expression "$reconnect\Logins\Session_reconnect.ps1"

Write-Host "Ændre kalender rettighed af $ADuser til LimitedDetails " -foregroundcolor Cyan 
    $MailCalenderPath = "$ADuser" + ":\Kalender"
    Set-mailboxfolderpermission –identity $MailCalenderPath –user Default –Accessrights LimitedDetails
    Add-MailboxFolderPermission –Identity $MailCalenderPath –User ConciergeMobile –AccessRights Editor
    Get-MailboxFolderPermission -Identity $MailCalenderPath


pause