#Adding username Master1
useradd -m Master1 
chage -d 0 Master1 
usermod Master1 -g root
#Adding username Neo
useradd -m Neo 
chage -d 0 Neo 
usermod Neo -g root
#Adding username Morpheus
useradd -m Morpheus 
chage -d 0 Morpheus  
usermod Morpheus -g root
#Adding username Oracle
useradd -m Oracle 
chage -d 0 Oracle
usermod Oracle -g root