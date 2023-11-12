net stop wuauserv
del "%SYSTEMROOT%\SoftwareDistribution" /q /s
net start wuauserv
del "%systemroot%\temp\*.*" /q /s
cleanmgr.exe /VERYLOWDISK
cleanmgr.exe /AUTOCLEAN
