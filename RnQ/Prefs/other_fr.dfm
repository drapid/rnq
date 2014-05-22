object otherFr: TotherFr
  Left = 0
  Top = 0
  VertScrollBar.Tracking = True
  ClientHeight = 400
  ClientWidth = 420
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = True
  OnResize = FrameResize
  PixelsPerInch = 96
  TextHeight = 13
  object plBg: TPanel
    Left = 0
    Top = 0
    Width = 420
    Height = 400
    Align = alClient
    BevelOuter = bvNone
    BorderWidth = 6
    TabOrder = 0
    object PageCtrl: TPageControl
      Left = 6
      Top = 6
      Width = 408
      Height = 388
      ActivePage = TabSheet1
      Align = alClient
      TabOrder = 0
      object TabSheet1: TTabSheet
        Caption = 'Common'
        ExplicitLeft = 0
        ExplicitTop = 0
        ExplicitWidth = 0
        ExplicitHeight = 0
        DesignSize = (
          400
          360)
        object Label1: TLabel
          Left = 273
          Top = 207
          Width = 39
          Height = 13
          Caption = 'seconds'
        end
        object Label2: TLabel
          Left = 6
          Top = 6
          Width = 145
          Height = 21
          AutoSize = False
          BiDiMode = bdLeftToRight
          Caption = 'Mouse wheel speed:'
          ParentBiDiMode = False
          Layout = tlCenter
        end
        object Label8: TLabel
          Left = 217
          Top = 6
          Width = 118
          Height = 21
          AutoSize = False
          Caption = 'lines at time'
          Layout = tlCenter
        end
        object PathInfoBtn: TRnQSpeedButton
          Left = 344
          Top = 318
          Width = 23
          Height = 22
          Hint = 'About path'
          ImageName = 'help'
          OnClick = PathInfoBtnClick
        end
        object ChkPathBtn: TRnQSpeedButton
          Left = 374
          Top = 318
          Width = 23
          Height = 22
          Hint = 'Check path'
          ImageName = 'apply'
          OnClick = ChkPathBtnClick
        end
        object quitChk: TCheckBox
          Left = 6
          Top = 55
          Width = 329
          Height = 17
          HelpKeyword = 'quit-confirmation'
          Caption = 'Exit confirmation'
          TabOrder = 2
        end
        object minimizeroasterChk: TCheckBox
          Left = 6
          Top = 34
          Width = 329
          Height = 17
          HelpKeyword = 'minimize-roaster'
          Caption = 'Minimize before hiding contact list'
          TabOrder = 1
        end
        object inactivehideSpin: TRnQSpinEdit
          Left = 203
          Top = 204
          Width = 66
          Height = 22
          HelpKeyword = 'inactive-hide-time'
          Decimal = 0
          MaxLength = 3
          MaxValue = 36000.000000000000000000
          TabOrder = 7
          Value = 36000.000000000000000000
          AsInteger = 36000
        end
        object inactivehideChk: TCheckBox
          Left = 6
          Top = 206
          Width = 185
          Height = 17
          HelpKeyword = 'inactive-hide'
          Caption = 'Auto-hide contact list on inactivity'
          TabOrder = 6
          OnClick = inactivehideChkClick
        end
        object fixwindowsChk: TCheckBox
          Left = 6
          Top = 164
          Width = 329
          Height = 17
          HelpKeyword = 'fix-windows-position'
          Caption = 'Adjust windows position'
          TabOrder = 4
        end
        object wheel: TRnQSpinEdit
          Left = 158
          Top = 6
          Width = 55
          Height = 22
          AutoSize = False
          Decimal = 0
          MaxLength = 2
          MaxValue = 30.000000000000000000
          TabOrder = 0
        end
        object oncomingDlgChk: TCheckBox
          Left = 6
          Top = 185
          Width = 329
          Height = 17
          HelpKeyword = 'show-oncoming-dialog'
          Caption = 'Show dialog box when i click on oncoming contact'
          TabOrder = 5
        end
        object switchklChk: TCheckBox
          Left = 6
          Top = 76
          Width = 329
          Height = 17
          HelpKeyword = 'auto-switch-keyboard-layout'
          Caption = 'Auto switch keyboard layout'
          TabOrder = 3
        end
        object GroupBox1: TGroupBox
          Left = 6
          Top = 230
          Width = 385
          Height = 68
          Anchors = [akLeft, akTop, akRight]
          Caption = 'Web browser'
          TabOrder = 8
          object fnBoxButton: TRnQSpeedButton
            Left = 311
            Top = 17
            Width = 23
            Height = 21
            ImageName = 'open'
            OnClick = fnBoxButtonClick
          end
          object defaultbrowserChk: TRadioButton
            Left = 6
            Top = 44
            Width = 113
            Height = 17
            HelpKeyword = 'use-default-browser'
            Caption = 'Default'
            TabOrder = 0
            OnClick = custombrowserChkClick
          end
          object custombrowserChk: TRadioButton
            Left = 6
            Top = 19
            Width = 17
            Height = 17
            TabOrder = 1
            OnClick = custombrowserChkClick
          end
          object fnBox: TEdit
            Left = 24
            Top = 17
            Width = 286
            Height = 21
            HelpKeyword = 'browser-command-line'
            TabOrder = 2
          end
        end
        object NILdoGrp: TRadioGroup
          Left = 6
          Top = 97
          Width = 350
          Height = 60
          Caption = 'Do with not-in-list on exit'
          Columns = 2
          Items.Strings = (
            'save all'
            'clear all'
            'ask')
          TabOrder = 9
        end
        object RcvPathEdit: TLabeledEdit
          Left = 6
          Top = 318
          Width = 334
          Height = 21
          HelpKeyword = 'files-recv-path'
          EditLabel.Width = 93
          EditLabel.Height = 13
          EditLabel.Caption = 'Receiving files path'
          TabOrder = 10
        end
      end
    end
  end
end
