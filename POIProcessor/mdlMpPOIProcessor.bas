Attribute VB_Name = "mdlMpPOIProcessor"
'=======================================================================
'Загрузка POI в базу
'CC-BY-SA (c) Zkir
'=======================================================================
Option Explicit

'КОНСТАНТЫ ПОЛЕЙ
Const TBL_POI = "POI"
Const POI_ID = "ID"
Const POI_OSMID = "OSM_ID"
Const POI_OSMVERSION = "OSM_VERSION"
Const POI_OSM_DATE = "OSM_DATE"
Const POI_LAT = "LAT"
Const POI_LON = "LON"
Const POI_MP_TYPE = "MP_TYPE"
Const POI_NAME = "NAME"
Const POI_ADDRESS1 = "ADDRESS1"
Const POI_CITY = "ADDRESS2"
Const POI_ADDR_STREET = "ADDR_STREET"
Const POI_ADDR_HOUSENUMBER = "ADDR_HOUSENUMBER"
Const POI_DESCRIPTION = "DESCRIPTION1"
Const POI_DESCRIPTION2 = "DESCRIPTION2"
Const POI_OPENING_HOURS = "OPENING_HOURS"
Const POI_PHONE = "PHONE"
Const POI_WEBSITE = "WEBSITE"
Const POI_MODIFIED_DATE = "MODIFIED_DATE"
Const POI_MODIFIED_USER_ID = "MODIFIED_USER_ID"


'-------------------------------------------------------------------------
'константы типов mp
'Населенные пункты
Const mptCityOver10M = "0x0100"
Const mptCity200_500K = "0x0600"
Const mptCity100_200K = "0x0700"
Const mptCity50_100K = "0x0800"

Const mptSettlement2_5K = "0x0C00"
Const mptSettlement500_1000 = "0x0E00"
Const mptSettlement200_500 = "0x0F00"
Const mptSettlementLess100 = "0x1100"

Const mptBusStop = "0xF002"
Const mptTramStop = "0xF003"

Const mptFord = "0xF307"
Const mptSingleTree = "0xF404"
Const mptCrossing = "0x6406"
Const mptCrossingSign = "0xFE0D"

Const mptTrafficLight = "0xF201"
Const mptRailwayCrossing = "0xF203"
Const mptRoughRoad = "0xF204"
Const mptBridge = "0x6401"
Const mptTunnel = "0x6413"

Const mptLabel = "0x2800"
Const mptLabelDistrict = "0x1F00"
Const mptLabelDistrict2 = "0x1F01"

'"0x1500"

Const mptSpring = "0x6511"
Const mptWell = "0x6414"
Const mptLake = "0x650D"
Const mptMountainPeak = "0x6616"
Const mptBay = "0x6503"
Const mptIsland = "0x650C"
Const mptForest = "0x660A"

Const mptInformation = "0x4C00"

Const mptHouse = "0x6100"

Private Declare Function CoCreateGuid Lib "ole32.dll" (buffer As Byte) As Long
Private Declare Function StringFromGUID2 Lib "ole32.dll" (buffer As Byte, ByVal lpsz As Long, ByVal cbMax As Long) As Long
 
 
'***************************************************************************
'Фильтрация mp
'***************************************************************************
Public Function ereg(ByVal Expression As String, _
                     ByVal Mask As String, _
                     Optional blnIgnoreCase As Boolean = False) As Boolean
  Static soRegExp As New VBScript_RegExp_55.RegExp
  soRegExp.IgnoreCase = blnIgnoreCase
  soRegExp.Pattern = Mask
  ereg = soRegExp.Test(Expression)
End Function
Private Function getGUID() As String
Dim buffer(0 To 15) As Byte
Dim s As String
Dim ret As Long
s = String$(128, 0)
ret = CoCreateGuid(buffer(0))

ret = StringFromGUID2(buffer(0), StrPtr(s), 128)
getGUID = Left$(s, ret - 1)
End Function

