Receiver Clean-up Utility
* Readme *

The following processes will be terminated before the utility begins to remove Receiver:

pnamain.exe
ssonsvr.exe
windocker.exe
browser.exe
selfservice.exe
selfserviceplugin.exe
receiver.exe
updater.exe
wfcrun32.exe
wfica32.exe
concentr.exe
authmansvr.exe
redirector.exe
radeobj.exe
ARPriv service (Citrix Receiver Install Helper Service)
webhelper.exe

* Files and Directories *
The utility deletes the following files and directories if they are available:

%programdata%\Microsoft\Windows\Start Menu\Programs\Citrix Receiver.lnk
%programdata%\Microsoft\Windows\Start Menu\Programs\Startup\Receiver.lnk
%programdata%\Microsoft\Windows\Start Menu\Programs\Startup\Online plug-in.lnk
%programdata%\Microsoft\Windows\Start Menu\Programs\Citrix\Online plug-in.lnk
%programdata%\Microsoft\Windows\Start Menu\Programs\Citrix\Receiver.lnk
%programdata%\Citrix\Citrix Receiver*
%programdata%\Citrix\Citrix Workspace*
%appdata%\ICAClient
%appdata%\Citrix\Receiver
%appdata%\Citrix\AuthManager
%appdata%\Citrix\SelfService
%systemdrive%\users\default\appdata\local\citrix\receiver
%systemdrive%\users\default\appdata\local\citrix\SelfService
%systemdrive%\users\default\appdata\local\citrix\AuthManager
%localappdata%\Citrix\Receiver
%localappdata%\Citrix\AuthManager
%localappdata%\Citrix\SelfService
%programfiles%\citrix\ICA client
%programfiles%\citrix\authmanager
%programfiles%\Citrix\Browser
%programfiles%\citrix\selfserviceplugin
%programfiles%\citrix\Receiver
%programfiles%\Citrix\Online Plugin
%programfiles%\Citrix\Citrix Screen Casting for Windows
%systemdrive%\users\*\Appdata\Local\Citrix\Citrix Receiver*
%systemdrive%\users\*\Appdata\Local\Citrix\Citrix Workspace*
%systemdrive%\users\*\Appdata\Local\Citrix\Receiver
%systemdrive%\users\*\Appdata\Local\Citrix\AuthManager
%systemdrive%\users\*\Appdata\Local\Citrix\SelfService
%systemdrive%\users\*\Appdata\Local\Citrix\PNAgent
%systemdrive%\users\*\Appdata\Local\Citrix\ICA Client
%systemdrive%\users\*\Appdata\Local\Citrix\Citrix Screen Casting for Windows

* User Profiles *
The Receiver folder for all user profiles except for the currently logged in user will be deleted.

* Registry Values *
The utility deletes the following registry values and keys if they exist:

HKLM\Software\Microsoft\Windows\Currentversion\Run\  Value:ConnectionCenter
HKLM\Software\Microsoft\Windows\Currentversion\Run\  Value:CitrixReceiver
HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\Folders	Value:Citrix\Receiver*
HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\Folders	Value:Citrix\SelfService*
HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\Folders	Value:Citrix\ICA Client*
HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\Folders	Value:Citrix\AuthManager*
HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\Folders	Value:Citrix\Browser*
HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\Folders	Value:Citrix\Citrix Screen Casting for Windows*

