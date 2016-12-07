{
This file is part of R&Q.
Under same license
}
unit history;
{$I RnQConfig.inc}
{$I NoRTTI.inc}

interface

uses
  Windows, classes, events, sysutils, graphics,
  RDGlobal,
  RnQDialogs, RnQProtocol;

const
  CRYPT_SIMPLE = 0;
  CRYPT_KEY1 = 1;
type
  Thistory = class(Tlist)
   private
    loading   : boolean;
    cryptMode : byte;
    hashed    : RawByteString;
 {$IFDEF DB_ENABLED}
    function  FromDB(cnt: TRnQContact): Int64;
 {$ELSE ~DB_ENABLED}
    function  fromStream(str: Tstream; quiet: Boolean = false): boolean;
 {$ENDIF ~DB_ENABLED}
   public
    fLoaded   : boolean;
    fToken    : Cardinal;
    themeToken, SmilesToken: Integer;

//    destructor Destroy; override;
    function  toString: RawByteString; reIntroduce;
    function  getAt(idx: integer): Thevent;
    function  getByID(pID: int64): Thevent;
    function  getByTime(time: TDateTime): Thevent;
    function  getIdxBeforeTime(time: TDateTime; inclusive: Boolean = True): Integer;
    class function UIDHistoryFN(UID: TUID): String;
    procedure reset;
//    function Clear;
    procedure deleteFromTo(const uid: TUID; st, en: integer);
    procedure deleteFromToTime(const uid: TUID; const st, en: TDateTime);
//    function  load(uid: AnsiString; quite: Boolean = false): boolean;
    function  load(cnt: TRnQContact; const quiet: Boolean = false): boolean;
//    function  RepaireHistoryFile(fn: String; var rslt: String): Boolean;
     property Token: Cardinal read fToken;
     property loaded: boolean read fLoaded;
   protected
    procedure Notify(Ptr: Pointer; Action: TListNotification); OverRide;
   private
//    function  RepaireHistoryStream(str: TMemoryStream; var rslt: String): boolean;
//    function  fromString(s: AnsiString; quite: Boolean = false): boolean;
   end; // Thistory

  function  DelHistWith(uid: TUID): Boolean;
  function  ExistsHistWith(uid: TUID): Boolean;

procedure writeHistorySafely(ev: Thevent; other: TRnQContact=NIL);
procedure flushHistoryWritingQ;

 {$IFDEF DB_ENABLED}
   procedure InitRnQBase;
 {$ENDIF ~DB_ENABLED}

implementation

uses
  DateUtils, AnsiStrings,
  RDFileUtil, RnQBinUtils,
  RQUtil, RnQLangs, RDUtils,
 {$IFDEF DB_ENABLED}
  RnQDB,
//  SQLite3,
//  SQLite3Commons, SynCommons,
  RnQ2SQL, ASGSQLite3Api,
 {$ENDIF DB_ENABLED}
  utilLib, globalLib;

const
  Max_Event_ID = 1000000;

class function Thistory.UIDHistoryFN(UID: TUID): String;
begin
  Result := Account.ProtoPath + historyPath + String(UID);
end;

//function Thistory.load(uid:AnsiString; quite : Boolean = false):boolean;
function Thistory.load(cnt: TRnQContact; const quiet: Boolean = false): boolean;
 {$IFNDEF DB_ENABLED}
var
  str: TStream;
  memstream: TMemoryStream;
 {$ENDIF ~DB_ENABLED}
begin
 {$IFDEF DB_ENABLED}
    FromDB(cnt);
    Result := True;
 {$ELSE ~DB_ENABLED}
//  Result :=  fromString(loadFile(userPath+historyPath + uid), quite);
  str := GetStream(UIDHistoryFN(cnt.UID2cmp));
  if Assigned(str)  then
   begin
    str.Position := 0;
//    Result :=  fromSteam(str, quite);
    memstream := TMemoryStream.Create;
    memstream.CopyFrom(str, str.Size);
    memstream.Position := 0;
    FreeAndNil(str);
    Result :=  fromStream(memstream, quiet);
    FreeAndNil(memstream);
   end
  else
   Result :=  fromStream(nil, quiet);
 {$ENDIF ~DB_ENABLED}
end;

procedure Thistory.Notify(Ptr: Pointer; Action: TListNotification);
begin
  inherited;
  if (Action = lnDeleted)and (Ptr <> NIL) then
    Thevent(Ptr).Free;
