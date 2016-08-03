object chatFr: TchatFr
  Left = 0
  Top = 0
  ClientHeight = 397
  ClientWidth = 427
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = True
  PixelsPerInch = 96
  TextHeight = 13
  object ChatPrefPages: TPageControl
    AlignWithMargins = True
    Left = 6
    Top = 6
    Width = 415
    Height = 385
    Margins.Left = 6
    Margins.Top = 6
    Margins.Right = 6
    Margins.Bottom = 6
    ActivePage = CommonSheet
    Align = alClient
    TabOrder = 0
    object CommonSheet: TTabSheet
      Caption = 'Common'
      DesignSize = (
        407
        357)
      object sendonenterLbl: TLabel
        Left = 36
        Top = 132
        Width = 39
        Height = 13
        Caption = 'Send ...'
      end
      object sendonenterSpin: TRnQSpinButton
        Left = 6
        Top = 128
        Width = 20
        Height = 20
        HelpKeyword = 'send-on-enter'
        TabOrder = 0
        OnDownClick = sendonenterSpinBottomClick
        OnUpClick = sendonenterSpinTopClick
      end
      object autocopyChk: TCheckBox
        Left = 6
        Top = 6
        Width = 451
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Auto-copy in clipboard'
        TabOrder = 1
      end
      object autodeselectChk: TCheckBox
        Left = 6
        Top = 51
        Width = 451
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Auto-deselect'
        TabOrder = 2
      end
      object singleChk: TCheckBox
        Left = 6
        Top = 76
        Width = 451
        Height = 17
        HelpKeyword = 'single-message-by-default'
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Single-message by default'
        TabOrder = 3
      end
      object statusontabChk: TCheckBox
        Left = 6
        Top = 101
        Width = 451
        Height = 17
        HelpKeyword = 'show-status-on-tabs'
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Show contact status on tabs'
        TabOrder = 4
      end
      object cursorbelowChk: TCheckBox
        Left = 6
        Top = 155
        Width = 451
        Height = 17
        HelpKeyword = 'quoting-cursor-below'
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Place cursor below quoted text'
        TabOrder = 5
      end
      object quoteselectedChk: TCheckBox
        Left = 6
        Top = 178
        Width = 451
        Height = 17
        HelpKeyword = 'quote-selected'
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Quote selected text (if any)'
        TabOrder = 6
      end
      object stylecodesChk: TCheckBox
        Left = 6
        Top = 201
        Width = 451
        Height = 17
        HelpKeyword = 'font-style-codes'
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Font style codes'
        TabOrder = 7
      end
      object chatOnTopChk: TCheckBox
        Left = 6
        Top = 224
        Width = 451
        Height = 17
        HelpKeyword = 'chat-always-on-top'
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Chat window is always on top'
        TabOrder = 8
      end
      object ChkDefCP: TCheckBox
        Left = 6
        Top = 28
        Width = 451
        Height = 17
        HelpKeyword = 'system-cp-flag'
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Use system default codepage for clipboard'
        TabOrder = 9
      end
      object PlugPanelChk: TCheckBox
        Left = 6
        Top = 247
        Width = 451
        Height = 17
        HelpKeyword = 'use-plugin-panel'
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Use plugin-panel in center'
        TabOrder = 10
      end
      object HintsShowChk: TCheckBox
        Left = 6
        Top = 270
        Width = 350
        Height = 17
        HelpKeyword = 'chat-hints-show'
        Caption = 'Show hints'
        TabOrder = 11
      end
      object msgWrapBox: TCheckBox
        Left = 6
        Top = 293
        Width = 350
        Height = 17
        HelpKeyword = 'hist-msg-view-wrap'
        Caption = 'Show msg in window with wrap'
        TabOrder = 12
      end
      object ClsSndChk: TCheckBox
        Left = 6
        Top = 316
        Width = 371
        Height = 17
        HelpKeyword = 'chat-close-on-send'
        Caption = 'Close on send empty string'
        TabOrder = 13
      end
      object ClsPgOnSnglChk: TCheckBox
        Left = 6
        Top = 337
        Width = 323
        Height = 17
        HelpKeyword = 'chat-close-page-on-single'
        Caption = 'Close page instead of window on single'
        TabOrder = 14
      end
    end
    object SmileSheet: TTabSheet
      Caption = 'Smiles'
      ImageIndex = 1
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
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
        407
        357)
      object IconsGrp: TGroupBox
        Left = 3
        Top = 3
        Width = 390
        Height = 351
        Anchors = [akLeft, akTop, akRight, akBottom]
        Caption = 'Show buttons'
        TabOrder = 0
        DesignSize = (
          390
          351)
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
          Height = 319
          Anchors = [akLeft, akTop, akBottom]
          DefaultNodeHeight = 16
          DragMode = dmAutomatic
          DragOperations = [doMove]
          DragType = dtVCL
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
          TabOrder = 1
          TreeOptions.MiscOptions = [toAcceptOLEDrop, toCheckSupport, toFullRepaintOnResize, toInitOnSave, toToggleOnDblClick, toWheelPanning, toFullRowDrag]
          TreeOptions.PaintOptions = [toShowButtons, toShowDropmark, toShowTreeLines, toThemeAware, toUseBlendedImages, toUseBlendedSelection]
          TreeOptions.SelectionOptions = [toFullRowSelect]
          Columns = <>
        end
      end
    end
  end
end
