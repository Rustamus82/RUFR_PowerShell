#PSVersion 5 Script made/assembled by Rust@m 02-05-2019
<#Login RUFR all AD login, Hybrid and o365
$CommandPath = (Get-Location).Path | Split-Path -Parent|Split-Path -Parent; $script = "$CommandPath\Logins\Login_SSI_SST_exch2010_DKSUND_Exchange365_RUFR.ps1"; & $script

#Login RUFR only office365
Import-Module MSOnline
$Global:credo365 = Get-Credential adm-rufr@dksund.onmicrosoft.com -Message "login til  Office 365"
$Global:sessiono365 = New-PSSession -ConfigurationName Microsoft.Exchange -Authentication Basic -ConnectionUri https://ps.outlook.com/powershell -AllowRedirection:$true  -Credential $Global:credo365
Import-PSSession $Global:sessiono365 -Prefix o365 -AllowClobber
Connect-MsolService -Credential $Global:credo365
cls
#>



#$NAME= "Test"; $FamilyName ="Name"
#$ADuserDisplayName = ($NAME+' '+$FamilyName)

#*********************************************************************************************************************************************

#Variables
$ADusers = Import-CSV .\Users.csv -Delimiter ";"
#Count:
$ADusers.count
$company = "STPK"
$Manager = ""
$ADuserDescription = "Virtuele brugere"

#dksund.dk/Organisationer/STPK/Brugere/
$OUPathSTPKUsers = 'OU=Brugere,OU=STPK,OU=Organisationer,DC=dksund,DC=dk'

$ADusers.ADKonto
$ADusers.Name
$ADusers.Surname
$ADusers.ADWorkZoneAfdelingsgruppe
$ADusers.ADWorkZoneRolle
#$ExpirationDate = (Get-ADUser rufr -Properties "AccountExpirationDate").AccountExpirationDate
$ExpirationDate = "12/18/2020"

$ADusers |ogv

#****************
#script execution 
#****************
Write-Host "Skifter til DKSUND AD" -foregroundcolor Yellow
<# 
Get-PSDrive
Set-Location -Path 'SSIAD:' 
Set-Location -Path 'SSTAD:'
Set-Location -Path 'DKSUNDAD:' 
#>


Foreach ($aduser in $ADusers) 
{   
        
                
        Write-Host "Opretter Bruger objekt i dksund AD." -foregroundcolor Cyan
        Write-Host ($ADuser).ADKonto -foregroundcolor Yellow

        $UserName = $ADusers.Name
        $UserSurename = $ADusers.Surname
        #$UserEmail = $ADusers.UserPrincipalName
        $ADkonto = $ADusers.ADKonto
        $DispName  = "$UserName $UserSurename ($ADkonto)"
                
        Write-Host "Opretter adm-konto..." -foregroundcolor Cyan
        New-ADUser -Name $ADkonto -GivenName $ADusers.Name -DisplayName $userDisplayName -UserPrincipalName (“{0}@{1}” -f $ADkonto,”dksund.dk”) -Description "$ADuserDescription" -Company "$company"  -Manager $Initals -ChangePasswordAtLogon $false -AccountPassword (ConvertTo-SecureString -AsPlainText '100%Arbejde100%' -Force) -Enabled $true -Path $OUPathSTPKUsers
        sleep 6
    
        Write-Host "Omdøber bruger..." -foregroundcolor Cyan
        Get-ADUser -Identity $ADkonto| Rename-ADObject -NewName "$DispName"
        sleep 6
    
        Write-Host "Sætter udløbsdato (if applicable)" -foregroundcolor Cyan
        Set-ADAccountExpiration -Identity $ADkonto -DateTime $ExpirationDate
        sleep 6
    
        Add-ADGroupMember -Identity $ADusers.ADWorkZoneAfdelingsgruppe $ADkonto
        Add-ADGroupMember -Identity $ADusers.ADWorkZoneRolle $ADkonto

  
}
     
