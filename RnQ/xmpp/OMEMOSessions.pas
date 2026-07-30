unit OMEMOSessions;

interface

uses
  SysUtils, Classes, Generics.Collections,
  mormot.core.base, mormot.core.buffers;

type

  { Минимальное состояние сессии Signal/OMEMO (упростим до нужного для decrypt) }
  TOMEMOSession = class
  public
    RemoteBareJid: RawUtf8;
    RemoteDeviceId: Integer;   // sid отправителя
    LocalDeviceId: Integer;

    { X3DH / root }
    RootKey: RawByteString;        // 32
    ChainKeySend: RawByteString;   // 32
    ChainKeyRecv: RawByteString;   // 32
    SendN: Integer;
    RecvN: Integer;
    PrevN: Integer;

    { Ratchet DH }
    DHRemotePub: RawByteString;    // 32 X25519
    DHLocalPriv: RawByteString;    // 32
    DHLocalPub: RawByteString;     // 32

    RemoteIdentityPub: RawByteString; // 32
    { сырой вложенный SignalMessage из PreKey — для 2d }
    PendingMsg: RawByteString;
    Established: Boolean;

    constructor Create(const AJid: RawUtf8; ARemoteDev, ALocalDev: Integer);
  end;

  TOMEMOSessionStore = class
  private
    FMap: TObjectDictionary<RawUtf8, TOMEMOSession>;
    function MakeKey(const BareJid: RawUtf8; DeviceId: Integer): RawUtf8;
  public
    constructor Create;
    destructor Destroy; override;

    function GetSession(const BareJid: RawUtf8; DeviceId: Integer): TOMEMOSession;
    procedure PutSession(S: TOMEMOSession); // store takes ownership if not already
    function HasSession(const BareJid: RawUtf8; DeviceId: Integer): Boolean;
    procedure Remove(const BareJid: RawUtf8; DeviceId: Integer);
    procedure Clear;
  end;

implementation

constructor TOMEMOSession.Create(const AJid: RawUtf8; ARemoteDev, ALocalDev: Integer);
begin
  inherited Create;
  RemoteBareJid := AJid;
  RemoteDeviceId := ARemoteDev;
  LocalDeviceId := ALocalDev;
  Established := False;
  SendN := 0;
  RecvN := 0;
  PrevN := 0;
end;

{ TOMEMOSessionStore }
constructor TOMEMOSessionStore.Create;
begin
  inherited Create;
  FMap := TObjectDictionary<RawUtf8, TOMEMOSession>.Create([doOwnsValues]);
end;

destructor TOMEMOSessionStore.Destroy;
begin
  FMap.Free;
  inherited;
end;

function TOMEMOSessionStore.MakeKey(const BareJid: RawUtf8; DeviceId: Integer): RawUtf8;
begin
//  Result := LowerCase(BareJid) + '/' + IntToHex(DeviceId, 1);
  Result := LowerCase(string(BareJid)) + '/' + IntToStr(DeviceId);
end;

function TOMEMOSessionStore.GetSession(const BareJid: RawUtf8; DeviceId: Integer): TOMEMOSession;
begin
  if not FMap.TryGetValue(MakeKey(BareJid, DeviceId), Result) then
    Result := nil;
end;

procedure TOMEMOSessionStore.PutSession(S: TOMEMOSession);
var
  k: RawUtf8;
begin
  k := MakeKey(S.RemoteBareJid, S.RemoteDeviceId);
  FMap.AddOrSetValue(k, S);
end;

function TOMEMOSessionStore.HasSession(const BareJid: RawUtf8; DeviceId: Integer): Boolean;
begin
  Result := FMap.ContainsKey(MakeKey(BareJid, DeviceId));
end;

procedure TOMEMOSessionStore.Remove(const BareJid: RawUtf8; DeviceId: Integer);
begin
  FMap.Remove(MakeKey(BareJid, DeviceId));
end;

procedure TOMEMOSessionStore.Clear;
begin
  FMap.Clear;
end;

end.