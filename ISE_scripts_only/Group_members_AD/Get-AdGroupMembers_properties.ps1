#navn skal angive navn på gruppe
$collection = Get-ADGroupMember 'Infrastruktur Projekter Sikkerhed og Arkitektur' |Sort-Object name

cls
foreach ($item in $collection)
{
    Get-ADUser $item.SamAccountName -Properties * |ft DisplayName,mail,telephoneNumber,title,department,EmployeeNumber 
    
}


#navn skal angive navn på gruppe
$collection = Get-ADGroupMember 'STPS_g_dks_STPS_KontaktOpsporing_w'-Recursive |Sort-Object name

cls
foreach ($item in $collection)
{
    Get-ADUser $item.SamAccountName -Properties * |select name,samaccountname,mail,company | Export-csv -path ".\Groupmembers_1.csv" -NoTypeInformation -Append -Encoding UTF8
    
}

Get-ADUser rufr -Properties * 

Write-Host "Skifter til SSI AD" -foregroundcolor Yellow
Set-Location -Path 'SSIAD:'

Write-Host "Skifter til DKSUND AD" -foregroundcolor Yellow
Set-Location -Path 'DKSUNDAD:'

Write-Host "Skifter til SST AD" -foregroundcolor Yellow
Set-Location -Path 'SSTAD:'