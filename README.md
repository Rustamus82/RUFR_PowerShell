# RUFR_PowerShell

***********************************************************************************************************************************************************
ChangeLog

***********************************************************************************************************************************************************
21-03-2021 ServicedeskPowershellTools_v2.10

new redesigned script that creates, attach security group to existing usermailbox as, full access, send as and send on behalf. It also set correct language, calendar "limited details" permission for existing mailbox.

.\PS_scripts\SST\OpretSikkerhedGruppeSST.ps1

Jesper har opdateret følgende
Commit Summary
•	JohnstrupOprettelseFraExcel.ps1
•	JohnstrupOprettelseFraExcel.ps1
•	New-JohnstrupUsers.psm1
•	Added UserMenu WPF
•	UserMenu
•	run menu.ps1
•	BrugeradmSDmenu.ps1
•	Added UserMenu GUI made in WPF
File Changes
•	M BrugeradmSDmenu.ps1 (664) 
•	M PS_scripts/JohnstrupOprettelseFraExcel.ps1 (90) 
•	M PS_scripts/New-JohnstrupUsers.psm1 (441) 
•	A UserMenu.xaml (462) 

***********************************************************************************************************************************************************
13-03-2021 ServicedeskPowershellTools_v2.09
Updated login for Exchnage 2010 to 2016 SST
.\Logins\Login_SSI_SST_exch2010_DKSUND_Exchange365_ADMIN.ps1
.\Logins\Login_SSI_SST_exch2010_DKSUND_Exchange365_Variabel.ps1
.\Logins\Login_SSI_SST_exch2010_DKSUND_Exchange365_RUFR.ps1

Updated login switches
.\BrugeradmSDmenu.ps1

SST echange scripts updated to support SST, DEP, STPS og NGC
.\PS_scripts\SST\OpretDistributionsgruppeSST.ps1
.\PS_scripts\SST\OpretFællespostkasseSST.ps1
.\PS_scripts\SST\OpretMødelokaleSST.ps1
.\PS_scripts\SST\OpretSikkerhedGruppeSST.ps1

Group based licens
.\PS_scripts\SSI\OpretBrugerSSI.ps1
.\PS_scripts\SSI\Convert_fra_Shared_to_RegularlUser_plusLicensSSI.ps1

***********************************************************************************************************************************************************
16-02-2021 ServicedeskPowershellTools_v2.08

Commit Summary
•	JohnstrupOprettelseFraExcel.ps1
•	JohnstrupOprettelseFraExcel.ps1
•	JohnstrupOprettelseFraExcel.ps1
•	New-JohnstrupUsers.psm1
File Changes
•	M PS_scripts/JohnstrupOprettelseFraExcel.ps1 (168) 
•	M PS_scripts/New-JohnstrupUsers.psm1 (346) 


***********************************************************************************************************************************************************
11-01-2021 RUFR_PowerShell_v2.07
Jesper opdateret Jonstrup scripts
• added Beredskabsstyrelsen
.\PS_scripts\JohnstrupOprettelseFraExcel.ps1
.\PS_scripts\New-JohnstrupUsers.psm1

SUM foreløbigt udkomenteret da de er migreret til nyere server, som der skal laves noget nyt...
.\PS_scripts\SST\OpretDistributionsgruppeSST.ps1
.\PS_scripts\SST\OpretFællespostkasseSST.ps1
.\PS_scripts\SST\OpretMødelokaleSST.ps1
.\PS_scripts\SST\OpretSikkerhedGruppeSST.ps1

***********************************************************************************************************************************************************
04-01-2021 RUFR_PowerShell_v2.06
Jesper Jonstrup script incorporated in menu:
.\PS_scripts\JohnstrupOprettelseFraExcel.ps1
.\PS_scripts\New-JohnstrupUsers.psm1

***********************************************************************************************************************************************************
17-12-2020 RUFR_PowerShell_v2.05
All logins updated with new servers:

.\Logins   and .\Logins\Session_reconnect.ps1
-ConnectionURI https://srv-lync-fe07.ssi.ad/OcsPowershell  WMF 5.1 installed so it is possible to establish session.
#-ConnectionURI https://srv-lync-fe08.ssi.ad/OcsPowershell

.\PS_scripts\SSI\OpretBrugerSSI.ps1
Lync 'pool02.ssi.ad' changed to 'pool03.ssi.ad'


***********************************************************************************************************************************************************
01-12-2020 RUFR_PowerShell_v2.04

