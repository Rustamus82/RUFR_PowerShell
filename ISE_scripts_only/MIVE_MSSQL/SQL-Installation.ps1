# udførende jobnavn: giver variable disk, sti, fil Kan ikke køres i include fil, da det vil være denne include fil der registreres
$EgoCmd=$PSCommandPath -Split("\\")     # $EgoCmd= 'm:','ps1','SQL-Installation.ps1'
$Egodisk=$EgoCmd[0]
$Egofil=$EgoCmd[-1]
If($EgoCmd.Count -lt 3){$Egosti=''}elseif($EgoCmd.Count -eq 3){$Egosti=$EgoCmd[1]}else{$EgoCmd1=$EgoCmd[1..($EgoCmd.Count-2)];$Egosti=$EgoCmd1 -join("\")}
# Function module File to include
#$FincPath="p:\sqldba\ps1\u\inclFunc.ps1"
$FincPath="\\s-inf-fil-05-p.ssi.ad\pvl\INSTALL\miveps1\u\inclFunc.ps1"
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
    Write-Output "Du skal være logget på som Administrator for at installere SQL Server"
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

#$EgoShort = $EgoServer
#If ($EgoShort.Length -gt $EgoDomainbs.length){If ($EgoShort -match $EgoDomainbs){$EgoShort=$EgoShort -Replace($EgoDomainbs,"")}}   
#If ($EgoShort.Length -gt 5){If ($EgoShort -match "\$"){$EgoShort=$EgoShort -Replace("\$","")}}   
#If ($EgoShort.Length -gt 8){If ($EgoShort -match "svd_sqle"){$EgoShort=$EgoShort -Replace("svd_sqle","")}}   
#If ($EgoShort.Length -gt 5){If ($EgoShort -match "mssql"){$EgoShort=$EgoShort -Replace("mssql","")}}   
#If ($EgoShort.Length -gt 5){If ($EgoShort -match "sql"){$EgoShort=$EgoShort -Replace("sql","")}}   
#If ($EgoShort.Length -gt 5){If ($EgoShort -match "db"){$EgoShort=$EgoShort -Replace("db","")}}   
#If ($EgoShort.Substring(0,2) -eq "s-"){$EgoShort=$EgoShort.Substring(2,$EgoShort.length-2)}
#$EgoShort=$EgoShort -Replace("-","")

$pm=@{}
Function Reset-Parm{
	Write-Host "Param fil Oprettes"
	$Pm.WinVer=$EgoWin
	$Pm.SqlServer=$EgoServer
	$Pm.SqlDomain=$EgoDomain
	$Pm.SqlShort=$EgoShort
	$Pm.Sqlsa="svd_sqlsa_"+$EgoShort
	$Pm.Sqlsapw=Get-Rndpw 16
	$Pm.SqlInstance=""
	$Pm.SqlInstFeat=""
	$Pm.SqlEdition=""
	If($EgoCore -eq "Server") {$Pm.Guimode="gui"}Else{$Pm.Guimode="core"}
	$Pm.SqlVer=""
	[int]$Pm.Step=0
	$Pm.Argl=""
}


if(test-Path $FSpath\$FSparm){
Write-Host "Param fil findes"
$pm=Import-Clixml -Path $FSpath\$FSparm
}else{
	Reset-Parm
	$Pm|Export-Clixml -path $FSpath\$FSparm
}

#$Doma="DKSUND.DK","SSI.AD","SST.DK","Ikke Valgt","intdmz.dk","pubdmz.dk","ssidmz01.local","imkit.dk","nsidsdn.dk","DKSUNDTEST.DK"

If (!($Pm.SqlDomain -in $EgoAd)){Write-Error "Forkert Domain navn: {0} angivet, Farvel" -f $Pm.SqlDomain;exit}

If($Pm.SqlInstance -eq ""){
	$svar=Read-Host "Skal der installeres default instance MSSQLSERVER, tryk Enter, ellers skriv instans Navn"
	If ($svar.length -gt 0){$Pm.SqlInstance=$svar}else{$Pm.SqlInstance="MSSQLSERVER"}
	$Pm|Export-Clixml -path $FSpath\$FSparm
}
If($Pm.SqlEdition -eq ""){
	$svar=Read-Host "Skal der installeres Standard SQL, tryk Enter, ellers skriv Developer/Enterprise for Developer eller Enterprise version"
	If (!($svar.length -gt 0)){$Pm.SqlEdition="Standard"}Else{
	If($svar.Substring(0,1) -eq "e"){$Pm.SqlEdition="Enterprise"}
	ElseIf($svar.Substring(0,1) -eq "d"){$Pm.SqlEdition="Developer"}
	}
	$Pm|Export-Clixml -path $FSpath\$FSparm
}
If($Pm.SqlVer -eq ""){
	$svar=Read-Host "Skal der installeres SQL Server 2019, tryk Enter, ellers skriv 2016 for SQL Server 2016"
	If (!($svar.length -gt 0)){$Pm.SqlVer="2019"}Else{If($svar.Substring(0,4) -eq "2014"){$Pm.SqlVer="2014"}else{$Pm.SqlVer="2016"}}
	$Pm|Export-Clixml -path $FSpath\$FSparm
}
If($Pm.SqlInstFeat -eq ""){
	#$Pm.SqlInstFeat="SQL"
	$svar=Read-Host "Skriv r for installation af SQL r-Services, ellers tryk Enter for ingen r-Services"
	If ($svar.length -gt 0){If($svar.Substring(0,1) -eq "r"){$Pm.SqlInstFeat+=" r"}}
	
	$svar=Read-Host "Skriv i for installation af SQL SSIS, ellers tryk Enter for ingen SSIS"
	If ($svar.length -gt 0){
		If($svar.Substring(0,1) -eq "i"){$Pm.SqlInstFeat+=" i"}
		If($svar.Substring(0,1) -eq "j"){$Pm.SqlInstFeat+=" j"}
		If($svar.Substring(0,1) -eq "k"){$Pm.SqlInstFeat+=" k"}
	}
	
	$svar=Read-Host "Skriv a for installation af SQL SSAS, ellers tryk Enter for ingen SSAS"
	If ($svar.length -gt 0){
		If($svar.Substring(0,1) -eq "a"){$Pm.SqlInstFeat+=" a"}
	}
	
	$svar=Read-Host "Skriv r for installation af SQL Reporting Services, ellers tryk Enter for ingen SSRS"
	If ($svar.length -gt 0){If($svar.Substring(0,1) -in "u","r","j","y"){$Pm.SqlInstFeat+=" u"}}
	
	#$svar=Read-Host "Skriv f for installation af SQL Full-Text services, ellers tryk Enter for ingen Full-Text"
	#If ($svar.length -gt 0){If($svar.Substring(0,1) -eq "f"){$Pm.SqlInstFeat+=" f"}}
	
	$Pm|Export-Clixml -path $FSpath\$FSparm
}
$Pm
do{
	$svar=Read-Host "Ser parametrene fine ud? (Ja/Nej/Reset)"
	
	If ($svar -in 'ja','j','J','y','Y') {write-host "Fint!";$svar = "ja"
	} elseIf ($svar -in 'Reset','r','R') {
		Reset-Parm
		$Pm|Export-Clixml -path $FSpath\$FSparm
		write-host "ok, Resetter param , og slutter , Kør igen!";exit
	} elseIf ($svar -in 'Nej','n','N','no') {
		write-host "ok, Slutter uden at Resette param , Kør igen!";exit
	}
} until ($svar -eq "ja")

Write-Host "Installations Proceduren er nået til trin: " $Pm.Step 
Write-Host "Tryk x for at afslutte her efter Parameter filen er opdateret, uden at installere yderligere!"  
$svar=Read-Host "Angiv andet trin-nr der skal fortsættes med, eller tryk Enter for at fortsætte med dette trin " $Pm.Step
If ($svar.length -gt 0){If($svar -match "x"){exit}elseIf(is-num $svar){[int]$Pm.Step=$svar}
	$Pm|Export-Clixml -path $FSpath\$FSparm
}

#$Step=$Pm.Step
$SQLdomain=$Pm.SqlDomain
$SQLsName=$Pm.SqlServer
$SQLsShortn=$Pm.SqlShort			# Max 7 char
$SQLsa=$Pm.Sqlsa						# Secret name for sa account
$SQLInstance=$Pm.SqlInstance		# Instance named or blank
$SQLInstFeat=$Pm.SqlInstFeat		# feature could be r (r-services), u (SSRS), a (SSAS), i (SSIS), j ,k or blank (kun engine)
$SQLsapw=$Pm.Sqlsapw
$SQLEdition=$Pm.SqlEdition			# Standard, Enterprise eller Developer
$gMSA="x"									# kan sættes til x hvis der bruges group Managed Service Accounts til de 2 næste.
$SQLengpw="U@%C5y@onE(8"		# SQL Engine pw ignoreres for gMSA
$SQLagntpw="p8rpv6dGln3)"			# SQL Agent pw ignoreres for gMSA
$Guimode=$Pm.Guimode				# Gui eller core eller quiet så man kan hjælpe med parametre
$SQLFeat="""SQL"
$SQLrAccpt=""
$SQLrcab=""
$winver=$Pm.WinVer
$SQLver=$Pm.SqlVer
		
$SQLInstFeat = $SQLInstFeat.ToLower() 

# Param Check:
If ($SQLEdition.Substring(0,1) -in 'e','E','s','S','d','D') {}else{Write-Error "Forkert SQL Version: $SQLEdition Angiv venligst Standard, Developer eller Enterprise, Farvel";exit}
If ($SQLsShortn.Length -gt 7){
    $wr= "SQLsShortn parameteren: ""$SQLsShortn"" er for lang ( {0} ), max 7 Char." -f $SQLsShortn.length
    Write-Error $wr
	exit
}

If($Pm.SqlVer -eq "2014"){$SQLv="120"
}ElseIf($Pm.SqlVer -eq "2016"){$SQLv="130"
}ElseIf($Pm.SqlVer -eq "2017"){$SQLv="140"
}ElseIf($Pm.SqlVer -eq "2019"){$SQLv="150"
}
$sqlv2=$sqlv.SubString(0,2)

#	$ArgL=[Ordered]@{
	$ArgL=@{
		ACTION="Install" 
		#AGTSVCACCOUNT="NT Service\SQLSERVERAGENT"
		AGTSVCSTARTUPTYPE="Automatic" 
		#ASBACKUPDIR=c:\MSSQL\AsBackup\ 
		#ASCONFIGDIR=c:\MSSQL\AsConfig\ 
		#ASDATADIR=c:\MSSQL\AsData\ 
		#ASLOGDIR=c:\MSSQL\AsLog\ 
		#ASTEMPDIR=c:\MSSQL\AsTemp\ 
		#ASSVCACCOUNT="NT Service\MSSQLServerOLAPService"
		#ASSVCSTARTUPTYPE="Automatic"
		#ASSYSADMINACCOUNTS=$EgoAda[$EgoAdNr]
		#ASPROVIDERMSOLAP=1
		BROWSERSVCSTARTUPTYPE="Automatic" 
		ENU="True"
		FEATURES="SQL" 
		IACCEPTSQLSERVERLICENSETERMS=1 
		INDICATEPROGRESS=1 
		INSTANCENAME="MSSQLSERVER" 
		#ISSVCACCOUNT="NT SERVICE\MSDTSSERVER$SQLv"
		#ISSVCStartupType="Automatic"
		#PID=$SQLEdition
		SAPWD=$Pm.Sqlsapw
		SECURITYMODE="SQL" 
		SQLBACKUPDIR="U:\System\MSSQL$sqlv2.MSSQLSERVER\MSSQL\Backup\"
		SQLCOLLATION="Danish_Norwegian_CI_AS"
		SQLSVCACCOUNT="$SQLdomain\svd_sqle$SQLsShortn$"
		SQLSVCSTARTUPTYPE="Automatic"
		SQLSVCINSTANTFILEINIT=1
		SQLSYSADMINACCOUNTS=$EgoAda[$EgoAdNr]
		SQLTEMPDBDIR="T:\System\MSSQL$sqlv2.MSSQLSERVER\MSSQL\TempDB\"
		SQLTEMPDBLOGDIR="T:\System\MSSQL$sqlv2.MSSQLSERVER\MSSQL\TempLog\"
		SQLTEMPDBFILESIZE=128 
		SQLTEMPDBFILEGROWTH=64 
		SQLTEMPDBLOGFILESIZE=64 
		SQLUSERDBDIR="R:\System\MSSQL$sqlv2.MSSQLSERVER\MSSQL\Data\"
		SQLUSERDBLOGDIR="S:\System\MSSQL$sqlv2.MSSQLSERVER\MSSQL\Log\"
		SUPPRESSPRIVACYSTATEMENTNOTICE=1 
		TCPENABLED=1 
	#	UIMODE="AutoAdvance" 
		UPDATEENABLED=1 
		USEMICROSOFTUPDATE=1
	}



$Gui=""
If ($Guimode -match "g") {
	$ArgL.UIMODE="AutoAdvance"
	$ArgL.FEATURES+=",Tools"
#	$ArgL.Qs="True"
}ElseIf ($Guimode -match "c") {
	$ArgL.UIMODE="EnableUIOnServerCore"
}else{
	$gui+="/qs "
	$ArgL.FEATURES+=",AdvancedAnalytics"
}

If ($SQLInstFeat -match "r") {
	$SqlrPath="c:\Install\Rcab"
	$ArgL.SqlrPath=$SqlrPath
	$ArgL.FEATURES+=",AdvancedAnalytics"
	$ArgL.IAcceptROpenLicenseTerms=1		
	$ArgL.MRCACHEDIRECTORY=$SqlrPath
}
If ($SQLInstFeat -match "i") {
	#$ArgL.ISSVCACCOUNT="NT Service\MsDtsServer150"  
	$ArgL.ISSVCStartupType="Automatic"
	$ArgL.FEATURES+=",IS"
}
If ($SQLInstFeat -match "a") {
	$ArgL.ASDATADIR="R:\System\MSSAS$sqlv2.MSSQLSERVER\MSSQL\"
	$ArgL.ASLOGDIR="S:\System\MSSAS$sqlv2.MSSQLSERVER\MSSQL\"
	$ArgL.ASTEMPDIR="T:\System\MSSAS$sqlv2.MSSQLSERVER\MSSQL\"
	$ArgL.ASBACKUPDIR="U:\System\MSSAS$sqlv2.MSSQLSERVER\MSSQL\Data\"
	$ArgL.ASCONFIGDIR="R:\System\MSSAS$sqlv2.MSSQLSERVER\MSSQL\Cfg"
	$ArgL.ASSERVERMODE="MULTIDIMENSIONAL"
	#$ArgL.ASSVCACCOUNT="NT Service\MSSQLServerOLAPService"
	$ArgL.ASSVCSTARTUPTYPE="Automatic"
	$ArgL.ASSYSADMINACCOUNTS=$EgoAda[$EgoAdNr]
	$ArgL.ASPROVIDERMSOLAP=1
	$ArgL.FEATURES+=",AS"
}
If ($SQLInstFeat -match "u") {
	$ArgL.RSINSTALLMODE="DefaultNativeMode"
	$ArgL.RSSVCACCOUNT="$SQLdomain\svd_ssrs$SQLsShortn$"  # kun ved brug af Rapportserver på anden server end SQL Engine
	$ArgL.RSSVCStartupType="Automatic"
	$ArgL.FEATURES+=",RS"
}
#If ($SQLInstFeat -match "f") {
#	$SQLrAccpt+=" /FTSVCACCOUNT='NT Service\MSSQLFDLauncher'"
#	$SQLFeat+=", Full-Text"
#}
$SQLFeat+=""""

#$SQLdomNYdba=('dksund.dk','dksundtest.dk','ssidmz01.local')
#$SQLdbaGrp=$SQLdomain.ToLower()
#$SQLdbaGrp+="\"
#if ($SQLdomNYdba -match $SQLdomain.ToLower()) {
#	$SQLdbaGrp+='l-org-mssql-sysadmin'
#} else { 		# dom= ssi, sst
#	$SQLdbaGrp+='MSSQLServerAdms'
#}

$SqlPath="P:\MSSQL\SQL$SQLver"
$SQLlog="C:\Program Files\Microsoft SQL Server\$SQLv\Setup Bootstrap\log" 

If ($SQLEdition.Substring(0,1) -eq 'E') {
	$SqlPath+="_Ent"
}ElseIf ($SQLEdition.Substring(0,1) -eq 'D') {
	$SqlPath+="_Devl"
}ElseIf ($SQLEdition.Substring(0,1) -eq 's') {
	$SqlPath+="_Std"
}
#	If($SQLver -eq "2016"){
#		$SQLlog="C:\Program Files\Microsoft SQL Server\$SQLv\Setup Bootstrap\log" 
#		$SqlIso="SW_DVD9_NTRL_SQL_Svr_Ent_Core_2016w_SP2_64Bit_English_OEM_VL_X21-59533.ISO"
#	}ElseIf($SQLver -eq "2019"){
#		$SQLlog="C:\Program Files\Microsoft SQL Server\$SQLv\Setup Bootstrap\log"
#		$SqlIso="SW_DVD9_SQL_Svr_Enterprise_Edtn_2019Nov2019_64Bit_English_MLF_X22-18972.ISO"
#	}
#}else{	# std
#	$SqlPath="P:\MSSQL\SQL$SQLver"
#	$SqlPath+="_Std"
#	If($SQLver -eq "2016"){
#		$SQLlog="C:\Program Files\Microsoft SQL Server\$SQLv\Setup Bootstrap\log"
#		$SqlIso="SW_DVD9_NTRL_SQL_Svr_Standard_Edtn_2016w_SP2_64Bit_English_OEM_VL_X21-59522.ISO"
#	}ElseIf($SQLver -eq "2019"){
#		$SQLlog="C:\Program Files\Microsoft SQL Server\$SQLv\Setup Bootstrap\log"
#		$SqlIso="SW_DVD9_NTRL_SQL_Svr_Standard_Edtn_2019Nov2019_64Bit_English_OEM_VL_X22-18928.ISO"
#	}
#}

$SqlIso=Get-ChildItem $SqlPath\*.iso
$SqlIson=$SqlIso.name



Write-host "Sql Installation step: " $Pm.Step

If ($Pm.Step -eq 0){ 

Write-host "Preparing gMSA, powershell & Kerberos"
Try{
    $rc=Get-WindowsFeature -Name *rsat-ad-powershell*
} Catch{
    If ($Error[0] -match("client-based")){
        write-host "RSAT Kan kun installeres på server, ikke på en arbejdsplads"
        Exit
    }
}
If ($rc.installed){Write-Host "AD modul er installeret:"
    $rc
} Else {
	Add-WindowsFeature -Name RSAT-AD-PowerShell
}
Write-Host "Volumes:"
Write-Host "disk opsætning / labling"
$DiskMan=0
$drev=Get-WmiObject -Class win32_volume
If($drev.name -notcontains 'c:\') {If($drev.label -notcontains 'System'){$DiskMan++}else{
$drive=Get-WmiObject -Class win32_volume -Filter "Label='System'"
$r=Set-WmiInstance -input $drive -Arguments @{DriveLetter="c:"; Label="System"}}
}Else{
$drive=Get-WmiObject -Class win32_volume -Filter "DriveLetter = 'c:'"
$r=Set-WmiInstance -input $drive -Arguments @{DriveLetter="c:"; Label="System"}
}

If($drev.name -notcontains 'r:\') {If($drev.label -notcontains 'SQLData'){$DiskMan++}else{
$drive=Get-WmiObject -Class win32_volume -Filter "Label='SQLData'"
$r=Set-WmiInstance -input $drive -Arguments @{DriveLetter="r:"; Label="SQLData"}}
}Else{
$drive=Get-WmiObject -Class win32_volume -Filter "DriveLetter = 'r:'"
$r=Set-WmiInstance -input $drive -Arguments @{DriveLetter="r:"; Label="SQLData"}
}

If($drev.name -notcontains 's:\') {If($drev.label -notcontains 'SQLLog'){$DiskMan++}else{
$drive=Get-WmiObject -Class win32_volume -Filter "Label='SQLLog'"
$r=Set-WmiInstance -input $drive -Arguments @{DriveLetter="s:"; Label="SQLLog"}}
}Else{
$drive=Get-WmiObject -Class win32_volume -Filter "DriveLetter = 's:'"
$r=Set-WmiInstance -input $drive -Arguments @{DriveLetter="s:"; Label="SQLLog"}
}

