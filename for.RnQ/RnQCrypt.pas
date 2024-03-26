unit RnQCrypt;
{$I forRnQConfig.inc}
{$I NoRTTI.inc}

interface

uses
  SysUtils,
   {$IFDEF USE_SYMCRYPTO}
  mormot.core.base,
  mormot.crypt.ecc256r1,
  mormot.crypt.secure,
   {$ELSE !USE_SYMCRYPTO}
     {$IFDEF USE_WE_LIBS}
       //use Wolfgang Ehrhardt's}
      WEHash,
     {$ELSE systems}
      Hash,
     {$ENDIF USE_WE_LIBS}
   {$ENDIF USE_SYMCRYPTO}
  Types;

   {$IFDEF USE_SYMCRYPTO}
type
  TSHA256Digest = THash256;
   {$ELSE }
     {$IFNDEF USE_WE_LIBS}
type
      TSHA256Digest = TBytes;
     {$ENDIF USE_WE_LIBS}
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
  function MD5PassH(const s: RawBytestring): RawByteString; //return HEX(MD5)
  function MD5PassHS(const s: RawBytestring): String; //return HEX(MD5)
  function MD5PassL(const s: RawBytestring): RawByteString; //return hex(MD5)

  function SHA256PassHS(const s: RawBytestring): String; //return HEX(SHA256)
  function SHA256PassLS(const s: RawBytestring): String; //return hex(SHA256)

//  function qip_msg_decr(s1: RawByteString; s2: AnsiString; n: integer): AnsiString;
//  function qip_msg_crypt(s1, s2: AnsiString; n: integer): RawByteString;
  function qip_msg_crypt(const s: AnsiString; p: Integer): RawByteString;
  function qip_msg_decr(const s1: RawByteString; p: integer): AnsiString;
//  function qip_msg_crypt(s1, s2: AnsiString; n: integer): RawByteString;
  function qip_str2pass(const s: RawByteString): Integer;

  function HMAC_MD5(const Text: RawByteString; Key: RawByteString): RawByteString;
  function SHA1Pass(const s: RawBytestring): RawByteString;
  function HMAC_SHA1_EX( const Data: RawByteString;
                       const Key: RawByteString ): RawByteString;

  function DigestToString(digest: TSHA256Digest): RawByteString;

  function Hash256String(const key, str: RawByteString): RawByteString;

  function SHA1toHex( const digest: RawByteString ): String;

//  function EccCommandVerifyFile(const FileToVerify, AuthPubKey: TFileName; fileSha256: THash256): TEccValidity;
  function verifyEccSignFile(const fileName: String; sign64, publicKey: RawByteString; allowSelfSigned: Boolean = True): Boolean;

type
  TProgressFunc = function(p: real): Boolean;

  function getFileMD5(const fn: String; progFunc: TProgressFunc): TBytes;
  function HashFile(const aFileName: TFileName; algo: THashAlgo): THash512Rec;

implementation
uses
  Windows,
   {$IFDEF USE_SYMCRYPTO}
  mormot.crypt.core,
  mormot.core.os,
  mormot.crypt.ecc,
  mormot.core.json,
  mormot.core.text,
    {$ELSE not SynCrypto}
     {$IFDEF USE_WE_LIBS}
       //use Wolfgang Ehrhardt's}
        MD5, SHA1, HMAC, HMACSHA1, HMACSHA2,
     {$ENDIF USE_WE_LIBS}
     classes,
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
 {$IFDEF USE_SYMCRYPTO}
  MD5Digest: TMD5Digest;
   MD5: TMD5;
  {$ELSE not SynCrypto}
     {$IFDEF USE_WE_LIBS}
       //use Wolfgang Ehrhardt's}
       MD5Digest: TMD5Digest;
       MD5Context: THashContext;
     {$ELSE USE systems}
       MD5: THashMD5;
       MD5Digest: TBytes;
     {$ENDIF USE_WE_LIBS}
 {$ENDIF ~USE_SYMCRYPTO}
