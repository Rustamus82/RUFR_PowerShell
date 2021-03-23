#Requires -Version 5.0
using namespace System.Collections.Generic
using namespace System.Security.Principal

[cmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [ValidateSet('Host', 'File', 'EventLog', 'None')]
    [Alias('Logging')]
    [string[]]$LoggingOptions = @('Host', 'File', 'EventLog'),
    [Parameter(Mandatory = $false)]
    [string]$LogName = 'Configuration Manager',
    [Parameter(Mandatory = $false)]
    [string]$LogSource = 'Invoke-CleanMgrEx',
    [Parameter(Mandatory = $false)]
    [switch]$LogDebugMessages = $false
)

process {
    $BeforeVol = Get-FreeDiskSpace -Volume c:
    Write-Output -InputObject $('{0} available disk space before disk cleanup on volume "{1}"' -f $BeforeVol.Percentage, $BeforeVol.DeviceID)
    Write-Verbose -Message $BeforeVol.FreeSpace
    
    Write-Verbose -Message 'Launching cleanmgr as an external process'
    Invoke-CleanMgr -Index 5432 > $null

    Write-Verbose -Message 'Clear BranchCache'
    Clear-BCCacheEx -force

    Write-Verbose -Message 'Remove old user profiles'
    Clear-OldUserProfiles -Months 6

    Write-Verbose -Message 'Clear Orphaned items from the ConfigMgr cache folder'
    Remove-CCMOrphanedCache

    Write-Verbose -Message 'Clear ConfigMgr Cache'
    Clear-ConfigMgrCache
        
    $AfterVol = Get-FreeDiskSpace -Volume c:
    Write-Output -InputObject $('{0} available disk space before disk cleanup on volume "{1}"' -f $AfterVol.Percentage, $AfterVol.DeviceID)
    Write-Verbose -Message $AfterVol.FreeSpace
    
    $SavedDiskSpace = $AfterVol.FreeSpace - $BeforeVol.FreeSpace
    if ($SavedDiskSpace -ge 0) {
        Write-Output -InputObject $('Available disk space increased with {0}' -f $(Format-Decimal -InputSize ([math]::abs($SavedDiskSpace)) -DecimalPlaces 2))
    }
    else {
        Write-Output -InputObject $('Available disk space decreased with {0}' -f $(Format-Decimal -InputSize ([math]::Abs($SavedDiskSpace)) -DecimalPlaces 2))
    }
}