end;

{
destructor Thistory.Destroy;
begin
  clear;
  inherited;
end;
}

 {$IFDEF DB_ENABLED}
function Thistory.FromDB(cnt: TRnQContact): Int64;
var
//  Stmt: TDISQLite3Statement;
//  Stmt: TSQLiteStmt;
  stmt: sqlite3_stmt_ptr;
  ev: Thevent;
  whom, from: AnsiString;
//  sql : String;
  sql: AnsiString;
  ss: AnsiString;
  Tail: PAnsiChar;
  resU8: PUTF8Char;
//  cnt: TRnQContact;
  i: Integer;
  biLen: Integer;
  Rows: Int64;
  isMyHist: Boolean;
begin
  loading := True;
  Rows := 0;
  cryptMode := CRYPT_SIMPLE;
//  cnt := p
 try
   isMyHist := cnt.fProto.getMyInfo.equals(cnt);
   if isMyHist then
     sql := SQLSelectSelfHistory
    else
//     sql := Format(SQLSelectHistoryWith, [cnt.uid2cmp, cnt.uid2cmp]);
//     sql := StringReplace(SQLSelectHistoryWith, '?1', cnt.uid2cmp, [rfReplaceAll]);
     sql := SQLSelectHistoryWith;
//   i := SQLite3_Prepare16_v2(MineDB, PWideChar(sql), (Length(sql)) * 2, Stmt, Tail);
//   i := SQLite3_Prepare16_v2(MineDB, PWideChar(sql), (Length(sql)) * 2, @Stmt, @Tail);
//   i := SQLite3_Prepare16_v2(MineDB, PWideChar(sql), (Length(sql)) shl 1, @Stmt, @Tail);
//   i := sqlite3_prepare_v2(MineDB, PAnsiChar(sql), Length(sql), @Stmt, @Tail);
   i := sqlite3_prepare_v2(histDB, Putf8Char(sql), Length(sql), Stmt, Putf8Char(Tail));
//    Stmt := MineDB.Prepare16(sql);
   if Stmt <> NIL then
//   if Stmt <> 0 then
    try
     if not isMyHist then
      begin
        ss := StrToUTF8(cnt.uid2cmp);
//        sqlite3_bind_str(stmt, 1, ss);
        sqlite3_bind_text(stmt, 1, Putf8Char(ss), Length(ss), NIL);
//        sqlite3_bind_text(stmt, 2, PAnsiChar(ss), Length(ss), NIL);
      end;
//       sqlite3_bind_str16(stmt, 1, cnt.uid2cmp);
      { Step through all records in the result set and
        add them to the string list. }
//      i := Sqlite3_Step(Stmt);
//      while i = SQLITE_ROW do
      while Sqlite3_Step(Stmt) = SQLITE_ROW do
        begin
            ev := Thevent.create;
            ev.ID := Max_Event_ID;
          //  ev.fpos:=cur-1;
          //  ev.fpos:= str.Position;
//            ev.fpos := 0;
            ev.cryptMode := cryptMode;
//            ev.when := Stmt.Column_Double(1);
//            ev.kind := Stmt.Column_Bytes(6);
//            ev.when  := JulianDateToDateTime(Sqlite3_ColumnDouble(Stmt, 0)); // TIME
            if not TryJulianDateToDateTime(Sqlite3_Column_Double(Stmt, 0),ev.when) then
              ev.when := 0;
            ev.kind  := Sqlite3_Column_Int(Stmt, 5);
            ev.flags := Sqlite3_Column_Int(Stmt, 6);
             i := Sqlite3_Column_Int(Stmt, 1); // ISSEND
            ev.fIsMyEvent := i = 1;
//            from := Stmt.Column_Str(4);
//            whom := Stmt.Column_Str(5);
            from := Sqlite3_Column_Text(Stmt, 3);
            whom := Sqlite3_Column_Text(Stmt, 4);

{            if i = 1 then
              ss := whom
             else
              ss := from;}
            ss := from;
            if cnt.equals(ss) then
               ev.who := cnt
            else
            if cnt.fProto.getMyInfo.equals(ss) then
               ev.who := cnt.fProto.getMyInfo
             else
               ev.who := cnt.fProto.getContact(ss);

