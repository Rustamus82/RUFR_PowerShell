﻿#PSVersion 5 Script made/assembled by Rust@m 08-05-2019
#Start ps1 as different user - ssi\adm-initialer
$ISEScriptPath = (Get-Location).Path
# Press 'F5' to run this script. Running this script will load the ConfigurationManager
# module for Windows PowerShell and will connect to the site.
#
# This script was auto-generated at '01-11-2018 16:58:41'.

# Uncomment the line below if running in an environment where script signing is 
# required.
#Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process

# Site configuration
$SiteCode = "PS1" # Site code 
$ProviderMachineName = "SRV-INF-SCCM.ssi.ad" # SMS Provider machine name

# Customizations
$initParams = @{}
#$initParams.Add("Verbose", $true) # Uncomment this line to enable verbose logging
#$initParams.Add("ErrorAction", "Stop") # Uncomment this line to stop the script on any errors

# Do not change anything below this line

# Import the ConfigurationManager.psd1 module 
if((Get-Module ConfigurationManager) -eq $null) {
    Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" @initParams 
}

# Connect to the site's drive if it is not already present
if((Get-PSDrive -Name $SiteCode -PSProvider CMSite -ErrorAction SilentlyContinue) -eq $null) {
    New-PSDrive -Name $SiteCode -PSProvider CMSite -Root $ProviderMachineName @initParams
}

# Set the current location to be the site code.
Set-Location "$($SiteCode):\" @initParams

#add list of Computers to DeviceCollection - need to be correclt path to files Get-Content ".\CollectionDeviceMembers.txt" - -CollectionID "Se in Properties on Collection"
#Get-Content "C:\RUFR_PowerShell\ISE_scripts_only\SCCM\DeviceCollectionMembers.txt" | foreach { Add-CMDeviceCollectionDirectMembershipRule -CollectionID "PS10050A" -ResourceID (Get-CMDevice -Name $_).ResourceID -ErrorAction SilentlyContinue }
$devices = Get-Content "C:\Users\adm-rufr\Desktop\SCCM\DeviceCollectionMembers.txt"; $devices.Count
Get-Content "C:\Users\adm-rufr\Desktop\SCCM\DeviceCollectionMembers.txt" | foreach {Write-Host "Adding Device: $_" -foregroundcolor Cyan; Add-CMDeviceCollectionDirectMembershipRule -CollectionID "PS10073D" -ResourceID (Get-CMDevice -Name $_).ResourceID -ErrorAction SilentlyContinue }    

cls
#(Get-CMDevice -Name 's-sei-mq1-p').ResourceID 
<#
Get-CMDeviceCollection -Name "VMware Virtuele servere i HCI v11.2.5 (s-vc01-p)" |select name,CollectionID
Get-CMDeviceCollection -Id "PS1006F5" |select name,CollectionID
#> 

<#
$CollMem = Get-CMCollectionMember -CollectionName "RUFR PCer med defekt SCCM klient"

$MemberInfo = foreach ($item in $CollMem)
{
    "CompuerName: " + $item.Name + " Domain: " + $item.Domain  + " PrimaryUser: " + $item.PrimaryUser + ", Last logged on user: " + $item.UserName + " CurrentLogonUser: " + $item.CurrentLogonUser
}; $MemberInfo

#>