{
This file is part of R&Q.
Under same license
}
unit uinlistLib;
{$I RnQConfig.inc}
{$I NoRTTI.inc}

interface

uses
  RnQProtocol, classes;

type
  PuinList=^TuinList;
  TuinList=record
    name:string;
    desc:string;
    cl:TRnQCList;
   end;

  TuinLists=class(Tlist)
   private
    enumidx :integer;
   public
    destructor Destroy; override;
    function  exists(const name:string):boolean;
    function  idxOf(const name:string):integer;
    function  getAt(idx:integer):PuinList;
    function  put(const name:string):PuinList;
		function  remove(ul:PuinList):boolean; overload;
    procedure fromString(pr : TRnQProtocol; s: RawByteString);
    function  toString: RawByteString;
    procedure Clear; override;
    function  names:string;
    function  get(const name:string):PuinList;
    procedure resetEnumeration;
    function  hasMore:boolean;
    function  getNext:PuinList;
   end;

implementation

uses
  sysutils, utilLib, RQUtil, RDUtils, RnQBinUtils;

function TuinLists.exists(const name: string): boolean;
begin
  result:=idxOf(name)>=0
end;

function TuinLists.idxOf(const name: string): integer;
begin
  result:=count-1;
  while (result>=0) and (compareText(getAt(result).name,name)<>0) do
    dec(result);
end; // idxof

function TuinLists.getAt(idx: integer): PuinList;
begin
  result:=PuinList(items[idx])
end;

function TuinLists.put(const name:string):PuinList;
var
  idx:integer;
begin
  idx:=idxOf(name);
  if idx>=0 then
   begin
    result:=getAt(idx);
    exit;
   end;
  new(result);
  result.name:=name;
  result.desc:='';
  result.cl:=TRnQCList.create;
  add(result);
end;

function TuinLists.remove(ul:PuinList):boolean;
var
  i:integer;
begin
  result:=FALSE;
  for i:=0 to count-1 do
   if items[i] = ul then
    begin
     dispose(ul);
     inherited remove(ul);
     result:=TRUE;
     exit;
    end;
end; // remove

procedure Tuinlists.clear;
var
  i:integer;
begin
  for i:=0 to count-1 do
    dispose(PuinList(items[i]));
  inherited;
end;

destructor Tuinlists.Destroy;
begin
  clear;
  inherited;
end; // destroy

const
  FK_NAME=1;
  FK_DESC=2;
  FK_UIN=3;

procedure Tuinlists.fromString(pr : TRnQProtocol; s : RawByteString);
var
  l,t:integer;
begin
 clear;
 while s > '' do
  begin
   l:=integer((@s[1])^);
   t:=integer((@s[5])^);
   case t of
    FK_NAME: put(UnUTF(copy(s,9,l)));
    FK_DESC: PuinList(last)^.desc:= UnUTF(copy(s,9,l));
//    FK_UIN: PuinList(last)^.cl.add(contactsDB.get(IntToStr(integer((@s[9])^))));
    FK_UIN: PuinList(last)^.cl.add(contactsDB.add(pr, IntToStrA(integer((@s[9])^))));
   end;
   system.delete(s,1,8+l);
  end;
end; // fromstring

function Tuinlists.toString: RawByteString;

  procedure writeDown(code:integer; const data: RawByteString);
  begin
    result:=result+int2str(length(data))+int2str(code)+data
  end;

var
  i,j:integer;
begin
  result:='';
  for i:=0 to count-1 do
   with getAt(i)^ do
    begin
     writedown(FK_NAME, StrToUTF8(name));
     writedown(FK_DESC, StrToUTF8(desc));
     for j:=0 to TList(cl).count-1 do
      writedown(FK_UIN, int2str(StrToIntDef(cl.getAt(j).uid, 0)));
    end;
end; // tostring

function Tuinlists.names:string;
var
  i:integer;
begin
result:='';
  try
   for i:=0 to count-1 do
     result:=result+getAt(i)^.name+#13;
   if result > '' then
     setLength(result,length(result)-1);
  except
    result := '';
  end;
end; // names

function Tuinlists.get(const name:string):PuinList;
var
  i:integer;
begin
i:=idxOf(name);
if i<0 then
  result:=NIL
else
  result:=getAt(i);
end; // get

procedure Tuinlists.resetEnumeration;
begin
  enumIdx := 0
end;

function Tuinlists.hasMore: boolean;
begin
  result := enumIdx<count
end;

function Tuinlists.getNext: PuinList;
begin
  result := getAt(enumIdx);
  inc(enumIdx);
end; // getNext

end.
