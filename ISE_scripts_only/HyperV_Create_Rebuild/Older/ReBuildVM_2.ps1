[cmdletbinding(DefaultParameterSetName='vm')]
Param (
    [Parameter(
        ParameterSetName='vm',
        Position=0,
        ValueFromPipeline=$true,
        Mandatory=$true)]
    [System.Object]$vm,
    [Parameter(
        ParameterSetName='ComputerName',
        Position=0,
        Mandatory=$true,
        ValueFromPipelineByPropertyName=$true,
        HelpMessage='Enter the name of the virtual machine to rebuild.')]
    [string]$Name,
    [Parameter(
        ParameterSetName='ComputerName',
        Position=1,
        Mandatory=$false,
        ValueFromPipelineByPropertyName=$true,
        HelpMessage='Enter the name of the virtual machine host. (Must be the computername of the local computer)')]
    [string]$ComputerName = ([system.net.dns]::GetHostByName("localhost")).HostName,
    [Parameter(
        Mandatory=$false)]
    [switch]$Stop
)

Begin {
    try { 
        Import-Module Hyper-V -ErrorAction Stop
    } Catch {
        Write-Error -Exception $_.Exception -Message "Could not load module Hyper-V."
        Break
    }
}

Process {
    #Create the virtual machine object
    try {
        If (!$vm) { $vm = Get-VM -ComputerName $ComputerName -Name $Name -ErrorAction Stop }
    } Catch {
        Write-Error -Exception $_.Exception   
        Break
    }

    #Stop vmconnect connected to the vm if running. 
    If (!$Stop) {
        $CimSessionOptions = New-CimSessionOption -Protocol Dcom
        $CimSession = New-CimSession -ComputerName $vm.ComputerName -SessionOption $CimSessionOptions
        $vmc = Get-CimInstance -CimSession $CimSession -Namespace 'root\cimv2' -ClassName Win32_Process -Filter $("Name = '{0}' And CommandLine Like '%{1}%'" -f 'vmconnect.exe', $vm.VMName)
        If ($vmc) { 
            foreach ($Object in $vmc) {
                Invoke-CimMethod -InputObject $Object -MethodName Terminate > $null 
            }
        }
    }

    #Get virtual harddisks of the virtual machine
    $vmHDDs = Get-VMHardDiskDrive -VM $vm
    $vmSnapshots = Get-VMSnapshot -VM $vm

    #Stop the vm if running
    if ($vm.state -ne 'Off'){
        Stop-VM -VM $vm -TurnOff -Force -ErrorAction Stop
    }

    #Remove and create new virtual harddrives
    Do {
        if ($vm.State -eq 'Off'){
            If ($vmSnapshots -and $vmSnapshots.Count -gt 0) { Remove-VMSnapshot -VMSnapshot $vmSnapshots -IncludeAllChildSnapshots }

            foreach ($vmHDD in $vmHDDs) {
                $vhd = Get-VHD -Path $vmHDD.Path
                Remove-VMHardDiskDrive -VMHardDiskDrive $vmHDD -ErrorAction Stop
                if(Test-Path $vhd.Path) {Remove-Item -Path $vhd.Path -force -ErrorAction Stop}
                New-VHD -ComputerName $vm.ComputerName -Path $vhd.Path -SizeBytes $vhd.Size -Dynamic -ErrorAction Stop > $null
                Add-VMHardDiskDrive -ComputerName $vm.ComputerName -VMName $vm.Name -Path $vhd.Path -ControllerType $vmHDD.ControllerType -ControllerNumber $vmHDD.ControllerNumber -ControllerLocation $vmHDD.ControllerLocation
            }
        }
        Start-Sleep -Seconds 2
    } while ($vm.State -ne 'Off')

    #Reset the boot order on a Gen 2 vm
    If ($vm.Generation -eq 2) {
        $firmware = Get-VMFirmware -VM $vm
        $newBootOrder = @()
        foreach ($boot in $firmware.BootOrder){
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
        } ElseIf (Test-Path $env:ProgramFiles\hyper-v\vmconnect.exe) {
            Start-Process $env:ProgramFiles\hyper-v\vmconnect.exe -ArgumentList $args -WindowStyle Normal
        } Else {
            Write-Error -Message "Could not locate vmconnect.exe in any of the usual places. " -Category OpenError
        }
        Start-VM -VM $vm
    }
}