//            ev.info := Stmt.Column_Text(8);
//            ev.binfo := Sqlite3_ColumnText(Stmt, 7);
            biLen := sqlite3_column_bytes(Stmt, 7);
            SetLength(ev.fBin, biLen);
            if biLen > 0 then
              CopyMemory(@ev.fBin[1], Sqlite3_Column_Blob(Stmt, 7), biLen);
//            ev.binfo := PAnsiChar(Sqlite3_Column_Blob(Stmt, 7));
//            ev.txt   := sqlite3_column_text16(Stmt, 8);
            resU8 := sqlite3_column_text(Stmt, 8);
            ev.txt   := UTF8ToString(resU8);
{
          if Length(s) > 0 then
          if Assigned(thisCnt) and thisCnt.equals(s) then
            ev.who       := thisCnt
           else
          if MainProto.getMyInfo.equals(s) then
            ev.who       := MainProto.getMyInfo
           else
              begin
                 thisCnt := MainProto.getContact(s);
                 ev.who  := thisCnt;
              end;
                  begin
                  if Assigned(thisCnt) and thisCnt.equals(i) then
                    begin
                      inc(Cnt1I);
                      ev.who := thisCnt
                    end
                   else
                  if MainProto.getMyInfo.equals(i) then
                    ev.who       := MainProto.getMyInfo
                   else
                  if Assigned(thisCnt2) and thisCnt2.equals(i) then
                    begin
                      inc(Cnt2I);
                      ev.who       := thisCnt2
                    end
                   else
                        begin
                         if not Assigned(thisCnt) or
                            (Assigned(thisCnt2) and (Cnt2I > Cnt1I)) then
                           begin
                            Cnt1I := 0;
                            thisCnt := MainProto.getContact(IntToStr(i));
                            ev.who  := thisCnt;
                           end
                          else
                           begin
                            Cnt2I := 0;
                            thisCnt2 := MainProto.getContact(IntToStr(i));
                            ev.who  := thisCnt2;
                           end
                        end
                  end
                else
                 begin
        //           thisCnt := NIL;
                   ev.who  := MainProto.getMyInfo;
                 end
}
          add(ev);
          inc(Rows);
//          i := Sqlite3_Step(Stmt);
        end;
    finally
//      Stmt.Free;
      if sqlite3_finalize(stmt) <> SQLITE_OK then
        ;
    end;
 finally
  loading := false;
  Result := Rows;
 end;
end;

 {$ELSE ~DB_ENABLED}
function Thistory.fromStream(str: Tstream; quiet: Boolean = false): boolean;
var
  ev: Thevent;
  thisCnt, thisCnt2: TRnQcontact;
  Cnt1I, Cnt2I: Int64;
//  cur:integer;

  function getByte: byte;
  begin
    str.Read(result, 1);
//    inc(cur)
  end;

  function getDatetime: Tdatetime;
  begin
    str.Read(result, 8);
//    inc(cur,8)
  end;

  function getInt: integer;
  begin
    str.Read(result, 4);
//    inc(cur,4);
  end;

  function getString: RawByteString;
  var
    i: Integer;
  begin
    i := getInt;
    SetLength(Result, i);
    str.Read(result[1], i);
//    inc(cur,length(result))
  end;

{  function getInt1(str1: Tstream): integer; Inline;
  begin
    str1.Read(result, 4);
  end;
  function getByte1(str1: Tstream): byte; Inline;
  begin
    str1.Read(result, 1);
  end;
  function getDatetime1(str1: Tstream): Tdatetime; Inline;
  begin
    str1.Read(result, 8);
  end;
  function getString1(str1: Tstream): string; Inline;
  var
    i: Integer;
  begin
    i := getInt1(str1);
    SetLength(Result, i);
    str1.Read(result[1], i);
  end;
}


