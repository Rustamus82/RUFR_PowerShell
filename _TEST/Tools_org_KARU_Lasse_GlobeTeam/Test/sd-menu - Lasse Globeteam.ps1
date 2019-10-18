Function Get-FileName($initialDirectory)
{
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.initialDirectory = $initialDirectory
    $OpenFileDialog.filter = "CSV (*.txt)| *.txt"
    $OpenFileDialog.ShowDialog() | Out-Null
    $OpenFileDialog.filename
}


function Show-Menu
 {
      param (
            [string]$Title = 'Sundhedsdatastyrelsen - Servicedesk - O365 / Exchange Online admin'
      )
      cls
      Write-Host "================ $Title ================"
      Write-Host
      Write-Host "	Prøv at trykke I<option> for udvidet info - fx I2 for Tilføj mailbox"
      Write-Host
      Write-Host " "
      Write-Host
      Write-Host "   Brugere"
      Write-Host
      Write-Host "	Tryk 1 for at vise bruger"
      Write-Host "	Tryk 2 for at tilføje mailboks til Office365 (Husk Ad konto først i SSI og vent på sync. Tilføj licens med option L )"
      Write-Host "	Tryk U for at aktivere UM funktionalitet"
      Write-Host "	Tryk S for at se licenser på bruger"
      Write-Host "	Tryk L for at tilføje licens til mailboks (Check først at mailbox og O365 user er klar i Option 1)"
      Write-Host "	Tryk C for at deaktivere clutter på brugers mailboks"
      Write-Host "	Tryk D for at sætte mailboks i litigation hold. Dette gøres inden mailboksen slettes. Herved gemmes den uden cost i 12 måneder"
      Write-Host "	Tryk V se mailbokse sat på litigation hold"
      Write-Host "	Tryk R Gendan data fra mailbokse sat på litigation hold"
      Write-Host
      Write-Host "   Grupper / distributionslister"
      Write-Host
      Write-Host "	Tryk 3 for at vise gruppe"
      Write-Host "	Tryk 4 for at mailaktivere gruppe. Husk at den skal være synkroniseret fra SSI AD først"
      Write-Host "	Tryk 5 for at vise gruppemedlemmer"
      Write-Host "	Tryk T for at tilføje medlemmer til gruppe"
      Write-Host
      Write-Host "   Delte mailbokse "
      Write-Host
      Write-Host "	Tryk M for at oprette ny delt mailboks i Office 365 (Husk opret almindelig mailboks først i 2 men uden licens option L)"
      Write-Host "	Tryk K for at lægge gruppe / bruger til delt mailboks for rettigheder (Husk gruppen skal laves i option 4 først)"
      Write-Host
      Write-Host "   Mødelokaler "
      Write-Host
      Write-Host "	Tryk A for at se mødelokaleindstillinger"
      Write-Host "	Tryk 7 for at oprette nyt mødelokale"
      Write-Host
      Write-Host "   Diverse "
      Write-Host
      Write-Host "	Tryk 6 for at checke min logon status (State = Broken eller helt tom så kør 9)"
      Write-Host "	Tryk 9 for at logge på igen"
      Write-Host
      Write-Host "	Press 'Q' to quit."
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
		 if (-not ($user -eq "*")) {
		 Get-AdUser $user
		 get-O365mailbox $user | fl Displayname, Primarysmtpaddress, distinguishedname, *hidden*, emailaddresses, Whencreated, Whenchanged, UMEnabled, RecipientTypeDetails
                 Get-o365MailboxPermission $user | Where-Object {$_.IsInherited -like "False" -and $_.User -notlike "*SELF" }
		 }
		 Else {}
                }
              '2' {
		 cls
		 Write-Host "Enable mailboks i Office 365"
	         $user = Read-Host "Tast brugernavn"
		 if (-not ($user -eq "*")) {
		 Enable-RemoteMailbox $user -RemoteRoutingAddress $user@dksund.mail.onmicrosoft.com
	         Get-o365Mailbox $user | set-o365Clutter -Enable $false
		 }
		 Else { write-host "du har tastet * i username, vælg menu 2 igen og tast et korrekt username" }
		  }
              'U' {
	         $user = Read-Host "Tast brugernavn"
             $sip = $user+"@ssi.dk"
             Write-Host "user" $sip
		 Enable-O365UMMailbox -Identity $user -UMMailboxPolicy O365UM -SIPResourceIdentifier $sip
		  }
            'S' {
                 cls
	         $user = Read-Host "Tast brugernavn:"
                 (Get-MsolUser -UserPrincipalName $user@dksund.dk).Licenses.Servicestatus | ogv
                }
              'L' {
                 cls
	         $user = Read-Host "Tast brugernavn"
		 if (-not ($user -eq "*")) {
		 $x = New-MsolLicenseOptions -AccountSkuId "dksund:ENTERPRISEPACK" -DisabledPlans "PROJECTWORKMANAGEMENT","YAMMER_ENTERPRISE","MCOSTANDARD","SHAREPOINTWAC", "OFFICESUBSCRIPTION", "SWAY", "RMS_S_ENTERPRISE"
 		Set-MsolUser -UserPrincipalName $user@dksund.dk -UsageLocation DK
		Set-MsolUserLicense -UserPrincipalName $user@dksund.dk -AddLicenses dksund:ENTERPRISEPACK
		Set-MsolUserLicense -UserPrincipalName $user@dksund.dk -LicenseOptions $x
  		}
		 Else { write-host "du har tastet * i username, vælg menu L igen og tast et korrekt username" }
               }
              'C' {
	         $user = Read-Host "Tast brugernavn"
		 if (-not ($user -eq "*")) {
	           Get-o365Mailbox $user | set-o365Clutter -Enable $false
		 }
		 Else { write-host "du har tastet * i username, vælg menu C igen og tast et korrekt username" }
 	          }

              '4' {
                 cls
	         $group = Read-Host "Tast Gruppens navn"
		 $company = Read-Host "Tast 1 for SSI eller 2 for Sundhedsdatastyrelsen (så får den @ssi.dk eller @sundhedsdata.dk)"
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
	         Write-Host "Gruppemedlemmer vedligeholdes i SSI ad ved hjælp af AD users and Computers"
                 }
              'M' {
                 cls
                 $alias = Read-Host "Tast Alias på mailbox (uden blanke)"
		 if (-not ($alias -eq "*")) {
                 Set-o365Mailbox $alias -Type:Shared
		 Get-o365Mailbox $alias | fl Displayname, *RecipientType*
		 }
		 Else {}
                 }
              'K' {
                 cls
                 $alias = Read-Host "Tast Alias på mailbox"
		 if (-not ($alias -eq "*" -or $alias -eq "")) {
                 $group = Read-Host "Tast navn på gruppe som skal have rettigheder til mailbox"
                 Get-o365Mailbox -identity $alias | add-o365mailboxpermission -user $group -accessrights FullAccess -inheritancetype All
                 Add-o365recipientPermission $alias -AccessRights SendAs -Trustee $group -Confirm:$false
		 }
		 Else {}
                 }
              'A' {
                 cls
                 $user = Read-Host "Tast navn på mødelokalet"
                 Get-o365Mailbox $user | select displayname, primarysmtpaddress, isresource, ResourceCapacity
                 Get-o365Mailbox $user | Get-o365CalendarProcessing | fl
	              }
              '7' {
                 cls
                 $user = Read-Host "Tast Displaynavn på mødelokale"
                 $alias = Read-Host "Tast Alias på nyt mødelokale (uden blanke)"
                 new-o365mailbox -name $alias -displayname $user -PrimarySMTPAddress $alias@ssi.dk -Room
                  }
              'D' {
cls
$LitigationHoldDuration=Read-Host "Angiv hvor mange dage det retslig tilbagehold skal gælde, angives der ikke noget vil tilbageholdet gælde for evigt"
$CSV=Get-FileName
IF($LitigationHoldDuration -gt "0"){
Import-Csv $CSV -Header Name | % {set-o365Mailbox $_.Name -LitigationHoldEnabled:$true -LitigationHoldDuration $LitigationHoldDuration
}
}
Else{Import-Csv $CSV -Header Name |% {set-o365Mailbox $_.Name -LitigationHoldEnabled:$true}
}
#else {}
                  }
              'V' {
                 cls
Get-o365Mailbox -ResultSize Unlimited -Filter {LitigationHoldEnabled -eq $True} | select name,LitigationHoldDuration |Out-GridView
#(Get-o365MailboxSearch "stoppede_brugere").Sourcemailboxes | Get-o365Mailbox -IncludeInactiveMailbox

		 }
              'R' {
                 cls
Get-o365Mailbox -InactiveMailboxOnly | Out-GridView -PassThru -Title "Liste over slettet postkasser" | % {
$ID=Get-Random
$name="Restore"+$_.Alias+$ID
New-o365Mailbox -Shared -Name $name
Get-o365Mailbox -ResultSize unlimited |Out-GridView -PassThru -Title "Hvem skal have adgang til postkassen" | %{
Add-o365MailboxPermission $name -AccessRights fullaccess -User $_.Alias
}
New-o365MailboxRestoreRequest -SourceMailbox $_.DistinguishedName -TargetMailbox $name -AllowLegacyDNMismatch
}


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
	         Write-Host "Udvidet hjælp til oprettelse af ny mailbox"
		 Write-Host
		 Write-Host "1. Opret AD konto i SSI ad. Husk at udfylde alle attributter (company, manager m.m)"
		 Write-Host "2. Opret tilhørende gruppe hvis det senere skal være en shared mailbox GRP-mailboxnavn"
		 Write-Host "3. Vent på Sync af konto til DKSUND (op til 1.5 timer)"
		 Write-Host "4. Når du vælger option 2 skal du så angive navnet på den AD konto du har oprettet"
		 Write-Host "   Nu oprettes mailboksen i Office365...."
		 Write-Host "5. Vent på sync fra DKSUND til O365 (Op til 30 min)"
		 Write-Host "6. Tildel Licens i option L"
		 Write-Host
     		  }

              'IM' {
                 cls
	         Write-Host "Udvidet hjælp til Shared mailbox"
		 Write-Host
		 Write-Host "En shared mailbox skal altid oprettes som en almindelig mailbox først og så konverteres til shared"
		 Write-Host "Den eneste forskel er at man ikke behøver at tildele en licens bagefter"
		 Write-Host "Se de enkelte steps til at oprette en mailbox ved at vælge I2"
     		  }

	      'q' {
                 return
            }
      }
      pause
 }
 until ($input -eq 'q')