Bugfix OU variable og bool test for Rooms
.\PS_scripts\SSI\OpretMødelokalleSSI.ps1

All logins updated to new ExchangeOnline and added for new collegues.
.\Logins

remove pssession added on reconnects for cloud sessions.
.\Logins\Session_reconnect.ps1

***********************************************************************************************************************************************************
16-10-2020 RUFR_PowerShell_v2.03

Før den fjerner tildelt licens venter den 1000 sekunder.
.\PS_scripts\SSI\OpretFællespostkasseSSI.ps1
.\PS_scripts\SSI\OpretMødelokalleSSI.ps1

***********************************************************************************************************************************************************
22-09-2020 RUFR_PowerShell_v2.02
Corrected variable OU Path creation og distributions list in SSI.AD
.\PS_scripts\SSI\OpretDistributionsGruppeSSI_udenHak_iManagerSSI.ps1

***********************************************************************************************************************************************************
21-09-2020 RUFR_PowerShell_v2.01
Licens removed from create new user, sharedmail, convert to regular:
dksund:WIN_DEF_ATP, dksund:EMSPREMIUM - EMS and defender ATP
.\PS_scripts\SSI\OpretBrugerSSI.ps1
.\PS_scripts\SSI\Convert_fra_Shared_to_RegularlUser_plusLicensSSI.ps1
.\PS_scripts\SSI\Convert_fra_Shared_to_SecureRegularUser_PlusLicens_SSI.ps1

variable and encoding uft-8 with  bom corrected in:
.\PS_scripts\SSI\Convert_fra_Shared_to_RegularlUser_plusLicensSSI.ps1
.\PS_scripts\SSI\Convert_fra_Shared_to_SecureRegularUser_PlusLicens_SSI.ps1

***********************************************************************************************************************************************************
16-07-2020 RUFR_PowerShell_v2.00

***********************************************************************************************************************************************************
16-07-2020 RUFR_PowerShell_v2.00
logins script Changed - ALL
Call login 'admin' when on admin server. it will use your login profile user variables for login promts.

New modules requred that also can use MFA marked with *
Update-Module -Name ExchangeOnlineManagement*
Update-Module -Name PowerShellGet*
Update-Module -Name AzureAD*
Update-Module -Name msonline (old)
Update-Module -Name ActiveDirectory

.\PS_scripts\SSI - all scripts are rewriten also the logic so now it retries many times instead just wating for 3 hours

***********************************************************************************************************************************************************
03-06-2020 RUFR_PowerShell_v1.72
Fællespostkasse og mødelokale ændret timeout fra 15 til 20 efter licens tildeling.
cosmeticn cange in meny and logins
***********************************************************************************************************************************************************
02-06-2020 RUFR_PowerShell_v1.71
Følgende har fået ændret regular expression: [^a-zA-Z0-9\-_\.] som tillader de her bogstaber

.\PS_scripts\SSI\OpretFællespostkasseSSI.ps1
.\PS_scripts\SSI\OpretMødelokalleSSI.ps1
.\PS_scripts\SSI\OpretDistributionsGruppeSSI_udenHak_iManagerSSI.ps1
.\PS_scripts\SSI\OpretSikkerhedGruppeSSI_udenHak_iManagerSSI.ps1
.\PS_scripts\SST\OpretDistributionsgruppeSST.ps1
.\PS_scripts\SST\OpretFællespostkasseSST.ps1
.\PS_scripts\SST\OpretMødelokaleSST.ps1
.\PS_scripts\SST\OpretSikkerhedGruppeSST.ps1

Derudover match på 5 til 20 karakter forbedret. Lasse har hjulpet.

***********************************************************************************************************************************************************
22-04-2020 RUFR_PowerShell_v1.70
.\PS_scripts\SSI\OpretFællespostkasseSSI.ps1
.\PS_scripts\SSI\OpretMødelokalleSSI.ps1
opdateret med timeut 16 min efter tildeling af licens alle steder, manglede når den skulle gøre det første gang da var den stadig 10

***********************************************************************************************************************************************************
12-02-2020 RUFR_PowerShell_v1.69
Fællespostkasse og mødelokale ændret timeout fra 10 til 15 efter licens tildeling.

***********************************************************************************************************************************************************
26-11-2019 RUFR_PowerShell_v1.68
Srv-lync-fe05 virker ikke og er slukket, logins for lync server ændres til srv-lync-fe03.ssi.ad 
dvs alle scrupts med login opdateret under .\Logins samt \Logins\Session_reconnect.ps1

