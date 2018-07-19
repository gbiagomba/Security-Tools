#Author: Gilles Biagomba
#Program: TLS_Check.sh
#Description: Test to see if TLS 1.0 and TLS 1.1 are enables.\n
#             This program is a derivative of my WeakSSL script.\n

#declaring variable
declare -a SSLPORT=(0 22 25 80 143 280 443 445 465 563 567 585 587 591 593 636 695 808 832 898 981 989 990 992 993 994 995 1090 1098 1099 1159 1311 1360 1392 1433 1434 1521 1527 1583 2083 2087 2096 2376 2484 2638 3071 3131 3132 3269 3306 3351 3389 3424 3872 3873 4443 4444 4445 4446 4843 4848 4903 5223 5432 5500 5556 5671 5672 5800 5900 5989 6080 6432 6619 6679 6697 6701 6703 7000 7002 7004 7080 7091 7092 7101 7102 7103 7105 7107 7109 7201 7202 7301 7306 7307 7403 7444 7501 7777 7799 7802 8000 8009 8080 8081 8082 8083 8089 8090 8140 8191 8243 8333 8443 8444 8531 8834 8888 8889 8899 9001 9002 9091 9095 9096 9097 9098 9099 9100 9443 9999 10000 10109 10443 10571 10911 11214 11215 12043 12443 12975 13722 17169 18091 18092 18366 19812 20911 23051 23642 27724 31100 32100 32976 33300 33840 36210 37549 38131 38760 41443 41581 41971 43778 46160 46393 49203 49223 49693 49926 55130 55443 56182 57572 58630 60306 62657 63002 64779 65298)
App="cipherscan"
pth=$(pwd)
TodaysDAY=$(date +%m-%d)
TodaysYEAR=$(date +%Y)
wrkpth="$TodaysYEAR/$TodaysDAY"

#Setting Envrionment
mkdir -p  $wrkpth/Nmap/ $wrkpth/SSLScan/ $wrkpth/Cipherscan $wrkpth/Masscan
mkdir -p $wrkpth/SSLyze/ $wrkpth/Reports/ $wrkpth/TestSSL/

#Checking/Downloading dependencies
if [ "$App" != "$(ls /tmp/ | grep cipherscan)" ]; then
    cd /tmp/
    git clone https://github.com/mozilla/cipherscan
    cd $pth/
fi

#Switching back to project dir
cd $pth/

#Requesting target file name
echo "What is the name of the targets file? The file with all the IP addresses"
read targets

#Use masscan to perform a quick port sweep
cat $targets | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" > $pth/temptargets
cat $targets | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\/[0-9]\{1,\}'  >> $pth/temptargets
cat $pth/temptargets | sort | uniq > $pth/targets2
masscan -iL $pth/targets2 -p $(echo ${SSLPORT[*]} | sed 's/ /,/g') --open-only --banners -oL $wrkpth/Masscan/masscan_output
OpenPORT=($(cat $pth/$wrkpth/Masscan/masscan_output | cut -d " " -f 3 | grep -v masscan | sort | uniq))
cat $pth/$wrkpth/Masscan/masscan_output | cut -d " " -f 4 | grep -v masscan | sort | uniq >> $wrkpth/livehosts

#Nmap Scan
echo "--------------------------------------------------"
echo "Performing the SSL scan using Nmap"
echo "--------------------------------------------------"
nmap -A -Pn -R -sS -sU -sV -p $(echo ${OpenPORT[*]} | sed 's/ /,/g') --script=ssl-enum-ciphers,vulners -iL $wrkpth/livehosts -oA $wrkpth/Nmap/TLS
xsltproc $pth/$wrkpth/Nmap/TLS.xml -o $pth/$wrkpth/Reports/Nmap_TLS_Output.html
cat $pth/$wrkpth/Nmap/TLS.gnmap | grep Up | cut -d ' ' -f 2 > $pth/$wrkpth/Nmap/live
#cat $pth/$wrkpth/Nmap/live | sort | uniq > $pth/$wrkpth/livehosts
unset OpenPORT
OpenPORT=($(cat $pth/$wrkpth/Nmap/TLS.nmap | grep open | grep "|" -v | cut -d " " -f 1 | cut -d "/" -f 1 | grep -Eo '[0-9]{0,5}' -o | sort | uniq))
#wc -l $pth/$wrkpth/livehosts | cut -d " " -f 1
echo

