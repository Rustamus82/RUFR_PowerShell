Set-location ".\TeamViewer Meeting Outlook Addin Removal v1.0.1"
#Install
#.\Deploy-Application.exe -DeploymentType Install -DeployMode Silent -AllowRebootPassThru
.\Deploy-Application.exe -DeploymentType Install -DeployMode Interactive -AllowRebootPassThru

#uninstall
#.\Deploy-Application.exe -DeploymentType Uninstall -DeployMode Silent -AllowRebootPassThru
#.\Deploy-Application.exe -DeploymentType Uninstall -DeployMode Interactive -AllowRebootPassThru