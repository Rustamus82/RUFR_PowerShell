<#
.SYNOPSIS

PSApppDeployToolkit - This script performs the installation or uninstallation of an application(s).

.DESCRIPTION

- The script is provided as a template to perform an install or uninstall of an application(s).
- The script either performs an "Install" deployment type or an "Uninstall" deployment type.
- The install deployment type is broken down into 3 main sections/phases: Pre-Install, Install, and Post-Install.

The script dot-sources the AppDeployToolkitMain.ps1 script which contains the logic and functions required to install or uninstall an application.

PSApppDeployToolkit is licensed under the GNU LGPLv3 License - (C) 2023 PSAppDeployToolkit Team (Sean Lillis, Dan Cunningham and Muhammad Mashwani).

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
    }
    Catch {
    }

    ##*===============================================
    ##* VARIABLE DECLARATION
    ##*===============================================
    ## Variables: Application
    [String]$appVendor = 'Cisco Systems, Inc.'
    [String]$appName = 'Cisco AnyConnect Secure Mobility Client'
    [String]$appVersion = '4.10.08025'
    [String]$appArch = '32-bit'
    [String]$appLang = 'EN'
    [String]$appRevision = '01'
    [String]$appScriptVersion = '1.0.0'
    [String]$appScriptDate = '09/08/2024'
	[string]$appScriptAuthor = 'Rust@m'
    [string]$ProductCode = ''
    [string]$installFile = "anyconnect-win-4.10.08025-core-vpn-predeploy-k9.msi"
    ##*===============================================
    ## Variables: Install Titles (Only set here to override defaults set by the toolkit)
    [String]$installName = "$appName $appVersion"
    [String]$installTitle = "$appName $appVersion"

    
    ##* Do not modify section below
    #region DoNotModify

    ## Variables: Exit Code
    [Int32]$mainExitCode = 0

    ## Variables: Script
    [String]$deployAppScriptFriendlyName = 'Deploy Application'
    [Version]$deployAppScriptVersion = [Version]'3.9.3'
    [String]$deployAppScriptDate = '02/05/2023'
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
    ##* END VARIABLE DECLARATION
    ##*===============================================

    If ($deploymentType -ine 'Uninstall' -and $deploymentType -ine 'Repair') {
        ##*===============================================
        ##* PRE-INSTALLATION
        ##*===============================================
        [String]$installPhase = 'Pre-Installation'

        ## Show Welcome Message, close Internet Explorer if required, allow up to 3 deferrals, verify there is enough disk space to complete the install, and persist the prompt
        #Show-InstallationWelcome -CloseApps 'vpnui' -AllowDefer -DeferTimes 3 -CheckDiskSpace -PersistPrompt
        Show-InstallationWelcome -CloseApps 'vpnui' -AllowDeferCloseApps -DeferTimes 3 -CheckDiskSpace -ForceCloseAppsCountdown 600

        ## Show Progress Message (with the default message)
        Show-InstallationProgress

        ## <Perform Pre-Installation tasks here>
        $staus = Get-NetIPConfiguration | Where-Object {$_.InterfaceDescription -like "*Cisco AnyConnect*"}

        if ($staus.InterfaceDescription -eq "Cisco AnyConnect Secure Mobility Client Virtual Miniport Adapter for Windows x64")
        {
            Write-Log -Message "VPN connection in use, skipping installation" -LogType CMTrace -ErrorAction SilentlyContinue
            Execute-ProcessAsUser -Path "$envProgramFilesX86\Cisco\Cisco AnyConnect Secure Mobility Client\vpnui.exe" 
            Exit-Script -ExitCode 60012
        }
        else
        {
            Remove-MSIApplications -Name 'Cisco AnyConnect Secure Mobility Client*' -WildCard -FilterApplication (,('Publisher','Cisco Systems*','WildCard')) -ContinueOnError $true

        }


        ##*===============================================
        ##* INSTALLATION
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
        $staus = Get-NetIPConfiguration | Where-Object {$_.InterfaceDescription -like "*Cisco AnyConnect*"}

        if ($staus.InterfaceDescription -eq "Cisco AnyConnect Secure Mobility Client Virtual Miniport Adapter for Windows x64")
        {
            Write-Log -Message "VPN connection in use, skipping installation" -LogType CMTrace -ErrorAction SilentlyContinue
            Execute-ProcessAsUser -Path "$envProgramFilesX86\Cisco\Cisco AnyConnect Secure Mobility Client\vpnui.exe" 
            Exit-Script -ExitCode 60012              
        }
        else
        {
            Execute-MSI -Action Install -Path "$dirFiles\$installFile" -AddParameters "ALLUSERS=`"2`" ADDLOCAL=`"ALL`""
        }



        ##*===============================================
        ##* POST-INSTALLATION
        ##*===============================================
        [String]$installPhase = 'Post-Installation'

        ## <Perform Post-Installation tasks here>
        
        #Cisco profile
        if (Test-Path -Path "$env:ProgramData\Cisco\Cisco AnyConnect Secure Mobility Client\Profile\cembra.ras.cert.xml") {Remove-File -Path "$env:ProgramData\Cisco\Cisco AnyConnect Secure Mobility Client\Profile\cembra.ras.cert.xml" -ContinueOnError $true}
        Copy-File -Path "$dirSupportFiles\cembra.ras.cert.xml" -Destination "$env:ProgramData\Cisco\Cisco AnyConnect Secure Mobility Client\Profile\cembra.ras.cert.xml"

        <## Display a message at the end of the install
        If (-not $useDefaultMsi) {
            Show-InstallationPrompt -Message 'You can customize text to appear at the end of an install or remove it completely for unattended installations.' -ButtonRightText 'OK' -Icon Information -NoWait
        }#>
    }
    ElseIf ($deploymentType -ieq 'Uninstall') {
        ##*===============================================
        ##* PRE-UNINSTALLATION
        ##*===============================================
        [String]$installPhase = 'Pre-Uninstallation'

        ## Show Welcome Message, close Internet Explorer with a 600 second countdown before automatically closing
        Show-InstallationWelcome -CloseApps 'vpnui' -CloseAppsCountdown 600

        ## Show Progress Message (with the default message)
        Show-InstallationProgress

        ## <Perform Pre-Uninstallation tasks here>


        ##*===============================================
        ##* UNINSTALLATION
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
        $staus = Get-NetIPConfiguration | Where-Object {$_.InterfaceDescription -like "*Cisco AnyConnect*"}

        if ($staus.InterfaceDescription -eq "Cisco AnyConnect Secure Mobility Client Virtual Miniport Adapter for Windows x64")
        {
            Write-Log -Message "VPN connection in use, skipping installation" -LogType CMTrace -ErrorAction SilentlyContinue
            Execute-ProcessAsUser -Path "$envProgramFilesX86\Cisco\Cisco AnyConnect Secure Mobility Client\vpnui.exe"
            Exit-Script -ExitCode 60012
        }
        else
        {
            Remove-MSIApplications -Name 'Cisco AnyConnect Secure Mobility Client*' -WildCard -FilterApplication (,('Publisher','Cisco Systems*','WildCard')) -ContinueOnError $true

        }

        ##*===============================================
        ##* POST-UNINSTALLATION
        ##*===============================================
        [String]$installPhase = 'Post-Uninstallation'

        ## <Perform Post-Uninstallation tasks here>
        if (Test-Path -Path "$env:ProgramData\Cisco\Cisco AnyConnect Secure Mobility Client") {Remove-File -Path "$env:ProgramData\Cisco\Cisco AnyConnect Secure Mobility Client" -Recurse -ContinueOnError $true}

    }
    ElseIf ($deploymentType -ieq 'Repair') {
        ##*===============================================
        ##* PRE-REPAIR
        ##*===============================================
        [String]$installPhase = 'Pre-Repair'

        ## Show Welcome Message, close Internet Explorer with a 60 second countdown before automatically closing
        Show-InstallationWelcome -CloseApps 'vpnui' -CloseAppsCountdown 60

        ## Show Progress Message (with the default message)
        Show-InstallationProgress

        ## <Perform Pre-Repair tasks here>

        ##*===============================================
        ##* REPAIR
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
        ##* POST-REPAIR
        ##*===============================================
        [String]$installPhase = 'Post-Repair'

        ## <Perform Post-Repair tasks here>


    }
    ##*===============================================
    ##* END SCRIPT BODY
    ##*===============================================

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

