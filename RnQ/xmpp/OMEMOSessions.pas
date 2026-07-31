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
    procedure SaveToStream(Stream: TStream);
    procedure LoadFromStream(Stream: TStream);
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

    function  SaveToFile(const FileName: string): Boolean;
    function  LoadFromFile(const FileName: string;
      LocalDeviceId: Integer): Boolean;
    function  SaveToStream(fs: TStream): Boolean;
    function  LoadFromStream(fs: TStream;
      LocalDeviceId: Integer): Boolean;
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

procedure WriteBlob(Stream: TStream; const S: RawByteString);
var
  n: Integer;
begin
  n := Length(S);
  Stream.WriteBuffer(n, SizeOf(n));
  if n > 0 then
    Stream.WriteBuffer(pointer(S)^, n);
end;

function ReadBlob(Stream: TStream): RawByteString;
var
  n: Integer;
begin
  Stream.ReadBuffer(n, SizeOf(n));
  if (n < 0) or (n > 1024 * 1024) then
    raise Exception.Create('OMEMO session: bad blob');
  SetLength(Result, n);
  if n > 0 then
    Stream.ReadBuffer(pointer(Result)^, n);
end;

procedure WriteStr(Stream: TStream; const S: RawUtf8);
begin
  WriteBlob(Stream, S);
end;

function ReadStr(Stream: TStream): RawUtf8;
begin
  Result := ReadBlob(Stream);
end;

procedure TOMEMOSession.SaveToStream(Stream: TStream);
var
  b: Byte;
begin
  WriteStr(Stream, RemoteBareJid);
  Stream.WriteBuffer(RemoteDeviceId, SizeOf(RemoteDeviceId));
  Stream.WriteBuffer(LocalDeviceId, SizeOf(LocalDeviceId));

  WriteBlob(Stream, RootKey);
  WriteBlob(Stream, ChainKeySend);
  WriteBlob(Stream, ChainKeyRecv);
  Stream.WriteBuffer(SendN, SizeOf(SendN));
  Stream.WriteBuffer(RecvN, SizeOf(RecvN));
  Stream.WriteBuffer(PrevN, SizeOf(PrevN));

  WriteBlob(Stream, DHRemotePub);
  WriteBlob(Stream, DHLocalPriv);
  WriteBlob(Stream, DHLocalPub);
  WriteBlob(Stream, RemoteIdentityPub);
  WriteBlob(Stream, PendingMsg);

  if Established then b := 1 else b := 0;
  Stream.WriteBuffer(b, 1);
end;

procedure TOMEMOSession.LoadFromStream(Stream: TStream);
var
  b: Byte;
begin
  RemoteBareJid := ReadStr(Stream);
  Stream.ReadBuffer(RemoteDeviceId, SizeOf(RemoteDeviceId));
  Stream.ReadBuffer(LocalDeviceId, SizeOf(LocalDeviceId));

  RootKey := ReadBlob(Stream);
  ChainKeySend := ReadBlob(Stream);
  ChainKeyRecv := ReadBlob(Stream);
  Stream.ReadBuffer(SendN, SizeOf(SendN));
  Stream.ReadBuffer(RecvN, SizeOf(RecvN));
  Stream.ReadBuffer(PrevN, SizeOf(PrevN));

  DHRemotePub := ReadBlob(Stream);
  DHLocalPriv := ReadBlob(Stream);
  DHLocalPub := ReadBlob(Stream);
  RemoteIdentityPub := ReadBlob(Stream);
  PendingMsg := ReadBlob(Stream);

  Stream.ReadBuffer(b, 1);
  Established := b <> 0;
end;

const
  OMEMO_SESS_MAGIC = $4F4D5331; // 'OMS1'
  OMEMO_SESS_VER   = 1;

function TOMEMOSessionStore.SaveToFile(const FileName: string): Boolean;
var
  fs: TFileStream;
  magic: Cardinal;
  ver, n: Integer;
  pair: TPair<RawUtf8, TOMEMOSession>;
  list: TList<TOMEMOSession>;
  S: TOMEMOSession;
  i: Integer;
