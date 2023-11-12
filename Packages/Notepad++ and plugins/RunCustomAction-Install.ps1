Set-location ".\NotepadPlusPlusplugins (64-bit)"
#Install
#.\Deploy-Application.exe -DeploymentType Install -DeployMode Silent -AllowRebootPassThru
.\Deploy-Application.exe -DeploymentType Install -DeployMode Interactive -AllowRebootPassThru

#uninstall
#.\Deploy-Application.exe -DeploymentType Uninstall -DeployMode Silent -AllowRebootPassThru
#.\Deploy-Application.exe -DeploymentType Uninstall -DeployMode Interactive -AllowRebootPassThru