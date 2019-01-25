object xmppFr: TxmppFr
  Left = 0
  Top = 0
  ClientHeight = 420
  ClientWidth = 512
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = True
  PixelsPerInch = 96
  TextHeight = 13
  object PageControl1: TPageControl
    Left = 0
    Top = 0
    Width = 512
    Height = 420
    ActivePage = TS1
    Align = alClient
    TabOrder = 0
    object TS1: TTabSheet
      Caption = 'XMPP'
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object LPr: TLabel
        Left = 32
        Top = 67
        Width = 34
        Height = 13
        Alignment = taRightJustify
        Caption = 'Priority'
      end
      object PrtySpin: TRnQSpinEdit
        Left = 72
        Top = 64
        Width = 121
        Height = 22
        Decimal = 0
        TabOrder = 0
      end
      object SrvEdit: TLabeledEdit
        Left = 72
        Top = 32
        Width = 121
        Height = 21
        EditLabel.Width = 51
        EditLabel.Height = 13
        EditLabel.Caption = 'Server JID'
        LabelPosition = lpLeft
        TabOrder = 1
      end
    end
    object TSSecurity: TTabSheet
      Caption = 'Security'
      ImageIndex = 1
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      DesignSize = (
        504
        392)
      object Label23: TLabel
        Left = 8
        Top = 8
        Width = 46
        Height = 13
        Alignment = taRightJustify
        Caption = 'Password'
      end
      object pwdBox: TEdit
        Left = 71
        Top = 6
        Width = 343
        Height = 22
        Anchors = [akLeft, akTop, akRight]
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Courier New'
        Font.Style = []
        ParentFont = False
        PasswordChar = '*'
        TabOrder = 0
      end
      object SSLChk: TCheckBox
        Left = 329
        Top = 35
        Width = 53
        Height = 17
        Caption = 'SSL'
        TabOrder = 1
        Visible = False
      end
      object ServerCBox: TComboBox
        Left = 49
        Top = 58
        Width = 257
        Height = 21
        TabOrder = 2
        Visible = False
      end
      object portBox: TLabeledEdit
        Left = 341
        Top = 58
        Width = 60
        Height = 21
        Anchors = [akTop, akRight]
        EditLabel.Width = 20
        EditLabel.Height = 13
        EditLabel.Caption = 'Port'
        LabelPosition = lpLeft
        TabOrder = 3
        Visible = False
      end
    end
  end
end
