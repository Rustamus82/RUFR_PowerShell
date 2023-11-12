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
	[string]$appName = 'Free Up Diskspace - Clear & Boost System'
	[string]$appVersion = '1.0.3'
	[string]$appArch = ''
	[string]$appLang = 'EN'
	[string]$appRevision = '01'
	[string]$appScriptVersion = '1.0.3'
	[string]$appScriptDate = '24/09/2021'
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
        Show-InstallationWelcome -CloseApps 'outlook,winword,excel,powerpnt' -PersistPrompt -PromptToSave		
        Show-InstallationWelcome -CloseApps 'iexplore,lync' -BlockExecution -CloseAppsCountdown 300
        		
		## Show Progress Message (with the default message)
		Show-InstallationProgress

		## <Perform Pre-Installation tasks here>
        Remove-File -Path "$env:SystemDrive\Temp" -Recurse -ContinueOnError $True
        Remove-File -Path "$env:SystemRoot\logs\Software\Clean-CMClientCache.log" -ContinueOnError $True

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
		Get-Service wuauserv | Stop-Service 
        Remove-File -Path "$envSystemRoot\SoftwareDistribution" -Recurse -ContinueOnError $true
        Get-Service wuauserv | Start-Service
        
        Remove-File -Path "$envSystemRoot\temp\*.*" -Recurse -ContinueOnError $true
        Remove-File -Path "$env:SystemDrive\OSLicenseDetails.txt" -ContinueOnError $true    
        Remove-File -Path "$env:SystemDrive\ConfigMgrAdminUISetup.log" -ContinueOnError $true
        Remove-File -Path "$env:SystemDrive\ConfigMgrAdminUISetupVerbose.log" -ContinueOnError $true
        #Remove-File -Path "$env:SystemDrive\win10drv\*.*" -Recurse -ContinueOnError $true
        Remove-File -Path "$env:SystemDrive\win10drv\" -Recurse -ContinueOnError $true     
        

        #The list of accounts, for which profiles must not be deleted
        $ExcludedUsers ="Public","Default","Administrator"
        $RunOnServers = $false
        [int]$MaximumProfileAge = 35 # Profiles older than this will be deleted
        
        $osInfo = Get-CimInstance -ClassName Win32_OperatingSystem
        
        if ($RunOnServers -eq $true -or $osInfo.ProductType -eq 1) {
        
            $obj = Get-WMIObject -class Win32_UserProfile | Where {(!$_.Special -and $_.Loaded -eq $false )}
            $output = @()
        
            foreach ($littleobj in $obj) {
                if (!($ExcludedUsers -like $littleobj.LocalPath.Replace("C:\Users\",""))) {
                    $lastwritetime = (Get-ChildItem -Path "$($littleobj.localpath)\AppData\Local\Microsoft\Windows\UsrClass.dat" -Force ).LastWriteTime
                    if ($lastwritetime -lt (Get-Date).AddDays(-$MaximumProfileAge)) {
                        $littleobj | Remove-WmiObject
                        $output += [PSCustomObject]@{
                            'RemovedSID' = $littleobj.SID
                            'LastUseTime' = $litteobj.LastUseTime
                            'LastWriteTime' = $lastwritetime
                            'LocalPath' = $littleobj.LocalPath
                        }
                    }
                }
            }
        
        #$output | Sort LocalPath | ft
        $output | Sort LocalPath | ft * -AutoSize | Out-String -Width 4096 | Out-File -filepath "$env:SystemRoot\logs\Software\RemovedProfiles.log" -append -Encoding Unicode
        }

        "past step of removing older profiles." | Out-File "$env:SystemRoot\logs\Software\FreeUpDiskspace-Clear&BoostSystem1.0.3_PSAppDeployToolkit_Install.log" -Append

        #Clear burger profiler %Temp%  på windows
        & "$dirSupportFiles\del_all_user_temp.bat"
        "past step $dirSupportFiles\del_all_user_temp.bat " | Out-File "$env:SystemRoot\logs\Software\FreeUpDiskspace-Clear&BoostSystem1.0.3_PSAppDeployToolkit_Install.log" -Append


        #https://winaero.com/cleanmgr-exe-command-line-arguments-in-windows-10/
        #& cleanmgr.exe /VERYLOWDISK
        Execute-Process -Path "$env:SystemRoot\system32\cleanmgr.exe" -Parameters "/VERYLOWDISK" -PassThru
        #Execute-ProcessAsUser -Path "$env:SystemRoot\system32\cleanmgr.exe" -Parameters "/VERYLOWDISK" -RunLevel HighestAvailable -PassThru
        
        #& cleanmgr.exe /AUTOCLEAN
        Execute-Process -Path "$env:SystemRoot\system32\cleanmgr.exe" -Parameters "/AUTOCLEAN" -PassThru
        
        #Invoke-CleanMgr -Index 5432 -> $null Lasses funktion som ikke lige bliver færdig... eller virker
        #"Invoke-CleanMgr -Index 5432 > $nul" | Out-File "$env:SystemRoot\logs\Software\FreeUpDiskspace-Clear&BoostSystem1.0.3_PSAppDeployToolkit_Install.log" -Append

        #Clear Lync folder for Lync\Skype for Business 2016:
        
        If ($IsLocalSystemAccount) {
            $UserProfileFolders = Get-UserProfiles -ExcludeSystemProfiles $true
            foreach ($folder in $UserProfileFolders.ProfilePath) { 
                $Shortcut = Join-Path -Path $folder -ChildPath 'AppData\Local\Microsoft\Office\16.0\Lync\'
                New-Item -Path $Shortcut -ItemType Directory -ErrorAction SilentlyContinue
                Get-ChildItem -Path $Shortcut -Recurse -Filter sip*| Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
                Remove-File -Path "$Shortcut\Tracing\*.*" -Recurse -ContinueOnError $true
                Get-ChildItem -Path "$Shortcut\Tracing\" -Recurse | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
                }
        } Else {
            $UserProfileFolders = Get-UserProfiles -ExcludeSystemProfiles $true
            foreach ($folder in $UserProfileFolders.ProfilePath) { 
                $Shortcut = Join-Path -Path $folder -ChildPath 'AppData\Local\Microsoft\Office\16.0\Lync\'
                New-Item -Path $Shortcut -ItemType Directory -ErrorAction SilentlyContinue
                Get-ChildItem -Path $Shortcut -Recurse -Filter sip*| Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
                Remove-File -Path "$Shortcut\Tracing\*.*" -Recurse -ContinueOnError $true
                Get-ChildItem -Path "$Shortcut\Tracing\" -Recurse | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
                }
        }
        "past clean up lync 16.0 step" | Out-File "$env:SystemRoot\logs\Software\FreeUpDiskspace-Clear&BoostSystem1.0.3_PSAppDeployToolkit_Install.log" -Append

        #Clear Lync folder for Lync\Skype for Business 2013:

        If ($IsLocalSystemAccount) {
            $UserProfileFolders = Get-UserProfiles -ExcludeSystemProfiles $true
            foreach ($folder in $UserProfileFolders.ProfilePath) { 
                $Shortcut = Join-Path -Path $folder -ChildPath 'AppData\Local\Microsoft\Office\15.0\Lync\'
                New-Item -Path $Shortcut -ItemType Directory -ErrorAction SilentlyContinue
                Remove-Folder -Path "$Shortcut\sip%" -ContinueOnError $true
                Remove-File -Path "$Shortcut\Tracing\*.*" -Recurse -ContinueOnError $true
                Remove-Folder -Path "$Shortcut\Tracing\OCAddin" -ContinueOnError $true
                Remove-Folder -Path "$Shortcut\Tracing\WPPMedia" -ContinueOnError $true
                }
        } Else {
            $UserProfileFolders = Get-UserProfiles -ExcludeSystemProfiles $true
            foreach ($folder in $UserProfileFolders.ProfilePath) { 
                $Shortcut = Join-Path -Path $folder -ChildPath 'AppData\Local\Microsoft\Office\15.0\Lync\'
                New-Item -Path $Shortcut -ItemType Directory -ErrorAction SilentlyContinue
                Remove-Folder -Path "$Shortcut\sip%" -ContinueOnError $true
                Remove-File -Path "$Shortcut\Tracing\*.*" -Recurse -ContinueOnError $true
                Remove-Folder -Path "$Shortcut\Tracing\OCAddin" -ContinueOnError $true
                Remove-Folder -Path "$Shortcut\Tracing\WPPMedia" -ContinueOnError $true
                }
        }
        "past clean up lync 15.0 step" | Out-File "$env:SystemRoot\logs\Software\FreeUpDiskspace-Clear&BoostSystem1.0.3_PSAppDeployToolkit_Install.log" -Append

        #Clear %temp%        
        If ($IsLocalSystemAccount) {
            $UserProfileFolders = Get-UserProfiles -ExcludeSystemProfiles $true
            foreach ($folder in $UserProfileFolders.ProfilePath) { 
                $Shortcut = Join-Path -Path $folder -ChildPath 'AppData\Local\Temp\'
                New-Item -Path $Shortcut -ItemType Directory -ErrorAction SilentlyContinue
                Get-ChildItem -Path $Shortcut -Recurse | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
                
                }
        } Else {
            $UserProfileFolders = Get-UserProfiles -ExcludeSystemProfiles $true
            foreach ($folder in $UserProfileFolders.ProfilePath) { 
                $Shortcut = Join-Path -Path $folder -ChildPath 'AppData\Local\Temp\'
                New-Item -Path $Shortcut -ItemType Directory -ErrorAction SilentlyContinue
                Get-ChildItem -Path $Shortcut -Recurse | Remove-Item -Recurse -Force -ErrorAction SilentlyContinu
                }
        }
        
        "past clean up AppData\Local\Temp\ step" | Out-File "$env:SystemRoot\logs\Software\FreeUpDiskspace-Clear&BoostSystem1.0.3_PSAppDeployToolkit_Install.log" -Append


        #After clearing lync need to flush dns
        #& ipconfig /flushdns
        Clear-DnsClientCache -Confirm:$false
        "past ipconfig /flushdns step" | Out-File "$env:SystemRoot\logs\Software\FreeUpDiskspace-Clear&BoostSystem1.0.3_PSAppDeployToolkit_Install.log" -Append

        ####Clear SCCMcache###
        <# https://gallery.technet.microsoft.com/scriptcenter/Deleting-the-SCCM-Cache-da03e4c7
        ********************************************************************************************************* 
        * Created by Ioan Popovici, 2015-11-13  | Requirements PowerShell 3.0                                   * 
        * ======================================================================================================* 
        * Modified by   |    Date    | Revision | Comments                                                      * 
        *_______________________________________________________________________________________________________* 
        * Ioan Popovici | 2015-11-13 | v1.0     | First version                                                 * 
        * Ioan Popovici | 2015-11-16 | v1.1     | Improved logging                                              * 
        * Ioan Popovici | 2015-11-17 | v1.2     | Vastly improved                                               * 
        * Ioan Popovici | 2016-02-03 | v2.0     | Vastly improved                                               * 
        * Ioan Popovici | 2016-02-04 | v2.1     | Fixed TotalSize decimals                                      * 
        * Ioan Popovici | 2016-02-19 | v2.2     | EventLog logging support                                      * 
        * Ioan Popovici | 2016-02-20 | v2.3     | Added check for not downloaded Cache Items, improved logging  * 
        * Ioan Popovici | 2017-04-26 | v2.4     | Basic error management, formatting cleanup                    * 
        * Ioan Popovici | 2017-04-26 | v2.5     | Orphaned cache cleanup, null CacheID fix, improved logging    * 
        * Ioan Popovici | 2017-05-02 | v2.5     | Basic error Management                                        * 
        * Walker        | 2017-08-08 | v2.6     | Fixed first time run logging bug                              * 
        *-------------------------------------------------------------------------------------------------------* 
        * To Do: Not happy, this needs a re-write changing the logic. Now it parses all apps/packages/updates   * 
        * and then looks in the cache for it. This search is expensive and optimized, will have to go the       * 
        * other way around if possible. Also logging and error handling are crap                                * 
        ********************************************************************************************************* 
        .SYNOPSIS 
            This PowerShell Script is used to clean the CCM cache of all unneeded, non persisted content. 
        .DESCRIPTION 
            This PowerShell Script is used to clean the CCM cache of all non persisted content that is not needed anymore. 
        .EXAMPLE 
            Clean-CMClientCache 
        .NOTES 
            It only cleans packages, applications and updates that have a "installed" status, are not persisted, or 
            are not needed anymore (Some other checks are performed). Other cache items will NOT be cleaned. 
        .LINK 
            http://sccm-zone.com 
        #> 
 
        ##*============================================= 
        ##* INITIALIZATION 
        ##*============================================= 
        #region Initialization 
 
        ## Cleaning prompt history 
        CLS 
 
        ## Global variables 
        $Global:Result  =@() 
        $Global:ExclusionList  =@() 
 
        ## Initialize progress Counter 
        $ProgressCounter = 0 
 
        ## Configure Logging 
        #  Set log path 
        $ResultCSV = "$env:SystemRoot\logs\Software\Clean-CMClientCache.log"
 
        #  Remove previous log it it's more than 500 KB 
        If (Test-Path $ResultCSV) { 
            If ((Get-Item $ResultCSV).Length -gt 500KB) { 
                Remove-Item $ResultCSV -Force | Out-Null 
            } 
        } 
 
        #  Get log parent path 
        [String]$ResultPath =  Split-Path $ResultCSV -Parent 
 
        #  Create path directory if it does not exist 
        If ((Test-Path $ResultPath) -eq $False) { 
            New-Item -Path $ResultPath -Type Directory | Out-Null 
        } 
 
        ## Get the current date 
        $Date = Get-Date 
 
        #endregion 
        ##*============================================= 
        ##* END INITIALIZATION 
        ##*============================================= 
 
        ##*============================================= 
        ##* FUNCTION LISTINGS 
        ##*============================================= 
        #region FunctionListings 
 
        #region Function Write-Log 
        Function Write-Log { 
        <# 
        .SYNOPSIS 
            Writes an event to EventLog. 
        .DESCRIPTION 
            Writes an event to EventLog with a specified source. 
        .PARAMETER EventLogName 
            The EventLog to write to. 
        .PARAMETER EventLogEntrySource 
            The EventLog Entry Source. 
        .PARAMETER EventLogEntryID 
            The EventLog Entry ID. 
        .PARAMETER EventLogEntryType 
            The EventLog Entry Type. (Error | Warning | Information | SuccessAudit | FailureAudit) 
        .PARAMETER EventLogEntryMessage 
            The EventLog Entry Message. 
        .EXAMPLE 
            Write-Log -EventLogName 'Configuration Manager' -EventLogEntrySource 'Script' -EventLogEntryID '1' -EventLogEntryType 'Information' -EventLogEntryMessage 'Clean-CMClientCache was successful' 
        .NOTES 
            This is an internal script function and should typically not be called directly. 
        .LINK 
            http://sccm-zone.com 
        #> 
            [CmdletBinding()] 
            Param ( 
                [Parameter(Mandatory=$false,Position=0)] 
                [Alias('Name')] 
                [string]$EventLogName = 'Configuration Manager', 
                [Parameter(Mandatory=$false,Position=1)] 
                [Alias('Source')] 
                [string]$EventLogEntrySource = 'Clean-CMClientCache', 
                [Parameter(Mandatory=$false,Position=2)] 
                [Alias('ID')] 
                [int32]$EventLogEntryID = 1, 
                [Parameter(Mandatory=$false,Position=3)] 
                [Alias('Type')] 
                [string]$EventLogEntryType = 'Information', 
                [Parameter(Mandatory=$true,Position=4)] 
                [Alias('Message')] 
                $EventLogEntryMessage 
            ) 
 
            ## Initialize log 
            If (([System.Diagnostics.EventLog]::Exists($EventLogName) -eq $false) -or ([System.Diagnostics.EventLog]::SourceExists($EventLogEntrySource) -eq $false )) { 
 
                #  Create new log and/or source 
                New-EventLog -LogName $EventLogName -Source $EventLogEntrySource 
 
            ## Write to log and console 
            } 
 
            #  Convert the Result to string and Write it to the EventLog 
            $ResultString = Out-String -InputObject $Result -Width 1000 
            Write-EventLog -LogName $EventLogName -Source $EventLogEntrySource -EventId $EventLogEntryID -EntryType $EventLogEntryType -Message $ResultString 
 
            #  Write Result Object to csv file (append) 
            $EventLogEntryMessage | Export-Csv -Path $ResultCSV -Delimiter ';' -Encoding UTF8 -NoTypeInformation -Append -Force 
 
            #  Write Result to console 
            $EventLogEntryMessage | Format-Table Name,TotalDeleted`(MB`) 
 
        } 
        #endregion 
 
 
        #region Function Remove-CacheItem 
        Function Remove-CacheItem { 
        <# 
        .SYNOPSIS 
            Removes SCCM cache item if it's not persisted. 
        .DESCRIPTION 
            Removes specified SCCM cache item if it's not found in the persisted cache list. 
        .PARAMETER CacheItemToDelete 
            The cache item ID that needs to be deleted. 
        .PARAMETER CacheItemName 
            The cache item name that needs to be deleted. 
        .EXAMPLE 
            Remove-CacheItem -CacheItemToDelete '{234234234}' -CacheItemName 'Office2003' 
        .NOTES 
            This is an internal script function and should typically not be called directly. 
        .LINK 
            http://sccm-zone.com 
        #> 
            [CmdletBinding()] 
            Param ( 
                [Parameter(Mandatory=$true,Position=0)] 
                [Alias('CacheTD')] 
                [string]$CacheItemToDelete, 
                [Parameter(Mandatory=$true,Position=1)] 
                [Alias('CacheN')] 
                [string]$CacheItemName 
            ) 
 
            ## Delete cache item if it's non persisted 
            If ($CacheItems.ContentID -contains $CacheItemToDelete) { 
 
                #  Get Cache item location and size 
                $CacheItemLocation = $CacheItems | Where {$_.ContentID -Contains $CacheItemToDelete} | Select -ExpandProperty Location 
                $CacheItemSize =  Get-ChildItem $CacheItemLocation -Recurse -Force | Measure-Object -Property Length -Sum | Select -ExpandProperty Sum 
 
                #  Check if cache item is downloaded by looking at the size 
                If ($CacheItemSize -gt '0.00') { 
 
                    #  Connect to resource manager COM object 
                    $CMObject = New-Object -ComObject 'UIResource.UIResourceMgr' 
 
                    #  Using GetCacheInfo method to return cache properties 
                    $CMCacheObjects = $CMObject.GetCacheInfo() 
 
                    #  Delete Cache item 
                    $CMCacheObjects.GetCacheElements() | Where-Object {$_.ContentID -eq $CacheItemToDelete} | 
                        ForEach-Object { 
                            $CMCacheObjects.DeleteCacheElement($_.CacheElementID) 
                            Write-Host 'Deleted: '$CacheItemName -BackgroundColor Red 
                        } 
                    #  Build result object 
                    $ResultProps = [ordered]@{ 
                        'Name' = $CacheItemName 
                        'ID' = $CacheItemToDelete 
                        'Location' = $CacheItemLocation 
                        'Size(MB)' = '{0:N2}' -f ($CacheItemSize / 1MB) 
                        'Status' = 'Deleted!' 
                    } 
 
                    #  Add items to result object 
                    $Global:Result  += New-Object PSObject -Property $ResultProps 
                } 
            } 
            Else { 
                Write-Host 'Already Deleted:'$CacheItemName '|| ID:'$CacheItemToDelete -BackgroundColor Green 
            } 
        } 
        #endregion 
 
        #region Function Remove-CachedApplications 
        Function Remove-CachedApplications { 
        <# 
        .SYNOPSIS 
            Removes cached application. 
        .DESCRIPTION 
            Removes specified SCCM cache application if it's already installed. 
        .EXAMPLE 
            Remove-CachedApplications 
        .NOTES 
            This is an internal script function and should typically not be called directly. 
        .LINK 
            http://sccm-zone.com 
        #> 
 
            ## Get list of applications 
            Try { 
                $CM_Applications = Get-WmiObject -Namespace root\ccm\ClientSDK -Query 'SELECT * FROM CCM_Application' -ErrorAction Stop 
            } 
            #  Write to log in case of failure 
            Catch { 
                Write-Host 'Get SCCM Application List from WMI - Failed!' 
            } 
 
            ## Check for installed applications 
            Foreach ($Application in $CM_Applications) { 
 
                ## Show progress bar 
                If ($CM_Applications.Count -ne $null) { 
                    $ProgressCounter++ 
                    Write-Progress -Activity 'Processing Applications' -CurrentOperation $Application.FullName -PercentComplete (($ProgressCounter / $CM_Applications.Count) * 100) 
                } 
                ## Get Application Properties 
                $Application.Get() 
 
                ## Enumerate all deployment types for an application 
                Foreach ($DeploymentType in $Application.AppDTs) { 
 
                    ## Get content ID for specific application deployment type 
                    $AppType = 'Install',$DeploymentType.Id,$DeploymentType.Revision 
                    $AppContent = Invoke-WmiMethod -Namespace root\ccm\cimodels -Class CCM_AppDeliveryType -Name GetContentInfo -ArgumentList $AppType 
 
                    If ($Application.InstallState -eq 'Installed' -and $Application.IsMachineTarget -and $AppContent.ContentID) { 
 
                        ## Call Remove-CacheItem function 
                        Remove-CacheItem -CacheTD $AppContent.ContentID -CacheN $Application.FullName 
                    } 
                    Else { 
                        ## Add to exclusion list 
                        $Global:ExclusionList += $AppContent.ContentID 
                    } 
                } 
            } 
        } 
        #endregion 
 
        #region Function Remove-CachedPackages 
        Function Remove-CachedPackages { 
        <# 
        .SYNOPSIS 
            Removes SCCM cached package. 
        .DESCRIPTION 
            Removes specified SCCM cached package if it's not needed anymore. 
        .EXAMPLE 
            Remove-CachedPackages 
        .NOTES 
            This is an internal script function and should typically not be called directly. 
        .LINK 
            http://sccm-zone.com 
        #> 
 
            ## Get list of packages 
            Try { 
                $CM_Packages = Get-WmiObject -Namespace root\ccm\ClientSDK -Query 'SELECT PackageID,PackageName,LastRunStatus,RepeatRunBehavior FROM CCM_Program' -ErrorAction Stop 
            } 
            #  Write to log in case of failure 
            Catch { 
                Write-Host 'Get SCCM Package List from WMI - Failed!' 
            } 
 
            ## Check if any deployed programs in the package need the cached package and add deletion or exemption list for comparison 
            ForEach ($Program in $CM_Packages) { 
 
                #  Check if program in the package needs the cached package 
                If ($Program.LastRunStatus -eq 'Succeeded' -and $Program.RepeatRunBehavior -ne 'RerunAlways' -and $Program.RepeatRunBehavior -ne 'RerunIfSuccess') { 
 
                    #  Add PackageID to Deletion List if not already added 
                    If ($Program.PackageID -NotIn $PackageIDDeleteTrue) { 
                        [Array]$PackageIDDeleteTrue += $Program.PackageID 
                    } 
 
                } 
                Else { 
 
                    #  Add PackageID to Exemption List if not already added 
                    If ($Program.PackageID -NotIn $PackageIDDeleteFalse) { 
                        [Array]$PackageIDDeleteFalse += $Program.PackageID 
                    } 
                } 
            } 
 
            ## Parse Deletion List and Remove Package if not in Exemption List 
            ForEach ($Package in $PackageIDDeleteTrue) { 
 
                #  Show progress bar 
                If ($CM_Packages.Count -ne $null) { 
                    $ProgressCounter++ 
                    Write-Progress -Activity 'Processing Packages' -CurrentOperation $Package.PackageName -PercentComplete (($ProgressCounter / $CM_Packages.Count) * 100) 
                    Start-Sleep -Milliseconds 800 
                } 
                #  Call Remove Function if Package is not in $PackageIDDeleteFalse 
                If ($Package -NotIn $PackageIDDeleteFalse) { 
                    Remove-CacheItem -CacheTD $Package.PackageID -CacheN $Package.PackageName 
                } 
                Else { 
                    ## Add to exclusion list 
                    $Global:ExclusionList += $Package.PackageID 
                } 
            } 
        } 
        #endregion 
 
        #region Function Remove-CachedUpdates 
        Function Remove-CachedUpdates { 
        <# 
        .SYNOPSIS 
            Removes SCCM cached updates. 
        .DESCRIPTION 
            Removes specified SCCM cached update if it's not needed anymore. 
        .EXAMPLE 
            Remove-CachedUpdates 
        .NOTES 
            This is an internal script function and should typically not be called directly. 
        .LINK 
            http://sccm-zone.com 
        #> 
 
            ## Get list of updates 
            Try { 
                $CM_Updates = Get-WmiObject -Namespace root\ccm\SoftwareUpdates\UpdatesStore -Query 'SELECT UniqueID,Title,Status FROM CCM_UpdateStatus' -ErrorAction Stop 
            } 
            #  Write to log in case of failure 
            Catch { 
                Write-Host 'Get SCCM Software Update List from WMI - Failed!' 
            } 
 
            ## Check if cached updates are not needed and delete them 
            ForEach ($Update in $CM_Updates) { 
 
                #  Show Progress bar 
                If ($CM_Updates.Count -ne $null) { 
                    $ProgressCounter++ 
                    Write-Progress -Activity 'Processing Updates' -CurrentOperation $Update.Title -PercentComplete (($ProgressCounter / $CM_Updates.Count) * 100) 
                } 
 
                #  Check if update is already installed 
                If ($Update.Status -eq 'Installed') { 
 
                    #  Call Remove-CacheItem function 
                    Remove-CacheItem -CacheTD $Update.UniqueID -CacheN $Update.Title 
                } 
                Else { 
                    ## Add to exclusion list 
                    $Global:ExclusionList += $Update.UniqueID 
                } 
            } 
        } 
        #endregion 
 
        #region Function Remove-OrphanedCacheItems 
        Function Remove-OrphanedCacheItems { 
        <# 
        .SYNOPSIS 
            Removes SCCM orphaned cached items. 
        .DESCRIPTION 
            Removes SCCM orphaned cache items not found in Applications, Packages or Update WMI Tables. 
        .EXAMPLE 
            Remove-OrphanedCacheItems 
        .NOTES 
            This is an internal script function and should typically not be called directly. 
        .LINK 
            http://sccm-zone.com 
        #> 
 
            ## Check if cached updates are not needed and delete them 
            ForEach ($CacheItem in $CacheItems) { 
 
                #  Show Progress bar 
                If ($CacheItems.Count -ne $null) { 
                    $ProgressCounter++ 
                    Write-Progress -Activity 'Processing Orphaned Cache Items' -CurrentOperation $CacheItem.ContentID -PercentComplete (($ProgressCounter / $CacheItems.Count) * 100) 
                } 
 
                #  Check if update is already installed 
                If ($Global:ExclusionList -notcontains $CacheItem.ContentID) { 
 
                    #  Call Remove-CacheItem function 
                    Remove-CacheItem -CacheTD $CacheItem.ContentID -CacheN 'Orphaned Cache Item' 
                } 
            } 
        } 
        #endregion 
 
        #endregion 
        ##*============================================= 
        ##* END FUNCTION LISTINGS 
        ##*============================================= 
 
        ##*============================================= 
        ##* SCRIPT BODY 
        ##*============================================= 
        #region ScriptBody 
 
        ## Get list of all non persisted content in CCMCache, only this content will be removed 
        Try { 
            $CacheItems = Get-WmiObject -Namespace root\ccm\SoftMgmtAgent -Query 'SELECT ContentID,Location FROM CacheInfoEx WHERE PersistInCache != 1' -ErrorAction Stop 
        } 
        #  Write to log in case of failure 
        Catch { 
            Write-Host 'Getting SCCM Cache Info from WMI - Failed! Check if SCCM Client is Installed!' 
        } 
 
        "Script body start" | Out-File "$env:SystemRoot\logs\Software\FreeUpDiskspace-Clear&BoostSystem1.0.3_PSAppDeployToolkit_Install.log" -Append
        ## Call Remove-CachedApplications function 
        Remove-CachedApplications 
        "Post Remove-CachedApplications step" | Out-File "$env:SystemRoot\logs\Software\FreeUpDiskspace-Clear&BoostSystem1.0.3_PSAppDeployToolkit_Install.log" -Append
 
        ## Call Remove-CachedApplications function 
        Remove-CachedPackages 
        "Post Remove-CachedPackages step" | Out-File "$env:SystemRoot\logs\Software\FreeUpDiskspace-Clear&BoostSystem1.0.3_PSAppDeployToolkit_Install.log" -Append

        ## Call Remove-CachedApplications function 
        Remove-CachedUpdates 
        "Post Remove-CachedUpdates step" | Out-File "$env:SystemRoot\logs\Software\FreeUpDiskspace-Clear&BoostSystem1.0.3_PSAppDeployToolkit_Install.log" -Append
 
        ## Call Remove-OrphanedCacheItems function 
        Remove-OrphanedCacheItems
        "Post Remove-OrphanedCacheItems step" | Out-File "$env:SystemRoot\logs\Software\FreeUpDiskspace-Clear&BoostSystem1.0.3_PSAppDeployToolkit_Install.log" -Append
 
        ## Get Result sort it and build Result Object 
        $Result =  $Global:Result | Sort-Object Size`(MB`) -Descending 
 
        #  Calculate total deleted size 
        $TotalDeletedSize = $Result | Measure-Object -Property Size`(MB`) -Sum | Select -ExpandProperty Sum 
 
        #  If $TotalDeletedSize is zero write that nothing could be deleted 
        If ($TotalDeletedSize -eq $null -or $TotalDeletedSize -eq '0.00') { 
            $TotalDeletedSize = 'Nothing to Delete!' 
        } 
        Else { 
            $TotalDeletedSize = '{0:N2}' -f $TotalDeletedSize 
            } 
 
        #  Build Result Object 
        $ResultProps = [ordered]@{ 
            'Name' = 'Total Size of Items Deleted in MB: '+$TotalDeletedSize 
            'ID' = 'N/A' 
            'Location' = 'N/A' 
            'Size(MB)' = 'N/A' 
            'Status' = ' ***** Last Run Date: '+$Date+' *****' 
        } 
 
        #  Add total items deleted to result object 
        $Result += New-Object PSObject -Property $ResultProps 
 
        ## Write to log and console 
        Write-Log -Message $Result 
        "Past all script test & clean up done" | Out-File "$env:SystemRoot\logs\Software\FreeUpDiskspace-Clear&BoostSystem1.0.3_PSAppDeployToolkit_Install.log" -Append
        Exit-Script -ExitCode 0
        
        #endregion 
        ##*============================================= 
        ##* END SCRIPT BODY 
        ##*=============================================

        		
		##*===============================================
		##* POST-INSTALLATION
		##*===============================================
		[string]$installPhase = 'Post-Installation'

		## <Perform Post-Installation tasks here>

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
		Show-InstallationWelcome -CloseApps 'NoAppToClose' -CloseAppsCountdown 300

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
		Remove-File -Path "$env:SystemDrive\Temp\Clean-CMClientCache.log" -ContinueOnError $True
        Remove-File -Path "$env:SystemDrive\Temp" -Recurse -ContinueOnError $True
        Remove-File -Path "$env:SystemRoot\logs\Software\Clean-CMClientCache.log" -ContinueOnError $True
        
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
