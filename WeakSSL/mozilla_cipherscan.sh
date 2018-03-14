function pause()
{
   read -p "$*"
}

#Mozilla Cipherscan
echo "--------------------------------------------------"
echo "Performing the SSL scan using cipherscan"
echo "--------------------------------------------------"
pth=$(pwd)
echo "This is the path: $pth"
pause 'Press [Enter] key to continue...'

cd /tmp/
rm -rf cipherscan
git clone https://github.com/mozilla/cipherscan
cd cipherscan/
echo "YOu installed cipherscan" && $(pwd)
pause 'Press [Enter] key to continue...'

for IP in $(cat $pth/targets); do
    for PORTS in $(cat Ports);do
	echo "You are scanning $IP:$PORTS"
        bash /tmp/cipherscan/cipherscan $IP:$PORTS | aha -t "Cipherscan output"  > $pth/Cipherscan/$IP-$PORTS-Cipherscan_detailed_output.html
        python2 analyze -t $IP:$PORTS | aha -t "Cipherscan output"  >> $pth/Reports/CipherScan_output.html
	pause 'Press [Enter] key to continue...'
    done
done
cd $pth
echo "Done scanning with cipherscan"
