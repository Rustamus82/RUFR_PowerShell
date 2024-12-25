<#
.SYNOPSIS

PSApppDeployToolkit - This script performs the installation or uninstallation of an application(s).

.DESCRIPTION

- The script is provided as a template to perform an install or uninstall of an application(s).
- The script either performs an "Install" deployment type or an "Uninstall" deployment type.
- The install deployment type is broken down into 3 main sections/phases: Pre-Install, Install, and Post-Install.

The script dot-sources the AppDeployToolkitMain.ps1 script which contains the logic and functions required to install or uninstall an application.

PSApppDeployToolkit is licensed under the GNU LGPLv3 License - (C) 2024 PSAppDeployToolkit Team (Sean Lillis, Dan Cunningham and Muhammad Mashwani).

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Lesser General Public License as published by the
Free Software Foundation, either version 3 of the License, or any later version. This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License
for more details. You should have received a copy of the GNU Lesser General Public License along with this program. If not, see <http://www.gnu.org/licenses/>.

.PARAMETER DeploymentType

The type of deployment to perform. Default is: Install.

.PARAMETER DeployMode

Specifies whether the installation should be run in Interactive, Silent, or NonInteractive mode. Default is: Interactive. Options: Interactive = Shows dialogs, Silent = No dialogs, NonInteractive = Very silent, i.e. no blocking apps. NonInteractive mode is automatically set if it is detected that the process is not user interactive.

.PARAMETER AllowRebootPassThru

Allows the 3010 return code (requires restart) to be passed back to the parent process (e.g. SCCM) if detected from an installation. If 3010 is passed back to SCCM, a reboot prompt will be triggered.

.PARAMETER TerminalServerMode

Changes to "user install mode" and back to "user execute mode" for installing/uninstalling applications for Remote Desktop Session Hosts/Citrix servers.

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

.INPUTS

None

You cannot pipe objects to this script.

.OUTPUTS

None

This script does not generate any output.

.NOTES

Toolkit Exit Code Ranges:
- 60000 - 68999: Reserved for built-in exit codes in Deploy-Application.ps1, Deploy-Application.exe, and AppDeployToolkitMain.ps1
- 69000 - 69999: Recommended for user customized exit codes in Deploy-Application.ps1
- 70000 - 79999: Recommended for user customized exit codes in AppDeployToolkitExtensions.ps1

.LINK

https://psappdeploytoolkit.com
#>


[CmdletBinding()]
Param (
    [Parameter(Mandatory = $false)]
    [ValidateSet('Install', 'Uninstall', 'Repair')]
    [String]$DeploymentType = 'Install',
    [Parameter(Mandatory = $false)]
    [ValidateSet('Interactive', 'Silent', 'NonInteractive')]
    [String]$DeployMode = 'Interactive',
    [Parameter(Mandatory = $false)]
    [switch]$AllowRebootPassThru = $false,
    [Parameter(Mandatory = $false)]
    [switch]$TerminalServerMode = $false,
    [Parameter(Mandatory = $false)]
    [switch]$DisableLogging = $false
)

