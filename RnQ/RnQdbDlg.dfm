object RnQdbFrm: TRnQdbFrm
  Left = 418
  Top = 137
  Caption = 'Contacts database'
  ClientHeight = 446
  ClientWidth = 290
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object panel: TPanel
    Left = 0
    Top = 319
    Width = 290
    Height = 127
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    ExplicitWidth = 289
    DesignSize = (
      290
      127)
    object GroupBox1: TGroupBox
      Left = 8
      Top = 8
      Width = 276
      Height = 52
      Anchors = [akLeft, akTop, akRight]
      Caption = 'Purge contacts'
      TabOrder = 1
      ExplicitWidth = 275
      object nilChk: TRadioButton
        Left = 8
        Top = 24
        Width = 113
        Height = 17
        Caption = 'not in my list'
        Checked = True
        TabOrder = 0
        TabStop = True
      end
    end
    object removenilhistoriesChk: TCheckBox
      Left = 8
      Top = 70
      Width = 275
      Height = 17
      Anchors = [akLeft, akTop, akRight]
      Caption = 'Remove histories for unexistant contacts'
      TabOrder = 0
    end
    object purgeBtn: TRnQButton
      Left = 8
      Top = 93
      Width = 99
      Height = 25
      Caption = '&Purge'
      TabOrder = 2
      OnClick = purgeBtnClick
    end
    object reportBtn: TRnQButton
      Left = 125
      Top = 93
      Width = 100
      Height = 25
      Caption = 'View report'
      TabOrder = 3
      Visible = False
      OnClick = reportBtnClick
    end
  end
  object barPnl: TPanel
    Left = 0
    Top = 297
    Width = 290
    Height = 22
    Align = alBottom
    AutoSize = True
    BevelOuter = bvNone
    Caption = 'barPnl'
    TabOrder = 1
    ExplicitWidth = 289
    DesignSize = (
      290
      22)
    object resizeBtn: TRnQSpeedButton
      Left = 0
      Top = 0
      Width = 22
      Height = 22
      Flat = True
      ImageName = 'down'
      OnClick = resizeBtnClick
    end
    object sbar: TStatusBar
      Left = 24
      Top = 0
      Width = 263
      Height = 21
      Align = alNone
      Anchors = [akLeft, akTop, akRight]
      Panels = <>
      SimplePanel = True
      ExplicitWidth = 262
    end
  end
  object dbTree: TVirtualDrawTree
    Left = 0
    Top = 0
    Width = 290
    Height = 297
    Align = alClient
    Header.AutoSizeIndex = 1
    Header.DefaultHeight = 17
    Header.Font.Charset = DEFAULT_CHARSET
    Header.Font.Color = clWindowText
    Header.Font.Height = -11
    Header.Font.Name = 'Tahoma'
    Header.Font.Style = []
    Header.Height = 17
    Header.Options = [hoColumnResize, hoDrag, hoShowSortGlyphs, hoVisible]
    Header.PopupMenu = VTHPMenu
    Header.SortColumn = 0
    TabOrder = 2
    TreeOptions.AutoOptions = [toAutoDropExpand, toAutoScrollOnExpand, toAutoSort, toAutoTristateTracking, toAutoDeleteMovedNodes]
    TreeOptions.PaintOptions = [toShowButtons, toShowDropmark, toShowHorzGridLines, toThemeAware, toUseBlendedImages]
    TreeOptions.SelectionOptions = [toFullRowSelect, toMultiSelect, toRightClickSelect]
    OnCompareNodes = dbTreeCompareNodes
    OnDrawNode = dbTreeDrawNode
    OnHeaderClick = dbTreeHeaderClick
    ExplicitWidth = 289
    Columns = <
      item
        Position = 0
        Width = 90
        WideText = 'UIN'
      end
      item
        Position = 1
        Width = 159
        WideText = 'Nickname'
      end
      item
        MinWidth = 20
        Options = [coAllowClick, coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark]
        Position = 2
        WideText = 'Important'
      end
      item
        MinWidth = 100
        Options = [coAllowClick, coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark]
        Position = 3
        Width = 100
        WideText = 'Avatar MD5'
      end
      item
        Options = [coAllowClick, coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark]
        Position = 4
        WideText = 'Birthday'
      end
      item
        Options = [coAllowClick, coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark]
        Position = 5
        WideText = 'Days to Bd'
      end
      item
        Options = [coAllowClick, coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark]
        Position = 6
        Width = 130
        WideText = 'Last time seen online'
      end>
  end
  object VTHPMenu: TVTHeaderPopupMenu
    OwnerDraw = True
    OnPopup = VTHPMenuPopup
    Left = 176
    Top = 112
  end
end
