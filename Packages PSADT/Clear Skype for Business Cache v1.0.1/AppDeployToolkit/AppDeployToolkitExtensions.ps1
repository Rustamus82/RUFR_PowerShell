﻿<#
.SYNOPSIS
	This script is a template that allows you to extend the toolkit with your own custom functions.
    # LICENSE #
    PowerShell App Deployment Toolkit - Provides a set of functions to perform common application deployment tasks on Windows.
    Copyright (C) 2017 - Sean Lillis, Dan Cunningham, Muhammad Mashwani, Aman Motazedian.
    This program is free software: you can redistribute it and/or modify it under the terms of the GNU Lesser General Public License as published by the Free Software Foundation, either version 3 of the License, or any later version. This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
    You should have received a copy of the GNU Lesser General Public License along with this program. If not, see <http://www.gnu.org/licenses/>.
.DESCRIPTION
	The script is automatically dot-sourced by the AppDeployToolkitMain.ps1 script.
.NOTES
    Toolkit Exit Code Ranges:
    60000 - 68999: Reserved for built-in exit codes in Deploy-Application.ps1, Deploy-Application.exe, and AppDeployToolkitMain.ps1
    69000 - 69999: Recommended for user customized exit codes in Deploy-Application.ps1
    70000 - 79999: Recommended for user customized exit codes in AppDeployToolkitExtensions.ps1
.LINK
	http://psappdeploytoolkit.com
#>
[CmdletBinding()]
Param (
)

##*===============================================
##* VARIABLE DECLARATION
##*===============================================

# Variables: Script
[string]$appDeployToolkitExtName = 'PSAppDeployToolkitExt'
[string]$appDeployExtScriptFriendlyName = 'App Deploy Toolkit Extensions'
[version]$appDeployExtScriptVersion = [version]'3.8.3'
[string]$appDeployExtScriptDate = '30/09/2020'
[hashtable]$appDeployExtScriptParameters = $PSBoundParameters

##*===============================================
##* FUNCTION LISTINGS
##*===============================================

# <Your custom functions go here>
#LAMG funktion.
function Get-UninstallString
{
  [CmdletBinding()]
  param
  (
    [String]
    [Parameter(Mandatory=$true,HelpMessage='String to search for')]
    $SearchString
  )
  
  New-Variable -Name UninstallKey -Value ''  -Option Private -Force
  New-Variable -Name Path         -Value ''  -Option Private -Force
  New-Variable -Name Parameters   -Value @() -Option Private -Force

  if ($is64Bit)
  {
    $UninstallKey = Get-ChildItem -Path 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall'
  }
  else
  {
    $UninstallKey = Get-ChildItem -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall'
  }

  foreach ($key in $UninstallKey) 
  {
    if ((Get-ItemProperty -Path $key.PsPath -ErrorAction SilentlyContinue).DisplayName -eq $SearchString)
    {
      $KeyPath = $key.PsPath
    }
  }

  if ($KeyPath)
  {
    $UninstallString = (Get-ItemProperty -Path $KeyPath).UninstallString
    $TempArray = $UninstallString.Split('"')
  }
  else 
  {
    return $null
  }

  foreach ($item in $TempArray)
  {
    if (-not [string]::IsNullOrWhiteSpace($item))
    {
      $item = $item.Trim()
      $pattern = '^(([a-zA-Z]:|\\\\\w[ \w\.]*)(\\\w[ \w\.]*|\\%[ \w\.]+%+)+|%[ \w\.]+%(\\\w[ \w\.]*|\\%[ \w\.]+%+)*)'

      if ([regex]::IsMatch($item, $pattern, [Text.RegularExpressions.RegexOptions]::IgnoreCase))
      {
        $path = $item
      }
      else
      {
        $parameters = $item.Replace('  ',' ').Split(' ')
        $parameters += '/Silent'
        $parameters += '/clone_wait'
      }
    }
  }

  return New-Object -TypeName PSObject -Property @{
    Path = $path
    Parameters = $parameters
  }
}

function Set-MultiStringValue
{
    param (
        # Parameter help description
        [Parameter(Mandatory=$true)]
        [string]$Path,
        # Parameter help description
        [Parameter(Mandatory=$true)]
        [String]$Name,
        # Parameter help description
        [Parameter(Mandatory=$true)]
        [string[]]$Value
    )

    process {
        [string]  $Type = 'MultiString'

        try {
            [string[]]$reg = Get-ItemProperty -LiteralPath $Path -Name $Name -ErrorAction Stop | Select-Object -ExpandProperty $Name
        }
        catch {
            [string[]]$reg = New-ItemProperty -LiteralPath $Path -Name $Name -PropertyType $Type -Value @() -OutVariable $r | Select-Object -ExpandProperty $Name
        }

        foreach ($item in $Value) {
            if (-not ($item -in $reg)) { $reg += $item }
        }

        $reg = $reg | Where-Object { -not [string]::IsNullOrWhiteSpace($_)} | Select-Object -Unique

        try {
            $result = Set-ItemProperty -LiteralPath $Path -Name $Name -Value $reg -Force -ErrorAction Stop -PassThru
        }
        catch {
            Write-Error -Exception $_.Exception
        }

        Remove-Variable -Name 'reg' -Force
        return $result
    }
}


##*===============================================
##* END FUNCTION LISTINGS
##*===============================================

##*===============================================
##* SCRIPT BODY
##*===============================================

If ($scriptParentPath) {
	Write-Log -Message "Script [$($MyInvocation.MyCommand.Definition)] dot-source invoked by [$(((Get-Variable -Name MyInvocation).Value).ScriptName)]" -Source $appDeployToolkitExtName
} Else {
	Write-Log -Message "Script [$($MyInvocation.MyCommand.Definition)] invoked directly" -Source $appDeployToolkitExtName
}

##*===============================================
##* END SCRIPT BODY
##*===============================================
