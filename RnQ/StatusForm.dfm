object xStatusForm: TxStatusForm
  Left = 183
  Top = 307
  BorderStyle = bsSizeToolWin
  Caption = 'Choose the xStatus...'
  ClientHeight = 317
  ClientWidth = 255
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsStayOnTop
  KeyPreview = True
  OldCreateOrder = False
  Position = poDesigned
  OnClose = FormClose
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  DesignSize = (
    255
    317)
  PixelsPerInch = 96
  TextHeight = 13
  object Bevel1: TBevel
    Left = 8
    Top = 36
    Width = 240
    Height = 120
    Anchors = [akLeft, akTop, akRight]
    Shape = bsFrame
    Style = bsRaised
  end
  object xStatusName: TEdit
    Left = 8
    Top = 8
    Width = 146
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 0
  end
  object XStatusStrMemo: TMemo
    Left = 8
    Top = 159
    Width = 239
    Height = 114
    Anchors = [akLeft, akTop, akRight, akBottom]
    MaxLength = 255
    TabOrder = 2
    OnChange = XStatusStrMemoChange
  end
  object xSetButton: TRnQButton
    Left = 169
    Top = 5
    Width = 79
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'SET'
    Default = True
    TabOrder = 1
    OnClick = xSetButtonClick
  end
  object SBar: TStatusBar
    Left = 0
    Top = 298
    Width = 255
    Height = 19
    Panels = <
      item
        Width = 100
      end
      item
        Width = 50
      end>
  end
  object OldxStChk: TCheckBox
    AlignWithMargins = True
    Left = 3
    Top = 278
    Width = 249
    Height = 17
    Align = alBottom
    Caption = 'Use old XStatus'
    TabOrder = 4
    OnClick = OldxStChkClick
  end
end
