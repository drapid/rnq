object newaccountFrm: TnewaccountFrm
  Left = 103
  Top = 150
  Anchors = [akTop, akRight]
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'New account'
  ClientHeight = 264
  ClientWidth = 273
  Color = clBtnFace
  Constraints.MinWidth = 270
  Font.Charset = RUSSIAN_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = True
  OnClose = FormClose
  OnCreate = FormCreate
  OnPaint = FormPaint
  OnShow = FormShow
  DesignSize = (
    273
    264)
  PixelsPerInch = 96
  TextHeight = 13
  object L2: TLabel
    Left = 11
    Top = 45
    Width = 88
    Height = 13
    Alignment = taRightJustify
    Caption = 'Enter a password:'
    Transparent = True
  end
  object btnGetPicture: TRnQSpeedButton
    Left = 8
    Top = 234
    Width = 128
    Height = 25
    Caption = 'Get Picture'
    ImageName = 'ok'
    OnClick = btnGetPictureClick
  end
  object RnQSpeedButton1: TRnQSpeedButton
    Left = 147
    Top = 9
    Width = 120
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Change'
    ImageName = 'preferences'
    OnClick = RnQSpeedButton1Click
    ExplicitLeft = 130
  end
  object L3: TLabel
    Left = 11
    Top = 181
    Width = 66
    Height = 13
    Caption = 'Enter a word:'
    Transparent = True
  end
  object okBtn: TRnQSpeedButton
    Left = 142
    Top = 234
    Width = 127
    Height = 25
    Anchors = [akTop, akRight]
    Caption = '&Register UIN'
    Enabled = False
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    ImageName = 'ok'
    OnClick = okBtnClick
    ExplicitLeft = 143
  end
  object L1: TLabel
    Left = 42
    Top = 15
    Width = 99
    Height = 13
    Alignment = taRightJustify
    Anchors = [akTop, akRight]
    Caption = 'Connection settings:'
    Transparent = True
    ExplicitLeft = 25
  end
  object pBox2: TEdit
    Left = 108
    Top = 42
    Width = 156
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 0
    OnChange = pBox2Change
  end
  object edWord: TEdit
    Left = 108
    Top = 178
    Width = 156
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    CharCase = ecUpperCase
    Enabled = False
    TabOrder = 1
    OnChange = edWordChange
  end
  object logBox: TEdit
    Left = 8
    Top = 205
    Width = 257
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    CharCase = ecUpperCase
    Enabled = False
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clGreen
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 2
    OnChange = edWordChange
  end
  object pl: TPanel
    Left = 6
    Top = 71
    Width = 259
    Height = 102
    Anchors = [akLeft, akTop, akRight]
    BevelKind = bkFlat
    BevelOuter = bvNone
    Caption = 'No picture'
    TabOrder = 3
    object PBox: TPaintBox
      Left = 0
      Top = 0
      Width = 255
      Height = 98
      Align = alClient
      OnPaint = PBoxPaint
      ExplicitLeft = 36
      ExplicitTop = -4
      ExplicitWidth = 105
      ExplicitHeight = 105
    end
  end
end
