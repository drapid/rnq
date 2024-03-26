object visibilityFrm: TvisibilityFrm
  Left = 15
  Top = 92
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Visibility'
  ClientHeight = 286
  ClientWidth = 504
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  PopupMenu = PMenu3
  OnClose = FormClose
  OnCreate = FormCreate
  OnShow = FormShow
  TextHeight = 13
  object Label1: TLabel
    Left = 0
    Top = 4
    Width = 169
    Height = 18
    Alignment = taCenter
    AutoSize = False
    Caption = 'Invisible list'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clNavy
    Font.Height = -13
    Font.Name = 'Arial'
    Font.Style = [fsBold, fsItalic]
    ParentFont = False
    Transparent = True
  end
  object Label2: TLabel
    Left = 176
    Top = 4
    Width = 161
    Height = 18
    Alignment = taCenter
    AutoSize = False
    Caption = 'Normal list'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clNavy
    Font.Height = -13
    Font.Name = 'Arial'
    Font.Style = [fsBold, fsItalic]
    ParentFont = False
    Transparent = True
  end
  object Label3: TLabel
    Left = 344
    Top = 4
    Width = 161
    Height = 18
    Alignment = taCenter
    AutoSize = False
    Caption = 'Visible list'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clNavy
    Font.Height = -13
    Font.Name = 'Arial'
    Font.Style = [fsBold, fsItalic]
    ParentFont = False
    Transparent = True
  end
  object InvisBox: TVirtualDrawTree
    Left = 0
    Top = 24
    Width = 169
    Height = 233
    DefaultNodeHeight = 16
    Header.AutoSizeIndex = 0
    Header.DefaultHeight = 17
    Header.Height = 13
    Header.MainColumn = -1
    Header.Options = [hoColumnResize, hoDrag]
    PopupMenu = PMenu1
    TabOrder = 0
    TreeOptions.MiscOptions = [toAcceptOLEDrop, toFullRepaintOnResize, toGridExtensions, toInitOnSave, toToggleOnDblClick, toWheelPanning]
    TreeOptions.PaintOptions = [toShowButtons, toShowDropmark, toShowTreeLines, toThemeAware, toUseBlendedImages]
    TreeOptions.SelectionOptions = [toFullRowSelect, toMultiSelect]
    OnClick = invisibleBoxClick
    OnDrawNode = InvisBoxDrawNode
    OnFreeNode = NormalBoxFreeNode
    Touch.InteractiveGestures = [igPan, igPressAndTap]
    Touch.InteractiveGestureOptions = [igoPanSingleFingerHorizontal, igoPanSingleFingerVertical, igoPanInertia, igoPanGutter, igoParentPassthrough]
    Columns = <>
  end
  object NormalBox: TVirtualDrawTree
    Left = 176
    Top = 24
    Width = 161
    Height = 233
    DefaultNodeHeight = 16
    Header.AutoSizeIndex = 0
    Header.DefaultHeight = 17
    Header.Height = 13
    Header.MainColumn = -1
    Header.Options = [hoColumnResize, hoDrag]
    PopupMenu = PMenu2
    TabOrder = 2
    TreeOptions.MiscOptions = [toAcceptOLEDrop, toFullRepaintOnResize, toGridExtensions, toInitOnSave, toToggleOnDblClick, toWheelPanning]
    TreeOptions.PaintOptions = [toShowButtons, toShowDropmark, toShowTreeLines, toThemeAware, toUseBlendedImages]
    TreeOptions.SelectionOptions = [toFullRowSelect, toMultiSelect]
    OnClick = normalBoxClick
    OnDrawNode = InvisBoxDrawNode
    OnFreeNode = NormalBoxFreeNode
    Touch.InteractiveGestures = [igPan, igPressAndTap]
    Touch.InteractiveGestureOptions = [igoPanSingleFingerHorizontal, igoPanSingleFingerVertical, igoPanInertia, igoPanGutter, igoParentPassthrough]
    Columns = <>
  end
  object VisibleBox: TVirtualDrawTree
    Left = 344
    Top = 24
    Width = 161
    Height = 233
    DefaultNodeHeight = 16
    Header.AutoSizeIndex = 0
    Header.DefaultHeight = 17
    Header.Height = 13
    Header.MainColumn = -1
    Header.Options = [hoColumnResize, hoDrag]
    PopupMenu = PMenu3
    TabOrder = 4
    TreeOptions.MiscOptions = [toAcceptOLEDrop, toFullRepaintOnResize, toGridExtensions, toInitOnSave, toToggleOnDblClick, toWheelPanning]
    TreeOptions.PaintOptions = [toShowButtons, toShowDropmark, toShowTreeLines, toThemeAware, toUseBlendedImages]
    TreeOptions.SelectionOptions = [toFullRowSelect, toMultiSelect]
    OnClick = visibleBoxClick
    OnDrawNode = InvisBoxDrawNode
    OnFreeNode = NormalBoxFreeNode
    Touch.InteractiveGestures = [igPan, igPressAndTap]
    Touch.InteractiveGestureOptions = [igoPanSingleFingerHorizontal, igoPanSingleFingerVertical, igoPanInertia, igoPanGutter, igoParentPassthrough]
    Columns = <>
  end
  object move2inv: TRnQButton
    Left = 16
    Top = 263
    Width = 129
    Height = 25
    Caption = 'visibility to invisible'
    ImageName = ''
    TabOrder = 1
    OnClick = move2invClick
  end
  object move2normal: TRnQButton
    Left = 200
    Top = 263
    Width = 121
    Height = 25
    Caption = 'visibility to normal'
    ImageName = ''
    TabOrder = 3
    OnClick = move2normalClick
  end
  object move2vis: TRnQButton
    Left = 368
    Top = 264
    Width = 121
    Height = 25
    Caption = 'visibility to visible'
    ImageName = ''
    TabOrder = 5
    OnClick = move2visClick
  end
  object PMenu1: TPopupMenu
    Left = 120
    Top = 192
    object selectall1: TMenuItem
      Caption = 'Select all'
      OnClick = selectall1Click
    end
  end
  object PMenu2: TPopupMenu
    Left = 272
    Top = 184
    object Selectall2: TMenuItem
      Caption = 'Select all'
      OnClick = Selectall2Click
    end
  end
  object PMenu3: TPopupMenu
    Left = 440
    Top = 200
    object Selectall3: TMenuItem
      Caption = 'Select all'
      OnClick = Selectall3Click
    end
  end
end
