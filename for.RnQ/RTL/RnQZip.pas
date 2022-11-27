{
This file is part of R&Q.
Under same license
}
unit RnQZip;
{$I ForRnQConfig.inc}
{$I NoRTTI.inc}

{ $IFDEF RNQ}
 { $DEFINE ZIP_AES}
{ $ENDIF RNQ}

// ToDo http://www.winzip.com/aes_info.htm
// Copyright 2005 Patrik Spanel
// scilib@sendme.cz

// Written from scratch using InfoZip PKZip file specification application note

// ftp://ftp.info-zip.org/pub/infozip/doc/appnote-iz-latest.zip

// uses the Borland out of the box zlib


// 2005 Added support for streams (LoadFromStream(const ZipFileStream: TStream),SaveToStream(...))

// Nick Naimo <nick@naimo.com> added support for folders on 6/29/2004
// Marcin Wojda <Marcin@sacer.com.pl> added exceptions and try finally blocks
// Jarek Stok³osa <jarek.stoklosa@gmail.com> 11/04/2008 added support for additional file descriptor(LoadFromStream and SaveToStream), add const section;

interface

uses
  SysUtils, Classes, Types, Windows,
 {$IFDEF FPC}
  ZLib,
  ZStream,
  ZlibHigh,
 {$ELSE ~FPC}
  System.ZLib,
  OverbyteIcsZLibHigh,
 {$ENDIF FPC}
  RDGlobal;

type

  TZLibStreamHeader = packed record
     CMF: Byte;
     FLG: Byte;
  end;

  TFileDescriptor = packed record
    Crc32: DWORD; //                          4 bytes
    CompressedSize: DWORD; //                 4 bytes
    UncompressedSize: DWORD; //               4 bytes
  end;

  TCommonFileHeader = packed record
    VersionNeededToExtract: WORD; //       2 bytes
    GeneralPurposeBitFlag: WORD; //        2 bytes
    CompressionMethod: WORD; //            2 bytes
    LastModFileTimeDate: DWORD; //         4 bytes
    FileDesc: TFileDescriptor;
    FilenameLength: WORD; //               2 bytes
    ExtraFieldLength: WORD; //             2 bytes
  end;

  TLocalFile = packed record
    LocalFileHeaderSignature: DWORD; //    4 bytes  (0x04034b50)
    CommonFileHeader: TCommonFileHeader; //
    filename: TBytes; //variable size
    extrafield: RawByteString; //variable size
    CompressedData: RawByteString; //variable size
    pass: AnsiString;
 { TODO -oRapid D -cIncrease load speed : Add support of "preview" loading }
    DataOffset: Int64;
    DataLoaded: Boolean;
    function UTFSupport: Boolean;
    function getFileName: String;
  end;

 {$IFDEF ZIP_AES}
  TAESExtraData = packed record
    HeaderID : WORD;      //2 bytes //Extra field header ID (0x9901)
    DataSize : WORD;      //2 bytes //Data size (currently 7, but subject to possible increase in the future)
    Version  : WORD;      //2 bytes //Integer version number specific to the zip vendor
    Vendor   : WORD;      //2 bytes //2-character vendor ID = 'AE'
    AESMode  : Byte;      //1 byte  //Integer mode value indicating AES encryption strength
    CompressMethod: WORD; //2 bytes //The actual compression method used to compress the file
  end;
 {$ENDIF ZIP_AES}

  FILE_INT = LongWord;
//  {$IFDEF HAS_64_BIT_INT}
  BIGINT = INT64;
//  {$ELSE}
//  BIGINT = LongInt;
//  {$ENDIF}

  zip64_Extra_Field = packed record
    Tag: WORD; { $0001 }
    Size: WORD;
    Uncompressed_Size: BIGINT;
    Compressed_Size: BIGINT;
    Relative_Offset: BIGINT;
    DiskStart: LongWord;
  end;
//  zip64_Extra_FieldPtr = ^zip64_Extra_Field;

  data_descriptor_zip64 = packed record
    crc32:              ULONG;
    compressed_size:    BIGINT;
    uncompressed_size:  BIGINT;
  end;

  NTFS_extra_field = packed record
    Tag: WORD; { $000a }
    Size: WORD;
    Reserved: LongWord;
    Tag1: WORD; { $0001 }
    Size1: WORD;
    Mtime: BIGINT;
    Atime: BIGINT;
    Ctime: BIGINT;
  end;
//  NTFS_extra_fieldPtr = ^NTFS_extra_field;

  TFileHeader = packed record
    CentralFileHeaderSignature: DWORD; //   4 bytes  (0x02014b50)
    VersionMadeBy: WORD; //                 2 bytes
    CommonFileHeader: TCommonFileHeader; //
    FileCommentLength: WORD; //             2 bytes
    DiskNumberStart: WORD; //               2 bytes
    InternalFileAttributes: WORD; //        2 bytes
    ExternalFileAttributes: DWORD; //       4 bytes
    RelativeOffsetOfLocalHeader: DWORD; //  4 bytes
    filename: TBytes; //variable size
    extrafield: RawByteString; //variable size
    fileComment: AnsiString; //variable size

 {$IFDEF ZIP_AES}
    AESInfo: TAESExtraData; // By Rapid D
 {$ENDIF ZIP_AES}
    function UTFSupport: Boolean;
  end;

  TEndOfCentralDir = packed record
    EndOfCentralDirSignature: DWORD; //    4 bytes  (0x06054b50)
    NumberOfThisDisk: WORD; //             2 bytes
    NumberOfTheDiskWithTheStart: WORD; //  2 bytes
    TotalNumberOfEntriesOnThisDisk: WORD;  //  2 bytes
    TotalNumberOfEntries: WORD; //         2 bytes
    SizeOfTheCentralDirectory: DWORD; //   4 bytes
    OffsetOfStartOfCentralDirectory: DWORD; // 4 bytes
    ZipfileCommentLength: WORD; //         2 bytes
  end;

  TZipFile = class(TObject)
   private
    Files: array of TLocalFile;
    CentralDirectory: array of TFileHeader;
    EndOfCentralDirectory: TEndOfCentralDir;
    aUTF8Support: Boolean;  // By Default its True
    fFN: String;
   public
    ZipFileComment: AnsiString;
    Password: AnsiString;
    prefixBLOB: RawByteString; // for example sfx module
//    fCompressionLevel: Integer;
  private
    function  GetUncompressed(i: integer): RawByteString;
    procedure SetUncompressed(i: integer; const Value: RawByteString);
    procedure Uncompress2Stream(I: Integer; Stream: TStream; pAutoLoad: Boolean = True);
    function  GetDateTime(i: integer): TDateTime;
    procedure SetDateTime(i: integer; const Value: TDateTime);
    function  GetCount: integer;
    function  GetName(i: integer): string;
    procedure SetName(i: integer; const Value: string);
  public
    constructor create;
    function  AddFile(const name: string; FAttribute: DWord = 0; const pPass: AnsiString = '';
                       const pData: RawByteString = ''): Integer;
    function  AddExtFile(const pFileName: String; const name: string = '';
                         FAttribute: DWord = 0; const pPass: AnsiString = ''): Integer;
    procedure SaveToFile(const filename: string);
    procedure SaveToStream(ZipFileStream: TStream);
    procedure LoadFromFile(const filename: string; pPreview: Boolean = false);
    procedure LoadFromStream(const ZipFileStream: TStream; pPreview: Boolean = false);
    function  IndexOf(const s: String): Integer;
    Function  ExtractToStream(const fn: String; Stream: TStream): Boolean; Overload;
    function  ExtractToStream(i: Integer; Stream: TStream): Boolean; Overload;
    function  IsEncrypted(i: Integer): Boolean;
    function  CheckPassword(I: Integer; const pass: AnsiString): Boolean;
    property  Count: integer read GetCount;
