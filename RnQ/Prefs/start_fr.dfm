object startFr: TstartFr
  Left = 0
  Top = 0
  VertScrollBar.Tracking = True
  ClientHeight = 382
  ClientWidth = 416
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = True
  PixelsPerInch = 96
  TextHeight = 13
  object Pages: TPageControl
    Left = 6
    Top = 6
    Width = 402
    Height = 368
    ActivePage = MainTab
    Align = alCustom
    Anchors = [akLeft, akTop, akRight, akBottom]
    MultiLine = True
    TabOrder = 0
    TabStop = False
    object MainTab: TTabSheet
      Caption = 'Common'
      DesignSize = (
        394
        340)
      object Label13: TLabel
        Left = 3
        Top = 183
        Width = 93
        Height = 13
        Alignment = taRightJustify
        Caption = 'Auto start with UIN'
      end
      object Label24: TLabel
        Left = 25
        Top = 211
        Width = 71
        Height = 13
        Alignment = taRightJustify
        Caption = 'Starting status'
      end
      object Label25: TLabel
        Left = 18
        Top = 269
        Width = 78
        Height = 13
        Alignment = taRightJustify
        Caption = 'Starting visibility'
      end
      object autoconnectChk: TCheckBox
        Left = 6
        Top = 3
        Width = 369
        Height = 17
        HelpKeyword = 'auto-connect'
        Caption = 'Auto-connect on start'
        TabOrder = 0
      end
      object splashChk: TCheckBox
        Left = 6
        Top = 24
        Width = 369
        Height = 17
        HelpKeyword = 'skip-splash'
        Caption = 'Skip splash screen on startup'
        TabOrder = 1
      end
      object readonlyChk: TCheckBox
        Left = 6
        Top = 45
        Width = 369
        Height = 17
        Caption = 'Check for read-only files at start'
        TabOrder = 2
      end
      object minimizedChk: TCheckBox
        Left = 6
        Top = 66
        Width = 352
        Height = 17
        HelpKeyword = 'start-minimized'
        Caption = 'Start minimized'
        TabOrder = 3
      end
      object lockonstartChk: TCheckBox
        Left = 6
        Top = 87
        Width = 352
        Height = 17
        HelpKeyword = 'lock-on-start'
        Caption = 'Lock on start (hum, to stop your little sister)'
        TabOrder = 4
      end
      object getofflinemsgsChk: TCheckBox
        Left = 6
        Top = 108
        Width = 353
        Height = 17
        Caption = 'Retrieve offline messages on start'
        TabOrder = 5
      end
      object delofflinemsgsChk: TCheckBox
        Left = 6
        Top = 129
        Width = 323
        Height = 17
        Caption = 'Delete offline messages (from server) on start'
        TabOrder = 6
      end
      object reopenchatsChk: TCheckBox
        Left = 6
        Top = 150
        Width = 369
        Height = 17
        HelpKeyword = 'reopen-chats-on-start'
        Caption = 'Reopen open chats on start'
        TabOrder = 7
      end
      object autostart1: TEdit
        Left = 102
        Top = 179
        Width = 160
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        TabOrder = 8
      end
      object startingStatusBox: TComboBox
        Left = 102
        Top = 206
        Width = 257
        Height = 26
        Style = csOwnerDrawVariable
        Anchors = [akLeft, akTop, akRight]
        DropDownCount = 12
        ItemHeight = 20
        TabOrder = 10
        OnDrawItem = startingStatusBoxDrawItem
        OnMeasureItem = startingStatusBoxMeasureItem
      end
      object laststatus1: TCheckBox
        Left = 102
        Top = 234
        Width = 213
        Height = 18
        HelpType = htKeyword
        HelpKeyword = 'use-last-status'
        Caption = 'only for the 1st connection'
        TabOrder = 11
      end
      object startingVisibilityBox: TComboBox
        Left = 102
        Top = 260
        Width = 257
        Height = 26
        Style = csOwnerDrawVariable
        Anchors = [akLeft, akTop, akRight]
        DropDownCount = 12
        ItemHeight = 20
        TabOrder = 12
        OnDrawItem = startingVisibilityBoxDrawItem
        OnMeasureItem = startingVisibilityBoxMeasureItem
      end
      object userspathBox: TLabeledEdit
        Left = 6
        Top = 313
        Width = 364
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        EditLabel.Width = 101
        EditLabel.Height = 13
        EditLabel.Caption = 'Additional users path'
        TabOrder = 13
      end
      object CurUINBtn: TRnQButton
        Left = 268
        Top = 176
        Width = 91
        Height = 25
        Caption = 'current UIN'
        TabOrder = 9
        OnClick = Button1Click
        ImageName = 'uin'
      end
    end
  end
end
