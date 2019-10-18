<#Script made/assembled by Rust@m 15-05-2019

#Requires -Version 5 - $PSVersionTable
#Requires -Module Hyper-V
#Requires -RunAsAdministrator
cls
#>
#*********************************************************************************************************************************************
#Function progressbar for timeout by ctigeek:
function Start-Sleep($seconds) {
    $doneDT = (Get-Date).AddSeconds($seconds)
    while($doneDT -gt (Get-Date)) {
        $secondsLeft = $doneDT.Subtract((Get-Date)).TotalSeconds
        $percent = ($seconds - $secondsLeft) / $seconds * 100
        Write-Progress -Activity "Sleeping" -Status "Sleeping..." -SecondsRemaining $secondsLeft -PercentComplete $percent
        [System.Threading.Thread]::Sleep(500)
    }
    Write-Progress -Activity "Sleeping" -Status "Sleeping..." -SecondsRemaining 0 -Completed
}

$WorkingDir = Convert-Path .
#http://www.yusufozturk.info/virtual-machine-manager/getting-virtual-machine-guest-information-from-hyper-v-server-2012r2.html
function Get-VMGuestInfo
{
<#
    .SYNOPSIS
 
        Gets virtual machine guest information
 
    .EXAMPLE
 
        Get-VMGuestInfo -VMName Test01
 
    .EXAMPLE
 
        Get-VMGuestInfo -VMName Test01 -HyperVHost Host01
 
    .NOTES
 
        Author: Yusuf Ozturk
        Website: http://www.yusufozturk.info
        Email: ysfozy[at]gmail.com
 
#>
 
[CmdletBinding(SupportsShouldProcess = $true)]
param (
 
    [Parameter(
        Mandatory = $true,
        HelpMessage = 'Virtual Machine Name')]
    $VMName,
 
    [Parameter(
        Mandatory = $false,
        HelpMessage = 'Hyper-V Host Name')]
    $HyperVHost = "localhost",
 
	[Parameter(
        Mandatory = $false,
        HelpMessage = 'Debug Mode')]
    [switch]$DebugMode = $false
)
	# Enable Debug Mode
	if ($DebugMode)
	{
		$DebugPreference = "Continue"
	}
	else
	{
		$ErrorActionPreference = "silentlycontinue"
	}
 
	$VMState = (Get-VM -ComputerName $HyperVHost -Name $VMName).State
 
	if ($VMState -eq "Running")
	{
		filter Import-CimXml
		{
			$CimXml = [Xml]$_
			$CimObj = New-Object -TypeName System.Object
			foreach ($CimProperty in $CimXml.SelectNodes("/INSTANCE/PROPERTY"))
			{
				if ($CimProperty.Name -eq "Name" -or $CimProperty.Name -eq "Data")
				{
					$CimObj | Add-Member -MemberType NoteProperty -Name $CimProperty.NAME -Value $CimProperty.VALUE
				}
			}
			$CimObj
		}
 
		$VMConf = Get-WmiObject -ComputerName $HyperVHost -Namespace "root\virtualization\v2" -Query "SELECT * FROM Msvm_ComputerSystem WHERE ElementName like '$VMName' AND caption like 'Virtual%' "
		$KVPData = Get-WmiObject -ComputerName $HyperVHost -Namespace "root\virtualization\v2" -Query "Associators of {$VMConf} Where AssocClass=Msvm_SystemDevice ResultClass=Msvm_KvpExchangeComponent"
		$KVPExport = $KVPData.GuestIntrinsicExchangeItems
 
		if ($KVPExport)
		{
			# Get KVP Data
			$KVPExport = $KVPExport | Import-CimXml
 
			# Get Guest Information
			$VMOSName = ($KVPExport | where {$_.Name -eq "OSName"}).Data
			$VMOSVersion = ($KVPExport | where {$_.Name -eq "OSVersion"}).Data
			$VMHostname = ($KVPExport | where {$_.Name -eq "FullyQualifiedDomainName"}).Data
		}
		else
		{
			$VMOSName = "Unknown"
			$VMOSVersion = "Unknown"
			$VMHostname = "Unknown"
		}
	}
	else
	{
		$VMOSName = "Unknown"
		$VMOSVersion = "Unknown"
		$VMHostname = "Unknown"
	}
 
	$Properties = New-Object Psobject
	$Properties | Add-Member Noteproperty VMName $VMName
	$Properties | Add-Member Noteproperty VMHost $HyperVHost
	$Properties | Add-Member Noteproperty VMState $VMState
	$Properties | Add-Member Noteproperty VMOSName $VMOSName
	$Properties | Add-Member Noteproperty VMOSVersion $VMOSVersion
	$Properties | Add-Member Noteproperty VMHostname $VMHostname
	Write-Output $Properties
}
#*********************************************************************************************************************************************
#*********************************************************************************************************************************************


$VMs = Get-VM

Get-VM | Start-VM -Verbose
#sleep 120

#Configuration of VM's for generation 2 windows 10, and update descriptions
foreach ($VM in $VMs.name)
{
  #VM need to be running to gather info about it
  $VMinfo = Get-VMGuestInfo -VMName $VM |select  VMHostname, VMOSName ,VMOSVersion
  $FQDN = $VMinfo.VMHostname
  $BUILD = $VMinfo.VMOSVersion
  $OSname = $VMinfo.VMOSName

  #To update all follwing configurations og VM, it need to be tuned of.
  Set-VM -Name $VM  -AutomaticStartAction Start -AutomaticStartDelay 180 -AutomaticStopAction Save -Notes "$FQDN`nOS: $OSname - $BUILD `nInitials: " -CheckpointType ProductionOnly -AutomaticCheckpointsEnabled $False -Verbose
  #Set-VM -Name $VM -GuestControlledCacheTypes $true -DynamicMemory -MemoryMinimumBytes 4GB -MemoryMaximumBytes 4Gb -ProcessorCount 2 -AutomaticStartAction Nothing -Notes "$FQDN`nOS: $OSname - $BUILD `nInitials: " -SnapshotFileLocation "$env:SystemDrive\Hyper-V\Virtual Hard Disks\$VM\Snapshot" -SmartPagingFilePath "$env:SystemDrive\Hyper-V\Virtual Machines\$VM" -CheckpointType ProductionOnly -AutomaticCheckpointsEnabled $False -Verbose
  
  #Get-VMIntegrationService -VMName VM01-WXU
  #$VM ="VM05-WXU"
}



#export and display names
$Overview = foreach($VM in $VMs.name)
{
  #VM need to be running to gather info about it
  $VMinfo = Get-VMGuestInfo -VMName $VM |select  VMHostname, VMOSName ,VMOSVersion
  $FQDN = $VMinfo.VMHostname
  $BUILD = $VMinfo.VMOSVersion
  $OSname = $VMinfo.VMOSName
  
  Write-Host "$VM - $FQDN " -ForegroundColor Cyan

  $Overview = $VMinfo | Export-Csv -Path $WorkingDir\VMinfo.txt -Force -Append -NoTypeInformation
  
  #Get-VMIntegrationService -VMName VM01-WXU
  #$VM ="VM05-WXU"
}



pause

