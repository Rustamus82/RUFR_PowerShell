<<<<<<< HEAD
﻿#PSVersion 5 Script made/assembled by Rust@m 17-03-2021
#Login RUFR all AD login, Hybrid and o365
$CommandPath = (Get-Location).Path 
$LoginscriptISE = (Get-Location).Path | Split-Path -Parent -ErrorAction SilentlyContinue|Split-Path -Parent -ErrorAction SilentlyContinue; $LoginscriptISE = "$LoginscriptISE\Logins\Login_SSI_SST_exch2010_DKSUND_Exchange365_RUFR.ps1"; if(Test-Path $LoginscriptISE){ Invoke-Expression $LoginscriptISE}
$ISEScriptPath = (Get-Location).Path | Split-Path -Parent -ErrorAction SilentlyContinue|Split-Path -Parent -ErrorAction SilentlyContinue; $ISEScriptPath = "$ISEScriptPath\Logins\Session_reconnect.ps1"
$PSscriptPath =  $PSScriptRoot | Split-Path -Parent -ErrorAction SilentlyContinue | Split-Path -Parent -ErrorAction SilentlyContinue; $PSscriptPath = "$PSscriptPath\Logins\Session_reconnect.ps1"
=======
﻿#PSVersion 5 Script made/assembled by Rust@m 23-03-2021  - $PSVersionTable
$CommandPath = (Get-Location).Path | Split-Path -Parent | Split-Path -Parent; $Login = "$CommandPath\Logins\Login_SSI_SST_exch2010_DKSUND_Exchange365_RUFR.ps1"; & $Login
$ISEScriptPath = (Get-Location).Path | Split-Path -Parent -ErrorAction SilentlyContinue|Split-Path -Parent -ErrorAction SilentlyContinue; $ISEScriptPath = "$ISEScriptPath\Logins\Session_reconnect.ps1"
$PSscriptPath =  $PSScriptRoot | Split-Path -Parent -ErrorAction SilentlyContinue | Split-Path -Parent -ErrorAction SilentlyContinue; $PSscriptPath = "$PSscriptPath\Logins\Session_reconnect.ps1"
$WorkingDir = Convert-Path .
>>>>>>> dc326f16ef88b77a20c1debf8292593e579e7d5a

Write-Host "Connecting to Sessions" -ForegroundColor Magenta
if (Test-Path $ISEScriptPath){ Invoke-Expression $ISEScriptPath }elseif(test-path $PSscriptPath){Invoke-Expression $PSscriptPath}
cls
#

Write-Host "Connecting to Sessions" -ForegroundColor Magenta
if (Test-Path $ISEScriptPath){ Invoke-Expression $ISEScriptPath }elseif(test-path $PSscriptPath){Invoke-Expression $PSscriptPath}

<# 
#Get-PSDrive
Set-Location -Path 'SSIAD:' 
Set-Location -Path 'SSTAD:'
Set-Location -Path 'DKSUNDAD:'
Set-Location $CommandPath
#>

<<<<<<< HEAD
Set-Location $CommandPath
$ADusers = (Get-Location).Path | Split-Path -Parent | Join-Path  -ChildPath "CSV\Users.txt"
$ADusers = Get-Content $ADusers ;$ADusers.Count 
$Adgroup1 = "TeamViewer_g_Users"
$AdgroupMembers1 = Get-ADGroupMember -Identity $Adgroup1; $AdgroupMembers1.Count

=======

$ADusers = Get-Content "$CommandPath\ISE_scripts_only\CSV\Users.txt";$ADusers.Count 
>>>>>>> dc326f16ef88b77a20c1debf8292593e579e7d5a

Set-Location -Path 'DKSUNDAD:'

Foreach ($aduser in $ADusers) 
{   
     
     Write-host -Object $("Udfører handling på {0}" -f  $ADuser) -ForegroundColor Cyan
     Add-ADGroupMember -Identity $Adgroup1 $ADuser -Verbose
     Start-Sleep -milliseconds 30
     
}