begin {
    $script:LoggingOptions = $LoggingOptions
    $script:LogName = $LogName
    $script:LogSource = $LogSource
    $script:LogDebugMessages = $LogDebugMessages
    $script:ReferencedThreshold = $ReferencedThreshold

    Function Write-Log {
        <#
        .SYNOPSIS
            Write messages to a log file in CMTrace.exe compatible format or Legacy text file format.
        .DESCRIPTION
            Write messages to a log file in CMTrace.exe compatible format or Legacy text file format and optionally display in the console.
        .PARAMETER Message
            The message to write to the log file or output to the console.
        .PARAMETER Severity
            Defines message type. When writing to console or CMTrace.exe log format, it allows highlighting of message type.
            Options: 1 = Information (default), 2 = Warning (highlighted in yellow), 3 = Error (highlighted in red)
        .PARAMETER Source
            The source of the message being logged. Also used as the event log source.
        .PARAMETER ScriptSection
            The heading for the portion of the script that is being executed. Default is: $script:installPhase.
        .PARAMETER LogType
            Choose whether to write a CMTrace.exe compatible log file or a Legacy text log file.
        .PARAMETER LoggingOptions
            Choose where to log 'Console', 'File', 'EventLog' or 'None'. You can choose multiple options.
        .PARAMETER LogFileDirectory
            Set the directory where the log file will be saved.
        .PARAMETER LogFileName
            Set the name of the log file.
        .PARAMETER MaxLogFileSizeMB
            Maximum file size limit for log file in megabytes (MB). Default is 10 MB.
        .PARAMETER LogName
            Set the name of the event log.
        .PARAMETER EventID
            Set the event id for the event log entry.
        .PARAMETER WriteHost
            Write the log message to the console.
        .PARAMETER ContinueOnError
            Suppress writing log message to console on failure to write message to log file. Default is: $true.
        .PARAMETER PassThru
            Return the message that was passed to the function
        .PARAMETER VerboseMessage
            Specifies that the message is a debug message. Verbose messages only get logged if -LogDebugMessage is set to $true.
        .PARAMETER DebugMessage
            Specifies that the message is a debug message. Debug messages only get logged if -LogDebugMessage is set to $true.
        .PARAMETER LogDebugMessage
            Debug messages only get logged if this parameter is set to $true in the config XML file.
        .EXAMPLE
            Write-Log -Message "Installing patch MS15-031" -Source 'Add-Patch' -LogType 'CMTrace'
        .EXAMPLE
            Write-Log -Message "Script is running on Windows 8" -Source 'Test-ValidOS' -LogType 'Legacy'
        .NOTES
            Slightly modified version of the PSADT logging cmdlet. I did not write the original cmdlet, please do not credit me for it.
        .LINK
            https://psappdeploytoolkit.com
        #>
            [CmdletBinding()]
            Param (
                [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
                [AllowEmptyCollection()]
                [Alias('Text')]
                [string[]]$Message,
                [Parameter(Mandatory = $false, Position = 1)]
                [ValidateRange(1, 3)]
                [int16]$Severity = 1,
                [Parameter(Mandatory = $false, Position = 2)]
                [ValidateNotNullorEmpty()]
                [string]$Source = $script:LogSource,
                [Parameter(Mandatory = $false, Position = 3)]
                [ValidateNotNullorEmpty()]
                [string]$ScriptSection = $script:RunPhase,
                [Parameter(Mandatory = $false, Position = 4)]
                [ValidateSet('CMTrace', 'Legacy')]
                [string]$LogType = 'CMTrace',
                [Parameter(Mandatory = $false, Position = 5)]
                [ValidateSet('Host', 'File', 'EventLog', 'None')]
                [string[]]$LoggingOptions = $script:LoggingOptions,
                [Parameter(Mandatory = $false, Position = 6)]
                [ValidateNotNullorEmpty()]
                [string]$LogFileDirectory = $(Join-Path -Path $Env:WinDir -ChildPath $('\Logs\' + $script:LogName)),
                [Parameter(Mandatory = $false, Position = 7)]
                [ValidateNotNullorEmpty()]
                [string]$LogFileName = $($script:LogSource + '.log'),
                [Parameter(Mandatory = $false, Position = 8)]
                [ValidateNotNullorEmpty()]
                [int]$MaxLogFileSizeMB = '4',
                [Parameter(Mandatory = $false, Position = 9)]
                [ValidateNotNullorEmpty()]
                [string]$LogName = $script:LogName,
                [Parameter(Mandatory = $false, Position = 10)]
                [ValidateNotNullorEmpty()]
                [int32]$EventID = 1,
                [Parameter(Mandatory = $false, Position = 11)]
                [ValidateNotNullorEmpty()]
                [boolean]$ContinueOnError = $false,
                [Parameter(Mandatory = $false, Position = 12)]
                [switch]$PassThru = $false,
                [Parameter(Mandatory = $false, Position = 13)]
                [switch]$VerboseMessage = $false,
                [Parameter(Mandatory = $false, Position = 14)]
                [switch]$DebugMessage = $false,
                [Parameter(Mandatory = $false, Position = 15)]
                [boolean]$LogDebugMessage = $script:LogDebugMessages
            )
        
            Begin {
                ## Get the name of this function
                [string]${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name
        
                ## Logging Variables
                #  Log file date/time
                [string]$LogTime = (Get-Date -Format 'HH:mm:ss.fff').ToString()
                [string]$LogDate = (Get-Date -Format 'MM-dd-yyyy').ToString()
                If (-not (Test-Path -LiteralPath 'variable:LogTimeZoneBias')) { [int32]$script:LogTimeZoneBias = [timezone]::CurrentTimeZone.GetUtcOffset([datetime]::Now).TotalMinutes }
                [string]$LogTimePlusBias = $LogTime + '-' + $script:LogTimeZoneBias
                #  Initialize variables
                [boolean]$WriteHost = $false
                [boolean]$WriteFile = $false
                [boolean]$WriteEvent = $false
                [boolean]$DisableLogging = $false
                [boolean]$ExitLoggingFunction = $false
                If (('Host' -in $LoggingOptions) -and (-not ($VerboseMessage -or $DebugMessage))) { $WriteHost = $true }
                If ('File' -in $LoggingOptions) { $WriteFile = $true }
                If ('EventLog' -in $LoggingOptions) { $WriteEvent = $true }
                If ('None' -in $LoggingOptions) { $DisableLogging = $true }
                #  Check if the script section is defined
                [boolean]$ScriptSectionDefined = [boolean](-not [string]::IsNullOrEmpty($ScriptSection))
                #  Check if the source is defined
                [boolean]$SourceDefined = [boolean](-not [string]::IsNullOrEmpty($Source))
                #  Check if the event log and event source exit
                [boolean]$LogNameNotExists = (-not [System.Diagnostics.EventLog]::Exists($LogName))
                [boolean]$LogSourceNotExists = (-not [System.Diagnostics.EventLog]::SourceExists($Source))
        
                ## Create script block for generating CMTrace.exe compatible log entry
                [scriptblock]$CMTraceLogString = {
                    Param (
                        [string]$lMessage,
                        [string]$lSource,
                        [int16]$lSeverity
                    )
                    "<![LOG[$lMessage]LOG]!>" + "<time=`"$LogTimePlusBias`" " + "date=`"$LogDate`" " + "component=`"$lSource`" " + "context=`"$([Security.Principal.WindowsIdentity]::GetCurrent().Name)`" " + "type=`"$lSeverity`" " + "thread=`"$PID`" " + "file=`"$Source`">"
                }
        
                ## Create script block for writing log entry to the console
                [scriptblock]$WriteLogLineToHost = {
                    Param (
                        [string]$lTextLogLine,
                        [int16]$lSeverity
                    )
                    If ($WriteHost) {
                        #  Only output using color options if running in a host which supports colors.
                        If ($Host.UI.RawUI.ForegroundColor) {
                            Switch ($lSeverity) {
                                3 { Write-Host -Object $lTextLogLine -ForegroundColor 'Red' -BackgroundColor 'Black' }
                                2 { Write-Host -Object $lTextLogLine -ForegroundColor 'Yellow' -BackgroundColor 'Black' }
                                1 { Write-Host -Object $lTextLogLine }
                            }
                        }
                        #  If executing "powershell.exe -File <filename>.ps1 > log.txt", then all the Write-Host calls are converted to Write-Output calls so that they are included in the text log.
                        Else {
                            Write-Output -InputObject $lTextLogLine
                        }
                    }
                }
        
                ## Create script block for writing log entry to the console as verbose or debug message
                [scriptblock]$WriteLogLineToHostAdvanced = {
                    Param (
                        [string]$lTextLogLine
                    )
                    #  Only output using color options if running in a host which supports colors.
                    If ($Host.UI.RawUI.ForegroundColor) {
                        If ($VerboseMessage) {
                            Write-Verbose -Message $lTextLogLine
                        }
                        Else {
                            Write-Debug -Message $lTextLogLine
                        }
                    }
                    #  If executing "powershell.exe -File <filename>.ps1 > log.txt", then all the Write-Host calls are converted to Write-Output calls so that they are included in the text log.
                    Else {
                        Write-Output -InputObject $lTextLogLine
                    }
                }
        
                ## Create script block for event writing log entry
                [scriptblock]$WriteToEventLog = {
                    If ($WriteEvent) {
                        $EventType = Switch ($Severity) {
                            3 { 'Error' }
                            2 { 'Warning' }
                            1 { 'Information' }
                        }
        
                        If ($LogNameNotExists -and (-not $LogSourceNotExists)) {
                            Try {
                                #  Delete event source if the log does not exist
                                $null = [System.Diagnostics.EventLog]::DeleteEventSource($Source)
                                $LogSourceNotExists = $true
                            }
                            Catch {
                                [boolean]$ExitLoggingFunction = $true
                                #  If error deleting event source, write message to console
                                If (-not $ContinueOnError) {
                                    Write-Host -Object "[$LogDate $LogTime] [${CmdletName}] $ScriptSection :: Failed to create the event log source [$Source]. `n$(Resolve-Error)" -ForegroundColor 'Red'
                                }
                            }
                        }
                        If ($LogNameNotExists -or $LogSourceNotExists) {
                            Try {
                                #  Create event log
                                $null = New-EventLog -LogName $LogName -Source $Source -ErrorAction 'Stop'
                            }
                            Catch {
                                [boolean]$ExitLoggingFunction = $true
                                #  If error creating event log, write message to console
                                If (-not $ContinueOnError) {
                                    Write-Host -Object "[$LogDate $LogTime] [${CmdletName}] $ScriptSection :: Failed to create the event log [$LogName`:$Source]. `n$(Resolve-Error)" -ForegroundColor 'Red'
                                }
                            }
                        }
                        Try {
                            #  Write to event log
                            Write-EventLog -LogName $LogName -Source $Source -EventId $EventID -EntryType $EventType -Category '0' -Message $ConsoleLogLine -ErrorAction 'Stop'
                        }
                        Catch {
                            [boolean]$ExitLoggingFunction = $true
                            #  If error creating directory, write message to console
                            If (-not $ContinueOnError) {
                                Write-Host -Object "[$LogDate $LogTime] [${CmdletName}] $ScriptSection :: Failed to write to event log [$LogName`:$Source]. `n$(Resolve-Error)" -ForegroundColor 'Red'
                            }
                        }
                    }
                }
        
                ## Exit function if it is a debug message and logging debug messages is not enabled in the config XML file
                If (($DebugMessage -or $VerboseMessage) -and (-not $LogDebugMessage)) { [boolean]$ExitLoggingFunction = $true; Return }
                ## Exit function if logging to file is disabled and logging to console host is disabled
                If (($DisableLogging) -and (-not $WriteHost)) { [boolean]$ExitLoggingFunction = $true; Return }
                ## Exit Begin block if logging is disabled
                If ($DisableLogging) { Return }
        
                ## Create the directory where the log file will be saved
                If (-not (Test-Path -LiteralPath $LogFileDirectory -PathType 'Container')) {
                    Try {
                        $null = New-Item -Path $LogFileDirectory -Type 'Directory' -Force -ErrorAction 'Stop'
                    }
                    Catch {
                        [boolean]$ExitLoggingFunction = $true
                        #  If error creating directory, write message to console
                        If (-not $ContinueOnError) {
                            Write-Host -Object "[$LogDate $LogTime] [${CmdletName}] $ScriptSection :: Failed to create the log directory [$LogFileDirectory]. `n$(Resolve-Error)" -ForegroundColor 'Red'
                        }
                        Return
                    }
                }
        
                ## Assemble the fully qualified path to the log file
                [string]$LogFilePath = Join-Path -Path $LogFileDirectory -ChildPath $LogFileName
            }
            Process {
        
                ForEach ($Msg in $Message) {
                    ## If the message is not $null or empty, create the log entry for the different logging methods
                    [string]$CMTraceMsg = ''
                    [string]$ConsoleLogLine = ''
                    [string]$LegacyTextLogLine = ''
                    If ($Msg) {
                        #  Create the CMTrace log message
                        If ($ScriptSectionDefined) { [string]$CMTraceMsg = "[$ScriptSection] :: $Msg" }
        
                        #  Create a Console and Legacy "text" log entry
                        [string]$LegacyMsg = "[$LogDate $LogTime]"
                        If ($ScriptSectionDefined) { [string]$LegacyMsg += " [$ScriptSection]" }
                        If ($Source) {
                            [string]$ConsoleLogLine = "$LegacyMsg [$Source] :: $Msg"
                            Switch ($Severity) {
                                3 { [string]$LegacyTextLogLine = "$LegacyMsg [$Source] [Error] :: $Msg" }
                                2 { [string]$LegacyTextLogLine = "$LegacyMsg [$Source] [Warning] :: $Msg" }
                                1 { [string]$LegacyTextLogLine = "$LegacyMsg [$Source] [Info] :: $Msg" }
                            }
                        }
                        Else {
                            [string]$ConsoleLogLine = "$LegacyMsg :: $Msg"
                            Switch ($Severity) {
                                3 { [string]$LegacyTextLogLine = "$LegacyMsg [Error] :: $Msg" }
                                2 { [string]$LegacyTextLogLine = "$LegacyMsg [Warning] :: $Msg" }
                                1 { [string]$LegacyTextLogLine = "$LegacyMsg [Info] :: $Msg" }
                            }
                        }
                    }
        
                    ## Execute script block to write the log entry to the console as verbose or debug message
                    & $WriteLogLineToHostAdvanced -lTextLogLine $ConsoleLogLine -lSeverity $Severity
        
                    ## Exit function if logging is disabled
                    If ($ExitLoggingFunction) { Return }
        
                    ## Execute script block to create the CMTrace.exe compatible log entry
                    [string]$CMTraceLogLine = & $CMTraceLogString -lMessage $CMTraceMsg -lSource $Source -lSeverity $lSeverity
        
                    ## Choose which log type to write to file
                    If ($LogType -ieq 'CMTrace') {
                        [string]$LogLine = $CMTraceLogLine
                    }
                    Else {
                        [string]$LogLine = $LegacyTextLogLine
                    }
        
                    ## Write the log entry to the log file and event log if logging is not currently disabled
                    If (-not $DisableLogging -and $WriteFile) {
                        ## Write to file log
                        Try {
                            $LogLine | Out-File -FilePath $LogFilePath -Append -NoClobber -Force -Encoding 'UTF8' -ErrorAction 'Stop'
                        }
                        Catch {
                            If (-not $ContinueOnError) {
                                Write-Host -Object "[$LogDate $LogTime] [$ScriptSection] [${CmdletName}] :: Failed to write message [$Msg] to the log file [$LogFilePath]. `n$(Resolve-Error)" -ForegroundColor 'Red'
                            }
                        }
                        ## Write to event log
                        Try {
                            & $WriteToEventLog -lMessage $ConsoleLogLine -lName $LogName -lSource $Source -lSeverity $Severity
                        }
                        Catch {
                            If (-not $ContinueOnError) {
                                Write-Host -Object "[$LogDate $LogTime] [$ScriptSection] [${CmdletName}] :: Failed to write message [$Msg] to the log file [$LogFilePath]. `n$(Resolve-Error)" -ForegroundColor 'Red'
                            }
                        }
                    }
        
                    ## Execute script block to write the log entry to the console if $WriteHost is $true and $LogLogDebugMessage is not $true
                    & $WriteLogLineToHost -lTextLogLine $ConsoleLogLine -lSeverity $Severity
                }
            }
            End {
                ## Archive log file if size is greater than $MaxLogFileSizeMB and $MaxLogFileSizeMB > 0
                Try {
                    If ((-not $ExitLoggingFunction) -and (-not $DisableLogging)) {
                        [IO.FileInfo]$LogFile = Get-ChildItem -LiteralPath $LogFilePath -ErrorAction 'Stop'
                        [decimal]$LogFileSizeMB = $LogFile.Length / 1MB
                        If (($LogFileSizeMB -gt $MaxLogFileSizeMB) -and ($MaxLogFileSizeMB -gt 0)) {
                            ## Change the file extension to "lo_"
                            [string]$ArchivedOutLogFile = [IO.Path]::ChangeExtension($LogFilePath, 'lo_')
                            [hashtable]$ArchiveLogParams = @{ ScriptSection = $ScriptSection; Source = ${CmdletName}; Severity = 2; LogFileDirectory = $LogFileDirectory; LogFileName = $LogFileName; LogType = $LogType; MaxLogFileSizeMB = 0; WriteHost = $WriteHost; ContinueOnError = $ContinueOnError; PassThru = $false }
        
                            ## Log message about archiving the log file
                            $ArchiveLogMessage = "Maximum log file size [$MaxLogFileSizeMB MB] reached. Rename log file to [$ArchivedOutLogFile]."
                            Write-Log -Message $ArchiveLogMessage @ArchiveLogParams -ScriptSection ${CmdletName}
        
                            ## Archive existing log file from <filename>.log to <filename>.lo_. Overwrites any existing <filename>.lo_ file. This is the same method SCCM uses for log files.
                            Move-Item -LiteralPath $LogFilePath -Destination $ArchivedOutLogFile -Force -ErrorAction 'Stop'
        
                            ## Start new log file and Log message about archiving the old log file
                            $NewLogMessage = "Previous log file was renamed to [$ArchivedOutLogFile] because maximum log file size of [$MaxLogFileSizeMB MB] was reached."
                            Write-Log -Message $NewLogMessage @ArchiveLogParams -ScriptSection ${CmdletName}
                        }
                    }
                }
                Catch {
                    ## If renaming of file fails, script will continue writing to log file even if size goes over the max file size
                }
                Finally {
                    If ($PassThru) { Write-Output -InputObject $Message }
                }
            }
        }

    function Format-Decimal {
        <#
        .SYNOPSIS
        Formats an integer into a decimal notation eg. KB, MB, GB etc.

        .DESCRIPTION
        This function formats an integer with an deciaml notation with a assigned number of decimal places. 

        .PARAMETER InputSize
        InputSize is the integer to be formatted.

        .PARAMETER DecimalPlaces
        Assignes the number of decimal places in the return string.

        .EXAMPLE
        Format-Decimal -InputSize 1234567890 -DecimalPlaces 2
        Formats the integer 1234567890 with 2 decimal places to '1,15GB'

        .INPUTS
        UInt64, Int (0..3)

        .OUTPUTS
        String
    #>

        [OutputType([string])]
        param
        (
            [Parameter(Mandatory = $true,
                HelpMessage = 'Add help message for user',
                ValueFromPipelineByPropertyName = $true,
                Position = 0)]
            [UInt64]$InputSize,
            [Parameter(ValueFromPipelineByPropertyName = $true,
                Position = 1)]
            [ValidateRange(0, 3)] 
            [Int]$DecimalPlaces = 0
        )
        Begin {
            [string]$s = [string]::Empty
        }
        Process {
            [string]$FormatString = [string]::Format(([cultureinfo]::CurrentCulture = [cultureinfo]::InvariantCulture), 'F{0:D}', $DecimalPlaces)
            If ($InputSize -ge [Math]::Pow(2, 60)) { $s = $($InputSize / [Math]::pow(2, 60)).ToString($FormatString) + 'EB' } 
            ElseIf ($InputSize -ge [Math]::Pow(2, 50)) { $s = $($InputSize / [Math]::pow(2, 50)).ToString($FormatString) + 'PB' } 
            ElseIf ($InputSize -ge [Math]::Pow(2, 40)) { $s = $($InputSize / [Math]::pow(2, 40)).ToString($FormatString) + 'TB' } 
            ElseIf ($InputSize -ge [Math]::Pow(2, 30)) { $s = $($InputSize / [Math]::pow(2, 30)).ToString($FormatString) + 'GB' } 
            ElseIf ($InputSize -ge [Math]::Pow(2, 20)) { $s = $($InputSize / [Math]::pow(2, 20)).ToString($FormatString) + 'MB' } 
            ElseIf ($InputSize -ge [Math]::Pow(2, 10)) { $s = $($InputSize / [Math]::pow(2, 10)).ToString($FormatString) + 'KB' } 
            Else { $s = $($InputSize).ToString($FormatString) + 'Bytes' }
        }
        End {
            return $s
        }
    }

    function Get-FreeDiskSpace {
        [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]
        param (
            [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
            [string[]]
            $Volume = 'C:',
            [switch]
            $force
        )

        process {
            if ($PSCmdlet.ShouldProcess('local machine', $('get the amount of free space on volume {0}' -f $(if ($volume -is [array]) { $volume -join ', ' } Else { $Volume })))) {
                $objs = Get-CimInstance -Namespace 'root\cimv2' -ClassName 'Win32_LogicalDisk' -Filter ("DriveType = 3")
            
                $result = [List[Object]]::New()
            
                foreach ($obj in $objs) {
                    if ($PSBoundParameters["force"] -eq $true) {
                        $result.Add([PSCustomObject]@{
                                DeviceID   = [string]$obj.DeviceID
                                VolumeName = [string]$obj.VolumeName
                                FreeSpace  = $obj.FreeSpace
                                Percentage = $("{0:P}" -f ($obj.FreeSpace/$Obj.Size))
                            })
                    }
                    else {
                        if ($obj.DeviceID -in $Volume) {
                            $result.Add([PSCustomObject]@{
                                    DeviceID   = [string]$obj.DeviceID
                                    VolumeName = [string]$obj.VolumeName
                                    FreeSpace  = $obj.FreeSpace
                                    Percentage = $("{0:P}" -f ($obj.FreeSpace/$Obj.Size))
                                })
                        } 
                    }
                }

                return $result

            }
        }
    }

    function Invoke-CleanMgr {
        #Requires -RunAsAdministrator
        [cmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
        [OutputType([Int32])]
        param (
            # Enter and integer from 1 to 9999
            [Parameter(ValueFromPipeline)]
            [ValidateRange(1, 9999)]
            [Int]$Index = 5432
        )

        process {
            if (-not ([WindowsPrincipal][WindowsIdentity]::GetCurrent()).IsInRole([WindowsBuiltInRole]::Administrator)) {
                throw "Function must be started with local administrator rigths."
            }

            [string]$StateFlags = "StateFlags" + $Index.ToString().PadLeft(4, '0')
            [object[]]$Items = Get-ChildItem -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches' -Recurse -Depth 0 -Exclude 'DownloadsFolder'

            if ($PSCmdlet.ShouldProcess("local machine", $('Cleanmgr.exe /SAGERUN:{0}' -f $Index))) {
                foreach ($item in $Items) {
                    $value = Get-ItemProperty -LiteralPath $item.PSPath -Name $StateFlags -ErrorAction SilentlyContinue
                    if ($value -ne '2') {
                        Set-ItemProperty -LiteralPath $Item.PSPath -Name $StateFlags -Value 2 -Force
                    }
                }

                try {
                    $Arguments = @{
                        FilePath     = $(Join-Path -Path "$env:SystemRoot" -ChildPath 'System32\cleanmgr.exe')
                        ArgumentList = @("/SAGERUN:$index")
                        NoNewWindow  = $true
                        PassThru     = $true
                        Wait         = $true
                        ErrorAction  = 'Stop'
                    }
                    $process = Start-Process @Arguments
                }
                catch {
                    Write-Error -Exception $_.Exception.Message
                }

                foreach ($item in $Items) {
                    if ($null -ne (Get-Item -LiteralPath $item.PSPath).GetValue($StateFlags, $null)) {
                        Remove-ItemProperty -Path $Item.PSPath -Name $StateFlags -Force
                    }
                }
                return $process.ExitCode
            }
        }
    }

    function Get-BCStatusEx {
        return (Get-BCStatus).BranchCacheIsEnabled
    }

    function Clear-BCCacheEx {
        [CmdletBinding()]
        param (
            [Parameter()]
            [switch]
            $force
        )

        if(Get-BCStatusEx){
            if($PSBoundParameters["force"] -eq $true){
                Clear-BCCache -force
            } else {
                Clear-BCCache
            } 
        }
    }

    function Clear-ConfigMgrCache {
        ## Initialize the CCM resource manager com object
        [__comobject]$CCMComObject = New-Object -ComObject 'UIResource.UIResourceMgr'
        ## Get the CacheElementIDs to delete
        $CacheInfo = $CCMComObject.GetCacheInfo().GetCacheElements()
        ## Remove cache items
        ForEach ($CacheItem in $CacheInfo) {
            try {
                $null = $CCMComObject.GetCacheInfo().DeleteCacheElement([string]$($CacheItem.CacheElementID))
            }
            catch {
                Write-Error -Exception $_.Exception                
            }
        }
    }

    function Clear-OldUserProfiles {
        [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
        param (
            [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
            [Int]
            $Months = 3
        )

        $objUserProfiles = Get-CimInstance -Namespace 'root\cimv2' -ClassName 'Win32_UserProfile' -Filter ("Special != 'true' and Loaded != 'True'")

        if ($PSCmdlet.ShouldProcess('Local Machine', $('Remove old user profiles older that {0} months' -f $Months))) {
            foreach ($userProfile in $objUserProfiles) {
                if($UserProfile.LastUseTime -and $UserProfile.LastUseTime -le (Get-Date).AddMonths(-$Months)){
                    try {
                        Remove-CimInstance -InputObject $userProfile
                    }
                    catch {
                        Write-Error -Exception $_.Exception
                    }
                }
            }
        }
    }

    Function Resolve-Error {
        <#
        .SYNOPSIS
            Enumerate error record details.
        .DESCRIPTION
            Enumerate an error record, or a collection of error record, properties. By default, the details for the last error will be enumerated.
        .PARAMETER ErrorRecord
            The error record to resolve. The default error record is the latest one: $global:Error[0]. This parameter will also accept an array of error records.
        .PARAMETER Property
            The list of properties to display from the error record. Use "*" to display all properties.
            Default list of error properties is: Message, FullyQualifiedErrorId, ScriptStackTrace, PositionMessage, InnerException
        .PARAMETER GetErrorRecord
            Get error record details as represented by $_.
        .PARAMETER GetErrorInvocation
            Get error record invocation information as represented by $_.InvocationInfo.
        .PARAMETER GetErrorException
            Get error record exception details as represented by $_.Exception.
        .PARAMETER GetErrorInnerException
            Get error record inner exception details as represented by $_.Exception.InnerException. Will retrieve all inner exceptions if there is more than one.
        .EXAMPLE
            Resolve-Error
        .EXAMPLE
            Resolve-Error -Property *
        .EXAMPLE
            Resolve-Error -Property InnerException
        .EXAMPLE
            Resolve-Error -GetErrorInvocation:$false
        .NOTES
            Unmodified version of the PADT error resolving cmdlet. I did not write the original cmdlet, please do not credit me for it!
        .LINK
            https://psappdeploytoolkit.com
        #>
            [CmdletBinding()]
            Param (
                [Parameter(Mandatory = $false, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
                [AllowEmptyCollection()]
                [array]$ErrorRecord,
                [Parameter(Mandatory = $false, Position = 1)]
                [ValidateNotNullorEmpty()]
                [string[]]$Property = ('Message', 'InnerException', 'FullyQualifiedErrorId', 'ScriptStackTrace', 'PositionMessage'),
                [Parameter(Mandatory = $false, Position = 2)]
                [switch]$GetErrorRecord,
                [Parameter(Mandatory = $false, Position = 3)]
                [switch]$GetErrorInvocation,
                [Parameter(Mandatory = $false, Position = 4)]
                [switch]$GetErrorException,
                [Parameter(Mandatory = $false, Position = 5)]
                [switch]$GetErrorInnerException
            )
        
            Begin {
                ## If function was called without specifying an error record, then choose the latest error that occurred
                If (-not $ErrorRecord) {
                    If ($global:Error.Count -eq 0) {
                        #Write-Warning -Message "The `$Error collection is empty"
                        Return
                    }
                    Else {
                        [array]$ErrorRecord = $global:Error[0]
                    }
                }
        
                ## Allows selecting and filtering the properties on the error object if they exist
                [scriptblock]$SelectProperty = {
                    Param (
                        [Parameter(Mandatory = $true)]
                        [ValidateNotNullorEmpty()]
                        $InputObject,
                        [Parameter(Mandatory = $true)]
                        [ValidateNotNullorEmpty()]
                        [string[]]$Property
                    )
        
                    [string[]]$ObjectProperty = $InputObject | Get-Member -MemberType '*Property' | Select-Object -ExpandProperty 'Name'
                    ForEach ($Prop in $Property) {
                        If ($Prop -eq '*') {
                            [string[]]$PropertySelection = $ObjectProperty
                            Break
                        }
                        ElseIf ($ObjectProperty -contains $Prop) {
                            [string[]]$PropertySelection += $Prop
                        }
                    }
                    Write-Output -InputObject $PropertySelection
                }
        
                #  Initialize variables to avoid error if 'Set-StrictMode' is set
                $LogErrorRecordMsg = $null
                $LogErrorInvocationMsg = $null
                $LogErrorExceptionMsg = $null
                $LogErrorMessageTmp = $null
                $LogInnerMessage = $null
            }
            Process {
                If (-not $ErrorRecord) { Return }
                ForEach ($ErrRecord in $ErrorRecord) {
                    ## Capture Error Record
                    If ($GetErrorRecord) {
                        [string[]]$SelectedProperties = & $SelectProperty -InputObject $ErrRecord -Property $Property
                        $LogErrorRecordMsg = $ErrRecord | Select-Object -Property $SelectedProperties
                    }
        
                    ## Error Invocation Information
                    If ($GetErrorInvocation) {
                        If ($ErrRecord.InvocationInfo) {
                            [string[]]$SelectedProperties = & $SelectProperty -InputObject $ErrRecord.InvocationInfo -Property $Property
                            $LogErrorInvocationMsg = $ErrRecord.InvocationInfo | Select-Object -Property $SelectedProperties
                        }
                    }
        
                    ## Capture Error Exception
                    If ($GetErrorException) {
                        If ($ErrRecord.Exception) {
                            [string[]]$SelectedProperties = & $SelectProperty -InputObject $ErrRecord.Exception -Property $Property
                            $LogErrorExceptionMsg = $ErrRecord.Exception | Select-Object -Property $SelectedProperties
                        }
                    }
        
                    ## Display properties in the correct order
                    If ($Property -eq '*') {
                        #  If all properties were chosen for display, then arrange them in the order the error object displays them by default.
                        If ($LogErrorRecordMsg) { [array]$LogErrorMessageTmp += $LogErrorRecordMsg }
                        If ($LogErrorInvocationMsg) { [array]$LogErrorMessageTmp += $LogErrorInvocationMsg }
                        If ($LogErrorExceptionMsg) { [array]$LogErrorMessageTmp += $LogErrorExceptionMsg }
                    }
                    Else {
                        #  Display selected properties in our custom order
                        If ($LogErrorExceptionMsg) { [array]$LogErrorMessageTmp += $LogErrorExceptionMsg }
                        If ($LogErrorRecordMsg) { [array]$LogErrorMessageTmp += $LogErrorRecordMsg }
                        If ($LogErrorInvocationMsg) { [array]$LogErrorMessageTmp += $LogErrorInvocationMsg }
                    }
        
                    If ($LogErrorMessageTmp) {
                        $LogErrorMessage = 'Error Record:'
                        $LogErrorMessage += "`n-------------"
                        $LogErrorMsg = $LogErrorMessageTmp | Format-List | Out-String
                        $LogErrorMessage += $LogErrorMsg
                    }
        
                    ## Capture Error Inner Exception(s)
                    If ($GetErrorInnerException) {
                        If ($ErrRecord.Exception -and $ErrRecord.Exception.InnerException) {
                            $LogInnerMessage = 'Error Inner Exception(s):'
                            $LogInnerMessage += "`n-------------------------"
        
                            $ErrorInnerException = $ErrRecord.Exception.InnerException
                            $Count = 0
        
                            While ($ErrorInnerException) {
                                [string]$InnerExceptionSeperator = '~' * 40
        
                                [string[]]$SelectedProperties = & $SelectProperty -InputObject $ErrorInnerException -Property $Property
                                $LogErrorInnerExceptionMsg = $ErrorInnerException | Select-Object -Property $SelectedProperties | Format-List | Out-String
        
                                If ($Count -gt 0) { $LogInnerMessage += $InnerExceptionSeperator }
                                $LogInnerMessage += $LogErrorInnerExceptionMsg
        
                                $Count++
                                $ErrorInnerException = $ErrorInnerException.InnerException
                            }
                        }
                    }
        
                    If ($LogErrorMessage) { $Output = $LogErrorMessage }
                    If ($LogInnerMessage) { $Output += $LogInnerMessage }
        
                    Write-Output -InputObject $Output
        
                    If (Test-Path -LiteralPath 'variable:Output') { Clear-Variable -Name 'Output' }
                    If (Test-Path -LiteralPath 'variable:LogErrorMessage') { Clear-Variable -Name 'LogErrorMessage' }
                    If (Test-Path -LiteralPath 'variable:LogInnerMessage') { Clear-Variable -Name 'LogInnerMessage' }
                    If (Test-Path -LiteralPath 'variable:LogErrorMessageTmp') { Clear-Variable -Name 'LogErrorMessageTmp' }
                }
            }
            End {
            }
        }
        
    Function Remove-CCMOrphanedCache {
        <#
        .SYNOPSIS
            Removes all orphaned ccm cache items.
        .DESCRIPTION
            Removes all ccm cache items not present it wmi.
        .EXAMPLE
            Remove-CCMOrphanedCache
        .INPUTS
            None.
        .OUTPUTS
            System.Object.
        .NOTES
            This is an internal script function and should typically not be called directly.
        .LINK
            https://SCCM.Zone
        .LINK
            https://SCCM.Zone/Git
        .COMPONENT
            CM Client Cache
        .FUNCTIONALITY
            Remove orphaned cached items
        #>
        
            [CmdletBinding()]
            Param ()
            Begin {
                Try {
        
                    ## Get the name of this function and write verbose header
                    [string]${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name
        
                    #  Write verbose header
                    Write-Log -Message 'Start' -VerboseMessage -ScriptSection ${CmdletName}
        
                    ## Initialize the CCM resource manager com object
                    [__comobject]$CCMComObject = New-Object -ComObject 'UIResource.UIResourceMgr'
        
                    ## Get ccm disk cache info
                        [string]$DiskCachePath = $($CCMComObject.GetCacheInfo()).Location
                        $DiskCacheInfo = Get-ChildItem -LiteralPath $DiskCachePath | Select-Object -Property 'FullName', 'Name'
        
                    ## Get ccm wmi cache info
                    $WmiCacheInfo = $($CCMComObject.GetCacheInfo().GetCacheElements())
        
                    ## Get ccm wmi cache paths
                    $WmiCachePaths = $WmiCacheInfo | Select-Object -ExpandProperty 'Location'
        
                    ## Initialize result object
                    [psobject]$RemoveOrphaned = @()
                }
                Catch {
                    Write-Log -Message "Initialization failed. `n$(Resolve-Error)" -Severity '3' -ScriptSection ${CmdletName}
                    Throw "Initialization failed. `n$($_.Exception.Message)"
                }
            }
            Process {
                Try {
        
                    ## Process disk cache items
                    ForEach ($CacheElement in $DiskCacheInfo) {
                        ## Set variables
                        #  Set cache Path
                        $CacheElementPath = $($CacheElement.FullName)
                        #  Set cache Size
                        $CacheElementSize = $(Get-ChildItem -LiteralPath $CacheElementPath -Recurse | Measure-Object -Property 'Length' -Sum).Sum
        
                        ## If disk cache path is not present in wmi, delete it
                        If ($CacheElementPath -notin $WmiCachePaths) {
                            #  Remove cache item
                            $RemoveCacheElement = Remove-Item -LiteralPath $CacheElementPath -Recurse -Force
        
                            #  Assemble result object props
                            $RemoveOrphanedProps = [ordered]@{
                                FullName   = 'Orphaned Disk Cache'
                                Location   = $CacheElementPath
                                'Size(MB)' = '{0:N2}' -f $($CacheElementSize / 1MB)
                                Status     = 'Removed'
                            }
                            #  Add items to result object
                            $RemoveOrphaned += New-Object 'PSObject' -Property $RemoveOrphanedProps
                        }
                    }
        
                    ## Process wmi cache items
                    ForEach ($CacheElement in $WmiCacheInfo) {
                        #  If disk cache path is not present in wmi, delete it
                        If ($($CacheElement.Location) -notin $($DiskCacheInfo.FullName)) {
                            #  Remove cache item
                            $RemoveCacheElement = Remove-CCMCacheElement -CacheElementID ($CacheElement.CacheElementID) -RemovePersisted $RemovePersisted
                            #  Assemble result object props
                            $RemoveOrphanedProps = [ordered]@{
                                FullName   = 'Orphaned WMI Cache'
                                ContentID  = $($CacheElement.ContentID)
                                'Size(MB)' = '0'
                                Status     = $($RemoveCacheElement.RemovalStatus)
                            }
                            #  Add items to result object
                            $RemoveOrphaned += New-Object 'PSObject' -Property $RemoveOrphanedProps
                        }
                    }
                }
                Catch {
                    Write-Log -Message "Could not remove cached item [$($CacheElementPath)]. `n$(Resolve-Error)" -Severity '3' -ScriptSection ${CmdletName}
                    Throw "Could not remove cached item [$($CacheElementPath)]. `n$($_.Exception.Message)"
                }
                Finally {
                    Write-Output -InputObject $RemoveOrphaned
                }
            }
            End {
        
                ## Write verbose footer
                Write-Log -Message 'Stop' -VerboseMessage -ScriptSection ${CmdletName}
            }
        }
}
