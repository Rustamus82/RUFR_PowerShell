<# 
.SYNOPSIS 
Viser informationer om Server / Arbejdsplads
Script opRettet Mikael Veistrup-Vetlov @ 20190410
Script Parametriseret & opdateret Mikael Veistrup-Vetlov @ 20210520

.DESCRIPTION 
Get-Ver.ps1 bruger INGEN argumenter, men viser informationer om lokal server / arbejdsstation

.EXAMPLE 
.\get-ver.ps1

.NOTES
.LINK
#> 

$Computer = "localhost" 
$Comp2 = "." 
$renv=Invoke-Command -ScriptBlock {Get-ChildItem env:} # -ComputerName $Comp2

#$pv=$PSVersionTable.PSVersion
$pv=Invoke-Command -ScriptBlock {$PSVersionTable.PSVersion} # -ComputerName $Comp2

#$ex=Get-ExecutionPolicy	# -list # -scope LocalMachine
$ex=Invoke-Command -ScriptBlock {Get-ExecutionPolicy} # -ComputerName $Comp2

Function Get-OSVersion{
$signature = @"
[DllImport("kernel32.dll")]
public static extern uint GetVersion();
"@
Add-Type -MemberDefinition $signature -Name "Win32OSVersion" -Namespace Win32Functions -PassThru
}

Function CheckPhysicalRam($Server)
{
    $PhysicalRAM = (Get-WMIObject -class Win32_PhysicalMemory -ComputerName $Server |Measure-Object -Property capacity -Sum | % {[Math]::Round(($_.sum / 1GB),2)})
    return $PhysicalRAM
 }
 
 Function CheckInstalledRam($Server) {
    $InstalledRAM = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $Server
    $InstalledRAM = [Math]::Round(($InstalledRAM.TotalPhysicalMemory/ 1GB))
    return $InstalledRam
}

Function CheckRam($Server) {
    $InstalledRAM = CheckInstalledRam($Server)
    $PhysicalRAM = CheckPhysicalRam($Server)
    if ($PhysicalRAM -eq $InstalledRAM)
    {
        return "pass"
    }
    Else
    {
        return "fail"
    }
}

$os = [System.BitConverter]::GetBytes((Get-OSVersion)::GetVersion())
$majorVersion = $os[0]
$minorVersion = $os[1]
$build = [byte]$os[2],[byte]$os[3]
$buildNumber = [System.BitConverter]::ToInt16($build,0)
# Virker, "Windows Version is {0}.{1} build {2}" -F $majorVersion,$minorVersion,$buildNumber

$wver=(Get-CimInstance Win32_OperatingSystem).version
$tlogp=(Get-CimInstance Win32_ComputerSystem).NumberOfLogicalProcessors
$wb=$wver.Split(".")[-1]
$wv=$wver.Split(".")[0,1] -join(".")