Try {
    ## Set the script execution policy for this process
    Try {
        Set-ExecutionPolicy -ExecutionPolicy 'ByPass' -Scope 'Process' -Force -ErrorAction 'Stop'
    } Catch {
    }

    ##*===============================================
    #region VARIABLE DECLARATION
    ##*===============================================
    ## Variables: Application
    [String]$appVendor = 'Microsoft Corporation'
    [String]$appName = 'New Teams'
    [String]$appVersion = ''
    [String]$appArch = '64-bit'
    [String]$appLang = 'EN'
    [String]$appRevision = '01'
    [String]$appScriptVersion = '1.0.9'
	[string]$appScriptAuthor = 'Rust@m'
    [string]$ProductCode = ''
    [string]$installFile = "MSTeams-x64.msix"
    ##*===============================================
    ## Variables: Install Titles (Only set here to override defaults set by the toolkit)
	[string]$installName = "$appName $appVersion"
	[string]$installTitle = "$appName $appVersion"

    ##* Do not modify section below
    #region DoNotModify

    ## Variables: Exit Code
    [Int32]$mainExitCode = 0

    ## Variables: Script
    [String]$deployAppScriptFriendlyName = 'Deploy Application'
    [Version]$deployAppScriptVersion = [Version]'3.10.2'
    [String]$deployAppScriptDate = '08/13/2024'
    [Hashtable]$deployAppScriptParameters = $PsBoundParameters

    ## Variables: Environment
    If (Test-Path -LiteralPath 'variable:HostInvocation') {
        $InvocationInfo = $HostInvocation
    }
    Else {
        $InvocationInfo = $MyInvocation
    }
    [String]$scriptDirectory = Split-Path -Path $InvocationInfo.MyCommand.Definition -Parent

    ## Dot source the required App Deploy Toolkit Functions
    Try {
        [String]$moduleAppDeployToolkitMain = "$scriptDirectory\AppDeployToolkit\AppDeployToolkitMain.ps1"
        If (-not (Test-Path -LiteralPath $moduleAppDeployToolkitMain -PathType 'Leaf')) {
            Throw "Module does not exist at the specified location [$moduleAppDeployToolkitMain]."
        }
        If ($DisableLogging) {
            . $moduleAppDeployToolkitMain -DisableLogging
        }
        Else {
            . $moduleAppDeployToolkitMain
        }
    }
    Catch {
        If ($mainExitCode -eq 0) {
            [Int32]$mainExitCode = 60008
        }
        Write-Error -Message "Module [$moduleAppDeployToolkitMain] failed to load: `n$($_.Exception.Message)`n `n$($_.InvocationInfo.PositionMessage)" -ErrorAction 'Continue'
        ## Exit the script, returning the exit code to SCCM
        If (Test-Path -LiteralPath 'variable:HostInvocation') {
            $script:ExitCode = $mainExitCode; Exit
        }
        Else {
            Exit $mainExitCode
        }
    }

    #endregion
    ##* Do not modify section above
    ##*===============================================
    #endregion END VARIABLE DECLARATION
    ##*===============================================

    If ($deploymentType -ine 'Uninstall' -and $deploymentType -ine 'Repair') {
        ##*===============================================
        ##* MARK: PRE-INSTALLATION
        ##*===============================================
        [String]$installPhase = 'Pre-Installation'

        ## Show Welcome Message, close Internet Explorer if required, allow up to 3 deferrals, verify there is enough disk space to complete the install, and persist the prompt
        #Show-InstallationWelcome -CloseApps 'ms-teams,Teams' -AllowDefer -DeferTimes 3 -CheckDiskSpace -PersistPrompt
        Show-InstallationWelcome -CloseApps 'NoAppToClose' -CheckDiskSpace -ForceCloseAppsCountdown 600

        ## Show Progress Message (with the default message)
        Show-InstallationProgress

        ## <Perform Pre-Installation tasks here>
        <#            
            #As Admin
            Get-AppxPackage -AllUsers | ft name, PackageFullName -AutoSize
            
            #As normal user
            Get-AppxPackage | ft name, PackageFullName -AutoSize
            
            $Package = Get-AppXProvisionedPackage -Online | Where-Object PackageName -Like "*MSTeams*"
            #Removes for all users
            Remove-AppxProvisionedPackage -Online -AllUsers -PackageName $Package.PackageName
        #>
        <#
        $AllNewTeamsApps = @("MSTeams"
                                     )
        foreach ($item in $AllNewTeamsApps)
        {
            Get-ProvisionedAppxPackage -Online | `
            Where-Object { $_.PackageName -match "$item" } | `
            ForEach-Object { Remove-ProvisionedAppxPackage -Online -AllUsers -PackageName $_.PackageName }
        }
        #>
        
        #copy or not addins manualy to issue with addon register or unregister
        <#Now no copy and unregister
        If ($IsLocalSystemAccount) {
            $UserProfileFolders = Get-UserProfiles -ExcludeSystemProfiles $true
            foreach ($folder in $UserProfileFolders.ProfilePath) { 
                $settings = Join-Path -Path $folder -ChildPath 'AppData\Local\Microsoft'
                New-Item -Path $settings -ItemType Directory -ErrorAction SilentlyContinue
                if (Test-Path "$settings\TeamsMeetingAdd-in\1.24.19202"){Invoke-RegisterOrUnregisterDLL -FilePath "$settings\TeamsMeetingAdd-in\1.24.19202\x64\Microsoft.Teams.AddinLoader.dll" -DLLAction Unregister -ContinueOnError $true}else{Copy-File -Path "\\Filer01\ca_unicenter$\02_Application\Microsoft Corporation\Office\Teams\TeamsMeetingAdd-in" -Destination "$settings" -Recurse -ContinueOnError $true}
                #%SystemRoot%\System32\regsvr32.exe /n /i:user %LocalAppData%\Microsoft\TeamsMeetingAdd-in\1.24.19202\x64\Microsoft.Teams.AddinLoader.dll
                #Invoke-RegisterOrUnregisterDLL -FilePath "$settings\TeamsMeetingAdd-in\1.23.35502\x64\Microsoft.Teams.AddinLoader.dll" -DLLAction Unregister  -ContinueOnError $true
                #Execute-ProcessAsUser -Path "$envSystem32Directory\cmd.exe" -Parameters "/c %SystemRoot%\System32\regsvr32.exe /n /i:user %LocalAppData%\Microsoft\TeamsMeetingAdd-in\1.24.19202\x64\Microsoft.Teams.AddinLoader.dll" -ContinueOnError $true
                #Invoke-RegisterOrUnregisterDLL -FilePath "$settings\TeamsMeetingAdd-in\1.24.19202\x64\Microsoft.Teams.AddinLoader.dll" -DLLAction Register -ContinueOnError $true
            }
        } Else {
            $settings = Join-Path -Path $env:LOCALAPPDATA -ChildPath 'Microsoft'
            New-Item -Path $settings -ItemType Directory -Force -ErrorAction SilentlyContinue
            if (Test-Path "$settings\TeamsMeetingAdd-in\1.24.19202"){Invoke-RegisterOrUnregisterDLL -FilePath "$settings\TeamsMeetingAdd-in\1.24.19202\x64\Microsoft.Teams.AddinLoader.dll" -DLLAction Unregister -ContinueOnError $true}else{Copy-File -Path "\\Filer01\ca_unicenter$\02_Application\Microsoft Corporation\Office\Teams\TeamsMeetingAdd-in" -Destination "$settings" -Recurse -ContinueOnError $true}
            #%SystemRoot%\System32\regsvr32.exe /n /i:user %LocalAppData%\Microsoft\TeamsMeetingAdd-in\1.24.19202\x64\Microsoft.Teams.AddinLoader.dll
            #Invoke-RegisterOrUnregisterDLL -FilePath "$settings\TeamsMeetingAdd-in\1.23.35502\x64\Microsoft.Teams.AddinLoader.dll" -DLLAction Unregister  -ContinueOnError $true
            #Execute-ProcessAsUser -Path "$envSystem32Directory\cmd.exe" -Parameters "/c %SystemRoot%\System32\regsvr32.exe /n /i:user %LocalAppData%\Microsoft\TeamsMeetingAdd-in\1.24.19202\x64\Microsoft.Teams.AddinLoader.dll" -ContinueOnError $true
            #Invoke-RegisterOrUnregisterDLL -FilePath "$settings\TeamsMeetingAdd-in\1.24.19202\x64\Microsoft.Teams.AddinLoader.dll" -DLLAction Register -ContinueOnError $true
            #Execute-ProcessAsUser -Path "$envSystem32Directory\cmd.exe" -Parameters "/c reg delete HKEY_CURRENT_USER\SOFTWARE\Microsoft\Office\Outlook\Addins\TeamsAddin.FastConnect /v LoadBehavior /F" -ContinueOnError $true
            #Execute-ProcessAsUser -Path "$envSystem32Directory\cmd.exe" -Parameters "/c reg add HKEY_CURRENT_USER\SOFTWARE\Microsoft\Office\Outlook\Addins\TeamsAddin.FastConnect /v LoadBehavior /t REG_DWORD /d 00000003 /f" -ContinueOnError $true
            
        }   
        #>
        Remove-MSIApplications -Name 'Teams*' -WildCard -FilterApplication (,('Publisher','Microsoft*','WildCard')) -ContinueOnError $true
        Remove-MSIApplications -Name 'Microsoft Teams*' -WildCard -FilterApplication (,('Publisher','Microsoft*','WildCard')) -ContinueOnError $true
        #Execute-ProcessAsUser -Path "$envSystem32Directory\msiexec.exe" -Parameters "/x `"{A7AB73A3-CB10-4AA5-9D38-6AEFFBDE4C91}`" REBOOT=ReallySuppress /QN /L*v `"C:\Windows\Logs\Software\Microsoft_MicrosoftTeamsMeetingAdd-inforMicrosoftOffice_1.24.19202_Uninstall.log`"" -ContinueOnError $true

        ##*===============================================
        ##* MARK: INSTALLATION
        ##*===============================================
        [String]$installPhase = 'Installation'

        ## Handle Zero-Config MSI Installations
        If ($useDefaultMsi) {
            [Hashtable]$ExecuteDefaultMSISplat = @{ Action = 'Install'; Path = $defaultMsiFile }; If ($defaultMstFile) {
                $ExecuteDefaultMSISplat.Add('Transform', $defaultMstFile)
            }
            Execute-MSI @ExecuteDefaultMSISplat; If ($defaultMspFiles) {
                $defaultMspFiles | ForEach-Object { Execute-MSI -Action 'Patch' -Path $_ }
            }
        }

        ## <Perform Installation tasks here>
        #for Classic Teams MSI
        #Execute-MSI -Action Install -Path "$dirFiles\$installFile" -AddParameters "ALLUSERS=`"2`""        
        #For modern app - new teams                
        #Execute-Process -Path "\\share\Teams\teamsbootstrapper.exe" -Parameters "-p -o `"\\share\Teams\$installFile`""
        Execute-Process -Path "$dirFiles\teamsbootstrapper.exe" -Parameters "-p -o `"$dirFiles\$installFile`""
        
        <#
        Get-AppXPackage -Name "*msteams*" | Select-Object -ExpandProperty Version
        #>

        ##*===============================================
        ##* MARK: POST-INSTALLATION
        ##*===============================================
        [String]$installPhase = 'Post-Installation'

        ## <Perform Post-Installation tasks here>
        Start-Sleep 10
        #EXPLORER.EXE shell:AppsFolder\MSTeams_8wekyb3d8bbwe!MSTeams
        Execute-ProcessAsUser -Path "$envSystemRoot\EXPLORER.EXE" -Parameters "shell:AppsFolder\MSTeams_8wekyb3d8bbwe!MSTeams" -RunLevel LeastPrivilege 

        #"C:\Program Files\WindowsApps\MSTeams_24295.605.3225.8804_x64__8wekyb3d8bbwe\ms-teams.exe" --register-im-provider
        Execute-Process -Path "$envProgramFiles\WindowsApps\MSTeams_24295.605.3225.8804_x64__8wekyb3d8bbwe\ms-teams.exe" -Parameters "--register-im-provider" -ContinueOnError $true

        <#Teams Meeting add-in - %localappdata%\Microsoft\TeamsMeetingAdd-in\
        #https://learn.microsoft.com/en-us/microsoftteams/new-teams-vdi-requirements-deploy      
        # Get Version of currently installed new Teams Package
        if ([bool]($NewTeamsPackageVersion = (Get-AppXPackage -AllUsers -Name *msteams*).Version)) {

            #Write-Host "Found new Teams Version: $NewTeamsPackageVersion"
            Write-Log -Message "Found new Teams Version: $NewTeamsPackageVersion" -LogType CMTrace -ErrorAction SilentlyContinue            
            $TMAVersion = $NewTeamsPackageVersion = (Get-AppXPackage -AllUsers -Name *msteams*).Version

            # Get Teams Meeting Addin Version
            $TMAPath = "{0}\WINDOWSAPPS\MSTEAMS_{1}_X64__8WEKYB3D8BBWE\MICROSOFTTEAMSMEETINGADDININSTALLER.MSI" -f $env:programfiles,$TMAVersion
            # Install parameters
            $TargetDir = "{0}\Microsoft\TeamsMeetingAddin\{1}\" -f ${env:ProgramFiles(x86)},$TMAVersion
            #per-machine
            $params = '/i "{0}" TARGETDIR="{1}" /qn ALLUSERS=2' -f $TMAPath, $TargetDir
            #per-user
            #$params = '/i "{0}" TARGETDIR="{1}" /qn' -f $TMAPath, $TargetDir
            # Start the install process
            #write-host "executing msiexec.exe $params"
            #Write-Log -Message "executing msiexec.exe $params" -LogType CMTrace -ErrorAction SilentlyContinue
            #Start-Process msiexec.exe -ArgumentList $params -ErrorAction SilentlyContinue
            Execute-Process -Path "$envSystem32Directory\msiexec.exe" -Parameters $params -ContinueOnError $true
            #Execute-ProcessAsUser -Path "$envSystem32Directory\msiexec.exe" -Parameters $params -ContinueOnError $true
            #write-host "Please confirm install result in Windows Eventlog"
            #Write-Log -Message "Please confirm install result in Windows Eventlog" -LogType CMTrace -ErrorAction SilentlyContinue
            
        }
        else{
            #Write-Host "New Teams Package not found. Please install new Teams from https://aka.ms/GetTeams ."
            Write-Log -Message "New Teams Package not found. Please install new Teams from https://aka.ms/GetTeams ." -LogType CMTrace -ErrorAction SilentlyContinue
            #Write-Host "Teams Meeting Addin not found in $TMAPath."
            Write-Log -Message "Teams Meeting Addin not found in $TMAPath." -LogType CMTrace -ErrorAction SilentlyContinue
            Exit-Script -ExitCode 1
        }        


        [scriptblock]$HKCURegistrySettings = {
           Set-RegistryKey -Key 'HKCU:\SOFTWARE\Microsoft\Office\Outlook\Addins\TeamsAddin.FastConnect\' -Name 'LoadBehavior' -Value '00000003' -Type DWord -SID $UserProfile.SID -ContinueOnError $true
        }

        Invoke-HKCURegistrySettingsForAllUsers -RegistrySettings $HKCURegistrySettings
        #>

        ## Display a message at the end of the install
        #If (-not $useDefaultMsi) {Show-InstallationPrompt -Message 'You can customize text to appear at the end of an install or remove it completely for unattended installations.' -ButtonRightText 'OK' -Icon Information -NoWait}
    }
    ElseIf ($deploymentType -ieq 'Uninstall') {
        ##*===============================================
        ##* MARK: PRE-UNINSTALLATION
        ##*===============================================
        [String]$installPhase = 'Pre-Uninstallation'

        ## Show Welcome Message, close Internet Explorer with a 60 second countdown before automatically closing
        Show-InstallationWelcome -CloseApps 'ms-teams,Teams' -CloseAppsCountdown 60

        ## Show Progress Message (with the default message)
        Show-InstallationProgress

        ## <Perform Pre-Uninstallation tasks here>


        ##*===============================================
        ##* MARK: UNINSTALLATION
        ##*===============================================
        [String]$installPhase = 'Uninstallation'

        ## Handle Zero-Config MSI Uninstallations
        If ($useDefaultMsi) {
            [Hashtable]$ExecuteDefaultMSISplat = @{ Action = 'Uninstall'; Path = $defaultMsiFile }; If ($defaultMstFile) {
                $ExecuteDefaultMSISplat.Add('Transform', $defaultMstFile)
            }
            Execute-MSI @ExecuteDefaultMSISplat
        }

        ## <Perform Uninstallation tasks here>
        ## Uninstall Microsoft Teams Classic (User Profile)
        $Users = Get-ChildItem "$envSystemDrive\Users"
        ForEach ($user in $Users) {
        $TeamsLocal = "$($user.fullname)\AppData\Local\Microsoft\Teams"
        If (Test-Path $TeamsLocal) {
        $UninstPath = Get-ChildItem -Path "$TeamsLocal\*" -Include Update.exe -Recurse -ErrorAction SilentlyContinue
        If ($UninstPath.Exists) {
        Write-Log -Message "Found $($UninstPath.FullName), now attempting to uninstall the $installTitle."
        Execute-ProcessAsUser -Path "$UninstPath" -Parameters "--uninstall -s" -Wait
        Start-Sleep -Seconds 5
        ## Cleanup Microsoft Teams Application (Local User Profile) Directory
        If (Test-Path $TeamsLocal) {
        Write-Log -Message "Cleanup ($TeamsLocal) Directory."
        Remove-Item -Path "$TeamsLocal" -Force -Recurse -ErrorAction SilentlyContinue
        }
        ## Remove Microsoft Teams Start Menu Shortcut From All Profiles
        $StartMenuSC = "$($user.fullname)\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Microsoft*Teams*"
        If (Test-Path $StartMenuSC) {
        Remove-Item $StartMenuSC -Recurse -Force -ErrorAction SilentlyContinue
        }
        ## Remove Microsoft Teams Shortcuts From All Profiles
        $DesktopSC = "$($user.fullname)\Desktop\Microsoft*Teams*.lnk"
        If (Test-Path $DesktopSC) {
        Remove-Item $DesktopSC -Recurse -Force -ErrorAction SilentlyContinue
        }
        }
        }
        }
        ## Cleanup User Profile Registry
        [scriptblock]$HKCURegistrySettings = {
        Remove-RegistryKey -Key 'HKCU\Software\Microsoft\Windows\CurrentVersion\Uninstall\Teams' -SID $UserProfile.SID
        }
        Invoke-HKCURegistrySettingsForAllUsers -RegistrySettings $HKCURegistrySettings -ErrorAction SilentlyContinue

        #Execute-Process -Path "\\share\Teams\teamsbootstrapper.exe" -Parameters "-x"
        Execute-Process -Path "$dirFiles\teamsbootstrapper.exe" -Parameters "-x"
        Remove-MSIApplications -Name 'Teams*' -WildCard -FilterApplication (,('Publisher','Microsoft*','WildCard')) -ContinueOnError $true
        Remove-MSIApplications -Name 'Microsoft Teams*' -WildCard -FilterApplication (,('Publisher','Microsoft*','WildCard')) -ContinueOnError $true

        ##*===============================================
        ##* MARK: POST-UNINSTALLATION
        ##*===============================================
        [String]$installPhase = 'Post-Uninstallation'

        ## <Perform Post-Uninstallation tasks here>
        Get-ChildItem "C:\Users" -directory | Remove-Item -Path {("{0}\AppData\Local\Microsoft\Teams" -f $_.fullname)} -Recurse -force -ErrorAction SilentlyContinue
        Get-ChildItem "C:\Users" -directory | Remove-Item -Path {("{0}\AppData\Roaming\Microsoft\Teams" -f $_.fullname)} -Recurse -force -ErrorAction SilentlyContinue
        Get-ChildItem "C:\Users" -directory | Remove-Item -Path {("{0}\AppData\Local\Packages\MSTeams_8wekyb3d8bbwe" -f $_.fullname)} -Recurse -force -ErrorAction SilentlyContinue
        Get-ChildItem "C:\Users" -directory | Remove-Item -Path {("{0}\AppData\Local\Microsoft\TeamsMeetingAddin" -f $_.fullname)} -Recurse -force -ErrorAction SilentlyContinue
        Get-ChildItem "C:\Users" -directory | Remove-Item -Path {("{0}\AppData\Local\Microsoft\TeamsMeetingAdd-in" -f $_.fullname)} -Recurse -force -ErrorAction SilentlyContinue

    }
    ElseIf ($deploymentType -ieq 'Repair') {
        ##*===============================================
        ##* MARK: PRE-REPAIR
        ##*===============================================
        [String]$installPhase = 'Pre-Repair'

        ## Show Welcome Message, close Internet Explorer with a 60 second countdown before automatically closing
	    Show-InstallationWelcome -CloseApps 'OUTLOOK' -AllowDeferCloseApps -DeferTimes 3 -CheckDiskSpace -PromptToSave -BlockExecution -ForceCloseAppsCountdown 600
        Show-InstallationWelcome -CloseApps 'ms-teams,Teams' -CloseAppsCountdown 60

        ## Show Progress Message (with the default message)
        Show-InstallationProgress

        ## <Perform Pre-Repair tasks here>
        ## Uninstall Microsoft Teams Classic (User Profile)
        ## Cleanup User Profile Registry
        [scriptblock]$HKCURegistrySettings = {
            Remove-RegistryKey -Key 'HKCU\Software\Microsoft\Windows\CurrentVersion\Uninstall\Teams' -SID $UserProfile.SID
        }
        Invoke-HKCURegistrySettingsForAllUsers -RegistrySettings $HKCURegistrySettings -ErrorAction SilentlyContinue

        <#copy or not addins manualy to issue with addon register or unregister
        #Now no copy and unregister
        If ($IsLocalSystemAccount) {
            $UserProfileFolders = Get-UserProfiles -ExcludeSystemProfiles $true
            foreach ($folder in $UserProfileFolders.ProfilePath) { 
                $settings = Join-Path -Path $folder -ChildPath 'AppData\Local\Microsoft'
                New-Item -Path $settings -ItemType Directory -ErrorAction SilentlyContinue
                if (Test-Path "$settings\TeamsMeetingAdd-in\1.24.19202"){Invoke-RegisterOrUnregisterDLL -FilePath "$settings\TeamsMeetingAdd-in\1.24.19202\x64\Microsoft.Teams.AddinLoader.dll" -DLLAction Unregister -ContinueOnError $true}else{Copy-File -Path "\\Filer01\ca_unicenter$\02_Application\Microsoft Corporation\Office\Teams\TeamsMeetingAdd-in" -Destination "$settings" -Recurse -ContinueOnError $true}
                #%SystemRoot%\System32\regsvr32.exe /n /i:user %LocalAppData%\Microsoft\TeamsMeetingAdd-in\1.24.19202\x64\Microsoft.Teams.AddinLoader.dll
                #Invoke-RegisterOrUnregisterDLL -FilePath "$settings\TeamsMeetingAdd-in\1.23.35502\x64\Microsoft.Teams.AddinLoader.dll" -DLLAction Unregister  -ContinueOnError $true
                #Execute-ProcessAsUser -Path "$envSystem32Directory\cmd.exe" -Parameters "/c %SystemRoot%\System32\regsvr32.exe /n /i:user %LocalAppData%\Microsoft\TeamsMeetingAdd-in\1.24.19202\x64\Microsoft.Teams.AddinLoader.dll" -ContinueOnError $true
                #Invoke-RegisterOrUnregisterDLL -FilePath "$settings\TeamsMeetingAdd-in\1.24.19202\x64\Microsoft.Teams.AddinLoader.dll" -DLLAction Register -ContinueOnError $true
            }
        } Else {
            $settings = Join-Path -Path $env:LOCALAPPDATA -ChildPath 'Microsoft'
            New-Item -Path $settings -ItemType Directory -Force -ErrorAction SilentlyContinue
            if (Test-Path "$settings\TeamsMeetingAdd-in\1.24.19202"){Invoke-RegisterOrUnregisterDLL -FilePath "$settings\TeamsMeetingAdd-in\1.24.19202\x64\Microsoft.Teams.AddinLoader.dll" -DLLAction Unregister -ContinueOnError $true}else{Copy-File -Path "\\Filer01\ca_unicenter$\02_Application\Microsoft Corporation\Office\Teams\TeamsMeetingAdd-in" -Destination "$settings" -Recurse -ContinueOnError $true}
            #%SystemRoot%\System32\regsvr32.exe /n /i:user %LocalAppData%\Microsoft\TeamsMeetingAdd-in\1.24.19202\x64\Microsoft.Teams.AddinLoader.dll
            #Invoke-RegisterOrUnregisterDLL -FilePath "$settings\TeamsMeetingAdd-in\1.23.35502\x64\Microsoft.Teams.AddinLoader.dll" -DLLAction Unregister  -ContinueOnError $true
            #Execute-ProcessAsUser -Path "$envSystem32Directory\cmd.exe" -Parameters "/c %SystemRoot%\System32\regsvr32.exe /n /i:user %LocalAppData%\Microsoft\TeamsMeetingAdd-in\1.24.19202\x64\Microsoft.Teams.AddinLoader.dll" -ContinueOnError $true
            #Invoke-RegisterOrUnregisterDLL -FilePath "$settings\TeamsMeetingAdd-in\1.24.19202\x64\Microsoft.Teams.AddinLoader.dll" -DLLAction Register -ContinueOnError $true
            #Execute-ProcessAsUser -Path "$envSystem32Directory\cmd.exe" -Parameters "/c reg delete HKEY_CURRENT_USER\SOFTWARE\Microsoft\Office\Outlook\Addins\TeamsAddin.FastConnect /v LoadBehavior /F" -ContinueOnError $true
            #Execute-ProcessAsUser -Path "$envSystem32Directory\cmd.exe" -Parameters "/c reg add HKEY_CURRENT_USER\SOFTWARE\Microsoft\Office\Outlook\Addins\TeamsAddin.FastConnect /v LoadBehavior /t REG_DWORD /d 00000003 /f" -ContinueOnError $true
            
        }
        #>
        
        #Execute-Process -Path "\\share\Teams\teamsbootstrapper.exe" -Parameters "-x"
        Execute-Process -Path "$dirFiles\teamsbootstrapper.exe" -Parameters "-x"
        Remove-MSIApplications -Name 'Teams*' -WildCard -FilterApplication (,('Publisher','Microsoft*','WildCard')) -ContinueOnError $true
        Remove-MSIApplications -Name 'Microsoft Teams*' -WildCard -FilterApplication (,('Publisher','Microsoft*','WildCard')) -ContinueOnError $true
        #Get-ChildItem "C:\Users" -directory | Remove-Item -Path {("{0}\AppData\Local\Microsoft\TeamsMeetingAddin" -f $_.fullname)} -Recurse -force -ErrorAction SilentlyContinue
        #Get-ChildItem "C:\Users" -directory | Remove-Item -Path {("{0}\AppData\Local\Microsoft\TeamsMeetingAdd-in" -f $_.fullname)} -Recurse -force -ErrorAction SilentlyContinue                        
        
        
        
        #Get-ItemProperty -Path "C:\Users\*\AppData\Local\Packages" | ForEach-Object {Remove-Item -Path "$_\Microsoft.AAD.BrokerPlugin*" -Recurse -Force | Out-Null}
        
        #Get-ChildItem "C:\Users" -directory | Remove-Item -Path {("{0}\AppData\Local\Packages\Microsoft.AAD.BrokerPlugin_cw5n1h2txyewy" -f $_.fullname)} -Recurse -force -ErrorAction SilentlyContinue
        #Get-ChildItem "C:\Users" -directory | Remove-Item -Path {("{0}\AppData\Local\Packages\Microsoft.Windows.CloudExperienceHost_cw5n1h2txyewy" -f $_.fullname)} -Recurse -force -ErrorAction SilentlyContinue
        #Get-ChildItem "C:\Users" -directory | Remove-Item -Path {("{0}\AppData\Local\Microsoft\TokenBroker" -f $_.fullname)} -Recurse -force -ErrorAction SilentlyContinue        
        Get-ChildItem "C:\Users" -directory | Remove-Item -Path {("{0}\AppData\Local\Microsoft\Teams" -f $_.fullname)} -Recurse -force -ErrorAction SilentlyContinue
        Get-ChildItem "C:\Users" -directory | Remove-Item -Path {("{0}\AppData\Roaming\Microsoft\Teams" -f $_.fullname)} -Recurse -force -ErrorAction SilentlyContinue
        Get-ChildItem "C:\Users" -directory | Remove-Item -Path {("{0}\AppData\Local\Packages\MSTeams_8wekyb3d8bbwe" -f $_.fullname)} -Recurse -force -ErrorAction SilentlyContinue
        Get-ChildItem "C:\Users" -directory | Remove-Item -Path {("{0}\AppData\Local\Microsoft\TeamsMeetingAddin" -f $_.fullname)} -Recurse -force -ErrorAction SilentlyContinue
        Get-ChildItem "C:\Users" -directory | Remove-Item -Path {("{0}\AppData\Local\Microsoft\TeamsMeetingAdd-in" -f $_.fullname)} -Recurse -force -ErrorAction SilentlyContinue       
        
        <#Get-ChildItem "C:\Users" -directory | Remove-Item -Path {("{0}\AppData\Local\Microsoft\OneAuth" -f $_.fullname)} -Recurse -force -ErrorAction SilentlyContinue        
        #Get-ChildItem "C:\Users" -directory | Remove-Item -Path {("{0}\AppData\Local\Microsoft\IdentityCache" -f $_.fullname)} -Recurse -force -ErrorAction SilentlyContinue

        [scriptblock]$HKCURegistrySettings = {

            Remove-RegistryKey -Key 'HKCU:\Software\Microsoft\IdentityCRL' -Recurse -SID $UserProfile.SID -ContinueOnError $true
            #Remove-RegistryKey -Key 'HKCU:\Software\Microsoft' -Name 'IdentityCRL' -Recurse -ContinueOnError $true
            Remove-RegistryKey -Key 'HKCU:\Software\Microsoft\Windows\CurrentVersion\AAD' -Recurse -SID $UserProfile.SID -ContinueOnError $true
            #Remove-RegistryKey -Key 'HKCU:\Software\Microsoft\Windows\CurrentVersion' -Name 'AAD' -Recurse -ContinueOnError $true
            Remove-RegistryKey -Key 'HKCU:\Software\Microsoft\Windows NT\CurrentVersion\WorkplaceJoin' -Recurse -SID $UserProfile.SID -ContinueOnError $true
            #Remove-RegistryKey -Key 'HKCU:\Software\Microsoft\Windows NT\CurrentVersion' -Name 'WorkplaceJoin' -Recurse -ContinueOnError $true

        }
        Invoke-HKCURegistrySettingsForAllUsers -RegistrySettings $HKCURegistrySettings
        #>
        ##*===============================================
        ##* MARK: REPAIR
        ##*===============================================
        [String]$installPhase = 'Repair'

        ## Handle Zero-Config MSI Repairs
        If ($useDefaultMsi) {
            [Hashtable]$ExecuteDefaultMSISplat = @{ Action = 'Repair'; Path = $defaultMsiFile; }; If ($defaultMstFile) {
                $ExecuteDefaultMSISplat.Add('Transform', $defaultMstFile)
            }
            Execute-MSI @ExecuteDefaultMSISplat
        }
        ## <Perform Repair tasks here>

        ##*===============================================
        ##* MARK: POST-REPAIR
        ##*===============================================
        [String]$installPhase = 'Post-Repair'

        ## <Perform Post-Repair tasks here>
        Execute-Process -Path "$dirFiles\teamsbootstrapper.exe" -Parameters "-p -o `"$dirFiles\$installFile`""

    }

    ## Call the Exit-Script function to perform final cleanup operations
    Exit-Script -ExitCode $mainExitCode
}
Catch {
    [Int32]$mainExitCode = 60001
    [String]$mainErrorMessage = "$(Resolve-Error)"
    Write-Log -Message $mainErrorMessage -Severity 3 -Source $deployAppScriptFriendlyName
    Show-DialogBox -Text $mainErrorMessage -Icon 'Stop'
    Exit-Script -ExitCode $mainExitCode
}
