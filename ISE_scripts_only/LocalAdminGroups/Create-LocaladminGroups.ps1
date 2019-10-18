#requires -module ActiveDirectory, NetTCPIP
#requires -version 4.0

<#
    .Synopsis
    Short description
    .DESCRIPTION
    Long description
    .EXAMPLE
    .\Create-LocalAdminGroups.ps1 -FilePath <Path to datafile> -Credential $Credentials
    .EXAMPLE
    .\Create-LocalAdminGroups.ps1 -DomainName <NetBIOS name of target domain> -UserName <Initials of adm-account> -$Computer <Name of target computer> -Credential $Credentials
    .EXAMPLE
    .\Create-LocalAdminGroups.ps1 -DomainName <NetBIOS name of target domain> -UserName <Initials of adm-account> -$Computer <Name of target computer>
    .INPUTS
    Inputs to this cmdlet (if any)
    .NOTES
    General notes
    .COMPONENT
    The component this cmdlet belongs to
    .ROLE
    The role this cmdlet belongs to
    .FUNCTIONALITY
    The functionality that best describes this cmdlet
#>

[CmdletBinding(DefaultParameterSetName = 'DataFile')]

param (
  [Parameter(Mandatory = $true,HelpMessage = 'Add help message for user',ParameterSetName = 'Datafile')]
  [ValidateNotNull()]
  [ValidateNotNullOrEmpty()]
  [ValidateScript({
        Test-Path -Path $_ -PathType Leaf
  })]
  [string]$FilePath,

  [Parameter(Mandatory = $true,HelpMessage = 'Add help message for user', ParameterSetName = 'SingleComputer')]
  [ValidateNotNull()]
  [ValidateNotNullOrEmpty()]
  [ValidateSet('DKSUND','DKSUNDTEST','SSI','SST')]
  [string]$DomainName,
    
  [Parameter(Mandatory = $true,HelpMessage = 'Add help message for user', ParameterSetName = 'SingleComputer')]
  [ValidateNotNull()]
  [ValidateNotNullOrEmpty()]
  [string]$UserName, 
    
  [Parameter(Mandatory = $true,HelpMessage = 'Add help message for user', ParameterSetName = 'SingleComputer')]
  [ValidateNotNull()]
  [ValidateNotNullOrEmpty()]
  [ValidateScript({
        $_.Length -le 15
  })]
  [string]$ComputerName, 
    
  [Parameter(Mandatory = $true,HelpMessage = 'Add help message for user', ParameterSetName = 'Datafile')]
  [Parameter(ParameterSetName = 'SingleComputer')]
  [System.Management.Automation.Credential()][pscredential]$Credential

)

process {

  If ($FilePath) 
  {
    $Objects = Get-Content -LiteralPath $FilePath | ConvertFrom-Csv -Delimiter ';'

    Foreach ($object in $Objects) 
    {
      Write-Log -Message $('Trying to create local admin group for computer "{0}" and add user(s) "{1}" in domain "{2}"...' -f $object.ComputerName, $object.UserName, $object.DomainName) -Level Info
      $result += New-LocalAdminGroup -DomainName $($object.DomainName) -UserName $($object.UserName) -ComputerName $($object.ComputerName) -Credential $Credential
    }
  }
  Else 
  {
    Write-Log -Message $('Trying to create local admin group for computer "{0}" and add user(s) "{1}" in domain "{2}"...' -f $ComputerName, $UserName, $DomainName) -Level Info
    $result += New-LocalAdminGroup -DomainName $DomainName -UserName $UserName -ComputerName $ComputerName -Credential $Credential
  }
}

end {
  If ($result.Contains($false))
  {
    Write-Log -Message $('One or more items failed. Please review the returned output to identified potential errors.') -Level Warn
  }
  Else 
  {
    Write-Log -Message $('All local Admin groups are created without error. ') -Level Info
  }
  
  Write-Log -Message '------ Script execution stopped ------' -Level Info
}

