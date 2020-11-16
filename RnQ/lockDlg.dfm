object lockFrm: TlockFrm
  Left = 297
  Top = 266
  BorderIcons = [biMinimize]
  BorderStyle = bsSingle
  Caption = 'R&Q LOCKED'
  ClientHeight = 100
  ClientWidth = 414
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = True
  Position = poScreenCenter
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnKeyDown = FormKeyDown
  OnPaint = FormPaint
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 112
    Top = 14
    Width = 197
    Height = 54
    Caption = 
      'This R&&Q has been locked. To unlock you need to type in your pa' +
      'ssword.'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
    WordWrap = True
  end
  object PaintBox1: TPaintBox
    Left = 8
    Top = 8
    Width = 98
    Height = 84
  end
  object pwdBox: TEdit
    Left = 112
    Top = 64
    Width = 129
    Height = 24
    PasswordChar = '*'
    TabOrder = 0
  end
  object OkBtn: TRnQButton
    Left = 250
    Top = 62
    Width = 75
    Height = 25
    Caption = 'Ok'
    Default = True
    ImageName = 'ok'
    TabOrder = 1
    OnClick = OkBtnClick
  end
  object QuitBtn: TRnQButton
    Left = 331
    Top = 62
    Width = 75
    Height = 25
    Caption = 'Quit'
    ImageName = 'quit'
    TabOrder = 2
    OnClick = QuitBtnClick
  end
end
