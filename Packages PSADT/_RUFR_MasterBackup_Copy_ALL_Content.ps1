#PSVersion 5 Script made/assembled by Rust@m 13-07-2017
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

$WorkingDir = Convert-Path .

#Remove-Item G:\RUFR_PowerShell\ -Recurse -Force -Verbose
Copy-Item $PSScriptRoot G:\ -Recurse -Force -Verbose


#Remove-Item C:\Users\rufr\OneDrive\Dokumenter\Scripts\RUFR_PowerShell -Recurse -Force -Verbose
Copy-Item $PSScriptRoot C:\Users\rufr\OneDrive\Dokumenter\Scripts\ -Recurse -Force -Verbose

sleep 3