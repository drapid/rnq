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

resourcestring
  FileTooBig = 'File is too big, max size %s MB';
  AuthFailed = 'File hosting authentication failed';
  UploadError = 'Failed to upload file! Server response';
  FileNotExists = 'File doesn''t exist';

//  function UploadFileRGhost(const Filename: String; pOnSendData: TDocDataEvent): String;
  function UploadFileRGhost(FileStream: TStream; FileName: String; pOnSendData: TDocDataEvent): String;
  function UploadFileRnQ(FileStream: TStream; const Filename: String; pOnSendData: TDocDataEvent): String;
  function UploadTarFileRnQ(const Filenames: String; pOnSendData: TDocDataEvent): String;

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
  RnQNet.Uploads.Lib,
  RnQNet.Uploads.Tar,
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

  fsize := tar.totalSize;

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




end.
