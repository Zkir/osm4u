object frmNewUser: TfrmNewUser
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'frmNewUser'
  ClientHeight = 435
  ClientWidth = 335
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
    Left = 16
    Top = 264
    Width = 80
    Height = 13
    Caption = #1044#1072#1090#1072' '#1088#1086#1078#1076#1077#1085#1080#1103
  end
  object Label2: TLabel
    Left = 16
    Top = 325
    Width = 19
    Height = 13
    Caption = #1055#1086#1083
  end
  object edLogin: TLabeledEdit
    Left = 16
    Top = 48
    Width = 289
    Height = 21
    CharCase = ecLowerCase
    EditLabel.Width = 71
    EditLabel.Height = 13
    EditLabel.Caption = #1045#1084#1077#1081#1083' ('#1051#1086#1075#1080#1085')'
    MaxLength = 256
    TabOrder = 0
  end
  object edPassword1: TLabeledEdit
    Left = 16
    Top = 96
    Width = 289
    Height = 21
    EditLabel.Width = 37
    EditLabel.Height = 13
    EditLabel.Caption = #1055#1072#1088#1086#1083#1100
    PasswordChar = '*'
    TabOrder = 1
  end
  object edPassword2: TLabeledEdit
    Left = 16
    Top = 136
    Width = 289
    Height = 21
    EditLabel.Width = 81
    EditLabel.Height = 13
    EditLabel.Caption = #1055#1072#1088#1086#1083#1100' '#1077#1097#1077' '#1088#1072#1079
    PasswordChar = '*'
    TabOrder = 2
  end
  object edFirstName: TLabeledEdit
    Left = 16
    Top = 184
    Width = 289
    Height = 21
    EditLabel.Width = 19
    EditLabel.Height = 13
    EditLabel.Caption = #1048#1084#1103
    TabOrder = 3
  end
  object edLastName: TLabeledEdit
    Left = 16
    Top = 232
    Width = 289
    Height = 21
    EditLabel.Width = 44
    EditLabel.Height = 13
    EditLabel.Caption = #1060#1072#1084#1080#1083#1080#1103
    TabOrder = 4
  end
  object edDateOfBirth: TDateTimePicker
    Left = 16
    Top = 280
    Width = 289
    Height = 21
    Date = 2.856498576387821000
    Time = 2.856498576387821000
    TabOrder = 5
  end
  object rbMale: TRadioButton
    Left = 16
    Top = 344
    Width = 80
    Height = 17
    Caption = #1052#1091#1078#1089#1082#1086#1081
    TabOrder = 6
  end
  object rbFemale: TRadioButton
    Left = 102
    Top = 344
    Width = 73
    Height = 17
    Caption = #1046#1077#1085#1089#1082#1080#1081
    TabOrder = 7
  end
  object Button1: TButton
    Left = 80
    Top = 384
    Width = 139
    Height = 25
    Caption = #1047#1072#1088#1077#1075#1080#1089#1090#1088#1080#1088#1086#1074#1072#1090#1100#1089#1103
    TabOrder = 8
    OnClick = Button1Click
  end
end
