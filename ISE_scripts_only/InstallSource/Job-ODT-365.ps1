
<#PSVersion 5 Script made/assembled by Rust@m 10-06-2024

# ODT Download  job run
#set location to where ODT exe file and config are:
#Set-Location "D:\Office365-SemiAnnual-Deploy_v3"
# need to run in elevated mode #cmd: 
#& setup.exe /download "Configuration_CompanyName_O365_v1.1.0.xml"

#>

#************************ Office and project ******************
# Set variables and paths
$downloadDestination = "D:\WsusContent\UpdateServicesPackages\O365_SemiAnnual_Updates\Office"
$archiveFolder = "D:\WsusContent\UpdateServicesPackages\O365_SemiAnnual_Updates\ODT-Download-Archive"
$Ver= Get-ChildItem -Path "\\SERVER\d$\WsusContent\UpdateServicesPackages\O365_SemiAnnual_Updates\Office\Data\*" -Directory | Select-Object name


# Check if the download was successful
if (Test-Path $downloadDestination) {
    # Move the downloaded file to the archive folder
    $timestamp = Get-Date -Format "yyyyMMdd"
    $archiveFolderName = "Office_$Ver_$timestamp"
    $archiveFolderPath = Join-Path -Path $archiveFolder -ChildPath $archiveFolderName
    
    Move-Item -Path $downloadDestination -Destination $archiveFolderPath -Force
    
    "ODT-job SourceFolder moved to archive folder: $archiveFolderPath" | Out-File -FilePath "D:\WsusContent\UpdateServicesPackages\O365_SemiAnnual_Updates\ODT-download-job.log"
    
} else {
    $timestamp = Get-Date -Format "yyyyMMdd"
    "Could not move folder. Files not found. $timestamp" | Out-File -FilePath "D:\WsusContent\UpdateServicesPackages\O365_SemiAnnual_Updates\ODT-download-job.log"
}



# Define paths
$ODTPath = "D:\Office365-SemiAnnual-Deploy_v3\setup.exe"
#$ConfigFilePath = "D:\Office365-SemiAnnual-Deploy_v3\Configuration_CompanyName_O365_v1.0.8.xml"
$ConfigFilePath = "D:\Office365-SemiAnnual-Deploy_v3\Configuration_CompanyName_O365_v1.1.0.xml"

# Check if ODT executable and config file exist
if (!(Test-Path $ODTPath) -or !(Test-Path $ConfigFilePath)) {
    Write-Host "ODT executable or configuration file not found."
    return
}

# Run the download command
Start-Process -FilePath $ODTPath -ArgumentList "/download", $ConfigFilePath -Wait


#*********  VISIO *****************
# Set variables and paths
$downloadDestination = "D:\WsusContent\UpdateServicesPackages\Visio_2019_Std\Office"
$archiveFolder = "D:\WsusContent\UpdateServicesPackages\Visio_2019_Std\ODT-Download-Archive"
$Ver= Get-ChildItem -Path "\\SERVER\d$\WsusContent\UpdateServicesPackages\Visio_2019_Std\Office\Data\*" -Directory | Select-Object name


# Check if the download was successful
if (Test-Path $downloadDestination) {
    # Move the downloaded file to the archive folder
    $timestamp = Get-Date -Format "yyyyMMdd"
    $archiveFolderName = "Office_$Ver_$timestamp"
    $archiveFolderPath = Join-Path -Path $archiveFolder -ChildPath $archiveFolderName
    
    Move-Item -Path $downloadDestination -Destination $archiveFolderPath -Force
    
    "ODT-job SourceFolder moved to archive folder: $archiveFolderPath" | Out-File -FilePath "D:\WsusContent\UpdateServicesPackages\Visio_2019_Std\ODT-download-job.log"
    
} else {
    $timestamp = Get-Date -Format "yyyyMMdd"
    "Could not move folder. Files not found. $timestamp" | Out-File -FilePath "D:\WsusContent\UpdateServicesPackages\Visio_2019_Std\ODT-download-job.log"
}



# Define paths
$ODTPath = "D:\Office365-SemiAnnual-Deploy_v3\setup.exe"
$ConfigFilePathVisio = "D:\Office365-SemiAnnual-Deploy_v3\Configuration_CompanyName_Visio_2019std_v1.0.1.xml"

# Check if ODT executable and config file exist
if (!(Test-Path $ODTPath) -or !(Test-Path $ConfigFilePathVisio)) {
    Write-Host "ODT executable or configuration file not found."
    return
}

# Run the download command
Start-Process -FilePath $ODTPath -ArgumentList "/download", $ConfigFilePathVisio -Wait

<## Create schedule task and then adjust when you need to run it and with what account
## need to be run once for creation of the task.
$action = New-ScheduledTaskAction -Execute 'PowerShell.exe' -Argument '-NoProfile -ExecutionPolicy Bypass -File "D:\Office365-SemiAnnual-Deploy_v3\Job-ODT-365.ps1"'
$trigger = New-ScheduledTaskTrigger -Weekly -At "12:00" -DaysOfWeek Tuesday 
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -RunOnlyIfNetworkAvailable -Priority 5
Register-ScheduledTask -TaskName "Office365DownloadTask" -Action $action -Trigger $trigger -Description "Task to download Office 365 using ODT" -RunLevel Highest
#>
