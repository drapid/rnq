object antispamFr: TantispamFr
  Left = 0
  Top = 0
  VertScrollBar.Tracking = True
  ClientHeight = 421
  ClientWidth = 468
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
    Width = 468
    Height = 421
    Align = alClient
    BevelOuter = bvNone
    BorderWidth = 6
    TabOrder = 0
    object PageControl1: TPageControl
      Left = 6
      Top = 6
      Width = 456
      Height = 409
      ActivePage = TabSheet1
      Align = alClient
      TabOrder = 0
      object TabSheet1: TTabSheet
        Caption = 'Filter'
        object IgnoreAuthNILChk: TCheckBox
          Left = 6
          Top = 75
          Width = 403
          Height = 17
          HelpKeyword = 'ignore-authreq-notinlist'
          Caption = 'Ignore authorization requests from people who'#39's not in your list'
          ParentShowHint = False
          ShowHint = True
          TabOrder = 3
        end
        object ignorepagersChk: TCheckBox
          Left = 6
          Top = 52
          Width = 377
          Height = 17
          HelpKeyword = 'ignore-pagers'
          Caption = 'Ignore pager messages'
          ParentShowHint = False
          ShowHint = True
          TabOrder = 2
        end
        object ignorenilChk: TCheckBox
          Left = 6
          Top = 29
          Width = 403
          Height = 17
          HelpKeyword = 'ignore-not-in-list'
          Caption = 'Ignore messages from people who'#39's not in your list'
          TabOrder = 1
        end
        object warnChk: TCheckBox
          Left = 6
          Top = 6
          Width = 377
          Height = 17
          HelpKeyword = 'spam-warn'
          Caption = 'Warn me upon filtered messages'
          TabOrder = 0
        end
        object gb: TGroupBox
          Left = 6
          Top = 116
          Width = 377
          Height = 246
          Caption = 'Ignore messages when all the rules apply'
          TabOrder = 4
          object notnilChk: TCheckBox
            Left = 12
            Top = 39
            Width = 320
            Height = 17
            HelpKeyword = 'spam-ignore-not-in-list'
            Caption = 'sender is not in my contact list'
            TabOrder = 1
          end
          object badwordsChk: TCheckBox
            Left = 12
            Top = 85
            Width = 320
            Height = 17
            HelpKeyword = 'spam-ignore-bad-words'
            Caption = 'the message contains a word from this list:'
            TabOrder = 3
          end
          object notemptyChk: TCheckBox
            Left = 12
            Top = 62
            Width = 320
            Height = 17
            HelpKeyword = 'spam-ignore-empty-history'
            Caption = 'history is empty'
            TabOrder = 2
          end
          object multisendChk: TCheckBox
            Left = 12
            Top = 16
            Width = 320
            Height = 17
            HelpKeyword = 'spam-ignore-multisend'
            Caption = 'is a multiple-recipient message'
            TabOrder = 0
          end
          object uingtChk: TCheckBox
            Left = 12
            Top = 218
            Width = 320
            Height = 17
            Caption = 'UIN is greater than'
            TabOrder = 5
          end
          object badwordsBox: TMemo
            Left = 12
            Top = 108
            Width = 357
            Height = 101
            HelpKeyword = 'spam-bad-words'
            ScrollBars = ssVertical
            TabOrder = 4
          end
          object uingSpin: TRnQSpinEdit
            Left = 152
            Top = 215
            Width = 217
            Height = 22
            HelpKeyword = 'spam-uin-greater-than'
            Decimal = 0
            MaxLength = 10
            MaxValue = 2000000000.000000000000000000
            MinValue = 1.000000000000000000
            TabOrder = 6
            Value = 1.000000000000000000
            AsInteger = 1
          end
        end
        object AddSpamToHistChk: TCheckBox
          Left = 6
          Top = 97
          Width = 377
          Height = 17
          HelpKeyword = 'spam-add-history'
          Caption = 'Add filtered messages to "0spamers" history'
          TabOrder = 5
        end
      end
      object TabSheet2: TTabSheet
        Caption = 'Bot'
        ImageIndex = 1
        ExplicitLeft = 0
        ExplicitTop = 0
        ExplicitWidth = 0
        ExplicitHeight = 0
        object Label1: TLabel
          Left = 64
          Top = 60
          Width = 78
          Height = 13
          Caption = 'Number of tryes'
          Layout = tlCenter
        end
        object UseBotChk: TCheckBox
          Left = 6
          Top = 6
          Width = 385
          Height = 17
          HelpKeyword = 'spam-use-bot'
          Caption = 'Enable'
          TabOrder = 0
        end
        object QstGrp: TGroupBox
          Left = 6
          Top = 101
          Width = 377
          Height = 239
          TabOrder = 4
          DesignSize = (
            377
            239)
          object QuestAddBtn: TRnQSpeedButton
            Left = 159
            Top = 12
            Width = 23
            Height = 22
            Flat = True
            ImageName = 'add'
            OnClick = QuestAddBtnClick
          end
          object QuestDelBtn: TRnQSpeedButton
            Left = 188
            Top = 12
            Width = 23
            Height = 22
            Flat = True
            ImageName = 'delete'
            OnClick = QuestDelBtnClick
          end
          object qstLbl: TLabel
            Left = 22
            Top = 59
            Width = 43
            Height = 13
            Alignment = taRightJustify
            Caption = 'Question'
          end
          object Label2: TLabel
            Left = 24
            Top = 139
            Width = 41
            Height = 13
            Alignment = taRightJustify
            Caption = 'Answers'
          end
          object QuestMemo: TMemo
            Left = 69
            Top = 56
            Width = 300
            Height = 69
            Anchors = [akLeft, akTop, akRight]
            TabOrder = 0
          end
          object QuestBox: TComboBox
            Left = 8
            Top = 12
            Width = 145
            Height = 21
            Style = csDropDownList
            TabOrder = 1
            OnChange = QuestBoxChange
          end
          object AnsMemo: TMemo
            Left = 69
            Top = 136
            Width = 300
            Height = 89
            TabOrder = 2
          end
        end
        object SpamFileChk: TCheckBox
          Left = 6
          Top = 90
          Width = 385
          Height = 17
          HelpKeyword = 'spam-use-bot-file'
          Caption = 'Use questions'
          TabOrder = 3
        end
        object TrCntBox: TComboBox
          Left = 6
          Top = 58
          Width = 49
          Height = 21
          HelpKeyword = 'spam-bot-tryes'
          Style = csDropDownList
          ItemIndex = 1
          TabOrder = 2
          Text = '3'
          Items.Strings = (
            '2'
            '3'
            '4'
            '5')
        end
        object BotInInvisChk: TCheckBox
          Left = 6
          Top = 32
          Width = 364
          Height = 17
          HelpKeyword = 'spam-use-bot-in-invis'
          Caption = 'Work even in invisible mode'
          TabOrder = 1
        end
      end
      object IgnoreSht: TTabSheet
        Caption = 'Ignore list'
        ImageIndex = 2
        DesignSize = (
          448
          381)
        object IgnoreTree: TVirtualDrawTree
          Left = 6
          Top = 31
          Width = 327
          Height = 319
          Anchors = [akLeft, akTop, akRight]
          Header.AutoSizeIndex = 0
          Header.DefaultHeight = 17
          Header.Font.Charset = DEFAULT_CHARSET
          Header.Font.Color = clWindowText
          Header.Font.Height = -11
          Header.Font.Name = 'Tahoma'
          Header.Font.Style = []
          Header.Height = 17
          Header.MainColumn = -1
          Header.Options = [hoColumnResize, hoDrag]
          TabOrder = 0
          TreeOptions.MiscOptions = [toAcceptOLEDrop, toFullRepaintOnResize, toGridExtensions, toInitOnSave, toToggleOnDblClick, toWheelPanning]
          TreeOptions.PaintOptions = [toShowButtons, toShowDropmark, toShowTreeLines, toThemeAware, toUseBlendedImages, toUseBlendedSelection]
          TreeOptions.SelectionOptions = [toFullRowSelect, toMiddleClickSelect, toRightClickSelect]
          OnDrawNode = IgnoreTreeDrawNode
          OnFreeNode = IgnoreTreeFreeNode
          Columns = <>
        end
        object AddIgnBtn: TRnQButton
          Left = 336
          Top = 36
          Width = 109
          Height = 25
          Anchors = [akTop, akRight]
          Caption = 'Add'
          TabOrder = 1
          OnClick = AddIgnBtnClick
          ImageName = 'add'
        end
        object AddIgnSrvBtn: TRnQButton
          Left = 336
          Top = 86
          Width = 109
          Height = 25
          Anchors = [akTop, akRight]
          Caption = 'Add to server'
          TabOrder = 2
          OnClick = AddIgnSrvBtnClick
        end
        object RmvIgnSrvBtn: TRnQButton
          Left = 336
          Top = 136
          Width = 109
          Height = 25
          Anchors = [akTop, akRight]
          Caption = 'Remove from server'
          TabOrder = 3
          Visible = False
        end
        object RmvIgnBtn: TRnQButton
          Left = 336
          Top = 183
          Width = 109
          Height = 25
          Anchors = [akTop, akRight]
          Caption = 'Remove'
          TabOrder = 4
          OnClick = RmvIgnBtnClick
          ImageName = 'delete'
        end
        object UseIgnChk: TCheckBox
          Left = 6
          Top = 6
          Width = 97
          Height = 17
          HelpKeyword = 'enable-ignore-list'
          Caption = 'Enabled'
          TabOrder = 5
        end
      end
    end
  end
end
