unit uLogin;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls;

type
  TfrmLogin = class(TForm)
    edPassword1: TLabeledEdit;
    edLogin: TLabeledEdit;
    Button1: TButton;
    Button2: TButton;
    chbRememberMe: TCheckBox;
    Label1: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmLogin: TfrmLogin;

implementation
 uses uWebApi,uXMLPoster,uNewUser, Xml.XMLIntf,XMLDoc;
{$R *.dfm}

procedure TfrmLogin.Button1Click(Sender: TObject);
var  strRequestXML:string;
     strResponseXML:string;
     xml:IXMLDocument;
     intErrorLevel:integer;
begin
  strRequestXML:=uWebApi.CheckUser(edLogin.Text,
                                   edPassword1.Text);

  frmPoster.Memo1.Lines.Text:=strRequestXML;
  strResponseXML:=uWebApi.SendXML(strRequestXML);

  xml:=LoadXMLData(strResponseXML);



  intErrorLevel:=uWebApi.DisplayMessages(xml);


  //frmPoster.Show;

  if intErrorLevel<=ERR_WARNING then
    self.ModalResult:=mrOk
end;

procedure TfrmLogin.Button2Click(Sender: TObject);
begin
  frmNewUser.ShowModal;
end;

end.