//    property Uncompressed[i: integer]: AnsiString read GetUncompressed;
                                                  //write SetUncompressed;
    property Data[i: integer]: RawByteString read  GetUncompressed
                                             write SetUncompressed;
//    property CompressionLevel: Integer read fCompressionLevel write fCompressionLevel;
    property DateTime[i: integer]: TDateTime read GetDateTime write SetDateTime;
    property Name[i: integer]: string read GetName write SetName;
    property UTF8Support: Boolean read aUTF8Support default True;
  end;

  EZipFileCRCError = class(Exception);

const
   dwLocalFileHeaderSignature = $04034B50;
   dwLocalFileDescriptorSignature = $08074B50;
   dwCentralFileHeaderSignature = $02014B50;
   dwEndOfCentralDirSignature = $06054b50;
   wAESEncrSignature = $9901;

function ZipCrc32(crc: Cardinal; const buffer: PByteArray; size: Cardinal): Cardinal; OverLoad;
function ZipCrc32(crc: Cardinal; const stream: TStream): Cardinal; OverLoad;

//function ZipCRC32(const Data: string): longword;
Function ToZipName(const FileName: String): String;
Function ToDosName(const FileName: String): String;
function CheckZIPFilePass(const zipfn, fn: String; const pass: String): Boolean;

function zCompressStr(const sa: RawByteString; Level: TCompressionLevel = clMax; StreamType: TZStreamType = zsZLib): RawByteString;
function ZDecompressStr(const sa: RawByteString): RawByteString;
function ZDecompressStr3(const sa: RawByteString; StreamType: TZStreamType = zsZLib): RawByteString;

function ZCompressBytes(const sa: TBytes; StreamType: TZStreamType = zsZLib): TBytes;
function ZDecompressBytes(const sa: TBytes): TBytes;

implementation
  uses
  {$IFDEF ZIP_AES}
   {$IFDEF USE_SYMCRYPTO}
     AES_HMAC_Syn,
    {$ELSE not SynCrypto}
     AES_HMAC,
   {$ENDIF ~USE_SYMCRYPTO}
  {$ENDIF ZIP_AES}
 {$IFNDEF FPC}
//   System.ZLibConst,
  {$IFDEF UNICODE}
   AnsiStrings,
  {$ENDIF UNICODE}
 {$ENDIF}
   RDFileUtil, RDUtils,
     Math;

const
  ZL_DEF_COMPRESSIONMETHOD  = $8;  { Deflate }
  ZL_ENCH_COMPRESSIONMETHOD = $9;  { Enchanced Deflate }
  ZL_BZIP2_COMPRESSIONMETHOD = 12; { BZIP2 }
  ZL_LZMA_COMPRESSIONMETHOD  = 14;  { LZMA }
  ZL_WINZIP_AES_COMPRESSIONMETHOD = 99; { AES encrypted}

  ZL_DEF_COMPRESSIONINFO    = $7;  { 32k window for Deflate }
  ZL_PRESET_DICT            = $20;

  ZL_FASTEST_COMPRESSION    = $0;
  ZL_FAST_COMPRESSION       = $1;
  ZL_DEFAULT_COMPRESSION    = $2;
  ZL_MAXIMUM_COMPRESSION    = $3;

  ZL_FCHECK_MASK            = $1F;
  ZL_CINFO_MASK             = $F0; { mask out leftmost 4 bits }
  ZL_FLEVEL_MASK            = $C0; { mask out leftmost 2 bits }
  ZL_CM_MASK                = $0F; { mask out rightmost 4 bits }



   SALT_LENGTH: array[1..3] of byte = (8, 12, 16);

//procedure make_crc_table;
var
  crc_table: array[Byte] of Cardinal;
  crc_table_computed: Boolean;

procedure make_crc_table;
var
  c: Cardinal;
  n, k: Integer;
begin
 for n:=0 to 255 do
  begin
   c := Cardinal(n);
   for k:=0 to 7 do
    begin
     if Boolean(c and 1) then
       c := $edb88320 xor (c shr 1)
      else
       c := c shr 1;
    end;
   crc_table[n] := c;
  end;
 crc_table_computed := True;
end;

{$R-}
function ZipCrc32(crc: Cardinal; const buffer: PByteArray; size: Cardinal): Cardinal;
var
  c: Cardinal;
  n: Int64;
  a: Byte;
begin
 c := crc;
 if not crc_table_computed then
  make_crc_table;
 if size > 0 then
   for n:=0 to size-1 do
     begin
       a := Byte(c) xor buffer^[n];
       c := Cardinal(crc_table[a] xor Cardinal(c shr 8));
     end;
 Result := c;
end;

function ZipCrc32(crc: Cardinal; const stream: TStream): Cardinal;
var
  c: Cardinal;
  n: Integer;
  buf: Byte;
begin
 c := crc;
 if not crc_table_computed then
  make_crc_table;
 stream.Position := 0;
 if stream.Size > 0 then
   begin
     n := stream.Read(buf, 1);
     while n > 0 do
      begin
        c := crc_table[(Byte(c) xor buf) and $FF] xor (c shr 8);
        n := stream.Read(buf, 1);
      end;
   end;
 Result := c;
end;
{$R+}

function ZCrc32(crc: Cardinal; const stream: TStream): Cardinal;
var
  c: Cardinal;
  a: Byte;
  Res: Int64;
  buf: array[0..254] of Byte;
begin
 c := crc;
// if not crc_table_computed then
//   make_crc_table;
 stream.Position := 0;
 Res := stream.size;
 while Res > 0 do
  begin
    a := stream.Read(buf, $FF);
    c := crc32(c, @buf[0], a) xor $FFFFFFFF;
    dec(Res, a);
  end;
 Result := c  xor $FFFFFFFF;
end;

function TFileHeader.UTFSupport: Boolean;
begin
  result := Self.CommonFileHeader.GeneralPurposeBitFlag and (1 shl 11) > 0
end;

function TLocalFile.UTFSupport: Boolean;
begin
  result := Self.CommonFileHeader.GeneralPurposeBitFlag and (1 shl 11) > 0
end;

function TLocalFile.getFileName: String;
var
  s: AnsiString;
begin
 SetLength(s, CommonFileHeader.FilenameLength);
 CopyMemory(@s[1], filename, CommonFileHeader.FilenameLength);
 if UTFSupport then
   Result := UnUTF(s)
  else
   Result := String(s);
end;

{ TZipFile }

constructor TZipFile.create;
begin
  inherited;
  Self.aUTF8Support := True;
end;

procedure TZipFile.SaveToFile(const filename: string);
var
  ZipFileStream: TFileStream;
begin
  ZipFileStream := TFileStream.Create(filename, fmCreate);
  try
  SaveToStream(ZipFileStream);
  finally
    ZipFileStream.Free;
  end;
end;

procedure TZipFile.SaveToStream(ZipFileStream: TStream);
var
  i: integer;
  dw: DWORD;
  cfh: TCommonFileHeader;
  additionalDescriptor: Boolean;
