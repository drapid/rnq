{
This file is part of R&Q.
Under same license
}
unit outboxLib;
{$I RnQConfig.inc}
{$I NoRTTI.inc}

interface

uses
  classes, sysutils, RnQStrings, RnQProtocol, RDGlobal;

const
  OE_msg        = 1;
  OE_contacts   = 2;
  OE_addedYou   = 3;
  OE_auth       = 4;
  OE_authDenied = 5;
  OE_file       = 6;
  OE_email      = 7;
  OE_automsgreq = 8;

  OEvent2ShowStr:array [OE_msg..OE_automsgreq] of string=(
    Str_message,'Contacts','Added you', 'Authorization given','Authorization denied',
    'File','E-Mail','Auto-message'
  );
type
  POEvent = ^TOEvent;
  TOEvent=class
   public
    kind:integer;
//    uin:integer;
    flags : Cardinal;
    whom  : TRnQContact; 
//    UID   : TUID;
    email : string;
    info  : string;
    cl: TRnQCList;
    wrote, lastmodify: Tdatetime;
    // ack fields
    timeSent: TdateTime;
    ID: integer;
    filepos: integer;
//    constructor Create;// override;
    constructor Create;// override;
    destructor Destroy; override;
    function   toString: RawByteString;
    function   fromString(const s: RawByteString) : Boolean;
    function   Clone: TOEvent;
    end; // TOEvent

  Toutbox = class(Tlist)
   public
//    destructor Destroy; override;

    function  toString: RawByteString;
    procedure fromString(s: RawByteString);

    function empty: boolean;
    function pop: TOevent;
    function popVisible: TOevent;

    procedure Clear; override;
    procedure clearU;
   protected
    procedure Notify(Ptr: Pointer; Action: TListNotification); OverRide;
   public
    function add(kind: Integer; dest: TRnQContact; flags: integer=0; const info: string=''): Toevent; overload;
    function add(kind: Integer; dest: TRnQContact; flags: integer; cl: TRnQCList): Toevent; overload;
    function getAt(idx: integer): TOevent;
    function remove(ev: TOevent): boolean; overload;
    function stFor(who: TRnQContact): boolean;
    function findID(id: Integer): integer;

    procedure updateScreenFor(cnt: TRnQContact);
    end; // Toutbox

implementation

uses
  globalLib, mainDlg, utilLib, chatDlg,
//  RnQProtocol,
  roasterLib, RnQCrypt,
  RQUtil, RnQDialogs, RDUtils, RnQBinUtils;

{destructor Toutbox.Destroy;
begin
  clear;
  inherited
end; // destroy
}

function Toutbox.toString: RawByteString;
var
  s: RawByteString;
  res : RawByteString;
  i: integer;
begin
  res := '';  // file version
  if count > 0 then
   begin
    for i:=0 to count-1 do
     begin
      s := getAt(i).toString;
      res := res + int2str(length(s))+s;
     end;
    critt(res, StrToIntDef(Account.AccProto.ProtoElem.MyAccNum, 0));
   end;
  result := 'VER'+int2str(1)+res;
end; // toString

procedure Toutbox.fromString(s: RawByteString);
var
  i, l: integer;
  ev: Toevent;
begin
  s := decritted(copy(s,8,length(s)), StrToIntDef(Account.AccProto.ProtoElem.MyAccNum, 0));
  clearU;
  i := 1;
  if length(s) < 4 then
    exit;
  try
   while i < length(s) do
    begin
      l:=integer((@s[i])^);
      inc(i,4);
      ev:=TOevent.create;
      if ev.fromString( copy(s,i,l) ) then
        add(ev)
       else
        ev.Free;
      inc(i,l);
    end;
  except
   msgDlg('Error on load outbox', True, mtError);
  end;
end; // fromString

procedure Toutbox.clear;
//var
//  i:integer;
//  oe : TOEvent;
begin
{for i:=count-1 downto 0 do
 begin
  oe := getAt(i);
  Items[i] := NIL;
  if oe <> NIL then
  with oe do
    try
//     updateScreenFor(uid);
     free;
    except
    end;
 end;}
  inherited;
  saveOutboxDelayed := TRUE;
