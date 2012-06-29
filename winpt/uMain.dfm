object frmMain: TfrmMain
  Left = 0
  Top = 0
  Caption = 'Osm4u - '#1089#1087#1088#1072#1074#1086#1095#1085#1080#1082' '#1080' '#1088#1077#1076#1072#1082#1090#1086#1088' '#1087#1086#1080' - '#1087#1088#1086#1090#1086#1090#1080#1087
  ClientHeight = 402
  ClientWidth = 838
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  OnCreate = FormCreate
  OnResize = FormResize
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object StatusBar1: TStatusBar
    Left = 0
    Top = 383
    Width = 838
    Height = 19
    Panels = <
      item
        Width = 150
      end
      item
        Width = 50
      end>
  end
  object tvClassificator: TTreeView
    Left = 0
    Top = 0
    Width = 249
    Height = 383
    Align = alLeft
    Indent = 19
    ReadOnly = True
    TabOrder = 1
    OnDblClick = tvClassificatorDblClick
  end
  object Panel1: TPanel
    Left = 601
    Top = 0
    Width = 237
    Height = 383
    Align = alRight
    TabOrder = 2
    object mapMiniMap: TStelMap
      Left = 6
      Top = 40
      Width = 219
      Height = 200
      Enabled = False
      Picture.Data = {07544269746D617000000000}
      ShowSet = False
      CachePath = '.\Cache\'
      proxyport = 0
    end
    object Label1: TLabel
      Left = 16
      Top = 8
      Width = 32
      Height = 13
      Caption = #1071' '#1090#1091#1090':'
    end
  end
  object dgPoiList: TDrawGrid
    Left = 249
    Top = 0
    Width = 352
    Height = 383
    Align = alClient
    ColCount = 1
    Constraints.MinWidth = 300
    DefaultRowHeight = 80
    FixedCols = 0
    TabOrder = 3
    OnDrawCell = dgPoiListDrawCell
    ColWidths = (
      331)
  end
  object MainMenu1: TMainMenu
    Left = 480
    object N1: TMenuItem
      Caption = #1055#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1100
      object N4: TMenuItem
        Caption = #1047#1072#1088#1077#1075#1080#1089#1090#1088#1080#1088#1086#1074#1072#1090#1100#1089#1103
        OnClick = N4Click
      end
      object N2: TMenuItem
        Caption = #1042#1086#1081#1090#1080
        OnClick = N2Click
      end
      object N3: TMenuItem
        Caption = #1042#1099#1081#1090#1080
        Enabled = False
        OnClick = N3Click
      end
    end
    object N5: TMenuItem
      Caption = #1052#1077#1089#1090#1072
      object N6: TMenuItem
        Caption = #1053#1086#1074#1086#1077' '#1084#1077#1089#1090#1086
        OnClick = N6Click
      end
    end
    object N9: TMenuItem
      Caption = #1056#1072#1079#1085#1086#1077
      object XML1: TMenuItem
        Caption = 'XML-'#1055#1086#1089#1090#1077#1088
        OnClick = XML1Click
      end
    end
    object N7: TMenuItem
      Caption = #1057#1087#1088#1072#1074#1082#1072
      object N8: TMenuItem
        Caption = #1054' '#1087#1088#1086#1075#1088#1072#1084#1084#1077
      end
    end
  end
end
