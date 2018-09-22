REM Install guide page 27
REM open command prompt as an admin
runas /noprofile /user:DBI\gbiagomba cmd

REM Stop the nessus service
net stop "Tenable Nessus"

REM Making a backup of existing Nessus folder
xcopy /E /v /Q /H /Z C:\ProgramData\Tenable\Nessus\ \\<Destination>

C:\ProgramData\Tenable\Nessus\global.db
C:\ProgramData\Tenable\Nessus\master.key
C:\ProgramData\Tenable\Nessus\policies.db
C:\ProgramData\Tenable\Nessus\users
C:\ProgramData\Tenable\Nessus\conf