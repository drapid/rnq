object hotkeysFr: ThotkeysFr
  Left = 0
  Top = 0
  VertScrollBar.Tracking = True
  ClientHeight = 376
  ClientWidth = 420
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = True
  OnContextPopup = FrameContextPopup
  DesignSize = (
    420
    376)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 40
    Top = 328
    Width = 368
    Height = 20
    Alignment = taRightJustify
    Anchors = [akTop, akRight]
    AutoSize = False
    Caption = 
      'system-wide hotkeys can be used also when R&Q is in background/h' +
      'idden'
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clRed
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    ShowAccelChar = False
    WordWrap = True
  end
  object Label2: TLabel
    Left = 37
    Top = 217
    Width = 34
    Height = 13
    Alignment = taRightJustify
    Caption = 'Hotkey'
  end
  object Label3: TLabel
    Left = 36
    Top = 265
    Width = 30
    Height = 13
    Alignment = taRightJustify
    Caption = 'Action'
  end
  object Label4: TLabel
    Left = 239
    Top = 347
    Width = 171
    Height = 13
    Alignment = taRightJustify
    Anchors = [akTop, akRight]
    Caption = 'warning: changes can'#39't be canceled'
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clRed
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object hotkey: THotKey
    Left = 79
    Top = 213
    Width = 311
    Height = 22
    Anchors = [akLeft, akTop, akRight]
    InvalidKeys = [hcShift]
    Modifiers = []
    TabOrder = 1
  end
  object swChk: TCheckBox
    Left = 72
    Top = 240
    Width = 121
    Height = 17
    Caption = 'system-wide'
    TabOrder = 2
  end
  object actionBox: TComboBox
    Left = 71
    Top = 262
    Width = 341
    Height = 21
    Style = csDropDownList
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 4
  end
  object winkeyChk: TCheckBox
    Left = 272
    Top = 240
    Width = 119
    Height = 17
    Anchors = [akTop, akRight]
    Caption = 'WIN key'
    TabOrder = 3
  end
  object HKTree: TVirtualDrawTree
    Left = 8
    Top = 8
    Width = 392
    Height = 185
    Header.AutoSizeIndex = 0
    Header.DefaultHeight = 17
    Header.Font.Charset = DEFAULT_CHARSET
    Header.Font.Color = clWindowText
    Header.Font.Height = -11
    Header.Font.Name = 'Tahoma'
    Header.Font.Style = []
    Header.Height = 17
    Header.Options = [hoAutoResize, hoColumnResize, hoDrag, hoVisible]
    TabOrder = 0
    TreeOptions.MiscOptions = [toAcceptOLEDrop, toFullRepaintOnResize, toGridExtensions, toInitOnSave, toToggleOnDblClick, toWheelPanning]
    TreeOptions.PaintOptions = [toShowButtons, toShowDropmark, toShowHorzGridLines, toShowTreeLines, toShowVertGridLines, toThemeAware, toUseBlendedImages, toFullVertGridLines]
    TreeOptions.SelectionOptions = [toFullRowSelect]
    OnChange = HKTreeChange
    OnDrawNode = HKTreeDrawNode
    OnFreeNode = HKTreeFreeNode
    Columns = <
      item
        Position = 0
        Width = 237
        WideText = 'Action'
      end
      item
        MaxWidth = 200
        MinWidth = 90
        Position = 1
        Width = 100
        WideText = 'Hotkey'
      end
      item
        MaxWidth = 60
        MinWidth = 45
        Position = 2
        Width = 55
        WideText = 'SW'
      end>
  end
  object btnDefault: TRnQButton
    Left = 8
    Top = 297
    Width = 81
    Height = 25
    Caption = 'Default'
    TabOrder = 5
    OnClick = btnDefaultClick
    ImageName = 'reset'
  end
  object saveBtn: TRnQButton
    Left = 144
    Top = 289
    Width = 81
    Height = 25
    Caption = 'Save'
    TabOrder = 6
    OnClick = saveBtnClick
    ImageName = 'save'
  end
  object deleteBtn: TRnQButton
    Left = 231
    Top = 289
    Width = 81
    Height = 25
    Caption = 'Delete'
    TabOrder = 7
    OnClick = deleteBtnClick
    ImageName = 'delete'
  end
  object replaceBtn: TRnQButton
    Left = 325
    Top = 289
    Width = 75
    Height = 25
    Caption = 'Replace'
    TabOrder = 8
    OnClick = replaceBtnClick
    ImageName = 'replace'
  end
end
