Import-Module -Name ActiveDirectory 
#Remove-Module -Name ActiveDirectory

#$ServerNameSSI = 'srv-ad-dc04.ssi.ad'
$ServerNameSSI = (Get-ADDomainController -DomainName ssi.ad -Discover -NextClosestSite).HostName
#$ServerNameDKSUND = 'S-AD-DC-01P.dksund.dk'
$ServerNameDKSUND = (Get-ADDomainController -DomainName dksund.dk -Discover -NextClosestSite).HostName
#$ServerNameSSI = "dc01.sst.dk"
$ServerNameSST = (Get-ADDomainController -DomainName sst.dk -Discover -NextClosestSite).HostName


#Get-PSDrive
#Current AD to SSI
if (-not(Get-PSDrive 'SSIAD' -ErrorAction SilentlyContinue)) {
    New-PSDrive –Name 'SSIAD' –PSProvider ActiveDirectory –Server "$ServerNameSSI" -Credential $UserCredSSI –Root '//RootDSE/' -Scope Global
    #alternativet creds: –Credential $(Get-Credential -Message 'Enter Password' -UserName 'SST.DK\adm-RUFR') 
     
} Else {
    Write-Output -InputObject "PSDrive already exists"
}

Set-Location -Path 'SSIAD:' 




Remove-PSDrive -Name SSIAD -Force
Set-Location C:\RUFR_PowerShell\_UnderUdvikling



#Current AD to DKSUND
if (-not(Get-PSDrive 'DKSUNDAD' -ErrorAction SilentlyContinue)) {
    New-PSDrive –Name 'DKSUNDAD' –PSProvider ActiveDirectory –Server "$ServerNameDKSUND" -Credential $UserCredDksund –Root '//RootDSE/' -Scope Global
    #alternativet creds: –Credential $(Get-Credential -Message 'Enter Password' -UserName 'SST.DK\adm-RUFR') 
     
} Else {
    Write-Output -InputObject "PSDrive already exists"
}

Set-Location -Path 'DKSUNDAD:' 




Remove-PSDrive -Name DKSUNDAD -Force
Set-Location C:\RUFR_PowerShell\_UnderUdvikling




#Current AD to SST
if (-not(Get-PSDrive 'SSTAD' -ErrorAction SilentlyContinue)) {
    New-PSDrive –Name 'SSTAD' –PSProvider ActiveDirectory –Server "$ServerNameSST" -Credential $UserCredSST –Root '//RootDSE/' -Scope Global
    #alternativet creds: –Credential $(Get-Credential -Message 'Enter Password' -UserName 'SST.DK\adm-RUFR') 
     
} Else {
    Write-Output -InputObject "PSDrive already exists"
}

Set-Location -Path 'SSTAD:' 

Remove-PSDrive -Name SSTAD -Force
Set-Location C:\RUFR_PowerShell\_UnderUdvikling

