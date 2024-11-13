
[CmdletBinding()]
Param(
    [string]$SamAccountName,
    [switch]$CreateSingleUser,
    [switch]$CreateMultipleUsers,
    [switch]$Test
)
$Alias = $SamAccountName

$time = Get-Date -Format yyyyMMddHHmm
$shorttime = Get-Date -Format yyyyMMdd


if(!$Test){
    $PathTranscript = "C:\Exchange\Scripts\Transcript\Transcript_User_MbxProvision_" + $time + ".txt"
    Start-Transcript -Path $PathTranscript -NoClobber
}



Function GetADUser($SamAccountName){
    Write-Host "Looking up AD user: "$SamAccountName""
    $ADUser = Get-ADUser $SamAccountName -Properties Mail,DisplayName,MemberOf,msExchRecipientTypeDetails
    if(!$ADUser){
        Write-Host " Did not find user with this SSO nr"
        $script:ADUser = $null
    }
    elseif($ADUser.Mail -like "unknown@company.com" ){
        Write-Host " User has wrong email address" -ForegroundColor Gray
        $script:ADUser = $null 
    }
    elseif($ADUser.Mail -like "*@company.com" -or $ADUser.Mail -like "*@2company.com"){
        if($ADUser.Enabled -like "True"){
            #Write-Host " Found enabled user: "$ADUser.DisplayName""
            if($ADUser.MemberOf -like "*G_365_License*"){
                Write-Host " User "$ADUser.DisplayName" is MemberOf G_365_License, proceeding"
                $script:ADUser = $ADUser
            }
            else{
                Write-Host " User "$ADUser.DisplayName" is NOT memberof G_365_License, skipping" -ForegroundColor RED
                #Start-Sleep -s 1
                $script:ADUser = $null
                #break
            }
        }
        else{
            Write-Host " Found user: "$ADUser.DisplayName" but AD account is NOT enabled, skipping" -ForegroundColor Red
            #Start-Sleep -s 1
            $script:ADUser = $null
            #exit
        }
    }
    elseif($ADUser.Mail -notlike "*@company.com" -and $ADUser.Mail -notlike "*@2company.com") {
        Write-Host " User has wrong email address" -ForegroundColor Gray
        $script:ADUser = $null
        #exit
    }
    else{
        Write-Host " Did not find user"
        $script:ADUser = $null
    }
}

$NoRemoteMailbox=@()
Function CheckRemoteMailbox($SamAccountName){
    GetADUser -SamAccountName $SamAccountName
    $Recip = $null
    $script:Email = $null
    if($script:ADUser){
        $Recip = Get-Recipient $script:ADUser.Mail -ErrorAction SilentlyContinue
        if(!$Recip){
            Write-Host " Found no Exchange recipient" -ForegroundColor Yellow
            $script:RemoteMbxExists = "no"
            $script:Email = $script:ADUser.Mail
            $NoRemoteMailbox =+ $SamAccountName
            Start-Sleep -s 1
        }
        elseif($Recip.RecipientTypeDetails -like "RemoteUserMailbox"){
            Write-Host " User is already a remote user mailbox" -ForegroundColor Green
            $script:RemoteMbxExists = "yes"
        }
        elseif($Recip.RecipientTypeDetails -notlike "RemoteUserMailbox"){
            Write-Host " User is NOT a remote user mailbox" -ForegroundColor Red
            $script:RemoteMbxExists = "other"
        }
    }
    else{
        Write-Host "  User does not meet the prereqs to create Remote Mailbox"
        Write-Host ""
        $script:RemoteMbxExists = $null
    } 
}

Function CreateRemoteMailbox($Email,$SamAccountName){
    if($Email){
        $PrimarySMTP = $script:Email
        Write-Host " Primary address = $PrimarySMTP"
    if($PrimarySMTP -like "*@company.com"){
        $RemoteRoutingAddress = $PrimarySMTP -replace("@company.com","@company.mail.onmicrosoft.com")
        Write-Host " Remote Routing address = $RemoteRoutingAddress "
    }
    if($PrimarySMTP -like "*@2company.com"){
        $RemoteRoutingAddress = $PrimarySMTP -replace("@2company.com","@company.mail.onmicrosoft.com")
        Write-Host " Remote Routing address = $RemoteRoutingAddress "
    }
    if($script:RemoteMbxExists -like "no"){
        Write-Host "  Creating remote mailbox ! " -ForegroundColor Yellow
        Enable-RemoteMailbox -Identity $SamAccountName -PrimarySmtpAddress $PrimarySMTP -RemoteRoutingAddress $RemoteRoutingAddress
        Start-Sleep -s 2
        Set-RemoteMailbox -Identity $SamAccountName -EmailAddresses @{add=$RemoteRoutingAddress} 
        $RemoteMbx = Get-RemoteMailbox -Identity $SamAccountName
        if($RemoteMbx){
            $Subject = "Mailbox created for: " + "$SamAccountName" + "  " + "$PrimarySMTP"
            Send-MailMessage -Subject $Subject -From "Exchange_User_Mbx_Provisioning@company.com" -To "Rustam@company.com" -SmtpServer "hubsrv.company.com"
        }

    }
    if($script:RemoteMbxExists -like "yes"){
        Write-Host ""
    }
    }
    else{Write-Host " NO $email value given"}
}

