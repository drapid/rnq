unit RnQNet.Uploads;
{$I forRnQConfig.inc}
{$I NoRTTI.inc}

interface

uses
  Classes, JSON, OverbyteIcsWSocket, OverbyteIcsHttpProt, OverbyteIcsNtlmMsgs, OverbyteIcsWSockBuf,
{$IFDEF UseNTLMAuthentication}
  RnQHttpAuth,
{$ENDIF}
  RDGlobal
  ;

type
  TarchiveStream = class(Tstream)
  protected
    pos, cachedTotal: int64;
    cur: integer;
    aHTTPHeader: RawByteString;
    procedure invalidate();
    procedure calculate(); virtual; abstract;
    function getTotal(): int64;
  public
    flist: array of record
      src,          // full path of the file on the disk
      dst: string;  // full path of the file in the archive
      firstByte,    // offset of the file inside the archive
      mtime,
      size: int64;
      data: Tobject;  // extra data
     end;
    onDestroy: TNotifyEvent;

    constructor create;
    destructor Destroy; override;
    function   addFile(const src: string; dst: string=''; data: Tobject=NIL): boolean; virtual;
    function   count(): integer;
    procedure  reset(); virtual;
    property   totalSize: int64 read getTotal;
    property   current: integer read cur;
  end; // TarchiveStream

  TtarStreamWhere = (TW_HEADER, TW_FILE, TW_PAD);

  TtarStream = class(TarchiveStream)
   protected
    fs: TFileStream;
    block: TStringStream;
    lastSeekFake: int64;
    where: TtarStreamWhere;
    function  fsInit(): boolean;
    procedure headerInit(); // fill block with header
    procedure padInit(full: boolean=FALSE); // fill block with pad
    function  headerLengthForFilename(const fn: string):integer;
    procedure calculate(); override;
   public
    fileNamesOEM: boolean;
    constructor create;
    destructor Destroy; override;
    function Read(var Buffer; Count: Longint): Longint; override;
    function Write(const Buffer; Count: Longint): Longint; override;
    function Seek(const Offset: Int64; Origin: TSeekOrigin=soBeginning): Int64; override;

    procedure reset(); override;
  end; // TtarStream

resourcestring
  FileTooBig = 'File is too big, max size %s MB';
  AuthFailed = 'File hosting authentication failed';
  UploadError = 'Failed to upload file! Server response';
  FileNotExists = 'File doesn''t exist';

{$IFDEF RNQ}
//  function UploadFileRGhost(const Filename: String; pOnSendData: TDocDataEvent): String;
  function UploadFileRGhost(FileStream: TStream; FileName: String; pOnSendData: TDocDataEvent): String;
  function UploadFileRnQ(FileStream: TStream; const Filename: String; pOnSendData: TDocDataEvent): String;
  function UploadTarFileRnQ(const Filenames: String; pOnSendData: TDocDataEvent): String;
{$ENDIF RNQ}

  function CreateZip(str: TStringList): TMemoryStream;


type
  PMemoryStream = ^TMemoryStream;

  TCallbacks = class
//  private
//    FOnBeforeHeaderSend: TBeforeHeaderSendEvent;
//    FOnSendData: TDocDataEvent;
  public
    class procedure OnBeforeHeaderSend(Sender: TObject; const Method: String; Headers: TStrings);
//    property OnBeforeHeaderSend: TBeforeHeaderSendEvent read FOnBeforeHeaderSend write FOnBeforeHeaderSend;
//    property OnSendData: TDocDataEvent read FOnSendData write FOnSendData;
  end;


var
  uploadSize, uploadedSize: Integer;
  isUploading: Boolean;

implementation

uses
  Windows, SysUtils, StrUtils, DateUtils, math,
  Base64, RDFileUtil, RDUtils, RnQBinUtils,
{$IFDEF UNICODE}
  AnsiStrings,
{$ENDIF UNICODE}
  // OverbyteIcsLogger,
{$IFDEF RNQ}
  RnQPrefsInt,
  RnQGlobal,
  RQUtil,
  RnQNet,
{$ENDIF RNQ}
  RnQZip,
  RnQDialogs
