#Author: Gilles Biagomba
#Program: WeakSSL2.sh
#Description: This script was design to check for weak SSL ciphers.\n
#Convert XML files to HTML
#xsltproc <nmap-output.xml> -o <nmap-output.html> 

#Requesting target file name
echo "What is the name of the targets file?"
read targets

#Creating workspace
echo "--------------------------------------------------"
echo "Creating the workspace"
echo "--------------------------------------------------"
mkdir -p Nmap SSLScan SSLyze Cipherscan
mkdir -p TestSSL WeakSSL Reports
echo "Done creating workspace"

#Nmap Scan
echo "--------------------------------------------------"
echo "Performing the SSL scan using Nmap"
echo "--------------------------------------------------"
nmap -sS -sV --script=ssh2-enum-algos,ssl-enum-ciphers,rdp-enum-encryption -iL $targets -oA Nmap/nmap_output
xsltproc Nmap/nmap_output.xml -o Reports/Nmap_SSL_Output.html
echo "Done scanning with nmap"

#SSL Scan - Needs troubleshooting
echo "--------------------------------------------------"
echo "Performing the SSL scan using sslscan"
echo "--------------------------------------------------"
sslscan --targets=$targets --xml=SSLScan/sslscan_output.xml | aha -t "SSLScan Output" > Reports/sslscan_output.html
echo "Done scanning with sslscan"

#SSLyze Scan
echo "--------------------------------------------------"
echo "Performing the SSL scan using sslyze"
echo "--------------------------------------------------"
sslyze --targets_in=$targets --xml_out=SSLyze/SSLyze.xml --regular | aha -t "SSLyze Output"  > Reports/sslyze_output.html
#sslyze --targets_in=$targets --xml_out=/dev/stdout --regular --quiet | xsltproc rsc/sslyze.xsl - > Reports/sslyze.html
echo "Done scanning with sslyze"

#TestSSL Scan
echo "--------------------------------------------------"
echo "Performing the SSL scan using testssl"
echo "--------------------------------------------------"
cd TestSSL
testssl --file ../$targets --log --csv | aha -t "TestSSL output"  > ../Reports/testssl_output.html
cd ..
echo "Done scanning with testssl"

#Mozilla Cipherscan
echo "--------------------------------------------------"
echo "Performing the SSL scan using cipherscan"
echo "--------------------------------------------------"
pth = $(pwd)
cd /tmp/
git clone https://github.com/mozilla/cipherscan
cd cipherscan/
for IP in $(cat $targets); do
    bash cipherscan $IP | aha -t "Cipherscan output"  > $pth/Cipherscan/cipherscan_detailed_output.html
    python2 analyze -t $IP | aha -t "Cipherscan output"  > $pth/Reports/CipherScan_output.html
done
cd $pth
echo "Done scanning with cipherscan"

#OpenSSL - Manually checking weak ciphers (Needs to be fixed)
#./Birthday_test.sh | aha > WeakSSL.html
# echo "--------------------------------------------------"
# echo "Validating results using OpenSSL"
# echo "--------------------------------------------------"
# for c in $(cat $targets); do
#  for i in $(cat WeakCiphers.txt); do
#   echo "---------------------------------------------TLSv1---------------------------------------------------------"
#   echo "Address: $c"
#   echo "Cipher: $i"
#   openssl s_client -connect $c:443 -tls1 -cipher $i | aha >> WeakSSL/$c-WeakCiphers.html
#   echo "---------------------------------------------TLSv1.1-------------------------------------------------------"
#   echo "Address: $c"
#   echo "Cipher: $i"
#   openssl s_client -connect $c:443 -tls1_1 -cipher $i | aha >> WeakSSL/$c-WeakCiphers.html
#   echo "---------------------------------------------TLSv1.2-------------------------------------------------------"
#   echo "Address: $c"
#   echo "Cipher: $i"
#   openssl s_client -connect $c:443 -tls1_2 -cipher $i | aha >> WeakSSL/$c-WeakCiphers.html
#   echo "--------------------------------------------------"
#  done
# done

echo "Done validating ciphers & We are done scanning everything!"

#Open reports in Firefox
echo "--------------------------------------------------"
echo "Opening the results now"
echo "--------------------------------------------------"
firefox --new-tab $pth/Reports/*.html

#De-initialize all variables & set them to NULL
unset pth
unset IP
unset targets
set -u