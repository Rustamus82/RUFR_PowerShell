#https://www.jesusninoc.com/01/29/sendkeys-method/
#Set-ExecutionPolicy -Scope LocalMachine RemoteSigned


while (1) {
 
    [System.Windows.Forms.SendKeys]::SendWait("^{F8}")
    Sleep 60
}
 