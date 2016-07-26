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
  OldCreateOrder = True
  ScreenSnap = True
  OnActivate = FormActivate
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
  PixelsPerInch = 96
  TextHeight = 13
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
      Width = 234
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
      object stickersBtn: TRnQSpeedButton
        Left = 54
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
        Left = 72
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
        Left = 90
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
        Left = 108
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
        Left = 126
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
        Left = 144
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
        Left = 162
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
        Left = 180
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
        Left = 198
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
        Left = 216
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
    Height = 21
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
    TabOrder = 0
    Visible = False
    OnClick = SBSearchClick
    ImageName = 'search'
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
  object ActList1: TActionList
    Left = 264
    Top = 96
    object hAaddtoroaster: TAction
      Category = 'histMenu'
      Caption = 'Add to contact list'
      HelpKeyword = 'addedyou'
      OnExecute = ANothingExecute
    end
    object hAsaveas: TAction
      Category = 'histMenu'
      Caption = 'Save as'
      HelpKeyword = 'save'
      OnExecute = ANothingExecute
    end
    object hAdelete: TAction
      Category = 'histMenu'
      Caption = 'Delete selected'
      HelpKeyword = 'delete'
      OnExecute = del1Click
    end
    object hACopy: TAction
      Category = 'histMenu'
      Caption = 'Copy'
      HelpKeyword = 'copy'
      OnExecute = copy2clpbClick
    end
    object hASelectAll: TAction
      Category = 'histMenu'
      Caption = 'Select all'
      HelpKeyword = 'select.all'
      OnExecute = selectall1Click
    end
    object hAchatshowlsb: TAction
      Category = 'histMenu'
      Caption = 'Show left scrollbar'
      OnExecute = chatshowlsb1Click
      OnUpdate = hAchatshowlsbUpdate
    end
    object hAchatpopuplsb: TAction
      Category = 'histMenu'
      Caption = 'Popup left scrollbar'
      OnExecute = chatpopuplsb1Click
      OnUpdate = hAchatpopuplsbUpdate
    end
    object hAViewInfo: TAction
      Category = 'histMenu'
      Caption = 'View info'
      OnExecute = hAViewInfoExecute
    end
    object hAShowSmiles: TAction
      Category = 'histMenu'
      AutoCheck = True
      Caption = 'Show graphic smiles'
      Checked = True
      HelpKeyword = 'smiles'
      OnExecute = hAShowSmilesExecute
      OnUpdate = hAShowSmilesUpdate
    end
    object ShowStickers: TAction
      Category = 'chatActions'
      SecondaryShortCuts.Strings = (
        'Ctrl+Shift+S')
      OnExecute = ShowStickersExecute
    end
    object hAShowDevTools: TAction
      Category = 'histMenu'
      Caption = 'hAShowDevTools'
      HelpKeyword = 'debug'
      OnExecute = chatShowDevToolsClick
    end
  end
  object histmenu: TPopupMenu
    OwnerDraw = True
    OnPopup = histmenuPopup
    Left = 200
    Top = 96
    object add2rstr: TMenuItem
      Action = hAaddtoroaster
    end
    object copylink2clpbd: TMenuItem
      Caption = 'Copy link'
      OnClick = copylink2clpbdClick
    end
    object copy2clpb: TMenuItem
      Action = hACopy
    end
    object savePicMnu: TMenuItem
      Caption = 'Save pic'
      OnClick = savePicMnuClick
    end
    object selectall1: TMenuItem
      Action = hASelectAll
    end
    object viewmessageinwindow1: TMenuItem
      Caption = 'View message in window'
      OnClick = viewmessageinwindow1Click
    end
    object saveas1: TMenuItem
      Action = hAsaveas
      object txt1: TMenuItem
        Caption = 'txt'
        OnClick = txt1Click
      end
      object html1: TMenuItem
        Caption = 'html'
        OnClick = html1Click
      end
    end
    object addlink2fav: TMenuItem
      Caption = 'Add link to favorites'
      OnClick = addlink2favClick
    end
    object del1: TMenuItem
      Action = hAdelete
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object toantispam: TMenuItem
      Caption = 'To antispam'
      OnClick = toantispamClick
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object Openchatwith1: TMenuItem
      Action = RnQmain.mAOpenchatwith
    end
    object ViewinfoM: TMenuItem
      Action = hAViewInfo
    end
    object N3: TMenuItem
      Caption = '-'
    end
    object chtShowSmiles: TMenuItem
      Action = hAShowSmiles
      AutoCheck = True
    end
    object chatshowlsb1: TMenuItem
      Action = hAchatshowlsb
    end
    object chatpopuplsb1: TMenuItem
      Action = hAchatpopuplsb
    end
    object chatShowDevTools: TMenuItem
      Caption = 'Show Dev tools'
      OnClick = chatShowDevToolsClick
    end
  end
end
