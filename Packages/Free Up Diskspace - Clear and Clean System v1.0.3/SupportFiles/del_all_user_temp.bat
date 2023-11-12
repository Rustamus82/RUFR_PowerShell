@echo off
cd /D "%SystemDrive%\Users"
REM ?-Clean Temp Folder?
for /D %%a in (*.*) do DEL /F /S /Q "%%a\AppData\Local\Temp\*.*"
