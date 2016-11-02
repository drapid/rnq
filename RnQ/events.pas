{
This file is part of R&Q.
Under same license
}
unit events;
{$I RnQConfig.inc}
{$WARN SYMBOL_PLATFORM OFF}

{$I NoRTTI.inc}

interface

uses
  windows, graphics, classes, extctrls, sysutils,
  RDGlobal, RnQProtocol, RQThemes, RnQStrings;

const
  EK_null         = 00;
  EK_msg          = 01;
  EK_url          = 02;
  EK_contacts     = 03;
  EK_file         = 04;
  EK_authReq      = 05;
  EK_AddedYou     = 06;
  EK_oncoming     = 07;
  EK_offgoing     = 08;
  EK_auth         = 09;
  EK_authDenied   = 10;
  EK_statuschange = 11;
  EK_automsgreq   = 12;
  EK_gcard        = 13;
  EK_automsg      = 14;
  EK_typingBeg    = 15;
  EK_typingFin    = 16;
//  EK_statuschangeExt = 17;
  EK_XstatusMsg   = 17;
  EK_Xstatusreq   = 18;
  EK_BirthDay     = 18;
  EK_buzz         = 19;
  EK_last         = 19;

// adding events remember to initialize supportedBehactions
const
  event2str:array [0..EK_last] of AnsiString=(
    '','msg','url','contacts','file','authreq','addedyou',
    'incoming','outgoing','auth','authdenied','statuschange','automsgreq','gcard','automsg','begtyping', 'fintyping', 'xstatusmsg', 'xstatusreq', 'buzz'
  );
  event2ShowStr:array [0..EK_last] of string=(
    '',Str_message, 'URL', 'Contacts', 'File','Authorization request',
    'Added you', 'Oncoming', 'Offgoing', 'Authorization given',
    'Authorization denied', 'Status changed','Auto-message request',
    'Green-card', 'Auto-message', 'Begin typing', 'Finish typing',
    'XStatus message', 'XStatus request', 'Contact buzzing'
  );
  trayEvent2str:array [0..EK_last] of string=(
    '','message from %s','URL from %s','contacts from %s','file',
    '%s requires authorization','%s added you','%s is online','%s is offline',
    '%s authorized you','%s denied authorization','%s changed status',
    'auto-message requested by %s','greeting card from %s',
    'auto-message for %s','Begun typing', 'Finished typing', '%s changed status',
    'XStatus requested by %s', 'Tried to buzz by %s'
  );
  tipevent2str:array [0..EK_last] of string=(
    '',Str_message,'Sent you an URL','Sent you contacts','Sent you file',
    'Requires authorization','Added you','is online','is offline',
    'Authorized you','Denied authorization','Changed status',
    'Requested your auto-message','Sent you a greeting card',
    'Auto-message','Begun typing', 'Finished typing', 'Changed status',
    'Requested your XStatus', 'Tried to buzz you!'
  );
  tipBirth2str: array[0..2] of string=(
    'Has a birthday!', 'Has a birthday tomorrow!', 'Has a birthday after tomorrow!'
  );
    histHeadPrefix = '%2:s %0:s, %1:s';
    histHeadevent2str:array [0..EK_last] of string=(
    '','','','',' sent file',' Request authorization','',
    ' is online',' is offline',' Authorized',' Denied authorization',' - status %3:s',
    ' requested your auto-message',' Greeting Card',' auto-message', ' begun typing',
    ' finished typing', ' - status %3:s', ' requested your XStatus', '%3:s'
  );
     histBodyEvent2str:array [EK_null..EK_last] of string=(
    '','','','',
    'Filename: %s\nCount: %d\nSize: %s\nMessage: %s', // EK_FILE
    '%s',   // EK_authReq
    'Added you to his/her contact list', // EK_AddedYou
    '','','','%s','','',
    'Watch the greeting card','','', '', '%s', '', ''
  );

  EI_flags=1;
//  EI_shit=3;
  EI_UID = 11;
  EI_WID = 12;

  HI_event=-1;
  HI_hashed=-2;
  HI_cryptMode=-3;

Type
  THeventHeader = record
    prefix: String;
    what: String;
    date: String;
  end;

  Thevent = class
   private
    f_flags    : Integer;
    f_who      : TRnQContact;
   public
 {$IFDEF DB_ENABLED}
    fBin       : RawByteString;
    txt        : String;
 {$ELSE ~DB_ENABLED}
    f_info     : RawByteString;
    fpos: integer;
 {$ENDIF ~DB_ENABLED}

    WID: RawByteString;
    ID : int64;
    kind,
    expires    : integer;  // tenths of second, negative if permanent
    when       : TdateTime;
    fIsMyEvent : Boolean;
    cryptMode  : byte;
    cl         : TRnQCList;
    fImgElm    : TRnQThemedElementDtls;
//   class var
   public
