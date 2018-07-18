#Author: Gilles Biagomba
#Program: JBosster.sh
#Description: This script uses Jexboss and runs it against multiple hosts.\n
#Prerequisite: You will need to install jexboss, nikto, nmap, and sniper.\n
#Reference: https://github.com/joaomatosf/jexboss

#script JBosster_output-$(date +%Y.%m.%d)

#declaring variable
declare -a PORT=(443 465 563 585 636 695 832 898 981 989 990 992 993 994 995 1090 1098 1099 1311 1360 1433 1434 1521 1527 1583 2083 2087 2096 2376 2484 2638 3269 3306 3351 3389 3424 3873 4443 4445 4446 4843 5223 5432 5500 5800 5900 6080 6432 6619 6679 6697 7000 7002 7080 7091 7092 7101 7103 7105 7107 7109 7306 7307 8009 8080 8081 8083 8243 8333 8443 8531 8888 9001 9091 9443 10911 11214 11215 12043 12443 12975 13722 18091 18092 18366 19812 20911 23642 27724 32976 33300 33840 36210 37549 38131 38760 41443 41581 41971 43778 46160 46393 55130 55443 62657 64779)
App="jexboss"
diskMax=90
diskSize=$(df | grep /dev/sda1 | cut -d " " -f 13 | cut -d "%" -f 1)
pth=$(pwd)
RunTIME=$(date +%H:%M)
TodaysDAY=$(date +%m-%d)
TodaysMONTH=$(date +%b)
TodaysYEAR=$(date +%Y)
workpth="$pth/$TodaysYEAR/$TodaysMONTH/$TodaysDAY/$RunTIME/"

#Checking system resources (HDD space)
if [ "$diskSize" -ge "$diskMax" ];then
	clear
	echo 
	echo "You are using $diskSize% and I am concerned you might run out of space"
	echo "Remove some files and try again, you will thank me later, trust me :)"
	exit
fi

#Downloading dependencies
cd /tmp/
git clone https://github.com/joaomatosf/jexboss.git
git clone https://github.com/hlldz/wildPwn.git
git clone https://github.com/johndekroon/serializekiller.git
cd $pth

#Setting Envrionment
mkdir -p $workpth/Masscan $workpth/wildPwn/ $workpth/SerializeKiller/ $workpth/Nmap
mkdir -p $workpth/JexBoss/Logs $workpth/Sniper $workpth/Nikto $workpth/Reports

#Requesting target file 
clear
echo
echo "What is the name of the targets file? The file with all the IP addresses"
read targets

#Launching scans

#Use masscan to perform a quick port sweep
cat $targets | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" > temptargets
cat $targets | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\/[0-9]\{1,\}'  >> temptargets
cat temptargets | sort | uniq > targets2
masscan -iL $pth/targets2 -p 0-65535 --open-only --banners -oL $workpth/Masscan/masscan_output
#Above the above stores the openports list to the variable to be later sent to nmap
OpenPORT=($(cat $workpth/Masscan/masscan_output | cut -d " " -f 3 | grep -v masscan | sort | uniq))

#Use nmap to perform a targeted scan then sorting the various hosts based on their technologies
cd $pth
nmap -A -Pn -R -sS -sU -sV --script=ssl-enum-ciphers,vulners,wildfly-detect -iL $pth/$targets -p $(echo ${OpenPORT[*]} | sed 's/ /,/g') -oA $workpth/Nmap/NBME_JBOSS
cat $workpth/Nmap/NBME_JBOSS.gnmap | grep "Up" | cut -d " " -f 2 | sort | uniq > $workpth/Nmap/livehosts
cat $workpth/Nmap/NBME_JBOSS.gnmap | grep -i "jboss" | cut -d " " -f 2 | sort | uniq > $workpth/Nmap/jboss
cat $workpth/Nmap/NBME_JBOSS.gnmap | grep -i "java" | cut -d " " -f 2 | sort | uniq > $workpth/Nmap/java
cat $workpth/Nmap/NBME_JBOSS.gnmap | grep -i "apache" | cut -d " " -f 2 | sort | uniq > $workpth/Nmap/apache
xsltproc $workpth/Nmap/NBME_JBOSS.xml -o $workpth/Reports/NBME_JBOSS_Nmap.html

