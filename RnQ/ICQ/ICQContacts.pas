{
  This file is part of R&Q.
  Under same license
}
unit ICQContacts;
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
  {$IFDEF USE_GDIPLUS}
    GDIPAPI,
    GDIPOBJ,
    RnQGraphics,
  {$ELSE}
    RnQGraphics32,
  {$ENDIF USE_GDIPLUS}
  ICQConsts,
  Types, RDGlobal, RnQProtocol;

type
//  TvisStatus = set
  Tlanguages = array [1..3] of byte;

type
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
//  TAvatarTypes =

//  TICQcontact = class;
//  TcontactProc = procedure(c: Tcontact);

  TICQcontact = class(TRnQContact)
   public
    uinINT: integer;
//   private
//   public
    invisible: boolean;
    noClient: boolean;
    clientClosed: TDateTime;
    status: TICQstatus;
    prevStatus: TICQstatus;
   { $IFDEF CHECK_INVIS}
    invisibleState: byte;
   { $ENDIF}
    crypt: record
      supportEcc: Boolean;
      supportCryptMsg: Boolean;
      cryptPWD: RawByteString;
      qippwd: Integer;
      EccPubKey: RawByteString;
      EccMsgKey: RawByteString;
     end;  
    gender: Smallint;
    age: Smallint;
    MarStatus: word;
    email,
    address,
    city,
    state,
    about,
    zip,
    homepage,
    // work
    workcity,
    workstate,
    workphone,
    workfax,
    workaddress,
    workzip,
    workCompany,
    workDep,
    workPos,
    workpage,
    birthcity,
    birthstate,
    regular,
    cellular,
//    lclImportant,
    ssImportant,
    ssCell,
    ssCell2,
    ssCell3,
    ssMail: String;
    OnlineTime: DWord;       // В секундах!
    lastUpdate_dw: DWord;
    lastinfoupdate_dw: DWord;
    lastStatusUpdate_dw: DWord;
    country, workCountry, birthCountry: word;
    IdleTime: word;          // В секундах!
    GMThalfs: Shortint;
    lang: Tlanguages;
    CreateTime,           // GMT
    memberSince,          // GMT
    onlineSince,          // local time
    lastUpdate,           // local time
    lastInfoUpdate,       // local time
    lastStatusUpdate,     // local time
    infoUpdatedTo: TDateTime;        // local time
    proto: Integer;
    fServerProto: String;
    connection: record
      port, ft_port: integer;
      ip, internal_ip: DWord;
      proxy_ip: DWord;
      dc_cookie: DWord;
     end;
    SMSable,
    nodb,
//    Authorized,
    birthFlag,
    icq2go,
    isMobile,
    isAIM: Boolean;
    capabilitiesBig: set of 1..45;
    capabilitiesSm: set of 1..30;
    capabilitiesXTraz: set of 1..50;
    extracapabilities: RawByteString;
    InfoToken: RawByteString;
//    Interests: Array of record code: Integer; Str: String; end;
    cookie: RawByteString;
    lastAccept: TicqAccept;

    ICQ6Status: String; 
    xStatusStr: String;
    xStatusDesc: String;
    xStatus: byte;
//    xStatusOld : byte;
     ICQIcon: record
//       Hash_safe: String[16];
//       Hash: String[16];
//       Hash_safe: RawByteString;
       Hash: RawByteString;
      end;
    interests: Tinterests; // By Shyr
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
   end; // TICQcontact
//  Tcontact = TICQcontact;
//  function  ICQCL_buinlist(cl: TRnQCList; Proto: IRnQProtocol):string;
  procedure ICQCL_setStatus(cl: TRnQCList; st: TICQStatus);
  function  ICQCL_idxBySSID(cl: TRnQCList; ssid: Word): integer;
  function  ICQCL_C8SSIByGrp(cl: TRnQCList; grID: Integer): AnsiString;
  function  ICQCL_SSIByGrp(cl: TRnQCList; grID: Integer): AnsiString;


//var
//  ICQContactsDB: TcontactList;
//  statusPics: array[Tstatus, boolean] of TRnQThemedElementDtls;
{    record
      ImgElm: TRnQThemedElementDtls;
//      tkn: Integer;
//      idx: Integer;
//      Loc: TPicLocation;
    end;}

IMPLEMENTATION

uses
  {$IFDEF UNICODE}
    Character, AnsiStrings,
  {$ENDIF UNICODE}
    RQUtil, RnQLangs, RDUtils, RnQBinUtils, RnQDialogs,
    RnQConst, GlobalLib, ICQv9, viewInfoDlg, mainDlg, utilLib,
    Protocol_ICQ;

///////////////////////////////////////////////////////////////////////////