end; // clear

procedure Toutbox.clearU;
var
  i: integer;
  oe: TOEvent;
begin
  for i:=count-1 downto 0 do
   begin
    oe := getAt(i);
    if oe <> NIL then
    with oe do
      try
//       if upd then
         updateScreenFor(whom);
//       free;
       Items[i] := NIL;
      except
      end;
   end;
  inherited;
  saveOutboxDelayed := TRUE;
end;


function Toutbox.add(kind: Integer; dest: TRnQContact; flags: integer; cl: TRnQCList): TOevent;
begin
  result := add(kind, dest, flags);
  result.cl := TRnQCList.create;
  result.cl.assign(cl);
end; // add

function Toutbox.add(kind: Integer; dest: TRnQContact; flags: integer=0; const info: string=''):TOevent;
var
  found: boolean;
  i: integer;
begin
  result := NIL;
  found := FALSE;
  if (kind in [OE_addedyou, OE_auth, OE_authDenied]) then
   for i:=0 to count-1 do
   begin
     result := getAt(i);
     if (kind=result.kind) and (dest.equals(result.whom)) then
      begin
       found := TRUE;
       break;
      end;
   end;
  if not found then
  begin
   result := TOevent.create;
   add(result);
  end;
  result.kind := kind;
  result.flags := flags;
  result.whom := dest;
  result.info := info;
  result.wrote := now;
  result.lastmodify := now;
  result.cl := NIL;
  updateScreenFor(result.whom);
  saveOutboxDelayed:=TRUE;
end; // add

function Toutbox.getAt(idx:integer):TOevent;
begin
if (idx>=0) and (idx<count) then
  result:=list[idx]
else
  result:=NIL;
end;
// getAt


procedure Toutbox.Notify(Ptr: Pointer; Action: TListNotification);
begin
  inherited;
  if (Action = lnDeleted)and (Ptr <> NIL) then
    TOevent(Ptr).Free;
end;

function Toutbox.remove(ev:TOevent):boolean;
var
  i : Integer;
begin
//   Result := inherited remove(ev)>=0;
  i := IndexOf(ev);
  if i >=0 then
    begin
      Result := True;
      list[i] := NIL;
      Delete(i);
      updateScreenFor(ev.whom);
      saveOutboxDelayed:=TRUE;
    end
   else
    Result := False;
end; // remove

function Toutbox.popVisible:TOevent;
var
  i:integer;
begin
i:=0;
while i < count do
  begin
  result:=getAt(i);
  if (result.flags and IF_sendWhenImVisible=0)
  or result.whom.imVisibleTo then
    begin
     list[i] := NIL;
     delete(i);
     saveOutboxDelayed:=TRUE;
     updateScreenFor(result.whom);
    exit;
    end;
  inc(i);
  end;
result:=NIL;
end; // popVisible

function Toutbox.pop:TOevent;
begin
  result:=NIL;
  if count>0 then
  begin
   result:=getAt(0);
   list[0] := NIL;
   delete(0);
   updateScreenFor(result.whom);
  end;
  saveOutboxDelayed:=TRUE;
end; // pop

function Toutbox.empty: boolean;
begin
  result:=count=0
end;

function Toutbox.stFor(who: TRnQContact): boolean;
var
  i: integer;
  ev: TOEvent;
begin
  result := FALSE;
  if Assigned(who) and (who is TRnQcontact) then
  for i:=0 to count-1 do
   begin
    ev := getAt(i);
    if Assigned(ev) and (ev.whom <> NIL) then
     if who.equals(ev.whom) then
      begin
        result := TRUE;
        exit;
      end;
   end;
end; // stFor

procedure Toutbox.updateScreenFor(cnt: TRnQContact);
begin
//if (uin = '') or (uin = '0') then exit;
  if (cnt = NIL) or (cnt.UID2cmp = '0') then
    exit;
//  redrawUIN(uin);
  roasterLib.redraw(cnt);
 if chatFrm<>NIL then
  with chatFrm do
    if (thischat<>NIL) and (thischat.who.Equals(cnt)) then
      sbar.repaint;
