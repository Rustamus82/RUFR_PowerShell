﻿#PSVersion 5 Script made/assembled by Rust@m 16-03-2021
Write-Host "Du har valgt OpretFællespostkasseSST.ps1" -ForegroundColor Gray -BackgroundColor DarkCyan
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
$OUPathSharedMailSST = 'OU=SST,OU=eDelt,OU=Systemkonti,DC=SST,DC=dk'
$OUPathSharedMailDEP = 'OU=DEP,OU=eDelt,OU=Systemkonti,DC=SST,DC=dk'
$OUPathSharedMailSTPS = 'OU=STPS,OU=eDelt,OU=Systemkonti,DC=SST,DC=dk'
$OUPathSharedMailNGC = 'OU=DEP,OU=eDelt,OU=Systemkonti,DC=SST,DC=dk'


$userDisplayName = Read-Host -Prompt "Angiv displayname til postkassen."
$ADuser = Read-Host -Prompt "Angiv ny fællespostkasse Navn/Alias på minimum 5 og max 20 karakterer, Må indeholde kun [^a-zA-Z0-9\-_\.] (f.eks Servicedesk):"
$company = Read-Host -Prompt "Tast 1 for sst.dk, 2 for sum.dk 3 for stps.dk eller 4 for NGC.dk 5 for dketik.dk til at vælge passende adresse."
$Manager = Read-Host -Prompt "Angiv Ejers INITIALER til fællespostkassen og den tilhørende sikkerhedsgruppe."

