<#PSVersion 5 Script made/assembled by Rust@m 12-08-2024

#>

Import-Module -Name ActiveDirectory

#Defile the CSV file location to be stored
#$ResultCSV = "$env:SystemDrive\Users\$env:USERNAME\Desktop\LDAP\UserGroupInfo_GroupRow.csv"
$ResultCSV = "$env:ProgramFiles\Securiton\Securigate\Service\SecurigateSyncService\CSVFile\UserGroupInfo_DL_PF00_SGATE_and_DG_PF00_Facility.csv"

#Delete CSV file
if (Test-Path $ResultCSV){Remove-Item -Path $ResultCSV -Force}

#-------------------------------------------------------------------------------------------------------------------------------
## Sort by user and list user only once and list all the groups it is memberof coma separated on the same line as row
#-------------------------------------------------------------------------------------------------------------------------------

# LDAPfilter_v1.0.6 - Retrieve groups containing the specified text pattern, additional group added "DG_PF00_Facility"
$groups = Get-ADGroup -Filter 'Name -like "*DL_PF00_SGATE*" -and Name -like "*DG_PF00_Facility*"'

# Create a hashtable to store user information grouped by SamAccountName
$usersInfo = @{}

# Iterate through each group and retrieve its members
foreach ($group in $groups) {
    $groupMembers = Get-ADGroupMember -Identity $group
    foreach ($member in $groupMembers) {
        $user = Get-ADUser -Identity $member.DistinguishedName -Properties SamAccountName, GivenName, Surname, Enabled # LDAPfilter_v1.0.5 - Removed 4th column "whenCreated, "
         if (-not $usersInfo.ContainsKey($user.SamAccountName)) {
            $usersInfo[$user.SamAccountName] = [PSCustomObject]@{
                SamAccountName = $user.SamAccountName
                #UserName = $user.Name
                GivenName = $user.GivenName
                Surname = $user.Surname
#                whenCreated = $user.whenCreated.ToString("MM/dd/yyyy")  # Convert to short date format
                Enabled = $user.Enabled
                Groups = @()                
            }
        }
        #$usersInfo[$user.SamAccountName].Groups += ($group.Name -replace "[\s,]", "")
        $usersInfo[$user.SamAccountName].Groups += $group.Name
    }
}

# Sort users by SamAccountName and output results
$sortedUsers = $usersInfo.Values | Sort-Object SamAccountName

# Format groups as comma-separated string for each user
foreach ($user in $sortedUsers) {
    #$user.Groups = $user.Groups -join ", "
    $user.Groups = $user.Groups -join "*"
}


<# will be not used manual csv we will use default AD values
# Create a manual CSV content
$csvContent = @()
#$csvContent += "SamAccountName,FirstName,LastName,DateCreated,Groups"
foreach ($user in $sortedUsers) {
    $csvContent += "$($user.SamAccountName),$($user.FirstName),$($user.LastName),$($user.DateCreated),$($user.Groups)"
}

# Save the CSV content to a file from a manual CSV content
$csvContent | Out-File -FilePath $ResultCSV -Encoding UTF8
#>

# Export the results to a CSV standard
$sortedUsers | Export-Csv -Path $ResultCSV -NoTypeInformation -Encoding UTF8

# LDAPfilter_v1.0.5 - Removed quotations marks from CSV file
(Get-Content $ResultCSV).Replace("`"","") | Set-Content $ResultCSV


<#-------------------------------------------------------------------------------------------------------------------------------
#-------------------------------------------------------------------------------------------------------------------------------
##List user and group membership per line
#-------------------------------------------------------------------------------------------------------------------------------
# Retrieve groups containing the specified text pattern
$groups = Get-ADGroup -Filter {Name -like "*DL_PF00_SGATE*"}

# Create an empty array to store user information
$usersInfo = @()

# Iterate through each group and retrieve its members
foreach ($group in $groups) {
    $groupMembers = Get-ADGroupMember -Identity $group
    foreach ($member in $groupMembers) {
        $user = Get-ADUser -Identity $member.DistinguishedName -Properties SamAccountName, GivenName, Surname, whenCreated
        $userObj = [PSCustomObject]@{
            #UserName = $user.Name
            SamAccountName = $user.SamAccountName
            FirstName = $user.GivenName
            LastName = $user.Surname
            DateCreated = $user.whenCreated.ToString("MM/dd/yyyy")  # Convert to short date format
            GroupName = $group.Name            
        }
        $usersInfo += $userObj
    }
}

# Export the results to a CSV file
#$usersInfo | Export-Csv -Path ".\UserGroupInfoGroupList.csv" -NoTypeInformation -Encoding UTF8
$sortedUsers | Export-Csv -Path $ResultCSV -NoTypeInformation -Encoding UTF8

###-------------------------------------------------------------------------------------------------------------------------------#>
