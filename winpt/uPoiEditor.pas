unit uPoiEditor;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ToolWin, Vcl.ComCtrls, Vcl.ExtCtrls,
  Vcl.StdCtrls, stelmap, Vcl.ButtonGroup, Vcl.CategoryButtons, Vcl.Grids,Xml.XMLIntf,XMLDoc;

type
  TfrmPoiEditor = class(TForm)
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    Panel1: TPanel;
    btnBack: TButton;
    btnNext: TButton;
    Panel2: TPanel;
    lblStepHint: TLabel;
    TabSheet3: TTabSheet;
    lblStepTitle: TLabel;
    edPOIName: TLabeledEdit;
    edAddrCountry: TLabeledEdit;
    edAddrCity: TLabeledEdit;
    edAddrStreet: TLabeledEdit;
    cbPoiCategory: TComboBox;
    cbPoiType: TComboBox;
    Label5: TLabel;
    Label6: TLabel;
    TabSheet4: TTabSheet;
    Label7: TLabel;
    Label8: TLabel;
    edPhone: TLabeledEdit;
    edWebsite: TLabeledEdit;
    edOpeningHours: TLabeledEdit;
    edAvgBill: TLabeledEdit;
    mmDescription: TMemo;
    lblRecomendation: TLabel;
    Label11: TLabel;
    cbRating: TComboBox;
    StelMap1: TStelMap;
    lblLoadMap: TLabel;
    Label1: TLabel;
    Label2: TLabel;
    sgExistingPoi: TStringGrid;
    cbNoDuplicate: TCheckBox;
    edAddrHouseNumber: TLabeledEdit;
    Label3: TLabel;
    chbWiFi: TCheckBox;
    procedure cbRatingChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormMouseWheelDown(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure FormMouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure FormResize(Sender: TObject);
    procedure StelMap1MapMouseClick(Button: TMouseButton; Shift: TShiftState;
      LAT, LON: Double; x, y: Integer);
    procedure StelMap1MapMouseMove(LAT, LON: Double; x, y: Integer);
    procedure StelMap1BeginMapLoad(count: Integer);
    procedure StelMap1EndMapLoad;
    procedure btnNextClick(Sender: TObject);
    procedure btnBackClick(Sender: TObject);
    procedure StelMap1DblClick(Sender: TObject);
    procedure cbPoiCategoryChange(Sender: TObject);

  private
    { Private declarations }
    GlobalLAT, GlobalLON : Double;
    CurrentLAT, CurrentLON : Double;
    PoiLAT, PoiLON : Double;
    blnMarkerSet:boolean;
    blnNearerPoiLoaded:boolean;

    Procedure SetStep(intStep:integer);
    Procedure ClearMiniMap;
    Procedure AddMarkerToMiniMap;
    Procedure GetNearerPoiList;
    procedure GetPoiCategories;

    procedure SavePoiToDB;
  public
    { Public declarations }

    procedure ShowToMakeNewPoi;
  end;

var
  frmPoiEditor: TfrmPoiEditor;


implementation
uses uWebApi,uXmlPoster,uMain;

{$R *.dfm}


procedure TfrmPoiEditor.ClearMiniMap ;
begin
  blnMarkerSet:=false;
  StelMap1.Layers(0).BitMapList.Clear;
  StelMap1.Layers(0).ShapeList.Clear;
  StelMap1.ReDraw;
end;

procedure TfrmPoiEditor.AddMarkerToMiniMap ;
var
  Car : TBMPObject;
begin
  Car := StelMap1.Layers(0).AddBitmap(CurrentLAT , CurrentLON, '', True, 0, 0);
  Car.BitMap.LoadFromFile('d:\OSM\_osm4u\car.bmp');
  Car.BitMap.Transparent := TRUE;

  PoiLat:= CurrentLAT;
  PoiLon:= CurrentLON;

  blnMarkerSet:=True;
  blnNearerPoiLoaded:=False;
  StelMap1.ReDraw;
end;



procedure TfrmPoiEditor.cbRatingChange(Sender: TObject);
var strRecomendation:string;
begin
  strRecomendation:='';
  case cbRating.ItemIndex+1 of
   1:  strRecomendation:=RECOMENDATION_1;//'К посещению НЕ рекомендуется';
   2:  strRecomendation:=RECOMENDATION_2;//'К посещению не рекомендуется';
   3:  strRecomendation:=RECOMENDATION_3;//'К посещению рекомендуется с оговорками';
   4:  strRecomendation:=RECOMENDATION_4;//'К посещению рекомендуется';
   5:  strRecomendation:=RECOMENDATION_5;//'Посетить обязательно!';
   else
     strRecomendation:='Ваша рекомендация?';
  end;
  lblRecomendation.Caption:=strRecomendation;
end;

procedure TfrmPoiEditor.FormCreate(Sender: TObject);
begin
  StelMap1.LAT := 0;
  StelMap1.LON := 0;
  StelMap1.Zoom := 16;

  StelMap1.AddLayer;
  blnMarkerSet:=false;
  blnNearerPoiLoaded:=false;
end;

procedure TfrmPoiEditor.FormMouseWheelDown(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin
  StelMap1.ZoomInPos(GlobalLAT, GlobalLON);
  Handled := TRUE;
end;

procedure TfrmPoiEditor.FormMouseWheelUp(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin
  StelMap1.ZoomOutPos(GlobalLAT, GlobalLON);
  Handled := TRUE;
end;

procedure TfrmPoiEditor.FormResize(Sender: TObject);
begin
  StelMap1.MapResize;
  StelMap1.Prepare;
  StelMap1.LoadMap(0, 0, TRUE);
  StelMap1.ReDraw;
end;


procedure TfrmPoiEditor.StelMap1BeginMapLoad(count: Integer);
begin
  lblLoadMap.Visible := True;
  lblLoadMap.Refresh;
end;

procedure TfrmPoiEditor.StelMap1DblClick(Sender: TObject);
begin
  //убрать старые отметки
  ClearMiniMap;
  cbNoDuplicate.checked:=false;

  //Добавить новую.
  AddMarkerToMiniMap;
end;

procedure TfrmPoiEditor.StelMap1EndMapLoad;
begin
  lblLoadMap.Visible := False;
  lblLoadMap.Refresh;
end;

procedure TfrmPoiEditor.StelMap1MapMouseClick(Button: TMouseButton;
  Shift: TShiftState; LAT, LON: Double; x, y: Integer);
begin
  CurrentLAT := LAT;
  CurrentLON := LON;
end;

procedure TfrmPoiEditor.StelMap1MapMouseMove(LAT, LON: Double; x, y: Integer);
begin
  GlobalLAT := LAT;
  GlobalLON := LON;
end;

Procedure TfrmPoiEditor.setStep(intStep:integer);

begin
  case intStep  of
   1: begin
        lblStepTitle.Caption := 'Шаг 1. Укажите, где находится место';
        lblStepHint.Caption:=  'Укажите место, поставив точку на карте';
        btnNext.Caption:='Дальше >>';
        btnBack.Enabled:=false;
      end;

   2: begin
        lblStepTitle.Caption:= 'Шаг 2. Проверьте, есть ли это место в списке ';
        lblStepHint.Caption:=  'Возможно, место, которое вы хотите добавить, уже есть на карте';
        btnNext.Caption:='Дальше >>';
        btnBack.Enabled:=true;
      end;
   3: begin
        lblStepTitle.Caption:= 'Шаг 3. Укажите тип места и адрес';
        lblStepHint.Caption:=  '';
        btnNext.Caption:='Дальше >>';
        btnBack.Enabled:=true;
      end;
   4: begin
        lblStepTitle.Caption:= 'Шаг 4. Заполните дополнительную информацию о месте';
        lblStepHint.Caption:=  'Эти сведения помогут другим людям решить, стоит ли посещать это место';
        btnNext.Caption:='Готово';
        btnBack.Enabled:=true;
      end;
  end;

  //На втором шаге нужно получить список окресных пои
  if intStep=2 then
  begin
    if not blnNearerPoiLoaded then
      begin
        GetNearerPoiList;
        //MessageDlg('Запрос',mtInformation , [mbOk],0);
      end;
  end;




end;

Procedure TfrmPoiEditor.GetNearerPoiList;
var
  strRequestXML,strResponseXML:string;
  xml:IXMLDocument;
  nodePOIs:IXMLNode;
  i:integer;
begin
  strRequestXML:=uWebApi.GetPoiByBBox (
                          frmMain.ApiContext,
                          CurrentLat-0.001,
                          CurrentLon-(0.001)/cos(CurrentLat/180*Pi),
                          CurrentLat+0.001,
                          CurrentLon+0.001/cos(CurrentLat/180*Pi),
                          '','');

  frmPoster.Memo1.Lines.Text:=strRequestXML;

  strResponseXML:=uWebApi.SendXML(strRequestXML);
  xml:=LoadXMLData(strResponseXML);

  nodePOIs:=xml.DocumentElement.ChildNodes['DTA'];
  sgExistingPoi.RowCount:=nodePOIs.ChildNodes.count;
  //

  for i := 0 to nodePOIs.ChildNodes.count-1  do
  begin
    sgExistingPoi.cells[0,i]:=frmWebApi.GetMpTypeNameByCode(nodePOIs.ChildNodes[i].ChildNodes['MP_TYPE'].Text);
    //if not nodePOIs.ChildNodes[i].ChildNodes['NAME'].t then

    sgExistingPoi.cells[1,i]:=nodePOIs.ChildNodes[i].ChildNodes['NAME'].Text;
    sgExistingPoi.cells[2,i]:=nodePOIs.ChildNodes[i].ChildNodes['ADDRESS3'].Text;
  end;
  sgExistingPoi.ColWidths[0]:=64;
  sgExistingPoi.ColWidths[1]:=200;
  sgExistingPoi.ColWidths[2]:=200;

  blnNearerPoiLoaded:=true;
end;

procedure TfrmPoiEditor.GetPoiCategories;
var

  nodeCategories:IXMLNode;
  i:integer;
begin

  nodeCategories:=frmWebApi.xmlPoiCategories.DocumentElement.ChildNodes['DTA'];
  cbPoiCategory.Items.Clear;
  cbPoiCategory.Items.Add('(выберите категорию)');

  for i := 0 to nodeCategories.ChildNodes.count-1  do
  begin
    cbPoiCategory.Items.Add(nodeCategories.ChildNodes[i].ChildNodes['NAME'].Text);

  end;
  cbPoiCategory.ItemIndex:=0;
  cbPoiType.Items.Clear;

end;

procedure TfrmPoiEditor.cbPoiCategoryChange(Sender: TObject);
var
  strCategoryName:string;
  nodeCategories:IXMLNode;
  i,j:integer;
begin
  if cbPoiCategory.ItemIndex<>0 then
  begin
    strCategoryName:=cbPoiCategory.Text;
    //Тут нужно выбирать дочерние типы
     nodeCategories:=frmWebApi.xmlPoiCategories.DocumentElement.ChildNodes['DTA'];
     for i := 0 to nodeCategories.ChildNodes.count-1  do
       if (nodeCategories.ChildNodes[i].ChildNodes['NAME'].Text=strCategoryName) then
       begin
         cbPoiType.Items.clear();
         cbPoiType.Items.Add('(выберите тип места)');
         for j := 1 to nodeCategories.ChildNodes[i].ChildNodes.Count-1  do
           cbPoiType.Items.Add(nodeCategories.ChildNodes[i].ChildNodes[j].ChildNodes['NAME'].Text);
         cbPoiType.ItemIndex:=0;
       end;
  end
  else
    cbPoiType.Items.clear();
end;

procedure TfrmPoiEditor.btnBackClick(Sender: TObject);
begin
  //Переход к предыдущему
      PageControl1.ActivePageIndex:=PageControl1.ActivePageIndex-1;
      setStep(PageControl1.ActivePageIndex+1);
end;

procedure TfrmPoiEditor.btnNextClick(Sender: TObject);

begin
  //Валидация текущего скрина
  case PageControl1.ActivePageIndex+1 of
  1:begin
    //На первом скрине нужно выбрать положение пои.
    if not blnMarkerSet  then
      begin
        MessageDlg('Нужно указать положение вашего места.'+#10#13+'Дважды щелкните по миникарте',mtWarning, [mbOk],0);
        exit;
      end;
    end;
  2:
    //На втором скрине нужно подтвердить отсутствие дупликата
    if not cbNoDuplicate.Checked then
      begin
        MessageDlg('Проверьте пожалуйста, список имеющихся мест.',mtInformation, [mbOk],0);
        exit;
      end;
  3:
    //На третьем скрине нужно указать название и выбрать тип.
    //Адрес является, к сожалению, опциональным
    begin
      if trim(edPOIName.Text)=''  then
        begin
          MessageDlg('Укажите название места.',mtInformation, [mbOk],0);
          exit;
        end;
      if (cbPoiCategory.ItemIndex=0)or(cbPoiType.ItemIndex=0)   then
        begin
          MessageDlg('Нужно выбрать категорию и тип места.',mtInformation, [mbOk],0);
          exit;
        end;
    end;

  end;

  //Переход к следующему
  if PageControl1.ActivePageIndex+1<4 then
    begin
      PageControl1.ActivePageIndex:=PageControl1.ActivePageIndex+1;
      setStep(PageControl1.ActivePageIndex+1);
    end
  else
    begin
      //Последний таб.
      SavePoiToDB;
      self.Close;
    end;
end;

procedure TfrmPoiEditor.ShowToMakeNewPoi;
begin
  StelMap1.LAT:=frmMain.ApiContext.CurrentLat;
  StelMap1.LON:=frmMain.ApiContext.CurrentLon;
  //Нужно все почистить
  //1-й и 2-й скрин
  ClearMiniMap;
  cbNoDuplicate.checked:=false;
  //3-й скрин
  edPOIName.text:='';
  edAddrCountry.text:='';
  edAddrCity.text:='';
  edAddrStreet.text:='';
  edAddrHouseNumber.text:='';

  cbPoiCategory.Items.Clear;
  cbPoiType.Items.Clear;

  //4-й скрин
  edPhone.text:='';
  edWebsite.text:='';
  edOpeningHours.text:='';
  edAvgBill.text:='';
  cbRating.ItemIndex:=-1;
  lblRecomendation.Caption:='Ваша рекомендация?';
  mmDescription.Lines.Clear;

  //Получим классификатор
  GetPoiCategories;

  //Установить первый шаг
  PageControl1.ActivePageIndex:=0;
  SetStep(1);
  //Показать самого себя модально.
  ShowModal;
end;




//Отправка Пои на сервер.
procedure TfrmPoiEditor.SavePoiToDB;
var
  strRequestXML,strResponseXML:string;
  xml:IXMLDocument;
  strPoiGuid:string;

begin

  strPoiGuid:= uWebApi.GetGuid();
  //Вызываем API -  добавление пои
  strRequestXML:=uWebApi.SavePoi (
                          frmMain.ApiContext,
                          //Гуид (новый для нового пои)
                          strPoiGuid,
                          //Тип
                          frmWebApi.GetMpTypeCodeByName(cbPoiType.Text),
                          // (координата)
                          PoiLat,PoiLon,
                          edPOIName.text, //Название

                          edAddrCountry.Text,
                          edAddrCity.Text,
                          edAddrStreet.Text,
                          edAddrHouseNumber.Text,
                          //4-й скрин
                          edPhone.text,
                          edWebsite.text,
                          edOpeningHours.text,
                          edAvgBill.text,
                          chbWiFi.Checked,
                          mmDescription.Lines.text
                          );

  frmPoster.Memo1.Lines.Text:=strRequestXML;

  strResponseXML:=uWebApi.SendXML(strRequestXML);
  xml:=LoadXMLData(strResponseXML);
  uWebApi.DisplayMessages(xml);

  //Вызываем API -  добавление оценки, для нового пои, это отдельная операция
  strRequestXML:=uWebApi.AddComment  (
                          frmMain.ApiContext,
                          //Гуид (новый для нового пои)
                          strPoiGuid,
                          //Тип
                          '',//Коммент, в данном случае пустой.
                          cbRating.ItemIndex+1//Установка оценки( рейтинга) может быть отдельной операцией
                          );

  frmPoster.Memo1.Lines.Text:=strRequestXML;


  strResponseXML:=uWebApi.SendXML(strRequestXML);
  xml:=LoadXMLData(strResponseXML);
  uWebApi.DisplayMessages(xml);


end;

end.
