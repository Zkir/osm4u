unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.RibbonLunaStyleActnCtrls,
  Vcl.Ribbon, Vcl.Menus, Vcl.ComCtrls, Vcl.ExtCtrls, Vcl.Grids,Xml.XMLIntf,XMLDoc,
  stelmap, Vcl.StdCtrls,uWebApi;

type
  TfrmMain = class(TForm)
    MainMenu1: TMainMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;
    N6: TMenuItem;
    N7: TMenuItem;
    N8: TMenuItem;
    StatusBar1: TStatusBar;
    N9: TMenuItem;
    XML1: TMenuItem;
    tvClassificator: TTreeView;
    Panel1: TPanel;
    dgPoiList: TDrawGrid;
    mapMiniMap: TStelMap;
    Label1: TLabel;
    procedure XML1Click(Sender: TObject);
    procedure N4Click(Sender: TObject);
    procedure N2Click(Sender: TObject);
    procedure N3Click(Sender: TObject);
    procedure N6Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure dgPoiListDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure FormCreate(Sender: TObject);
    procedure tvClassificatorDblClick(Sender: TObject);

  private
    { Private declarations }
    xmlNearerPoi:IXMLDocument;
    procedure FillPoiClassificator;
    Procedure GetNearerPoiList(strCategory,strType:string);
    //Function Login:boolean;
  public
    { Public declarations }
    ApiContext:TApiContext;
  end;

var
  frmMain: TfrmMain;



implementation
uses uXMLPoster,uNewUser, uLogin,uPoiEditor;
{$R *.dfm}

function DistanceKm(lat1,lon1,lat2,lon2:double):double;
const grad_len=111.0;
begin
   result:= sqrt(sqr(grad_len*(lat1-lat2))+sqr(grad_len*cos(lat1/180*Pi)*(lon1-lon2)));
end;

procedure TfrmMain.dgPoiListDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);

var
  strName,strAddr,strType:string;
  dblDist:double;
  dblRating:double;
  intCommentsNumber:integer;
  intMarksNumber:integer;
  strTmp:string;
  intLen:integer;
  nodePOI:IXMLNode;
  poiLat,poiLon:double;
  strRecomendation:string;