{  procedure parseExtrainfo;
  var
    code, next, extraEnd: integer;
  begin
  extraEnd := cur+getInt;
  while cur < extraEnd do
    begin
    code := getInt;
    next := cur+getInt;
    case code of
      EI_flags: ev.flags := getInt;
      end;
    cur := next;
    end;
  end; // parseExtraInfo
}
  procedure parseExtrainfo;
  var
    code, next, extraEnd: integer;
    cur: Integer;
    s: RawByteString;
    len: Integer;
    uid: TUID;
  begin
    cur := 1;
    extraEnd := 4+getInt;
    inc(cur, 4);
    while cur < extraEnd do
     begin
      code := getInt;
      inc(cur, 4);
  //    inc(cur, 4);
      len := getInt;
      next := cur + len + 4;
      case code of
        EI_flags:
          begin
           ev.flags := getInt;
  //         inc(cur, 4);
          end;
        EI_UID:
          begin
  //          s := str.re
      {$IFDEF UID_IS_UNICODE}
            uid := UnUTF(getString);
      {$ELSE ansi}
            uid := getString;
      {$ENDIF UID_IS_UNICODE}
            if Length(uid) > 0 then
            if Assigned(thisCnt) and thisCnt.equals(uid) then
              ev.who       := thisCnt
             else
            if Account.AccProto.getMyInfo.equals(uid) then
              ev.who       := Account.AccProto.getMyInfo
             else
                begin
                   thisCnt := Account.AccProto.getContact(uid);
                   ev.who  := thisCnt;
                end;
          end;
        EI_WID:
          begin
            SetLength(s, len);
            str.Read(s[1], len);
          end;
       end;
      cur := next;
     end;
  end; // parseExtraInfo
var
  len: Int64;
//  iu : TUID;
  i: Integer;
  curPos: Int64;
begin
  loading := True;
 try
//  cur:=1;
  cryptMode := CRYPT_SIMPLE;
  hashed := '';
  Cnt2I := 0;
  Cnt1I := 0;
  if not Assigned(str) then
    begin
      fLoaded := True;
      result := True;
      exit;
    end;
  len := str.Size;
  thisCnt := NIL;
  thisCnt2 := NIL;
  str.Seek(0, 0);
  curPos := 0;
//while str.Position < len do
  if len > 0 then
  repeat
  begin
  ev := Thevent.create;
  ev.ID := Max_Event_ID;
//  ev.fpos:=cur-1;
//  ev.fpos:= str.Position;
  ev.fpos := curPos;
  case getInt of
//  case getInt1(str) of
    HI_event:
      begin
      ev.cryptMode := cryptMode;
      ev.kind      := getByte;
      begin
//        iu := IntToStr(getInt);
        i := getInt;
        if i > 0 then
          begin
          if Assigned(thisCnt) and thisCnt.equals(i) then
            begin
              inc(Cnt1I);
              ev.who := thisCnt
            end
           else
          if Account.AccProto.getMyInfo.equals(i) then
            ev.who       := Account.AccProto.getMyInfo
           else
          if Assigned(thisCnt2) and thisCnt2.equals(i) then
            begin
              inc(Cnt2I);
              ev.who       := thisCnt2
            end
           else
                begin
                 if not Assigned(thisCnt) or
                    (Assigned(thisCnt2) and (Cnt2I > Cnt1I)) then
                   begin
                    Cnt1I := 0;
                    thisCnt := Account.AccProto.getContact(i);
                    ev.who  := thisCnt;
                   end
                  else
                   begin
                    Cnt2I := 0;
                    thisCnt2 := Account.AccProto.getContact(i);
                    ev.who  := thisCnt2;
                   end
                end
          end
        else
         begin
//           thisCnt := NIL;
           ev.who  := Account.AccProto.getMyInfo;
         end
      end;
      ev.when      := getDatetime;
      parseExtrainfo;
      ev.f_info      := getString;
//      ev.parseInfo(getString);
      add(ev);
      end;
    HI_hashed: hashed := getString;
    HI_cryptMode:
      begin
//      getInt; // skip length
         str.Seek(4, soFromCurrent); // skip length
       cryptMode    := getByte;
      end;
    else
      begin
       if not quiet then
         msgDlg('The history is corrupted, some data is lost', True, mtError);
       result := FALSE;
       fLoaded := TRUE;
       exit;
      end;
    end;
  end;
  curPos := str.Position;
  until (curPos >=len);
  fLoaded := TRUE;
  result := TRUE;
 finally
   loading := false;
 end;
end; // fromStream
 {$ENDIF ~DB_ENABLED}

  procedure addStr(var dim: Integer; const s: RawByteString; var Res: RawByteString);
  begin
    while dim+length(s) > length(Res) do
      setLength(Res, length(Res)+10000);
    system.move(s[1], Res[dim+1], length(s));
    inc(dim, length(s));
  end; // addStr

