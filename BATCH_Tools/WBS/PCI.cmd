@echo off

REM Author: Gilles S. Biagomba
REM Program: PCI Auditor
REM Description: This program was designed to fetch information off the PCI machines

REM Change the title & output message to user
title PCI Audit Script
echo Please do not close this box...

REM Makes folder with machine name & Creates a Report directory
mkdir "C:\PCI\%computername%\%date:/=-%\Report"
cd "C:\PCI\%computername%\%date:/=-%\"

REM Pulls Installed Applications off the machine
echo Gathering list of installed applications on the machine...1/8
wmic product get name,version, InstallDate /format:list >> Report\%computername%_Installed_Application.txt
wmic product list full /format:csv >> Report\%computername%_Installed_Application.csv

REM Pulls list of running processes off the machine
echo Gathering list of running processes on the machine...2/8
tasklist /svc /fo table >> Report\%computername%_Processes.txt
wmic process list full /format:csv >> Report\%computername%_Processes.csv

REM Pulls list of running services off the machine
echo Gathering list of services on the machine...3/8
net start >> Report\%computername%_Services.txt
WMIC SERVICE GET caption, name, state /format:csv >> Report\%computername%_Services.csv

REM Pulls list of installed patches off the machine
echo Gathering list of installed Windows Patches on the machine...4/8
wmic qfe list full >> Report\%computername%_Installed_Patches.txt
wmic qfe list full /format:csv >> Report\%computername%_Installed_Patches.csv

REM Pulls list of users
echo Gathering list of all users on the machine...5/8
NET USER >> Report\%computername%_Users.txt
wmic USERACCOUNT ist full /format:csv >> Report\%computername%_Users.csv

REM Pulls IP Address
echo Gathering IP address on the machine...6/8
ipconfig /all >> Report\%computername%_IP_Address.txt
wmic nicconfig get IPAddress /format:csv >> Report\%computername%_IP_Address.csv

REM Pull the Group Policy Settings
echo Gathering Group Policy settings...7/8
gpresult /h %computername%.html
gpresult /Z >> Report\GP.txt

REM Parsing through the OSSEC log file for errors
REM Try to filter it so it only shows errors from this month rather than all errors in the file
REM echo Parsing the OSSEC agent log...8/8
REM type "C:\Program Files\ossec-agent\ossec.log" find "error" >> %computername%_OSSEC_Log.txt
REM set month=%date:~4,2%
REM set year=%date:~10,4%
REM set dest=\\imsnas03\Active-Directory-Logs\logs\%year%-%month%
REM set header="Log In","%Date%","%TIME%"
REM echo if not exist "%dest%" md "%dest%"
REM echo %Header%,"%USERNAME%" >> "%dest%\computer\%COMPUTERNAME%.txt"
REM echo %Header%,"%COMPUTERNAME%" >> "%dest%\user\%USERNAME%.txt"
REM %date:~-4%
REM 28/07/2009
REM 2009

REM Generates final report
echo Generating final text report...1/2
cd Report
hoastname >> ..\%computername%_Final_Report.txt
echo %DATE% %TIME% >> ..\%computername%_Final_Report.txt
type *.txt >> ..\%computername%_Final_Report.txt

REM Final report generation contd.
echo Generating final excel report...2/2
hoastname >> ..\%computername%_Final_Report.csv
echo %DATE% %TIME% >> ..\%computername%_Final_Report.csv
type *.csv >> ..\%computername%_Final_Report.csv

REM Copy final product back to server
echo Uploading findings to Master server...1/1
pushd \\dbphqpcim01\C$
mkdir PCI
robocopy /E /Z /r:N /w:100 C:\PCI\ \PCI
robocopy /E /Z /r:N /w:100 C:\Windows\System32\%computername%\ \PCI\%computername%

REM Close connection to server
popd

REM Script is finished
echo DONE!!