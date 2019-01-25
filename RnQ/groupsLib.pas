{
Copyright (C) 2002-2004  Massimo Melina (www.rejetto.com)

This file is part of &RQ.

    &RQ is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    &RQ is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with &RQ; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
}
{
  This file is part of R&Q.
  Under same license
}
unit groupsLib;
{$I RnQConfig.inc}
{$I NoRTTI.inc}

interface

uses
  roasterlib, RDGlobal;

type
  Pgroup = ^Tgroup;
  Tgroup = record
    id: integer;
    ssiID: Integer;
    name: string;
    order: integer;
    node: array [Tdivisor] of Tnode;
    expanded: array [Tdivisor] of boolean;
    procedure ServerUpdate;
   end;

type
  Tgroups = class
   public
    a: array of Tgroup;
    procedure clear;
    procedure MakeAllLocal;
//    procedure save;
//    procedure load(s : AnsiString);
    procedure fromString(s: RawByteString);
    function  toString: RawByteString; reintroduce;
    function  idxOf(id: integer): integer;
    function  add(id_: integer=0): integer; OverLoad;
    function  add(const name: String; ssid: Integer = -1): integer; OverLoad;
    function  get(id: integer): Pgroup;
    function  exists(id: integer): boolean;
    function  count: integer;
    procedure rename(id: integer; const newname: string; onlyLocal: Boolean = false);
    procedure setNode(id: integer; divisor: TDivisor; node: TNode);
//    function  RenameLocal(ID: Integer; const NewName: String): TPair<String, TGroup>;
    function  delete(id: integer): boolean;
//    procedure changeId(oldId, newId: integer; db: TRnQCList);
    function  name2id(const name_: string): integer;
    function  ssi2id(ssiN: integer): integer;
    function  id2ssi(id: integer): Integer;
    function  id2name(id: integer): string;
    function  getAllSSI: RawByteString;
    function  freeID: integer;
    function  last: Pgroup;
   end; // Tgroups

implementation

uses
  utilLib, globalLib, classes, sysutils, RnQBinUtils,
 {$IFDEF UNICODE}
   AnsiStrings,
 {$ENDIF UNICODE}
  RnQprotocol,
 {$IFDEF PROTOCOL_ICQ}
   ICQv9,
 {$ENDIF PROTOCOL_ICQ}
  RQUtil, RDUtils, RnQFileUtil;

function Tgroups.get(id: integer): Pgroup;
begin result := @a[idxOf(id)] end;

//procedure Tgroups.save;
//begin saveFile(userPath+groupsFilename, toString) end;

//procedure Tgroups.load(s: AnsiSring);
//begin fromString(s) end;

const
  string_separator = ';';

procedure Tgroups.fromString(s: RawByteString);
var
  k, line: RawByteString;
begin
  clear;
  while s>'' do
   begin
    line := chopLine(s);
    k := trim(chop(AnsiString('='), line));
    line := trim(line);
    if isOnlyDigits(k) then
      try
        add;
        last.id := strToIntA(k);
        last.name := UnUTF(line);
       except
        setlength(a, length(a)-1);
      end
     else
      if k='collapsed' then
        while line > '' do
         try
           last.expanded[str2divisor(chop(string_separator,line))] := FALSE;
          except
         end
       else
        if k='order' then
          try
            last.order := strToIntA(line)
           except
          end
         else
          if k='ssi' then
            try
              last.ssiID := strToIntA(line)
             except
            end;
  end;
end; // fromString

function Tgroups.toString: RawByteString;
var
  i: integer;
  d: Tdivisor;
begin
  result := '';
  for i:=0 to count-1 do
  begin
    result := result+format(AnsiString('%d=%s'+CRLF+'order=%d'
             +CRLF+'collapsed='), [
      a[i].id, StrToUTF8(a[i].name), a[i].order]);
    for d:=low(d) to high(d) do
      if not a[i].expanded[d] then
        result := result+divisor2str[d]+string_separator;
    result := result+format(AnsiString(CRLF+'ssi=%d'), [a[i].ssiID]);
    result := result+CRLF;
  end;
end; // toString

procedure Tgroups.clear;
var
  I: Integer;
  d: Tdivisor;
begin
 for I := 0 to Length(a) - 1 do
  begin
    a[i].name := '';
    for d:=low(Tdivisor) to high(Tdivisor) do
     begin
//     divs[d].Free;
       a[i].node[d].Free;
       a[i].node[d] := NIL;
     end;
  end;
  setlength(a,0)
end;

function Tgroups.idxOf(id: integer): integer;
begin
  for result:=0 to count-1 do
    if a[result].id = id then
      exit;
  result := -1;
end; // idxOf

function Tgroups.freeID: integer;
var
  i: integer;
