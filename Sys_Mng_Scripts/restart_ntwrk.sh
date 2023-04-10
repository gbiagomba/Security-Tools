#!/usr/bin/env bash
# Author: Gilles Biagomba
# Filaname: restart_ntwk.sh
# Description: Restarts network interfaces on UNX/NIX machines (including MacOS)

# Setting global var
HOST=$1
wrkpth=$(mktemp -d)
# SUDOEH="timeout 5 sudo -EH"
SUDOEH="sudo -EH"
restartCounter="0"
stopCounter="0"

# Checking varaibles
if [ -z $HOST ]; then HOST="www.amazon.com"; fi

# Tool bannerecho "
echo "
███╗░░██╗███████╗████████╗░██╗░░░░░░░██╗░█████╗░██████╗░██╗░░██╗
████╗░██║██╔════╝╚══██╔══╝░██║░░██╗░░██║██╔══██╗██╔══██╗██║░██╔╝
██╔██╗██║█████╗░░░░░██║░░░░╚██╗████╗██╔╝██║░░██║██████╔╝█████═╝░
██║╚████║██╔══╝░░░░░██║░░░░░████╔═████║░██║░░██║██╔══██╗██╔═██╗░
██║░╚███║███████╗░░░██║░░░░░╚██╔╝░╚██╔╝░╚█████╔╝██║░░██║██║░╚██╗
╚═╝░░╚══╝╚══════╝░░░╚═╝░░░░░░╚═╝░░░╚═╝░░░╚════╝░╚═╝░░╚═╝╚═╝░░╚═╝

░██╗░░░░░░░██╗██╗███████╗░█████╗░██████╗░██████╗░██████╗░██╗░░░██╗
░██║░░██╗░░██║██║╚════██║██╔══██╗██╔══██╗██╔══██╗██╔══██╗╚██╗░██╔╝
░╚██╗████╗██╔╝██║░░███╔═╝███████║██████╔╝██║░░██║██████╔╝░╚████╔╝░
░░████╔═████║░██║██╔══╝░░██╔══██║██╔══██╗██║░░██║██╔══██╗░░╚██╔╝░░
░░╚██╔╝░╚██╔╝░██║███████╗██║░░██║██║░░██║██████╔╝██║░░██║░░░██║░░░
"

# Pause function
function pause()
{
   read -p "$*"
}

# Banner function
function banner()
{
    echo
    echo "--------------------------------------------------"
    echo "$1 at $current_time" && say "$1"
    echo "--------------------------------------------------"
}

# Nmap function
function connection_test()
{
  sleep 10 # && wait 10
  banner "Running a quick nmap"
  $SUDOEH nmap -T5 --min-rate 300 --resolve-all -PA"21-23,25,53,79,80-83,88,110,111,135,139,161,179,443,445,497,515,535,548,993,1025,1028,1029,1917,2869,3389,5000,5060,6000,8080,9001,9100,49000" -PE -PM -PP -PO -PR -PS"21-23,25,53,79,80-83,88,110,111,135,139,161,179,443,445,497,515,535,548,993,1025,1028,1029,1917,2869,3389,5000,5060,6000,8080,9001,9100,49000" -PU"42,53,67-68,88,111,123,135,137,138,161,500,3389,5355" -PY"22,80,179,5060" -R --reason --resolve-all -sn -oA "$wrkpth/nmap_pingsweep" $HOST
  $SUDOEH nmap -6 -T5 --min-rate 300 --resolve-all -PA"21-23,25,53,79,80-83,88,110,111,135,139,161,179,443,445,497,515,535,548,993,1025,1028,1029,1917,2869,3389,5000,5060,6000,8080,9001,9100,49000" -PS"21-23,25,53,79,80-83,88,110,111,135,139,161,179,443,445,497,515,535,548,993,1025,1028,1029,1917,2869,3389,5000,5060,6000,8080,9001,9100,49000" -PU"42,53,67-68,88,111,123,135,137,138,161,500,3389,5355" -PY"22,80,179,5060" -R --reason --resolve-all -sn -oA "$wrkpth/nmap_pingsweep6" $HOST
  open $wrkpth
  banner "Done running network mapper!"

  # Checking to see if previous attempt worked
  nmap_pingsweep=`tail -n 1 "$wrkpth/nmap_pingsweep.gnmap" | cut -d "(" -f 2 | cut -d ")" -f 1 | cut -d " " -f 1`
  nmap_pingsweep6=`tail -n 1 "$wrkpth/nmap_pingsweep6.gnmap" | cut -d "(" -f 2 | cut -d ")" -f 1 | cut -d " " -f 1`
  if [[ $nmap_pingsweep -eq 0 ]] && [[ $nmap_pingsweep6 -eq 0 ]]; then 
    say "Network connection is still broken, please hold on while we try again" && restartCounter=$((restartCounter++))
    main
  else
    say "Network connection fixed" && stopCounter=$((stopCounter++))
    sleep 180 && connection_test
  fi
}

# Main function
function main()
{
  # checking counter
  if [[ $restartCounter == 3 ]]; then
    say "We tried to reset your NIC card 3 times, to no avail. We recommend restarting your machine"
    pause 'Press [Enter] key to continue...'
    $SUDOEH reboot -q now
  elif [[ $stopCounter == 3 ]]; then
    say "We have done three successful network checks, no need to keep testing" && exit
  fi

  # Resetting the jawn
  for i in $(ifconfig -a | cut -d ":" -f 1 | tr " " "\n" | tr -d "\t" | grep -i en | sort -fu); do
    banner "resetting $i"; $SUDOEH ifconfig $i down; $SUDOEH ifconfig $i up; ifconfig -u $i; echo
  done

  # Reset DNS
  banner "Resetting DNS"
  $SUDOEH dscacheutil -flushcache
  $SUDOEH killall -HUP mDNSResponder 

  # Checking network configs
  banner "Checking inet"; ifconfig -a | grep -i "en" | grep -i "inet" | tr -d "\t"; echo

  # Checking connection
  connection_test
}

main
