#PSVersion 5 Script made/assembled by Rust@m 23-03-2021  - $PSVersionTable
$CommandPath = (Get-Location).Path | Split-Path -Parent | Split-Path -Parent; $Login = "$CommandPath\Logins\Login_SSI_SST_exch2010_DKSUND_Exchange365_RUFR.ps1"; & $Login
$ISEScriptPath = (Get-Location).Path | Split-Path -Parent -ErrorAction SilentlyContinue|Split-Path -Parent -ErrorAction SilentlyContinue; $ISEScriptPathReconnect = "$ISEScriptPath\Logins\Session_reconnect.ps1"
$PSscriptPath =  $PSScriptRoot | Split-Path -Parent -ErrorAction SilentlyContinue | Split-Path -Parent -ErrorAction SilentlyContinue; $PSscriptPathReconnect = "$PSscriptPath\Logins\Session_reconnect.ps1"
$WorkingDir = Convert-Path .

cls
#

Write-Host "Connecting to Sessions" -ForegroundColor Magenta
if (Test-Path $ISEScriptPathReconnect){ Invoke-Expression $ISEScriptPathReconnect }elseif(test-path $PSscriptPathReconnect){Invoke-Expression $PSscriptPathReconnect}