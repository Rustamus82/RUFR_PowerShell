Suspend-BitLocker -MountPoint "$env:SystemDrive" -RebootCount 1
& shutdown -r -f -t 15 -c "Genstarter PC. Udsætte bitlcoker en enkelt gang,  maks 15 gange, og så vil man bliver promptet for Bitlocker."
& shutdown -a
pause
