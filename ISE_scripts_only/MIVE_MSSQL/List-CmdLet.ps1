<# 
.SYNOPSIS 
Lister .ps1 powershell scripts der er cmdlets + 2 linier efter synopsis linien, der kendetegner Cmdlets
Script opdateret Mikael Veistrup-Vetlov @ 20211208
Script oprettet Mikael Veistrup-Vetlov @ 20200504


.Parameter sti
Her kan angives en sti, hvor der skal søges efter Powershell cmdlets 
ingen <sti> betyder at scriptene listes fra aktuel folder 

.DESCRIPTION 
List-Cmdlets.ps1 bruger argument <-sti> for derfra at vise .ps1 powershell scripts der indeholder synopsis linier 

.EXAMPLE 
.\List-Cmdlets.ps1 -sti s:\MSSQL
Søger s:\mssql igennem efter '.ps1' filer der indeholder synopsis linien, der kendetegner Cmdlets
.EXAMPLE 
Dette kan angives med alias -folder for -user, -domain/-domæne for -ad og -gem for -fil
.\List-Cmdlets.ps1 -folder c:\powshell

.NOTES
.LINK
#> 

[CmdletBinding()] 
param( 
	[Parameter(Mandatory=$false, Position=0, ValueFromPipelineByPropertyName,
	HelpMessage="Angiv sti / folder hvorfra .ps1 powershell scripts der indeholder synopsis linien skal vises.")] 
	[ValidateScript({Test-Path $_ -PathType ‘Container’})]
    [Alias("folder")] 
	[string] $sti=""		#$script:MyInvocation.MyCommand.Path
)
Begin{
	$EgoCmd=$PSCommandPath -Split("\\")     # $EgoCmd= 'm:','ps1','SQL-Installation.ps1'
	$Egodisk=$EgoCmd[0]
	$Egofil=$EgoCmd[-1]
	If($EgoCmd.Count -lt 3){$Egosti=''}elseif($EgoCmd.Count -eq 3){$Egosti=$EgoCmd[1]}else{$EgoCmd1=$EgoCmd[1..($EgoCmd.Count-2)];$Egosti=$EgoCmd1 -join("\")}
	If (!($sti.length -gt 0)){$sti=$Egodisk+"\"+$Egosti}
	$sti=$sti.trimend(" \")
	If (!(test-path $sti)){Write-Error "Du har ikke adgang til path: $sti !";exit}
	$global:EGOFilListe=Get-ChildItem $sti\*.ps1 | Select-String -pattern ".SYNOPSIS" | group path
	$global:EGOfundet = $global:EGOFilListe.name.count

	if (!($global:EGOfundet -gt 0)) {Write-Error "Der er ikke nogen Powershell cmdlets (.ps1) filer med teksten "".Synopsis"" ! ";exit}
	
	Function Reset-Liste{
		$global:EGOpos=0
		$global:EGOL=$global:EGO1=$global:EGO2=$global:EGO3=@()
		Foreach($el in $EGOFilListe){
			$global:EGOL+=$el.Name
			$b=Get-Content $el.group[0].Path | Select-Object -skip $el.group[0].LineNumber -first 3
			$global:EGO1+=$b[0]
			$global:EGO2+=$b[1]
			$global:EGO3+=$b[2]
		}
	}

	
	$EgoCrLf="`r`n"
	$monitor = Get-Wmiobject Win32_Videocontroller
	$monitor.CurrentHorizontalResolution
	$global:VertResol=$monitor.CurrentVerticalResolution
	foreach ($VertResol1 in $VertResol){[int]$global:EGOSidestr=(($VertResol1-350))/100}

	Function Vis-Vindue {
	# opret nyt vindue
		$lpos=10
		[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")  
		[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") 
		[void] [System.Windows.Forms.Application]::EnableVisualStyles()  
	# Form definitionen
		$global:EGOForm = New-Object system.Windows.Forms.Form 
		$global:EGOForm.Size = New-Object System.Drawing.Size(1500,(($global:EGOSidestr*100)+200)) 
		$global:EGOForm.MaximizeBox = $false 
		$global:EGOForm.MinimizeBox = $false 
		$global:EGOForm.StartPosition = "CenterScreen" 
		$global:EGOForm.FormBorderStyle = 'Fixed3D' 
		#$Font = New-Object System.Drawing.Font("Arial",15,[System.Drawing.FontStyle]::Bold) 
		$Font = New-Object System.Drawing.Font("Times New Roman",15)
		$global:EGOForm.Font = $Font 
	# label
		$global:Label0 = New-Object System.Windows.Forms.label
		$global:Label1 = New-Object System.Windows.Forms.label
		$global:Label2 = New-Object System.Windows.Forms.label
		$global:Label3 = New-Object System.Windows.Forms.label
		$global:Label4 = New-Object System.Windows.Forms.label
		$global:Label5 = New-Object System.Windows.Forms.label
		$global:Label6 = New-Object System.Windows.Forms.label
		$global:Label7 = New-Object System.Windows.Forms.label
		$global:Label8 = New-Object System.Windows.Forms.label
		$global:Label9 = New-Object System.Windows.Forms.label
		$global:Label10 = New-Object System.Windows.Forms.label
		$global:Label11 = New-Object System.Windows.Forms.label	
		$global:Label0.Size=$global:Label1.Size=$global:Label2.Size=$global:Label3.Size=$global:Label4.Size=$global:Label5.Size=$global:Label6.Size=$global:Label7.Size=$global:Label8.Size=$global:Label9.Size=$global:Label10.Size=$global:Label11.Size=New-Object System.Drawing.Size(200,70)
		$global:Txt0 = New-Object System.Windows.Forms.label	
		$global:Txt1 = New-Object System.Windows.Forms.label	
		$global:Txt2 = New-Object System.Windows.Forms.label	
		$global:Txt3 = New-Object System.Windows.Forms.label	
		$global:Txt4 = New-Object System.Windows.Forms.label	
		$global:Txt5 = New-Object System.Windows.Forms.label	
		$global:Txt6 = New-Object System.Windows.Forms.label	
		$global:Txt7 = New-Object System.Windows.Forms.label	
		$global:Txt8 = New-Object System.Windows.Forms.label	
		$global:Txt9 = New-Object System.Windows.Forms.label	
		$global:Txt10 = New-Object System.Windows.Forms.label	
		$global:Txt11 = New-Object System.Windows.Forms.label	
		$global:Txt0.Size=$global:Txt1.Size=$global:Txt2.Size=$global:Txt3.Size=$global:Txt4.Size=$global:Txt5.Size=$global:Txt6.Size=$global:Txt7.Size=$global:Txt8.Size=$global:Txt9.Size=$global:Txt10.Size=$global:Txt11.Size=New-Object System.Drawing.Size(1000,70)
		
		
		If($global:EGOSidestr -ge 0){
			$global:Label0.Location = New-Object System.Drawing.Size(10,$lpos)
			$global:Txt0.location = new-object system.drawing.point(210,$lpos)
			$global:EGOForm.Controls.Add($global:Label0)
			$global:EGOForm.controls.Add($global:Txt0)
			$lpos+=80
		}
		If($global:EGOSidestr -ge 1){
			$global:Label1.Location = New-Object System.Drawing.Size(10,$lpos)
			$global:Txt1.location = new-object system.drawing.point(210,$lpos)
			$global:EGOForm.Controls.Add($global:Label1)
			$global:EGOForm.controls.Add($global:Txt1)
			$lpos+=80
		}
		If($global:EGOSidestr -ge 2){
			$global:Label2.Location = New-Object System.Drawing.Size(10,$lpos)
			$global:Txt2.location = new-object system.drawing.point(210,$lpos)
			$global:EGOForm.Controls.Add($global:Label2)
			$global:EGOForm.controls.Add($global:Txt2)
			$lpos+=80
		}
		If($global:EGOSidestr -ge 3){
			$global:Label3.Location = New-Object System.Drawing.Size(10,$lpos)
			$global:Txt3.location = new-object system.drawing.point(210,$lpos)
			$global:EGOForm.Controls.Add($global:Label3)
			$global:EGOForm.controls.Add($global:Txt3)
			$lpos+=80
		}
		If($global:EGOSidestr -ge 4){
			$global:Label4.Location = New-Object System.Drawing.Size(10,$lpos)
			$global:Txt4.location = new-object system.drawing.point(210,$lpos)
			$global:EGOForm.Controls.Add($global:Label4)
			$global:EGOForm.controls.Add($global:Txt4)
			$lpos+=80
		}
		If($global:EGOSidestr -ge 5){
			$global:Label5.Location = New-Object System.Drawing.Size(10,$lpos)
			$global:Txt5.location = new-object system.drawing.point(210,$lpos)
			$global:EGOForm.Controls.Add($global:Label5)
			$global:EGOForm.controls.Add($global:Txt5)
			$lpos+=80
		}
		If($global:EGOSidestr -ge 6){
			$global:Label6.Location = New-Object System.Drawing.Size(10,$lpos)
			$global:Txt6.location = new-object system.drawing.point(210,$lpos)
			$global:EGOForm.Controls.Add($global:Label6)
			$global:EGOForm.controls.Add($global:Txt6)
			$lpos+=80
		}
		If($global:EGOSidestr -ge 7){
			$global:Label7.Location = New-Object System.Drawing.Size(10,$lpos)
			$global:Txt7.location = new-object system.drawing.point(210,$lpos)
			$global:EGOForm.Controls.Add($global:Label7)
			$global:EGOForm.controls.Add($global:Txt7)
			$lpos+=80
		}
		If($global:EGOSidestr -ge 8){
			$global:Label8.Location = New-Object System.Drawing.Size(10,$lpos)
			$global:Txt8.location = new-object system.drawing.point(210,$lpos)
			$global:EGOForm.Controls.Add($global:Label8)
			$global:EGOForm.controls.Add($global:Txt8)
			$lpos+=80
		}
		If($global:EGOSidestr -ge 9){
			$global:Label9.Location = New-Object System.Drawing.Size(10,$lpos)
			$global:Txt9.location = new-object system.drawing.point(210,$lpos)
			$global:EGOForm.Controls.Add($global:Label9)
			$global:EGOForm.controls.Add($global:Txt9)
			$lpos+=80
		}
		If($global:EGOSidestr -ge 10){
			$global:Label10.Location = New-Object System.Drawing.Size(10,$lpos)
			$global:Txt10.location = new-object system.drawing.point(210,$lpos)
			$global:EGOForm.Controls.Add($global:Label10)
			$global:EGOForm.controls.Add($global:Txt10)
			$lpos+=80
		}
		If($global:EGOSidestr -ge 11){
			$global:Label11.Location = New-Object System.Drawing.Size(10,$lpos)
			$global:Txt11.location = new-object system.drawing.point(210,$lpos)
			$global:EGOForm.Controls.Add($global:Label11)
			$global:EGOForm.controls.Add($global:Txt11)
			$lpos+=80
		}
	#$global:Txt0.Font = "Microsoft Sans Serif,10"
			
	# Plus(+) Knap definition
		$Plusbutton = New-Object System.Windows.Forms.Button 
		$Plusbutton.Location = New-Object System.Drawing.Size(640,$lpos) 
		$Plusbutton.Size = New-Object System.Drawing.Size(30,30) 
		$Plusbutton.Add_Click({$global:EGOForm.Close()}) 
		$Plusbutton.DialogResult = "Yes" 
		$Plusbutton.Text = "+" 
		$global:EGOForm.Controls.Add($Plusbutton)
	# Minus(-) Knap definition
		$Minusbutton = New-Object System.Windows.Forms.Button 
		$Minusbutton.Location = New-Object System.Drawing.Size(730,$lpos) 
		$Minusbutton.Size = New-Object System.Drawing.Size(30,30) 
		$Minusbutton.Add_Click({$global:EGOForm.Close()}) 
		$Minusbutton.DialogResult = "No" 
		$Minusbutton.Text = "-" 
		$global:EGOForm.Controls.Add($Minusbutton)
	# OK Knap definition
		$okpos=$lpos+40
		$Okbutton = New-Object System.Windows.Forms.Button 
		$Okbutton.Location = New-Object System.Drawing.Size(10,$okpos) 
		$Okbutton.Size = New-Object System.Drawing.Size(280,40) 
		#$Okbutton.AutoSize = $false
		#$Okbutton.Add_Click({Return-DropDown $DropDown}) 
		$Okbutton.Add_Click({$global:EGOForm.Close()}) 
		$Okbutton.DialogResult = "Ok" 
		$global:EGOForm.Controls.Add($Okbutton)
	# Annuler Knap definition
		$Cancelbutton = New-Object System.Windows.Forms.Button 
		$Cancelbutton.Location = New-Object System.Drawing.Size(360,$okpos) 
		$Cancelbutton.Size = New-Object System.Drawing.Size(200,40) 
		#$Cancelbutton.AutoSize = $true 
		$Cancelbutton.Text = "Annuler Valg" 
		$Cancelbutton.Add_Click({$global:EGOForm.Close()}) 
		$Cancelbutton.DialogResult = "Cancel" # values: None,Ok,Cancel,Abort,Retry,Ignore,Yes,No
		$global:EGOForm.Controls.Add($Cancelbutton)
	# Reset Knap definition
		$Resetbutton = New-Object System.Windows.Forms.Button 
		$Resetbutton.Location = New-Object System.Drawing.Size(630,$okpos) 
		$Resetbutton.Size = New-Object System.Drawing.Size(200,40) 
		#$Resetbutton.AutoSize = $true 
		$Resetbutton.Text = "Reset Liste" 
		$Resetbutton.Add_Click({$global:EGOForm.Close()}) 
		$Resetbutton.DialogResult = "Retry" # values: None,Ok,Cancel,Abort,Retry,Ignore,Yes,No
		$global:EGOForm.Controls.Add($Resetbutton)
		$global:EGOForm.Text = "Liste over Powershell cmdlets med synopsis kodeord."
		$Okbutton.Text = "Check \& brug Parametre" 
	# add an image/logo
		$img = [System.Drawing.Image]::Fromfile('\\dksund.dk\koncern\SDS\SDrev\mssql\u\sds.png')
		$pictureBox = new-object Windows.Forms.PictureBox
		$pictureBox.Location = new-object System.Drawing.Size(865,$lpos)
		$pictureBox.Width = $img.Size.Width
		$pictureBox.Height = $img.Size.Height
		$pictureBox.Image = $img
		$global:EGOForm.controls.add($pictureBox)
	# Assign the Accept and Cancel options in the form to the corresponding buttons
		$global:EGOForm.AcceptButton = $OKButton
		$global:EGOForm.CancelButton = $CancelButton
	}
	#$colors = [enum]::GetValues([System.ConsoleColor])

	Function Label-White { 
		$global:Label0.BackColor=[System.Drawing.Color]::FromName("White") ; $global:Txt0.BackColor=[System.Drawing.Color]::FromName("White") # kan være Transparent
		$global:Label1.BackColor=[System.Drawing.Color]::FromName("White") ; $global:Txt1.BackColor=[System.Drawing.Color]::FromName("White") 
		$global:Label2.BackColor=[System.Drawing.Color]::FromName("White") ; $global:Txt2.BackColor=[System.Drawing.Color]::FromName("White") 
		$global:Label3.BackColor=[System.Drawing.Color]::FromName("White") ; $global:Txt3.BackColor=[System.Drawing.Color]::FromName("White") 
		$global:Label4.BackColor=[System.Drawing.Color]::FromName("White") ; $global:Txt4.BackColor=[System.Drawing.Color]::FromName("White") 
		$global:Label5.BackColor=[System.Drawing.Color]::FromName("White") ; $global:Txt5.BackColor=[System.Drawing.Color]::FromName("White") 
		$global:Label6.BackColor=[System.Drawing.Color]::FromName("White") ; $global:Txt6.BackColor=[System.Drawing.Color]::FromName("White") 
		$global:Label7.BackColor=[System.Drawing.Color]::FromName("White") ; $global:Txt7.BackColor=[System.Drawing.Color]::FromName("White") 
		$global:Label8.BackColor=[System.Drawing.Color]::FromName("White") ; $global:Txt8.BackColor=[System.Drawing.Color]::FromName("White") 
		$global:Label9.BackColor=[System.Drawing.Color]::FromName("White") ; $global:Txt9.BackColor=[System.Drawing.Color]::FromName("White") 
		$global:Label10.BackColor=[System.Drawing.Color]::FromName("White") ; $global:Txt10.BackColor=[System.Drawing.Color]::FromName("White") 
		$global:Label11.BackColor=[System.Drawing.Color]::FromName("White") ; $global:Txt11.BackColor=[System.Drawing.Color]::FromName("White") 
	}

	Function Check-Parm {
		#Write-Host $pss.keys.count
		$rs=0
		$global:Label0.Text=" " ; $global:Txt0.Text=" "  #;$global:Label0.Add_Click({$global:Label0.BackColor=[System.Drawing.Color]::FromName("Lightblue");$global:Valgt=$global:Label0.Text }) 
		$global:Label1.Text=" " ; $global:Txt1.Text=" "  #;$global:Label1.Add_Click({$global:Label1.BackColor=[System.Drawing.Color]::FromName("Lightblue");$global:Valgt=$global:Label0.Text }) 
		$global:Label2.Text=" " ; $global:Txt2.Text=" "  #;$global:Label2.Add_Click({$global:Label2.BackColor=[System.Drawing.Color]::FromName("Lightblue");$global:Valgt=$global:Label0.Text }) 
		$global:Label3.Text=" " ; $global:Txt3.Text=" "  #;$global:Label3.Add_Click({$global:Label3.BackColor=[System.Drawing.Color]::FromName("Lightblue");$global:Valgt=$global:Label0.Text }) 
		$global:Label4.Text=" " ; $global:Txt4.Text=" "  #;$global:Label4.Add_Click({$global:Label4.BackColor=[System.Drawing.Color]::FromName("Lightblue");$global:Valgt=$global:Label0.Text }) 
		$global:Label5.Text=" " ; $global:Txt5.Text=" "  #;$global:Label5.Add_Click({$global:Label5.BackColor=[System.Drawing.Color]::FromName("Lightblue");$global:Valgt=$global:Label0.Text }) 
		$global:Label6.Text=" " ; $global:Txt6.Text=" "  #;$global:Label6.Add_Click({$global:Label6.BackColor=[System.Drawing.Color]::FromName("Lightblue");$global:Valgt=$global:Label0.Text }) 
		$global:Label7.Text=" " ; $global:Txt7.Text=" "  #;$global:Label7.Add_Click({$global:Label7.BackColor=[System.Drawing.Color]::FromName("Lightblue");$global:Valgt=$global:Label0.Text }) 
		$global:Label8.Text=" " ; $global:Txt8.Text=" "  #;$global:Label8.Add_Click({$global:Label8.BackColor=[System.Drawing.Color]::FromName("Lightblue");$global:Valgt=$global:Label0.Text }) 
		$global:Label9.Text=" " ; $global:Txt9.Text=" "  #;$global:Label9.Add_Click({$global:Label9.BackColor=[System.Drawing.Color]::FromName("Lightblue");$global:Valgt=$global:Label0.Text }) 
		$global:Label10.Text=" " ; $global:Txt10.Text=" "  #;$global:Label10.Add_Click({$global:Label10.BackColor=[System.Drawing.Color]::FromName("Lightblue");$global:Valgt=$global:Label0.Text }) 
		$global:Label11.Text=" " ; $global:Txt11.Text=" "  #;$global:Label11.Add_Click({$global:Label11.BackColor=[System.Drawing.Color]::FromName("Lightblue");$global:Valgt=$global:Label0.Text }) 
		for ($j=0;(($j -lt $global:EGOSidestr+1) -and ($j+$global:EGOpos -lt $global:EGOfundet)) ;$j++){
			#$EGOFil = $global:EGOFilListe[($j+$global:EGOpos)]
			#$EGOFil.group[0].filename
			#$b=Get-Content $EGOFil.group[0].Path | Select-Object -skip $EGOFil.group[0].LineNumber -first 3
			$EgoCrLf= "`r`n"
			Switch ($j)
			{
				0		{$global:Label0.Text = $EGOL[$j+$global:EGOpos]; $global:Txt0.Text = $global:EGO1[$j+$global:EGOpos]+$EgoCrLf+$global:EGO2[$j+$global:EGOpos]+$EgoCrLf+$global:EGO3[$j+$global:EGOpos];$global:Label0.Add_Click({Label-White;$global:Label0.BackColor=[System.Drawing.Color]::FromName("Lightblue");$global:Valgt=$global:Label0.Text }) }
				1		{$global:Label1.Text = $EGOL[$j+$global:EGOpos]; $global:Txt1.Text = $global:EGO1[$j+$global:EGOpos]+$EgoCrLf+$global:EGO2[$j+$global:EGOpos]+$EgoCrLf+$global:EGO3[$j+$global:EGOpos];$global:Label1.Add_Click({Label-White;$global:Label1.BackColor=[System.Drawing.Color]::FromName("Lightblue");$global:Valgt=$global:Label1.Text }) }
				2		{$global:Label2.Text = $EGOL[$j+$global:EGOpos]; $global:Txt2.Text = $global:EGO1[$j+$global:EGOpos]+$EgoCrLf+$global:EGO2[$j+$global:EGOpos]+$EgoCrLf+$global:EGO3[$j+$global:EGOpos];$global:Label2.Add_Click({Label-White;$global:Label2.BackColor=[System.Drawing.Color]::FromName("Lightblue");$global:Valgt=$global:Label2.Text }) }
				3		{$global:Label3.Text = $EGOL[$j+$global:EGOpos]; $global:Txt3.Text = $global:EGO1[$j+$global:EGOpos]+$EgoCrLf+$global:EGO2[$j+$global:EGOpos]+$EgoCrLf+$global:EGO3[$j+$global:EGOpos];$global:Label3.Add_Click({Label-White;$global:Label3.BackColor=[System.Drawing.Color]::FromName("Lightblue");$global:Valgt=$global:Label3.Text }) }
				4		{$global:Label4.Text = $EGOL[$j+$global:EGOpos]; $global:Txt4.Text = $global:EGO1[$j+$global:EGOpos]+$EgoCrLf+$global:EGO2[$j+$global:EGOpos]+$EgoCrLf+$global:EGO3[$j+$global:EGOpos];$global:Label4.Add_Click({Label-White;$global:Label4.BackColor=[System.Drawing.Color]::FromName("Lightblue");$global:Valgt=$global:Label4.Text }) }
				5		{$global:Label5.Text = $EGOL[$j+$global:EGOpos]; $global:Txt5.Text = $global:EGO1[$j+$global:EGOpos]+$EgoCrLf+$global:EGO2[$j+$global:EGOpos]+$EgoCrLf+$global:EGO3[$j+$global:EGOpos];$global:Label5.Add_Click({Label-White;$global:Label5.BackColor=[System.Drawing.Color]::FromName("Lightblue");$global:Valgt=$global:Label5.Text }) }
				6		{$global:Label6.Text = $EGOL[$j+$global:EGOpos]; $global:Txt6.Text = $global:EGO1[$j+$global:EGOpos]+$EgoCrLf+$global:EGO2[$j+$global:EGOpos]+$EgoCrLf+$global:EGO3[$j+$global:EGOpos];$global:Label6.Add_Click({Label-White;$global:Label6.BackColor=[System.Drawing.Color]::FromName("Lightblue");$global:Valgt=$global:Label6.Text }) }
				7		{$global:Label7.Text = $EGOL[$j+$global:EGOpos]; $global:Txt7.Text = $global:EGO1[$j+$global:EGOpos]+$EgoCrLf+$global:EGO2[$j+$global:EGOpos]+$EgoCrLf+$global:EGO3[$j+$global:EGOpos];$global:Label7.Add_Click({Label-White;$global:Label7.BackColor=[System.Drawing.Color]::FromName("Lightblue");$global:Valgt=$global:Label7.Text }) }
				8		{$global:Label8.Text = $EGOL[$j+$global:EGOpos]; $global:Txt8.Text = $global:EGO1[$j+$global:EGOpos]+$EgoCrLf+$global:EGO2[$j+$global:EGOpos]+$EgoCrLf+$global:EGO3[$j+$global:EGOpos];$global:Label8.Add_Click({Label-White;$global:Label8.BackColor=[System.Drawing.Color]::FromName("Lightblue");$global:Valgt=$global:Label8.Text }) }
				9		{$global:Label9.Text = $EGOL[$j+$global:EGOpos]; $global:Txt9.Text = $global:EGO1[$j+$global:EGOpos]+$EgoCrLf+$global:EGO2[$j+$global:EGOpos]+$EgoCrLf+$global:EGO3[$j+$global:EGOpos];$global:Label9.Add_Click({Label-White;$global:Label9.BackColor=[System.Drawing.Color]::FromName("Lightblue");$global:Valgt=$global:Label9.Text }) }
				10	{$global:Label10.Text = $EGOL[$j+$global:EGOpos]; $global:Txt10.Text = $global:EGO1[$j+$global:EGOpos]+$EgoCrLf+$global:EGO2[$j+$global:EGOpos]+$EgoCrLf+$global:EGO3[$j+$global:EGOpos];$global:Label10.Add_Click({Label-White;$global:Label10.BackColor=[System.Drawing.Color]::FromName("Lightblue");$global:Valgt=$global:Label10.Text }) }
				11	{$global:Label11.Text = $EGOL[$j+$global:EGOpos]; $global:Txt11.Text = $global:EGO1[$j+$global:EGOpos]+$EgoCrLf+$global:EGO2[$j+$global:EGOpos]+$EgoCrLf+$global:EGO3[$j+$global:EGOpos];$global:Label11.Add_Click({Label-White;$global:Label11.BackColor=[System.Drawing.Color]::FromName("Lightblue");$global:Valgt=$global:Label11.Text }) }
			}	
		}
		$rc=$global:EGOForm.ShowDialog()
	#If($Form.DialogResult -eq "Cancel") {Write-Output "Ok Cancel!!";exit} 
	#Write-Host $Form.DialogResult
	#Write-Host "Rc $rc"
	
	

	# Gem resultat af ComboBox/dropdown box i variabel
		#$Bruger = ($DropDown.SelectedItem.ToString()).split(":")[0]
		If($rc -eq "Cancel"){Write-Output "Ok Cancel!";exit}
		If($rc -eq "Ignore"){Write-Output "Ok annuleret";exit}

	# Skift Record
		If($rc -eq "Yes"){	# Plusbutton trykket
			Label-White
			If (($global:EGOpos+ $global:EGOSidestr+1) -lt $global:EGOfundet){
				$global:EGOpos=$global:EGOpos+$global:EGOSidestr+1;
			}
		}
		If($rc -eq "No"){	# Minusbutton trykket
			Label-White
			If (($global:EGOpos+ $global:EGOSidestr) -gt $global:EGOSidestr){
				$global:EGOpos=$global:EGOpos-$global:EGOSidestr-1
			}
		}		
		If($rc -eq "Retry"){	# Resetbutton trykket
			Reset-Liste
			Label-White 
		}
		Return $rs
	}


#Write-Host "ForegroundColor is 12 : Red -  BackgroundColor is cyan :  "-ForegroundColor 1 -BackgroundColor 8

#exit
#Write-Host $global:EGOSidestr
	Vis-Vindue
	Reset-Liste
	Label-White 
	do {
		$rc=Check-Parm 
		#Write-host "Res= $rc"
	} until ($rc -gt 0)

}
# SIG # Begin signature block
# MIIdAgYJKoZIhvcNAQcCoIIc8zCCHO8CAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCBdi7yHHHTUKsmz
# wVyu5HnOWjHa5vhHGUyBAGOEUeicB6CCGBMwggT+MIID5qADAgECAhANQkrgvjqI
# /2BAIc4UAPDdMA0GCSqGSIb3DQEBCwUAMHIxCzAJBgNVBAYTAlVTMRUwEwYDVQQK
# EwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xMTAvBgNV
# BAMTKERpZ2lDZXJ0IFNIQTIgQXNzdXJlZCBJRCBUaW1lc3RhbXBpbmcgQ0EwHhcN
# MjEwMTAxMDAwMDAwWhcNMzEwMTA2MDAwMDAwWjBIMQswCQYDVQQGEwJVUzEXMBUG
# A1UEChMORGlnaUNlcnQsIEluYy4xIDAeBgNVBAMTF0RpZ2lDZXJ0IFRpbWVzdGFt
# cCAyMDIxMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAwuZhhGfFivUN
# CKRFymNrUdc6EUK9CnV1TZS0DFC1JhD+HchvkWsMlucaXEjvROW/m2HNFZFiWrj/
# ZwucY/02aoH6KfjdK3CF3gIY83htvH35x20JPb5qdofpir34hF0edsnkxnZ2OlPR
# 0dNaNo/Go+EvGzq3YdZz7E5tM4p8XUUtS7FQ5kE6N1aG3JMjjfdQJehk5t3Tjy9X
# tYcg6w6OLNUj2vRNeEbjA4MxKUpcDDGKSoyIxfcwWvkUrxVfbENJCf0mI1P2jWPo
# GqtbsR0wwptpgrTb/FZUvB+hh6u+elsKIC9LCcmVp42y+tZji06lchzun3oBc/gZ
# 1v4NSYS9AQIDAQABo4IBuDCCAbQwDgYDVR0PAQH/BAQDAgeAMAwGA1UdEwEB/wQC
# MAAwFgYDVR0lAQH/BAwwCgYIKwYBBQUHAwgwQQYDVR0gBDowODA2BglghkgBhv1s
# BwEwKTAnBggrBgEFBQcCARYbaHR0cDovL3d3dy5kaWdpY2VydC5jb20vQ1BTMB8G
# A1UdIwQYMBaAFPS24SAd/imu0uRhpbKiJbLIFzVuMB0GA1UdDgQWBBQ2RIaOpLqw
# Zr68KC0dRDbd42p6vDBxBgNVHR8EajBoMDKgMKAuhixodHRwOi8vY3JsMy5kaWdp
# Y2VydC5jb20vc2hhMi1hc3N1cmVkLXRzLmNybDAyoDCgLoYsaHR0cDovL2NybDQu
# ZGlnaWNlcnQuY29tL3NoYTItYXNzdXJlZC10cy5jcmwwgYUGCCsGAQUFBwEBBHkw
# dzAkBggrBgEFBQcwAYYYaHR0cDovL29jc3AuZGlnaWNlcnQuY29tME8GCCsGAQUF
# BzAChkNodHRwOi8vY2FjZXJ0cy5kaWdpY2VydC5jb20vRGlnaUNlcnRTSEEyQXNz
# dXJlZElEVGltZXN0YW1waW5nQ0EuY3J0MA0GCSqGSIb3DQEBCwUAA4IBAQBIHNy1
# 6ZojvOca5yAOjmdG/UJyUXQKI0ejq5LSJcRwWb4UoOUngaVNFBUZB3nw0QTDhtk7
# vf5EAmZN7WmkD/a4cM9i6PVRSnh5Nnont/PnUp+Tp+1DnnvntN1BIon7h6JGA078
# 9P63ZHdjXyNSaYOC+hpT7ZDMjaEXcw3082U5cEvznNZ6e9oMvD0y0BvL9WH8dQgA
# dryBDvjA4VzPxBFy5xtkSdgimnUVQvUtMjiB2vRgorq0Uvtc4GEkJU+y38kpqHND
# Udq9Y9YfW5v3LhtPEx33Sg1xfpe39D+E68Hjo0mh+s6nv1bPull2YYlffqe0jmd4
# +TaY4cso2luHpoovMIIFMTCCBBmgAwIBAgIQCqEl1tYyG35B5AXaNpfCFTANBgkq
# hkiG9w0BAQsFADBlMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5j
# MRkwFwYDVQQLExB3d3cuZGlnaWNlcnQuY29tMSQwIgYDVQQDExtEaWdpQ2VydCBB
# c3N1cmVkIElEIFJvb3QgQ0EwHhcNMTYwMTA3MTIwMDAwWhcNMzEwMTA3MTIwMDAw
# WjByMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQL
# ExB3d3cuZGlnaWNlcnQuY29tMTEwLwYDVQQDEyhEaWdpQ2VydCBTSEEyIEFzc3Vy
# ZWQgSUQgVGltZXN0YW1waW5nIENBMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIB
# CgKCAQEAvdAy7kvNj3/dqbqCmcU5VChXtiNKxA4HRTNREH3Q+X1NaH7ntqD0jbOI
# 5Je/YyGQmL8TvFfTw+F+CNZqFAA49y4eO+7MpvYyWf5fZT/gm+vjRkcGGlV+Cyd+
# wKL1oODeIj8O/36V+/OjuiI+GKwR5PCZA207hXwJ0+5dyJoLVOOoCXFr4M8iEA91
# z3FyTgqt30A6XLdR4aF5FMZNJCMwXbzsPGBqrC8HzP3w6kfZiFBe/WZuVmEnKYmE
# UeaC50ZQ/ZQqLKfkdT66mA+Ef58xFNat1fJky3seBdCEGXIX8RcG7z3N1k3vBkL9
# olMqT4UdxB08r8/arBD13ays6Vb/kwIDAQABo4IBzjCCAcowHQYDVR0OBBYEFPS2
# 4SAd/imu0uRhpbKiJbLIFzVuMB8GA1UdIwQYMBaAFEXroq/0ksuCMS1Ri6enIZ3z
# bcgPMBIGA1UdEwEB/wQIMAYBAf8CAQAwDgYDVR0PAQH/BAQDAgGGMBMGA1UdJQQM
# MAoGCCsGAQUFBwMIMHkGCCsGAQUFBwEBBG0wazAkBggrBgEFBQcwAYYYaHR0cDov
# L29jc3AuZGlnaWNlcnQuY29tMEMGCCsGAQUFBzAChjdodHRwOi8vY2FjZXJ0cy5k
# aWdpY2VydC5jb20vRGlnaUNlcnRBc3N1cmVkSURSb290Q0EuY3J0MIGBBgNVHR8E
# ejB4MDqgOKA2hjRodHRwOi8vY3JsNC5kaWdpY2VydC5jb20vRGlnaUNlcnRBc3N1
# cmVkSURSb290Q0EuY3JsMDqgOKA2hjRodHRwOi8vY3JsMy5kaWdpY2VydC5jb20v
# RGlnaUNlcnRBc3N1cmVkSURSb290Q0EuY3JsMFAGA1UdIARJMEcwOAYKYIZIAYb9
# bAACBDAqMCgGCCsGAQUFBwIBFhxodHRwczovL3d3dy5kaWdpY2VydC5jb20vQ1BT
# MAsGCWCGSAGG/WwHATANBgkqhkiG9w0BAQsFAAOCAQEAcZUS6VGHVmnN793afKpj
# erN4zwY3QITvS4S/ys8DAv3Fp8MOIEIsr3fzKx8MIVoqtwU0HWqumfgnoma/Capg
# 33akOpMP+LLR2HwZYuhegiUexLoceywh4tZbLBQ1QwRostt1AuByx5jWPGTlH0gQ
# GF+JOGFNYkYkh2OMkVIsrymJ5Xgf1gsUpYDXEkdws3XVk4WTfraSZ/tTYYmo9WuW
# wPRYaQ18yAGxuSh1t5ljhSKMYcp5lH5Z/IwP42+1ASa2bKXuh1Eh5Fhgm7oMLStt
# osR+u8QlK0cCCHxJrhO24XxCQijGGFbPQTS2Zl22dHv1VjMiLyI2skuiSpXY9aaO
# UjCCBi0wggQVoAMCAQICE2oAANdl/WBX1Cl4R54AAQAA12UwDQYJKoZIhvcNAQEL
# BQAwSDESMBAGCgmSJomT8ixkARkWAmRrMRYwFAYKCZImiZPyLGQBGRYGZGtzdW5k
# MRowGAYDVQQDExFES1NVTkQgSXNzdWluZyBDQTAeFw0yMDA5MDkwOTEwMjhaFw0y
# NTA5MDgwOTEwMjhaMCgxJjAkBgNVBAMTHU1pa2FlbCBWZWlzdHJ1cC1WZXRsb3Yg
# KE1JVkUpMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA4wfkCXfwnVva
# 6BA19L5jKeKjH0tQ2zC5b/gKPtATh3rwDnXbnlXLy6+YBY+O3Lb9ZyZqJT5F5GFI
# XTK0w8m6wXj+EkT/UbnMPZRv0RTNePTzwwaRpMRifPwQD2V1PXk+1WbERHcC9uoh
# a27uR8ZU6ZxqS46mKb6fNEf1FSwTBjyDRhR+FA2Jf8JwfUYw7YFRnA6XtIY3htkY
# WTLDJpphw+mzOofqUrOY/eOOTejmWrIa+bHQg3ln6jHTfBsUo9eB5yyH8vfeHIQO
# I2FJQCnbs2hG75akh2HBViiP27oQKKstSKfuY1LpgHGxSr8g7lQTG5A6kTWbb0r7
# svtLRYYYuQIDAQABo4ICLjCCAiowPAYJKwYBBAGCNxUHBC8wLQYlKwYBBAGCNxUI
# h/nRJIXb10WCjYcZhcCgPYTQhCmBFPLKfrz0EgIBZAIBCjATBgNVHSUEDDAKBggr
# BgEFBQcDAzAOBgNVHQ8BAf8EBAMCB4AwGwYJKwYBBAGCNxUKBA4wDDAKBggrBgEF
# BQcDAzAdBgNVHQ4EFgQUL9wQMXuOxRzADB2QWCT78WWgF38wHwYDVR0jBBgwFoAU
# w4L0QWT8TyL4NsMTBaMx81ntghYwPwYDVR0fBDgwNjA0oDKgMIYuaHR0cDovL3Br
# aS5ka3N1bmQuZGsvREtTVU5EJTIwSXNzdWluZyUyMENBLmNybDCCAQQGCCsGAQUF
# BwEBBIH3MIH0MD0GCCsGAQUFBzAChjFodHRwOi8vcGtpLmRrc3VuZC5kay9ES1NV
# TkQlMjBJc3N1aW5nJTIwQ0EoMSkuY3J0MIGyBggrBgEFBQcwAoaBpWxkYXA6Ly8v
# Q049REtTVU5EJTIwSXNzdWluZyUyMENBLENOPUFJQSxDTj1QdWJsaWMlMjBLZXkl
# MjBTZXJ2aWNlcyxDTj1TZXJ2aWNlcyxDTj1Db25maWd1cmF0aW9uLERDPWRrc3Vu
# ZCxEQz1kaz9jQUNlcnRpZmljYXRlP2Jhc2U/b2JqZWN0Q2xhc3M9Y2VydGlmaWNh
# dGlvbkF1dGhvcml0eTAfBgNVHREEGDAWgRRNSVZFQHN1bmRoZWRzZGF0YS5kazAN
# BgkqhkiG9w0BAQsFAAOCAgEAaL1y1fp7myMA0rP6Yo7CiGJItA5z3qGTlbyLvgfB
# CVsg5EeMcWkLw7nRJSwuDnWjOA7jL9hoIK5Scy8I10KCXpzJX7KzKX6LocuTeEqt
# uKjmegQ3Ivv0B1fQHAJAGevgNl0OrGydMDkbVRkQmC0GbS9jdLMDWaGnsQaBeU+u
# BHvZ7kUwNAWBC0B5BFBMdmfX2juuMrtDoSHir/k5VpNeuhyutcY5RGHF934yUw5G
# fUOUrcZVYzodDyG+fhdJDPGPiqcq5SdURrwLaBbu00amj2wKzrouglLv5Xwe94qK
# TAUR4YYpW/6PSVr5lETCwFzBKkIQUxMjJ3LRCG9EtQo7dw8W35GR9bRW79nO5Fpt
# syf5ao1Zu9sRrYZYUzrEUZaLpoFbCdMN0KRAMqHY3ZLGOhWAFMnHfbZy+7JJ2svl
# gm97wQn64FYnrQjw+p+IGzt3nKAq/dzwpAGuDOPt7xOnwiPVOod+sw/G5pAZ6OAA
# 4igqgK5PaUBXmJquTDLf6RyMlWJex5O6myyHTKabzmF5ta6TeRgqUpfcefxU06ha
# NDIO5w1rmrEVLn+Jmd20jE4TucMO07i7EszdpSeuUeC2mzbDJlNOTkqnp5ul9bfT
# pSPzZT9gvchLZpgOTi1ck6LDe2eNw9wQgQ67kzdbA/Abnv6tlhiVOCUcf1t2XYN7
# vNcwggenMIIFj6ADAgECAhMSAAAAA/XTVIj+NIf5AAAAAAADMA0GCSqGSIb3DQEB
# CwUAMBkxFzAVBgNVBAMTDkRLU1VORCBSb290IENBMB4XDTE4MDMwNzExNTkwOVoX
# DTI4MDMwNzEyMDkwOVowSDESMBAGCgmSJomT8ixkARkWAmRrMRYwFAYKCZImiZPy
# LGQBGRYGZGtzdW5kMRowGAYDVQQDExFES1NVTkQgSXNzdWluZyBDQTCCAiIwDQYJ
# KoZIhvcNAQEBBQADggIPADCCAgoCggIBAJHxuqhN8Yo4v8+GwT1S89tOtHIZeu6n
# nGtG+nXBq5Um6/en0OkxQF15AjMr4aIQo7KQcEoGoeV6pkfPU2iy+xnLqZPar8sK
# fizfv8Oy8VQlquO/9McsulsKigJHHttoqvkr4tZc1vPUjsXL10aCEQq8zXCB5CJ5
# dCWAWFBJfb/Q/ywAfGBFIUPsaZlO7n5hMsLWZAxALmywnaH8/esZKrI7pyaj1b+P
# gBF877h3OCI96w1TH6iz/GHsmiO2/7+M8srbo7lwY1mqpWulujFotgRC6hnQnuqI
# ywwZLQut/oKUY32xIFKuRkeJMv+Sucv5zCFf/PlyKmR8xfOJ13TI9ktjusNbUaON
# iGGwD/g8J3ziuIjvaqE3Nn716v/8athfKkgZMXc5Hngd2dBi9R2S1Nyy2UI2hlWt
# YVJ7YDg1krHvjeDEwAKUP79UJLrLx7IJAaXxrySIl1K8EaJurNQdUbUb4SQNyCMK
# hHv3jOPw4j4yIFj3dMOqbPVdhn9qfzA4uo9xuXAKPEdM1a+TfkHnOD+ctbI/McHP
# 0+kwvMI29APqmlnA2g/je+PGkh0en3pRV0q7tmh39uXVa0KAgQ4o8zWwt62samuu
# q+9XMOTs+ZFwDXtK9wePw4QCRcsjMq9pD0xSSWlrrCH8XPQ4Y6GFhTJ3UCp07yT0
# gQBPFRQ6CsPLAgMBAAGjggK3MIICszAQBgkrBgEEAYI3FQEEAwIBATAjBgkrBgEE
# AYI3FQIEFgQUDOJFU7QVvhofIePf5eU+aJlSx6QwHQYDVR0OBBYEFMOC9EFk/E8i
# +DbDEwWjMfNZ7YIWMBkGCSsGAQQBgjcUAgQMHgoAUwB1AGIAQwBBMAsGA1UdDwQE
# AwIBhjAPBgNVHRMBAf8EBTADAQH/MB8GA1UdIwQYMBaAFG7UhySWgcqXaK5nzziA
# jEQF8yYFMIIBAQYDVR0fBIH5MIH2MIHzoIHwoIHthitodHRwOi8vcGtpLmRrc3Vu
# ZC5kay9ES1NVTkQlMjBSb290JTIwQ0EuY3JshoG9bGRhcDovLy9DTj1ES1NVTkQl
# MjBSb290JTIwQ0EsQ049Uy1QS0ktUk9PVDAxUCxDTj1DRFAsQ049UHVibGljJTIw
# S2V5JTIwU2VydmljZXMsQ049U2VydmljZXMsQ049Q29uZmlndXJhdGlvbixEQz1k
# a3N1bmQsREM9ZGs/Y2VydGlmaWNhdGVSZXZvY2F0aW9uTGlzdD9iYXNlP29iamVj
# dENsYXNzPWNSTERpc3RyaWJ1dGlvblBvaW50MIH7BggrBgEFBQcBAQSB7jCB6zA3
# BggrBgEFBQcwAoYraHR0cDovL3BraS5ka3N1bmQuZGsvREtTVU5EJTIwUm9vdCUy
# MENBLmNydDCBrwYIKwYBBQUHMAKGgaJsZGFwOi8vL0NOPURLU1VORCUyMFJvb3Ql
# MjBDQSxDTj1BSUEsQ049UHVibGljJTIwS2V5JTIwU2VydmljZXMsQ049U2Vydmlj
# ZXMsQ049Q29uZmlndXJhdGlvbixEQz1ka3N1bmQsREM9ZGs/Y0FDZXJ0aWZpY2F0
# ZT9iYXNlP29iamVjdENsYXNzPWNlcnRpZmljYXRpb25BdXRob3JpdHkwDQYJKoZI
# hvcNAQELBQADggIBAJ4ne9gV8KQyoFprJ35Rt/sO9u4aZWt2V24GmojT5Rlf5vfM
# 9xHc1wFMVepvW/JbPm2K744bu6/a5yBBUi5vHpTx3gzOVOUG01uIDln2kCIYgVda
# tnCP1xTkpGksnJW5S4qvHr7msRLTTWCG8X4MW5VbSfTJGGgs0uQ9v49wqaiOvopa
# TMMbQs4/HnJiVZU+IffG4iwOqgiEt7e5SOtFfTSd9D5qYEhNEfvf1jspB+aB1rV8
# 4Tj7SUlmQar2kfyDr6Lm2y0Gp8mLv2A0R9eHc3JggQFEyiVUhr7LkHJZf3541W9T
# UfR/RKcm/EEMdb1M7vvpT8VwPlvn0qzZ0TAsnDODH61u/WY3leEseYK/k9OL2LAp
# MEC+glnhC4KWZAwKLmBENr4XCISqysL/gMLtu5evCOiKZBJIcqZbX8poOWm2svF5
# iJ4oPgMoPJvL879LFDLrIBJsWBl4w7cdugiN1N7y+QYCkeYt+CrDtSvJcY3bEiXT
# 7YeuQkS95r/OatebJorp7WD1ZOrbnbAJuAcTFcV5/Ed+J7Vk1oEBeiy8DLxrXhQf
# OvrDIS9fWX0v7N+xH1pnjittto3bywKP7D98QQ2md8JrJONIu4X+gR4z8MlRKMrq
# InUVdnqClX3xfoeq1vVCWnS4vMh8TMn4LJe/g15PO7l1DJL2ZI4lOohSEqCZMYIE
# RTCCBEECAQEwXzBIMRIwEAYKCZImiZPyLGQBGRYCZGsxFjAUBgoJkiaJk/IsZAEZ
# FgZka3N1bmQxGjAYBgNVBAMTEURLU1VORCBJc3N1aW5nIENBAhNqAADXZf1gV9Qp
# eEeeAAEAANdlMA0GCWCGSAFlAwQCAQUAoIGEMBgGCisGAQQBgjcCAQwxCjAIoAKA
# AKECgAAwGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEO
# MAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEIPy36954lE4Kl77AnmiU6tZw
# uH4ihOxT4HkV0bN76QB7MA0GCSqGSIb3DQEBAQUABIIBAK2HJqxT6t9FGD5YK1qb
# wtzFHkjIr83CsyIBzLF3AB32JiwoTGjk9gPg4ArYwTmr6ZNaSsbi3GyFWk/JbJEQ
# T/0qIops3HmT4PdgxhO2hvjn33R+yzoZMihMCg3sS3EbDEKdHlMboXIM5MePmI2d
# Hl9Ce8JJ0igcIXjUh12LnE79jXiCdD+ZBU0UcfJt1+vvRSDio8iMQIj1r68S+2xZ
# T3rY8aiHewqkcwxpxoqed/iVVDh3O1+PGrv/Lc/zRgZ27QHqHNfHpambdc9pfJnf
# FTGYexEqT3VIylRGU0Is2KAzctCwbR5eStX0wblT0pOimK+A0qeTpYvfGM6rI3tD
# h06hggIwMIICLAYJKoZIhvcNAQkGMYICHTCCAhkCAQEwgYYwcjELMAkGA1UEBhMC
# VVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQd3d3LmRpZ2ljZXJ0
# LmNvbTExMC8GA1UEAxMoRGlnaUNlcnQgU0hBMiBBc3N1cmVkIElEIFRpbWVzdGFt
# cGluZyBDQQIQDUJK4L46iP9gQCHOFADw3TANBglghkgBZQMEAgEFAKBpMBgGCSqG
# SIb3DQEJAzELBgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTIxMTIwODA5NDUx
# N1owLwYJKoZIhvcNAQkEMSIEIAakSEzy4mkUyEg9jNXJvsmqsvBD4I3Hf1jVbx0w
# q/s1MA0GCSqGSIb3DQEBAQUABIIBAKO92POA0WP/3374hu5gLxJGjjoD6aBafsS2
# pu2JrOXLrf7fExd836Tdbi7sS/ZgkhXh+wp4OsqCeMQlqM9+x2KUDB97AYAlwyup
# /kXieERwwxipsoZp24SPpBi15M7bAwe4veCSwuBj8Wvi2jxk5pSo5OvYk2PgvRXq
# cq7z67HBkt3XUSoPqDQGRBKbQYZzK/Dmgr22hdYEzjzHnXPhpP0LtVO/GwUfvwVL
# MDannKFHucWUiWEc3tMr5Ldltu86Gz9RqcTG7PP4xKL7YQXgfZyUF/B7CKOn50wf
# VwdgyhGXt7QT4kIAstgi2BJQ0fqiNK11VpF7QTzOCtK8IWv9ESA=
# SIG # End signature block
