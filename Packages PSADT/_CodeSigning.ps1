# Get the code-signing certificate from the local computer's certificate store with the name *ATA Authenticode* and store it to the $codeCertificate variable.
#$codeCertificate = Get-ChildItem Cert:\LocalMachine\My | Where-Object {$_.Subject -eq "CN=ATA Authenticode"}
$codeCertificate = Get-ChildItem -Path 'Cert:\CurrentUser\My\' -Recurse -CodeSigningCert 

# Sign the PowerShell script
# PARAMETERS:
# FilePath - Specifies the file path of the PowerShell script to sign, eg. C:\ATA\myscript.ps1.
# Certificate - Specifies the certificate to use when signing the script.
# TimeStampServer - Specifies the trusted timestamp server that adds a timestamp to your script's digital signature. Adding a timestamp ensures that your code will not expire when the signing certificate expires.

#Set-AuthenticodeSignature -Certificate $codeCertificate -TimeStampServer "http://timestamp.digicert.com" -FilePath C:\Users\userName\Desktop\TestSigne.ps1
#Set-AuthenticodeSignature -Certificate $codeCertificate  -FilePath C:\Users\userName\Desktop\TestSigne.ps1

#$collection = Get-ChildItem -Path "$env:USERPROFILE\desktop" -Recurse -Exclude "*CodeSigning*" -Filter "*.ps1"
$collection = Get-ChildItem -Path "$env:USERPROFILE\desktop" -Recurse -Filter "*.ps1"
foreach ($item in $collection)
{    
    Set-AuthenticodeSignature -Certificate $codeCertificate -TimeStampServer "http://timestamp.digicert.com" -FilePath $item.PSPath
   
}

$collection = Get-ChildItem -Path "$env:USERPROFILE\desktop" -Recurse -Exclude "*CodeSigning*" -Filter "*.psm1"
foreach ($item in $collection)
{    
    Set-AuthenticodeSignature -Certificate $codeCertificate -TimeStampServer "http://timestamp.digicert.com" -FilePath $item.PSPath
   
}
