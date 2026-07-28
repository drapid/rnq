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
  RnQXml, NativeXml;

const
  OMEMO_AXOLOTL_NS    = 'eu.siacs.conversations.axolotl';
  OMEMO2_NS           = 'urn:xmpp:omemo:2';
  OMEMO2_DEVICES_NODE = 'urn:xmpp:omemo:2:devices';
  OMEMO2_BUNDLES_NODE = 'urn:xmpp:omemo:2:bundles';

  OMEMO_KEY_LEN = 32;
  OMEMO_SIG_LEN = 64;
  OMEMO_PREKEY_COUNT = 100;

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
    Identity: TOMEMOKeyPair;       // X25519
    SignedPreKey: TOMEMOSignedPreKey;
    PreKeys: array of TOMEMOPreKey;
    { Отдельная Ed25519-пара для подписи SPK на Этапе 1.
      Полноценный XEdDSA (подпись тем же Curve25519 identity) — Этап 2. }
    SignKeyPrivDer: RawByteString;
    SignKeyPubDer:  RawByteString;
  end;

  TOMEMOManager = class
  private
    FDeviceID: Integer;
    FBundle: TOMEMOBundle;
    FReady: Boolean;

    function B64(const S: RawByteString): RawUtf8;
    function ExtractRaw32FromX25519PrivateDer(const Der: RawByteString): RawByteString;
    function ExtractRaw32FromX25519PublicDer(const Der: RawByteString): RawByteString;
  public
    constructor Create;
    destructor Destroy; override;

    class function GenX25519(out Key: TOMEMOKeyPair): Boolean;
    class function GenEd25519(out PrivDer, PubDer: RawByteString): Boolean;
    class function SignEd25519(const PrivDer, Msg: RawByteString): RawByteString;
    class function VerifyEd25519(const PubDer, Msg, Sig: RawByteString): Boolean;

    procedure Initialize;
    function  IsReady: Boolean;

    property DeviceID: Integer read FDeviceID;
    property Bundle: TOMEMOBundle read FBundle;

    function BuildDeviceListXML: TRnQXML;
    function BuildBundleXML: TRnQXML;
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

  function ParseOMEMOEncrypted(const MsgEl: TsdElement;
    OurDeviceId: Integer): TOMEMOEncryptedMessage;
  function IsOMEMOMessage(const MsgEl: TsdElement): Boolean;

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

{ TOMEMOManager }

constructor TOMEMOManager.Create;
begin
  inherited Create;
  FReady := False;
  FDeviceID := 0;
end;

destructor TOMEMOManager.Destroy;
begin
  if FBundle.Identity.Priv <> '' then
    FillZero(FBundle.Identity.Priv);
  if FBundle.SignedPreKey.Key.Priv <> '' then
    FillZero(FBundle.SignedPreKey.Key.Priv);
  if FBundle.SignKeyPrivDer <> '' then
    FillZero(FBundle.SignKeyPrivDer);
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

procedure TOMEMOManager.Initialize;
var
  i: Integer;
  ok: Boolean;
begin
  if FReady then
    Exit;

  if not OpenSslIsAvailable then
    raise Exception.Create('OMEMO: OpenSSL not available (define USE_OPENSSL + DLLs)');

  { Device ID: 1 .. 2^31-1 }
  FDeviceID := 1 + Integer(TAesPrng.Main.Random32 and $7FFFFFFF);
  if FDeviceID <= 0 then
    FDeviceID := 1;

  ok := GenX25519(FBundle.Identity);
  if not ok then
    raise Exception.Create('OMEMO: X25519 identity key generation failed');

  FBundle.SignedPreKey.ID := 1;
  ok := GenX25519(FBundle.SignedPreKey.Key);
  if not ok then
    raise Exception.Create('OMEMO: X25519 signed prekey generation failed');

  { Ed25519 для подписи SPK (Этап 1). XEdDSA — позже. }
  if not GenEd25519(FBundle.SignKeyPrivDer, FBundle.SignKeyPubDer) then
    raise Exception.Create('OMEMO: Ed25519 sign key generation failed');

  FBundle.SignedPreKey.Signature :=
    SignEd25519(FBundle.SignKeyPrivDer, FBundle.SignedPreKey.Key.Pub);
  if Length(FBundle.SignedPreKey.Signature) <> OMEMO_SIG_LEN then
    raise Exception.Create('OMEMO: signed prekey signature failed');

  SetLength(FBundle.PreKeys, OMEMO_PREKEY_COUNT);
  for i := 0 to OMEMO_PREKEY_COUNT - 1 do
  begin
    FBundle.PreKeys[i].ID := i + 1;
    if not GenX25519(FBundle.PreKeys[i].Key) then
      raise Exception.CreateFmt('OMEMO: prekey %d generation failed', [i + 1]);
  end;

  FReady := True;
end;

function TOMEMOManager.IsReady: Boolean;
begin
  Result := FReady;
end;

function TOMEMOManager.BuildDeviceListXML: TRnQXML;
var
  pub, item, devices, device: TsdElement;
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
    device.AttributeAdd('label', 'R&Q');
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
      UTF8ToString(B64(FBundle.Identity.Pub));

    pks := TsdElement(bundle.NodeNew('prekeys'));
    for i := 0 to High(FBundle.PreKeys) do
    begin
      pk := TsdElement(pks.NodeNew('pk'));
      pk.AttributeAdd('id', IntToStr(FBundle.PreKeys[i].ID));
      pk.ValueUnicode := UTF8ToString(B64(FBundle.PreKeys[i].Key.Pub));
    end;
  end;
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
        ke.Rid := StrToIntDef(string(el.AttributeValueByNameWide['rid']), 0);
        prekeyAttr := string(el.AttributeValueByNameWide['prekey']);
        if prekeyAttr = '' then
          prekeyAttr := string(el.AttributeValueByNameWide['kex']);
        ke.IsPreKey := SameText(prekeyAttr, 'true');
        b64 := RawUtf8(Trim(string(el.ValueUnicode)));
        ke.Data := Base64ToBin(b64);

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

          ke.Rid := StrToIntDef(string(key.AttributeValueByNameWide['rid']), 0);
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

end.