begin
if ARow<>0  then
begin
   nodePOI:=xmlNearerPoi.DocumentElement.ChildNodes['DTA'].ChildNodes[ARow-1];

   strName:=nodePOI.ChildNodes['NAME'].Text;
   strAddr:=nodePOI.ChildNodes['ADDRESS3'].Text;
   strType:=frmWebApi.GetMpTypeNameByCode(nodePOI.ChildNodes['MP_TYPE'].Text);
   //strType:=nodePOI.ChildNodes['MP_TYPE'].Text;

   if strName='' then strName:='<'+strType+'>';

   poiLat:=StrToFloat(nodePOI.ChildNodes['COORD'].ChildNodes['LAT'].Text);
   poiLon:=StrToFloat(nodePOI.ChildNodes['COORD'].ChildNodes['LON'].Text);

   dblDist:=DistanceKm(ApiContext.CurrentLat,ApiContext.CurrentLon, poiLat, poiLon);


   if nodePOI.ChildNodes['RATING'].Text<>'' then
     dblRating:=StrToFloat(nodePOI.ChildNodes['RATING'].Text)
   else
     dblRating:=0;

   intMarksNumber:=StrToInt(nodePOI.ChildNodes['NUMBER_OF_RATINGS'].Text);
   intCommentsNumber:=StrToInt(nodePOI.ChildNodes['NUMBER_OF_COMMENTS'].Text);

   dgPoiList.Canvas.Font.Name:='Arial Unicode MS';
   dgPoiList.Canvas.Font.Style:=[fsBold];
   dgPoiList.Canvas.TextOut(rect.Left+10,rect.Top+4, strName);
   dgPoiList.Canvas.Font.Style:=[];
   dgPoiList.Canvas.TextOut(rect.Left+10,rect.Top+19, strAddr);

   dgPoiList.Canvas.Font.Style:=[];
   dgPoiList.Canvas.TextOut(rect.Left+10,rect.Top+36, 'Категория: '+strType);



   //Расстояние
   if dblDist<1 then
     strTmp:=FloatToStrF(dblDist*1000,ffFixed,3,0)+' м'
   else
     strTmp:=FloatToStrF(dblDist,ffFixed,4,1)+' км';

   intLen:=dgPoiList.Canvas.TextWidth(strTmp );
   dgPoiList.Canvas.TextOut(rect.Right-6-intLen,rect.Top+4, strTmp);

   //Оценка, если есть.
   if dblRating<>0  then
   begin

     dgPoiList.Canvas.Font.Style:=[];
     dgPoiList.Canvas.Font.Size:=14;
     if (dblRating<3)   then
       begin
         strTmp:=  #10025+#10025+#10025;
         strRecomendation:=RECOMENDATION_2;
       end;

     if (dblRating>=3) and (dblRating<=3.66)   then
       begin
         strTmp:=  #9733+#10025+#10025;
         strRecomendation:=RECOMENDATION_3;
       end;

     if (dblRating>3.66) and (dblRating<=4.33)   then
       begin
         strTmp:=  #9733+#9733+#10025;
         strRecomendation:=RECOMENDATION_4;
       end;

     if (dblRating>4.33) and (dblRating<=5)   then
       begin
         strTmp:=  #9733+#9733+#9733;
         strRecomendation:=RECOMENDATION_5;
       end;

     intLen:=dgPoiList.Canvas.TextWidth(strTmp );
     dgPoiList.Canvas.TextOut(rect.Right-6-intLen,rect.Top+19, strTmp);

     dgPoiList.Canvas.Font.Size:=8;
     strTmp:='Оценка:'+FormatFloat('0.0',  dblRating) ;
     intLen:=dgPoiList.Canvas.TextWidth(strTmp );
     dgPoiList.Canvas.TextOut(rect.Right-6-intLen,rect.Top+45, strTmp);

     dgPoiList.Canvas.Font.Size:=10;
     strTmp:= #$270E+IntToStr(intCommentsNumber)+' '+#$2727+IntToStr(intMarksNumber);
     intLen:=dgPoiList.Canvas.TextWidth(strTmp );
     dgPoiList.Canvas.TextOut(rect.Right-6-intLen,rect.Top+59, strTmp);

     dgPoiList.Canvas.Font.Size:=8;
     dgPoiList.Canvas.Font.Style:=[fsItalic];
     dgPoiList.Canvas.TextOut(rect.Left+10,rect.Top+53,
            'Рекомендация Osm4u: '+strRecomendation);
   end;





   end
else
  begin

    dgPoiList.Canvas.TextOut(rect.Left+6,rect.Top+4, 'Результаты поиска: '+inttostr(dgPoiList.RowCount-1)  +' шт.');
  end;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  mapMiniMap.LAT := 0;
  mapMiniMap.LON := 0;
  mapMiniMap.Zoom := 16;

  mapMiniMap.AddLayer;
  mapMiniMap.ShowSet:=false;
end;

procedure TfrmMain.FormResize(Sender: TObject);
begin
  dgPoiList.ColWidths[0]:=dgPoiList.Width-25;
  dgPoiList.Repaint ;
end;

procedure TfrmMain.FormShow(Sender: TObject);
var
  Car : TBMPObject;
begin
 dgPoiList.RowHeights[0]:=25;

 //Первое и главное - логин
 N2Click(Sender);

 //Получим классификатор
 frmWebApi.LoadPoiCategories;

 FillPoiClassificator;


  //Отобразим список пои рядом
  GetNearerPoiList('','');
  dgPoiList.Refresh;

  mapMiniMap.LAT := ApiContext.CurrentLat;
  mapMiniMap.LON := ApiContext.CurrentLon;

  mapMiniMap.MapResize;
  mapMiniMap.Prepare;
  mapMiniMap.LoadMap(0, 0, TRUE);
  mapMiniMap.ReDraw;



  Car := mapMiniMap.Layers(0).AddBitmap(ApiContext.CurrentLAT , ApiContext.CurrentLON, '', True, 0, 0);
  Car.BitMap.LoadFromFile('d:\OSM\_osm4u\car.bmp');
  Car.BitMap.Transparent := TRUE;