***********************************************************************************************************************************************************
14-10-2019 RUFR_PowerShell_v1.65

tilføjet login script .\Logins\Login_SSI_SST_exch2010_DKSUND_Exchange365_TIJE.ps1
tilfjet TIJE switch menu .\BrugeradmSDmenu.ps1

***********************************************************************************************************************************************************
25-09-2019 RUFR_PowerShell_v1.64

tilføjet og kan startes med bat .\ISE_scripts_only\LoggedOnUser_sessions\Check_Seesions.ps1

***********************************************************************************************************************************************************
23-09-2019 RUFR_PowerShell_v1.63
error handling loggning forbedret i:
 .\ISE_scripts_only\Group_descriptions_Owner_update_AD\Group_descriptions_Owner_update_AD.ps1 
 .\ISE_scripts_only\Update_ADuser_manager_description_CreateForEachGoup\ADuser_Manager_update_Company_descritpion_Groups.ps1

***********************************************************************************************************************************************************
20-09-2019 RUFR_PowerShell_v1.62
oprettet .\ISE_scripts_only\Group_descriptions_Owner_update_AD\Group_descriptions_Owner_update_AD.ps1 
***********************************************************************************************************************************************************
19-09-2019 RUFR_PowerShell_v1.61
oprettet: .\Logins\Login_SSI_SST_exch2010_DKSUND_Exchange365_MOKI.ps1  
oprettet: .\ISE_scripts_only\Update_ADuser_manager_description_CreateForEachGoup\ADuser_Manager_update.ps1
.\_installModules - Ryddet op i Modules, så den fylde ikke nær så meget

***********************************************************************************************************************************************************
25-07-2019 RUFR_PowerShell_v1.59
ændre timeout variabel til exchange on prem til 3 min

***********************************************************************************************************************************************************
25-07-2019 RUFR_PowerShell_v1.58

Rettet regular expression chek [^\sa-zA-Z0-9_-ÆØÅæøå] på tilladte karaktere i Display Name i scripts

.\PS_scripts\SSI\OpretDistributionsGruppeSSI_udenHak_iManagerSSI.ps1
.\PS_scripts\SST\OpretDistributionsgruppeSST.ps1

***********************************************************************************************************************************************************
02-07-2019 RUFR_PowerShell_v1.57

Opdateret licens for E5... i følgende:
Fjernedt tildeling af dksund:EMSPREMIUM og dksund:WIN_DEF_ATP ved mødelokale oprettelse og fællespostkasse

***********************************************************************************************************************************************************
02-07-2019 RUFR_PowerShell_v1.56

Opdateret licens for E5... i følgende:
.\PS_scripts\SSI\Convert_fra_Shared_to_RegularlUser_plusLicensSSI.ps1
.\PS_scripts\SSI\OpretFællespostkasseSSI.ps1
.\PS_scripts\SSI\OpretMødelokalleSSI.ps1

***********************************************************************************************************************************************************
21-06-2019 RUFR_PowerShell_v1.55

.\ISE_scripts_only\Licens Office365\Get_ALL_Licens_forBruger_runonlyISE.ps1 opdaterte til at kunne håndtere E5 licenser og Project licensers

hermed opdateret .\PS_scripts\SSI\OpretBrugerSSI.ps1 licens til E5 som følgende blevet fjernet: -RemoveLicenses dksund:ENTERPRISEPACK

***********************************************************************************************************************************************************
19-06-2019 RUFR_PowerShell_v1.54
script oprettet af EKS-ANAE@sundhedsdata.dk hermed opdateret

 .PS_scripts\SST\OpretDistributionsgruppeSST.ps1
 .PS_scripts\SST\OpretFællespostkasseSST.ps1
 .PS_scripts\SST\OpretMødelokaleSST.ps1
 .PS_scripts\SST\OpretSikkerhedGruppeSST.ps1

Dvs. nu kan man oprettet disse for SST/DEP, STPS.

****

