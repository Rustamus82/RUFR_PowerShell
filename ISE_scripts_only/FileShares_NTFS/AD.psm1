function Set-NtfsUserRightsOnPath {

    [CmdletBinding()]
    [Alias()]
    [OutputType([System.Security.AccessControl.DirectorySecurity])]
    Param
    (
        # Path to the Item you wanna change
        [Parameter(Mandatory = $true,
            ValueFromPipelineByPropertyName = $true)]
        [string[]]$paths,

        # username in the form domain\account
        [Parameter(Mandatory = $true,
            ValueFromPipelineByPropertyName = $true)]
        [string]$user, # mydomain\myuser https://msdn.microsoft.com/en-us/library/system.security.principal.ntaccount(v=vs.110).aspx

        # .NET Framework used to change filesystem right is documentet here https://msdn.microsoft.com/en-us/library/ms147785(v=vs.110).aspx
        [Parameter(Mandatory = $true,
            ValueFromPipelineByPropertyName = $true)]
        [System.Security.AccessControl.FileSystemRights[]]$rights, #= "Read, Write, Modify, delete, DeleteSubdirectoriesAndFiles", # delete, DeleteSubdirectoriesAndFiles https://msdn.microsoft.com/en-us/library/system.security.accesscontrol.filesystemrights(v=vs.110).aspx

        # The Below parameter meaning is explained here https://msdn.microsoft.com/en-us/library/ms229747(v=vs.110).aspx
        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true)]
        [ValidateSet("ContainerInherit", "ObjectInherit", "None", "ContainerInherit,ObjectInherit")]
        [string[]]$InheritanceF = 'none', # this sets all child files https://msdn.microsoft.com/en-us/library/ms229747(v=vs.110).aspx

        # The Below parameter meaning is explained here https://msdn.microsoft.com/en-us/library/ms229747(v=vs.110).aspx
        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true)]
        [System.Security.AccessControl.PropagationFlags]$PropagationF = 'none', #https://msdn.microsoft.com/en-us/library/ms229747(v=vs.110).aspx

        # allow or deny access based on the rules supplied
        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true)]
        [System.Security.AccessControl.AccessControlType]$allowordeny = 'allow', # https://msdn.microsoft.com/en-us/library/w4ds5h86(v=vs.110).aspx

        # The Below parameter meaning is explained here https://msdn.microsoft.com/en-us/library/system.security.accesscontrol.objectsecurity.setaccessruleprotection(v=vs.110).aspx
        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true)]
        [bool]$protectobjectfrominheritance = $false,

        # The Below parameter meaning is explained here https://msdn.microsoft.com/en-us/library/system.security.accesscontrol.objectsecurity.setaccessruleprotection(v=vs.110).aspx
        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true)]
        [bool]$preserveInheritedAccessRulesOrRemove = $true
    )

    Begin {
        Push-Location
    }
    Process {
        Write-Verbose "----------------------------------------------"
        Write-Verbose "Set-NtfsUserRightsOnPath"
        Write-Verbose "paths = {$paths}"
        Write-Verbose "user = {$user}"
        Write-Verbose "rights = {$rights}"
        Write-Verbose "InheritanceF = {$InheritanceF}"
        Write-Verbose "PropagationF = {$PropagationF}"
        Write-Verbose "allowordeny = {$allowordeny}"
        Write-Verbose "protectobjectfrominheritance = {$protectobjectfrominheritance}"
        Write-Verbose "preserveInheritedAccessRulesOrRemove = {$preserveInheritedAccessRulesOrRemove}"
        Write-Verbose "----------------------------------------------"
        #$filesArray = (Get-ChildItem "$path").FullName

        foreach ($path in $paths) {
            $acls = get-acl -path $path

            Foreach ($acl in $acls) {
                # this is unessecery because i only plan to pass it one path at a time. this is because files and folders have different values to manipulate. I cant find propagation for files, because it makes no sens since they can't have child objects.
                $filename = (convert-path $acl.pspath)
                $acl.SetAccessRuleProtection($protectobjectfrominheritance, $preserveInheritedAccessRulesOrRemove) # if $protectobjectfrominheritance is false $preserveInheritedAccessRulesOrRemove is ignored. This part is crucial for undetstanding the output. https://msdn.microsoft.com/en-us/library/system.security.accesscontrol.objectsecurity.setaccessruleprotection(v=vs.110).aspx
                # $acl = get-acl -path $path
                # $access =  $acl.Access
                # $identity = $access.identityReference.Value
                $UsersRightsExistUseModify = $null
                Foreach ($access in $acl.Access) {
                    Foreach ($identity in $access.identityReference.Value) {
                        if ($identity -eq $user) {
                            $UsersRightsExistUseModify = $true
                            $colRights = [System.Security.AccessControl.FileSystemRights]$rights
                            $InheritanceFlag = [System.Security.AccessControl.InheritanceFlags]$InheritanceF
                            $PropagationFlag = [System.Security.AccessControl.PropagationFlags]$PropagationF
                            $objType = [System.Security.AccessControl.AccessControlType]::$allowordeny

                            #$objUser = New-Object System.Security.Principal.NTAccount("$user")

                            $objAccessMod = New-Object system.security.AccessControl.AccessControlModification
                            $objAccessMod.value__ = 1
                            $Modification = $False
                            $rule = (New-Object System.Security.AccessControl.FileSystemAccessRule("$user", "$colRights", "$InheritanceFlag", "$PropagationFlag", "$objType"))
                            $acl.ModifyAccessRule($objAccessMod, $rule, [ref]$Modification) | Out-Null

                        } # if ($identity -eq $user)
                    } #end foreach identity loop
                } #end foreach access loop
                if ($UsersRightsExistUseModify -ne $true) {
                    $colRights = [System.Security.AccessControl.FileSystemRights]$rights
                    $InheritanceFlag = [System.Security.AccessControl.InheritanceFlags]$InheritanceF
                    $PropagationFlag = [System.Security.AccessControl.PropagationFlags]$PropagationF
                    $objType = [System.Security.AccessControl.AccessControlType]::$allowordeny

                    $objUser = New-Object System.Security.Principal.NTAccount("$user")

                    $objACE = New-Object System.Security.AccessControl.FileSystemAccessRule($objUser, $colRights, $InheritanceFlag, $PropagationFlag, $objType)

                    $acl.AddAccessRule($objACE) # RemoveAccessRuleAll bruges hvis de skal fjernes men alt bliver ramt. AddAccessRule
                }

                Set-Acl -path $filename -aclObject $acl

                $output = get-acl $path
                Write-Output $output

            } # Foreach ($acl in $acls)
        } # foreach ($path in $paths)

    } #process
    End {
        Pop-Location
    }
}

