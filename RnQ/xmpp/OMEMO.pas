unit OMEMO;

{
  OMEMO 2 (XEP-0384) — Этап 1: ключи + device list + bundle (PEP)
  mORMot2 trunk + OpenSSL, без изменений в исходниках mORMot2

  Требуется:
    - define USE_OPENSSL в проекте
    - RegisterOpenSsl при старте
    - OpenSSL 1.1.1+ / 3.x (нужен X25519)
}

{$I RnQConfig.inc}
{$I NoRTTI.inc}

interface

uses
  SysUtils, Classes,
  mormot.core.base,
  mormot.core.buffers,
  mormot.core.unicode,
  mormot.core.text,
  mormot.crypt.core,
  mormot.crypt.secure,
  mormot.crypt.openssl,
  mormot.lib.openssl11,
  OMEMOSessions,
  OMEMOXEdDSA,
  RnQXml, NativeXml;

const
  OMEMO_AXOLOTL_NS    = 'eu.siacs.conversations.axolotl';
  OMEMO2_NS           = 'urn:xmpp:omemo:2';
  OMEMO2_DEVICES_NODE = 'urn:xmpp:omemo:2:devices';
  OMEMO2_BUNDLES_NODE = 'urn:xmpp:omemo:2:bundles';

  OMEMO_KEY_LEN = 32;
  OMEMO_SIG_LEN = 64;
  OMEMO_PREKEY_COUNT = 100;
  OMEMO_MAX_SKIP = 1000;

  { OpenSSL NID / EVP type for X25519 — в trunk mORMot2 константы нет,
    но OpenSslGenerateKeys принимает integer. Не меняем mORMot2. }
  OSSL_EVP_PKEY_X25519 = 1034; // NID_X25519 = EVP_PKEY_X25519

type
  TOMEMOKeyPair = record
    Priv: RawByteString; // 32 raw bytes (secret)
    Pub:  RawByteString; // 32 raw bytes (public)
  end;

  TOMEMOSignedPreKey = record
    ID: Integer;
    Key: TOMEMOKeyPair;
    Signature: RawByteString; // 64 bytes
  end;

  TOMEMOPreKey = record
    ID: Integer;
    Key: TOMEMOKeyPair;
  end;

  TOMEMOBundle = record
    { Identity: Ed25519 (OpenSSL DER) + raw 32-byte public for wire }
    IdentityPrivDer: RawByteString;
    IdentityPubDer:  RawByteString;
    IdentityPubRaw:  RawByteString; // 32-byte Ed25519 public (для ik / labelsig verify)

    { Для X3DH DH(IK, …) — X25519, derived from Ed25519 }
    IdentityX25519: TOMEMOKeyPair;  // Priv/Pub по 32 raw

    SignedPreKey: TOMEMOSignedPreKey; // X25519 + Ed25519 signature
    PreKeys: array of TOMEMOPreKey;
  end;

type
  TOMEMOProtocol = (ompUnknown, ompAxolotl, ompOmemo2);

  TOMEMOKeyElement = record
    Rid: Integer;
    IsPreKey: Boolean;     // prekey=true / kex=true
    Data: RawByteString;     // raw bytes после Base64
  end;

  TOMEMOKeysGroup = record
    Jid: RawUtf8;            // jid получателя
    Keys: array of TOMEMOKeyElement;
  end;

  TOMEMOEncryptedMessage = record
    Protocol: TOMEMOProtocol;
    FromJid: RawUtf8;
    FromResource: RawUtf8;
    ToJid: RawUtf8;
    MsgId: RawUtf8;
    SenderDeviceId: Integer; // header@sid
    KeyGroups: array of TOMEMOKeysGroup;
    IV: RawByteString;         // только axolotl
    Payload: RawByteString;  // raw ciphertext||tag
    HasPayload: Boolean;
    // удобно: ключ именно для нашего device
    OurKey: TOMEMOKeyElement;
    HasOurKey: Boolean;
  end;

  TPreKeySignalMsg = record
    RegistrationId: Integer;
    PreKeyId: Integer;
    SignedPreKeyId: Integer;
    BaseKey: RawByteString;     // 32, Alice EK
    IdentityKey: RawByteString; // 32, Alice IK
    Message: RawByteString;     // вложенный WhisperMessage
    OK: Boolean;
  end;

  TWhisperMessage = record
    RatchetKey: RawByteString; // 32
    N: Integer;                // message counter
    Pn: Integer;               // previous chain length
    Ciphertext: RawByteString;
    OK: Boolean;
  end;

type
  TOMEMOManager = class
  private
    FDeviceID: Integer;
    FDeviceLabel: RawUtf8;
    FBundle: TOMEMOBundle;
    FReady: Boolean;
    FSessions: TOMEMOSessionStore;

    function B64(const S: RawByteString): RawUtf8;
    function ExtractRaw32FromX25519PrivateDer(const Der: RawByteString): RawByteString;
    function ExtractRaw32FromX25519PublicDer(const Der: RawByteString): RawByteString;
//    function X25519ECDH(const OurPriv32, TheirPub32: RawByteString): RawByteString;
//    function OMEMOHKDF(const IKM, Salt, Info: RawByteString; L: Integer): RawByteString;
    function SignDeviceLabel(const LabelUtf8: RawByteString): RawByteString;
    function VerifyDeviceLabel(const LabelUtf8, LabelSigB64: RawUtf8;
             const IdentityPubEd25519Der: RawByteString): Boolean;
  public
    constructor Create;
    destructor Destroy; override;

    class function GenX25519(out Key: TOMEMOKeyPair): Boolean;
    class function GenEd25519(out PrivDer, PubDer: RawByteString): Boolean;
    class function SignEd25519(const PrivDer, Msg: RawByteString): RawByteString;
    class function VerifyEd25519(const PubDer, Msg, Sig: RawByteString): Boolean;
    class function ParsePreKeySignalMessage(const Data: RawByteString): TPreKeySignalMsg;
    class function BareJidOf(const FullJid: RawUtf8): RawUtf8;
    class function ParseWhisperMessage(const Data: RawByteString): TWhisperMessage;

    procedure Initialize(pDeviceID: Integer; const pDeviceLabel: String);
    function  IsReady: Boolean;

    property DeviceID: Integer read FDeviceID;
    property Bundle: TOMEMOBundle read FBundle;
    property Sessions: TOMEMOSessionStore read FSessions;

    function BuildDeviceListXML: TRnQXML;
    function BuildBundleXML: TRnQXML;
    function EstablishFromPreKey(
      const BareJid: RawUtf8;
      const Msg: TOMEMOEncryptedMessage): TOMEMOSession;
    procedure InitRecvChainAfterX3DH(S: TOMEMOSession;
      const AliceRatchetPub: RawByteString);
    function DecryptOMEMO(const Msg: TOMEMOEncryptedMessage): RawUtf8;
  end;

  function ParseOMEMOEncrypted(const MsgEl: TsdElement;
    OurDeviceId: Integer): TOMEMOEncryptedMessage;
  function IsOMEMOMessage(const MsgEl: TsdElement): Boolean;

  function X25519ECDH(const OurPriv32, TheirPub32: RawByteString): RawByteString;
  function OMEMOHKDF(const IKM, Salt, Info: RawByteString; L: Integer): RawByteString;