begin
  Result := False;
  ForceDirectories(ExtractFilePath(FileName));
  list := TList<TOMEMOSession>.Create;
  try
    for pair in FMap do
      if (pair.Value <> nil) and pair.Value.Established then
        list.Add(pair.Value);

    fs := TFileStream.Create(FileName, fmCreate);
    try
      magic := OMEMO_SESS_MAGIC;
      ver := OMEMO_SESS_VER;
      fs.WriteBuffer(magic, SizeOf(magic));
      fs.WriteBuffer(ver, SizeOf(ver));
      n := list.Count;
      fs.WriteBuffer(n, SizeOf(n));
      for i := 0 to n - 1 do
        list[i].SaveToStream(fs);
      Result := True;
    finally
      fs.Free;
    end;
  finally
    list.Free;
  end;
end;

function TOMEMOSessionStore.LoadFromFile(const FileName: string;
  LocalDeviceId: Integer): Boolean;
var
  fs: TFileStream;
  magic: Cardinal;
  ver, n, i: Integer;
  S: TOMEMOSession;
begin
  Result := False;
  if not FileExists(FileName) then Exit;

  Clear;
  fs := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
  try
    fs.ReadBuffer(magic, SizeOf(magic));
    if magic <> OMEMO_SESS_MAGIC then
      raise Exception.Create('OMEMO sessions: bad magic');
    fs.ReadBuffer(ver, SizeOf(ver));
    if ver <> OMEMO_SESS_VER then
      raise Exception.Create('OMEMO sessions: bad version');

    fs.ReadBuffer(n, SizeOf(n));
    if (n < 0) or (n > 10000) then
      raise Exception.Create('OMEMO sessions: bad count');

    for i := 0 to n - 1 do
    begin
      S := TOMEMOSession.Create('', 0, LocalDeviceId);
      try
        S.LoadFromStream(fs);
        if (LocalDeviceId > 0) and (S.LocalDeviceId <> LocalDeviceId) then
        begin
          S.Free;
          Continue; // сессия от другого нашего device id
        end;
        if (S.RemoteBareJid = '') or (S.RemoteDeviceId <= 0) then
        begin
          S.Free;
          Continue;
        end;
        PutSession(S); // store owns S
      except
        S.Free;
        raise;
      end;
    end;
    Result := True;
  finally
    fs.Free;
  end;
end;

function TOMEMOSessionStore.SaveToStream(fs: TStream): Boolean;
var
  magic: Cardinal;
  ver, n: Integer;
  pair: TPair<RawUtf8, TOMEMOSession>;
  list: TList<TOMEMOSession>;
  S: TOMEMOSession;
  i: Integer;
begin
  list := TList<TOMEMOSession>.Create;
  try
    for pair in FMap do
      if (pair.Value <> nil) and pair.Value.Established then
        list.Add(pair.Value);

    magic := OMEMO_SESS_MAGIC;
    ver := OMEMO_SESS_VER;
    fs.WriteBuffer(magic, SizeOf(magic));
    fs.WriteBuffer(ver, SizeOf(ver));
    n := list.Count;
    fs.WriteBuffer(n, SizeOf(n));
    for i := 0 to n - 1 do
      list[i].SaveToStream(fs);
    Result := True;
  finally
    list.Free;
  end;
end;

function TOMEMOSessionStore.LoadFromStream(fs: TStream;
  LocalDeviceId: Integer): Boolean;
var
  magic: Cardinal;
  ver, n, i: Integer;
  S: TOMEMOSession;
begin
  Result := False;
  Clear;
  if fs.Size < 10 then
    Exit;
  fs.Position := 0;
  fs.ReadBuffer(magic, SizeOf(magic));
  if magic <> OMEMO_SESS_MAGIC then
    raise Exception.Create('OMEMO sessions: bad magic');
  fs.ReadBuffer(ver, SizeOf(ver));
  if ver <> OMEMO_SESS_VER then
    raise Exception.Create('OMEMO sessions: bad version');

  fs.ReadBuffer(n, SizeOf(n));
  if (n < 0) or (n > 10000) then
    raise Exception.Create('OMEMO sessions: bad count');

  for i := 0 to n - 1 do
  begin
    S := TOMEMOSession.Create('', 0, LocalDeviceId);
    try
      S.LoadFromStream(fs);
      if (LocalDeviceId > 0) and (S.LocalDeviceId <> LocalDeviceId) then
      begin
        S.Free;
        Continue; // сессия от другого нашего device id
      end;
      if (S.RemoteBareJid = '') or (S.RemoteDeviceId <= 0) then
      begin
        S.Free;
        Continue;
      end;
      PutSession(S); // store owns S
    except
      S.Free;
      raise;
    end;
  end;
  Result := True;
end;

end.