;

class procedure TCallbacks.OnBeforeHeaderSend(Sender: TObject; const Method: String; Headers: TStrings);
begin
  Headers.Add('Pragma: no-cache');
  Headers.Add('Cache-Control: no-cache');
end;

function FileSize(const aFilename: String): Int64;
var
  info: TWin32FileAttributeData;
begin
  result := -1;

  if not GetFileAttributesEx(PWideChar(aFileName), GetFileExInfoStandard, @info) then
    Exit;

  result := Int64(info.nFileSizeLow) or Int64(info.nFileSizeHigh shl 32);
end;

function InputText(Boundry, Name, Value: RawByteString): RawByteString;
begin
  result := format(AnsiString(RawByteString('%s') + CRLF + 'Content-Disposition: form-data; name="%s"' + CRLF + CRLF + '%s' + CRLF),
            [AnsiString('--') + boundry, name, value]);
end;

{$IFDEF RNQ}
function UploadFileRGhost(FileStream: TStream; FileName: String; pOnSendData: TDocDataEvent): String;
var
  AvStream, TokenStream: TMemoryStream;
  httpCli: TSslHttpCli;
  Host: String;
  Token, Buf, Boundry, TokenStr, FilePage: RawByteString;
  JSONObject: TJSONObject;
  i, p, ULimit: Integer;
  Cookie, DownloadLink: String;
