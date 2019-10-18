#PSVersion 5 Script made/assembled by Rust@m 13-07-2017
Write-Host "Du har valgt OpretDistributionsGruppeSSI_udenHak_iManagerSSI.ps1" -ForegroundColor Gray -BackgroundColor DarkCyan
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
$OUPathDistrubutionslisterSSI = 'OU=Distribution lists,DC=SSI,DC=ad'
$GroupAlias = Read-Host -Prompt "Angiv distributionsliste EMAIL, Må kun indeholde [^a-zA-Z0-9_-] (eksempel: itsupportere)"
$GroupDispName = Read-Host -Prompt "Angiv distribution liste DisplayName eller gentag Alias, må kun indeholde [^\sa-zA-Z0-9_-ÆØÅæøå] (eksempel: IT supportere)"
$Manager = Read-Host -Prompt 'Angiv distributionsliste Ejer'
$company = Read-Host "Tast 1 for SSI eller 2 for Sundhedsdatastyrelsen (så får den @ssi.dk eller @sundhedsdata.dk)"
$Description = Read-Host -Prompt "Angiv beskrivelse af hvad vil den bruger til? (eller skriv '.' til at springe over N/A)"

##Check for illegal Characters i email alias
if($GroupAlias -match  '[^a-zA-Z0-9_-]'){

    Write-Host "Whoops --> You have used illegal characters in email alias!" -foregroundcolor red
    Write-Host "Distributionsliste EMAIL, Må kun indeholde [^a-zA-Z0-9_-] (eksempel: itsupportere)" -ForegroundColor Yellow
    Write-Host "Better luck next time, exiting script!" -ForegroundColor Cyan
    pause
    exit
}

##Check for illegal Characters
if($GroupDispName -match  '[^\sa-zA-Z0-9_-ÆØÅæøå]'){

    Write-Host "Whoops --> You have used illegal characters in email alias!" -foregroundcolor red
    Write-Host "Distributionsliste Display Name, Må kun indeholde [^\sa-zA-Z0-9_-ÆØÅæøå] (eksempel: IT supportere)" -ForegroundColor Yellow
    Write-Host "Better luck next time, exiting script!" -ForegroundColor Cyan
    pause
    #exit
}


Write-Host "Opretter Distributionsgruppe i SSI AD." -foregroundcolor Cyan
#PSdrive blev oprettet ved login script, som er ikke en del af den her execution.
Set-Location -Path 'SSIAD:'


If ($company -eq "1") {
    New-ADGroup -Name $GroupDispName -GroupScope Universal -GroupCategory Distribution -ManagedBy $Manager -Description $Description -Path $OUPathDistrubutionslisterSSI
    Write-Host "TimeOut for 20 sek." -foregroundcolor Cyan
    sleep 20
    
    #Set-ADGroup -Identity $GroupAlias -Clear Company
    Write-Host "Opdaterer 'Company' felt og tilføje  email adresse til gruppen" -foregroundcolor Cyan
    $GroupMail = $GroupAlias+'@ssi.dk'
    Set-ADGroup -Identity $GroupDispName -Add @{company="Statens Serum Institut";mail="$GroupMail"}
    }
    ElseIf ($company -eq "2") {
    New-ADGroup -Name $GroupDispName -GroupScope Universal -GroupCategory Distribution -ManagedBy $Manager -Description $Description -Path $OUPathDistrubutionslisterSSI
    
    Write-Host "TimeOut for 20 sek." -foregroundcolor Cyan
    sleep 20
    
    #Set-ADGroup -Identity $GroupAlias -Clear Company
    Write-Host "Opdaterer 'Company' felt og tilføje  email adresse til gruppen" -foregroundcolor Cyan
    $GroupMail = $GroupAlias+'@sundhedsdata.dk'
    Set-ADGroup -Identity $GroupDispName -Add @{company="Sundhedsdatastyrelsen";mail="$GroupMail"}
    }
    Else{
    Write-Warning "Mislykkedes oprette og opdatere 'Company' felt på gruppen $GroupAlias fordi gruppen
    findes ikke i AD, eller der er ikke valgt korrekt Company værdi."
    }


