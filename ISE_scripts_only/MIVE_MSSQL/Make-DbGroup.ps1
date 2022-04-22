<# 
.SYNOPSIS 
Dette Powershell script opretter .log dokument med kommandoer der giver forløb over SQL Server Database oprettelse.
Script opdateret Mikael Veistrup-Vetlov @ 20211201
Disse kommandoer kan kopieres  
- til PowerShell på server der har Powershell AD-modulerne aktiveret X2
- til MS SQL Server Management Studie der kan forbinde til databaseserveren
- til ServiceNow sagen som meddelelse til brugeren
- til PowerShell på databaseserveren som kommando til at starte TSM full backup af databasen
- som instruktion til full scan & Tabula Resa i Check_MK for at undgå fejl i overvågningen.
Script oprettet Mikael Veistrup-Vetlov @ 20190522

.DESCRIPTION 
Dette Powershell script opretter .log dokument med kommandoer der giver forløb over SQL Server Database oprettelse.
Disse kommandoer kan kopieres 
- til PowerShell på server der har Powershell AD-modulerne aktiveret X2
- til MS SQL Server Management Studie der kan forbinde til databaseserveren
- til ServiceNow sagen som meddelelse til brugeren
- til PowerShell på databaseserveren som kommando til at starte TSM full backup af databasen
- som instruktion til full scan & Tabula Resa i Check_MK for at undgå fejl i overvågningen.
Script oprettet Mikael Veistrup-Vetlov @ 20190522
Script opdateret Mikael Veistrup-Vetlov @ 20210901

.EXAMPLE 
.\Make-DbGroup.ps1 
Spørger via Gui om parametre til oprettelse af DataBase, Ad-Grupper mm. og klargør liste over script kommandoer for at styre igennem installationen.

.NOTES
.LINK
#> 
 #   [CmdletBinding()] 