//    themeTkn : Integer;
//    picIdx   : Integer;
//    picLoc   : TPicLocation;
    HistoryToken : Cardinal;
    PaintHeight : Integer;
    otherpeer  : TRnQcontact; // used to keep track of other peer when "who" is us
    class var hisFont : TFont;
    class var myFont  : TFont;
    class var fntToken: Integer;
    class constructor Create;
    class destructor Destroy;

    class function new(kind_: integer; who_: TRnQContact; when_: TdateTime;
             const info_: RawByteString;
 {$IFDEF DB_ENABLED}
             const txt_ : String;
 {$ENDIF DB_ENABLED}
             flags_: integer; pID: integer = 0; GUID: RawByteString = ''): Thevent;
    destructor Destroy; override;
    function  pic: TPicName;
    function  PicSize(const PPI: Integer): TSize;
    function  Draw(DC: HDC; x, y: Integer; const PPI: Integer): TSize;
//    function  GetImgElm : TRnQThemedElementDtls;
//    function  font: Tfont;
    procedure applyFont(font: Tfont);
    function  getFont: Tfont;
//    function  useFont : String;
    function  clone: Thevent;
    function  toString: RawByteString;
    function  urgent: boolean;
    function  isHasBody: Boolean;
 {$IFNDEF DB_ENABLED}
    procedure setInfo(const info_: RawByteString);
    function  decrittedInfo: String;
    function  decrittedInfoOrg: RawByteString;
    procedure appendToHistoryFile(par: TUID='');
 {$ENDIF ~DB_ENABLED}

    procedure writeWID(pID: integer; GUID: RawByteString);

    function  getBodyBin: RawByteString;
    function  getBodyText: string;
    function  getHeaderText: string;
    function  getHeader: THeventHeader;
    procedure ParseMsgStr(const pMsg: RawByteString);
    procedure setFlags(f: integer);
    procedure setWho(w: TRnQContact);
    function  isHis(c: TRnQContact): Boolean;
//   published
    property  flags: Integer read f_flags write setFlags;
    property  who: TRnQContact read f_who write setWho;
    property  isMyEvent: Boolean read fIsMyEvent;
 {$IFNDEF DB_ENABLED}
    property  bInfo: RawByteString read getBodyBin;
 {$ENDIF ~DB_ENABLED}
  end; // Thevent

  TeventQ = class(Tlist)
   public
    OnNewTop: procedure of object;

    constructor Create;
    destructor Destroy; override;
    function  add(kind_: integer; c: TRnQContact; when: Tdatetime; flags_: integer): Thevent; overload;
    procedure add(ev: Thevent); overload;
    function  pop: Thevent;
    function  top: Thevent;
    function  empty: boolean;
    function  chop: boolean;
    function  find(kind_: integer; c: TRnQcontact): integer;
    function  removeAt(i: integer): Boolean;
    function  firstEventFor(c: TRnQContact): Thevent;
    function  getNextEventFor(c: TRnQContact; idx: Integer): Integer;
    function  removeEvent(kind_: integer; c: TRnQContact): boolean; overload;
    function  removeEvent(c: TRnQContact): boolean; overload;
    procedure Clear; override;
    procedure fromString(const Qs: RawByteString);
    function  toString: RawByteString;
    procedure removeExpiringEvents;
    end; // TeventQ

var
  hasMsgOK :  Boolean;
  hasMsgSRV : Boolean;


implementation

uses
  forms, strUtils,
 {$IFDEF UNICODE}
   AnsiStrings,
 {$ENDIF UNICODE}
  RQUtil, RDFileUtil, RDUtils, RnQBinUtils, RnQFileUtil,
  RnQLangs, RnQCrypt, RnQGlobal, RnQPics,
//  prefDlg,
  outboxDlg, utilLib, chatDlg, history,
  themesLib, pluginutil, globalLib, mainDlg,
  Protocols_all,
 {$IFDEF PROTOCOL_ICQ}
  viewinfoDlg, ICQConsts, protocol_ICQ, ICQv9,
 {$ENDIF PROTOCOL_ICQ}
//  Contacts
  roasterLib;

function Thevent.clone: Thevent;
begin
  result := Thevent.create;
  result.ID := ID;
  Result.WID := WID;
  result.kind := kind;
  result.who := who;
  result.otherpeer := otherpeer;
  result.when := when;
  Result.fIsMyEvent := fIsMyEvent;
   {$IFDEF DB_ENABLED}
  result.fBin := fBin;
  result.txt:= txt;
   {$ELSE ~DB_ENABLED}
  result.f_info:= f_info;
  result.fpos := fpos;
   {$ENDIF ~DB_ENABLED}
  result.flags := flags;
  result.cryptMode := cryptMode;
  Result.HistoryToken := 0;
  Result.fImgElm.ThemeToken := -1;
  try
   if cl <> NIL then // By Rapid !
    result.cl:=cl.clone
   else
    result.cl:=NIL;
  except
    result.cl:=NIL
  end;
  result.expires := expires;
end; // clone

destructor Thevent.Destroy;
begin
  if Assigned(cl) then
   cl.free;
 {$IFDEF DB_ENABLED}
  SetLength(fBin, 0);
  SetLength(txt, 0);
 {$ELSE ~DB_ENABLED}
  SetLength(f_info, 0);
 {$ENDIF ~DB_ENABLED}
  inherited;
