object RnQmain: TRnQmain
  Left = 283
  Top = 165
  HorzScrollBar.Tracking = True
  HorzScrollBar.Visible = False
  VertScrollBar.Tracking = True
  ActiveControl = roster
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSizeToolWin
  Caption = 'R&Q'
  ClientHeight = 380
  ClientWidth = 142
  Color = 8314031
  CustomTitleBar.Height = 20
  TransparentColorValue = clBackground
  Constraints.MinHeight = 50
  Constraints.MinWidth = 50
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  GlassFrame.Left = 5
  GlassFrame.Top = 20
  GlassFrame.Right = 5
  GlassFrame.Bottom = 20
  GlassFrame.SheetOfGlass = True
  Position = poDesigned
  ScreenSnap = True
  SnapBuffer = 15
  OnActivate = AppActivate
  OnAfterMonitorDpiChanged = FormAfterMonitorDpiChanged
  OnClick = ANothingExecute
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDeactivate = AppActivate
  OnHide = FormHide
  OnKeyDown = FormKeyDown
  OnKeyPress = FormKeyPress
  OnResize = FormResize
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object TopLbl: TLabel
    Left = 0
    Top = 0
    Width = 142
    Height = 13
    Align = alTop
    Alignment = taCenter
    Caption = 'R&Q'
    ShowAccelChar = False
    Transparent = False
    Visible = False
    OnDblClick = TopLblDblClick
    ExplicitWidth = 22
  end
  object bar: TPanel
    Left = 0
    Top = 357
    Width = 142
    Height = 23
    Align = alBottom
    BevelEdges = [beTop]
    BevelKind = bkFlat
    BevelOuter = bvNone
    FullRepaint = False
    ParentColor = True
    TabOrder = 0
    object menuBtn: TRnQSpeedButton
      Left = 0
      Top = 0
      Width = 21
      Height = 21
      Hint = 'Menu'
      Align = alLeft
      Constraints.MinHeight = 21
      Flat = True
      ParentShowHint = False
      ShowHint = True
      ImageName = 'rnq'
      OnClick = menuBtnClick
      ExplicitHeight = 22
    end
    object statusBtn: TRnQSpeedButton
      Left = 21
      Top = 0
      Width = 21
      Height = 21
      Hint = 'Status'
      Align = alLeft
      Constraints.MinHeight = 21
      Flat = True
      ParentShowHint = False
      ShowHint = True
      OnClick = statusBtnClick
      OnMouseUp = statusBtnMouseUp
      ExplicitHeight = 22
    end
    object visibilityBtn: TRnQSpeedButton
      Left = 42
      Top = 0
      Width = 21
      Height = 21
      Hint = 'Visibility'
      Align = alLeft
      Constraints.MinHeight = 21
      Flat = True
      ParentShowHint = False
      ShowHint = True
      OnClick = visibilityBtnClick
      ExplicitHeight = 22
    end
  end
  object FilterBar: TPanel
    Left = 0
    Top = 13
    Width = 142
    Height = 24
    Align = alTop
    BevelEdges = []
    BevelOuter = bvNone
    FullRepaint = False
    TabOrder = 3
    DesignSize = (
      142
      24)
    object FilterClearBtn: TRnQSpeedButton
      Left = 119
      Top = 1
      Width = 21
      Height = 21
      Hint = 'Clear filter text'
      Anchors = [akTop, akRight]
      Flat = True
      ImageName = 'cancel'
      OnClick = FilterClearBtnClick
    end
    object FilterEdit: TEdit
      AlignWithMargins = True
      Left = 3
      Top = 3
      Width = 115
      Height = 18
      Margins.Right = 24
      Align = alClient
      TabOrder = 0
      OnChange = FilterEditChange
      OnKeyDown = FilterEditKeyDown
      ExplicitHeight = 21
    end
  end
  object roster: TVirtualDrawTree
    Left = 0
    Top = 58
    Width = 142
    Height = 299
    Align = alClient
    BevelEdges = []
    BorderStyle = bsNone
    ButtonFillMode = fmTransparent
    ButtonStyle = bsTriangle
    BorderWidth = 1
    Colors.UnfocusedColor = clMedGray
    DragOperations = [doMove]
    Header.AutoSizeIndex = 0
    Header.MainColumn = -1
    Header.Options = [hoColumnResize, hoDrag]
    HintAnimation = hatNone
    HintMode = hmHint
    NodeDataSize = 4
    ScrollBarOptions.ScrollBars = ssVertical
    TabOrder = 1
    TextMargin = 0
    TreeOptions.AnimationOptions = [toAnimatedToggle]
    TreeOptions.AutoOptions = [toAutoDropExpand, toAutoScroll, toAutoScrollOnExpand, toAutoTristateTracking, toAutoChangeScale]
    TreeOptions.MiscOptions = [toAcceptOLEDrop, toEditable, toFullRepaintOnResize, toInitOnSave, toToggleOnDblClick, toWheelPanning, toFullRowDrag]
    TreeOptions.PaintOptions = [toHideFocusRect, toHideSelection, toThemeAware, toUseBlendedImages, toAlwaysHideSelection, toUseBlendedSelection]
    TreeOptions.SelectionOptions = [toFullRowSelect, toRightClickSelect]
    OnCollapsed = rosterCollapsed
    OnCollapsing = rosterCollapsing
    OnCompareNodes = rosterCompareNodes
    OnDblClick = rosterDblClick
    OnDragOver = rosterDragOver
    OnDragDrop = rosterDragDrop
    OnDrawHint = rosterDrawHint
    OnDrawNode = rosterDrawNode
    OnExpanded = rosterCollapsed
    OnFocusChanged = rosterFocusChanged
    OnFocusChanging = rosterFocusChanging
    OnGetHintSize = rosterGetHintSize
    OnKeyDown = rosterKeyDown
    OnKeyPress = rosterKeyPress
    OnKeyUp = rosterKeyUp
    OnMeasureItem = rosterMeasureItem
    OnMouseDown = rosterMouseDown
    OnMouseMove = rosterMouseMove
    OnMouseUp = rosterMouseUp
    Touch.InteractiveGestures = [igPan, igPressAndTap]
    Touch.InteractiveGestureOptions = [igoPanSingleFingerVertical, igoParentPassthrough]
    Columns = <>
  end
  object MlCntBtn: TRnQButton
    Left = 0
    Top = 37
    Width = 142
    Height = 21
    Align = alTop
    ImageName = 'mail'
    TabOrder = 2
    OnClick = MlCntBtnClick
    Spacing = 0
  end
  object menu: TPopupMenu
    Tag = 666
    Alignment = paRight
    AutoPopup = False
    OnPopup = menuPopup
    Left = 8
    Top = 184
    object Status1: TMenuItem
      Action = mAStatus
    end
    object mainmenuvisibility1: TMenuItem
      Action = mAvisibility
    end
    object mainmenuaddcontacts1: TMenuItem
      Action = mAaddcontacts
      object Whitepages1: TMenuItem
        Action = mAWhitepages
      end
      object byUIN1: TMenuItem
        Action = mAbyUIN
      end
    end
    object mainmenuprivacysecurity1: TMenuItem
      Action = mAprivacysecurity
      object Password1: TMenuItem
        Action = mAPassword
      end
      object in_visiblelist1: TMenuItem
        Action = mAin_visiblelist
      end
      object Lock1: TMenuItem
        Action = mALock
      end
    end
    object mainmenuspecial1: TMenuItem
      Action = mAspecial
      object Viewinfoof1: TMenuItem
        Action = mAViewinfoof
      end
      object Openchatwith1: TMenuItem
        Action = mAOpenchatwith
      end
      object mainmenuoutbox1: TMenuItem
        Action = mAoutbox
      end
      object Contactsdatabase1: TMenuItem
        Action = mAContactsdatabase
      end
      object Showlogwindow1: TMenuItem
        Action = mAShowlogwindow
      end
      object SendanSMS1: TMenuItem
        Action = mASendanSMS
        Visible = False
      end
      object Automessages1: TMenuItem
        Action = mAAutomessages
      end
      object mainmenureloadlang1: TMenuItem
        Action = mAreloadlang
      end
      object mainmenuimportclb: TMenuItem
        Action = mAimportclb
        Visible = False
      end
      object mainmenuexportclb: TMenuItem
        Action = mAexportclb
        Visible = False
      end
      object mmrequestCL: TMenuItem
        Action = mARequestCL
      end
      object mmSinchrServCL: TMenuItem
        Action = mASinchrCL
      end
      object ViewSSI1: TMenuItem
        Action = mAViewSSI
      end
      object Historyutilities1: TMenuItem
        Action = mAHistoryUtils
      end
    end
    object mainmenuthemes1: TMenuItem
      Action = mAthemes
      object mainmenureloadtheme2: TMenuItem
        Action = mAreloadtheme
      end
      object mainmenugetthemes1: TMenuItem
        Action = mARefreshThemeList
      end
      object Opencontactstheme: TMenuItem
        Action = mAThmCntEdt
      end
      object SmilesMenu: TMenuItem
        Action = mASmiles
      end
      object SoundsMenu: TMenuItem
        Action = mASounds
      end
      object N10: TMenuItem
        Caption = '-'
      end
    end
    object mainmenusupport1: TMenuItem
      Action = mAsupport
      AutoHotkeys = maManual
      object Checkforupdates1: TMenuItem
        Action = mACheckforupdates
      end
      object N8: TMenuItem
        Caption = '-'
        Hint = 'web'
      end
      object RQhomepage1: TMenuItem
        Tag = 3010
        Caption = 'R&&Q Portal'
        Hint = 'http://RnQ.ru'
        OnClick = RQhomepage1Click
      end
      object RQHelp1: TMenuItem
        Tag = 3010
        Caption = 'R&&Q Help'
        Hint = 'http://Help.RnQ.ru'
        OnClick = RQHelp1Click
      end
      object MMGenError: TMenuItem
        Caption = 'Generate error'
        OnClick = MMGenErrorClick
      end
    end
    object mmChkInvisAll: TMenuItem
      Action = mAChkInvisAll
    end
    object mainmenugetofflinemsgs1: TMenuItem
      Action = mAgetofflinemsgs
    end
    object mainmenudeleteofflinemsgs1: TMenuItem
      Action = mAdeleteofflinemsgs
    end
    object mainmenuchangeadduser1: TMenuItem
      Action = mAchangeadduser
    end
  end
  object contactMenu: TPopupMenu
    OnPopup = contactMenuPopup
    Left = 40
    Top = 80
    object Sendmessage1: TMenuItem
      Action = ASendmessage1
      Default = True
    end
    object Sendcontacts1: TMenuItem
      Action = ASendcontacts1
    end
    object Sendemail1: TMenuItem
      Action = ASendemail1
    end
    object Sendfile1: TMenuItem
      Action = cASendFile
    end
    object SendSMS1: TMenuItem
      Action = ASendSMS
    end
    object menusendaddedyou1: TMenuItem
      Action = Amenusendaddedyou1
    end
    object Addtoserver1: TMenuItem
      Action = cAAdd2Server
    end
    object authReq: TMenuItem
      Action = cAAuthReqst
    end
    object Authgrant: TMenuItem
      Action = cAAuthGrant
    end
    object Requestavatar1: TMenuItem
      Action = ARequestAvt
    end
    object N9: TMenuItem
      Caption = '-'
    end
    object Viewinfo1: TMenuItem
      Action = AViewinfo1
    end
    object Readautomessage1: TMenuItem
      Action = AReadautomessage1
    end
    object Readextstatus1: TMenuItem
      Action = cAReadXst
    end
    object CheckInvisibility: TMenuItem
      Action = cACheckInvisibility
    end
    object Openincomingfolder1: TMenuItem
      Caption = 'Open incoming folder'
      OnClick = Openincomingfolder1Click
    end
    object Addtocontactlist1: TMenuItem
      Action = AAddtocontactlist1
    end
    object movetogroup1: TMenuItem
      Action = cmAmovetogroup
    end
    object Rename1: TMenuItem
      Action = ARename1
    end
    object menuremovedyou1: TMenuItem
      Action = cARemFrHisCL
    end
    object Makelocal1: TMenuItem
      Action = cAMakeLocal
    end
    object Delete1: TMenuItem
      Action = ADelete1
    end
    object Deleteonlyhistory1: TMenuItem
      Action = cADeleteOH
    end
    object Deletewithhistory1: TMenuItem
      Action = cADeleteWH
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object Visiblelist1: TMenuItem
      Action = AVisiblelist1
    end
    object Invisiblelist1: TMenuItem
      Action = AInvisiblelist1
    end
    object tempvisiblelist1: TMenuItem
      Action = Atempvisiblelist1
    end
    object Ignorelist1: TMenuItem
      Action = AIgnorelist1
    end
    object Checkinginvislist1: TMenuItem
      Action = cAChkInvisList
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object UIN1: TMenuItem
      Action = AUIN1
    end
    object IP1: TMenuItem
      Action = AIP1
    end
    object N5: TMenuItem
      Caption = '-'
    end
  end
  object divisorMenu: TPopupMenu
    OnPopup = divisorMenuPopup
    Left = 40
    Top = 16
    object Newgroup1: TMenuItem
      Action = ANewgroup1
    end
    object Addcontact1: TMenuItem
      Action = gmANewContact
      Enabled = False
    end
    object N6: TMenuItem
      Caption = '-'
    end
    object Openallgroups1: TMenuItem
      Action = AOpenallgroups1
    end
    object Closeallgroups1: TMenuItem
      Action = ACloseallgroups1
    end
    object Deleteallemptygroups1: TMenuItem
      Action = ADeleteallemptygroups1
    end
    object N7: TMenuItem
      Caption = '-'
    end
    object Showgroups1: TMenuItem
      Action = AShowgroups1
    end
    object Showonlyonlinecontacts1: TMenuItem
      Action = AShowonlyonlinecontacts1
    end
    object menushowonlyimvisibleto1: TMenuItem
      Action = Amenushowonlyimvisibleto1
    end
    object Showallcontactsinone1: TMenuItem
      Action = AContInOne
    end
  end
  object groupMenu: TPopupMenu
    OnPopup = groupMenuPopup
    Left = 40
    Top = 48
    object Newgroup2: TMenuItem
      Action = gmANewgroup
    end
    object Newcontact1: TMenuItem
      Action = gmANewContact
    end
    object Addtoserver2: TMenuItem
      Action = gmAAdd2Server
    end
    object N3: TMenuItem
      Caption = '-'
    end
    object Renamegroup1: TMenuItem
      Action = gmARenamegroup
    end
    object Makelocal2: TMenuItem
      Action = gmAMakeLocal
    end
    object Deletegroup1: TMenuItem
      Action = gmADeletegroup
    end
    object Moveallcontactsto1: TMenuItem
      Action = gmAMoveallcontactsto
    end
    object Allcontactsvisibility1: TMenuItem
      Action = gmAAllcontactsvisibility
      object tempvisiblelist2: TMenuItem
        Action = gmAVtempvisiblelist
      end
      object tovisiblelist1: TMenuItem
        Action = gmAVtovisiblelist
      end
      object toinvisiblelist1: TMenuItem
        Action = gmAVtoinvisiblelist
      end
      object tonormalvisibility1: TMenuItem
        Action = gmAVtonormalvisibility1
      end
    end
    object N4: TMenuItem
      Caption = '-'
    end
    object Showgroups2: TMenuItem
      Tag = 3003
      Action = AShowgroups1
    end
  end
  object timer: TTimer
    Enabled = False
    Interval = 100
    OnTimer = OnTimer
    Left = 80
    Top = 144
  end
  object ActList: TActionList
    Left = 80
    Top = 88
    object ASendmessage1: TAction
      Category = 'contactMenu'
      Caption = 'Send message'
      HelpKeyword = 'msg'
      HelpType = htContext
      OnExecute = Sendmessage1Click
    end
    object ASendcontacts1: TAction
      Category = 'contactMenu'
      Caption = 'Send contacts'
      HelpKeyword = 'contacts'
      HelpType = htContext
      OnExecute = Sendcontacts1Click
    end
    object ASendemail1: TAction
      Category = 'contactMenu'
      Caption = 'Send e-mail'
      HelpKeyword = 'mail'
      HelpType = htContext
      OnExecute = Sendemail1Click
      OnUpdate = ASendemail1Update
    end
    object ASendSMS: TAction
      Category = 'contactMenu'
      Caption = 'Send SMS'
      HelpKeyword = 'sms'
      OnExecute = ASendSMSExecute
      OnUpdate = ASendSMSUpdate
    end
    object cASendFile: TAction
      Category = 'contactMenu'
      Caption = 'Send file'
      HelpKeyword = 'file'
      OnExecute = cASendFileExecute
      OnUpdate = cASendFileUpdate
    end
    object Amenusendaddedyou1: TAction
      Category = 'contactMenu'
      Caption = 'Send added-you'
      HelpKeyword = 'addedyou'
      HelpType = htContext
      OnExecute = menusendaddedyou1Click
    end
    object cAAuthGrant: TAction
      Category = 'contactMenu'
      Caption = 'Grant Authorization'
      HelpKeyword = 'auth.grant'
      OnExecute = cAAuthGrantExecute
      OnUpdate = cAAuthGrantUpdate
    end
    object cAAuthReqst: TAction
      Category = 'contactMenu'
      Caption = 'Request Authorization'
      HelpKeyword = 'auth.req'
      OnExecute = authReqClick
      OnUpdate = cAAuthReqstUpdate
    end
    object ARequestAvt: TAction
      Category = 'contactMenu'
      Caption = 'Request avatar'
      HelpKeyword = 'avatar'
      OnExecute = Requestavatar1Click
      OnUpdate = ARequestAvtUpdate
    end
    object cARemFrHisCL: TAction
      Category = 'contactMenu'
      Caption = 'Remove me from his CL'
      HelpKeyword = 'delete'
      OnExecute = cARemFrHisCLExecute
      OnUpdate = cAAuthGrantUpdate
    end
    object Asplit1: TAction
      Category = 'contactMenu'
      Caption = '-'
    end
    object AViewinfo1: TAction
      Category = 'contactMenu'
      Caption = 'View info'
      HelpKeyword = 'info'
      HelpType = htContext
      OnExecute = Viewinfo1Click
    end
    object cAReadXst: TAction
      Category = 'contactMenu'
      Caption = 'Read XStatus'
      OnExecute = Readextstatus1Click
      OnUpdate = cAReadXstUpdate
    end
    object AReadautomessage1: TAction
      Category = 'contactMenu'
      Caption = 'Read auto-message'
      HelpKeyword = 'msg'
      HelpType = htContext
      OnExecute = Readautomessage1Click
      OnUpdate = AReadautomessage1Update
    end
    object cACheckInvisibility: TAction
      Category = 'contactMenu'
      Caption = 'Check invisibility'
      HelpKeyword = 'visibility'
      OnExecute = cACheckInvisibilityExecute
      OnUpdate = cACheckInvisibilityUpdate
    end
    object AAddtocontactlist1: TAction
      Category = 'contactMenu'
      Caption = 'Add to contact list'
      HelpKeyword = 'add.contact'
      HelpType = htContext
      OnExecute = ANothingExecute
    end
    object cAAdd2Server: TAction
      Category = 'contactMenu'
      Caption = 'Add to server'
      HelpKeyword = 'add'
      HelpType = htContext
      OnExecute = cAAdd2ServerExecute
      OnUpdate = cAAdd2ServerUpdate
    end
    object cAMakeLocal: TAction
      Category = 'contactMenu'
      Caption = 'Make local'
      HelpKeyword = 'contact.local'
      HelpType = htContext
      OnExecute = cAMakeLocalExecute
      OnUpdate = cAMakeLocalUpdate
    end
    object cmAmovetogroup: TAction
      Category = 'contactMenu'
      Caption = 'Move to group'
      HelpKeyword = 'close.group'
      HelpType = htContext
      OnExecute = ANothingExecute
      OnUpdate = cmAmovetogroupUpdate
    end
    object ARename1: TAction
      Category = 'contactMenu'
      Caption = 'Rename'
      HelpKeyword = 'rename'
      HelpType = htContext
      OnExecute = Rename1Click
      OnUpdate = ARename1Update
    end
    object ADelete1: TAction
      Category = 'contactMenu'
      Caption = 'Delete'
      HelpKeyword = 'delete'
      OnExecute = Delete1Click
      OnUpdate = ADelete1Update
    end
    object cADeleteOH: TAction
      Category = 'contactMenu'
      Caption = 'Delete only history'
      HelpKeyword = 'delete'
      OnExecute = cADeleteOHExecute
      OnUpdate = cADeleteOHUpdate
    end
    object cADeleteWH: TAction
      Category = 'contactMenu'
      Caption = 'Delete with history'
      HelpKeyword = 'delete'
      OnExecute = cADeleteWHExecute
      OnUpdate = cADeleteWHUpdate
    end
    object Asplit2: TAction
      Category = 'contactMenu'
      Caption = '-'
    end
    object AVisiblelist1: TAction
      Category = 'contactMenu'
      Caption = 'Visible list'
      OnExecute = Visiblelist1Click
      OnUpdate = AVisiblelist1Update
    end
    object AInvisiblelist1: TAction
      Category = 'contactMenu'
      Caption = 'Invisible list'
      OnExecute = invisiblelist1Click
      OnUpdate = AInvisiblelist1Update
    end
    object Atempvisiblelist1: TAction
      Category = 'contactMenu'
      Caption = 'Temporary visible list'
      OnExecute = tempvisiblelist1Click
      OnUpdate = Atempvisiblelist1Update
    end
    object AIgnorelist1: TAction
      Category = 'contactMenu'
      Caption = 'Ignore list'
      OnExecute = Ignorelist1Click
      OnUpdate = AIgnorelist1Update
    end
    object cAChkInvisList: TAction
      Category = 'contactMenu'
      Caption = 'Check-invis list'
      OnExecute = cAChkInvisListExecute
      OnUpdate = cAChkInvisListUpdate
    end
    object Asplit3: TAction
      Category = 'contactMenu'
      Caption = '-'
    end
    object AUIN1: TAction
      Category = 'contactMenu'
      Hint = 'if you click the UIN will be copied into clipboard'
      OnExecute = UIN1Click
      OnUpdate = AUIN1Update
    end
    object AIP1: TAction
      Category = 'contactMenu'
      Hint = 'if you click the IP address will be copied into clipboard'
      OnExecute = IP1Click
      OnUpdate = AIP1Update
    end
    object ANewgroup1: TAction
      Category = 'divisorMenu'
      Caption = 'New group'
      HelpKeyword = 'new.group'
      OnExecute = Newgroup1Click
    end
    object ADivisor1: TAction
      Category = 'divisorMenu'
      Caption = '-'
    end
    object AOpenallgroups1: TAction
      Category = 'divisorMenu'
      Caption = 'Open all groups'
      HelpKeyword = 'open.group'
      OnExecute = Openallgroups1Click
    end
    object ACloseallgroups1: TAction
      Category = 'divisorMenu'
      Caption = 'Close all groups'
      HelpKeyword = 'close.group'
      OnExecute = Closeallgroups1Click
    end
    object ADeleteallemptygroups1: TAction
      Category = 'divisorMenu'
      Caption = 'Delete all empty groups'
      HelpKeyword = 'delete'
      OnExecute = Deleteallemptygroups1Click
    end
    object Adivisor2: TAction
      Category = 'divisorMenu'
      Caption = 'Adivisor2'
    end
    object AShowgroups1: TAction
      Category = 'divisorMenu'
      Caption = 'Show groups'
      OnExecute = Showgroups1Click
      OnUpdate = AShowgroups1Update
    end
    object AShowonlyonlinecontacts1: TAction
      Category = 'divisorMenu'
      Caption = 'Show only online contacts'
      OnExecute = Showonlyonlinecontacts1Click
      OnUpdate = AShowonlyonlinecontacts1Update
    end
    object Amenushowonlyimvisibleto1: TAction
      Category = 'divisorMenu'
      Caption = 'Show only contacts i'#39'm visible to'
      OnExecute = menushowonlyimvisibleto1Click
      OnUpdate = Amenushowonlyimvisibleto1Update
    end
    object gmANewgroup: TAction
      Category = 'groupMenu'
      Caption = 'New group'
      HelpKeyword = 'new.group'
      OnExecute = Newgroup1Click
    end
    object gmAdivisor1: TAction
      Category = 'groupMenu'
      Caption = '-'
    end
    object gmARenamegroup: TAction
      Category = 'groupMenu'
      Caption = 'Rename group'
      HelpKeyword = 'rename'
      OnExecute = Renamegroup1Click
    end
    object gmADeletegroup: TAction
      Category = 'groupMenu'
      Caption = 'Delete group'
      HelpKeyword = 'delete'
      OnExecute = Deletegroup1Click
    end
    object gmAMoveallcontactsto: TAction
      Category = 'groupMenu'
      Caption = 'Move all contacts to'
      HelpKeyword = 'close.group'
      OnExecute = ANothingExecute
    end
    object gmAAllcontactsvisibility: TAction
      Category = 'groupMenu'
      Caption = 'All contacts visibility'
      HelpKeyword = 'close.group'
      OnExecute = ANothingExecute
    end
    object gmAVtempvisiblelist: TAction
      Category = 'groupMenu'
      Caption = 'temporary visible list'
      OnExecute = tempvisiblelist2Click
    end
    object gmAVtovisiblelist: TAction
      Category = 'groupMenu'
      Caption = 'visible list'
      OnExecute = tovisiblelist1Click
    end
    object gmAVtoinvisiblelist: TAction
      Category = 'groupMenu'
      Caption = 'invisible list'
      OnExecute = toinvisiblelist1Click
    end
    object gmAVtonormalvisibility1: TAction
      Category = 'groupMenu'
      Caption = 'normal visibility'
      OnExecute = tonormalvisibility1Click
    end
    object gmADivisor2: TAction
      Category = 'groupMenu'
      Caption = '-'
    end
    object gmAShowgroups: TAction
      Category = 'groupMenu'
      Caption = 'Show groups'
      OnExecute = Showgroups2Click
      OnUpdate = AShowgroups1Update
    end
    object mAStatus: TAction
      Category = 'menu'
      Caption = 'Status'
      OnExecute = ANothingExecute
      OnUpdate = mAStatusUpdate
    end
    object mAvisibility: TAction
      Category = 'menu'
      Caption = 'Visibility'
      OnExecute = ANothingExecute
      OnUpdate = mAvisibilityUpdate
    end
    object mAaddcontacts: TAction
      Category = 'menu'
      Caption = 'Add contacts'
      HelpKeyword = 'add.contact'
      OnExecute = ANothingExecute
    end
    object mAWhitepages: TAction
      Category = 'menu'
      Caption = 'Search at white pages'
      HelpKeyword = 'wp'
      OnExecute = Whitepages1Click
    end
    object mAbyUIN: TAction
      Category = 'menu'
      Caption = 'by UIN'
      HelpKeyword = 'uin'
      OnExecute = byUIN1Click
    end
    object mAprivacysecurity: TAction
      Category = 'menu'
      Caption = 'Privacy && Security'
      HelpKeyword = 'key'
      OnExecute = ANothingExecute
    end
    object mAPassword: TAction
      Category = 'menu'
      Caption = 'Password'
      HelpKeyword = 'key'
      OnExecute = password1Click
    end
    object mAin_visiblelist: TAction
      Category = 'menu'
      Caption = 'in/visible list'
      HelpKeyword = 'visibility'
      OnExecute = in_visiblelist1Click
    end
    object mALock: TAction
      Category = 'menu'
      Caption = 'Lock'
      HelpKeyword = 'key'
      OnExecute = Lock1Click
    end
    object mAspecial: TAction
      Category = 'menu'
      Caption = 'Special'
      HelpKeyword = 'special'
      OnExecute = ANothingExecute
    end
    object mAViewinfoof: TAction
      Category = 'menu'
      Caption = 'View info of...'
      HelpKeyword = 'info'
      OnExecute = Viewinfoof1Click
    end
    object mAOpenchatwith: TAction
      Category = 'menu'
      Caption = 'Open chat with...'
      HelpKeyword = 'msg'
      OnExecute = Openchatwith1Click
    end
    object mAContactsdatabase: TAction
      Category = 'menu'
      Caption = 'Contacts database'
      HelpKeyword = 'db'
      OnExecute = Contactsdatabase1Click
    end
    object mAShowlogwindow: TAction
      Category = 'menu'
      Caption = 'Show log window'
      HelpKeyword = 'history'
      OnExecute = Showlogwindow1Click
    end
    object mASendanSMS: TAction
      Category = 'menu'
      Caption = 'Send an SMS'
      HelpKeyword = 'sms'
      OnExecute = SendanSMS1Click
    end
    object mAAutomessages: TAction
      Category = 'menu'
      Caption = 'Auto-message'
      HelpKeyword = 'msg'
      OnExecute = Automessage1Click
    end
    object mAreloadlang: TAction
      Category = 'menu'
      Caption = 'Reload current lang'
      HelpKeyword = 'refresh'
      OnExecute = mainmenureloadlang1Click
    end
    object mAimportclb: TAction
      Category = 'menu'
      Caption = 'Import from ICQ contacts file'
      HelpKeyword = 'import.clb'
      OnExecute = mainmenuimportclbClick
    end
    object mAexportclb: TAction
      Category = 'menu'
      Caption = 'Export to ICQ contacts file'
      HelpKeyword = 'export.clb'
      OnExecute = mainmenuexportclbClick
    end
    object mAthemes: TAction
      Category = 'menu'
      Caption = 'Themes'
      HelpKeyword = 'theme'
      OnExecute = ANothingExecute
    end
    object mAreloadtheme: TAction
      Category = 'menu'
      Caption = 'Reload current theme'
      HelpKeyword = 'refresh'
      OnExecute = mainmenureloadtheme1Click
    end
    object mAsupport: TAction
      Category = 'menu'
      Caption = 'Support'
      HelpKeyword = 'support'
      OnExecute = ANothingExecute
    end
    object mACheckforupdates: TAction
      Category = 'menu'
      Caption = 'Check for updates'
      HelpKeyword = 'download'
      OnExecute = Checkforupdates1Click
    end
    object mAoutbox: TAction
      Category = 'menu'
      Caption = 'Outbox'
      HelpKeyword = 'outbox'
      OnExecute = Outbox1Click
    end
    object mAgetofflinemsgs: TAction
      Category = 'menu'
      Caption = 'Get offline messages'
      HelpKeyword = 'down'
      OnExecute = Getofflinemessages1Click
      OnUpdate = mAgetofflinemsgsUpdate
    end
    object mAdeleteofflinemsgs: TAction
      Category = 'menu'
      Caption = 'Delete offline messages'
      HelpKeyword = 'delete'
      OnExecute = Deleteofflinemessages1Click
      OnUpdate = mAdeleteofflinemsgsUpdate
    end
    object mAchangeadduser: TAction
      Category = 'menu'
      Caption = 'Users (change/add/remove)'
      HelpKeyword = 'users'
      OnExecute = Changeoradduser1Click
    end
    object mARequestCL: TAction
      Category = 'menu'
      Caption = 'Load contact list from Server'
      HelpKeyword = 'request.contact.list'
      OnExecute = mARequestCLExecute
      OnUpdate = mARequestCLUpdate
    end
    object mASinchrCL: TAction
      Category = 'menu'
      Caption = 'Syncronize CL with Server'
      OnExecute = mASinchrCLExecute
      OnUpdate = mASinchrCLUpdate
    end
    object mAChkInvisAll: TAction
      Category = 'menu'
      Caption = 'Check Invisibility list'
      HelpKeyword = 'check.invisibility.list'
      OnExecute = mAChkInvisAllExecute
      OnUpdate = mAChkInvisAllUpdate
    end
    object mAHistoryUtils: TAction
      Category = 'menu'
      Caption = 'History synchronization'
      HelpKeyword = 'history.sync'
      OnExecute = mAHistoryUtilsExecute
    end
    object mARefreshThemeList: TAction
      Category = 'menu'
      Caption = 'Refresh theme-list'
      HelpKeyword = 'reload.theme.list'
      OnExecute = mainmenugetthemes1Click
    end
    object AContInOne: TAction
      Category = 'divisorMenu'
      Caption = 'Not separate by online\offline'
      OnExecute = Showallcontactsinone1Click
      OnUpdate = AContInOneUpdate
    end
    object gmANewContact: TAction
      Category = 'groupMenu'
      Caption = 'Add contact'
      HelpKeyword = 'add.contact'
      OnExecute = byUIN1Click
    end
    object gmANewContactLocal: TAction
      Category = 'groupMenu'
      Caption = 'Add contact locally'
      HelpKeyword = 'add.contact'
    end
    object gmAAdd2Server: TAction
      Category = 'groupMenu'
      Caption = 'Add to server'
      HelpKeyword = 'add'
      HelpType = htContext
      OnExecute = gmAAdd2ServerExecute
      OnUpdate = gmAAdd2ServerUpdate
    end
    object gmAMakeLocal: TAction
      Category = 'groupMenu'
      Caption = 'Make local'
      HelpKeyword = 'down'
      HelpType = htContext
      OnExecute = gmAMakeLocalExecute
      OnUpdate = gmAMakeLocalUpdate
    end
    object mAThmCntEdt: TAction
      Category = 'menu'
      Caption = 'Open contacts-theme'
      HelpKeyword = 'theme'
      Hint = 'Open contacts-theme in notepad'
      OnExecute = mAThmCntEdtExecute
    end
    object mAViewSSI: TAction
      Category = 'menu'
      Caption = 'View SSI'
      HelpKeyword = 'ssi'
      OnExecute = ViewSSI1Click
      OnUpdate = mAViewSSIUpdate
    end
    object mASmiles: TAction
      Category = 'menu'
      Caption = 'Smiles'
      HelpKeyword = 'smiles'
      OnExecute = ANothingExecute
    end
    object mASounds: TAction
      Category = 'menu'
      Caption = 'Sounds'
      HelpKeyword = 'sounds'
      OnExecute = ANothingExecute
    end
  end
end
