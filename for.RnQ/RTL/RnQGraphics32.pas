unit RnQGraphics32;
{$I ForRnQConfig.inc}
{$I NoRTTI.inc}

interface

uses
  Messages, Windows, SysUtils, Types, Classes,
  {$IF DEFINED(DELPHI9_UP) OR DEFINED(FPC)}
    System.UITypes,
  {$ENDIF DELPHI9_UP}
  {$IFDEF FPC}
  LCLType,
  {$ENDIF FPC}
  Graphics,
  Forms,
  Controls,
  RDFileUtil,
  RDGlobal
  ;


{$IFDEF FPC}
const
  //gdi32 = 'gdi32.dll';
  msimg32 = 'msimg32.dll';
{$ENDIF FPC}

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
    Blending: Boolean;  // this frame has to be blended instead of
      // just drawed over the previous frame. (just transparent pixels)

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
  TRnQBitmap = class(TGraphic)
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
    procedure DrawBound(DC: HDC; DestR: TGPRect; Bound: Boolean = True; Scale: Boolean = True); Overload;
    procedure StretchDraw(DC: HDC; DestR: TGPRect); Overload;
    procedure Draw(ACanvas: TCanvas; const Rect: TRect); Overload; OverRide;
    procedure DrawTransparent(ACanvas: TCanvas; const Rect: TRect; Opacity: Byte); {$IFNDEF FPC}OverRide; {$ENDIF}
    function  GetEmpty: Boolean; OverRide;
    function  GetPalette: HPALETTE; OverLoad;
    function  GetTransparent: Boolean; OverRide;
//    function  Clone(x, y, pWidth, pHeight: Integer): TRnQBitmap;
    function  Clone(bnd: TGPRect): TRnQBitmap;
    function  CloneFrame(frame: Integer): TRnQBitmap;
    function  CloneAll: TRnQBitmap;
    procedure SetTransparent(t: Boolean);
    procedure SetTransparentColor(clr: cardinal);
    function  bmp2ico32: HIcon;
    procedure GetHICON(var hi: HICON);
    function  GetWidth: Integer;  OverRide; //{$IFDEF HAS_INLINE}inline; {$ENDIF HAS_INLINE}
    function  GetHeight: Integer; OverRide; //{$IFDEF HAS_INLINE}inline; {$ENDIF HAS_INLINE}
    procedure SetWidth(W: Integer);  OverRide;
    procedure SetHeight(H: Integer); OverRide;
    procedure SaveToStream(Stream: TStream); OverRide; deprecated 'Don''t coded yet';
 {$IFNDEF FPC}
    procedure LoadFromClipboardFormat(AFormat: Word; AData: THandle;
      APalette: HPALETTE); OverRide; deprecated 'Don''t coded yet';
    procedure SaveToClipboardFormat(var AFormat: Word; var AData: THandle;
      var APalette: HPALETTE); OverRide; deprecated 'Don''t coded yet';
  {$ELSE LAZARUS}
    procedure LoadFromClipboardFormat(FormatID: TClipboardFormat); OverRide; deprecated 'Don''t coded yet';
 {$ENDIF LAZARUS}
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
    function  isPicFile(const fn: string; onlySupported: Boolean = false): Boolean;
    function  getSupPicExts: String;
  procedure  StretchPic(var bmp: TRnQBitmap; maxH, maxW: Integer); overload;



type
  TRnQAni = TRnQBitmap;

  function CreateAni(fn: String; var b: Boolean): TRnQBitmap; {$IFDEF HAS_INLINE} inline; {$ENDIF HAS_INLINE} overload;
  function CreateAni(fs: TStream; var b: Boolean): TRnQBitmap; {$IFDEF HAS_INLINE} inline; {$ENDIF HAS_INLINE} overload;
  function LoadAGifFromStream(var NonAnimated: boolean;
              Stream: TStream): TRnQBitmap;

  function  JPEGTurbo: Boolean;


