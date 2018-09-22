@echo off

setlocal enabledelayedexpansion

REM machNum=prompt user for machine's number
REM ipAdd=x.x.x.(40 - machNum)
REM set machine IP to ipAdd
set /p machNum="Enter the machine's number:"
set mask=255.255.255.0
set gate=192.168.3.1
call :verify
echo %ipAdd%
call :connectionName
call :setIP
echo Script completed.
goto:eof

:verify
set /a test=(machNum-40)
echo %test%
if %test% gtr 0 if %test% lss 254 set ipAdd=x.x.x.%test%
goto:eof

:connectionName
for /f "tokens=* delims=:" %%a in ('ipconfig ^| find /i "ethernet adapter"') do (
set conName=%%a
set conName=!conName:~17! REM remove first 17 chars
set conName=!conName:~0,-1! REM remove trailing chars
)
goto:eof

:setIP
netsh interface ip set address !conName! static %ipAdd% %mask% %gate% 1
netsh interface ip set dns name="!conName!" static 8.8.8.8
netsh interface ip add dns name="!conName!" 8.8.4.4 index=2
netsh int ip show config
pause
goto:eof