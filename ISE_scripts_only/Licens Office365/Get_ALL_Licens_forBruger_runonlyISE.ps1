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
Write-Host "Get_ALL_Licens_forBruger_runonlyISE.ps1" -ForegroundColor Gray -BackgroundColor DarkCyan
$WorkingDir = Convert-Path .
#Get all licensed users 
Get-MSOLUser -All | Where-Object { $_.isLicensed -eq $true } | Select-Object UserPrincipalName, DisplayName, Department, {$_.Licenses.AccountSkuId}, isLicensed, WhenCreated |  Export-CSV "$WorkingDir\LicensedUsers.csv" -NoTypeInformation -Encoding UTF8

Get-MSOLUser -All | Where-Object { $_.isLicensed -eq $true } | Select-Object UserPrincipalName, DisplayName, Department, {$_.Licenses.AccountSkuId}, isLicensed, WhenCreated | ogv
get-MSOLUser -All | where {$_.isLicensed -eq "TRUE" -and $_.Licenses.AccountSKUID } | select UserPrincipalName, DisplayName, Department, {$_.Licenses.AccountSkuId}, Licensesd, isLicense | ogv

#statistics
Get-MsolAccountSku 


#Get all licensed users 
Get-MsolUser -all | select DisplayName, Licenses | Where-Object {$_.Licenses.AccountSkuID -eq "DKSUND:ENTERPRISEPACK" } | ogv

#test change licens on one account
$WorkingDir = Convert-Path .
$user = 'rufr'
"Updating E5 license for {0} $('[{0:yyyy/mm/dd} {0:HH:mm:ss}]' -f (Get-Date))" -f  $user | Out-File "$WorkingDir\E5_license_log.txt" -Append -Verbose
Set-MsolUserLicense -UserPrincipalName "$user@dksund.dk" -AddLicenses dksund:WIN_DEF_ATP, dksund:ENTERPRISEPREMIUM, dksund:EMSPREMIUM -RemoveLicenses dksund:ENTERPRISEPACK
Get-MsolUser -UserPrincipalName "$user@dksund.dk" | Set-MsolUserLicense -LicenseOptions $StandardLicenseOptions


#************************************************************************************************************************************************************************************************************************************************************************
#change, add or modify specific licnes for all E5 licensed user:
$users= Get-MsolUser -all | Where-Object {$_.Licenses.AccountSkuID -eq "DKSUND:ENTERPRISEPACK" } 
($users).UserPrincipalName
($users).Count

#licnes and Licensoption for all licensed user E5:
$StandardLicenseOptions = New-MsolLicenseOptions -AccountSkuId "dksund:ENTERPRISEPREMIUM" -DisabledPlans "PROJECTWORKMANAGEMENT","YAMMER_ENTERPRISE","MCOSTANDARD","SHAREPOINTWAC", "SWAY", "RMS_S_ENTERPRISE"
$WorkingDir = Convert-Path .
Get-MsolUser -all | Where-Object {$_.Licenses.AccountSkuID -eq "DKSUND:ENTERPRISEPACK" }  | ForEach-Object { 

"Updating E5 license for {0} $('[{0:yyyy/mm/dd} {0:HH:mm:ss}]' -f (Get-Date))" -f  ($_).UserPrincipalName  | Out-File "$WorkingDir\E5_license_log.txt" -Append -Verbose
Set-MsolUserLicense -UserPrincipalName ($_).UserPrincipalName -AddLicenses dksund:WIN_DEF_ATP, dksund:ENTERPRISEPREMIUM, dksund:EMSPREMIUM -RemoveLicenses dksund:ENTERPRISEPACK 
sleep 15
Get-MsolUser -UserPrincipalName ($_).UserPrincipalName | Set-MsolUserLicense -LicenseOptions $StandardLicenseOptions

}


#************************************************************************************************************************************************************************************************************************************************************************
## Get all Project Online User wihtout client:
$users= Get-MsolUser -all | Where-Object {$_.Licenses.AccountSkuID -eq "dksund:PROJECTONLINE_PLAN_1" } 
($users).UserPrincipalName
($users).Count

$users= Get-MsolUser -all | Where-Object {$_.Licenses.AccountSkuID -eq "dksund:PROJECTCLIENT" } 
($users).UserPrincipalName
($users).Count

