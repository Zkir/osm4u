unit uXMLposter;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, IdBaseComponent, IdComponent,
  IdTCPConnection, IdTCPClient, IdHTTP, Vcl.ExtCtrls, Vcl.StdCtrls,
  Vcl.OleCtrls, SHDocVw;

type
  TfrmPoster = class(TForm)
    Memo1: TMemo;
    Panel1: TPanel;
    Button1: TButton;
    Splitter1: TSplitter;
    WebBrowser1: TWebBrowser;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmPoster: TfrmPoster;

implementation
uses MSHTML, ActiveX, uWebApi;
{$R *.dfm}



procedure TfrmPoster.Button1Click(Sender: TObject);

var response:string;

   Document: IHTMLDocument2;
   V: OleVariant;

begin
  //Memo2.Lines.Clear;



  response:=uWebApi.SendXML(memo1.Lines.text);
  // Этот метод переписывает в TWebBrowser HTML-
  // документ из TMemo
  Document := WebBrowser1.Document as IHtmlDocument2;
  V := VarArrayCreate([0, 0], varVariant);
  V[0] := response;//Memo1.Text;
  Document.Write(PSafeArray(TVarData(v).VArray));

  Document.Close;



end;

procedure TfrmPoster.FormCreate(Sender: TObject);
begin
 WebBrowser1.Navigate('about:blank');
end;

end.
