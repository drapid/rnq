{
  This file is part of R&Q.
  Under same license
}
unit WIMContacts;
{$I RnQConfig.inc}
{$I NoRTTI.inc}
{$I-}
{$X+}
interface

uses
  Classes, SysUtils,
{$IFDEF RNQ_AVATARS}
  Graphics,
{$ENDIF RNQ_AVATARS}
  RnQGraphics32,
  WIMConsts,
  Types, RDGlobal, RnQProtocol;

type
  TLanguages = array [1..3] of String;
  TinterestBlock = record // By Shyr
             Code: integer;
//             Str: String;
             Names: Tstrings;
            end;
  Tinterests = record
//              InterestBlock: array of TinterestBlock;
              InterestBlock: array[0..3] of TinterestBlock;
              Count: integer;
             end;

  TWIMContact = class(TRnQContact)
  public
    UININT: Integer;
    NoClient: Boolean;
    Official: Boolean;
    ClientClosed: TDateTime;
    Status: TWIMStatus;
    PrevStatus: TWIMStatus;
    InvisibleState: Byte;
    UserType: TWIMContactType;
    Crypt: record
      supportEcc: Boolean;
      supportCryptMsg: Boolean;
      cryptPWD: RawByteString;
      qippwd: Integer;
      EccPubKey: RawByteString;
      EccMsgKey: RawByteString;
    end;
    Gender: SmallInt;
    Age: Integer;
    MarStatus: Word;
    Email,
    Address,
    City,
    Country,
    State,
    About,
    ZIP,
    Homepage,
    // work
    Workcity,
    Workstate,
    Workphone,
    Workfax,
    Workaddress,
    Workzip,
    WorkCompany,
    WorkDep,
    WorkPos,
    Workpage,
    BirthCountry,
    BirthCity,
    BirthState,
    BirthAddress,
    BirthZIP,
    Regular,
    Cellular,
    SMSMobile,
    OtherPhone,
//    lclImportant,
    ssImportant,
    ssCell,
    ssCell2,
    ssCell3,
    ssCell4,
    ssNickname,
    ssMail: String;
    OnlineTime: DWord;       // В секундах!
    LastUpdate_dw: DWord;
    Lastinfoupdate_dw: DWord;
    LastStatusUpdate_dw: DWord;
//    WorkCountry: Word;
    IdleTime: Word;          // В секундах!
    GMThalfs: ShortInt;
    Lang: TLanguages;
    CreateTime,           // GMT
    MemberSince,          // GMT
    OnlineSince,          // local time
    LastUpdate,           // local time
    LastInfoUpdate,       // local time
    LastStatusUpdate,     // local time
    InfoUpdatedTo: TDateTime;        // local time
    ProtoV: integer;
    fServerProto: String;
    Connection: record
      port, ft_port: Integer;
      ip, internal_ip: DWord;
      proxy_ip: DWord;
      dc_cookie: DWord;
     end;
    SMSable,
    NoDB,
    Muted,
//    Authorized,
    BirthFlag,
    ICQ2Go,
    isMobile,
    isAIM: Boolean;
    CapabilitiesBig: set of 1..45;
    CapabilitiesSm: set of 1..36;
    CapabilitiesXTraz: set of 1..50;
    ExtraCapabilities: RawByteString;
    LastCapsUpdate: TTime;
    InfoToken: RawByteString;
//    Interests: Array of record code: Integer; Str: String; end;
    Cookie: RawByteString;
    LastAccept: TICQAccept;

    LifeStatus: String;
    xStatusStr: String;
    xStatusDesc: String;
    xStatus: Byte;
//    xStatusOld: Byte;
    IconID: RawByteString;
    Interests: TInterests; // By Shyr
//    data: tce;
   public
    constructor Create(pProto: TRnQProtocol; const uin_: TUID); override;
    destructor Destroy; override;
