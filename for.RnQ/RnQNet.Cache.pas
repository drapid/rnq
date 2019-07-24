unit RnQNet.Cache;
{$I forRnQConfig.inc}
{$I NoRTTI.inc}

interface

uses
  Classes, Forms, JSON, NetEncoding, OverbyteIcsWSocket, OverbyteIcsHttpProt, OverbyteIcsNtlmMsgs, OverbyteIcsWSockBuf,
{$IFDEF UseNTLMAuthentication}
  RnQHttpAuth,
{$ENDIF}
  iniFiles,
  RDGlobal, RnQGlobal;


const
  ConnectionError = 'Connection error\n[%d]\n%s';
  SSLError = 'OpenSSL libs are not found\n%s';
  FileTooBig = 'File is too big, max size %s MB';
  AuthFailed = 'File hosting authentication failed';
  UploadError = 'Failed to upload file! Server response';

  ImageContentTypes: array [0 .. 25] of string = (
    'image/bmp', 'image/x-bmp', 'image/x-bitmap', 'image/x-xbitmap', 'image/x-win-bitmap', 'image/x-windows-bmp', 'image/ms-bmp', 'image/x-ms-bmp', 'application/bmp', 'application/x-bmp', 'application/x-win-bitmap',
    'image/jpeg', 'image/jpg', 'application/jpg', 'application/x-jpg',
    'image/gif',
    'image/png', 'application/png', 'application/x-png',
    'image/ico', 'image/x-icon', 'application/ico', 'application/x-ico',
    'image/tiff', 'image/x-tiff',
    'image/webp'
  );
  ImageExtensions: array [0 .. 25] of string = (
    'bmp', 'bmp', 'bmp', 'bmp', 'bmp', 'bmp', 'bmp', 'bmp', 'bmp', 'bmp', 'bmp',
    'jpg', 'jpg', 'jpg', 'jpg',
    'gif',
    'png', 'png', 'png',
    'ico', 'ico', 'ico', 'ico',
    'tiff', 'tiff',
    'webp'
  );

  procedure CacheType(const url, mime, ctype: RawByteString);
  function CheckType(lnk: String): Boolean; overload;
  function CheckType(lnk: String; var sA: RawByteString; var ext: String): Boolean; overload;
  function DownloadAndCache(lnk: String): Boolean;
  function CacheImage(var mem: TMemoryStream; const url, ext: RawByteString): Boolean;

var
  EnableVideoLinks: Boolean;
var
  imgCacheInfo: TMemIniFile;
  cacheDir: String;

implementation

uses
  Windows, Base64, SysUtils, StrUtils, System.Threading, Graphics,
  RDUtils,
  RnQPrefsInt, RnQZip,  RnQNet, Murmur2,
{$IFDEF UNICODE}
  AnsiStrings,
{$ENDIF UNICODE}
  // OverbyteIcsLogger,
{$IFDEF RNQ}
  RnQLangs, RnQDialogs, RQUtil,
{$ENDIF RNQ}
{$IFDEF RNQ_PLUGIN}
  RDPlugins,
{$ENDIF RNQ_PLUGIN}
  RnQGraphics32;

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
  result := format('%s' + CRLF + 'Content-Disposition: form-data; name="%s"' + CRLF + CRLF + '%s' + CRLF,
            ['--' + boundry, name, value]);
end;

function CheckType(lnk: String): Boolean;
var
  ext: String;
  sA: RawByteString;
begin
  Result := CheckType(lnk, sA, ext);
end;

function DecodeURL(url: String): String;
begin
  Result := TEncoding.UTF8.GetString(TNetEncoding.URL.DecodeStringToBytes(url));
end;

procedure CacheType(const url, mime, ctype: RawByteString);
begin
  try
    if not (mime = '') then
      imgCacheInfo.WriteString(url, 'mime', mime)
    else if not (ctype = '') then
      imgCacheInfo.WriteString(url, 'mime', ctype);
    imgCacheInfo.UpdateFile;
  except end;
end;

function CacheImage(var mem: TMemoryStream; const url, ext: RawByteString): Boolean;
var
  imgcache, fn: String;
  hash: LongWord;
  winimg: TWICImage;
