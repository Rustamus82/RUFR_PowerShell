:Reinstallation af SCCM klient SST Win8.1
:rufr 31-07-2014

pushd \\msfc-uivs\uvl\IT\Solution\Client\Win8.1\SCCM

xcopy "*.*" "C:\Users\%username%\AppData\Local\Temp\" /Y /F
popd

cd C:\Windows\System32
rem RunOnce planlæg installation til næste windows startup.
REG IMPORT C:\Users\%username%\AppData\Local\Temp\SCCM_runonce.reg /reg:64

cd %temp%
rem Afinstallation af SCCM og genstart
"execution_Win8.1_SSI SCCM_klient.bat"