constructor TICQcontact.create(pProto: TRnQProtocol; const uin_: TUID);
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
//    uinINT := StrToIntDef(UID2cmp, 0);
    uinINT := inherited UIDasInt; // StrToIntDef(UID2cmp, 0);
   {$IFDEF RNQ_AVATARS}
  icon.Bmp := NIL;
  icon.cache := NIL;
   {$ENDIF RNQ_AVATARS}
  if assigned(onContactCreation) then
    onContactCreation(self);
end; // create

destructor TICQcontact.Destroy;
begin
// if assigned(onContactDestroying) then onContactDestroying(self);
// onContactDestroying := NIL;
 clear;
 inherited Destroy;
end; // destroy

procedure TICQcontact.clear;
//var
//  i: Byte;
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
  icon.Bmp := NIL;
  icon.ToShow := 0;
  if Assigned(icon.cache) then
    icon.cache.Free;
  icon.cache := NIL;
  icon.Hash_safe := '';
   {$ENDIF RNQ_AVATARS}
  status := ICQConsts.SC_UNK;
  gender := 0;
  age := 0;
  connection.ip := 0;
  connection.internal_ip := 0;
  connection.port := 0;
  GMThalfs := 100;
  country := 0;
  group := 0;
  birth := 0;
  birthFlag := False;
  infoUpdatedTo := 0;
  lastTimeSeenOnline := 0;
  fillChar(lang, sizeOf(lang), 0);
  homepage := '';
  regular := '';
  cellular := '';
  SMSable := FALSE;
  proto := 0;
  MarStatus := 0;
  crypt.qippwd := 0;
  crypt.supportCryptMsg := False;
  nodb := FALSE;
  icq2go := FALSE;
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
  clearInterests;
end; // clear

procedure TICQcontact.clearInterests;
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

procedure TICQcontact.setOffline;
begin
  OfflineClear;
  status := ICQConsts.SC_OFFLINE;
end;

procedure TICQcontact.OfflineClear;
begin
  invisibleState := 0;
 {$IFDEF CHECK_INVIS}
//  invisibleState := 0;
 {$ENDIF}
  invisible := False;
  typing.bIsTyping := False;
  typing.bIAmTyping := False;
  crypt.supportCryptMsg := False;
  xStatus := 0;
  capabilitiesXTraz := [];
//  xStatusOld := 0;
//  xStatusStr := '';
//  xStatusDesc := '';
//  ICQVer := '';
  birthFlag := false;
  IdleTime := 0;
end;

function TICQcontact.getGMT: TdateTime;
begin result := -GMThalfs/48 end;

function TICQcontact.GMTavailable: boolean;
begin result := abs(GMThalfs)<>100 end;

function TICQcontact.isOnline: Boolean;
begin
  result := not (status in [ICQConsts.SC_OFFLINE, ICQConsts.SC_UNK])
end;

function TICQcontact.isAcceptFile: Boolean;
begin
  Result :=
 {$IFDEF usesDC}
    (CAPS_sm_FILE_TRANSFER in capabilitiesSm);
 {$else not usesDC}
        false;
 {$ENDIF  usesDC}
end;

function TICQcontact.isInvisible: Boolean;
begin
  result := //(status in [SC_OFFLINE, SC_UNK])
//   and
   (invisibleState > 0);
end;

function TICQcontact.isOffline: Boolean;
begin
  result := status = ICQConsts.SC_OFFLINE;
end;

function TICQcontact.canEdit: Boolean;
begin
  result := CntIsLocal or
 {$IFDEF UseNotSSI}
    ((fProto is TicqSession) and
      not TicqSession(fProto).usessi) or
//    icq.useSSI and
 {$ENDIF UseNotSSI}
     fProto.isOnline;
end;

procedure TICQcontact.SetDisplay(const s: String);
begin
  Inherited;
//  fDisplay := s;  // This in inherited
 {$IFDEF UseNotSSI}
  if TICQSession(fProto).useSSI then
 {$ENDIF UseNotSSI}
    TICQSession(fProto).SSI_UpdateContact(self);
end;

procedure TICQcontact.ViewInfo;
var
  vi: TRnQViewInfoForm;
begin
  begin
   vi := findViewInfo(self);
   if vi = NIL then
    try
      TviewinfoFrm.doAll(RnQmain, self)
     except
    end
   else
    vi.bringToFront;
  end;
end;

function TICQcontact.uinAsStr: string;
begin
  result := String(uid)
end;

function TICQcontact.uin2Show: string;
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

function TICQcontact.getStatusName: String;
var
  s1: String;
