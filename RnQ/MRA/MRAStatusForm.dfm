object MRAStatusForm: TMRAStatusForm
  Left = 183
  Top = 307
  BorderStyle = bsToolWindow
  Caption = 'Choose the xStatus...'
  ClientHeight = 296
  ClientWidth = 287
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
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Bevel1: TBevel
    Left = 8
    Top = 36
    Width = 273
    Height = 120
    Shape = bsFrame
    Style = bsRaised
  end
  object xStatusName: TEdit
    Left = 8
    Top = 8
    Width = 177
    Height = 21
    TabOrder = 0
  end
  object XStatusStrMemo: TMemo
    Left = 8
    Top = 160
    Width = 265
    Height = 129
    MaxLength = 255
    TabOrder = 2
    OnChange = XStatusStrMemoChange
  end
  object xSetButton: TRnQButton
    Left = 200
    Top = 5
    Width = 79
    Height = 25
    Caption = 'SET'
    Default = True
    TabOrder = 1
    OnClick = xSetButtonClick
  end
  object SBar: TStatusBar
    Left = 0
    Top = 277
    Width = 287
    Height = 19
    Panels = <
      item
        Width = 100
      end
      item
        Width = 50
      end>
  end
end
