#Author: Gilles Biagomba
#Program: JBosster.sh
#Description: This script uses Jexboss and runs it against multiple hosts.\n
#Prerequisite: You will need to install jexboss, nikto, nmap, and sniper.\n
#Reference: https://github.com/joaomatosf/jexboss

#script JBosster_output-$(date +%Y.%m.%d)

#declaring variable
declare -a PORT=(443 465 563 585 636 695 832 898 981 989 990 992 993 994 995 1090 1098 1099 1311 1360 1433 1434 1521 1527 1583 2083 2087 2096 2376 2484 2638 3269 3306 3351 3389 3424 3873 4443 4445 4446 4843 5223 5432 5500 5800 5900 6432 6619 6679 6697 7000 7002 7080 7091 7092 7101 7103 7105 7107 7109 7306 7307 8009 8080 8081 8083 8243 8333 8443 8531 8888 9001 9091 9443 10911 11214 11215 12043 12443 12975 13722 18091 18092 18366 19812 20911 23642 27724 32976 33300 33840 36210 37549 38131 38760 41443 41581 41971 43778 46160 46393 55130 55443 62657 64779)
pth=$(pwd)
TodaysYEAR=$(date +%Y)
TodaysMONTH=$(date +%b)
TodaysDAY=$(date +%m-%d)
RunTIME=$(date +%H:%M)
diskSize=$(df | grep /dev/sda1 | cut -d " " -f 11 | cut -d "%" -f 1)
diskMax=90
App="jexboss"
mainpth="$pth/$TodaysYEAR/$TodaysMONTH/$TodaysDAY/$RunTIME/"
echo $mainpth

#Checking system resources (HDD space)
if ["$diskSize" -ge "$diskMax"];then
	echo "You are using $diskSize% and I am concerned you might run out of space"
	echo "Remove some files and try again, you will thank me later, trust me :)"
	exit
fi

#Checking for requirements
#git clone https://github.com/joaomatosf/jexboss.git
#git clone https://github.com/hlldz/wildPwn.git
#git clone https://github.com/johndekroon/serializekiller.git

#Setting Envrionment
mkdir -p $pth/$TodaysYEAR/$TodaysMONTH/$TodaysDAY/$RunTIME/Masscan
mkdir -p $pth/$TodaysYEAR/$TodaysMONTH/$TodaysDAY/$RunTIME/JexBoss/Logs $pth/$TodaysYEAR/$TodaysMONTH/$TodaysDAY/$RunTIME/Sniper $pth/$TodaysYEAR/$TodaysMONTH/$TodaysDAY/$RunTIME/Nikto
mkdir -p $pth/$TodaysYEAR/$TodaysMONTH/$TodaysDAY/$RunTIME/Nmap $pth/$TodaysYEAR/$TodaysMONTH/$TodaysDAY/$RunTIME/Reports

#Launching scans

#Use masscan to perform a quick port sweep
masscan -iL $pth/targets -p 0-65535 --open-only --banners -oL $pth/$TodaysYEAR/$TodaysMONTH/$TodaysDAY/$RunTIME/Masscan/masscan_output
OpenPORT=($(cat $pth/$TodaysYEAR/$TodaysMONTH/$TodaysDAY/$RunTIME/Masscan/masscan_output | cut -d " " -f 3 | grep -v masscan | sort | uniq))
#Above the above stores the openports list to the variable to be later sent to nmap

