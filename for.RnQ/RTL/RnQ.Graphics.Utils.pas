unit RnQ.Graphics.Utils;
{$I ForRnQConfig.inc}
{$I NoRTTI.inc}

{$IFDEF FPC}
 { $DEFINE DELPHI9_UP}
  {$DEFINE TransparentStretchBltMissing}
  {$DEFINE CopyPaletteMissing}
{$ENDIF}

interface

uses
  Messages, Windows, SysUtils, Types, Classes,
  {$IF DEFINED(DELPHI9_UP) OR DEFINED(FPC)}
    System.UITypes,
  {$ENDIF DELPHI9_UP}
  {$IFDEF FPC}
  LCLType,
  {$ENDIF FPC}
 {$IFDEF FMX}
  FMX.Graphics,
 {$ELSE ~FMX}
  Graphics,
 {$ENDIF FMX}
  RDGlobal
  ;


{$IFDEF FPC}
const
  //gdi32 = 'gdi32.dll';
  msimg32 = 'msimg32.dll';
{$ENDIF FPC}

type
  TGradientDirection = (gdVertical, gdHorizontal);

  procedure FlipVertical(var img: TBitmap);
  procedure StretchPic(var bmp: TBitmap; maxH, maxW: Integer); overload;

  procedure SmoothRotate(var Src, Dst: TBitmap; cx, cy: Integer; Angle: Extended);

  procedure FillGradient(DC: HDC; ARect: TRect; //ColorCount: Integer;
    StartColor, EndColor: Cardinal; ADirection: TGradientDirection; Alpha: Byte = $FF);
  {$IFNDEF DELPHI9_UP}
  function WinGradientFill(DC: HDC; Vertex: PTriVertex; NumVertex: ULONG; Mesh: Pointer; NumMesh, Mode: ULONG): BOOL; stdcall;
  {$ENDIF DELPHI9_UP}
  procedure FillRoundRectangle(DC: HDC; ARect: TRect; Clr: Cardinal; rnd: Word);
//  Procedure FillRectangle(DC: HDC; ARect: TRect; Clr : Cardinal);
  procedure DrawTextTransparent(DC: HDC; x, y: Integer; Text: String; Font: TFont; Alpha: Byte; fmt: Integer);
// {$IFDEF DELPHI9_UP}
 {$IF DEFINED(DELPHI9_UP) OR DEFINED(FPC)}
  procedure DrawText32(DC: HDC; TextRect: TRect; Text: String; Font: TFont; TextFlags: Cardinal);
 {$ENDIF DELPHI9_UP}
 {$IFNDEF NO_WIN98}
  procedure DrawTransparentBitmap(dc: HDC; DrawBitmap: HBitmap; DestBnd: TGPRect; srcW, srcH: Integer; cTransparentColor: COLORREF);
 {$ENDIF NO_WIN98}
 {$IFDEF TransparentStretchBltMissing}
  function TransparentStretchBlt(DstDC: HDC; DstX, DstY, DstW, DstH: Integer;
   SrcDC: HDC; SrcX, SrcY, SrcW, SrcH: Integer; MaskDC: HDC; MaskX,
   MaskY: Integer): Boolean;
  function AlphaBlend(hdcDest: HDC; xoriginDest, yoriginDest, wDest, hDest: Integer;
                      hdcSrc: HDC; xoriginSrc, yoriginSrc, wSrc, hSrc: Integer; p11: TBlendFunction): BOOL;
 {$ENDIF TransparentStretchBltMissing}
 {$ifdef CopyPaletteMissing}
  function CopyPalette(Palette: HPALETTE): HPALETTE;
 {$ENDif CopyPaletteMissing}
 {$IFDEF FPC}
  function BytesPerScanline(PixelsPerScanline, BitsPerPixel, Alignment: Longint): Longint;
 {$ENDIF}


  function  wbmp2bmp(Stream: TStream; var pic: TBitmap; CalcOnly: Boolean = False): TSize;
  function LoadIconFromStream(str: TStream): HIcon;

  function  createBitmap(dx, dy: integer; PPI: Integer = cDefaultDPI): Tbitmap; overload;
  function  createBitmap(cnv: Tcanvas): Tbitmap; overload;
  procedure InitTransAlpha(var bmp: TBitmap);
  procedure Premultiply(var bmp: TBitmap);
  procedure Demultiply(var bmp: TBitmap);


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

{$IFDEF FPC}
  function TransparentBlt(hdcSrc: HDC; nXOriginSrc, nYOriginSrc, nWidthSrc,
    nHeightSrc: Integer; hdcDest: HDC; nXOriginDest, nYOriginDest, nWidthDest,
    nHeightDest: Integer; crTransparent: LongWord): BOOL; stdcall;
{$ENDIF}

