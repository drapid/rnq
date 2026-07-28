{
  This file is part of R&Q.
  Under same license
}
unit RDGlobal;
{$I ..\ForRnQConfig.inc}
{$I ..\NoRTTI.inc}

 { $ DEFINE RNQ_PLAYER}
 {$IF DEFINED(VCL) OR DEFINED(RNQ)}
  {$DEFINE UI}
 {$IFEND VCL}

interface
uses
  Classes, Types,
  Messages,
  System.UITypes,
 {$IFDEF UI}
  {$IFDEF FMX}
  FMX.Forms,
  FMX.Objects
  {$ELSE ~FMX}
  Forms,
  ExtCtrls,
  Graphics,
  {$ENDIF FMX}
 {$ENDIF UI}
  SysUtils
  ;

{ ************ common types used for compatibility between compilers and CPU }

{$ifndef FPC} { make cross-compiler and cross-CPU types available to Delphi }
type

  /// a CPU-dependent unsigned integer type cast of a pointer / register
  // - used for 64 bits compatibility, native under Free Pascal Compiler
{$ifdef ISDELPHI2009}
  PtrUInt = cardinal; { see http://synopse.info/forum/viewtopic.php?id=136 }
{$else}
  PtrUInt = {$ifdef UNICODE}NativeUInt{$else}cardinal{$endif};
{$endif}
  /// a CPU-dependent unsigned integer type cast of a pointer of pointer
  // - used for 64 bits compatibility, native under Free Pascal Compiler
  PPtrUInt = ^PtrUInt;

  /// a CPU-dependent signed integer type cast of a pointer / register
  // - used for 64 bits compatibility, native under Free Pascal Compiler
  PtrInt = {$ifdef UNICODE}NativeInt{$else}integer{$endif};
  /// a CPU-dependent signed integer type cast of a pointer of pointer
  // - used for 64 bits compatibility, native under Free Pascal Compiler
  PPtrInt = ^PtrInt;

  /// unsigned Int64 doesn't exist under older Delphi, but is defined in FPC
  QWord = {$ifdef UNICODE}UInt64{$else}Int64{$endif};

{$ifNdef COMPILER16_UP}
//  INT_PTR = System.IntPtr;    // NativeInt;
  INT_PTR = NativeInt;
  {$EXTERNALSYM INT_PTR}
//  UINT_PTR = System.UIntPtr;  // NativeUInt;
  UINT_PTR = NativeUInt;
  UIntPtr = UINT_PTR;
  {$EXTERNALSYM UINT_PTR}
  PINT_PTR = ^INT_PTR;
  {$EXTERNALSYM PINT_PTR}
  PUINT_PTR = ^UINT_PTR;
  {$EXTERNALSYM PUINT_PTR}
{$ENDIF}

{$endif}


type
 {$IFNDEF UNICODE}
  {$IFNDEF FPC}
  RawByteString = AnsiString;
  {$ENDIF ~FPC}
 {$ENDIF UNICODE}
  TPicName = AnsiString;
//  TPicName = String;
  TPicNameW = WideString;

  TStrObj = class(TObject)
   public
    str: String;
  end;
  TPStrObj = Class(TObject)
   public
    Str: PAnsiChar;
  end;

  TPUStrObj = Class(TObject)
   public
    Str: PChar;
  end;

 {$IFDEF UI}
  TRnQPntBox = class(TPaintBox)
{$IFNDEF FMX}
  protected
//    procedure WMPaint(var Msg: TWMPaint); message WM_PAINT;
    procedure WMEraseBkgnd(var Msg: TWmEraseBkgnd); message WM_ERASEBKGND;
{$ENDIF ~FMX}
  public
    constructor Create(AOwner: TComponent); override;
//    procedure PaintImages;
  end;
 {$ENDIF UI}

type
  PColor32 = ^TColor32;
 {$IFDEF FPC}
  TColor32 = packed record
   case boolean of
    True:
      (B,R,G,A: Byte);
//      (B,G,R,A: Byte);
    false:
      (color : Cardinal);
//   end;
  end;
 {$ELSE ~FPC}
  TColor32 = TAlphaColorRec;
 {$ENDIF}
  PColor32Array = ^TColor32Array;
  TColor32Array = array [0..MaxInt div SizeOf(TColor32) - 1] of TColor32;


  PColor24 = ^TColor24;

  TColor24= packed record
    B,R,G: Byte;
  end;
  PColor24Array = ^TColor24Array;
  TColor24Array = array [0..MaxInt div SizeOf(TColor24) - 1] of TColor24;


type
  PGPPoint = ^TGPPoint;
  TGPPoint = packed record
    X: Integer;
    Y: Integer;
  end;
  TPointDynArray = array of TGPPoint;

  function MakePoint(p2: TPoint): TGPPoint; {$IFDEF HAS_INLINE} inline; {$ENDIF HAS_INLINE}
//  function MakePoint(X, Y: Integer): TGPPoint; overload;

//--------------------------------------------------------------------------
// Represents a dimension in a 2D coordinate system (integer coordinates)
//--------------------------------------------------------------------------

type
  PGPSize = ^TGPSize;
  TGPSize = packed record
    Width: Integer;
    Height: Integer;
    constructor create(Width, Height: Integer);
    function asTSize: TSize;
    function ToPPI(PPI: Integer): TGPSize; OverLoad;
    function ToPPI(PPI: Integer; selfDPI: Integer): TGPSize; OverLoad;
  end;

  function MakeSize(sz2: TSize): TGPSize; {$IFDEF HAS_INLINE} inline; {$ENDIF HAS_INLINE}
  function GetSize(sz1: TGPSize): TSize; {$IFDEF HAS_INLINE} inline; {$ENDIF HAS_INLINE}
//  function MakeSize(Width, Height: Integer): TGPSize; overload;

type
  PGPRect = ^TGPRect;
  TGPRect = packed record
     function rect: TRect;
      case Integer of
      0: (X, Y, Width, Height: Integer);
      1: (TopLeft : TGPPoint; size: TGPSize);
  end;
  TRectDynArray = array of TGPRect;

  function MakeRect(x, y, width, height: Integer): TGPRect; overload; {$IFDEF HAS_INLINE} inline; {$ENDIF HAS_INLINE}
  function MakeRect(location: TGPPoint; size: TGPSize): TGPRect; overload; {$IFDEF HAS_INLINE} inline; {$ENDIF HAS_INLINE}
  function MakeRect(const Rect: TRect): TGPRect; overload; {$IFDEF HAS_INLINE} inline; {$ENDIF HAS_INLINE}

 {$IFNDEF FMX}
type
//  TMsgDlgType = (mtWarning, mtError, mtInformation, mtConfirmation, mtCustom);
  {$IFDEF RNQ}
  TMsgDlgType = (mtWarning, mtError, mtInformation, mtConfirmation, mtBuzz, mtCustom);
  {$ELSE !RNQ}
  TMsgDlgType    = System.UITypes.TMsgDlgType;
  {$ENDIF RNQ}
  TMsgDlgTypes = set of TMsgDlgType;
{
  TMsgDlgBtn = (mbYes, mbNo, mbOK, mbCancel, mbAbort, mbRetry, mbIgnore,
    mbAll, mbNoToAll, mbYesToAll, mbHelp, mbClose);
  TMsgDlgButtons = set of TMsgDlgBtn;
}
  TMsgDlgBtn = System.UITypes.TMsgDlgBtn;
  TMsgDlgButtons = System.UITypes.TMsgDlgButtons;
 {$ENDIF ~FMX}

type
  TPAFormat = (PA_FORMAT_UNK, PA_FORMAT_BMP, PA_FORMAT_JPEG,
               PA_FORMAT_GIF, PA_FORMAT_PNG, PA_FORMAT_XML,
               PA_FORMAT_SWF, PA_FORMAT_ICO,
               PA_FORMAT_TIF, PA_FORMAT_WEBP, PA_FORMAT_HEIF, PA_FORMAT_HEIC, // From WIC
               PA_FORMAT_JPEGXL
               );

const
  PAFormat: array [TPAFormat] of string = ('.dat','.bmp','.jpeg','.gif','.png', '.xml', '.swf', '.ico', '.tif', '.webp', '.heif', '.heic', '.jxl');
  PAFormatString: array [TPAFormat] of string = ('Unknown', 'Bitmap', 'JPEG', 'GIF', 'PNG', 'XML', 'SWF', 'ICON', 'TIF', 'WEBP', 'HEIF', 'HEIC', 'JPEG-XL');
  PAFormatMime: array [TPAFormat] of string = ('image/x-icon', 'image/bmp', 'image/jpeg',
          'image/gif','image/png', 'text/xml', 'application/x-shockwave-flash', 'image/x-icon',
          'image/tiff', 'image/webp', 'image/heif', 'image/heic',
          'image/jxl');

  notCompressableExt: array of String = ['.7z', '.zip', '.rar', '.xlsx', '.docx', '.xz', '.mp3', '.mp4', '.mkv', '.ogg', '.webm', '.jpg', '.jpeg', '.png', '.webp', '.heic', '.jxl', '.heif'];

const
  CrLf           = AnsiString(#13#10);
  CrLfS          = #13#10;
//  CRLFA: AnsiString = AnsiString(#13#10);
  CRLFCRLF  = AnsiString(CRLF+CRLF);
//  CRLFCRLF: AnsiString = AnsiString(CRLF+CRLF);
//  CRLFCRLF: AnsiString = AnsiString(#13#10#13#10);
  NL = #10;
  HexChars = ['A'..'F', 'a'..'f', '0'..'9'];
//  yesno: array [boolean] of AnsiString=('No','Yes');
  yesnoLower: array [boolean] of AnsiString=('no','yes');
  Def_DateTimeFormat = 'DD.MM.YYYY HH:NN:SS';
  Def_DateFormat     = 'DD.MM.YYYY';

const
  GByte = 1024*1024*1024;
  MByte = 1024*1024;

const
  AlphaMask = $FF000000;
  cDefaultDPI = 96;

var
//  myPath: String;
  ShellVersion: Cardinal;

const
 // Windows resourses!!!!!!!!
  PIC_EXCLAMATION                 = TPicName('exclamation');
  PIC_HAND                        = TPicName('hand');
  PIC_ASTERISK                    = TPicName('asterisk');
  PIC_QUEST                       = TPicName('question');

  function  PicName2Str(val: TPicName): String; {$IFDEF HAS_INLINE} inline; {$ENDIF HAS_INLINE}

 {$IFDEF FMX}
  function MulDiv(nNumber, nNumerator, nDenominator: Integer): Integer;
 {$ENDIF FMX}

 {$IFNDEF USE_MORMOT}
type
 TRawByteStringStream = class(TStream)
  protected
    fPosition: Int64;
    fDataString: RawByteString;
    function GetSize: Int64; override;
    procedure SetSize(NewSize: Longint); override;
    {$ifdef FPC}
    function GetPosition: Int64; override;
    {$endif FPC}
  public
    /// initialize the storage, optionally with some RawByteString content
    // - to be used for Read() from this memory buffer
    constructor Create(const aString: RawByteString); overload;
    /// read some bytes from the internal storage
    // - returns the number of bytes filled into Buffer (<=Count)
    function Read(var Buffer; Count: Longint): Longint; override;
    /// append some data to the buffer
    // - will resize the buffer, i.e. will replace the end of the string from
    // the current position with the supplied data
    function Write(const Buffer; Count: Longint): Longint; override;
    /// reset the internal DataString content and the current position
    procedure Clear;
      {$ifdef HASINLINE}inline;{$endif}
    /// change the current Read/Write position, within current GetSize
    function Seek(const Offset: Int64; Origin: TSeekOrigin): Int64; override;
    /// generic override calling the 64-bit Seek() overload
    function Seek(Offset: Longint; Origin: Word): Longint; override;
    /// direct low-level access to the internal RawByteString storage
    property DataString: RawByteString
      read fDataString write fDataString;
  end;
 {$ENDIF !USE_MORMOT}

implementation

{$IFNDEF FMX}
   uses
     Windows
  {$IFDEF UI}
     , Controls
  {$ENDIF UI}
     ;
{$ENDIF ~FMX}

 {$IFDEF UI}
constructor TRnQPntBox.Create(AOwner: TComponent);
begin
  inherited;
//  ControlStyle := ControlStyle + [ csOpaque ] ;
end;

{$IFNDEF FMX}
procedure TRnQPntBox.WMEraseBkgnd(var Msg: TWmEraseBkgnd);
Begin
//  inherited;
//   msg.Result := 1;
   msg.Result := LRESULT(False);
   msg.Msg := 0;
end;
{$ENDIF FMX}
 {$ENDIF UI}

{$IFDEF FMX}
function MathRound(AValue: Extended): Int64; inline;
begin
  if AValue >= 0 then
    Result := Trunc(AValue + 0.5)
  else
    Result := Trunc(AValue - 0.5);
end;

function MulDiv(nNumber, nNumerator, nDenominator: Integer): Integer;
begin
  if nDenominator = 0 then
    Result := -1
  else
    Result := MathRound(Int64(nNumber) * Int64(nNumerator) / nDenominator);
end;
{$ENDIF FMX}

  function MakePoint(p2: TPoint): TGPPoint;
  begin
    Result.X := p2.X;
    Result.Y := p2.Y;
  end;

  function MakeSize(sz2: TSize): TGPSize;
  begin
    Result.Width := sz2.cx;
    Result.Height := sz2.cy;
  end;

  function GetSize(sz1: TGPSize): TSize;
  begin
    Result.cx := sz1.Width;
    Result.cy := sz1.Height;
  end;

  constructor TGPSize.create(Width, Height: Integer);
  begin
    Self.Width := Width;
    Self.Height := Height;
  end;

  function TGPSize.asTSize: TSize;
  begin
    Result.cx := Width;
    Result.cy := Height;
  end;

  function TGPSize.ToPPI(PPI: Integer): TGPSize;
  begin
    if (PPI > 30) and (PPI <> cDefaultDPI) then
      begin
        Result.Width := MulDiv(Self.Width, PPI, cDefaultDPI);
        Result.Height := MulDiv(Self.Height, PPI, cDefaultDPI);
      end
     else
      begin
        Result.Width := Self.Width;
        Result.Height := Self.Height;
      end
  end;

  function TGPSize.ToPPI(PPI: Integer; selfDPI: Integer): TGPSize;
  var
    lDPI: Integer;
  begin
    if (selfDPI > 20) then
      lDPI := selfDPI
     else
      lDPI := cDefaultDPI;

    if (PPI > 30) and (PPI <> lDPI) then
      begin
        Result.Width := MulDiv(Self.Width, PPI, lDPI);
        Result.Height := MulDiv(Self.Height, PPI, lDPI);
      end
     else
      begin
        Result.Width := Self.Width;
        Result.Height := Self.Height;
      end
  end;

function TGPRect.rect: TRect;
begin
  Result.Left := Self.X;
  Result.Top  := Self.Y;
  Result.Right:= Self.X + Self.Width;
  Result.Bottom := Self.Y + Self.Height;
end;

  function MakeRect(x, y, width, height: Integer): TGPRect; {$IFDEF HAS_INLINE} inline; {$ENDIF HAS_INLINE}
  begin
    Result.X      := x;
    Result.Y      := y;
    Result.Width  := width;
    Result.Height := height;
  end;

  function MakeRect(location: TGPPoint; size: TGPSize): TGPRect; {$IFDEF HAS_INLINE} inline; {$ENDIF HAS_INLINE}
  begin
//    Result.X      := location.X;
//    Result.Y      := location.Y;
    Result.TopLeft := location;
//    Result.Width  := size.Width;
//    Result.Height := size.Height;
    Result.size := size;
  end;

  function MakeRect(const Rect: TRect): TGPRect; {$IFDEF HAS_INLINE} inline; {$ENDIF HAS_INLINE}
  begin
    Result.X := rect.Left;
    Result.Y := Rect.Top;
    Result.Width := Rect.Right-Rect.Left;
    Result.Height:= Rect.Bottom-Rect.Top;
  end;

function  PicName2Str(val: TPicName): String; {$IFDEF HAS_INLINE} inline; {$ENDIF HAS_INLINE}
begin
//  if TPicName is AnsiString then
    Result := String(val);
end;

{$IFNDEF USE_MORMOT}
{$ifdef FPC}
function TRawByteStringStream.GetPosition: Int64;
begin
  result := fPosition;
end;
{$endif FPC}

function TRawByteStringStream.Seek(const Offset: Int64; Origin: TSeekOrigin): Int64;
var
  size: Int64;
begin
  if (Offset <> 0) or
     (Origin <> soCurrent) then
  begin
    size := GetSize;
    case Origin of
      soBeginning:
        result := Offset;
      soEnd:
        result := size - Offset;
    else
      result := fPosition + Offset; // soCurrent
    end;
    if result > size then
      result := size
    else if result < 0 then
      result := 0;
    fPosition := result;
  end
  else
    // optimize for Delphi with no GetPosition method but Seek(0,soCurrent) call
    result := fPosition;
end;

function TRawByteStringStream.Seek(Offset: Longint; Origin: Word): Longint;
begin
  result := Seek(Offset, TSeekOrigin(Origin)); // call the 64-bit version above
end;

{ TRawByteStringStream }

constructor TRawByteStringStream.Create(const aString: RawByteString);
begin
  fDataString := aString;
  fPosition := 0;
end;

function TRawByteStringStream.Read(var Buffer; Count: Longint): Longint;
begin
  if Count <= 0 then
    result := 0
  else
  begin
    result := Length(fDataString) - fPosition;
    if result = 0 then
      exit;
    if result > Count then
      result := Count;
    Move(fDataString[fPosition+1], Buffer, result);
    inc(fPosition, result);
  end;
end;

function TRawByteStringStream.GetSize: Int64;
begin
  // faster than the TStream inherited method calling Seek() twice
  result := length(fDataString);
end;

procedure TRawByteStringStream.SetSize(NewSize: Longint);
begin
  SetLength(fDataString, NewSize);
  if fPosition > NewSize then
    fPosition := NewSize;
end;

function TRawByteStringStream.Write(const Buffer; Count: Longint): Longint;
var
  needed: PtrInt;
  p: PByte;
begin
  result := Count;
  if result <= 0 then
    exit;
  needed := fPosition + result;
  if needed > length(fDataString) then
    SetLength(fDataString, needed); // resize
  p := @fDataString[fPosition+1];
  Move(Buffer, p^, result);
  fPosition := needed;
end;

procedure TRawByteStringStream.Clear;
begin
  fPosition := 0;
  fDataString := '';
end;

{$ENDIF !USE_MORMOT}

end.
