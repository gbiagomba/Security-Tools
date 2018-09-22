title Restoration Agent

@echo off
mkdir "C:\Users\gbiagomba\Documents\GBiagomba"
pushd \\dbphqfilp01\GBiagomba
robocopy /E /zb /r:N /w:100 \  "C:\Users\gbiagomba\Documents\GBiagomba" 
popd
pause