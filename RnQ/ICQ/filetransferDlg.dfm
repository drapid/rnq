object filetransferFrm: TfiletransferFrm
  Left = 334
  Top = 134
  Caption = 'File transfer'
  ClientHeight = 300
  ClientWidth = 404
  Color = clBtnFace
  Constraints.MinHeight = 300
  Constraints.MinWidth = 412
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnShow = FormShow
  DesignSize = (
    404
    300)
  PixelsPerInch = 96
  TextHeight = 13
  object PathBtn: TRnQSpeedButton
    Left = 372
    Top = 56
    Width = 24
    Height = 22
    Anchors = [akTop, akRight]
    ImageName = 'open'
    OnClick = PathBtnClick
  end
  object box: TMemo
    Left = 8
    Top = 83
    Width = 388
    Height = 61
    Align = alCustom
    Anchors = [akLeft, akTop, akRight, akBottom]
    ScrollBars = ssBoth
    TabOrder = 4
  end
  object FTProgress: TProgressBar
    Left = 8
    Top = 191
    Width = 388
    Height = 17
    Anchors = [akLeft, akRight, akBottom]
    ParentShowHint = False
    Smooth = True
    Step = 1
    ShowHint = True
    TabOrder = 6
  end
  object FNLEdit: TLabeledEdit
    Left = 72
    Top = 33
    Width = 171
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    EditLabel.Width = 42
    EditLabel.Height = 13
    EditLabel.Caption = 'Filename'
    LabelPosition = lpLeft
    ReadOnly = True
    TabOrder = 1
  end
  object PathLEdit: TLabeledEdit
    Left = 72
    Top = 58
    Width = 294
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    EditLabel.Width = 22
    EditLabel.Height = 13
    EditLabel.Caption = 'Path'
    LabelPosition = lpLeft
    LabelSpacing = 6
    TabOrder = 2
  end
  object SizeLEdit: TLabeledEdit
    Left = 303
    Top = 33
    Width = 93
    Height = 21
    Anchors = [akTop, akRight]
    EditLabel.Width = 20
    EditLabel.Height = 13
    EditLabel.Caption = 'Size'
    LabelPosition = lpLeft
    LabelSpacing = 6
    ReadOnly = True
    TabOrder = 3
  end
  object AcceptBtn: TRnQButton
    Left = 48
    Top = 271
    Width = 86
    Height = 25
    Anchors = [akLeft]
    Caption = 'Accept'
    Default = True
    TabOrder = 9
    OnClick = AcceptBtnClick
    ImageName = 'apply'
  end
  object CloseBtn: TRnQButton
    Left = 151
    Top = 271
    Width = 93
    Height = 25
    Anchors = []
    Cancel = True
    Caption = 'Close'
    TabOrder = 10
    OnClick = CloseBtnClick
    ImageName = 'close'
  end
  object SenderLEdit: TLabeledEdit
    Left = 72
    Top = 8
    Width = 326
    Height = 21
    TabStop = False
    Anchors = [akLeft, akTop, akRight]
    EditLabel.Width = 34
    EditLabel.Height = 13
    EditLabel.Caption = 'Sender'
    LabelPosition = lpLeft
    ReadOnly = True
    TabOrder = 0
  end
  object LocProxyChk: TCheckBox
    Left = 168
    Top = 214
    Width = 198
    Height = 17
    Anchors = [akLeft, akBottom]
    Caption = 'Proxy'
    TabOrder = 8
  end
  object OpenBtn: TRnQButton
    Left = 257
    Top = 271
    Width = 109
    Height = 25
    Anchors = [akRight]
    Caption = 'Open path'
    TabOrder = 11
    OnClick = OpenBtnClick
    ImageName = 'open'
  end
  object SrvChk: TCheckBox
    Left = 8
    Top = 214
    Width = 154
    Height = 17
    Anchors = [akLeft, akBottom]
    Caption = 'Through server'
    TabOrder = 7
    OnClick = SrvChkClick
  end
  object TimePanel: TPanel
    Left = 8
    Top = 148
    Width = 388
    Height = 42
    Anchors = [akLeft, akRight, akBottom]
    BevelOuter = bvLowered
    TabOrder = 5
    DesignSize = (
      388
      42)
    object TimeLEdit: TLabeledEdit
      Left = 8
      Top = 18
      Width = 118
      Height = 21
      TabStop = False
      Color = clBtnFace
      EditLabel.Width = 23
      EditLabel.Height = 13
      EditLabel.Caption = 'Time'
      ReadOnly = True
      TabOrder = 0
    end
    object TimeLeftLEdit: TLabeledEdit
      Left = 264
      Top = 18
      Width = 115
      Height = 21
      TabStop = False
      Anchors = [akTop, akRight]
      BevelInner = bvNone
      BevelOuter = bvNone
      Color = clBtnFace
      EditLabel.Width = 40
      EditLabel.Height = 13
      EditLabel.Caption = 'Time left'
      ReadOnly = True
      TabOrder = 2
    end
    object SpeedLEdit: TLabeledEdit
      Left = 137
      Top = 18
      Width = 121
      Height = 21
      TabStop = False
      Anchors = [akTop]
      Color = clBtnFace
      EditLabel.Width = 31
      EditLabel.Height = 13
      EditLabel.Caption = 'Speed'
      ReadOnly = True
      TabOrder = 1
    end
  end
  object ClsWinChk: TCheckBox
    Left = 8
    Top = 236
    Width = 358
    Height = 17
    Anchors = [akLeft, akBottom]
    Caption = 'Close window after file received'
    TabOrder = 12
    OnClick = ClsWinChkClick
  end
  object T1: TTimer
    Enabled = False
    Interval = 250
    OnTimer = T1Timer
    Left = 360
    Top = 205
  end
end