If($drev.name -notcontains 't:\') {If($drev.label -notcontains 'SQLTemp'){$DiskMan++}else{
$drive=Get-WmiObject -Class win32_volume -Filter "Label='SQLTemp'"
$r=Set-WmiInstance -input $drive -Arguments @{DriveLetter="t:"; Label="SQLTemp"}}
}Else{
$drive=Get-WmiObject -Class win32_volume -Filter "DriveLetter = 't:'"
$r=Set-WmiInstance -input $drive -Arguments @{DriveLetter="t:"; Label="SQLTemp"}
}

If($drev.name -notcontains 'u:\') {If($drev.label -notcontains 'SQLBackup'){$DiskMan++}else{
$drive=Get-WmiObject -Class win32_volume -Filter "Label='SQLBackup'"
$r=Set-WmiInstance -input $drive -Arguments @{DriveLetter="u:"; Label="SQLBackup"}}
}Else{
$drive=Get-WmiObject -Class win32_volume -Filter "DriveLetter = 'u:'"
$r=Set-WmiInstance -input $drive -Arguments @{DriveLetter="u:"; Label="SQLBackup"}
}

If($DiskMan -gt 0) {
Write-Host "Der er ikke angivet 5 diske: c,r,s,t,u med Labels: System, SQLData, SQLLog, SQLTemp, SQLBackup"
Write-Host "Dette skal nok gøres manuelt, f.eks ved kommandoerne:"
Write-Host "      # $drive=Get-WmiObject -Class win32_volume -Filter ""DriveLetter = 'c:'"""
Write-Host "eller # $drive=Get-WmiObject -Class win32_volume -Filter ""Label='System'"""
Write-Host "og   # $r=Set-WmiInstance -input $drive -Arguments @{DriveLetter=""c:""; Label=""System"""
Get-Volume|ft
Write-Host "Derefter fortsæt med Step=" $Pm.Step
Exit
}
Get-Volume |ft
Write-Host "Rigtige Drev-bogstaver sat til SQL Server."
$d0=("r:","s:","t:","u:")
foreach($d in $drev){if($d.Driveletter -in $d0){If($d.blocksize -lt 60000){
	Format-Volume -driveletter ($d.DriveLetter).Substring(0,1) -FileSystem NTFS -AllocationUnitSize 65536 -NewFileSystemLabel $d.Label -Confirm:$false
 }}}

