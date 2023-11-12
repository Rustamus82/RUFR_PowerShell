:Reinstallation af SCCM klient SST Win8.1
:rufr 31-07-2014


REM Afinstaller SCCM klient
C:\Windows\ccmsetup\ccmsetup.exe /uninstall 
TASKKILL /F /IM ccmsetup.exe
REM Stopper Windows Management Instrumentation service
net stop winmgmt /y

REM Sletter mapperne 
rd /s/q "C:\Windows\SysWOW64\wbem\Repository"
rd /s/q "C:\Windows\SysWOW64\CCM"
rd /s/q "C:\WINDOWS\ccmsetup"

REM Starter Windows Management Instrumentation service
net start winmgmt /y

REM Installer SCCM Klient
pushd \\srv-inf-sccm.ssi.ad\source$\Software\SCCM 2012 Client\

rem execution:
ccmsetup.exe

::remove the temporary drive letter and return to your original location
popd


REM DU SKAL NU GENSTARTE PCen

shutdown -r -f -t 120 -C "Din PC bliver genstartet om 2 min. Vigtigt: Venligst luk alle prorgammer, ikke gemte data bliver tabt! Mvh. Drift og Support"