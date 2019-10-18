#
Add-ADGroupPropertyPermission -ADObject TheMailboxAccessGroup -MasterObject TheMailboxOwnerGroup -AccessRight WriteProperty -AccessRule Allow -Property Member

help *Add-ADGroupPropertyPermission*