@echo off

REM Author: Gilles S. Biagomba
REM Program: FFCopy
REM Description: This program was designed to download the latest version of Chrome from mthe OE Server\n
REM				 Then install said version on the OE machine.\n

REM Killing chrome process in task manager
taskkill /f /im chrome.exe*

REM Remove and re-create Firefox local repository folder
del /s /q /f C:\Users\Public\Documents\Chrome\*.*
rd /s /q C:\Users\Public\Documents\Chrome
mkdir C:\Users\Public\Documents\Chrome

REM Connect to OE Server and download Chrome & extensions
pushd \\dbphqpcim01\c$\
robocopy /E /Z /r:N /w:100 \PCI\Other\Misc\Browsers\Chrome C:\Users\Public\Documents\Chrome
popd

REM Install Chrome
cd "C:\Users\Public\Documents\Chrome"
Msiexec /q /I googlechromestandaloneenterprise.msi
copy "C:\Users\Public\Documents\Chrome\master_preferences" "C:\Program Files\Google\Chrome\Application\" /y

REM Log off the user so the install can take effect
shutdown -r -f - t00