{
This file is part of R&Q.
Under same license
}
unit RnQBinUtils;
{$I ForRnQConfig.inc}
{$I NoRTTI.inc}

{ $INLINE ON}

interface

uses
  sysutils, types, RDGlobal;

function dword_LE2ip(d: dword): AnsiString;
 {$IFDEF UNICODE}
function dword_LE2ipU(d: dword): UnicodeString;
 {$ENDIF UNICODE}
//function invert(d:integer):integer; OverLoad;
//function invert64(const d:int64):int64; OverLoad; inline;
//function BSwapInt(Value: LongWord): LongWord; assembler; register;
//procedure SwapShort(const P: PWord; const Count: Cardinal);
//procedure SwapLong(P: PInteger; Count: Cardinal);
//function  SwapLong(Value: Cardinal): Cardinal; overload;

function incPtr(p: pointer; d: Integer): Pointer; inline;
function findTLV(idx: Integer; const s: RawByteString; ofs: Integer=1): Integer;
function existsTLV(idx: Integer; const s: RawByteString; ofs: Integer=1): Boolean; inline;
function deleteTLV(idx: Integer; const s: RawByteString; ofs: Integer=1): RawByteString;

// build data
function qword_LEasStr(d: Int64): RawByteString;
function qword_BEasStr(d: Int64): RawByteString;
function dword_LEasStr(d: dword): RawByteString;
function dword_BEasStr(d: dword): RawByteString;
function word_BEasStr(w: word): RawByteString; inline;
function word_LEasStr(w: word): RawByteString;
function TLV(t: word; v: dword): RawByteString; overload;
function TLV(t: word; v: word): RawByteString; overload;
function TLV(t: word; v: Integer): RawByteString; overload;
function TLV(t: word; v: Int64): RawByteString; overload;
function TLV(t: word; const v: RawByteString): RawByteString; overload;
function TLV_IFNN(t: word; const v: RawByteString): RawByteString; inline;
function TLV_LE(t: word; const v: RawByteString): RawByteString;
function TLV2(code: Integer; const data: RawByteString): RawByteString; overload;
function TLV2(code: Integer; const data: TDateTime): RawByteString;overload;
function TLV2(code: Integer; const data: Integer): RawByteString;overload;
function TLV2(code: Integer; const data: Boolean): RawByteString; overload;
function TLV2_IFNN(code: Integer; const data: RawByteString): RawByteString; overload; // if data not null
function TLV2_IFNN(code: Integer; const data: TDateTime): RawByteString;overload; // if data not null
function TLV2_IFNN(code: Integer; data: Integer): RawByteString; overload; // if data not null
function TLV2U_IFNN(code: Integer; const str: String): RawByteString;// overload; // if data not null. Unicode String
function TLV3(code: Integer; const data: RawByteString): RawByteString;
function TLV3U(code: Integer; const Str: UnicodeString): RawByteString;
function Length_LE(const data: RawByteString): RawByteString;
function Length_BE(const data: RawByteString): RawByteString;
function Length_DLE(const data: RawByteString): RawByteString;
function Length_B(const data: RawByteString): RawByteString;
function WNTS(const s: RawByteString): RawByteString;
function WNTSU(const s: String): RawByteString;

// read data
function Qword_LEat(p: Pointer): Int64; {$IFDEF HAS_INLINE}inline;{$ENDIF HAS_INLINE}
function Qword_BEat(p: Pointer): Int64; {$IFDEF HAS_INLINE}inline;{$ENDIF HAS_INLINE}
function dword_BEat(const s: RawByteString; ofs: Integer): Integer; overload; {$IFDEF HAS_INLINE}inline;{$ENDIF HAS_INLINE}
function dword_BEat(p: Pointer): LongWord; overload; {$IFDEF HAS_INLINE}inline;{$ENDIF HAS_INLINE}
function dword_LEat(p: Pointer): LongWord; inline; {$IFDEF HAS_INLINE}inline;{$ENDIF HAS_INLINE}
function word_LEat(p: Pointer): word; {$IFDEF HAS_INLINE}inline;{$ENDIF HAS_INLINE}
function word_BEat(p: Pointer): word; overload; {$IFDEF HAS_INLINE}inline;{$ENDIF HAS_INLINE}
function ptrWNTS(p: Pointer): RawByteString;

