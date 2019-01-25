unit RnQCrypt;
{$I forRnQConfig.inc}
{$I NoRTTI.inc}

interface

   {$IFDEF USE_SYMCRYPTO}
uses
  SynCommons;
   {$ENDIF USE_SYMCRYPTO}

// crypting
function  passCrypt(const s: RawByteString): RawByteString;
function  passDeCrypt(const s: RawByteString): RawByteString;
function  decritted(const s: RawByteString; key: integer): RawByteString;
function  critted(const s: RawByteString; key: integer): RawByteString;
procedure critt(var s: RawByteString; key: integer);
procedure decritt(var s: RawByteString; key: integer);
function  calculate_KEY1(const pwd: AnsiString): integer;
function  calculate_KEY(const pwd: String): integer;
function  MD5Pass(const s: RawByteString): RawByteString;
function  MD5Pass2(const s: RawByteString): RawByteString;

//  function qip_msg_decr(s1: RawByteString; s2: AnsiString; n: integer): AnsiString;
//  function qip_msg_crypt(s1, s2: AnsiString; n: integer): RawByteString;
  function qip_msg_crypt(const s: AnsiString; p: Integer): RawByteString;
  function qip_msg_decr(const s1: RawByteString; p: integer): AnsiString;
//  function qip_msg_crypt(s1, s2: AnsiString; n: integer): RawByteString;
  function qip_str2pass(const s: RawByteString): Integer;

  function HMAC_MD5(Text, Key: RawByteString): RawByteString;
  function SHA1Pass(const s: RawBytestring): RawByteString;
  function HMAC_SHA1_EX( const Data: RawByteString;
                       const Key : RawByteString ): RawByteString;

  function DigestToString(digest: THash256): RawByteString;

  function Hash256String(key, str: RawByteString): RawByteString;

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
   Base64, RDUtils;

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

function calculate_KEY(const pwd: String): integer;
begin
  Result := calculate_KEY1(AnsiString(pwd));
end;


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
//  ansiStrings.StrPLCopy(@result[1], PAnsiChar(@MD5Digest), length(MD5Digest))
  ansiStrings.StrPLCopy(PAnsiChar(result), PAnsiChar(@MD5Digest), length(MD5Digest))
 {$WARN UNSAFE_CODE ON}
//  result := copy(PChar(MD5Digest), 0, length(MD5Digest));
end;

function MD5Pass2(const s: RawBytestring): RawByteString;
var
  MD5Digest: TMD5Digest;
 {$IFDEF USE_SYMCRYPTO}
   MD5: TMD5;
  {$ELSE not SynCrypto}
   MD5Context: TMD5Context;
 {$ENDIF ~USE_SYMCRYPTO}
begin
 {$IFDEF USE_SYMCRYPTO}
   if Length(s)>0 then
     begin
       md5.Full(@s[1], length(s), MD5Digest);
     end
    else
     begin
       MD5.Init;
       md5.Final(MD5Digest);
     end;
  {$ELSE not SynCrypto}
  MD5Init(MD5Context);
  MD5UpdateBuffer(MD5Context, PAnsiChar(s), length(s));
  MD5Final(MD5Digest, MD5Context);
 {$ENDIF ~USE_SYMCRYPTO}

  SetLength(Result, length(MD5Digest));
 {$WARN UNSAFE_CODE OFF}
  ansiStrings.StrPLCopy(PAnsiChar(result), PAnsiChar(@MD5Digest), length(MD5Digest))
 {$WARN UNSAFE_CODE ON}
end;

function qip_msg_crypt(const s: AnsiString; p: Integer): RawByteString;
//                 текст    пароль
const
  n0 = $1B5F;
var
  s5: RawByteString;
  n, l, i: integer;
begin
  Result := s;
  if p=0 then
    exit;
  Result := '';
  s5 := '';
  n := n0;
  l := Length(s);
  if l>0 then
   for I := 1 to l do
    begin
      s5 := s5+ AnsiChar(Byte(s[i]) xor byte(n shr 8));
      n:=(Byte(s5[i])+n)*$A8C3+p;
    end;
//  s5:=_005D6FF8(Result); //похоже на кодирование base64
  Result:= Base64EncodeString(s5);
end;

function qip_str2pass(const s: RawByteString): Integer;
var
  l, i: Integer;
begin
  Result := 0;
  l := Length(s);
  if l > 0 then
   begin
     Result := $3E9;
     for I := 1 to l do
      Result := Result+ Byte(s[i]);
   end;
end;

function qip_msg_decr(const s1: RawByteString; p: integer): AnsiString;
const
  n0 = $1B5F;
var
  s4: RawByteString;
//  a,
  n, l: integer;
  I: Integer;
begin
  if p=0 then
   begin
    Result := s1;
    exit;
   end;
  Result := '';
  n := n0;
