<#Script made/assembled by Rust@m 15-05-2019

#Requires -Version 5 - $PSVersionTable
#Requires -Module Hyper-V
#Requires -RunAsAdministrator
cls
#>

#Disable Bitlocker on so called server
Suspend-BitLocker -MountPoint "$env:SystemDrive" -RebootCount 0

#removing VMs
#Get-VM| Stop-VM -TurnOff -Force -Verbose
#Get-VM | Remove-VM -Force -Verbose

#deleting directories
#Remove-Item -Path "$env:SystemDrive\Hyper-V" -Force -Recurse -Verbose

#Get-VMSwitch | Remove-VMSwitch -Force -Verbose

#Disable Hyper V
#Disable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All -Verbose

#Enable Hyper-V
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V –All

#Adding ad user for local group for administrative purpose and to get access to Hyper V Console from other PC's
$Users = @("adm-rufr","adm-nise","adm-mam","adm-lamg")

foreach ($User in $Users)
{
   Add-LocalGroupMember -Group 'Administrators' -Member $User  -ErrorAction SilentlyContinue
   Add-LocalGroupMember -Group 'Administratorer' -Member $User  -ErrorAction SilentlyContinue
   Add-LocalGroupMember -Group 'Hyper-V Administrators' -Member $User -ErrorAction SilentlyContinue
   Add-LocalGroupMember -Group 'Hyper-V-administratorer' -Member $User -ErrorAction SilentlyContinue
   Add-LocalGroupMember -Group 'Remote Desktop Users' -Member $User -ErrorAction SilentlyContinue
   Add-LocalGroupMember -Group 'Brugere af Fjernskrivebord' -Member $User -ErrorAction SilentlyContinue
}


# Set VM Folder 
New-Item -Path "$env:SystemDrive\Hyper-V\" -ItemType Directory
#New-Item -Path "$env:SystemDrive\Hyper-V\Virtual Hard Disks" -ItemType Directory
#New-Item -Path "$env:SystemDrive:\Hyper-V\Virtual Machines" -ItemType Directory

Set-VMHost -VirtualHardDiskPath "$env:SystemDrive\Hyper-V\Virtual Hard Disks"
Set-VMHost -VirtualMachinePath "$env:SystemDrive:\Hyper-V\Virtual Machines"

#Copy rebuild scripts bats
$WorkingDir = Convert-Path .
Copy-Item -Path "$WorkingDir\ReBuildVM_3.ps1" -Destination "$env:SystemDrive\Hyper-V\" -Force
Copy-Item -Path "$WorkingDir\HyperV-Setup-TestFrameWork_UIplusplus_AsAdmin.ps1" -Destination "$env:SystemDrive\Hyper-V\" -Force -Verbose
Copy-Item -Path "$WorkingDir\HyperV-Setup-TestFrameWork_UIplusplus_AsAdmin.bat" -Destination "$env:SystemDrive\Hyper-V\" -Force -Verbose
Copy-Item -Path "$WorkingDir\Call_rebuild_script_AsAdmin.ps1" -Destination "$Env:PUBLIC\desktop\" -Force
Copy-Item -Path "$WorkingDir\Call_rebuild_script_AsAdmin.bat" -Destination "$Env:PUBLIC\desktop\" -Force -Verbose

#Create a virtual switch by using Windows PowerShell - https://docs.microsoft.com/en-us/windows-server/virtualization/hyper-v/get-started/create-a-virtual-switch-for-hyper-v-virtual-machines
#Get-NetAdapter

New-VMSwitch -name ExternalSwitch  -NetAdapterName Ethernet -AllowManagementOS $true -ErrorAction SilentlyContinue
New-VMSwitch -name InternalSwitch -SwitchType Internal -ErrorAction SilentlyContinue
New-VMSwitch -name PrivateSwitch -SwitchType Private -ErrorAction SilentlyContinue

## https://docs.microsoft.com/en-us/windows-server/virtualization/hyper-v/get-started/create-a-virtual-machine-in-hyper-v
## Create a virtual machine in Hyper-V
# example: New-VM -Name <Name> -MemoryStartupBytes <Memory> -BootDevice <BootDevice> -VHDPath <VHDPath> -Path <Path> -Generation <Generation> -Switch <SwitchName>
# example: New-VM -Name VM01-WIN10 -MemoryStartupBytes 4GB  -BootDevice VHD -NewVHDPath .\VMs\Win10.vhdx -Path .\VMData -NewVHDSizeBytes 50GB -Generation 2 -Switch ExternalSwitch

