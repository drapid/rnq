{
This file is part of R&Q.
Under same license
}
unit XMPPcontacts;
{$I RnQConfig.inc}
{$I NoRTTI.inc}


interface

uses
  classes, sysutils, types,
    RnQGraphics32,
  RDGlobal, RnQProtocol;

type
  TXMPPstatus = (SC_ONLINE = 0, SC_OFFLINE, SC_UNK,
               mSC_AWAY=3, mSC_DND, mSC_XA, mSC_CHAT);
//  Tmras = Tstatus + TMRAstatus;
const
  StatusPriority: array[TXMPPstatus] of byte= (0,8,9, 1, 2, 3,4);
//  statMenu: array[0..6] of TMRAStatus = (mSC_ONLINE, mSC_F4C, mSC_OCCUPIED, mSC_DND,
//           mSC_AWAY, mSC_NA, mSC_OFFLINE);
const
  IS_AVATAR = 0;
  IS_PHOTO  = 1;
  IS_NONE   = 2;

type
  TXMP_RESRC = record
    resID: String;
    priority: integer;
    status, prevStatus: TXMPPstatus;
    xStatus: record
//         id: AnsiString;
//         Name,
         Desc: String;
       end;
    ClientID: String;
    caps_hash: String;
    caps: array of string;
  end;

type
  TxmppContact = class(TRnQContact)
   public
    invisible: boolean;
    gender: Byte;
    resources: array of TXMP_RESRC;
    defRes: Int8;
    f_offline_sts: TXMPPstatus;
//    ssPhones: AnsiString;
{
    ssCells: AnsiString;
    City_id: Integer;
//    Location: String;
    Country_id: Integer;
    Location_id: Integer;
    zodiac: byte;
    hisPhones: AnsiString;}
    AuthorizedHim: Boolean;
//    Authorized: Boolean;
//    onlineSince:
    infoUpdatedTo: TDateTime;
    XIcon: record
//       Hash_safe: RawByteString;
       Hash: RawByteString;
      end;
   public
    constructor Create(pProto: TRnQProtocol; const uin_: TUID); override; final;
    destructor Destroy; override; final;
//     class operator Implicit(const a: AnsiString) : TContact; inline;// Implicit conversion of an Integer to type TMyClass
    procedure clear; override;
    procedure setOffline;
    procedure OfflineClear;
    function  isOnline: Boolean; override; final;
    function  isInvisible: Boolean; override; final;
    function  isOffline: Boolean; override; final;
    function  canEdit: Boolean; override; final;
    function  getStatusName: String; OverLoad; OverRide; final;
    function  statusImg: TPicName; OverRide; final;
    function  getStatus: byte; OverRide; final;
    procedure SetDisplay(const s: String); OverRide; final;
    function  uin2Show: string; OverRide; final;
    function  GetDBrow: RawByteString; OverRide; final;
    function  ParseDBrow(ItemType: Integer; const item: RawByteString): Boolean; OverRide; final;
    procedure ViewInfo; OverRide; final;
    class procedure UID2DomUser(const uid: TUID; var d, u: TUID);
    class function trimUID(const uid: TUID): TUID; OverRide; final;
    class function GetRes(const uid: TUID): TUID;
    function  AddRes(const uid: TUID): Int8;
    function  GetResUID(resnum: Int8): TUID;
    function  findDefRes: Int8;
    procedure GetDomUser(var d, u: TUID);
    function  getStatusS: TXMPPstatus;
    procedure SetStatus(st: TXMPPstatus; res: Integer = -1);
    property status: TXMPPstatus read getStatusS;
   end; // Tcontact


  Txmpp_cnt_res = record
    cnt: TxmppContact;
    resNum: Int8;
  end;
  procedure XMPPCL_setStatus(cl: TRnQCList; st: TXMPPStatus);

IMPLEMENTATION

