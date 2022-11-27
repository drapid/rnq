object chatFrm: TchatFrm
  Left = 180
  Top = 204
  Caption = 'Chat window'
  ClientHeight = 347
  ClientWidth = 620
  Color = clBtnFace
  ParentFont = True
  GlassFrame.Bottom = 55
  KeyPreview = True
  ScreenSnap = True
  OnActivate = FormActivate
  OnAfterMonitorDpiChanged = FormAfterMonitorDpiChanged
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnHide = FormHide
  OnKeyDown = FormKeyDown
  OnKeyPress = FormKeyPress
  OnMouseDown = FormMouseDown
  OnMouseMove = FormMouseMove
  OnMouseWheelDown = FormMouseWheelDown
  OnMouseWheelUp = FormMouseWheelUp
  OnResize = FormResize
  OnShow = FormShow
  DesignSize = (
    620
    347)
  TextHeight = 30
  object fp: TBevel
    Left = 0
    Top = 0
    Width = 620
    Height = 37
    Align = alTop
    Shape = bsBottomLine
    Visible = False
    ExplicitWidth = 509
  end
  object CLSplitter: TSplitter
    Left = 615
    Top = 37
    Height = 255
    Align = alRight
    ExplicitLeft = 488
    ExplicitTop = 64
    ExplicitHeight = 100
  end
  object panel: TPanel
    Left = 0
    Top = 292
    Width = 620
    Height = 33
    Align = alBottom
    BevelOuter = bvNone
    FullRepaint = False
    ParentBackground = False
    TabOrder = 6
    object sendBtn: TRnQToolButton
      Left = 9
      Top = 8
      Width = 65
      Height = 22
      Caption = '&Send'
      Flat = True
      OnClick = sendBtnClick
    end
    object closeBtn: TRnQToolButton
      Left = 80
      Top = 8
      Width = 65
      Height = 22
      Caption = '&Close'
      Flat = True
      ImageName = 'close'
      OnClick = closeBtnClick
    end
    object toolbar: TToolBar
      Left = 190
      Top = 8
      Width = 257
      Height = 19
      Align = alNone
      AutoSize = True
      ButtonHeight = 19
      ButtonWidth = 20
      Color = clBtnFace
      EdgeInner = esNone
      EdgeOuter = esNone
      List = True
      ParentColor = False
      TabOrder = 0
      Transparent = False
      Wrapable = False
      object historyBtn: TRnQSpeedButton
        Left = 0
        Top = 0
        Width = 18
        Height = 19
        Hint = 'Show the whole history, not only recent messages\nALT+H'
        AllowAllUp = True
        GroupIndex = 4
        Flat = True
        ParentShowHint = False
        ShowHint = False
        Spacing = 0
        Transparent = False
        ImageName = 'history'
        OnClick = historyBtnClick
      end
      object findBtn: TRnQSpeedButton
        Left = 18
        Top = 0
        Width = 18
        Height = 19
        Hint = 'Find a word in the history\nALT+F'
        AllowAllUp = True
        GroupIndex = 5
        Flat = True
        ParentShowHint = False
        ShowHint = False
        Spacing = 0
        Transparent = False
        ImageName = 'search'
        OnClick = findBtnClick
        OnMouseDown = findBtnMouseDown
      end
      object smilesBtn: TRnQSpeedButton
        Left = 36
        Top = 0
        Width = 18
        Height = 19
        Hint = 'Shows smiles as pictures\nALT+M, Menu - Ctrl+S'
        AllowAllUp = True
        Flat = True
        ParentShowHint = False
        ShowHint = False
        Spacing = 0
        Transparent = False
        ImageName = 'smiles'
        OnClick = smilesBtnClick
      end
      object emojiBtn: TRnQSpeedButton
        Left = 54
        Top = 0
        Width = 23
        Height = 19
        Hint = 'Show emoji'#39's panel'
        Flat = True
        Transparent = False
        ImageName = 'emoji'
        OnClick = emojiBtnClick
      end
      object stickersBtn: TRnQSpeedButton
        Left = 77
        Top = 0
        Width = 18
        Height = 19
        Hint = 'Shows stickers menu Ctrl+Shift+S'
        AllowAllUp = True
        Flat = True
        ParentShowHint = False
        ShowHint = False
        Spacing = 0
        Transparent = False
        Visible = False
        ImageName = 'stickers'
        OnClick = stickersBtnClick
      end
      object prefBtn: TRnQSpeedButton
        Left = 95
        Top = 0
        Width = 18
        Height = 19
        Hint = 'Preferences for the chat window\nALT+P'
        AllowAllUp = True
        Flat = True
        ParentShowHint = False
        ShowHint = False
        Spacing = 0
        Transparent = False
        ImageName = 'preferences'
        OnClick = prefBtnClick
        OnMouseDown = prefBtnMouseDown
      end
      object autoscrollBtn: TRnQSpeedButton
        Left = 113
        Top = 0
        Width = 18
        Height = 19
        Hint = 'Scrolls history on a new message\nALT+A'
        AllowAllUp = True
        GroupIndex = 2
        Flat = True
        ParentShowHint = False
        ShowHint = False
        Spacing = 0
        Transparent = False
        ImageName = 'down'
        OnClick = autoscrollBtnClick
      end
      object infoBtn: TRnQSpeedButton
        Left = 131
        Top = 0
        Width = 18
        Height = 19
        Hint = 'Info about this user\nALT+I'
        AllowAllUp = True
        Flat = True
        ParentShowHint = False
        ShowHint = False
        Spacing = 0
        Transparent = False
        ImageName = 'info'
        OnClick = infoBtnClick
      end
      object quoteBtn: TRnQSpeedButton
        Left = 149
        Top = 0
        Width = 18
        Height = 19
        Hint = 'Quote previous received messages\nALT+Q'
        Flat = True
        ParentShowHint = False
        ShowHint = False
        Spacing = 0
        Transparent = False
        ImageName = 'quote'
        OnClick = quoteBtnClick
        OnMouseDown = quoteBtnMouseDown
      end
      object singleBtn: TRnQSpeedButton
        Left = 167
        Top = 0
        Width = 18
        Height = 19
        Hint = 
          'Auto-close chat with this contact after you send him a message.\' +
          'nYou can choose a default setting from the "chat settings".'
        AllowAllUp = True
        GroupIndex = 3
        Flat = True
        ParentShowHint = False
        ShowHint = False
        Spacing = 0
        Transparent = False
        ImageName = '1.msg'
        OnClick = singleBtnClick
      end
      object btnContacts: TRnQSpeedButton
        Left = 185
        Top = 0
        Width = 18
        Height = 19
        Hint = 'Send contacts'
        Flat = True
        ParentShowHint = False
        ShowHint = False
        Spacing = 0
        Transparent = False
        ImageName = 'contacts'
        OnClick = btnContactsClick
      end
      object RnQPicBtn: TRnQSpeedButton
        Left = 203
        Top = 0
        Width = 18
        Height = 19
        Hint = 'Send pics'
        Flat = True
        ParentShowHint = False
        ShowHint = False
        Spacing = 0
        Transparent = False
        ImageName = 'pics'
        OnClick = RnQPicBtnClick
      end
      object RnQFileBtn: TRnQSpeedButton
        Left = 221
        Top = 0
        Width = 18
        Height = 19
        Hint = 'Send file'
        Flat = True
        ParentShowHint = False
        ShowHint = False
        Spacing = 0
        Transparent = False
        ImageName = 'file'
        OnClick = RnQFileBtnClick
        OnMouseDown = RnQFileBtnMouseDown
      end
      object BuzzBtn: TRnQSpeedButton
        Left = 239
        Top = 0
        Width = 18
        Height = 19
        Hint = 'Buzz contact'
        Flat = True
        ParentShowHint = False
        ShowHint = False
        Spacing = 0
        Transparent = False
        Visible = False
        ImageName = 'buzz'
        OnClick = BuzzBtnClick
      end
    end
    object tb0: TToolBar
      Left = 1
      Top = 1
      Width = 200
      Height = 0
      Align = alCustom
      Color = clBtnFace
      EdgeInner = esNone
      EdgeOuter = esNone
      ParentColor = False
      TabOrder = 1
    end
  end
  object sbar: TStatusBar
    Left = 0
    Top = 325
    Width = 620
    Height = 22
    Panels = <
      item
        Width = 120
      end
      item
        Style = psOwnerDraw
        Width = 25
      end
      item
        Alignment = taRightJustify
        Style = psOwnerDraw
        Width = 40
      end
      item
        Alignment = taRightJustify
        Style = psOwnerDraw
        Width = 25
      end
      item
        Width = 398
      end>
    OnDblClick = sbarDblClick
    OnMouseUp = sbarMouseUp
    OnDrawPanel = sbarDrawPanel
  end
  object pagectrl: TPageControl
    Left = 0
    Top = 37
    Width = 615
    Height = 255
    Align = alClient
    HotTrack = True
    MultiLine = True
    OwnerDraw = True
    TabOrder = 1
    OnChange = pagectrlChange
    OnChanging = pagectrlChanging
    OnDragDrop = pagectrlDragDrop
    OnDragOver = pagectrlDragOver
    OnDrawTab = pagectrlDrawTab
    OnMouseDown = pagectrl00MouseDown
    OnMouseLeave = pagectrlMouseLeave
    OnMouseMove = pagectrlMouseMove
    OnMouseUp = pagectrl00MouseUp
  end
  object caseChk: TCheckBox
    Left = 427
    Top = 10
    Width = 97
    Height = 17
    Anchors = [akTop, akRight]
    Caption = 'Case sensitive'
    TabOrder = 4
    Visible = False
  end
  object reChk: TCheckBox
    Left = 535
    Top = 10
    Width = 76
    Height = 17
    Anchors = [akTop, akRight]
    Caption = 'Reg.Exp.'
    TabOrder = 5
    Visible = False
  end
  object directionGrp: TComboBox
    Left = 302
    Top = 8
    Width = 119
    Height = 38
    AutoDropDown = True
    Style = csDropDownList
    Anchors = [akTop, akRight]
    ItemIndex = 0
    TabOrder = 3
    Text = 'from the beginning'
    Visible = False
    Items.Strings = (
      'from the beginning'
      'from the end'
      'backward'
      'forward')
  end
  object w2sBox: TEdit
    Left = 96
    Top = 8
    Width = 200
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    Constraints.MinWidth = 30
    TabOrder = 2
    Visible = False
    OnKeyDown = w2sBoxKeyDown
  end
  object SBSearch: TRnQButton
    Left = 8
    Top = 6
    Width = 75
    Height = 25
    Caption = 'Search'
    ImageName = 'search'
    TabOrder = 0
    Visible = False
    OnClick = SBSearchClick
  end
  object CLPanel: TPanel
    Left = 618
    Top = 37
    Width = 2
    Height = 255
    Align = alRight
    DockSite = True
    ParentColor = True
    TabOrder = 8
    OnDockDrop = CLPanelDockDrop
    OnDockOver = CLPanelDockOver
    OnUnDock = CLPanelUnDock
  end
end
