#https://jerrygamblin.com/2017/08/24/disallow-million-most-common-passwords/
apt-get install libpam-cracklib -y
wget https://raw.githubusercontent.com/danielmiessler/SecLists/master/Passwords/10_million_password_list_top_1000000.txt /usr/share/dict/ -O /usr/share/dict/million.txt
create-cracklib-dict /usr/share/dict/million.txt
