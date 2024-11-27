#Requires -Version 2

function Get-NameFromSID {
    [CmdletBinding()]
    [Alias()]
    [OutputType([string])]
    Param (
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, Position=0)]
        [ValidatePattern('^S-\d-(\d+-){1,14}\d+$')]
        [string]$SID
    )

    Begin {}
    Process {
        try {
            $objSID = New-Object System.Security.Principal.SecurityIdentifier("$SID")
            $objNTAccount = $objSID.Translate( [System.Security.Principal.NTAccount])
        } Catch [System.Management.Automation.MethodInvocationException] {
            Write-Error -Exception $Error[0].Exception
            return ''
        } Catch {
            Write-Error -Exception $Error[0].Exception
            Break
        }
        $Name = ($objNTAccount.Value).Split("\")[1]
        Return $Name
    }
    End {}
}

[string]$ComputerName = $env:COMPUTERNAME

$Group = Get-NameFromSID -SID 'S-1-5-32-544'
$User = Get-NameFromSID -SID 'S-1-5-4'

$objGroup = [ADSI]("WinNT://$ComputerName/$Group, group")

$Members = @($objGroup.PSBase.Invoke("Members"))
ForEach ($Member In $Members) { 
    $Name = $Member.GetType().InvokeMember("Name", 'GetProperty', $Null, $Member, $Null) 
    If ($Name -eq $user) {
        $p = $Member.GetType().InvokeMember("AdsPath", 'GetProperty', $Null, $Member, $Null)
        $objGroup.PSBase.Invoke("Remove", $p)
    } Else {
        Continue
    }
} 