Public Function NormalizeStreetName(ByVal strStreetName As String, ByVal blnKillUl As Boolean) As String
Dim l As Long

  'улица убивается в начале и в конце названия.
  ' в средине пока не будем
  strStreetName = Trim$(strStreetName)
  l = Len(strStreetName)
  If blnKillUl Then
    
    If LCase(Left(strStreetName, 5)) = "улица" Then strStreetName = Right(strStreetName, l - 5)
    If LCase(Left(strStreetName, 3)) = "ул." Then strStreetName = Right(strStreetName, l - 3)
  
    If LCase(Right(strStreetName, 5)) = "улица" Then strStreetName = Left(strStreetName, l - 5)
    If LCase(Right(strStreetName, 3)) = "ул." Then strStreetName = Left(strStreetName, l - 3)
    
    
  End If
  
  'Применим сокращения
  '
  strStreetName = " " & Trim$(strStreetName) & " "
  
  If Not (ereg(strStreetName, "^ [0-9]+-я Набережная $") Or strStreetName = " Набережная ") Then
    ' названия типа "6-я набережная" не сокращаются, во избежание "6-я наб."
    strStreetName = Replace$(strStreetName, " набережная ", " наб. ", , , vbTextCompare)
  End If
  
  
  strStreetName = Replace$(strStreetName, " проспект ", " пр. ", , , vbTextCompare)
  strStreetName = Replace$(strStreetName, " площадь ", " пл. ", , , vbTextCompare)
  
  strStreetName = Replace$(strStreetName, " переулок ", " пер. ", , , vbTextCompare)
  strStreetName = Replace$(strStreetName, " проезд ", " пр-д. ", , , vbTextCompare)
  strStreetName = Replace$(strStreetName, " шоссе ", " ш. ", , , vbTextCompare)
  strStreetName = Replace$(strStreetName, " улица ", " ул. ", , , vbTextCompare)
  
  'Убьем пробел перед номером
  strStreetName = Replace$(strStreetName, " № ", " №", , , vbTextCompare)
   
  'Обтримливание на всякий случай
  strStreetName = Trim$(strStreetName)
  
  ' статусная часть переносится в конец
  If Not blnKillUl Then
    l = Len(strStreetName)
    If LCase(Left(strStreetName, 3)) = "ул." Then strStreetName = Right(strStreetName, l - 3) + " ул."
    'If LCase(Left(strStreetName, 3)) = "пр." Then strStreetName = Right(strStreetName, l - 3) + " пр."
  End If
  
  strStreetName = Trim$(strStreetName)
  
  NormalizeStreetName = strStreetName

End Function


Public Sub ProcessMP(strSrcFileName As String)
Dim oMpSection As clsMpSection

Dim strLabel As String

Dim objCon As ADODB.Connection
Dim rsPoi As ADODB.Recordset
Dim strOsmID As String
Dim N As Long

