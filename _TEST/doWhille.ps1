#PSVersion 5 Script made/assembled by Rust@m 10-07-2020
<#Login RUFR all AD login, Hybrid and EXO
$CommandPath = (Get-Location).Path | Split-Path -Parent; $script = "$CommandPath\Logins\Login_SSI_SST_exch2010_DKSUND_Exchange365_RUFR.ps1"; & $script

#Import-Module exhcnage online & Azure AD
Import-Module ExchangeOnlineManagement
Import-Module AzureAD
$Global:UserCredDksund = Get-Credential adm-rufr@dksund.dk -Message "DKSUND AD login, Exchange Online & Hybrid"
Connect-ExchangeOnline -Credential $Global:UserCredDksund -ShowProgress $true -ShowBanner:$false
Connect-AzureAD -Credential $Global:UserCredDksund
Connect-MsolService -Credential $Global:UserCredDksund
cls
#>

Start-Process -FilePath 'C:\Windows\System32\calc.exe'
Start-Sleep -Seconds 5

$stopWatch = New-Object -TypeName System.Diagnostics.Stopwatch
$timeSpan = New-TimeSpan -Minutes 1 -Seconds 30
$stopWatch.Start()

do
{
    Write-Output -InputObject 'Checking if calculator is running...'
    $calcProcess = Get-Process -Name Calculator -ErrorAction SilentlyContinue
    IF([bool](Get-AzureADUser -SearchString "$ADuser"))
    {
        Write-Output -InputObject ('User found in Azure: {0}' -f $ADuser)
    }
    Start-Sleep -Seconds 5
}
until ((-not $calcProcess) -or ($stopWatch.Elapsed -ge $timeSpan))