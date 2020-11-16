object prefFrm: TprefFrm
  Left = 113
  Top = 133
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsDialog
  Caption = 'Preferences'
  ClientHeight = 431
  ClientWidth = 596
  Color = clBtnFace
  DefaultMonitor = dmMainForm
  ParentFont = True
  GlassFrame.Enabled = True
  GlassFrame.Bottom = 30
  KeyPreview = True
  OldCreateOrder = True
  Position = poScreenCenter
  ShowHint = True
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  DesignSize = (
    596
    431)
  PixelsPerInch = 96
  TextHeight = 13
  object Bevel: TBevel
    Left = 6
    Top = 271
    Width = 551
    Height = 4
    Anchors = [akLeft, akRight, akBottom]
    Shape = bsBottomLine
    ExplicitTop = 272
    ExplicitWidth = 549
  end
  object framePnl: TPanel
    Left = 198
    Top = 8
    Width = 360
    Height = 258
    Align = alCustom
    Anchors = [akLeft, akTop, akRight, akBottom]
    BevelInner = bvRaised
    BevelOuter = bvLowered
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
  end
  object PrefList: TVirtualDrawTree
    Left = 8
    Top = 8
    Width = 184
    Height = 258
    Colors.UnfocusedSelectionColor = clBtnShadow
    Header.AutoSizeIndex = 0
    Header.DefaultHeight = 17
    Header.Height = 17
    Header.MainColumn = -1
    Header.Options = [hoColumnResize, hoDrag]
    IncrementalSearch = isAll
    TabOrder = 0
    TreeOptions.MiscOptions = [toAcceptOLEDrop, toFullRepaintOnResize, toInitOnSave, toToggleOnDblClick, toWheelPanning]
    TreeOptions.PaintOptions = [toShowButtons, toShowDropmark, toShowTreeLines, toThemeAware, toUseBlendedImages, toUseBlendedSelection]
    TreeOptions.SelectionOptions = [toFullRowSelect, toMiddleClickSelect, toRightClickSelect]
    OnChange = PrefListChange
    OnDrawNode = PrefListDrawNode
    OnFreeNode = PrefListFreeNode
    OnGetNodeWidth = PrefListGetNodeWidth
    Columns = <>
  end
  object resetBtn: TRnQButton
    Left = 8
    Top = 281
    Width = 85
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Reset'
    ImageName = 'refresh'
    TabOrder = 2
    OnClick = resetBtnClick
  end
  object okBtn: TRnQButton
    Left = 274
    Top = 281
    Width = 83
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Ok'
    Default = True
    ImageName = 'ok'
    ModalResult = 1
    TabOrder = 3
    OnClick = okBtnClick
  end
  object closeBtn: TRnQButton
    Left = 362
    Top = 281
    Width = 91
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Close'
    ImageName = 'close'
    TabOrder = 4
    OnClick = closeBtnClick
  end
  object applyBtn: TRnQButton
    Left = 460
    Top = 281
    Width = 89
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Apply'
    ImageName = 'apply'
    TabOrder = 5
    OnClick = applyBtnClick
  end
end
