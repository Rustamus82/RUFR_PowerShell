function reconnect-Exchange2016SST {
    try {
    
            Write-Host "Reconnecting to Exchange 2016 SST" -foregroundcolor Cyan 
            Get-PSSession  | Where-Object{$_.ComputerName -like "s-exc-mbx0*"} | Remove-PSSession -ErrorAction SilentlyContinue
            $Global:SessionExchangeSST = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://s-exc-mbx02-p/PowerShell/ -Authentication Kerberos -Credential $Global:UserCredSST -ErrorAction Stop
                
    }
    catch {
    
            Write-Host "Reconnecting to Exchange 2016 SST" -foregroundcolor Cyan 
            Get-PSSession  | Where-Object{$_.ComputerName -like "s-exc-mbx0*"} | Remove-PSSession -ErrorAction SilentlyContinue
            $Global:SessionExchangeSST = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://s-exc-mbx03-p/PowerShell/ -Authentication Kerberos -Credential $Global:UserCredSST -ErrorAction Continue
    
    }
    
    try {
            Import-PSSession $Global:SessionExchangeSST -Prefix SST -ErrorAction stop
    }
    catch {
            Write-Warning "Could not connect to SST exchange 2016 servers"
            Pause 
            #return
    }
}