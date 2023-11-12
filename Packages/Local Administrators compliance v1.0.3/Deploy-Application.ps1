﻿<#
.SYNOPSIS
	This script performs the installation or uninstallation of an application(s).
	# LICENSE #
	PowerShell App Deployment Toolkit - Provides a set of functions to perform common application deployment tasks on Windows.
	Copyright (C) 2017 - Sean Lillis, Dan Cunningham, Muhammad Mashwani, Aman Motazedian.
	This program is free software: you can redistribute it and/or modify it under the terms of the GNU Lesser General Public License as published by the Free Software Foundation, either version 3 of the License, or any later version. This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
	You should have received a copy of the GNU Lesser General Public License along with this program. If not, see <http://www.gnu.org/licenses/>.
.DESCRIPTION
	The script is provided as a template to perform an install or uninstall of an application(s).
	The script either performs an "Install" deployment type or an "Uninstall" deployment type.
	The install deployment type is broken down into 3 main sections/phases: Pre-Install, Install, and Post-Install.
	The script dot-sources the AppDeployToolkitMain.ps1 script which contains the logic and functions required to install or uninstall an application.
.PARAMETER DeploymentType
	The type of deployment to perform. Default is: Install.
.PARAMETER DeployMode
	Specifies whether the installation should be run in Interactive, Silent, or NonInteractive mode. Default is: Interactive. Options: Interactive = Shows dialogs, Silent = No dialogs, NonInteractive = Very silent, i.e. no blocking apps. NonInteractive mode is automatically set if it is detected that the process is not user interactive.
.PARAMETER AllowRebootPassThru
	Allows the 3010 return code (requires restart) to be passed back to the parent process (e.g. SCCM) if detected from an installation. If 3010 is passed back to SCCM, a reboot prompt will be triggered.
.PARAMETER TerminalServerMode
	Changes to "user install mode" and back to "user execute mode" for installing/uninstalling applications for Remote Destkop Session Hosts/Citrix servers.
.PARAMETER DisableLogging
	Disables logging to file for the script. Default is: $false.
.EXAMPLE
    powershell.exe -Command "& { & '.\Deploy-Application.ps1' -DeployMode 'Silent'; Exit $LastExitCode }"
.EXAMPLE
    powershell.exe -Command "& { & '.\Deploy-Application.ps1' -AllowRebootPassThru; Exit $LastExitCode }"
.EXAMPLE
    powershell.exe -Command "& { & '.\Deploy-Application.ps1' -DeploymentType 'Uninstall'; Exit $LastExitCode }"
.EXAMPLE
    Deploy-Application.exe -DeploymentType "Install" -DeployMode "Silent"
.NOTES
	Toolkit Exit Code Ranges:
	60000 - 68999: Reserved for built-in exit codes in Deploy-Application.ps1, Deploy-Application.exe, and AppDeployToolkitMain.ps1
	69000 - 69999: Recommended for user customized exit codes in Deploy-Application.ps1
	70000 - 79999: Recommended for user customized exit codes in AppDeployToolkitExtensions.ps1
.LINK
	http://psappdeploytoolkit.com
#>
[CmdletBinding()]
Param (
	[Parameter(Mandatory=$false)]
	[ValidateSet('Install','Uninstall','Repair')]
	[string]$DeploymentType = 'Install',
	[Parameter(Mandatory=$false)]
	[ValidateSet('Interactive','Silent','NonInteractive')]
	[string]$DeployMode = 'Interactive',
	[Parameter(Mandatory=$false)]
	[switch]$AllowRebootPassThru = $false,
	[Parameter(Mandatory=$false)]
	[switch]$TerminalServerMode = $false,
	[Parameter(Mandatory=$false)]
	[switch]$DisableLogging = $false
)

