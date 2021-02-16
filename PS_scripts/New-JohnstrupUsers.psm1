﻿function Get-WpfUserInput {

    [CmdletBinding()]
    Param
    (
        # Message for textbox
        [Parameter(Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 0)]
        $Message
    )

    Add-Type -AssemblyName PresentationFramework, System.Windows.Forms, WindowsFormsIntegration

    [xml][string]$XAML_ConnectDialog = @"
    <Window Name="Form_ConnectDialog"
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="User indput" Height="250" Width="428" ResizeMode="NoResize" ShowInTaskbar="True" FocusManager.FocusedElement="{Binding ElementName=Txt_ConnectDialog_Input}">
        <Grid>
            <TextBlock FontSize="14" TextWrapping="Wrap" Text="$message" Margin="10,0,10,91"/>
            <Label FontSize="16" Content="Enter password:" HorizontalAlignment="Left" Height="35" VerticalAlignment="Top" Width="156" Margin="10,45,0,0"/>
            <Label FontSize="16" Content="Re-enter password:" HorizontalAlignment="Left" Height="35" VerticalAlignment="Top" Width="156" Margin="10,80,0,0"/>
            <Button Name="Btn_ConnectDialog_Connect"  HorizontalAlignment="center" Content="OK" Height="35" Width="100" Margin="50,88,26,20" IsDefault="True"/>
            <PasswordBox x:Name="Txt_ConnectDialog_Input" HorizontalAlignment="Left" Height="23" Margin="171,51,0,0" VerticalAlignment="Top" Width="208" />
            <PasswordBox x:Name="Txt_ConnectDialog_Input_control" HorizontalAlignment="Left" Height="23" Margin="171,87,0,0" VerticalAlignment="Top" Width="208" />
        </Grid>
    </Window>
"@
    [xml][string]$XAML_ConnectDialogPasswordmismatch = @"
    <Window Name="Form_ConnectDialog"
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="User indput" Height="250" Width="428" ResizeMode="NoResize" ShowInTaskbar="True" FocusManager.FocusedElement="{Binding ElementName=Txt_ConnectDialog_Input}">
        <Grid>
            <TextBlock FontSize="14" TextWrapping="Wrap" Text="$message" Margin="10,0,10,91"/>
            <Label FontSize="16" Content="Enter password:" HorizontalAlignment="Left" Height="35" VerticalAlignment="Top" Width="156" Margin="10,45,0,0"/>
            <Label FontSize="16" Content="Re-enter password:" HorizontalAlignment="Left" Height="35" VerticalAlignment="Top" Width="156" Margin="10,80,0,0"/>
            <Label FontSize="16" Content="password mismatch" HorizontalAlignment="center" Height="35" VerticalAlignment="Top" Width="156" Margin="50,108,26,20"/>
            <Button Name="Btn_ConnectDialog_Connect"  HorizontalAlignment="center" Content="OK" Height="35" Width="100" Margin="50,108,26,20" IsDefault="True"/>
            <PasswordBox x:Name="Txt_ConnectDialog_Input" HorizontalAlignment="Left" Height="23" Margin="171,51,0,0" VerticalAlignment="Top" Width="208" />
            <PasswordBox x:Name="Txt_ConnectDialog_Input_control" HorizontalAlignment="Left" Height="23" Margin="171,87,0,0" VerticalAlignment="Top" Width="208" />
        </Grid>
    </Window>
"@
    $i = 0
    do {
        if ($i -gt 0) {
            $XML_Node_Reader_ConnectDialog = (New-Object System.Xml.XmlNodeReader $XAML_ConnectDialogPasswordmismatch)
        }
        else {
            $XML_Node_Reader_ConnectDialog = (New-Object System.Xml.XmlNodeReader $XAML_ConnectDialog)
        }
        #$XML_Node_Reader_ConnectDialog = (New-Object System.Xml.XmlNodeReader $XAML_ConnectDialog)
        $ConnectDialog = [Windows.Markup.XamlReader]::Load($XML_Node_Reader_ConnectDialog)
        $Btn_ConnectDialog_Connect = $ConnectDialog.FindName('Btn_ConnectDialog_Connect')
        $Txt_ConnectDialog_Input = $ConnectDialog.FindName('Txt_ConnectDialog_Input')
        $Txt_ConnectDialog_Input_control = $ConnectDialog.FindName('Txt_ConnectDialog_Input_control')

        $Btn_ConnectDialog_Connect.Add_Click( {
                $ConnectDialog.Close()
            })

        $ConnectDialog.Add_Closing( { [System.Windows.Forms.Application]::Exit() }) # {$form.Close()}

        # add keyboard indput
        [System.Windows.Forms.Integration.ElementHost]::EnableModelessKeyboardInterop($ConnectDialog)

        # Running this without $appContext and ::Run would actually cause a really poor response.
        $ConnectDialog.Show()

        # This makes it pop up
        $ConnectDialog.Activate() | Out-Null
        #run the form ConnectDialog
        $appContext = New-Object System.Windows.Forms.ApplicationContext
        [System.Windows.Forms.Application]::Run($appContext)

        $UserName = "sa"
        $top = New-Object System.Management.Automation.PSCredential `
            -ArgumentList $UserName, $Txt_ConnectDialog_Input.SecurePassword

        $UserName = "sa"
        $bottom = New-Object System.Management.Automation.PSCredential `
            -ArgumentList $UserName, $Txt_ConnectDialog_Input_control.SecurePassword
        $i++
    }
    while (($top.GetNetworkCredential().Password) -cne ($bottom.GetNetworkCredential().Password))
    $output = $Txt_ConnectDialog_Input.SecurePassword
    Write-Output $output
}
function Read-HostWithPrompt {
    # thsi is from powershellcookbook by lee holmes
    param(
        ## The caption for the prompt
        $Caption = $null,

        ## The message to display in the prompt
        $Message = $null,

        ## Options to provide in the prompt
        [Parameter(Mandatory = $true)]
        $Option,

        ## Any help text to provide
        $HelpText = $null,

        ## The default choice
        $Default = 0
    )

    Set-StrictMode -Version 3

    ## Create the list of choices
    $choices = New-Object `
        Collections.ObjectModel.Collection[Management.Automation.Host.ChoiceDescription]

    ## Go through each of the options, and add them to the choice collection
    for ($counter = 0; $counter -lt $option.Length; $counter++) {
        $choice = New-Object Management.Automation.Host.ChoiceDescription `
            $option[$counter]

        if ($helpText -and $helpText[$counter]) {
            $choice.HelpMessage = $helpText[$counter]
        }

        $choices.Add($choice)
    }

    ## Prompt for the choice, returning the item the user selected
    $host.UI.PromptForChoice($caption, $message, $choices, $default)
    <#
    $HostWithPromptprop = @{option = "&0C:\Program Files\Microsoft SQL Server\MSSQL11.WINKOMPAS2012\MSSQL\Binn\sqlservr.exe","&1C:\Program Files\Microsoft SQL Server\MSSQL11.WINKOMPAS2012_1\MSSQL\Binn\sqlservr.exe","&2C:\Program Files\Microsoft SQL Server\MSSQL11.WINKOMPAS2012_2\MSSQL\Binn\sqlservr.exe"
                        helpText = "C:\Program Files\Microsoft SQL Server\MSSQL11.WINKOMPAS2012\MSSQL\Binn\sqlservr.exe","C:\Program Files\Microsoft SQL Server\MSSQL11.WINKOMPAS2012_1\MSSQL\Binn\sqlservr.exe","C:\Program Files\Microsoft SQL Server\MSSQL11.WINKOMPAS2012_2\MSSQL\Binn\sqlservr.exe"
                        caption = "More than one apllication found in search for application exe. Please choose"
                        message = "Please choose a file"
                        default = 0

    $HostWithPrompt = New-Object psobject -Property $$HostWithPromptprop
    #>
}
<#
Long description
.EXAMPLE
Example of how to use this cmdlet
.EXAMPLE
Another example of how to use this cmdlet
.INPUTS
Inputs to this cmdlet (if any)
.OUTPUTS
Output from this cmdlet (if any)
.NOTES
General notes
.COMPONENT
The component this cmdlet belongs to
.ROLE
The role this cmdlet belongs to
.FUNCTIONALITY
The functionality that best describes this cmdlet
#>
function New-JohnstrupUsers {
    [CmdletBinding()]
    [OutputType([Microsoft.ActiveDirectory.Management.ADAccount])]
    Param
    (
        # User to get group membership from
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $false,
            ValueFromPipelineByPropertyName = $true,
            Position = 0,
            ParameterSetName = 'Parameter Set 1')]
        #[ValidateSet("kope1", "kope2")]
        [kope]$Kope,

        # Responsible for the created user. Added to user description.
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $false,
            Position = 1,
            ValueFromPipelineByPropertyName = $true,
            ParameterSetName = 'Parameter Set 1')]
        [kontakansvarlig]$Kontakansvarlig,

        # Case ID
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $false,
            Position = 1,
            ValueFromPipelineByPropertyName = $true,
            ParameterSetName = 'Parameter Set 1')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [string]$CaseID,        

        # Company
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $false,
            Position = 2,
            ValueFromPipelineByPropertyName = $true,
            ParameterSetName = 'Parameter Set 1')]
        #[ValidateSet("Hjemmeværnet", "Moment", "Politiet")]
        [company]$Company,

        # Complete path to file.
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $false,
            Position = 3,
            ValueFromPipelineByPropertyName = $true,
            ParameterSetName = 'Parameter Set 1')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [String]$FileName,

        # Complete path to file.
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $false,
            Position = 3,
            ValueFromPipelineByPropertyName = $true,
            ParameterSetName = 'Parameter Set 1')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [DateTime]$AccountExpirationDate
    )

    Begin {
    }
    Process {
        ## End userdefinded values
        ## ikke pille længere nede. :)

        $Office = "STPS"
        $Title = "Ekstern konsulent"
        $UserParentOUDistinguishedName = "OU=Eksterne,OU=Organisationer,DC=dksund,DC=dk"
        # $server = "S-AD-DC-03P.dksund.dk"
        Remove-Variable SecurityGroups -ErrorAction SilentlyContinue
        $SecurityGroups = (Get-ADUser -Identity $($Kope.ToString()) -Properties MemberOf).MemberOf # -Server $server
        $UserPrincipalNamedomain = "@dksund.dk"
        # $UserNameOfRunner = $env:USERNAME -replace 'adm_', '' -replace 'adm-', ''
        # $FilePathDownloads = "C:\Users\$UserNameOfRunner\Downloads\"
        # $FilePath = "$FilePathDownloads" + "$FileName"
        Remove-Variable FilePath -ErrorAction SilentlyContinue
        $FilePath = "$FileName"

        if ( -not (Test-Path -Path $FilePath)) {

            write-warning "Jeg kan ikke finde den fil du har angivet."
            Pause
            Return
        }

        if (-not $Password) {
            $Password = Get-WpfUserInput -Message 'skriv koden du vil have på brugerne'
        }
        #$password = Read-Host -AsSecureString -Prompt 'indtast kode til brugeren'

        $Excel = New-Object -comobject Excel.Application

        #open file
        Remove-Variable Workbook -ErrorAction SilentlyContinue
        Remove-Variable s1 -ErrorAction SilentlyContinue
        $Workbook = $Excel.Workbooks.Open($FilePath)
        $s1 = $Workbook.sheets | Where-Object -FilterScript { $_.name -eq 'Ark1' }

        $iExcelTestLenght = 0

        do {
            Remove-Variable MANumrer -ErrorAction SilentlyContinue
            $iExcelTestLenght++
            $MANumrer = $s1.range("D$iExcelTestLenght").cells.text
        }
        until (-not $MANumrer)

        $ExcelSelctor = for ($iExcel = 2; $iExcel -lt $iExcelTestLenght; $iExcel++ ) {
            # starts at 2, because first line vallues contain userinformation in excel

            Write-Output $iExcel
        }
        # $number = 2

        # Skip test for only numbers in colum D. it doesn't apply to ATP
        if ($Company -ne 'ATP') {
            
            foreach ($Number in $ExcelSelctor ) {
        
                try {
                    $MANumrerIntTest = $s1.range("D$number").cells.text
                    [int]$MANumrerIntTestClean = $MANumrerIntTest.Trim() 
                }
                catch {
                    Write-Host -ForegroundColor Yellow "Der er andet end tal i MA Numrer {$($MANumrerIntTest.Trim())}. Du havde vist ikke lavet ordenlig kontrol"
                    $Excel.Quit()
                    Pause
                    Return
                }        
            }
        }

        #[int]$ExcelSelctorProgressCounter = 0

        $UserCreationOutput = foreach ($Number in $ExcelSelctor) {
            
            #[int]$ExcelSelctorProgressCounter++
            Write-Progress -Activity "Creating Users" -Status "$($ExcelSelctor.IndexOf($Number)) af $($ExcelSelctor.count)"  -PercentComplete ($($ExcelSelctor.IndexOf($Number))/$ExcelSelctor.count*100)
            
            Remove-Variable GivenNameClean -ErrorAction SilentlyContinue
            Remove-Variable SurnameClean -ErrorAction SilentlyContinue
            Remove-Variable MANumrerClean -ErrorAction SilentlyContinue
            Remove-Variable AccountName -ErrorAction SilentlyContinue
            Remove-Variable MobilePhoneCleanPlus45 -ErrorAction SilentlyContinue
            Remove-Variable EmailAddressClean -ErrorAction SilentlyContinue
            Remove-Variable name -ErrorAction SilentlyContinue
            Remove-Variable Displayname -ErrorAction SilentlyContinue
            Remove-Variable UserPrincipalName -ErrorAction SilentlyContinue
            Remove-Variable Description -ErrorAction SilentlyContinue
            Remove-Variable Hash -ErrorAction SilentlyContinue

            $GivenName = $s1.range("B$Number").cells.text
            $GivenNameClean = $GivenName.Trim()

            $Surname = $s1.range("C$number").cells.text
            $SurnameClean = $Surname.trim()

            $MANumrer = $s1.range("D$Number").cells.text
            $MANumrerClean = $MANumrer.Trim()

            $MANumrerCleanEKS_ = "EKS_" + "$MANumrerClean"
            $AccountName = $MANumrerCleanEKS_

            $MobilePhone = $s1.range("F$Number").cells.text
            $MobilePhoneClean = $MobilePhone.trim()
            $MobilePhoneCleanPlus45 = "+45" + "$MobilePhoneClean"

            $EmailAddress = $s1.range("E$number").cells.text
            $EmailAddressClean = $EmailAddress.trim()

            $name = "$GivenNameClean" + " " + "$SurnameClean" + " ($MANumrerCleanEKS_)"
            $Displayname = "$GivenNameClean" + " " + "$SurnameClean"

            $UserPrincipalName = "$MANumrerCleanEKS_" + "$UserPrincipalNamedomain"

            $Description = "Almindelig konto til ekstern konsulent, kontakt person $kontakansvarlig - $CaseID" # SALM LNGE NALH

            #hash table for splat New-ADUser
            $Hash = [ordered]@{
                Name                  = $name;
                SamAccountName        = $AccountName;
                Enabled               = $true;
                Path                  = $UserParentOUDistinguishedName;
                AccountPassword       = $password;
                ChangePasswordAtLogon = $True;
                GivenName             = $GivenNameClean;
                Surname               = $SurnameClean;
                DisplayName           = $Displayname;
                Description           = $Description;
                UserPrincipalName     = $UserPrincipalName;
                Office                = $Office;
                Company               = $Company;
                EmailAddress          = $EmailAddressClean;
                Title                 = $Title;
                AccountExpirationDate = $AccountExpirationDate;
                MobilePhone           = $MobilePhoneCleanPlus45
            }

            # only ask user to validate first user
            if ( -not $UserYesNoChoiceToDataValid) {

                Write-Host -ForegroundColor Yellow "Kig om det indlæste står i de korekte felter. Luk vinduet når du har kontrolleret det"
                Show-FirstUserOutputWPFForm -hash $Hash
            }

            if (-not $UserYesNoChoiceToDataValid) {
                
                Write-Host -ForegroundColor Yellow "kør scriptet igen, når du har rettet fejlen, du fandt i excel arket"
                $Excel.Quit()
                pause
                Return
            }

            ## removes $false values. find a better way to confirm value in hastable.
            <#
            #Removing empty values from OtherAttributes
            @($Hash.Keys) | ForEach-Object {
            if (-not $Hash[$_]) { $Hash.Remove($_) }
            }
            #>

            Remove-Variable TestIfUserExist -ErrorAction SilentlyContinue
            $ErrorActionPreferenceBeforechange = $ErrorActionPreference
            $ErrorActionPreference = "SilentlyContinue" # done because get-aduser doesn't respect -ErrorAction
            
            try{
            
            $TestIfUserExist = Get-ADUser -Identity "$MANumrerCleanEKS_" -ErrorAction Stop # -Server $server
            }
            catch{
            
                # do nothing
            }
            $ErrorActionPreference = $ErrorActionPreferenceBeforechange

            if (-not $TestIfUserExist) {

                # Creating the user account
                try {
                    New-ADUser @Hash  # -Server $server #-Verbose -PassThru
                }
                catch {
                    Write-Host -ForegroundColor Yellow "Could not create user {$AccountName} , {$Displayname}"
                }

                ## set the decription
                try {

                    Remove-Variable UserInfoFieldString -ErrorAction SilentlyContinue
                    $UserInfoFieldString += "$Description"
                    $UserInfoFieldString += "`r`n"
                    $DateForDayOne = (get-date).DateTime ## convert to [datetime] and forward one day and use grether than one day. or goolge for something more simple
                    $UserInfoFieldString += "Brugeroprettet {$DateForDayOne}"
                    # $UserInfoFieldString

                    Set-ADUser -Identity $MANumrerCleanEKS_ -Replace @{info = $UserInfoFieldString } # -Server $server #-WhatIf
                }
                catch {
                    Write-Host -ForegroundColor Yellow "Could not replace userinfo field user {$AccountName} , {$Displayname}"
                }

                # Add Group membership according to kope
                Remove-Variable TestIfUserExistAfterNewUser -ErrorAction SilentlyContinue
                $TestIfUserExistAfterNewUser = Get-ADUser -Identity $AccountName -ErrorAction SilentlyContinue  # -Server $server
                # $TestIfUserExistAfterNewUser.MemberOf
                if ($TestIfUserExistAfterNewUser) {

                    foreach ($SecurityGroupsline in $SecurityGroups) {

                        #$SecurityGroupsline = $SecurityGroups[2]
                        $SecurityGroupslineClean = $SecurityGroupsline.Trim()
                        Add-ADGroupMember -Identity $SecurityGroupslineClean -Members  $MANumrerCleanEKS_ # -Server $server #-PassThru
                    }
                }
                Write-Output $TestIfUserExistAfterNewUser 
                # $HashOutput = New-Object psobject -Property $Hash
                # Write-Output ($HashOutput | Select-Object -Property Name) # $hash.name
                # write-host "$($hash.name)"
            }
            else {
                # if (-not $TestIfUserExist) {

                Write-Warning "{$($TestIfUserExist.name)} Allready exist. Nothing have been changed on the user. Change Ma number in Excel if this is a new user"
            }
            #$AccountName


        } # foreach ($number in $ExcelSelctor ) {

        Write-Output $UserCreationOutput
        $global:UserYesNoChoiceToDataValid = $false
        #Remove-Variable UserYesNoChoiceToDataValid -ErrorAction SilentlyContinue
        Remove-Variable Password -ErrorAction SilentlyContinue
        $Excel.Quit()
    }
    End {

    }
}
function Show-FirstUserOutputWPFForm {

    [CmdletBinding()]
    [OutputType([bool])]
    Param
    (
        # Userinformation Hash from New-JohnstrupUsers
        [Parameter(Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 0)]
        $Hash
    )

    Add-Type -AssemblyName PresentationFramework, System.Windows.Forms, WindowsFormsIntegration

    [xml][string]$XAML_ConnectDialog = @"
    <Window 
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
    xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
    xmlns:local="clr-namespace:Azure"
    Title="Kig om det indlæste står i de korekte felter, for den første bruger i arket." Height="500" Width="610">
<Grid Margin="0,0,0,0">
    <Button Name="btnOK" Content="Godkend" HorizontalAlignment="Left" VerticalAlignment="bottom" Margin="510,0,0,20"  Width="75" Height="23"/>
    <Button Name="btnExit" Content="Afvis" HorizontalAlignment="Left" VerticalAlignment="bottom" Margin="425,0,0,20"  Width="75" Height="23"/>
    <ListView Name="Collections" Margin="0,0,0,53">
    <ListView.View>
      <GridView>
        <GridViewColumn Header="Name" DisplayMemberBinding="{Binding Name}" Width="150"/>
        <GridViewColumn Header="Value" DisplayMemberBinding="{Binding Value}" Width="430"/>
      </GridView>
    </ListView.View>
  </ListView>
</Grid>
</Window>
"@

    $XML_Node_Reader_ConnectDialog = (New-Object System.Xml.XmlNodeReader $XAML_ConnectDialog)

    #$XML_Node_Reader_ConnectDialog = (New-Object System.Xml.XmlNodeReader $XAML_ConnectDialog)
    $ConnectDialog = [Windows.Markup.XamlReader]::Load($XML_Node_Reader_ConnectDialog)
    $Collections = $ConnectDialog.FindName('Collections')
    
    $Btn_ConnectDialog_ConnectOK = $ConnectDialog.FindName('btnOK')
    $Btn_ConnectDialog_ConnectOK.IsDefault = $true
    $Btn_ConnectDialog_ConnectOK.Add_Click( {

            $global:UserYesNoChoiceToDataValid = $true
            #write-host "1"
            $ConnectDialog.Close()
        })
    $Btn_ConnectDialog_ConnectExit = $ConnectDialog.FindName('btnExit')
    $Btn_ConnectDialog_ConnectExit.IsCancel = $true
    $Btn_ConnectDialog_ConnectExit.Add_Click( {

            $global:UserYesNoChoiceToDataValid = $false
            #Write-Host "2"
            $ConnectDialog.Close()
        
        })
    $HashToArrayOfCustomObjects = $Hash.GetEnumerator() | ForEach-Object {
        [pscustomobject]@{name = $_.name; value = $_.Value }
    }
    #$DCs = Import-Csv -Path 'C:\Users\jebn\OneDrive - Sundhedsdatastyrelsen\Dokumenter\values.txt'
    #$DCs = Get-ChildItem C:\RUFR_PowerShell\PS_scripts\SST
    # $Collections.ItemsSource = $DCs    
    $Collections.ItemsSource = $HashToArrayOfCustomObjects

    # Add hanldling when exit i pressed. Not sure
    $ConnectDialog.Add_Closing( { [System.Windows.Forms.Application]::Exit() }) # {$form.Close()}

    # Running this without $appContext and ::Run would actually cause a really poor response.
    $ConnectDialog.Show()

    # This makes it pop up
    $ConnectDialog.Activate() | Out-Null
    #run the form ConnectDialog
    $appContext = New-Object System.Windows.Forms.ApplicationContext
    [System.Windows.Forms.Application]::Run($appContext)

    #########################
    #$ButtonPressBook 
}
function Get-DateFromString {
    [CmdletBinding()]
    [Alias('Get-DateFromReadHost')]
    [OutputType([datetime])]
    Param
    (
        # Date in format dd-mm-yyyy
        [Parameter(Mandatory = $false,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            ValueFromRemainingArguments = $false,
            Position = 0)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        $datefromuser
    )

    Begin {
    }
    Process {
        do {
            Remove-Variable datetime -ErrorAction SilentlyContinue

            if ($datefromuser) {

                try {
                    [int]$dd = $datefromuser.Substring(0, 2)
                }
                catch {
                    Write-Host -ForegroundColor Yellow "Could not parse Date. Please follow format dd-mm-yyyy"
                }

                try {
                    [int]$mm = $datefromuser.Substring(3, 2)
                }
                catch {
                    Write-Host -ForegroundColor Yellow "Could not parse Date. Please follow format dd-mm-yyyy"
                }

                try {
                    [int]$yyyy = $datefromuser.Substring(6, 4)
                }
                catch {
                    Write-Host -ForegroundColor Yellow "Could not parse Date. Please follow format dd-mm-yyyy"
                }

                try {
                    $datetime = [datetime]::Parse("$yyyy-$mm-$dd`T00:00:00")
                    #$ChangeDate = New-Object DateTime(2008, 11, 18, 1, 40, 02)
                }
                catch {
                    Write-Host -ForegroundColor Yellow "Could not parse Date  {$datefromuser}"
                }
                # Done to make sure a valid date is returned. If the provided indput ins't valid.
                if (-not $datetime) {

                    Write-Host -ForegroundColor Yellow "Could not parse Date enter valid date"
                    Pause
                    $datefromuser = Read-Host "please enter date in the format dd-mm-yyyy"

                    try {
                        [int]$dd = $datefromuser.Substring(0, 2)
                    }
                    catch {
                        Write-Host -ForegroundColor Yellow "Could not parse Date. Please follow format dd-mm-yyyy"
                    }

                    try {
                        [int]$mm = $datefromuser.Substring(3, 2)
                    }
                    catch {
                        Write-Host -ForegroundColor Yellow "Could not parse Date. Please follow format dd-mm-yyyy"
                    }

                    try {
                        [int]$yyyy = $datefromuser.Substring(6, 4)
                    }
                    catch {
                        Write-Host -ForegroundColor Yellow "Could not parse Date. Please follow format dd-mm-yyyy"
                    }

                    try {
                        $datetime = [datetime]::Parse("$yyyy-$mm-$dd`T00:00:00")
                        #$ChangeDate = New-Object DateTime(2008, 11, 18, 1, 40, 02)
                    }
                    catch {
                        Write-Host -ForegroundColor Yellow "Could not parse Date  {$datefromuser}"
                    }
                }

            }
            else {

                $datefromuser = Read-Host "please enter date in the format dd-mm-yyyy"

                try {
                    [int]$dd = $datefromuser.Substring(0, 2)
                }
                catch {
                    Write-Host -ForegroundColor Yellow "Could not parse Date. Please follow format dd-mm-yyyy"
                }

                try {
                    [int]$mm = $datefromuser.Substring(3, 2)
                }
                catch {
                    Write-Host -ForegroundColor Yellow "Could not parse Date. Please follow format dd-mm-yyyy"
                }

                try {
                    [int]$yyyy = $datefromuser.Substring(6, 4)
                }
                catch {
                    Write-Host -ForegroundColor Yellow "Could not parse Date. Please follow format dd-mm-yyyy"
                }

                try {
                    $datetime = [datetime]::Parse("$yyyy-$mm-$dd`T00:00:00")
                    #$ChangeDate = New-Object DateTime(2008, 11, 18, 1, 40, 02)
                }
                catch {
                    Write-Host -ForegroundColor Yellow "Could not parse Date  {$datefromuser}"
                }
            }

        }
        until ($datetime)

        Write-Output $datetime
    }
    End {
    }
} 
<#
    $HashToArrayOfCustomObjects = $Hash.GetEnumerator() | ForEach-Object{
        [pscustomobject]@{name=$_.name;LastName=$_.Value}
    }
    $HashToArrayOfCustomObjects.GetType()

    $data = @(
        [pscustomobject]@{name='UserName';LastName='Marquette'}
        [pscustomobject]@{name='SamAccountName'; LastName='Doe'}
        [pscustomobject]@{name='Enabled';LastName='Marquette'}
        [pscustomobject]@{name='Path'; LastName='Doe'}
    )
    $data
    $data.GetType()

    $BindableDCs = $DCs | Select-Object -Property @{Name='CollectionName';Expression={$_.Name}}, @{Name='CollectionCount';Expression={$_.MemberCount}}
    #>