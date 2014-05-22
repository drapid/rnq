object CLsyncDlg: TCLsyncDlg
  Left = 278
  Top = 134
  Caption = 'CL sync'
  ClientHeight = 266
  ClientWidth = 413
  Color = clBtnFace
  Constraints.MinHeight = 296
  Constraints.MinWidth = 200
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object SCList: TVirtualDrawTree
    Left = 0
    Top = 0
    Width = 413
    Height = 229
    Align = alClient
    Header.AutoSizeIndex = 0
    Header.Font.Charset = DEFAULT_CHARSET
    Header.Font.Color = clWindowText
    Header.Font.Height = -11
    Header.Font.Name = 'Tahoma'
    Header.Font.Style = []
    Header.MainColumn = 1
    Header.Options = [hoAutoResize, hoColumnResize, hoDrag, hoShowSortGlyphs, hoVisible]
    Header.SortColumn = 0
    Header.Style = hsThickButtons
    TabOrder = 0
    TreeOptions.MiscOptions = [toFullRepaintOnResize, toGridExtensions, toInitOnSave, toToggleOnDblClick, toWheelPanning]
    TreeOptions.PaintOptions = [toHideSelection, toShowButtons, toShowDropmark, toShowHorzGridLines, toShowVertGridLines, toThemeAware, toUseBlendedImages]
    TreeOptions.SelectionOptions = [toFullRowSelect]
    OnCompareNodes = SCListCompareNodes
    OnDrawNode = SCListDrawNode
    OnMouseDown = SCListMouseDown
    Columns = <
      item
        Position = 0
        Width = 189
        WideText = 'Contact'
      end
      item
        Position = 1
        Width = 90
        WideText = 'Display [Server]'
      end
      item
        Options = [coAllowClick, coDraggable, coEnabled, coParentBidiMode, coParentColor, coShowDropMark, coVisible]
        Position = 2
        Style = vsOwnerDraw
        Width = 40
        WideText = 'CopyTo'
        WideHint = 'CopyTo'
      end
      item
        Position = 3
        Width = 90
        WideText = 'Display [Local]'
      end>
  end
  object Panel1: TPanel
    Left = 0
    Top = 229
    Width = 413
    Height = 37
    Align = alBottom
    TabOrder = 1
    DesignSize = (
      413
      37)
    object ApplyBtn: TRnQSpeedButton
      Left = 233
      Top = 8
      Width = 80
      Height = 22
      Anchors = [akTop, akRight]
      Caption = 'Apply'
      ModalResult = 1
      ImageName = 'apply'
      ExplicitLeft = 12
    end
    object CancelBtn: TRnQSpeedButton
      Left = 321
      Top = 8
      Width = 80
      Height = 22
      Anchors = [akTop, akRight]
      Caption = 'Cancel'
      ModalResult = 2
      ImageName = 'cancel'
      OnClick = CancelBtnClick
      ExplicitLeft = 100
    end
  end
end