//  function ParsePreKeySignalMessage(const Data: RawByteString): TPreKeySignalMsg;

implementation

{ ---- helpers: DER → raw 32 bytes for X25519 (fixed OpenSSL layout) ---- }

function FindRaw32AfterHeader(const Der: RawByteString;
  const Header: array of Byte): RawByteString;
var
  i, hLen: Integer;
  match: Boolean;
  j: Integer;
begin
  Result := '';
  hLen := Length(Header);
  if (hLen = 0) or (Length(Der) < hLen + OMEMO_KEY_LEN) then
    Exit;
  for i := 1 to Length(Der) - hLen - OMEMO_KEY_LEN + 1 do
  begin
    match := True;
    for j := 0 to hLen - 1 do
      if Byte(Der[i + j]) <> Header[j] then
      begin
        match := False;
        Break;
      end;
    if match then
    begin
      Result := Copy(Der, i + hLen, OMEMO_KEY_LEN);
      Exit;
    end;
  end;
end;

function Sha512(const s: Pointer; sLength: Integer): RawUtf8;
var
  sha: TSha512;
  dig: TSha512Digest;
begin
  sha.Full(s, sLength, dig);
  BinToHexLower(@dig, SizeOf(dig), result);
  FillZero(dig);
end;

function Ed25519SeedToX25519Priv(const Seed32: RawByteString): RawByteString;
{ crypto_sign_ed25519_sk_to_curve25519 }
var
  h: TSha512Digest;
  hs: RawUtf8;
//  i: Integer;
begin
  Result := '';
  if Length(Seed32) <> 32 then Exit;
  hs := Sha512(pointer(Seed32), 32);
  Move512(@h, @hs[1]);
//  Sha512(@h, SizeOf(TSha512Digest), pointer(Seed32), 32);
  h[0]  := h[0] and $F8;
  h[31] := h[31] and $7F;
  h[31] := h[31] or $40;
  SetLength(Result, 32);
  Move(h, pointer(Result)^, 32);
  FillChar(h, SizeOf(h), 0);
end;

function ExtractRaw32Ed25519PrivateDer(const Der: RawByteString): RawByteString;
const
  H: array[0..7] of Byte = ($06, $03, $2B, $65, $70, $04, $22, $04);
  { OID Ed25519 1.3.101.112 = 2b 65 70, затем 04 22 04 20 }
var
  H8: array[0..7] of Byte;
  i: Integer;
begin
  for i := 0 to 7 do H8[i] := H[i];
  Result := FindRaw32AfterHeader(Der, H8);
  { после 04 22 идёт 04 20 — заголовок 8 байт до seed; если Find ищет 06..04 22,
    seed может начаться на байт позже — проверьте на реальном DER }
  if Length(Result) <> 32 then
  begin
    { fallback: last 32 bytes }
    if Length(Der) >= 32 then
      Result := Copy(Der, Length(Der) - 31, 32)
    else
      Result := '';
  end;
end;

function ExtractRaw32Ed25519PublicDer(const Der: RawByteString): RawByteString;
const
  H: array[0..7] of Byte = ($06, $03, $2B, $65, $70, $03, $21, $00);
begin
  Result := FindRaw32AfterHeader(Der, H);
  if Length(Result) <> 32 then
    if Length(Der) >= 32 then
      Result := Copy(Der, Length(Der) - 31, 32)
    else
      Result := '';
end;

{ TOMEMOManager }

constructor TOMEMOManager.Create;
begin
  inherited Create;
  FReady := False;
  FDeviceID := 0;
  FSessions := TOMEMOSessionStore.Create;
end;

destructor TOMEMOManager.Destroy;
begin
  FillZero(FBundle.IdentityPrivDer);
  FillZero(FBundle.IdentityX25519.Priv);
  FillZero(FBundle.SignedPreKey.Key.Priv);

  FreeAndNil(FSessions);
  inherited Destroy;
end;

function TOMEMOManager.B64(const S: RawByteString): RawUtf8;
begin
  Result := BinToBase64(S);
end;

function TOMEMOManager.ExtractRaw32FromX25519PrivateDer(
  const Der: RawByteString): RawByteString;
{ Типичный PKCS#8 X25519 private:
  ... 06 03 2B 65 6E 04 22 04 20 | 32 bytes secret }
const
  H: array[0..9] of Byte = (
    $06, $03, $2B, $65, $6E, $04, $22, $04, $20, $00);
  { последний $00 — заглушка; ищем 06 03 2B 65 6E 04 22 04 20 }
var
  H8: array[0..7] of Byte;
  i: Integer;
begin
  for i := 0 to 7 do
    H8[i] := H[i];
  Result := FindRaw32AfterHeader(Der, H8);
  if Result = '' then
  begin
    { fallback: последние 32 байта DER часто = raw seed }
    if Length(Der) >= OMEMO_KEY_LEN then
      Result := Copy(Der, Length(Der) - OMEMO_KEY_LEN + 1, OMEMO_KEY_LEN);
  end;
end;

function TOMEMOManager.ExtractRaw32FromX25519PublicDer(
  const Der: RawByteString): RawByteString;
{ SPKI X25519 public:
  ... 06 03 2B 65 6E 03 21 00 | 32 bytes public }
const
  H: array[0..7] of Byte = (
    $06, $03, $2B, $65, $6E, $03, $21, $00);
begin
  Result := FindRaw32AfterHeader(Der, H);
  if Result = '' then
  begin
    if Length(Der) >= OMEMO_KEY_LEN then
      Result := Copy(Der, Length(Der) - OMEMO_KEY_LEN + 1, OMEMO_KEY_LEN);
  end;
