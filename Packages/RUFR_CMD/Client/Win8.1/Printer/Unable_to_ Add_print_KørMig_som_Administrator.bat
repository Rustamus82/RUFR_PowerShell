REM Script kompileret af RUFR@ssi.dk

pushd \\msfc-uivs\uvl\IT\Solution\Client\Win8.1\Printer
xcopy "*.*" "C:\Users\%username%\AppData\Local\Temp\" /Y /F
popd

REG IMPORT C:\Users\%username%\AppData\Local\Temp\Fix_for_Unable_to_add_printer.reg /reg:64

net stop spooler
net start spooler
Pause