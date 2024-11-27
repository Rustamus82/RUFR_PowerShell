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
	[string]$appName = 'Reset Outlook-Skype Profile and Windows Credentials'
	[string]$appVersion = ''
	[string]$appArch = ''
	[string]$appLang = 'EN'
	[string]$appRevision = '01'
	[string]$appScriptVersion = '1.0.1'
	[string]$appScriptDate = '28/10/2020'
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
		Show-InstallationWelcome -CloseApps 'winword,excel,powerpnt,Outlook,lync,OneDrive,OneNote,teams,Busylight' -AllowDefer -DeferTimes 3 -CheckDiskSpace -PromptToSave 
        
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
        #Remove default Outlook profile: https://cloudrain.in/clients/index.php/knowledgebase/24/Powershell-Script-to-remove-the-Default-outlook-Profile-in-user-machines.html?language=french
        $outlookApplication = New-Object -ComObject ‘Outlook.Application’

        #read default profile:
        $profileName = $outlookApplication.Application.DefaultProfileName
        $profileRoot16 = “HKCU:\Software\Microsoft\Office\16.0\Outlook\Profiles”
        $profileRoot15 = “HKCU:\Software\Microsoft\Office\15.0\Outlook\Profiles”
        
         
        
        if (Test-Path $profileRoot15){
        
            $outlookProfile15 = Join-Path -Path $profileRoot15 -Childpath $profileName
        
        }
        
        if (Test-Path $profileRoot16){
        
            $outlookProfile16 = Join-Path -Path $profileRoot16 -Childpath $profileName
        
        }
        

        if (test-path $profileRoot15){
               
        
            Remove-Item “$outlookProfile15\*” -force -Recurse 
        
        }
        
        if (test-path $profileRoot16){
        
            Remove-Item “$outlookProfile16\*” -force -Recurse
        
        }

        Get-Process Outlook -ErrorAction SilentlyContinue| Stop-Process -ErrorAction SilentlyContinue

        if(Test-Path "$env:LOCALAPPDATA\Microsoft\Outlook") {
            
            Get-Process Outlook -ErrorAction SilentlyContinue| Stop-Process -ErrorAction SilentlyContinue
            sleep 5
            Get-ChildItem -Path "$env:LOCALAPPDATA\Microsoft\Outlook" | Where-Object {$_.name -like "*.ost"} | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue  
            Get-ChildItem -Path "$env:LOCALAPPDATA\Microsoft\Outlook" | Where-Object {$_.name -like "*.nst"} | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
        }

        <# Preformes removal of saved credentials
        #Install-Module -Name CredentialManager
        Get-Command -Module CredentialManager
        #Import-Module -Name CredentialManager
        #help Remove-StoredCredential -Detailed
        #Remove-Module -Name CredentialManager
        #Get-InstalledModule -Name CredentialManager | Uninstall-Module        
        #>

        #[downloaded from https://psg-prod-eastus.azureedge.net/packages/credentialmanager.2.0.0.nupkg]
        #Install-Module -Name CredentialManager 
        
        Import-Module ((Get-ChildItem "$dirFiles" -Recurse -Filter "CredentialManager.psd1").FullName)
        
        
        $creds =  Get-StoredCredential -AsCredentialObject
        #$creds.Count
        foreach ($item in $creds)
        {
            #$item.Type
            Remove-StoredCredential -Target $item.TargetName -ErrorAction SilentlyContinue
        }        
        

        # what following does for one current profile - clears lync/skype cache for Office 2016 and office 365
        if(Test-Path "$env:LOCALAPPDATA\Microsoft\Office\16.0\Lync\" ){
        
            Get-ChildItem -Path "$env:LOCALAPPDATA\Microsoft\Office\16.0\Lync\" | Where-Object {$_.name -like "*sip*"} | Remove-Item -Recurse -ErrorAction SilentlyContinue  

        }

        if(Test-Path "$env:LOCALAPPDATA\Microsoft\Office\16.0\Lync\Tracing"){
        
            Get-Process Outlook -ErrorAction SilentlyContinue| Stop-Process -ErrorAction SilentlyContinue
            Get-Process lync -ErrorAction SilentlyContinue| Stop-Process -ErrorAction SilentlyContinue
            sleep 5
            Remove-Item -Path "$env:LOCALAPPDATA\Microsoft\Office\16.0\Lync\Tracing\OCAddin\*" -Recurse -Force -ErrorAction SilentlyContinue
            Remove-Item -Path "$env:LOCALAPPDATA\Microsoft\Office\16.0\Lync\Tracing\*" -Recurse -Force -ErrorAction SilentlyContinue
        }

        # what following does for one current profile - clears lync/skype cache for Office 2013
        if(Test-Path "$env:LOCALAPPDATA\Microsoft\Office\15.0\Lync\" ){
        
            Get-ChildItem -Path "$env:LOCALAPPDATA\Microsoft\Office\15.0\Lync\" | Where-Object {$_.name -like "*sip*"} | Remove-Item -Recurse -ErrorAction SilentlyContinue  

        }

        if(Test-Path "$env:LOCALAPPDATA\Microsoft\Office\15.0\Lync\Tracing"){
        
            Get-Process Outlook -ErrorAction SilentlyContinue| Stop-Process -ErrorAction SilentlyContinue
            Get-Process lync -ErrorAction SilentlyContinue| Stop-Process -ErrorAction SilentlyContinue
            sleep 5
            Remove-Item -Path "$env:LOCALAPPDATA\Microsoft\Office\15.0\Lync\Tracing\OCAddin\*" -Recurse -Force -ErrorAction SilentlyContinue
            Remove-Item -Path "$env:LOCALAPPDATA\Microsoft\Office\15.0\Lync\Tracing\*" -Recurse -Force -ErrorAction SilentlyContinue
        }
 

        Get-Process Outlook -ErrorAction SilentlyContinue| Stop-Process -ErrorAction SilentlyContinue
        
		##*===============================================
		##* POST-INSTALLATION
		##*===============================================
		[string]$installPhase = 'Post-Installation'
        Remove-Module -Name CredentialManager -Force -ErrorAction SilentlyContinue
        #& gpupdate /force
                
        & shutdown -r -f -t 20 /c "Din PC vil bliver genstartet, Husk at gemme din Data og lukke alle andre programmer, ikke gemte data bliver tabt! Mvh. IOS Drift og Support"
        #& shutdown -a
        Show-InstallationPrompt -Message 'Din PC genstartes om 20 sekunder' -ButtonRightText 'OK' -Icon Information -NoWait

		## <Perform Post-Installation tasks here>

		## Display a message at the end of the install
		#If (-not $useDefaultMsi) { Show-InstallationPrompt -Message '' -ButtonRightText 'OK' -Icon Information -NoWait  }
	}
	ElseIf ($deploymentType -ieq 'Uninstall')
	{
		##*===============================================
		##* PRE-UNINSTALLATION
		##*===============================================
		[string]$installPhase = 'Pre-Uninstallation'

		## Show Welcome Message, close Internet Explorer with a 60 second countdown before automatically closing
		Show-InstallationWelcome -CloseApps 'winword,excel,powerpnt,Outlook,lync,OneDrive,OneNote,teams,Busylight' -AllowDefer -DeferTimes 3 -CheckDiskSpace -PromptToSave -ForceCloseAppsCountdown 300
        

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
