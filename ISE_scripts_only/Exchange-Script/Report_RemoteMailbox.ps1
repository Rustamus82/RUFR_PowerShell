$RemoteMbxs = Get-RemoteMailbox -ResultSize Unlimited

$Results=@()
$RemoteMbxs | ForEach-Object{
    $Record= New-Object System.Object
    Write-Host ""$_.samaccountname""
    $RR = $_.RemoteRoutingAddress.smtpaddress
    if($_.EmailAddresses.smtpaddress -like $RR){
        #Write-Host " True"
        $Match = "yes"
    }
    else{
        Write-Host " NO" -ForegroundColor Yellow
        Set-RemoteMailbox -Identity $_.SamAccountName -EmailAddresses @{add=$RR}
        Start-Sleep -s 1
        $Match = "no"
    }
    $Record | Add-Member -MemberType NoteProperty -Name SamAccountName -Value $_.SamAccountName
    $Record | Add-Member -MemberType NoteProperty -Name DisplayName -Value $_.DisplayName
    $Record | Add-Member -MemberType NoteProperty -Name PrimSMTP -Value $_.PrimarySmtpAddress
    $Record | Add-Member -MemberType NoteProperty -Name RemoteRouting -Value $_.RemoteRoutingAddress
    $Record | Add-Member -MemberType NoteProperty -Name SMTP -Value $SMTP.ProxyAddressString
    $Record | Add-Member -MemberType NoteProperty -Name Match -Value $Match
    $Results += $Record
}
$Results | Out-GridView