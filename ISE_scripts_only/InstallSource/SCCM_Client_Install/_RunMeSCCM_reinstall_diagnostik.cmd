@ECHO OFF
SET _CURDIR=%~dp0
SET _CURDIR=%_CURDIR:~0,-1%
SET _CCMSETUP=%SYSTEMROOT%\ccmsetup
SET _BITNESS=64
SET _MP=srv-inf-dp01.ssi.ad
SET _FSP=%_MP%
@ECHO ON

"%~dp0%~1\ccmsetup.exe" /uninstall

copy "%~dp0%~1\cmtrace.exe" "%windir%\System32\cmtrace.exe" /y
timeout /t 3 /nobreak
rem "%windir%\System32\cmtrace.exe" c:\Windows\ccmsetup\logs\ccmsetup.log

RD /S /Q %windir%\CCM
RD /S /Q %windir%\ccmsetup
RD /S /Q %windir%\ccmcache

DEL /F %windir%\SMSAdvancedClient.*.mif
DEL /F %windir%\SMSCFG.INI

REG DELETE HKLM\Software\Microsoft\CCM /f
REG DELETE HKLM\Software\Microsoft\ccmsetup /f
REG DELETE HKLM\Software\Microsoft\SMS /f
REG DELETE HKLM\SOFTWARE\Microsoft\SystemCertificates\SMS /f

NET STOP Winmgmt /y
NET START Winmgmt
%windir%\System32\WBEM\winmgmt.exe /resetrepository

NET START iphlpsvc
NET START wscsvc

echo Venter på at WMI Repository er blevet gendannet. Det kan tage et par minutter:  C:\Windows\System32\WBEM\Repository
start explorer "%windir%\System32\WBEM\Repository"

timeout /t 180 /nobreak

rem install af SCCM
IF %PROCESSOR_ARCHITECTURE% == x86 (
  IF NOT DEFINED PROCESSOR_ARCHITEW6432 SET _BITNESS=32
)

IF EXIST %_CCMSETUP%\ccmsetup.exe (
  ECHO Please uninstal the old client before proceeding.
  GOTO:eof
) 

RD /S /Q %_CCMSETUP% 2>nul 

ECHO Installing ConfigMgr2012 Client...
ECHO Check status of the installation in the logfile "%_CCMSETUP%\Logs\ccmsetup.log".
START "" /WAIT "%_CURDIR%\ccmsetup.exe" /forceinstall /MP:%_MP% SMSSITECODE=PS1 SMSCACHESIZE=20480 SMSMP=%_MP% FSP=%_FSP% DNSSUFFIX=SSI.AD

timeout /t 5 /nobreak
"%windir%\System32\cmtrace.exe" c:\Windows\ccmsetup\logs\ccmsetup.log
pause
