object themeditFr: TthemeditFr
  Left = 0
  Top = 0
  ClientHeight = 376
  ClientWidth = 519
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = True
  DesignSize = (
    519
    376)
  PixelsPerInch = 96
  TextHeight = 13
  object sizeLbl: TLabel
    Left = 208
    Top = 208
    Width = 63
    Height = 21
    Alignment = taRightJustify
    AutoSize = False
    Caption = 'Size'
    Layout = tlCenter
    Visible = False
  end
  object Label2: TLabel
    Left = 6
    Top = 6
    Width = 63
    Height = 13
    Caption = 'Theme editor'
  end
  object Label3: TLabel
    Left = 6
    Top = 125
    Width = 49
    Height = 13
    Caption = 'Properties'
  end
  object fontLbl: TLabel
    Left = 6
    Top = 230
    Width = 104
    Height = 13
    Caption = 'This is a font example'
  end
  object ColorBtn: TColorPickerButton
    Left = 6
    Top = 168
    Width = 121
    Height = 30
    Flat = True
    PopupSpacing = 8
    ShowSystemColors = True
    OnChange = ColorBtnChange
  end
  object fnBoxButton: TRnQSpeedButton
    Left = 469
    Top = 175
    Width = 23
    Height = 21
    Anchors = [akTop, akRight]
    ImageName = 'open'
    OnClick = fnBoxButtonClick
    ExplicitLeft = 370
  end
  object FontBoxButton: TRnQSpeedButton
    Left = 166
    Top = 208
    Width = 24
    Height = 22
    ImageName = 'font'
    OnClick = FontBoxButtonClick
  end
  object ImgPBox: TPaintBox
    Left = 8
    Top = 249
    Width = 385
    Height = 97
    OnPaint = ImgPBoxPaint
  end
  object stringBox: TMemo
    Left = 6
    Top = 360
    Width = 487
    Height = 150
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 4
    Visible = False
    ExplicitWidth = 388
  end
  object sizeSpin: TRnQSpinEdit
    Left = 277
    Top = 207
    Width = 60
    Height = 22
    Decimal = 0
    MaxLength = 2
    MaxValue = 100.000000000000000000
    MinValue = 6.000000000000000000
    TabOrder = 3
    Value = 14.000000000000000000
    AsInteger = 14
    Visible = False
    OnChange = fontBox11Change
  end
  object propsBox: TComboBox
    Left = 6
    Top = 141
    Width = 209
    Height = 21
    Style = csDropDownList
    TabOrder = 1
    OnChange = propsBoxChange
    OnClick = propsBoxChange
    OnKeyPress = propsBoxKeyPress
    OnSelect = propsBoxChange
  end
  object textBox: TMemo
    Left = 6
    Top = 24
    Width = 508
    Height = 97
    Anchors = [akLeft, akTop, akRight]
    ScrollBars = ssVertical
    TabOrder = 0
    ExplicitWidth = 409
  end
  object MPlayerBar: TToolBar
    Left = 16
    Top = 464
    Width = 57
    Height = 29
    Align = alCustom
    AutoSize = True
    Caption = 'MPlayerBar'
    TabOrder = 5
    object PlayBtn: TRnQSpeedButton
      Left = 0
      Top = 0
      Width = 23
      Height = 22
      ImageName = 'play'
      OnClick = PlayBtnClick
    end
  end
  object fnBox: TEdit
    Left = 134
    Top = 175
    Width = 336
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 7
    ExplicitWidth = 237
  end
  object FontBox: TEdit
    Left = 6
    Top = 208
    Width = 161
    Height = 21
    ReadOnly = True
    TabOrder = 6
  end
  object addBtn: TRnQButton
    Left = 232
    Top = 138
    Width = 97
    Height = 25
    Caption = 'Add'
    TabOrder = 2
    OnClick = addBtnClick
    ImageName = 'add'
  end
end
