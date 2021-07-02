#PSVersion 5 Script made/assembled by Rust@m 05-03-2021
<#Login RUFR all AD login, Hybrid and EXO
$CommandPath = (Get-Location).Path | Split-Path -Parent; $script = "$CommandPath\Logins\Login_SSI_SST_exch2010_DKSUND_Exchange365_RUFR.ps1"; & $script

#Import-Module exhcnage online & Azure AD
Import-Module ExchangeOnlineManagement
Import-Module AzureAD
$Global:UserCredDksund = Get-Credential adm-rufr@dksund.dk -Message "DKSUND AD login, Exchange Online & Hybrid"
Connect-ExchangeOnline -Credential $Global:UserCredDksund -ShowProgress $true -ShowBanner:$false
Connect-AzureAD -Credential $Global:UserCredDksund
Connect-MsolService -Credential $Global:UserCredDksund
cls
#>


$UserCredential = Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/?proxyMethod=RPS -Credential $UserCredential -Authentication Basic -AllowRedirection
Import-PSSession $Session

##SST+STPS
#Update the user photos path here. Name of the file should be username of the Office365 user.
$path= '\\s-inf-fil-05-p.ssi.ad\uvl\Medarbejderfotos_SST\CheckedPhotos\O365\'
$Images = Get-ChildItem $path
$Images |Foreach-Object{
$Identity = ($_.Name.Tostring() -split "\.")[0]
$PictureData = $path+$_.name
Set-UserPhoto -Identity $Identity -PictureData ([System.IO.File]::ReadAllBytes($PictureData)) -Confirm:$false }



##SSI+SDS
#Update the user photos path here. Name of the file should be username of the Office365 user.
#$path= '\\s-inf-fil-05-p.ssi.ad\uvl\Medarbejderfotos\CheckedPhotos\O365\'
$path= 'C:\Users\adm-rufr\Desktop\Photo\'
$Images = Get-ChildItem $path
$Images |Foreach-Object{
$Identity = ($_.Name.Tostring() -split "\.")[0]
$PictureData = $path+$_.name
Set-UserPhoto -Identity $Identity -PictureData ([System.IO.File]::ReadAllBytes($PictureData)) -Confirm:$false }
                        
             

##STPK
#Update the user photos path here. Name of the file should be username of the Office365 user.
$path= '\\dksund.dk\koncern\STPK\Faelles\Medarbejderfotos\O365\'
$Images = Get-ChildItem $path
$Images |Foreach-Object{
$Identity = ($_.Name.Tostring() -split "\.")[0]
$PictureData = $path+$_.name
Set-UserPhoto -Identity $Identity -PictureData ([System.IO.File]::ReadAllBytes($PictureData)) -Confirm:$false }
                        

                        
