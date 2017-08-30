apt-get autoremove
apt-get --purge remove && apt-get autoclean
apt-get -f install -y
apt-get install --fix-broken -y
apt-get update
apt-get upgrade && apt-get dist-upgrade
#dpkg-reconfigure -a
dpkg --configure -a