begin
  If prefixBLOB > '' then
    ZipFileStream.Write(prefixBLOB[1], length(prefixBLOB));
  for i := 0 to High(Files) do
    with Files[i] do
      begin
        CentralDirectory[i].RelativeOffsetOfLocalHeader :=
          ZipFileStream.Position;
        ZipFileStream.Write(LocalFileHeaderSignature, 4);
        if (LocalFileHeaderSignature = (dwLocalFileHeaderSignature)) then
        begin
          cfh := CommonFileHeader;
          additionalDescriptor :=((cfh.GeneralPurposeBitFlag AND 8) = 8);
          if additionalDescriptor then
          begin
             cfh.FileDesc.Crc32 := 0;
             cfh.FileDesc.CompressedSize := 0;
             cfh.FileDesc.UncompressedSize := 0;
          end;
          ZipFileStream.Write(cfh, SizeOf(CommonFileHeader));
          ZipFileStream.Write(PByte(filename)^,
            CommonFileHeader.FilenameLength);
          ZipFileStream.Write(PByte(extrafield)^,
            CommonFileHeader.ExtraFieldLength);
          ZipFileStream.Write(PByte(CompressedData)^,
            CommonFileHeader.FileDesc.CompressedSize);
          if additionalDescriptor then
          begin
            dw := dwLocalFileDescriptorSignature;
            ZipFileStream.Write(dw, 4);
            ZipFileStream.Write(CommonFileHeader.FileDesc, SizeOf(CommonFileHeader.FileDesc));
          end
        end;
      end;

    EndOfCentralDirectory.OffsetOfStartOfCentralDirectory :=
      ZipFileStream.Position;

    for i := 0 to High(CentralDirectory) do
      with CentralDirectory[i] do
      begin
        ZipFileStream.Write(CentralFileHeaderSignature, 4);
        ZipFileStream.Write(VersionMadeBy, 2);
        ZipFileStream.Write(CommonFileHeader, SizeOf(CommonFileHeader));
        ZipFileStream.Write(FileCommentLength, 2);
        ZipFileStream.Write(DiskNumberStart, 2);
        ZipFileStream.Write(InternalFileAttributes, 2);
        ZipFileStream.Write(ExternalFileAttributes, 4);
        ZipFileStream.Write(RelativeOffsetOfLocalHeader, 4);
        ZipFileStream.Write(PByte(filename)^, length(filename));
        ZipFileStream.Write(PByte(extrafield)^, length(extrafield));
        ZipFileStream.Write(PByte(fileComment)^, length(fileComment));
      end;
    with EndOfCentralDirectory do
    begin
      EndOfCentralDirSignature := dwEndOfCentralDirSignature;
      NumberOfThisDisk := 0;
      NumberOfTheDiskWithTheStart := 0;
      TotalNumberOfEntriesOnThisDisk := High(Files) + 1;
      TotalNumberOfEntries := High(Files) + 1;
      SizeOfTheCentralDirectory :=
        ZipFileStream.Position - OffsetOfStartOfCentralDirectory;
      ZipfileCommentLength := length(ZipFileComment);
    end;
    ZipFileStream.Write(EndOfCentralDirectory, SizeOf(EndOfCentralDirectory));
    ZipFileStream.Write(PByte(ZipFileComment)^, length(ZipFileComment));
end;


procedure TZipFile.LoadFromStream(const ZipFileStream: TStream; pPreview: Boolean = false);
var
  n: integer;
  signature: DWORD;
