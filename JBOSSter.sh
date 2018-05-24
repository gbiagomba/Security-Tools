#Author: Gilles Biagomba
#Program: JBosster.sh
#Description: This script uses Jexboss and runs it against multiple hosts.\n
#Prerequisite: You will need to install jexboss, nikto, nmap, and sniper.\n
#Reference: https://github.com/joaomatosf/jexboss

#script JBosster_output-$(date +%Y.%m.%d)

#declaring variable
declare -a PORT=(443 1090 1098 1099 3873 4445 4446 7080 7091 7092 8009 8080 8083 10911 13722 18366 20911 23642 27724 33300 33840 36210 37549 38131 38760 41443 41581 41971 43778 46160 46393 55130 55443 62657 64779 4443 7101 7103 7105 7107 7109 8081 8888)
pth=$(pwd)
TodaysDATE=$(date +%Y.%m.%d)
RunTIME=$(date +%H:%M)
diskSize=$(df | grep /dev/sda1 | cut -d " " -f 11 | cut -d "%" -f 1)
diskMax=90

#Checking system resources (HDD space)
if ["$diskSize" -ge "$diskMax"];then
	echo "You are using $diskSize% and I am concerned you might run out of space"
	echo "Remove some files and try again, you will thank me later, trust me :)"
	exit
fi

#Setting Envrionment
mkdir -p $pth/$TodaysDATE/$RunTIME/JexBoss/Logs $pth/$TodaysDATE/$RunTIME/Sniper $pth/$TodaysDATE/$RunTIME/Nikto
mkdir -p $pth/$TodaysDATE/$RunTIME/Nmap $pth/$TodaysDATE/$RunTIME/Reports
if ["jexboss" != "$(ls | grep jexboss)"];then
	cd /tmp/
	git clone https://github.com/joaomatosf/jexboss.git
fi

#git clone https://github.com/hlldz/wildPwn.git
#git clone https://github.com/johndekroon/serializekiller.git

#Launching scans

#Use nmap to perform a targeted scan then sorting the various hosts based on their technologies
cd $pth
nmap -A -Pn -R -sS -sU -sV --script=ssl-enum-ciphers,vulners,wildfly-detect -p 443,465,563,585,636,695,832,898,981,989,990,992,993,994,995,1311,1360,1433,1434,1521,1527,1583,2083,2087,2096,2376,2484,2638,3269,3306,3351,3389,3424,4843,5223,5432,5500,5800,5900,6432,6619,6679,6697,7000,7002,7306,7307,8243,8333,8443,8531,8888,9001,9091,9443,11214,11215,12043,12443,12975,18091,18092,19812,32976 -iL $pth/targets -oA $pth/$TodaysDATE/$RunTIME/Nmap/NBME_JBOSS
cat $pth/$TodaysDATE/$RunTIME/Nmap/NBME_JBOSS.gnmap | grep "Up" | cut -d " " -f 2 | sort | uniq > $pth/$TodaysDATE/$RunTIME/Nmap/livehosts
cat $pth/$TodaysDATE/$RunTIME/Nmap/NBME_JBOSS.gnmap | grep -i "jboss" | cut -d " " -f 2 | sort | uniq > $pth/$TodaysDATE/$RunTIME/Nmap/jboss
cat $pth/$TodaysDATE/$RunTIME/Nmap/NBME_JBOSS.gnmap | grep -i "java" | cut -d " " -f 2 | sort | uniq > $pth/$TodaysDATE/$RunTIME/Nmap/java
cat $pth/$TodaysDATE/$RunTIME/Nmap/NBME_JBOSS.gnmap | grep -i "apache" | cut -d " " -f 2 | sort | uniq > $pth/$TodaysDATE/$RunTIME/Nmap/apache
xsltproc $pth/$TodaysDATE/$RunTIME/Nmap/NBME_JBOSS.xml -o $pth/$TodaysDATE/$RunTIME/Reports/NBME_JBOSS_Nmap.html

