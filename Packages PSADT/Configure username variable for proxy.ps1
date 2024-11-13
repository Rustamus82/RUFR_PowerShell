$UserPass = Read-Host "Please enter password" -AsSecureString
[System.Environment]::SetEnvironmentVariable('HTTP_PROXY',"http://{replace by SSO}:$(ConvertFrom-SecureString -SecureString $UserPass -AsPlainText)@proxyserver.company.com:8080", 'User')
[System.Environment]::SetEnvironmentVariable('http_proxy',"http://{replace by SSO}:$(ConvertFrom-SecureString -SecureString $UserPass -AsPlainText)@proxyserver.company.com:8080", 'User')
 
[System.Environment]::SetEnvironmentVariable('HTTPS_PROXY',"http://{replace by SSO}:$(ConvertFrom-SecureString -SecureString $UserPass -AsPlainText)@proxyserver.company.com:8080", 'User')
[System.Environment]::SetEnvironmentVariable('https_proxy',"http://{replace by SSO}:$(ConvertFrom-SecureString -SecureString $UserPass -AsPlainText)@proxyserver.company.com:8080", 'User')
 
[System.Environment]::SetEnvironmentVariable('FTP_PROXY',"http://{replace by SSO}:$(ConvertFrom-SecureString -SecureString $UserPass -AsPlainText)@proxyserver.company.com:8080", 'User')
[System.Environment]::SetEnvironmentVariable('ftp_proxy',"http://{replace by SSO}:$(ConvertFrom-SecureString -SecureString $UserPass -AsPlainText)@proxyserver.company.com:8080", 'User')
 
[System.Environment]::SetEnvironmentVariable('NO_PROXY',"localhost,127.0.0.1,localaddress,.domain.com,.local.domain.net,.docker.internal", 'User')
[System.Environment]::SetEnvironmentVariable('no_proxy',"localhost,127.0.0.1,localaddress,.domain.com,.local.domain.net,.docker.internal", 'User')
 
[System.Environment]::SetEnvironmentVariable('ALL_PROXY',"http://{replace by SSO}:$(ConvertFrom-SecureString -SecureString $UserPass -AsPlainText)@proxyserver.company.com:8080", 'User')
[System.Environment]::SetEnvironmentVariable('all_proxy',"http://{replace by SSO}:$(ConvertFrom-SecureString -SecureString $UserPass -AsPlainText)@proxyserver.company.com:8080", 'User')
 
#run it in Powershell 7


##########

#[System.Net.WebRequest]::DefaultWebProxy.Credentials = [System.Net.CredentialCache]::DefaultCredentials 
<#
does the following:

[System.Net.WebRequest]::DefaultWebProxy: This part retrieves the default proxy settings that are configured on the machine. This is typically the proxy settings that are configured in the system's network settings, such as those used by Internet Explorer or Windows proxy settings.

.Credentials: The Credentials property of the proxy is used to specify the credentials (username and password) that the proxy will use to authenticate.

[System.Net.CredentialCache]::DefaultCredentials: This is a special value that represents the default credentials of the currently logged-in Windows user. In essence, this allows the system to use the credentials (username and password) of the user currently logged into the machine.

What it does:
The command configures the default proxy on the machine to use the credentials of the currently logged-in user for authentication when making network requests. This is commonly used in environments where a proxy requires authentication, and you want to use the Windows credentials of the current user to authenticate without needing to manually specify the username and password.

In practical terms:

If your system is behind a proxy that requires authentication, this command will automatically use the logged-in user's credentials for any web request that goes through the proxy. This can be useful in corporate or enterprise environments where proxies and network authentication are common.


does not need to be run as an administrator. It can be executed by a regular user because:

Default Proxy Settings: The command is only modifying the proxy credentials for the current session of the PowerShell process. It is not making any system-wide changes to network settings or proxy configurations.

Current User's Credentials: The command uses the credentials of the currently logged-in user ([System.Net.CredentialCache]::DefaultCredentials), which means it works within the context of that user's session. It doesn't require elevated privileges to access the user's credentials.

Key Points:
No admin privileges required: This command operates at the user level, and as such, it can be run without administrative rights.
Temporary change: The command only affects the current PowerShell session, not the entire system or other users.
In summary, a regular user can execute this command without needing elevated (administrator) privileges.
#>

 