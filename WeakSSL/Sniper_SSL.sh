#Initializing the "PORT" array 
declare -a PORT=(22 25 443 567 593 808 1433 3389 4443 4848 7103 7201 8443 8888)

#Declaring a function
function pause()
{
   read -p "$*"
}
 
function main()
{
	#Requesting target file name
	echo "What is the name of the target file?"
	read targets
	echo
	echo "What is the name of the workspace?"
	read workspace
	echo

	#Performing a Sniper scan
	for IP in $(cat $targets); do
		for PORTNUM in ${PORT[*]}; do
			sniper -w $workspace -t $IP -m webporthttps -p $PORTNUM
		done
	done
}

#Making sure sniper is installed
APP=$(ls /usr/bin/ | grep sniper)
if [ "$APP" == "sniper" ]; then
	echo "Sniper is installed, carry on"
	echo
	main
else 
	echo "You need to install sniper"
	echo "Do you want me to install it for you? (y/n)"
	read answer
	echo
	case $answer in
		y|Y|yes|Yes)
			cd /opt/
			git clone https://github.com/1N3/Sn1per
			cd Sn1per
			bash install.sh
			main
			;;
		n|N|no|No)
			echo "go to: https://github.com/1N3/Sn1per"
			pause 'Press [Enter] key to exit...'
			exit
			;;
	esac
fi

#De-initialize all variables & setting them to NULL
unset answer
unset APP
unset IP
unset PORTNUM
unset PORT
unset targets
set -u
