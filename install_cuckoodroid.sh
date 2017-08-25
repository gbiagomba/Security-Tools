git clone https://github.com/idanr1986/cuckoodroid-2.0
cd cuckoodroid-2.0
apt-get install -y python git python-pip
apt-get install -y libffi-dev libssl-dev libxml2-dev libxslt1-dev libjpeg8-dev zlib1g-dev
pip install -r /requirements.txt
#apt-get install -y qemu-kvm libvirt-bin # when using esx server
