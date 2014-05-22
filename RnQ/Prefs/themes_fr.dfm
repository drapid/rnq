object themesFr: TthemesFr
  Left = 0
  Top = 0
  ClientHeight = 376
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
    376)
  PixelsPerInch = 96
  TextHeight = 13
  object logoImg: TImage
    Left = 16
    Top = 171
    Width = 374
    Height = 198
    Anchors = [akLeft, akTop, akRight, akBottom]
    Transparent = True
  end
  object refreshBtn: TRnQSpeedButton
    Left = 275
    Top = 14
    Width = 115
    Height = 26
    Anchors = [akTop, akRight]
    Caption = 'Refresh'
    ImageName = 'refresh'
    OnClick = refreshBtnClick
  end
  object themeBox: TComboBox
    Left = 16
    Top = 17
    Width = 247
    Height = 21
    Style = csDropDownList
    Anchors = [akLeft, akTop, akRight]
    ItemHeight = 13
    TabOrder = 0
    OnSelect = themeBoxSelect
  end
  object descBox: TMemo
    Left = 16
    Top = 52
    Width = 376
    Height = 105
    Anchors = [akLeft, akTop, akRight]
    ReadOnly = True
    TabOrder = 1
  end
end