function word_BEat(const s: RawByteString; ofs: Integer): Word; overload;
//function word_BEat(s:string; ofs:integer):word; overload;

  function readQWORD(const snac: RawByteString; var ofs: Integer): Int64;
  function readWORD(const snac: RawByteString; var ofs: Integer): Word;
  function readBEWORD(const snac: RawByteString; var ofs: Integer): Word; {$IFDEF HAS_INLINE}inline;{$ENDIF HAS_INLINE}
  function readINT(const snac: RawByteString; var ofs: Integer): Integer; {$IFDEF HAS_INLINE}inline;{$ENDIF HAS_INLINE}
  function readDWORD(const snac: RawByteString; var ofs: integer): Cardinal;
  function readBEDWORD(const snac: RawByteString; var ofs: integer): Cardinal;
  function readBYTE(const snac: RawByteString; var ofs: Integer): Byte;

//function getBUIN2(const s:RawByteString; var ofs:integer): RawByteString;
//function getBUIN(const s:RawByteString; var ofs:integer): Integer;
function getDLS(const s:RawByteString; var ofs:integer):RawByteString;
function getWNTS(const s:RawByteString; var ofs:integer):RawByteString;
function getBEWNTS(const s:RawByteString; var ofs:integer):RawByteString;

function getTLV(p:pointer):RawByteString; overload;
function getTLVwordBE(p:pointer):word; overload;
function getTLVdwordBE(p:pointer):dword; overload;

function getTLV(idx:integer; const s:RawByteString;ofs:integer=1):RawByteString; overload;
function getTLVwordBE(idx:integer; const s:RawByteString; ofs:integer=1):word; overload;
function getTLVdwordBE(idx:integer; const s:RawByteString; ofs:integer=1):dword; overload;
function getTLVqwordBE(idx:integer; const s:RawByteString; ofs:integer=1): Int64;

function getTLVSafe(idx: integer; const s: RawByteString; ofs: integer=1): RawByteString;
function getTLVSafeDelete(idx: integer; var s: RawByteString; ofs: integer=1): RawByteString;
function replaceAddTLV(idx: integer; const s: RawByteString; ofs: integer=1; NewTLV: RawByteString = ''): RawByteString;

//----------------------------
function findTLV3(const idx:integer; const s:RawByteString; ofs:integer):integer;
function getTLV3Safe(const idx:integer; const s:RawByteString; const ofs:integer):RawByteString;
function getTLV3dwordBE(p:pointer):dword;
function getTLV3wordBE(p:pointer):dword;

function getwTLD(const s:RawByteString; var ofs:integer): RawByteString;
function getwTLD_DWORD(const s:RawByteString; var ofs:integer): LongWord;
/////----------------------------


  function  int2str(i: Integer): RawByteString;
  function  int2str64(i: Int64): RawByteString;
  function  dt2str(dt: Tdatetime): RawByteString;

  function  str2int(const s:RawByteString):integer; overload;
  function  str2int(p:pointer):integer; overload; inline;

implementation
  uses
 {$IFDEF UNICODE}
   AnsiStrings,
 {$ENDIF UNICODE}
 {$IFNDEF FPC}
   OverbyteIcsUtils,
 {$ENDIF ~FPC}
   Windows,
   RDUtils
   ;

{$IFDEF Linux}    // Äëÿ Lazarus
//Function Swap (X : Integer) : Integer;{$ifdef SYSTEMINLINE}inline;{$endif}
Function Swap (X : word) : word;{$ifdef SYSTEMINLINE}inline;{$endif}
Begin
  { the extra 'and $ff' in the right term is necessary because the  }
  { 'X shr 8' is turned into "longint(X) shr 8", so if x < 0 then   }
  { the sign bits from the upper 16 bits are shifted in rather than }
  { zeroes. Another bug for TP/Delphi compatibility...              }
  swap:=(X and $ff) shl 8 + ((X shr 8) and $ff)
