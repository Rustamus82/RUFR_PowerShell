::Script kompileret af RUFR@ssi.dk

@ECHO off
TITLE Sletter gemte Outlook/Lync legtimationer...
@ECHO TITLE Sletter gemte Outlook/Lync legtimationer...

cmdkey.exe /list > "%TEMP%\cmdkeyList.txt"

findstr.exe Target "%TEMP%\cmdkeyList.txt" > "%TEMP%\tokensonly.txt"

FOR /F "tokens=1,2 delims= " %%G IN (%TEMP%\tokensonly.txt) DO cmdkey.exe /delete:%%H
del "%TEMP%\*.*" /s /f /q
cmdkey.exe /list > "%TEMP%\cmdkeyList2.txt"

::Importerer Concierge indstilinger reg.
rem reg import "\\srv-exc-con01\ConcicergeShare\Software\Concierge_Office365_registry.reg"

gpupdate /force /boot
logoff