#PSVersion 5 Script made/assembled by Rust@m 21-03-2021
Write-Host "OpretSikkerhedGruppeSST.ps1" -ForegroundColor Gray -BackgroundColor DarkCyan
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
#Variabler
#****************
$OUPathForExchangeSikkerhedsgrupperSST = 'OU=SST,OU=Sikkerhedsgrupper,DC=SST,DC=dk'
$OUPathForExchangeSikkerhedsgrupperDEP = 'OU=DEP,OU=Sikkerhedsgrupper,DC=SST,DC=dk'
$OUPathForExchangeSikkerhedsgrupperSTPS = 'OU=STPS,OU=Sikkerhedsgrupper,DC=SST,DC=dk'
$OUPathForExchangeSikkerhedsgrupperNGC = 'OU=NGC,OU=Sikkerhedsgrupper,DC=SST,DC=dk'

$ADuser = Read-Host -Prompt "Angiv eksisterende fællespostkasse Navn/Alias på minimum 5 og max 20 karakterer, Må indeholde kun [^a-zA-Z0-9\-_\.] (f.eks Servicedesk):"
$company = Read-Host -Prompt "Tast 1 for sst.dk, 2 for sum.dk 3 for stps.dk eller 4 for NGC.dk til at vælge passende adresse."
$Manager = Read-Host -Prompt "Angiv Ejers INITIALER til fællespostkassen og den tilhørende sikkerhedsgruppe."

$SikkerhedsgrupperDescription = "Giver fuld adgang til fællespostkasse $ADuser"
#****************
#script execution 
#****************

#Check for illegal characters - legal are a-zA-Z0-9_-  also check for aloowed lenght from 5 to 20
if($ADuser -match '[^a-zA-Z0-9\-_\.]' -or $ADuser.Length -lt 5 -or $ADuser.Length -gt 20){

    Write-Host "Whoops --> You have used illegal characters in email alias!" -foregroundcolor red
    Write-Host "Mødelokale ALIAS på minimum 5 og max 20 karaktere, Må indeholde kun [^a-zA-Z0-9\-_\.] (eksempel: 202-213):" -ForegroundColor Yellow
    Write-Host "Better luck next time, exiting script!" -ForegroundColor Cyan
    pause
    return
}


