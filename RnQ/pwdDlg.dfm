object msgFrm: TmsgFrm
  Left = 161
  Top = 99
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  ClientHeight = 68
  ClientWidth = 179
  Color = clBtnFace
  CustomTitleBar.Height = 6
  ParentFont = True
  GlassFrame.Enabled = True
  GlassFrame.Left = 6
  GlassFrame.Top = 6
  GlassFrame.Right = 6
  GlassFrame.Bottom = 6
  GlassFrame.SheetOfGlass = True
  OldCreateOrder = True
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnPaint = FormPaint
  OnShow = FormShow
  DesignSize = (
    179
    68)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 21
    Top = 11
    Width = 46
    Height = 13
    Alignment = taRightJustify
    Anchors = [akLeft, akBottom]
    Caption = 'Password'
    Transparent = True
  end
  object KBBtn: TRnQSpeedButton
    Left = 155
    Top = 8
    Width = 23
    Height = 22
    Anchors = [akTop, akRight]
    ImageName = 'key'
    OnClick = KBBtnClick
  end
  object txtBox: TEdit
    Left = 72
    Top = 7
    Width = 81
    Height = 23
    Anchors = [akLeft, akRight, akBottom]
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Courier New'
    Font.Style = []
    ParentFont = False
    PasswordChar = '*'
    TabOrder = 0
    OnKeyPress = txtBoxKeyPress
  end
  object okBtn: TRnQButton
    Left = 49
    Top = 38
    Width = 81
    Height = 25
    Anchors = [akBottom]
    Caption = '&Ok'
    Default = True
    DoubleBuffered = False
    ImageName = 'ok'
    ParentDoubleBuffered = False
    TabOrder = 1
    OnClick = okBtnClick
  end
end
