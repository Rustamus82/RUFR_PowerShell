#Requires -Version 5
#Requires -Modules ActiveDirectory
#Requires -Modules ConfigurationManager


param(
    # Sets the cutoff for the cleanup date in hole months
    [Parameter(Mandatory=$false)]
    [Byte]$Month = 3,
    # Sets the path where the log files are saved
    [Parameter(Mandatory=$false)]
    [ValidateScript({Test-Path -Path "$_" -PathType 'Container'})]
    [string]$LogPath = "$env:TEMP"
)


Import-Module -Name ActiveDirectory
$daysago = [datetime]::new(([datetime]::Today.AddMonths(-($Month)).Year), ([datetime]::Today.AddMonths(-($Month)).Month), 1)
$now = [datetime]::Now.ToString('yyyyMMddHHmmss')


#SST.DK credentials
$SSTcreds = Get-Credential -Message 'Angiv adm-konto til SST.DK domænet' sst.dk\adm-rufr
$SSTDomainController = (Get-ADDomainController -DomainName 'SST.DK' -Discover).HostName[-1]
if (-not ((Test-NetConnection -ComputerName $SSTDomainController -Port 389).TcpTestSucceeded)) { return 1 }


#SSI.AD credentials
$SSICreds = Get-Credential -Message 'Angiv adm-konto til SSI.AD domænet' ssi\adm-rufr
$SSIDomainController = (Get-ADDomainController -DomainName 'SSI.AD' -Discover).HostName[-1]
if (-not ((Test-NetConnection -ComputerName $SSIDomainController -Port 389).TcpTestSucceeded)) { return 1 }


#SSI.AD credentials
$DKSUNDCreds = Get-Credential -Message 'Angiv adm-konto til DKSUND.DK domænet' dksund\adm-rufr
$DKSUNDDomainController = (Get-ADDomainController -DomainName 'DKSUND.DK' -Discover).HostName[-1]
if (-not ((Test-NetConnection -ComputerName $DKSUNDDomainController -Port 389).TcpTestSucceeded)) { return 1 }


#SST.DK Old Computers
Get-ADComputer -Filter {Enabled -eq $true -and OperatingSystem -notlike '*server*' -and PasswordLastSet -lt $daysago -and LastLogonTimeStamp -lt $daysago} -Properties OperatingSystem,PwdLastSet,LastLogonTimeStamp -Server $SSTDomainController |
    Select-Object -Property Name, DistinguishedName, @{Name="PasswordLastSet";Expression={[datetime]::FromFileTime($_.PwdLastSet)}}, @{Name="LastLogontimeStamp";Expression={[datetime]::FromFileTime($_.LastLogonTimeStamp)}} |
    Export-Csv -LiteralPath "$LogPath\SST_OldPcs_$($Now).csv" -Force -Encoding UTF8 -Delimiter ';' -NoTypeInformation


Get-ADComputer -Filter {Enabled -eq $true -and OperatingSystem -like '*server*' -and PasswordLastSet -lt $daysago -and LastLogonTimeStamp -lt $daysago} -Properties OperatingSystem,PwdLastSet,LastLogonTimeStamp -Server $SSTDomainController |
    Select-Object -Property Name, DistinguishedName, @{Name="PasswordLastSet";Expression={[datetime]::FromFileTime($_.PwdLastSet)}}, @{Name="LastLogontimeStamp";Expression={[datetime]::FromFileTime($_.LastLogonTimeStamp)}} |
    Export-Csv -LiteralPath "$LogPath\SST_OldServers_$($now).csv" -Force -Encoding UTF8 -Delimiter ';' -NoTypeInformation


#SSI.AD Old Computers
Get-ADComputer -Filter {Enabled -eq $true -and OperatingSystem -notlike '*server*' -and PasswordLastSet -lt $daysago -and LastLogonTimeStamp -lt $daysago} -Properties OperatingSystem,PwdLastSet,LastLogonTimeStamp -Server $SSIDomainController |
    Select-Object -Property Name, DistinguishedName, @{Name="PasswordLastSet";Expression={[datetime]::FromFileTime($_.PwdLastSet)}}, @{Name="LastLogontimeStamp";Expression={[datetime]::FromFileTime($_.LastLogonTimeStamp)}} |
    Export-Csv -LiteralPath "$LogPath\SSI_OldPcs_$($now).csv" -Force -Encoding UTF8 -Delimiter ';' -NoTypeInformation


Get-ADComputer -Filter {Enabled -eq $true -and OperatingSystem -like '*server*' -and PasswordLastSet -lt $daysago -and LastLogonTimeStamp -lt $daysago} -Properties OperatingSystem,PwdLastSet,LastLogonTimeStamp -Server $SSIDomainController |
    Select-Object -Property Name, DistinguishedName, @{Name="PasswordLastSet";Expression={[datetime]::FromFileTime($_.PwdLastSet)}}, @{Name="LastLogontimeStamp";Expression={[datetime]::FromFileTime($_.LastLogonTimeStamp)}} |
    Export-Csv -LiteralPath "$LogPath\SSI_OldServers_$($now).csv" -Force -Encoding UTF8 -Delimiter ';' -NoTypeInformation


