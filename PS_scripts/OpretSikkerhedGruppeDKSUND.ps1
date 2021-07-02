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
$ISEScriptPath = (Get-Location).Path | Split-Path -Parent -ErrorAction SilentlyContinue; $ISEScriptPathReconnect = "$ISEScriptPath\Logins\Session_reconnect.ps1"
$PSscriptPath =  $PSScriptRoot | Split-Path -Parent -ErrorAction SilentlyContinue; $PSscriptPathReconnect = "$PSscriptPath\Logins\Session_reconnect.ps1"
#*********************************************************************************************************************************************
#Variabler
#****************
#dksund.dk/Organisationer/STPK/Grupper/
$OUPathForADgrouperSTPK = 'OU=Grupper,OU=STPK,OU=Organisationer,DC=dksund,DC=dk'
#dksund.dk/Organisationer/STPK/Shared mailbox/
$OUPathSharedMailSTPK = 'OU=Shared mailbox,OU=STPK,OU=Organisationer,DC=dksund,DC=dk'


$ADuser = Read-Host -Prompt "Angiv eksisterende fællespostkasse Navn/Alias på minimum 5 og max 20 karakterer, Må indeholde kun [^a-zA-Z0-9\-_\.] (f.eks Servicedesk):"
$company = Read-Host -Prompt "Tast 6 for stpk.dk til at vælge passende adresse."
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

Write-Host "Skifter til DKSUND AD" -foregroundcolor Yellow
Set-Location -Path 'DKSUNDAD:'

    if ($company -eq "6"){
        
        New-ADGroup -Name $ADgroup -GroupScope Universal -GroupCategory Security -ManagedBy $Manager -Description $ADgroupDescription -Path $OUPathForADgrouperSTPK
        Write-Host "TimeOut for 20 sek." -foregroundcolor Yellow 
        Start-Sleep 20
        
        Write-Host "Opdaterer 'Company' felt og tilføje  email adresse til gruppen" -foregroundcolor Cyan
        $GroupMail = $ADgroup+'@stpk.dk'
        Set-ADGroup -Identity $ADgroup -Add @{company="STYRELSEN FOR PATIENTKLAGER";mail="$GroupMail"}
        
        Write-Host "Tilføjer $Manager til  gruppen 'CTX_G_DKS_Standard_STPK' medlemskab." -foregroundcolor Cyan
        Add-ADGroupMember -Identity 'CTX_G_DKS_Standard_STPK' -Members  $Manager -ErrorAction SilentlyContinue
    }
    Else { 
    Write-Warning "Mislykkedes at oprette $ExchangeSikkerhedsgruppe, Noget gik galt..."
    }


Write-Host "Tilføjer $Manager til gruppen $ADgroup medlemskab." -foregroundcolor Cyan
Add-ADGroupMember -Identity $ADgroup -Members $Manager

Write-Host "time out 2 min (Synkroniserer i AD)" -foregroundcolor Yellow 
sleep 120


Write-Host "Connecting to Sessions" -ForegroundColor Magenta
if (Test-Path $ISEScriptPathReconnect){ Invoke-Expression $ISEScriptPathReconnect }elseif(test-path $PSscriptPathReconnect){Invoke-Expression $PSscriptPathReconnect}

    if ([bool](Get-ADGroup -Filter  {SamAccountName -eq $ADgroup})) 
    {
        Write-Host "E-Mail aktivering af gruppen i Exchange 2016 SST" -foregroundcolor Cyan
        Enable-SSIDistributionGroup -Identity $ADgroup -ErrorAction Stop
    
        if($company -eq "6"){
                Write-Host "Tilføjer primær '@stpk.dk' smtp adressen og disabled email politik for $ADgroup på Exchange 2016 SST" -foregroundcolor Cyan
                $new = $ADgroup + "@stpk.dk"
                Set-SSIDistributionGroup $ADgroup -PrimarySMTPAddress $new -EmailAddressPolicyEnabled $false
                sleep 60
            }
        }
        Else {
            Write-Warning "Fejlede i at tilføje primær smtp."        
        }  
    }
    Else
    {
        Write-Warning "Kunne ikke e-mail aktivere $ADgroup, da gruppen muligvis ikke findes i DKSUND/Exchange 2016, eller noget gik  galt." -ErrorAction Stop
    }


Write-Host "Connecting to Sessions" -ForegroundColor Magenta
if (Test-Path $ISEScriptPathReconnect){ Invoke-Expression $ISEScriptPathReconnect }elseif(test-path $PSscriptPathReconnect){Invoke-Expression $PSscriptPathReconnect}

Write-Host "Tilføjer sikkerhedsgruppe $ADgroup som 'FUll access & Send As' på $ADuser" -foregroundcolor Cyan     

