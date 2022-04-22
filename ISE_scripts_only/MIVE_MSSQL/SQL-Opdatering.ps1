# udførende jobnavn: giver variable disk, sti, fil Kan ikke være i include fil, da det vil være denne fil der registreres
$EgoCmd=$PSCommandPath -Split("\\")     # $EgoCmd= 'm:','ps1','SQL-Opdatering.ps1'
$Egodisk=$EgoCmd[0]
$Egofil=$EgoCmd[-1]
If($EgoCmd.Count -lt 3){$Egosti=''}elseif($EgoCmd.Count -eq 3){$Egosti=$EgoCmd[1]}else{$EgoCmd1=$EgoCmd[1..($EgoCmd.Count-2)];$Egosti=$EgoCmd1 -join("\")}
# Function module File to include
$FincPath="p:\sqldba\ps1\u\inclFunc.ps1"
If (test-path $FincPath){
. "$FincPath"
}
Get-EgoVar
# Lokale variable
#$EgoServer=$env:Computername
#$EgoDomain=$env:Userdnsdomain
#$EgoDomainbs=$EgoDomain+"\\"
# Os Version
#$EgoOs = Gwmi win32_operatingsystem -cn $EgoServer
#$EgoCore=(Get-ItemProperty -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\" -Name InstallationType).InstallationType
#$Farr=(($EgoOs.name -split("\|"))[0]) -split(" ");foreach($F in $Farr){If (Is-Num $F) {$EgoWin=$F}}
#$EgoCmd
If (!($EgoCmd[-2] -eq "ps1")) {
	Write-Host "SQL-Installation.ps1 skal køres fra folderen p:\sqldba\ps1"
	exit
}
If(!($EgoIsAdm)) {
    Write-Output "Du skal være logget på som Administrator for at Opdatere SQL Server"
    Exit
}
$FVpath="$Egodisk\$Egosti\$EgoWin"
if(!(test-Path $FVpath)){
	Write-Host "Folder: $Egodisk\$Egosti\$EgoWin findes ikke! OS melder:" ($EgoOs.name -split("\|"))[0]
	exit
}
$FSparm="SqlInstParm.xml"
$FSpath="$Egodisk\$Egosti\$EgoWin\$EgoServer"
if(test-Path $FSpath){
Write-Host "Server Folder: $FSpath findes"
}else{
New-Item -Path $FSpath  -ItemType Directory
Write-Host "Server Folder: $FSpath oprettet"
}

$rc=Get-Service -displayname 'Sql Server (*'
if(!($rc.status -eq "Running")){
	Write-Host "Man kan ikke opdatere en SQL Server der ikke kører (SQL engine) Start SQL "
	Exit
}

do{
	$svar=Read-Host "Hvis du lige har installeret SQL Server, bør du lige genstarte Serveren før opdateringen. Er du klar til at fortsætte? (ja/nej)"
	If ($svar -in 'ja','j','J','y','Y','q') {write-host "Fint!";$svar = "ja"
	} elseIf ($svar -in 'Nej','n','N','no') {write-host "ok, slutter , Farvel!";exit}
} until ($svar -eq "ja")

$pm=@{}
if(test-Path $FSpath\$FSparm){
	Write-Host "Param fil findes"
	$pm=Import-Clixml -Path $FSpath\$FSparm
}else{
	Write-Host "Param fil Skal oprettes først.  Kør P:\sqldba\ps1\SQL-Installation.ps1"
	Exit
}

If($Pm.SqlEdition -eq ""){
	Write-Host "SqlEdition skal findes i Param fil.  Kør P:\sqldba\ps1\SQL-Installation.ps1"
	Exit
}
If($Pm.SqlVer -eq ""){
	Write-Host "SqlVersion skal findes i Param fil.  Kør P:\sqldba\ps1\SQL-Installation.ps1"
	Exit
}
$Pm
do{
	$svar=Read-Host "Ser parametrene fine ud? (ja/nej)"
	If ($svar -in 'ja','j','J','y','Y') {write-host "Fint!";$svar = "ja"
	} elseIf ($svar -in 'Nej','n','N','no') {write-host "ok, slutter , Farvel!";exit}
} until ($svar -eq "ja")

Write-Host "SQL Opdaterings Proceduren for SQL Server v. " $Pm.SqlVer 
do{
	$svar=Read-Host "Klar til at fortsætte opdateringsprocessen? (ja/nej)"
	If ($svar -in 'ja','j','J','y','Y','q') {write-host "Fint!";$svar = "ja"
	} elseIf ($svar -in 'Nej','n','N','no') {write-host "ok, slutter , Farvel!";exit}
} until ($svar -eq "ja")
$a=Get-Module sqlserver
If (!(($a.name).length -gt 0)) {
	# Check om sqlserver module Installeret.
	$IsSqlPath="p:\sqldba\ps1\u\Is-Sql.ps1"
	If (test-path $IsSqlPath){
		. "$IsSqlPath"
	}
}
$a=invoke-sqlcmd -ServerInstance "(local)" -query "Select Serverproperty('Productlevel') as SP,Serverproperty('ProductUpdateLevel') As Cu"
If (!(($a.sp).Length -gt 0)) {
	Write-Host "invoke-sqlcmd ikke installeret  skal findes i Param fil.  Kør P:\sqldba\ps1\SQL-Installation.ps1"
	Exit
}

switch ($Pm.SqlVer)
{
    "2019" {
		$cdisk='c:'
		$InstCpath='\install\19ServUpd'
		$SPdisk='p:'
		$SPpath='\MSSQL_SP_CU\SQL_Server_2019_ServUpd'
		if (!(test-path $SPdisk\sqldba\)) {
			Write-error "Install Disk p: er ikke tilknyttet." ;exit}
		If(!(test-path $cdisk$InstCpath)) {New-Item -ItemType directory -Path $cdisk$InstCpath -Force}
		If(!(test-path $cdisk$InstCpath)) {Write-error "Install Path $cdisk$InstCpath kan ikke oprettes." ;exit}
		$rc=Get-ChildItem $SPdisk$SPpath"\sqlserver2019*"
		$exec=$rc.name
		If(!(test-path $SPdisk$SPpath\$exec)) {Write-error "SQL Opdatering $SPdisk$SPpath\$exec <ikke fundet." ;exit}
		Copy-Item -Path $SPdisk$SPpath\$exec -Destination $cdisk$InstCpath
		If(!(test-path $cdisk$InstCpath\$exec)) {Write-error "Fil: $SPdisk$SPpath\$exec ikke kopieret til $cdisk$InstCpath" ;exit}
		$arg="/qs /Action=Patch /AllInstances /IAcceptSQLServerLicenseTerms "
		#$arg
		Start-Process -wait -FilePath $cdisk$InstCpath\$exec -ArgumentList $arg 
		do{
			$svar=Read-Host "Ser det fint ud? Efter Opdateringen er færdig? (ja/nej)"
			If ($svar -in 'ja','j','J','y','Y','q') {
				write-host "Fint!"
				Write-Host "Start Kontrolpanel: Win-R Control"
				Write-Host "Start Configuration Manager"
				Write-Host "Klik Actions"
				Write-Host "Vælg Software Updates Scan Cycle"
				Write-Host "Klik Run Now"
				Write-Host "Start MS SSMS og kontroller opdatering!"
				Write-Host "Vent på at DBA_DB kører Collect i nat (eller start collfetch på 09t)"
				$svar = "ja"
			} elseIf ($svar -in 'Nej','n','N','no') {write-host "ok, slutter , Farvel!";exit}
		} until ($svar -eq "ja")
		invoke-sqlcmd -ServerInstance "(local)" -query "Select Serverproperty('Productlevel') as SP,Serverproperty('ProductUpdateLevel') As Cu"
	}    
	"2016" {
		$cdisk='c:'
		$InstCpath='\install\16ServUpd'
		$SPdisk='p:'
		$SPpath='\MSSQL_SP_CU\SQL_Server_2016_CU'
		if (!(test-path $SPdisk\sqldba\)) {
			Write-error "Install Disk p: er ikke tilknyttet." ;exit}
		If(!(test-path $cdisk$InstCpath)) {New-Item -ItemType directory -Path $cdisk$InstCpath -Force}
		If(!(test-path $cdisk$InstCpath)) {Write-error "Install Path $cdisk$InstCpath kan ikke oprettes." ;exit}
		$rc=Get-ChildItem $SPdisk$SPpath"\*.exe"
		$exec=$rc.name
		If(!(test-path $SPdisk$SPpath\$exec)) {Write-error "SQL Opdatering $SPdisk$SPpath\$exec <ikke fundet." ;exit}
		Copy-Item -Path $SPdisk$SPpath\$exec -Destination $cdisk$InstCpath
		If(!(test-path $cdisk$InstCpath\$exec)) {Write-error "Fil: $SPdisk$SPpath\$exec ikke kopieret til $cdisk$InstCpath" ;exit}
		$arg="/qs /Action=Patch /AllInstances /IAcceptSQLServerLicenseTerms "
		#$arg
		Start-Process -wait -FilePath $cdisk$InstCpath\$exec -ArgumentList $arg 
		do{
			$svar=Read-Host "Ser det fint ud? Efter Opdateringen er færdig? (ja/nej)"
			If ($svar -in 'ja','j','J','y','Y','q') {
				write-host "Fint!"
				Write-Host "Start Kontrolpanel: Win-R Control"
				Write-Host "Start Configuration Manager"
				Write-Host "Klik Actions"
				Write-Host "Vælg Software Updates Scan Cycle"
				Write-Host "Klik Run Now"
				Write-Host "Start MS SSMS og kontroller opdatering!"
				Write-Host "Vent på at DBA_DB kører Collect i nat (eller start collfetch på 09t)"
				$svar = "ja"
			} elseIf ($svar -in 'Nej','n','N','no') {write-host "ok, slutter , Farvel!";exit}
		} until ($svar -eq "ja")
		invoke-sqlcmd -ServerInstance "(local)" -query "Select Serverproperty('Productlevel') as SP,Serverproperty('ProductUpdateLevel') As Cu"
	}
    "2014" {
		$cdisk='c:'
		$InstCpath='\install\14ServUpd'
		$SPdisk='p:'
		$SPpath='\MSSQL_SP_CU\SQL_Server_2014_ServUpd'
		if (!(test-path $SPdisk\sqldba\)) {
			Write-error "Install Disk p: er ikke tilknyttet." ;exit}
		If(!(test-path $cdisk$InstCpath)) {New-Item -ItemType directory -Path $cdisk$InstCpath -Force}
		If(!(test-path $cdisk$InstCpath)) {Write-error "Install Path $cdisk$InstCpath kan ikke oprettes." ;exit}
		$rc=Get-ChildItem $SPdisk$SPpath"\*.exe"
		$exec=$rc.name
		If(!(test-path $SPdisk$SPpath\$exec)) {Write-error "SQL Opdatering $SPdisk$SPpath\$exec <ikke fundet." ;exit}
		Copy-Item -Path $SPdisk$SPpath\$exec -Destination $cdisk$InstCpath
		If(!(test-path $cdisk$InstCpath\$exec)) {Write-error "Fil: $SPdisk$SPpath\$exec ikke kopieret til $cdisk$InstCpath" ;exit}
		$arg="/qs /Action=Patch /AllInstances /IAcceptSQLServerLicenseTerms "
		#$arg
		Start-Process -wait -FilePath $cdisk$InstCpath\$exec -ArgumentList $arg 
		do{
			$svar=Read-Host "Ser det fint ud? Efter Opdateringen er færdig? (ja/nej)"
			If ($svar -in 'ja','j','J','y','Y','q') {
				write-host "Fint!"
				Write-Host "Start Kontrolpanel: Win-R Control"
				Write-Host "Start Configuration Manager"
				Write-Host "Klik Actions"
				Write-Host "Vælg Software Updates Scan Cycle"
				Write-Host "Klik Run Now"
				Write-Host "Start MS SSMS og kontroller opdatering!"
				Write-Host "Vent på at DBA_DB kører Collect i nat (eller start collfetch på 09t)"
				$svar = "ja"
			} elseIf ($svar -in 'Nej','n','N','no') {write-host "ok, slutter , Farvel!";exit}
		} until ($svar -eq "ja")
		invoke-sqlcmd -ServerInstance "(local)" -query "Select Serverproperty('Productlevel') as SP,Serverproperty('ProductUpdateLevel') As Cu"
	}    
    "2012" {
		$cdisk='c:'
		$InstCpath='\install\12ServUpd'
		$SPdisk='p:'
		$SPpath='\MSSQL_SP_CU\SQL_Server_2012_ServUpd'
		if (!(test-path $SPdisk\sqldba\)) {
			Write-error "Install Disk p: er ikke tilknyttet." ;exit}
		If(!(test-path $cdisk$InstCpath)) {New-Item -ItemType directory -Path $cdisk$InstCpath -Force}
		If(!(test-path $cdisk$InstCpath)) {Write-error "Install Path $cdisk$InstCpath kan ikke oprettes." ;exit}
		$rc=Get-ChildItem $SPdisk$SPpath"\*.exe"
		$exec=$rc.name
		If(!(test-path $SPdisk$SPpath\$exec)) {Write-error "SQL Opdatering $SPdisk$SPpath\$exec <ikke fundet." ;exit}
		Copy-Item -Path $SPdisk$SPpath\$exec -Destination $cdisk$InstCpath
		If(!(test-path $cdisk$InstCpath\$exec)) {Write-error "Fil: $SPdisk$SPpath\$exec ikke kopieret til $cdisk$InstCpath" ;exit}
		$arg="/qs /Action=Patch /AllInstances /IAcceptSQLServerLicenseTerms "
		#$arg
		Start-Process -wait -FilePath $cdisk$InstCpath\$exec -ArgumentList $arg 
		do{
			$svar=Read-Host "Ser det fint ud? Efter Opdateringen er færdig? (ja/nej)"
			If ($svar -in 'ja','j','J','y','Y','q') {
				write-host "Fint!"
				Write-Host "Start Kontrolpanel: Win-R Control"
				Write-Host "Start Configuration Manager"
				Write-Host "Klik Actions"
				Write-Host "Vælg Software Updates Scan Cycle"
				Write-Host "Klik Run Now"
				Write-Host "Start MS SSMS og kontroller opdatering!"
				Write-Host "Vent på at DBA_DB kører Collect i nat (eller start collfetch på 09t)"
				$svar = "ja"
			} elseIf ($svar -in 'Nej','n','N','no') {write-host "ok, slutter , Farvel!";exit}
		} until ($svar -eq "ja")
		invoke-sqlcmd -ServerInstance "(local)" -query "Select Serverproperty('Productlevel') as SP,Serverproperty('ProductUpdateLevel') As Cu"
	}    
	default {Write-Host "der er ikke klargjort procedure for SQL Version:" $Pm.SqlVer}
}


# SIG # Begin signature block
# MIIdAgYJKoZIhvcNAQcCoIIc8zCCHO8CAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCCepODpXQeVovHq
# vObdigE+aRd9GFOyUrWCBFWHo2PBSaCCGBMwggT+MIID5qADAgECAhANQkrgvjqI
# /2BAIc4UAPDdMA0GCSqGSIb3DQEBCwUAMHIxCzAJBgNVBAYTAlVTMRUwEwYDVQQK
# EwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xMTAvBgNV
# BAMTKERpZ2lDZXJ0IFNIQTIgQXNzdXJlZCBJRCBUaW1lc3RhbXBpbmcgQ0EwHhcN
# MjEwMTAxMDAwMDAwWhcNMzEwMTA2MDAwMDAwWjBIMQswCQYDVQQGEwJVUzEXMBUG
# A1UEChMORGlnaUNlcnQsIEluYy4xIDAeBgNVBAMTF0RpZ2lDZXJ0IFRpbWVzdGFt
# cCAyMDIxMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAwuZhhGfFivUN
# CKRFymNrUdc6EUK9CnV1TZS0DFC1JhD+HchvkWsMlucaXEjvROW/m2HNFZFiWrj/
# ZwucY/02aoH6KfjdK3CF3gIY83htvH35x20JPb5qdofpir34hF0edsnkxnZ2OlPR
# 0dNaNo/Go+EvGzq3YdZz7E5tM4p8XUUtS7FQ5kE6N1aG3JMjjfdQJehk5t3Tjy9X
# tYcg6w6OLNUj2vRNeEbjA4MxKUpcDDGKSoyIxfcwWvkUrxVfbENJCf0mI1P2jWPo
# GqtbsR0wwptpgrTb/FZUvB+hh6u+elsKIC9LCcmVp42y+tZji06lchzun3oBc/gZ
# 1v4NSYS9AQIDAQABo4IBuDCCAbQwDgYDVR0PAQH/BAQDAgeAMAwGA1UdEwEB/wQC
# MAAwFgYDVR0lAQH/BAwwCgYIKwYBBQUHAwgwQQYDVR0gBDowODA2BglghkgBhv1s
# BwEwKTAnBggrBgEFBQcCARYbaHR0cDovL3d3dy5kaWdpY2VydC5jb20vQ1BTMB8G
# A1UdIwQYMBaAFPS24SAd/imu0uRhpbKiJbLIFzVuMB0GA1UdDgQWBBQ2RIaOpLqw
# Zr68KC0dRDbd42p6vDBxBgNVHR8EajBoMDKgMKAuhixodHRwOi8vY3JsMy5kaWdp
# Y2VydC5jb20vc2hhMi1hc3N1cmVkLXRzLmNybDAyoDCgLoYsaHR0cDovL2NybDQu
# ZGlnaWNlcnQuY29tL3NoYTItYXNzdXJlZC10cy5jcmwwgYUGCCsGAQUFBwEBBHkw
# dzAkBggrBgEFBQcwAYYYaHR0cDovL29jc3AuZGlnaWNlcnQuY29tME8GCCsGAQUF
# BzAChkNodHRwOi8vY2FjZXJ0cy5kaWdpY2VydC5jb20vRGlnaUNlcnRTSEEyQXNz
# dXJlZElEVGltZXN0YW1waW5nQ0EuY3J0MA0GCSqGSIb3DQEBCwUAA4IBAQBIHNy1
# 6ZojvOca5yAOjmdG/UJyUXQKI0ejq5LSJcRwWb4UoOUngaVNFBUZB3nw0QTDhtk7
# vf5EAmZN7WmkD/a4cM9i6PVRSnh5Nnont/PnUp+Tp+1DnnvntN1BIon7h6JGA078
# 9P63ZHdjXyNSaYOC+hpT7ZDMjaEXcw3082U5cEvznNZ6e9oMvD0y0BvL9WH8dQgA
# dryBDvjA4VzPxBFy5xtkSdgimnUVQvUtMjiB2vRgorq0Uvtc4GEkJU+y38kpqHND
# Udq9Y9YfW5v3LhtPEx33Sg1xfpe39D+E68Hjo0mh+s6nv1bPull2YYlffqe0jmd4
# +TaY4cso2luHpoovMIIFMTCCBBmgAwIBAgIQCqEl1tYyG35B5AXaNpfCFTANBgkq
# hkiG9w0BAQsFADBlMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5j
# MRkwFwYDVQQLExB3d3cuZGlnaWNlcnQuY29tMSQwIgYDVQQDExtEaWdpQ2VydCBB
# c3N1cmVkIElEIFJvb3QgQ0EwHhcNMTYwMTA3MTIwMDAwWhcNMzEwMTA3MTIwMDAw
# WjByMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQL
# ExB3d3cuZGlnaWNlcnQuY29tMTEwLwYDVQQDEyhEaWdpQ2VydCBTSEEyIEFzc3Vy
# ZWQgSUQgVGltZXN0YW1waW5nIENBMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIB
# CgKCAQEAvdAy7kvNj3/dqbqCmcU5VChXtiNKxA4HRTNREH3Q+X1NaH7ntqD0jbOI
# 5Je/YyGQmL8TvFfTw+F+CNZqFAA49y4eO+7MpvYyWf5fZT/gm+vjRkcGGlV+Cyd+
# wKL1oODeIj8O/36V+/OjuiI+GKwR5PCZA207hXwJ0+5dyJoLVOOoCXFr4M8iEA91
# z3FyTgqt30A6XLdR4aF5FMZNJCMwXbzsPGBqrC8HzP3w6kfZiFBe/WZuVmEnKYmE
# UeaC50ZQ/ZQqLKfkdT66mA+Ef58xFNat1fJky3seBdCEGXIX8RcG7z3N1k3vBkL9
# olMqT4UdxB08r8/arBD13ays6Vb/kwIDAQABo4IBzjCCAcowHQYDVR0OBBYEFPS2
# 4SAd/imu0uRhpbKiJbLIFzVuMB8GA1UdIwQYMBaAFEXroq/0ksuCMS1Ri6enIZ3z
# bcgPMBIGA1UdEwEB/wQIMAYBAf8CAQAwDgYDVR0PAQH/BAQDAgGGMBMGA1UdJQQM
# MAoGCCsGAQUFBwMIMHkGCCsGAQUFBwEBBG0wazAkBggrBgEFBQcwAYYYaHR0cDov
# L29jc3AuZGlnaWNlcnQuY29tMEMGCCsGAQUFBzAChjdodHRwOi8vY2FjZXJ0cy5k
# aWdpY2VydC5jb20vRGlnaUNlcnRBc3N1cmVkSURSb290Q0EuY3J0MIGBBgNVHR8E
# ejB4MDqgOKA2hjRodHRwOi8vY3JsNC5kaWdpY2VydC5jb20vRGlnaUNlcnRBc3N1
# cmVkSURSb290Q0EuY3JsMDqgOKA2hjRodHRwOi8vY3JsMy5kaWdpY2VydC5jb20v
# RGlnaUNlcnRBc3N1cmVkSURSb290Q0EuY3JsMFAGA1UdIARJMEcwOAYKYIZIAYb9
# bAACBDAqMCgGCCsGAQUFBwIBFhxodHRwczovL3d3dy5kaWdpY2VydC5jb20vQ1BT
# MAsGCWCGSAGG/WwHATANBgkqhkiG9w0BAQsFAAOCAQEAcZUS6VGHVmnN793afKpj
# erN4zwY3QITvS4S/ys8DAv3Fp8MOIEIsr3fzKx8MIVoqtwU0HWqumfgnoma/Capg
# 33akOpMP+LLR2HwZYuhegiUexLoceywh4tZbLBQ1QwRostt1AuByx5jWPGTlH0gQ
# GF+JOGFNYkYkh2OMkVIsrymJ5Xgf1gsUpYDXEkdws3XVk4WTfraSZ/tTYYmo9WuW
# wPRYaQ18yAGxuSh1t5ljhSKMYcp5lH5Z/IwP42+1ASa2bKXuh1Eh5Fhgm7oMLStt
# osR+u8QlK0cCCHxJrhO24XxCQijGGFbPQTS2Zl22dHv1VjMiLyI2skuiSpXY9aaO
# UjCCBi0wggQVoAMCAQICE2oAANdl/WBX1Cl4R54AAQAA12UwDQYJKoZIhvcNAQEL
# BQAwSDESMBAGCgmSJomT8ixkARkWAmRrMRYwFAYKCZImiZPyLGQBGRYGZGtzdW5k
# MRowGAYDVQQDExFES1NVTkQgSXNzdWluZyBDQTAeFw0yMDA5MDkwOTEwMjhaFw0y
# NTA5MDgwOTEwMjhaMCgxJjAkBgNVBAMTHU1pa2FlbCBWZWlzdHJ1cC1WZXRsb3Yg
# KE1JVkUpMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA4wfkCXfwnVva
# 6BA19L5jKeKjH0tQ2zC5b/gKPtATh3rwDnXbnlXLy6+YBY+O3Lb9ZyZqJT5F5GFI
# XTK0w8m6wXj+EkT/UbnMPZRv0RTNePTzwwaRpMRifPwQD2V1PXk+1WbERHcC9uoh
# a27uR8ZU6ZxqS46mKb6fNEf1FSwTBjyDRhR+FA2Jf8JwfUYw7YFRnA6XtIY3htkY
# WTLDJpphw+mzOofqUrOY/eOOTejmWrIa+bHQg3ln6jHTfBsUo9eB5yyH8vfeHIQO
# I2FJQCnbs2hG75akh2HBViiP27oQKKstSKfuY1LpgHGxSr8g7lQTG5A6kTWbb0r7
# svtLRYYYuQIDAQABo4ICLjCCAiowPAYJKwYBBAGCNxUHBC8wLQYlKwYBBAGCNxUI
# h/nRJIXb10WCjYcZhcCgPYTQhCmBFPLKfrz0EgIBZAIBCjATBgNVHSUEDDAKBggr
# BgEFBQcDAzAOBgNVHQ8BAf8EBAMCB4AwGwYJKwYBBAGCNxUKBA4wDDAKBggrBgEF
# BQcDAzAdBgNVHQ4EFgQUL9wQMXuOxRzADB2QWCT78WWgF38wHwYDVR0jBBgwFoAU
# w4L0QWT8TyL4NsMTBaMx81ntghYwPwYDVR0fBDgwNjA0oDKgMIYuaHR0cDovL3Br
# aS5ka3N1bmQuZGsvREtTVU5EJTIwSXNzdWluZyUyMENBLmNybDCCAQQGCCsGAQUF
# BwEBBIH3MIH0MD0GCCsGAQUFBzAChjFodHRwOi8vcGtpLmRrc3VuZC5kay9ES1NV
# TkQlMjBJc3N1aW5nJTIwQ0EoMSkuY3J0MIGyBggrBgEFBQcwAoaBpWxkYXA6Ly8v
# Q049REtTVU5EJTIwSXNzdWluZyUyMENBLENOPUFJQSxDTj1QdWJsaWMlMjBLZXkl
# MjBTZXJ2aWNlcyxDTj1TZXJ2aWNlcyxDTj1Db25maWd1cmF0aW9uLERDPWRrc3Vu
# ZCxEQz1kaz9jQUNlcnRpZmljYXRlP2Jhc2U/b2JqZWN0Q2xhc3M9Y2VydGlmaWNh
# dGlvbkF1dGhvcml0eTAfBgNVHREEGDAWgRRNSVZFQHN1bmRoZWRzZGF0YS5kazAN
# BgkqhkiG9w0BAQsFAAOCAgEAaL1y1fp7myMA0rP6Yo7CiGJItA5z3qGTlbyLvgfB
# CVsg5EeMcWkLw7nRJSwuDnWjOA7jL9hoIK5Scy8I10KCXpzJX7KzKX6LocuTeEqt
# uKjmegQ3Ivv0B1fQHAJAGevgNl0OrGydMDkbVRkQmC0GbS9jdLMDWaGnsQaBeU+u
# BHvZ7kUwNAWBC0B5BFBMdmfX2juuMrtDoSHir/k5VpNeuhyutcY5RGHF934yUw5G
# fUOUrcZVYzodDyG+fhdJDPGPiqcq5SdURrwLaBbu00amj2wKzrouglLv5Xwe94qK
# TAUR4YYpW/6PSVr5lETCwFzBKkIQUxMjJ3LRCG9EtQo7dw8W35GR9bRW79nO5Fpt
# syf5ao1Zu9sRrYZYUzrEUZaLpoFbCdMN0KRAMqHY3ZLGOhWAFMnHfbZy+7JJ2svl
# gm97wQn64FYnrQjw+p+IGzt3nKAq/dzwpAGuDOPt7xOnwiPVOod+sw/G5pAZ6OAA
# 4igqgK5PaUBXmJquTDLf6RyMlWJex5O6myyHTKabzmF5ta6TeRgqUpfcefxU06ha
# NDIO5w1rmrEVLn+Jmd20jE4TucMO07i7EszdpSeuUeC2mzbDJlNOTkqnp5ul9bfT
# pSPzZT9gvchLZpgOTi1ck6LDe2eNw9wQgQ67kzdbA/Abnv6tlhiVOCUcf1t2XYN7
# vNcwggenMIIFj6ADAgECAhMSAAAAA/XTVIj+NIf5AAAAAAADMA0GCSqGSIb3DQEB
# CwUAMBkxFzAVBgNVBAMTDkRLU1VORCBSb290IENBMB4XDTE4MDMwNzExNTkwOVoX
# DTI4MDMwNzEyMDkwOVowSDESMBAGCgmSJomT8ixkARkWAmRrMRYwFAYKCZImiZPy
# LGQBGRYGZGtzdW5kMRowGAYDVQQDExFES1NVTkQgSXNzdWluZyBDQTCCAiIwDQYJ
# KoZIhvcNAQEBBQADggIPADCCAgoCggIBAJHxuqhN8Yo4v8+GwT1S89tOtHIZeu6n
# nGtG+nXBq5Um6/en0OkxQF15AjMr4aIQo7KQcEoGoeV6pkfPU2iy+xnLqZPar8sK
# fizfv8Oy8VQlquO/9McsulsKigJHHttoqvkr4tZc1vPUjsXL10aCEQq8zXCB5CJ5
# dCWAWFBJfb/Q/ywAfGBFIUPsaZlO7n5hMsLWZAxALmywnaH8/esZKrI7pyaj1b+P
# gBF877h3OCI96w1TH6iz/GHsmiO2/7+M8srbo7lwY1mqpWulujFotgRC6hnQnuqI
# ywwZLQut/oKUY32xIFKuRkeJMv+Sucv5zCFf/PlyKmR8xfOJ13TI9ktjusNbUaON
# iGGwD/g8J3ziuIjvaqE3Nn716v/8athfKkgZMXc5Hngd2dBi9R2S1Nyy2UI2hlWt
# YVJ7YDg1krHvjeDEwAKUP79UJLrLx7IJAaXxrySIl1K8EaJurNQdUbUb4SQNyCMK
# hHv3jOPw4j4yIFj3dMOqbPVdhn9qfzA4uo9xuXAKPEdM1a+TfkHnOD+ctbI/McHP
# 0+kwvMI29APqmlnA2g/je+PGkh0en3pRV0q7tmh39uXVa0KAgQ4o8zWwt62samuu
# q+9XMOTs+ZFwDXtK9wePw4QCRcsjMq9pD0xSSWlrrCH8XPQ4Y6GFhTJ3UCp07yT0
# gQBPFRQ6CsPLAgMBAAGjggK3MIICszAQBgkrBgEEAYI3FQEEAwIBATAjBgkrBgEE
# AYI3FQIEFgQUDOJFU7QVvhofIePf5eU+aJlSx6QwHQYDVR0OBBYEFMOC9EFk/E8i
# +DbDEwWjMfNZ7YIWMBkGCSsGAQQBgjcUAgQMHgoAUwB1AGIAQwBBMAsGA1UdDwQE
# AwIBhjAPBgNVHRMBAf8EBTADAQH/MB8GA1UdIwQYMBaAFG7UhySWgcqXaK5nzziA
# jEQF8yYFMIIBAQYDVR0fBIH5MIH2MIHzoIHwoIHthitodHRwOi8vcGtpLmRrc3Vu
# ZC5kay9ES1NVTkQlMjBSb290JTIwQ0EuY3JshoG9bGRhcDovLy9DTj1ES1NVTkQl
# MjBSb290JTIwQ0EsQ049Uy1QS0ktUk9PVDAxUCxDTj1DRFAsQ049UHVibGljJTIw
# S2V5JTIwU2VydmljZXMsQ049U2VydmljZXMsQ049Q29uZmlndXJhdGlvbixEQz1k
# a3N1bmQsREM9ZGs/Y2VydGlmaWNhdGVSZXZvY2F0aW9uTGlzdD9iYXNlP29iamVj
# dENsYXNzPWNSTERpc3RyaWJ1dGlvblBvaW50MIH7BggrBgEFBQcBAQSB7jCB6zA3
# BggrBgEFBQcwAoYraHR0cDovL3BraS5ka3N1bmQuZGsvREtTVU5EJTIwUm9vdCUy
# MENBLmNydDCBrwYIKwYBBQUHMAKGgaJsZGFwOi8vL0NOPURLU1VORCUyMFJvb3Ql
# MjBDQSxDTj1BSUEsQ049UHVibGljJTIwS2V5JTIwU2VydmljZXMsQ049U2Vydmlj
# ZXMsQ049Q29uZmlndXJhdGlvbixEQz1ka3N1bmQsREM9ZGs/Y0FDZXJ0aWZpY2F0
# ZT9iYXNlP29iamVjdENsYXNzPWNlcnRpZmljYXRpb25BdXRob3JpdHkwDQYJKoZI
# hvcNAQELBQADggIBAJ4ne9gV8KQyoFprJ35Rt/sO9u4aZWt2V24GmojT5Rlf5vfM
# 9xHc1wFMVepvW/JbPm2K744bu6/a5yBBUi5vHpTx3gzOVOUG01uIDln2kCIYgVda
# tnCP1xTkpGksnJW5S4qvHr7msRLTTWCG8X4MW5VbSfTJGGgs0uQ9v49wqaiOvopa
# TMMbQs4/HnJiVZU+IffG4iwOqgiEt7e5SOtFfTSd9D5qYEhNEfvf1jspB+aB1rV8
# 4Tj7SUlmQar2kfyDr6Lm2y0Gp8mLv2A0R9eHc3JggQFEyiVUhr7LkHJZf3541W9T
# UfR/RKcm/EEMdb1M7vvpT8VwPlvn0qzZ0TAsnDODH61u/WY3leEseYK/k9OL2LAp
# MEC+glnhC4KWZAwKLmBENr4XCISqysL/gMLtu5evCOiKZBJIcqZbX8poOWm2svF5
# iJ4oPgMoPJvL879LFDLrIBJsWBl4w7cdugiN1N7y+QYCkeYt+CrDtSvJcY3bEiXT
# 7YeuQkS95r/OatebJorp7WD1ZOrbnbAJuAcTFcV5/Ed+J7Vk1oEBeiy8DLxrXhQf
# OvrDIS9fWX0v7N+xH1pnjittto3bywKP7D98QQ2md8JrJONIu4X+gR4z8MlRKMrq
# InUVdnqClX3xfoeq1vVCWnS4vMh8TMn4LJe/g15PO7l1DJL2ZI4lOohSEqCZMYIE
# RTCCBEECAQEwXzBIMRIwEAYKCZImiZPyLGQBGRYCZGsxFjAUBgoJkiaJk/IsZAEZ
# FgZka3N1bmQxGjAYBgNVBAMTEURLU1VORCBJc3N1aW5nIENBAhNqAADXZf1gV9Qp
# eEeeAAEAANdlMA0GCWCGSAFlAwQCAQUAoIGEMBgGCisGAQQBgjcCAQwxCjAIoAKA
# AKECgAAwGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEO
# MAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEIFth09V/3Rsbu2lYmmjnUZZR
# /aJbiqSfqf6/7U9rf7zGMA0GCSqGSIb3DQEBAQUABIIBAJpkVISHbZxLlS3k6UJO
# SRReff2ulO/sPSawNBOAcmy+KwbxlnV3NS66KhXU1GDXpBfWtZ8pyTe6IyMZOmm5
# EjjZuFVBush7vYi/A6nucyds5pkE0yCpGzU1EcpvMa46IusG8SNfI4l6SPmRwMF9
# W4cylxGd07v2IdhbXAVumI/IUrfE+Emi6VVGrF6L5cUHD/tLqIvfDCk410WZWkct
# 1THGue5Bp4SkQS398JKSHyiky0agiJai5WsgijA/KNjwbDWa5B4v1lh1xO05NekW
# LxC5apTiaGZqI2DHw3gtDJOym9UMWIMJcHOKTg1tt97RypNb1YdzZ173UNaht+o8
# JqehggIwMIICLAYJKoZIhvcNAQkGMYICHTCCAhkCAQEwgYYwcjELMAkGA1UEBhMC
# VVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQd3d3LmRpZ2ljZXJ0
# LmNvbTExMC8GA1UEAxMoRGlnaUNlcnQgU0hBMiBBc3N1cmVkIElEIFRpbWVzdGFt
# cGluZyBDQQIQDUJK4L46iP9gQCHOFADw3TANBglghkgBZQMEAgEFAKBpMBgGCSqG
# SIb3DQEJAzELBgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTIxMDcxMjA4MDYy
# NVowLwYJKoZIhvcNAQkEMSIEIA/z6vriFT6VDFEZ1dmtWQQ56ZOozP3d8JCoogYU
# w/yPMA0GCSqGSIb3DQEBAQUABIIBALgM6a56niekRQZK7zAlnLljc/t+Urh94HqK
# O6hiVPpeS2CO9LO2i+BElvtQ1zw487E9abE1f9/dJMH33iCZLtaOJT5rk7UxmB5a
# lB2HeBd21nYQvCJNg7bCc6f05UVaRZX1AB6cygPbEmNTq/jkQeTh788fhjdYVbQA
# RwTstwYu6uY8qiAUnzbQRhfpGFs1W5YP4RWDuFO1vU0sHy+wp8y9+22koJ5JFoxv
# DcJ8ezexY+iFVAQJ9uo3KdycHzmsB++d+rpDQgFqvI0r6jXpVY4UIuvqMJjxFrel
# ue9B+iEBpBBud6JCUBhSua3vQTfniISvHNNnYXZ+LACp1yeMovY=
# SIG # End signature block