$ADuserDescription = 'Delt fællespostkasse (uden licens, direkte login disablet)'
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
        
        $ADgroup = 'SST_'+$ADuser+'_MAIL'
        Write-Host "Objekt $ADuser Findes ikke i AD til at starte med, opretter " -foregroundcolor Yellow
        Write-Host "Sikkerhedsgruppe bliver til $ADgroup" -ForegroundColor Yellow
        Write-Host "Opretter AD objekt $ADgroup i SST AD" -foregroundcolor Cyan
        
        New-ADGroup -Name $ADgroup -GroupScope Universal -GroupCategory Security -ManagedBy $Manager -Description $SikkerhedsgrupperDescription -Path $OUPathForExchangeSikkerhedsgrupperSST
        Write-Host "TimeOut for 60 sek." -foregroundcolor Yellow 
        sleep 60

        Write-Host "Opdaterer 'Company' felt og tilføje  email adresse til gruppen" -foregroundcolor Cyan
        $GroupMail = $ADgroup+'@sst.dk'
        Set-ADGroup -Identity $ADgroup -Add @{company="Sundhedsstyrelsen";mail="$GroupMail"}
    }
    Elseif ($company -eq "2") {

        $ADgroup = 'DEP_'+$ADuser+'_MAIL'
        Write-Host "Objekt $ADuser Findes ikke i AD til at starte med, opretter " -foregroundcolor Yellow
        Write-Host "Sikkerhedsgruppe bliver til $ADgroup" -ForegroundColor Yellow
        Write-Host "Opretter AD objekt $ADgroup i SST AD" -foregroundcolor Cyan

        New-ADGroup -Name $ADgroup -GroupScope Universal -GroupCategory Security -ManagedBy $Manager -Description $SikkerhedsgrupperDescription -Path $OUPathForExchangeSikkerhedsgrupperDEP
        Write-Host "TimeOut for 60 sek." -foregroundcolor Yellow 
        sleep 60

        Write-Host "Opdaterer 'Company' felt og tilføje  email adresse til gruppen" -foregroundcolor Cyan
        $GroupMail = $ADgroup+'@sst.dk'
        Set-ADGroup -Identity $ADgroup -Add @{company="Sundheds- og Ældreministeriet";mail="$GroupMail"}
    }
    Elseif ($company -eq "3") {
        $ADgroup = 'STPS_'+$ADuser+'_MAIL'
        Write-Host "Objekt $ADuser Findes ikke i AD til at starte med, opretter " -foregroundcolor Yellow
        Write-Host "Sikkerhedsgruppe bliver til $ADgroup" -ForegroundColor Yellow
        Write-Host "Opretter AD objekt $ADgroup i SST AD" -foregroundcolor Cyan

        New-ADGroup -Name $ADgroup -GroupScope Universal -GroupCategory Security -ManagedBy $Manager -Description $SikkerhedsgrupperDescription -Path $OUPathForExchangeSikkerhedsgrupperSTPS
        Write-Host "TimeOut for 60 sek." -foregroundcolor Yellow 
        sleep 60

        Write-Host "Opdaterer 'Company' felt og tilføje  email adresse til gruppen" -foregroundcolor Cyan
        $GroupMail = $ADgroup+'@sst.dk'
        Set-ADGroup -Identity $ADgroup -Add @{company="Styrelsen for Patientsikkerhed";mail="$GroupMail"}
    }
    Elseif ($company -eq "4") {
        $ADgroup = 'NGC_'+$ADuser+'_MAIL'
        Write-Host "Objekt $ADuser Findes ikke i AD til at starte med, opretter " -foregroundcolor Yellow
        Write-Host "Sikkerhedsgruppe bliver til $ADgroup" -ForegroundColor Yellow
        Write-Host "Opretter AD objekt $ADgroup i SST AD" -foregroundcolor Cyan

        New-ADGroup -Name $ADgroup -GroupScope Universal -GroupCategory Security -ManagedBy $Manager -Description $SikkerhedsgrupperDescription -Path $OUPathForExchangeSikkerhedsgrupperNGC
        Write-Host "TimeOut for 60 sek." -foregroundcolor Yellow 
        sleep 60

        Write-Host "Opdaterer 'Company' felt og tilføje  email adresse til gruppen" -foregroundcolor Cyan
        $GroupMail = $ADgroup+'@sst.dk'
        Set-ADGroup -Identity $ADgroup -Add @{company="Nationalt Genom Center";mail="$GroupMail"}
    }
    Else { 
    Write-Warning "Mislykkedes at oprette $ADgroup, Noget gik galt..."
    }


    Write-Host "Tilføjer $Manager til gruppen $ADgroup medlemskab." -foregroundcolor Cyan
    Add-ADGroupMember -Identity $ADgroup -Members $Manager

    Write-Host "Sætter hak i Manager må godt opdatere medlemskabsliste på sikkerhedsgruppe $ADgroup" -foregroundcolor Cyan
    #Manager 
    $ManagerObject = Get-ADUser $Manager 
    #Set-ADGroup "$ADgroup" -Replace @{managedBy=$ManagerObject.DistinguishedName}
    #RightsGuid
    $guid = [guid]'bf9679c0-0de6-11d0-a285-00aa003049e2'
    #SID of the manager 
    $sid = [System.Security.Principal.SecurityIdentifier]$ManagerObject.sid
    #ActiveDirectoryAccessRule create 
    $ctrlType = [System.Security.AccessControl.AccessControlType]::Allow 
    $rights = [System.DirectoryServices.ActiveDirectoryRights]::WriteProperty -bor [System.DirectoryServices.ActiveDirectoryRights]::ExtendedRight
    $rule = New-Object System.DirectoryServices.ActiveDirectoryAccessRule($sid, $rights, $ctrlType, $guid)
    #Read out the group ACL, add a new rule and overwrite the group's ACL 
    $GroupObject = Get-ADGroup "$ADgroup"
    $AD = Get-Location
    $aclPath = "$AD" + $GroupObject.distinguishedName 
    $acl = Get-Acl $aclPath
    $acl.AddAccessRule($rule) 
    Set-Acl -acl $acl -path $aclPath

    #Write-Host "Tilføjer $Manager til  gruppen 'U-SSI-CTX-Standard applikationer' medlemskab." -foregroundcolor Cyan
    #Add-ADGroupMember -Identity 'U-SSI-CTX-Standard applikationer' -Members  $Manager -ErrorAction SilentlyContinue

    Write-Host "Opretter Fællespostkasse/SharedMail i SST AD." -foregroundcolor Cyan
    Set-Location -Path 'SSTAD:'
    if ($company -eq "1"){
        New-ADUser -Name "$ADuser" -DisplayName $ADuser -GivenName $ADuser -Manager $Manager -Description $ADuserDescription -UserPrincipalName (“{0}@{1}” -f $ADuser,”sst.dk”) -ChangePasswordAtLogon $true -Path $OUPathSharedMailSST 
    }
    Elseif ($company -eq "2") {
        New-ADUser -Name "$ADuser" -DisplayName $ADuser -GivenName $ADuser -Manager $Manager -Description $ADuserDescription -UserPrincipalName (“{0}@{1}” -f $ADuser,”sum.dk”) -ChangePasswordAtLogon $true -Path $OUPathSharedMailDEP
    }
    Elseif ($company -eq "3") {
        New-ADUser -Name "$ADuser" -DisplayName $ADuser -GivenName $ADuser -Manager $Manager -Description $ADuserDescription -UserPrincipalName (“{0}@{1}” -f $ADuser,”stps.dk”) -ChangePasswordAtLogon $true -Path $OUPathSharedMailSTPS
    } 
    Elseif ($company -eq "4") {
        New-ADUser -Name "$ADuser" -DisplayName $ADuser -GivenName $ADuser -Manager $Manager -Description $ADuserDescription -UserPrincipalName (“{0}@{1}” -f $ADuser,”ngc.dk”) -ChangePasswordAtLogon $true -Path $OUPathSharedMailNGC
    }
    Else 
    { Write-Warning "Mislykkedes at oprette AD objekt: $ADuser."}


    Write-Host "time out 2 min (Synkroniserer i AD)" -foregroundcolor Yellow 
    sleep 120


    Write-Host "Tilføjer 'sammacount' email og opdatere 'company' felt i AD for $ADuser." -foregroundcolor Cyan
    If (Get-ADUser -Filter  {Name -eq $ADuser}) 
    {
    
        If ($company -eq "1") {
        Set-ADUser $ADuser -SamAccountName $ADuser -EmailAddress $ADuser'@sst.dk' -Company 'Sundhedsstyrelsen' 
        }
        If ($company -eq "2") {
        Set-ADUser $ADuser -SamAccountName $ADuser -EmailAddress $ADuser'@sum.dk' -Company 'Sundheds- og Ældreministeriet' 
        }
        If ($company -eq "3") {
        Set-ADUser $ADuser -SamAccountName $ADuser -EmailAddress $ADuser'@stps.dk' -Company 'Styrelsen for Patientsikkerhed' 
        }
        If ($company -eq "4") {
        Set-ADUser $ADuser -SamAccountName $ADuser -EmailAddress $ADuser'@ngc.dk' -Company 'Nationalt Genom Center' 
        }
    }
    Else
    {
        Write-Warning "Mislykkedes at tilføje 'samaccount' op opdatere 'company' felt for AD bruger $ADuser, Muligvis fordi den ikke findes i AD."
    }

