#PSVersion 5 Script made/assembled by Rust@m 13-07-2017
cls
function Show-Menu {
     param (
          [string]$Title = 'Sundhedsdatastyrelsen - Servicedesk - Rust@m'
     )
     Clear-Host
     Write-Host "******************************** $Title ******************************************"  -backgroundcolor Red -foregroundcolor Black
     Write-Host "==================================== Vælg en af de følgende logins ====================================================="  -backgroundcolor Red -foregroundcolor Black
     Write-Host "[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][[][][][][][][]["  -foregroundcolor red
     Write-Host
     Write-Host "	Indtast 'initialer' og tryk på knappen. Kan bruges til server og klient pc. Kræver MFA. f.eks 'MOTJ'                 " -foregroundcolor Cyan
     Write-Host
     Write-Host "	Indtast 'admin' for at logge med adm-konti variabler Dette skal køres fra server, da det er basic authentication     " -foregroundcolor Cyan
     Write-Host "[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][[][][][][][][]["  -foregroundcolor red
     Write-Host "==================================== Vælg følgende (husk at logge på først!) ==========================================="  -backgroundcolor Red -foregroundcolor Black
     Write-Host
     Write-Host "[][][] Bruger [][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][[][][][][][][" -foregroundcolor Green
     Write-Host
     Write-Host " Skriv 'b' for at oprette bruger SSI/SDS" -foregroundcolor Cyan
     Write-Host
     Write-Host " Skriv 'u' for at aktivere (UM) Unified Messaging på bruger SSI/SDS" -foregroundcolor Cyan
     Write-Host
     Write-Host " Skriv 'rights' for at  Liste brugerens Privilegier" -foregroundcolor Cyan
     Write-Host
     Write-Host " Skriv 'jonstrup' for at oprette jonstrup brugere" -foregroundcolor Cyan
     Write-Host
     Write-Host " Skriv 'jonstrupned' for at oprette jonstrup brugere" -foregroundcolor Cyan
     Write-Host
     Write-Host "[][][] Fællespostkasse [][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][[[]["  -foregroundcolor Green
     Write-Host
     Write-Host " Tryk '1' for at oprette ny Fælles/Funktionspostkasse SSI/SDS" -foregroundcolor Cyan
     Write-Host
     Write-Host " Tryk '1sst' for at oprette ny Fælles/Funktionspostkasse SST Exchange (SST, DEP, STPS og NGC)" -foregroundcolor Cyan
     Write-Host
     Write-Host " Tryk '2' for at konverter eksisterende fællespostkasse af type 'Shared' til 'Regular'(Normal user)," -foregroundcolor Cyan
     Write-Host "          samt tildele Licens i office365 SSI/SDS "  -foregroundcolor Cyan
     Write-Host
     Write-Host " Tryk '3' for at konverter eksisterende fællespostkasse af type 'Regular'(Normal user) til type 'Shared'," -foregroundcolor Cyan
     Write-Host "          samt fjren Licensen SSI" -foregroundcolor Cyan
     Write-Host
     Write-Host " Tryk '4' for at konverter eksisterende fællespostkasse af type 'Shared' til 'Regual' (Normal user for Sikkermail)" -foregroundcolor Cyan
     Write-Host "          i tilhørende OU sikkermail, samt Tildele Licens i Office 365 SSI/SDS" -foregroundcolor Cyan
     Write-Host
     Write-Host
     Write-Host "[][][] Gruppe / DIstributionslister [][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][" -foregroundcolor Green
     Write-Host
     Write-Host " Tryk '5' for at oprette ny Distributionsgruppe/Postlister SSI/SDS" -foregroundcolor Cyan
     Write-Host
     Write-Host " Skriv 'ssigrp' for at oprette Sikkerhedsgruppe for en Eksisterende fællespostkasse" -foregroundcolor Cyan
     Write-Host
     Write-Host " Tryk '5sst' for at oprette ny Distributionsgruppe/Postlister SST Exchange (SST, DEP, STPS og NGC)" -foregroundcolor Cyan
     Write-Host
     Write-Host " Skriv 'sstgrp' for at oprette Sikkerhedsgruppe for en Eksisterende fællespostkasse i SST Exchange (SST, DEP, STPS og NGC)" -foregroundcolor Cyan
     Write-Host
     Write-Host "*** Adm-Konti ifm. lokal admin rettigheder (Dispensation) ***"  -foregroundcolor Green
     Write-Host
     Write-Host " Tryk '6' for at oprette ny ADM_KONTO for eksiterende AD bruger enten i SSI/SST/DKSUND Domænet" -foregroundcolor Cyan
     Write-Host
     Write-Host
     Write-Host "[][][] MødeLokaler [][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][[][][][][]["   -foregroundcolor Green
     Write-Host
     Write-Host " Skriv 'roomssi' for at oprette Mødelokalle i SSI" -foregroundcolor Cyan
     Write-Host
     Write-Host " Skriv 'roomsst' for at oprette Mødelokalle i SST Exchange (SST, DEP, STPS og NGC)" -foregroundcolor Cyan
     Write-Host
     Write-Host " Skriv 'licensfri' convertere alle brugere i SSI/SDS eller SUM eller SST -DisabledUsers og fjerne licenser, så de bliver frigjort " -foregroundcolor Cyan
     Write-Host
     Write-Host "[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][[][][][][][][]["  -foregroundcolor red
     Write-Host "========================================================================================================================"  -backgroundcolor Red -foregroundcolor Black
     Write-Host
     Write-Host "	------------->  Press 'Q' to quit." -foregroundcolor red
     Write-Host
     Write-Host
}
function Show-WpfMenu {

     Add-Type -AssemblyName PresentationFramework, System.Windows.Forms, WindowsFormsIntegration

     if (test-path "$PSScriptRoot\UserMenu.xaml") {
          [xml]$XAML_ConnectDialog = Get-Content "$PSScriptRoot\UserMenu.xaml" -Encoding UTF8
     }
     if (-not (test-path "$PSScriptRoot\UserMenu.xaml")) {
          [xml]$XAML_ConnectDialog = Get-Content "C:\RUFR_PowerShell\UserMenu.xaml" -Encoding UTF8
     }
     $XML_Node_Reader_ConnectDialog = (New-Object System.Xml.XmlNodeReader $XAML_ConnectDialog)
     $ConnectDialog = [Windows.Markup.XamlReader]::Load($XML_Node_Reader_ConnectDialog)
     $ConnectDialog.WindowStyle = 'None'

     #### Vælg bruger
     # Select Admin
     $Btn_ConnectDialog_User_Admin = $ConnectDialog.FindName('Btn_ConnectDialog_User_Admin')
     $Btn_ConnectDialog_User_Admin.Add_Click( {
               $Global:InputFromHost = 'admin'
               $ConnectDialog.Close()
          })
     # Select Initialer (xxxx)
     $Btn_ConnectDialog_User_Initials = $ConnectDialog.FindName('Btn_ConnectDialog_User_Initials')
     $Txt_ConnectDialog_User_Initials = $ConnectDialog.FindName('Txt_ConnectDialog_User_Initials')
     $Btn_ConnectDialog_User_Initials.Add_Click( {
               $Txt_ConnectDialog_User_Initials.text
               $Global:InputFromHost = $Txt_ConnectDialog_User_Initials.text.ToString()
               $ConnectDialog.Close()
          })

     #### bruger
     # Select B
     $Btn_ConnectDialog_b = $ConnectDialog.FindName('Btn_ConnectDialog_b')
     $Btn_ConnectDialog_b.Add_Click( {
               $Global:InputFromHost = 'b'
               $ConnectDialog.Close()
          })
     # Select U
     $Btn_ConnectDialog_u = $ConnectDialog.FindName('Btn_ConnectDialog_u')
     $Btn_ConnectDialog_u.Add_Click( {
               $Global:InputFromHost = 'u'
               $ConnectDialog.Close()
          })
     # Select Rights
     $Btn_ConnectDialog_rights = $ConnectDialog.FindName('Btn_ConnectDialog_rights')
     $Btn_ConnectDialog_rights.Add_Click( {
               $Global:InputFromHost = 'rights'
               $ConnectDialog.Close()
          })
     # Select Jonstrup
     $Btn_ConnectDialog_jonstrup = $ConnectDialog.FindName('Btn_ConnectDialog_jonstrup')
     $Btn_ConnectDialog_jonstrup.Add_Click( {
               $Global:InputFromHost = 'jonstrup'
               $ConnectDialog.Close()
          })
     # Select Jonstrup ned
     $Btn_ConnectDialog_jonstrup = $ConnectDialog.FindName('Btn_ConnectDialog_jonstrupned')
     $Btn_ConnectDialog_jonstrup.Add_Click( {
               $Global:InputFromHost = 'jonstrupned'
               $ConnectDialog.Close()
          })

     #### Fællespostkasse
     # Select 1
     $Btn_ConnectDialog_1 = $ConnectDialog.FindName('Btn_ConnectDialog_1')
     $Btn_ConnectDialog_1.Add_Click( {
               $Global:InputFromHost = '1'
               $ConnectDialog.Close()
          })
     # Select 1 SST
     $Btn_ConnectDialog_1sst = $ConnectDialog.FindName('Btn_ConnectDialog_1sst')
     $Btn_ConnectDialog_1sst.Add_Click( {
               $Global:InputFromHost = '1sst'
               $ConnectDialog.Close()
          })
     # Select 2
     $Btn_ConnectDialog_2 = $ConnectDialog.FindName('Btn_ConnectDialog_2')
     $Btn_ConnectDialog_2.Add_Click( {
               $Global:InputFromHost = '2'
               $ConnectDialog.Close()
          })
     # Select 3
     $Btn_ConnectDialog_3 = $ConnectDialog.FindName('Btn_ConnectDialog_3')
     $Btn_ConnectDialog_3.Add_Click( {
               $Global:InputFromHost = '3'
               $ConnectDialog.Close()
          })
     # Select 4
     $Btn_ConnectDialog_4 = $ConnectDialog.FindName('Btn_ConnectDialog_4')
     $Btn_ConnectDialog_4.Add_Click( {
               $Global:InputFromHost = '4'
               $ConnectDialog.Close()
          })

     #### Gruppe / DIstributionslister
     # Select 5
     $Btn_ConnectDialog_5 = $ConnectDialog.FindName('Btn_ConnectDialog_5')
     $Btn_ConnectDialog_5.Add_Click( {
               $Global:InputFromHost = '5'
               $ConnectDialog.Close()
          })
     # Select SSI Group
     $Btn_ConnectDialog_ssigrp = $ConnectDialog.FindName('Btn_ConnectDialog_ssigrp')
     $Btn_ConnectDialog_ssigrp.Add_Click( {
               $Global:InputFromHost = 'ssigrp'
               $ConnectDialog.Close()
          })
     # Select 5 SST
     $Btn_ConnectDialog_5sst = $ConnectDialog.FindName('Btn_ConnectDialog_5sst')
     $Btn_ConnectDialog_5sst.Add_Click( {
               $Global:InputFromHost = '5sst'
               $ConnectDialog.Close()
          })
     # Select SST Group
     $Btn_ConnectDialog_sstgrp = $ConnectDialog.FindName('Btn_ConnectDialog_sstgrp')
     $Btn_ConnectDialog_sstgrp.Add_Click( {
               $Global:InputFromHost = 'sstgrp'
               $ConnectDialog.Close()
          })

     #### Adm-Konti ifm. lokal admin rettigheder (Dispensation)
     # Select Admin
     $Btn_ConnectDialog_6 = $ConnectDialog.FindName('Btn_ConnectDialog_6')
     $Btn_ConnectDialog_6.Add_Click( {
               $Global:InputFromHost = '6'
               $ConnectDialog.Close()
          })

     #### MødeLokaler
     # Select Admin
     $Btn_ConnectDialog_roomssi = $ConnectDialog.FindName('Btn_ConnectDialog_roomssi')
     $Btn_ConnectDialog_roomssi.Add_Click( {
               $Global:InputFromHost = 'roomssi'
               $ConnectDialog.Close()
          })
     # Select Admin
     $Btn_ConnectDialog_roomsst = $ConnectDialog.FindName('Btn_ConnectDialog_roomsst')
     $Btn_ConnectDialog_roomsst.Add_Click( {
               $Global:InputFromHost = 'roomsst'
               $ConnectDialog.Close()
          })
     # Select Admin
     $Btn_ConnectDialog_licensfri = $ConnectDialog.FindName('Btn_ConnectDialog_licensfri')
     $Btn_ConnectDialog_licensfri.Add_Click( {
               $Global:InputFromHost = 'licensfri'
               $ConnectDialog.Close()
          })

     #### Luk knappen
     # Close form
     $Btn_ConnectDialog_Close_Form = $ConnectDialog.FindName('Btn_ConnectDialog_Close_Form')
     $Btn_ConnectDialog_Close_Form.Add_Click( {
               Remove-Variable -Name InputFromHost -ErrorAction SilentlyContinue -Scope Global
               $ConnectDialog.Close()
          })


     $ConnectDialog.Add_Closing( {
               [System.Windows.Forms.Application]::Exit()
               #Remove-Variable -Name InputFromHost -ErrorAction SilentlyContinue -Scope Global
          }) # {$form.Close()}

     # add keyboard indput
     [System.Windows.Forms.Integration.ElementHost]::EnableModelessKeyboardInterop($ConnectDialog)

     # Running this without $appContext and ::Run would actually cause a really poor response.
     $ConnectDialog.Show()

     # This makes it pop up
     $ConnectDialog.Activate() | Out-Null
     #run the form ConnectDialog
     $appContext = New-Object System.Windows.Forms.ApplicationContext
     [System.Windows.Forms.Application]::Run($appContext)

     $output = $InputFromHost
     Write-Output $output
}
do {
     Show-Menu
     $InputFromHost = Show-WpfMenu -Message '1'
     if (-not $InputFromHost) {

          $InputFromHost = Read-Host "Vælg en af muligheder, (husk at logge på først)"
     }
     #$WorkingDir = Convert-Path . replacing with: $PSScriptRoot
     switch ($InputFromHost) {
          'bae' {
               Clear-Host
               $global:UserInitial = "adm-bae"
               & "$PSScriptRoot\Logins\Login_SSI_SST_exch2010_DKSUND_Exchange365_Variabel.ps1"
          }
          'jomh' {
               Clear-Host
               $global:UserInitial = "adm-jomh"
               & "$PSScriptRoot\Logins\Login_SSI_SST_exch2010_DKSUND_Exchange365_Variabel.ps1"
          }
          'snt' {
               Clear-Host
               $global:UserInitial = "adm-snt"
               & "$PSScriptRoot\Logins\Login_SSI_SST_exch2010_DKSUND_Exchange365_AD.ps1"
          }
          'motj' {
               Clear-Host
               $global:UserInitial = "adm-motj"
               & "$PSScriptRoot\Logins\Login_SSI_SST_exch2010_DKSUND_Exchange365_Variabel.ps1"
          }
          'rufr' {
               Clear-Host

               $global:UserInitial = "adm-rufr"
               & "$PSScriptRoot\Logins\Login_SSI_SST_exch2010_DKSUND_Exchange365_rufr.ps1"
          }
          'krle' {
               Clear-Host

               $global:UserInitial = "adm-krle"
               & "$PSScriptRoot\Logins\Login_SSI_SST_exch2010_DKSUND_Exchange365_Variabel.ps1"
          }
          'dacj' {
               Clear-Host
               $global:UserInitial = "adm_dacj"
               & "$PSScriptRoot\Logins\Login_SSI_SST_exch2010_DKSUND_Exchange365_Variabel.ps1"
          }
          'tije' {
               Clear-Host
               $global:UserInitial = "adm-tije"
               & "$PSScriptRoot\Logins\Login_SSI_SST_exch2010_DKSUND_Exchange365_Variabel.ps1"
          }
          'tibe' {
               Clear-Host
               $global:UserInitial = "adm_tibe"
               & "$PSScriptRoot\Logins\Login_SSI_SST_exch2010_DKSUND_Exchange365_Variabel.ps1"
          }
          'jebn' {
               Clear-Host
               $global:UserInitial = "adm_jebn"
               & "$PSScriptRoot\Logins\Login_SSI_SST_exch2010_DKSUND_Exchange365_Variabel.ps1"
          }
          'anvm' {
               Clear-Host
               $global:UserInitial = "adm_anvm"
               & "$PSScriptRoot\Logins\Login_SSI_SST_exch2010_DKSUND_Exchange365_Variabel.ps1"
          }
          'lowg' {
               Clear-Host
               $global:UserInitial = "adm_lowg"
               & "$PSScriptRoot\Logins\Login_SSI_SST_exch2010_DKSUND_Exchange365_Variabel.ps1"
          }
          'frsl' {
               Clear-Host
               $global:UserInitial = "adm_frsl"
               & "$PSScriptRoot\Logins\Login_SSI_SST_exch2010_DKSUND_Exchange365_Variabel.ps1"
          }
          'mcor' {
               Clear-Host
               $global:UserInitial = "adm_mcor"
               & "$PSScriptRoot\Logins\Login_SSI_SST_exch2010_DKSUND_Exchange365_Variabel.ps1"
          }
          'admin' {
               Clear-Host
               & "$PSScriptRoot\Logins\Login_SSI_SST_exch2010_DKSUND_Exchange365_ADMIN.ps1"
          }


          '1' {
               Clear-Host
               # " Tryk '1' for at oprette ny Fælles/Funktionspostkasse SSI"
               & "$PSScriptRoot\PS_scripts\SSI\OpretFællespostkasseSSI.ps1"
          }

          '1sst' {
               Clear-Host
               # " Tryk '1' for at oprette ny Fælles/Funktionspostkasse SSI"
               & "$PSScriptRoot\PS_scripts\SST\OpretFællespostkasseSST.ps1"
          }

          '2' {
               Clear-Host
               # "Tryk '2' for at konverter eksisterende fællespostkasse af type 'Shared' til 'Regular'(Normal user), samt tildele Licens i office365 SSI"
               & "$PSScriptRoot\PS_scripts\SSI\Convert_fra_Shared_to_RegularlUser_plusLicensSSI.ps1"
          }

          '3' {
               Clear-Host
               # " Tryk '3' for at konverter eksisterende fællespostkasse af type 'Regular'(Normal user) til type 'Shared', samt. fjern Licensen SSI"
               & "$PSScriptRoot\PS_scripts\SSI\Convert_fra_Regular_to_SharedMail_removeLicensSSI.ps1"
          }

          '4' {
               Clear-Host
               # " Tryk '4' for at konverter eksisterende fællespostkasse af type 'Shared' til 'Regual' (Normal user i OU sikkermail) for sikkermail løsning, samt tildele Licens i Office 365 SSI "
               & "$PSScriptRoot\PS_scripts\SSI\Convert_fra_Shared_to_SecureRegularUser_PlusLicens_SSI.ps1"
          }


          '5' {
               Clear-Host
               # " Tryk '5' for at oprette ny Distributionsgruppe/Postlister SSI"
               & "$PSScriptRoot\PS_scripts\SSI\OpretDistributionsGruppeSSI_udenHak_iManagerSSI.ps1"
          }

          '5sst' {
               Clear-Host
               # " Tryk '5' for at oprette ny Distributionsgruppe/Postlister SSI"
               & "$PSScriptRoot\PS_scripts\SST\OpretDistributionsgruppeSST.ps1"
          }


          'ssigrp' {
               Clear-Host
               # "Skriv 'grpssi' for at oprette Sikkerhedsgruppe for en Eksisterende fællespostkasse"
               & "$PSScriptRoot\PS_scripts\SSI\OpretSikkerhedGruppeSSI_udenHak_iManagerSSI.ps1"
          }

          'sstgrp' {
               Clear-Host
               # "Skriv 'grpssi' for at oprette Sikkerhedsgruppe for en Eksisterende fællespostkasse"
               & "$PSScriptRoot\PS_scripts\SST\OpretSikkerhedGruppeSST.ps1"
          }

          '6' {
               Clear-Host
               # " Tryk '6' for at oprette ny ADM_KONTO for eksiterende AD bruger enten i SSI/SST Domænet"
               & "$PSScriptRoot\PS_scripts\Create_ADM-KONTO_forExisting_ADuser_SST_SSI_DKSUND.ps1"
          }


          'roomssi' {
               Clear-Host
               #Skriv 'room' at oprette Mødelokalle i SSI
               & "$PSScriptRoot\PS_scripts\SSI\OpretMødelokalleSSI.ps1"
          }

          'roomsst' {
               Clear-Host
               #Skriv 'room' at oprette Mødelokalle i SSI
               & "$PSScriptRoot\PS_scripts\SST\OpretMødelokaleSST.ps1"
          }


          'b' {
               Clear-Host
               #Tryk 'b' at OpretBrugerSSI i SSI
               #& "$PSScriptRoot\PS_scripts\SSI\OpretBrugerSSI.ps1"
               & "$PSScriptRoot\PS_scripts\SSI\OpretBrugerSSI.ps1"
          }
          'u' {
               Clear-Host
               #Tryk 'um' Aktivere UM i SSI/SDS
	              & "$PSScriptRoot\PS_scripts\SSI\Activate_UM_On_User_SSI.ps1"
          }

          'rights' {
               Clear-Host
               #Tryk 'b' at OpretBrugerSSI i SSI
               #& "$PSScriptRoot\PS_scripts\SSI\OpretBrugerSSI.ps1"
               & "$PSScriptRoot\PS_scripts\Get-ADUserMembership.ps1"
          }


          'licensfri' {
               Clear-Host
               #Skriv 'ps1' for at køre i powershell fri style mens du er logget på og har forbindelse på tværs domæner...
               & "$PSScriptRoot\PS_scripts\SSI\RemoveDirectLicens_for_OU.ps1"
          }
          'jonstrup' {
               Clear-Host
               #Skriv 'ps1' for at køre i powershell fri style mens du er logget på og har forbindelse på tværs domæner...
               & "$PSScriptRoot\PS_scripts\JohnstrupOprettelseFraExcel.ps1"
          }
          'jonstrupned' {
               Clear-Host
               #Skriv 'ps1' for at køre i powershell fri style mens du er logget på og har forbindelse på tværs domæner...
               & "$PSScriptRoot\PS_scripts\JohnstrupNedlæggelseFraExcel.ps1"
          }

          'path' {
               Clear-Host
               & "$PSScriptRoot\PS_scripts\SSI\path.ps1"
          }

          'q' {
               return
          }
     }
     pause
}
until ($InputFromHost -eq 'q')
#Remove-PSDrive -Name DKSUNDAD -Force
#Remove-PSDrive -Name SSIAD -Force
#Remove-PSDrive -Name SSTAD -Force