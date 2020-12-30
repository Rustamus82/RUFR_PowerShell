#PSVersion 5.1 Script made/assembled by JEBN 29-12-2020
cls; Write-Host "Du har valgt JohnstrupOprettelseFraExcel.ps1" -ForegroundColor Gray -BackgroundColor DarkCyan

## udfyld nedestående værdier efter arket.

# $Kope = "kope1" # kope1 kope2

# $Description = "Almindelig konto til ekstern konsulent, kontakt person $kontakansvarlig - $CaseID" # SALM LNGE NALH

# $Company = "Hjemmeværnet"  # Hjemmeværnet Moment Politiet


# $FileName = 'Kontaktoplysninger KOPE_HJV_17-11-2020.xlsx' # husk fil endelse 

# $StiTilPowershellFiler = "C:\Users\jebn\OneDrive - Sundhedsdatastyrelsen\Powershell\johnstrup"
$StiTilPowershellFiler = "$PSScriptRoot" 

<#

Tryk F5

#>

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

enum kope {
    kope1
    kope2
}

enum kontakansvarlig {
    SALM
    LNGE
    NALH
}

enum company {
    Hjemmeværnet
    Moment
    Politiet
}

if ( -not $kope) {

    $Options = @()
    $Options += "kope1"
    $Options += "kope2"

    $i = 1
    $option = foreach ($OptionsLine in $Options) {
        "&$i $OptionsLine"
        $i++
    }

    $helpText = foreach ($OptionsLine in $Options) {
        "$OptionsLine"
    }

    $message = "Vælg kope"

    $default = -1
    Remove-Variable kope -ErrorAction SilentlyContinue
    [kope]$kope = Read-HostWithPrompt $caption $message $option $helpText $default
}

if ( -not $kontakansvarlig) {

    $Options = @()
    $Options += "SALM"
    $Options += "LNGE"
    $Options += "NALH"

    $option = foreach ($OptionsLine in $Options) {
        "&$OptionsLine"
    }

    $helpText = foreach ($OptionsLine in $Options) {
        "$OptionsLine"
    }

    $message = "Vælg ansvarlig"

    $default = -1
    Remove-Variable kontakansvarlig -ErrorAction SilentlyContinue
    [kontakansvarlig]$kontakansvarlig = Read-HostWithPrompt $caption $message $option $helpText $default
}

if ( -not $company) {

    $Options = @()
    $Options += "Hjemmeværnet"
    $Options += "Moment"
    $Options += "Politiet"

    $option = foreach ($OptionsLine in $Options) {
        "&$OptionsLine"
    }

    $helpText = foreach ($OptionsLine in $Options) {
        "$OptionsLine"
    }

    $message = "Vælg firma"

    $default = -1
    Remove-Variable company -ErrorAction SilentlyContinue
    [company]$company = Read-HostWithPrompt $caption $message $option $helpText $default
}


do {
    [string]$CaseID = Read-Host -Prompt "Tast sags ID. (RITM nummer)"
}
until ($CaseID)

write-host "Vælg Jonstrup Excel fil fra sagen" -ForegroundColor Green

# done to make sure a filepath is provided
do {
    # Filepath for input
    Add-Type -AssemblyName System.Windows.Forms
    $FolderBrowser = New-Object System.Windows.Forms.OpenFileDialog
    [void]$FolderBrowser.ShowDialog()
    # $FolderBrowser.FileName
    $FileName = $FolderBrowser.FileName
}
until ($FileName)
Remove-Module -Name New-JohnstrupUsers -ErrorAction SilentlyContinue
Import-Module ((Get-ChildItem "$PSScriptRoot" -Recurse -Filter "New-JohnstrupUsers.psm1").FullName)

Write-Host "Skifter til DKSUND AD" -foregroundcolor Yellow
Set-Location -Path 'DKSUNDAD:'

New-JohnstrupUsers -Kope $kope -kontakansvarlig $kontakansvarlig -CaseID $CaseID -Company $company -FileName $FileName 

#-CaseID $CaseID -Filename $FileName 
