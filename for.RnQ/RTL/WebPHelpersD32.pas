unit WebpHelpersD32;

interface

uses
  Windows, SysUtils,
  Graphics,
//  GDIPAPI,
//  GDIPOBJ,
  Classes,
  libwebpD;

// Encode GUID's from https://stackoverflow.com/questions/16368575/how-to-save-an-image-to-bmp-png-jpg-with-gdi
const
  gGIf: TGUID = '{557CF402-1A04-11D3-9A73-0000F81EF32E}';
  gPNG: TGUID = '{557CF406-1A04-11D3-9A73-0000F81EF32E}';
  gPJG: TGUID = '{557CF401-1A04-11D3-9A73-0000F81EF32E}';
  gBMP: TGUID = '{557CF400-1A04-11D3-9A73-0000F81EF32E}';
  gTIF: TGUID = '{557CF405-1A04-11D3-9A73-0000F81EF32E}';

/// <summary>
///   Compress image using Webp. See https://developers.google.com/speed/webp/docs/api#simple_encoding_api for more documentation.
/// </summary>
/// <param name="stream">
///   Stream to write the image content to.
/// </param>
/// <param name="img">
///   The image to compress
/// </param>
/// <param name="quality_factor">
///   The image quality {0-100}. Default is 80.
/// </param>
function WebpEncode(var stream: TStream; img: TBitmap; quality_factor: Single = 80): Boolean; overload;

/// <summary>
///   Compress image using Webp. See https://developers.google.com/speed/webp/docs/api#simple_encoding_api for more documentation.
/// </summary>
/// <param name="buffer">
///   Buffer to write the image content to.
/// </param>
/// <param name="img">
///   The image to compress
/// </param>
/// <param name="quality_factor">
///   The image quality {0-100}. Default is 80.
/// </param>
function WebpEncode(var buffer: TBytes; img: TBitmap; quality_factor: Single = 80): Boolean; overload;

/// <summary>
///   Compress image losslessly using Webp. See https://developers.google.com/speed/webp/docs/api#simple_encoding_api for more documentation.
/// </summary>
/// <param name="stream">
///   Stream to write the image content to.
/// </param>
/// <param name="img">
///   The image to compress
/// </param>
function WebpLosslessEncode(var stream: TMemoryStream; img: TBitmap): Boolean; overload;

/// <summary>
///   Compress image losslessly using Webp. See https://developers.google.com/speed/webp/docs/api#simple_encoding_api for more documentation.
/// </summary>
/// <param name="buffer">
///   Buffer to write the image content to.
/// </param>
/// <param name="img">
///   The image to compress
/// </param>
function WebpLosslessEncode(var buffer: TBytes; img: TBitmap): Boolean; overload;

/// <summary>
///   Decode image to GDI+ Bitmap
/// </summary>
/// <param name="fs">
///   File stream to decode
/// </param>
/// <param name="data">
///   The pointer to the raw decoded data in BGRA format (32bit). YOU MUST FREE IT WITH WebPFree(data)!
/// </param>
/// <param name="bitmap">
///   The bitmap data for the image. YOU MUST FREE IT WITH bitmap.Free!
/// </param>
procedure WebpDecode(fs: TStream; var data: PByte; var bitmap : TBitmap); OverLoad;


procedure WebpDecode(fs: TStream; var bitmap : TBitmap); OverLoad;
procedure WebpDecode2(fs: TStream; var bitmap: TBitmap);

/// <summary>
///   Return version as string
/// </summary>
function GetWebpVersionString (versionhex : integer) : string;

function WebPCanBeAnimated(str: TStream): Boolean;

implementation

uses
  RDGlobal, RnQ.Graphics.Utils;

function WebpEncode(var stream: TStream; img: TBitmap; quality_factor: Single = 80): Boolean; overload;
const
  BitCounts: array [pf1Bit..pf32Bit] of Byte = (1,4,8,16,16,24,32);
var
  rect: TGPRect;
