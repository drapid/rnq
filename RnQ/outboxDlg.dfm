object outboxFrm: ToutboxFrm
  Left = 241
  Top = 198
  Caption = 'Outbox'
  ClientHeight = 367
  ClientWidth = 551
  Color = clBtnFace
  Font.Charset = RUSSIAN_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  GlassFrame.Enabled = True
  GlassFrame.Bottom = 40
  OldCreateOrder = True
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnResize = FormResize
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 551
    Height = 328
    Align = alClient
    BevelOuter = bvNone
    BorderWidth = 5
    TabOrder = 0
    object Splitter2: TSplitter
      Left = 145
      Top = 5
      Width = 5
      Height = 318
      ExplicitLeft = 150
      ExplicitHeight = 322
    end
    object Panel3: TPanel
      Left = 150
      Top = 5
      Width = 396
      Height = 318
      Align = alClient
      BevelOuter = bvNone
      TabOrder = 0
      object memo: TMemo
        Left = 0
        Top = 105
        Width = 396
        Height = 213
        Align = alClient
        Lines.Strings = (
          'memo')
        ReadOnly = True
        ScrollBars = ssVertical
        TabOrder = 0
        OnChange = memoChange
      end
      object Panel4: TPanel
        Left = 0
        Top = 0
        Width = 396
        Height = 105
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 1
        object groupbox: TGroupBox
          Left = 0
          Top = 0
          Width = 396
          Height = 84
          Align = alTop
          Caption = 'Additional info'
          TabOrder = 0
          object charsLbl: TLabel
            Left = 5
            Top = 16
            Width = 6
            Height = 13
            Caption = '_'
          end
          object infoLbl: TLabel
            Left = 5
            Top = 40
            Width = 6
            Height = 13
            Caption = '_'
          end
        end
        object processChk00: TCheckBox
          Left = 0
          Top = 87
          Width = 185
          Height = 17
          Caption = 'Process messages when possible'
          Checked = True
          State = cbChecked
          TabOrder = 1
          OnClick = processChk00Click
        end
      end
    end
    object list: TVirtualDrawTree
      Left = 5
      Top = 5
      Width = 140
      Height = 318
      Align = alLeft
      Header.AutoSizeIndex = 0
      Header.DefaultHeight = 17
      Header.Height = 17
      Header.MainColumn = -1
      Header.Options = [hoColumnResize, hoDrag]
      PopupMenu = menu
      TabOrder = 1
      TreeOptions.MiscOptions = [toAcceptOLEDrop, toFullRepaintOnResize, toGridExtensions, toInitOnSave, toToggleOnDblClick, toWheelPanning]
      TreeOptions.PaintOptions = [toShowButtons, toShowDropmark, toShowTreeLines, toThemeAware, toUseBlendedImages]
      TreeOptions.SelectionOptions = [toFullRowSelect, toMiddleClickSelect, toRightClickSelect]
      OnChange = listChange
      OnDrawNode = listDrawNode
      Columns = <>
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 328
    Width = 551
    Height = 39
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    DesignSize = (
      551
      39)
    object Bevel: TBevel
      Left = 5
      Top = 0
      Width = 541
      Height = 3
      Anchors = [akLeft, akTop, akRight]
      Shape = bsBottomLine
    end
    object deleteBtn: TRnQButton
      Left = 5
      Top = 9
      Width = 76
      Height = 25
      Anchors = [akLeft, akBottom]
      Caption = 'Delete'
      Enabled = False
      ImageName = 'delete'
      TabOrder = 0
      OnClick = deleteBtnClick
    end
    object saveBtn: TRnQButton
      Left = 104
      Top = 9
      Width = 81
      Height = 25
      Anchors = [akLeft, akBottom]
      Caption = 'Save'
      Enabled = False
      ImageName = 'save'
      TabOrder = 1
      OnClick = saveBtnClick
    end
    object closeBtn: TRnQButton
      Left = 456
      Top = 9
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Cancel = True
      Caption = 'Close'
      ImageName = 'close'
      ModalResult = 2
      TabOrder = 2
      OnClick = closeBtnClick
    end
  end
  object menu: TPopupMenu
    OnPopup = menuPopup
    Left = 96
    Top = 80
    object Sendmsg1: TMenuItem
      Tag = -37
      Caption = 'Send now'
      OnClick = Sendmsg1Click
    end
    object Viewinfo1: TMenuItem
      Tag = 25
      Caption = 'View info'
      OnClick = Viewinfo1Click
    end
  end
end