Write-Host "Tilføjer $Manager til  gruppen $GroupDispName medlemskab." -foregroundcolor Cyan
Add-ADGroupMember -Identity $GroupDispName -Members $Manager
Write-Host "Tilføjer $Manager til  gruppen 'U-SSI-CTX-Standard applikationer' medlemskab." -foregroundcolor Cyan
Add-ADGroupMember -Identity 'U-SSI-CTX-Standard applikationer' -Members  $Manager

#Get-ADGroup -Filter  {SamAccountName -eq 'samarbejdsogarbejdsmiljoeudvalget'} -Server $ServerNameDKSUND #http://stackoverflow.com/questions/6307127/hiding-errors-when-using-get-adgroup

Write-Host "TimeOut på 3 timmer, til AD gruppe synkroniseres med DKSUND, venter synkronisering...." -foregroundcolor Yellow
Write-Host "Obs! Husk at sætte hak i Manager kan opdatere medlemskabsliste, da dette del kan ikke automatiseres pt. !!!!" -foregroundcolor Yellow -backgroundcolor DarkCyan
sleep 10800

Write-Host "Skifter til DKSUND AD" -foregroundcolor Yellow
Set-Location -Path 'DKSUNDAD:'

Write-Host "Connecting to Sessions" -ForegroundColor Magenta
$reconnect =  $PSScriptRoot | Split-Path -Parent | Split-Path -Parent; Invoke-Expression "$reconnect\Logins\Session_reconnect.ps1"


if ([bool](Get-ADGroup -Filter  {SamAccountName -eq $GroupDispName})) 
{
    Write-Host "E-Mail aktivering af gruppen i Exchange 2016" -foregroundcolor Cyan
    Enable-SSIDistributionGroup -Identity $GroupDispName
    #Disable-SSIDistributionGroup $GroupDispName
    If ($company -eq "1") {
    $new = $GroupAlias + "@ssi.dk"
    Set-SSIDistributionGroup $GroupDispName -PrimarySMTPAddress $new -EmailAddressPolicyEnabled $false

    }
    ElseIf ($company -eq "2") {
    $new = $GroupAlias + "@sundhedsdata.dk"
    Set-SSIDistributionGroup $GroupDispName -PrimarySMTPAddress $new -EmailAddressPolicyEnabled $false
    }
}
Else
{
    Write-Warning "Mislykkedes at e-mail aktivere $GroupAlias, da gruppen muligvis ikke findes i DKSUND/Exchange 2016..."
}


 Write-Host "TimeOut for 20 sek." -foregroundcolor Cyan
 sleep 20


Write-Host "Connecting to Sessions" -ForegroundColor Magenta
$reconnect =  $PSScriptRoot | Split-Path -Parent | Split-Path -Parent; Invoke-Expression "$reconnect\Logins\Session_reconnect.ps1"


Write-Host "Obs! Husk at sætte hak i Manager kan opdatere medlemskabsliste, da dette kan ikke automatiseres pt. !!!!" -foregroundcolor Yellow -backgroundcolor DarkCyan

Write-Host "Noter følgende i Nilex løsningsbeksrivelse:" -foregroundcolor Yellow -backgroundcolor DarkCyan
$ResultGroupName = (Get-o365Group $GroupDispName).DisplayName
Write-Host "Distrubutionsgruppe Display Name: $ResultGroupName" -foregroundcolor Green -backgroundcolor DarkCyan
$ResultGroupAlias = (Get-o365Group $GroupDispName).WindowsEmailAddress
Write-Host "Distrubutionsgruppe oprettet: $ResultGroupAlias" -foregroundcolor Green -backgroundcolor DarkCyan
Write-Host "Ejer: $Manager" -foregroundcolor Green -backgroundcolor DarkCyan
Pause