end;

procedure TfrmMain.FillPoiClassificator;
var


  nodeCategories:IXMLNode;
  i,j:integer;

  var nRoot,nItem:TTreeNode;
begin


  //Заполнение дерева категорий
  nodeCategories:=frmWebApi.xmlPoiCategories.DocumentElement.ChildNodes['DTA'];

  nRoot:=tvClassificator.Items.GetFirstNode;
  for i := 0 to nodeCategories.ChildNodes.count-1  do
  begin
    nItem:=tvClassificator.Items.AddChild(nRoot,nodeCategories.ChildNodes[i].ChildNodes['NAME'].Text);
    for j := 1 to nodeCategories.ChildNodes[i].ChildNodes.Count-1  do
      tvClassificator.Items.AddChild(nItem,nodeCategories.ChildNodes[i].ChildNodes[j].ChildNodes['NAME'].Text);

  end;


end;

Procedure TfrmMain.GetNearerPoiList(strCategory,strType:string);
var
  strRequestXML,strResponseXML:string;
const
  DELTA=0.05;
begin
  strRequestXML:=uWebApi.GetPoiByBBox (
                          frmMain.ApiContext,
                          frmMain.ApiContext.CurrentLat-DELTA,
                          frmMain.ApiContext.CurrentLon-(DELTA)/cos(frmMain.ApiContext.CurrentLat/180*Pi),
                          frmMain.ApiContext.CurrentLat+DELTA,
                          frmMain.ApiContext.CurrentLon+DELTA/cos(frmMain.ApiContext.CurrentLat/180*Pi),
                          strCategory,
                          strType);

  frmPoster.Memo1.Lines.Text:=strRequestXML;

  strResponseXML:=uWebApi.SendXML(strRequestXML);
  xmlNearerPoi:=LoadXMLData(strResponseXML);
  dgPoiList.RowCount:=xmlNearerPoi.DocumentElement.ChildNodes['DTA'].ChildNodes.count+1;


end;

procedure TfrmMain.N2Click(Sender: TObject);
begin
  frmLogin.ShowModal;
  if frmLogin.ModalResult=mrOk  then
  begin
    //Логин успешен. Имя пользователя и пароль нужно куда-то сохранить,
    //потому что они используются во всех запросах, вывести в статус-баре
    //UserLogin:=frmLogin.edLogin.Text;
    //UserPassword:=frmLogin.edPassword1.Text;
    N4.Enabled:=false;
    N2.Enabled:=false;
    N3.Enabled:=true;
    StatusBar1.Panels[0].Text:=ApiContext.Login;
  end
  else
    self.Close;

end;

procedure TfrmMain.N3Click(Sender: TObject);
begin
    //Выход
    ApiContext.Free;
    N4.Enabled:=true;
    N2.Enabled:=true;
    N3.Enabled:=false;
    StatusBar1.Panels[0].Text:='';

end;

procedure TfrmMain.N4Click(Sender: TObject);
begin
 frmNewUser.ShowModal;
end;

procedure TfrmMain.N6Click(Sender: TObject);
begin
  frmPoiEditor.ShowToMakeNewPoi;
end;

procedure TfrmMain.tvClassificatorDblClick(Sender: TObject);
var
  strSelectedItem:string;
  strCategory:string;
  strType:string;
begin
  strSelectedItem:=tvClassificator.Selected.Text;


  strType:=frmWebApi.GetMpTypeCodeByName(strSelectedItem);
  strCategory:=frmWebApi.CheckCategoryName(strSelectedItem);

  //Отобразим список пои рядом
  GetNearerPoiList(strCategory,strType);
  dgPoiList.Refresh;
end;



procedure TfrmMain.XML1Click(Sender: TObject);
begin
  frmPoster.Show;
end;

end.
