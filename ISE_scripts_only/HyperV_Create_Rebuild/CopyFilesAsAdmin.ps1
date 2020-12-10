#PSVersion 5 Script made/assembled by Rust@m 15-05-2019
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
#*********************************************************************************************************************************************

#Copy rebuild scripts bats
$WorkingDir = Convert-Path .
New-Item -Path "Hyper-V" -ItemType Directory -Force
New-Item -Path "$env:SystemDrive\Hyper-V" -ItemType Directory -ErrorAction SilentlyContinue
#Copy-Item -Path "$PSScriptRoot\ReBuildVM_3.ps1" -Destination "\Hyper-V\" -Force -Verbose
#Copy-Item -Path "$PSScriptRoot\Reinstall_VM_script_AsAdmin.ps1" -Destination "$Env:PUBLIC\desktop\" -Force -Verbose
#Copy-Item -Path "$PSScriptRoot\Reinstall_VM_script_AsAdmin.bat" -Destination "$Env:PUBLIC\desktop\" -Force -Verbose
#Copy-Item -Path "$PSScriptRoot\HyperV-RemoteService-WinRM.bat" -Destination "$Env:PUBLIC\desktop\" -Force -Verbose
#Copy-Item -Path "$PSScriptRoot\HyperV-RemoteService-WinRM.ps1" -Destination "$Env:PUBLIC\desktop\" -Force -Verbose


Copy-Item -Path "$PSScriptRoot\Reinstall_VM_script_AsAdmin.ps1" -Destination "$Env:PUBLIC" -Force -Verbose
Copy-Item -Path "$PSScriptRoot\Reinstall_VM_script_AsAdmin.bat" -Destination "$Env:PUBLIC" -Force -Verbose
Copy-Item -Path "$PSScriptRoot\HyperV-RemoteService-WinRM.bat" -Destination "$Env:PUBLIC" -Force -Verbose
Copy-Item -Path "$PSScriptRoot\HyperV-RemoteService-WinRM.ps1" -Destination "$Env:PUBLIC" -Force -Verbose


Copy-Item -Path "$env:SystemDrive\HyperV_Create_Rebuild\Reinstall_VM_script_AsAdmin.ps1" -Destination "$env:USERPROFILE" -Force -Verbose
Copy-Item -Path "$env:SystemDrive\HyperV_Create_Rebuild\Reinstall_VM_script_AsAdmin.bat" -Destination "$env:USERPROFILE" -Force -Verbose
Copy-Item -Path "$env:SystemDrive\HyperV_Create_Rebuild\HyperV-RemoteService-WinRM.bat" -Destination "$env:USERPROFILE" -Force -Verbose
Copy-Item -Path "$env:SystemDrive\HyperV_Create_Rebuild\HyperV-RemoteService-WinRM.ps1" -Destination "$env:USERPROFILE" -Force -Verbose

sleep 4