Write-Host "time out 2 min (Synkroniserer i AD)" -foregroundcolor Yellow 
sleep 120


Write-Host "Forsøger at E-Mail aktivere fællesposkasse $ADuser på Exchange 2016 SST" -foregroundcolor Cyan       
    if ([bool](Get-ADuser -Filter  {SamAccountName -eq $ADuser})){
    Write-Host "Connecting to Sessions" -ForegroundColor Magenta
    #$reconnect =  $PSScriptRoot | Split-Path -Parent | Split-Path -Parent; Invoke-Expression "$reconnect\Logins\Session_reconnect.ps1"
    if (Test-Path $ISEScriptPath){ Invoke-Expression $ISEScriptPath }elseif(test-path $PSscriptPath){Invoke-Expression $PSscriptPath}
    
    Enable-SSTMailbox "$ADuser" 
    Write-Host "Time Out 1 min..."  -foregroundcolor Yellow  
    sleep 60
    #som resultat vil den være synlig på Exchnage 2016 onprem men ikke i Offic365 , da den ikke endnu har en licens.
        Write-Host "Connecting to Sessions" -ForegroundColor Magenta
        if (Test-Path $ISEScriptPath){ Invoke-Expression $ISEScriptPath }elseif(test-path $PSscriptPath){Invoke-Expression $PSscriptPath}

        if($company -eq "2"){
            Write-Host "Tilføjer primær smtp adressen og disabled email politik for $ADgroup på Exchange 2016 SST" -foregroundcolor Cyan
        $new = $ADuser + "@sum.dk"
        Set-SSTMailbox $ADuser -PrimarySMTPAddress $new -EmailAddressPolicyEnabled $false
        sleep 60 
        }
        if($company -eq "3") {
            Write-Host "Tilføjer primær smtp adressen og disabled email politik for $ADgroup på Exchange 2016 SST" -foregroundcolor Cyan
        $new = $ADuser + "@stps.dk"
        Set-SSTMailbox $ADuser -PrimarySMTPAddress $new -EmailAddressPolicyEnabled $false
        sleep 60 
        }
        if($company -eq "4") {
            Write-Host "Tilføjer primær smtp adressen og disabled email politik for $ADgroup på Exchange 2016 SST" -foregroundcolor Cyan
        $new = $ADuser + "@ngc.dk"
        Set-SSTMailbox $ADuser -PrimarySMTPAddress $new -EmailAddressPolicyEnabled $false
        sleep 60 
        }
        elseif($company -eq "1"){
            sleep 5
        }
        Else { 
            Write-Warning "Fejlede at tilføje sum.dk som primær smtp: $ADuser, noget gik galt..." 
        }

    }
    Else { Write-Warning "Fejlede at E-Mail aktivere fællespostkasse/bruger: $ADuser, noget gik galt..." }