end;
(*
class function TOMEMOManager.GenX25519(out Key: TOMEMOKeyPair): Boolean;
var
  pkey: PEVP_PKEY;
  privDer, pubDer: RawByteString;
  mgr: TOMEMOManager;
begin
  Result := False;
  Key.Priv := '';
  Key.Pub := '';

  if not OpenSslIsAvailable then
    Exit;
  if not OpenSslSupports(OSSL_EVP_PKEY_X25519) then
    Exit; // старый OpenSSL без X25519

  pkey := OpenSslGenerateKeys(OSSL_EVP_PKEY_X25519, 0);
  if pkey = nil then
    Exit;
  try
    privDer := pkey.PrivateToDer({password=}'');
    pubDer  := pkey.PublicToDer;
  finally
    pkey.Free;
  end;

  mgr := TOMEMOManager.Create;
  try
    Key.Priv := mgr.ExtractRaw32FromX25519PrivateDer(privDer);
    Key.Pub  := mgr.ExtractRaw32FromX25519PublicDer(pubDer);
  finally
    mgr.Free;
  end;

  Result := (Length(Key.Priv) = OMEMO_KEY_LEN) and
            (Length(Key.Pub) = OMEMO_KEY_LEN);
  if not Result then
  begin
    Key.Priv := '';
    Key.Pub := '';
  end;
end;
*)
class function TOMEMOManager.GenX25519(out Key: TOMEMOKeyPair): Boolean;
var
  ctx: PEVP_PKEY_CTX;
  pkey: PEVP_PKEY;
  privDer, pubDer: RawByteString;
  mgr: TOMEMOManager;
begin
  Result := False;
  Key.Priv := '';
  Key.Pub := '';

  if not OpenSslIsAvailable then
    Exit;

  { OpenSslGenerateKeys() в trunk не поддерживает X25519 (else exit).
    Делаем keygen сами — API уже есть в mormot.lib.openssl11. }
  ctx := EVP_PKEY_CTX_new_id(OSSL_EVP_PKEY_X25519, nil);
  if ctx = nil then
    Exit; // OpenSSL без X25519 или неверный NID

  pkey := nil;
  try
    if EVP_PKEY_keygen_init(ctx) <= 0 then
      Exit;
    if EVP_PKEY_keygen(ctx, @pkey) <= 0 then
      Exit;
    if pkey = nil then
      Exit;

    privDer := pkey.PrivateToDer({password=}'');
    pubDer  := pkey.PublicToDer;
  finally
    if pkey <> nil then
      pkey.Free;
    EVP_PKEY_CTX_free(ctx);
  end;

  if (privDer = '') or (pubDer = '') then
    Exit;

  mgr := TOMEMOManager.Create;
  try
    Key.Priv := mgr.ExtractRaw32FromX25519PrivateDer(privDer);
    Key.Pub  := mgr.ExtractRaw32FromX25519PublicDer(pubDer);
  finally
    mgr.Free;
  end;

  Result := (Length(Key.Priv) = OMEMO_KEY_LEN) and
            (Length(Key.Pub) = OMEMO_KEY_LEN);
  if not Result then
  begin
    Key.Priv := '';
    Key.Pub := '';
  end;
end;

class function TOMEMOManager.GenEd25519(out PrivDer, PubDer: RawByteString): Boolean;
begin
  Result := False;
  PrivDer := '';
  PubDer := '';
  if not OpenSslIsAvailable then
    Exit;
  if not OpenSslSupports(EVP_PKEY_ED25519) then
    Exit;
  try
    OpenSslGenerateBinaryKeys(EVP_PKEY_ED25519, 0, PrivDer, PubDer);
    Result := (PrivDer <> '') and (PubDer <> '');
  except
    Result := False;
    PrivDer := '';
    PubDer := '';
  end;
end;

class function TOMEMOManager.SignEd25519(const PrivDer, Msg: RawByteString): RawByteString;
begin
  Result := '';
  if (PrivDer = '') or (Msg = '') then
    Exit;
  { Algorithm 'null' — обязательно для Ed25519 в mORMot/OpenSSL }
  if OpenSslSign('null', pointer(Msg), pointer(PrivDer),
       Length(Msg), Length(PrivDer), Result) = 0 then
    Result := '';
end;

class function TOMEMOManager.VerifyEd25519(const PubDer, Msg, Sig: RawByteString): Boolean;
begin
  Result := False;
  if (PubDer = '') or (Msg = '') or (Sig = '') then
    Exit;
  Result := OpenSslVerify('null', '',
    pointer(Msg), pointer(PubDer), pointer(Sig),
    Length(Msg), Length(PubDer), Length(Sig));
end;

procedure TOMEMOManager.Initialize(pDeviceID: Integer; const pDeviceLabel: String);
var
  i: Integer;
  seed: RawByteString;
  ok: Boolean;
begin
  if FReady then
    Exit;

  if not OpenSslIsAvailable then
    raise Exception.Create('OMEMO: OpenSSL not available (define USE_OPENSSL + DLLs)');
  FDeviceID := pDeviceID;
  if pDeviceID <= 0 then
    begin
      { Device ID: 1 .. 2^31-1 }
      FDeviceID := 1 + Integer(TAesPrng.Main.Random32 and $7FFFFFFF);
      if FDeviceID <= 0 then
        FDeviceID := 1;
    end;
  FDeviceLabel := pDeviceLabel;

  { --- Identity = Ed25519 --- }
  if not GenEd25519(FBundle.IdentityPrivDer, FBundle.IdentityPubDer) then
    raise Exception.Create('OMEMO: Ed25519 identity failed');

  seed := ExtractRaw32Ed25519PrivateDer(FBundle.IdentityPrivDer);
  FBundle.IdentityPubRaw := ExtractRaw32Ed25519PublicDer(FBundle.IdentityPubDer);
  if (Length(seed) <> 32) or (Length(FBundle.IdentityPubRaw) <> 32) then
    raise Exception.Create('OMEMO: bad Ed25519 identity raw keys');

  FBundle.IdentityX25519.Priv := Ed25519SeedToX25519Priv(seed);
  FBundle.IdentityX25519.Pub := Ed25519PubToX25519Pub(FBundle.IdentityPubRaw);
  if Length(FBundle.IdentityX25519.Priv) <> 32 then
    raise Exception.Create('OMEMO: Ed25519→X25519 priv failed');
  { Pub может быть '' до реализации map — для исходящего X3DH priv достаточно }

  FillZero(seed);

 { --- Signed PreKey = X25519, signature = Ed25519(identity, SPK_pub) --- }
  FBundle.SignedPreKey.ID := 1;
  if not GenX25519(FBundle.SignedPreKey.Key) then
    raise Exception.Create('OMEMO: SPK failed');

  FBundle.SignedPreKey.Signature :=
    SignEd25519(FBundle.IdentityPrivDer, FBundle.SignedPreKey.Key.Pub);
  if Length(FBundle.SignedPreKey.Signature) <> OMEMO_SIG_LEN then
    raise Exception.Create('OMEMO: SPK signature failed');

  SetLength(FBundle.PreKeys, OMEMO_PREKEY_COUNT);
  for i := 0 to OMEMO_PREKEY_COUNT - 1 do
  begin
    FBundle.PreKeys[i].ID := i + 1;
    if not GenX25519(FBundle.PreKeys[i].Key) then
      raise Exception.CreateFmt('OMEMO: prekey %d failed', [i + 1]);
  end;

  FReady := True;
