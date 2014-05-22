object ignoreFr: TignoreFr
  Left = 0
  Top = 0
  ClientHeight = 376
  ClientWidth = 420
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = True
  DesignSize = (
    420
    376)
  PixelsPerInch = 96
  TextHeight = 13
  object ignoreChk: TCheckBox
    Left = 6
    Top = 6
    Width = 97
    Height = 17
    Caption = 'Enabled'
    TabOrder = 0
  end
  object ignoreBox: TListBox
    Left = 6
    Top = 28
    Width = 405
    Height = 229
    Anchors = [akLeft, akTop, akRight, akBottom]
    Columns = 2
    ItemHeight = 13
    MultiSelect = True
    TabOrder = 1
    OnContextPopup = ignoreBoxContextPopup
    OnDragDrop = ignoreBoxDragDrop
    OnDragOver = ignoreBoxDragOver
  end
  object addBtn: TRnQButton
    Left = 8
    Top = 336
    Width = 117
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Add'
    TabOrder = 2
    OnClick = addBtnClick
    ImageName = 'add.contact'
  end
  object removeBtn: TRnQButton
    Left = 152
    Top = 336
    Width = 121
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Remove'
    TabOrder = 3
    OnClick = removeBtnClick
    ImageName = 'delete'
  end
  object PopupMenu: TPopupMenu
    Left = 280
    Top = 176
    object menuviewinfo: TMenuItem
      Caption = 'View info'
      OnClick = menuviewinfoClick
    end
  end
end
