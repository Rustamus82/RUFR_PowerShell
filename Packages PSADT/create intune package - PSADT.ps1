#PSVersion 5 Script made/assembled by Rust@m 28-11-2024
<##Creat intune files from PSADT source. tool can be found here: https://github.com/Microsoft/Microsoft-Win32-Content-Prep-Tool
cls
#>


# Specify the path to the folder and the executable
$folderPath = Get-ChildItem -Path "C:\Intune\Input"
$exePath = "C:\Intune\Microsoft-Win32-Content-Prep-Tool-1.8.6\IntuneWinAppUtil.exe"
$desiredWorkingDirectory = "C:\Intune\Microsoft-Win32-Content-Prep-Tool-1.8.6\"  # Working directory for cmd.exe


<# Validate paths
if (-Not (Test-Path $exePath)) {
    Write-Error "Executable not found at: $exePath"
    return
}

if (-Not (Test-Path $folderPath)) {
    Write-Error "Input folder not found: $folderPath"
    return
}
#>

# Change to the directory containing the .exe
#Set-Location -Path "C:\Intune\Microsoft-Win32-Content-Prep-Tool-1.8.6"

foreach ($filePath in $folderPath)
{
    # Extract the full path of the file
    $PSADT = $filePath.FullName; $PSADT
    $Name = $filePath.name  
    # Build the command
    $Output = "C:\Intune\Output\$Name"
    $command = "$exePath -c `"$PSADT`" -s `"$PSADT\Deploy-Application.exe`" -o `"$Output`" -a `"$PSADT`" -q"
    
    # Debugging: Show the constructed command
    Write-Output "Executing: $command"
    
    # Start the process using cmd.exe with the specified working directory
    Start-Process -FilePath "cmd.exe" -ArgumentList "/k", $command -Wait -WorkingDirectory $desiredWorkingDirectory
    Get-ChildItem -Path "$Output" -Filter "*.intunewin" -Recurse |Rename-Item -NewName "$Name.intunewin"
}


#Get-ChildItem -Path "C:\Intune" -Filter "*.intunewin" -Recurse


