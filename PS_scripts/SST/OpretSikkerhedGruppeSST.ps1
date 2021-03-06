﻿#PSVersion 5 Script made/assembled by Rust@m 16-03-2021
Write-Host "Du har valgt OpretSikkerhedGruppeSST.ps1" -ForegroundColor Gray -BackgroundColor DarkCyan
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
$ISEScriptPath = (Get-Location).Path | Split-Path -Parent -ErrorAction SilentlyContinue|Split-Path -Parent -ErrorAction SilentlyContinue; $ISEScriptPath = "$ISEScriptPath\Logins\Session_reconnect.ps1"
$PSscriptPath =  $PSScriptRoot | Split-Path -Parent -ErrorAction SilentlyContinue | Split-Path -Parent -ErrorAction SilentlyContinue; $PSscriptPath = "$PSscriptPath\Logins\Session_reconnect.ps1"
#*********************************************************************************************************************************************
#script 
#*********************************************************************************************************************************************
#Variabler oprettelse:
$OUPathForExchangeSikkerhedsgrupperSST = 'OU=SST,OU=Sikkerhedsgrupper,DC=SST,DC=dk'
$OUPathForExchangeSikkerhedsgrupperDEP = 'OU=DEP,OU=Sikkerhedsgrupper,DC=SST,DC=dk'
$OUPathForExchangeSikkerhedsgrupperSTPS = 'OU=STPS,OU=Sikkerhedsgrupper,DC=SST,DC=dk'
$OUPathForExchangeSikkerhedsgrupperNGC = 'OU=NGC,OU=Sikkerhedsgrupper,DC=SST,DC=dk'

$ExchangeSikkerhedsgruppe =  Read-Host -Prompt "Angiv Sikkerhedsgruppe navn, må indeholde kun [^a-zA-Z0-9\-_\.] (f.eks. SST_servicedesk_mail)"
$Manager = Read-Host -Prompt 'Angiv Ejers INITIALER til Sikkerhedsgruppe'
$company = Read-Host "Tast 1 for @sst.dk, 2 for @sum.dk, 3 for @stps.dk eller 4 for @ngc.dk"
$SikkerhedsgrupperDescription = "Giver fuld adgang til sikkerhedgruppen $ExchangeSikkerhedsgruppe."

##Check for illegal characters
if($ExchangeSikkerhedsgruppe -match  '[^a-zA-Z0-9\-_\.]'){

    Write-Host "Whoops --> You have used illegal characters in email alias!" -foregroundcolor red
    Write-Host "Sikkerhedsgruppe, Må indeholde kun [^a-zA-Z0-9\-_\.] (eksempel: SST_servicedesk_mai)" -ForegroundColor Yellow
    Write-Host "Better luck next time, exiting script!" -ForegroundColor Cyan
    pause
    return
}

Write-Host "Opretter AD objekt $ExchangeSikkerhedsgruppe i SST AD" -foregroundcolor Cyan
    Set-Location -Path 'SSTAD:'
if ($company -eq "1"){
    
    New-ADGroup -Name $ExchangeSikkerhedsgruppe -GroupScope Universal -GroupCategory Security -ManagedBy $Manager -Description $SikkerhedsgrupperDescription -Path $OUPathForExchangeSikkerhedsgrupperSST
    Write-Host "TimeOut for 60 sek." -foregroundcolor Yellow 
    sleep 60

    Write-Host "Opdaterer 'Company' felt og tilføje  email adresse til gruppen" -foregroundcolor Cyan
    $GroupMail = $ExchangeSikkerhedsgruppe+'@sst.dk'
    Set-ADGroup -Identity $ExchangeSikkerhedsgruppe -Add @{company="Sundhedsstyrelsen";mail="$GroupMail"}
}
Elseif ($company -eq "2") {
    New-ADGroup -Name $ExchangeSikkerhedsgruppe -GroupScope Universal -GroupCategory Security -ManagedBy $Manager -Description $SikkerhedsgrupperDescription -Path $OUPathForExchangeSikkerhedsgrupperDEP
    Write-Host "TimeOut for 60 sek." -foregroundcolor Yellow 
    sleep 60

    Write-Host "Opdaterer 'Company' felt og tilføje  email adresse til gruppen" -foregroundcolor Cyan
    $GroupMail = $ExchangeSikkerhedsgruppe+'@sst.dk'
    Set-ADGroup -Identity $ExchangeSikkerhedsgruppe -Add @{company="Sundheds- og Ældreministeriet";mail="$GroupMail"}
}
if ($company -eq "3") {
    New-ADGroup -Name $ExchangeSikkerhedsgruppe -GroupScope Universal -GroupCategory Security -ManagedBy $Manager -Description $SikkerhedsgrupperDescription -Path $OUPathForExchangeSikkerhedsgrupperSTPS
    Write-Host "TimeOut for 60 sek." -foregroundcolor Yellow 
    sleep 60

    Write-Host "Opdaterer 'Company' felt og tilføje  email adresse til gruppen" -foregroundcolor Cyan
    $GroupMail = $ExchangeSikkerhedsgruppe+'@sst.dk'
    Set-ADGroup -Identity $ExchangeSikkerhedsgruppe -Add @{company="Styrelsen for Patientsikkerhed";mail="$GroupMail"}
}
if ($company -eq "4") {
    New-ADGroup -Name $ExchangeSikkerhedsgruppe -GroupScope Universal -GroupCategory Security -ManagedBy $Manager -Description $SikkerhedsgrupperDescription -Path $OUPathForExchangeSikkerhedsgrupperNGC
    Write-Host "TimeOut for 60 sek." -foregroundcolor Yellow 
    sleep 60

    Write-Host "Opdaterer 'Company' felt og tilføje  email adresse til gruppen" -foregroundcolor Cyan
    $GroupMail = $ExchangeSikkerhedsgruppe+'@sst.dk'
    Set-ADGroup -Identity $ExchangeSikkerhedsgruppe -Add @{company="Nationalt Genom Center";mail="$GroupMail"}
}
Else 
{ Write-Warning "Mislykkedes at oprette $ExchangeSikkerhedsgruppe, Noget gik galt..."}


