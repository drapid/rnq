object RegUserDlg: TRegUserDlg
  Left = 0
  Top = 0
  Caption = 'RegUserDlg'
  ClientHeight = 287
  ClientWidth = 323
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  DesignSize = (
    323
    287)
  PixelsPerInch = 96
  TextHeight = 13
  object FNameEdit: TLabeledEdit
    Left = 96
    Top = 166
    Width = 219
    Height = 21
    Anchors = [akLeft, akRight, akBottom]
    EditLabel.Width = 50
    EditLabel.Height = 13
    EditLabel.Caption = 'First name'
    LabelPosition = lpLeft
    MaxLength = 64
    TabOrder = 0
    ExplicitTop = 8
    ExplicitWidth = 173
  end
  object LNameEdit: TLabeledEdit
    Left = 96
    Top = 206
    Width = 219
    Height = 21
    Anchors = [akLeft, akRight, akBottom]
    EditLabel.Width = 49
    EditLabel.Height = 13
    EditLabel.Caption = 'Last name'
    LabelPosition = lpLeft
    MaxLength = 64
    TabOrder = 1
    ExplicitTop = 48
    ExplicitWidth = 173
  end
  object OkBtn: TRnQButton
    Left = 96
    Top = 246
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Ok'
    Default = True
    ImageName = 'ok'
    ModalResult = 1
    TabOrder = 2
    ExplicitTop = 88
  end
  object TosMemo: TMemo
    Left = 0
    Top = 0
    Width = 323
    Height = 160
    Align = alTop
    Anchors = [akLeft, akTop, akRight, akBottom]
    ReadOnly = True
    TabOrder = 3
    ExplicitWidth = 403
    ExplicitHeight = 197
  end
  object CncBtn: TRnQButton
    Left = 192
    Top = 246
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Cancel = True
    Caption = 'Cancel'
    ImageName = 'cancel'
    ModalResult = 2
    TabOrder = 4
  end
end