HKCR\ica
HKCR\.ica
HKCR\wfica
HKCR\WinFrameICA
HKCR\Citrix.AuthManager
HKCR\Citrix.ICAClient
HKCR\Mime\Database\Content Type\application/x-ica
HKCR\Installer\UpgradeCodes\9b123F490B54521479D0EDD389BCACC1
HKCR\CLSID that starts with {238F
HKCR that starts with citrix.icaclient
HKCU\Software\Citrix\ICA Client
HKCU\Software\Citrix\PNAgent
HKCU\Software\Citrix\Dazzle
HKCU\Software\Citrix\PrinterProperties
HKCU\Software\Citrix\Receiver
HKCU\Software\Citrix\XenDesktop\DesktopViewer

Entries in HKLM\Software\Classes\Installer\Products\ that relate to the following:
SSONWrapper and PNAWrapper components
HKLM\Microsoft\Windows\CurrentVersion\Uninstall\CitrixOnlinePluginFull
HKLM\Microsoft\Windows\CurrentVersion\Uninstall\CitrixOnlinePluginPackWeb
HKLM\Software\Citrix\AuthManager
HKLM\Software\Citrix\Browser
HKLM\Software\Citrix\CitrixCAB
HKLM\Software\Citrix\Dazzle
HKLM\Software\Citrix\ICA Client
HKLM\Software\Citrix\ReceiverInside
HKLM\Software\Citrix\PNAgent
HKLM\Software\Citrix\PluginPackages\XenAppSuite
HKLM\Software\Citrix\XenDesktop\DesktopViewer
HKLM\Software\Citrix\Install\{94F321B9-45B0-4125-970D-DE3D98CBCA1C}
HKLM\Software\Citrix\Install\ICA Client
HKLM\Software\Citrix\Install\PNAgent
HKLM\Software\Citrix\Install\DesktopViewer
HKLM\Software\Citrix\Install\ReceiverInsideForOnline
HKLM\Software\Citrix\Install\MUI
HKLM\Software\Citrix\Receiver
HKLM\Software\Citrix\Install\{70755658-255B-4EA6-BF8F-7188BDCFF7D0}
HKLM\Software\Citrix\Install\SSON
HKLM\Software\Microsoft\Windows\CurrentVersion\Uninstall\CitrixOnlinePluginFull
HKLM\System\CurrentControlSet\Services\PnSson
HKLM\System\ControlSet001\Services\PnSson
HKLM\System\ControlSet002\Services\PnSson
HKLM\Software\Microsoft\Windows\Currentversion\Installer\UserData\S-1-5-18\Components\AAC19809250CF4140B060EBD01517B77

Entries in:
HKLM\Software\Microsoft\Windows\CurrentVersion\Installer\UserData
HKLM\Software\Classes\Installer\Products
HKLM\Software\Microsoft\Windows\CurrentVersion\Uninstall
HKCR\Installer\Products

For the following:
Online Plug-in
Citrix Receiver(DV)
Citrix Receiver(PNA)
Citrix Receiver (HDX Flash Redirection)
Citrix Receiver(SSON)
Citrix Receiver(USB)
Citrix Receiver(Aero)
Citrix Online plug-in (PNA)
Citrix Online plug-in (SSON)
Citrix Receiver Inside
Citrix online plug-in (web)
Citrix online plug-in (PNA)
Citrix online plug-in (USB)
Citrix online plug-in (HDX)
Citrix online plug-in (DV)
Self-service plug-in
Citrix Web Helper
Citrix Workspace
Citrix Screen Casting for Windows
Citrix Authentication Manager
Citrix Receiver Updater and Citrix offline plug-in components

The following registry keys are modified by the utility to remove PnSson provider from the Provider Order value:

HKLM\System\ControlSet001\Control\networkprovider\HwOrder
HKLM\System\ControlSet001\Control\NetworkProvider\Order
HKLM\System\ControlSet002\Control\networkprovider\HwOrder
HKLM\System\ControlSet002\Control\networkprovider\Order
HKLM\System\CurrentControlSet\Control\networkprovider\HwOrder
HKLM\System\CurrentControlSet\Control\networkprovider\Order

The following entries in the HKEY_USERS registry for each user on the machine will be removed:

\Software\citrix\AuthManager
\Software\citrix\Browser
\Software\citrix\CitrixCAB
\Software\citrix\ICA Client
\Software\citrix\WorkspaceHub
\Software\citrix\Dazzle
\Software\citrix\Receiver
\Software\Citrix\ReceiverInside
\Software\Citrix\PluginPackages
\Software\citrix\PrinterProperties
\Software\citrix\PNAgent
\Software\citrix\Program Neighborhood Agent
\Software\Citrix\HDXRealTime
\Software\Citrix\HDXRMEP
\Software\Citrix\RTMediaEngineSRV
\Software\Citrix\XenDesktop\DesktopViewer
\Software\Microsoft\Windows\CurrentVersion\Uninstall\CitrixOnlinePluginFull
\Software\Microsoft\Windows\CurrentVersion\Uninstall\CitrixOnlinePluginPackWeb