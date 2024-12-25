﻿Enter-PSSession -ComputerName "MSD-4LLKFB3.ssi.ad"

$Lookup = @{
# For One True framework (latest .NET 4x), change the Where-Oject match 

Get-LocalGroupMember Administrators

#enable Remote Desktop using PowerShell on Windows 10
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -name "fDenyTSConnections" -value 1
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"

#Enable Windows update instead og WSUS:
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU' -name "UseWUServer" -value 0

#Disable Windows Update and enable WSUS:
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU' -name "UseWUServer" -value 1


#Enable location services in windows 11:
Set-ItemProperty -Path 'HKLM:\\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location' -name "Value" -value 'Allow'