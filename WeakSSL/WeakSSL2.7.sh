#Author: Gilles Biagomba
#Program: WeakSSL2.5.sh
#Description: This script was design to check for weak SSL ciphers.\n
#Convert XML files to HTML
#xsltproc <nmap-output.xml> -o <nmap-output.html> 

#Initializing all variables 
declare -a PORT=(22 25 443 567 593 808 1433 3389 4443 4848 7103 7201 8443 8888)
declare -a Ciphers=(DES-CBC-SHA DES-CBC3-SHA ECDH-ECDSA-DES-CBC3-SHA ECDH-ECDSA-RC4-SHA ECDH-RSA-DES-CBC3-SHA ECDH-RSA-RC4-SHA ECDHE-ECDSA-DES-CBC3-SHA ECDHE-ECDSA-RC4-SHA ECDHE-RSA-DES-CBC3-SHA ECDHE-RSA-RC4-SHA EDH-DSS-DES-CBC-SHA EDH-DSS-DES-CBC3-SHA EDH-RSA-DES-CBC-SHA EDH-RSA-DES-CBC3-SHA PSK-3DES-EDE-CBC-SHA PSK-AES128-CBC-SHA PSK-AES256-CBC-SHA PSK-RC4-SHA RC4-MD5 RC4-SHA SRP-3DES-EDE-CBC-SHA SRP-AES-128-CBC-SHA SRP-AES-256-CBC-SHA SRP-DSS-3DES-EDE-CBC-SHA SRP-DSS-AES-128-CBC-SHA SRP-DSS-AES-256-CBC-SHA SRP-RSA-3DES-EDE-CBC-SHA SRP-RSA-AES-128-CBC-SHA SRP-RSA-AES-256-CBC-SHA)
STAT1="Up"
STAT2="open"
pth=$(pwd)

#Requesting target file name
echo "What is the name of the targets file? The file with all the IP addresses"
read targets

#Creating workspace
echo "--------------------------------------------------"
echo "Creating the workspace"
echo "--------------------------------------------------"
mkdir -p Nmap SSLScan SSLyze Cipherscan
mkdir -p TestSSL WeakSSL Reports SSH-Audit
echo "Done creating workspace"

#Nmap Scan
echo "--------------------------------------------------"
echo "Performing the SSL scan using Nmap"
echo "--------------------------------------------------"
nmap -sS -sV --script=ssh2-enum-algos,ssl-enum-ciphers,rdp-enum-encryption,vulners -R -iL $targets -p 22,25,443,567,593,808,1433,3389,4443,4848,7103,7201,8443,8888 -oA Nmap/nmap_output
xsltproc Nmap/nmap_output.xml -o Reports/Nmap_SSL_Output.html
echo "Done scanning with nmap"

#SSL Scan - Needs troubleshooting
echo "--------------------------------------------------"
echo "Performing the SSL scan using sslscan"
echo "--------------------------------------------------"
for IP in $(cat $pth/$targets); do
    for PORTNUM in ${PORT[*]};do
        STAT1=$(cat nmap_output.gnmap | grep $IP | grep "Status: Up" -m 1 -o | cut -c 9-10)
        STAT2=$(cat nmap_output.gnmap | grep $IP | grep "Ports: $PORTNUM/open" -m 1 -o | cut -c 11-15)
        if [$STAT1 == "Up" && $STAT2 == "open"];then
            sslscan --xml=SSLScan/sslscan_output.xml $IP:$PORTNUM | aha -t "SSLScan Output" >> Reports/sslscan_output.html
        fi
    done
done
echo "Done scanning with sslscan"

#SSLyze Scan
echo "--------------------------------------------------"
echo "Performing the SSL scan using sslyze"
echo "--------------------------------------------------"
for IP in $(cat $pth/$targets); do
    for PORTNUM in ${PORT[*]};do
        STAT1=$(cat nmap_output.gnmap | grep $IP | grep "Status: Up" -m 1 -o | cut -c 9-10)
        STAT2=$(cat nmap_output.gnmap | grep $IP | grep "Ports: $PORTNUM/open" -m 1 -o | cut -c 11-15)
        if [$STAT1 == "Up" && $STAT2 == "open"];then
            sslyze --xml_out=SSLyze/SSLyze.xml --regular $IP:$PORTNUM | aha -t "SSLyze Output"  >> Reports/sslyze_output.html
        fi
    done
done
echo "Done scanning with sslyze"

#TestSSL Scan
echo "--------------------------------------------------"
echo "Performing the SSL scan using testssl"
echo "--------------------------------------------------"
cd TestSSL #You step into the folder because the testssl command uses the --log & --csv flags
for IP in $(cat $pth/$targets); do
    for PORTNUM in ${PORT[*]};do
        STAT1=$(cat nmap_output.gnmap | grep $IP | grep "Status: Up" -m 1 -o | cut -c 9-10)
        STAT2=$(cat nmap_output.gnmap | grep $IP | grep "Ports: $PORTNUM/open" -m 1 -o | cut -c 11-15)
        if [$STAT1 == "Up" && $STAT2 == "open"];then
            testssl --log --csv $IP:$PORTNUM | aha -t "TestSSL output"  >> ../Reports/testssl_output.html
        fi
    done