if (-not ($ADuser -eq "*" -or $ADuser -eq "")) {
     
     Get-SSIMailbox -identity $ADuser | add-SSImailboxpermission -user $ADgroup -accessrights FullAccess -inheritancetype All
     Add-SSIADPermission $ADuser -User $ADgroup -Extendedrights "Send As"
     Get-SSIADPermission -Identity $ADuser | where {$_.ExtendedRights -like 'Send*'} | Format-Table -Auto User,Deny,ExtendedRights
     #Man kan tilføje individuelle brugere, men ikke grupper. Søgning giver ingen resultater, hvis man gør det med GUI.
     Set-SSIMailbox -Identity $ADuser -GrantSendOnBehalfTo $ADgroup
     Get-SSIMailbox -Identity $ADuser | Format-List GrantSendOnBehalfTo
     
}
Else { write-host "Mislykkedes at tilknytte sikkerhedsgruppe: $ADgroup adgang til fællespostkasse: $ADuser..." }

Write-Host "Connecting to Sessions" -ForegroundColor Magenta
if (Test-Path $ISEScriptPathReconnect){ Invoke-Expression $ISEScriptPathReconnect }elseif(test-path $PSscriptPathReconnect){Invoke-Expression $PSscriptPathReconnect}

Write-Host "Opretter regel at Mail som er sendt fra shared postkasse, bliver lagt 2 steder, nemlig i sendt items hos bruger og i selve fællespostkasse." -foregroundcolor Cyan 
#exchnage 2010:
#Set-SSIMailboxSentItemsConfiguration -Identity  $ADUser -SendAsItemsCopiedTo SenderAndFrom
#Echnage 2016:
Set-SSIMailbox  -Identity $ADUser -MessageCopyForSentAsEnabled $true -ErrorAction SilentlyContinue
Set-SSIMailbox  -Identity $ADUser -MessageCopyForSendOnBehalfEnabled $true

Write-Host "Sætter standard sprog til DK" -foregroundcolor Cyan 
Set-SSIMailboxRegionalConfiguration –identity $ADuser –language da-dk -LocalizeDefaultFolderName
#read changes
Get-SSIMailbox -Identity $ADuser| Format-List DisplayName,PrimarySmtpAddress,RecipientTypeDetails, MessageCopyForSentAsEnabled,MessageCopyForSendOnBehalfEnabled, Languages


Write-Host "Ændrer kalender rettighed af $ADuser til LimitedDetails " -foregroundcolor Cyan 
$MailCalenderPath = "$ADuser" + ":\Kalender"
Set-SSImailboxfolderpermission –identity $MailCalenderPath –user Default –Accessrights LimitedDetails
Get-SSIMailboxFolderPermission -Identity $MailCalenderPath


Write-Host "Time out 1 min..." -foregroundcolor Yellow 
sleep 60
Write-Host "Connecting to Sessions" -ForegroundColor Magenta
if (Test-Path $ISEScriptPathReconnect){ Invoke-Expression $ISEScriptPathReconnect }elseif(test-path $PSscriptPathReconnect){Invoke-Expression $PSscriptPathReconnect}

# OBS. flueben at manager af sikkerhedsgruppe kan opdateret medlemskab
#Add-ADPermission -Identity $ADgroup -User $Manager -AccessRights WriteProperty -Properties "Member"
Set-SSIDistributionGroup -Identity $ADgroup -ManagedBy $Manager


Write-Host "Obs! Husk at sætte hak i Manager må godt opdatere medlemskabsliste på sikkerhedsgruppe $ADgroup, da dette kan ikke automatiseres pt. !!!!" -foregroundcolor Yellow -backgroundcolor DarkCyan
Write-Host "Noter følgende i Sagens løsningsbeksrivelse:" -foregroundcolor Yellow -backgroundcolor DarkCyan
$ResultMailboxType = (Get-SSIMailbox $ADuser).RecipientTypeDetails
Write-Host "Postkasse type: $ResultMailboxType" -foregroundcolor Green -backgroundcolor DarkCyan
$ResultSharedmail = (Get-SSIMailbox "$ADuser").PrimarySmtpAddress
Write-Host "Fællespostkasse oprettet: $ResultSharedmail" -foregroundcolor Green -backgroundcolor DarkCyan
$ResultGroup = (Get-SSIGroup $ADgroup).WindowsEmailAddress
Write-Host "Tilhørende sikkerhedsgruppe oprettet: $ResultGroup" -foregroundcolor Green -backgroundcolor DarkCyan
Write-Host "Ejer: $Manager" -foregroundcolor Green -backgroundcolor DarkCyan
Pause


<#Fejlfinding
Get-SSIMailbox $ADuser | fl
Get-ADGroup -Filter  {SamAccountName -eq 'samarbejdsogarbejdsmiljoeudvalget'} -Server $ServerNameDKSUND #http://stackoverflow.com/questions/6307127/hiding-errors-when-using-get-adgroup
Get-ADGroup -Filter  {SamAccountName -eq 'samarbejdsogarbejdsmiljoeudvalget'} -Credential $UserCredDksund -AuthType Negotiate -Server $ServerNameDKSUND
get-RemoteMailbox $ADuser
get-ADUser $ADuser
get-RemoteUserMailbox $ADuser
Disable-RemoteMailbox $ADuser
get-remotemailbox
get-SSImailbox
#Fejlfinding#>