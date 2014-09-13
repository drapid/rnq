object HEventFrm: THEventFrm
  Left = 0
  Top = 0
  Caption = 'HEventFrm'
  ClientHeight = 328
  ClientWidth = 550
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object PageCtl: TPageControl
    Left = 0
    Top = 0
    Width = 550
    Height = 328
    Align = alClient
    DoubleBuffered = True
    OwnerDraw = True
    ParentDoubleBuffered = False
    Style = tsButtons
    TabOrder = 0
  end
  object imgmenu: TPopupMenu
    Left = 264
    Top = 96
    object savePicMnuImg: TMenuItem
      Caption = 'Save pic'
      OnClick = savePicMnuImgClick
    end
  end
end