end;

 {$IFNDEF DB_ENABLED}
procedure Thevent.appendToHistoryFile(par: TUID='');
var
  s: string;
begin
  if par='' then
    par := who.uid;
  s := Account.ProtoPath+historyPath + par;
  fpos := sizeOfFile(s);
  appendFile(s, toString);
end; // appendToHistoryFile
 {$ENDIF ~DB_ENABLED}

procedure Thevent.writeWID(pID: integer; GUID: RawByteString);
begin
 {$IFDEF DB_ENABLED}
 // make update
 {$ENDIF DB_ENABLED}
end;

function Thevent.urgent: boolean;
begin result := flags and IF_urgent > 0 end;

procedure Thevent.applyFont(font: Tfont);
begin
 if fIsMyEvent then
  theme.ApplyFont('history.my', font) //history.myfont
 else
  theme.ApplyFont('history.his', font); //history.hisfont
end;

function Thevent.getFont: Tfont;
begin
 if theme.token <> fntToken then
   begin
     if not Assigned(myFont) then
      myFont := TFont.Create;
     myFont.Assign(Screen.MenuFont);
     theme.ApplyFont('history.my', myFont); //history.myfont
     if not Assigned(hisFont) then
      hisFont := TFont.Create;
     hisFont.Assign(Screen.MenuFont);
     theme.ApplyFont('history.his', hisFont); //history.hisFont
     fntToken := theme.token;
   end;
 if fIsMyEvent then
  result := myFont
 else
  result := hisFont;
end;

function Thevent.pic: TPicName;
begin
 if (kind = EK_msg) then
   begin
    if hasMsgOK and((Self.flags and IF_not_delivered) > 0)then
       Result := PIC_MSG_BAD// + 'ok'
     else
      if hasMsgOK and
//    ((Self.flags and (IF_delivered or IF_not_delivered)) > 0) then
//    if
      ((Self.flags and IF_delivered) > 0) then
       Result := PIC_MSG_OK// + 'ok'
      else
       if hasMsgSRV and ((Self.flags and IF_SERVER_ACCEPT) > 0)then
         Result := PIC_MSG_SERVER// + 'ok'
        else
         Result := PIC_MSG// + 'ok'
   end
  else if kind = EK_buzz then
    Result := PIC_BUZZ
  else
//   if kind = EK_XstatusMsg then
//     result:=
//    else
    result := event2imgName(kind)
end;

function Thevent.PicSize(const PPI: Integer): TSize;
begin
  if fImgElm.ThemeToken <> theme.token then
   begin
    fImgElm.picName := pic;
   end;
  PicSize := theme.GetPicSize(fImgElm, 0, PPI);
end;

function Thevent.Draw(DC: HDC; x, y: Integer; const PPI: Integer): TSize;
begin
  if fImgElm.ThemeToken <> theme.token then
   begin
    fImgElm.picName := pic;
   end;
  Draw := theme.drawPic(dc, Point(x, y), fImgElm, PPI);
end;
{
function Thevent.GetImgElm : TRnQThemedElementDtls;
begin
  if fImgElm.ThemeToken <> theme.token then
   begin
    fImgElm.picName := pic;
   end;
  GetImgElm := fImgElm;
end;}

 {$IFNDEF DB_ENABLED}
function Thevent.decrittedInfo: String;
begin
  case cryptMode of
   CRYPT_SIMPLE: result := unUTF(decritted(f_info, StrToIntDef(who.uid, 0)));
   CRYPT_KEY1: result := unUTF(decritted(f_info, histcrypt.pwdKey));
  end;
//  result := UnWideStr(result);  // By Rapid D!
//  if pos('<RnQImage>', result) <= 0 then
//   Result := unUTF(Result);
end; // decrittedInfo

function Thevent.decrittedInfoOrg: RawByteString;
begin
case cryptMode of
  CRYPT_SIMPLE: result := decritted(f_info, StrToIntDef(who.uid, 0));
  CRYPT_KEY1: result := decritted(f_info, histcrypt.pwdKey);
  end;
end; // decrittedInfo

procedure Thevent.setInfo(const info_: RawByteString);
begin
if histcrypt.enabled then
  begin
  cryptMode := CRYPT_KEY1;
  f_info := critted(info_, histcrypt.pwdKey);
  end
else
  begin
  cryptMode := CRYPT_SIMPLE;
  if who<>NIL then
    f_info := critted(info_, StrToIntDef(who.uid, 0))
   else
    f_info := critted(info_, 0);
  end;
end; // setInfo
 {$ENDIF ~DB_ENABLED}

class constructor Thevent.Create;
begin
  myFont := NIL;
  hisFont := NIL;
  hasMsgOK := False;
  fntToken := -1;
end;

class destructor Thevent.Destroy;
begin
  FreeAndNil(myFont);
  FreeAndNil(hisFont);
end;