begin
 {$IFDEF USE_SYMCRYPTO}
   md5.Init;
   if Length(s)>0 then
     md5.Update(s[1], length(s));
   md5.Final(MD5Digest);
  {$ELSE not SynCrypto}
     {$IFDEF USE_WE_LIBS}
      MD5Init(MD5Context);
      MD5UpdateXL(MD5Context, PAnsiChar(s), length(s));
      MD5Final(MD5Context, MD5Digest);
     {$ELSE USE_WE_LIBS}
      MD5 := THashMD5.Create;
      if Length(s)>0 then
        MD5.Update(s[1], length(s));
      MD5Digest := MD5.HashAsBytes;
     {$ENDIF USE_WE_LIBS}
 {$ENDIF ~USE_SYMCRYPTO}
  SetLength(Result, length(MD5Digest));
 {$WARN UNSAFE_CODE OFF}
//  ansiStrings.StrPLCopy(@result[1], PAnsiChar(@MD5Digest), length(MD5Digest))
//  ansiStrings.StrPLCopy(PAnsiChar(result), PAnsiChar(@MD5Digest), length(MD5Digest))
  CopyMemory(@result[1], @MD5Digest[0], length(MD5Digest))
 {$WARN UNSAFE_CODE ON}
//  result := copy(PChar(MD5Digest), 0, length(MD5Digest));
end;

function MD5Pass2(const s: RawBytestring): RawByteString;
var
 {$IFDEF USE_SYMCRYPTO}
   MD5Digest: TMD5Digest;
   MD5: TMD5;
  {$ELSE not SynCrypto}
     {$IFDEF USE_WE_LIBS}
       //use Wolfgang Ehrhardt's}
       MD5Digest: TMD5Digest;
       MD5Context: THashContext;
     {$ELSE USE systems}
       MD5: THashMD5;
       MD5Digest: TBytes;
     {$ENDIF USE_WE_LIBS}
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
     {$IFDEF USE_WE_LIBS}
      MD5Init(MD5Context);
      MD5UpdateXL(MD5Context, PAnsiChar(s), length(s));
      MD5Final(MD5Context, MD5Digest);
     {$ELSE ~USE_WE_LIBS}
      MD5 := THashMD5.Create;
      if Length(s)>0 then
        MD5.Update(s[1], length(s));
      MD5Digest := MD5.HashAsBytes;
     {$ENDIF USE_WE_LIBS}
 {$ENDIF ~USE_SYMCRYPTO}

  SetLength(Result, length(MD5Digest));
 {$WARN UNSAFE_CODE OFF}
//  ansiStrings.StrPLCopy(PAnsiChar(result), PAnsiChar(@MD5Digest), length(MD5Digest))
  CopyMemory(@result[1], @MD5Digest[0], length(MD5Digest))
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
  s4 := Base64DecodeString(s1); //looks like base64 decoding
  l := Length(s4);
  if l>0 then
   for I := 1 to l do
    begin
      Result := Result+AnsiChar(Byte(s4[i]) xor byte(n shr 8));
      n := (Byte(s4[i])+n)*$A8C3+p;
    end;
end;

function HMAC_MD5(const Text: RawByteString; Key: RawByteString): RawByteString;
var
  ipad, opad, s: RawByteString;
  n: Integer;
//  MDContext: TMDCtx;
 {$IFDEF USE_SYMCRYPTO}
   MD5Digest: TMD5Digest;
   MD5: TMD5;
  {$ELSE not SynCrypto}
   {$IFDEF USE_WE_LIBS}
   MD5Digest: TMD5Digest;
   MD5Context: THashContext;
   {$ELSE !USE_WE_LIBS}
   MD5Digest: TBytes;
   {$ENDIF USE_WE_LIBS}
 {$ENDIF ~USE_SYMCRYPTO}
