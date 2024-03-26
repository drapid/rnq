object chatFr: TchatFr
  Left = 0
  Top = 0
  ClientHeight = 420
  ClientWidth = 422
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  TextHeight = 13
  object ChatPrefPages: TPageControl
    AlignWithMargins = True
    Left = 6
    Top = 6
    Width = 410
    Height = 408
    Margins.Left = 6
    Margins.Top = 6
    Margins.Right = 6
    Margins.Bottom = 6
    ActivePage = CommonSheet
    Align = alClient
    TabOrder = 0
    ExplicitWidth = 416
    ExplicitHeight = 417
    object CommonSheet: TTabSheet
      Caption = 'Common'
      DesignSize = (
        402
        380)
      object sendonenterLbl: TLabel
        Left = 36
        Top = 99
        Width = 39
        Height = 13
        Caption = 'Send ...'
      end
      object sendonenterSpin: TRnQSpinButton
        Left = 6
        Top = 95
        Width = 20
        Height = 20
        HelpKeyword = 'send-on-enter'
        TabOrder = 0
        OnDownClick = sendonenterSpinBottomClick
        OnUpClick = sendonenterSpinTopClick
      end
      object singleChk: TCheckBox
        Left = 6
        Top = 28
        Width = 440
        Height = 17
        HelpKeyword = 'single-message-by-default'
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Single-message by default'
        TabOrder = 1
        ExplicitWidth = 452
      end
      object statusontabChk: TCheckBox
        Left = 6
        Top = 50
        Width = 440
        Height = 17
        HelpKeyword = 'show-status-on-tabs'
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Show contact status on tabs'
        TabOrder = 2
        ExplicitWidth = 452
      end
      object cursorbelowChk: TCheckBox
        Left = 6
        Top = 122
        Width = 440
        Height = 17
        HelpKeyword = 'quoting-cursor-below'
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Place cursor below quoted text'
        TabOrder = 3
        ExplicitWidth = 452
      end
      object quoteselectedChk: TCheckBox
        Left = 6
        Top = 145
        Width = 440
        Height = 17
        HelpKeyword = 'quote-selected'
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Quote selected text (if any)'
        TabOrder = 4
        ExplicitWidth = 452
      end
      object chatOnTopChk: TCheckBox
        Left = 6
        Top = 170
        Width = 440
        Height = 17
        HelpKeyword = 'chat-always-on-top'
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Chat window is always on top'
        TabOrder = 5
        ExplicitWidth = 452
      end
      object ChkDefCP: TCheckBox
        Left = 6
        Top = 5
        Width = 440
        Height = 17
        HelpKeyword = 'system-cp-flag'
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Use system default codepage for clipboard'
        TabOrder = 6
        ExplicitWidth = 452
      end
      object PlugPanelChk: TCheckBox
        Left = 6
        Top = 193
        Width = 440
        Height = 17
        HelpKeyword = 'use-plugin-panel'
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Use plugin-panel in center'
        TabOrder = 7
        ExplicitWidth = 452
      end
      object HintsShowChk: TCheckBox
        Left = 6
        Top = 72
        Width = 350
        Height = 17
        HelpKeyword = 'chat-hints-show'
        Caption = 'Show hints on chat tabs'
        TabOrder = 8
      end
      object msgWrapBox: TCheckBox
        Left = 6
        Top = 217
        Width = 350
        Height = 17
        HelpKeyword = 'hist-msg-view-wrap'
        Caption = 'Wrap text in separate preview window'
        TabOrder = 9
      end
      object ClsSndChk: TCheckBox
        Left = 6
        Top = 240
        Width = 371
        Height = 17
        HelpKeyword = 'chat-close-on-send'
        Caption = 'Close on send empty string'
        TabOrder = 10
      end
      object ClsPgOnSnglChk: TCheckBox
        Left = 6
        Top = 261
        Width = 371
        Height = 17
        HelpKeyword = 'chat-close-page-on-single'
        Caption = 'Close page instead of window on single'
        TabOrder = 11
      end
    end
    object TSHistory: TTabSheet
      Caption = 'History'
      ImageIndex = 4
      DesignSize = (
        402
        380)
      object stylecodesChk: TCheckBox
        Left = 6
        Top = 3
        Width = 273
        Height = 17
        HelpKeyword = 'font-style-codes'
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Font style codes'
        TabOrder = 0
        ExplicitWidth = 285
      end
      object autodeselectChk: TCheckBox
        Left = 6
        Top = 47
        Width = 320
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Auto-deselect'
        TabOrder = 1
        ExplicitWidth = 332
      end
      object autocopyChk: TCheckBox
        Left = 6
        Top = 24
        Width = 320
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Auto-copy in clipboard'
        TabOrder = 2
        ExplicitWidth = 332
      end
      object DrawEmojiChk: TCheckBox
        Left = 6
        Top = 91
        Width = 385
        Height = 17
        HelpType = htKeyword
        HelpKeyword = 'hist-emoji-draw'
        Caption = 'Draw Emoji'
        TabOrder = 3
      end
      object SmilesChk: TCheckBox
        Left = 6
        Top = 69
        Width = 332
        Height = 17
        HelpType = htKeyword
        HelpKeyword = 'use-smiles'
        Caption = 'Draw Smiles'
        TabOrder = 4
      end
    end
    object SmileSheet: TTabSheet
      Caption = 'Smiles'
      ImageIndex = 1
      object SmlPnlChk: TCheckBox
        Left = 6
        Top = 6
        Width = 291
        Height = 17
        Caption = 'Animate smiles on panel'
        TabOrder = 0
      end
      object ChkShowSmileCptn: TCheckBox
        Left = 6
        Top = 205
        Width = 350
        Height = 17
        HelpKeyword = 'smiles-captions'
        Caption = 'Show smiles captions in menu'
        TabOrder = 1
      end
      object GroupBox1: TGroupBox
        Left = 6
        Top = 26
        Width = 384
        Height = 173
        Caption = 'Smile-panel with animation'
        TabOrder = 2
        object BtnWidthLabel: TLabel
          Left = 7
          Top = 60
          Width = 28
          Height = 13
          Caption = 'Width'
        end
        object BtnHeightLabel: TLabel
          Left = 7
          Top = 116
          Width = 31
          Height = 13
          Caption = 'Height'
        end
        object SmlUseSizeChk: TCheckBox
          Left = 7
          Top = 37
          Width = 366
          Height = 17
          HelpKeyword = 'smiles-panel-btn-autosize'
          Caption = 'Use selected size of smile buttons'
          TabOrder = 0
          OnClick = SmlUseSizeChkClick
        end
        object SmlGridChk: TCheckBox
          Left = 7
          Top = 14
          Width = 375
          Height = 17
          HelpKeyword = 'smiles-panel-draw-grid'
          Caption = 'Draw grid between smiles'
          TabOrder = 1
        end
        object SmlBtnWidthTrk: TTrackBar
          Left = 2
          Top = 80
          Width = 369
          Height = 33
          HelpKeyword = 'smiles-panel-btn-width'
          Max = 80
          Min = 20
          Position = 20
          PositionToolTip = ptTop
          TabOrder = 2
        end
        object SmlBtnHeightTrk: TTrackBar
          Left = 2
          Top = 135
          Width = 369
          Height = 29
          HelpKeyword = 'smiles-panel-btn-height'
          Max = 80
          Min = 1
          Position = 20
          PositionToolTip = ptTop
          TabOrder = 3
        end
      end
      object SepSmilesChk: TCheckBox
        Left = 6
        Top = 228
        Width = 302
        Height = 17
        Caption = 'Smile must be separated from text'
        TabOrder = 3
        Visible = False
      end
    end
    object TSBtns: TTabSheet
      Caption = 'Buttons'
      ImageIndex = 2
      TabVisible = False
      DesignSize = (
        402
        380)
      object IconsGrp: TGroupBox
        Left = 3
        Top = 3
        Width = 379
        Height = 374
        Anchors = [akLeft, akTop, akRight, akBottom]
        Caption = 'Show buttons'
        TabOrder = 0
        ExplicitWidth = 391
        ExplicitHeight = 383
        DesignSize = (
          379
          374)
        object SpinBtn: TRnQSpinButton
          Left = 266
          Top = 23
          Width = 22
          Height = 25
          TabOrder = 0
          Visible = False
        end
        object BtnsList: TVirtualDrawTree
          Left = 12
          Top = 18
          Width = 248
          Height = 342
          Anchors = [akLeft, akTop, akBottom]
          DefaultNodeHeight = 16
          DragMode = dmAutomatic
          DragOperations = [doMove]
          DragType = dtVCL
          Header.AutoSizeIndex = 0
          Header.DefaultHeight = 17
          Header.Height = 13
          Header.MainColumn = -1
          Header.Options = [hoColumnResize, hoDrag]
          TabOrder = 1
          TreeOptions.MiscOptions = [toAcceptOLEDrop, toCheckSupport, toFullRepaintOnResize, toInitOnSave, toToggleOnDblClick, toWheelPanning, toFullRowDrag]
          TreeOptions.PaintOptions = [toShowButtons, toShowDropmark, toShowTreeLines, toThemeAware, toUseBlendedImages, toUseBlendedSelection]
          TreeOptions.SelectionOptions = [toFullRowSelect]
          Touch.InteractiveGestures = [igPan, igPressAndTap]
          Touch.InteractiveGestureOptions = [igoPanSingleFingerHorizontal, igoPanSingleFingerVertical, igoPanInertia, igoPanGutter, igoParentPassthrough]
          ExplicitHeight = 351
          Columns = <>
        end
      end
    end
    object SpellSheet: TTabSheet
      Caption = 'Spell check'
      ImageIndex = 5
      DesignSize = (
        402
        380)
      object langLbl: TLabel
        Left = 6
        Top = 32
        Width = 82
        Height = 13
        Caption = 'Languages used:'
      end
      object warningLbl: TLabel
        Left = 6
        Top = 204
        Width = 403
        Height = 13
        AutoSize = False
        Caption = 
          'Selecting many languages can add a noticable delay to spell chec' +
          'king.'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clGrayText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object howotLbl: TLabel
        Left = 6
        Top = 256
        Width = 386
        Height = 52
        AutoSize = False
        Caption = 
          'Install language and then download language pack for it. Restart' +
          ' may be required to start using spell checking for newly install' +
          'ed language.'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        WordWrap = True
      end
      object SpellCheckActive: TCheckBox
        Left = 6
        Top = 6
        Width = 391
        Height = 17
        Caption = 'Activate real-time checking'
        TabOrder = 0
      end
      object LangList: TVirtualDrawTree
        Left = 6
        Top = 50
        Width = 312
        Height = 151
        Colors.DropMarkColor = cl3DLight
        Colors.DropTargetColor = cl3DLight
        Colors.DropTargetBorderColor = cl3DLight
        Colors.FocusedSelectionColor = cl3DLight
        Colors.FocusedSelectionBorderColor = cl3DLight
        Colors.SelectionRectangleBlendColor = cl3DLight
        Colors.SelectionRectangleBorderColor = cl3DLight
        Header.AutoSizeIndex = 0
        Header.DefaultHeight = 17
        Header.Height = 13
        Header.MainColumn = -1
        Header.Options = [hoColumnResize, hoDrag]
        TabOrder = 1
        TreeOptions.MiscOptions = [toAcceptOLEDrop, toCheckSupport, toFullRepaintOnResize, toInitOnSave, toToggleOnDblClick, toWheelPanning]
        TreeOptions.PaintOptions = [toHideFocusRect, toShowButtons, toShowDropmark, toShowTreeLines, toThemeAware, toUseBlendedImages, toUseBlendedSelection]
        TreeOptions.SelectionOptions = [toFullRowSelect]
        OnDrawNode = LangListDrawNode
        OnFreeNode = LangListFreeNode
        Touch.InteractiveGestures = [igPan, igPressAndTap]
        Touch.InteractiveGestureOptions = [igoPanSingleFingerHorizontal, igoPanSingleFingerVertical, igoPanInertia, igoPanGutter, igoParentPassthrough]
        Columns = <>
      end
      object refreshBtn: TButton
        Left = 5
        Top = 225
        Width = 153
        Height = 25
        Caption = 'Refresh language list'
        TabOrder = 2
        OnClick = refreshBtnClick
      end
      object manageBtn: TButton
        Left = 166
        Top = 225
        Width = 153
        Height = 25
        Caption = 'Manage languages'
        TabOrder = 3
        OnClick = manageBtnClick
      end
      object GroupBox2: TGroupBox
        Left = 6
        Top = 303
        Width = 302
        Height = 55
        Anchors = [akLeft, akTop, akRight]
        BiDiMode = bdLeftToRight
        Caption = 'Spelling errors highlight style'
        ParentBiDiMode = False
        TabOrder = 4
        ExplicitWidth = 314
        object ColorBtn: TColorPickerButton
          Left = 93
          Top = 22
          Width = 59
          Height = 21
          PopupSpacing = 8
          ShowSystemColors = False
        end
        object underSize: TComboBox
          Left = 9
          Top = 22
          Width = 78
          Height = 21
          Style = csDropDownList
          TabOrder = 0
          Items.Strings = (
            '1x1 px'
            '1x2 px'
            '2x1 px'
            '2x2 px'
            '1 px'
            '2 px')
        end
      end
    end
  end
end