function Thistory.toString: RawByteString;
var
  i, dim: integer;
begin
  result := '';
  dim := 0;

  if histcrypt.enabled then
    addStr(dim, TLV2(HI_cryptMode, AnsiChar(cryptMode))
       + TLV2(HI_hashed, hashed), Result );
  i := 0;
  while i < count do
   begin
    addStr(dim, getAt(i).toString, Result);
    inc(i);
   end;
  setLength(result, dim);
end; // toString

function Thistory.getAt(idx: integer): Thevent;
begin
  if (idx >= 0) and (idx < count) then
    result := Thevent(items[idx])
   else
    result := NIL
end; // getAt

procedure Thistory.reset;
//var
//  i: integer;
begin
  fLoaded := FALSE;
  loading := True;
//  i := 0;
  Clear;
{  while i < count do
    begin
    Thevent(items[i]).free;
    inc(i);
    end;
  clear;}
  fToken := 101;
  loading := False;
end; // reset

function  Thistory.getByID(pID: Int64): Thevent;
var
  i: integer;
begin
  i := Count-1;
  Result := NIL;
  while i >= 0 do
   with Thevent(items[i]) do
   begin
    if ID = pID then
      begin
       Result := Thevent(items[i]);
       break;
      end
     else
      if ID = Max_Event_ID then
        Exit;
    dec(i);
   end;
end;

function Thistory.getByTime(time: TDateTime): Thevent;
var
  i: integer;
begin
  i := count - 1;
  Result := nil;
  while i >= 0 do
    with Thevent(items[i]) do
    begin
      if CompareDateTime(when, time) = 0 then
      begin
        Result := Thevent(items[i]);
        Break;
      end;
      dec(i);
    end;
end;

function Thistory.getIdxBeforeTime(time: TDateTime; inclusive: Boolean = True): Integer;
var
  i: integer;
begin
  i := count - 1;
  Result := -1;
  while i >= 0 do
    with Thevent(items[i]) do
    begin
      if CompareDateTime(when, time) < 0 then
      begin
        if inclusive then
          Result := i
        else
          Result := i + 1;
        Break;
      end;
      dec(i);
    end;
end;

procedure Thistory.deleteFromTo(const uid: TUID; st, en: integer);
var
  i: integer;
  hev: Thevent;
  fn: String;
  l: Integer;
begin
 {$IFDEF DB_ENABLED}
 {$ELSE ~DB_ENABLED}
  i := st;
  while (st>=en) and (getAt(en) <> NIL)and(getAt(en).fpos < 0) do
    dec(en);
  fn := UIDHistoryFN(uid);
  while i <= en do
    begin
    if getAt(i).fpos < 0 then
      begin
      if i > st then
      begin
        hev := getAt(i - 1);
        if (hev.fpos >= 0) then
         begin
           if hev.fLen > 0 then
             l := hev.fLen
            else
             l := length(hev.toString);
           utilLib.deleteFromTo(fn, getAt(st).fpos, hev.fpos + l);
         end;
      end;
      st := i+1;
      end;
    inc(i);
    end;
  if st > en then
    exit;
  hev := getAt(en);
  if (hev.fpos >= 0) then
   begin
     if hev.fLen > 0 then
       l := hev.fLen
      else
       l := length(hev.toString);
     utilLib.deleteFromTo(fn, getAt(st).fpos, hev.fpos + l);
   end;

  reset;
//      Clear;
//   fromString(loadFile(fn));
  load(Account.AccProto.getContact(uid))
{
for i:=en downto st do
  begin
  Thevent(items[i]).free;
  delete(i);
  end;
}
 {$ENDIF ~DB_ENABLED}
end; // deleteFromTo

procedure Thistory.deleteFromToTime(const uid: TUID; const st, en: TDateTime);
var
  hevst, heven: Thevent;
  fn: String;
  l: Integer;
begin
{$IFDEF DB_ENABLED}
{$ELSE ~DB_ENABLED}
  hevst := getByTime(st);
  heven := getByTime(en);
  if (hevst = nil) or (heven = nil) then
    Exit;
  fn := UIDHistoryFN(uid);

  if (heven.fpos >= 0) then
   begin
     if heven.fLen > 0 then
       l := heven.fLen
      else
       l := length(heven.toString);
     utilLib.deleteFromTo(fn, hevst.fpos, heven.fpos + l);
   end;


  Reset;
  Load(Account.AccProto.getContact(uid))
{$ENDIF ~DB_ENABLED}
end; // deleteFromTo

