#Author: Gilles Biagomba
#Program: WeakSSL2.sh
#Description: This script was design to check for weak SSL ciphers.\n

#Requesting target file name
echo "What is the name of the targets file?"
read targets

#Creating workspace
mkdir -p Nmap SSLyze TestSSL WeakSSL

#Nmap Scan
nmap -sS -sV -sC ssh2-enum-algos,ssl-enum-ciphers -iL $targets -oA Nmap/nmap_output.txt | aha > nmap_output.html

#SSLyze Scan
sslyze --targets_in=$targets --xml_out=SSLyze/SSLyze.xml --regular | aha > sslyze_output.html

#TestSSL Scan
cd TestSSL
testssl --file $targets --log --csv | aha > ../testssl_output.html

#Checking weak ciphers manually using OpenSSL
#./Birthday_test.sh | aha > WeakSSL.html
for c in $(cat targets); do
 for i in $(cat WeakCiphers.txt); do 
  echo "----------------------------------------------SSL3--------------------------------------------------------"
  echo "Address: $c"
  echo "Cipher: $i"
  echo "-----------------------------------------------------------------------------------------------------------"
  openssl s_client -connect $c:443 -ssl3 -cipher $i | aha >> WeakSSL/$c-WeakCiphers.html
  echo "----------------------------------------------TLSv1--------------------------------------------------------"
  echo "Address: $c"
  echo "Cipher: $i"
  echo "-----------------------------------------------------------------------------------------------------------"
  openssl s_client -connect $c:443 -tls1 -cipher $i | aha >> WeakSSL/$c-WeakCiphers.html
  echo "----------------------------------------------TLSv1.1------------------------------------------------------"
  echo "Address: $c"
  echo "Cipher: $i"
  echo "-----------------------------------------------------------------------------------------------------------"
  openssl s_client -connect $c:443 -tls1_1 -cipher $i | aha >> WeakSSL/$c-WeakCiphers.html
  echo "---------------------------------------------TLSv1.2-------------------------------------------------------"
  echo "Address: $c"
  echo "Cipher: $i"
  echo "-----------------------------------------------------------------------------------------------------------"
  openssl s_client -connect $c:443 -tls1_2 -cipher $i | aha >> WeakSSL/$c-WeakCiphers.html
  echo "-----------------------------------------------------------------------------------------------------------"
 done
done