//     class operator Implicit(const a: AnsiString): TContact; inline;// Implicit conversion of an Integer to type TMyClass
    procedure clear; override;
    procedure clearInterests;
    procedure setOffline;
    procedure OfflineClear;
    function  isOnline: Boolean; override; final;
    function  isInvisible: Boolean; override;
    function  isOffline: Boolean; override; final;
    function  canEdit: Boolean; override;
    function  getGMT: TdateTime;
    function  GMTavailable: boolean;
    function  uinAsStr: string; {$IFDEF HAS_INLINE} inline; {$ENDIF HAS_INLINE}
    function  uin2Show: string; OverRide; Final;
    function  getStatusName: String; OverLoad; OverRide; final;
    function  statusImg: TPicName; OverRide; final;
    function  getStatus: byte; OverRide; final;
    procedure SetDisplay(const s: String); OverRide; final;
    function  GetDBrow: RawByteString; OverRide; final;
    function  ParseDBrow(ItemType: Integer; const item: RawByteString): Boolean; OverRide; final;
    procedure ViewInfo; OverRide; final;
    function  isAcceptFile: Boolean; OverRide; final;
    class function trimUID(const sUID: TUID): TUID; OverRide; final;
    procedure AddInterest(idx: byte; code: Integer; str: String);
   end; // TWIMContact
//  Tcontact = TWIMContact;
//  function  ICQCL_buinlist(cl: TRnQCList; Proto: IRnQProtocol): string;
  procedure ICQCL_setStatus(cl: TRnQCList; st: TWIMStatus);
  function  ICQCL_idxBySSID(cl: TRnQCList; ssid: Word): integer;
//  function  ICQCL_C8SSIByGrp(cl: TRnQCList; grID: Integer): AnsiString;
//  function  ICQCL_SSIByGrp(cl: TRnQCList; grID: Integer): AnsiString;

  function unFakeUIN(uin: int64): TUID;

//var
//  ICQContactsDB: TcontactList;
//  statusPics: array[Tstatus, boolean] of TRnQThemedElementDtls;
{    record
      ImgElm: TRnQThemedElementDtls;
//      tkn: Integer;
//      idx: Integer;
//      Loc: TPicLocation;
    end;}

implementation

uses
  {$IFDEF UNICODE}
    Character, AnsiStrings,
  {$ENDIF UNICODE}
  RQUtil, RnQLangs, RDUtils, RnQBinUtils, RnQDialogs,
  RnQConst, GlobalLib, mainDlg, utilLib,
  WIM, viewWIMinfoDlg, Protocol_WIM;

///////////////////////////////////////////////////////////////////////////

constructor TWIMContact.create(pProto: TRnQProtocol; const uin_: TUID);
begin
  inherited create(pProto, uin_);
  clear;
//  iProto := Account.AccProto;
//  uid := uin_;
//  UID2cmp := AnsiLowerCase(trimUID(uid));
  isAIM := not isOnlyDigits(UID);
  if isAIM then
    uinINT := 0
   else
    uinINT := StrToIntDef(UID2cmp, 0);
   {$IFDEF RNQ_AVATARS}
  icon.Bmp := nil;
  icon.cache := nil;
   {$ENDIF RNQ_AVATARS}
  if assigned(onContactCreation) then
    onContactCreation(self);
end; // create

destructor TWIMContact.Destroy;
begin
// if assigned(onContactDestroying) then onContactDestroying(self);
// onContactDestroying := NIL;
 clear;
 inherited Destroy;
end; // destroy

procedure TWIMContact.clear;
begin
  //uid := '';
  //nick := '';
  //first := '';
  //last := '';
   {$IFDEF RNQ_AVATARS}
  if Assigned(icon.Bmp) then
   try
     icon.Bmp.Free;
    except
     msgDlg(getTranslation('Error on destroying avatar of contact: %s', [uid]), False, mtError, uinAsStr);
   end;
  icon.Bmp := nil;
  icon.ToShow := 0;
  FreeAndNil(icon.cache);
  IconID := '';
{$ENDIF RNQ_AVATARS}
  status := WIMConsts.SC_UNK;
  UserType := CT_ICQ;
  gender := 0;
  age := 0;
  connection.ip := 0;
  connection.internal_ip := 0;
  connection.port := 0;
  GMThalfs := 100;
  country := '';
  group := 0;
  birth := 0;
  birthFlag := False;
  infoUpdatedTo := 0;
  lastTimeSeenOnline := 0;
  fillChar(lang, sizeOf(lang), 0);
  homepage := '';
  regular := '';
  cellular := '';
  SMSMobile := '';
  SMSable := False;
  Official := False;
  protoV := 0;
  MarStatus := 0;
  crypt.qippwd := 0;
  crypt.supportCryptMsg := False;
  nodb := False;
  icq2go := False;
  isMobile := False;
  capabilitiesBig := [];
  capabilitiesSm := [];
  capabilitiesXTraz := [];
  extracapabilities := '';