function DelHistWith(uid: TUID): Boolean;
begin
 {$IFDEF DB_ENABLED}
    ExecSQL(protoDB, Format(SQLDeleteHistoryWith, [uid, uid]));
 {$ELSE ~DB_ENABLED}
    if FileExists(Thistory.UIDHistoryFN(UID)) then
      Result := DeleteFile(Thistory.UIDHistoryFN(UID))
     else
 {$ENDIF ~DB_ENABLED}
      Result := False;
end;

{
function Thistory.RepaireHistoryStream(str: TMemoryStream; var rslt: String): boolean;
var
  ev: Thevent;
//  cur: integer;

  function getByte: byte;
  begin
    str.Read(result, 1);
//    inc(cur)
  end;
  function getDatetime: Tdatetime;
  begin
//    result:=Tdatetime((@s[cur])^);
    str.Read(result, 8);
//    inc(cur,8)
  end;
  function getInt: integer;
  begin
//    result:=integer((@s[cur])^);
    str.Read(result, 4);
//    inc(cur,4);
  end;
  function getString: string;
  var
    i: Integer;
  begin
//    result := copy(s,cur,getInt); inc(cur,length(result))
    i := getInt;
    SetLength(Result, i);
    str.Read(result[1], i);
  end;

  procedure parseExtrainfo;
  var
    code, next, extraEnd: integer;
    cur: Integer;
  begin
    cur := 1;
    extraEnd := getInt;
    inc(cur, 4);
  while cur < extraEnd do
    begin
    code := getInt;
    inc(cur, 4);
    next := cur+getInt;
    case code of
      EI_flags:
        begin
         ev.flags := getInt;
//         inc(cur, 4);
        end;
      EI_UID:
        begin
          ev.who := MainProto.getContact(getString);
        end;
      end;
    cur := next;
    end;
  end; // parseExtraInfo
var
  len: Int64;
//  iu: TUID;
  i: Integer;
  thisCnt: TRnQcontact;
begin
//  cur := 1;
  cryptMode := CRYPT_SIMPLE;
  hashed := '';
  if not Assigned(str) then
    begin
      loaded := True;
      result := True;
      exit;
    end;
  len := str.Size;
  thisCnt := NIL;
  str.Seek(0, 0);
while str.Position < len do
  begin
  ev:=Thevent.create;
//  ev.fpos:=cur-1;
  ev.fpos:= str.Position;
  case getInt of
    HI_event:
      begin
      ev.cryptMode := cryptMode;
      ev.kind      := getByte;
      begin
//        iu := IntToStr(getInt);
        i := getInt;
        if Assigned(thisCnt) and thisCnt.equals(i) then
          ev.who       := thisCnt
         else
          if MainProto.MyInfo.equals(i) then
            ev.who       := MainProto.MyInfo
           else
            if i > 0 then
              begin
               thisCnt := MainProto.getContact(IntToStr(i));
               ev.who  := thisCnt;
              end
             else
              begin
               thisCnt := NIL;
               ev.who  := thisCnt;
              end
      end;
      ev.when      := getDatetime;
      parseExtrainfo;
      ev.info      := getString;
      add(ev);
      end;
    HI_hashed: hashed:=getString;
    HI_cryptMode:
      begin
      getInt; // skip length
      cryptMode    := getByte;
      end;
    else
      begin
//       if not quite then
//         msgDlg(getTranslation('The history is corrupted, some data is lost'),mtError);
       result:=FALSE;
//       exit;
      end;
    end;
  end;
loaded:=TRUE;
result:=TRUE;
end;

function Thistory.RepaireHistoryFile(fn : String; var rslt : String) : Boolean;
var
  str : TStream;
  memstream : TMemoryStream;
begin
  rslt := logtimestamp + getTranslation('Begin repaire file "%s"', [fn]);

  str := GetStream(fn);
  if Assigned(str)  then
   begin
    str.Position := 0;
  //  Result :=  fromSteam(str, quite);
    memstream := TMemoryStream.Create;
    memstream.CopyFrom(str, str.Size);
    memstream.Position := 0;
    FreeAndNil(str);

    result := RepaireHistoryStream(memstream, rslt);
//    Result :=  fromSteam(memstream, quite);
    FreeAndNil(memstream);
   end;
  rslt := rslt+crlf+ logtimestamp + getTranslation('End of repaire file "%s"', [fn]);
  Result := True;
end;
}


