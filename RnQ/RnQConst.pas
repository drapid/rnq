{
  This file is part of R&Q.
  Under same license
}
unit RnQConst;
{$I RnQConfig.inc}
{$I NoRTTI.inc}

interface
uses
  Winapi.Messages, sysutils,
  RDGlobal, RnQGlobal;

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
//  ANDRQversion: Longword = $00090412;  // remember: it's hex
//  RnQversion: Longword = $000A00DB;  // remember: it's hex
  RQversion: Longword = $000A01FF;  // remember: it's hex
 {$IFDEF DB_ENABLED}
  RnQBuild = 1300;
  PIC_CLIENT_LOGO                 = TPicName('rnq');
 {$ELSE ~DB_ENABLED}
  RnQBuild = 1129;
  PIC_CLIENT_LOGO                 = TPicName('rnq');
 {$ENDIF ~DB_ENABLED}
{$I RnQBuiltTime.inc}

  GAP_SIZEd2 = 3;
  GAP_SIZE   = 6;
  GAP_SIZE2  = 12;
  FRM_HEIGHT = 400;
  FRM_WIDTH  = 420;

type
  TwhatForm = (WF_PREF, WF_USERS, WF_WP, WF_WP_MRA, WF_SEARCH);
  TfrmViewMode = (vmFull, vmShort);

  TformXY = record
    top, left, height, width: integer;
    maximized: boolean;
    end;
  TsortBy = ( SB_NONE, SB_ALPHA, SB_EVENT, SB_STATUS );
  Tbehaction = (BE_TRAY, BE_SOUND, BE_OPENCHAT, BE_HISTORY, BE_SAVE, BE_TIP, BE_POPUP, BE_FLASHCHAT, BE_BALLOON);
  Tbehaviour = record
    trig: set of Tbehaction;
    tiptime: integer;
    tiptimeplus: integer;
    tiptimes: boolean;
//    doFlashChat: Boolean;
//    flash
    end;



