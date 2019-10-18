#PSVersion 5 Script made/assembled by Rust@m 02-05-2018
<#Login RUFR all AD login, Hybrid and o365
$CommandPath = (Get-Location).Path | Split-Path -Parent; $script = "$CommandPath\Logins\Login_SSI_SST_exch2010_DKSUND_Exchange365_RUFR.ps1"; & $script

#Login RUFR only office365
Import-Module MSOnline
$Global:credo365 = Get-Credential adm-rufr@dksund.onmicrosoft.com -Message "login til  Office 365"
$Global:sessiono365 = New-PSSession -ConfigurationName Microsoft.Exchange -Authentication Basic -ConnectionUri https://ps.outlook.com/powershell -AllowRedirection:$true  -Credential $Global:credo365
Import-PSSession $Global:sessiono365 -Prefix o365 -AllowClobber
Connect-MsolService -Credential $Global:credo365
cls
#>

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
#*********************************************************************************************************************************************
#LOGIN
#*********************************************************************************************************************************************
#SST AD login og import af AD modulet.
$UserCredSST = Get-Credential sst.dk\adm-rufr

#exchange 2010
$Exchange2010_SST = "S-EXC-MBX01-P.sst.dk"

$SessionExchangeSST= New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://S-EXC-MBX01-P.sst.dk/PowerShell/ -Authentication Kerberos -Credential $UserCredSST
Import-PSSession $SessionExchangeSST -Prefix SST
#Write-Verbose "Loading the Exchange snapin (module)"
Add-PSSnapin Microsoft.Exchange.Management.PowerShell.E2010 -ErrorAction SilentlyContinu

sleep 4
#*********************************************************************************************************************************************
#Activer Directory Modules import
#*********************************************************************************************************************************************
Import-Module -Name ActiveDirectory 
#Remove-Module -Name ActiveDirectory

#*********************************************************************************************************************************************
#Discover Domain Controllers
#*********************************************************************************************************************************************
Write-Host "Finder SSI, SST og DKSUND Domain Controllere" -foregroundcolor Yellow
#$ServerNameSST = "dc01.sst.dk"
$ServerNameSST = (Get-ADDomainController -DomainName sst.dk -Discover -NextClosestSite).HostName

#*********************************************************************************************************************************************
#PS driver creattion
#*********************************************************************************************************************************************
#PSdrive AD to SST
#PSdrive blev oprettet ved login script, som er ikke en del af den her execution.
Write-Host " Opretter PSdrive til SST AD" -foregroundcolor Cyan
if (-not(Get-PSDrive 'SSTAD' -ErrorAction SilentlyContinue)) {
    New-PSDrive –Name 'SSTAD' –PSProvider ActiveDirectory –Server "$ServerNameSST" -Credential $UserCredSST –Root '//RootDSE/' -Scope Global
    #alternativet creds: –Credential $(Get-Credential -Message 'Enter Password' -UserName 'SST.DK\adm-RUFR') 
     
} Else {
    Write-Output -InputObject "PSDrive SSTAD already exists"
}

cls

Set-Location -Path 'SSTAD:'

New-SSTMailContact -Name “Kitt Pedersen STPS” -Alias "STPSkip"  -ExternalEmailAddress “kip@patientombuddet.dk” -OrganizationalUnit "Patientombuddet" 