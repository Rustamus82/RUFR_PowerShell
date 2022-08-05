<# https://portal.fischerkerrn.com/concierge-booking/technical-papers/support-for-tls-on-concierge-client-and-server-modules/
SUPPORT FOR TLS ON CONCIERGE CLIENT AND SERVER MODULES
TLS (Transport Layer Security) is the encryption used to secure communication between a client and the server over the internet. Microsoft is working towards eliminating TLS 1.0 and 1.1 as they as not as “strong” as TLS 1.2. This means that all applications targeting Office 365 must support TLS 1.2, and it documented in this Microsoft article. All Concierge modules have had support for TLS 1.2 since ver. 2.20.1202, released 2020-05-04.

Enable TLS 1.2
In Concierge support for TLS 1.2 is provided through the .NET 4.7.2 layer in the application modules. Enabling the use of TLS 1.2 can be switched on/off through the OS, and can be controlled in different ways. This Microsoft article documents how to switch a workstation/Server to enable TLS 1.2 for all .NET applications

Please note that the support for TLS 1.2 is covered by Concierge 2.20.1202 and later versions

Enable TLS 1.2 support as a machine-wide default protocol by setting the following Key:
#>

#32 bit:
if(Test-Path -Path 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\.NETFramework\v4.0.30319\') {
   
   #PSADT
   #Set-RegistryKey -Key 'HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\.NETFramework\v4.0.30319\' -Name 'SystemDefaultTlsVersions' -Value '00000001' -Type DWord
   #Set-RegistryKey -Key 'HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\.NETFramework\v4.0.30319\' -Name 'SchUseStrongCrypto' -Value '00000001' -Type DWord
   
   #Native
   #New-Item -Path 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\.NETFramework\v4.0.30319\'
   #New-ItemProperty -Path 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\.NETFramework\v4.0.30319\' -Name 'SystemDefaultTlsVersions' -Value '00000001' -type
   #Set-ItemProperty -Path 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\.NETFramework\v4.0.30319\' -Name 'SystemDefaultTlsVersions' -Value '00000001' -Type "DWord"
   
   New-ItemProperty -Path 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\.NETFramework\v4.0.30319\' -Name 'SystemDefaultTlsVersions' -Value '00000001' -PropertyType "DWord"
   New-ItemProperty -Path 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\.NETFramework\v4.0.30319\' -Name 'SchUseStrongCrypto' -Value '00000001' -PropertyType "DWord"

}


#64 bit:
if(Test-Path -Path 'HKLM:\SOFTWARE\Microsoft\.NETFramework\v4.0.30319\') {
   
   #PSADT
   #Set-RegistryKey -Key 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\.NETFramework\v4.0.30319\' -Name 'SystemDefaultTlsVersions' -Value '00000001' -Type DWord
   #Set-RegistryKey -Key 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\.NETFramework\v4.0.30319\' -Name 'SchUseStrongCrypto' -Value '00000001' -Type DWord

   #Native
   #New-Item -Path 'HKLM:\SOFTWARE\Microsoft\.NETFramework\v4.0.30319\'
   New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\.NETFramework\v4.0.30319\' -Name 'SystemDefaultTlsVersions' -Value '00000001' -PropertyType "DWord"
   New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\.NETFramework\v4.0.30319\' -Name 'SchUseStrongCrypto' -Value '00000001' -PropertyType "DWord"
}