//  bmpData: BitmapData;
  ptrEncoded: PByte;
  size: Cardinal;
  bmpbuf: TBytes;
  BytesPerRow: Integer;
  i: Integer;
begin
  Result := False;
  if not libWebp_IsLoaded then
    if not libWebp_Load then
      Exit;
  // Get image size
  rect.X := 0;
  rect.Y := 0;
  rect.Width := img.Width;
  rect.height := img.Height;
  // Get image data
//  img.LockBits(rect, 3, img.GetPixelFormat, bmpData);
  // Check if image has alpha layer.
  if (not Assigned(img)) or (img.Height=0) or (img.Width = 0) then
    Exit;

  if (img.PixelFormat <> pf24bit) and (img.PixelFormat <> pf32bit) then
    img.PixelFormat := pf24bit;
  BytesPerRow := BytesPerScanline(img.Width, BitCounts[img.PixelFormat], 32);
  SetLength(bmpbuf, img.Height * BytesPerRow);
  for I := 0 to img.Height-1 do
    begin
      CopyMemory(@bmpbuf[i*BytesPerRow], img.ScanLine[i], BytesPerRow);
    end;
{
  if img.PixelFormat = pf32bit then
    size := WebPEncodeBGRA(img.ScanLine[0], img.Width, img.Height, BytesPerScanline(img.Width, 32, 32), quality_factor, ptrEncoded)
   else
    size := WebPEncodeBGR(img.ScanLine[0], img.Width, img.Height, img.Width * 3 , quality_factor, ptrEncoded);
}
  ptrEncoded := NIL;
  if img.PixelFormat = pf32bit then
    size := WebPEncodeBGRA(@bmpbuf[0], img.Width, img.Height, BytesPerRow, quality_factor, ptrEncoded)
   else
    size := WebPEncodeBGR(@bmpbuf[0], img.Width, img.Height, BytesPerRow, quality_factor, ptrEncoded);
  // Write buffer to stream
  stream.Write(ptrEncoded^, size);
  // Free buffer
  WebPFree(ptrEncoded);
  Result := True;
end;

function WebpEncode(var buffer: TBytes; img: TBitmap; quality_factor: Single = 80): Boolean; overload;
var
  stream: TMemoryStream;
begin
  // Helper to convert stream to buffer
  stream := TMemoryStream.Create;
  WebpEncode(TStream(stream), img, quality_factor);
  stream.Position := 0;
  SetLength(buffer, stream.Size);
  stream.Read(buffer, stream.Size);
  //stream.ReadData(buffer, stream.Size);
  stream.Free;
  Result := True;
end;

function WebpLosslessEncode(var stream: TMemoryStream; img: TBitmap): Boolean; overload;
var
  rect: TGPRect;
//  bmpData: BitmapData;
  ptrEncoded: PByte;
  size: Cardinal;
begin
  // Get image size
  rect.X := 0;
  rect.Y := 0;
  rect.Width := img.Width;
  rect.height := img.Height;
  // Get image data
//  img.LockBits(rect, 3, img.GetPixelFormat, bmpData);
  // Check if image has alpha layer.
  if (img.PixelFormat = pf32bit) {$IFNDEF FPC} and (img.AlphaFormat = afDefined) {$ENDIF ~FPC} then
    size := WebPEncodeLosslessBGRA(img.ScanLine[0], img.Width, img.Height, BytesPerScanline(img.Width, 32, 32), ptrEncoded)
   else
    size := WebPEncodeLosslessBGRA(img.ScanLine[0], img.Width, img.Height, img.Width * 3, ptrEncoded);
//    size := WebPEncodeLosslessBGR(bmpData.Scan0, img.GetWidth, img.GetHeight, bmpData.Stride, ptrEncoded);
  // Write buffer to stream
  stream.Write(ptrEncoded^, size);
  // Free buffer
  WebPFree(ptrEncoded);
  Result := True;
end;

function WebpLosslessEncode(var buffer: TBytes; img: TBitmap): Boolean; overload;
var
  stream : TMemoryStream;