begin
  s1 := '';
  if fProto.isOnline then
   begin
    if xStatusStr > '' then
      s1 := xStatusStr
     else
      if xStatusDesc > '' then
        s1 := xStatusDesc
       else
        if ICQ6Status > '' then
          s1 := ICQ6Status
   end;
  if (s1 > '') then
    if status <> ICQConsts.SC_ONLINE then
       result := getTranslation(status2ShowStr[status]) +' ('+ s1 +')'
     else
       result := s1
   else
    result := getTranslation(status2ShowStr[status]);
end;

function TICQcontact.statusImg: TPicName;
begin
//  result := status2ImgName(byte(status), invisible);
  if XStatusAsMain and (xStatus > 0) then
    Result := XStatusArray[xStatus].PicName
   else
    begin
     result := status2imgName(byte(status), invisible);
    end;
end;

function TICQcontact.getStatus: byte;
begin
  result := byte(status);
end;

class function TICQcontact.trimUID(const sUID: TUID): TUID;
var
  i: word;
  t: word;
//  pp: PAnsiChar;
  ch: TUID_Char;
  s1, s2: TUID;
  isAIM: Boolean;
begin
  result := '';
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

procedure TICQcontact.AddInterest(idx: byte; code: Integer; str: String);
begin
  Interests.InterestBlock[idx].Code := code;
  if (Interests.InterestBlock[idx].Names <> NIL)
     AND Assigned(Interests.InterestBlock[idx].Names) then
     Interests.InterestBlock[idx].Names.Clear
    else
     Interests.InterestBlock[idx].Names:=TStringList.Create;
   while str<>'' do
     Interests.InterestBlock[idx].Names.Add(chop(',',str));
//                 Interests.InterestBlock[i].Count:=int.Count+1;
end;

function  TICQcontact.GetDBrow: RawByteString;
  function languages2str(l: Tlanguages): RawByteString;
  begin
    if (l[1] > 0)or(l[2] > 0)or(l[3] > 0) then
     begin
      setLength(result, 3);
      move(l, Pointer(result)^, 3);
     end
    else
      setLength(result, 0);
  end;

  Function interests2str(int: Tinterests): RawByteString;  // By Shyr
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
//      +TLV2(DBFK_COUNTRY, int2str(country))
      +TLV2_IFNN(DBFK_COUNTRY, integer(country))
      +TLV2_IFNN(DBFK_LANG, languages2str(lang))
      +TLV2U_IFNN(DBFK_HOMEPAGE, homepage)
      +TLV2U_IFNN(DBFK_REGULAR, regular)
      +TLV2U_IFNN(DBFK_CELLULAR, cellular)
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
      +TLV2U_IFNN(DBFK_ssMail, ssMail)
      +TLV2U_IFNN(DBFK_ssCell, ssCell)
      +TLV2U_IFNN(DBFK_ssCell2, ssCell2)
      +TLV2U_IFNN(DBFK_ssCell3, ssCell3)
//      +TLV2(DBFK_ICONSHOW, int2str(icon.ToShow))
      +TLV2(DBFK_ICONSHOW, integer(icon.ToShow))
      +TLV2_IFNN(DBFK_ICONMD5, Icon.hash_safe)
      +TLV2U_IFNN(DBFK_WORKPAGE, workpage)
      +TLV2U_IFNN(DBFK_WORKSTNT, workPos) // Должность
      +TLV2U_IFNN(DBFK_WORKDEPT, workDep) // Департамент
      +TLV2U_IFNN(DBFK_WORKCOMPANY, workCompany) // Компания
//      +TLV2(DBFK_WORKCOUNTRY, int2str(workCountry))
      +TLV2_IFNN(DBFK_WORKCOUNTRY, integer(workCountry))
      +TLV2U_IFNN(DBFK_WORKZIP, workzip)
      +TLV2U_IFNN(DBFK_WORKADDRESS, workaddress)
      +TLV2U_IFNN(DBFK_WORKPHONE, workphone)
      +TLV2U_IFNN(DBFK_WORKSTATE, workstate)
      +TLV2U_IFNN(DBFK_WORKCITY,  workcity)
      +TLV2_IFNN(DBFK_MARSTATUS, MarStatus)
      +TLV2_IFNN(DBFK_qippwd, crypt.qippwd)

      +TLV2_IFNN(DBFK_BIRTHCOUNTRY, integer(birthCountry))
      +TLV2U_IFNN(DBFK_BIRTHSTATE, birthstate)
      +TLV2U_IFNN(DBFK_BIRTHCITY, birthcity)
end;

