 
function Get-WpfUserInput {

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
    [OutputType([String])]
    Param
    (
        # Param1 help description
        
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $false,
            ValueFromPipelineByPropertyName = $true,
            Position = 0,
            ParameterSetName = 'Parameter Set 1')]
        #[ValidateSet("kope1", "kope2")]
        [kope]$Kope,

        # Param2 help description
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $false,
            Position = 1,
            ValueFromPipelineByPropertyName = $true,
            ParameterSetName = 'Parameter Set 1')]
        [kontakansvarlig]$kontakansvarlig,

        # Param3 help description
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $false,
            Position = 1,
            ValueFromPipelineByPropertyName = $true,
            ParameterSetName = 'Parameter Set 1')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [string]$CaseID,        

        # Param4 help description
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $false,
            Position = 2,
            ValueFromPipelineByPropertyName = $true,
            ParameterSetName = 'Parameter Set 1')]
        #[ValidateSet("Hjemmeværnet", "Moment", "Politiet")]
        [company]$Company,

        # Param5 help description
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $false,
            Position = 3,
            ValueFromPipelineByPropertyName = $true,
            ParameterSetName = 'Parameter Set 1')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [String]$FileName
    )

    Begin {
    }
    Process {
        ## End userdefinded values
        ## ikke pille længere nede. :)

        $Office = "STPS"
        $Title = "Ekstern konsulent"
        $UserParentOUDistinguishedName = "OU=Eksterne,OU=Organisationer,DC=dksund,DC=dk"
        $AccountExpirationDate = "28-02-2021"
        # $server = "S-AD-DC-03P.dksund.dk"
        $SecurityGroups = (Get-ADUser -Identity $($Kope.ToString()) -Properties MemberOf).MemberOf # -Server $server
        $UserPrincipalNamedomain = "@dksund.dk"
        # $UserNameOfRunner = $env:USERNAME -replace 'adm_', '' -replace 'adm-', ''
        # $FilePathDownloads = "C:\Users\$UserNameOfRunner\Downloads\"
        # $FilePath = "$FilePathDownloads" + "$FileName"
        $FilePath = "$FileName"

        if ( -not (Test-Path -Path $FilePath)) {

            write-warning "Jeg kan ikke finde den fil du har angivet. Ligger den i din egen downloads mappe?"
            Return
        }

        if (-not $password) {
            $password = Get-WpfUserInput -Message 'skriv koden du vil have på brugerne'
        }
        #$password = Read-Host -AsSecureString -Prompt 'indtast kode til brugeren'

        $excel = New-Object -comobject Excel.Application

        #open file
        $workbook = $excel.Workbooks.Open($FilePath)
        $s1 = $workbook.sheets | Where-Object -FilterScript { $_.name -eq 'Ark1' }

        $iExcelTestLenght = 0

        do {
            Remove-Variable MANumrer -ErrorAction SilentlyContinue
            $iExcelTestLenght++
            $MANumrer = $s1.range("D$iExcelTestLenght").cells.text
        }
        until (-not $MANumrer)

        $ExcelSelctor = for ($iExcel = 2; $iExcel -lt $iExcelTestLenght; $iExcel++ ) {
            # starts at 2, because first vallues conating userinformation in excel ar is line 2

            Write-Output $iExcel
        }
        # $number = 2


        foreach ($number in $ExcelSelctor ) {
        
            try {
                $MANumrerIntTest = $s1.range("D$number").cells.text
                [int]$MANumrerIntTestClean = $MANumrerIntTest.Trim() 
            }
            catch [System.Object] {
                Write-Host -ForegroundColor Yellow "Der er andet end tal i MA Numrer {$($MANumrerIntTest.Trim())}. Du havde vist ikke lavet ordenlig kontrol"
                Return
            }        
        }

        $UserCreationOutput = foreach ($number in $ExcelSelctor ) {

            $GivenName = $s1.range("B$number").cells.text
            $GivenNameClean = $GivenName.Trim()

            $Surname = $s1.range("C$number").cells.text
            $SurnameClean = $Surname.trim()

            $MANumrer = $s1.range("D$number").cells.text
            $MANumrerClean = $MANumrer.Trim()

            $MANumrerCleanEKS_ = "EKS_" + "$MANumrerClean"
            $AccountName = $MANumrerCleanEKS_

            $MobilePhone = $s1.range("F$number").cells.text
            $MobilePhoneClean = $MobilePhone.trim()
            $MobilePhoneCleanPlus45 = "+45" + "$MobilePhoneClean"

            $EmailAddress = $s1.range("E$number").cells.text
            $EmailAddressClean = $EmailAddress.trim()

            $name = "$GivenNameClean" + " " + "$SurnameClean" + " ($MANumrerCleanEKS_)"
            $Displayname = "$GivenNameClean" + " " + "$SurnameClean"

            $UserPrincipalName = "$MANumrerCleanEKS_" + "$UserPrincipalNamedomain"

            $Description = "Almindelig konto til ekstern konsulent, kontakt person $kontakansvarlig - $CaseID" # SALM LNGE NALH

            #hash table for splat New-ADUser
            $hash = @{
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

                Out-GridView -InputObject $hash -Wait

                $Options = @()
                $Options += "Nej"
                $Options += "Ja"

            $option = foreach ($OptionsLine in $Options) {
                "&$OptionsLine"
            }

                $helpText = foreach ($OptionsLine in $Options) {
                    "$OptionsLine"
                }


                $message = "er første bruger udfuldt med korrekt information i felterne? Svar Ja, eller Nej"

                $default = -1
                Remove-Variable UserYesNoChoiceToDataValid -ErrorAction SilentlyContinue
                $UserYesNoChoiceToDataValid = Read-HostWithPrompt $caption $message $option $helpText $default
            }

            if (-not $UserYesNoChoiceToDataValid) {
                
                Write-Host -ForegroundColor Yellow "kør scriptet igen når du har rettet fejlen du fandt i excel arket"
                Return
            }

            ## removes $false values. find a better way to confirm value in hastable.
            <#
            #Removing empty values from OtherAttributes
            @($hash.Keys) | ForEach-Object {
            if (-not $hash[$_]) { $hash.Remove($_) }
            }
            #>

            Remove-Variable TestIfUserExist -ErrorAction SilentlyContinue
            $ErrorActionPreferenceBeforechange = $ErrorActionPreference
            $ErrorActionPreference = "SilentlyContinue" # done because get-aduser doesn't respect -ErrorAction
            $TestIfUserExist = Get-ADUser -Identity "$MANumrerCleanEKS_"  -Properties *   -ErrorAction SilentlyContinue # -Server $server
            $ErrorActionPreference = $ErrorActionPreferenceBeforechange

            if (-not $TestIfUserExist) {

                # Creating the user account
                try {
                    New-ADUser @hash  # -Server $server #-Verbose -PassThru
                }
                catch [System.Object] {
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
                catch [System.Object] {
                    Write-Host -ForegroundColor Yellow "Could not replace userinfo field user {$AccountName} , {$Displayname}"
                }

                # Add Group membership according to kope
                Remove-Variable TestIfUserExistAfterNewUser -ErrorAction SilentlyContinue
                $TestIfUserExistAfterNewUser = Get-ADUser -Identity $AccountName -ErrorAction SilentlyContinue -Properties * # -Server $server
                # $TestIfUserExistAfterNewUser.MemberOf
                if ($TestIfUserExistAfterNewUser) {

                    foreach ($SecurityGroupsline in $SecurityGroups) {

                        #$SecurityGroupsline = $SecurityGroups[2]
                        $SecurityGroupslineClean = $SecurityGroupsline.Trim()
                        Add-ADGroupMember -Identity $SecurityGroupslineClean -Members  $MANumrerCleanEKS_ # -Server $server #-PassThru
                    }
                }
                Write-Output $hash.name
            }
            else {
                # if (-not $TestIfUserExist) {

                Write-Warning "{$($TestIfUserExist.Displayname)} Allready exist. Nothing have been changed on the user. correct user manually"
            }
            #$AccountName


        } # foreach ($number in $ExcelSelctor ) {

        Write-Output $UserCreationOutput

        $excel.Quit()
        
        do
        {
            $Options = @()
            $Options += "Ja"
            $Options += "Nej"

            $option = foreach ($OptionsLine in $Options) {
                "&$OptionsLine"
            }

            $helpText = foreach ($OptionsLine in $Options) {
                "$OptionsLine"
            }
            $caption = ""
            $message = "Har du kopiret output ud til Sagssystem? Svar Ja, eller Nej"

            $default = -1
            Remove-Variable ReadyToClose -ErrorAction SilentlyContinue
            $ReadyToClose = Read-HostWithPrompt $caption $message $option $helpText $default    
        }
        until ($ReadyToClose -eq 0)

        
    }
    End {
    }
}

