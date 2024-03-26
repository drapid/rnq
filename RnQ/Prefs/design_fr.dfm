object designFr: TdesignFr
  Left = 0
  Top = 0
  VertScrollBar.Tracking = True
  ClientHeight = 403
  ClientWidth = 414
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  TextHeight = 13
  object plBg: TPanel
    Left = 0
    Top = 0
    Width = 414
    Height = 403
    Align = alClient
    BevelOuter = bvNone
    BorderWidth = 6
    TabOrder = 0
    ExplicitWidth = 420
    ExplicitHeight = 412
    object PageCtrl: TPageControl
      Left = 6
      Top = 6
      Width = 408
      Height = 400
      ActivePage = CommonTab
      Align = alClient
      TabOrder = 0
      object CommonTab: TTabSheet
        Caption = 'Common'
        DesignSize = (
          394
          363)
        object Label3: TLabel
          Left = 297
          Top = 190
          Width = 62
          Height = 13
          Caption = 'experimental'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clRed
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
        object LangLbl: TLabel
          Left = 6
          Top = 324
          Width = 94
          Height = 13
          Caption = 'Prefered CodePage'
          Visible = False
        end
        object textureChk: TCheckBox
          Left = 6
          Top = 29
          Width = 350
          Height = 17
          Caption = 'Texturized windows'
          TabOrder = 0
        end
        object GrBox2: TGroupBox
          Left = 6
          Top = 213
          Width = 288
          Height = 59
          Caption = 'Icon blink speed'
          TabOrder = 7
          object Label20: TLabel
            Left = 205
            Top = 13
            Width = 35
            Height = 11
            Alignment = taCenter
            Caption = 'Example'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -9
            Font.Name = 'Small Fonts'
            Font.Style = []
            ParentFont = False
          end
          object Label22: TLabel
            Left = 152
            Top = 42
            Width = 20
            Height = 11
            Alignment = taRightJustify
            Caption = 'Slow'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -9
            Font.Name = 'Small Fonts'
            Font.Style = []
            ParentFont = False
          end
          object Label21: TLabel
            Left = 9
            Top = 43
            Width = 19
            Height = 11
            Caption = 'Fast'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -9
            Font.Name = 'Small Fonts'
            Font.Style = []
            ParentFont = False
          end
          object BlinkPBox: TPaintBox
            Left = 207
            Top = 25
            Width = 40
            Height = 31
            OnPaint = BlinkPBoxPaint
          end
          object blinkSlider: TTrackBar
            Left = 4
            Top = 16
            Width = 174
            Height = 25
            Max = 15
            Min = 1
            Position = 1
            TabOrder = 0
          end
        end
        object ChkMenuHeight: TCheckBox
          Left = 6
          Top = 75
          Width = 350
          Height = 17
          Caption = 'Permanent menu height'
          TabOrder = 1
        end
        object ShXstInMnuChk: TCheckBox
          Left = 6
          Top = 98
          Width = 338
          Height = 17
          Anchors = [akLeft, akTop, akRight]
          Caption = 'Show XStatus buttons in menus'
          TabOrder = 2
          ExplicitWidth = 350
        end
        object BlnsShowChk: TCheckBox
          Left = 6
          Top = 167
          Width = 338
          Height = 17
          Anchors = [akLeft, akTop, akRight]
          Caption = 'Show balloons tips in tray (Win2K+)'
          TabOrder = 5
          ExplicitWidth = 350
        end
        object ChkExtStsMainMenu: TCheckBox
          Left = 6
          Top = 121
          Width = 350
          Height = 17
          HelpKeyword = 'xstatus-as-main'
          Caption = 'Show XStatus as main status'
          TabOrder = 3
        end
        object BlinkStsChk: TCheckBox
          Left = 6
          Top = 278
          Width = 339
          Height = 17
          Caption = 'Blink with status'
          TabOrder = 8
        end
        object SingleClickChk: TCheckBox
          Left = 6
          Top = 144
          Width = 375
          Height = 17
          HelpKeyword = 'use-single-click-tray'
          Caption = 'Use single click in tray'
          TabOrder = 4
        end
        object Dock2ChatChk: TCheckBox
          Left = 6
          Top = 190
          Width = 287
          Height = 17
          Caption = 'Docking contact list to chat'
          TabOrder = 6
        end
        object UINDelimChk: TCheckBox
          Left = 6
          Top = 52
          Width = 353
          Height = 17
          HelpKeyword = 'show-uin-delimiter'
          Caption = 'Show UIN-delimiter'
          TabOrder = 9
        end
        object CntThmChk: TCheckBox
          Left = 6
          Top = 301
          Width = 310
          Height = 17
          Caption = 'Use theme per contacts'
          TabOrder = 10
        end
        object ontop1: TCheckBox
          Left = 6
          Top = 6
          Width = 350
          Height = 17
          HelpKeyword = 'always-on-top'
          Caption = 'Contact list is always on top'
          TabOrder = 11
        end
        object LangCBox: TComboBox
          Left = 147
          Top = 321
          Width = 214
          Height = 22
          Style = csOwnerDrawVariable
          ItemIndex = 0
          TabOrder = 12
          Text = 'System'
          Visible = False
          Items.Strings = (
            'System'
            '1251')
        end
      end
      object RstrSheet: TTabSheet
        Caption = 'Roaster'
        ImageIndex = 3
        DesignSize = (
          394
          363)
        object indentChk: TCheckBox
          Left = 6
          Top = 261
          Width = 375
          Height = 17
          Caption = 'Indent contacts in groups'
          TabOrder = 3
        end
        object sortbyGrp: TRadioGroup
          Left = 6
          Top = 6
          Width = 363
          Height = 61
          Anchors = [akLeft, akTop, akRight]
          Caption = 'Sort contacts'
          Columns = 2
          Items.Strings = (
            'none'
            'alphabetic'
            'by last event time'
            'by status')
          TabOrder = 0
          ExplicitWidth = 375
        end
        object EyeLevChk: TCheckBox
          Left = 6
          Top = 242
          Width = 365
          Height = 17
          Caption = 'Leveling contacts'
          TabOrder = 2
        end
        object IconsGrp: TGroupBox
          Left = 6
          Top = 69
          Width = 375
          Height = 170
          Caption = 'Show icons'
          TabOrder = 1
          object RnQSpinButton1: TRnQSpinButton
            Left = 266
            Top = 23
            Width = 22
            Height = 25
            TabOrder = 0
            Visible = False
          end
          object IconsList: TVirtualDrawTree
            Left = 12
            Top = 18
            Width = 248
            Height = 149
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
            OnDragOver = IconsListDragOver
            OnDragDrop = IconsListDragDrop
            OnDrawNode = IconsListDrawNode
            OnFreeNode = IconsListFreeNode
            Touch.InteractiveGestures = [igPan, igPressAndTap]
            Touch.InteractiveGestureOptions = [igoPanSingleFingerHorizontal, igoPanSingleFingerVertical, igoPanInertia, igoPanGutter, igoParentPassthrough]
            Columns = <>
          end
        end
        object groupsChk: TCheckBox
          Left = 6
          Top = 318
          Width = 350
          Height = 17
          Caption = 'Enable groups'
          TabOrder = 6
        end
        object onlyvisibletoChk: TCheckBox
          Left = 6
          Top = 299
          Width = 350
          Height = 17
          Caption = 'Show only contacts i'#39'm visible to'
          TabOrder = 5
        end
        object onlyonlineChk: TCheckBox
          Left = 6
          Top = 280
          Width = 350
          Height = 17
          Caption = 'Show only online contacts'
          TabOrder = 4
        end
        object showcontacttipChk: TCheckBox
          Left = 6
          Top = 337
          Width = 328
          Height = 17
          Caption = 'Show tip for contacts'
          TabOrder = 7
        end
      end
      object TabSheet2: TTabSheet
        Caption = 'Contact list'
        ImageIndex = 1
        DesignSize = (
          394
          363)
        object dockGrp: TRadioGroup
          Left = 203
          Top = 6
          Width = 170
          Height = 80
          Anchors = [akLeft, akTop, akRight]
          Caption = 'Contact list docking'
          Items.Strings = (
            'none'
            'docking'
            'docking+resize')
          TabOrder = 1
          ExplicitWidth = 182
        end
        object italicGrp: TRadioGroup
          Left = 6
          Top = 90
          Width = 211
          Height = 76
          Caption = 'Contact list italic'
          Items.Strings = (
            'Never'
            'For contacts in visible-list'
            'For contacts i'#39'm visible to')
          TabOrder = 2
        end
        object roasterbarGrp: TRadioGroup
          Left = 219
          Top = 90
          Width = 74
          Height = 76
          Anchors = [akLeft, akTop, akRight]
          Caption = 'Roaster bar'
          Items.Strings = (
            'Top'
            'Bottom'
            'Off')
          TabOrder = 3
          ExplicitWidth = 86
        end
        object autosizeGrp: TRadioGroup
          Left = 6
          Top = 6
          Width = 191
          Height = 80
          Caption = 'Auto-size contact list'
          Items.Strings = (
            'Disabled'
            'Only online'
            'Full list')
          TabOrder = 0
        end
        object TtlGrBox: TGroupBox
          Left = 11
          Top = 172
          Width = 362
          Height = 84
          Anchors = [akLeft, akTop, akRight]
          Caption = 'Window title bar'
          TabOrder = 5
          ExplicitWidth = 374
          object roastertitleBox: TLabeledEdit
            Left = 15
            Top = 34
            Width = 217
            Height = 21
            EditLabel.Width = 114
            EditLabel.Height = 13
            EditLabel.Caption = 'Contact list window title'
            TabOrder = 0
            Text = ''
          end
          object hideoncloseChk00: TRadioButton
            Left = 16
            Top = 61
            Width = 313
            Height = 17
            Caption = 'Show close button acting as minimize button'
            Checked = True
            TabOrder = 1
            TabStop = True
          end
        end
        object filterbarGrp: TRadioGroup
          Left = 307
          Top = 90
          Width = 66
          Height = 76
          Anchors = [akLeft, akTop, akRight]
          Caption = 'Filter bar'
          Items.Strings = (
            'Top'
            'Bottom'
            'Off')
          TabOrder = 4
          ExplicitWidth = 78
        end
        object ShowBrdrChk: TCheckBox
          Left = 6
          Top = 263
          Width = 294
          Height = 17
          Caption = 'Show border'
          TabOrder = 6
        end
        object aniroasterChk: TCheckBox
          Left = 6
          Top = 286
          Width = 350
          Height = 17
          Caption = 'Animated open/close groups in contact list'
          TabOrder = 7
        end
        object unAuthShowChk: TCheckBox
          Left = 6
          Top = 309
          Width = 350
          Height = 17
          Caption = 'Show unauthorized as offline'
          TabOrder = 8
        end
        object AutoSzUpChk: TCheckBox
          Left = 6
          Top = 331
          Width = 382
          Height = 17
          Caption = 'Auto-size up'
          TabOrder = 9
        end
      end
      object TabSheet3: TTabSheet
        Caption = 'Transparency'
        ImageIndex = 2
        DesignSize = (
          394
          363)
        object transpGr: TGroupBox
          Left = 11
          Top = 11
          Width = 363
          Height = 162
          Anchors = [akLeft, akTop, akRight]
          Caption = 'Transparency (works only with Windows XP/2000)'
          TabOrder = 0
          ExplicitWidth = 375
          DesignSize = (
            363
            162)
          object Label14: TLabel
            Left = 32
            Top = 90
            Width = 96
            Height = 13
            Alignment = taRightJustify
            Caption = 'opacity when active'
          end
          object Label15: TLabel
            Left = 24
            Top = 126
            Width = 104
            Height = 13
            Alignment = taRightJustify
            Caption = 'opacity when inactive'
          end
          object Label1: TLabel
            Left = 136
            Top = 69
            Width = 16
            Height = 13
            Caption = 'Min'
          end
          object Label2: TLabel
            Left = 323
            Top = 69
            Width = 20
            Height = 13
            Alignment = taRightJustify
            Anchors = [akTop, akRight]
            Caption = 'Max'
            ExplicitLeft = 335
          end
          object roastertranspChk: TCheckBox
            Left = 15
            Top = 22
            Width = 167
            Height = 18
            HelpKeyword = 'transparency'
            Caption = 'For contact list'
            TabOrder = 0
          end
          object chattranspChk: TCheckBox
            Left = 15
            Top = 47
            Width = 137
            Height = 18
            HelpKeyword = 'transparency-chat'
            Caption = 'For chat window'
            TabOrder = 1
          end
          object transpActive: TTrackBar
            Left = 129
            Top = 87
            Width = 221
            Height = 28
            Anchors = [akLeft, akTop, akRight]
            Max = 255
            TabOrder = 2
            TickStyle = tsManual
            OnChange = transpChange
            OnEnter = transpChange
            OnExit = transpExit
            ExplicitWidth = 233
          end
          object transpInactive: TTrackBar
            Left = 129
            Top = 121
            Width = 221
            Height = 28
            Anchors = [akLeft, akTop, akRight]
            Max = 255
            TabOrder = 3
            TickStyle = tsManual
            OnChange = transpChange
            OnEnter = transpChange
            OnExit = transpExit
            ExplicitWidth = 233
          end
        end
      end
      object avtTS: TTabSheet
        Caption = 'Avatars'
        ImageIndex = 4
        object AvtShwChtChk: TCheckBox
          Left = 6
          Top = 6
          Width = 350
          Height = 17
          Caption = 'Show avatars in chat'
          TabOrder = 0
        end
        object AvtShwHntChk: TCheckBox
          Left = 6
          Top = 29
          Width = 350
          Height = 17
          Caption = 'Show avatars in hints'
          TabOrder = 1
        end
        object AvtShwTraChk: TCheckBox
          Left = 6
          Top = 52
          Width = 350
          Height = 17
          Caption = 'Show avatars in tray'
          TabOrder = 2
        end
        object AvtMaxSzChk: TCheckBox
          Left = 6
          Top = 75
          Width = 264
          Height = 17
          HelpKeyword = 'show-tips-use-avt-size'
          Caption = 'Max avatar size in tips'
          TabOrder = 3
        end
        object AvtMaxSzSpin: TRnQSpinEdit
          Left = 276
          Top = 73
          Width = 80
          Height = 22
          HelpKeyword = 'show-tips-avt-size'
          Decimal = 0
          MaxValue = 300.000000000000000000
          TabOrder = 4
          Value = 100.000000000000000000
          AsInteger = 100
        end
      end
    end
  end
end