const
  icon_size = 16;

implementation
 uses
   StrUtils,
   math, mmSystem,
   RnQ.Graphics.Utils,
 {$IF DEFINED(DELPHI9_UP) OR DEFINED(FPC)}
//   DwmApi,
   {$IFNDEF FPC}
   Consts,
   System.Net.Mime,
   wincodec,
   {$IFDEF UNICODE}
     AnsiStrings,
   {$ENDIF UNICODE}
   {$ENDIF FPC}
 {$ENDIF DELPHI9_UP}
//  {$IFNDEF RNQ_LITE}
   {$IFDEF USE_FLASH}
    ShockwaveFlashObjects_TLB,
//    FlashPlayerControl,
    ExtCtrls,
   {$ENDIF RNQ_FULL}
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

const
  CLSID_WICWEBPDecoder: TGUID = '{C747A836-4884-47B8-8544-002C41BD63D2}';
  CLSID_WICWebpDecoder2: TGUID = '{7693e886-51c9-4070-8419-9f70738ec8fa}';
  CLSID_WICHeifDecoder: TGUID = '{e9a4a80a-44fe-4de4-8971-7150b10a5199}';
  GUID_ContainerFormatHeif: TGUID = '{e1e62521-6787-405b-a339-500715b5763f}';

var
// supExts: array[0..9] of string = ('bmp', 'wbmp', 'wbm', 'ico','icon',
//                 'gif', 'png', 'jpg', 'jpe', 'jpeg');//, 'tif', 'dll')
 supExts: array[0..10] of string = ('bmp', 'wbmp', 'wbm', 'ico','icon',
                 'gif', 'png', 'jpg', 'jpe', 'jpeg', 'heic');//, 'tif', 'dll')
 isWEBPSupport: Boolean;
 isTIFFSupport: Boolean;
 isHEIFSupport: Boolean;
 fJPEGTurbo: Boolean;

var
  ThePalette: HPalette;       {the rainbow palette for 256 colors}

function  JPEGTurbo: Boolean;
begin
  Result := fJPEGTurbo;
end;

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
   {$IF DEFINED(DELPHI9_UP) OR DEFINED(FPC)}
    fBmp.SetSize(Width, Heigth);
   {$ELSE DELPHI9_dn}
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

{$IFDEF FPC}
procedure RaiseExceptions;
begin
  RaiseException(0, 0, 0, 0);
end;
{$ENDIF FPC}

procedure TRnQBitmap.SetWidth(W: Integer);
begin
  {$IFDEF FPC}
  RaiseException(0, 0, 0, 0);
  {$ELSE ~FPC}
  RaiseExceptions;
  {$ENDIF FPC}
end;

procedure TRnQBitmap.SetHeight(H: Integer);
begin
  RaiseExceptions;
end;

procedure TRnQBitmap.SaveToStream(Stream: TStream);
begin
  RaiseExceptions;
end;

{$IFDEF FPC}
procedure TRnQBitmap.LoadFromClipboardFormat(FormatID: TClipboardFormat);
begin
  RaiseExceptions;
end;

{$ELSE ~FPC}

procedure TRnQBitmap.LoadFromClipboardFormat(AFormat: Word; AData: THandle;
      APalette: HPALETTE);
begin
  RaiseExceptions;
end;

procedure TRnQBitmap.SaveToClipboardFormat(var AFormat: Word; var AData: THandle;
      var APalette: HPALETTE);
begin
  RaiseExceptions;
end;
{$ENDIF FPC}

function loadPic2(const fn: string; var bmp: TRnQBitmap): Boolean;
begin
  Result := loadPic(fn, bmp);
  if not Result then
    if Assigned(bmp) then
     begin
       bmp.Free;
       bmp := NIL;
     end;
end;

function loadPic(const fn: string; var bmp: TRnQBitmap; idx: Integer = 0): Boolean;
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
            {$IF DEFINED(DELPHI9_UP) OR DEFINED(FPC)}
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
    @C[0],
    SizeOf(C),
    nil);
  Result:=StrPas( C );
