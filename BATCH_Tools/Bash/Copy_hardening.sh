#Files to copy
sudo cp /etc/ssh/sshd_config /home/support/Documents/Hardening
sudo cp /etc/fail2ban/jail.conf /home/support/Documents/Hardening
sudo cp /etc/sysctl.conf /home/support/Documents/Hardening
sudo cp /etc/apache2/conf-enabled/security.conf /home/support/Documents/Hardening
sudo cp /etc/chkrootkit.conf /home/support/Documents/Hardening
sudo cp /etc/default/rkhunter /home/support/Documents/Hardening
sudo cp /etc/modsecurity/modsecurity.conf /home/support/Documents/Hardening
sudo cp /etc/apache2/mods-available/security2.conf /home/support/Documents/Hardening

#services to reload
# service ssh restart
# service ssh reload
# sudo sysctl -p

# #misc
# mv /etc/ssh/sshd_config /etc/ssh/sshd_config_bkup
# mv /etc/fail2ban/fail2ban.conf /etc/fail2ban/fail2ban.conf_bkup 
# mv /etc/sysctl .conf /etc/sysctl.conf_bkup

# sudo cp /home/adminuser/Documents/sshd_config /etc/ssh/ 
# sudo cp /home/adminuser/Documents/fail2ban.conf /etc/fail2ban/
# sudo cp /home/adminuser/Documents/sysctl.conf /etc/ 

# Header unset ETag
# FileETag None