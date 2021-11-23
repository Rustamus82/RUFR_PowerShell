# -----------------------------------------------------------------------------
# This script will delete all Group Policy History and reapply policies.
# Use it when a Group Policy Setting for some reason does not apply to the pc or to the user.
#
# -----------------------------------------------------------------------------
# Created by: Peter Kjær
# Contact: peter.kjaer@dk.ey.com
# Version: 2.00
# Version History: 2.00 - Added logic to identify OS version and delete settings for Windows 10
# Moved the delete process to a function
# 1.00 - Only support for Windows 7
# Name: ResetGPOSettings.ps1
# Use: Start an elevated PowerShell command shell, browse to the directory (use cd) where this file is stored
# Run the script like this:
# - PS C:\Users\<UserName>\Desktop> .\ResetGPOSettings.ps1
# -----------------------------------------------------------------------------

# Delete all subfolders and content in subfolders
function Remove-SubFolders ($Path)
{
# Delete all child folders
<#Get-ChildItem -Path $Path | Where-Object -FilterScript {($PSItem.PSIsContainer)} |
ForEach-Object {
Remove-Item -Path $PSItem.FullName -Force -Recurse
}#>
# Delete all files and child folders in the base folder
Get-ChildItem -Path $Path |
ForEach-Object {
Remove-Item -Path $PSItem.FullName -Force -Recurse
}



}



# Load Windows Forms to setup the message box and prepare text for message box
[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
$messageBoxTitle = "Reset GPOs"
$messageBox1Text = "Please close all open programs.`rYou will most likely be logged off.`r`rClick Cancel to abort."
$messageBox2Text = "Click OK to start gpupdate /force`r`rPlease close all open programs.`rYou will most likely be logged off."



# Give the opportunity to opt out by presenting a message box with OK and Cancel
$doReset = [System.Windows.Forms.Messagebox]::Show($messageBox1Text, $messageBoxTitle,[System.Windows.Forms.MessageBoxButtons]::OKCancel,[System.Windows.Forms.MessageBoxIcon]::Information)



Switch ($doReset)
{
'OK' # Do the clean up
{
try
{
$OSversion = (Get-CimInstance Win32_OperatingSystem).Version



If ($OSversion.StartsWith(10))
{
Remove-SubFolders -Path "$env:USERPROFILE\AppData\Local\Microsoft\Group Policy\History"
Remove-SubFolders -Path "$env:USERPROFILE\AppData\Local\GroupPolicy\DataStore"
Remove-SubFolders -Path "$env:SystemRoot\System32\GroupPolicy"
Remove-SubFolders -Path "$env:SystemRoot\System32\GroupPolicyUsers"
}



If ($OSversion.StartsWith(6.1))
{

Remove-SubFolders -Path "$env:ALLUSERSPROFILE\Microsoft\Group Policy\History"
Remove-SubFolders -Path "$env:SystemRoot\System32\GroupPolicy"
Remove-SubFolders -Path "$env:SystemRoot\System32\GroupPolicyUsers"
}

$messageBox = [System.Windows.Forms.Messagebox]::Show($messageBox2Text, $messageBoxTitle,[System.Windows.Forms.MessageBoxButtons]::OK,[System.Windows.Forms.MessageBoxIcon]::Information)
Start-Process -FilePath "$env:SystemRoot\System32\cmd.exe" -ArgumentList "/c `"%SystemRoot%\System32\gpupdate.exe /force /logoff`" & Pause"
Exit

}
catch
{
# Do nothing here. It should just end without showing any errors.
Exit
}



}

'Cancel'
{
# Do nothing here. Just end.
Exit
}



}