uses
  RnQLangs, RnQConst, globalLib, mainDlg,
  utilLib, RQUtil, StrUtils,
    RnQBinUtils, RDUtils,
 {$IFDEF UNICODE}
   AnsiStrings,
 {$ENDIF UNICODE}
   viewXMPPinfoDlg,
    XMPP_proto, XMPPv1;
//    mra_Proto, Protocol_MRA, MRAv1;

constructor TxmppContact.create(pProto: TRnQProtocol; const uin_: TUID);
begin
  inherited create(pProto, uin_);
//  iProto := Account.AccProto;
  clear;
//  uid := uin_;
  if assigned(onContactCreation) then
    onContactCreation(self);
end; // create

destructor TxmppContact.Destroy;
begin
// if assigned(onContactDestroying) then onContactDestroying(self);
// onContactDestroying := NIL;
 clear;
 inherited Destroy;
end;

function TxmppContact.getStatusName: String;
begin
{  if (XStatusAsMain and (status = SC_ONLINE)) and (xStatus.id > '') then
    begin
      if xStatus.Name > '' then
//        result := getTranslation(Xsts)
        result := xStatus.Name
       else
        if xStatus.Desc > '' then
  //        result := getTranslation(Xsts)
          result := xStatus.Desc
         else
//          result := getTranslation(XStatusArray[extSts].Caption)
            result := getTranslation(XMPPstatus2ShowStr[status])
    end}
{  if xStatus.Desc > '' then
    result := xStatus.Desc
   else}
    result := getTranslation(XMPPstatus2ShowStr[status])
end;

function TxmppContact.isInvisible: Boolean;
begin
  Result := false;
end;

function TxmppContact.isOffline: Boolean;
begin
  result := status = SC_OFFLINE;
end;

function TxmppContact.isOnline: Boolean;
begin
  result := not (status in [SC_OFFLINE, SC_UNK])
end;

procedure TxmppContact.OfflineClear;
begin
  invisible := False;
  typing.bIsTyping := False;
  typing.bIAmTyping := False;
//  crypt.supportCryptMsg := False;
//  xStatus.id := '';
//  xStatus.Name := '';
//  ICQVer := '';
end;

procedure TxmppContact.SetDisplay(const s: String);
begin
  inherited;
  TxmppSession(fProto).SSI_UpdateContact(self);
end;

procedure TxmppContact.setOffline;
begin
//  status := SC_OFFLINE;
  SetStatus(SC_OFFLINE);
  OfflineClear;
end;

function TxmppContact.statusImg: TPicName;
begin
  Result := '';
{  if xStatus.id > '' then
   begin
    Result := 'mra.'+xStatus.id;
    with theme.GetPicSize(RQteDefault, Result) do
     if (cx = 0)or(cy = 0) then
      result := '';
   end;
  if Result = '' then}
   Result := XMPPstatus2ImgName(status, invisible);
end;

function TxmppContact.getStatus: byte;
begin
  result := byte(status);
end;

function TxmppContact.uin2Show: string;
begin
  Result := UID;
end;

function TxmppContact.GetDBrow: RawByteString;
begin
  with TCE(data^) do
  begin
    Result := TLV2(DBFK_OLDUIN, int2str(0))
      +TLV2(DBFK_UID, UTF8Encode(uid))
      +TLV2(DBFK_SSIID, int2str(ssiid))
      +TLV2(DBFK_Authorized, Authorized)
      +TLV2U_IFNN(DBFK_DISPLAY, display)
      +TLV2U_IFNN(DBFK_NICK, nick)
      +TLV2U_IFNN(DBFK_FIRST, first)
      +TLV2U_IFNN(DBFK_LAST, last)
//      +TLV2_IFNN(DBFK_EMAIL, email)
//      +TLV2_IFNN(DBFK_CITY, city)
//      +TLV2_IFNN(DBFK_STATE, state)
//      +TLV2_IFNN(DBFK_ABOUT, about)
//      +TLV2_IFNN(DBFK_ZIP, zip)
//      +TLV2(DBFK_NODB, nodb)
//      +TLV2(DBFK_COUNTRY, int2str(country))
      +TLV2_IFNN(DBFK_BIRTH, birth)
