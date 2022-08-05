# Test-Port helper function
function Test-Port($hostname, $port)
{
    $status = ""
    $returnObject = New-Object -TypeName PSObject    
    # This works no matter in which form we get $host - hostname or ip address
    try {
        
        $ip = [System.Net.Dns]::GetHostAddresses($hostname) | 
            select-object IPAddressToString -expandproperty  IPAddressToString
        if($ip.GetType().Name -eq "Object[]")
        {
            #If we have several ip's for that address, let's take first one
            $ip = $ip[0]                 
        }
        $returnObject | Add-Member -MemberType NoteProperty -name "IP" -value $ip
    } catch {
        return "Possibly $hostname is wrong hostname or IP"        
    }
    $t = New-Object Net.Sockets.TcpClient
    # We use Try\Catch to remove exception info from console if we can't connect
    try
    {
        $t.Connect($ip,$port)
        $CurPort=$port

    } catch {}

    if($t.Connected)
    {
        $t.Close()
        $msg = "open"        
    }
    else
    {
        $msg = "*closed*"        
    }
    $returnObject | Add-Member -MemberType NoteProperty -name "msg" -value $msg
    return $returnObject

}

Function WriteFile 
{
               $newOutputObject = New-Object -TypeName PSObject    
  
        $newOutputObject | Add-Member -MemberType NoteProperty -name "Maskine ip" -value $testip
        $newOutputObject | Add-Member -MemberType NoteProperty -name "Address" -value $Url
        $newOutputObject | Add-Member -MemberType NoteProperty -name "IP" -value $statObject.IP       
        $newOutputObject | Add-Member -MemberType NoteProperty -name "Port" -value $CurPort
        
        $newOutputObject | Add-Member -MemberType NoteProperty -name "Result" -value $statObject.msg
        $newOutputObject | Add-Member -MemberType NoteProperty -name "TimeStamp" -value "$(Get-Date)"
        
        $outputCSVData += $newOutputObject
        $outputCSVData | Export-Csv $OutputCSV -Delimiter ";" -Encoding UTF8 -NoTypeInformation -append      
}

Test-Port s-exc-hyb-01p.dksund.dk 443
Test-Port s-exc-hyb-02p.dksund.dk 443