//  a:=0;
  s4 := Base64DecodeString(s1); //похоже на декодирование base64
  l := Length(s4);
  if l>0 then
   for I := 1 to l do
    begin
      Result := Result+AnsiChar(Byte(s4[i]) xor byte(n shr 8));
      n := (Byte(s4[i])+n)*$A8C3+p;
    end;
end;

function HMAC_MD5(Text, Key: RawByteString): RawByteString;
var
  ipad, opad, s: RawByteString;
  n: Integer;
//  MDContext: TMDCtx;
  MD5: TMD5;
  MD5Digest: TMD5Digest;
begin
 {$WARN UNSAFE_CODE OFF}
  if Length(Key) > 64 then
    Key := MD5Pass(Key);
  ipad := StringOfChar(AnsiChar(#$36), 64);
  opad := StringOfChar(AnsiChar(#$5C), 64);
  for n := 1 to Length(Key) do
  begin
    ipad[n] := AnsiChar(Byte(ipad[n]) xor Byte(Key[n]));
    opad[n] := AnsiChar(Byte(opad[n]) xor Byte(Key[n]));
  end;

  md5.Init;
  md5.Update(ipad[1], length(ipad));
  md5.Update(Text[1], length(Text));
  md5.Final(MD5Digest);
  SetLength(s, length(MD5Digest));
  ansiStrings.StrPLCopy(PAnsiChar(s), PAnsiChar(@MD5Digest), length(MD5Digest));
  md5.Init;
  md5.Update(opad[1], length(opad));
  md5.Update(s[1], length(s));
  md5.Final(MD5Digest);
  SetLength(Result, length(MD5Digest));
  ansiStrings.StrPLCopy(PAnsiChar(Result), PAnsiChar(@MD5Digest), length(MD5Digest));
 {$WARN UNSAFE_CODE ON}
{

  MDInit(MDContext);
  MDUpdate(MDContext, ipad, @MD5Transform);
  MDUpdate(MDContext, Text, @MD5Transform);
  s := MDFinal(MDContext, @MD5Transform);
  MDInit(MDContext);
  MDUpdate(MDContext, opad, @MD5Transform);
  MDUpdate(MDContext, s, @MD5Transform);
  Result := MDFinal(MDContext, @MD5Transform);
}
end;


function SHA1Pass(const s: RawBytestring): RawByteString;
var
  SHA1Digest: TSHA1Digest;
  SHA1: TSHA1;
begin
  SHA1.full(@s[1], Length(s), SHA1Digest);
  SetLength(Result, length(SHA1Digest));
  ansiStrings.StrPLCopy(PAnsiChar(Result), PAnsiChar(@SHA1Digest), length(SHA1Digest));
end;
{
function HMAC_SHA1(Text, Key: RawByteString): RawByteString;
var
  ipad, opad, s: RawByteString;
  n: Integer;
//  SHA1Context: TSHA1;
  SHA1: TSHA1;
  SHA1Digest: TSHA1Digest;
begin
  if Length(Key) > 64 then
    Key := SHA1Pass(Key);
  ipad := StringOfChar(AnsiChar(#$36), 64);
  opad := StringOfChar(AnsiChar(#$5C), 64);
  for n := 1 to Length(Key) do
  begin
    ipad[n] := AnsiChar(Byte(ipad[n]) xor Byte(Key[n]));
    opad[n] := AnsiChar(Byte(opad[n]) xor Byte(Key[n]));
  end;

  SHA1.Init;
  SHA1.Update(@ipad[1], length(ipad));
  SHA1.Update(@Text[1], length(Text));
  SHA1.Final(SHA1Digest);
  SetLength(s, length(SHA1Digest));
  ansiStrings.StrPLCopy(PAnsiChar(s), PAnsiChar(@SHA1Digest), length(SHA1Digest));
  SHA1.Init;
  SHA1.Update(@opad[1], length(opad));
  SHA1.Update(@s[1], length(s));
  SHA1.Final(SHA1Digest);
  SetLength(Result, length(SHA1Digest));
  ansiStrings.StrPLCopy(PAnsiChar(Result), PAnsiChar(@SHA1Digest), length(SHA1Digest));
end;
}
function HMAC_SHA1_EX( const Data: RawByteString;
                       const Key : RawByteString ): RawByteString;
var
  Digest: TSHA1Digest;
begin
//   HMAC_SHA1( Data, Key, Digest);
   HMAC_SHA1( Key, Data, Digest);
   SetLength( Result, SizeOf(TSHA1Digest) );
   Move( digest[0], Result[1], Length(Result) );
end;

function DigestToString(digest: THash256): RawByteString;
begin
  SetString(Result, PAnsiChar(@digest[0]), Length(digest));
end;

function Hash256String(key, str: RawByteString): RawByteString;
var
  digest: TSHA256Digest;
begin
  HMAC_SHA256(key, str, digest);
  Result := Base64EncodeString(DigestToString(digest));
end;

end.
