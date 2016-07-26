object securityFr: TsecurityFr
  Left = 0
  Top = 0
  ClientHeight = 340
  ClientWidth = 428
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = True
  PixelsPerInch = 96
  TextHeight = 13
  object cryptGroup: TGroupBox
    Left = 8
    Top = 194
    Width = 321
    Height = 82
    TabOrder = 6
    object histcryptSavePwdChk: TCheckBox
      Left = 23
      Top = 62
      Width = 141
      Height = 17
      HelpKeyword = 'history-crypt-save-password'
      Caption = 'remember password'
      TabOrder = 0
    end
    object histcryptChangeBtn: TRnQButton
      Left = 23
      Top = 23
      Width = 141
      Height = 25
      Caption = 'change password'
      TabOrder = 1
      OnClick = histcryptChangeBtnClick
    end
  end
  object histcryptEnableChk: TCheckBox
    Left = 8
    Top = 194
    Width = 164
    Height = 17
    HelpKeyword = 'history-crypt-enabled'
    Caption = 'History encryption'
    TabOrder = 5
    OnClick = histcryptEnableChkClick
  end
  object dontsavepwdChk: TCheckBox
    Left = 8
    Top = 31
    Width = 321
    Height = 17
    Hint = 
      'If you don'#39't save your password, only who knows the password wil' +
      'l be able to connect.\nPassword is asked only once, so be sure t' +
      'hat you lock or quit R&Q when you'#39're off the screen.'
    HelpKeyword = 'dont-save-password'
    Caption = 'Dont'#39' save password'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 1
    OnClick = dontsavepwdChkClick
  end
  object writeHistoryChk: TCheckBox
    Left = 8
    Top = 8
    Width = 312
    Height = 17
    Caption = 'Save history on disk'
    TabOrder = 0
  end
  object DelHistChk: TCheckBox
    Left = 8
    Top = 171
    Width = 312
    Height = 17
    Caption = 'Delete contacts with history'
    Enabled = False
    TabOrder = 4
    Visible = False
  end
  object MakeBakChk: TCheckBox
    Left = 8
    Top = 125
    Width = 312
    Height = 17
    Caption = 'Make backup for files before write'
    TabOrder = 2
  end
  object AddTempVisMsgChk: TCheckBox
    Left = 8
    Top = 148
    Width = 312
    Height = 17
    Caption = 'Add to temporary visible before send message'
    TabOrder = 3
  end
  object CplPwdChk: TCheckBox
    Left = 16
    Top = 54
    Width = 321
    Height = 17
    Hint = 
      'If you don'#39't save your password, only who knows the password wil' +
      'l be able to connect.\nPassword is asked all time you trying to ' +
      'connect.'
    HelpKeyword = 'clear-password-on-disconnect'
    Caption = 'Clear password after disconnect'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 7
  end
  object AskPassOnBossChk: TCheckBox
    Left = 8
    Top = 77
    Width = 321
    Height = 17
    HelpKeyword = 'ask-password-after-bossmode'
    Caption = 'Ask password before exit from  Boss-mode'
    TabOrder = 8
  end
  object SetAccPassBtn: TRnQButton
    Left = 8
    Top = 282
    Width = 209
    Height = 25
    Caption = 'Set password for account'
    TabOrder = 9
    OnClick = SetAccPassBtnClick
  end
  object HistCryptBtn: TRnQButton
    Left = 8
    Top = 313
    Width = 209
    Height = 25
    Caption = 'Set password for history'
    TabOrder = 10
    OnClick = HistCryptBtnClick
  end
end
