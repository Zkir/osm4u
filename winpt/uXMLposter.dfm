object frmPoster: TfrmPoster
  Left = 0
  Top = 0
  Caption = 'frmPoster'
  ClientHeight = 386
  ClientWidth = 639
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 329
    Top = 0
    Height = 345
    ExplicitLeft = 360
    ExplicitTop = 192
    ExplicitHeight = 100
  end
  object Memo1: TMemo
    Left = 0
    Top = 0
    Width = 329
    Height = 345
    Align = alLeft
    Lines.Strings = (
      'Memo1'
      #1056#1091#1089#1089#1082#1080#1081' '#1090#1077#1082#1089#1090)
    TabOrder = 0
  end
  object Panel1: TPanel
    Left = 0
    Top = 345
    Width = 639
    Height = 41
    Align = alBottom
    TabOrder = 1
    object Button1: TButton
      Left = 280
      Top = 6
      Width = 75
      Height = 25
      Caption = #1054#1090#1087#1088#1072#1074#1080#1090#1100
      TabOrder = 0
      OnClick = Button1Click
    end
  end
  object WebBrowser1: TWebBrowser
    Left = 332
    Top = 0
    Width = 307
    Height = 345
    Align = alClient
    TabOrder = 2
    ExplicitLeft = 392
    ExplicitTop = 128
    ExplicitWidth = 300
    ExplicitHeight = 150
    ControlData = {
      4C000000BB1F0000A82300000000000000000000000000000000000000000000
      000000004C000000000000000000000001000000E0D057007335CF11AE690800
      2B2E126209000000000000004C0000000114020000000000C000000000000046
      8000000000000000000000000000000000000000000000000000000000000000
      00000000000000000100000000000000000000000000000000000000}
  end
end