begin
  {$IF NOT DEFINED(USE_SYMCRYPTO) AND NOT DEFINED(USE_WE_LIBS)}
   if Length(Text) > 0 then
     MD5Digest := TBytes(@Text[1])
    else
     MD5Digest := NIL ;
  MD5Digest := THashMD5.GetHMACAsBytes(MD5Digest, TBytes(@Key[1]));
  SetLength(Result, length(MD5Digest));
  ansiStrings.StrPLCopy(PAnsiChar(Result), PAnsiChar(@MD5Digest), length(MD5Digest));
  {$ELSE}
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

 {$IFDEF USE_SYMCRYPTO}
  md5.Init;
  md5.Update(ipad[1], length(ipad));
  if Length(Text) > 0 then
    md5.Update(Text[1], length(Text));
  md5.Final(MD5Digest);
  SetLength(s, length(MD5Digest));
  {$IFNDEF FPC}SysUtils.{$ENDIF ~FPC}StrPLCopy(PAnsiChar(s), PAnsiChar(@MD5Digest), length(MD5Digest));
  md5.Init;
  md5.Update(opad[1], length(opad));
  if Length(s) > 0 then
    md5.Update(s[1], length(s));
  md5.Final(MD5Digest);
  SetLength(Result, length(MD5Digest));
  {$IFNDEF FPC}SysUtils.{$ENDIF ~FPC}StrPLCopy(PAnsiChar(Result), PAnsiChar(@MD5Digest), length(MD5Digest));
 {$ELSE !USE_SYMCRYPTO}
  MD5Init(MD5Context);
  MD5Update(MD5Context, @ipad[1], length(ipad));
  if Length(Text) > 0 then
    MD5UpdateXL(MD5Context, @Text[1], length(Text));
  MD5Final(MD5Context, MD5Digest);
  SetLength(s, length(MD5Digest));
  ansiStrings.StrPLCopy(PAnsiChar(s), PAnsiChar(@MD5Digest), length(MD5Digest));
  MD5Init(MD5Context);
  MD5Update(MD5Context, @opad[1], length(opad));
  if Length(s) > 0 then
    MD5UpdateXL(MD5Context, @s[1], length(s));
  MD5Final(MD5Context, MD5Digest);
  SetLength(Result, length(MD5Digest));
  ansiStrings.StrPLCopy(PAnsiChar(Result), PAnsiChar(@MD5Digest), length(MD5Digest));
 {$ENDIF USE_SYMCRYPTO}
 {$WARN UNSAFE_CODE ON}
  {$IFEND}
end;


function SHA1Pass(const s: RawBytestring): RawByteString;
var
  p: Pointer;
 {$IFDEF USE_SYMCRYPTO}
  SHA1: TSHA1;
  SHA1Digest: TSHA1Digest;
 {$ELSE !USE_SYMCRYPTO}
   {$IFDEF USE_WE_LIBS}
  SHA1Digest: TSHA1Digest;
   {$ELSE !USE_WE_LIBS}
  SHA1: THashSHA1;
  SHA1Digest: TBytes;
   {$ENDIF USE_WE_LIBS}
 {$ENDIF ~USE_SYMCRYPTO}
begin
  if Length(s) > 0 then
    p := @s[1]
   else
    p := NIL;
 {$IFDEF USE_SYMCRYPTO}
  SHA1.full(p, Length(s), SHA1Digest);
 {$ELSE !USE_SYMCRYPTO}
     {$IFDEF USE_WE_LIBS}
      SHA1FullXL(SHA1Digest, p, Length(s));
     {$ELSE !USE_WE_LIBS}
      SHA1 := THashSHA1.Create;
      SHA1.Update(p, Length(s));
      SHA1Digest := SHA1.HashAsBytes;
     {$ENDIF USE_WE_LIBS}
 {$ENDIF USE_SYMCRYPTO}
  SetLength(Result, length(SHA1Digest));
  {$IFNDEF FPC}SysUtils.{$ENDIF ~FPC}StrPLCopy(PAnsiChar(Result), PAnsiChar(@SHA1Digest), length(SHA1Digest));
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
 {$IFDEF USE_SYMCRYPTO}
  Digest: TSHA1Digest;
 {$ELSE !USE_SYMCRYPTO}
   {$IFDEF USE_WE_LIBS}
    Digest: TSHA1Digest;
    hmac_context: THMAC_Context;
   {$ELSE !USE_WE_LIBS}
    d, k, Digest: TBytes;
   {$ENDIF USE_WE_LIBS}
 {$ENDIF ~USE_SYMCRYPTO}
