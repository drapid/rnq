object RnQdbFrm: TRnQdbFrm
  Left = 418
  Top = 137
  Caption = 'Contacts database'
  ClientHeight = 428
  ClientWidth = 278
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  TextHeight = 13
  object panel: TPanel
    Left = 0
    Top = 301
    Width = 278
    Height = 127
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    ExplicitTop = 319
    ExplicitWidth = 290
    DesignSize = (
      278
      127)
    object GroupBox1: TGroupBox
      Left = 8
      Top = 8
      Width = 252
      Height = 52
      Anchors = [akLeft, akTop, akRight]
      Caption = 'Purge contacts'
      TabOrder = 1
      ExplicitWidth = 276
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
      Width = 251
      Height = 17
      Anchors = [akLeft, akTop, akRight]
      Caption = 'Remove histories for unexistant contacts'
      TabOrder = 0
      ExplicitWidth = 275
    end
    object purgeBtn: TRnQButton
      Left = 8
      Top = 93
      Width = 99
      Height = 25
      Caption = '&Purge'
      ImageName = ''
      TabOrder = 2
      OnClick = purgeBtnClick
    end
    object reportBtn: TRnQButton
      Left = 125
      Top = 93
      Width = 100
      Height = 25
      Caption = 'View report'
      ImageName = ''
      TabOrder = 3
      Visible = False
      OnClick = reportBtnClick
    end
  end
  object barPnl: TPanel
    Left = 0
    Top = 279
    Width = 278
    Height = 22
    Align = alBottom
    AutoSize = True
    BevelOuter = bvNone
    TabOrder = 1
    ExplicitTop = 297
    ExplicitWidth = 290
    object resizeBtn: TRnQSpeedButton
      Left = 0
      Top = 0
      Width = 22
      Height = 22
      Align = alLeft
      Flat = True
      ImageName = 'down'
      OnClick = resizeBtnClick
    end
    object sbar: TStatusBar
      Left = 22
      Top = 0
      Width = 268
      Height = 22
      Align = alClient
      Panels = <>
      SimplePanel = True
      ExplicitLeft = 24
      ExplicitWidth = 259
      ExplicitHeight = 21
    end
  end
  object dbTree: TVirtualDrawTree
    Left = 0
    Top = 0
    Width = 278
    Height = 279
    Align = alClient
    Colors.UnfocusedColor = clMedGray
    Header.AutoSizeIndex = 1
    Header.DefaultHeight = 17
    Header.Height = 17
    Header.Options = [hoColumnResize, hoDrag, hoShowSortGlyphs, hoVisible]
    Header.PopupMenu = VTHPMenu
    Header.SortColumn = 0
    TabOrder = 2
    TreeOptions.PaintOptions = [toShowButtons, toShowDropmark, toShowHorzGridLines, toThemeAware, toUseBlendedImages]
    TreeOptions.SelectionOptions = [toFullRowSelect, toMultiSelect, toRightClickSelect]
    OnCompareNodes = dbTreeCompareNodes
    OnDrawNode = dbTreeDrawNode
    OnHeaderClick = dbTreeHeaderClick
    Touch.InteractiveGestures = [igPan, igPressAndTap]
    Touch.InteractiveGestureOptions = [igoPanSingleFingerHorizontal, igoPanSingleFingerVertical, igoPanInertia, igoPanGutter, igoParentPassthrough]
    ExplicitWidth = 290
    ExplicitHeight = 297
    Columns = <
      item
        Position = 0
        Text = 'UIN'
        Width = 90
      end
      item
        Position = 1
        Text = 'Nickname'
        Width = 159
      end
      item
        MinWidth = 20
        Options = [coAllowClick, coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark]
        Position = 2
        Text = 'Important'
      end
      item
        MinWidth = 100
        Options = [coAllowClick, coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark]
        Position = 3
        Text = 'Avatar MD5'
        Width = 100
      end
      item
        Options = [coAllowClick, coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark]
        Position = 4
        Text = 'Birthday'
      end
      item
        Options = [coAllowClick, coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark]
        Position = 5
        Text = 'Days to Bd'
      end
      item
        Options = [coAllowClick, coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark]
        Position = 6
        Text = 'Last time seen online'
        Width = 130
      end>
  end
  object VTHPMenu: TVTHeaderPopupMenu
    OwnerDraw = True
    OnPopup = VTHPMenuPopup
    Left = 176
    Top = 112
  end
end