//  SetLength(about, 0);
  SetLength(ssImportant, 0);
  SetLength(lclImportant, 0);
//  SetLength(email, 0);
  SetLength(ssCell, 0);
  SetLength(ssCell2, 0);
  SetLength(ssCell3, 0);
  SetLength(ssCell4, 0);
  SetLength(ssNickname, 0);
  SetLength(ssMail, 0);

  fDisplay := '';
  email := '';
  city := '';
  state := '';
  about := '';
  zip := '';
  homepage := '';
  // work
  workcity := '';
  workstate := '';
  workphone := '';
  workfax := '';
  workaddress := '';
  workzip := '';
  workCompany := '';
  workDep := '';
  workPos := '';
  workpage := '';
  regular := '';
  cellular := '';
  SMSMobile := '';
  clearInterests;
end; // clear

procedure TWIMContact.clearInterests;
var
  i: Integer;
begin
  for i := Low(interests.InterestBlock) to High(interests.InterestBlock) do
   begin
    interests.InterestBlock[i].Code := 0;
    if Assigned(interests.InterestBlock[i].Names) then
      FreeAndNil(interests.InterestBlock[i].Names);
   end;
 interests.Count := 0;
end;

procedure TWIMContact.SetOffline;
begin
  OfflineClear;
  status := WIMConsts.SC_OFFLINE;
end;

procedure TWIMContact.OfflineClear;
begin
  invisibleState := 0;
  typing.bIsTyping := False;
  typing.bIAmTyping := False;
  crypt.supportCryptMsg := False;
  xStatus := 0;
  capabilitiesXTraz := [];
//  xStatusOld := 0;
//  xStatusStr := '';
//  xStatusDesc := '';
//  ICQVer := '';
  birthFlag := False;
  IdleTime := 0;
end;

function TWIMContact.getGMT: TdateTime;
begin result := -GMThalfs/48 end;

function TWIMContact.GMTavailable: boolean;
begin result := abs(GMThalfs) < 100 end;

function TWIMContact.isOnline: Boolean;
begin
  result := not (status in [WIMConsts.SC_OFFLINE, WIMConsts.SC_UNK])
end;

function TWIMContact.isAcceptFile: Boolean;
begin
  Result := False;
end;

function TWIMContact.isInvisible: Boolean;
begin
  Result := InvisibleState > 0;
end;

function TWIMContact.isOffline: Boolean;
begin
  result := status = WIMConsts.SC_OFFLINE;
end;

function TWIMContact.canEdit: Boolean;
begin
  result := CntIsLocal or
 {$IFDEF UseNotSSI}
    ((fProto is TicqSession) and
      not TicqSession(fProto).usessi) or
//    icq.useSSI and
 {$ENDIF UseNotSSI}
     fProto.isOnline;
end;

procedure TWIMContact.SetDisplay(const s: String);
var
  s0: String;
begin
  s0 := Display;
  inherited;
  // TODO: Update displayed name on server
  if s0 <> Display then
    TWIMSession(fProto).SSI_UpdateContact(self);
end;

procedure TWIMContact.ViewInfo;
var
  vi: TRnQViewInfoForm;
begin
  vi := findViewInfo(Self);
  if vi = nil then
    try
      TviewinfoFrm.doAll(RnQmain, self)
     except
    end
   else
    vi.BringToFront;
end;

function TWIMContact.uinAsStr: String;
begin result := uid end;

function TWIMContact.uin2Show: String;
var
  i, m, n, l: byte;
  s: String;
begin
 s := uinAsStr;
 if (not isAIM) and ShowUINDelimiter then
   begin
//     s := UnDelimiter(uid);
     l := length(s);
     if l > 3 then
      begin
       result := '';
       m := l div 3;
       n := l mod 3;
       if n > 0 then
        Result := Copy(s, 1, n) + '-';
       if m > 1 then
       for I := 0 to m-2 do
         Result := Result + Copy(s, 1 + n + i * 3, 3) + '-';
       result := Result + copy(s, l-2, 3);
      end
     else
      Result := s;
   end
  else
   result := s
