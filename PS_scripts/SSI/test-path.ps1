$ISEScriptPath = (Get-Location).Path | Split-Path -Parent -ErrorAction SilentlyContinue|Split-Path -Parent -ErrorAction SilentlyContinue; $ISEScriptPath = "$ISEScriptPath\Logins\Session_reconnect.ps1"
$PSscriptPath =  $PSScriptRoot | Split-Path -Parent -ErrorAction SilentlyContinue | Split-Path -Parent -ErrorAction SilentlyContinue; $PSscriptPath = "$PSscriptPath\Logins\Session_reconnect.ps1"

Write-Host "Connecting to Sessions" -ForegroundColor Magenta
if (Test-Path $ISEScriptPath){ Invoke-Expression $ISEScriptPath }elseif(test-path $PSscriptPath){Invoke-Expression $PSscriptPath}
