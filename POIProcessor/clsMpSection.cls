VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "clsMpSection"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
'***************************************************************************
'������� mp �����
'***************************************************************************

Option Explicit
Const l_grad = 111.321322222222
Const RS_ATTR_NAME = "name"
Const RS_ATTR_VALUE = "value"
Private strComment(1000) As String
Private nComments As Integer
Private rsAttributes As ADODB.Recordset
Public SectionType As String
Public SectionEnding As String
Private m_Type As String
Private m_Label As String

Private Sub Class_Initialize()
  SectionType = ""
  SectionEnding = ""
  m_Type = ""
  Set rsAttributes = New ADODB.Recordset
  rsAttributes.Fields.Append RS_ATTR_NAME, adWChar, 255
  rsAttributes.Fields.Append RS_ATTR_VALUE, adWChar, 2048
  rsAttributes.Open
  rsAttributes(RS_ATTR_NAME).Properties("Optimize") = True
  
End Sub

Private Sub Class_Terminate()
  Set rsAttributes = Nothing
End Sub

Private Sub AddAttributeLine(strMpLine As String)
Dim strName
Dim strValue
Dim s() As String
  s = Split(strMpLine, "=", 2)
  strName = s(0)
  strValue = s(1)
  
  rsAttributes.AddNew
  rsAttributes(RS_ATTR_NAME).Value = Trim$(strName)
  rsAttributes(RS_ATTR_VALUE).Value = Trim$(strValue)
End Sub

Public Sub ReadSection()
  Dim strMpLine As String
  Dim blnSectionStarted As Boolean
    
  blnSectionStarted = False

  
  Do
    Line Input #1, strMpLine
    strMpLine = Trim(strMpLine)
    
    If (strMpLine = "") And (Not blnSectionStarted) Then
      SectionType = "BLANK"
      Exit Do
    End If
    
    
    'comment
    If Left(strMpLine, 1) = ";" Then
      SectionType = "COMMENT"
      If nComments < UBound(strComment) Then
        strComment(nComments) = strMpLine
        nComments = nComments + 1
      End If
      GoTo next_line
    End If
   
    
    If Left(strMpLine, 1) = "[" And Right(strMpLine, 1) = "]" Then
      If Not blnSectionStarted Then
        SectionType = strMpLine
        blnSectionStarted = True
      Else
        '����� ������
        SectionEnding = strMpLine
        Exit Do
      End If
    Else

      '����������� �������, ������� �� �� ��������
      strMpLine = Replace(strMpLine, "�", "")
      strMpLine = Replace(strMpLine, "�", "")
      strMpLine = Replace(strMpLine, "�", "")
      strMpLine = Replace(strMpLine, "�", "")
      strMpLine = Replace(strMpLine, "�", "")
      
      '������ ������� ��� Osm2mp
     
      ' �����������
      strMpLine = Replace$(strMpLine, "�", "�", , , vbBinaryCompare)
      strMpLine = Replace$(strMpLine, "�", "�", , , vbBinaryCompare)
      
      If strMpLine <> "" Then
        AddAttributeLine strMpLine
      End If
    End If
next_line:
  Loop
  
End Sub

Public Sub WriteSection()
Dim i As Integer

Select Case SectionType
  Case "COMMENT":
    Print #2, strComment(0)
  Case "BLANK"
    Print #2, ""
  Case Else
    Print #2, SectionType
    
    rsAttributes.MoveFirst
    Do While Not rsAttributes.EOF
      Print #2, rsAttributes(RS_ATTR_NAME) & "=" & rsAttributes(RS_ATTR_VALUE)
      rsAttributes.MoveNext
    Loop
   
    Print #2, SectionEnding
End Select

End Sub

Public Function GetAttributeValue(ByVal strAttributeName As String) As String
Dim strAttributeValue

  rsAttributes.Find RS_ATTR_NAME & "='" & strAttributeName & "'", , adSearchForward, adBookmarkFirst
  If Not rsAttributes.EOF Then
    strAttributeValue = rsAttributes(RS_ATTR_VALUE).Value
  Else
    'empty by default
    strAttributeValue = ""
  End If

  GetAttributeValue = strAttributeValue
End Function
Public Function SetAttributeValue(ByVal strAttributeName As String, ByVal strAttributeValue As String)

  rsAttributes.Find RS_ATTR_NAME & "='" & strAttributeName & "'", , adSearchForward, adBookmarkFirst
  If rsAttributes.EOF Then
    rsAttributes.AddNew
    rsAttributes(RS_ATTR_NAME).Value = strAttributeName
  End If
  rsAttributes(RS_ATTR_VALUE).Value = strAttributeValue

End Function

Property Get mpType() As String
  If m_Type = "" Then
    m_Type = GetAttributeValue("Type")
    m_Type = "0x" & UCase(Right(m_Type, Len(m_Type) - 2))
  End If
  mpType = m_Type
