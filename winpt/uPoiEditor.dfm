object frmPoiEditor: TfrmPoiEditor
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'frmPoiEditor'
  ClientHeight = 425
  ClientWidth = 509
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnMouseWheelDown = FormMouseWheelDown
  OnMouseWheelUp = FormMouseWheelUp
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object PageControl1: TPageControl
    Left = 0
    Top = 49
    Width = 509
    Height = 340
    ActivePage = TabSheet1
    Align = alClient
    Style = tsFlatButtons
    TabOrder = 0
    object TabSheet1: TTabSheet
      Caption = #1064#1072#1075' 1'
      TabVisible = False
      object StelMap1: TStelMap
        Left = 0
        Top = 0
        Width = 501
        Height = 330
        Align = alClient
        IncrementalDisplay = True
        Picture.Data = {07544269746D617000000000}
        OnDblClick = StelMap1DblClick
        CachePath = '.\Cache\'
        OnBeginMapLoad = StelMap1BeginMapLoad
        OnEndMapLoad = StelMap1EndMapLoad
        OnMapMouseClick = StelMap1MapMouseClick
        onMapMouseMove = StelMap1MapMouseMove
        proxyport = 0
        ExplicitLeft = 56
        ExplicitTop = 40
        ExplicitWidth = 320
        ExplicitHeight = 160
      end
      object lblLoadMap: TLabel
        Left = 48
        Top = 144
        Width = 418
        Height = 21
        Caption = #1048#1076#1077#1090' '#1079#1072#1075#1088#1091#1079#1082#1072' '#1082#1072#1088#1090#1099'. '#1055#1086#1078#1072#1083#1091#1081#1089#1090#1072', '#1087#1086#1076#1086#1078#1076#1080#1090#1077'.'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clRed
        Font.Height = -17
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentFont = False
        Visible = False
      end
    end
    object TabSheet2: TTabSheet
      Caption = #1064#1072#1075' 2'
      ImageIndex = 1
      TabVisible = False
      object sgExistingPoi: TStringGrid
        Left = 10
        Top = 18
        Width = 488
        Height = 289
        ColCount = 3
        DefaultColWidth = 150
        DrawingStyle = gdsClassic
        FixedCols = 0
        FixedRows = 0
        ScrollBars = ssVertical
        TabOrder = 0
      end
      object cbNoDuplicate: TCheckBox
        Left = 17
        Top = 313
        Width = 312
        Height = 17
        Caption = #1052#1077#1089#1090#1086', '#1082#1086#1090#1086#1088#1086#1077' '#1103' '#1093#1086#1095#1091' '#1076#1086#1073#1072#1074#1080#1090#1100', '#1086#1090#1089#1091#1090#1089#1090#1074#1091#1077#1090' '#1074' '#1089#1087#1080#1089#1082#1077
        TabOrder = 1
      end
    end
    object TabSheet3: TTabSheet
      Caption = #1064#1072#1075' 3'
      ImageIndex = 2
      TabVisible = False
      object Label5: TLabel
        Left = 20
        Top = 46
        Width = 54
        Height = 13
        Alignment = taRightJustify
        Caption = #1050#1072#1090#1077#1075#1086#1088#1080#1103
      end
      object Label6: TLabel
        Left = 24
        Top = 70
        Width = 50
        Height = 13
        Alignment = taRightJustify
        Caption = #1058#1080#1087' '#1084#1077#1089#1090#1072
      end
      object Label1: TLabel
        Left = 312
        Top = 136
        Width = 101
        Height = 13
        Caption = #1053#1072#1087#1088#1080#1084#1077#1088', "'#1052#1086#1089#1082#1074#1072'"'
      end
      object Label2: TLabel
        Left = 312
        Top = 168
        Width = 128
        Height = 13
        Caption = #1053#1072#1087#1088#1080#1084#1077#1088', "'#1091#1083'. '#1055#1091#1096#1082#1080#1085#1072'"'
      end
      object Label3: TLabel
        Left = 312
        Top = 197
        Width = 129
        Height = 13
        Caption = #1053#1072#1087#1088#1080#1084#1077#1088', "11" '#1080#1083#1080' "6 '#1082'3"'
      end
      object edPOIName: TLabeledEdit
        Left = 80
        Top = 16
        Width = 393
        Height = 21
        EditLabel.Width = 51
        EditLabel.Height = 13
        EditLabel.Caption = #1053#1072#1079#1074#1072#1085#1080#1077' '
        LabelPosition = lpLeft
        TabOrder = 0
      end
      object edAddrCountry: TLabeledEdit
        Left = 80
        Top = 113
        Width = 217
        Height = 21
        EditLabel.Width = 37
        EditLabel.Height = 13
        EditLabel.Caption = #1057#1090#1088#1072#1085#1072
        LabelPosition = lpLeft
        TabOrder = 3
      end
      object edAddrCity: TLabeledEdit
        Left = 80
        Top = 140
        Width = 217
        Height = 21
        EditLabel.Width = 31
        EditLabel.Height = 13
        EditLabel.Caption = #1043#1086#1088#1086#1076
        LabelPosition = lpLeft
        TabOrder = 4
      end
      object edAddrStreet: TLabeledEdit
        Left = 80
        Top = 167
        Width = 217
        Height = 21
        EditLabel.Width = 31
        EditLabel.Height = 13
        EditLabel.Caption = #1059#1083#1080#1094#1072
        LabelPosition = lpLeft
        TabOrder = 5
      end
      object cbPoiCategory: TComboBox
        Left = 80
        Top = 43
        Width = 217
        Height = 21
        Style = csDropDownList
        TabOrder = 1
        OnChange = cbPoiCategoryChange
      end
      object cbPoiType: TComboBox
        Left = 80
        Top = 70
        Width = 217
        Height = 21
        Style = csDropDownList
        TabOrder = 2
      end
      object edAddrHouseNumber: TLabeledEdit
        Left = 80
        Top = 194
        Width = 217
        Height = 21
        EditLabel.Width = 59
        EditLabel.Height = 13
        EditLabel.Caption = #1053#1086#1084#1077#1088' '#1076#1086#1084#1072
        LabelPosition = lpLeft
        TabOrder = 6
      end
    end
    object TabSheet4: TTabSheet
      Caption = #1064#1072#1075' 4'
      ImageIndex = 3
      TabVisible = False
      object Label7: TLabel
        Left = 36
        Top = 171
        Width = 38
        Height = 13
        Caption = #1054#1094#1077#1085#1082#1072
      end
      object Label8: TLabel
        Left = 25
        Top = 216
        Width = 49
        Height = 13
        Caption = #1054#1087#1080#1089#1072#1085#1080#1077
      end
      object lblRecomendation: TLabel
        Left = 235
        Top = 171
        Width = 107
        Height = 13
        Caption = #1042#1072#1096#1072' '#1088#1077#1082#1086#1084#1077#1085#1076#1072#1094#1080#1103'?'
        Color = clBackground
        ParentColor = False
      end
      object Label11: TLabel
        Left = 368
        Top = 232
        Width = 37
        Height = 13
        Caption = 'Label11'
      end
      object edPhone: TLabeledEdit
        Left = 80
        Top = 16
        Width = 393
        Height = 21
        EditLabel.Width = 44
        EditLabel.Height = 13
        EditLabel.Caption = #1058#1077#1083#1077#1092#1086#1085
        LabelPosition = lpLeft
        TabOrder = 0
      end
      object edWebsite: TLabeledEdit
        Left = 80
        Top = 43
        Width = 393
        Height = 21
        EditLabel.Width = 25
        EditLabel.Height = 13
        EditLabel.Caption = #1057#1072#1081#1090
        LabelPosition = lpLeft
        TabOrder = 1
      end
      object edOpeningHours: TLabeledEdit
        Left = 80
        Top = 70
        Width = 393
        Height = 21
        EditLabel.Width = 67
        EditLabel.Height = 13
        EditLabel.Caption = #1063#1072#1089#1099' '#1088#1072#1073#1086#1090#1099
        LabelPosition = lpLeft
        TabOrder = 2
      end
      object edAvgBill: TLabeledEdit
        Left = 80
        Top = 97
        Width = 393
        Height = 21
        EditLabel.Width = 70
        EditLabel.Height = 13
        EditLabel.Caption = #1057#1088#1077#1076#1085#1080#1081' '#1089#1095#1077#1090
        LabelPosition = lpLeft
        TabOrder = 3
      end
      object mmDescription: TMemo
        Left = 80
        Top = 213
        Width = 393
        Height = 89
        TabOrder = 4
      end
      object cbRating: TComboBox
        Left = 80
        Top = 168
        Width = 145
        Height = 21
        Style = csDropDownList
        TabOrder = 5
        OnChange = cbRatingChange
        Items.Strings = (
          #1059#1078#1072#1089#1085#1086
          #1055#1083#1086#1093#1086
          #1053#1086#1088#1084#1072#1083#1100#1085#1086
          #1061#1086#1088#1086#1096#1086
          #1054#1090#1083#1080#1095#1085#1086)
      end
      object chbWiFi: TCheckBox
        Left = 80
        Top = 124
        Width = 97
        Height = 17
        Caption = #1045#1089#1090#1100' '#1074#1072#1081#1092#1072#1081
        TabOrder = 6
      end
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 389
    Width = 509
    Height = 36
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    object btnBack: TButton
      Left = 4
      Top = 2
      Width = 97
      Height = 25
      Caption = '<< '#1053#1072#1079#1072#1076
      Enabled = False
      TabOrder = 0
      OnClick = btnBackClick
    end
    object btnNext: TButton
      Left = 420
      Top = 2
      Width = 75
      Height = 25
      Caption = #1044#1072#1083#1077#1077' >>'
      TabOrder = 1
      OnClick = btnNextClick
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 509
    Height = 49
    Align = alTop
    Color = clWindow
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentBackground = False
    ParentFont = False
    TabOrder = 2
    object lblStepHint: TLabel
      Left = 17
      Top = 27
      Width = 212
      Height = 13
      Caption = #1059#1082#1072#1078#1080#1090#1077' '#1084#1077#1089#1090#1086', '#1087#1086#1089#1090#1072#1074#1080#1074' '#1090#1086#1095#1082#1091' '#1085#1072' '#1082#1072#1088#1090#1077
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object lblStepTitle: TLabel
      Left = 4
      Top = 8
      Width = 225
      Height = 13
      Caption = #1064#1072#1075' 1. '#1059#1082#1072#1078#1080#1090#1077', '#1075#1076#1077' '#1085#1072#1093#1086#1076#1080#1090#1089#1103' '#1084#1077#1089#1090#1086
    end
  end
end
