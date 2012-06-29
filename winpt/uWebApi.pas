unit uWebApi;

interface

uses
  System.SysUtils, System.Classes, IdBaseComponent, IdComponent,
  IdTCPConnection, IdTCPClient, IdHTTP,Xml.XMLIntf,XMLDoc,Vcl.Dialogs,vcl.Forms,vcl.controls;

type
  TfrmWebApi = class(TDataModule)
    IdHTTP1: TIdHTTP;
  private
    { Private declarations }
  public
    { Public declarations }
    xmlPoiCategories:IXMLDocument; // Классификатор пои
    procedure LoadPoiCategories;
    function GetMpTypeCodeByName(strTypeName:string):string;
    function GetMpTypeNameByCode(strTypeCode:string):string;
    function CheckCategoryName(strCategoryName:string):string;
  end;

var
  frmWebApi: TfrmWebApi;

//const API_URL='http://localhost:3571/webapi.php';
const API_URL='http://test1.osm4u.ru/api/webapi.php';

//Уровни ошибок
const ERR_INFOMESSAGE=0;
const ERR_WARNING=1;
const ERR_BUSINESS_ERROR=2;
const ERR_INTERNAL_ERROR=3;

//Контекст, указывающий на пользователя и его координаты
type TContext=class
  private
    FLogin:string;
    FPassword:string;
    FLat:double;
    FLon:double;
    property Password:string read  FPassword;
  public
    property Login:string read  FLogin;
    property CurrentLat:double read  FLat;
    property CurrentLon:double read  FLon;
    constructor Create (ALogin, APassword:string);
    //procedure SetLocation(NewLat,NewLon:double);
end;
type TApiContext=TContext;

//Главная функция обмена данными с сервером
function SendXML(xml:string):string;
procedure OnBeginQuery;
procedure OnEndQuery;

//Отображение сообщений, полученных в результате вызова API (SendXML)
//Возращает "уровень ошибки"
function DisplayMessages(xml:IXMLDocument):integer;

function GetGUID():string;

//Операции обмена с сервером
//Регистрация нового пользователя
function RegisterNewUser(strLogin,strPassword, strFirstName,strLastName:string;
                         dtDateOfBirth:TDateTime;
                         strGender:string):string;

//Проверка подлинности существующего  пользователя
function CheckUser(Context:TContext):string;

//Запрос Пои рамке.
function GetPoiByBBox(Context:TContext;
                      MinLat,MinLon,MaxLat,MaxLon:double;
                      strCategory,strType:string):string;

//Получение классификатора
function GetPoiCategories(Context:TContext):string;

//сохранение пои в базу
function SavePoi ( Context:TContext;
                   strID:string;
                   strMpPoiType:string;// тип пои
                   lat,lon:double;//Координаты
                   //3-й скрин
                   strPOIName, //Название
                   strAddrCountry,
                   strAddrCity,
                   strAddrStreet,
                   strAddrNumber,
                   //4-й скрин
                   strPhone,
                   strWebsite,
                   strOpeningHours,
                   strAvgBill:string;
                   blnWiFi:boolean;
                   strDescription:string
                   ):string;

function AddComment(Context:TContext;
                    strPoiID:string;
                    strComment:string;
                    intRating:integer ):string;

const

   RECOMENDATION_1 = 'К посещению НЕ рекомендуется';
   RECOMENDATION_2 = 'К посещению не рекомендуется';
   RECOMENDATION_3 = 'К посещению рекомендуется с оговорками';
   RECOMENDATION_4 = 'К посещению рекомендуется';
   RECOMENDATION_5 = 'Посетить обязательно!';

implementation
uses IdMultipartFormData,EncdDecd,uMain;
{%CLASSGROUP 'System.Classes.TPersistent'}

{$R *.dfm}
var  oldCursor:Tcursor;
procedure OnBeginQuery;
begin
   oldCursor:=Screen.Cursor;
   screen.Cursor:=crHourGlass;
end;
procedure OnEndQuery;
begin
  screen.Cursor:=oldCursor;
end;

//==============================================================================
//   Контекст исполнения
//==============================================================================
constructor TContext.Create (ALogin, APassword:string);
begin
  FLogin:= ALogin;
  FPassword:=APassword;

  //Значение положения по умолчанию.
  FLat:=  55.716753;
  FLon:=  37.6189519;

end;
//==============================================================================
//   Обмен данными с сервером
//==============================================================================

//Xml отправляется на сервер методом пост.
//получается ответный xml
function SendXML(xml:string):string;
var
   data: TIdMultiPartFormDataStream;
   str:string;
   l,i:integer;
begin
  OnBeginQuery;
  try
  data := TIdMultiPartFormDataStream.Create;

