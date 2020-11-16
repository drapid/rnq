object viewinfoFrm: TviewinfoFrm
  Left = 245
  Top = 141
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'view info'
  ClientHeight = 456
  ClientWidth = 432
  Color = clBtnFace
  ParentFont = True
  KeyPreview = True
  OldCreateOrder = True
  Position = poDesigned
  OnClose = FormClose
  OnCreate = FormCreate
  OnKeyPress = FormKeyPress
  OnPaint = FormPaint
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object pagectrl: TPageControl
    Left = 0
    Top = 33
    Width = 432
    Height = 423
    ActivePage = mainSheet
    Align = alClient
    TabOrder = 0
    OnChange = pagectrlChange
    object mainSheet: TTabSheet
      Caption = '&Main'
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object Label7: TLabel
        Left = 3
        Top = 264
        Width = 29
        Height = 13
        Caption = 'About'
        Transparent = True
        Visible = False
      end
      object Label2: TLabel
        Left = 39
        Top = 92
        Width = 35
        Height = 13
        Alignment = taRightJustify
        Caption = 'Gender'
        Transparent = True
      end
      object Label13: TLabel
        Left = 221
        Top = 92
        Width = 56
        Height = 13
        Alignment = taRightJustify
        Caption = 'Language 1'
        Transparent = True
      end
      object Label17: TLabel
        Left = 221
        Top = 115
        Width = 56
        Height = 13
        Alignment = taRightJustify
        Caption = 'Language 2'
        Transparent = True
      end
      object Label18: TLabel
        Left = 221
        Top = 138
        Width = 56
        Height = 13
        Alignment = taRightJustify
        Caption = 'Language 3'
        Transparent = True
      end
      object Label20: TLabel
        Left = 326
        Top = 222
        Width = 21
        Height = 13
        Alignment = taRightJustify
        Caption = 'GMT'
        Transparent = True
      end
      object mailBtn: TRnQSpeedButton
        Left = 197
        Top = 59
        Width = 20
        Height = 20
        Hint = 'Send an e-mail'
        Flat = True
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
        ParentShowHint = False
        ShowHint = True
        OnClick = mailBtnClick
      end
      object XstatusBtn: TRnQSpeedButton
        Left = 396
        Top = 257
        Width = 23
        Height = 22
        Hint = 'Read XStatus'
        Flat = True
        OnClick = XstatusBtnClick
      end
      object StatusBtn: TRnQSpeedButton
        Left = 195
        Top = 218
        Width = 22
        Height = 20
        Hint = 'Status'
        Flat = True
        OnClick = StatusBtnClick
      end
      object Label3: TLabel
        Left = 0
        Top = 116
        Width = 71
        Height = 21
        Alignment = taRightJustify
        AutoSize = False
        Caption = 'Marital status'
        Layout = tlCenter
      end
      object birthageLbl: TLabel
        Left = 52
        Top = 168
        Width = 19
        Height = 13
        Alignment = taRightJustify
        Caption = 'Age'
        Transparent = True
      end
      object aboutBox: TMemo
        AlignWithMargins = True
        Left = 3
        Top = 280
        Width = 418
        Height = 112
        Align = alBottom
        MaxLength = 480
        ScrollBars = ssVertical
        TabOrder = 21
      end
      object genderBox: TComboBox
        Left = 77
        Top = 88
        Width = 140
        Height = 21
        Style = csDropDownList
        TabOrder = 6
      end
      object lang1Box: TComboBox
        Left = 281
        Top = 88
        Width = 140
        Height = 21
        Style = csDropDownList
        Sorted = True
        TabOrder = 9
      end
      object lang2Box: TComboBox
        Left = 281
        Top = 111
        Width = 140
        Height = 21
        Style = csDropDownList
        Sorted = True
        TabOrder = 10
      end
      object lang3Box: TComboBox
        Left = 281
        Top = 134
        Width = 140
        Height = 21
        Style = csDropDownList
        Sorted = True
        TabOrder = 11
      end
      object smsChk: TCheckBox
        Left = 220
        Top = 191
        Width = 188
        Height = 17
        Caption = 'SMS-able'
        TabOrder = 17
      end
      object nickBox: TLabeledEdit
        Left = 281
        Top = 3
        Width = 140
        Height = 21
        EditLabel.Width = 19
        EditLabel.Height = 13
        EditLabel.Caption = 'Nick'
        LabelPosition = lpLeft
        ReadOnly = True
        TabOrder = 1
      end
      object lastBox: TLabeledEdit
        Left = 281
        Top = 32
        Width = 140
        Height = 21
        EditLabel.Width = 49
        EditLabel.Height = 13
        EditLabel.Caption = 'Last name'
        LabelPosition = lpLeft
        ReadOnly = True
        TabOrder = 3
      end
      object firstBox: TLabeledEdit
        Left = 77
        Top = 31
        Width = 140
        Height = 21
        EditLabel.Width = 50
        EditLabel.Height = 13
        EditLabel.Caption = 'First name'
        LabelPosition = lpLeft
        ReadOnly = True
        TabOrder = 2
      end
      object emailBox: TLabeledEdit
        Left = 77
        Top = 58
        Width = 115
        Height = 21
        EditLabel.Width = 28
        EditLabel.Height = 13
        EditLabel.Caption = 'E-mail'
        LabelPosition = lpLeft
        ReadOnly = True
        TabOrder = 4
      end
      object displayBox: TLabeledEdit
        Left = 77
        Top = 3
        Width = 140
        Height = 21
        EditLabel.Width = 46
        EditLabel.Height = 13
        EditLabel.Caption = 'Displayed'
        LabelPosition = lpLeft
        ReadOnly = True
        TabOrder = 0
      end
      object uinBox: TLabeledEdit
        Left = 281
        Top = 59
        Width = 140
        Height = 21
        EditLabel.Width = 18
        EditLabel.Height = 13
        EditLabel.Caption = 'UIN'
        LabelPosition = lpLeft
        ReadOnly = True
        TabOrder = 5
      end
      object statusBox: TLabeledEdit
        Left = 77
        Top = 219
        Width = 115
        Height = 21
        EditLabel.Width = 31
        EditLabel.Height = 13
        EditLabel.Caption = 'Status'
        EditLabel.OnDblClick = statusBoxSubLabelDblClick
        LabelPosition = lpLeft
        ReadOnly = True
        TabOrder = 8
      end
      object timeBox: TLabeledEdit
        Left = 279
        Top = 219
        Width = 38
        Height = 21
        EditLabel.Width = 36
        EditLabel.Height = 13
        EditLabel.Caption = 'his time'
        LabelPosition = lpLeft
        ReadOnly = True
        TabOrder = 18
      end
      object cellularBox: TLabeledEdit
        Left = 77
        Top = 192
        Width = 140
        Height = 21
        EditLabel.Width = 35
        EditLabel.Height = 13
        EditLabel.Caption = 'Cellular'
        LabelPosition = lpLeft
        ReadOnly = True
        TabOrder = 16
      end
      object birthBox: TDateTimePicker
        Left = 220
        Top = 165
        Width = 92
        Height = 21
        Date = 39050.000000000000000000
        Time = 0.677962962960009500
        TabOrder = 13
        OnChange = birthBoxChange
      end
      object ageSpin: TRnQSpinEdit
        Left = 219
        Top = 165
        Width = 55
        Height = 22
        Decimal = 0
        MaxValue = 120.000000000000000000
        MinValue = 13.000000000000000000
        TabOrder = 12
        Value = 13.000000000000000000
        AsInteger = 13
        OnChange = OnlyDigitChange
      end
      object xstatusBox: TLabeledEdit
        Left = 77
        Top = 249
        Width = 313
        Height = 21
        EditLabel.Width = 37
        EditLabel.Height = 13
        EditLabel.Caption = 'XStatus'
        LabelPosition = lpLeft
        ReadOnly = True
        TabOrder = 20
      end
      object BirthLBox: TDateTimePicker
        Left = 336
        Top = 165
        Width = 85
        Height = 21
        Date = 38421.000000000000000000
        Format = 'dd.MM.yyyy'
        Time = 0.660487349538016100
        TabOrder = 15
        OnChange = birthBoxChange
      end
      object BirthLChk: TCheckBox
        Left = 314
        Top = 167
        Width = 18
        Height = 17
        Alignment = taLeftJustify
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
        TabOrder = 14
        OnClick = BirthLChkClick
        OnKeyPress = BirthLChkKeyPress
      end
      object gmtBox: TComboBox
        Left = 353
        Top = 219
        Width = 66
        Height = 21
        Style = csDropDownList
        TabOrder = 19
      end
      object MarStsBox: TComboBox
        Left = 77
        Top = 116
        Width = 140
        Height = 21
        Style = csDropDownList
        TabOrder = 7
      end
      object birthageBox: TComboBox
        Left = 77
        Top = 165
        Width = 140
        Height = 21
        Style = csDropDownList
        TabOrder = 22
        OnChange = birthageBoxChange
        Items.Strings = (
          'Not specified'
          'Birthday'
          'Age')
      end
    end
    object HomeTS: TTabSheet
      Caption = 'Home'
      ImageIndex = 7
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object Label14: TLabel
        Left = 34
        Top = 153
        Width = 39
        Height = 13
        Alignment = taRightJustify
        Caption = 'Country'
        Transparent = True
      end
      object homepageBox: TLabeledEdit
        Left = 8
        Top = 23
        Width = 336
        Height = 21
        EditLabel.Width = 51
        EditLabel.Height = 13
        EditLabel.Caption = 'Homepage'
        ReadOnly = True
        TabOrder = 0
      end
      object goBtn: TRnQButton
        Left = 353
        Top = 21
        Width = 71
        Height = 25
        Hint = 'Open this address'
        Caption = 'GO'
        ImageName = ''
        TabOrder = 1
        OnClick = goBtnClick
      end
      object cityBox: TLabeledEdit
        Left = 77
        Top = 88
        Width = 267
        Height = 21
        EditLabel.Width = 19
        EditLabel.Height = 13
        EditLabel.Caption = 'City'
        LabelPosition = lpLeft
        LabelSpacing = 6
        ReadOnly = True
        TabOrder = 2
      end
      object stateBox: TLabeledEdit
        Left = 77
        Top = 118
        Width = 267
        Height = 21
        EditLabel.Width = 26
        EditLabel.Height = 13
        EditLabel.Caption = 'State'
        LabelPosition = lpLeft
        LabelSpacing = 6
        ReadOnly = True
        TabOrder = 3
      end
      object countryBox: TComboBox
        Left = 77
        Top = 148
        Width = 267
        Height = 21
        Style = csDropDownList
        Sorted = True
        TabOrder = 4
      end
      object zipBox: TLabeledEdit
        Left = 77
        Top = 180
        Width = 267
        Height = 21
        EditLabel.Width = 14
        EditLabel.Height = 13
        EditLabel.Caption = 'Zip'
        LabelPosition = lpLeft
        LabelSpacing = 6
        ReadOnly = True
        TabOrder = 5
      end
      object addressBox: TLabeledEdit
        Left = 77
        Top = 58
        Width = 267
        Height = 21
        EditLabel.Width = 39
        EditLabel.Height = 13
        EditLabel.Caption = 'Address'
        LabelPosition = lpLeft
        LabelSpacing = 6
        ReadOnly = True
        TabOrder = 6
      end
      object regularBox: TLabeledEdit
        Left = 77
        Top = 211
        Width = 267
        Height = 21
        EditLabel.Width = 30
        EditLabel.Height = 13
        EditLabel.Caption = 'Phone'
        EditLabel.Font.Charset = DEFAULT_CHARSET
        EditLabel.Font.Color = 9079434
        EditLabel.Font.Height = -11
        EditLabel.Font.Name = 'Tahoma'
        EditLabel.Font.Style = []
        EditLabel.ParentFont = False
        LabelPosition = lpLeft
        LabelSpacing = 6
        ReadOnly = True
        TabOrder = 7
      end
      object GroupBox1: TGroupBox
        Left = 8
        Top = 269
        Width = 410
        Height = 119
        Caption = 'Place of birth'
        TabOrder = 8
        object Label5: TLabel
          Left = 24
          Top = 83
          Width = 39
          Height = 13
          Alignment = taRightJustify
          Caption = 'Country'
          Transparent = True
        end
        object birthCityBox: TLabeledEdit
          Left = 69
          Top = 26
          Width = 267
          Height = 21
          EditLabel.Width = 19
          EditLabel.Height = 13
          EditLabel.Caption = 'City'
          LabelPosition = lpLeft
          LabelSpacing = 6
          ReadOnly = True
          TabOrder = 0
        end
        object birthStateBox: TLabeledEdit
          Left = 69
          Top = 53
          Width = 267
          Height = 21
          EditLabel.Width = 26
          EditLabel.Height = 13
          EditLabel.Caption = 'State'
          LabelPosition = lpLeft
          LabelSpacing = 6
          ReadOnly = True
          TabOrder = 1
        end
        object birthCountryBox: TComboBox
          Left = 69
          Top = 80
          Width = 267
          Height = 21
          Style = csDropDownList
          Sorted = True
          TabOrder = 2
        end
      end
    end
    object WorkTS: TTabSheet
      Caption = '&Work'
      ImageIndex = 6
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object Label1: TLabel
        Left = 32
        Top = 237
        Width = 39
        Height = 13
        Alignment = taRightJustify
        Caption = 'Country'
        Transparent = True
      end
      object WkpgEdt: TLabeledEdit
        Left = 8
        Top = 23
        Width = 336
        Height = 21
        EditLabel.Width = 49
        EditLabel.Height = 13
        EditLabel.Caption = 'Workpage'
        ReadOnly = True
        TabOrder = 0
      end
      object workCityEdt: TLabeledEdit
        Left = 77
        Top = 173
        Width = 267
        Height = 21
        EditLabel.Width = 19
        EditLabel.Height = 13
        EditLabel.Caption = 'City'
        LabelPosition = lpLeft
        LabelSpacing = 6
        ReadOnly = True
        TabOrder = 5
      end
      object workStateEdt: TLabeledEdit
        Left = 77
        Top = 205
        Width = 267
        Height = 21
        EditLabel.Width = 26
        EditLabel.Height = 13
        EditLabel.Caption = 'State'
        LabelPosition = lpLeft
        LabelSpacing = 6
        ReadOnly = True
        TabOrder = 6
      end
      object WorkCntryBox: TComboBox
        Left = 77
        Top = 235
        Width = 267
        Height = 21
        Style = csDropDownList
        Sorted = True
        TabOrder = 7
      end
      object workZipEdt: TLabeledEdit
        Left = 77
        Top = 266
        Width = 267
        Height = 21
        CharCase = ecLowerCase
        EditLabel.Width = 14
        EditLabel.Height = 13
        EditLabel.Caption = 'Zip'
        LabelPosition = lpLeft
        LabelSpacing = 6
        MaxLength = 9
        ReadOnly = True
        TabOrder = 8
        OnChange = OnlyDigitChange
      end
      object WorkCellEdit: TLabeledEdit
        Left = 77
        Top = 297
        Width = 267
        Height = 21
        EditLabel.Width = 35
        EditLabel.Height = 13
        EditLabel.Caption = 'Cellular'
        LabelPosition = lpLeft
        LabelSpacing = 6
        ReadOnly = True
        TabOrder = 9
      end
      object WorkPosEdit: TLabeledEdit
        Left = 77
        Top = 50
        Width = 267
        Height = 21
        EditLabel.Width = 37
        EditLabel.Height = 13
        EditLabel.Caption = 'Position'
        LabelPosition = lpLeft
        LabelSpacing = 6
        ReadOnly = True
        TabOrder = 2
      end
      object WorkDeptEdit: TLabeledEdit
        Left = 77
        Top = 79
        Width = 267
        Height = 21
        EditLabel.Width = 57
        EditLabel.Height = 13
        EditLabel.Caption = 'Department'
        LabelPosition = lpLeft
        LabelSpacing = 6
        ReadOnly = True
        TabOrder = 3
      end
      object WorkCompanyEdit: TLabeledEdit
        Left = 77
        Top = 110
        Width = 267
        Height = 21
        EditLabel.Width = 45
        EditLabel.Height = 13
        EditLabel.Caption = 'Company'
        LabelPosition = lpLeft
        LabelSpacing = 6
        ReadOnly = True
        TabOrder = 4
      end
      object GoWkPgBtn: TRnQButton
        Left = 350
        Top = 21
        Width = 71
        Height = 25
        Hint = 'Open this address'
        Caption = 'GO'
        ImageName = ''
        TabOrder = 1
        OnClick = GoWkPgBtnClick
      end
      object workAddressEdt: TLabeledEdit
        Left = 77
        Top = 141
        Width = 267
        Height = 21
        EditLabel.Width = 39
        EditLabel.Height = 13
        EditLabel.Caption = 'Address'
        LabelPosition = lpLeft
        LabelSpacing = 6
        ReadOnly = True
        TabOrder = 10
      end
    end
    object TabSheet2: TTabSheet
      Caption = '&Extra'
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object Bevel2: TBevel
        Left = 245
        Top = 201
        Width = 2
        Height = 181
      end
      object Label28: TLabel
        Left = 265
        Top = 208
        Width = 40
        Height = 13
        Caption = 'UIN-lists'
      end
      object dontdeleteChk: TCheckBox
        Left = 8
        Top = 357
        Width = 231
        Height = 22
        Caption = 'Don'#39't delete from database'
        TabOrder = 6
      end
      object uinlistsBox: TMemo
        Left = 265
        Top = 263
        Width = 148
        Height = 86
        ReadOnly = True
        ScrollBars = ssVertical
        TabOrder = 9
      end
      object groupBox: TLabeledEdit
        Left = 288
        Top = 228
        Width = 125
        Height = 21
        EditLabel.Width = 29
        EditLabel.Height = 13
        EditLabel.Caption = 'Group'
        LabelPosition = lpLeft
        ReadOnly = True
        TabOrder = 8
      end
      object publicChk: TCheckBox
        Left = 8
        Top = 375
        Width = 231
        Height = 22
        Caption = 'Let people see my e-mail address'
        TabOrder = 7
      end
      object GroupBox9: TGroupBox
        Left = 3
        Top = 48
        Width = 418
        Height = 145
        Caption = 'Interests'
        TabOrder = 0
        object Inter1Box: TComboBox
          Left = 16
          Top = 16
          Width = 129
          Height = 21
          Style = csDropDownList
          TabOrder = 0
        end
        object Inter2Box: TComboBox
          Left = 16
          Top = 48
          Width = 129
          Height = 21
          Style = csDropDownList
          TabOrder = 1
        end
        object Inter3Box: TComboBox
          Left = 16
          Top = 80
          Width = 129
          Height = 21
          Style = csDropDownList
          TabOrder = 2
        end
        object Inter1: TEdit
          Left = 160
          Top = 16
          Width = 250
          Height = 21
          TabOrder = 3
        end
        object Inter2: TEdit
          Left = 160
          Top = 48
          Width = 250
          Height = 21
          TabOrder = 4
        end
        object Inter3: TEdit
          Left = 160
          Top = 80
          Width = 250
          Height = 21
          TabOrder = 5
        end
        object Inter4Box: TComboBox
          Left = 16
          Top = 110
          Width = 129
          Height = 21
          Style = csDropDownList
          TabOrder = 6
        end
        object Inter4: TEdit
          Left = 160
          Top = 110
          Width = 250
          Height = 21
          TabOrder = 7
        end
      end
      object lastupdateBox: TLabeledEdit
        Left = 121
        Top = 309
        Width = 120
        Height = 21
        EditLabel.Width = 76
        EditLabel.Height = 13
        EditLabel.Caption = 'Info updated to'
        LabelPosition = lpLeft
        ReadOnly = True
        TabOrder = 5
      end
      object membersinceBox: TLabeledEdit
        Left = 121
        Top = 282
        Width = 120
        Height = 21
        EditLabel.Width = 67
        EditLabel.Height = 13
        EditLabel.Caption = 'Registered on'
        LabelPosition = lpLeft
        ReadOnly = True
        TabOrder = 4
      end
      object onlinesinceBox: TLabeledEdit
        Left = 121
        Top = 255
        Width = 120
        Height = 21
        EditLabel.Width = 57
        EditLabel.Height = 13
        EditLabel.Caption = 'Online since'
        LabelPosition = lpLeft
        ReadOnly = True
        TabOrder = 3
      end
      object lastonlineBox: TLabeledEdit
        Left = 121
        Top = 228
        Width = 120
        Height = 21
        EditLabel.Width = 100
        EditLabel.Height = 13
        EditLabel.Caption = 'Last time seen online'
        LabelPosition = lpLeft
        ReadOnly = True
        TabOrder = 2
      end
      object lastmsgBox: TLabeledEdit
        Left = 121
        Top = 201
        Width = 120
        Height = 21
        EditLabel.Width = 88
        EditLabel.Height = 13
        EditLabel.Caption = 'Last message time'
        LabelPosition = lpLeft
        ReadOnly = True
        TabOrder = 1
      end
      object LastChgInfoBox: TLabeledEdit
        Left = 121
        Top = 335
        Width = 120
        Height = 21
        EditLabel.Width = 64
        EditLabel.Height = 13
        EditLabel.Caption = 'Info changed'
        LabelPosition = lpLeft
        ReadOnly = True
        TabOrder = 10
      end
      object StsMsgEdit: TLabeledEdit
        Left = 3
        Top = 17
        Width = 322
        Height = 21
        EditLabel.Width = 50
        EditLabel.Height = 13
        EditLabel.Caption = 'Life status'
        TabOrder = 11
      end
      object RnQButton2: TRnQButton
        Left = 331
        Top = 17
        Width = 90
        Height = 25
        Caption = 'Apply'
        ImageName = 'apply'
        TabOrder = 12
        OnClick = RnQButton2Click
      end
    end
    object InterSheet: TTabSheet
      Caption = '&Client'
      ImageIndex = 3
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object Bevel1: TBevel
        Left = 16
        Top = 293
        Width = 393
        Height = 2
      end
      object Label26: TLabel
        Left = 32
        Top = 324
        Width = 51
        Height = 13
        Caption = 'IP address'
      end
      object resolveBtn: TRnQSpeedButton
        Left = 19
        Top = 340
        Width = 70
        Height = 20
        Caption = 'Resolve'
        OnClick = resolveBtnClick
      end
      object copyBtn: TRnQSpeedButton
        Left = 19
        Top = 363
        Width = 70
        Height = 20
        Caption = 'Copy'
        OnClick = copyBtnClick
      end
      object Bevel3: TBevel
        Left = 183
        Top = 19
        Width = 3
        Height = 71
      end
      object CapsLabel: TLabel
        Left = 3
        Top = 77
        Width = 82
        Height = 13
        Caption = 'Client capabilities'
      end
      object Label8: TLabel
        Left = 32
        Top = 307
        Width = 51
        Height = 13
        Alignment = taRightJustify
        Caption = 'IP address'
        Transparent = True
      end
      object ipbox2: TMemo
        Left = 95
        Top = 331
        Width = 314
        Height = 61
        ReadOnly = True
        TabOrder = 5
      end
      object ChkSendTransl: TCheckBox
        Left = 192
        Top = 21
        Width = 261
        Height = 17
        Caption = 'Send translit message (for russian only)'
        TabOrder = 2
      end
      object protoBox: TLabeledEdit
        Left = 75
        Top = 19
        Width = 102
        Height = 21
        EditLabel.Width = 70
        EditLabel.Height = 13
        EditLabel.Caption = 'Direct protocol'
        LabelPosition = lpLeft
        ReadOnly = True
        TabOrder = 0
      end
      object clientBox: TLabeledEdit
        Left = 75
        Top = 46
        Width = 102
        Height = 21
        EditLabel.Width = 27
        EditLabel.Height = 13
        EditLabel.Caption = 'Client'
        LabelPosition = lpLeft
        ReadOnly = True
        TabOrder = 1
      end
      object CliCapsMemo: TMemo
        Left = 3
        Top = 96
        Width = 418
        Height = 193
        ReadOnly = True
        ScrollBars = ssVertical
        TabOrder = 4
        WordWrap = False
      end
      object loginMailEdt: TLabeledEdit
        Left = 192
        Top = 72
        Width = 217
        Height = 21
        EditLabel.Width = 107
        EditLabel.Height = 13
        EditLabel.Caption = 'Attached mail for login'
        TabOrder = 3
      end
      object LUPDDATEEdt: TEdit
        Left = 192
        Top = 46
        Width = 97
        Height = 21
        ReadOnly = True
        TabOrder = 6
      end
      object LInfoDATEEdt: TEdit
        Left = 304
        Top = 46
        Width = 105
        Height = 21
        ReadOnly = True
        TabOrder = 7
      end
      object ipBox: TEdit
        Left = 95
        Top = 304
        Width = 140
        Height = 21
        TabStop = False
        AutoSize = False
        TabOrder = 8
        Text = '000.000.000.000'
      end
      object HEXCapsChk: TCheckBox
        Left = 128
        Top = 73
        Width = 49
        Height = 17
        Caption = 'Hex'
        TabOrder = 9
        OnClick = HEXCapsChkClick
      end
    end
    object TabSheet1: TTabSheet
      Caption = '&Notes'
      ImageIndex = 2
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object notesBox: TMemo
        AlignWithMargins = True
        Left = 3
        Top = 200
        Width = 418
        Height = 192
        Align = alBottom
        Lines.Strings = (
          'notesBox')
        ScrollBars = ssVertical
        TabOrder = 0
      end
      object ssNotesGrp: TGroupBox
        Left = 3
        Top = 0
        Width = 418
        Height = 153
        Caption = 'Server side'
        TabOrder = 1
        object ssNoteStrEdit: TLabeledEdit
          Left = 66
          Top = 17
          Width = 345
          Height = 21
          EditLabel.Width = 48
          EditLabel.Height = 13
          EditLabel.Caption = 'Important'
          EditLabel.Layout = tlCenter
          LabelPosition = lpLeft
          LabelSpacing = 8
          TabOrder = 0
        end
        object localMailEdt: TLabeledEdit
          Left = 66
          Top = 44
          Width = 286
          Height = 21
          EditLabel.Width = 28
          EditLabel.Height = 13
          EditLabel.Caption = 'E-Mail'
          EditLabel.Layout = tlCenter
          LabelPosition = lpLeft
          LabelSpacing = 8
          TabOrder = 1
        end
        object CellularEdt: TLabeledEdit
          Left = 66
          Top = 71
          Width = 286
          Height = 21
          EditLabel.Width = 35
          EditLabel.Height = 13
          EditLabel.Caption = 'Cellular'
          EditLabel.Layout = tlCenter
          LabelPosition = lpLeft
          LabelSpacing = 8
          TabOrder = 2
        end
        object ApplyMyTextBtn: TRnQButton
          Left = 355
          Top = 44
          Width = 56
          Height = 45
          ImageName = 'apply'
          TabOrder = 3
          OnClick = ApplyMyTextBtnClick
        end
        object CellularEdt3: TLabeledEdit
          Left = 66
          Top = 121
          Width = 286
          Height = 21
          EditLabel.Width = 44
          EditLabel.Height = 13
          EditLabel.Caption = 'Cellular 3'
          EditLabel.Layout = tlCenter
          LabelPosition = lpLeft
          LabelSpacing = 6
          TabOrder = 4
        end
        object CellularEdt2: TLabeledEdit
          Left = 66
          Top = 96
          Width = 286
          Height = 21
          EditLabel.Width = 44
          EditLabel.Height = 13
          EditLabel.Caption = 'Cellular 2'
          EditLabel.Layout = tlCenter
          LabelPosition = lpLeft
          LabelSpacing = 6
          TabOrder = 5
        end
      end
      object lclNoteStrEdit: TLabeledEdit
        Left = 69
        Top = 165
        Width = 352
        Height = 21
        EditLabel.Width = 48
        EditLabel.Height = 13
        EditLabel.Caption = 'Important'
        EditLabel.Layout = tlCenter
        LabelPosition = lpLeft
        LabelSpacing = 8
        TabOrder = 2
      end
    end
    object avtTS: TTabSheet
      Caption = '&Avatar'
      ImageIndex = 4
      OnShow = avtTSShow
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      DesignSize = (
        424
        395)
      object AVTGrp: TGroupBox
        Left = 88
        Top = 0
        Width = 333
        Height = 153
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Avatar'
        TabOrder = 1
        object AvtPBox: TPaintBox
          Left = 8
          Top = 16
          Width = 162
          Height = 134
          OnPaint = AvtPBoxPaint
        end
        object ClrAvtLbl: TLabel
          Left = 186
          Top = 38
          Width = 129
          Height = 13
          Alignment = taCenter
          AutoSize = False
          Caption = 'Need restart'
        end
        object ClrAvtBtn: TRnQButton
          Left = 176
          Top = 16
          Width = 150
          Height = 22
          Caption = 'Clear avatar'
          ImageName = 'clear'
          TabOrder = 0
          OnClick = ClrAvtBtnClick
        end
        object avtSaveBtn: TRnQButton
          Left = 176
          Top = 65
          Width = 150
          Height = 25
          Caption = 'Change own avatar'
          ImageName = 'save.net'
          TabOrder = 1
          OnClick = avtSaveBtnClick
        end
        object avtLoadBtn: TRnQButton
          Left = 176
          Top = 112
          Width = 150
          Height = 25
          Caption = 'Load avatar'
          ImageName = 'load.net'
          TabOrder = 2
          OnClick = avtLoadBtnClick
        end
      end
      object IcShRGrp: TRadioGroup
        Left = 3
        Top = 0
        Width = 79
        Height = 153
        Caption = 'Show'
        ItemIndex = 0
        Items.Strings = (
          'Avatar'
          'Photo'
          'None')
        TabOrder = 0
      end
      object PhtGrp: TGroupBox
        Left = 3
        Top = 159
        Width = 418
        Height = 234
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Photo'
        TabOrder = 2
        object RnQSpeedButton2: TRnQSpeedButton
          Left = 261
          Top = 24
          Width = 150
          Height = 22
          Caption = 'Save own photo'
          Enabled = False
          Visible = False
          ImageName = 'save.net'
          OnClick = avtSaveBtnClick
        end
        object PhotoPBox: TPaintBox
          Left = 8
          Top = 16
          Width = 247
          Height = 215
          OnPaint = PhotoPBoxPaint
        end
        object PhtLoadBtn: TRnQButton
          Left = 261
          Top = 60
          Width = 150
          Height = 25
          Caption = 'Load thumb'
          ImageName = 'load.net'
          TabOrder = 0
          OnClick = PhtLoadBtnClick
        end
        object PhtBigLoadBtn: TRnQButton
          Left = 261
          Top = 99
          Width = 150
          Height = 25
          Caption = 'Load photo'
          ImageName = 'load.net'
          TabOrder = 1
          OnClick = PhtBigLoadBtnClick
        end
        object PhtLoadBtn2: TRnQButton
          Left = 261
          Top = 137
          Width = 150
          Height = 25
          Caption = 'Load photo 2'
          ImageName = 'load.net'
          TabOrder = 2
          OnClick = PhtLoadBtn2Click
        end
        object PhtLoadBtn3: TRnQButton
          Left = 261
          Top = 176
          Width = 150
          Height = 25
          Caption = 'Load photo 3'
          ImageName = 'load.net'
          TabOrder = 3
          OnClick = PhtLoadBtn3Click
        end
      end
    end
    object PrivacyTab: TTabSheet
      Caption = 'Privacy'
      ImageIndex = 6
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object Label4: TLabel
        Left = 35
        Top = 32
        Width = 31
        Height = 13
        Caption = 'Label4'
      end
      object FontSelectBtn: TRnQSpeedButton
        Left = 154
        Top = 31
        Width = 23
        Height = 22
        ImageName = 'font'
      end
    end
  end
  object topPnl: TPanel
    Left = 0
    Top = 0
    Width = 432
    Height = 33
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 1
    object deleteBtn: TRnQSpeedButton
      Left = 270
      Top = 2
      Width = 102
      Height = 25
      Caption = 'delete from list'
      Flat = True
      OnClick = deleteBtnClick
    end
    object saveBtn: TRnQSpeedButton
      Left = 162
      Top = 2
      Width = 102
      Height = 25
      Caption = 'save my info'
      Flat = True
      OnClick = saveBtnClick
    end
    object updateBtn: TRnQSpeedButton
      Left = 50
      Top = 2
      Width = 102
      Height = 25
      Caption = 'retrieve info'
      Flat = True
      OnClick = updateBtnClick
    end
  end
end
