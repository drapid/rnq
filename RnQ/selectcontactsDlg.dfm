object selectCntsFrm: TselectCntsFrm
  Left = 234
  Top = 154
  BorderIcons = [biSystemMenu, biMinimize]
  Caption = 'Select contacts'
  ClientHeight = 357
  ClientWidth = 196
  Color = clBtnFace
  Constraints.MaxWidth = 218
  Constraints.MinHeight = 160
  Constraints.MinWidth = 210
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OnClose = FormClose
  OnCreate = FormCreate
  OnShow = FormShow
  DesignSize = (
    196
    357)
  TextHeight = 13
  object sbar: TStatusBar
    Left = 0
    Top = 338
    Width = 196
    Height = 19
    Panels = <>
    SimplePanel = True
    SizeGrip = False
    ExplicitTop = 347
    ExplicitWidth = 202
  end
  object listPnl: TPanel
    Left = 0
    Top = 302
    Width = 196
    Height = 36
    Align = alBottom
    BevelOuter = bvLowered
    TabOrder = 0
    ExplicitTop = 311
    ExplicitWidth = 202
    DesignSize = (
      196
      36)
    object Label1: TLabel
      Left = 1
      Top = 1
      Width = 194
      Height = 13
      Align = alTop
      Alignment = taCenter
      AutoSize = False
      Caption = 'uin-list'
      Transparent = True
      ExplicitLeft = 16
      ExplicitTop = 0
      ExplicitWidth = 176
    end
    object saveBtn: TRnQSpeedButton
      Left = 149
      Top = 16
      Width = 20
      Height = 20
      Hint = 'Save selected as a uin-list'
      Anchors = [akTop, akRight]
      Caption = '<'
      Font.Charset = SYMBOL_CHARSET
      Font.Color = clNavy
      Font.Height = -15
      Font.Name = 'Wingdings'
      Font.Style = []
      Layout = blGlyphRight
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      OnClick = saveBtnClick
      ExplicitLeft = 159
    end
    object addBtn: TRnQSpeedButton
      Left = 110
      Top = 16
      Width = 20
      Height = 20
      Hint = 'Add the uin-list to the selected'
      Anchors = [akTop, akRight]
      Caption = '+'
      Font.Charset = ANSI_CHARSET
      Font.Color = clGreen
      Font.Height = -19
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      Layout = blGlyphBottom
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      OnClick = addBtnClick
      ExplicitLeft = 120
    end
    object subBtn: TRnQSpeedButton
      Left = 130
      Top = 16
      Width = 20
      Height = 20
      Hint = 'Remove the uin-list from the selected'
      Anchors = [akTop, akRight]
      Caption = '-'
      Font.Charset = ANSI_CHARSET
      Font.Color = clMaroon
      Font.Height = -19
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      Layout = blGlyphBottom
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      OnClick = subBtnClick
      ExplicitLeft = 140
    end
    object delBtn: TRnQSpeedButton
      Left = 167
      Top = 16
      Width = 20
      Height = 20
      Hint = 'Delete this uin-list'
      Anchors = [akTop, akRight]
      Caption = 'u'
      Font.Charset = SYMBOL_CHARSET
      Font.Color = clRed
      Font.Height = -19
      Font.Name = 'Wingdings'
      Font.Style = []
      Layout = blGlyphRight
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      OnClick = delBtnClick
      ExplicitLeft = 177
    end
    object uinlistBox: TComboBox
      Left = 5
      Top = 16
      Width = 103
      Height = 19
      Anchors = [akLeft, akTop, akRight]
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -9
      Font.Name = 'Small Fonts'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
      Text = 'uinlistBox'
    end
  end
  object doBtn: TRnQButton
    Left = 8
    Top = 248
    Width = 185
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Do it'
    ImageName = ''
    TabOrder = 2
    ExplicitTop = 257
  end
  object list: TVirtualDrawTree
    Left = 0
    Top = 0
    Width = 196
    Height = 243
    Align = alTop
    Anchors = [akLeft, akTop, akRight, akBottom]
    ButtonStyle = bsTriangle
    Header.AutoSizeIndex = 0
    Header.DefaultHeight = 17
    Header.Height = 13
    Header.MainColumn = -1
    Header.Options = [hoColumnResize, hoDrag]
    IncrementalSearch = isAll
    TabOrder = 3
    TreeOptions.MiscOptions = [toAcceptOLEDrop, toCheckSupport, toFullRepaintOnResize, toInitOnSave, toToggleOnDblClick, toWheelPanning]
    TreeOptions.PaintOptions = [toShowButtons, toShowDropmark, toShowTreeLines, toThemeAware, toUseBlendedImages]
    TreeOptions.SelectionOptions = [toFullRowSelect, toMiddleClickSelect, toRightClickSelect]
    OnChecked = listChecked
    OnDrawNode = listDrawNode
    OnGetNodeWidth = listGetNodeWidth
    Touch.InteractiveGestures = [igPan, igPressAndTap]
    Touch.InteractiveGestureOptions = [igoPanSingleFingerHorizontal, igoPanSingleFingerVertical, igoPanInertia, igoPanGutter, igoParentPassthrough]
    ExplicitWidth = 202
    ExplicitHeight = 252
    Columns = <>
  end
  object selectBtn: TRnQButton
    Left = 8
    Top = 279
    Width = 88
    Height = 17
    Anchors = [akLeft, akBottom]
    Caption = 'Select all'
    ImageName = ''
    TabOrder = 4
    OnClick = selectBtnClick
    ExplicitTop = 288
  end
  object unselectBtn: TRnQButton
    Left = 104
    Top = 279
    Width = 90
    Height = 17
    Anchors = [akLeft, akBottom]
    Caption = 'Unselect all'
    ImageName = ''
    TabOrder = 5
    OnClick = unselectBtnClick
    ExplicitTop = 288
  end
end
