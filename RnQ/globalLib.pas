{
  This file is part of R&Q.
  Under same license
}
unit globalLib;
{$I RnQConfig.inc}
{$I NoRTTI.inc}

interface

uses
  Windows, sysutils, graphics, controls, comctrls, types, classes, forms, messages,
  iniFiles,
  events,
 {$IFDEF ICQ_ONLY}
    ICQv9,
  ICQConsts,
 {$ENDIF ICQ_ONLY}
  RnQConst,
  RnQProtocol,
  groupsLib,
  roasterLib,
  pluginLib, RnQtrayLib,
  outboxLib, uinlistLib,
  RQThemes, RDGlobal,
  themesLib,
  RnQPrefsTypes,
 {$IFDEF PREF_IN_DB}
  DBPrefsLib,
 {$ELSE ~PREF_IN_DB}
  RnQPrefsLib,
 {$ENDIF PREF_IN_DB}
  RnQMacros
  ;


type
  TRnQPageControl = Class(TPageControl)
    procedure WMEraseBkGnd(var Message: TWMEraseBkGnd);
//    procedure DrawTab(TabIndex: Integer; const Rect: TRect; Active: Boolean); virtual;

  end;

type
  TRnQViewInfoForm = class(TForm)
    contact: TRnQContact;
    procedure updateInfo; virtual; Abstract;
    constructor doAll(owner_: Tcomponent; c: TRnQContact); virtual; Abstract;
   public
    readOnlyContact: Boolean;
    procedure UpdateCntAvatar; virtual; Abstract;
    procedure ClearAvatar; virtual; Abstract;
    procedure UpdateClock; virtual; Abstract;
   end;

type
  PRnQUser = ^TRnQUser;
  TRnQUser = record
 {$IFDEF ICQ_ONLY}
     proto: TICQProtoClass;
 {$ELSE ~ICQ_ONLY}
     proto: TRnQProtoClass;
 {$ENDIF ICQ_ONLY}
     uin: TUID;
     name, //uinStr,
     SubPath, path, prefix: string;
     SSI: Boolean;
//     pwd: ShortString;
     pwd: String;
     encr: Boolean;
   end;


type
  TRnQAccount = record
     ProtoPath: String;
//     db: TZipFile;
 {$IFDEF ICQ_ONLY}
     AccProto: TicqSession;
 {$ELSE ~ICQ_ONLY}
//     AccProto: IRnQProtocol;
     AccProto: TRnQProtocol;
 {$ENDIF ICQ_ONLY}
     outbox: Toutbox;
     acks: Toutbox;
   end;

const
   ChkInvisDiv = 64;

type
  Tbehaviours = array [1..EK_last] of Tbehaviour;

var
  outboxprocessChk: Boolean = True;

  ContactsTheme: TRQtheme;
//  ICQ: TicqSession;
//  MainProto: IRnQProtocol;
//  MainProto: TRnQProtocol;
  Account: TRnQAccount;
  MainPrefs: TRnQPref;

//  userPath: String;
  AccPath: String;
  FileSavePath: String;
  StickerPath      : String;
  MakeBackups: Boolean;

//  gmtCodes,languageCodes,countryCodes,pastCodes,ageCodes,interestCodes,genderCodes :Tcodes;
  eventQ    : TeventQ;
  plugins   : Tplugins;
  progStart : double;
  statusIcon: TstatusIcon;
  hintMode  : (HM_null, HM_url, HM_comm);
  usertime  : integer;
  startTime: TdateTime;
  WM_TASKBARCREATED: longword;
//  contactsPnl,
//  freePnl: TstatusPanel;
  contactsPnlStr: String;
  locked, startingLock: boolean;
  hotkeysEnabled: boolean;
  CloseFTWndAuto: Boolean;
  outboxSbarRect: Trect;
  supportedBehactions: array [1..EK_last] of set of Tbehaction;
  // here i bookmark last selected node, cause it could change between clicks
  clickedContact: TRnQContact;
//  focusedCnt: TRnQContact;
  clickedGroup: integer;
  clickedNode: Tnode;

  prefHeight: integer;
  saveDBtimer2: integer;
//  loginServer: string;
  lastServerIP, lastserverAddr: string;
  cmdLinePar: record
     startUser: TUID;
     extraini,
     userPath,
     mainPath,
     logpath,
     useproxy: String;
     ssi: Boolean;
     Debug: Boolean;
