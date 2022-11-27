object logFrm: TlogFrm
  Left = 192
  Top = 103
  Caption = 'Log'
  ClientHeight = 341
  ClientWidth = 602
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 0
    Top = 165
    Width = 602
    Height = 3
    Cursor = crVSplit
    Align = alBottom
    ExplicitTop = 155
  end
  object dumpBox: TMemo
    Left = 0
    Top = 168
    Width = 602
    Height = 173
    Align = alBottom
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Courier New'
    Font.Style = []
    ParentFont = False
    ReadOnly = True
    ScrollBars = ssBoth
    TabOrder = 0
  end
  object menu: TPopupMenu
    Left = 104
    Top = 32
    object CopytoClipboard1: TMenuItem
      Caption = 'Copy to Clipboard'
      OnClick = CopytoClipboard1Click
    end
    object Clear1: TMenuItem
      Caption = 'Clear'
      OnClick = Clear1Click
    end
    object Showevents1: TMenuItem
      AutoCheck = True
      Caption = 'Show events'
      Checked = True
      OnClick = Showevents1Click
    end
    object Showpackets1: TMenuItem
      AutoCheck = True
      Caption = 'Show packets'
      Checked = True
      OnClick = Showpackets1Click
    end
  end
end
