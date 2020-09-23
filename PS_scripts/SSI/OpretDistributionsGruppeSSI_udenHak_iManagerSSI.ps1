#PSVersion 5 Script made/assembled by Rust@m 13-07-2017
cls; Write-Host "Du har valgt OpretDistributionsGruppeSSI_udenHak_iManagerSSI.ps1" -ForegroundColor Gray -BackgroundColor DarkCyan
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
[string]$ADgroup = Read-Host -Prompt "Angiv distributionsliste EMAIL, Må kun indeholde [^a-zA-Z0-9_-] (eksempel: itsupportere)"
[string]$GroupDispName = Read-Host -Prompt "Angiv distributionliste DisplayName eller gentag Alias, må kun indeholde [^\sa-zA-Z0-9_-ÆØÅæøå] (eksempel: IT supportere)"
[string]$Manager = Read-Host -Prompt 'Angiv distributionsliste Ejer'
[string]$company = Read-Host "Tast 1 for SSI eller 2 for Sundhedsdatastyrelsen (så får den @ssi.dk eller @sundhedsdata.dk)"
[string]$ADgroupDescription = Read-Host -Prompt "Angiv beskrivelse af hvad vil den bruger til? (eller skriv '.' til at springe over N/A)"

Write-Host "AdObjekt angivet til $ADgroup, $GroupDispName " -foregroundcolor Cyan

##Check for illegal Characters i email alias
if($ADgroup -match  '[^a-zA-Z0-9\-_\.]'){

    Write-Host "Whoops --> You have used illegal characters in email alias!" -foregroundcolor red
    Write-Host "Distributionsliste EMAIL, Må kun indeholde [^a-zA-Z0-9-_.] (eksempel: itsupportere)" -ForegroundColor Yellow
    Write-Host "Better luck next time,, script skifter til hoved menu" -foregroundcolor red
    & "$PSScriptRoot\BrugeradmSDmenu.ps1"
}

##Check for illegal Characters
if($GroupDispName -match  '[^\sa-zA-Z0-9_\-ÆØÅæøå]'){

    Write-Host "Whoops --> You have used illegal characters in email alias!" -foregroundcolor red
    Write-Host "Distributionsliste Display Name, Må kun indeholde [^\sa-zA-Z0-9_\-ÆØÅæøå] (eksempel: IT supportere)" -ForegroundColor Yellow
    Write-Host "Better luck next time,, script skifter til hoved menu" -foregroundcolor red
    & "$PSScriptRoot\BrugeradmSDmenu.ps1"
}


Write-Host "Opretter Distributionsgruppe i SSI AD." -foregroundcolor Cyan
Set-Location -Path 'SSIAD:'
<#
If ($company -eq "1") {
    New-ADGroup -Name $GroupDispName -GroupScope Universal -GroupCategory Distribution -ManagedBy $Manager -Description $ADgroupDescription -Path $OUPathDistrubutionslisterSSI
    Write-Host "TimeOut for 20 sek." -foregroundcolor Cyan
    Start-Sleep 20
    
    #Set-ADGroup -Identity $ADgroup -Clear Company
    Write-Host "Opdaterer 'Company' felt og tilføje  email adresse til gruppen" -foregroundcolor Cyan
    $GroupMail = $ADgroup+'@ssi.dk'
    Set-ADGroup -Identity $GroupDispName -Add @{company="Statens Serum Institut";mail="$GroupMail"}
    }
    ElseIf ($company -eq "2") {
    New-ADGroup -Name $GroupDispName -GroupScope Universal -GroupCategory Distribution -ManagedBy $Manager -Description $ADgroupDescription -Path $OUPathDistrubutionslisterSSI
    
    Write-Host "TimeOut for 20 sek." -foregroundcolor Cyan
    Start-Sleep 20
    
    #Set-ADGroup -Identity $ADgroup -Clear Company
    Write-Host "Opdaterer 'Company' felt og tilføje  email adresse til gruppen" -foregroundcolor Cyan
    $GroupMail = $ADgroup+'@sundhedsdata.dk'
    Set-ADGroup -Identity $GroupDispName -Add @{company="Sundhedsdatastyrelsen";mail="$GroupMail"}
    }
    Else{
    Write-Warning "Mislykkedes oprette og opdatere 'Company' felt på gruppen $ADgroup fordi gruppen
    findes ikke i AD, eller der er ikke valgt korrekt Company værdi."
    }
#>

do
{
    switch ($company)
    {
           '1' {
                  New-ADGroup -Name $GroupDispName -GroupScope Universal -GroupCategory Distribution -ManagedBy $Manager -Description $ADgroupDescription -Path $OUPathDistrubutionslisterSSI
                  Write-Host "TimeOut for 20 sek." -foregroundcolor Yellow 
                  Start-Sleep 20

                  #Set-ADGroup -Identity $ADgroup -Clear Company
                  Write-Host "Opdaterer 'Company' felt og tilføje  email adresse til gruppen" -foregroundcolor Cyan
                  $GroupMail = $ADgroup+'@ssi.dk'
                  Set-ADGroup -Identity $GroupDispName -Add @{company="Statens Serum Institut";mail="$GroupMail"}
	  }
        
          '2' {
                  New-ADGroup -Name $GroupDispName -GroupScope Universal -GroupCategory Distribution -ManagedBy $Manager -Description $ADgroupDescription -Path $OUPathDistrubutionslisterSSI
                  Write-Host "TimeOut for 20 sek." -foregroundcolor Yellow 
                  Start-Sleep 20

                  #Set-ADGroup -Identity $ADgroup -Clear Company
                  Write-Host "Opdaterer 'Company' felt og tilføje  email adresse til gruppen" -foregroundcolor Cyan
                  $GroupMail = $ADgroup+'@sundhedsdata.dk'
                  Set-ADGroup -Identity $GroupDispName -Add @{company="Sundhedsdatastyrelsen";mail="$GroupMail"}
	  }
          Default {
                  $company = Read-Host -Prompt "Tast 1 for @ssi.dk eller 2 for @sundhedsdata.dk til at vælge passende adresse."
          
          }
    }

}
until (($company -eq '1') -or ($company -eq '2'))