$Rca=Get-WmiObject -Class Win32_Volume | Select DriveLetter, Label, BlockSize, DriveType,
    @{Label="DiskType";Expression={switch ($_.DriveType) {2 {"Removable"} 3 {"Fixed"} 5 {"CD-Rom"}}}},
    @{Label="FreeSpace (In GB)";Expression={"{0:#.##}" -f ($_.Freespace/1gb)}},
    @{Label="Capacity (In GB)";Expression={"{0:#.##}" -f ($_.Capacity/1gb)}}|Sort {$_.DriveLetter} |
    Format-Table -AutoSize
	Write-Output $Rca

$svar = " "
do{
	$svar=Read-Host "Alt OK, med step " $Pm.Step "fortsæt med næste Step? (ja/nej)"
	If ($svar -in 'ja','j','J','y','Y') {write-host "Fint!";$Pm.Step+=1;$svar = "ja"
	} elseIf ($svar -in 'Nej','n','N','no') {write-host "ok, slutter ved trin " $Pm.Step "Farvel!";break}
	} until ($svar -eq "ja")
}
$Pm|Export-Clixml -path $FSpath\$FSparm

set-location $Egodisk
set-location \$Egosti

If ($Pm.Step -eq 1){ 


set-location $Egodisk
cd \
if (test-path .\sqldba\*.*) {cd sqldba}
if (test-path ps1\*.*) {cd ps1}
if (test-path spn\*.*) {cd spn}
Write-Host " "
Write-Host "Find-SpnHost.ps1 <server>.<domain> svarer lidt til \u\sql-macro.ps1 spn (viser tilknyttede SetSPN adresser)"
$fqn=$SQLsName+"."+$SQLdomain
#get-location
#test-path Find-SpnHost.ps1
#$fqn
#
#Read-host "?"
#Start-Process -wait -FilePath .\Find-SpnHost.ps1 -ArgumentList $SQLsName+"."+$SQLdomain
.\Find-SpnHost.ps1 $fqn
Write-Host " "
Write-Host "laver .log dokument, med klargjorte powershell kommandoer til at oprette group ManagedServiceAccounts til SQL Server"
#Start-Process -wait -FilePath p:\sqldba\ps1\spn\chk-gMSA.ps1 -ArgumentList "-SnameFqdn $SQLsName"".""$SQLdomain -shortname $SQLsShortn -Instance $SQLInstance"
.\chk-gMSA.ps1 -SnameFqdn $fqn -shortname $SQLsShortn -Instance $SQLInstance
Write-Host " "
copy p:\sqldba\ps1\spn\chk-gMSA.log $FSpath
Write-Host
Write-Host "Opret Secret password i dbservicekonti:"

Write-Host $SQLsa"."$SQLdomain
Write-Host "SQL sa user for Default SQL Instance on" $SQLsName"."$SQLdomain
Write-Host "Volumes:"

#write-Host "Flg kræver kør som administrator"
#Write-Host FSUTIL.exe 8dot3name query C:.

#Get-Volume |ft
$svar = " "
do{
	$svar=Read-Host "Alt OK, med step " $Pm.Step "fortsæt med næste Step? (ja/nej)"
	If ($svar -in 'ja','j','J','y','Y') {write-host "Fint!";$Pm.Step+=1;$svar = "ja"
	} elseIf ($svar -in 'Nej','n','N','no') {write-host "ok, slutter ved trin " $Pm.Step " Farvel!";break}
	} until ($svar -eq "ja")
}
	$Pm|Export-Clixml -path $FSpath\$FSparm