function TICQcontact.ParseDBrow(ItemType: Integer; const item: RawByteString): Boolean;
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
//        cntICQ := TICQcontact(c);
        case ItemType of
          DBFK_EMAIL:   self.email := UnUTF(item);
          DBFK_ADDRESS: self.address := UnUTF(item);
          DBFK_CITY:    self.city := UnUTF(item);
          DBFK_STATE:   self.state := UnUTF(item);
          DBFK_ABOUT:   self.about := UnUTF(item);
          DBFK_ZIP:     self.zip  := UnUTF(item);
          DBFK_NODB:    self.nodb := boolean(item[1]);
          DBFK_COUNTRY: system.move(item[1], self.country, 4);
          DBFK_LANG:    system.move(item[1], self.lang, 3);
          DBFK_HOMEPAGE:    self.homepage := UnUTF(item);
          DBFK_CELLULAR:    self.cellular := UnUTF(item);
          DBFK_REGULAR:     self.regular := UnUTF(item);
          DBFK_IP:          system.move(item[1], self.connection.ip, 4);
          DBFK_AGE:         system.move(item[1], self.age, 4);
          DBFK_GMT:         system.move(item[1], self.GMThalfs, 1);
          DBFK_GENDER:      system.move(item[1], self.gender, 4);
          DBFK_LASTUPDATE:  system.move(item[1], self.infoUpdatedTo, 8);
          DBFK_LASTONLINE:  system.move(item[1], self.lastTimeSeenOnline, 8);
          DBFK_LASTMSG:     system.move(item[1], TCE(self.data^).lastMsgTime, 8);
          DBFK_ONLINESINCE: system.move(item[1], self.onlinesince, 8);
          DBFK_MEMBERSINCE: system.move(item[1], self.membersince, 8);
          DBFK_LASTINFOCHG: system.move(item[1], self.lastInfoUpdate, 8);
          DBFK_SMSABLE:     self.smsable := boolean(item[1]);
          DBFK_INTERESTS:   str2interests(item, self.interests);
          DBFK_WORKPAGE:    self.workpage := UnUTF(item);
          DBFK_WORKSTNT:    self.workPos  := UnUTF(item); // Должность
          DBFK_WORKDEPT:    self.workDep  := UnUTF(item); // Департамент
          DBFK_WORKCOMPANY: self.workCompany := UnUTF(item); // Компания
          DBFK_WORKCOUNTRY: system.move(item[1], self.workCountry, 4);
          DBFK_WORKZIP:     self.workzip := UnUTF(item);
          DBFK_WORKADDRESS: self.workaddress := UnUTF(item);
          DBFK_WORKPHONE:   self.workphone := UnUTF(item);
          DBFK_WORKSTATE:   self.workstate := UnUTF(item);
          DBFK_WORKCITY :   self.workcity  := UnUTF(item);

          DBFK_BIRTHCOUNTRY: system.move(item[1], self.birthCountry, 4);
          DBFK_BIRTHSTATE:   self.birthstate := UnUTF(item);
          DBFK_BIRTHCITY :   self.birthcity  := UnUTF(item);

          DBFK_ssNoteStr:   self.ssImportant := UnUTF(item);
          DBFK_ssMail:      self.ssMail := UnUTF(item);
          DBFK_ssCell:      self.ssCell := UnUTF(item);
          DBFK_ssCell2:     self.ssCell2 := UnUTF(item);
          DBFK_ssCell3:     self.ssCell3 := UnUTF(item);
          DBFK_ICONMD5:     self.Icon.hash_safe := item;
          DBFK_MARSTATUS:   self.MarStatus := str2int(item);
          DBFK_qippwd:      self.crypt.qippwd := str2int(item);
         else
          Result := inherited ParseDBrow(ItemType, item);
        end;
end;


{operator TICQcontact.Implicit(a: AnsiString): TContact; // Implicit conversion of an Integer to type TMyClass
begin
  result := TICQcontact.create(a);
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
   if Assigned(c)and (c is TICQContact) then
    if TICQContact(c).SSIID = ssid then
     break;
  until Result < cl.count;
  if Result >= cl.count then
    Result := -1;
//result:=-1;
end;

procedure ICQCL_SetStatus(cl: TRnQCList; st: TICQstatus);
var
  i: integer;
  cnt: TRnQContact;
begin
  for i:=0 to cl.count-1 do
   begin
    cnt := cl.getAt(i);
    if cnt is TICQContact then
      TICQContact(cnt).status := st;
   end;
end; // setStatus

function ICQCL_SSIByGrp(cl: TRnQCList; grID: Integer): AnsiString;
var
  i: integer;
begin
  result := '';
  for i:=0 to cl.count-1 do
//   with TICQContact(cl.items[i]) do
   with TICQContact(cl.getAt(i)) do
   if (group = grID)and (not CntIsLocal) and (SSIID > 0) then
    result := result + word_BEasStr(SSIID);
end;

function ICQCL_C8SSIByGrp(cl: TRnQCList; grID: Integer): AnsiString;
begin
  result := TLV($C8, ICQCL_SSIByGrp(cl, grID));
end;

end.
