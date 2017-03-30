{
  This file is part of R&Q.
  Under same license
}
unit RDUtils;
{$I ForRnQConfig.inc}
{$I NoRTTI.inc}

interface
uses
  Windows, sysutils, classes, graphics, forms, types, RDGlobal;

function  IfThen(AValue: Boolean; const ATrue: Integer; const AFalse: Integer = 0): Integer; overload;
function  IfThen(AValue: Boolean; const s1, s2: RawByteString): RawByteString; overload; {$IFDEF HAS_INLINE} inline; {$ENDIF HAS_INLINE}

function  packArray(a: array of Integer; zero: Integer): TintegerDynArray;
function  compareInt(a, b: Integer): Smallint; OverLoad;
function  compareInt(a, b: int64): Smallint; OverLoad;
function  CompareDate(a, b: TDateTime): Smallint;
function  boundInt(var i: Integer; min, max: Integer): Integer;
function  bound(i: Integer; min, max: Integer): Integer;
function  within(pt: Tpoint; x, y, w, h: Integer): boolean; overload; {$IFDEF HAS_INLINE} inline; {$ENDIF HAS_INLINE}
function  within(a, b, c: Integer): boolean; overload; {$IFDEF HAS_INLINE} inline; {$ENDIF HAS_INLINE}
function  DestRect(const W, H, cw, ch: Integer): TGPRect; overload;
function  DestRect(const PicSize, DestSize: TGPSize): TGPRect; overload;
function  BoundsSize(srcSize, maxSize: TSize): TSize; overload;
function  BoundsSize(srcCX, srcCY, maxCX, maxCY: Longint): TSize; overload;
// strings
function  isURL(const s: string; ofs: Integer=1): boolean;
function  ipos(const ss: string; const s: string): Integer;
function  capitalize(const s: string): string;
procedure convertAllNewlinesToCRLF(var s: string);
function  separated(const sep: string; ss: array of string): string;
function  template(const src: string; table: array of string): string;
 {$IFDEF UNICODE}
 overload;
function  template(const src: AnsiString; table: array of AnsiString): AnsiString; overload;
 {$ENDIF UNICODE}
//function  TLV(code: Integer; data: String): String;
function  newline2slashn(s: String): String;
function  excludeTrailingCRLF(const s: String): String;
function  dupAmperstand(const s: String): String;
function  onlyDigits(const s: String): string; overload;
function  matches(const s: String; from: Integer; const sub: String): boolean; {$IFDEF HAS_INLINE} inline; {$ENDIF HAS_INLINE}
function  matchesA(const s: RawByteString; from: Integer; const sub: RawByteString): Boolean; {$IFDEF HAS_INLINE} inline; {$ENDIF HAS_INLINE}
function  Imatches(const s: String; from: Integer; const sub: String): Boolean;
function  dupString(const s: AnsiString): AnsiString; {$IFDEF UNICODE}overload; {$IFDEF HAS_INLINE} inline; {$ENDIF HAS_INLINE}
function  dupString(const s: String): String; overload; inline;
                                              {$ENDIF UNICODE}
function  trailing(const s, ss: string): Boolean;
procedure swap4(var a, b: Integer); overload;
procedure swap4(var src, dest; count: dword; cond: Boolean); overload;
procedure swap8(var a, b: TDateTime);
// Convert
function  ip2str(ip: Integer): String; {$IFDEF HAS_INLINE} inline; {$ENDIF HAS_INLINE}
function  str2ip(const s: RawByteString): Integer;
function  qword_BE2verU(d: UInt64): String;
function  qword_LE2verU(d: UInt64): String;
function  bool2str(const b: Boolean): RawByteString;
  function ABCD_ADCB(d: dword): dword; assembler;
  function str2color(const s: AnsiString): Tcolor;
  function color2str(color: Tcolor): AnsiString;
  function color2strU(color: Tcolor): String;
  function IntToHexA(Value: Integer; Digits: Integer): AnsiString; {$IFNDEF UNICODE}{$IFDEF HAS_INLINE} inline; {$ENDIF HAS_INLINE}{$ENDIF UNICODE}
  function IntToStrA(Value: Integer): AnsiString; {$IFNDEF UNICODE}{$IFDEF HAS_INLINE} inline; {$ENDIF HAS_INLINE}{$ENDIF UNICODE}  overload;
  function intToStrA(i, d: Integer): AnsiString; overload;
  function intToStr(i, d: Integer): string; overload;
  function strToIntA(s: RawByteString): Integer;

// Strings
  function WideBEToUTF8(const Value: RawByteString): RawByteString;
// function unUTF(const s: AnsiString) : AnsiString;
  function UnUTF(const s: RawByteString): String;
  function UTF(const s: String): RawByteString; inline; deprecated 'Use UTF8Encode instead';
  function StrToUTF8(const Value: AnsiString): RawByteString; OverLoad;
  function StrToUnicode(const Value: AnsiString): RawByteString; overload;
  function StrToUnicodeLE(const Value: AnsiString): AnsiString; overload;
 {$IFDEF UNICODE}
  function WideBEToStr(const Value: RawByteString): UnicodeString;
  function StrToUTF8(const Value: UnicodeString): RawByteString; OverLoad;
  function StrToUnicode(const Value: String): RawByteString; overload;
  function StrToUnicodeLE(const Value: String): RawByteString; overload;
 {$ENDIF UNICODE}

  function UTF8ToStr(const Value: RawByteString): String;
//  function UTF8ToStrSmart(const Value: RawByteString): String;
// function UTF8ToStrSmart(Value: String): String;
// function UnWideStr(s : String) : String;
//procedure StrSwapByteOrder(Str: PWideChar);
 {$IFDEF UNICODE} {$IF CompilerVersion >= 24}
  function RnQEndsText(const ASubText, AText: UnicodeString): Boolean;
{$ELSE}
  function RnQEndsText(const ASubText, AText: UnicodeString): Boolean; inline;
 {$IFEND ver} {$ENDIF UNICODE}

  function TBytesToString(B: TBytes; CodePage: Integer = CP_UTF8): string;
  function StringToTBytes(S: string; CodePage: Integer = CP_UTF8): TBytes;


// strings
 {$IFDEF UNICODE}
  function  findInStrings(const s: AnsiString; ss: Tstrings): Integer; overload;
 {$ENDIF UNICODE}
  function  findInStrings(const s: AnsiString; ss: array of AnsiString): Integer; overload;
  function  findInStrings(const s: AnsiString; ss, separator: RawByteString): Integer; overload;
  function  findInStrings(const s: String; ss: Tstrings): Integer; overload;

  function  chop(i: Integer; var s: RawByteString): RawByteString; overload; {$IFDEF HAS_INLINE} inline; {$ENDIF HAS_INLINE}
  function  chop(i, l: Integer; var s: RawByteString): RawByteString; overload;
  function  chop(const ss: RawByteString; var s: RawByteString): RawByteString; overload;
  function  chopline(var s: RawByteString): RawByteString; overload;
  function  choplineV(const s: RawByteString; var pos0: Integer): RawByteString;

 {$IFDEF UNICODE}
{ split S in position where SS is found, the first part is returned
  the second part following SS is left in S }
  function chop(const ss: String; var s: UnicodeString): String; overload;
// same as before, but specifying separator length
  function chop(i, l: Integer; var s: UnicodeString): String; overload;
// same as before, but separator is I
  function chop(i: Integer; var s: UnicodeString): String; overload;
// same as chop(lineterminator, s)
  function chopline(var s: UnicodeString): String; overload;
 {$ENDIF UNICODE}

 {$IFDEF UNICODE}
  function  isOnlyDigits(const s: AnsiString): Boolean; overload;
  function  isOnlyDigits(const s: UnicodeString): Boolean; overload;
 {$ELSE ~UNICODE}
  function  isOnlyDigits(const s: AnsiString): Boolean;
 {$ENDIF UNICODE}
//  function  UnDelimiter(s: String): String;
  function  BetterStr(const s: AnsiString): AnsiString;
  function BetterStrS(const s: String): String;

 function IsEqualGUID(const guid1, guid2: TGUID): Boolean; stdcall;
{$EXTERNALSYM IsEqualGUID}
 function SGUID2rGUID(const guid: RawByteString; Zero2Empty: Boolean = True): RawByteString;
 function GUID2rGUID(const guid: TGUID): RawByteString;


// convert
  function str2valor(const s: Ansistring): Int64;
  function hex2Str(const s: RawByteString): RawByteString;
  function hex2StrSafe(const s: RawByteString): RawByteString;

  function hex2StrU(const s: String): RawByteString;

  function PacketToHex(Buffer: Pointer; BufLen: Word): AnsiString;
  function  hexDump(const data: RawByteString): AnsiString;
  function  hexDumpS(const data: RawByteString): String;

  function str2hex(const s: RawByteString): AnsiString; overload;
  function str2hexU(const s: RawByteString): String; overload;
  function str2hex(const s: RawByteString; const Delim : AnsiChar) : AnsiString; overload;
  function  hexToInt(const s: RawByteString): Cardinal; overload;
  function  hexToInt(const s: String): Cardinal; overload;
  function  strings2str(const split: string; ss: Tstrings): string; overload;
  function  strings2str(const split: string; const ss: array of string):string; overload;
  procedure str2strings(const split: String; src: string; var ss: Tstrings); deprecated;
  function  size2str(sz: Int64): String;

