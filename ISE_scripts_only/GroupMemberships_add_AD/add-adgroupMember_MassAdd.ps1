#PSVersion 5 Script made/assembled by Rust@m 23-03-2021  - $PSVersionTable
$CommandPath = (Get-Location).Path | Split-Path -Parent | Split-Path -Parent; $Login = "$CommandPath\Logins\Login_SSI_SST_exch2010_DKSUND_Exchange365_RUFR.ps1"; & $Login
$ISEScriptPath = (Get-Location).Path | Split-Path -Parent -ErrorAction SilentlyContinue|Split-Path -Parent -ErrorAction SilentlyContinue; $ISEScriptPath = "$ISEScriptPath\Logins\Session_reconnect.ps1"
$PSscriptPath =  $PSScriptRoot | Split-Path -Parent -ErrorAction SilentlyContinue | Split-Path -Parent -ErrorAction SilentlyContinue; $PSscriptPath = "$PSscriptPath\Logins\Session_reconnect.ps1"
$WorkingDir = Convert-Path .

cls
#

Write-Host "Connecting to Sessions" -ForegroundColor Magenta
if (Test-Path $ISEScriptPath){ Invoke-Expression $ISEScriptPath }elseif(test-path $PSscriptPath){Invoke-Expression $PSscriptPath}

<# 
#Get-PSDrive
Set-Location -Path 'SSIAD:' 
Set-Location -Path 'SSTAD:'
Set-Location -Path 'DKSUNDAD:'
#>


$ADusers = Get-Content "$CommandPath\ISE_scripts_only\CSV\Users.txt";$ADusers.Count 

Set-Location -Path 'DKSUNDAD:'

Foreach ($aduser in $ADusers) 
{   
     
     Write-host -Object $("Udfører handling på {0}" -f  $ADuser) -ForegroundColor Cyan
     Add-ADGroupMember -Identity G-ORG-SMSP-ActiveUsers $ADuser
     Add-ADGroupMember -Identity CTX_G_DKS_RDP-Client_SST $ADuser
     Start-Sleep -milliseconds 30
     
}