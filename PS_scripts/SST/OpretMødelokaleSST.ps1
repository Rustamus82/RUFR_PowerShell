#PSVersion 5 Script made/assembled by eks-@nae 07-06-2019
Write-Host "Du har valgt OpretMødelokalleSST.ps1" -ForegroundColor Gray -BackgroundColor DarkCyan
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
$userDisplayName = Read-Host -Prompt "Tast Displayname på mødelokalet, f.eks SST Mødelokale 402"
$ADuser =  Read-Host -Prompt "Tast 'Alias' på nyt mødelokale min.5 og max. 20 karakterer, Må indeholde kun [^a-zA-Z0-9\-_\.] - (eksempel: 202-213)"
$Manager =  Read-Host -Prompt "Angiv Ejers INITIALER på Mødelokalle/sikkerhedsgruppen"
$Capacity =  Read-Host -Prompt "Tast 'antal' personer for kapacitet af mødelokalet"
$company = Read-Host -Prompt "Tast 1 for @sst.dk, 3 for @stps.dk eller 4 for @ngc.dk for den tilhørende postkasse"

$OUpathRoomSST = 'OU=eLokaler,OU=Systemkonti,DC=SST,DC=dk'

$OUPathForExchangeSikkerhedsgrupperSST = 'OU=SST,OU=Sikkerhedsgrupper,DC=SST,DC=dk'
$OUPathForExchangeSikkerhedsgrupperDEP = 'OU=DEP,OU=Sikkerhedsgrupper,DC=SST,DC=dk'
$OUPathForExchangeSikkerhedsgrupperSTPS = 'OU=STPS,OU=Sikkerhedsgrupper,DC=SST,DC=dk'
$OUPathForExchangeSikkerhedsgrupperNGC = 'OU=NGC,OU=Sikkerhedsgrupper,DC=SST,DC=dk'

$ADuserDescription = 'Mødelokale'
$SikkerhedsgrupperDescription = "Giver fuld adgang til Mødelokale $ADuser"

#Check for illegal characters - legal are a-zA-Z0-9_-  also check for aloowed lenght from 5 to 20
if($ADuser -match '[^a-zA-Z0-9\-_\.]' -or $ADuser.Length -lt 5 -or $ADuser.Length -gt 20){

    Write-Host "Whoops --> You have used illegal characters in email alias!" -foregroundcolor red
    Write-Host "Mødelokale ALIAS på minimum 5 og max 20 karakterer, Må indeholde kun [^a-zA-Z0-9\-_\.] (eksempel: 202-213):" -ForegroundColor Yellow
    Write-Host "Better luck next time, exiting script!" -ForegroundColor Cyan
    pause
    return
}