var
  writingQ:Tlist;

procedure writeHistorySafely(ev: Thevent; other: TRnQContact=NIL);
begin
  ev := ev.clone;
  if other<>NIL then
    ev.otherpeer := other;
  if ev.otherpeer=NIL then
    ev.otherpeer := ev.who;
  writingQ.add(ev)
end; // addToHistoryWritingQ


 {$IFDEF DB_ENABLED}

procedure flushHistoryWritingQ;
var
//  InsHistStmt: TDISQLite3Statement;
//  Stmt: TSQLiteStmt;
  Stmt: sqlite3_stmt_ptr;

  function InsertHist(ev: Thevent): Boolean;
  var
    sel, sub: string;
    msg: RawByteString;
    inf: AnsiString;
    I: Integer;
    ISSEND, im: byte;
    whom, from: AnsiString;
  begin
   Result := false;
   sub := '';
   sel := '';
      try
//       for I := 0 to Length(Fields) - 1 do
        begin
         msg := StrToUTF8(ev.txt);
         inf := ev.fBin;

//         InsHistStmt.Bind_Double(1, DateTimeToJulianDate(ev.when));
//         sqlite3_bind_Double(stmt, DateTimeToJulianDate(ev.when));
//         sqlite3_bind_Double(stmt, 1, Double(ev.when));
         with ev.who.fProto do
          begin
           if ev.isMyEvent then
             begin
               whom := StrToUTF8(ev.otherpeer.UID2cmp);
               from := StrToUTF8(getMyInfo.UID2cmp);
               ISSEND := 1;
             end
            else
             begin
               whom := StrToUTF8(getMyInfo.UID2cmp);
               from := StrToUTF8(ev.who.UID2cmp);
               ISSEND := 0;
             end;
           im := ProtoElem.ProtoID -1;
          end;


//         InsHistStmt.Bind_Int(2, ISSEND);
//         InsHistStmt.Bind_Int(3, im);
//         InsHistStmt.Bind_Str(4, from);
//         InsHistStmt.Bind_Str(5, whom);
//         InsHistStmt.Bind_Int(6, ev.kind);
//         InsHistStmt.Bind_Int(7, ev.flags);
//         InsHistStmt.Bind_Str(8, inf);
//         InsHistStmt.Bind_Str(9, msg);

         sqlite3_bind_Double(stmt, 1, DateTimeToJulianDate(ev.when));
         SQLite3_Bind_Int(stmt, 2, ISSEND);
         SQLite3_Bind_Int(stmt, 3, im);
         SQLite3_Bind_text(stmt, 4, Putf8Char(from), Length(from), nil);
         SQLite3_Bind_text(stmt, 5, Putf8Char(whom), Length(whom), nil);
         SQLite3_Bind_Int(stmt, 6, ev.kind);
         SQLite3_Bind_Int(stmt, 7, ev.flags);
//         SQLite3_Bind_text(stmt, 8, PAnsiChar(inf), Length(inf)+1, nil);
         SQLite3_Bind_Blob(stmt, 8, Putf8Char(inf), Length(inf), nil);
//         SQLite3_Bind_text16(stmt, 9, PWideChar(msg), (Length(msg))*2, nil);
         SQLite3_Bind_text(stmt, 9, Putf8Char(msg), Length(msg), nil);
//        Stmt.Bind_Str(1, Field);
//         case Fields[i].val_type of
//           1: Stmt.bind_Str(i+1, Fields[i].val1);
//           2: Stmt.bind_Int64(i+1, Fields[i].val2);
//           3: Stmt.Bind_Str(i+1, DateTimeToStr(Fields[i].val3));
//         end;

        end;
//       Stmt.bind_Int64(Length(Fields)+1, cntID);
//       if InsHistStmt.Step = SQLITE_ROW then
       i := Sqlite3_Step(stmt);
       if (i = SQLITE_ROW)or(i = SQLITE_DONE) then
         begin
           Result := True;
         end;
//       InsHistStmt.Reset;
       SQLite3_Reset(stmt);
      finally
//        FreeAndNil(Stmt);
      end;
