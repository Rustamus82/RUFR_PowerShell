﻿
#start powershell as admin and install following following:
Find-Module -Name "msonline*" | Install-Module
Find-Module -Name "Lync 2013*" | Install-Module
Find-Module -Name "Skype*" | Install-Module


#check
Get-InstalledModule

#In this example, modules with a name that starts with Msonline that are found by Find-Module in the online gallery are #installed to the default folder, C:\Program Files\WindowsPowerShell\Modules