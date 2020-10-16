#PSVersion 5 Script made/assembled by Rust@m 13-07-2017
cls; Write-Host "Du har valgt OpretMødelokalleSSI.ps1" -ForegroundColor Gray -BackgroundColor DarkCyan
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
#script
#*********************************************************************************************************************************************
[string]$userDisplayName = Read-Host -Prompt "Tast Displayname på mødelokale eksempel: (202-213 Mødelokale)"
[string]$ADuser =  Read-Host -Prompt "Tast 'Alias' på nyt mødelokaleminimum 5 og max 20 karaktere, Må IKKE indeholde: mellemrum, komma, ÆØÅ / \ (eksempel: 202-213)"
[string]$Manager =  Read-Host -Prompt "Angiv Ejers INITIALER på Mødelokalle/sikkerhedsgruppen"
[string]$Capacity =  Read-Host -Prompt "Tast 'antal' personer for Kapacitet af mødeloaket. Skriv tal:"

$OUpathRoomSSI = 'OU=Rooms,OU=Ressourcer,DC=ssi,DC=ad'
#$OUpathEquipmentSSI = 'OU=Equipment,OU=Ressourcer,DC=ssi,DC=ad'

$OUPathForExchangeSikkerhedsgrupperSSI = 'OU=ResourceGroups,OU=Exchange,OU=Groups,OU=SSI,DC=SSI,DC=ad'
#$OUPathSharedMailSSI = 'OU=Faelles postkasser,OU=Ressourcer,DC=SSI,DC=ad'

#$OUPathForExchangeSikkerhedsgrupperSDS = 'OU=Exchange Sikkerhedsgrupper,OU=Sundhedsdatastyrelsen,OU=Ressourcer,DC=SSI,DC=ad'
#$OUPathSharedMailSDS = 'OU=Faelles postkasser,OU=Sundhedsdatastyrelsen,OU=Ressourcer,DC=SSI,DC=ad'

[string]$ADuserDescription = 'Mødelokale'
[string]$ADgroup = 'GRP-'+$ADuser
Write-Host "Sikkerhedsgruppe bliver til $ADgroup" -ForegroundColor Yellow

#$company = "1"
#Read-Host "Tast 1 for @ssi.dk eller 2 for @sundhedsdata.dk for den nye postkasse"
$SikkerhedsgrupperDescription = "Giver fuld adgang til Mødelokalle $ADuser"


#Check for illegal characters - legal are a-zA-Z0-9-_.  also check for aloowed lenght from 5 to 20
if($ADuser -match '[^a-zA-Z0-9\-_\.]' -or $ADuser.Length -lt 5 -or $ADuser.Length -gt 20){

    Write-Host "Whoops --> You have used illegal characters in email alias!" -foregroundcolor red
    Write-Host "Mødelokale ALIAS på minimum 5 og max 20 karaktere, Må IKKE indeholde: mellemrum, komma, ÆØÅ / \ (eksempel: 202-213):" -ForegroundColor Yellow
    Write-Host "Better luck next time, exiting script!" -ForegroundColor Cyan
    pause
    exit
}

#****************
#script execution 
#****************
Write-Host "AdObjekt angivet til $ADuser" -foregroundcolor Yellow

Write-Host "Skifter til DKSUND AD" -foregroundcolor Yellow
Set-Location -Path 'DKSUNDAD:'