$users= Get-MsolUser -all | Where-Object {$_.Licenses.AccountSkuID -eq "dksund:PROJECTPREMIUM" } 
($users).UserPrincipalName
($users).Count


## Projeckt licenser - change, add or modify specific licnes for all E5 licensed user:
$WorkingDir = Convert-Path .
Get-MsolUser -all | Where-Object {$_.Licenses.AccountSkuID -eq "dksund:PROJECTONLINE_PLAN_1" }  | ForEach-Object { 

"Updating dksund:PROJECTPREMIUM E5 license for {0} $('[{0:yyyy/mm/dd} {0:HH:mm:ss}]' -f (Get-Date))" -f  ($_).UserPrincipalName  | Out-File "$WorkingDir\E5_license_log.txt" -Append -Verbose
Set-MsolUserLicense -UserPrincipalName ($_).UserPrincipalName -AddLicenses dksund:PROJECTPREMIUM -RemoveLicenses dksund:PROJECTONLINE_PLAN_1

}

#test change licens on one account
$WorkingDir = Convert-Path .
$user = 'STLR'
"Updating dksund:PROJECTPREMIUM E5 license for {0} $('[{0:yyyy/mm/dd} {0:HH:mm:ss}]' -f (Get-Date))" -f  $user | Out-File "$WorkingDir\E5_license_log.txt" -Append -Verbose
Set-MsolUserLicense -UserPrincipalName "$user@dksund.dk" -AddLicenses dksund:PROJECTPREMIUM -RemoveLicenses dksund:PROJECTONLINE_PLAN_1

#Set-MsolUserLicense -UserPrincipalName "xpj@dksund.onmicrosoft.com" -RemoveLicenses dksund:PROJECTONLINE_PLAN_1
#Set-MsolUserLicense -UserPrincipalName "xpj@dksund.onmicrosoft.com" -AddLicenses dksund:PROJECTPREMIUM




#Get-MsolUser -all | Where-Object {$_.Licenses.AccountSkuID -eq "dksund:ENTERPRISEPREMIUM" }  | ForEach-Object { ($_).UserPrincipalName; Set-MsolUserLicense -UserPrincipalName ($_).UserPrincipalName -RemoveLicenses dksund:ENTERPRISEPACK}
Get-MsolUser -UserPrincipalName rufr@dksund.dk | Format-List DisplayName,Licenses

#************************************************************************************************************************************************************************************************************************************************************************

#change licnes option for all licensed user E3:
$StandardLicenseOptions = New-MsolLicenseOptions -AccountSkuId "DKSUND:ENTERPRISEPACK" -DisabledPlans "PROJECTWORKMANAGEMENT","YAMMER_ENTERPRISE","MCOSTANDARD","SHAREPOINTWAC", "SWAY", "RMS_S_ENTERPRISE"
Get-MsolUser -all | Where-Object {$_.Licenses.AccountSkuID -eq "DKSUND:ENTERPRISEPACK" } | Set-MsolUserLicense -LicenseOptions $StandardLicenseOptions


#change licnes option for all licensed user E5:
$StandardLicenseOptions = New-MsolLicenseOptions -AccountSkuId "dksund:ENTERPRISEPREMIUM" -DisabledPlans "PROJECTWORKMANAGEMENT","YAMMER_ENTERPRISE","MCOSTANDARD","SHAREPOINTWAC", "SWAY", "RMS_S_ENTERPRISE"
Get-MsolUser -all | Where-Object {$_.Licenses.AccountSkuID -eq "dksund:ENTERPRISEPREMIUM" } | Set-MsolUserLicense -LicenseOptions $StandardLicenseOptions

#************************************************************************************************************************************************************************************************************************************************************************
# get Licens Value for: $AccountSkuId
$user = 'suno'
(Get-MsolUser -UserPrincipalName $user@dksund.dk  )| select *
(Get-MsolUser -UserPrincipalName $user@dksund.dk  ).Licenses[0,1,2].AccountSkuId 
(Get-MsolUser -UserPrincipalName $user@dksund.dk ).UsageLocation 


#Licens is a collection, thus we can expand it, by saving i first in object.
$licens = (Get-MsolUser -UserPrincipalName suno@dksund.dk  ).Licenses
cls
foreach ($item in $licens)
{
    Write-Host $item.AccountSku.AccountName
    Write-Host $item.AccountSku.SkuPartNumber
    Write-Host $item.AccountSkuId
    
}