end;

function TOMEMOManager.IsReady: Boolean;
begin
  Result := FReady;
end;

function TOMEMOManager.SignDeviceLabel(const LabelUtf8: RawByteString): RawByteString;
begin
  Result := '';
  if LabelUtf8 = '' then
    Exit;
  {
    XEP-0384 Key Exchange: Sig(PK, M) — подпись identity key.
    Публичный IK в bundle всегда в форме Ed25519; подпись — EdDSA/XEdDSA.

    Сейчас в Этапе 1 identity = X25519, отдельный Ed25519 SignKey —
    для полной совместимости нужен XEdDSA(Identity).
    Пока XEdDSA нет: подписываем тем же ключом, что и SPK (SignKeyPrivDer).
    После внедрения XEdDSA — заменить на SignXEdDSA(FBundle.Identity.Priv, LabelUtf8).
  }
  Result := SignEd25519(FBundle.IdentityPrivDer, LabelUtf8);
  if Length(Result) <> OMEMO_SIG_LEN then
    Result := '';
end;

function TOMEMOManager.VerifyDeviceLabel(const LabelUtf8, LabelSigB64: RawUtf8;
  const IdentityPubEd25519Der: RawByteString): Boolean;
var
  sig: RawByteString;
begin
  Result := False;
  if (LabelUtf8 = '') or (LabelSigB64 = '') then
    Exit; // label без labelsig — игнорировать (XEP MUST)
  sig := Base64ToBin(LabelSigB64);
  if Length(sig) <> OMEMO_SIG_LEN then
    Exit;
  Result := VerifyEd25519(IdentityPubEd25519Der, LabelUtf8, sig);
end;

function TOMEMOManager.BuildDeviceListXML: TRnQXML;
var
  pub, item, devices, device: TsdElement;
  labelText: RawUtf8;
  labelBytes: RawByteString;
  labelSig: RawByteString;
begin
  Result := TRnQXML.CreateEx(nil, False, False, True, 'iq');
  with Result.Root do
  begin
    AttributeAdd('type', 'set');
    AttributeAdd('id', Format('omemo-devlist-%d', [FDeviceID]));

    pub := TsdElement(NodeNew('pubsub'));
    pub.AttributeAdd('xmlns', 'http://jabber.org/protocol/pubsub');

    pub := TsdElement(pub.NodeNew('publish'));
    pub.AttributeAdd('node', OMEMO2_DEVICES_NODE);

    item := TsdElement(pub.NodeNew('item'));
    item.AttributeAdd('id', 'current');

    devices := TsdElement(item.NodeNew('devices'));
    devices.AttributeAdd('xmlns', OMEMO2_NS);

    device := TsdElement(devices.NodeNew('device'));
    device.AttributeAdd('id', IntToStr(FDeviceID));
    { XEP-0384: label MAY; если есть — MUST labelsig
      labelsig = Base64( Sig(IdentityKey, UTF-8(label)) ) }
    labelText := FDeviceLabel; // ≤ 53 Unicode code points
    if labelText <> '' then
    begin
      labelBytes := labelText; // RawUtf8 = UTF-8 bytes
      labelSig := SignDeviceLabel(labelBytes);
      if labelSig = '' then
      begin
        { нет подписи — label публиковать нельзя }
      end
      else
      begin
        device.AttributeAdd('label', UTF8ToString(labelText));
        device.AttributeAdd('labelsig', UTF8ToString(B64(labelSig)));
      end;
    end;
  end;
end;

function TOMEMOManager.BuildBundleXML: TRnQXML;
var
  pub, item, bundle, spk, pks, pk: TsdElement;
  i: Integer;
begin
  Result := TRnQXML.CreateEx(nil, False, False, True, 'iq');
  with Result.Root do
  begin
    AttributeAdd('type', 'set');
    AttributeAdd('id', Format('omemo-bundle-%d', [FDeviceID]));

    pub := TsdElement(NodeNew('pubsub'));
    pub.AttributeAdd('xmlns', 'http://jabber.org/protocol/pubsub');

    pub := TsdElement(pub.NodeNew('publish'));
    pub.AttributeAdd('node', OMEMO2_BUNDLES_NODE);

    item := TsdElement(pub.NodeNew('item'));
    item.AttributeAdd('id', IntToStr(FDeviceID));

    bundle := TsdElement(item.NodeNew('bundle'));
    bundle.AttributeAdd('xmlns', OMEMO2_NS);

    spk := TsdElement(bundle.NodeNew('spk'));
    spk.AttributeAdd('id', IntToStr(FBundle.SignedPreKey.ID));
    spk.ValueUnicode := UTF8ToString(B64(FBundle.SignedPreKey.Key.Pub));

    TsdElement(bundle.NodeNew('spks')).ValueUnicode :=
      UTF8ToString(B64(FBundle.SignedPreKey.Signature));

    TsdElement(bundle.NodeNew('ik')).ValueUnicode :=
      UTF8ToString(B64(FBundle.IdentityPubRaw));

    pks := TsdElement(bundle.NodeNew('prekeys'));
    for i := 0 to High(FBundle.PreKeys) do
    begin
      pk := TsdElement(pks.NodeNew('pk'));
      pk.AttributeAdd('id', IntToStr(FBundle.PreKeys[i].ID));
      pk.ValueUnicode := UTF8ToString(B64(FBundle.PreKeys[i].Key.Pub));
    end;
  end;
end;

function TOMEMOManager.EstablishFromPreKey(
  const BareJid: RawUtf8;
  const Msg: TOMEMOEncryptedMessage): TOMEMOSession;
