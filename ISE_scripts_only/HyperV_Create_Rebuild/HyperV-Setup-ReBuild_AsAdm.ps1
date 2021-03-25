<#Script made/assembled by Rust@m 20-05-2019

#Requires -Version 5 - $PSVersionTable
#Requires -Module Hyper-V
Import-Module -Name Hyper-v 
#Requires -RunAsAdministrator
cls
#>

#Disable Bitlocker on so called server
#Suspend-BitLocker -MountPoint "$env:SystemDrive" -RebootCount 0 -ErrorAction SilentlyContinue


# Install the Hyper-V management tool pack (Hyper-V Manager and the Hyper-V PowerShell module)
#Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-Tools-All
#Enable Hyper-V
#Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All
#instal the Hyper-V on Windows server core 2019
#Install-WindowsFeature -Name Hyper-V -IncludeAllSubFeature -IncludeManagementTools
#Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V
Import-Module -Name Hyper-v -ErrorAction SilentlyContinue
Get-Module -Name Hyper-V

#Adding ad user for local group for administrative purpose and to get access to Hyper V Console from other PC's
$Users = @("adm-rufr","adm-nise")

foreach ($User in $Users)
{
   Add-LocalGroupMember -Group 'Administrators' -Member $User  -ErrorAction SilentlyContinue -Verbose
   Add-LocalGroupMember -Group 'Administratorer' -Member $User  -ErrorAction SilentlyContinue -Verbose
   Add-LocalGroupMember -Group 'Hyper-V Administrators' -Member $User -ErrorAction SilentlyContinue -Verbose
   Add-LocalGroupMember -Group 'Hyper-V-administratorer' -Member $User -ErrorAction SilentlyContinue -Verbose
   Add-LocalGroupMember -Group 'Remote Desktop Users' -Member $User -ErrorAction SilentlyContinue -Verbose
   Add-LocalGroupMember -Group 'Brugere af Fjernskrivebord' -Member $User -ErrorAction SilentlyContinue -Verbose
}


#Get-PSDrive; 
Set-Location -Path 'D:'

#removing VMs
Get-VM| Stop-VM -TurnOff -Force -Verbose
Get-VM | Remove-VM -Force -Verbose

#deleting directories
Remove-Item -Path "\Hyper-V" -Force -Recurse -Verbose

Get-VMSwitch | Remove-VMSwitch -Force -Verbose

# Set VM Folders
New-Item -Path "\Hyper-V\" -ItemType Directory -Verbose
New-Item -Path "\Hyper-V\Virtual Hard Disks" -ItemType Directory -Verbose
New-Item -Path "\Hyper-V\Virtual Machines" -ItemType Directory -Verbose

Set-VMHost -VirtualHardDiskPath "\Hyper-V\Virtual Hard Disks" -Verbose
Set-VMHost -VirtualMachinePath "\Hyper-V\Virtual Machines" -Verbose

#Copy rebuild scripts bats
New-Item -Path "Hyper-V" -ItemType Directory -Force
Copy-Item -Path "$PSScriptRoot\ReBuildVM_3.ps1" -Destination "\Hyper-V\" -Force -Verbose
Copy-Item -Path "$PSScriptRoot\Call_rebuild_script_AsAdmin.ps1" -Destination "$Env:PUBLIC\desktop\" -Force -Verbose
Copy-Item -Path "$PSScriptRoot\Call_rebuild_script_AsAdmin.bat" -Destination "$Env:PUBLIC\desktop\" -Force -Verbose

#Create a virtual switch by using Windows PowerShell - https://docs.microsoft.com/en-us/windows-server/virtualization/hyper-v/get-started/create-a-virtual-switch-for-hyper-v-virtual-machines
#Get-NetAdapter
New-VMSwitch -name ExternalSwitch  -NetAdapterName Ethernet -AllowManagementOS $true -ErrorAction SilentlyContinue -Verbose
New-VMSwitch -name InternalSwitch -SwitchType Internal -ErrorAction SilentlyContinue -Verbose
New-VMSwitch -name PrivateSwitch -SwitchType Private -ErrorAction SilentlyContinue -Verbose

# Allow enhanced Session Mode set on HyperV server settings - https://www.niallbrady.com/2019/02/18/hyper-v-enhanced-session-greyed-out-on-windows-server-2019-gen-2-virtual-machines/#:~:text=You%20need%20to%20click%20on,Session%20Mode%20as%20shown%20here.

