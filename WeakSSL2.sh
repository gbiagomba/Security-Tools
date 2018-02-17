#Author: Gilles Biagomba
#Program: WeakSSL2.sh
#Description: This script was design to check for weak SSL ciphers.\n

#Requesting target file name
echo "What is the name of the targets file?"
read targets

#Creating workspace
echo "-----------------------------------------------------------------------------------------------------------"
echo "Creating the workspace"
echo "-----------------------------------------------------------------------------------------------------------"
mkdir -p Nmap SSLScan SSLyze TestSSL WeakSSL

#Nmap Scan
echo "-----------------------------------------------------------------------------------------------------------"
echo "Performing the SSL scan using Nmap"
echo "-----------------------------------------------------------------------------------------------------------"
nmap -sS -sV --script=ssh2-enum-algos,ssl-enum-ciphers,rdp-enum-encryption -iL $targets -oA Nmap/nmap_output
xsltproc Nmap/nmap_output.xml -o Nmap_SSL_Output.html

#SSL Scan
echo "-----------------------------------------------------------------------------------------------------------"
echo "Performing the SSL scan using sslscan"
echo "-----------------------------------------------------------------------------------------------------------"
cd SSLScan
sslscan --targets=$target --xml=sslscan_output.xml | aha > ../sslscan_output.html
cd ..

#SSLyze Scan
echo "-----------------------------------------------------------------------------------------------------------"
echo "Performing the SSL scan using sslyze"
echo "-----------------------------------------------------------------------------------------------------------"
sslyze --targets_in=$targets --xml_out=SSLyze/SSLyze.xml --regular | aha > sslyze_output.html

#TestSSL Scan
echo "-----------------------------------------------------------------------------------------------------------"
echo "Performing the SSL scan using testssl"
echo "-----------------------------------------------------------------------------------------------------------"
cd TestSSL
testssl --file $targets --log --csv | aha > ../testssl_output.html
cd ..
echo "-----------------------------------------------------------------------------------------------------------"

#OpenSSL - Manually checking weak ciphers
#./Birthday_test.sh | aha > WeakSSL.html
echo "-----------------------------------------------------------------------------------------------------------"
echo "Validating results using OpenSSL"
echo "-----------------------------------------------------------------------------------------------------------"
for c in $(cat targets); do
 for i in $(cat WeakCiphers.txt); do 
  echo "----------------------------------------------SSL3--------------------------------------------------------"
  echo "Address: $c"
  echo "Cipher: $i"
  openssl s_client -connect $c:443 -ssl3 -cipher $i | aha >> WeakSSL/$c-WeakCiphers.html
  echo "----------------------------------------------TLSv1--------------------------------------------------------"
  echo "Address: $c"
  echo "Cipher: $i"
  openssl s_client -connect $c:443 -tls1 -cipher $i | aha >> WeakSSL/$c-WeakCiphers.html
  echo "----------------------------------------------TLSv1.1------------------------------------------------------"
  echo "Address: $c"
  echo "Cipher: $i"
  openssl s_client -connect $c:443 -tls1_1 -cipher $i | aha >> WeakSSL/$c-WeakCiphers.html
  echo "---------------------------------------------TLSv1.2-------------------------------------------------------"
  echo "Address: $c"
  echo "Cipher: $i"
  openssl s_client -connect $c:443 -tls1_2 -cipher $i | aha >> WeakSSL/$c-WeakCiphers.html
  echo "-----------------------------------------------------------------------------------------------------------"
 done
done

#Convert XML files to HTML
#xsltproc <nmap-output.xml> -o <nmap-output.html> 
