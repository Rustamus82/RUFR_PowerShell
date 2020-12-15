#PSVersion 5 Script made/assembled by Rust@m 11-07-2020
Write-Host "===================================================== Logon script ====================================================="  -backgroundcolor Red -foregroundcolor Cyan
Write-Host "[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][[][][][][][][]["  -foregroundcolor red
Write-Host
Write-Host "                                       Bemærk! du får 3 gange 'logins' popups!                                          " -foregroundcolor Cyan
Write-Host
Write-Host "                                            1st login er SST\adm-XXXX" -foregroundcolor Yellow
Write-Host
Write-Host "                                            2nd login er adm-XXXX@dksund.dk" -foregroundcolor Yellow
Write-Host
#Write-Host "3d login er til Office365. Benyt din <admn-XXXX>@dksund.onmicrosoft.com>" -foregroundcolor Yellow
#Write-Host
Write-Host "                                            3d login er SSI\adm-XXXX" -foregroundcolor Yellow
Write-Host
Write-Host "[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][[][][][][][][]["  -foregroundcolor Red
Write-Host "===================================================== Logon script ====================================================="  -backgroundcolor Red -foregroundcolor Cyan
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
#Session option timeout set variable.
#*********************************************************************************************************************************************
#$Global:PSSessionOption = New-PSSessionOption -OpenTimeOut  0  -OperationTimeout 0 -IdleTimeout 12000000
$Global:PSSessionOption = New-PSSessionOption -OpenTimeOut  180000  -OperationTimeout 0 -IdleTimeout 14400000
#*********************************************************************************************************************************************
#LOGIN
#*********************************************************************************************************************************************
#SST AD login og import af AD modulet.
$Global:UserCredSST = Get-Credential "sst.dk\adm_tibe" -Message "SST AD login og import af AD modulet"

#exchange 2010
$Global:Exchange2010_SST = "S-EXC-MBX01-P.sst.dk"
$Global:SessionExchangeSST= New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://S-EXC-MBX01-P.sst.dk/PowerShell/ -Authentication Kerberos -Credential $Global:UserCredSST
Import-PSSession $Global:SessionExchangeSST -Prefix SST
#Write-Verbose "Loading the Exchange snapin (module)"
Add-PSSnapin Microsoft.Exchange.Management.PowerShell.E2010 -ErrorAction SilentlyContinue

Start-Sleep 4;

#login til  Office 365 og session.
# Save credential to a file
#Get-Credential "adm_tibe@dksund.dk" | Export-Clixml C:\RUFR_PowerShell\Logins\xml\rufr_o365.xml
#Save credential with password to vairable.
# Load credential from file
#$credo365 =  Import-Clixml C:\RUFR_PowerShell\Logins\xml\rufr_o365.xml


#Import-Module exhcnage online & Azure AD
Import-Module ExchangeOnlineManagement
Import-Module AzureAD
$Global:UserCredDksund = Get-Credential "adm_tibe@dksund.dk" -Message "DKSUND AD login, Exchange Online & Hybrid"
Connect-ExchangeOnline -UserPrincipalName "adm_tibe@dksund.dk" -ShowProgress $true -ShowBanner:$false
#Connect-ExchangeOnline -Credential $Global:UserCredDksund -ShowProgress $true -ShowBanner:$false
#Connect-ExchangeOnline -UserPrincipalName "adm_tibe@dksund.dk" -ShowProgress $true 
Connect-AzureAD -AccountId "adm_tibe@dksund.dk"
#Connect-AzureAD -Credential $Global:UserCredDksund
<#
Get-AzureADUser -ObjectId rufr@dksund.dk
#>

##Import-Module MSOnline - Depricated soon.....
#Import-Module MSOnline
#$Global:sessiono365 = New-PSSession -ConfigurationName Microsoft.Exchange -Authentication Basic -ConnectionUri https://ps.outlook.com/powershell -AllowRedirection:$true  -Credential $Global:UserCredDksund
#Import-PSSession $Global:sessiono365 -AllowClobber
Connect-MsolService -Credential $Global:UserCredDksund
<#
Get-MsolUser -UserPrincipalName rufr@dksund.dk
#>


#DKSUND AD login og session til Exchange ON Premises (Hvis installeret opdatering KB3134758  giver fejl ved forbindelse til HybridServere.)
#$Global:UserCredDksund = Get-Credential "adm_tibe@dksund.dk" -Message "DKSUND AD login, Exchange Online & Hybrid"
$Global:SessionHyb = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://s-exc-hyb-02p.dksund.dk/PowerShell/ -Authentication Kerberos -SessionOption $Global:PSSessionOption -Credential $Global:UserCredDksund
#$Global:SessionHyb = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://s-exc-hyb-01p.dksund.dk/PowerShell/ -Authentication Kerberos -SessionOption $Global:PSSessionOption -Credential $Global:UserCredDksund
Import-PSSession $Global:SessionHyb -Prefix SSI -AllowClobber


