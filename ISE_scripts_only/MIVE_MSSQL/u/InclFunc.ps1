# File to include Powershell functions / Modules for reuse
# set-ExecutionPolicy Bypass		# evt for at måtte
# Function module File to include	#$FincPath="p:\sqldba\ps1\u\inclFunc.ps1"
$FincPath="p:\Miveps1\u\inclFunc.ps1"
If (test-path $FincPath){
#. $FincPath				# fjern "#" først på linien for at bruge i .ps1
}
# Get-EgoVar


# No powershell function for testing if value numeric exists, This returns true if numeric, else false
Function Is-Num([string]$i1){
$Sub="Is-Num"
[bool]$r=0
If($i1.length -lt1){return $r}
trap {return $r}
$r=$i1/1
$r=1
Return $r
}

Function Get-EgoVar {
# udførende jobnavn: giver variable disk, sti, fil Kan ikke være aktiv i include fil, da det vil være denne fil der registreres
#$Global:EgoCmd=$PSCommandPath -Split("\\")     # $Global:EgoCmd= 'z:','ps1','2016','Set-2016Sp2.ps1'
#$Global:Egodisk=$Global:EgoCmd[0]
#$Global:Egofil=$Global:EgoCmd[-1]
#If($Global:EgoCmd.Count -lt 3){$Global:Egosti=''}elseif($Global:EgoCmd.Count -eq 3){$Global:Egosti=$Global:EgoCmd[1]}else{$h1=$Global:EgoCmd[1..($Global:EgoCmd.Count-2)];$Global:Egosti=$h1 -join("\")}
#$Global:WrToFile=(($Global:EgoCmd -Join("\")) -Replace("\.ps1",".log"))
#if (Test-Path $Global:WrToFile) {Remove-Item $Global:WrToFile}
#if (Test-Path $Global:WrToFile) {Notepad $Global:WrToFile}


$Global:EgoDomain=$env:userdnsdomain
$Global:EgoDomainbs=$Global:EgoDomain+"\\"
$Global:EgoShort = $Global:EgoServer = $env:computername  #Henter fra lokale envirnment variable
$Global:EgoUser=$env:username
$Global:EgoDato=Get-Date -format yyyyMMdd
$Global:EgoAd=@()
$Global:EgoAd+="dksund.dk","ssi.ad","sst.dk","sdsp.dk","intdmz.dk","pubdmz.dk","ssidmz01.local","imkit.dk","nsidsdn.dk","dksundtest.dk"
$Global:EgoSqlAd=@()
$Global:EgoSqlAd+="dksund","ssi","sst.dk","sdsp","intdmz","pubdmz","ssidmz01","imkit","nsidsdn","dksundtest"
$Global:EgoAds=@()
$Global:EgoAds+="dks","ssi","sst","sdp","idz","pdz","ssz","imk","nsi","dkt"
$Global:EgoAda=@()
$Global:EgoAda+="l-ORG-MSSQL-Sysadmin","MSSQLServerAdms","MSSQLServerAdms","l-ORG-MSSQL-Sysadmin","l-ORG-MSSQL-Sysadmin","l-ORG-MSSQL-Sysadmin","l-ORG-MSSQL-Sysadmin","l-ORG-MSSQL-Sysadmin","l-ORG-MSSQL-Sysadmin","l-ORG-MSSQL-Sysadmin"
$Global:EgoAdP=@()
$Global:EgoAdP+="OU=MSSQL,OU=T2Groups,OU=Tier2,DC=dksund,DC=dk","OU=MSSQL,OU=T2Groups,OU=Tier2,DC=ssi,DC=ad","OU=MSSQL,OU=T2Groups,OU=Tier2,DC=sst,DC=dk","sdp","OU=MSSQL,OU=T2Groups,OU=Tier2,DC=intdmz,DC=dk","OU=MSSQL,OU=T2Groups,OU=Tier2,DC=pubdmz,DC=dk","OU=MSSQL,OU=T2Groups,OU=Tier2,DC=ssidmz01,DC=local","OU=MSSQL,OU=T2Groups,OU=Tier2,DC=imkit,DC=dk","OU=MSSQL,OU=T2Groups,OU=Tier2,DC=nsidsddn,DC=dk","OU=MSSQL,OU=T2Groups,OU=Tier2,DC=dksundtest,DC=dk"
# Domain controllers
$Global:EgoDC=@()
$Global:EgoDC+="S-AD-DC-02P.dksund.dk","S-DC10-p.ssi.ad","s-dc21-p.sst.dk","","idmzdc03.intdmz.dk","pdmzdc02.pubdmz.dk","srv-ad-dmzdc02.ssidmz01.local","S-IMKIT-DC-01P.IMKIT.DK","srv-ad-dc02.nsidsdn.dk","s-ad-dc-01t.dksundtest.dk"
$Global:EgoAdNr=-1		# giver domain nr i $Global:EgoAd
For ($i=0;$i -lt $Global:EgoAd.count;$i++){If ($Global:EgoAd[$i] -eq $Global:EgoDomain) {$Global:EgoAdNr=$i}}
$Global:EgoOs = Gwmi win32_operatingsystem -cn $Global:EgoServer                               # Henter fra Get-WmiObject
$Global:EgoCore=(Get-ItemProperty -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\" -Name InstallationType).InstallationType
$EgoArr=(($Global:EgoOs.name -split("\|"))[0]) -split(" ");foreach($EgoI in $EgoArr){If (Is-Num $EgoI) {$Global:EgoWin=$EgoI}}
If ($Global:EgoShort.Length -gt $Global:EgoDomainbs.length){If ($Global:EgoShort -match $Global:EgoDomainbs){$Global:EgoShort=$Global:EgoShort -Replace($Global:EgoDomainbs,"")}}   
If ($Global:EgoShort.Length -gt 5){If ($Global:EgoShort -match "\$"){$Global:EgoShort=$Global:EgoShort -Replace("\$","")}}   
If ($Global:EgoShort.Length -gt 5){If ($Global:EgoShort -match "mssql"){$Global:EgoShort=$Global:EgoShort -Replace("mssql","")}}   
If ($Global:EgoShort.Length -gt 5){If ($Global:EgoShort -match "sql"){$Global:EgoShort=$Global:EgoShort -Replace("sql","")}}   
If ($Global:EgoShort.Length -gt 5){If ($Global:EgoShort -match "db"){$Global:EgoShort=$Global:EgoShort -Replace("db","")}}   
If ($Global:EgoShort.Substring(0,2) -eq "s-"){$Global:EgoShort=$Global:EgoShort.Substring(2,$Global:EgoShort.length-2)}
$Global:EgoShort=$Global:EgoShort -Replace("-","")
$Global:EgoSrcDC=$Global:EgoDC[$Global:EgoAdNr]
$Global:EgoCrLf="`r`n"                            	# Simpel tekst =cariageReturn & Newline
$Global:EgoHtmlCrLf="<br>"
}

$Global:EgoIsAdm=[bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544")

Function Skriv-Fil {
	param()
	$Sub="Skriv-Fil"
	$PrtLin=[string]::join(' ', $args)
	If($WrToFile -eq "0"){
		Write-Host  $PrtLin
	}elseIf($WrToFile -eq "SQL"){
		Write-Output  $PrtLin
	}else{
		Out-File -literalpath $WrToFile -InputObject $prtLin  -Append
	}
}

Function Skriv-Echo {
	param()
	$Sub="Skriv-Echo"
	$PrtLin=[string]::join(' ', $args)
	Write-Host  $PrtLin
	Skriv-Fil  $PrtLin
}

function ExitWithCode {
    param (
        $exitcode
    )
    $host.SetShouldExit($exitcode)
    exit
}

# Viser parametre og info om Programmet
Function Vis-Help {
	Param (
		[String]$sh_pnavn
		,[String[]]$sh_HelpLines
	)
	Write-Host "Du har kaldt $sh_pnavn uden korrekte parametre! "
	If ($sh_HelpLines.count -gt 0){
		Foreach ($s in $sh_HelpLines){
			Write-Host $s
		}
	}
}

function Encode-HTMLSpCh ([string]$Streng){
	$Streng = $Streng.Replace("æ", "&#230;");
	#$Streng = $Streng.Replace("æ", "&aelig;");
	$Streng = $Streng.Replace("ø", "&oslash;");
	$Streng = $Streng.Replace("å", "&aring;");
	$Streng = $Streng.Replace("Æ", "&AElig;");
	$Streng = $Streng.Replace("Ø", "&Oslash;");
	$Streng = $Streng.Replace("Å", "&Aring;");
	return $Streng
} # function Encode-HTMLSpCh

Function Get-Rndpw($wp2){
if ($wp2 -eq "?"){Write-output "Angiver et random password, -wp2 længden af password hvis ikke default 16 char.";Return}
If (!(Is-Num $wp2)) {$wp2 = 16}
$w= ([char[]]([char]'a'..[char]'z'))
$w+=(0..9)
$w+=('§ ! @ £ ¤ % & = ? + - _').Split(" ")
$w+=([char[]]([char]'A'..[char]'Z'))
Write-host $wp2
$wpas= Get-Random -count $wp2 -InputObject ($w)
$wp=$wpas -join('')
Return $wp
}

Function Get-FireWallRule
{Param ($Name, $Direction, $Enabled, $Protocol, $profile, $action, $grouping)
$Rules=(New-object –comObject HNetCfg.FwPolicy2).rules
If ($name)      {$rules= $rules | where-object {$_.name     -like $name}}
If ($direction) {$rules= $rules | where-object {$_.direction  -eq $direction}}
If ($Enabled)   {$rules= $rules | where-object {$_.Enabled    -eq $Enabled}}
If ($protocol)  {$rules= $rules | where-object {$_.protocol   -eq $protocol}}
If ($profile)   {$rules= $rules | where-object {$_.Profiles -bAND $profile}}
If ($Action)    {$rules= $rules | where-object {$_.Action     -eq $Action}}
If ($Grouping)  {$rules= $rules | where-object {$_.Grouping -like $Grouping}}
$rules}

Function Make-AdServAcc {  
Param (
	[String]$acc
	,[String]$descr
	,[String]$Ad=$EgoAd[0]
	,[String]$Dc=$EgoDC[0]
	,[String]$AdPath=$EgoAdP[0]
	)
$pw=Get-Rndpw
$pw+=Get-Rndpw
$pws = $pw | ConvertTo-SecureString -asPlainText -Force

Write-Host "Vil du oprette Servicekonto: $acc descr: $descr " 
$svar=Read-Host "i domain: $Ad ou: $AdPath ?"
If (!($svar -in 'ja','j','J','y','Y','yes')) {Return -1}
$accParm=[ordered]@{
				Name        = $acc
				DisplayName = $acc
				UserPrincipalName = $acc+"@"+$Ad
				AccountPassword = $pws
				PasswordNeverExpires = $true
				CannotChangePassword = $true
				samaccountname  = $acc
				Path  =$AdPath
				Server = $Dc
				Enabled = $true
			}

NEW-ADUser  @AccParm     
Skriv-Fil "User: $acc"
Skriv-Fil "Password: $pw"
Skriv-Fil "Beskrivelse: $descr"
Skriv-Fil "Secret:  $Ad\$acc"
Skriv-Fil "Husk at gemme Service konto og password i Secretserver"
Skriv-Fil "$acc@dksund.dk"
Skriv-Fil "$descr"
Skriv-Fil "dksund.dk"
Skriv-Fil '<Link$$>'
Skriv-Fil "<system>"
Skriv-Fil "SD <sdnr>"
Skriv-Fil ""
}

#IF  EXISTS (SELECT * FROM sys.server_principals WHERE name = N'SQLDBACOLL') DROP LOGIN [SQLDBACOLL];
#CREATE LOGIN [SQLDBACOLL] WITH PASSWORD=N'DBA_DB2018!start', DEFAULT_DATABASE=[DBA_DB], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF;

Function Make-SQLServAcc {  
Param (
	[String]$acc
	,[String]$descr
	,[String]$Ad=$EgoAd[0]
	,[String]$Dc=$EgoDC[0]
	,[String]$AdPath=$EgoAdP[0]
	)
$pw=Get-Rndpw
$pw+=Get-Rndpw
$pws = $pw | ConvertTo-SecureString -asPlainText -Force

Write-Host "Vil du oprette Servicekonto: $acc descr: $descr " 
$svar=Read-Host "i domain: $Ad ou: $AdPath ?"
If (!($svar -in 'ja','j','J','y','Y','yes')) {Return -1}
$accParm=[ordered]@{
				Name        = $acc
				DisplayName = $acc
				UserPrincipalName = $acc+"@"+$Ad
				AccountPassword = $pws
				PasswordNeverExpires = $true
				CannotChangePassword = $true
				samaccountname  = $acc
				Path  =$AdPath
				Server = $Dc
				Enabled = $true
			}

NEW-ADUser  @AccParm     
Skriv-Fil "User: $acc"
Skriv-Fil "Password: $pw"
Skriv-Fil "Beskrivelse: $descr"
Skriv-Fil "Secret:  $Ad\$acc"
Skriv-Fil "Husk at gemme Service konto og password i Secretserver"
Skriv-Fil "$acc@dksund.dk"
Skriv-Fil "$descr"
Skriv-Fil "dksund.dk"
Skriv-Fil '<Link$$>'
Skriv-Fil "<system>"
Skriv-Fil "SD <sdnr>"
Skriv-Fil ""
}



Function Add-User2Group {  
Param (
	[String]$acc
	,[String]$Group
	)

$svar=Read-Host "Vil du Tilføje brugerkonto: $acc til gruppe: $Group ?"
If (!($svar -in 'ja','j','J','y','Y','yes')) {Return -1}

Add-ADGroupMember -identity $Group -members $acc -server $EgoSrcDC
Skriv-Fil "Bruger: $acc meldt ind i gruppe: $group"
Skriv-Fil ""
}

Function Slet-User2Group {  
Param (
	[String]$acc
	,[String]$Group
	)

$svar=Read-Host "Vil du Fjerne brugerkonto: $acc fra gruppe: $Group ?"
If (!($svar -in 'ja','j','J','y','Y','yes')) {Return -1}

Remove-ADGroupMember -Identity $Group -Members $acc -server $EgoSrcDC -Confirm:$false
Skriv-Fil "Bruger: $acc fjernet fra gruppe: $group"
Skriv-Fil ""
}


# Sum of ip-address for sorting & comparing.
Function Sum-Ip([string]$i1){
$Sub="Sum-Ip"
[long]$r=0
If ($i1 -match "\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}") {
	$a=$i1.split(".")
	[int]$b0=$a[0]
	[int]$b1=$a[1]
	[int]$b2=$a[2]
	[int]$b3=$a[3]
	$r=(($b0*256+$b1)*256+$b2)*256+$b3
	}
Return $r
}

Function Is-AdGroup ([String]$gl){
If(!($gl.length -gt 3)){ Return -1}
Return (Get-ADGroup -LDAPFilter "(SAMAccountName=$gl)" -server $EgoSrcDC).name.count
}

Function Hent-AdGroup ([String]$gl){
If(!($gl.length -gt 3)){ Return -1}
Return (Get-ADGroup -LDAPFilter "(SAMAccountName=$gl)" -server $EgoSrcDC)
}

Function Is-AdUser ([String]$gl){
If(!($gl.length -gt 1)){ Return -1}
Return (Get-ADUser -LDAPFilter "(SAMAccountName=$gl)" -server $EgoSrcDC).name.count
}

Function Hent-AdUser ([String]$gl){
If(!($gl.length -gt 1)){ Return -1}
Return (Get-ADUser -LDAPFilter "(SAMAccountName=$gl)" -server $EgoSrcDC)
}

Function Skriv-Hash {
    param(
        [hashtable]$pss
		)
	$message =@()
	foreach($key in $pss.keys){
		$v1=$pss[$key]
		$t1=$key.GetType().name
		If ($pss[$key] -is [System.Collections.IDictionary]){$v1=$pss[$key].GetType().name}
		If ($key.GetType().isarray){$v1 = "[Array]"}
		$message += 'Param {0} af typen {2} har værdien {1} ' -f $key, $v1, $t1
		If ($key.GetType().isarray){Write-Output $pss[$key]}
		If (($pss[$key] -is [System.Collections.IDictionary]) -or ($pss[$key] -is [System.Collections.Hashtable]) -or ($pss[$key] -is [System.Collections.Specialized.OrderedDictionary])){
			$w1=$pss[$key]
			Foreach($k1 in $w1.keys){
				$v2=$pss[$k1]
				$t2=$k1.GetType().name
				If ($pss[$k1] -is [System.Collections.IDictionary]){$v2=$pss[$k1].GetType().name}
				If ($k1.GetType().isarray){$v2 = "[Array]"}
				$message += 'Param {3} Subparm {0} af typen {2} har værdien {1} ' -f $k1, $w1[$k1], $t2,$Key
			}
		}
	}
	Return $message
}

Function SQL-Info{
  $r=[ordered]@{}
  $r1="HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\"
  foreach($v in ("160","150","140","130","120","110","100","90")) {
	if (test-path "$r1$v\Machin*"){$r.SQLnr=$v
	  $r.SQLServer=(Get-ItemProperty "$r1$v\Machines").OriginalMachineName
      $r.SQLver=(Get-Item "$r1$v\sql*").PSChildName
	}
  }
  If(!(($r.SQLnr).length -gt 0)){$r.SQLver="n/a";Return $r}
  $r2=Get-Item $r1"Instance Names\*"
  $r3=Get-ItemProperty $r1"Instance Names\*"
  $r.SQLtype=$r2.PSChildName
  Foreach($r0 in $r2.Property){
    $r.SQLInstance+=$r0+","
    $r.SQLinstName+=$r3.($r0)+","
  }
  $r.SQLInstance=$r0=($r.SQLInstance).trim(",")
  $r.SQLinstName=$v=($r.SQLinstName).trim(",")
  $r0=$r1+$r.SQLinstName+"\"+$r.SQLInstance
  if (test-path "$r0\*"){
	  $r.DefaultLog=(Get-ItemProperty "$r0").DefaultLog
	  $r.DefaultData=(Get-ItemProperty "$r0").DefaultData
	  $r.BackupDirectory=(Get-ItemProperty "$r0").BackupDirectory
  }
  Return $r
}

Function Call-SQL {   # hvis den skal bruges indeni et script
Param (
	[String]$SqlDb="master"
	,[String]$SQLcmd="SELECT @@Servername as Servername,@@VERSION AS SQLVersion"
	,[String]$server="."
	,[String]$Instance
    ,[String]$sqlpw
    ,[String]$sqlport
	)
If($server -eq "."){ $server="(local)"}			# localhost skal angives som (local)
$ego=$server.Split("\")[0]
If($server -like ".\*"){ $ego="(local)"}			# localhost 
If($server -like "$EgoServer*"){ $ego="(local)"}	# localhost 
If($server -like "localh*"){ $ego="(local)"}	# localhost 
If($server.Contains("\")){							# instance in servername
	$ego+="\"
	$ego+=$server.Split("\")[1]					# Instance
} else{													# not 2 instance names
	If($Instance.Length -gt 0){
		If($Instance -ne 'MSSQLSERVER'){ 					
			$ego+="\"
			$ego+=$Instance.Trim()
		}
	}
}
$uid="SQLDBACOLL"
$server=$ego
If($sqlport.Length -gt 0) {
    $server+=','
    $server+=$sqlport
}
	invoke-sqlcmd
    $rc=$error.Clear()
    If ($sqlpw.Length -gt 0){
	    $ConnStr = "Server=$server;Database=$SqlDb;User ID=$uid;Password=$sqlpw"
    }else{
	    $ConnStr = "Server=$server;Database=$SqlDb;Integrated Security=True"
    }
	$SqlConn = New-Object System.Data.SqlClient.SqlConnection($ConnStr)
	Try{
	$SqlSrv = New-Object Microsoft.SqlServer.Management.Smo.Server($SqlConn)
	}Catch{
		#.\Is-SQL.ps1
		invoke-sqlcmd
		$SqlSrv = New-Object Microsoft.SqlServer.Management.Smo.Server($SqlConn)
	}

	# variable with result of sql call
	Try{
		$SqlTable = $SqlSrv.Databases["$SqlDb"].ExecuteWithResults($SQLcmd).Tables[0]
	}Catch{
		write-host $error[0]
		$SqlTable= $false
	}Finally{
		# Clean up, and close connection
		$SqlConn.Close()
	}
	Return $SqlTable #viser hele svar på parent
} # Function Call-SQL

Function Skriv-Acl {  
Param (
	[String]$Dest="<dest>"
	,[String]$Account="user"
	,[String]$Rights="r"
	)
	If (!(Test-Path $Dest)){Return "0 Ukendt Destination"}
	If ($Account.Contains("@")){Return "0 Brug dksund\<bruger> ikke snabel@"}
	If ($Rights.Substring(0,1) -eq "f"){$Rights="FullControl"
	}ElseIf ($Rights.Substring(0,1) -eq "r"){$Rights="ReadAndExecute"
	}ElseIf ($Rights.Substring(0,1) -eq "m"){$Rights="Modify"
	}ElseIf ($Rights.Substring(0,1) -eq "d"){$Rights="Delete"
	}Else{Return "0 Ukendt Rettighed"}
    $Acl = Get-Acl "$Dest"
	If($Rights -eq "Delete"){
		$AcR = $Acl.Access | ?{ $_.IsInherited -eq $false -and  $_.IdentityReference -eq $Account }
		If($acr.IdentityReference.count -gt 0){$acl.RemoveAccessRuleAll($AcR)}
		"slettet"
	}ElseIf($Dest.Substring(1,1) -eq ":"){
    $Ar = New-Object  system.security.accesscontrol.filesystemaccessrule("$Account","$Rights","Allow")
    $Acl.SetAccessRule($Ar)
    }Elseif($Dest.Substring(0,4) -in 'hklm','hkcu'){
    $Ar = New-Object  System.Security.AccessControl.RegistryAccessRule ("$Account","Rights","Allow")
    $Acl.SetAccessRule($Ar)
	}Else{Return "0 Ukorrekt Destination"}
    Set-Acl "$Dest" $Acl
    Return Get-Acl "$Dest"|fl
}

#eksempler
#$vrøvle="vrøvl"
#$indhold="Dette er noget {0} {1}!" -f $vrøvle,"basta"

Write-Host "InclFunc.ps1 loaded"
# SIG # Begin signature block
# MIIdAgYJKoZIhvcNAQcCoIIc8zCCHO8CAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCAGClSVKB3vFdCR
# 1UzCb/ldgxl/TgEuQvpcg38RmIwbLKCCGBMwggT+MIID5qADAgECAhANQkrgvjqI
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
# MAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEIE9BC8gwPejDsYLVUzn8noo7
# yb79QaBdx+5SziWOqkbhMA0GCSqGSIb3DQEBAQUABIIBAN7egvRvDMhPlTtv47Rz
# AjwQiuHQ/qGzefxm9dbVWxpL40uK+tryt6bbx285dNIEXB5KTmsa6fO+oxEUpZqH
# x/+EgCsaw+rZEAYgDKugmOk/COxqgJUvTKF9DERGNzPJY0kaVOjRSVwaGfcNCDW3
# 3Z3+KQUlfPOlheYkI3x732EfeH83kCQzNvX3dxvyVsXM3Q1timaLqVAstTvavQiC
# gIWjGxjFtHk1qLvTnrLWC4OOsAP+Rt2qLmg4ctpmrxM0XQl5DFY0aQQTVHLJnuQ7
# mrySS4PD2Zp+wIFCXZRCVa72u2WDz6qlRj/+BR+udeMQRjnnlbUJm5Wi/lgluwtH
# /X+hggIwMIICLAYJKoZIhvcNAQkGMYICHTCCAhkCAQEwgYYwcjELMAkGA1UEBhMC
# VVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQd3d3LmRpZ2ljZXJ0
# LmNvbTExMC8GA1UEAxMoRGlnaUNlcnQgU0hBMiBBc3N1cmVkIElEIFRpbWVzdGFt
# cGluZyBDQQIQDUJK4L46iP9gQCHOFADw3TANBglghkgBZQMEAgEFAKBpMBgGCSqG
# SIb3DQEJAzELBgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTIxMDkyMTEyNTk0
# NFowLwYJKoZIhvcNAQkEMSIEIKu/AhyZ4Dyc3a5shZ4Ryzgk8/JzsVBo9/ZwgnPM
# /Z9OMA0GCSqGSIb3DQEBAQUABIIBALGCZAMsdHbYoRLy8A9ZkofREIJp4nDJkJWt
# iEi2KQxT0RpGWltFL0aljen2gsiJaOj9YrIpr+lzikv8fpcMRM6fnv/ImRP/xR34
# QAEks2lMnZVJNmjOfgv+VOXjwdTAxiEPg/e0EPLOAka169aoVrzaxYhmnq7MPZaO
# 29dTCe07E4tsQhJwmhucCnhmGvazwHGlNVYQuiWJ+aTWnoYqjCiZ7K6J3sjh1xXB
# 5xH7VzRIqmGPeb+DFpJ7DSIJ2kzukKIsY2e0k1EtoMH21Gpjz1XVeMBdJiFpOaJu
# WpjgqsOMvX2UqwjWaSHax+u/qVVahL9imw0qX5F/A+fHxb56DA4=
# SIG # End signature block
