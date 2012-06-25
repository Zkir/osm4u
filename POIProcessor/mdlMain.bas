Attribute VB_Name = "mdlMain"
Option Explicit
Private Declare Sub ExitProcess Lib "kernel32" (ByVal uExitCode As Long)

Private Sub ParseCommandLine(strSource As String)
Dim strCommandLine As String
Dim args() As String
  strCommandLine = Command()
  
  args = Split(strCommandLine, " ")
  strSource = args(0)
  
'  If UBound(args) >= 0 Then
'    strTarget = args(1)
'    If UBound(args) > 1 Then
'      strViewPoint = Replace(args(2), ",", " ")
'    End If
'  End If
End Sub
Sub Main()
Dim strSource As String
On Error GoTo finalize
  Open "log-pp.txt" For Append As #3
  
  ParseCommandLine strSource
  If strSource <> "" Then
    Print #3, ""
    Print #3, " --| MP Postprocessor for osm2dcm conversion, (C) Zkir 2010"
    Print #3, "Postprocessor has been started"
    Print #3, "Source file: " & strSource
    ProcessMP strSource
    Print #3, "Postprocessor has been finished OK"
  Else
    MsgBox "Usage: mpPostProcessor <source mp file>"
  End If
  
finalize:
 If Err.Number <> 0 Then
    Print #3, "Error: " & Err.Description
    Close #3
   ' ExitProcess 1
 End If
 Close #3
End Sub
