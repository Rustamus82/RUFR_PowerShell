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
#$Global:UserCredDksund = Get-Credential "$env:USERNAME@dksund.dk" -Message "DKSUND AD login, Exchange Online & Hybrid"
$Global:UserCredDksund = Get-Credential "adm-rufr@dksund.dk" -Message "DKSUND AD login, Exchange Online & Hybrid"
$Computername = Read-Host -Prompt "Compuername"
Test-Connection -ComputerName $Computername
#Enable remoteregistry
#Enable remoteregistry via cmd: sc \\TST005396 config remoteregistry start= demand
Set-Service -Name RemoteRegistry -ComputerName $Computername -StartupType Manual
#Set-Service -Name RemoteRegistry -ComputerName . -StartupType Manual
HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server