begin
//   HMAC_SHA1( Data, Key, Digest);
 {$IFDEF USE_SYMCRYPTO}
   HMACSHA1( Key, Data, Digest);
 {$ELSE !USE_SYMCRYPTO}
   {$IFDEF USE_WE_LIBS}
     hmac_sha1_init(hmac_context, PAnsiChar(key), Length(key));
     hmac_sha1_updateXL(hmac_context, PAnsiChar(Data), Length(Data));
     hmac_sha1_final(hmac_context, Digest);
   {$ELSE !USE_WE_LIBS}
    d := BytesOf(Data);
    k := BytesOf(Key);
    Digest := THashSHA1.GetHMACAsBytes(d, k);
   {$ENDIF USE_WE_LIBS}
 {$ENDIF USE_SYMCRYPTO}
   SetLength( Result, SizeOf(Digest) );
   Move( digest[0], Result[1], Length(Result) );
end;

function DigestToString(digest: TSHA256Digest): RawByteString;
begin
  SetString(Result, PAnsiChar(@digest[0]), Length(digest));
end;

function Hash256String(const key, str: RawByteString): RawByteString;
var
 {$IFDEF USE_SYMCRYPTO}
  digest: TSHA256Digest;
 {$ELSE !USE_SYMCRYPTO}
   {$IFDEF USE_WE_LIBS}
    digest: TSHA256Digest;
    hmac_context: THMAC_Context;
   {$ELSE !USE_WE_LIBS}
    d, k, Digest: TBytes;
   {$ENDIF USE_WE_LIBS}
 {$ENDIF ~USE_SYMCRYPTO}
begin
 {$IFDEF USE_SYMCRYPTO}
  HMACSHA256(key, str, digest);
 {$ELSE !USE_SYMCRYPTO}
   {$IFDEF USE_WE_LIBS}
   hmac_SHA256_init(hmac_context, PAnsiChar(key), Length(key));
   hmac_SHA256_updateXL(hmac_context, PAnsiChar(str), Length(str));
   hmac_SHA256_final(hmac_context, Digest);
   {$ELSE !USE_WE_LIBS}
    d := BytesOf(str);
    k := BytesOf(Key);
    Digest := THashSHA2.GetHMACAsBytes(d, k);
   {$ENDIF USE_WE_LIBS}
 {$ENDIF USE_SYMCRYPTO}
  Result := Base64EncodeString(DigestToString(digest));
end;

   {$IFDEF USE_SYMCRYPTO}
function getFileMD5(const fn: String; progFunc: TProgressFunc): TBytes;
var
  F: THandle;
  digest: TMD5Digest;
  MD5: TMD5;
  fSize: TQWordRec;
  fPos: UInt64;
  buf: array [1..1024*1024] of byte;
  i: integer;
begin
  for i:=0 to 15 do
    byte(digest[i]) := succ(i);
  F := FileOpenSequentialRead(fn);
  if PtrInt(F)>=0 then
    try
      md5.Init;
      fSize.L := GetFileSize(F, @fSize.H);
      fPos := 0;
      if fSize.V > 0 then
        repeat
          i := FileRead(F, pointer(buf[1])^, sizeof(buf));
          Inc(fPos, i);
          md5.Update(buf[1], i);
          if Assigned(progFunc) and not( progFunc((fPos / fSize.V))) then
            exit;
        until i < sizeof(buf);
   finally
    FileClose(F);
    md5.Final(digest);
  end;
  SetLength(Result, length(digest));
  {$IFNDEF FPC}SysUtils.{$ENDIF ~FPC}StrPLCopy(PAnsiChar(Result), PAnsiChar(@digest), length(digest));
end;

function HashFile256(const aFileName: TFileName): THash256;
var
//  hasher: TSynHasher;
  hasher: TSha256;
  temp: RawByteString;
  F: THandle;
  size, tempsize: Int64;
  n, read: integer;
  rr: THash512Rec;
