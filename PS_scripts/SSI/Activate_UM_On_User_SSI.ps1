#PSVersion 5 Script made/assembled by Rust@m 13-07-2017
Write-Host "Activate_UM_On_User_SSI.ps1" -ForegroundColor Gray -BackgroundColor DarkCyan
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
$sip = $ADuser+"@ssi.dk"

Write-Host "Skifter til SSI AD." -foregroundcolor Cyan  
Set-Location -Path 'SSIAD:'

Write-Host "Checker om ADobjekt findes i forvejen...." -foregroundcolor Cyan
if ([bool](Get-ADUser -Filter  {SamAccountName -eq $ADuser})) 
{   
    $ADSeaerch = Get-ADUser $ADuser -Properties Canonicalname | select CanonicalName
    Write-Host "Bruger findes i AD:" -foregroundcolor Green
    Write-Host  $ADSeaerch.CanonicalName -foregroundcolor Green

    
} 
else { 
    
    Write-Host "Objekt $ADuser Findes ikke i AD eller konto i forvejen mailenablet, script afsluttes" -foregroundcolor red
    pause
    exit
} 


Write-Host "Skifter til DKSUND AD." -foregroundcolor Cyan   
Set-Location -Path 'DKSUNDAD:'

Write-Host "Forsøger aktivere UM Funktion i o365." -foregroundcolor Cyan 
if ([bool](Get-ADuser -Filter  {SamAccountName -eq $ADuser})){
    
    Write-Host "Connecting to Sessions" -ForegroundColor Magenta
    $reconnect =  $PSScriptRoot | Split-Path -Parent | Split-Path -Parent; Invoke-Expression "$reconnect\Logins\Session_reconnect.ps1"

    Write-Host "Enabling (UM) Unified Messaging funtion for Skype Enterprise" -foregroundcolor Cyan 
    Enable-o365UMMailbox -Identity $ADuser -UMMailboxPolicy O365UM -SIPResourceIdentifier $sip

    $ResultADuser = (Get-o365Mailbox "$ADuser").PrimarySmtpAddress
    Write-Host "UM var aktiveret på: $ResultADuser" -foregroundcolor Green -backgroundcolor DarkCyan

}
Else { Write-Warning "Mislykkedes at Aktivere UM, bruger muligvis findes ikke i DKSUND AD eller man har glemt at skrive tel nr nummer i SSI ad og afvente  synkronisering - 1 time, før man køre dette script igen..."}

Pause

#Fejlfinding
#Get-o365Mailbox $ADuser | fl
#Get-ADGroup -Filter  {SamAccountName -eq 'samarbejdsogarbejdsmiljoeudvalget'} -Server $ServerNameDKSUND #http://stackoverflow.com/questions/6307127/hiding-errors-when-using-get-adgroup
#Get-ADGroup -Filter  {SamAccountName -eq 'samarbejdsogarbejdsmiljoeudvalget'} -Credential $UserCredDksund -AuthType Negotiate -Server $ServerNameDKSUND