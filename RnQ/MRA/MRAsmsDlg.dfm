object MRAsmsFrm: TMRAsmsFrm
  Left = 335
  Top = 158
  Caption = 'SMS'
  ClientHeight = 285
  ClientWidth = 222
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  DesignSize = (
    222
    285)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 5
    Top = 107
    Width = 42
    Height = 13
    Caption = 'message'
  end
  object SendBtn: TRnQSpeedButton
    Left = 129
    Top = 256
    Width = 83
    Height = 25
    Anchors = [akLeft, akTop, akRight]
    Caption = '&Send'
    ImageName = 'ok'
    OnClick = SendBtnClick
    ExplicitWidth = 88
  end
  object RnQSpeedButton1: TRnQSpeedButton
    Left = 191
    Top = 8
    Width = 23
    Height = 22
    Anchors = [akTop, akRight]
    ExplicitLeft = 207
  end
  object msgBox: TMemo
    Left = 0
    Top = 123
    Width = 217
    Height = 89
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 0
    OnChange = msgBoxChange
    ExplicitWidth = 233
  end
  object charsBox: TLabeledEdit
    Left = 57
    Top = 258
    Width = 49
    Height = 21
    EditLabel.Width = 27
    EditLabel.Height = 13
    EditLabel.Caption = 'Chars'
    LabelPosition = lpLeft
    TabOrder = 2
  end
  object delivery_receiptBox: TCheckBox
    Left = 8
    Top = 232
    Width = 177
    Height = 17
    Caption = 'delivery receipt'
    Checked = True
    State = cbChecked
    TabOrder = 1
  end
  object PhoneBox: TComboBox
    Left = 8
    Top = 8
    Width = 177
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    ItemHeight = 13
    TabOrder = 3
    Text = '+7'
    ExplicitWidth = 193
  end
end