//response:=IdHTTP1.Get('http://test1.osm4u.ru/getdata.xml?MpType=0xF102');
//data.AddFormField('param1', 'value1');
  str:= trim(xml);
  //Перед отправкой xml кодируется в base64
  //В инди какие-то неисправимые проблемы с кодирвкой кирилицы
  l:=length(str);
  for i := 1 to 3-(l mod 3) do
    str:=str+' ';

  data.AddFormField('xmlmsg', EncodeString( str));
  data.AddFormField('base64', 'yes');
  //response:=IdHTTP1.Post('http://test1.osm4u.ru/api/userin.php', data  );
  result:=frmWebApi.IdHTTP1.Post(API_URL, data  );

  data.Free;
  finally
    OnEndQuery;
  end;
end;

//Отображение сообщений, полученных в результате вызова API
//Возращает "уровень ошибки"
function DisplayMessages(xml:IXMLDocument):integer;
var
    nodeErrors:IXMLNode;
    strError:string;
    intErrorLevel:integer;
    i:integer;
begin
  nodeErrors:=xml.DocumentElement.ChildNodes['ERS'];
  strError:='';
  intErrorLevel:=0;
  for i := 0 to nodeErrors.ChildNodes.count-1  do
  begin
    if +nodeErrors.ChildNodes[i].ChildNodes['CODE'].NodeValue<>0 then
      strError:=strError+' '+ #10#13+nodeErrors.ChildNodes[i].ChildNodes['DESCR'].NodeValue;
    if nodeErrors.ChildNodes[i].ChildNodes['TYPE'].NodeValue>intErrorLevel then
    intErrorLevel:=nodeErrors.ChildNodes[i].ChildNodes['TYPE'].NodeValue;

  end;
  if strError<>'' then
    MessageDlg(strError,mtInformation,[mbOK],0);

  result:=intErrorLevel;
end;

function FormatXMLStr(str:string):string;
begin
  result:=str;
end;

function FormatXMLDate(aDate:TDateTime):string;
var intYear,intMonth, intDay:word;
begin
  DecodeDate(aDate, intYear,intMonth, intDay);
  result:= Format ('%.4d', [intYear]) +'-'+ Format('%.2d',[intMonth]) +'-'+ Format('%.2d',[intDay]);
end;

function FormatXMLDbl(aDouble:double):string;
begin
  result:=FloatToStr(aDouble);
end;

function FormatXMLBool(aBool:boolean):string;
begin
  if aBool then
    result:='1'
  else
    result:='0'
end;



function GetGUID():string;
var
  udtGUID : TGUID;
  lResult : longint;
begin
  lResult := CreateGUID(udtGUID);

  //Получаем гуид без фигурных скобок
  result:= copy(GUIDToString(udtGUID),2,36);
end;


//Регистрация нового пользователя.
function RegisterNewUser(strLogin,strPassword,strFirstName,strLastName:string;
                         dtDateOfBirth:TDateTime;
                         strGender:string):string;
var Lines:TStringList;
begin
  Lines:=TStringList.Create;
  Lines.Add('<?xml version="1.0" encoding="Windows-1251"?>');
  Lines.Add('<REQUEST operation="UserIn">');
  Lines.Add('<DTA>');
  Lines.Add('  <USER>');
  Lines.Add('    <EMAIL>'+FormatXMLStr(strLogin)+'</EMAIL>');
  Lines.Add('    <PASSWORD>'+FormatXMLStr(strPassword)+'</PASSWORD>');
  Lines.Add('    <FIRSTNAME>'+FormatXMLStr(strFirstName )+'</FIRSTNAME>');
  Lines.Add('    <LASTNAME>'+FormatXMLStr(strLastName )+'</LASTNAME>');
  Lines.Add('    <DATEOFBIRTH>'+FormatXMLDate(dtDateOfBirth) +'</DATEOFBIRTH>');
  Lines.Add('    <GENDER>'+FormatXMLStr(strGender)+'</GENDER>');
  Lines.Add('  </USER>');
  Lines.Add('</DTA>');
  Lines.Add('<CTX></CTX>');
  Lines.Add('</REQUEST>');
  result:=lines.text;
  Lines.free;
end;

//Проверка подлинности существующего  пользователя
function CheckUser(Context:TContext):string;
var Lines:TStringList;
begin
  Lines:=TStringList.Create;
  Lines.Add('<?xml version="1.0" encoding="Windows-1251"?>');
  Lines.Add('<REQUEST operation="UserCheck">');
  Lines.Add('<DTA/>');
  Lines.Add('<CTX>');
  Lines.Add('  <USER>'+FormatXMLStr(Context.Login)+'</USER>');
  Lines.Add('  <PASSWORD>'+FormatXMLStr(Context.Password)+'</PASSWORD>');
  Lines.Add('</CTX>');
  Lines.Add('</REQUEST>');
  result:=lines.text;
  Lines.free;
