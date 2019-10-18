#PSVersion 5 Script made/assembled by Rust@m 02-05-2018
<#Login RUFR all AD login, Hybrid and o365
$CommandPath = (Get-Location).Path | Split-Path -Parent; $script = "$CommandPath\Logins\Login_SSI_SST_exch2010_DKSUND_Exchange365_RUFR.ps1"; & $script

cls
Exit
#>

##Logins

# 1 Log på SSI
$Global:UserCredSSI = Get-Credential -Message "Angiv brugernavn og password" -UserName ’ssi\adm-rufr’

# 1 Log på DKSUND
$Global:UserCredDKSUND = Get-Credential -Message "Angiv brugernavn og password" -UserName ’dksund\adm-rufr’

# 1 Log på SST
$Global:UserCredSST = Get-Credential -Message "Angiv brugernavn og password" -UserName ’sst.dk\adm-rufr’


$computer = 'SSI004337.ssi.ad';Test-Connection -ComputerName $computer


## Computer sessions
#DKSUND
$PCSession = New-PSSession -ComputerName $computer -Credential $Global:UserCredDKSUND
#SSI
$PCSession = New-PSSession -ComputerName $computer -Credential $Global:UserCredSSI
#SST
$PCSession = New-PSSession -ComputerName $computer -Credential $Global:UserCredSST


##Source packages
#Sccm reinstall
$CommandPath = (Get-Location).Path; $InstallPackageFiles = "$CommandPath\InstallSource\SCCM_Client_Install"

#Citrix cleanup tool
$CommandPath = (Get-Location).Path; $InstallPackageFiles = "$CommandPath\InstallSource\ReceiverCleanupUtility"

##Copy to Remote PC sessions
#copy to session  - perform the file copy via -ToSession parameter:
Copy-Item -Path $InstallPackageFiles -Destination "C:\SCCM_Client_Install" -ToSession $PCSession -Recurse -Force
Copy-Item -Path $InstallPackageFiles -Destination "C:\ReceiverCleanupUtility" -ToSession $PCSession -Recurse -Force
#Copy-Item -FromSession $PCSession -Path "C:\Users\Administrator\desktop\scripts\" -Destination "C:\Users\administrator\desktop\" -Recurse


##Enter Sessions for remote Computers
#PSsessions SSI, enter remote PC
Enter-PSSession -ComputerName $computer -Credential $Global:UserCredDKSUND

#PSsessions SSI, enter remote PC
Enter-PSSession -ComputerName $computer -Credential $Global:UserCredSSI

#PSsessions SST, enter remote PC
Enter-PSSession -ComputerName $computer -Credential $Global:UserCredSST

#install remotely, execute install files
& "$env:SystemDrive\SCCM_Client_Install\_RunMeSCCM_reinstall.cmd"; 
get-content "$env:SystemRoot\ccmsetup\logs\ccmsetup.log" -Tail 20
Remove-Item -Path "$env:SystemDrive\SCCM_Client_Install\" -Recurse
exit


#install remotely, execute install files
& "$env:SystemDrive\ReceiverCleanupUtility\ReceiverCleanupUtility.exe" /silent; 
get-content "$env:SystemDrive\ReceiverCleanupUtility\ReceiverLogs\CleanupToolLog.txt" -Tail 10
get-content "$env:SystemDrive\ReceiverCleanupUtility\ReceiverLogs\Uninstall.log" -Tail 10
Remove-Item -Path "$env:SystemDrive\ReceiverCleanupUtility\" -Recurse
exit


##get list of installed software, takes some time to gather:
Get-WmiObject -Class Win32_Product  -ComputerName .| Sort-Object InstallDate -Descending | Format-Table -Property Name,InstallDate,Vendor,Version, IdentifyingNumber -AutoSize

##Exit Sessions for remote Computers
cls;exit

#Get Environment Variables
Get-ChildItem Env: | Sort Name

#Enable remoteregistry
#Enable remoteregistry via cmd: sc \\TST005377 config remoteregistry start= demand
Set-Service -Name RemoteRegistry -ComputerName . -StartupType Manual

#remember this script should be in elevated mode before this one works
Set-Service -Name RemoteRegistry -ComputerName $computer -StartupType Manual
Get-Service "RemoteRegistry" -ComputerName . | start-service


#Check Powershell version.
$PSVersionTable

<# Enable PS remoting via remote CMD start cmd as admin#>
C:\SysinternalsSuite\psexec.exe /accepteula /s \\SDS000328 cmd /K
%SYSTEMROOT%\System32\WindowsPowerShell\v1.0\powershell.exe -Noninteractive -Executionpolicy ByPass -command "& {enable-psremoting -force}"
#>

#check diskspace
Invoke-Command -ComputerName SDS000328.dksund.dk {Get-PSDrive | Where {$_.Free -gt 0}} -Credential $Global:UserCredDKSUND
get-WmiObject win32_logicaldisk -ComputerName SDS000328.dksund.dk
Restart-Computer


AEF klient odbc opdatering.
#Ved remove skal angives både platform + DSNtype + Navn
#ADD har nogle problemer med at default sql server opsætningen (men dette kan ordnes via user settings i DB)
# computernavn: SSI004337    
get-OdbcDsn 
#verifcer..
Remove-OdbcDsn -Name "AEF" -DsnType All -Platform '32-bit'

Add-OdbcDsn -Name "AEF" -DriverName "SQL Server" -DsnType "System" -Platform "32-bit" -SetPropertyValue @("Server=srv-mssql.07p", "Trusted_Connection=Yes", "Database=AEF")
