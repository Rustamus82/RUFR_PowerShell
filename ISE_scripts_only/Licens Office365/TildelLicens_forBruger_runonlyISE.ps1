<#Script made/assembled by Rust@m 14-05-2019
##Login RUFR all AD login, Hybrid and o365
$CommandPath = (Get-Location).Path | Split-Path -Parent|Split-Path -Parent; $script = "$CommandPath\Logins\Login_SSI_SST_exch2010_DKSUND_Exchange365_RUFR.ps1"; & $script

#Requires -Version 5 - $PSVersionTable

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
#Script
#*********************************************************************************************************************************************
#variabler

$User = Read-Host "Tildel o365 Licens Bruger, ved at taste postkasse/initialer"
$licensType = Read-Host "Tildel o365 Licens tast '1' for E3 lcines eller '2' for E5 licnes"

if($licensType -eq '1') {

            Write-Host "Tildeler E3 licens for $User" -foregroundcolor Magenta
            #dksund:ENTERPRISEPACK
              
            if (-not ($User -eq "*")) {
		            $x = New-MsolLicenseOptions -AccountSkuId "dksund:ENTERPRISEPACK" -DisabledPlans "PROJECTWORKMANAGEMENT","YAMMER_ENTERPRISE","MCOSTANDARD","SHAREPOINTWAC", "SWAY", "RMS_S_ENTERPRISE"
 		            Set-MsolUser -UserPrincipalName $User@dksund.dk -UsageLocation DK
		            Set-MsolUserLicense -UserPrincipalName $User@dksund.dk -AddLicenses dksund:ENTERPRISEPACK -RemoveLicenses dksund:WIN_DEF_ATP, dksund:ENTERPRISEPREMIUM, dksund:EMSPREMIUM
		            Set-MsolUserLicense -UserPrincipalName $User@dksund.dk -LicenseOptions $x
            }Else { Write-Warning "du har tastet * i username, tjek om det er korrekt fællespostkasse/bruger" }

} elseif ($licensType -eq '2'){
            
            Write-Host "Tildeler E5 licens for $User" -foregroundcolor Magenta
            #dksund:WIN_DEF_ATP dksund:ENTERPRISEPREMIUM dksund:EMSPREMIUM
             
            if (-not ($User -eq "*")) {
                    $x = New-MsolLicenseOptions -AccountSkuId "dksund:ENTERPRISEPREMIUM" -DisabledPlans "PROJECTWORKMANAGEMENT","YAMMER_ENTERPRISE","MCOSTANDARD","SHAREPOINTWAC", "SWAY", "RMS_S_ENTERPRISE"
                    Set-MsolUser -UserPrincipalName $User@dksund.dk -UsageLocation DK
                    Set-MsolUserLicense -UserPrincipalName $User@dksund.dk -AddLicenses dksund:WIN_DEF_ATP, dksund:ENTERPRISEPREMIUM, dksund:EMSPREMIUM -RemoveLicenses dksund:ENTERPRISEPACK
                    Set-MsolUserLicense -UserPrincipalName $User@dksund.dk -LicenseOptions $x
                    
            }Else { Write-Warning "du har tastet * i username, tjek om det er korrekt fællespostkasse/bruger" }

}

#get licens types
#Get-MsolAccountSku 
cls
#Get all licensed users 
#Get-MSOLUser -All | Where-Object { $_.isLicensed -eq $true } | Select-Object UserPrincipalName, DisplayName, Department, {$_.Licenses.AccountSkuId}, WhenCreated |  Export-CSV C:\PowerShell\Logs\LicensedUsers.csv -NoTypeInformation -Encoding UTF8
#Write-Log -Message '------ Script execution started ------' -Level Info -Path C:\PowerShell\Logs\funktionspostkasseoprettelse_Log.txt
