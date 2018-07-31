curl -s https://updates.signal.org/desktop/apt/keys.asc | sudo apt-key add -
echo "deb [arch=amd64] https://updates.signal.org/desktop/apt xenial main" | sudo tee -a /etc/apt/sources.list.d/signal-xenial.list
apt update
apt install signal-desktop -y

#curl -s https://updates.signal.org/desktop/apt/keys.asc | sudo apt-key add - && echo "deb [arch=amd64] https://updates.signal.org/desktop/apt xenial main" | sudo tee -a /etc/apt/sources.list.d/signal-xenial.list && sudo apt update && sudo apt install signal-desktop