set-location $Egodisk
set-location \$Egosti

#If ($Pm.Step -eq 2){ 

#Write-Host "disk opsætning / labling"
#$drive=Get-WmiObject -Class win32_volume -Filter "DriveLetter = 'c:'"
#$r=Set-WmiInstance -input $drive -Arguments @{DriveLetter="c:"; Label="System"}
#$drive=Get-WmiObject -Class win32_volume -Filter "DriveLetter = 'r:'"
#$r=Set-WmiInstance -input $drive -Arguments @{DriveLetter="r:"; Label="SQLData"}
#$drive=Get-WmiObject -Class win32_volume -Filter "DriveLetter = 's:'"
#$r=Set-WmiInstance -input $drive -Arguments @{DriveLetter="s:"; Label="SQLLog"}
#$drive=Get-WmiObject -Class win32_volume -Filter "DriveLetter = 't:'"
#$r=Set-WmiInstance -input $drive -Arguments @{DriveLetter="t:"; Label="SQLTemp"}
#$drive=Get-WmiObject -Class win32_volume -Filter "DriveLetter = 'u:'"
#$r=Set-WmiInstance -input $drive -Arguments @{DriveLetter="u:"; Label="SQLBackup"}

#Get-Volume |ft
# fsutil.exe behavior set disable8dot3 0 	# for at enable 8.3 navngivning (krævet af r.)
#$svar = " "
#do{
#	$svar=Read-Host "Alt OK, med step "$Pm.Step "fortsæt med næste Step? (ja/nej)"
#	If ($svar -in 'ja','j','J','y','Y') {write-host "Fint!";$Pm.Step+=1;$svar = "ja"
#	} elseIf ($svar -in 'Nej','n','N','no') {write-host "ok, slutter ved trin "$Pm.Step", Farvel!";break}
#	} until ($svar -eq "ja")
#}
#	$Pm|Export-Clixml -path $FSpath\$FSparm
#
#set-location $Egodisk
#set-location \$Egosti


If ($Pm.Step -eq 2){ 
	Write-host "SQL Installation media mount"
	if (test-path p:\sqldba) {}else{net use p: \\TSCLIENT\P}
	if (test-path c:\Install) {}else{md c:\Install}
	
	If ($SQLInstFeat -match "r") {
		if (test-path $SqlrPath) {}else {
			md $SqlrPath
			If($SQLver -eq "2016"){
				copy P:\MSSQL\MSSQL2016Rcab\*.* $SqlrPath
			}ElseIf($SQLver -eq "2019"){copy P:\MSSQL\MSSQL2019Rcab\*.* $SqlrPath
			}
		Write-Host "Kopieret"
		}
	}

#	if (test-path c:\Install\$SqlIso) {}else{copy $SqlPath\$SqlIso c:\install;Write-Host "ISO Kopieret"}
	if (test-path c:\Install\$SqlIson) {}else{copy $SqlPath\$SqlIson c:\install;Write-Host "ISO Kopieret"}
	Write-Host "Mounting . . . "
	$mountResult=Mount-DiskImage -passthru -ImagePath c:\install\$SqlIson

	$driveLetter = ($mountResult | Get-Volume).DriveLetter
	$d=$driveLetter
	$d+=":"
	write-Host "Mounted: " $d
	Get-Childitem $d |ft
$svar = " "
do{
	$svar=Read-Host "Alt OK, med step "$Pm.Step "fortsæt med næste Step? (ja/nej)"
	If ($svar -in 'ja','j','J','y','Y') {write-host "Fint!";$Pm.Step+=1;$svar = "ja"
	} elseIf ($svar -in 'Nej','n','N','no') {write-host "ok, slutter ved trin "$Pm.Step", Farvel!";break}
	} until ($svar -eq "ja")
}
	$Pm|Export-Clixml -path $FSpath\$FSparm
set-location $Egodisk
set-location \$Egosti


If ($Pm.Step -eq 3){

Write-Host "Udfør Kerberos - SetSpn:"
# Define Svd_sqle, svd_sqla, \l-org-mssql-sysadmin,\g-org-mssql-sysadmin,\l-org-mssql-AdmWinOS,\g-org-mssql-AdmWinOS
# Add secret: Svd_sqle, svd_sqla, sa
#setspn -L $SQLdomain"\"$SQLsName
#setspn -L $SQLdomain\svd_sqle$SQLsShortn

setspn -L $SQLdomain"\"$SQLsName
setspn -L $SQLdomain\svd_sqle$SQLsShortn
#If ($SQLInstFeat -match "a") {setspn -L $SQLdomain\svd_ssas$SQLsShortn}
If ($SQLInstFeat -match "i") {setspn -L $SQLdomain\svd_ssis$SQLsShortn}
If ($SQLInstFeat -match "u") {setspn -L $SQLdomain\svd_ssrs$SQLsShortn}

Get-FirewallRule | where { $_.LocalPorts -in 80,135,443,1433,1434,2283,2382} | Format-Table Name,Localports,Enabled,Direction


$svar = " "
do{
	$svar=Read-Host "Alt OK, med step "$Pm.Step" fortsæt med næste Step? (ja/nej)"
	If ($svar -in 'ja','j','J','y','Y') {write-host "Fint!";$Pm.Step+=1;$svar = "ja"
	} elseIf ($svar -in 'Nej','n','N','no') {write-host "ok, slutter ved trin "$Pm.Step", Farvel!";break}
	} until ($svar -eq "ja")
}
	$Pm|Export-Clixml -path $FSpath\$FSparm