# SIG # Begin signature block
# MIIiTAYJKoZIhvcNAQcCoIIiPTCCIjkCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUynL9xfRLiRKI0yUimsnCVSPe
# aqKgghuUMIIFjTCCBHWgAwIBAgIQDpsYjvnQLefv21DiCEAYWjANBgkqhkiG9w0B
# AQwFADBlMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYD
# VQQLExB3d3cuZGlnaWNlcnQuY29tMSQwIgYDVQQDExtEaWdpQ2VydCBBc3N1cmVk
# IElEIFJvb3QgQ0EwHhcNMjIwODAxMDAwMDAwWhcNMzExMTA5MjM1OTU5WjBiMQsw
# CQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3d3cu
# ZGlnaWNlcnQuY29tMSEwHwYDVQQDExhEaWdpQ2VydCBUcnVzdGVkIFJvb3QgRzQw
# ggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQC/5pBzaN675F1KPDAiMGkz
# 7MKnJS7JIT3yithZwuEppz1Yq3aaza57G4QNxDAf8xukOBbrVsaXbR2rsnnyyhHS
# 5F/WBTxSD1Ifxp4VpX6+n6lXFllVcq9ok3DCsrp1mWpzMpTREEQQLt+C8weE5nQ7
# bXHiLQwb7iDVySAdYyktzuxeTsiT+CFhmzTrBcZe7FsavOvJz82sNEBfsXpm7nfI
# SKhmV1efVFiODCu3T6cw2Vbuyntd463JT17lNecxy9qTXtyOj4DatpGYQJB5w3jH
# trHEtWoYOAMQjdjUN6QuBX2I9YI+EJFwq1WCQTLX2wRzKm6RAXwhTNS8rhsDdV14
# Ztk6MUSaM0C/CNdaSaTC5qmgZ92kJ7yhTzm1EVgX9yRcRo9k98FpiHaYdj1ZXUJ2
# h4mXaXpI8OCiEhtmmnTK3kse5w5jrubU75KSOp493ADkRSWJtppEGSt+wJS00mFt
# 6zPZxd9LBADMfRyVw4/3IbKyEbe7f/LVjHAsQWCqsWMYRJUadmJ+9oCw++hkpjPR
# iQfhvbfmQ6QYuKZ3AeEPlAwhHbJUKSWJbOUOUlFHdL4mrLZBdd56rF+NP8m800ER
# ElvlEFDrMcXKchYiCd98THU/Y+whX8QgUWtvsauGi0/C1kVfnSD8oR7FwI+isX4K
# Jpn15GkvmB0t9dmpsh3lGwIDAQABo4IBOjCCATYwDwYDVR0TAQH/BAUwAwEB/zAd
# BgNVHQ4EFgQU7NfjgtJxXWRM3y5nP+e6mK4cD08wHwYDVR0jBBgwFoAUReuir/SS
# y4IxLVGLp6chnfNtyA8wDgYDVR0PAQH/BAQDAgGGMHkGCCsGAQUFBwEBBG0wazAk
# BggrBgEFBQcwAYYYaHR0cDovL29jc3AuZGlnaWNlcnQuY29tMEMGCCsGAQUFBzAC
# hjdodHRwOi8vY2FjZXJ0cy5kaWdpY2VydC5jb20vRGlnaUNlcnRBc3N1cmVkSURS
# b290Q0EuY3J0MEUGA1UdHwQ+MDwwOqA4oDaGNGh0dHA6Ly9jcmwzLmRpZ2ljZXJ0
# LmNvbS9EaWdpQ2VydEFzc3VyZWRJRFJvb3RDQS5jcmwwEQYDVR0gBAowCDAGBgRV
# HSAAMA0GCSqGSIb3DQEBDAUAA4IBAQBwoL9DXFXnOF+go3QbPbYW1/e/Vwe9mqyh
# hyzshV6pGrsi+IcaaVQi7aSId229GhT0E0p6Ly23OO/0/4C5+KH38nLeJLxSA8hO
# 0Cre+i1Wz/n096wwepqLsl7Uz9FDRJtDIeuWcqFItJnLnU+nBgMTdydE1Od/6Fmo
# 8L8vC6bp8jQ87PcDx4eo0kxAGTVGamlUsLihVo7spNU96LHc/RzY9HdaXFSMb++h
# UD38dglohJ9vytsgjTVgHAIDyyCwrFigDkBjxZgiwbJZ9VVrzyerbHbObyMt9H5x
# aiNrIv8SuFQtJ37YOtnwtoeW/VvRXKwYw02fc7cBqZ9Xql4o4rmUMIIGrjCCBJag
# AwIBAgIQBzY3tyRUfNhHrP0oZipeWzANBgkqhkiG9w0BAQsFADBiMQswCQYDVQQG
# EwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3d3cuZGlnaWNl
# cnQuY29tMSEwHwYDVQQDExhEaWdpQ2VydCBUcnVzdGVkIFJvb3QgRzQwHhcNMjIw
# MzIzMDAwMDAwWhcNMzcwMzIyMjM1OTU5WjBjMQswCQYDVQQGEwJVUzEXMBUGA1UE
# ChMORGlnaUNlcnQsIEluYy4xOzA5BgNVBAMTMkRpZ2lDZXJ0IFRydXN0ZWQgRzQg
# UlNBNDA5NiBTSEEyNTYgVGltZVN0YW1waW5nIENBMIICIjANBgkqhkiG9w0BAQEF
# AAOCAg8AMIICCgKCAgEAxoY1BkmzwT1ySVFVxyUDxPKRN6mXUaHW0oPRnkyibaCw
# zIP5WvYRoUQVQl+kiPNo+n3znIkLf50fng8zH1ATCyZzlm34V6gCff1DtITaEfFz
# sbPuK4CEiiIY3+vaPcQXf6sZKz5C3GeO6lE98NZW1OcoLevTsbV15x8GZY2UKdPZ
# 7Gnf2ZCHRgB720RBidx8ald68Dd5n12sy+iEZLRS8nZH92GDGd1ftFQLIWhuNyG7
# QKxfst5Kfc71ORJn7w6lY2zkpsUdzTYNXNXmG6jBZHRAp8ByxbpOH7G1WE15/teP
# c5OsLDnipUjW8LAxE6lXKZYnLvWHpo9OdhVVJnCYJn+gGkcgQ+NDY4B7dW4nJZCY
# OjgRs/b2nuY7W+yB3iIU2YIqx5K/oN7jPqJz+ucfWmyU8lKVEStYdEAoq3NDzt9K
# oRxrOMUp88qqlnNCaJ+2RrOdOqPVA+C/8KI8ykLcGEh/FDTP0kyr75s9/g64ZCr6
# dSgkQe1CvwWcZklSUPRR8zZJTYsg0ixXNXkrqPNFYLwjjVj33GHek/45wPmyMKVM
# 1+mYSlg+0wOI/rOP015LdhJRk8mMDDtbiiKowSYI+RQQEgN9XyO7ZONj4KbhPvbC
# dLI/Hgl27KtdRnXiYKNYCQEoAA6EVO7O6V3IXjASvUaetdN2udIOa5kM0jO0zbEC
# AwEAAaOCAV0wggFZMBIGA1UdEwEB/wQIMAYBAf8CAQAwHQYDVR0OBBYEFLoW2W1N
# hS9zKXaaL3WMaiCPnshvMB8GA1UdIwQYMBaAFOzX44LScV1kTN8uZz/nupiuHA9P
# MA4GA1UdDwEB/wQEAwIBhjATBgNVHSUEDDAKBggrBgEFBQcDCDB3BggrBgEFBQcB
# AQRrMGkwJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBBBggr
# BgEFBQcwAoY1aHR0cDovL2NhY2VydHMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0VHJ1
# c3RlZFJvb3RHNC5jcnQwQwYDVR0fBDwwOjA4oDagNIYyaHR0cDovL2NybDMuZGln
# aWNlcnQuY29tL0RpZ2lDZXJ0VHJ1c3RlZFJvb3RHNC5jcmwwIAYDVR0gBBkwFzAI
# BgZngQwBBAIwCwYJYIZIAYb9bAcBMA0GCSqGSIb3DQEBCwUAA4ICAQB9WY7Ak7Zv
# mKlEIgF+ZtbYIULhsBguEE0TzzBTzr8Y+8dQXeJLKftwig2qKWn8acHPHQfpPmDI
# 2AvlXFvXbYf6hCAlNDFnzbYSlm/EUExiHQwIgqgWvalWzxVzjQEiJc6VaT9Hd/ty
# dBTX/6tPiix6q4XNQ1/tYLaqT5Fmniye4Iqs5f2MvGQmh2ySvZ180HAKfO+ovHVP
# ulr3qRCyXen/KFSJ8NWKcXZl2szwcqMj+sAngkSumScbqyQeJsG33irr9p6xeZmB
# o1aGqwpFyd/EjaDnmPv7pp1yr8THwcFqcdnGE4AJxLafzYeHJLtPo0m5d2aR8XKc
# 6UsCUqc3fpNTrDsdCEkPlM05et3/JWOZJyw9P2un8WbDQc1PtkCbISFA0LcTJM3c
# HXg65J6t5TRxktcma+Q4c6umAU+9Pzt4rUyt+8SVe+0KXzM5h0F4ejjpnOHdI/0d
# KNPH+ejxmF/7K9h+8kaddSweJywm228Vex4Ziza4k9Tm8heZWcpw8De/mADfIBZP
# J/tgZxahZrrdVcA6KYawmKAr7ZVBtzrVFZgxtGIJDwq9gdkT/r+k0fNX2bwE+oLe
# Mt8EifAAzV3C+dAjfwAL5HYCJtnwZXZCpimHCUcr5n8apIUP/JiW9lVUKx+A+sDy
# Divl1vupL0QVSucTDh3bNzgaoSv27dZ8/DCCBsIwggSqoAMCAQICEAVEr/OUnQg5
# pr/bP1/lYRYwDQYJKoZIhvcNAQELBQAwYzELMAkGA1UEBhMCVVMxFzAVBgNVBAoT
# DkRpZ2lDZXJ0LCBJbmMuMTswOQYDVQQDEzJEaWdpQ2VydCBUcnVzdGVkIEc0IFJT
# QTQwOTYgU0hBMjU2IFRpbWVTdGFtcGluZyBDQTAeFw0yMzA3MTQwMDAwMDBaFw0z
# NDEwMTMyMzU5NTlaMEgxCzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5EaWdpQ2VydCwg
# SW5jLjEgMB4GA1UEAxMXRGlnaUNlcnQgVGltZXN0YW1wIDIwMjMwggIiMA0GCSqG
# SIb3DQEBAQUAA4ICDwAwggIKAoICAQCjU0WHHYOOW6w+VLMj4M+f1+XS512hDgnc
# L0ijl3o7Kpxn3GIVWMGpkxGnzaqyat0QKYoeYmNp01icNXG/OpfrlFCPHCDqx5o7
# L5Zm42nnaf5bw9YrIBzBl5S0pVCB8s/LB6YwaMqDQtr8fwkklKSCGtpqutg7yl3e
# GRiF+0XqDWFsnf5xXsQGmjzwxS55DxtmUuPI1j5f2kPThPXQx/ZILV5FdZZ1/t0Q
# oRuDwbjmUpW1R9d4KTlr4HhZl+NEK0rVlc7vCBfqgmRN/yPjyobutKQhZHDr1eWg
# 2mOzLukF7qr2JPUdvJscsrdf3/Dudn0xmWVHVZ1KJC+sK5e+n+T9e3M+Mu5SNPvU
# u+vUoCw0m+PebmQZBzcBkQ8ctVHNqkxmg4hoYru8QRt4GW3k2Q/gWEH72LEs4VGv
# tK0VBhTqYggT02kefGRNnQ/fztFejKqrUBXJs8q818Q7aESjpTtC/XN97t0K/3k0
# EH6mXApYTAA+hWl1x4Nk1nXNjxJ2VqUk+tfEayG66B80mC866msBsPf7Kobse1I4
# qZgJoXGybHGvPrhvltXhEBP+YUcKjP7wtsfVx95sJPC/QoLKoHE9nJKTBLRpcCcN
# T7e1NtHJXwikcKPsCvERLmTgyyIryvEoEyFJUX4GZtM7vvrrkTjYUQfKlLfiUKHz
# OtOKg8tAewIDAQABo4IBizCCAYcwDgYDVR0PAQH/BAQDAgeAMAwGA1UdEwEB/wQC
# MAAwFgYDVR0lAQH/BAwwCgYIKwYBBQUHAwgwIAYDVR0gBBkwFzAIBgZngQwBBAIw
# CwYJYIZIAYb9bAcBMB8GA1UdIwQYMBaAFLoW2W1NhS9zKXaaL3WMaiCPnshvMB0G
# A1UdDgQWBBSltu8T5+/N0GSh1VapZTGj3tXjSTBaBgNVHR8EUzBRME+gTaBLhklo
# dHRwOi8vY3JsMy5kaWdpY2VydC5jb20vRGlnaUNlcnRUcnVzdGVkRzRSU0E0MDk2
# U0hBMjU2VGltZVN0YW1waW5nQ0EuY3JsMIGQBggrBgEFBQcBAQSBgzCBgDAkBggr
# BgEFBQcwAYYYaHR0cDovL29jc3AuZGlnaWNlcnQuY29tMFgGCCsGAQUFBzAChkxo
# dHRwOi8vY2FjZXJ0cy5kaWdpY2VydC5jb20vRGlnaUNlcnRUcnVzdGVkRzRSU0E0
# MDk2U0hBMjU2VGltZVN0YW1waW5nQ0EuY3J0MA0GCSqGSIb3DQEBCwUAA4ICAQCB
# GtbeoKm1mBe8cI1PijxonNgl/8ss5M3qXSKS7IwiAqm4z4Co2efjxe0mgopxLxjd
# TrbebNfhYJwr7e09SI64a7p8Xb3CYTdoSXej65CqEtcnhfOOHpLawkA4n13IoC4l
# eCWdKgV6hCmYtld5j9smViuw86e9NwzYmHZPVrlSwradOKmB521BXIxp0bkrxMZ7
# z5z6eOKTGnaiaXXTUOREEr4gDZ6pRND45Ul3CFohxbTPmJUaVLq5vMFpGbrPFvKD
# NzRusEEm3d5al08zjdSNd311RaGlWCZqA0Xe2VC1UIyvVr1MxeFGxSjTredDAHDe
# zJieGYkD6tSRN+9NUvPJYCHEVkft2hFLjDLDiOZY4rbbPvlfsELWj+MXkdGqwFXj
# hr+sJyxB0JozSqg21Llyln6XeThIX8rC3D0y33XWNmdaifj2p8flTzU8AL2+nCps
# eQHc2kTmOt44OwdeOVj0fHMxVaCAEcsUDH6uvP6k63llqmjWIso765qCNVcoFstp
# 8jKastLYOrixRoZruhf9xHdsFWyuq69zOuhJRrfVf8y2OMDY7Bz1tqG4QyzfTkx9
# HmhwwHcK1ALgXGC7KP845VJa1qwXIiNO9OzTF/tQa/8Hdx9xl0RBybhG02wyfFgv
# Z0dl5Rtztpn5aywGRu9BHvDwX+Db2a2QgESvgBBBijCCCIcwggZvoAMCAQICEyoA
# AnWS4v8I3gH41BMAAAACdZIwDQYJKoZIhvcNAQELBQAwRjESMBAGCgmSJomT8ixk
# ARkWAmNoMRswGQYKCZImiZPyLGQBGRYLY2VtYnJhaW50cmExEzARBgNVBAMTCkNl
# bWJyYUNvcmUwHhcNMjMwOTIxMTUxNTMwWhcNMjQwOTIwMTUxNTMwWjCBojESMBAG
# CgmSJomT8ixkARkWAmNoMRswGQYKCZImiZPyLGQBGRYLY2VtYnJhaW50cmExDTAL
# BgNVBAsTBFBGMDAxEjAQBgNVBAsMCVBGMDBfVXNlcjEUMBIGA1UECwwLUEYwMF9Q
# ZXJzb24xGTAXBgNVBAsMEFBGMDBfTm9uUGVyc29uYWwxGzAZBgNVBAMTElBvd2Vy
# c2hlbGxDb2RlU2lnbjCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAL5j
# oTFOuokst/536RWqz8GT64cnsNsUie80k1q3ii2hJx7L0s3+LQDuodzBWIJCA5JA
# hyeTOXIZig/U2n/bZj4F/T83uFsZ7HM2r98l0HFkyKwEtSxRI77C8hH+/O4SyS70
# tSlU+r8FaGa3JEqxC3R1oE0eU7PRLZfcOHgYdyN1xlydXgteSL1hfOeGRg6k1jWO
# aPQ6pQrAbPsby8po9AV7pe/4ibiNyTdgGADu2nY3izPdrS4i8s0fjByU9k8hGIVI
# s8pQGV7fB7OtgcmBhGo1EWXEuaMhk9TfPEIxTanx1xWaG7IPVQCkYaR2wYnivY2m
# 39A6BP506T74xuEr+mfoj+Trt8hNmyzczVD4XWS7LZCmG3hrb9NEP8E8AuFOPM/R
# Jiqam/Efj8jfqwFsoydUi0ymmfdMMOkoBH3wF2WJdn3pN79UkLEvgtE4An6W4WP/
# t6yGa2xdK3uiyLUiQvD3twuw9sHp9J4eSbXwI8tv5ApWiZHkAMh7Bqhm3ZhdrMZG
# AsBvhH8Y6h46UsD3YfQ+nU+jZ4viMViYJaaJ8KUhWxHzT/dwIuAIf20hzKMwDsvH
# /g2ZWB6Wf/0SLh5y1M7lLhWcs5STrCO0SKgAe1YaXB+o9Ly1dykgd/x6Z2tyydjC
# CT0fKFw4rVvsF1LCneQeiF7IAl09NPaIjuS/P8gxAgMBAAGjggMPMIIDCzAOBgNV
# HQ8BAf8EBAMCB4AwEwYDVR0lBAwwCgYIKwYBBQUHAwMwHQYDVR0OBBYEFGqwsryd
# Bza3soIhJ7l690fySPDEMB8GA1UdIwQYMBaAFHE/4AcfQZmeOX/AeR9uZrYSEBsN
# MIH2BgNVHR8Ege4wgeswgeiggeWggeKGgbVsZGFwOi8vL0NOPUNlbWJyYUNvcmUs
# Q049c2IwMDQ4MjcsQ049Q0RQLENOPVB1YmxpYyUyMEtleSUyMFNlcnZpY2VzLENO
# PVNlcnZpY2VzLENOPUNvbmZpZ3VyYXRpb24sREM9Y2VtYnJhaW50cmEsREM9Y2g/
# Y2VydGlmaWNhdGVSZXZvY2F0aW9uTGlzdD9iYXNlP29iamVjdENsYXNzPWNSTERp
# c3RyaWJ1dGlvblBvaW50hihodHRwOi8vY3JsLmNlbWJyYWludHJhLmNoL2NlbWJy
# YWNvcmUuY3JsMIG/BggrBgEFBQcBAQSBsjCBrzCBrAYIKwYBBQUHMAKGgZ9sZGFw
# Oi8vL0NOPUNlbWJyYUNvcmUsQ049QUlBLENOPVB1YmxpYyUyMEtleSUyMFNlcnZp
# Y2VzLENOPVNlcnZpY2VzLENOPUNvbmZpZ3VyYXRpb24sREM9Y2VtYnJhaW50cmEs
# REM9Y2g/Y0FDZXJ0aWZpY2F0ZT9iYXNlP29iamVjdENsYXNzPWNlcnRpZmljYXRp
# b25BdXRob3JpdHkwPQYJKwYBBAGCNxUHBDAwLgYmKwYBBAGCNxUIhNiZf4T+pTOB
# rYMhgcauXYHjtDkAhKm9d4bu2XICAWQCAQQwGwYJKwYBBAGCNxUKBA4wDDAKBggr
# BgEFBQcDAzA8BgNVHREENTAzoDEGCisGAQQBgjcUAgOgIwwhUG93ZXJzaGVsbENv
# ZGVTaWduQGNlbWJyYWludHJhLmNoME8GCSsGAQQBgjcZAgRCMECgPgYKKwYBBAGC
# NxkCAaAwBC5TLTEtNS0yMS0yOTkzNjU1Nzg4LTE2OTQ5OTU0OS0zMzI3OTczNjU0
# LTkxOTg0MA0GCSqGSIb3DQEBCwUAA4ICAQAhSzQBZb7ZUOI6c5F6HP5i/q6yAJKi
# bR9ckX6bunyrz08CNTCNo/mRcWra76KdmjPsySfJJfnIFgobUJ7H8eRrSCE+V4Wp
# c9JOKFnMZtRduy262uQJNw3RHSjUEqU+8AVrSFehuxmCQfHlEPl6cwZelIXrrrk3
# Z/mWNM3ZUURQ0z5BbJ92Q5BavBT9Jtm6NgiqwMqoX92gsB8k50b0KzAx9i//B2iF
# 7AaZ/8e+l8YZmIXhUht8aS8UmloKqtqi3UksaGnNxhrYnZ8g93TCiYhhmZix0FK2
# J2WB5YPMFbGKtMkAXgElddHr1MAgLuBcKSV6ZTB9koJ1uXriO/KSYh95VSRRcTu7
# cHOpyiYi1m/YKJQZ1ccMN1QBtcXQLeSCQ80oWtStWUMyOKsDSRktzSPRA7pie7zJ
# jhV4QSkY6LkWr3jNgKMc5gXxnKZWq3snG/N/wlKwY1V+e8DD0vzb9XaXLCP8vRUz
# EYTOVPliftuH7khQ5f6X0kpaNlVVSrdFHYsfrrHk8G9ECPQT0bkg74KH6lHqcsX8
# M6NJL2hGlnhfE4bFmMc2dLgY2smreqAWOStOSuF/mzjgWqr4RZDeN1vGvMrxUz2N
# ijrUAjdkImFjHzCT6rBu1cJ6JzXZzgZckGyQp9RHd5biJYnr5EhaWMhOGvUQ9zXj
# ksmb6RNDDWGMmjGCBiIwggYeAgEBMF0wRjESMBAGCgmSJomT8ixkARkWAmNoMRsw
# GQYKCZImiZPyLGQBGRYLY2VtYnJhaW50cmExEzARBgNVBAMTCkNlbWJyYUNvcmUC
# EyoAAnWS4v8I3gH41BMAAAACdZIwCQYFKw4DAhoFAKB4MBgGCisGAQQBgjcCAQwx
# CjAIoAKAAKECgAAwGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQwHAYKKwYBBAGC
# NwIBCzEOMAwGCisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYEFEvUGNOi2iZc1ZCb
# SOeop2jp9oh8MA0GCSqGSIb3DQEBAQUABIICAGMx8igvW/gmdezn9girVTmp9BgU
# bMyNeaPgISaBcN3dewC/USx6wf6KNSXBt1VTt89NVLQlgiJSWJ8sRClgcLNxbvX/
# wUfwqr82ui02SQRaBkpAv2/Al1yYbknbSRnAw0F2PtebrHSl6kCJREKPqXMcSieJ
# xbkP210DdCyTenkk9MPAHGqcz+E1mb/h177JLIyn0JEQ4OPZp7dRHMls77OpqPy8
# Fd4sRapLq90NxtbS2ldGni/vEIpI8NCOFCmbSFTlW8zItJ9gpKJmzKevWafctJAq
# NkW4lH5frztuk7epeh/MilnuxZSWISZdOeRdMashDQ7Cn+AG2hTm9bWVojQTStk2
# ZVlbamK/Sn61Ny9rcT8afsZFndej2t/NBvww3zJg9fd4mEhRbAJOwYrRsKLNz6J2
# IUTZ0Ufl0fUlcVkN34/sOH4ybvdXj9CX6yqGDdBPl9jPEaFydNkcTsD70/552diu
# yLht+M9+v14OnhQLNGwjDnyji4fvwDYpdIJv4WBCHny7NvUYnr2bdQNcUgXhZWIM
# gqbUoJFtiObohTU+BApBjWYhahhn4cqURhfyYfjVns//3RIqbrRGmnNCgQzSnNyz
# qHwBcyaLW2cAaGOzskQrZw1sPb8sMQBQcU1XLrcLBJ6Em0VFZ8l3aJSFvqnJVukY
# gaeXYyBzw4MAxlEooYIDIDCCAxwGCSqGSIb3DQEJBjGCAw0wggMJAgEBMHcwYzEL
# MAkGA1UEBhMCVVMxFzAVBgNVBAoTDkRpZ2lDZXJ0LCBJbmMuMTswOQYDVQQDEzJE
# aWdpQ2VydCBUcnVzdGVkIEc0IFJTQTQwOTYgU0hBMjU2IFRpbWVTdGFtcGluZyBD
# QQIQBUSv85SdCDmmv9s/X+VhFjANBglghkgBZQMEAgEFAKBpMBgGCSqGSIb3DQEJ
# AzELBgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTI0MDgwOTEwMTcxOFowLwYJ
# KoZIhvcNAQkEMSIEIKeBfegEdW1cmu5VxIdVwTcvG8yQDlUkS4RRhZ/8eXCIMA0G
# CSqGSIb3DQEBAQUABIICAAZxplw0NgDUYVLcjBAq0GlnbNXyCfnRH7eCCS8LAJr4
# U+DQOEtnIyncfev68D17N51FZJSwqQ4cDoBO+bU7+6AKcnmTsF1ck1THwevxeL12
# 2rgPDNnj6J8NKJD2XaAqWv4zjiLubfHfDj0h8J+BRLXGkh3GzYPuxvpFHaZtCAv1
# hUQ+K420elg7d+SjDhc84Pot6e+dqRoSBB7ZVLLkdSdo8fcbdfn9oaZeo3ttGBt2
# FgpqG5itaWx/9g0OygrrYlk9Kivwc1ROTaAyO+6mfBGLpCkGXCHhjdV/r/fnjIkz
# FuqG8wLJOQdqSa4tceZRmXzOU7ExK6dk2dRVYdG1TUJKLh89kdQ/CtZtFyJCs6PR
# UkrsFy/zX5Lnru9drT3D5FUAZB7sJFyrzlSk1NSxqWhQ6zUTpuHWUsU4C4VKLz0l
# sF8mPR1aVR8iFU4Wh77vcQfBknVxk/fnU1uoBK77LPTL5Xjsq5xh8gDMCNuGm3rI
# TG4F2qIqGuSZ8tcEZPYWRXw6QrqiiXh62qgtrORQ9G8rniyR7UuuqrlhWQwnef1n
# AVBZGXp4gQWaB8/Os4Tr0dXW5hNrBfx1LQ4KBI3HmF3Lzj9Jo9Jv0Vla+nZURFqu
# BNSdWkuctS48AmnkT0HfS2O3pL7iFBZKpHf8hT0gAbA+Tks2p5bhDnuHJbFTBeqJ
# SIG # End signature block
