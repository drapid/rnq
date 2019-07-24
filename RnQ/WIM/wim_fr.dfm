object WIMFr: TWIMFr
  Left = 0
  Top = 0
  ClientHeight = 401
  ClientWidth = 425
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = True
  PixelsPerInch = 96
  TextHeight = 13
  object plBg: TPanel
    Left = 0
    Top = 0
    Width = 425
    Height = 401
    Align = alClient
    BevelOuter = bvNone
    BorderWidth = 6
    TabOrder = 0
    object O: TPageControl
      Left = 6
      Top = 6
      Width = 413
      Height = 389
      ActivePage = TS1
      Align = alClient
      TabOrder = 0
      object TS1: TTabSheet
        Caption = 'WIM'
        DesignSize = (
          405
          361)
        object birthGrp: TRadioGroup
          Left = 6
          Top = 245
          Width = 381
          Height = 60
          Anchors = [akLeft, akTop, akRight]
          Caption = 'Show the birthday balloon icon to people'
          Columns = 2
          Items.Strings = (
            'Never'
            'Always'
            'On my birtday'
            '')
          TabOrder = 7
          OnClick = UpdVis
        end
        object bdayBox: TDateTimePicker
          Left = 250
          Top = 278
          Width = 114
          Height = 22
          Anchors = [akTop, akRight]
          Date = 37466.000000000000000000
          Time = 0.562277013901621100
          TabOrder = 8
        end
        object addedYouChk: TCheckBox
          Left = 6
          Top = 6
          Width = 384
          Height = 17
          Hint = 
            'If you add someone to your list, he will receive a notification ' +
            'about it.'
          Caption = 'Send the "i added you" message when adding contacts'
          ParentShowHint = False
          ShowHint = True
          TabOrder = 0
        end
        object clientidChk: TCheckBox
          Left = 6
          Top = 24
          Width = 318
          Height = 17
          Caption = 'Show client identifier'
          TabOrder = 1
        end
        object webawareChk: TCheckBox
          Left = 6
          Top = 43
          Width = 318
          Height = 17
          Caption = 'Webaware (enable status indicators on the web)'
          TabOrder = 3
        end
        object visibilityexploitChk: TCheckBox
          Left = 6
          Top = 62
          Width = 381
          Height = 17
          Caption = 'Warn me when someone uses visibility exploit on me'
          TabOrder = 5
        end
        object authNeededChk: TCheckBox
          Left = 6
          Top = 81
          Width = 372
          Height = 17
          Caption = 'My authorization is required before people add me to their lists'
          TabOrder = 6
        end
        object ProtVerCBox: TComboBox
          Left = 338
          Top = 21
          Width = 46
          Height = 21
          AutoDropDown = True
          AutoCloseUp = True
          Style = csDropDownList
          DropDownCount = 2
          ItemIndex = 0
          TabOrder = 2
          Text = '9'
          Visible = False
          Items.Strings = (
            '9'
            '10')
        end
        object TestWWBtn: TRnQButton
          Left = 300
          Top = 40
          Width = 75
          Height = 25
          Caption = 'test it'
          TabOrder = 4
          OnClick = SpeedButton1Click
        end
        object useSSIChk: TCheckBox
          Left = 6
          Top = 306
          Width = 396
          Height = 17
          Caption = 'Use server-side contact list (need reconnect)'
          TabOrder = 9
          OnClick = UpdVis
        end
        object PrivacyGrp: TRadioGroup
          Left = 3
          Top = 104
          Width = 381
          Height = 66
          Anchors = [akLeft, akTop, akRight]
          Caption = 'Share details'
          Items.Strings = (
            'Everybody'
            
              'Share E-Mail and phone only with contacts. The rest with everybo' +
              'dy'
            'Only contacts')
          TabOrder = 10
        end
        object UseLSIChk: TCheckBox
          Left = 9
          Top = 338
          Width = 381
          Height = 17
          Caption = 'Work with local contacts'
          TabOrder = 11
        end
        object ShowInvChk: TCheckBox
          Left = 9
          Top = 322
          Width = 393
          Height = 17
          Caption = 'Show invisible status (when use ssi)'
          TabOrder = 12
        end
      end
      object SecTS: TTabSheet
        Caption = 'Security'
        ImageIndex = 4
        DesignSize = (
          405
          361)
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
          Width = 331
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
        object LoginRG: TRadioGroup
          Left = 6
          Top = 77
          Width = 144
          Height = 68
          Anchors = [akLeft, akTop, akRight]
          Caption = 'Login'
          Items.Strings = (
            'Simple'
            'MD5')
          TabOrder = 1
        end
      end
      object AddTrafTB: TTabSheet
        Caption = 'Add traffic'
        ImageIndex = 1
        DesignSize = (
          405
          361)
        object CapsLabel: TLabel
          Left = 19
          Top = 341
          Width = 3
          Height = 13
          ShowAccelChar = False
        end
        object GBTyping: TGroupBox
          Left = 6
          Top = 61
          Width = 381
          Height = 70
          Anchors = [akLeft, akTop, akRight]
          TabOrder = 2
          object Label2: TLabel
            Left = 280
            Top = 38
            Width = 65
            Height = 21
            AutoSize = False
            Caption = 'seconds'
            Layout = tlCenter
          end
          object Label3: TLabel
            Left = 40
            Top = 38
            Width = 161
            Height = 21
            Alignment = taRightJustify
            AutoSize = False
            Caption = 'Typing idle interval'
            Layout = tlCenter
          end
          object ChkSendTyping: TCheckBox
            Left = 10
            Top = 20
            Width = 297
            Height = 17
            Caption = 'Send Typing'
            TabOrder = 0
          end
          object MTNIdleSpin: TRnQSpinEdit
            Left = 210
            Top = 38
            Width = 66
            Height = 22
            Decimal = 0
            MaxLength = 3
            MaxValue = 3600.000000000000000000
            TabOrder = 1
            Value = 5.000000000000000000
            AsInteger = 5
          end
        end
        object GBInvis: TGroupBox
          Left = 6
          Top = 135
          Width = 381
          Height = 134
          Anchors = [akLeft, akTop, akRight]
          TabOrder = 4
          Visible = False
          object Label1: TLabel
            Left = 280
            Top = 19
            Width = 65
            Height = 21
            AutoSize = False
            Caption = 'seconds'
            Layout = tlCenter
          end
          object Label4: TLabel
            Left = 280
            Top = 46
            Width = 65
            Height = 21
            AutoSize = False
            Caption = 'seconds'
            Layout = tlCenter
          end
          object Label5: TLabel
            Left = 140
            Top = 46
            Width = 65
            Height = 21
            AutoSize = False
            BiDiMode = bdRightToLeft
            Caption = 'interval'
            ParentBiDiMode = False
            Layout = tlCenter
          end
          object ChkinvisCheck: TCheckBox
            Left = 10
            Top = 18
            Width = 198
            Height = 21
            Caption = 'Check status every'
            TabOrder = 0
          end
          object CheckInvisSpin: TRnQSpinEdit
            Left = 210
            Top = 23
            Width = 66
            Height = 22
            Decimal = 0
            MaxLength = 3
            MaxValue = 3600.000000000000000000
            TabOrder = 1
            Value = 30.000000000000000000
            AsInteger = 30
          end
          object ChkInvisSend: TCheckBox
            Left = 10
            Top = 70
            Width = 350
            Height = 21
            Caption = 'Check when send offline'
            TabOrder = 4
          end
          object ChkInvisGoOfl: TCheckBox
            Left = 10
            Top = 88
            Width = 350
            Height = 21
            Caption = 'Check when go offline'
            TabOrder = 5
          end
          object ShwOfflBox: TCheckBox
            Left = 10
            Top = 107
            Width = 335
            Height = 22
            Caption = 'Show message about offline'
            TabOrder = 6
          end
          object ChkIntervSpin: TRnQSpinEdit
            Left = 210
            Top = 47
            Width = 66
            Height = 22
            Decimal = 1
            MaxLength = 2
            Increment = 0.100000000000000000
            MaxValue = 20.000000000000000000
            TabOrder = 3
            ValueType = vtFloat
            Value = 3.000000000000000000
            AsInteger = 3
          end
          object ChkInvisRG: TRadioGroup
            Left = 232
            Top = 72
            Width = 146
            Height = 59
            Caption = 'Method'
            ItemIndex = 0
            Items.Strings = (
              'Request status')
            TabOrder = 7
            Visible = False
          end
          object SBSelInvisCl: TRnQButton
            Left = 10
            Top = 44
            Width = 121
            Height = 25
            Caption = 'Select contacts'
            TabOrder = 2
            OnClick = SBSelInvisClClick
          end
        end
        object ChkSupInvChk: TCheckBox
          Left = 7
          Top = 134
          Width = 16
          Height = 16
          TabOrder = 3
          OnClick = UpdVis
          OnKeyUp = UpdVis1
        end
        object ChkTyping: TCheckBox
          Left = 7
          Top = 60
          Width = 16
          Height = 16
          TabOrder = 1
          OnClick = UpdVis
          OnKeyUp = UpdVis1
        end
        object AutoReqXStChk: TCheckBox
          Left = 6
          Top = 270
          Width = 376
          Height = 17
          Caption = 'Auto request XStatus'
          TabOrder = 5
        end
        object MsgCryptChk: TCheckBox
          Left = 6
          Top = 40
          Width = 381
          Height = 17
          Caption = 'Encrypt messages'
          TabOrder = 0
        end
        object CapEdit: TMaskEdit
          Left = 16
          Top = 307
          Width = 284
          Height = 21
          CharCase = ecUpperCase
          EditMask = 
            '>aa\ aa\ aa\ aa\ aa\ aa\ aa\ aa\ aa\ aa\ aa\ aa\ aa\ aa\ aa\ aa;' +
            '0;_'
          MaxLength = 47
          TabOrder = 7
          Text = ''
          OnChange = CapEditChange
        end
        object AddCapsBtn: TRnQButton
          Left = 308
          Top = 305
          Width = 86
          Height = 25
          Caption = 'Add defined'
          TabOrder = 8
          OnClick = AddCapsBtnClick
          ImageName = 'add'
        end
        object AddCapsChk: TCheckBox
          Left = 6
          Top = 288
          Width = 276
          Height = 17
          Caption = 'Add client capability'
          TabOrder = 6
          OnClick = UpdVis
        end
        object XMPPChk: TCheckBox
          Left = 216
          Top = 341
          Width = 166
          Height = 17
          Caption = 'Support XMPP contacts'
          TabOrder = 9
        end
      end
      object AvatarsTS: TTabSheet
        Caption = 'Avatars'
        ImageIndex = 2
        object AvatarGrp: TGroupBox
          Left = 6
          Top = 17
          Width = 399
          Height = 118
          TabOrder = 1
          object AvtAutLoadChk: TCheckBox
            Left = 8
            Top = 14
            Width = 350
            Height = 17
            Caption = 'Auto load avatars'
            TabOrder = 0
          end
          object AvtAutGetChk: TCheckBox
            Left = 8
            Top = 37
            Width = 200
            Height = 17
            Caption = 'Auto get flash-avatars'
            TabOrder = 1
          end
          object CheckBox1: TCheckBox
            Left = 8
            Top = 83
            Width = 210
            Height = 17
            Caption = 'Max size of downloaded avatars, kB'
            Enabled = False
            TabOrder = 3
            Visible = False
          end
          object RnQSpinEdit1: TRnQSpinEdit
            Left = 224
            Top = 81
            Width = 121
            Height = 22
            Enabled = False
            Decimal = 0
            TabOrder = 4
            Visible = False
          end
          object NotDnlddInfoChk: TCheckBox
            Left = 8
            Top = 60
            Width = 350
            Height = 17
            Caption = 'Info about not downloaded avatars'
            TabOrder = 2
          end
        end
        object SupAvtChk: TCheckBox
          Left = 6
          Top = 6
          Width = 196
          Height = 17
          Caption = 'Support avatars'
          TabOrder = 0
          OnClick = UpdVis
          OnKeyUp = UpdVis1
        end
      end
      object FileTrTS: TTabSheet
        Caption = 'File transfer'
        ImageIndex = 3
        TabVisible = False
        object FTPortsEdit: TLabeledEdit
          Left = 64
          Top = 16
          Width = 265
          Height = 21
          EditLabel.Width = 25
          EditLabel.Height = 13
          EditLabel.Caption = 'Ports'
          LabelPosition = lpLeft
          LabelSpacing = 6
          TabOrder = 0
        end
      end
    end
  end
  object CapsPpp: TPopupMenu
    Left = 336
    Top = 320
  end
end
