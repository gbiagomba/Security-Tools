title Backup Agent

@echo off
pushd \\dbphqfilp01\GBiagomba
robocopy /E /zb /r:N /w:100 "C:\Users\gbiagomba\OneDrive - David's Bridal, Inc-" \
popd
pause