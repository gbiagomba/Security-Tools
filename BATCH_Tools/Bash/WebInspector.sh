# Author: Gilles Biagomba
# Program:Web Inspector
# Description: This script is designed to automate the earlier phases.\n
#              of a web application assessment (specficailly recon).\n

#Declaring variables
pth=$(pwd)
TodaysDAY=$(date +%m-%d)
TodaysYEAR=$(date +%Y)
wrkpth="$pth/$TodaysYEAR/$TodaysDAY"

Setting Envrionment
mkdir -p  $wrkpth/Halberd/ $wrkpth/Sublist3r/ $wrkpth/Harvester $wrkpth/Metagoofil
mkdir -p $wrkpth/Nikto/ $wrkpth/Dirb/ $wrkpth/Nmap/ $wrkpth/Sniper/
mkdir -p $wrkpth/Masscan/

# Checking dependencies - halberd, sublist3r, theharvester, metagoofil, nikto, dirb, nmap, sn1per
if [ "halberd" != "$(ls /usr/local/bin/ | grep halberd)" ]; then
    cd /opt/
    git clone https://github.com/jmbr/halberd
    cd halberd
    python setup.py install
fi

if [ "sublist3r" != "$(ls /usr/bin/ | grep sublist3r)" ]; then
    apt install sublist3r -y
fi

if [ "theharvester" != "$(ls /usr/bin/ | grep theharvester)" ]; then
    apt install theharvester -y
fi

if [ "metagoofil" != "$(ls /usr/bin/ | grep metagoofil)" ]; then
    apt install metagoofil -y
fi

if [ "nikto" != "$(ls /usr/bin/ | grep nikto)" ]; then
    apt install nikto -y
fi

if [ "dirb" != "$(ls /usr/bin/ | grep dirb)" ]; then
    apt install dirb -y
fi

if [ "nmap" != "$(ls /usr/bin/ | grep nmap)" ]; then
    apt install nmap -y
fi

if [ "sniper" != "$(ls /usr/bin/ | grep sniper)" ]; then
    cd /opt/
    git clone https://github.com/1N3/Sn1per
    cd Sn1per
    bash install,sh
fi

if [ "masscan" != "$(ls /usr/bin/ | grep masscan)" ]; then
    apt install masscan -y
fi

# Moving back to original workspace
clear
cd $pth

# Requesting target file name & moving to work space
echo "What is the name of the targets file? The file with all the IP addresses or sites"
read targets

if [ "$targets" == "$(ls $pth/$targets)" ]; then
    cp $targets $wrkpth/
else
    echo "FIle not found! Try again!"
fi

# Using halberd
halberd -u $targets -o 