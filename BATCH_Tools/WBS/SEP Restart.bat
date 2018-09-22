REM http://www.symantec.com/connect/forums/how-stop-smc-service-through-command-line-smcexe-stop-p-xxxxxxxx

@echo off

REM 32 bit
cd "C:\Program Files (x86)\Symantec\Symantec Endpoint Protection\12.1.5337.5000.105\Bin\"
Smc.exe -stop -p xxxxxxxx

REM 64 bit
cd "C:\Program Files (x86)\Symantec\Symantec Endpoint Protection\12.1.5337.5000.105\Bin64\"
Smc.exe -stop -p xxxxxxxx