End;
{$ENDIF Linux}
{$IFDEF FPC}
// From ICS!
  {* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
  function IcsSwap32(Value: LongWord): LongWord;
  {$IFDEF PUREPASCAL}
  begin
      Result := Word(((Value shr 16) shr 8) or ((Value shr 16) shl 8)) or
                Word((Word(Value) shr 8) or (Word(Value) shl 8)) shl 16;
  {$ELSE}
  asm
  {$IFDEF CPUX64}
      MOV    EAX, ECX
  {$ENDIF}
      BSWAP  EAX
  {$ENDIF}
  end;
  {* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
  function IcsSwap64(Value: Int64): Int64;
  {$IFDEF PUREPASCAL}
  var
      H, L: LongWord;
  begin
      H := LongWord(Value shr 32);
      L := LongWord(Value);
      H := Word(((H shr 16) shr 8) or ((H shr 16) shl 8)) or
           Word((Word(H) shr 8) or (Word(H) shl 8)) shl 16;
      L := Word(((L shr 16) shr 8) or ((L shr 16) shl 8)) or
           Word((Word(L) shr 8) or (Word(L) shl 8)) shl 16;
      Result := Int64(H) or Int64(L) shl 32;
  {$ELSE}
  asm
  {$IFDEF CPUX64}
      MOV    RAX, RCX
      BSWAP  RAX
  {$ELSE}
      MOV   EDX,  [EBP + $08]
      MOV   EAX,  [EBP + $0C]
      BSWAP EAX
      BSWAP EDX
  {$ENDIF}
  {$ENDIF}
  end;
{$ENDIF FPC}
    {$WARN UNSAFE_CAST OFF}
    {$WARN UNSAFE_CODE OFF}

{function invert(d:integer):integer; assembler; register;
//begin
//  result:=swap(d shr 16)+swap(d) shl 16
asm
 BSWAP EAX
end;}

{
function BSwapInt(Value: LongWord): LongWord; assembler; register;
asm
  BSWAP  EAX
end;

function invert64(const d:int64):int64;
//var
//  i : Int64Rec
begin
  Int64Rec(result).Words[0] := Swap(Int64Rec(d).Words[3]);
  Int64Rec(result).Words[1] := Swap(Int64Rec(d).Words[2]);
  Int64Rec(result).Words[2] := Swap(Int64Rec(d).Words[1]);
  Int64Rec(result).Words[3] := Swap(Int64Rec(d).Words[0]);
//  result := swap(Word(d shr 48)) + swap(Word(d shr 32)) shl 16 +
//            swap(word(d shr 16)) shl 32 + swap(word( d)) shl 48;
end;
}

{
Here's another one that uses the SSSE3 instruction PSHUFB:

 function Swap(const X: Int64): Int64;
 const
 SHUFIDX: array [0..1] of Int64 = ($0001020304050607, 0);
 asm
 MOVQ XMM0,[X]
 PSHUFB XMM0,SHUFIDX
 MOVQ [Result],XMM0
 end;
}
{procedure SwapShort(const P: PWord; const Count: Cardinal);
asm
 @@Loop:
  MOV CX, [EAX]
  XCHG CH, CL
  MOV [EAX], CX
  ADD EAX, 2
  DEC EDX
  JNZ @@Loop
end;

procedure SwapLong(P: PInteger; Count: Cardinal); overload;
asm
 @@Loop:
  MOV ECX, [EAX]
  BSWAPl ECX
  MOV [EAX], ECX
  ADD EAX, 4
  DEC EDX
  JNZ @@Loop
end;
}



function int2str(i:integer):RawByteString;
var
  v : RawByteString;
begin
  setLength(v, 4);
  move(i, Pointer(v)^, 4);
  Result := v;
end;

function ptrWNTS(p:pointer):RawByteString;
var
  v : RawByteString;
begin
  setLength(v, word(p^)-1);
  move(incPtr(p,2)^, Pointer(v)^, length(v));
  Result := v;
end; // ptrWNTS

{
function getBUIN2(const s:RawByteString; var ofs:integer): RawByteString;
begin
//result:=strToInt(copy(s,ofs+1,ord(s[ofs])));
result:= copy(s,ofs+1,ord(s[ofs]));
inc(ofs, 1+ord(s[ofs]));
end; // getBUIN

function getBUIN(const s:RawByteString; var ofs:integer): Integer;
var
  E: Integer;
//  ss : AnsiString;
  ss : String;
begin
//  result:=strToInt(ss);
  ss := copy(s, ofs+1, byte(s[ofs]));
  Val(ss, Result, E);
  if e <> 0 then
    Result := 0;
//result:= copy(s,ofs+1,ord(s[ofs]));
  inc(ofs, 1+ byte(s[ofs]));
end; // getBUIN
}
function getWNTS(const s:RawByteString; var ofs:integer): RawByteString;
var
  i:integer;
begin
i:=word((@s[ofs])^);
result:=copy(s,ofs+2,i-1);
inc(ofs, 2+i);
end; // getWNTS

function getBEWNTS(const s:RawByteString; var ofs:integer): RawByteString;
var
  i:integer;
begin
  i:=swap(word((@s[ofs])^));
  result:=copy(s,ofs+2,i);
  inc(ofs, 2+i);
end; // getBEWNTS

function getDLS(const s:RawByteString; var ofs:integer): RawByteString;
var
  i:integer;
begin
i:=integer((@s[ofs])^);
if i > 100*1024 then
  result:=''
else
  begin
  result:=copy(s,ofs+4,i);
  inc(ofs, 4+i);
  end;
end; // getDLS

function incPtr(p:pointer;d:integer):pointer; inline;
begin
  result:=pointer(PtrInt(p)+d)
end;

function existsTLV(idx:integer; const s:RawByteString;ofs:integer):boolean;
begin
  result:=findTLV(idx,s,ofs)>0
end;

function findTLV(idx:integer; const s:RawByteString; ofs:integer):integer;
var
 l :  Integer;
begin
  result:=-1;
{
  l := length(s);
  if (l >= 4)and(ofs < l) then
//  if l > 2 then
  begin
   while word_BEat(@s[ofs])<>idx do
    begin
    inc(ofs, word_BEat(@s[ofs+2])+4);
    if ofs >= l then
      exit;
    end;
   result:=ofs;
  end;}
  l := length(s)-2;
  if (l >= 2)and(ofs < l) then
//  if l > 2 then
  begin
   while word_BEat(@s[ofs])<>idx do
    begin
    inc(ofs, word_BEat(@s[ofs+2])+4);
    if ofs >= l then
      exit;
    end;
   result:=ofs;
  end;
end; // findTLV

function deleteTLV(idx:integer; const s:RawByteString;ofs:integer=1):RawByteString;
var
 i, l : Integer;
begin
  i := findTLV(idx, s, ofs);
  if i > 0 then
   begin
    l := word_BEat(@s[i+2]);
    Result := Copy(s, 1, i-1) + Copy(s, i + 4 + l, length(s));
   end
  else
   Result := s;
end;

function getTLV(p:pointer):RawByteString;
var
  pw:pword absolute p;
begin
if pw=NIL then
  result:=''
else
  begin
  inc(pw);
  setLength(result, swap(pw^));
  inc(pw);
  move(pw^, Pointer(result)^, length(result));
  end;
end; // getTLV

function getTLVwordBE(p:pointer):word;
var
  pw:pword absolute p;
begin
inc(pw,2);
result:=swap(pw^);
end; // getTLVwordBE

function getTLVdwordBE(p:pointer):dword;
var
  pw:pword absolute p;
  pd:pinteger absolute p;
begin
  inc(pw,2);
//result:= BSwapInt(pd^);
  result:= IcsSwap32(pd^);
end;

function getTLV(idx: integer; const s: RawByteString; ofs: integer): RawByteString;
begin
  result := getTLV(@s[findTLV(idx,s,ofs)])
end;

function getTLVSafe(idx: integer; const s: RawByteString; ofs: integer): RawByteString;
var
  i: Integer;
begin
 i := findTLV(idx,s,ofs);
 if i > 0 then
  result:=getTLV(@s[i])
 else
  result:='';
end;

function getTLVSafeDelete(idx:integer; var s: RawByteString; ofs:integer=1): RawByteString;
var
  i : Integer;
begin
 i := findTLV(idx,s,ofs);
 if i > 0 then
   begin
    result:=getTLV(@s[i]);
    s := deleteTLV(idx, s, i);
   end
 else
  result:='';
end;

function replaceAddTLV(idx: integer; const s: RawByteString; ofs:integer=1; NewTLV: RawByteString = ''): RawByteString;
var
  i, l : Integer;
begin
  i := findTLV(idx, s, ofs);
  if i > 0 then
   begin
    l := word_BEat(@s[i+2]);
    Result := Copy(s, 1, i-1) +TLV(idx, NewTLV) + Copy(s, i + 4 + l, length(s));
   end
  else
   Result := s + TLV(idx, NewTLV);
end;

function getTLVwordBE(idx: integer; const s: RawByteString; ofs: integer=1): word;
begin
  result:=getTLVwordBE(@s[findTLV(idx,s,ofs)])
end;

function getTLVdwordBE(idx: integer; const s: RawByteString;ofs: integer=1): dword;
begin
  result:=getTLVdwordBE(@s[findTLV(idx,s,ofs)])
end;

function getTLVqwordBE(idx: integer; const s: RawByteString;ofs: integer=1): Int64;
var
  i : Integer;
begin
 i := findTLV(idx, s, ofs);
 if i > 0  then
   result := Qword_BEat(@s[i+4])
  else
   result := 0;
end;


function findTLV3(const idx: integer; const s: RawByteString; ofs:integer):integer;
var
 l :  Integer;
begin
  result:=-1;
  l := length(s)-2;
  if (l >= 8)and(ofs < l) then
//  if l > 2 then
  begin
   while dword_BEat(@s[ofs])<>idx do
    begin
    inc(ofs, dword_BEat(@s[ofs+4])+8);
    if ofs >= l then
      exit;
    end;
   result:=ofs;
  end;
end; // findTLV3

function getTLV3(p: pointer): RawByteString;
var
//  pw:PDWord absolute p;
  pw: PINT absolute p;
  a : Integer;
begin
if pw=NIL then
  result:=''
else
  begin
  inc(pw);
//  setLength(result, swap(pw^));
//  a := BSwapInt(pw^);
  a := IcsSwap32(pw^);
  setLength(result, a);
  inc(pw);
  move(pw^, result[1], a);
  end;
end; // getTLV

function getTLV3Safe(const idx: integer; const s: RawByteString; const ofs:integer):RawByteString;
var
  i : Integer;
begin
 i := findTLV3(idx,s,ofs);
 if i > 0 then
  result:= getTLV3(@s[i])
 else
  result:='';
end;

function getTLV3dwordBE(p: pointer): dword;
var
  pw:PDWORD absolute p;
  pd:pinteger absolute p;
begin
  inc(pw,2);
//  result:= BSwapInt(pd^);
  result:= IcsSwap32(pd^);
end;

function getTLV3wordBE(p: pointer): dword;
var
  pw:PDWORD absolute p;
  pd:pword absolute p;
begin
  inc(pw,2);
  result:= swap(pd^);
end;

function getwTLD(const s: RawByteString; var ofs: integer): RawByteString;
var
  i:integer;
begin
//i:= BSwapInt(integer((@s[ofs+4])^));
  i:= IcsSwap32(integer((@s[ofs+4])^));
if i > 100*1024 then
  result:=''
else
  begin
  result:=copy(s,ofs+4 + 4,i);
  inc(ofs, 4+4+i);
  end;
end; // getwTLD

function getwTLD_DWORD(const s: RawByteString; var ofs: integer): LongWord;
var
  i: integer;
begin
  inc(ofs, 4);
//  i:= BSwapInt(integer((@s[ofs])^));
  i:= IcsSwap32(LongWord((@s[ofs])^));
  if i <> 4 then
    result := 0
   else
    begin
     inc(ofs, 4);
     result := dword_BEat(@s[ofs]);
     inc(ofs, i);
    end;
end;

function Length_LE(const data: RawByteString): RawByteString;
begin
  result := word_LEasStr(length(data))+data
end;

function Length_DLE(const data: RawByteString): RawByteString;
begin
  result:=dword_LEasStr(length(data))+data
end;

function Length_BE(const data: RawByteString): RawByteString;
begin
  result := word_BEasStr(length(data))+data
end;

function Length_B(const data: RawByteString): RawByteString;
begin
  result := AnsiChar(byte(length(data)))+data
end;

function WNTS(const s: RawByteString): RawByteString;
begin
  result := Word_LEasStr(length(s)+1)+s+#0
end;

function WNTSU(const s: String): RawByteString;
var
  s1 : RawByteString;
begin
  s1 := StrToUTF8(s);
  result:=Word_LEasStr(length(s1)+1)+s1+#0
end;

function TLV(t: word; v: dword): RawByteString;
begin
  result:=TLV(t,dword_BEasStr(v))
end;

function TLV(t: word; v: word): RawByteString;
begin
  result:=TLV(t,word_BEasStr(v))
end;

function TLV(t: word; v: integer): RawByteString;
begin
  result:=TLV(t,dword_BEasStr(v))
end;

function TLV(t: word; v: Int64): RawByteString;
begin
  result:=TLV(t,qword_BEasStr(v))
end;

function TLV(t: word; const v: RawByteString): RawByteString;
//begin result:=word_BEasStr(t)+word_BEasStr(length(v))+v end;
var
  s: RawByteString;
  ps: Pointer;
  i: word;
  a: word;
begin
  i := length(v);
  SetLength(s, 2+ 2+ i);
  ps := Pointer(s);
  a := swap(t);
  Move(a, ps^, 2);
  inc(PByte(ps), 2);
  a := swap(i);
  Move(a, ps^, 2);
  inc(PByte(ps), 2);
  if i > 0 then
    Move(Pointer(v)^, ps^, i);
  Result := s;
end;

function TLV_IFNN(t: word; const v: RawByteString): RawByteString;
begin
  if (v > '') then
    result := TLV(t, v)
   else
    result := '';
end;
//function TLV_LE(t:word; v:word):string;
//begin result:= TLV_LE(t, word_LEasStr(v)) end;

function TLV_LE(t: word; const v: RawByteString): RawByteString;
begin
  result := word_LEasStr(t)+word_LEasStr(length(v))+v
end;

function TLV2(code: integer; const data: RawByteString): RawByteString;
var
  s : RawByteString;
//  ps : PAnsiChar;
  ps : Pointer;
  i : Integer;
begin
  i := length(data);
  SetLength(s, 4+ 4+ i);
  ps := Pointer(s);
//  Move(code, ps^, 4);
  PInteger(ps)^ := code;

  inc(PByte(ps), 4);
//  Move(i, ps^, 4);
  PInteger(ps)^ := i;

  inc(PByte(ps), 4);
  if i > 0 then
    Move(Pointer(data)^, ps^, i);
  Result := s;
{
  move(code, Result[1], 4);
  i := length(data);
//  inc(ps, 4);
  move(i, Result[5], 4);
//  inc(ps, 4);
  move(data[1], Result[9], i);
}
end;

function TLV3U(code: integer; const Str: UnicodeString): RawByteString;
begin
  if Str > '' then
    Result := TLV3(code, StrToUTF8(Str))
   else
    Result := TLV3(code, '');
end;

function TLV3(code: integer; const data: RawByteString): RawByteString;
var
  s : RawByteString;
  ps : Pointer;
  i : Integer;
//  a : Integer;
begin
  i := length(data);
  SetLength(s, 4+ 4+ i);
  ps := Pointer(s);
//  a := BSwapInt(code);
//  Move(a, ps^, 4);
//  PInteger(ps)^ := BSwapInt(code);
  PInteger(ps)^ := IcsSwap32(code);

  inc(PByte(ps), 4);
//  a := BSwapInt(i);
//  Move(a, ps^, 4);
//  PInteger(ps)^ := BSwapInt(i);
  PInteger(ps)^ := IcsSwap32(i);

  inc(PByte(ps), 4);
  if i > 0 then
    Move(Pointer(data)^, ps^, i);
  Result := s;
end;

function TLV2(code: integer; const data: TDateTime): RawByteString;
var
  s : RawByteString;
  ps : Pointer;
//  i : Integer;
begin
  SetLength(s, 4+ 4+ 8);
  ps := Pointer(s);
  PInteger(ps)^ := code;

  inc(PByte(ps), 4);
//  i := 8;
//  Move(i, ps^, 4);
  PInteger(ps)^ := 8;
  inc(PByte(ps), 4);
//  Move(data, ps^, 8);
  PDateTime(ps)^ := data;
  Result := s;
end;

//function TLV2(code:integer; const data:Integer):RawByteString;
//var
//  s : RawByteString;
//  ps : Pointer;
//  i : Integer;
//begin
//  SetLength(s, 4+ 4+ 4);
//  ps := Pointer(s);
//  Move(code, ps^, 4);
//  i := 4;
//  inc(Cardinal(ps), 4);
//  Move(i, ps^, 4);
//  inc(Cardinal(ps), 4);
//  Move(data, ps^, 4);
//  Result := s;
//end;

function TLV2(code:integer; const data:Integer):RawByteString;
var
  s : RawByteString;
  ps : Pointer;
//  i : Integer;
begin
  SetLength(s, 4+ 4+ 4);
  ps := Pointer(s);
  PInteger(ps)^ := code;

  inc(PByte(ps), 4);
  PInteger(ps)^ := 4;

  inc(PByte(ps), 4);
  PInteger(ps)^ := data;

  Result := s;
end;


function TLV2(code:integer; const data:Boolean):RawByteString;
//begin result:=int2str(code)+int2str(1)+ AnsiChar(data) end;
var
  s : RawByteString;
  ps : Pointer;
//  i : Integer;
begin
  SetLength(s, 4+ 4+ 1);
  ps := Pointer(s);
//  Move(code, ps^, 4);
  PInteger(ps)^ := code;
//  i := 1;
  inc(PByte(ps), 4);
//  Move(i, ps^, 4);
  PInteger(ps)^ := 1;
//  Result[9] := AnsiChar(data);
  inc(PByte(ps), 4);
//  Move(data, ps^, 1);
  PByte(ps)^ := byte(data);
  Result := s;
end;

function TLV2_IFNN(code:integer; const data:RawByteString):RawByteString; // if data not null
begin
  if Length(data)>0 then
    result:=int2str(code)+int2str(length(data))+data
   else
    result:='';
end;

function TLV2U_IFNN(code:integer; const str:String):RawByteString; // if data not null. Unicode String
var
 s1 : RawByteString;
begin
  if str> '' then
    s1 := StrToUTF8(str)
   else
    begin
     result:='';
     Exit;
    end;
  if Length(s1)>0 then
//    result:=int2str(code)+int2str(length(s1))+s1
    result:=TLV2(code, s1)
   else
    result:='';
end;


function TLV2_IFNN(code:integer; data: Integer):RawByteString; // if data not null
begin
  if data>0 then
    result:=int2str(code)+int2str(4)+ int2str(data)
   else
    result:='';
end;

function TLV2_IFNN(code:integer; const data:TDateTime):RawByteString;
var
  s : RawByteString;
  ps : Pointer;
//  i : Integer;
begin
  if data > 0 then
   begin
    SetLength(s, 4+ 4+ 8);
    ps := Pointer(s);
//    Move(code, ps^, 4);
    PInteger(ps)^ := code;

    inc(PByte(ps), 4);
//    i := 8;
//    Move(i, ps^, 4);
    PInteger(ps)^ := 8;

    inc(PByte(ps), 4);
//    Move(data, ps^, 8);
    PDateTime(ps)^ := data;
    Result := s;
   end
  else
   Result := '';
end;

function qword_LEat(p: pointer): int64; {$IFDEF HAS_INLINE}inline;{$ENDIF HAS_INLINE}
begin
  result:=int64(p^)
end;

function Qword_BEat(p:pointer):int64; {$IFDEF HAS_INLINE}inline;{$ENDIF HAS_INLINE}
begin
//  result:=invert64(int64(p^))
  result:=IcsSwap64(int64(p^))
end;

function dword_BEat(p:pointer):LongWord; {$IFDEF HAS_INLINE}inline;{$ENDIF HAS_INLINE}
begin
//  result:= BSwapInt(integer(p^))
  result:= IcsSwap32(LongWord(p^))
end;

function dword_BEat(const s: RawByteString; ofs: integer): integer; {$IFDEF HAS_INLINE}inline;{$ENDIF HAS_INLINE}
begin
  result:=dword_BEat(@s[ofs])
end;

function dword_LEat(p: pointer): LongWord; {$IFDEF HAS_INLINE}inline;{$ENDIF HAS_INLINE}
begin
  result:=integer(p^)
end;

function word_LEat(p: pointer): word; {$IFDEF HAS_INLINE}inline;{$ENDIF HAS_INLINE}
begin
  result:=word(p^)
end;

function word_BEat(p: pointer): word; {$IFDEF HAS_INLINE}inline;{$ENDIF HAS_INLINE}
begin
  result:=swap(word(p^))
end;

function word_BEat(const s: RawByteString; ofs: integer): word; {$IFDEF HAS_INLINE}inline;{$ENDIF HAS_INLINE}
begin
  result:=word_BEat(@s[ofs])
end;

function dword_LE2ip(d: dword): AnsiString;
begin
  result:=format(AnsiString('%d.%d.%d.%d'),[byte(d shr 24),byte(d shr 16),byte(d shr 8),byte(d)])
end;

 {$IFDEF UNICODE}
function dword_LE2ipU(d: dword): UnicodeString;
begin
  result:=format('%d.%d.%d.%d',[byte(d shr 24),byte(d shr 16),byte(d shr 8),byte(d)])
end;
 {$ENDIF UNICODE}

function word_LEasStr(w: word): RawByteString;
begin
  result:=AnsiChar(w)+AnsiChar(w shr 8)
end;

function word_BEasStr(w: word): RawByteString;
begin
  result:=AnsiChar(w shr 8)+AnsiChar(w)
end;

function dword_BEasStr(d: dword): RawByteString;
begin
  result:=AnsiChar(d shr 24)+AnsiChar(d shr 16)+AnsiChar(d shr 8)+AnsiChar(d)
end;

function dword_LEasStr(d: dword): RawByteString;
begin
  result:=AnsiChar(d)+AnsiChar(d shr 8)+AnsiChar(d shr 16)+AnsiChar(d shr 24)
end;

function qword_LEasStr(d: int64): RawByteString;
begin
  setLength(result,8);
  move(d, Pointer(result)^,8);
end; // qword_LEasStr

function qword_BEasStr(d: int64): RawByteString;
begin
  setLength(result,8);
//  d := Invert64(d);
  d := IcsSwap64(d);
  move(d, Pointer(result)^, 8);
end; // qword_LEasStr

  function readBYTE(const snac: RawByteString; var ofs: integer): byte;
//  begin result:=byte((@snac[ofs])^); inc(ofs) end;
//  function readBYTE:byte;
  begin
    result:=byte(snac[ofs]);
    inc(ofs)
  end;
  function readWORD(const snac: RawByteString; var ofs: integer): word;
  begin
    result:=word_LEat(@snac[ofs]);
    inc(ofs, 2)
  end;
  function readBEWORD(const snac: RawByteString; var ofs: integer): word;
  begin
    result:=word_BEat(@snac[ofs]);
    inc(ofs, 2)
  end;
  function readINT(const snac: RawByteString; var ofs: integer): integer;
  begin
    result:=dword_LEat(@snac[ofs]);
    inc(ofs, 4)
  end;
  function readDWORD(const snac: RawByteString; var ofs: integer): cardinal;
  begin
    result:=dword_LEat(@snac[ofs]);
    inc(ofs, 4)
  end;
  function readBEDWORD(const snac: RawByteString; var ofs: integer): cardinal;
  begin
    result:=dword_BEat(@snac[ofs]);
    inc(ofs, 4)
  end;

  function readQWORD(const snac: RawByteString; var ofs: integer): Int64;
  begin
    result:=Qword_LEat(@snac[ofs]);
    inc(ofs, 8)
  end;


function int2str64(i:Int64):RawByteString;
var
  v : RawByteString;
begin
  setLength(v, 8);
  move(i, Pointer(v)^, 8);
  Result := v;
end;

function dt2str(dt:Tdatetime):RawByteString;
var
  v : RawByteString;
begin
  setLength(v, 8);
  move(dt, Pointer(v)^, 8);
  Result := v;
end;

function str2int(const s: RawByteString): integer;
begin
  result:=dword_LEat(Pointer(s))
end;

function str2int(p: pointer): integer;
begin
  result:=dword_LEat(p)
end;

end.