begin {
  [bool[]]$result = @()


  function Write-Log
  {
    <#
        .Synopsis
        Write-Log writes a message to a specified log file with the current time stamp.

        .DESCRIPTION
        The Write-Log function is designed to add logging capability to other scripts.
        In addition to writing output and/or verbose you can write to a log file for
        later debugging.

        .NOTES
        Created by: Jason Wasser @wasserja
        Modified: 11/24/2015 09:30:19 AM  

        Changelog:
        * Code simplification and clarification - thanks to @juneb_get_help
        * Added documentation.
        * Renamed LogPath parameter to Path to keep it standard - thanks to @JeffHicks
        * Revised the Force switch to work as it should - thanks to @JeffHicks

        To Do:
        * Add error handling if trying to create a log file in a inaccessible location.
        * Add ability to write $Message to $Verbose or $Error pipelines to eliminate
        duplicates.

        .PARAMETER Message
        Message is the content that you wish to add to the log file. 
      
        .PARAMETER Path
        The path to the log file to which you would like to write. By default the function will 
        create the path and file if it does not exist. 
      
        .PARAMETER Level
        Specify the criticality of the log information being written to the log (i.e. Error, Warning, Informational)
      
        .PARAMETER NoClobber
        Use NoClobber if you do not wish to overwrite an existing file.
      
        .EXAMPLE
        Write-Log -Message 'Log message' 
        Writes the message to c:\Logs\PowerShellLog.log.
      
        .EXAMPLE
        Write-Log -Message 'Restarting Server.' -Path c:\Logs\Scriptoutput.log
        Writes the content to the specified log file and creates the path and file specified. 
      
        .EXAMPLE
        Write-Log -Message 'Folder does not exist.' -Path c:\Logs\Script.log -Level Error
        Writes the message to the specified log file as an error message, and writes the message to the error pipeline.
      
        .LINK
        https://gallery.technet.microsoft.com/scriptcenter/Write-Log-PowerShell-999c32d0
    #>
    Param
    (
      [Parameter(Mandatory = $true,HelpMessage='Add help message for user',
      ValueFromPipelineByPropertyName = $true)]
      [ValidateNotNullOrEmpty()]
      [Alias('LogContent')]
      [string]$Message,

      [Alias('LogPath')]
      [string]$Path = "$env:temp\Create-LocalAdminGroups.log",
        
      [ValidateSet('Error','Warn','Info')]
      [string]$Level = 'Info',
        
      [switch]$NoClobber
    )

    Begin
    {
      # Set VerbosePreference to Continue so that verbose messages are displayed.
      $VerbosePreference = 'Continue'
    }
    Process
    {
        
      # If the file already exists and NoClobber was specified, do not write to the log.
      if ((Test-Path -Path $Path) -AND $NoClobber) 
      {
        Write-Error -Message ('Log file {0} already exists, and you specified NoClobber. Either delete the file or specify a different name.' -f $Path)
        Return
      }

      # If attempting to write to a log file in a folder/path that doesn't exist create the file including the path.
      elseif (!(Test-Path -Path $Path)) 
      {
        Write-Verbose -Message ('Creating {0}.' -f $Path)
        $null = $(New-Item -Path $Path -Force -ItemType File)
      }

      # Format Date for our Log File
      $FormattedDate = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'

      # Write message to error, warning, or verbose pipeline and specify $LevelText
      switch ($Level) {
        'Error' 
        {
          Write-Error -Message $Message
          $LevelText = 'ERROR:'
        }
        'Warn' 
        {
          Write-Warning -Message $Message
          $LevelText = 'WARNING:'
        }
        'Info' 
        {
          Write-Verbose -Message $Message
          $LevelText = 'INFO:'
        }
      }
        
      # Write log entry to $Path
      ('{0} {1} {2}' -f $FormattedDate, $LevelText, $Message) | Out-File -FilePath $Path -Append
    }
    End
    {
    }
  }
  
  function New-LocalAdminGroup
  {
    <#
        .SYNOPSIS
        Creates a Domain local Security group in selected domain, used by Group Policy Preferences to assign to the local Administrator group. 

        .DESCRIPTION
        Add a more complete description of what the function does.

        .PARAMETER DomainName
        Describe parameter -DomainName.

        .PARAMETER UserName
        Describe parameter -UserName.

        .PARAMETER ComputerName
        Describe parameter -ComputerName.

        .PARAMETER Credential
        Describe parameter -Credential.

        .EXAMPLE
        Create-LocalAdminGroup -DomainName Value -UserName Value -ComputerName "ComputerName" -Credential $creds

        .EXAMPLE
        Create-LocaladminGroup -DomainName Value -UserName Value -ComputerName Value
        Describe what this call does

        .NOTES
        Place additional notes here.

        .LINK
        URLs to related sites
        The first link is opened by Get-Help -Online New-LocalAdminGroup

        .INPUTS
        List of input types that are accepted by this function.

        .OUTPUTS
        List of output types produced by this function.
    #>

    [OutputType([bool])]
    param (
      [Parameter(Mandatory = $true,HelpMessage = 'Add help message for user',
          ValueFromPipelineByPropertyName = $true,
      Position = 0)]
      [ValidateSet('DKSUND','DKSUNDTEST','SSI','SST')]
      [string]$DomainName,
    
      [Parameter(Mandatory = $true,HelpMessage = 'Add help message for user',
          ValueFromPipelineByPropertyName = $true,
      Position = 1)]
      [string]$UserName, 
    
      [Parameter(Mandatory = $true,HelpMessage = 'Add help message for user',
          ValueFromPipelineByPropertyName = $true,
      Position = 2)]
      [ValidateScript({
            $_.Length -le 15
      })]
      [string]$ComputerName, 
    
      [Parameter(Mandatory = $true,HelpMessage = 'Add help message for user',
          ValueFromPipelineByPropertyName = $true,
      Position = 3)]
      [System.Management.Automation.Credential()][pscredential]$Credential
    )

    begin {
      Add-Type -AssemblyName Microsoft.ActiveDirectory.Management
      Import-Module -Name ActiveDirectory

      switch ($DomainName)
      {
        'DKSUND' 
        {
          $ServerName = 'S-AD-DC-02P.dksund.dk'
          $OUPath = 'OU=Local Administrator Groups,OU=T2Groups,OU=Tier2,DC=dksund,DC=dk'
          $GroupNameTemplate = 'DKSUND-{0}-{1}-s'
          Break
        }
        'DKSUNDTEST' 
        {
          $ServerName = 'S-AD-DC-01T.dksundtest.dk'
          $OUPath = 'OU=Local Administrator Groups,OU=T2Groups,OU=Tier2,DC=dksundtest,DC=dk'
          $GroupNameTemplate = 'DKSUND-{0}-{1}-s'
          Break
        }
        'SSI' 
        {
          $ServerName = 'SRV-AD-DC04.ssi.ad'
          $OUPath = 'OU=Local Administrator Groups,OU=T2Groups,OU=Tier2,DC=ssi,DC=ad'
          $GroupNameTemplate = 'DKSUND-{0}-{1}-s'
          Break
        }
        'SST' 
        {
          $ServerName = 'DC03.sst.dk'
          $OUPath = 'OU=Local Administrator Groups,OU=T2Groups,OU=Tier2,DC=sst,DC=dk'
          $GroupNameTemplate = 'DKSUND-{0}-{1}-s'
          Break
        }
        Default 
        {
          throw 'Unknown domain name'
        }
      }

      If (-not (Test-NetConnection -ComputerName $ServerName -Port 389 -InformationLevel Quiet)) 
      {
        Throw 'Can not connect to remote server'
      }

      If (!($Credential)) 
      {
        $Credential = Get-Credential -Message 'Enter username and password of an account with the permissions to create a security group in the specified Active Directory domain.'
      }

      [bool]$result = $false
    }
    
    process {
      [string]$GroupName = $GroupNameTemplate -f $DomainName.ToUpper(), $ComputerName.ToUpper()
      Write-Verbose -Message $('Assigned {1} to variable {0}' -f $GroupName, $GroupName)
      [string]$InfoString = @"
Medlemmer af denne gruppe får tildelt lokale administrator privilegier på en Koncern standard Windows PC i et år. PC'ens navn kan ses i Description feltet. 

Oprettet af {0} d. {1}
"@ -f $Credential.UserName, (Get-Date).ToShortDateString()
    
      Write-Verbose -Message ('Assigned "{0}" to variable InfoString' -f $InfoString)
    
      If(-not ([regex]::Match($UserName, '​^adm(-|_)|admin', [Text.RegularExpressions.RegexOptions]::IgnoreCase + [Text.RegularExpressions.RegexOptions]::Multiline ))) 
      {
        Write-Log -Message $('The username "{0}" is not a correct formatted adm-account.' -f $UserName) -Level Error
        #$UserName = 'adm-{0}' -f $UserName
      }
    
      [Microsoft.ActiveDirectory.Management.ADComputer[]]$ADComputers = Get-ADComputer -AuthType Negotiate -Credential @Credential -Server $ServerName -filter {
        (Name -eq $ComputerName) -And (Enabled -eq $true)
      } -SearchScope Subtree
      If ($ADComputers -and ($ADComputers.Count -gt 0)) {
          Write-Log -Message $('Found {0} computer(s) in domain "{1}" matching computername "{2}"' -f $ADComputers.Count, $DomainName, $ComputerName) -Level Info
          [bool]$bComputers = $true
      } Else {
          Write-Log -Message $('No matching computer object found in Active Directory: {0}' -f $ComputerName) -Level Error
          return $result
      }     

      [Microsoft.ActiveDirectory.Management.ADUser[]]$ADUsers   = Get-ADUser  -AuthType Negotiate -Credential $Credential -Server $ServerName -Filter {
        sAMAccountName -eq $UserName
      }  -SearchScope Subtree
      If ($ADUsers -and ($ADUsers.Count -gt 0)) {
          Write-log -Message $('Found {0} user(s) in domain "{1}" matching username "{2}"' -f $ADUsers.Count, $DomainName, $UserName) -Level Info
          [bool]$bUsers = $true
      } Else {
        Write-Log -Message $('No matching user account found in Active Directory: {0}' -f $UserName) -Level Error
        return $result
      }
    
      [Microsoft.ActiveDirectory.Management.ADGroup[]]$ADGroups = Get-ADGroup -AuthType Negotiate -Credential $Credential -Server $ServerName -Filter {
        Name -eq $GroupName
      } -SearchScope Subtree
      Write-log -Message $('Found {0} local admin group(s) in domain "{1}" matching computer name "{2}"' -f $ADGroups.Count, $DomainName, $ComputerName) -Level Info
    
      If ($ADGroups -and ($ADGroups.Count -gt 0)) 
      {
          foreach ($adgroup in $ADGroups) 
          {
              Write-Log -Message $('Group "{0}" already exists in domain "{1}"' -f $adgroup.DistinguishedName, $DomainName) -Level Warn
              try 
              {
                  Add-ADGroupMember -Identity $adgroup `
                  -Server $ServerName `
                    -Members $ADUsers `
                    -Credential $Credential `
                    -AuthType Negotiate
                }
                Catch 
                {
                    Write-Error -Exception $_.Exception
                }
                Finally 
                {
                    If ($_.Exception) 
                    { 
                        Write-Log -Message $('Could not add members to group "{0}"' -f $adgroup) -Level Error
                    }
                    Else 
                    { 
                        Write-Log -Message $('Added users: "{0}" to group "{1}"' -f $ADUsers.Name, $adgroup.Name) -Level Info
                        $result = $true
                    }
                }
            }
        }
        Else 
        {
            Write-Log -Message $('Group "{0}" was not found, trying to create a new group' -f $GroupName) -Level Info
            try 
            {
                $adgroup = New-ADGroup -Name $GroupName `
                    -Server $ServerName `
                    -DisplayName $GroupName  `
                    -Description $('Local administrator group for computer "{0}"' -f $ComputerName.ToUpper()) `
                    -GroupScope DomainLocal `
                    -GroupCategory Security `
                    -Path $OUPath `
                    -Credential $Credential `
                    -AuthType Negotiate `
                    -OtherAttributes @{ 'info' = $InfoString } `
                    -PassThru
            }
            Catch 
            {
                Write-Error -Exception $_.Exception
            }
            Finally 
            {
                If ($_.Exception) 
                {
                    Write-Log -Message ('Could not create new group {0}' -f $GroupName) -Level Error
                }
                Else 
                {
                    Write-Log -Message $('Created new local admin group: "{0}"' -f $GroupName) -Level Info
                }
            }
            
            If ($adgroup) 
            {
                Set-ADObject -AuthType Negotiate `
                    -Credential $Credential `
                    -Identity $adgroup `
                    -ProtectedFromAccidentalDeletion $true `
                    -Server $ServerName   
            
                try 
                {
                    Add-ADGroupMember -Identity $adgroup `
                    -Server $ServerName `
                    -Members $ADUsers `
                    -Credential $Credential `
                    -AuthType Negotiate
                }
                Catch 
                {
                    Write-Error -Message $_.Exception
                }
                finally 
                {
                    If ($_.Exception) 
                    {
                        Write-Log -Message $('Could not add user(s) "{0}" to group "{1}"' -f [string]::Join(',', $ADUsers.ForEach({
                            $_.Name
                        })), $adgroup) -Level Error
                    }
                    Else 
                    {
                        Write-Log -Message $('Added user(s) "{0}" to group "{1}"' -f [string]::Join(',', $ADUsers.ForEach({
                            $_.Name
                        })), $adgroup) -Level Info                  
                        $result = $true
                    }
                }
            }
        }
    }

    end {
      return $result
    }
  }

  Write-Log -Message '------ Script execution started ------' -Level Info

}