#DKSUND.DK Old Computers
Get-ADComputer -Filter {Enabled -eq $true -and OperatingSystem -notlike '*server*' -and PasswordLastSet -lt $daysago -and LastLogonTimeStamp -lt $daysago} -Properties OperatingSystem,PwdLastSet,LastLogonTimeStamp -Server $DKSUNDDomainController |
    Select-Object -Property Name, DistinguishedName, @{Name="PasswordLastSet";Expression={[datetime]::FromFileTime($_.PwdLastSet)}}, @{Name="LastLogontimeStamp";Expression={[datetime]::FromFileTime($_.LastLogonTimeStamp)}} |
    Export-Csv -LiteralPath "$LogPath\DKSUND_OldPcs_$($now).csv" -Force -Encoding UTF8 -Delimiter ';' -NoTypeInformation


Get-ADComputer -Filter {Enabled -eq $true -and OperatingSystem -like '*server*' -and PasswordLastSet -lt $daysago -and LastLogonTimeStamp -lt $daysago} -Properties OperatingSystem,PwdLastSet,LastLogonTimeStamp -Server $DKSUNDDomainController |
    Select-Object -Property Name, DistinguishedName, @{Name="PasswordLastSet";Expression={[datetime]::FromFileTime($_.PwdLastSet)}}, @{Name="LastLogontimeStamp";Expression={[datetime]::FromFileTime($_.LastLogonTimeStamp)}} |
    Export-Csv -LiteralPath "$LogPath\DKSUND_OldServers_$($now).csv" -Force -Encoding UTF8 -Delimiter ';' -NoTypeInformation


#Cleanup in ActiveDirectory
#SST.DK
Get-ADComputer -Filter {Enabled -eq $true -and OperatingSystem -notlike '*server*' -and PasswordLastSet -lt $daysago -and LastLogonTimeStamp -lt $daysago} -Properties OperatingSystem,PwdLastSet,LastLogonTimeStamp -Server $SSTDomainController |
    Set-ADComputer -Server $SSTDomainController -Enabled $false -Credential $SSTcreds -PassThru |
    Move-ADObject -Server $SSTDomainController -Credential $SSTcreds -TargetPath 'OU=Disabled computers,DC=sst,DC=dk'


#SSI.AD
Get-ADComputer -Filter {Enabled -eq $true -and OperatingSystem -notlike '*server*' -and PasswordLastSet -lt $daysago -and LastLogonTimeStamp -lt $daysago} -Properties OperatingSystem,PwdLastSet,LastLogonTimeStamp -Server $SSIDomainController |
    Set-ADComputer -Server $SSIDomainController -Enabled $false -Credential $SSICreds -PassThru |
    Move-ADObject -Server $SSIDomainController -Credential $SSICreds -TargetPath 'OU=Disabled computers,DC=ssi,DC=ad'


#SSI.AD
Get-ADComputer -Filter {Enabled -eq $true -and OperatingSystem -notlike '*server*' -and PasswordLastSet -lt $daysago -and LastLogonTimeStamp -lt $daysago} -Properties OperatingSystem,PwdLastSet,LastLogonTimeStamp -Server $DKSUNDDomainController |
    Set-ADComputer -Server $DKSUNDDomainController -Enabled $false -Credential $DKSUNDCreds -PassThru |
    Move-ADObject -Server $DKSUNDDomainController -Credential $DKSUNDCreds -TargetPath 'OU=Disabled computers,DC=dksund,DC=dk'


#Cleanup in ConfigMgr
Import-Module -Name (Join-Path -Path (Split-path -Path "$env:SMS_ADMIN_UI_PATH" -Parent) -ChildPath 'ConfigurationManager.psd1' -Resolve) -Force
Set-Location -Path ((Get-PSDrive -PSProvider 'CMSite' | Select-Object -ExpandProperty Name) + ':')


$Objects = Get-Content -Path "$LogPath\SST_OldPcs_$($Now).csv", "$LogPath\SSI_OldPcs_$($now).csv", "$LogPath\DKSUND_OldPcs_$($now).csv" |
    ConvertFrom-Csv -Delimiter ';'


for ($i = 0; $i -lt $Objects.Count; $i++) {
    Write-Progress -Activity 'Cleanup computerobjects in ConfigMgr' -Status $('{0:P1} : Complete:' -f $($i/$Objects.Count)) -PercentComplete $($i/($Objects.Count)*100) -CurrentOperation $('Removing computer object "{0}"' -f $Objects[$i].Name)
    Get-CMDevice -Name $($Objects[$i].Name) -CollectionId SMS00001 -Fast |
        Remove-CMDevice -Force
}
Write-Progress -Activity 'Cleanup computerobjects in ConfigMgr' -Completed


#Cleanup Variables
Clear-Variable -Name 'SSTcreds' | Remove-Variable -force
Clear-Variable -Name 'SSICreds' | Remove-Variable -Force
Clear-Variable -Name 'DKSUNDCreds' | Remove-Variable -Force