end;

function TWIMContact.getStatusName: String;
var
  s1: String;
begin
  s1 := '';
  if fProto.isOnline then
//   begin
    if xStatusStr > '' then
      s1 := xStatusStr;
//     else
//      if xStatusDesc > '' then
//        s1 := xStatusDesc
//       else
//        if ICQ6Status > '' then
//          s1 := ICQ6Status
//   end;
  if (s1 > '') then
    if status <> WIMConsts.SC_ONLINE then
       result := getTranslation(status2ShowStr[status]) +' ('+ s1 +')'
     else
       result := s1
   else
    result := getTranslation(status2ShowStr[status]);
end;

function TWIMContact.statusImg: TPicName;
begin
//  result := status2ImgName(byte(status), invisible);
  if False{XStatusAsMain} and (xStatus > 0) then
    Result := XStatusArray[xStatus].PicName
   else
    begin
     result := status2imgName(byte(status), isInvisible);
    end;
end;

function TWIMContact.getStatus: byte;
begin
  result := byte(status);
end;

class function TWIMContact.trimUID(const sUID: TUID): TUID;
var
  i: Word;
  t: Word;
//  pp: PAnsiChar;
  ch: TUID_Char;
  s1, s2: TUID;
  isAIM: Boolean;
begin
  Result := '';
//  i := 1;
//  while i <= Length(uid) do
//  SetLength(Result, length(sUID));
  s1 := Trim(sUID);
  if Length(s1) = 0 then
    Exit;

  isAIM := not (s1[1] in ['0'..'9']);

  s2 := dupString(s1);

  t := 0;

  if isAIM then
    begin
      for I := 1 to length(sUID) do
       begin
        ch := s2[i];
//        if not TCharacter.IsSeparator(ch)  then
        if not ((ch = ' ') or (ch = Char($A0))) then
         begin
          inc(t);
          if i <> t then
            s2[t] := ch;
         end;
       end;
//      Exit;
    end
   else
    begin
      for I := 1 to length(sUID) do
       begin
        ch := s2[i];
        if ch in UID_CHARS then
         begin
          inc(t);
          if i <> t then
            s2[t] := ch;
    //      pp[t-1] :=Result[i];
         end;
       end;
    end;
  SetLength(Result, t);
  if t <> Length(s1) then
    Result := Copy(s2, 1, t)
   else
    Result := s2
end;

procedure TWIMContact.AddInterest(idx: byte; code: Integer; str: String);
begin
  Interests.InterestBlock[idx].Code := code;
  if (Interests.InterestBlock[idx].Names <> NIL)
     AND Assigned(Interests.InterestBlock[idx].Names) then
     Interests.InterestBlock[idx].Names.Clear
    else
     Interests.InterestBlock[idx].Names:=TStringList.Create;
   while str<>'' do
     Interests.InterestBlock[idx].Names.Add(chop(',', str));
//                 Interests.InterestBlock[i].Count:=int.Count+1;
end;

function TWIMContact.GetDBrow: RawByteString;
  function interests2str(int: Tinterests): RawByteString;  // By Shyr
  var
   i, j: integer;
   s: RawByteString;
   present: Boolean;
  begin
   s := '';
   present := False;
//   p := '';
   for i:=0 to int.Count-1 do
   if int.InterestBlock[i].Code > 0 then
   begin
    present := True;
    try
    s := s + AnsiChar(int.InterestBlock[i].Code);
    if Assigned(int.interestBlock[i].Names) then
     for j:=0 to int.interestBlock[i].Names.Count-1 do
      begin
       if j<>0 then
         s := s + ',';
       s:= s + StrToUTF8(int.interestBlock[i].Names.Strings[j]);
      end;
    except
     s := '';
    end;
//     s:=s+int.interestBlock[i].Str;
    s := s+#0;
   end;
   if present then
     Result := s
    else
     Result := '';
//   p := '';
  end;

var
  tuin: Integer;
