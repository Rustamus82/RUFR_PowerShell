﻿Enter-PSSession -ComputerName "MSD-4LLKFB3.ssi.ad"

$Lookup = @{    378389 = [version]'4.5'    378675 = [version]'4.5.1'    378758 = [version]'4.5.1'    379893 = [version]'4.5.2'    393295 = [version]'4.6'    393297 = [version]'4.6'    394254 = [version]'4.6.1'    394271 = [version]'4.6.1'    394802 = [version]'4.6.2'    394806 = [version]'4.6.2'    460798 = [version]'4.7'    460805 = [version]'4.7'    461308 = [version]'4.7.1'    461310 = [version]'4.7.1'    461808 = [version]'4.7.2'    461814 = [version]'4.7.2'    528040 = [version]'4.8'    528049 = [version]'4.8'}
# For One True framework (latest .NET 4x), change the Where-Oject match # to PSChildName -eq "Full":Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP' -Recurse |  Get-ItemProperty -name Version, Release -EA 0 |  Where-Object { $_.PSChildName -match '^(?!S)\p{L}'} |  Select-Object @{name = ".NET Framework"; expression = {$_.PSChildName}}, @{name = "Product"; expression = {$Lookup[$_.Release]}}, Version, Release

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