On Error GoTo finalize
  
  N = 0
  Set objCon = New ADODB.Connection
  Set rsPoi = New ADODB.Recordset
  objCon.Open OSM4U_DB_CONNECTION_STRING
  
  
  rsPoi.CursorType = adUseClient
  rsPoi.Open "Select * from POI", objCon, adOpenStatic, adLockBatchOptimistic, adCmdText
 ' rsPoi(POI_OSMID).Properties("Optimize") = True
    
  Open strSrcFileName For Input As #1

  Do While Not EOF(1)
  
    Set oMpSection = New clsMpSection
    oMpSection.ReadSection
    
    ' Занесем ПОИ в базу
    If oMpSection.SectionType = "[POI]" Then
      'Исключаем мосты, тоннели, преходы, светофоры, ворота, шлагбаумы, урны, лежачие полицейские, бетонные блоки
      If Not ((oMpSection.mpType >= mptCityOver10M And oMpSection.mpType <= mptSettlementLess100) Or _
              oMpSection.mpType = mptBusStop Or _
              oMpSection.mpType = mptTramStop Or _
              oMpSection.mpType = mptFord Or _
              oMpSection.mpType = mptSingleTree Or _
              oMpSection.mpType = mptCrossing Or _
              oMpSection.mpType = mptCrossingSign Or _
              oMpSection.mpType = mptTrafficLight Or _
              oMpSection.mpType = mptRailwayCrossing Or _
              oMpSection.mpType = mptRoughRoad Or _
              oMpSection.mpType = mptBridge Or _
              oMpSection.mpType = mptTunnel Or _
              oMpSection.mpType = mptLabelDistrict Or _
              oMpSection.mpType = mptLabelDistrict2 Or _
              oMpSection.mpType = mptSpring Or _
              oMpSection.mpType = mptWell Or _
              oMpSection.mpType = mptLake Or _
              oMpSection.mpType = mptMountainPeak Or _
              oMpSection.mpType = mptBay Or _
              oMpSection.mpType = mptIsland Or _
              oMpSection.mpType = mptForest Or _
              oMpSection.mpType = mptHouse Or _
              oMpSection.mpType = mptInformation _
              ) Then
        
        strOsmID = oMpSection.GetOsmID
        
        ' Проверяем, есть ли уже такой объект
        ' По одному объекту, особенно линейному, может сгенериться несколько ПОИ
        'rsPoi.Find POI_OSMID & "='" & strOsmID & "' ", , adSearchForward, adBookmarkFirst
        'rsPoi.Filter = POI_OSMID & "='" & strOsmID & "' and " & POI_MP_TYPE & "='" & oMpSection.mpType & "'"
       
        'If rsPoi.EOF Then
          rsPoi.AddNew
          rsPoi(POI_ID).Value = getGUID
          rsPoi(POI_OSMID).Value = strOsmID
        'End If
              
        ' Тут, по идее, нужно проверять, что в OSM более новая версия, чем в базе
        ' Но пока средств для этого нет.
        
        ' Пока обновление безусловное
        
        rsPoi(POI_OSMVERSION).Value = 0
        rsPoi(POI_OSM_DATE).Value = "1900-01-01"
        Dim strCoords() As String
        strCoords = Split(oMpSection.GetCoords, ",")
        rsPoi(POI_LAT).Value = strCoords(0)
        rsPoi(POI_LON).Value = strCoords(1)
        rsPoi(POI_MP_TYPE).Value = oMpSection.mpType
        rsPoi(POI_NAME).Value = oMpSection.mpLabel
        rsPoi(POI_ADDRESS1).Value = oMpSection.GetAttributeValue("RegionName")
        rsPoi(POI_CITY).Value = oMpSection.GetAttributeValue("CityName")
        rsPoi(POI_ADDR_STREET).Value = Trim(NormalizeStreetName(oMpSection.GetAttributeValue("StreetDesc"), True))
        If rsPoi(POI_ADDR_STREET).Value = "" Then
          rsPoi(POI_ADDR_STREET).Value = "<улица не задана>"
        End If
        rsPoi(POI_ADDR_HOUSENUMBER).Value = oMpSection.GetAttributeValue("HouseNumber")
        rsPoi(POI_DESCRIPTION).Value = oMpSection.GetAttributeValue("Text")
        'rsPoi(POI_DESCRIPTION2).Value = 'Это поле еще предстоит заполнить
        
        rsPoi(POI_OPENING_HOURS).Value = oMpSection.GetAttributeValue("OpeningHours")
        rsPoi(POI_PHONE).Value = oMpSection.GetAttributeValue("Phone")
        rsPoi(POI_WEBSITE).Value = Replace$(oMpSection.GetAttributeValue("WebPage"), "http://", "")
        'rsPoi(POI_MODIFIED_DATE).Value =
        'rsPoi(POI_MODIFIED_USER_ID).Value =
        N = N + 1
        If (N Mod 250) = 0 Then
          rsPoi.UpdateBatch
          Debug.Print N, strOsmID
          DoEvents
        End If
      End If
    End If
  
 
    Set oMpSection = Nothing
  
  Loop
  Close #1

  rsPoi.UpdateBatch
  
  objCon.Close
finalize:
  If Err.Number <> 0 Then
    Err.Raise Err.Number, "ProcessMP", Err.Description & " ProcessMP:" & Erl
  End If

End Sub

Private Function СomposeAddress(ByRef strStreet As String, ByRef strHouseNumber As String) As String
If strStreet = "" Then
 strStreet = "<улица не задана>"
End If
If strHouseNumber <> "" Then
  СomposeAddress = strStreet & ", " & strHouseNumber
Else
  СomposeAddress = strStreet
End If
End Function
