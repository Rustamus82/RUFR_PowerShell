###############################################################################
#https://gallery.technet.microsoft.com/scriptcenter/Send-HTML-Email-Powershell-6653235c
#Moddified by Rust@m 29-05-2018
###########Define Variables########

$fromaddress = "donotreply@sundhedsdata.dk"
$toaddress = "bebo@sundhedsdata.dk"
#$bccaddress = "ssiprep@ssi.dk"
$CCaddress = "rufr@ssi.dk"
$Subject = "Action Required: test besked fra .."
$body = get-content .\content.htm
#$body = get-content "$PSScriptRoot\content.htm"
$smtpserver = "relay.dksund.dk"


#your file location
$Path = "C:\RUFR_PowerShell\ISE_scripts_only\sendemail"
$Files = Get-ChildItem -Path $Path -Include *.txt -Recurse  | Where-Object {$_.CreationTime -gt (Get-Date).Date}

####################################

$message = new-object System.Net.Mail.MailMessage
$message.From = $fromaddress
$message.To.Add($toaddress)
$message.CC.Add($CCaddress)
#$message.Bcc.Add($bccaddress)
$message.IsBodyHtml = $True
$message.Subject = $Subject

#Several attachments added
Foreach($file in $files)
{
Write-Host “Attaching File: -” $file
$attachment = New-Object System.Net.Mail.Attachment $($file.FullName)
$message.Attachments.Add($attachment)
}
#$attach = new-object Net.Mail.Attachment($attachment)
#$message.Attachments.Add($attach)
$message.body = $body
$smtp = new-object Net.Mail.SmtpClient($smtpserver)
$smtp.Send($message)
Remove-Variable -Name * -ErrorAction SilentlyContinue
#################################################################################