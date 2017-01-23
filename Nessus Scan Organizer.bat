REM Author: Gilles S. Biagomba
REM Program: Nessus Scan Oranizer
REM Description: This program will move the dump of Nessus files into corresponding directories \n
			 REM by parsing through the file name in the dump and extracting only the store number \n
			 REM then it creates a directory for every file. Next it copies the files into each dir \n
			 REM Lastly itt moves into each folder executes the nessus parser then backs out of the dir \n

REM Resources & additional documents
REM http://stackoverflow.com/questions/3732947/batch-to-remove-character-from-a-string
REM http://www.dostips.com/DtTipsStringManipulation.php
REM http://ss64.com/nt/syntax-substring.html
 
REM sample code
REM @setlocal enableextensions enabledelayedexpansion
REM @echo off
REM for /f "delims=" %%a in (testprog.in) do (
    REM set variable=%%a
    REM if "x!variable:~-4!"=="x.png" (
        REM set variable=!variable:~0,-4!
    REM )
    REM echo.!variable!
REM )
REM endlocal

REM real code
@echo off

title Nessus Scan Oranizer v1.0

REM Connect to cargoe bay
REM pushd \\cargobay02.phlseclab.int\cargobay\
REM cd Clients\TRU\Stores Completed\Gilles

dir /a-d /b > Nessus_FileListing.txt

for /f "delims=" %%a in (Nessus_FileListing.txt) do 
(
	REM this wll preserve the original file name so that it can be copied over later
	set orgstr=Blah #finish this line it is not accurate
	REM grabs the first 18 characters (i.e Q1_2016_Store_8736)
	set str=%str:~0,18%
	REM should grb the last 10 characters and ifnore the first 8 (i.e Store_8736)
	set str=%str:~8,10%
	REM makes the directory based on the parsed variable
	mkdir %str%
	REM copies the individual files to their respective directories
	xcopy %orgstr% %str% /v
	REM copies the nessus parser to each directory
	xcopy parse_nessus.exe %str%
	REM moves into the newly created directory`
	cd %str%
	REM executes the parser program
	parse_nessus.exe
	REM moves backout of the directory
	cd ..
)

REM Notes:
REM Q1_2016_Store_8736_cf96vg.nessus
REM Using a loop do the foolowing
REM Delete the first 8 characters
REM Skip the first 10 characters
REM Delete the remining 13 characters
REM Substitue the middle character for a whitespace, so instead of "_", have " "
REM Send that to mkdir
REM Copy nessus files to reach respecting folder
REM Copy parser in each folder 