set-location $Egodisk
set-location \$Egosti


If ($Pm.Step -eq 4){ 

Write-host "Klar til SQL Installation "
if(test-path d:\SqlSetupBoot*.*) {$cd='d:'} 
Elseif(test-path e:\SqlSetupBoot*.*) {$cd='e:'} 
Elseif(test-path f:\SqlSetupBoot*.*) {$cd='f:'} 
Else {Write-host "SQL installation cd not in d, e, f,   MAKE it so!!"
	Exit
}
Write-Host "SqlSetupBoot* (sql cd) fundet på drev: $cd "
set-location $cd
if(test-path .\Setup.exe) {
# .\setup.exe /?       for at se parametre
## no report server on core!!!
# arjo forslag:  /SQLTEMPDBFILECOUNT=4 default 8
# arjo forslag: /SQLTEMPDBLOGFILEGROWTH=32 default 64

If ($SQLInstance.length -lt 1) {$SQLInstance='MSSQLSERVER'}

#$ArgL="$gui /ACTION=Install /FEATURES=$SQLFeat /INSTANCENAME=$SQLInstance /SUPPRESSPRIVACYSTATEMENTNOTICE=1 /INDICATEPROGRESS=1 $SQLrAccpt $SQLrcab /SQLSVCACCOUNT=$SQLdomain\svd_sqle$SQLsShortn$ /SQLSVCSTARTUPTYPE=Automatic /AGTSVCACCOUNT=$SQLdomain\svd_sqla$SQLsShortn$ /AGTSVCSTARTUPTYPE=Automatic /BROWSERSVCSTARTUPTYPE=Automatic /SQLSYSADMINACCOUNTS=$SQLdbaGrp /TCPENABLED=1 /IACCEPTSQLSERVERLICENSETERMS=1 /UPDATEENABLED=1 /SECURITYMODE=SQL /SAPWD=""$SQLsapw"" /SQLTEMPDBDIR=T:\System\MSSQL$sqlv2.MSSQLSERVER\MSSQL\TempDB\ /SQLTEMPDBLOGDIR=T:\System\MSSQL$sqlv2.MSSQLSERVER\MSSQL\TempLog\ /SQLTEMPDBFILESIZE=128 /SQLTEMPDBFILEGROWTH=64 /SQLTEMPDBLOGFILESIZE=64 /SQLUSERDBDIR=R:\System\MSSQL$sqlv2.MSSQLSERVER\MSSQL\Data\ /SQLUSERDBLOGDIR=S:\System\MSSQL$sqlv2.MSSQLSERVER\MSSQL\Log\ /SQLBACKUPDIR=U:\System\MSSQL$sqlv2.MSSQLSERVER\MSSQL\Backup\ /SQLCOLLATION=Danish_Norwegian_CI_AS"
#$ArgL="$gui /ACTION=Install /FEATURES=$SQLFeat /INSTANCENAME=$SQLInstance /SUPPRESSPRIVACYSTATEMENTNOTICE=1 /INDICATEPROGRESS=1 $SQLrAccpt $SQLrcab /SQLSVCACCOUNT=$SQLdomain\svd_sqle$SQLsShortn$ /SQLSVCSTARTUPTYPE=Automatic /AGTSVCACCOUNT=""NT SERVICE\SQLSERVERAGENT"" /AGTSVCSTARTUPTYPE=Automatic /BROWSERSVCSTARTUPTYPE=Automatic /SQLSYSADMINACCOUNTS=$SQLdbaGrp /TCPENABLED=1 /IACCEPTSQLSERVERLICENSETERMS=1 /UPDATEENABLED=1 /SECURITYMODE=SQL /SAPWD=""$SQLsapw"" /SQLTEMPDBDIR=T:\System\MSSQL$sqlv2.MSSQLSERVER\MSSQL\TempDB\ /SQLTEMPDBLOGDIR=T:\System\MSSQL$sqlv2.MSSQLSERVER\MSSQL\TempLog\ /SQLTEMPDBFILESIZE=128 /SQLTEMPDBFILEGROWTH=64 /SQLTEMPDBLOGFILESIZE=64 /SQLUSERDBDIR=R:\System\MSSQL$sqlv2.MSSQLSERVER\MSSQL\Data\ /SQLUSERDBLOGDIR=S:\System\MSSQL$sqlv2.MSSQLSERVER\MSSQL\Log\ /SQLBACKUPDIR=U:\System\MSSQL$sqlv2.MSSQLSERVER\MSSQL\Backup\ /SQLCOLLATION=Danish_Norwegian_CI_AS"
#$ArgL="$gui /ACTION=Install /FEATURES=$SQLFeat /INSTANCENAME=$SQLInstance /SUPPRESSPRIVACYSTATEMENTNOTICE=1 /INDICATEPROGRESS=1 $SQLrAccpt $SQLrcab /SQLSVCACCOUNT=$SQLdomain\svd_sqle$SQLsShortn$ /SQLSVCSTARTUPTYPE=Automatic /AGTSVCACCOUNT=""Local System"" /AGTSVCSTARTUPTYPE=Automatic /BROWSERSVCSTARTUPTYPE=Automatic /SQLSYSADMINACCOUNTS=$SQLdbaGrp /TCPENABLED=1 /IACCEPTSQLSERVERLICENSETERMS=1 /UPDATEENABLED=1 /SECURITYMODE=SQL /SAPWD=""$SQLsapw"" /SQLTEMPDBDIR=T:\System\MSSQL$sqlv2.MSSQLSERVER\MSSQL\TempDB\ /SQLTEMPDBLOGDIR=T:\System\MSSQL$sqlv2.MSSQLSERVER\MSSQL\TempLog\ /SQLTEMPDBFILESIZE=128 /SQLTEMPDBFILEGROWTH=64 /SQLTEMPDBLOGFILESIZE=64 /SQLUSERDBDIR=R:\System\MSSQL$sqlv2.MSSQLSERVER\MSSQL\Data\ /SQLUSERDBLOGDIR=S:\System\MSSQL$sqlv2.MSSQLSERVER\MSSQL\Log\ /SQLBACKUPDIR=U:\System\MSSQL$sqlv2.MSSQLSERVER\MSSQL\Backup\ /SQLCOLLATION=Danish_Norwegian_CI_AS"
#$ArgL="$gui /ACTION=Install /FEATURES=$SQLFeat /INSTANCENAME=$SQLInstance /SUPPRESSPRIVACYSTATEMENTNOTICE=1 /INDICATEPROGRESS=1 $SQLrAccpt $SQLrcab /SQLSVCACCOUNT=$SQLdomain\svd_sqle$SQLsShortn$ /SQLSVCSTARTUPTYPE=Automatic /AGTSVCACCOUNT=""NT AUTHORITY\LOCAL SERVICE"" /AGTSVCSTARTUPTYPE=Automatic /BROWSERSVCSTARTUPTYPE=Automatic /SQLSYSADMINACCOUNTS=$SQLdbaGrp /TCPENABLED=1 /IACCEPTSQLSERVERLICENSETERMS=1 /UPDATEENABLED=1 /SECURITYMODE=SQL /SAPWD=""$SQLsapw"" /SQLTEMPDBDIR=T:\System\MSSQL$sqlv2.MSSQLSERVER\MSSQL\TempDB\ /SQLTEMPDBLOGDIR=T:\System\MSSQL$sqlv2.MSSQLSERVER\MSSQL\TempLog\ /SQLTEMPDBFILESIZE=128 /SQLTEMPDBFILEGROWTH=64 /SQLTEMPDBLOGFILESIZE=64 /SQLUSERDBDIR=R:\System\MSSQL$sqlv2.MSSQLSERVER\MSSQL\Data\ /SQLUSERDBLOGDIR=S:\System\MSSQL$sqlv2.MSSQLSERVER\MSSQL\Log\ /SQLBACKUPDIR=U:\System\MSSQL$sqlv2.MSSQLSERVER\MSSQL\Backup\ /SQLCOLLATION=Danish_Norwegian_CI_AS"
#$ArgL="$gui /ACTION=Install /FEATURES=$SQLFeat /INSTANCENAME=$SQLInstance /SUPPRESSPRIVACYSTATEMENTNOTICE=1 /INDICATEPROGRESS=1 $SQLrAccpt $SQLrcab /SQLSVCACCOUNT=$SQLdomain\svd_sqle$SQLsShortn$ /SQLSVCSTARTUPTYPE=Automatic /AGTSVCSTARTUPTYPE=Automatic /BROWSERSVCSTARTUPTYPE=Automatic /SQLSYSADMINACCOUNTS=$SQLdbaGrp /TCPENABLED=1 /IACCEPTSQLSERVERLICENSETERMS=1 /UPDATEENABLED=1 /SECURITYMODE=SQL /SAPWD=""$SQLsapw"" /SQLTEMPDBDIR=T:\System\MSSQL$sqlv2.MSSQLSERVER\MSSQL\TempDB\ /SQLTEMPDBLOGDIR=T:\System\MSSQL$sqlv2.MSSQLSERVER\MSSQL\TempLog\ /SQLTEMPDBFILESIZE=128 /SQLTEMPDBFILEGROWTH=64 /SQLTEMPDBLOGFILESIZE=64 /SQLUSERDBDIR=R:\System\MSSQL$sqlv2.MSSQLSERVER\MSSQL\Data\ /SQLUSERDBLOGDIR=S:\System\MSSQL$sqlv2.MSSQLSERVER\MSSQL\Log\ /SQLBACKUPDIR=U:\System\MSSQL$sqlv2.MSSQLSERVER\MSSQL\Backup\ /SQLCOLLATION=Danish_Norwegian_CI_AS"
Write-Host "Installation med Param: $ArgL"

$Pm.Argl=$ArgL
$Pm|Export-Clixml -path $FSpath\$FSparm

# der checkes om der bruges group Managed Service Accounts.
If ($gMSA.length -lt 1) {Write-Host " ikke gMSA!"    #(skal samles til 1 linie

##Start-Process -wait -FilePath .\Setup.exe -ArgumentList "$gui /ACTION=Install /FEATURES=$SQLFeat $SQLrAccpt $SQLrcab /INSTANCENAME=$SQLInstance /SUPPRESSPRIVACYSTATEMENTNOTICE=1 /INDICATEPROGRESS=1 /SQLSVCACCOUNT=$SQLdomain\svd_sqle$SQLsShortn /SQLSVCPASSWORD=""$SQLengpw"" /SQLSVCSTARTUPTYPE=Automatic /AGTSVCACCOUNT=$SQLdomain\svd_sqla$SQLsShortn /AGTSVCPASSWORD=""$SQLagntpw"" /AGTSVCSTARTUPTYPE=Automatic /BROWSERSVCSTARTUPTYPE=Automatic /SQLSYSADMINACCOUNTS=$SQLdbaGrp /TCPENABLED=1 /IACCEPTSQLSERVERLICENSETERMS=1 /UPDATEENABLED=1 /SECURITYMODE=SQL /SAPWD=""$SQLsapw"" /SQLTEMPDBDIR=""T:\System\MSSQL$sqlv2.MSSQLSERVER\MSSQL\TempDB\"" /SQLTEMPDBLOGDIR=""T:\System\MSSQL$sqlv2.MSSQLSERVER\MSSQL\TempLog\"" /SQLTEMPDBFILESIZE=128 /SQLTEMPDBFILEGROWTH=64 /SQLTEMPDBLOGFILESIZE=64 /SQLUSERDBDIR=""R:\System\MSSQL$sqlv2.MSSQLSERVER\MSSQL\log\"" /SQLUSERDBLOGDIR='S:\System\MSSQL$sqlv2.MSSQLSERVER\MSSQL\Log\' /SQLBACKUPDIR='U:\System\MSSQL$sqlv2.MSSQLSERVER\MSSQL\Backup\' /SQLCOLLATION=Danish_Norwegian_CI_AS"
#Start-Process -wait -FilePath .\Setup.exe -ArgumentList "$gui /ACTION=Install /FEATURES=$SQLFeat $SQLrAccpt $SQLrcab /INSTANCENAME=$SQLInstance /SUPPRESSPRIVACYSTATEMENTNOTICE=1 /INDICATEPROGRESS=1 /SQLSVCACCOUNT=$SQLdomain\svd_sqle$SQLsShortn /SQLSVCPASSWORD=""$SQLengpw"" /SQLSVCSTARTUPTYPE=Automatic /AGTSVCACCOUNT=""Local System"" /AGTSVCSTARTUPTYPE=Automatic /BROWSERSVCSTARTUPTYPE=Automatic /SQLSYSADMINACCOUNTS=$SQLdbaGrp /TCPENABLED=1 /IACCEPTSQLSERVERLICENSETERMS=1 /UPDATEENABLED=1 /SECURITYMODE=SQL /SAPWD=""$SQLsapw"" /SQLTEMPDBDIR=""T:\System\MSSQL$sqlv2.MSSQLSERVER\MSSQL\TempDB\"" /SQLTEMPDBLOGDIR=""T:\System\MSSQL$sqlv2.MSSQLSERVER\MSSQL\TempLog\"" /SQLTEMPDBFILESIZE=128 /SQLTEMPDBFILEGROWTH=64 /SQLTEMPDBLOGFILESIZE=64 /SQLUSERDBDIR=""R:\System\MSSQL$sqlv2.MSSQLSERVER\MSSQL\log\"" /SQLUSERDBLOGDIR='S:\System\MSSQL$sqlv2.MSSQLSERVER\MSSQL\Log\' /SQLBACKUPDIR='U:\System\MSSQL$sqlv2.MSSQLSERVER\MSSQL\Backup\' /SQLCOLLATION=Danish_Norwegian_CI_AS"
Start-Process -wait -FilePath .\Setup.exe -ArgumentList $Argl $gui 
}
else {Write-Host " gMSA!"    # (skal samles til 1 linie
$al=$gui 
Write-Output $gui 
foreach($key in $ArgL.keys){
    $message = 'Param {0} har værdien {1} ' -f $key, $ArgL[$key]
	If(($key -eq 'SAPWD') -or ($ArgL[$key] -match(" "))){
    $al+= "/{0}='{1}' " -f $key, $ArgL[$key]
	}else{
    $al+= "/{0}={1} " -f $key, $ArgL[$key]	}
   # Write-Output $message
}
#write-output $al

#Start-Process -wait -FilePath .\Setup.exe -ArgumentList $ArgL $gui
#Start-Process -wait -FilePath .\Setup.exe $gui $ArgL 
Start-Process -wait -FilePath .\Setup.exe -ArgumentList $aL 




}

}Else {Write-Host "Setup.exe ikke fundet på $cd"}
$svar=read-host "Alt ok?"
If ($svar -eq 'ja') {write-host "Fint!"} elseIf ($svar -eq 'nej') {write-host "Øv!"}
get-service *sql*
$svar = " "
do{
	$svar=Read-Host "Alt OK, med step "$Pm.Step" fortsæt med næste Step? (ja/nej)"
	If ($svar -in 'ja','j','J','y','Y') {write-host "Fint!";$Pm.Step+=1;$svar = "ja"
	} elseIf ($svar -in 'Nej','n','N','no') {write-host "ok, slutter ved trin "$Pm.Step", Farvel!";break}
	} until ($svar -eq "ja")
}
	$Pm|Export-Clixml -path $FSpath\$FSparm