class function Thevent.new(kind_: integer;
            who_: TRnQContact; when_: TdateTime;
            const info_: RawByteString;
 {$IFDEF DB_ENABLED}
            const txt_: String;
 {$ENDIF DB_ENABLED}
            flags_: integer; pID: Integer = 0; GUID: RawByteString = ''): Thevent;
begin
  result := Thevent.create;
  result.kind := kind_;
  result.who := who_;
  result.when := when_;
  result.flags := flags_;
  result.expires := -1;
  result.cl := NIL;
  result.ID := pID;
  Result.WID := guID;
 {$IFDEF DB_ENABLED}
  result.fBin := info_;
  result.txt := txt_;
 {$ELSE ~DB_ENABLED}
  result.fpos := -1;
  result.setInfo(info_);
 {$ENDIF ~DB_ENABLED}
  Result.HistoryToken := 0;
  Result.fImgElm.ThemeToken := -1;
end; // new

function Thevent.toString: RawByteString;

  function extraInfo: RawByteString;
  begin
    result := TLV2(EI_flags, int2str(flags));
    if not isOnlyDigits(who.UID) then
//
//    if who.isAIM then
      result:= Result + TLV2(EI_UID, int2str(length(who.UID))+who.UID);
//      result:= Result + TLV2(EI_UID, who.UID);
    if wid > '' then
      result := Result + TLV2(EI_WID, wid);
    result := int2str(length(result))+result;
  end; // extrainfo
 {$IFDEF DB_ENABLED}
var
  sa: RawByteString;
 {$ENDIF DB_ENABLED}
begin
 {$IFDEF DB_ENABLED}
  sa := StrToUTF8(txt);
 {$ENDIF DB_ENABLED}
  result := int2str(HI_event)+AnsiChar(kind)+int2str(StrToIntDef(who.uid, 0))
       +dt2str(when)+extrainfo
 {$IFDEF DB_ENABLED}
       +int2str(length(fBin)) + fBin
       +int2str(length(sa)) + sa
 {$ELSE ~DB_ENABLED}
       +int2str(length(f_info)) + f_info
 {$ENDIF ~DB_ENABLED}
       ;
end; // toString

procedure Thevent.ParseMsgStr(const pMsg: RawByteString);
 {$IFDEF DB_ENABLED}
var
  i, k: Integer;
  msg : RawByteString;
 {$ENDIF DB_ENABLED}
begin
 {$IFDEF DB_ENABLED}
  fBin := '';
  txt  := '';
  msg := pMsg;
      i := Pos(RnQImageTag, msg);
      while i > 0 do
       begin
         k := PosEx(RnQImageUnTag, msg, i+10);
         if k <= 0 then Break;
//         foundPicSize := k-i-10;
//         Result := Result + Copy(sa, i+10, k-i-10);
         fBin := fBin + Copy(msg, i, k-i+11);
         Delete(msg, i, k-i+11);
//         i := PosEx(RnQImageTag, msg, k+11);
         i := PosEx(RnQImageTag, msg, i);
        ;
       end;
      i := pos(RnQImageExTag, msg);
      while i > 0 do
       begin
         k := PosEx(RnQImageExUnTag, msg, i+12);
         if k <= 0 then Break;
//         foundPicSize := k-i-10;
//         Result := Result + Copy(sa, i+12, k-i-12);
         fBin := fBin + Copy(msg, i, k-i+13);
         Delete(msg, i, k-i+13);
//         i := PosEx(RnQImageExTag, msg, k+10);
         i := PosEx(RnQImageExTag, msg, i);
        ;
       end;
  txt := UnUTF(msg);
 {$ELSE ~DB_ENABLED}
  setInfo(pMsg);
 {$ENDIF ~DB_ENABLED}
end;

function Thevent.getHeaderText:string;
var
  dsp : String;
  sa  : RawByteString;
begin
 if not assigned(self) then
  begin
    result := '';
    exit;
  end;
if kind in [EK_ONCOMING, EK_OFFGOING, EK_STATUSCHANGE] then
  begin
//    if (flags and IF_XTended_EVENT)>0 then
 {$IFDEF DB_ENABLED}
    result:= statusNameExt2(infoToStatus(fBin), infoToXStatus(fBin));
 {$ELSE ~DB_ENABLED}
  {$IFDEF PROTOCOL_ICQ}
    result:= statusNameExt2(infoToStatus(f_info), infoToXStatus(f_info));
  {$ELSE ~PROTOCOL_ICQ}
    result:= Proto_StsID2Name(Account.AccProto, infoToStatus(f_info), infoToXStatus(f_info));
  {$ENDIF PROTOCOL_ICQ}
 {$ENDIF ~DB_ENABLED}
  end
else
 if kind = EK_XstatusMsg then
    begin
 {$IFDEF DB_ENABLED}
      sa := copy(fBin, 2, length(fBin));
 {$ELSE ~DB_ENABLED}
      sa := copy(f_info, 2, length(f_info));
 {$ENDIF ~DB_ENABLED}
      if Length(sa) > 4 then
       begin
        if _int_at(sa, 1) > Length(sa) then
          result := ''
         else
          result := UnUTF(_istring_at(sa, 1));
       end
       else
        result := '';
    end
  else
   result:='';
  if Assigned(who) then
  begin
    if (kind = EK_buzz) then
      if isMyEvent then
      begin
        dsp := GetTranslation('You');
        Result := ' ' + GetTranslation('tried to buzz this contact!');
      end
        else
      begin
        dsp := who.displayed;
        Result := ' ' + GetTranslation('tried to buzz you!');
      end
    else
    dsp := who.displayed
  end
   else
    dsp := ''; 
