object selectCntsFrm: TselectCntsFrm
  Left = 234
  Top = 154
  BorderIcons = [biSystemMenu, biMinimize]
  Caption = 'Select contacts'
  ClientHeight = 366
  ClientWidth = 202
  Color = clBtnFace
  Constraints.MaxWidth = 218
  Constraints.MinHeight = 160
  Constraints.MinWidth = 210
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = True
  OnClose = FormClose
  OnCreate = FormCreate
  OnShow = FormShow
  DesignSize = (
    202
    366)
  PixelsPerInch = 96
  TextHeight = 13
  object sbar: TStatusBar
    Left = 0
    Top = 347
    Width = 202
    Height = 19
    Panels = <>
    SimplePanel = True
    SizeGrip = False
  end
  object listPnl: TPanel
    Left = 0
    Top = 311
    Width = 202
    Height = 36
    Align = alBottom
    BevelOuter = bvLowered
    TabOrder = 0
    DesignSize = (
      202
      36)
    object Label1: TLabel
      Left = 1
      Top = 1
      Width = 200
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
      Left = 159
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
    end
    object addBtn: TRnQSpeedButton
      Left = 120
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
    end
    object subBtn: TRnQSpeedButton
      Left = 140
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
    end
    object delBtn: TRnQSpeedButton
      Left = 177
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
    end
    object uinlistBox: TComboBox
      Left = 5
      Top = 16
      Width = 113
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
    Top = 257
    Width = 185
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Do it'
    TabOrder = 2
  end
  object list: TVirtualDrawTree
    Left = 0
    Top = 0
    Width = 202
    Height = 252
    Align = alTop
    Anchors = [akLeft, akTop, akRight, akBottom]
    ButtonStyle = bsTriangle
    CheckImageKind = ckXP
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
    IncrementalSearch = isAll
    TabOrder = 3
    TreeOptions.MiscOptions = [toAcceptOLEDrop, toCheckSupport, toFullRepaintOnResize, toInitOnSave, toToggleOnDblClick, toWheelPanning]
    TreeOptions.PaintOptions = [toShowButtons, toShowDropmark, toShowTreeLines, toThemeAware, toUseBlendedImages]
    TreeOptions.SelectionOptions = [toFullRowSelect, toMiddleClickSelect, toRightClickSelect]
    OnChecked = listChecked
    OnDrawNode = listDrawNode
    OnGetNodeWidth = listGetNodeWidth
    Columns = <>
  end
  object selectBtn: TRnQButton
    Left = 8
    Top = 288
    Width = 88
    Height = 17
    Anchors = [akLeft, akBottom]
    Caption = 'Select all'
    TabOrder = 4
    OnClick = selectBtnClick
  end
  object unselectBtn: TRnQButton
    Left = 104
    Top = 288
    Width = 90
    Height = 17
    Anchors = [akLeft, akBottom]
    Caption = 'Unselect all'
    TabOrder = 5
    OnClick = unselectBtnClick
  end
end
