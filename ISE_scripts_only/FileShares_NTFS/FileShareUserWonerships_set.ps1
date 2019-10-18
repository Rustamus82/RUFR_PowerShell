$installdir =  (Get-Location).Path
Import-Module ((Get-ChildItem "$installdir" -Filter "AD.psm1").FullName)

#*********************************************************************************************************************************************
#PS driver creattion
#*********************************************************************************************************************************************
$Global:UserCredDKSUND = Get-Credential -Message 'Enter Password'  "dksund\adm-rufr"
$Global:UserCredSSI = Get-Credential -Message 'Enter Password'  "ssi\adm-rufr"
$Global:FileShare = "\\s-fil08-p.dksund.dk\EksBrugere"

$Global:FileShare = "\\s-inf-fil-05-p.ssi.ad\SDSBrugere"


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

foreach ($item in $Folders)
{
    $item   
}


get-acl -Path rufr | fl
Get-Acl -Path  gabu |fl
get-acl -Path XALKT | fl





$rufr = Get-ChildItem -Filter '*rufr*'

$rufr | fl * -Force

$NtfsUserRigts = foreach ($item in $rufr) 
{


            

            $UserPersonalDrivePathClean = $item.FullName
            $UserStringNameDKSUND = "dksund\" + $item.Name
            $UserStringNameSSI = "ssi\" + $item.Name

            Set-NtfsUserRightsOnPath -path $UserPersonalDrivePathClean -user $UserStringNameDKSUND -rights "Read, Write, Modify, DeleteSubdirectoriesAndFiles" -InheritanceF 'ContainerInherit,ObjectInherit' -PropagationF None -allowordeny Allow
            Set-NtfsUserRightsOnPath -path $UserPersonalDrivePathClean -user $UserStringNameSSI -rights "Read, Write, Modify, DeleteSubdirectoriesAndFiles" -InheritanceF 'ContainerInherit,ObjectInherit' -PropagationF None -allowordeny Allow


            $ACL = Get-ACL $UserPersonalDrivePathClean
            $Group = New-Object System.Security.Principal.NTAccount("$UserStringNameSSI")
            $ACL.SetOwner($Group)
            Set-Acl -Path $UserPersonalDrivePathClean -AclObject $ACL


           <# foreach ($group in $SecurityGroupDC.SamAccountName) {
                Set-NtfsUserRightsOnPath -path $UserPersonalDrivePathClean -user "$domain\$group" -rights "full" -InheritanceF 'ContainerInherit,ObjectInherit' -PropagationF None -allowordeny Allow
            }
            foreach ($group in $SecurityGroupNoneDC.SamAccountName) {
                Set-NtfsUserRightsOnPath -path $UserPersonalDrivePathClean -user "$domain\$group" -rights "full" -InheritanceF 'ContainerInherit,ObjectInherit' -PropagationF None -allowordeny Allow
            }#>
        
} 

Write-Output $NtfsUserRigts