//  function  bmp2wbmp(bmp : TBitmap) : String;
//  procedure wbmp2bmp(Stream: TStream; var pic : TBitmap);
//  procedure wbmp2bmp(s: String; pic : TBitmap);

  function  Rgb2Gray(RGBColor: TColor): byte;

  function DoubleAsInt64(Value: double): int64; {$IFDEF HAS_INLINE} inline; {$ENDIF HAS_INLINE}
  function Int64AsDouble(Value: int64): double; {$IFDEF HAS_INLINE} inline; {$ENDIF HAS_INLINE}
  function TryStrToLongWord(const S: string; var Value: LongWord): Boolean;

{ $IFNDEF UNICODE }
var
  RnQDefaultSystemCodePage: Integer;
{ $ENDIF UNICODE }


implementation
  uses
    StrUtils, Math,
  {$IFDEF UNICODE}
    Character, AnsiStrings,
  {$ENDIF UNICODE}
    RnQBinUtils;

const
  ole32    = 'ole32.dll';



function IfThen(AValue: Boolean; const ATrue: Integer; const AFalse: Integer = 0): Integer; {$IFDEF HAS_INLINE} inline; {$ENDIF HAS_INLINE}
begin
  if avalue then
    result := atrue
   else
    result := afalse
end;

function IfThen(AValue: Boolean; const s1, s2: RawByteString): RawByteString; {$IFDEF HAS_INLINE} inline; {$ENDIF HAS_INLINE}
begin
  if avalue then
    result := s1
   else
    result := s2
end;


function packArray(a: array of Integer; zero: Integer): TintegerDynArray;
var
  i, n: Integer;
begin
  n := 0;
  setlength(result, length(a));
  for i:=0 to length(a)-1 do
    if a[i]<>zero then
      begin
      result[n] := a[i];
      inc(n);
      end;
  SetLength(result, n);
end; // packArray

function compareInt(a, b: Integer): Smallint;
begin
  if a<b then
    result := -1
   else
    if a>b then
      result := +1
     else
      result := 0
end; // compareInt

function compareInt(a, b: int64): Smallint;
begin
  if a<b then
    result := -1
   else
    if a>b then
      result := +1
     else
      result := 0
end; // compareInt

function CompareDate(a, b: TDateTime): Smallint;
begin
  if a<b then
    result := -1
   else
    if a>b then
      result := +1
     else
      result := 0
end;

function boundInt(var i: Integer; min, max: Integer): Integer;
begin
  if i > max then
    i := max;
  if i < min then
    i := min;
  result := i;
end; // boundInt

function bound(i: Integer; min, max: Integer): Integer;
begin
  if i > max then
     result := max
   else
     if i < min then
       result := min
      else
       result := i;
end; // boundInt

function within(a, b, c: Integer): boolean; overload; {$IFDEF HAS_INLINE} inline; {$ENDIF HAS_INLINE}
begin
  result := (b>=a) and (b<=c)
end;

function within(pt: Tpoint; x, y, w, h: Integer): boolean; overload; {$IFDEF HAS_INLINE} inline; {$ENDIF HAS_INLINE}
begin
  result := (pt.x>=x) and (pt.y>=y) and (pt.x < x+w) and (pt.y < y+h)
end;

function BoundsSize(srcCX, srcCY, maxCX, maxCY : Longint): TSize;
begin
  if (srcCX > maxCX )
   or (srcCY > maxCY) then
  begin
   if srcCX * maxCY < srcCY * maxCX then
     begin
       Result.cx := maxCY * srcCX div srcCY;
//       Result.cx := MulDiv(maxCY, srcCX, srcCY);
       Result.cy := maxCY;
     end
    else
     begin
       Result.cx := maxCX;
       Result.cy := maxCX * srcCY div srcCX;
//       Result.cy := MulDiv(maxCX, srcCY, srcCX);
     end;
  end
  else
   begin
    result.cx := srcCX;
    result.cy := srcCY;
   end;
end;

function BoundsSize(srcSize, maxSize: TSize): TSize;
begin
  if (srcSize.cx > maxSize.cx )
   or (srcSize.cy > maxSize.cy) then
  begin
   if srcSize.cx * maxSize.cy < srcSize.cy * maxSize.cx then
     begin
       Result.cx := maxSize.cy*srcSize.cx div srcSize.cy;
//       Result.cx := MulDiv(maxSize.cy, srcSize.cx, srcSize.cy);
       Result.cy := maxSize.cy;
     end
    else
     begin
       Result.cx := maxSize.cx;
       Result.cy := maxSize.cx*srcSize.cy div srcSize.cx;
     end;
  end
  else
   result := srcSize;
end;

{function DestRect(W, H, cw, ch: Integer): TRect;
const
  Stretch = false;
  Proportional = True;
  Center  = True;
var
//  w, h, cw, ch: Integer;
  xyaspect: Double;
begin
//  w := Picture.GetWidth;
//  h := Picture.GetHeight;
//  cw := ClientWidth;
//  ch := ClientHeight;
  if Stretch or (Proportional and ((w > cw) or (h > ch))) then
  begin
    if Proportional and (w > 0) and (h > 0) then
    begin
      xyaspect := w / h;
      if w > h then
      begin
        w := cw;
        h := Trunc(cw / xyaspect);
        if h > ch then  // woops, too big
        begin
          h := ch;
          w := Trunc(ch * xyaspect);
        end;
      end
      else
      begin
        h := ch;
        w := Trunc(ch * xyaspect);
        if w > cw then  // woops, too big
        begin
          w := cw;
          h := Trunc(cw / xyaspect);
        end;
      end;
    end
    else
    begin
      w := cw;
      h := ch;
    end;
  end;

  with Result do
  begin
    Left := 0;
    Top := 0;
    Right := w;
    Bottom := h;
  end;

  if Center then
    OffsetRect(Result, (cw - w) div 2, (ch - h) div 2);
end;}

function DestRect(const W, H, cw, ch: Integer): TGPRect;
const
  Stretch = false;
  Proportional = True;
  Center  = True;
var
//  w, h, cw, ch: Integer;
  xyaspect: Double;
//  i, j : Integer;
begin
//  w := Picture.GetWidth;
//  h := Picture.GetHeight;
//  cw := ClientWidth;
//  ch := ClientHeight;
  with Result do
  begin
//    X := 0;
//    Y := 0;
    Width := min(cW, w);
    Height := min(cH, h);
  end;

  if Stretch or (Proportional and ((w > cw) or (h > ch))) then
  begin
    if Proportional and (w > 0) and (h > 0) then
    begin
      xyaspect := w / h;
      if w > h then
      begin
//        w := cw;
//        Result.Width := cw;
        Result.Height := Trunc(cw / xyaspect);
        if Result.Height > ch then  // woops, too big
        begin
          Result.Height := ch;
          Result.Width := Trunc(ch * xyaspect);
        end;
      end
      else
      begin
//        h := ch;
        Result.Width := Trunc(ch * xyaspect);
        if Result.Width > cw then  // woops, too big
        begin
          Result.Width := cw;
          Result.Height := Trunc(cw / xyaspect);
        end;
      end;
    end
{    else
    begin
      w := cw;
      h := ch;
    end;}
  end;

  if Center then
   begin
//    OffsetRect(Result, (cw - w) div 2, (ch - h) div 2);
//     inc(Result.X, (cw - w) div 2);
//     inc(Result.Y, (ch - h) div 2);
     Result.X := (cw - Result.Width) div 2;
     Result.Y := (ch - Result.Height) div 2;
   end;
end;

function  DestRect(const PicSize, DestSize: TGPSize): TGPRect;
const
  Stretch = false;
  Proportional = True;
  Center  = True;
var
//  w, h, cw, ch: Integer;
  xyaspect: Double;
begin
//  w := Picture.GetWidth;
//  h := Picture.GetHeight;
//  cw := ClientWidth;
//  ch := ClientHeight;
//  Result.size := DestSize;
  with Result do
  begin
//    X := 0;
//    Y := 0;
    Width := min(DestSize.Width, PicSize.Width);
    Height := min(DestSize.Height, PicSize.Height);
    Width := max(Width, 0);
    Height := max(Height, 0);
  end;
  if Stretch or (Proportional and ((PicSize.Width > DestSize.Width)
                               or (PicSize.Height > DestSize.Height))) then
  begin
    if Proportional and (PicSize.Width > 0) and (PicSize.Height > 0) then
    begin
      xyaspect := PicSize.Width / PicSize.Height;
      if PicSize.Width > PicSize.Height then
      begin
//        Result.Width := DestSize.Width;
        Result.Height := Trunc(DestSize.Width / xyaspect);
        if Result.Height > DestSize.Height then  // woops, too big
        begin
          Result.Height := DestSize.Height;
          Result.Width := Trunc(DestSize.Height * xyaspect);
        end;
      end
      else
      begin
//        Result.Height := DestSize.Height;
        Result.Width := Trunc(DestSize.Height * xyaspect);
        if Result.Width > DestSize.Width then  // woops, too big
        begin
          Result.Width := DestSize.Width;
          Result.Height := Trunc(DestSize.Width / xyaspect);
        end;
      end;
    end
{    else
    begin
      Result.Width := DestSize.Width;
      Result.Height := DestSize.Height;
    end;}
  end
  ;
{
  with Result do
  begin
    X := 0;
    Y := 0;
    Width := w;
    Height := h;
  end;
}
  if Center then
   begin
