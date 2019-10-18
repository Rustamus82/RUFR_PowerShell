#requires -Version 2.0 -Modules NetTCPIP
#Region Functions and scripts
Function Get-PSScriptRoot
{
    $ScriptRoot = ''

    Try
    {
        $ScriptRoot = Get-Variable -Name PSScriptRoot -ValueOnly -ErrorAction Stop
    }
    Catch
    {
        $ScriptRoot = Split-Path -Path $script:MyInvocation.MyCommand.Path
    }

    Write-Output -InputObject $ScriptRoot
}

Function Get-FileName {
    
  param
  (
    [Parameter(Mandatory=$true)]
    [string]
    $initialDirectory
  )
    $null = Add-Type -AssemblyName System.windows.forms
    $OpenFileDialog = New-Object -TypeName System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.initialDirectory = $initialDirectory
    $OpenFileDialog.filter = 'CSV (*.csv)| *.csv'
    $null = $OpenFileDialog.ShowDialog()
    $OpenFileDialog.filename
}

$Script = {
    param(
        # Name of the user or group to be removed from localgroup
        [Parameter(Mandatory=$true)]
        [string]
        $IDRemove
    )

    function Get-NameFromSID {
        [OutputType([string])]
        Param (
            [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, Position=0)]
            [ValidatePattern('^S-\d-(\d+-){1,14}\d+$')]
            [string]$SID
        )

        Begin {
            New-Variable -Name 'Name' -Value ''
        }
        Process {
            try {
                $objSID = New-Object -TypeName System.Security.Principal.SecurityIdentifier -ArgumentList ("$SID")
                $objNTAccount = $objSID.Translate( [Security.Principal.NTAccount])
            } Catch [Management.Automation.MethodInvocationException] {
                Write-Error -Exception $Error[0].Exception
                return ''
            } Catch {
                Write-Error -Exception $Error[0].Exception
                Break
            }
            $Name = ($objNTAccount.Value).Split('\')[1]
        }
        End {
            Return $Name
        }
    }


    $LocalAdminGroup = Get-NameFromSID -SID 'S-1-5-32-544'

    $members = & "$env:windir\system32\net.exe" localgroup $LocalAdminGroup |  
      Where-Object {$_ -AND $_ -notmatch 'command' -and $_ -notmatch 'Kommandoen'} |  Select-Object -skip 4

    forEach ($member in $members) {
        if ($member -eq $IDRemove) {
            & "$env:windir\system32\net.exe" localgroup $LocalAdminGroup $IDRemove /delete
            $Status = 'OK'
        }
        else {
            if (!($Status -eq 'OK')) { $Status = 'Kunne ikke finde bruger' } 
        }
    }

    $membersCheck = & "$env:windir\system32\net.exe" localgroup $LocalAdminGroup | 
      Where-Object {$_ -AND $_ -notmatch 'command' -and $_ -notmatch 'Kommandoen'} |  Select-Object -skip 4

    return new-object -TypeName psobject -Property @{
        Members      = $members
        MembersCheck = $membersCheck
        Admin        = $LocalAdminGroup
        Status       = $Status
    }
}
#Endregion


[pscredential]$cred = Get-Credential
[io.fileinfo]$CSV = Get-FileName -initialDirectory $(Get-PSScriptRoot)
[string]$Filename = Get-Date -format ddMMyy
[Collections.ArrayList]$Results = @()