Write-Host "Connecting to Sessions" -ForegroundColor Magenta
#$reconnect =  $PSScriptRoot | Split-Path -Parent | Split-Path -Parent; Invoke-Expression "$reconnect\Logins\Session_reconnect.ps1"
if (Test-Path $ISEScriptPath){ Invoke-Expression $ISEScriptPath }elseif(test-path $PSscriptPath){Invoke-Expression $PSscriptPath}

    if ([bool](Get-ADGroup -Filter  {SamAccountName -eq $ADgroup})) 
    {
        Write-Host "E-Mail aktivering af gruppen i Exchange 2016 SST" -foregroundcolor Cyan
        Enable-SSTDistributionGroup -Identity $ADgroup -ErrorAction Stop
    
        if($company -eq "2"){
            Write-Host "Tilføjer primær '@sum.dk' smtp adressen og disabled email politik for $ADgroup på Exchange 2016 SST" -foregroundcolor Cyan
        $new = $ADgroup + "@sum.dk"
        Set-SSTDistributionGroup $ADgroup -PrimarySMTPAddress $new -EmailAddressPolicyEnabled $false
        sleep 60
        }
        if($company -eq "3"){
            Write-Host "Tilføjer primær '@stps.dk' smtp adressen og disabled email politik for $ADgroup på Exchange 2016 SST" -foregroundcolor Cyan
        $new = $ADgroup + "@stps.dk"
        Set-SSTDistributionGroup $ADgroup -PrimarySMTPAddress $new -EmailAddressPolicyEnabled $false
        sleep 60
        }
        if($company -eq "4"){
            Write-Host "Tilføjer primær '@ngc.dk' smtp adressen og disabled email politik for $ADgroup på Exchange 2016 SST" -foregroundcolor Cyan
        $new = $ADgroup + "@ngc.dk"
        Set-SSTDistributionGroup $ADgroup -PrimarySMTPAddress $new -EmailAddressPolicyEnabled $false
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
        Write-Warning "Kunne ikke e-mail aktivere $ADgroup, da gruppen muligvis ikke findes i DKSUND/Exchange 2016, eller noget gik  galt." -ErrorAction Stop
    }


Write-Host "Connecting to Sessions" -ForegroundColor Magenta
#$reconnect =  $PSScriptRoot | Split-Path -Parent | Split-Path -Parent; Invoke-Expression "$reconnect\Logins\Session_reconnect.ps1"
if (Test-Path $ISEScriptPath){ Invoke-Expression $ISEScriptPath }elseif(test-path $PSscriptPath){Invoke-Expression $PSscriptPath}

Write-Host "Tilføjer sikkerhedsgruppe $ADgroup som 'FUll access & Send As' på $ADuser" -foregroundcolor Cyan     

if (-not ($ADuser -eq "*" -or $ADuser -eq "")) {
     
     Get-SSTMailbox -identity $ADuser | add-sstmailboxpermission -user $ADgroup -accessrights FullAccess -inheritancetype All
     Add-SSTADPermission $ADuser -User $ADgroup -Extendedrights "Send As"
     Get-SSTADPermission -Identity $ADuser | where {$_.ExtendedRights -like 'Send*'} | Format-Table -Auto User,Deny,ExtendedRights
     #Man kan tilføje individuelle brugere, men ikke grupper. Søgning giver ingen resultater, hvis man gør det med GUI.
     Set-SSTMailbox -Identity $ADuser -GrantSendOnBehalfTo $ADgroup
     Get-SSTMailbox -Identity $ADuser | Format-List GrantSendOnBehalfTo
     
}
Else { write-host "Mislykkedes at tilknytte sikkerhedsgruppe: $ADgroup adgang til fællespostkasse: $ADuser..." }

Write-Host "Connecting to Sessions" -ForegroundColor Magenta
#$reconnect =  $PSScriptRoot | Split-Path -Parent | Split-Path -Parent; Invoke-Expression "$reconnect\Logins\Session_reconnect.ps1"
if (Test-Path $ISEScriptPath){ Invoke-Expression $ISEScriptPath }elseif(test-path $PSscriptPath){Invoke-Expression $PSscriptPath}

Write-Host "Konverterer postkasse $ADuser til type Shared" -foregroundcolor Cyan 
Set-SSTMailbox $ADuser -Type Shared

Write-Host "Opretter regel at Mail som er sendt fra shared postkasse, bliver lagt 2 steder, nemlig i sendt items hos bruger og i selve fællespostkasse." -foregroundcolor Cyan 
#exchnage 2010:
#Set-SSTMailboxSentItemsConfiguration -Identity  $ADUser -SendAsItemsCopiedTo SenderAndFrom
#Echnage 2016:
Set-SSTMailbox  -Identity $ADUser -MessageCopyForSentAsEnabled $true
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

#Set-SSTDistributionGroup -Identity $ADgroup -ManagedBy $Manager

Write-Host "Omdøber bruger..." -foregroundcolor Cyan
   Get-ADUser -Identity $ADuser | Rename-ADObject -NewName "$userDisplayName"
   sleep 6

#Write-Host "Obs! Husk at sætte hak i Manager må godt opdatere medlemskabsliste på sikkerhedsgruppe $ADgroup, da dette kan ikke automatiseres pt. !!!!" -foregroundcolor Yellow -backgroundcolor DarkCyan
Write-Host "Noter følgende i Sagens løsningsbeksrivelse:" -foregroundcolor Yellow -backgroundcolor DarkCyan
$ResultMailboxType = (Get-SSTMailbox $ADuser).RecipientTypeDetails
Write-Host "Postkasse type: $ResultMailboxType" -foregroundcolor Green -backgroundcolor DarkCyan
$ResultSharedmail = (Get-SSTMailbox "$ADuser").PrimarySmtpAddress
Write-Host "Fællespostkasse oprettet: $ResultSharedmail" -foregroundcolor Green -backgroundcolor DarkCyan
$ResultGroup = (Get-SSTGroup $ADgroup).WindowsEmailAddress
Write-Host "Tilhørende sikkerhedsgruppe oprettet: $ResultGroup" -foregroundcolor Green -backgroundcolor DarkCyan
Write-Host "Ejer: $Manager" -foregroundcolor Green -backgroundcolor DarkCyan
Pause


#Fejlfinding
#Get-SST5Mailbox $ADuser | fl
#Get-ADGroup -Filter  {SamAccountName -eq 'samarbejdsogarbejdsmiljoeudvalget'} -Server $ServerNameDKSUND #http://stackoverflow.com/questions/6307127/hiding-errors-when-using-get-adgroup
#Get-ADGroup -Filter  {SamAccountName -eq 'samarbejdsogarbejdsmiljoeudvalget'} -Credential $UserCredDksund -AuthType Negotiate -Server $ServerNameDKSUND