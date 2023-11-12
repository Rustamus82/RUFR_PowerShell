<#
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
	[ValidateSet('Install','Uninstall')]
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
	[string]$appName = 'RSAT AdminTools windows 10. v1709 or later'
	[string]$appVersion = '1.0.0'
    [string]$appArch = '64-bit'    
	[string]$appLang = 'en-US' #country codes: & "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe" --%  https://msdn.microsoft.com/en-us/library/ee825488(v=cs.20).aspx  en-US = 1033
	[string]$appRevision = '01'
	[string]$appScriptVersion = '1.0.1'
	[string]$appScriptDate = '29/07/2019'
	[string]$appScriptAuthor = 'Rust@m'
    [string]$ProductCode = ''
    [string]$installFile = ""
	##*===============================================
	## Variables: Install Titles (Only set here to override defaults set by the toolkit)
	[string]$installName = "$appName"
	[string]$installTitle = "$appName"
	
	##* Do not modify section below
	#region DoNotModify
	
	## Variables: Exit Code
	[int32]$mainExitCode = 0
	
	## Variables: Script
	[string]$deployAppScriptFriendlyName = 'Deploy Application'
	[version]$deployAppScriptVersion = [version]'3.7.0'
	[string]$deployAppScriptDate = '02/13/2018'
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
		
	If ($deploymentType -ine 'Uninstall') {
		##*===============================================
		##* PRE-INSTALLATION
		##*===============================================
		[string]$installPhase = 'Pre-Installation'

		## Show Welcome Message, close Internet Explorer if required, allow up to 3 deferrals, verify there is enough disk space to complete the install, and persist the prompt
		Show-InstallationWelcome -CloseApps 'mmc' -CheckDiskSpace -PersistPrompt -ForceCloseAppsCountdown 300
		
		## Show Progress Message (with the default message)
		Show-InstallationProgress
		
		## <Perform Pre-Installation tasks here>
		Remove-Item -Path "$env:SystemDrive\Runas" -Recurse -Force
		
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
        #in the future can be used this: https://mikefrobbins.com/2018/10/03/use-powershell-to-install-the-remote-server-administration-tools-rsat-on-windows-10-version-1809/
            
        Copy-Item -Path "$dirFiles\Runas" -Destination "$env:SystemDrive\" -Recurse -Force
        
        #https://en.wikipedia.org/wiki/Windows_10_version_history

        <# Win 10 version 1803
        if([version](Get-CimInstance Win32_OperatingSystem).Version -ge [version]"10.0.17134" -and [version](Get-CimInstance Win32_OperatingSystem).Version -lt [version]"10.0.17763"){
            #virkede ikke fra $dirfiles skulle være lokalt på PC først
            Start-Process -FilePath wusa.exe -ArgumentList  "$env:SystemDrive\Runas\WindowsTH-RSAT_WS_1803-x64.msu /quiet /norestart" -Wait
        }
        #>

        # Win 10 version 1809, 1903 og derefter
        if([version](Get-CimInstance Win32_OperatingSystem).Version -ge [version]"10.0.17763" -and [version](Get-CimInstance Win32_OperatingSystem).Version -lt [version]"10.9.9999.999"){
            
            Get-WindowsCapability -Online | Where-Object {($_.State -notmatch 'Installed') -and ($_.Name -match 'rsat')} | %{Add-WindowsCapability -Name $_.Name -Online}
            Get-WindowsCapability -Online | Where-Object {($_.State -notmatch 'Installed') -and ($_.Name -match 'rsat')} | %{Add-WindowsCapability -Name $_.Name -Online}
            Update-Help -Force -ErrorAction SilentlyContinue
        }

        
        
		##*===============================================
		##* POST-INSTALLATION
		##*===============================================
		[string]$installPhase = 'Post-Installation'
		
		## <Perform Post-Installation tasks here>
		Set-RegistryKey -Key 'HKEY_LOCAL_MACHINE\Software\SDS\RSAT' -Name "Version" -Value $appVersion -Type String
        
		## Display a message at the end of the install
		#If (-not $useDefaultMsi) { Show-InstallationPrompt -Message 'You can customize text to appear at the end of an install or remove it completely for unattended installations.' -ButtonRightText 'OK' -Icon Information -NoWait }
	}
	ElseIf ($deploymentType -ieq 'Uninstall')
	{
		##*===============================================
		##* PRE-UNINSTALLATION
		##*===============================================
		[string]$installPhase = 'Pre-Uninstallation'
		
		## Show Welcome Message, close Internet Explorer with a 60 second countdown before automatically closing
		Show-InstallationWelcome -CloseApps 'mmc' -ForceCloseAppsCountdown 300
		
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
        # Win 10 version 1809, 1903 og derefter
        if([version](Get-CimInstance Win32_OperatingSystem).Version -ge [version]"10.0.17763" -and [version](Get-CimInstance Win32_OperatingSystem).Version -lt [version]"10.0.18945"){
            
            Get-WindowsCapability -Online | Where-Object {($_.State -match 'Installed') -and ($_.Name -match 'rsat')} | %{Remove-WindowsCapability -Name $_.Name -Online -ErrorAction SilentlyContinue}
            Update-Help -Force -ErrorAction SilentlyContinue
        }

        #KB2693643 1709
        #KB2693643 1803 ???

        # Win10 1709
        if([version](Get-CimInstance Win32_OperatingSystem).Version -ge [version]"10.0.16299" -and [version](Get-CimInstance Win32_OperatingSystem).Version -lt [version]"10.0.17134"){
            
            #virkede ikke fra $dirfiles skulle være lokalt på PC først
            Start-Process -FilePath wusa.exe -ArgumentList "$env:SystemDrive\Runas\WindowsTH-RSAT_WS_1709-x64.msu /uninstall /quiet /norestart" -Wait
            #Start-Process -FilePath wusa.exe -ArgumentList "/uninstall KB:2693643 /quiet /norestart" -Wait
        }

        # Win 10 version 1803
        if([version](Get-CimInstance Win32_OperatingSystem).Version -ge [version]"10.0.17134" -and [version](Get-CimInstance Win32_OperatingSystem).Version -lt [version]"10.0.17763"){
            #virkede ikke fra dirfiles skulle være lokalt på PC først
            
            Start-Process -FilePath wusa.exe -ArgumentList "$env:SystemDrive\Runas\WindowsTH-RSAT_WS_1803-x64.msu /uninstall /quiet /norestart" -Wait
            #Start-Process -FilePath wusa.exe -ArgumentList "/uninstall KB:2693643 /quiet /norestart" -Wait
        }
       
		##*===============================================
		##* POST-UNINSTALLATION
		##*===============================================
		[string]$installPhase = 'Post-Uninstallation'
		
		## <Perform Post-Uninstallation tasks here>
		Set-RegistryKey -Key 'HKEY_LOCAL_MACHINE\Software\SDS\RSAT' -Name "Version" -Value '0' -Type String
        
        Remove-Item -Path "$env:SystemDrive\Runas" -Recurse -Force		

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