const

 {$IFNDEF UNICODE}
  ALPHANUMERIC    = ['a'..'z','A'..'Z','0'..'9','а'..'я','А'..'Я','Ё','ё'];
 {$ENDIF UNICODE}
  WHITESPACES     = [#9, #10, #13, #32];
  EMAILCHARS      = ['a'..'z','A'..'Z','0'..'9','-','_','.'];
//  UID_CHARS       = ['a'..'z','A'..'Z','0','1'..'9','-','_','.', '@'];
  UID_CHARS       = ['a'..'z','A'..'Z','0','1'..'9','_','.','@'];
  BreakChars      = [' ', ';', ',', #10, #13];
  BreakCharsS     = [';', ',', #10, #13];
  FTPURLCHARS     = [#33,#35..#38,#40..#59, #61, #63..#90, #92, #94..#255];
  WEBURLCHARS     = FTPURLCHARS;
  EDURLCHARS      = WEBURLCHARS;
  DOCK_SNAP = 5;
  MaxDispayedLen  = 40; // By Rapid D

  MaxXStatusLen = 250;
  MaxXStatusDescLen = 250;

  WM_DOCK = WM_USER+200;
  progLogonTotal = 6.3;
  timeBetweenMsgs = 21; // In 0.1 of seconds
  saveDBdelay = 100;
  searchDelay = 3;
  DTseconds = 1/(SecsPerDay);
  dblClickTime = 0.3*DTseconds;
  allBehactions = [BE_tray,BE_sound,BE_openchat,BE_history,BE_save,BE_tip,
                 BE_popup, BE_flashchat, BE_BALLOON];
  allBehactionsButTip = allBehactions-[BE_tip];
  mtnBehactions = [BE_OPENCHAT, BE_tip, BE_SOUND, BE_HISTORY, BE_BALLOON];


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


// costants for DB files
const
  DBFK_OLDUIN      = 00;
  DBFK_NICK        = 01;
  DBFK_FIRST       = 02;
  DBFK_LAST        = 03;
  DBFK_EMAIL       = 04;
  DBFK_CITY        = 05;
  DBFK_STATE       = 06;
  DBFK_ABOUT       = 07;
  DBFK_DISPLAY     = 08;
  DBFK_QUERY       = 09;
  DBFK_ZIP         = 10;
   {$IFDEF PROTOCOL_ICQ}
  DBFK_COUNTRY     = 11;
   {$ENDIF PROTOCOL_ICQ}
  DBFK_BIRTH       = 12;
  DBFK_LANG        = 13;
  DBFK_HOMEPAGE    = 14;
  DBFK_CELLULAR    = 15;
  DBFK_IP          = 16;
  DBFK_AGE         = 17;
  DBFK_GMT         = 18;
  DBFK_GENDER      = 19;
  DBFK_GROUP       = 20;
  DBFK_LASTUPDATE  = 21;
  DBFK_LASTONLINE  = 22;
//  DBFK_LASTMSG     = 23;   DON'T USE, it was badly updated
  DBFK_LASTMSG     = 24;
  DBFK_NOTES       = 25;
  DBFK_DONTDELETE  = 26;
  DBFK_ASKEDAUTH   = 27;
  DBFK_MEMBERSINCE = 28;
  DBFK_ONLINESINCE = 29;
  DBFK_SMSABLE     = 30;
  DBFK_NODB        = 31;
  DBFK_SENDTRANSL  = 32;
  DBFK_INTERESTS   = 33;

  DBFK_WORKPAGE    = 34;
  DBFK_WORKSTNT    = 35; // Должность
  DBFK_WORKDEPT    = 36; // Департамент
  DBFK_WORKCOMPANY = 37; // Компания
  DBFK_WORKCOUNTRY = 38;
  DBFK_WORKZIP     = 39;
  DBFK_WORKADDRESS = 40;
  DBFK_WORKPHONE   = 41;
  DBFK_WORKSTATE   = 42;
  DBFK_WORKCITY    = 43;

  DBFK_UTYPE = 110;
  DBFK_UID         = 111;
  DBFK_BIRTHL      = 112;
  DBFK_SSIID       = 113;
  DBFK_Authorized  = 114;
  DBFK_ssNoteStr   = 115;
  DBFK_ICONSHOW    = 116;
  DBFK_ICONMD5     = 117;
  DBFK_ssMail      = 118;
  DBFK_ssCell      = 119;
  DBFK_MARSTATUS   = 120;
  DBFK_lclNoteStr  = 121;
  DBFK_ZODIAC      = 122;
  DBFK_qippwd      = 123;
  DBFK_LASTBDINFORM= 124;

  DBFK_LASTINFOCHG = 125;

  DBFK_ADDRESS = 126;
  DBFK_BIRTHCOUNTRY = 127;
  DBFK_BIRTHSTATE = 128;
  DBFK_BIRTHCITY = 129;
  DBFK_REGULAR = 130;

  DBFK_ssCell2 = 131;
  DBFK_ssCell3 = 132;
  DBFK_ssCell4 = 142;

  // New types
  DBFK_SMSMOBILE = 44;
  DBFK_COUNTRY_CODE = 45;
  DBFK_LANG1 = 46;
  DBFK_LANG2 = 47;
  DBFK_LANG3 = 48;

  DBFK_BIRTHCOUNTRY_CODE = 133;
  DBFK_BIRTHADDRESS = 134;
  DBFK_BIRTHZIP = 135;


  // rosterItalic values
  RI_none = 0;
  RI_list = 1;
  RI_visibleto = 2;

  // filenames
  userthemeFilename = 'user.theme.ini';
  contactsthemeFilename = 'contacts.theme.ini';
  packetslogFilename = 'packets.log';
  commonFileName = 'common.ini';
  automsgFilename = 'automsg.ini';
  OldconfigFileName = 'andrq.ini';
  configFileName = 'rnq.ini';
  defaultsConfigFileName = 'defaults.ini';
  groupsFilename = 'groups.ini';
//  myinfoFilename = 'myinfo';
  inboxFilename = 'inbox';
  outboxFilename = 'outbox';
  macrosFilename = 'macros';
  dbFilename = 'db';
//  langFilename = 'lang.txt';
  uinlistFilename = 'uinlists';
  extstatusesFilename = 'extstatuses';
  SpamQuestsFilename = 'spamquests.txt';
  reopenchatsFileName = 'reopen.list.txt';
  proxiesFilename = 'proxies.list.txt';
   {$IFDEF CHECK_INVIS}
//     CheckInvisFileName = 'check.invisible.list';
     CheckInvisFileName1 = 'check.invisible.list.txt';
   {$ENDIF}

  // recent version of list files have a trailing .txt
  // here i keep old filenames to be able to load old versions
//  rosterFileName = 'contact.list';
//  visibleFileName = 'visible.list';
//  invisibleFileName = 'invisible.list';
//  ignoreFileName = 'ignore.list';
//  nilFilename = 'not.in.list';
//  retrieveFilename = 'retrieve.list';
  rosterFileName1 = 'contact.list.txt';
  visibleFileName1 = 'visible.list.txt';
  invisibleFileName1 = 'invisible.list.txt';
  ignoreFileName1 = 'ignore.list.txt';
  nilFilename1 = 'not.in.list.txt';
  retrieveFilename1 = 'retrieve.list.txt';
  AboutFileName = 'about.txt';

//  cachedThemeFilename = 'cache.theme';
  spamsFilename = '0spamers';
  helpFilename = 'miniguide.html';
  rnqSite = 'https://RnQ.ru';

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
  docsPath = 'docs\';

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
//  behactions2str: array [Tbehaction] of string=('tray','sound','openchat',
//    'history','save','tip','popupchat');
  behactions2str: array [Tbehaction] of string=('tray notification','play sound',
    'open a chat', 'add to history','save to disk','show pop-up message',
    'pop up chat', 'flash chat', 'show balloon in tray (Win2K+)');
  sortby2str: array [TsortBy] of RawByteString=('none','alpha','event', 'status');

const
  ChkInvisDiv = 64;

  ClrHistBG = 'history.bg';

type
  TQuestAns = record
              q: String;
              ans: array of String;
           end;
  TQuestAnsArr = array of TQuestAns;


implementation

end.