end;

procedure BeginPicsMassLoad;
begin
  init_libJPEGCS(TJpegImage.LibPathName);
end;

procedure EndPicsMassLoad;
begin
  UnInit_libJPEG;
end;

function loadPic(var str0: TStream; var bmp: TRnQBitmap; idx: Integer = 0;
                  ff: TPAFormat = PA_FORMAT_UNK; name: string = '';
                  PreserveStream: Boolean = false): Boolean;
var
  png: TPNGObject;
 {$IFNDEF FPC}
  WICpic: TWICImage;
 {$ENDIF FPC}
  NonAnimated: Boolean;
  vJpg: TJPEGImage;

  vBmp: TBitmap;
//  {$ENDIF RNQ_LITE}
  IcoStream: TIconStream;
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
           if fJPEGTurbo then
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
        {$IFNDEF FPC}
            if not Assigned(vBmp) then
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
                    bmp.f32Alpha := False;
                    bmp.fFormat := ff;

                    begin
                      if not Assigned(bmp.fBmp) then
                        bmp.fBmp := TBitmap.Create;
                      bmp.fBmp.PixelFormat := pf24bit;
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
        {$ELSE}
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
           LoadPictureStream2(MemStream, vBmp);
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
        {$ENDIF}
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
               bmp.fBmp := TBitmap.Create;
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
   {$IFNDEF FPC}
    PA_FORMAT_TIF, PA_FORMAT_WEBP, PA_FORMAT_HEIF, PA_FORMAT_HEIC:
      begin
        WICpic := TWICImage.Create;
        try
          try
            WICpic.LoadFromStream(str0);
           except
           //
          end;
          if not WICpic.empty then
          begin
            if not Assigned(bmp) then
              bmp := TRnQBitmap.Create
            else
              bmp.Clear;
            bmp.f32Alpha := True;
            bmp.fFormat := ff;

            begin
              if not Assigned(bmp.fBmp) then
                bmp.fBmp := TBitmap.Create;
              if bmp.f32Alpha then
                begin
                  bmp.fBmp.PixelFormat := pf32bit;
                  bmp.fBmp.AlphaFormat := afDefined;
                end
               else
                bmp.fBmp.PixelFormat := pf24bit;
              bmp.fBmp.Assign(WICpic);
              bmp.fWidth := bmp.fBmp.Width;
              bmp.fHeight := bmp.fBmp.Height;
            end;
            if WICpic.IsAnimating then
              begin
                bmp.FNumFrames := WICpic.FrameCount;
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
   {$ENDIF FPC}
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

procedure TRnQBitmap.SetTransparent(t: Boolean);
begin
  fBMP.Transparent := t;
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
            HBMP, LeftTop.X, LeftTop.Y, SrcBnd.Width, SrcBnd.Height, blend);
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

procedure TRnQBitmap.DrawBound(DC: HDC; DestR: TGPRect; Bound: Boolean = True; Scale: Boolean = True);
var
  Pt: TPoint;
  r2: TGPRect;
begin
  if ((DestR.Width) <> (fWidth))
     or ((DestR.Height) <> (fHeight)) then
   begin
    if not Bound then
      begin
       GetBrushOrgEx(dc, pt);
       SetStretchBltMode(dc, HALFTONE);
       SetBrushOrgEx(dc, pt.x, pt.y, @pt);
       Draw(DC, DestR, makerect(0, 0, fWidth, fHeight));
      end
     else
      begin
       r2 := DestRect(fWidth, fHeight, DestR.Width, DestR.Height, Scale);
       inc(r2.X, DestR.X);
       inc(r2.Y, DestR.Y);
       Draw(DC, r2, makerect(0, 0, fWidth, fHeight));
      end;
   end
  else
    Draw(DC, DestR, makerect(0, 0, fWidth, fHeight));