begin
  result := 1000;
  for i:=0 to count-1 do
    if a[i].id >= result then
      result := a[i].id+1;
end; // freeID

function Tgroups.add(id_: integer=0): integer;
var
  d: Tdivisor;
  p: Pgroup;
begin
  setlength(a, length(a)+1);
  p := last;
  if id_=0 then
    p.id := freeID
   else
    p.id := id_;
  p.name := '';
  p.order := 0;
  for d:=low(d) to high(d) do
    begin
      p.node[d] := NIL;
      p.expanded[d] := TRUE;
    end;
  result := p.id;
end; // add

function Tgroups.add(const name: String; ssid: Integer = -1): integer;
var
  i: Integer;
  gr: Pgroup;
begin
  if (ssid < 0) or exists(ssid) then
    i := 0
   else
    i := ssid;
  Result := add(i);
  gr := get(Result);
  gr.ssiID := ssid;
  gr.name := name;
end;

function Tgroups.exists(id: integer): boolean;
begin result:=idxOf(id) >= 0 end;

procedure Tgroups.rename(id: integer; const newname: string; onlyLocal: Boolean = false);
begin
  with a[idxOf(id)] do
   begin
     name := newname;
     ServerUpdate;
   end;
end;

procedure TGroups.setNode(id: integer; divisor: TDivisor; node: TNode);
var
  i: Integer;
begin
  i := idxOf(id);
  if (i >= 0) and (divisor in [Low(TDivisor)..High(TDivisor)]) then
    a[i].node[divisor] := node;
end;

procedure Tgroups.MakeAllLocal;
var
  p: TGroup;
begin
  for p in a do
  begin
//    p := g.Value;
//    p.IsLocal := True;
//    SaveGroup(p);
  end;
end;

function Tgroups.delete(id: integer): boolean;
var
  i: Integer;
begin
  id := idxOf(id);
  result := id >= 0;
  if not result then
    exit;
  i := a[id].ssiID;
// shift
  while id < count-1 do
   begin
    a[id]:=a[id+1];
    inc(id);
   end;
  setlength(a,length(a)-1);
 {$IFDEF PROTOCOL_ICQ}
  if
 {$IFDEF UseNotSSI}
    TicqSession(MainProto.ProtoElem).useSSI and
 {$ENDIF UseNotSSI}
    (i > 0)and Account.AccProto.isReady then
      TicqSession(Account.AccProto.ProtoElem).SSIdeleteGroup(i);
 {$ENDIF PROTOCOL_ICQ}
end; // delete

function Tgroups.id2name(id: integer): string;
begin
  id:=idxOf(id);
  if id<0 then
    result:=''
   else
    result:=a[id].name;
end; // id2name

function Tgroups.name2id(const name_: string): integer;
var
  i: integer;
begin
  for i:=0 to count-1 do
    if a[i].name = name_ then
      begin
        result :=a[i].id;
        exit;
      end;
  result:=-1;
end; // name2id

function Tgroups.ssi2id(ssiN: Integer): integer;
var
  i: integer;
begin
for i:=0 to count-1 do
  if a[i].ssiID = ssiN then
    begin
    result:=a[i].id;
    exit;
    end;
result:=-1;
end; // name2id

function Tgroups.id2ssi(id: integer): Integer;
begin
  id:=idxOf(id);
  if id<0 then
    result:= 0
   else
    result:=a[id].ssiID;
end;

function Tgroups.getAllSSI: RawByteString;
var
  i: integer;
begin
  Result := '';
  for i:=0 to count-1 do
   if a[i].ssiID > 0 then
    Result := Result + word_BEasStr(a[i].ssiID);
end;


{
procedure Tgroups.changeId(oldId, newId: integer; db: TRnQCList);
var
  i: integer;
begin
  if exists(newId) then
    delete(oldId)
   else
    a[idxOf(oldId)].id := newId;

  for i:=0 to TList(db).count-1 do
    with TRnQcontact(db.getAt(i)) do
      if group = oldId then
        group := newId;
end; // changeId
}
function Tgroups.count: integer;
begin result := length(a) end;

function Tgroups.last: Pgroup;
begin result := @a[length(a)-1] end;

{ Tgroup }

procedure Tgroup.ServerUpdate;
begin
//               ICQ.SSIRenameGroup(ssiID, name);
//               if ssiID > 0 then
 {$IFDEF PROTOCOL_ICQ}
  if Account.AccProto.ProtoElem is TicqSession then
 {$IFDEF UseNotSSI}
   if TicqSession(Account.AccProto.ProtoElem).useSSI then
 {$ENDIF UseNotSSI}
    TicqSession(Account.AccProto.ProtoElem).SSIUpdateGroup(id);
 {$ENDIF PROTOCOL_ICQ}
end;

end.
