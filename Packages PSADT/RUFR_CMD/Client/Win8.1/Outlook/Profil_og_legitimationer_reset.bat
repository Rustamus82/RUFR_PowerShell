::Script kompileret af RUFR@ssi.dk

@ECHO off
TITLE Nulstiller Outlookprofil og sletter gemte Outlook/Lync legitimationer...
@ECHO TITLE Nulstiller Outlookprofil og sletter gemte Outlook/Lync legitimationer...

::Nulstiller outlook profil og Lync
TASKKILL /F /IM outlook.exe
REG DELETE HKEY_CURRENT_USER\Software\Microsoft\Office\15.0\Outlook\Profiles /f

start lync.exe
timeout /t 5 /nobreak
TASKKILL /F /IM lync.exe
C:
CD C:\Users\%username%\AppData\Local\Microsoft\Office\15.0\Lync\
timeout /t 10 /nobreak
RD sip_%username%@ssi.dk /S /Q

::Eksporterer Legitimationer til temp.
cmdkey.exe /list > "%TEMP%\cmdkeyList.txt"

::Sletter kun windows gemte legitimationer.
findstr.exe Target "%TEMP%\cmdkeyList.txt" > "%TEMP%\tokensonly.txt"
FOR /F "tokens=1,2 delims= " %%G IN (%TEMP%\tokensonly.txt) DO cmdkey.exe /delete:%%H

::Rydder op i %temp%
del "%TEMP%\*.*" /s /f /q

::Se Eksporterer Legitimationer til temp "Currently stored credentials"
cmdkey.exe /list > "%TEMP%\cmdkeyList2.txt"

::Importerer Concierge indstilinger reg.
reg import "\\msfc-uivs\uvl\IT\Solution\Client\Win8.1\Outlook\ConciergeRegistry\Concierge_Office365_registry.reg"

::Opdaterrer politiker og genstarter PC.
gpupdate /force
shutdown -r -f -t 5 /c "Din PC vil bliver genstartet, Husk at gemme din Data og lukke alle andre programmer, ikke gemte data bliver tabt! Mvh. IOS Drift og Support"!"