object usersFrm: TusersFrm
  Left = 398
  Top = 99
  ActiveControl = UsersBox
  BorderIcons = [biSystemMenu, biMinimize]
  Caption = 'Users'
  ClientHeight = 258
  ClientWidth = 321
  Color = clBtnFace
  Constraints.MaxHeight = 500
  Constraints.MaxWidth = 450
  Constraints.MinHeight = 270
  Constraints.MinWidth = 280
  ParentFont = True
  GlassFrame.Enabled = True
  GlassFrame.Right = 130
  KeyPreview = True
  OldCreateOrder = True
  OnClose = FormClose
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  OnPaint = FormPaint
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object P1: TPanel
    Left = 191
    Top = 0
    Width = 130
    Height = 258
    Align = alRight
    BevelOuter = bvNone
    ParentColor = True
    TabOrder = 1
    object importBtn: TRnQSpeedButton
      Left = 6
      Top = 163
      Width = 35
      Height = 25
      Hint = 'import your data from ICQ'
      Caption = 'Import'
      Enabled = False
      ParentShowHint = False
      ShowHint = True
      ImageName = 'import'
    end
    object deleteaccountBtn: TRnQSpeedButton
      Left = 6
      Top = 132
      Width = 35
      Height = 25
      Hint = 'delete definitely your UIN from the server'
      Caption = 'Delete account'
      Enabled = False
      ParentShowHint = False
      ShowHint = True
      Visible = False
      ImageName = 'delete'
      OnClick = deleteaccountBtnClick
    end
    object PntBox: TPaintBox
      Left = 6
      Top = 127
      Width = 115
      Height = 100
      OnClick = L1Click
      OnMouseEnter = L1MouseEnter
      OnMouseLeave = L1MouseLeave
      OnPaint = PntBoxPaint
    end
    object okBtn: TRnQButton
      Left = 6
      Top = 8
      Width = 115
      Height = 25
      Caption = 'Ok'
      Default = True
      Enabled = False
      ModalResult = 1
      TabOrder = 0
      OnClick = okBtnClick
      ImageName = 'ok'
    end
    object newuserBtn: TRnQButton
      Left = 6
      Top = 39
      Width = 116
      Height = 25
      Hint = 'input your UIN and create a new user'
      Caption = 'New user'
      TabOrder = 1
      OnClick = newuserBtnClick
      ImageName = 'new.user'
    end
    object deleteuserBtn: TRnQButton
      Left = 6
      Top = 70
      Width = 116
      Height = 25
      Hint = 'delete your user from this PC'
      Caption = 'Delete user'
      TabOrder = 2
      OnClick = deleteuserBtnClick
      ImageName = 'delete'
    end
    object newaccountBtn: TRnQButton
      Left = 6
      Top = 101
      Width = 116
      Height = 25
      Hint = 'create a new UIN on the server'
      Caption = 'Get new ICQ account'
      TabOrder = 3
      OnClick = newaccountBtnClick
      ImageName = 'new.account'
    end
  end
  object UsersBox: TVirtualDrawTree
    Left = 0
    Top = 0
    Width = 191
    Height = 258
    Align = alClient
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
    TabOrder = 0
    TreeOptions.MiscOptions = [toAcceptOLEDrop, toFullRepaintOnResize, toGridExtensions, toInitOnSave, toToggleOnDblClick, toWheelPanning]
    TreeOptions.PaintOptions = [toShowButtons, toShowDropmark, toShowTreeLines, toThemeAware, toUseBlendedImages]
    TreeOptions.SelectionOptions = [toFullRowSelect, toMiddleClickSelect, toRightClickSelect]
    OnChecked = UsersBoxChecked
    OnClick = usersBoxClick
    OnCompareNodes = UsersBoxCompareNodes
    OnDblClick = usersBoxDblClick
    OnDrawNode = UsersBoxDrawNode
    OnFocusChanged = UsersBoxFocusChanged
    OnFocusChanging = UsersBoxFocusChanging
    OnFreeNode = UsersBoxFreeNode
    OnKeyDown = FormKeyDown
    OnKeyPress = usersBoxKeyPress
    Columns = <>
  end
end