begin
  // Helper to convert stream to buffer
  stream := TMemoryStream.Create;
  WebpLosslessEncode(stream, img);
  stream.Position := 0;
  SetLength(buffer, stream.Size);
  stream.Read(buffer, stream.Size);
  stream.Free;
  Result := True;
end;

procedure WebpDecode(fs: TStream; var data: PByte; var bitmap: TBitmap);
type
   TBitmapInfo4 = packed record
      bmiHeader: TBitmapV4Header;
      bmiColors: array[0..0] of TRGBQuad;
   end;
var
  buffer: TBytes;
  width, height: integer;
  // Load to image
  BitmapInfo: TBitmapInfo4;
//  IconInfo: TIconInfo;
  AlphaBitmap: HBitmap;
//     MaskBitmap: TBitmap;
//  X, Y: Integer;
  cpy: PByte;
//     AlphaLine: PByteArray;
//     HasAlpha, HasBitmask: Boolean;
//     Color, TransparencyColor: TColor;
//     PB: PColor32;
begin

  fs.Position := 0;
  setlength(buffer, fs.Size);
  fs.ReadBuffer(buffer, fs.size);
  cpy := WebPDecodeARGB(@buffer[0], fs.Size, @width, @height);
  // Free buffer
  setlength(buffer, 0);

  if cpy <> NIL then
    begin
      data := AllocMem(width*height*4);
      CopyMemory(data, cpy, width*height*4);
      WebPFree(cpy);

      //Convert a PNG object to an alpha-blended icon resource
    //  ImageBits := nil;

      //Allocate a DIB for the color data and alpha channel
      with BitmapInfo.bmiHeader do
      begin
         bV4Size := SizeOf(BitmapInfo.bmiHeader);
         bV4Width := Width;
         bV4Height := Height;
         bV4Planes := 1;
         bV4BitCount := 32;
         bV4V4Compression := BI_BITFIELDS;
         bV4SizeImage := 0;
         bV4XPelsPerMeter := 0;
         bV4YPelsPerMeter := 0;
         bV4ClrUsed := 0;
         bV4ClrImportant := 0;
         bV4RedMask := $00FF0000;
         bV4GreenMask := $0000FF00;
         bV4BlueMask := $000000FF;
         bV4AlphaMask := $FF000000;
         end;
     {$IFDEF FPC}
      AlphaBitmap := CreateDIBSection(0, Windows.PBITMAPINFO(@BitmapInfo)^, DIB_RGB_COLORS, Pointer(data), 0, 0);
      bitmap := TBitmap.Create;
      bitmap.SetSize(width, height);
     {$ELSE ~FPC}
      AlphaBitmap := CreateDIBSection(0, PBitmapInfo(@BitmapInfo)^, DIB_RGB_COLORS, Pointer(data), 0, 0);
      bitmap := TBitmap.Create(width, height);
     {$ENDIF FPC}

      bitmap.Handle := AlphaBitmap;
     {$IFNDEF FPC}
      bitmap.AlphaFormat := afDefined;
     {$ENDIF ~FPC}
    end;
end;

procedure WebpDecode2(fs: TStream; var bitmap: TBitmap);
type
   TBitmapInfo4 = packed record
      bmiHeader: TBitmapV4Header;
      bmiColors: array[0..0] of TRGBQuad;
   end;
var
  buffer: TBytes;
  lb: Pointer;
  width, height: integer;
  // Load to image
  bmpbuf: TBytes;
//  BitmapInfo: TBitmapInfo4;
//  IconInfo: TIconInfo;
//  AlphaBitmap: HBitmap;
//     MaskBitmap: TBitmap;
  X, Y: Integer;
//     AlphaLine: PByteArray;
//     HasAlpha, HasBitmask: Boolean;
//     Color, TransparencyColor: TColor;
//     PB: PColor32;
  pb: Pointer;
  buf: Pointer;
