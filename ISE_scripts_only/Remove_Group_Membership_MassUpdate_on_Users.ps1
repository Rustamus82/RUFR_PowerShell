#PSVersion 5 Script made/assembled by Rust@m 02-05-2018
<#Login RUFR all AD login, Hybrid and o365
$CommandPath = (Get-Location).Path | Split-Path -Parent; $script = "$CommandPath\Logins\Login_SSI_SST_exch2010_DKSUND_Exchange365_RUFR.ps1"; & $script
$CommandPath = (Get-Location).Path | Split-Path -Parent; $script = "$CommandPath\Logins\Login_SSI_SST_exch2010_DKSUND_Exchange365_GHK.ps1"; & $script

#Login RUFR only office365
Import-Module MSOnline
$Global:credo365 = Get-Credential adm-rufr@dksund.onmicrosoft.com -Message "login til  Office 365"
$Global:sessiono365 = New-PSSession -ConfigurationName Microsoft.Exchange -Authentication Basic -ConnectionUri https://ps.outlook.com/powershell -AllowRedirection:$true  -Credential $Global:credo365
Import-PSSession $Global:sessiono365 -Prefix o365 -AllowClobber
Connect-MsolService -Credential $Global:credo365
cls
#>


# Remove_Groups_Membership_MassUpdate
#*******************************************************************************************************************************************************************************


#Get-users from file
$CommandPath = (Get-Location).Path |Split-Path -Parent
[array]$ADusers =  get-content $CommandPath\ISE_scripts_only\CSV\conusererrors.txt 
$ADusers.Count

$ADGroup = "GRP-testservicedesk"


### i SSI AD ###
Write-Host "Skifter til SSI AD" -foregroundcolor Yellow
Set-Location -Path 'SSIAD:'


Foreach ($Users in $ADusers) 
{   
    Remove-ADGroupMember -Identity $ADGroup -Members $Users -Confirm:$false
}


### i DKSUND AD ###
Write-Host "Skifter til DKSUND AD" -foregroundcolor Yellow
Set-Location -Path 'DKSUNDAD:'

Foreach ($Users in $ADusers) 
{   
    Remove-ADGroupMember -Identity $ADGroup -Members $Users -Confirm:$false
}


### i SST AD ###

Write-Host "Skifter til SST AD" -foregroundcolor Yellow
Set-Location -Path 'SSTAD:'

Foreach ($Users in $ADusers) 
{   
    Remove-ADGroupMember -Identity $ADGroup -Members $Users -Confirm:$false
}

#*******************************************************************************************************************************************************************************


