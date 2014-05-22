object autoawayFr: TautoawayFr
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
  PixelsPerInch = 96
  TextHeight = 13
  object plBg: TPanel
    Left = 0
    Top = 0
    Width = 420
    Height = 376
    Align = alClient
    BevelOuter = bvNone
    BorderWidth = 6
    TabOrder = 0
    object Label26: TLabel
      Left = 6
      Top = 6
      Width = 294
      Height = 32
      AutoSize = False
      Caption = 
        'If you don'#39't use your mouse and your keyboard for a while, you c' +
        'an ask R&Q to set you as "away".'
      ShowAccelChar = False
      WordWrap = True
    end
    object Label28: TLabel
      Left = 6
      Top = 167
      Width = 73
      Height = 13
      Caption = 'Auto-message:'
    end
    object Label1: TLabel
      Left = 324
      Top = 42
      Width = 37
      Height = 13
      Caption = 'minutes'
    end
    object Label2: TLabel
      Left = 324
      Top = 70
      Width = 37
      Height = 13
      Caption = 'minutes'
    end
    object setawayChk: TCheckBox
      Left = 6
      Top = 42
      Width = 248
      Height = 17
      HelpKeyword = 'autoaway-away'
      Caption = 'Set me away after i'#39'm not using the pc for'
      TabOrder = 0
      OnClick = UpdVis
    end
    object awaySpin: TRnQSpinEdit
      Left = 260
      Top = 39
      Width = 60
      Height = 22
      HelpKeyword = 'autoaway-away-time'
      Decimal = 0
      MaxLength = 4
      MaxValue = 100.000000000000000000
      MinValue = 1.000000000000000000
      TabOrder = 1
      Value = 1.000000000000000000
      AsInteger = 1
    end
    object naSpin: TRnQSpinEdit
      Left = 260
      Top = 67
      Width = 60
      Height = 22
      HelpKeyword = 'autoaway-na-time'
      Decimal = 0
      MaxLength = 4
      MaxValue = 100.000000000000000000
      MinValue = 1.000000000000000000
      TabOrder = 2
      Value = 1.000000000000000000
      AsInteger = 1
    end
    object setnaChk: TCheckBox
      Left = 6
      Top = 67
      Width = 248
      Height = 17
      HelpKeyword = 'autoaway-na'
      Caption = 'Set me N/A after i'#39'm not using the pc for'
      TabOrder = 3
      OnClick = UpdVis
    end
    object exitawayChk: TCheckBox
      Left = 6
      Top = 92
      Width = 408
      Height = 17
      HelpKeyword = 'autoaway-exit'
      Caption = 'Auto-exit from auto-away (when i come back to the pc)'
      TabOrder = 4
    end
    object automsgBox: TMemo
      Left = 6
      Top = 186
      Width = 408
      Height = 120
      TabOrder = 5
    end
    object setnaSSChk: TCheckBox
      Left = 6
      Top = 117
      Width = 408
      Height = 17
      HelpKeyword = 'autoaway-ss'
      Caption = 'Set me N/A when screensaver started'
      TabOrder = 6
    end
    object setNAVolChk: TCheckBox
      Left = 6
      Top = 319
      Width = 408
      Height = 17
      HelpKeyword = 'autoaway-set-vol'
      Caption = 'Set sound volume when auto-status is N/A'
      Enabled = False
      TabOrder = 7
      Visible = False
    end
    object naVolSl: TTrackBar
      Left = 260
      Top = 312
      Width = 140
      Height = 26
      HelpKeyword = 'autoaway-volume'
      Enabled = False
      Max = 100
      Frequency = 5
      Position = 100
      TabOrder = 8
      ThumbLength = 10
      TickMarks = tmBoth
      Visible = False
    end
    object bossnaChk: TCheckBox
      Left = 6
      Top = 142
      Width = 355
      Height = 17
      HelpKeyword = 'autoaway-boss'
      Caption = 'Set me N/A when boss-mode is on'
      TabOrder = 9
    end
  end
end
