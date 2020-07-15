#PSVersion 5 Script made/assembled by Rust@m 15-07-2020
Write-Host "Du har valgt OpretFællespostkasseSSI.ps1" -ForegroundColor Gray -BackgroundColor DarkCyan
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
#Variabler
#****************
$OUPathForExchangeSikkerhedsgrupperSSI = 'OU=ResourceGroups,OU=Exchange,OU=Groups,OU=SSI,DC=SSI,DC=ad'
$OUPathSharedMailSSI = 'OU=Faelles postkasser,OU=Ressourcer,DC=SSI,DC=ad'

$OUPathForExchangeSikkerhedsgrupperSDS = 'OU=Exchange Sikkerhedsgrupper,OU=Sundhedsdatastyrelsen,OU=Ressourcer,DC=SSI,DC=ad'
$OUPathSharedMailSDS = 'OU=Faelles postkasser,OU=Sundhedsdatastyrelsen,OU=Ressourcer,DC=SSI,DC=ad'

[string]$ADuser = Read-Host -Prompt "Angiv Fællespostkasse ALIAS på minimum 5 og max 20 karaktere, Må IKKE indeholde: mellemrum, komma, ÆØÅ / \ (f.eks Servicedesk):"
$company = Read-Host -Prompt "Tast 1 for @ssi.dk eller 2 for @sundhedsdata.dk til at vælge passende adresse."
$Manager = Read-Host -Prompt "Angiv Ejers INITIALER til angivet fællespostkassen/sikkerhedsgruppen"

$ExchangeSikkerhedsgruppe = 'GRP-'+$ADuser
$ADuserDescription = 'Delt fællespostkasse (uden licens, direkte login disablet)'
$SikkerhedsgrupperDescription = "Giver fuld adgang til fællespostkasse $ADuser"

#Check for illegal characters - legal are a-zA-Z0-9-_.  also check for aloowed lenght from 5 to 20
if($ADuser -match '[^a-zA-Z0-9\-_\.]' -or $ADuser.Length -lt 5 -or $ADuser.Length -gt 20){

    Write-Host "Whoops --> You have used illegal characters in email alias!" -foregroundcolor red
    Write-Host "Angiv Fællespostkasse ALIAS på minimum 5 og max 20 karaktere, Må IKKE indeholde: mellemrum, komma, ÆØÅ / \ (f.eks Servicedesk):" -ForegroundColor Yellow
    Write-Host "Better luck next time, exiting script!" -ForegroundColor Cyan
    pause
    exit
}

#****************
#script execution 
#****************
Write-Host "Skifter til DKSUND AD" -foregroundcolor Yellow
Set-Location -Path 'DKSUNDAD:'

