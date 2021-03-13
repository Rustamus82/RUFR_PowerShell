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
$Global:UserCredSST = Get-Credential "sst.dk\$global:UserInitial" -Message "SST AD login og import af AD modulet"
#Import-Module Azure AD
Import-Module AzureAD
$Global:UserCredDksund = Get-Credential "$global:UserInitial@dksund.dk" -Message "DKSUND AD login, Exchange Online & Hybrid"
Connect-AzureAD -AccountId "$global:UserInitial@dksund.dk"

#SSI AD login og import af AD modulet og Lync session.
$Global:UserCredSSI = Get-Credential "ssi\$global:UserInitial" -Message "SSI AD login"

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
    #alternativet creds: Credential $(Get-Credential -Message 'Enter Password' -UserName "ssi\$global:UserInitial") 
     
} Else {
    Write-Output -InputObject "PSDrive SSIAD already exists"
}

#PSdrive blev oprettet ved login script, som er ikke en del af den her execution.
Write-Host " Opretter PSdrive til DKSUND AD" -foregroundcolor Cyan
if (-not(Get-PSDrive 'DKSUNDAD' -ErrorAction SilentlyContinue)) {
    New-PSDrive -Name 'DKSUNDAD' -PSProvider ActiveDirectory -Server "$Global:ServerNameDKSUND" -Credential $Global:UserCredDksund -Root '//RootDSE/' -Scope Global
    #alternativet creds: Credential $(Get-Credential -Message 'Enter Password' -UserName "sst.dk\$global:UserInitial"') 
     
} Else {
    Write-Output -InputObject "PSDrive DKSUNDAD already exists"
}

#PSdrive AD to SST
#PSdrive blev oprettet ved login script, som er ikke en del af den her execution.
Write-Host " Opretter PSdrive til SST AD" -foregroundcolor Cyan
if (-not(Get-PSDrive 'SSTAD' -ErrorAction SilentlyContinue)) {
    New-PSDrive -Name 'SSTAD' -PSProvider ActiveDirectory -Server "$Global:ServerNameSST" -Credential $Global:UserCredSST -Root '//RootDSE/' -Scope Global
    #alternativet creds: Credential $(Get-Credential -Message 'Enter Password' -UserName "$global:UserInitial@dksund.dk") 
     
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