#Running all the other tools
echo "--------------------------------------------------"
echo "Performing Performing TLS 1.1 validation"
echo "--------------------------------------------------"
for IP in $(cat $pth/$wrkpth/livehosts); do
    for PORTNUM in ${OpenPORT[*]}; do
        STAT1=$(cat $pth/$wrkpth/Nmap/TLS.gnmap | grep $IP | grep "Status: Up" -m 1 -o | cut -c 9-10)
        STAT2=$(cat $pth/$wrkpth/Nmap/TLS.gnmap | grep $IP | grep "$PORTNUM/open" -m 1 -o | grep "open" -o)
        STAT3=$(cat $pth/$wrkpth/Nmap/TLS.gnmap | grep $IP | grep "$PORTNUM/filtered" -m 1 -o | grep "filtered" -o)
        SVRNAME=$(cat $pth/$wrkpth/Nmap/TLS.nmap | grep "Nmap scan report for" | grep $IP | cut -d " " -f 5) #nslookup $IP | grep name | cut -d " " -f 3
        if [ "$SVRNAME" == "" ] || [ "$SVRNAME" == " " ]; then
            "$SVRNAME"=$(nslookup $IP | grep name | cut -d " " -f 3)
            if [ "$SVRNAME" == "" ] || [ "$SVRNAME" == " " ]; then
                "$SVRNAME"="Unknown"
            fi
        fi
        echo $SVRNAME:$PORTNUM
        if [ "$STAT1" == "Up" ] && [ "$STAT2" == "open" ] || [ "$STAT3" == "filtered" ]; then
            echo "--------------------------------------------------" | tee -a $pth/$wrkpth/SSLScan/$IP:$PORTNUM-sslscan_output.txt $pth/$wrkpth/SSLyze/$IP:$PORTNUM-sslyze_output.txt $pth/$wrkpth/TestSSL/$IP:$PORTNUM-TestSSL_output.txt $pth/$wrkpth/Cipherscan/$IP:$PORTNUM-CipherScan_output.txt $pth/$wrkpth/Cipherscan/$IP:$PORTNUM-Analyze_output.txt
            echo "Performing a TLS 1.1 scan of $IP:$PORTNUM ($SVRNAME:$PORTNUM)" | tee -a $pth/$wrkpth/SSLScan/$IP:$PORTNUM-sslscan_output.txt $pth/$wrkpth/SSLyze/$IP:$PORTNUM-sslyze_output.txt $pth/$wrkpth/TestSSL/$IP:$PORTNUM-TestSSL_output.txt $pth/$wrkpth/Cipherscan/$IP:$PORTNUM-CipherScan_output.txt $pth/$wrkpth/Cipherscan/$IP:$PORTNUM-Analyze_output.txt
            echo "THis scan was performed on $(date)" | tee -a $pth/$wrkpth/SSLScan/$IP:$PORTNUM-sslscan_output.txt $pth/$wrkpth/SSLyze/$IP:$PORTNUM-sslyze_output.txt $pth/$wrkpth/TestSSL/$IP:$PORTNUM-TestSSL_output.txt $pth/$wrkpth/Cipherscan/$IP:$PORTNUM-CipherScan_output.txt $pth/$wrkpth/Cipherscan/$IP:$PORTNUM-Analyze_output.txt
            echo "THis scan was performed by $(whoami)@$(hostname)" | tee -a $pth/$wrkpth/SSLScan/$IP:$PORTNUM-sslscan_output.txt $pth/$wrkpth/SSLyze/$IP:$PORTNUM-sslyze_output.txt $pth/$wrkpth/TestSSL/$IP:$PORTNUM-TestSSL_output.txt $pth/$wrkpth/Cipherscan/$IP:$PORTNUM-CipherScan_output.txt $pth/$wrkpth/Cipherscan/$IP:$PORTNUM-Analyze_output.txt
            echo "--------------------------------------------------" | tee -a $pth/$wrkpth/SSLScan/$IP:$PORTNUM-sslscan_output.txt $pth/$wrkpth/SSLyze/$IP:$PORTNUM-sslyze_output.txt $pth/$wrkpth/TestSSL/$IP:$PORTNUM-TestSSL_output.txt $pth/$wrkpth/Cipherscan/$IP:$PORTNUM-CipherScan_output.txt $pth/$wrkpth/Cipherscan/$IP:$PORTNUM-Analyze_output.txt
            sslscan --xml=$pth/$wrkpth/SSLScan/$IP:$PORTNUM-sslscan_output.xml --ssl3 --tls10 --tls11 $IP:$PORTNUM | tee -a $pth/$wrkpth/SSLScan/$IP:$PORTNUM-sslscan_output.txt
            sslyze --xml_out=$pth/$wrkpth/SSLyze/$IP:$PORTNUM-sslyze.xml --sslv3 --tlsv1 --tlsv1_1 $IP:$PORTNUM | tee -a $pth/$wrkpth/SSLyze/$IP:$PORTNUM-sslyze_output.txt
            testssl -oa "$pth/$wrkpth/TestSSL/TLS" --append -e --fast -p --parallel --sneaky $IP:$PORTNUM | tee -a $pth/$wrkpth/TestSSL/$IP:$PORTNUM-TestSSL_output.txt
            bash /tmp/cipherscan/cipherscan https://$IP:$PORTNUM | tee -a $pth/$wrkpth/Cipherscan/$IP:$PORTNUM-CipherScan_output.txt
            python2 /tmp/cipherscan/analyze.py -t $IP:$PORTNUM -l modern | tee -a $pth/$wrkpth/Cipherscan/$IP:$PORTNUM-Analyze_output.txt
        fi
    done