#Use nmap to perform a targeted scan then sorting the various hosts based on their technologies
cd $pth
nmap -A -Pn -R -sS -sU -sV --script=ssl-enum-ciphers,vulners,wildfly-detect -iL $pth/targets -p $(echo ${OpenPORT[*]} | sed 's/ /,/g') -oA $pth/$TodaysYEAR/$TodaysMONTH/$TodaysDAY/$RunTIME/Nmap/NBME_JBOSS
cat $pth/$TodaysYEAR/$TodaysMONTH/$TodaysDAY/$RunTIME/Nmap/NBME_JBOSS.gnmap | grep "Up" | cut -d " " -f 2 | sort | uniq > $pth/$TodaysYEAR/$TodaysMONTH/$TodaysDAY/$RunTIME/Nmap/livehosts
cat $pth/$TodaysYEAR/$TodaysMONTH/$TodaysDAY/$RunTIME/Nmap/NBME_JBOSS.gnmap | grep -i "jboss" | cut -d " " -f 2 | sort | uniq > $pth/$TodaysYEAR/$TodaysMONTH/$TodaysDAY/$RunTIME/Nmap/jboss
cat $pth/$TodaysYEAR/$TodaysMONTH/$TodaysDAY/$RunTIME/Nmap/NBME_JBOSS.gnmap | grep -i "java" | cut -d " " -f 2 | sort | uniq > $pth/$TodaysYEAR/$TodaysMONTH/$TodaysDAY/$RunTIME/Nmap/java
cat $pth/$TodaysYEAR/$TodaysMONTH/$TodaysDAY/$RunTIME/Nmap/NBME_JBOSS.gnmap | grep -i "apache" | cut -d " " -f 2 | sort | uniq > $pth/$TodaysYEAR/$TodaysMONTH/$TodaysDAY/$RunTIME/Nmap/apache
xsltproc $pth/$TodaysYEAR/$TodaysMONTH/$TodaysDAY/$RunTIME/Nmap/NBME_JBOSS.xml -o $pth/$TodaysYEAR/$TodaysMONTH/$TodaysDAY/$RunTIME/Reports/NBME_JBOSS_Nmap.html

