object histUtilsFrm: ThistUtilsFrm
  Left = 280
  Top = 71
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSizeToolWin
  Caption = 'History utilities'
  ClientHeight = 374
  ClientWidth = 282
  Color = clBtnFace
  Constraints.MinHeight = 340
  Constraints.MinWidth = 290
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnShow = FormShow
  DesignSize = (
    282
    374)
  PixelsPerInch = 96
  TextHeight = 13
  object loadHistBtn: TRnQSpeedButton
    Left = 8
    Top = 48
    Width = 259
    Height = 22
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Add history from another clients'
    OnClick = loadHistBtnClick
  end
  object loadHist1Btn: TRnQSpeedButton
    Left = 8
    Top = 80
    Width = 259
    Height = 22
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Add history from one contact to another'
    OnClick = loadHist1BtnClick
  end
  object Label1: TLabel
    Left = 16
    Top = 112
    Width = 17
    Height = 13
    Caption = 'Log'
  end
  object Label2: TLabel
    Left = 16
    Top = 0
    Width = 243
    Height = 42
    Alignment = taCenter
    Anchors = [akLeft, akTop, akRight]
    AutoSize = False
    Caption = 
      'Thanks to Basenko Andrey for this functions!\n e-mail: and-basen' +
      'ko@yandex.ru\nICQ UIN: 74835516'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clRed
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    Layout = tlCenter
    WordWrap = True
  end
  object Memo1: TMemo
    Left = 8
    Top = 128
    Width = 267
    Height = 237
    Anchors = [akLeft, akTop, akRight, akBottom]
    ScrollBars = ssVertical
    TabOrder = 0
  end
  object RepHistBtn: TRnQButton
    Left = 80
    Top = 104
    Width = 147
    Height = 25
    Caption = 'Repair bad history files'
    TabOrder = 1
    Visible = False
    OnClick = RepHistBtnClick
  end
end