end;

procedure TRnQBitmap.StretchDraw(DC: HDC; DestR: TGPRect);
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

procedure TRnQBitmap.Draw(ACanvas: TCanvas; const Rect: TRect);
begin
  StretchDraw(ACanvas.Handle, MakeRect(Rect));
end;

procedure TRnQBitmap.DrawTransparent(ACanvas: TCanvas; const Rect: TRect; Opacity: Byte);
begin
  StretchDraw(ACanvas.Handle, MakeRect(Rect));
end;


function TRnQBitmap.GetEmpty: Boolean;
begin
  Result := fWidth = 0;
end;

function TRnQBitmap.GetPalette: HPALETTE;
begin
  Result := 0;
end;

function TRnQBitmap.GetTransparent: Boolean;
begin
  Result := htTransparent;
end;

function TRnQBitmap.CloneAll: TRnQBitmap;
begin
  Result := TRnQBitmap.Create;
  Result.f32Alpha := Self.f32Alpha;
  Result.fFormat := Self.fFormat;
  if Assigned(Self.fBmp) then
  begin
    Result.fBmp := TBitmap.Create;
    Result.fBmp.Assign(Self.fBmp);
  end;
  Result.fWidth := Self.fWidth;
  Result.fHeight := Self.fHeight;
  Result.fTransparentColor := Self.fTransparentColor;
  Result.fAnimated := Self.fAnimated;
  Result.htTransparent := Self.htTransparent;

  Result.fHI := CopyIcon(Self.fHI);
  Result.FNumFrames := Self.FNumFrames;
  Result.FCurrentFrame := Self.FCurrentFrame;
  Result.LastTime := Self.LastTime;
  Result.CurrentInterval := Self.CurrentInterval;
  Result.CurrentIteration := Self.CurrentIteration;
  Result.FNumIterations := Self.FNumIterations;
  Result.fFrames := Self.fFrames;
  Result.WasDisposal := Self.WasDisposal;

  if Assigned(Self.htMask) then
  begin
    Result.htMask := TBitmap.Create;
    Result.htMask.Assign(Self.htMask);
  end;
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
               {$IF DEFINED(DELPHI9_UP) OR DEFINED(FPC)}
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
 {$IF DEFINED(DELPHI9_UP) OR DEFINED(FPC)}
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
 {$IF DEFINED(DELPHI9_UP) OR DEFINED(FPC)}
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
     PB: PColor32;
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
 {$IFDEF FPC}
  AlphaBitmap := CreateDIBSection(0, Windows.PBITMAPINFO(@BitmapInfo)^, DIB_RGB_COLORS, Pointer(ImageBits), 0, 0);
 {$ELSE ~FPC}
  AlphaBitmap := CreateDIBSection(0, PBitmapInfo(@BitmapInfo)^, DIB_RGB_COLORS, Pointer(ImageBits), 0, 0);
 {$ENDIF FPC}
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


{$IFNDEF FPC}
procedure checkWICCodecs;
var
  FImagingFactory: IWICImagingFactory;
  ctInfo: IWICComponentInfo;
begin
  isTIFFSupport := false;
  isWEBPSupport := false;
  isHEIFSupport := false;

  if Succeeded( CoCreateInstance(CLSID_WICImagingFactory, nil, CLSCTX_INPROC_SERVER or
      CLSCTX_LOCAL_SERVER, IUnknown, FImagingFactory)) then
  begin
    isTIFFSupport := true;
    if Succeeded( FImagingFactory.CreateComponentInfo(CLSID_WICWEBPDecoder, ctInfo) ) then
      begin
       ctInfo := NIL;
       isWEBPSupport := true;
      end;

    if (not isWEBPSupport) and Succeeded( FImagingFactory.CreateComponentInfo(CLSID_WICWEBPDecoder2, ctInfo) ) then
      begin
       ctInfo := NIL;
       isWEBPSupport := true;
      end;

    if Succeeded( FImagingFactory.CreateComponentInfo(CLSID_WICHeifDecoder, ctInfo) ) then
      begin
       ctInfo := NIL;
       isHEIFSupport := true;
      end;
  end;
