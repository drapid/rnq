object updateFr: TupdateFr
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
  object updateGrp: TGroupBox
    Left = 6
    Top = 10
    Width = 378
    Height = 97
    Anchors = [akLeft, akTop, akRight]
    Caption = 'updateGrp'
    TabOrder = 1
    object Label1: TLabel
      Left = 182
      Top = 26
      Width = 27
      Height = 13
      Caption = 'hours'
    end
    object Label2: TLabel
      Left = 59
      Top = 27
      Width = 60
      Height = 13
      Alignment = taRightJustify
      Caption = 'Check every'
    end
    object checkSpin: TRnQSpinEdit
      Left = 124
      Top = 23
      Width = 53
      Height = 22
      HelpKeyword = 'auto-check-every'
      Decimal = 0
      MaxLength = 4
      MaxValue = 9999.000000000000000000
      MinValue = 1.000000000000000000
      TabOrder = 0
      Value = 1.000000000000000000
      AsInteger = 1
    end
    object LoginUpdChk: TCheckBox
      Left = 14
      Top = 51
      Width = 307
      Height = 17
      Caption = 'Check every login'
      Checked = True
      Enabled = False
      State = cbChecked
      TabOrder = 1
      Visible = False
    end
  end
  object updateChk: TCheckBox
    Left = 6
    Top = 6
    Width = 169
    Height = 17
    HelpKeyword = 'auto-check-update'
    Caption = 'Auto-check for new versions'
    TabOrder = 0
    OnClick = updateChkClick
  end
  object betaChk: TCheckBox
    Left = 6
    Top = 113
    Width = 355
    Height = 17
    HelpKeyword = 'check-betas'
    Caption = 'Check updates for beta-testers'
    TabOrder = 2
  end
end
