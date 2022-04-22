<# 
.SYNOPSIS 
Kalder SQL server med t-sql Statement og afleverer svar.
Script opdateret Mikael Veistrup-Vetlov @ 20210506
Script oprettet Mikael Veistrup-Vetlov @ 20210909

.Parameter DataBase 
Call-SQL.ps1 bruger argument <-DataBase> for at angive hvilken database der skal forespørges imod

.Parameter Kommando
Angiv <-Kommando> for at udføre en T-SQL kommand i (dobbelt) citationstegn "

.Parameter Server 
Hvis kommandoen ikke skal udføres på den server man er på, kan man angive et servernavn <-Server>
Standardværdien er lokal serveren,

.Parameter Instans 
Hvis der er en speciel SQL-Instans på serveren kan denne angives her: <-Instans>
Ved Standardværdien MSSQLSERVER kan parametren udelades.

.Parameter Sqlport 
Hvis der er opsat  en speciel SQL-port for at tilgå serveren kan denne angives her: <-Sqlport>
Ved SQL Standard porten 1433 kan parametren udelades.

.DESCRIPTION 
Man kalder Call-SQL.ps1 med T-sql kaldet <-Kommando> og man kan angive en <-Server> <-Instans> og <-DataBase>
for at uspecificere hvilken database i hvilken instans på hvilken server men vil forespørge.

