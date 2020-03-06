# Konverter AJVUsers.CSV fra UTF-8 til UTF-8-BOM
# hvor kontakter importeret i Outlook - Concierge
# 2020-02-29 Rust@m
# ---------------------------------------------------

#Konverter format
$CONFileName = "C:\Kontakter\AJV\AJVUsers.csv"
# Write-Host $CONFileName
#[System.Text.Encoding]::Default.EncodingName
#[System.IO.File]::ReadAllText($CONFileName) | Out-File -FilePath $CONFileName -Encoding default

(Get-Content -path "$CONFileName" -Encoding UTF8) | Set-Content -Encoding UTF8 -Path "$CONFileName"


#--------------------------------------------------------------------------------------------

<#Kopiere filen til SAMWIN serveren
$source="C:\Samwin\AJVUsers.csv"
$destination="\\Srv-lync-tlF01\Samwin\Import\AJVUsers.CSV"
Copy-Item -Path $source -destination $destination 
#-------------------------------------------------
cls
#>