#$ri.ReleaseId
$IsAdm=[bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544")
If ($IsAdm) {$wadm='- Administrator'}else{$wadm=''}

$phr=CheckPhysicalRam $Comp2
$inr=CheckInstalledRam $Computer

#CheckRam $Computer

$bios = Get-WmiObject –class Win32_BIOS –computername $computer
$os = Gwmi win32_operatingsystem -cn $computer
$ostype=('xx','Work Station','Domain Controller','NonDC Server')
$mem = get-wmiobject Win32_ComputerSystem -cn $computer | select @{name="PhysicalMemory";Expression={"{0:N2}" -f($_.TotalPhysicalMemory/1gb).tostring("N0")}},NumberOfProcessors,Name,Model
$cpuinfo = "numberOfCores","NumberOfLogicalProcessors"  #,"maxclockspeed","addressWidth"
$cpudata = Get-WmiObject -class win32_processor –computername $computer -Property $cpuinfo | Select-Object -Property $cpuinfo
$cpuNo = Get-WmiObject -class win32_processor –computername $computer -Property "numberOfCores","NumberOfLogicalProcessors" 
$phyv = Get-WmiObject win32_bIOS -computer $computer | select serialnumber
$res = "Physical” # Assume "physical machine" unless resource has "vmware" in the value or a "dash" in the serial #                 
if ($phyv -like "*-*" -or $phyv -like "*VM*" -or $phyv -like "*vm*") { $res = "Virtual" } # else
$Networks = gwmi Win32_NetworkAdapterConfiguration -ComputerName $computer | ? {$_.IPEnabled}
foreach ($Network in $Networks) {[string[]]$IPAddress += ("[" + $Network.IpAddress[0] + " " + $Network.MACAddress + "]")}
$ActiveIPs = $IPAddress
$Networks = gwmi -ComputerName $computer win32_networkadapter | where-object { $_.physicaladapter }
foreach ($Network in $Networks) {
	#if ({$_.$Network.MACAddress}) {[string[]]$MACinfo += "#" + $Network.DeviceID + "-" + $Network.MACAddress} else {[string[]]$MACinfo += "#" + $Network.DeviceID + "-Dis"}
	[string[]]$MACinfo += "#" + $Network.DeviceID + "-" + $Network.MACAddress
}
$nc=$nlp=0
Foreach($c in $cpuNo){
	$nc+=$c.numberOfCores
	$nlp+=$c.NumberOfLogicalProcessors
}
If($env:Logonserver.length -eq 0) {
	$logs="Guest login to ";$logd="<From other AD>"
}else{
	$logs=$env:Logonserver;$logd=$env:USERDNSDOMAIN
}
$Out1="PC Name: {1}.{2} ({3}) 
PC - Server type: {0} 
ip/mac: {4}" -f $ostype[$os.ProductType],$env:COMPUTERNAME,$logd,$res,$ActiveIPs[0]

$Out2="Logonserver: {0}.{1} 
User: {2} 
Physical_Ram: {3} Installed_Ram: {4} #Cpu: {5} #logicalPRocessors: {6} " -f $logs,$env:userdnsdomain,$env:username,$phr,$inr,$nc,$nlp
If($os.ProductType -eq 1) {
	$ri=Get-ItemProperty -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\" -Name ReleaseId
	$Out3="Windows {1} Version {0} ( OS build {2})" -F $ri.ReleaseId,$wv,$wb
}else{
	$Out3="Windows Version is {0}.{1} build {2} - {3}" -F $majorVersion,$minorVersion,$buildNumber,($os.name -split("\|"))[0]
}
$rc=Get-ItemProperty -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\" -Name InstallationType
$Out4=$rc.InstallationType

$Out5="Powershell {3} '{0}' Version: {1}.{2}" -F $ex,$pv.Major,$pv.Minor,$wadm
If ((Get-WmiObject -Namespace "root\CIMV2\TerminalServices" -Class "Win32_TerminalServiceSetting" -ComputerName $Computer).TerminalServerMode -eq "1") {
15
	$TerminalServerMode="Enabled"
}Else{
	$TerminalServerMode="Disabled"
}	
#$nlp
#$nlp2= $cpudata.NumberOfLogicalProcessors|Measure-Object -sum
#$nlp2.sum
#write-Host $Out1
#write-Host $Out2
#write-Host $Out3
#write-Host $Out4
#write-Host $Out5
#
$obj = New-Object –typename PSObject
$obj | Add-Member –membertype NoteProperty –name ComputerNavn –value ($env:COMPUTERNAME+"."+$logd) –PassThru |
	Add-Member –membertype NoteProperty –name Hardware –value ($res) -PassThru |
	Add-Member –membertype NoteProperty –name OperatingSystem –value ($os.Caption) -PassThru |
	Add-Member –membertype NoteProperty –name WinVersion -value ($Out3) -PassThru |
	Add-Member –membertype NoteProperty –name ServicePack –value ($os.ServicePackMajorVersion) -PassThru |
	Add-Member –membertype NoteProperty –name ServerType -value ($ostype[$os.ProductType]) -PassThru |
	Add-Member –membertype NoteProperty –name InstalType -value ($Out4) -PassThru |
	Add-Member –membertype NoteProperty –name TerminalServerMode -value ($TerminalServerMode) -PassThru |
	Add-Member –membertype NoteProperty –name ExecutionPolicy -value ($ex) -PassThru |
	Add-Member –membertype NoteProperty –name PowershellVer -value ($Out5) -PassThru |
	Add-Member –membertype NoteProperty –name Logonserver -value ($logs+"."+$logd) -PassThru |
	Add-Member –membertype NoteProperty –name LoggedOnUser -value ($env:username) -PassThru |
	Add-Member –membertype NoteProperty –name "PhysicalMemory(GB)" –value ($mem.PhysicalMemory) -PassThru |
	Add-Member –membertype NoteProperty –name Processors –value ($mem.numberofprocessors)  -PassThru |
	Add-Member –membertype NoteProperty –name noOfCores –value ($cpudata.numberOfCores) -PassThru |
	Add-Member –membertype NoteProperty –name NoOfLogProcs –value ($cpudata.NumberOfLogicalProcessors) -PassThru |
	Add-Member –membertype NoteProperty –name TotalLogProcs –value ($nlp) -PassThru |
	Add-Member –membertype NoteProperty –name TotalLogProcCim –value ($tlogp) -PassThru |
	Add-Member –membertype NoteProperty –name IPAddress –value ($ActiveIPs) -PassThru  |
	Add-Member –membertype NoteProperty –name NICs –value ($MACinfo) -PassThru |
	Add-Member –membertype NoteProperty –name Serial -value ($phyv)
Write-Output $obj

# SIG # Begin signature block
# MIIdAgYJKoZIhvcNAQcCoIIc8zCCHO8CAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCAiJ9KANDV28zyO
# H+XLoF/eqd8hUMkTDvzcJbhJHOiDlqCCGBMwggT+MIID5qADAgECAhANQkrgvjqI
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
# MAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEIFmOH4IUzLlUdE243I+CZcYu
# 20qP7Fi7VspTPzGU3Vf+MA0GCSqGSIb3DQEBAQUABIIBAGHpVrUYmv0V9gVrSL58
# 0of49CGDqIXBpASS7KL8PwGtbW38FhMtdneM+sMc3g23IXRtW94lKYshD7EIM/MW
# dLLxWzohKzVKaaFdd57ODmfycBAbpk2EGIrkine+GtMf4mBMHr4eYeJLeSeqq4+W
# eQlZsB2GulHH9LM6GqhFBnWW3KR6eAVK7+mnlsEDh0ulej1ntZ+/4I85ZPdB4kDJ
# VOVGwfGTXfc/bmujMZ3mWOUGQ0ugp30f9ATDSHqzhMUmEKtFtZhd6ZPFOQVhX28U
# W7HgH/wJTRRKcqiOZkwe2Iw4UDr0xlBhwxybujqJjPbBx7hFC4KAQhIk2ZbvOnD7
# +NihggIwMIICLAYJKoZIhvcNAQkGMYICHTCCAhkCAQEwgYYwcjELMAkGA1UEBhMC
# VVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQd3d3LmRpZ2ljZXJ0
# LmNvbTExMC8GA1UEAxMoRGlnaUNlcnQgU0hBMiBBc3N1cmVkIElEIFRpbWVzdGFt
# cGluZyBDQQIQDUJK4L46iP9gQCHOFADw3TANBglghkgBZQMEAgEFAKBpMBgGCSqG
# SIb3DQEJAzELBgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTIxMDcxMjA3Mzg0
# MVowLwYJKoZIhvcNAQkEMSIEIDMLUxPRQdvJ8/1jkynJSOhedBgu24Aa03LSOHxr
# mriwMA0GCSqGSIb3DQEBAQUABIIBAHLU5+rX4q2MBm4GH5Z7R8SBiJXH5iwvRV8C
# e8Jqtx5qyKRYCWIdIjf72eeNCEPanhTqZs+j0RA6VFfd3qCJaZCOff3PiA3aDx9Y
# VceSn41hDA+DU/GQR+zLc5reQNrUV1/eaWP4XMR3hPHpcZUfTxwqEMCyZysaWsUN
# 3rC7odbEkEwoGYchRGz/WKJFJCT3prO51Ifs+O4vT7ZofwR3KnV2IdsKcVAmTqgH
# 1JmmMRh9mUfmUt+jxxqK2BexJ5V7foWAEqa6N2X0D4/gw3mfurfWmnQFTrOktxa8
# I+4Bh9EJ+eM5Z16AveGiBBz1+RG2K9HdJDs15cb4ShKupLcO7Ew=
# SIG # End signature block