.EXAMPLE 
.\Call-SQL.ps1 -Kommando info
Giver kort information om serveren.
.EXAMPLE 
.\Call-SQL.ps1 -DataBase "master" -Kommando "SELECT @@Servername as Servername,@@VERSION AS SQLVersion"
for at se servernavn og version på den lokale server.
.EXAMPLE 
.\Call-SQL.ps1 -DataBase "Dba_DB" -Kommando "select * from sys.tables" -Server s-mssql01-t.dksund.dk -Instans devl
lister tabeller i Dba_db databasen på s-mssql01-t.dksund.dk\devl sql-instansen
.EXAMPLE 
.\Call-SQL.ps1 -Kommando "select name from sys.sysdatabases" -Server s-mssql01-t.dksund.dk -Instans devl
Lister databaser fra sql-instansen - hvis den findes
.EXAMPLE 
.\call-Sql.ps1 -Server s-mssql-db-03p -Instans specimengate -sqlport 2433
Viser navn og sql version af server med speciel instansnavn & speciel tcp-port
#> 

   # [CmdletBinding()] 
    Param (
	[Parameter(Mandatory=$false, Position=0, ValueFromPipelineByPropertyName,
		HelpMessage="Angiv database der skal forespørges imod.")] 
		[Alias("SqlDb")]
		[string]$DataBase ="master"
	,[Parameter(Mandatory=$false, Position=1, ValueFromPipelineByPropertyName,
		HelpMessage="Angiv T-SQL forespørgslen.")] 
		[Alias("cmd","SQLcmd")] 
		[string]$Kommando="SELECT @@Servername as Servername,@@VERSION AS SQLVersion"
        ,[Parameter(Mandatory=$false, Position=2, ValueFromPipelineByPropertyName,
		HelpMessage="Angiv Server med SQL installeret. ")] 
		[AllowNull()]
		[string]$Server="(local)"
        ,[Parameter(Mandatory=$false, Position=3, ValueFromPipelineByPropertyName,
		HelpMessage="Angiv Instansnavn hvis ikke default ")] 
		[AllowNull()]
		[string]$Instans=""
        ,[Parameter(Mandatory=$false, Position=4, ValueFromPipelineByPropertyName,
		HelpMessage="Angiv ip portnr hvis ikke default ")] 
		[AllowNull()]
		[string]$sqlport=""
        ,[Parameter(Mandatory=$false, Position=5, ValueFromPipelineByPropertyName,
		HelpMessage="Angiv evt anden SQL konto ")] 
		[AllowNull()]
		[string]$sqluid=""
	,[Parameter(Mandatory=$false, Position=6, ValueFromPipelineByPropertyName,
		HelpMessage="Angiv evt password til SQL konto ")] 
		[AllowNull()]
		[string]$sqlpw=""
		)
	Begin{
		$mee2=$env:Computername									# get local computername from environment variable
		If($Server -in ".","","(local)"){ $Server="(local)"		# localhost skal angives som (local)
		}else{
			$ego=$Server.Split("\")[0]
			If($Server -like ".\*"){ $ego="(local)"}			# localhost 
			If($Server -like "$mee2*"){ $ego="(local)"}	# localhost 
			If($Server -like "localh*"){ $ego="(local)"}	# localhost 
			If($Server.Contains("\")){							# instance in servername
				$ego+="\"
				$ego+=$Server.Split("\")[1]					# Instance
			} else{													# not 2 instance names
				If($Instans.Length -gt 0){					
					$ego+="\"
					$ego+=$Instans.Trim()
				}
			}
			$Server=$ego
			If($sqlport.Length -gt 0) {
				$Server+=','
				$Server+=$sqlport
			}

		}
		
		invoke-sqlcmd
		If ($sqlpw.Length -gt 0){
			If (!($sqluid.Length -gt 2)){$sqluid=$env.USERNAME}
			$ConnStr = "Server=$Server;Database=$DataBase;User ID=$sqluid;Password=$sqlpw"
		}Else{
			$ConnStr = "Server=$Server;Database=$DataBase;Integrated Security=True"
		}
		$SqlConn = New-Object System.Data.SqlClient.SqlConnection($ConnStr)
		$SqlSrv = New-Object Microsoft.SqlServer.Management.Smo.Server($SqlConn)
		
		# variable with result of sql call
		#$Kommando
		If($SqlSrv.Product.length -gt 0) {}else{
			Write-Error "0 SQL Connection kald fejler med ukendt server\Instans $SqlSrv "
			Exit
		}
		If($Kommando -eq 'Info'){
			Return $SqlSrv
		}
Try{
		$SqlTable = $SqlSrv.Databases["$DataBase"].ExecuteWithResults($Kommando).Tables[0];
}Catch{
		Write-Error "SQL Komando kald fejler med: "
		write-Error $error[0]
}Finally{
		# Clean up, and close connection
		$SqlConn.Close()
}
		Return $SqlTable #viser hele svar på parent
	}	#endBegin

# SIG # Begin signature block
# MIIdAgYJKoZIhvcNAQcCoIIc8zCCHO8CAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCCrewqCFziG7waO
# 7vtsBJbKDq/VzR7RifYMBop8JHlsE6CCGBMwggT+MIID5qADAgECAhANQkrgvjqI
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
# MAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEIOtjvKUOn/pM8qmylP2XQtHZ
# R3u/s4sxyr945O0+fJW5MA0GCSqGSIb3DQEBAQUABIIBABxn77qh/1TtSCVYD30s
# YP01UjoI/TuFDV/7+K5l/7MMznipch6OdN227rChOGkQ0rT6JUc3/MVOS+Oz6sHB
# CwRIkqZtTUdDenccyxAzNmF+pSHqTtI07I14ANp9DDwjAoF/8ak4mj8Qi5j12gh1
# 58M6KKiL83sHXODQ0eYU4c5+UEw0AuteDpZ2udYQvpJ8YALaykQKqSDwjGzSbYYE
# UydqFmVsmXb/kmxIYmhR+Yv18ixxdEMmknZJUArtUwp2LjJbs2XmlPrfIMyMk/H6
# m3aTbcsEb3yV5X0NXsfDHyi+NxdALplJz5/kZThnjjUUZ4eFxqwsECQIpkCzw8DU
# IGWhggIwMIICLAYJKoZIhvcNAQkGMYICHTCCAhkCAQEwgYYwcjELMAkGA1UEBhMC
# VVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQd3d3LmRpZ2ljZXJ0
# LmNvbTExMC8GA1UEAxMoRGlnaUNlcnQgU0hBMiBBc3N1cmVkIElEIFRpbWVzdGFt
# cGluZyBDQQIQDUJK4L46iP9gQCHOFADw3TANBglghkgBZQMEAgEFAKBpMBgGCSqG
# SIb3DQEJAzELBgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTIxMTIxMDA5MzIw
# MVowLwYJKoZIhvcNAQkEMSIEIImDxX6G34IMgC853b/7ejqQeE9pfNXY2cNLIKTc
# 7qcoMA0GCSqGSIb3DQEBAQUABIIBALgTXvNIPc09vqUt/W7SdbWGGCNB1S4oEDZu
# lxOuq0IbwXsj9F6aFKRfvctUi5hJ5NzjDJD5RRSOBLGfkktvUY1+iYjl0BzWIwKD
# hkeK6428IInTRUIVjn7G4tz2mt7Y47up5iFzxIj1YitcIq+3RNxRUxDZ7uz7hOXc
# r1/OUmFGwC/ISssmHsnotH+xFnr4qdxzWftQeiRWkvITfAA/R+LGRVrYtGHeChiL
# tBxycONSz29rYkTJ5uwWauiI2xbA/YK440Xno2QNciNzLetiZPgy94hsZSw07pb5
# JiHLb2Cqx7VEocS5PYh3EtswnfSzs7PbhbQF56cFujx2q444ITA=
# SIG # End signature block
