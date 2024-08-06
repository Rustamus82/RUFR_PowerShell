<#PSVersion 5 Script made/assembled by Rust@m 24-05-2024 v.1.0.3

#>


#-------------------------------------------------------------------------------------------------------------------------------
## Sort by user and list user only once and list all the groups it is memberof coma separated on the same line as row
#-------------------------------------------------------------------------------------------------------------------------------

# Retrieve groups containing the specified text pattern
$groups = Get-ADGroup -Filter {Name -like "*Prefix or name in interest*"}

# Create a hashtable to store user information grouped by SamAccountName
$usersInfo = @{}

# Iterate through each group and retrieve its members
foreach ($group in $groups) {
    $groupMembers = Get-ADGroupMember -Identity $group
    foreach ($member in $groupMembers) {
        $user = Get-ADUser -Identity $member.DistinguishedName -Properties SamAccountName, GivenName, Surname, whenCreated
        if (-not $usersInfo.ContainsKey($user.SamAccountName)) {
            $usersInfo[$user.SamAccountName] = [PSCustomObject]@{
                SamAccountName = $user.SamAccountName
                #UserName = $user.Name
                FirstName = $user.GivenName
                LastName = $user.Surname
                DateCreated = $user.whenCreated.ToString("MM/dd/yyyy")  # Convert to short date format
                Groups = @()                
            }
        }
        $usersInfo[$user.SamAccountName].Groups += $group.Name
        #$usersInfo[$user.SamAccountName].Groups += ($group.Name -replace "[\s,]", "")

    }
}

# Sort users by SamAccountName and output results
$sortedUsers = $usersInfo.Values | Sort-Object SamAccountName

# Format groups as comma-separated string for each user
foreach ($user in $sortedUsers) {
    #$user.Groups = $user.Groups -join ", "
    $user.Groups = $user.Groups -join "*"
}

# Export the results to a CSV file with QuotesQuotes
#$sortedUsers | Export-Csv -Path ".\UserGroupInfo_GroupRow.csv" -NoTypeInformation -Encoding UTF8


# Create a manual CSV content
$csvContent = @()
$csvContent += "SamAccountName,FirstName,LastName,DateCreated,Groups"
foreach ($user in $sortedUsers) {
    $csvContent += "$($user.SamAccountName),$($user.FirstName),$($user.LastName),$($user.DateCreated),$($user.Groups)"
}

# Save the CSV content to a file
$csvContent | Out-File -FilePath ".\UserGroupInfo_GroupRow.csv" -Encoding UTF8


<#-------------------------------------------------------------------------------------------------------------------------------
#-------------------------------------------------------------------------------------------------------------------------------
##List user and group membership per line
#-------------------------------------------------------------------------------------------------------------------------------
# Retrieve groups containing the specified text pattern
$groups = Get-ADGroup -Filter {Name -like "*Prefix or name in interest*"}

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
$usersInfo | Export-Csv -Path ".\UserGroupInfoGroupList.csv" -NoTypeInformation -Encoding UTF8

###-------------------------------------------------------------------------------------------------------------------------------#>