### Creat one VM
<#
$VM = "VM01-WXU"
New-VM -Name $VM -MemoryStartupBytes 4GB  -BootDevice VHD -NewVHDPath "C:\Hyper-V\Virtual Hard Disks\$VM.vhdx" -Path "C:\Hyper-V\Virtual Machines\$VM" -NewVHDSizeBytes 60GB -Generation 2 -Switch ExternalSwitch
#>

### Configure one VM
#Configures a virtual machine - https://docs.microsoft.com/en-us/powershell/module/hyper-v/set-vm?view=win10-ps
# example: Set-VM -Name VM01-WXU -GuestControlledCacheTypes $true -LowMemoryMappedIoSpace 4096 -HighMemoryMappedIoSpace 4096 -StaticMemory -ProcessorCount 2 -AutomaticStartAction Nothing -AutomaticStopAction Save -Notes "INITIALS:NON Company:New AD:NEW" -SnapshotFileLocation "C:\Hyper-V\Virtual Machines\VM01-WIN10_Snapshot" -SmartPagingFilePath "C:\Hyper-V\Virtual Machines\VM01-WIN10" -CheckpointType ProductionOnly -AutomaticCheckpointsEnabled $False 

<#
$VM = "VM01-WXU"
Set-VM -Name $VM -GuestControlledCacheTypes $true -DynamicMemory -MemoryMinimumBytes 4GB -MemoryMaximumBytes 4Gb -ProcessorCount 2 -AutomaticStartAction Nothing -AutomaticStopAction Save -Notes "INITIALS:  COMPANY:  AD:  " -SnapshotFileLocation "C:\Hyper-V\Virtual Hard Disks\$VM _Snapshot" -SmartPagingFilePath "C:\Hyper-V\Virtual Machines\$VM" -CheckpointType ProductionOnly -AutomaticCheckpointsEnabled $False   
Set-VMMemory $VM -Buffer 5 -Priority 10
Enable-VMIntegrationService -VMName $VM -Name "Guest Service Interface" -ErrorAction SilentlyContinue
Enable-VMIntegrationService -VMName $VM -Name "Grænseflade til gæstetjeneste" -ErrorAction SilentlyContinue
#>


## Creation of multiple VMs
#Naming VMs
#$VMs = @("VM01-WXU","VM02-WXU","VM03-WXU","VM04-WXU","VM05-WXU","VM06-WXU","VM07-WXU","VM08-WXU","VM09-WXU","VM10-WXU","VM11-WXU","VM12-WXU");cls

$VMs = for ($i = 1; $i -lt 13; $i++)
{ 
    "VM{0:D2}-WXU" -f $i
}

#Provision VMS
foreach ($VM in $VMs)
{
  New-VM -Name $VM -MemoryStartupBytes 4GB  -BootDevice VHD -NewVHDPath "$env:SystemDrive\Hyper-V\Virtual Hard Disks\$VM.vhdx" -Path "$env:SystemDrive\Hyper-V\Virtual Machines\$VM" -NewVHDSizeBytes 60GB -Generation 2 -Switch ExternalSwitch
  
}

#Configuration of VM's for generation 2 windows 10
foreach ($VM in $VMs)
{
  Set-VM -Name $VM -GuestControlledCacheTypes $true -DynamicMemory -MemoryMinimumBytes 4GB -MemoryMaximumBytes 4Gb -ProcessorCount 2 -AutomaticStartAction Start -AutomaticStartDelay 180 -AutomaticStopAction Save -Notes "INITIALS:  COMPANY:  AD:  -PreProd" -SnapshotFileLocation "$env:SystemDrive\Hyper-V\Virtual Hard Disks\$VM\Snapshot" -SmartPagingFilePath "$env:SystemDrive\Hyper-V\Virtual Machines\$VM" -CheckpointType ProductionOnly -AutomaticCheckpointsEnabled $False
  Set-VMMemory $VM -Buffer 5 -Priority 10
  Enable-VMIntegrationService -VMName $VM -Name "Guest Service Interface" -ErrorAction SilentlyContinue
  Enable-VMIntegrationService -VMName $VM -Name "Grænseflade til gæstetjeneste" -ErrorAction SilentlyContinue
  #Get-VMIntegrationService -VMName VM12-WXU
  #$VM ="VM12-WXU"
}
pause

& shutdown -r -f -t 3