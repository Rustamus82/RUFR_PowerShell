@ECHO OFF
SET _CURDIR=%~dp0
SET _CURDIR=%_CURDIR:~0,-1%
SET _CCMSETUP=%SYSTEMROOT%\ccmsetup
SET _BITNESS=64
SET _MP=srv-inf-dp01.ssi.ad
SET _FSP=%_MP%
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

