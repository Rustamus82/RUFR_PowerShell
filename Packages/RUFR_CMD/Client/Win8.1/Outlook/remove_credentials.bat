::Script kompileret af RUFR@ssi.dk

@ECHO off
TITLE Sletter gemte Outlook/Lync legtimationer...
@ECHO TITLE Sletter gemte Outlook/Lync legtimationer...
@ECHO off

::ryd legitimationer for windows, outlook og Lync
TASKKILL /F /IM outlook.exe
start lync.exe
timeout /t 5 /nobreak
TASKKILL /F /IM lync.exe
C:
CD C:\Users\%username%\AppData\Local\Microsoft\Office\15.0\Lync\
timeout /t 10 /nobreak
RD sip_%username%@ssi.dk /S /Q

cmdkey.exe /list > "%TEMP%\cmdkeyList.txt"

findstr.exe Target "%TEMP%\cmdkeyList.txt" > "%TEMP%\tokensonly.txt"

FOR /F "tokens=1,2 delims= " %%G IN (%TEMP%\tokensonly.txt) DO cmdkey.exe /delete:%%H
del "%TEMP%\*.*" /s /f /q
cmdkey.exe /list > "%TEMP%\cmdkeyList2.txt"

::Importerer Concierge indstilinger reg.
reg import "\\srv-exc-con01\ConcicergeShare\Software\Concierge_Office365_registry.reg"

gpupdate /force
shutdown -r -f -t 10 /c "Din PC vil bliver genstartet, Husk at gemme din Data og lukke andre programmer, ikke gemte data bliver tabt! Mvh. IOS Drift og Support"!"