//result:=___('history header '+event2str[kind], [
result := getTranslation(HistHeadPrefix + histheadevent2str[kind], [
  formatDatetime(timeformat.chat, when),
  dsp,
  ifThen(IF_multiple and flags>0, getTranslation('(multi-send)')),
  result
]);
end; // getHeaderText

function Thevent.getHeader: THeventHeader;
var
  dsp, res: String;
  sa: RawByteString;
begin
  if not assigned(self) then
    Exit;

  if kind in [EK_ONCOMING, EK_OFFGOING, EK_STATUSCHANGE] then
  begin
//    if (flags and IF_XTended_EVENT)>0 then
{$IFDEF DB_ENABLED}
    res := statusNameExt2(infoToStatus(fBin), infoToXStatus(fBin));
{$ELSE ~DB_ENABLED}
  {$IFDEF PROTOCOL_ICQ}
    res := statusNameExt2(infoToStatus(f_info), infoToXStatus(f_info));
  {$ELSE ~PROTOCOL_ICQ}
    res := Proto_StsID2Name(Account.AccProto, infoToStatus(f_info), infoToXStatus(f_info));
  {$ENDIF PROTOCOL_ICQ}
{$ENDIF ~DB_ENABLED}
  end
    else
  if kind = EK_XstatusMsg then
  begin
{$IFDEF DB_ENABLED}
    sa := copy(fBin, 2, length(fBin));
{$ELSE ~DB_ENABLED}
    sa := copy(f_info, 2, length(f_info));
{$ENDIF ~DB_ENABLED}
    if Length(sa) > 4 then
    begin
      if _int_at(sa, 1) > Length(sa) then
        res := ''
      else
        res := UnUTF(_istring_at(sa, 1));
    end;
  end;

  if Assigned(who) then
  begin
    if (kind = EK_buzz) then
      if isMyEvent then
      begin
        dsp := GetTranslation('You');
        res := ' ' + GetTranslation('tried to buzz this contact!');
      end
        else
      begin
        dsp := who.displayed;
        res := ' ' + GetTranslation('tried to buzz you!');
      end
    else
      dsp := who.displayed
  end
    else
  dsp := '';

  Result.prefix := ifThen(IF_multiple and flags > 0, getTranslation('(multi-send)'));
  Result.what := dsp + getTranslation(histheadevent2str[kind], [res]);
  Result.date := formatDatetime(timeformat.chat, when)
end; // getHeader

function Thevent.getBodyText: string;
var
  s, s2:string;
  sa : RawByteString;
  i, k : integer;
  size : Int64;
//  ofs : Integer;
begin
result:='';
case kind of
  EK_AUTH,
  EK_GCARD,
  EK_ADDEDYOU: result:=getTranslation(histBodyEvent2str[kind]);
  EK_AUTHREQ,
  EK_AUTHDENIED:
 {$IFDEF DB_ENABLED}
    result:=getTranslation(histBodyEvent2str[kind],[txt]);
 {$ELSE ~DB_ENABLED}
    result:=getTranslation(histBodyEvent2str[kind],[decrittedInfo]);
 {$ENDIF ~DB_ENABLED}
  EK_statuschange : if flags and IF_XTended_EVENT > 0 then
    begin
 {$IFDEF DB_ENABLED}
      result:= txt;
 {$ELSE ~DB_ENABLED}
      if Length(f_info) > 6+4 then
        result:= unUTF(copy(f_info, 11, length(f_info)))
       else
        result := '';
 {$ENDIF ~DB_ENABLED}
    end;
  EK_XstatusMsg:
    begin
 {$IFDEF DB_ENABLED}
      result:= txt;
 {$ELSE ~DB_ENABLED}
      if length(f_info) > 1+4 then
        begin
          i := _int_at(f_info, 2) + 1 + 4 + 1;
          if (i > 0) and (length(f_info) > i+4) then
           begin
             k := _int_at(f_info, i);
             result := unUTF(copy(f_info, i+4, k));
           end;
        end;
 {$ENDIF ~DB_ENABLED}
    end;
  EK_AUTOMSG:
    begin
 {$IFDEF DB_ENABLED}
      result:= txt;
 {$ELSE ~DB_ENABLED}
