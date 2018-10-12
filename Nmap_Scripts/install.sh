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

# Installing the vulners nse script
cd /opt/
git clone https://github.com/vulnersCom/nmap-vulners
cd vulners/
cp vulners.nse /usr/share/nmap/scripts/

# Installing the Halcyon IDE
apt-get install ant default-jre -y
cd /opt/
git clone https://github.com/s4n7h0/Halcyon
cd Halcyon/
ant
java -cp /opt/Halcyon/src/lib/autocomplete.jar:/opt/Halcyon/src/lib/rsyntaxtextarea.jar:/opt/Halcyon/dist/Halcyon_IDE_v2.0.1.jar halcyon.ide.HalcyonIDE    