begin
  Result := False;
  winimg := TWICImage.Create;
  mem.Seek(0, 0);

  try
    winimg.LoadFromStream(mem);
  except
    if Assigned(winimg) then
      winimg.Free;
    Exit;
  end;

  if winimg.Empty then
  begin
    winimg.Free;
    Exit;
  end;

  imgcache := myPath + 'Cache\Images\';
  if not DirectoryExists(imgcache) then
    ForceDirectories(imgcache);

  hash := CalcMurmur2(BytesOf(url));
  fn := imgcache + IntToStr(hash) + '.' + ext;
  winimg.SaveToFile(fn);

  try
    imgCacheInfo.WriteString(url, 'ext', ext);
    imgCacheInfo.WriteString(url, 'hash', IntToStr(hash));
    imgCacheInfo.WriteInteger(url, 'width', winimg.Width);
    imgCacheInfo.WriteInteger(url, 'height', winimg.Height);
    imgCacheInfo.UpdateFile;
  finally
    winimg.Free;
  end;

  Result := True;
end;

function CheckType(lnk: String; var sA: RawByteString; var ext: String): Boolean;
var
  Task: ITask;
  res: Boolean;
  sALocal: RawByteString;
  extLocal, anchor: String;
begin
  Result := False;

  Task := TTask.Run(procedure()
  var
    buf: TMemoryStream;
    idx: Integer;
    ctype: String;
    imgStr, mime, fileIdStr: RawByteString;
    JSONObject: TJSONObject;
  begin

  if EnableVideoLinks and (ContainsText(lnk, 'youtube.com/') or ContainsText(lnk, 'youtu.be/') or ContainsText(lnk, 'vimeo.com/')) then
  begin
    buf := TMemoryStream.Create;
    LoadFromURL(lnk, buf);
    SetLength(imgStr, buf.Size);
    buf.ReadBuffer(imgStr[1], buf.Size);
    buf.Free;

    anchor := 'property="og:image" content="';
    sALocal := copy(imgStr, pos(anchor, imgStr) + length(anchor));
    sALocal := copy(sALocal, 1, pos('"', sALocal) - 1);
    sALocal := DecodeURL(UnUTF(sALocal));
  end
  else if ContainsText(lnk, 'files.icq.net/') then
  begin
    fileIdStr := ReplaceText(Trim(lnk), 'files.icq.net/get/', 'files.icq.com/getinfo?file_id=');
    fileIdStr := ReplaceText(fileIdStr, 'files.icq.net/files/get?fileId=', 'files.icq.com/getinfo?file_id=');

    buf := TMemoryStream.Create;
    LoadFromURL(fileIdStr, buf);
    SetLength(imgStr, buf.Size);
    buf.ReadBuffer(imgStr[1], buf.Size);
    buf.Free;

    JSONObject := TJSONObject.ParseJSONValue(imgStr) as TJSONObject;
    if Assigned(JSONObject) then
    try
      JSONObject := TJSONObject.ParseJSONValue(TJSONArray(JSONObject.GetValue('file_list')).Items[0].ToJSON) as TJSONObject;
      sALocal := JSONObject.GetValue('dlink').Value + '?no-download=1';
      mime := JSONObject.GetValue('mime').Value;
      JSONObject.Free;
    except end;
  end else
    sALocal := Trim(lnk);

  if not (mime = '') and (pos(';', mime) > 0) then
    mime := copy(mime, 1, pos(';', mime) - 1);

  ctype := HeaderFromURL(sALocal);
  if not (ctype = '') and (pos(';', ctype) > 0) then
    ctype := copy(ctype, 1, pos(';', ctype) - 1);

  CacheType(lnk, mime, ctype);
  if MatchText(mime, ImageContentTypes) or MatchText(ctype, ImageContentTypes) then
  begin
    res := True;

    idx := IndexText(mime, ImageContentTypes);
    if idx < 0 then
      idx := IndexText(ctype, ImageContentTypes);

    if idx >= 0 then
      extLocal := ImageExtensions[idx]
    else
      extLocal := 'jpg';
  end;
  end);
  while not task.Wait(100) do
    Application.ProcessMessages;

  sA := sALocal;
  ext := extLocal;
  Result := res;
end;

function DownloadAndCache(lnk: String): Boolean;
var
  ext: String;
  sA: RawByteString;
  res: Boolean;
  buf: TMemoryStream;
begin
  Result := False;
  if not CheckType(lnk, sA, ext) then
    Exit;

  buf := TMemoryStream.Create;
  LoadFromURL(sA, buf);

  TThread.Synchronize(nil, procedure begin
    res := CacheImage(buf, lnk, ext);
  end);
  if Assigned(buf) then
    buf.Free;
  Result := res;
end;


end.
