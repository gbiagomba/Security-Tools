#!/usr/bin/env bash

#Author: Gilles S. Biagomba
#Program: $Tron 2.0
#Description: This program automates the Ubuntu 8 to 10 upgrade & include security\n
#Links for the hardening:
#http://www.lampnode.com/linux/howto-harden-ubuntu-1404-after-installation/
#http://blog.mattbrock.co.uk/hardening-the-security-on-ubuntu-server-14-04/

# Checking user is root
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

# Ensuring system is debian based
OS_CHK=$(cat /etc/os-release | grep -o debian)
if [ "$OS_CHK" != "debian" ]; then
    echo "Unfortunately this install script was written for debian based distributions only, sorry!"
    exit
fi

#Check for updates and upgrades again
apt-get update --yes
apt-get upgrade --yes

#Install security applications
apt-get install clamav --yes
apt-get install chkrootkit --yes
apt-get install rkhunter --yes
apt-get install lynis --yes
apt-get install gufw --yes
apt-get install fail2ban --yes
apt-get install logwatch --yes
apt-get install libdate-manip-perl --yes
apt-get install acct --yes
#apt-get install tiger --yes

#Limit su access to administrators only
dpkg-statoverride --update --add root sudo 4750 /bin/su

#Moving essential files
mv /etc/modsecurity/modsecurity.conf-recommended /etc/modsecurity/modsecurity.conf

#Backing up existing configuration files
mv /etc/ssh/sshd_config /etc/ssh/sshd_config_bkup
mv /etc/fail2ban/fail2ban.conf /etc/fail2ban/fail2ban.conf_bkup 
mv /etc/sysctl .conf /etc/sysctl.conf_bkup
mv /etc/apache2/conf-enabled/security.conf /etc/apache2/conf-enabled/security.conf_bkup
mv /etc/chkrootkit.conf /etc/chkrootkit.conf_bkup
mv /etc/default/rkhunter /etc/default/rkhunter_bkup

#Copying new configuration file
cp lib/sshd_config /etc/ssh/ 
cp lib/fail2ban.conf /etc/fail2ban/
cp lib/sysctl.conf /etc/ 
cp lib/security.conf /etc/apache2/conf-enabled/
cp lib/chkrootkit.conf /etc/
cp lib/rkhunter /etc/default/

#Setting up cron jobs
cp lib/pacct-report.sh /etc/cron.weekly/
mv /etc/cron.daily/00logwatch /etc/cron.weekly/
mv /etc/cron.weekly/rkhunter /etc/cron.weekly/rkhunter_update
mv /etc/cron.daily/rkhunter /etc/cron.weekly/rkhunter_run
mv /etc/cron.daily/chkrootkit /etc/cron.weekly/

#Prevent none admin users from running sudo
dpkg-statoverride --update --add root sudo 4750 /bin/su

#Allow Apache hardening to go through
ln -s /etc/apache2/mods-available/headers.load /etc/apache2/mods-enabled/headers.load

#Enable process accounting
touch /var/log/wtmp

#Configure & Enable firewall
ufw default allow outgoing
ufw default deny incoming
ufw limit 2222/tcp
#ufw allow smtp
ufw allow 139
ufw allow 445
ufw allow 10000
ufw allow samba
ufw allow http
ufw logging high
ufw --force enable

#Reload & restart services
service ssh reload
service ssh restart
service fail2ban reload
service fail2ban restart
service apache2 reload
service apache2 restart
sudo sysctl -p

#Run all newly installed security tools
rkhunter --update -q
rkhunter --propupd -q
rkhunter --check -q
chkrootkit -q
lynis -c -q
rkhunter -c -q

#Checks again to see what OS & Kernel are installed
lsb_release -a >> /root/OS_installed.txt
uname -a >> /root/kernel_installed.txt

#Cleaning up the mess
apt-get check
apt-get autoclean
apt-get autoremove

#Launch the system upgrade
do-release-upgrade -f DistUpgradeViewNonInteractive

#restart the box
shutdown -r now
