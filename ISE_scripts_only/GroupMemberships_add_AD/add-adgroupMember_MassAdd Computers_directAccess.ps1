#PSVersion 5 Script made/assembled by Rust@m 17-03-2021
#Login RUFR all AD login, Hybrid and o365
$CommandPath = (Get-Location).Path
$LoginscriptISE = (Get-Location).Path | Split-Path -Parent -ErrorAction SilentlyContinue | Split-Path -Parent -ErrorAction SilentlyContinue; $LoginscriptISE = "$LoginscriptISE\Logins\Login_SSI_SST_exch2010_DKSUND_Exchange365_RUFR.ps1"; if (Test-Path $LoginscriptISE) { Invoke-Expression $LoginscriptISE }
$ISEScriptPath = (Get-Location).Path | Split-Path -Parent -ErrorAction SilentlyContinue | Split-Path -Parent -ErrorAction SilentlyContinue; $ISEScriptPath = "$ISEScriptPath\Logins\Session_reconnect.ps1"
$PSscriptPath = $PSScriptRoot | Split-Path -Parent -ErrorAction SilentlyContinue | Split-Path -Parent -ErrorAction SilentlyContinue; $PSscriptPath = "$PSscriptPath\Logins\Session_reconnect.ps1"

Write-Host "Connecting to Sessions" -ForegroundColor Magenta
if (Test-Path $ISEScriptPath) { Invoke-Expression $ISEScriptPath }elseif (test-path $PSscriptPath) { Invoke-Expression $PSscriptPath }
cls
#

Write-Host "Connecting to Sessions" -ForegroundColor Magenta
if (Test-Path $ISEScriptPath) { Invoke-Expression $ISEScriptPath }elseif (test-path $PSscriptPath) { Invoke-Expression $PSscriptPath }

<#
#Get-PSDrive
Set-Location -Path 'SSIAD:'
Set-Location -Path 'SSTAD:'
Set-Location -Path 'DKSUNDAD:'
Set-Location $CommandPath
#>

Set-Location $CommandPath
#$ADComputers = (Get-Location).Path | Split-Path -Parent | Join-Path  -ChildPath "CSV\Computers.txt"



Set-Location -Path 'DKSUNDAD:'

$Adgroup1 = "dks_U_DirectAccess_Clients"

Get-ADComputer SDS000640 -Properties * |out-file "$CommandPath\OrgComputersProperty.txt"

#$ADComputers = Get-ADComputer -SearchBase 'OU=Organisationer,DC=dksund,DC=dk' -Filter * -Properties SamAccountName |Select-Object SamAccountName| Sort-Object name|out-file "$CommandPath\OrgComputers.txt"
$collection = Get-ADComputer -SearchBase 'OU=Organisationer,DC=dksund,DC=dk' -Filter * -Properties SamAccountName |Select-Object SamAccountName| Sort-Object name
$collection.Count

foreach ($item in $collection)
{
     Write-host -Object $("Udfører handling på {0}" -f $item.SamAccountName) -ForegroundColor Cyan
     Add-ADGroupMember -Identity $Adgroup1 $item.SamAccountName -Verbose -Credential $Global:UserCredDksund
     #Add-ADGroupMember -Identity $Adgroup1 SDS000640$ -Verbose -Credential $Global:UserCredDksund
     Start-Sleep -milliseconds 30
}

Get-ADGroup -Identity $Adgroup1 -Properties Member |Select-Object -Expand Member |out-file "$CommandPath\Computers_$Adgroup1.txt"