begin
  FillZero(result);
  if aFileName = '' then
    exit;
  n := 0;
  F := FileOpenSequentialRead(aFileName);
  if ValidHandle(F) then
  try
//    hasher.Init(hfSHA256);
    hasher.Init;
    size := FileSize(F);
    tempsize := 1 shl 20; // 1MB temporary buffer for reading
    if tempsize > size then
      tempsize := size;
    SetLength(temp, tempsize);
    dec(n);
    while size > 0 do
    begin
      read := FileRead(F, temp[1], tempsize);
      if read <= 0 then
        exit;
      hasher.Update(@temp[1], read);
      dec(size, read);
    end;
    hasher.Final(rr.Lo);
     result := rr.Lo;
  finally
    FileClose(F);
  end;
end;

function HashFile(const aFileName: TFileName; algo: THashAlgo): THash512Rec;
var
  hasher: TSynHasher;
  temp: RawByteString;
  F: THandle;
  size, tempsize: Int64;
  n, read: integer;
  //rr: THash512Rec;
begin
  FillZero(result.b);
  if aFileName = '' then
    exit;
  n := 0;
  F := FileOpenSequentialRead(aFileName);
  if ValidHandle(F) then
  try
    hasher.Init(algo);
    size := FileSize(F);
    tempsize := 1 shl 20; // 1MB temporary buffer for reading
    if tempsize > size then
      tempsize := size;
    SetLength(temp, tempsize);
    dec(n);
    while size > 0 do
    begin
      read := FileRead(F, pointer(temp)^, tempsize);
      if read <= 0 then
        exit;
      hasher.Update(pointer(temp), read);
      dec(size, read);
    end;
    hasher.Final(Result);
  finally
    FileClose(F);
  end;
end;
   {$ELSE NOT USE_SYMCRYPTO}
   {$IFDEF USE_WE_LIBS}
function getFileMD5(fn: String; progFunc: TProgressFunc): TBytes;
var
  digest: TMD5Digest;
//  context: TMD5Context;
  context: THashContext;
  fs: Tfilestream;
  buf: array [1..16*1024] of byte;
  i: integer;
  pos, size: UInt64;
begin
  fs := TFileStream.create(fn, fmOpenRead+fmShareDenyWrite);
  for i:=0 to 15 do
    byte(digest[i]) := succ(i);
  MD5init(context);
  pos := 0;
  size := fs.size;
  try
     if size > 0 then
      repeat
        i := fs.Read(buf, sizeof(buf));
        inc(pos, i);
    //    MD5updateBuffer(context, @buf, i);
        if i > 0 then
          MD5Update(context, @buf, i);
        if Assigned(progFunc) and not progFunc(0.0+pos / size) then
          exit;
      until i < sizeof(buf);
   finally
      fs.free;
//      MD5final(digest, context);
      MD5final(context, digest);
//      for i:=0 to 15 do
//        result := result + intToHex(byte(digest[i]), 2);
  end;
  SetLength(Result, length(digest));
  ansiStrings.StrPLCopy(PAnsiChar(Result), PAnsiChar(@digest), length(digest));
end;
   {$ELSE !USE_WE_LIBS}
function getFileMD5(fn: String; progFunc: TProgressFunc): TBytes;
var
  digest: TBytes;
  md5: THashMD5;
  fs: Tfilestream;
  buf: array [1..16*1024] of byte;
  i: integer;
  pos, size: UInt64;
begin
  fs := TFileStream.create(fn, fmOpenRead+fmShareDenyWrite);
  for i:=0 to 15 do
    byte(digest[i]) := succ(i);
  md5 := THashMD5.Create;
  pos := 0;
  size := fs.size;
  try
     if size > 0 then
      repeat
        i := fs.Read(buf, sizeof(buf));
        inc(pos, i);
    //    MD5updateBuffer(context, @buf, i);
        if i > 0 then
          md5.Update(buf, i);
        if Assigned(progFunc) and not progFunc(0.0+pos / size) then
          exit;
      until i < sizeof(buf);
   finally
      fs.free;
      digest := MD5.HashAsBytes;
  end;
  SetLength(Result, length(digest));
  ansiStrings.StrPLCopy(PAnsiChar(Result), PAnsiChar(@digest), length(digest));
