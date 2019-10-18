
function Set-GroupManager {
    param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$false, ValueFromPipelinebyPropertyName=$True, Position=0)]
        [string]$ManagerDN,
        [Parameter(Mandatory=$true, ValueFromPipeline=$false, ValueFromPipelinebyPropertyName=$True, Position=1)]
        [string]$GroupDN
        )

    try {
        Import-Module ActiveDirectory -NoClobber

        $mgr = [ADSI]"LDAP://$ManagerDN";
        #        $identityRef = (Get-ADUser -Filter {DistinguishedName -like $ManagerDN}).SID.Value
        #  $sid = New-Object System.Security.Principal.SecurityIdentifier ($identityRef);
        $sid = $UserCredSSI
        $adRule = New-Object System.DirectoryServices.ActiveDirectoryAccessRule ($sid, `
                    [System.DirectoryServices.ActiveDirectoryRights]::WriteProperty, `
                    [System.Security.AccessControl.AccessControlType]::Allow, `
                    [Guid]"5c308557-3df0-430f-b86c-0b8f95e4b156");

        $grp = [ADSI]"LDAP://$GroupDN";

        $grp.InvokeSet("managedBy", @("$ManagerDN"));
        $grp.CommitChanges();

        # Taken from here: http://blogs.msdn.com/b/dsadsi/archive/2013/07/09/setting-active-directory-object-permissions-using-powershell-and-system-directoryservices.aspx
        [System.DirectoryServices.DirectoryEntryConfiguration]$SecOptions = $grp.get_Options();
        $SecOptions.SecurityMasks = [System.DirectoryServices.SecurityMasks]'Dacl'

        $grp.get_ObjectSecurity().AddAccessRule($adRule);
        $grp.CommitChanges();
    }
    catch {
        throw
    }
}
