unit RnQCrypt;
{$I forRnQConfig.inc}
{$I NoRTTI.inc}

interface


// crypting
function  passCrypt(const s: RawByteString): RawByteString;
function  passDeCrypt(const s: RawByteString): RawByteString;
function  decritted(const s: RawByteString; key: integer): RawByteString;
function  critted(const s: RawByteString; key: integer): RawByteString;
procedure critt(var s: RawByteString; key: integer);
procedure decritt(var s: RawByteString; key: integer);
function  calculate_KEY1(const pwd: AnsiString): integer;
function  MD5Pass(const s: RawByteString): RawByteString;

implementation
uses
   {$IFDEF USE_SYMCRYPTO}
     SynCrypto,
    {$ELSE not SynCrypto}
     OverbyteIcsMD5,
   {$ENDIF ~USE_SYMCRYPTO}
 {$IFDEF UNICODE}
   AnsiStrings,
//   Character,
 {$ENDIF UNICODE}
    RDUtils;

function passCrypt(const s: RawByteString): RawByteString;
var
  i: integer;
begin
  result := '';
  randSeed := 55555;
  i := length(s);
  while i > 0 do
    begin
     inc(randSeed, ord(s[i]));
     dec(i);
    end;

  i := length(s);
  while i > 0 do
   begin
    result := result + AnsiChar(40+ byte(s[i]) and 15) + AnsiChar(40+byte(s[i]) shr 4)+ AnsiChar(35+random(35));
    while random(3) <> 0 do
      result := result+AnsiChar(70+random(250-70));
    dec(i);
   end;
end; // passCrypt

function passDecrypt(const s: RawByteString): RawByteString;
var
  i: integer;
begin
  result := '';
  i := length(s);
  while i > 0 do
    begin
    if s[i] < #70 then
      begin
      result := result+AnsiChar((byte(s[i-1])-40) shl 4+ byte(s[i-2])-40);
      dec(i, 2);
      end;
    dec(i);
    end;
end; // passDecrypt

function decritted(const s: RawByteString; key: integer): RawByteString;
begin
result:=dupString(s);
decritt(result, key);
end;

function critted(const s: RawByteString; key: integer): RawByteString;
begin
  result := dupString(s);
  critt(result, key);
end;

{$IFDEF CPUX64}
procedure critt(var s: RawByteString; key: integer);
var
  i: Cardinal;
  c, d: Byte;
  a, b: Byte;
  p: PAnsiChar;
begin
  if Length(s)=0 then
    Exit;
  c := Byte(key);
  d := Byte(key shr 20);
  p := @s[1];

  a := $B8;// 10111000b;
  for i := 1 to Length(s) do
    begin
      b := Byte(s[i]) + c;
      b := b xor d;
      b := (b shr 3) or (b shl 5);
      b := b xor a;

      p^ := AnsiChar( b );
      inc(PAnsiChar(p));
//      s[i] := AnsiChar(b);
      a := (a shr 3) or (a shl 5);
    end;
end;

procedure decritt(var s: RawByteString; key: integer);
var
  i: Cardinal;
  c, d: Byte;
  a, b: Byte;
  p: PAnsiChar;
begin
  if Length(s)=0 then
    Exit;
  c := Byte(key);
  d := Byte(key shr 20);
  p := @s[1];

  a := $B8;// 10111000b;
  for i := 1 to Length(s) do
    begin
      b := Byte(s[i]) xor a;
      b := (b shl 3) or (b shr 5);
      b := b xor d;
      b := b - c;

      p^ := AnsiChar( b );
      inc(PAnsiChar(p));
//      s[i] := AnsiChar(b);
      a := (a shr 3) or (a shl 5);
    end;
end;
{$ELSE ~CPUX64}
    {$WARN UNSAFE_CODE OFF}
procedure critt(var s: RawByteString; key: integer);
  asm
  mov ecx, key
  mov dl, cl
  shr ecx, 20
  mov dh, cl

  mov esi, s
  mov esi, [esi]
  or  esi, esi    // nil string
  jz  @OUT

  mov ecx, [esi-4]   // length
  or  ecx, ecx
  jz  @OUT
  mov ah, 10111000b
@IN:
  mov al, [esi]
  add al, dl
  xor al, dh
  ror al, 3
  xor al, ah

  mov [esi], al
  inc esi
  ror ah, 3
  dec ecx
  jnz @IN
@OUT:
  end; // critt

procedure decritt(var s: RawByteString; key: integer);
  asm
    PUSH ESI // Recommended by Пушкожук
  mov ecx, key
  mov dl, cl
  shr ecx, 20
  mov dh, cl

  mov esi, s
  mov esi, [esi]
  or  esi, esi    // nil string
  jz  @OUT
  mov ah, 10111000b

  mov ecx, [esi-4]
  or  ecx, ecx
  jz  @OUT
@IN:
  mov al, [esi]
  xor al, ah
  rol al, 3
  xor al, dh
  sub al, dl

  mov [esi], al
  inc esi
  ror ah, 3
  dec ecx
  jnz @IN
@OUT:
    POP ESI // Recommended by Пушкожук
end; // decritt
    {$WARN UNSAFE_CODE ON}
{$ENDIF CPUX64}

function calculate_KEY1(const pwd: AnsiString): integer;
var
  i, L: integer;
  p: ^integer;
begin
  L := length(pwd);
  result := L shl 16;
 {$WARN UNSAFE_CODE OFF}
  p := NIL;  // shut up compiler warning
  if pwd>'' then
    p := @pwd[1];
  i := 0;
  while i+4 < L do
   begin
    inc(result, p^);
    inc(p);
    inc(i, 4);
   end;
  while i < L do
   begin
    inc(result, ord(pwd[i]));
    inc(i);
   end;
 {$WARN UNSAFE_CODE ON}
end; // calculate_KEY1

function MD5Pass(const s: RawBytestring): RawByteString;
var
  MD5Digest: TMD5Digest;
 {$IFDEF USE_SYMCRYPTO}
   MD5: TMD5;
  {$ELSE not SynCrypto}
   MD5Context: TMD5Context;
 {$ENDIF ~USE_SYMCRYPTO}
begin
 {$IFDEF USE_SYMCRYPTO}
   md5.Init;
   if Length(s)>0 then
     md5.Update(s[1], length(s));
   md5.Final(MD5Digest);
  {$ELSE not SynCrypto}
  MD5Init(MD5Context);
  MD5UpdateBuffer(MD5Context, PAnsiChar(s), length(s));
  MD5Final(MD5Digest, MD5Context);
 {$ENDIF ~USE_SYMCRYPTO}
  SetLength(Result, length(MD5Digest));
//  StrPLCopy(@result[1], PByte(@MD5Digest), length(MD5Digest))
//  StrPLCopy(@result[1], PAnsiChar(@MD5Digest), length(MD5Digest))
 {$WARN UNSAFE_CODE OFF}
  ansiStrings.StrPLCopy(@result[1], PAnsiChar(@MD5Digest), length(MD5Digest))
 {$WARN UNSAFE_CODE ON}
//  result := copy(PChar(MD5Digest), 0, length(MD5Digest));
end;


end.
