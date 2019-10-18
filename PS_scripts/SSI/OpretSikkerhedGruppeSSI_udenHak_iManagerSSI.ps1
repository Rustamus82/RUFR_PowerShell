#PSVersion 5 Script made/assembled by Rust@m 13-07-2017
Write-Host "Du har valgt OpretSikkerhedGruppeSSI_udenHak_iManagerSSI.ps1" -ForegroundColor Gray -BackgroundColor DarkCyan
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
#script 
#*********************************************************************************************************************************************
#Variabler oprettelse:
$OUPathForExchangeSikkerhedsgrupperSSI = 'OU=ResourceGroups,OU=Exchange,OU=Groups,OU=SSI,DC=SSI,DC=ad'
$OUPathForExchangeSikkerhedsgrupperSDS = 'OU=Exchange Sikkerhedsgrupper,OU=Sundhedsdatastyrelsen,OU=Ressourcer,DC=SSI,DC=ad'

$ExchangeSikkerhedsgruppe =  Read-Host -Prompt "Angiv Sikkerhedsgruppe navn til eksisterende fællespostkasse, må indeholde kun [^a-zA-Z0-9_-] (f.eks. GRP-servicedesk)"
$Manager = Read-Host -Prompt 'Angiv Ejers INITIALER til Sikkerhedsgruppe'
$company = Read-Host "Tast 1 for SSI eller 2 for Sundhedsdatastyrelsen (så får den @ssi.dk eller @sundhedsdata.dk)"
$SikkerhedsgrupperDescription = "Giver fuld adgang til fællespostkasse"

##Check for illegald Characters
if($ExchangeSikkerhedsgruppe -match  '[^a-zA-Z0-9_-]'){

    Write-Host "Whoops --> You have used illegal characters in email alias!" -foregroundcolor red
    Write-Host "Sikkerhedsgruppe, Må IKKE indeholde: mellemrum, komma, ÆØÅ / \ (eksempel: GRP-servicedesk)" -ForegroundColor Yellow
    Write-Host "Better luck next time, exiting script!" -ForegroundColor Cyan
    pause
    exit
}


Write-Host "Opretter AD objekt $ExchangeSikkerhedsgruppe i SSI AD" -foregroundcolor Cyan
    Set-Location -Path 'SSIAD:'
if ($company -eq "1"){
    
    New-ADGroup -Name $ExchangeSikkerhedsgruppe -GroupScope Universal -GroupCategory Security -ManagedBy $Manager -Description $SikkerhedsgrupperDescription -Path $OUPathForExchangeSikkerhedsgrupperSSI
    Write-Host "TimeOut for 20 sek." -foregroundcolor Yellow 
    sleep 20

    Write-Host "Opdaterer 'Company' felt og tilføje  email adresse til gruppen" -foregroundcolor Cyan
    $GroupMail = $ExchangeSikkerhedsgruppe+'@ssi.dk'
    Set-ADGroup -Identity $ExchangeSikkerhedsgruppe -Add @{company="Statens Serum Institut";mail="$GroupMail"}
}
Elseif ($company -eq "2") {
    New-ADGroup -Name $ExchangeSikkerhedsgruppe -GroupScope Universal -GroupCategory Security -ManagedBy $Manager -Description $SikkerhedsgrupperDescription -Path $OUPathForExchangeSikkerhedsgrupperSDS
    Write-Host "TimeOut for 20 sek." -foregroundcolor Yellow 
    sleep 20

    Write-Host "Opdaterer 'Company' felt og tilføje  email adresse til gruppen" -foregroundcolor Cyan
    $GroupMail = $ExchangeSikkerhedsgruppe+'@sundhedsdata.dk'
    Set-ADGroup -Identity $ExchangeSikkerhedsgruppe -Add @{company="Sundhedsdatastyrelsen";mail="$GroupMail"}
}
Else 
{ Write-Warning "Mislykkedes at oprette $ExchangeSikkerhedsgruppe, Noget gik galt..."}


Write-Host "Tilføjer $Manager til  gruppen $ExchangeSikkerhedsgruppe medlemskab." -foregroundcolor Cyan
Add-ADGroupMember -Identity $ExchangeSikkerhedsgruppe -Members $Manager 
Write-Host "Tilføjer $Manager til  gruppen 'U-SSI-CTX-Standard applikationer' medlemskab." -foregroundcolor Cyan
Add-ADGroupMember -Identity 'U-SSI-CTX-Standard applikationer' -Members  $Manager



#Venter Synkronisering til DKSUND
Write-Host "Time out 3 timer. venter til konti synkroniseret til DKSUND" -foregroundcolor Yellow
Write-Host "Obs! Husk at sætte hak i Manager kan opdatere medlemskabsliste, da dette del kan ikke automatiseres pt. !!!!" -foregroundcolor Yellow -backgroundcolor DarkCyan
sleep 10800

Write-Host "Skifter til DKSUND AD" -foregroundcolor Yellow
Set-Location -Path 'DKSUNDAD:'

Write-Host "Connecting to Sessions" -ForegroundColor Magenta
$reconnect =  $PSScriptRoot | Split-Path -Parent | Split-Path -Parent; Invoke-Expression "$reconnect\Logins\Session_reconnect.ps1"

Write-Host "E-Mail aktivering af $ExchangeSikkerhedsgruppe i Exchange 2016" -foregroundcolor Cyan
if ([bool](Get-ADGroup -Filter  {SamAccountName -eq $ExchangeSikkerhedsgruppe})) 
{
    Write-Host "E-Mail aktivering af gruppen i Exchange 2016" -foregroundcolor Cyan
    Enable-SSIDistributionGroup -Identity $ExchangeSikkerhedsgruppe -ErrorAction Stop
    #Disable-SSIDistributionGroup -Identity $ExchangeSikkerhedsgruppe -ErrorAction Stop
    Write-Host "Tilføjer primær smtp adressen og disabled email politik for $ExchangeSikkerhedsgruppe på Exchange 2016" -foregroundcolor Cyan
    $new = $ExchangeSikkerhedsgruppe + "@ssi.dk"
    Set-SSIDistributionGroup $ExchangeSikkerhedsgruppe -PrimarySMTPAddress $new -EmailAddressPolicyEnabled $false
        
}
Else
{
    Write-Warning "Kunne ikke e-mail aktivere $ExchangeSikkerhedsgruppe, da gruppen muligvis ikke findes i DKSUND/Exchange 2016, eller noget gik  galt." -ErrorAction Stop
}

Write-Host "TimeOut for 20 sek." -foregroundcolor Cyan
sleep 20

Write-Host "Connecting to Sessions" -ForegroundColor Magenta
$reconnect =  $PSScriptRoot | Split-Path -Parent | Split-Path -Parent; Invoke-Expression "$reconnect\Logins\Session_reconnect.ps1"
Connect-MsolService -Credential $Global:credo365


Write-Host "Obs! Husk at sætte hak i Manager kan opdatere medlemskabsliste, da dette kan ikke automatiseres pt. !!!!" -foregroundcolor Yellow -backgroundcolor DarkCyan
$ResultGroup = (Get-o365Group $ExchangeSikkerhedsgruppe).WindowsEmailAddress
Write-Host "Tilhørende sikkerhedsgruppe oprettet: $ResultGroup" -foregroundcolor Green -backgroundcolor DarkCyan
Write-Host "Ejer: $Manager" -foregroundcolor Green -backgroundcolor DarkCyan
Pause