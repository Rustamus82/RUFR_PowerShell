$installdir =  (Get-Location).Path
Import-Module ((Get-ChildItem "$installdir" -Filter "AD.psm1").FullName)

# navn på domain
$domain = "plast-line"
$DC = "DC=$domain,DC=local"

# Angiv sti til brugere
$UsersClientDirty1 = Get-ADUser -SearchBase "OU=SBSUsers,OU=Users,OU=MyBusiness,$DC" -Filter *

# drev hvor mapperne skal oprettes
# husk at fjerne builtinn\users eller andre grupper der skal væk inden du giver specifik adgang. Fjern Inheritance fra rod mappen, ellers har du ikke kontrol over hvem der har adgang.
$PersonalDrivePath = 'F:\personligedrev'

$UsersClientDirty1 = Get-ADUser -SearchBase "OU=SBSUsers,OU=Users,OU=MyBusiness,$DC" -Filter *
$userswinkompas = $UsersClientDirty1 | Where-Object -FilterScript { ($_.name -notlike '*windows*') -and ($_.name -notlike '*sharepoint*') -and ($_.name -notlike '*mail*') -and ($_.name -notlike '*backup user*') -and ($_.name -notlike '*template*') -and ($_.name -notlike '*network a*') -and ($_.name -notlike '*sbsmon*') -and ($_.name -notlike '*standard*') }

$userswinkompas | Select-Object -Property name, SamAccountName

#$userswinkompas = Get-ADUser -Filter * -SearchBase "OU=Winkompas,OU=Users,OU=Administration,DC=$domain,DC=local"
<# dette kan med fordel bruges istedet for i foreach loop. men det må blive en anden dag. :)
$SamAccountName = $user.SamAccountName
$UserStringName = "$env:USERDOMAIN" + "\" + "$SamAccountName"
$userforrights = $user
#>

# mappe oprettelse
# Denne del opretter en mappe med deres samaccountname som navn.
foreach ($userfolder in $userswinkompas) {

    $PersonalDrivePathClean = $PersonalDrivePath.TrimEnd('\\')
    $foldername = $userfolder.SamAccountName
    New-Item -Path $PersonalDrivePathclean -ItemType Directory -Name $foldername
}


# Hent Sikkerhedsgrupperne for vores admins
$SecurityGroupDC = Get-ADGroup -Filter { Name -like "Servers.Domain.Admin.DC" }  -SearchBase "OU=Servers,OU=groups,OU=Administration,DC=$domain,DC=local"
$SecurityGroupNoneDC = Get-ADGroup -Filter { Name -like "Servers.local.Admin*" }  -SearchBase "OU=Servers,OU=groups,OU=Administration,DC=$domain,DC=local"

#$userfolder = $userswinkompas[31]
#husk at fjerne builtinn\users eller andre grupper der skal væk inden du giver specifik adgang.

$NtfsUserRigts = foreach ($userfolder in $userswinkompas) {

    $SamAccountName = $userfolder.SamAccountName
    $PersonalDrivePathClean = $PersonalDrivePath.TrimEnd('\\')
    $UserPersonalDrivePathClean = "$PersonalDrivePathClean" + "\" + "$SamAccountName"
    $SamAccountName = $userfolder.SamAccountName
    $UserStringName = "$env:USERDOMAIN" + "\" + "$SamAccountName"

    Set-NtfsUserRightsOnPath -path $UserPersonalDrivePathClean -user $UserStringName -rights "Read, Write, Modify, DeleteSubdirectoriesAndFiles" -InheritanceF 'ContainerInherit,ObjectInherit' -PropagationF None -allowordeny Allow
    foreach ($group in $SecurityGroupDC.SamAccountName) {
        Set-NtfsUserRightsOnPath -path $UserPersonalDrivePathClean -user "$domain\$group" -rights "full" -InheritanceF 'ContainerInherit,ObjectInherit' -PropagationF None -allowordeny Allow
    }
    foreach ($group in $SecurityGroupNoneDC.SamAccountName) {
        Set-NtfsUserRightsOnPath -path $UserPersonalDrivePathClean -user "$domain\$group" -rights "full" -InheritanceF 'ContainerInherit,ObjectInherit' -PropagationF None -allowordeny Allow
    }
}

Write-Output $NtfsUserRigts
#$userrigtssetto.path

