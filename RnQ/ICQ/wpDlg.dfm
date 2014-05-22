object wpFrm: TwpFrm
  Left = 359
  Top = 263
  Caption = 'White pages'
  ClientHeight = 430
  ClientWidth = 656
  Color = clBtnFace
  Constraints.MinHeight = 250
  Constraints.MinWidth = 662
  Font.Charset = RUSSIAN_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = True
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnPaint = FormPaint
  OnResize = FormResize
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 399
    Width = 656
    Height = 31
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    DesignSize = (
      656
      31)
    object clearBtn: TRnQSpeedButton
      Left = 97
      Top = 43
      Width = 90
      Height = 25
      Caption = '&Clear'
      Visible = False
      OnClick = clearBtnClick
    end
    object Label12: TLabel
      Left = 22
      Top = 10
      Width = 82
      Height = 13
      Caption = 'Only online users'
      FocusControl = onlineChk
      Transparent = True
      OnClick = Label12Click
    end
    object Label1: TLabel
      Left = 196
      Top = 10
      Width = 86
      Height = 13
      Caption = 'Don'#39't clear results'
      FocusControl = accumulateChk
      Transparent = True
      OnClick = Label1Click
    end
    object AddSB: TRnQSpeedButton
      Left = 328
      Top = 6
      Width = 97
      Height = 19
      Caption = 'Next'
      ImageName = 'add'
      OnClick = AddSBClick
    end
    object sbar: TPanel
      Left = 431
      Top = 5
      Width = 220
      Height = 23
      Anchors = [akLeft, akTop, akRight, akBottom]
      BevelKind = bkFlat
      BevelOuter = bvNone
      TabOrder = 0
    end
    object accumulateChk: TCheckBox
      Left = 179
      Top = 9
      Width = 14
      Height = 14
      TabOrder = 1
    end
    object onlineChk: TCheckBox
      Left = 5
      Top = 9
      Width = 14
      Height = 14
      TabOrder = 2
    end
  end
  object pcSearch: TPageControl
    Left = 0
    Top = 0
    Width = 656
    Height = 225
    ActivePage = TabSheet1
    Align = alTop
    TabOrder = 1
    OnChange = pcSearchChange
    object TabSheet1: TTabSheet
      Caption = 'UIN'
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object uinBox2: TLabeledEdit
        Left = 60
        Top = 8
        Width = 487
        Height = 21
        EditLabel.Width = 18
        EditLabel.Height = 13
        EditLabel.Caption = 'UIN'
        EditLabel.Transparent = True
        LabelPosition = lpLeft
        TabOrder = 0
        OnChange = uinBoxChange
      end
      object searchBtn: TRnQButton
        Left = 565
        Top = 6
        Width = 80
        Height = 25
        Caption = '&Search'
        Default = True
        TabOrder = 1
        OnClick = searchBtnClick
        ImageName = 'search'
      end
    end
    object TabSheet2: TTabSheet
      Caption = 'E-Mail'
      ImageIndex = 1
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object emailBox2: TLabeledEdit
        Left = 60
        Top = 8
        Width = 487
        Height = 21
        EditLabel.Width = 28
        EditLabel.Height = 13
        EditLabel.Caption = 'E-mail'
        EditLabel.Transparent = True
        LabelPosition = lpLeft
        TabOrder = 0
      end
    end
    object TabSheet3: TTabSheet
      Caption = 'Key words'
      ImageIndex = 2
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object Label2: TLabel
        Left = 13
        Top = 12
        Width = 44
        Height = 13
        Alignment = taRightJustify
        Caption = 'Interests'
        Transparent = True
      end
      object keyBox2: TLabeledEdit
        Left = 256
        Top = 8
        Width = 291
        Height = 21
        EditLabel.Width = 31
        EditLabel.Height = 13
        EditLabel.Caption = 'Words'
        EditLabel.Transparent = True
        LabelPosition = lpLeft
        TabOrder = 0
      end
      object InterestCombo2: TComboBox
        Left = 60
        Top = 8
        Width = 120
        Height = 21
        AutoComplete = False
        Style = csDropDownList
        Sorted = True
        TabOrder = 1
      end
    end
    object TabSheet4: TTabSheet
      Caption = 'Personal Info'
      ImageIndex = 3
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object nickBox2: TLabeledEdit
        Left = 60
        Top = 8
        Width = 120
        Height = 21
        EditLabel.Width = 19
        EditLabel.Height = 13
        EditLabel.Caption = 'Nick'
        EditLabel.Transparent = True
        LabelPosition = lpLeft
        TabOrder = 0
      end
      object firstBox2: TLabeledEdit
        Left = 243
        Top = 8
        Width = 120
        Height = 21
        EditLabel.Width = 50
        EditLabel.Height = 13
        EditLabel.Caption = 'First name'
        EditLabel.Transparent = True
        LabelPosition = lpLeft
        TabOrder = 1
      end
      object lastBox2: TLabeledEdit
        Left = 427
        Top = 8
        Width = 120
        Height = 21
        EditLabel.Width = 49
        EditLabel.Height = 13
        EditLabel.Caption = 'Last name'
        EditLabel.Transparent = True
        LabelPosition = lpLeft
        TabOrder = 2
      end
    end
    object TabSheet5: TTabSheet
      Caption = 'All Info'
      ImageIndex = 4
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object Panel2: TPanel
        Left = 0
        Top = 0
        Width = 561
        Height = 197
        Align = alLeft
        BevelOuter = bvNone
        TabOrder = 0
        object Label5: TLabel
          Left = 409
          Top = 35
          Width = 19
          Height = 13
          Alignment = taRightJustify
          Caption = 'Age'
          Transparent = True
        end
        object Label8: TLabel
          Left = 201
          Top = 11
          Width = 39
          Height = 13
          Alignment = taRightJustify
          Caption = 'Country'
          Transparent = True
        end
        object Label9: TLabel
          Left = 393
          Top = 12
          Width = 35
          Height = 13
          Alignment = taRightJustify
          Caption = 'Gender'
          Transparent = True
        end
        object Label10: TLabel
          Left = 382
          Top = 61
          Width = 47
          Height = 13
          Alignment = taRightJustify
          Caption = 'Language'
          Transparent = True
        end
        object Label3: TLabel
          Left = 195
          Top = 83
          Width = 44
          Height = 13
          Alignment = taRightJustify
          Caption = 'Interests'
          Transparent = True
        end
        object ageBox: TComboBox
          Left = 435
          Top = 31
          Width = 120
          Height = 21
          AutoComplete = False
          Style = csDropDownList
          TabOrder = 10
        end
        object genderBox: TComboBox
          Left = 435
          Top = 8
          Width = 120
          Height = 21
          AutoComplete = False
          Style = csDropDownList
          TabOrder = 9
        end
        object countryBox: TComboBox
          Left = 242
          Top = 8
          Width = 120
          Height = 21
          AutoComplete = False
          Style = csDropDownList
          Sorted = True
          TabOrder = 5
        end
        object langBox: TComboBox
          Left = 435
          Top = 56
          Width = 120
          Height = 21
          AutoComplete = False
          Style = csDropDownList
          Sorted = True
          TabOrder = 11
        end
        object nickBox: TLabeledEdit
          Left = 60
          Top = 8
          Width = 120
          Height = 21
          EditLabel.Width = 19
          EditLabel.Height = 13
          EditLabel.Caption = 'Nick'
          EditLabel.Transparent = True
          LabelPosition = lpLeft
          TabOrder = 1
        end
        object firstBox: TLabeledEdit
          Left = 60
          Top = 32
          Width = 120
          Height = 21
          EditLabel.Width = 50
          EditLabel.Height = 13
          EditLabel.Caption = 'First name'
          EditLabel.Transparent = True
          LabelPosition = lpLeft
          TabOrder = 2
        end
        object cityBox: TLabeledEdit
          Left = 242
          Top = 32
          Width = 120
          Height = 21
          EditLabel.Width = 19
          EditLabel.Height = 13
          EditLabel.Caption = 'City'
          EditLabel.Transparent = True
          LabelPosition = lpLeft
          TabOrder = 6
        end
        object lastBox: TLabeledEdit
          Left = 60
          Top = 56
          Width = 120
          Height = 21
          EditLabel.Width = 49
          EditLabel.Height = 13
          EditLabel.Caption = 'Last name'
          EditLabel.Transparent = True
          LabelPosition = lpLeft
          TabOrder = 3
        end
        object emailBox: TLabeledEdit
          Left = 60
          Top = 80
          Width = 120
          Height = 21
          EditLabel.Width = 28
          EditLabel.Height = 13
          EditLabel.Caption = 'E-mail'
          EditLabel.Transparent = True
          LabelPosition = lpLeft
          TabOrder = 4
        end
        object uinBox: TLabeledEdit
          Left = 60
          Top = 136
          Width = 120
          Height = 21
          EditLabel.Width = 18
          EditLabel.Height = 13
          EditLabel.Caption = 'UIN'
          EditLabel.Transparent = True
          LabelPosition = lpLeft
          TabOrder = 0
          Visible = False
          OnChange = uinBoxChange
        end
        object stateBox: TLabeledEdit
          Left = 242
          Top = 56
          Width = 120
          Height = 21
          EditLabel.Width = 26
          EditLabel.Height = 13
          EditLabel.Caption = 'State'
          EditLabel.Transparent = True
          LabelPosition = lpLeft
          TabOrder = 7
        end
        object keyBox: TLabeledEdit
          Left = 435
          Top = 80
          Width = 120
          Height = 21
          EditLabel.Width = 47
          EditLabel.Height = 13
          EditLabel.Caption = 'Keywords'
          EditLabel.Transparent = True
          LabelPosition = lpLeft
          TabOrder = 12
        end
        object InterestCombo1: TComboBox
          Left = 242
          Top = 80
          Width = 120
          Height = 21
          AutoComplete = False
          Style = csDropDownList
          Sorted = True
          TabOrder = 8
        end
      end
    end
    object TabSheet6: TTabSheet
      Caption = 'People Search'
      ImageIndex = 5
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object Label4: TLabel
        Left = 22
        Top = 42
        Width = 39
        Height = 13
        Alignment = taRightJustify
        Caption = 'Country'
        Transparent = True
      end
      object Label6: TLabel
        Left = 265
        Top = 16
        Width = 35
        Height = 13
        Alignment = taRightJustify
        Caption = 'Gender'
        Transparent = True
      end
      object Label7: TLabel
        Left = 281
        Top = 41
        Width = 19
        Height = 13
        Alignment = taRightJustify
        Caption = 'Age'
        Transparent = True
      end
      object Label11: TLabel
        Left = 254
        Top = 65
        Width = 47
        Height = 13
        Alignment = taRightJustify
        Caption = 'Language'
        Transparent = True
      end
      object nickCPbox: TLabeledEdit
        Left = 63
        Top = 12
        Width = 160
        Height = 21
        EditLabel.Width = 19
        EditLabel.Height = 13
        EditLabel.Caption = 'Nick'
        EditLabel.Transparent = True
        LabelPosition = lpLeft
        TabOrder = 0
      end
      object CountryCPCBox: TComboBox
        Left = 63
        Top = 39
        Width = 160
        Height = 21
        AutoComplete = False
        Style = csDropDownList
        Sorted = True
        TabOrder = 1
      end
      object CityCPLEdit: TLabeledEdit
        Left = 63
        Top = 63
        Width = 160
        Height = 21
        EditLabel.Width = 19
        EditLabel.Height = 13
        EditLabel.Caption = 'City'
        EditLabel.Transparent = True
        LabelPosition = lpLeft
        TabOrder = 2
      end
      object LangCPCBox: TComboBox
        Left = 307
        Top = 63
        Width = 160
        Height = 21
        AutoComplete = False
        Style = csDropDownList
        Sorted = True
        TabOrder = 5
      end
      object AgeCPCBox: TComboBox
        Left = 307
        Top = 36
        Width = 160
        Height = 21
        AutoComplete = False
        Style = csDropDownList
        TabOrder = 4
      end
      object GenderCPCBox: TComboBox
        Left = 307
        Top = 12
        Width = 160
        Height = 21
        AutoComplete = False
        Style = csDropDownList
        TabOrder = 3
      end
    end
  end
  object resultTree: TVirtualDrawTree
    Left = 0
    Top = 225
    Width = 656
    Height = 174
    Align = alClient
    Header.AutoSizeIndex = 2
    Header.DefaultHeight = 17
    Header.Font.Charset = DEFAULT_CHARSET
    Header.Font.Color = clWindowText
    Header.Font.Height = -11
    Header.Font.Name = 'Tahoma'
    Header.Font.Style = []
    Header.Height = 17
    Header.Options = [hoColumnResize, hoDrag, hoShowSortGlyphs, hoVisible]
    Header.PopupMenu = VTHPMenu
    Header.SortColumn = 2
    TabOrder = 2
    TreeOptions.AutoOptions = [toAutoDropExpand, toAutoScrollOnExpand, toAutoSort, toAutoSpanColumns, toAutoTristateTracking, toAutoDeleteMovedNodes]
    TreeOptions.MiscOptions = [toAcceptOLEDrop, toFullRepaintOnResize, toGridExtensions, toInitOnSave, toToggleOnDblClick, toWheelPanning]
    TreeOptions.PaintOptions = [toShowButtons, toShowDropmark, toShowHorzGridLines, toShowTreeLines, toShowVertGridLines, toThemeAware, toUseBlendedImages, toFullVertGridLines, toUseBlendedSelection]
    TreeOptions.SelectionOptions = [toFullRowSelect, toRightClickSelect]
    OnCompareNodes = resultTreeCompareNodes
    OnDblClick = resultsDblClick
    OnDrawNode = resultTreeDrawNode
    OnHeaderClick = resultTreeHeaderClick
    Columns = <
      item
        MaxWidth = 50
        MinWidth = 30
        Position = 0
        WideText = 'Online'
      end
      item
        Alignment = taCenter
        MaxWidth = 100
        MinWidth = 30
        Position = 1
        Width = 80
        WideText = 'UIN'
      end
      item
        Alignment = taCenter
        Position = 2
        Width = 182
        WideText = 'Nick'
      end
      item
        MinWidth = 70
        Position = 3
        Width = 80
        WideText = 'First name'
      end
      item
        MinWidth = 80
        Position = 4
        Width = 80
        WideText = 'Last name'
      end
      item
        MinWidth = 80
        Position = 5
        Width = 80
        WideText = 'E-Mail'
      end
      item
        Position = 6
        WideText = 'Gender/Age'
      end
      item
        Position = 7
        WideText = 'Authorize'
      end
      item
        Options = [coAllowClick, coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark]
        Position = 8
        WideText = 'Birthday'
      end>
  end
  object VTHPMenu: TVTHeaderPopupMenu
    OwnerDraw = True
    OnPopup = VTHPMenuPopup
    Left = 512
    Top = 288
  end
end
