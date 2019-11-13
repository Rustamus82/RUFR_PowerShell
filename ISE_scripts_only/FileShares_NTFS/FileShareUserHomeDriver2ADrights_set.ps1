$stampDate = Get-Date -Format “yyyy/MM/dd”
$log = $stampDate+"_FileShareUserHomeDriverOwener_set.log"
$WorkingDir =  (Get-Location).Path ;$log = "$WorkingDir\$log"
Import-Module "$WorkingDir\AD.psm1"


#*********************************************************************************************************************************************
#PS driver creattion
#*********************************************************************************************************************************************
$Global:UserCredDKSUND = Get-Credential -Message 'Enter Password'  "dksund\adm-rufr"
#$Global:UserCredSSI = Get-Credential -Message 'Enter Password'  "ssi\adm-rufr"
$Global:FileShare = "\\s-fil08-p.dksund.dk\EksBrugere"


#PSdrive blev oprettet ved login script, som er ikke en del af den her execution.
Write-Host " Opretter PSdrive til FileShare in DKSUND filseshare" -foregroundcolor Cyan
if (-not(Get-PSDrive 'FileShare' -ErrorAction SilentlyContinue)) {
    New-PSDrive –Name 'FileShare' –PSProvider FileSystem "$Global:FileShare" -Credential $Global:UserCredDKSUND
    #alternativet creds: –Credential $(Get-Credential -Message 'Enter Password' -UserName 'SST.DK\adm-snt') 
     
} Else {
    Write-Output -InputObject "PSDrive $Global:FileShare already exists"
}


<# 
#Get-PSDrive
Set-Location -Path 'FileShare:' 

Write-Host "Skifter til FileShare" -foregroundcolor Yellow
Set-Location -Path 'FileShare:'

Remove-PSDrive -Name FileShare -Force
cls
#>


Set-Location -Path 'FileShare:'
$Folders = Get-ChildItem 
$Folders.Count

foreach ($item in $Folders)
{
    $UserPersonalDrivePathClean = $item.FullName
    $UserStringNameDKSUND = "dksund\" + $item.Name
    $UserStringNameSSI = "ssi\" + $item.Name
       
    "Updating NTFS accress rules and Owner on $Global:FileShare : {0} " -f $item.Name | Out-File $log  -Append
    
    try
    {
        Set-NtfsUserRightsOnPath -path $UserPersonalDrivePathClean -user $UserStringNameDKSUND -rights "Read, Write, Modify, DeleteSubdirectoriesAndFiles" -InheritanceF 'ContainerInherit,ObjectInherit' -PropagationF None -allowordeny Allow | fl *
    }
    catch 
    {
        "Error on Updating NTFS accress rules in AD: {0} " -f $UserStringNameDKSUND | Out-File $log  -Append
        $_.Exception.message | Out-File $log -Append
    }

    try
    {
        Set-NtfsUserRightsOnPath -path $UserPersonalDrivePathClean -user $UserStringNameSSI -rights "Read, Write, Modify, DeleteSubdirectoriesAndFiles" -InheritanceF 'ContainerInherit,ObjectInherit' -PropagationF None -allowordeny Allow | fl *
    }
    catch 
    {
        "Error on Updating NTFS accress rules in AD: {0} " -f $UserStringNameSSI | Out-File $log  -Append
        $_.Exception.message | Out-File $log -Append
    }    
    
    $ACL = Get-ACL $UserPersonalDrivePathClean
    $Group = New-Object System.Security.Principal.NTAccount("DKSUND\dks_l_file8managers_o")
    $ACL.SetOwner($Group)
    Set-Acl -Path $UserPersonalDrivePathClean -AclObject $ACL
    
    
    <# foreach ($group in $SecurityGroupDC.SamAccountName) {
        Set-NtfsUserRightsOnPath -path $UserPersonalDrivePathClean -user "$domain\$group" -rights "full" -InheritanceF 'ContainerInherit,ObjectInherit' -PropagationF None -allowordeny Allow
    }
    foreach ($group in $SecurityGroupNoneDC.SamAccountName) {
        Set-NtfsUserRightsOnPath -path $UserPersonalDrivePathClean -user "$domain\$group" -rights "full" -InheritanceF 'ContainerInherit,ObjectInherit' -PropagationF None -allowordeny Allow
    }#>   
}




$NtfsUserRigtsExecution = foreach ($item in $Folders)
{
    $UserPersonalDrivePathClean = $item.FullName
    $UserStringNameDKSUND = "dksund\" + $item.Name
    $UserStringNameSSI = "ssi\" + $item.Name
    
    get-acl -Path $item.Name | fl
    
}
$NtfsUserRigtsExecution #| Out-File $log -Append



get-acl -Path rufr | fl *
get-acl -Path XPAFO | fl






#udfør på enkelte mappe
$rufr = Get-ChildItem -Filter '*rufr*'

$rufr | fl * -Force

$NtfsUserRigts = foreach ($item in $rufr) 
{
    
    
    
    
    $UserPersonalDrivePathClean = $item.FullName
    $UserStringNameDKSUND = "dksund\" + $item.Name
    $UserStringNameSSI = "ssi\" + $item.Name
    
    Set-NtfsUserRightsOnPath -path $UserPersonalDrivePathClean -user $UserStringNameDKSUND -rights "Read, Write, Modify, DeleteSubdirectoriesAndFiles" -InheritanceF 'ContainerInherit,ObjectInherit' -PropagationF None -allowordeny Allow
    Set-NtfsUserRightsOnPath -path $UserPersonalDrivePathClean -user $UserStringNameSSI -rights "Read, Write, Modify, DeleteSubdirectoriesAndFiles" -InheritanceF 'ContainerInherit,ObjectInherit' -PropagationF None -allowordeny Allow
    
    
    #$ACL = Get-ACL $UserPersonalDrivePathClean
    #$Group = New-Object System.Security.Principal.NTAccount("$UserStringNameDKSUND")
    #$ACL.SetOwner($Group)
    #Set-Acl -Path $UserPersonalDrivePathClean -AclObject $ACL
    
    
    <# foreach ($group in $SecurityGroupDC.SamAccountName) {
        Set-NtfsUserRightsOnPath -path $UserPersonalDrivePathClean -user "$domain\$group" -rights "full" -InheritanceF 'ContainerInherit,ObjectInherit' -PropagationF None -allowordeny Allow
    }
    foreach ($group in $SecurityGroupNoneDC.SamAccountName) {
        Set-NtfsUserRightsOnPath -path $UserPersonalDrivePathClean -user "$domain\$group" -rights "full" -InheritanceF 'ContainerInherit,ObjectInherit' -PropagationF None -allowordeny Allow
    }#>
        
} 

Write-Output $NtfsUserRigts

$NtfsUserRigts | fl *

$NtfsUserRigts.AccessToString



$allebrugere = Get-Content $log | select-string -SimpleMatch \ 


$allebrugereudenad = $allebrugere -replace 'ssi','' -replace 'dksund',''

$allebrugereudenad[0].Remove(0,72)


$allebrugereudenadbegge = foreach ( $item in $allebrugereudenad) {

    $item.Remove(0,72)

}

$allebrugereudenadbegge | Group-Object | Where-Object -FilterScript {$_.count -eq 2}