var
  pk: TPreKeySignalMsg;
  dh1, dh2, dh3, dh4, ikm, sk: RawByteString;
  opkPriv: RawByteString;
  i: Integer;
begin
  Result := nil;
  if not Msg.HasOurKey or not Msg.OurKey.IsPreKey then Exit;

  pk := ParsePreKeySignalMessage(Msg.OurKey.Data);
  if not pk.OK then
    raise Exception.Create('OMEMO: bad PreKeySignalMessage');

  { DH2 = X25519(IK_B_priv, IK_A_pub) }
  dh2 := X25519ECDH(FBundle.IdentityX25519.Priv, pk.BaseKey);

  { DH3 = X25519(SPK_B_priv, EK_A_pub)  — baseKey = Alice ephemeral }
  dh3 := X25519ECDH(FBundle.SignedPreKey.Key.Priv, pk.BaseKey);

  { DH1 в Signal для Alice: DH(IK_A, SPK_B).
    Bob: DH(SPK_B_priv, IK_A_pub) — тот же shared secret }
  dh1 := X25519ECDH(FBundle.SignedPreKey.Key.Priv, pk.IdentityKey);

  if (dh1 = '') or (dh2 = '') or (dh3 = '') then
    raise Exception.Create('OMEMO: X3DH ECDH failed');

  dh4 := '';
  if pk.PreKeyId > 0 then
  begin
    opkPriv := '';
    for i := 0 to High(FBundle.PreKeys) do
      if FBundle.PreKeys[i].ID = pk.PreKeyId then
      begin
        opkPriv := FBundle.PreKeys[i].Key.Priv;
        Break;
      end;
    if opkPriv <> '' then
      dh4 := X25519ECDH(opkPriv, pk.BaseKey);
  end;

  if dh4 <> '' then
    ikm := dh1 + dh2 + dh3 + dh4
  else
    ikm := dh1 + dh2 + dh3;

