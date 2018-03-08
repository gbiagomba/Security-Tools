#Initializing the "PORT" array 
declare -a PORT=(22 25 443 567 593 808 1433 3389 4443 4848 7103 7201 8443 8888)

#Requesting target file name
echo "What is the name of the target file?"
read targets
echo "What is the name of the workspace?"
read workspace

#Performing a Sniper scan
for IP in $(cat $targets); do
    for PORTNUM in ${PORT[*]};do
		sniper -w $workspace -t $IP -m webporthttps -p $PORTNUM
	done
done

#De-initialize all variables & setting them to NULL
unset IP
unset PORTNUM
unset PORT
unset targets
set -u