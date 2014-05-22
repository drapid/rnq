object changePwdFrm: TchangePwdFrm
  Left = 267
  Top = 169
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Change password'
  ClientHeight = 108
  ClientWidth = 297
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = True
  OnClose = FormClose
  OnPaint = FormPaint
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label2: TLabel
    Left = 75
    Top = 34
    Width = 70
    Height = 13
    Alignment = taRightJustify
    Caption = 'New password'
    Transparent = True
  end
  object Label3: TLabel
    Left = 19
    Top = 57
    Width = 126
    Height = 13
    Alignment = taRightJustify
    Caption = 'Re-type the new password'
    Transparent = True
  end
  object Label1: TLabel
    Left = 63
    Top = 10
    Width = 82
    Height = 13
    Alignment = taRightJustify
    Caption = 'Current password'
    Transparent = True
  end
  object newpwd1Box: TEdit
    Left = 152
    Top = 30
    Width = 137
    Height = 22
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Courier New'
    Font.Style = []
    MaxLength = 16
    ParentFont = False
    PasswordChar = '*'
    TabOrder = 1
  end
  object newpwd2Box: TEdit
    Left = 152
    Top = 53
    Width = 137
    Height = 22
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Courier New'
    Font.Style = []
    MaxLength = 16
    ParentFont = False
    PasswordChar = '*'
    TabOrder = 2
  end
  object oldpwdBox: TEdit
    Left = 152
    Top = 6
    Width = 137
    Height = 22
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Courier New'
    Font.Style = []
    MaxLength = 16
    ParentFont = False
    PasswordChar = '*'
    TabOrder = 0
  end
  object saveBtn: TRnQButton
    Left = 152
    Top = 81
    Width = 137
    Height = 25
    Caption = 'Save new password'
    Default = True
    TabOrder = 3
    OnClick = saveBtnClick
    ImageName = 'save'
  end
end