begin
  if not TryStrToInt(String(UID2cmp), tuin) then
    tuin := 0;
  with TCE(data^) do
    Result := //TLV2(DBFK_OLDUIN, int2str(tuin))
        TLV2(DBFK_OLDUIN, integer(tuin))
      +TLV2(DBFK_UID, uid)
      +TLV2_IFNN(DBFK_UTYPE, Integer(UserType))
      +TLV2_IFNN(DBFK_SSIID, IfThen(CntIsLocal or (ssiid=0), AnsiString(''), int2str(ssiid)))
      +TLV2_IFNN(DBFK_Authorized, IfThen(CntIsLocal, AnsiString(''), bool2str(Authorized)))
      +TLV2U_IFNN(DBFK_DISPLAY, display)
      +TLV2U_IFNN(DBFK_NICK, nick)
      +TLV2U_IFNN(DBFK_FIRST, first)
      +TLV2U_IFNN(DBFK_LAST, last)
      +TLV2U_IFNN(DBFK_EMAIL, email)
      +TLV2U_IFNN(DBFK_ADDRESS, address)
      +TLV2U_IFNN(DBFK_CITY, city)
      +TLV2U_IFNN(DBFK_STATE, state)
      +TLV2U_IFNN(DBFK_ABOUT, about)
      +TLV2U_IFNN(DBFK_ZIP, zip)
      +TLV2(DBFK_NODB, nodb)
      +TLV2U_IFNN(DBFK_COUNTRY_CODE, country)
      +TLV2_IFNN(DBFK_LANG1, lang[1])
      +TLV2_IFNN(DBFK_LANG2, lang[2])
      +TLV2_IFNN(DBFK_LANG3, lang[3])
      +TLV2U_IFNN(DBFK_HOMEPAGE, homepage)
      +TLV2U_IFNN(DBFK_REGULAR, regular)
      +TLV2U_IFNN(DBFK_CELLULAR, cellular)
      +TLV2U_IFNN(DBFK_SMSMOBILE, SMSMobile)
      +TLV2_IFNN(DBFK_IP, connection.ip)
//      +TLV2(DBFK_AGE, int2str(age))
      +TLV2_IFNN(DBFK_AGE, integer(age))
      +TLV2(DBFK_GMT, AnsiChar(GMThalfs))
//      +TLV2(DBFK_GENDER, int2str(gender))
      +TLV2_IFNN(DBFK_GENDER, integer(gender))
//      +TLV2(DBFK_GROUP, int2str(group))
      +TLV2(DBFK_GROUP, integer(group))
      +TLV2_IFNN(DBFK_LASTUPDATE, infoUpdatedTo)
      +TLV2_IFNN(DBFK_LASTONLINE, lastTimeSeenOnline)
      +TLV2_IFNN(DBFK_LASTMSG, lastMsgTime)
      +TLV2U_IFNN(DBFK_NOTES, notes)
      +TLV2(DBFK_DONTDELETE, dontdelete)
      +TLV2(DBFK_ASKEDAUTH, askedAuth)
      +TLV2_IFNN(DBFK_ONLINESINCE, onlineSince)
      +TLV2_IFNN(DBFK_MEMBERSINCE, memberSince)
      +TLV2_IFNN(DBFK_LASTINFOCHG, lastInfoUpdate)
      +TLV2_IFNN(DBFK_BIRTH, birth)
      +TLV2_IFNN(DBFK_BIRTHL, birthL)
      +TLV2_IFNN(DBFK_LASTBDINFORM, LastBDInform)
      +TLV2(DBFK_SMSABLE, smsable)
      +TLV2(DBFK_QUERY, toquery)
      +TLV2(DBFK_SENDTRANSL, SendTransl)
      +TLV2_IFNN(DBFK_INTERESTS, interests2str(interests))
      +TLV2U_IFNN(DBFK_lclNoteStr, lclImportant)
      +TLV2U_IFNN(DBFK_ssNoteStr, ssImportant)
//      +TLV2U_IFNN(DBFK_ssMail, ssMail)
//      +TLV2U_IFNN(DBFK_ssNickname, ssNickname)
      +TLV2U_IFNN(DBFK_ssCell, ssCell)
      +TLV2U_IFNN(DBFK_ssCell2, ssCell2)
      +TLV2U_IFNN(DBFK_ssCell3, ssCell3)
      +TLV2U_IFNN(DBFK_ssCell4, ssCell4)
