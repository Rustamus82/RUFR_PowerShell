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
	[string]$appName = 'Delete Windows Credentials and reset Outlook profile'
	[string]$appVersion = '1.0.0'
    [string]$appArch = 'n/a'    
	[string]$appLang = 'en-US' #country codes: & "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe" --%  https://msdn.microsoft.com/en-us/library/ee825488(v=cs.20).aspx  en-US = 1033
	[string]$appRevision = '01'
	[string]$appScriptVersion = '1.0.0'
	[string]$appScriptDate = '19/07/2018'
	[string]$appScriptAuthor = 'EKS-@NAE'
    [string]$ProductCode = ''
    [string]$installFile = ""
	##*===============================================
	## Variables: Install Titles (Only set here to override defaults set by the toolkit)
	[string]$installName = 'MyCompany - Delete Windows Credentials'
	[string]$installTitle = 'Delete Windows Credentials'
	
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

        ## Show Welcome Message
        #NB. Jeg kan ikke få programmet til at køre, hvis jeg inkorporerer 'Show-InstallationWelcome' og 'Show-InstallationProgress'!!
        Show-InstallationWelcome -CloseApps 'NoAppToClose' -ForceCloseAppsCountdown 30
        ## Show Progress Message (with the default message)
		Show-InstallationProgress

		
		
		## <Perform Pre-Installation tasks here>
		#Kalder brugeren og skiller domænenavnet fra det 'rene' brugernavn.
        [String] $stUserDomain,[String]  $CurrentUserAccount = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name.split("\")

        Set-Location -Path 'C:'
        
        #Lukker Windowsapplikationer.

        Stop-Process -Name "Outlook" -Force -ErrorAction SilentlyContinue
        Stop-Process -Name "winword" -Force -ErrorAction SilentlyContinue
        Stop-Process -Name "excel" -Force -ErrorAction SilentlyContinue
        Stop-Process -Name "powerpnt" -Force -ErrorAction SilentlyContinue
        Stop-Process -Name "iexplore" -Force -ErrorAction SilentlyContinue
        Stop-Process -Name "lync" -Force -ErrorAction SilentlyContinue

		
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
        #Sletter Lync/Skype for Business settings Office 2016
        Set-Location -Path C:\Users\$CurrentUserAccount\AppData\Local\Microsoft\Office\16.0\Lync\ -ErrorAction SilentlyContinue
        Get-ChildItem -Recurse -Filter sip*| Remove-Item -Recurse -ErrorAction SilentlyContinue
        Remove-Item -Path "C:\Users\$CurrentUserAccount\AppData\Local\Microsoft\Office\16.0\Lync\Tracing\*.*" -Recurse -ErrorAction SilentlyContinue
        Get-ChildItem -Path "C:\Users\$CurrentUserAccount\AppData\Local\Microsoft\Office\16.0\Lync\Tracing\" -Recurse | Remove-Item -Recurse -ErrorAction SilentlyContinue

        #Sletter Lync/Skype for Business settings Office 2013
        Set-Location -Path C:\Users\$CurrentUserAccount\AppData\Local\Microsoft\Office\15.0\Lync\ -ErrorAction SilentlyContinue
        Get-ChildItem -Recurse -Filter sip*| Remove-Item -Recurse -ErrorAction SilentlyContinue
        Remove-Item -Path "C:\Users\$CurrentUserAccount\AppData\Local\Microsoft\Office\15.0\Lync\Tracing\*.*" -Recurse -ErrorAction SilentlyContinue
        Get-ChildItem -Path "C:\Users\$CurrentUserAccount\AppData\Local\Microsoft\Office\15.0\Lync\Tracing\" -Recurse | Remove-Item -Recurse -ErrorAction SilentlyContinue

        #Gendanner ipconfig/flusher DNS.
        Clear-DnsClientCache

        #Sletter Windowslegitmationsoplysninger.
        Remove-Item -Path C:\Users\$CurrentUserAccount\AppData\Roaming\Microsoft\Credentials -Recurse -Force
        #Sletter ost-filen for current user.
        Remove-Item -Path C:\Users\$CurrentUserAccount\AppData\Local\Microsoft\Outlook\$CurrentUserAccount@*.*.ost		

		sleep 5
		##*===============================================
		##* POST-INSTALLATION
		##*===============================================
		[string]$installPhase = 'Post-Installation'
		
		## <Perform Post-Installation tasks here>
        #Tjekker om Concierge findes i registry.
        Set-Location -Path 'HKCU:'

        $Concierge = 'HKCU:\Software\Fischer & Kerrn'
        $ConciergePath = Test-Path $Concierge
        If ($ConciergePath -eq $False) {
        Sleep 5
        }
        Else {
        #Retter alle Conciergerelaterede registry keys. 

        Set-Itemproperty -Path 'HKEY_CURRENT_USER\Software\Fischer & Kerrn\FKConcAs' -Name "EWSURL" -Type string -Value "https://outlook.office365.com/EWS/Exchange.asmx" -ErrorAction SilentlyContinue
        
        Set-Itemproperty -Path 'HKEY_CURRENT_USER\Software\Fischer & Kerrn\FKConcAs' -Name "ForceCredentialsPrompt" -type dword -value "00000001" -ErrorAction SilentlyContinue
        
        Set-Itemproperty -Path 'HKEY_CURRENT_USER\Software\Fischer & Kerrn\FKConcAs' -Name "EWSVersion" -type string -value "Exchange2013" -ErrorAction SilentlyContinue

        Set-Itemproperty -Path 'HKEY_CURRENT_USER\Software\Fischer & Kerrn\FKConcAs' -Name "autodiscoverdisabled" -type dword -value "00000000" -ErrorAction SilentlyContinue
        
        Set-Itemproperty -Path 'HKEY_CURRENT_USER\Software\Fischer & Kerrn\FKConcAs' -Name "UPNSuffix" -type string -value "dksund.dk" -ErrorAction SilentlyContinue
        
        Set-Itemproperty -Path 'HKEY_CURRENT_USER\Software\Fischer & Kerrn A/S\Concierge Services Storage\Settings' -Name "UseWebService" -type dword -value "00000001" -ErrorAction SilentlyContinue
        Set-Itemproperty -Path 'HKEY_CURRENT_USER\Software\Fischer & Kerrn A/S\Concierge Services Storage\Settings' -Name "ForceUpdate" -type dword -value "00000001" -ErrorAction SilentlyContinue
        }
        
        #Fjerner alle registreringer under outlookprofiler for current user i regedit.
        Set-Location -Path 'HKCU:' | Out-Host
        Remove-Item -Path .\Software\Microsoft\Office\15.0\Outlook\Profiles\ -Recurse -ErrorAction SilentlyContinue
        Remove-Item -Path .\Software\Microsoft\Office\16.0\Outlook\Profiles\ -Recurse -ErrorAction SilentlyContinue
        
        #Registrerer dette program i Regedit.
        Set-Location -Path 'HKCU:'
		Set-RegistryKey -Key 'HKEY_Current_User\Software\SDS\Delete Windows Credentials' -Name "Version" -Value $appVersion -Type String
        Show-InstallationProgress "Din PC bliver genstartet om 60 sekunder. Husk at gemme dine data og lukke alle andre programmer, da ikke gemte data bliver tabt! Mvh. IOS Drift og Support!"
        sleep 60
        Restart-Computer
        
		## Display a message at the end of the install
		#If (-not $useDefaultMsi) { Show-InstallationPrompt -Message 'You can customize text to appear at the end of an install or remove it completely for unattended installations.' -ButtonRightText 'OK' -Icon Information -NoWait }
	}
	ElseIf ($deploymentType -ieq 'Uninstall')
	{
		##*===============================================
		##* PRE-UNINSTALLATION
		##*===============================================
		[string]$installPhase = 'Pre-Uninstallation'
		
		## Show Welcome Message
        #NB. Jeg kan ikke få programmet til at køre, hvis jeg inkorporerer 'Show-InstallationWelcome' og 'Show-InstallationProgress'!!
        Show-InstallationWelcome -CloseApps 'NoAppToClose' -ForceCloseAppsCountdown 30
        ## Show Progress Message (with the default message)
		Show-InstallationProgress

		
		## <Perform Pre-UnInstallation tasks here>
        #Kalder brugeren og skiller domænenavnet fra det 'rene' brugernavn.
        [String] $stUserDomain,[String]  $CurrentUserAccount = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name.split("\")
        Set-Location -Path 'C:'

		#Lukker Windowsapplikationer.

        Stop-Process -Name "Outlook" -Force -ErrorAction SilentlyContinue | Out-Host
        Stop-Process -Name "winword" -Force -ErrorAction SilentlyContinue | Out-Host
        Stop-Process -Name "excel" -Force -ErrorAction SilentlyContinue | Out-Host
        Stop-Process -Name "powerpnt" -Force -ErrorAction SilentlyContinue | Out-Host
        Stop-Process -Name "iexplore" -Force -ErrorAction SilentlyContinue  | Out-Host
        Stop-Process -Name "lync" -Force -ErrorAction SilentlyContinue | Out-Host
		
		
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
        #Sletter Lync/Skype for Business settings Office 2016
        Set-Location -Path C:\Users\$CurrentUserAccount\AppData\Local\Microsoft\Office\16.0\Lync\ -ErrorAction SilentlyContinue
        Get-ChildItem -Recurse -Filter sip*| Remove-Item -Recurse -ErrorAction SilentlyContinue
        Remove-Item -Path "C:\Users\$CurrentUserAccount\AppData\Local\Microsoft\Office\16.0\Lync\Tracing\*.*" -Recurse -ErrorAction SilentlyContinue
        Get-ChildItem -Path "C:\Users\$CurrentUserAccount\AppData\Local\Microsoft\Office\16.0\Lync\Tracing\" -Recurse | Remove-Item -Recurse -ErrorAction SilentlyContinue

        #Sletter Lync/Skype for Business settings Office 2013
        Set-Location -Path C:\Users\$CurrentUserAccount\AppData\Local\Microsoft\Office\15.0\Lync\ -ErrorAction SilentlyContinue
        Get-ChildItem -Recurse -Filter sip*| Remove-Item -Recurse -ErrorAction SilentlyContinue
        Remove-Item -Path "C:\Users\$CurrentUserAccount\AppData\Local\Microsoft\Office\15.0\Lync\Tracing\*.*" -Recurse -ErrorAction SilentlyContinue
        Get-ChildItem -Path "C:\Users\$CurrentUserAccount\AppData\Local\Microsoft\Office\15.0\Lync\Tracing\" -Recurse | Remove-Item -Recurse -ErrorAction SilentlyContinue

        #Gendanner ipconfig/flusher DNS.
        Clear-DnsClientCache

		#Sletter Windowslegitmationsoplysninger.
        Remove-Item -Path C:\Users\$CurrentUserAccount\AppData\Roaming\Microsoft\Credentials -Recurse -Force
        #Sletter ost-filen for current user.
        Remove-Item -Path C:\Users\$CurrentUserAccount\AppData\Local\Microsoft\Outlook\$CurrentUserAccount@*.*.ost		

		##*===============================================
		##* POST-UNINSTALLATION
		##*===============================================
		[string]$installPhase = 'Post-Uninstallation'
		
		## <Perform Post-Uninstallation tasks here>
        Set-Location -Path 'HKCU:'
        $Concierge = 'HKCU:\Software\Fischer & Kerrn'
        $ConciergePath = Test-Path $Concierge
        If ($ConciergePath -eq $False) {
        Sleep 5
        }
        Else {
        #Retter alle Conciergerelaterede registry keys. 

        Set-Itemproperty -Path 'HKEY_CURRENT_USER\Software\Fischer & Kerrn\FKConcAs' -Name "EWSURL" -PropertyType string -Value "https://outlook.office365.com/EWS/Exchange.asmx" -ErrorAction SilentlyContinue
        
        Set-Itemproperty -Path 'HKEY_CURRENT_USER\Software\Fischer & Kerrn\FKConcAs' -Name "ForceCredentialsPrompt" -type dword -value "00000001" -ErrorAction SilentlyContinue
        
        Set-Itemproperty -Path 'HKEY_CURRENT_USER\Software\Fischer & Kerrn\FKConcAs' -Name "EWSVersion" -type string -value "Exchange2013" -ErrorAction SilentlyContinue

        Set-Itemproperty -Path 'HKEY_CURRENT_USER\Software\Fischer & Kerrn\FKConcAs' -Name "autodiscoverdisabled" -type dword -value "00000000" -ErrorAction SilentlyContinue
        
        Set-Itemproperty -Path 'HKEY_CURRENT_USER\Software\Fischer & Kerrn\FKConcAs' -Name "UPNSuffix" -type string -value "dksund.dk" -ErrorAction SilentlyContinue
        
        Set-Itemproperty -Path 'HKEY_CURRENT_USER\Software\Fischer & Kerrn A/S\Concierge Services Storage\Settings' -Name "UseWebService" -type dword -value "00000001" -ErrorAction SilentlyContinue
        Set-Itemproperty -Path 'HKEY_CURRENT_USER\Software\Fischer & Kerrn A/S\Concierge Services Storage\Settings' -Name "ForceUpdate" -type dword -value "00000001" -ErrorAction SilentlyContinue
        }

        #Fjerner alle registreringer under outlookprofiler for current user i regedit.
        Set-Location -Path 'HKCU:' | Out-Host
        Remove-Item -Path .\Software\Microsoft\Office\15.0\Outlook\Profiles\ -Recurse -ErrorAction SilentlyContinue
        Remove-Item -Path .\Software\Microsoft\Office\16.0\Outlook\Profiles\ -Recurse -ErrorAction SilentlyContinue
        

        #Registrerer dette program i Regedit.
        Set-Location -Path 'HKCU:'
		Set-RegistryKey -Key 'HKEY_Current_User\Software\SDS\Delete Windows Credentials and reset Outlook profile' -Name "Version" -Value '0' -Type String
        Show-InstallationProgress "Din PC bliver genstartet om 60 sekunder. Husk at gemme dine data og lukke alle andre programmer, da ikke gemte data bliver tabt! Mvh. IOS Drift og Support!"
        sleep 60
        Restart-Computer
		
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