set-location $Egodisk
set-location \$Egosti

If ($Pm.Step -eq 5){ 


#start-Service mssqlserver
#start-Service SQLSERVERAGENT
#start-Service SQLBrowser


#z:\ps1\u\disk-size.ps1
#r: 
#ls -r |ft
#s:
#ls -r |ft
#t:
#ls -r |ft
#u:
#ls -r |ft


#netsh advfirewall firewall show rule name=all  
#netsh advfirewall firewall show rule name="SQL Server"
#netsh advfirewall firewall show rule name="SQL Browser" 
#netsh advfirewall firewall show rule name="HTTP" 
#netsh advfirewall firewall show rule name="HTTPS" 
#Get-NetFirewallRule | where { $_.Enabled -eq 'True' -and $_.Direction -eq 'Inbound' -and $_.DisplayName -Like '*check*'}
#Get-NetFirewallRule | where { $_.Direction -eq 'Inbound' -and $_.LocalPort= 80}
# /* virker i powershell 1 Søg i Netstat */	
$f=netstat -an
$f.count
foreach($fw in $f) {if($fw.contains("443") ){$fw}}

# /* Virker i powershell 2 */
#Function Get-FireWallRule{
#	Param ($Name, $Direction, $Enabled, $Protocol, $profile, $action, $grouping)
#	$Rules=(New-object –comObject HNetCfg.FwPolicy2).rules
#	If ($name)      {$rules= $rules | where-object {$_.name     -like $name}}
#	If ($direction) {$rules= $rules | where-object {$_.direction  -eq $direction}}
#	If ($Enabled)   {$rules= $rules | where-object {$_.Enabled    -eq $Enabled}}
#	If ($protocol)  {$rules= $rules | where-object {$_.protocol   -eq $protocol}}
#	If ($profile)   {$rules= $rules | where-object {$_.Profiles -bAND $profile}}
#	If ($Action)    {$rules= $rules | where-object {$_.Action     -eq $Action}}
#	If ($Grouping)  {$rules= $rules | where-object {$_.Grouping -like $Grouping}}
#	$rules
#}

Get-FirewallRule | where { $_.LocalPorts -in 80,443}
Get-FirewallRule | where { $_.LocalPorts -in 80,135,443,1433,1434,2283,2382} | Format-Table Name,Localports,Enabled,Direction

#læs logfiles
Notepad $SQLlog"\Summary.txt"
get-childitem $SQLlog |ft
Write-Host "CD to todays folder, and notepad detail.txt  for extensive error seeking."

$svar = " "
do{
	$svar=Read-Host "Alt OK, med step "$Pm.Step" fortsæt med næste Step? (ja/nej)"
	If ($svar -in 'ja','j','J','y','Y') {write-host "Fint!";$Pm.Step+=1;$svar = "ja"
	} elseIf ($svar -in 'Nej','n','N','no') {write-host "ok, slutter ved trin "$Pm.Step", Farvel!";break}
	} until ($svar -eq "ja")
}
	$Pm|Export-Clixml -path $FSpath\$FSparm