//     NoSound: Boolean;
    end;
  lastOnTimer: Tdatetime;
  showRosterTimer: integer;
  removeTempVisibleTimer: integer;
  removeTempVisibleContact: TRnQContact;
  inactiveTime: integer;
  noOncomingCounter: integer; // if > 0, IE_oncoming means people was here before (used in the login process)
  childWindows: Tlist;
  MustQuit: Boolean = False; // Вызывается из плагинов, чтобы их нормально завершить успеть.

  docking: record
    pos: (DP_right, DP_left);
    bakOfs, bakSize: Tpoint;
    enabled,
    active,
    appbar,
    appbarFlag,
    tempOff,
    Dock2Chat,
    Docked2chat: boolean;
    end;
  fantomWork,
  ShowUINDelimiter,
  XStatusAsMain,
  blinkWithStatus,
  menuViaMacro,
  saveOutboxDelayed,
  saveInboxDelayed,
  saveGroupsDelayed,
  appBarResizeDelayed,
  saveListsDelayed,
  saveCfgDelayed,
  autosizeDelayed,
  dbUpdateDelayed,
  rosterRepaintDelayed,          // requires a roasterLib.repaint
  rosterRebuildDelayed: boolean; // requires a roasterLib.rebuild
  stayConnected, running, resolving: boolean;
  chatfrmXY: TformXY;
  oldForeWindow: Thandle;
  bringForeground: Thandle;
  groups: Tgroups;
  searching: string;
  usersPath: string;
  lastUser: TUID;
  userCharSet: integer;
  imAwaySince: Tdatetime;
  lastSearchTime: Tdatetime;
  lastFilterEditTime: Tdatetime;
  selectedColor: Tcolor;
  dialogFrm: Tform;
  uinlists: Tuinlists;
//  myStatus,

//  visibleList, invisibleList,
   ignoreList,
   notInList,
   updateViewInfoQ, retrieveQ, reqAvatarsQ , reqXStatusQ
      :TRnQCList;
  // timers
  outboxCount: integer;
  blinkCount: word;
  delayCount: word;
  longDelayCount,
  reconnectdelayCount: byte;
  flapSecs: byte;
  blinking: boolean;
  toReconnectTime: integer;
  // options
  focusOnChatPopup: boolean;
  quoting: record
    cursorBelow: boolean;
    quoteselected: boolean;
    width: integer;
   end;
  rosterItalic: integer;
  behaviour: Tbehaviours;
  spamfilter: record
    ignoreNIL,
    warn,
    addToHist,
    ignorepagers,
    ignoreauthNIL,
    // rules
     useBot,
     useBotInInvis,
     UseBotFromFile,
    notNIL,
    notEmpty,
    nobadwords,
    multisend: Boolean;
     BotTryesCount: Integer;
    uingt: integer;
    badwords: string;
    quests: TQuestAnsArr;
   end;
  histCrypt: record
    enabled: boolean;
    savePwd: boolean;
    pwdKey: integer;
    pwd: String;
   end;
  AccPass: String;
  autoaway: record
//    time: cardinal;
    time: Integer;
//  {$IFDEF WIN98_SUP}
//    lastMousePos :Tpoint;
//    lastKeybPos :integer;
//  {$ENDIF WIN98_SUP}

    away, na, ss, boss, autoexit,
    clearXSts, setVol: boolean;
    awayTime, naTime: Integer;
    msg: string;
    triggered: (TR_none, TR_away, TR_na);
    bakstatus: byte;
    bakxstatus: byte;
    bakmsg: string;
     vol: Integer;
   end;
  BossMode: Record
    isBossKeyOn,
    activeChat,
    toShowChat,
    toShowCL: Boolean;
   end;

//  themeprops: array of TthemeProperty;
  browserCmdLine: String;
  FTOutPorts: String;
  splitY, inactiveHideTime, blinkSpeed: integer;

  TipsMaxAvtSize: Integer;
  TipsMaxAvtSizeUse: Boolean;

  useDefaultBrowser: boolean;
  minOnOff: boolean;
  minOnOffTime: integer; // in seconds
  autostartUIN: TUID;
  RnQStartingStatus, RnQStartingVisibility: Int8;
  lastStatus, lastStatusUserSet: Int8;
  rosterTitle: string;
  automessages: Tstrings;
  keepalive: record
    enabled: boolean;
    freq: integer;
    timer: integer;
   end;
  fixingWindows: record
    lastWidth, lastRightSpace: integer;
    onTheRight: boolean;
   end;
  sendOnEnter,
  tempBlinkTime,
  wheelVelocity: integer;
  disabledPlugins: string;
  sortBy: TsortBy;
  transparency: record
    forRoster, forChat, forTray: boolean;
    chgOnMouse: Boolean;
    active, inactive: integer;
    tray: Integer;
   end;
  macros: Tmacros;
  splashFrm: Tform;
  splashImgElm: TRnQThemedElementDtls;
  checkupdate: record
    autochecking,
    checking,
    enabled,
    betas: boolean;
    every: integer;
    lastSerial: integer;
    last: Tdatetime;
//    info: string;
   end;
  fontstylecodes: record
    enabled: boolean;
   end;

 {$IFDEF CHAT_SPELL_CHECK}
  EnableSpellCheck: Boolean;
//  spellLanguages: TStringList = nil;
  spellLanguageMain: String;
  spellErrorColor: TColor;
  spellErrorStyle: Integer;
 {$ENDIF CHAT_SPELL_CHECK}

   {$IFDEF CHECK_INVIS}
    checkInvQ, autoCheckInvQ: TRnQCList;
  checkInvis: record
      ChkInvisInterval: Double;
      lastAllChkTime: TDateTime;
      lastChkTime: TDateTime;
      CList: TRnQCList;
      AutoCheckInterval: Integer;
      ShowInvisibility,
      AutoCheck,
      AutoCheckGoOfflineUsers,
      AutoCheckOnSend: Boolean;
      Method: Byte;
    end;
    showCheckedInvOfl: Boolean;// = True;
   {$ENDIF}
  //booleans
  autoRequestXsts,
  warnVisibilityExploit,
  warnVisibilityAutoMsgReq,
  ShowHintsInChat,
