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
  CRYPT_SIMPLE=0;
  CRYPT_KEY1=1;
type
  Thistory=class(Tlist)
   private
    loading   : boolean;
    cryptMode : byte;
    hashed    : RawByteString;
    function  fromStream(str: Tstream; quite : Boolean = false):boolean;
   public
    loaded    :boolean;
    fToken, themeToken,SmilesToken : Cardinal;

//    destructor Destroy; override;
    function  toString: RawByteString;
    function  getAt(idx:integer):Thevent;
    function  getByID(pID: int64):Thevent;
    procedure reset;
//    function Clear;
    procedure deleteFromTo(uid: TUID; st,en:integer);
//    function  load(uid:AnsiString; quite : Boolean = false):boolean;
    function  load(cnt: TRnQContact; const quite : Boolean = false):boolean;
//    function  RepaireHistoryFile(fn : String; var rslt : String) : Boolean;
     property Token : Cardinal read fToken;
   protected
    procedure Notify(Ptr: Pointer; Action: TListNotification); OverRide;
   private
//    function  RepaireHistoryStream(str : TMemoryStream; var rslt : String) : boolean;
//    function  fromString(s:AnsiString; quite : Boolean = false):boolean;
   end; // Thistory

  function  DelHistWith(uid : TUID) : Boolean;
  function  ExistsHistWith(uid : TUID) : Boolean;

procedure writeHistorySafely(ev:Thevent; other:TRnQContact=NIL);
procedure flushHistoryWritingQ;

implementation

uses
  DateUtils, AnsiStrings,
  RDFileUtil, RnQBinUtils,
  RQUtil, RnQLangs,
  utilLib, globalLib;

const
  Max_Event_ID = 1000000;

//function Thistory.load(uid:AnsiString; quite : Boolean = false):boolean;
function Thistory.load(cnt: TRnQContact; const quite : Boolean = false):boolean;
 {$IFNDEF DB_ENABLED}
var
  str : TStream;
  memstream : TMemoryStream;
 {$ENDIF ~DB_ENABLED}
begin
//  Result :=  fromString(loadFile(userPath+historyPath + uid), quite);
  str := GetStream(Account.ProtoPath+historyPath + cnt.UID2cmp);
  if Assigned(str)  then
   begin
    str.Position := 0;
//    Result :=  fromSteam(str, quite);
    memstream := TMemoryStream.Create;
    memstream.CopyFrom(str, str.Size);
    memstream.Position := 0;
    FreeAndNil(str);
    Result :=  fromStream(memstream, quite);
    FreeAndNil(memstream);
   end
  else
   Result :=  fromStream(nil, quite);
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

function Thistory.fromStream(str:Tstream; quite : Boolean = false):boolean;
var
  ev:Thevent;
  thisCnt, thisCnt2 : TRnQcontact;
  Cnt1I, Cnt2I : Int64;
//  cur:integer;

  function getByte:byte;
  begin
    str.Read(result, 1);
//    inc(cur)
  end;

  function getDatetime:Tdatetime;
  begin
    str.Read(result, 8);
//    inc(cur,8)
  end;

  function getInt:integer;
  begin
    str.Read(result, 4);
//    inc(cur,4);
  end;

  function getString: RawByteString;
  var
    i : Integer;
  begin
    i := getInt;
    SetLength(Result, i);
    str.Read(result[1], i);
//    inc(cur,length(result))
  end;

{  function getInt1(str1 : Tstream):integer;Inline;
  begin
    str1.Read(result, 4);
  end;
  function getByte1(str1 : Tstream):byte; Inline;
  begin
    str1.Read(result, 1);
  end;
  function getDatetime1(str1 : Tstream):Tdatetime;Inline;
  begin
    str1.Read(result, 8);
  end;
  function getString1(str1 : Tstream):string;Inline;
  var
    i : Integer;
  begin
    i := getInt1(str1);
    SetLength(Result, i);
    str1.Read(result[1], i);
  end;
}


{  procedure parseExtrainfo;
  var
    code,next,extraEnd:integer;
  begin
  extraEnd:=cur+getInt;
  while cur < extraEnd do
    begin
    code:=getInt;
    next:=cur+getInt;
    case code of
      EI_flags: ev.flags:=getInt;
      end;
    cur:=next;
    end;
  end; // parseExtraInfo
}
  procedure parseExtrainfo;
  var
    code,next,extraEnd:integer;
    cur : Integer;
    s : AnsiString;
  begin
    cur := 1;
    extraEnd := 4+getInt;
    inc(cur, 4);
  while cur < extraEnd do
    begin
    code:=getInt;
    inc(cur, 4);
//    inc(cur, 4);
    next:=cur+ getInt + 4;
    case code of
      EI_flags:
        begin
         ev.flags:=getInt;
//         inc(cur, 4);
        end;
      EI_UID:
        begin
//          s := str.re
          s := getString;
          if Length(s) > 0 then
          if Assigned(thisCnt) and thisCnt.equals(s) then
            ev.who       := thisCnt
           else
          if Account.AccProto.getMyInfo.equals(s) then
            ev.who       := Account.AccProto.getMyInfo
           else
              begin
                 thisCnt := Account.AccProto.getContact(s);
                 ev.who  := thisCnt;
              end;
        end;
      end;
    cur:=next;
    end;
  end; // parseExtraInfo
var
  len : Int64;
//  iu : TUID;
  i : Integer;
  curPos : Int64;
begin
  loading := True;
 try
