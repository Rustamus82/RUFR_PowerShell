﻿#PSVersion 5 Script made/assembled by Rust@m 08-05-2019
#Start ps1 as different user - ssi\adm-initialer

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
Get-Content "C:\RUFR_PowerShell_v1.58\ISE_scripts_only\SCCM\DeviceCollectionMembers.txt" | foreach { Add-CMDeviceCollectionDirectMembershipRule -CollectionID "PS1005D0" -ResourceID (Get-CMDevice -Name $_).ResourceID -ErrorAction SilentlyContinue }
cls
#(Get-CMDevice -Name 'SSI000592').ResourceID 