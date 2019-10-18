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
            if (!($Status -eq 'OK')) { $Status = 'Blank' } 
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


$cred = Get-Credential
$CSV = Get-FileName -initialDirectory $(Get-PSScriptRoot)
$Filename = Get-Date -format ddMMyy
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
          $Status = 'Fejl'
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
    Export-Csv -Path ('{0}\{1}_Status.csv' -f [io.fileinfo]$CSV.DirectoryName, $Filename ) -NoTypeInformation -Encoding UTF8 -Delimiter ';'
}