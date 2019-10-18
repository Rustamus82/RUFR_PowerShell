#PSVersion 5 Script made/assembled by Rust@m 19-09-2019
<#Login RUFR all AD login, Hybrid and o365
$CommandPath = (Get-Location).Path | Split-Path -Parent|Split-Path -Parent; $script = "$CommandPath\Logins\Login_SSI_SST_exch2010_DKSUND_Exchange365_RUFR.ps1"; & $script; 
$WorkingDir = Convert-Path .

# Change to correct Psdriver path
#Get-PSDrive
Set-Location -Path 'SSIAD:' 
Set-Location -Path 'SSTAD:'
Set-Location -Path 'DKSUNDAD:'

#error handling - https://www.gngrninja.com/script-ninja/2016/6/5/powershell-getting-started-part-11-error-handling
$Error[0]| gm
$Error[0].InvocationInfo.Line
$error[0].Exception | Get-Member

cls
#>

#Get-ADUser 883| Set-ADUser -Manager adm-rufr -Description "RUFR test, skal slettes" -Credential $Global:UserCredDksund

## mass update $collection
#Get content from file nee to set location where the source files is
$stampDate = Get-Date -Format “yyyy/MM/dd”
$log = $stampDate+"_log.txt"
$WorkingDir = Convert-Path . ;$log = "$WorkingDir\$log"
$AdUsers = Import-CSV "$WorkingDir\STPKfællespostkassermedansvarlig.CSV" -Delimiter ";" -Encoding UTF8

$AdUsers.Dksundalias
$AdUsers.Description
$AdUsers.Ejer
$Prefix = "STPK_"
$Postfix = "_Mail"
$Company = "STYRELSEN FOR PATIENTKLAGER"
$AT = '@stpk.dk'
#dksund.dk/Organisationer/STPK/Grupper/
$GroupsOUPath = 'OU=Grupper,OU=STPK,OU=Organisationer,DC=dksund,DC=dk'

cls

Set-Location -Path 'DKSUNDAD:'
foreach ($AdUser in $AdUsers)
{
        
    #Add members 
    "$('[{0:yyyy/mm/dd} {0:HH:mm:ss}]' -f (Get-Date)) retriving AD object, Creating goups for each & updating Description and Owner in AD: {0} " -f $AdUser.Dksundalias| Out-File $log  -Append
                
        try
        {
            Get-ADUser $AdUser.Dksundalias | Set-ADUser -Manager $AdUser.Ejer -Description $AdUser.Description -Company $Company -Credential $Global:UserCredDksund -ErrorAction Stop
            Get-ADUser $AdUser.Dksundalias | Set-ADUser -Description $AdUser.Description -Credential $Global:UserCredDksund -ErrorAction Stop

            if ([bool](Get-ADUser $AdUser.Dksundalias))
            {
                
                $ADgroup = $Prefix+$AdUser.Dksundalias+$Postfix
                $Alias = $AdUser.Dksundalias
                
                New-ADGroup -Name $ADgroup -GroupScope Universal -GroupCategory Security -ManagedBy $AdUser.Ejer -Description "Giver fuld adgang til Fællespotskasse - $Alias" -Path $GroupsOUPath -ErrorAction SilentlyContinue
                Write-Host "TimeOut for 20 sek." -foregroundcolor Yellow 
                sleep 20

                Write-Host "Opdaterer 'Company' felt og tilføje  email adresse til gruppen" -foregroundcolor Cyan
                $GroupMail = $ADgroup+$AT
                Set-ADGroup -Identity $ADgroup -Add @{company="$Company";mail="$GroupMail"}
                Add-ADGroupMember -Identity $ADgroup -Members $AdUser.Ejer

                Enable-SSIDistributionGroup -Identity $ADgroup
                #Disable-SSIDistributionGroup -Identity $ADgroup
                Set-SSIDistributionGroup $ADgroup -PrimarySMTPAddress $GroupMail -EmailAddressPolicyEnabled $true
                Get-SSIMailbox -Identity $AdUser.Dksundalias | Add-SSIMailboxPermission -User $ADgroup -AccessRights FullAccess -InheritanceType All
                Add-SSIADPermission -Identity $AdUser.Dksundalias -User $ADgroup -AccessRights ExtendedRight  -ExtendedRights "Send As"
                #Can not be virified in ECP on MailBoxes that does not have licens - https://community.dynamics.com/crm/b/crmchap/posts/grant-send-on-behalf-permissions-for-shared-mailbox-exchange-online
                Set-SSIMailbox -Identity $AdUser.Dksundalias -GrantSendOnBehalfTo @{Add="$ADgroup"}
                
                #Mssing exchnage premission for AD on the OU at the moment - Nu virker på STPK OU - https://support.microsoft.com/en-us/help/2983209/access-denied-when-you-try-to-give-user-send-as-or-receive-as-permissi 
                Add-SSIADPermission -Identity $ADgroup -User $AdUser.Dksundalias -AccessRights WriteProperty -Properties "Member"         
                  
            }

            
                        
        }
        catch
        {
            $Error.Exception.Message | Out-File $log  -Append
            
        }       
}