## https://docs.microsoft.com/en-us/windows-server/virtualization/hyper-v/get-started/create-a-virtual-machine-in-hyper-v
## Create a virtual machine in Hyper-V
# example: New-VM -Name <Name> -MemoryStartupBytes <Memory> -BootDevice <BootDevice> -VHDPath <VHDPath> -Path <Path> -Generation <Generation> -Switch <SwitchName>
# example: New-VM -Name VM01-WIN10 -MemoryStartupBytes 4GB  -BootDevice VHD -NewVHDPath .\VMs\Win10.vhdx -Path .\VMData -NewVHDSizeBytes 50GB -Generation 2 -Switch ExternalSwitch

### Creat one VM
<#
$VM = "VM01-WXU"
New-VM -Name $VM -MemoryStartupBytes 4GB  -BootDevice VHD -NewVHDPath "C:\Hyper-V\Virtual Hard Disks\$VM.vhdx" -Path "C:\Hyper-V\Virtual Machines\$VM" -NewVHDSizeBytes 128GB -Generation 2 -Switch ExternalSwitch
#>

<### Configure one VM
#Configures a virtual machine - https://docs.microsoft.com/en-us/powershell/module/hyper-v/set-vm?view=win10-ps

$VM = "VM01-WXU"
Set-VM -Name $VM -GuestControlledCacheTypes $true -DynamicMemory -MemoryMinimumBytes 4GB -MemoryMaximumBytes 4Gb -ProcessorCount 2 -AutomaticStartAction Nothing -AutomaticStopAction Save -Notes "INITIALS:  COMPANY:  AD:  " -SnapshotFileLocation "C:\Hyper-V\Virtual Hard Disks\$VM _Snapshot" -SmartPagingFilePath "C:\Hyper-V\Virtual Machines\$VM" -CheckpointType ProductionOnly -AutomaticCheckpointsEnabled $False   
Set-VMMemory $VM -Buffer 5 -Priority 10
Enable-VMIntegrationService -VMName $VM -Name "Guest Service Interface" -ErrorAction SilentlyContinue
Enable-VMIntegrationService -VMName $VM -Name "Grænseflade til gæstetjeneste" -ErrorAction SilentlyContinue
#>


## Creation of multiple VMs
#Naming VMs
#$VMs = @("VM01-WXU","VM02-WXU","VM03-WXU","VM04-WXU","VM05-WXU","VM06-WXU","VM07-WXU","VM08-WXU","VM09-WXU","VM10-WXU","VM11-WXU","VM12-WXU");cls


$VMs = for ($i = 1; $i -lt 21; $i++)
{ 
    "VM{0:D2}" -f $i
}


<#
$wxu = for ($i = 1; $i -lt 9; $i++)
{ 
    "VM{0:D2}-WXU" -f $i
}

$win10Dev = "VM{0:D2}-WXD" -f 9


$win8 = for ($i = 10; $i -lt 12; $i++)
{ 
    "VM{0:D2}-W8.1" -f $i
}

$win7 = for ($i = 12; $i -lt 14; $i++)
{ 
    "VM{0:D2}-WIN7" -f $i
}

$VMs = $wxu+$win10Dev+$win8+$win7
#>


#Provision VMS
foreach ($VM in $VMs)
{
  Write-Host "Creating Virtual Machine - $VM" -ForegroundColor Yellow -Verbose
  New-VM -Name $VM -MemoryStartupBytes 4GB  -BootDevice VHD -NewVHDPath "\Hyper-V\Virtual Hard Disks\$VM.vhdx" -Path "\Hyper-V\Virtual Machines\" -NewVHDSizeBytes 128GB -Generation 2 -Switch ExternalSwitch
  
}


#Configuration of VM's for generation 2 windows 10
foreach ($VM in $VMs)
{
  Set-VM -Name $VM -GuestControlledCacheTypes $true -DynamicMemory -MemoryMinimumBytes 4GB -MemoryMaximumBytes 4Gb -ProcessorCount 2 -AutomaticStartAction Nothing -AutomaticStopAction Save -Notes "INITIALS:  PC:  XXX.dksund.dk  -PreProd" -SnapshotFileLocation "\Hyper-V\Virtual Hard Disks\" -SmartPagingFilePath "\Hyper-V\Virtual Machines\" -CheckpointType Production -AutomaticCheckpointsEnabled $False -Verbose
  Set-VMMemory $VM -Buffer 5 -Priority 10 -Verbose
  Enable-VMIntegrationService -VMName $VM -Name "Guest Service Interface" -ErrorAction SilentlyContinue -Verbose
  Enable-VMIntegrationService -VMName $VM -Name "Grænseflade til gæstetjeneste" -ErrorAction SilentlyContinue -Verbose
  #Get-VMIntegrationService -VMName VM12-WXU
  #$VM ="VM12-WXU"
}

pause