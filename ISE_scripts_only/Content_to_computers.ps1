#PSVersion 5 Script made/assembled by Rust@m 02-05-2018
<#Login RUFR all AD login, Hybrid and o365
$CommandPath = (Get-Location).Path | Split-Path -Parent; $script = "$CommandPath\Logins\Login_SSI_SST_exch2010_DKSUND_Exchange365_RUFR.ps1"; & $script

#Login RUFR only office365
Import-Module MSOnline
$Global:credo365 = Get-Credential adm-rufr@dksund.onmicrosoft.com -Message "login til  Office 365"
$Global:sessiono365 = New-PSSession -ConfigurationName Microsoft.Exchange -Authentication Basic -ConnectionUri https://ps.outlook.com/powershell -AllowRedirection:$true  -Credential $Global:credo365
Import-PSSession $Global:sessiono365 -Prefix o365 -AllowClobber
Connect-MsolService -Credential $Global:credo365
cls
#>

# This file contains the list of servers you want to copy files/folders to
#$computers = Get-Content "C:\scripts\servers.txt"

#$currentpath = (Resolve-Path .\).Path
$WorkingDir = Convert-Path .

$CSV = Import-CSV "$WorkingDir\CSV\Computers.csv" -Delimiter ";"
$computers = $CSV.name
$computers = "SSI000447.ssi.ad"
cls

 
# This is the file/folder(s) you want to copy to the servers in the $computer variable
#$source = "C:\Users\Public\Desktop\Software Center.lnk"
$source = "$WorkingDir\InstallSource\SCCM_Client_Install" 
# The destination location you want the file/folder(s) to be copied to
$destination = "C$\SCCM_Client_Install\"

$pathtest ="C$"
cls

foreach ($computer in $computers) {
if ((Test-Path -Path \\$computer\$pathtest)) {
Copy-Item $source -Destination \\$computer\$destination -Recurse -Force -Verbose
} else {
"\\$computer\$destination is not reachable or does not exist"
}
}


Test-Connection -ComputerName $computers



##Source packages
#Sccm reinstall
$CommandPath = (Get-Location).Path; $InstallPackageFiles = "$CommandPath\InstallSource\SCCM_Client_Install"



##Enter Sessions for remote Computers
#PSsessions SSI, enter remote PC
Enter-PSSession -ComputerName $computer 


#install remotely, execute install files
& "$env:SystemDrive\SCCM_Client_Install\Certificates\Import.cmd";
& "$env:SystemDrive\SCCM_Client_Install\_RunMeSCCM_reinstall.cmd"; 
get-content "$env:SystemRoot\ccmsetup\logs\ccmsetup.log" -Tail 20
Remove-Item -Path "$env:SystemDrive\SCCM_Client_Install\" -Recurse
exit
