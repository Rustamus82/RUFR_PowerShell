#PSVersion 5 Script made/assembled by Rust@m 19-09-2019
<#Login RUFR all AD login, Hybrid and o365
$CommandPath = (Get-Location).Path | Split-Path -Parent|Split-Path -Parent; $script = "$CommandPath\Logins\Login_SSI_SST_exch2010_DKSUND_Exchange365_RUFR.ps1"; & $script; 
$WorkingDir = Convert-Path .

# Change to correct Psdriver path
#Get-PSDrive
Set-Location -Path 'SSIAD:' 
Set-Location -Path 'SSTAD:'
Set-Location -Path 'DKSUNDAD:'

#error handling - https://www.gngrninja.com/script-ninja/2016/6/5/powershell-getting-started-part-11-error-handling
$Error[0]| gm
$Error[0].InvocationInfo.Line
$error[0].Exception | Get-Member
$error[0].Exception.message

cls
#>


## mass update $collection
#Get content from file nee to set location where the source files is
$stampDate = Get-Date -Format “yyyy/MM/dd”
$log = $stampDate+"_log.txt"
$WorkingDir = Convert-Path . ;$log = "$WorkingDir\$log"
$ADgroups = Import-CSV "$WorkingDir\STPxAD-grupper.CSV" -Delimiter ";" -Encoding UTF8

$ADgroups.Navn
$ADgroups.Ejer
$ADgroups.Beskrivelse


Set-Location -Path 'DKSUNDAD:'
foreach ($item in $ADgroups)
{
    "$('[{0:yyyy/mm/dd} {0:HH:mm:ss}]' -f (Get-Date)) retriving & updating Description and Owner in AD: {0} " -f $item.Navn| Out-File $log  -Append
    
    try
    {
        Get-ADGroup -Identity $item.Navn |Set-ADGroup -ManagedBy $item.Ejer -ErrorAction Stop
        Get-ADGroup -Identity $item.Navn |Set-ADGroup -Description $item.Beskrivelse -ErrorAction Stop
    }
    catch 
    {
        $_.Exception.message | Out-File $log -Append
    }   
}