//  showClientID,
  connectOnConnection,
  reopenchats,
  closeChatOnSend,
  ClosePageOnSingle,
  rosterbarOnTop,
  filterBarOnTop,
  animatedRoster,
  showMainBorder,
  showVisAndLevelling,
  getOfflineMsgs,
  delOfflineMsgs,
  lockOnStart,
  closeAuthAfterReply,
  autoConsumeEvents,
  DsblEvnt4ClsdGrp,
  enableIgnoreList,
  inactiveHide,
  doFixWindows,
  minimizeRoster,
  autoReconnect,
  autoReconnectStop,
  SaveIP,
  startMinimized,
  autoSwitchKL,
  popupAutoMsg,
  okOn2enter_autoMsg,
  skipSplash,
  oncomingOnAway,
  enteringProtoPWD,
  check4readonly,
  dontSavePwd,
  clearPwdOnDSNCT,
  sendTheAddedYou,
  showStatusOnTabs,
//  webaware,
  singleDefault,
  texturizedWindows,
  showGroups,
  showEmptyGroups,
  autoCopyHist,
//  bViewTextWrap,
  indentRoster,
  showDisconnectedDlg,
  autoConnect,
  autoDeselect,
  alwaysOnTop,
  chatAlwaysOnTop,
  useLastStatus,
  useSmiles,
  quitconfirmation,
  showOncomingDlg,
  showOnlyOnline,
  showOnlyImVisibleTo,
  showUnkAsOffline,
  OnlOfflInOne,
  autosizeFullRoster,
  autoSizeRoster,
  autosizeUp,
  useSingleClickTray,
//  SupportTyping, // In ICQv9.pas
  avatarShowInChat,
  avatarShowInHint,
  avatarShowInTray,
  showXStatusMnu,
  showRQP,
  UseContactThemes,
  xxx,
  usePlugPanel,
  useMainPlugPanel,
  useCtrlNumInstAlt,
  useSystemCodePage,
  askPassOnBossKeyOn,
  helpExists
              : boolean;
//  AutoCheckGoOfflineUsers: Boolean;

//  haveToApplyTheme: Boolean;
  NILdoWith: byte; // 0 - ask; 1 = clear all; 2 = save
  typingInterval: Integer;
  prefPages: array of TPrefPage;
  Mutex: Cardinal;
  portsListen: TPortList;
  cache: String;
  imgCacheInfo: TMemIniFile;

//const
//  supportInvisCheck = false;

  procedure AddPrefPage1(index: Byte; cl: TPrefFrameClass; Cpt: String);
  procedure ClearPrefPages;

 type
  pTCE = ^TCE;
  TCE = packed record
//    history0: Tobject;  // a probably wanted history, won't be saved to disk
    notes: string;
    lastAutoMsg: string;
    lastEventTime: Tdatetime;
    lastMsgTime: TdateTime;
    lastOncoming: Tdatetime;
    lastPriority: integer;
    node: Tnode;
    keylay: integer;
    askedAuth: boolean;
    dontdelete: boolean;
    toquery: boolean;
   end;

type
TUpdateLayeredWindow = function(Handle: THandle;
                                hdcDest: HDC;
                                pptDst: PPoint;
                                _psize: PSize;
                                hdcSrc: HDC;
                                pptSrc: PPoint;
                                crKey: COLORREF;
                                pblend: PBLENDFUNCTION;
                                dwFlags: DWORD): Boolean; stdcall;

var
  g_hLib_User32: Cardinal;
  g_pUpdateLayeredWindow: TUpdateLayeredWindow;
                                

implementation

uses
  Themes;

procedure ClearPrefPages;
var
  i: Integer;
begin
  if Length(prefPages) > 0 then
   for I := 0 to Length(prefPages) - 1 do
    FreeAndNil(prefPages[I]);
{  with prefPages[I] do
   begin
     Free;
   end;}
  SetLength(prefPages, 0);
end;

procedure AddPrefPage1(index: Byte; cl: TPrefFrameClass; Cpt: String);
var
  i: Integer;
begin
  I := length(prefPages);
  SetLength(prefPages, I+1);
  prefPages[I] := TPrefPage.Create;
  with prefPages[I] do
   begin
     idx := index;
     frameClass := cl;
     Name := Cpt;
     Caption := Cpt;
   end;
end;

procedure TRnQPageControl.WMEraseBkGnd(var Message: TWMEraseBkGnd);
begin
//  if (not ThemeServices.ThemesEnabled) or (not ParentBackground) then
  if (not StyleServices.Enabled) or (not ParentBackground) then
    inherited
  else
    Message.Result := 1;
end;

end.

