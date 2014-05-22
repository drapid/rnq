object TipsFr: TTipsFr
  Left = 0
  Top = 0
  ClientHeight = 364
  ClientWidth = 420
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = True
  DesignSize = (
    420
    364)
  PixelsPerInch = 96
  TextHeight = 13
  object Label4: TLabel
    Left = 85
    Top = 10
    Width = 83
    Height = 13
    Caption = 'Max count of tips'
  end
  object Label7: TLabel
    Left = 85
    Top = 42
    Width = 128
    Height = 13
    Caption = 'Space between tips, pixels'
  end
  object DisLbl: TLabel
    Left = 317
    Top = 26
    Width = 75
    Height = 16
    Alignment = taRightJustify
    Caption = 'Tips disabled'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clRed
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    Visible = False
  end
  object TipsMaxCntSpin: TRnQSpinEdit
    Left = 6
    Top = 6
    Width = 73
    Height = 22
    HelpKeyword = 'show-tips-count'
    Decimal = 0
    MaxValue = 30.000000000000000000
    TabOrder = 0
    Value = 20.000000000000000000
    AsInteger = 20
    OnChange = TipsMaxCntSpinChange
  end
  object TipsSpaceSpn: TRnQSpinEdit
    Left = 6
    Top = 39
    Width = 73
    Height = 22
    HelpKeyword = 'show-tips-btw-space'
    Decimal = 0
    MaxValue = 30.000000000000000000
    TabOrder = 1
    Value = 2.000000000000000000
    AsInteger = 2
  end
  object TranspTrayGroup: TGroupBox
    Left = 6
    Top = 67
    Width = 394
    Height = 78
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 2
    DesignSize = (
      394
      78)
    object Label3: TLabel
      Left = 93
      Top = 43
      Width = 35
      Height = 13
      Alignment = taRightJustify
      Caption = 'opacity'
    end
    object Label5: TLabel
      Left = 146
      Top = 22
      Width = 16
      Height = 13
      Caption = 'Min'
    end
    object Label6: TLabel
      Left = 358
      Top = 22
      Width = 20
      Height = 13
      Alignment = taRightJustify
      Anchors = [akTop, akRight]
      Caption = 'Max'
    end
    object traytranspChk: TCheckBox
      Left = 15
      Top = 6
      Width = 298
      Height = 18
      HelpKeyword = 'transparency-tray'
      Caption = 'Transparency (works only with Windows XP/2000)'
      TabOrder = 0
    end
    object transpTray: TTrackBar
      Left = 134
      Top = 41
      Width = 252
      Height = 28
      HelpKeyword = 'transparency-vtray'
      Anchors = [akLeft, akTop, akRight]
      Max = 255
      TabOrder = 1
      TickStyle = tsManual
    end
  end
  object PosGrp: TRadioGroup
    Left = 6
    Top = 151
    Width = 187
    Height = 114
    HelpKeyword = 'show-tips-align'
    Caption = 'Corner'
    Items.Strings = (
      'Bottom Right'
      'Bottom Left'
      'Top Left'
      'Top Right')
    TabOrder = 3
  end
  object IndGrp: TGroupBox
    Left = 208
    Top = 151
    Width = 192
    Height = 114
    Caption = 'Indent'
    TabOrder = 4
    object Label1: TLabel
      Left = 16
      Top = 13
      Width = 48
      Height = 13
      Caption = 'Horizontal'
    end
    object Label2: TLabel
      Left = 16
      Top = 61
      Width = 35
      Height = 13
      Caption = 'Vertical'
    end
    object HorIndSpn: TRnQSpinEdit
      Left = 16
      Top = 32
      Width = 81
      Height = 22
      HelpKeyword = 'show-tips-hor-indent'
      Decimal = 0
      TabOrder = 0
    end
    object VerIndSpn: TRnQSpinEdit
      Left = 16
      Top = 80
      Width = 81
      Height = 22
      HelpKeyword = 'show-tips-ver-indent'
      Decimal = 0
      TabOrder = 1
    end
  end
  object RnQButton1: TRnQButton
    Left = 8
    Top = 271
    Width = 54
    Height = 25
    Caption = 'test it'
    TabOrder = 5
    OnClick = RnQButton1Click
  end
end