//  finally
//    sqlite3_exec_fast(mineDB.Handle, 'COMMIT TRANSACTION');
//  end;
  end;

var
  ev: Thevent;
  i: Integer;
  sql: UTF8String;
  Tail: PAnsiChar;
begin
  if writingQ.count = 0 then
    Exit;

  execSQL(histDB, 'BEGIN TRANSACTION');
  sql := SQLInsertHistory;
//  try
//   InsHistStmt := mineDB.Prepare16(SQLInsertHistory);
//  i := SQLite3_Prepare16_v2(MineDB, PWideChar(SQLInsertHistory),  +1) * 2, Stmt, Tail);
//  i := SQLite3_Prepare_v2(MineDB, PAnsiChar(sql),  Length(sql), @Stmt, @Tail);
  i := SQLite3_Prepare_v2(histDB, PUTF8Char(sql),  Length(sql), Stmt, PUTF8Char(Tail));
  if Stmt <> NIL then
//  if Stmt <> 0 then
  while writingQ.count > 0 do
  begin
    ev:=writingQ.first;
    writingQ.delete(0);
    InsertHist(ev);
//    ev.appendToHistoryFile(ev.otherpeer.uid);
    ev.Free;
  end;
//  FreeAndNil(InsHistStmt);
  SQLite3_Finalize(stmt);
  execSQL(histDB, 'COMMIT TRANSACTION');
end; // flushHistoryWritingQ

 {$ELSE ~DB_ENABLED}

procedure flushHistoryWritingQ;
var
  ev: Thevent;
begin
  while writingQ.count > 0 do
   begin
    ev := writingQ.first;
    writingQ.delete(0);
    ev.appendToHistoryFile(ev.otherpeer.uid);
    ev.Free;
   end;
end; // flushHistoryWritingQ
 {$ENDIF ~DB_ENABLED}

function ExistsHistWith(uid: TUID): Boolean;
begin
 {$IFDEF DB_ENABLED}
  result := True;
 {$ELSE ~DB_ENABLED}
  Result := sizeoffile(Thistory.UIDHistoryFN(uid)) > 0;
 {$ENDIF ~DB_ENABLED}
end;

 {$IFDEF DB_ENABLED}
procedure InitRnQBase;
begin

 {$IFDEF PREF_IN_DB}
//  ExecSQL(MineDB, 'DROP TABLE CLIST_TYPES;');
  if ExecSQL(protoDB, SQLCreate_CLIST_TYPES) then
    ExecSQL(protoDB, SQLData_CLIST_TYPES);
  ExecSQL(protoDB, SQLCreate_SYS_CLISTS);
  ExecSQL(protoDB, SQLCreateAccountsTable);
  ExecSQL(protoDB, SQLCreateGroupsTable);
  ExecSQL(protoDB, SQLCreateExStsTable);
  ExecSQL(protoDB, SQLCreatePrefTable);
  ExecSQL(protoDB, SQLCreateProxiesTable);
  ExecSQL(protoDB, SQLCreateMacrosTable);

  ExecSQL(protoDB, 'COMMIT;');

 {$ENDIF PREF_IN_DB}

 {$IFDEF AVT_IN_DB}
//  if avtDB <> NIL then
  if avtDB <> 0 then
   begin
    ExecSQL(avtDB, SQLCreate_RnQ_AVT);
    ExecSQL(avtDB, 'COMMIT;');
   end;
 {$ENDIF AVT_IN_DB}

  ExecSQL(histDB, SQLCreateHistTable);
  ExecSQL(histDB, 'COMMIT;');


//  sqlite3_exec()
//  MineDB.Execute('SELECT name from sqlite_master where name="_info";');
//  sqlite3_open(historyDBFile, db);
    // check for original logs table
//    tmp := _db.getTable('SELECT name from sqlite_master where name="jlog_info";');
{  mineDB.StartTransaction(ttExclusive);
  mineDB.Execute(SQLCreateDBTable);
  mineDB.Execute(SQLCreateOscarDBTable);
  mineDB.Execute(SQLCreateDB2IMTable);
  mineDB.Execute(SQLCreateHistTable);
  mineDB.Commit;}
end;
 {$ENDIF ~DB_ENABLED}


INITIALIZATION

  writingQ := Tlist.create;

FINALIZATION
  writingQ.free;
  writingQ := NIL;

end.