hermed opdateret .\PS_scripts\SSI\OpretBrugerSSI.ps1 licens til E5 som følgende:
$x = New-MsolLicenseOptions -AccountSkuId "dksund:ENTERPRISEPREMIUM" -DisabledPlans "PROJECTWORKMANAGEMENT","YAMMER_ENTERPRISE","MCOSTANDARD","SHAREPOINTWAC", "SWAY", "RMS_S_ENTERPRISE"
 		Set-MsolUser -UserPrincipalName "$ADuser@dksund.dk" -UsageLocation DK
		Set-MsolUserLicense -UserPrincipalName "$ADuser@dksund.dk" -AddLicenses dksund:WIN_DEF_ATP, dksund:ENTERPRISEPREMIUM, dksund:EMSPREMIUM -RemoveLicenses dksund:ENTERPRISEPACK
		Set-MsolUserLicense -UserPrincipalName "$ADuser@dksund.dk" -LicenseOptions $x

***********************************************************************************************************************************************************
12-06-2019 RUFR_PowerShell_v1.53
Ny script oprettet af eks-@nae

 .PS_scripts\SST\OpretDistributionsgruppeSST_udenHak_iManagerSST.ps1
 .PS_scripts\SST\OpretFællespostkasseSST.ps1
 .PS_scripts\SST\OpretMødelokaleSST.ps1
 .PS_scripts\SST\OpretSikkerhedGruppeSST_udenHak_iManagerSST.ps1

Dvs. nu kan man oprettet disse for SST/DEP, STPS kommer senere..... bliver opdateret i selvsamme scripst som ekstra mulighed...

***********************************************************************************************************************************************************
01-05-2019 RUFR_PowerShell_v1.52
Opdater .PS_scripts\SSI\OpretDistributionsGruppeSSI_udenHak_iManagerSSI.ps1 at der må godt komme mellemrum i Display navn

***********************************************************************************************************************************************************
23-05-2019 RUFR_PowerShell_v1.46
Tiføjet nyt script .\ISE_scripts_only\HyperV_Create_Rebuild
* Call_rebuild_script_AsAdmin.ps1 
* HyperV-Setup-TestFrameWork_UIplusplus_AsAdmin.ps1
*and bats that calling them

***********************************************************************************************************************************************************
01-05-2019 RUFR_PowerShell_v1.45
Tiføjet nyt script .\ISE_scripts_only\GroupMemberships\add-adgroupMember_From_and_To.ps1 added loging

***********************************************************************************************************************************************************
01-05-2019 RUFR_PowerShell_v1.44
Tiføjet nyt script .\ISE_scripts_only\GroupMemberships\add-adgroupMember_From_and_To.ps1

***********************************************************************************************************************************************************
01-05-2019 RUFR_PowerShell_v1.42
tilføjet Ise script \ISE_scripts_only\SCCM\Add-Users_list_To_Specific_Collection_PS1 - SSI.ps1

***********************************************************************************************************************************************************
01-05-2019 RUFR_PowerShell_v1.41
Tilføjet tjek på regular expression for oprettelse af fællespostkasse, mødeloaker, sikkerhedsgrupper og distributionslister for ulovlig karakter
Kun følgende er lovligt: a-zA-Z0-9_-
Derudover tilføjet tjek på længde for mødelokaler eller fællespostkasse som er kun på 5 til 20.

***********************************************************************************************************************************************************
01-05-2019 RUFR_PowerShell_v1.39
Tiføjet nyt ISE script .\ISE_scripts_only\Create_ADuser_MassCreate_CSV som kan genbruges ti oprettelse af mass ad objekter

***********************************************************************************************************************************************************
01-05-2019 RUFR_PowerShell_v1.38
Tiføjet nyt ISE script hvor man kan få fat i Licensered brugere i Office 365 baseret på brugere OU i lokale ADer:
.\ISE_scripts_only\Licens Office365Get_OU_Users_Licens_runonlyISE.ps1

tilføjet .\Logins\Login_SSI_SST_exch2010_DKSUND_Exchange365_AFKH.ps1
tilføjet .\Logins\Login_SSI_SST_exch2010_DKSUND_Exchange365_ANAE.ps1

***********************************************************************************************************************************************************
17-04-2019 RUFR_PowerShell_v1.37
Tilføjet nyt ps .\ISE_scripts_only\add-adgroupMember_MassAdd.ps1
Tilføjet .\PS_scripts\SSI\OpretMødelokalleSSI.ps1 har øget vente tid til 15 min efter convertring til type "room" så licenser bliver fjernet 10 min senere
Har opdateret .\Logins\Session_reconnect.ps1 giver bedre beskrivelse hvad de forsøge at gøre

Tilføjet .\PS_scripts\SSI\OpretFællespostkasseSSI.ps1 - har øget vente tid til 15 min efter convertring til type "shared" så licenser bliver fjernet 10 min senere

