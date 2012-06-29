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
    chkRememberMe: TCheckBox;
    Label1: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmLogin: TfrmLogin;

implementation
 uses uWebApi,uXMLPoster,uNewUser, Xml.XMLIntf,XMLDoc,Registry,uMain;
{$R *.dfm}

procedure TfrmLogin.Button1Click(Sender: TObject);
var  strRequestXML:string;
     strResponseXML:string;
     xml:IXMLDocument;
     intErrorLevel:integer;
     Registry: TRegistry;
begin
  //�������� ���������
  frmMain.ApiContext:=TContext.Create(edLogin.Text,
                                      edPassword1.Text);

  strRequestXML:=uWebApi.CheckUser(frmMain.ApiContext);

  frmPoster.Memo1.Lines.Text:=strRequestXML;
  strResponseXML:=uWebApi.SendXML(strRequestXML);

  xml:=LoadXMLData(strResponseXML);



  intErrorLevel:=uWebApi.DisplayMessages(xml);


  //frmPoster.Show;

  if intErrorLevel<=ERR_WARNING then
  begin

      { ������ ������ TRegistry }
      Registry := TRegistry.Create;
      { ������������� �������� ����; ������� hkey_local_machine ��� hkey_current_user }
      Registry.RootKey := HKEY_CURRENT_USER;
      { ��������� � ������ ���� }
      Registry.OpenKey('software\Osm4u',true);
      { ���������� �������� }
      if chkRememberMe.Checked   then
      begin
        Registry.WriteString('login',edLogin.Text);
        Registry.WriteString('password',edPassword1.Text );
        Registry.WriteBool('rememberme',chkRememberMe.Checked);
      end
      else
      begin
        Registry.DeleteValue('login');
        Registry.DeleteValue('password' );
        Registry.WriteBool('rememberme',chkRememberMe.Checked);
      end;
      { ��������� � ����������� ���� }
      Registry.CloseKey;
      Registry.Free;


    self.ModalResult:=mrOk;
  end;
end;

procedure TfrmLogin.Button2Click(Sender: TObject);
begin
  frmNewUser.ShowModal;
end;

procedure TfrmLogin.FormShow(Sender: TObject);
var
 Registry: TRegistry;
begin
       Registry := TRegistry.Create;
      { ������������� �������� ����; ������� hkey_local_machine ��� hkey_current_user }
      Registry.RootKey := HKEY_CURRENT_USER;
      { ��������� � ������ ���� }
      Registry.OpenKey('software\Osm4u',true);
      { ������ �������� }
      if Registry.ValueExists('rememberme') then
        chkRememberMe.Checked:=Registry.ReadBool('rememberme')
      else   chkRememberMe.Checked:=false;

      edLogin.Text:=Registry.ReadString('login');
      edPassword1.Text:=Registry.ReadString('password');
      { ��������� � ����������� ���� }
      Registry.CloseKey;
      Registry.Free;
end;

end.
