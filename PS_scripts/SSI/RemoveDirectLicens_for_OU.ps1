#PSVersion 5 Script made/assembled by Rust@m 09-07-2020
cls; Write-Host "RemoveDirectLicens for OU.ps1" -ForegroundColor Gray -BackgroundColor DarkCyan
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
#ssi.ad/SSI/DisabledUsers/
$OUPathDisabledUsersSSI = 'OU=DisabledUsers,OU=SSI,DC=SSI,DC=ad'

Write-Host "Konverting to type SharedMailBox & Removing all licenses from ssi.ad/SSI/DisabledUsers/" -foregroundcolor Yellow 

Write-Host "Skifter til SSI AD." -foregroundcolor Cyan  
Set-Location -Path 'SSIAD:'

# Get all groups in specified OU to SSI. and count
#(Get-ADUser -SearchBase "$OUPathDisabledUsersSSI" -Filter *).count
$ADusers =  (Get-ADUser -SearchBase "$OUPathDisabledUsersSSI" -Filter * )
$ADusers.count
$Total = $ADusers.count
$ADusers.SamAccountName

foreach ($ADuser in $ADusers){

    $SamAccountName = $ADuser.SamAccountName
    Write-host -Object $("Konverterer postkasse til SharedMailBox User: {0}" -f  $SamAccountName) -ForegroundColor Cyan
    Set-Mailbox $SamAccountName -Type Shared
    #Disable-ADAccount -Identity $SamAccountName -WhatIf
    
    
    Write-host -Object $("Removing Licens for SharedMailBox User: {0}" -f  $SamAccountName) -ForegroundColor Cyan
    #Remove-ADGroupMember -Identity 'O365_E5STD_U' -Members $ADuser -ErrorAction SilentlyContinue -Confirm:$false -Credential $Global:UserCredDksund
    $MSOLSKU = (Get-MsolUser -UserPrincipalName "$SamAccountName@dksund.dk").Licenses.AccountSkuId
    Set-MsolUserLicense -UserPrincipalName "$SamAccountName@dksund.dk" -RemoveLicenses $MSOLSKU
    Start-Sleep -milliseconds 800

}

#Write-Host "Connecting to Sessions" -ForegroundColor Magenta
#$reconnect =  $PSScriptRoot | Split-Path -Parent | Split-Path -Parent; Invoke-Expression "$reconnect\Logins\Session_reconnect.ps1"

Write-Host "Users converted to type SharedMailBox and Licens removed for all user in OU ssi.ad/SSI/DisabledUsers/" -foregroundcolor Yellow -backgroundcolor DarkCyan
Write-Host "Licens removed processed on  Disabled users: $Total" -foregroundcolor Green -backgroundcolor white
Pause