***********************************************************************************************************************************************************
17-04-2019 RUFR_PowerShell_v1.35
Created new script .\ISE_scripts_only\Password_exparation_dates.ps1 kan exportere bulk eller køre på enkelt bruger i ISE
.\PS_scripts\SSI\OpretBrugerSSI.ps1 - G drev kopiering som aftalt kopiere vi ikke mere.... for vi mener det ikke bliver brugt.

***********************************************************************************************************************************************************
15-04-2019 RUFR_PowerShell_v1.34
Tilføjet .\PS_scripts\SSI\OpretMødelokalleSSI.ps1 har øget vente tid til 10 min efter convertring til type "room" så licenser bliver fjernet 10 min senere
Har opdateret .\Logins\Session_reconnect.ps1 giver bedre beskrivelse hvad de forsøge at gøre

Tilføjet .\PS_scripts\SSI\OpretFællespostkasseSSI.ps1 - har øget vente tid til 10 min efter convertring til type "shared" så licenser bliver fjernet 10 min senere

Tilføjet .\PS_scripts\SSI\OpretBrugerSSI.ps1 har øget vente tid til 3 min, så den kan rette kalender efter den har ændret det til Dansk


***********************************************************************************************************************************************************
13-02-2019 RUFR_PowerShell_v1.33
Tilføjet .\PS_scripts\Create_ADM-KONTO_forExisting_ADuser_SST_SSI.ps1
 tilføjet at der tildeles gruppe "Protected Users" som bliver tilføjet for SSI og SST, og synkroniseret fra SSI til DKSUND

***********************************************************************************************************************************************************
13-02-2019 RUFR_PowerShell_v1.32
Tilføjet .\PS_scripts\SSI\OpretBrugerSSI.ps1 tilføjet at der tildeles gruppe CM_L_DKS_CM-Users-r som bliver tilføjet kun for SDS brugere

***********************************************************************************************************************************************************
11-02-2019 RUFR_PowerShell_v1.30
Tilføjet .\PS_scripts\SSI\Activate_UM_On_User_SSI.ps1

***********************************************************************************************************************************************************
27-11-2018 RUFR_PowerShell_v1.29
rettet i .\ISE_scripts_only\_LocalAdmingroups_ForLocalAdminPC_Create_LAMG_RUFR.ps1

***********************************************************************************************************************************************************
17-07-2018 RUFR_PowerShell_v1.27
OpretMødelokalleSSI.ps1 time out på 5 minuter efter konvertering til room.

***********************************************************************************************************************************************************
02-07-2018 RUFR_PowerShell_v1.26

.\PS_scripts\SSI\OpretBrugerSSI.ps1
Tilføjer sleep 1 under Write-Host "Ændre kalender rettighed for $ADuser til 'LimitedDetails' og tilføjer 'ConciergeMobile' som kalender 'editor' "
***********************************************************************************************************************************************************
29-06-2018 RUFR_PowerShell_v1.25
Skiftet placering af LocalAdminGroups til \ISE_scripts_only\LocalAdminGroups

Ændret i _LocalAdmingroups_ForLocalAdminPC_Create_LAMG.ps1 så man kan udføre de ovenstående LAMG's scripts, så det er sti uafhægnig, og at der fjernes og
tilføjes AD modul ved hver login.

***********************************************************************************************************************************************************
08-05-2018 RUFR_PowerShell_v1.23 Rust@m
Updated Licens managment option and modification for E3 or E5... in .\ISE_scripts_only\Licens Office365
***********************************************************************************************************************************************************
08-05-2018 RUFR_PowerShell_v1.23 Rust@m
Added script .\ISE_scripts_only\sendemail\Sendemail.ps1  that ablle to send files that are created via email/Powershell

***********************************************************************************************************************************************************
08-05-2018 RUFR_PowerShell_v1.22 Rust@m
***********************************************************************************************************************************************************
OpretFællespostkasseSSI.ps1 - canged places that objekt will be mail enabled first, then Security group and then later gives licens for maileablet Object
***********************************************************************************************************************************************************
08-05-2018 RUFR_PowerShell_v1.19 Rust@m
New login scrips created for GHK and AFKH.
New Script is created for mass removal of a specific AD group: Remove_Group_Membership_MassUpdate_on_Users.ps1

***********************************************************************************************************************************************************
08-05-2018 RUFR_PowerShell_v1.19 Rust@m
Tilføjet 45 secunder delay før policy bliver eksekveret:
Lync Client policy to be -ClientPolicy KunADfoto