#$ADUser = Get-ADUser $Alias -Properties Mail
if($CreateSingleUser){
    Write-Host ""
    CheckRemoteMailbox -SamAccountName $SamAccountName
    if($script:Email){
        CreateRemoteMailbox -Email $script:Email
    }
}
elseif($CreateMultipleUsers){
    Write-Host ""
    Write-Host "Getting all Cembra users..."
    $ADUsers_Cembra = Get-ADUser -SearchBase "OU=PF00_Personal,OU=PF00_Person,OU=PF00_User,OU=PF00,DC=cembraintra,DC=ch" -Filter * -Properties Mail,msExchRemoteRecipientType
    Write-Host "Getting all PFCU01 users..."
    $ADUsers_PFCU01 = Get-ADUser -SearchBase "OU=PFCU01_Personal,OU=PFCU01_Person,OU=PFCU01_User,OU=PFCU01,DC=cembraintra,DC=ch" -Filter * -Properties Mail,msExchRemoteRecipientType
    Write-Host "Getting all PFCU02 users..."
    $ADUsers_PFCU02 = Get-ADUser -SearchBase "OU=PFCU02_Personal,OU=PFCU02_Person,OU=PFCU02_User,OU=PFCU02,DC=cembraintra,DC=ch" -Filter * -Properties Mail,msExchRemoteRecipientType
    $ADUsers = $ADUsers_Cembra + $ADUsers_PFCU01 + $ADUsers_PFCU02
    Write-Host "Found "$ADUsers.count" number of users"
    $ADUsers_Mail = $ADUsers | Where-Object{$_.Mail -like "*@cembra*"}
    $ADUsers_Enabled = $ADUsers_Mail | Where-Object{$_.Enabled -like "True"}
    $ADUsers_ToProcess = $ADUsers_Enabled | Where-Object {$_.msExchRemoteRecipientType -notlike "1" -and $_.msExchRemoteRecipientType -notlike "4"}
    Write-Host "Found "$ADUsers_ToProcess.count" to proces for remote mailbox"
    Write-Host ""
    $ADUsers_ToProcess | ForEach-Object{
        CheckRemoteMailbox -SamAccountName $_.SamAccountName
        if($script:Email){CreateRemoteMailbox -SamAccountName $_.SamAccountName -Email $script:Email}
        #.\EnableRemoteMailbox_V2 -CreateSingleUser -SamAccountName $_.SamAccountName
        #Start-Sleep -s 1
    }
    
}
elseif($Test){
    Write-Host ""
    CheckRemoteMailbox -SamAccountName $SamAccountName
}
else{Write-Host "No parameter selection made !!" -ForegroundColor Red}

#$NoRemoteMailbox | Out-GridView
# $ADUsers = Get-ADUser -SearchBase "OU=PF00_Personal,OU=PF00_Person,OU=PF00_User,OU=PF00,DC=cembraintra,DC=ch" -Filter * -Properties Mail,msExchRemoteRecipientType
# $ADUsers_Mail = $ADUsers | Where-Object{$_.Mail -like "*@*cembra*"}
# $ADUsers_Enabled = $ADUsers_Mail | Where-Object{$_.Enabled -like "True"}
# $ADUsers_Enabled | Where-Object {$_.msExchRemoteRecipientType -notlike "1" -and $_.msExchRemoteRecipientType -notlike "4"}

if($PathTranscript){
    Stop-Transcript
    Send-MailMessage -Priority Low -Subject "User Mbx Provisioning has ran" -From "Exchange_User_Mbx_Provisioning@company.com" -To "steven.provo@company.com" -SmtpServer "hubsrv.company.com" -Attachments $PathTranscript
}