Begin {
# udførende jobnavn: giver variable disk, sti, fil Kan ikke køres i include fil, da det vil være denne include fil der registreres
$EgoCmd=$PSCommandPath -Split("\\")     # $EgoCmd= 'm:','ps1','SQL-Installation.ps1'
$Egodisk=$EgoCmd[0]
$Egofil=$EgoCmd[-1]
If($EgoCmd.Count -lt 3){$Egosti=''}elseif($EgoCmd.Count -eq 3){$Egosti=$EgoCmd[1]}else{$EgoCmd1=$EgoCmd[1..($EgoCmd.Count-2)];$Egosti=$EgoCmd1 -join("\")}

# Function module File to include
$EgoF1="\\dksund.dk\koncern\SDS\SDrev\mssql"
$EgoF2="\\s-inf-fil-05-p.ssi.ad\pvl\INSTALL\SQLdba\ps1"
$EgoF3="\\TSCLIENT\S\mssql"
If (Test-Path $EgoF1){$EgoF=$EgoF1
}ElseIf(Test-Path $EgoF2){$EgoF=$EgoF2
}ElseIf(Test-Path $EgoF3){$EgoF=$EgoF3
}Else{Write-Host "Du har desværre Ikke privilegier til at tilgå scriptet, eller ikke privilegier på s:\mssql - Farvel!";exit}
# adgang til lokal log & totlog ??  og inclfunc
#$EgoF
$FincPath="$EgoF\u\inclFunc.ps1"
#$FincPath
If (test-path $FincPath){
. "$FincPath"
}
Get-EgoVar
$EgoFl=$EgoF2 -Replace("\\ps1","\log")
If (Test-Path $EgoFl){
	#"log fundet"
	$WrToLog=$EgoFl
	$WrToLog+="\Total-MkGrp.log"
	$EgoFl+="\"
	$EgoFl+=$EgoUser
	If (Test-Path $EgoFl){
		#"$EgoUser fundet"
	}Else{
		#"$EgoUser IKKE fundet"
		New-Item -ItemType directory -Path $EgoFl
	}
}Else {
	Write-Host "Du har desværre Ikke privilegier til at tilgå powershell Logdrevet, - Farvel!";exit
}

If (!(Test-Path $EgoFl)){
	Write-Host "Du har desværre Ikke Skrive privilegier på PowerShell Logdrevet: $EgoFl , - Farvel!";exit
}
$WrToFile=$EgoFl
$WrToFile+="\"
$WrToFile+=($Egofil -Replace("\.ps1",".log"))

# Lokale variable

If ($EgoUser.Substring(0,3) -eq "adm"){
	$mssqldba =$EgoUser.Substring(4)
}ElseIf ($EgoUser.Substring(0,3) -eq "adx"){
	$mssqldba ="eks"+$EgoUser.Substring(3)
}Else{
	$mssqldba =$EgoUser
}

$FSparm="Make-Group.$mssqldba.xml"
#$EgoFl="$Egodisk\$Egosti\"
$Mgp=[ordered]@{}
Function Reset-Parm{
	Write-Host "Param fil Oprettes"
	$Mgp.clear()
	$Mgp.mssqldba=$mssqldba
	$Mgp.System=""
	$Mgp.DBname=""
	$Mgp.DBLink=""
	$Mgp.SDnr=""
	$Mgp.Manager=""
	$Mgp.CoMan=""
	$Mgp.Sqlserver="$EgoServer"
	$Mgp.sqlinstans="MSSQLSERVER"
	$Mgp.ResDom="$EgoDomain"
	$Mgp.UserDom="Dksund.dk"
	$Mgp.Schemas="test1,test2"
	$Mgp.Extension="r,w,d,o,m,t,u"
	$Mgp.Beskr ="Hvad"
	$Mgp.SuppGrp ="Database-Bi Assignment"
	$Mgp.Gdpr=""
	$Mgp.Exec=$false
}

if(test-Path $EgoFl\$FSparm){
	Write-Host "Param fil findes"
	$Mgp=Import-Clixml -Path $EgoFl\$FSparm
}else{
	Reset-Parm
	$Mgp|Export-Clixml -path $EgoFl\$FSparm
}

# opret nyt vindue
	$lpos=10
	[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")  
	[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") 
	[void] [System.Windows.Forms.Application]::EnableVisualStyles()  
# Form definitionen
	$Form = New-Object system.Windows.Forms.Form 
	$Form.Size = New-Object System.Drawing.Size(1500,1200) 
	$Form.MaximizeBox = $false 
	$Form.MinimizeBox = $false 
	$Form.StartPosition = "CenterScreen" 
	$Form.FormBorderStyle = 'Fixed3D' 
	#$Font = New-Object System.Drawing.Font("Arial",15,[System.Drawing.FontStyle]::Bold) 
	$Font = New-Object System.Drawing.Font("Times New Roman",15)
	$Form.Font = $Font 
	
	
#	$laba = New-Object System.Windows.Forms.label
#	$Laba.Size = New-Object System.Drawing.Size(150,30)
#	$Texta = New-Object system.windows.Forms.TextBox
#$TxtA.Width=1000


# label
	$Label0 = New-Object System.Windows.Forms.label
	$Label1 = New-Object System.Windows.Forms.label
	$Label2 = New-Object System.Windows.Forms.label
	$Label3 = New-Object System.Windows.Forms.label
	$Label4 = New-Object System.Windows.Forms.label
	$Label5 = New-Object System.Windows.Forms.label
	$Label6 = New-Object System.Windows.Forms.label
	$Label7 = New-Object System.Windows.Forms.label
	$Label8 = New-Object System.Windows.Forms.label
	$Label9 = New-Object System.Windows.Forms.label
	$LabelA = New-Object System.Windows.Forms.label
	$LabelB = New-Object System.Windows.Forms.label
	$LabelC = New-Object System.Windows.Forms.label
	$LabelD = New-Object System.Windows.Forms.label
	$LabelE = New-Object System.Windows.Forms.label
	$LabelF = New-Object System.Windows.Forms.label
	$Label0.Size = $Label1.Size = $Label2.Size = $Label3.Size = $Label4.Size = $Label5.Size = $Label6.Size = $LabelF.Size = New-Object System.Drawing.Size(150,30)
	$Label7.Size = $Label8.Size = $Label9.Size = $LabelA.Size = $LabelB.Size = $LabelC.Size = $LabelD.Size = $LabelE.Size = New-Object System.Drawing.Size(150,30)
	$Txt0 = New-Object system.windows.Forms.TextBox
	$Txt1 = New-Object system.windows.Forms.TextBox
	$Txt2 = New-Object system.windows.Forms.TextBox
	$Txt3 = New-Object system.windows.Forms.TextBox
	$Txt4 = New-Object system.windows.Forms.TextBox
	$Txt5 = New-Object system.windows.Forms.TextBox
	$Txt6 = New-Object system.windows.Forms.TextBox
	$Txt7 = New-Object system.windows.Forms.TextBox
	$Txt8 = New-Object system.windows.Forms.TextBox
	$Txt9 = New-Object system.windows.Forms.TextBox
	$TxtA = New-Object system.windows.Forms.TextBox
	$TxtB = New-Object system.windows.Forms.TextBox
	$TxtC = New-Object system.windows.Forms.TextBox
	$TxtD = New-Object system.windows.Forms.TextBox
	$TxtE = New-Object system.windows.Forms.TextBox
	$TxtF = New-Object system.windows.Forms.TextBox
	$Txt0.Width=$Txt1.Width=$Txt2.Width=$Txt3.Width=$Txt4.Width=$Txt5.Width=$Txt6.Width=$Txt7.Width=$Txt8.Width=$Txt9.Width=$TxtA.Width=$TxtB.Width=$TxtC.Width=$TxtD.Width=$TxtE.Width=1000
	$TxtF.Width=100
	$Txt0.Height=$Txt1.Height=$Txt2.Height=$Txt3.Height=$Txt4.Height=$Txt5.Height=$Txt6.Height=$Txt7.Height=$Txt8.Height=$Txt9.Height=$TxtA.Height=$TxtB.Height=$TxtC.Height=$TxtD.Height=$TxtE.Height=$TxtF.Height=30
	$Txt0.AcceptsTab=$Txt1.AcceptsTab=$Txt2.AcceptsTab=$Txt3.AcceptsTab=$Txt4.AcceptsTab=$true
	$Txt5.AcceptsTab=$Txt6.AcceptsTab=$Txt7.AcceptsTab=$Txt8.AcceptsTab=$Txt9.AcceptsTab=$TxtA.AcceptsTab=$TxtB.AcceptsTab=$TxtC.AcceptsTab=$TxtD.AcceptsTab=$TxtE.AcceptsTab=$TxtF.AcceptsTab=$true
	$Label0.Location = New-Object System.Drawing.Size(10,$lpos)
	$Txt0.location = new-object system.drawing.point(160,$lpos)
	$lpos+=40
	$Label1.Location = New-Object System.Drawing.Size(10,$lpos)
	$Txt1.location = new-object system.drawing.point(160,$lpos)
	$lpos+=40
	$Label2.Location = New-Object System.Drawing.Size(10,$lpos)
	$Txt2.location = new-object system.drawing.point(160,$lpos)
	$lpos+=40
	$Label3.Location = New-Object System.Drawing.Size(10,$lpos)
	$Txt3.location = new-object system.drawing.point(160,$lpos)
	$lpos+=40
	$Label4.Location = New-Object System.Drawing.Size(10,$lpos)
	$Txt4.location = new-object system.drawing.point(160,$lpos)
	$lpos+=40
	$Label5.Location = New-Object System.Drawing.Size(10,$lpos)
	$Txt5.location = new-object system.drawing.point(160,$lpos)
	$lpos+=40
	$Label6.Location = New-Object System.Drawing.Size(10,$lpos)
	$Txt6.location = new-object system.drawing.point(160,$lpos)
	$lpos+=40
	$Label7.Location = New-Object System.Drawing.Size(10,$lpos)
	$Txt7.location = new-object system.drawing.point(160,$lpos)
	$lpos+=40
	$Label8.Location = New-Object System.Drawing.Size(10,$lpos)
	$Txt8.location = new-object system.drawing.point(160,$lpos)
	$lpos+=40
	$Label9.Location = New-Object System.Drawing.Size(10,$lpos)
	$Txt9.location = new-object system.drawing.point(160,$lpos)
	$lpos+=40
	$LabelA.Location = New-Object System.Drawing.Size(10,$lpos)
	$TxtA.location = new-object system.drawing.point(160,$lpos)
	$lpos+=40
	$LabelB.Location = New-Object System.Drawing.Size(10,$lpos)
	$TxtB.location = new-object system.drawing.point(160,$lpos)
	$lpos+=40
	$LabelC.Location = New-Object System.Drawing.Size(10,$lpos)
	$TxtC.location = new-object system.drawing.point(160,$lpos)
	$lpos+=40
	$LabelD.Location = New-Object System.Drawing.Size(10,$lpos)
	$TxtD.location = new-object system.drawing.point(160,$lpos)
	$lpos+=40
	$LabelE.Location = New-Object System.Drawing.Size(10,$lpos)
	$Txte.location = new-object system.drawing.point(160,$lpos)
	$lpos+=40
	$LabelF.Location = New-Object System.Drawing.Size(10,$lpos)
	$TxtF.location = new-object system.drawing.point(160,$lpos)
	$lpos+=40
	 # create your checkbox 
    $ExecCheck = new-object System.Windows.Forms.checkbox
    $ExecCheck.Location = new-object System.Drawing.Size(10,$lpos)
    $ExecCheck.Size = new-object System.Drawing.Size(500,30)
    $ExecCheck.Text = "Check for at oprette grupperne direkte"
    $ExecCheck.Checked = $true
	$Label0.Text = "MssqlDBA:"
	$Label1.Text = "System / BS:"
	$Label2.Text = "DBname:"
	$Label3.Text = "DBLink:"
	$Label4.Text = "SDnr:"
	$Label5.Text = "Manager:"
	$Label6.Text = "CoMan:"
	$Label7.Text = "Sqlserver:"
	$Label8.Text = "Sqlinstans:"
	$Label9.Text = "ResDom:"
	$LabelA.Text = "UserDom:"
	$LabelB.Text = "Schemas:"
	$LabelC.Text = "Extension:"
	$LabelD.Text = "DB Beskrivelse:"
	$LabelE.Text = "SupportGroup:"
	$LabelF.Text = "PersonHenført:"
	$Form.Controls.Add($Label0)
	$Form.controls.Add($Txt0)
	$Form.Controls.Add($Label1)
	$Form.controls.Add($Txt1)
	$Form.Controls.Add($Label2)
	$Form.controls.Add($Txt2)
	$Form.Controls.Add($Label3)
	$Form.controls.Add($Txt3)
	$Form.Controls.Add($Label4)
	$Form.controls.Add($Txt4)
	$Form.Controls.Add($Label5)
	$Form.controls.Add($Txt5)
	$Form.Controls.Add($Label6)
	$Form.controls.Add($Txt6)
	$Form.Controls.Add($Label7)
	$Form.controls.Add($Txt7)
	$Form.Controls.Add($Label8)
	$Form.controls.Add($Txt8)
	$Form.Controls.Add($Label9)
	$Form.controls.Add($Txt9)
	$Form.Controls.Add($LabelA)
	$Form.controls.Add($TxtA)
	$Form.Controls.Add($LabelB)
	$Form.controls.Add($TxtB)
	$Form.Controls.Add($LabelC)
	$Form.controls.Add($TxtC)
	$Form.Controls.Add($LabelD)
	$Form.controls.Add($TxtD)
	$Form.Controls.Add($LabelE)
	$Form.controls.Add($TxtE)
	$Form.Controls.Add($LabelF)
	$Form.controls.Add($TxtF)
    $Form.Controls.Add($ExecCheck)  
	#$Txt0.Font = "Microsoft Sans Serif,10"
# OK Knap definition
	$okpos=$lpos+40
	$Okbutton = New-Object System.Windows.Forms.Button 
	$Okbutton.Location = New-Object System.Drawing.Size(10,$okpos) 
	$Okbutton.Size = New-Object System.Drawing.Size(280,40) 
	#$Okbutton.AutoSize = $false
	#$Okbutton.Add_Click({Return-DropDown $DropDown}) 
	$Okbutton.Add_Click({$Form.Close()}) 
	$Okbutton.DialogResult = "Ok" 
	$Form.Controls.Add($Okbutton)
# Annuler Knap definition
	$Cancelbutton = New-Object System.Windows.Forms.Button 
	$Cancelbutton.Location = New-Object System.Drawing.Size(360,$okpos) 
	$Cancelbutton.Size = New-Object System.Drawing.Size(200,40) 
	#$Cancelbutton.AutoSize = $true 
	$Cancelbutton.Text = "Annuler Valg" 
	$Cancelbutton.Add_Click({$Form.Close()}) 
	$Cancelbutton.DialogResult = "Cancel" # values: None,Ok,Cancel,Abort,Retry,Ignore,Yes,No
	$Form.Controls.Add($Cancelbutton)
# Reset Knap definition
	$Resetbutton = New-Object System.Windows.Forms.Button 
	$Resetbutton.Location = New-Object System.Drawing.Size(630,$okpos) 
	$Resetbutton.Size = New-Object System.Drawing.Size(200,40) 
	#$Resetbutton.AutoSize = $true 
	$Resetbutton.Text = "Reset Parametre" 
	$Resetbutton.Add_Click({$Form.Close()}) 
	$Resetbutton.DialogResult = "Retry" # values: None,Ok,Cancel,Abort,Retry,Ignore,Yes,No
	$Form.Controls.Add($Resetbutton)
	$Form.Text = "Angiv parametre for nye AD-Grupper for privilegier til DataBase"
	$Okbutton.Text = "Check \& brug Parametre" 
# add an image/logo
	$img = [System.Drawing.Image]::Fromfile('p:\sqldba\ps1\u\sds.png')
	$pictureBox = new-object Windows.Forms.PictureBox
	$pictureBox.Location = new-object System.Drawing.Size(865,$lpos)
	$pictureBox.Width = $img.Size.Width
	$pictureBox.Height = $img.Size.Height
	$pictureBox.Image = $img
	$form.controls.add($pictureBox)
	
#	$lpos+=100
#	 # Create a group that will contain your radio buttons
#    $MyGroupBox = New-Object System.Windows.Forms.GroupBox
#    $MyGroupBox.Location = "10,$lpos"
#    $MyGroupBox.size = '400,150'
#    $MyGroupBox.text = "Do you like Cheese?"
#    $lpos+=40
#    # Create the collection of radio buttons
#    $RadioButton1 = New-Object System.Windows.Forms.RadioButton
#    $RadioButton1.Location = "20,40"
#    $RadioButton1.size = '350,20'
#    $RadioButton1.Checked = $true 
#    $RadioButton1.Text = "Yes - I like Cheese."	
#	$lpos+=40
#    $RadioButton2 = New-Object System.Windows.Forms.RadioButton
#    $RadioButton2.Location = "20,70"
#    $RadioButton2.size = '350,20'
#    $RadioButton2.Checked = $false
#    $RadioButton2.Text = "No - I don't like Cheese."
#	$lpos+=40
#    $RadioButton3 = New-Object System.Windows.Forms.RadioButton
#    $RadioButton3.Location = "20,100"
#    $RadioButton3.size = '350,20'
#    $RadioButton3.Checked = $false
#    $RadioButton3.Text = "That depends on the chease."
#    # Add all the GroupBox controls on one line
#    $MyGroupBox.Controls.AddRange(@($Radiobutton1,$RadioButton2,$RadioButton3))
#	$form.controls.add($MyGroupBox)


$info = New-Object System.Windows.Forms.label
$info.Size = New-Object System.Drawing.Size(860,300)
$okpos4=$okpos+60
$info.Location = New-Object System.Drawing.Size(10,$okpos4)
$info.AutoSize = $false
$Infot=""
$Form.Controls.Add($info)
# Assign the Accept and Cancel options in the form to the corresponding buttons
    $form.AcceptButton = $OKButton
    $form.CancelButton = $CancelButton

Function Check-Parm {
    param(
        [hashtable]$pss
		)
	#Write-Host $pss.keys.count

	$Txt0.Text=$pss.mssqldba
	$Txt1.Text=$pss.System
	$Txt2.Text=$pss.DBname
	$Txt3.Text=$pss.DBLink
	$Txt4.Text=$pss.SDnr
	$Txt5.Text=$pss.Manager
	$Txt6.Text=$pss.CoMan
	$Txt7.Text=$pss.Sqlserver
	$Txt8.Text=$pss.sqlinstans
	$Txt9.Text=$pss.ResDom
	$TxtA.Text=$pss.UserDom
	$TxtB.Text=$pss.Schemas
	$TxtC.Text=$pss.Extension
	$TxtD.Text=$pss.Beskr
	$TxtE.Text=$pss.SuppGrp
	$TxtF.Text=$pss.Gdpr
	$ExecCheck.Checked=$pss.Exec

	
	$rc=$Form.ShowDialog()
	If($Form.DialogResult -eq "Cancel") {Write-Output "Ok Cancel!";exit} 

	$Infot=""
	# Gem resultat af ComboBox/dropdown box i variabel
	#$Bruger = ($DropDown.SelectedItem.ToString()).split(":")[0]
	If($rc -eq "Ignore"){Write-Host "Ok annuleret";exit}
	If($rc -eq "Retry"){$Infot+="Parametre resat!$EgoCrLf";Reset-Parm;Return 0}
	$rs=1

	If ($pss.mssqldba -ne $Txt0.Text){$Mgp.mssqldba = $Txt0.Text;$rs=0}
	If ($pss.System -ne $Txt1.Text){$Mgp.System = $Txt1.Text;$rs=0}
	If ($pss.DBname -ne $Txt2.Text){$Mgp.DBname = ($Txt2.Text).trim();$rs=0}
	If ($pss.DBLink -ne $Txt3.Text){$Mgp.DBLink = $Txt3.Text;$rs=0}
	If ($pss.SDnr -ne $Txt4.Text){[string]$Mgp.SDnr = $Txt4.Text;$rs=0}
	If ($pss.Manager -ne $Txt5.Text){$Mgp.Manager = $Txt5.Text;$rs=0}	
	If ($pss.CoMan -ne $Txt6.Text){$Mgp.CoMan = $Txt6.Text;$rs=0}
	If ($pss.Sqlserver -ne $Txt7.Text){$Mgp.Sqlserver = $Txt7.Text;$rs=0}
	If ($pss.sqlinstans -ne $Txt8.Text){$Mgp.sqlinstans = $Txt8.Text;$rs=0}
	If ($pss.ResDom -ne $Txt9.Text){$Mgp.ResDom = $Txt9.Text;$rs=0}
	If ($pss.UserDom -ne $TxtA.Text){$Mgp.UserDom = $TxtA.Text;$rs=0}
	If ($pss.Schemas -ne $TxtB.Text){$Mgp.Schemas = $TxtB.Text;$rs=0}
	If ($pss.Extension -ne $TxtC.Text){$Mgp.Extension = $TxtC.Text;$rs=0}
	If ($pss.Beskr -ne $TxtD.Text){$Mgp.Beskr = $TxtD.Text;$rs=0}
	If ($pss.SuppGrp -ne $TxtE.Text){$Mgp.SuppGrp = $TxtE.Text;$rs=0}
	If ($pss.Gdpr -ne $TxtF.Text){$Mgp.Gdpr = $TxtF.Text;$rs=0}

	If ($Mgp.mssqldba.length -lt 2){$Mgp.mssqldba = $mssqldba;$rs=0}
	If ($Mgp.System.length -lt 2){$Infot+="System skal være udfyldt!$EgoCrLf";$Mgp.System = "";$rs=0}
	If ($Mgp.DBname.length -lt 2){$Infot+="DBname skal være udfyldt!$EgoCrLf";$Mgp.DBname = "";$rs=0}
	If ($Mgp.DBLink.length -lt 2){$Infot+="DBLink skal være udfyldt, bruges til gruppenavn!$EgoCrLf";$Mgp.DBLink = $Mgp.DBname;$rs=0}
	#If ($Mgp.DBLink.length -gt 12){$Infot+="DBLink max 12 char, bruges til gruppenavn!$EgoCrLf";$Mgp.DBLink = $Mgp.DBLink.Substring(0,12);$rs=0}
	If ($Mgp.SDnr.length -lt 10){$Infot+="SD-nr skal starte med inc, chg, req eller ritm, efterfulgt af 7 cifre$EgoCrLf";$rs=0
	}ElseIf (!($Mgp.SDnr.substring(0,3) -in ("inc","chg","req","rit"))){$Infot+="SD-nr skal starte med inc, chg, req eller ritm, efterfulgt af 7 cifre$EgoCrLf"}
	If ($Mgp.Manager.length -lt 2){
		$Infot+="Manager skal være udfyldt!$EgoCrLf";$Mgp.Manager = "";$rs=0
	}Else{
		if(!(Is-AdUser $Mgp.Manager)){$Infot+="Manager findes ikke i dette AD!$EgoCrLf"
		}Else{
			If ($Mgp.CoMan.length -lt 2){$Mgp.CoMan = $Mgp.Manager;$rs=0}
			If (!($Mgp.CoMan.contains($Mgp.Manager))){$Mgp.CoMan = $Mgp.CoMan+","+$Mgp.Manager;$rs=0}
		}
	}
	If ($Mgp.CoMan.contains(" ")){$Infot+="CoManager skal adskilles af , !$EgoCrLf";$Mgp.CoMan = $Mgp.CoMan.Replace(" ",",");$rs=0}
	If ($Mgp.CoMan -match(",,")){$Mgp.CoMan = $Mgp.CoMan.Replace(",,",",");$rs=0}
	If ($Mgp.Sqlserver.length -lt 2){$Infot+="SqlServer navn skal være udfyldt!$EgoCrLf";$Mgp.Sqlserver = "$EgoServer";$rs=0}
	If ($Mgp.sqlinstans.length -lt 2){$Infot+="Instans navn skal være udfyldt!$EgoCrLf";$Mgp.sqlinstans = "MSSQLSERVER";$rs=0}
	If ($Mgp.ResDom.length -lt 2){$Infot+="ResDom er hvor ressourcen findes!$EgoCrLf";$Mgp.ResDom = "$EgoDomain";$rs=0}
	If ($Mgp.UserDom.length -lt 2){$Infot+="Userdom er hvor brugerne er oprettet!$EgoCrLf";$Mgp.UserDom = "Dksund.dk";$rs=0}
	If ($Mgp.Schemas.contains(" ")){$Infot+="Hvis privilegier skal gælde på Schema niveau!$EgoCrLf";$Mgp.Schemas=$Mgp.Schemas.Replace(" ",",");$rs=0}
	If ($Mgp.Extension.contains(" ")){$Infot+="Extensions=privilegietype, Read, Write, dbOwner, unMask, Dataadministrativ askilt af , skal være udfyldt!$EgoCrLf";$Mgp.Extension=$Mgp.Extension.Replace(" ",",");$rs=0}
	If ($Mgp.Schemas.contains(",")){
		$sch0=$Mgp.Schemas -split(",")
		foreach($Sch in $sch0){If ($Sch.length -gt 0){If($sch -match("_")){$sch.replace("_","")}}}
		$Mgp.Schemas=$sch0 -join(",")
	}
	If ($Mgp.Schemas -ne $TxtB.Text){$rs=0}
	If ($Mgp.Extension.contains(",")){
		$ext0=$Mgp.Extension -split(",")
		$ext=@()
		foreach($e in $ext0){If($e -in "r","w","d","o","m","t","u"){If(!($e -in $ext)){$ext+=$e}}}
		$Mgp.Extension = $ext -join(",")
	}
	If ($Mgp.Extension -ne $TxtC.Text){$rs=0}
	If ($Mgp.Extension.length -lt 1){$Mgp.Extension="r";$rs=0}
	If ($Mgp.Beskr.length -lt 5){$Infot+="Beskrivelsen skal udfyldes, min 10 char, max 80!$EgoCrLf";$Mgp.Beskr="";$rs=0}
	If ($Mgp.SuppGrp.length -lt 8){$Infot+="Support Gruppe skal udfyldes som ServiceNow Assignment gruppe!$EgoCrLf";$Mgp.SuppGrp="";$rs=0}
	If ($Mgp.Gdpr -in "j","ja","yes","y"){$Mgp.Gdpr="Ja"
	}ElseIf ($Mgp.Gdpr -in "n","nej","no"){$Mgp.Gdpr="Nej"
	}Else {$Infot+="Personhenførbart SKAL udfyldes. Hvis i tvivl, vælg ja! $EgoCrLf";$Mgp.Gdpr="Ja";$rs=0
	}
	
	If ($pss.Exec -ne $ExecCheck.Checked){
		$Mgp.Exec = $ExecCheck.Checked;
		$Infot+="Direkte Gruppeoprettelse ændret til ";
		$Infot+=$Mgp.Exec
		$Infot+="!$EgoCrLf";$rs=0}
	If ($Infot.length -lt 2){$Infot="Parametre kontrolleret, Klar til at udføre!"}
	$info.Text =$Infot
	Return $rs
}


do {
	$rc=Check-Parm $Mgp
} until ($rc -gt 0)
#"Userclose"
#$Form.CloseReason
#"DialogResult"
#$Form.DialogResult OK
#"Cancel fundet ved X"
#"???"





$Mgp|Export-Clixml -path $EgoFl\$FSparm
#exit
$rc=$form.Dispose()

if (Test-Path $WrToFile) {Remove-Item $WrToFile}

$System = $Mgp.System
# Hvis gruppe skal relatere til flere databaser på samme server, angiv med komma asdkilt
$DBname =@(($Mgp.DBname).split(","))
$DBLink = $Mgp.DBLink
$SDnr = $Mgp.SDnr
# Opret servicedesk sag hvis bruger ikke findes, tekst: Jeg kan ikke tilføje bruger som Manager felt, derfor skal der oprettes dummy bruger
$Manager = $Mgp.Manager
# (co manager)  initialer komma adskilt, skal indeholde ressourceejer!!
$CoMan =   $Mgp.CoMan	###CoManager
$mssqldba = $Mgp.mssqldba
$Sqlserver=$Mgp.Sqlserver
$sqlinstans=$Mgp.sqlinstans																	# default "MSSQLSERVER"
$ResDom = $Mgp.ResDom
$UserDom = $Mgp.UserDom


#$ext="r","o","w"  #,"t"																					# privilege extensions: "t","w","o","r","m","u" kan bruges
$ext=@($Mgp.Extension -split(","))


#$sqlCrLogin="j"
# Domain names for index
#$EgoAd="ssi.ad","sst.dk","dksund.dk","dksundtest.dk","intdmz.dk","pubdmz.dk","imkit.dk","nsidsdn.dk","ssidmz01.local"
# Domain short names
#$EgoAds="ssi","sst","dks","dkt","dmz","dmz","dmz","nsi","dmz"
#$EgoSqlAd="ssi","sst","dksund","dksundtest","intdmz","pubdmz","imkit","nsidsdn","ssidmz01"
# Domain controllers
#$EgoAda ="SRV-AD-DC04.ssi.ad","dc01.sst.dk","S-AD-DC-01P.dksund.dk","s-ad-dc-01t.dksundtest.dk","idmzdc03.intdmz.dk","pdmzdc02.pubdmz.dk","S-IMKIT-DC-01P.IMKIT.DK","srv-ad-dc02.nsidsdn.dk","srv-ad-dmzdc02.ssidmz01.local"

# SQL DBA group
#$EgoAda="MSSQLServerAdms","MSSQLServerAdms","l-ORG-MSSQL-Sysadmin","MSSQLServerAdms","l-ORG-MSSQL-Sysadmin","l-ORG-MSSQL-Sysadmin","l-ORG-MSSQL-Sysadmin","l-ORG-MSSQL-Sysadmin","l-ORG-MSSQL-Sysadmin"
# location of MSSQL Groups
#$EgoAdP="'OU=Systemgroups,OU=MSSQL,OU=Groups,ou=SSI,DC=ssi,DC=AD'","'OU=MSSQL,OU=T2Groups,OU=Tier2,DC=sst,DC=dk'"
#$EgoAdP+="'OU=MSSQL,OU=T2Groups,OU=Tier2,DC=dksund,DC=dk'"
#$EgoAdP+="'OU=MSSQL,OU=T2Groups,OU=Tier2,DC=dksundtest,DC=dk'"
#$EgoAdP+="'OU=MSSQL,OU=T2Groups,OU=Tier2,DC=intdmz,DC=dk'"
#$EgoAdP+="'OU=MSSQL,OU=T2Groups,OU=Tier2,DC=pubdmz,DC=dk'"
#$EgoAdP+="'OU=MSSQL,OU=T2Groups,OU=Tier2,DC=imkit,DC=dk'"
#$EgoAdP+="'OU=MSSQL,OU=T2Groups,OU=Tier2,DC=nsidsddn,DC=dk'"
#$EgoAdP+="'OU=MSSQL,OU=T2Groups,OU=Tier2,DC=ssidmz01,DC=local'"

For ($i=0;$i -lt $EgoAd.count;$i++){
	If ($EgoAd[$i] -eq $ResDom) {$iR=$i}
	If ($EgoAd[$i] -eq $UserDom) {$iU=$i}
}

#$iR=[array]::indexof($EgoAd,$ResDom.ToLower() )
#$iU=[array]::indexof($EgoAd,$UserDom.ToLower() )
#$iK=[array]::indexof(@(" ","ssi.ad","dksund.dk","ssidmz01.local"),$ResDom.ToLower() )
#If ($iK -gt 0) {$domsql= $EgoSqlAd[$iR]}else{$domsql=$ResDom }
If($sqlinstans.length -lt 2) {$sqlinstans='MSSQLSERVER'} 

#$sqla=$EgoAda[$iR]
#$sqlp=$EgoAdP[$iR]
#$sqls=$EgoAds[$iR]

$scope="0","1"																							#Scope could be 0,1,2 for local, global & Universal groups.
If ($UserDom -ne $ResDom) {$scope +="2"}
$sqlLoginUser=@()

#If ($DBname.contains(",")) {
#	$DBname2=$DBname.split(",")
	$DBname1=$DBname[0]
#	$DBname=$DBname.replace(',',', ')
#} else {$DBname1=$DBname}

#$DBname1=$DBname1.trim()
#$domsql=$ResDom.split(".")[0]    # der er ikke brug for del domain
$domsql=$Global:EgoSqlAd[$iR]

$sdg=@()
$sdl=@()

$crnl='`r`n'
#$EgoDato = Get-Date -format yyyy-MM-dd
$notes="$EgoDato $mssqldba : $SDnr"
$BefulNotes="$crnl$EgoDato $mssqldba : [co-managers: $CoMan]"
$manager=" "
#function Get-ScriptDirectory
#{
#    Split-Path $script:MyInvocation.MyCommand.Path
#}

#Function Skriv-Fil {
#	param()
#$Sub="Skriv-Fil"
#	$PrtLin=[string]::join(' ', $args)
#	If($WrToFile -eq "0"){
#		write-Host $PrtLin
#	}else{
#	#write-Host $WrToFile
#		$PrtLin | Out-File -filepath $WrToFile -Append
#	}
#}

Function Skriv-Log {
	param()
$Sub="Skriv-Log"
	$PrtLog=[string]::join(' ', $args)
	If($WrToFile -eq "0"){
		write-Host $PrtLog
	}else{
		$PrtLog | Out-File -filepath $WrToLog -Append
	}
}

#Prepare logfile with AD commands.
#$WrToFile=Get-ScriptDirectory
#$WrToLog=$WrToFile+"\Total-MkGrp.log"
#$WrToFile+="\"+ ($MyInvocation.MyCommand.Name).split(".")[0] +".log"
#if (Test-Path $WrToFile) {Remove-Item $WrToFile}

Skriv-Log " "
$Iam=[System.Security.Principal.WindowsIdentity]::GetCurrent().Name
Skriv-Log "$EgoDato $Iam : Make_Group har klargjort grupper til følgende"
Skriv-Log "System = $System"
Skriv-Log "DBname = " $Mgp.DBname
Skriv-Log "DBLink = $DBLink"

Skriv-Log "ServiceDesk# = $SDnr"
Skriv-Log "Ressourceejer = " $Mgp.Manager
Skriv-Log "CoMan = $CoMan"
Skriv-Log "Sqlserver = $Sqlserver"
Skriv-Log "Sqlinstans = $sqlinstans"
Skriv-Log "mssqldba = $mssqldba"
Skriv-Log "ResDom = $ResDom"
Skriv-Log "UserDom = $UserDom"
Skriv-Log "Skemaer = " $Mgp.Schemas
Skriv-Log "Extensions = " $Mgp.Extension
Skriv-Log "Beskr = " $Mgp.Beskr
Skriv-Log "SuppGrp = " $Mgp.SuppGrp
Skriv-Log "Gdpr = " $Mgp.Gdpr
	
$global:EgoSrcDC=$EgoDC[$IR]
If(Is-AdUser $Mgp.Manager){
	$mr=Hent-AdUser $Mgp.Manager
#	$manager=" -ManagedBy '"
#	$manager+=$mr.distinguishedname
	$manager=$mr.distinguishedname
#	$manager+="'"
}else{Write-Host "Opret sag til servicedesk at bruger: $Manager skal oprettes som disablet bruger i domænet: $ResDom"
	$manager=""
}
$ml=Hent-AdGroup $EgoAda[$iR]
#$ml=$a.distinguishedname
#$managerLocalgrp=" -ManagedBy '"
#$managerLocalgrp+=$ml.distinguishedname
$managerLocalgrp=$ml.distinguishedname
#$managerLocalgrp+="'"
$EgoSrcDC=$EgoDC[$IU]
#$gm=$Mgp.Manager
#$gdMan=Get-ADUser -LDAPFilter "(SAMAccountName=$gm)" -server $EgoSrcDC
#				If(($gdMan.DistinguishedName).length -gt 0){ 
#					$glm=$gdMan.DistinguishedName
#}
#$glm
#$EgoSrcDC
#Hent-AdUser $Mgp.Manager
If(Is-AdUser $Mgp.Manager){
	$mu=Hent-AdUser $Mgp.Manager
#	$Mgp.Manager
#	$IU
#	$mu|fl
#	$managerU=" -ManagedBy '"
#	$managerU+=$mu.distinguishedname
	$managerU=$mu.distinguishedname
#	$managerU+="'"
}else{Write-Host "Opret sag til servicedesk at bruger: $Mgp.Manager skal oprettes som disablet bruger i domænet: $UserDom"
	$managerU=""
}
#exit


$sn=0

$Schemas=@($Mgp.Schemas -split(","))

do {
	If($sn -gt 0){
		$Schema=$Schemas[$sn-1]
		#$sch0=$Schema.Replace("_","")
		If($Schema.length -lt 1){Break}
	
	}else{$Schema=""}
	foreach($e in $ext){
		If($sn -gt 0 -and $e -eq "o"){Break}
		Switch ($e) {
			'r'		{$ee='db_datareader'}
			'w'	{$ee='db_datareader & writer'}
			'd'		{$ee='ddladmin, execute, db_datareader & writer, dataadministrativ adgang, dvs. adgang til at definere datastrukturer (oprette tabeller, mv.), samt adgangsforhold på datastrukturer'}
			'o'		{$ee='db_owner'}
			'm'	{$ee='Betroet Maskeløs adgang til beskyttede oplysninger/tilladelse til at UNMASKe data. Dette er en komplimentær adgang; konto ?skal stadig tildeles r eller w'}
			't'		{$ee='ddladmin, execute, db_datareader & writer'}
			'u'		{$ee='service-brugeradgang, dvs. adgang til at anvende et system eller en service'}
		}
		$Dc="Brugere med $ee rolle mod DataBase: "+$Mgp.DBname
		If($Schema.length -gt 0){
			$Dc+=" Schema: "
			#$Dc+=$Schema.replace("_","")
		}
		If ($Sqlserver.length -gt 1){$Dc+=" på $Sqlserver"}
		If ($sqlinstans.length -gt 1){$Dc+="\$sqlinstans"}

		foreach($s in $scope){				#først lokalgrupperne: 
			if ($s -eq "0") {
				$Desc="""Ressourcetilknytning for $Dc"""
				$c="l"								#lokalgruppe
				$sqls=$EgoAds[$iR]
				$sqlp=$EgoAdP[$iR]
				$EgoSrcDC=$EgoDC[$IR]
				$n=$Notes
				$n+=" Ressourcetilknytning for $Dc "
				$n+=$crnl
				$n+="Meld_IKKE_brugere_ind_i_lokal_gruppen_BRUG_Global_gruppen!"
				$m=$managerLocalgrp
				$Scop="DomainLocal"
			} elseif ($s -eq "1") {
				$Desc="""$Dc"""
				$c="g"								#globalgruppe
				$sqls=$EgoAds[$iR]
				$sqlp=$EgoAdP[$iR]
				$EgoSrcDC=$EgoDC[$IR]
				$n=$Notes
				$n+=" Privilegie gruppe for $Dc"
				If ($CoMan.length -gt 1){$n+=$BefulNotes}
				$m=$manager
				$Scop="Global"
			} else {
				$Desc=$Dc
				$c="g"								#globalgruppe Dksund
				$sqls=$EgoAds[$iU]
				$sqlp=$EgoAdP[$iU]
				$EgoSrcDC=$EgoDC[$IU]
				$n=$Notes
				$n+=" Privilegie gruppe for $Dc"
				If ($CoMan.length -gt 1){$n+=$BefulNotes}
				$m=$managerU
				$Scop="Global"
			}
		$g="$system¤$c¤$sqls¤$DBLink¤$Schema¤$e" -replace("¤","_")
		$g=$g -replace("__","_")

#			$NewParm = @{

			$NewParm = [ordered]@{
				Name        = $g
				samaccountname  = $g
				groupscope   = "$Scop"
				Path  ="""$sqlp"""
				Description = $Desc 
				GroupCategory = "Security"
				Server = $EgoSrcDC
				OtherAttributes = @{info="$n"}
			}
			If ($m.length -gt 0){$NewParm.Add('ManagedBy', $m)}#Else{$NewParm.Remove('ManagedBy')}

# Add-DhcpServerv4Scope @NewParm



			If(Is-AdGroup $g){
				$w="#Gruppe findes allerede#  NEW-ADGroup $g" #$NewParm  
				Skriv-Fil $w
			}Else{
			
				$w="NEW-ADGroup"
				$NewParm.OtherAttributes = '@{info="'+$n+'"}'
#				$NewParm.Path="'"+$NewParm.Path+"'"
				foreach($key in $NewParm.keys){
					If ($key -eq "OtherAttributes") {$w+= ' -{0} {1}' -f $key,'@{info="'+$n+'"}'}
					ElseIf ($NewParm[$key] -match('"')) {$w+= ' -{0} {1}' -f $key,$NewParm[$key]}
					#ElseIf ($key -in ("name","samaccountname")) {$w+= ' -{0} {1}' -f $key,$NewParm[$key]}
					Else {$w+= ' -{0} "{1}"' -f $key, $NewParm[$key] }
				}
			
#			$w="NEW-ADGroup –name $g -samaccountname $g –groupscope $s –path $sqlp -Description $Desc $m -GroupCategory 1 -OtherAttributes @{info=""$n""}"
				If ($Mgp.Exec){
				Try{
					NEW-ADGroup @NewParm -ErrorAction Stop
					Invoke-Expression $w
				}Catch{
					Write-Host ([PSCustomObject]$NewParm)
					$_
				}
					
					write-Host "Ny Gruppe $g oprettet : " $rc
				}
				
				Skriv-Fil $w
				Skriv-Log $w
			}
			if ($s -eq "0") {
				$glg=$g
				$sqlLoginUser+="Use [Master];"
				$sqlLoginUser+="CREATE LOGIN [$domsql\$g] FROM WINDOWS WITH DEFAULT_DATABASE=[$DBname1];"
				foreach($DBname3 in $DBname){
					$DBname3=$DBname3.trim()
					$sqlLoginUser+="Use [$DBname3];"
					If($Schema.length -gt 0){
						$sqlLoginUser+="CREATE USER [$domsql\$g] FOR LOGIN [$domsql\$g] With default_schema = $Schema;"
						Switch ($e) {
							"u"	{$sqlLoginUser+="GRANT EXECUTE ON SCHEMA::[$Schema] TO [$domsql\$g];"}
							"r"	{$sqlLoginUser+="GRANT SELECT ON SCHEMA::[$Schema] TO [$domsql\$g];"}
							"w"	{$sqlLoginUser+="GRANT SELECT ON SCHEMA::[$Schema] TO [$domsql\$g];"
								$sqlLoginUser+="GRANT INSERT  ON SCHEMA::[$Schema] TO [$domsql\$g];"
								$sqlLoginUser+="GRANT UPDATE  ON SCHEMA::[$Schema] TO [$domsql\$g];"
								$sqlLoginUser+="GRANT DELETE  ON SCHEMA::[$Schema] TO [$domsql\$g];"
								} 
							{$_ -in "d","t","l"}	{$sqlLoginUser+="GRANT SELECT ON SCHEMA::[$Schema] TO [$domsql\$g];"
								$sqlLoginUser+="GRANT INSERT  ON SCHEMA::[$Schema] TO [$domsql\$g];"
								$sqlLoginUser+="GRANT UPDATE  ON SCHEMA::[$Schema] TO [$domsql\$g];"
								$sqlLoginUser+="GRANT DELETE  ON SCHEMA::[$Schema] TO [$domsql\$g];"
								$sqlLoginUser+="GRANT EXECUTE ON SCHEMA::[$Schema] TO [$domsql\$g];"
								$sqlLoginUser+="GRANT VIEW DEFINITION ON SCHEMA::[$Schema] TO [$domsql\$g];"
								}
						}
					}else{
						$sqlLoginUser+="CREATE USER [$domsql\$g] FOR LOGIN [$domsql\$g] With default_schema = dbo;"
						If ($e -eq "o") {
							$sqlLoginUser+="ALTER ROLE [db_owner] ADD MEMBER [$domsql\$g];"
							#$sqlLoginUser+="EXEC sp_addrolemember N'db_owner', N'$domsql\$g';"
						}else {  #($e -eq "r")
							$sqlLoginUser+="ALTER ROLE [db_datareader] ADD MEMBER [$domsql\$g];"
							#$sqlLoginUser+="EXEC sp_addrolemember N'db_datareader', N'$domsql\$g';"
							If ($e -eq "w") {
								$sqlLoginUser+="ALTER ROLE [db_datawriter] ADD MEMBER [$domsql\$g];"
								#$sqlLoginUser+="EXEC sp_addrolemember N'db_datawriter', N'$domsql\$g';"
							}
							If ($e -in "d","l","t") {
								$sqlLoginUser+="ALTER ROLE [db_datawriter] ADD MEMBER [$domsql\$g];"
								#$sqlLoginUser+="EXEC sp_addrolemember N'db_datawriter', N'$domsql\$g';"
								$sqlLoginUser+="ALTER ROLE [db_ddladmin] ADD MEMBER [$domsql\$g];"
								#$sqlLoginUser+="EXEC sp_addrolemember N'db_ddladmin', N'$domsql\$g';"
								$sqlLoginUser+="Grant EXEC to [$domsql\$g];"
							}
						}			
					}
				}
				$priv="$domsql\$g   ($ee)"
				#If ($e -eq "r") {$priv="$domsql\$g   (læse-privilegie)"}
				#If ($e -eq "w") {$priv="$domsql\$g   (Skriv&læse privilegie)"}
				#If ($e -eq "d") {$priv="$domsql\$g   (dataadministrativ adgang: Execute,ddladmin,skriv&læse privilegie)"}
				#If ($e -eq "o") {$priv="$domsql\$g   (dbo privilegie)"}
				#If ($e -eq "t") {$priv="$domsql\$g   (Udvikler: Execute,ddladmin,skriv&læse privilegie)"}
				#If ($e -eq "l") {$priv="$domsql\$g   (Udvikler: Execute,ddladmin,skriv&læse privilegie)"}
				#If ($e -eq "m") {$priv="$domsql\$g   (Betroet: tilladelse til at UNMASKe data)"}
				$sdl+=$priv
			}Elseif ($s -eq "1") {
				$sdg+="$ResDom\$g"
				If ($Mgp.Exec){
				
					$rc=Add-ADGroupMember -identity $glg -members $g -server $EgoSrcDC
					write-Host "Gruppe $g meldt ind i gruppe $glg : " $rc
				}
				$w= "Add-ADGroupMember -identity $glg -members $g -server $EgoSrcDC"
				Skriv-Fil $w
				Skriv-Log $w
			}Elseif ($s -eq "2") {
				$sdg+="$UserDom\$g"
				If ($Mgp.Exec){
					$addgrp=get-adgroup $g -server $EgoDC[$IU] 
					$rc=Add-ADGroupMember -identity $glg -members $addgrp -server $EgoDC[$IR]
					write-Host "Dks-Gruppe $addgrp meldt ind i gruppe $glg : " $rc
				}
				$w="¤addgrp=get-adgroup $g -server "+ $EgoDC[$IU] 
				$w=$w -replace("¤","$")
				Skriv-Fil $w
				Skriv-Log $w
				$w= "Add-ADGroupMember -identity $glg -members ¤addgrp -server "+$EgoDC[$IR]
				$w=$w -replace("¤","$")
				Skriv-Fil $w
				Skriv-Log $w
			}Else{
				$sdg+="$UserDom\$g"
			}
		}
#	$EgoSrcDC=$EgoDC[$IR]
#	if ($s -gt "1") {
#		$w= "Add-ADGroupMember -identity $glg -members $gug -server $EgoSrcDC"
#		Skriv-Fil $w
#		Skriv-Log $w
#		$EgoSrcDC=$EgoDC[$IU]
#	}
		
#	$w= "Add-ADGroupMember -identity $glg -members $g -server $EgoSrcDC"
#	Skriv-Fil $w
#	Skriv-Log $w
	}

# Add-ADGroupMember -identity Epimiba_l_Epimiba06_w -members Epimiba_g_Epimiba06_w
	$sn++
} while($sn -le $Schemas.count)




If ($sqlLoginUser.length -gt 1) { 
	Skriv-Fil
	$w= "-- Kopier T-SQL til MS SQL Server Management Studio forbundet til $Sqlserver"; Skriv-Fil $w; Skriv-Log $w
	foreach($DBname3 in $DBname){
		$w= "Use Master;"; Skriv-Fil $w; Skriv-Log $w
		$w= "CREATE DATABASE [$DBname3]"; Skriv-Fil $w; Skriv-Log $w
		$w= "Go"; Skriv-Fil $w; Skriv-Log $w
		$w= "EXEC [$DBname3].sys.sp_addextendedproperty @name=N'Db_BS', @value=N'{0}'" -f $Mgp.System; Skriv-Fil $w; Skriv-Log $w
		$w= "Go"; Skriv-Fil $w; Skriv-Log $w
		$w= "EXEC [$DBname3].sys.sp_addextendedproperty @name=N'Db_Ejer', @value=N'{0}'" -f $Mgp.Manager; Skriv-Fil $w; Skriv-Log $w
		$w= "Go"; Skriv-Fil $w; Skriv-Log $w
		$w= "EXEC [$DBname3].sys.sp_addextendedproperty @name=N'Db_gdpr', @value=N'{0}'" -f $Mgp.gdpr; Skriv-Fil $w; Skriv-Log $w
		$w= "Go"; Skriv-Fil $w; Skriv-Log $w
		$w= "EXEC [$DBname3].sys.sp_addextendedproperty @name=N'Db_SuppGrp', @value=N'{0}'" -f $Mgp.SuppGrp; Skriv-Fil $w; Skriv-Log $w
		$w= "Go"; Skriv-Fil $w; Skriv-Log $w
		$w= "EXEC [$DBname3].sys.sp_addextendedproperty @name=N'Db_Beskr', @value=N'{0}'" -f $Mgp.Beskr; Skriv-Fil $w; Skriv-Log $w
		$w= "Go"; Skriv-Fil $w; Skriv-Log $w
		foreach($Schema in $Schemas){
			If($Schema.length -gt 0){
				$w= "Use $DBname3;"; Skriv-Fil $w; Skriv-Log $w
				$w= "Go"; Skriv-Fil $w; Skriv-Log $w
				$w="CREATE SCHEMA [$Schema] AUTHORIZATION [dbo]"; Skriv-Fil $w; Skriv-Log $w
				$w= "Go"; Skriv-Fil $w; Skriv-Log $w
			}
		}
	}
	Skriv-Fil
	foreach ($g in $sqlLoginUser){
		$w= $g 
		Skriv-Fil $w
		Skriv-Log $w
	}
	Skriv-Fil	
	Skriv-Fil
	if($mgp.system -eq "mtime"){
		$w= "-- if mTime?"; Skriv-Fil $w
		$w= "Use [$DBname3]"; Skriv-Fil $w
		$w= "GO"; Skriv-Fil $w
		$w= "CREATE USER [a_mtime] FOR LOGIN [a_mtime]"; Skriv-Fil $w
		$w= "GO"; Skriv-Fil $w
		$w= "ALTER ROLE [db_owner] ADD MEMBER [a_mtime]"; Skriv-Fil $w
		$w= "GO"; Skriv-Fil $w
	}
	Skriv-Fil
	$w= "-- Udfør på SQL Server: $Sqlserver i Powershell (administrator)"; Skriv-Fil $w
	$w= "\\TSCLIENT\S\mssql\Tsm-FullDbBk.ps1 -Database {0}" -f $dbname -join(",")
	Skriv-Fil $w
	Skriv-Fil	
	Skriv-Fil
	$w= "-- Udfør i Check_MK (master): Vælg SQL Server: $Sqlserver"; Skriv-Fil $w
	$w= "-- Udfør i Check_MK (master): Vælg Wato"; Skriv-Fil $w
	$w= "-- Udfør i Check_MK (master): Vælg Services"; Skriv-Fil $w
	$w= "-- Udfør i Check_MK (master): Vælg Full Scan"; Skriv-Fil $w
	$w= "-- Udfør i Check_MK (master): Vælg Tabula Resa"; Skriv-Fil $w
	$w= "-- Udfør i Check_MK (master): Vælg 2 Changes"; Skriv-Fil $w
	$w= "-- Udfør i Check_MK (master): Vælg Continue"; Skriv-Fil $w
	$w= "Skulle gerne fjerne Check_MK fejl med Unknown på den nye Database {0}" -f $dbname -join(",")
	Skriv-Fil $w
	Skriv-Fil	
	Skriv-Fil
	$w= "-- Udfør i ServiceNow Forside ( https://sds.service-now.com/serviceportal ) Foretag Bestilling  
	-  Tilføj CI til Business Service  -  BS: {0} CI: {1}" -f $Mgp.System,$Mgp.DBname; Skriv-Fil $w
	Skriv-Fil	
	Skriv-Fil
	$w= "-- Rediger & Kopier til servicedesk sag"; Skriv-Fil $w; Skriv-Log $w
	$w= "Jeg har oprettet database: {0}" -f $dbname -join(",")
	Skriv-Fil $w; Skriv-Log $w
	$w= "på SQL Server: $Sqlserver\$sqlinstans"; Skriv-Fil $w; Skriv-Log $w
	foreach($Schema in $Schemas){
		If($Schema.length -gt 0){
			$w= "Jeg har oprettet Schema: $DBname3;"; Skriv-Fil $w; Skriv-Log $w
		}
	}	
	Skriv-Fil
	$w= "Jeg har oprettet Globalbruger-grupperne"; Skriv-Fil $w; Skriv-Log $w
	foreach ($g in $sdg){
		$w= $g 
		Skriv-Fil $w
		Skriv-Log $w
		If ($g.substring($g.length-2,2) -eq "_o"){$go=$g}
	}
	Skriv-Fil
	$w= "Disse er forbundet med de tilsvarende Lokalressouceprivilegiegrupper: "; Skriv-Fil $w; Skriv-Log $w
	foreach ($g in $sdl){
		$w= $g 
		Skriv-Fil $w
		Skriv-Log $w
	}
	$w= "der igen tildeler ressourcer på database: {0}" -f $dbname -join(","); Skriv-Fil $w; Skriv-Log $w
	$w= "på SQL Server: $Sqlserver\$sqlinstans"; Skriv-Fil $w; Skriv-Log $w
	Skriv-Fil
	if($mgp.system -eq "mtime"){
		$w= "Brugeren: a_mtime har fået de normale privilegier på databasen!";Skriv-Fil $w; Skriv-Log $w
		Skriv-Fil $w; Skriv-Log $w
	}
	$w= "$CoMan er befuldmægtigede til at oprette ServiceNow sager med ønske om brugere der skal meldes ind i _G_ grupperne (eller ud af). "; Skriv-Fil $w; Skriv-Log $w
	Skriv-Fil
	$w= "$Manager kan når som helst oprette SD sager til brugeradministrationen, om at andre ligeledes skal være befuldmægtiget til at håndtere ovennævnte grupper. "; Skriv-Fil $w; Skriv-Log $w
	$w= "Brugerne : {0} er meldt ind i  _o  -gruppen {1}" -f ($CoMan  -Replace(",",";")),$g
	Skriv-Fil $w; Skriv-Log $w
	$w= "Privilegierne opnås efter næste logoff & logon (Disconnect virker ikke)" 
	Skriv-Fil $w; Skriv-Log $w
	$w= "Sag løst og lukket" 
	Skriv-Fil $w; Skriv-Log $w
	$w= "mvh. $mssqldba" 
	Skriv-Fil $w; Skriv-Log $w
	Skriv-Fil
	$w= "Add-ADGroupMember -Identity {1} -Members {0}" -f $CoMan,(($g.split("\("))[1] -replace("_l_","_g_"))
	Skriv-Fil $w; Skriv-Log $w
	
}


if (Test-Path $WrToFile) {notepad $WrToFile}

}



# SIG # Begin signature block
# MIIdAgYJKoZIhvcNAQcCoIIc8zCCHO8CAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCC/QUv40vSyoqMn
# gvkcdrhKeoNkb+zZIDBdLTYCSPnBUqCCGBMwggT+MIID5qADAgECAhANQkrgvjqI
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
# MAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEIG2A1n4btEmZrNInyv8BJcrF
# J9xNYMD5pD6vCpfH/OhYMA0GCSqGSIb3DQEBAQUABIIBAI7E8pT7tQaRnXdt49DB
# OkfMWDlQR0Sr5Av/qmIg5GFWgsL23egxm4MDsuT8tw7oMvNUHbGmItc/FRKIDOnG
# 0XiDj0SGD/OwhRIk3Igka/9WKLHgiX6RGuZUTQnu3HBmt2gBygu+sgvLRoFzgUdy
# rS9RIBNvPKTxEXYdvhv5oqoGGk8q3Qm6ZpkEUdTJuhTwKC0/3RCLK+BYbESRN5RY
# GVyw4ArvbuZfBG248EgReLSPiIZ+Xq4W/hmNsZIA35nBOou1P6B1HS4uWfCfDUVY
# YARp5hu8gyAK3mQsltteRkji+XgJ/oJigiWJtn8z/tyBzfN7pClE51NymtFa6yTF
# zDqhggIwMIICLAYJKoZIhvcNAQkGMYICHTCCAhkCAQEwgYYwcjELMAkGA1UEBhMC
# VVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQd3d3LmRpZ2ljZXJ0
# LmNvbTExMC8GA1UEAxMoRGlnaUNlcnQgU0hBMiBBc3N1cmVkIElEIFRpbWVzdGFt
# cGluZyBDQQIQDUJK4L46iP9gQCHOFADw3TANBglghkgBZQMEAgEFAKBpMBgGCSqG
# SIb3DQEJAzELBgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTIxMTIwMTEzMjY1
# NVowLwYJKoZIhvcNAQkEMSIEIIwrgmnBw/SWCIa0sKmW0A/G1Z+P5Btcil9o/RXh
# HoBEMA0GCSqGSIb3DQEBAQUABIIBAAPc9QZ2iNdgFVry3Sz7lXj92IYlxyv9Xjng
# B2+/8ipCHDCBTvVQK+rUVyvcsNb4+aMw8YCmg/RSSjcOO9QZnsyfFEEHEpss12D+
# 8wTM0BUytC5nKAchJpfq+dDcP95oIyM+zWt5yA7j69Lv/9qQR7nXTEUKyO6Fke19
# j131DYT3gzHmjWNKM6amzSVBAyHWsInxdiINuEciPpi93FU5wYwl3S+w7Pvz2kZ0
# XVNIgAbzHhRsZVzYRGp31NzeV2ZdRqFxWjBRYaYdDDmBPxG6stsyNbRtJUzIxNNl
# wGC8FH7QSMOlWsshUUfFvWmagUHXmZJElAGNNMvmUH8/iewVaog=
# SIG # End signature block
