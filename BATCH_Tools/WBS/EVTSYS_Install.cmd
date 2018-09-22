@echo off
REM rd C:\Users\Public\Documents\EVTSYS /S /Q
mkdir C:\Users\Public\Documents\EVTSYS 
pushd \\dbphqpcim01\c$\
robocopy /E /Z /r:N /w:100 "\PCI\Other\Misc\SNARE Replacement\EVTSYS" C:\Users\Public\Documents\EVTSYS
popd
C:\Users\Public\Documents\EVTSYS\Evtsys_4.5.1_32-Bit\32-Bit\evtsys.exe -i -h 192.168.1.20 -p 514 -l 0
net start "Eventlog to Syslog"
"C:\Program Files\Snare\unins000.exe" -q