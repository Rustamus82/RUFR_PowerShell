#suspend bitlocker once
Suspend-BitLocker -MountPoint "$env:SystemDrive" -RebootCount 1
#set for Lenovo
(gwmi -class Lenovo_SetBiosSetting –namespace root\wmi).SetBiosSetting("SecureBoot,Enable,Bios2tal,ascii,us")
#save
(gwmi -class Lenovo_SaveBiosSettings -namespace root\wmi).SaveBiosSettings("Bios2tal,ascii,us”)