//  sk := OMEMOHKDF(ikm, StringOfChar(#0, 32), 'OMEMO Root Key', 32);
  sk := OMEMOHKDF(ikm, StringOfChar(#0, 32), 'WhisperText', 32);
  { Точные salt/info — по test vectors libsignal/OMEMO }

  Result := TOMEMOSession.Create(BareJid, Msg.SenderDeviceId, FDeviceID);
  Result.RemoteIdentityPub := pk.IdentityKey;
  Result.RootKey := sk;
  Result.DHRemotePub := pk.BaseKey;
  { Дальше из sk init chain keys + расшифровать pk.Message → message key }
  Result.Established := True;
  Result.PendingMsg := pk.Message;

  FSessions.PutSession(Result);
end;

class function TOMEMOManager.BareJidOf(const FullJid: RawUtf8): RawUtf8;
var
  p: Integer;
begin
  p := Pos('/', string(FullJid));
  if p > 0 then
    Result := Copy(FullJid, 1, p - 1)
  else
    Result := FullJid;
  Result := LowerCase(Result);
end;

function ParseOMEMOEncrypted(const MsgEl: TsdElement;
  OurDeviceId: Integer): TOMEMOEncryptedMessage;
var
  enc, header, keys, key: TsdElement;
  i, j, k, n, m: Integer;
  item, gchild: TXmlNode;
  el: TsdElement;
  ns, b64: RawUtf8;
  grp: TOMEMOKeysGroup;
  ke: TOMEMOKeyElement;
  prekeyAttr: string;
  rid: String;
begin
  FillChar(Result, SizeOf(Result), 0);
  Result.Protocol := ompUnknown;
  Result.HasOurKey := False;
  Result.HasPayload := False;

  if MsgEl = nil then Exit;

  Result.FromJid := RawUtf8(MsgEl.AttributeValueByNameWide['from']);
  Result.ToJid   := RawUtf8(MsgEl.AttributeValueByNameWide['to']);
  Result.MsgId   := RawUtf8(MsgEl.AttributeValueByNameWide['id']);
  // from = user@host/resource → при желании разрезать

  enc := nil;
  for i := 0 to MsgEl.ContainerCount - 1 do
  begin
    item := MsgEl.Containers[i];
    if not (item is TsdElement) then
      Continue;
    el := TsdElement(item);
    if el.NameUnicode <> 'encrypted' then
      Continue;
    ns := RawUtf8(el.AttributeValueByNameWide['xmlns']);
    if ns = OMEMO_AXOLOTL_NS then
    begin
      Result.Protocol := ompAxolotl;
      enc := el;
      Break;
    end
    else if ns = OMEMO2_NS then
    begin
      Result.Protocol := ompOmemo2;
      enc := el;
      Break;
    end;
  end;
  if enc = nil then
    Exit;

  header := nil;
  for i := 0 to enc.ContainerCount - 1 do
  begin
    item := enc.Containers[i];
    if not (item is TsdElement) then Continue;
    el := TsdElement(item);
    if el.NameUnicode = 'header' then
      header := el
    else if el.NameUnicode = 'payload' then
      begin
        b64 := RawUtf8(Trim(string(el.ValueUnicode)));
        Result.Payload := Base64ToBin(b64);
        Result.HasPayload := Result.Payload <> '';
      end;
  end;
  if header = nil then Exit;

  Result.SenderDeviceId := StrToIntDef(
    string(header.AttributeValueByNameWide['sid']), 0);

  n := 0;
  for i := 0 to header.ContainerCount - 1 do
  begin
    item := header.Containers[i];
    if not (item is TsdElement) then Continue;
    el := TsdElement(item);

    if el.NameUnicode = 'iv' then
      begin
        b64 := RawUtf8(Trim(string(el.ValueUnicode)));
        Result.IV := Base64ToBin(b64);
        Continue;
      end;
      if el.NameUnicode = 'key' then
      begin
        { axolotl: key прямо в header }
        rid := el.AttributeValueByNameWide['rid'];
        ke.Rid := StrToIntDef(string(rid), 0);
        prekeyAttr := string(el.AttributeValueByNameWide['prekey']);
        if prekeyAttr = '' then
          prekeyAttr := string(el.AttributeValueByNameWide['kex']);
        ke.IsPreKey := SameText(prekeyAttr, 'true');
        b64 := RawUtf8(Trim(string(el.ValueUnicode)));
        ke.Data := Base64ToBin(b64);

        //grp.Jid := RawUtf8(el.AttributeValueByNameWide['jid']);
        grp.Jid := Result.ToJid;

        SetLength(grp.Keys, n + 1);
        grp.Keys[n] := ke;

        SetLength(Result.KeyGroups, n + 1);
        Result.KeyGroups[n] := grp;
        Inc(n);

        if ke.Rid = OurDeviceId then
        begin
          Result.OurKey := ke;
          Result.HasOurKey := True;
        end;
        Continue;
      end;

      if (el.NameUnicode = 'keys') and (Result.Protocol = ompOmemo2) then
       begin
      { omemo:2 — вложенные key }
        grp.Jid := RawUtf8(el.AttributeValueByNameWide['jid']);
        SetLength(grp.Keys, 0);
        m := 0;
        for j := 0 to el.ContainerCount - 1 do
        begin
          gchild := el.Containers[j];
          if not (gchild is TsdElement) then Continue;
          key := TsdElement(gchild);
          if key.NameUnicode <> 'key' then Continue;

          rid := key.AttributeValueByNameWide['rid'];
          ke.Rid := StrToIntDef(string(rid), 0);
          ke.IsPreKey := SameText(string(key.AttributeValueByNameWide['kex']), 'true');
          b64 := RawUtf8(Trim(string(key.ValueUnicode)));
          ke.Data := Base64ToBin(b64);

          SetLength(grp.Keys, m + 1);
          grp.Keys[m] := ke;
          Inc(m);

          if ke.Rid = OurDeviceId then
          begin
            Result.OurKey := ke;
            Result.HasOurKey := True;
          end;
        end;

        SetLength(Result.KeyGroups, n + 1);
        Result.KeyGroups[n] := grp;
        Inc(n);
       end;
  end;
end;

function IsOMEMOMessage(const MsgEl: TsdElement): Boolean;
var
  i: Integer;
  child: TXmlNode;
  el: TsdElement;
  ns: RawUtf8;
begin
  Result := False;
  if MsgEl = nil then Exit;
  for i := 0 to MsgEl.ContainerCount - 1 do
  begin
    child := MsgEl.Containers[i];
    if not (child is TsdElement) then Continue;
    el := TsdElement(child);
    if el.NameUnicode <> 'encrypted' then Continue;
    ns := RawUtf8(el.AttributeValueByNameWide['xmlns']);
    if (ns = OMEMO_AXOLOTL_NS) or (ns = OMEMO2_NS) then
      Exit(True);
  end;
end;

function X25519ECDH(const OurPriv32, TheirPub32: RawByteString): RawByteString;
{ OurPriv32 / TheirPub32 — raw 32 bytes.
  Строим PEVP_PKEY из DER-обёрток и делаем EVP_PKEY_derive. }
var
  ourDer, theirDer: RawByteString;
  ourKey, theirKey: PEVP_PKEY;
  ctx: PEVP_PKEY_CTX;
  len: PtrUInt;
begin
  Result := '';
  if (Length(OurPriv32) <> 32) or (Length(TheirPub32) <> 32) then Exit;

  { Минимальные PKCS#8 / SPKI для X25519 (OpenSSL) }
  ourDer :=
    #$30#$2E#$02#$01#$00#$30#$05#$06#$03#$2B#$65#$6E#$04#$22#$04#$20 + OurPriv32;
  theirDer :=
    #$30#$2A#$30#$05#$06#$03#$2B#$65#$6E#$03#$21#$00 + TheirPub32;

  ourKey := nil;
  theirKey := nil;
  ctx := nil;
  try
    { Загрузка через существующие хелперы mORMot, если есть LoadPrivateKey /
      LoadPublicKey из DER. Иначе — BIO + d2i_PrivateKey / d2i_PUBKEY
      из mormot.lib.openssl11 (они обычно уже есть). }

    // Псевдокод API — подставьте реальные Load* из вашей сборки:
    // ourKey   := LoadPrivateKey(pointer(ourDer), length(ourDer), '');
    // theirKey := LoadPublicKey(pointer(theirDer), length(theirDer), '');

    if (ourKey = nil) or (theirKey = nil) then Exit;

    ctx := EVP_PKEY_CTX_new(ourKey, nil);
    if ctx = nil then Exit;
    if EVP_PKEY_derive_init(ctx) <= 0 then Exit;
    if EVP_PKEY_derive_set_peer(ctx, theirKey) <= 0 then Exit;

    len := 32;
    SetLength(Result, 32);
    if EVP_PKEY_derive(ctx, pointer(Result), @len) <= 0 then
    begin
      Result := '';
      Exit;
    end;
    SetLength(Result, len);
  finally
    if ctx <> nil then EVP_PKEY_CTX_free(ctx);
    if ourKey <> nil then ourKey.Free;
    if theirKey <> nil then theirKey.Free;
  end;
end;

function OMEMOHKDF(const IKM, Salt, Info: RawByteString; L: Integer): RawByteString;
{ HKDF-SHA256 (RFC 5869): Extract + Expand
  IKM  — input key material (конкатенация DH)
  Salt — соль (для X3DH часто 32 нулевых байта)
  Info — контекст (для Signal часто 'WhisperText')
  L    — длина выхода в байтах (для root key = 32) }
var
  prk: TSha256Digest;
  saltKey: RawByteString;
  t, step: TSha256Digest;
  prev, msg, outBuf: RawByteString;
  n, i, need, offset: Integer;
begin
  Result := '';
  if (L <= 0) or (L > 255 * 32) then
    Exit;

  { --- Extract: PRK = HMAC-Hash(salt, IKM) --- }
  if Salt = '' then
  begin
    { RFC 5869: salt длины HashLen, заполненный нулями }
    SetLength(saltKey, SizeOf(TSha256Digest));
    FillChar(pointer(saltKey)^, Length(saltKey), 0);
  end
  else
    saltKey := Salt;

  HmacSha256(saltKey, IKM, prk);

  { --- Expand: OKM = T(1) | T(2) | ... ---
    T(0) = empty
    T(i) = HMAC-Hash(PRK, T(i-1) | info | i)  }
  n := (L + 31) div 32; // ceil(L / HashLen)
  SetLength(outBuf, n * 32);
  offset := 0;
  prev := ''; // T(0) = empty
  FillChar(t, SizeOf(t), 0); // T(0) = empty → первый msg без предыдущего блока

  for i := 1 to n do
    begin
      msg := prev + Info + AnsiChar(Byte(i));
      HmacSha256(@prk, pointer(msg), SizeOf(prk), Length(msg), step);

      Move(step, outBuf[offset + 1], SizeOf(step));
      Inc(offset, SizeOf(step));

      { T(i) → prev для следующей итерации }
      SetLength(prev, SizeOf(step));
      Move(step, pointer(prev)^, SizeOf(step));
    end;

  SetLength(outBuf, L);
  Result := outBuf;

  FillChar(prk, SizeOf(prk), 0);
  FillChar(t, SizeOf(t), 0);
  FillChar(step, SizeOf(step), 0);
  if prev <> '' then
    FillChar(pointer(prev)^, Length(prev), 0);
end;

function ReadVarint(const Buf: RawByteString; var Pos: Integer): UInt64;
var
  shift: Integer;
  b: Byte;
begin
  Result := 0;
  shift := 0;
  while Pos <= Length(Buf) do
  begin
    b := Byte(Buf[Pos]);
    Inc(Pos);
    Result := Result or (UInt64(b and $7F) shl shift);
    if (b and $80) = 0 then Exit;
    Inc(shift, 7);
    if shift > 63 then Break;
  end;
  Result := 0;
end;

class function TOMEMOManager.ParsePreKeySignalMessage(
  const Data: RawByteString): TPreKeySignalMsg;
var
  pos, field, wt, len, startPos: Integer;
  v: UInt64;
  tryPos: array[0..1] of Integer;
  t: Integer;
begin
  FillChar(Result, SizeOf(Result), 0);
  if Length(Data) < 3 then
    Exit;

  { Signal: иногда первый байт = version (0x33 и т.п.) }
  tryPos[0] := 1;
  tryPos[1] := 2;

  for t := 0 to 1 do
  begin
    FillChar(Result, SizeOf(Result), 0);
    pos := tryPos[t];
    while pos <= Length(Data) do
    begin
      startPos := pos;
      v := ReadVarint(Data, pos);
      if pos = startPos then
        Break;
      field := Integer(v shr 3);
      wt := Integer(v and 7);
      case wt of
        0:
          begin
            v := ReadVarint(Data, pos);
            case field of
              1: Result.RegistrationId := Integer(v);
              2: Result.PreKeyId := Integer(v);
              3: Result.SignedPreKeyId := Integer(v);
            end;
          end;
        2:
          begin
            len := Integer(ReadVarint(Data, pos));
            if (len < 0) or (pos + len - 1 > Length(Data)) then
              Break;
            case field of
              4: Result.BaseKey := Copy(Data, pos, len);
              5: Result.IdentityKey := Copy(Data, pos, len);
              6: Result.Message := Copy(Data, pos, len);
            end;
            Inc(pos, len);
          end;
      else
        Break;
      end;
    end;

    Result.OK :=
      (Length(Result.BaseKey) = 32) and
      (Length(Result.IdentityKey) = 32) and
      (Result.Message <> '');
    if Result.OK then
      Exit;
  end;
end;

class function TOMEMOManager.ParseWhisperMessage(
  const Data: RawByteString): TWhisperMessage;
var
  pos, field, wt, len, t, startPos: Integer;
  v: UInt64;
  tryPos: array[0..1] of Integer;
begin
  FillChar(Result, SizeOf(Result), 0);
  if Length(Data) < 3 then Exit;

  tryPos[0] := 1;
  tryPos[1] := 2; // возможен version byte

  for t := 0 to 1 do
  begin
    FillChar(Result, SizeOf(Result), 0);
    pos := tryPos[t];
    while pos <= Length(Data) do
    begin
      startPos := pos;
      v := ReadVarint(Data, pos);
      if pos = startPos then Break;
      field := Integer(v shr 3);
      wt := Integer(v and 7);
      case wt of
        0:
          begin
            v := ReadVarint(Data, pos);
            case field of
              2: Result.N := Integer(v);
              3: Result.Pn := Integer(v);
            end;
          end;
        2:
          begin
            len := Integer(ReadVarint(Data, pos));
            if (len < 0) or (pos + len - 1 > Length(Data)) then Break;
            case field of
              1: Result.RatchetKey := Copy(Data, pos, len);
              4: Result.Ciphertext := Copy(Data, pos, len);
            end;
            Inc(pos, len);
          end;
      else
        Break;
      end;
    end;

    Result.OK :=
      (Length(Result.RatchetKey) = 32) and
      (Result.Ciphertext <> '');
    if Result.OK then Exit;
  end;
end;

function RootRatchet(const RootKey, DHOut: RawByteString;
  out NewRoot, NewChain: RawByteString): Boolean;
{ HKDF(IKM=DHOut, salt=RootKey, info=...) → 64 байта = root||chain }
var
  okm: RawByteString;
begin
  Result := False;
  okm := OMEMOHKDF(DHOut, RootKey, 'WhisperRatchet', 64);
  if Length(okm) <> 64 then Exit;
  NewRoot := Copy(okm, 1, 32);
  NewChain := Copy(okm, 33, 32);
  Result := True;
end;

procedure TOMEMOManager.InitRecvChainAfterX3DH(S: TOMEMOSession;
  const AliceRatchetPub: RawByteString);
var
  dhOut, newRoot, recvChain: RawByteString;
  local: TOMEMOKeyPair;
begin
  { Локальная ratchet-пара для ответа (2e); для приёма первого msg
    Bob считает DH(SPK_priv, AliceEK) уже в X3DH.
    Для первого WhisperMessage ratchetKey часто = Alice base/ephemeral. }

  if not GenX25519(local) then Exit;
  S.DHLocalPriv := local.Priv;
  S.DHLocalPub := local.Pub;

  dhOut := X25519ECDH(S.DHLocalPriv, AliceRatchetPub);
  if dhOut = '' then
  begin
    { fallback: DH(IK, AliceRatchet) — только для отладки }
    dhOut := X25519ECDH(FBundle.IdentityPrivDer, AliceRatchetPub);
  end;
  if not RootRatchet(S.RootKey, dhOut, newRoot, recvChain) then
    Exit;
  S.RootKey := newRoot;
  S.ChainKeyRecv := recvChain;
  S.DHRemotePub := AliceRatchetPub;
  S.RecvN := 0;
end;

procedure ChainDerive(const ChainKey: RawByteString;
  out NextChainKey, MessageKey: RawByteString);
{ message_key = HMAC(chain, 0x01); next_chain = HMAC(chain, 0x02) }
var
  d1, d2: TSha256Digest;
  seed1, seed2: RawByteString;
begin
  seed1 := #$01;
  seed2 := #$02;
  HmacSha256(ChainKey, seed1, d1);
  HmacSha256(ChainKey, seed2, d2);
  SetLength(MessageKey, 32);
  SetLength(NextChainKey, 32);
  Move(d1, pointer(MessageKey)^, 32);
  Move(d2, pointer(NextChainKey)^, 32);
end;

function SignalDecryptMessage(const MessageKey, Ciphertext: RawByteString): RawByteString;
{ Упрощённо: HKDF(MessageKey) → encKey(32) || macKey(32) || iv(16)
  MAC = HMAC-SHA256(macKey, ciphertext)[0..7] в конце
  AES-256-CBC decrypt }
var
  material: RawByteString;
  encKey, macKey, iv, mac, body: RawByteString;
  calcMac: TSha256Digest;
  aes: TAesCbc;
begin
  Result := '';
  if Length(Ciphertext) < 24 then Exit; // mac 8 + min block

  material := OMEMOHKDF(MessageKey, '', 'WhisperMessageKeys', 80);
  if Length(material) < 80 then Exit;
  encKey := Copy(material, 1, 32);
  macKey := Copy(material, 33, 32);
  iv := Copy(material, 65, 16);

  mac := Copy(Ciphertext, Length(Ciphertext) - 7, 8);
  body := Copy(Ciphertext, 1, Length(Ciphertext) - 8);

  HmacSha256(macKey, body, calcMac);
  if not CompareMem(@calcMac, pointer(mac), 8) then
    Exit; // bad MAC

  aes := TAesCbc.Create(pointer(encKey)^, 256);
  try
    aes.IV := PHash128(pointer(iv))^; // или aes.DecryptPKCS7 с IV API вашей версии
    Result := aes.DecryptPKCS7(body, {iv=}True); // уточните API TAesCbc в вашей сборке
  finally
    aes.Free;
  end;
end;

function DerivePayloadKeyFromSession(S: TOMEMOSession;
  const WhisperData: RawByteString;
  out PayloadKey: RawByteString): Boolean;
var
  wm: TWhisperMessage;
  dhOut, newRoot, recvChain, msgKey, nextChain: RawByteString;
  i: Integer;
  plain: RawByteString;
begin
  Result := False;
  PayloadKey := '';
  wm := TOMEMOManager.ParseWhisperMessage(WhisperData);
  if not wm.OK then Exit;

  { 1) DH ratchet, если новый ratchet key }
  if (S.DHRemotePub = '') or (S.DHRemotePub <> wm.RatchetKey) then
  begin
    if Length(S.DHLocalPriv) <> 32 then
    begin
      { после X3DH: локальный ratchet key ещё не создан —
        для первого входящего часто DH(SPK или IK, remote ratchet).
        Практика libsignal: receiving chain из root + DH(our_ratchet_priv, their_ratchet_pub).
        На первом prekey: our side использует ephemeral/SPK-derived state.
        Минимально: DH(Identity.Priv или SignedPreKey.Priv, wm.RatchetKey) — уточняется test vector. }
      Exit; // пока нет локального DH — см. InitRecvChainAfterX3DH ниже
    end;
    dhOut := X25519ECDH(S.DHLocalPriv, wm.RatchetKey);
    if not RootRatchet(S.RootKey, dhOut, newRoot, recvChain) then Exit;
    S.RootKey := newRoot;
    S.ChainKeyRecv := recvChain;
    S.DHRemotePub := wm.RatchetKey;
    S.RecvN := 0;
  end;

  { 2) промотать chain до wm.N }
  recvChain := S.ChainKeyRecv;
  for i := S.RecvN to wm.N do
  begin
    ChainDerive(recvChain, nextChain, msgKey);
    recvChain := nextChain;
    if i = wm.N then
      Break;
  end;
  S.ChainKeyRecv := recvChain;
  S.RecvN := wm.N + 1;

  { 3) снять Signal message encryption → payload AES key }
  plain := SignalDecryptMessage(msgKey, wm.Ciphertext);
  if plain = '' then Exit;

  PayloadKey := plain; // часто 16 или 32 байта
  Result := Length(PayloadKey) in [16, 32];