# to do
# fix the jexboss logging (log file)
# fix the jexboss report export [done]
# fix the if jexboss statement [done]
# put up a note about the 443none issue observed [done]

#Perform targeted scan using jexboss
cd /tmp/jexboss/
for IP in $(cat $workpth/Nmap/livehosts); do
	for PORTNUM in ${PORT[*]}; do
		STAT1=$(cat $workpth/Nmap/NBME_JBOSS.gnmap | grep $IP | grep "Status: Up" -m 1 -o | cut -c 9-10)
		STAT2=$(cat $workpth/Nmap/NBME_JBOSS.gnmap | grep $IP | grep "$PORTNUM/open" -m 1 -o | grep "open" -o)
		STAT3=$(cat $workpth/Nmap/NBME_JBOSS.gnmap | grep $IP | grep "$PORTNUM/filtered" -m 1 -o | grep "filtered" -o)
		if [ "$STAT1" == "Up" ] && [ "$STAT2" == "open" ] || [ "$STAT3" == "filtered" ];then
			if [ "$PORTNUM" == "443" ]
				python jexboss.py -u https://$IP -results "$workpth/JexBoss/$IP-$PORTNUM-HTTPS-JexBOSS" -out "$workpth/JexBoss/Logs/$IP-$PORTNUM-report_file_scan2.log" | tee -a $workpth/JexBoss/Logs/$IP-$PORTNUM
			fi
			python jexboss.py -u http://$IP:$PORTNUM -results "$workpth/JexBoss/$IP-$PORTNUM-HTTP-JexBOSS" -out "$workpth/JexBoss/Logs/$IP-$PORTNUM-report_file_scan.log" | tee $workpth/JexBoss/$IP-$PORTNUM
			python jexboss.py -u https://$IP:$PORTNUM -results "$workpth/JexBoss/$IP-$PORTNUM-HTTPS-JexBOSS" -out "$workpth/JexBoss/Logs/$IP-$PORTNUM-report_file_scan2.log" | tee -a $workpth/JexBoss/Logs/$IP-$PORTNUM
		fi
	done
