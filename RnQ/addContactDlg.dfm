object addContactFrm: TaddContactFrm
  Left = 277
  Top = 192
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Add contact'
  ClientHeight = 90
  ClientWidth = 269
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = True
  Position = poDefault
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnPaint = FormPaint
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 39
    Width = 181
    Height = 13
    Caption = 'Type the UIN number you want to add'
    Transparent = True
  end
  object uinBox: TLabeledEdit
    Left = 45
    Top = 62
    Width = 113
    Height = 21
    EditLabel.Width = 19
    EditLabel.Height = 13
    EditLabel.Caption = 'UIN'
    EditLabel.Transparent = True
    LabelPosition = lpLeft
    TabOrder = 0
    OnChange = uinBoxChange
    OnKeyPress = uinboxKeyPress
  end
  object addBtn: TRnQButton
    Left = 164
    Top = 60
    Width = 94
    Height = 25
    Caption = 'Add'
    Default = True
    ImageName = 'add.contact'
    TabOrder = 1
    OnClick = addBtnClick
  end
  object LocalChk: TCheckBox
    Left = 8
    Top = 8
    Width = 241
    Height = 17
    Caption = 'Locally'
    Checked = True
    State = cbChecked
    TabOrder = 2
  end
end
