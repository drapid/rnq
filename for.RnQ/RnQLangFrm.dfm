object FrmLangs: TFrmLangs
  Left = 0
  Top = 0
  Caption = 'Select a language'
  ClientHeight = 274
  ClientWidth = 243
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object LangsBox: TVirtualDrawTree
    Left = 0
    Top = 0
    Width = 243
    Height = 224
    Align = alClient
    Header.AutoSizeIndex = 0
    Header.Font.Charset = DEFAULT_CHARSET
    Header.Font.Color = clWindowText
    Header.Font.Height = -11
    Header.Font.Name = 'Tahoma'
    Header.Font.Style = []
    Header.MainColumn = -1
    Header.Options = [hoColumnResize, hoDrag]
    TabOrder = 0
    TreeOptions.AutoOptions = [toAutoDropExpand, toAutoScrollOnExpand, toAutoSort, toAutoTristateTracking, toAutoDeleteMovedNodes]
    TreeOptions.MiscOptions = [toAcceptOLEDrop, toFullRepaintOnResize, toGridExtensions, toInitOnSave, toToggleOnDblClick, toWheelPanning]
    TreeOptions.PaintOptions = [toShowButtons, toShowDropmark, toShowTreeLines, toThemeAware, toUseBlendedImages]
    TreeOptions.SelectionOptions = [toFullRowSelect, toMiddleClickSelect, toRightClickSelect]
    OnDblClick = LangsBoxDblClick
    OnDrawNode = LangsBoxDrawNode
    OnFocusChanged = LangsBoxFocusChanged
    OnFreeNode = LangsBoxFreeNode
    Columns = <>
  end
  object PnlBtn: TPanel
    Left = 0
    Top = 224
    Width = 243
    Height = 50
    Align = alBottom
    TabOrder = 1
    object BtnOk: TRnQButton
      Left = 22
      Top = 16
      Width = 75
      Height = 25
      Caption = 'Ok'
      Default = True
      ModalResult = 1
      TabOrder = 0
      OnClick = BtnOkClick
      ImageName = 'ok'
    end
    object BtnCncl: TRnQButton
      Left = 136
      Top = 16
      Width = 75
      Height = 25
      Cancel = True
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 1
    end
  end
end