//    OffsetRect(Result, (cw - w) div 2, (ch - h) div 2);
//     inc(Result.X, (DestSize.Width - Result.Width) div 2);
//     inc(Result.Y, (DestSize.Height - Result.Height) div 2);
     Result.X := (DestSize.Width - Result.Width) div 2;
     Result.Y := (DestSize.Height - Result.Height) div 2;
   end
  else
   begin
     Result.X := 0;
     Result.Y := 0;
   end
end;


function isURL(const s: String; ofs: Integer=1): Boolean;
begin
 {$IFDEF UNICODE}
 while (Integer(s[ofs]) <= $7F) and
        (((s[ofs] >= '0') and (s[ofs] <= '9')) or s[ofs].IsLetter()) do
 {$ELSE nonUNICODE}
 while s[ofs] in ['0'..'9','a'..'z','A'..'Z'] do
 {$ENDIF UNICODE}
  inc(ofs);
result:= copy(s,ofs,3) = '://' ;
end; // isURL

function ipos(const ss: string; const s: string): Integer;
begin
  for result:=1 to length(s) do
    if ansiCompareText(ss, copy(s,result,length(ss)))=0 then
      exit;
  result:=0;
end; // ipos

function capitalize(const s: string): string;
begin
 result := s;
 if result>'' then
   result[1] := upcase(result[1]);
end; // capitalize

procedure convertAllNewlinesToCRLF(var s: string);
//var
//  i: Integer;
begin
  s := AdjustLineBreaks(s, tlbsCRLF);
{i:=length(s);
while i>0 do
  begin
  case s[i] of
    #13: if (i=length(s)) or (s[i+1]<>#10) then insert(#10,s,i+1);
    #10: if (i=1) or (s[i-1]<>#13) then insert(#13,s,i);
    end;
  dec(i);
  end}
end; // convertAllNewlinesToCRLF

function separated(const sep: string; ss: array of string): string;
var
  i: Integer;
begin
  result := '';
  for i:=0 to length(ss)-1 do
    if ss[i] > '' then
      result := result+ifThen(result>'', ',')+ss[i];
end; // separated

function template(const src: string; table: array of string): string;
var
  i: Integer;
begin
  result := src;
  i := 0;
  while i < length(table) do
   begin
//    result:=AnsiReplaceText(result, table[i], table[i+1]);
    result := AnsiReplaceStr(result, table[i], table[i+1]);
    inc(i,2);
   end;
end; // template

 {$IFDEF UNICODE}
function  template(const src: AnsiString; table: array of AnsiString): AnsiString;
var
  i: Integer;
begin
  result := src;
  i := 0;
  while i < length(table) do
   begin
//    result:=AnsiReplaceText(result, table[i], table[i+1]);
    result := AnsiReplaceStr(result, table[i], table[i+1]);
    inc(i, 2);
   end;
end; // template
 {$ENDIF UNICODE}

function newline2slashn(s: string): string;
var
  i: Integer;