// convert
 {$IFNDEF FMX}
  function pic2ico(pic: Tbitmap): Ticon;
  function bmp2ico2(bitmap: Tbitmap): Ticon;
  function bmp2ico3(bitmap: Tbitmap): Ticon;
  function bmp2ico4M(bitmap: Tbitmap): hicon;
  function bmp2ico32(bitmap: Tbitmap): hicon;
  function bmp2ico(bitmap: Tbitmap): Ticon;
  procedure ico2bmp(ico: TIcon; bmp: TBitmap);
 {$ENDIF ~FMX}

  procedure ico2bmp2(pIcon: HIcon; bmp: TBitmap);

  procedure LoadPictureStream2(str: TStream; var bmp: TBitmap);

const
  icon_size = 16;

implementation
 uses
   StrUtils,
 {$IFNDEF FMX}
   Themes,
 {$ENDIF ~FMX}
   UxTheme,
 {$IF DEFINED(DELPHI9_UP) OR DEFINED(FPC)}
//   DwmApi,
   {$IFNDEF FPC}
   {$IFDEF UNICODE}
     AnsiStrings,
   {$ENDIF UNICODE}
   {$ENDIF FPC}
 {$ENDIF DELPHI9_UP}
    CommCtrl,
    ActiveX,
   RDUtils,
  math
   ;
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
 IID_IPicture: TGUID = '{7BF80980-BF32-101A-8BBB-00AA00300CAB}';

{$IFDEF FPC}
procedure RaiseExceptions;
begin
  RaiseException(0, 0, 0, 0);
end;
{$ENDIF FPC}

procedure InitTransAlpha(var bmp: TBitmap);
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
  if bmp.PixelFormat <> pf32bit then
    Exit;

  Bt := bmp.Transparent;
  h := bmp.Height-1; // Сразу вычетаем 1 !!!
  w := bmp.Width-1;  // Сразу вычетаем 1 !!!

  Trans.Color := ColorToRGB(bmp.TransparentColor) and not AlphaMask;
{$IFDEF FPC}
  bmp.BeginUpdate;
{$ENDIF FPC}
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
{$IFDEF FPC}
  bmp.EndUpdate;
{$ENDIF FPC}
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
  if bmp.PixelFormat <> pf32bit then
    Exit;
  h := bmp.Height-1; // Сразу вычетаем 1 !!!
  w := bmp.Width-1;  // Сразу вычетаем 1 !!!
{$IFDEF FPC}
  bmp.BeginUpdate;
{$ENDIF FPC}
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
{$IFDEF FPC}
  bmp.EndUpdate;
{$ENDIF FPC}
end;

procedure Demultiply(var bmp: TBitmap);
var
 Scan32: pColor32Array;
 I, X: Cardinal;
 A1: Double;
 h, w: Integer;
begin
  if bmp.PixelFormat <> pf32bit then
    Exit;
  h := bmp.Height-1;
  w := bmp.Width-1;
{$IFDEF FPC}
  bmp.BeginUpdate;
{$ENDIF FPC}
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
{$IFDEF FPC}
  bmp.EndUpdate;
{$ENDIF FPC}
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
    const iid: TGUID; var vObject): HResult; stdcall external 'OleAut32.dll' name 'OleLoadPicture';
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

procedure LoadPictureStream2(str: TStream; var bmp: TBitmap);
var
  pic: IPicture;
  a, b: integer;
  h, w: integer;
  r: TRect;
begin
  LoadPictureStream(str, pic);
  if pic <> nil then
  begin
    pic.get_Width(a);
    pic.get_Height(b);

    if not Assigned(bmp) then
      begin
        bmp := TBitmap.Create;
        bmp.PixelFormat := pf24bit;
      end;

    w := MulDiv(a, GetDeviceCaps(bmp.canvas.Handle, LOGPIXELSX), 2540);
    h := MulDiv(b, GetDeviceCaps(bmp.canvas.Handle, LOGPIXELSY), 2540);
    r.Left := 0;
    r.Top := 0;
    r.Right := w;
    r.Bottom := h;
 {$IF DEFINED(DELPHI9_UP) OR DEFINED(FPC)}
    bmp.SetSize(w, h);
 {$ELSE DELPHI9_UP}
    bmp.Height := 0;
    bmp.Width := w;
    bmp.Height := h;
 {$ENDIF DELPHI9_UP}
    pic.Render(bmp.canvas.Handle, 0, 0, w, h, 0, b, a, -b, r);
    pic := NIL;
  end;
end;

{ $ENDIF ~FPC}

function GetLastErrorText: string;
var
  C: array[Byte] of Char;
