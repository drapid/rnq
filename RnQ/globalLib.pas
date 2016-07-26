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
    icqv9,
  ICQConsts,
 {$ENDIF ICQ_ONLY}
//  contacts,
  RnQProtocol,
  groupsLib,
  roasterLib,
  pluginLib, RDtrayLib,
  outboxLib, uinlistLib,
  RQThemes, RDGlobal,
  themesLib,
  RnQMacros, RnQPrefsLib,
  RnQZip
  ;


const
//  PREVIEWversion = True;
//  PREVIEWversion = False;
  PREVIEWversion =
  {$IFDEF EUREKALOG}
                True;
  {$ELSE NO_EUREKALOG}
                False;
  {$ENDIF EUREKALOG}

//  PREVIEWversion = True;
  TestVersion    = False;

 {$IFDEF RNQ_FULL}
   LiteVersion = False;
 {$ELSE}
   LiteVersion = True;
 {$ENDIF}
//  ANDRQversion:Longword=$00090412;  // remember: it's hex
//  RnQversion:Longword = $000A00DB;  // remember: it's hex
  RQversion:Longword = $000A01FF;  // remember: it's hex
 {$IFDEF DB_ENABLED}
  RnQBuild = ;
 {$ELSE ~DB_ENABLED}
  RnQBuild = 1125;
  PIC_CLIENT_LOGO                 = TPicName('rnq');
 {$ENDIF ~DB_ENABLED}
//  {$Include RnQBuiltTime.inc}
  {$I RnQBuiltTime.inc}
//  BuiltTime = BuiltTime;
//  BuiltTime = 39163.6284508449;

  GAP_SIZEd2 = 3;
  GAP_SIZE   = 6;
  GAP_SIZE2  = 12;
  FRM_HEIGHT = 400;
  FRM_WIDTH  = 420;
type
  TwhatForm=(WF_PREF, WF_USERS, WF_WP, WF_WP_MRA, WF_SEARCH);
  TfrmViewMode = (vmFull, vmShort);

  TformXY=record
    top,left,height,width:integer;
    maximized:boolean;
    end;
  TsortBy=( SB_NONE, SB_ALPHA, SB_EVENT, SB_STATUS );
  Tbehaction=(BE_TRAY, BE_SOUND, BE_OPENCHAT, BE_HISTORY, BE_SAVE, BE_TIP, BE_POPUP, BE_FLASHCHAT, BE_BALLOON);
  Tbehaviour=record
    trig:set of Tbehaction;
    tiptime:integer;
    tiptimeplus:integer;
    tiptimes:boolean;
//    doFlashChat : Boolean;
//    flash
    end;
  Tbehaviours=array [1..EK_last] of Tbehaviour;

  pTCE = ^TCE;
  TCE= packed record
//    history0:Tobject;  // a probably wanted history, won't be saved to disk
    notes: String;
    lastAutoMsg: String;
    lastEventTime: Tdatetime;
    lastMsgTime: TdateTime;
    lastOncoming: Tdatetime;
    lastPriority: integer;
    node: Tnode;
    keylay: Integer;
    askedAuth: Boolean;
    dontdelete: Boolean;
    toquery: Boolean;
   end;