End Property
Property Let mpType(strNewType As String)
  
  SetAttributeValue "Type", strNewType
  m_Type = strNewType
End Property

Property Get mpEndLevel() As Integer
  
  mpEndLevel = GetAttributeValue("EndLevel")
  
End Property
Property Let mpEndLevel(intNewValue As Integer)
  
  SetAttributeValue "EndLevel", intNewValue
  
End Property

Property Get mpLabel() As String
  If m_Label = "" Then
    m_Label = GetAttributeValue("Label")
  End If
  mpLabel = m_Label
End Property
Property Let mpLabel(strNewLabel As String)
  
  SetAttributeValue "Label", strNewLabel
  m_Label = strNewLabel
End Property

Public Function GetSize()
Dim strData0 As String
Dim coords() As Double ' ������ ��������� ������ ��������
Dim tmp() As String
Dim strX As String
Dim strY As String
Dim i As Long, N As Long
Dim s As Double
'������ ������ ������� � ���������� ����������
'������������ ��� Data0 �������� ������� ������� ��������
  strData0 = GetAttributeValue("Data0")
  
'��������� ���.
'������
'(x1,y1),(x2,y2),(x3,y3), ...,(xN,yN)
  tmp = Split(strData0, "),")
  N = UBound(tmp)
  ReDim coords(N + 1, 1)
  For i = 0 To N
    strX = Trim$(Split(tmp(i), ",")(0)) '������
    strY = Trim$(Split(tmp(i), ",")(1)) '������
    '������
    
    coords(i, 0) = Right(strX, Len(strX) - 1)
    
    
    '�������
    If i = N Then
      coords(i, 1) = Left(strY, Len(strY) - 1)
    Else
      coords(i, 1) = strY
    End If
       
  Next i
  '�������� ��� ������� ���������
  If (coords(0, 0) <> coords(N, 0)) Or (coords(0, 1) <> coords(N, 1)) Then
    'Err.Raise vbObjectError, "GetSize", "Polygon is not closed"
    N = N + 1
    coords(N, 0) = coords(0, 0)
    coords(N, 1) = coords(0, 1)
  End If
'������ ������� � ���������� ��������
  s = 0
  For i = 0 To N - 1
    s = s + (coords(i, 0) - coords(i + 1, 0)) * (coords(i, 1) + coords(i + 1, 1)) / 2
  Next i

'��������� ������� �� ���������� �������� � ��^2 (�����������)
  s = s * l_grad * l_grad * Cos(coords(0, 0) * 3.141592653 / 180)
  
  '���� ������� �� ����������� ������, �� ������� �������� ��� ��� ����� ������������
  GetSize = Abs(s)
End Function

Public Function GetCoords() As String
Dim strData As String
Dim s As String
Dim i As Integer
  
  For i = 0 To 7
    strData = GetAttributeValue("Data" & i)
    If strData <> "" Then
      Exit For
    End If
  Next i
  
  If strData = "" Then
    Err.Raise vbObjectError, "GetCoords", "�� �������� ���������� ���������� �������"
  End If
    
  s = Split(strData, ")", 2)(0)
  If Left(s, 1) = "(" Then
   s = Right(s, Len(s) - 1)
  End If
  
  GetCoords = s
End Function
'��������� ������������� �������
'OSM ID ���������� � ������ ������ ����������
Public Function GetOsmID() As String
Dim s() As String
Dim strCommentLine
Dim strType As String
Dim strNumber As String
Dim i As Integer
  
  strCommentLine = strComment(0)
  If Left(strCommentLine, 19) = "; multipolygon with" Then
   strCommentLine = strComment(1)
  End If
  
  If Left(strCommentLine, 8) = "; ERROR:" Then
    strCommentLine = strComment(1)
    If Left(strCommentLine, 8) = "; ERROR:" Then
      strCommentLine = strComment(2)
    End If
  End If
  
  
  


  i = InStr(strCommentLine, "NodeID =")
  If i > 0 Then
   strCommentLine = Mid(strCommentLine, i)
  End If
  
  i = InStr(strCommentLine, "WayID =")
  If i > 0 Then
   strCommentLine = Mid(strCommentLine, i)
  End If
  
  i = InStr(strCommentLine, "RelID =")
  If i > 0 Then
   strCommentLine = Mid(strCommentLine, i)
  End If
    
    
  s = Split(strCommentLine, "=")
  strType = Trim(s(0))
  strNumber = Trim(s(1))
  Select Case strType
    '�����
    Case "NodeID"
      GetOsmID = "N:" & strNumber
    '�����
    Case "WayID"
      GetOsmID = "W:" & strNumber
    '���������
    Case "RelID"
      GetOsmID = "R:" & strNumber
    Case Else
      Debug.Print strCommentLine
      Err.Raise vbObjectError, "GetOsmID", "����������� ��� ������� " & strCommentLine
  End Select
  
End Function