end;
   {$ENDIF USE_WE_LIBS}
   {$ENDIF USE_SYMCRYPTO}

function MD5PassH(const s: RawBytestring): RawByteString;
var
  digest: RawBytestring;
  i: Integer;
begin
  Result := '';
  digest := MD5Pass2(s);
  if length(digest) > 0 then
    for i:=1 to length(digest) do
      result := result + IntToHexA(byte(digest[i]), 2);
end;

function MD5PassL(const s: RawBytestring): RawByteString;
var
  digest: RawBytestring;
  i: Integer;
begin
  Result := '';
  digest := MD5Pass2(s);
  if length(digest) > 0 then
    for i:=1 to length(digest) do
      result := result + IntToHexAL(byte(digest[i]), 2);
end;

function MD5PassHS(const s: RawBytestring): String; //return HEX(MD5)
var
  digest: RawBytestring;
  i: Integer;
begin
  Result := '';
  digest := MD5Pass2(s);
  if length(digest) > 0 then
    for i:=1 to length(digest) do
      result := result + intToHex(byte(digest[i]), 2);
end;

function SHA256PassHS(const s: RawBytestring): String; //return HEX(SHA256)
var SHA: TSHA256;
    Digest: TSHA256Digest;
//var
//  digest: RawBytestring;
  b: Byte;
begin
  Result := '';
  SHA.Full(pointer(s),length(s),Digest);

//  digest := SHA256(s);
//  if length(digest) > 0 then
    for b in digest do
      result := result + intToHex(Byte(b), 2);
end;

function SHA256PassLS(const s: RawBytestring): String; //return hex(SHA256)
var SHA: TSHA256;
    Digest: TSHA256Digest;
//var
//  digest: RawBytestring;
  b: Byte;
begin
  Result := '';
  SHA.Full(pointer(s),length(s),Digest);

//  digest := SHA256(s);
//  if length(digest) > 0 then
    for b in digest do
      result := result + LowerCase(IntToHex(Byte(b), 2));
end;

// converts SHA1 digest into a hex-string

function SHA1toHex( const digest: RawByteString ): String;
var  i: Integer;
begin
   Result := '';
   for i:=1 to length(digest) do
     Result := Result + inttohex( ord( digest[i] ), 2 );
   Result := LowerCase( Result );
end;

function EccCommandVerifyFile(fileSha256: THash256; const sign64: RawByteString; const AuthPubKey: RawByteString): TEccValidity;
//const
  //AuthBase64: String = '';
var
  auth: TEccCertificate;
  cert: TEccSignatureCertified;
begin
  cert := TEccSignatureCertified.CreateFromBase64(sign64);
  try
    if not cert.Check then
    begin
      result := ecvInvalidSignature;
      exit;
    end;
    auth := TEccCertificate.Create;
    try
//      if auth.FromAuth(AuthPubKey, AuthBase64, cert.AuthoritySerial) then
      if auth.FromBase64(AuthPubKey) then
        begin
          result := cert.Verify(auth, fileSha256);
        end
      else
        result := ecvUnknownAuthority;
    finally
      auth.Free;
    end;
  finally
    cert.Free;
  end;
end;

function verifyEccSignFile(const fileName: String; sign64, publicKey: RawByteString; allowSelfSigned: Boolean = True): Boolean;
var
  v: TEccValidity;
  hash: TSha256Digest;
//  sign64: RawByteString;
  pub64: RawByteString;
begin
  if not FileExists(fileName) then
    Exit(False);
  hash := HashFile256(fileName);
//  if FileExists(sigFileName) then
//    sign64 := StringFromFile(sigFileName);
  pub64 := JsonDecode(PUTF8Char(publicKey), 'Base64', nil, true);
  v := EccCommandVerifyFile(hash, sign64, pub64);
  Result := (v = ecvValidSigned) or (allowSelfSigned and (v = ecvValidSelfSigned));
end;


end.
