function Show-Menu
 {
      param (
            [string]$Title = 'Sundhedsdatastyrelsen - Servicedesk - O365 mailboks admin'
      )
      cls
      Write-Host "================ $Title ================"
      Write-Host
      Write-Host "	Pr�v at trykke I<option> for udvidet info - fx I2 for Tilf�j mailbox"
      Write-Host
      Write-Host " **** Seneste nyt - Ny procedure for shared mailbox - se IM og I2 ****"
      Write-Host
      Write-Host "	Tryk 1 for at vise bruger"
      Write-Host "	Tryk 2 for at tilf�je mailbox til Office365 (Husk Ad konto f�rst i SSI og vent p� sync. Tilf�j licens med option L )"
      Write-Host "	Tryk U for at aktivere UM funktionalitet"
      Write-Host "	Tryk L for at tilf�je licens til mailbox (Check f�rst at mailbox og O365 user er klar i Option 1)"
      Write-Host "	"
      Write-Host "	Tryk C for at deaktivere clutter p� brugers mailboks"
      Write-Host
      Write-Host "	Tryk 3 for at vise gruppe"
      Write-Host "	Tryk 4 for at mailaktivere gruppe. Husk at den skal v�re synkroniseret fra SSI AD f�rst"
      Write-Host "	Tryk 5 for at vise gruppemedlemmer"
      Write-Host "	Tryk T for at tilf�je medlemmer til gruppe"
      Write-Host
      Write-Host "	Tryk M for at oprette ny delt mailbox i Office 365 (Husk opret almindelig mailbox f�rst i 2 men uden licens option L)"
      Write-Host "	Tryk K for at l�gge gruppe / bruger til delt mailbox for rettigheder (Husk gruppen skal laves i option 4 f�rst)"
      Write-Host
      Write-Host "	Tryk A for at se m�delokaleindstillinger"
      Write-Host "	Tryk 7 for at oprette nyt m�delokale"
      write-host
      Write-Host "	Tryk 6 for at checke min logon status (State = Broken eller helt tom s� k�r 9)"
      Write-Host "	Tryk 9 for at logge p� igen"
      Write-Host
      Write-Host "	Q: Press 'Q' to quit."
      Write-Host
 }

