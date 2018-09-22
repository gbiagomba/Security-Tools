@echo off

REM Author: Gilles S. Biagomba
REM Program: FFCopy
REM Description: This program was designed to download the latest version of Firefox from mthe OE Server\n
REM				 Then install said version on the OE machine.\n

REM Killing firefox process in task manager
taskkill /f /im firefox.exe*

REM Remove and re-create Firefox local repository folder
del /s /q /f C:\Users\Public\Documents\Firefox\*.*
rd /s /q C:\Users\Public\Documents\Firefox
mkdir C:\Users\Public\Documents\Firefox

REM Connect to OE Server and download FireFox & extensions
pushd \\dbphqpcim01\c$\
robocopy /E /Z /r:N /w:100 \PCI\Other\Misc\Browsers\FireFox C:\Users\Public\Documents\Firefox
popd

REM Install Firefox
cd "C:\Users\Public\Documents\Firefox"
dir /b find firefox* > path.txt
set /p PATH=< path.txt
%PATH% -ms

REM Cleaning up
del /s /q /f path.txt
SET PATH="NULL"

REM Move Extensions over [BETA]
REM copy C:\PCI\Other\Misc\Browsers\FireFox\*.xpi "C:\Program Files (x86)\Mozilla Firefox\browser\extensions"

REM Log off the user so the install can take effect
shutdown -r -f - t00