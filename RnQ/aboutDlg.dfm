object aboutFrm: TaboutFrm
  Left = 197
  Top = 152
  ActiveControl = OkBtn
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsToolWindow
  Caption = 'About'
  ClientHeight = 222
  ClientWidth = 300
  Color = clBtnFace
  ParentFont = True
  GlassFrame.Enabled = True
  GlassFrame.Bottom = 40
  OldCreateOrder = True
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnKeyPress = FormKeyPress
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object versionLbl: TLabel
    Left = 16
    Top = 45
    Width = 185
    Height = 37
    AutoSize = False
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Times New Roman'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object Lbl: TLabel
    Left = 12
    Top = 8
    Width = 7
    Height = 33
    Hint = 'http://RnQ.ru'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clRed
    Font.Height = -29
    Font.Name = 'Times New Roman'
    Font.Style = []
    ParentFont = False
    ParentShowHint = False
    ShowAccelChar = False
    ShowHint = True
  end
  object MThanks: TMemo
    AlignWithMargins = True
    Left = 10
    Top = 25
    Width = 287
    Height = 36
    Margins.Left = 10
    TabStop = False
    Align = alBottom
    BevelInner = bvLowered
    BevelKind = bkFlat
    BevelOuter = bvNone
    BorderStyle = bsNone
    Color = clBtnFace
    Lines.Strings = (
      'Thanks to:'
      '- Rejetto for &RQ'
      '- Mikanoshi'
      '- Embarcadero for Delphi 10!'
      ''
      'Thanks for help to:'
      '- MadNut, ZlydenGL, ego1st, Sax-mmS, Djumon'
      '- DJ Ference, Vit@l, Mika'#39'el, OverQuantum'
      '- bass, Vaz, TiMeTraSheR, d0cent, dek'
      ''
      'Thanks for donates to:'
      '- Kantah'
      ''
      'Libs used'
      '- Internet Component Suite, by Fran'#231'ois Piette'
      '- VirtualTreeview, ColorPickerButton, by Mike Lischke'
      '- Bass, by Ian Luck'
      '- SciZipFile, by Patrik Spanel'
      '- AES, by Wolfgang Ehrhardt')
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 0
    Visible = False
  end
  object AbPnl: TPanel
    Left = 0
    Top = 64
    Width = 300
    Height = 120
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    object forumLbl: TLabel
      Left = 12
      Top = 79
      Width = 204
      Height = 13
      Cursor = crHandPoint
      Hint = 'http://RnQ.ru'
      Caption = 'Use the forum for support or to contact us'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlue
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      ShowAccelChar = False
      Transparent = True
      OnClick = forumLblClick
      OnMouseEnter = lblMouseEnter
      OnMouseLeave = lblMouseLeave
    end
    object L5: TLabel
      Left = 12
      Top = 53
      Width = 74
      Height = 13
      Caption = #169'2005'#8212'2016'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -9
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object L3: TLabel
      Left = 12
      Top = 37
      Width = 74
      Height = 13
      Caption = #169'2004'#8212'2005'
      Font.Charset = ANSI_CHARSET
      Font.Color = clGray
      Font.Height = -9
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object RDLbl: TLabel
      Left = 90
      Top = 37
      Width = 47
      Height = 13
      Cursor = crHandPoint
      Hint = 'Send e-mail'
      Caption = 'Rapid D'
      Font.Charset = ANSI_CHARSET
      Font.Color = clGray
      Font.Height = -9
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      Transparent = True
      OnClick = RDLblClick
      OnMouseEnter = lblMouseEnter
      OnMouseLeave = lblMouseLeave
    end
    object L6: TLabel
      Left = 90
      Top = 53
      Width = 61
      Height = 13
      Cursor = crHandPoint
      Hint = 'Send e-mail'
      Caption = 'R&Q Team'
      Font.Charset = ANSI_CHARSET
      Font.Color = clBlack
      Font.Height = -9
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      ParentShowHint = False
      ShowAccelChar = False
      ShowHint = True
      Transparent = True
      OnClick = L6Click
      OnMouseEnter = lblMouseEnter
      OnMouseLeave = lblMouseLeave
    end
    object L2: TLabel
      Left = 90
      Top = 21
      Width = 90
      Height = 13
      Cursor = crHandPoint
      Caption = 'Massimo Melina'
      Font.Charset = ANSI_CHARSET
      Font.Color = clGray
      Font.Height = -9
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      Transparent = True
    end
    object L1: TLabel
      Left = 12
      Top = 21
      Width = 74
      Height = 13
      Caption = #169'2001'#8212'2003'
      Font.Charset = ANSI_CHARSET
      Font.Color = clGray
      Font.Height = -9
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object BuiltLbl: TLabel
      Left = 12
      Top = 103
      Width = 20
      Height = 13
      Caption = 'Built'
    end
  end
  object BtnPnl: TPanel
    Left = 0
    Top = 184
    Width = 300
    Height = 38
    Align = alBottom
    BevelEdges = [beTop]
    TabOrder = 2
    object CrdBtn: TRnQButton
      Left = 16
      Top = 7
      Width = 100
      Height = 25
      Caption = 'Credits >'
      TabOrder = 0
      OnClick = CrdBtnClick
    end
    object OkBtn: TRnQButton
      Left = 201
      Top = 7
      Width = 83
      Height = 25
      Align = alCustom
      Anchors = [akTop, akRight]
      Cancel = True
      Caption = 'OK'
      Default = True
      ModalResult = 1
      TabOrder = 1
      OnClick = OkBtnClick
    end
  end
end
