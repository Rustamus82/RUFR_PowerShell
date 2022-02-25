<# 
.SYNOPSIS 
Dette er en funktion for at få AD informationer for en AD brugerkonto, efter søge kriterier. 
Script opdateret Mikael Veistrup-Vetlov @ 20211122
Script oprettet Mikael Veistrup-Vetlov @ 20200323

.Parameter Bruger 
AD-WhoIs.ps1 bruger søgeargument <-Bruger> for at søge i AD efter brugere hvor navnet 
indeholder søgeargumentet
Resultatet vises som dropdown, hvis der er mere end 1 resultat, hvor man skal vælge 1.


.DESCRIPTION 
AD-WhoIs.ps1 bruger søgeargument <-Bruger> for at søge i AD efter brugere hvor navnet 
indeholder søgeargumentet <-Bruger> og lister brugerne i Dropdown liste, hvor der 
skal vælges 1 bruger. 
Det er primært for at få info om oprettelse og brugs informationer.
Angiv kun initialer / brugernavn!"
Man kan angive en reelt bruger / service konto, eller en del af et konto navn der kan søges på. "
Søgeord skal angives uden wildcards, da funktionen supplerer disse  :-) 
For denne bruger listes bruger, email, brugerstatus, emailstatus & gruppe medlemsskab. 

.EXAMPLE 
.\ad-WhoIs.ps1 -Bruger mive 
Søger lokalt ad igennem med søgeargument *mive* efter brugere
.EXAMPLE 
$who= .\ad-user.ps1 -user mive 

