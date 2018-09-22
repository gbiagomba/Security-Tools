FOR %%A IN (%Date%) DO SET Today=%%A
SET Now=%Time%
ECHO Today is %Today% > C:\FIMtest1.txt
ECHO The TIme is %Now% >> C:\FIMtest1.txt
copy C:\FIMtest1.txt C:\Special\FIMtest2.txt /Y
