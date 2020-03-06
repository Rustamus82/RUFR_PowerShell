# Konverter AJVUsers.CSV fra Unicode til Ascii (ANSI) format og kopier den til SAMWIN serveren,
# hvor Jansson importere filen til SamWin telefonbog 
# 2018-01-29 Globeteam, Jan Pries
# ---------------------------------------------------

#Konverter format
$CONFileName = "C:\Samwin\AJVUsers.csv"
# Write-Host $CONFileName
[System.Text.Encoding]::Default.EncodingName
[System.IO.File]::ReadAllText($CONFileName) | Out-File -FilePath $CONFileName -Encoding default
#--------------------------------------------------------------------------------------------

#Kopiere filen til SAMWIN serveren
$source="C:\Samwin\AJVUsers.csv"
$destination="\\Srv-lync-tlF01\Samwin\Import\AJVUsers.CSV"
Copy-Item -Path $source -destination $destination 
#-------------------------------------------------