end;

function AesGcmDecryptPayload(const Key, IV, CipherAndTag: RawByteString): RawByteString;
{ OMEMO axolotl: IV 12 байт, tag 16 байт в конце payload }
var
  aes: TAesGcm;
  tag: TAesBlock;
  ct: RawByteString;
  tagLen: Integer;
begin
  Result := '';
  tagLen := 16;
  if (Length(IV) < 12) or (Length(CipherAndTag) <= tagLen) then Exit;
  if not (Length(Key) in [16, 32]) then Exit;

  ct := Copy(CipherAndTag, 1, Length(CipherAndTag) - tagLen);
  Move(CipherAndTag[Length(CipherAndTag) - tagLen + 1], tag, tagLen);

  aes := TAesGcm.Create(pointer(Key)^, Length(Key) * 8, @IV[1]);
  try
//    Move(pointer(IV)^, aes.IV, 12); // или MacSetNonce / IV API
    { native TAesGcm в mORMot2 предпочтительнее TAesGcmOsl для AEAD }
    SetLength(Result, Length(ct));
    try
      aes.Decrypt(pointer(ct), pointer(Result), Length(ct));
     except
      Result := '';
      Exit;
    end;
    if not aes.AesGcmFinal(tag, tagLen) then
      Result := '';
  finally
    aes.Free;
  end;
end;

function TOMEMOManager.DecryptOMEMO(const Msg: TOMEMOEncryptedMessage): RawUtf8;
var
  bare: RawUtf8;
  sess: TOMEMOSession;
  whisper: RawByteString;
  payloadKey, plain: RawByteString;
begin
  Result := '';
  if not Msg.HasOurKey or not Msg.HasPayload then Exit;

  bare := BareJidOf(Msg.FromJid);
  sess := FSessions.GetSession(bare, Msg.SenderDeviceId);

  if sess = nil then
  begin
    if not Msg.OurKey.IsPreKey then Exit;
    sess := EstablishFromPreKey(bare, Msg);
    if sess = nil then Exit;
  end;

  if Msg.OurKey.IsPreKey and (sess.PendingMsg <> '') then
    whisper := sess.PendingMsg
  else
  begin
    { обычный key без prekey — весь blob = WhisperMessage }
    whisper := Msg.OurKey.Data;
  end;

  if not DerivePayloadKeyFromSession(sess, whisper, payloadKey) then
    Exit;

  plain := AesGcmDecryptPayload(payloadKey, Msg.IV, Msg.Payload);
  if plain = '' then Exit;

  Result := plain; // UTF-8 текст
  sess.PendingMsg := '';
end;

end.
