net stop wuauserv
del "%SYSTEMROOT%\SoftwareDistribution" /q /s
net start wuauserv