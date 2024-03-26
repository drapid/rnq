object pluginsFr: TpluginsFr
  Left = 0
  Top = 0
  VertScrollBar.Tracking = True
  ClientHeight = 367
  ClientWidth = 414
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  TextHeight = 13
  object Label1: TLabel
    Left = 6
    Top = 6
    Width = 66
    Height = 13
    Caption = 'Found plugins'
  end
  object reloadBtn: TRnQButton
    Left = 8
    Top = 288
    Width = 121
    Height = 25
    Caption = '&Reload'
    ImageName = 'refresh'
    TabOrder = 0
    OnClick = reloadBtnClick
  end
  object prefBtn: TRnQButton
    Left = 144
    Top = 288
    Width = 113
    Height = 25
    Caption = '&Preferences'
    ImageName = 'preferences'
    TabOrder = 1
    OnClick = prefBtnClick
  end
  object PluginsList: TVirtualDrawTree
    Left = 8
    Top = 25
    Width = 385
    Height = 255
    DragType = dtVCL
    Header.AutoSizeIndex = 0
    Header.DefaultHeight = 17
    Header.Height = 17
    Header.Options = [hoColumnResize, hoDrag, hoVisible]
    TabOrder = 2
    TreeOptions.MiscOptions = [toAcceptOLEDrop, toCheckSupport, toFullRepaintOnResize, toInitOnSave, toToggleOnDblClick, toWheelPanning]
    TreeOptions.PaintOptions = [toShowButtons, toShowDropmark, toShowTreeLines, toThemeAware, toUseBlendedImages]
    TreeOptions.SelectionOptions = [toFullRowSelect]
    OnDrawNode = PluginsListDrawNode
    OnFreeNode = PluginsListFreeNode
    Touch.InteractiveGestures = [igPan, igPressAndTap]
    Touch.InteractiveGestureOptions = [igoPanSingleFingerHorizontal, igoPanSingleFingerVertical, igoPanInertia, igoPanGutter, igoParentPassthrough]
    Columns = <
      item
        Position = 0
        Text = 'Name'
        Width = 220
      end
      item
        Position = 1
        Text = 'Filename'
        Width = 150
      end>
  end
end
