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
	[string]$appName = 'Clear Skype for Business Cache'
	[string]$appVersion = '1.0.1'
	[string]$appArch = ''
	[string]$appLang = 'EN'
	[string]$appRevision = '01'
	[string]$appScriptVersion = '1.0.1'
	[string]$appScriptDate = '05/02/2021'
	[string]$appScriptAuthor = 'Rust@m'
    [string]$ProductCode = ''
    [string]$installFile = ""
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
	[version]$deployAppScriptVersion = [version]'3.8.3'
	[string]$deployAppScriptDate = '30/09/2020'
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
		Show-InstallationWelcome -CloseApps 'outlook,lync' -CheckDiskSpace -PersistPrompt

		## Show Progress Message (with the default message)
		Show-InstallationProgress

		## <Perform Pre-Installation tasks here>


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
        <# what following does for one current profile
        if(Test-Path "$env:LOCALAPPDATA\Microsoft\Office\16.0\Lync\" ){
        
            Get-ChildItem -Path "$env:LOCALAPPDATA\Microsoft\Office\16.0\Lync\" | Where-Object {$_.name -like "*sip*"} | Remove-Item -Recurse -ErrorAction Continue      

        }

        if(Test-Path "$env:LOCALAPPDATA\Microsoft\Office\16.0\Lync\Tracing"){
        
            Remove-Item -Path "$env:LOCALAPPDATA\Microsoft\Office\16.0\Lync\Tracing\*" -Recurse -Force
        
        }
        #>
        
        
        #Deleteing content and Executing for each user. [-Recurse must be if there is many files in deleted folders toherwise it will hang with confirmations which you will never see!]
        If($IsLocalSystemAccount){
            #$UserProfileFolders = Get-ChildItem -Path "$env:SystemDrive\Users\*"
            $UserProfileFolders = Get-UserProfiles -ExcludeSystemProfiles $true
            foreach ($folder in $UserProfileFolders.ProfilePath) { 
                $settings = Join-Path -Path $folder -ChildPath 'AppData\Local\Microsoft\Office\16.0\Lync'
                New-Item -Path $settings -ItemType Directory -Force -ErrorAction SilentlyContinue
                Get-ChildItem -Path "$settings" | Where-Object {$_.name -like "*sip*"} |Remove-Item -Recurse -ErrorAction Continue 
                Remove-Item -Path "$settings\Tracing\*" -Recurse -Force -ErrorAction SilentlyContinue

            }
        } Else {
            $settings = Join-Path -Path $env:LOCALAPPDATA -ChildPath 'Microsoft\Office\16.0\Lync\'
            New-Item -Path $settings -ItemType Directory -Force -ErrorAction SilentlyContinue
            Get-ChildItem -Path "$settings" | Where-Object {$_.name -like "*sip*"} |Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
            Remove-Item -Path "$settings\Tracing\*" -Recurse -Force -ErrorAction SilentlyContinue
        }

        <# For one user wiht if detecttion and test
        if((Get-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Office\16.0\Lync').EcsConfigStarts -eq "00000000") {

           Set-RegistryKey -Key 'HKCU:\SOFTWARE\Microsoft\Office\16.0\Lync\' -Name 'EcsConfigStarts' -Value '00000001'
           Set-RegistryKey -Key 'HKCU:\SOFTWARE\Microsoft\Office\16.0\Lync\' -Name 'ConfigurationMode' -Value '00000000'
           #here I remover else preffered server srv-lync-fe03.ssi.ad
           Set-RegistryKey -Key 'HKCU:\SOFTWARE\Microsoft\Office\16.0\Lync\' -Name 'ServerAddressInternal' -Value ''
        }
        #>
        
        [scriptblock]$HKCURegistrySettings = {

           Set-RegistryKey -Key 'HKCU:\SOFTWARE\Microsoft\Office\16.0\Lync\' -Name 'EcsConfigStarts' -Value '00000001' -SID $UserProfile.SID -ContinueOnError $true
           Set-RegistryKey -Key 'HKCU:\SOFTWARE\Microsoft\Office\16.0\Lync\' -Name 'ConfigurationMode' -Value '00000000' -SID $UserProfile.SID -ContinueOnError $true
           #here I remover else preffered server srv-lync-fe03.ssi.ad
           Set-RegistryKey -Key 'HKCU:\SOFTWARE\Microsoft\Office\16.0\Lync\' -Name 'ServerAddressInternal' -Value '' -SID $UserProfile.SID -ContinueOnError $true
        }

        Invoke-HKCURegistrySettingsForAllUsers -RegistrySettings $HKCURegistrySettings

		##*===============================================
		##* POST-INSTALLATION
		##*===============================================
		[string]$installPhase = 'Post-Installation'

		## <Perform Post-Installation tasks here>
        
        #clear DNS cache can be runs only when psadt runs as admin
        Clear-DnsClientCache
        #Get-DnsClientCache

        sleep 5
                
        #When psadt runs as admin but start process for user
        Execute-ProcessAsUser -Path $Env:ComSpec -Parameters "cmd /C start lync.exe"
        #Execute-ProcessAsUser -Path $Env:ComSpec -Parameters "cmd /C start Outlook.exe"

        #For users
        #Start-Process Lync


		## Display a message at the end of the install
		#If (-not $useDefaultMsi) { Show-InstallationPrompt -Message 'Din skype cahce blevet nulstillet' -ButtonRightText 'OK' -Icon Information -NoWait }
	}
	ElseIf ($deploymentType -ieq 'Uninstall')
	{
		##*===============================================
		##* PRE-UNINSTALLATION
		##*===============================================
		[string]$installPhase = 'Pre-Uninstallation'

		## Show Welcome Message, close Internet Explorer with a 60 second countdown before automatically closing
		Show-InstallationWelcome -CloseApps 'outlook,lync' -CloseAppsCountdown 300

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