begin
  Result := '';
  Boundry := 'RghostUploadBoundaryabcdef0123456789';

  httpCli := TSslHttpCli.Create(nil);
  SetupProxy(httpCli);

  try
    TokenStream := TMemoryStream.Create;
    httpCli.RcvdStream := TokenStream;
    httpCli.BandwidthLimit := 0;
    httpCli.RequestVer := '1.1';
    httpCli.Connection := 'Keep-Alive';
    httpCli.Reference := 'http://rghost.net/';
    httpCli.Agent := 'rgup 1.3';
    httpCli.URL := 'http://rghost.net/multiple/upload_host';
    httpCli.Cookie := '';
    httpCli.Get;

    for i := 0 to httpCli.RcvdHeader.Count - 1 do
    if StartsText('Set-Cookie:', httpCli.RcvdHeader[i]) then
      Cookie := StrUtils.ReplaceText(Copy(httpCli.RcvdHeader[i], 1, Pos(';', httpCli.RcvdHeader[i]) - 1), 'Set-Cookie: ', '');

    TokenStream.Seek(0, 0);
    SetLength(TokenStr, TokenStream.Size);
    TokenStream.ReadBuffer(TokenStr[1], TokenStream.Size);
    TokenStream.Clear;
    FreeAndNil(TokenStream);
   except
  end;

  JSONObject := TJSONObject.ParseJSONValue(TokenStr) as TJSONObject;
  if Assigned(JSONObject) then
    begin
      Host := JSONObject.GetValue('upload_host').Value;
      Token := AnsiString(JSONObject.GetValue('authenticity_token').Value);
      ULimit := 100;
      TryStrToInt(JSONObject.GetValue('upload_limit').Value, ULimit);

      if FileSize(Filename) > ULimit * 1024 * 1024 then
      begin
 {$IFDEF RNQ}
        msgDlg(Format(FileTooBig, [IntToStr(ULimit)]), False, mtError);
 {$ELSE ~RNQ}
        MessageDlg(Format(FileTooBig, [IntToStr(ULimit)]), mtError, [mbOK], 0);
 {$ENDIF ~RNQ}
        httpCli.Free;
        Exit;
      end;
    end
   else
    begin
 {$IFDEF RNQ}
      msgDlg(AuthFailed, False, mtError);
 {$ELSE ~RNQ}
        MessageDlg(AuthFailed, mtError, [mbOK], 0);
 {$ENDIF ~RNQ}
      httpCli.Free;
      Exit;
    end;

  try
    httpCli.URL := 'http://' + Host + '/files';
    httpCli.ContentTypePost := 'multipart/form-data; boundary=' + String(Boundry);
    httpCli.SendStream := TMemoryStream.Create;

    Buf := InputText(Boundry, 'authenticity_token', Token)
         + '--' + Boundry + CRLF + 'Content-Disposition: form-data; name="file"; filename="' + UTF8Encode(ExtractFileName(Filename)) + '"' + CRLF +
           'Content-Transfer-Encoding: binary' + CRLF + CRLF;
    httpCli.SendStream.Write(Buf[1], Length(Buf));

    if Assigned(FileStream) then
      httpCli.SendStream.CopyFrom(FileStream, 0)
     else
      begin
        FileStream := TMemoryStream.Create;
        TMemoryStream(FileStream).LoadFromFile(Filename);
        FileStream.Seek(0, soFromBeginning);
        httpCli.SendStream.CopyFrom(FileStream, 0);
        FreeAndNil(FileStream);
      end;

    Buf := CRLF + '--' + Boundry + '--' + CRLF;
    httpCli.SendStream.Write(Buf[1], Length(Buf));
    httpCli.SendStream.Seek(0, soFromBeginning);

    httpCli.OnBeforeHeaderSend := TCallbacks.OnBeforeHeaderSend;
    httpCli.OnSendData := pOnSendData;

    AvStream := TMemoryStream.Create;
    httpCli.RcvdStream := AvStream;
    httpCli.Cookie := Cookie;

    try
      uploadSize := httpCli.SendStream.Size;
      uploadedSize := 0;
      isUploading := True;
      httpCli.FollowRelocation := False;
      httpCli.Post;
      isUploading := False;

      for i := 0 to httpCli.RcvdHeader.Count - 1 do
        if StartsText('Location:', httpCli.RcvdHeader[i]) then
          Result := Trim(StrUtils.ReplaceText(httpCli.RcvdHeader[i], 'Location:', ''));

      if not (Result = '') then
      begin
        AvStream.Clear;
        httpCli.URL := Result;
        httpCli.FollowRelocation := True;
        httpCli.Get;
        AvStream.Seek(0, 0);
        SetLength(FilePage, AvStream.Size);
        AvStream.ReadBuffer(FilePage[1], AvStream.Size);

        p := Pos(RawByteString('window.rgh.fileurl = '''), FilePage) + 22;
        DownloadLink := UnUTF(Copy(FilePage, p, Pos(RawByteString(''''), FilePage, p) - p));
        OutputDebugString(PChar(DownloadLink));

        p := Pos(RawByteString('name="direct_link"'), FilePage) + 83;
        Result := UnUTF(Copy(FilePage, p, Pos(RawByteString('"'), FilePage, p) - p));
        OutputDebugString(PChar(Result));

        if not StartsText('http://', Result) then
          Result := httpCli.Location;
      end;
    except
 {$IFDEF RNQ}
      msgDlg(UploadError + ': ' + httpCli.LastResponse, False, mtError);
 {$ELSE ~RNQ}
      MessageDlg(UploadError + ': ' + httpCli.LastResponse, mtError, [mbOK], 0);
 {$ENDIF RNQ}
    end;
  finally
    isUploading := False;
    httpCli.Free;
    if Assigned(AvStream) then
      FreeAndNil(AvStream);
    if Assigned(FileStream) then
      FreeAndNil(FileStream);
  end;
end;

function UploadFileRnQ(FileStream: TStream; const Filename: String; pOnSendData: TDocDataEvent): String;
var
  AvStream: TMemoryStream;
  httpCli: TSslHttpCli;
  Buf, Boundry, UploadedName: RawByteString;
begin
  Result := '';
//  Boundry := '---------------MikanoshiServerUpload';
  Boundry := '---------------RnQPortalServerUpload';

  httpCli := TSslHttpCli.Create(nil);
  SetupProxy(httpCli);
  httpCli.BandwidthLimit := 0;
  httpCli.RequestVer := '1.1';
  httpCli.Connection := 'Keep-Alive';
  httpCli.Agent := 'R&Q 1124 Custom Build';

  if FileSize(Filename) > 100 * 1024 * 1024 then
  begin
 {$IFDEF RNQ}
    msgDlg(Format(FileTooBig, [IntToStr(100)]), true, mtError);
 {$ELSE ~RNQ}
    MessageDlg(Format(FileTooBig, [IntToStr(100)]), mtError, [mbOK], 0);
 {$ENDIF RNQ}
    httpCli.Free;
    Exit;
  end;

  try
    httpCli.URL := 'http://RnQ.ru/file_upload.php';
    httpCli.ContentTypePost := 'multipart/form-data; boundary=' + String(Boundry);

    httpCli.SendStream := TMemoryStream.Create;

    Buf := InputText(Boundry, 'fname', StrToUTF8(ExtractFileName(Filename)))
         + '--' + Boundry + CRLF + 'Content-Disposition: form-data; name="file"; filename="' + UTF8Encode(ExtractFileName(Filename)) + '"' + CRLF +
           'Content-Transfer-Encoding: binary' + CRLF + CRLF;
    httpCli.SendStream.Write(Buf[1], Length(Buf));


    if Assigned(FileStream) then
      httpCli.SendStream.CopyFrom(FileStream, 0)
     else
      begin
        FileStream := TMemoryStream.Create;
        TMemoryStream(FileStream).LoadFromFile(Filename);
        FileStream.Seek(0, soFromBeginning);
        httpCli.SendStream.CopyFrom(FileStream, 0);
        FreeAndNil(FileStream);
      end;

    Buf := CRLF + '--' + Boundry + '--' + CRLF;
    httpCli.SendStream.Write(Buf[1], Length(Buf));

    httpCli.SendStream.Seek(0, soFromBeginning);

    httpCli.OnBeforeHeaderSend := TCallbacks.OnBeforeHeaderSend;
    httpCli.OnSendData := pOnSendData;

    AvStream := TMemoryStream.Create;
    httpCli.RcvdStream := AvStream;

    try
      uploadSize := httpCli.SendStream.Size;
      uploadedSize := 0;
      isUploading := True;
      httpCli.FollowRelocation := False;
      httpCli.Post;
      isUploading := False;

      AvStream.Seek(0, 0);
      SetLength(UploadedName, AvStream.Size);
      AvStream.ReadBuffer(UploadedName[1], AvStream.Size);

      Result := UnUTF(UploadedName);
    except
 {$IFDEF RNQ}
      msgDlg(UploadError + ': ' + #13#10 + httpCli.RcvdHeader.Text, False, mtError);
 {$ELSE ~RNQ}
      MessageDlg(UploadError + ': ' + #13#10 + httpCli.RcvdHeader.Text, mtError, [mbOK], 0);
 {$ENDIF RNQ}
    end;
  finally
    isUploading := False;
    httpCli.Free;
    if Assigned(AvStream) then
      FreeAndNil(AvStream);
  end;
end;

function UploadTarFileRnQ(const Filenames: String; pOnSendData: TDocDataEvent): String;
var
  AvStream: TMemoryStream;
  str: TStrings;
  tar: TtarStream;
  fsize: Int64;
  httpCli: TSslHttpCli;
  Buf, Boundry, UploadedName: RawByteString;
  I: Integer;
  l: Integer;
begin
  Result := '';
  Boundry := '---------------RnQPortalServerUpload';

  tar := TtarStream.create;

 {$WARN CONSTRUCTING_ABSTRACT OFF}
  str := TStringList.Create;

  str.StrictDelimiter := True;
  str.Delimiter := ';';
  str.DelimitedText := Filenames;
  try
    for I := 1 to str.Count do
      tar.addFile(str[i-1]);
   finally
    str.Free;
  end;
 {$WARN CONSTRUCTING_ABSTRACT ON}

  fsize := tar.getTotal;

  if fsize = 0 then
  begin
 {$IFDEF RNQ}
    msgDlg(Format(FileNotExists, [Filenames]), False, mtError);
 {$ELSE ~RNQ}
    MessageDlg(Format(FileNotExists, [Filenames]), mtError, [mbOK], 0);
 {$ENDIF RNQ}
    tar.Free;
    Exit;
  end;


  if fsize > 100 * 1024 * 1024 then
  begin
 {$IFDEF RNQ}
    msgDlg(Format(FileTooBig, [IntToStr(100)]), False, mtError);
 {$ELSE ~RNQ}
    MessageDlg(Format(FileTooBig, [IntToStr(100)]), mtError, [mbOK], 0);
 {$ENDIF RNQ}
    tar.Free;
    Exit;
  end;

  httpCli := TSslHttpCli.Create(nil);
  SetupProxy(httpCli);
  httpCli.BandwidthLimit := 0;
  httpCli.RequestVer := '1.1';
  httpCli.Connection := 'Keep-Alive';
  httpCli.Agent := 'R&Q';



  try
    httpCli.URL := 'http://RnQ.ru/file_upload.php';
    httpCli.ContentTypePost := 'multipart/form-data; boundary=' + String(Boundry);

    Buf := InputText(Boundry, 'fname', 'archive.tar')
         + '--' + Boundry + CRLF + 'Content-Disposition: form-data; name="file"; filename="' + ('archive.tar') + '"' + CRLF
         + 'Content-Transfer-Encoding: binary' + CRLF + CRLF;

    httpCli.SendStream := TMemoryStream.Create;

    httpCli.SendStream.Write(Buf[1], Length(Buf));

//    httpCli.SendStream.CopyFrom(tar, tar.Size);
    tar.Seek(0, soFromBeginning);
    l := httpCli.SendStream.Size;
    httpCli.SendStream.Size := l + tar.Size;
    if tar.Size <> 0 then
      tar.ReadBuffer((PByte(TMemoryStream(httpCli.SendStream).Memory)+l)^, tar.Size);

    FreeAndNil(tar);



    Buf := CRLF + '--' + Boundry + '--' + CRLF;

    httpCli.SendStream.Seek(0, soFromEnd);

    httpCli.SendStream.Write(Buf[1], Length(Buf));

    httpCli.SendStream.Seek(0, soFromBeginning);

    httpCli.OnBeforeHeaderSend := TCallBacks.OnBeforeHeaderSend;
    httpCli.OnSendData := pOnSendData;

    AvStream := TMemoryStream.Create;
    httpCli.RcvdStream := AvStream;

    try
      uploadSize := httpCli.SendStream.Size;
      uploadedSize := 0;
      isUploading := True;
      httpCli.FollowRelocation := False;
      httpCli.Post;
      isUploading := False;

      AvStream.Seek(0, 0);
      SetLength(UploadedName, AvStream.Size);
      AvStream.ReadBuffer(UploadedName[1], AvStream.Size);

      Result := UnUTF(UploadedName);
    except
 {$IFDEF RNQ}
      msgDlg(UploadError + ': ' + #13#10 + httpCli.RcvdHeader.Text, False, mtError);
 {$ELSE ~RNQ}
      MessageDlg(UploadError + ': ' + #13#10 + httpCli.RcvdHeader.Text, mtError, [mbOK], 0);
 {$ENDIF RNQ}
    end;
  finally
    isUploading := False;
    httpCli.Free;
    if Assigned(AvStream) then
      FreeAndNil(AvStream);
  end;
end;
{$ENDIF RNQ}

function CreateZip(str: TStringList): TMemoryStream;
var
  Zip: TZipFile;
  i: Integer;
  fs: TFileStream;
  pData: RawByteString;
begin
  Result := TMemoryStream.Create;
  Zip := TZipFile.Create;
  try
    for i := 0 to str.Count - 1 do
    if FileExists(str.Strings[i]) then
    begin
      fs := TFileStream.Create(str.Strings[i], fmOpenRead);
      SetLength(pData, fs.Size);
      fs.ReadBuffer(pData[1], fs.Size);
      FreeAndNil(fs);
      Zip.AddFile(ExtractFileName(str.Strings[i]), 0, '', pData);
    end;
    Zip.SaveToStream(Result);
  except end;
  FreeAndNil(Zip);
end;


//////////// TarchiveStream

function TarchiveStream.getTotal():int64;
begin
  if cachedTotal < 0 then
    calculate();
  result := cachedTotal;
end; // getTotal

function TarchiveStream.addFile(const src: string; dst: string=''; data: Tobject=NIL): boolean;

  function getMtime(fh: Thandle): int64;
  var
    ctime, atime, mtime: Tfiletime;
    st: TSystemTime;
  begin
    getFileTime(fh, @ctime, @atime, @mtime);
    fileTimeToSystemTime(mtime, st);
    result:=dateTimeToUnix(SystemTimeToDateTime(st));
  end; // getMtime

var
  i, fh: integer;
begin
  result := FALSE;
  fh := fileopen(src, fmOpenRead+fmShareDenyNone);
  if fh = -1 then
    exit;
  result:=TRUE;
  if dst = '' then
    dst := extractFileName(src);
  i:=length(flist);
  setLength(flist, i+1);
  flist[i].src:=src;
  flist[i].dst:=dst;
  flist[i].data:=data;
  flist[i].size:=sizeOfFile(src);
  flist[i].mtime:=getMtime(fh);
  flist[i].firstByte:=-1;
  fileClose(fh);
  invalidate();
end; // addFile

procedure TarchiveStream.invalidate();
begin
  cachedTotal:=-1
end;

constructor TarchiveStream.create;
begin
  inherited;
  reset();
end; // create

destructor TarchiveStream.destroy;
begin
  if assigned(onDestroy) then
    onDestroy(self);
  inherited;
end; // destroy

procedure TarchiveStream.reset();
begin
  flist:=NIL;
  cur:=0;
  pos:=0;
  invalidate();
end; // reset

function TarchiveStream.count():integer;
begin result:=length(flist) end;

//////////// TtarStream

constructor TtarStream.create;
begin
  block := TStringStream.create('');
  lastSeekFake := -1;
  where := TW_HEADER;
  fileNamesOEM := FALSE;
  inherited;
end; // create

destructor TtarStream.destroy;
begin
  freeAndNIL(fs);
  inherited;
end; // destroy

procedure TtarStream.reset();
begin
inherited;
block.size:=0;
end; // reset

function TtarStream.fsInit(): boolean;
begin
  if assigned(fs) and (fs.FileName = flist[cur].src) then
    begin
      result := TRUE;
      exit;
    end;
  result:=FALSE;
  try
    freeAndNIL(fs);
    fs := TfileStream.Create(flist[cur].src, fmOpenRead+fmShareDenyWrite);
    result := TRUE;
   except
    fs := NIL;
  end;
end; // fsInit

procedure TtarStream.headerInit();

  function num(i: int64; const fieldLength: integer): RawByteString;
  const
    CHARS: array [0..7] of AnsiChar = '01234567';
  var
    d: integer;
  begin
    result := dupeString(RawByteString(' '), fieldLength);
    d := fieldLength-1;
    while d > 0 do
      begin
        result[d] := CHARS[i and 7];
        dec(d);
        i := i shr 3;
        if i = 0 then
          break;
      end;
  end; // num

  function str(s: RawByteString; fieldLength: integer; fill: RawByteString=#0): RawByteString;
  begin
    setLength(s, min(length(s), fieldLength-1));
    result := s+dupeString(fill, fieldLength-length(s));
  end; // str

  function sum(const s: RawBytestring): integer;
  var
    i: integer;
  begin
    result := 0;
    for i:=1 to length(s) do
      inc(result, ord(s[i]));
  end; // sum

  procedure applyChecksum(var s: RawByteString);
  var
    chk: RawByteString;
  begin
    chk := num(sum(s), 7)+' ';
    chk[7] := #0;
    move(chk[1], s[100+24+12+12+1], length(chk));
  end; // applyChecksum

const
  FAKE_CHECKSUM = '        ';
var
  fn: string;
  fn2: AnsiString;
  pre, s, fnU: RawByteString;
begin
  fn := replaceStr(flist[cur].dst, '\', '/');
  if fileNamesOEM then
    begin
      CharToOem(pChar(fn), pAnsiChar(fn2));
      fn := fn2;
    end;

  pre := '';
  fnU := StrToUTF8(fn);
  if length(fnU) >= 100 then
    begin
      pre := str('././@LongLink', 124)+num(length(fnU)+1, 12)+num(0, 12)
        +FAKE_CHECKSUM+'L';
      applyChecksum(pre);
      pre := str(pre, 512)+str(fnU, 512);
    end;
{ // old ustar format
  s := str(fnU, 100)
    +'100666 '#0'     0 '#0'     0 '#0 // file mode, uid, gid
    +num(flist[cur].size, 12) // file size
    +num(flist[cur].mtime, 12)  // mtime
    +FAKE_CHECKSUM
    +'0'+str('', 100)       // link properties
    +'ustar  '#0+str('user',32) + str('group',32);    // not actually used
}
 // posix format
  s := str(fnU, 100)
    +'100666 '#0'0000000'#0'0000000'#0 // file mode, uid, gid
    + #$80#0#0#0
    + qword_BEasStr(flist[cur].size) // file size
    +num(flist[cur].mtime, 12)  // mtime
    +FAKE_CHECKSUM
    +'0'+str('', 100)       // link properties
    +'ustar'#0'00'+str('',32) + str('',32);    // not actually used

  applyChecksum(s);
  s := str(s, 512); // pad
  block.Size := 0;
//  block.WriteString(pre+s);
  if Length(pre) > 0 then
    block.WriteData(@pre[1], Length(pre));
  if Length(s) > 0 then
    block.WriteData(@s[1], Length(s));
  block.seek(0, soBeginning);
end; // headerInit

function TtarStream.write(const Buffer; Count: Longint): Longint;
begin
  raise EWriteError.Create('write unsupproted')
end;

function gap512(i: int64): word; inline;
begin
  result := i and 511;
  if result > 0 then
    result:=512-result;
end; // gap512

function eos(s: Tstream): boolean;
begin
  result := s.position >= s.size
end;

procedure TtarStream.padInit(full: boolean=FALSE);
begin
  block.Size := 0;
  block.WriteString(dupeString(#0, math.IfThen(full, 512, gap512(pos)) ));
  block.Seek(0, soBeginning);
end; // padInit

function TtarStream.headerLengthForFilename(const fn: string): integer;
begin
  result := length(fn);
  result := 512 * math.IfThen(result<100, 1, 3+result div 512);
end; // headerLengthForFilename

procedure TtarStream.calculate();
var
  pos: int64;
  i: integer;
begin
pos:=0;
for i:=0 to length(flist)-1 do
  with flist[i] do
    begin
    firstByte:=pos;
    inc(pos, size+headerLengthForFilename(dst));
    inc(pos, gap512(pos));
    end;
inc(pos, 512); // last empty block
cachedTotal:=pos;
end; // calculate

function TtarStream.seek(const Offset: Int64; Origin: TSeekOrigin): Int64;

  function left(): int64;
  begin
    result := offset-pos
  end;

  procedure fineSeek(s: Tstream);
  begin
    inc(pos, s.seek(left(), soBeginning))
  end;

  function skipMoreThan(size: int64):boolean;
  begin
    result := left() > size;
    if result then
      inc(pos, size);
  end;

var
  bak: int64;
  prevCur: integer;
begin
{ The lastSeekFake trick is a way to fastly manage a sequence of
  seek(0,soCurrent); seek(0,soEnd); seek(0,soBeginning);
  such sequence called very often, while it is used to just read
  the size of the stream, no real seeking requirement.
}
  bak:=lastSeekFake;
  lastSeekFake:=-1;
  if totalSize <0 then
    calculate;
  if (origin = soCurrent) and (offset <> 0) then
    seek(pos+offset, soBeginning);
  if origin = soEnd then
    if offset < 0 then
      seek(totalSize+offset, soBeginning)
     else
      begin
        lastSeekFake:=pos;
        pos:=totalsize;
      end;
  result:=pos;
  if origin <> soBeginning then
    exit;
  if bak >= 0 then
  begin
    pos:=bak;
    exit;
  end;

// here starts the normal seeking algo

prevCur := cur;
cur:=0;  // flist index
pos:=0;  // current position in the file
block.size:=0;
while (left() > 0) and (cur < length(flist)) do
  begin
  // are we seeking inside this header?
  if not skipMoreThan(headerLengthForFilename(flist[cur].dst)) then
    begin
    if (prevCur <> cur) or (where <> TW_HEADER) or eos(block) then
      headerInit();
    fineSeek(block);
    where:=TW_HEADER;
    break;
    end;
  // are we seeking inside this file?
  if not skipMoreThan(flist[cur].size) then
    begin
    if not fsInit() then
      raise Exception.Create('TtarStream.seek: cannot open '+flist[cur].src);
    fineSeek(fs);
    where:=TW_FILE;
    break;
    end;
  // are we seeking inside this pad?
  if not skipMoreThan(gap512(pos)) then
    begin
    padInit();
    fineSeek(block);
    where:=TW_PAD;
    break;
    end;
  inc(cur);
  end;//while
if left() > 0 then
  begin
  padInit(TRUE);
  fineSeek(block);
  end;
result:=pos;
end; // seek

function TtarStream.read(var Buffer; Count: Longint): Longint;
var
  p: Pbyte;

  procedure goForth(d: int64); overload;
  begin
    dec(count, d);
    inc(pos, d);
    inc(p, d);
  end; // goForth

  procedure goForth(s: Tstream); overload;
  begin
    goForth( s.read(p^, count) )
  end;

var
  i, posBak: int64;
begin
posBak:=pos;
p:=@buffer;
while (count > 0) and (cur < length(flist)) do
  case where of
    TW_HEADER:
      begin
      if block.size = 0 then
        headerInit();
      goForth(block);
      if not eos(block) then continue;
      where:=TW_FILE;
      block.size:=0;
      end;
    TW_FILE:
      begin
      fsInit();
      if assigned(fs) then
        goForth(fs);
      { We reserved a fixed space for this file in the archive, but the file
        may not exist anymore, or its size may be shorter than expected,
        so we can't rely on eos(fs) to know if we are done in this section.
        Lets calculate how far we are from the theoretical end of the file,
        and decide after it.
      }
      i:=headerLengthForFilename(flist[cur].dst);
      i:=flist[cur].firstByte+i+flist[cur].size-pos;
      if count >= i then
        where:=TW_PAD;
      // In case the file is shorter, we pad the rest with NUL bytes
      i:=min(count, max(0,i));
      fillChar(p^,i,0);
      goForth(i);
      end;
    TW_PAD:
      begin
        if block.size = 0 then
          padInit();
        goForth(block);
        if not eos(block) then
          continue;
        where:=TW_HEADER;
        block.size:=0;
        inc(cur);
      end;
    end;//case

// last empty block
if count > 0 then
  begin
  padInit(TRUE);
  goForth(block);
  end;
result:=pos-posBak;
end; // read

end.
