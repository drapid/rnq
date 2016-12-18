unit RnQGraphics32;
{$I ForRnQConfig.inc}
{$I NoRTTI.inc}

{ $DEFINE DELPHI9_UP}
{$IFDEF FPC}
  {$DEFINE TransparentStretchBltMissing}
  {$DEFINE CopyPaletteMissing}
{$ENDIF}

interface

uses
  Messages, Windows, SysUtils, Types, Classes,
  Graphics,
  Forms,
  Controls,
 {$IFDEF RNQ}
  RDFileUtil,
 {$ENDIF RNQ}
  RDGlobal
  ;


{$IFDEF FPC}
const
  //gdi32 = 'gdi32.dll';
  msimg32 = 'msimg32.dll';
{$ENDIF FPC}

type
  TGradientDirection = (gdVertical, gdHorizontal);
type
  TPAFormat = (PA_FORMAT_UNK, PA_FORMAT_BMP, PA_FORMAT_JPEG,
               PA_FORMAT_GIF, PA_FORMAT_PNG, PA_FORMAT_XML,
               PA_FORMAT_SWF, PA_FORMAT_ICO,
               PA_FORMAT_TIF, PA_FORMAT_WEBP // From WIC
               );

const
  PAFormat: array [TPAFormat] of string = ('.dat','.bmp','.jpeg','.gif','.png', '.xml', '.swf', '.ico', '.tif', '.webp');
  PAFormatString: array [TPAFormat] of string = ('Unknown', 'Bitmap', 'JPEG', 'GIF', 'PNG', 'XML', 'SWF', 'ICON', 'TIF', 'WEBP');
  PAFormatMime: array [TPAFormat] of string = ('image/x-icon', 'image/bmp', 'image/jpeg',
          'image/gif','image/png', 'text/xml', 'application/x-shockwave-flash', 'image/x-icon', 'image/tiff', 'image/webp');

type
  TAniDisposalType = (dtUndefined,   {Take no action}
                   dtDoNothing,   {Leave graphic, next frame goes on top of it}
                   dtToBackground,{restore original background for next frame}
                   dtToPrevious); {restore image as it existed before this frame}
  TRnQPicState = (PS_HAS_ORIGIN, PS_INIT_PICS);
  TRnQPicStates = set of TRnQPicState;

  TAniFrame = class
  private
    { private declarations }
    frLeft: Integer;
    frTop: Integer;
    frWidth: Integer;
    frHeight: Integer;

    frDelay: Integer;
    frDisposalMethod: TAniDisposalType;
    TheEnd: boolean;    {end of what gets copied}

    IsCopy: boolean;

  Public
    constructor Create;       
    constructor CreateCopy(Item: TAniFrame);
//    destructor Destroy; override;
  end;

  TAniFrameList = class(TList)
  private
    function GetFrame(I: Integer): TAniFrame;
  public
    {note: Frames is 1 based, goes from [1..Count]}
    property Frames[I: Integer]: TAniFrame read GetFrame; default;
  end;

//--------------------------------------------------------------------------
// Represents a location in a 2D coordinate system (integer coordinates)
//--------------------------------------------------------------------------


type
  TRnQBitmap = class
   protected
    fHI:  HICON;
//    fBmp32: TBitmap32;
    FNumFrames: Integer;
    FCurrentFrame: Integer;
    FNumIterations: Integer;

    fFrames: TAniFrameList;

    WasDisposal: TAniDisposalType;
    CurrentIteration: Integer;
    LastTime: DWord;
    CurrentInterval: DWord;
    OriginalFile: TMemoryStream;
    FState  : TRnQPicStates;
   public
    fBmp    : TBitmap;
    htMask  : TBitmap;
    htTransparent: boolean; // is Has Mask
    fTransparentColor: COLORREF;
    f32Alpha: Boolean;
    fFormat : TPAFormat;
    fWidth  : Integer;
    fHeight : Integer;
    fDPI    : Integer;
   private
    fAnimated: Boolean;
//    procedure Draw32bit(DC: HDC; DX, DY: Integer);
    procedure SetCurrentFrame(AFrame: Integer);
    procedure NextFrame(OldFrame: Integer);
   public
    constructor Create; overload;
    constructor Create(Width, Heigth: Integer); Overload;
    constructor Create(fn: String); Overload;
    constructor Create(hi: HICON); Overload;
    destructor  Destroy; override;
    procedure   Clear;
    procedure   MakeEmpty;
    procedure   loadFromStream(stream: TStream);
//    procedure   Free; overload;
//    function  loadPic(fn: string): Tbitmap;

    procedure MaskDraw(DC: HDC; const DestBnd, SrcBnd: TGPRect); Overload;
    procedure MaskDraw(DC: HDC; const DX, DY: Integer); Overload;
    procedure Draw(DC: HDC; DX, DY: Integer); Overload;
//    procedure Draw(DC: HDC; DestR: TRect; SrcX, SrcY, SrcW, SrcH: Integer; pEnabled: Boolean= True; isCopy : Boolean= false); Overload;
    procedure Draw(DC: HDC; DestBnd, SrcBnd: TGPRect; pEnabled: Boolean= True; isCopy32: Boolean = false); Overload;
//    procedure Draw(DC: HDC; DestR, SrcR: TRect); Overload;
    procedure Draw(DC: HDC; DestR: TGPRect); Overload;
//    function  Clone(x, y, pWidth, pHeight: Integer): TRnQBitmap;
    function  Clone(bnd: TGPRect): TRnQBitmap;
    function  CloneFrame(frame: Integer): TRnQBitmap;
    procedure SetTransparentColor(clr: cardinal);
    function  bmp2ico32: HIcon;
    procedure GetHICON(var hi: HICON);
    function  GetWidth: Integer; {$IFDEF HAS_INLINE}inline; {$ENDIF HAS_INLINE}
    function  GetHeight: Integer; {$IFDEF HAS_INLINE}inline; {$ENDIF HAS_INLINE}
    function  GetSize(PPI: Integer): TSize;
    function  RnQCheckTime: Boolean;
    property  Animated: Boolean read fAnimated;
    property  NumFrames: Integer read FNumFrames;
    property  Width: integer read fWidth;
    property  Height: integer read FHeight;
    property  CurrentFrame: Integer read FCurrentFrame write SetCurrentFrame;
    property  picDPI: Integer read fDPI;
  end;

   procedure DrawRbmp(DC: HDC; VAR bmp: TRnQBitmap; DestR, SrcR: TGPRect); OverLoad; {$IFDEF HAS_INLINE}inline; {$ENDIF HAS_INLINE}
   procedure DrawRbmp(DC: HDC; VAR bmp: TRnQBitmap; DestR: TGPRect; Bound: Boolean = True); OverLoad; {$IFDEF HAS_INLINE}inline; {$ENDIF HAS_INLINE}
   procedure DrawRbmp(DC: HDC; VAR bmp: TRnQBitmap); OverLoad; {$IFDEF HAS_INLINE}inline; {$ENDIF HAS_INLINE}
   procedure DrawRbmp(DC: HDC; VAR bmp: TRnQBitmap; X, Y: Integer); OverLoad; {$IFDEF HAS_INLINE}inline; {$ENDIF HAS_INLINE}
//    procedure DrawRbmp(DC: HDC; VAR bmp: TRnQBitmap; DestRect : TRect; SrcX, SrcY, SrcW, SrcH: Integer; pEnabled: Boolean= True); OverLoad; inline;
   procedure DrawRbmp(DC: HDC; VAR bmp: TRnQBitmap; DestR, SrcR: TGPRect;
                       pEnabled: Boolean= True; isCopy: Boolean = false); OverLoad; {$IFDEF HAS_INLINE}inline; {$ENDIF HAS_INLINE}

   function  loadPic(const fn: string; var bmp: TRnQBitmap; idx: Integer = 0): Boolean; Overload;
   function  loadPic(var str0: TStream; var bmp: TRnQBitmap; idx: Integer = 0;
                     ff: TPAFormat = PA_FORMAT_UNK; name: string = '';
                     PreserveStream: Boolean = false): Boolean; Overload;
 {$IFDEF RNQ}
   function  loadPic(pt: TThemeSourcePath; fn: string; var bmp: TRnQBitmap; idx: Integer = 0): boolean; overload;
 {$ENDIF RNQ}

   function  loadPic2(const fn: string; var bmp: TRnQBitmap): boolean; // if not loaded then bmp is nil!
   procedure BeginPicsMassLoad;
   procedure EndPicsMassLoad;

{   //function  loadPic(fn: string; bmp: Tbitmap): boolean; overload;
    function  loadPic(fn: string; bmp: Tbitmap; idx: Integer = 0): boolean; overload;
    function  loadPic(fn: string; img: Timage): boolean; overload;
    function  loadPic(fn: string; var bmp: TGpBitmap; idx: Integer = 0): boolean; overload;
    function  loadPic(fs: TStream; bmp: Tbitmap; idx: Integer = 0; name : string = ''):boolean; overload;
    //function  loadPic(fs: TStream; var bmp: TGPbitmap; idx: Integer = 0): boolean; overload;
    function  loadPic(fs: TStream; var bmp: TGPbitmap; idx: Integer = 0; name: string = ''):boolean; overload;
    //procedure loadIco(fn: string; var result: Ticon);
}

    function  isSupportedPicFile(fn: string): boolean;
    function  getSupPicExts: String;
    function  DetectFileFormatStream(str: TStream): TPAFormat;
  procedure  StretchPic(var bmp: TBitmap; maxH, maxW: Integer); overload;
  procedure  StretchPic(var bmp: TRnQBitmap; maxH, maxW: Integer); overload;

  procedure SmoothRotate(var Src, Dst: TBitmap; cx, cy: Integer; Angle: Extended);

  procedure FillGradient(DC: HDC; ARect: TRect; //ColorCount: Integer;
    StartColor, EndColor: Cardinal; ADirection: TGradientDirection; Alpha: Byte = $FF);
  {$IFNDEF DELPHI9_UP}
  function WinGradientFill(DC: HDC; Vertex: PTriVertex; NumVertex: ULONG; Mesh: Pointer; NumMesh, Mode: ULONG): BOOL; stdcall;
  {$ENDIF DELPHI9_UP}
  procedure FillRoundRectangle(DC: HDC; ARect: TRect; Clr: Cardinal; rnd: Word);
//  Procedure FillRectangle(DC: HDC; ARect: TRect; Clr : Cardinal);
  procedure DrawTextTransparent(DC: HDC; x, y: Integer; Text: String; Font: TFont; Alpha: Byte; fmt: Integer);
 {$IFDEF DELPHI9_UP}
  procedure DrawText32(DC: HDC; TextRect: TRect; Text: String; Font: TFont; TextFlags: Cardinal);
 {$ENDIF DELPHI9_UP}
 {$IFNDEF NO_WIN98}
  procedure DrawTransparentBitmap(dc: HDC; DrawBitmap: HBitmap; DestBnd: TGPRect; srcW, srcH: Integer; cTransparentColor: COLORREF);
 {$ENDIF NO_WIN98}

  function wbmp2bmp(Stream: TStream; var pic: TBitmap; CalcOnly: Boolean = False): TSize;

  function  createBitmap(dx, dy: integer; PPI: Integer = cDefaultDPI): Tbitmap; overload;
  function  createBitmap(cnv: Tcanvas): Tbitmap; overload;


// Color
type
  Thls = record h,l,s: double; end; // H=[0,6] L=[0,1] S=[0,1]

//  function GPtranspPColor(cl: Cardinal): Cardinal;
//  function transpColor(cl: TColor; alpha: Byte): TColor;
  function  gpColorFromAlphaColor(Alpha: Byte; Color: TColor): Cardinal;
  function  color2hls(clr: Tcolor): Thls;
  function  hls2color(hls: Thls):  Tcolor;
  function  addLuminosity(clr: Tcolor; q: real): Tcolor;
  function  MidColor(clr1, clr2: Cardinal): Cardinal; overLoad;
  function  MidColor(const clr1, clr2: Cardinal; koef: Double): Cardinal; overLoad;
  function  blend(c1, c2: Tcolor; left: real): Tcolor;
//function  traspBmp1(bmp: Tbitmap; bg: Tcolor; transpLevel: integer): Tbitmap;

// convert
  function pic2ico(pic: Tbitmap): Ticon;
  function bmp2ico2(bitmap: Tbitmap): Ticon;
  function bmp2ico3(bitmap: Tbitmap): Ticon;
  function bmp2ico4M(bitmap: Tbitmap): hicon;
  function bmp2ico32(bitmap: Tbitmap): hicon;
  function bmp2ico(bitmap: Tbitmap): Ticon;
  procedure ico2bmp(ico: TIcon; bmp: TBitmap);
  procedure ico2bmp2(pIcon: HIcon; bmp: TBitmap);

type
  TRnQAni = TRnQBitmap;

  function CreateAni(fn: String; var b: Boolean): TRnQBitmap; {$IFDEF HAS_INLINE} inline; {$ENDIF HAS_INLINE} overload;
  function CreateAni(fs: TStream; var b: Boolean): TRnQBitmap; {$IFDEF HAS_INLINE} inline; {$ENDIF HAS_INLINE} overload;
  function LoadAGifFromStream(var NonAnimated: boolean;
              Stream: TStream): TRnQBitmap;

const
  icon_size = 16;

implementation
 uses
   StrUtils,
   math, mmSystem, Themes, UxTheme, UITypes,
 {$IFDEF DELPHI9_UP}
   DwmApi,
 {$ENDIF DELPHI9_UP}
 {$IFDEF UNICODE}
   AnsiStrings,
 {$ENDIF UNICODE}
//  {$IFNDEF RNQ_LITE}
   {$IFDEF USE_FLASH}
    ShockwaveFlashObjects_TLB,
//    FlashPlayerControl,
    ExtCtrls,
   {$ENDIF RNQ_FULL}
    CommCtrl,
    wincodec,
    ActiveX,
    RnQpngImage,
   RDUtils,
 {$IFDEF RNQ}
   RnQGlobal,
 {$ENDIF RNQ}
    litegif1,
    cgJpeg,
    uIconStream
   ;
{
type
  PColor24 = ^TColor24;
  TColor24 = record
    B, G, R: Byte;
  end;
  PColor24Array = ^TColor24Array;
  TColor24Array = array[0..MaxInt div SizeOf(TColor24) - 1] of TColor24;
}
{$IFDEF FPC}
type
  PAlphaColor = ^TAlphaColor;
  TAlphaColor = UInt32;

  {$EXTERNALSYM OLE_HANDLE}
  OLE_HANDLE = Longint;
  {$EXTERNALSYM OLE_XPOS_HIMETRIC}
  OLE_XPOS_HIMETRIC  = Longint;
  {$EXTERNALSYM OLE_YPOS_HIMETRIC}
  OLE_YPOS_HIMETRIC  = Longint;
  {$EXTERNALSYM OLE_XSIZE_HIMETRIC}
  OLE_XSIZE_HIMETRIC = Longint;
  {$EXTERNALSYM OLE_YSIZE_HIMETRIC}
  OLE_YSIZE_HIMETRIC = Longint;

  {$EXTERNALSYM IPicture}
  {$HPPEMIT 'DECLARE_DINTERFACE_TYPE(IPicture)' }
  IPicture = interface
    ['{7BF80980-BF32-101A-8BBB-00AA00300CAB}']
    function get_Handle(out handle: OLE_HANDLE): HResult;  stdcall;
    function get_hPal(out handle: OLE_HANDLE): HResult; stdcall;
    function get_Type(out typ: Smallint): HResult; stdcall;
    function get_Width(out width: OLE_XSIZE_HIMETRIC): HResult; stdcall;
    function get_Height(out height: OLE_YSIZE_HIMETRIC): HResult; stdcall;
    function Render(dc: HDC; x, y, cx, cy: Longint;
      xSrc: OLE_XPOS_HIMETRIC; ySrc: OLE_YPOS_HIMETRIC;
      cxSrc: OLE_XSIZE_HIMETRIC; cySrc: OLE_YSIZE_HIMETRIC;
      const rcWBounds: TRect): HResult; stdcall;
    function set_hPal(hpal: OLE_HANDLE): HResult; stdcall;
    function get_CurDC(out dcOut: HDC): HResult; stdcall;
    function SelectPicture(dcIn: HDC; out hdcOut: HDC;
      out bmpOut: OLE_HANDLE): HResult; stdcall;
    function get_KeepOriginalFormat(out fkeep: BOOL): HResult; stdcall;
    function put_KeepOriginalFormat(fkeep: BOOL): HResult; stdcall;
    function PictureChanged: HResult; stdcall;
    function SaveAsFile(const stream: IStream; fSaveMemCopy: BOOL;
      out cbSize: Longint): HResult; stdcall;
    function get_Attributes(out dwAttr: Longint): HResult; stdcall;
  end;

  function AlphaBlend(hdcDest: HDC; xoriginDest, yoriginDest, wDest, hDest: Integer;
                      hdcSrc: HDC; xoriginSrc, yoriginSrc, wSrc, hSrc: Integer; p11: TBlendFunction): BOOL; stdcall;
                external msimg32 name 'AlphaBlend';
  {$EXTERNALSYM AlphaBlend}

  //function AlphaBlend; external msimg32 name 'AlphaBlend' delayed;

{$ENDIF FPC}