Try {
	## Set the script execution policy for this process
	Try { Set-ExecutionPolicy -ExecutionPolicy 'ByPass' -Scope 'Process' -Force -ErrorAction 'Stop' } Catch {}

	##*===============================================
	##* VARIABLE DECLARATION
	##*===============================================
	## Variables: Application
	[string]$appVendor = 'MyCompany'
	[string]$appName = 'Local Administrators compliance'
	[string]$appVersion = '1.0.3'
	[string]$appArch = 'multi'
	[string]$appLang = 'EN'
	[string]$appRevision = '01'
	[string]$appScriptVersion = '1.0.0'
	[string]$appScriptDate = '17/01/2022'
	[string]$appScriptAuthor = 'RUFR'
    [string]$ProductCode = ''
    [string]$installFile = "Konti som skal smides ud 2.xlsx"
	##*===============================================
	## Variables: Install Titles (Only set here to override defaults set by the toolkit)
	[string]$installName = "$appName $appVersion"
	[string]$installTitle = "$appName $appVersion"

	##* Do not modify section below
	#region DoNotModify

	## Variables: Exit Code
	[int32]$mainExitCode = 0

	## Variables: Script
	[string]$deployAppScriptFriendlyName = 'Deploy Application'
	[version]$deployAppScriptVersion = [version]'3.8.4'
	[string]$deployAppScriptDate = '26/01/2021'
	[hashtable]$deployAppScriptParameters = $psBoundParameters

	## Variables: Environment
	If (Test-Path -LiteralPath 'variable:HostInvocation') { $InvocationInfo = $HostInvocation } Else { $InvocationInfo = $MyInvocation }
	[string]$scriptDirectory = Split-Path -Path $InvocationInfo.MyCommand.Definition -Parent

	## Dot source the required App Deploy Toolkit Functions
	Try {
		[string]$moduleAppDeployToolkitMain = "$scriptDirectory\AppDeployToolkit\AppDeployToolkitMain.ps1"
		If (-not (Test-Path -LiteralPath $moduleAppDeployToolkitMain -PathType 'Leaf')) { Throw "Module does not exist at the specified location [$moduleAppDeployToolkitMain]." }
		If ($DisableLogging) { . $moduleAppDeployToolkitMain -DisableLogging } Else { . $moduleAppDeployToolkitMain }
	}
	Catch {
		If ($mainExitCode -eq 0){ [int32]$mainExitCode = 60008 }
		Write-Error -Message "Module [$moduleAppDeployToolkitMain] failed to load: `n$($_.Exception.Message)`n `n$($_.InvocationInfo.PositionMessage)" -ErrorAction 'Continue'
		## Exit the script, returning the exit code to SCCM
		If (Test-Path -LiteralPath 'variable:HostInvocation') { $script:ExitCode = $mainExitCode; Exit } Else { Exit $mainExitCode }
	}

	#endregion
	##* Do not modify section above
	##*===============================================
	##* END VARIABLE DECLARATION
	##*===============================================

	If ($deploymentType -ine 'Uninstall' -and $deploymentType -ine 'Repair') {
		##*===============================================
		##* PRE-INSTALLATION
		##*===============================================
		[string]$installPhase = 'Pre-Installation'

		## Show Welcome Message, close Internet Explorer if required, allow up to 3 deferrals, verify there is enough disk space to complete the install, and persist the prompt
		Show-InstallationWelcome -CloseApps 'Tvsukernel' -CheckDiskSpace -PersistPrompt

		## Show Progress Message (with the default message)
		Show-InstallationProgress

		## <Perform Pre-Installation tasks here>
        <# following is failing if there is unknown orphaned AD objekt.
        Get-LocalGroupMember 'Administratorer'
        Get-LocalGroupMember 'Administrator'
        Get-LocalGroupMember -SID 'S-1-5-32-544'
        Get-LocalGroupMember -SID 'S-1-5-32-544' | Where-Object PrincipalSource -EQ Local
        Get-LocalGroupMember -SID 'S-1-5-32-544' | Where-Object name -Like '*lenovo_tmp*'

        $domainSID = (New-Object System.Security.Principal.SecurityIdentifier([System.Security.Principal.WellKnownSidType]::BuiltinDomainSid, $null))
        $ID = [System.Security.Principal.WellKnownSidType]::BuiltinAdministratorsSid
        $SID = New-Object System.Security.Principal.SecurityIdentifier($ID, $domainSID)
        $objUser = $SID.Translate( [System.Security.Principal.NTAccount])
        [string]$NTAccount = $objUser.Value
        $props = @{ User = $NTAccount
        NTAccountSID = $SID
        }
        $UserFromWellKnownSidType = New-Object -TypeName psobject -Property $props
        Write-Output $UserFromWellKnownSidType        
        #>




		##*===============================================
		##* INSTALLATION
		##*===============================================
		[string]$installPhase = 'Installation'

		## Handle Zero-Config MSI Installations
		If ($useDefaultMsi) {
			[hashtable]$ExecuteDefaultMSISplat =  @{ Action = 'Install'; Path = $defaultMsiFile }; If ($defaultMstFile) { $ExecuteDefaultMSISplat.Add('Transform', $defaultMstFile) }
			Execute-MSI @ExecuteDefaultMSISplat; If ($defaultMspFiles) { $defaultMspFiles | ForEach-Object { Execute-MSI -Action 'Patch' -Path $_ } }
		}

		## <Perform Installation tasks here>
                
        #removal of orphaned SIDs from local administrarors group. Works fine on Windows 10, but fails on Windows 8.1 and presumably on windows 7
        $domainSID = (New-Object System.Security.Principal.SecurityIdentifier([System.Security.Principal.WellKnownSidType]::BuiltinDomainSid, $null))
        $ID = [System.Security.Principal.WellKnownSidType]::BuiltinAdministratorsSid
        $SID = New-Object System.Security.Principal.SecurityIdentifier($ID, $domainSID)
        $objUser = $SID.Translate( [System.Security.Principal.NTAccount])
        [string]$NTAccount = $objUser.Value
        $props = @{ User = $NTAccount
        NTAccountSID = $SID
        }
        $UserFromWellKnownSidType = New-Object -TypeName psobject -Property $props
        $adminGroupName = $UserFromWellKnownSidType.User -replace 'BUILTIN\\',''
                
        $adsi = [adsi]"WinNT://$env:COMPUTERNAME"
        $adminGroup = $adsi.Children.Find("$adminGroupName", "Group")
        foreach ($mem in $adminGroup.psbase.Invoke("members"))
        {
        
        try{            
            $type = $mem.GetType()
            $name = $type.InvokeMember("Name", "GetProperty", $null, $mem, $null) # Not sure what this equals if there's no account
            [byte[]]$sidBytes = $type.InvokeMember("ObjectSid", "GetProperty", $null, $mem, $null)
            $sid = New-Object System.Security.Principal.SecurityIdentifier($sidBytes, 0)
            }
            catch{}
        
        # Maybe try translating it?
        try
        {
        $ntAcct = $sid.Translate([System.Security.Principal.NTAccount])
        }
        catch [System.Management.Automation.MethodInvocationException]
        {
        # Couldn't translate, could be a candidate for removal
        Write-Warning "Orphaned AD objekt SID removed $($sid.Value)..."
        "If Orphaned AD objekt exist, then this SID removed: $($sid.Value)" | Out-File "$env:SystemRoot\logs\Software\Unauthorized Users removal from Local Administrators.log" -Append
        #Actual Removal
        $adminGroup.Remove(("WinNT://$sid"))
        }
        }


        # try to resolve group after if orpahned objekts removed else gives error and stop the execution
        Try{Get-LocalGroupMember -SID 'S-1-5-32-544' -ErrorAction Stop
        }
        catch
        {
            $ErrorMessage = $_.Exception.Message
            "If Orphaned AD objekt exist and cannot be femoved Get-LocalGroupMember error: $ErrorMessage " | Out-File "$env:SystemRoot\logs\Software\Unauthorized Users removal from Local Administrators.log" -Append
            #[int32]$mainExitCode = 60001
	        [string]$mainErrorMessage = "$(Resolve-Error)"
	        #Write-Log -Message $mainErrorMessage -Severity 3 -Source $deployAppScriptFriendlyName
	        Show-DialogBox -Text $mainErrorMessage -Icon 'Stop'
	        Exit-Script -ExitCode $mainExitCode
            
        }


        $lenovoUser = Get-LocalGroupMember -SID 'S-1-5-32-544' | Where-Object name -Like '*lenovo_tmp*'
        $lenovoUser | Out-File "$env:SystemRoot\logs\Software\Unauthorized Users removal from Local Administrators.log" -Append
        Get-LocalGroupMember -SID 'S-1-5-32-544' | Where-Object name -Like '*lenovo_tmp*' |Remove-LocalGroupMember -SID 'S-1-5-32-544'
        
        #selecting all users that are local type and removes all but the Administrator user.
        #$localusers = Get-LocalGroupMember -SID 'S-1-5-32-544' | Where-Object {($_.PrincipalSource -eq 'local') -and ($_.name -notlike '*Administrator*')}
        #"Local User removed from local administrators: $localusers" |Out-File "$env:SystemRoot\logs\Software\Unauthorized Users removal from Local Administrators.log" -Append
        #Get-LocalGroupMember -SID 'S-1-5-32-544' | Where-Object {($_.PrincipalSource -eq 'local') -and ($_.name -notlike '*Administrator*')} |Remove-LocalGroupMember -SID 'S-1-5-32-544'

        
        #import excel modules psd.
        Import-Module ((Get-ChildItem "$dirSupportFiles" -Recurse -Filter "ImportExcel.psd1").FullName)
        #Get-Module -Name '*excel*'

        #import from Excel of Accounts and computer that should be removed
        $collection = Import-Excel -Path "$dirFiles\$installFile"
        #$collection.Count
                
        foreach ($item in $collection)
        {
             if ($item.'Computer Name' -eq "$env:COMPUTERNAME")
                {
                    
                    $ADuser = $item.Member -replace '/','\'
                    $LocalUser = "$env:COMPUTERNAME\"+$item.Member
                    "$('[{0:yyyy/mm/dd} {0:HH:mm:ss}]' -f (Get-Date)) Following user: {0} enforced removal from computer $env:COMPUTERNAME Local Administrators group, according match in current excel. ServiceNow: RITM0022559" -f $item.Member | Out-File "$env:SystemRoot\logs\Software\Unauthorized Users removal from Local Administrators.log" -Append
                    #Get-LocalGroupMember -SID 'S-1-5-32-544' | Where-Object name -EQ $ADuser |Remove-LocalGroupMember -SID 'S-1-5-32-544' -WhatIf
                    #Get-LocalGroupMember -SID 'S-1-5-32-544' | Where-Object name -EQ $LocalUser |Remove-LocalGroupMember -SID 'S-1-5-32-544' -WhatIf

                    Get-LocalGroupMember -SID 'S-1-5-32-544' | Where-Object name -EQ $ADuser |Remove-LocalGroupMember -SID 'S-1-5-32-544' -ErrorAction SilentlyContinue
                    Get-LocalGroupMember -SID 'S-1-5-32-544' | Where-Object name -EQ $LocalUser |Remove-LocalGroupMember -SID 'S-1-5-32-544' -ErrorAction SilentlyContinue
                }
        }
        
		##*===============================================
		##* POST-INSTALLATION
		##*===============================================
		[string]$installPhase = 'Post-Installation'

		## <Perform Post-Installation tasks here>
        #Get-Module -Name '*excel*'
        Remove-Module -Name ImportExcel -Force -ErrorAction SilentlyContinue

        #addin correct lokal administrator and remote desktop for administrators for clients
        $DomainAD = Get-WmiObject -Namespace root\cimv2 -Class Win32_ComputerSystem | Select Domain
        
        if ($DomainAD.Domain -eq "dksund.dk")
        {
            #get-LocalGroupMember -SID 'S-1-5-32-544'
            #get-LocalGroupMember -SID 'S-1-5-32-555'
            Add-LocalGroupMember -SID 'S-1-5-32-544' -Member 'DKSUND\dks_l_WorkstationAdministrators_u' -ErrorAction SilentlyContinue
            Add-LocalGroupMember -SID 'S-1-5-32-555' -Member 'DKSUND\dks_l_WorkstationRDP_u' -ErrorAction SilentlyContinue
        }

        if ($DomainAD.Domain -eq "ssi.ad")
        {
            Add-LocalGroupMember -SID 'S-1-5-32-544' -Member 'SSI\GRP-APP-SCCM_Helpdes' -ErrorAction SilentlyContinue
            Add-LocalGroupMember -SID 'S-1-5-32-544' -Member 'SSI\GRP-RGH-SCCMClientPush' -ErrorAction SilentlyContinue
            Add-LocalGroupMember -SID 'S-1-5-32-555' -Member 'SSI\Domain Users' -ErrorAction SilentlyContinue
        }

        if ($DomainAD.Domain -eq "sst.dk")
        {
            Add-LocalGroupMember -SID 'S-1-5-32-544' -Member 'SST.DK\L-SST-LocalClientAdmins' -ErrorAction SilentlyContinue
            Add-LocalGroupMember -SID 'S-1-5-32-555' -Member 'SSI\dks_l_WorkstationSCCMRemoteControlUsers_u' -ErrorAction SilentlyContinue
            Add-LocalGroupMember -SID 'S-1-5-32-555' -Member 'SST.DK\dks_l_WorkstationSCCMRemoteControlUsers_u' -ErrorAction SilentlyContinue
            Add-LocalGroupMember -SID 'S-1-5-32-555' -Member 'SST.DK\Domain Users' -ErrorAction SilentlyContinue
            Add-LocalGroupMember -SID 'S-1-5-32-555' -Member 'SST.DK\L-SST-LocalClientAdmins' -ErrorAction SilentlyContinue
        }

        #detection rule for package for sccm aplication
        if($Is64Bit) {
        	$ProgramFiles = $envProgramFilesX86
        	$RegRootPath = Get-Item -Path 'HKLM:\SOFTWARE\WOW6432Node' | Select-Object -ExpandProperty Name
        }
        else {
        	$ProgramFiles = $envProgramFiles
        	$RegRootPath = Get-Item -Path 'HKLM:\SOFTWARE' | Select-Object -ExpandProperty Name
        }
        
        $Key = $(Join-path -Path $RegRootPath -ChildPath "\Microsoft\Windows\CurrentVersion\Uninstall\$appName")
        Set-RegistryKey -Key $Key -Name 'Publisher' -Value $appVendor -Type String
        Set-RegistryKey -Key $Key -Name 'DisplayName' -Value $installTitle -Type String
        Set-RegistryKey -Key $Key -Name 'DisplayVersion' -Value $appVersion -Type String
        #Set-RegistryKey -Key $Key -Name 'DisplayIcon' -Value $null -Type String
        #Set-RegistryKey -Key $Key -Name 'UninstallPath' -Value $null -Type String
        #Set-RegistryKey -Key $Key -Name 'UninstallString' -Value $null -Type String
        Set-RegistryKey -Key $Key -Name 'NoModify' -Value 1 -Type DWord
        Set-RegistryKey -Key $Key -Name 'NoRepair' -Value 1 -Type Dword

		## Display a message at the end of the install
		#If (-not $useDefaultMsi) { Show-InstallationPrompt -Message 'You can customize text to appear at the end of an install or remove it completely for unattended installations.' -ButtonRightText 'OK' -Icon Information -NoWait }
	}
	ElseIf ($deploymentType -ieq 'Uninstall')
	{
		##*===============================================
		##* PRE-UNINSTALLATION
		##*===============================================
		[string]$installPhase = 'Pre-Uninstallation'

		## Show Welcome Message, close Internet Explorer with a 300 second countdown before automatically closing
		Show-InstallationWelcome -CloseApps 'Tvsukernel' -CloseAppsCountdown 300

		## Show Progress Message (with the default message)
		Show-InstallationProgress

		## <Perform Pre-Uninstallation tasks here>


		##*===============================================
		##* UNINSTALLATION
		##*===============================================
		[string]$installPhase = 'Uninstallation'

		## Handle Zero-Config MSI Uninstallations
		If ($useDefaultMsi) {
			[hashtable]$ExecuteDefaultMSISplat =  @{ Action = 'Uninstall'; Path = $defaultMsiFile }; If ($defaultMstFile) { $ExecuteDefaultMSISplat.Add('Transform', $defaultMstFile) }
			Execute-MSI @ExecuteDefaultMSISplat
		}

		# <Perform Uninstallation tasks here>


		##*===============================================
		##* POST-UNINSTALLATION
		##*===============================================
		[string]$installPhase = 'Post-Uninstallation'

		## <Perform Post-Uninstallation tasks here>
        if($Is64Bit) {
        	$ProgramFiles = $envProgramFilesX86
        	$RegRootPath = Get-Item -Path 'HKLM:\SOFTWARE\WOW6432Node' | Select-Object -ExpandProperty Name
        }
        else {
        	$ProgramFiles = $envProgramFiles
        	$RegRootPath = Get-Item -Path 'HKLM:\SOFTWARE' | Select-Object -ExpandProperty Name
        }
        
        $Key = $(Join-path -Path $RegRootPath -ChildPath "\Microsoft\Windows\CurrentVersion\Uninstall\$appName")
        Remove-RegistryKey -Key $Key -Recurse

	}
	ElseIf ($deploymentType -ieq 'Repair')
	{
		##*===============================================
		##* PRE-REPAIR
		##*===============================================
		[string]$installPhase = 'Pre-Repair'

		## Show Progress Message (with the default message)
		Show-InstallationProgress

		## <Perform Pre-Repair tasks here>

		##*===============================================
		##* REPAIR
		##*===============================================
		[string]$installPhase = 'Repair'

		## Handle Zero-Config MSI Repairs
		If ($useDefaultMsi) {
			[hashtable]$ExecuteDefaultMSISplat =  @{ Action = 'Repair'; Path = $defaultMsiFile; }; If ($defaultMstFile) { $ExecuteDefaultMSISplat.Add('Transform', $defaultMstFile) }
			Execute-MSI @ExecuteDefaultMSISplat
		}
		# <Perform Repair tasks here>

		##*===============================================
		##* POST-REPAIR
		##*===============================================
		[string]$installPhase = 'Post-Repair'

		## <Perform Post-Repair tasks here>


    }
	##*===============================================
	##* END SCRIPT BODY
	##*===============================================

	## Call the Exit-Script function to perform final cleanup operations
	Exit-Script -ExitCode $mainExitCode
}
Catch {
	[int32]$mainExitCode = 60001
	[string]$mainErrorMessage = "$(Resolve-Error)"
	Write-Log -Message $mainErrorMessage -Severity 3 -Source $deployAppScriptFriendlyName
	Show-DialogBox -Text $mainErrorMessage -Icon 'Stop'
	Exit-Script -ExitCode $mainExitCode
}
