Write-Host "Husk du får 3 logins."
Write-Host
Write-Host "Første login er til Hybrid server i DKSUND. Benyt dksund\<din adminkonto>"
Write-Host "Andet login er til Office365. Benyt <din adminkonto>@dksund.onmicrosoft.com"
Write-Host
Write-Host "Andet login er til SSI AD. Benyt SSI\<din adminkonto>"
Write-Host
#*****************************************************
#LOGIN
#*****************************************************
#DKSUND AD login og session til Exchange ON Premises
$UserCredDksund = Get-Credential dksund\adm-rufr
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://s-exc-hyb-01p.dksund.dk/PowerShell/ -Authentication Kerberos -Credential $UserCredDksund
Import-PSSession $session

#login til  Office 365 og session.
$credo365 = Get-Credential adm-rufr@dksund.onmicrosoft.com
$sessiono365 = New-PSSession -ConfigurationName Microsoft.Exchange -Authentication Basic -ConnectionUri https://ps.outlook.com/powershell -AllowRedirection:$true -Credential $credo365
Import-PSSession $sessiono365 -Prefix o365
Connect-MsolService -Credential $credo365

#SSI AD login og import af AD modulet.
$UserCredSSI = Get-Credential ssi\adm-rufr
Import-Module -Name ActiveDirectory 
#*************************************************
#Variable for funktion:
$ServerNameSSI = 'srv-ad-dc04.ssi.ad'
$MasterObject = $Manager
$ADObject = $GroupName
#ADD external assemblies here
#[System.Security.Principal.SecurityIdentifier]


#Function:
function Add-ADGroupPropertyPermission
{
    <#
    .SYNOPSIS
    This function is used for setting access rights on properties on Active Directory Groups.
    Use this code with caution! It has not been tested on a lot of objects/properties/access rights!

    .DESCRIPTION
    This function changes the ACLs on AD-Groups to enable granular delegation of them to other groups.

    Use this code with caution! It has not been tested on a lot of objects/properties/access rights!

    .EXAMPLE
    Add-ADGroupPropertyPermission -ADObject TheGroupSomeoneWantsAccessTo -MasterObject TheGroupWhoWillGainAccess -AccessRight WriteProperty -AccessRule Allow -Property Member -ActiveDirectoryServer MyDomain

    .PARAMETER ADObject
    Specify the identity of the group you want to delegate to the other group.

    .PARAMETER MasterObject
    Specify the identity of the group who should gain access to the specified property.

    .PARAMETER AccessRight
    Specify what access should be added, for example WriteProperty.

    .PARAMETER AccessRule
    Set this to Allow or Deny.

    .PARAMETER Property
    Specify which property this should be applied for.

    .PARAMETER ActiveDirectoryServer
    Specify domain or domain controller where the search for the groups will take place.

    #>

    [cmdletbinding()]
    param (
           [Parameter(Mandatory=$True)]
           $ADObject,
           [Parameter(Mandatory=$True)]
           $MasterObject,
           [Parameter(Mandatory=$True)]
           $AccessRight,
           [Parameter(Mandatory=$True)]
           [ValidateSet("Allow","Deny")]
           $AccessRule,
           [Parameter(Mandatory=$True)]
           $Property,
           $ActiveDirectoryServer)
           

    # Load the AD objects
    try {
        $TheAccessGroup = Get-ADGroup -Identity $ADObject -Server $ActiveDirectoryServer -ErrorAction Stop
    }
    catch {
        Write-Error "Failed to get the object with identity $ADObject. The error was: $($Error[0])."
        return
    }

    try {
        
        $TheOwnerUser = Get-ADuser -Identity $MasterObject -Server $ActiveDirectoryServer -ErrorAction Stop
        
    }
    catch {
        Write-Error "Failed to get the object with identity $MasterObject. The error was: $($Error[0])."
        return
    }

    # Create SID-objects
    try {
        $AccessGroupSid = New-Object System.Security.Principal.SecurityIdentifier ($TheAccessGroup).SID -ErrorAction Stop
    }
    catch {
        Write-Error "Failed to resolve the sid of $ADObject. The error was: $($Error[0])."
        return
    }

    try {
        $OwnerUserSid = New-Object System.Security.Principal.SecurityIdentifier ($TheOwnerUser).SID -ErrorAction Stop
    }
    catch {
        Write-Error "Failed to resolve the sid of $MasterObject. The error was: $($Error[0])."
        return
    }

    # Create the ACL object
    try {
        $AccessGroupACL = Get-Acl -Path "AD:\$($TheAccessGroup.DistinguishedName)" -ErrorAction Stop
    }
    catch {
        Write-Error "Failed to get the ACL of $($TheAccessGroup.DistinguishedName). The error was: $($Error[0])."
        return
    }

    #Get a reference to the RootDSE of the current domain
    $rootdse = Get-ADRootDSE

    #Create a hashtable to store the GUID value of each schema class and attribute
    $guidmap = @{}
    Get-ADObject -SearchBase ($rootdse.SchemaNamingContext) -LDAPFilter "(schemaidguid=*)" -Properties lDAPDisplayName,schemaIDGUID | % {$guidmap[$_.lDAPDisplayName]=[System.GUID]$_.schemaIDGUID}

    #Create a hashtable to store the GUID value of each extended right in the forest
    $extendedrightsmap = @{}
    Get-ADObject -SearchBase ($rootdse.ConfigurationNamingContext) -LDAPFilter "(&(objectclass=controlAccessRight)(rightsguid=*))" -Properties displayName,rightsGuid | % {$extendedrightsmap[$_.displayName]=[System.GUID]$_.rightsGuid}

    # Create the new rule
    #$AccessGroupACL.AddAccessRule((New-Object System.DirectoryServices.ActiveDirectoryAccessRule $OwnerGroupSid,$extendedrightsmap["Group Membership"],"Allow","Descendents",$guidmap["user"]))
    
    # Allow time to create the object
    $AccessGroupACL.AddAccessRule((New-Object System.DirectoryServices.ActiveDirectoryAccessRule $OwnerGroupSid,$AccessRight,$AccessRule,$guidmap["$Property"]))

    # Set the ACL
    try {
        Set-Acl -AclObject $AccessGroupACL -Path "AD:\$($TheAccessGroup.DistinguishedName)" -ErrorAction Stop
    }
    catch {
        Write-Error "Failed to set the ACL on $($TheAccessGroup.DistinguishedName). The error was: $($Error[0])."
        return
    }
}

