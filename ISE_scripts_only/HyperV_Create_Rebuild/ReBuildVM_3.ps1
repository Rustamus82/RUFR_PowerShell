#Requires -Version 5
#Requires -Module Hyper-V
#Requires -RunAsAdministrator

[cmdletbinding(DefaultParameterSetName = 'vm')]
Param (
    [Parameter(
        ParameterSetName = 'vm',
        Position = 0,
        ValueFromPipeline = $true,
        Mandatory = $true)]
    [Microsoft.HyperV.PowerShell.VirtualMachine]$vm,
    [Parameter(
        ParameterSetName = 'ComputerName',
        Position = 0,
        Mandatory = $true,
        ValueFromPipelineByPropertyName = $true,
        HelpMessage = 'Enter the name of the virtual machine to rebuild.')]
    [string]$VMName,
    [Parameter(
        ParameterSetName = 'ComputerName',
        Position = 1,
        Mandatory = $false,
        ValueFromPipelineByPropertyName = $true,
        HelpMessage = 'Enter the name of the virtual machine host. (Must be the computername of the local computer)')]
    [string]$ComputerName = ([system.net.dns]::GetHostByName("localhost")).HostName,
    [Parameter(
        Mandatory = $false)]
    [switch]$Stop
)

Begin {
    try { 
        Import-Module Hyper-V -ErrorAction Stop
    }
    Catch {
        Write-Error -Exception $_.Exception -Message "Could not load module Hyper-V."
        Break
    }
}

Process {
    try {
        [Microsoft.HyperV.PowerShell.VMHost]$vmHost = Get-VMHost -ComputerName $ComputerName
    }
    catch {
        Write-Error -Exception $_.Exception
        Break
    }

    #Create the virtual machine object
    try {
        If (!$vm) { [Microsoft.HyperV.PowerShell.VirtualMachine]$vm = Get-VM -ComputerName $([string]::Join('.', $vmHost.ComputerName, $vmHost.FullyQualifiedDomainName)) -Name $VMName -ErrorAction Stop }
    }
    Catch {
        Write-Error -Exception $_.Exception   
        Break
    }

    #Stop vmconnect connected to the vm if running. 
    If (!$Stop) {
        $CimSessionOptions = New-CimSessionOption -Protocol Dcom
        $CimSession = New-CimSession -ComputerName $vm.ComputerName -SessionOption $CimSessionOptions
        $vmconnect = Get-CimInstance -CimSession $CimSession -Namespace 'root\cimv2' -ClassName Win32_Process -Filter "Name = 'vmconnect.exe' And CommandLine Like '%$VMName%'" 
        If ($vmconnect) { Invoke-CimMethod -InputObject $vmconnect -MethodName Terminate > $null }
    }

    #Get virtual harddisks of the virtual machine
    [Microsoft.HyperV.PowerShell.HardDiskDrive[]]$vmHDDs = Get-VMHardDiskDrive -VM $vm

    #Stop the vm if running
    if ($vm.state -ne 'Off') {
        Stop-VM -VM $vm -TurnOff -Force -ErrorAction Stop
    }

    #Remove and create new virtual harddrives
    Do {
        if ($vm.State -eq 'Off') {
            [System.Object[]]$Checkpoints = Get-VMSnapshot -VM $vm

            if ($Checkpoints -and $Checkpoints.count -gt 0) {
                foreach ($Checkpoint in $Checkpoints) {
                    Remove-VMSnapshot -VMSnapshot $Checkpoint -ErrorAction Stop > $null
                    do
                    {
                        Start-Sleep -Seconds 2
                    } while (Get-vm -ComputerName $vm.ComputerName -Id $vm.Id | Where-Object -FilterScript {$_.Status -eq 'merging disks'})
                }
            }
            
            if ($vmHDDs -and $vmHDDs.Count -gt 0) {
                foreach ($vmHDD in $vmHDDs) {
                    $vhd = Get-VHD -Path $vmHDD.Path
                    Remove-VMHardDiskDrive -VMHardDiskDrive $vmHDD -ErrorAction Stop
                    if (Test-Path $vhd.Path) {Remove-Item -Path $vhd.Path -force -ErrorAction Stop}
                    New-VHD -ComputerName $vm.ComputerName -Path $vhd.Path -SizeBytes $vhd.Size -Dynamic -ErrorAction Stop > $null
                    Add-VMHardDiskDrive -VM $vm -Path $vhd.Path -ControllerType $vmHDD.ControllerType -ControllerNumber $vmHDD.ControllerNumber -ControllerLocation $vmHDD.ControllerLocation
                }
            }
            else {
                $VhdPath = Join-Path -Path $vmHost.VirtualHardDiskPath -ChildPath $($vm.Name + '.vhdx')
                if (Test-Path -Path $VhdPath) {Remove-Item -Path $VhdPath -Force -ErrorAction Stop}
                $HDD = New-VHD -ComputerName $vm.computername -Path $VhdPath -SizeBytes 127GB -Dynamic -ErrorAction Stop
                if ($vm.Generation -eq 2) {
                    Add-VMHardDiskDrive -VM $vm -Path $HDD.Path -ControllerType SCSI -ControllerNumber 0 -ControllerLocation 0
                }
                else {
                    Add-VMHardDiskDrive -vm $vm -Path $HDD.Path -ControllerType IDE -ControllerNumber 0 -ControllerLocation 0
                }
            }
        }
        Start-Sleep -Seconds 2
    } while ($vm.State -ne 'Off')

    #Reset the boot order on a Gen 2 vm
    If ($vm.Generation -eq 2) {
        $firmware = Get-VMFirmware -VM $vm
        $newBootOrder = @()
        foreach ($boot in $firmware.BootOrder) {
            if ($boot.BootType -ne 'File') {
                $newBootOrder += $boot
            }
        }
        Set-VMFirmware -VM $vm -BootOrder $newBootOrder
    }
}

End {
    #Launch VM after rebuild
    If (!$Stop) {
        $args = @()
        $args += $('"{0}"' -f $vm.ComputerName)
        $args += $('"{0}"' -f $vm.VMName)
        $args += $('-G "{0}"' -f $vm.VMId)
        $args += $('-C "0"')

        If (Test-Path $env:SystemRoot\System32\vmconnect.exe) {
            Start-Process VmConnect.exe -ArgumentList $args -WindowStyle Normal
        }
        ElseIf (Test-Path $env:ProgramFiles\hyper-v\vmconnect.exe) {
            Start-Process $env:ProgramFiles\hyper-v\vmconnect.exe -ArgumentList $args -WindowStyle Normal
        }
        Else {
            Write-Error -Message "Could not locate vmconnect.exe in any of the usual places. " -Category OpenError
        }
        Start-VM -VM $vm
    }
}