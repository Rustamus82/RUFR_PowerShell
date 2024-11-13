#Set-Executionpolicy RemoteSigned
$days=14 #You can change the number of days here
$days_BLG_Files = 3 
 


# Modify the drive and paths as needed
$ExchangeInstallRoot = "C"
$IISLogPath="inetpub\logs\LogFiles\"
$ExchangeLoggingPath="Program Files\Microsoft\Exchange Server\V15\Logging\"
$ExchangeLoggingPath1="Program Files\Microsoft\Exchange Server\V15\Logging\HttpProxy\Mapi"
$ETLLoggingPath="Program Files\Microsoft\Exchange Server\V15\Bin\Search\Ceres\Diagnostics\ETLTraces\"
$ETLLoggingPath2="Program Files\Microsoft\Exchange Server\V15\Bin\Search\Ceres\Diagnostics\Logs"
$DailyPerfLogs="Program Files\Microsoft\Exchange Server\V15\Logging\Diagnostics\DailyPerformanceLogs"



Write-Host "Removing IIS and Exchange logs; keeping last" $days "days"
 
Function CleanLogfiles($TargetFolder){
  if($TargetFolder -like "inetpub\logs\LogFiles\"){
    $ExchangeInstallRoot = "E"
    $days = 90 
  }  
  $TargetFolder = "\\$E15Server\$ExchangeInstallRoot$\$TargetFolder"
  write-host -debug -ForegroundColor Yellow $TargetFolder
    if (Test-Path $TargetFolder) {
        $Now = Get-Date
        $LastWrite = $Now.AddDays(-$days)
        $Files = Get-ChildItem $TargetFolder  -Recurse | Where-Object {$_.Name -like "*.log" -or $_.Name -like "*.etl"}  | where {$_.lastWriteTime -le "$lastwrite"} | Select-Object FullName  
        foreach ($File in $Files)
            {
               $FullFileName = $File.FullName  
               Write-Host "Deleting file $FullFileName"; 
               Remove-Item $FullFileName -ErrorAction SilentlyContinue | out-null
            }
        $LastWrite =$Now.AddDays(-$days_BLG_Files)
        $blgs = Get-ChildItem $TargetFolder  -Recurse | Where-Object {$_.Name -like "*.blg"}  | where {$_.lastWriteTime -le "$lastwrite"} | Select-Object FullName
        foreach ($blg in $blgs)
            {
            $FullFileName = $Blg.FullName  
            Write-Host "Deleting file $FullFileName"; 
            Remove-Item $FullFileName -ErrorAction SilentlyContinue | out-null
            }  
       }   
    Else {
        Write-Host "The folder $TargetFolder doesn't exist! Check the folder path!" -ForegroundColor "red"
        }
}
 
#$Ex2013 = Get-ExchangeServer | Where {$_.IsE15OrLater -eq $true}
$E15Server = "hubsrv.company.com"
CleanLogfiles($DailyPerfLogs)
CleanLogfiles($IISLogPath)
CleanLogfiles($ExchangeLoggingPath)
CleanLogfiles($ExchangeLoggingPath1)
CleanLogfiles($ETLLoggingPath)
CleanLogfiles($ETLLoggingPath2)



