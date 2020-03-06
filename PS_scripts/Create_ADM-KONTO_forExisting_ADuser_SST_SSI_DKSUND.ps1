#PSVersion 5. Script made/assembled by Rust@m dato: 15-02-2017
Write-Host "Du har valgt CreateADM-User_forExistingADuserSST_SSI" -ForegroundColor Gray -BackgroundColor DarkCyan
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
[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic') | Out-Null

$AD  = [Microsoft.VisualBasic.Interaction]::InputBox("Tast '1' for oprettelse i SSI AD                          Tast '2' for oprettelse i SST AD                          Tast '3' for oprettelse i DKSUND AD", "Active Directory", "$env:ActiverDirectory") 
$SD  = [Microsoft.VisualBasic.Interaction]::InputBox("Skriv servicedesk sag her SD","Sagsnummer", "$env:sag") 
$Initals  = [Microsoft.VisualBasic.Interaction]::InputBox("Angiv eksisterende Brugerens INITIALER som ADM_XXX konto skal opretter for","Initaler", "$env:initialer") 

#$Initals = Read-Host -Prompt "Angiv eksisterende Brugerens INITIALER som ADM-XXX konto skal opretter for"
#$AD = Read-Host "Tast '1' for oprettelse i SSI AD eller tast '2' for oprettelse i SST AD"
#$SD = Read-Host "Skriv servicedesk sag her SD" 

#sst.dk/Administratorkonti/Local Workstation Administrators
$OUPathLocalWorkstationAdministratorsSST = 'OU=Local Workstation Administrators,OU=Tier2,DC=sst,DC=dk'
#ssi.ad/Administrativ Users/Local Workstation Administrators/
$OUPathLocalWorkstationAdministratorsSSI = 'OU=Local Workstation Administrators,OU=Tier2,DC=ssi,DC=ad'
#dksund.dk/Tier2/Local Workstation Administrators/
$OUPathLocalWorkstationAdministratorsDKSUND = 'OU=Local Workstation Administrators,OU=Tier2,DC=dksund,DC=dk'



Write-Host "Opretter ADM-Konti for eksisterende AD bruger." -foregroundcolor Cyan
if ($AD -eq "1"){
    #PSdrive blev oprettet ved login script, som er ikke en del af den her execution.
    Write-Host "i SSI AD" -foregroundcolor Yellow
    Set-Location -Path 'SSIAD:'
    $UserInfo = Get-ADUser $Initals 
    $UserName = $UserInfo.GivenName
    $UserSurename = $UserInfo.Surname
    $UserEmail = $UserInfo.UserPrincipalName
    $admkonto = 'adm_'+$Initals
    $admDispName  = "$UserName $UserSurename ($admkonto)"
    $ExpirationDate = (Get-ADUser $Initals -Properties "AccountExpirationDate").AccountExpirationDate
    
    Write-Host "Opretter adm-konto..." -foregroundcolor Cyan
    New-ADUser -Name $admkonto  -UserPrincipalName (“{0}@{1}” -f $admkonto,”ssi.ad”) -Company "Statens Serum Institut"  -Manager $Initals -ChangePasswordAtLogon $false -AccountPassword (ConvertTo-SecureString -AsPlainText '100%Arbejde100%' -Force) -Enabled $true  -Description "Administrativ bruger for $UserName $UserSurename, konto $UserEmail - SD$SD" -Path $OUPathLocalWorkstationAdministratorsSSI
    sleep 6
    
    Write-Host "Omdøber bruger..." -foregroundcolor Cyan
    Get-ADUser -Identity $admkonto | Rename-ADObject -NewName "$admDispName"
    sleep 6
    
    Write-Host "Sætter udløbsdato (if applicable)" -foregroundcolor Cyan
    Set-ADAccountExpiration -Identity $admkonto -DateTime  $ExpirationDate
    sleep 6
    
    Add-ADGroupMember -Identity 'Protected Users' $admkonto

    Write-Host "Konto oprettet, noter i sagen: ssi\$admkonto" -foregroundcolor Green -backgroundcolor DarkCyan
}
Elseif ($AD -eq "2") {
    #PSdrive blev oprettet ved login script, som er ikke en del af den her execution.
    Write-Host "i SST AD" -foregroundcolor Yellow
    Set-Location -Path 'SSTAD:'
    $UserInfo = Get-ADUser $Initals
    $UserName = $UserInfo.GivenName
    $UserSurename = $UserInfo.Surname
    $UserEmail = $UserInfo.UserPrincipalName
    $admkonto = 'adm_'+$Initals
    $admDispName  = "$UserName $UserSurename ($admkonto)"
    $ExpirationDate = (Get-ADUser $Initals -Properties "AccountExpirationDate").AccountExpirationDate   
    
    Write-Host "Opretter adm_konto..." -foregroundcolor Cyan
    New-ADUser -Name $admkonto  -UserPrincipalName (“{0}@{1}” -f $admkonto,”sst.dk”) -Company "Sundhedsstyrelsen" -Manager $Initals -ChangePasswordAtLogon $false -AccountPassword (ConvertTo-SecureString -AsPlainText '100%Arbejde100%' -Force) -Enabled $true  -Description "Administrativ bruger for $UserName $UserSurename, konto $UserEmail - SD$SD" -Path $OUPathLocalWorkstationAdministratorsSST
    sleep 6
    
    Write-Host "Omdøber bruger..." -foregroundcolor Cyan
    Get-ADUser -Identity $admkonto | Rename-ADObject -NewName "$admDispName"
    sleep 6
    
    Write-Host "Sætter udløbsdato (if applicable)" -foregroundcolor Cyan
    Set-ADAccountExpiration -Identity $admkonto -DateTime  $ExpirationDate
    sleep 6

    Add-ADGroupMember -Identity 'Protected Users' $admkonto

 
    if ([bool](Get-ADUser -Filter  {SamAccountName -eq $admkonto})){
    
    Write-Host "Konto oprettet, noter i sagen: sst.dk\$admkonto" -foregroundcolor Green -backgroundcolor DarkCyan

    }
    Else { Write-Warning "Fejlede ved oprettelse af $admkonto, noget gik galt..." }
        
}
Elseif ($AD -eq "3") {
    #PSdrive blev oprettet ved login script, som er ikke en del af den her execution.
    Write-Host "i DKSUND.DK AD" -foregroundcolor Yellow
    Set-Location -Path 'DKSUNDAD:'
    $UserInfo = Get-ADUser $Initals
    $UserName = $UserInfo.GivenName
    $UserSurename = $UserInfo.Surname
    $UserEmail = $UserInfo.UserPrincipalName
    $admkonto = 'adm_'+$Initals
    $admDispName  = "$UserName $UserSurename ($admkonto)"
    $ExpirationDate = (Get-ADUser $Initals -Properties "AccountExpirationDate").AccountExpirationDate   
    
    Write-Host "Opretter adm_konto..." -foregroundcolor Cyan
    New-ADUser -Name $admkonto  -UserPrincipalName (“{0}@{1}” -f $admkonto,”dksund.dk”) -Company "Sundhedsdatastyrelsen" -Manager $Initals -ChangePasswordAtLogon $false -AccountPassword (ConvertTo-SecureString -AsPlainText '100%Arbejde100%' -Force) -Enabled $true  -Description "Administrativ bruger for $UserName $UserSurename, konto $UserEmail - SD$SD" -Path $OUPathLocalWorkstationAdministratorsDKSUND
    sleep 6
    
    Write-Host "Omdøber bruger..." -foregroundcolor Cyan
    Get-ADUser -Identity $admkonto | Rename-ADObject -NewName "$admDispName"
    sleep 6
    
    Write-Host "Sætter udløbsdato (if applicable)" -foregroundcolor Cyan
    Set-ADAccountExpiration -Identity $admkonto -DateTime  $ExpirationDate
    sleep 6

    Add-ADGroupMember -Identity 'Protected Users' $admkonto

 
    if ([bool](Get-ADUser -Filter  {SamAccountName -eq $admkonto})){
    
    Write-Host "Konto oprettet, noter i sagen: dksund.dk\$admkonto" -foregroundcolor Green -backgroundcolor DarkCyan

    }
    Else { Write-Warning "Fejlede ved oprettelse af $admkonto, noget gik galt..." }
        
}
Else 
{ Write-Warning "Kunne ikke oprette konto $admkonto, muligvis findes i forvejen eller har glemt at vælge AD flow"}

pause
cls
 
#Get-PSDrive