#Perform targeted scan using jexboss
cd /tmp/jexboss
for IP in $(cat $pth/$TodaysDATE/$RunTIME/Nmap/livehosts); do
	for PORTNUM in ${PORT[*]}; do
		STAT1=$(cat $pth/$TodaysDATE/$RunTIME/Nmap/NBME_JBOSS.gnmap | grep $IP | grep "Status: Up" -m 1 -o | cut -c 9-10)
        STAT2=$(cat $pth/$TodaysDATE/$RunTIME/Nmap/NBME_JBOSS.gnmap | grep $IP | grep "$PORTNUM/open" -m 1 -o | grep "open" -o)
        STAT3=$(cat $pth/$TodaysDATE/$RunTIME/Nmap/NBME_JBOSS.gnmap | grep $IP | grep "$PORTNUM/filtered" -m 1 -o | grep "filtered" -o)
        if [ "$STAT1" == "Up" ] && [ "$STAT2" == "open" ] || [ "$STAT3" == "filtered" ];then
			python jexboss.py -u http://$IP:$PORTNUM -results "$pth/$TodaysDATE/$RunTIME/JexBoss/$IP-$PORTNUM-HTTP-JexBOSS" -out "$pth/$TodaysDATE/$RunTIME/JexBoss/Logs/$IP-$PORTNUM-report_file_scan.log" | tee $pth/$TodaysDATE/$RunTIME/JexBoss/$IP-$PORTNUM
			python jexboss.py -u https://$IP:$PORTNUM -results "$pth/$TodaysDATE/$RunTIME/JexBoss/$IP-$PORTNUM-HTTPS-JexBOSS" -out "$pth/$TodaysDATE/$RunTIME/JexBoss/Logs/$IP-$PORTNUM-report_file_scan2.log" | tee -a $pth/$TodaysDATE/$RunTIME/JexBoss/Logs/$IP-$PORTNUM
			cat $pth/$TodaysDATE/$RunTIME/JexBoss/$IP:$PORTNUM | aha -t "$IP JexBoss Results" >> $pth/$TodaysDATE/$RunTIME/Reports/$IP-JexBoss-Final.html
			echo "--------------------------------$IP:$PORTNUM---------------------------------------------" >> $pth/$TodaysDATE/$RunTIME/Reports/$IP-FInal.html
		fi
	done
done

#Performing a Nikto scan
for IP in $(cat $pth/$TodaysDATE/$RunTIME/Nmap/livehosts); do
	for PORTNUM in ${PORT[*]}; do
		STAT1=$(cat $pth/$TodaysDATE/$RunTIME/Nmap/NBME_JBOSS.gnmap | grep $IP | grep "Status: Up" -m 1 -o | cut -c 9-10)
        STAT2=$(cat $pth/$TodaysDATE/$RunTIME/Nmap/NBME_JBOSS.gnmap | grep $IP | grep "$PORTNUM/open" -m 1 -o | grep "open" -o)
        STAT3=$(cat $pth/$TodaysDATE/$RunTIME/Nmap/NBME_JBOSS.gnmap | grep $IP | grep "$PORTNUM/filtered" -m 1 -o | grep "filtered" -o)
        if [ "$STAT1" == "Up" ] && [ "$STAT2" == "open" ] || [ "$STAT3" == "filtered" ];then
			nikto -C all -h $IP:$PORTNUM -o $pth/$TodaysDATE/$RunTIME/Nikto/$IP-$PORTNUM.txt
			cat $pth/$TodaysDATE/$RunTIME/Nikto/$IP:$PORTNUM | aha -t "$IP Nikto Results" >> $pth/$TodaysDATE/$RunTIME/Reports/$IP-Nikto-Final.html
		fi
	done
done

#Performing a Sniper scan
for IP in $(cat $pth/$TodaysDATE/$RunTIME/Nmap/livehosts); do
	for PORTNUM in ${PORT[*]}; do
		STAT1=$(cat $pth/$TodaysDATE/$RunTIME/Nmap/NBME_JBOSS.gnmap | grep $IP | grep "Status: Up" -m 1 -o | cut -c 9-10)
        STAT2=$(cat $pth/$TodaysDATE/$RunTIME/Nmap/NBME_JBOSS.gnmap | grep $IP | grep "$PORTNUM/open" -m 1 -o | grep "open" -o)
        STAT3=$(cat $pth/$TodaysDATE/$RunTIME/Nmap/NBME_JBOSS.gnmap | grep $IP | grep "$PORTNUM/filtered" -m 1 -o | grep "filtered" -o)
        if [ "$STAT1" == "Up" ] && [ "$STAT2" == "open" ] || [ "$STAT3" == "filtered" ];then
			sniper -w JBOSS -t $IP -m webporthttps -p $PORTNUM | tee -a $pth/$TodaysDATE/$RunTIME/Sniper/$IP-$PORTNUM
			cat $pth/$TodaysDATE/$RunTIME/Sniper/$IP:$PORTNUM | aha -t "$IP Sniper Results" >> $pth/$TodaysDATE/$RunTIME/Reports/$IP-Sniper-Final.html
		fi
	done
done

#Perform targeted scanning using wildPwn
#python wildPwn.py -m deploy --target <TARGET> --port <PORT> -u <USERNAME> -p <PASSWORD>

#Perform targeted scanning using serializekiller
#python serializekiller.py --url example.com

#cleaning up
unset diskMax
unset diskSize
unset IP
unset PORT
unset PORTNUM
unset pth
unset RunTIME
unset STAT1
unset STAT2
unset STAT3
unset TodaysDATE
set -u