begin
  repeat
  i := pos(#13,s);
  if i>0 then
    begin
    s[i] := '\';
    if (i>=length(s)) or (s[i+1]<>#10) then
      insert('n',s,i)
    else
      s[i+1] := 'n';
    end;
  until i=0;
  result := s;
end; // newline2slashn


function onlyDigits(const s: string): string;
var
  i: Integer;
begin
  i := 1;
//  t := 1;
  Result := Copy(s, 1, length(s));
  while i <= length(Result) do
//  if s[i] in ['0'..'9'] then
  if s[i].IsDigit then
//   if Result[i].IsDigit then
     inc(i)
    else
     delete(Result,i,1);
//result:=s;
end; // onlyDigits

function matches(const s: String; from: Integer; const sub: String): Boolean; {$IFDEF HAS_INLINE} inline; {$ENDIF HAS_INLINE}
//begin result:=sub=copy(s,from,length(sub)) end;
//begin result:=AnsiPos(sub, s) = from end;
var
{$IFDEF MSWINDOWS}
  P: PChar;
{$ENDIF}
  L, L2: Integer;
begin
  dec(from);
{$IFDEF MSWINDOWS}
//  P := PChar(s)+from;
  p := PChar(@s[1]) + from;
{$ENDIF}
  L := Length(sub);
  L2 := Length(s)-from;
  if L > L2 then
    Result := False
  else
{$IFDEF MSWINDOWS}
    Result := CompareString(LOCALE_USER_DEFAULT, 0, //NORM_IGNORECASE,
      P, L, PChar(sub), L) = 2;
{$ENDIF}
{$IFDEF LINUX}
    Result := WideSameText(ASubText, Copy(AText, 1, L));
{$ENDIF}
end;

function matchesA(const s: RawByteString; from: Integer; const sub: RawByteString): Boolean; {$IFDEF HAS_INLINE} inline; {$ENDIF HAS_INLINE}
//begin result:=sub=copy(s,from,length(sub)) end;
//begin result:=AnsiPos(sub, s) = from end;
var
{$IFDEF MSWINDOWS}
  P: PAnsiChar;
{$ENDIF}
  L, L2: Integer;
begin
  dec(from);
{$IFDEF MSWINDOWS}
//  P := PChar(s)+from;
  p := PAnsiChar(@s[1]) + from;
{$ENDIF}
  L := Length(sub);
  L2 := Length(s)-from;
  if L > L2 then
    Result := False
  else
{$IFDEF MSWINDOWS}
    Result := CompareStringA(LOCALE_USER_DEFAULT, 0, //NORM_IGNORECASE,
      P, L, PAnsiChar(sub), L) = 2;
{$ENDIF}
{$IFDEF LINUX}
    Result := SameText(ASubText, Copy(AText, 1, L));
{$ENDIF}
end;

function Imatches(const s: String; from: Integer; const sub: String): Boolean;
//begin result:=compareText(sub,copy(s,from,length(sub)))=0 end;
var
{$IFDEF MSWINDOWS}
  P: PChar;
{$ENDIF}
  L, L2: Integer;
begin
  dec(from);
{$IFDEF MSWINDOWS}
  P := PChar(s)+from;
{$ENDIF}
  L := Length(sub);
  L2 := Length(s)-from;
  if L > L2 then
    Result := False
  else
{$IFDEF MSWINDOWS}
    Result := CompareString(LOCALE_USER_DEFAULT, NORM_IGNORECASE,
      P, L, PChar(sub), L) = 2;
{$ENDIF}
{$IFDEF LINUX}
    Result := WideSameText(ASubText, Copy(AText, 1, L));
{$ENDIF}
end;

function dupString(const s: AnsiString): AnsiString;
begin
  result := copy(s, 1, length(s))
end;

{$IFDEF UNICODE}
function dupString(const s: string): string;
begin
  result := copy(s, 1, length(s))
end;
{$ENDIF UNICODE}

function trailing(const s, ss: String): Boolean;
begin
  result := ss=copy(s,length(s)-length(ss)+1,length(ss))
end;


function bool2str(const b: Boolean): RawByteString;
begin
  result := AnsiChar(b)
end;

function ABCD_ADCB(d: dword): dword; assembler;
 asm
  mov EAX, d
  ror EAX, 16
  ror AX, 8
  rol EAX, 16
  ror AX, 8
  rol EAX, 8
end; // ABCD_ADCB

 {$IFDEF UNICODE}
function color2strU(color: Tcolor): UnicodeString;
begin
  if not ColorToIdent(Color, Result) then
    begin
      color := ABCD_ADCB(ColorToRGB(color));
      result := intToHex(color, 6);
    end;
end;
 {$ENDIF UNICODE}

function color2str(color: Tcolor): AnsiString;
 {$IFDEF UNICODE}
var
  res: String;
begin
//color := ABCD_ADCB(ColorToRGB(color));
  if ColorToIdent(Color, Res) then
    Result := AnsiString(res)
   else
    begin
      color := ABCD_ADCB(ColorToRGB(color));
      result := IntToHexA(color,6);
    end;
 {$ELSE nonUNICODE}
begin
//color := ABCD_ADCB(ColorToRGB(color));
  if not ColorToIdent(Color, Result) then
    begin
      color := ABCD_ADCB(ColorToRGB(color));
      result := intToHex(color,6);
    end;
 {$ENDIF UNICODE}
end; // color2str

function str2color(const s: AnsiString): Tcolor;
begin
  if length(s) = 0 then
    result := -1
   else
    if s[1]='$' then
      result := ABCD_ADCB(stringToColor(String(s)))
     else
      if (length(s) > 2) and (upcase(s[1])='C') and (upcase(s[2])='L') then
        result := stringToColor(String(s))
       else
        result := ABCD_ADCB(stringToColor('$' + String(s)))
end; // str2color


 {$IF DEFINED(WIN64) OR DEFINED(FPC)}
  function IntToHexA(Value: Integer; Digits: Integer): AnsiString; {$IFDEF HAS_INLINE} inline; {$ENDIF HAS_INLINE}
  begin
    Result := IntToHex(Value, Digits);
  end;
  function IntToStrA(Value : Integer) : AnsiString; {$IFDEF HAS_INLINE} inline; {$ENDIF HAS_INLINE}
  begin
    Result := intToStr(Value);
  end;

 {$ELSE win32}
// {$IF DEFINED(UNICODE) AND DEFINED(WIN32) AND DEFINED(X86ASM)}
 {$IF DEFINED(UNICODE) AND DEFINED(WIN32)}
procedure CvtInt;
{ IN:
    EAX:  The integer value to be converted to text
    ESI:  Ptr to the right-hand side of the output buffer:  LEA ESI, StrBuf[16]
    ECX:  Base for conversion: 0 for signed decimal, 10 or 16 for unsigned
    EDX:  Precision: zero padded minimum field width
  OUT:
    ESI:  Ptr to start of converted text (not start of buffer)
    ECX:  Length of converted text
}
asm // StackAlignSafe
        OR      CL,CL
        JNZ     @CvtLoop
@C1:    OR      EAX,EAX
        JNS     @C2
        NEG     EAX
        CALL    @C2
        MOV     AL,'-'
        INC     ECX
        DEC     ESI
        MOV     [ESI],AL
        RET
@C2:    MOV     ECX,10

@CvtLoop:
        PUSH    EDX
        PUSH    ESI
@D1:    XOR     EDX,EDX
        DIV     ECX
        DEC     ESI
        ADD     DL,'0'
        CMP     DL,'0'+10
        JB      @D2
        ADD     DL,('A'-'0')-10
@D2:    MOV     [ESI],DL
        OR      EAX,EAX
        JNE     @D1
        POP     ECX
        POP     EDX
        SUB     ECX,ESI
        SUB     EDX,ECX
        JBE     @D5
        ADD     ECX,EDX
        MOV     AL,'0'
        SUB     ESI,EDX
        JMP     @z
@zloop: MOV     [ESI+EDX],AL
@z:     DEC     EDX
        JNZ     @zloop
        MOV     [ESI],AL
@D5:
end;

function IntToHexA(Value: Integer; Digits: Integer): AnsiString;
//  FmtStr(Result, '%.*x', [Digits, Value]);
asm
        CMP     EDX, 32        // Digits < buffer length?
        JBE     @A1
        XOR     EDX, EDX
@A1:    PUSH    ESI
        MOV     ESI, ESP
        SUB     ESP, 32
        PUSH    ECX            // result ptr
        MOV     ECX, 16        // base 16     EDX = Digits = field width
        CALL    CvtInt
        MOV     EDX, ESI
        POP     EAX            // result ptr
(*{$IF DEFINED(Unicode)}
        CALL    System.@UStrFromPCharLen
{$ELSE}*)
        PUSH    RnQDefaultSystemCodePage
        CALL    System.@LStrFromPCharLen
//{$IFEND}
        ADD     ESP, 32
        POP     ESI
end;

function IntToStrA(Value: Integer): AnsiString;
//  FmtStr(Result, '%d', [Value]);
asm
        PUSH    ESI
        MOV     ESI, ESP
        SUB     ESP, 16
        XOR     ECX, ECX       // base: 0 for signed decimal
        PUSH    EDX            // result ptr
        XOR     EDX, EDX       // zero filled field width: 0 for no leading zeros
        CALL    CvtInt
        MOV     EDX, ESI
        POP     EAX            // result ptr
(*{$IF DEFINED(Unicode)}
        CALL    System.@UStrFromPCharLen
{$ELSE}*)
        PUSH    RnQDefaultSystemCodePage
        CALL    System.@LStrFromPCharLen
//{$IFEND}
        ADD     ESP, 16
        POP     ESI
end;
 {$ELSE nonUNICODE}
{$IF CompilerVersion >= 24}
  {$MESSAGE FATAL 'Must be UNICODE.'}
{$ENDIF}

  function IntToHexA(Value: Integer; Digits: Integer): AnsiString; {$IFDEF HAS_INLINE} inline; {$ENDIF HAS_INLINE}
  begin
    Result := IntToHex(Value, Digits);
  end;
  function IntToStrA(Value: Integer): AnsiString; {$IFDEF HAS_INLINE} inline; {$ENDIF HAS_INLINE}
  begin
    Result := intToStr(Value);
  end;
// {$ENDIF UNICODE}
 {$ENDIF UNICODE}
 {$ENDIF win64}
function intToStr(i, d: Integer): string; overload;
begin
  result := intToStr(i);
  while length(result) < d do
    result := '0'+result;
end; // intToStr

function intToStrA(i, d: Integer): AnsiString; overload;
begin
  result := intToStrA(i);
  while length(result) < d do
    result := '0'+result;
end; // intToStr

function strToIntA(s: RawByteString): Integer;
begin
  Result := StrToInt(String(s));
end;

function excludeTrailingCRLF(const s: string): string;
var
  i: Integer;
begin
  result := '';
  i := length(s);
//  if s='' then
  if i = 0 then
    exit;
//  while (i > 0) and (s[i] in [#10, #13]) do
  while (i > 0) and CharInSet(s[i], [#10, #13]) do
    dec(i);
//  setLength(s,i);
//if s[length(s)]=#10 then setLength(s,length(s)-1);
//if s[length(s)]=#13 then setLength(s,length(s)-1);
//result := s;
  result := copy(s, 1, i);
end; // excludeTrailingCRLF

function dupAmperstand(const s: string): string;
var
  i, last: Integer;
begin
  result := '';
  last := 1;
  for i:=1 to length(s) do
    if s[i]='&' then
      begin
        result := result + copy(s,last,i-last+1) + '&';
        last := i+1;
      end;
  if last<=length(s) then
    result := result+copy(s,last,length(s)-last+1);
end; // dupAmperstand

{function max(a, b: double): double;
begin if a > b then result:=a else result:=b end;

function min(a,b:double):double;
begin if a < b then result:=a else result:=b end;
 }
procedure swap4(var a, b: Integer);
var
  bak: Integer;
begin
  bak := a;
  a := b;
  b := bak;
end; // swap

procedure swap4(var src, dest; count: dword; cond: boolean);
var
  temp: pointer;
begin
  if not cond then
    exit;
  getmem(temp, count);
  move(src, temp^, count);
  move(dest, src, count);
  move(temp^, dest, count);
  freemem(temp, count);
{  asm
  mov ESI, src
  mov EDI, dest
  mov ECX, count
@L:
  mov AL, [ESI]
  xchg AL, [EDI]
  mov [ESI], AL
  inc ESI
  inc EDI
  loop @L
  end;}
end; // swapMem

procedure swap8(var a, b: TDateTime);
var
  bak: TDateTime;
begin
  bak := a;
  a := b;
  b := bak;
end;

 {$IFDEF UNICODE}
function ip2str(ip: Integer): String; inline;
begin
  result := dword_LE2ipU(ip)
end;
 {$ELSE nonUNICODE}
function ip2str(ip: Integer): RawByteString; {$IFDEF HAS_INLINE} inline; {$ENDIF HAS_INLINE}
begin
  result := dword_LE2ip(ip)
end;
 {$ENDIF UNICODE}

function str2ip(const s: RawByteString): Integer;
var
  i, v: Integer;
//  cd: Integer;
  p: Integer;
  s1: String;
begin
  result := 0;
  p := 1;
  try
    repeat
      result := result shl 8;
      i := pos(AnsiString('.'), s, p);
      if i > 0 then
       begin
        s1 := String(copy(s, p, i-p));
        v := StrToInt(s1);
  //      Val(copy(s,1,i-1), v, cd);
  //      if cd <> 0 then
  //        v := 0;
        inc(result, v);
        p := i+1;
//        delete(s, 1, i);
       end;
    until i = 0;
    // BY Rapid
    if (p>1) and (p <= length(s)) then
//      if s <> '' then
     inc(result, strToInt(String(copy(s, p, length(s)))))
    else
      result := 0;
   except
    result := 0;
  end;
end; // str2ip

function qword_BE2verU(d: UInt64): String;
begin
  result := format(String('%d.%d.%d.%d'),[word(d), word(d shr 16), word(d shr 32), word(d shr 48)])
end;

function qword_LE2verU(d: UInt64): String;
begin
  result := format(String('%d.%d.%d.%d'),[word(d shr 48), word(d shr 32), word(d shr 16), word(d)])
end;

//procedure SwapWordByteOrder(P: PByte; Len: Cardinal);
//var
//  B: Byte;
procedure SwapWordByteOrder(P: PAnsiChar; Len: Cardinal);
var
  B: AnsiChar;
begin
  while Len > 0 do
  begin
    B := P[0];
    P[0] := P[1];
    P[1] := B;
    Inc(P, 2);
    Dec(Len, 2);
  end;
end;

procedure StrSwapByteOrder(Str: PWideChar);
var
  P: PWord;
begin
  P := PWord(Str);
  While (P^ <> 0) do
  begin
    P^ := MakeWord(HiByte(P^), LoByte(P^));
    Inc(P);
  end;
end;

{
procedure StrSwapByteOrder(Str: PWideChar);
// exchanges in each character of the given string the low order and high order
// byte to go from LSB to MSB and vice versa.
// EAX contains address of string
asm
       PUSH    ESI
       PUSH    EDI
       MOV     ESI, EAX
       MOV     EDI, ESI
       XOR     EAX, EAX // clear high order byte to be able to use 32bit operand below
@@1:
       LODSW
       OR      EAX, EAX
       JZ      @@2
       XCHG    AL, AH
       STOSW
       JMP     @@1
@@2:
       POP     EDI
       POP     ESI
end;}

{function UnWideStr(s : AnsiString) : AnsiString;
begin
  result := s;
  if (Length(result) > 1)
     and ((result[1] < #5)or(result[2] < #5) or((result[1] = #255)and (result[2] = #254)))
     and not odd(Length(result)) then
   begin
     if (result[1] < #5) then
      StrSwapByteOrder(PWideChar(result));
//     result := #255#254 + result;
//     result := StringToWideStringEx(ws, CP_ACP);
//     result := utf8ToAnsi(result);
     result := WideCharToString(PWidechar(result));
//   result := ws;
//     UnicodeToUtf8(Pchar(Result), Length(result), PWideChar(result), Length(result));
//     result :=WideStringToStringEx(#255#254+result, CP_UTF8);
//     result := WideStringToStringEx(#255#254+result, CP_ACP);
//       result := TranslateString(result, CP_UTF8, CP_ACP);
//     result := Utf8ToAnsi(#255#254+result);
     //UTF8ToStrSmart(WideStringToUTF8(#255#254+result));
//     UTF8ToWideString(result);
   end;
end;


function UnUTF(const s : AnsiString) : AnsiString;
begin
  result := UTF8ToStrSmart(UnWideStr(s));
end;
}

{Convert string to UTF8 format}


{Convert string from UTF-8 format into ASCII}
function UTF8ToStr(const Value: RawByteString): String;
const
  MB_ERR_INVALID_CHARS         = 8;
var
  buffer: Pointer;
  BufLen: LongWord;
//  str : AnsiString;
  l : Integer;
begin
  if Value = '' then
   begin
    Result := '';
    Exit;
   end;
  BufLen := Length(Value)*2 + 6;
  GetMem(buffer, BufLen);
  FillChar(buffer^, BufLen, 0);
//  MultiByteToWideChar(CP_UTF8, 0, @Value[1], BufLen - 4, buffer, BufLen);
 {$IFDEF UNICODE}
  l := MultiByteToWideChar(CP_UTF8, MB_ERR_INVALID_CHARS, PAnsiChar(Value), Length(Value), buffer, BufLen);
//  l := MultiByteToWideChar(CP_UTF8, 0, PAnsiChar(Value), Length(Value), buffer, BufLen);
 {$else nonUNICODE}
  l := MultiByteToWideChar(CP_UTF8, 0, PAnsiChar(Value), Length(Value), buffer, BufLen);
 {$ENDIF UNICODE}
//  Result := WideCharToString(buffer);
//  WideCharLenToStrVar(buffer,
//  str := LStrFromPWChar(buffer);
//  str := PWideChar(buffer);
  if l > 0 then
    Result := WideCharToString(buffer)
   else
    Result := '';
//  Result := str;
  FreeMem(buffer, BufLen);
end;

{Convert string from UTF-8 format mixed with standart ASCII symbols($00..$7f)}
(* Old function. And commented
function UTF8ToStrSmart(const Value: RawByteString): String;
var
  Digit: RawByteString;
  str : String;
  i: Word;
  HByte: Byte;
  Len: Byte;
begin
  Result := '';
  if Value = '' then Exit;
  Len := 0;
 {$IFNDEF UNICODE}
  str := UTF8Decode(Value);
 {$else UNICODE}
  str := UTF8ToStr(Value);
 {$ENDIF UNICODE}
  If (str='')or(str = value) Then
   Begin
    Result:=Value;
    Exit
   End;
  for i := 1 to Length(Value) do
  begin
    if Len > 0 then
    begin
      Digit := Digit + Value[i];
      Dec(Len);
      if Len = 0 then
       begin
        str := UTF8ToStr(Digit);
        if str > '' then
          Result := Result + str
        else
          Result := Result + Digit;
       end;
    end else
    begin
      HByte := byte(Value[i]);
      if HByte in [$00..$7f] then       //Standart ASCII chars
        Result := Result + Value[i]
      else begin
        //Get length of UTF-8 char
        if HByte and $FC = $FC then
          Len := 6
        else if HByte and $F8 = $F8 then
          Len := 5
        else if HByte and $F0 = $F0 then
          Len := 4
        else if HByte and $E0 = $E0 then
          Len := 3
        else if HByte and $C0 = $C0 then
          Len := 2
        else begin
          Result := Result + Value[i];
          Continue;
        end;
        Dec(Len);
        Digit := Value[i];
      end;
    end;
  end;
end;
*)
{
procedure SetLength2(var s:string; value:Integer);
begin
  SetLength(s,value); //UStrSetLength не экспортируется из System...
end;
function UTF8ToStrSmart2(const Value: AnsiString): String; assembler;
// By SuperHacker
var s2:string;   //Вообще-то, туда сохраняется ^string, но ассемблеру всё равно...
asm
  mov s2,edx
  test eax,eax
  je @exit        //Проверим, что строка не пустая
  push ebx
  push esi
  push edi
  push eax        //Потом нам может понадобиться эта строчка...
  mov esi,eax     //Строчку будем читать с помощью lodsb
  mov edx,[eax-4]
  mov ebx,edx     //Длину строки сохраним в ebx
  mov eax,s2
  call SetLength2 //Сделаем Unicode-строчку такой же длины (в символах), как исходная (в подавляющем большинстве случаев результат туда влезет)
  mov edx,ebx     //Восстановим длину в edx
  mov edi,s2      //Будем писать в новую строку
  mov edi,[edi]
  mov ecx,edx     //Счётчик цикла
@startloop:
  xor eax,eax     //Очистим, чтобы не мешалось
  lodsb           //Возьмём символ
  bt eax,7        //Проверим 7-й бит
  jc @above1
  stosw           //Если 0, то это символ 0..127, сохраним его вместе с нулём (eax мы очистили)
  jmp @next
@above1:          //Если не 0...
  mov ebx,eax     //Сделаем резервную копию
  shr eax,1
  cmp eax,1111110b//1111110х ?
  je @error       //Не включено в стандарт. Наверное, это ansi...
  shr eax,1
  cmp eax,111110b //111110хх ?
  je @error       //То же самое...
  shr eax,1
  cmp eax,11110b //11110ххх ?
  je @error       //Это есть в стандарте, но это, имхо, перебор... К тому же я не уверен, поддерживается ли это в Delphi.
  shr eax,1
  cmp eax,1110b   //1110хххх ?
  jne @lower3
  cmp ecx,3       //Символ занимает 3 байта. Там ещё строка не кончается?
  jnl @ok3
                  //Кончается...
  cmp edx,ecx     //Мы в самом начале?
  je @error       //Тогда это скорее ansi, чем UTF-8
  mov ecx,1
  jmp @next       //Если не в начале, то, значит, строка обрезана, не считаем это серьёзной ошибкой
@ok3:
  and ebx,1111b    //Возьмём 4 младших бита...
  push ecx        //Организуем вложенный цикл
  mov ecx,2
@smallloop3:
  lodsb           //Возьмём символ...
  bt eax,7        //Проверим на соответствие стандарту
  jnc @error
  bt eax,6
  jc @error
  shl eax,24+2
  shld ebx,eax,6  //Добавляем 6 младших битов в ebx
  xor eax,eax     //Очистим мусор :)
  loop @smallloop3
  pop ecx
  sub ecx,2       //Восстановим ecx
  mov eax,ebx
  stosw           //Сохраним символ
@lower3:
  shr eax,1
  cmp eax,110b    //110ххххх ?
  jne @error      //Не соответствует стандарту
  cmp ecx,2       //Символ занимает 2 байта. Там ещё строка не кончается?
  jnl @ok2
                  //Кончается...
  cmp edx,ecx     //Мы в самом начале?
  je @error       //Тогда это скорее ansi, чем UTF-8
  mov ecx,1
  jmp @next       //Если не в начале, то, значит, строка обрезана, не считаем это серьёзной ошибкой
@ok2:
  and ebx,11111b    //Возьмём 5 младших битов...
  lodsb           //Возьмём ещё символ...
  bt eax,7        //Проверим на соответствие стандарту
  jnc @error
  bt eax,6
  jc @error
  shl eax,24+2
  shld ebx,eax,6  //Добавляем 6 младших битов в ebx
  xor eax,eax     //Очистим мусор :)
  dec ecx         //Восстановим ecx
  mov eax,ebx
  stosw           //Сохраним символ
@next:
  //loop @startloop
  dec ecx
  jne @startloop  //Цикл получился слишком длинным для loop, придётся вручную...
  mov eax,s2
  mov eax,[eax]
  sub edi,eax     //Считаем, сколько символов получилось
  shr edi,1       //Переводим из байт в символы
  cmp edi,[eax-4] //Надо менять длину?
  je @NoSetLength
  mov eax,s2
  mov edx,edi
  call SetLength2 //Меняем...
@NoSetLength:
  pop eax         //Это адрес нашей входной строки. Он не понадобился, но стек восстановить надо...
  jmp @exit2
@error:           //Сюда мы попадаем, если в процессе декодирования UTF-8 произошла ошибка.
                  //Скорее всего, это значит, что строка в ansi, но нам нужно вернуть результат в юникоде...
  pop eax         //Это адрес нашей входной строки
  push edx        //Надеюсь, в edx осталась длина строки...
  mov ebx,s2
  push [ebx]
  push edx
  push eax
  xor ecx,ecx
  push ecx
  push ecx //CP_ACP=0
  call MultiByteToWideChar  //Преобразуем в юникод
  //Здесь надо было бы проверить, что ф-ция выполнилась успешно... Но вряд ли это случится :)
@exit2:
  pop edi
  pop esi
  pop ebx
@exit:
end;}

function UTF8ToStrSmart3(const Value: RawByteString): String;
var
  Len: cardinal;

  procedure error;
  begin
    MultiByteToWideChar(RnQDefaultSystemCodePage, 0, @Value[1], Len, @Result[1], Len);
  end;

var
  i,
  j,
  k: cardinal;
  pc: PChar;
  c: byte;
  tmp: word;
//  tmp4: DWORD;
  tmp4: ShortString;
begin
  if Value='' then
  begin
    Result:= '';
    exit;
  end;
  Len := Length(Value);
  SetLength(Result, Len);
  pc := @Result[1];
  i := 1;
  j := 1;
  repeat
    c := byte(Value[i]);
    inc(i);
    if (c and $80)=0 then begin   //Символ с кодом 0..127
//      Result[j]:=chr(c);
//      Result[j]:= Char(c);
      pc^ := Char(c);
      inc(j);
      inc(pc);
      continue;
    end;
//    if ((c shr 1)=$7E) or ((c shr 2)=$3E) or ((c shr 3)=$1E) then begin
    //  1111110x            111110xx            11110xxx

    if ((c shr 1)=$7E) or ((c shr 2)=$3E) then begin // Upd 2016
    //  1111110x            111110xx

      error;
      exit;
    end;
//>>> Added 2016 for Emoji
    if (c shr 3)=$1E {11110xxx} then begin    //Символ занимает 4 байта
      if Integer(Len-i)<1 then               //Строка кончилась?
        if i=2 then begin
          error;
          exit;
        end
        else break;
//      tmp4:= c and $7;                         // 3 младших бита
      SetLength(tmp4, 4);
      tmp4[1]:= Value[i-1];
      for k := 1 to 3 do begin
        c := byte(Value[i]);
        inc(i);
        if (c shr 6)<>2 then begin           //10xxxxxx
          error;
          exit;
        end;
//        tmp4 := (tmp4 shl 6) or (c and $3F);     //Добавляем 6 бит в конец
        tmp4[k+1] := Value[i-1];
      end;
      k := Cardinal(UnicodeFromLocaleChars(CP_UTF8, 0, @tmp4[1], 4, pc, len - j));
      if k > 0 then
         begin
          inc(j, k);
          inc(pc, k);
         end
       else
        begin
          error;
          exit;
        end;

      continue;
    end;
//<<< Added 2016 for Emoji
    if (c shr 4)=$E {1110xxxx} then begin    //Символ занимает 3 байта
      if Integer(Len-i)<1 then               //Строка кончилась?
        if i=2 then begin
          error;
          exit;
        end
        else break;
      tmp:=c and $F;                         // 4 младших бита
      for k := 1 to 2 do begin
        c := byte(Value[i]);
        inc(i);
        if (c shr 6)<>2 then begin           //10xxxxxx
          error;
          exit;
        end;
        tmp := (tmp shl 6) or (c and $3F);     //Добавляем 6 бит в конец
      end;
//      Result[j]:=chr(tmp);
      inc(j);
      pc^ := chr(tmp);
      inc(pc);
      continue;
    end;
    if (c shr 5)=6 {110xxxxx} then begin     //Символ занимает 2 байта
      if i>Len then
        if i=2 then begin
          error;
          exit;
        end
        else break;
      tmp := word(c and $1F) shl 6; // 5 младших битов
      c := byte(Value[i]);
      inc(i);
      if (c shr 6)<>2 then begin      //10xxxxxx
        error;
        exit;
      end;
      tmp := tmp or (c and $3F);
//      Result[j]:=chr(tmp);
      inc(j);
      pc^ := chr(tmp);
      inc(pc);
    end
    else begin
      error;
      exit;
    end;
  until i>Len;
  dec(j);
  if j<Len then SetLength(Result,j);
end;

function UnUTF(const s: RawByteString): String;
{$IFNDEF UNICODE}
var
//  ss: RawString;
  ss: RawByteString;
{$ENDIF UNICODE}
begin
//  result := s;
  if (Length(s) > 1)
     and ((s[1] < #5)or(s[2] < #5) or((s[1] = #255)and (s[2] = #254)))
     and not odd(Length(s)) then
   begin
   {$IFDEF UNICODE}
     Result := PWideChar(@s[1]);
     if (s[1] < #5) then
      begin
//        StrSwapByteOrder(PWideChar(result));
//        SwapShort(@Result[1], ByteLength(Result));
        SwapWordByteOrder(PAnsiChar(@Result[1]), ByteLength(Result));
      end;
   {$ELSE nonUNICODE}
     ss := s;
     if (ss[1] < #5) then
//      StrSwapByteOrder(PWideChar(ss));
//       SwapShort(@ss[1], Length(ss));
       SwapWordByteOrder(PAnsiChar(ss), Length(ss));
     result := WideCharToString(PWidechar(ss));
   {$ENDIF UNICODE}
   end
   else
//    result := UTF8ToStrSmart(s);
    result := UTF8ToStrSmart3(s);
end;

function UTF(const s: String): RawByteString;
begin
  Result := UTF8Encode(s)
end;

function WideBEToUTF8(const Value: RawByteString): RawByteString;
var
//  buffer: Pointer;
  ResLen, BufLen: LongWord;
  str: RawByteString;
//  lpBuf: Pointer;
begin
  if Value='' then
   begin
    Result := '';
    exit;
   end;
  str := Copy(Value, 1, Length(Value));
//  StrSwapByteOrder(PWideChar(str));
//  SwapShort(@str[1], Length(str));
  SwapWordByteOrder(PAnsiChar(str), Length(str));

  BufLen := Length(Value) * 4;

  SetLength(Result, BufLen);
  ResLen := WideCharToMultiByte(CP_UTF8, 0, @Str[1], Length(str) shr 1, PAnsiChar(Result), BufLen, nil, nil);

  SetLength(Result, ResLen);
end;

{Convert string to UTF8 format}
function StrToUTF8(const Value: AnsiString): RawByteString;
var
  buffer: Pointer;
  ResLen, BufLen: LongWord;
//  lpBuf: Pointer;
begin
  if Value='' then
   begin
    Result := '';
    exit;
   end;
  BufLen := Length(Value) * 4;
  GetMem(buffer, BufLen); FillChar(buffer^, BufLen, 0);
//  GetMem(lpBuf, BufLen); FillChar(lpBuf^, BufLen, 0);
  SetLength(Result, BufLen);
  StringToWideChar(Value, buffer, BufLen);
  ResLen := WideCharToMultiByte(CP_UTF8, 0, buffer, -1, PAnsiChar(Result), BufLen, nil, nil);
  FreeMem(buffer, BufLen);

  SetLength(Result, ResLen-1);
//  CopyMemory(@Result[1], lpBuf, ResLen);
//  Result := PAnsiChar(lpBuf);
//  FreeMem(lpBuf, BufLen);
end;

{Convert string to Unicode format}
function StrToUnicode(const Value: AnsiString): RawByteString;
var
  buffer: Pointer;
  BufLen: LongWord;
//  lpBuf: Pointer;
begin
  if Value='' then
   begin
    Result := '';
    exit;
   end;
  BufLen := Length(Value) * 2 + 2;
  SetLength(Result, BufLen);
//  GetMem(buffer, BufLen);
  buffer := @result[1];
  FillChar(buffer^, BufLen, 0);
//  GetMem(lpBuf, BufLen); FillChar(lpBuf^, BufLen, 0);
  StringToWideChar(Value, buffer, BufLen);
//  WideCharToMultiByte(CP_UTF8, 0, buffer, -1, lpBuf, BufLen, nil, nil);
//  SetLength(Result, BufLen);
//  Result := Copy(PChar(buffer), 0, BufLen);
//  StrSwapByteOrder(PWideChar(result));
//  SwapShort(@result[1], Length(result));
  SwapWordByteOrder(PAnsiChar(result), Length(result));
  SetLength(Result, BufLen-2);
//  FreeMem(buffer, BufLen);
//  Result := PChar(lpBuf);
//  FreeMem(lpBuf, BufLen);
end;

function StrToUnicodeLE(const Value: AnsiString): AnsiString;
var
  buffer: Pointer;
  BufLen: LongWord;
//  lpBuf: Pointer;
begin
  if Value='' then
   begin
    Result := '';
    exit;
   end;
  BufLen := Length(Value) * 2 + 22;
  SetLength(Result, BufLen);
//  GetMem(buffer, BufLen);
  buffer := @result[1];
  FillChar(buffer^, BufLen, 0);
//  GetMem(lpBuf, BufLen); FillChar(lpBuf^, BufLen, 0);
// {$IFDEF UNICODE}
  BufLen := MultiByteToWideChar(RnQDefaultSystemCodePage, 0, @Value[1], Length(Value), buffer, BufLen);
  SetLength(Result, BufLen);
// {$ELSE}
//  BufLen := MultiByteToWideChar(DefaultSystemCodePage, 0, @Value[1], Length(Value), buffer, BufLen);
//  BufLen := StringToWideChar(Value, PWideChar(buffer), BufLen);
//  SetLength(Result, BufLen-2);
// {$ENDIF UNICODE}
end;

 {$IFDEF UNICODE}
function WideBEToStr(const Value: RawByteString): UnicodeString;
var
  str: RawByteString;
begin
  if Value='' then
   begin
    Result := '';
    exit;
   end;
  str := Value;
//  StrSwapByteOrder(PWideChar(str));
//  SwapShort(@str[1], ByteLength(str));
  SwapWordByteOrder(PAnsiChar(str), Length(str));
  Result := WideCharToString(PWideChar(@str[1]));
end;

 {Convert string to UTF8 format}
function StrToUTF8(const Value: UnicodeString): RawByteString;
var
//  buffer: Pointer;
  ResLen, BufLen: LongWord;
//  lpBuf: Pointer;
begin
  if Value='' then
    exit('');
  BufLen := Length(Value) * 4;
//  GetMem(buffer, BufLen); FillChar(buffer^, BufLen, 0);
//  GetMem(lpBuf, BufLen); FillChar(lpBuf^, BufLen, 0);
//  StringToWideChar(Value, buffer, BufLen);
//  Buffer := @Value[1];
  SetLength(Result, BufLen);
  ResLen := WideCharToMultiByte(CP_UTF8, 0, @Value[1], Length(Value), PAnsiChar(Result), BufLen, nil, nil);
 // ResLen includes the byte for the terminating null character.

 //  FreeMem(buffer, BufLen);
//  Result := PAnsiChar(lpBuf);
//  FreeMem(lpBuf, BufLen);
  SetLength(Result, ResLen); //
end;

{Convert string to Unicode format}
function StrToUnicode(const Value: UnicodeString): RawByteString;
var
//  buffer: Pointer;
  BufLen: LongWord;
//  lpBuf: Pointer;
  str: WideString;
begin
  if Value='' then
    exit('');
  str := Value;
//  WideCharToMultiByte(CP_UTF8, 0, buffer, -1, lpBuf, BufLen, nil, nil);
//  StrSwapByteOrder(PWideChar(str));
//  SwapShort(@str[1], ByteLength(str));
  BufLen := byteLength(Value);
  SwapWordByteOrder(PAnsiChar(@str[1]), BufLen);
  SetLength(Result, BufLen);
  Move(Pointer(str)^, Pointer(Result)^, BufLen);
//  Result := Copy(PAnsiChar(Pointer(str)), 0, BufLen);
//  SetLength(Result, BufLen-2);
//  Result := str;
//  FreeMem(buffer, BufLen);
//  Result := PChar(lpBuf);
//  FreeMem(lpBuf, BufLen);
end;

function StrToUnicodeLE(const Value: UnicodeString): RawByteString;
var
  buffer: Pointer;
  BufLen: LongWord;
//  lpBuf: Pointer;
begin
  if Value='' then
    exit('');
  BufLen := Length(Value) * 2 + 2;
  SetLength(Result, BufLen);
  buffer := @result[1];
  FillChar(buffer^, BufLen, 0);
  StringToWideChar(Value, buffer, BufLen);
  SetLength(Result, BufLen-2);
end;
 {$ENDIF UNICODE}

//{$IF CompilerVersion >= 24}
//{$IFEND}
 {$IFDEF UNICODE} {$IF CompilerVersion >= 24}
function RnQEndsText(const ASubText, AText: UnicodeString): Boolean;
var
  SubTextLocation: Integer;
begin
  SubTextLocation := AText.Length - ASubText.Length + 1;
  if (SubTextLocation > 0) and (ASubText <> '') and
     (ByteType(AText, SubTextLocation) <> mbTrailByte) then
    Result := AnsiStrIComp(PChar(ASubText), PChar(@AText[SubTextLocation])) = 0
  else
    Result := False;
end;
 {$ELSE}
function RnQEndsText(const ASubText, AText: UnicodeString): Boolean;
begin
  Result := AnsiEndsText(ASubText, AText);
end;
 {$IFEND ver} {$ENDIF UNICODE}

 function IsEqualGUID;                   external ole32 name 'IsEqualGUID';
{$EXTERNALSYM IsEqualGUID}

function SGUID2rGUID(const guid: RawByteString; Zero2Empty: Boolean = True): RawByteString;
var
  g: TGUID;
begin
  if Length(GUID) = 16 then
    Exit(guid);
  Result := '';
  if Length(GUID) > 16 then
   begin
     if Length(GUID) = 38 then
       g := StringToGUID(guid)
      else
       if Length(GUID) = 36 then;
         g := StringToGUID('{'+guid+'}');
     if not (Zero2Empty and IsEqualGUID(g, GUID_NULL)) then
      begin
       SetLength(Result, 16);
       CopyMemory(@Result[1], @g, 16);
      end;
   end;
end;

function GUID2rGUID(const guid: TGUID): RawByteString;
begin
  Result := '';
  if guid <> GUID_NULL then
    begin
       SetLength(Result, 16);
       CopyMemory(@Result[1], @guid, 16);
    end;
end;

function findInStrings(const s: string; ss: Tstrings): Integer;
begin
  result := 0;
  while result < ss.count do
    if ss[result] = s then
      exit
    else
      inc(result);
  result := -1;
end; // findInStrings

 {$IFDEF UNICODE}
function findInStrings(const s: AnsiString; ss: Tstrings): Integer;
var
  sU: UnicodeString;
begin
  sU := UnicodeString(s);
  result := 0;
  while result < ss.count do
    if ss[result] = sU then
      exit
     else
      inc(result);
  result:=-1;
end; // findInStrings
 {$ENDIF UNICODE}

function findInStrings(const s: AnsiString; ss: array of AnsiString): Integer;
begin
  result := 0;
  while result < length(ss) do
    if ss[result] = s then
      exit
    else
      inc(result);
  result := -1;
end; // findInStrings

function findInStrings(const s: AnsiString; ss, separator: RawByteString): Integer;
begin
result:=0;
while ss>'' do
  if chop(separator,ss) = s then
    exit
  else
    inc(result);
result:=-1;
end; // findInStrings


function hexToInt(const s: RawByteString): Cardinal;
var
  i, v, c: Cardinal;
begin
  result := 0;
  c := 0;
  i := length(s);
  while i > 0 do
    begin
      if s[i] >= 'a' then
        v := byte(s[i])-byte('a')+10
       else
        if s[i] >= 'A' then
          v := byte(s[i])-byte('A')+10
         else
          v := byte(s[i])-byte('0');
      inc(result, v shl c);
      inc(c, 4);
      dec(i);
    end;
end; // hexToInt

function hexToInt(const s: String): Cardinal;
var
  i, v, c: Cardinal;
begin
  result := 0;
  c := 0;
  i := length(s);
  while i > 0 do
    begin
      if s[i] >= 'a' then
        v := byte(s[i])-byte('a')+10
       else
        if s[i] >= 'A' then
          v := byte(s[i])-byte('A')+10
         else
          v := byte(s[i])-byte('0');
      inc(result, v shl c);
      inc(c, 4);
      dec(i);
    end;
end; // hexToInt

function str2valor(const s: AnsiString): Int64;
var
  cd: Integer;
begin
  if s = '' then
    result := -1
   else
    if s[length(s)]='h' then
      result := hexToInt(copy(s,1,length(s)-1))
    else
      try
        Val(String(s), Result, cd);
        if cd <> 0 then
          result := 0
      except
        result := 0
      end
end; // str2valor

function hex2Str(const s: RawByteString): RawByteString;
var
  i: Integer;
begin
  result := '';
  //c := 0;
  //i := length(s);
  i := 1;
  while i < length(s) do
    begin
      result := result + AnsiChar(hexToInt(copy(s,i,2)));
  {  if s[i] >= 'a' then v:=byte(s[i])-byte('a')+10 else
      if s[i] >= 'A' then v:=byte(s[i])-byte('A')+10 else
        v:=byte(s[i])-byte('0');
    result := result + IntToStr(v);
  //  inc(result, v shl c);
  //  inc(c,4);
    dec(i); }
     inc(i, 2);
    end;
end; // hexToInt

function hex2StrSafe(const s: RawByteString): RawByteString;
var
  i: Integer;
  ch: AnsiChar;
begin
  result := '';
  //c := 0;
  //i := length(s);
  i := 1;
  while i < length(s) do
    begin
      if (s[i] in hexChars)and
         (s[i+1] in hexChars) then
        ch := AnsiChar(hexToInt(copy(s,i,2)))
       else
        ch := ' ';
      result := result + Ch;
  {  if s[i] >= 'a' then
       v:=byte(s[i])-byte('a')+10
      else
       if s[i] >= 'A' then
         v:=byte(s[i])-byte('A')+10
        else
         v:=byte(s[i])-byte('0');
     result := result + IntToStr(v);
   //  inc(result, v shl c);
   //  inc(c,4);
     dec(i); }
     inc(i, 2);
    end;
end; // hexToInt

function hex2StrU(const s: String): RawByteString;
var
  i: Integer;
  ch: AnsiChar;
begin
  result := '';
  //c := 0;
  //i := length(s);
  i := 1;
  while i < (length(s)-1) do
    begin
//      if (s[i] in hexChars)and
//         (s[i+1] in hexChars) then

      if CharInSet(s[i], hexChars) and
         CharInSet(s[i+1], hexChars) then
        ch := AnsiChar(hexToInt(copy(s,i,2)))
       else
        ch := ' ';
      result := result + Ch;
  {  if s[i] >= 'a' then v:=byte(s[i])-byte('a')+10 else
      if s[i] >= 'A' then v:=byte(s[i])-byte('A')+10 else
        v := byte(s[i])-byte('0');
    result := result + IntToStr(v);
  //  inc(result, v shl c);
  //  inc(c,4);
    dec(i); }
     inc(i, 2);
    end;
end; // hexToInt

function PacketToHex(Buffer: Pointer; BufLen: Word): AnsiString;
var
//  S: AnsiString;
  i: Cardinal;
begin
  Result := '';
  for i := 1 to BufLen do
   begin
      Result := Result + IntToHexA(PByte(LongWord(Buffer) + i - 1)^, 2);
   end;
end;


function str2hex(const s: RawByteString): AnsiString;
var
//  ofs,
  i: Integer;
//  s2: string;
begin
  result := '';
//  ofs := 0;
  for i:=1 to length(s) do
    begin
      result := result+
              intToHexA(byte(s[i]),2);
//      result := result+' ';
    end;
end; // Str2hex

function str2hexU(const s: RawByteString): String;
var
//  ofs,
  i: Integer;
//  s2: string;
begin
  result := '';
//  ofs:=0;
  for i:=1 to length(s) do
    begin
      result := result+
              intToHex(byte(s[i]),2);
//      result:=result+' ';
    end;
end; // Str2hex

function str2hex(const s: RawByteString; const Delim: AnsiChar): AnsiString;
var
//  ofs,
  i: Integer;
//  s2: string;
begin
  result := '';
//  ofs:=0;
  for i:=1 to length(s) do
    begin
      if i > 1 then
        result := result+delim;
      result := result+
              intToHexA(byte(s[i]),2);
//      result := result+' ';
    end;
end; // Str2hex

function strings2str(const split: string; ss: Tstrings): string;
var
  i: Integer;
begin
  result := '';
  if ss = nil then
   exit;
  i:=0;
  while i < ss.count-1 do
    begin
    result := result+ss[i]+split;
    inc(i);
    end;
  // the last one without split
  if ss.count > 0 then
    result := result+ss[ss.count-1]
end; // strings2str

function strings2str(const split: string; const ss: array of string): string;
var
  i: Integer;
begin
  result := '';
  if length(ss)=0 then
    exit;
  for i:=0 to length(ss)-2 do
    result := result+ss[i]+split;
  result := result+ss[length(ss)-1];
end;

procedure str2strings(const split: String; src: string; var ss: Tstrings);
var
  i: Integer;
begin
  ss.clear;
  while src > '' do
    begin
      i := pos(split, src);
      if i=0 then
        i := length(src)+1;
      ss.add( copy(src,1,i-1) );
      delete(src, 1, i+length(split)-1);
    end;
end; // strings2str

function hexDump(const data: RawByteString): AnsiString;
const
  cols=16;
var
  ofs, i: Integer;
  s, s2: AnsiString;
begin
 result := '';
 ofs := 0;
 while ofs < length(data) do
  begin
    s := '';
    s2 := '';
    for i:=1 to cols do
      if ofs+i <= length(data) then
        begin
        s := s+intToHexA(byte(data[ofs+i]),2);
        if i=8 then
          s := s+'  '
         else
          s := s+' ';
        if data[ofs+i] < #32 then
          s2 := s2+'.'
         else
          s2 := s2+data[ofs+i];
        end;
    s := s+stringOfChar(AnsiChar(' '),cols*3+4-length(s));
    result := result+s+s2+CRLF;
    inc(ofs, cols);
  end;
end; // hexDump

function hexDumpS(const data: RawByteString): String;
const
  cols = 16;
var
  ofs, i: Integer;
  s, s2: String;
begin
 result := '';
 ofs := 0;
 while ofs < length(data) do
  begin
    s := '';
    s2 := '';
    for i:=1 to cols do
      if ofs+i <= length(data) then
        begin
          s := s+IntToHex(byte(data[ofs+i]),2);
          if i=8 then
            s := s+'  '
           else
            s := s+' ';
        if data[ofs+i] < #32 then
          s2 := s2+'.'
         else
          s2 := s2+ String( data[ofs+i] );
        end;
    s := s+stringOfChar(' ',cols*3+4-length(s));
    result := result+s+s2+CRLF;
    inc(ofs, cols);
  end;
end; // hexDump

function isOnlyDigits(const s: AnsiString): boolean;
var
  i: Integer;
begin
  result := FALSE;
  i := 1;
  while i <= length(s) do
    if s[i] in ['0'..'9'] then
      inc(i)
     else
      exit;
  if i > 1 then
    result := TRUE;
end; // isOnlyDigits

{$IFDEF UNICODE}
function  isOnlyDigits(const s: UnicodeString): boolean;
var
  i: Integer;
begin
  result := FALSE;
  i := 1;
  while i <= length(s) do
//    if s[i] in ['0'..'9'] then
    if s[i].IsDigit then
      inc(i)
    else
      exit;
  if i > 1 then
    result := TRUE;
end; // isOnlyDigits
{$ENDIF UNICODE}

function size2str(sz: Int64): String;
begin
  if sz > GByte then // GB
    result := FloatToStr(round(100*(sz / GByte)) /100) + ' GByte'
   else
    if sz > MByte then // MB
      result := FloatToStr(round(100*(sz / MByte)) /100) + ' MByte'
     else
      if sz > 1024 then // KB
        result := FloatToStr(round(100*(sz / 1024)) /100) + ' KByte'
       else
        result := intToStr(sz) + ' Byte'
end;

function chop(const ss: RawByteString; var s: RawByteString): RawByteString;
begin
  result := chop(pos(ss,s), length(ss), s)
end;

function chop(i: Integer; var s: RawByteString): RawByteString; {$IFDEF HAS_INLINE} inline; {$ENDIF HAS_INLINE}
begin
  result := chop(i, 1, s)
end;

function chop(i, l: Integer; var s: RawByteString): RawByteString;
begin
  if i=0 then
    begin
      result := s;
      s := '';
      exit;
    end;
  result := copy(s,1,i-1);
  delete(s, 1, i-1+l);
end; // chop


function chopline(var s: RawByteString): RawByteString;
var
  i: Integer;
begin
  for i:=1 to length(s) do
    case s[i] of
      #10:
        begin
          result := chop(i,s);
          exit;
        end;
      #13:
        begin
          if (i < length(s)) and (s[i+1]=#10) then
            result := chop(i, 2, s)
           else
            result:= chop(i,s);
          exit;
        end;
      end;
  result := chop(0,0,s);
end; // chopline

function choplineV(const s: RawByteString; var pos0: Integer): RawByteString;
var
  i, l: Integer;
begin
  l := Length(s);
  if pos0 < l then
    for i := pos0 to l do
      case s[i] of
        #10:
          begin
            result := Copy(s, pos0, i-pos0);
            pos0 := i+1;
            exit;
          end;
        #13:
          begin
            if (i < length(s)) and (s[i+1]=#10) then
              begin
                result := Copy(s, pos0, i-pos0);
                pos0 := i+2;
              end
             else
              begin
                result := Copy(s, pos0, i-pos0);
                pos0 := i+1;
              end;
            exit;
          end;
      end;
  result := Copy(s, pos0);
  pos0 := Length(s)+1;
end; // chopline

 {$IFDEF UNICODE}
function chop(i, l: Integer; var s: String): String;
begin
  if i=0 then
    begin
      result := s;
      s := '';
      exit;
    end;
  result := copy(s, 1, i-1);
  delete(s, 1, i-1+l);
end; // chop

function chop(i: Integer; var s: String): String; {$IFDEF HAS_INLINE} inline; {$ENDIF HAS_INLINE}
begin
  result := chop(i,1,s)
end;

function chop(const ss: String; var s: String): String;
begin
  result := chop(pos(ss,s), length(ss), s)
end;

function chopline(var s: String): String;
var
  i: Integer;
begin
  for i:=1 to length(s) do
    case s[i] of
      #10:
        begin
          result := chop(i,s);
          exit;
        end;
      #13:
        begin
          if (i < length(s)) and (s[i+1]=#10) then
            result := chop(i,2,s)
           else
            result := chop(i,s);
          exit;
        end;
      end;
  result := chop(0,0,s);
end; // chopline

 {$ENDIF UNICODE}

{
function  UnDelimiter(s: String): String;
var
  i: Integer;
begin
  result := '';
  for I := 1 to length(s) do
    if (s[i] in ['a'..'z','A'..'Z','1'..'9','0', '@', '.', '_']) then
      result := result + s[i];
end;}

function BetterStr(const s: AnsiString): AnsiString;
var
  i: Integer;
begin
  SetLength(Result, Length(s));
  for i := 1 to length(s) do
   if s[i] < #32 then
    Result[i] := AnsiChar('.')
   else
    Result[i] := s[i];
end;

function BetterStrS(const s: String): String;
var
  i: Integer;
begin
  SetLength(Result, Length(s));
  for i := 1 to length(s) do
   if s[i] < #32 then
    Result[i]:= '.'
   else
    Result[i]:= s[i];
end;

 function Rgb2Gray(RGBColor: TColor): byte;
// var
//   Gray: byte;
 begin
   Result := Round((0.30 * GetRValue(RGBColor)) +
                 (0.59 * GetGValue(RGBColor)) +
                 (0.11 * GetBValue(RGBColor )));
//   Result := RGB(Gray, Gray, Gray);
 end;

function DoubleAsInt64(Value: double): int64;
var
  i: int64 absolute Value;
begin
  result := i;
end;

function Int64AsDouble(Value: int64): double;
var
  d: double absolute Value;
begin
  result := d;
end;

function TBytesToString(B: TBytes; CodePage: Integer = CP_UTF8): string;
var
  E: TEncoding;
begin
  E := TEncoding.GetEncoding(CodePage);
  try
    Result := E.GetString(B);
  finally
    E.Free;
  end;
end;

function StringToTBytes(S: string; CodePage: Integer = CP_UTF8): TBytes;
var
  E: TEncoding;
begin
  E := TEncoding.GetEncoding(CodePage);
  try
    Result := E.GetBytes(S);
  finally
    E.Free;
  end;
end;

function TryStrToLongWord(const S: string; var Value: LongWord): Boolean;
var
  Int64Value: Int64;
begin
  Result := TryStrToInt64(S, Int64Value) and (Int64Value >= 0) and (Int64Value <= High(Value));
  if Result then
    Value := LongWord(Int64Value);
end;

{ $IFNDEF UNICODE }
initialization
  RnQDefaultSystemCodePage := GetACP;
{ $ENDIF UNICODE }



end.
