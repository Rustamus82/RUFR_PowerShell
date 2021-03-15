#PSVersion 5 Script made/assembled by eks-@nae 07-06-2019
Write-Host "Du har valgt OpretDistributionsgruppeSST.ps1" -ForegroundColor Gray -BackgroundColor DarkCyan
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
$OUPathDistrubutionslisterSST = 'OU=SST,OU=Distributionsgrupper,DC=SST,DC=dk'
$OUPathDistrubutionslisterDEP = 'OU=DEP,OU=Distributionsgrupper,DC=SST,DC=dk'
$OUPathDistrubutionslisterSTPS = 'OU=STPS,OU=Distributionsgrupper,DC=SST,DC=dk'
$OUPathDistrubutionslisterNGC = 'OU=NGC,OU=Distributionsgrupper,DC=SST,DC=dk'

$GroupAlias = Read-Host -Prompt "Angiv distributionsliste EMAIL, Må kun indeholde [^a-zA-Z0-9\-_\.] (eksempel: itsupportere)"
$GroupDispName = Read-Host -Prompt "Angiv distribution liste DisplayName eller gentag Alias, må kun indeholde [^\sa-zA-Z0-9-_.ÆØÅæøå] (eksempel: IT supportere)"
$Manager = Read-Host -Prompt 'Angiv distributionsliste Ejer'
$company = Read-Host "Tast 1 for SST, 2 for SUM eller 3 for STPS og 4 for NGC (så får den @sst.dk, @sum.dk, @stps.dk eller @ngc.dk)"
$Description = Read-Host -Prompt "Angiv beskrivelse af hvad vil den bruger til? (eller skriv '.' til at springe over N/A)"

##Check for illegal Characters i email alias
if($GroupAlias -match  '[^a-zA-Z0-9\-_\.]'){

    Write-Host "Whoops --> You have used illegal characters in email alias!" -foregroundcolor red
    Write-Host "Distributionsliste EMAIL, Må kun indeholde [^a-zA-Z0-9\-_\.] (eksempel: itsupportere)" -ForegroundColor Yellow
    Write-Host "Better luck next time, exiting script!" -ForegroundColor Cyan
    pause
    return
}

##Check for illegal Characters
if($GroupDispName -match  '[^\sa-zA-Z0-9\-_\.ÆØÅæøå]'){

    Write-Host "Whoops --> You have used illegal characters in email alias!" -foregroundcolor red
    Write-Host "Distributionsliste Display Name, Må kun indeholde [^\sa-zA-Z0-9\-_\.ÆØÅæøå] (eksempel: IT supportere)" -ForegroundColor Yellow
    Write-Host "Better luck next time, exiting script!" -ForegroundColor Cyan
    pause
    return
}


Write-Host "Opretter Distributionsgruppe i SST AD." -foregroundcolor Cyan
#PSdrive blev oprettet ved login script, som er ikke en del af den her execution.
Set-Location -Path 'SSTAD:'


    If ($company -eq "1") {
    New-ADGroup -Name $GroupDispName -GroupScope Universal -GroupCategory Distribution -ManagedBy $Manager -Description $Description -Path $OUPathDistrubutionslisterSST
    Write-Host "TimeOut for 20 sek." -foregroundcolor Cyan
    sleep 20
    
    #Set-ADGroup -Identity $GroupAlias -Clear Company
    Write-Host "Opdaterer 'Company' felt og tilføje  email adresse til gruppen" -foregroundcolor Cyan
    $GroupMail = $GroupAlias+'@sst.dk'
    Set-ADGroup -Identity $GroupDispName -Add @{company="Sundhedsstyrelsen";mail="$GroupMail"}
    }
    ElseIf ($company -eq "2") {
    New-ADGroup -Name $GroupDispName -GroupScope Universal -GroupCategory Distribution -ManagedBy $Manager -Description $Description -Path $OUPathDistrubutionslisterDEP
    
    Write-Host "TimeOut for 20 sek." -foregroundcolor Cyan
    sleep 20
    
    #Set-ADGroup -Identity $GroupAlias -Clear Company
    Write-Host "Opdaterer 'Company' felt og tilføje  email adresse til gruppen" -foregroundcolor Cyan
    $GroupMail = $GroupAlias+'@sum.dk'
    Set-ADGroup -Identity $GroupDispName -Add @{company="Sundheds- og Ældreministeriet";mail="$GroupMail"}
    }
    If ($company -eq "3") {
    New-ADGroup -Name $GroupDispName -GroupScope Universal -GroupCategory Distribution -ManagedBy $Manager -Description $Description -Path $OUPathDistrubutionslisterSTPS
    
    Write-Host "TimeOut for 20 sek." -foregroundcolor Cyan
    sleep 20
    
    #Set-ADGroup -Identity $GroupAlias -Clear Company
    Write-Host "Opdaterer 'Company' felt og tilføje  email adresse til gruppen" -foregroundcolor Cyan
    $GroupMail = $GroupAlias+'@stps.dk'
    Set-ADGroup -Identity $GroupDispName -Add @{company="Styrelsensen for Patientsikkerhed";mail="$GroupMail"}
    }
    If ($company -eq "4") {
    New-ADGroup -Name $GroupDispName -GroupScope Universal -GroupCategory Distribution -ManagedBy $Manager -Description $Description -Path $OUPathDistrubutionslisterNGC
    
    Write-Host "TimeOut for 20 sek." -foregroundcolor Cyan
    sleep 20
    
    #Set-ADGroup -Identity $GroupAlias -Clear Company
    Write-Host "Opdaterer 'Company' felt og tilføje  email adresse til gruppen" -foregroundcolor Cyan
    $GroupMail = $GroupAlias+'@ngc.dk'
    Set-ADGroup -Identity $GroupDispName -Add @{company="Nationalt Genom Center";mail="$GroupMail"}
    }
    Else{
    Write-Warning "Mislykkedes oprette og opdatere 'Company' felt på gruppen $GroupAlias fordi gruppen
    findes ikke i AD, eller der er ikke valgt korrekt Company værdi."
    }