//      +TLV2(DBFK_LANG, languages2str(lang))
//      +TLV2_IFNN(DBFK_HOMEPAGE, homepage)
//      +TLV2_IFNN(DBFK_CELLULAR, cellular)
//      +TLV2(DBFK_IP, int2str(connection.ip))
//      +TLV2(DBFK_AGE, int2str(age))
//      +TLV2(DBFK_GMT, AnsiChar(GMThalfs))
//      +TLV2(DBFK_GENDER, int2str(gender))
//      +TLV2(DBFK_GROUP, int2str(fGroupID))
      +TLV2(DBFK_GROUP, int2str(Group))
      +TLV2_IFNN(DBFK_LASTUPDATE, infoUpdatedTo)
      +TLV2_IFNN(DBFK_LASTONLINE, lastTimeSeenOnline)
      +TLV2_IFNN(DBFK_LASTMSG, lastMsgTime)
      +TLV2U_IFNN(DBFK_NOTES, notes)
      +TLV2(DBFK_DONTDELETE, dontdelete)
      +TLV2(DBFK_ASKEDAUTH, askedAuth)
//      +TLV2(DBFK_ONLINESINCE, dt2str(onlineSince))
//      +TLV2(DBFK_MEMBERSINCE, dt2str(memberSince))
//      +TLV2(DBFK_SMSABLE, smsable)
      +TLV2(DBFK_QUERY, toquery)
      +TLV2(DBFK_SENDTRANSL, SendTransl)
//      +TLV2(DBFK_INTERESTS, interests2str(interests))
      +TLV2_IFNN(DBFK_BIRTHL, birthL)
      +TLV2U_IFNN(DBFK_lclNoteStr, lclImportant)
//      +TLV2_IFNN(DBFK_ssNoteStr, ssImportant)
//      +TLV2_IFNN(DBFK_ssMail, ssMail)
      +TLV2(DBFK_ICONSHOW, int2str(icon.ToShow))
{
      +TLV2_IFNN(DBFK_ssCell, ssCells)
      +TLV2_IFNN(DBFK_CITY, IfThen(City_id=0, AnsiString(''), int2str(City_id)))
      +TLV2_IFNN(DBFK_STATE, IfThen(Location_id=0, AnsiString(''), int2str(Location_id)))
      +TLV2_IFNN(DBFK_COUNTRY, IfThen(Country_id=0, AnsiString(''), int2str(Country_id)))
      +TLV2_IFNN(DBFK_ZODIAC, IfThen(zodiac=0, AnsiString(''), AnsiChar(zodiac)))
}
      +TLV2_IFNN(DBFK_ICONMD5, Icon.hash_safe)
//      +TLV2_IFNN(DBFK_WORKPAGE, workpage)
//      +TLV2_IFNN(DBFK_WORKSTNT, workPos) // Должность
//      +TLV2_IFNN(DBFK_WORKDEPT, workDep) // Департамент
//      +TLV2_IFNN(DBFK_WORKCOMPANY, workCompany) // Компания
//      +TLV2(DBFK_WORKCOUNTRY, int2str(workCountry))
//      +TLV2_IFNN(DBFK_WORKZIP, workzip)
//      +TLV2_IFNN(DBFK_WORKADDRESS, workaddress)
//      +TLV2_IFNN(DBFK_WORKPHONE, workphone)
//      +TLV2_IFNN(DBFK_WORKSTATE, workstate)
//      +TLV2_IFNN(DBFK_WORKCITY,  workcity)
//      +TLV2(DBFK_MARSTATUS, int2str(MarStatus))
     ;
  end;
end;