const
  JPEG_HDRS: array [0..6] of AnsiString = (
    #$FF#$D8#$FF#$E0,
    #$FF#$D8#$FF#$E1,
    #$FF#$D8#$FF#$ED, {ADOBE}
    #$FF#$D8#$FF#$E2, {CANON}
    #$FF#$D8#$FF#$E3,
    #$FF#$D8#$FF#$DB, {SAMSUNG}
    #$FF#$D8#$FF#$FE {UNKNOWN});
  TIF_HDR: array [0..3] of AnsiChar = #$49#$49#$2A#$00;
  TIF_HDR2: array [0..3] of AnsiChar = #$4D#$4D#$00#$2A;
  CLSID_WICWEBPDecoder: TGUID = '{C747A836-4884-47B8-8544-002C41BD63D2}';

const
 IID_IPicture: TGUID = '{7BF80980-BF32-101A-8BBB-00AA00300CAB}';

var
 supExts: array[0..9] of string = ('bmp', 'wbmp', 'wbm', 'ico','icon',
                 'gif', 'png', 'jpg', 'jpe', 'jpeg');//, 'tif', 'dll')
 isWEBPSupport: Boolean;
 isTIFFSupport: Boolean;
 JPEGTurbo: Boolean;

  var
    ThePalette: HPalette;       {the rainbow palette for 256 colors}


{----------------TAniFrame.Create}
constructor TAniFrame.Create;
begin
  inherited Create;
end;

constructor TAniFrame.CreateCopy(Item: TAniFrame);
begin
  inherited Create;
  System.Move(Item.frLeft, frLeft, DWord(@TheEnd)-DWord(@frLeft));
  IsCopy := True;
end;

{----------------TAniFrame.Destroy}
{
destructor TAniFrame.Destroy;
begin
  inherited Destroy;
end;}

{----------------TAniFrameList.GetFrame}
function TAniFrameList.GetFrame(I: integer): TAniFrame;
begin
  Assert((I <= Count) and (I >= 1   ), 'Frame index out of range');
  Result := TAniFrame(Items[I-1]);
end;

destructor  TRnQBitmap.Destroy;
var
 i: Integer;
begin
 FreeAndNil(fBmp);
 FreeAndNil(htMask);
 if fHI > 0 then
  DestroyIcon(fHI);
 if Assigned(fFrames) then
 begin
   for I := 1 to fFrames.Count do
     fFrames[i].Free;
   fFrames.Clear;
   FreeAndNil(fFrames);
 end;
// FreeAndNil(fBMP32);
 inherited;
end;

{procedure TRnQBitmap.Free;
begin
  if Self <> nil then
    Destroy;
end;}

constructor TRnQBitmap.Create;
begin
  fBmp := NIL;
  htMask := NIL;
  htTransparent := false;
  fHI  := 0;
//  fBMP32 := NIL;
  f32Alpha := False;
  fFormat := PA_FORMAT_UNK;
  fDPI  := cDefaultDPI;

  fAnimated := False;
  FCurrentFrame := 1;
  fFrames := NIL;
  FNumFrames := 0;
//  Frames := TAniFrameList.Create;
  CurrentIteration := 1;
end;

procedure TRnQBitmap.Clear;
begin
  FreeAndNil(fBmp);
  FreeAndNil(htMask);
  htTransparent := false;
  if fHI > 0 then
   DestroyIcon(fHI);
  fHI  := 0;
  f32Alpha := False;
  fFormat := PA_FORMAT_UNK;
end;

constructor TRnQBitmap.Create(Width, Heigth: Integer);
begin
  Create;
//  fBmp := createBitmap(Width, Heigth);
   fBmp := Tbitmap.create;
   fBmp.PixelFormat := pf32bit;
   {$IFDEF DELPHI9_UP}
    fBmp.SetSize(Width, Heigth);
   {$ELSE DELPHI9_UP}
    fBmp.width  := Width;
    fBmp.height := Heigth;
   {$ENDIF DELPHI9_UP}
  fWidth  := Width;
  fHeight := Heigth;
end;

constructor TRnQBitmap.Create(hi: HICON);
begin
  Create;
  fHI := CopyIcon(hi);
//  fWidth  := icon_size;
//  fHeight := icon_size;
  fWidth  := GetSystemMetrics(SM_CXICON);
  fHeight := GetSystemMetrics(SM_CYICON);
end;

constructor TRnQBitmap.Create(fn: String);
begin
  Create;
  loadPic(fn, Self);
end;

procedure TRnQBitmap.loadFromStream(stream: TStream);
begin
  loadpic(stream, self, 0, PA_FORMAT_UNK, '', True);
end;

function  TRnQBitmap.GetWidth: Integer;
begin
  Result := fWidth;
end;
function  TRnQBitmap.GetHeight: Integer;
begin
  Result := fHeight;
end;

function TRnQBitmap.GetSize(PPI: Integer): TSize;
var
  lPicDPI: Integer;
begin
  if PicDPI < 20 then
    lPicDPI := cDefaultDPI
   else
    lPicDPI := picDPI;
  if (PPI <> lPicDPI)and (PPI > 30) then
      begin
        Result.cx := MulDiv(fWidth, PPI, lPicDPI);
        Result.cy := MulDiv(fHeight, PPI, lPicDPI);
      end
  else if (PPI > 30) and (lPicDPI <> cDefaultDPI) then
      begin
        Result.cx := MulDiv(fWidth, cDefaultDPI, lPicDPI);
        Result.cy := MulDiv(fHeight, cDefaultDPI, lPicDPI);
      end
  else
      begin
        Result.cx := fWidth;
        Result.cy := fHeight;
      end
end;

procedure InitTransAlpha(bmp: TBitmap);
var
 Scan32: pColor32Array;
 I, X: Cardinal;
// A1: Double;
 h, w: Integer;
 bt: Boolean;
 Trans: TColor32;
begin
//  if not bmp.Transparent then
//    Exit;
  Bt := bmp.Transparent;
  h := bmp.Height-1; // —разу вычетаем 1 !!!
  w := bmp.Width-1;  // —разу вычетаем 1 !!!

  Trans.Color := ColorToRGB(bmp.TransparentColor) and not AlphaMask;
  for I := 0 to h do
   begin
    Scan32 := Bmp.ScanLine[i];
    for X := 0 to w do
     begin
      with Scan32^[X] do
       begin
         if bt and ((Color and not AlphaMask) = Trans.Color) then
           A := 0
          else
           A := $FF;
       end;
     end;
   end;
end;

procedure Premultiply(var bmp: TBitmap);
  function mult1(const a, b: byte): byte; {$IFDEF HAS_INLINE}inline; {$ENDIF HAS_INLINE}
  var
    i: Integer;
  begin
    if b = 255 then
      Result := a
     else
      if b = 0 then
        Result := 0
       else
      begin
       i := a;
       i := (i*b + $7F)shr 8;
       Result := i;
      end;
  end;
var
 Scan32: pColor32Array;
 I, X: Cardinal;
// A1: Double;
 h, w: Integer;
begin
  h := bmp.Height-1; // —разу вычетаем 1 !!!
  w := bmp.Width-1;  // —разу вычетаем 1 !!!
  for I := 0 to h do
   begin
    Scan32 := Bmp.ScanLine[i];
    for X := 0 to w do
     begin
      with Scan32^[X] do
       begin
//         B := (Integer(B)*A + $7F) shl 8;
//         R := (Integer(R)*A + $7F) shl 8;
//         G := (Integer(G)*A + $7F) shl 8;
        B := mult1(B, A);
        R := mult1(R, A);
        G := mult1(G, A);
       end;
     end;
   end;
end;

procedure Demultiply(bmp: TBitmap);
var
 Scan32: pColor32Array;
 I, X: Cardinal;
 A1: Double;
 h, w: Integer;
begin
  h := bmp.Height-1;
  w := bmp.Width-1;
  for I := 0 to H do
   begin
    Scan32 := Bmp.ScanLine[i];
    for X := 0 to W do
     with Scan32^[X] do
     begin
      if A > 0 then
       begin
        A1 := A / $FF;
        R := round(R / A1);
        G := round(G / A1);
        B := round(B / A1);
       end;
     end;
   end;
end;

{procedure LoadPictureFile(Name: String; var gpPicture: IPicture);
var
 aFile: HFILE;
// pstm: IStream;
 pvData: Pointer;
 dwBytesRead: DWORD;
 dwFileSize: DWORD;
 Global: HGLOBAL;
 i: longint;
begin

 aFile := CreateFile(PChar(Name), GENERIC_READ, 0, NIL, OPEN_EXISTING, 0, 0);
 if aFile = INVALID_HANDLE_VALUE then
   Exit;
 dwFileSize := GetFileSize(aFile, NIL);
 if dwFileSize = -1 then
   Exit;

 pvData := NIL;

 Global := GlobalAlloc(GMEM_MOVEABLE, dwFileSize);
 if Global = 0 then
 begin
   CloseHandle(aFile);
   Exit;
 end;

 pvData := GlobalLock(Global);
 if pvData = NIL then
   Exit;

 dwBytesRead := 0;

 if not ReadFile(aFile, pvData^, dwFileSize, dwBytesRead, NIL) then
   Exit;

 GlobalUnlock(Global);
 CloseHandle(aFile);

 pstm := NIL;

 if CreateStreamOnHGlobal(Global, True, pstm) <> S_OK then
   Exit;
 if pstm = NIL then
   Exit;

 if Assigned(gpPicture) then
   gpPicture := NIL;
 if OleLoadPicture(pstm, dwFileSize, False, IID_IPicture, gpPicture) <> S_OK then
 begin
   pstm := NIL;
   Exit;
 end;
 GlobalFree(Global);
 pstm := NIL;
end;}

{ $IFNDEF FPC}

{$IFDEF FPC}
function OleLoadPicture(stream: IStream; lSize: Longint; fRunmode: BOOL;
    const iid: TGUID; var vObject): HResult; stdcall external 'olepro32.dll' name 'OleLoadPicture';
{$ENDIF}
procedure LoadPictureStream(str: TStream; var gpPicture: IPicture);
var
 stra: TStreamAdapter;
 dwFileSize: DWORD;
// Global: HGLOBAL;
// i: longint;
begin

 str.Position := 0;
 stra := TStreamAdapter.Create(str);
 dwFileSize := str.Size;
 try
   if Assigned(gpPicture) then
     gpPicture := NIL;
  // if OleLoadPicture(pstm, dwFileSize, False, IID_IPicture, gpPicture) <> S_OK then
   if OleLoadPicture(stra, dwFileSize, False, IID_IPicture, gpPicture) <> S_OK then
   begin
  //   pstm := NIL;
//     stra.Free;
//     Exit;
     gpPicture := NIL;
   end;
  // GlobalFree(Global);
  // pstm := NIL;
 finally
//   stra.Free;
//  stra.
 end;
end;

{ $ENDIF ~FPC}

function  loadPic2(const fn: string; var bmp: TRnQBitmap):boolean;
begin
  Result := loadPic(fn, bmp);
  if not Result then
    if Assigned(bmp) then
     begin
       bmp.Free;
       bmp := NIL;
     end;
end;

function  loadPic(const fn: string; var bmp: TRnQBitmap; idx : Integer = 0):boolean;
var
  Stream: TStream;
   {$IFDEF USE_FLASH}
  swf: TShockwaveFlash;
//  swf: TTransparentFlashPlayerControl;
//  swf: TFlashPlayerControl;
  frm: TForm;
  w, h: Double;
   {$ENDIF USE_FLASH}
//  pnl: TPanel;
  ff: TPAFormat;
  pic: TPicture;
begin
  Result := FileExists(fn);
  if not Assigned(bmp) then
    if not Result then
      Exit
     else
      bmp := TRnQBitmap.Create
   else
    bmp.Clear;
  if not Result then
    Exit;
//  Result := False;
  if (lowercase(sysutils.ExtractFileExt(fn)) = '.ico')
       or (lowercase(sysutils.ExtractFileExt(fn)) = '.icon') then
    ff := PA_FORMAT_ICO
//  {$IFNDEF RNQ_LITE}
  else if (lowercase(sysutils.ExtractFileExt(fn)) = '.swf') then
     begin
   {$IFDEF USE_FLASH}
      try
//       swf :=  TTransparentFlashPlayerControl.Create(Application.MainForm);
//       pnl := TPanel.Create(Application.MainForm);
//       pnl.Parent :=Application.MainForm;
//       pnl := TPanel.Create(Application);
//       pnl.Parent :=Application.MainForm;
       frm := TForm.Create(Application);
       frm.Width := maxSWFAVTW;
       frm.Height := maxSWFAVTH;
       try
         swf :=  TShockwaveFlash.Create(frm);
  //       swf :=  TTransparentFlashPlayerControl.Create(pnl);
  //       swf :=  TFlashPlayerControl.Create(pnl);
         swf.Visible := False;
  //         swf.parent := Application.MainForm;
           swf.parent := frm;
  //         swf.align  := alClient;
         swf.Movie := fn;
  //       swf.
  //       swf.BackgroundColor := clWindow;
  //       swf.ClientWidth := 100;
  //       pnl.Width := swf.ClientWidth + 2;
  //       pnl.Width := 100;
         swf.Width := maxSWFAVTW; swf.Height := maxSWFAVTH;
         try
          w := swf.TGetPropertyNum('/', 8); // WIDTH
          h := swf.TGetPropertyNum('/', 9); // HEIGHT
         except
           w := 1; h := 1;
         end;
          if w = 0 then w := 1;
          if h = 0 then h := 1;

         if w * maxSWFAVTH < h * maxSWFAVTW then
           begin
            swf.Width := trunc(maxSWFAVTH*w / h); swf.Height := maxSWFAVTH;
           end
         else
           begin
            swf.Width := maxSWFAVTW; swf.Height := trunc(maxSWFAVTW*h / w);
           end;

         swf.GotoFrame(idx);
         swf.Repaint;
  //       swf.SetVariable('wmode', 'transparent');
  //       swf.TSetProperty('wmode', );
         swf.WMode := wideString( 'TRANSPARENT');
  //       s := swf.BGColor;
  //       if s = 'Black' then
  //         swf.BackgroundColor := $00010101;
         if not Assigned(bmp.fBmp) then
           bmp.fBmp := createBitmap(swf.Width, swf.Height)
          else
           begin
             bmp.fBmp.Handle := 0;
            {$IFDEF DELPHI9_UP}
             bmp.fBmp.SetSize(swf.Width, swf.Height);
            {$else DELPHI_9_dn}
             bmp.fBmp.Height := 0;
             bmp.fBmp.Width := swf.Width;
             bmp.fBmp.Height := swf.Height;
            {$ENDIF DELPHI9_UP}
           end;
  //         FreeAndNil(bmp.fBmp);
  //        fBmp.Canvas.Brush.Color:= clRed;// $00010101;
  //        fBmp.Canvas.FillRect(fBmp.Canvas.ClipRect);
  //       fBmp.Canvas.FillRect(fBmp.Canvas.ClipRect);
  //       bmp.fBmp.PixelFormat := pf32bit;
  //       bmp.fBmp := swf.CreateFrameBitmap;
  //       bmp.f32Alpha := True;
         swf.PaintTo(bmp.fBmp.Canvas, 0, 0);
  //       bmp.SetTransparentColor($00010101);
  //       bmp.fBmp.Transparent := True;

          bmp.fWidth := bmp.fBmp.Width;
          bmp.fHeight:= bmp.fBmp.Height;
         FreeAndNil(swf);
       finally
        FreeAndNil(frm);
       end;
       result := True;
      except
       result := false;
      end;
   {$ELSE not_USE_FLASH}
       Result := false;
   {$ENDIF USE_FLASH}
      exit;
     end
{  if (lowercase(ExtractFileExt(fn)) = '.gif') then
    ff := PA_FORMAT_GIF
  else
     else
    if (lowercase(ExtractFileExt(fn)) = '.jpeg')
     or (lowercase(ExtractFileExt(fn)) = '.jpg') then
}
//  {$ENDIF RNQ_LITE}
  else
   ff := PA_FORMAT_UNK;

  Stream := TFileStream.Create(fn, sysutils.fmOpenRead or sysutils.fmShareDenyWrite);
  try
    Result := loadPic(Stream, bmp, idx, ff);

  finally
    if Assigned(stream) then
      Stream.Free;
  end;
  if not Result then
    begin
       pic := TPicture.Create;
       try
        pic.LoadFromFile(fn);
       except
        FreeAndNil(pic);
       end;
       if Assigned(pic) then
        begin
         if not Assigned(bmp.fBmp) then
           bmp.fBmp := TBitmap.Create;
         try
           bmp.fBmp.Assign(pic.Graphic);
           bmp.fWidth := bmp.fBmp.Width;
           bmp.fHeight := bmp.fBmp.Height;
           bmp.fTransparentColor := ColorToRGB(bmp.fBmp.TransparentColor);
           Result := True;
          except
           bmp.Free;
           bmp := NIL;
           Result := False;
         end;
        end;
       FreeAndNil(pic);
//       fBmp.LoadFromFile();
    end;
end;

function GetLastErrorText: string;
var
  C: array[Byte] of Char;
begin

  FormatMessage(
    FORMAT_MESSAGE_FROM_SYSTEM,
    nil,
    GetLastError,
    LOCALE_USER_DEFAULT,
    C,
    SizeOf(C),
    nil);
  Result:=StrPas( C );
end;
function LoadIconFromStream(str : TStream) : HIcon;
{var
  MStr : TMemoryStream;
begin
  if str is TMemoryStream then
    MStr := TMemoryStream( str )
   else
    begin
      MStr := TMemoryStream.Create;
      MStr.LoadFromStream(str);
    end;
  MStr.Position := 0;
  Result := CreateIconFromResourceEx(MStr.Memory, MStr.Size, True, $00030000,
              icon_size, icon_size,
              LR_DEFAULTCOLOR);

  if MStr <> str then
    begin
      MStr.Free;
    end;

  if Result = 0 then
    msgDlg(GetLastErrorText, False, mtError);
}
var
  icn: TIcon;
begin
  icn := TIcon.Create;
  icn.LoadFromStream(str);
  Result := CopyIcon(icn.Handle);
  icn.Free;
end;

procedure BeginPicsMassLoad;
begin
  init_libJPEGCS(TJpegImage.LibPathName);
end;

procedure EndPicsMassLoad;
begin
  UnInit_libJPEG;
end;

function  loadPic(var str0: TStream; var bmp: TRnQBitmap; idx: Integer = 0;
                  ff: TPAFormat = PA_FORMAT_UNK; name: string = '';
                  PreserveStream: Boolean = false): boolean;
var
//  png: TPNGGraphic;
  png: TPNGObject;
  WICpic: TWICImage;
//  aniImg : TRnQAni;
  NonAnimated: Boolean;
  vJpg: TJPEGImage;

//  {$IFNDEF RNQ_LITE}
//  vJpg, vJpgBad: TsdJpegFormat;
//  vJpg, vJpgBad: jpeg_decompress_struct;
//  JPegR: TFPReaderJPEG;
  pic: IPicture;
  a, b: Integer;
  h, w: Integer;
  r: TRect;

  vBmp: TBitmap;
//  {$ENDIF RNQ_LITE}
  IcoStream: TIconStream;
  MemStream: TMemoryStream;
  i: Integer;
  Frame: TAniFrame;
//  Grph: TGraphic;
//  ff: TPAFormat;
begin
//  fBmp := NIL;
//  fBMP32 := NIL;
//  f32Alpha := False;
  Result := False;
  if not Assigned(str0) then
    Exit;

  if ff = PA_FORMAT_UNK then
    ff := DetectFileFormatStream(str0);
  str0.Position := 0;
  case ff of
   PA_FORMAT_BMP:
       begin
//        FreeAndNil(bmp);
        if not Assigned(bmp) then
          bmp := TRnQBitmap.Create
         else
          bmp.Clear;
        bmp.f32Alpha := False;
        bmp.fFormat := ff;
         if not Assigned(bmp.fBmp) then
           bmp.fBmp := TBitmap.Create;
         bmp.fBmp.LoadFromStream(str0);
         bmp.fWidth  := bmp.fBmp.Width;
         bmp.fHeight := bmp.fBmp.Height;
{          f32Alpha := False;
          if (fBmp.PixelFormat = pf32bit) and (fBmp.PixelFormat = pf32bit) then
           begin
            f32Alpha := fBmp.PixelFormat = pf32bit;
            Premultiply(fBmp);
           end;}
//        bmp.fBmp.Transparent := True;
           bmp.fTransparentColor := ColorToRGB(bmp.fBmp.TransparentColor);
        Include(bmp.FState, PS_INIT_PICS);
        if not PreserveStream then
         begin
          str0.Free;
          str0 := NIL;
         end;
        Result := True;
       end;
//  {$IFNDEF RNQ_LITE}
   PA_FORMAT_JPEG:
       begin
//         vJpgBad := NIL;
//         vJpg := TJPEGImage.Create;
//         vJpg := TsdJpegFormat.Create(NIL);
//         jpeg_CreateDecompress(vJpg);
//         jpeg_CreateDecompress(@vJpg, JPEG_LIB_VERSION, SizeOf(vJpg));
//         JPegR := TFPReaderJPEG.Create;
//         vJpg.LoadOptions := [loTileMode];
         vBmp := NIL;
         try
           if JPEGTurbo then
             begin
              vJpg := TJPEGImage.Create;
              if vJpg.LoadFromStream(str0) then
                begin
                  vBmp := TBitmap.Create;
                  vBmp.PixelFormat := pf24bit;
                  vBmp.Assign(vJpg);
                end;
              vJpg.Free;
//              if not PreserveStream then
//                FreeAndNil(str0);
             end;
            if not Assigned(vBmp) then

          try

//           vBmp := JPegR.GetBMP(str);

//           jpeg_read_header(vJpg, True);
{           if (str is TMemoryStream) then
             begin
               vJpg.LoadFromStream(str)
               jpeg_stdio_src(@vJpg, @str);
             end;
//             MemStream := str
            else
             try
               MemStream := TMemoryStream.Create;
               MemStream.CopyFrom(str, str.Size);
               MemStream.Position := 0;
               vJpg.LoadFromStream(MemStream);
              finally
               FreeAndNil(MemStream);
             end;}

           MemStream := TMemoryStream.Create;
           MemStream.CopyFrom(str0, str0.Size);
           MemStream.Position := 0;
           LoadPictureStream(MemStream, pic);
           if pic <> NIL then
             begin
//              scr := CreateDC('DISPLAY', nil, nil, nil);
              pic.get_Width(a);
              pic.get_Height(b);

              vBmp := TBitmap.Create;
              vBmp.PixelFormat := pf24bit;
//              w := MulDiv(a, GetDeviceCaps(scr, LOGPIXELSX), 2540);
//              h := MulDiv(b, GetDeviceCaps(scr, LOGPIXELSY), 2540);
              w := MulDiv(a, GetDeviceCaps(vBmp.Canvas.Handle, LOGPIXELSX), 2540);
              h := MulDiv(b, GetDeviceCaps(vBmp.Canvas.Handle, LOGPIXELSY), 2540);
            //  a := 50; b := 120;
              r.Left := 0; r.Top := 0; r.Right := w; r.Bottom := h;
 {$IFDEF DELPHI9_UP}
              vBmp.SetSize(w, h);
 {$ELSE DELPHI9_UP}
              vBmp.Height := 0;
              vBmp.Width := w;
              vBmp.Height := h;
 {$ENDIF DELPHI9_UP}
              pic.Render(vBmp.Canvas.Handle, 0, 0, w, h, 0, b, a, -b, r);
              pic := NIL;
             end;

           finally
            FreeAndNil(MemStream);
            if not PreserveStream then
              FreeAndNil(str0);
            try
//              if Assigned(JPegR) then
//                JPegR.Free;
             except
            end;
           end;
          except
//           vJpgBad := vJpg;
//           vJpg := NIL;
           vBmp := NIL;
         end;
{         if Assigned(vJpgBad) then
         try
           vJpgBad.Free;
          except
         end;
         if Assigned(vJpg) and Assigned(vJpg.Coder) and
            vJpg.Coder.HasCoefs then}
         if Assigned(vBmp) then
         begin
          if not Assigned(bmp) then
            bmp := TRnQBitmap.Create
           else
            bmp.Clear;
          bmp.f32Alpha := False;
          bmp.fFormat := ff;
{           if not Assigned(bmp.fBmp) then
            bmp.fBmp :=TBitmap.Create;
  //         bmp.fBmp.Assign(TJPEGImage(vJpg));
           bmp.fBmp.Assign(vJpg.Bitmap);}
           bmp.fBmp := vBmp; 
  //         bmp.fBmp.Transparent := TJPEGImage(vJpg).Transparent;
           bmp.fBmp.Transparent := False;
           bmp.fWidth  := bmp.fBmp.Width;
           bmp.fHeight := bmp.fBmp.Height;
           bmp.fBmp.Transparent := False;
//           InitTransAlpha(bmp.fBmp);
           Include(bmp.FState, PS_INIT_PICS);

           try
//             vJpg.Free;
//             vBmp.Free;
            except
//             vJpg := NIL;
           end;
           Result := True;
         end;
         exit;
       end;
//  {$ENDIF RNQ_LITE}
   PA_FORMAT_GIF:
      begin
//        aniImg := CreateAni(str, NonAnimated);
        if Assigned(bmp) then
          bmp.Free;
//         else
//          bmp.Clear;
        bmp := LoadAGifFromStream(NonAnimated, str0);
//        if Assigned(aniImg) and (aniImg.NumFrames > 0) then
        if Assigned(bmp) and (bmp.NumFrames > 0) then
        begin
  //        bmp := TBitmap.Create;
          if (idx < 1) or (idx > bmp.NumFrames) then
            idx := 1;
          bmp.CurrentFrame := idx;
{          if Assigned(bmp) then
           bmp.Free;
          bmp := GetRnQBitMap(aniImg);
          bmp.fFormat := ff;
          bmp.fAnimated := not NonAnimated;}
  {
          if not Assigned(bmp.fBmp) then
           bmp.fBmp :=TBitmap.Create;
  //        FreeAndNil(fBmp32);
          bmp.fBmp.Assign(aniImg.Bitmap);
  //        bmp.TransparentMode := tmAuto;
          bmp.fBmp.Transparent := aniImg.IsTransparent;
          bmp.fWidth:= bmp.fBmp.Width;
          bmp.fHeight:= bmp.fBmp.Height;
  }

//          aniImg.Free;
           bmp.fTransparentColor := ColorToRGB(bmp.fBmp.TransparentColor);
           bmp.fFormat := ff;
         if not PreserveStream then
          begin
           str0.Free;
           str0 := NIL;
          end;
         Result := True;
        end;
       exit;
     end;
   PA_FORMAT_PNG:
       begin
//         png := TPNGGraphic.Create;
         png := TPNGObject.Create;
         try
           png.LoadFromStream(str0);
          except
         end;
         if not png.empty then
         begin
          if not Assigned(bmp) then
            bmp := TRnQBitmap.Create
           else
            bmp.Clear;
          bmp.f32Alpha := False;
          bmp.fFormat := ff;

          if png.Animated then
            begin
             if Assigned(bmp.fBmp) then
                FreeAndNil(bmp.fBmp);

             bmp.fBmp := png.AniPNG.getFullBitmap;
{
              if (png.TransparencyMode =ptmPartial)
                 or (png.Header.ColorType = COLOR_PALETTE)
               then
                begin
                 bmp.f32Alpha := True;
//                 Premultiply(bmp.fBmp);
                end;

              bmp.fTransparentColor := ColorToRGB(bmp.fBmp.TransparentColor);
}
              bmp.f32Alpha := True;
//              Premultiply(bmp.fBmp);

              bmp.fWidth := png.Width;
              bmp.fHeight := png.Height;

             if not Assigned(bmp.fFrames) then
               bmp.fFrames := TAniFrameList.Create;
//             bmp.fAnimated := True;
             bmp.FNumFrames := png.AniPNG.FNumFrames;
             bmp.FNumIterations := png.AniPNG.FNumIterations;
             bmp.FAnimated := bmp.FNumFrames > 1;
             for I := 0 to png.AniPNG.FNumFrames-1 do
              begin
                Frame := TAniFrame.Create;
                try
                  Frame.frDisposalMethod := TAniDisposalType(png.AniPNG.Frames.Item[i].DisposeOp);
                  Frame.frLeft := png.AniPNG.Frames.Item[i].XOffset;
                  Frame.frTop := png.AniPNG.Frames.Item[i].YOffset;
                  Frame.frWidth := png.AniPNG.Frames.Item[i].SelfWidth;
                  Frame.frHeight := png.AniPNG.Frames.Item[i].SelfHeight;
        //          Frame.frDelay := IntMax(30, AGif.ImageDelay[I] * 10);
                  Frame.frDelay := IntMax(100, png.AniPNG.Frames.Item[i].DelayMS);
                 except
                  Frame.Free;
                  Raise;
                end;
                bmp.fFrames.Add(Frame);
              end;
             if bmp.fAnimated then
              bmp.WasDisposal := dtToBackground;
            end
           else
             begin
              if not Assigned(bmp.fBmp) then
               bmp.fBmp :=TBitmap.Create;
              bmp.fBmp.PixelFormat := pf32bit;
              bmp.f32Alpha := False;
              bmp.fBmp.Assign(png);
    //          if (png.ImageProperties.HasAlpha) and (bmp.fBmp.PixelFormat = pf32bit) then
              if (png.TransparencyMode =ptmPartial)
                 or (png.TransparencyMode =ptmBit)and (png.Header.ColorType = COLOR_PALETTE)
//                 or (png.Header.ColorType = COLOR_PALETTE)
               then
                begin
    //             PNGObjectToBitmap32(png, bmp.fBmp);
                 bmp.f32Alpha := True;
    //            bmp.f32Alpha := bmp.fBmp.PixelFormat = pf32bit;
                 Premultiply(bmp.fBmp);
    //            bmp.fBmp.Transparent := png.Transparent;
    //            bmp.fBmp.TransparentColor := png.TransparentColor;
    //            bmp.fBmp.TransparentMode := png.Transparen;
                end
               else
                begin
    //            bmp.fBmp.TransparentMode := tmAuto;
    //            bmp.fBmp.Transparent := True;
                end;
              bmp.fTransparentColor := ColorToRGB(bmp.fBmp.TransparentColor);
              bmp.fWidth := bmp.fBmp.Width;
              bmp.fHeight := bmp.fBmp.Height;
             end;

            png.free;
           if not PreserveStream then
            begin
             str0.Free;
             str0 := NIL;
            end;
           Result := True;
         end;
       end;
   PA_FORMAT_ICO:
       begin
        if (idx < 1) then
          idx := 1;
        if idx > 1 then
//        if 1 = 1 then
          begin
           IcoStream := TIconStream.Create;
           IcoStream.LoadFromStream(str0);
            if (idx < 1) or (idx > IcoStream.Count) then
              idx := 1;
            dec(idx);
            if not Assigned(bmp) then
              bmp := TRnQBitmap.Create
             else
              bmp.Clear;
            bmp.f32Alpha := False;
            bmp.fFormat := ff;
              begin
                if not Assigned(bmp.fBmp) then
                 bmp.fBmp := TBitmap.Create;
    //            FreeAndNil(fBmp32);
                bmp.fBmp.Height:= IcoStream[Idx].bHeight;
                bmp.fBmp.Width := IcoStream[Idx].bWidth;
        //        bmp.Canvas.Brush.Color:= clBtnFace;
                bmp.fBmp.Canvas.Brush.Color:= $010101;
                bmp.fBmp.Canvas.FillRect(bmp.fBmp.Canvas.ClipRect);

                IcoStream.Draw(bmp.fBmp.Canvas.Handle, 0,0, Idx);
                bmp.SetTransparentColor($010101);
                bmp.fBmp.Transparent := True;
                bmp.fWidth:= bmp.fBmp.Width;
                bmp.fHeight:= bmp.fBmp.Height;
              end;
            IcoStream.Free;
          end
         else
          begin
            if not Assigned(bmp) then
              bmp := TRnQBitmap.Create
             else
              bmp.Clear;
            bmp.f32Alpha := False;
            bmp.fFormat := ff;
{
            bmp.fWidth := icon_size;
            bmp.fHeight := icon_size;
}

            bmp.fWidth  := GetSystemMetrics(SM_CXICON);
            bmp.fHeight := GetSystemMetrics(SM_CYICON);

//            bmp.fWidth := icn.Width;
//            bmp.fHeight := icn.Height;
//            bmp.fHI := icn.ReleaseHandle;
            bmp.fHI := LoadIconFromStream(str0);
            if bmp.fHI = 0 then
              begin
                bmp.Free;
                bmp := NIL;
              end;
          end;
         if not PreserveStream then
          begin
           str0.Free;
           str0 := NIL;
          end;
        if Assigned(bmp) then
          Result := True;
       exit;
     end;
    PA_FORMAT_TIF, PA_FORMAT_WEBP:
      begin
        WICpic := TWICImage.Create;
        try
          WICpic.LoadFromStream(str0);
          if not WICpic.empty then
          begin
            if not Assigned(bmp) then
              bmp := TRnQBitmap.Create
            else
              bmp.Clear;
            bmp.f32Alpha := false;
            bmp.fFormat := ff;

            begin
              if not Assigned(bmp.fBmp) then
                bmp.fBmp := TBitmap.Create;
              bmp.fBmp.PixelFormat := pf24bit;
              bmp.f32Alpha := false;
              bmp.fBmp.Assign(WICpic);
              bmp.fWidth := bmp.fBmp.Width;
              bmp.fHeight := bmp.fBmp.Height;
            end;

            Result := True;
          end;
         finally
           WICPic.Free;
           if not PreserveStream then
            begin
             str0.Free;
             str0 := NIL;
            end;
        end;
      end;
//   PA_FORMAT_XML: ;
//   PA_FORMAT_SWF: ;
//   PA_FORMAT_UNK: ;
   else
     begin
//       msgDlg(gettrans 'Can''t load picture from stream "%s"');
//        msgDlg(getTranslation('Can''t load file from stream: %s', [name]), mtError);
        Result := False;
     end;
  end;

//  if bmp.fBmp.Transparent then
//   Premultiply(bmp.fBmp);
//   InitTransAlpha(bmp.fBmp);
end;

 {$IFDEF RNQ}
function loadPic(pt: TThemeSourcePath; fn : string; var bmp: TRnQbitmap; idx: Integer = 0): boolean;
  function fullpath(const fn: string): string;
  begin
    if ansipos(':',fn)=0 then
      result := pt.path+fn
     else
      result := fn
  end;
var
  Stream: TMemoryStream;
  ff: TPAFormat;
begin
//  result := false;
  Stream := NIL;
  result := loadFile(pt, fn, TStream(Stream));
  ff := PA_FORMAT_UNK;
  if (lowercase(sysutils.ExtractFileExt(fn)) = '.ico')
       or (lowercase(sysutils.ExtractFileExt(fn)) = '.icon') then
    ff := PA_FORMAT_ICO;
  if Result then
   Result := loadPic(TStream(Stream), bmp, idx, ff);
  if not Result then
   if Assigned(Stream) then
    Stream.Free;
end;
 {$ENDIF RNQ}

procedure TRnQBitmap.SetTransparentColor(clr: cardinal);
begin
  fBMP.TransparentColor := clr;
  fTransparentColor := clr;
end;

{
procedure TRnQBitmap.Draw32bit(DC: HDC; DX, DY: Integer);
//procedure Draw32bit(DC: HDC; DX, DY: Integer; const Bmp: TBitmap);
var
  tmp_Bmp: TBitmap;
  X, Y: Integer;
  A: Double;
  Scan24: PColor24Array;
  Scan32: GR32.PColor32Array;
begin
  begin
    tmp_bmp := createBitmap(fWidth, fHeight);
    tmp_bmp.PixelFormat := pf24bit;

    BitBlt(tmp_bmp.Canvas.Handle,
      0, 0, fWidth, fHeight,
      DC, DX, DY, SrcCopy);

    for Y := 0 to fHeight - 1 do
    begin
      Scan24 := PColor24Array(tmp_bmp.ScanLine[Y]);
      Scan32 := GR32.PColor32Array(fBMP32.ScanLine[Y]);

      for X := 0 to fWidth - 1 do
      begin
        A := AlphaComponent(Scan32^[X]);

        if A <> 0 then
        begin
          A := A / 255;
//          A := (A + A/255) / 256;
          Scan24^[X].R := round(RedComponent(Scan32^[X]) * (A) + Scan24^[X].R * (1 - A));
          Scan24^[X].G := round(GreenComponent(Scan32^[X]) * (A) + Scan24^[X].G * (1 - A));
          Scan24^[X].B := round(BlueComponent(Scan32^[X]) * (A) + Scan24^[X].B * (1 - A));
        end;
      end;
    end;


    BitBlt(DC,
      DX, DY, fWidth, fHeight,
      tmp_bmp.Canvas.Handle, 0, 0, SrcCopy);

    tmp_bmp.Free;
  end;
end;
}

{$ifdef CopyPaletteMissing}
// -----------
// CopyPalette
// -----------
// Copies a HPALETTE.
//
// Copied from D3 graphics.pas. This is declared private in some old versions
// of Delphi 2 and is missing in Lazarus Component Library (LCL), so we have
// to implement it here to support those versions.
//
// Parameters:
// Palette	The palette to copy.
//
// Returns:
// The handle to a new palette.
//
function CopyPalette(Palette: HPALETTE): HPALETTE;
var
  PaletteSize: Integer;
  LogPal: TMaxLogPalette;
begin
  Result := 0;
  if Palette = 0 then Exit;
  PaletteSize := 0;
  if GetObject(Palette, SizeOf(PaletteSize), @PaletteSize) = 0 then Exit;
  if PaletteSize = 0 then Exit;
  with LogPal do
  begin
    palVersion := $0300;
    palNumEntries := PaletteSize;
    GetPaletteEntries(Palette, 0, PaletteSize, palPalEntry);
  end;
  Result := CreatePalette(PLogPalette(@LogPal)^);
end;
{$endif}
{$ifdef TransparentStretchBltMissing}
(*
**  GDI Error handling
**  Adapted from graphics.pas
*)
{$IFOPT R+}
  {$DEFINE R_PLUS}
  {$RANGECHECKS OFF}
{$ENDIF}
{$ifdef D3_BCB3}
function GDICheck(Value: Integer): Integer;
{$else}
function GDICheck(Value: Cardinal): Cardinal;
{$endif}
var
  ErrorCode		: integer;
// 2008.10.19 ->
{$IFDEF VER20_PLUS}
  Buf			: array [byte] of WideChar;
{$ELSE}
  Buf			: array [byte] of AnsiChar;
{$ENDIF}
// 2008.10.19 <-

  function ReturnAddr: Pointer;
  // From classes.pas
  asm
    MOV		EAX,[EBP+4] // sysutils.pas says [EBP-4], but this works !
  end;

begin
  if (Value = 0) then
  begin
    ErrorCode := GetLastError;
    if (ErrorCode <> 0) and (FormatMessage(FORMAT_MESSAGE_FROM_SYSTEM, nil,
      ErrorCode, LOCALE_USER_DEFAULT, Buf, sizeof(Buf), nil) <> 0) then
      raise EOutOfResources.Create(Buf) at ReturnAddr
    else
     raise EOutOfResources.Create('Out of resources') at ReturnAddr;
      //raise EOutOfResources.Create(SOutOfResources) at ReturnAddr;
  end;
  Result := Value;
end;
{$IFDEF R_PLUS}
  {$RANGECHECKS ON}
  {$UNDEF R_PLUS}
{$ENDIF}

var
  // From Delphi 3 graphics.pas
  SystemPalette16: HPalette; // 16 color palette that maps to the system palette

// Copied from D3 graphics.pas
// Fixed by Brian Lowe of Acro Technology Inc. 30Jan98
function TransparentStretchBlt(DstDC: HDC; DstX, DstY, DstW, DstH: Integer;
  SrcDC: HDC; SrcX, SrcY, SrcW, SrcH: Integer; MaskDC: HDC; MaskX,
  MaskY: Integer): Boolean;
const
  ROP_DstCopy		= $00AA0029;
var
  MemDC,
  OrMaskDC: HDC;
  MemBmp,
  OrMaskBmp: HBITMAP;
  Save,
  OrMaskSave: THandle;
  crText, crBack: TColorRef;
  SavePal: HPALETTE;

begin
  Result := True;
  if (Win32Platform = VER_PLATFORM_WIN32_NT) and (SrcW = DstW) and (SrcH = DstH) then
  begin
    MemBmp := GDICheck(CreateCompatibleBitmap(SrcDC, 1, 1));
    MemBmp := SelectObject(MaskDC, MemBmp);
    try
      MaskBlt(DstDC, DstX, DstY, DstW, DstH, SrcDC, SrcX, SrcY, MemBmp, MaskX,
        //MaskY, MakeRop4(ROP_DstCopy, SrcCopy));
        MaskY, SrcCopy);
    finally
      MemBmp := SelectObject(MaskDC, MemBmp);
      DeleteObject(MemBmp);
    end;
    Exit;
  end;

  SavePal := 0;
  MemDC := GDICheck(CreateCompatibleDC(DstDC));
  try
    { Color bitmap for combining OR mask with source bitmap }
    MemBmp := GDICheck(CreateCompatibleBitmap(DstDC, SrcW, SrcH));
    try
      Save := SelectObject(MemDC, MemBmp);
      try
        { This bitmap needs the size of the source but DC of the dest }
        OrMaskDC := GDICheck(CreateCompatibleDC(DstDC));
        try
          { Need a monochrome bitmap for OR mask!! }
          OrMaskBmp := GDICheck(CreateBitmap(SrcW, SrcH, 1, 1, nil));
          try
            OrMaskSave := SelectObject(OrMaskDC, OrMaskBmp);
            try

              // OrMask := 1
              // Original: BitBlt(OrMaskDC, SrcX, SrcY, SrcW, SrcH, OrMaskDC, SrcX, SrcY, WHITENESS);
              // Replacement, but not needed: PatBlt(OrMaskDC, SrcX, SrcY, SrcW, SrcH, WHITENESS);
              // OrMask := OrMask XOR Mask
              // Not needed: BitBlt(OrMaskDC, SrcX, SrcY, SrcW, SrcH, MaskDC, SrcX, SrcY, SrcInvert);
              // OrMask := NOT Mask
              BitBlt(OrMaskDC, SrcX, SrcY, SrcW, SrcH, MaskDC, SrcX, SrcY, NotSrcCopy);

              // Retrieve source palette (with dummy select)
              SavePal := SelectPalette(SrcDC, SystemPalette16, False);
              // Restore source palette
              SelectPalette(SrcDC, SavePal, False);
              // Select source palette into memory buffer
              if SavePal <> 0 then
                SavePal := SelectPalette(MemDC, SavePal, True)
              else
                SavePal := SelectPalette(MemDC, SystemPalette16, True);
              RealizePalette(MemDC);

              // Mem := OrMask
              BitBlt(MemDC, SrcX, SrcY, SrcW, SrcH, OrMaskDC, SrcX, SrcY, SrcCopy);
              // Mem := Mem AND Src
{$IFNDEF GIF_TESTMASK} // Define GIF_TESTMASK if you want to know what it does...
              BitBlt(MemDC, SrcX, SrcY, SrcW, SrcH, SrcDC, SrcX, SrcY, SrcAnd);
{$ELSE}
              StretchBlt(DstDC, DstX, DstY, DstW DIV 2, DstH, MemDC, SrcX, SrcY, SrcW, SrcH, SrcCopy);
              StretchBlt(DstDC, DstX+DstW DIV 2, DstY, DstW DIV 2, DstH, SrcDC, SrcX, SrcY, SrcW, SrcH, SrcCopy);
              exit;
{$ENDIF}
            finally
              if (OrMaskSave <> 0) then
                SelectObject(OrMaskDC, OrMaskSave);
            end;
          finally
            DeleteObject(OrMaskBmp);
          end;
        finally
          DeleteDC(OrMaskDC);
        end;

        crText := SetTextColor(DstDC, $00000000);
        crBack := SetBkColor(DstDC, $00FFFFFF);

        { All color rendering is done at 1X (no stretching),
          then final 2 masks are stretched to dest DC }
        // Neat trick!
        // Dst := Dst AND Mask
        StretchBlt(DstDC, DstX, DstY, DstW, DstH, MaskDC, SrcX, SrcY, SrcW, SrcH, SrcAnd);
        // Dst := Dst OR Mem
        StretchBlt(DstDC, DstX, DstY, DstW, DstH, MemDC, SrcX, SrcY, SrcW, SrcH, SrcPaint);

        SetTextColor(DstDC, crText);
        SetTextColor(DstDC, crBack);

      finally
        if (Save <> 0) then
          SelectObject(MemDC, Save);
      end;
    finally
      DeleteObject(MemBmp);
    end;
  finally
    if (SavePal <> 0) then
      SelectPalette(MemDC, SavePal, False);
    DeleteDC(MemDC);
  end;
end;
{$endif}

{$IFDEF FPC}
function TransparentBlt(hdcSrc: HDC; nXOriginSrc, nYOriginSrc, nWidthSrc,
  nHeightSrc: Integer; hdcDest: HDC; nXOriginDest, nYOriginDest, nWidthDest,
  nHeightDest: Integer; crTransparent: LongWord): BOOL; stdcall; external msimg32 name 'TransparentBlt';
{$ENDIF}

procedure TRnQBitmap.MaskDraw(DC: HDC; const DestBnd, SrcBnd: TGPRect);
{Draw parts of this bitmap on ACanvas}
var
  OldPalette, myPalette: HPalette;
  RestorePalette: Boolean;
  DoHalftone: Boolean;
  Pt: TPoint;
  BPP: Integer;
  MyDC: HDC;
begin
//  with DestBnd do
  begin
//    AHandle := dc;  {LDB}
    myPalette := fBmp.Palette;
//    PaletteNeeded;
    OldPalette := 0;
    RestorePalette := False;

    if myPalette <> 0 then
    begin
      OldPalette := SelectPalette(dc, myPalette, True);
      RealizePalette(dc);
      RestorePalette := True;
    end;
    BPP := GetDeviceCaps(dc, BITSPIXEL) *
      GetDeviceCaps(dc, PLANES);
    DoHalftone := (BPP <= 8) and (fBmp.PixelFormat in [pf15bit, pf16bit, pf24bit]);
    if DoHalftone then
    begin
      GetBrushOrgEx(dc, pt);
      SetStretchBltMode(dc, HALFTONE);
      SetBrushOrgEx(dc, pt.x, pt.y, @pt);
    end else if not fBmp.Monochrome then
      SetStretchBltMode(dc, STRETCH_DELETESCANS);
//      SetStretchBltMode(dc, HALFTONE);
    try
//      AHandle := dc;   {LDB}
      MyDC := fBmp.Canvas.Handle;
      if htTransparent then
        TransparentStretchBlt(dc, DestBnd.X, DestBnd.Y, DestBnd.Width,
            DestBnd.Height, MyDC,
            SrcBnd.X, SrcBnd.Y, SrcBnd.Width, SrcBnd.Height,
            htMask.Canvas.Handle, SrcBnd.X, SrcBnd.Y)   {LDB}
      else
        StretchBlt(dc, DestBnd.X, DestBnd.Y, DestBnd.Width, DestBnd.Height, MyDC,
          SrcBnd.X, SrcBnd.Y, SrcBnd.Width, SrcBnd.Height,
          SRCCOPY);
    finally
      if RestorePalette then
        SelectPalette(dc, OldPalette, True);
    end;
  end;
end;

procedure TRnQBitmap.MakeEmpty;
var
  hbr: HBRUSH;
begin
 if Assigned(fBmp) then
  begin
   fBmp.TransparentMode := tmAuto;
   fBmp.Transparent := True;
  // loadedpic.fTransparentColor := loadedpic.fBmp.TransparentColor;
   fTransparentColor := ColorToRGB(fBmp.TransparentColor);
   hbr := CreateSolidBrush(fTransparentColor);
   FillRect(fBmp.Canvas.Handle, fBmp.Canvas.ClipRect, hbr);
   DeleteObject(hbr);
  end;
end;

procedure TRnQBitmap.MaskDraw(DC: HDC; const DX, DY: Integer);
{Draw parts of this bitmap on ACanvas}
var
  OldPalette, myPalette: HPalette;
  RestorePalette: Boolean;
  DoHalftone: Boolean;
  Pt: TPoint;
  BPP: Integer;
begin
//  with DestRect do
  begin
//    AHandle := dc;  {LDB}
    myPalette := fBmp.Palette;
//    PaletteNeeded;
    OldPalette := 0;
    RestorePalette := False;

    if myPalette <> 0 then
    begin
      OldPalette := SelectPalette(dc, myPalette, True);
      RealizePalette(dc);
      RestorePalette := True;
    end;
    BPP := GetDeviceCaps(dc, BITSPIXEL) *
      GetDeviceCaps(dc, PLANES);
    DoHalftone := (BPP <= 8) and (fBmp.PixelFormat in [pf15bit, pf16bit, pf24bit]);
    if DoHalftone then
    begin
      GetBrushOrgEx(dc, pt);
      SetStretchBltMode(dc, HALFTONE);
      SetBrushOrgEx(dc, pt.x, pt.y, @pt);
    end else if not fBmp.Monochrome then
      SetStretchBltMode(dc, STRETCH_DELETESCANS);
    try
//      AHandle := dc;   {LDB}
      if htTransparent then
        TransparentStretchBlt(dc, DX, DY, fWidth, fHeight, fBmp.Canvas.Handle,
            0, 0, fWidth, fHeight,
            htMask.Canvas.Handle, 0, 0)   {LDB}
      else
       BitBlt(DC, DX, DY, fWidth, fHeight,
        fbmp.Canvas.Handle, 0, 0, SrcCopy);

//        StretchBlt(dc, Left, Top, Right - Left, Bottom - Top,
//          fBmp.Canvas.Handle,
//          SrcRect.Left, SrcRect.Top, SrcRect.Right - SrcRect.Left, SrcRect.Bottom - SrcRect.Top,
//          SRCCOPY);
    finally
      if RestorePalette then
        SelectPalette(dc, OldPalette, True);
    end;
  end;
end;


 {$IFNDEF NO_WIN98}
procedure DrawTransparentBitmapRect(DC: HDC; Bitmap: HBitmap; xStart, yStart,
  Width, Height: Integer; Rect: TRect; TransparentColor: TColorRef);
var
{$IFDEF WIN32}
  BM: Windows.TBitmap;
{$ELSE}
  BM: WinTypes.TBitmap;
{$ENDIF}
  cColor: TColorRef;
  bmAndBack, bmAndObject, bmAndMem, bmSave: HBitmap;
  bmBackOld, bmObjectOld, bmMemOld, bmSaveOld: HBitmap;
  hdcMem, hdcBack, hdcObject, hdcTemp, hdcSave: HDC;
  ptSize, ptRealSize, ptBitSize, ptOrigin: TPoint;
begin
  hdcTemp := CreateCompatibleDC(DC);
  SelectObject(hdcTemp, Bitmap);      { Select the bitmap    }
  GetObject(Bitmap, SizeOf(BM), @BM);
  ptRealSize.x := Min(Rect.Right - Rect.Left, BM.bmWidth - Rect.Left);
  ptRealSize.y := Min(Rect.Bottom - Rect.Top, BM.bmHeight - Rect.Top);
  DPtoLP(hdcTemp, ptRealSize, 1);
  ptOrigin.x := Rect.Left;
  ptOrigin.y := Rect.Top;
  DPtoLP(hdcTemp, ptOrigin, 1);       { Convert from device  }
                                      { to logical points    }
  ptBitSize.x := BM.bmWidth;          { Get width of bitmap  }
  ptBitSize.y := BM.bmHeight;         { Get height of bitmap }
  DPtoLP(hdcTemp, ptBitSize, 1);
  if (ptRealSize.x = 0) or (ptRealSize.y = 0) then begin
    ptSize := ptBitSize;
    ptRealSize := ptSize;
  end
  else ptSize := ptRealSize;
  if (Width = 0) or (Height = 0) then begin
    Width := ptSize.x;
    Height := ptSize.y;
  end;

  { Create some DCs to hold temporary data }
  hdcBack   := CreateCompatibleDC(DC);
  hdcObject := CreateCompatibleDC(DC);
  hdcMem    := CreateCompatibleDC(DC);
  hdcSave   := CreateCompatibleDC(DC);
  { Create a bitmap for each DC. DCs are required for a number of }
  { GDI functions                                                 }
  { Monochrome DC }
  bmAndBack   := Windows.CreateBitmap(ptSize.x, ptSize.y, 1, 1, nil);
  bmAndObject := Windows.CreateBitmap(ptSize.x, ptSize.y, 1, 1, nil);
  bmAndMem    := CreateCompatibleBitmap(DC, Max(ptSize.x, Width), Max(ptSize.y, Height));
  bmSave      := CreateCompatibleBitmap(DC, ptBitSize.x, ptBitSize.y);
  { Each DC must select a bitmap object to store pixel data }
  bmBackOld   := SelectObject(hdcBack, bmAndBack);
  bmObjectOld := SelectObject(hdcObject, bmAndObject);
  bmMemOld    := SelectObject(hdcMem, bmAndMem);
  bmSaveOld   := SelectObject(hdcSave, bmSave);
  { Set proper mapping mode }
  SetMapMode(hdcTemp, GetMapMode(DC));

  { Save the bitmap sent here, because it will be overwritten }
  BitBlt(hdcSave, 0, 0, ptBitSize.x, ptBitSize.y, hdcTemp, 0, 0, SRCCOPY);
  { Set the background color of the source DC to the color,         }
  { contained in the parts of the bitmap that should be transparent }
  cColor := SetBkColor(hdcTemp, TransparentColor);
  { Create the object mask for the bitmap by performing a BitBlt()  }
  { from the source bitmap to a monochrome bitmap                   }
  BitBlt(hdcObject, 0, 0, ptSize.x, ptSize.y, hdcTemp, ptOrigin.x, ptOrigin.y,
    SRCCOPY);
  { Set the background color of the source DC back to the original  }
  { color                                                           }
  SetBkColor(hdcTemp, cColor);
  { Create the inverse of the object mask }
  BitBlt(hdcBack, 0, 0, ptSize.x, ptSize.y, hdcObject, 0, 0,
    NOTSRCCOPY);
  { Copy the background of the main DC to the destination }
  BitBlt(hdcMem, 0, 0, Width, Height, DC, xStart, yStart,
    SRCCOPY);
  { Mask out the places where the bitmap will be placed }
  StretchBlt(hdcMem, 0, 0, Width, Height, hdcObject, 0, 0,
    ptSize.x, ptSize.y, SRCAND);
  {BitBlt(hdcMem, 0, 0, ptSize.x, ptSize.y, hdcObject, 0, 0, SRCAND);}
  { Mask out the transparent colored pixels on the bitmap }
  BitBlt(hdcTemp, ptOrigin.x, ptOrigin.y, ptSize.x, ptSize.y, hdcBack, 0, 0,
    SRCAND);
  { XOR the bitmap with the background on the destination DC }
  StretchBlt(hdcMem, 0, 0, Width, Height, hdcTemp, ptOrigin.x, ptOrigin.y,
    ptSize.x, ptSize.y, SRCPAINT);
  {BitBlt(hdcMem, 0, 0, ptSize.x, ptSize.y, hdcTemp, ptOrigin.x, ptOrigin.y,
    SRCPAINT);}
  { Copy the destination to the screen }
  BitBlt(DC, xStart, yStart, Max(ptRealSize.x, Width), Max(ptRealSize.y, Height),
    hdcMem, 0, 0, SRCCOPY);
  { Place the original bitmap back into the bitmap sent here }
  BitBlt(hdcTemp, 0, 0, ptBitSize.x, ptBitSize.y, hdcSave, 0, 0, SRCCOPY);

  { Delete the memory bitmaps }
  DeleteObject(SelectObject(hdcBack, bmBackOld));
  DeleteObject(SelectObject(hdcObject, bmObjectOld));
  DeleteObject(SelectObject(hdcMem, bmMemOld));
  DeleteObject(SelectObject(hdcSave, bmSaveOld));
  { Delete the memory DCs }
  DeleteDC(hdcMem);
  DeleteDC(hdcBack);
  DeleteDC(hdcObject);
  DeleteDC(hdcSave);
  DeleteDC(hdcTemp);
end;

procedure DrawTransparentBitmap(dc:HDC;DrawBitmap: HBitmap; DestBnd:TGPRect; srcW, srcH : Integer; cTransparentColor:COLORREF);
var
  cColor:  COLORREF;
  bmAndBack,bmAndObject,bmAndMem:HBITMAP;
  bmBackOld,bmObjectOld,bmMemOld:HBITMAP;
  hdcMem,hdcBack,hdcObject,hdcTemp:HDC;
//  ptSize,
  orgSize:TPOINT;
  OldBitmap
  //,DrawBitmap
  :HBITMAP;
begin
  hdcTemp:=CreateCompatibleDC(dc);
//  DrawBitmap:=CreateDIBitmap(dc,srcHeader,CBM_INIT,srcBits,srcBitmapInfo^,DIB_RGB_COLORS);
  OldBitmap:=SelectObject(hdcTemp,DrawBitmap);
//  OrgSize.x:=Abs(srcHeader.biWidth);
//  OrgSize.y:=Abs(srcHeader.biHeight);
  OrgSize.x:=srcW;
  OrgSize.y:=srcH;

//  ptSize.x:=DestBnd.Width;
//  ptSize.y:=DestR.Bottom-DestR.Top;
  hdcBack:=CreateCompatibleDC(dc);
  hdcObject:=CreateCompatibleDC(dc);
  hdcMem:=CreateCompatibleDC(dc);
  bmAndBack:=   Windows.CreateBitmap(DestBnd.Width,DestBnd.Height, 1,1,nil);
  bmAndObject:= Windows.CreateBitmap(DestBnd.Width,DestBnd.Height, 1,1,nil);
  bmAndMem:=    Windows.CreateCompatibleBitmap(dc,DestBnd.Width, DestBnd.Height);
  bmBackOld:=  SelectObject(hdcBack,bmAndBack);
  bmObjectOld:=SelectObject(hdcObject,bmAndObject);
  bmMemOld:=   SelectObject(hdcMem,bmAndMem);
  cColor:=SetBkColor(hdcTemp,cTransparentColor);
  StretchBlt(hdcObject,0,0,DestBnd.Width,DestBnd.Height,hdcTemp,0,0,orgSize.x,orgSize.y,SRCCOPY);
  SetBkColor(hdcTemp,cColor);
  BitBlt(hdcBack,0,0,DestBnd.Width,DestBnd.Height,hdcObject,0,0,NOTSRCCOPY);
  BitBlt(hdcMem,0,0,DestBnd.Width,DestBnd.Height,dc,DestBnd.X,DestBnd.Y,SRCCOPY);
  BitBlt(hdcMem,0,0,DestBnd.Width,DestBnd.Height,hdcObject,0,0,SRCAND);
  StretchBlt(hdcTemp,0,0,OrgSize.x,OrgSize.y,hdcBack,0,0,DestBnd.Width,DestBnd.Height,SRCAND);
  StretchBlt(hdcMem,0,0,DestBnd.Width,DestBnd.Height,hdcTemp,0,0,OrgSize.x,OrgSize.y,SRCPAINT);
  BitBlt(dc, DestBnd.X,DestBnd.Y, DestBnd.Width,DestBnd.Height,hdcMem,0,0,SRCCOPY);
  DeleteObject(SelectObject(hdcBack,bmBackOld));
  DeleteObject(SelectObject(hdcObject,bmObjectOld));
  DeleteObject(SelectObject(hdcMem,bmMemOld));
    SelectObject(hdcTemp,OldBitmap);
//  DeleteObject(SelectObject(hdcTemp,OldBitmap));
  DeleteDC(hdcMem);
  DeleteDC(hdcBack);
  DeleteDC(hdcObject);
  DeleteDC(hdcTemp);
end;
 {$ENDIF NO_WIN98}


//procedure TRnQBitmap.Draw(DC: HDC; DestR: TRect; SrcX, SrcY, SrcW, SrcH: Integer; pEnabled: Boolean= True; isCopy: Boolean= false);
procedure TRnQBitmap.Draw(DC: HDC; DestBnd, SrcBnd: TGPRect; pEnabled: Boolean= True; isCopy32: Boolean= false);
var
    blend: BLENDFUNCTION;
    hBMP: HDC;
    ico: HICON;
  {$IFNDEF NO_WIN98}
    tBMP: TRnQBitmap;
    tempBitmap: TBitmap;
  {$ENDIF NO_WIN98}
    LeftTop: TGPPoint;
//    p: TPoint;
 {$IFNDEF NO_WIN98}
    sz: TSize;
 {$ENDIF NO_WIN98}
begin
  if fAnimated then
    begin
      with fFrames[FCurrentFrame] do
        begin
(*         LeftTop.X := SrcX+ (FCurrentFrame-1)*Width;
//         SRect := Rect(ALeft, 0, ALeft+Width, Height); {current frame location in Strip bitmap}
//         FStretchedRect := Rect(X, Y, X+Width, Y+Height);
         LeftTop.Y := SrcY;
*)
         LeftTop := SrcBnd.TopLeft;
//         inc(LeftTop.X, (FCurrentFrame-1)*Width);
         inc(LeftTop.Y, (FCurrentFrame-1)* Height);
        end;
    end
   else
    begin
//      LeftTop.X := SrcX;
//      LeftTop.Y := SrcY;
      LeftTop := SrcBnd.TopLeft;
    end;
    if Assigned(fBmp) then
    begin
     if f32Alpha then
      begin
        if not isCopy32 then
          blend.AlphaFormat     := AC_SRC_ALPHA
         else
          blend.AlphaFormat     := AC_SRC_OVER;
       blend.BlendOp            := AC_SRC_OVER;

       blend.BlendFlags         := 0;
       if not pEnabled then
         blend.SourceConstantAlpha := 100
        else
         blend.SourceConstantAlpha := $FF;

       //StretchDIBits(DC,DX,DY,Width,Height,0, 0, Width, Height,pAND, PBitmapInfo(@iAND)^, DIB_RGB_COLORS,SRCAND);
       {$IFNDEF NO_WIN98}
       if  Win32MajorVersion < 5 then
        begin
         tBMP := Self.Clone(SrcBnd);
         hBMP := tBMP.fBmp.Canvas.Handle;
//         SrcW := min(DestR.Right-DestR.Left, SrcW);
//         SrcH := min(DestR.Bottom - DestR.Top, SrcH);
         sz.cx := min(DestBnd.Width, SrcBnd.Width);
         sz.cy := min(DestBnd.Height, SrcBnd.Height);
         tempBitmap := createBitmap(SrcBnd.Width, SrcBnd.Height);
         tempBitmap.PixelFormat := pf32bit;
         BitBlt(tempBitmap.Canvas.Handle, 0, 0, SrcBnd.Width, SrcBnd.Height, DC, DestBnd.X, DestBnd.Y, SRCCOPY);
//         Windows.AlphaBlend(DC, DestR.Left, DestR.Top, SrcW, SrcH, HBMP, 0, 0, SrcW, SrcH, blend);
         Windows.AlphaBlend(tempBitmap.Canvas.Handle, 0, 0, sz.cx, sz.cy, HBMP,
              0, 0, sz.cx, sz.cy, blend);
//         BitBlt(tempBitmap.Canvas.Handle, 0, 0, SrcW, SrcH, HBMP, 0, 0, SRCCOPY);
         tBMP.Free;
         BitBlt(DC, DestBnd.X, DestBnd.Y, sz.cx, sz.cy, tempBitmap.Canvas.Handle, 0, 0, SRCCOPY);
         tempBitmap.Free;
        end
        else
       {$ENDIF NO_WIN98}
         begin
          hBMP := fBmp.Canvas.Handle;
//       fBmp.Canvas.Lock;
        {$IFDEF FPC}
          //JwaWinGDI.
        {$ELSE ~FPC}
          Windows.
        {$ENDIF ~FPC}
          AlphaBlend(DC, DestBnd.X, DestBnd.Y, DestBnd.Width, DestBnd.Height,
            HBMP, SrcBnd.X, SrcBnd.Y, SrcBnd.Width, SrcBnd.Height, blend);
         end;
//       fBmp.Canvas.Unlock;
      end
     else
     if fBmp.Transparent then
      begin
       {$IFNDEF NO_WIN98}
       if  Win32MajorVersion < 5 then
        begin
         tBMP := Self.Clone(SrcBnd);
//         hBMP := tBMP.fBmp.Canvas.Handle;
         hBMP := tBMP.fBmp.Handle;
         sz.cx := min(DestBnd.Width, SrcBnd.Width);
         sz.cy := min(DestBnd.Height, SrcBnd.Height);
//         SrcW := min(DestR.Right-DestR.Left, SrcBnd.);
//         SrcH := min(DestR.Bottom - DestR.Top, SrcH);

//         TransparentBlt(DC, DestR.Left, DestR.Top, DestR.Right-DestR.Left, DestR.Bottom - DestR.Top,
//           hBMP, 0, 0, SrcW, SrcH, fTransparentColor) and not AlphaMask);
         DrawTransparentBitmap(DC, hBMP, DestBnd,
           sz.cx, sz.cy, fTransparentColor and not AlphaMask);
         tBMP.Free;
        end
        else
       {$ENDIF NO_WIN98}
       TransparentBlt(DC, DestBnd.X, DestBnd.Y, DestBnd.Width, DestBnd.Height,
        fbmp.Canvas.Handle, LeftTop.X, LeftTop.Y, SrcBnd.Width, SrcBnd.Height, fTransparentColor and not AlphaMask)
{        begin
          blend.AlphaFormat         := AC_SRC_ALPHA
  //       else
//          blend.AlphaFormat         := AC_SRC_OVER
          ;
         blend.BlendOp             := AC_SRC_OVER;
//         blend.BlendFlags          := AC_SRC_NO_ALPHA;
         blend.BlendFlags          := 0;
         if not pEnabled then
           blend.SourceConstantAlpha := 100
          else
           blend.SourceConstantAlpha := $FF;
         //StretchDIBits(DC,DX,DY,Width,Height,0, 0, Width, Height,pAND, PBitmapInfo(@iAND)^, DIB_RGB_COLORS,SRCAND);
          hBMP := fBmp.Canvas.Handle;
//       fBmp.Canvas.Lock;
          Windows.AlphaBlend(DC, DestR.Left, DestR.Top, DestR.Right-DestR.Left, DestR.Bottom - DestR.Top,
            HBMP, SrcX, SrcY, SrcW, SrcH, blend);
        end}
//       TransparentStretchBlt(DC, DestR.Left, DestR.Top, DestR.Right-DestR.Left, DestR.Bottom - DestR.Top,
//        fbmp.Canvas.Handle, SrcX, SrcY, SrcW, SrcH, fbmp.ma, SrcX, SrcY)
      end
     else
      if htTransparent then
       MaskDraw(DC, DestBnd, makeRect(LeftTop, SrcBnd.size))
      else
        begin
//      MaskBlt(DC, DestR.Left, DestR.Top, DestR.Right-DestR.Left, DestR.Bottom - DestR.Top,
//       fbmp.Canvas.Handle, SrcX, SrcY, fBmp.MaskHandle, 0, 0, SrcCopy);
//         if not isCopy32 then
           StretchBlt(DC, DestBnd.X, DestBnd.Y, DestBnd.Width, DestBnd.Height,
              fbmp.Canvas.Handle, LeftTop.X, LeftTop.Y, SrcBnd.Width, SrcBnd.Height, SrcCopy)
{          else
          begin
            blend.AlphaFormat    := AC_SRC_OVER;
            blend.BlendOp        := AC_SRC_OVER;

            blend.BlendFlags         := AC_SRC_NO_PREMULT_ALPHA;
//            blend.BlendFlags         := 0;
            if not pEnabled then
              blend.SourceConstantAlpha := 100
             else
              blend.SourceConstantAlpha := $FF;
            Windows.AlphaBlend(DC, DestBnd.X, DestBnd.Y, DestBnd.Width, DestBnd.Height,
              fbmp.Canvas.Handle,LeftTop.X, LeftTop.Y, SrcBnd.Width, SrcBnd.Height, blend);
          end;}
        end;

    end
  else
   if fHI > 0 then
    begin
     ico := CopyImage(fHI, IMAGE_ICON, DestBnd.Width, DestBnd.Height, LR_COPYFROMRESOURCE);
//     DrawIconEx(AboutPBox.Canvas.Handle, 0, 0, ico, 48, 48, 0, 0, DI_NORMAL);
//     DrawIconEx(DC, DestR.Left, DestR.Top, fHI, DestR.Right-DestR.Left, DestR.Bottom-DestR.Top, 0, 0, DI_NORMAL);
     DrawIconEx(DC, DestBnd.X, DestBnd.Y, ico, DestBnd.Width, DestBnd.Height, 0, 0, DI_NORMAL);
     DeleteObject(ico);
    end;
end;

procedure TRnQBitmap.Draw(DC: HDC; DestR: TGPRect);
begin
  Draw(DC, DestR, makerect(0, 0, fWidth, fHeight));
end;

procedure TRnQBitmap.Draw(DC: HDC; DX, DY: Integer);
var
    blend: BLENDFUNCTION;
    LeftTop: TPoint;
    MyDC: HDC;
begin
  if fAnimated then
    begin
//      with fFrames[FCurrentFrame] do
        begin
//         LeftTop.X := (FCurrentFrame-1)*Width;
//         LeftTop.Y := 0;

         LeftTop.X := 0;
         LeftTop.Y := (FCurrentFrame-1)* Height;
        end;
    end
   else
    begin
      LeftTop.X := 0;
      LeftTop.Y := 0;
    end;
{  if Assigned(fBMP32) then
    begin
      if f32Alpha then
       Draw32Native(DC, Rect(DX, DY, DX+fWidth, DY+fHeight),
                @fBmp32.BitmapInfo, fBmp32.Bits)
//       Draw32bit(DC, DX, DY)
      else
       fBMP32.DrawTo(DC, DX, DY);
    end
   else}
    if Assigned(fBmp) then
    begin
     MyDC := fBmp.Canvas.Handle;
     if f32Alpha then
      begin
        blend.AlphaFormat         := AC_SRC_ALPHA
//       else
//        blend.AlphaFormat         := AC_SRC_OVER
        ;
       blend.BlendOp             := AC_SRC_OVER;
       blend.BlendFlags          := 0;
       blend.SourceConstantAlpha := $FF;
       //StretchDIBits(DC,DX,DY,Width,Height,0, 0, Width, Height,pAND, PBitmapInfo(@iAND)^, DIB_RGB_COLORS,SRCAND);
       {$IFDEF FPC}
         //JwaWinGDI.
       {$ELSE ~FPC}
         Windows.
       {$ENDIF ~FPC}
//         if not
           AlphaBlend(DC, DX, DY, fWidth, fHeight, MyDC,
                              LeftTop.X, LeftTop.Y, fWidth, fHeight, blend)
      end
     else
     if fBmp.Transparent then
       {$IFNDEF NO_WIN98}
      if  Win32MajorVersion < 5 then
         DrawTransparentBitmap(DC, fbmp.Handle, MakeRect(DX, DY, fWidth, fHeight),
                               fWidth, fHeight, fTransparentColor and (not AlphaMask))
       else
       {$ENDIF NO_WIN98}
        TransparentBlt(DC, DX, DY, fWidth, fHeight,
          MyDC, LeftTop.X, LeftTop.Y, fWidth, fHeight, fTransparentColor and (not AlphaMask))
{
        begin
          blend.AlphaFormat         := AC_SRC_ALPHA
  //       else
  //        blend.AlphaFormat         := AC_SRC_OVER
          ;
         blend.BlendOp             := AC_SRC_OVER;
         blend.BlendFlags          := AC_SRC_NO_ALPHA;
         blend.SourceConstantAlpha := $FF;
         //StretchDIBits(DC,DX,DY,Width,Height,0, 0, Width, Height,pAND, PBitmapInfo(@iAND)^, DIB_RGB_COLORS,SRCAND);
         Windows.AlphaBlend(DC, DX, DY, fWidth, fHeight, MyDC,
                                LeftTop.X, LeftTop.Y, fWidth, fHeight, blend);
        end
}
     else
      if htTransparent then
//       MaskDraw(DC, DX, DY)
       MaskDraw(DC, MakeRect(DX, DY, fWidth, fHeight),
                    MakeRect(LeftTop.X, LeftTop.Y, fWidth, fHeight))
      else
//      MaskBlt(DC, DX, DY, fWidth, fHeight,
//       fbmp.Canvas.Handle, 0, 0, fBmp.MaskHandle, 0, 0, SrcCopy);
//       StretchBlt(DC, DX, DY, fWidth, fHeight,
//        fbmp.Canvas.Handle, 0, 0, fWidth, fHeight, SrcCopy);
      BitBlt(DC, DX, DY, fWidth, fHeight, MyDC, LeftTop.X, LeftTop.Y, SrcCopy);
    end
  else
   if fHI > 0 then
    DrawIconEx(DC, DX, DY, fHI, 0, 0, 0, 0, DI_NORMAL);
end;

//type
//  PColor32 = ^TColor32;
//  TColor32 = type Cardinal;
// in new Delphi we have TAlphaColor in UITypes
  function SetAlpha(Color32: TAlphaColor; NewAlpha: Byte): TAlphaColor; {$IFDEF HAS_INLINE}inline;{$ENDIF HAS_INLINE}
    begin
{      if NewAlpha <= 0 then
//       NewAlpha := 0
        Result := (Color32 and $00FFFFFF)
       else
        if NewAlpha > 255 then
//          NewAlpha := 255;
          Result := AlphaMask or (Color32 and $00FFFFFF)
         else}
          Result := (Color32 and $00FFFFFF) or (NewAlpha shl 24);
    end;


//function  TRnQBitmap.Clone(x, y, pWidth, pHeight: Integer): TRnQBitmap;
function  TRnQBitmap.Clone(bnd: TGPRect): TRnQBitmap;
var
{
  PB, //:PByte;
  PC:PColor32;
  r, C:Cardinal;
}
//    b: Byte;
//    bi: TBitmapInfo;
//    biSize: Cardinal;
//    arr: TMAXBITMAPINFO;
//    blend: BLENDFUNCTION;
  MyDC: HDC;
  i: Integer;
  Frame: TAniFrame;
begin
  if Assigned(fBmp) then
  begin
    Result := TRnQBitmap.Create(bnd.Width, bnd.Height);
    Result.f32Alpha := f32Alpha;
    Result.fTransparentColor := fTransparentColor;
    if (fBmp.Width=0) or (fBmp.Height=0) then exit;
    MyDC := fBmp.Canvas.Handle;
    SetStretchBltMode(MyDC,COLORONCOLOR);
    if f32Alpha then
      Result.fBmp.PixelFormat := pf32bit
     else
      begin
        Result.fBmp.PixelFormat := fBmp.PixelFormat;
        if fBmp.Transparent then
         begin
           Result.fBmp.Transparent := True;
           Result.fBmp.TransparentColor := fBmp.TransparentColor;
         end;
      end;
    if Animated and (bnd.X=0)and(bnd.Y=0)and(bnd.Width=Width)and(bnd.Height=Height)  then
     begin
        Result.fFormat := PA_FORMAT_UNK;
        Result.FNumFrames := FNumFrames;
        Result.FAnimated := Result.FNumFrames > 1;
        Result.FWidth := FWidth;
        Result.FHeight := FHeight;
        Result.FNumIterations := FNumIterations;
        Result.htTransparent := htTransparent;
         begin
    //      Strip := ThtBitmap.Create;
//           if fBmp.Width > fWidth then
           if fBmp.Height > fHeight then
             begin
               Result.fBmp.Height := 0;
               {$IFDEF DELPHI9_UP}
                Result.fBmp.SetSize(fBmp.Width, fBmp.Height);
               {$ELSE DELPHI9_UP}
                Result.fBmp.width  := fBmp.Width;
                Result.fBmp.height := fBmp.Height;
               {$ENDIF DELPHI9_UP}
             end;
           BitBlt(Result.fBmp.Canvas.Handle, 0, 0, fBmp.Width, fBmp.Height,
               MyDC, 0, 0, SRCCOPY);
           if Assigned(htMask) then
             begin
               Result.htMask := TBitmap.Create;
               Result.htMask.Assign(htMask);
               Result.htTransparent := True;
             end
            else
              begin
               Result.htMask := NIL;
               Result.htTransparent := false;
              end;
          if Result.fBmp.Palette <> 0 then
          DeleteObject(Result.fBmp.ReleasePalette);
          Result.fBmp.Palette := CopyPalette(fBmp.Palette);
         end;
         if not Assigned(Result.fFrames) then
           Result.fFrames := TAniFrameList.Create;
         for I := 1 to Result.FNumFrames do
          begin
            Frame := TAniFrame.Create;
            try
              Frame.frDisposalMethod := fFrames[i].frDisposalMethod;
              Frame.frLeft := fFrames[i].frLeft;
              Frame.frTop := fFrames[i].frTop;
              Frame.frWidth := fFrames[i].frWidth;
              Frame.frHeight := fFrames[i].frHeight;
              Frame.frDelay := fFrames[i].frDelay;
             except
              Frame.Free;
              Raise;
            end;
            Result.fFrames.Add(Frame);
          end;
          Result.WasDisposal := dtToBackground;
     end
   else
{  case fBmp.PixelFormat of
      pfDevice, pf24bit, pf32bit: b := 24;
      pf1bit: b := 1;
      pf4bit: b := 4;
      pf8bit: b := 8;
      pf15bit: b := 15;
      pf16bit: b := 16;
  end;
 GetDIBSizes(fBmp.Handle, biSize, r);
// bi.bmiColors := arr;
// SetLength(bi.bmiColors, (biSize - sizeof(bi.bmiHeader))div SIZEOF(TRGBQuad) );
// GetDIB(fBmp.Handle, fBmp.Palette, bi)
// StretchDiBits(Result.fBmp.Canvas.Handle,0,0,width, height,
//               x,y, width, height, b, bi
//               pBitmapInfo(@PNG.Header.BitmapInfo)^,DIB_RGB_COLORS,SRCCOPY);
}
//        blend.AlphaFormat        := AC_SRC_ALPHA;
//   if (not CheckWin32Version(5,1))or not f32Alpha then
//   if ( Win32MajorVersion < 6)or not f32Alpha then
//   if not f32Alpha or
//      not((Win32MajorVersion > 5)or((Win32MajorVersion = 5)and(Win32MinorVersion >= 1))) then
   if 1=1 then
     begin
       BitBlt(Result.fBmp.Canvas.Handle, 0, 0, bnd.width, bnd.height,
           MyDC, bnd.x, bnd.y, SRCCOPY);
// if PNG.Header.ColorType in [COLOR_GRAYSCALEALPHA,COLOR_RGBALPHA] then
{      if f32Alpha then
       begin
         for R:=0 to bnd.height-1 do
          begin
           PB:=Pointer(Self.fBmp.ScanLine[r+bnd.Y]);
           if PB<>nil then
           begin
            inc(PB, bnd.x);
            PC:=Pointer(Result.fBmp.ScanLine[r]);
            for C:=0 to bnd.width-1 do
             begin
              PC^:=SetAlpha(PC^,PByte(PB)^);
              Inc(PB); Inc(PC);
             end;
           end;
         end;
       end;}
     end
    else
     begin
{       blend.AlphaFormat         := AC_SRC_OVER;
       blend.BlendOp             := AC_SRC_OVER;
       blend.BlendFlags          := 0;
//       if not pEnabled then
//         blend.SourceConstantAlpha := 100
//        else
       blend.SourceConstantAlpha := $FF;

       Windows.AlphaBlend(Result.fBmp.Canvas.Handle, 0, 0, bnd.width, bnd.height,
                       MyDC, bnd.X, bnd.y, bnd.width, bnd.height, blend);
}
     end;
//  if f32Alpha then
//   else
//    BitBlt(Result.fBmp.Canvas.Handle, 0, 0, width, height,
//           fBmp.Canvas.Handle, x, y, SRCCOPY);

  end
  else
   if fHI > 0 then
    begin
      Result := TRnQBitmap.Create;
      Result.f32Alpha := f32Alpha;
      Result.fHI := CopyIcon(fHI);
      Result.fWidth := fWidth;
      Result.fHeight := fHeight;
    end
   else
    result := NIL;
end;

function  TRnQBitmap.CloneFrame(frame: Integer): TRnQBitmap;
var
    LeftTop: TPoint;
//var
//  PB, //  : PByte;
//    PC: PColor32;
//    b: Byte;
//    bi: TBitmapInfo;
//    biSize: Cardinal;
//    arr: TMAXBITMAPINFO;
//    C: Cardinal;
//    r: Integer;
var
  SRect: TRect;
  blend: BLENDFUNCTION;
begin
  if frame >=0 then
    SetCurrentFrame(frame);
  if fAnimated then
    begin
      with fFrames[FCurrentFrame] do
        begin
//         LeftTop.X := (FCurrentFrame-1)*Width;
//         LeftTop.Y := 0;
         LeftTop.X := 0;
         LeftTop.Y := (FCurrentFrame-1)* Height;
        end;
    end
   else
    begin
      LeftTop.X := 0;
      LeftTop.Y := 0;
    end;
//  Result := TRnQBitmap.Create;
//  Result.f32Alpha := f32Alpha;
//  Result.fBmp :=  (fHI);
//  Result.fWidth := fWidth;
//  Result.fHeight := fHeight;
  if Assigned(fBmp) then
  begin
    Result := TRnQBitmap.Create(width, height);
    Result.f32Alpha := f32Alpha;
//    B32.SetSize(PNG.Width,PNG.Height);
    if (fBmp.Width=0) or (fBmp.Height=0) then
      exit;
//    SetStretchBltMode(fBmp.Canvas.Handle,COLORONCOLOR);
    if f32Alpha then
      Result.fBmp.PixelFormat := pf32bit
     else
      Result.fBmp.PixelFormat := pf24bit;
{  case fBmp.PixelFormat of
      pfDevice, pf24bit, pf32bit: b := 24;
      pf1bit: b := 1;
      pf4bit: b := 4;
      pf8bit: b := 8;
      pf15bit: b := 15;
      pf16bit: b := 16;
  end;
 GetDIBSizes(fBmp.Handle, biSize, r);
// bi.bmiColors := arr;
// SetLength(bi.bmiColors, (biSize - sizeof(bi.bmiHeader))div SIZEOF(TRGBQuad) );
// GetDIB(fBmp.Handle, fBmp.Palette, bi)
// StretchDiBits(Result.fBmp.Canvas.Handle,0,0,width, height,
//               x,y, width, height, b, bi
//               pBitmapInfo(@PNG.Header.BitmapInfo)^,DIB_RGB_COLORS,SRCCOPY);
}
// if PNG.Header.ColorType in [COLOR_GRAYSCALEALPHA,COLOR_RGBALPHA] then
  if f32Alpha then
  begin
//        blend.AlphaFormat        := AC_SRC_ALPHA;
       blend.AlphaFormat         := AC_SRC_OVER;
       blend.BlendOp             := AC_SRC_OVER;
       blend.BlendFlags          := 0;
//       if not pEnabled then
//         blend.SourceConstantAlpha := 100
//        else
       blend.SourceConstantAlpha := $FF;
       {$IFDEF FPC}
         //JwaWinGDI.
       {$ELSE ~FPC}
         Windows.
       {$ENDIF ~FPC}
           AlphaBlend(Result.fBmp.Canvas.Handle, 0, 0, width, height,
                       fBmp.Canvas.Handle, LeftTop.X, LeftTop.y, width, height, blend);
{    BitBlt(Result.fBmp.Canvas.Handle, 0, 0, width, height,
           fBmp.Canvas.Handle, LeftTop.X, LeftTop.y, SRCCOPY);
     for R:=LeftTop.y to LeftTop.y+Height-1 do
      begin
       PB:=Pointer(Self.fBmp.ScanLine[r]);
       if PB<>nil then
       begin
        inc(PB, LeftTop.X);
        PC:=Pointer(Result.fBmp.ScanLine[r-LeftTop.y]);
        for C:=0 to width-1 do
         begin
          PC^:=SetAlpha(PC^,PByte(PB)^);
          Inc(PB); Inc(PC);
         end;
       end;
     end;}
   end
//  if f32Alpha then
   else
    begin

//  FMaskedBitmap := TBitmap.Create;
//  FMaskedBitmap.Assign(Strip);

   {$IFDEF FPC}
     SRect := Rect(LeftTop.x, LeftTop.y, LeftTop.X+Width, LeftTop.Y+Height); {current frame location in Strip bitmap}
   {$ELSE ~FPC}
     SRect := Rect(LeftTop, Point(LeftTop.X+Width, LeftTop.Y+Height)); {current frame location in Strip bitmap}
   {$ENDIF ~FPC}
{
     Result.fBmp.Assign(fBmp);
     Result.fBmp.Canvas.CopyRect(Rect(0, 0, Width, Height), Result.fBmp.Canvas, SRect);
     Result.fBmp.Width := FWidth;
}
 {$IFDEF DELPHI9_UP}
     Result.fBmp.SetSize(Width, Height);
 {$ELSE DELPHI_9_dn}
     Result.fBmp.Height := 0;
     Result.fBmp.Width := Width;
     Result.fBmp.Height := Height;
 {$ENDIF DELPHI9_UP}
     Result.fBmp.Canvas.CopyRect(Rect(0, 0, Width, Height), fBmp.Canvas, SRect);
     Result.fBmp.Transparent := fBmp.Transparent;
     Result.fBmp.TransparentColor := fBmp.TransparentColor;
     Result.fBmp.TransparentMode := fBmp.TransparentMode;

     if htTransparent then
      begin
        Result.htMask := TBitmap.Create;
{
        Result.htMask.Assign(htMask);
        Result.htMask.Canvas.CopyRect(Rect(0, 0, Width, Height), Result.htMask.Canvas, SRect);
        Result.htMask.Width := FWidth;
}
        Result.htMask.Monochrome := True;
 {$IFDEF DELPHI9_UP}
        Result.htMask.SetSize(Width, Height);
 {$ELSE DELPHI_9_dn}
        Result.htMask.Height := 0;
        Result.htMask.Width := Width;
        Result.htMask.Height := Height;
 {$ENDIF DELPHI9_UP}
        Result.htMask.Canvas.CopyRect(Rect(0, 0, Width, Height), htMask.Canvas, SRect);
        Result.htMask.Transparent := htMask.Transparent;
        Result.htMask.TransparentColor := htMask.TransparentColor;
        Result.htMask.TransparentMode := htMask.TransparentMode;

      end;
     Result.fBmp.Transparent := False;

//    fBmp.PixelFormat := ani.MaskedBitmap.PixelFormat;
//    fBmp.Width := ani.Width;
//    fBmp.Height := ani.Height;
//    fBmp.Assign(ani.MaskedBitmap);
//    ani.Draw(fBmp.Handle, 0, 0);

     Result.fFormat := PA_FORMAT_GIF;
     Result.htTransparent := htTransparent and Assigned(htMask);
    end;
//      BitBlt(Result.fBmp.Canvas.Handle, 0, 0, width, height,
//           fBmp.Canvas.Handle, x, y, SRCCOPY);
//    end;

  end
  else
   if fHI > 0 then
    begin
      Result := TRnQBitmap.Create;
      Result.f32Alpha := f32Alpha;
      Result.fHI := CopyIcon(fHI);
      Result.fWidth := fWidth;
      Result.fHeight := fHeight;
    end
   else
    result := NIL;
end;

function TRnQBitmap.bmp2ico32: HIcon;
const
   MaxRGBQuads = MaxInt div SizeOf(TRGBQuad) - 1;
type
   TRGBQuadArray = array[0..MaxRGBQuads] of TRGBQuad;
   PRGBQuadArray = ^TRGBQuadArray;
   TBitmapInfo4 = packed record
      bmiHeader: TBitmapV4Header;
      bmiColors: array[0..0] of TRGBQuad;
   end;
var
     ImageBits: PRGBQuadArray;
     BitmapInfo: TBitmapInfo4;
     IconInfo: TIconInfo;
     AlphaBitmap: HBitmap;
     MaskBitmap: TBitmap;
     X, Y: Integer;
//     AlphaLine: PByteArray;
//     HasAlpha, HasBitmask: Boolean;
//     Color, TransparencyColor: TColor;
     PB:PColor32;
begin
  //Convert a PNG object to an alpha-blended icon resource
  ImageBits := nil;

  //Allocate a DIB for the color data and alpha channel
  with BitmapInfo.bmiHeader do
  begin
     bV4Size := SizeOf(BitmapInfo.bmiHeader);
     bV4Width := Self.Width;
     bV4Height := Self.Height;
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
  AlphaBitmap := CreateDIBSection(0, PBitmapInfo(@BitmapInfo)^, DIB_RGB_COLORS, Pointer(ImageBits), 0, 0);
  try
    //Spin through and fill it with a wash of color and alpha.
//    AlphaLine := nil;
//    HasAlpha := Self.f32Alpha;// Png.Header.ColorType in [COLOR_GRAYSCALEALPHA, COLOR_RGBALPHA];
//    HasBitmask := Png.TransparencyMode = ptmBit;
//    HasBitmask := self.htTransparent;
//    TransparencyColor := self.fTransparentColor;
    for Y := 0 to Self.Height - 1 do
     begin
       PB := Pointer(Self.fBmp.ScanLine[self.Height - Y - 1]);
       if PB<>nil then
       begin
//        inc(PB, LeftTop.X);
//        PC:=Pointer(Result.fBmp.ScanLine[r-LeftTop.y]);
        for X := 0 to self.Width - 1 do
        with ImageBits^[Y * Self.Width + X] do
//        for C:=0 to width-1 do
         begin
          if Self.f32Alpha then
            rgbReserved := PAlphaColor(PB)^ shr 24 and $FF
           else
            if self.htTransparent then
              rgbReserved := Integer(PAlphaColor(PB)^ <> self.fTransparentColor) * $FF
             else
              rgbReserved := $FF 
            ;
          if rgbReserved = 0 then
            begin
             rgbBlue  := $7F;
             rgbGreen := $7F;
             rgbRed   := $7F;
            end
           else
            begin
  {           rgbRed := Pcolor32(PB)^ and $FF;
             rgbGreen := Pcolor32(PB)^ shr 8 and $FF;
             rgbBlue := Pcolor32(PB)^ shr 16 and $FF;}
             rgbBlue :=  PAlphaColor(PB)^ and $FF;
             rgbGreen := PAlphaColor(PB)^ shr 8 and $FF;
             rgbRed :=   PAlphaColor(PB)^ shr 16 and $FF;
            end;
          Inc(PB); // Inc(PC);
         end;
       end;
     end;

    //Create an empty mask
    MaskBitmap := TBitmap.Create;
    try
      MaskBitmap.Width := self.Width;
      MaskBitmap.Height := self.Height;
      MaskBitmap.PixelFormat := pf1bit;
      MaskBitmap.Canvas.Brush.Color := clBlack;
//      MaskBitmap.Canvas.Brush.Color := clWhite;
      MaskBitmap.Canvas.FillRect(Rect(0, 0, MaskBitmap.Width, MaskBitmap.Height));

      //Create the alpha blended icon
      IconInfo.fIcon := True;
      IconInfo.hbmColor := AlphaBitmap;
      IconInfo.hbmMask := MaskBitmap.Handle;
//      IconInfo.hbmMask := 0;
      Result := CreateIconIndirect(IconInfo);
    finally
      MaskBitmap.Free;
     end;
  finally
    DeleteObject(AlphaBitmap);
   end;
  end;


procedure TRnQBitmap.GetHICON(var hi : HICON);
//var
// ico : Ticon;
//  tbmp : TBitmap;
begin
  if fHI > 0 then
    hi := CopyIcon(fHI)
   else
    if Assigned(fBmp) then
     begin
//      ico := TIcon.Create;
//      ico.Assign(fBmp);
//      ico := bmp2ico3(fBmp);
//      hi := CopyIcon(ico.Handle);
//      if f32Alpha and (GetComCtlVersion >= ComCtlVersionIE6) then
      if f32Alpha and ((Win32MajorVersion > 5)or((Win32MajorVersion = 5)and(Win32MinorVersion >= 1)))
// if 1=1

        {(GetComCtlVersion >= ComCtlVersionIE6)} then
  //Windows XP or later, using the modern method: convert every PNG to
  //an icon resource with alpha channel
        begin
{          tbmp := TBitmap.Create;
          tbmp.Assign(fBmp);
          Demultiply(tbmp);
          hi := bmp2ico32(tbmp);
//          hi := bmp2ico4M(tbmp);
          tbmp.Free;}
//          hi := bmp2ico32(fbmp);
          hi := self.bmp2ico32;
//          hi := bmp2ico4M(fBmp);
        end
       else
        hi := bmp2ico4M(fBmp);
{        begin
          ico := bmp2ico(fBmp);
          hi := ico.handle;
          ico.free;
        end;}
//        hi :=self.bmp2ico32;
//      ico.Free;
     end;
end;

(*
//procedure wbmp2bmp(s: String; pic : TBitmap);
//procedure wbmp2bmp(Stream: TStream; var pic : TBitmap);
function wbmp2bmp(Stream: TStream; var pic: TBitmap; CalcOnly: Boolean = false): TSize;
var
  Bts: Integer;
  w, h: Integer;
  l, i: Word;
//  , k, j: Word;
  b: Byte;
var
  Pal: TMaxLogPalette;
begin
//  if not FileExists('pic00.wbmp') then
//    appendFile('pic00.wbmp', s);
//  Bts := 4;
  l := 5;
  stream.position := 2;
  Stream.Read(B, SizeOf(Byte));
  w := 0;
  h := 0;

 try
  if b = 128 then
   begin
     Stream.Read(w, SizeOf(Byte));
//     ACols := Ord(s[4]);
     inc(l, 2);
     Stream.Read(b, SizeOf(Byte));
//     ARows := Ord(s[4+2]);
     Stream.Read(h, SizeOf(Byte));
   end
  else
   begin
     w := b;
//     ARows := Ord(s[4]);
     Stream.Read(h, SizeOf(Byte));
   end;
  Bts := w div 8;
  if w mod 8 > 0 then inc(Bts);

  Result.cx := w;
  Result.cy := h;

  if (w = 0) or (h = 0) then
   begin
     FreeAndNil(pic);
     exit;
   end;
  if CalcOnly then
    FreeAndNil(pic)
   else
    begin
      if not Assigned(pic) then
        pic := createBitmap(w, h)
       else
        begin
         pic.Width  := w;
         pic.Height := h;
        end;

    //  pic.Monochrome := True;
      pic.Transparent := false;

            FillChar(Pal, SizeOf(Pal), 0);
            Pal.palVersion := $300;
            Pal.palNumEntries := 2;
            Pal.palPalEntry[1].peRed := $FF;
            Pal.palPalEntry[1].peGreen := $FF;
            Pal.palPalEntry[1].peBlue := $FF;
            pic.Palette := CreatePalette(PLogPalette(@Pal)^);
            pic.PixelFormat := pf1bit;
            for i := 0 to H - 1 do
              Stream.Read(pic.ScanLine[i]^, Bts);

    {  for i := 0 to ARows-1 do
       begin
        For k := 0 to Bts-1 do
         for j := 0 to 7 do
          begin
           if (7 - j + 8 * k) < Acols then
           if (Ord(s[l+k]) and (1 shl j)) = 0 then
            pic.Canvas.Pixels[7 - j + 8 * k, i] := clBlack
           else
            pic.Canvas.Pixels[7 - j + 8 * k, i] := clWhite;
          end;
        inc(l, Bts)
       end;}
    end;
 except
  if Assigned(pic) then
   begin
    pic.Height := 1;
    pic.Width := 1;
    pic.Canvas.Pixels[1, 1] := clBlack
   end;
 end;
end;
*)

function wbmp2bmp(Stream: TStream; var pic: TBitmap; CalcOnly: Boolean = false): TSize;
const
  WBMP_TYPE_BW_NOCOMPRESSION = 0;
  WBMP_DATA_MASK = $7F;
  WBMP_DATA_SHIFT = 7;
  WBMP_CONTINUE_MASK = $80;
  WBMP_FIXEDHEADERFIELD_EXT_MASK = $60;
  WBMP_FIXEDHEADERFIELD_EXT_00 = $00;
  WBMP_FIXEDHEADERFIELD_EXT_01 = $20;
  WBMP_FIXEDHEADERFIELD_EXT_10 = $40;
  WBMP_FIXEDHEADERFIELD_EXT_11 = $60;
  WBMP_FIXEDHEADERFIELD_EXT_11_IDENT_MASK = $70;
  WBMP_FIXEDHEADERFIELD_EXT_11_IDENT_SHIFT = 4;
  WBMP_FIXEDHEADERFIELD_EXT_11_VALUE_MASK = $0F;
  WBMP_FIXEDHEADERFIELD_EXT_11_VALUE_SHIFT = 0;
var
    FTypeField: Byte;
    FFixHeaderField: Byte;
//    width, height: Integer;
  B: Byte;
  BytesPerRow: Integer;
  i: Integer;
  SId: string[8];
  SVal: string[16];

  function ReadNum: Integer;
  var
    B: Integer;
  begin
    Result := 0;
    b := 0;
    repeat
//      B := 0;
      Stream.Read(B, SizeOf(Byte));
      Result := (Result shl WBMP_DATA_SHIFT) or (B and WBMP_DATA_MASK);
    until (B and WBMP_CONTINUE_MASK) = 0;
  end;

var
  Pal: TMaxLogPalette;
begin
  Result.cx := 0;
  Result.cy := 0;
  if not Assigned(stream) then
    Exit;
  stream.position := 0;
  Stream.Read(B, SizeOf(Byte));
  fTypeField := B;
  case fTypeField of
    WBMP_TYPE_BW_NOCOMPRESSION:
      begin
//        FixImage;
        Stream.Read(B, SizeOf(Byte));
        fFixHeaderField := B;
//        ExtHeaders.Clear;
        if (fFixHeaderField and WBMP_CONTINUE_MASK) <> 0 then
          case fFixHeaderField and WBMP_FIXEDHEADERFIELD_EXT_MASK of
            WBMP_FIXEDHEADERFIELD_EXT_00: // Not Implemented
              begin
//                raise Exception.Create(sNotImplemented);
              end;
            WBMP_FIXEDHEADERFIELD_EXT_01, WBMP_FIXEDHEADERFIELD_EXT_10: // Reserved
              begin
//                raise Exception.Create(sReservedExtHeaderType);
              end;
            WBMP_FIXEDHEADERFIELD_EXT_11:
              begin
                repeat
                  Stream.Read(B, SizeOf(Byte));
                  SetLength(SId, (B and WBMP_FIXEDHEADERFIELD_EXT_11_IDENT_MASK) shr WBMP_FIXEDHEADERFIELD_EXT_11_IDENT_SHIFT);
                  SetLength(SVal, (B and WBMP_FIXEDHEADERFIELD_EXT_11_VALUE_MASK) shr WBMP_FIXEDHEADERFIELD_EXT_11_VALUE_SHIFT);
                  Stream.Read(SId[1], Length(SId));
                  Stream.Read(SVal[1], Length(SVal));
//                  ExtHeaders.Values[SId] := SVal;
                until (B and WBMP_CONTINUE_MASK) = 0;
              end;
          end;
        Result.cx := ReadNum;
        Result.cy := ReadNum;
        if (Result.cy > 5000)or(Result.cy > 5000)or(Result.cy < 0)  then
          begin
            Result.cx := 0;
            Result.cy := 0;
            FreeAndNil(pic);
            exit;
          end;
        if CalcOnly then
          FreeAndNil(pic)
         else
          begin
            if not Assigned(pic) then
              begin
                pic := Tbitmap.create;
              end
             else
              begin
               pic.Height := 0;
              end;
            pic.PixelFormat := pf1bit;
           {$IFDEF DELPHI9_UP}
            pic.SetSize(Result.cx, Result.cy);
           {$ELSE DELPHI_9_dn}
            pic.Width := Result.cx;
            pic.Height := Result.cy;
           {$ENDIF DELPHI9_UP}
            FillChar(Pal, SizeOf(Pal), 0);
            Pal.palVersion := $300;
            Pal.palNumEntries := 2;
            Pal.palPalEntry[1].peRed := $FF;
            Pal.palPalEntry[1].peGreen := $FF;
            Pal.palPalEntry[1].peBlue := $FF;
            pic.Palette := CreatePalette(PLogPalette(@Pal)^);
            BytesPerRow := Result.cx div 8;
            if Result.cx mod 8 > 0 then
              inc(BytesPerRow);
            for i := 0 to Result.cy - 1 do
              Stream.Read(pic.ScanLine[i]^, BytesPerRow);
    //        Changed(Self);
          end;
      end;
//  else
//    raise Exception.Create(sUnsuportedWBMPType);
  end;
end;

(*
function bmp2wbmp(bmp: TBitmap): String;
var
  Bts: Byte;
  ACols, ARows: word;
  i, j, k, l: word;
//  clr: TColor;
//Chs: Array[0..15] of Char;
begin
  ACols := bmp.Width;
  ARows := bmp.Height;
  Bts := ACols div 8;
  if ACols mod 8 > 0 then inc(Bts);

//  for i := 1 to Bmp.Height do
//    for j := 1 to Bmp.Width do
//      if Bmp.Canvas.Pixels[j, i] = clBlack then
//        SEPic[i, j] := true;
  result := #0#0 + Chr(ACols) + Chr(ARows);
  SetLength(result, ARows*bts+4);
  l := 5;
  if (ACols=0) or (ARows=0) then exit; 
  for i := 0 to ARows-1 do
   begin
    For k := 0 to Bts-1 do
    begin
     result[l+k] := #255;
     for j := 0 to 7 do
      begin
      if (Rgb2Gray(Bmp.Canvas.Pixels[7 - j + 8 * k, i]) < 128) or
//        if SEPic[i, 7 - j + 8 * k] or
           ((7 - j + 8 * k) > Acols) then
         result[l+k] := Chr(ord(result[l+k]) AND not (1 shl j));
//         if (7 - j + 8 * k) < Acols then
      end;
    end;
    inc(l, bts);
   end;
end;
*)

function createBitmap(dx, dy: integer; PPI: Integer = cDefaultDPI): Tbitmap;
begin
  result := Tbitmap.create;
  Result.PixelFormat := pf24bit;
  Result.Canvas.Font.PixelsPerInch := PPI;
 {$IFDEF DELPHI9_UP}
  Result.SetSize(dx, dy);
 {$ELSE DELPHI9_UP}
  result.width := dx;
  result.height := dy;
 {$ENDIF DELPHI9_UP}
end;

function createBitmap(cnv: Tcanvas): Tbitmap;
begin
  with cnv.cliprect do
    result := createBitmap(right-left+1, bottom-top+1);
  Result.Canvas.Font.PixelsPerInch := cnv.Font.PixelsPerInch;
end;

procedure checkWICCodecs;
var
  FImagingFactory: IWICImagingFactory;
  ctInfo: IWICComponentInfo;
begin
  isTIFFSupport := false;
  isWEBPSupport := false;

  if Succeeded( CoCreateInstance(CLSID_WICImagingFactory, nil, CLSCTX_INPROC_SERVER or
      CLSCTX_LOCAL_SERVER, IUnknown, FImagingFactory)) then
  begin
    isTIFFSupport := true;
    if Succeeded( FImagingFactory.CreateComponentInfo(CLSID_WICWEBPDecoder, ctInfo) ) then
      begin
       ctInfo := NIL;
       isWEBPSupport := true;
      end;
  end;


end;

function  getSupPicExts: String;
var
  I: Integer;
  s: String;
//var
//  l: TStrings;
begin
//  FileFormatList.GetExtensionList(l);
  s := '';
  for I := low(supExts) to High(supExts) do
    s := S + '*.' + supExts[i] + '; ';
  if isTIFFSupport then
    s := S + '*.tif; *.tiff; ';
  if isWEBPSupport then
    s := S + '*.webp; ';

  result := 'All images' + '|' + s; // + '|';
//  result := FileFormatList.GetGraphicFilter([], fstDescription,
//            [foCompact, foIncludeAll, foIncludeExtension], nil);
// !!!!!!!!!!!!!!!!!         ADDD       WBMP, GIF         !!!!!!!!!!!!!
end;
function isSupportedPicFile(fn: string): boolean;
//var
//  Extensions: TStringList;
//  i: Integer;
begin
//  result := true;
  result := false;
  fn := lowercase(SysUtils.ExtractFileExt(fn));
//  if fn <> '' then
  if Length(fn) > 3 then // dot + extension
  begin
    fn := Copy(fn, 2, Length(fn)-1);
    if (fn = 'bmp')or(fn = 'wbmp')or(fn = 'wbm')or(fn = 'gif')or
        (fn = 'ico')or(fn = 'icon')or(fn='png')or(fn='jpg')or(fn='jpeg')or
        (fn='dll')or
        (isWEBPSupport and (fn='webp'))or
        (isTIFFSupport and ((fn='tiff')or (fn='tiff')))
    then
     begin
      result := true;
      exit;
     end
{   try
    Extensions := TStringList.Create;
    FileFormatList.GetExtensionList(Extensions);
    i := Extensions.IndexOf(fn);
    if i>=0 then
     result:=true
    else
     result:=false
   finally
    Extensions.Free;
   end;
  end}
  else
     result := false;
  end;
end; // isSupportedPicFile


function DetectFileFormatStream(str: TStream): TPAFormat;
var
//  s: String;
  s: array[0..3] of AnsiChar;
begin
  str.Seek(0, soBeginning);
//  str.Position := 0;
  Result := PA_FORMAT_UNK;
  if str.Read(s, 4) < 4 then
    Result := PA_FORMAT_UNK
  else
//  s := Copy(pBuffer, 1, 4);
  if s = 'GIF8' then
    Result := PA_FORMAT_GIF
  else if MatchStr(s, JPEG_HDRS) then
    Result := PA_FORMAT_JPEG
  else if AnsiStartsText(AnsiString('BM'), s) then
    Result := PA_FORMAT_BMP
  else if s = '<?xm' then
    Result := PA_FORMAT_XML
  else if AnsiStartsText(AnsiString('CWS'), s) then
    Result := PA_FORMAT_SWF
  else if AnsiStartsText(AnsiString('FWS'), s) then
    Result := PA_FORMAT_SWF
  else if AnsiStartsText(AnsiString('ЙPNG'), s) then
    Result := PA_FORMAT_PNG
  else if (s = TIF_HDR) or (s = TIF_HDR2) then
    Result := PA_FORMAT_TIF
  else if (s= 'RIFF') then
    begin
      if str.Read(s, 4) < 4 then
        Result := PA_FORMAT_UNK
       else
        if str.Read(s, 4) < 4 then
          Result := PA_FORMAT_UNK
         else if s = 'WEBP' then
          Result := PA_FORMAT_WEBP;
    end
//  else
//    Result := PA_FORMAT_UNK;
end;

procedure  StretchPic(var bmp: TBitmap; maxH, maxW: Integer);
var
  bmp1: TBitmap;
begin
  if (bmp.Width > maxW )
   or (bmp.Height > maxH) then
  begin
   bmp1 := TBitmap.Create;
   if bmp.Width * maxH < bmp.Height * maxW then
     begin
      {$IFDEF DELPHI9_UP}
       bmp1.SetSize(maxH*bmp.Width div bmp.Height, maxH);
      {$ELSE DELPHI_9_down}
       bmp1.Width := maxH*bmp.Width div bmp.Height;
       bmp1.Height := maxH;
      {$ENDIF DELPHI9_UP}
     end
    else
     begin
      {$IFDEF DELPHI9_UP}
     bmp1.SetSize(maxW, maxW*bmp.Height div bmp.Width);
      {$ELSE DELPHI_9_down}
       bmp1.Width := maxW;
       bmp1.Height := maxW*bmp.Height div bmp.Width;
      {$ENDIF DELPHI9_UP}
     end;
   bmp1.Canvas.StretchDraw(Rect(0, 0, bmp1.Width, bmp1.Height), bmp);
   FreeAndNil(bmp);
   bmp := bmp1;
//   bmp1 := nil;
 end;
end;

procedure  StretchPic(var bmp: TRnQBitmap; maxH, maxW: Integer);
//var
//  bmp1: TBitmap;
//  newBmp: TRnQBitmap;
//  w, h: Integer;
//  gr: TGPGraphics;
begin
  if not Assigned(bmp) or
     (bmp.fAnimated and (bmp.FNumFrames > 1)) then
   Exit;
{  w := bmp.GetWidth;
  h := bmp.GetHeight;
  if (w > maxW )
   or (h > maxH) then
 begin}
//  bmp1 := TBitmap.Create;
  if Assigned(bmp.fBmp) then
    begin
     StretchPic(bmp.fBmp, maxH, maxW);
     bmp.fWidth := bmp.fBmp.Width;
     bmp.fHeight := bmp.fBmp.Height;
    end;

{   if w * maxH < h * maxW then
     newBmp := TRnQBitmap.Create(maxH*w div h, maxH)
    else
     newBmp := TRnQBitmap.Create(maxW, maxW*h div w);
{   gr := TGPGraphics.Create(newBmp);
   gr.SetInterpolationMode(InterpolationModeHighQualityBicubic);
   gr.SetSmoothingMode(SmoothingModeHighQuality);
   gr.DrawImage(bmp, 0,0, newBmp.GetWidth, newBmp.GetHeight);
   gr.Free;
   FreeAndNil(bmp);
//   bmp := newBmp;
//   newBmp := nil;
 end; }
end;


procedure DrawRbmp(DC : HDC; VAR bmp : TRnQBitmap; DestR, SrcR : TGPRect); OverLoad;
var
  Pt: TPoint;
begin
  if (DestR.Width <> SrcR.Width)
     or (DestR.Height <> SrcR.Height) then
   begin
    GetBrushOrgEx(dc, pt);
    SetStretchBltMode(dc, HALFTONE);
    SetBrushOrgEx(dc, pt.x, pt.y, @pt);
   end;
//   SetStretchBltMode(DC, HALFTONE);
  bmp.Draw(DC, DestR, SrcR);
end;
procedure DrawRbmp(DC: HDC; VAR bmp: TRnQBitmap; DestR: TGPRect; Bound: Boolean = True); OverLoad;
var
  Pt: TPoint;
  r2: TGPRect;
begin
  if ((DestR.Width) <> (bmp.fWidth))
     and ((DestR.Height) <> (bmp.fHeight)) then
   begin
    if not Bound then
      begin
       GetBrushOrgEx(dc, pt);
       SetStretchBltMode(dc, HALFTONE);
       SetBrushOrgEx(dc, pt.x, pt.y, @pt);
       bmp.Draw(DC, DestR);
      end
     else
      begin
       r2 := DestRect(bmp.fWidth, bmp.fHeight, DestR.Width, DestR.Height);
       inc(r2.X, DestR.X);
       inc(r2.Y, DestR.Y);
       bmp.Draw(DC, r2);
      end;
   end
  else
    bmp.Draw(DC, DestR);
end;
procedure DrawRbmp(DC: HDC; VAR bmp: TRnQBitmap); OverLoad;
begin
  bmp.Draw(DC, 0, 0);
end;
procedure DrawRbmp(DC: HDC; VAR bmp: TRnQBitmap; X, Y: Integer); OverLoad;
begin
  bmp.Draw(DC, x, y);
end;
{procedure DrawRbmp(DC: HDC; VAR bmp: TRnQBitmap; DestRect : TRect; SrcX, SrcY, SrcW, SrcH: Integer; pEnabled: Boolean= True);
var
  Pt: TPoint;
begin
  if ((DestRect.Right - DestRect.Left) <> (SrcW))
     and ((DestRect.Bottom - DestRect.Top) <> (SrcH)) then
   begin
    GetBrushOrgEx(dc, pt);
    SetStretchBltMode(dc, HALFTONE);
    SetBrushOrgEx(dc, pt.x, pt.y, @pt);
   end;
  bmp.Draw(DC, DestRect, SrcX, SrcY, SrcW, SrcH, pEnabled);
end;}

procedure DrawRbmp(DC: HDC; VAR bmp: TRnQBitmap; DestR, SrcR: TGPRect; pEnabled: Boolean = True; isCopy: Boolean = false);
var
  Pt: TPoint;
begin
  if ((DestR.Width) <> (SrcR.Width))
     and ((DestR.Height) <> (SrcR.Height)) then
   begin
    GetBrushOrgEx(dc, pt);
    SetStretchBltMode(dc, HALFTONE);
    SetBrushOrgEx(dc, pt.x, pt.y, @pt);
   end;
  bmp.Draw(DC, DestR, SrcR, pEnabled, isCopy);
end;


function FillGradientInternal(DC: HDC; ARect: TRect; ColorCount: Integer;
  StartColor, EndColor: Cardinal; ADirection: TGradientDirection): Boolean;
  function GetAValue(rgb: DWORD): Byte;
  begin
    Result := Byte(rgb shr 24);
  end;
  function RGBA(r, g, b, a: Byte): COLORREF; {$IFDEF HAS_INLINE}inline;{$ENDIF HAS_INLINE}
  begin
    Result := (r or (g shl 8) or (b shl 16) or (a shl 24));
  end;

var
  StartRGB: array [0..3] of Byte;
  RGBKoef: array [0..3] of Double;
  Brush: HBRUSH;
  AreaWidth, AreaHeight, I: Integer;
  ColorRect: TRect;
  RectOffset: Double;
begin
  RectOffset := 0;
  Result := False;
  if ColorCount < 1 then
    Exit;
//  StartColor := StartColor;
//  EndColor := EndColor;
  StartRGB[0] := GetRValue(StartColor);
  StartRGB[1] := GetGValue(StartColor);
  StartRGB[2] := GetBValue(StartColor);
  StartRGB[3] := GetAValue(StartColor);
  RGBKoef[0] := (GetRValue(EndColor) - StartRGB[0]) / ColorCount;
  RGBKoef[1] := (GetGValue(EndColor) - StartRGB[1]) / ColorCount;
  RGBKoef[2] := (GetBValue(EndColor) - StartRGB[2]) / ColorCount;
  RGBKoef[3] := (GetAValue(EndColor) - StartRGB[3]) / ColorCount;
  AreaWidth := ARect.Right - ARect.Left;
  AreaHeight :=  ARect.Bottom - ARect.Top;
  case ADirection of
    gdHorizontal:
      RectOffset := AreaWidth / ColorCount;
    gdVertical:
      RectOffset := AreaHeight / ColorCount;
  end;
  for I := 0 to ColorCount - 1 do
  begin
//    Brush := CreateHatchBrush(HS_BDIAGONAL,
    Brush := CreateSolidBrush(
      RGBA(
      StartRGB[0] + Round((I + 1) * RGBKoef[0]),
      StartRGB[1] + Round((I + 1) * RGBKoef[1]),
      StartRGB[2] + Round((I + 1) * RGBKoef[2]),
      StartRGB[3] + Round((I + 1) * RGBKoef[3])));
    case ADirection of
      gdHorizontal:
        SetRect(ColorRect, Round(RectOffset * I), 0, Round(RectOffset * (I + 1)), AreaHeight);
      gdVertical:
        SetRect(ColorRect, 0, Round(RectOffset * I), AreaWidth, Round(RectOffset * (I + 1)));
    end;
    OffsetRect(ColorRect, ARect.Left, ARect.Top);
    FillRect(DC, ColorRect, Brush);
    DeleteObject(Brush);
  end;
  Result := True;
end;

  {$IFNDEF DELPHI9_UP}
function WinGradientFill; external msimg32 name 'GradientFill';
type
  COLOR16_RD = Smallint;

  PTriVertex_RD = ^TTriVertex;
  { $EXTERNALSYM _TRIVERTEX_RD}
  _TRIVERTEX_RD = packed record
    x: Longint;
    y: Longint;
    Red: COLOR16_RD;
    Green: COLOR16_RD;
    Blue: COLOR16_RD;
    Alpha: COLOR16_RD;
  end;
  TTriVertex_RD = _TRIVERTEX_RD;
  { $EXTERNALSYM TRIVERTEX_RD}
  TRIVERTEX_RD = _TRIVERTEX_RD;
  {$ENDIF DELPHI9_UP}

procedure FillGradient(DC: HDC; ARect: TRect;// ColorCount: Integer;
  StartColor, EndColor: Cardinal; ADirection: TGradientDirection; Alpha : Byte = $FF);
var
  {$IFDEF DELPHI9_UP}
   udtVertex: array [0..1] of TTriVertex;
  {$ELSE DELPHI_9_dn}
   udtVertex: array [0..1] of TTriVertex_RD;
  {$ENDIF DELPHI9_UP}
   rectGradient: TGradientRect;
   mode : Cardinal;

  tempDC  : HDC;
  ABitmap, HOldBmp : HBITMAP;
//  BIH: TBitmapInfoHeader;
  BI : TBitmapInfo;
  blend: BLENDFUNCTION;
//  oldBr, brF : HBRUSH;
begin
//  StartColor := ColorToRGB(StartColor);
//  EndColor := ColorToRGB(EndColor);
   if ((StartColor and AlphaMask)= (EndColor and AlphaMask)) and
      ((StartColor and AlphaMask) <> AlphaMask) then
    begin
     Alpha := Alpha * Byte(EndColor shr 24) div $FF;
     StartColor := StartColor or AlphaMask;
     EndColor := EndColor or AlphaMask;
    end;
     with udtVertex[0] do
     begin
          x := ARect.Left;
          y := ARect.Top;
{
          Red := GetRValue(StartColor) shl 8;
          Blue := GetBValue(StartColor) shl 8;
          Green := GetGValue(StartColor) shl 8;
          Alpha := Byte(StartColor shr 24) shl 8;
}
          Red := Byte(StartColor) shl 8;
          Blue := Byte(StartColor shr 16) shl 8;
          Green := Byte(StartColor shr 8) shl 8;
          Alpha := Byte(StartColor shr 24) shl 8;
     end;

     with udtVertex[1] do
     begin
          x := ARect.Right;
          y := ARect.Bottom;
//          Red := GetRValue(EndColor) shl 8;
//          Blue := GetBValue(EndColor) shl 8;
//          Green := GetGValue(EndColor) shl 8;
//          Alpha := Byte(EndColor shr 24) shl 8;
          Red := Byte(EndColor) shl 8;
          Blue := Byte(EndColor shr 16) shl 8;
          Green := Byte(EndColor shr 8) shl 8;
          Alpha := Byte(EndColor shr 24) shl 8;
     end;

     rectGradient.UpperLeft := 0;
     rectGradient.LowerRight := 1;
     if ADirection = gdVertical then
       Mode := GRADIENT_FILL_RECT_V
      else
       Mode := GRADIENT_FILL_RECT_H;
   tempDC := DC;
   ABitmap := 0;
   if //(Win32MajorVersion >=6) and
//     if
     (((StartColor and AlphaMask) <> AlphaMask) or
        ((EndColor and AlphaMask) <> AlphaMask)) or (Alpha < $FF) then
     begin
       HOldBmp := 0;
       try
        try
          with udtVertex[1] do
            begin
             dec(x, udtVertex[0].x);
             dec(y, udtVertex[0].y);
            end;
          with udtVertex[0] do
            begin
             x := 0;
             y := 0;
            end;
          tempDC := CreateCompatibleDC(DC);

//          HOldBmp := 0;
          with ARect do
          if ((udtVertex[1].x) >0) and ((udtVertex[1].y) > 0) then
          begin
            BI.bmiHeader.biSize := SizeOf(TBitmapInfoHeader);
            BI.bmiHeader.biWidth  := udtVertex[1].x;
            BI.bmiHeader.biHeight := udtVertex[1].y;
            BI.bmiHeader.biPlanes := 1;
            BI.bmiHeader.biBitCount := 32;
            BI.bmiHeader.biCompression := BI_RGB;
            ABitmap := CreateDIBitmap(DC, BI.bmiHeader, 0, NIL, BI, DIB_RGB_COLORS);
//            CreateDIBSection(DC, BI, DIB_RGB_COLORS, )
//            ABitmap := CreateCompatibleBitmap(DC, udtVertex[1].x, udtVertex[1].y);
            if (ABitmap = 0) and (udtVertex[1].x > 0)and(udtVertex[1].y > 0) then
             begin
              DeleteDC(tempDC);
              tempDC := 0;
              raise EOutOfResources.Create('Out of Resources');
             end;
            HOldBmp := SelectObject(tempDC, ABitmap);
//            SetWindowOrgEx(tempDC, Left, Top, Nil);
          end
          else
           ABitmap := 0;
        finally

        end;

//        FillGradientInternal(tempDC,
//           Rect(udtVertex[0].x, udtVertex[0].Y,udtVertex[1].x, udtVertex[1].Y),
//           128, StartColor, EndColor, ADirection);
    {$IFDEF DELPHI9_UP}
        if GradientFill(tempDC,
    {$ELSE DELPHI9_UP}
        if WinGradientFill(tempDC,
    {$ENDIF DELPHI9_UP}
                  @udtVertex, 2,
                  @rectGradient, 1,
                  Mode) then
         begin
            blend.AlphaFormat         := AC_SRC_ALPHA
    //       else
    //        blend.AlphaFormat         := AC_SRC_OVER
            ;
           blend.BlendOp             := AC_SRC_OVER;
           blend.BlendFlags          := 0;
           blend.SourceConstantAlpha := Alpha;

{      brF := CreateSolidBrush(ColorToRGB(theme.GetColor('menu.selected', clMenuHighlight)));
      FillRect(tempDC, Rect(0, 0, udtVertex[1].x, udtVertex[1].y), brF);
      DeleteObject(brF);
}
//          GdiFlush;
//          if not
          {$IFDEF FPC}
            //JwaWinGDI.
          {$ELSE ~FPC}
            Windows.
          {$ENDIF ~FPC}
              AlphaBlend(DC, ARect.Left, ARect.Top, ARect.Right-ARect.Left, ARect.Bottom - ARect.Top,
                              tempDC, 0, 0, udtVertex[1].x, udtVertex[1].y, blend)
{           then
            loggaEvt('Coudn''t draw AlphaBlend :(', 'draw');
}
          end
//          else
//           loggaEvt('Coudn''t draw gradient :(', 'draw');
         ;
//        else
//        BitBlt(DC, ARect.Left, ARect.Top, udtVertex[1].x, udtVertex[1].y, tempDC, 0, 0, SRCCOPY)
       finally
        SelectObject(tempDC, HOldBmp);
        DeleteObject(ABitmap);
        if tempDC <> DC then
           DeleteDC(tempDC);
       end;
     end
    else
    {$IFDEF DELPHI9_UP}
      GradientFill(DC,
    {$ELSE DELPHI9_UP}
      WinGradientFill(DC,
    {$ENDIF DELPHI9_UP}
                   @udtVertex, 2,
                   @rectGradient, 1,
                   Mode);

//  GdiFlush;
end;

procedure FillRoundRectangle(DC: HDC; ARect: TRect; Clr: Cardinal; rnd: Word);
var
  oldBr, brF: HBRUSH;
  oldPen, Hp: HPEN;
begin
  if ((Clr and AlphaMask) <> AlphaMask) then
   begin
   end
  else
   begin
     brF := CreateSolidBrush(Clr);
     Hp  := CreatePen(PS_SOLID, 1, addLuminosity(Clr, -0.2));
     oldPen := SelectObject(DC, Hp);
     oldBr  := SelectObject(DC, brF);
     RoundRect(DC, ARect.Left, ARect.Top, ARect.Right, ARect.Bottom, 3, 3);
     SelectObject(DC, oldPen);
     DeleteObject(Hp);
     SelectObject(DC, oldBr);
  //   FrameRect(DC, rB, brF);
     DeleteObject(brF);
   end;
end;


procedure DrawTextTransparent(DC: HDC; x, y: Integer; Text: String; Font: TFont; Alpha: Byte; fmt: integer);
var
  tempDC: HDC;
//  ABitmap, HOldBmp: HBITMAP;
//  BIH: TBitmapInfoHeader;
//  BI: TBitmapInfo;
  tempBitmap: TBitmap;
  blend: BLENDFUNCTION;
  oldFont: HFONT;
  R: TRect;
  res: TSize;
  i, k, h, w: Integer;
 Scan32: pColor32Array;
//  oldBr, brF: HBRUSH;
begin
//            SetBKMode(cnv.Handle, oldMode);
  R.Left := 0;
  R.Top  := 0;
  R.Right  := MAXWORD;
  R.Bottom := MAXWORD;
   oldFont := SelectObject(DC, Font.Handle);
   DrawText(DC, PChar(Text), -1, R, DT_CALCRECT or fmt);
   GetTextExtentPoint32(DC,pchar(Text),length(Text), res);
   SelectObject(DC, oldFont);
  R.Right := res.cx;
  R.Bottom := res.cy;
//     tempBitmap := createBitmap(res.cx, res.cy);
     tempBitmap := Tbitmap.create;
     tempBitmap.PixelFormat := pf32bit;
 {$IFDEF DELPHI9_UP}
     tempBitmap.SetSize(res.cx, res.cy);
 {$ELSE DELPHI_9_dn}
     tempBitmap.Width := res.cx;
     tempBitmap.Height := res.cy;
 {$ENDIF DELPHI9_UP}
     tempDC := tempBitmap.Canvas.Handle;
{        tempDC := CreateCompatibleDC(DC);
        HOldBmp := 0;
        try
          with R do
          begin
            BI.bmiHeader.biSize := SizeOf(TBitmapInfoHeader);
            BI.bmiHeader.biWidth  := res.cx;
            BI.bmiHeader.biHeight := res.cy;
            BI.bmiHeader.biPlanes := 1;
            BI.bmiHeader.biBitCount := 32;
            BI.bmiHeader.biCompression := BI_RGB;
            ABitmap := CreateDIBitmap(DC, BI.bmiHeader, 0, NIL, BI, DIB_RGB_COLORS);
//            CreateDIBSection()
//            ABitmap := CreateCompatibleBitmap(DC, udtVertex[1].x, udtVertex[1].y);
            if (ABitmap = 0) then
             begin
              DeleteDC(tempDC);
              tempDC := 0;
              raise EOutOfResources.Create('Out of Resources');
             end;
            HOldBmp := SelectObject(tempDC, ABitmap);
//            SetWindowOrgEx(tempDC, Left, Top, Nil);
          end
//          else
//           ABitmap := 0;
        finally

        end;}
          oldFont := SelectObject(tempDC, Font.Handle);
        //  oldColor :=
          SetTextColor(tempDC, ColorToRGB(Font.Color));
//          SetTextColor(tempDC, $FFFFFFFF);
        //  oldMode:=
          SetBKMode(tempDC, TRANSPARENT);
//         FillRect(tempDC, R, GetStockObject(BLACK_BRUSH));
         FillRect(tempDC, R, GetStockObject(WHITE_BRUSH));
//         FillRect(tempDC, R, GetStockObject(LTGRAY_BRUSH));
         DrawText(tempDC, PChar(Text), Length(Text), R, fmt);
         SelectObject(tempDC, oldFont);
          h := res.cY-1;  // —разу вычетаем 1 !!!
          w := res.cx-1;  // —разу вычетаем 1 !!!

//          Trans.c := ColorToRGB(bmp.TransparentColor) and not AlphaMask;
          for I := 0 to h do
           begin
        //    if biHeight > 0 then  // bottom-up DIB
        //      Row := biHeight - Row - 1;
//            Integer(Scan32) := Integer(BI.bmiHeader.bmBits) +
//              i * BytesPerScanline(res.cx, 32, 32);

            Scan32 := tempBitmap.ScanLine[i];
            for k := 0 to w do
             begin
              with Scan32^[k] do
               begin
                 if (Color and $FFFFFF) <> $FFFFFF then
                   A:= $FF
                  else
                   A := 0;
               end;
             end;
           end;
        try
         begin
            blend.AlphaFormat         := AC_SRC_ALPHA
//           else
//            blend.AlphaFormat         := AC_SRC_OVER
            ;
           blend.BlendOp             := AC_SRC_OVER;
           blend.BlendFlags          := 0;
           blend.SourceConstantAlpha := Alpha;

{      brF := CreateSolidBrush(ColorToRGB(theme.GetColor('menu.selected', clMenuHighlight)));
      FillRect(tempDC, Rect(0, 0, udtVertex[1].x, udtVertex[1].y), brF);
      DeleteObject(brF);
}
//          GdiFlush;
//          if not
        {$IFDEF FPC}
          //JwaWinGDI.
        {$ELSE ~FPC}
          Windows.
        {$ENDIF ~FPC}
           AlphaBlend(DC, x, y, res.cx, res.cy,
                              tempDC, 0, 0, res.cx, res.cy, blend)
{           then
            loggaEvt('Coudn''t draw AlphaBlend :(', 'draw');
}
          end
//          else
//           loggaEvt('Coudn''t draw gradient :(', 'draw');
         ;
//        else
//        BitBlt(DC, x,y, res.cx, res.cy,  tempDC, 0, 0, SRCCOPY)
       finally
//        SelectObject(tempDC, HOldBmp);
//        DeleteObject(ABitmap);
//        DeleteDC(tempDC);
         FreeAndNil(tempBitmap);
       end
end;

 {$IFDEF DELPHI9_UP}
//procedure DrawTextTransparent2(DC: HDC; x, y: Integer; Text: String; Font: TFont; Alpha: Byte; fmt: Integer);
procedure DrawText32(DC: HDC; TextRect: TRect; Text: String; Font: TFont; TextFlags: Cardinal);
var
   TextLen: Integer;
//   TextRect: TRect;
//   TextFlags: ;
   Options: TDTTOpts;
//   pmtParams: TBPPaintParams;
//   blend: BLENDFUNCTION;
//   PaintOnGlass: Boolean;
  MemDC: HDC;
  PaintBuffer: HPAINTBUFFER;
//  br: HBRUSH;
  oldF: HFONT;
//  s: String;
begin
      TextLen := Length(Text);
//      TextFlags := DT_CENTER or DT_VCENTER;
//      TextRect := r;
//      TextRect.Left := r.Right - x - 4;
//      TextRect.Top := y-1;
//      inc(TextRect.Bottom, 1);
      FillChar(Options, SizeOf(Options), 0);
      Options.dwSize := SizeOf(Options);
      Options.dwFlags := DTT_COMPOSITED or DTT_GLOWSIZE or DTT_TEXTCOLOR;
//      Options.dwFlags := DTT_GLOWSIZE or DTT_TEXTCOLOR;
//      Options.dwFlags := DTT_COMPOSITED or DTT_GLOWSIZE;
      Options.iGlowSize := 5;
      Options.crText := ColorToRGB(Font.Color);
//      FillRect(cnv.Handle, TextRect, GetStockObject(BLACK_BRUSH));
{
      pmtParams.cbSize := SizeOf(TBPPaintParams);
      pmtParams.dwFlags := //BPPF_NONCLIENT;
         0;
//         BPPF_ERASE;
//        blend.AlphaFormat        := AC_SRC_ALPHA;
//       else
        blend.AlphaFormat         := AC_SRC_OVER;
//       blend.BlendOp             := AC_SRC_OVER;
       blend.BlendFlags          := 0;
//       if not pEnabled then
//         blend.SourceConstantAlpha := 100
//        else
         blend.SourceConstantAlpha := $FF;
//      pmtParams.pBlendFunction := @blend;
      pmtParams.pBlendFunction := nil;
//      PaintBuffer := BeginBufferedPaint(DC, TextRect, BPBF_TOPDOWNDIB, @pmtParams, MemDC);
}
      PaintBuffer := BeginBufferedPaint(DC, TextRect, BPBF_TOPDOWNDIB, nil, MemDC);
      try
         BufferedPaintClear(PaintBuffer, @TextRect);
//          SetBKMode(MemDC, TRANSPARENT);
          oldF := SelectObject(MemDC, Font.Handle);
//         FillRect(MemDC, R, GetStockObject(BLACK_BRUSH));
//         FillRect(MemDC, R, GetStockObject(LTGRAY_BRUSH));
//         DrawText(MemDC, PChar(Text), Length(Text), R, fmt);
//          with ThemeServices.GetElementDetails(twCaptionActive) do
//            DrawThemeTextEx(ThemeServices.Theme[element], MemDC, Part, State,
//            DrawThemeTextEx(ThemeServices.Theme[teWindow], MemDC, 0, 0,
            DrawThemeTextEx(StyleServices.Theme[teWindow], MemDC, 0, 0,
                PWideChar(WideString(Text)), TextLen, TextFlags, @TextRect, Options);
          SelectObject(MemDC, oldF);
//          DeleteObject(oldF);
//        BufferedPaintMakeOpaque(PaintBuffer, @R);
      finally
        EndBufferedPaint(PaintBuffer, True);
      end;
end;
 {$ENDIF DELPHI9_UP}

function LoadAGifFromStream(var NonAnimated: boolean;
              Stream: TStream): TRnQBitmap;
var
  AGif: TGif;
  Frame: TAniFrame;
  I: integer;
  ABitmap, AMask: TBitmap;
begin
  Result := Nil;
  if not Assigned(Stream) then
    Exit;
try
  NonAnimated := True;
  AGif := TGif.Create;
  Try
    AGif.LoadFromStream(Stream);
    Result := TRnQBitmap.Create;
    Result.fFormat := PA_FORMAT_GIF;
    Result.FNumFrames := AGif.ImageCount;
    Result.FAnimated := Result.FNumFrames > 1;
    NonAnimated := not Result.FAnimated;
    Result.FWidth := AGif.Width;
    Result.FHeight := AGif.Height;
    Result.FNumIterations := AGif.LoopCount;
    if Result.FNumIterations < 0 then    {-1 means no loop block}     
      Result.FNumIterations := 1
    else if Result.FNumIterations > 0 then
      Inc(Result.FNumIterations);    {apparently this is the convention}
//    Result.FTransparent := AGif.Transparent;
    Result.htTransparent := AGif.Transparent;

    with Result do
     begin
//      Strip := ThtBitmap.Create;
       fBmp := TBitmap.Create;
      ABitmap := AGif.GetStripBitmap(AMask);
      try
//        Strip.Assign(ABitmap);
        fBmp.Assign(ABitmap);
//        Strip.htMask := AMask;
        htMask := AMask;
        htTransparent := Assigned(AMask);
       finally
        ABitmap.Free;
      end;
      if fBmp.Palette <> 0 then
      DeleteObject(fBmp.ReleasePalette);
      fBmp.Palette := CopyPalette(ThePalette);
     end;
    if Result.FAnimated then
    begin
     if not Assigned(Result.fFrames) then
       Result.fFrames := TAniFrameList.Create;
     for I := 0 to Result.FNumFrames-1 do
      begin
        Frame := TAniFrame.Create;
        try
          Frame.frDisposalMethod := TAniDisposalType(AGif.ImageDisposal[I]);
          Frame.frLeft := AGif.ImageLeft[I];
          Frame.frTop := AGif.ImageTop[I];
          Frame.frWidth := AGif.ImageWidth[I];
          Frame.frHeight := AGif.ImageHeight[I];
//          Frame.frDelay := IntMax(30, AGif.ImageDelay[I] * 10);
          Frame.frDelay := IntMax(100, AGif.ImageDelay[I] * GIFDelayExp);
         except
          Frame.Free;
          Raise;
        end;
        Result.fFrames.Add(Frame);
      end;
      Result.WasDisposal := dtToBackground;
    end;
  finally
    AGif.Free;
    end;
except
  FreeAndNil(Result);
  end;
end;


{----------------TRnQBitmap.NextFrame}
procedure TRnQBitmap.NextFrame(OldFrame: Integer);
begin
WasDisposal := fFrames[OldFrame].frDisposalMethod;
end;

{----------------TRnQBitmap.SetCurrentFrame}
procedure TRnQBitmap.SetCurrentFrame(AFrame: Integer);
begin
  if AFrame = FCurrentFrame then
    Exit;

  NextFrame(FCurrentFrame);
  if AFrame > FNumFrames then
    FCurrentFrame := 1
   else
    if AFrame < 1 then
      FCurrentFrame := FNumFrames
     else
      FCurrentFrame := AFrame;
  if FAnimated then
    WasDisposal := dtToBackground;
end;

{----------------TRnQBitmap.RnQCheckTime}
function TRnQBitmap.RnQCheckTime: Boolean;
var
  ThisTime: DWord;
begin
  Result := False;
  if not fAnimated then
    Exit;

//FCurrentFrame := 6; exit;

  ThisTime := timeGetTime;
  if ThisTime - LastTime < CurrentInterval then
    Exit;

  LastTime := ThisTime;

if (FCurrentFrame = FNumFrames) then
  begin
  if (FNumIterations > 0) and (CurrentIteration >= FNumIterations) then
    begin
//    SetAnimate(False);
    Exit;
    end;
  Inc(CurrentIteration);
  end;
NextFrame(FCurrentFrame);
Inc(FCurrentFrame);
  Result := True;
if (FCurrentFrame > FNumFrames) or (FCurrentFrame <= 0) then
  FCurrentFrame := 1;

//InvalidateRect(WinControl.Handle, @FStretchedRect, True);

CurrentInterval := IntMax(fFrames[FCurrentFrame].frDelay, 1);
end;


function CreateAni(fn: String; var b: Boolean): TRnQBitmap; {$IFDEF HAS_INLINE} inline; {$ENDIF HAS_INLINE}
var
  Stream: TFileStream;
begin
  {$IFDEF NOT_USE_GDIPLUS}
  Result := Nil;
//  result := CreateAGif(fn, b);
  try
    Stream := TFileStream.Create(fn, fmOpenRead or fmShareDenyWrite);
    try
      Result := LoadAGifFromStream(b, Stream);
    finally
      Stream.Free;
      end;
  except
  end;
  {$ELSE NOT_USE_GDIPLUS}
  result := TRnQAni.Create(fn);
//  NewGPImage(fn);
//   b := not result.CanAnimate;
  b := not result.FAnimated;
  {$ENDIF NOT_USE_GDIPLUS}
end;

function CreateAni(fs: TStream; var b: Boolean): TRnQBitmap; {$IFDEF HAS_INLINE} inline; {$ENDIF HAS_INLINE}
begin
  {$IFDEF NOT_USE_GDIPLUS}
  result := LoadAGifFromStream(b, fs);
  {$ELSE NOT_USE_GDIPLUS}
  result := TRnQAni.Create(fn);
//  NewGPImage(fn);
//   b := not result.CanAnimate;
  b := not result.FAnimated;
  {$ENDIF NOT_USE_GDIPLUS}
end;

function gpColorFromAlphaColor (Alpha: Byte; Color: TColor): Cardinal;
begin
    Result := (Alpha shl 24) or (ABCD_ADCB(
              ColorToRGB(Color)) and $ffffff);
end;

function color2hls(clr: Tcolor): Thls;
var
  r,g,b,a,z,d: double;
begin
  clr := colorToRGB(clr);
  r := GetRvalue(clr)/255;
  g := GetGvalue(clr)/255;
  b := GetBvalue(clr)/255;
  a := min(min(r,g),b);
  z := max(max(r,g),b);
  d := z-a;
with result do
  begin
  l := z;
  if d=0 then
    begin
      h := 0;
      s := 0;
    exit;
    end;
  //if l < 0.5 then s:=d/(z+a) else s:=d/(2-z-a);
  if z=0 then
    s := 0
   else
    result.s := d/z;
  if r=z then
    h := (g-b)/d;
  if g=z then
    h := 2+(b-r)/d;
  if b=z then
    h := 4+(r-g)/d;
  end;
end; // color2hls

function hls2color(hls: Thls): Tcolor;
var
  r,g,b, p,q,t: double;
begin
with hls do
  if s = 0 then
    begin
    r:=l;
    g:=l;
    b:=l;
    end
  else
    begin
    p:=l*(1.0-s);
    q:=l*(1.0-(s*frac(h)));
    t:=l*(1.0-(s*(1.0-frac(h))));

    case trunc(h) of
      0:begin r:=l; g:=t; b:=p end;
      1:begin r:=q; g:=l; b:=p end;
      2:begin r:=p; g:=l; b:=t end;
      3:begin r:=p; g:=q; b:=l end;
      4:begin r:=t; g:=p; b:=l end;
      else begin r:=l; g:=p; b:=q end;
      end;
    end;
result:=round(r*255)+round(g*255) shl 8+round(b*255) shl 16;
end; // hls2color

function addLuminosity(clr: Tcolor; q: real): Tcolor;
var
  hls: Thls;
begin
  hls := color2hls(clr);
  with hls do
   begin
     l := l+q;
     if l<0 then
       l := 0;
     if l>1 then
       l := 1;
   end;
  result := hls2color(hls);
end; // addLuminosity

function  MidColor(clr1, clr2: Cardinal): Cardinal;
begin
  result := 0;
  result := result + ((byte(clr1 shr 24) + byte(clr2 shr 24)) div 2) shl 24;
  result := result + ((byte(clr1 shr 16) + byte(clr2 shr 16)) div 2) shl 16;
  result := result + ((byte(clr1 shr 8) + byte(clr2 shr 8)) div 2) shl 8;
  result := result + ((byte(clr1) + byte(clr2)) div 2);
end;

function  MidColor(const clr1, clr2: Cardinal; koef: Double): Cardinal; overLoad;
var
  r1, g1, b1, a1: Byte;
  r2, g2, b2, a2: Byte;
  k1: Double;
begin
  r1 := byte(clr1 shr 24);
  g1 := byte(clr1 shr 16);
  b1 := byte(clr1 shr 8);
  a1 := byte(clr1);
  r2 := byte(clr2 shr 24);
  g2 := byte(clr2 shr 16);
  b2 := byte(clr2 shr 8);
  a2 := byte(clr2);
  k1 := 1-koef;
  Result := (trunc(r1 * k1 + r2*koef)) shl 24 +
            trunc(g1 * k1 + g2*koef) shl 16 +
            trunc(b1 * k1 + b2*koef) shl 8 +
            trunc(a1 * k1 + a2*koef);
{  result := 0;
  result := result + trunc((byte(clr1 shr 24)*(1-koef) + byte(clr2 shr 24)*koef) ) shl 24;
  result := result + trunc((byte(clr1 shr 16)*(1-koef) + byte(clr2 shr 16)*koef) ) shl 16;
  result := result + trunc((byte(clr1 shr 8)*(1-koef) + byte(clr2 shr 8)*koef) ) shl 8;
  result := result + trunc((byte(clr1)*(1-koef) + byte(clr2)*koef) );
}
end;


function bmp2ico2(bitmap: Tbitmap): Ticon;
var
  iconX, iconY: integer;
  IconInfo: TIconInfo;
  IconBitmap, MaskBitmap: TBitmap;
//  dx,dy,
  x, y: Integer;
  tc: TColor;
begin
if bitmap=NIL then
  begin
  result := NIL;
  exit;
  end;

// iconX := icon_size;
// iconY := icon_size;

 iconX := GetSystemMetrics(SM_CXICON);
 iconY := GetSystemMetrics(SM_CYICON);

 IconBitmap:= createBitmap(iconX, iconY);
 IconBitmap.PixelFormat := bitmap.PixelFormat;
 StretchBlt(IconBitmap.Canvas.Handle, 0, 0, iconX, iconY,
            bitmap.Canvas.Handle, 0, 0, bitmap.Width, bitmap.Height, SRCCOPY);
// iconX := GetSystemMetrics(SM_CXICON);
//iconY := GetSystemMetrics(SM_CYICON);
//IconBitmap:= TBitmap.Create;
//IconBitmap.Width:= iconX;
//IconBitmap.Height:= iconY;
IconBitmap.TransparentColor:=Bitmap.TransparentColor;
tc:=Bitmap.TransparentColor and $FFFFFF;
Bitmap.transparent:=FALSE;
//IconBitmap.Width :=
{with IconBitmap.Canvas do
  begin
  dx:=bitmap.width*2;
  dy:=bitmap.height*2;
  if (dx < iconX) and (dy < iconY) then
    begin
    brush.color:=tc;
    fillrect(clipRect);
    x:=(iconX-dx) div 2;
    y:=(iconY-dy) div 2;
    StretchDraw(Rect(x,y,x+dx,y+dy), Bitmap);
    end
  else
    IconBitmap.Canvas.StretchDraw(Rect(0, 0, iconX, iconY), Bitmap);
  end;}
MaskBitmap:= TBitmap.Create;
MaskBitmap.Assign(IconBitmap);
Bitmap.transparent:=TRUE;
with IconBitmap.Canvas do
  for y:= 0 to iconY - 1 do
    for x:= 0 to iconX - 1 do
      if Pixels[x, y]=tc then
        Pixels[x, y]:=clBlack;
IconInfo.fIcon:= True;
IconInfo.hbmMask:= MaskBitmap.MaskHandle;
IconInfo.hbmColor:= IconBitmap.Handle;
Result:= TIcon.Create;
Result.Handle:= CreateIconIndirect(IconInfo);
MaskBitmap.Free;
IconBitmap.Free;
end; // bmp2ico

function bmp2ico3(bitmap: Tbitmap): Ticon;
var
  il: THandle;
  hi: HICON;
  iconX, iconY: integer;
begin
  Result := TIcon.Create;
// iconX := icon_size;
// iconY := icon_size;

 iconX := GetSystemMetrics(SM_CXICON);
 iconY := GetSystemMetrics(SM_CYICON);

  il := ImageList_Create(iconX, iconY, ILC_COLOR32 or ILC_MASK, 0, 0);
  ImageList_Add(il, bitmap.Handle, bitmap.MaskHandle);
  hi := ImageList_ExtractIcon(0, il, 0);
  Result.Handle := hi;
//  DestroyIcon(hi);
  ImageList_Destroy(il);
end;

function bmp2ico32(bitmap: Tbitmap): HICON;
var
  il: THandle;
  i: Integer;
//  mask: TBitmap;
//  hi: HICON;
begin
//  Result := TIcon.Create;
//  bitmap.PixelFormat := pf32bit;
//  il := ImageList_Create(icon_size, icon_size, ILC_COLOR32 or ILC_MASK, 0, 0);
//  il := ImageList_Create(Min(bitmap.Width, icon_size), Min(bitmap.Height, icon_size), ILC_COLOR32 or ILC_MASK, 0, 0);
  il := ImageList_Create(min(bitmap.Width, bitmap.Height), min(bitmap.Width,bitmap.Height), ILC_COLOR32, 0, 0);
//  ImageList_SetBkColor(il, $00FFFF00);
{          Mask := TBitmap.Create;
          try
            Mask.Assign(bitmap);
            mask.Monochrome := True;
            Mask.TransparentColor := bitmap.TransparentColor;
            Mask.Transparent := True;
            ImageList_AddMasked(il, bitmap.Handle, Mask.MaskHandle);
          finally
            mask.Free;
          end;}
  i := ImageList_Add(il, bitmap.Handle, bitmap.Handle);
  if i >= 0 then
    Result := ImageList_ExtractIcon(0, il, i)
   else
    Result := 0;
//  DestroyIcon(hi);
  ImageList_Destroy(il);
end;

function bmp2ico4M(bitmap: Tbitmap): HICON;
var
  il: THandle;
  i: Integer;
//  mask: TBitmap;
//  hi: HICON;
  iconX, iconY: integer;
begin
//  Result := TIcon.Create;
//  bitmap.PixelFormat := pf32bit;
//  il := ImageList_Create(icon_size, icon_size, ILC_COLOR32 or ILC_MASK, 0, 0);

// iconX := icon_size;
// iconY := icon_size;

 iconX := GetSystemMetrics(SM_CXICON);
 iconY := GetSystemMetrics(SM_CYICON);

  il := ImageList_Create(Min(bitmap.Width, iconX), Min(bitmap.Height, iconY), ILC_COLOR32 or ILC_MASK, 0, 0);
{  if ((Win32MajorVersion > 5)or((Win32MajorVersion = 5)and(Win32MinorVersion >= 1))) then
    i := ILC_HIGHQUALITYSCALE or ILC_COLOR32 or ILC_MASK
   else
    i := ILC_COLOR24 or ILC_MASK;

  il := ImageList_Create(min(bitmap.Width,bitmap.Height), min(bitmap.Width,bitmap.Height), i, 0, 0);
}
//  il := ImageList_Create(icon_size, icon_size, i, 0, 0);
//  il := ImageList_Create(icon_size, icon_size, ILC_COLOR32 or ILC_MASK, 0, 0);
//  ImageList_SetBkColor(il, $00FFFF00);
{          Mask := TBitmap.Create;
          try
            Mask.Assign(bitmap);
            mask.Monochrome := True;
            Mask.TransparentColor := bitmap.TransparentColor;
            Mask.Transparent := True;
            ImageList_AddMasked(il, bitmap.Handle, Mask.MaskHandle);
          finally
            mask.Free;
          end;}
  i := ImageList_Add(il, bitmap.Handle, bitmap.MaskHandle);
  if i >= 0 then
    Result := ImageList_ExtractIcon(0, il, i)
   else
    Result := 0;
//  DestroyIcon(hi);
  ImageList_Destroy(il);
end;

function bmp2ico(bitmap: Tbitmap): Ticon;
var
  iconX, iconY: integer;
  IconInfo: TIconInfo;
  IconBitmap, MaskBitmap: TBitmap;
  dx,dy,x,y: Integer;
  tc: TColor;
begin
  if bitmap=NIL then
   begin
    result := NIL;
    exit;
   end;
iconX := GetSystemMetrics(SM_CXICON);
iconY := GetSystemMetrics(SM_CYICON);
IconBitmap := TBitmap.Create;
IconBitmap.Width := iconX;
IconBitmap.Height := iconY;
IconBitmap.TransparentColor := Bitmap.TransparentColor;
tc := Bitmap.TransparentColor and $FFFFFF;
Bitmap.transparent := FALSE;
//IconBitmap.Width :=
with IconBitmap.Canvas do
  begin
  dx := bitmap.width*2;
  dy := bitmap.height*2;
  if (dx < iconX) and (dy < iconY) then
    begin
    brush.color := tc;
    fillrect(clipRect);
    x := (iconX-dx) div 2;
    y := (iconY-dy) div 2;
    StretchDraw(Rect(x,y,x+dx,y+dy), Bitmap);
    end
  else
    IconBitmap.Canvas.StretchDraw(Rect(0, 0, iconX, iconY), Bitmap);
  end;
MaskBitmap := TBitmap.Create;
MaskBitmap.Assign(IconBitmap);
Bitmap.transparent := TRUE;
with IconBitmap.Canvas do
  for y:= 0 to iconY - 1 do
    for x:= 0 to iconX - 1 do
      if Pixels[x, y]=tc then
        Pixels[x, y] := clBlack;
IconInfo.fIcon := True;
IconInfo.hbmMask := MaskBitmap.MaskHandle;
IconInfo.hbmColor := IconBitmap.Handle;
Result := TIcon.Create;
Result.Handle := CreateIconIndirect(IconInfo);
MaskBitmap.Free;
IconBitmap.Free;
end; // bmp2ico

function pic2ico(pic: Tbitmap): Ticon;
begin
  result := bmp2ico(pic)
end;

procedure ico2bmp(ico: TIcon; bmp: TBitmap);
//var
//  IcoStream: TIconStream;
//  str: TMemoryStream;
//  idx: Integer;
// il: TCustomImageList;
// ilH: HIMAGELIST;
// R: TRect;
begin
//  il := TCustomImageList.Create(NIL);
{   ilH :=  ImageList_Create(icon_size, icon_size, ILC_COLOR32// or ILC_MASK
   , 0, 0);
  ImageList_AddIcon(ilH, ico.Handle);
  bmp.Width := icon_size;
  bmp.Height := icon_size;
  ImageList_Draw(ilH, 0, bmp.Canvas.Handle, 0, 0, ILD_NORMAL);
  ImageList_Destroy(ilh);}
//  il.AddIcon(ico);
//  il.GetBitmap(0, bmp);
//  bmp.Width := icon_size; //ico.Width;
//  bmp.Height := icon_size;
  bmp.Width  := GetSystemMetrics(SM_CXICON);
  bmp.Height := GetSystemMetrics(SM_CYICON);
  bmp.PixelFormat := pf24bit;
  bmp.Canvas.Brush.Color:= $010100;
  bmp.Canvas.FillRect(bmp.Canvas.ClipRect);

//  DrawIconEx(bmp.Canvas.Handle, 0, 0, ico.Handle, icon_size, icon_size, 0, 0, DI_NORMAL);

//          ico := TIcon.Create;
//          ico.Handle := hi;
//          pic.Width := ico.Width;
//          pic.Height := ico.Height;
            bmp.Canvas.StretchDraw(Rect(0, 0, bmp.Width, bmp.Height), ico);
//          bmp.Canvas.Draw(0, 0, ico);
//          pic.Assign(ico); //CopyImage(hi, IMAGE_ICON, 0, 0, LR_CREATEDIBSECTION)
//          DestroyIcon(hi);
//          ico.Free;

  bmp.TransparentColor := $010100;
  bmp.Transparent := True;
{
  IcoStream := TIconStream.Create;
  str := TMemoryStream.Create;
  ico.SaveToStream(str);
  IcoStream.LoadFromStream(str);
  idx := 0;
//  if (idx < 1) or (idx > IcoStream.Count) then
//    idx := 1;
//  dec(idx);
//        bmp:= TBitmap.Create;
  bmp.Height:= IcoStream[Idx].bHeight;
  bmp.Width := IcoStream[Idx].bWidth;
  if IcoStream[idx].wBitCount = 32 then
    bmp.PixelFormat := pf32bit
   else
    bmp.PixelFormat := pf24bit;
//        bmp.Canvas.Brush.Color:= clBtnFace;
  bmp.Canvas.Brush.Color:= $FF010101;
  bmp.Canvas.FillRect(bmp.Canvas.ClipRect);

  IcoStream.Draw(bmp.Canvas.Handle, 0,0, Idx);
  bmp.TransparentColor := $FF010101;
  bmp.Transparent := True;
  IcoStream.Free;
  str.Free;}
end;

procedure ico2bmp2(pIcon: HIcon; bmp: TBitmap);
var
//  IcoStream: TIconStream;
//  str: TMemoryStream;
//  idx: Integer;
// il: TCustomImageList;
 ilH: HIMAGELIST;
// hi: HICON;
// ico: TIcon;
// R: TRect;
  iconX, iconY: integer;
begin
//  il := TCustomImageList.Create(NIL);
{   ilH:=  ImageList_Create(icon_size, icon_size, ILC_COLOR32// or ILC_MASK
   , 0, 0);
  ImageList_AddIcon(ilH, ico.Handle);
  ImageList_Draw(ilH, 0, bmp.Canvas.Handle, 0, 0, ILD_NORMAL);
  ImageList_Destroy(ilh);}

  iconX := GetSystemMetrics(SM_CXICON);
  iconY := GetSystemMetrics(SM_CYICON);

 {$IFDEF DELPHI9_UP}// By Rapid D
  bmp.SetSize(iconX, iconY);
 {$ELSE DELPHI_9_dn}
  bmp.Height := 0;
  bmp.Width := iconX;
  bmp.Height := iconY;
 {$ENDIF DELPHI9_UP}// By Rapid D
  bmp.TransparentColor := $010100;
//  il.AddIcon(ico);
//  il.GetBitmap(0, bmp);
//  bmp.Canvas.Brush.Color:= bmp.TransparentColor;
//  bmp.Canvas.FillRect(bmp.Canvas.ClipRect);
//  hi := CopyImage(pIcon, IMAGE_ICON, icon_size, icon_size, 0);
//  hi := CopyImage(pIcon, IMAGE_ICON, icon_size, icon_size, LR_CREATEDIBSECTION);
//  DrawIconEx(bmp.Canvas.Handle, 0, 0, hi, icon_size, icon_size, 0, 0, DI_NORMAL);
//  DrawIconEx(bmp.Canvas.Handle, 0, 0, pIcon, icon_size, icon_size, 0, 0, DI_NORMAL);
      ilH := ImageList_Create(iconX, iconY, ILC_COLOR32 or ILC_MASK, 0, 0);
      ImageList_AddIcon(ilH, pIcon);
//          hi := ImageList_ExtractIcon(0, ilH, 0);
//          ImageList_Draw(ilH, 0, bmp.Canvas.Handle, 0, 0, ILD_TRANSPARENT);
//          ImageList_DrawEx(ilH, 0, bmp.Canvas.Handle, 0, 0, 0, 0, bmp.TransparentColor, CLR_NONE, ILD_TRANSPARENT);
          ImageList_DrawEx(ilH, 0, bmp.Canvas.Handle, 0, 0, 0, 0, bmp.TransparentColor, CLR_NONE, ILD_NORMAL);
      ImageList_Destroy(ilH);
//          ico := TIcon.Create;
//          ico.Handle := hi;
//          DrawIconEx()
//          bmp.Width := ico.Width;
//          bmp.Height := ico.Height;
//  bmp.Canvas.Brush.Color:= $010100;
//  bmp.Canvas.FillRect(bmp.Canvas.ClipRect);
//          bmp.Canvas.Draw(0, 0, ico);

//          pic.Assign(ico); //CopyImage(hi, IMAGE_ICON, 0, 0, LR_CREATEDIBSECTION)
//          ico.Free;
//  DestroyIcon(hi);
{
  bmp.PixelFormat := pf24bit;


//          ico := TIcon.Create;
//          ico.Handle := hi;
//          pic.Width := ico.Width;
//          pic.Height := ico.Height;
            bmp.Canvas.StretchDraw(Rect(0, 0, icon_size, icon_size), ico);
//          bmp.Canvas.Draw(0, 0, ico);
//          pic.Assign(ico); //CopyImage(hi, IMAGE_ICON, 0, 0, LR_CREATEDIBSECTION)
//          DestroyIcon(hi);
//          ico.Free;
}
//  bmp.Transparent := True;
//   bmp.TransparentMode := tmAuto;
   bmp.Transparent := True;
//   bmp.Transparent := False;
{
  IcoStream := TIconStream.Create;
  str := TMemoryStream.Create;
  ico.SaveToStream(str);
  IcoStream.LoadFromStream(str);
  idx := 0;
//  if (idx < 1) or (idx > IcoStream.Count) then
//    idx := 1;
//  dec(idx);
//        bmp:= TBitmap.Create;
  bmp.Height:= IcoStream[Idx].bHeight;
  bmp.Width := IcoStream[Idx].bWidth;
  if IcoStream[idx].wBitCount = 32 then
    bmp.PixelFormat := pf32bit
   else
    bmp.PixelFormat := pf24bit;
//        bmp.Canvas.Brush.Color:= clBtnFace;
  bmp.Canvas.Brush.Color:= $FF010101;
  bmp.Canvas.FillRect(bmp.Canvas.ClipRect);

  IcoStream.Draw(bmp.Canvas.Handle, 0,0, Idx);
  bmp.TransparentColor := $FF010101;
  bmp.Transparent := True;
  IcoStream.Free;
  str.Free;}
end;

function TrimInt(i, Min, Max: Integer): Integer;
begin
  if      i>Max then
    Result := Max
  else if i<Min then
    Result := Min
  else
    Result := i;
end;

function IntToByte(i: Integer): Byte;
begin
  if      i>255 then
    Result := 255
  else if i<0   then
    Result := 0
  else
    Result := i;
end;

procedure SmoothRotate(var Src, Dst: TBitmap; cx, cy: Integer; Angle: Extended);
type
 TFColor  = record b,g,r, a: Byte end;
const
  colorBytes  = 4;
var
  Top, Bottom,
  Left, Right,
  eww,nsw,
  fx,fy,
  wx,wy:  Extended;
  cAngle, sAngle:   Double;
  xDiff, yDiff,
  ifx, ify,
  px, py,
  ix, iy,
  x, y:     Integer;
  nw, ne,
  sw, se:   TFColor;
  P1, P2, P3: Pbytearray;
begin
  Angle := angle;
  Angle := -Angle*Pi/180;
  sAngle := Sin(Angle);
  cAngle := Cos(Angle);
  xDiff := (Dst.Width-Src.Width)div 2;
  yDiff := (Dst.Height-Src.Height)div 2;
  for y:=0 to Dst.Height-1 do
  begin
    P3 := Dst.scanline[y];
    py := 2*(y-cy)+1;
    for x:=0 to Dst.Width-1 do
    begin
      px := 2*(x-cx)+1;
      fx := (((px*cAngle-py*sAngle)-1)/ 2+cx)-xDiff;
      fy := (((px*sAngle+py*cAngle)-1)/ 2+cy)-yDiff;
      ifx := Round(fx);
      ify := Round(fy);

      if(ifx>-1)and(ifx<Src.Width)and(ify>-1)and(ify<Src.Height)then
      begin
        eww := fx-ifx;
        nsw := fy-ify;
        iy := TrimInt(ify+1,0,Src.Height-1);
        ix := TrimInt(ifx+1,0,Src.Width-1);
        P1 := Src.scanline[ify];
        P2 := Src.scanline[iy];
        nw.r := P1[ifx*colorBytes];
        nw.g := P1[ifx*colorBytes+1];
        nw.b := P1[ifx*colorBytes+2];
        nw.a := P1[ifx*colorBytes+3];

        ne.r := P1[ix*colorBytes];
        ne.g := P1[ix*colorBytes+1];
        ne.b := P1[ix*colorBytes+2];
        ne.a := P1[ix*colorBytes+3];

        sw.r := P2[ifx*colorBytes];
        sw.g := P2[ifx*colorBytes+1];
        sw.b := P2[ifx*colorBytes+2];
        sw.a := P2[ifx*colorBytes+3];

        se.r := P2[ix*colorBytes];
        se.g := P2[ix*colorBytes+1];
        se.b := P2[ix*colorBytes+2];
        se.a := P2[ix*colorBytes+3];


        Top := nw.a+eww*(ne.a-nw.a);
        Bottom := sw.a+eww*(se.a-sw.a);
        P3[x*colorBytes+3] := IntToByte(Round(Top+nsw*(Bottom-Top)));

        Top := nw.b+eww*(ne.b-nw.b);
        Bottom:=sw.b+eww*(se.b-sw.b);
        P3[x*colorBytes+2]:=IntToByte(Round(Top+nsw*(Bottom-Top)));

        Top := nw.g+eww*(ne.g-nw.g);
        Bottom:=sw.g+eww*(se.g-sw.g);
        P3[x*colorBytes+1]:=IntToByte(Round(Top+nsw*(Bottom-Top)));

        Top := nw.r+eww*(ne.r-nw.r);
        Bottom:=sw.r+eww*(se.r-sw.r);
        P3[x*colorBytes]:=IntToByte(Round(Top+nsw*(Bottom-Top)));
      end;
    end;
  end;
end;




procedure CalcPalette(DC: HDC);
{calculate a rainbow palette, one with equally spaced colors}
const
  Values: array[0..5] of integer = (55, 115, 165, 205, 235, 255);
var
  LP: ^TLogPalette;
  I, J, K, Sub: integer;
begin
  GetMem(LP, Sizeof(TLogPalette) + 256*Sizeof(TPaletteEntry));
try
  with LP^ do
    begin
    palVersion := $300;
    palNumEntries := 256;
    GetSystemPaletteEntries(DC, 0, 256, palPalEntry);
    Sub := 10;  {start at entry 10}
    for I := 0 to 5 do
      for J := 0 to 5 do
        for K := 0 to 5 do
          if not ((I=5) and (J=5) and (K=5)) then  {skip the white}
            with palPalEntry[Sub] do
              begin
              peBlue := Values[I];
              peGreen := Values[J];
              peRed := Values[K];
              peFlags := 0;
              Inc(Sub);
              end;
    for I := 1 to 24 do
       if not (I in [7, 15, 21]) then   {these would be duplicates}  
          with palPalEntry[Sub] do
            begin
            peBlue := 130 + 5*I;
            peGreen := 130 + 5*I;
            peRed := 130 + 5*I;
            peFlags := 0;
            Inc(Sub);
            end;
    ThePalette := CreatePalette(LP^);
    end;
finally
  FreeMem(LP, Sizeof(TLogPalette) + 256*Sizeof(TPaletteEntry));
  end;
end;





function blend(c1, c2: Tcolor; left: real): Tcolor;
var
  right: real;
//  clr1: Tcolor32;
begin
  right := 1-left;
  c1 := colorToRGB(c1);
  c2 := colorToRGB(c2);
  result := rgb(
     round(left*(c1 and $FF)+right*(c2 and $FF)),
     round(left*(c1 shr 8 and $FF)+right*(c2 shr 8 and $FF)),
     round(left*(c1 shr 16)+right*(c2 shr 16))
    );
end; // blend

function traspBmp1(bmp: Tbitmap; bg: Tcolor; transpLevel: integer): Tbitmap;
var
  a, t: Tcolor;
  x,y, r,g,b: integer;
begin
  result := Tbitmap.create;
  result.Assign(bmp);
  bg := colorToRGB(bg);
  r := transpLevel*(bg and $FF);
  g := transpLevel*(bg shr 8 and $FF);
  b := transpLevel*(bg shr 16);
  bg := r+g+b;
  t := result.TransparentColor and $FFFFFF;
with result.Canvas do
  for x:=0 to result.width-1 do
    for y:=0 to result.height-1 do
      begin
      a:=Pixels[x,y] and $FFFFFF;
      if a=t then continue;
      r:=a and $FF;
      g:=a shr 8 and $FF;
      b:=a shr 16;
      a:=(r+g+b+bg) div ((transpLevel+1)*3);
      pixels[x,y] := rgb(a,a,a);
      end;
  result.transparent := bmp.transparent;
  result.transparentcolor := bmp.transparentcolor;
end; // traspBmp



var
  DC: HDC;
  ColorBits: Byte;
  h: HMODULE;

initialization
  DC := GetDC(0);
  try
    ColorBits := GetDeviceCaps(DC, BitsPixel)*GetDeviceCaps(DC, Planes);

    if ColorBits <= 4 then
      ColorBits := 4
    else if ColorBits <= 8 then
      ColorBits := 8
    else
      ColorBits := 24;

    ThePalette := 0;
    if ColorBits = 8 then
      CalcPalette(DC);
   finally
    ReleaseDC(0, DC);
  end;
  checkWICCodecs;

{$ifdef TransparentStretchBltMissing}
  // Note: This doesn't return the same palette as the Delphi 3 system palette
  // since the true system palette contains 20 entries and the Delphi 3 system
  // palette only contains 16.
  // For our purpose this doesn't matter since we do not care about the actual
  // colors (or their number) in the palette.
  // Stock objects doesn't have to be deleted.
  SystemPalette16 := GetStockObject(DEFAULT_PALETTE);
{$endif}

  h := LoadLibrary(modulesPath + 'jpegturbo.dll');
  if h <> 0 then
  begin
    JPEGTurbo := True;
    FreeLibrary(h);
    TJpegImage.LibPathName := modulesPath + 'jpegturbo.dll';
  end else
    JPEGTurbo := False;

finalization
  if ThePalette <> 0 then
    DeleteObject(ThePalette);


end.
