REM to start psexec from current folder mvh. Rust@m
sc \\%COMPUTERNAME% config remoteregistry start= demand
"%~dp0%~1\PsExec.exe" /accepteula -s -i cmd.exe
rem  cmd.exe /K "%~dp0%~1\PsExec.exe" -s -i cmd.exe
rem whoami