set-location $Egodisk
set-location \$Egosti

If ($Pm.Step -eq 6){ 

#Check om firewall regler findes før oprettelse
#Check om firewall regler findes før oprettelse
#Check om firewall regler findes før oprettelse
#Check om firewall regler findes før oprettelse
#Check om firewall regler findes før oprettelse






# Fejl ved Check_MK klargøring




# Fejl ved dismount 







1
#$fwr=Get-NetFirewallRule | where { $_.Enabled -eq 'True' -and $_.Direction -eq 'Inbound' -and $_.DisplayName -Like '*SQL*'}
#If($fwr.name.count -lt 1){
#Remove-NetFirewallRule -Name "SQL Server"
$fwr=Get-NetFirewallRule | where { $_.Enabled -eq 'True' -and $_.Direction -eq 'Inbound' -and $_.DisplayName -Like '*SQL Server*'}
If($fwr.name.count -lt 1){
	New-NetFirewallRule -Name "SQL Server" -DisplayName "SQL Server" -Profile Any -Direction Inbound -Action Allow -Protocol TCP -LocalPort 1433
}

#Remove-NetFirewallRule -Name "SQL Browser"
$fwr=Get-NetFirewallRule | where { $_.Enabled -eq 'True' -and $_.Direction -eq 'Inbound' -and $_.DisplayName -Like '*SQL Browser'}
If($fwr.name.count -lt 1){
	New-NetFirewallRule -Name "SQL Browser" -DisplayName "SQL Browser" -Profile Any -Direction Inbound -Action Allow -Protocol UDP -LocalPort 1434
}

If ($SQLInstFeat -match "a") {
	$fwr=Get-NetFirewallRule | where { $_.Enabled -eq 'True' -and $_.Direction -eq 'Inbound' -and $_.DisplayName -Like '*SSAS*'}
	If($fwr.name.count -lt 1){
		New-NetFirewallRule -Name "SSAS" -DisplayName "SSAS" -Profile Any -Direction Inbound -Action Allow -Protocol TCP -LocalPort 2383
		New-NetFirewallRule -Name "SSASb" -DisplayName "SSASbrowse" -Profile Any -Direction Inbound -Action Allow -Protocol TCP -LocalPort 2382
	}
}
# Open TCP port 2382 when installing a named instance. Named instances use dynamic port assignments. As the discovery 
# service for Analysis Services, SQL Server Browser service listens on TCP port 2382 and redirects the connection request 
# to the port currently used by Analysis Services. 
If ($SQLInstFeat -match "i") {
	$fwr=Get-NetFirewallRule | where { $_.Enabled -eq 'True' -and $_.Direction -eq 'Inbound' -and $_.DisplayName -Like '*SSIS*'}
	If($fwr.name.count -lt 1){
		New-NetFirewallRule -Name "SSIS" -DisplayName "SSIS" -Profile Any -Direction Inbound -Action Allow -Protocol TCP -LocalPort 135
	}
}

If ($SQLInstFeat -match "u") {
	$fwr=Get-NetFirewallRule | where { $_.Enabled -eq 'True' -and $_.Direction -eq 'Inbound' -and $_.DisplayName -Like '*HTTP*'}
	If($fwr.name.count -lt 1){
		New-NetFirewallRule -Name "HTTP" -DisplayName "HTTP" -Profile Any -Direction Inbound -Action Allow -Protocol TCP -LocalPort 80
		New-NetFirewallRule -Name "HTTPS" -DisplayName "HTTPS" -Profile Any -Direction Inbound -Action Allow -Protocol TCP -LocalPort 443
	}
}
#Write-Host "netsh firewall add portopening protocol=TCP port=135 name="RPC (TCP/135)" mode=ENABLE scope=SUBNET"
#To open the firewall for all computers, and also for computers on the Internet, replace scope=SUBNET with scope=ALL.

Get-FirewallRule | where { $_.LocalPorts -in 80,135,443,1433,1434,2283,2382} | Format-Table Name,Localports,Enabled,Direction

If ($SQLInstFeat -eq 'r') {
	stop-Service MSSQLLaunchpad
}
stop-Service SQLSERVERAGENT
stop-Service SQLBrowser

restart-Service mssqlserver
start-Service SQLSERVERAGENT
start-Service SQLBrowser
If ($SQLInstFeat -eq 'r') {
	start-Service MSSQLLaunchpad
}

#copy Z:\sqldba\mssql.vbs "C:\Program Files (x86)\check_mk\plugins\"
if (test-path p:\sqldba\mssql.vbs) {
	Write-Host  "Husk at Installer nyeste version af Check_MK agent via p:\sqldba\New-CheckMK.ps1 "
}
Write-Host  "Husk at discover services / tabula resa i Check_MK for $SQLdomain \ $SQLsName "
$svar = " "
do{
	$svar=Read-Host "Alt OK, med step "$Pm.Step "fortsæt med næste Step? (ja/nej)"
	If ($svar -in 'ja','j','J','y','Y') {write-host "Fint!";$Pm.Step+=1;$svar = "ja"
	} elseIf ($svar -in 'Nej','n','N','no') {write-host "ok, slutter ved trin "$Pm.Step", Farvel!";break}
	} until ($svar -eq "ja")
}
	$Pm|Export-Clixml -path $FSpath\$FSparm
