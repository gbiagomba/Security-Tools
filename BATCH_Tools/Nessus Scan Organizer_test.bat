@echo off
REM This script does a directory look up filtering only files. On every file the name is parsed to REM pull the store number. The file is then copied to the corresponding folder.
REM This script assumes that the the nessus files are located in a folder “nessusCopy” and the REM script is in the location that “nessusCopy” is located in

setlocal enabledelayedexpansion

xcopy *.nessus nessusCopy\

dir /a-d /b nessusCopy >>Nessus_FileListing.txt

for /f %%a in (Nessus_FileListing.txt) do (
	set tempName=%%a
	set tempName=!tempName:~0,18!
	set tempName=!tempName:~8,10!
	echo %%a
	echo !tempName!
	move /y nessusCopy\%%a nessusCopy\!tempName!\
	xcopy parse_nessus.exe nessusCopy\!tempName!\
	cd nessusCopy\!tempName!\
	echo %cd%
	pause
	parse_nessus.exe
	cd ..\..\
	echo %cd%
	pause
)
del Nessus_FileListing.txt