#*************************************************
#script 
#*************************************************
cls

#Variabler oprettelse:

$OUPath = 'OU=Distribution lists,DC=SSI,DC=ad'
$GroupName = Read-Host -Prompt 'Angiv  distribution liste name'
$Manager = Read-Host -Prompt 'Angiv Manager af grupper'
$company = Read-Host "Tast 1 for SSI eller 2 for Sundhedsdatastyrelsen (så får den @ssi.dk eller @sundhedsdata.dk)"
$Description = Read-Host -Prompt 'Angiv beskrivelse'

#Distributionsgruppe oprettelse i SSI AD.
New-ADGroup -Name $GroupName -GroupScope Universal -GroupCategory Distribution -ManagedBy $Manager -Description $Description -Path $OUPath -Credential $UserCredSSI -AuthType Negotiate -Server $ServerNameSSI


#FUnction call: Add-ADGroupPropertyPermission
#help Add-ADGroupPropertyPermission
#get-help Add-ADGroupPropertyPermission -detailed

#Add-ADGroupPropertyPermission -ADObject $GroupName -MasterObject $Manager -AccessRight] Object -AccessRule Object -Property Object [[-ActiveDirectoryServer] Object] [<CommonParameters>]
#Add-ADGroupPropertyPermission -ADObject TheGroupSomeoneWantsAccessTo -MasterObject TheUserWhoWillGainAccess -AccessRight WriteProperty -AccessRule Allow -Property Member -ActiveDirectoryServer MyDomain
    
#mailaktivering af rguppen Exchange 2016 
		 Enable-DistributionGroup -Identity $GroupName
		 If ($company -eq "1") {
		 $new = $GroupName + "@ssi.dk"
		 Set-DistributionGroup $GroupName -PrimarySMTPAddress $new -EmailAddressPolicyEnabled $false
		 }
		 ElseIf ($company -eq "2") {
		 $new = $GroupName + "@sundhedsdata.dk"
		 Set-DistributionGroup $GroupName -PrimarySMTPAddress $new -EmailAddressPolicyEnabled $false
		 }
		 
#tjek tingende:
#Disable-DistributionGroup -Identity $GroupName
#Get-DistributionGroup -Identity $GroupName | fl
#help Set-DistributionGroup -Detailed