do
{
      Show-Menu
      $input = Read-Host "Please make a selection"
      switch ($input)
      {
            '1' {
                 cls
	         $user = Read-Host "Tast brugernavn:"
		 Get-AdUser $user
		 get-O365mailbox $user | fl Displayname, Primarysmtpaddress, distinguishedname, *hidden*, emailaddresses, Whencreated, Whenchanged, UMEnabled, RecipientTypeDetails
         Get-o365MailboxPermission $user | Where-Object {$_.IsInherited -like "False" -and $_.User -notlike "*SELF" }
         Write-Host       
         (Get-MsolUser -UserPrincipalName $user@dksund.dk).Licenses.Servicestatus
                }
              '2' {
	         $user = Read-Host "Tast brugernavn"
		 Enable-RemoteMailbox $user -RemoteRoutingAddress $user@dksund.mail.onmicrosoft.com
         Get-o365Mailbox $user | set-o365Clutter -Enable $false
		  }
              'U' {
	         $user = Read-Host "Tast brugernavn"
             $sip = $user+"@ssi.dk"
             Write-Host "user" $sip
		 Enable-O365UMMailbox -Identity $user -UMMailboxPolicy O365UM -SIPResourceIdentifier $sip
		  }

              'L' {
                 cls
	         $user = Read-Host "Tast brugernavn"
		 $x = New-MsolLicenseOptions -AccountSkuId "dksund:ENTERPRISEPACK" -DisabledPlans "PROJECTWORKMANAGEMENT","YAMMER_ENTERPRISE","MCOSTANDARD","SHAREPOINTWAC", "OFFICESUBSCRIPTION", "SWAY", "RMS_S_ENTERPRISE"
 		Set-MsolUser -UserPrincipalName $user@dksund.dk -UsageLocation DK
		Set-MsolUserLicense -UserPrincipalName $user@dksund.dk -AddLicenses dksund:ENTERPRISEPACK
		Set-MsolUserLicense -UserPrincipalName $user@dksund.dk -LicenseOptions $x
                (Get-MsolUser -UserPrincipalName $user@dksund.dk).Licenses.Servicestatus
                 }
              'S' {
                 cls
	         Write-Host "Brugere / mailbox slettes ved at slette SSI ad object. Se procedure for dette. Kontoen skal flyttes til speciel OU f�rst"
                 }
              'C' {
	         $user = Read-Host "Tast brugernavn"
             Get-o365Mailbox $user | set-o365Clutter -Enable $false
		  }

              '4' {
                 cls
	         $group = Read-Host "Tast Gruppens navn"
		 $company = Read-Host "Tast 1 for SSI eller 2 for Sundhedsdatastyrelsen (s� f�r den @ssi.dk eller @sundhedsdata.dk)"
		 Enable-DistributionGroup -Identity $group
		 If ($company -eq "1") {
		 $new = $group + "@ssi.dk"
		 Set-DistributionGroup $group -PrimarySMTPAddress $new -EmailAddressPolicyEnabled $false
		 }
		 ElseIf ($company -eq "2") {
		 $new = $group + "@sundhedsdata.dk"
		 Set-DistributionGroup $group -PrimarySMTPAddress $new -EmailAddressPolicyEnabled $false
		 }
		 }
              '3' {
                 cls
	         $group = Read-Host "Tast Gruppens navn"
		 Get-Group $group		 
		 Get-o365group $group | select DisplayName,WindowsEmailAddress,Recipienttype*
		 Get-DistributionGroup $group
                 }
              '5' {
                 cls
	         $group = Read-Host "Tast Gruppens navn"
		 Get-o365DistributiongroupMember $group | select name
                 }
              'T' {
                 cls
	         Write-Host "Gruppemedlemmer vedligeholdes i SSI ad ved hj�lp af AD users and Computers"
                 }
              'M' {
                 cls
                 $alias = Read-Host "Tast Alias p� mailbox (uden blanke)"
                 Set-o365Mailbox $alias -Type:Shared
		 Get-o365Mailbox $alias | fl Displayname, *RecipientType*
	              }
              'K' {
                 cls
                 $alias = Read-Host "Tast Alias p� mailbox"
                 $group = Read-Host "Tast navn p� gruppe som skal have rettigeder til mailbox"
                 Get-o365Mailbox -identity $alias | add-o365mailboxpermission -user $group -accessrights FullAccess -inheritancetype All
                 Add-o365recipientPermission $alias -AccessRights SendAs -Trustee $group -Confirm:$false
	              }
              'A' {
                 cls
                 $user = Read-Host "Tast navn p� m�delokalet"
                 Get-o365Mailbox $user | select displayname, primarysmtpaddress, isresource, ResourceCapacity
                 Get-o365Mailbox $user | Get-o365CalendarProcessing | fl
	              }
              '7' {
                 cls
                 $user = Read-Host "Tast Displaynavn p� m�delokale"
                 $alias = Read-Host "Tast Alias p� nyt m�delokale (uden blanke)"
                 new-o365mailbox -name $alias -displayname $user -PrimarySMTPAddress $alias@ssi.dk -Room
                  }

              '6' {
                 cls
	         Get-PSSession
		  }
              '9' {
                 cls
	         c:\tools\logonall.ps1
		  }
              'I2' {
                 cls
	         Write-Host "Udvidet hj�lp til oprettelse af ny mailbox"
		 Write-Host
		 Write-Host "1. Opret AD konto i SSI ad. Husk at udfylde alle attributter (company, manager m.m)"
		 Write-Host "2. Opret tilh�rende gruppe hvis det senere skal v�re en shared mailbox GRP-mailboxnavn"
		 Write-Host "3. Vent p� Sync af konto til DKSUND (op til 1.5 timer)"
		 Write-Host "4. N�r du v�lger option 2 skal du s� angive navnet p� den AD konto du har oprettet"
		 Write-Host "   Nu oprettes mailboksen i Office365...."
		 Write-Host "5. Vent p� sync fra DKSUND til O365 (Op til 30 min)"
		 Write-Host "6. Tildel Licens i option L"
		 Write-Host
     		  }

              'IM' {
                 cls
	         Write-Host "Udvidet hj�lp til Shared mailbox"
		 Write-Host
		 Write-Host "En shared mailbox skal altid oprettes som en almindelig mailbox f�rst og s� konverteres til shared"
		 Write-Host "Den eneste forskel er at man ikke beh�ver at tildele en licens bagefter"
		 Write-Host "Se de enkelte steps til at oprette en mailbox ved at v�lge I2"
     		  }

	      'q' {
                 return
            }
      }
      pause
 }
 until ($input -eq 'q')
