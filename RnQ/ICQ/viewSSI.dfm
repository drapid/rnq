object SSIForm: TSSIForm
  Left = 192
  Top = 114
  Caption = 'Server side information'
  ClientHeight = 436
  ClientWidth = 722
  Color = clBtnFace
  ParentFont = True
  OldCreateOrder = False
  OnClose = FormClose
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object CLTree: TVirtualDrawTree
    Left = 0
    Top = 0
    Width = 577
    Height = 320
    Align = alClient
    BorderWidth = 1
    CheckImageKind = ckXP
    Header.AutoSizeIndex = 0
    Header.Font.Charset = DEFAULT_CHARSET
    Header.Font.Color = clWindowText
    Header.Font.Height = -11
    Header.Font.Name = 'Tahoma'
    Header.Font.Style = []
    Header.Options = [hoColumnResize, hoDrag, hoVisible, hoAutoSpring]
    Header.PopupMenu = VTHeaderPopupMenu1
    TabOrder = 0
    TreeOptions.MiscOptions = [toAcceptOLEDrop, toFullRepaintOnResize, toGridExtensions, toInitOnSave, toToggleOnDblClick, toWheelPanning, toFullRowDrag]
    TreeOptions.PaintOptions = [toShowButtons, toShowDropmark, toShowTreeLines, toShowVertGridLines, toThemeAware, toUseBlendedImages, toFullVertGridLines]
    TreeOptions.SelectionOptions = [toFullRowSelect, toRightClickSelect]
    OnDrawNode = CLTreeDrawNode
    OnFocusChanged = CLTreeFocusChanged
    OnFreeNode = CLTreeFreeNode
    OnGetNodeWidth = CLTreeGetNodeWidth
    Columns = <
      item
        Position = 0
        Width = 150
        WideText = 'List Item'
      end
      item
        Position = 1
        WideText = 'Auth'
      end
      item
        Position = 2
        WideText = 'Alias'
      end
      item
        Position = 3
        WideText = 'ID'
      end
      item
        Options = [coAllowClick, coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark]
        Position = 4
        WideText = 'E-Mail'
      end
      item
        Options = [coAllowClick, coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark]
        Position = 5
        WideText = 'Mobile'
      end
      item
        Options = [coAllowClick, coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark]
        Position = 6
        WideText = 'Note'
      end
      item
        Position = 7
        Width = 70
        WideText = 'Time'
      end
      item
        Position = 8
        Width = 60
        WideText = 'Type'
      end
      item
        Position = 9
        WideText = 'Ext'
      end>
  end
  object Panel1: TPanel
    Left = 577
    Top = 0
    Width = 145
    Height = 320
    Align = alRight
    TabOrder = 1
    object FillBtn: TRnQButton
      Left = 6
      Top = 59
      Width = 132
      Height = 25
      Caption = 'Fill tree'
      TabOrder = 0
      OnClick = Button1Click
    end
    object DelBtn: TRnQButton
      Left = 6
      Top = 107
      Width = 132
      Height = 25
      Caption = 'Delete item'
      TabOrder = 1
      OnClick = DelBtnClick
    end
    object LoadSSIBtn: TRnQButton
      Left = 6
      Top = 16
      Width = 132
      Height = 25
      Caption = 'Load SSI from server'
      TabOrder = 2
      OnClick = LoadSSIBtnClick
    end
    object LoadFileBtn: TRnQButton
      Left = 6
      Top = 224
      Width = 132
      Height = 25
      Caption = 'Load from file'
      TabOrder = 3
      OnClick = LoadFileBtnClick
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 320
    Width = 722
    Height = 116
    Align = alBottom
    TabOrder = 2
    object GroupBox1: TGroupBox
      Left = 369
      Top = 1
      Width = 352
      Height = 114
      Align = alRight
      Caption = 'Extended data hex view'
      TabOrder = 0
      object MemoHexView: TMemo
        Left = 2
        Top = 15
        Width = 348
        Height = 97
        Align = alClient
        TabOrder = 0
      end
    end
  end
  object VTHeaderPopupMenu1: TVTHeaderPopupMenu
    OnPopup = VTHeaderPopupMenu1Popup
    Left = 304
    Top = 24
  end
end
