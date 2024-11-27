c:
cd \
md VPNtest

ping tscb01 >>c:\VPNtest\tscb01.txt
ping 192.168.209.7 >>c:\VPNtest\tscb01-IP.txt

ping ts >>c:\VPNtest\ts.txt

ping ts10 >>c:\VPNtest\ts10.txt
ping ts11 >>c:\VPNtest\ts11.txt
ping ts12 >>c:\VPNtest\ts12.txt
ping ts13 >>c:\VPNtest\ts13.txt
ping ts14 >>c:\VPNtest\ts14.txt
ping ts15 >>c:\VPNtest\ts15.txt


ping 192.168.209.9 >>c:\VPNtest\ts10-ip.txt
ping 192.168.209.183 >>c:\VPNtest\ts11-ip.txt
ping 192.168.209.64 >>c:\VPNtest\ts12-ip.txt
ping 192.168.209.77 >>c:\VPNtest\ts13-ip.txt
ping 192.168.209.56 >>c:\VPNtest\ts14-ip.txt
ping 192.168.209.185 >>c:\VPNtest\ts15-ip.txt

ipconfig /all >>c:\VPNtest\ipconfig-all.txt
