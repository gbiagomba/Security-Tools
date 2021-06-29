brew install pidof
curl -# -o /tmp/armitage.tgz http://www.fastandeasyhacking.com/download/armitage-latest.tgz
tar -xvzf /tmp/armitage.tgz -C /usr/local/share
bash -c "echo \'/usr/bin/java\' -jar /usr/local/share/armitage/armitage.jar \$\*" > /usr/local/share/armitage/armitage
perl -pi -e 's/armitage.jar/\/usr\/local\/share\/armitage\/armitage.jar/g' /usr/local/share/armitage/teamserver
ln -s /usr/local/share/armitage/armitage /usr/local/bin/armitage
ln -s /usr/local/armitage/teamserver /usr/local/bin/teamserver

# For launching Armitage
sudo -E armitage

# For launching msfconsole
sudo -E msfconsole
