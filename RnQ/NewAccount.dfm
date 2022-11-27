object NewAccFrm: TNewAccFrm
  Left = 0
  Top = 0
  ActiveControl = AccEdit
  BorderStyle = bsSizeToolWin
  Caption = 'New user'
  ClientHeight = 116
  ClientWidth = 284
  Color = clBtnFace
  Constraints.MinHeight = 142
  Constraints.MinWidth = 292
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  DesignSize = (
    284
    116)
  PixelsPerInch = 96
  TextHeight = 13
  object L1: TLabel
    Left = 8
    Top = 19
    Width = 74
    Height = 13
    Alignment = taRightJustify
    AutoSize = False
    Caption = 'Type'
  end
  object Label1: TLabel
    Left = 8
    Top = 46
    Width = 74
    Height = 13
    Alignment = taRightJustify
    AutoSize = False
    Caption = 'UID'
  end
  object AccCBox: TComboBox
    Left = 88
    Top = 16
    Width = 145
    Height = 21
    Style = csDropDownList
    TabOrder = 0
    OnCloseUp = AccCBoxCloseUp
  end
  object AccEdit: TEdit
    Left = 88
    Top = 43
    Width = 145
    Height = 21
    TabOrder = 1
  end
  object OkBtn: TRnQButton
    Left = 113
    Top = 83
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Ok'
    Default = True
    ImageName = 'ok'
    ModalResult = 1
    TabOrder = 2
    OnClick = OkBtnClick
  end
  object CnclBtn: TRnQButton
    Left = 201
    Top = 83
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Cancel'
    ImageName = 'cancel'
    ModalResult = 2
    TabOrder = 3
  end
end