begin

  fs.Position := 0;
  if fs is TMemoryStream then
    lb := (fs as TMemoryStream).Memory
   else
    begin
      setlength(buffer, fs.Size);
      fs.ReadBuffer(buffer, fs.size);
      lb := @buffer[0];
    end;
  x := WebPGetInfo(lb, fs.Size, @width, @height);
  if (x <> 0) and (height > 0) and (width > 0) then
    begin
      SetLength(bmpbuf, width*height*4);
      pb := WebPDecodeBGRAInto(PByte(lb), fs.Size, @bmpbuf[0], Length(bmpbuf), width*4);
      if (pb <> NIL) then
        begin
          if Assigned(bitmap) then
            bitmap.SetSize(width, height)
           else
            begin
             {$IFDEF FPC}
              bitmap := TBitmap.Create;
              bitmap.SetSize(width, height);
             {$ELSE ~FPC}
              bitmap := TBitmap.Create(width, height);
             {$ENDIF ~FPC}
            end;
          bitmap.PixelFormat := pf32bit;
         {$IFNDEF FPC}
          bitmap.AlphaFormat := afDefined;
         {$ENDIF ~FPC}
          for y := 0 to height-1 do
            begin
             buf := Pointer(PtrUInt(@bmpbuf[0]) + y*width*4);
             CopyMemory(bitmap.ScanLine[y], buf, width*4);
            end;
          Premultiply(bitmap);
        end;
      SetLength(bmpbuf, 0);
    end;

  // Free buffer
  setlength(buffer, 0);
end;

procedure WebpDecode(fs: TStream; var bitmap : TBitmap);
var
  data: PByte;
begin
  WebpDecode(fs, data, bitmap);
//  WebPFree(data);
//  FreeMem(data);
end;

function GetWebpVersionString (versionhex: integer) : string;
var
  maj, min, patch : integer;
begin
  // Determine version
  // Format for version is hex, where first 2 hex is maj, second min, third patch
  // E.g: v2.5.7 is 0x020507
  maj := versionhex div $10000;
  min := (versionhex - (maj * $10000)) div $100;
  patch := (versionhex - (maj * $10000) - (min * $100));
  result := maj.ToString + '.' + min.ToString + '.' + patch.ToString;
end;

function ArrayToAnsiString(const a: array of AnsiChar;
  len: Integer = 0; start: Integer = 0): RawByteString;
var
  i: Integer;
begin
  if len = 0 then
  begin
    len:= Length(a);
    for i:= start to High(a) do
      if a[i] = #0 then
      begin
        len:= i;
        break;
      end;
  end;
  if len > 0 then
    SetString(Result, PAnsiChar(@a[start]), len)
  else
    Result := '';
end;

function WebPCanBeAnimated(str: TStream): Boolean;
var
//  Stream: TFileStream;
  fourcc: array[0..3] of AnsiChar;
  chunksize: Cardinal;
  icount: Integer;
begin
  Result := false;
  if not Assigned(str) or (str.Size < 8) then
    exit;
  try
    str.Seek(8, soBeginning);
    str.Read(fourcc, 4);
    icount:= 0;
    if ArrayToAnsiString(fourcc) <> 'WEBP' then
      exit;
    str.Read(fourcc, 4);
    if ArrayToAnsiString(fourcc) <> 'VP8X' then
      exit;
    repeat
      str.Read(chunksize, 4);
      if chunksize mod 2 <> 0 then
        Inc(chunksize);
      if (fourcc = 'VP8 ') or (fourcc = 'VP8L') then
      begin
        if chunksize = 0 then
          exit;
        Inc(icount);
        if icount = 2 then
        begin
          Result:= true;
          exit;
        end;
      end;
      if fourcc = 'ANMF' then
        str.Seek(16, soCurrent)
      else
        str.Seek(chunksize, soCurrent);
      if str.Position < str.Size - 4 then
        str.Read(fourcc, 4);
    until str.Position >= str.Size - 4;
  finally
  end;
end;


end.
