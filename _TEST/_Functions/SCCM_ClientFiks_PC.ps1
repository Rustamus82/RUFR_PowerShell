& "C:\SysinternalsSuite\psexec.exe" --% /accepteula /s \\STD001136 cmd /K

hostname
C:\Windows\ccmsetup\ccmsetup /uninstall

cmtrace.exe \\STD001136\admin$\ccmsetup\logs\ccmsetup.log 



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
C:\Windows\System32\WBEM\winmgmt.exe /resetrepository

NET START iphlpsvc
NET START wscsvc

\\STD001136\admin$\System32\WBEM\Repository