Write-Host "Connecting to Sessions" -ForegroundColor Magenta
$reconnect =  $PSScriptRoot | Split-Path -Parent | Split-Path -Parent; Invoke-Expression "$reconnect\Logins\Session_reconnect.ps1"
[enum]::GetValues([System.ConsoleColor]) | Foreach-Object {Write-Host $_ -ForegroundColor $_ }
Import-Module ExchangeOnlineManagement
Import-Module AzureAD
Import-Module -Name ActiveDirectory 
Import-Module lync -ErrorAction SilentlyContinue
cls

<# 
#Get-PSDrive
Set-Location -Path 'SSIAD:' 
Set-Location -Path 'SSTAD:'
Set-Location -Path 'DKSUNDAD:' 

Write-Host "Skifter til SSI AD" -foregroundcolor Yellow
Set-Location -Path 'SSIAD:'

Write-Host "Skifter til DKSUND AD" -foregroundcolor Yellow
Set-Location -Path 'DKSUNDAD:'

Write-Host "Skifter til SST AD" -foregroundcolor Yellow
Set-Location -Path 'SSTAD:'


Remove-PSDrive -Name DKSUNDAD -Force
Remove-PSDrive -Name SSTAD -Force
Remove-PSDrive -Name SSIAD -Force
Set-Location $initialDirectory
#>



do
{
      
      $input = Read-Host -Prompt "write a command"
      #%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe
      powershell.exe -command $input
      #Invoke-Expression $input
      

 }
 until ($input -eq 'q')
#Remove-PSDrive -Name DKSUNDAD -Force
#Remove-PSDrive -Name SSIAD -Force
#Remove-PSDrive -Name SSTAD -Force