.NOTES
.LINK
#> 

    [CmdletBinding()] 
	Param (
		[Parameter(Mandatory, Position=0, ValueFromPipelineByPropertyName,
		HelpMessage="Angiv tekst der skal bruges til at søge efter AD bruger.")] 
        [Alias("User")] 
		[ValidateLength(3,36)]
		[String]$Bruger
		)
	Begin{
		$us="Name -like ""*"
		$us+=$Bruger
		$us+="*"""
		Function Is-Num([string]$i1){
			$Sub="Is-Num"
			[bool]$r=0
			If($i1.length -lt1){return $r}
			trap {return $r}
			$r=$i1/1
			$r=1
			Return $r
		}
		$aduser=get-aduser -Filter $us -Properties * | select Name,samaccountname,DistinguishedName
		If($aduser.length -gt 0){
			$comboCount=$aduser.count

			[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")  
			[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") 
			[void] [System.Windows.Forms.Application]::EnableVisualStyles()  

			$Form = New-Object system.Windows.Forms.Form 
			$Form.Size = New-Object System.Drawing.Size(1200,300) 
			$Form.MaximizeBox = $false 
			$Form.MinimizeBox = $false 
			$Form.StartPosition = "CenterScreen" 
			$Form.FormBorderStyle = 'Fixed3D' 
			$Form.Text = "Vælg Bruger, " + ($comboCount.ToString()) + " fundet"
			$Font = New-Object System.Drawing.Font("Arial",15,[System.Drawing.FontStyle]::Bold) 
			$Form.Font = $Font 

			$DropDown = New-Object System.Windows.Forms.ComboBox
			$DropDown.Location = New-Object System.Drawing.Point(10, 40)     # (Lodret,Vandret)
			$DropDown.Size = New-Object System.Drawing.Size(1100, 900)
			foreach($e in $aduser){
				$Linie=$e.samaccountname + ": " + $e.DistinguishedName
				Write-Host "Valg: -" $Linie
				[void] $DropDown.Items.add($linie)
			}
			$DropDown.AutoSize           = $true
			$Form.Controls.Add($DropDown)
			# Select the default value
			$DropDown.SelectedIndex       = 0
	
			$Okbutton = New-Object System.Windows.Forms.Button 
			$Okbutton.Location = New-Object System.Drawing.Size(10,100) 
			$Okbutton.Size = New-Object System.Drawing.Size(100,30) 
			$Okbutton.AutoSize = $true 
			$Okbutton.Text = "Vælg viste bruger" 
			#$Okbutton.Add_Click({Return-DropDown $DropDown}) 
			$Okbutton.Add_Click({$Form.Close()}) 
			$Okbutton.DialogResult = "Ok" 
			$Form.Controls.Add($Okbutton)

			$Cancelbutton = New-Object System.Windows.Forms.Button 
			$Cancelbutton.Location = New-Object System.Drawing.Size(210,100) 
			#$Cancelbutton.Size = New-Object System.Drawing.Size(100,50) 
			$Cancelbutton.AutoSize = $true 
			$Cancelbutton.Text = "Annuler Valg" 
			$Cancelbutton.Add_Click({$Form.Close()}) 
			$Cancelbutton.DialogResult = "Ignore" # values: None,Ok,Cancel,Abort,Retry,Ignore,Yes,No
			$Form.Controls.Add($Cancelbutton)

			$rc=$Form.ShowDialog()
			$Bruger = ($DropDown.SelectedItem.ToString()).split(":")[0]
			If($rc -eq "Ignore"){Write-Host "Ok annuleret";exit}
			# Optional: Call the Dispose method when you are finished with the dialog box.
			#$form.Dispose()
			Write-Host "Valgt:"
		}ElseIf(!($aduser.name.length -gt 0)){
			Write-Host "Der er ikke fundet brugerkonto, efter søgekriteriet *$bruger*"
			Exit
		}

		$rc=get-aduser -filter "samaccountname -eq ""$Bruger""" -properties *     #UserPrincipalName,SamAccountName,
#			DistinguishedName,CN,DisplayName,EmailAddress, enabled, LastLogonDate, logonCount, PasswordExpired,
#			whenChanged,Created,whenCreated,PasswordLastSet,"PasswordNeverExpires",AccountExpirationDate,
#			"msDS-UserPasswordExpiryTimeComputed",MemberOf
		If(!($rc.SamAccountName.count -gt 0)){Write-Host "Bruger: ..............." $Bruger " er ikke fundet i AD!";exit} 
		Write-Host "Bruger: ..............." $Bruger
		Write-Host "Bruger/AD: ............" $rc.UserPrincipalName
		Write-Host "SamAccountName: ......." $rc.SamAccountName
		Write-Host "Dn: ..................." $rc.DistinguishedName
		Write-Host "CN: ..................." $rc.CN
		Write-Host "DisplayName: .........." $rc.DisplayName
		If($rc.EmailAddress){Write-Host "EmailAddress: ........." $rc.EmailAddress}
		Write-Host "Bruger enabled: ......." $rc.enabled

		Write-Host "LastLogonDate: ........" $rc.LastLogonDate
		Write-Host "logonCount: ..........." $rc.logonCount
		Write-Host "SID: .................." $rc.sid
		If($rc.sidhistory){Write-Host "sidhistory: ..........." $rc.sidhistory}
		Write-Host "PasswordExpired: ......" $rc.PasswordExpired
		Write-Host "UserCreated: .........." $rc.Created
		Write-Host "whenCreated: .........." $rc.whenCreated
		Write-Host "UserChanged: .........." $rc.whenChanged
		Write-Host "PasswordLastSet: ......" $rc.PasswordLastSet
		If($rc.PasswordNeverExpires) {
			Write-Host "PasswordNeverExpires"
		}Else{
			If ($Bruger.Substring(0,4) -in "adx-","adx_","adm-","adm_"){Write-Host "PasswordExpire: ......." ($rc.PasswordLastSet).AddMonths(2)
			}elseIf ($Bruger.Length -eq 7){
				If (Is-Num($Bruger.Substring(1,6))){
					If ($Bruger.Substring(0,1) -eq "e"){Write-Host "PasswordExpire: ......." ($rc.PasswordLastSet).AddDays(60)
					}elseIf ($Bruger.Substring(0,1) -eq "b"){Write-Host "PasswordExpire: ......." ($rc.PasswordLastSet).AddMonths(12)
					}}
			}else{
				Write-Host "PasswordExpire: ......." ($rc.PasswordLastSet).AddMonths(3)
			}
		}
		
		If (!($rc.AccountExpirationDate)) {
			Write-Host "AccountNeverExpires"
		}else{
			Write-Host "AccountExpires: ......." $rc.AccountExpirationDate 
		}

#	$mof1=$rc.MemberOf -replace(" cn","!cn")
		$mof=$rc.MemberOf -split("!")
		Write-Host
		Write-Host "Medlem af " $mof.count " grupper:" #$rc.MemberOf
		Write-Host
		Foreach($m in $mof){Write-Host $m}

	}


# SIG # Begin signature block
# MIIdAgYJKoZIhvcNAQcCoIIc8zCCHO8CAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCCJ5G1R8jf6shNE
# Fukqup1nkOSf76VldxvC1uairQcMjqCCGBMwggT+MIID5qADAgECAhANQkrgvjqI
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
# MAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEIPBGa4ExBwtdfI01hG0uwNwr
# BLDCN/ShTxCiohVTll/+MA0GCSqGSIb3DQEBAQUABIIBAGoJ0o2K+O11JBkLgCcv
# tO6RyQKlLtKgJbWbSZNHgYGqrkk6YQ3bwdGcn8uGmtT1T00My0fB8KZPkq8fj8uP
# 20layki1P3IBeXQH7tjB+X087Lt4I3u3oiu7TxdGP+0cKh0heO2uvywzVQYapXY8
# C9Dm8mCbYx3jnMZt2cHhetTyU7ljsyfq0BMvff3NsDjXqm+xOxRNS+qiY1Y1vz3H
# CIzIWzKAoT9DeMElNY7uNJHdPypSRRnEeubfuPVExGBSled115ndDWb8r9+KXJcs
# mqeCeNBwjV42LWtRpW2l4lNdN7y4c7E2x994wVeuzFQU51yWPpW0/SfL4sOa8gvt
# CoChggIwMIICLAYJKoZIhvcNAQkGMYICHTCCAhkCAQEwgYYwcjELMAkGA1UEBhMC
# VVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQd3d3LmRpZ2ljZXJ0
# LmNvbTExMC8GA1UEAxMoRGlnaUNlcnQgU0hBMiBBc3N1cmVkIElEIFRpbWVzdGFt
# cGluZyBDQQIQDUJK4L46iP9gQCHOFADw3TANBglghkgBZQMEAgEFAKBpMBgGCSqG
# SIb3DQEJAzELBgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTIyMDIwOTE4MjMw
# MlowLwYJKoZIhvcNAQkEMSIEIJlz9ZCFr16+z2NUOXW9pGIAbhEzYdW+b1E4gOcU
# z0WfMA0GCSqGSIb3DQEBAQUABIIBAB7V1lInfCr6MdY6hO9SRC+IUtw3Ycc41+Lc
# OiVQXGOoy1jLERkwE51DB+eOWwRep7lKy+rtngdviMD2ST5havtVIW3hthDsGmcX
# SsDvD6169lnbPR/AhBGHeZ42TkDlBdEYe3FzUNh5mOtpzfKFckUNaC+QZ94K2xbm
# YJBsqwZ53fXVNBEZdn2M8ybOR/yeQvPWLsnizXd/gpoxatcc+/PNRK5KqDSVTHsJ
# xm+wXXNpyE0BHPhRXEMVeJ9gl7rvel4yW1zETCj7rgmgA6tZ/FQF4T54/qcluat/
# 2F0Tz0ytGe7E7a0IjopWKcnTf7LBC9fM87LX7cLTFo8eJL45CAk=
# SIG # End signature block