***********************************************************************************************************************************************************
08-05-2018 RUFR_PowerShell_v1.19 Rust@m
***********************************************************************************************************************************************************
New script created: Get-ADuserMembership.ps1
Changed Lync Client policy to be -ClientPolicy first and -Indenity after in OpretBrugerSSI.ps1

***********************************************************************************************************************************************************
16-03-2018 RUFR_PowerShell_v1.14 Rust@m
***********************************************************************************************************************************************************
I følgende scripts:
Convert_fra_Regular_to_SharedMail_removeLicensSSI.ps1
Convert_fra_Shared_to_RegularlUser_plusLicensSSI.ps1
Convert_fra_Shared_to_SecureRegularUser_PlusLicens_SSI.ps1
Tilføjet reconnect sessioner der hvor den skal bruge det, fra globale variabler

I følgende scripts:
OpretMødelokalleSSI.ps1
OpretFællespostkasseSSI.ps1
OpretBrugerSSI.ps1

Efter ændring af sprog til DK har øget sleep fra 60 til 120 sekunder


***********************************************************************************************************************************************************
16-03-2018 RUFR_PowerShell_v1.13 Rust@m
***********************************************************************************************************************************************************
OpretFællespostkasseSSI.ps1
OpretMødelokalleSSI.ps1
Tilføjet reconnect efter tilknytning af grupper 
***********************************************************************************************************************************************************
16-03-2018 RUFR_PowerShell_v1.12 Rust@m
***********************************************************************************************************************************************************
OpretFællespostkasseSSI.ps1
Added check of existing ADobjekt, if exist do the rest whatever needed, If not create new., Do not run it on Adobjekt that are not type of SharedMail
Added attribute GivenName as the Object name. If servicedsk is objekt name, the given name will be servicedesk.

Found out how is to to call login scripts in Powershell ISE! When they are not in current directory and following stamp can be added anywhere in folders 
or subfulders scripts, and still can call correct login script, from parent folder.
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#PSVersion 5 Script made/assembled by Rust@m 16-03-2018
<#Login RUFR
$CommandPath = (Get-Location).Path | Split-Path -Parent; $script = "$CommandPath\Logins\Login_SSI_SST_exch2010_DKSUND_Exchange365_RUFR.ps1"; & $script
cls
#>
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Following scripts opdated with better reconnect session script, which is now it's own script that resides here "RUFR_PowerShell_v1.12\Logins\Session_reconnect.ps1"
OpretBrugerSSI
OpretDistributionsGruppeSSI_udenHak_iManagerSSI
OpretFællespostkasseSSI
OpretMødelokalleSSI
OpretSikkerhedGruppeSSI_udenHak_iManagerSSI

All logins scripts revised and updated to use Global Variables in all instances that are used.

Created ChangeLog.txt

***********************************************************************************************************************************************************
01-03-2018 RUFR_PowerShell_v1.10 Rust@m
***********************************************************************************************************************************************************
BrugeradmSDmenu.ps1
Globale variables changed to $PSScriptRoot. Earlier it was defined as: #$WorkingDir = Convert-Path .
Now script is able to return for a rerun, it was not possible previously.

Whole Menu should be now started with BrugerAdmMenu.bat to avoid looking at "Cosmetical errors", as result of implemeted security messures in AD. 
Details:
When Run as Powershell was chosen.
which executes this default this:
"C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" "-Command" "if((Get-ExecutionPolicy ) -ne 'AllSigned') { Set-ExecutionPolicy -Scope Process Bypass }; & '%1'" 
See more onenote:https://d.docs.live.net/ade9c9b8229a18b1/Dokumenter/RF-s/AD%20and%20PS.one#Right%20click%20and%20%22Run%20with%20PowerShell%22%20Evasive%20Error&section-id={D07EE802-49EB-4F69-A2D9-1C1C58C9657C}&page-id={A9242EAE-877A-46C7-A431-8258A77FA8CD}&end

OpretBrugerSSI.ps1
Now also enables Lync-to-Lync with the default policies.


***********************************************************************************************************************************************************
16-10-2017 RUFR_PowerShell Rust@m
***********************************************************************************************************************************************************
Global vriables implemented so "C:\RUFR_PowerShell_vX.XX\Logins" scripts would work in any other called script, so login would work Globaly and stop asking 
for credentials all the time.

