object smsFrm: TsmsFrm
  Left = 335
  Top = 158
  Caption = 'SMS'
  ClientHeight = 285
  ClientWidth = 242
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 5
    Top = 8
    Width = 42
    Height = 13
    Caption = 'message'
  end
  object Label2: TLabel
    Left = 5
    Top = 119
    Width = 94
    Height = 13
    Caption = 'destination numbers'
  end
  object SendBtn: TRnQSpeedButton
    Left = 129
    Top = 256
    Width = 88
    Height = 25
    Caption = '&Send'
    ImageName = 'ok'
    OnClick = SendBtnClick
  end
  object msgBox: TMemo
    Left = 0
    Top = 24
    Width = 233
    Height = 89
    TabOrder = 0
    OnChange = msgBoxChange
  end
  object destBox: TMemo
    Left = 0
    Top = 135
    Width = 233
    Height = 89
    TabOrder = 1
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
    TabOrder = 3
  end
  object delivery_receiptBox: TCheckBox
    Left = 8
    Top = 232
    Width = 177
    Height = 17
    Caption = 'delivery receipt'
    Checked = True
    State = cbChecked
    TabOrder = 2
  end
end
