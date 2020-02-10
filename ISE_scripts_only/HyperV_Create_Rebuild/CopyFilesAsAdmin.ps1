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
Copy-Item -Path "$WorkingDir\ReBuildVM_3.ps1" -Destination "$env:SystemDrive\Hyper-V\" -Force
Copy-Item -Path "$WorkingDir\HyperV-Setup-TestFrameWork_UIplusplus_AsAdmin.ps1" -Destination "$env:SystemDrive\Hyper-V\" -Force -Verbose
Copy-Item -Path "$WorkingDir\HyperV-Setup-TestFrameWork_UIplusplus_AsAdmin.bat" -Destination "$env:SystemDrive\Hyper-V\" -Force -Verbose
Copy-Item -Path "$WorkingDir\Reinstall_VM_script_AsAdmin.ps1" -Destination "$Env:PUBLIC\desktop\" -Force
Copy-Item -Path "$WorkingDir\Reinstall_VM_script_AsAdmin.bat" -Destination "$Env:PUBLIC\desktop\" -Force -Verbose

sleep 4