if ($CSV) 
{
  Import-Csv -Path $CSV | 
    ForEach-Object {
      $Ping = Test-NetConnection -ComputerName $_.Computernavn -Port 5985 -WarningAction SilentlyContinue

      if ($Ping.TcpTestSucceeded -eq $true) 
      {
          $Remote = invoke-command -Credential $cred -ComputerName $_.Computernavn -ScriptBlock $Script -ArgumentList $($_.Bruger)
          $Status = $Remote.Status
      }
      else 
      {
          $Status = 'Kunne ikke pinge computeren'
      }

      $Properties = @{
          'Computernavn' = $_.Computernavn
          'Bruger'       = $_.Bruger
          'Tid'          = Get-Date
          'Forbindelse'  = $Ping.TcpTestSucceeded
          'PSRemoting'   = $Remote
          'Gruppenavn'   = $Remote.Admin
          'Before'       = $Remote.Members
          'After'        = $Remote.MembersCheck
          'Status'       = $Status
      }

      $Results.Add($(New-Object -TypeName psobject -Property $properties))
    }
  $Results | 
    Select-Object -Property Computernavn, Bruger, Status | 
    Export-Csv -Path ('{0}\{1}_Status.csv' -f $CSV.DirectoryName, $Filename ) -NoTypeInformation -Encoding UTF8 -Delimiter ';'
}
# SIG # Begin signature block
# MIIZdAYJKoZIhvcNAQcCoIIZZTCCGWECAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUTA+sTXFwfiozExgAKYxjPduZ
# BpKgghTmMIID7jCCA1egAwIBAgIQfpPr+3zGTlnqS5p31Ab8OzANBgkqhkiG9w0B
# AQUFADCBizELMAkGA1UEBhMCWkExFTATBgNVBAgTDFdlc3Rlcm4gQ2FwZTEUMBIG
# A1UEBxMLRHVyYmFudmlsbGUxDzANBgNVBAoTBlRoYXd0ZTEdMBsGA1UECxMUVGhh
# d3RlIENlcnRpZmljYXRpb24xHzAdBgNVBAMTFlRoYXd0ZSBUaW1lc3RhbXBpbmcg
# Q0EwHhcNMTIxMjIxMDAwMDAwWhcNMjAxMjMwMjM1OTU5WjBeMQswCQYDVQQGEwJV
# UzEdMBsGA1UEChMUU3ltYW50ZWMgQ29ycG9yYXRpb24xMDAuBgNVBAMTJ1N5bWFu
# dGVjIFRpbWUgU3RhbXBpbmcgU2VydmljZXMgQ0EgLSBHMjCCASIwDQYJKoZIhvcN
# AQEBBQADggEPADCCAQoCggEBALGss0lUS5ccEgrYJXmRIlcqb9y4JsRDc2vCvy5Q
# WvsUwnaOQwElQ7Sh4kX06Ld7w3TMIte0lAAC903tv7S3RCRrzV9FO9FEzkMScxeC
# i2m0K8uZHqxyGyZNcR+xMd37UWECU6aq9UksBXhFpS+JzueZ5/6M4lc/PcaS3Er4
# ezPkeQr78HWIQZz/xQNRmarXbJ+TaYdlKYOFwmAUxMjJOxTawIHwHw103pIiq8r3
# +3R8J+b3Sht/p8OeLa6K6qbmqicWfWH3mHERvOJQoUvlXfrlDqcsn6plINPYlujI
# fKVOSET/GeJEB5IL12iEgF1qeGRFzWBGflTBE3zFefHJwXECAwEAAaOB+jCB9zAd
# BgNVHQ4EFgQUX5r1blzMzHSa1N197z/b7EyALt0wMgYIKwYBBQUHAQEEJjAkMCIG
# CCsGAQUFBzABhhZodHRwOi8vb2NzcC50aGF3dGUuY29tMBIGA1UdEwEB/wQIMAYB
# Af8CAQAwPwYDVR0fBDgwNjA0oDKgMIYuaHR0cDovL2NybC50aGF3dGUuY29tL1Ro
# YXd0ZVRpbWVzdGFtcGluZ0NBLmNybDATBgNVHSUEDDAKBggrBgEFBQcDCDAOBgNV
# HQ8BAf8EBAMCAQYwKAYDVR0RBCEwH6QdMBsxGTAXBgNVBAMTEFRpbWVTdGFtcC0y
# MDQ4LTEwDQYJKoZIhvcNAQEFBQADgYEAAwmbj3nvf1kwqu9otfrjCR27T4IGXTdf
# plKfFo3qHJIJRG71betYfDDo+WmNI3MLEm9Hqa45EfgqsZuwGsOO61mWAK3ODE2y
# 0DGmCFwqevzieh1XTKhlGOl5QGIllm7HxzdqgyEIjkHq3dlXPx13SYcqFgZepjhq
# IhKjURmDfrYwggSjMIIDi6ADAgECAhAOz/Q4yP6/NW4E2GqYGxpQMA0GCSqGSIb3
# DQEBBQUAMF4xCzAJBgNVBAYTAlVTMR0wGwYDVQQKExRTeW1hbnRlYyBDb3Jwb3Jh
# dGlvbjEwMC4GA1UEAxMnU3ltYW50ZWMgVGltZSBTdGFtcGluZyBTZXJ2aWNlcyBD
# QSAtIEcyMB4XDTEyMTAxODAwMDAwMFoXDTIwMTIyOTIzNTk1OVowYjELMAkGA1UE
# BhMCVVMxHTAbBgNVBAoTFFN5bWFudGVjIENvcnBvcmF0aW9uMTQwMgYDVQQDEytT
# eW1hbnRlYyBUaW1lIFN0YW1waW5nIFNlcnZpY2VzIFNpZ25lciAtIEc0MIIBIjAN
# BgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAomMLOUS4uyOnREm7Dv+h8GEKU5Ow
# mNutLA9KxW7/hjxTVQ8VzgQ/K/2plpbZvmF5C1vJTIZ25eBDSyKV7sIrQ8Gf2Gi0
# jkBP7oU4uRHFI/JkWPAVMm9OV6GuiKQC1yoezUvh3WPVF4kyW7BemVqonShQDhfu
# ltthO0VRHc8SVguSR/yrrvZmPUescHLnkudfzRC5xINklBm9JYDh6NIipdC6Anqh
# d5NbZcPuF3S8QYYq3AhMjJKMkS2ed0QfaNaodHfbDlsyi1aLM73ZY8hJnTrFxeoz
# C9Lxoxv0i77Zs1eLO94Ep3oisiSuLsdwxb5OgyYI+wu9qU+ZCOEQKHKqzQIDAQAB
# o4IBVzCCAVMwDAYDVR0TAQH/BAIwADAWBgNVHSUBAf8EDDAKBggrBgEFBQcDCDAO
# BgNVHQ8BAf8EBAMCB4AwcwYIKwYBBQUHAQEEZzBlMCoGCCsGAQUFBzABhh5odHRw
# Oi8vdHMtb2NzcC53cy5zeW1hbnRlYy5jb20wNwYIKwYBBQUHMAKGK2h0dHA6Ly90
# cy1haWEud3Muc3ltYW50ZWMuY29tL3Rzcy1jYS1nMi5jZXIwPAYDVR0fBDUwMzAx
# oC+gLYYraHR0cDovL3RzLWNybC53cy5zeW1hbnRlYy5jb20vdHNzLWNhLWcyLmNy
# bDAoBgNVHREEITAfpB0wGzEZMBcGA1UEAxMQVGltZVN0YW1wLTIwNDgtMjAdBgNV
# HQ4EFgQURsZpow5KFB7VTNpSYxc/Xja8DeYwHwYDVR0jBBgwFoAUX5r1blzMzHSa
# 1N197z/b7EyALt0wDQYJKoZIhvcNAQEFBQADggEBAHg7tJEqAEzwj2IwN3ijhCcH
# bxiy3iXcoNSUA6qGTiWfmkADHN3O43nLIWgG2rYytG2/9CwmYzPkSWRtDebDZw73
# BaQ1bHyJFsbpst+y6d0gxnEPzZV03LZc3r03H0N45ni1zSgEIKOq8UvEiCmRDoDR
# EfzdXHZuT14ORUZBbg2w6jiasTraCXEQ/Bx5tIB7rGn0/Zy2DBYr8X9bCT2bW+IW
# yhOBbQAuOA2oKY8s4bL0WqkBrxWcLC9JG9siu8P+eJRRw4axgohd8D20UaF5Mysu
# e7ncIAkTcetqGVvP6KUwVyyJST+5z3/Jvz4iaGNTmr1pdKzFHTx/kuDDvBzYBHUw
# ggYbMIIFA6ADAgECAgpdSt18AAEAABE2MA0GCSqGSIb3DQEBBQUAMDoxEjAQBgoJ
# kiaJk/IsZAEZFgJhZDETMBEGCgmSJomT8ixkARkWA3NzaTEPMA0GA1UEAxMGU1NJ
# LUNBMB4XDTE1MTExNzA5MTc1NVoXDTIwMTExNTA5MTc1NVowgYYxCzAJBgNVBAYT
# AkRLMRMwEQYKCZImiZPyLGQBGRYDc3NpMRIwEAYKCZImiZPyLGQBGRYCYWQxHjAc
# BgNVBAoTFVN1bmRoZWRzZGF0YXN0eXJlbHNlbjESMBAGA1UEAxMJbGFtZ2FkbWlu
# MRowGAYJKoZIhvcNAQkBFgtsYW1nQHNzaS5kazCCASIwDQYJKoZIhvcNAQEBBQAD
# ggEPADCCAQoCggEBALTjrwp0ChJ2SKW9UmGEFlFNgoAdBBq1DNJkwTjbWB3J7fKZ
# ef95E6dr14x0NeSwvar7yQsbT1tB3F2EgqjThzfa4+7X3d6d+zl101ZIzOm9Pmyy
# htOFfd0HIBdpHucwsUIpx9OOEDCeq/u3skkP8EpC39eOtHxX2ACHLfsPGRg9tO5a
# VCdGGacXoZ/yEf/dvc9HMETymu1v90vBCmot9TQJnixf/Mtu7DxYO6HkQ3J4iZlO
# lnO8zCy1WmwRg/C082fxdYmpBkP4E+LvYCz4Iuw0FaK7RKorTpseVqpc1SkjWZvv
# NtQFkZakaH1tM4TyZV5TfpIzD9Xa94jEUhx6I0MCAwEAAaOCAtQwggLQMDoGCSsG
# AQQBgjcVBwQtMCsGIysGAQQBgjcVCPeyK4euszTFkTuE3dtlh4ClKBblgy+C4cE3
# AgFkAgECMBMGA1UdJQQMMAoGCCsGAQUFBwMDMA4GA1UdDwEB/wQEAwIHgDAbBgkr
# BgEEAYI3FQoEDjAMMAoGCCsGAQUFBwMDMB0GA1UdDgQWBBQN+lsHXqyh9LaYSf7n
# iVGFT+XPhzAWBgNVHREEDzANgQtsYW1nQHNzaS5kazAfBgNVHSMEGDAWgBQrSBQC
# rj3wKDHaM6B4nwcOsQD8lzCB/QYDVR0fBIH1MIHyMIHvoIHsoIHphoGvbGRhcDov
# Ly9DTj1TU0ktQ0EoMSksQ049U1JWLUFELUNBMDIsQ049Q0RQLENOPVB1YmxpYyUy
# MEtleSUyMFNlcnZpY2VzLENOPVNlcnZpY2VzLENOPUNvbmZpZ3VyYXRpb24sREM9
# c3NpLERDPWFkP2NlcnRpZmljYXRlUmV2b2NhdGlvbkxpc3Q/YmFzZT9vYmplY3RD
# bGFzcz1jUkxEaXN0cmlidXRpb25Qb2ludIY1aHR0cDovL3BraS5zc2kuZGsvY3Js
# L1NSVi1BRC1DQTAyLnNzaS5hZFNTSS1DQSgxKS5jcmwwgfcGCCsGAQUFBwEBBIHq
# MIHnMIGgBggrBgEFBQcwAoaBk2xkYXA6Ly8vQ049U1NJLUNBLENOPUFJQSxDTj1Q
# dWJsaWMlMjBLZXklMjBTZXJ2aWNlcyxDTj1TZXJ2aWNlcyxDTj1Db25maWd1cmF0
# aW9uLERDPXNzaSxEQz1hZD9jQUNlcnRpZmljYXRlP2Jhc2U/b2JqZWN0Q2xhc3M9
# Y2VydGlmaWNhdGlvbkF1dGhvcml0eTBCBggrBgEFBQcwAoY2aHR0cDovL3BraS5z
# c2kuZGsvY3JsL1NSVi1BRC1DQTAyLnNzaS5hZF9TU0ktQ0EoMSkuY3J0MA0GCSqG
# SIb3DQEBBQUAA4IBAQB44w9enuLKi8ZpnBOQO6f/Zlw/5ZNX6mgKzK/k1VvkLZJ+
# hTdKvvA8KeaRPoMYzP95UjSih2Y0MFaX+JeKfgaAIPNFTeyty7bEdptMbR9YUKac
# rcn6fgXZ/Zvl4vCoHgcrhUNDC/oRJHlwGxD5hhaywci/R2VaBfjD+hdPxg1znHMW
# Y/YuuV5ALWC8uylrtlFHPrOaK2WEK3QXlZAQIxFHjZbIV1zUV/Q49R7aHdjA5lOR
# 9x0n2q+N5E1aZv6qO8VNSbYPCHIwRY0GSrfXk8UGU96fp/a/aHcaRZhCF4zl9w6k
# kfFLL2kh2DDEJ4RaTf9jC7QfRK4JMBwJ8AKMrk50MIIGKjCCBRKgAwIBAgIKYYK7
# hwAAAAAABzANBgkqhkiG9w0BAQUFADAwMS4wLAYDVQQDEyVTdGF0ZW5zIFNlcnVt
# IEluc3RpdHV0IENvcnBvcmF0ZSBSb290MB4XDTExMDMwODA5NTQ0OVoXDTMxMDMw
# ODEwMDQ0OVowOjESMBAGCgmSJomT8ixkARkWAmFkMRMwEQYKCZImiZPyLGQBGRYD
# c3NpMQ8wDQYDVQQDEwZTU0ktQ0EwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEK
# AoIBAQDB7M4xWcA7L/ersF9RC1lcCrDuXTShSJyDRNm6ocW10K5Y62qJXsUit8Xe
# oDO4nT9uTC1PksiT/t1wS8ikSuuvDZSSsve4FMSxOIr+iA6o9YloiL4I/PZgHQxh
# jtV+3k/Q78RnkECjmmiQz5LhZRDy513kLsTaa7t0OkFzbJ6SpPgbMlmXBOF5bhPw
# ASM2r2mShVyw8KpvC0dNiLiQuaMWri5NW1FB408Gtwu5v+jmL3fbYy2KrTkYEVlf
# OZjCCYx+O4Tpz5DyicOjGAKFq6yQGeFzQ4TLUgoVbTwoVOsR4SL1CY+qud7UqWhn
# x6gTOvbwznST7AoD4gABL67wVRurAgMBAAGjggM6MIIDNjASBgkrBgEEAYI3FQEE
# BQIDAQABMCMGCSsGAQQBgjcVAgQWBBR+6enK1P4LgaMj2Clb2pFj7H8ajjAdBgNV
# HQ4EFgQUK0gUAq498Cgx2jOgeJ8HDrEA/JcwGQYJKwYBBAGCNxQCBAweCgBTAHUA
# YgBDAEEwCwYDVR0PBAQDAgGGMA8GA1UdEwEB/wQFMAMBAf8wHwYDVR0jBBgwFoAU
# v63sANIvXaNWq+YjFUxjiZdhCS8wggE4BgNVHR8EggEvMIIBKzCCASegggEjoIIB
# H4aB02xkYXA6Ly8vQ049U3RhdGVucyUyMFNlcnVtJTIwSW5zdGl0dXQlMjBDb3Jw
# b3JhdGUlMjBSb290LENOPVNSVi1BRC1DQTAxLENOPUNEUCxDTj1QdWJsaWMlMjBL
# ZXklMjBTZXJ2aWNlcyxDTj1TZXJ2aWNlcyxDTj1Db25maWd1cmF0aW9uLERDPVNT
# SSxEQz1BRD9jZXJ0aWZpY2F0ZVJldm9jYXRpb25MaXN0P2Jhc2U/b2JqZWN0Q2xh
# c3M9Y1JMRGlzdHJpYnV0aW9uUG9pbnSGR2h0dHA6Ly9wa2kuc3NpLmRrL0NSTC9T
# dGF0ZW5zJTIwU2VydW0lMjBJbnN0aXR1dCUyMENvcnBvcmF0ZSUyMFJvb3QuY3Js
# MIIBRAYIKwYBBQUHAQEEggE2MIIBMjCBxwYIKwYBBQUHMAKGgbpsZGFwOi8vL0NO
# PVN0YXRlbnMlMjBTZXJ1bSUyMEluc3RpdHV0JTIwQ29ycG9yYXRlJTIwUm9vdCxD
# Tj1BSUEsQ049UHVibGljJTIwS2V5JTIwU2VydmljZXMsQ049U2VydmljZXMsQ049
# Q29uZmlndXJhdGlvbixEQz1TU0ksREM9QUQ/Y0FDZXJ0aWZpY2F0ZT9iYXNlP29i
# amVjdENsYXNzPWNlcnRpZmljYXRpb25BdXRob3JpdHkwZgYIKwYBBQUHMAKGWmh0
# dHA6Ly9wa2kuc3NpLmRrL0NSTC9TUlYtQUQtQ0EwMS5TU0kuREtfU3RhdGVucyUy
# MFNlcnVtJTIwSW5zdGl0dXQlMjBDb3Jwb3JhdGUlMjBSb290LmNydDANBgkqhkiG
# 9w0BAQUFAAOCAQEAk6E+3QzcafmbVOOXLFRFOyEdqQhL3ycQzWsRo1lI9WZLdkkG
# EzNHu7f5lxOJN7jGThu6lGCMX/X1cLGhUAqQ8ESAIe7x5Db8qfkRRAl4GVTQEn3z
# O/xFT4dMX2ygjCkBjw2quoDieoLwi2sQIV+s/zkKp9wIyuDkw6/fSqLD/1CP+OQo
# M02hPy/336GFR56x11/tr0WVpdrrqCj7AgWqPseJHd5CxbLEDprSAthGquGJoDg+
# wqb7GwLlMoSXQzuZ/khXnDS9n4CW4Lc4c/R+MfnLSLsrOEnUcJWemJ9zqPMREIty
# fM3ar2b0bef67AcYcUQCImcEogMsUDCjjiq7JzGCA/gwggP0AgEBMEgwOjESMBAG
# CgmSJomT8ixkARkWAmFkMRMwEQYKCZImiZPyLGQBGRYDc3NpMQ8wDQYDVQQDEwZT
# U0ktQ0ECCl1K3XwAAQAAETYwCQYFKw4DAhoFAKB4MBgGCisGAQQBgjcCAQwxCjAI
# oAKAAKECgAAwGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQwHAYKKwYBBAGCNwIB
# CzEOMAwGCisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYEFNF1Ex2joWcCvMKZ1GiE
# p+WOTtmbMA0GCSqGSIb3DQEBAQUABIIBABYVVnZ/0eqj33E4EZJbJL17Il8jMB4u
# yRMzzN9Mk99LiPxYHRZmZhC+ycHZxh4EKP721bIoq+OJi+p6Zz7gUFcCOXrpxEQn
# 9cBCavgRlzNZG/HvQOuhhYpgoV0XXbkVxVJDDLDL2/xe5HpHE6t1SwJ8lSobczeR
# RdsuZyHYQA9zsW8UPkF+I+Ikxg12RzH0mJwmHuoViTnh0n6gkb2QNXwaXbzoQP1x
# oo0Bx51vgVQhFnAel7DfNUoWDVCvlZ0QApcwaeS+JgnMVHvSJlb7aUkWIUIiTC88
# xnWGXc5LNEg5c+nSjpKQjgZlvUNugOhq1IirUSc9Man1bkK3p4nFcOOhggILMIIC
# BwYJKoZIhvcNAQkGMYIB+DCCAfQCAQEwcjBeMQswCQYDVQQGEwJVUzEdMBsGA1UE
# ChMUU3ltYW50ZWMgQ29ycG9yYXRpb24xMDAuBgNVBAMTJ1N5bWFudGVjIFRpbWUg
# U3RhbXBpbmcgU2VydmljZXMgQ0EgLSBHMgIQDs/0OMj+vzVuBNhqmBsaUDAJBgUr
# DgMCGgUAoF0wGAYJKoZIhvcNAQkDMQsGCSqGSIb3DQEHATAcBgkqhkiG9w0BCQUx
# DxcNMTcwOTEyMTMzMzU2WjAjBgkqhkiG9w0BCQQxFgQUg5UaOUl7ghTydcCRTgRK
# xv1keyIwDQYJKoZIhvcNAQEBBQAEggEADOkiAfAjKr/bRrhxFzjFRLWrnc5Vv2xP
# 0KiYRmygKQceQFDpcI1uVuGKPGyS08TpPcNa6hG8k+WCM3TDo2/HGmp3AsGjh6Bf
# aN9t0adT9s6tXgU9lhXUcdAxgaJR6H8VY2juXvKsDtU+VVYbJuzrHsS4z4xnMzbc
# iKO2hnWdjBBgS7W4/+qYzMa4W8qJPcOaROO2eQ7mSyjhOoZtvkWzvrexvW9dbNpD
# b/mtz9AGP81HguUp68GMQwPmTRdOHnkVltwnlEP30tBKiKCmusswseoUPJgpGiHo
# vTb/6ujU9o9T5j9d9HEPUFcq5etnCUXESg922Wk05rzozyXaR2encg==
# SIG # End signature block
