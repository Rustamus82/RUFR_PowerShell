REM the execution in this case are directly from hybrid server, else need to be adapted to other server if no hybrid exists

Program
C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe

add argument(optional): 
-NonInteractive -WindowStyle Hidden -command ". 'C:\Program Files\Microsoft\Exchange Server\V15\bin\RemoteExchange.ps1'; Connect-ExchangeServer -auto; c:\exchange\scripts\EnableRemoteMailbox_v2.ps1 -CreateMultipleUsers"

start in:
c:\exchange\scripts