end;

function GetPoiByBBox(Context:TContext;MinLat,MinLon,MaxLat,MaxLon:double;
                      strCategory,strType:string):string;
var Lines:TStringList;
begin
  Lines:=TStringList.Create;
  Lines.Add('<?xml version="1.0" encoding="Windows-1251"?>');
  Lines.Add('<REQUEST operation="PoiOut">');
  Lines.Add('<DTA>');
  Lines.Add('  <MINLAT>'+FormatXMLDbl(MinLat)+'</MINLAT>');
  Lines.Add('  <MINLON>'+FormatXMLDbl(MinLon)+'</MINLON>');
  Lines.Add('  <MAXLAT>'+FormatXMLDbl(MaxLat)+'</MAXLAT>');
  Lines.Add('  <MAXLON>'+FormatXMLDbl(MaxLon)+'</MAXLON>');
  if strCategory<>''  then
    Lines.Add('  <CATEGORY>'+FormatXMLStr(strCategory)+'</CATEGORY>');

  if strType<>'' then
    Lines.Add('  <MP_TYPE>'+FormatXMLStr(strType)+'</MP_TYPE>');


  Lines.Add('</DTA>');
  Lines.Add('<CTX>');
  Lines.Add('  <USER>'+FormatXMLStr(Context.Login)+'</USER>');
  Lines.Add('  <PASSWORD>'+FormatXMLStr(Context.Password)+'</PASSWORD>' );
  Lines.Add('  <LAT>'+FormatXMLDbl(Context.CurrentLat)+'</LAT>' );
  Lines.Add('  <LON>'+FormatXMLDbl(Context.CurrentLon)+'</LON>' );
  Lines.Add('</CTX>');
  Lines.Add('</REQUEST>');
  result:=lines.text;
  Lines.free;
end;

function GetPoiCategories(Context:TContext):string;
var Lines:TStringList;
begin
  Lines:=TStringList.Create;
  Lines.Add('<?xml version="1.0" encoding="Windows-1251"?>');
  Lines.Add('<REQUEST operation="CategoryOut">');
  Lines.Add('<DTA/>');
  Lines.Add('<CTX>');
  Lines.Add('  <USER>'+FormatXMLStr(Context.Login)+'</USER>');
  Lines.Add('  <PASSWORD>'+FormatXMLStr(Context.Password)+'</PASSWORD>' );
  Lines.Add('</CTX>');
  Lines.Add('</REQUEST>');
  result:=lines.text;
  Lines.free;
end;

function SavePoi ( Context:TContext;
                   strID:string;
                   strMpPoiType:string;// тип пои
                   lat,lon:double;//Координаты
                   //3-й скрин
                   strPOIName, //Название
                   strAddrCountry,
                   strAddrCity,
                   strAddrStreet,
                   strAddrNumber,
                   //4-й скрин
                   strPhone,
                   strWebsite,
                   strOpeningHours,
                   strAvgBill:string;
                   blnWiFi:boolean;
                   strDescription:string
                   ):string;

var Lines:TStringList;
begin
  Lines:=TStringList.Create;
  Lines.Add('<?xml version="1.0" encoding="Windows-1251"?>');
  Lines.Add('<REQUEST operation="PoiIn">');
  Lines.Add('<DTA>');

  Lines.Add('<POI>');
  Lines.Add('  <ID>'+FormatXMLStr(strID)+'</ID>');
  //Lines.Add('  <OSM_ID></OSM_ID>');
  Lines.Add('  <MP_TYPE>'+FormatXMLStr(strMpPoiType)+'</MP_TYPE>');
  Lines.Add('  <COORD>');
  Lines.Add('    <LAT>'+FormatXMLDbl(Lat)+'</LAT>');
  Lines.Add('    <LON>'+FormatXMLDbl(Lon)+'</LON>');
  Lines.Add('  </COORD>');
  Lines.Add('  <NAME>'+FormatXMLStr(strPOIName)+'</NAME>');
  Lines.Add('  <DESCRIPTION1>'+FormatXMLStr(strDescription)+'</DESCRIPTION1>');
  Lines.Add('  <DESCRIPTION2></DESCRIPTION2>');
  Lines.Add('  <ADDRESS1></ADDRESS1>');
  Lines.Add('  <ADDRESS2>'+FormatXMLStr(strAddrCity)+'</ADDRESS2>');
  Lines.Add('  <ADDR_STREET>'+FormatXMLStr(strAddrStreet)+'</ADDR_STREET>');
  Lines.Add('  <ADDR_HOUSENUMBER>'+FormatXMLStr(strAddrNumber)+'</ADDR_HOUSENUMBER>');
  Lines.Add('  <PHONE>'+FormatXMLStr(strPhone)+'</PHONE>');
  Lines.Add('  <WEBSITE>'+FormatXMLStr(strWebsite)+'</WEBSITE>');
  Lines.Add('  <OPENING_HOURS>'+FormatXMLStr(strOpeningHours)+'</OPENING_HOURS>');
  Lines.Add('  <AVG_BILL>'+FormatXMLStr(strAvgBill)+'</AVG_BILL>');
  Lines.Add('  <WIFI_PRESENT>'+FormatXMLBool(blnWiFi)+'</WIFI_PRESENT>');
  Lines.Add('</POI>');


  Lines.Add('</DTA>');
  Lines.Add('<CTX>');
  Lines.Add('  <USER>'+FormatXMLStr(Context.Login)+'</USER>');
  Lines.Add('  <PASSWORD>'+FormatXMLStr(Context.Password)+'</PASSWORD>' );
  Lines.Add('</CTX>');
  Lines.Add('</REQUEST>');
  result:=lines.text;
  Lines.free;

