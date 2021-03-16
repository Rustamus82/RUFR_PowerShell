$CommandPath = (Get-Location).Path | Split-Path -Parent|Split-Path -Parent; $ISEscript = "$CommandPath\Logins\Session_reconnect.ps1"; #& $ISEscript
$CommandPath = (Get-Location).Path | Split-Path -Parent|Split-Path -Parent; $PSscript = "$PSScriptRoot\Logins\Session_reconnect.ps1"; #& $PSscript

if (Test-Path $ISEscript ){
Write-Host '$ISEscript' -ForegroundColor Green; & $ISEscript}
if(Test-Path $PSscript){
Write-Host '$PSscript' -ForegroundColor Green; & $PSscript}
