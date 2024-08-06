TITLE rydde op 
@ECHO Rydde op...
@ECHO OFF
set folder="%temp%"
cd /d %folder%
for /F "delims=" %%i in ('dir /b') do (rmdir "%%i" /s/q || del "%%i" /s/q)
cls

TASKKILL /F /IM RunDll32.exe

::To Delete ALL in INternet explorer bowser history
RunDll32.exe InetCpl.cpl,ClearMyTracksByProcess 255
