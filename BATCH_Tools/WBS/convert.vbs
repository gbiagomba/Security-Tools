Sub BackToA1()
Range("A1").Select
End Sub

Sub GetPDFnow()
Dim varRetVal As Variant
Dim strFullyPathedFileName As String
Dim strDoIt As String
'Add a new worksheet
Sheets.Add After:=Sheets(Sheets.Count)
'Name it
ActiveSheet.Name = "Input01"
'Back to "A1"
Range("A1").Activate
'HERE YOU DEFINE THE FULLY PATHED PDF FILE
strFullyPathedFileName = "C:\Users\gbiagomba\Documents\GBiagomba\Documents\NCP Standards\iOS 8\U_Apple_iOS_8_V1R1_ISCG_Configuration_Table.pdf"
'HERE YOU SET UP THE SHELL COMMAND
strDoIt = "C:\Program Files (x86)\Adobe\Reader 11.0\Reader\AcroRd32.exe " & strFullyPathedFileName
'The Shell command
varRetVal = Shell(strDoIt, 1)
'Clear CutCopyMode
Application.CutCopyMode = False
AppActivate varRetVal
'Wait some time
Application.Wait Now + TimeValue("00:00:03") ' wait 3 seconds
DoEvents
'IN ACROBAT :
'SELECT ALL
SendKeys "^a"
'COPY
SendKeys "^c"
'EXIT (Close & Exit)
SendKeys "^q"
'Wait some time
Application.Wait Now + TimeValue("00:00:03") ' wait 3 seconds
DoEvents
'Paste
ActiveSheet.Paste
'Go back to cell A1
Call BackToA1
End Sub
