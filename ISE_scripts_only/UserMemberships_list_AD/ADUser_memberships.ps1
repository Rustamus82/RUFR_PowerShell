

Write-Host "Skifter til SSI AD" -foregroundcolor Yellow
Set-Location -Path 'SSIAD:'

Write-Host "Skifter til DKSUND AD" -foregroundcolor Yellow
Set-Location -Path 'DKSUNDAD:'

Write-Host "Skifter til SST AD" -foregroundcolor Yellow
Set-Location -Path 'SSTAD:'


cls
(Get-ADUser –Identity adm_AFKH –Properties MemberOf | Select-Object MemberOf).MemberOf |ogv


(Get-ADUser –Identity adx_lubl –Properties MemberOf | Select-Object MemberOf).MemberOf |ogv