Set-Location -Path 'SSTAD:'
    if ($company -eq "1"){
        
        $ExchangeSikkerhedsgruppe = 'SST_'+$ADuser+'_MAIL'
        Write-Host "Objekt $ADuser Findes ikke i AD til at starte med, opretter " -foregroundcolor Yellow
        Write-Host "Sikkerhedsgruppe bliver til $ExchangeSikkerhedsgruppe" -ForegroundColor Yellow
        Write-Host "Opretter AD objekt $ExchangeSikkerhedsgruppe i SST AD" -foregroundcolor Cyan
        
        New-ADGroup -Name $ExchangeSikkerhedsgruppe -GroupScope Universal -GroupCategory Security -ManagedBy $Manager -Description $SikkerhedsgrupperDescription -Path $OUPathForExchangeSikkerhedsgrupperSST
        Write-Host "TimeOut for 60 sek." -foregroundcolor Yellow 
        sleep 60

        Write-Host "Opdaterer 'Company' felt og tilføje  email adresse til gruppen" -foregroundcolor Cyan
        $GroupMail = $ExchangeSikkerhedsgruppe+'@sst.dk'
        Set-ADGroup -Identity $ExchangeSikkerhedsgruppe -Add @{company="Sundhedsstyrelsen";mail="$GroupMail"}
    }
    Elseif ($company -eq "2") {

        $ExchangeSikkerhedsgruppe = 'DEP_'+$ADuser+'_MAIL'
        Write-Host "Objekt $ADuser Findes ikke i AD til at starte med, opretter " -foregroundcolor Yellow
        Write-Host "Sikkerhedsgruppe bliver til $ExchangeSikkerhedsgruppe" -ForegroundColor Yellow
        Write-Host "Opretter AD objekt $ExchangeSikkerhedsgruppe i SST AD" -foregroundcolor Cyan

        New-ADGroup -Name $ExchangeSikkerhedsgruppe -GroupScope Universal -GroupCategory Security -ManagedBy $Manager -Description $SikkerhedsgrupperDescription -Path $OUPathForExchangeSikkerhedsgrupperDEP
        Write-Host "TimeOut for 60 sek." -foregroundcolor Yellow 
        sleep 60

        Write-Host "Opdaterer 'Company' felt og tilføje  email adresse til gruppen" -foregroundcolor Cyan
        $GroupMail = $ExchangeSikkerhedsgruppe+'@sst.dk'
        Set-ADGroup -Identity $ExchangeSikkerhedsgruppe -Add @{company="Sundheds- og Ældreministeriet";mail="$GroupMail"}
    }
    Elseif ($company -eq "3") {
        $ExchangeSikkerhedsgruppe = 'STPS_'+$ADuser+'_MAIL'
        Write-Host "Objekt $ADuser Findes ikke i AD til at starte med, opretter " -foregroundcolor Yellow
        Write-Host "Sikkerhedsgruppe bliver til $ExchangeSikkerhedsgruppe" -ForegroundColor Yellow
        Write-Host "Opretter AD objekt $ExchangeSikkerhedsgruppe i SST AD" -foregroundcolor Cyan

        New-ADGroup -Name $ExchangeSikkerhedsgruppe -GroupScope Universal -GroupCategory Security -ManagedBy $Manager -Description $SikkerhedsgrupperDescription -Path $OUPathForExchangeSikkerhedsgrupperSTPS
        Write-Host "TimeOut for 60 sek." -foregroundcolor Yellow 
        sleep 60

        Write-Host "Opdaterer 'Company' felt og tilføje  email adresse til gruppen" -foregroundcolor Cyan
        $GroupMail = $ExchangeSikkerhedsgruppe+'@sst.dk'
        Set-ADGroup -Identity $ExchangeSikkerhedsgruppe -Add @{company="Styrelsen for Patientsikkerhed";mail="$GroupMail"}
    }
    Elseif ($company -eq "4") {
        $ExchangeSikkerhedsgruppe = 'NGC_'+$ADuser+'_MAIL'
        Write-Host "Objekt $ADuser Findes ikke i AD til at starte med, opretter " -foregroundcolor Yellow
        Write-Host "Sikkerhedsgruppe bliver til $ExchangeSikkerhedsgruppe" -ForegroundColor Yellow
        Write-Host "Opretter AD objekt $ExchangeSikkerhedsgruppe i SST AD" -foregroundcolor Cyan

        New-ADGroup -Name $ExchangeSikkerhedsgruppe -GroupScope Universal -GroupCategory Security -ManagedBy $Manager -Description $SikkerhedsgrupperDescription -Path $OUPathForExchangeSikkerhedsgrupperNGC
        Write-Host "TimeOut for 60 sek." -foregroundcolor Yellow 
        sleep 60

        Write-Host "Opdaterer 'Company' felt og tilføje  email adresse til gruppen" -foregroundcolor Cyan
        $GroupMail = $ExchangeSikkerhedsgruppe+'@sst.dk'
        Set-ADGroup -Identity $ExchangeSikkerhedsgruppe -Add @{company="Nationalt Genom Center";mail="$GroupMail"}
    }
    Else { 
    Write-Warning "Mislykkedes at oprette $ExchangeSikkerhedsgruppe, Noget gik galt..."
    }


Write-Host "Tilføjer $Manager til gruppen $ExchangeSikkerhedsgruppe medlemskab." -foregroundcolor Cyan
Add-ADGroupMember -Identity $ExchangeSikkerhedsgruppe -Members $Manager
#Write-Host "Tilføjer $Manager til  gruppen 'U-SSI-CTX-Standard applikationer' medlemskab." -foregroundcolor Cyan
#Add-ADGroupMember -Identity 'U-SSI-CTX-Standard applikationer' -Members  $Manager -ErrorAction SilentlyContinue


Write-Host "time out 2 min (Synkroniserer i AD)" -foregroundcolor Yellow 
sleep 120