Set-Location -Path 'SSTAD:'
    if ($company -eq "1"){
        
        $ExchangeSikkerhedsgruppe = 'SST_'+$ADuser
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

        $ExchangeSikkerhedsgruppe = 'SUM_'+$ADuser
        Write-Host "Objekt $ADuser Findes ikke i AD til at starte med, opretter " -foregroundcolor Yellow
        Write-Host "Sikkerhedsgruppe bliver til $ExchangeSikkerhedsgruppe" -ForegroundColor Yellow
        Write-Host "Opretter AD objekt $ExchangeSikkerhedsgruppe i SST AD" -foregroundcolor Cyan

        New-ADGroup -Name $ExchangeSikkerhedsgruppe -GroupScope Universal -GroupCategory Security -ManagedBy $Manager -Description $SikkerhedsgrupperDescription -Path $OUPathForExchangeSikkerhedsgrupperDEP
        Write-Host "TimeOut for 60 sek." -foregroundcolor Yellow 
        sleep 60

        Write-Host "Opdaterer 'Company' felt og tilføjer  email adresse til gruppen" -foregroundcolor Cyan
        $GroupMail = $ExchangeSikkerhedsgruppe+'@sst.dk'
        Set-ADGroup -Identity $ExchangeSikkerhedsgruppe -Add @{company="Sundheds- og Ældreministeriet";mail="$GroupMail"}
    }
    Elseif($company -eq "3"){

        $ExchangeSikkerhedsgruppe = 'STPS_'+$ADuser
        Write-Host "Objekt $ADuser Findes ikke i AD til at starte med, opretter " -foregroundcolor Yellow
        Write-Host "Sikkerhedsgruppe bliver til $ExchangeSikkerhedsgruppe" -ForegroundColor Yellow
        Write-Host "Opretter AD objekt $ExchangeSikkerhedsgruppe i SST AD" -foregroundcolor Cyan

        New-ADGroup -Name $ExchangeSikkerhedsgruppe -GroupScope Universal -GroupCategory Security -ManagedBy $Manager -Description $SikkerhedsgrupperDescription -Path $OUPathForExchangeSikkerhedsgrupperSTPS
        Write-Host "TimeOut for 60 sek." -foregroundcolor Yellow 
        sleep 60

        Write-Host "Opdaterer 'Company' felt og tilføjer  email adresse til gruppen" -foregroundcolor Cyan
        $GroupMail = $ExchangeSikkerhedsgruppe+'@sst.dk'
        Set-ADGroup -Identity $ExchangeSikkerhedsgruppe -Add @{company="Styrelsen for Patientsikkerhed";mail="$GroupMail"}
    }
    Elseif($company -eq "4"){

        $ExchangeSikkerhedsgruppe = 'NGC_'+$ADuser
        Write-Host "Objekt $ADuser Findes ikke i AD til at starte med, opretter " -foregroundcolor Yellow
        Write-Host "Sikkerhedsgruppe bliver til $ExchangeSikkerhedsgruppe" -ForegroundColor Yellow
        Write-Host "Opretter AD objekt $ExchangeSikkerhedsgruppe i SST AD" -foregroundcolor Cyan

        New-ADGroup -Name $ExchangeSikkerhedsgruppe -GroupScope Universal -GroupCategory Security -ManagedBy $Manager -Description $SikkerhedsgrupperDescription -Path $OUPathForExchangeSikkerhedsgrupperNGC
        Write-Host "TimeOut for 60 sek." -foregroundcolor Yellow 
        sleep 60

        Write-Host "Opdaterer 'Company' felt og tilføjer  email adresse til gruppen" -foregroundcolor Cyan
        $GroupMail = $ExchangeSikkerhedsgruppe+'@sst.dk'
        Set-ADGroup -Identity $ExchangeSikkerhedsgruppe -Add @{company="Nationalt Genom Center";mail="$GroupMail"}
    }
    Else 
    { Write-Warning "Mislykkedes at oprette $ExchangeSikkerhedsgruppe, Noget gik galt..."}


Write-Host "Tilføjer $Manager til gruppen $ExchangeSikkerhedsgruppe medlemskab." -foregroundcolor Cyan
Add-ADGroupMember -Identity $ExchangeSikkerhedsgruppe -Members $Manager

   
Write-Host "Timeout i 20 sekunder." -foregroundcolor Yellow 
sleep 20


#Opdaterer 'Company' felt for ExchangeSikkerhedsgrupper og email


Write-Host "Opretter Mødedelokale $ADuser objekt i SST AD." -foregroundcolor Cyan
New-ADUser -Name $ADuser -DisplayName $userDisplayName -GivenName $ADuserDescription -Manager $Manager -Description $ADuserDescription -UserPrincipalName (“{0}@{1}” -f $ADuser,”sst.dk”) -ChangePasswordAtLogon $true -Path $OUpathRoomSST

Write-Host "time out 2 min (Synkroniserer i AD)" -foregroundcolor Yellow 
sleep 120

if ([bool](Get-ADuser -Filter  {Name -eq $ADuser}))
{
   Write-Host "Tilføje 'samaccount' (email) felt for $ADuser i SST AD." -foregroundcolor Cyan
   Set-ADUser $ADuser -SamAccountName $ADuser -EmailAddress $ADuser'@sst.dk' -Company 'Sundhedsstyrelsen' 
    
}
Else
{
    Write-Warning "Mislykkedes at tilføje 'samaccount' (email) felt for ad user $ADuser i SST AD."
}


sleep 120
Write-Host "Connecting to Sessions" -ForegroundColor Magenta
#$reconnect =  $PSScriptRoot | Split-Path -Parent | Split-Path -Parent; Invoke-Expression "$reconnect\Logins\Session_reconnect.ps1"
if (Test-Path $ISEScriptPath){ Invoke-Expression $ISEScriptPath }elseif(test-path $PSscriptPath){Invoke-Expression $PSscriptPath}

