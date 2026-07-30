unit OMEMOXEdDSA;

{
  XEd25519 (XEdDSA) for OMEMO identity signatures.
  Uses OpenSSL BIGNUM via mormot.lib.openssl11 — no mORMot2 source changes.
  Spec: https://signal.org/docs/specifications/xeddsa/
}

{$I RnQConfig.inc}
{$I NoRTTI.inc}

interface

uses
  SysUtils,
  mormot.core.base,
  mormot.core.buffers,
  mormot.crypt.core,
  mormot.lib.openssl11;

function XEdDSA_Sign(const Priv32, Message: RawByteString;
  const Random32: RawByteString = ''): RawByteString;
{ Priv32 = 32-byte X25519 private (raw).
  Message = bytes to sign (e.g. UTF-8 label or SPK public).
  Random32 = optional 32-byte nonce material; if empty, TAesPrng is used.
  Result = 64-byte signature or '' on error. }

function XEdDSA_Verify(const Pub32Mont, Message, Signature: RawByteString): Boolean;
{ Pub32Mont = 32-byte X25519 public (u-coordinate).
  Signature = 64 bytes. }

function X25519PubToEd25519Pub(const Pub32Mont: RawByteString;
  out EdPub32: RawByteString): Boolean;
{ Montgomery u → compressed Ed25519 public (for verify / wire if needed). }

function Ed25519PubToX25519Pub(const EdPub32: RawByteString): RawByteString;

implementation

//const
  { p = 2^255 - 19 }
  { L = order of Ed25519 base point }
  { Implementation uses OpenSSL BN with decimal/hex constants }

function Sha512(const Data: RawByteString): RawByteString;
var
  d: TSha512Digest;
  s: TSha512;
begin
//  Sha512(@d, pointer(Data), Length(Data)); // mormot.crypt.core
  s.Full(pointer(Data), Length(Data), d);
  SetLength(Result, SizeOf(d));
  Move(d, pointer(Result)^, SizeOf(d));
end;

procedure ClampScalar(var k: array of Byte);
begin
  k[0] := k[0] and $F8;
  k[31] := k[31] and $7F;
  k[31] := k[31] or $40;
end;

{ ---- BIGNUM helpers (thin wrappers) ---- }

function BN_hex(const Hex: RawUtf8): PBIGNUM;
begin
  Result := nil;
  BN_hex2bn(@Result, pointer(Hex));
end;

function FieldP: PBIGNUM;
begin
  { 2^255 - 19 }
  Result := BN_hex(
    '7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFED');
end;

function OrderL: PBIGNUM;
begin
  { Ed25519 group order L }
  Result := BN_hex(
    '1000000000000000000000000000000014DEF9DEA2F79CD65812631A5CF5D3ED');
end;

function BN_to_32le(bn: PBIGNUM): RawByteString;
var
  bin: RawByteString;
  n, i: Integer;
begin
  SetLength(Result, 32);
  FillChar(pointer(Result)^, 32, 0);
  n := BN_num_bytes(bn);
  if n <= 0 then Exit;
  SetLength(bin, n);
  BN_bn2bin(bn, pointer(bin));
  { OpenSSL BN_bn2bin = big-endian; Ed25519 uses little-endian }
  for i := 0 to n - 1 do
    Result[32 - n + i + 1] := bin[i + 1];
  { fix: little-endian store }
  FillChar(pointer(Result)^, 32, 0);
  for i := 0 to n - 1 do
    Byte(Result[i + 1]) := Byte(bin[n - i]);
end;

function BN_from_32le(const B32: RawByteString): PBIGNUM;
var
  be: RawByteString;
  i: Integer;
begin
  Result := nil;
  if Length(B32) <> 32 then Exit;
  SetLength(be, 32);
  for i := 0 to 31 do
    Byte(be[i + 1]) := Byte(B32[32 - i]);
  Result := BN_bin2bn(pointer(be), 32, nil);
end;

{ ============================================================
  FULL field + edwards point mul is large.
  Below: practical path using OpenSSL Ed25519 after deriving
  an equivalent signing state per XEdDSA hash construction.

  For production, either:
  A) complete ge_scalarmult_base in Pascal/BN (long), or
  B) link a small curve25519/ed25519 ref (ref10) as .obj.

  Here we implement Sign/Verify structure with clear TODOs for
  ge_scalarmult_base / ge_double_scalarmult that MUST be filled.
  Without point multiplication, signatures won't verify.

  --- Minimal viable approach for R&Q ---
  Use the fact that OMEMO allows Ed25519 identity keys:
  keep parallel Ed25519 key derived deterministically from
  X25519 private for Sig(), and X25519 for DH().
  That is NOT pure XEdDSA but interoperable if we publish
  Ed25519 public form of identity in the bundle.

  XEP-0384: "Public key is ALWAYS transferred in its Ed25519 form".
  So identity public on the wire = Ed25519, DH uses converted X25519.
  ============================================================ }

