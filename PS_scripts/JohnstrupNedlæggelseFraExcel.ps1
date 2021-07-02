#PSVersion 5.1 Script made/assembled by JEBN 29-12-2020
cls; Write-Host "Du har valgt JohnstrupOprettelseFraExcel.ps1" -ForegroundColor Gray -BackgroundColor DarkCyan

# Import-Module ((Get-ChildItem 'C:\Users\adm_jebn\Documents\RUFR_PowerShell_v2.07\PS_scripts' -Recurse -Filter "New-JohnstrupUsers.psm1").FullName)
Remove-Module -Name New-JohnstrupUsers -ErrorAction SilentlyContinue
Import-Module ((Get-ChildItem "$PSScriptRoot" -Recurse -Filter "New-JohnstrupUsers.psm1").FullName)

enum company {
    Hjemmeværnet
    Moment
    Politiet
    Beredskabsstyrelsen
    ATP
}

if ( -not $company) {

    $Options = @()
    $Options += "Hjemmeværnet"
    $Options += "Moment"
    $Options += "Politiet"
    $Options += "Beredskabsstyrelsen"
    $Options += "ATP"

    $i = 1
    $option = foreach ($OptionsLine in $Options) {
        "&$i $OptionsLine"
        $i++
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
    $FilePath = $FolderBrowser.FileName
}
until ($FilePath)

# This part is done because Excel com objects doesn't support "\\tsclient" i filepath
Remove-Variable -Name FilePathExcel -ErrorAction SilentlyContinue
$FilePathExcel = Get-ChildItem $FilePath


if ($FilePathExcel.FullName -like '\\tsclient*') {
    Remove-Variable -Name FileName -ErrorAction SilentlyContinue
    Copy-Item -Path $FilePathExcel.FullName -Destination $env:TEMP
    $FilePath = (Get-ChildItem -Path "$env:TEMP\$($FilePathExcel.name)").FullName
}

Write-Host "Skifter til DKSUND AD" -foregroundcolor Yellow
Set-Location -Path 'DKSUNDAD:'

$JonstrupUserOutput = Remove-JohnstrupUsers -CaseID $CaseID -Company $company -FilePath $FilePath 
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
    
    Remove-Item -Path $FilePath 
}
#-CaseID $CaseID -Filename $FileName 