Write-Host "Checker om ADobjekt findes i forvejen i DKSUND AD...." -foregroundcolor Cyan
if ([bool](Get-ADUser -Filter  {SamAccountName -eq $ADuser})) 
{   
    $ADSeaerch = Get-ADUser $ADuser -Properties Canonicalname | Select-Object CanonicalName
    Write-Host "Bruger findes i DKSUND AD:" -foregroundcolor Green
    Write-Host  $ADSeaerch.CanonicalName -foregroundcolor Green

    Write-Host "Opdaterer AD objekt $ExchangeSikkerhedsgruppe i SSI AD" -foregroundcolor Cyan
        Set-Location -Path 'SSIAD:'
    if ($company -eq "1"){
    
        Set-ADGroup $ExchangeSikkerhedsgruppe -GroupScope Universal -GroupCategory Security -ManagedBy $Manager -Description $SikkerhedsgrupperDescription
        Write-Host "TimeOut for 20 sek." -foregroundcolor Yellow 
        Start-Sleep 20

        Write-Host "Opdaterer 'Company' felt og tilføje  email adresse til gruppen" -foregroundcolor Cyan
        $GroupMail = $ExchangeSikkerhedsgruppe+'@ssi.dk'
        Set-ADGroup -Identity $ExchangeSikkerhedsgruppe -Add @{company="Statens Serum Institut";mail="$GroupMail"}
    }
    Elseif ($company -eq "2") {
        Set-ADGroup $ExchangeSikkerhedsgruppe -GroupScope Universal -GroupCategory Security -ManagedBy $Manager -Description $SikkerhedsgrupperDescription
        Write-Host "TimeOut for 20 sek." -foregroundcolor Yellow 
        Start-Sleep 20

        Write-Host "Opdaterer 'Company' felt og tilføje  email adresse til gruppen" -foregroundcolor Cyan
        $GroupMail = $ExchangeSikkerhedsgruppe+'@sundhedsdata.dk'
        Set-ADGroup -Identity $ExchangeSikkerhedsgruppe -Add @{company="Sundhedsdatastyrelsen";mail="$GroupMail"}
    }
    Else 
    { Write-Warning "Mislykkedes at oprette $ExchangeSikkerhedsgruppe, Noget gik galt..."}

    Write-Host "Tilføjer $Manager som Manager på AD Objekt $ADuser." -foregroundcolor Cyan
    Set-ADUser $ADuser -Manager $Manager

    Write-Host "Tilføjer $Manager til  gruppen $ExchangeSikkerhedsgruppe medlemskab." -foregroundcolor Cyan
    Add-ADGroupMember -Identity $ExchangeSikkerhedsgruppe -Members $Manager
    Write-Host "Tilføjer $Manager til  gruppen 'U-SSI-CTX-Standard applikationer' medlemskab." -foregroundcolor Cyan
    Add-ADGroupMember -Identity 'U-SSI-CTX-Standard applikationer' -Members  $Manager -ErrorAction SilentlyContinue

    
    Write-Host "Skifter til DKSUND AD" -foregroundcolor Yellow
    Set-Location -Path 'DKSUNDAD:'

    Write-Host "Connecting to Sessions" -ForegroundColor Magenta
    $reconnect =  $PSScriptRoot | Split-Path -Parent | Split-Path -Parent; Invoke-Expression "$reconnect\Logins\Session_reconnect.ps1"

    Write-Host "Forsøger at E-Mail aktivere fællesposkasse $ADuser på Exchange 2016" -foregroundcolor Cyan       
    if ([bool](Get-ADuser -Filter  {SamAccountName -eq $ADuser}))
    {
    Enable-SSIRemoteMailbox "$ADuser" -RemoteRoutingAddress "$ADuser@dksund.mail.onmicrosoft.com"
    Write-Host "Time Out 1 min..."  -foregroundcolor Yellow  
    Start-Sleep 60
    #som resultat vil den være synlig på Exchnage 2016 onprem men ikke i Offic365 , da den ikke endnu har en licens.
    }
    Else { Write-Warning "Fejlede at E-Mail aktivere fællespostkasse/bruger: $ADuser, noget gik galt..." }

    Write-Host "Connecting to Sessions" -ForegroundColor Magenta
    $reconnect =  $PSScriptRoot | Split-Path -Parent | Split-Path -Parent; Invoke-Expression "$reconnect\Logins\Session_reconnect.ps1"

    Write-Host "E-Mail aktivering af Sikkerhedsgruppe $ExchangeSikkerhedsgruppe i Exchange 2016" -foregroundcolor Cyan
    if ([bool](Get-ADGroup -Filter  {SamAccountName -eq $ExchangeSikkerhedsgruppe})) 
    {
        Write-Host "E-Mail aktivering af gruppen i Exchange 2016" -foregroundcolor Cyan
        Enable-SSIDistributionGroup -Identity $ExchangeSikkerhedsgruppe -ErrorAction Stop
    
        Write-Host "Tilføjer primær smtp adressen og disabled email politik for $ExchangeSikkerhedsgruppe på Exchange 2016" -foregroundcolor Cyan
        $new = $ExchangeSikkerhedsgruppe + "@ssi.dk"
        Set-SSIDistributionGroup $ExchangeSikkerhedsgruppe -PrimarySMTPAddress $new -EmailAddressPolicyEnabled $false
        Start-Sleep 60    
    }
    Else
    {
        Write-Warning "Kunne ikke e-mail aktivere $ExchangeSikkerhedsgruppe, da gruppen muligvis ikke findes i DKSUND/Exchange 2016, eller noget gik  galt." -ErrorAction Stop
    }
    

    Write-Host "Connecting to Sessions" -ForegroundColor Magenta
    $reconnect =  $PSScriptRoot | Split-Path -Parent | Split-Path -Parent; Invoke-Expression "$reconnect\Logins\Session_reconnect.ps1"


    Write-Host "Tildeler licens for $ADuser" -foregroundcolor Cyan  
    if ([bool](Get-ADuser -Filter  {SamAccountName -eq $ADuser}))
    {
		    #Write-Host "Tilføjer $ADuser til  gruppen 'O365_E5STD_U' medlemskab." -foregroundcolor Cyan
            #Add-ADGroupMember -Identity 'O365_E5STD_U' -Members  $ADuser -ErrorAction SilentlyContinue

 		    Set-MsolUser -UserPrincipalName "$ADuser@dksund.dk" -UsageLocation DK
            Set-MsolUserLicense -UserPrincipalName "$ADuser@dksund.dk" -AddLicenses dksund:STANDARDPACK
            #$x = New-MsolLicenseOptions -AccountSkuId "dksund:ENTERPRISEPREMIUM" -DisabledPlans "PROJECTWORKMANAGEMENT","YAMMER_ENTERPRISE","MCOSTANDARD","SHAREPOINTWAC", "SWAY", "RMS_S_ENTERPRISE"
		    #Set-MsolUserLicense -UserPrincipalName "$ADuser@dksund.dk" -LicenseOptions $x
        
            Write-Host "time out 16 min..." -foregroundcolor Yellow 
            Start-Sleep 960
        
    }
    Else { Write-Warning "Bruger '$ADuser' kunne ikke findes i AD, tjek om det er korrekt fællespostkasse/bruger" }


    Write-Host "Connecting to Sessions" -ForegroundColor Magenta
    $reconnect =  $PSScriptRoot | Split-Path -Parent | Split-Path -Parent; Invoke-Expression "$reconnect\Logins\Session_reconnect.ps1"

    Write-Host "Deaktiverer Clutter..." -foregroundcolor Cyan 
    Get-Mailbox $ADuser | set-Clutter -Enable $false

    Write-Host "Tilføjer sikkerhedsgruppe $ExchangeSikkerhedsgruppe som 'FUll access & Send As' på $ADuser" -foregroundcolor Cyan     
    $alias = $ADuser
    if (-not ($alias -eq "*" -or $alias -eq "")) {
         
         Get-Mailbox -identity $alias | add-mailboxpermission -user $ExchangeSikkerhedsgruppe -accessrights FullAccess -inheritancetype All
         Add-recipientPermission $alias -AccessRights SendAs -Trustee $ExchangeSikkerhedsgruppe -Confirm:$false
         Set-Mailbox -Identity $alias -GrantSendOnBehalfTo $ExchangeSikkerhedsgruppe
    }
    Else { write-host "Mislykkedes at tilknytte sikkerhedsgruppe: $ExchangeSikkerhedsgruppe adgang til fællespostkasse: $ADuser..." }

    Write-Host "Connecting to Sessions" -ForegroundColor Magenta
    $reconnect =  $PSScriptRoot | Split-Path -Parent | Split-Path -Parent; Invoke-Expression "$reconnect\Logins\Session_reconnect.ps1"


    Write-Host "Konverterer postkasse $ADuser til type Shared" -foregroundcolor Cyan 
    Set-Mailbox -Identity "$ADuser@dksund.onmicrosoft.com" -Type Shared
    Set-Mailbox -Identity $ADuser -Type Shared

    Write-Host "Opretter reggel at Mail som er sendt fra shared postkasse, bliver lagt 2 steder, nemlig i sendt items hos bruger og i selve fællespostkasse." -foregroundcolor Cyan 
    Set-Mailbox $ADuser -MessageCopyForSentAsEnabled $True 

    Write-Host "Sætter standard sprog til DK" -foregroundcolor Cyan 
    Set-MailboxRegionalConfiguration –identity $ADuser –language da-dk -LocalizeDefaultFolderName
           
    
    Write-Host "Connecting to Sessions" -ForegroundColor Magenta
    $reconnect =  $PSScriptRoot | Split-Path -Parent | Split-Path -Parent; Invoke-Expression "$reconnect\Logins\Session_reconnect.ps1"

    Write-Host "Ændre kalender rettighed af $ADuser til LimitedDetails " -foregroundcolor Cyan 
    $MailCalenderPath = "$ADuser" + ":\Kalender"
    Add-MailboxFolderPermission –Identity $MailCalenderPath –User ConciergeMobile –AccessRights Editor
    Add-MailboxFolderPermission $ADuser -User conciergemobile -AccessRights foldervisible -ErrorAction SilentlyContinue
    Set-mailboxfolderpermission $ADuser -User conciergemobile -AccessRights foldervisible
    Set-mailboxfolderpermission –identity $MailCalenderPath –user Default –Accessrights LimitedDetails
    Get-MailboxFolderPermission -Identity $MailCalenderPath


    Write-Host "time out 20 min..." -foregroundcolor Yellow 
    Start-Sleep 1200

    Write-Host "Fjerner Licensen fra $ADuser, da den nu blevet konverteret til type 'shared' fællespostkasse..." -foregroundcolor Cyan 
    #Get-MsolUser -UserPrincipalName $ADuser@dksund.dk |Select-Object UserPrincipalName, DisplayName, Department, {$_.Licenses.AccountSkuId}, WhenCreated
    
    #Remove-ADGroupMember -Identity 'O365_E5STD_U' -Members $ADuser -ErrorAction SilentlyContinue -Confirm:$false -Credential $Global:UserCredDksund
    $MSOLSKU = (Get-MsolUser -UserPrincipalName "$ADuser@dksund.dk").Licenses.AccountSkuId
    Set-MsolUserLicense -UserPrincipalName "$ADuser@dksund.dk" -RemoveLicenses $MSOLSKU



    Write-Host "Time out 5 min..." -foregroundcolor Yellow 
    Start-Sleep 300
    Write-Host "Connecting to Sessions" -ForegroundColor Magenta
    $reconnect =  $PSScriptRoot | Split-Path -Parent | Split-Path -Parent; Invoke-Expression "$reconnect\Logins\Session_reconnect.ps1"


    Write-Host "Obs! Husk at sætte hak i Manager må godt opdatere medlemskabsliste på sikkerhedsgruppe $ExchangeSikkerhedsgruppe, da dette kan ikke automatiseres pt. !!!!" -foregroundcolor Yellow -backgroundcolor DarkCyan
    Write-Host "Noter følgende i Nilex løsningsbeksrivelse:" -foregroundcolor Yellow -backgroundcolor DarkCyan
    $ResultMailboxType = (Get-Mailbox $ADuser).RecipientTypeDetails
    Write-Host "Postkasse type: $ResultMailboxType" -foregroundcolor Green -backgroundcolor DarkCyan
    $ResultSharedmail = (Get-Mailbox "$ADuser").PrimarySmtpAddress
    Write-Host "Fællespostkasse oprettet: $ResultSharedmail" -foregroundcolor Green -backgroundcolor DarkCyan
    $ResultGroup = (Get-Group $ExchangeSikkerhedsgruppe).WindowsEmailAddress
    Write-Host "Tilhørende sikkerhedsgruppe oprettet: $ResultGroup" -foregroundcolor Green -backgroundcolor DarkCyan
    Write-Host "Ejer: $Manager" -foregroundcolor Green -backgroundcolor DarkCyan
    Pause            
} 
else { 
    
    Write-Host "Objekt $ADuser Findes ikke i AD til at starte med, opretter " -foregroundcolor Yellow

    
    Write-Host "Opretter AD objekt Sikkerhedsgruppe: $ExchangeSikkerhedsgruppe i SSI AD" -foregroundcolor Cyan
        Set-Location -Path 'SSIAD:'
    <#
    if ($company -eq "1"){
    
        New-ADGroup -Name $ExchangeSikkerhedsgruppe -GroupScope Universal -GroupCategory Security -ManagedBy $Manager -Description $SikkerhedsgrupperDescription -Path $OUPathForExchangeSikkerhedsgrupperSSI
        Write-Host "TimeOut for 20 sek." -foregroundcolor Yellow 
        Start-Sleep 20

        Write-Host "Opdaterer 'Company' felt og tilføje  email adresse til gruppen" -foregroundcolor Cyan
        $GroupMail = $ExchangeSikkerhedsgruppe+'@ssi.dk'
        Set-ADGroup -Identity $ExchangeSikkerhedsgruppe -Add @{company="Statens Serum Institut";mail="$GroupMail"}
    }
    Elseif ($company -eq "2") {
        New-ADGroup -Name $ExchangeSikkerhedsgruppe -GroupScope Universal -GroupCategory Security -ManagedBy $Manager -Description $SikkerhedsgrupperDescription -Path $OUPathForExchangeSikkerhedsgrupperSDS
        Write-Host "TimeOut for 20 sek." -foregroundcolor Yellow 
        Start-Sleep 20

        Write-Host "Opdaterer 'Company' felt og tilføje  email adresse til gruppen" -foregroundcolor Cyan
        $GroupMail = $ExchangeSikkerhedsgruppe+'@sundhedsdata.dk'
        Set-ADGroup -Identity $ExchangeSikkerhedsgruppe -Add @{company="Sundhedsdatastyrelsen";mail="$GroupMail"}
    }
    Else 
    { Write-Warning "Mislykkedes at oprette $ExchangeSikkerhedsgruppe, Noget gik galt..."}
    #>

    [string]$company = Read-Host -Prompt "Tast 1 for @ssi.dk eller 2 for @sundhedsdata.dk til at vælge passende adresse."
    do
    {
          switch ($company)
          {
                 '1' {
                        New-ADGroup -Name $ExchangeSikkerhedsgruppe -GroupScope Universal -GroupCategory Security -ManagedBy $Manager -Description $SikkerhedsgrupperDescription -Path $OUPathForExchangeSikkerhedsgrupperSSI
                        Write-Host "TimeOut for 20 sek." -foregroundcolor Yellow 
                        Start-Sleep 20
    
                        Write-Host "Opdaterer 'Company' felt og tilføje  email adresse til gruppen" -foregroundcolor Cyan
                        $GroupMail = $ExchangeSikkerhedsgruppe+'@ssi.dk'
                        Set-ADGroup -Identity $ExchangeSikkerhedsgruppe -Add @{company="Statens Serum Institut";mail="$GroupMail"}
    		  }
              
                '2' {
                        New-ADGroup -Name $ExchangeSikkerhedsgruppe -GroupScope Universal -GroupCategory Security -ManagedBy $Manager -Description $SikkerhedsgrupperDescription -Path $OUPathForExchangeSikkerhedsgrupperSDS
                        Write-Host "TimeOut for 20 sek." -foregroundcolor Yellow 
                        Start-Sleep 20
    
                        Write-Host "Opdaterer 'Company' felt og tilføje  email adresse til gruppen" -foregroundcolor Cyan
                        $GroupMail = $ExchangeSikkerhedsgruppe+'@sundhedsdata.dk'
                        Set-ADGroup -Identity $ExchangeSikkerhedsgruppe -Add @{company="Sundhedsdatastyrelsen";mail="$GroupMail"}
    		  }
                Default {
                        $company = Read-Host -Prompt "Tast 1 for @ssi.dk eller 2 for @sundhedsdata.dk til at vælge passende adresse."
                
                }
          }
    
     }
     until (($company -eq '1') -or ($company -eq '2'))



    Write-Host "Tilføjer $Manager til  gruppen $ExchangeSikkerhedsgruppe medlemskab." -foregroundcolor Cyan
    Add-ADGroupMember -Identity $ExchangeSikkerhedsgruppe -Members $Manager
    Write-Host "Tilføjer $Manager til  gruppen 'U-SSI-CTX-Standard applikationer' medlemskab." -foregroundcolor Cyan
    Add-ADGroupMember -Identity 'U-SSI-CTX-Standard applikationer' -Members  $Manager -ErrorAction SilentlyContinue


    Write-Host "Opretter Fællespostkasse/SharedMail i SSI AD." -foregroundcolor Cyan
    Set-Location -Path 'SSIAD:'
    if ($company -eq "1"){
        New-ADUser -Name "$ADuser" -DisplayName $ADuser -GivenName $ADuser -Manager $Manager -Description $ADuserDescription -UserPrincipalName (“{0}@{1}” -f $ADuser,”ssi.dk”) -ChangePasswordAtLogon $true -Path $OUPathSharedMailSSI 
    }
    Elseif ($company -eq "2") {
        New-ADUser -Name "$ADuser" -DisplayName $ADuser -GivenName $ADuser -Manager $Manager -Description $ADuserDescription -UserPrincipalName (“{0}@{1}” -f $ADuser,”ssi.dk”) -ChangePasswordAtLogon $true -Path $OUPathSharedMailSDS
    }
    Else 
    { Write-Warning "Mislykkedes at oprette AD objekt: $ADuser."; Write-Host "Better luck next time, exiting script!" -ForegroundColor Cyan; pause;exit }


    Write-Host "time out 2 min (Synkroniserer i AD)" -foregroundcolor Yellow 
    Start-Sleep 120


    Write-Host "Tilføjer 'sammacount' email og opdatere 'comapny' felt field in AD for $ADuser." -foregroundcolor Cyan
    If (Get-ADUser -Filter  {Name -eq $ADuser}) 
    {
    
        If ($company -eq "1") {
        Set-ADUser $ADuser -SamAccountName $ADuser -EmailAddress $ADuser'@ssi.dk' -Company 'Statens Serum Institut' 
        }
        ElseIf ($company -eq "2") {
        Set-ADUser $ADuser -SamAccountName $ADuser -EmailAddress $ADuser'@sundhedsdata.dk' -Company 'Sundhedsdatastyrelsen' 
        }
    }
    Else { Write-Warning "Mislykkedes at tilføker 'samaccount' op opdatere 'company' felt for AD bruger $ADuser, Muligvis fordi den ikke findes i AD." ; Write-Host "Better luck next time, exiting script!" -ForegroundColor Cyan; pause;exit }

    <#Venter Synkronisering til DKSUND
    Write-Host "Time out 3 timer. venter til konti synkroniseret til DKSUND" -foregroundcolor Yellow 
    Start-Sleep 10800
    #>

    #Venter Synkronisering til DKSUND
    Write-Host "Skifter til DKSUND AD" -foregroundcolor Yellow
    Set-Location -Path 'DKSUNDAD:'

    do
    {
        
        Start-Sleep 1800
        $i++
        if ([bool](Get-ADGroup -Filter  {SamAccountName -eq $ExchangeSikkerhedsgruppe})) 
        {
        Write-Host "forsøger at E-Mail aktivere gruppen i Exchange 2016" -foregroundcolor Cyan
        Enable-SSIDistributionGroup -Identity $ExchangeSikkerhedsgruppe -ErrorAction Stop
        
        Write-Host "Tilføjer primær smtp adressen og disabled email politik for $ExchangeSikkerhedsgruppe på Exchange 2016" -foregroundcolor Cyan
        $new = $ExchangeSikkerhedsgruppe + "@ssi.dk"
        Set-SSIDistributionGroup $ExchangeSikkerhedsgruppe -PrimarySMTPAddress $new -EmailAddressPolicyEnabled $false 
        }
     
        if ($i -eq 8) {
        Write-Warning "Kunne ikke e-mail aktivere $ExchangeSikkerhedsgruppe, da gruppen muligvis ikke findes i DKSUND/Exchange 2016, eller noget gik  galt."
        Pause
        exit
        }
    
    }
    until ((Get-ADGroup -Filter  {SamAccountName -eq $ExchangeSikkerhedsgruppe}) -or ($i -ge 8 ) )

    Write-Host "Skifter til DKSUND AD" -foregroundcolor Yellow
    Set-Location -Path 'DKSUNDAD:'

    Write-Host "Connecting to Sessions" -ForegroundColor Magenta
    $reconnect =  $PSScriptRoot | Split-Path -Parent | Split-Path -Parent; Invoke-Expression "$reconnect\Logins\Session_reconnect.ps1"

    Write-Host "Forsøger at E-Mail aktivere fællesposkasse $ADuser på Exchange 2016" -foregroundcolor Cyan       
    if ([bool](Get-ADuser -Filter  {SamAccountName -eq $ADuser}))
    {
    Enable-SSIRemoteMailbox "$ADuser" -RemoteRoutingAddress "$ADuser@dksund.mail.onmicrosoft.com"
    Write-Host "Time Out 1 min..."  -foregroundcolor Yellow  
    Start-Sleep 60
    #som resultat vil den være synlig på Exchnage 2016 onprem men ikke i Offic365 , da den ikke endnu har en licens.
    }
    Else { Write-Warning "Fejlede at E-Mail aktivere fællespostkasse/bruger: $ADuser, noget gik galt..." }


    Write-Host "Connecting to Sessions" -ForegroundColor Magenta
    $reconnect =  $PSScriptRoot | Split-Path -Parent | Split-Path -Parent; Invoke-Expression "$reconnect\Logins\Session_reconnect.ps1"


    Write-Host "E-Mail aktivering af Sikkerhedsgruppe $ExchangeSikkerhedsgruppe i Exchange 2016" -foregroundcolor Cyan
    if ([bool](Get-ADGroup -Filter  {SamAccountName -eq $ExchangeSikkerhedsgruppe})) 
    {
        Write-Host "E-Mail aktivering af gruppen i Exchange 2016" -foregroundcolor Cyan
        Enable-SSIDistributionGroup -Identity $ExchangeSikkerhedsgruppe -ErrorAction Stop
    
        Write-Host "Tilføjer primær smtp adressen og disabled email politik for $ExchangeSikkerhedsgruppe på Exchange 2016" -foregroundcolor Cyan
        $new = $ExchangeSikkerhedsgruppe + "@ssi.dk"
        Set-SSIDistributionGroup $ExchangeSikkerhedsgruppe -PrimarySMTPAddress $new -EmailAddressPolicyEnabled $false
        Start-Sleep 60    
    }
    Else
    {
        Write-Warning "Kunne ikke e-mail aktivere $ExchangeSikkerhedsgruppe, da gruppen muligvis ikke findes i DKSUND/Exchange 2016, eller noget gik  galt." -ErrorAction Stop
    }


    #Fejlfinding
    #get-RemoteMailbox $ADuser
    #get-ADUser $ADuser
    #get-RemoteUserMailbox $ADuser
    #Disable-RemoteMailbox $ADuser

    Write-Host "Connecting to Sessions" -ForegroundColor Magenta
    $reconnect =  $PSScriptRoot | Split-Path -Parent | Split-Path -Parent; Invoke-Expression "$reconnect\Logins\Session_reconnect.ps1"


    Write-Host "Tildeler licens for $ADuser" -foregroundcolor Cyan  
    if ([bool](Get-ADuser -Filter  {SamAccountName -eq $ADuser}))
    {

            #Write-Host "Tilføjer $ADuser til  gruppen 'O365_E5STD_U' medlemskab." -foregroundcolor Cyan
            #Add-ADGroupMember -Identity 'O365_E5STD_U' -Members  $ADuser -ErrorAction SilentlyContinue

 		    Set-MsolUser -UserPrincipalName "$ADuser@dksund.dk" -UsageLocation DK
            Set-MsolUserLicense -UserPrincipalName "$ADuser@dksund.dk" -AddLicenses dksund:STANDARDPACK
            #$x = New-MsolLicenseOptions -AccountSkuId "dksund:ENTERPRISEPREMIUM" -DisabledPlans "PROJECTWORKMANAGEMENT","YAMMER_ENTERPRISE","MCOSTANDARD","SHAREPOINTWAC", "SWAY", "RMS_S_ENTERPRISE"
		    #Set-MsolUserLicense -UserPrincipalName "$ADuser@dksund.dk" -LicenseOptions $x
        
            Write-Host "Time out 16 min..." -foregroundcolor Yellow 
            Start-Sleep 960
        
    }
    Else { Write-Warning "Bruger '$ADuser' kunne ikke findes i AD, tjek om det er korrekt fællespostkasse/bruger" }


    Write-Host "Connecting to Sessions" -ForegroundColor Magenta
    $reconnect =  $PSScriptRoot | Split-Path -Parent | Split-Path -Parent; Invoke-Expression "$reconnect\Logins\Session_reconnect.ps1"

    Write-Host "Deaktiverer Clutter..." -foregroundcolor Cyan 
    Get-Mailbox $ADuser | set-Clutter -Enable $false

    Write-Host "(K) Tilføjer sikkerhedsgruppe $ExchangeSikkerhedsgruppe som 'FUll access & Send As' på $ADuser" -foregroundcolor Cyan     
    $alias = $ADuser
    if (-not ($alias -eq "*" -or $alias -eq "")) {
         
         Get-Mailbox -identity $alias | add-mailboxpermission -user $ExchangeSikkerhedsgruppe -accessrights FullAccess -inheritancetype All
         Add-recipientPermission $alias -AccessRights SendAs -Trustee $ExchangeSikkerhedsgruppe -Confirm:$false
         Set-Mailbox -Identity $alias -GrantSendOnBehalfTo $ExchangeSikkerhedsgruppe
    }
    Else { write-host "Mislykkedes at tilknytte sikkerhedsgruppe: $ExchangeSikkerhedsgruppe adgang til fællespostkasse: $ADuser..." }

    Write-Host "Connecting to Sessions" -ForegroundColor Magenta
    $reconnect =  $PSScriptRoot | Split-Path -Parent | Split-Path -Parent; Invoke-Expression "$reconnect\Logins\Session_reconnect.ps1"


    Write-Host "Konverterer postkasse $ADuser til type Shared" -foregroundcolor Cyan 
    Set-Mailbox -Identity "$ADuser@dksund.onmicrosoft.com" -Type Shared
    Set-Mailbox -Identity $ADuser -Type Shared

    Write-Host "Opretter reggel at Mail som er sendt fra shared postkasse, bliver lagt 2 steder, nemlig i sendt items hos bruger og i selve fællespostkasse." -foregroundcolor Cyan 
    Set-Mailbox $ADuser -MessageCopyForSentAsEnabled $True 

    Write-Host "Sætter standard sprog til DK" -foregroundcolor Cyan 
    Set-MailboxRegionalConfiguration –identity $ADuser –language da-dk -LocalizeDefaultFolderName


    Write-Host "Connecting to Sessions" -ForegroundColor Magenta
    $reconnect =  $PSScriptRoot | Split-Path -Parent | Split-Path -Parent; Invoke-Expression "$reconnect\Logins\Session_reconnect.ps1"

    Write-Host "Ændre kalender rettighed af $ADuser til LimitedDetails " -foregroundcolor Cyan 
    $MailCalenderPath = "$ADuser" + ":\Kalender"
    Set-mailboxfolderpermission –identity $MailCalenderPath –user Default –Accessrights LimitedDetails
    Add-MailboxFolderPermission –Identity $MailCalenderPath –User ConciergeMobile –AccessRights Editor
    Add-MailboxFolderPermission $ADuser -User conciergemobile -AccessRights foldervisible -ErrorAction SilentlyContinue
    Set-mailboxfolderpermission $ADuser -User conciergemobile -AccessRights foldervisible
    Get-MailboxFolderPermission -Identity $MailCalenderPath

    Write-Host "time out 20 min..." -foregroundcolor Yellow 
    Start-Sleep 1200

    Write-Host "Fjerner Licensen fra $ADuser, da den nu blevet konverteret til type 'shared' fællespostkasse..." -foregroundcolor Cyan 
    #Get-MsolUser -UserPrincipalName $ADuser@dksund.dk |Select-Object UserPrincipalName, DisplayName, Department, {$_.Licenses.AccountSkuId}, WhenCreated
    #Remove-ADGroupMember -Identity 'O365_E5STD_U' -Members $ADuser -ErrorAction SilentlyContinue -Confirm:$false -Credential $Global:UserCredDksund
    $MSOLSKU = (Get-MsolUser -UserPrincipalName "$ADuser@dksund.dk").Licenses.AccountSkuId
    Set-MsolUserLicense -UserPrincipalName "$ADuser@dksund.dk" -RemoveLicenses $MSOLSKU

    
    Write-Host "Time out 5 min..." -foregroundcolor Yellow 
    Start-Sleep 300

    Write-Host "Connecting to Sessions" -ForegroundColor Magenta
    $reconnect =  $PSScriptRoot | Split-Path -Parent | Split-Path -Parent; Invoke-Expression "$reconnect\Logins\Session_reconnect.ps1"


    Write-Host "Obs! Husk at sætte hak i Manager må godt opdatere medlemskabsliste på sikkerhedsgruppe $ExchangeSikkerhedsgruppe, da dette kan ikke automatiseres pt. !!!!" -foregroundcolor Yellow -backgroundcolor DarkCyan
    Write-Host "Noter følgende i Nilex løsningsbeksrivelse:" -foregroundcolor Yellow -backgroundcolor DarkCyan
    $ResultMailboxType = (Get-Mailbox $ADuser).RecipientTypeDetails
    Write-Host "Postkasse type: $ResultMailboxType" -foregroundcolor Green -backgroundcolor DarkCyan
    $ResultSharedmail = (Get-Mailbox "$ADuser").PrimarySmtpAddress
    Write-Host "Fællespostkasse oprettet: $ResultSharedmail" -foregroundcolor Green -backgroundcolor DarkCyan
    $ResultGroup = (Get-Group $ExchangeSikkerhedsgruppe).WindowsEmailAddress
    Write-Host "Tilhørende sikkerhedsgruppe oprettet: $ResultGroup" -foregroundcolor Green -backgroundcolor DarkCyan
    Write-Host "Ejer: $Manager" -foregroundcolor Green -backgroundcolor DarkCyan
    Pause 
    exit
} 

#Fejlfinding
#Get-Mailbox $ADuser | fl
#Get-ADGroup -Filter  {SamAccountName -eq 'samarbejdsogarbejdsmiljoeudvalget'} -Server $ServerNameDKSUND #http://stackoverflow.com/questions/6307127/hiding-errors-when-using-get-adgroup
#Get-ADGroup -Filter  {SamAccountName -eq 'samarbejdsogarbejdsmiljoeudvalget'} -Credential $UserCredDksund -AuthType Negotiate -Server $ServerNameDKSUND