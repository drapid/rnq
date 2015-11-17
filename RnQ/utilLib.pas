{
This file is part of R&Q.
Under same license
}
unit utilLib;
{$I RnQConfig.inc}
{$I NoRTTI.inc}

 {$IFDEF RNQ_FULL}
// {$ELSE}
//    {$UNDEF CHECK_INVIS}
 {$ENDIF}

interface

uses
  windows, sysutils, graphics, classes, extctrls,
  forms, stdctrls, controls, menus,
  comctrls, messages, types,
  VirtualTrees,
  strutils,
//    GDIPAPI, GDIPOBJ,
  outboxLib,
  RnQNet, RnQProtocol, RDGlobal,
  AnsiClasses,
  roasterLib,
  RnQZip,
  globalLib, events,
  dateutils
  ;

function OnlFeature(const pr: TRnQProtocol; check: Boolean = True): Boolean; // True if online

procedure processOevent(oe: Toevent);
function  getShiftState(): integer;
function  exitFromAutoaway(): Boolean;

procedure addTempVisibleFor(time: integer; c: TRnQContact);
function  infoToStatus(const info: RawByteString): byte;
function  infoToXStatus(const info: RawByteString): Byte;
procedure drawHint(cnv: Tcanvas; kind: Integer;
                   groupid : integer; c : TRnQcontact;
                   var r: Trect; calcOnly: Boolean = False);
//procedure drawNodeHint(cnv:Tcanvas; node:Pvirtualnode; var r:Trect);
function  unexistant(const uin: TUID): boolean;
function  fileIncomePath(cnt: TRnQContact): String;

function  isAbort(const pluginReply: AnsiString): boolean;
function  findInAvailableUsers(const uin: TUID): integer;
procedure setupChatButtons;
procedure reloadCurrentLang();

function  showUsers(var pass: String): TUID;
function  CheckAccPas(const uid: TUID; const db: String; var pPass: String): Boolean;
procedure clearAvailableUsers;
procedure refreshAvailableUsers;
function  getLeadingInMsg(const s: string; ofs: integer = 1): string;
procedure applyCommonSettings(c: Tcomponent);
procedure applyUserCharset(f: Tfont);
 {$IFDEF Use_Baloons}
procedure ShowBalloonEv(ev: Thevent);
 {$ENDIF Use_Baloons}
function  addToNIL(c: TRnQContact; isBulk: Boolean = false): boolean;
procedure NILifNIL(c: TRnQContact; isBulk: Boolean = false);
function  setRosterAnimation(v: boolean): boolean;
//function  eventName(ev: integer): string;
function  behactionName(a: Tbehaction): string;
//function  sendMCIcommand(cmd: PChar): string;
function doLock: Boolean;
//function  loadNewOrOldVersionContactList(fn: string; altpath: string=''): string;
procedure trayAction;
function  chopAndRealizeEvent: boolean;
procedure realizeEvents(const kind_: integer; c: TRnQContact);
procedure realizeEvent(ev: Thevent);
procedure removeSWhotkeys;
function  updateSWhotkeys: boolean;
procedure hideTaskButtonIfUhave2;
function  behave(ev: Thevent; kind: integer=-1{; const info: Ansistring=''}): boolean;
procedure startTimer;
procedure stopMainTimer;
procedure contactCreation(c: TRnQContact);
procedure contactDestroying(c: TRnQContact);
procedure clearDB(db: TRnQCList);
procedure freeDB(var db: TRnQCList);
function  isSpam(var wrd: String; c: TRnQContact; msg: string=''; flags: dword=0): boolean;
function  filterRefuse(c: TRnQContact; const msg: string=''; flags: dword=0; ev: Thevent = NIL): boolean;
function  rosterImgNameFor(c: TRnQcontact): TPicName;
procedure setAppBarSize;
procedure check4update;
 {$IFDEF PROTOCOL_ICQ}
function  CheckUpdates(cnt: TRnQContact): Boolean;
 {$ENDIF PROTOCOL_ICQ}
function  setAutomsg(const s: String): string;
function  applyVars(c: TRnQcontact; const s: String; fromAM: boolean = false): String;
function  getAutomsgFor(c: TRnQcontact): string;
function  getXStatusMsgFor(c: TRnQContact): string;
procedure toggleOnlyOnline;
procedure toggleOnlyImVisibleTo;
procedure openURL(const pURL: String); OverLoad;
function  enterPwdDlg(var pwd: String; const title: String = ''; maxLength: Integer = 0;
                      AllowNull: Boolean = False): boolean;
function  enterUinDlg(const proto: TRnQProtocol; var uin: TUID; const title: string=''): boolean;
function  sendProtoMsg(var oe: TOevent): boolean;
procedure SendEmail2Mail(const email: String);
function  childParent(child, parent: integer): boolean;
procedure myBeep;
function  findViewInfo(c: TRnQContact): TRnQViewInfoForm;
procedure sortCL(cl: TRnQCList);
procedure sortCLbyGroups(cl: TRnQCList);
procedure updateViewInfo(c: TRnQContact);
 {$IFDEF RNQ_FULL2}
procedure convertHistoriesDlg(const oldPwd, newPwd: string);
 {$ENDIF}
procedure openSendContacts(dest: TRnQContact);
function  isEmailAddress(const s: string; start: integer): integer;
procedure notAvailable;
// strings
//function  TLV(code: integer; data: string): string;
function  mb(q: extended): string;

procedure onlyDigits(obj: Tobject); overload;
// icq communication
procedure addToIgnorelist(c: TRnQcontact; const Local_only: Boolean = false);
procedure removeFromIgnorelist(c: TRnQcontact);
procedure removeFromRoster(c: TRnQContact; const withHistory: Boolean = false);
function  addToRoster(c: TRnQContact; group: integer; const isLocal: Boolean = True): boolean; overload;
function  doConnect: boolean;
procedure connect_after_dns(const proto: TRnQProtocol);
// convert
function  ints2cl(a: TintegerDynArray): TRnQCList;
function  event2imgName(e: integer): TPicName;
function  statusDrawExt(const DC: HDC; const x, y: Integer; const s: byte;
                        const inv: Boolean = False; const ExtSts: Byte = 0) : TSize;
//function  statusDraw(cnv:Tcanvas; x,y:integer; s:Tstatus; inv:boolean=FALSE) : TSize;
function  beh2str(kind: integer): RawByteString;
procedure str2beh(const b, s: RawByteString); overload;
function  str2beh(s: AnsiString): Tbehaviour; overload;
function  str2html(const s: string): string;
function  strFromHTML(const s: string): string;
function  db2strU(db: TRnQCList): RawByteString;
// window management
procedure toggleMainfrmBorder(setBrdr: Boolean = false; IsBrdr: Boolean = True);
procedure applySnap();
procedure mainfrmHandleUpdate;
procedure dockSet(var r: Trect); overload;
procedure dockSet; overload;
procedure fixWindowPos(frm: Tform);
procedure showAuthreq(c: TRnQContact; msg: string);
procedure showSplash;
function  viewHeventWindow(ev: Thevent): Tform;
procedure hideForm(frm: Tform);
procedure showForm(whatForm: TwhatForm; const Page: String = ''; Mode: TfrmViewMode = vmFull); overload;
function  PrefIsVisiblePage(const pf: String): Boolean;
procedure restoreForeWindow;
procedure applyTransparency(forced: integer=-1);
procedure applyDocking(Undock: Boolean = false);
function  whatStatusPanel(statusbar: Tstatusbar; x: integer): integer;
// graphic
procedure wallpaperize(canvas: Tcanvas); overload;
procedure wallpaperize(DC: THandle; r: TRect); {$IFDEF HAS_INLINE} inline; {$ENDIF HAS_INLINE} overload;
// file management
function  delSUBtree(subPath: string): boolean;
function  deltree(path: string): boolean;
function  deleteFromTo(const fn: string; from, to_: integer): boolean;
function  saveAllLists(const uPath: String; const pr: TRnQProtocol; pProxys : Tarrproxy) : Boolean;
function  loadDB(zp: TZipFile; pCheckGroups: Boolean): boolean;
//procedure saveDB;
//procedure saveLists(pr: TRnQProtocol);
procedure loadLists(const pr: TRnQProtocol; zp: TZipFile; const uPath : String);
procedure LoadExtSts(zp: TZipFile);
//procedure SaveExtSts;
procedure loadSpamQuests(zp: TZipFile);
//procedure SaveSpamQuests;
procedure LoadProxies(zp: TZipFile; var pProxys: Tarrproxy);
//procedure SaveProxies(pProxys: Tarrproxy);
//procedure saveInbox;
//procedure loadInbox(zp: TZipFile);
//procedure saveOutbox;
procedure loadOutInBox(zp: TZipFile);
//procedure saveRetrieveQ;
function  openSaveDlg(parent: Tform; const Cptn: String; IsOpen: Boolean;
                      const ext: String = ''; const extCptn: String = '';
                      const defFile: String = ''; MultiSelect: boolean = false):string;

function  str2sortby(const s: AnsiString): TsortBy;
procedure CheckBDays;
function  GetWidth(chk: TCheckBox): integer;
procedure parseMsgImages(const imgStr: RawByteString; var imgList: TAnsiStringList);
function  CacheImage(var mem: TMemoryStream; url, ext: RawByteString): Boolean;
procedure CacheType(const url, mime, ctype: RawByteString);
function  CheckType(const lnk: String; var sA: RawByteString; var ext: String): Boolean; overload;
function  CheckType(const lnk: String): Boolean; overload;

// costants for files
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
  DBFK_COUNTRY     = 11;
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

implementation

uses
  ShlObj, shellapi,
  Themes, DwmApi, math, UITypes,
 {$IFDEF UNICODE}
   AnsiStrings,
   Character,
 {$ELSE nonUNICODE}
   // Enable russian codepage by default
   RusClipboard in 'RusClipboard.pas',
 {$ENDIF UNICODE}
  {$IFDEF EUREKALOG}
  ExceptionLog7, ECore, ETypes,
  {$ENDIF EUREKALOG}
  Base64,
  OverbyteIcsWSocket,
  OverbyteIcsMD5,
  RQUtil, RDFileUtil, RDUtils, RnQSysUtils,
  RQMenuItem, RQThemes, RQLog, RnQDialogs,
  RnQLangs, RnQButtons, RnQBinUtils, RnQGlobal, RnQCrypt, RnQPics,
  RDtrayLib, RnQTips,
  Murmur2, json,
   {$IFDEF RNQ_FULL2}
     converthistoriesDlg,
   {$ENDIF}
  // лайт версия будет без окна настроек!!!
// {$IFNDEF RNQ_LITE}
  prefDlg, RnQPrefsLib,
//   ignore_fr,
  design_fr,
// {$ENDIF RNQ_LITE}
 {$IFDEF RNQ_PLAYER}
  uSimplePlayer,
 {$ENDIF RNQ_PLAYER}
  mainDlg, iniLib, pluginutil,
  chatDlg, selectContactsDlg, incapsulate,
  pluginLib, authreqDlg,
  lockDlg, langLib, groupsLib, outboxDlg, pwdDlg, //msgsDlg,
  history,
  addContactDlg,
  RnQMacros,
  usersDlg, visibilityDlg,
  changepwdDlg, ThemesLib, RnQStrings,
  Protocols_all,
 {$IFDEF PROTOCOL_MRA}
  MRAv1, MRAcontacts,
  wpMRADlg,
 {$ENDIF PROTOCOL_MRA}
 {$IFDEF PROTOCOL_ICQ}
  RQ_ICQ, ICQv9, ICQContacts, ICQConsts,
  icq_fr,
  Protocol_ICQ,// ICQClients,
  wpDlg,
 {$ENDIF PROTOCOL_ICQ}
  {$IFDEF USE_GDIPLUS}
    RnQGraphics,
  {$ELSE}
    RnQGraphics32,
  {$ENDIF USE_GDIPLUS}
//  AsyncCalls,

  menusUnit, HistAllSearch,
  ViewHEventDlg,
  OleCtrls;


function str2sortby(const s: AnsiString): TsortBy;
begin
  result := low(TsortBy);
  while result <= high(TsortBy) do
   if s = sortby2str[result] then
     exit
    else
     inc(result);
  Result := SB_EVENT;
end; // str2sortby

//procedure openURL(url: AnsiString);
procedure openURL(const pURL: String);
begin
  RnQSysUtils.openURL(pURL, useDefaultBrowser, browserCmdLine);
end; // openURL

procedure onlyDigits(obj: Tobject);
var
  i: integer;
begin
if obj is Tcustomedit then
  with (obj as Tcustomedit) do
    begin
    i := selstart;
    text := onlyDigits(text);
    if i>length(text) then
      i := length(text);
    selStart := i;
    end;
end; // onlyDigits

procedure loadLists(const pr: TRnQProtocol; zp: TZipFile; const uPath : String);
var
  zipLists: Boolean;
  function LoadZorF(const fn: String): RawByteString;
  var
    i: Integer;
   begin
     if zipLists then
      begin
         i := zp.IndexOf(fn);
         if i >= 0 then
           result := zp.data[i]
          else
           result := '';
      end
      else
    //   s := loadNewOrOldVersionContactList(visibleFileName1);
       result := loadFileA(uPath + fn);
   end;
var
  s: RawByteString;
  i: Integer;
begin
// backward compatibility
renamefile(uPath + 'uin.list', uPath + uinlistFilename);

  i := -1;
  zipLists := false;
  if Assigned(zp) then
   try
     i := zp.IndexOf(rosterFileName1);
     if i >= 0 then
      s := zp.data[i];
    except
     i := -1;
     s := '';
   end;
 if i >=0 then
  begin
    zipLists := True;
  end
  else
//   s := loadNewOrOldVersionContactList(rosterFileName1);
   s := loadFileA(uPath + rosterFileName1);
 pr.readList(LT_ROSTER).fromString(pr, s, contactsDB);


{ if zipLists then
  begin
     i := zp.IndexOf(visibleFileName1);
     if i >= 0 then
      s := zp.Uncompressed[i];
  end
  else
//   s := loadNewOrOldVersionContactList(visibleFileName1);
   s := loadFile(uPath + visibleFileName1);
 pr.readList(LT_VISIBLE).fromString(pr.getContactClass, s, contactsDB );
}
 pr.readList(LT_VISIBLE).fromString(pr, LoadZorF(visibleFileName1), contactsDB );

 pr.readList(LT_INVISIBLE).fromString(pr, LoadZorF(invisibleFileName1), contactsDB );

 notInlist.fromString(pr, LoadZorF(nilFilename1), contactsDB );
 notInlist.remove(pr.readList(LT_ROSTER));

 ignoreList.fromString(pr, LoadZorF(ignoreFilename1), contactsDB );

 uinlists.fromString(pr, LoadZorF(uinlistFilename) );
 {$IFDEF CHECK_INVIS}
  CheckInvis.CList.fromString(pr, LoadZorF(CheckInvisFileName1), contactsDB );
 {$ENDIF}
 retrieveQ.fromString(pr, LoadZorF(retrieveFileName1), contactsDB );
end; // loadLists

(*procedure saveLists(pr : TRnQProtocol);
begin
if not saveFile(userPath+rosterFileName+'.txt', pr.readList(LT_ROSTER).toString, True) then msgDlg(getTranslation('Error saving contact list'),mtError);
if not saveFile(userPath+visibleFileName+'.txt', pr.readList(LT_VISIBLE).toString, True) then msgDlg(getTranslation('Error saving visible list'),mtError);
if not saveFile(userPath+invisibleFileName+'.txt', pr.readList(LT_INVISIBLE).toString, True) then msgDlg(getTranslation('Error saving invisible list'),mtError);
if not saveFile(userPath+ignoreFileName+'.txt', ignorelist.toString, True) then msgDlg(getTranslation('Error saving ignore list'),mtError);
if NILdoWith = 2 then
  if not saveFile(userPath+nilFileName+'.txt', notinlist.toString, True) then msgDlg(getTranslation('Error saving not-in-list'),mtError);
if not saveFile(userPath+uinlistFilename, uinlists.toString, True) then msgDlg(getTranslation('Error saving uinlists'), mtError);
 {$IFDEF CHECK_INVIS}
if not saveFile(userPath+CheckInvisFileName+'.txt', CheckInvis.CList.toString, True) then msgDlg(getTranslation('Error saving Check-invisibility list'),mtError);
 {$ENDIF}
end; // saveLists
*)

procedure loadExtSts(zp: TZipFile);
var
  k, line, s: RawByteString;
  i : Integer;
begin
//  clear;
//  s := loadFile(userPath + extstatusesFilename);
 {$IFDEF PROTOCOL_ICQ}
  s := loadFromZipOrFile(zp, Account.ProtoPath, extstatusesFilename);
  i := 0;
  while s>'' do
  begin
   line := chopLine(s);
   k := chop(AnsiString('='),line);
   k := trim(k);
   line := trim(line);
   if isOnlyDigits(k) then
     try
       i := strToInt(k);
       if i < Length(ExtStsStrings) then
        begin
         ExtStsStrings[i].Cap := '';
         ExtStsStrings[i].Desc := '';
        end;
     except
       i := -1;
//       setlength(a,length(a)-1);
     end
   else
//    if (i >= Low(XStatus6))and(i <= High(XStatus6)) then
    if (i >= Low(ExtStsStrings))and(i <= High(ExtStsStrings)) then
     if k='caption' then
       try
          ExtStsStrings[i].Cap := UnUTF(Copy(line, 1, MaxXStatusLen));
       except
       end
     else
       if k='desc' then
         try
           ExtStsStrings[i].Desc := UnUTF(StringReplace(Copy(line, 1, MaxXStatusDescLen), AnsiString('\n'), CRLF, [rfReplaceAll]));
         except
         end;
  end;
 {$ENDIF PROTOCOL_ICQ}
end;

{procedure SaveExtSts;
var
  i:integer;
  f : string;
begin
  f:='';
//  for I := low(XStatus6) to High(XStatus6) do
  for I := low(ExtStsStrings) to High(ExtStsStrings) do
  begin
    f := f+format('%d=%s'//+CRLF+'caption=%s'
           +CRLF+'desc=%s', [
      i, XStatusArray[i].Caption, newline2slashn(ExtStsStrings[i])]);
//  f := f+format(CRLF+'ssi=%d', [a[i].ssiID]);
    f:=f+CRLF;
  end;
 saveFile(userPath + extstatusesFilename, f);
end;
}
procedure loadSpamQuests(zp : TZipFile);
var
  k, line, s: RawByteString;
  i, j : Integer;
begin
//  clear;
  s := loadFromZipOrFile(zp, Account.ProtoPath, SpamQuestsFilename);
  i := -1;
//  i := 0;
  while s>'' do
  begin
   line := chopLine(s);
   k := trim(chop('=',line));
   line := trim(line);
{   if isOnlyDigits(k) then
     try
       i := strToInt(k);
     except
//       setlength(a,length(a)-1);
     end
   else}
     if k='question' then
       try
         i := Length(spamfilter.quests);
         SetLength(spamfilter.quests, i+1);
         spamfilter.quests[i].q := UnUTF(StringReplace(line, AnsiString('\n'), CRLF, [rfReplaceAll])) ;
       except
       end
     else
       if k='answer' then
         try
          if i >=0 then
            try
             j := Length(spamfilter.quests[i].ans);
             SetLength(spamfilter.quests[i].ans, j+1);
             spamfilter.quests[i].ans[j] := UnUTF(line);
            except 
            end;
         except
         end;
  end;
end;

{procedure SaveSpamQuests;
var
  i, j : integer;
  f : string;
begin
  if fantomWork then Exit;

  f:='';
  for I := low(spamfilter.quests) to High(spamfilter.quests) do
  begin
    f := f+format('question=%s',
      [newline2slashn(spamfilter.quests[i].q)]);
    for j := low(spamfilter.quests[i].ans) to High(spamfilter.quests[i].ans) do
     f := f+format(CRLF + 'answer=%s',[spamfilter.quests[i].ans[j]]);
//  f := f+format(CRLF+'ssi=%d', [a[i].ssiID]);
    f:=f+CRLF + '**********' + CRLF;
  end;
 saveFile(userPath + SpamQuestsFilename, f);
end;
}

procedure LoadProxies(zp: TZipFile; var pProxys: Tarrproxy);
var
  cfg, l, h: RawByteString;
  i, ppp: Integer;
  function yesno:boolean;
  begin
    result := comparetext(l,AnsiString('yes'))=0
  end;
//var
//  pp : TproxyProto;
begin
//  cfg := loadfile(userPath + proxiesFileName);
  cfg := loadFromZipOrFile(zp, Account.ProtoPath, proxiesFileName);
  i := 0;
  ClearProxyArr(pProxys);
