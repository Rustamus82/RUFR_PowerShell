#PSVersion 5 Script made/assembled by Rust@m 05-10-2017

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
#LOGIN
#*********************************************************************************************************************************************
#ssidmz01 AD login og import af AD modulet.
$Global:UserCredssidmz01 = Get-Credential ssidmz01.local\adm-rufr -Message "ssidmz01.loca AD login"
#SSI AD login og import af AD modulet.
$Global:UserCredSSI = Get-Credential ssi\adm-rufr -Message "SSI AD login"

#*********************************************************************************************************************************************
#Activer Directory Modules import
#*********************************************************************************************************************************************
Import-Module -Name ActiveDirectory 
#Remove-Module -Name ActiveDirectory

#*********************************************************************************************************************************************
#Discover Domain Controllers
#*********************************************************************************************************************************************
Write-Host "Finder SSI, srv-ad-dmzdc01.ssidmz01.local Domain Controllere" -foregroundcolor Yellow
$ServerNamessidmz01 = 'srv-ad-dmzdc01.ssidmz01.local'

#$ServerNameSSI = 'srv-ad-dc04.ssi.ad'
$ServerNameSSI = (Get-ADDomainController -DomainName ssi.ad -Discover -NextClosestSite).HostName

#PSdrive blev oprettet ved login script, som er ikke en del af den her execution.
Write-Host " Opretter PSdrive til ssidmz01.loca AD" -foregroundcolor Cyan
if (-not(Get-PSDrive 'ssidmz01loca' -ErrorAction SilentlyContinue)) {
    New-PSDrive –Name 'ssidmz01loca' –PSProvider ActiveDirectory –Server "$ServerNamessidmz01" -Credential $Global:UserCredssidmz01 –Root '//RootDSE/' -Scope Global
    #alternativet creds: –Credential $(Get-Credential -Message 'Enter Password' -UserName 'SST.DK\adm-RUFR') 
     
} Else {
    Write-Output -InputObject "PSDrive ssidmz01loca already exists"
}

#PSdrive blev oprettet ved login script, som er ikke en del af den her execution.
Write-Host " Opretter PSdrive til SSI AD" -foregroundcolor Cyan
if (-not(Get-PSDrive 'SSIAD' -ErrorAction SilentlyContinue)) {
    New-PSDrive –Name 'SSIAD' –PSProvider ActiveDirectory –Server "$ServerNameSSI" -Credential $UserCredSSI –Root '//RootDSE/' -Scope Global
    #alternativet creds: –Credential $(Get-Credential -Message 'Enter Password' -UserName 'SST.DK\adm-RUFR') 
     
} Else {
    Write-Output -InputObject "PSDrive SSIAD already exists"
}

cls

C:\RUFR_PowerShell\ISE_scripts_only\Opret_ADX_ssidmz01\Create_ADM-KONTO_forExisting_ADuser_SST_SSI_ssidmz01.ps1


<# 
#Get-PSDrive
Set-Location -Path 'SSIAD:' 
Set-Location -Path 'SSTAD:'
Set-Location -Path 'DKSUNDAD:'
Set-Location -Path 'ssidmz01loca:' 


Remove-PSDrive -Name DKSUNDAD -Force
Remove-PSDrive -Name SSTAD -Force
Remove-PSDrive -Name SSIAD -Force
Remove-PSDrive -Name ssidmz01loca -Force
Set-Location C:\RUFR_PowerShell\_UnderUdvikling
#>
