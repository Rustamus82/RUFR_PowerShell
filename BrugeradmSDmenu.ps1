#PSVersion 5 Script made/assembled by Rust@m 13-07-2017
function Show-Menu
 {
      param (
            [string]$Title = 'Sundhedsdatastyrelsen - Servicedesk - Rust@m'
      )
      cls
      Write-Host "******************************** $Title ******************************************"  -backgroundcolor Red -foregroundcolor Black
     Write-Host "==================================== Vælg en af de følgende logins ====================================================="  -backgroundcolor Red -foregroundcolor Black
     Write-Host "[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][[][][][][][][]["  -foregroundcolor red
      Write-Host "	Skriv 'bae' for at logge på som BAE                                                                             " -foregroundcolor Cyan
      Write-Host
      Write-Host "	Skriv 'jomh' for at logge på som JOMH                                                                           " -foregroundcolor Cyan
      Write-Host
      Write-Host "	Skriv 'snt' for at logge på som SNT                                                                           " -foregroundcolor Cyan
      Write-Host
      Write-Host "	Skriv 'motj' for at logge på som MOTJ                                                                           " -foregroundcolor Cyan
      Write-Host
      Write-Host "	Skriv 'rufr' for at logge på som RUFR                                                                           " -foregroundcolor Cyan
      Write-Host
      Write-Host "	Skriv 'krle' for at logge på som KRLE                                                                           " -foregroundcolor Cyan
      Write-Host
      Write-Host "	Skriv 'dacj' for at logge på som DACJ                                                                           " -foregroundcolor Cyan
      Write-Host
      Write-Host "	Skriv 'tije' for at logge på som TIJE                                                                           " -foregroundcolor Cyan
      Write-Host
      Write-Host "	Skriv 'admin' for at logge med adm-konti variabler                                                              " -foregroundcolor Cyan 
      Write-Host "[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][[][][][][][][]["  -foregroundcolor red
      Write-Host "==================================== Vælg følgende (husk at logge på først!) ==========================================="  -backgroundcolor Red -foregroundcolor Black
      Write-Host
      Write-Host "*** Bruger ***" -foregroundcolor Green
      Write-Host
      Write-Host " Skriv 'b' for at oprette bruger SSI/SDS" -foregroundcolor Cyan
      Write-Host
      Write-Host " Skriv 'u' for at aktivere (UM) Unified Messaging på bruger SSI/SDS" -foregroundcolor Cyan
      Write-Host
      Write-Host " Skriv 'rights' forat  Liste brugerens Privilegier" -foregroundcolor Cyan
      Write-Host 
      Write-Host "*** Fællespostkasse ***"  -foregroundcolor Green
      Write-Host
      Write-Host " Tryk '1' for at oprette ny Fælles/Funktionspostkasse SSI/SDS" -foregroundcolor Cyan
      Write-Host
      Write-Host " Tryk '1sst' for at oprette ny Fælles/Funktionspostkasse SST" -foregroundcolor Cyan
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
      Write-Host "*** Gruppe / DIstributionslister ***" -foregroundcolor Green
      Write-Host
      Write-Host " Tryk '5' for at oprette ny Distributionsgruppe/Postlister SSI/SDS" -foregroundcolor Cyan
      Write-Host
      Write-Host " Skriv 'ssigrp' for at oprette Sikkerhedsgruppe for en Eksisterende fællespostkasse" -foregroundcolor Cyan
      Write-Host
      Write-Host " Tryk '5sst' for at oprette ny Distributionsgruppe/Postlister SST" -foregroundcolor Cyan
      Write-Host
      Write-Host " Skriv 'sstgrp' for at oprette Sikkerhedsgruppe for en Eksisterende fællespostkasse" -foregroundcolor Cyan
      Write-Host
      Write-Host "*** Adm-Konti ifm. lokal admin rettigheder (Dispensation) ***"  -foregroundcolor Green
      Write-Host
      Write-Host " Tryk '6' for at oprette ny ADM_KONTO for eksiterende AD bruger enten i SSI/SST/DKSUND Domænet" -foregroundcolor Cyan
      Write-Host
      Write-Host
      Write-Host "*** MødeLokaler ***"   -foregroundcolor Green
      Write-Host
      Write-Host " Skriv 'roomssi' for at oprette Mødelokalle i SSI" -foregroundcolor Cyan
      Write-Host
      Write-Host " Skriv 'roomsst' for at oprette Mødelokalle i SST" -foregroundcolor Cyan
      Write-Host
      Write-Host " Skriv 'licensfri' convertere alle brugere i SSI -DisabledUsers og fjerne licenser, så de bliver frigjort " -foregroundcolor Cyan
      Write-Host "[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][[][][][][][][]["  -foregroundcolor red
      Write-Host "========================================================================================================================"  -backgroundcolor Red -foregroundcolor Black
      Write-Host
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
                 cls
	         & "$PSScriptRoot\Logins\Login_SSI_SST_exch2010_DKSUND_Exchange365_BAE.ps1"
		  }
            'jomh' {
                 cls
	         & "$PSScriptRoot\Logins\Login_SSI_SST_exch2010_DKSUND_Exchange365_JOMH.ps1"
		  }
            'snt' {
                 cls
	         & "$PSScriptRoot\Logins\Login_SSI_SST_exch2010_DKSUND_Exchange365_snt.ps1"
		  }
            'motj' {
                 cls
	         & "$PSScriptRoot\Logins\Login_SSI_SST_exch2010_DKSUND_Exchange365_MOTJ.ps1"
		  }
            'rufr' {
                 cls
	         
            & "$PSScriptRoot\Logins\Login_SSI_SST_exch2010_DKSUND_Exchange365_RUFR.ps1"
		  }


            'krle' {
                 cls
	         
            & "$PSScriptRoot\Logins\Login_SSI_SST_exch2010_DKSUND_Exchange365_krle.ps1"
		  }

            'dacj' {
                 cls
	         
            & "$PSScriptRoot\Logins\Login_SSI_SST_exch2010_DKSUND_Exchange365_dacj.ps1"
		  }

            'tije' {
                 cls
	         
            & "$PSScriptRoot\Logins\Login_SSI_SST_exch2010_DKSUND_Exchange365_TIJE.ps1"
		  }

             'admin' {
                 cls
	         & "$PSScriptRoot\Logins\Login_SSI_SST_exch2010_DKSUND_Exchange365_ANY.ps1"
		  }
            
            
             '1' {
                 cls
                 # " Tryk '1' for at oprette ny Fælles/Funktionspostkasse SSI"
	             & "$PSScriptRoot\PS_scripts\SSI\OpretFællespostkasseSSI.ps1"
		  }

             '1sst' {
                 cls
                 # " Tryk '1' for at oprette ny Fælles/Funktionspostkasse SSI"
	             & "$PSScriptRoot\PS_scripts\SST\OpretFællespostkasseSST.ps1"
		  }
          
            '2' {
                 cls
                 # "Tryk '2' for at konverter eksisterende fællespostkasse af type 'Shared' til 'Regular'(Normal user), samt tildele Licens i office365 SSI"
      	         & "$PSScriptRoot\PS_scripts\SSI\Convert_fra_Shared_to_RegularlUser_plusLicensSSI.ps1"
		  }
           
            '3' {
                 cls
                 # " Tryk '3' for at konverter eksisterende fællespostkasse af type 'Regular'(Normal user) til type 'Shared', samt. fjern Licensen SSI"
                    & "$PSScriptRoot\PS_scripts\SSI\Convert_fra_Regular_to_SharedMail_removeLicensSSI.ps1"
		  }
           
            '4' {
                 cls
                 # " Tryk '4' for at konverter eksisterende fællespostkasse af type 'Shared' til 'Regual' (Normal user i OU sikkermail) for sikkermail løsning, samt tildele Licens i Office 365 SSI "
                    & "$PSScriptRoot\PS_scripts\SSI\Convert_fra_Shared_to_SecureRegularUser_PlusLicens_SSI.ps1"
		  }


            '5' {
                 cls
                 # " Tryk '5' for at oprette ny Distributionsgruppe/Postlister SSI"
	             & "$PSScriptRoot\PS_scripts\SSI\OpretDistributionsGruppeSSI_udenHak_iManagerSSI.ps1"
		  }
            
            '5sst' {
                 cls
                 # " Tryk '5' for at oprette ny Distributionsgruppe/Postlister SSI"
	             & "$PSScriptRoot\PS_scripts\SST\OpretDistributionsgruppeSST.ps1"
		  }
           

           'ssigrp' {
                 cls
                 # "Skriv 'grpssi' for at oprette Sikkerhedsgruppe for en Eksisterende fællespostkasse"
	             & "$PSScriptRoot\PS_scripts\SSI\OpretSikkerhedGruppeSSI_udenHak_iManagerSSI.ps1"
		  }

           'sstgrp' {
                 cls
                 # "Skriv 'grpssi' for at oprette Sikkerhedsgruppe for en Eksisterende fællespostkasse"
	             & "$PSScriptRoot\PS_scripts\SST\OpretSikkerhedGruppeSST.ps1"
		  }
            
            '6' {
                 cls
                 # " Tryk '6' for at oprette ny ADM_KONTO for eksiterende AD bruger enten i SSI/SST Domænet"
	             & "$PSScriptRoot\PS_scripts\Create_ADM-KONTO_forExisting_ADuser_SST_SSI_DKSUND.ps1"
		  }
           
            
            'roomssi' {
                 cls
                 #Skriv 'room' at oprette Mødelokalle i SSI
	             & "$PSScriptRoot\PS_scripts\SSI\OpretMødelokalleSSI.ps1"
		  }

            'roomsst' {
                 cls
                 #Skriv 'room' at oprette Mødelokalle i SSI
	             & "$PSScriptRoot\PS_scripts\SST\OpretMødelokaleSST.ps1"
		  }


            'b' {
                 cls
                 #Tryk 'b' at OpretBrugerSSI i SSI
	             #& "$PSScriptRoot\PS_scripts\SSI\OpretBrugerSSI.ps1"
                  & "$PSScriptRoot\PS_scripts\SSI\OpretBrugerSSI.ps1"
		  }
            'u' {
                 cls
                 #Tryk 'um' Aktivere UM i SSI/SDS
	              & "$PSScriptRoot\PS_scripts\SSI\Activate_UM_On_User_SSI.ps1"
		  }

            'rights' {
                 cls
                 #Tryk 'b' at OpretBrugerSSI i SSI
	             #& "$PSScriptRoot\PS_scripts\SSI\OpretBrugerSSI.ps1"
                  & "$PSScriptRoot\PS_scripts\Get-ADUserMembership.ps1"
		  }


             'licensfri' {
                 cls
                 #Skriv 'ps1' for at køre i powershell fri style mens du er logget på og har forbindelse på tværs domæner...
	             & "$PSScriptRoot\PS_scripts\SSI\RemoveDirectLicens_for_OU.ps1" 
		  }
            
              'test' {
                 cls
                 #Skriv 'test' for at køre i powershell fri style mens du er logget på og har forbindelse på tværs domæner...
	         & "$PSScriptRoot\PS_scripts\SSI\RemoveDirectLicens_for_OU.ps1"
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