//  cur:=1;
  cryptMode:=CRYPT_SIMPLE;
  hashed:='';
  Cnt2I := 0;
  Cnt1I := 0;
  if not Assigned(str) then
    begin
      loaded := True;
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
  ev:=Thevent.create;
  ev.ID := Max_Event_ID;
//  ev.fpos:=cur-1;
//  ev.fpos:= str.Position;
  ev.fpos:= curPos;
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
                    thisCnt := Account.AccProto.getContact(IntToStr(i));
                    ev.who  := thisCnt;
                   end
                  else
                   begin
                    Cnt2I := 0;
                    thisCnt2 := Account.AccProto.getContact(IntToStr(i));
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
       if not quite then
         msgDlg('The history is corrupted, some data is lost', True, mtError);
       result := FALSE;
       loaded := TRUE;
       exit;
      end;
    end;
  end;
  curPos := str.Position;
  until (curPos >=len);
  loaded := TRUE;
  result := TRUE;
 finally
   loading := false;
 end;
end; // fromStream

  procedure addStr(var dim: Integer; const s: RawByteString; var Res: RawByteString);
  begin
    while dim+length(s) > length(Res) do
      setLength(Res, length(Res)+10000);
    system.move(s[1], Res[dim+1], length(s));
    inc(dim, length(s));
  end; // addStr

function Thistory.toString: RawByteString;
var
  i,dim: integer;
begin
  result:='';
  dim:=0;

  if histcrypt.enabled then
    addStr(dim, TLV2(HI_cryptMode, AnsiChar(cryptMode))
       + TLV2(HI_hashed, hashed), Result );
  i:=0;
  while i < count do
   begin
    addStr(dim, getAt(i).toString, Result );
    inc(i);
   end;
  setLength(result, dim);
end; // toString

function Thistory.getAt(idx: integer): Thevent;
begin
if (idx >= 0) and (idx < count) then
  result:=Thevent(items[idx])
else
  result:=NIL
end; // getAt

procedure Thistory.reset;
//var
//  i:integer;
begin
  loaded:=FALSE;
  loading := True;
//  i:=0;
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

function  Thistory.getByID(pID: Int64):Thevent;
var
  i:integer;
begin
  i:=Count-1;
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


procedure Thistory.deleteFromTo(uid: TUID; st,en:integer);
var
  i:integer;
begin
 {$IFDEF DB_ENABLED}
 {$ELSE ~DB_ENABLED}
  i:=st;
  while (st>=en) and (getAt(en) <> NIL)and(getAt(en).fpos < 0) do
    dec(en);
  while i <= en do
    begin
    if getAt(i).fpos < 0 then
      begin
      if i > st then
        utilLib.deleteFromTo(Account.ProtoPath+historyPath + uid, getAt(st).fpos, getAt(i-1).fpos+length(getAt(i-1).toString));
      st:=i+1;
      end;
    inc(i);
    end;
  if st > en then
    exit;
  utilLib.deleteFromTo(Account.ProtoPath+historyPath + uid, getAt(st).fpos, getAt(en).fpos+length(getAt(en).toString));

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

function DelHistWith(uid : TUID) : Boolean;
begin
 {$IFDEF DB_ENABLED}
    ExecSQL(MineDB, Format(SQLDeleteHistoryWith, [uid, uid]));
 {$ELSE ~DB_ENABLED}
    if FileExists(Account.ProtoPath + historyPath + UID) then
      Result := DeleteFile(Account.ProtoPath + historyPath + UID)
     else
 {$ENDIF ~DB_ENABLED}
      Result := False;
end;

{
function Thistory.RepaireHistoryStream(str : TMemoryStream; var rslt : String) : boolean;
var
  ev:Thevent;
//  cur:integer;

  function getByte:byte;
  begin
    str.Read(result, 1);
//    inc(cur)
  end;
  function getDatetime:Tdatetime;
  begin
//    result:=Tdatetime((@s[cur])^);
    str.Read(result, 8);
//    inc(cur,8)
  end;
  function getInt:integer;
  begin
//    result:=integer((@s[cur])^);
    str.Read(result, 4);
//    inc(cur,4);
  end;
  function getString:string;
  var
    i : Integer;
  begin
//    result:=copy(s,cur,getInt); inc(cur,length(result))
    i := getInt;
    SetLength(Result, i);
    str.Read(result[1], i);
  end;

  procedure parseExtrainfo;
  var
    code,next,extraEnd:integer;
    cur : Integer;
  begin
    cur := 1;
    extraEnd := getInt;
    inc(cur, 4);
  while cur < extraEnd do
    begin
    code:=getInt;
    inc(cur, 4);
    next:=cur+getInt;
    case code of
      EI_flags:
        begin
         ev.flags:=getInt;
//         inc(cur, 4);
        end;
      EI_UID:
        begin
          ev.who := MainProto.getContact(getString);
        end;
      end;
    cur:=next;
    end;
  end; // parseExtraInfo
var
  len : Int64;
//  iu : TUID;
  i : Integer;
  thisCnt : TRnQcontact;
begin
//  cur:=1;
  cryptMode:=CRYPT_SIMPLE;
  hashed:='';
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

function ExistsHistWith(uid : TUID) : Boolean;
begin
 {$IFDEF DB_ENABLED}
  result := True;
 {$ELSE ~DB_ENABLED}
  Result := sizeoffile(Account.ProtoPath+historyPath+uid) > 0;
 {$ENDIF ~DB_ENABLED}
end;


INITIALIZATION

writingQ:=Tlist.create;

FINALIZATION
writingQ.free;
writingQ := NIL;

end.
