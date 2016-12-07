object eventsFr: TeventsFr
  Left = 414
  Top = 227
  ClientHeight = 447
  ClientWidth = 470
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = True
  PixelsPerInch = 96
  TextHeight = 13
  object Label3: TLabel
    Left = 422
    Top = 517
    Width = 3
    Height = 13
    Alignment = taRightJustify
    Visible = False
  end
  object s: TPageControl
    AlignWithMargins = True
    Left = 6
    Top = 6
    Width = 458
    Height = 435
    Margins.Left = 6
    Margins.Top = 6
    Margins.Right = 6
    Margins.Bottom = 6
    ActivePage = MainTS
    Align = alClient
    TabOrder = 0
    object MainTS: TTabSheet
      Caption = 'Common'
      DesignSize = (
        450
        407)
      object Label4: TLabel
        Left = 339
        Top = 281
        Width = 39
        Height = 13
        Caption = 'seconds'
        Layout = tlCenter
      end
      object DLLLbl: TLabel
        Left = 184
        Top = 242
        Width = 64
        Height = 13
        Caption = 'Need bass.dll'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clRed
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        Layout = tlCenter
      end
      object VolLbl: TLabel
        Left = 104
        Top = 242
        Width = 74
        Height = 13
        Alignment = taRightJustify
        AutoSize = False
        Caption = 'Volume'
        Color = clBtnFace
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentColor = False
        ParentFont = False
        Transparent = True
      end
      object playSnds: TCheckBox
        Left = 6
        Top = 240
        Width = 111
        Height = 17
        Caption = 'Play sounds'
        TabOrder = 2
        OnClick = UpdVis
      end
      object SndVolSlider: TTrackBar
        Left = 180
        Top = 234
        Width = 140
        Height = 26
        Max = 100
        Frequency = 5
        Position = 100
        TabOrder = 3
        ThumbLength = 10
        TickMarks = tmBoth
      end
      object autoconsumeChk: TCheckBox
        Left = 6
        Top = 299
        Width = 350
        Height = 17
        HelpKeyword = 'auto-consume-events'
        Caption = 'Skip events when you see them'
        TabOrder = 8
      end
      object BringInfoChk: TCheckBox
        Left = 6
        Top = 339
        Width = 350
        Height = 17
        Caption = 'Bring info-window foreground'
        TabOrder = 10
      end
      object focuschatpopupChk: TCheckBox
        Left = 6
        Top = 319
        Width = 350
        Height = 17
        HelpKeyword = 'focus-on-chat-popup'
        Caption = 'Focus on chat window popup'
        TabOrder = 9
      end
      object minOnOffChk: TCheckBox
        Left = 6
        Top = 279
        Width = 327
        Height = 17
        HelpKeyword = 'min-on-off'
        Caption = 'Ignore oncoming/offgoing events if faster than'
        TabOrder = 6
        OnClick = UpdVis
      end
      object oncomingOnAwayChk: TCheckBox
        Left = 6
        Top = 259
        Width = 350
        Height = 17
        HelpKeyword = 'oncoming-on-away'
        Caption = 'Simulate '#39'oncoming'#39' exiting away status'
        TabOrder = 5
      end
      object minOnOffSpin: TRnQSpinEdit
        Left = 275
        Top = 277
        Width = 60
        Height = 22
        HelpKeyword = 'min-on-off-time'
        Ctl3D = True
        Decimal = 0
        MaxLength = 4
        MaxValue = 2000.000000000000000000
        MinValue = 1.000000000000000000
        ParentCtl3D = False
        TabOrder = 7
        Value = 1.000000000000000000
        AsInteger = 1
        OnChange = tipSpinChange
      end
      object TestVolSButton: TRnQButton
        Left = 321
        Top = 236
        Width = 75
        Height = 25
        Caption = 'test it'
        TabOrder = 4
        OnClick = TestVolSButtonClick
        ImageName = 'play'
      end
      object EvntGrp: TGroupBox
        Left = 6
        Top = 3
        Width = 438
        Height = 233
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Events'
        TabOrder = 0
        object Label1: TLabel
          Left = 0
          Top = 27
          Width = 49
          Height = 13
          Alignment = taRightJustify
          AutoSize = False
          Caption = 'Triggers'
          Color = clBtnFace
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentColor = False
          ParentFont = False
          Transparent = True
        end
        object Label5: TLabel
          Left = 70
          Top = 181
          Width = 41
          Height = 13
          Caption = 'Duration'
          Color = clBtnFace
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentColor = False
          ParentFont = False
          Transparent = True
          Layout = tlCenter
        end
        object Label9: TLabel
          Left = 318
          Top = 181
          Width = 39
          Height = 13
          Caption = 'seconds'
          Layout = tlCenter
        end
        object tipSpin: TRnQSpinEdit
          Left = 230
          Top = 176
          Width = 82
          Height = 22
          Ctl3D = True
          Decimal = 1
          MaxLength = 6
          Increment = 0.100000000000000000
          MaxValue = 999999.000000000000000000
          ParentCtl3D = False
          TabOrder = 0
          ValueType = vtFloat
          Value = 1.000000000000000000
          AsInteger = 1
          OnChange = tipSpinChange
        end
        object tiptimesChk: TCheckBox
          Left = 16
          Top = 204
          Width = 208
          Height = 21
          Caption = 'multiplicate for message length plus'
          TabOrder = 1
          OnClick = tiptimesChkClick
        end
        object tipplusSpin: TRnQSpinEdit
          Left = 230
          Top = 204
          Width = 82
          Height = 22
          Ctl3D = True
          Decimal = 1
          MaxLength = 6
          Increment = 0.100000000000000000
          MaxValue = 999999.000000000000000000
          ParentCtl3D = False
          TabOrder = 2
          ValueType = vtFloat
          OnChange = tipplusSpinChange
        end
        object TestEvBtn: TRnQButton
          Left = 327
          Top = 202
          Width = 54
          Height = 25
          Caption = 'test it'
          TabOrder = 3
          OnClick = RnQSpeedButton1Click
        end
        object TrigList: TVirtualDrawTree
          Left = 55
          Top = 25
          Width = 312
          Height = 150
          DefaultNodeHeight = 16
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
          TabOrder = 4
          TreeOptions.MiscOptions = [toAcceptOLEDrop, toCheckSupport, toFullRepaintOnResize, toInitOnSave, toToggleOnDblClick, toWheelPanning]
          TreeOptions.PaintOptions = [toShowButtons, toShowDropmark, toShowTreeLines, toThemeAware, toUseBlendedImages, toUseBlendedSelection]
          TreeOptions.SelectionOptions = [toFullRowSelect]
          OnChecked = TrigListChecked
          OnDrawNode = TrigListDrawNode
          OnFreeNode = TrigListFreeNode
          Columns = <>
        end
      end
      object eventBox: TComboBox
        Left = 52
        Top = 2
        Width = 327
        Height = 26
        Style = csOwnerDrawVariable
        Anchors = [akLeft, akTop, akRight]
        ItemHeight = 20
        TabOrder = 1
        OnDrawItem = eventBoxDrawItem
        OnMeasureItem = eventBoxMeasureItem
        OnSelect = eventBoxSelect
      end
    end
    object DisEvTS: TTabSheet
      Caption = 'Extra disabling'
      ImageIndex = 1
      DesignSize = (
        450
        407)
      object GroupBox1: TGroupBox
        Left = 6
        Top = 3
        Width = 426
        Height = 126
        Anchors = [akLeft, akTop, akRight]
        Caption = 'on status'
        TabOrder = 0
        object Label2: TLabel
          Left = 0
          Top = 32
          Width = 49
          Height = 13
          Alignment = taRightJustify
          AutoSize = False
          Caption = 'disable'
          Color = clBtnFace
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentColor = False
          ParentFont = False
          Transparent = True
        end
        object TipsChk: TCheckBox
          Left = 55
          Top = 31
          Width = 194
          Height = 17
          Caption = 'tips'
          TabOrder = 0
          OnClick = TipsChkClick
        end
        object BlinkChk: TCheckBox
          Left = 55
          Top = 51
          Width = 194
          Height = 17
          Caption = 'blinking'
          TabOrder = 1
          OnClick = TipsChkClick
        end
        object SndChk: TCheckBox
          Left = 55
          Top = 71
          Width = 194
          Height = 17
          Caption = 'sounds'
          TabOrder = 2
          OnClick = TipsChkClick
        end
        object chatChk: TCheckBox
          Left = 55
          Top = 91
          Width = 194
          Height = 17
          Caption = 'open a chat'
          TabOrder = 3
          OnClick = TipsChkClick
        end
      end
      object statusBox: TComboBox
        Left = 61
        Top = 2
        Width = 362
        Height = 26
        Style = csOwnerDrawVariable
        Anchors = [akLeft, akTop, akRight]
        DropDownCount = 10
        ItemHeight = 20
        TabOrder = 1
        OnDrawItem = statusBoxDrawItem
        OnMeasureItem = statusBoxMeasureItem
        OnSelect = statusBoxSelect
      end
      object ClosedGrpChk: TCheckBox
        Left = 8
        Top = 144
        Width = 407
        Height = 17
        HelpKeyword = 'disable-events-on-closed-groups'
        Caption = 'Disable events on close groups'
        TabOrder = 2
      end
    end
    object LogTS: TTabSheet
      Caption = 'Log'
      ImageIndex = 2
      DesignSize = (
        450
        407)
      object PckLogGrp: TGroupBox
        Left = 6
        Top = 6
        Width = 356
        Height = 105
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Log packets'
        TabOrder = 0
        object pktclearChk: TCheckBox
          Left = 14
          Top = 72
          Width = 171
          Height = 17
          Caption = 'Clear on start'
          TabOrder = 0
        end
        object pktfileChk: TCheckBox
          Left = 14
          Top = 49
          Width = 204
          Height = 17
          Caption = 'On file'
          TabOrder = 1
        end
        object pktwndChk: TCheckBox
          Left = 14
          Top = 26
          Width = 204
          Height = 17
          Caption = 'On window'
          TabOrder = 2
        end
      end
      object EvLogGrp: TGroupBox
        Left = 6
        Top = 117
        Width = 356
        Height = 100
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Log events'
        TabOrder = 1
        object evtwndChk: TCheckBox
          Left = 14
          Top = 24
          Width = 196
          Height = 17
          Caption = 'On window'
          TabOrder = 0
        end
        object evtfileChk: TCheckBox
          Left = 14
          Top = 44
          Width = 196
          Height = 17
          Caption = 'On file'
          TabOrder = 1
        end
        object evtclearChk: TCheckBox
          Left = 14
          Top = 64
          Width = 196
          Height = 17
          Caption = 'Clear on start'
          TabOrder = 2
        end
      end
    end
    object BDTS: TTabSheet
      Caption = 'Birthday'
      ImageIndex = 3
      object LDays1: TLabel
        Left = 349
        Top = 24
        Width = 23
        Height = 13
        Caption = 'days'
      end
      object LDays2: TLabel
        Left = 349
        Top = 47
        Width = 23
        Height = 13
        Caption = 'days'
      end
      object BD1Chk: TCheckBox
        Left = 14
        Top = 23
        Width = 267
        Height = 17
        HelpKeyword = 'is-show-bd-first'
        Caption = 'First inform about birthday before'
        TabOrder = 0
        OnClick = UpdVis
      end
      object BD1Spin: TRnQSpinEdit
        Left = 283
        Top = 19
        Width = 60
        Height = 22
        HelpKeyword = 'show-bd-first'
        Ctl3D = True
        Decimal = 0
        MaxLength = 4
        MaxValue = 15.000000000000000000
        MinValue = 1.000000000000000000
        ParentCtl3D = False
        TabOrder = 1
        Value = 1.000000000000000000
        AsInteger = 1
        OnChange = tipSpinChange
      end
      object BD2Chk: TCheckBox
        Left = 14
        Top = 46
        Width = 267
        Height = 17
        HelpKeyword = 'is-show-bd-before'
        Caption = 'Inform about birthday before'
        TabOrder = 2
        OnClick = UpdVis
      end
      object BD2Spin: TRnQSpinEdit
        Left = 283
        Top = 44
        Width = 60
        Height = 22
        HelpKeyword = 'show-bd-before'
        Ctl3D = True
        Decimal = 0
        MaxLength = 4
        MaxValue = 7.000000000000000000
        ParentCtl3D = False
        TabOrder = 3
        Value = 1.000000000000000000
        AsInteger = 1
        OnChange = tipSpinChange
      end
    end
  end
end
