#Manager can update membership list - PowerShell - Active Directory FAQ - https://activedirectoryfaq.com/2021/03/manager-can-update-membership-list/
#https://docs.microsoft.com/en-us/windows/win32/adschema/r-self-membership

#Manager setzen 
$user = Get-ADUser KMLY 
Set-ADGroup "dwssika" -Replace @{managedBy=$user.DistinguishedName}
#RightsGuid
$guid = [guid]'bf9679c0-0de6-11d0-a285-00aa003049e2'
#SID des Managers
$sid = [System.Security.Principal.SecurityIdentifier]$user.sid
#ActiveDirectoryAccessRule erstellen
$ctrlType = [System.Security.AccessControl.AccessControlType]::Allow 
$rights = [System.DirectoryServices.ActiveDirectoryRights]::WriteProperty -bor [System.DirectoryServices.ActiveDirectoryRights]::ExtendedRight
$rule = New-Object System.DirectoryServices.ActiveDirectoryAccessRule($sid, $rights, $ctrlType, $guid)
#Gruppen-ACL auslesen, neue Regel hinzufügen und ACL der Gruppe überschreiben
$group = Get-ADGroup "dwssika"
$aclPath = "AD:\" + $group.distinguishedName 
$acl = Get-Acl $aclPath
$acl.AddAccessRule($rule) 
Set-Acl -acl $acl -path $aclPath


#Manager 
$ManagerObject = Get-ADUser $Manager 
Set-ADGroup "$ADgroup" -Replace @{managedBy=$ManagerObject.DistinguishedName}
#RightsGuid
$guid = [guid]'bf9679c0-0de6-11d0-a285-00aa003049e2'
#SID of the manager 
$sid = [System.Security.Principal.SecurityIdentifier]$ManagerObject.sid
#ActiveDirectoryAccessRule create 
$ctrlType = [System.Security.AccessControl.AccessControlType]::Allow 
$rights = [System.DirectoryServices.ActiveDirectoryRights]::WriteProperty -bor [System.DirectoryServices.ActiveDirectoryRights]::ExtendedRight
$rule = New-Object System.DirectoryServices.ActiveDirectoryAccessRule($sid, $rights, $ctrlType, $guid)
#Read out the group ACL, add a new rule and overwrite the group's ACL 
$GroupObject = Get-ADGroup "$ADgroup"
$AD = Get-Location
#$aclPath = "AD:\" + $group.distinguishedName 
$aclPath = "$AD" + $GroupObject.distinguishedName 
$acl = Get-Acl $aclPath
$acl.AddAccessRule($rule) 
Set-Acl -acl $acl -path $aclPath