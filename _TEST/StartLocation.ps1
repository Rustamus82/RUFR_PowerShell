# Get Program location  $disk="z:";  $sti="ps1\u"; $fil="sql-macro.ps1"
$h=$PSCommandPath -Split("\\")
$disk=$h[0]
$fil=$h[-1]
If($h.Count -lt 3){$sti=''}elseif($h.Count -eq 3){$sti=$h[1]}else{$h=$h[1..($h.Count-2)];$sti=$h -join("\")}
$disk
$fil
$sti
$h
Set-Location $disk
Set-Location $sti



#$path =  "$env:SystemDrive\Hyper-V\ReBuildVM_3.ps1"
get-vm | ogv -PassThru | C:\Hyper-V\ReBuildVM_3.ps1


pause