unit uNewUser;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls, Vcl.ExtCtrls;

type
  TfrmNewUser = class(TForm)
    edLogin: TLabeledEdit;
    edPassword1: TLabeledEdit;
    edPassword2: TLabeledEdit;
    edFirstName: TLabeledEdit;
    edLastName: TLabeledEdit;
    edDateOfBirth: TDateTimePicker;
    rbMale: TRadioButton;
    rbFemale: TRadioButton;
    Label1: TLabel;
    Label2: TLabel;
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure ClearForm;
    function ValidateForm:boolean;
  end;

var
  frmNewUser: TfrmNewUser;


implementation
uses uWebApi, uXMLPoster, Xml.XMLIntf,XMLDoc;

{$R *.dfm}



procedure TfrmNewUser.Button1Click(Sender: TObject);
var strGender:string;
    strRequestXML:string;
    strResponseXML:string;
    xml:IXMLDocument;
    intErrorLevel:integer;
begin
  if Not  ValidateForm  then
    exit;


  strGender:='';
  if rbMale.Checked   then strGender:='M';
  if rbFemale.Checked  then strGender:='F';

  strRequestXML:=uWebApi.RegisterNewUser(edLogin.Text,
                          edPassword1.Text,
                          edFirstName.Text,
                          edLastName.Text,
                          edDateOfBirth.Date,
                          strGender);

  frmPoster.Memo1.Lines.Text:=strRequestXML;

  strResponseXML:=uWebApi.SendXML(strRequestXML);

  xml:=LoadXMLData(strResponseXML);

  //Ќеобходимо показать список ошибок, если они есть.
  intErrorLevel:=DisplayMessages(xml);

  //если результат положительный, идти дальше (закрыть форму).


  //frmPoster.Show;

  if intErrorLevel<=ERR_WARNING then
    self.ModalResult:=mrOk;
end;

procedure TfrmNewUser.ClearForm;
begin
  edLogin.Text:='';
  edPassword1.Text:='';
  edPassword2.Text:='';
  edFirstName.Text:='';
  edLastName.Text:='';
  edDateOfBirth.Date:=2;
  rbMale.checked:=false;
  rbFemale.checked:=false;
end;
procedure TfrmNewUser.FormShow(Sender: TObject);
begin
  ClearForm;
end;

function TfrmNewUser.ValidateForm:boolean;
begin
  result:=true;
  if edPassword1.Text<> edPassword2.Text then
  begin
    result:=false;
    MessageDlg('ѕароль и подтверждение парол€ не совпадают', mtError,[mbOK],0);
  end;

end;

end.