Write-Host "E-Mail aktivering af $ExchangeSikkerhedsgruppe i Exchange 2016 SST" -foregroundcolor Cyan
if ([bool](Get-ADGroup -Filter  {SamAccountName -eq $ExchangeSikkerhedsgruppe}))
{
    Enable-SSTDistributionGroup -Identity $ExchangeSikkerhedsgruppe
    #Disable-SSTDistributionGroup -Identity $ExchangeSikkerhedsgruppe
    $new = $ExchangeSikkerhedsgruppe + "@sst.dk"
    Write-Host "Disabled email politik på Exchange 2016 SST $ExchangeSikkerhedsgruppe" -foregroundcolor Cyan
    Set-SSTDistributionGroup $ExchangeSikkerhedsgruppe -PrimarySMTPAddress $new -EmailAddressPolicyEnabled $false
        
       
}
Else
{
    Write-Warning "Kunne ikke e-mail aktivere $ExchangeSikkerhedsgruppe, da gruppen muligvis ikke findes i Exchange 2016 SST, eller noget gik  galt." -ErrorAction Stop
}


Write-Host "Connecting to Sessions" -ForegroundColor Magenta
#$reconnect =  $PSScriptRoot | Split-Path -Parent | Split-Path -Parent; Invoke-Expression "$reconnect\Logins\Session_reconnect.ps1"
if (Test-Path $ISEScriptPath){ Invoke-Expression $ISEScriptPath }elseif(test-path $PSscriptPath){Invoke-Expression $PSscriptPath}


Write-Host "Forsøger at E-Mail aktivere fællesposkasse $ADuser på Exchange 2016 SST" -foregroundcolor Cyan       
    if ([bool](Get-ADuser -Filter  {SamAccountName -eq $ADuser})){
    Enable-SSTMailbox "$ADuser" 
    Write-Host "Time Out 1 min..."  -foregroundcolor Yellow  
    sleep 60
    
    Write-Host "Connecting to Sessions" -ForegroundColor Magenta
    #$reconnect =  $PSScriptRoot | Split-Path -Parent | Split-Path -Parent; Invoke-Expression "$reconnect\Logins\Session_reconnect.ps1"
    if (Test-Path $ISEScriptPath){ Invoke-Expression $ISEScriptPath }elseif(test-path $PSscriptPath){Invoke-Expression $PSscriptPath}

        if($company -eq "2"){
            Write-Host "Tilføjer primær smtp adressen og disabled email politik for $ExchangeSikkerhedsgruppe på Exchange 2016 SST" -foregroundcolor Cyan
        $new = $ADuser + "@sum.dk"
        Set-SSTMailbox $ADuser -PrimarySMTPAddress $new -EmailAddressPolicyEnabled $false
        sleep 60 
        }
        if($company -eq "3"){
            Write-Host "Tilføjer primær smtp adressen og disabled email politik for $ExchangeSikkerhedsgruppe på Exchange 2016 SST" -foregroundcolor Cyan
        $new = $ADuser + "@stps.dk"
        Set-SSTMailbox $ADuser -PrimarySMTPAddress $new -EmailAddressPolicyEnabled $false
        sleep 60 
        }
        if($company -eq "4"){
            Write-Host "Tilføjer primær smtp adressen og disabled email politik for $ExchangeSikkerhedsgruppe på Exchange 2016 SST" -foregroundcolor Cyan
        $new = $ADuser + "@ngc.dk"
        Set-SSTMailbox $ADuser -PrimarySMTPAddress $new -EmailAddressPolicyEnabled $false
        sleep 60 
        }
        elseif ($company -eq "1"){
        sleep 5
        }
        Else { 
            Write-Warning "Fejlede at tilføje sum.dk, stps eller ngc som primær smtp: $ADuser, noget gik galt..." 
    }

    }
    Else { 
            Write-Warning "Fejlede at E-Mail aktivere fællespostkasse/bruger: $ADuser, noget gik galt..." 
    }


