#PSVersion 5 Script made/assembled by Rust@m 23-03-2021  - $PSVersionTable
$CommandPath = (Get-Location).Path | Split-Path -Parent | Split-Path -Parent; $Login = "$CommandPath\Logins\Login_SSI_SST_exch2010_DKSUND_Exchange365_RUFR.ps1"; & $Login
$ISEScriptPath = (Get-Location).Path | Split-Path -Parent -ErrorAction SilentlyContinue|Split-Path -Parent -ErrorAction SilentlyContinue; $ISEScriptPath = "$ISEScriptPath\Logins\Session_reconnect.ps1"
$PSscriptPath =  $PSScriptRoot | Split-Path -Parent -ErrorAction SilentlyContinue | Split-Path -Parent -ErrorAction SilentlyContinue; $PSscriptPath = "$PSscriptPath\Logins\Session_reconnect.ps1"
$WorkingDir = Convert-Path .

cls
#

Write-Host "Connecting to Sessions" -ForegroundColor Magenta
if (Test-Path $ISEScriptPath){ Invoke-Expression $ISEScriptPath }elseif(test-path $PSscriptPath){Invoke-Expression $PSscriptPath}

 $ADuser = "adm-rufr@dksund.dk"


#Open a Powershell session and connect to Office 365
#At a PowerShell Prompt connect to Office 365 with the command:
#Authenticate with Office 365
#Sign in to Office 365 when prompted with a Global Administrator account.
Connect-MsolService
#List Global Admins with the Get-MsolRoleMember cmdlet
#Use the following command to list all global admins:

$role = Get-MsolRole -RoleName "Company Administrator"
Get-MsolRoleMember -RoleObjectId $role.ObjectId

Get-MsolRoleMember -RoleObjectId $(Get-MsolRole -RoleName "Company Administrator").ObjectId
Get-MsolRoleMember -RoleObjectId $(Get-MsolRole -RoleName "Company Administrator").ObjectId | Select-Object -Property DisplayName,EmailAddress | Export-Csv -NoTypeInformation -Path "$WorkingDir\GlobalAdmins.txt"

