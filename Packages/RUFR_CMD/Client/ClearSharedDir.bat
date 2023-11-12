@ECHO ON 
@ECHO This script wil empty the content of a folder C:\test.
Pause
set folder="C:\test"
cd /d %folder%
for /F "delims=" %%i in ('dir /b') do (rmdir "%%i" /s/q || del "%%i" /s/q)