#$userini = $userswinkompas.SamAccountName[2]
$SMBSharerRghts = foreach ($userini in $userswinkompas.SamAccountName) {
    $PersonalDrivePathClean = $PersonalDrivePath.TrimEnd('\\')
    $UserPersonalDrivePathClean = "$PersonalDrivePathClean" + "\" + "$userini"
    #[string]$BuiltinAdministrators = ((Get-UserFromWellKnownSidType -WellKnownSidType BuiltinAdministratorsSid).user) # bruges ikke da "$env:USERDOMAIN\Administrator" er medlem af administrator gruppen

    if (Get-SmbShare -Name "$userini$" -ErrorAction SilentlyContinue) {

        Write-Verbose "share {$userini$} already exist" -Verbose
        Grant-SmbShareAccess -Name "$userini$" -AccountName "$env:USERDOMAIN\$userini" -AccessRight Change  -Force
        Grant-SmbShareAccess -Name "$userini$" -AccountName "$env:USERDOMAIN\Administrator" -AccessRight Full -Force
        foreach ($group in $SecurityGroupDC.SamAccountName) {
            Grant-SmbShareAccess -Name "$userini$" -AccountName "$env:USERDOMAIN\$group" -AccessRight Full -Force
        }
        foreach ($group in $SecurityGroupNoneDC.SamAccountName) {
            Grant-SmbShareAccess -Name "$userini$" -AccountName "$env:USERDOMAIN\$group" -AccessRight Full -Force
        }
        Revoke-SmbShareAccess -Name "$userini$" -AccountName "Everyone" -Force

    }
    else {

        new-SmbShare -Name "$userini$" -Path $UserPersonalDrivePathClean #-Confirm $false #-ChangeAccess "$env:USERDOMAIN\$userini" -FullAccess "$env:USERDOMAIN\Administrator"
        # use "grant access to shares"  instead of below if you need to change after first run.
        Grant-SmbShareAccess -Name "$userini$" -AccountName "$env:USERDOMAIN\$userini" -AccessRight Change  -Force #-Confirm $false
        Grant-SmbShareAccess -Name "$userini$" -AccountName "$env:USERDOMAIN\Administrator" -AccessRight Full -Force #-Confirm $false
        foreach ($group in $SecurityGroupDC.SamAccountName) {
            Grant-SmbShareAccess -Name "$userini$" -AccountName "$env:USERDOMAIN\$group" -AccessRight Full -Force
        }
        foreach ($group in $SecurityGroupNoneDC.SamAccountName) {
            Grant-SmbShareAccess -Name "$userini$" -AccountName "$env:USERDOMAIN\$group" -AccessRight Full -Force
        }
        Revoke-SmbShareAccess -Name "$userini$" -AccountName "Everyone"  -Force #-Confirm $false
    }
}

Write-Output $SMBSharerRghts

<# blev brugt til test
$shares = (Get-ChildItem F:\personligedrev -Directory).Name

$SecurityGroupDC = Get-ADGroup -Filter {Name -like "Servers.Domain.Admin.DC"}  -SearchBase "OU=Servers,OU=groups,OU=Administration,DC=$domain,DC=local"
$SecurityGroupNoneDC = Get-ADGroup -Filter {Name -like "Servers.local.Admin*"}  -SearchBase "OU=Servers,OU=groups,OU=Administration,DC=$domain,DC=local"

# this part is for new users. admins  is included in above run.
$user = $usersDA[1]
# grant access to shares
foreach ($user in $SecurityGroupDC.SamAccountName) {
    foreach ($name in $shares) {

        Grant-SmbShareAccess -Name "$name$" -AccountName "$domain\$user" -AccessRight full -Force
        #Revoke-SmbShareAccess -Name "$name$" -AccountName "$domain\$user" -Force
    }
}

# grant access to shares
foreach ($user in $SecurityGroupNoneDC.SamAccountName) {
    foreach ($name in $shares) {

        Grant-SmbShareAccess -Name "$name$" -AccountName "$domain\$user" -AccessRight full -Force
        #Revoke-SmbShareAccess -Name "$name$" -AccountName "$domain\$user" -Force

    }
}

#>
<# blev brugt til test
$userini = $usersforshare[78].UserPrincipalName.TrimEnd('@isoplus.dk')

$usersforshare.UserPrincipalName.replace('@isoplus.dk', '')

$usersforshare[78] | gm

$usersforshare[78] | Select-Object -Property SamAccountName

$userini

$usersforshare[4]

$userini.count

$usersforshare.count

((Get-UserFromWellKnownSidType -WellKnownSidType 'BuiltinUsersSid').user)
((Get-UserFromWellKnownSidType -WellKnownSidType BuiltinAdministratorsSid).user)
#>