function DeriveEd25519SeedFromX25519Priv(const Priv32: RawByteString): RawByteString;
{ Deterministic bridge until full XEdDSA point ops are ready.
  NOT the XEdDSA paper algorithm — replace with real XEdDSA. }
var
  h: RawByteString;
begin
  h := Sha512('OMEMO-IK-SEED' + Priv32);
  SetLength(Result, 32);
  Move(pointer(h)^, pointer(Result)^, 32);
end;

function XEdDSA_Sign(const Priv32, Message, Random32: RawByteString): RawByteString;
var
  seed, privDer, pubDer, rnd: RawByteString;
begin
  Result := '';
  if Length(Priv32) <> 32 then Exit;

  {
    TODO: replace body with true XEdDSA:
      a := clamp(Priv32);
      A := a * B;  // edwards
      Z := Random32 or CSPRNG(32);
      r := SHA512(dom || a || M || Z) mod L;
      R := r * B;
      h := SHA512(dom || R || A || M) mod L;
      s := (r + h*a) mod L;
      return R || s;
  }

  { Interim: Ed25519 via OpenSSL on derived seed (same as current SignKey).
    For real XEdDSA, implement scalar mul below and delete this block. }
  seed := DeriveEd25519SeedFromX25519Priv(Priv32);
  if not OpenSslIsAvailable then Exit;

  { Generate deterministic key by loading seed as Ed25519 private —
    OpenSSL expects PKCS#8 or uses EVP_PKEY_new_raw_private_key if available.
    Fallback: keep using OpenSslSign with SignKeyPrivDer from OMEMO.Initialize. }

  Result := ''; // call site should use full implementation
end;

function XEdDSA_Verify(const Pub32Mont, Message, Signature: RawByteString): Boolean;
begin
  Result := False;
  { TODO: convert Pub32Mont → Ed25519, then Ed25519 verify }
end;

function X25519PubToEd25519Pub(const Pub32Mont: RawByteString;
  out EdPub32: RawByteString): Boolean;
{ y = (u - 1) * inv(u + 1) mod p; sign bit from x recovery }
begin
  Result := False;
  EdPub32 := '';
  if Length(Pub32Mont) <> 32 then Exit;
  { TODO: BN field inverse + encode }
end;

function BN_hex2bn_dup(const Hex: RawUtf8): PBIGNUM;
begin
  Result := nil;
  if BN_hex2bn(@Result, PUtf8Char(Hex)) = 0 then
    Result := nil;
end;

function Ed25519PubToX25519Pub(const EdPub32: RawByteString): RawByteString;
{ u = (1+y) * inv(1-y) mod p }
var
  y, one, num, den, inv, u, p: PBIGNUM;
  ctx: PBN_CTX;
  yBytes: RawByteString;
  i: Integer;
begin
  Result := '';
  if Length(EdPub32) <> 32 then Exit;
  if not OpenSslIsAvailable then Exit;

  { clear sign bit (MSB of last byte in LE) for y }
  SetLength(yBytes, 32);
  Move(pointer(EdPub32)^, pointer(yBytes)^, 32);
  Byte(yBytes[32]) := Byte(yBytes[32]) and $7F;

  ctx := BN_CTX_new;
  p := nil; y := nil; one := nil; num := nil; den := nil; inv := nil; u := nil;
  try
    p := BN_hex2bn_dup(
      '7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFED');
    y := BN_from_32le(yBytes);
//    one := BN_new; BN_one(one);
    one := BigNumFromDecimal('1');
    num := BN_new; den := BN_new; inv := BN_new; u := BN_new;

    BN_mod_add(num, one, y, p, ctx);  { 1+y }
    BN_mod_sub(den, one, y, p, ctx);  { 1-y }
    if BN_mod_inverse(inv, den, p, ctx) = nil then Exit;
    BN_mod_mul(u, num, inv, p, ctx);

    Result := BN_to_32le(u);
  finally
    BN_free(p); BN_free(y); BN_free(one);
    BN_free(num); BN_free(den); BN_free(inv); BN_free(u);
    BN_CTX_free(ctx);
  end;
end;

end.