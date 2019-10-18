Write-Host "Du har valgt Get-ADUserMembership.ps1" -ForegroundColor Gray -BackgroundColor DarkCyan
#PSVersion 5 Script made/assembled by Rust@m 08-05-2018
<#Login RUFR all AD login, Hybrid and o365
$CommandPath = (Get-Location).Path | Split-Path -Parent; $script = "$CommandPath\Logins\Login_SSI_SST_exch2010_DKSUND_Exchange365_RUFR.ps1"; & $script

#Login RUFR only office365
Import-Module MSOnline
$Global:credo365 = Get-Credential adm-rufr@dksund.onmicrosoft.com -Message "login til  Office 365"
$Global:sessiono365 = New-PSSession -ConfigurationName Microsoft.Exchange -Authentication Basic -ConnectionUri https://ps.outlook.com/powershell -AllowRedirection:$true  -Credential $Global:credo365
Import-PSSession $Global:sessiono365 -Prefix o365 -AllowClobber
Connect-MsolService -Credential $Global:credo365
cls
#>

$ADuser =  Read-Host -Prompt "Angiv Bruger initialer:";cls
$AD = Read-Host -Prompt "vælg AD, skriv 'SSI', 'SST' eller 'DKSUND' ";cls

Write-Host "Søger for AD user og viser medlemskabet" -foregroundcolor Cyan
if ($AD -eq "ssi"){
    #PSdrive blev oprettet ved login script, som er ikke en del af den her execution.
    Write-Host "i SSI AD" -foregroundcolor Yellow
    Set-Location -Path 'SSIAD:'
    
    Write-Host "AD user `"$ADuser"" have flowing membership:" -foregroundcolor Cyan
    $ADSeaerch = Get-ADUser $ADuser -Properties Canonicalname | select CanonicalName
    Write-Host "Bruger findes i AD:" -foregroundcolor Green
    Write-Host  $ADSeaerch.CanonicalName -foregroundcolor Green
    Get-ADPrincipalGroupMembership $ADuser | Format-Table name
    
}
Elseif ($AD -eq "sst") {
    #PSdrive blev oprettet ved login script, som er ikke en del af den her execution.
    Write-Host "i SST AD" -foregroundcolor Yellow
    Set-Location -Path 'SSTAD:'
    Write-Host "AD user `"$ADuser"" have flowing membership:" -foregroundcolor Cyan
    $ADSeaerch = Get-ADUser $ADuser -Properties Canonicalname | select CanonicalName
    Write-Host "Bruger findes i AD:" -foregroundcolor Green
    Write-Host  $ADSeaerch.CanonicalName -foregroundcolor Green
    Get-ADPrincipalGroupMembership $ADuser | Format-Table name       
        
    }
Elseif ($AD -eq "DKSUND") {
    #PSdrive blev oprettet ved login script, som er ikke en del af den her execution.
    Write-Host "i DKSUND AD" -foregroundcolor Yellow
    Set-Location -Path 'DKSUNDAD:' 

    Write-Host "AD user `"$ADuser"" have flowing membership:" -foregroundcolor Cyan
    $ADSeaerch = Get-ADUser $ADuser -Properties Canonicalname | select CanonicalName
    Write-Host "Bruger findes i AD:" -foregroundcolor Green
    Write-Host  $ADSeaerch.CanonicalName -foregroundcolor Green
    Get-ADPrincipalGroupMembership $ADuser | Format-Table name

    }
Else 
{ Write-Warning "Bruger findes ikke i ADer"}

pause
cls