function TxmppContact.ParseDBrow(ItemType: Integer; const item: RawByteString): Boolean;
begin
  Result := True;
  case ItemType of
{    DBFK_COUNTRY: self.Country_id := str2int(item);
    DBFK_EMAIL:   self.email:= UnUTF(item);
    DBFK_CITY:    self.city := UnUTF(item);
    DBFK_STATE:   self.state:= UnUTF(item);
    DBFK_ABOUT:   self.about:= UnUTF(item);
    DBFK_ZIP:     self.zip  := UnUTF(item);

//          DBFK_NODB:    self.nodb:=boolean(item[1]);
//          DBFK_COUNTRY: system.move(d[1], self.country, 4);
    DBFK_LANG:
        begin
          Lang1 := Byte(item[1]);
          Lang2 := Byte(item[2]);
        end;
    DBFK_HOMEPAGE:    self.homepage := UnUTF(item);
    DBFK_CELLULAR:    self.PhoneCell := UnUTF(item);
}
//          DBFK_IP:          system.move(d[1], self.connection.ip, 4);
//          DBFK_AGE:         system.move(d[1], self.age, 4);
//          DBFK_GMT:         system.move(d[1], self.GMThalfs, 1);
    DBFK_GENDER:      system.move(item[1], self.gender, 4);
    DBFK_LASTUPDATE:  system.move(item[1], self.infoUpdatedTo, 8);
    DBFK_LASTONLINE:  system.move(item[1], self.lastTimeSeenOnline, 8);
    DBFK_LASTMSG:     system.move(item[1], TCE(self.data^).lastMsgTime, 8);
{    DBFK_ONLINESINCE: system.move(item[1], self.onlinesince, 8);
    DBFK_MEMBERSINCE: system.move(item[1], self.membersince, 8);
}
//          DBFK_SMSABLE:     self.smsable := boolean(d[1]);
//          DBFK_INTERESTS:   str2interests(d, self.interests);
{
    DBFK_ssNoteStr:   self.ssImportant := UnUTF(item);
    DBFK_ssMail:      self.ssMail := UnUTF(item);
    DBFK_ssCell:      self.ssCell := UnUTF(item);
}
    DBFK_ICONMD5:     self.Icon.hash_safe := item;
{
    DBFK_WORKADDRESS: self.address := UnUTF(item);
//          DBFK_MARSTATUS:   self.MarStatus := str2int(d);
          DBFK_WORKSTNT:    self.workPos  := UnUTF(item); // Должность
          DBFK_WORKDEPT:    self.workDep  := UnUTF(item); // Департамент
          DBFK_WORKCOMPANY: self.workCompany := UnUTF(item); // Компания
}
   else
    Result := False;
  end;
end;

class procedure TxmppContact.UID2DomUser(const uid: TUID; var d, u: TUID);
//var
//  i: word;
//  found: Boolean;
//  ch: TUID_Char;
begin
  d := uid;
  u := chop(TUID('@'), TUID(d));
//  uid := trimUID(uin_);
//  U2 := LowerCase(uid);
//  d := UID2cmp;
//  i := 1;
//  repeat
//    k := i;
//    i := PosEx(AnsiString('/'), d, i+1);
//  until (i <= 0);
  d := chop(TUID('/'), TUID(d));
end;

class function TxmppContact.trimUID(const uid: TUID): TUID;
var
  i: word;
//  found: Boolean;
  ch: TUID_Char;
  d, u: TUID;
begin
  result := '';
  UID2DomUser(uid, d, u);
//  i := 1;
//  while i <= Length(uid) do
  for I := 1 to length(u) do
   begin
    ch := u[i];
    if not CharInSet(ch, BreakCharsS) then
     Result := Result + ch;
//    inc(i);
   end;
  Result := Result + '@';
  for I := 1 to length(d) do
   begin
    ch := d[i];
    if not CharInSet(ch, BreakChars) then
     Result := Result + ch;
//    inc(i);
   end;
end;

procedure TxmppContact.GetDomUser(var d, u: TUID);
//var
// u, d: AnsiString;
// i, k: Integer;
begin
  d := UID2cmp;
  u := chop(TUID('@'), TUID(d));