#Perform targeted scan using jexboss
#Need to revise if statement, currently written ineficiently
cd $pth
if ["$App" != "$(ls | grep jexboss)"];then
	cd /tmp/
	git clone https://github.com/joaomatosf/jexboss.git
	cd jexboss/
	for IP in $(cat $pth/$TodaysYEAR/$TodaysMONTH/$TodaysDAY/$RunTIME/Nmap/livehosts); do
		for PORTNUM in ${PORT[*]}; do
			STAT1=$(cat $pth/$TodaysYEAR/$TodaysMONTH/$TodaysDAY/$RunTIME/Nmap/NBME_JBOSS.gnmap | grep $IP | grep "Status: Up" -m 1 -o | cut -c 9-10)
			STAT2=$(cat $pth/$TodaysYEAR/$TodaysMONTH/$TodaysDAY/$RunTIME/Nmap/NBME_JBOSS.gnmap | grep $IP | grep "$PORTNUM/open" -m 1 -o | grep "open" -o)
			STAT3=$(cat $pth/$TodaysYEAR/$TodaysMONTH/$TodaysDAY/$RunTIME/Nmap/NBME_JBOSS.gnmap | grep $IP | grep "$PORTNUM/filtered" -m 1 -o | grep "filtered" -o)
			if [ "$STAT1" == "Up" ] && [ "$STAT2" == "open" ] || [ "$STAT3" == "filtered" ];then
				python jexboss.py -u http://$IP:$PORTNUM -results "$pth/$TodaysYEAR/$TodaysMONTH/$TodaysDAY/$RunTIME/JexBoss/$IP-$PORTNUM-HTTP-JexBOSS" -out "$pth/$TodaysYEAR/$TodaysMONTH/$TodaysDAY/$RunTIME/JexBoss/Logs/$IP-$PORTNUM-report_file_scan.log" | tee $pth/$TodaysYEAR/$TodaysMONTH/$TodaysDAY/$RunTIME/JexBoss/$IP-$PORTNUM
				python jexboss.py -u https://$IP:$PORTNUM -results "$pth/$TodaysYEAR/$TodaysMONTH/$TodaysDAY/$RunTIME/JexBoss/$IP-$PORTNUM-HTTPS-JexBOSS" -out "$pth/$TodaysYEAR/$TodaysMONTH/$TodaysDAY/$RunTIME/JexBoss/Logs/$IP-$PORTNUM-report_file_scan2.log" | tee -a $pth/$TodaysYEAR/$TodaysMONTH/$TodaysDAY/$RunTIME/JexBoss/Logs/$IP-$PORTNUM
				cat $pth/$TodaysYEAR/$TodaysMONTH/$TodaysDAY/$RunTIME/JexBoss/$IP:$PORTNUM | aha -t "$IP JexBoss Results" >> $pth/$TodaysYEAR/$TodaysMONTH/$TodaysDAY/$RunTIME/Reports/$IP-JexBoss-Final.html
				echo "--------------------------------$IP:$PORTNUM---------------------------------------------" >> $pth/$TodaysYEAR/$TodaysMONTH/$TodaysDAY/$RunTIME/Reports/$IP-FInal.html
			fi
		done
	done
	cat $pth/$TodaysYEAR/$TodaysMONTH/$TodaysDAY/$RunTIME/JexBoss/* | grep VUNERABLE > $pth/$TodaysYEAR/$TodaysMONTH/$TodaysDAY/$RunTIME/Final_Vulnerable.txt
	cat $pth/$TodaysYEAR/$TodaysMONTH/$TodaysDAY/$RunTIME/JexBoss/* | grep EXPOSED > $pth/$TodaysYEAR/$TodaysMONTH/$TodaysDAY/$RunTIME/Final_EXPOSED.txt
	cat $pth/$TodaysYEAR/$TodaysMONTH/$TodaysDAY/$RunTIME/JexBoss/* | grep OK > $pth/$TodaysYEAR/$TodaysMONTH/$TodaysDAY/$RunTIME/Final_OK.txt
	cd ..
else
	cd jexboss/
	for IP in $(cat $pth/$TodaysYEAR/$TodaysMONTH/$TodaysDAY/$RunTIME/Nmap/livehosts); do
		for PORTNUM in ${PORT[*]}; do
			STAT1=$(cat $pth/$TodaysYEAR/$TodaysMONTH/$TodaysDAY/$RunTIME/Nmap/NBME_JBOSS.gnmap | grep $IP | grep "Status: Up" -m 1 -o | cut -c 9-10)
			STAT2=$(cat $pth/$TodaysYEAR/$TodaysMONTH/$TodaysDAY/$RunTIME/Nmap/NBME_JBOSS.gnmap | grep $IP | grep "$PORTNUM/open" -m 1 -o | grep "open" -o)
			STAT3=$(cat $pth/$TodaysYEAR/$TodaysMONTH/$TodaysDAY/$RunTIME/Nmap/NBME_JBOSS.gnmap | grep $IP | grep "$PORTNUM/filtered" -m 1 -o | grep "filtered" -o)
			if [ "$STAT1" == "Up" ] && [ "$STAT2" == "open" ] || [ "$STAT3" == "filtered" ];then
				python jexboss.py -u http://$IP:$PORTNUM -results "$pth/$TodaysYEAR/$TodaysMONTH/$TodaysDAY/$RunTIME/JexBoss/$IP-$PORTNUM-HTTP-JexBOSS" -out "$pth/$TodaysYEAR/$TodaysMONTH/$TodaysDAY/$RunTIME/JexBoss/Logs/$IP-$PORTNUM-report_file_scan.log" | tee $pth/$TodaysYEAR/$TodaysMONTH/$TodaysDAY/$RunTIME/JexBoss/$IP-$PORTNUM
				python jexboss.py -u https://$IP:$PORTNUM -results "$pth/$TodaysYEAR/$TodaysMONTH/$TodaysDAY/$RunTIME/JexBoss/$IP-$PORTNUM-HTTPS-JexBOSS" -out "$pth/$TodaysYEAR/$TodaysMONTH/$TodaysDAY/$RunTIME/JexBoss/Logs/$IP-$PORTNUM-report_file_scan2.log" | tee -a $pth/$TodaysYEAR/$TodaysMONTH/$TodaysDAY/$RunTIME/JexBoss/Logs/$IP-$PORTNUM
				cat $pth/$TodaysYEAR/$TodaysMONTH/$TodaysDAY/$RunTIME/JexBoss/$IP:$PORTNUM | aha -t "$IP JexBoss Results" >> $pth/$TodaysYEAR/$TodaysMONTH/$TodaysDAY/$RunTIME/Reports/$IP-JexBoss-Final.html
				echo "--------------------------------$IP:$PORTNUM---------------------------------------------" >> $pth/$TodaysYEAR/$TodaysMONTH/$TodaysDAY/$RunTIME/Reports/$IP-FInal.html
			fi
		done
	done
	cat $pth/$TodaysYEAR/$TodaysMONTH/$TodaysDAY/$RunTIME/JexBoss/* | grep VUNERABLE > $pth/$TodaysYEAR/$TodaysMONTH/$TodaysDAY/$RunTIME/Final_Vulnerable.txt
	cat $pth/$TodaysYEAR/$TodaysMONTH/$TodaysDAY/$RunTIME/JexBoss/* | grep EXPOSED > $pth/$TodaysYEAR/$TodaysMONTH/$TodaysDAY/$RunTIME/Final_EXPOSED.txt
	cat $pth/$TodaysYEAR/$TodaysMONTH/$TodaysDAY/$RunTIME/JexBoss/* | grep OK > $pth/$TodaysYEAR/$TodaysMONTH/$TodaysDAY/$RunTIME/Final_OK.txt
	cd ..
fi

#Performing a Nikto scan
for IP in $(cat $pth/$TodaysYEAR/$TodaysMONTH/$TodaysDAY/$RunTIME/Nmap/livehosts); do
	for PORTNUM in ${PORT[*]}; do
		STAT1=$(cat $pth/$TodaysYEAR/$TodaysMONTH/$TodaysDAY/$RunTIME/Nmap/NBME_JBOSS.gnmap | grep $IP | grep "Status: Up" -m 1 -o | cut -c 9-10)
        STAT2=$(cat $pth/$TodaysYEAR/$TodaysMONTH/$TodaysDAY/$RunTIME/Nmap/NBME_JBOSS.gnmap | grep $IP | grep "$PORTNUM/open" -m 1 -o | grep "open" -o)
        STAT3=$(cat $pth/$TodaysYEAR/$TodaysMONTH/$TodaysDAY/$RunTIME/Nmap/NBME_JBOSS.gnmap | grep $IP | grep "$PORTNUM/filtered" -m 1 -o | grep "filtered" -o)
        if [ "$STAT1" == "Up" ] && [ "$STAT2" == "open" ] || [ "$STAT3" == "filtered" ];then
			nikto -C all -h $IP:$PORTNUM -o $pth/$TodaysYEAR/$TodaysMONTH/$TodaysDAY/$RunTIME/Nikto/$IP-$PORTNUM.txt
			cat $pth/$TodaysYEAR/$TodaysMONTH/$TodaysDAY/$RunTIME/Nikto/$IP:$PORTNUM | aha -t "$IP Nikto Results" >> $pth/$TodaysYEAR/$TodaysMONTH/$TodaysDAY/$RunTIME/Reports/$IP-Nikto-Final.html
		fi
	done
done

#Performing a Sniper scan
for IP in $(cat $pth/$TodaysYEAR/$TodaysMONTH/$TodaysDAY/$RunTIME/Nmap/livehosts); do
	for PORTNUM in ${PORT[*]}; do
		STAT1=$(cat $pth/$TodaysYEAR/$TodaysMONTH/$TodaysDAY/$RunTIME/Nmap/NBME_JBOSS.gnmap | grep $IP | grep "Status: Up" -m 1 -o | cut -c 9-10)
        STAT2=$(cat $pth/$TodaysYEAR/$TodaysMONTH/$TodaysDAY/$RunTIME/Nmap/NBME_JBOSS.gnmap | grep $IP | grep "$PORTNUM/open" -m 1 -o | grep "open" -o)
        STAT3=$(cat $pth/$TodaysYEAR/$TodaysMONTH/$TodaysDAY/$RunTIME/Nmap/NBME_JBOSS.gnmap | grep $IP | grep "$PORTNUM/filtered" -m 1 -o | grep "filtered" -o)
        if [ "$STAT1" == "Up" ] && [ "$STAT2" == "open" ] || [ "$STAT3" == "filtered" ];then
			sniper -w JBOSS -t $IP -m webporthttps -p $PORTNUM | tee -a $pth/$TodaysYEAR/$TodaysMONTH/$TodaysDAY/$RunTIME/Sniper/$IP-$PORTNUM
			cat $pth/$TodaysYEAR/$TodaysMONTH/$TodaysDAY/$RunTIME/Sniper/$IP:$PORTNUM | aha -t "$IP Sniper Results" >> $pth/$TodaysYEAR/$TodaysMONTH/$TodaysDAY/$RunTIME/Reports/$IP-Sniper-Final.html
		fi
	done
done

#Perform targeted scanning using wildPwn
#python wildPwn.py -m deploy --target <TARGET> --port <PORT> -u <USERNAME> -p <PASSWORD>

#Perform targeted scanning using serializekiller
#python serializekiller.py --url example.com

#cleaning up
unset App
unset diskMax
unset diskSize
unset IP
unset mainpth
unset PORT
unset PORTNUM
unset pth
unset RunTIME
unset STAT1
unset STAT2
unset STAT3
unset TodaysYEAR
unset TodaysMONTH
unset TodaysDAY
set -u