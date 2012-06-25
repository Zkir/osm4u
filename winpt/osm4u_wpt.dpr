program osm4u_wpt;

uses
  Vcl.Forms,
  uMain in 'uMain.pas' {frmMain},
  uNewUser in 'uNewUser.pas' {frmNewUser},
  uLogin in 'uLogin.pas' {frmLogin},
  uXMLposter in 'uXMLposter.pas' {frmPoster},
  uWebApi in 'uWebApi.pas' {frmWebApi: TDataModule},
  uPoiEditor in 'uPoiEditor.pas' {frmPoiEditor};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMain, frmMain);
  Application.CreateForm(TfrmNewUser, frmNewUser);
  Application.CreateForm(TfrmLogin, frmLogin);
  Application.CreateForm(TfrmPoster, frmPoster);
  Application.CreateForm(TfrmWebApi, frmWebApi);
  Application.CreateForm(TfrmPoiEditor, frmPoiEditor);
  Application.Run;
end.
