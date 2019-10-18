#PSVersion 5 Script made/assembled by Rust@m 09-05-2019
<#Login RUFR all AD login, Hybrid and o365
$CommandPath = (Get-Location).Path | Split-Path -Parent|Split-Path -Parent; $script = "$CommandPath\Logins\Login_SSI_SST_exch2010_DKSUND_Exchange365_RUFR.ps1"; & $script; 

cls
#>

<# Change to correct Psdriver path
#Get-PSDrive
Set-Location -Path 'SSIAD:' 
Set-Location -Path 'SSTAD:'
Set-Location -Path 'DKSUNDAD:'
Set-Location C:\RUFR_PowerShell_v1.45\ISE_scripts_only\GroupMemberships
#>


## only on one group, source to target
#copy member from source grooup to target group.
$GroupSource ="grp-tmp"
$GroupTarget ="GRP-SDVagtplan"

#get members from specific Group - choose correct AD
Get-ADGroupMember "grp-tmp" | Where-Object -FilterScript {$_.ObjectClass -eq 'User'} |ogv
$GroupSourceMembers = Get-ADGroupMember $GroupSource | Where-Object -FilterScript {$_.ObjectClass -eq 'User'}
#$GroupSourceMembers.SamAccountName |measure
$GroupSourceMembers

#Add members 
"Adding $GroupSourceMembers to {0} $('[{0:yyyy/mm/dd} {0:HH:mm:ss}]' -f (Get-Date))" -f  $GroupTarget | Out-File C:\RUFR_PowerShell_v1.45\ISE_scripts_only\GroupMemberships\add-adgroupMember_From_and_To_log.txt -Append -Verbose
Add-ADGroupMember -Identity $GroupTarget -Members $GroupSourceMembers



## mass change on many groups
#Get content from file nee to set location where the source files is
Set-Location C:\RUFR_PowerShell_v1.45\ISE_scripts_only\GroupMemberships
$ADGroups = Import-CSV .\AdGroupsDefinition.txt -Delimiter ";" -Encoding UTF8
$ADGroups.AdGroupSource
$ADGroups.AdGroupTarget

#Changeing to AD to preform group executions
Set-Location -Path 'DKSUNDAD:'
Foreach ($Adgroup in $ADGroups) 
{   
        
     #Following to filter only user members and not groups
     $GroupSourceMember = Get-ADGroupMember -Identity $Adgroup.AdGroupSource | Where-Object -FilterScript {$_.ObjectClass -eq 'User'}
     
     "Adding $GroupSourceMember to {0} $('[{0:yyyy/mm/dd} {0:HH:mm:ss}]' -f (Get-Date))" -f  $ADGroup.AdGroupTarget  | Out-File C:\RUFR_PowerShell_v1.45\add-adgroupMember_From_and_To_log.txt -Append -Verbose
     Add-ADGroupMember -Identity $Adgroup.AdGroupTarget -Members $GroupSourceMembers
     
     #Following to filter only user members and not groups
     #Add-ADGroupMember -Identity $Adgroup.AdGroupTarget -Members ($ADGroup.AdGroupSource)
     
     
}