# SIG # Begin signature block
# MIIZdAYJKoZIhvcNAQcCoIIZZTCCGWECAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUivVdXWEQhMRQNsL1cxxSj3mY
# 1YagghTmMIID7jCCA1egAwIBAgIQfpPr+3zGTlnqS5p31Ab8OzANBgkqhkiG9w0B
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
# CzEOMAwGCisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYEFMrbNu+gP55L7TqGQPJo
# 1GHvuYh+MA0GCSqGSIb3DQEBAQUABIIBADKqMiOjPKzQulDgAhNpE+kNf1XutjU1
# U5qeL6LV+L3oBbh2miMKT+5jSdWHLYuQeOKefnhwJBlXiVBqSS/3YybN0A36CGYd
# U3yPQ96cueqhlXAKmnX0lWhHhteinBR7TpvK2UsZnipM1KR66BN7zr69njUCgQeG
# lQ6PfShLliWzSoIBh3hf3w7FhNE9n/yNgdpW3dmE2iO8+7GSx31n3PS1dh/4Onp8
# mS/3aYg6iUV8zNW2gS16nF7B1brfsMcb5Zt+k0/pILa4xMey5mXCiNxvISLxDJ39
# g11poTZFK/6pnOQ0vNE1HYA/kdXS+hj+dMz+Vu62SVKLa5l+Ywp0aKyhggILMIIC
# BwYJKoZIhvcNAQkGMYIB+DCCAfQCAQEwcjBeMQswCQYDVQQGEwJVUzEdMBsGA1UE
# ChMUU3ltYW50ZWMgQ29ycG9yYXRpb24xMDAuBgNVBAMTJ1N5bWFudGVjIFRpbWUg
# U3RhbXBpbmcgU2VydmljZXMgQ0EgLSBHMgIQDs/0OMj+vzVuBNhqmBsaUDAJBgUr
# DgMCGgUAoF0wGAYJKoZIhvcNAQkDMQsGCSqGSIb3DQEHATAcBgkqhkiG9w0BCQUx
# DxcNMTcwODA5MTIwMTEzWjAjBgkqhkiG9w0BCQQxFgQUAfdbofikkFevX66DbMKq
# IRwDRgMwDQYJKoZIhvcNAQEBBQAEggEATgQet58EVn5aLuCEJV501OarBG1JPOuR
# YsWzNfDmNS/gj4QIP+MZg6GqWUaQXP4xkUQ+GnFmx8IBDx8wwQDtRFcUpUvs/+sX
# 0HO9/IuwLLwKTSnwbNUlSdZSLrfg/SSCpmvY+XgL/V7mw0p8OkYKni5ZBmJkOi4h
# VecOaIFbMUJwPAF+7tMeybmb2r5Sz7aXi8hPkAVHIexFTEs8CZjVkDsCDozI2OQy
# cmgL76N3BRftATEGno7NgIjJlYMSl6WT/JQpqU/rB00fNYthmoo2bqFZGSRjkFRB
# PG1qUsXdp7BsB60HGAOyo+2qtdbtas6ysQ6HIuSiagk2B2HAF/9MZw==
# SIG # End signature block
