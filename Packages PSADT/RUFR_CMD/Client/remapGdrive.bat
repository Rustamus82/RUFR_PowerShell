@ECHO OFF
echo y| net use G: /delete
net use G: %homeshare% /home
echo n| gpupdate /force