done
cat $workpth/JexBoss/* | aha -t "JBOSS Report - $TodaysDAY-$TodaysMONTH-$TodaysYEAR" > $workpth/Reports/Jxboss.html
cat $workpth/JexBoss/* | grep VUNERABLE > $workpth/Reports/Final_Vulnerable.txt
cat $workpth/JexBoss/* | grep EXPOSED > $workpth/Reports/Final_EXPOSED.txt
cat $workpth/JexBoss/* | grep OK > $workpth/Reports/Final_OK.txt
cd $pth

#Perform targeted scanning using wildPwn
#python wildPwn.py -m deploy --target <TARGET> --port <PORT> -pass /usr/share/seclists/Passwords/Common-Credentials/10-million-password-list-top-1000.txt -user /usr/share/seclists/Usernames/top-usernames-shortlist.txt
cd /tmp/wildPwn
echo "What is the test account username?"
read usrname
echo "What is the test account password?"
read passwrd
for IP in $(cat $workpth/Nmap/livehosts); do
	for PORTNUM in ${PORT[*]}; do
		STAT1=$(cat $workpth/Nmap/NBME_JBOSS.gnmap | grep $IP | grep "Status: Up" -m 1 -o | cut -c 9-10)
        STAT2=$(cat $workpth/Nmap/NBME_JBOSS.gnmap | grep $IP | grep "$PORTNUM/open" -m 1 -o | grep "open" -o)
        STAT3=$(cat $workpth/Nmap/NBME_JBOSS.gnmap | grep $IP | grep "$PORTNUM/filtered" -m 1 -o | grep "filtered" -o)
        if [ "$STAT1" == "Up" ] && [ "$STAT2" == "open" ] || [ "$STAT3" == "filtered" ];then
			python wildPwn.py  -m deploy --target $IP --port $PORTNUM -u $usrname -p $passwrd | tee $workpth/wildPwn/$IP-$PORTNUM
		fi
	done
done
cat $workpth/wildPwn/* | aha -t "$IP wildPwn Results" >> $workpth/Reports/$IP-wildPwn-Final.html
cd $pth

#Perform targeted scanning using serializekiller
#python serializekiller.py --url example.com
cd /tmp/SerializeKiller
for IP in $(cat $workpth/Nmap/livehosts); do
	for PORTNUM in ${PORT[*]}; do
		STAT1=$(cat $workpth/Nmap/NBME_JBOSS.gnmap | grep $IP | grep "Status: Up" -m 1 -o | cut -c 9-10)
        STAT2=$(cat $workpth/Nmap/NBME_JBOSS.gnmap | grep $IP | grep "$PORTNUM/open" -m 1 -o | grep "open" -o)
        STAT3=$(cat $workpth/Nmap/NBME_JBOSS.gnmap | grep $IP | grep "$PORTNUM/filtered" -m 1 -o | grep "filtered" -o)
        if [ "$STAT1" == "Up" ] && [ "$STAT2" == "open" ] || [ "$STAT3" == "filtered" ];then
			python serializekiller.py $pth/targets | tee $workpth/SerializeKiller/$IP-$PORTNUM
		fi
	done
done
cat $workpth/SerializeKiller/* | aha -t "$IP serializekiller Results" >> $workpth/Reports/$IP-SerializeKiller-Final.html
cd $pth

#Performing a Nikto scan
cd $pth
for IP in $(cat $workpth/Nmap/livehosts); do
	for PORTNUM in ${PORT[*]}; do
		STAT1=$(cat $workpth/Nmap/NBME_JBOSS.gnmap | grep $IP | grep "Status: Up" -m 1 -o | cut -c 9-10)
        STAT2=$(cat $workpth/Nmap/NBME_JBOSS.gnmap | grep $IP | grep "$PORTNUM/open" -m 1 -o | grep "open" -o)
        STAT3=$(cat $workpth/Nmap/NBME_JBOSS.gnmap | grep $IP | grep "$PORTNUM/filtered" -m 1 -o | grep "filtered" -o)
        if [ "$STAT1" == "Up" ] && [ "$STAT2" == "open" ] || [ "$STAT3" == "filtered" ];then
			nikto -C all -h $IP:$PORTNUM -o $workpth/Nikto/$IP-$PORTNUM.txt
		fi
	done
done
cat $workpth/Nikto/* | aha -t "$IP Nikto Results" >> $workpth/Reports/$IP-Nikto-Final.html

#Performing a Sniper scan
for IP in $(cat $workpth/Nmap/livehosts); do
	for PORTNUM in ${PORT[*]}; do
		STAT1=$(cat $workpth/Nmap/NBME_JBOSS.gnmap | grep $IP | grep "Status: Up" -m 1 -o | cut -c 9-10)
        STAT2=$(cat $workpth/Nmap/NBME_JBOSS.gnmap | grep $IP | grep "$PORTNUM/open" -m 1 -o | grep "open" -o)
        STAT3=$(cat $workpth/Nmap/NBME_JBOSS.gnmap | grep $IP | grep "$PORTNUM/filtered" -m 1 -o | grep "filtered" -o)
        if [ "$STAT1" == "Up" ] && [ "$STAT2" == "open" ] || [ "$STAT3" == "filtered" ];then
			sniper -w JBOSS -t $IP -m webporthttps -p $PORTNUM | tee -a $workpth/Sniper/$IP-$PORTNUM			
		fi
	done
done
cat $workpth/Sniper/* | aha -t "$IP Sniper Results" >> $workpth/Reports/$IP-Sniper-Final.html

#cleaning up
unset App
unset diskMax
unset diskSize
unset IP
unset mainpth
unset passwrd
unset PORT
unset PORTNUM
unset pth
unset RunTIME
unset STAT1
unset STAT2
unset STAT3
unset TodaysDAY
unset TodaysMONTH
unset TodaysYEAR
unset usrname
unset workpth
set -u