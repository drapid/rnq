object automsgFrm: TautomsgFrm
  Left = 310
  Top = 149
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Auto message'
  ClientHeight = 315
  ClientWidth = 192
  Color = clBtnFace
  Constraints.MinWidth = 200
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Position = poMainFormCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnShow = FormShow
  DesignSize = (
    192
    315)
  TextHeight = 13
  object Bevel1: TBevel
    Left = 6
    Top = 120
    Width = 175
    Height = 3
    Anchors = [akLeft, akTop, akRight]
    ExplicitWidth = 193
  end
  object Panel1: TPanel
    Left = 16
    Top = 133
    Width = 157
    Height = 17
    Anchors = [akLeft, akTop, akRight]
    BevelOuter = bvLowered
    Caption = 'predefined messages'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 3
    ExplicitWidth = 169
  end
  object msgBox: TMemo
    Left = 0
    Top = 0
    Width = 185
    Height = 89
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 0
    OnKeyPress = msgBoxKeyPress
    ExplicitWidth = 197
  end
  object popupChk: TCheckBox
    Left = 8
    Top = 281
    Width = 189
    Height = 17
    Anchors = [akLeft, akBottom]
    Caption = 'pop up on status change'
    TabOrder = 8
    ExplicitTop = 290
  end
  object ok2enterChk: TCheckBox
    Left = 8
    Top = 297
    Width = 189
    Height = 17
    Anchors = [akLeft, akBottom]
    Caption = 'ok on double ENTER'
    TabOrder = 9
    OnClick = ok2enterChkClick
    ExplicitTop = 306
  end
  object PredBox: TVirtualDrawTree
    Left = 16
    Top = 152
    Width = 168
    Height = 106
    DefaultNodeHeight = 15
    Header.AutoSizeIndex = 0
    Header.DefaultHeight = 17
    Header.Height = 13
    Header.MainColumn = -1
    Header.Options = [hoColumnResize, hoDrag]
    TabOrder = 4
    TreeOptions.MiscOptions = [toAcceptOLEDrop, toFullRepaintOnResize, toGridExtensions, toInitOnSave, toToggleOnDblClick, toWheelPanning]
    TreeOptions.PaintOptions = [toShowButtons, toShowDropmark, toShowTreeLines, toThemeAware, toUseBlendedImages]
    TreeOptions.SelectionOptions = [toFullRowSelect, toMiddleClickSelect, toRightClickSelect]
    OnChange = PredBoxChange
    OnDrawNode = PredBoxDrawNode
    Touch.InteractiveGestures = [igPan, igPressAndTap]
    Touch.InteractiveGestureOptions = [igoPanSingleFingerHorizontal, igoPanSingleFingerVertical, igoPanInertia, igoPanGutter, igoParentPassthrough]
    Columns = <>
  end
  object nameBox: TEdit
    Left = 15
    Top = 239
    Width = 157
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 5
    Visible = False
    OnKeyPress = nameBoxKeyPress
    ExplicitWidth = 169
  end
  object okBtn: TRnQButton
    Left = 8
    Top = 92
    Width = 83
    Height = 22
    Caption = 'Ok'
    ImageName = 'ok'
    TabOrder = 1
    OnClick = okBtnClick
  end
  object cancelBtn: TRnQButton
    Left = 109
    Top = 92
    Width = 81
    Height = 22
    Caption = 'Cancel'
    ImageName = 'cancel'
    TabOrder = 2
    OnClick = cancelBtnClick
  end
  object saveBtn: TRnQButton
    Left = 16
    Top = 264
    Width = 75
    Height = 20
    Hint = 'add current message to predefined messages'
    Caption = 'Save'
    ImageName = 'save'
    TabOrder = 6
    OnClick = saveBtnClick
  end
  object deleteBtn: TRnQButton
    Left = 109
    Top = 264
    Width = 75
    Height = 20
    Hint = 'delete selected predefined message'
    Caption = 'Delete'
    ImageName = 'delete'
    TabOrder = 7
    OnClick = deleteBtnClick
  end
end