Write-Host "Connecting to Sessions" -ForegroundColor Magenta
#$reconnect =  $PSScriptRoot | Split-Path -Parent | Split-Path -Parent; Invoke-Expression "$reconnect\Logins\Session_reconnect.ps1"
if (Test-Path $ISEScriptPath){ Invoke-Expression $ISEScriptPath }elseif(test-path $PSscriptPath){Invoke-Expression $PSscriptPath}

    if ([bool](Get-ADGroup -Filter  {SamAccountName -eq $ExchangeSikkerhedsgruppe})) 
    {
        Write-Host "E-Mail aktivering af gruppen i Exchange 2016 SST" -foregroundcolor Cyan
        Enable-SSTDistributionGroup -Identity $ExchangeSikkerhedsgruppe -ErrorAction Stop
    
        if($company -eq "2"){
            Write-Host "Tilføjer primær '@sum.dk' smtp adressen og disabled email politik for $ExchangeSikkerhedsgruppe på Exchange 2016 SST" -foregroundcolor Cyan
        $new = $ExchangeSikkerhedsgruppe + "@sum.dk"
        Set-SSTDistributionGroup $ExchangeSikkerhedsgruppe -PrimarySMTPAddress $new -EmailAddressPolicyEnabled $false
        sleep 60
        }
        if($company -eq "3"){
            Write-Host "Tilføjer primær '@stps.dk' smtp adressen og disabled email politik for $ExchangeSikkerhedsgruppe på Exchange 2016 SST" -foregroundcolor Cyan
        $new = $ExchangeSikkerhedsgruppe + "@stps.dk"
        Set-SSTDistributionGroup $ExchangeSikkerhedsgruppe -PrimarySMTPAddress $new -EmailAddressPolicyEnabled $false
        sleep 60
        }
        if($company -eq "4"){
            Write-Host "Tilføjer primær '@ngc.dk' smtp adressen og disabled email politik for $ExchangeSikkerhedsgruppe på Exchange 2016 SST" -foregroundcolor Cyan
        $new = $ExchangeSikkerhedsgruppe + "@ngc.dk"
        Set-SSTDistributionGroup $ExchangeSikkerhedsgruppe -PrimarySMTPAddress $new -EmailAddressPolicyEnabled $false
        sleep 60
        }
        Elseif($comapny -eq "1"){
        sleep 5
        }
        Else {
            Write-Warning "Fejlede i at tilføje primær smtp."        
        }  
    }
    Else
    {
        Write-Warning "Kunne ikke e-mail aktivere $ExchangeSikkerhedsgruppe, da gruppen muligvis ikke findes i DKSUND/Exchange 2016, eller noget gik  galt." -ErrorAction Stop
    }


Write-Host "Connecting to Sessions" -ForegroundColor Magenta
#$reconnect =  $PSScriptRoot | Split-Path -Parent | Split-Path -Parent; Invoke-Expression "$reconnect\Logins\Session_reconnect.ps1"
if (Test-Path $ISEScriptPath){ Invoke-Expression $ISEScriptPath }elseif(test-path $PSscriptPath){Invoke-Expression $PSscriptPath}

Write-Host "Tilføjer sikkerhedsgruppe $ExchangeSikkerhedsgruppe som 'FUll access & Send As' på $ADuser" -foregroundcolor Cyan     

if (-not ($ADuser -eq "*" -or $ADuser -eq "")) {
     
     Get-SSTMailbox -identity $ADuser | add-sstmailboxpermission -user $ExchangeSikkerhedsgruppe -accessrights FullAccess -inheritancetype All
     Add-SSTADPermission $ADuser -User $ExchangeSikkerhedsgruppe -Extendedrights "Send As"
     Get-SSTADPermission -Identity $ADuser | where {$_.ExtendedRights -like 'Send*'} | Format-Table -Auto User,Deny,ExtendedRights
     #Man kan tilføje individuelle brugere, men ikke grupper. Søgning giver ingen resultater, hvis man gør det med GUI.
     Set-SSTMailbox -Identity $ADuser -GrantSendOnBehalfTo $ExchangeSikkerhedsgruppe
     Get-SSTMailbox -Identity $ADuser | Format-List GrantSendOnBehalfTo
     
}
Else { write-host "Mislykkedes at tilknytte sikkerhedsgruppe: $ExchangeSikkerhedsgruppe adgang til fællespostkasse: $ADuser..." }

Write-Host "Connecting to Sessions" -ForegroundColor Magenta
#$reconnect =  $PSScriptRoot | Split-Path -Parent | Split-Path -Parent; Invoke-Expression "$reconnect\Logins\Session_reconnect.ps1"
if (Test-Path $ISEScriptPath){ Invoke-Expression $ISEScriptPath }elseif(test-path $PSscriptPath){Invoke-Expression $PSscriptPath}

