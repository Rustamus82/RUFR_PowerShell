
If($args.count -gt 1) {
    $Pnr=$args[0]
    $p2=$args[1]
    $p3=$args[2]
}else{
    [string]$Pnr=$args
}

$sqldS="ssi","sst","dksund","dksundtest","intdmz","pubdmz","imkit","nsidsdn","ssidmz01"
# No powershell function for testing if value numeric exists, This returns true if numeric, else false
Function Is-Num([string]$i1){
[bool]$r=0
If($i1.length -lt1){return $r}
trap {return $r}
$r=$i1/1
$r=1
Return $r
}

# Get Program location  $Egodisk="z:";  $Egosti="ps1\u"; $Egofil="sql-macro.ps1"
#$xx=$EgoCmd=$PSCommandPath -Split("\\") 		#giver lokation af SQL-Macro.ps1
#$EgoCmd=Get-Location											#giver lokation hvor der kaldes fra.
#$EgoCmd=$EgoCmd.path.Split("\\")
#$Egodisk=$EgoCmd[0]
#$Egofil=$EgoCmd[-1]											#der er ingen fil der kaldes fra
#If($EgoCmd.Count -lt 3){$Egosti=''}elseif($EgoCmd.Count -eq 3){$Egosti=$EgoCmd[1]}else{$EgoCmd=$EgoCmd[1..($EgoCmd.Count-2)];$Egosti=$EgoCmd -join("\")}
$EgoServer=$env:Computername
$EgoOs = Get-CIMInstance win32_operatingsystem -cn $EgoServer
$EgoArr=(($EgoOs.name -split("\|"))[0]) -split(" ");foreach($EgoI in $EgoArr){If (Is-Num $EgoI) {$EgoWin=$EgoI}}
# Get User location ? hvor er du ?
$EgoCmd=Get-Location											#giver lokation hvor der kaldes fra.
$EgoCmd=$EgoCmd.path.Split("\\")
$Egodisk=$EgoCmd[0]
If($EgoCmd.Count -lt 2){$Egosti=''}elseif($EgoCmd.Count -eq 2){$Egosti=$EgoCmd[1]}else{$EgoCmd=$EgoCmd[1..($EgoCmd.Count)];$Egosti=$EgoCmd -join("\")}
$Egofil="u\sql-macro.ps1"
$IsAdm=[bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544")
#$h=Get-Location
#$h=$h.path.Split("\\")
#$diskr=$h[0]
#If($h.Count -lt 2){$stir=''}elseif($h.Count -eq 2){$stir=$h[1]}else{$h=$h[1..($h.Count)];$stir=$h -join("\")}

Function Get-Rndpw($wp2){
if ($wp2 -eq "?"){Write-output "Angiver et random password, -wp2 længden af password hvis ikke default 16 char.";Return}
If (!(Is-Num $wp2)) {$wp2 = 16}
$w= ([char[]]([char]'a'..[char]'z'))
$w+=(0..9)
$w+=('§ ! @ £ ¤ % & = ? + - _').Split(" ")
$w+=([char[]]([char]'A'..[char]'Z'))
Write-Output $wp2
$wpas= Get-Random -count $wp2 -InputObject ($w)
$wp=$wpas -join('')
Return $wp
}

Function List-MyAlias{
$wAlias=('Scite','wm','ver','tail','sqm','xy')
 [array]::sort($wAlias) 
Return $wAlias
}
Function List-ssas{
	$Antal=$rcc=0
	$ssast='Instanser: '
	$rc=Get-Service -displayname 'Sql Server Analysis*'		#List services med ssas
	if ($rc.count -gt 0){
		$rcc=$rc.count
		$wouta= "Antal SSAS Instanser fundet på {0}: {1}"  -f $EgoServer,$rcc
		foreach($r in $rc) {
			If($r.Status -eq 'Running'){
			#	$loadInfo = [Reflection.Assembly]::LoadWithPartialName('Microsoft.AnalysisServices')
				$serverA = New-Object Microsoft.AnalysisServices.Server
				$ssasn=($r.DisplayName).Split("(,)")[1]
				If ($ssasn -eq 'MSSQLSERVER') {
					$lh="localhost"
				}Else{
					$lh="localhost\"
					$lh+=$ssasn
				}
				$ssast+=$ssasn
				$ssast+=","
				$rc=$serverA.connect($lh)
				$rc
				$rc
				foreach ($database in $serverA.Databases){
					foreach ($cube in $database.cubes){
						If($Antal -eq 0) {Write-Output "SSAS Kuber fundet:"}
						$Antal+=1
						$dbn=$database.name
						$cun=$cube.Name
						$wout="Instans: $ssasn LH $lh db $dbn kube $cun"
						Write-Output $wout= 
					} #FE Cube
				} #FE DB
			}Else{# SSAS service ikke running
			}
		} #FE  ssas
	Write-Output $wouta
	Write-Output $ssast.TrimEnd(',')
	}Else{ Write-Output "Ingen SSAS services aktive"
	}
}
Function When-Dbadb{
	$q="select * from sys.databases where name='DBA_DB'"
	$sq=Get-Service -displayname 'Sql Server (*'
	foreach($s in $sq){
		$w=$s.DisplayName 
		$w=$w.Split('(,)')[1]
		$srv=$EgoServer
		If ($w -ne 'MSSQLSERVER'){
			$srv+='\'
			$srv+=$w
		}
		if ($s.Status -eq "Running"){
			$iq=Invoke-SQLCMD -ServerInstance $srv -Query $q
			Write-Output "$srv ($w) DBA_DB created: " $iq.create_date
		}else{Write-Output "$srv ($w) not running"}
	}
}
Function Get-FireWallRule{
	Param ($Name, $Direction, $Enabled, $Protocol, $profile, $action, $grouping)
	$Rules=(New-object –comObject HNetCfg.FwPolicy2).rules
	If ($name)      {$rules= $rules | where-object {$_.name     -like $name}}
	If ($direction) {$rules= $rules | where-object {$_.direction  -eq $direction}}
	If ($Enabled)   {$rules= $rules | where-object {$_.Enabled    -eq $Enabled}}
	If ($protocol)  {$rules= $rules | where-object {$_.protocol   -eq $protocol}}
	If ($profile)   {$rules= $rules | where-object {$_.Profiles -bAND $profile}}
	If ($Action)    {$rules= $rules | where-object {$_.Action     -eq $Action}}
	If ($Grouping)  {$rules= $rules | where-object {$_.Grouping -like $Grouping}}
	$rules
}

Function List-sqlfw{
	{Get-FirewallRule | Where-Object { $_.LocalPorts -in 80,135,443,1433,1434,1500,1501,1502,1503,1504,1581,2383,2382,5022} | Format-Table Name,Localports,Enabled,Direction}
#	{Get-FirewallRule | Where-Object { "80 135 443 1433 1434 1500 1501 1502 1503 1504 1581 2383 2382" -match $_.LocalPorts } | Format-Table Name,Localports,Enabled,Direction}
}

Function List-FireWall{
Param (
	[String]$Direction
	)
	If($Direction.Substring(0,1) -eq "o") {$Direction="Outbound"}else{$Direction="Inbound"}
	Get-NetFirewallRule -Action Allow -Enabled True -Direction $Direction |	Format-Table -Property Name,
	@{Name='Protocol';Expression={($PSItem | Get-NetFirewallPortFilter).Protocol}},
	@{Name='LocalPort';Expression={($PSItem | Get-NetFirewallPortFilter).LocalPort}},
	@{Name='RemotePort';Expression={($PSItem | Get-NetFirewallPortFilter).RemotePort}},
	@{Name='RemoteAddress';Expression={($PSItem | Get-NetFirewallAddressFilter).RemoteAddress}},
	Enabled,Profile,Direction,Action
}

Function List-IpAdresse {
    $ret=Get-NetIPAddress -AddressFamily IPv4 -AddressState Preferred | `
    Where-Object { $_.PrefixOrigin -ne 'WellKnown' } | `
    Select-Object -ExpandProperty IPAddress
	Return $ret
}

Function List-sqlservice{
	$sqls=Get-CIMInstance win32_service -ComputerName . -Filter "displayname like 'sql server (%' OR displayname like 'sql server analysis services (%' OR displayname like 'sql server Reporting services%' OR displayname like 'sql server Integration services%' OR displayname like 'sql server agent (%'" | Select-Object State,Name,DisplayName,StartName,Startmode
	Return $sqls
}

Function List-Color{
	$colors = [enum]::GetValues([System.ConsoleColor])
	$fc=0
	foreach( $fcolor in $colors ){$bc=0
		foreach( $bcolor in $colors ){
			Write-Host "ForegroundColor is $fc : $fcolor -  BackgroundColor is $bc : $bcolor "-ForegroundColor $fcolor -BackgroundColor $bcolor
			$bc++
		}
		$fc++
	}
	Return 
}

Function List-SetSpn{
	SetSPN -L $EgoServer
	$Sqls1=List-sqlservice
	foreach($s in $Sqls1){
	$a=((($s.StartName -split('\\'))[0]).split('.'))[0]
	If ($sqldS -contains($a)){SetSPN -L $s.StartName} Else{
		$b=" - Service {0} - {1} er en lokal, ikke et AD service account!" -f $s.Name,$s.StartName
		Write-Output $b
		}
	}
}

Function Start-sqlservice{
	$Sqls1=List-sqlservice
	foreach($s in $Sqls1){
		$rc=Start-Service $s.Name
	}
	List-sqlservice|Format-Table
}
function Format-SQLDisk([string]$driveletter){
	If ($driveletter.length -gt 0){If (!($driveletter.length -gt 2)){
		$dl=$driveletter.Substring(0,1)
		Switch ($dl)
			{
				r	{$drLab="SQLData"}
				s	{$drLab="SQLLog"}
				t	{$drLab="SQLTemp"}
				u	{$drLab="SQLBackup"}
				q	{$drLab="SQLTemp1"}
				m	{$drLab="SQLTemp2"}
				n	{$drLab="SQLTemp3"}
				o	{$drLab="SQLTemp4"}
				k	{$drLab="SQLTemp3"}
				l	{$drLab="SQLTemp4"}
				v	{$drLab="SQLTemp5"}
				w	{$drLab="SQLTemp6"}
				x	{$drLab="SQLTemp7"}
				default {Write-Output "Der skal angives et gyldigt SQL drev! IKKE $driveletter"}
			}
			If ($drLab.length -gt 3){
				$svar=Read-Host "Vil du formatere drev $dl : som $drlab ?"
				If ($svar -in 'ja','j','J','y','Y') {
					Format-Volume 	-DriveLetter $dl -NewFileSystemLabel $drLab -FileSystem NTFS -AllocationUnitSize 65536 –Force -Confirm:$false
				}
			}
		}Else{Write-Output "Der skal angives drevbogstav for disk 1 char!"}
	}Else{Write-Output "Der skal angives drevbogstav for disk 1 char!"}
}

Function List-LogDisk{
Param (
	[String[]]$DiskA
)
#	$Rca=Get-CIMInstance -Class Win32_logicaldisk |Select DeviceID, SystemName, BlockSize, DriveType,FileSystem,VolumeName,
	$Rca=Get-CIMInstance -Class Win32_logicaldisk |Select DeviceID, DriveType,
            @{Label="DiskType";Expression={switch ($_.DriveType) {0 {"Unknown"} 1 {"NoRootDir"} 2 {"Removable"} 3 {"LocalDisk"} 4 {"Network Drive"}  5 {"CD-Rom"} 6 {"RAM Disk"} }}},
            @{Label="    FreeSpace";Expression={"{0,10:n2} Gb" -f ($_.Freespace/1gb)}},
            @{Label="       Size";Expression={"{0,10:n2} Gb" -f ($_.Size/1gb)}},
            ProviderName |Sort-Object {$_.DeviceID} |
        Format-Table -AutoSize
	Write-Output $Rca
#	Write-Output " "
	$Rcb=@()
	If($DiskA.count -gt 1) {
#	$DiskA.count
		$DiskA = $DiskA[1..($DiskA.Length-1)]
		foreach($ai in $DiskA){
			$a2=$ai+':'
			$Rca=Get-CIMInstance -Class Win32_logicaldisk -Filter "Name = '$a2'" |Select DeviceID, DriveType,
            @{Label="DiskType";Expression={switch ($_.DriveType) {0 {"Unknown"} 1 {"NoRootDir"} 2 {"Removable"} 3 {"LocalDisk"} 4 {"Network Drive"}  5 {"CD-Rom"} 6 {"RAM Disk"} }}},
            @{Label="    FreeSpace";Expression={"{0,10:n2} Gb" -f ($_.Freespace/1gb)}},
            @{Label="       Size";Expression={"{0,10:n2} Gb" -f ($_.Size/1gb)}},
            ProviderName |Sort-Object {$_.DeviceID} 
	    $Rcb+=$Rca
#			Write-Output "Disk $a2" 
		}
			Write-Output $rcb |         Format-Table -AutoSize
	}
}

Function List-Diskinfo{
Param (
	[String[]]$DiskA
)

#	If($IsAdm) {Get-Volume}Else{
		Write-Output "ADVARSEL: Man skal være på som administrator for at Get-Volume har adgang til en CIM resource."
		$Rca=Get-CIMInstance -Class Win32_Volume | Select DriveLetter, Label, BlockSize, DriveType,
            @{Label="DiskType";Expression={switch ($_.DriveType) {2 {"Removable"} 3 {"Fixed"} 5 {"CD-Rom"}}}},
            @{Label="FreeSpace";Expression={"{0,10:n2} Gb" -f ($_.Freespace/1gb)}},
#            @{Label="FreeSpace";Expression={"{0,10:0.##} Gb" -f ($_.Freespace/1gb)}},
            @{Label="Capacity";Expression={"{0,10:n2} Gb" -f ($_.Capacity/1gb)}},
            DeviceID |Sort-Object {$_.DriveLetter} |
        Format-Table -AutoSize
		Write-Output $Rca
#	}
	Write-Output " "
	If($DiskA.count -gt 1) {
		#$first, $diskB = $DiskA
		$DiskA = $DiskA[1..($DiskA.Length-1)]
		foreach($ai in $DiskA){
			$a2=$ai+':'
			$Rca=Get-CIMInstance -Class Win32_volume -Filter "DriveLetter = '$a2'"
			Write-Output "Disk $a2" 
			Write-Output $rca
		}
	}
}

Function List-TSMinfo{
	$Tsms=Get-CIMInstance win32_service -ComputerName . -Filter "displayname like 'TSM%' " | select State,Name,DisplayName,StartName,Startmode
	Return $Tsms
}
	$colors = [enum]::GetValues([System.ConsoleColor])
	$SkrivHvid = @{
		NoNewLine       = $true
		ForegroundColor = $colors[15]
	}
	$SkrivGreen = @{
		NoNewLine       = $true
		ForegroundColor = $colors[10]
	}
	$SkrivGul = @{
		NoNewLine       = $False
		ForegroundColor = $colors[14]
	}

Function Skriv-Hash {
    param(
        [hashtable]$Hash1
		)
	$message =@()
	foreach($key in $Hash1.keys){
		$Value1=$Hash1[$key]
		$Type1=$key.GetType().name
		If ($Hash1[$key] -is [System.Collections.IDictionary]){$Value1=$Hash1[$key].GetType().name}		##
		If ($key.GetType().isarray){$Value1 = "[Array]"}
		If( ($Hash1[$key].GetType()).name -eq "Arraylist") {$Value1 = "[Array]"}
#		$message += 'Param {0} af typen {2} har værdien {1} ' -f $key, $Value1, $Type1
		Write-Output  "Param " @SkrivHvid
		Write-Output  $key.PadRight(15," ") @SkrivGreen
		Write-Output  " af typen " @SkrivHvid
		Write-Output $Type1.PadRight(10," ") @SkrivGreen
		Write-Output  " har værdien: " @SkrivHvid
		Write-Output $Value1 @SkrivGul
		#Write-Output $message
		If ($key.GetType().isarray){Write-Output $Hash1[$key]}
		If( ($Hash1[$key].GetType()).name -eq "Arraylist") {
			$z9=(($Hash1[$key]).count)
			for ($z0=0; $z0 -lt $z9; $z0++){
				$Array1=$Hash1[$key]		# = arraylist
				$Hash2=$Array1[$z0]		# 
				If (($Hash2 -is [System.Collections.IDictionary]) -or ($Hash2 -is [System.Collections.Hashtable]) -or ($Hash2 -is [System.Collections.Specialized.OrderedDictionary])){
					Foreach($Ky in $Hash2.keys){
						$Value1=$Hash2[$Ky]
						$Type1=$Ky.GetType().name
						If ($Hash2[$Ky] -is [System.Collections.IDictionary]){$Type1=$Hash2[$Ky].GetType().name}
						If ($Ky.GetType().isarray){$Type1 = "[Array]"}
						Write-Output "Param " @SkrivHvid
						$Kindex="$key [$z0]"
						Write-Output $Kindex.PadRight(15," ") @SkrivGreen
						Write-Output " Subparm " @SkrivHvid
						Write-Output $Ky.PadRight(30," ") @SkrivGreen
						Write-Output  " type " @SkrivHvid
						Write-Output $Type1.PadRight(10," ") @SkrivGreen
						Write-Output " har værdien: " @SkrivHvid
						Write-Output $Hash2[$Ky] @SkrivGul					
					}
				}
			}
		}
		
		$Hash2=$Hash1[$key]
		If (($Hash2 -is [System.Collections.IDictionary]) -or ($Hash2 -is [System.Collections.Hashtable]) -or ($Hash2 -is [System.Collections.Specialized.OrderedDictionary])){
			Foreach($Ky in $Hash2.keys){
				$Value1=$Hash2[$Ky]
				$Type1=$Ky.GetType().name
				If ($Hash2[$Ky] -is [System.Collections.IDictionary]){$Value1=$Hash2[$Ky].GetType().name}
				If ($Ky.GetType().isarray){$Value1 = "[Array]"}
				Write-Output "Param " @SkrivHvid
				Write-Output $key.PadRight(15," ") @SkrivGreen
				Write-Output " Subparm " @SkrivHvid
				Write-Output $Ky.PadRight(30," ") @SkrivGreen
				Write-Output  " type " @SkrivHvid
				Write-Output $Type1.PadRight(10," ") @SkrivGreen
				Write-Output " har værdien: " @SkrivHvid
				Write-Output $Value1 @SkrivGul					#}
				#Write-Output $message
			}
		}
	}
	Return $message
}

Function Chg-DriveLetter ([string]$fra,[string]$til){
	if ($fra.length -ne 1){Write-output "Param -fra: $fra er ikke 1 char lang, det skal den være. ";Return}
	if ($fra -eq "?"){Write-output "Skifter drevbogstav -fra -til Angiv f.eks. z d for at flytte cd-rom fra z: til d:";Return}
	if ($til.length -ne 1){Write-output "Param -til: $til er ikke 1 char lang, det skal den være. ";Return}
	If(!($IsAdm)) {Write-output "Du skal ""run as Administrator"" for at kunne ændre drevbogstav!" ;Return}
	$a=Get-Volume 
	$ok=0
	foreach ($aa in $a){
		If ($aa.driveletter -eq $til){Write-output "Param -til er ikke brugbar, Disk $til allerede i brug  ";Return}
		If ($aa.driveletter -eq $fra){$ok=1}
	}
	If($ok -ne 1){Write-output "Param -fra er ikke brugbar, Disk $fra findes ikke ";Return}
	$fra+=":"
	$til+=":"
#	$a=Set-WmiInstance -InputObject ( Get-WmiObject -Class Win32_volume -Filter "DriveLetter = '$fra'") -Arguments @{DriveLetter="$til"}
	$a=Set-CIMInstance -InputObject ( Get-CIMInstance -Class Win32_volume -Filter "DriveLetter = '$fra'") -Arguments @{DriveLetter="$til"}
	If ($a.DriveLetter -eq $til){$aa=get-volume $til.substring(0,1)}
	Return $aa
}

Function List-SQLinfo{
$qi="select @@Servername as Servername
	,@@SERVICENAME as Instancename
	,Serverproperty('MachineName') as MachN
	,Serverproperty('InstanceName') as InstN
	,Serverproperty('ServerName') as ServN
	,@@VERSION as Version
	,Serverproperty('ProductVersion') as ProdVer
	,Serverproperty('Productlevel') as ProdLvl
	,Serverproperty('ProductUpdateLevel') as ProdUpdLvl
	,Serverproperty('Edition') as Edition
	,Serverproperty('InstanceDefaultDataPath') as Data
	,Serverproperty('InstanceDefaultLogPath') as Log
	,Serverproperty('InstanceDefaultBackupPath') as BK
	,CONVERT (varchar, SERVERPROPERTY('collation')) AS 'ServerCollation';
	"
#$r0="SQL kommando: 'Invoke-SQLCMD -ServerInstance ""(local)"" -Query ""Select Serverproperty('xxx')""'"
$r1=Invoke-SQLCMD -ServerInstance "(local)" -Query $qi
#$r2="@@Servername: {0} @@Servicename:\{1} (MachineName:{2} InstanceName:\{3}) " -f $r1.Servername,$r1.Instancename,$r1.MachN,$r1.InstN
#$r3="ServerName: {0} Collation: {1} " -f $r1.ServN,$r1.ServerCollation
#$r4="ProductVersion: {0} Productlevel: {1} ProductUpdateLevel: {2} Edition: {3} " -f $r1.ProdVer,$r1.ProdLvl,$r1.ProdUpdLvl,$r1.Edition
#$r5="InstanceDefaultDataPath: {0} " -f $r1.Data
#$r6="InstanceDefaultLogPath:  {0} " -f $r1.Log
#$r7="InstanceDefaultBackupPath:  {0} " -f $r1.Log
#$r8="@@Version: {0} " -f $r1.Version
#Write-Output $r0
#Write-Output $r2
#Write-Output $r3
#Write-Output $r4
#Write-Output $r5
#Write-Output $r6
#Write-Output $r7

[string]$v=$r1.Version
#$v0=$v.split("()")[0]
#$v1=$v.split("()")[1]
$KbNr=$v.split("()")[3]
#$v30=$v.split([Environment]::NewLine)[0]
#$v3=($v30.split("()",5)[4]).trimStart("- ")
#$v4=$v.split([Environment]::NewLine)[1]
#$v0=$v.split("(")[0]
#$v0=$v.split("(")[0]
#$v0=$v.split("(")[0]
#$v0=$v.split("(")[0]

$obj = New-Object –typename PSObject
$obj | Add-Member –membertype NoteProperty –name ComputerNavn –value ($EgoServer+"."+$env:USERDNSDOMAIN) –PassThru |
	Add-Member –membertype NoteProperty –name Servername –value ($r1.Servername) -PassThru |
	Add-Member –membertype NoteProperty –name Servicename –value ($r1.Instancename) -PassThru |
	Add-Member –membertype NoteProperty –name MachineName –value ($r1.MachN) -PassThru |
	Add-Member –membertype NoteProperty –name InstanceName –value ($r1.InstN) -PassThru |
	Add-Member –membertype NoteProperty –name Collation –value ($r1.ServerCollation) -PassThru |
	Add-Member –membertype NoteProperty –name ProductVersion –value ($r1.ProdVer) -PassThru |
	Add-Member –membertype NoteProperty –name Productlevel –value ($r1.ProdLvl) -PassThru |
	Add-Member –membertype NoteProperty –name ProductUpdateLevel –value ($r1.ProdUpdLvl) -PassThru |
	Add-Member –membertype NoteProperty –name KBnr –value ($KbNr) -PassThru |
	Add-Member –membertype NoteProperty –name Edition –value ($r1.Edition) -PassThru |
	Add-Member –membertype NoteProperty –name InstanceDefaultDataPath –value ($r1.Data) -PassThru  |
	Add-Member –membertype NoteProperty –name InstanceDefaultLogPath –value ($r1.Log) -PassThru |
	Add-Member –membertype NoteProperty –name InstanceDefaultBackupPath –value ($r1.Bk)# -PassThru |
#	Add-Member –membertype NoteProperty –name Version -value ($r1.Version)
	Write-Output $obj
}

#Main
#$EgoCmd=$PSCommandPath -Split("\\")
#$Egodisk=$EgoCmd[0]
If($pnr.length -lt 1 -or $pnr.contains('?')){
	Write-Output "MSSQL Sql-Macro skal have en parameter, der angiver hvad der skal foretages."
	Write-Output " 1 : List lokale SQL instances"
	Write-Output " 2 : List lokale SQL Analysis Services"
	Write-Output " 3 : List lokale *SQL* services"
	Write-Output " 4 : List lokale ssas instanser og kuber"
	Write-Output " 5 : List lokale SQL Services og service accounts"
	Write-Output " 5s : Start lokale SQL Services og service accounts"
	Write-Output " 6 : List lokale SQL dm_os_sys_info"
	Write-Output " 7 : List lokale SQL CheckInfo Check_MK mm. parametre"
	Write-Output " a : List mive alias"
	Write-Output " c : List available colours for powershell"
	Write-Output " d : List DBA_DB createdate per instance"
	Write-Output " f : Lister SQL relaterede firewall regler Brug evt p:\sqldba\ps1\u\get-fw.ps1 med port som param :-)"
	Write-Output " form : Formatter disk efter sql regler 64Kb mm. Brug p:\miveps1\u\SQL-Param.ps1  form med drevbogstav som param :-)"
	Write-Output " h : Viser hvor makroen kaldes fra"
	Write-Output " i : Viser egen ip-adresse(r)"
	Write-Output " l : Viser logiske diske (2=Floppy,3=Disk,4=Net,5=Cd,6=RamDisk)"
	Write-Output " lyt : Viser lyttende porte via Netstat"
	Write-Output " r : Random password"
	Write-Output " s : List SQL Info"
	Write-Output " sccm : Start SCCM Software Center (virker på Windows Core)"
	Write-Output " t : List TSM Info"
	Write-Output " v : List Disk Volumes"
	Write-Output " z : Skifter drevbogstav fra til Angiv f.eks. z d for at flytte cd-rom fra z: til d:"
	Write-Output " x : List XML Lokal SQL Parameter Installations fil eller Hash-Tabel"
	Write-Output " edit : Scite sql-macro"
	Write-Output " spn : List SetSPN information om Server & Service konti"
}ElseIf ($pnr.length -gt 2){
	If ($pnr.Substring(0,1) -eq "z"){$p2 = $pnr.Substring(1,1);$p3 = $pnr.Substring(2,1);$pnr="z"}
}ElseIf ($pnr.length -gt 1){
	If ($pnr.Substring(0,1) -eq "r"){$p2 = $pnr.Substring(1);$pnr="r"}
}
#$Egodisk
#$Egosti
	Switch ($pnr)
	{
		1 {Get-Service -displayname 'Sql Server (*'   }
		2 {Get-Service -displayname 'Sql Server Analysis*'   }
		3 {Get-Service *sql*}
		4 {List-ssas}
		'5l' {List-sqlservice|Format-List}
		5 {List-sqlservice|Format-Table}
		'5s' {start-sqlservice}
		6 {Write-Output "Select * from [sys].[dm_os_sys_info]";z:\ps1\2016\call-sql.ps1 -sqlcmd "Select * from [sys].[dm_os_sys_info]"}
		7 {Write-Output "Select * from [CheckInfo]";z:\ps1\2016\call-sql.ps1 -sqldb "DBA_DB" -sqlcmd "Select * FROM [DBA_DB].[dbo].[CheckInfo]"|Format-Table}
		'w' {if(!(Test-Path .\u\get-ver.ps1)){Get-CIMInstance -Class Win32_OperatingSystem | Select CSName,version,caption|Format-List}Else{.\u\Get-Ver.ps1}}
		'a' {get-alias -Definition *.*}    #{List-MyAlias}
		'c' {$ci=0;[enum]::GetValues([System.ConsoleColor]) | Foreach-Object {Write-Host $i $_ -ForegroundColor $_;$i++} }
		'cc' {List-Color}
		'cb' {[enum]::GetValues([System.ConsoleColor]) | Foreach-Object {Write-Output $_ -BackgroundColor $_} }
		'd' {When-Dbadb}
		'fi' {List-FireWall -Direction i}
		'fo' {List-FireWall -Direction o}
		'fp' {$ar=$args -split(",") -split(" ");$ar=$ar[1..($ar.length -1)];Get-FirewallRule | Where-Object { $_.LocalPorts -in $ar} | Format-Table Name,Localports,Enabled,Direction}
		'form' {Format-SQLDisk -driveletter $p2}
		'f' {Get-FirewallRule | Where-Object { $_.LocalPorts -in 80,135,443,1433,1434,1500,1501,1502,1503,1504,1581,2383,2382,5022} | Format-Table Name,Localports,Enabled,Direction}
		'i' {List-IpAdresse}
		'l' {List-LogDisk -diska $args}
		'lyt' {netstat -ao -p TCP}
		'r' {Get-Rndpw $p2 }
		's' {List-SQLinfo}
		'sccm' {If(!(Test-path c:\windows\ccm)){Write-Host "Sccm klient ikke installeret";Exit}Else{c:\windows\ccm\SCClient.exe}}
		't' {List-TSMinfo}
		'v' {List-Diskinfo -diska $args}
		'x' {If(($p2.length -gt 0) -And (test-Path $p2)){$pm=@{};	$pm=Import-Clixml -Path $p2;Skriv-Hash -Hash1 $pm
				}Else{
				$FSparm="$Egodisk\$Egosti\$EgoWin\$EgoServer\SqlInstParm.xml"
				Write-Output $FSparm
				if(test-Path $FSparm){$pm=@{};$pm=Import-Clixml -Path $FSparm;	Skriv-Hash -Hash1 $pm}}}
		'z' {Chg-DriveLetter -fra $p2 -til $p3}
		'spn' {List-SetSpn}
		'h' {Write-Output "Kommando fra disk: $Egodisk sti: $Egosti app: $Egofil"}
		'Edit' {If((get-alias scite).name.count){scite $Egodisk\$Egosti\$Egofil}Else{Notepad $Egodisk\$Egosti\$Egofil}}
		'Editi' {If((get-alias scite).name.count){scite $Egodisk\ps1\u\InclFunc.ps1}Else{Notepad $Egodisk\ps1\u\InclFunc.ps1}}
		'Editp' {If((get-alias scite).name.count){scite $profile}Else{Notepad $profile}}
		'Editv' {If((get-alias scite).name.count){scite $Egodisk\ps1\u\get-ver.ps1}Else{Notepad $Egodisk\ps1\u\get-ver.ps1}}
		'Editm' {If((get-alias scite).name.count){scite $Egodisk\DBA\MaintenanceScript\MaintenanceSolution_20210104.sql}Else{Notepad $Egodisk\DBA\MaintenanceScript\MaintenanceSolution_20210104.sql}}
	}


set-location $Egodisk
set-location \$Egosti

# SIG # Begin signature block
# MIIdAgYJKoZIhvcNAQcCoIIc8zCCHO8CAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCD/UAGblyC9BjE9
# wOnijO1D5/AHEvtPYwHTTRvQtGoLuaCCGBMwggT+MIID5qADAgECAhANQkrgvjqI
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
# MAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEIC3CzvwNlR6bEUvCBuR6mfyr
# OJdZ9k9zAd24uMTPAY47MA0GCSqGSIb3DQEBAQUABIIBANlP3hIxFaMURh5Le4im
# RIkUHrXjDZb6Vj4LPq1f5Y+Ay1uH4xoJ3L0r9zWXlKxAbJ2n/6RzFbf2taPt8aFh
# Gaf6Vqzvi3XavQ/P+pEXajO90qiRX8FXc8IluCX0AL9r5uRIJdjJIoskYrKekpJh
# 5uo7nekRGSzeTd8QHcgmjiLNfclcukPSPzeSMIAbIlHMBHpjJ6sqiFpMfM25d9py
# 6HdKzM5CZ2NOIvo0iU2ARpHh5OYpZU2uNIzEOnn40IGUV/hRQhu/kVj00hGr4CF+
# HcPgt3crhKcbojXnfNXYcuIisADCQAbIgcfhlkpQYAbhkMsRFhJvPcfXWmJXW0Js
# dd6hggIwMIICLAYJKoZIhvcNAQkGMYICHTCCAhkCAQEwgYYwcjELMAkGA1UEBhMC
# VVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQd3d3LmRpZ2ljZXJ0
# LmNvbTExMC8GA1UEAxMoRGlnaUNlcnQgU0hBMiBBc3N1cmVkIElEIFRpbWVzdGFt
# cGluZyBDQQIQDUJK4L46iP9gQCHOFADw3TANBglghkgBZQMEAgEFAKBpMBgGCSqG
# SIb3DQEJAzELBgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTIyMDEyNDE2NTkw
# NFowLwYJKoZIhvcNAQkEMSIEIJ+oLBZpk4FwKSyJTROLrZwfQ3loU4fsVlyQB8g7
# YOmnMA0GCSqGSIb3DQEBAQUABIIBADHTXfZzQPkCSCtUJS26/N8/GVR4k4Y3LeCQ
# iievM2LlwFTTNJykog7jwFd7LZtX7EuOTT72X9Ts3RwFCbHbX9y4Sz59caGIIOPC
# eU102QNcdIZbCj7ESz+B6d4xHhy9FNOVrjX/YpaY7rB5uplqi0mS+D/Qi7zovt8f
# kQngcZ/V3bVs+Cwbj0XrgxTcBaU8UxsQNLW4dslqNiHeRiRowKF7lJiJKNfJe81u
# gQ+A9YosJIQ9XJRWDQsgm5CfsxwQsOwovM17R4NulvCp0v7o2JzjafaHsJPxa976
# iwELVmZ6AZ3/L+FXg5eTy1rjtOY5kEDUp9OoVATcbVyRHsS1lDM=
# SIG # End signature block