done
echo "Done scanning"
echo

#Generating final "report"
echo "--------------------------------------------------"
echo "Generating final 'Report'"
echo "--------------------------------------------------"
cat $pth/$wrkpth/SSLScan/*.txt | aha -t "SSLScan Output" >> $pth/$wrkpth/Reports/SSLScan_Master_Output.html
cat $pth/$wrkpth/SSLyze/*.txt | aha -t "SSLyze Output" >> $pth/$wrkpth/Reports/SSLyze_Master_Output.html
cat $pth/$wrkpth/TestSSL/*.txt | aha -t "TestSSL Output" >> $pth/$wrkpth/Reports/TestSSL_Master_Output.html
cat $pth/$wrkpth/Cipherscan/*.txt | aha -t "Cipherscan/Analyze Output" >> $pth/$wrkpth/Reports/Cipherscan_Master_Output.html
cat $pth/$wrkpth/Report/*.html | aha -t "COmbined Report" >> $pth/$wrkpth/Reports/Combined_Report.html

echo "Done validating ciphers & We are done scanning everything!"

#Open reports in Firefox
echo "--------------------------------------------------"
echo "Opening the results now"
echo "--------------------------------------------------"
firefox --new-tab $pth/$wrkpth/Reports/*.html &

# Empty file cleanup
find $pth/$wrkpth/ -size 0c -type f -exec rm -rf {} \;

#Deleting Temp files
# rm -rf /tmp/cipherscan/
# rm $pth/temptargets
# rm $pth/targets2

#De-initialize all variables & set them to NULL
unset ciphr
unset IP
unset OpenPORT
unset PORT
unset PORTNUM
unset pth
unset STAT1
unset STAT2
unset STAT3
unset SVRNAME
unset targets
unset wrkpth
set -u