function Get-UserFromWellKnownSidType {
    [CmdletBinding()]

    [OutputType([psobject])]
    Param
    (
        # Welknown SID type from https://msdn.microsoft.com/en-us/library/system.security.principal.wellknownsidtype(v=vs.110).aspx
        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            Position = 0)]
        [System.Security.Principal.WellKnownSidType]$WellKnownSidType = 'BuiltinUsersSid',

        # Domain SID, defaults to WellknownSIDType BuiltinDomainSid
        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            Position = 0)]
        $domainSID = (New-Object System.Security.Principal.SecurityIdentifier([System.Security.Principal.WellKnownSidType]::BuiltinDomainSid, $null))
    )

    Begin {
        Push-Location
    }
    Process {
        Write-Verbose "----------------------------------------------"
        Write-Verbose "Get-UserFromWellKnownSidType"
        Write-Verbose "WellKnownSidType = {$WellKnownSidType}"
        Write-Verbose "domainSID = {$domainSID}"
        Write-Verbose "----------------------------------------------"

        $ID = [System.Security.Principal.WellKnownSidType]::$WellKnownSidType
        $SID = New-Object System.Security.Principal.SecurityIdentifier($ID, $domainSID)
        $objSID = New-Object System.Security.Principal.SecurityIdentifier($SID)
        $objUser = $objSID.Translate( [System.Security.Principal.NTAccount])
        [string]$NTAccount = $objUser.Value
        $props = @{ User = $NTAccount
            NTAccountSID = $SID
        }
        $UserFromWellKnownSidType = New-Object -TypeName psobject -Property $props
        Write-Output $UserFromWellKnownSidType

        Write-Output $SID
    }
    End {
        Pop-Location
    }
}

# Export only the functions using PowerShell standard verb-noun naming.
# Be sure to list each exported functions in the FunctionsToExport field of the module manifest file.
# This improves performance of command discovery in PowerShell.
Export-ModuleMember -Function Get-UserFromWellKnownSidType, Set-NtfsUserRightsOnPath