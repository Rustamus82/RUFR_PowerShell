#PSVersion 5 Script made/assembled by Rust@m 17-04-2019
<#Login RUFR all AD login, Hybrid and o365
$CommandPath = (Get-Location).Path | Split-Path -Parent; $script = "$CommandPath\Logins\Login_SSI_SST_exch2010_DKSUND_Exchange365_RUFR.ps1"; & $script;$WorkingDir = Convert-Path .
cls
#>

$WorkingDir = Convert-Path .
#Requirmensts RSAT installed and psdrive created for SSI, SST and DKSUND AD
#Get-PSDrive
#******************************************************************************************************************************************************************************************************
Set-Location -Path 'SSIAD:'

#All users  - To display the expiration date rather than the password last set date, use this command.
Get-ADUser -filter {Enabled -eq $True -and PasswordNeverExpires -eq $False} –Properties "DisplayName", "msDS-UserPasswordExpiryTimeComputed" |
Select-Object -Property "Displayname","UserPrincipalName",@{Name="ExpiryDate";Expression={[datetime]::FromFileTime($_."msDS-UserPasswordExpiryTimeComputed")}} | Export-CSV "$WorkingDir\UsersPWDExparationDates_SSI.csv" -NoTypeInformation -Encoding UTF8

# Specific user display exparation date:
get-aduser adm-rufr –Properties "DisplayName", "msDS-UserPasswordExpiryTimeComputed" | Select-Object -Property "Displayname","UserPrincipalName",@{Name="ExpiryDate";Expression={[datetime]::FromFileTime($_."msDS-UserPasswordExpiryTimeComputed")}}


#To find the date the password was last set, run this command.
get-aduser adm-rufr -properties passwordlastset, passwordneverexpires |ft Name, passwordlastset, Passwordneverexpires

<# All users - find the date the password was last set, run this command.
get-aduser -filter * -properties passwordlastset, passwordneverexpires |ft Name, passwordlastset, Passwordneverexpires
#>

#******************************************************************************************************************************************************************************************************
Set-Location -Path 'SSTAD:'

#All users  - To display the expiration date rather than the password last set date, use this command.
Get-ADUser -filter {Enabled -eq $True -and PasswordNeverExpires -eq $False} –Properties "DisplayName", "msDS-UserPasswordExpiryTimeComputed" |
Select-Object -Property "Displayname","UserPrincipalName",@{Name="ExpiryDate";Expression={[datetime]::FromFileTime($_."msDS-UserPasswordExpiryTimeComputed")}} |  Export-CSV "$WorkingDir\UsersPWDExparationDates_SSI.csv" -NoTypeInformation -Encoding UTF8

# Specific user display exparation date:
get-aduser adm-rufr –Properties "DisplayName", "msDS-UserPasswordExpiryTimeComputed" | Select-Object -Property "Displayname","UserPrincipalName",@{Name="ExpiryDate";Expression={[datetime]::FromFileTime($_."msDS-UserPasswordExpiryTimeComputed")}}

#To find the date the password was last set, run this command.
get-aduser adm-rufr -properties passwordlastset, passwordneverexpires |ft Name, passwordlastset, Passwordneverexpires

<# All users - find the date the password was last set, run this command.
get-aduser -filter * -properties passwordlastset, passwordneverexpires |ft Name, passwordlastset, Passwordneverexpires
#>

#******************************************************************************************************************************************************************************************************
Set-Location -Path 'DKSUNDAD:' 

#All users  - To display the expiration date rather than the password last set date, use this command.
Get-ADUser -filter {Enabled -eq $True -and PasswordNeverExpires -eq $False} –Properties "DisplayName", "msDS-UserPasswordExpiryTimeComputed" |
Select-Object -Property "Displayname","UserPrincipalName",@{Name="ExpiryDate";Expression={[datetime]::FromFileTime($_."msDS-UserPasswordExpiryTimeComputed")}} |  Export-CSV "$WorkingDir\UsersPWDExparationDates_SSI.csv" -NoTypeInformation -Encoding UTF8

# Specific user display exparation date:
get-aduser adm-rufr –Properties "DisplayName", "msDS-UserPasswordExpiryTimeComputed" | Select-Object -Property "Displayname","UserPrincipalName",@{Name="ExpiryDate";Expression={[datetime]::FromFileTime($_."msDS-UserPasswordExpiryTimeComputed")}}

#To find the date the password was last set, run this command.
get-aduser adm-rufr -properties passwordlastset, passwordneverexpires |ft Name, passwordlastset, Passwordneverexpires

<# All users - find the date the password was last set, run this command.
get-aduser -filter * -properties passwordlastset, passwordneverexpires |ft Name, passwordlastset, Passwordneverexpires
#>