Write-Host "Tilføjer $Manager til  gruppen $GroupDispName medlemskab." -foregroundcolor Cyan
Add-ADGroupMember -Identity $GroupDispName -Members $Manager
Write-Host "Tilføjer $Manager til  gruppen 'U-SSI-CTX-Standard applikationer' medlemskab." -foregroundcolor Cyan
Add-ADGroupMember -Identity 'U-SSI-CTX-Standard applikationer' -Members  $Manager

#Get-ADGroup -Filter  {SamAccountName -eq 'samarbejdsogarbejdsmiljoeudvalget'} -Server $ServerNameDKSUND #http://stackoverflow.com/questions/6307127/hiding-errors-when-using-get-adgroup

<#
Write-Host "TimeOut på 3 timmer, til AD gruppe synkroniseres med DKSUND, venter synkronisering...." -foregroundcolor Yellow
Start-Sleep 10800
#>
Write-Host "Obs! Husk at sætte hak i Manager kan opdatere medlemskabsliste, da dette del kan ikke automatiseres pt. !!!!" -foregroundcolor Yellow -backgroundcolor DarkCyan

Write-Host "Skifter til DKSUND AD" -foregroundcolor Yellow
Set-Location -Path 'DKSUNDAD:'


Write-Host "Forsøger at E-Mail aktivere Sikkerhedsgruppe $ADgroup  i Exchange 2016" -foregroundcolor Yellow
do
{
    
    Start-Sleep 600
    $i++
    IF([bool](Get-AzureADGroup -Filter "DisplayName eq '$ADgroup'"))
    {

        switch ($company)
        {
            '1' {
        
                    Write-Host "Connecting to Sessions" -ForegroundColor Magenta
                    $reconnect =  $PSScriptRoot | Split-Path -Parent | Split-Path -Parent; Invoke-Expression "$reconnect\Logins\Session_reconnect.ps1"
                    
                    Write-Host "E-Mail aktivering af Sikkerhedsgruppe $ADgroup i Exchange 2016" -foregroundcolor Cyan
                    Enable-SSIDistributionGroup -Identity $GroupDispName -ErrorAction Stop
                    
                    Write-Host "Tilføjer primær smtp adressen og disabled email politik for $ADgroup på Exchange 2016" -foregroundcolor Cyan
                    $new = $ADgroup + "@ssi.dk"
                    Set-SSIDistributionGroup $GroupDispName -PrimarySMTPAddress $new -EmailAddressPolicyEnabled $false 
        
                }
            
            '2' {
        
                    Write-Host "Connecting to Sessions" -ForegroundColor Magenta
                    $reconnect =  $PSScriptRoot | Split-Path -Parent | Split-Path -Parent; Invoke-Expression "$reconnect\Logins\Session_reconnect.ps1"
                    
                    Write-Host "E-Mail aktivering af Sikkerhedsgruppe $ADgroup i Exchange 2016" -foregroundcolor Cyan
                    Enable-SSIDistributionGroup -Identity $GroupDispName -ErrorAction Stop
                    
                    Write-Host "Tilføjer primær smtp adressen og disabled email politik for $ADgroup på Exchange 2016" -foregroundcolor Cyan
                    $new = $ADgroup + "@sundhedsdata.dk"
                    Set-SSIDistributionGroup $GroupDispName -PrimarySMTPAddress $new -EmailAddressPolicyEnabled $false 
        
                }
             Default {$company = Read-Host -Prompt "Tast 1 for @ssi.dk eller 2 for @sundhedsdata.dk til at vælge passende adresse."}
        }

    }
 
    if ($i -eq 18) {
    Write-Warning "Kunne ikke e-mail aktivere $ADgroup, da gruppen muligvis ikke findes i DKSUND/Exchange 2016, eller noget gik  galt."}

}
until ((Get-AzureADGroup -Filter "DisplayName eq '$ADgroup'") -or ($i -ge 18 ) )

Write-Host "TimeOut for 20 sek." -foregroundcolor Cyan
Start-Sleep 20


Write-Host "Connecting to Sessions" -ForegroundColor Magenta
$reconnect =  $PSScriptRoot | Split-Path -Parent | Split-Path -Parent; Invoke-Expression "$reconnect\Logins\Session_reconnect.ps1"

Write-Host "Obs! Husk at sætte hak i Manager kan opdatere medlemskabsliste, da dette kan ikke automatiseres pt. !!!!" -foregroundcolor Yellow -backgroundcolor DarkCyan

Write-Host "Noter følgende i Nilex løsningsbeksrivelse:" -foregroundcolor Yellow -backgroundcolor DarkCyan
$ResultGroupName = (Get-Group $GroupDispName).DisplayName
Write-Host "Distrubutionsgruppe Display Name: $ResultGroupName" -foregroundcolor Green -backgroundcolor DarkCyan
$ResultGroupAlias = (Get-Group $GroupDispName).WindowsEmailAddress
Write-Host "Distrubutionsgruppe oprettet: $ResultGroupAlias" -foregroundcolor Green -backgroundcolor DarkCyan
Write-Host "Ejer: $Manager" -foregroundcolor Green -backgroundcolor DarkCyan
Pause