sleep 120

if ([bool](Get-ADGroup -Filter  {SamAccountName -eq $GroupDispName})) 
{
    Write-Host "E-Mail aktivering af gruppen i Exchange 2010" -foregroundcolor Cyan
    Write-Host "Enable-DistributionGroup required LOGIN + PWD as it cannot take credentials as parameter :/" -foregroundcolor Yellow
    Enable-SSTDistributionGroup -Identity $GroupDispName
    #Disable-SSIDistributionGroup $GroupDispName
    If ($company -eq "1") {
    $new = $GroupAlias + "@sst.dk"
    Set-SSTDistributionGroup $GroupDispName -PrimarySMTPAddress $new -EmailAddressPolicyEnabled $false

    }
    ElseIf ($company -eq "2") {
    $new = $GroupAlias + "@sum.dk"
    Set-SSTDistributionGroup $GroupDispName -PrimarySMTPAddress $new -EmailAddressPolicyEnabled $false
    }
    If ($company -eq "3") {
    $new = $GroupAlias + "@stps.dk"
    Set-SSTDistributionGroup $GroupDispName -PrimarySMTPAddress $new -EmailAddressPolicyEnabled $false
    }
    If ($company -eq "4") {
    $new = $GroupAlias + "@ngc.dk"
    Set-SSTDistributionGroup $GroupDispName -PrimarySMTPAddress $new -EmailAddressPolicyEnabled $false
    }
}
Else
{
    Write-Warning "Mislykkedes at e-mail aktivere $GroupAlias, da gruppen muligvis ikke findes i DKSUND/Exchange 2016..."
}

Write-Host "Tilføjer $Manager til  gruppen $GroupDispName medlemskab." -foregroundcolor Cyan
Add-ADGroupMember -Identity $GroupDispName -Members $Manager
#Write-Host "Tilføjer $Manager til  gruppen 'U-SSI-CTX-Standard applikationer' medlemskab." -foregroundcolor Cyan
#Add-ADGroupMember -Identity 'U-SSI-CTX-Standard applikationer' -Members  $Manager

#Der kommer en lang WARNING med nedenstående kommando, virker ikke!
#Add-ADPermission -Identity $GroupDispName -User $Manager -AccessRights WriteProperty -Properties "Member"


Write-Host "Noter følgende i Sagens løsningsbeksrivelse:" -foregroundcolor Yellow -backgroundcolor DarkCyan
$ResultGroupName = (Get-SSTGroup $GroupDispName).DisplayName
Write-Host "Distrubutionsgruppe oprettet: $ResultGroupName" -foregroundcolor Green -backgroundcolor DarkCyan
$ResultGroupAlias = (Get-SSTGroup $GroupDispName).WindowsEmailAddress
Write-Host "Distrubutionsgruppe oprettet: $ResultGroupAlias" -foregroundcolor Green -backgroundcolor DarkCyan
Write-Host "Ejer: $Manager" -foregroundcolor Green -backgroundcolor DarkCyan
Pause