Write-Host "Opretter regel at Mail som er sendt fra shared postkasse, bliver lagt 2 steder, nemlig i sendt items hos bruger og i selve fællespostkasse." -foregroundcolor Cyan 
#exchnage 2010:
#Set-SSTMailboxSentItemsConfiguration -Identity  $ADUser -SendAsItemsCopiedTo SenderAndFrom
#Echnage 2016:
Set-SSTMailbox  -Identity $ADUser -MessageCopyForSentAsEnabled $true -ErrorAction SilentlyContinue
Set-SSTMailbox  -Identity $ADUser -MessageCopyForSendOnBehalfEnabled $true

Write-Host "Sætter standard sprog til DK" -foregroundcolor Cyan 
Set-SSTMailboxRegionalConfiguration –identity $ADuser –language da-dk -LocalizeDefaultFolderName
#read changes
Get-sstMailbox -Identity $ADuser| Format-List DisplayName,PrimarySmtpAddress,RecipientTypeDetails, MessageCopyForSentAsEnabled,MessageCopyForSendOnBehalfEnabled, Languages


Write-Host "Ændrer kalender rettighed af $ADuser til LimitedDetails " -foregroundcolor Cyan 
$MailCalenderPath = "$ADuser" + ":\Kalender"
Set-SSTmailboxfolderpermission –identity $MailCalenderPath –user Default –Accessrights LimitedDetails
Get-SSTMailboxFolderPermission -Identity $MailCalenderPath


Write-Host "Time out 1 min..." -foregroundcolor Yellow 
sleep 60
Write-Host "Connecting to Sessions" -ForegroundColor Magenta
#$reconnect =  $PSScriptRoot | Split-Path -Parent | Split-Path -Parent; Invoke-Expression "$reconnect\Logins\Session_reconnect.ps1"
if (Test-Path $ISEScriptPath){ Invoke-Expression $ISEScriptPath }elseif(test-path $PSscriptPath){Invoke-Expression $PSscriptPath}

# OBS. flueben at manager af sikkerhedsgruppe kan opdateret medlemskab
#Add-ADPermission -Identity $ExchangeSikkerhedsgruppe -User $Manager -AccessRights WriteProperty -Properties "Member"
Set-SSTDistributionGroup -Identity $ExchangeSikkerhedsgruppe -ManagedBy $Manager


Write-Host "Obs! Husk at sætte hak i Manager må godt opdatere medlemskabsliste på sikkerhedsgruppe $ExchangeSikkerhedsgruppe, da dette kan ikke automatiseres pt. !!!!" -foregroundcolor Yellow -backgroundcolor DarkCyan
Write-Host "Noter følgende i Sagens løsningsbeksrivelse:" -foregroundcolor Yellow -backgroundcolor DarkCyan
$ResultMailboxType = (Get-SSTMailbox $ADuser).RecipientTypeDetails
Write-Host "Postkasse type: $ResultMailboxType" -foregroundcolor Green -backgroundcolor DarkCyan
$ResultSharedmail = (Get-SSTMailbox "$ADuser").PrimarySmtpAddress
Write-Host "Fællespostkasse oprettet: $ResultSharedmail" -foregroundcolor Green -backgroundcolor DarkCyan
$ResultGroup = (Get-SSTGroup $ExchangeSikkerhedsgruppe).WindowsEmailAddress
Write-Host "Tilhørende sikkerhedsgruppe oprettet: $ResultGroup" -foregroundcolor Green -backgroundcolor DarkCyan
Write-Host "Ejer: $Manager" -foregroundcolor Green -backgroundcolor DarkCyan
Pause


#Fejlfinding
#Get-SST5Mailbox $ADuser | fl
#Get-ADGroup -Filter  {SamAccountName -eq 'samarbejdsogarbejdsmiljoeudvalget'} -Server $ServerNameDKSUND #http://stackoverflow.com/questions/6307127/hiding-errors-when-using-get-adgroup
#Get-ADGroup -Filter  {SamAccountName -eq 'samarbejdsogarbejdsmiljoeudvalget'} -Credential $UserCredDksund -AuthType Negotiate -Server $ServerNameDKSUND