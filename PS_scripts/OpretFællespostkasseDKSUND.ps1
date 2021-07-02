#PSVersion 5 Script made/assembled by Rust@m 15-07-2020
cls; Write-Host "Du har valgt OpretFællespostkasseSSI.ps1" -ForegroundColor Gray -BackgroundColor DarkCyan
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
$ISEScriptPath = (Get-Location).Path | Split-Path -Parent -ErrorAction SilentlyContinue; $ISEScriptPath = "$ISEScriptPath\Logins\Session_reconnect.ps1"
$PSscriptPath =  $PSScriptRoot | Split-Path -Parent -ErrorAction SilentlyContinue; $PSscriptPath = "$PSscriptPath\Logins\Session_reconnect.ps1"
#*********************************************************************************************************************************************
#Variabler
#****************
#dksund.dk/Organisationer/STPK/Grupper/
$OUPathForADgrouperSTPK = 'OU=Grupper,OU=STPK,OU=Organisationer,DC=dksund,DC=dk'
#dksund.dk/Organisationer/STPK/Shared mailbox/
$OUPathSharedMailSTPK = 'OU=Shared mailbox,OU=STPK,OU=Organisationer,DC=dksund,DC=dk'

[string]$ADuser = Read-Host -Prompt "Angiv Fællespostkasse ALIAS på minimum 5 og max 20 karaktere, Må IKKE indeholde: mellemrum, komma, ÆØÅ / \ (f.eks Servicedesk):"
[string]$company = Read-Host -Prompt "Tast 6 for @stps.dk"
[string]$Manager = Read-Host -Prompt "Angiv Ejers INITIALER til angivet fællespostkassen/sikkerhedsgruppen"

[string]$UserDisplayName = Read-Host -Prompt "Angiv displayname til postkassen."
[string]$ADuserDescription = 'Delt fællespostkasse (uden licens, direkte login disablet)'
[string]$ADgroupDescription = "Giver fuld adgang til fællespostkasse $ADuser"

#Check for illegal characters - legal are a-zA-Z0-9-_.  also check for aloowed lenght from 5 to 20
if($ADuser -match '[^a-zA-Z0-9\-_\.]' -or $ADuser.Length -lt 5 -or $ADuser.Length -gt 20){

    Write-Host "Whoops --> You have used illegal characters in email alias!" -foregroundcolor red
    Write-Host "Angiv Fællespostkasse ALIAS på minimum 5 og max 20 karaktere, Må IKKE indeholde: mellemrum, komma, ÆØÅ / \ (f.eks Servicedesk):" -ForegroundColor Yellow
    Write-Host "Better luck next time, returning to menu!" -ForegroundColor Cyan
    pause
    return
}

#****************
#script execution 
#****************
Write-Host "AdObjekt angivet til $ADuser" -foregroundcolor Yellow

Write-Host "Skifter til DKSUND AD" -foregroundcolor Yellow
Set-Location -Path 'DKSUNDAD:'

