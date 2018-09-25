# Checking dependencies - nmap, masscan, zip
if [ "nmap" != "$(ls /usr/bin/nmap)" ]; then
    apt install nmap -y
fi

if [ "masscan" != "$(ls /usr/bin/masscan)" ]; then
    apt install masscan -y
fi

if [ "zip" != "$(ls /usr/bin/zip)" ]; then
    apt install zip -y
fi
