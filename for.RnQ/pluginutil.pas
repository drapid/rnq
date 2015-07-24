Unit pluginutil;
interface
{$I NoRTTI.inc}

uses
 types;

function _int(i: integer): RawByteString; overload;
function _int(ints: array of integer): RawByteString; overload;
function _byte_at(p: pointer; ofs: integer=0): byte; overload;
function _byte_at(const s: RawByteString; idx: integer=1): byte; overload;
function _int_at(p: pointer; ofs: integer=0): integer; overload;
function _int_at(const s: RawByteString; idx: integer=1): integer; overload;
function _ptr_at(p: pointer; ofs: integer=0): pointer;
function _istring(const s: RawByteString): RawByteString; inline;
function _istring_at(p: pointer; ofs: integer=0): RawByteString; overload;
function _istring_at(const s: RawByteString; idx: integer=1): RawByteString; overload;
function _intlist(a: array of integer): RawByteString;
function _intlist_at(p: pointer; ofs: integer=0): TintegerDynArray; overload;
function _intlist_at(const s: RawByteString; idx: integer=1): TintegerDynArray; overload;
function _double(p: pointer; ofs: integer=0): double;
// By Rapid D
function _dt(dt: Tdatetime): RawByteString;
function _dt_at(p: pointer; ofs: integer=0): Tdatetime; overload;
function _dt_at(const s: RawByteString; idx: integer=1): Tdatetime; overload;


implementation
function _int(i: integer): RawByteString; overload;
begin
  setLength(result, 4);
  move(i, result[1], 4);
end; // _int

function _int(ints: array of integer): RawByteString; overload;
var
  i: integer;
begin
  result:='';
  for i:=0 to length(ints)-1 do
    result := result+_int(ints[i]);
end; // _int

function _byte_at(p: pointer; ofs: integer=0): byte;
begin
  inc( PByte(p), ofs);
  result:=byte(p^)
end;

function _byte_at(const s: RawByteString; idx: integer=1): byte; overload;
begin
  result:=_byte_at(@s[idx])
end;

function _int_at(p: pointer; ofs: integer=0): integer; overload;
begin
  inc( PByte(p), ofs);
  result:=integer(p^)
end;

function _int_at(const s: RawByteString; idx: integer=1): integer; overload; inline;
begin result := _int_at(@s[idx]) end;

function _ptr_at(p: pointer; ofs: integer=0): pointer;
begin
  inc( PByte(p), ofs);
  result := pointer(_int_at(p))
end;

function _istring(const s: RawByteString): RawByteString; inline;
begin result:=_int(length(s))+s end;

function _istring_at(p:pointer; ofs:integer=0):RawByteString; overload;
begin
  inc(PByte(p), ofs);
  setlength(result, integer(p^));
  inc(PByte(p), 4);
  if Length(Result) > 0 then
    move(p^, result[1], length(result));
end; // _istring_at

function _istring_at(const s:RawByteString; idx:integer=1):RawByteString; overload;
begin result:=_istring_at(@s[idx]) end;

function _intlist(a:array of integer):RawByteString;
begin result:=_int(length(a))+_int(a) end;

function _intlist_at(p:pointer; ofs:integer=0):TintegerDynArray; overload;
var
  n,i:integer;
begin
inc(PByte(p), ofs);
n:=integer(p^);
setlength(result, n);
for i:=0 to n-1 do
  begin
  inc(PByte(p),4);
  result[i]:=_int_at(p);
  end;
end; // _intlist_at

function _intlist_at(const s: RawByteString; idx: integer=1): TintegerDynArray; overload;
begin result:=_intlist_at(@s[idx]) end;

function _dt(dt:Tdatetime):RawByteString;
begin
setLength(result, 8);
move(dt, result[1], 8);
end; // _dt

function _double(p: pointer; ofs: integer=0): double;
begin
inc(PByte(p), ofs);
//setlength(result, integer(p^));
//inc(integer(p), 4);
move(p^, result, 8);
end; // _double

function _dt_at(p: pointer; ofs: integer=0): Tdatetime; overload;
begin
  inc( PByte(p), ofs);
  result := Tdatetime(p^)
end; // _dt_at
function _dt_at(const s: RawByteString; idx: integer=1): Tdatetime; overload;
begin
 result := _dt_at(@s[idx]);
end; // _dt_at


end.