//      +TLV2(DBFK_ICONSHOW, int2str(icon.ToShow))
      +TLV2(DBFK_ICONSHOW, integer(icon.ToShow))
      +TLV2_IFNN(DBFK_ICONMD5, Icon.hash_safe)
      +TLV2U_IFNN(DBFK_WORKPAGE, workpage)
      +TLV2U_IFNN(DBFK_WORKSTNT, workPos) // Должность
      +TLV2U_IFNN(DBFK_WORKDEPT, workDep) // Департамент
      +TLV2U_IFNN(DBFK_WORKCOMPANY, workCompany) // Компания
//      +TLV2_IFNN(DBFK_WORKCOUNTRY, integer(workCountry))
      +TLV2U_IFNN(DBFK_WORKZIP, workzip)
      +TLV2U_IFNN(DBFK_WORKADDRESS, workaddress)
      +TLV2U_IFNN(DBFK_WORKPHONE, workphone)
      +TLV2U_IFNN(DBFK_WORKSTATE, workstate)
      +TLV2U_IFNN(DBFK_WORKCITY,  workcity)
      +TLV2_IFNN(DBFK_MARSTATUS, MarStatus)
      +TLV2_IFNN(DBFK_qippwd, crypt.qippwd)

      +TLV2U_IFNN(DBFK_BIRTHCOUNTRY_CODE, BirthCountry)
      +TLV2U_IFNN(DBFK_BIRTHSTATE, BirthState)
      +TLV2U_IFNN(DBFK_BIRTHCITY, BirthCity)
      +TLV2U_IFNN(DBFK_BIRTHADDRESS, BirthAddress)
      +TLV2U_IFNN(DBFK_BIRTHZIP, BirthZIP)
end;

