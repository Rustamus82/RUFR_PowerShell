@ECHO OFF
SETLOCAL
SET CURDIR=%~dp0
SET CURDIR=%CURDIR:~0,-1%
FOR /F "delims=\" %%G IN ('dir /b %CURDIR%\root\*.cer') DO START "" /WAIT /B %SYSTEMROOT%\System32\certutil.exe -f -enterprise -addstore ROOT "%CURDIR%\Root\%%G"
FOR /F "delims=\" %%G IN ('dir /b %CURDIR%\CA\*.cer') DO START "" /WAIT /B %SYSTEMROOT%\System32\certutil.exe -f -enterprise -addstore CA "%CURDIR%\CA\%%G"
FOR /F "delims=\" %%G IN ('dir /b %CURDIR%\TrustedPublisher\*.cer') DO START "" /WAIT /B %SYSTEMROOT%\System32\certutil.exe -f -enterprise -addstore TrustedPublisher "%CURDIR%\TrustedPublisher\%%G"
ENDLOCAL