end;
{$ENDIF FPC}

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
//  if isHEIFSupport then
//    s := S + '*.heic; *.heif; ';

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
//        (isHEIFSupport and ((fn='heic')or (fn='heif'))) or
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

function isPicFile(const fn: string; onlySupported: Boolean = false): Boolean;
var
  ext: String;
 {$IFNDEF FPC}
  k: TMimeTypes.TKind;
 {$ENDIF ~FPC}
  t: String;
//  Extensions: TStringList;
//  i: Integer;
begin
//  result := true;
  result := false;
  ext := lowercase(SysUtils.ExtractFileExt(fn));
  {$IFNDEF FPC}
  if not onlySupported then
    begin
      TMimeTypes.Default.GetExtInfo(ext, t, k);
      Result := StartsText('image/', t);
    end
   else
  {$ENDIF ~FPC}
    begin
//      if Length(ext) > 3 then // dot + extension
      if (Length(ext) > 3) and StartsText('.', ext) then
      begin
        ext := Copy(fn, 2, Length(fn)-1);
        if (ext = 'bmp')or(ext = 'wbmp')or(ext = 'wbm')or(ext = 'gif')or
            (ext = 'ico')or(ext = 'icon')or(ext='png')or(ext='jpg')or(ext='jpeg')or
            (ext='dll')or
            (isWEBPSupport and (ext='webp'))or
            (isHEIFSupport and ((fn='heic')or (fn='heif'))) or
            (isTIFFSupport and ((ext='tiff')or (ext='tiff')))
        then
         begin
          result := true;
          exit;
         end
        else
         result := false;
      end;
    end;
end; // isSupportedPicFile

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
}
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


procedure DrawRbmp(DC: HDC; VAR bmp: TRnQBitmap; DestR, SrcR: TGPRect); OverLoad;
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
begin
  bmp.DrawBound(DC, DestR, Bound);
end;

procedure DrawRbmp(DC: HDC; VAR bmp: TRnQBitmap); OverLoad;
begin
  bmp.Draw(DC, 0, 0);
end;

procedure DrawRbmp(DC: HDC; VAR bmp: TRnQBitmap; X, Y: Integer); OverLoad;
begin
  bmp.Draw(DC, x, y);
end;

{procedure DrawRbmp(DC: HDC; VAR bmp: TRnQBitmap; DestRect: TRect; SrcX, SrcY, SrcW, SrcH: Integer; pEnabled: Boolean= True);
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
       //fBmp := AGif.GetStripBitmap(htMask);
       //htMask := AMask;
       //htTransparent := Assigned(htMask);

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

procedure CalcPalette(DC: HDC);
{calculate a rainbow palette, one with equally spaced colors}
const
  Values: array[0..5] of integer = (55, 115, 165, 205, 235, 255);
var
  LP: ^Windows.TLogPalette;
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

procedure initLibs(path: String = '');
var
  h: HMODULE;
  fn: UnicodeString;
begin
  fn := path + 'jpegturbo.dll';
  h := LoadLibraryW(PWideChar(fn));
  if h <> 0 then
  begin
    fJPEGTurbo := True;
    FreeLibrary(h);
    TJpegImage.LibPathName := fn;
  end else
    fJPEGTurbo := False;
end;


procedure InitPalete;
var
  DC: HDC;
  ColorBits: Byte;
begin
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
end;

initialization
  InitPalete;

 {$IFNDEF FPC}
  checkWICCodecs;
 {$ENDIF FPC}

 {$IFDEF RNQ}
  initLibs(modulesPath);
 {$ELSE ~RNQ}
  initLibs();
 {$ENDIF RNQ}

finalization
  if ThePalette <> 0 then
    DeleteObject(ThePalette);


end.
