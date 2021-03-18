$xaml = Get-Content -Path 'C:\RUFR_PowerShell\UserMenu.xaml' -Encoding UTF8

# Grid.Row is incrementet by one from highest to lowest
[int]$HighestRowNumber = 27
[int]$LowestRowNumber = 11
for ($i = $HighestRowNumber; $i -ge $LowestRowNumber; $i--) {

    $xaml = $xaml -replace "Grid.Row=`"$i`"", "Grid.Row=`"$($i+1)`""
    #Write-Output $i
}
$xaml | Set-Content -Path 'C:\RUFR_PowerShell\UserMenu.xaml' -Encoding UTF8