// RnQmain.sbar.Repaint;
 RnQmain.PntBar.Repaint;
end; // updateScreenFor

function Toutbox.findID(id: Integer): integer;
var
  e: TOEvent;
begin
  for result:=count-1 downto 0 do
   begin
    e := getAt(result);
    if ( e<> NIL) AND (e.id = id) then
     exit;
   end;
  result:=-1;
end; // findID

////////////////////////////////////////////////////////////////////////

const
  OEK_kind    = 1;
  OEK_flags   = 2;
  OEK_email   = 3;
  OEK_uin     = 4;
  OEK_info    = 5;
  OEK_wrote   = 6;
  OEK_cl      = 7;
  OEK_UID     = 10;

function TOevent.toString: RawByteString;

  procedure writeDown(code: integer; const data: RawByteString);
  begin
    result:=result+int2str(length(data))+int2str(code)+data
  end;

begin
  result:='';
  writeDown(OEK_kind, int2str(kind));
  writeDown(OEK_flags, int2str(flags));
  if kind=OE_email then
    writeDown(OEK_email, StrToUTF8(email))
   else
//    writeDown(OEK_uin, int2str(uid));
    if Assigned(whom) then
      writeDown(OEK_uid, StrToUTF8(whom.UID2cmp));
  writeDown(OEK_info, StrToUTF8(info));
  writeDown(OEK_wrote, dt2str(wrote));
  if assigned(cl) then
  writeDown(OEK_cl, cl.tostring);
end; // toString

function TOevent.fromString(const s: RawByteString): Boolean;
var
  i,L,code,next:integer;
  uid : TUID;
begin
  i := 1;
  Result := True;
  try
  while i < length(s) do
   begin
    L := integer((@s[i])^); inc(i,4);
    code := integer((@s[i])^); inc(i,4);
    next := i+L;
    case code of
      OEK_kind: kind := integer((@s[i])^);
      OEK_flags: flags := integer((@s[i])^);
      OEK_wrote: wrote := Tdatetime((@s[i])^);
      OEK_info: info := UnUTF(copy(s,i,L));
      OEK_email: email := UnUTF(copy(s,i,L));
      OEK_uin:
         begin
      {$IFDEF UID_IS_UNICODE}
           uid  := IntToStr(integer((@s[i])^));
      {$ELSE ansi}
           uid  := IntToStrA(integer((@s[i])^));
      {$ENDIF UID_IS_UNICODE}
           whom := Account.AccProto.getContact(uid);
         end;
      OEK_uid:
         begin
      {$IFDEF UID_IS_UNICODE}
           uid  := unUTF(copy(s,i,L));
      {$ELSE ansi}
           uid  := copy(s,i,L);
      {$ENDIF UID_IS_UNICODE}
           whom := Account.AccProto.getContact(uid);
         end;
      OEK_cl:
        begin
          if cl=NIL then
            cl := TRnQCList.create;
          cl.fromstring(Account.AccProto, copy(s,i,L), contactsDB);
        end;
      end;
    i := next;
   end;
  except
    Result := false;
  end;
end; // fromString

function  TOevent.Clone : TOEvent;
begin
  Result := TOEvent.Create;
  Result.kind  := Self.kind;
  Result.flags := Self.flags;
  Result.whom   := Self.whom;
  Result.email := Self.email;
  Result.info  := Self.info;
  if Self.cl <> NIL then
    Result.cl  := cl.clone
   else
    Result.cl  := NIL;
  Result.wrote := Self.wrote;
  Result.lastmodify := lastmodify;
  Result.timeSent   := timeSent;
  Result.ID    := ID;
  Result.filepos    := filepos;  
end;


destructor TOevent.Destroy;
begin
  if Assigned(cl) then
    FreeAndNil(cl);
//  FreeAndNil(whom);
  whom := NIL;
//  SetLength(UID, 0);
  SetLength(email, 0);
  SetLength(info, 0);
 inherited;
end;

constructor TOEvent.Create;
begin
  inherited;
  kind:= OE_msg;
//    uin:integer;
  flags:= 0;
//  UID   := '';
  whom  := NIL;
  email := '';
  info  := '';
  cl    := NIL;
end;


end.