done
cd ..
echo "Done scanning with testssl"

#Mozilla Cipherscan
echo "--------------------------------------------------"
echo "Performing the SSL scan using cipherscan"
echo "--------------------------------------------------"
cd /tmp/
git clone https://github.com/mozilla/cipherscan
cd cipherscan/
for IP in $(cat $pth/$targets); do
    for PORTNUM in ${PORT[*]};do
        STAT1=$(cat nmap_output.gnmap | grep $IP | grep "Status: Up" -m 1 -o | cut -c 9-10)
        STAT2=$(cat nmap_output.gnmap | grep $IP | grep "Ports: $PORTNUM/open" -m 1 -o | cut -c 11-15)
        if [$STAT1 == "Up" && $STAT2 == "open"];then
            echo "You are scanning $IP:$PORTNUM"
            bash cipherscan $IP:$PORTNUM | aha -t "Cipherscan output"  > $pth/Cipherscan/$IP-$PORTNUM-Cipherscan_detailed_output.html
            python2 analyze -t $IP:$PORTNUM | aha -t "Cipherscan output"  >> $pth/Reports/CipherScan_output.html
        fi
    done
done
cd $pth
echo "Done scanning with cipherscan"

#Mozilla SSH Audit
echo "--------------------------------------------------"
echo "Performing the SSL scan using SSH Audit"
echo "--------------------------------------------------"
git clone https://github.com/arthepsy/ssh-audit
cd ssh-audit/
for IP in $(cat $pth/$targets); do
    for PORTNUM in ${PORT[*]};do
        STAT1=$(cat nmap_output.gnmap | grep $IP | grep "Status: Up" -m 1 -o | cut -c 9-10)
        STAT2=$(cat nmap_output.gnmap | grep $IP | grep "Ports: $PORTNUM/open" -m 1 -o | cut -c 11-15)
        if [$STAT1 == "Up" && $STAT2 == "open"];then
            echo "You are scanning $IP:$PORTNUM"
            echo "You are scanning $IP:$PORTNUM" | aha -t "SSH-Audit output"  >> $pth/SSH-Audit/$IP-SSH-Audit_detailed_output.html
            bash ssh-audit.py $IP:$PORTNUM | aha -t "SSH-Audit output"  >> $pth/SSH-Audit/$IP-SSH-Audit_detailed_output.html
        fi
    done
done
cd $pth
echo "Done scanning with cipherscan"

#OpenSSL - Manually checking weak ciphers (Needs to be fixed)
echo "--------------------------------------------------"
echo "Validating results using OpenSSL"
echo "--------------------------------------------------"
cd /tmp/cipherscan/
for IP in $(cat $pth/$targets); do
    for PORTNUM in ${PORT[*]};do
        for ciphr in ${Ciphers[*]};do
            echo "---------------------------------------------SSLv3---------------------------------------------------------"
            echo "Address: $IP"
            echo "Cipher: $Ciphers"
            bash openssl s_client -connect $IP:$PORTNUM -ssl3 -cipher $ciphr | aha -t "OpenSSL Scan" >> WeakSSL/$IP-WeakCiphers.html
            echo "---------------------------------------------TLSv1---------------------------------------------------------"
            echo "Address: $IP"
            echo "Cipher: $Ciphers"
            bash openssl s_client -connect $IP:$PORTNUM -tls1 -cipher $ciphr | aha -t "OpenSSL Scan" >> WeakSSL/$IP-WeakCiphers.html
            echo "---------------------------------------------TLSv1.1-------------------------------------------------------"
            echo "Address: $IP"
            echo "Cipher: $Ciphers"
            bash openssl s_client -connect $IP:$PORTNUM -tls1_1 -cipher $ciphr | aha -t "OpenSSL Scan" >> WeakSSL/$IP-WeakCiphers.html
            echo "---------------------------------------------TLSv1.2-------------------------------------------------------"
            echo "Address: $IP"
            echo "Cipher: $Ciphers"
            bash openssl s_client -connect $IP:$PORTNUM -tls1_2 -cipher $ciphr | aha -t "OpenSSL Scan" >> WeakSSL/$IP-WeakCiphers.html
            echo "--------------------------------------------------"
        done
    done
done
cd $pth

echo "Done validating ciphers & We are done scanning everything!"

#Open reports in Firefox
echo "--------------------------------------------------"
echo "Opening the results now"
echo "--------------------------------------------------"
firefox --new-tab $pth/Reports/*.html

#De-initialize all variables & set them to NULL
unset ciphr
unset pth
unset IP
unset PORT
unset PORTNUM
unset STAT1
unset STAT2
unset targets
set -u
