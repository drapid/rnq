object authreqFrm: TauthreqFrm
  Left = 162
  Top = 156
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'authorization request'
  ClientHeight = 195
  ClientWidth = 434
  Color = clBtnFace
  Constraints.MinHeight = 221
  Constraints.MinWidth = 440
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = True
  OnClose = FormClose
  OnPaint = FormPaint
  OnShow = FormShow
  DesignSize = (
    434
    195)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 5
    Top = 0
    Width = 421
    Height = 33
    AutoSize = False
    Caption = 'auth desc'
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Times New Roman'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
    WordWrap = True
  end
  object Label2: TLabel
    Left = 25
    Top = 175
    Width = 133
    Height = 13
    Anchors = [akLeft, akBottom]
    Caption = 'Close this window after reply'
    FocusControl = closeChk
    Transparent = True
    OnClick = Label2Click
    ExplicitTop = 186
  end
  object msgBox: TMemo
    Left = 5
    Top = 33
    Width = 280
    Height = 97
    Anchors = [akLeft, akTop, akRight, akBottom]
    ScrollBars = ssVertical
    TabOrder = 0
  end
  object closeChk: TCheckBox
    Left = 8
    Top = 174
    Width = 16
    Height = 17
    HelpKeyword = 'close-auth-after-reply'
    Anchors = [akLeft, akBottom]
    TabOrder = 1
    OnClick = closeChkClick
  end
  object AuthBtn: TRnQButton
    Left = 291
    Top = 35
    Width = 136
    Height = 26
    Anchors = [akTop, akRight]
    Caption = '&Authorize'
    ImageName = 'auth.grant'
    TabOrder = 2
    OnClick = authBtnClick
  end
  object noBtn: TRnQButton
    Left = 291
    Top = 67
    Width = 136
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'No'
    ImageName = 'cancel'
    TabOrder = 3
    OnClick = noBtnClick
  end
  object reasonBtn: TRnQButton
    Left = 291
    Top = 98
    Width = 136
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'No with &Reason'
    ImageName = ''
    TabOrder = 4
    OnClick = reasonBtnClick
  end
  object viewinfoBtn: TRnQButton
    Left = 291
    Top = 136
    Width = 135
    Height = 33
    Anchors = [akLeft, akBottom]
    Caption = 'View info'
    ImageName = 'info'
    TabOrder = 5
    OnClick = viewinfoBtnClick
  end
  object sendBtn: TRnQButton
    Left = 139
    Top = 136
    Width = 146
    Height = 33
    Anchors = [akLeft, akBottom]
    Caption = 'Send message'
    ImageName = 'msg'
    TabOrder = 6
    OnClick = sendBtnClick
  end
  object addBtn: TRnQButton
    Left = 5
    Top = 136
    Width = 128
    Height = 33
    Anchors = [akLeft, akBottom]
    Caption = 'Add to contact list'
    ImageName = 'add.contact'
    TabOrder = 7
    OnClick = addBtnClick
  end
  object addmenu: TPopupMenu
    Left = 105
    Top = 144
  end
end
