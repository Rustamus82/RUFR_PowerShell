"C:\SCCM_Client_Install\ccmsetup.exe" /uninstall

copy "C:\SCCM_Client_Install\cmtrace.exe" "%windir%\System32\cmtrace.exe" /y
timeout /t 180 /nobreak
echo Se om det blev afinstalleret succesfuldt: "C:\Windows\System32\cmtrace.exe" c:\Windows\ccmsetup\logs\ccmsetup.log

RD /S /Q c:\Windows\CCM
RD /S /Q c:\Windows\ccmsetup
RD /S /Q c:\Windows\ccmcache

DEL /F c:\Windows\SMSAdvancedClient.*.mif
DEL /F c:\Windows\SMSCFG.INI

REG DELETE HKLM\Software\Microsoft\CCM /f
REG DELETE HKLM\Software\Microsoft\ccmsetup /f
REG DELETE HKLM\Software\Microsoft\SMS /f
REG DELETE HKLM\SOFTWARE\Microsoft\SystemCertificates\SMS /f

NET STOP Winmgmt /y
NET START Winmgmt
%windir%\System32\WBEM\winmgmt.exe /resetrepository

NET START iphlpsvc
NET START wscsvc

echo Venter på at WMI Repository er blevet gendannet. Det kan tage et par minutter:  C:\Windows\System32\WBEM\Repository>CON
echo Se installation process: cmtrace.exe c:\Windows\ccmsetup\logs\ccmsetup.log>CON
timeout /t 180 /nobreak

cd "C:\SCCM_Client_Install\"
_RunMe.cmd
pause
