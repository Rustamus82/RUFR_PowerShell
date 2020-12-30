#PSVersion 5 Script made/assembled by Rust@m 13-07-2017
cls; Write-Host "Du har valgt OpretSikkerhedGruppeSSI_udenHak_iManagerSSI.ps1" -ForegroundColor Gray -BackgroundColor DarkCyan
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
[string]$ADgroup =  Read-Host -Prompt "Angiv Sikkerhedsgruppe navn til eksisterende fællespostkasse, må indeholde kun [^a-zA-Z0-9\-_\.] (f.eks. GRP-servicedesk)"
[string]$Manager = Read-Host -Prompt 'Angiv Ejers INITIALER til Sikkerhedsgruppe'
[string]$company = Read-Host "Tast 1 for SSI eller 2 for Sundhedsdatastyrelsen (så får den @ssi.dk eller @sundhedsdata.dk)"
[string]$ADgroupDescription = "Giver fuld adgang til fællespostkasse"

Write-Host "AdObjekt angivet til $ADgroup" -foregroundcolor Yellow

##Check for illegald Characters
if($ADgroup -match  '[^a-zA-Z0-9\-_\.]'){

    Write-Host "Whoops --> You have used illegal characters in email alias!" -foregroundcolor red
    Write-Host "Sikkerhedsgruppe, Må kun indeholde [^a-zA-Z0-9\-_\.] (eksempel: GRP-servicedesk)" -ForegroundColor Yellow
    Write-Host "Better luck next time, returning to manu" -ForegroundColor Cyan
    pause
    return
}


Write-Host "Opretter AD objekt $ADgroup i SSI AD" -foregroundcolor Cyan
Set-Location -Path 'SSIAD:'

<#
if ($company -eq "1"){
    
    New-ADGroup -Name $ADgroup -GroupScope Universal -GroupCategory Security -ManagedBy $Manager -Description $ADgroupDescription -Path $OUPathForExchangeSikkerhedsgrupperSSI
    Write-Host "TimeOut for 20 sek." -foregroundcolor Yellow 
    Start-Sleep 20

    Write-Host "Opdaterer 'Company' felt og tilføje  email adresse til gruppen" -foregroundcolor Cyan
    $GroupMail = $ADgroup+'@ssi.dk'
    Set-ADGroup -Identity $ADgroup -Add @{company="Statens Serum Institut";mail="$GroupMail"}
}
Elseif ($company -eq "2") {
    New-ADGroup -Name $ADgroup -GroupScope Universal -GroupCategory Security -ManagedBy $Manager -Description $ADgroupDescription -Path $OUPathForExchangeSikkerhedsgrupperSDS
    Write-Host "TimeOut for 20 sek." -foregroundcolor Yellow 
    Start-Sleep 20

    Write-Host "Opdaterer 'Company' felt og tilføje  email adresse til gruppen" -foregroundcolor Cyan
    $GroupMail = $ADgroup+'@sundhedsdata.dk'
    Set-ADGroup -Identity $ADgroup -Add @{company="Sundhedsdatastyrelsen";mail="$GroupMail"}
}
Else 
{ Write-Warning "Mislykkedes at oprette $ADgroup, Noget gik galt..."}


Write-Host "Tilføjer $Manager til  gruppen $ADgroup medlemskab." -foregroundcolor Cyan
Add-ADGroupMember -Identity $ADgroup -Members $Manager 
Write-Host "Tilføjer $Manager til  gruppen 'U-SSI-CTX-Standard applikationer' medlemskab." -foregroundcolor Cyan
Add-ADGroupMember -Identity 'U-SSI-CTX-Standard applikationer' -Members  $Manager



#Venter Synkronisering til DKSUND
Write-Host "Time out 3 timer. venter til konti synkroniseret til DKSUND" -foregroundcolor Yellow
Write-Host "Obs! Husk at sætte hak i Manager kan opdatere medlemskabsliste, da dette del kan ikke automatiseres pt. !!!!" -foregroundcolor Yellow -backgroundcolor DarkCyan
Start-Sleep 10800

Write-Host "Skifter til DKSUND AD" -foregroundcolor Yellow
Set-Location -Path 'DKSUNDAD:'

Write-Host "Connecting to Sessions" -ForegroundColor Magenta
$reconnect =  $PSScriptRoot | Split-Path -Parent | Split-Path -Parent; Invoke-Expression "$reconnect\Logins\Session_reconnect.ps1"

