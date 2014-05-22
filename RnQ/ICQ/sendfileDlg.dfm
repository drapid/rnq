object sendfileFrm: TsendfileFrm
  Left = 223
  Top = 192
  BorderIcons = [biSystemMenu, biMinimize]
  Caption = 'Send file'
  ClientHeight = 279
  ClientWidth = 471
  Color = clBtnFace
  Constraints.MinHeight = 300
  Constraints.MinWidth = 310
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnResize = FormResize
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Spl1: TSplitter
    Left = 317
    Top = 0
    Width = 4
    Height = 279
    Align = alRight
    ExplicitLeft = 392
    ExplicitHeight = 271
  end
  object tree: TVirtualDrawTree
    Left = 321
    Top = 0
    Width = 150
    Height = 279
    Align = alRight
    Header.AutoSizeIndex = 0
    Header.DefaultHeight = 17
    Header.Font.Charset = DEFAULT_CHARSET
    Header.Font.Color = clWindowText
    Header.Font.Height = -11
    Header.Font.Name = 'Tahoma'
    Header.Font.Style = []
    Header.Height = 17
    Header.MainColumn = -1
    Header.Options = [hoColumnResize, hoDrag]
    TabOrder = 0
    OnDrawNode = treeDrawNode
    OnFreeNode = treeFreeNode
    OnGetNodeWidth = treeGetNodeWidth
    Columns = <>
  end
  object P1: TPanel
    Left = 0
    Top = 0
    Width = 317
    Height = 279
    Align = alClient
    TabOrder = 1
    DesignSize = (
      317
      279)
    object Llog: TLabel
      Left = 0
      Top = 41
      Width = 73
      Height = 87
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Log'
      WordWrap = True
    end
    object LPrg: TLabel
      Left = 16
      Top = 183
      Width = 41
      Height = 13
      Anchors = [akLeft, akBottom]
      Caption = 'Progress'
      ExplicitTop = 192
    end
    object LPerc: TLabel
      Left = 295
      Top = 186
      Width = 3
      Height = 13
      Alignment = taRightJustify
      Anchors = [akRight, akBottom]
      ExplicitLeft = 317
      ExplicitTop = 192
    end
    object toBox: TLabeledEdit
      Left = 79
      Top = 2
      Width = 225
      Height = 18
      TabStop = False
      Anchors = [akLeft, akTop, akRight]
      AutoSize = False
      Color = clBtnFace
      EditLabel.Width = 13
      EditLabel.Height = 13
      EditLabel.Caption = 'To'
      LabelPosition = lpLeft
      LabelSpacing = 6
      ReadOnly = True
      TabOrder = 0
    end
    object FilesCnt: TLabeledEdit
      Left = 79
      Top = 22
      Width = 225
      Height = 18
      Anchors = [akLeft, akTop, akRight]
      AutoSize = False
      Color = clBtnFace
      EditLabel.Width = 6
      EditLabel.Height = 13
      EditLabel.Caption = 'F'
      LabelPosition = lpLeft
      LabelSpacing = 6
      ReadOnly = True
      TabOrder = 1
    end
    object msgBox: TMemo
      Left = 79
      Top = 40
      Width = 225
      Height = 70
      Anchors = [akLeft, akTop, akRight, akBottom]
      TabOrder = 2
    end
    object FilePrgrs: TProgressBar
      Left = 16
      Top = 202
      Width = 290
      Height = 17
      Anchors = [akLeft, akRight, akBottom]
      ParentShowHint = False
      Smooth = True
      Step = 1
      ShowHint = True
      TabOrder = 6
    end
    object SrvChk: TCheckBox
      Left = 16
      Top = 116
      Width = 154
      Height = 17
      Anchors = [akLeft, akBottom]
      Caption = 'Through server'
      Checked = True
      State = cbChecked
      TabOrder = 3
      OnClick = SrvChkClick
    end
    object LocProxyChk: TCheckBox
      Left = 176
      Top = 116
      Width = 129
      Height = 17
      Anchors = [akLeft, akBottom]
      Caption = 'Proxy'
      Checked = True
      State = cbChecked
      TabOrder = 4
    end
    object CancelBtn: TRnQButton
      Left = 176
      Top = 246
      Width = 89
      Height = 25
      Anchors = [akLeft, akBottom]
      Cancel = True
      Caption = 'Cancel'
      TabOrder = 8
      OnClick = CancelBtnClick
      ImageName = 'cancel'
    end
    object sBtn: TRnQButton
      Left = 48
      Top = 246
      Width = 89
      Height = 25
      Anchors = [akLeft, akBottom]
      Caption = '&Send'
      Default = True
      TabOrder = 7
      OnClick = sendBtnClick
      ImageName = 'send'
    end
    object TimePanel: TPanel
      Left = 16
      Top = 135
      Width = 288
      Height = 42
      Anchors = [akLeft, akRight, akBottom]
      BevelOuter = bvLowered
      TabOrder = 5
      DesignSize = (
        288
        42)
      object TimeLEdit: TLabeledEdit
        Left = 8
        Top = 18
        Width = 89
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
        Left = 192
        Top = 18
        Width = 90
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
        Left = 98
        Top = 18
        Width = 92
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
      Left = 16
      Top = 224
      Width = 289
      Height = 17
      Anchors = [akLeft, akBottom]
      Caption = 'Close window after file received'
      TabOrder = 9
      OnClick = ClsWinChkClick
    end
  end
  object T1: TTimer
    Enabled = False
    Interval = 250
    OnTimer = T1Timer
    Left = 288
    Top = 240
  end
end
