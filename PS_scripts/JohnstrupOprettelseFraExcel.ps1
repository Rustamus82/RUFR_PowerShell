#PSVersion 5.1 Script made/assembled by JEBN 29-12-2020
cls; Write-Host "Du har valgt JohnstrupOprettelseFraExcel.ps1" -ForegroundColor Gray -BackgroundColor DarkCyan

# Import-Module ((Get-ChildItem 'C:\Users\adm_jebn\Documents\RUFR_PowerShell_v2.07\PS_scripts' -Recurse -Filter "New-JohnstrupUsers.psm1").FullName)
Remove-Module -Name New-JohnstrupUsers -ErrorAction SilentlyContinue
Import-Module ((Get-ChildItem "$PSScriptRoot" -Recurse -Filter "New-JohnstrupUsers.psm1").FullName)

enum kope {
    kope1
    kope2
}

enum kontakansvarlig {
    SALM
    LNGE
    NALH
    SATM
    JACH
}
#[kontakansvarlig].GetEnumName(0)

enum company {
    Hjemmeværnet
    Moment
    Politiet
    Beredskabsstyrelsen
    ATP
}

# could not create enum with "numbers" or "-"". Changes to array and i index into it instead. 
$AccountExpirationDateEnteredArray = @()
$AccountExpirationDateEnteredArray += "Enter Date"
$AccountExpirationDateEnteredArray += "31-05-2021"


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
    $Options += "SATM"
    $Options += "JACH"

    $i = 1
    $option = foreach ($OptionsLine in $Options) {
        "&$i $OptionsLine"
        $i++
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
    $Options += "Beredskabsstyrelsen"
    $Options += "ATP"

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

if ($Company -eq 'ATP') {

    $Options = @()
    $Options += "Enter date"
    $Options += "31-05-2021"

    $i = 1
    $option = foreach ($OptionsLine in $Options) {
        "&$i $OptionsLine"
        $i++
    }

    $helpText = foreach ($OptionsLine in $Options) {
        "$OptionsLine"
    }

    $message = "Vælg slut dato for bruger eller tast selv"

    $default = -1
    Remove-Variable choice -ErrorAction SilentlyContinue
    [int]$choice = Read-HostWithPrompt $caption $message $option $helpText $default

    switch ($choice)
    {
        '0' {
        
            $AccountExpirationDateEntered = Get-DateFromString
            $AccountExpirationDate = $AccountExpirationDateEntered.AddDays(+1)        
        }
        '1' {
        
            $AccountExpirationDateEntered = Get-DateFromString $($AccountExpirationDateEnteredArray[$choice])
            $AccountExpirationDate = $AccountExpirationDateEntered.AddDays(+1)
        }
        Default {
        
            Write-Warning "slut dato for bruger fejler"
            pause
            return
        }
    }
}
else {
        
    $AccountExpirationDate = Get-DateFromString "30-06-2021"
}

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

# This part is done because Excel com objects doesn't support "\\tsclient" i filepath
Remove-Variable -Name FilePathExcel -ErrorAction SilentlyContinue
$FilePathExcel = Get-ChildItem $FileName


if ($FilePathExcel.FullName -like '\\tsclient*') {
    Remove-Variable -Name FileName -ErrorAction SilentlyContinue
    Copy-Item -Path $FilePathExcel.FullName -Destination $env:TEMP
    $FileName = (Get-ChildItem -Path "$env:TEMP\$($FilePathExcel.name)").FullName
}

Write-Host "Skifter til DKSUND AD" -foregroundcolor Yellow
Set-Location -Path 'DKSUNDAD:'

$JonstrupUserOutput = New-JohnstrupUsers -Kope $kope -kontakansvarlig $kontakansvarlig -CaseID $CaseID -Company $company -FileName $FileName -AccountExpirationDate $AccountExpirationDate
# Write-Output $JonstrupUserOutput 

foreach ($JonstrupUserOutputLine in $JonstrupUserOutput) {

    Write-Host "$($JonstrupUserOutputLine.name)"
}
# Write-Host "$JonstrupUserOutput"

 do {
    $Options = @()
    $Options += "Ja"
    $Options += "Nej"

    $option = foreach ($OptionsLine in $Options) {
        "&$OptionsLine"
    }

    $HelpText = foreach ($OptionsLine in $Options) {
        "$OptionsLine"
    }
    $Caption = ""
    $Message = "Har du kopiret output ud til Sagssystem? Svar Ja, eller Nej"

    $Default = -1
    Remove-Variable ReadyToClose -ErrorAction SilentlyContinue
    $ReadyToClose = Read-HostWithPrompt $Caption $Message $option $HelpText $Default    
}
until ($ReadyToClose -eq 0)


# Remove temp file if it's copied to avoid "\\tsclient" i path.
if ($FilePathExcel.FullName -like '\\tsclient*') {
    
    Remove-Item -Path $FileName 
}
#-CaseID $CaseID -Filename $FileName 

