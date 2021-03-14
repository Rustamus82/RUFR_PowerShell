#PSVersion 5 Script made/assembled by Rust@m 13-07-2017
cls
function Show-Menu
 {
      param (
            [string]$Title = 'Sundhedsdatastyrelsen - Servicedesk - Rust@m'
      )
      Clear-Host
      Write-Host "******************************** $Title ******************************************"  -backgroundcolor Red -foregroundcolor Black
     Write-Host "==================================== Vælg en af de følgende logins ====================================================="  -backgroundcolor Red -foregroundcolor Black
     Write-Host "[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][[][][][][][][]["  -foregroundcolor red
      Write-Host
      Write-Host "	Skriv 'initialer' for at logge på med egne admin konti - eksempelvis 'motj'                                              " -foregroundcolor Cyan
      Write-Host
      Write-Host "	Skriv 'admin' for at logge med adm-konti variabler når du er på servere                                                  " -foregroundcolor Cyan 
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
      Write-Host "[][][] Fællespostkasse [][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][[[]["  -foregroundcolor Green
      Write-Host
      Write-Host " Tryk '1' for at oprette ny Fælles/Funktionspostkasse SSI/SDS" -foregroundcolor Cyan
      Write-Host
      Write-Host " Tryk '1sst' for at oprette ny Fælles/Funktionspostkasse SST Exchange (sst og stps)" -foregroundcolor Cyan
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
      Write-Host " Tryk '5sst' for at oprette ny Distributionsgruppe/Postlister SST Exchange (sst og stps)" -foregroundcolor Cyan
      Write-Host
      Write-Host " Skriv 'sstgrp' for at oprette Sikkerhedsgruppe for en Eksisterende fællespostkasse i SST Exchange (sst og stps)" -foregroundcolor Cyan
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
      Write-Host " Skriv 'roomsst' for at oprette Mødelokalle i SST Exchange (sst og stps)" -foregroundcolor Cyan
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


do
{
      Show-Menu
      $input = Read-Host "Vælg en af muligheder, (husk at logge på først)"
      #$WorkingDir = Convert-Path . replacing with: $PSScriptRoot
      switch ($input)
      {
            
            'bae' {
                 Clear-Host
             $global:UserInitial = "adm-bae"
	         & "$PSScriptRoot\Logins\Login_SSI_SST_exch2010_DKSUND_Exchange365_Variabel.ps1.ps1"
		  }
            'jomh' {
                 Clear-Host
             $global:UserInitial = "adm-jomh"
	         & "$PSScriptRoot\Logins\Login_SSI_SST_exch2010_DKSUND_Exchange365_Variabel.ps1.ps1"
		  }
            
            'snt' {
                 Clear-Host
             $global:UserInitial = "adm-snt"
	         & "$PSScriptRoot\Logins\Login_SSI_SST_exch2010_DKSUND_Exchange365_AD.ps1"
		  }
            'motj' {
                 Clear-Host
             $global:UserInitial = "adm-motj"
	         & "$PSScriptRoot\Logins\Login_SSI_SST_exch2010_DKSUND_Exchange365_Variabel.ps1.ps1"
		  }
            'rufr' {
                 Clear-Host
	         
             $global:UserInitial = "adm-rufr"
	         & "$PSScriptRoot\Logins\Login_SSI_SST_exch2010_DKSUND_Exchange365_rufr.ps1.ps1"
		  }

            'krle' {
                 Clear-Host
	         
             $global:UserInitial = "adm-krle"
	         & "$PSScriptRoot\Logins\Login_SSI_SST_exch2010_DKSUND_Exchange365_Variabel.ps1.ps1"
		  }

            'dacj' {
                 Clear-Host
             $global:UserInitial = "adm_dacj"
	         & "$PSScriptRoot\Logins\Login_SSI_SST_exch2010_DKSUND_Exchange365_Variabel.ps1.ps1"
		  }

            'tije' {
                 Clear-Host
             $global:UserInitial = "adm-tije"
	         & "$PSScriptRoot\Logins\Login_SSI_SST_exch2010_DKSUND_Exchange365_Variabel.ps1.ps1"
		  }
            'tibe' {
                 Clear-Host
             $global:UserInitial = "adm_tibe"
	         & "$PSScriptRoot\Logins\Login_SSI_SST_exch2010_DKSUND_Exchange365_Variabel.ps1.ps1"
		  }
            'jebn' {
                 Clear-Host
             $global:UserInitial = "adm_jebn"
	         & "$PSScriptRoot\Logins\Login_SSI_SST_exch2010_DKSUND_Exchange365_Variabel.ps1.ps1"
		  }
            'anvm' {
                 Clear-Host
             $global:UserInitial = "adm_anvm"
	         & "$PSScriptRoot\Logins\Login_SSI_SST_exch2010_DKSUND_Exchange365_Variabel.ps1.ps1"
		  }
            'lowg' {
                 Clear-Host
             $global:UserInitial = "adm_lowg"
	         & "$PSScriptRoot\Logins\Login_SSI_SST_exch2010_DKSUND_Exchange365_Variabel.ps1.ps1"
		  }
            'frsl' {
                 Clear-Host
             $global:UserInitial = "adm_frsl"
	         & "$PSScriptRoot\Logins\Login_SSI_SST_exch2010_DKSUND_Exchange365_Variabel.ps1.ps1"
		  }

            'mcor' {
                 Clear-Host
             $global:UserInitial = "adm_mcor"
	         & "$PSScriptRoot\Logins\Login_SSI_SST_exch2010_DKSUND_Exchange365_Variabel.ps1.ps1"
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
 until ($input -eq 'q')
#Remove-PSDrive -Name DKSUNDAD -Force
#Remove-PSDrive -Name SSIAD -Force
#Remove-PSDrive -Name SSTAD -Force