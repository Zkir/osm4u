object frmLogin: TfrmLogin
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = #1042#1093#1086#1076' '#1074' '#1089#1080#1089#1090#1077#1084#1091
  ClientHeight = 249
  ClientWidth = 323
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 289
    Height = 57
    AutoSize = False
    Caption = 
      #1055#1088#1077#1076#1089#1090#1072#1074#1100#1090#1077#1089#1100' '#1087#1086#1078#1072#1083#1091#1081#1089#1090#1072'. '#1044#1072#1085#1085#1099#1077' '#1074' Osm4u '#1088#1077#1072#1083#1100#1085#1099#1077', '#1080' '#1084#1099' '#1089#1095#1080#1090#1072#1077#1084',' +
      ' '#1095#1090#1086' '#1087#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1080' '#1090#1086#1078#1077' '#1076#1086#1083#1078#1085#1099' '#1073#1099#1090#1100' '#1088#1077#1072#1083#1100#1085#1099#1077'. :) '#1045#1089#1083#1080' '#1091' '#1074#1072#1089' '#1085#1077#1090' '#1077 +
      #1097#1077' '#1091#1095#1077#1090#1085#1086#1081' '#1079#1072#1087#1080#1089#1080', '#1074#1099' '#1084#1086#1078#1077#1090#1077' '#1079#1072#1088#1077#1075#1080#1089#1090#1088#1080#1088#1086#1074#1072#1090#1100#1089#1103'.'
    WordWrap = True
  end
  object edPassword1: TLabeledEdit
    Left = 16
    Top = 133
    Width = 289
    Height = 21
    EditLabel.Width = 37
    EditLabel.Height = 13
    EditLabel.Caption = #1055#1072#1088#1086#1083#1100
    PasswordChar = '*'
    TabOrder = 1
  end
  object edLogin: TLabeledEdit
    Left = 16
    Top = 88
    Width = 289
    Height = 21
    CharCase = ecLowerCase
    EditLabel.Width = 71
    EditLabel.Height = 13
    EditLabel.Caption = #1045#1084#1077#1081#1083' ('#1051#1086#1075#1080#1085')'
    MaxLength = 256
    TabOrder = 0
  end
  object Button1: TButton
    Left = 24
    Top = 208
    Width = 120
    Height = 25
    Caption = #1042#1086#1081#1090#1080
    TabOrder = 2
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 168
    Top = 208
    Width = 120
    Height = 25
    Caption = #1047#1072#1088#1077#1075#1080#1089#1090#1088#1080#1088#1086#1074#1072#1090#1100#1089#1103
    TabOrder = 3
    OnClick = Button2Click
  end
  object chkRememberMe: TCheckBox
    Left = 16
    Top = 160
    Width = 97
    Height = 17
    Caption = #1047#1072#1087#1086#1084#1085#1080#1090#1100' '#1084#1077#1085#1103
    TabOrder = 4
  end
end