Write-Host "Tilføjer $Manager til  gruppen $ExchangeSikkerhedsgruppe medlemskab." -foregroundcolor Cyan
Add-ADGroupMember -Identity $ExchangeSikkerhedsgruppe -Members $Manager 


sleep 120
Write-Host "Connecting to Sessions" -ForegroundColor Magenta
#$reconnect =  $PSScriptRoot | Split-Path -Parent | Split-Path -Parent; Invoke-Expression "$reconnect\Logins\Session_reconnect.ps1"
if (Test-Path $ISEScriptPath){ Invoke-Expression $ISEScriptPath }elseif(test-path $PSscriptPath){Invoke-Expression $PSscriptPath}


Write-Host "E-Mail aktivering af $ExchangeSikkerhedsgruppe i Exchange 2016 SST" -foregroundcolor Cyan
if ([bool](Get-ADGroup -Filter  {SamAccountName -eq $ExchangeSikkerhedsgruppe})) 
{
    Write-Host "E-Mail aktivering af gruppen i Exchange 2016 SST" -foregroundcolor Cyan
    Enable-SSTDistributionGroup -Identity $ExchangeSikkerhedsgruppe -ErrorAction Stop
    #Disable-SSTSecurityGroup -Identity $ExchangeSikkerhedsgruppe -ErrorAction Stop
    Write-Host "Tilføjer primær smtp adressen og disabled email politik for $ExchangeSikkerhedsgruppe på Exchange 2016 SST" -foregroundcolor Cyan
   
    if ($company -eq "2"){
        $new = $ExchangeSikkerhedsgruppe + "@sum.dk"
        Set-SSTDistributionGroup $ExchangeSikkerhedsgruppe -PrimarySMTPAddress $new -EmailAddressPolicyEnabled $false
    }#>
    elseif ($company -eq "3"){
        $new = $ExchangeSikkerhedsgruppe + "@stps.dk"
        Set-SSTDistributionGroup $ExchangeSikkerhedsgruppe -PrimarySMTPAddress $new -EmailAddressPolicyEnabled $false
    }
    elseif ($company -eq "4"){
        $new = $ExchangeSikkerhedsgruppe + "@ngc.dk"
        Set-SSTDistributionGroup $ExchangeSikkerhedsgruppe -PrimarySMTPAddress $new -EmailAddressPolicyEnabled $false
    }
    elseif ($company -eq "1"){
        sleep 5
    }
    else {
        Write-Warning "Mislykkedes at e-mail aktivere $ExchangeSikkerhedsgruppe, noget gik galt."
    }
}
Else
{
    Write-Warning "Kunne ikke e-mail aktivere $ExchangeSikkerhedsgruppe, da gruppen muligvis ikke findes i Exchange 2016 SST, eller noget gik  galt." -ErrorAction Stop
}

Write-Host "TimeOut for 20 sek." -foregroundcolor Cyan
sleep 20

#Der kommer en lang WARNING med nedenstående kommando, men det ser ud til at virke :-)
Add-ADPermission -Identity $ExchangeSikkerhedsgruppe -User $Manager -AccessRights WriteProperty -Properties "Member"

$ResultGroup = (Get-SSTGroup $ExchangeSikkerhedsgruppe).WindowsEmailAddress
Write-Host "Sikkerhedsgruppe oprettet: $ResultGroup" -foregroundcolor Green -backgroundcolor DarkCyan
Write-Host "Ejer: $Manager" -foregroundcolor Green -backgroundcolor DarkCyan
Pause