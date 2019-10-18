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
#Start PowerShell som 'admin'

#Se tilgængelige VM's
#get-vm

## Se VMs i OVG:
#get-vm | ogv -PassThru

#*Lasses Rebuild Script
#get-vm | ogv -PassThru | C:\Scripts\ReBuildVM_3.ps1

try
{
    $path =  "$env:SystemDrive\Hyper-V\ReBuildVM_3.ps1"
    get-vm | ogv -PassThru | & $path
}
catch [System.Exception]
{
    Write-Host
    Write-Host
    Write-Host
    Write-Host
    Write-Host
    Write-Host "                                     [Exception Error]               " -ForegroundColor Red
    Write-Host
    Write-Host "           >>>>>>>>>>>> Achtung!!! Achtung!!! Atención!!! Atención!!!  <<<<<<<<<<<< " -ForegroundColor Red
    Write-Host
    Write-Host "    [Cause nr 1] Probably Call_rebuild_script_AsAdmin.bat not startet as Admin. " -ForegroundColor Yellow
    Write-Host "    [Solution nr 1] Please right click on the Call_rebuild_script_AsAdmin.bat and choose ad Administrator. " -ForegroundColor Green
    Write-Host
    Write-Host "    [Cause nr 2] Probably VM had a check point and the Harddisk is not attached to this VM anymore. " -ForegroundColor Yellow
    Write-Host "    [Solution nr 2] Please re-attache HDD to VM and try again" -ForegroundColor Green
    Write-Host
    Write-Host "    [Cause nr 3] Probably You didn't choose any VMs to reinstall in Out Of Grid GUI. And just clicked on [X] " -ForegroundColor Yellow
    Write-Host "    [Solution nr 3] Please ignore the Error message. " -ForegroundColor Green
    Write-Host
    Write-Host
    pause
}
finally
{
    
    sleep 3
}