//  SetLength(pProxys, 0);
//  ProxyIDBox.ItemIndex := 0;
  while cfg > '' do
   begin
     l := chop(CRLF,cfg);
     h := chop('=',l);
     if h = 'proxy-name' then
       begin
         i := Length(pProxys);
         SetLength(pProxys, i+1);
         ClearProxy(pProxys[i]);
         pProxys[i].name := UnUTF(l);
       end
     else
     if Length(pProxys) > 0 then
     begin
      if h='proxy-ver5' then
         if yesno then
           pProxys[i].proto:=PP_SOCKS5
         else
           pProxys[i].proto:=PP_SOCKS4
//      else if h='proxy' then pProxys[i].enabled:=yesno
      else if h='proxy-auth' then pProxys[i].auth:=yesno
      else if h='proxy-user' then pProxys[i].user:= UnUTF(l)
      else if h='proxy-ntlm' then pProxys[i].NTLM := yesno
      else if h='connection-ssl' then pProxys[i].ssl := yesno
      else if h='proxy-pass' then pProxys[i].pwd:=passDecrypt(l)
      else if h='proxy-pass64' then pProxys[i].pwd:=passDecrypt(Base64DecodeString(l))
      else if h='proxy-serv-host' then pProxys[i].serv.host:=l
      else if h='proxy-serv-port' then pProxys[i].serv.port:=StrToIntDef(l, 0)
      else if h='proxy-host' then pProxys[i].addr.host:=l
      else if h='proxy-port' then pProxys[i].addr.port:=StrToIntDef(l, 0)
      else if h='proxy-proto' then
         begin
         ppp:=findInStrings(l, proxyproto2str);
         if ppp < 0 then
           begin
//             pProxys[i].enabled:=FALSE;
//             pProxys[i].proto:=PP_SOCKS5;
             pProxys[i].proto:=PP_NONE;
           end
         else
           pProxys[i].proto:=TproxyProto(ppp);
         end
{      else if Pos('proxy-', h)>0 then
       for pp:=low(pp) to high(pp) do
         begin
         if h='proxy-'+proxyproto2str[pp]+'-host' then proxyes[i].addr[pp].host:=l;
         if h='proxy-'+proxyproto2str[pp]+'-port' then proxyes[i].addr[pp].port:=l;
         end;}
     end
   end;
end;

(*procedure SaveProxies(pProxys : Tarrproxy);
var
  cfg : string;
//  pp : TproxyProto;
  I: Integer;
begin
  if fantomWork then Exit;
  
  cfg := '';
  for I := 0 to Length(pProxys) - 1 do
  begin
   if pProxys[i].name = '' then
     pProxys[i].name := 'Proxy' + IntToStr(i+1);
   
   cfg := cfg
   + 'proxy-name=' + pProxys[i].name+CRLF
//   + 'proxy='+yesno[pProxys[i].enabled]+CRLF
    +'proxy-serv-host='+pProxys[i].serv.host+CRLF
    +'proxy-serv-port='+IntToStr(pProxys[i].serv.port)+CRLF
   + 'proxy-auth='+yesno[pProxys[i].auth]+CRLF
   + 'proxy-user='+pProxys[i].user+CRLF
   + 'proxy-pass='+passCrypt(pProxys[i].pwd)+CRLF
   + 'proxy-NTLM='+yesno[pProxys[i].NTLM]+CRLF
   + 'proxy-proto='+proxyproto2str[pProxys[i].proto]+CRLF
{   for pp:=low(pp) to high(pp) do cfg:=cfg
     +'proxy-'+proxyproto2str[pp]+'-host='+proxyes[i].addr[pp].host+CRLF
     +'proxy-'+proxyproto2str[pp]+'-port='+proxyes[i].addr[pp].port+CRLF;
}
     +'proxy-host='+pProxys[i].addr.host+CRLF
     +'proxy-port='+IntToStr(pProxys[i].addr.port)+CRLF;
   cfg := cfg + '------------------' + CRLF;
  end;

  savefile(userPath+proxiesFileName, CFG, True)
end;
*)

function  saveAllLists(const uPath : String; const pr : TRnQProtocol; pProxys : Tarrproxy) : Boolean;
const
  splitMsg='automsg: ';
  autoaway_name='AUTO-AWAY';
var
  zf: TZipFile;
//  ZIP: TZIPWriter;
  procedure AddFile2Zip(const fn : String; const cfg : RawByteString);
//  var
//    fIDX : Integer;
  begin
//    if cfg > '' then
     begin
//      fIDX := zf.AddFile(fn);
//      fIDX := zf.AddFile(fn, 0, '123');
//      fIDX := zf.AddFile(fn, 0, AccPass);
//      zf.Data[fIDX] := cfg;
//       fIDX :=
         zf.AddFile(fn, 0, AccPass, cfg);
     end;
//    zf.Files[fIDX].CommonFileHeader.VersionNeededToExtract
  end;
var
//  s: string;
  cfg: RawByteString;
  sA: AnsiString;
//  i: Integer;
  k, l: integer;
  Saved: Boolean;
  memStream: TMemoryStream;
  lFileOld,lFileNew, lFileBak: string;
begin
 Result := False; 
 if fantomWork then
   Exit;
{
    groups.save;          -- OK
    saveLists(MainProto); -- OK
    saveInbox;            -- OK
    saveOutbox;           -- OK
    saveCFG;              -- OK
    saveAutoMessages;     -- OK
    saveMacros;           -- OK
    savecommonCFG;        -- OK
    saveDB;               -- OK
    saveRetrieveQ;        -- OK
    if reopenchats then chatFrm.savePages; -- OK
    SaveExtSts;           -- OK
    SaveSpamQuests;       -- OK
}

  zf := TZipFile.Create;
//  i := 0;
//  zf.AddFile(dbFileName);
//  zf.Data[i] := db2str(contactsDB);
  zf.ZipFileComment := 'DB file of R&Q ver.' + IntToStrA(RnQBuild);

  cfg := db2strU(contactsDB);
  AddFile2Zip(dbFileName, cfg);

  cfg := AnsiString('protocol=') + AnsiString(pr.ProtoName) +CRLF+
       AnsiString('account-id=')+ pr.getMyInfo.UID2cmp +CRLF+
       AnsiString('account-name=')+ StrToUTF8(pr.getMyInfo.displayed)
 {$IFDEF UseNotSSI}
      +CRLF+ AnsiString('use-ssi=') + yesno[useSSI2]
 {$ELSE UseNotSSI}
      +CRLF+AnsiString('use-ssi=') + yesno[True]
 {$ENDIF UseNotSSI}
    ;
  AddFile2Zip(AboutFileName, cfg);
  cfg := '';

  AddFile2Zip(groupsFilename, groups.toString);
  AddFile2Zip(rosterFileName1, pr.readList(LT_ROSTER).toString);
//    msgDlg(getTranslation('Error saving contact list'),mtError);
  AddFile2Zip(visibleFileName1, pr.readList(LT_VISIBLE).toString);
//    msgDlg(getTranslation('Error saving visible list'),mtError);
  AddFile2Zip(invisibleFileName1, pr.readList(LT_INVISIBLE).toString);
//    msgDlg(getTranslation('Error saving invisible list'),mtError);
  AddFile2Zip(ignoreFileName1, ignorelist.toString);
//    msgDlg(getTranslation('Error saving ignore list'),mtError);
//  if NILdoWith = 2 then
   begin
    AddFile2Zip(nilFileName1, notinlist.toString);
//    msgDlg(getTranslation('Error saving not-in-list'),mtError);
   end;
  AddFile2Zip(uinlistFilename, uinlists.toString);
//    msgDlg(getTranslation('Error saving uinlists'), mtError);
 {$IFDEF CHECK_INVIS}
  AddFile2Zip(CheckInvisFileName1, CheckInvis.CList.toString);
//    msgDlg(getTranslation('Error saving Check-invisibility list'),mtError);
 {$ENDIF}

  if Assigned(eventQ) then
    AddFile2Zip(inboxFilename, eventQ.toString);

  if Assigned(Account.outbox) then
    AddFile2Zip(outboxFilename, Account.outbox.toString);

  AddFile2Zip(configFileName, getCFG);

  begin
   if Length(automessages[0]) > 5000 then
     automessages.Strings[0] := copy(automessages[0], 1, 5000);
   cfg:= StrToUTF8(automessages[0]) + CRLF;
   k:=1;
   while k < automessages.count do
    begin
      cfg:= cfg+splitMsg+ StrToUTF8(automessages[k])+CRLF+
                          StrToUTF8(automessages[k+1])+CRLF;
      inc(k,2);
    end;
   cfg := cfg+splitMsg+ autoaway_name+CRLF+ StrToUTF8(autoaway.msg)+CRLF;
   AddFile2Zip(automsgFilename, cfg);
   cfg := '';
  end;

  AddFile2Zip(macrosFileName, macros2str(macros));

//  inc(i);
//  zf.AddFile(commonFileName);
//  zf.Data[i] := getCommonCFG;

  if retrieveQ.empty then
//    deleteFile(uPath+retrieveFileName+'.txt')
   else
    AddFile2Zip(retrieveFileName1, retrieveQ.toString);
  if Assigned(chatFrm) then
    AddFile2Zip(reopenchatsFileName, chatFrm.Pages2String);

  cfg := '';
 {$IFDEF PROTOCOL_ICQ}
//  for I := low(XStatus6) to High(XStatus6) do
  for k := low(ExtStsStrings) to High(ExtStsStrings) do
  begin
    cfg := cfg+format(AnsiString('%d=%s'
           +CRLF+'caption=%s'
           +CRLF+'desc=%s'), [
      k, AnsiString(XStatusArray[k].Caption),
      StrToUTF8(ExtStsStrings[k].Cap),
      StrToUTF8(newline2slashn(ExtStsStrings[k].Desc))]);
//  f := f+format(CRLF+'ssi=%d', [a[i].ssiID]);
    cfg := cfg+CRLF;
  end;
  AddFile2Zip(extstatusesFilename, cfg);
 {$ENDIF PROTOCOL_ICQ}

  cfg := '';

  for k := low(spamfilter.quests) to High(spamfilter.quests) do
  begin
    sa := StrToUTF8(newline2slashn(spamfilter.quests[k].q));
    if sa > '' then
     begin
      cfg := cfg+format(AnsiString('question=%s'), [sA]);
      for l := low(spamfilter.quests[k].ans) to High(spamfilter.quests[k].ans) do
  //     cfg := cfg+format(AnsiString(CRLF + 'answer=%s'),[StrToUTF8(spamfilter.quests[k].ans[l])]);
       cfg := cfg+ CRLF + AnsiString('answer=') + StrToUTF8(spamfilter.quests[k].ans[l]);
  //  f := f+format(CRLF+'ssi=%d', [a[i].ssiID]);
      cfg := cfg+CRLF + '**********' + CRLF;
     end;
  end;
  AddFile2Zip(SpamQuestsFilename, cfg);

  cfg := '';
  if Length(pProxys)>0 then
  for k := 0 to Length(pProxys) - 1 do
  begin
   if pProxys[k].name = '' then
     pProxys[k].name := 'Proxy' + IntToStr(k+1);

   cfg := cfg
   + 'proxy-name='     + StrToUTF8(pProxys[k].name)+CRLF
//   + 'proxy='+yesno[pProxys[i].enabled]+CRLF
    +'proxy-serv-host='+ AnsiString(pProxys[k].serv.host)+CRLF
    +'proxy-serv-port='+ IntToStrA(pProxys[k].serv.port)+CRLF
   + 'proxy-auth='     + yesno[pProxys[k].auth]+CRLF
   + 'proxy-user='     + StrToUTF8(pProxys[k].user)+CRLF
//   + 'proxy-pass='     +passCrypt(pProxys[k].pwd)+CRLF
   + 'proxy-pass64='   +Base64EncodeString(passCrypt(pProxys[k].pwd))+CRLF
   + 'proxy-ntlm='     +yesno[pProxys[k].NTLM]+CRLF
   + 'connection-ssl=' +yesno[pProxys[k].ssl]+CRLF
   + 'proxy-proto='    +proxyproto2str[pProxys[k].proto]+CRLF
{   for pp:=low(pp) to high(pp) do cfg:=cfg
     +'proxy-'+proxyproto2str[pp]+'-host='+proxyes[i].addr[pp].host+CRLF
     +'proxy-'+proxyproto2str[pp]+'-port='+proxyes[i].addr[pp].port+CRLF;
}
     +'proxy-host='    + AnsiString(pProxys[k].addr.host)+CRLF
     +'proxy-port='    + IntToStrA(pProxys[k].addr.port)+CRLF;
   cfg := cfg + '------------------' + CRLF;
  end;
  AddFile2Zip(proxiesFileName, cfg);

  try
//    zf.SaveToFile(uPath+dbFileName + '4.new');
    memStream := TMemoryStream.Create;
    zf.SaveToStream(memStream);
    memStream.SaveToFile(uPath+dbFileName + '5.new');
    memStream.Free;
    Saved := True;
   except
    msgDlg('Error on saving DB5', True, mtError);
    Saved := False;
  end;
  zf.Free;
  if Saved then
   try
     if FileExists(uPath+dbFileName + '5') then
       begin
        lFileOld := uPath+dbFileName + '5';
        lFileNew := uPath+dbFileName + '5.new';
        lFileBak := uPath+dbFileName + '5.bak';
     if MakeBakups then
       begin
           ReplaceFile(PChar(lFileOld), PChar(lFileNew), PChar(lFileBak), REPLACEFILE_IGNORE_MERGE_ERRORS, NIL, NIL)
       end
      else
           ReplaceFile(PChar(lFileOld), PChar(lFileNew), NIL, REPLACEFILE_IGNORE_MERGE_ERRORS, NIL, NIL)
       end
      else
//       DeleteFile(uPath+dbFileName + '5');
     RenameFile(uPath+dbFileName + '5.new', uPath+dbFileName + '5');
    except
//    RnQFileUtil.saveFile(userPath+dbFileName, s, True);
     msgDlg('Error on saving DB', True, mtError);
   end;

//    if FileExists(userPath+dbFileName) then
//      DeleteFile(userPath+dbFileName);
//  if FileExists(userPath+dbFileName + '2') then
//    DeleteFile(userPath+dbFileName + '2');
  Result := True;
end;

function doConnect: boolean;
var
// msg : string;
// evInt : Integer;
 pr: TRnQProtocol;
begin
 result := FALSE;
 if not Assigned(Account.AccProto) or
    not Account.AccProto.isOffline then
   exit;

 result:=TRUE;
 if not useLastStatus then
  lastStatus:= RnQstartingStatus;
 setProgBar(Account.AccProto, 0.1/progLogonTotal);
 pr := Account.AccProto.ProtoElem;
// if MainProto.ProtoName = 'ICQ' then
   begin
//  proxy_http_Enable(ICQ.sock);
 {$IFDEF PROTOCOL_ICQ}
      if (MainProxy.ssl)
 {$IFNDEF ICQ_ONLY}
          and(pr.ProtoID = ICQProtoID)
 {$ENDIF ICQ_ONLY}
      then
       MainProxy.serv.host := TicqSession(pr).SSLserver;
 {$ENDIF PROTOCOL_ICQ}
    CopyProxy(pr.aProxy, MainProxy);
    pr.sock.proxySettings(pr.aProxy);

    pr.loginServerAddr := pr.aProxy.serv.host;
    pr.loginServerPort := IntToStrA(pr.aProxy.serv.port);
 {$IFDEF USE_SSL}
    pr.sock.isSSL := pr.aProxy.ssl;
 {$ENDIF USE_SSL}
//    if pr.aProxy.proto = PP_HTTPS then
      begin
    //    statusicon.update;
    //    try
    //      ICQ.sock.DnsLookup(proxy.serv.host);
       if (pr.loginServerAddr = lastserverAddr)and(lastServerIP > '') then
         connect_after_dns(Account.AccProto)
       else
       if WSocketIsDottedIP(pr.loginServerAddr) or
         not MainProxy.rslvIP
       then
         begin
           lastserverAddr := pr.loginServerAddr;
           lastServerIP := pr.loginServerAddr;
           connect_after_dns(Account.AccProto)
         end
       else
        begin
          if resolving then
            Exit;
    //      icq.sock.MultiThreaded := True;
    //      icq.sock.ThreadAttach
//          try
            resolving:=TRUE;
          PostMessage(RnQmain.Handle, WM_RESOLVE_DNS, 0, 0);
  {          pr.sock.DnsLookup(pr.aProxy.serv.host);
          except
           on E:Exception do
            begin
              evInt:=WSocket_WSAGetLastError;
              msg := E.Message;
              Account.AccProto.disconnect;
              resolving:= False;
              setProgBar(Account.AccProto, 0);
              msgDlg(getTranslation('DNS error: [%d]\n%s' , [evInt, Msg]), False, mtError);
            end
           else
            begin
              evInt:=WSocket_WSAGetLastError;
              Msg := WSocketErrorDesc(evInt);
              Account.AccProto.disconnect;
              resolving:= False;
              setProgBar(Account.AccProto, 0);
              msgDlg(getTranslation('DNS error: [%d]\n%s' , [evInt, Msg]), False, mtError);
            end;
          end;}
//          pr.sock.DnsLookup(pr.loginServerAddr)
        end;
    //    lastserverAddr := ICQ.loginServerAddr
      ;
      end
   end
end; // doConnect

procedure connect_after_dns(const proto : TRnQProtocol);
//var
//  icq : TicqSession;
begin
   begin
   if lastServerIP > '' then
     proto.ProtoElem.loginServerAddr := lastServerIP
  ;
   {$IFDEF UseNotSSI}
    if (proto.ProtoElem is TicqSession) then
      TicqSession(proto.ProtoElem).updateVisibility;
  //  ICQ.updateVisibility;
   {$ENDIF UseNotSSI}
//    proto.ProtoElem.sock.MultiThreaded := False;
//    proto.ProtoElem.sock.MultiThreaded := True;
    if lastStatus = byte(SC_OFFLINE) then
      proto.setStatus(byte(SC_ONLINE))
     else
      if not exitFromAutoaway() then
        proto.setStatus(byte(lastStatus));
   end;
end; // connect_after_dns

function findAuthReq(c: TRnQContact): TauthreqFrm;
var
  i: integer;
begin
with childWindows do
  begin
  i:=0;
  while i < count do
    begin
    if Tobject(items[i]) is TauthreqFrm then
      begin
      result := TauthreqFrm(items[i]);
      if result.contact.equals(c) then
        exit;
      end;
    inc(i);
    end;
  end;
result:=NIL;
end; // findAuthreq

function findViewInfo(c: TRnQContact): TRnQViewInfoForm;
var
  i: integer;
begin
with childWindows do
  begin
  i:=0;
  while i < count do
    begin
    if Tobject(items[i]) is TRnQViewInfoForm then
      begin
      result:=TRnQViewInfoForm(items[i]);
      if result.contact.equals(c) then
        exit;
      end;
    inc(i);
    end;
  end;
result:=NIL;
end;


procedure ShowSplash;
const
  minWidth = 200;
{var
//  region:HRGN;
//  b0 : TBitmap;
//  b1 : TGPBitmap;
//  gr : TGPGraphics;
//  p  :TGPPointF;
//  gp : TGPGraphicsPath;
//  fnt : TGPFont;
//  br : TGPBrush;
//  rgn : TGPRegion;
//  x : Integer;
  transcolor:integer;
  brF : HBRUSH;
  st : Integer;
//  transcolor :TColor;
}
begin
 try
{   bmp2 := TBitmap.Create;
   bmp2.PixelFormat := pf32bit; }
  splashImgElm.ThemeToken := -1;
  splashImgElm.picName := PIC_SPLASH;
  splashImgElm.Element := RQteDefault;
  splashImgElm.pEnabled := True;
  with theme.GetPicSize(splashImgElm) do
  begin

