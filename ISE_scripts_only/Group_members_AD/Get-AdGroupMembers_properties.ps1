#navn skal angive navn på gruppe
$collection = Get-ADGroupMember 'Infrastruktur Projekter Sikkerhed og Arkitektur' |Sort-Object name

cls
foreach ($item in $collection)
{
    Get-ADUser $item.SamAccountName -Properties * |ft DisplayName,mail,telephoneNumber,title,department,EmployeeNumber 
    
}

Get-ADUser rufr -Properties * 

Write-Host "Skifter til SSI AD" -foregroundcolor Yellow
Set-Location -Path 'SSIAD:'

Write-Host "Skifter til DKSUND AD" -foregroundcolor Yellow
Set-Location -Path 'DKSUNDAD:'

Write-Host "Skifter til SST AD" -foregroundcolor Yellow
Set-Location -Path 'SSTAD:'