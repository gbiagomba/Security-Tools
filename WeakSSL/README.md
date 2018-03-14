# Weak SSL Scanner & Sniper_SSL
The script below scans servers for SSL misconfigurations (e.g., weak ciphers, weak encryption protocols, etc) using nmap, sslscan, sslyze, testssl and openssl. I use multiple tools because I want to cross reference and validate all findings without having to manually run additional tools.

## Requirements
### Sniper_SSL
you will need sniper installed https://github.com/1N3/Sn1per

### WeakSSL Scanner
YOu will need nmap, sslscan, sslyze, and testssl installed
- Run packagehundler install_flag sslyze sslscan testssl.sh
- Debian: apt install sslyze sslscan testssl.sh

## Usage
./WeakSSLx.x.xsh
./Sniper_SSL.sh

You will be prompted for the name of the target file, type it in and dont forget the extension (assuming there is one).
YOu should also note that by default it will look in the current working directory (pwd).
If the target file is elsewhere, you will need to manually enter the path to the file.
Lastly, make sure you copy the "rsc" folder and the "WeakCiphers.txt" file

Then seat back and let it do its thing.