//      result:= decrittedInfoOrg;
//    result := UTF8ToStrSmart(result);
//      delete(result,1,1);
      result := unUTF(copy(decrittedInfoOrg, 2, length(f_info)));
 {$ENDIF ~DB_ENABLED}
    end;
  EK_FILE:
    begin
 {$IFDEF DB_ENABLED}
      sa := fBin;
 {$ELSE ~DB_ENABLED}
      sa := decrittedInfoOrg;
 {$ENDIF ~DB_ENABLED}
      s  := unUTF(getTLVSafe(1, sa)); // fileName;
      s2 := unUTF(getTLVSafe(4, sa)); // Message
      if s > '' then
        begin
         i := getTLVdwordBE(2, sa);// Count
         size := getTLVqwordBE(3, sa);// Size
        end
       else
        begin i := 0; size := 0; end;
      result := getTranslation(histBodyEvent2str[kind],[s, i, size2str(size), s2]);
      if existsTLV(5, sa) then
        Result := Result +CRLF+ 'IP: '+ ip2str(getTLVdwordBE(5, sa));
      if existsTLV(6, sa) then
        Result := Result +CRLF+getTranslation('Internal IP')+ ': '+ ip2str(getTLVdwordBE(6, sa));
    end;
  EK_CONTACTS:
    begin
 {$IFDEF DB_ENABLED}
    sa := fBin;
 {$ELSE ~DB_ENABLED}
    sa := decrittedInfoOrg;
 {$ENDIF ~DB_ENABLED}
    // backward compatibility (converts old format)
    i := length(sa);
    if i>30 then i:=30;
    while (i>0) and (sa[i]<>#2) do dec(i);
    if i <= 0 then
      begin
        Result := sa;
        exit;
      end;
//    s:=sa; result:='';
    while sa > '' do
     begin
      chop(#2,sa);
      result := result + chop(', ',sa)+CRLF;
     end;
    end;
  EK_URL:
 {$IFDEF DB_ENABLED}
    result := txt;
 {$ELSE ~DB_ENABLED}
    result := decrittedInfo;
 {$ENDIF ~DB_ENABLED}
  EK_MSG:
    begin
 {$IFDEF DB_ENABLED}
      Result := txt;
 {$ELSE ~DB_ENABLED}
      sa := decrittedInfoOrg;
          i := AnsiPos(RnQImageExTag, sa);
          while i > 0 do
           begin
             k := PosEx(RnQImageExUnTag, sa, i+12);
             if k <= 0 then Break;
             Delete(sa, i, k-i+13);
             i := PosEx(RnQImageExTag, sa, i);
            ;
           end;
      if (f_flags and IF_CODEPAGE_MASK) = IF_UTF8_TEXT then
        Result := UTF8ToStr(sa)
       else
        begin
          i := AnsiPos(RnQImageTag, sa);
          while i > 0 do
           begin
             k := PosEx(RnQImageUnTag, sa, i+10);
             if k <= 0 then Break;
             Delete(sa, i, k-i+11);
             i := PosEx(RnQImageTag, sa, i);
            ;
           end;
          Result := UnUTF(sa);
        end;
 {$ENDIF ~DB_ENABLED}
    end;
  end;
//  if pos('<RnQImage>', result) <= 0 then
    convertAllNewlinesToCRLF(result);
end; // getBodyText

 {$IFDEF DB_ENABLED}
function Thevent.getBodyBin: RawByteString;
var
  sa: RawByteString;
  i, k//, foundPicSize
    : Integer;
begin
  if kind in [EK_oncoming, EK_statuschange, EK_AUTOMSG, EK_XstatusMsg, EK_MSG] then
    Result := fBin
   else
    result := '';
end;
 {$ELSE ~DB_ENABLED}
function Thevent.getBodyBin: RawByteString;
var
  sa: RawByteString;
  i, k//, foundPicSize
    : Integer;
begin
result:='';
case kind of
  EK_oncoming,
  EK_statuschange : //if flags and IF_XTended_EVENT > 0 then
    begin
      result:=copy(f_info, 1, 6);
    end;
  EK_AUTOMSG:
    begin
      result:=copy(decrittedInfoOrg, 1, 1);
//    result := UTF8ToStrSmart(result);
    end;
  EK_XstatusMsg:
    begin
      result:= copy(f_info, 1, 1);
    end;
  EK_MSG:
    begin
//      sa:=decrittedInfoAnsi;
      sa:=decrittedInfoOrg;
      i := Pos(RnQImageTag, sa);
      while i > 0 do
       begin
         k := PosEx(RnQImageUnTag, sa, i+10);
         if k <= 0 then Break;
//         foundPicSize := k-i-10;
//         Result := Result + Copy(sa, i+10, k-i-10);
         Result := Result + Copy(sa, i, k-i+11);
         i := PosEx(RnQImageTag, sa, k+11);
        ;
       end;
      i := pos(RnQImageExTag, sa);
      while i > 0 do
       begin
         k := PosEx(RnQImageExUnTag, sa, i+12);
         if k <= 0 then Break;
//         foundPicSize := k-i-10;
//         Result := Result + Copy(sa, i+12, k-i-12);
         Result := Result + Copy(sa, i, k-i+13);
         i := PosEx(RnQImageExTag, sa, k+10);
        ;
       end;
    end;
  end;
end;
 {$ENDIF ~DB_ENABLED}

function  Thevent.isHasBody: Boolean;
begin
case kind of
  EK_AUTH,
  EK_GCARD,
  EK_ADDEDYOU,
  EK_AUTHREQ,
  EK_AUTHDENIED: result:=True;
  EK_statuschange : Result := flags and IF_XTended_EVENT > 0;
  EK_AUTOMSG,
  EK_XstatusMsg,
  EK_CONTACTS,
 {$IFDEF DB_ENABLED}
  EK_FILE:
    begin
      result:= Length(fBin) > 0;
    end;
  EK_URL,
  EK_MSG:
    begin
      result:= (Length(txt) > 0)or (Length(fBin) > 10);
    end;
 {$ELSE ~DB_ENABLED}
  EK_FILE,
  EK_URL,
  EK_MSG:
    begin
      result:= Length(f_info) > 0;
    end;
 {$ENDIF ~DB_ENABLED}
   else
    result:=false;
  end;
end;

procedure Thevent.setFlags(f: integer);
begin
  f_flags := f;
  fImgElm.ThemeToken := -1;
  fImgElm.Element := RQteDefault;
  fImgElm.pEnabled := True;
end;

procedure Thevent.setWho(w: TRnQContact);
begin
  f_Who := w;

 {$IFNDEF DB_ENABLED}
  fIsMyEvent := (not Assigned(f_Who)) or f_Who.fProto.isMyAcc(w);
 {$ENDIF DB_ENABLED}
end;

function Thevent.isHis(c: TRnQContact): Boolean;
begin
  if Assigned(c) then
    if Assigned(otherpeer) then
      Result := c.equals(otherpeer)
     else
      Result := c.equals(who)
end;

//////////////////////////////////////////////////////////////

constructor TeventQ.create;
begin
  inherited create;
  blinking := TRUE;
end; // create

function TeventQ.find(kind_: integer; c: TRnQcontact): integer;
begin
  result := count;
  while result > 0 do
    begin
    dec(result);
    with Thevent(items[result]) do
      if (kind = kind_) and isHis(c) then
        exit;
    end;
  result := -1;
end; // find

procedure TeventQ.add(ev: Thevent);
//var
//  i: integer;
begin
  if sortBy = SB_event then
    roasterLib.sort(ev.who);
// contacts and authreq requires distint windows for each event
{if ev.kind in [EK_contacts,EK_auth] then
  i:=-1
else
  i:=find(ev.kind, ev.who);

//if (i >= 0) and (not ev.urgent or Thevent(items[i]).urgent) then
//  ev.free
//else
}
  begin
//  if ev.flags and IF_urgent > 0 then
//    insert(0, ev)
//  else
    inherited add(ev);
  if ev.kind in [EK_oncoming, EK_offgoing] then
    ev.expires:=tempBlinkTime;        // tenth of second
  if count = 1 then
    if assigned(OnNewTop) then
      OnNewTop;
  saveInboxDelayed:=TRUE;
  end;
end; // add

function TeventQ.add(kind_: integer; c: TRnQContact; when: Tdatetime; flags_: integer): Thevent;
begin
  result := Thevent.create;
  result.kind := kind_;
  result.who := c;
  result.when := when;
  result.flags := flags_;
  add(result);
end; // add

function TeventQ.pop: Thevent;
begin
  result := top;
  removeAt(0);
end; // pop

function TeventQ.top: Thevent;
begin
  if count=0 then
    result := NIL
   else
    result := first
end;

procedure TeventQ.clear;
begin
  while count > 0 do
    pop.free;
end; // clear

destructor TeventQ.Destroy;
begin
  clear;
  inherited;
end; // destroy

function TeventQ.empty: boolean;
begin result := count=0 end;

function TeventQ.chop: boolean;
begin
  result := FALSE;
  if not empty then
    begin
    pop.free;
    result := TRUE;
    end;
end; // chop

function TeventQ.removeAt(i: integer): boolean;
var
  c, c2: TRnQcontact;
begin
  result := (i >= 0) and (i < count);
  if result then
   begin
    c := Thevent(items[i]).who;
    c2 := Thevent(items[i]).otherpeer;
    delete(i);
    if i=0 then
      if assigned(OnNewTop) then
        OnNewTop;
    if Assigned(c2) and (c2 <> c) then
      roasterLib.redraw(c2);
    roasterLib.redraw(c);
   end;
end; // removeAt

function TeventQ.firstEventFor(c: TRnQContact): Thevent;
var
  i: integer;
begin
  i := 0;
  if Assigned(c) and (c is TRnQContact) then
//result := NIL;
  while i < count do
    begin
     try
      result := Thevent(items[i]);
      if Result.isHis(c) then
        Exit;
     except
       result := NIL;
       // May be need to remove bad item
     end;
    inc(i);
    end;
  result := NIL;
end; // firstEventFor

function TeventQ.getNextEventFor(c: TRnQContact; idx: Integer): Integer;
var
  i: integer;
begin
  if idx >= 0 then
    i:=idx
   else
    i := 0;
  if Assigned(c) and (c is TRnQcontact) then
//result := NIL;
  while i < count do
    begin
     try
      result := i;
      if Thevent(items[i]).isHis(c) then
       exit;
     except
       result := -1;
       exit;
     end;
    inc(i);
    end;
  result:=-1;
end; // firstEventFor

function TeventQ.removeEvent(kind_: integer; c: TRnQContact): boolean;
var
  i: Integer;
begin
  Result := false;
  repeat
    i := find(kind_, c);
    if i >= 0 then
     result := removeAt(i);
  until (i < 0);
end;

function TeventQ.removeEvent(c: TRnQContact): boolean;
var
  i: integer;
begin
  result := FALSE;
  i := count;
  while i > 0 do
    begin
     dec(i);
     if Thevent(items[i]).isHis(c) then
      begin
       result:=TRUE;
       removeAt(i)
      end
    end;
end; // removeEvent

const
  FK_KIND    = 00;
  FK_EXPIRES = 01;
  FK_WHO     = 02;
  FK_CL      = 03;
  FK_WHEN    = 04;
//  FK_URGENT  = 05;  OBSOLETE
  FK_INFO    = 06;
  FK_FLAGS   = 07;

  FK_WHO_STR = 12;
  FK_TXT     = 16; // UTF8 text

procedure TeventQ.fromString(const Qs: RawByteString);
var
  t, l: integer;
  e: Thevent;
  uin: Integer;
  s: RawByteString;
  ofs: Integer;
begin
  roasterLib.building := True;
  ofs := 1;
  try
    clear;
    e:=NIL;
    while length(Qs) >= 8+ofs do
     begin
      t:=integer((@Qs[ofs])^); // 1234
      inc(ofs, 4);
      l:=integer((@Qs[ofs])^); // 5678
      inc(ofs, 4);

      if not within(0,l,1000000)
       or not within(0,t,100)
       or (length(Qs)-ofs < 8+l) then break; // corrupted file

      s := Copy(Qs, ofs, l);
      inc(ofs, l);
      case t of
        FK_KIND: begin
                if Assigned(e) then
                 try
                   if Not Assigned(e.who) then
                    begin
                     Remove(e);
                     e.Free;
                     e := NIL;
                    end;
                  except
                 end;
                e:=add(integer((@s[1])^), Account.AccProto.getmyInfo, 0, 0);
             end;
        FK_EXPIRES: e.expires:=integer((@s[1])^);
        FK_WHO:
      begin
        uin := integer((@s[1])^);
        if uin > 0 then
          e.who:= Account.AccProto.getContact(IntToStr(uin))
         else
          e.who:= NIL;
      if Assigned(e.who) then
             NILifNIL(e.who, True)
        else
         e.who:= Account.AccProto.getMyInfo;
      end;
        FK_WHO_STR:
      begin
        e.who := Account.AccProto.getContact(s);
        if Assigned(e.who) then
              NILifNIL(e.who, True)
         else
          e.who:= Account.AccProto.getMyInfo;
      end;
        FK_WHEN: e.when := Tdatetime((@s[1])^);
        FK_FLAGS: e.flags := integer((@s[1])^);
     {$IFDEF DB_ENABLED}
        FK_INFO: e.fBin:= s;
        FK_TXT:  e.txt:= utf8tostr(s);
     {$ELSE ~DB_ENABLED}
        FK_INFO: e.f_info:= s;
     {$ENDIF ~DB_ENABLED}
        FK_CL:
          if l > 0 then
           begin
            e.cl := TRnQCList.create;
            e.cl.fromString(Account.AccProto, s, Account.AccProto.contactsDB );
           end;
    end;//case
     end;
   finally
    roasterLib.building := False;
    roasterLib.rebuild;
    saveListsDelayed := True; // If we added to NIL, then it would be need!
  end;
end; // fromString

function TeventQ.toString: RawByteString;
var
  i: integer;
  s: RawByteString;
begin
  result := '';
  i := 0;
while i < count do
  with Thevent(items[i]) do
    begin
     try
      s:=TLV2(FK_KIND, int2str(kind))
        +TLV2(FK_EXPIRES, int2str(expires))
        +TLV2(FK_WHO, int2str(StrToIntDef(who.uid, 0)))
        +TLV2(FK_WHEN, dt2str(when))
        +TLV2(FK_FLAGS, int2str(flags))
 {$IFDEF DB_ENABLED}
        +TLV2(FK_INFO, fBin)
        +TLV2(FK_TXT, StrToUTF8(txt));
 {$ELSE ~DB_ENABLED}
        +TLV2(FK_INFO, f_info);
 {$ENDIF ~DB_ENABLED}
      if assigned(cl) then s:=s+TLV2(FK_cl, cl.toString);
      if StrToIntDef(who.uid, 0) = 0 then
        s := s+ TLV2(FK_WHO_STR, who.uid);

      result:=result+s;
     except
      s := '';
     end;
    inc(i);
    end;
end; // toString

procedure TeventQ.removeExpiringEvents;
var
  i: integer;
begin
  i := 0;
  while i < count do
    if Thevent(items[i]).expires >= 0 then
      removeAt(i)
    else
      inc(i);
end; // removeExpiringEvents


end.