begin
  fFN := '';
  n := 0;
  repeat
    signature := 0;
    ZipFileStream.Read(signature, 4);
    if   (ZipFileStream.Position =  ZipFileStream.Size) then
      exit;
  until signature = dwLocalFileHeaderSignature;
  repeat
    begin
      if (signature = dwLocalFileHeaderSignature) then
      begin
        inc(n);
        SetLength(Files, n);
        with Files[n - 1] do
        begin
          LocalFileHeaderSignature := signature;
          ZipFileStream.Read(CommonFileHeader, SizeOf(CommonFileHeader));
          SetLength(filename, CommonFileHeader.FilenameLength);
          ZipFileStream.Read(PByte(filename)^,
            CommonFileHeader.FilenameLength);
          SetLength(extrafield, CommonFileHeader.ExtraFieldLength);
          ZipFileStream.Read(PByte(extrafield)^,
            CommonFileHeader.ExtraFieldLength);
{
          if ((CommonFileHeader.GeneralPurposeBitFlag and 8) = 8) then
          begin
            searchSignature := 0;
            rawData := '';
            repeat
              ZipFileStream.Read(searchSignature, 4);
              if searchSignature <> dwLocalFileDescriptorSignature then
              begin
                ZipFileStream.Seek(-4, soFromCurrent);
                ZipFileStream.Read(c, SizeOf(c));
                rawData := rawData + c;
              end;
            until  searchSignature = dwLocalFileDescriptorSignature;
            CompressedData := rawData;
            ZipFileStream.Read(CommonFileHeader.FileDescriptor, SizeOf(CommonFileHeader.FileDescriptor));
          end
          else
          begin
            SetLength(CompressedData, CommonFileHeader.FileDescriptor.CompressedSize);
            ZipFileStream.Read(PChar(CompressedData)^, CommonFileHeader.FileDescriptor.CompressedSize);
          end;
}
          DataOffset := ZipFileStream.Position;
          if pPreview then
            begin
             DataLoaded := False;
             SetLength(CompressedData, 0);
             ZipFileStream.Seek(CommonFileHeader.FileDesc.CompressedSize, soCurrent)
            end
           else
            begin
             DataLoaded := True;
             SetLength(CompressedData, CommonFileHeader.FileDesc.CompressedSize);
             ZipFileStream.Read(PByte(CompressedData)^,
                  CommonFileHeader.FileDesc.CompressedSize);
            end;
        end;
      end;
    end;
    signature := 0;
    ZipFileStream.Read(signature, 4);
  until signature <> (dwLocalFileHeaderSignature);

  n := 0;
  repeat
    begin
      if (signature = dwCentralFileHeaderSignature) then
      begin
        inc(n);
        if Length(CentralDirectory) < n then
          SetLength(CentralDirectory, n);
        with CentralDirectory[n - 1] do
          begin
            CentralFileHeaderSignature := signature;
            ZipFileStream.Read(VersionMadeBy, 2);
            ZipFileStream.Read(CommonFileHeader, SizeOf(CommonFileHeader));
            ZipFileStream.Read(FileCommentLength, 2);
            ZipFileStream.Read(DiskNumberStart, 2);
            ZipFileStream.Read(InternalFileAttributes, 2);
            ZipFileStream.Read(ExternalFileAttributes, 4);
            ZipFileStream.Read(RelativeOffsetOfLocalHeader, 4);
            SetLength(filename, CommonFileHeader.FilenameLength);
            ZipFileStream.Read(PAnsiChar(filename)^,
              CommonFileHeader.FilenameLength);
            SetLength(extrafield, CommonFileHeader.ExtraFieldLength);
            ZipFileStream.Read(PAnsiChar(extrafield)^,
              CommonFileHeader.ExtraFieldLength);
            SetLength(fileComment, FileCommentLength);
            ZipFileStream.Read(PAnsiChar(fileComment)^, FileCommentLength);

            //By Rapid D 20080601 ->
   {$IFDEF ZIP_AES}
            if (CommonFileHeader.ExtraFieldLength >= SizeOf(TAESExtraData))
                and (extrafield[1] = #$01)and(extrafield[2] = #$99) then
              begin
                CopyMemory(@AESInfo, PAnsiChar(extrafield), SizeOf(TAESExtraData) );
              end;
   {$ENDIF ZIP_AES}
            //
          end
      end;
    end;
    signature := 0;
    ZipFileStream.Read(signature, 4);
  until signature <> (dwCentralFileHeaderSignature);

  if Length(CentralDirectory) < length(files) then
    SetLength(CentralDirectory, length(files));

  if signature = dwEndOfCentralDirSignature then
  begin
    EndOfCentralDirectory.EndOfCentralDirSignature := Signature;
    ZipFileStream.Read(EndOfCentralDirectory.NumberOfThisDisk,
      SizeOf(EndOfCentralDirectory) - 4);
    SetLength(ZipFileComment, EndOfCentralDirectory.ZipfileCommentLength);
    ZipFileStream.Read(PByte(ZipFileComment)^,
      EndOfCentralDirectory.ZipfileCommentLength);
  end;
end;

procedure TZipFile.LoadFromFile(const filename: string; pPreview: Boolean = false);
var
  ZipFileStream: TFileStream;
begin
  fFN := filename;
  ZipFileStream := TFileStream.Create(filename, fmOpenRead or fmShareDenyWrite);
  try
    LoadFromStream(ZipFileStream, pPreview);
    fFN := filename;
  finally
    ZipFileStream.Free;
  end;
end;

function TZipFile.GetUncompressed(I: Integer): RawByteString;
var
 // Decompressor: TDecompressionStream;
  ResultStream: TMemoryStream;
  UncSize: Int64;
{  CompressedStream: TMemoryStream;
  AHeader: AnsiString;
  ReadBytes: Integer;
  LoadedCrc32: DWORD;}
begin
 if (I<0) or (I>High(Files)) then
  raise Exception.Create('Index out of range.');
 ResultStream := TMemoryStream.Create;
 try
   Uncompress2Stream(i, ResultStream);
   UncSize := ResultStream.Size;
   SetLength(Result, UncSize);
   if UncSize > 0 then
    CopyMemory(Pointer(Result), ResultStream.Memory, UncSize);
  except
    Result := '';
 end;
 ResultStream.Free;
end;


function TZipFile.CheckPassword(I: Integer; const pass: AnsiString): Boolean;
 {$IFDEF ZIP_AES}
var
  l: Integer;
  salt2: RawByteString;
//  key: Ansistring;
  pwd_ver: RawByteString;
//  pwd_verW: Word;
  {$IFDEF USE_SYMCRYPTO}
//    aes: TAESCTR;
    cx: fcrypt_ctx;
   {$ELSE not SynCrypto}
    cx: fcrypt_ctx;
  {$ENDIF ~USE_SYMCRYPTO}
//  cx: T_fcrypt_ctx;
  s1: RawByteString;
//  data : TData_Type;
 {$ENDIF ZIP_AES}
begin
 if (I<0) or (I>High(Files)) then
  begin
   Result := False;
   Exit;
  end;
 if Files[I].CommonFileHeader.CompressionMethod=99 then // Encrypted
  begin
//    raise EZDecompressionError.CreateFmt('Encryption is not supported',[]);
 {$IFDEF ZIP_AES}
//    Password := '123';
    l := SALT_LENGTH[CentralDirectory[i].AESInfo.AESMode];
//    l := SALT_LENGTH(CentralDirectory[i].AESInfo.AESMode);
   SetLength(salt2, l);
//   CopyMemory(@salt2[1], @Files[I].CompressedData[1], l);
   Move(Pointer(Files[I].CompressedData)^, Pointer(salt2)^, l);
  {$IFDEF USE_SYMCRYPTO}
//   aes := TAESCTR.Create(@pass[1], Length(pass));
//   aes.IV := (salt2);
    fcrypt_init(CentralDirectory[i].AESInfo.AESMode, pass, salt2, pwd_ver, cx);
  {$ELSE ~USE_SYMCRYPTO}
    AES_HMAC.fcrypt_init(CentralDirectory[i].AESInfo.AESMode, pass, salt2, pwd_ver, cx);
  {$ENDIF ~USE_SYMCRYPTO}
//    AES_HMAC.fcrypt_end(cx);
//    fcrypt_init(CentralDirectory[i].AESInfo.AESMode, @pass[1], Length(pass), @salt2[1], pwd_verW, cx);
//    SetLength(pwd_ver, 2);
//    CopyMemory(@pwd_ver[1], @pwd_verW, 2);

    s1 := Copy(Files[I].CompressedData, l+1, 2);
    if s1 <> pwd_ver then
      Result := false
     else
 {$ENDIF ZIP_AES}
      Result := True;
  end
 else
  Result := True;
end;


procedure TZipFile.Uncompress2Stream(I: Integer; Stream: TStream; pAutoLoad: Boolean = True);
var
//  Decompressor: TDecompressionStream;
//  CompressedStream: TMemoryStream;
// UncompressedStream: TStringStream;
// CompressedStream: TStringStream;
 ComprStream: TMemoryStream;
  AHeader: RawByteString;
  FZLHeader: TZLibStreamHeader;
//  ReadBytes: Integer;
//  ReadBytes2: Integer;
  LoadedCrc32: DWORD;

  data: Pointer;
 {$IFDEF ZIP_AES}
  l: Integer;
  salt2: RawByteString;
//  key: Ansistring;
  pwd_ver: RawByteString;
  cx: fcrypt_ctx;
  s1, s2: RawByteString;
//  data: TData_Type;
  dataLen: Integer;
  Cont_Size: Integer;

//  pwd_verW: word;
//  cx: DIFileEncrypt.T_fcrypt_ctx;
 {$ENDIF ZIP_AES}

  ZLH: Word;
  Compress: Byte;
  ZipFileStream: TFileStream;
begin
 if (I<0) or (I>High(Files)) then
  raise Exception.Create('Index out of range.');
 if not Files[i].DataLoaded and (not pAutoLoad or (fFN = '')) then
  raise Exception.Create('File was not decompressed.');

 if pAutoLoad and not Files[i].DataLoaded and (fFN > '') then
   begin
     ZipFileStream := TFileStream.Create(fFN, fmOpenRead or fmShareDenyWrite);
     try
       with Files[i] do
        begin
         DataLoaded := True;
         SetLength(CompressedData, CommonFileHeader.FileDesc.CompressedSize);
         ZipFileStream.Position := DataOffset;
         ZipFileStream.Read(PByte(CompressedData)^,
                  CommonFileHeader.FileDesc.CompressedSize);
        end;
      finally
       ZipFileStream.Free;
     end;
   end;

// AHeader := Chr(120)+Chr(156);
 AHeader := RawByteString(#$78)+#$9C;
  ZLH := Files[I].CommonFileHeader.CompressionMethod;
  if (ZLH=8)or (ZLH=9)or (ZLH = 99) Then
     Begin
//  FZLHeader.CMF := $78;
//  FZLHeader.FLG := $9C;
       FZLHeader.CMF := (ZL_DEF_COMPRESSIONINFO shl 4);               { 32k Window size }
       FZLHeader.CMF := FZLHeader.CMF or ZL_DEF_COMPRESSIONMETHOD;    { Deflate }
       Compress := ZL_DEFAULT_COMPRESSION;
       Case Files[I].CommonFileHeader.GeneralPurposeBitFlag AND 6 of
            0 : Compress := ZL_DEFAULT_COMPRESSION;
            2 : Compress := ZL_MAXIMUM_COMPRESSION;
            4 : Compress := ZL_FAST_COMPRESSION;
            6 : Compress := ZL_FASTEST_COMPRESSION;
       End;
       FZLHeader.FLG := FZLHeader.FLG or (Compress shl 6);
       FZLHeader.FLG := FZLHeader.FLG and not ZL_PRESET_DICT;         { no preset dictionary}
       FZLHeader.FLG := FZLHeader.FLG and not ZL_FCHECK_MASK;
       ZLH           := (FZLHeader.CMF * 256) + FZLHeader.FLG;
       Inc(FZLHeader.FLG, 31 - (ZLH mod 31));
//       Result := Result + Stream.Write(FZLHeader,SizeOf(FZLHeader));
       SetLength(AHeader, 2);
       AHeader[1] := AnsiChar(FZLHeader.CMF);
       AHeader[2] := AnsiChar(FZLHeader.FLG);
     End;
 Stream.Size := 0;
 if Files[I].CommonFileHeader.CompressionMethod=0 then //not compressed
  begin
   Stream.Write(Files[I].CompressedData[1], length(Files[I].CompressedData));
//   Result:=Files[I].CompressedData;
  end else
 if Files[I].CommonFileHeader.CompressionMethod=99 then // Encrypted
  begin
//    raise EZDecompressionError.CreateFmt('Encryption is not supported',[]);
 {$IFDEF ZIP_AES}
//    Password := '123';
    l := SALT_LENGTH[CentralDirectory[i].AESInfo.AESMode];
//    l := SALT_LENGTH(CentralDirectory[i].AESInfo.AESMode);
    SetLength(salt2, l);
    Move(Pointer(Files[I].CompressedData)^, Pointer(salt2)^, l);

    fcrypt_init(CentralDirectory[i].AESInfo.AESMode, Password, salt2, pwd_ver, cx);
//    fcrypt_init(CentralDirectory[i].AESInfo.AESMode, @Password[1], Length(Password), @salt2[1], pwd_verW, cx);
//    SetLength(pwd_ver, 2);
//    CopyMemory(@pwd_ver[1], @pwd_verW, 2);
    s1 := Copy(Files[I].CompressedData, l+1, 2);
    if s1 <> pwd_ver then
//     raise EZDecompressionError.CreateFmt('Wrong password',[]);
      raise Exception.Create('Wrong password.');

    Cont_Size := l+2;
    dataLen := Files[I].CommonFileHeader.FileDesc.CompressedSize - Cont_Size - 10;//MAC_LENGTH;
//    if dataLen > 0 then
     begin
      s2 := Copy(Files[I].CompressedData, Cont_Size + dataLen + 1, 10);
      ComprStream := TMemoryStream.Create;
      ComprStream.Write(AHeader[1], 2);
      ComprStream.Write(Files[I].CompressedData[Cont_Size+1], dataLen);
      ComprStream.Position := 0;
      data := Pointer(cardinal(ComprStream.Memory)+2);
  //    data := ComprStream.Memory+2;
  //    ReadBytes := 0;
  //      for l := 1 to Files[I].CommonFileHeader.UncompressedSize div SizeOf(buf) do
      if dataLen > 0 then
       fcrypt_decrypt(data, dataLen, cx);
//      fcrypt_decrypt(data, dataLen, cx2);
//      AES_HMAC.fcrypt_decrypt(data, dataLen, fcrypt_ctx((@cx2)^));
  //        fcrypt_decrypt(ComprStream.Memory, dataLen, cx);
{       l := dataLen;
       while l >= 16 do
        begin
         fcrypt_decrypt(data, 16, cx);
         dec(l, 16);
         inc(Cardinal(data), 16);
        end;
      if l > 0 then
       fcrypt_decrypt(data, l, cx);
}  
      s1 := fcrypt_end(cx);

      if dataLen > 0 then
      if CentralDirectory[i].AESInfo.CompressMethod = 0 then
        begin
  //        ComprStream.Position := 0;
          ComprStream.Position := 2;
          Stream.CopyFrom(ComprStream, dataLen);
  //        Stream.Write(data, dataLen);
  //      Stream.Write(Files[I].CompressedData[Cont_Size+1], dataLen)

  //      Stream.Write(Files[I].CompressedData[Cont_Size+1], dataLen)
          ComprStream.Free;
        end
       else
        begin
          ComprStream.Position := 0;
  //        CompressedStream.CopyFrom(ComprStream, dataLen);
          try
             ZLibDecompressStream(ComprStream, Stream);
  //           ZDecompressStream(ComprStream, Stream);
//           ReadBytes := Stream.Size;
          finally
      //     UncompressedStream.Free;
  //          CompressedStream.Free;
           ComprStream.Free;
          end;
        end;
     end;
//    Files[I].CommonFileHeader.Crc32 := 0;
 {$ENDIF ZIP_AES}
  end else
   begin
//    UncompressedStream:=TStringStream.Create(AHeader+Files[I].CompressedData);
//     CompressedStream := TStringStream.Create(AHeader+Files[I].CompressedData);
      ComprStream := TMemoryStream.Create;
      ComprStream.SetSize(Length(AHeader) + Length(Files[I].CompressedData));
      CopyMemory(ComprStream.Memory, @AHeader[1], Length(AHeader));
      data := ComprStream.Memory;
      INT_PTR(data) := INT_PTR(data) + Length(AHeader);
//      inc(data, Length(AHeader));
      CopyMemory(data, @Files[I].CompressedData[1], Length(Files[I].CompressedData));
      ZLibDecompressStream(ComprStream, Stream);
//      ZDecompressStream(ComprStream, Stream);
      ComprStream.Free;
//    LoadedCRC32:=ZipCRC32(Result);
//  LoadedCRC32 := ZCrc32($FFFFFFFF, @Result[1], Length(Result)) XOR $FFFFFFFF;
    Stream.Position := 0;
    LoadedCRC32 := ZipCrc32($FFFFFFFF, Stream) XOR $FFFFFFFF;
//  LoadedCRC32 := Crc32($FFFFFFFF, TMemoryStream(Stream).Memory, Stream.Size) XOR $FFFFFFFF;
    if LoadedCRC32<>Files[I].CommonFileHeader.FileDesc.Crc32 then
      raise EZipFileCRCError.CreateFmt('CRC Error in "%s".',[Files[I].getFileName]);
   end;
end;


Function TZipFile.ExtractToStream(const fn : String; Stream : TStream) : Boolean;
var
  i : Integer;
begin
  i := IndexOf(fn);
  if i >=0 then
   begin
//    if not Assigned(Stream) then
//      Stream := TMemoryStream.Create;
    Stream.Size := 0;
    Stream.Position := 0;
    Result := ExtractToStream(i, Stream);
   end
  else
   Result := False;
end;

Function TZipFile.ExtractToStream(i : Integer; Stream : TStream) : Boolean;
//var
// S:String;
begin
 if (I<0) or (I>High(Files)) then
  raise Exception.Create('Index out of range.');
// S:=GetUncompressed(i);
 Uncompress2Stream(i, Stream);
// if s > '' then
 if (Stream.Size > 0)or(Files[I].CommonFileHeader.FileDesc.UncompressedSize=0) then
 begin
//  Stream.Write(S[1],length(S));
  Result := True;
 end
 else
  Result := False;
// SetLength(s, 0);
end;

procedure TZipFile.SetUncompressed(i: integer; const Value: RawByteString);
const
  TestRPNG = RawByteString(#$CC#$7D#$42#$93#$04#$FE#$63#$7C#$B0#$46#$AD#$CE#$8F#$85#$63#$11);
var
//  Compressor: TCompressionStream;
//  CompressedStream: TStringStream;
  resStream: TMemoryStream;
  UnComprStream: TMemoryStream;
  Data: Pointer;
  ComprDataNIL: RawByteString;
  ComprSize: Int64;
 {$IFDEF ZIP_AES}
  isEncr: Boolean;
  aesMode: byte;
  salt2: RawByteString;
  pwd_ver: RawByteString;
  cx: fcrypt_ctx;
//  cx: T_fcrypt_ctx;
//  pwd_verW: Word;
  s1: RawByteString;
  l, ofs: Integer;
//  data1: Pointer;
//  EncrSize: Cardinal;
 {$ENDIF ZIP_AES}
begin
  if i > High(Files) then // exit;
    raise Exception.Create('Index out of range.');
//  compressedStream := TStringStream.Create('');
  try {+}
//    compressor := TcompressionStream.Create(CompressedStream, clMax);
//    compressor := TcompressionStream.Create(CompressedStream, clDefault);
//    compressor := TcompressionStream.Create(clDefault, CompressedStream);
    if Value = '' then
      begin
        ComprSize := 2;
        resStream := NIL;
        ComprDataNIL := dupString(RawByteString(#03#00));
//        Files[i].CompressedData := ;
        data := @ComprDataNIL[1];
      end
     else
      begin
        UnComprStream := TMemoryStream.Create;
        UnComprStream.SetSize(Length(Value));
        CopyMemory(UnComprStream.Memory, Pointer(Value), Length(Value));
        resStream := TMemoryStream.Create;
    //    ZlibCompressStreamEx(UnComprStream, resStream, clMax, zsZLib, false);
        ZLibCompressStreamEx(UnComprStream, resStream, clMax, zsZLib, True);
        UnComprStream.Free;
    //    ZCompressStream(UnComprStream, resStream, clMax);
        ComprSize := resStream.Size - 6;
        resStream.Position := 0;
        Data := resStream.Memory;
        inc(INT_PTR(Data), 2);
      end;

 {$IFDEF ZIP_AES}
    isEncr := Files[i].pass > '';
    if isEncr then
      begin
//       salt2 := 'Testing encription';
//       salt2 := #$FA#$48#$CB#$73#$F9#$65#$A2#$87#$85#$83#$CE#$79#$60#$3C#$08#$90;
       salt2 := TestRPNG;
       aesMode := 3;
       l := SALT_LENGTH[aesMode];
       SetLength(salt2, l);
       fcrypt_init(aesMode, Files[i].pass, salt2, pwd_ver, cx);
       if ComprSize > 0 then
        begin
//         ofs := ComprSize mod 16;
//         EncrSize := ComprSize - ofs;
//         fcrypt_encrypt(data, EncrSize, cx);
         fcrypt_encrypt(data, ComprSize, cx);
{         if ofs > 0 then
          begin
           data1 := data;
           inc(Cardinal(Data1), EncrSize);
           fcrypt_encrypt(data1, ofs, cx);
          end;}
        end;
       s1 := fcrypt_end(cx);
//        SetLength(s1, 10);
//        fcrypt_end(@s1[1], cx);
       ofs := l + 2 + ComprSize + 10;
       SetLength(Files[i].CompressedData, ofs);
       ofs := 1;
       CopyMemory(@Files[i].CompressedData[ofs], Pointer(salt2), l);
       inc(ofs, l); // Salt
       CopyMemory(@Files[i].CompressedData[ofs], Pointer(pwd_ver), 2);
       inc(ofs, 2); // Pwd_ver
      CopyMemory(@Files[i].CompressedData[ofs], Data, ComprSize);
       inc(ofs, ComprSize); // Data
       CopyMemory(@Files[i].CompressedData[ofs], Pointer(s1), 10);
      end
     else
 {$ENDIF ZIP_AES}
//      if Value > '' then
       begin
        SetLength(Files[i].CompressedData, ComprSize);
        CopyMemory(Pointer(Files[i].CompressedData), Data, ComprSize);
       end;
    if Assigned(resStream) then
      resStream.Free;
(*    Files[i].CompressedData := Copy(compressedStream.DataString, 3,
      length(compressedStream.DataString) - 6);

    try {+}
      compressor.Write(PByte(Value)^, length(Value));
     finally
      compressor.Free;
    end;
    Files[i].CompressedData := Copy(compressedStream.DataString, 3,
      length(compressedStream.DataString) - 6);
    //strip the 2 byte headers and 4 byte footers
*)
    Files[i].LocalFileHeaderSignature := (dwLocalFileHeaderSignature);
    with Files[i].CommonFileHeader do
    begin
//      VersionNeededToExtract := 20;
//      GeneralPurposeBitFlag := 0;
//      CompressionMethod := 8;
      LastModFileTimeDate := DateTimeToFileDate(Now);
//      Crc32 := ZipCRC32(Value);
//      Crc32 := OverbyteIcsZLibObj.Crc32($FFFFFFFF, @Value[1], Length(Value)) XOR $FFFFFFFF;
   {$IFDEF ZIP_AES}
      if isEncr then
        begin
          CompressionMethod := 99;
          GeneralPurposeBitFlag := GeneralPurposeBitFlag or 1;
          FileDesc.Crc32 := 0;
        end
       else
   {$ENDIF ZIP_AES}
        begin
          CompressionMethod := 8;
          GeneralPurposeBitFlag := GeneralPurposeBitFlag and (not 1);
//          Crc32 := ZipCrc32($FFFFFFFF, @Value[1], Length(Value)) XOR $FFFFFFFF;
          FileDesc.Crc32 := ZipCrc32($FFFFFFFF, Pointer(Value), Length(Value)) XOR $FFFFFFFF;
        end;

      FileDesc.CompressedSize   := length(Files[i].CompressedData);
      FileDesc.UncompressedSize := length(Value);
//      FilenameLength   := length(Files[i].filename);
//      ExtraFieldLength := length(Files[i].extrafield);
    end;

    with CentralDirectory[i] do
    begin
      CentralFileHeaderSignature := dwCentralFileHeaderSignature;
//      VersionMadeBy := 20;
      CommonFileHeader := Files[i].CommonFileHeader;
//      FileCommentLength := 0;
//      DiskNumberStart := 0;
//      InternalFileAttributes := 0;
      //      ExternalFileAttributes := 0;
//      RelativeOffsetOfLocalHeader := 0;
//      filename := Files[i].filename;
//      extrafield := Files[i].extrafield;
      fileComment := '';
    end;
  finally
//    compressedStream.Free;
  end;
end;

function TZipFile.AddFile(const name: string; FAttribute: DWord = 0; const pPass: AnsiString = '';
                             const pData: RawByteString = ''): Integer;
var
  h: Integer;
 {$IFDEF ZIP_AES}
  isEncr: Boolean;
  vAES_DATA: TAESExtraData;
//  salt2: RawByteString;
//  pwd_ver: RawByteString;
//  cx: fcrypt_ctx;
//  cx: T_fcrypt_ctx;
//  pwd_verW: Word;
//  s1: RawByteString;
//  ofs: Integer;
//  l: Integer;
//  dataLen: Integer;
//  Cont_Size: Integer;
 {$ENDIF ZIP_AES}
begin
//  Result := -1;
  SetLength(Files, High(Files) + 2);
  SetLength(CentralDirectory, length(Files));
  h := High(Files);
  if UTF8Support then
    Files[h].CommonFileHeader.GeneralPurposeBitFlag := Files[h].CommonFileHeader.GeneralPurposeBitFlag or (1 shl 11); // UTF8 support

  if UTF8Support then
    Files[h].filename := StringToTBytes(name)
   else
    Files[h].filename := StringToTBytes(name, 437)
  ;
  Files[h].extrafield := '';
  Files[h].pass := pPass;
 {$IFDEF ZIP_AES}
  isEncr := pPass > '';

  Files[h].LocalFileHeaderSignature := dwLocalFileHeaderSignature;

  if isEncr then
   begin
     vAES_DATA.HeaderID := wAESEncrSignature;
     vAES_DATA.DataSize := 7;
     vAES_DATA.Version  := $0002; // The vendor version for AE-2 is 0x0002
     vAES_DATA.Vendor   := Byte('E') shl 8 + byte('A');
     vAES_DATA.AESMode  := $03; // $03	- 256-bit encryption key
     vAES_DATA.CompressMethod := 8;
     SetLength(Files[h].extrafield, SIZEOF(TAESExtraData));
     CopyMemory(PAnsiChar(Files[h].extrafield), @vAES_DATA, SizeOf(TAESExtraData));
   end;
 {$ENDIF ZIP_AES}

  with Files[h].CommonFileHeader do
  begin
    VersionNeededToExtract := 20;
(*
 {$IFDEF ZIP_AES}
    if isEncr then
      begin
        CompressionMethod := 99;
        GeneralPurposeBitFlag := 1;
        CompressedSize := l + 2 + 0 + 10;
      end
     else
 {$ENDIF ZIP_AES}
*)
      begin
        CompressionMethod := 8;
        GeneralPurposeBitFlag := GeneralPurposeBitFlag and (not 1);
        FileDesc.CompressedSize := 0;
      end;
//    GeneralPurposeBitFlag := GeneralPurposeBitFlag or 2; // ZL_MAXIMUM_COMPRESSION
    LastModFileTimeDate := DateTimeToFileDate(Now);
    FileDesc.Crc32 := 0;
    FileDesc.UncompressedSize := 0;
    FilenameLength := length(Files[h].filename);
    ExtraFieldLength := length(Files[h].extrafield);
  end;

  with CentralDirectory[h] do
  begin
    CentralFileHeaderSignature := dwCentralFileHeaderSignature;
    VersionMadeBy := 20;
    CommonFileHeader := Files[h].CommonFileHeader;
    FileCommentLength := 0;
    DiskNumberStart := 0;
    InternalFileAttributes := 0;
    ExternalFileAttributes := FAttribute;
    RelativeOffsetOfLocalHeader := 0;
    filename := Files[h].filename;
    extrafield := Files[h].extrafield;
    fileComment := '';
  end;

  SetUncompressed(h, pData);
{  if Length(data) > 0 then
    begin
    end
   else
    Files[h].CompressedData := ''; //start with an empty file
}
  Result := h;
end;

function TZipFile.AddExtFile(const pFileName : String; const name: string = '';
                    FAttribute: DWord = 0; const pPass: AnsiString = ''): Integer;
var
  buf : RawByteString;
  lFN : String;
begin
  buf := loadFileA(pFileName);
  if name = '' then
    lFN := ExtractFileName(pFileName)
   else
    lFN := name;
  result := AddFile(lFN, FAttribute, pPass, buf);
  buf := '';
end;


function TZipFile.GetDateTime(i: integer): TDateTime;
begin
  if i > High(Files) then // begin Result:=0; exit; end;
    raise Exception.Create('Index out of range.');
  result := FileDateToDateTime(Files[i].CommonFileHeader.LastModFileTimeDate);
end;

procedure TZipFile.SetDateTime(i: integer; const Value: TDateTime);
begin
  if i > High(Files) then //exit;
    raise Exception.Create('Index out of range.');
  Files[i].CommonFileHeader.LastModFileTimeDate := DateTimeToFileDate(Value);
end;

function TZipFile.GetCount: integer;
begin
  Result := High(Files) + 1;
end;

function TZipFile.GetName(i: integer): string;
begin
  if Files[i].UTFSupport then
    Result := TBytesToString(Files[i].filename, CP_UTF8)
   else
    Result := TBytesToString(Files[i].filename, 437)
   ;
end;

procedure TZipFile.SetName(i: integer; const Value: string);
begin
//  Files[i].filename := Value;
  if Files[i].UTFSupport then
    Files[i].filename := StringToTBytes(Value, CP_UTF8)
   else
    Files[i].filename := StringToTBytes(Value, 437)
    ;
end;

function  TZipFile.IndexOf(const s: String): Integer;
var
  I: Integer;
//  s1 : AnsiString;
  b1, b8: TBytes;
begin
  Result := -1;
  b8 := StringToTBytes(ToZipName(s), CP_UTF8);
  b1 := StringToTBytes(ToZipName(s), 437);
// s1 := ToZipName(s);
  for I := 0 to Length(Files) - 1 do
//  if AnsiSameText(Files[i].filename, b) then
  if (Files[i].UTFSupport) then
    begin
      if (Length(Files[i].filename) = Length(b8)) and (CompareMem(Files[i].filename, b8, Length(b8))) then
       begin
        Result := i;
        Exit;
       end;
    end
   else
    begin
      if (Length(Files[i].filename) = Length(b1)) and (CompareMem(Files[i].filename, b1, Length(b1))) then
       begin
        Result := i;
        Exit;
       end;
    end

end;

function TZipFile.IsEncrypted(i: Integer): Boolean;
begin
  if i > High(Files) then // exit;
    raise Exception.Create('Index out of range.');
  Result := Files[I].CommonFileHeader.CompressionMethod=99;
end;

{ ZipCRC32 }

//calculates the zipfile CRC32 value from a string
{
function ZipCRC32(const Data: string): longword;
const
  CRCtable: array[0..255] of DWORD = (
    $00000000, $77073096, $EE0E612C, $990951BA, $076DC419, $706AF48F, $E963A535,
    $9E6495A3, $0EDB8832, $79DCB8A4,
    $E0D5E91E, $97D2D988, $09B64C2B, $7EB17CBD, $E7B82D07, $90BF1D91, $1DB71064,
    $6AB020F2, $F3B97148, $84BE41DE,
    $1ADAD47D, $6DDDE4EB, $F4D4B551, $83D385C7, $136C9856, $646BA8C0, $FD62F97A,
    $8A65C9EC, $14015C4F, $63066CD9,
    $FA0F3D63, $8D080DF5, $3B6E20C8, $4C69105E, $D56041E4, $A2677172, $3C03E4D1,
    $4B04D447, $D20D85FD, $A50AB56B,
    $35B5A8FA, $42B2986C, $DBBBC9D6, $ACBCF940, $32D86CE3, $45DF5C75, $DCD60DCF,
    $ABD13D59, $26D930AC, $51DE003A,
    $C8D75180, $BFD06116, $21B4F4B5, $56B3C423, $CFBA9599, $B8BDA50F, $2802B89E,
    $5F058808, $C60CD9B2, $B10BE924,
    $2F6F7C87, $58684C11, $C1611DAB, $B6662D3D, $76DC4190, $01DB7106, $98D220BC,
    $EFD5102A, $71B18589, $06B6B51F,
    $9FBFE4A5, $E8B8D433, $7807C9A2, $0F00F934, $9609A88E, $E10E9818, $7F6A0DBB,
    $086D3D2D, $91646C97, $E6635C01,
    $6B6B51F4, $1C6C6162, $856530D8, $F262004E, $6C0695ED, $1B01A57B, $8208F4C1,
    $F50FC457, $65B0D9C6, $12B7E950,
    $8BBEB8EA, $FCB9887C, $62DD1DDF, $15DA2D49, $8CD37CF3, $FBD44C65, $4DB26158,
    $3AB551CE, $A3BC0074, $D4BB30E2,
    $4ADFA541, $3DD895D7, $A4D1C46D, $D3D6F4FB, $4369E96A, $346ED9FC, $AD678846,
    $DA60B8D0, $44042D73, $33031DE5,
    $AA0A4C5F, $DD0D7CC9, $5005713C, $270241AA, $BE0B1010, $C90C2086, $5768B525,
    $206F85B3, $B966D409, $CE61E49F,
    $5EDEF90E, $29D9C998, $B0D09822, $C7D7A8B4, $59B33D17, $2EB40D81, $B7BD5C3B,
    $C0BA6CAD, $EDB88320, $9ABFB3B6,
    $03B6E20C, $74B1D29A, $EAD54739, $9DD277AF, $04DB2615, $73DC1683, $E3630B12,
    $94643B84, $0D6D6A3E, $7A6A5AA8,
    $E40ECF0B, $9309FF9D, $0A00AE27, $7D079EB1, $F00F9344, $8708A3D2, $1E01F268,
    $6906C2FE, $F762575D, $806567CB,
    $196C3671, $6E6B06E7, $FED41B76, $89D32BE0, $10DA7A5A, $67DD4ACC, $F9B9DF6F,
    $8EBEEFF9, $17B7BE43, $60B08ED5,
    $D6D6A3E8, $A1D1937E, $38D8C2C4, $4FDFF252, $D1BB67F1, $A6BC5767, $3FB506DD,
    $48B2364B, $D80D2BDA, $AF0A1B4C,
    $36034AF6, $41047A60, $DF60EFC3, $A867DF55, $316E8EEF, $4669BE79, $CB61B38C,
    $BC66831A, $256FD2A0, $5268E236,
    $CC0C7795, $BB0B4703, $220216B9, $5505262F, $C5BA3BBE, $B2BD0B28, $2BB45A92,
    $5CB36A04, $C2D7FFA7, $B5D0CF31,
    $2CD99E8B, $5BDEAE1D, $9B64C2B0, $EC63F226, $756AA39C, $026D930A, $9C0906A9,
    $EB0E363F, $72076785, $05005713,
    $95BF4A82, $E2B87A14, $7BB12BAE, $0CB61B38, $92D28E9B, $E5D5BE0D, $7CDCEFB7,
    $0BDBDF21, $86D3D2D4, $F1D4E242,
    $68DDB3F8, $1FDA836E, $81BE16CD, $F6B9265B, $6FB077E1, $18B74777, $88085AE6,
    $FF0F6A70, $66063BCA, $11010B5C,
    $8F659EFF, $F862AE69, $616BFFD3, $166CCF45, $A00AE278, $D70DD2EE, $4E048354,
    $3903B3C2, $A7672661, $D06016F7,
    $4969474D, $3E6E77DB, $AED16A4A, $D9D65ADC, $40DF0B66, $37D83BF0, $A9BCAE53,
    $DEBB9EC5, $47B2CF7F, $30B5FFE9,
    $BDBDF21C, $CABAC28A, $53B39330, $24B4A3A6, $BAD03605, $CDD70693, $54DE5729,
    $23D967BF, $B3667A2E, $C4614AB8,
    $5D681B02, $2A6F2B94, $B40BBE37, $C30C8EA1, $5A05DF1B, $2D02EF8D);
var
  i: integer;
begin
  result := $FFFFFFFF;
  for i := 0 to length(Data) - 1 do
    result := (result shr 8) xor (CRCtable[byte(result) xor Ord(Data[i + 1])]);
  result := result xor $FFFFFFFF;
end;
}
Function ToZipName(const FileName: String): String;
Var
 P: Integer;
Begin
  Result := FileName;
  Result := StringReplace(Result,'\','/',[rfReplaceAll]);
  P := Pos(':/',Result);
  if P > 0 Then
     Begin
       System.Delete(Result,1,P+1);
     End;
  P := Pos('//',Result);
  if P > 0 Then
     Begin
       System.Delete(Result,1,P+1);
       P := Pos('/',Result);
       if P > 0 Then
          Begin
             System.Delete(Result,1,P);
             P := Pos('/',Result);
             if P > 0 Then System.Delete(Result,1,P);
          End;
     End;
End;


Function ToDosName(const FileName: String): String;
Var
 P: Integer;
Begin
  Result := FileName;
  Result := StringReplace(Result,'\','/',[rfReplaceAll]);
  P := Pos(':/',Result);
  if P > 0 Then
     Begin
       System.Delete(Result,1,P+1);
     End;
  P := Pos('//',Result);
  if P > 0 Then
     Begin
       System.Delete(Result,1,P+1);
       P := Pos('/',Result);
       if P > 0 Then
          Begin
             System.Delete(Result,1,P);
             P := Pos('/',Result);
             if P > 0 Then System.Delete(Result,1,P);
          End;
     End;
  Result := StringReplace(Result,'/','\',[rfReplaceAll]);
End;

function CheckZipFilePass(const zipfn, fn: String; const pass: String): Boolean;
var
  zp: TZipFile;
  i: Integer;
begin
  Result := False;
  if FileExists(zipfn) then
    begin
      zp := TZipFile.Create;
      zp.LoadFromFile(zipfn);
      i := zp.IndexOf(fn);
      if i >=0 then
        begin
          if zp.IsEncrypted(i) then
            Result := zp.CheckPassword(i, pass)
           else
            Result := True;
        end;
      zp.Free;
    end;
end;

function zCompressStr(const sa: RawByteString; Level: TCompressionLevel = clMax; StreamType: TZStreamType = zsZLib): RawByteString;
var
  buf, destBuf: TMemoryStream;
begin
  if sa = '' then
    Exit('');
  buf := TMemoryStream.create;
  destBuf := TMemoryStream.create;
  buf.Write(sa[1], Length(sa));
  buf.Position := 0;
  ZlibCompressStreamEx(buf, destBuf, clMax, StreamType, false);
  buf.free;
  SetLength(Result, destBuf.Size);
  destBuf.Position := 0;
  destBuf.Read(Result[1], destBuf.Size);
  destBuf.free;
end;

function ZDecompressStr(const sa: RawByteString): RawByteString;
var
  buf, destBuf: TMemoryStream;
begin
  if sa = '' then
    Exit('');
  Buf := TMemoryStream.create;
  destBuf := TMemoryStream.create;
  buf.Write(sa[1], Length(sa));
  buf.Position := 0;
  ZlibDecompressStream(buf, destBuf);
  buf.free;
  setLength(Result, destBuf.Size);
  destBuf.Position := 0;
  CopyMemory(@Result[1], destBuf.Memory, destBuf.Size);
  destBuf.free;
end;

function ZDecompressStr3(const sa: RawByteString; StreamType: TZStreamType = zsZLib): RawByteString;
begin
  Result := ZDecompressStr(sa);
end;

function ZCompressBytes(const sa: TBytes; StreamType: TZStreamType = zsZLib): TBytes;
var
  Buf, DestBuf: TMemoryStream;
begin
  if Length(sa) = 0 then
  begin
    SetLength(Result, 0);
    Exit;
  end;
  Buf := TMemoryStream.Create;
  DestBuf := TMemoryStream.Create;
  Buf.WriteBuffer(sa[0], Length(sa));
  Buf.Position := 0;
  ZlibCompressStreamEx(Buf, DestBuf, clMax, StreamType, False);
  Buf.Free;
  SetLength(Result, DestBuf.Size);
  DestBuf.Position := 0;
  DestBuf.Read(Result[0], DestBuf.Size);
  DestBuf.Free;
end;

function ZDecompressBytes(const sa: TBytes): TBytes;
var
  Buf, DestBuf: TMemoryStream;
begin
  if Length(sa) = 0 then
  begin
    SetLength(Result, 0);
    Exit;
  end;
  Buf := TMemoryStream.create;
  DestBuf := TMemoryStream.create;
  Buf.WriteBuffer(sa[0], Length(sa));
  Buf.Position := 0;
  ZlibDecompressStream(Buf, DestBuf);
  Buf.free;
  SetLength(Result, DestBuf.Size);
  DestBuf.Position := 0;
  CopyMemory(@Result[0], DestBuf.Memory, DestBuf.Size);
  DestBuf.free;
end;


end.