Write-Host "Checker om ADobjekt findes i forvejen i DKSUND AD...." -foregroundcolor Cyan
IF([bool](Get-ADUser -Filter "MailNickName eq '$ADuser'"))
{   
    $ADSeaerch = Get-ADUser $ADuser -Properties Canonicalname | Select-Object CanonicalName
    Write-Host "Bruger findes i DKSUND AD:" -foregroundcolor Green
    Write-Host  $ADSeaerch.CanonicalName -foregroundcolor Green

    Write-Host "Opdaterer AD objekt $ADgroup i DKSUND AD" -foregroundcolor Cyan
        
    if ($company -eq "6"){
        $ADgroup = 'STPS_'+$ADuser+'_MAIL'
        Write-Host "Objekt $ADuser Findes ikke i AD til at starte med, opretter " -foregroundcolor Yellow
        Write-Host "Sikkerhedsgruppe bliver til $ADgroup" -ForegroundColor Yellow
        Write-Host "Opretter AD objekt $ADgroup i DKSUND AD" -foregroundcolor Cyan

        New-ADGroup -Name $ADgroup -GroupScope Universal -GroupCategory Security -ManagedBy $Manager -Description $SikkerhedsgrupperDescription -Path $OUPathForADgrouperSTPK
        Write-Host "TimeOut for 60 sek." -foregroundcolor Yellow 
        sleep 60

        Write-Host "Opdaterer 'Company' felt og tilføje  email adresse til gruppen" -foregroundcolor Cyan
        $GroupMail = $ADgroup+'@stps.dk'
        Set-ADGroup -Identity $ADgroup -Add @{company="STYRELSEN FOR PATIENTKLAGER";mail="$GroupMail"}

        Write-Host "Tilføjer $Manager til  gruppen 'CTX_G_DKS_Standard_STPK' medlemskab." -foregroundcolor Cyan
        Add-ADGroupMember -Identity 'CTX_G_DKS_Standard_STPK' -Members  $Manager -ErrorAction SilentlyContinue
    }
    Else 
    { Write-Warning "Mislykkedes Opdaterer AD objekt $ADgroup, Noget gik galt..."}

    Write-Host "Tilføjer $Manager som Manager på AD Objekt $ADuser." -foregroundcolor Cyan
    Set-ADUser $ADuser -Manager $Manager

    Write-Host "Tilføjer $Manager til  gruppen $ADgroup medlemskab." -foregroundcolor Cyan
    Add-ADGroupMember -Identity $ADgroup -Members $Manager

   
    Write-Host "Forsøger at E-Mail aktivere Sikkerhedsgruppe $ADgroup  i Exchange 2016" -foregroundcolor Yellow
    do
    {
        
        Start-Sleep 120
        $i++
        IF([bool](Get-ADGroup -Filter "DisplayName eq '$ADgroup'"))
        {

            switch ($company)
            {
                '6' {
            
                        Write-Host "Connecting to Sessions" -ForegroundColor Magenta
                        if (Test-Path $ISEScriptPath){ Invoke-Expression $ISEScriptPath }elseif(test-path $PSscriptPath){Invoke-Expression $PSscriptPath}
                        
                        Write-Host "E-Mail aktivering af Sikkerhedsgruppe $ADgroup i Exchange 2016" -foregroundcolor Cyan
                        Enable-SSIDistributionGroup -Identity $ADgroup -ErrorAction Stop
                        
                        Write-Host "Tilføjer primær smtp adressen og disabled email politik for $ADgroup på Exchange 2016" -foregroundcolor Cyan
                        $new = $ADgroup + "@stpk.dk"
                        Set-SSIDistributionGroup $ADgroup -PrimarySMTPAddress $new -EmailAddressPolicyEnabled $false 
            
                    }

                 Default {$company = Read-Host -Prompt "Tast 6 for @stpk.dk til at vælge passende adresse."}
            }

        }
     
        if ($i -eq 20) {
        Write-Warning "Kunne ikke e-mail aktivere $ADgroup, da gruppen muligvis ikke findes i DKSUND/Exchange 2016, eller noget gik  galt."}
    
    }
    until ((Get-ADGroup -Filter "DisplayName eq '$ADgroup'") -or ($i -ge 20 ) )


    Write-Host "Forsøger at E-Mail aktivere fællesposkasse $ADuser på Exchange 2016" -foregroundcolor Cyan       
    IF([bool](Get-ADUser -Filter "MailNickName eq '$ADuser'"))
    {

        Write-Host "Connecting to Sessions" -ForegroundColor Magenta
        if (Test-Path $ISEScriptPath){ Invoke-Expression $ISEScriptPath }elseif(test-path $PSscriptPath){Invoke-Expression $PSscriptPath}
        
        Enable-SSIMailbox -Identity "$ADuser"
        Write-Host "Time Out 1 min..."  -foregroundcolor Yellow  
        Start-Sleep 60
        #som resultat vil den være synlig på Exchnage 2016 onprem men ikke i Offic365 , da den ikke endnu har en licens.
    }
    Else { Write-Warning "Fejlede at E-Mail aktivere fællespostkasse/bruger: $ADuser, noget gik galt..." }


    Write-Host "Tilføjer sikkerhedsgruppe $ADgroup som 'FUll access, Send As and on behalf' på $ADuser" -foregroundcolor Cyan     
    $alias = $ADuser
    if (-not ($alias -eq "*" -or $alias -eq "")) {

        Write-Host "Connecting to Sessions" -ForegroundColor Magenta
        if (Test-Path $ISEScriptPath){ Invoke-Expression $ISEScriptPath }elseif(test-path $PSscriptPath){Invoke-Expression $PSscriptPath}              
        
        Get-Mailbox -identity $alias | add-mailboxpermission -user $ADgroup -accessrights FullAccess -inheritancetype All
        Add-recipientPermission $alias -AccessRights SendAs -Trustee $ADgroup -Confirm:$false
        Set-Mailbox -Identity $alias -GrantSendOnBehalfTo $ADgroup
    }
    Else { write-host "Mislykkedes at tilknytte sikkerhedsgruppe: $ADgroup adgang til fællespostkasse: $ADuser..." }



    Write-Host "Forsøger at konvertere ADobjekt $ADuser $('[{0:yyyy/mm/dd} {0:HH:mm:ss}]' -f (Get-Date))" -foregroundcolor Yellow
    do
    {
        
        Start-Sleep 120
        #Start-Sleep 3
        $i++
        IF([bool](Get-SSIMailbox  "$ADuser@dksund.dk" -ErrorAction SilentlyContinue))
        {   
            Write-Host "Connecting to Sessions" -ForegroundColor Magenta
            if (Test-Path $ISEScriptPath){ Invoke-Expression $ISEScriptPath }elseif(test-path $PSscriptPath){Invoke-Expression $PSscriptPath}
            
            Write-Host "Konverterer postkasse $ADuser til type Shared" -foregroundcolor Cyan
            Set-Mailbox -Identity $ADuser -Type Shared
        }
     
        if ($i -eq 20) {
        Write-Warning "Kunne ikke Konverterer $ADuser til type 'shared'ved forsøg $i "}
    
    }
    until ([bool](Get-SSIMailbox  "$ADuser@dksund.dk" -ErrorAction SilentlyContinue) -or ($i -ge 20 ) )    
    
    Write-Host "Opretter regel at Mail som er sendt fra shared postkasse, bliver lagt 2 steder, nemlig i sendt items hos bruger og i selve fællespostkasse." -foregroundcolor Cyan 
    #Echnage 2016:
    Set-SSiMailbox  -Identity $ADUser -MessageCopyForSentAsEnabled $true
    Set-SSiMailbox  -Identity $ADUser -MessageCopyForSendOnBehalfEnabled $true
    
    Write-Host "Sætter standard sprog til DK" -foregroundcolor Cyan 
    Set-SSiMailboxRegionalConfiguration –identity $ADuser –language da-dk -LocalizeDefaultFolderName
    #read changes
    Get-SSiMailbox -Identity $ADuser| Format-List DisplayName,PrimarySmtpAddress,RecipientTypeDetails, MessageCopyForSentAsEnabled,MessageCopyForSendOnBehalfEnabled, Languages
    
    
    Write-Host "Ændrer kalender rettighed af $ADuser til LimitedDetails " -foregroundcolor Cyan 
    $MailCalenderPath = "$ADuser" + ":\Kalender"
    Set-SSimailboxfolderpermission –identity $MailCalenderPath –user Default –Accessrights LimitedDetails
    Get-SSiMailboxFolderPermission -Identity $MailCalenderPath
    
    
    Write-Host "Time out 1 min..." -foregroundcolor Yellow 
    sleep 60
    Write-Host "Connecting to Sessions" -ForegroundColor Magenta
    #$reconnect =  $PSScriptRoot | Split-Path -Parent | Split-Path -Parent; Invoke-Expression "$reconnect\Logins\Session_reconnect.ps1"
    if (Test-Path $ISEScriptPath){ Invoke-Expression $ISEScriptPath }elseif(test-path $PSscriptPath){Invoke-Expression $PSscriptPath}
    
    # OBS. flueben at manager af sikkerhedsgruppe kan opdateret medlemskab
    #Add-ADPermission -Identity $ADgroup -User $Manager -AccessRights WriteProperty -Properties "Member"
    Set-SSiDistributionGroup -Identity $ADgroup -ManagedBy $Manager
    
    
    Write-Host "Omdøber bruger..." -foregroundcolor Cyan
    Get-ADUser -Identity $ADuser | Rename-ADObject -NewName "$userDisplayName"
    sleep 6

    
    Write-Host "Connecting to Sessions" -ForegroundColor Magenta
    if (Test-Path $ISEScriptPath){ Invoke-Expression $ISEScriptPath }elseif(test-path $PSscriptPath){Invoke-Expression $PSscriptPath}

    Write-Host "Obs! Husk at sætte hak i Manager må godt opdatere medlemskabsliste på sikkerhedsgruppe $ADgroup, da dette kan ikke automatiseres pt. !!!!" -foregroundcolor Yellow -backgroundcolor DarkCyan
    Write-Host "Noter følgende i Sagens løsningsbeksrivelse:" -foregroundcolor Yellow -backgroundcolor DarkCyan
    $ResultMailboxType = (Get-SSITMailbox $ADuser).RecipientTypeDetails
    Write-Host "Postkasse type: $ResultMailboxType" -foregroundcolor Green -backgroundcolor DarkCyan
    $ResultSharedmail = (Get-SSIMailbox "$ADuser").PrimarySmtpAddress
    Write-Host "Fællespostkasse oprettet: $ResultSharedmail" -foregroundcolor Green -backgroundcolor DarkCyan
    $ResultGroup = (Get-SSIGroup $ADgroup).WindowsEmailAddress
    Write-Host "Tilhørende sikkerhedsgruppe oprettet: $ResultGroup" -foregroundcolor Green -backgroundcolor DarkCyan
    Write-Host "Ejer: $Manager" -foregroundcolor Green -backgroundcolor DarkCyan
    Pause 
    return            
} 
else { 
    
    Write-Host "Objekt $ADuser Findes ikke i AD til at starte med, opretter " -foregroundcolor Yellow
    Write-Host "Opretter AD objekt Sikkerhedsgruppe: $ADgroup i DKSUND AD" -foregroundcolor Cyan
    do
    {
          switch ($company)
          {
                 '6' {
                        New-ADGroup -Name $ADgroup -GroupScope Universal -GroupCategory Security -ManagedBy $Manager -Description $ADgroupDescription -Path $OUPathForADgrouperSTPK
                        Write-Host "TimeOut for 20 sek." -foregroundcolor Yellow 
                        Start-Sleep 20
    
                        Write-Host "Opdaterer 'Company' felt og tilføje  email adresse til gruppen" -foregroundcolor Cyan
                        $GroupMail = $ADgroup+'@stpk.dk'
                        Set-ADGroup -Identity $ADgroup -Add @{company="STYRELSEN FOR PATIENTKLAGER";mail="$GroupMail"}

                        Write-Host "Tilføjer $Manager til  gruppen 'CTX_G_DKS_Standard_STPK' medlemskab." -foregroundcolor Cyan
                        Add-ADGroupMember -Identity 'CTX_G_DKS_Standard_STPK' -Members  $Manager -ErrorAction SilentlyContinue
    		  }
              
                Default {
                        $company = Read-Host -Prompt "6 for @stpk.dk til at vælge passende adresse."
                
                }
          }
    
     }
     until (($company -eq '1') -or ($company -eq '2'))



    Write-Host "Tilføjer $Manager til  gruppen $ADgroup medlemskab." -foregroundcolor Cyan
    Add-ADGroupMember -Identity $ADgroup -Members $Manager

    Write-Host "Opretter Fællespostkasse/SharedMail in DKSUND AD." -foregroundcolor Cyan
    if ($company -eq "6"){
        New-ADUser -Name "$ADuser" -DisplayName $ADuser -GivenName $ADuser -Manager $Manager -Description $ADuserDescription -UserPrincipalName ("{0}@{1}” -f $ADuser,"dksund.dk") -ChangePasswordAtLogon $true -Path $OUPathSharedMailSTPK
    }
    Else 
    { Write-Warning "Mislykkedes at oprette AD objekt: $ADuser."; Write-Host "Better luck next time, exiting script!" -ForegroundColor Cyan; pause;return }


    Write-Host "time out 2 min (Synkroniserer i AD)" -foregroundcolor Yellow 
    Start-Sleep 120


    Write-Host "Tilføjer 'sammacount' email og opdatere 'comapny' felt field in AD for $ADuser." -foregroundcolor Cyan
    If (Get-ADUser -Filter  {Name -eq $ADuser}) 
    {
    
        If ($company -eq "6") {
        Set-ADUser $ADuser -SamAccountName $ADuser -EmailAddress $ADuser'@stpk.dk' -Company 'STYRELSEN FOR PATIENTKLAGER' 
        }
    }
    Else { Write-Warning "Mislykkedes at tilføker 'samaccount' op opdatere 'company' felt for AD bruger $ADuser, Muligvis fordi den ikke findes i AD." ; Write-Host "Better luck next time, exiting script!" -ForegroundColor Cyan; pause;return }


    Write-Host "Forsøger at E-Mail aktivere Sikkerhedsgruppe $ADgroup  i Exchange 2016" -foregroundcolor Yellow
    do
    {
        
        Start-Sleep 60
        $i++
        IF([bool](Get-ADGroup -Filter "DisplayName eq '$ADgroup'"))
        {

            switch ($company)
            {
                '6' {
            
                        Write-Host "Connecting to Sessions" -ForegroundColor Magenta
                        if (Test-Path $ISEScriptPath){ Invoke-Expression $ISEScriptPath }elseif(test-path $PSscriptPath){Invoke-Expression $PSscriptPath}
                        
                        Write-Host "E-Mail aktivering af Sikkerhedsgruppe $ADgroup i Exchange 2016" -foregroundcolor Cyan
                        Enable-SSIDistributionGroup -Identity $ADgroup -ErrorAction Stop
                        
                        Write-Host "Tilføjer primær smtp adressen og disabled email politik for $ADgroup på Exchange 2016" -foregroundcolor Cyan
                        $new = $ADgroup + "@stpk.dk"
                        Set-SSIDistributionGroup $ADgroup -PrimarySMTPAddress $new -EmailAddressPolicyEnabled $false 
            
                    }
                
                 Default {$company = Read-Host -Prompt "Tast 6 for @stpk.dk til at vælge passende adresse."}
            }

        }
     
        if ($i -eq 8) {
        Write-Warning "Kunne ikke e-mail aktivere $ADgroup, da gruppen muligvis ikke findes i DKSUND/Exchange 2016, eller noget gik  galt."}
    
    }
    until ((Get-ADGroup -Filter "DisplayName eq '$ADgroup'") -or ($i -ge 8 ) )


    Write-Host "Forsøger at E-Mail aktivere fællesposkasse $ADuser på Exchange 2016" -foregroundcolor Cyan       
    IF([bool](Get-ADUser -Filter "MailNickName eq '$ADuser'"))
    {

        Write-Host "Connecting to Sessions" -ForegroundColor Magenta
        if (Test-Path $ISEScriptPath){ Invoke-Expression $ISEScriptPath }elseif(test-path $PSscriptPath){Invoke-Expression $PSscriptPath}
        
        Enable-SSIMailbox "$ADuser"
        Write-Host "Time Out 1 min..."  -foregroundcolor Yellow  
        Start-Sleep 60
    }
    Else { Write-Warning "Fejlede at E-Mail aktivere fællespostkasse/bruger: $ADuser, noget gik galt..." }


    Write-Host "Tilføjer sikkerhedsgruppe $ADgroup som 'FUll access & Send As' på $ADuser" -foregroundcolor Cyan     
    if (-not ($ADuser -eq "*" -or $ADuser -eq "")) {
         
         Get-SSIMailbox -identity $ADuser | add-SSimailboxpermission -user $ADgroup -accessrights FullAccess -inheritancetype All
         Add-SSIADPermission $ADuser -User $ADgroup -Extendedrights "Send As"
         Get-SSIADPermission -Identity $ADuser | where {$_.ExtendedRights -like 'Send*'} | Format-Table -Auto User,Deny,ExtendedRights
         #Man kan tilføje individuelle brugere, men ikke grupper. Søgning giver ingen resultater, hvis man gør det med GUI.
         Set-SSIMailbox -Identity $ADuser -GrantSendOnBehalfTo $ADgroup
         Get-SSIMailbox -Identity $ADuser | Format-List GrantSendOnBehalfTo
         
    }
    Else { write-host "Mislykkedes at tilknytte sikkerhedsgruppe: $ADgroup adgang til fællespostkasse: $ADuser..." }



    Write-Host "Forsøger at konvertere ADobjekt $ADuser $('[{0:yyyy/mm/dd} {0:HH:mm:ss}]' -f (Get-Date))" -foregroundcolor Yellow
    do
    {
        
        Start-Sleep 120
        #Start-Sleep 3
        $i++
        IF([bool](Get-SSIMailbox  "$ADuser@dksund.dk" -ErrorAction SilentlyContinue))
        {   
            Write-Host "Connecting to Sessions" -ForegroundColor Magenta
            if (Test-Path $ISEScriptPath){ Invoke-Expression $ISEScriptPath }elseif(test-path $PSscriptPath){Invoke-Expression $PSscriptPath}
            
            Write-Host "Konverterer postkasse $ADuser til type Shared" -foregroundcolor Cyan
            Set-SSIMailbox $ADuser -Type Shared -ErrorAction stop
        }
     
        if ($i -eq 20) {
        Write-Warning "Kunne ikke Konverterer $ADuser til type 'shared' ved forsøg $i "}
    
    }
    until ([bool](Get-SSIMailbox  "$ADuser@dksund.dk" -ErrorAction SilentlyContinue) -or ($i -ge 20 ) )  
    

    Write-Host "Connecting to Sessions" -ForegroundColor Magenta
    if (Test-Path $ISEScriptPath){ Invoke-Expression $ISEScriptPath }elseif(test-path $PSscriptPath){Invoke-Expression $PSscriptPath}

    Write-Host "Opretter regel at Mail som er sendt fra shared postkasse, bliver lagt 2 steder, nemlig i sendt items hos bruger og i selve fællespostkasse." -foregroundcolor Cyan 
    #exchnage 2010:
    #Set-SSiMailboxSentItemsConfiguration -Identity  $ADUser -SendAsItemsCopiedTo SenderAndFrom
    #Echnage 2016:
    Set-SSiMailbox  -Identity $ADUser -MessageCopyForSentAsEnabled $true
    Set-SSiMailbox  -Identity $ADUser -MessageCopyForSendOnBehalfEnabled $true
    
    Write-Host "Sætter standard sprog til DK" -foregroundcolor Cyan 
    Set-SSiMailboxRegionalConfiguration –identity $ADuser –language da-dk -LocalizeDefaultFolderName
    #read changes
    Get-SSiMailbox -Identity $ADuser| Format-List DisplayName,PrimarySmtpAddress,RecipientTypeDetails, MessageCopyForSentAsEnabled,MessageCopyForSendOnBehalfEnabled, Languages
    
    
    Write-Host "Ændrer kalender rettighed af $ADuser til LimitedDetails " -foregroundcolor Cyan 
    $MailCalenderPath = "$ADuser" + ":\Kalender"
    Set-SSimailboxfolderpermission –identity $MailCalenderPath –user Default –Accessrights LimitedDetails
    Get-SSiMailboxFolderPermission -Identity $MailCalenderPath
    
    
    Write-Host "Time out 1 min..." -foregroundcolor Yellow 
    sleep 60
    Write-Host "Connecting to Sessions" -ForegroundColor Magenta
    #$reconnect =  $PSScriptRoot | Split-Path -Parent | Split-Path -Parent; Invoke-Expression "$reconnect\Logins\Session_reconnect.ps1"
    if (Test-Path $ISEScriptPath){ Invoke-Expression $ISEScriptPath }elseif(test-path $PSscriptPath){Invoke-Expression $PSscriptPath}
    
    # OBS. flueben at manager af sikkerhedsgruppe kan opdateret medlemskab
    #Add-ADPermission -Identity $ADgroup -User $Manager -AccessRights WriteProperty -Properties "Member"
    Set-SSiDistributionGroup -Identity $ADgroup -ManagedBy $Manager
    
    
    Write-Host "Omdøber bruger..." -foregroundcolor Cyan
    Get-ADUser -Identity $ADuser | Rename-ADObject -NewName "$userDisplayName"
    sleep 6

    
    Write-Host "Connecting to Sessions" -ForegroundColor Magenta
    if (Test-Path $ISEScriptPath){ Invoke-Expression $ISEScriptPath }elseif(test-path $PSscriptPath){Invoke-Expression $PSscriptPath}

    Write-Host "Obs! Husk at sætte hak i Manager må godt opdatere medlemskabsliste på sikkerhedsgruppe $ADgroup, da dette kan ikke automatiseres pt. !!!!" -foregroundcolor Yellow -backgroundcolor DarkCyan
    Write-Host "Noter følgende i Sagens løsningsbeksrivelse:" -foregroundcolor Yellow -backgroundcolor DarkCyan
    $ResultMailboxType = (Get-SSITMailbox $ADuser).RecipientTypeDetails
    Write-Host "Postkasse type: $ResultMailboxType" -foregroundcolor Green -backgroundcolor DarkCyan
    $ResultSharedmail = (Get-SSIMailbox "$ADuser").PrimarySmtpAddress
    Write-Host "Fællespostkasse oprettet: $ResultSharedmail" -foregroundcolor Green -backgroundcolor DarkCyan
    $ResultGroup = (Get-SSIGroup $ADgroup).WindowsEmailAddress
    Write-Host "Tilhørende sikkerhedsgruppe oprettet: $ResultGroup" -foregroundcolor Green -backgroundcolor DarkCyan
    Write-Host "Ejer: $Manager" -foregroundcolor Green -backgroundcolor DarkCyan
    Pause 
    return
} 

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