const

 {$IFNDEF UNICODE}
  ALPHANUMERIC    = ['a'..'z','A'..'Z','0'..'9','а'..'я','А'..'Я','Ё','ё'];
 {$ENDIF UNICODE}
  WHITESPACES     = [#9,#10,#13,#32];
  EMAILCHARS      = ['a'..'z','A'..'Z','0'..'9','-','_','.'];
//  UID_CHARS       = ['a'..'z','A'..'Z','0','1'..'9','-','_','.', '@'];
  UID_CHARS       = ['a'..'z','A'..'Z','0','1'..'9','_','.','@'];
  BreakChars      = [' ', ';', ',', #10, #13];
  FTPURLCHARS     = [#33,#35..#38,#40..#59, #61, #63..#90, #92, #94..#255];
  WEBURLCHARS     = FTPURLCHARS;
  EDURLCHARS      = WEBURLCHARS;
  DOCK_SNAP=5;
  MaxDispayedLen  = 40; // By Rapid D

  MaxXStatusLen = 250;
  MaxXStatusDescLen = 250;

  WM_DOCK=WM_USER+200;
  progLogonTotal=6.3;
  timeBetweenMsgs=21; // In 0.1 of seconds
  saveDBdelay=100;
  searchDelay=3;
  DTseconds=1/(SecsPerDay);
  dblClickTime=0.3*DTseconds;
  allBehactions=[BE_tray,BE_sound,BE_openchat,BE_history,BE_save,BE_tip,
                 BE_popup, BE_flashchat, BE_BALLOON];
  allBehactionsButTip=allBehactions-[BE_tip];
  mtnBehactions = [BE_OPENCHAT, BE_tip, BE_SOUND, BE_HISTORY, BE_BALLOON];

  RnQImageTag = AnsiString('<RnQImage>');
  RnQImageUnTag = AnsiString('</RnQImage>');
  RnQImageExTag = AnsiString('<RnQImageEx>');
  RnQImageExUnTag = AnsiString('</RnQImageEx>');


  // additional flags start from the top, to not collide with ICQv9 flags
  IF_sendWhenImVisible  = 1 shl 31;
  IF_pager = 1 shl 30; // it is a pager message
  IF_auth = 1 shl 29; // it is a Autorization Request message
  IF_not_show_chat = 1 shl 28;
  IF_not_save_hist = 1 shl 27;
  IF_delivered     = 1 shl 26; // Msg delivered to recipient
  IF_not_delivered = 1 shl 25;
  IF_SERVER_ACCEPT = 1 shl 24; // Msg on server
  IF_XTended_EVENT = 1 shl 23; // XStatus desc in status change for example

  IF_Unicode  = 1 shl 4;      // msg in Unicode
  IF_Bin      = 1 shl 6;      // msg is not Text string - dont crypt :)
  IF_Encrypt  = 1 shl 7;      // msg was encrypted!

  IF_UTF8_TEXT = (1 shl 8) or (1 shl 9);
  IF_CODEPAGE_MASK = (1 shl 8) or (1 shl 9) or (1 shl 10);


  // rosterItalic values
  RI_none = 0;
  RI_list = 1;
  RI_visibleto = 2;

  // filenames
  userthemeFilename='user.theme.ini';
  contactsthemeFilename='contacts.theme.ini';
  packetslogFilename='packets.log';
  commonFileName='common.ini';
  automsgFilename='automsg.ini';
  OldconfigFileName='andrq.ini';
  configFileName='rnq.ini';
  defaultsConfigFileName='defaults.ini';
  groupsFilename='groups.ini';
//  myinfoFilename='myinfo';
  inboxFilename='inbox';
  outboxFilename='outbox';
  macrosFilename='macros';
  dbFilename='db';
//  langFilename='lang.txt';
  uinlistFilename='uinlists';
  extstatusesFilename='extstatuses';
  SpamQuestsFilename='spamquests.txt';
  reopenchatsFileName='reopen.list.txt';
  proxiesFilename = 'proxies.list.txt';
   {$IFDEF CHECK_INVIS}
//     CheckInvisFileName='check.invisible.list';
     CheckInvisFileName1='check.invisible.list.txt';
   {$ENDIF}

  // recent version of list files have a trailing .txt
  // here i keep old filenames to be able to load old versions
//  rosterFileName='contact.list';
//  visibleFileName='visible.list';
//  invisibleFileName='invisible.list';
//  ignoreFileName='ignore.list';
//  nilFilename='not.in.list';
//  retrieveFilename='retrieve.list';
  rosterFileName1='contact.list.txt';
  visibleFileName1='visible.list.txt';
  invisibleFileName1='invisible.list.txt';
  ignoreFileName1='ignore.list.txt';
  nilFilename1='not.in.list.txt';
  retrieveFilename1='retrieve.list.txt';
  AboutFileName = 'about.txt';

//  cachedThemeFilename='cache.theme';
  spamsFilename = '0spamers';
  helpFilename='miniguide.html';
  rnqSite = 'http://RnQ.ru';

  // paths
 {$IFDEF DB_ENABLED}
  {$IFDEF PREF_IN_DB}
  protoDBFile = 'main.db3';
  {$ENDIF PREF_IN_DB}
  historyDBFile = 'history.db3';
  AVT_DB_File = 'RnQAvatars.db3';
 {$ELSE ~DB_ENABLED}
   historyPath='history\';
 {$ENDIF DB_ENABLED}
//  langsPath='lang\';
  avtPath = 'Devils\';
  docsPath='docs\';

  // macro opcodes
  OP_NONE=0;
  OP_CHAT=1;
  OP_ROSTER=2;
  OP_TRAY=3;
  OP_CLEAREVENT=4;
  OP_CLEAREVENTS=5;
  OP_POPEVENT=6;
  OP_QUIT=7;
  OP_SHUTDOWN=8;
  OP_GROUPS=9;
  OP_MAINMENU=10;
  OP_STATUSMENU=11;
  OP_VISIBILITYMENU=12;
  OP_BROWSER=13;
  OP_OFFLINECONTACTS=14;
  OP_AUTOSIZE=15;
  OP_CONNECT=16;
  OP_CD_PLAY=17;
  OP_CD_STOP=18;
  OP_VIEWINFO=19;
  OP_ADDBYUIN=20;
  OP_WP=21;
  OP_TOGGLEBORDER=22;
  OP_PREFERENCES=23;
  OP_LOCK=24;
  OP_HINT=25;
  OP_TIP=26;
  OP_RELOADTHEME=27;
  OP_RELOADLANG=28;
  OP_VISIBLE_TO=29;
  OP_TOGGLE_SOUND=30;
 {$IFDEF RNQ_PLAYER}
  OP_PLR_PLAY   = 31;
  OP_PLR_PAUSE  = 32;
  OP_PLR_STOP   = 33;
  OP_PLR_NEXT   = 34;
  OP_PLR_PREV   = 35;
  OP_PLR_VOLUP  = 36;
  OP_PLR_VOLDWN  = 37;
  OP_PLR_ADD    = 38;
  OP_BOSSKEY = 39;
  OP_RESTARTRNQ = 40;
  OP_LAST=40;
 {$ELSE RNQ_PLAYER}
  OP_BOSSKEY = 31;
  OP_RESTARTRNQ = 32;
  OP_SEARCHALLHISTORY = 33;
  OP_LAST=33;
 {$ENDIF RNQ_PLAYER}

  macro2str: array [OP_CHAT..OP_LAST] of AnsiString=(
    'Show/hide chat window',          //'chat',
    'Show/hide contact list',         //'roster',
    'Simulate double-click on tray',  //'tray',
    'Clear event',                    //'clear event',
    'Clear all events',               //'clear events',
    'Pop event',
    'Quit',
    'Shutdown the computer',          //'shutdown',
    'Show/hide groups',               //'groups',
    'Pop up main menu',               //'main menu',
    'Pop up status menu',             //'status menu',
    'Pop up visibility menu',         //'visibility menu',
    'Open browser',                   //'browser',
    'Show/hide offline contacts',     //'offline contacts',
    'Toggle autosize',                //'autosize',
    'Connect',
    'Play audio cd',                  //'cd play',
    'Stop/eject audio cd',            //'cd stop',
    'Show contact info',              //'view info',
    'Show ''add by uin'' dialog',     //'by uin',
    'Show white-pages',               //'wp',
    'Toggle contact list border',     //'toggle border',
    'Show preferences',               //'preferences',
    'Lock',
    'Contact tip pop up',             //'show hint',
    'Simulate double-click on tip message', //'tip',
    'Reload theme',
    'Reload language',
    'Visible to selected contact',    //'visible to',
    'Sound on/off',                   //'toggle sound'
 {$IFDEF RNQ_PLAYER}
    'Start play',
    'Pause play',
    'Stop play',
    'Play next track',
    'Play prev track',
    'Player volume Up',
    'Player volume Down',
    'Add files to player',
 {$ELSE}
{    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',}
 {$ENDIF RNQ_PLAYER}
    'Bosskey',
    'Restart R&Q',
    'Search in all history files'
  );

  VK_A=65;
  VK_B=66;
  VK_C=67;
  VK_D=68;
  VK_E=69;
  VK_F=70;
  VK_G=71;
  VK_H=72;
  VK_I=73;
  VK_J=74;
  VK_K=75;
  VK_L=76;
  VK_M=77;
  VK_N=78;
  VK_O=79;
  VK_P=80;
  VK_Q=81;
  VK_R=82;
  VK_S=83;
  VK_T=84;
  VK_U=85;
  VK_V=86;
  VK_W=87;
  VK_X=88;
  VK_Y=89;
  VK_Z=90;
{
  VK_ESC=27;
  VK_BS=8;
}
//  behactions2str:array [Tbehaction] of string=('tray','sound','openchat',
//    'history','save','tip','popupchat');
  behactions2str:array [Tbehaction] of string=('tray notification','play sound',
    'open a chat', 'add to history','save to disk','show pop-up message',
    'pop up chat', 'flash chat', 'show balloon in tray (Win2K+)');
  sortby2str:array [TsortBy] of RawByteString=('none','alpha','event', 'status');

type
  TRnQPageControl = Class(TPageControl)
    procedure WMEraseBkGnd(var Message: TWMEraseBkGnd);
//    procedure DrawTab(TabIndex: Integer; const Rect: TRect; Active: Boolean); virtual;

  end;

type
  TRnQViewInfoForm = class(TForm)
    contact: TRnQContact;
    procedure updateInfo; virtual; Abstract;
    constructor doAll(owner_ :Tcomponent; c: TRnQContact); virtual; Abstract;
   public
    readOnlyContact : Boolean;
    procedure UpdateCntAvatar; virtual; Abstract;
    procedure ClearAvatar; virtual; Abstract;
    procedure UpdateClock; virtual; Abstract;
   end;

type
  PRnQUser = ^TRnQUser;
  TRnQUser = record
 {$IFDEF ICQ_ONLY}
     proto : TICQProtoClass;
 {$ELSE ~ICQ_ONLY}
     proto : TRnQProtoClass;
 {$ENDIF ICQ_ONLY}
     uin  : TUID;
     name, //uinStr,
     SubPath, path, prefix:string;
     SSI : Boolean;
//     pwd : ShortString;
     pwd : String;
     encr : Boolean;
   end;


type
  TRnQAccount = record
     ProtoPath : String;
//     db : TZipFile;
 {$IFDEF ICQ_ONLY}
     AccProto : TicqSession;
 {$ELSE ~ICQ_ONLY}
//     AccProto : IRnQProtocol;
     AccProto : TRnQProtocol;
 {$ENDIF ICQ_ONLY}
     outbox :Toutbox;
     acks   :Toutbox;
   end;

const
   ChkInvisDiv = 64;


var
  outboxprocessChk: Boolean = True;

  ContactsTheme : TRQtheme;
//  ICQ :TicqSession;
//  MainProto : IRnQProtocol;
//  MainProto : TRnQProtocol;
  Account : TRnQAccount;
  MainPrefs : TRnQPref;

//  userPath : String;
  AccPath : String;
  FileSavePath : String;
  MakeBakups : Boolean;

//  gmtCodes,languageCodes,countryCodes,pastCodes,ageCodes,interestCodes,genderCodes :Tcodes;
  eventQ    : TeventQ;
  plugins   : Tplugins;
  progStart : double;
  statusIcon :TstatusIcon;
  hintMode  : (HM_null,HM_url,HM_comm);
  usertime  : integer;
  startTime : TdateTime;
  WM_TASKBARCREATED : longword;
//  contactsPnl,
//  freePnl :TstatusPanel;
  contactsPnlStr : String;
  locked, startingLock : boolean;
  hotkeysEnabled : boolean;
  CloseFTWndAuto : Boolean;
  outboxSbarRect : Trect;
  supportedBehactions : array [1..EK_last] of set of Tbehaction;
  // here i bookmark last selected node, cause it could change between clicks
  clickedContact : TRnQContact;
//  focusedCnt : TRnQContact;
  clickedGroup : integer;
  clickedNode : Tnode;

  prefHeight      : integer;
  saveDBtimer     : integer;
//  loginServer  :string;
  lastServerIP, lastserverAddr : string;
  cmdLinePar : record
     startUser : TUID;
     extraini,
     userPath,
     mainPath,
     logpath,
     useproxy  : String;
     ssi : Boolean;
//     NoSound : Boolean;
    end;
  lastOnTimer : Tdatetime;
  showRosterTimer : integer;
  removeTempVisibleTimer : integer;
  removeTempVisibleContact : TRnQContact;
  inactiveTime : integer;
  noOncomingCounter : integer; // if > 0, IE_oncoming means people was here before (used in the login process)
  childWindows : Tlist;
  MustQuit : Boolean = False; // Вызывается из плагинов, чтобы их нормально завершить успеть.

  docking :record
    pos :(DP_right,DP_left);
    bakOfs, bakSize :Tpoint;
    enabled,
    active,
    appbar,
    appbarFlag,
    tempOff,
    Dock2Chat,
    Docked2chat : boolean;
    end;
  fantomWork,
  ShowUINDelimiter,
  XStatusAsMain,
//  offlineMsgsChecked,
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
  rosterRebuildDelayed :boolean; // requires a roasterLib.rebuild
  stayConnected, running, resolving :boolean;
  chatfrmXY :TformXY;
  oldForeWindow   :Thandle;
  bringForeground :Thandle;
  groups :Tgroups;
  searching      : string;
  usersPath      : string;
  lastUser  : TUID;
  userCharSet :integer;
  imAwaySince :Tdatetime;
  lastSearchTime :Tdatetime;
  lastFilterEditTime :Tdatetime;
  selectedColor :Tcolor;
  dialogFrm :Tform;
  uinlists : Tuinlists;
//  myStatus,

//  visibleList, invisibleList,
   ignoreList,
   notInList,
   updateViewInfoQ, retrieveQ, reqAvatarsQ , reqXStatusQ
      :TRnQCList;
  // timers
  outboxCount    :integer;
  blinkCount     :word;
  delayCount     :word;
  longDelayCount,
  reconnectdelayCount :byte;
  flapSecs       :byte;
  blinking       :boolean;
  toReconnectTime : integer;
  // options
  focusOnChatPopup :boolean;
  quoting :record
    cursorBelow :boolean;
    quoteselected :boolean;
    width :integer;
    end;
  rosterItalic  :integer;
  behaviour :Tbehaviours;
  spamfilter :record
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
    multisend    : Boolean;
     BotTryesCount : Integer;
    uingt        :integer;
    badwords     :string;
//    quests : array of record q : String; ans : String; end;
    quests : array of record q : String; ans : array of String; end;
   end;
  histCrypt :record
    enabled : boolean;
    savePwd : boolean;
    pwdKey  : integer;
    pwd     : String;
   end;
  AccPass : String;
  autoaway : record
    time :cardinal;
//  {$IFDEF WIN98_SUP}
//    lastMousePos :Tpoint;
//    lastKeybPos :integer;
//  {$ENDIF WIN98_SUP}

    away, na, ss, boss, autoexit,
    clearXSts, setVol :boolean;
    awayTime, naTime : Integer;
    msg :string;
    triggered:(TR_none, TR_away, TR_na);
    bakstatus : byte;
    bakxstatus : byte;
    bakmsg :string;
     vol : Integer;
   end;
  BossMode: Record
    isBossKeyOn,
    activeChat,
    toShowChat,
    toShowCL : Boolean;
   end;

//  themeprops :array of TthemeProperty;
  browserCmdLine : String;
  FTOutPorts     : String;
  splitY, inactiveHideTime, blinkSpeed :integer;

  TipsMaxAvtSize : Integer;
  TipsMaxAvtSizeUse : Boolean;

  useDefaultBrowser :boolean;
  minOnOff :boolean;
  minOnOffTime :integer; // in seconds
  autostartUIN : TUID;
  uin2Bstarted : TUID;
  RnQStartingStatus, RnQStartingVisibility : Int8;
  lastStatus, lastStatusUserSet : Int8;
  rosterTitle :string;
  automessages:Tstrings;
  keepalive:record
    enabled:boolean;
    freq:integer;
    timer:integer;
   end;
  fixingWindows:record
    lastWidth, lastRightSpace:integer;
    onTheRight: boolean;
   end;
  sendOnEnter,
  tempBlinkTime,
  wheelVelocity:integer;
  disabledPlugins:string;
  sortBy:TsortBy;
  transparency:record
    forRoster, forChat, forTray :boolean;
    chgOnMouse : Boolean;
    active,inactive:integer;
    tray : Integer;
   end;
  macros : Tmacros;
  splashFrm : Tform;
  splashImgElm : TRnQThemedElementDtls;
//  splashPicTkn : Integer;
//  splashPicIdx : Integer;
//  splashPicLoc : TPicLocation;
  checkupdate : record
    autochecking,
    checking,
    enabled,
    betas :boolean;
    every :integer;
    lastSerial :integer;
    last :Tdatetime;
//    info :string;
    end;
  fontstylecodes :record
    enabled: boolean;
    end;
   {$IFDEF CHECK_INVIS}
    checkInvQ, autoCheckInvQ : TRnQCList;
  checkInvis : record
      ChkInvisInterval  : Double;
      lastAllChkTime    : TDateTime;
      lastChkTime       : TDateTime;
      CList             : TRnQCList;
      AutoCheckInterval : Integer;
      ShowInvisibility,
      AutoCheck,
      AutoCheckGoOfflineUsers,
      AutoCheckOnSend   : Boolean;
      Method            : Byte;
    end;
    showCheckedInvOfl  : Boolean;// = True;
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
  enteringICQpwd,
  check4readonly,
  dontSavePwd,
  clearPwdOnDSNCT,
  sendTheAddedYou,
  showStatusOnTabs,
//  webaware,
  singleDefault,
  texturizedWindows,
  showGroups,
  autoCopyHist,
  bViewTextWrap,
  indentRoster,
  showDisconnectedDlg,
  autoConnect,
  autoDeselect,
  alwaysOnTop,
  chatAlwaysOnTop,
  useLastStatus,
  useSmiles,
  ShowAniSmlPanel,
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
              :boolean;
//  AutoCheckGoOfflineUsers : Boolean;

//  haveToApplyTheme : Boolean;
  NILdoWith : byte; // 0 - ask; 1 = clear all; 2 = save
  typingInterval : Integer;
  prefPages : array of TPrefPage;
  Mutex:Cardinal;
  portsListen : TPortList;
  cache: String;
  imgCacheInfo: TMemIniFile;

//const
//  supportInvisCheck = false;

  procedure AddPrefPage1(index: Byte; cl: TPrefFrameClass; Cpt: String);
  procedure ClearPrefPages;

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
  i : Integer;
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
  i : Integer;
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

