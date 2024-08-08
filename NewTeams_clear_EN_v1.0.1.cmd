rem Rust@m 08.08.2024
@echo off
setlocal

rem Check if the Microsoft Teams application is installed
rem	if not exist "C:\Program Files (x86)\Teams Installer\Teams.exe" (
rem     echo Microsoft Teams is not installed in this user context.
rem 	pause
rem exit /b 1
rem )

REM Terminate Teams processes (optional, but recommended to avoid issues)
taskkill /f /im Teams.exe > nul 2>&1
taskkill /f /im ms-teams.exe > nul 2>&1

timeout 5 > NUL

rem powershell -command "Get-ItemProperty -Path "C:\Users\*\AppData\Local\Packages" | ForEach-Object {Remove-Item -Path "$_\Microsoft.AAD.BrokerPlugin*" -Recurse -Force | Out-Null}"
REM Delete local and roaming app data for Microsoft Teams
rem echo Deleting Microsoft Teams app data...
REM calssic teams
rd /s /q "%APPDATA%\Microsoft\Teams"
rd /s /q "%LOCALAPPDATA%\Microsoft\Teams"
REM new teams
rd /s /q "%LOCALAPPDATA%\Packages\MSTeams_8wekyb3d8bbwe"

echo Microsoft Teams app cache data has been successfully deleted from this user context.
rem powershell -command "Start-Process -FilePath 'C:\Program Files (x86)\Teams Installer\Teams.exe' -ArgumentList '-checkInstall', '-source=default'"
EXPLORER.EXE shell:AppsFolder\MSTeams_8wekyb3d8bbwe!MSTeams
endlocal