//  i := 1;
//  repeat
//    k := i;
//    i := PosEx(AnsiString('/'), d, i+1);
//  until (i <= 0);
  d := chop(TUID('/'), TUID(d));
end;
// destroy

class function TxmppContact.GetRes(const uid: TUID): TUID;
var
// u, d: AnsiString;
// i, k: Integer;
  u: TUID;
begin
  u := uid;
//  chop(RawByteString('/'), RawByteString(u));
  chop('/', u);
  result := u;
end;

function TxmppContact.AddRes(const uid: TUID): Int8;
var
//  r: TXMP_RESRC;
  i, l: Integer;
  rid: TUID;
begin
  Result := -1;
  rid := GetRes(uid);
{  if rid = '' then
    Exit;}
  l := Length(resources);
  if l > 0 then
   for i := 0 to l-1 do
    if resources[i].resID = rid then
      Result := i;
  if Result < 0 then
    begin
      SetLength(resources, l+1);
      resources[l].resID := rid;
      Result := l;
    end;
end;

function TxmppContact.findDefRes: Int8;
var
  i, l: Integer;
begin
  l := Length(resources);
  if l >0 then
    begin
      for I := Low(resources) to High(resources) do
        if not (resources[i].status in [SC_OFFLINE, SC_UNK])  then
         begin
          defRes := i;
          Exit(i);
         end;
      Result := -1;
    end
   else
    begin
      defRes := -1;
      Result := -1;
    end;
end;

function TxmppContact.GetResUID(resnum: Int8): TUID;
begin
  if (resnum >= Low(resources)) and (resnum <= High(resources)) then
    Result := UID2cmp + '/' + resources[resnum].resID
   else
    Result := UID2cmp;
end;

function TxmppContact.getStatusS: TXMPPstatus;
begin
  if Length(resources)> 0 then
    begin
      if defRes >=0 then
        result := resources[defRes].status
       else
        result := resources[0].status;
    end
   else
    Result := f_offline_sts;
end;

procedure TxmppContact.SetStatus(st: TXMPPstatus; res: Integer);
var
  I: Integer;
begin
  f_offline_sts := st;
  if Length(resources)> 0 then
    begin
      if (res >=0) then
        begin
          if (res < length(resources)) then
            resources[res].status := st;
        end
       else
        for I := Low(resources) to High(resources) do
          resources[i].status := st;
      findDefRes;
    end;
end;


function TxmppContact.canEdit: Boolean;
begin
  Result := True;
end;

procedure TxmppContact.clear;
//var
//  i: Byte;
begin
//uid := '';
//nick := '';
//first := '';
//last := '';
//  status := SC_UNK;
//  prevStatus := SC_UNK;
//  ClientID := '';
  f_offline_sts := SC_UNK;
  SetLength(resources, 0);
  defRes := -1;
//  icon.ToShow := IS_PHOTO;
  icon.ToShow := IS_AVATAR;
 {$IFDEF RNQ_AVATARS}
  icon_Path := '';
  FreeAndNil(icon.Bmp);
  FreeAndNil(icon.cache);
 {$ENDIF RNQ_AVATARS}
//  ssCells  := '';
  Icon.Hash_safe := '';
  XIcon.Hash := '';

  OfflineClear;
end;

procedure TxmppContact.ViewInfo;
var
  vi: TRnQviewInfoForm;
begin
// if c is TICQcontact then  // ICQ
  begin
   vi := findViewInfo(self);
   if vi = NIL then
    try
  //     vi :=
     TviewXMPPinfoFrm.doAll(RnQmain, self)
    except
    end
   else
    vi.bringToFront;
  end;
end;

procedure XMPPCL_setStatus(cl: TRnQCList; st: TXMPPStatus);
var
  i: integer;
  cnt: TRnQContact;
begin
  for i:=0 to cl.count-1 do
   begin
    cnt := cl.getAt(i);
    if cnt is TXMPPContact then
      TXMPPContact(cnt).SetStatus(st);
   end;
end;


end.