function TWIMContact.ParseDBrow(ItemType: Integer; const item: RawByteString): Boolean;
  procedure str2interests(str: RawByteString; var int: Tinterests);  // By Shyr
  var
   s1: RawByteString;
   s2: string;
  begin
   int.Count := 0;
   if str<>'' then
     str := str+'';
   while (str<>'')and (int.Count < 4) do begin
    s1 := chop(AnsiChar(#0), str);
    if s1 > '' then
     begin
      int.InterestBlock[int.Count].Code := Byte(s1[1]);
      s1 := Copy(s1,2,length(s1)-1);
      int.interestblock[int.Count].Names := TStringList.Create;
      while s1<>'' do begin
       s2 := UnUTF(chop(AnsiChar(','),s1));
       int.interestblock[int.Count].Names.Add(s2);
      end;
      int.Count := int.Count+1;
     end;
   end;
  end;

begin
  Result := True;
  case ItemType of
    DBFK_EMAIL: self.email:= UnUTF(item);
    DBFK_ADDRESS: self.address := UnUTF(item);
    DBFK_CITY: self.city := UnUTF(item);
    DBFK_STATE: self.state:= UnUTF(item);
    DBFK_ABOUT: self.about:= UnUTF(item);
    DBFK_ZIP: self.zip  := UnUTF(item);
    DBFK_NODB: self.nodb := boolean(item[1]);
    DBFK_COUNTRY_CODE: self.country := UnUTF(item);
    DBFK_LANG1: self.lang[1] := UnUTF(item);
    DBFK_LANG2: self.lang[2] := UnUTF(item);
    DBFK_LANG3: self.lang[3] := UnUTF(item);
    DBFK_HOMEPAGE: self.homepage := UnUTF(item);
    DBFK_CELLULAR: self.cellular := UnUTF(item);
    DBFK_SMSMOBILE: self.SMSMobile := UnUTF(item);
    DBFK_REGULAR: self.regular := UnUTF(item);
    DBFK_IP: system.move(item[1], self.connection.ip, 4);
    DBFK_AGE: system.move(item[1], self.age, 4);
    DBFK_GMT: system.move(item[1], self.GMThalfs, 1);
    DBFK_GENDER: system.move(item[1], self.gender, 4);
    DBFK_LASTUPDATE: system.move(item[1], self.infoUpdatedTo, 8);
    DBFK_LASTONLINE: system.move(item[1], self.lastTimeSeenOnline, 8);
    DBFK_LASTMSG: system.move(item[1], TCE(self.data^).lastMsgTime, 8);
    DBFK_ONLINESINCE: system.move(item[1], self.onlinesince, 8);
    DBFK_MEMBERSINCE: system.move(item[1], self.membersince, 8);
    DBFK_LASTINFOCHG: system.move(item[1], self.lastInfoUpdate, 8);
    DBFK_SMSABLE: self.smsable := boolean(item[1]);
    DBFK_INTERESTS: str2interests(item, self.interests);
    DBFK_WORKPAGE: self.workpage := UnUTF(item);
    DBFK_WORKSTNT: self.workPos  := UnUTF(item); // Должность
    DBFK_WORKDEPT: self.workDep  := UnUTF(item); // Департамент
    DBFK_WORKCOMPANY: self.workCompany := UnUTF(item); // Компания
//    DBFK_WORKCOUNTRY: system.move(item[1], self.workCountry, 4);
    DBFK_WORKZIP: self.workzip := UnUTF(item);
    DBFK_WORKADDRESS: self.workaddress := UnUTF(item);
    DBFK_WORKPHONE: self.workphone := UnUTF(item);
    DBFK_WORKSTATE: self.workstate := UnUTF(item);
    DBFK_WORKCITY: self.workcity  := UnUTF(item);

    DBFK_BIRTHCOUNTRY_CODE: self.BirthCountry := UnUTF(item);
    DBFK_BIRTHSTATE: self.BirthState := UnUTF(item);
    DBFK_BIRTHCITY: self.BirthCity := UnUTF(item);
    DBFK_BIRTHADDRESS: self.BirthAddress := UnUTF(item);
    DBFK_BIRTHZIP: self.birthZIP := UnUTF(item);

    DBFK_ssNoteStr: self.ssImportant := UnUTF(item);
    DBFK_ssMail: self.ssMail := UnUTF(item);
//    DBFK_ssNickname: self.ssNickname := UnUTF(item);
    DBFK_ssCell: self.ssCell := UnUTF(item);
    DBFK_ssCell2: self.ssCell2 := UnUTF(item);
    DBFK_ssCell3: self.ssCell3 := UnUTF(item);
    DBFK_ssCell4: self.ssCell4 := UnUTF(item);
    DBFK_MARSTATUS: self.MarStatus := str2int(item);
    DBFK_qippwd: self.crypt.qippwd := str2int(item);

    DBFK_UTYPE: self.UserType := TWIMContactType(str2int(item));
  else
    Result := inherited ParseDBrow(ItemType, item);
  end;
end;

{operator TWIMContact.Implicit(a: AnsiString): TContact; // Implicit conversion of an Integer to type TMyClass
begin
  result := TWIMContact.create(a);
end;
}
///////////////////////////////////////////////////////////////////


function ICQCL_idxBySSID(cl: TRnQCList; ssid: Word): integer;
var
//  min, max: integer;
//  u: TUID;
//  uid: TUID;
  c: TRnQContact;
begin
  Result := -1;
  if cl.count = 0 then
   begin
    result := -1;
    exit;
   end;
//  max:=count-1;
  repeat
   inc(result);
   c := cl.getAt(result);
   if Assigned(c)and (c is TWIMContact) then
    if TWIMContact(c).SSIID = ssid then
     break;
  until Result < cl.count;
  if Result >= cl.count then
    Result := -1;
//result:=-1;
end;

procedure ICQCL_SetStatus(cl: TRnQCList; st: TWIMstatus);
var
  i: integer;
  cnt: TRnQContact;
begin
  for i:=0 to cl.count-1 do
   begin
    cnt := cl.getAt(i);
    if cnt is TWIMContact then
      TWIMContact(cnt).status := st;
   end;
end; // setStatus
{
function ICQCL_SSIByGrp(cl: TRnQCList; grID: Integer): AnsiString;
var
  i: integer;
begin
  result := '';
  for i:=0 to cl.count-1 do
//   with TWIMContact(cl.items[i]) do
   with TWIMContact(cl.getAt(i)) do
   if (group = grID)and (not CntIsLocal) and (SSIID > 0) then
    result := result + word_BEasStr(SSIID);
end;

function ICQCL_C8SSIByGrp(cl: TRnQCList; grID: Integer): AnsiString;
begin
  result := TLV($C8, ICQCL_SSIByGrp(cl, grID));
end;
}
function unFakeUIN(uin: int64): TUID;
var
  x: int64;
begin
// x := MaxLongint;
 x := UIN;
 while x > 4294967296 do
  x := x - 4294967296;
 result := IntToStr(x);
end;

end.
