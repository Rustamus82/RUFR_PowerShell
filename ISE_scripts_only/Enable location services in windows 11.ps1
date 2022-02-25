#Enable location services in windows 11:
Set-ItemProperty -Path 'HKLM:\\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location' -name "Value" -value 'Allow'