(*
    begin
      if (cx = 0) or (cy = 0) then
       Exit;
{     bmp := createBitmap(max(cx, minWidth), cy + 30);
     bmp.PixelFormat := pf32bit;}
//     b0 := createBitmap(max(cx, minWidth), cy + 30);
//     b0 := createBitmap(max(cx, minWidth), cy);
     b0 := createBitmap(cx, cy);
     b0.PixelFormat := pf32bit;
//     b0.PixelFormat := pf24bit;
//   b0.TransparentColor := ABCD_ADCB($020201);
//   b0.TransparentColor := $020201;
   b0.TransparentColor := ABCD_ADCB($030201);
//     b0.Canvas.fi;
   transcolor := b0.TransparentColor AND $FFFFFF;
   b0.TransparentMode := tmFixed;
//   transcolor := b0.TransparentColor;
   b0.TransparentColor := transcolor;
   b0.Transparent := True;
//   bmp.TransparentColor := transcolor;
   brF := CreateSolidBrush(transcolor);
   FillRect(b0.Canvas.Handle, b0.Canvas.ClipRect, brF);
   DeleteObject(brF);
//   b0.Canvas.Brush.Color := transcolor;
//   b0.Canvas.FillRect(b0.Canvas.ClipRect);
//   theme.drawPic(b0.Canvas, x, 30, PIC_SPLASH);
//   bmp2.Free;
{   b0.Canvas.Font.Size := 18;
   b0.Canvas.Brush.Color := clBlue;
   b0.Canvas.Font.Color := clBlue;
   theme.ApplyFont('splash', b0.Canvas.Font);
//   SetBKMode(b0.canvas.Handle, TRANSPARENT);
  SetBKMode(b0.canvas.Handle, TRANSPARENT);
  TextOut(b0.canvas.Handle, 5, 0, 'http://RnQ.ru', length('http://RnQ.ru'));
}
//     theme.drawPic(b0.Canvas.Handle, (max(cx, minWidth)- cx) div 2, 30, PIC_SPLASH,
     theme.drawPic(b0.Canvas.Handle, Point(0, 0), splashImgElm);

//     region:= CreateRectRgn(0, 0, cx, 30 + cy);
//     b1 := TGPBitmap.Create(max(cx, minWidth), cy + 30);
{     if cx < minWidth then
       x := (minWidth - cx) div 2
      else
       x := 0;}
    end;
{   gr := TGPGraphics.Create(b0.Canvas.Handle);
//   gr := TGPGraphics.Create(b1);
   gr.Clear(aclTransparent);
{   Fnt := TGPFont.Create('Arial', 18, FontStyleBold or FontStyleItalic);
   Br := TGPSolidBrush.Create(aclBlue);
   p.X := 0; p.Y := 0;
   gr.DrawString(wideString('http://RnQ.ru'), length('http://RnQ.ru'), fnt,
     p, br);
   br.Free; fnt.Free;
}
//   theme.drawPic(gr, 0, 30, PIC_SPLASH, splashPicTkn, splashPicLoc, splashPicIdx);
//   bmp.Canvas.TextOut(0, 0, 'http://RnQ.ru');
//   theme.getPic(PIC_SPLASH, bmp);


//  region := theme.GetPicRGN(PIC_SPLASH, splashPicTkn, splashPicLoc, splashPicIdx);
{
  rgn := TGPRegion.Create;
  gp := TGPGraphicsPath.Create;
  gp.AddString(wideString('http://RnQ.ru'), length('http://RnQ.ru'), fnt, FontStyleBold, 18,
     p, br)
  region := rgn.GetHRGN(gr);
}
//  gr.Free;//rgn.Free;

//  b0.Transparent := True;
//  region:=getRegion2(b0);
  region:=getRegion(b0);
*)
   splashFrm:=TForm.create(application);

//    SetWindowLong(splashFrm.Handle, GWL_EXSTYLE, GetWindowLong(splashFrm.Handle, GWL_EXSTYLE) or WS_EX_LAYERED);
//    GetWindowLong(Parent.Handle, GWL_STYLE)
//    SetWindowLong(splashFrm.Handle, GWL_STYLE, WS_VISIBLE);
//    SetWindowPos(splashFrm.Handle, 0, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE or SWP_NOZORDER or SWP_FRAMECHANGED);

  g_hLib_User32 := LoadLibrary('user32.dll');
  if g_hLib_User32 = 0 then
    raise Exception.Create('LoadLibrary(user32.dll) failed');

  @g_pUpdateLayeredWindow := GetProcAddress(g_hLib_User32, 'UpdateLayeredWindow');
  with splashFrm do
    begin
//    color:=clBlack;
//    color := theme.GetFontProp('splash', FPT_COLOR).color;
//    TransparentColorValue := transcolor;
    position:=poScreenCenter;
    Width:= cx;
    Height:= cy;
    borderstyle := bsNone;
//    if region > 0 then
//      SetWindowRgn(handle,region,TRUE);
     BorderStyle := bsNone;
    onPaint:=RnQmain.splashPaint;

//    st := GetWindowLong(splashFrm.Handle, GWL_EXSTYLE);
//    SetWindowLong(splashFrm.Handle, GWL_EXSTYLE, st and not WS_EX_LAYERED);
//    SetWindowLong(splashFrm.Handle, GWL_EXSTYLE, st or WS_EX_LAYERED);
    SetWindowLong(splashFrm.Handle, GWL_STYLE, WS_VISIBLE);
//    SetWindowLongPtr(splashFrm.Handle, GWL_STYLE, WS_VISIBLE);  // Win64 compatible!!!
    SetWindowPos(splashFrm.Handle, 0, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE or SWP_NOZORDER or SWP_FRAMECHANGED);
    show;
    RnQmain.splashPaint(splashFrm);
     bringForeground:= splashFrm.handle;
     setTopMost(splashFrm, True);
//    repaint;
//      splashFrm.Canvas.Draw(0, 0, b0);
    end;
  end;
(*  b0.Free; *)
 except
end;
end; // ShowSplash

function viewHeventWindow(ev:Thevent):Tform;
begin
  result:=NIL;
  if ev=NIL then
    exit;
  result := viewTextWindow(ev.getHeaderText, ev.getBodyText, ev.getBodyBin);
//theme.GetIco2(ev.pic, result.icon);
theme.pic2ico(RQteFormIcon, ev.pic, result.icon);
end; // viewHeventWindow

function openSaveDlg(parent:Tform; const Cptn : String; IsOpen : Boolean;
         const ext : String= ''; const extCptn : String = '';
         const defFile : String =''; MultiSelect : boolean = false):string;
var
  Filtr : String;
  fn : String;
  hndl : THandle;
//  defDir : String;
begin
  if ext > '' then
   if extCptn > '' then
    Filtr:=getTranslation(extCptn)+'|*.'+ext+'|'+getTranslation('All files')+'|*.*'
   else
    Filtr:='*.'+ext+'|*.'+ext+'|'+getTranslation('All files')+'|*.*'
  else
    Filtr:=getTranslation('All files')+'|*.*';
//  if defFile = '' then
//    defFile := myPath;
//dlg.options:=[ofFileMustExist,ofEnableSizing];
  if parent <> NIL then
    hndl := parent.Handle
   else
    hndl := 0;
  fn := ExtractFileName(defFile);
  if OpenSaveFileDialog(Hndl, ext, Filtr, ExtractFileDir(defFile),
    getTranslation(cptn), fn, IsOpen, MultiSelect) then
    result:=fn
  else
    result:='';
end; // opendlg

function str2html(const s:string):string;
begin
result:=template(s, [
  '&', '&amp;',
  '"', '&quot;',
  '<', '&lt;',
  '>', '&gt;',
  CRLF, '<br>',
  #13, '<br>',
  #10, '<br>'
]);
end; // str2html

function strFromHTML(const s:string):string;
begin
result:=template(s, [
  '&amp;', '&',
  '&quot;', '"',
  '&lt;', '<',
  '&gt;', '>',
  '<br>', CRLF
//  '<br>', #13,
//  '<br>', #10,
]);
end; // str2html


procedure restoreForeWindow;
begin
  if oldForewindow=0 then
   exit;
  bringForeground := oldForeWindow;
  oldForewindow := 0;
end; // restoreForeWIndow

procedure applyTransparency(forced: integer = -1);
var
  bak:Thandle;
begin
  if not running then
    exit;
  bak := RnQmain.handle;
  RnQmain.alphablend:=transparency.forRoster or (forced>0);
  chatfrm.alphablend:=transparency.forChat or (forced>0);
  if RnQmain.alphablend then
   if forced >= 0 then
  	begin
    RnQmain.alphablendvalue:=forced;
//    chatfrm.alphablendvalue:=forced
    end
  else
  	begin
//    chatFrm.AlphaBlendValue:=transparency.active;
    if RnQmain.handle=getForegroundWindow then
      RnQmain.alphablendvalue:=transparency.active
    else
      RnQmain.alphablendvalue:=transparency.inactive;
    end;
  if chatfrm.alphablend then
   if forced >= 0 then
     chatfrm.alphablendvalue:=forced
    else
     chatFrm.AlphaBlendValue:=transparency.active;
  if bak<>RnQmain.handle then
    mainfrmHandleUpdate;
end; // applyTransparency

procedure applyDocking(Undock: Boolean = false);
var
  r: TRect;
begin
 try
  if docking.Dock2Chat then
   begin
     if Undock then
      begin
       if not RnQmain.Floating then
        begin
         if Assigned(RnQmain.Parent) then
           R.TopLeft := RnQmain.Parent.ClientToScreen(Point(RnQmain.Left, RnQmain.Top))
          else
           R.TopLeft := Point(RnQmain.Left, RnQmain.Top);
        end;
         R.Right := r.Left + RnQmain.Width;
         R.Bottom := r.Top + RnQmain.Height;
         RnQmain.ManualFloat(R);
      end
     else
      begin
       mainDlg.RnQmain.DragKind := dkDock;
       chatFrm.CLSplitter.Visible := True;
       chatFrm.CLPanel.Visible := True;
       if docking.Docked2chat and RnQmain.Floating then
         if chatFrm.pageCtrl.pageCount > 0 then
          begin
           chatFrm.MainFormWidth := RnQmain.Width;
           RnQmain.ManualDock(chatFrm.CLPanel);
           RnQmain.Visible := True;
          end;
      end;
   end
  else
   begin
     if not RnQmain.Floating then
      try
{        if Assigned(chatFrm.DockManager) then
          chatFrm.DockManager.RemoveControl(RnQmain)
         else
          if Assigned(chatFrm.CLPanel.DockManager) then
            chatFrm.CLPanel.DockManager.RemoveControl(RnQmain);}
         if Assigned(RnQmain.Parent) then
           R.TopLeft := RnQmain.Parent.ClientToScreen(Point(RnQmain.Left, RnQmain.Top))
          else
           R.TopLeft := Point(RnQmain.Left, RnQmain.Top);
         R.Right := r.Left + RnQmain.Width;
         R.Bottom := r.Top + RnQmain.Height;
         RnQmain.ManualFloat(R);
       except
      end;
     docking.Docked2chat := False;
     mainDlg.RnQmain.DragKind := dkDrag;
     chatFrm.CLPanel.Visible := False;
     chatFrm.CLSplitter.Visible := False;
   end;
 finally
  mainfrmHandleUpdate;
 end;
end;

function  loadDB(zp: TZipFile; pCheckGroups: Boolean): Boolean;
var
  s: RawByteString;
  zf: TZipFile;
  i: Integer;
begin
  freeDB(contactsDB);
  s := '';
  if Assigned(zp) then
   begin
//     zf := TZipFile.Create;
       try
        i := zp.IndexOf(dbFileName);
        if i >=0 then
          s := zp.data[i];
       except
         s := '';   
       end
   end;
 if s = '' then
  if FileExists(Account.ProtoPath + dbFileName) then
    s := loadFileA(Account.ProtoPath + dbFileName)
   else
      begin
       zf := TZipFile.Create;
       try
//        if FileExists(userPath+dbFileName + '4') then
//         begin
//           zf.LoadFromFile(userPath+dbFileName + '4');
//           i := zf.IndexOf(dbFileName);
//           if i >=0 then
//             s := zf.Uncompressed[i];
//         end
//        else
        if FileExists(Account.ProtoPath + dbFileName + '3') then
         begin
           zf.LoadFromFile(Account.ProtoPath + dbFileName + '3');
           i := zf.IndexOf(dbFileName);
           if i >=0 then
             s := zf.data[i];
         end
        except
         s := '';
       end;
       zf.Free;
      end;
//    if FileExists(userPath+dbFileName + '2') then
//      s := ZDecompressStrEx(loadFile(userPath+dbFileName + '2'))
//     else
//  contactsDB:=str2db(Account.AccProto.getContactClass, s, result)
  contactsDB:=str2db(Account.AccProto, s, result, pCheckGroups);
  contactsDB.add(Account.AccProto, Account.AccProto.ProtoElem.MyAccNum)
end; // loadDB

(*
procedure saveDB;
var
 s : string;
  zf : TZipFile;
//  ZIP: TZIPWriter;
begin
  s := db2str(contactsDB);
//  saveFile(userPath+dbFileName, s, True);
//  saveFile(userPath+dbFileName + '2', ZCompressStrEx(s, clMax), True);
{    ZIP := TZIPWriter.Create(userPath+dbFileName + '3', '');
    try
//      for i := 0 to (List.Count - 1) do
//        ZIP.AddFile(List[i], ExtractFileName(List[i]));
      ZIP.AddString(s, dbFileName);
    finally
      ZIP.Free;
    end;
}

  zf := TZipFile.Create;
  zf.AddFile(dbFileName);
  zf.Data[0] := s;
  try
    zf.SaveToFile(userPath+dbFileName + '3');
    if FileExists(userPath+dbFileName) then
      DeleteFile(userPath+dbFileName);
   except
    RnQFileUtil.saveFile(userPath+dbFileName, s, True);
    msgDlg('Error on saving DB', mtError);
  end;
  zf.Free;

  if FileExists(userPath+dbFileName + '2') then
    DeleteFile(userPath+dbFileName + '2');
end;
*)

function compContacts(Item1, Item2: Pointer):Integer;
begin
  result := compareText(TRnQContact(item1).displayed, TRnQContact(item2).displayed)
end;

function compContactsByGroup(Item1, Item2: Pointer):Integer;
var
  c1,c2 : TRnQcontact;
begin
  c1:=TRnQcontact(item1);
  c2:=TRnQcontact(item2);
if c1.group < c2.group then
  result:=-1
else
  if c1.group > c2.group then
    result:=+1
  else
    result:=compareText(c1.displayed, c2.displayed);
end; // compContacts

procedure sortCL(cl:TRnQCList);
begin
  cl.sort(compContacts)
end;

procedure sortCLbyGroups(cl:TRnQCList);
begin
  cl.sort(compContactsByGroup)
end;

//////////////////////////////////////////////////////////////////////////
procedure hideForm(frm:Tform);
begin
  if frm=NIL then
    exit;
  if frm = RnQmain then
   begin
     if formvisible(RnQmain) then
       RnQmain.toggleVisible;
     exit;
  end;
  frm.hide;
  ShowWindow(application.handle,SW_HIDE)
end;

function PrefIsVisiblePage(const pf: String): Boolean;
begin
  Result := True;
  if pf = 'ICQ' then
    if not Assigned(Account.AccProto)
 {$IFNDEF ICQ_ONLY}
       or not (Account.AccProto.ProtoElem.ProtoID = ICQProtoID)
 {$ENDIF ICQ_ONLY}
    then
    Result := false;
 {$IFNDEF ICQ_ONLY}
  if pf = 'XMPP' then
    if not Assigned(Account.AccProto)
       or not (Account.AccProto.ProtoElem.ProtoID = XMPProtoID) then
    Result := false;
 {$ENDIF ICQ_ONLY}
end;

procedure showForm(whatForm:TwhatForm; const Page: String = ''; Mode: TfrmViewMode = vmFull);
var
  frm:^Tform;
  frmclass:TcomponentClass;
  i //, actPage
   : Byte;
  arr : array of TPrefPage;
  cr : boolean;
begin
case whatForm of
// {$IFNDEF RNQ_LITE}
  WF_PREF: begin frmclass:=TprefFrm; frm:=@prefFrm end;
// {$ENDIF RNQ_LITE}
  WF_USERS: begin frmclass:=TusersFrm; frm:=@usersFrm end;
 {$IFDEF PROTOCOL_ICQ}
  WF_WP: begin
           frmclass:=TwpFrm;
           frm:=@wpFrm
         end;
 {$ENDIF PROTOCOL_ICQ}
 {$IFDEF PROTOCOL_MRA}
  WF_WP_MRA: begin
           frmclass:=TwpMRAFrm;
           frm:=@wpMRAFrm
         end;
 {$ENDIF PROTOCOL_MRA}
  WF_SEARCH: begin frmclass := TAllHistSrchForm; frm:=@AllHistSrchForm; end;
  else exit;
  end;
  if frm^=NIL then
  begin
    cr := True;
    application.createForm(frmclass, frm^);
    applyCommonsettings(frm^);
    translateWindow(frm^);
  end
  else
    cr := false;

// {$IFNDEF RNQ_LITE}
//  actPage := 0;
  if whatForm = WF_PREF then
  begin
    SetLength(arr, 0);
    if Page > '' then
     if cr and (Mode <> vmFull) then
      for i := 0 to length(prefPages)-1 do
        if prefPages[i].Name = Page then
          begin
//           if cr and (Mode <> vmFull) then
             begin
              SetLength(arr, 1);
              arr[0] := prefPages[i];
             end;
//            else
//              actPage := i;
            break;
          end;

    if cr then
      begin
       prefFrm.SetViewMode(arr);
       if Mode = vmFull then
        begin
         prefFrm.SetActivePage(Page);
        end
      end
     else
      if Page > '' then
       begin
        prefFrm.SetActivePage(Page);
       end;
    SetLength(arr, 0);
  end;
// {$ENDIF RNQ_LITE}

  showForm(frm^);
end; // showPref

function showUsers(var pass: String): TUID;
begin
  application.createForm(TusersFrm, usersFrm);
  applyCommonsettings(usersFrm);
  //applyTaskButton(usersFrm);
  translateWindow(usersFrm);
  result := usersFrm.doSelect;
  pass := usersFrm.resAccPass;
  freeandNIL(usersFrm);
end; // showUsers

function CheckAccPas(const uid: TUID; const db: String; var pPass: String): Boolean;
begin
      pPass := '';
      if enterPwdDlg(pPass, getTranslation('Account password') + ' (' + uid + ')', 16) then
         if CheckZipFilePass(db, dbFilename, pPass) then
           begin
//             resAccPass := newAccPass;
             Result := True
           end
          else
           begin
            pPass := '';
            Result := False;
            msgDlg('Wrong password', True, mtWarning)
           end
       else
        begin
          Result := False;
          msgDlg('Please enter password', True, mtWarning);
        end;
end;

procedure updateViewInfo(c: TRnQcontact);
begin
if not updateViewInfoQ.exists(c) then
  updateViewInfoQ.add(c);
end;


{
procedure saveInbox;
begin
  if Assigned(eventQ) then
    saveFile( userPath+inboxFilename, eventQ.toString )
end;


procedure loadInbox(zp : TZipFile);
var
 s : AnsiString;
 i : Integer;
begin
  i := -1;
  if Assigned(zp) then
   try
     i := zp.IndexOf(inboxFilename);
     if i >= 0 then
      s := zp.Uncompressed[i];
    except
     i := -1;
     s := '';
   end;
  if i < 0 then
   s := loadfile(userPath+inboxFilename)

  eventQ.fromString( s );
  eventQ.removeExpiringEvents;
end;

{
procedure saveOutbox;
begin saveFile( userPath+outboxFilename, outbox.toString ) end;}

procedure loadOutInBox(zp : TZipFile);
var
 s : RawByteString;
 i : Integer;
 zipPref : Boolean;
begin
  i := -1;
  zipPref := False;
  if Assigned(zp) then
   try
     i := zp.IndexOf(outboxFilename);
     if i >= 0 then
      s := zp.data[i];
    except
     i := -1;
     s := '';
   end;
  if i < 0 then
    s := loadfileA(Account.ProtoPath + outboxFilename)
   else
    zipPref := True;
  Account.outbox.fromString(s);
  if zipPref then
    begin
     i := zp.IndexOf(inboxFilename);
     if i >= 0 then
      s := zp.data[i];
    end
   else
    s := loadfileA(Account.ProtoPath + inboxFilename);

  eventQ.fromString( s );
  eventQ.removeExpiringEvents;
end;

procedure openSendContacts(dest: TRnQcontact);
var
  wnd: TselectCntsFrm;
begin
  if not Assigned(dest) then
    Exit;
  wnd := TselectCntsFrm.doAll2( RnQmain,
                              getTranslation('To %s',[dest.displayed]),
                              getTranslation('Send selected contacts'),
                              dest.fProto,
                              notInList.clone.add(dest.fProto.readList(LT_ROSTER)),
                              RnQmain.sendContactsAction,
                              [sco_multi,sco_groups,sco_predefined],
                              @wnd
                              );
//  Theme.getIco2(PIC_CONTACTS, wnd.icon);
  Theme.pic2ico(RQteFormIcon, PIC_CONTACTS, wnd.icon);
  wnd.extra := Tincapsulate.aString(dest.uid);
end; // openSendContacts

function isEmailAddress(const s: string; start: integer): integer;
//const
//  emailChar=['a'..'z','A'..'Z','0'..'9','-','_','.'];
var
  j: integer;
  existsDot: boolean;
begin
result := -1;
if s[start] in EMAILCHARS then   // chi comincia bene...
  begin
  // try to find the @
  j := start+1;
  while (j < length(s)) and (s[j] in EMAILCHARS) do
    inc(j);
  if s[j]='@' then
    begin
    // @ found, now skip the @ and search for .
    inc(j);
    existsDot:=FALSE;
    while (j < length(s)) and (s[j+1] in EMAILCHARS) do
      begin
      if s[j]='.' then
        begin
        existsDot:=TRUE;
        break;
        end;
      inc(j);
      end;
    if existsDot and (s[j] in EMAILCHARS) then // at least a valid char after the . must exists
      begin
        repeat
        inc(j);
        until (j > length(s)) or not  (s[j] in EMAILCHARS); // go forth till we're out or we meet an invalid char
      result:=j-1;
      end;
    end;
  end;
end; // isEmailAddress

procedure notAvailable;
begin
  msgDlg('This feature isn''t available yet.\nCome back tomorrow...', True, mtInformation)
end;

function childParent(child,parent:integer):boolean;
begin
 result:=TRUE;
  repeat
  if child = parent then
    exit;
  child:=getParent(child);
  until child=0;
 result:= parent=0;
end; // childParent

procedure myBeep;
begin
  if playSounds then
    beep
end;

function whatStatusPanel(statusbar:Tstatusbar; x:integer):integer;
var
  x1:integer;
begin
result:=0;
x1:=statusbar.panels[0].width;
while (x > x1) and (result<statusbar.Panels.Count-1) do
  begin
  inc(result);
  inc(x1, statusbar.panels[result].width);
  end;
end; // whatStatusPanel

function sendProtoMsg(var oe: TOevent): Boolean;
var
//  c  : Tcontact;
  ev: THevent;
  vBin: RawByteString;
  vStr: String;
  send_msg: String;
  fl: Cardinal;
  i: Integer;
begin
//  c:= Tcontact(contactsDB.get( oe.uid));

{if (c.lastPriority>0) and (c.status in [SC_dnd,SC_occupied]) then
  oe.flags:=oe.flags or c.lastPriority;}
  oe.flags:=oe.flags or IF_urgent;

  if oe.flags and IF_multiple <> 0 then
   oe.flags:=oe.flags or IF_noblink and not IF_urgent;

  vBin := plugins.castEv( PE_MSG_SENT, oe.whom.uid,oe.flags,oe.info);
  if (vBin>'') then
    if(byte(vBin[1])=PM_DATA) then
     begin
      i := _int_at(vBin, 2);
      send_msg:= UnUTF(_istring_at(vBin, 2));
      if length(vBin)>= 1+4+ i  + 4 then
       oe.info := UnUTF(_istring_at(vBin, 2+4+ i))
      else
       oe.info := send_msg;
     end
     else if (byte(vBin[1])=PM_ABORT) then
      exit
     else
      begin end
   else
     send_msg := oe.info;
  vBin := '';
  if Length(send_msg) = 0 then
    exit;
  result := True;
  oe.id := oe.whom.fProto.sendMsg(oe.whom, oe.flags, send_msg, result);
  oe.timeSent:=now;
  if result then
    Account.acks.add(oe.kind, oe.whom, oe.flags, 'MSG').ID := oe.ID;

  if Length(oe.info) = 0 then
    exit;
 {$IFDEF DB_ENABLED}
  if (oe.flags and IF_Bin) <> 0 then
    begin
      vBin := oe.info;
      vStr := '';
      fl := oe.flags;
    end
   else
    begin
      vBin := '';
      vStr := oe.info;
      fl := oe.flags or IF_UTF8_TEXT;
    end;
 {$ELSE ~DB_ENABLED}
  if (oe.flags and IF_Bin) <> 0 then
    begin
      vBin := oe.info;
      vStr := '';
      fl := oe.flags;
    end
   else
    begin
      vBin := StrToUTF8(oe.info);
      vStr := '';
      fl := oe.flags or IF_UTF8_TEXT;
    end;
 {$ENDIF ~DB_ENABLED}
  ev:=Thevent.new(EK_MSG, oe.whom.fProto.getMyInfo, oe.timeSent, vBin{$IFDEF DB_ENABLED}, vStr{$ENDIF DB_ENABLED}, fl, oe.id);
  ev.fIsMyEvent := True;
   if logpref.writehistory and (BE_save in behaviour[ev.kind].trig) and ( oe.flags and IF_not_save_hist = 0) then
    writeHistorySafely(ev, oe.whom);
//  if oe.flags and IF_not_show_chat = 0 then
//    chatFrm.addEvent_openchat(c, ev.clone);
  chatFrm.addEvent(oe.whom, ev.clone);
  ev.Free;
end; // sendProtoMsg

procedure SendEmail2Mail(const email : String);
begin
  if email > '' then
    exec('mailto:'+ email);
end;

function deleteFromTo(const fn: string; from,to_:integer):boolean;
begin
  result := partDeleteFile(fn,from,to_-from)
end;

function enterUinDlg(const proto: TRnQProtocol; var uin: TUID; const title: string=''): boolean;
var
  res: TUID;
  ttl : String;
  s : String;
//  e: integer;
//  fUIN : Int64;
   prCl : TRnQProtoClass;
begin
  if title='' then
    ttl:='uin'
   else
    ttl := title;
  res:='';
  repeat
   result:=InputQuery(getTranslation(ttl), getTranslation('UIN'), s);
   res := s;
   if result then
    begin
      res := trim(res);
      uin := res;
      if proto = NIL then
        begin
         result := False;
         for prCl in RnQProtos do
//          if prCl._isValidUid(uin) then
          if prCl._isProtoUid(uin) then
           begin
            result:= True;
            uin := res;
            break;
           end;
        end
       else
        result:= proto.validUid1(uin);
     if result then
       begin
//        uin := res;
        break
       end
      else
       msgDlg('Invalid UIN', True, mtError)
    end;
  until not result;
end; // enterUinDlg

function enterPwdDlg(var pwd: String; const title: string=''; maxLength: integer=0;
                      AllowNull: Boolean = False): Boolean;
var
  frm: pwdDlg.TmsgFrm;
begin
  frm:=pwdDlg.TmsgFrm.create(Application);
  frm.txtBox.MaxLength:=maxLength;
  translateWindow(frm);
  setwindowlong(frm.handle, GWL_HWNDPARENT, 0);
//  You must not call SetWindowLong with the GWL_HWNDPARENT index to change the parent of a child window.
//  Instead, use the SetParent function.
//  SetParent(frm.handle, 0);
  if title > '' then
//    frm.caption:=getTranslation(title)
    frm.caption:= title
//   else
     ;
  frm.txtBox.text:='';
  frm.AllowNull := AllowNull;
  bringForeground:=frm.handle;
  setTopMost(frm, True);
  frm.showModal;
  result:= frm.exitCode=pwdDlg.EC_enter;
  if result then
    pwd:=trim(frm.txtBox.text);
  FreeAndNil(frm);
end; // enterPwdDlg

{$IFDEF RNQ_FULL2}
procedure convertHistoriesDlg(oldPwd, newPwd: AnsiString);
begin
  if oldPwd=newPwd then
    exit;
  if not ICQ.isOffline then
    if messageDlg(getTranslation('You have to be offline for this operation!\nDisconnect?'),mtConfirmation,[mbYes,mbNo],0)=mrNo then
      exit
     else
      ICQ.disconnect;
  chatFrm.closeAllPages;
  convhistFrm := TconvhistFrm.Create(Application);
  convhistFrm.oldPwd := oldPwd;
  convhistFrm.newPwd := newPwd;
  convhistFrm.showModal;
end; // convertHistoriesDlg
{$ENDIF}

function addToRoster(c: TRnQContact; group: integer; const isLocal: Boolean = True): boolean;
begin
  // Add SSI
  result:=FALSE;
  if c=NIL then
    exit;
  if group=2000 then
    group:=0;
  c.group:=group;
  saveGroupsDelayed:=TRUE;
  result := addToRoster(c, isLocal) or roasterLib.update(c);
end; // addToRoster

function addToNIL(c: TRnQContact; isBulk: Boolean = false): boolean;
begin
  result:=FALSE;
  c.fProto.removeContact(c);
  if not notInList.add(c) then
    exit;
  if not isBulk then
   begin
    roasterlib.update(c);
    saveListsDelayed:=TRUE;
   end;
  plugins.castEvList( PE_LIST_ADD, PL_NIL, c);
  result:=TRUE;
end; // addToNIL

procedure NILifNIL(c: TRnQContact; isBulk: Boolean = false);
begin
  if Assigned(c) then
  if not c.isInRoster then
   begin
    addToNIL(c, isBulk);
 {$IFDEF PROTOCOL_ICQ}
    if not isBulk and (c is TICQContact) then
     if TICQContact(c).infoUpdatedTo=0 then
      TicqSession(c.fProto).sendQueryInfo(TICQcontact(c).uinINT);
 {$ENDIF PROTOCOL_ICQ}
   end;
end; // eventFrom

function deltree(path: String): Boolean;
var
  sr: TsearchRec;
begin
  result:=FALSE;
  if (path='') or not directoryExists(path) then
    exit;
  path := includeTrailingPathDelimiter(path);
  if findFirst(path+'*.*', faAnyFile, sr) = 0 then
   repeat
    if (sr.name<>'.') and (sr.name<>'..') then
      if sr.Attr and faDirectory > 0 then
        deltree(path+sr.name)
       else
        deleteFile(path+sr.name);
   until findNext(sr) <> 0;
  findClose(sr);
//path:=ExcludeTrailingPathDelimiter(path);
  result := RemoveDir(path);
end; // deltree

function delSUBtree(subPath: String): Boolean;
var
  sr: TsearchRec;
  path: String;
begin
  result := FALSE;
  path := myPath + subPath;
  if(subPath='') or (subPath=PathDelim)or(path='') or not directoryExists(path) then
    exit;
  subPath := includeTrailingPathDelimiter(subPath);
  path := includeTrailingPathDelimiter(path);
  if findFirst(path+'*.*', faAnyFile, sr) = 0 then
    repeat
    if (sr.name<>'.') and (sr.name<>'..') then
      if sr.Attr and faDirectory > 0 then
        delSUBtree(subPath+sr.name)
      else
        deleteFile(path+sr.name);
    until findNext(sr) <> 0;
  findClose(sr);
  //path:=ExcludeTrailingPathDelimiter(path);
  result := RemoveDir(path);
end; // deltree

function rosterImgNameFor(c:TRnQContact): AnsiString;
begin
if notinlist.exists(c) then
  result:=status2imgName(byte(SC_UNK), FALSE)
else
//  result:=status2imgName(tstatus(c.status), c.invisible)
  result:= c.fProto.Statuses[c.getStatus].ImageName;
//  Result := c.statusImg;
end; // rosterImgIdxFor

{
function statusDraw(cnv:Tcanvas; x,y:integer; s:Tstatus; inv:boolean=FALSE) : TSize;
begin
  result := theme.drawPic(cnv, x, y, status2imgName(s, inv),
   statusPics[s, inv].tkn, statusPics[s, inv].Loc, statusPics[s, inv].idx)
end;}

function statusDrawExt(const DC: HDC; const x, y: integer; const s: byte;
                       const inv: boolean=FALSE; const ExtSts: Byte = 0): TSize;
begin
 {$IFDEF PROTOCOL_ICQ}
  if XStatusAsMain and (ExtSts > 0) then
    if DC = 0 then
      Result := theme.GetPicSize(RQteDefault, XStatusArray[ExtSts].PicName)
     else
      Result := theme.drawPic(DC, x, y, XStatusArray[ExtSts].PicName)
   else
 {$ENDIF PROTOCOL_ICQ}
    begin
     if statusPics[s, inv].picName = '' then
      begin
       statusPics[s, inv].picName  := status2imgName(s, inv);
       statusPics[s, inv].pEnabled := True;
       statusPics[s, inv].ThemeToken := -1;
       statusPics[s, inv].Element  := RQteDefault;
      end;
     if DC = 0 then
       Result := theme.GetPicSize(statusPics[s, inv])
      else
       result := theme.drawPic(DC, Point(x, y), statusPics[s, inv])
    end;
end;

procedure showAuthreq(c:TRnQcontact; msg:string);
var
  ar:TauthreqFrm;
begin
msg:=dupString(msg);
ar:=findAuthreq(c);
if ar = NIL then
  TauthreqFrm.doAll(RnQmain, c, msg)
else
  begin
  ar.msgBox.text:=msg;
  ar.bringToFront;
  end;
end; // showAuthreq

function countContactsIn(proto : TRnQProtocol; const st: byte):integer;
var
  cl:TRnQCList;
  i:integer;
begin
  result := 0;
  cl := TRnQCList(proto.readList(LT_ROSTER));
  for i:=0 to TList(cl).count-1 do
  if byte(TRnQContact(cl[i]).status) = st then
    inc(result); 
end; // countContactsIn

procedure toggleOnlyOnline;
begin
  roasterLib.setOnlyOnline(not showOnlyOnline);
//  design_fr.prefToggleOnlyOnline;
end;

procedure toggleOnlyImVisibleTo;
begin
  showOnlyImvisibleto:=not showOnlyImvisibleto;
  saveCfgDelayed := True;
  updateHiddenNodes;
end; // toggleOnlyImVisibleto

function setAutomsg(const s:string):string;
begin
  result:=automessages[0];
  automessages[0]:=s;
end; // setAutomsg

function applyVars(c:TRnQcontact; const s : String; fromAM : boolean = false) : String;
var
  h:Tdatetime;
  s1, s2 : String;
begin
  if imAwaySince > 0 then
    h:=(now-imAwaySince)*24
  else
    h:=0;
   result:=template(s, [
    '%awaysince%', formatDatetime(timeformat.automsg, imAwaySince),
    '%awaysince-gmt%', formatDatetime(timeformat.automsg, imAwaySince-GMToffset),
    '%elapsedhours%', intToStr(trunc(h)),
    '%elapsedminutes%', intToStr(trunc(frac(h)*60)),
    '%h%', intToStr(hourof(now)),
    '%m%', intToStr(minuteof(now)),
    '%s%', intToStr(secondof(now)),
    '%D%', intToStr(dayof(now)),
    '%M%', intToStr(monthof(now)),
    '%Y%', intToStr(yearof(now)),
    '%hh%', intToStr(hourof(now),2),
    '%mm%', intToStr(minuteof(now),2),
    '%ss%', intToStr(secondof(now),2),
    '%DD%', intToStr(dayof(now),2),
    '%MM%', intToStr(monthof(now),2),
      {$IFDEF RNQ_PLAYER}
    '%track%', uSimplePlayer.RnQPlayer.getPlayingTitle,
      {$ENDIF RNQ_PLAYER}
    '%onlinecontacts%', intToStr(TList(Account.AccProto.readList(LT_ROSTER)).count -
                          countContactsIn(Account.AccProto, byte(SC_OFFLINE))),
    '%offlinecontacts%', intToStr(countContactsIn(Account.AccProto, byte(SC_OFFLINE))),
    '%events%', intToStr(eventQ.Count)
  //  '%AutoMess%', ifThen(fromAM, '', getAutomsgFor(c))
  ]);
  if Assigned(c) then
    begin
 {$IFDEF PROTOCOL_ICQ}
     if (c is TICQContact) then
       begin
         if TICQContact(c).connection.ip=0 then
           s1 := getTranslation(Str_unk)
          else
           s1 := ip2str(TICQContact(c).connection.ip);
         if TICQContact(c).proto=0 then
           s2 := getTranslation(Str_unk)
          else
           s2 := intToStr(TICQContact(c).proto);
       end
      else
 {$ENDIF PROTOCOL_ICQ}
       begin
        s1 := getTranslation(Str_unk);
        s2 := s1;
       end;
     result:=template(result, [
      '%you%',   c.displayed,
      '%nick%',  c.nick,
      '%first%', c.first,
      '%last%',  c.last,
      '%status%',getTranslation(c.fProto.statuses[c.getStatus].Cptn),
      '%ip%',    s1,
      '%proto%', s2
     ]);
    end
   else
    result:=template(result, [
      '%you%',    '',
      '%nick%',   '',
      '%first%',  '',
      '%last%',   '',
      '%ip%',     getTranslation(Str_unk),
      '%status%', getTranslation(Str_unk), //statusNameExt2(byte(SC_OFFLINE)),
      '%proto%',  getTranslation(Str_unk)])
;
end;

function getAutomsgFor(c: TRnQcontact): string;
begin
  result := applyVars(c, automessages[0], True);
end; // getAutomsg

function getXStatusMsgFor(c: TRnQcontact): string;
begin
//  result := applyVars(c, curXStatusDesc, True);
//  result := applyVars(c, ExtStsStrings[ICQ.curXStatus][1], True);
//  result := applyVars(c, ExtStsStrings[TicqSession(c.fProto).curXStatus], True);
 {$IFDEF PROTOCOL_ICQ}
  if Assigned(c) then
    result := applyVars(c, ExtStsStrings[TicqSession(c.fProto).curXStatus].Desc, True)
   else
    result := applyVars(NIL, ExtStsStrings[TicqSession(Account.AccProto.ProtoElem).curXStatus].Desc, True)
 {$ENDIF PROTOCOL_ICQ}
end; // getAutomsg

procedure check4update;
//var
//  ct : Tcontact;
begin
//  ct.uin := uinToUpdate;
 {$IFDEF PROTOCOL_ICQ}
  if Account.AccProto.ProtoName = 'ICQ' then
  if Account.AccProto.isOnline then
   begin
    TicqSession(Account.AccProto.ProtoElem).sendQueryInfo(uinToUpdate);
    checkupdate.checking := True;
   end
  else
   if not checkupdate.autochecking then
    OnlFeature(Account.AccProto, false);
//  icq.sendSimpleQueryInfo(uinToUpdate);
 {$ENDIF PROTOCOL_ICQ}
end; // check4update

 {$IFDEF PROTOCOL_ICQ}
function CheckUpdates(cnt : TRnQContact) : Boolean;
var
//  ss:Tstrings;
  v,previewv:Longword;
  serial:integer;
  ct : TICQContact;
//  thisVer:string;
  procedure found(v: longword; preview: boolean);
  var
    vs, ps, url: string;
  begin
    if preview then
      url := ct.workpage
     else
      url:= ct.homepage;
  //  ps:=plugins.castEv(PE_UPDATE_INFO, checkupdate.info, ip2str(v), url, preview, v);
  //  if isAbort(ps) then exit;
    vs := IntToStr(v) + ifThen(preview, ' PREVIEW');
    ps := ifThen( PREVIEWversion , CRLF+getTranslation('Your version is a "preview"!'), '');
    if messageDlg( getTranslation('There''s a new version available! version %s%s\nDo you want to download the new version?', [vs,ps]), mtConfirmation,[mbYes,mbNo],0)=mrYes then
      openURL(url)
  end; // found

  procedure nothingFound;
  begin
   if not checkupdate.autochecking then
    msgDlg('No new version available',True, mtInformation);
  end; // nothingFound

begin
  checkupdate.checking := False;
  Result := False;
  if cnt is TICQContact then
    ct := TICQContact(cnt)
   else
    Exit;
  if (error<>0) and not checkupdate.autochecking then
   begin
    msgDlg('Error checking for updates', True, mtError);
    exit;
   end;
  if not matches(ct.nick, 1, 'R&Q versions info') then
    exit;
  checkupdate.last := now;
//thisVer:=ip2str(RnQversion);
 try
  serial := StrToInt64Def(ct.zip, 0);
  v := StrToInt64Def(ct.first, RnQBuild);
  previewv := StrToInt64Def(ct.last, RnQBuild);
  if PREVIEWversion and ((v > RnQBuild) or (previewv > RnQBuild))  then
   begin
     Result := True;
     if MessageDlg(getTranslation('You are running OLD TEST BUILD!\nRun anyway?'), mtWarning, [mbYes, mbNo], 0) <> mrYes then
       openURL(rnqSite)
      else
       begin
        Result := False;
//        if IsEurekaLogActive then
        {$IFDEF EUREKALOG}
         ExceptionLog7.CurrentEurekaLogOptions.EMailSendMode := esmNoSend;
         ExceptionLog7.CurrentEurekaLogOptions.SaveLogFile := False;
        {$ENDIF EUREKALOG}
//        ExceptionLog.CurrentEurekaLogOptions.
//        SetEurekaLogState(False);
       end;
//     msgDlg(getTranslation('StartR&Q: Old Test build'),mtError);
     Exit;
   end;
  

  if (serial > checkupdate.lastSerial) or not checkupdate.autochecking then
    begin
    if ct.about > '' then
      msgDlg(ct.about, True, mtInformation);

//    openURL(checkupdate.ct.);

//    if pos(thisVer, ss.values['deprecated']) > 0 then
//      msgDlg(getTranslation('This version of R&&Q is DEPRECATED\nYou are invited to upgrade as soon as possible'), mtWarning);
//    if pos(thisVer, ss.values['block']) > 0 then
//      msgDlg(getTranslation('This version of R&&Q is BLOCKED\nYou SHOULD NOT use it, cause it has a serious bug\nPlease upgrade as soon as possible'), mtWarning);

    if checkupdate.betas and (previewv > RnQBuild) and (previewv>v) then
     begin
      Result := True;
      found(previewv, TRUE)
     end
    else
      if v > RnQBuild then
        begin
          Result := True;
          found(v, FALSE);
        end
      else
        nothingFound;
//    openURL(ss.values['html-message']);
    end
  else
    nothingFound;
 finally
 end;
 checkupdate.lastSerial:=serial;
// saveCFG;
 saveCfgDelayed := True;
end;
 {$ENDIF PROTOCOL_ICQ}

procedure dockSet;
var
  r: Trect;
begin
  if RnQmain=NIL then
    exit;
  r := RnQmain.boundsrect;
  dockset(r);
  RnQmain.boundsrect := r;
end; // dockSet

procedure dockSet(var r:Trect);
var
  w:integer;
  vOn : Boolean;
begin
  if not RnQmain.visible or not running then
    exit;
  vOn := docking.appBar and docking.active and not docking.tempOff;
  if vOn <> docking.appBarFlag then
   begin
    docking.appbarFlag := vOn;
    RnQSysUtils.dockSet(RnQmain.Handle, vOn, WM_DOCK);
   end;
  if not docking.active then
    exit;
  w := r.right-r.left;
  r := desktopWorkArea(RnQmain.Handle);
  if docking.appBar then
  begin
    r.left:=0;
    r.right := screen.width;
  end;
  if docking.pos=DP_left then
    begin
     dec(r.left,getsystemmetrics(SM_CXFRAME));
     r.right := r.left+w;
    end
   else
    begin
     inc(r.right,getsystemmetrics(SM_CXFRAME));
     r.left := r.right-w;
    end;
  appbarResizeDelayed := TRUE;
end; // dockSet

procedure setAppBarSize;
//var
//  r : TRect;
begin
//  r := RnQmain.boundsrect;
////  r.Right := r.Right + 10;
  RnQSysUtils.setAppBarSize( RnQmain.handle, RnQmain.boundsrect, WM_DOCK, docking.pos=DP_left)
end; // setAppBarSize

procedure fixWindowPos(frm: Tform);
var
  dwa: Trect;
begin
  if frm=NIL then
    exit;
  if not doFixWindows or docking.active or (frm.WindowState<>wsNormal) then
    exit;
  dwa := Screen.DesktopRect;
//  dwa:=desktopWorkArea;
  if fixingWindows.lastWidth <> dwa.right then
   begin
    if fixingWindows.onTheRight then
      frm.left:=dwa.right-fixingWindows.lastRightSpace;
    fixingWindows.lastWidth:=dwa.right;
   end;
  if frm.left < (dwa.left-frm.Width) then
    frm.left := dwa.left-frm.Width+10;
  if frm.top < (dwa.top-frm.Height) then
    frm.top := dwa.top-frm.Height+10;
  if frm.left > dwa.right-10 then
    frm.left := dwa.Right-10;
  if frm.top > dwa.bottom-10 then
    frm.Top := dwa.bottom-10;
  if frm.height > screen.height then
    frm.height := screen.height-20;
  if frm.width > screen.width then
    frm.width := screen.width-20;
  fixingWindows.onTheRight := centerPoint(frm.BoundsRect).x > (screen.Width div 2);
  fixingWindows.lastRightSpace := dwa.right-frm.left;
end; // fixWindowPos

function isSpam(var wrd: String; c: TRnQcontact; msg: string = ''; flags: dword = 0): Boolean;
var
  b, filter: boolean;
  s: string;
  i: Integer;
begin
  if (flags and IF_auth > 0) and spamfilter.ignoreauthNIL and
//     (not roasterLib.exists(c) or notInList.exists(c))
     (notInList.exists(c) or not c.isInRoster) then
  begin
    result:=TRUE;
    exit;
  end;
  if spamfilter.ignoreNIL and //(not roasterLib.exists(c) or notInList.exists(c))
    (notInList.exists(c) or not c.isInRoster)
    or spamfilter.ignorepagers and (IF_pager and flags>0) then
  begin
    result:=TRUE;
    exit;
  end;
  result := FALSE;
  filter := FALSE;
  if spamfilter.uingt>0 then
    if TryStrToInt(c.uid, i) and (i <= spamfilter.uingt) then
      exit
     else
      filter:=TRUE;
  if spamfilter.notnil then
//  if roasterLib.exists(c) then exit
    if c.isInRoster then
      exit
     else
      filter:=TRUE;
  if spamfilter.multisend then
    if flags and IF_multiple = 0 then
      exit
     else
      filter := TRUE;
  if spamfilter.notEmpty then
    if ExistsHistWith(c.uid2cmp) then
      exit
     else
      filter := TRUE;
  if spamfilter.nobadwords then
  begin
    b:=FALSE;
    s:=spamfilter.badwords;
    while not b and (s>'') do
     begin
       wrd := chop(';',s);
       b:=ansiContainsText(msg, wrd);
     end;
    if b then
      filter := TRUE
     else
      begin
        wrd := '';
        filter := False;
    //    exit;
      end;
  end;
  result := filter;
end; // isSpam

function filterRefuse(c: TRnQContact; const msg: string = ''; flags: dword = 0; ev: Thevent = NIL): boolean;
var
  wrd: String;
  spamCnt: TRnQcontact;
begin
  result := TRUE;
  wrd := '';
  if isSpam(wrd, c, msg, flags) then
  begin
   if spamfilter.addToHist then
    if (msg > '')and(Assigned(ev)) then
      begin
//        spamCnt:= contactsDB.get(TICQContact, spamsFilename);
        spamCnt:= contactsDB.Add(c.fProto, spamsFilename);
        writeHistorySafely(ev, spamCnt);
//        if chatFrm.chats.idxOfUIN(spamsFilename) >= 0 then
          chatFrm.addEvent(spamCnt, ev.clone);
      end;

    if spamfilter.warn then
     if wrd > '' then
       msgDlg(getTranslation('SPAM FILTERED FROM %s \n BY WORD %s',
          [c.displayed + ' (' + c.UID + ')', wrd]), False, mtInformation, c.UID)
      else
       msgDlg(getTranslation('SPAM FILTERED FROM %s',[c.displayed + ' (' + c.UID + ')']), False,
             mtInformation, c.UID);
    exit;
  end;
  result:=enableIgnoreList and ignorelist.exists(c);
end; // filterRefuse

function db2strU(db: TRnQCList): RawByteString;
var
 dim: integer;

  procedure addStr(const s: RawByteString);
   var
     i: Integer;
  begin
    if Length(s) > 0 then
    begin
      i := length(result);
      while dim+length(s) > i do
        inc(i, 10000);
      if i > length(result) then
        setLength(result, i);
      system.move(Pointer(s)^, result[dim+1], length(s));
      inc(dim, length(s));
    end;
  end; // addStr
var
  i:integer;
  cnt : TRnQContact;
begin
  result:='';
  dim:=0;
  i:=0;
  while i < TList(db).count do
   begin
    cnt := db.getAt(i);
    if Assigned(cnt) then
      addStr( cnt.GetDBrow);
    inc(i);
   end;
  setLength(result, dim);
end; // db2str

procedure clearDB(db:TRnQCList);
var
  i:integer;
begin
for i:=0 to TList(db).count-1 do
  with db.getAt(i) do
    free;
db.clear;
end; // clearDB

procedure freeDB(var db: TRnQCList);
begin
  if not Assigned(db) then
    Exit;
  clearDB(db);
  db.free;
  db:=NIL;
end; // freeDB

procedure contactCreation(c: TRnQContact);
begin
//  getMem(c.data, sizeof(TCE));
//  new(TCE(c.data));
  c.data := AllocMem(sizeof(TCE));
  fillChar(c.data^, sizeOf(TCE),0);
  TCE(c.data^).toquery:=TRUE;
end;

procedure contactDestroying(c: TRnQContact);
begin
  if Assigned(c.data) then
  begin
{    if assigned(pTCE(c.data).history0) then
     begin
      Thistory(pTCE(c.data).history0).Free;
      pTCE(c.data).history0 := NIL;
     end;}
    if assigned(pTCE(c.data).node) then
     FreeAndNil(pTCE(c.data).node);
    SetLength(TCE(c.data^).notes, 0);
    freeMem(c.data);
  end;
end;

procedure startTimer;
begin
  RnQmain.timer.enabled:=TRUE
end;

procedure stopMainTimer;
begin
  RnQmain.timer.enabled:=FALSE;
//  RnQmain.timer.OnTimer := NIL;
end;

function behave(ev: Thevent; kind:integer=-1{; const info: AnsiString=''}): boolean;
  function IsAnswer(ans : array of string; text : String) : Boolean;
  var
    I: Integer;
  begin
    Result := False;
    if (Length(ans) = 0) then
     Exit;
    for I := Low(ans) to High(ans) do
      if (AnsiStartsText(ans[i], Text)
          or AnsiStartsText('<HTML><BODY>'+ans[i], Text)) then
        begin
          Result := True;
          Exit;
        end;
  end;
  procedure Answers0(var ans : array of string);
  var
    I: Integer;
  begin
     for I := Low(ans) to High(ans) do
       SetLength(ans[i], 0);
//     SetLength(ans, 0);
  end;
const
    SpamBotMsgFlags = IF_not_show_chat or IF_not_save_hist
 {$IFDEF PROTOCOL_ICQ}
           or IF_Simple
 {$ENDIF PROTOCOL_ICQ}
    ;
var
  ok: boolean;
  wnd: TselectCntsFrm;
//  str1:string;
//  spamCnt : Tcontact;
  spmHist : Thistory;
  i,j : Integer;
  ev0 : Thevent;
  s : string;
  fn : string;
  foundInSpam : Boolean;
  vProto : TRnQProtocol;
  vCnt: TRnQContact;
  tipsAllowed : Boolean;
  SkipEvent   : Boolean;
  picsFound : Boolean;
  picsName : TPicName;
  gr : Pgroup;
  dd : TDivisor;
begin
  result:=FALSE;
 {$IFNDEF DB_ENABLED}
//  if info > '' then
//    ev.setInfo(info);
 {$ENDIF ~DB_ENABLED}
  if kind >= 0 then
    ev.kind:=kind;

  case kind of
    EK_GCARD,
    EK_MSG,
    EK_URL: ok:=not filterRefuse(ev.who, ev.getBodyText, 0, ev);
    EK_AUTHREQ: ok:=(not (enableignorelist and ignorelist.exists(ev.who)))and (not filterRefuse(ev.who, '', IF_auth));
   else
     ok := not filterRefuse(ev.who);
  end;

  if not ok then
    exit;

  tipsAllowed := IsCanShowNotifications;

  if Assigned(ev.otherpeer) then
    vCnt := ev.otherpeer
   else
    vCnt := ev.who;

  vProto := vCnt.fProto;

 if (spamfilter.useBotInInvis or (vCnt.imVisibleTo)) and spamfilter.useBot then
  if not (vProto.isInList(LT_ROSTER, vCnt) or
          notInList.exists(vCnt) or
          chatFrm.isChatOpen(vCnt)
          ) then
  begin
   if kind in [EK_typingBeg .. EK_Xstatusreq, EK_oncoming, EK_offgoing,
               EK_auth, EK_authDenied, EK_statuschange] then
    exit
   else
   if (IF_offline and ev.flags > 1) then
   begin

   end
   else
   if kind in [EK_automsgreq, EK_automsg, EK_XstatusMsg, EK_Xstatusreq] then
     begin

     end
   else
   if ((kind = EK_MSG) and (Length(vCnt.antispam.lastQuests) > 0) and
        IsAnswer(vCnt.antispam.lastQuests, ev.getBodyText)
      )  then
    begin
     vCnt.antispam.Tryes := 0;
     Answers0(vCnt.antispam.lastQuests);
     SetLength(vCnt.antispam.lastQuests, 0);

 {$IFNDEF DB_ENABLED}
     try
//       spamCnt := contactsDB.get(spamsFilename);
       spmHist := Thistory.Create;
       fn := Account.ProtoPath + historyPath + spamsFilename;
//       spmHist.fromString(loadFile(fn));
       spmHist.load(vProto.getContact(spamsFilename));
//       chatFrm.closeChatWith(spamCnt);
       foundInSpam := false;
       i := 0;
       while i < spmHist.Count do
       begin
         ev0 := spmHist.getAt(i);
         ev0.expires:=-1;
        if ev0.who.equals(ev.who) then
         begin
          foundInSpam := True;
          // OPENCHAT
          if //not BossMode.isBossKeyOn and
             (BE_openchat in behaviour[ev0.kind].trig)
             and not vProto.getStatusDisable.OpenChat then
            chatFrm.openchat(ev0.who);
          // SAVE  
          if logpref.writehistory and (BE_save in behaviour[ev0.kind].trig) then
           writeHistorySafely(ev0, ev0.who);
          // HISTORY
          if BE_history in behaviour[ev0.kind].trig then
            chatFrm.addEvent(ev0.who, ev0.clone);
          // TRAY
          if (ev0.kind = EK_CONTACTS) and chatFrm.isVisible and (ev0.who=chatFrm.thisChat.who) then
            TselectCntsFrm.doAll2( RnQmain,getTranslation('from %s',[ev0.who.displayed]),
                getTranslation('Add selected contacts'), vProto,
                ev0.cl.clone, RnQmain.addContactsAction, [sco_multi], @wnd)
          else
            if BE_tray in behaviour[ev0.kind].trig then
              eventQ.add(ev0.clone);
          // TIP
          if tipsAllowed and not BossMode.isBossKeyOn
              and (BE_tip in behaviour[ev0.kind].trig) and (ev0.flags and IF_offline=0)
              and not vProto.getStatusDisable.tips then
           try
//             TipAdd(ev0);
             TipAdd3(ev0);
           except
           end;
          spmHist.Delete(i);
         end
         else
          inc(i);
       end;
       if foundInSpam then
         saveFile2(fn, spmHist.toString);
       spmHist.Free;
     except
     end;
 {$ENDIF ~DB_ENABLED}
//     utilLib.deleteFromTo(fn, getAt(st).fpos, getAt(en).fpos+length(getAt(en).toString));
//     history.deleteFromTo(userPath+historyPath + spamCnt.uid, st,en);
     Proto_Outbox_add(OE_msg, vCnt, SpamBotMsgFlags,
                      getTranslation(AntiSpamMsgs[2]))
    end
   else
    begin
      Answers0(ev.who.antispam.lastQuests);
      SetLength(ev.who.antispam.lastQuests, 0);
      if logpref.writehistory and (BE_save in behaviour[ev.kind].trig) then
       writeHistorySafely(ev, contactsDB.Add(vProto, spamsFilename));
      if (BE_HISTORY in behaviour[ev.kind].trig) then
//        if chatFrm.chats.idxOfUIN(spamsFilename) >= 0 then
          chatFrm.addEvent(contactsDB.Add(vProto, spamsFilename), ev.clone);
      if ev.who.antispam.Tryes = spamfilter.BotTryesCount then
       begin
        inc(ev.who.antispam.Tryes);
        Proto_Outbox_add(OE_msg, vCnt, SpamBotMsgFlags,
                   AnsiReplaceStr(getTranslation(AntiSpamMsgs[3]), '%uin%', ev.who.UID));
        exit;
       end
      else
      if vCnt.antispam.Tryes > spamfilter.BotTryesCount then
       exit
      else
       begin
        Randomize;
        if spamfilter.UseBotFromFile and (Length(spamfilter.quests) > 0) then
         begin
           i := RandomRange(0, Length(spamfilter.quests));
//           if i >0 then
           begin
            with spamfilter.quests[i] do
             begin
              Answers0(vCnt.antispam.lastQuests);
              SetLength(vCnt.antispam.lastQuests, length(ans));
              for j := 0 to Length(ans) - 1 do
                vCnt.antispam.lastQuests[j] := ans[j];
              s := q;
             end;
           end
{           else
             begin
               s := '';
               ev.who.antispam.lastQuest := '';
             end;}
         end
         else
          begin
           i := RandomRange(100, 999);
           Answers0(vCnt.antispam.lastQuests);
           SetLength(vCnt.antispam.lastQuests, 1);
           vCnt.antispam.lastQuests[0] := IntToStr(i);
           s := TxtFromInt(i)
          end;
        if Length(vCnt.antispam.lastQuests) > 0 then
         begin
           inc(vCnt.antispam.Tryes);
           if spamfilter.UseBotFromFile and (Length(spamfilter.quests) > 0) then
             Proto_Outbox_add(OE_msg, vCnt, SpamBotMsgFlags,
                        AnsiReplaceStr(getTranslation(AntiSpamMsgs[5]), '%attempt%', IntToStr( spamfilter.BotTryesCount+1-ev.who.antispam.Tryes)) + CRLF+ getTranslation(AntiSpamMsgs[6]) + CRLF + s)
            else
             Proto_Outbox_add(OE_msg, vCnt, SpamBotMsgFlags,
                        AnsiReplaceStr(getTranslation(AntiSpamMsgs[5]), '%attempt%', IntToStr( spamfilter.BotTryesCount+1-ev.who.antispam.Tryes)) + CRLF+ getTranslation(AntiSpamMsgs[4]) + CRLF + s);
           exit;
         end;
       end;
    end;

  end;


// prevent annoying fast oncoming/offgoing sequences
if minOnOff then
  if (ev.kind=EK_ONCOMING) and (now-vCnt.lastTimeSeenOnline < minOnOffTime*DTseconds)
  or (ev.kind=EK_OFFGOING) and (now-TCE(vCnt.data^).lastOncoming < minOnOffTime*DTseconds) then
    exit;

  result:=TRUE;
  if ev.kind in [EK_msg..EK_automsg] then
    TCE(ev.who.data^).lastEventTime:=now;
  if ev.kind in [EK_MSG,EK_URL,EK_CONTACTS,EK_auth,EK_authDenied,EK_AUTHREQ] then
    TCE(vCnt.data^).lastMsgTime := ev.when;

 // SAVE
 if logpref.writehistory and (BE_save in behaviour[ev.kind].trig) then
   writeHistorySafely(ev)
 else
   ev.fpos:=-1;

 SkipEvent := false;
 if DsblEvnt4ClsdGrp and (ev.kind in [EK_oncoming, EK_offgoing, EK_statuschange,
                EK_automsgreq, EK_automsg, EK_typingBeg, EK_typingFin,
                EK_XstatusMsg, EK_Xstatusreq]) then
   begin
//     gr := ev.who.group;
     gr := groups.get(vCnt.group);
     if OnlOfflInOne then
       dd := d_contacts
      else
       dd := d_online;
     SkipEvent := (gr <> NIL) and not gr.expanded[dd];
   end;

  // SOUND
  if not BossMode.isBossKeyOn and (BE_sound in behaviour[ev.kind].trig) and
     not vProto.getStatusDisable.sounds and
     not skipEvent then
   if ev.flags and IF_no_matter = 0 then
     begin
      picsFound := false;
      if UseContactThemes and Assigned(ContactsTheme) then
       begin
         picsName := TPicName(vCnt.UID2cmp) + '.' + event2str[ev.kind];
         picsFound := (ContactsTheme.GetSound(picsName) > '');
         if picsFound then
           ContactsTheme.PlaySound(picsName)
          else
           begin
              begin
               picsName := TPicName('group.') + TPicName(AnsiLowerCase(groups.id2name(vCnt.group))) + '.' + TPicName(event2str[ev.kind]);
               picsFound := (ContactsTheme.GetSound(picsName) > '');
              end;
             if picsFound then
              ContactsTheme.PlaySound(picsName);
           end;
       end;
      if not picsFound then
        theme.PlaySound(event2str[ev.kind]);
     end;

  // TIP
  if tipsAllowed and not BossMode.isBossKeyOn
      and (BE_tip in behaviour[ev.kind].trig) and (ev.flags and IF_offline=0)
      and not vProto.getStatusDisable.tips
      and not SkipEvent then
   if ev.flags and IF_no_matter = 0 then
    try
//      TipAdd(ev);
      TipAdd3(ev);
     except
    end;
 {$IFDEF Use_Baloons}
  if not BossMode.isBossKeyOn and (be_BALLOON in behaviour[ev.kind].trig)
     and (ev.flags and IF_offline=0)
     and not vProto.getStatusDisable.tips
     and not SkipEvent then
   if ev.flags and IF_no_matter = 0 then
      ShowBalloonEv(ev);
 {$ENDIF Use_Baloons}
// TRAY
if (ev.kind = EK_CONTACTS) and chatFrm.isVisible and (ev.who=chatFrm.thisChat.who) then
  TselectCntsFrm.doAll2( RnQmain,getTranslation('from %s',[ev.who.displayed]),
      getTranslation('Add selected contacts'), vProto,
      ev.cl.clone, RnQmain.addContactsAction, [sco_multi], @wnd)
else
  if (BE_tray in behaviour[ev.kind].trig)
     and not SkipEvent then
//   if ev.flags and IF_no_matter = 0 then
    eventQ.add(ev.clone);

// OPENCHAT
  if (BE_openchat in behaviour[ev.kind].trig)
     and not vProto.getStatusDisable.OpenChat then
   if ev.flags and IF_no_matter = 0 then
    if chatFrm.openchat(vCnt, false, True) then
     if not BossMode.isBossKeyOn and (BE_flashchat in behaviour[ev.kind].trig) then
       chatFrm.flash;
  // HISTORY
  if BE_history in behaviour[ev.kind].trig then
    if chatFrm.addEvent(vCnt, ev.clone) then
     if ev.flags and IF_no_matter = 0 then
      if not vProto.getStatusDisable.OpenChat then
       if not BossMode.isBossKeyOn and (BE_flashchat in behaviour[ev.kind].trig) then
          chatFrm.flash;
// POP UP
if not BossMode.isBossKeyOn and (BE_popup in behaviour[ev.kind].trig) then
  if not chatFrm.isVisible then
   if not vProto.getStatusDisable.OpenChat then
    if ev.flags and IF_no_matter = 0 then
     chatFrm.openOn(vCnt, focusOnChatPopup);
  // SHAKE IT BABY!
  if ev.kind = EK_BUZZ then
    if not BossMode.isBossKeyOn and (BE_flashchat in behaviour[ev.kind].trig) then
      if chatFrm.Visible then
        chatFrm.shake;
end; // behave

function beh2str(kind: integer): RawByteString;
var
  s: RawByteString;
begin
  s:='';
  if behaviour[kind].tiptimes then
    s:=s+'times('+IntToStrA(behaviour[kind].tiptimeplus)+')+';
  if BE_tip in behaviour[kind].trig then
    s:=s+'tip('+IntToStrA(behaviour[kind].tiptime)+')+';
  if BE_tray in behaviour[kind].trig then
    s:=s+'tray+';
  if BE_openchat in behaviour[kind].trig then
    s:=s+'openchat+';
  if BE_save in behaviour[kind].trig then
    s:=s+'save+';
  if BE_sound in behaviour[kind].trig then
    s:=s+'sound+';
  if BE_history in behaviour[kind].trig then
    s:=s+'history+';
  if BE_popup in behaviour[kind].trig then
    s:=s+'popup+';
  if BE_flashchat in behaviour[kind].trig then
    s:=s+'flashchat+';
  if BE_balloon in behaviour[kind].trig then
    s:=s+'balloon+';
  delete(s,length(s),1);
  result:=s;
end; // beh2str

procedure str2beh(const b, s : RawByteString);
var
  i : byte;
begin
//    for e:=EK_last downto 1 do
//    for i:=0 to EK_last-1 do
    for i:=1 to EK_last do
      if b = event2str[i]+'-behaviour' then
        behaviour[i]:=str2beh(s)
end;

function str2beh(s: AnsiString): Tbehaviour;
const
  tipstr = AnsiString('tip');

  function extractPar(const lab: AnsiString): AnsiString;
  var
    i,j: integer;
  begin
    result:='';
    i := AnsiPos(lab+'(',s);
    if i > 0 then
     begin
       inc(i,length(lab)+1);
       j:= PosEx(')', s, i);
   //    j:=i;
   //    while (length(s) > j) and (s[j]<>')') do
   //      inc(j);
       if j > 0 then
         result:=copy(s,i,j-i)
        else
         result:=''
     end;
  end; // extractPar
var
  tS : AnsiString;
begin
result.trig:=[];
result.tiptime := 0;
result.tiptimes := false;
result.tiptimeplus := 0;
s := Lowercase(s);
result.tiptimes:=ansiContainsText(s, AnsiString('times'));
  try
    tS := extractPar(AnsiString('times'));
    if tS <>'' then
      result.tiptimeplus:=strToInt(ts)
  except
  end;
  if ansiContainsText(s, tipstr) then
    include(result.trig, BE_tip);
  try
    tS := extractPar(tipstr);
    if tS <>'' then
      result.tiptime:=strToInt(ts)
  except
  end;
if ansiContainsText(s, AnsiString('tray')) then include(result.trig, BE_tray);
if ansiContainsText(s, AnsiString('openchat')) then include(result.trig, BE_openchat);
if ansiContainsText(s, AnsiString('save')) then include(result.trig, BE_save);
if ansiContainsText(s, AnsiString('sound')) then include(result.trig, BE_sound);
if ansiContainsText(s, AnsiString('history')) then include(result.trig, BE_history);
if ansiContainsText(s, AnsiString('popup')) then include(result.trig, BE_popup);
if ansiContainsText(s, AnsiString('flashchat')) then include(result.trig, BE_FLASHCHAT);
if ansiContainsText(s, AnsiString('balloon')) then include(result.trig, BE_BALLOON);

end; // str2beh

//function event2imgidx(e:integer):integer;
function event2imgName(e: integer): TPicName;
begin
case e of
  EK_URL:       result := PIC_URL;
  EK_MSG:       result := PIC_MSG;
  EK_CONTACTS:  result := PIC_CONTACTS;
  EK_ADDEDYOU:  result := PIC_ADDEDYOU;
  EK_AUTHREQ:   result := PIC_AUTH_REQ;
  EK_TYPINGBEG: result := PIC_TYPING;
  EK_TYPINGFIN: result := PIC_TYPING;
  EK_ONCOMING:  result := PIC_ONCOMING;
  EK_OFFGOING:  result := PIC_OFFGOING;
  EK_file:      result := PIC_FILE;
  EK_GCARD:     result := PIC_GCARD;
  EK_BUZZ:      result := PIC_BUZZ;
  else          result := PIC_OTHER_EVENT;
  end;
end; // event2imgidx

procedure hideTaskButtonIfUhave2;
begin
if not menuViaMacro then
  ShowWindow(application.handle,SW_HIDE)
end;

function registerHK(id: integer; hk: word): boolean;
var
  m: integer;
begin
  m:=0;
  if hk and $1000>0 then inc(m, MOD_WIN);
  if hk and $2000>0 then inc(m, MOD_SHIFT);
  if hk and $4000>0 then inc(m, MOD_CONTROL);
  if hk and $8000>0 then inc(m, MOD_ALT);
  result:=RegisterHotKey(RnQmain.handle, id, m, LOBYTE(hk));
end; // registerHK

function updateSWhotkeys: Boolean;
var
  i: integer;
begin
  result:=False;
 if RnQmain = nil then
   Exit;
removeSWhotkeys;
result:=TRUE;
for i:=0 to length(macros)-1 do
  if macros[i].sw then
    result:=registerHK(i, macros[i].hk) and result;
end; // updateSWhotkeys

procedure removeSWhotkeys;
var
  i:integer;
begin
for i:=0 to 200 do
  unregisterHotKey(RnQmain.handle, i);
end; // removeSWhotkeys

{
procedure saveRetrieveQ;
begin
  if fantomWork then Exit;

if retrieveQ.empty then
  deleteFile(userPath+retrieveFileName1)
else
  saveFile(userPath+retrieveFileName1, retrieveQ.toString);
end; // saveRetrieveQ
}

procedure addToignorelist(c:TRnQcontact; const Local_only : Boolean = false);
//var
//  i : Byte;
begin
  if (c=NIL) or ignoreList.exists(c) then
    exit;
  ignoreList.add(c);
  if
  {$IFDEF UseNotSSI}
//    icq.useSSI and
  (not (c.iProto.ProtoElem is TicqSession) or TicqSession(c.iProto.ProtoElem).useSSI) and
 {$ENDIF UseNotSSI}
    not Local_only
  then
//    activeICQ.add2ignore(c);
    c.fProto.AddToList(LT_SPAM, c);
//    activeICQ.SSI_AddVisItem(c.UID, FEEDBAG_CLASS_ID_IGNORE_LIST);
{    for i := Low(prefPages) to High(prefPages) do
     if prefPages[i].Name = 'Ignore list' then
      if Assigned(prefPages[i].frame) then
        TignoreFr(prefPages[i].frame).ignoreBox.addItem(c.displayed,c);
}
  saveListsDelayed:=TRUE;
end; // addToIgnorelist

procedure removeFromIgnorelist(c:TRnQcontact);
//var
//  i : Byte;
begin
  if (c=NIL) or not ignoreList.exists(c) then
    exit;
  ignoreList.remove(c);
 {$IFDEF UseNotSSI}
//  if icq.useSSI then
  if (not (c.iProto.ProtoElem is TicqSession) or TicqSession(c.iProto.ProtoElem).useSSI) then
 {$ENDIF UseNotSSI}
   begin
//    if ICQ.readList(LT_SPAM).exists(c) then
      c.fProto.RemFromList(LT_SPAM, c);
//      ICQ.SSI_DelVisItem(c.UID, FEEDBAG_CLASS_ID_IGNORE_LIST);
   end;

{    for i := Low(prefPages) to High(prefPages) do
     if prefPages[i].Name = 'Ignore list' then
      if Assigned(prefPages[i].frame) then
       with TignoreFr(prefPages[i].frame).ignoreBox do
        items.delete(items.indexOfObject(c));
}
  saveListsDelayed:=TRUE;
end; // removeFromIgnorelist

procedure removeFromRoster(c:TRnQContact; const WithHistory : Boolean = false);
var
  grp:integer;
begin
  if c=NIL then
    exit;
  if c.isInRoster then
    plugins.castEvList( PE_LIST_REMOVE, PL_ROSTER, c);
  grp:=c.group;
  roasterLib.remove(c);
//  c.iProto.removeContact(c);
  if WithHistory then
    DelHistWith(c.UID2cmp);
//    if FileExists(userPath + historyPath + c.UID) then
//     DeleteFile(userPath + historyPath + c.UID);

if (grp>0) and (TRnQCList(c.fProto.readList(LT_ROSTER)).getCount(grp) = 0) then
  if messageDlg(getTranslation('This group (%s) is empty! Do you want to delete it?',[groups.id2name(grp)]),mtConfirmation, [mbYes,mbNo], 0) = mrYes then
    roasterLib.removeGroup(grp);
c.group:=0;
end; // removeFromRoster

procedure realizeEvents(const kind_:integer; c:TRnQcontact);
var
  k : Integer;
  ev0 : Thevent;

begin
  k := -1;
  repeat
    k:=eventQ.getNextEventFor(c, k);
//       if (ev0 = nil) then
//         Break;
//       if ev0.kind in clearEvents then
//       begin
//         if not chatFrm.moveToTimeOrEnd(c, ev0.when) then
//            chatFrm.addEvent(c, ev0.clone);
//       k := eventQ.find(t, c);
    if (k >= 0) and (k < eventQ.count) then
      begin
        ev0 := Thevent(eventQ.items[k]);
        if (kind_ < 0) or (ev0.kind = kind_) then
         begin
          eventQ.removeAt(k);
          realizeEvent(ev0);
         end;
//        if ev0.kind in clearEvents then
//          eventQ.removeAt(k);
//        end
//         eventQ.Remove(ev0);
//       else
        ;
       end;
     until (k<0);
end;

procedure realizeEvent(ev: Thevent);
var
  wnd: TselectCntsFrm;
 {$IFDEF PROTOCOL_ICQ}
  dd : TProtoDirect;
 {$ENDIF PROTOCOL_ICQ}
//  ev0:Thevent;
  vCnt: TRnQContact;
begin
  if not Assigned(ev) then
    Exit;

  if Assigned(ev.otherpeer) then
    vCnt := ev.otherpeer
   else
    vCnt := ev.who;

  roasterLib.redraw(vCnt);
    TipRemove(ev);
  if ev.kind in [EK_ADDEDYOU, EK_AUTHREQ, EK_MSG, EK_GCARD, EK_URL, EK_CONTACTS] then
    NILifNIL(vCnt);
  case ev.kind of
    EK_ADDEDYOU:
      if ev.who.isInList(LT_ROSTER) then
        msgDlg(getTranslation('%s added you to his/her contact list.',[ev.who.displayed]), False, mtInformation)
      else
        if messageDlg(getTranslation('%s added you to his/her contact list.\nDo you want to add him/her to your contact list?',[ev.who.displayed]), mtConfirmation, [mbYes,mbNo], 0) = mrYes then
          addToRoster((ev.who));
    EK_AUTHREQ: showAuthreq((ev.who), ev.getBodyText);
    EK_ONCOMING:
      if showOncomingDlg then
        msgDlg(getTranslation('%s is online', [vCnt.displayed]), False, mtInformation);
    EK_file:
      begin
 {$IFDEF PROTOCOL_ICQ}
        dd := TicqSession(ev.who.fProto).directs.findID(ev.ID);
        if Assigned(dd) then
          receiveFile(dd);
 {$ENDIF PROTOCOL_ICQ}
      end;
    EK_GCARD,
    EK_URL,
    EK_MSG:
      with chatFrm do
        begin
         openOn(vCnt);
//         moveToTimeOrEnd(ev.who, ev.when);

//         ev0:=eventQ.firstEventFor(ev.who);
//         if (ev0 = nil)or(ev = ev0)  then
           begin
//            if not chatFrm.moveToTimeOrEnd(ev.who, ev.when) then
            if not chatFrm.moveToTimeOrEnd(vCnt, ev.when, false) then
              chatFrm.addEvent(vCnt, ev.clone);
           end
//          else
//           begin
//             sdfsdf
//           end;
        end;
    EK_CONTACTS:
      TselectCntsFrm.doAll2( RnQmain,getTranslation('from %s',[ev.who.displayed]),
            getTranslation('Add selected contacts'), ev.who.fProto,
            ev.cl.clone, RnQmain.addContactsAction, [sco_multi,sco_selected], @wnd)
  end;
  try
//    FreeAndNil(ev);
     ev.free;
   except
  end;
end; // realizeEvent

function chopAndRealizeEvent: boolean;
var
  ev: Thevent;
begin
  result := FALSE;
  if eventQ=NIL then
    exit;
  ev := eventQ.pop;
  if not assigned(ev) then
    exit;
  result := TRUE;
  realizeEvent(ev);
  saveInboxDelayed := TRUE;
end; // chopAndRealizeEvent

procedure trayAction;
begin
if not chopAndRealizeEvent then
  if useSingleClickTray or (not RnQmain.visible) then
    RnQmain.toggleVisible
  else
    if not doConnect then
      RnQmain.toggleVisible;
//  doConnect;
end; // trayAction

{function loadNewOrOldVersionContactList(fn:string; altpath:string=''):string;
var
  s:string;
begin
if altpath='' then altpath:=userpath;
//if fileExists(altPath+fn+'.txt') then
//  result:=loadFile(altPath+fn+'.txt')
if fileExists(altPath+fn) then
  result:=loadFile(altPath+fn)
else
  begin
  s:=loadFile(altPath+ ExtractFileName(fn));
  result:='';
  while s>'' do
    begin
    result:=result+copy(s,2, ord(s[1]))+CRLF;
    delete(s, 1, ord(s[1])+1);
    end;
  end;
end; // loadNewOrOldVersionContactList
}

function ints2cl(a: Types.TintegerDynArray): TRnQCList;
var
  i:integer;
begin
  result:=TRnQCList.create;
 {$IFDEF PROTOCOL_ICQ}
  for i:=0 to length(a)-1 do
//    result.add(contactsDB.get(TICQContact, IntToStr(a[i])));
    result.add(contactsDB.get(TICQContact, a[i]));
 {$ENDIF PROTOCOL_ICQ}
end; // ints2cl

function doLock : Boolean;
begin
  Result := False;
  if (AccPass = '') and (Account.AccProto.pwd = '') then
    begin
     msgDlg('No password has been inserted, so you can''t lock.', True, mtInformation);
     Result := True;
    end
   else
    begin
     if not Assigned(lockFrm) then
      begin
        lockFrm := TlockFrm.Create(Application);
        translateWindow(lockFrm);
      end;
     result := (lockFrm.showModal <> mrAbort) and (not locked);
    end;
end; // doLock

{function sendMCIcommand(cmd:PChar):string;
var
  res:array [0..100] of char;
  trash:Thandle;
begin
trash:=0; // shut up compiler
mciSendString(cmd, res, length(res), trash);
result:=res;
end; // sendMCI
{
function statusName(s:Tstatus):string;
begin
  result:=getTranslation(status2str[s])
end;}

function behactionName(a: Tbehaction): string;
begin
  result := getTranslation(behactions2str[a])
end;

function mb(q: extended): string;
begin
  result := floatToStrF(q/(1024*1024),ffFixed,20,1)+getTranslation('Mb')
end;

//function eventName(ev:integer):string;
//begin result:=getTranslation(event2str[ev]) end;

function setRosterAnimation(v: boolean): boolean;
begin
with RnQmain.roster.TreeOptions do
  begin
  result := toAnimatedToggle in animationoptions;
  if v then
    animationoptions := [toAnimatedToggle]
  else
    animationoptions := []
  end;
end; // setRosterAnimation

procedure wallpaperize(canvas: Tcanvas); {$IFDEF HAS_INLINE} inline; {$ENDIF HAS_INLINE}
begin
 if texturizedWindows then
  theme.Draw_wallpaper(canvas.Handle, canvas.ClipRect);
end; // wallpaperize

procedure wallpaperize(DC: THandle; r: TRect); {$IFDEF HAS_INLINE} inline; {$ENDIF HAS_INLINE}
begin
 if texturizedWindows then
  theme.Draw_wallpaper(DC, r);
end; // wallpaperize

procedure applyUserCharset(f: Tfont);
begin
  if userCharset >= 0 then
    f.charset:=usercharset
end;

function getLeadingInMsg(const s: string; ofs: integer=1): string;
var
  i: integer;
begin
  i := 0;
  while (i<length(s)) and (s[i+ofs] in ['>',' ']) do
    inc(i);
  result := copy(s,ofs,i);
end; // getLeadingInMsg

function  fileIncomePath(cnt: TRnQContact): String;
begin
  Result := template(FileSavePath,[
                    '%userpath%', ExcludeTrailingPathDelimiter(AccPath),
                    '%rnqpath%', ExcludeTrailingPathDelimiter(mypath),
                    '%uid%', validFilename(cnt.UID),
                    '%nick%', validFilename(cnt.displayed)
                ]);

end;

procedure applyCommonSettings(c: Tcomponent);
var
  i, i1: integer;
begin
  if not Assigned(c) then
    Exit;
  for i:=c.componentCount-1 downto 0 do
    applyCommonSettings(c.components[i]);
  if c is Tpopupmenu then
  //    if not (Tpopupmenu(c).Items.Items[i] is TRQMenuItem) then
   if c.Name <> 'visMenu' then
   begin
    Tpopupmenu(c).OwnerDraw := True;
    for i := 0 to Tpopupmenu(c).Items.Count-1 do
     if not (Tpopupmenu(c).Items.Items[i] is TRQMenuItem) then
      with Tpopupmenu(c).Items.Items[i] do
      begin
        OnAdvancedDrawItem:=RnQmain.menuDrawitem;
        onMeasureItem:=RnQmain.menuMeasureItem;
  //      onMeasureItem := TRQMenuItem.MeasureItem;
        for i1 := 0 to Tpopupmenu(c).Items.Items[i].Count-1 do
        if not (Tpopupmenu(c).Items.Items[i].Items[i1] is TRQMenuItem) then
         with Tpopupmenu(c).Items.Items[i].Items[i1] do
          begin
           OnAdvancedDrawItem:=RnQmain.menuDrawitem;
           onMeasureItem:=RnQmain.menuMeasureItem;
          end;
      end;
   end;
  if c is TWinControl then
   begin
//   TControl(c).
//   Font.Name := 'Tahoma'; //'Arial';
//   Font.Charset := RUSSIAN_CHARSET;
   end;
   if c is Tcontrol then
    ApplyThemeComponent(Tcontrol(c));
{  if c is TAction then
  begin
    TAction(c).HelpKeyword
  end;}
end; // applyCommonSettings

procedure clearAvailableUsers;
var
  i: Integer;
begin
  for i := 0 to Length(availableUsers)-1 do
   begin
     SetLength(availableUsers[i].name, 0);
//     SetLength(availableUsers[i].uinStr, 0);
     SetLength(availableUsers[i].SubPath, 0);
     SetLength(availableUsers[i].path, 0);
     SetLength(availableUsers[i].uin, 0);
     SetLength(availableUsers[i].Prefix, 0);
   end;
  setlength(availableUsers, 0);
end;

procedure refreshAvailableUsers;
  function getNick_SSI(protoClass: TRnQProtoClass; path: string;
                       var pSSI: Boolean; uid: TUID;
                       var nick: String; var isEncripted: Boolean): Boolean;
      function yesno(const l: String): boolean;
      begin result := LowerCase(l)='yes' end;
  var
    db: TRnQCList;
    ini: TStrings;
    zf: TZipFile;
    s: AnsiString;
    cf: string;
    i: Integer;
//    cnt: TRnQcontact;
    save: Boolean;
  begin
    result := False;
    nick := '';
    save := false;
    isEncripted := False;
    ini := TstringList.create;
    db := nil;
    pSSI := masterUseSSI;
    cf := path+ PathDelim +dbFileName + '5';
    if not FileExists(cf) then
      cf := path+ PathDelim +dbFileName + '4';
    if FileExists(cf) then
      begin
         zf := TZipFile.Create;
         try
           zf.LoadFromFile(cf);
           i := zf.IndexOf('about.txt');
           if i >=0 then
            begin
             isEncripted := zf.IsEncrypted(i);
             Result := True;
             if not isEncripted then
              begin
               ini.Text := zf.data[i];
               s := ini.values['account-name'];
               nick := unUTF( s );
               pSSI := yesno(ini.Values['use-ssi']);
              end;
            end;
           if not Result then
            begin
             i := zf.IndexOf(configFileName);
             if i >=0 then
              begin
               isEncripted := zf.IsEncrypted(i);
               Result := True;
               if not isEncripted then
                begin
                 ini.Text := zf.data[i];
                 s := ini.values['account-name'];
                 nick := unUTF(s);
                 pSSI := yesno(ini.Values['use-ssi']);
                end;
              end;
            end;
{
           if not Result then
            begin
             i := zf.IndexOf(dbFileName);
             if i >=0 then
              begin
               isEncripted := zf.IsEncrypted(i);
               Result := True;
               if not isEncripted then
                begin
                  s := zf.data[i];
                  db := str2db(protoClass._getContactClass, s);
                  cnt := db.get(protoClass._getContactClass, uid);
                  if Assigned(cnt) then
                    nick := cnt.nick;
                  freeDB(db);
                end;
              end;
            end;
}
          except
           s := '';
         end;
         zf.Free;
      end;
    if not result then
     begin
      cf := path+ PathDelim + configFileName;
      if fileExists(cf) then
        begin
          save := True;
          result := True;
          try
            ini.LoadFromFile(cf);
           except
            ini.Clear;
          end;
          nick := UnUTF(ini.values['account-name']);
          pSSI := yesno(ini.Values['use-ssi']);
        end
       else
        begin
          cf := path + PathDelim +OldconfigFileName;
          if fileExists(cf) then
            begin
              Result := True;
              save := True;
              ini.LoadFromFile(cf);
              nick := ini.values['account-name'];
              pSSI := yesno(ini.Values['use-ssi']);
            end
        end;
     end;
    if not result then
     begin
  //     loadDB(path+ PathDelim, db)
        begin
         zf := TZipFile.Create;
         try
           if FileExists(path+ PathDelim +dbFileName + '3') then
             zf.LoadFromFile(path+ PathDelim +dbFileName + '3');
           i := zf.IndexOf(dbFileName);
           if i >=0 then
             s := zf.data[i];
          except
           s := '';
         end;
         zf.Free;
        end;
       if s = '' then
         s := loadFileA(path+ PathDelim +dbFileName);
{
      if s > '' then
       begin
        Result := True;
        db:=str2db(protoClass._getContactClass, s);
        cnt := db.get(protoClass._getContactClass, uid);
        if Assigned(cnt) then
          nick := cnt.nick;
       end;
}
//      if not result then
//        nick := ' ';
      if save then
       begin
        ini.values['account-name']:= StrToUTF8(nick);
  //      ini.Values['use-ssi'] := yesno();
        ini.saveToFile(cf);
       end;
      freeDB(db);
     end;
    ini.free;
  end; // getNick

  procedure addAvailableUser(protoClass: TRnQProtoClass; UID: TUID;
          pPath, pPrefix: string);
  var
    n: integer;
  begin
    n := length(availableUsers);
    setlength(availableUsers, n+1);
//    with availableUsers[n] do
    begin
//      availableUsers[n].uinStr:=extractFileName(pPath);
      with availableUsers[n] do
       begin
//        if copy(uinStr, 1, 4) = AIMprefix then
//         uinStr := copy(uinStr, 5, length(uinStr));
//        uinStr:=extractFileName(pPath);
        SubPath := extractFileName(pPath);
 {$IFNDEF ICQ_ONLY}
        proto := protoClass;
//        if (protoClass <> TicqSession) then
//          uinStr := protoClass._GetProtoName + '_' + uid
//         else
 {$ELSE ICQ_ONLY}
//        uinStr := UID;
        proto := TICQSession;
 {$ENDIF ~ICQ_ONLY}
        uin := UID;
//         uid := uinStr;
         getNick_SSI(protoClass, pPath, SSI, UID, name, encr);
         Prefix := pPrefix;
         path:= ExtractFilePath(pPath);
       end;
    end;
  end; // addAvailableUser

  procedure searchIn(path: string; Prefix : String = '');

  var
//  code:integer;
    sr: TsearchRec;
//   i:integer;
    s: String;
    s2: TUID;
//   prCl : TRnQProtoHelper;
    prCl: TRnQProtoClass;
  begin
  path := includeTrailingPathDelimiter(path);
  ZeroMemory(@sr.FindData, SizeOf(TWin32FindData));
  if FindFirst(path+'*', faDirectory, sr)=0 then
    repeat
    if (sr.Attr and faDirectory > 0) and (sr.name <> '.')and (sr.name <> '..') then
      begin
        s := ExtractFileName(sr.name);
//      val(sr.Name, i, code);
//      if TicqSession.isValidUID(s)
//      if TRnQProtocol(icq).isValidUID(s)
       for prCl in RnQProtos do
        begin
         s2 := s;
//         if prCl._isValidUid(s2)
         if prCl._isProtoUid(s2)
//      if icq.isValidUID(s)
//        or (copy(sr.Name, 1, 4) = 'AIM_')
        then
         begin
          addAvailableUser(prCl, s2, path+sr.name, Prefix);
          break;
         end;
        end;
      end;
    until FindNext(sr) > 0;
  FindClose(sr);
  end;

var
  s: string;
  i, j, n: integer;
  found: Boolean;
  ss: TUID;
//  uid : AnsiString;
begin
  clearAvailableUsers;
  searchIn(myPath);
  if RnQMainPath > '' then
    searchIn(myPath+RnQMainPath);

//  s := getSpecialFolder('AppData')+'R&Q\';
  s := getSpecialFolder(CSIDL_APPDATA)+'R&Q\';
  searchIn(s, 'App\');

  if (cmdLinePar.userPath > '') and not AnsiSameText(cmdLinePar.userPath, usersPath) then
   if LowerCase(s) <> LowerCase(cmdLinePar.userPath) then
     searchIn(cmdLinePar.userPath, 'User\');

  s := usersPath;
  while s>'' do
    searchIn(chop(';',s), 'Users path\');
  if cmdLinePar.startUser > '' then
   begin
    found := false;
    for n := 0 to length(availableUsers) - 1 do
     begin
      ss := cmdLinePar.startUser;
      if availableUsers[n].proto._isProtoUid(ss)
        and (availableUsers[n].uin = ss) then
       found := true;
     end;
    if not found then
     begin
//      fantomWork := True;    // New фича 2007.10.09
 {$IFDEF ICQ_ONLY}
      addAvailableUser(TicqSession, cmdLinePar.startUser, myPath + cmdLinePar.startUser, 'CMD\');
 {$ENDIF ICQ_ONLY}
     end;
   end;

 n := length(availableUsers);
 for i:=0 to n-2 do
  for j:=i+1 to n-1 do
    swap4(availableUsers[i], availableUsers[j], sizeOf(availableUsers[i]),
      availableUsers[i].uin > availableUsers[j].uin );
end; // refreshAvailableUsers


procedure mainfrmHandleUpdate;
var
  b : Boolean;
begin
  b := StyleServices.enabled and DwmCompositionEnabled and (not docking.Docked2chat and RnQmain.Floating);
  if mainDlg.RnQmain.GlassFrame.Enabled <> b then
    mainDlg.RnQmain.GlassFrame.Enabled := b;
  if RnQmain.Handle = RnQmain.oldHandle then
    Exit;
  DragAcceptFiles(RnQmain.oldHandle, FALSE);
  RnQmain.oldHandle := RnQmain.Handle;
// DragAcceptFiles(RnQmain.roster.handle, FALSE);
 DragAcceptFiles(RnQmain.handle, True);
 if Assigned(statusIcon) then
   statusIcon.handleChanged(RnQmain.handle);
// mainDlg.RnQmain.GlassFrame.Enabled := DwmCompositionEnabled and (not docking.Docked2chat and RnQmain.Floating);
 updateSWhotkeys;
end; // mainfrmhandleupdate

procedure reloadCurrentLang();
begin
  ClearLanguage;
  LoadSomeLanguage;
  translateWindows();
end; // reloadCurrentLang

procedure setupChatButtons;
{ weird behaviour of ToolBar component: the autosize property only affects
{ height. So we collect the max height for the buttons we display, and set
{ Toolbar.buttonheight to the right value. Width is instead set for each
{ button }
var
  h:integer;
{
  procedure setupChatButton(newBtn:TspeedButton; pic:Tbitmap); overload;
  begin
    newBtn.glyph := pic;
    newBtn.top:=(chatFrm.panel.clientheight-newBtn.height) div 2;
    if h < pic.height then h:=pic.height;
    newBtn.width:=pic.width+5;
  end; // setupChatButton

//  procedure setupChatButton(newBtn:TspeedButton; pic:String); overload;
//  begin setupChatButton(newbtn, theme.getPic(pic)) end;
}
begin
  if not assigned(chatFrm) then
    exit;
//h:=0;
  chatFrm.sendBtn.Width := 5 + theme.getPicSize(RQteButton, status2imgName(byte(SC_ONLINE))).cx + 5
      + chatFrm.Canvas.TextWidth(chatFrm.sendBtn.Caption) + 5
      + chatFrm.sendBtn.DropDownWidth + 5;
  chatFrm.closeBtn.Width := 5 + theme.getPicSize(RQteButton, PIC_CLOSE).cx + 5
      + chatFrm.Canvas.TextWidth(chatFrm.closeBtn.Caption) + 5
      + chatFrm.closeBtn.DropDownWidth + 5;
  h := theme.getPicSize(RQteDefault, status2imgName(byte(SC_ONLINE)), 16).cy+6;
  if StyleServices.enabled then
    inc(h, 2);
  chatFrm.pagectrl.tabHeight := h;
  chatFrm.closeBtn.left:=chatFrm.SendBtn.boundsrect.right+10;
  chatFrm.closeBtn.top:=chatFrm.SendBtn.top;
// applyCommonSettings(chatFrm);

  chatfrm.toolbar.left := chatFrm.closeBtn.boundsrect.right+10;
  chatFrm.tb0.Width := chatFrm.toolbar.Left-30;
//  chatfrm.toolbar.Height:=18+theme.GetPicSize(PIC_HISTORY).cy;
  chatfrm.panel.Height:=18+theme.getPicSize(RQteButton, PIC_HISTORY, 16).cy;
  h := chatfrm.panel.Height -18;
  with chatFrm.toolbar do
    top:=(chatfrm.panel.ClientHeight-height) div 2;
  chatFrm.toolbar.buttonheight:=h+5;
end; // setupChatButtons

procedure toggleMainfrmBorder(setBrdr : Boolean = false; IsBrdr : Boolean = True);
begin
  with RnQmain do
   if not( setBrdr and( (IsBrdr and (borderstyle <>bsNone)or (not IsBrdr and (borderstyle =bsNone))) ) ) then
   if borderstyle=bsNone then
     begin
//       TopLbl.Visible := False;
       borderStyle:=bsSizeToolWin;
//       BorderWidth := 0;
       showMainBorder := True;
     end
   else
    begin
//     TopLbl.Visible := True;
     borderStyle:=bsNone;
//     borderStyle:=bsSingle;
       showMainBorder := false;
    end;
  mainfrmHandleUpdate;
end; // toggleMainfrmBorder

procedure applySnap();
var
  l: Boolean;
begin
  if Assigned(MainPrefs) then
   begin
    l := MainPrefs.getPrefBoolDef('snap-to-screen-edges', True);
    if Assigned(RnQmain) then
      RnQmain.ScreenSnap := l;
    if Assigned(chatFrm) then
      chatFrm.ScreenSnap := l;
   end;
end;

function unexistant(const uin: TUID): boolean;
begin
result:=not (Account.AccProto.getMyInfo.equals(uin))
    and not Account.AccProto.readList(LT_ROSTER).exists(Account.AccProto, uin)
    and not notInlist.exists(Account.AccProto, uin)
end; // unexistant

function findInAvailableUsers(const uin: TUID): integer;
begin
for result:=0 to length(availableusers)-1 do
  if availableusers[result].uin = uin then
    exit;
result:=-1;
end; // findInAvailableUsers

function isAbort(const pluginReply: AnsiString):boolean;
begin
  result:= (pluginReply>'') and (Byte(pluginReply[1])=PM_ABORT)
end;

procedure drawHint(cnv: Tcanvas; kind: Integer;
                   groupid: integer; c: TRnQcontact;
                   var r: Trect; calcOnly: Boolean = False);
const
  border=5;
  roundsize=16;
  maxWidth = 300;
var
//  n:Tnode;
  maxX,x,y,dy, xdy:integer;

  procedure textout(s:string); overload;
   var
     rr: TRect;
  begin
    if s = '' then
     begin
       xdy := 0;
       exit;
     end;
//   textOut(cnv.handle, x,y, , j);
//    drawText(cnv.handle, PChar(s), -1, R, DT_CALCRECT or DT_SINGLELINE or DT_VCENTER or DT_CENTER);
//   cnv.TextRect(150);
//  rr := r;
  rr.Left := x;
  rr.Top := y;
  rr.Right := maxWidth;
  rr.Bottom := y;// + 100;
  s := dupAmperstand(s);
//  rr.Right := r.Left + 10;
  {$IFDEF DELPHI9_UP}
   cnv.TextRect(rr, s, [tfCalcRect, tfBottom, tfLeft, tfWordBreak, tfEndEllipsis, tfEditControl]);
  {$ENDIF DELPHI9_UP} 
  xdy := rr.Bottom - rr.Top;
//  if rr.Right > maxWidth then
    begin
//      rr.Left := x;
//      rr.Top := y;
//      rr.Right := maxWidth;
//      rr.Bottom := y + 100;
      Inc(rr.Right, 2);
      if calcOnly then
       {$IFDEF DELPHI9_UP}
//        cnv.TextRect(rr, s, [tfBottom, tfLeft, tfWordBreak, tfEndEllipsis, tfEditControl, tfCalcRect])
       {$ENDIF DELPHI9_UP} 
       else
       {$IFDEF DELPHI9_UP}
        cnv.TextRect(rr, s, [tfBottom, tfLeft, tfWordBreak, tfEndEllipsis, tfEditControl]);
       {$ENDIF DELPHI9_UP}
//      xdy := rr.Bottom - rr.Top;
      x:=rr.Right;
    end;
{   else
    begin
      cnv.TextOut(x,y, s);
      x:=cnv.penpos.x;
    end;}
  if x > maxX then
    maxX:=x;
  end; // textout

  procedure textout(const s: string; a: TFontStyles); overload;
  begin
   cnv.Font.Style := a;
   textout(s);
  end; // textout

  procedure fieldOut(const fn, fc: string; needTranslateFC : Boolean = false);
  begin
    textout(fn, []);
    if fc='' then
      textout(getTranslation(Str_unk), [fsItalic])
     else
      if needTranslateFC then
        textout(getTranslation(fc), [fsBold])
       else
        textout(fc, [fsBold]);
    x:=border;
  //  inc(y, dy+2);
    inc(y, xdy+2);
  end; // fieldout
  procedure fieldOutDP(const fn, fc: string; needTranslateFC : Boolean = false);
  begin
    textout(getTranslation(fn) + ': ', []);
    if fc='' then
      textout(getTranslation(Str_unk), [fsItalic])
     else
      if needTranslateFC then
        textout(getTranslation(fc), [fsBold])
       else
        textout(fc, [fsBold]);
    x:=border;
  //  inc(y, dy+2);
    inc(y, xdy+2);
  end; // fieldout

  procedure lineOut(clr:Tcolor);
  begin
    cnv.Pen.color:=clr;
    cnv.moveTo(r.left+15, y);
    cnv.LineTo(r.right-15, y);
  end; // lineout

  procedure rulerOut();
  begin
   inc(y,dy div 2);
   if not calcOnly then
     lineOut(cnv.Pen.Color);
   inc(y,2);
   if not calcOnly then
     lineOut(cnv.Pen.Color);
   inc(y,dy div 2);
  end; // rulerOut

//  procedure picOut(picName:String);
//  begin
//  end; // picOut
//
  function timeToStr(t:Tdatetime):string;
  begin
    if t<1 then
      result:=''
     else
      result:=dateTocoolstr(t)+', '+FormatDateTime('h:nn',t)
  end;

var
  i,
  a, a2, a3: integer;
  cl:TRnQCList;
  ty : Integer;
  pic : TPicName;
 {$IFDEF PROTOCOL_ICQ}
  cnt : TICQcontact;
 {$ENDIF PROTOCOL_ICQ}
 {$IFDEF PROTOCOL_MRA}
//  cnt2 : TMRAcontact;
 {$ENDIF PROTOCOL_MRA}
//  gr : TGPGraphics;
//  region:HRGN;
  tS : String;
begin
  if (kind = NODE_CONTACT) and (c=NIL) then
    exit;
  if (kind = NODE_GROUP) and (groupid < 0) then
    exit;
  if cnv=NIL then
    exit;

//  n:=getNode(node);
 {$IFDEF PROTOCOL_ICQ}
  if c is TICQcontact then
    cnt := TICQContact(c)
   else
    cnt := NIL;;
 {$ENDIF PROTOCOL_ICQ}

  if not calcOnly then
   begin
    cnv.font.Color  := clInfoText;
    cnv.Pen.Color   := theme.GetColor('roaster.hint.border', clInfoText);
    cnv.Brush.Color := theme.GetColor('roaster.hint', clInfoBk);
//    cnv.RoundRect(r.Left,r.top,r.Right,r.bottom, roundsize+1,roundsize+1);
//    cnv.FillRect(r);
    cnv.Rectangle(r);
   end;

  theme.ApplyFont('roaster.hint', cnv.Font);
  dy := cnv.TextHeight('I');

maxX:=0;
x:=border;
y:=roundsize div 2;
case kind of
  NODE_CONTACT:
    begin
     if calcOnly then
       with theme.GetPicSize(RQteDefault, rosterImgNameFor(c)) do
       begin
        inc(x, cx+3);
        ty := cy;
        pic := Protocols_all.Protos_getXstsPic(c, false);
        with theme.GetPicSize(RQteDefault, pic) do
         begin
          inc(x, cx+3);
          ty := max(cy,ty);
         end;
 {$IFDEF PROTOCOL_ICQ}
        if (c is TICQcontact) and (TICQcontact(c).birthFlag) then
          with theme.GetPicSize(RQteDefault, PIC_BIRTH) do
           begin
            inc(x, cx+3);
            ty := max(cy,ty);
           end;
 {$ENDIF PROTOCOL_ICQ}
       end
      else
       with theme.drawpic(cnv.Handle,x,y, rosterImgNameFor(c)) do
       begin
        inc(x, cx+3);
        ty := cy;
        pic := Protocols_all.Protos_getXstsPic(c, false);
        with theme.drawpic(cnv.Handle,x,y, pic) do
         begin
          inc(x, cx+3);
          ty := max(cy,ty);
         end;
 {$IFDEF PROTOCOL_ICQ}
        if (c is TICQcontact) and (TICQcontact(c).birthFlag) then
          with theme.drawpic(cnv.Handle,x,y, PIC_BIRTH) do
           begin
            inc(x, cx+3);
            ty := max(cy,ty);
           end;
 {$ENDIF PROTOCOL_ICQ}
       end;
     ty := Max(ty, 16);
     inc(y, ty-dy);
//     i := y;
     fieldOut(getTranslation('UIN')+'# ', c.uin2Show);
//     if y < i+ty then y := i+ty;
//     if n.contact.xStatusStr > '' then
    if Assigned(c.fProto) and c.fProto.isOnline then
      fieldOutDP('Status', c.getStatusName);

//     if (not XStatusAsMain) and (cnt.xStatus > 0) then
 {$IFDEF PROTOCOL_ICQ}
    if Assigned(cnt) then // ICQ
    begin
     if cnt.xStatusStr > '' then
       begin
         if cnt.xStatusDesc > '' then
           fieldOutDP(Str_message, cnt.xStatusDesc)
          else
           if cnt.ICQ6Status > '' then
             fieldOutDP(Str_message, cnt.ICQ6Status)
       end
      else
         if cnt.xStatusDesc > '' then
          begin
//           if c.isOffline then
//             fieldOutDP(Str_message, cnt.xStatusDesc);
           if cnt.ICQ6Status > '' then
             fieldOutDP(Str_message, cnt.ICQ6Status);
          end;

     if cnt.IdleTime > 0 then
       fieldOutDP('Idle time',
         getTranslation('%d:%.2d',[cnt.IdleTime div 60, cnt.IdleTime mod 60]));
    end;
 {$ENDIF PROTOCOL_ICQ}

 {$IFDEF PROTOCOL_MRA}
    if (c is TMRAcontact) then // MRA
     with TMRAcontact(c) do
      begin
       if (xStatus.id > '') and not ((XStatusAsMain) and (byte(status) = byte(SC_ONLINE))) then
        if xStatus.Name > '' then
          begin
            fieldOutDP('XStatus', xStatus.Name);
           if xStatus.Desc > '' then
             fieldOutDP(Str_message, xStatus.Desc)
          end
         else
          if xStatus.Desc > '' then
            fieldOutDP('XStatus', xStatus.Desc)
         ;
       if xStatus.Name > '' then
           if xStatus.Desc > '' then
             fieldOutDP(Str_message, xStatus.Desc)
      end;
 {$ENDIF PROTOCOL_MRA}

    rulerOut();

    tS := getTranslation('Important')+': ';
 {$IFDEF PROTOCOL_ICQ}
    if Assigned(cnt) then
     if cnt.ssImportant > '' then
       begin
        fieldOut(ts, cnt.ssImportant);
        tS := '';
       end;
 {$ENDIF PROTOCOL_ICQ}
    if c.lclImportant > '' then
      fieldOut(tS, c.lclImportant);

    fieldOutDP('Nick', c.nick);
    fieldOutDP('First name', c.first);
    fieldOutDP('Last name', c.last);
    if c.birthL <> 0 then
     fieldOutDP('Birthday',DateToStr(c.birthL))
    else
     if c.birth <> 0 then
      fieldOutDP('Birthday',DateToStr(c.birth));
    fieldOutDP('Group', groups.id2name(c.group));
 {$IFDEF PROTOCOL_ICQ}
    if Assigned(cnt) then
     begin
        tS := ifThen(cnt.connection.ip<>0,
                ifThen(cnt.connection.ip = TICQcontact(c.fProto.getMyInfo).connection.ip,
                  ip2str(cnt.connection.internal_ip),
                  ip2str(cnt.connection.ip)
                )
              );
        if tS > '' then
         fieldOutDP('IP address', tS);
        if cnt.fServerProto > '' then
         fieldOutDP('Server proto', cnt.fServerProto);
     end;
 {$ENDIF PROTOCOL_ICQ}
    if c.isOnline then
      begin
//       fieldOutDP('Client', getClientFor(c));
       fieldOutDP('Client', c.ClientDesc);
 {$IFDEF PROTOCOL_ICQ}
       if Assigned(cnt) then
          begin
            if cnt.noClient then
              fieldOutDP('Client was closed', timeToStr(cnt.clientClosed));
            fieldOutDP('Online since', timeToStr(cnt.onlinesince));
          end;
 {$ENDIF PROTOCOL_ICQ}
      end
    else
      fieldOutDP('Last time seen online', timeToStr(c.lastTimeSeenOnline));
    if c.isInList(LT_VISIBLE) then
      fieldOut('', 'visible list', True);
    if c.isInList(LT_TEMPVIS) then
      fieldOut('', 'temporary visible list', True);
    if c.isInList(LT_INVISIBLE) then
      fieldOut('', 'invisible list', True);
    if c.isInList(LT_SPAM) or ignoreList.exists(c) then
      fieldOut('', 'ignore list', True);
   {$IFDEF CHECK_INVIS}
    if CheckInvis.CList.exists(c) then
      fieldOut('', 'Check-invisibility list', True);
   {$ENDIF}
    if
     {$IFDEF UseNotSSI}
       Assigned(c) and
//       icq.useSSI and
       (not (c.iProto.ProtoElem is TicqSession) or TicqSession(c.iProto.ProtoElem).useSSI) and
     {$ENDIF UseNotSSI}
       not c.CntIsLocal and not c.Authorized then
      fieldOut('', 'Need authorization', True);
   {$IFDEF RNQ_AVATARS}
 {$IFDEF PROTOCOL_ICQ}
    if Account.AccProto.AvatarsSupport and
       avatarShowInHint then
     if Assigned(c.icon.Bmp) then
       if calcOnly then
         begin
           inc(y, c.icon.Bmp.GetHeight);
           maxX := Max(maxX, c.icon.Bmp.GetWidth + 15);
//         inc(y, cnt.icon.Bmp.GetHeight);
         end
        else
         begin
          DrawRbmp(cnv.Handle, c.icon.Bmp, 10, y);
         end
      else
       if Assigned(cnt) then
        if cnt.ICQIcon.hash > '' then
         fieldOut('', 'Has avatar', True);
 {$ENDIF PROTOCOL_ICQ}
   {$ENDIF RNQ_AVATARS}
    end;
  NODE_GROUP:
    begin
     if calcOnly then
       with theme.GetPicSize(RQteDefault, PIC_CLOSE_GROUP) do
       begin
        inc(x, cx+3);
        inc(y, cy-dy);
       end
     else
       with theme.drawpic(cnv.Handle,x,y, PIC_CLOSE_GROUP) do
       begin
        inc(x, cx+3);
        inc(y, cy-dy);
       end;
    cl:= Account.AccProto.readList(LT_ROSTER);
    fieldOutDP('Total', intToStr(cl.getCount(groupid)));
    if Account.AccProto.isOnline then
     begin
      a:=0;
      a2:=0;
      a3:=0;
      for i:=0 to TList(cl).count-1 do
        with TRnQcontact(cl.getAt(i)) do
          if group = groupid then
            if isOffline then
              inc(a)
            else
             if isOnline then
               inc(a2)
              else
               inc(a3) ;
      fieldOutDP('Online',inttostr(a2));
      fieldOutDP('Offline',inttostr(a));
      fieldOutDP('Unknown',inttostr(a3));
     end;
    end;
  else // Unknown type
    begin
     r:=rect(0,0,0,0);
     exit;
    end;
  end;
//r:=rect(0,0,maxX+ShadowSize+roundsize,y+ShadowSize+roundsize);
r:=rect(0, 0, maxX+ShadowSize + 5, y+ShadowSize);
// cnv.Rectangle(r);
// SetWindowRgn(cnv.Handle, region, TRUE);

// r:=rect(0,0,100,400);
end; // drawHint

function infoToStatus(const info: RawByteString): byte;
begin
 {$IFDEF PROTOCOL_ICQ}
  if length(info) < 4 then
    result:= byte(SC_UNK)
   else
    result:= str2int(info);
if not (result in [byte(SC_ONLINE)..byte(SC_Last)]) then
 {$ENDIF PROTOCOL_ICQ}
  result:= byte(SC_UNK);
//if (result<SC_ONLINE) or (result>SC_UNK) then result:=SC_UNK;
end; // infoToStatus

function infoToXStatus(const info: RawByteString): Byte;
begin
 {$IFDEF PROTOCOL_ICQ}
  if length(info) < 6 then
    result:=0
   else
    result:= byte(info[6]);
  if Result > High(XStatusArray) then
 {$ENDIF PROTOCOL_ICQ}
   result := 0;
end; // infoToXStatus

function exitFromAutoaway():boolean;
begin
  result:=FALSE;
  if autoaway.triggered=TR_none then
    exit;
 {$IFDEF PROTOCOL_ICQ}
  if autoaway.clearXSts and (autoaway.bakxstatus > 0) then
    begin
//     setStatusFull(autoaway.bakstatus, autoaway.bakxstatus, Account.AccProto.xStsStringArray[autoaway.bakxstatus]);
     setStatusFull(Account.AccProto, autoaway.bakstatus, autoaway.bakxstatus, ExtStsStrings[autoaway.bakxstatus]);
//    TicqSession(Account.AccProto.ProtoElem).curXStatus := autoaway.bakxstatus;
//    if Account.AccProto.isOnline then
//      TicqSession(Account.AccProto.ProtoElem).sendStatusCode(false);
//      icq.sendCapabilities;
    end
   else
    setStatus(Account.AccProto, autoaway.bakstatus);
 {$ENDIF PROTOCOL_ICQ}
  setAutomsg(autoaway.bakmsg);
  autoaway.bakmsg:='';
  result:=TRUE;
end; // exitFromAutoaway

function getShiftState():integer;
var
  keys:TkeyboardState;
begin
  result:=0;
  if not GetKeyboardState(keys) then
   exit;
  if keys[VK_SHIFT] >= $80 then
    inc(result, 1);
  if keys[VK_CONTROL] >= $80 then
    inc(result, 2);
  if keys[VK_MENU] >= $80 then
    inc(result, 4);
end; // getShiftState

procedure addTempVisibleFor(time:integer; c:TRnQContact);
begin
// {$IFDEF UseNotSSI}
//  ICQ.addTemporaryVisible(c);
  c.fProto.AddToList(LT_TEMPVIS, c);
  removeTempVisibleTimer:=time;
  removeTempVisibleContact:=c;
//{$ELSE UseSSI}
//  msgDlg(Str_unsupported, mtWarning);
//{$ENDIF UseNotSSI}
end; // addTempVisibleFor

procedure processOevent(oe:Toevent);
begin
case oe.kind of
  OE_MSG: //if sendICQmsg(oe) then exit;
     sendProtoMsg(oe);
  OE_CONTACTS:
    begin
 {$IFDEF PROTOCOL_ICQ}
     sendICQcontacts( oe.whom, oe.flags, oe.cl);
 {$ENDIF PROTOCOL_ICQ}
    end;
  OE_AUTH: Protos_auth( oe.whom );
  OE_AUTHDENIED: Protos_AuthDenied( oe.whom, oe.info );
 {$IFDEF PROTOCOL_ICQ}
  OE_ADDEDYOU: sendICQaddedYou(oe.whom);
 {$ENDIF PROTOCOL_ICQ}
//  OE_file:
  end;
end; // processOevent

function OnlFeature(const pr : TRnQProtocol; check : Boolean = True) : Boolean;
// True if online
begin
  if check and (pr <> NIL) then
    Result := pr.isOnline
   else
    Result := False;
  if not Result then
    msgDlg('You must be online in order to use this feature', True, mtWarning)
end;

 {$IFDEF Use_Baloons}
procedure ShowBalloonEv(ev : Thevent);
var
  counter : Int64;
  s : String;
begin
//  str1:=ev.decrittedInfoOrg;
  //if pos(#13,str1)<>0 then str1:=copy(str1,1,pos(#13,str1)-1);
  counter:=behaviour[ev.kind].TipTime;
//  s := copy(ev.decrittedInfo,1,255);
  s := copy(ev.getBodyText, 1, 255);

  if behaviour[ev.kind].TipTimes then
    counter := counter*length(s)+
               behaviour[ev.kind].TipTimePlus* 100;
  if counter < 100 then
    counter := 100;

  case ev.kind of
  EK_msg, EK_authReq:
    if  (be_BALLOON in behaviour[ev.kind].trig) and (ev.flags and IF_offline=0)
       and not Account.AccProto.getStatusDisable.tips then
          statusIcon.showballoon(counter, s, ev.who.displayed+' '+getTranslation(tipevent2str[ev.kind]), bitinfo);
  EK_offgoing, EK_oncoming, EK_typingFin, EK_typingBeg:
    if  (be_BALLOON in behaviour[ev.kind].trig) and (ev.flags and IF_offline=0)
       and not Account.AccProto.getStatusDisable.tips then
          statusIcon.showballoon(counter, ev.who.displayed, getTranslation(tipevent2str[ev.kind]), bitinfo);
  end;
end;
 {$ENDIF Use_Baloons}

function  CheckAntispam(c : TRnQcontact) : Boolean;
begin
  Result := False;
//  if not (rosterLib.exists(c) or notInList.exists(c)) then
//   if  spam then
end;

procedure CheckBDays;
const
  bds : TPicName = 'birthday';
  PrefIsShowBDFirst  = 'is-show-bd-first';
  PrefShowBDFirst    = 'show-bd-first';
  PrefIsShowBDBefore = 'is-show-bd-before';
  PrefShowBDBefore   = 'show-bd-before';
var
  bPrefIsShowBDFirst,
  bPrefIsShowBDBefore : Boolean;
  iPrefShowBDFirst,
  iPrefShowBDBefore : Integer;
  cl : TRnQCList;
  c : TRnQContact;
  k, l : Integer;
  ss : TPicName;
  played, showInform : Boolean;
begin
// if not Assigned(Account.AccProto) then Exit;
 iPrefShowBDFirst  := 7;
 iPrefShowBDBefore := 3;
 bPrefIsShowBDFirst := MainPrefs.getPrefBoolDef(PrefIsShowBDFirst, True);
 bPrefIsShowBDBefore := MainPrefs.getPrefBoolDef(PrefIsShowBDBefore, True);
 if bPrefIsShowBDFirst then
   MainPrefs.getPrefInt(PrefShowBDFirst, iPrefShowBDFirst);
 if bPrefIsShowBDBefore then
   MainPrefs.getPrefInt(PrefShowBDBefore, iPrefShowBDBefore);
 if not bPrefIsShowBDFirst or not bPrefIsShowBDBefore then
   Exit;

 cl := Account.AccProto.readList(LT_ROSTER).clone;

 try
   if assigned(notInList) then
     cl.add(notInList);
   cl.resetEnumeration;
   while cl.hasMore do
    begin
      c := cl.getNext;
      if c.UID = '' then
       Continue;
      k := c.Days2Bd;
      if (k >= iPrefShowBDFirst)and
         (k >= iPrefShowBDBefore) then
       Continue;
      showInform := false;

      if bPrefIsShowBDBefore and (k < iPrefShowBDBefore) then
        showInform := True;
      if bPrefIsShowBDFirst and not showInform then
       begin
        l := -1;
        if trunc(c.LastBDInform) < trunc(now) then
          begin
            l := trunc(now) - trunc(c.LastBDInform);
          end;
        if l > iPrefShowBDFirst then
         if k < iPrefShowBDFirst then
           begin
             showInform := True;
             c.LastBDInform := now;
           end;
       end;
      if showInform then
       begin
        TipAdd3(NIL, NIL, c);
        if k=0 then // Play sound
         begin
          played := false;
          if UseContactThemes and Assigned(ContactsTheme) then
           begin
            ss := TPicName(c.UID2cmp) + '.' + bds;
            if (ContactsTheme.GetSound(ss) > '') then
              begin
                played := True;
                ContactsTheme.PlaySound(ss)
              end
             else
              begin
                ss := TPicName('group.') + TPicName(AnsiLowerCase(groups.id2name(c.group))) + '.' + bds;
                if (ContactsTheme.GetSound(ss) > '') then
                 begin
                  played := True;
                  ContactsTheme.PlaySound(ss)
                 end;
              end;
           end;
          if not played then
            theme.PlaySound(bds);
         end;
       end;

  {  if not BossMode.isBossKeyOn and (BE_tip in behaviour[ev.kind].trig) and (ev.flags and IF_offline=0)
        and not proto.getStatusDisable.tips then
     if ev.flags and IF_no_matter = 0 then
      try
        TipAdd(ev);
       except
      end;}
    end;
 finally
   cl.Free;
 end;
end;


procedure ClearSpamFilter;
//var
//  q : record q : String; ans : array of String; end;
begin
  spamfilter.badwords := '';
//  for q in spamfilter.quests do

end;

function GetWidth(chk: TCheckBox): integer;
var
  c: TBitmap;
begin
  c := TBitmap.Create;
  try
    c.canvas.Font.Assign(chk.Font);
    result := c.canvas.TextWidth(chk.Caption) + 16;
  finally
    c.Free;
  end;
end;

procedure parseMsgImages(const imgStr: RawByteString; var imgList: TAnsiStringList);
var
  pos1, pos2: integer;
  image: RawByteString;
begin
  if not Assigned(imgList) then
    exit;

  image := imgStr;
  repeat
    pos1 := PosEx(RnQImageTag, image);
    if (pos1 > 0) then
    begin
      pos2 := PosEx(RnQImageUnTag, image, pos1 + length(RnQImageTag));
      imgList.Add(Copy(image, pos1 + length(RnQImageTag), pos2 - (pos1 + length(RnQImageTag))));
      image := Copy(image, pos2 + length(RnQImageUnTag), length(image));
    end
    else
      Break;
  until pos1 <= 0;

  image := imgStr;
  repeat
    pos1 := PosEx(RnQImageExTag, image);
    if (pos1 > 0) then
    begin
      pos2 := PosEx(RnQImageExUnTag, image, pos1 + length(RnQImageExTag));
      imgList.Add(Copy(image, pos1 + length(RnQImageExTag), pos2 - (pos1 + length(RnQImageExTag))));
      image := Copy(image, pos2 + length(RnQImageExUnTag), length(image));
    end
    else
      Break;
  until pos1 <= 0;
end;

procedure CacheType(const url, mime, ctype: RawByteString);
begin
  try
    if not (mime = '') then
      imgCacheInfo.WriteString(url, 'mime', mime)
    else
      imgCacheInfo.WriteString(url, 'mime', ctype);
    imgCacheInfo.UpdateFile;
  except end;
end;

function CheckType(const lnk: String; var sA: RawByteString; var ext: String): Boolean;
var
  idx: Integer;
  ctype: String;
  imgStr, mime, fileIdStr: RawByteString;
  buf: TMemoryStream;
  JSONObject: TJSONObject;
begin
  Result := False;
  if ContainsText(lnk, 'files.icq.net/') then
  begin
    buf := TMemoryStream.Create;
    fileIdStr := ReplaceText(Trim(lnk), 'files.icq.net/get/', 'files.icq.com/getinfo?file_id=');
    fileIdStr := ReplaceText(fileIdStr, 'files.icq.net/files/get?fileId=', 'files.icq.com/getinfo?file_id=');
    LoadFromURL(fileIdStr, buf);
    SetLength(imgStr, buf.Size);
    buf.ReadBuffer(imgStr[1], buf.Size);
    buf.Free;

    JSONObject := TJSONObject.ParseJSONValue(imgStr) as TJSONObject;
    if Assigned(JSONObject) then
    try
      JSONObject := TJSONObject.ParseJSONValue(TJSONArray(JSONObject.GetValue('file_list')).Items[0].ToJSON) as TJSONObject;
      sA := JSONObject.GetValue('dlink').Value + '?no-download=1';
      mime := JSONObject.GetValue('mime').Value;
      JSONObject.Free;
    except end;
  end else
    sA := Trim(lnk);

  ctype := HeaderFromURL(sA);
  CacheType(lnk, mime, ctype);
  if MatchText(mime, ImageContentTypes) or MatchText(ctype, ImageContentTypes) then
  begin
    Result := True;

    idx := IndexText(mime, ImageContentTypes);
    if idx < 0 then
      idx := IndexText(ctype, ImageContentTypes);

    if idx >= 0 then
      ext := ImageExtensions[idx]
    else
      ext := 'jpg';
  end;
end;

function CheckType(const lnk: String): Boolean;
var
  ext: String;
  sA: RawByteString;
begin
  Result := CheckType(lnk, sA, ext);
end;

function CacheImage(var mem: TMemoryStream; url, ext: RawByteString): Boolean;
var
  imgcache, fn: String;
  hash: LongWord;
  winimg: TWICImage;
begin
  Result := False;
  winimg := TWICImage.Create;
  mem.Seek(0, 0);

  try
    winimg.LoadFromStream(mem);
  except
    if Assigned(winimg) then
      winimg.Free;
    Exit;
  end;

  if winimg.Empty then
  begin
    winimg.Free;
    Exit;
  end;

  imgcache := myPath + 'Cache\Images\';
  if not DirectoryExists(imgcache) then
    ForceDirectories(imgcache);

  hash := CalcMurmur2(BytesOf(url));
  fn := imgcache + IntToStr(hash) + '.' + ext;
  winimg.SaveToFile(fn);

  try
    imgCacheInfo.WriteString(url, 'ext', ext);
    imgCacheInfo.WriteString(url, 'hash', IntToStr(hash));
    imgCacheInfo.WriteInteger(url, 'width', winimg.Width);
    imgCacheInfo.WriteInteger(url, 'height', winimg.Height);
    imgCacheInfo.UpdateFile;
  finally
    winimg.Free;
  end;

  Result := True;
end;


INITIALIZATION


  g_hLib_User32 := LoadLibrary('user32.dll');
  if g_hLib_User32 = 0 then
    raise Exception.Create('LoadLibrary(user32.dll) failed');
  @g_pUpdateLayeredWindow := GetProcAddress(g_hLib_User32, 'UpdateLayeredWindow');

 {$IFDEF EUREKALOG}
{
 //   if ExceptionLog7.IsEurekaLogActive then
   ExceptionLog7.CurrentEurekaLogOptions.SupportURL := rnqSite;
//   ExceptionLog.CurrentEurekaLogOptions.SetCustomizedTexts(mtLog_CustInfoHeader, getTranslation('Build %d', [RnQBuild]));
   ExceptionLog7.CurrentEurekaLogOptions.CustomizedTexts[mtLog_CustInfoHeader] := getTranslation('Build %d', [RnQBuild]);
   ExceptionLog7.CurrentEurekaLogOptions.CustomField['Built'] := DateTimeToStr(builtTime);
//   ExceptionLog7.CurrentEurekaLogOptions.CustomizedExpandedTexts[mtLog_CustInfoHeader] := 'Built: '+ DateTimeToStr(builtTime);
}
 {$ENDIF EUREKALOG}

finalization

  g_pUpdateLayeredWindow := NIL;
  if g_hLib_User32 <> 0 then
    FreeLibrary(g_hLib_User32);
  g_hLib_User32 := 0;

end.