Write-Host "Checker om ADobjekt findes i forvejen i DKSUND AD...." -foregroundcolor Cyan
IF([bool](Get-AzureADUser -Filter "MailNickName eq '$ADuser'"))
{   
    $ADSeaerch = Get-ADUser $ADuser -Properties Canonicalname | Select-Object CanonicalName
    Write-Host "Bruger findes i DKSUND AD:" -foregroundcolor Green
    Write-Host  $ADSeaerch.CanonicalName -foregroundcolor Green

    Write-Host "Opdaterer AD objekt $ADgroup i SSI AD" -foregroundcolor Cyan
        Set-Location -Path 'SSIAD:'
    if ($company -eq "1"){
    
        Set-ADGroup $ADgroup -GroupScope Universal -GroupCategory Security -ManagedBy $Manager -Description $ADgroupDescription
        Write-Host "TimeOut for 20 sek." -foregroundcolor Yellow 
        Start-Sleep 20

        Write-Host "Opdaterer 'Company' felt og tilføje  email adresse til gruppen" -foregroundcolor Cyan
        $GroupMail = $ADgroup+'@ssi.dk'
        Set-ADGroup -Identity $ADgroup -Add @{company="Statens Serum Institut";mail="$GroupMail"}
    }
    Elseif ($company -eq "2") {
        Set-ADGroup $ADgroup -GroupScope Universal -GroupCategory Security -ManagedBy $Manager -Description $ADgroupDescription
        Write-Host "TimeOut for 20 sek." -foregroundcolor Yellow 
        Start-Sleep 20

        Write-Host "Opdaterer 'Company' felt og tilføje  email adresse til gruppen" -foregroundcolor Cyan
        $GroupMail = $ADgroup+'@sundhedsdata.dk'
        Set-ADGroup -Identity $ADgroup -Add @{company="Sundhedsdatastyrelsen";mail="$GroupMail"}
    }
    Else 
    { Write-Warning "Mislykkedes Opdaterer AD objekt $ADgroup, Noget gik galt..."}

    Write-Host "Tilføjer $Manager som Manager på AD Objekt $ADuser." -foregroundcolor Cyan
    Set-ADUser $ADuser -Manager $Manager

    Write-Host "Tilføjer $Manager til  gruppen $ADgroup medlemskab." -foregroundcolor Cyan
    Add-ADGroupMember -Identity $ADgroup -Members $Manager
    Write-Host "Tilføjer $Manager til  gruppen 'U-SSI-CTX-Standard applikationer' medlemskab." -foregroundcolor Cyan
    Add-ADGroupMember -Identity 'U-SSI-CTX-Standard applikationer' -Members  $Manager -ErrorAction SilentlyContinue

    
    Write-Host "Skifter til DKSUND AD" -foregroundcolor Yellow
    Set-Location -Path 'DKSUNDAD:'
    
    Write-Host "Forsøger at E-Mail aktivere Sikkerhedsgruppe $ADgroup  i Exchange 2016" -foregroundcolor Yellow
    do
    {
        
        Start-Sleep 120
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
     
        if ($i -eq 20) {
        Write-Warning "Kunne ikke e-mail aktivere $ADgroup, da gruppen muligvis ikke findes i DKSUND/Exchange 2016, eller noget gik  galt."}
    
    }
    until ((Get-AzureADGroup -Filter "DisplayName eq '$ADgroup'") -or ($i -ge 20 ) )


    Write-Host "Forsøger at E-Mail aktivere AdObjekt $ADuser på Exchange 2016" -foregroundcolor Cyan       
    IF([bool](Get-AzureADUser -Filter "MailNickName eq '$ADuser'"))
    {

        Write-Host "Connecting to Sessions" -ForegroundColor Magenta
        $reconnect =  $PSScriptRoot | Split-Path -Parent | Split-Path -Parent; Invoke-Expression "$reconnect\Logins\Session_reconnect.ps1"
        
        Enable-SSIRemoteMailbox "$ADuser" -RemoteRoutingAddress "$ADuser@dksund.mail.onmicrosoft.com"
        Write-Host "Time Out 1 min..."  -foregroundcolor Yellow  
        Start-Sleep 60
        #som resultat vil den være synlig på Exchnage 2016 onprem men ikke i Offic365 , da den ikke endnu har en licens.
    }
    Else { Write-Warning "Fejlede at E-Mail aktivere AdObjekt: $ADuser, noget gik galt..." }


    #Fejlfinding
    #get-RemoteMailbox $ADuser
    #get-ADUser $ADuser
    #get-RemoteUserMailbox $ADuser
    #Disable-RemoteMailbox $ADuser

    Write-Host "Tildeler licens for $ADuser forsøg første gang $('[{0:yyyy/mm/dd} {0:HH:mm:ss}]' -f (Get-Date))" -foregroundcolor Yellow
    do
    {
        
        Start-Sleep 120
        #Start-Sleep 3
        $i++
        IF([bool](Get-AzureADUser -Filter "MailNickName eq '$ADuser'"))
        {
            Write-Host "Connecting to Sessions" -ForegroundColor Magenta
            $reconnect =  $PSScriptRoot | Split-Path -Parent | Split-Path -Parent; Invoke-Expression "$reconnect\Logins\Session_reconnect.ps1"
            
            #Write-Host "Tilføjer $ADuser til  gruppen 'O365_E5STD_U' medlemskab." -foregroundcolor Cyan
            #Add-ADGroupMember -Identity 'O365_E5STD_U' -Members  $ADuser -ErrorAction SilentlyContinue
            
            Write-Host "Tildeler licens for $ADuser forsøg $i" -foregroundcolor Cyan
            Set-MsolUser -UserPrincipalName "$ADuser@dksund.dk" -UsageLocation DK
            Set-MsolUserLicense -UserPrincipalName "$ADuser@dksund.dk" -AddLicenses dksund:STANDARDPACK -ErrorAction SilentlyContinue
            #$x = New-MsolLicenseOptions -AccountSkuId "dksund:ENTERPRISEPREMIUM" -DisabledPlans "PROJECTWORKMANAGEMENT","YAMMER_ENTERPRISE","MCOSTANDARD","SHAREPOINTWAC", "SWAY", "RMS_S_ENTERPRISE"
            #Set-MsolUserLicense -UserPrincipalName "$ADuser@dksund.dk" -LicenseOptions $x
        }
     
        if ($i -eq 67) {
        Write-Warning "Kunne ikke tildele licen til $ADuser, da den findes ikke i Exchange online."}
    }
    until ([bool](Get-EXOMailbox  "$ADuser@dksund.dk" -ErrorAction SilentlyContinue) -or ($i -ge 67 ) )


    Write-Host "Deaktiverer Clutter..." -foregroundcolor Cyan 
    Get-Mailbox $ADuser | set-Clutter -Enable $false

    Write-Host "Tilføjer sikkerhedsgruppe $ADgroup som 'FUll access, Send As and on behalf' på $ADuser" -foregroundcolor Cyan     
    $alias = $ADuser
    if (-not ($alias -eq "*" -or $alias -eq "")) {

        Write-Host "Connecting to Sessions" -ForegroundColor Magenta
        $reconnect =  $PSScriptRoot | Split-Path -Parent | Split-Path -Parent; Invoke-Expression "$reconnect\Logins\Session_reconnect.ps1"              
        
        Get-Mailbox -identity $alias | add-mailboxpermission -user $ADgroup -accessrights FullAccess -inheritancetype All
        Add-recipientPermission $alias -AccessRights SendAs -Trustee $ADgroup -Confirm:$false
        Set-Mailbox -Identity $alias -GrantSendOnBehalfTo $ADgroup
    }
    Else { write-host "Mislykkedes at tilknytte sikkerhedsgruppe: $ADgroup adgang til AdObjekt: $ADuser..." }



    Write-Host "Forsøger at konvertere ADobjekt to type 'room' $ADuser $('[{0:yyyy/mm/dd} {0:HH:mm:ss}]' -f (Get-Date))" -foregroundcolor Yellow
    do
    {
        
        Start-Sleep 120
        #Start-Sleep 3
        $i++
        IF([bool](Get-EXOMailbox  "$ADuser@dksund.dk" -ErrorAction SilentlyContinue))
        {   
            Write-Host "Connecting to Sessions" -ForegroundColor Magenta
            $reconnect =  $PSScriptRoot | Split-Path -Parent | Split-Path -Parent; Invoke-Expression "$reconnect\Logins\Session_reconnect.ps1"
            
            Write-Host "Konverterer postkasse $ADuser til type Room og sætter kapacitet til: $Capacity" -foregroundcolor Cyan 
            Set-Mailbox -Identity "$ADuser@dksund.onmicrosoft.com" -Type room -ResourceCapacity $Capacity -ErrorAction stop
            Start-Sleep 60
            Set-Mailbox -Identity $ADuser -Type room -ResourceCapacity $Capacity    
        }
     
        if ($i -eq 20) {
        Write-Warning "Kunne ikke Konverterer $ADuser til type 'room' ved forsøg $i "}
    
    }
    until ([bool](Get-EXOMailbox  "$ADuser@dksund.dk" -ErrorAction SilentlyContinue) -or ($i -ge 20 ) )    
    
    
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
    
    
    Write-Host "Fjerner Licensen fra $ADuser, da den nu blevet konverteret til type 'rooms' $ADuser $('[{0:yyyy/mm/dd} {0:HH:mm:ss}]' -f (Get-Date))" -foregroundcolor Yellow
    do
    {
         
         Start-Sleep 1000
         #Start-Sleep 3
         $i++
         IF([bool](Get-EXOMailbox  "$ADuser@dksund.dk" -ErrorAction SilentlyContinue))
         {
            Write-Host "Connecting to Sessions" -ForegroundColor Magenta
            $reconnect =  $PSScriptRoot | Split-Path -Parent | Split-Path -Parent; Invoke-Expression "$reconnect\Logins\Session_reconnect.ps1"                 
            
            Write-Host "Fjerner Licensen fra $ADuser, da den nu blevet konverteret til type 'rooms' $ADuser " -foregroundcolor Yellow
            #Get-MsolUser -UserPrincipalName $ADuser@dksund.dk |Select-Object UserPrincipalName, DisplayName, Department, {$_.Licenses.AccountSkuId}, WhenCreated
            #Remove-ADGroupMember -Identity 'O365_E5STD_U' -Members $ADuser -ErrorAction SilentlyContinue -Confirm:$false -Credential $Global:UserCredDksund
            $MSOLSKU = (Get-MsolUser -UserPrincipalName "$ADuser@dksund.dk").Licenses.AccountSkuId
            Set-MsolUserLicense -UserPrincipalName "$ADuser@dksund.dk" -RemoveLicenses $MSOLSKU
         }
      
         if ($i -eq 20) {
         Write-Warning "Kunne fjerne licens for $ADuser da den ikke eksistere ved forsøg $i "}
     
    }
    until ([bool](Get-EXOMailbox  "$ADuser@dksund.dk" -ErrorAction SilentlyContinue) -or ($i -ge 20 ) )
    
    
    Write-Host "Connecting to Sessions" -ForegroundColor Magenta
    $reconnect =  $PSScriptRoot | Split-Path -Parent | Split-Path -Parent; Invoke-Expression "$reconnect\Logins\Session_reconnect.ps1"
    
    Write-Host "Obs! Husk at sætte hak i Manager må godt opdatere medlemskabsliste på sikkerhedsgruppe $ADgroup, da dette kan ikke automatiseres pt. !!!!" -foregroundcolor Yellow -backgroundcolor DarkCyan
    Write-Host "Noter følgende i Nilex løsningsbeksrivelse:" -foregroundcolor Yellow -backgroundcolor DarkCyan
    $ResultMailboxType = (Get-Mailbox $ADuser).RecipientTypeDetails
    Write-Host "Postkasse type: $ResultMailboxType" -foregroundcolor Green -backgroundcolor DarkCyan
    $ResultSharedmail = (Get-Mailbox "$ADuser").PrimarySmtpAddress
    Write-Host "$ResultMailboxType oprettet: $ResultSharedmail" -foregroundcolor Green -backgroundcolor DarkCyan
    $ResultGroup = (Get-Group $ADgroup).WindowsEmailAddress
    Write-Host "Tilhørende sikkerhedsgruppe oprettet: $ResultGroup" -foregroundcolor Green -backgroundcolor DarkCyan
    Write-Host "Ejer: $Manager" -foregroundcolor Green -backgroundcolor DarkCyan
    Pause            
} 
else { 
    
    Write-Host "Objekt $ADuser Findes ikke i AD til at starte med, opretter " -foregroundcolor Yellow

    
    Write-Host "Opretter AD objekt Sikkerhedsgruppe: $ADgroup i SSI AD" -foregroundcolor Cyan
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
    #>

    
    do
    {
          switch ($company)
          {
                 '1' {
                        New-ADGroup -Name $ADgroup -GroupScope Universal -GroupCategory Security -ManagedBy $Manager -Description $ADgroupDescription -Path $OUPathForExchangeSikkerhedsgrupperSSI
                        Write-Host "TimeOut for 20 sek." -foregroundcolor Yellow 
                        Start-Sleep 20
    
                        Write-Host "Opdaterer 'Company' felt og tilføje  email adresse til gruppen" -foregroundcolor Cyan
                        $GroupMail = $ADgroup+'@ssi.dk'
                        Set-ADGroup -Identity $ADgroup -Add @{company="Statens Serum Institut";mail="$GroupMail"}
    		  }
              
                '2' {
                        New-ADGroup -Name $ADgroup -GroupScope Universal -GroupCategory Security -ManagedBy $Manager -Description $ADgroupDescription -Path $OUPathForExchangeSikkerhedsgrupperSDS
                        Write-Host "TimeOut for 20 sek." -foregroundcolor Yellow 
                        Start-Sleep 20
    
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
    Add-ADGroupMember -Identity 'U-SSI-CTX-Standard applikationer' -Members  $Manager -ErrorAction SilentlyContinue


    Write-Host "Opretter AdObjekt i SSI AD." -foregroundcolor Cyan
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

    Write-Host "Forsøger at E-Mail aktivere Sikkerhedsgruppe $ADgroup  i Exchange 2016" -foregroundcolor Yellow
    do
    {
        
        Start-Sleep 1800
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
     
        if ($i -eq 8) {
        Write-Warning "Kunne ikke e-mail aktivere $ADgroup, da gruppen muligvis ikke findes i DKSUND/Exchange 2016, eller noget gik  galt."}
    
    }
    until ((Get-AzureADGroup -Filter "DisplayName eq '$ADgroup'") -or ($i -ge 8 ) )


    Write-Host "Forsøger at E-Mail aktivere fællesposkasse $ADuser på Exchange 2016" -foregroundcolor Cyan       
    IF([bool](Get-AzureADUser -Filter "MailNickName eq '$ADuser'"))
    {

        Write-Host "Connecting to Sessions" -ForegroundColor Magenta
        $reconnect =  $PSScriptRoot | Split-Path -Parent | Split-Path -Parent; Invoke-Expression "$reconnect\Logins\Session_reconnect.ps1"
        
        Enable-SSIRemoteMailbox "$ADuser" -RemoteRoutingAddress "$ADuser@dksund.mail.onmicrosoft.com"
        Write-Host "Time Out 1 min..."  -foregroundcolor Yellow  
        Start-Sleep 60
        #som resultat vil den være synlig på Exchnage 2016 onprem men ikke i Offic365 , da den ikke endnu har en licens.
    }
    Else { Write-Warning "Fejlede at E-Mail aktivere AdObjekt: $ADuser, noget gik galt..." }


    #Fejlfinding
    #get-RemoteMailbox $ADuser
    #get-ADUser $ADuser
    #get-RemoteUserMailbox $ADuser
    #Disable-RemoteMailbox $ADuser

    Write-Host "Tildeler licens for $ADuser forsøg første gang $('[{0:yyyy/mm/dd} {0:HH:mm:ss}]' -f (Get-Date))" -foregroundcolor Yellow
    
    do
    {
        
        Start-Sleep 600
        #Start-Sleep 3
        $i++
        IF([bool](Get-AzureADUser -Filter "MailNickName eq '$ADuser'"))
        {
            Write-Host "Connecting to Sessions" -ForegroundColor Magenta
            $reconnect =  $PSScriptRoot | Split-Path -Parent | Split-Path -Parent; Invoke-Expression "$reconnect\Logins\Session_reconnect.ps1"
            
            #Write-Host "Tilføjer $ADuser til  gruppen 'O365_E5STD_U' medlemskab." -foregroundcolor Cyan
            #Add-ADGroupMember -Identity 'O365_E5STD_U' -Members  $ADuser -ErrorAction SilentlyContinue
            
            Write-Host "Tildeler licens for $ADuser forsøg $i" -foregroundcolor Cyan
            Set-MsolUser -UserPrincipalName "$ADuser@dksund.dk" -UsageLocation DK
            Set-MsolUserLicense -UserPrincipalName "$ADuser@dksund.dk" -AddLicenses dksund:STANDARDPACK -ErrorAction SilentlyContinue
            #$x = New-MsolLicenseOptions -AccountSkuId "dksund:ENTERPRISEPREMIUM" -DisabledPlans "PROJECTWORKMANAGEMENT","YAMMER_ENTERPRISE","MCOSTANDARD","SHAREPOINTWAC", "SWAY", "RMS_S_ENTERPRISE"
            #Set-MsolUserLicense -UserPrincipalName "$ADuser@dksund.dk" -LicenseOptions $x
        }
     
        if ($i -eq 18) {
        Write-Warning "Kunne ikke tildele licen til $ADuser, da den findes ikke i Exchange online."}
    }
    until ([bool](Get-EXOMailbox  "$ADuser@dksund.dk" -ErrorAction SilentlyContinue) -or ($i -ge 18 ) )


    Write-Host "Deaktiverer Clutter..." -foregroundcolor Cyan 
    Get-Mailbox $ADuser | set-Clutter -Enable $false

    Write-Host "Tilføjer sikkerhedsgruppe $ADgroup som 'FUll access, Send As and on behalf' på $ADuser" -foregroundcolor Cyan     
    $alias = $ADuser
    if (-not ($alias -eq "*" -or $alias -eq "")) {

        Write-Host "Connecting to Sessions" -ForegroundColor Magenta
        $reconnect =  $PSScriptRoot | Split-Path -Parent | Split-Path -Parent; Invoke-Expression "$reconnect\Logins\Session_reconnect.ps1"              
        
        Get-Mailbox -identity $alias | add-mailboxpermission -user $ADgroup -accessrights FullAccess -inheritancetype All
        Add-recipientPermission $alias -AccessRights SendAs -Trustee $ADgroup -Confirm:$false
        Set-Mailbox -Identity $alias -GrantSendOnBehalfTo $ADgroup
    }
    Else { write-host "Mislykkedes at tilknytte sikkerhedsgruppe: $ADgroup adgang til AdObjekt: $ADuser..." }



    Write-Host "Forsøger at konvertere ADobjekt to type 'room' $ADuser $('[{0:yyyy/mm/dd} {0:HH:mm:ss}]' -f (Get-Date))" -foregroundcolor Yellow
    do
    {
        
        Start-Sleep 120
        #Start-Sleep 3
        $i++
        IF([bool](Get-EXOMailbox  "$ADuser@dksund.dk" -ErrorAction SilentlyContinue))
        {   
            Write-Host "Connecting to Sessions" -ForegroundColor Magenta
            $reconnect =  $PSScriptRoot | Split-Path -Parent | Split-Path -Parent; Invoke-Expression "$reconnect\Logins\Session_reconnect.ps1"
            
            Write-Host "Konverterer postkasse $ADuser til type Room og sætter kapacitet til: $Capacity" -foregroundcolor Cyan 
            Set-Mailbox -Identity "$ADuser@dksund.onmicrosoft.com" -Type room -ResourceCapacity $Capacity -ErrorAction stop
            Start-Sleep 60
            Set-Mailbox -Identity $ADuser -Type room -ResourceCapacity $Capacity
        }
     
        if ($i -eq 20) {
        Write-Warning "Kunne ikke Konverterer $ADuser til type 'room' ved forsøg $i "}
    
    }
    until ([bool](Get-EXOMailbox  "$ADuser@dksund.dk" -ErrorAction SilentlyContinue) -or ($i -ge 20 ) )
    
    

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

    Write-Host "Fjerner Licensen fra $ADuser, da den nu blevet konverteret til type 'rooms' $ADuser $('[{0:yyyy/mm/dd} {0:HH:mm:ss}]' -f (Get-Date))" -foregroundcolor Yellow
    do
    {
         
         Start-Sleep 1000
         #Start-Sleep 3
         $i++
         IF([bool](Get-EXOMailbox  "$ADuser@dksund.dk" -ErrorAction SilentlyContinue))
         {
            Write-Host "Connecting to Sessions" -ForegroundColor Magenta
            $reconnect =  $PSScriptRoot | Split-Path -Parent | Split-Path -Parent; Invoke-Expression "$reconnect\Logins\Session_reconnect.ps1"                 
            
            Write-Host "Fjerner Licensen fra $ADuser, da den nu blevet konverteret til type 'rooms' $ADuser " -foregroundcolor Yellow
            #Get-MsolUser -UserPrincipalName $ADuser@dksund.dk |Select-Object UserPrincipalName, DisplayName, Department, {$_.Licenses.AccountSkuId}, WhenCreated
            #Remove-ADGroupMember -Identity 'O365_E5STD_U' -Members $ADuser -ErrorAction SilentlyContinue -Confirm:$false -Credential $Global:UserCredDksund
            $MSOLSKU = (Get-MsolUser -UserPrincipalName "$ADuser@dksund.dk").Licenses.AccountSkuId
            Set-MsolUserLicense -UserPrincipalName "$ADuser@dksund.dk" -RemoveLicenses $MSOLSKU
         }
      
         if ($i -eq 20) {
         Write-Warning "Kunne fjerne licens for $ADuser da den ikke eksistere ved forsøg $i "}
     
    }
    until ([bool](Get-EXOMailbox  "$ADuser@dksund.dk" -ErrorAction SilentlyContinue) -or ($i -ge 20 ) )
  
    
    Write-Host "Connecting to Sessions" -ForegroundColor Magenta
    $reconnect =  $PSScriptRoot | Split-Path -Parent | Split-Path -Parent; Invoke-Expression "$reconnect\Logins\Session_reconnect.ps1"

    Write-Host "Obs! Husk at sætte hak i Manager må godt opdatere medlemskabsliste på sikkerhedsgruppe $ADgroup, da dette kan ikke automatiseres pt. !!!!" -foregroundcolor Yellow -backgroundcolor DarkCyan
    Write-Host "Noter følgende i Nilex løsningsbeksrivelse:" -foregroundcolor Yellow -backgroundcolor DarkCyan
    $ResultMailboxType = (Get-Mailbox $ADuser).RecipientTypeDetails
    Write-Host "Postkasse type: $ResultMailboxType" -foregroundcolor Green -backgroundcolor DarkCyan
    $ResultSharedmail = (Get-Mailbox "$ADuser").PrimarySmtpAddress
    Write-Host "$ResultMailboxType oprettet: $ResultSharedmail" -foregroundcolor Green -backgroundcolor DarkCyan
    $ResultGroup = (Get-Group $ADgroup).WindowsEmailAddress
    Write-Host "Tilhørende sikkerhedsgruppe oprettet: $ResultGroup" -foregroundcolor Green -backgroundcolor DarkCyan
    Write-Host "Ejer: $Manager" -foregroundcolor Green -backgroundcolor DarkCyan
    Pause 
    exit
} 