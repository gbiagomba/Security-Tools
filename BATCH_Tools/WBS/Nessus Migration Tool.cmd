REM Author: Gilles S. Biagomba
REM Program: Nessus Migration Tool
REM Description: This script will import & export he Nessus settings, policies and profiles to or from different Nessus programs

REM stop the Nessus service:
net stop "Tenable Nessus"

REM Map to the Nessus Network Folder
pushd \\images\install\Nessus\
mkdir %computername%_IMPORTED %computername%_BACKUP

REM This for Importing & backing the Nessus 
REM The important files that need to be migrated from the old installation to the new installation are:
robocopy /E /zb C:\ProgramData\Tenable\Nessus\global.db  %computername%_IMPORTED\
robocopy /E /zb C:\ProgramData\Tenable\Nessus\master.key %computername%_IMPORTED\
robocopy /E /zb C:\ProgramData\Tenable\Nessus\policies.db %computername%_IMPORTED\
REM The important directories that need to be migrated from the old installation to the new installation are:
robocopy /E /zb C:\ProgramData\Tenable\Nessus\users %computername%_IMPORTED\
robocopy /E /zb C:\ProgramData\Tenable\Nessus\conf %computername%_IMPORTED\
REM Master Back
robocopy /E /zb C:\ProgramData\Tenable\Nessus\ %computername%_BACKUP
compact /c /s %computername%_BACKUP
RD /s /q %computername%_BACKUP

REM tHIS is for Exporting the Content

REM Register the activation code with this installation. This will also have Nessus fetch the latest plugins.
cd C:\Program Files\Tenable\Nessus 
nessuscli fetch --register <activation code>
REM Re-index the Nessus plugins. This may take up to 15-20 minutes, depending on your system resources.
nessusd -R

REM restart the Nessus service:
net start "tenable nessus"

REM Unmap the network Drive
popd