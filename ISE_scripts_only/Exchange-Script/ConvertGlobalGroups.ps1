#$ALLADGroups = Get-ADGroup -SearchBase "OU=SWISSCOM-MCC,DC=cembraintra,DC=ch" -Filter * -Properties Mail,MemberOf
$ALLADGroups = Get-ADGroup -SearchBase "OU=DistributionLists,OU=Access,DC=company,DC=com" -Filter *
$ALLADGroups.count
$GlobalGrps = $ALLADGroups | Where-Object {$_.GroupScope -like "Global"}
$GlobalGrps.count
$GlobalGrps | ForEach-Object{
    $ADGrpMember = Get-ADGroupMember $_.distinguishedName -Recursive
    if($_.MemberOf -ne $null){Write-Host ""}
    else{
       Write-Host "Group "$_.SamAccountName" has no MemberOF"
        Start-Sleep -s 2
    }
}

#$ADGroupsDG = Get-ADGroup -SearchBase "OU=DistributionLists,OU=PF00_Cembra-Servers-Access,OU=PF00_Cembra-Servers,OU=PF00_Generic,OU=PF00_Res,OU=PF00,DC=cembraintra,DC=ch" -Filter *
#$ADGroupsDG |ForEach-Object{
#    $ADGrpMember = Get-ADGroupMember $_.distinguishedName -Recursive
#}

#$ADGroupsDG = Get-ADGroup -SearchBase "OU=DistributionLists,OU=PF00_Cembra-Servers-Access,OU=PF00_Cembra-Servers,OU=PF00_Generic,OU=PF00_Res,OU=PF00,DC=cembraintra,DC=ch" -Filter * -Properties Mail
#$UniversalGrps = $ADGroupsDG | Where-Object {$_.GroupScope -like "Universal"}
#$GlobalGrps = $ADGroupsDG | Where-Object {$_.GroupScope -like "Global"}

#$GlobalGrps | ForEach-Object{
#    Write-Host "Processing $_.SamAccountName"
#    $ADPrinc = Get-ADPrincipalGroupMembership -Identity $_.SamAccountName
#    if(!$ADPrinc){
#        Write-Host "Group: $_. has no "
#    }
#}


    #$ADGroupMember = Get-ADGroupMember -Identity $_.DistinguishedName -Recursive







#Set-ADGroup -GroupScope Universal
#$Universal | ForEach-Object{Enable-DistributionGroup -Identity $_.DistinguishedName -PrimarySmtpAddress $_.Mail}
#Set-DistributionGroup CEMBRAITINFRASTRUCTUREDATABASE@cembra.ch -RequireSenderAuthenticationEnabled $false