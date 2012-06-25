unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.RibbonLunaStyleActnCtrls,
  Vcl.Ribbon, Vcl.Menus, Vcl.ComCtrls;

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
    procedure XML1Click(Sender: TObject);
    procedure N4Click(Sender: TObject);
    procedure N2Click(Sender: TObject);
    procedure N3Click(Sender: TObject);
    procedure N6Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    UserLogin:string;
    UserPassword:string;
  end;

var
  frmMain: TfrmMain;

implementation
uses uXMLPoster,uNewUser, uLogin,uPoiEditor;
{$R *.dfm}

procedure TfrmMain.FormShow(Sender: TObject);
begin
 N2Click(Sender);
end;

procedure TfrmMain.N2Click(Sender: TObject);
begin
  frmLogin.ShowModal;
  if frmLogin.ModalResult=mrOk  then
  begin
    //Логин успешен. Имя пользователя и пароль нужно куда-то сохранить,
    //потому что они используются во всех запросах, вывести в статус-баре
    UserLogin:=frmLogin.edLogin.Text;
    UserPassword:=frmLogin.edPassword1.Text;
    N4.Enabled:=false;
    N2.Enabled:=false;
    N3.Enabled:=true;
    StatusBar1.Panels[0].Text:=UserLogin;

  end;

end;

procedure TfrmMain.N3Click(Sender: TObject);
begin
    UserLogin:='';
    UserPassword:='';
    N4.Enabled:=true;
    N2.Enabled:=true;
    N3.Enabled:=false;
    StatusBar1.Panels[0].Text:=UserLogin;

end;

procedure TfrmMain.N4Click(Sender: TObject);
begin
 frmNewUser.ShowModal;
end;

procedure TfrmMain.N6Click(Sender: TObject);
begin
  frmPoiEditor.ShowToMakeNewPoi;
end;

procedure TfrmMain.XML1Click(Sender: TObject);
begin
  frmPoster.Show;
end;

end.
