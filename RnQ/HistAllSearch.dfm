object AllHistSrchForm: TAllHistSrchForm
  Left = 0
  Top = 0
  Caption = 'Search in all history files'
  ClientHeight = 398
  ClientWidth = 325
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnShow = FormShow
  DesignSize = (
    325
    398)
  PixelsPerInch = 96
  TextHeight = 13
  object SearchEdit: TLabeledEdit
    Left = 16
    Top = 24
    Width = 294
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    EditLabel.Width = 70
    EditLabel.Height = 13
    EditLabel.Caption = 'Text to search'
    TabOrder = 0
  end
  object caseChk: TCheckBox
    Left = 16
    Top = 51
    Width = 97
    Height = 17
    Caption = 'Case sensitive'
    TabOrder = 1
  end
  object reChk: TCheckBox
    Left = 176
    Top = 51
    Width = 76
    Height = 17
    Caption = 'Reg.Exp.'
    TabOrder = 2
  end
  object RoasterChk: TCheckBox
    Left = 16
    Top = 74
    Width = 257
    Height = 17
    Caption = 'Only in contact-list'
    TabOrder = 3
  end
  object SchBtn: TRnQButton
    Left = 16
    Top = 97
    Width = 294
    Height = 25
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Search'
    Default = True
    TabOrder = 4
    OnClick = SchBtnClick
  end
  object HistPosTree: TVirtualDrawTree
    Left = 16
    Top = 128
    Width = 294
    Height = 262
    Anchors = [akLeft, akTop, akRight, akBottom]
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
    TabOrder = 5
    OnDblClick = HistPosTreeDblClick
    OnDrawNode = HistPosTreeDrawNode
    OnFreeNode = HistPosTreeFreeNode
    OnGetNodeWidth = HistPosTreeGetNodeWidth
    OnKeyPress = HistPosTreeKeyPress
    Columns = <>
  end
end