Write-Host "E-Mail aktivering af Sikkerhedsgruppe $ExchangeSikkerhedsgruppe i Exchange 2016 SST" -foregroundcolor Cyan
Write-Host "Connecting to Sessions" -ForegroundColor Magenta
#$reconnect =  $PSScriptRoot | Split-Path -Parent | Split-Path -Parent; Invoke-Expression "$reconnect\Logins\Session_reconnect.ps1"
if (Test-Path $ISEScriptPath){ Invoke-Expression $ISEScriptPath }elseif(test-path $PSscriptPath){Invoke-Expression $PSscriptPath}


    if ([bool](Get-ADGroup -Filter  {SamAccountName -eq $ExchangeSikkerhedsgruppe})) 
    {
        
        if($company -eq "2"){
            Write-Host "Tilføjer primær sum smtp adressen og disabled email politik for $ExchangeSikkerhedsgruppe på Exchange 2016 SST" -foregroundcolor Cyan
        $new = $ExchangeSikkerhedsgruppe + "@sum.dk"
        Set-SSTDistributionGroup $ExchangeSikkerhedsgruppe -PrimarySMTPAddress $new -EmailAddressPolicyEnabled $false
        sleep 60
        }
        if($company -eq "3"){
            Write-Host "Tilføjer primær sum smtp adressen og disabled email politik for $ExchangeSikkerhedsgruppe på Exchange 2016 SST" -foregroundcolor Cyan
        $new = $ExchangeSikkerhedsgruppe + "@stps.dk"
        Set-SSTDistributionGroup $ExchangeSikkerhedsgruppe -PrimarySMTPAddress $new -EmailAddressPolicyEnabled $false
        sleep 60
        }
        if($company -eq "4"){
            Write-Host "Tilføjer primær sum smtp adressen og disabled email politik for $ExchangeSikkerhedsgruppe på Exchange 2016 SST" -foregroundcolor Cyan
        $new = $ExchangeSikkerhedsgruppe + "@ngc.dk"
        Set-SSTDistributionGroup $ExchangeSikkerhedsgruppe -PrimarySMTPAddress $new -EmailAddressPolicyEnabled $false
        sleep 60
        }
        Elseif($company -eq "1"){
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

sleep 60
Write-Host "Connecting to Sessions" -ForegroundColor Magenta
#$reconnect =  $PSScriptRoot | Split-Path -Parent | Split-Path -Parent; Invoke-Expression "$reconnect\Logins\Session_reconnect.ps1"
if (Test-Path $ISEScriptPath){ Invoke-Expression $ISEScriptPath }elseif(test-path $PSscriptPath){Invoke-Expression $PSscriptPath}

Write-Host "Tilføjer sikkerhedsgruppe $ExchangeSikkerhedsgruppe som 'FUll access & Send As' på $ADuser" -foregroundcolor Cyan     
if ([bool](Get-ADuser -Filter  {SamAccountName -eq $ADuser})) {
     $group = $ExchangeSikkerhedsgruppe
     Get-SSTMailbox -identity $ADuser | add-SSTmailboxpermission -user $group -accessrights FullAccess -inheritancetype All
     Add-SSTADPermission $ADuser -User $ExchangeSikkerhedsgruppe -Extendedrights "Send As"
     Get-SSTADPermission -Identity $ADuser | where {$_.ExtendedRights -like 'Send*'} | Format-Table -Auto User,Deny,ExtendedRights
     #Man kan tilføje individuelle brugere, men ikke grupper. Søgning giver ingen resultater, hvis man gør det med GUI.
     #Set-SSTMailbox -Identity $ADuser -GrantSendOnBehalfTo $ExchangeSikkerhedsgruppe
}
Else { write-host "Mislykkedes at tilknytte sikkerhedsgruppe: $ExchangeSikkerhedsgruppe adgang til Mødelokale: $ADuser..." }
           

Write-Host "Connecting to Sessions" -ForegroundColor Magenta
#$reconnect =  $PSScriptRoot | Split-Path -Parent | Split-Path -Parent; Invoke-Expression "$reconnect\Logins\Session_reconnect.ps1"
if (Test-Path $ISEScriptPath){ Invoke-Expression $ISEScriptPath }elseif(test-path $PSscriptPath){Invoke-Expression $PSscriptPath}


Write-Host "Konverterer postkasse $ADuser til type Room og sætter kapacitet til: $Capacity" -foregroundcolor Cyan 
Set-SSTMailbox $ADuser -Type room -ResourceCapacity $Capacity

Write-Host "Sætter standard sprog til DK" -foregroundcolor Cyan 
Set-SSTMailboxRegionalConfiguration –identity $ADuser –language da-dk -LocalizeDefaultFolderName
#read changes
Get-sstMailbox -Identity $ADuser| Format-List DisplayName,PrimarySmtpAddress,RecipientTypeDetails, MessageCopyForSentAsEnabled,MessageCopyForSendOnBehalfEnabled, Languages

Write-Host "Connecting to Sessions" -ForegroundColor Magenta
#$reconnect =  $PSScriptRoot | Split-Path -Parent | Split-Path -Parent; Invoke-Expression "$reconnect\Logins\Session_reconnect.ps1"
if (Test-Path $ISEScriptPath){ Invoke-Expression $ISEScriptPath }elseif(test-path $PSscriptPath){Invoke-Expression $PSscriptPath}


Write-Host "Ændrer kalender rettighed af $ADuser til LimitedDetails " -foregroundcolor Cyan 
$ADuserCalenderPath = "$ADuser" + ":\Kalender"
Set-SSTmailboxfolderpermission –identity $ADuserCalenderPath –user Default –Accessrights LimitedDetails
Get-SSTMailboxFolderPermission -Identity $ADuserCalenderPath

sleep 6

Write-Host "Connecting to Sessions" -ForegroundColor Magenta
#$reconnect =  $PSScriptRoot | Split-Path -Parent | Split-Path -Parent; Invoke-Expression "$reconnect\Logins\Session_reconnect.ps1"
if (Test-Path $ISEScriptPath){ Invoke-Expression $ISEScriptPath }elseif(test-path $PSscriptPath){Invoke-Expression $PSscriptPath}

#new added, need to see it works...?!
Write-Host "Omdøber bruger..." -foregroundcolor Cyan
Get-ADUser -Identity $ADuser | Rename-ADObject -NewName "$userDisplayName"
sleep 6

Write-Host "Obs! er manager sat som ejer?" -foregroundcolor Yellow -backgroundcolor DarkCyan
#ER det nødvendigt med en manager med nedenstående for mødelokaler?
#Write-Host "Husk at sætte hak i Manager må godt opdatere medlemskabsliste på sikkerhedsgruppe $ExchangeSikkerhedsgruppe," -foregroundcolor Yellow -backgroundcolor DarkCyan
#Write-Host "da dette kan ikke automatiseres pt. !!!!" -foregroundcolor Yellow -backgroundcolor DarkCyan
Write-Host
Write-Host "Husk at sætte hak i 'Enable the Resource Booking Attendant' under fanen 'Resource general' i Exchange," -foregroundcolor Yellow -backgroundcolor DarkCyan
Write-Host "så mødelokalet auto-accepterer mødeindkaldelser." -foregroundcolor Yellow -backgroundcolor DarkCyan
Write-Host
Write-Host "Noter følgende i Sagens løsningsbeksrivelse:" -foregroundcolor Yellow -backgroundcolor DarkCyan
$ResultMailboxType = (Get-SSTMailbox $ADuser).RecipientTypeDetails
Write-Host "Postkasse type: $ResultMailboxType" -foregroundcolor Green -backgroundcolor DarkCyan
$ResultRoom = (Get-SSTMailbox $ADuser).PrimarySmtpAddress
Write-Host "Mødelokalle oprettet: $ResultRoom" -foregroundcolor Green -backgroundcolor DarkCyan
$ResultGroup = (Get-SSTGroup $ExchangeSikkerhedsgruppe).WindowsEmailAddress
Write-Host "Tilhørende sikkerhedsgruppe oprettet: $ResultGroup" -foregroundcolor Green -backgroundcolor DarkCyan
Write-Host "Kapacitet: $Capacity" -foregroundcolor Green -backgroundcolor DarkCyan
Write-Host "Ejer: $Manager" -foregroundcolor Green -backgroundcolor DarkCyan
Pause




