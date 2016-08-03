object FEmoji: TFEmoji
  Left = 309
  Top = 213
  BiDiMode = bdLeftToRight
  BorderStyle = bsNone
  Caption = 'Stickers'
  ClientHeight = 311
  ClientWidth = 484
  Color = clBtnFace
  DoubleBuffered = True
  Font.Charset = RUSSIAN_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Arial'
  Font.Style = [fsBold]
  FormStyle = fsStayOnTop
  KeyPreview = True
  OldCreateOrder = False
  ParentBiDiMode = False
  Position = poDefault
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  OnPaint = FormPaint
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 16
  object exts: TPanel
    AlignWithMargins = True
    Left = 1
    Top = 1
    Width = 482
    Height = 42
    Margins.Left = 1
    Margins.Top = 1
    Margins.Right = 1
    Margins.Bottom = 0
    Align = alTop
    BevelOuter = bvNone
    Color = 14935011
    Ctl3D = True
    DoubleBuffered = True
    FullRepaint = False
    ParentBackground = False
    ParentCtl3D = False
    ParentDoubleBuffered = False
    TabOrder = 0
  end
  object UpdTmr: TTimer
    Enabled = False
    Interval = 40
    OnTimer = UpdTmrTimer
    Left = 432
    Top = 256
  end
  object actList: TActionList
    Left = 384
    Top = 256
    object NextExt: TAction
      SecondaryShortCuts.Strings = (
        'TAB')
    end
    object PrevExt: TAction
      SecondaryShortCuts.Strings = (
        'Shift+TAB')
    end
  end
end
