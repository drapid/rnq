unit RnQNet.Uploads;
{$I forRnQConfig.inc}
{$I RnQConfig.inc }
{$I NoRTTI.inc}

interface

uses
  Classes, JSON, OverbyteIcsWSocket, OverbyteIcsHttpProt, OverbyteIcsNtlmMsgs, OverbyteIcsWSockBuf,
{$IFDEF UseNTLMAuthentication}
  RnQHttpAuth,
{$ENDIF}
  RDGlobal, RnQGlobal;


const
  FileTooBig = 'File is too big, max size %s MB';
  AuthFailed = 'File hosting authentication failed';
  UploadError = 'Failed to upload file! Server response';

  function UploadFileRGhost(const Filename: String; pOnSendData: TDocDataEvent): String;
  function UploadFileRnQ(const Filename: String; pOnSendData: TDocDataEvent): String;

type
  PMemoryStream = ^TMemoryStream;

  TCallbacks = class
  public
    class procedure OnBeforeHeaderSend(Sender: TObject; const Method : String; Headers: TStrings);
  end;

var
  uploadSize, uploadedSize: Integer;
  isUploading: Boolean;

implementation

uses
  Windows, Base64, SysUtils, StrUtils,
//  RDUtils, iniLib, utilLib, globalLib,
  RnQPrefsLib,
{$IFDEF UNICODE}
  AnsiStrings,
{$ENDIF UNICODE}
  // OverbyteIcsLogger,
{$IFDEF RNQ}
  RnQLangs, RnQDialogs, RQUtil,
{$ENDIF RNQ}
  RnQNet,
  RnQGraphics32;

class procedure TCallbacks.OnBeforeHeaderSend(Sender: TObject; const Method : String; Headers: TStrings);
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
  result := format('%s' + CRLF + 'Content-Disposition: form-data; name="%s"' + CRLF + CRLF + '%s' + CRLF,
            ['--' + boundry, name, value]);
end;

function UploadFileRGhost(const Filename: String; pOnSendData: TDocDataEvent): String;
var
  AvStream, FileStream, TokenStream: TMemoryStream;
  httpCli: TSslHttpCli;
  Host, Token, Buf, Boundry, TokenStr, FilePage: RawByteString;
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
  except end;

  JSONObject := TJSONObject.ParseJSONValue(TokenStr) as TJSONObject;
  if Assigned(JSONObject) then
    begin
      Host := JSONObject.GetValue('upload_host').Value;
      Token := JSONObject.GetValue('authenticity_token').Value;
      ULimit := 100;
      TryStrToInt(JSONObject.GetValue('upload_limit').Value, ULimit);

      if FileSize(Filename) > ULimit * 1024 * 1024 then
      begin
        msgDlg(getTranslation(FileTooBig, [IntToStr(ULimit)]), true, mtError);
        httpCli.Free;
        Exit;
      end;
    end
   else
    begin
      msgDlg(getTranslation(AuthFailed), true, mtError);
      httpCli.Free;
      Exit;
    end;

  try
    httpCli.URL := 'http://' + Host + '/files';
    httpCli.ContentTypePost := 'multipart/form-data; boundary=' + Boundry;
    httpCli.SendStream := TMemoryStream.Create;

    Buf := InputText(Boundry, 'authenticity_token', Token);
    httpCli.SendStream.Write(Buf[1], Length(Buf));
    Buf := '--' + Boundry + CRLF + 'Content-Disposition: form-data; name="file"; filename="' + UTF8Encode(ExtractFileName(Filename)) + '"' + CRLF +
           'Content-Transfer-Encoding: binary' + CRLF + CRLF;
    httpCli.SendStream.Write(Buf[1], Length(Buf));

    FileStream := TMemoryStream.Create;
    FileStream.LoadFromFile(Filename);
    FileStream.Seek(0, soFromBeginning);
    FileStream.SaveToStream(httpCli.SendStream);

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

        p := Pos('window.rgh.fileurl = ''', FilePage) + 22;
        DownloadLink := Copy(FilePage, p, Pos('''', FilePage, p) - p);
        OutputDebugString(PChar(DownloadLink));

        p := Pos('name="direct_link"', FilePage) + 83;
        Result := Copy(FilePage, p, Pos('"', FilePage, p) - p);
        OutputDebugString(PChar(Result));

        if not StartsText('http://', Result) then
          Result := httpCli.Location;
      end;
    except
      msgDlg(getTranslation(UploadError) + ': ' + httpCli.LastResponse, true, mtError);
    end;
  finally
    isUploading := False;
    httpCli.Free;
    if Assigned(AvStream) then FreeAndNil(AvStream);
    if Assigned(FileStream) then FreeAndNil(FileStream);
  end;
end;

function UploadFileRnQ(const Filename: String; pOnSendData: TDocDataEvent): String;
var
  AvStream, FileStream: TMemoryStream;
  httpCli: TSslHttpCli;
  Buf, Boundry, UploadedName: RawByteString;
begin
  Result := '';
  Boundry := '---------------MikanoshiServerUpload';

  httpCli := TSslHttpCli.Create(nil);
  SetupProxy(httpCli);
  httpCli.BandwidthLimit := 0;
  httpCli.RequestVer := '1.1';
  httpCli.Connection := 'Keep-Alive';
  httpCli.Agent := 'R&Q 1124 Custom Build';

  if FileSize(Filename) > 100 * 1024 * 1024 then
  begin
    msgDlg(getTranslation(FileTooBig, [IntToStr(100)]), true, mtError);
    httpCli.Free;
    Exit;
  end;

  try
    httpCli.URL := 'http://RnQ.ru/file_upload.php';
    httpCli.ContentTypePost := 'multipart/form-data; boundary=' + Boundry;
    httpCli.SendStream := TMemoryStream.Create;

    Buf := InputText(Boundry, 'fname', ExtractFileName(Filename));
    httpCli.SendStream.Write(Buf[1], Length(Buf));
    Buf := '--' + Boundry + CRLF + 'Content-Disposition: form-data; name="file"; filename="' + UTF8Encode(ExtractFileName(Filename)) + '"' + CRLF +
           'Content-Transfer-Encoding: binary' + CRLF + CRLF;
    httpCli.SendStream.Write(Buf[1], Length(Buf));

    FileStream := TMemoryStream.Create;
    FileStream.LoadFromFile(Filename);
    FileStream.Seek(0, soFromBeginning);
    FileStream.SaveToStream(httpCli.SendStream);

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

      Result := UploadedName;
    except
      msgDlg(getTranslation(UploadError) + ': ' + #13#10 + httpCli.RcvdHeader.Text, true, mtError);
    end;
  finally
    isUploading := False;
    httpCli.Free;
    if Assigned(AvStream) then FreeAndNil(AvStream);
    if Assigned(FileStream) then FreeAndNil(FileStream);
  end;
end;


end.
