REM Important links
REM https://msdn.microsoft.com/en-us/library/ff647642.aspx
REM https://blogs.msdn.microsoft.com/ashishme/2013/02/15/microsoft-baseline-security-analyzer-mbsa-offline-bulk-scan-process/
REM https://dougvitale.wordpress.com/2011/11/18/microsoft-baseline-security-analyzer/
REM http://stackoverflow.com/questions/1449188/running-windows-batch-file-commands-asynchronously
REM mbsacli /xmlout /catalog wsusscn2.cab /unicode /nvc >results.xml #http://www.breaknenter.org/2011/02/how-to-use-mbsa-standalone-to-check-a-ms-server-for-patch-status/

REM Open command prompt with admin prividleges
runas /noprofile /user:NA\%username% cmd
REM Download Update Cab file
bitsadmin  /transfer mydownloadjob  /download  /priority high http://go.microsoft.com/fwlink/?LinkId=76054 C:\Users\%username%\Documents\Applications\MBSA\wsusscn2.cab
REM Run MBSA tool
mbsacli.exe /listfile <FILE PATH> /n os+iis+sql+password /cabpath C:\Users\%username%\Documents\Applications\MBSA\ /o Results.htm
REM Run multiple threads of a file/command
start /b cmd /c java -version