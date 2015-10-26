object connectionFr: TconnectionFr
  Left = 0
  Top = 0
  ClientHeight = 400
  ClientWidth = 488
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = True
  DesignSize = (
    488
    400)
  PixelsPerInch = 96
  TextHeight = 13
  object Label9: TLabel
    Left = 340
    Top = 326
    Width = 39
    Height = 13
    Caption = 'seconds'
  end
  object kaChk: TCheckBox
    Left = 6
    Top = 324
    Width = 322
    Height = 17
    HelpKeyword = 'keep-alive'
    Caption = 'Send keep-alive packets each'
    TabOrder = 3
  end
  object proxyGroup: TGroupBox
    Left = 6
    Top = 6
    Width = 439
    Height = 254
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Connection settings'
    TabOrder = 6
    DesignSize = (
      439
      254)
    object ProxyDelBtn: TRnQSpeedButton
      Left = 256
      Top = 20
      Width = 23
      Height = 22
      Flat = True
      ImageName = 'delete'
      OnClick = ProxyDelBtnClick
    end
    object ProxyAddBtn: TRnQSpeedButton
      Left = 227
      Top = 20
      Width = 23
      Height = 22
      Flat = True
      ImageName = 'add'
      OnClick = ProxyAddBtnClick
    end
    object ServerLbl: TLabel
      Left = 22
      Top = 74
      Width = 42
      Height = 21
      AutoSize = False
      BiDiMode = bdRightToLeft
      Caption = 'Server'
      ParentBiDiMode = False
      Transparent = True
      Layout = tlCenter
    end
    object LEProxyName: TLabeledEdit
      Left = 65
      Top = 48
      Width = 251
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      EditLabel.Width = 27
      EditLabel.Height = 13
      EditLabel.Caption = 'Name'
      LabelPosition = lpLeft
      TabOrder = 1
    end
    object ProxyIDBox: TComboBox
      Left = 65
      Top = 21
      Width = 156
      Height = 21
      Style = csDropDownList
      TabOrder = 0
      OnChange = ProxyIDBoxChange
    end
    object ServerCBox: TComboBox
      Left = 65
      Top = 75
      Width = 257
      Height = 21
      TabOrder = 2
    end
    object portBox: TLabeledEdit
      Left = 358
      Top = 75
      Width = 60
      Height = 21
      Anchors = [akTop, akRight]
      EditLabel.Width = 20
      EditLabel.Height = 13
      EditLabel.Caption = 'Port'
      LabelPosition = lpLeft
      TabOrder = 3
      OnChange = portBoxChange
    end
    object GroupBox1: TGroupBox
      Left = 2
      Top = 102
      Width = 432
      Height = 149
      Anchors = [akLeft, akTop, akRight]
      Caption = 'Proxy'
      TabOrder = 4
      DesignSize = (
        432
        149)
      object proxyhostBox: TLabeledEdit
        Left = 63
        Top = 12
        Width = 249
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        EditLabel.Width = 22
        EditLabel.Height = 13
        EditLabel.Caption = 'Host'
        LabelPosition = lpLeft
        TabOrder = 0
      end
      object proxyportBox: TLabeledEdit
        Left = 353
        Top = 12
        Width = 60
        Height = 21
        Anchors = [akTop, akRight]
        EditLabel.Width = 20
        EditLabel.Height = 13
        EditLabel.Caption = 'Port'
        LabelPosition = lpLeft
        TabOrder = 1
        OnChange = portBoxChange
      end
      object authGroup: TGroupBox
        Left = 133
        Top = 51
        Width = 290
        Height = 98
        Anchors = [akLeft, akTop, akRight]
        TabOrder = 4
        DesignSize = (
          290
          98)
        object L6: TLabel
          Left = 22
          Top = 48
          Width = 46
          Height = 13
          Alignment = taRightJustify
          Caption = 'Password'
        end
        object proxyuserBox: TLabeledEdit
          Left = 71
          Top = 18
          Width = 210
          Height = 21
          Anchors = [akLeft, akTop, akRight]
          EditLabel.Width = 22
          EditLabel.Height = 13
          EditLabel.Caption = 'User'
          LabelPosition = lpLeft
          TabOrder = 0
        end
        object proxypwdBox: TEdit
          Left = 71
          Top = 44
          Width = 210
          Height = 22
          Anchors = [akLeft, akTop, akRight]
          Font.Charset = ANSI_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Courier New'
          Font.Style = []
          ParentFont = False
          PasswordChar = '*'
          TabOrder = 1
        end
        object ntlmauth: TCheckBox
          Left = 10
          Top = 73
          Width = 263
          Height = 17
          Caption = 'Use NTLM autentication'
          TabOrder = 2
          OnClick = authChkClick
        end
      end
      object proxyproto: TRadioGroup
        Left = 14
        Top = 51
        Width = 113
        Height = 97
        Caption = 'Type'
        TabOrder = 2
        OnClick = proxyprotoClick
      end
      object authChk: TCheckBox
        Left = 133
        Top = 51
        Width = 153
        Height = 17
        Caption = 'authentication'
        TabOrder = 3
        OnClick = authChkClick
      end
    end
    object SSLChk: TCheckBox
      Left = 310
      Top = 52
      Width = 64
      Height = 17
      Caption = 'SSL'
      TabOrder = 5
    end
    object SaveIPChk: TCheckBox
      Left = 310
      Top = 32
      Width = 97
      Height = 17
      Caption = 'Save IP'
      TabOrder = 6
    end
    object RslvIPChk: TCheckBox
      Left = 310
      Top = 12
      Width = 74
      Height = 17
      Caption = 'Resolve IP'
      TabOrder = 7
    end
  end
  object autoreconnectChk: TCheckBox
    Left = 6
    Top = 266
    Width = 408
    Height = 17
    HelpKeyword = 'auto-reconnect'
    Caption = 'Auto-reconnect (when connection is lost)'
    TabOrder = 0
  end
  object kaSpin: TRnQSpinEdit
    Left = 275
    Top = 324
    Width = 60
    Height = 22
    HelpKeyword = 'keep-alive-freq'
    Decimal = 0
    MaxLength = 3
    MaxValue = 9999.000000000000000000
    MinValue = 1.000000000000000000
    TabOrder = 4
    Value = 9999.000000000000000000
    AsInteger = 9999
  end
  object disconnectedChk: TCheckBox
    Left = 6
    Top = 344
    Width = 408
    Height = 17
    HelpKeyword = 'show-disconnected-dialog'
    Caption = 'Show dialog box when disconnected'
    TabOrder = 5
  end
  object conOnConChk: TCheckBox
    Left = 6
    Top = 304
    Width = 408
    Height = 17
    HelpKeyword = 'connect-on-connection'
    Caption = 'Connect on connection available'
    TabOrder = 2
  end
  object StopRcnctChk: TCheckBox
    Left = 6
    Top = 285
    Width = 396
    Height = 17
    HelpKeyword = 'auto-reconnect-stop'
    Caption = 'Stop reconnecting after login from another place'
    TabOrder = 1
  end
  object PortsLEdit: TLabeledEdit
    Left = 119
    Top = 371
    Width = 295
    Height = 21
    EditLabel.Width = 105
    EditLabel.Height = 13
    EditLabel.Caption = 'Use ports for listening'
    LabelPosition = lpLeft
    TabOrder = 7
  end
end
