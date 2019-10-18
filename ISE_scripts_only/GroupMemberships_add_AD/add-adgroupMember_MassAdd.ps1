#PSVersion 5 Script made/assembled by Rust@m 25-04-2019
<#Login RUFR all AD login, Hybrid and o365
$CommandPath = (Get-Location).Path | Split-Path -Parent; $script = "$CommandPath\Logins\Login_SSI_SST_exch2010_DKSUND_Exchange365_RUFR.ps1"; & $script

cls
#>

<# 
#Get-PSDrive
Set-Location -Path 'SSIAD:' 
Set-Location -Path 'SSTAD:'
Set-Location -Path 'DKSUNDAD:'
#>

Set-Location -Path 'DKSUNDAD:'
$ADusers = Get-Content .\CSV\Users.txt;$ADusers.Count 

Foreach ($aduser in $ADusers) 
{   
     
     Write-host -Object $("Udfører handling på {0}" -f  $ADuser) -ForegroundColor Cyan
     Add-ADGroupMember -Identity G-ORG-SMSP-ActiveUsers $ADuser
     Add-ADGroupMember -Identity CTX_G_DKS_RDP-Client_SST $ADuser
     Start-Sleep -milliseconds 30
     
}