$UserPass = Read-Host "Please enter password" -AsSecureString
[System.Environment]::SetEnvironmentVariable('HTTP_PROXY',"http://{replace by SSO}:$(ConvertFrom-SecureString -SecureString $UserPass -AsPlainText)@server.company.com:8080", 'User')
[System.Environment]::SetEnvironmentVariable('http_proxy',"http://{replace by SSO}:$(ConvertFrom-SecureString -SecureString $UserPass -AsPlainText)@server.company.com:8080", 'User')
 
[System.Environment]::SetEnvironmentVariable('HTTPS_PROXY',"http://{replace by SSO}:$(ConvertFrom-SecureString -SecureString $UserPass -AsPlainText)@server.company.com:8080", 'User')
[System.Environment]::SetEnvironmentVariable('https_proxy',"http://{replace by SSO}:$(ConvertFrom-SecureString -SecureString $UserPass -AsPlainText)@server.company.com:8080", 'User')
 
[System.Environment]::SetEnvironmentVariable('FTP_PROXY',"http://{replace by SSO}:$(ConvertFrom-SecureString -SecureString $UserPass -AsPlainText)@server.company.com:8080", 'User')
[System.Environment]::SetEnvironmentVariable('ftp_proxy',"http://{replace by SSO}:$(ConvertFrom-SecureString -SecureString $UserPass -AsPlainText)@server.company.com:8080", 'User')
 
[System.Environment]::SetEnvironmentVariable('NO_PROXY',"localhost,127.0.0.1,localaddress,.cembraintra.ch,.local.byjunoag.net,.docker.internal", 'User')
[System.Environment]::SetEnvironmentVariable('no_proxy',"localhost,127.0.0.1,localaddress,.cembraintra.ch,.local.byjunoag.net,.docker.internal", 'User')
 
[System.Environment]::SetEnvironmentVariable('ALL_PROXY',"http://{replace by SSO}:$(ConvertFrom-SecureString -SecureString $UserPass -AsPlainText)@server.company.com:8080", 'User')
[System.Environment]::SetEnvironmentVariable('all_proxy',"http://{replace by SSO}:$(ConvertFrom-SecureString -SecureString $UserPass -AsPlainText)@server.company.com:8080", 'User')
 
 
#run it in Powershell 7
 