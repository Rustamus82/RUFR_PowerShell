Write-Host "Connecting to Sessions" -ForegroundColor Magenta
$reconnect =  $PSScriptRoot | Split-Path -Parent | Split-Path -Parent; Invoke-Expression "$reconnect\Logins\Session_reconnect.ps1"

[enum]::GetValues([System.ConsoleColor]) | Foreach-Object {Write-Host $_ -ForegroundColor $_ }