begin

  FormatMessage(
    FORMAT_MESSAGE_FROM_SYSTEM,
    nil,
    GetLastError,
    LOCALE_USER_DEFAULT,
    @C[0],
    SizeOf(C),
    nil);
  Result:=StrPas( C );
end;

function LoadIconFromStream(str: TStream): HIcon;
{var
  MStr: TMemoryStream;
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
  LogPal: LOGPALETTE;
  //LogPal: TMaxLogPalette;
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
 {$IFDEF FPC}
  Result := CreatePalette((Windows.PLogPalette(@LogPal))^);
 {$ELSE ~FPC}
  Result := CreatePalette(PLogPalette(@LogPal)^);
 {$ENDIF FPC}

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
function GDICheck(Value: HANDLE): HANDLE;
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
  {$asmMode intel}
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
 function BytesPerScanline(PixelsPerScanline, BitsPerPixel, Alignment: Longint): Longint;
 begin
   Dec(Alignment);
   Result := ((PixelsPerScanline * BitsPerPixel) + Alignment) and not Alignment;
   Result := Result div 8;
 end;
{$ENDIF}

{$IFDEF FPC}
function TransparentBlt(hdcSrc: HDC; nXOriginSrc, nYOriginSrc, nWidthSrc,
  nHeightSrc: Integer; hdcDest: HDC; nXOriginDest, nYOriginDest, nWidthDest,
  nHeightDest: Integer; crTransparent: LongWord): BOOL; stdcall; external msimg32 name 'TransparentBlt';
{$ENDIF}


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
           {$IF DEFINED(DELPHI9_UP) or DEFINED(FPC)}
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
            pic.Palette := CreatePalette(Windows.PLogPalette(@Pal)^);
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
 {$IF DEFINED(DELPHI9_UP) OR DEFINED(FPC)}
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

procedure ResizeBitmap(Bitmap: TBitmap; const NewWidth, NewHeight: integer);
begin
  Bitmap.Canvas.StretchDraw(
    Rect(0, 0, NewWidth, NewHeight),
    Bitmap);
  Bitmap.SetSize(NewWidth, NewHeight);
end;

procedure StretchPic(var bmp: TBitmap; maxH, maxW: Integer);
var
  bmp1: TBitmap;
  sx, sy: Integer;
begin
  if (bmp.Width > maxW )
   or (bmp.Height > maxH) then
  begin
   if bmp.Width * maxH < bmp.Height * maxW then
     begin
       sx := maxH*bmp.Width div bmp.Height;
       sy := maxH;
     end
    else
     begin
       sx := maxW;
       sy := maxW*bmp.Height div bmp.Width;
     end;
   bmp1 := createBitmap(sx, sy);
   bmp1.PixelFormat := bmp.PixelFormat;
   bmp1.Canvas.StretchDraw(Rect(0, 0, bmp1.Width, bmp1.Height), bmp);
   FreeAndNil(bmp);
   bmp := bmp1;
//   bmp1 := nil;
 end;
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

  {$IFDEF DELPHI9_UP}
type
  COLOR16_RD = COLOR16;
  {$ELSE !DELPHI9_UP}
function WinGradientFill; external msimg32 name 'GradientFill';
type
  COLOR16_RD = UInt16;

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
   mode: Cardinal;

  tempDC: HDC;
  ABitmap, HOldBmp: HBITMAP;
//  BIH: TBitmapInfoHeader;
  BI: Windows.TBitmapInfo;
  blend: BLENDFUNCTION;
//  oldBr, brF: HBRUSH;
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
          Red := COLOR16_RD(Byte(StartColor)) shl 8;
          Blue := COLOR16_RD(Byte(StartColor shr 16)) shl 8;
          Green := COLOR16_RD(Byte(StartColor shr 8)) shl 8;
          Alpha := COLOR16_RD(Byte(StartColor shr 24)) shl 8;
     end;

     with udtVertex[1] do
     begin
          x := ARect.Right;
          y := ARect.Bottom;
//          Red := GetRValue(EndColor) shl 8;
//          Blue := GetBValue(EndColor) shl 8;
//          Green := GetGValue(EndColor) shl 8;
//          Alpha := Byte(EndColor shr 24) shl 8;
          Red := COLOR16_RD(Byte(EndColor)) shl 8;
          Blue := COLOR16_RD(Byte(EndColor shr 16)) shl 8;
          Green := COLOR16_RD(Byte(EndColor shr 8)) shl 8;
          Alpha := COLOR16_RD(Byte(EndColor shr 24)) shl 8;
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
 {$IF DEFINED(DELPHI9_UP) OR DEFINED(FPC)}
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
          h := res.cY-1;  // Сразу вычетаем 1 !!!
          w := res.cx-1;  // Сразу вычетаем 1 !!!

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

{$IF DEFINED(DELPHI9_UP) OR DEFINED(FPC)}
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
      ZeroMemory(@Options, SizeOf(Options));
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
  {$IFDEF FPC}
   PaintBuffer := BeginBufferedPaint(DC, @TextRect, BPBF_TOPDOWNDIB, nil, MemDC);
  {$ELSE ~FPC}
   PaintBuffer := BeginBufferedPaint(DC, TextRect, BPBF_TOPDOWNDIB, nil, MemDC);
  {$ENDIF FPC}
      try
         BufferedPaintClear(PaintBuffer, @TextRect);
//          SetBKMode(MemDC, TRANSPARENT);
          oldF := SelectObject(MemDC, Font.Handle);
        {$IFDEF FPC}
         ThemeServices.DrawText(MemDC, ThemeServices.GetElementDetails(TThemedWindow.twCaptionActive), Text, TextRect, TextFlags, 0);
        {$ELSE ~FPC}
//         FillRect(MemDC, R, GetStockObject(BLACK_BRUSH));
//         FillRect(MemDC, R, GetStockObject(LTGRAY_BRUSH));
//         DrawText(MemDC, PChar(Text), Length(Text), R, fmt);
//          with ThemeServices.GetElementDetails(twCaptionActive) do
//            DrawThemeTextEx(ThemeServices.Theme[element], MemDC, Part, State,
            //DrawThemeTextEx(ThemeServices.Theme[teWindow], MemDC, 0, 0,
            DrawThemeTextEx(StyleServices.Theme[teWindow], MemDC, 0, 0,
                PWideChar(WideString(Text)), TextLen, TextFlags, @TextRect, Options);
        {$ENDIF FPC}
          SelectObject(MemDC, oldF);
//          DeleteObject(oldF);
//        BufferedPaintMakeOpaque(PaintBuffer, @R);
      finally
        EndBufferedPaint(PaintBuffer, True);
      end;
end;
 {$ENDIF DELPHI9_UP}

function gpColorFromAlphaColor (Alpha: Byte; Color: Graphics.TColor): Cardinal;
begin
    Result := (Alpha shl 24) or (ABCD_ADCB(
              ColorToRGB(Color)) and $ffffff);
end;

function color2hls(clr: Graphics.Tcolor): Thls;
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

 {$IF DEFINED(DELPHI9_UP) OR DEFINED(FPC)}
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
//  Left, Right,
  eww,nsw,
  fx,fy,
//  wx,wy:  Extended;
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

Procedure FlipVertical(var img: TBitmap);
const
  BitCounts: array [pf1Bit..pf32Bit] of Byte = (1,4,8,16,16,24,32);
var
  BytesPerRow: Integer;
  bmpbuf: TBytes;
  j, j2: integer;
  P1, P2: Pbytearray;
begin
  if (not Assigned(img)) or (img.Height<2) or (img.Width = 0) then
    Exit;
    { in-place }
  if img.PixelFormat = pfDevice then
  {$IFDEF FPC}
    img.FreeImage;
  {$ELSE ~FPC}
    img.Dormant;
  {$ENDIF FPC}
  BytesPerRow := BytesPerScanline(img.Width, BitCounts[img.PixelFormat], 32);
  SetLength(bmpbuf, BytesPerRow);
  J2 := img.Height - 1;
//    GetMem(Buffer, img.Width shl 2);
    for J := 0 to img.Height div 2 - 1 do
    begin
      P1 := img.ScanLine[j];
      P2 := img.ScanLine[j2];
      CopyMemory(@bmpbuf[0], P1, BytesPerRow);
      CopyMemory(P1, P2, BytesPerRow);
      CopyMemory(P2, @bmpbuf[0], BytesPerRow);
      Dec(J2);
    end;
  SetLength(bmpbuf, 0);
end;

Procedure FlipVerticalSlow(var Picture: TBitmap);
var
  BMP: TBitmap;
  i,j: integer;
begin
  BMP := TBitmap.Create;
  BMP.Assign(Picture);
  for i := 0 to BMP.Height-1 do
    for j := 0 to BMP.Width-1 do
      Picture.canvas.Pixels[j, BMP.Height-i-1] := BMP.canvas.Pixels[j, i];
  BMP.free;
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

initialization

{$ifdef TransparentStretchBltMissing}
  // Note: This doesn't return the same palette as the Delphi 3 system palette
  // since the true system palette contains 20 entries and the Delphi 3 system
  // palette only contains 16.
  // For our purpose this doesn't matter since we do not care about the actual
  // colors (or their number) in the palette.
  // Stock objects doesn't have to be deleted.
  SystemPalette16 := GetStockObject(DEFAULT_PALETTE);
{$endif}

end.