Write-Host "E-Mail aktivering af $ADgroup i Exchange 2016" -foregroundcolor Cyan
if ([bool](Get-ADGroup -Filter  {SamAccountName -eq $ADgroup})) 
{
    Write-Host "E-Mail aktivering af gruppen i Exchange 2016" -foregroundcolor Cyan
    Enable-SSIDistributionGroup -Identity $ADgroup -ErrorAction Stop
    #Disable-SSIDistributionGroup -Identity $ADgroup -ErrorAction Stop
    Write-Host "Tilføjer primær smtp adressen og disabled email politik for $ADgroup på Exchange 2016" -foregroundcolor Cyan
    $new = $ADgroup + "@ssi.dk"
    Set-SSIDistributionGroup $ADgroup -PrimarySMTPAddress $new -EmailAddressPolicyEnabled $false
        
}
Else
{
    Write-Warning "Kunne ikke e-mail aktivere $ADgroup, da gruppen muligvis ikke findes i DKSUND/Exchange 2016, eller noget gik  galt." -ErrorAction Stop
}

#>

do
{
    switch ($company)
    {
           '1' {
                  New-ADGroup -Name $ADgroup -GroupScope Universal -GroupCategory Security -ManagedBy $Manager -Description $ADgroupDescription -Path $OUPathForExchangeSikkerhedsgrupperSSI
                  Write-Host "TimeOut for 20 sek." -foregroundcolor Yellow 
                  Start-Sleep 20

                  #Set-ADGroup -Identity $ADgroup -Clear Company
                  Write-Host "Opdaterer 'Company' felt og tilføje  email adresse til gruppen" -foregroundcolor Cyan
                  $GroupMail = $ADgroup+'@ssi.dk'
                  Set-ADGroup -Identity $ADgroup -Add @{company="Statens Serum Institut";mail="$GroupMail"}
	  }
        
          '2' {
                  New-ADGroup -Name $ADgroup -GroupScope Universal -GroupCategory Security -ManagedBy $Manager -Description $ADgroupDescription -Path $OUPathForExchangeSikkerhedsgrupperSDS
                  Write-Host "TimeOut for 20 sek." -foregroundcolor Yellow 
                  Start-Sleep 20

                  #Set-ADGroup -Identity $ADgroup -Clear Company
                  Write-Host "Opdaterer 'Company' felt og tilføje  email adresse til gruppen" -foregroundcolor Cyan
                  $GroupMail = $ADgroup+'@sundhedsdata.dk'
                  Set-ADGroup -Identity $ADgroup -Add @{company="Sundhedsdatastyrelsen";mail="$GroupMail"}
	  }
          Default {
                  $company = Read-Host -Prompt "Tast 1 for @ssi.dk eller 2 for @sundhedsdata.dk til at vælge passende adresse."
          
          }
    }

}
until (($company -eq '1') -or ($company -eq '2'))

Write-Host "Tilføjer $Manager til  gruppen $ADgroup medlemskab." -foregroundcolor Cyan
Add-ADGroupMember -Identity $ADgroup -Members $Manager
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
                    Enable-SSIDistributionGroup -Identity $ADgroup -ErrorAction Stop
                    
                    Write-Host "Tilføjer primær smtp adressen og disabled email politik for $ADgroup på Exchange 2016" -foregroundcolor Cyan
                    $new = $ADgroup + "@ssi.dk"
                    Set-SSIDistributionGroup $ADgroup -PrimarySMTPAddress $new -EmailAddressPolicyEnabled $false 
        
                }
            
            '2' {
        
                    Write-Host "Connecting to Sessions" -ForegroundColor Magenta
                    $reconnect =  $PSScriptRoot | Split-Path -Parent | Split-Path -Parent; Invoke-Expression "$reconnect\Logins\Session_reconnect.ps1"
                    
                    Write-Host "E-Mail aktivering af Sikkerhedsgruppe $ADgroup i Exchange 2016" -foregroundcolor Cyan
                    Enable-SSIDistributionGroup -Identity $ADgroup -ErrorAction Stop
                    
                    Write-Host "Tilføjer primær smtp adressen og disabled email politik for $ADgroup på Exchange 2016" -foregroundcolor Cyan
                    $new = $ADgroup + "@sundhedsdata.dk"
                    Set-SSIDistributionGroup $ADgroup -PrimarySMTPAddress $new -EmailAddressPolicyEnabled $false 
        
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
$ResultGroup = (Get-Group $ADgroup).WindowsEmailAddress
Write-Host "Tilhørende sikkerhedsgruppe oprettet: $ResultGroup" -foregroundcolor Green -backgroundcolor DarkCyan
Write-Host "Ejer: $Manager" -foregroundcolor Green -backgroundcolor DarkCyan
Pause