set-location $Egodisk
set-location \$Egosti

If ($Pm.Step -eq 7){ 

write-host "Opret ny hostnotes for server i Sharepoint"
write-host "Kopier skabelon og server link ind, og hostnotes link ind i server."
write-host "opret ny Servicekonto i Sharepoint, og peg på secret."
write-host "indsæt info fra installationen i ovenstående. UDEN passwords"
If ($SQLInstFeat -eq 'r') {
Write-Host "kør kommando på sql: sp_configure 'external scripts enabled' med resultat maximum =1"
Write-Host " evt: Restart-Computer "
Write-Host "Check: ny service running: MSSQLLaunchpad"  
Write-Host "Genstart alle SQL Services"
Write-Host "kør SQL:"
Write-Host "use master;"
Write-Host "exec sp_execute_external_script @language =N'R',"
Write-Host "@script=N'"
Write-Host "OutputDataSet <- InputDataSet;"
Write-Host "',"
Write-Host "@input_data_1 =N'SELECT 1 AS hello'"
Write-Host "With Result Sets (([hello] int not null));"
Write-Host "Go"

Write-Host "Installer Service Packs & CU"
Write-Host "Installer Ola Hallgreens Maintenance scripts"
Write-Host "SD på SQL Backup installation til ASC"
Write-Host "Installer & Klargør SQL Logpoint Auditering"
Write-Host  "Husk at Installer nyeste version af Check_MK agent via p:\sqldba\New-CheckMK.ps1 "
}
$svar = " "
do{
	$svar=Read-Host "Alt OK, med step "$Pm.Step" fortsæt med næste Step? (ja/nej)"
	If ($svar -in 'ja','j','J','y','Y') {write-host "Fint!";$Pm.Step+=1;$svar = "ja"
	} elseIf ($svar -in 'Nej','n','N','no') {write-host "ok, slutter ved trin "$Pm.Step", Farvel!";break}
	} until ($svar -eq "ja")
}
	$Pm|Export-Clixml -path $FSpath\$FSparm
set-location $Egodisk
set-location \$Egosti


If ($Pm.Step -eq 8){ 
Write-Host  Mangler
Write-Host "setspn -S MSOLAPDisco.3/s-mssql02-p.dksund.dk dksund.dk\s-mssql02-p"
Write-Host "setspn -S MSOLAPDisco.3/s-mssql02-p dksund.dk\s-mssql02-p"

Write-Host "DisMounting . . . "
#$mountResult=Dismount-DiskImage -passthru -ImagePath c:\install\$SqlIson 
$mountResult=Dismount-DiskImage -ImagePath c:\install\$SqlIson 

$driveLetter = ($mountResult | Get-Volume).DriveLetter
$d=$driveLetter
$d+=":"
write-Host "DisMounted: " $d

Get-Volume |ft

$svar = " "
do{
	$svar=Read-Host "Alt OK, med step "$Pm.Step" fortsæt med næste Step? (ja/nej)"
	If ($svar -in 'ja','j','J','y','Y') {write-host "Fint!";$Pm.Step+=1;$svar = "ja"
	} elseIf ($svar -in 'Nej','n','N','no') {write-host "ok, slutter ved trin "$Pm.Step", Farvel!";break}
	} until ($svar -eq "ja")
}
	$Pm|Export-Clixml -path $FSpath\$FSparm
set-location $Egodisk
set-location \$Egosti
#copy $Egofil \$gsti\
#get-childitem

#Write-Host "Installation af SSMS"
#set-location $Egodisk
#cd \
#if (test-path sqldba\*.*) {cd sqldba}
#if (test-path ps1\*.*) {cd ps1}
#if (test-path $winver\*.*) {cd $winver}
#Start-Process -wait -FilePath .\ssms-inst.ps1
#Start-Process -wait -FilePath .\Setup.exe -ArgumentList $ArgL

# SIG # Begin signature block
# MIIdAgYJKoZIhvcNAQcCoIIc8zCCHO8CAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCDII0qyiAY4DVV/
# mkDxEHj1DM0mtbo9advduY7h3uvhs6CCGBMwggT+MIID5qADAgECAhANQkrgvjqI
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
# MAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEIHljbqCpFIh2NgRtay1G3yvX
# D1ljouzX6CEJ2Pk/VcIQMA0GCSqGSIb3DQEBAQUABIIBABqRh+k86QH67C2bVsS7
# ZDRJ0rEmS4G1acddK4Nbv//F2Ywu7f9M6OwCERvZfDr8Ajxc5YPJ57JOJtAjs7/+
# PROuUymsCojDediXlhMlUBWTKR9iUZXUrSGKDd/0vr+8EJsS8bywVx0MJi9/EnKL
# 32AmuRlRTgAWH+IayS5cYCi7VBoEwYHfNM1GlDedSJlaaUkflvMqwRgG7DfLuM3y
# vBvDShZidPNsshRxrovovfjMioLOG/KbZ4RLcvqvVrzs2uGXBUXR2QArM2Oky6Kp
# 52oH2h6ET9FzdVvBGqgHx7cqHAMdwuzZT3cDFuvDFej2r3OzBeQNhyiFAYQdRcMS
# 76yhggIwMIICLAYJKoZIhvcNAQkGMYICHTCCAhkCAQEwgYYwcjELMAkGA1UEBhMC
# VVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQd3d3LmRpZ2ljZXJ0
# LmNvbTExMC8GA1UEAxMoRGlnaUNlcnQgU0hBMiBBc3N1cmVkIElEIFRpbWVzdGFt
# cGluZyBDQQIQDUJK4L46iP9gQCHOFADw3TANBglghkgBZQMEAgEFAKBpMBgGCSqG
# SIb3DQEJAzELBgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTIxMDcxMjA4MDUz
# MlowLwYJKoZIhvcNAQkEMSIEIPYwowzHzvoQg13qvhnzdOVJ/y0nMTLYW9IgoKW/
# 3zNHMA0GCSqGSIb3DQEBAQUABIIBAJ7Hl641A7mmwj1ctAKjMcBTZyPbk5b5lWeS
# mPeIUmyMTfUagIzcg36GC76z7slPYWBUDHSpLpctKZcOrK2FTRznPhlLLZ0eWIWz
# oPAtf7iT7aRErF4gcxAsEdk2qo4jN7NPnoTmg7jZ77SQR4DUdqR26irf68iuwa93
# +JKblGfKrfpytvlpW8uEA9ZjmTNmRU/Fb38H/+M0n+zZR6VgvSWYNgd/ODR9CZtH
# +tE3EQ441dW+l64bQ+vsOkPd4VIDwG07kerxyux9CimUHMxiBBejs+1u16LboPk6
# YaUra4y1leFwOKfPEJr70wFfhXyc8wBG09VmAnTzXcmnBoC7YNA=
# SIG # End signature block