end;

function AddComment( Context:TContext;
                   strPoiID:string;
                   strComment:string;
                   intRating:integer ):string;
var Lines:TStringList;
begin
  Lines:=TStringList.Create;
  Lines.Add('<?xml version="1.0" encoding="Windows-1251"?>');
  Lines.Add('<REQUEST operation="CommentIn">');
  Lines.Add('<DTA>');

  Lines.Add('<COMMENT>');
  Lines.Add('  <POI_ID>'+FormatXMLStr(strPoiID)+'</POI_ID>');
  Lines.Add('  <COMMENT>'+FormatXMLStr(strComment)+'</COMMENT>');
  Lines.Add('  <RATING>'+IntToStr(intRating)+'</RATING>');
  Lines.Add('</COMMENT>');


  Lines.Add('</DTA>');
  Lines.Add('<CTX>');
  Lines.Add('  <USER>'+FormatXMLStr(Context.Login)+'</USER>');
  Lines.Add('  <PASSWORD>'+FormatXMLStr(Context.Password)+'</PASSWORD>' );
  Lines.Add('</CTX>');
  Lines.Add('</REQUEST>');
  result:=lines.text;
  Lines.free;

end;

//==============================================================================
//                   Методы формы
//==============================================================================
procedure TfrmWebApi.LoadPoiCategories;
var strRequestXML,strResponseXML:string;
begin
   strRequestXML:=uWebApi.GetPoiCategories(frmMain.ApiContext);


  strResponseXML:=uWebApi.SendXML(strRequestXML);
  xmlPoiCategories:=LoadXMLData(strResponseXML);
end;

//Нужно получить тип пои (например '0x2C02')  по описанию.
function TfrmWebApi.GetMpTypeCodeByName(strTypeName:string):string;
var
  nodeCategories:IXMLNode;
  i,j:integer;
begin
   result:='';
   nodeCategories:=xmlPoiCategories.DocumentElement.ChildNodes['DTA'];
   for i := 0 to nodeCategories.ChildNodes.count-1  do
     for j := 1 to nodeCategories.ChildNodes[i].ChildNodes.Count-1  do
       if (nodeCategories.ChildNodes[i].ChildNodes[j].ChildNodes['NAME'].Text=strTypeName) then
         begin
           result:=nodeCategories.ChildNodes[i].ChildNodes[j].ChildNodes['MP_TYPE'].Text;
           exit;
         end;
end;

//Нужно получить описание типа по коду.
function TfrmWebApi.GetMpTypeNameByCode(strTypeCode:string):string;
var
  nodeCategories:IXMLNode;
  i,j:integer;
begin
   result:='';
   nodeCategories:=xmlPoiCategories.DocumentElement.ChildNodes['DTA'];
   for i := 0 to nodeCategories.ChildNodes.count-1  do
     for j := 1 to nodeCategories.ChildNodes[i].ChildNodes.Count-1  do
       if (nodeCategories.ChildNodes[i].ChildNodes[j].ChildNodes['MP_TYPE'].Text=strTypeCode) then
         begin
           result:=nodeCategories.ChildNodes[i].ChildNodes[j].ChildNodes['NAME'].Text;
           exit;
         end;
end;

//Проверяет,  является ли данная строка категорией пои
function TfrmWebApi.CheckCategoryName(strCategoryName:string):string;
var
  nodeCategories:IXMLNode;
  i:integer;
begin
   result:='';
   nodeCategories:=xmlPoiCategories.DocumentElement.ChildNodes['DTA'];
   for i := 0 to nodeCategories.ChildNodes.count-1  do
       if (nodeCategories.ChildNodes[i].ChildNodes['NAME'].Text=strCategoryName) then
         begin
           result:=strCategoryName;
           exit;
         end;

end;

end.