#SSI AD login og import af AD modulet og Lync session.
$Global:UserCredSSI = Get-Credential "ssi\adm_tibe" -Message "SSI AD login"
$Global:sessionOptionLync = New-PSSessionOption -SkipCACheck -SkipRevocationCheck -SkipCNCheck
$Global:sessionLync = New-PSSession -ConnectionURI https://srv-lync-fe07.ssi.ad/OcsPowershell -Credential $Global:UserCredSSI -SessionOption $Global:sessionOptionLync -ErrorAction SilentlyContinue
#$Global:sessionLync = New-PSSession -ConnectionURI https://srv-lync-fe08.ssi.ad/OcsPowershell -Credential $Global:UserCredSSI -SessionOption $Global:sessionOptionLync -ErrorAction SilentlyContinue
Import-PSSession $Global:sessionLync -Prefix LYNC -AllowClobber -ErrorAction SilentlyContinue
#eksemmel Get-LYNCCsUser


#*********************************************************************************************************************************************
#Activer Directory Modules import
#*********************************************************************************************************************************************
Import-Module -Name ActiveDirectory 
Import-Module lync -ErrorAction SilentlyContinue
#Remove-Module -Name ActiveDirectory

#*********************************************************************************************************************************************
#Discover Domain Controllers
#*********************************************************************************************************************************************
Write-Host "Finder SSI, SST og DKSUND Domain Controllere" -foregroundcolor Yellow
#$ServerNameSSI = 'srv-ad-dc04.ssi.ad'
$Global:ServerNameSSI = (Get-ADDomainController -DomainName ssi.ad -Discover -NextClosestSite).HostName
#$ServerNameDKSUND = 'S-AD-DC-01P.dksund.dk'
$Global:ServerNameDKSUND = (Get-ADDomainController -DomainName dksund.dk -Discover -NextClosestSite).HostName
#$ServerNameSST = "dc01.sst.dk"
$Global:ServerNameSST = (Get-ADDomainController -DomainName sst.dk -Discover -NextClosestSite).HostName

#*********************************************************************************************************************************************
#PS driver creattion
#*********************************************************************************************************************************************
#PSdrive blev oprettet ved login script, som er ikke en del af den her execution.
Write-Host " Opretter PSdrive til SSI AD" -foregroundcolor Cyan
if (-not(Get-PSDrive 'SSIAD' -ErrorAction SilentlyContinue)) {
    New-PSDrive -Name 'SSIAD' -PSProvider ActiveDirectory -Server "$Global:ServerNameSSI" -Credential $Global:UserCredSSI -Root '//RootDSE/' -Scope Global
    #alternativet creds: Credential $(Get-Credential -Message 'Enter Password' -UserName "ssi\adm_tibe") 
     
} Else {
    Write-Output -InputObject "PSDrive SSIAD already exists"
}

#PSdrive blev oprettet ved login script, som er ikke en del af den her execution.
Write-Host " Opretter PSdrive til DKSUND AD" -foregroundcolor Cyan
if (-not(Get-PSDrive 'DKSUNDAD' -ErrorAction SilentlyContinue)) {
    New-PSDrive -Name 'DKSUNDAD' -PSProvider ActiveDirectory -Server "$Global:ServerNameDKSUND" -Credential $Global:UserCredDksund -Root '//RootDSE/' -Scope Global
    #alternativet creds: Credential $(Get-Credential -Message 'Enter Password' -UserName "sst.dk\adm_tibe"') 
     
} Else {
    Write-Output -InputObject "PSDrive DKSUNDAD already exists"
}

#PSdrive AD to SST
#PSdrive blev oprettet ved login script, som er ikke en del af den her execution.
Write-Host " Opretter PSdrive til SST AD" -foregroundcolor Cyan
if (-not(Get-PSDrive 'SSTAD' -ErrorAction SilentlyContinue)) {
    New-PSDrive -Name 'SSTAD' -PSProvider ActiveDirectory -Server "$Global:ServerNameSST" -Credential $Global:UserCredSST -Root '//RootDSE/' -Scope Global
    #alternativet creds: Credential $(Get-Credential -Message 'Enter Password' -UserName "adm_tibe@dksund.dk") 
     
} Else {
    Write-Output -InputObject "PSDrive SSTAD already exists"
}


<# 
#Get-PSDrive
Set-Location -Path 'SSIAD:' 
Set-Location -Path 'SSTAD:'
Set-Location -Path 'DKSUNDAD:' 

Write-Host "Skifter til SSI AD" -foregroundcolor Yellow
Set-Location -Path 'SSIAD:'

Write-Host "Skifter til DKSUND AD" -foregroundcolor Yellow
Set-Location -Path 'DKSUNDAD:'

Write-Host "Skifter til SST AD" -foregroundcolor Yellow
Set-Location -Path 'SSTAD:'


Remove-PSDrive -Name DKSUNDAD -Force
Remove-PSDrive -Name SSTAD -Force
Remove-PSDrive -Name SSIAD -Force
Set-Location $initialDirectory
#>
