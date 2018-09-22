REM Author: Gilles S. Biagomba
REM Program: MozillaFTP.bat
REM Description: This program is designed to connect to the mozilla ftp \n
REM contd. and download the lastest version of firefox

@echo off

del C:\PCI\Other\Misc\Browsers\FireFox C:\Users\Public\Documents\Firefox\*.exe /f /q
ftp -n -a -s:ftpcmd.dat ftp.mozilla.org

pause