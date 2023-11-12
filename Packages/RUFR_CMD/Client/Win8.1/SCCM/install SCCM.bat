:Reinstallation af SCCM klient SST Win8.1
:rufr 31-07-2014

REM Installer SCCM Klient
pushd \\srv-inf-sccm.ssi.ad\source$\Software\SCCM 2012 Client\

rem execution:
ccmsetup.exe

::remove the temporary drive letter and return to your original location