{
This file is part of RaDIuM.
Under same license
}
unit RQThemes;
{$I ForRnQConfig.inc}
{$I NoRTTI.inc}

 { $DEFINE RQDEBUG2}
 { $DEFINE USE_32Aplha_Images}
 { $DEFINE USE_GDIPLUS}



{$WRITEABLECONST OFF} // Read-only typed constants

interface
uses
  Windows, Forms, SysUtils, Classes, Graphics,
  {$IFDEF USE_GDIPLUS}
    GDIPAPI,
    GDIPOBJ,
    RnQGraphics,
  {$ELSE}
    RnQGraphics32,
  {$ENDIF NOT USE_GDIPLUS}
  RDGlobal,
//  ImgList,
 {$IFDEF RNQ_FULL}
 {$IFNDEF andRQ}
  ExtCtrls, SyncObjs,
 {$ENDIF andRQ}
 {$ENDIF RNQ_FULL}

 {$IFDEF UNICODE}
   AnsiClasses,
 {$ENDIF UNICODE}
   Generics.Collections,

 {$IFDEF USE_ZIP}
//   kazip,
//   VCLUnZip,
//  SXZipUtils,
  RnQZip,
 {$ENDIF USE_ZIP}
 {$IFDEF USE_RAR}
//   ztvUnRar,
    UnRAR,
 {$ENDIF USE_RAR}
 {$IFDEF USE_7Z}
   SevenZip,
 {$ENDIF USE_7Z}
  RDFileUtil;

type
  TRnQAni = TRnQBitmap;

  TRnQThemedElement = (
    RQteDefault,
    RQteButton,
    RQteMenu,
    RQteTrayNotify,
    RQteFormIcon
  );

const
  TE2Str : array[TRnQThemedElement] of TPicName = ('', 'button.', 'menu.', 'tray.', 'formicon.');

type
  TPicLocation = (PL_pic, PL_icon, PL_int, PL_Ani, PL_Smile);
  TthemePropertyKind = (TP_font, TP_color, TP_file, TP_pic, TP_ico,
                        TP_string, TP_sound, TP_smile);

//  PRnQThemedElementDtls = ^TRnQThemedElementDtls;
  TRnQThemedElementDtls = record
    ThemeToken : Integer;
    Loc        : TPicLocation;
    picIdx     : Integer;
    picName    : TPicName;
    Element    : TRnQThemedElement;
    pEnabled   : Boolean;
  end;


type
  TSmlObj = class(TObject)
   public
    SmlStr : TStringList;
    Animated : Boolean;
    AniIdx : Integer;
  end;
  TSndObj = class(TObject)
   public
    str : String;
    s3m : TMemoryStream;
  end;
  TPicObj = class(TObject)
   public
//  TPicObj = record
    bmp : TRnQBitmap;
  {$IFDEF PRESERVE_BIG_FILE}
    pic: TMemoryStream;
  {$ENDIF PRESERVE_BIG_FILE}
//    bmp : TGPImage;
    ref : integer;
//    AniIdx : Integer;
  end;
 const
  FPT_CHARSET = 1 shl 0;
  FPT_SIZE    = 1 shl 1;
  FPT_COLOR   = 1 shl 2;
  FPT_STYLE   = 1 shl 3;
  FPT_NAME    = 1 shl 4;
//  FPT_UNK
{  TFontPropsTypes = (FPT_CHARSET, FPT_SIZE, FPT_COLOR, FPT_STYLE, FPT_NAME, FPT_UNK);
  TFontProps = record
    fpType : TFontPropsTypes;
    case TFontPropsTypes of
     FPT_CHARSET: (charset : Integer);
     FPT_SIZE: (size : Integer);
     FPT_COLOR: (color : Cardinal);
     FPT_STYLE: (style : set of TFontStyle);
     FPT_NAME: (name : PAnsiChar);
//    end;
  end;
}
 type
  TFontObj = class(TObject)
   protected
     flags : byte;
     charset : Integer;
     size  : Integer;
     color : Cardinal;
     style : set of TFontStyle;
     name  : PChar;
   public
    constructor Create;
    destructor Destroy; override;
    function Clone : TFontObj;
  end;
 {$IFDEF RNQ_FULL}
  TThemePic = class(TObject)
   public
     PicIDX: Integer;
//    Name : String;
     r : TGPRect;
     isWholeBig : Boolean;
//    constructor Create;
//    destructor Destroy; override;
//    procedure SetPicIDX(idx : Integer);
//    property PicIDX : Integer read FPicIDX write SetPicIDX;
//    Left, Top : Integer;
//    Width, Height : Integer;
//    bmp : TRnQBitmap;
  end;

  TAniPicParams = record
//    Name : String;
    IDX: Integer;
    SmileIDX : Integer;
//    Bounds: TRect;
    Bounds: TGPRect;
  {$IFNDEF USE_GDIPLUS}
    Color: TColor;
  {$ELSE USE_GDIPLUS}
    Color: Cardinal;
//    DC : HDC;
  {$ENDIF NOT_USE_GDIPLUS}
    Canvas : TCanvas;
    selected : Boolean;
//    bg : TRnQBitmap;
//    Count: Integer;
  end;

  TAniSmileParamsArray = array of TAniPicParams;
 {$ENDIF RNQ_FULL}

  TThemeSubClass = (tsc_all, tsc_pics, tsc_smiles, tsc_sounds);

//  Pthemeinfo=^Tthemeinfo;
  ToThemeinfo = Class(TObject)
   public
//  Tthemeinfo=record
     fn, subFile,title,desc,logo:string;
     Ver : byte; 
    end;
   aThemeInfo = array of ToThemeinfo;
  PTthemeProperty = ^TthemeProperty;
  TthemeProperty=record
//    section : String;
    section : AnsiString;
    name: TPicName;
    kind:TthemePropertyKind;
//    ptr:pointer;
    end;
  aTthemeProperty = array of TthemeProperty;

 {$IFDEF UNICODE}
  TObjList =  TAnsiStringList;
 {$ELSE ~UNICODE}
  TObjList =  TStringList;
 {$ENDIF UNICODE}
  TFontList = TDictionary<string, TFontObj>;

type
  TRQtheme = class
   private
    curToken : Integer;
    fDPI : Integer;
    FBigPics, FSmileBigPics : array of TPicObj;
    FThemePics,
    FSmilePics,
    FFonts2,
    FClr,
    FStr,
    FSmiles,
    FSounds,
    FIntPics : TObjList;
    FIntPicsIL : THandle;
 {$IFDEF RNQ_FULL}
    FAniSmls: TObjList;
//    FAniPics: TObjList;
//    FAniSmls: TStrListEx;
 {$IFDEF SMILES_ANI_ENGINE}
    FAniParamList: TAniSmileParamsArray;
    FAniDrawCnt: Integer;
    FAniTimer : TTimer;
    FdrawCS : TCriticalSection;
 {$ENDIF SMILES_ANI_ENGINE}
 {$ENDIF RNQ_FULL}
//    addProp : procedure (name: TPicName; kind:TthemePropertyKind; s: String);
    procedure addProp(name: TPicName; ts: TThemeSourcePath; kind: TthemePropertyKind; const s: String); overload;
//    procedure addProp(name: TPicName; ico: TIcon); overload;
//    procedure addProp(name: TPicName; fnt: TFont); overload;
    procedure addprop(const pName: TPicName; fnt: TFontObj); overload;
//    procedure addprop(name: TPicName; fnt: TFontProps); overload;
    procedure addProp(const name: TPicName; c: TColor); overload;
    procedure addprop(const name: TPicName; const SmlCaption: String;
                      Smile: TRnQBitmap; origSmile: TMemoryStream;
                      var pTP: TThemePic; bStretch: Boolean = false;
                      Ani: Boolean = false; AniIdx: Integer = -1); overload;
//    function  GetIco2(name : String; ico : TIcon) : Boolean;
  {$IFDEF USE_GDIPLUS}
    function  GetPic13(name: TPicName; var pic: TGPImage; AddPic: Boolean = True): boolean;
  {$ENDIF USE_GDIPLUS}
    function GetSmlCnt: Integer;
//    procedure GetPic(name : String; var pic : TRnQBitmap); overload;
 {$IFDEF SMILES_ANI_ENGINE}
    procedure TickAniTimer(Sender: TObject);
 {$ENDIF SMILES_ANI_ENGINE}
   public
    ThemePath: TThemePath;
//    MasterFN, subfn :string;
//    fs : TPathType;
//    fs : TThemeSourcePath;
//    path : String;
    title, desc: string;
    useTSC : TThemeSubClass;
//    supSmiles : Boolean;
 {$IFDEF RNQ_FULL}
    useAnimated : Boolean;
//    Anipicbg : Boolean;
    AnibgPic : TBitmap;
 {$ENDIF RNQ_FULL}
//    logo:TRnQBitmap;
    themelist2 : aThemeinfo;
    smileList  : aThemeinfo;
    soundList  : aThemeinfo;
    fBasePath  : String;
    procedure Debug;
    constructor Create;
    destructor Destroy; override;
    procedure Clear(pTSC: TThemeSubClass);
    procedure FreeResource;
    procedure load(fn0: string; subFile: String = ''; loadBase: Boolean = True;
                   subClass: TThemeSubClass = tsc_all);
    procedure loadThemeScript(const fn: String; const path: string); overload;
    procedure loadThemeScript(fn: String; ts: TThemeSourcePath); overload;
   private
    function  addBigPic(var pBmp: TRnQBitmap; const origPic: TMemoryStream): Integer;
    function  addBigSmile(var pBmp: TRnQBitmap; const origPic: TMemoryStream): Integer;
//    procedure addprop(name:string;hi: HICON; Internal : Boolean = false); overload;
    function  addProp(const name: TPicName; kind: TthemePropertyKind; var pBmp: TRnQBitmap) : Integer; overload;
    procedure addProp(const name: TPicName; kind: TthemePropertyKind; var pic: TThemePic); overload;
//    procedure delProp(name:String;kind:TthemePropertyKind);
 {$IFDEF RNQ_FULL}
    function addProp(name: AnsiString; pic: TRnQAni): Integer; overload;
//    function addProp(name:string; pic: TRnQBitmap) : Integer; overload;
 {$ENDIF RNQ_FULL}
   public
    procedure addHIco(const name: TPicName; hi: HICON; Internal: Boolean = false);
    function  AddPicResource(const name: TPicName; ResourceName: String; Internal: Boolean = false) : Boolean;
  {$IFNDEF USE_GDIPLUS}
    function  GetBrush(name: TPicName): HBRUSH;
  {$ENDIF NOT USE_GDIPLUS}
//    procedure initPic(name : String; var ThemeToken : Integer;
//               var picLoc : TPicLocation; var picIdx : Integer); overload;
    procedure initPic(var picElm: TRnQThemedElementDtls); overload;
    function  GetBigPic(const picName: TPicName; var mem: TMemoryStream): Boolean;
    function  GetBigSmile(const picName: TPicName; var mem: TMemoryStream): Boolean;
    function  GetPicSize(pTE: TRnQThemedElement; const name: TPicName; minSize: Integer = 0;
                             DPI: Integer = cDefaultDPI): Tsize; overload;
//    function  GetPicSize(name: String; var ThemeToken: Integer;
//        var picLoc: TPicLocation; var picIdx: Integer; minSize: Integer = 0): Tsize; overload;
    function  GetPicSize(var PicElm: TRnQThemedElementDtls; minSize: Integer = 0): Tsize; overload;
    function  GetPicOld(const PicName: TPicName; pic: TBitmap; AddPic: Boolean = True): Boolean;
    procedure GetPicOrigin(const name: TPicName; var OrigPic: TPicName; var rr: TGPRect);
//    function  GetIcoBad(name : String) : TIcon;
    function  GetString(const name: TPicName; isAdd: Boolean = True): String;
    function  GetSound(const name: TPicName): String;
    function  PlaySound(const name: TPicName): Boolean;
//    procedure ApplyFont(name : String; var fnt : TFont); overload;
    procedure ApplyFont(const pName: TPicName; fnt: TFont);
//    function  GetFontProp(name : String; Prop : TFontPropsTypes) : TFontProps;
    function  GetFontName(const pName : TPicName) : String;
    function  GetColor(const name: TPicName; pDefColor: TColor = clDefault): TColor;
    function  GetAColor(const name: TPicName; pDefColor: Integer = clDefault): Cardinal;
    function  GetTColor(const name: TPicName; pDefColor: Cardinal): Cardinal;
  {$IFDEF USE_GDIPLUS}
//    function  pic2ico2(picName:String; ico:Ticon) : Boolean;
  {$ENDIF USE_GDIPLUS}
    function  pic2ico(pTE: TRnQThemedElement; const picName: TPicName; ico: Ticon): Boolean;
    function  pic2hIcon(const picName: TPicName; var ico: HICON): Boolean;
//    function  drawPic(cnv: Tcanvas; x,y: integer; pic: TRnQBitmap): Tsize; overload;
    function  drawPic(DC: HDC; pX, pY: integer; const picName: TPicName; pEnabled: Boolean = true):Tsize; overload;
//    function  drawPic(DC: HDC; x,y: integer; picName: string; var ThemeToken: Integer;
//        var picLoc: TPicLocation; var picIdx: Integer; pEnabled: Boolean = true): Tsize; overload;
//    function  drawPic(DC: HDC; x,y:integer; var picElm : TRnQThemedElementDtls): Tsize; overload;
    function  drawPic(DC: HDC; pR: TGPRect; const picName: TPicName; pEnabled: Boolean = true):Tsize; overload;
    function  drawPic(DC: HDC; p: TPoint; var picElm: TRnQThemedElementDtls): Tsize; overload;
    function  drawPic(DC: HDC; pR: TGPRect; var picElm: TRnQThemedElementDtls): Tsize; overload;
    function  getPic(DC: HDC; p : TPoint; var picElm: TRnQThemedElementDtls; var is32Alpha : Boolean):Tsize; overload;
  {$IFDEF USE_GDIPLUS}
    function  drawPic(gr: TGPGraphics; x, y: integer; picName: string; pEnabled: Boolean = true): Tsize; overload;
    function  drawPic(gr: TGPGraphics; x, y: integer; picName: string; var ThemeToken: Integer;
        var picLoc: TPicLocation; var picIdx : Integer; pEnabled : Boolean = true): Tsize; overload;
    function  drawPic(gr: TGPGraphics; x, y: integer; picElm: Prnq): Tsize; overload;
  {$ENDIF USE_GDIPLUS}
//    function  GetPicRGN(picName:string; var ThemeToken : Integer;
//        var picLoc : TPicLocation; var picIdx : Integer):HRGN;
//    function drawPic(cnv:Tcanvas; x,y:integer; picName:String):Tsize; overload;
    function  GetSmileName(i: Integer): TPicName;
    function  GetSmileObj(i: Integer): TSmlObj;
    procedure checkAnimationTime;
 {$IFDEF SMILES_ANI_ENGINE}
    procedure  AddAniParam( PicIdx: Integer; Bounds: TGPRect;
                    Color: TColor; cnv, cnvSrc: TCanvas; Sel: Boolean = false);
    procedure  ClearAniParams;
    procedure  ClearAniMNUParams;
 {$ENDIF SMILES_ANI_ENGINE}

   {$IFDEF RNQ_FULL}
    function  GetAniPic(idx: integer): TRnQAni;
   {$ENDIF RNQ_FULL}

    Property SmilesCount : Integer read GetSmlCnt;
    Property token : Integer read curToken;
 {$IFNDEF RNQ_LITE}
    procedure getprops(var PropList : aTthemeProperty);
 {$ENDIF RNQ_LITE}

    procedure initThemeIcons;
  {$IFDEF USE_GDIPLUS}
    procedure drawTiled(gr:TGPGraphics; r: TGPRectF; const picName : TPicName); overload;
    procedure drawStratch(gr:TGPGraphics; r : TGPRectF; const picName : TPicName); overload;
    procedure drawStratch(gr:TGPGraphics; x, y, w, h : Integer; const picName : TPicName); overload;
  {$ENDIF USE_GDIPLUS}
    procedure drawTiled(canvas: Tcanvas; const picName : TPicName); overload;
    procedure drawTiled(dc: HDC; ClipRect: TRect; const picName : TPicName); overload;
    procedure Draw_wallpaper(DC: HDC; r: TRect); //{$IFDEF HAS_INLINE } inline; {$ENDIF HAS_INLINE}
    procedure refreshThemeList;
  //  procedure refreshSmilesList;
    procedure ClearThemelist;
  end;


//  function TE2Str(pTE : TRnQThemedElement) : TPicName;

const
//  theme_def_file = 'RnQ.theme.ini';

  PIC_EMPTY                       = TPicName('empty');
  PIC_HISTORY                     = TPicName('history');//51;
  PIC_WALLPAPER                   = TPicName('wallpaper');//69;
  PIC_CURRENT                     = TPicName('current');
//  PIC_WARNING                     = 'warning';
//  PIC_ERROR                       = 'error';

var
  theme  : TRQtheme;



implementation

 uses
  strUtils,
  math,
 {$IFDEF UNICODE}
   AnsiStrings,
 {$ENDIF UNICODE}
  RDUtils,
  RnQGlobal, RnQLangs,
  RQUtil,
 {$IFDEF RNQ}
   RQlog,
 {$ENDIF RNQ}
  RnQDialogs,
  CommCtrl, mmSystem, Types;
type
//  Tsection=(_null,_roaster,_tip,_pics,_icons,_history,_smiles,_sounds,_menu);
  TRQsection=(_null,_pics,_icons,_smiles,_sounds, _ico, _smile, _str, _desc, _fontfile);
const
//  sectionLabels:array [Tsection] of string=('','roaster','tip','pics','icons',
//    'history','smiles','sounds','menu');
  RQsectionLabels: array [TRQsection] of AnsiString=('','pics','icons','smiles',
    'sounds', 'rnqpics', 'rnqsmiles', 'strings', 'desc', 'font');

 {$IFDEF USE_7Z}
const
   SevenZipThemes : array[0..2] of string = ('.7z', '.7zip', '.rt7');
 {$ENDIF USE_7Z}
 {$IFDEF USE_RAR}
const
   RARThemes : array[0..1] of string = ('.rar', '.rtr');
 {$ENDIF USE_RAR}
 {$IFDEF USE_ZIP}
const
   ZipThemes : array[0..1] of string = ('.zip', '.rtz');
   ThemeInis : array[0..2] of string = ('theme.ini', 'smiles.ini', 'sounds.ini');
 {$ENDIF USE_ZIP}

 function MakeRectI(x, y, width, height: Integer): TGPRect; {$IFDEF HAS_INLINE}inline;{$ENDIF HAS_INLINE}
  begin
    Result.X      := x;
    Result.Y      := y;
    Result.Width  := width;
    Result.Height := height;
  end;


procedure InitThemePath(var ts : TThemeSourcePath; fn : String);
var
  fn_Ext : String;
begin
  fn_Ext := AnsiLowerCase(ExtractFileExt(fn));
 {$IFDEF USE_ZIP}
  if (fn_Ext = '.rtz') or
     (fn_Ext = '.zip')then
   begin
//    fs := pt_zip;
    ts.pathType := pt_zip;
    ts.path := '';
    ts.ArcFile := fn;
{      ts.zp := TZipFile.Create;
      try
        ts.zp.LoadFromFile(Fn);
       except
        ts.zp.Free;
        ts.zp := NIL;
      end;
     end;}
   end
  else
 {$ENDIF USE_ZIP}
 {$IFDEF USE_7Z}
     if (SevenZipThemes[0]= fn_Ext) or
        (SevenZipThemes[1]= fn_Ext) or
        (SevenZipThemes[2]= fn_Ext) then
     begin
//      fs := pt_7z;
      ts.pathType := pt_7z;
      ts.path := '';
      ts.ArcFile := fn;
     end
  else
 {$ENDIF USE_7Z}
 {$IFDEF USE_RAR}
     if (RARThemes[0]= fn_Ext) or
        (RARThemes[1]= fn_Ext) then
     begin
//      fs := pt_7z;
      ts.pathType := pt_rar;
      ts.path := '';
      ts.ArcFile := fn;
      ts.RarHnd := 0;
     end
  else
 {$ENDIF USE_7Z}
   begin
    ts.pathType := pt_path;
    ts.path := ExtractFileDir(fn);
    ts.path := includeTrailingPathDelimiter(ts.Path);
    ts.ArcFile := '';
   end;
end;

constructor TFontObj.Create;
begin
  inherited;
  flags := 0;
//  pr
  name := NIL;
//  if StrLen(name)>0 then
//     StrDispose(name);
//  SetLength(prop, 0);
end;
destructor TFontObj.destroy;
//var
//  I: Integer;
begin
  if name<>NIL then
     StrDispose(name);
  name := NIL;
//  for I := 0 to Length(prop) - 1 do
//   if Self.prop[i].fpType = FPT_NAME then
//    StrDispose(prop[i].name);
//  SetLength(prop, 0);
end;
function TFontObj.Clone : TFontObj;
begin
  Result := TFontObj.Create;
  Result.flags := flags;
    if FPT_CHARSET and flags > 0 then
     begin
       Result.flags := Result.flags or FPT_CHARSET;
       Result.charset := charset;
     end;
//     else
//       Result.flags := Result.flags and not FPT_CHARSET;
    if FPT_SIZE and flags > 0 then
     begin
       Result.flags := Result.flags or FPT_SIZE;
       Result.size := size;
     end;
//     else
//       Result.flags := Result.flags and not FPT_SIZE;

    if FPT_COLOR and flags > 0 then
     begin
       Result.flags := Result.flags or FPT_COLOR;
       Result.color := color;
     end;
//     else
//       Result.flags := Result.flags and not FPT_COLOR;

    if FPT_STYLE and flags > 0 then
     begin
       Result.flags := Result.flags or FPT_STYLE;
       Result.style := style;
     end;
//     else
//       Result.flags := Result.flags and not FPT_STYLE;

    if FPT_NAME and flags > 0 then
     begin
       Result.flags := Result.flags or FPT_NAME;
       StrDispose(Result.Name);
      {$IFDEF UNICODE}
//       Result.Name := AnsiStrAlloc(StrLen(name)+1);
       Result.Name := StrAlloc(StrLen(name)+1);
      {$ELSE nonUNICODE}
       Result.Name := StrAlloc(StrLen(name)+1);
      {$ENDIF UNICODE}
       StrCopy(Result.Name, name);
     end;
//     else
//      begin
//       TFontObj(FFonts2.Objects[i]).flags := TFontObj(FFonts2.Objects[i]).flags and not FPT_NAME;
//       StrDispose(TFontObj(FFonts2.Objects[i]).Name);
//      end;
end;

{constructor TThemePic.Create;
begin
  inherited;
  FPicIDX := -1;
end;
destructor TThemePic.Destroy;
begin
  inherited;
end;
procedure TThemePic.SetPicIDX(idx : Integer);
begin
//  if FPicIDX >=0 then
//   if Assigned(f) then
end;
}

procedure TRQtheme.debug;
begin
 {$IFDEF RQDEBUG2}
  Fpics.SaveToFile('FPics');
  FFonts.SaveToFile('FFonts');
//  FIcons.SaveToFile('FIcons');
  FIPNames.SaveToFile('FIcons');
  FStr.SaveToFile('FStr');
  FSmiles.SaveToFile('FSmiles');
  FClr.SaveToFile('FClr');
  FSounds.SaveToFile('FSounds');
  FAniSmls.SaveToFile('FaniSmiles');
 {$ENDIF}
end;

constructor TRQtheme.Create;
begin
  curToken := 101;
  fDPI := cdefaultDPI;
 {$IFDEF SMILES_ANI_ENGINE}
  FAniTimer := NIL;
  FdrawCS := TCriticalSection.Create;
 {$ENDIF SMILES_ANI_ENGINE}
  useTSC := tsc_all;
//  supSmiles := False;
//  FGPpics := TStringList.Create;
//  FBigPics   := TStringList.Create;

//  FSmileBigPics := TStringList.Create;

  FThemePics := TObjList.Create;
  FSmilePics := TObjList.Create;
  FIntPics   := TObjList.Create;
  FSmiles    := TObjList.Create;
  FStr       := TObjList.Create;
  FClr       := TObjList.Create;
  Fsounds    := TObjList.Create;
  FFonts2    := TObjList.Create;
//  FFonts    := TFontList.Create;

//  FIntPicsIL := ImageList_Create(icon_size, icon_size, ILC_COLOR32 or ILC_MASK, 0, 0);
  FIntPicsIL := ImageList_Create(GetSystemMetrics(SM_CXICON), GetSystemMetrics(SM_CYICON), ILC_COLOR32 or ILC_MASK, 0, 0);

//  FIconPics.BkColor := clNone;
  FSmiles.CaseSensitive := True;
//  FFonts := TStringList.Create;

 {$IFDEF RNQ_FULL}
  FAniSmls := TObjList.Create;
//  FAniSmls := NewStrListEx^;
  FSmiles.CaseSensitive := True;
  FAniSmls.CaseSensitive := True;
//  FSmiles.Sorted := True;
//  FAniSmls.Sorted := True;
 {$ENDIF RNQ_FULL}
  AnibgPic := NIL;
 
  initThemeIcons;
end;

destructor TRQtheme.Destroy;
begin
  Clear(tsc_all);
//  FGPpics.Free;
  SetLength(ThemePath.fn, 0);
  SetLength(ThemePath.subfn, 0);
//  SetLength(title, 0);
//  SetLength(desc, 0);
  if Assigned(AnibgPic) then
   AnibgPic.Free;
  AnibgPic := NIL;
 {$IFDEF SMILES_ANI_ENGINE}
  if Assigned(FAniTimer) then
   FreeAndNil(FAniTimer);
  FdrawCS.Free;
 {$ENDIF SMILES_ANI_ENGINE}

//  FBigPics.Free;
//  FSmileBigPics.Free;
  FSmilePics.Free;
  FThemePics.Free;
  FIntPics.Free;
  ImageList_Destroy(FIntPicsIL);

  FSmiles.Free;
//  FFonts.Free;
  FFonts2.Free;
  FStr.Free;
  FClr.Free;
  Fsounds.Free;


//  FIntIPs.Free;
 {$IFDEF RNQ_FULL}
  FAniSmls.Free;
 {$ENDIF RNQ_FULL}
end;


procedure TRQtheme.clear(pTSC : TThemeSubClass);
var
  i : Integer;
  po : TPicObj;
  so : TSndObj;
begin
{   WITH FIntPics do
   For i := 0 to Count-1 do
   begin
     TRnQBitmap(Objects[i]).Free;
   end;
   FIntPics.Clear;}
   // ¬нутренние картинки Ќ≈Ћ№«я очищать
//   ImageList_RemoveAll(FIntPicsIL);
//   FIntPics.Clear;
  if pTSC = tsc_all then
   begin
    SetLength(title, 0);
    SetLength(desc, 0);
   end;

  if pTSC in [tsc_all, tsc_pics] then
  begin
   for I := 0 to FThemePics.Count - 1 do
    begin
//      TThemePic(FThemePics.Objects[i]);
      TThemePic(FThemePics.Objects[i]).Free;
      FThemePics.Objects[i] := NIL;
    end;
   FThemePics.Clear;

 {$IFDEF DELPHI9_UP}
   for po in FBigPics do begin
 {$ELSE DELPHI_9_dn}
   for I := 0 to Length(FBigPics) - 1 do begin
    po := FBigPics[i];
 {$ENDIF DELPHI9_UP}
    if Assigned(po) then
    begin
      try
        if Assigned(po.bmp) then
          po.bmp.Free;
        po.bmp := NIL;
  {$IFDEF PRESERVE_BIG_FILE}
        if Assigned(po.pic) then
          po.pic.Free;
        po.pic := nil;
  {$ENDIF PRESERVE_BIG_FILE}
       except
      end;
      po.Free;
//      FBigPics.Objects[i].Free;
//      FBigPics.Objects[i] := NIL;
    end;
   end; 
//   FBigPics.Clear;
   SetLength(FBigPics, 0);


{   WITH FGPpics do
   For i := 0 to Count-1 do
   begin
     TRnQBitmap(Objects[i]).Free;
     Objects[i] := nil;
   end;
   FGPpics.Clear;
}
//   For i := 0 to FIcons.Count-1 do TIcon(FIcons.Objects[i]).Free;
//    FFonts.Clear;

    For i := 0 to FFonts2.Count-1 do
     begin
      TFontObj(FFonts2.Objects[i]).Free;
     end;
    FFonts2.Clear;

    For i := 0 to FStr.Count-1 do
      TStrObj(FStr.Objects[i]).Free;
    FStr.Clear;
  //  For i := 0 to FClr.Count-1 do FClr.Objects[i].Free;
    FClr.Clear;
  end;

//  if pTSC = tsc_smiles then
//   add

  if pTSC in [tsc_all, tsc_smiles] then
  begin
   For i := 0 to FSmiles.Count-1 do
    begin
//     try
//      TSmlObj(FSmiles.Objects[i]).Smile.Free;
//     except
//     end;
      TSmlObj(FSmiles.Objects[i]).SmlStr.Clear;
      TSmlObj(FSmiles.Objects[i]).SmlStr.Free;
      TSmlObj(FSmiles.Objects[i]).Free;
//      FSmiles.Objects[i] := NIL;
    end;
   FSmiles.Clear;
   {$IFDEF RNQ_FULL}
    For i := 0 to FAniSmls.Count-1 do
  //    TRnQBitmap(FAniPics.Objects[i]).Free;
      TRnQAni(FAniSmls.Objects[i]).Free;
  //    TRnQAni(Pointer(FAnismls.Objects[i])^).Free;
    FAniSmls.Clear;
   for I := 0 to FSmilePics.Count - 1 do
    begin
//      TThemePic(FSmilePics.Objects[i]).;
      TThemePic(FSmilePics.Objects[i]).Free;
      FSmilePics.Objects[i] := NIL;
    end;
   FSmilePics.Clear;
{   for I := 0 to FSmileBigPics.Count - 1 do
    begin
     with TPicObj(FSmileBigPics.Objects[i]) do
      try
        if Assigned(bmp) then
          bmp.Free;
        bmp := NIL;
       except
      end;
      TPicObj(FSmileBigPics.Objects[i]).Free;
      FSmileBigPics.Objects[i] := NIL;
    end;
   FSmileBigPics.Clear;
}
 {$IFDEF DELPHI9_UP}
   for po in FSmileBigPics do begin
 {$ELSE DELPHI_9_dn}
   for I := 0 to Length(FSmileBigPics) - 1 do begin
    po := FSmileBigPics[i];
 {$ENDIF DELPHI9_UP}
    if Assigned(po) then
    begin
      try
        if Assigned(po.bmp) then
          po.bmp.Free;
        po.bmp := NIL;
  {$IFDEF PRESERVE_BIG_FILE}
          if Assigned(po.pic) then
            po.pic.Free;
          po.pic := nil;
  {$ENDIF PRESERVE_BIG_FILE}
       except
      end;
      po.Free;
    end;
   end; 
//   FBigPics.Clear;
   SetLength(FSmileBigPics, 0);

    if Assigned(AnibgPic) then
    begin
  //    AnibgPic. := 0;
  //    AnibgPic.GetHeight := 0;
    end;
   {$ENDIF RNQ_FULL}
  end;

  if pTSC in [tsc_all, tsc_sounds] then
  begin
    if Fsounds.Count > 0 then
      SoundStop;
    For i := 0 to Fsounds.Count-1 do
     begin
      so := TSndObj(Fsounds.Objects[i]);
      Fsounds.Objects[i] := NIL;
      if Assigned(so.s3m) then
       FreeAndNil(so.s3m);
      so.Free;
     end;
    Fsounds.Clear;
  end;

//  FIntIPNames.Clear;
//  FIntIPs.Clear;

//  SetLength(smlList, 0);
//  smlList:= nil;
end;
procedure TRQtheme.FreeResource;
var
  I, k: Integer;
  po : TPicObj;
//var
//  i : Integer;
begin
 {$IFDEF DELPHI9_UP}
  for po in FBigPics do begin
 {$ELSE DELPHI_9_dn}
  for I := 0 to Length(FBigPics) - 1 do begin
    po := FBigPics[i];
 {$ENDIF DELPHI9_UP}
   if Assigned(po) then
    po.ref := 0;
  end;  
  for I := 0 to FThemePics.Count - 1 do
  begin
    with TThemePic(FThemePics.Objects[i]) do
     begin

       if (PicIDX < Length(FBigPics)) then
        begin
         inc(FBigPics[PicIDX].ref);
         if (r.X = 0)and(r.Y = 0) and
            (FBigPics[PicIDX].bmp.Width = r.Width)and
            (FBigPics[PicIDX].bmp.Height = r.Height)
         then
           isWholeBig := True; // ThemePic= BigPic
        end
       else
        isWholeBig := False;
     end;
  end;
 {$IFDEF DELPHI9_UP}
  for po in FBigPics do begin
 {$ELSE DELPHI_9_dn}
  for I := 0 to Length(FBigPics) - 1 do begin
    po := FBigPics[i];
 {$ENDIF DELPHI9_UP}
   if Assigned(po) then
   if po.ref = 0 then
      begin
        FreeAndNil(po.bmp);
  {$IFDEF PRESERVE_BIG_FILE}
        FreeAndNil(po.pic);
  {$ENDIF PRESERVE_BIG_FILE}
      end;
  end;

 {$IFDEF DELPHI9_UP}
  for po in FSmileBigPics do begin
 {$ELSE DELPHI_9_dn}
  for I := 0 to Length(FSmileBigPics) - 1 do begin
    po := FSmileBigPics[i];
 {$ENDIF DELPHI9_UP}
   if Assigned(po) then
    po.ref := 0;
  end;
  for I := 0 to FSmilePics.Count - 1 do
  begin
    k := TThemePic(FSmilePics.Objects[i]).PicIDX;
    if (k >=0)and (k < Length(FSmileBigPics)) then
      inc(FSmileBigPics[k].ref);
  end;
 {$IFDEF DELPHI9_UP}
  for po in FSmileBigPics do begin
 {$ELSE DELPHI_9_dn}
  for I := 0 to Length(FSmileBigPics) - 1 do begin
    po := FSmileBigPics[i];
 {$ENDIF DELPHI9_UP}
   if Assigned(po) then
   if po.ref = 0 then
      begin
        FreeAndNil(po.bmp);
  {$IFDEF PRESERVE_BIG_FILE}
        FreeAndNil(po.pic);
  {$ENDIF PRESERVE_BIG_FILE}
      end;
  end;
{  For i := 0 to Fpics.Count-1 do
   begin
     TRnQBitmap(FPics.Objects[i]).Dormant;
   end;
  For i := 0 to FSmiles.Count-1 do
   begin
     if TSmlObj(FSmiles.Objects[i]).Smile <> NIL then
       TSmlObj(FSmiles.Objects[i]).Smile.Dormant;
   end;
}
end;

procedure TRQtheme.load(fn0:string; subFile : String = ''; loadBase : Boolean = True; subClass : TThemeSubClass = tsc_all);
var
//  path : string;
//  f,
 {$IFDEF USE_ZIP}
//  baseArc : string;
  baseThemePath : TThemePath;
 {$ENDIF USE_ZIP}
  s, fn_full, fn_Only, fn_Ext : String;
  s1 : String;
  ts : TThemeSourcePath;
  I: Integer;
begin
  fn_Only := ExtractFileName(fn0);
  if fn_Only = '' then
    if not loadBase then
      Exit
     else
      begin
//       loggaEvt(getTranslation('Theme not selected'));
       msgDlg('Theme not selected', True, mtError);
//       Exit;
      end;
 s := ExtractFileDir(fn0);
 if s > '' then
   fn_full := fn0
  else
   fn_full := fBasePath +themesPath+ fn_Only;
 if (Length(fn_Only) > 0) and not FileExists(fn_full) then
  begin
//   loggaEvt(getTranslation('Can''t find theme %s',[fn]));
   msgDlg(getTranslation('Can''t find theme %s',[fn_full]), False, mtError);
//   self.fn := '';
   subFile := '';
   if subClass = tsc_all then
     begin
      ThemePath.fn := '';
//      ThemePath.subfn := '';
     end;
   exit;
  end;
 {$IFDEF RNQ_FULL}
  if subClass in [tsc_all, tsc_smiles] then
  begin
// UnInitGDIP;
// InitGDIP;
    useAnimated := False;
    if Assigned(AnibgPic) then
    begin
     AnibgPic.Free;
     AnibgPic := NIL;
  //   Anipicbg := False;
    end;
  end;  
 {$ENDIF RNQ_FULL}

  Clear(subClass);
  ts.ArcFile := '';
 {$IFDEF USE_ZIP}
     ts.zp := NIL;
 {$ENDIF USE_ZIP}
 {$IFDEF USE_7Z}
     ts.z7 := NIL;
 {$ENDIF USE_7Z}
 {$IFDEF USE_RAR}
   ts.RarHnd := 0;
 {$ENDIF USE_RAR}
 if subClass = tsc_all then
  ThemePath.fn := fn_Only;
 if loadBase then
 begin
 {$IFDEF USE_ZIP}
//  baseArc := mypath+themesPath+'RnQ.theme.rtz';
  baseThemePath.pathType := pt_zip;
  baseThemePath.fn := fBasePath+themesPath+'RnQ.theme.rtz';
 {$ENDIF USE_ZIP}
  if not FileExists(fn_full) then
 {$IFDEF USE_ZIP}
   if FileExists(baseThemePath.fn) then
    begin
     fn_full := baseThemePath.fn;
     fn_Only := 'RnQ.theme.rtz';
     subFile := defaultThemePrefix +defaultThemePostfix;
    end
   else
 {$ENDIF USE_ZIP}
    begin
     fn_full := fBasePath+themesPath+defaultThemePrefix +defaultThemePostfix;
     fn_Only := defaultThemePrefix +defaultThemePostfix;
     subFile := '';
    end;
 {$IFDEF USE_ZIP}
  if FileExists(baseThemePath.fn) then
    begin
//     fs := pt_zip;
     ts.pathType := pt_zip;
     ts.path := '';
//     ts.zp := TKAZip.Create(NIL);
     ts.zp := TZipFile.Create;
   //  ts.zp.ReadOnly := True;
//     ts.zp.Open(baseArc);
     ts.zp.LoadFromFile(baseThemePath.fn);
    end
   else
 {$ENDIF USE_ZIP}
    begin
//     fs := pt_path;
     ts.pathType := pt_path;
     ts.path := fBasePath+themesPath;
    end;

  loadThemeScript(defaultThemePrefix+ 'Base.' + defaultThemePostfix, ts);
 {$IFDEF USE_ZIP}
  if (fn_full <> baseThemePath.fn)and Assigned(ts.zp) then
    FreeAndNil(ts.zp);
 {$ENDIF USE_ZIP}
 end;
 fn_Ext := ExtractFileExt(fn_Only);
 InitThemePath(ts, fn_full);
 case ts.pathType of
   pt_path:
      begin
        subFile := fn_Only;
    //    subfn := '';
        if subClass = tsc_all then
         begin
    //      ThemePath.fn := '';
          ThemePath.subfn := '';
         end;
     {$IFDEF USE_ZIP}
        FreeAndNil(ts.zp);
     {$ENDIF USE_ZIP}
     {$IFDEF USE_7Z}
//        FreeAndNil(ts.7z);
        ts.z7 := NIL;
     {$ENDIF USE_7Z}
       end;

     {$IFDEF USE_ZIP}
   pt_zip:
       begin
        if subClass = tsc_all then
          ThemePath.fn:= fn_Only;
        if (fn_full <> baseThemePath.fn)or not Assigned(ts.zp) then
         begin
    //      ts.zp := TKAZip.Create(NIL);
          ts.zp := TZipFile.Create;
      //  ts.zp.ReadOnly := True;
    //      ts.zp.Open(Fn);
          try
            ts.zp.LoadFromFile(fn_full);
           except
            ts.zp.Free;
            ts.zp := NIL;
          end; 
         end;
        if subFile = '' then
         begin
           for I := 0 to ts.zp.Count - 1 do
            begin
              s1 := ts.zp.Name[i];
              if (LastDelimiter('\/:', s1) <= 0)and
                  RnQEndsText('theme.ini', s1)  then
               begin
                 subFile := s1;
                 break;
               end;
            end;
         end;
    //    else
    //     Self.fn := subFile;
        if subClass = tsc_all then
          ThemePath.subfn := subFile;
       end;
   {$ENDIF USE_ZIP}
 {$IFDEF USE_7Z}
   pt_7z:
       begin
        if subClass = tsc_all then
          ThemePath.fn:= fn_only;

        try
//           ts.z7 := TSevenZip.Create(NIL);
           ts.z7 := CreateInArchive(CLSID_CFormat7z);
          except
             ts.z7 := NIL;
        end;

           if Assigned(ts.z7) then
            begin
//             ts.z7.SZFileName := Fn;
//             ts.z7.List;
             ts.z7.OpenFile(fn_full);
              if subFile = '' then
               begin
          {       for I := 0 to ts.zp.Entries.Count - 1 do
                  if (LastDelimiter('\/:', ts.zp.Entries.Items[i].FileName) <= 0)and
                     (ExtractFileExt(ts.zp.Entries.Items[i].FileName) = '.ini')  then
                   subFile := ts.zp.Entries.Items[i].FileName;}
//                 for I := 0 to ts.z7.Files.Count - 1 do
                 for I := 0 to ts.z7.NumberOfItems - 1 do
                  begin
//                   s1 := ts.z7.Files.WStrings[i]
                   s1 := ts.z7.getItemPath(i);
                   if (LastDelimiter('\/:', s1) <= 0)and
                       RnQEndsText('theme.ini', s1)  then
                    begin
                     subFile := s1;
                     break;
                    end;
                  end;
               end;
//              ts.z7.Close;
               if subClass = tsc_all then
                 ThemePath.subfn := subFile;
            end
           else
            begin
             loggaEvt('Can''t load theme '+fn_full + '; Need 7za.dll or 7zxa.dll!');
             subFile := '';
             if subClass = tsc_all then
              begin
               ThemePath.fn := '';
               ThemePath.subfn := '';
              end;
            end;
       end;
 {$ENDIF USE_7Z}
 {$IFDEF USE_RAR}
   pt_rar:
       begin
        if subClass = tsc_all then
          ThemePath.fn:= fn_Only;

        if subFile = '' then
         begin
           ts.ArcFile := '';
{           for I := 0 to ts.zp.Count - 1 do
            if (LastDelimiter('\/:', ts.zp.Name[i]) <= 0)and
                RnQEndsText('theme.ini', ts.zp.Name[i])  then
             subFile := ts.zp.Name[i];}
             if subClass = tsc_all then
              begin
               ThemePath.fn := '';
               ThemePath.subfn := '';
              end;
         end;
        if subClass = tsc_all then
          ThemePath.subfn := subFile;
       end;
 {$ENDIF USE_RAR}
 end;

 if loadBase and not FileExists(fn_full) then
  begin
//   loggaEvt(getTranslation('Can''t find theme %s',[fn]));
   msgDlg(getTranslation('Can''t find theme %s',[fn_full]), False, mtError);
//   self.fn := '';
   subFile := '';
   if subClass = tsc_all then
     begin
      ThemePath.fn := '';
//      ThemePath.subfn := '';
     end;
  end;

 {$IFDEF USE_RAR}
 if (ts.pathType = pt_rar) and not IsRARDLLLoaded then
   LoadRarLibrary;
 {$ENDIF USE_RAR}

 loadThemeScript(subFile, ts);

 {$IFDEF USE_RAR}
 if (ts.pathType = pt_rar) then
  begin
   if ts.RarHnd > 0 then
     RARCloseArchive(ts.RarHnd);
   ts.RarHnd := 0;
   if IsRARDLLLoaded then
     UnLoadRarLibrary;
  end;
 {$ENDIF USE_RAR}

 {$IFDEF USE_ZIP}
 FreeAndNil(ts.zp);
 {$ENDIF USE_ZIP}
 {$IFDEF USE_7Z}
// FreeAndNil(ts.z7);
  ts.z7 := NIL;
 {$ENDIF USE_7Z}
 FThemePics.Sorted := True;
// FGPpics.Sorted := True;
// FIntPics.Sorted := True;
 FreeResource;

 {$IFDEF SMILES_ANI_ENGINE}
 if subClass in [tsc_all, tsc_smiles] then
 begin
   if useAnimated then
   begin
    if not Assigned(FAniTimer) then
      FAniTimer:= TTimer.Create(nil);
    FAniTimer.Enabled := false;
    FAniTimer.Interval:= 40;
    //timer.Enabled:= UseAnime;
    FAniTimer.OnTimer:= TickAniTimer;
   end
   else
    if (FAniTimer <> NIL) and Assigned(FAniTimer) then
      FreeAndNil(FAniTimer);
 end;
 {$ENDIF SMILES_ANI_ENGINE}
// msgDlg(IntToStr(GDIPlus.Version), mtInformation);

// if useAnimated then
//   CreateWaitableTimer()
 inc(curToken);
end; // loadTheme


  {$IFDEF USE_GDIPLUS}
function TRQtheme.GetPic13(const name : TPicName; var pic: TGPImage; AddPic : Boolean = True) : Boolean;
var
  i : Integer;
//  bmp : TRnQBitmap;
//  hb : HBITMAP;
begin
  result := false;
  i := FThemePics.IndexOf(AnsiLowerCase(name));
  if i >= 0 then
   begin
    if Assigned(pic) then
      pic.Free;
    Pic := NIL;  
//     if True then
//    if FBigPics.Objects[TThemePic(FThemePics.Objects[i]).PicIDX] is TPicObj then
    if Assigned(FBigPics.Objects[TThemePic(FThemePics.Objects[i]).PicIDX]) then
       pic := TPicObj(FBigPics.Objects[TThemePic(FThemePics.Objects[i]).PicIDX]).bmp;
    if Assigned(pic) then
      result := true
   end
{  else
      begin
       i := FIntPics.IndexOf(AnsiLowerCase(name));
       if i >= 0 then
         begin
          if Assigned(pic) then
           pic.Free;
          pic := TRnQBitmap(FIntPics.Objects[i]);
          result := true;
         end
       else
        if AddPic then
        begin
          bmp := TRnQBitmap.Create(icon_size, icon_size);
          if picDrawFirstLtr then
           begin
//            bmp.Canvas.Pen.Color := clBlue;
//            bmp.Canvas.Font.Color := clBlue;
//            bmp.Canvas.TextOut((bmp.Width - 4) div 2, (bmp.Height - 12) div 2 , name[1]);
           end;
//          pic.Height := 0;
//          pic.Width  := 0;
//          pic.Width := FIconPics.Width;
//          pic.Height := FIconPics.Height;
          addProp(name, TP_pic, bmp);
          pic := bmp;
//          pic.Assign(bmp);
          bmp.Free;
        end;
    end; }
end;
  {$ENDIF USE_GDIPLUS}

{$IFDEF USE_GDIPLUS}
function TRQtheme.GetPicOld(const name: TPicName; pic: TBitmap; AddPic: Boolean = True): Boolean;
var
//  i : Integer;
//  bmp : TRnQBitmap;
//  hb : HBITMAP;
  gr : TGPGraphics;
  tt, idx : Integer;
  pl : TPicLocation;
begin
  result := false;
  with GetPicSize(name, tt, pl, idx) do
  if (cx > 0) and (cy > 0) then
   begin
    {$IFDEF DELPHI9_UP}
    pic.SetSize(cx,cy);
    {$ELSE DELPHI9_UP}
     pic.Width  := cx;
     pic.Height := cy;
    {$ENDIF DELPHI9_UP}
    gr := TGPGraphics.Create(pic.Canvas.Handle);
    gr.Clear(aclWhite);
    gr.Free;
    drawPic(pic.Canvas.Handle, 0, 0, name, tt, pl, idx);
    result := True;
   end
  else
   begin
    {$IFDEF DELPHI9_UP}
    pic.SetSize(0,0);
    {$ELSE DELPHI9_UP}
     pic.Width  := 0;
     pic.Height := 0;
    {$ENDIF DELPHI9_UP}
   end;
{

  i := FGPpics.IndexOf(AnsiLowerCase(name));
  if i >= 0 then
   begin
    TRnQBitmap(FGPpics.Objects[i]).GetHBITMAP(0, hb);
    pic.SetSize(TRnQBitmap(FGPpics.Objects[i]).GetWidth,
                TRnQBitmap(FGPpics.Objects[i]).GetHeight);

//    pic.Handle := hb;
//    pic := TRnQBitmap(Fgppics.Objects[i]).g;
//    pic.Handle := hb;
    result := true;
   end
  else
      begin
       i := FIntPics.IndexOf(AnsiLowerCase(name));
       if i >= 0 then
         begin
          TRnQBitmap(FIntPics.Objects[i]).GetHBITMAP(0, hb);
          pic.Handle := hb;
//          pic := TRnQBitmap(FIntPics.Objects[i]);
          result := true;
         end
//       else
      end; }
end;
 {$ELSE NOT USE_GDIPLUS}
function TRQtheme.GetPicOld(const PicName: TPicName; pic: TBitmap; AddPic: Boolean = True): Boolean;
var
  i : Integer;
//  bmp : TRnQBitmap;
//  hb : HBITMAP;
//  gr : TGPGraphics;
//  tt, idx : Integer;
//  pl : TPicLocation;
  s : TPicName;
  tbmp : TRnQBitmap;
  hi   : HICON;
  ico  : TIcon;
begin
  result := false;
//  s := AnsiLowerCase(PicName);
  s := PicName;
(*  with GetPicSize(name, tt, pl, idx) do
  if (cx > 0) and (cy > 0) then
   begin
    {$IFDEF DELPHI9_UP}
    pic.SetSize(cx,cy);
    {$ELSE DELPHI9_UP}
     pic.Width  := cx;
     pic.Height := cy;
    {$ENDIF DELPHI9_UP}
    pic.Assign();
    pic.Canvas.Brush.Color := clWhite;
    pic.Canvas.FillRect(pic.Canvas.ClipRect);
    drawPic(pic.Canvas.Handle, 0, 0, name, tt, pl, idx);
    result := True;
   end
  else
   begin
    {$IFDEF DELPHI9_UP}
    pic.SetSize(0,0);
    {$ELSE DELPHI9_UP}
     pic.Width  := 0;
     pic.Height := 0;
    {$ENDIF DELPHI9_UP}
   end;
*)

  i := FThemePics.IndexOf(s);
  if i >= 0 then
   begin
    with TThemePic(FThemePics.Objects[i]) do
     if isWholeBig then
       pic.Assign(FBigPics[PicIDX].bmp.fBmp)
      else
       begin
        tbmp := FBigPics[PicIDX].bmp.Clone(r);
        pic.Assign(tbmp.fBmp);
        tbmp.Free;
       end;
//    TThemePic(FThemePics.Objects[i]).
//    TRnQBitmap(FGPpics.Objects[i]).GetHBITMAP(0, hb);
//    pic.SetSize(TRnQBitmap(FGPpics.Objects[i]).GetWidth,
//                TRnQBitmap(FGPpics.Objects[i]).GetHeight);

//    pic.Handle := hb;
//    pic := TRnQBitmap(Fgppics.Objects[i]).g;
//    pic.Handle := hb;
    result := true;
   end
  else
      begin
       i := FIntPics.IndexOf(s);
       if i >= 0 then
         begin
          hi := ImageList_ExtractIcon(0, FIntPicsIL, i);
          ico := TIcon.Create;
          ico.Handle := hi;
          pic.Width := ico.Width;
          pic.Height := ico.Height;
          pic.Canvas.Draw(0, 0, ico);
//          pic.Assign(ico); //CopyImage(hi, IMAGE_ICON, 0, 0, LR_CREATEDIBSECTION)
          DestroyIcon(hi);
          ico.Free;
//          ico2bmp();
//          TRnQBitmap(FIntPics.Objects[i]).GetHBITMAP(0, hb);
//          pic.Handle := hb;
//          pic := TRnQBitmap(FIntPics.Objects[i]);
          result := true;
         end
//       else
      end; 
end;
 {$ENDIF USE_GDIPLUS}

  {$IFNDEF USE_GDIPLUS}
function TRQtheme.GetBrush(name : TPicName) : HBRUSH;
var
  i : Integer;
  bmp : TRnQBitmap;
begin
  result := 0;
//  i := Fpics.IndexOf(LowerCase(name));
  i := FThemePics.IndexOf(AnsiLowerCase(name));
  if i >= 0 then
   begin
    with TThemePic(FThemePics.Objects[i]) do
//       bmp := TPicObj(FBigPics.Objects[PicIDX]).bmp.Clone(r);
       bmp := FBigPics[PicIDX].bmp.Clone(r);
//               Clone(TThemePic(FThemePics.Objects[i]).Left, TThemePic(FThemePics.Objects[i]).Top,
//                  TThemePic(FThemePics.Objects[i]).Width, TThemePic(FThemePics.Objects[i]).Height);
    result := CreatePatternBrush(bmp.fBmp.Handle);
    bmp.Free;
//    result := CreatePatternBrush(TRnQBitmap(Fpics.Objects[i]).Handle);
//    result := true;
   end
end;
  {$ENDIF NOT USE_GDIPLUS}

function TRQtheme.GetBigPic(const picName: TPicName; var mem: TMemoryStream): Boolean;
var
  i: integer;
  s: TPicName;
begin
  if picName = '' then
  begin
    Result := false;
    Exit;
  end;

  Result := false;
 {$IFDEF PRESERVE_BIG_FILE}
  i := -1;
  i := FThemePics.IndexOf(AnsiLowerCase(picName));

  if i >= 0 then
  begin
    with TThemePic(FThemePics.Objects[i]) do
    if Assigned(FBigPics[picIdx].pic) then
    begin
      mem := TMemoryStream.Create;
      FBigPics[picIdx].pic.Seek(0, soFromBeginning);
      mem.LoadFromStream(FBigPics[picIdx].pic);
      Result := True;
    end
  end;
 {$ENDIF PRESERVE_BIG_FILE}
end;

function TRQtheme.GetBigSmile(const picName: TPicName; var mem: TMemoryStream): Boolean;
var
  i: integer;
  s: TPicName;
begin
  if picName = '' then
  begin
    Result := false;
    Exit;
  end;

  Result := false;
 {$IFDEF PRESERVE_BIG_FILE}

  if TryStrToInt(picName, i) then
  begin
    with TThemePic(FSmilePics.Objects[i]) do
    if Assigned(FSmileBigPics[picIdx].pic) then
    begin
      mem := TMemoryStream.Create;
      mem.LoadFromStream(FSmileBigPics[picIdx].pic);
      Result := True;
    end;
  end;
 {$ENDIF PRESERVE_BIG_FILE}
end;

function TRQtheme.GetPicSize(pTE: TRnQThemedElement; const name: TPicName; minSize: Integer = 0;
                             DPI: Integer = cDefaultDPI): Tsize;
var
  i: Integer;
  s, s1: TPicName;
begin
  s1 := AnsiLowerCase(name);
  s := TE2Str[pTE] + s1;
  i := FThemePics.IndexOf(s);
  if i < 0 then
   i := FThemePics.IndexOf(s1);
  if i >= 0 then
   with TThemePic(FThemePics.Objects[i]) do
   begin
//    result.cx := r.width;
//    result.cy := r.Height;
    result := Tsize(r.size);
   end
  else
    begin
      i := FIntPics.IndexOf(s);
      if i < 0 then
       i := FIntPics.IndexOf(s1);
      if i >= 0 then
       begin
//         result.cx := icon_size;
//         result.cy := icon_size;
         ImageList_GetIconSize(FIntPicsIL, result.cx, result.cy);
//         result.cx := TRnQBitmap(FIntPics.Objects[i]).GetWidth;
//         result.cy := TRnQBitmap(FIntPics.Objects[i]).GetHeight;
       end
       else
        begin
        {$IFDEF RNQ_FULL}
//         i := FAniSmls.IndexOf(s);
//         if i < 0 then
          i := FAniSmls.IndexOf(name);
         if i >= 0 then
          with TRnQAni(FAniSmls.Objects[i]) do
          begin
            Result.cx := Width;
            Result.cy := Height;
          end
         else
        {$ENDIF RNQ_FULL}
          begin
          {$IFDEF RNQ_FULL}
//           i := FSmilePics.IndexOf(s);
//           if i < 0 then
            i := FSmilePics.IndexOf(name);
           if i >= 0 then
            with TThemePic(FSmilePics.Objects[i]) do
            begin
//              Result.cx := r.Width;
//              Result.cy := r.Height;
              result := Tsize(r.size);
            end
           else
          {$ENDIF RNQ_FULL}
            begin
              Result.cx := minSize;
              Result.cy := minSize;
            end;
          end;
        end;
    end;
  if dpi <> fDPI then
   begin
     result.cx := MulDiv(result.cx, dpi, fDPI);
     result.cy := MulDiv(result.cy, dpi, fDPI);
   end;
end;

procedure TRQtheme.GetPicOrigin(const name: TPicName; var OrigPic: TPicName; var rr: TGPRect);
const
  minSize : integer = 0;
var
  i, j: integer;
//  s: TPicName;
//  i: Integer;
  s, s1: TPicName;
begin
  OrigPic := name;
  s1 := AnsiLowerCase(name);

  i := FThemePics.IndexOf(s1);

  try
    if i >= 0 then
      begin
        for j := 0 to FThemePics.Count - 1 do
        if TThemePic(FThemePics.Objects[j]).picIdx = TThemePic(FThemePics.Objects[i]).picIdx then
        begin
          if not (s1 = FThemePics.Strings[j]) then
          begin
            OrigPic := FThemePics.Strings[j];
            Exit;
          end else
            Break;
        end;
      end
     else
      begin
        i := FSmilePics.IndexOf(s1);
        if i >= 0 then
          for j := 0 to FSmilePics.Count - 1 do
          if TThemePic(FSmilePics.Objects[j]).picIdx = TThemePic(FSmilePics.Objects[i]).picIdx then
          begin
            if not (s1 = FSmilePics.Strings[j]) then
            begin
              OrigPic := FSmilePics.Strings[j];
              Exit;
            end else
              Break;
          end;
      end;
  finally
    i := FThemePics.IndexOf(s1);

  if i >= 0 then
  with TThemePic(FThemePics.Objects[i]) do
    rr := r
  else
  begin
    i := FIntPics.IndexOf(s);
    if i < 0 then
      i := FIntPics.IndexOf(s1);
    if i >= 0 then
    begin
      rr.X := 0;
      rr.Y := 0;
      rr.Width := icon_size;
      rr.Height := icon_size;
    end
      else
    begin
{$IFDEF RNQ_FULL}
      // i := FAniSmls.IndexOf(s);
      // if i < 0 then
      i := FAniSmls.IndexOf(name);
      if i >= 0 then
      with TRnQAni(FAniSmls.Objects[i]) do
      begin
        rr.X := 0;
        rr.Y := 0;
        rr.Width := Width;
        rr.Height := Height;
      end
        else
{$ENDIF RNQ_FULL}
      begin
{$IFDEF RNQ_FULL}
        // i := FSmilePics.IndexOf(s);
        // if i < 0 then
        i := FSmilePics.IndexOf(name);
        if i >= 0 then
        with TThemePic(FSmilePics.Objects[i]) do
          rr := r
        else
{$ENDIF RNQ_FULL}
        begin
          rr.X := 0;
          rr.Y := 0;
          rr.Width := minSize;
          rr.Height := minSize;
        end;
      end;
    end;
  end

  end;
end;

function TRQtheme.GetPicSize(var PicElm : TRnQThemedElementDtls; minSize : Integer = 0):Tsize;
//var
//  i : Integer;
begin
   initPic(PicElm);

  if PicElm.picIdx < 0 then
          begin
            Result.cx := minSize;
            Result.cy := minSize;
            exit;
          end;
  case PicElm.Loc of
   PL_pic: with TThemePic(FThemePics.Objects[PicElm.picIdx]) do
    begin
//      result.cx := r.Width;
//      result.cy := r.Height;
      result := Tsize(r.size);
    end;
   PL_int:
        begin
//         result.cx := icon_size;
//         result.cy := icon_size;
         ImageList_GetIconSize(FIntPicsIL, result.cx, result.cy);
//         result.cx := TRnQBitmap(FIntPics.Objects[picIdx]).GetWidth;
//         result.cy := TRnQBitmap(FIntPics.Objects[picIdx]).GetHeight;
        end;
   PL_Ani: with TRnQAni(FAniSmls.Objects[PicElm.picIdx]) do
          begin
            Result.cx := Width;
            Result.cy := Height;
          end;
   PL_Smile: with TThemePic(FSmilePics.Objects[PicElm.picIdx]) do
        begin
//          result.cx := r.Width;
//          result.cy := r.Height;
          result := Tsize(r.size);
        end;
   else
          begin
            Result.cx := minSize;
            Result.cy := minSize;
          end;
  end
end;

procedure TRQtheme.initPic(var picElm : TRnQThemedElementDtls);
var
  i : Integer;
  s : TPicName;
begin
  if picElm.ThemeToken = curToken then
   begin
    if picElm.picIdx = -1 then
      Exit;
    case picElm.Loc of
      PL_pic: i := FThemePics.Count;
      PL_int: i := FIntPics.Count;
      PL_Ani: i := FAniSmls.Count;
      PL_Smile: i := FSmilePics.Count;
     else
      i := -1;
    end;
    if (picElm.picIdx < 0)or(picElm.picIdx > i) then
      picElm.picIdx := -1;
    if picElm.picIdx = -1 then
      picElm.ThemeToken := -1;
    Exit;
   end;

  picElm.ThemeToken := curToken;
  if picElm.picName ='' then
   begin
     picElm.picIdx := -1;
     Exit;
   end;
  s := AnsiLowerCase(picElm.picName);
  picElm.picName := s;
  if not (picElm.Element in [RQteDefault..RQteFormIcon]) then
    picElm.Element := RQteDefault;
  s := te2Str[picElm.Element] + picElm.picName;
  i := FThemePics.IndexOf(s);
  if i <0 then
   i := FThemePics.IndexOf(picElm.picName);
  if i >= 0 then
   begin
    picElm.Loc := PL_pic;
    picElm.picIdx := i;
   end
  else
    begin
      begin
       i := FIntPics.IndexOf(s);
       if i < 0 then
        i := FIntPics.IndexOf(picElm.picName);
       if i >= 0 then
        begin
         picElm.Loc := PL_int;
         picElm.picIdx := i;
        end
       else
        begin
         i := FSmilePics.IndexOf(picElm.picName);
         if i >= 0 then
           begin
            picElm.Loc := PL_Smile;
            picElm.picIdx := i;
           end
         else
          begin
          {$IFDEF RNQ_FULL}
//           i := FAniSmls.IndexOf(s);
//           if i < 0 then
            i := FAniSmls.IndexOf(picElm.picName);
           if i >= 0 then
            begin
              picElm.Loc := PL_Ani;
              picElm.picIdx := i;
            end
           else
          {$ENDIF RNQ_FULL}
            begin
    //          picLoc := 0;
              picElm.picIdx := -1;
            end;
          end;
        end
      end;
    end
end;

function TRQtheme.GetSmileName(i: Integer): TPicName;
begin
  if i >= 0 then
    result := FSmiles.Strings[i]
  else
    result := '';
end;
function TRQtheme.GetSmileObj(i: Integer): TSmlObj;
begin
  if i >= 0 then
   if Assigned(FSmiles.Objects[i]) then
    result := TSmlObj(FSmiles.Objects[i])
   else
    result := NIL
  else
    result := NIL;
end;

function TRQtheme.GetSmlCnt : Integer;
begin
  result := FSmiles.Count;
end;

function TRQtheme.GetString(const name: TPicName; isAdd: Boolean = True): String;
var
  i : Integer;
  ts : TThemeSourcePath;
begin
 i := Fstr.IndexOf(AnsiLowerCase(name));
 if i >= 0 then
   result := TStrObj(Fstr.Objects[i]).str
 else
   begin
    result := '';
    if isAdd then
     begin
      ts.pathType := pt_path;
      addprop(name, ts, TP_string, '');
     end;
   end;
end;

function TRQtheme.GetSound(const name: TPicName): String;
var
  i : Integer;
begin
  i := Fsounds.IndexOf(AnsiLowerCase(name));
  if i >= 0 then
    result := TSndObj(Fsounds.Objects[i]).str
  else
    result := '';
end;
function TRQtheme.PlaySound(const name : TPicName): Boolean;
var
  i : Integer;
//  s : String;
begin
  result := True;
  i := Fsounds.IndexOf(AnsiLowerCase(name));
  if i >= 0 then
   begin
    if not Assigned(TSndObj(Fsounds.Objects[i]).s3m) then
      SoundPlay(TSndObj(Fsounds.Objects[i]).str)
    else
     begin
      if Assigned(TSndObj(Fsounds.Objects[i]).s3m) then
        SoundPlay(TSndObj(Fsounds.Objects[i]).s3m);
     end;
   end
  else
   result := false;
end;

procedure TRQtheme.ApplyFont(const pName : TPicName; fnt : TFont);
var
  i : Integer;
begin
  if not Assigned(fnt) then
//   fnt := Screen.MenuFont;
    Exit;
//  i := FFonts2.IndexOf(AnsiLowerCase(name));
  i := FFonts2.IndexOf(pName);
  if i >= 0 then
   with TFontObj(FFonts2.Objects[i]) do
    if flags > 0 then
     begin
       if flags and FPT_CHARSET > 0 then
         fnt.Charset := charset;
       if flags and FPT_SIZE > 0 then
         fnt.Size := size;
       if flags and FPT_COLOR > 0 then
         fnt.Color := color;
       if flags and FPT_STYLE > 0 then
         fnt.Style := style;
       if flags and FPT_NAME > 0 then
         fnt.Name := TFontName(Name);
     end;
end;

{
function TRQtheme.GetFontProp(name : String; Prop : TFontPropsTypes) : TFontProps;
var
  i, j : Integer;
  found : Boolean;
begin
  found := False;
  Result.fpType := Prop;
  i := FFonts2.IndexOf(AnsiLowerCase(name));
  if i >= 0 then
   begin
    for J := 0 to Length(TFontObj(FFonts2.Objects[i]).prop) - 1 do
      if Prop = TFontObj(FFonts2.Objects[i]).prop[j].fpType then
      begin
      case Prop of
        FPT_CHARSET: Result.charset := TFontObj(FFonts2.Objects[i]).prop[j].charset;
        FPT_SIZE:    Result.Size    := TFontObj(FFonts2.Objects[i]).prop[j].size;
        FPT_COLOR:   Result.Color   := TFontObj(FFonts2.Objects[i]).prop[j].color;
        FPT_STYLE:   Result.Style   := TFontObj(FFonts2.Objects[i]).prop[j].style;
        FPT_NAME:    Result.Name    := TFontObj(FFonts2.Objects[i]).prop[j].name;
      end;
       found := True;
      end;
   end;
  if not found then
    case Prop of
        FPT_CHARSET: Result.charset := Screen.MenuFont.charset;
        FPT_SIZE:    Result.Size    := Screen.MenuFont.size;
        FPT_COLOR:   Result.Color   := Screen.MenuFont.color;
        FPT_STYLE:   Result.Style   := Screen.MenuFont.style;
        FPT_NAME:    StrPCopy(Result.Name, Screen.MenuFont.Name);
    end;
end;
}
function TRQtheme.GetFontName(const pName : TPicName) : String;
var
  i : Integer;
  found : Boolean;
begin
  found := False;
  i := FFonts2.IndexOf(AnsiLowerCase(pName));
  if i >= 0 then
   begin
     if TFontObj(FFonts2.Objects[i]).flags and FPT_NAME > 0 then
      begin
       Result := TFontObj(FFonts2.Objects[i]).name;
       found := True;
      end;
   end;
  if not found then
   Result := Screen.MenuFont.Name;
end;


function TRQtheme.GetColor(const name : TPicName; pDefColor : TColor = clDefault) : TColor;
var
  i : Integer;
begin
  i := FClr.IndexOf(AnsiLowerCase(name));
  if i >= 0 then
 {$WARN UNSAFE_CAST OFF}
    result := TColor(FClr.Objects[i])
 {$WARN UNSAFE_CAST ON}
  else
    begin
//      addProp(name, pDefColor);
      result := pDefColor;
    end
end;

function TRQtheme.GetAColor(const name : TPicName; pDefColor : Integer = clDefault) : Cardinal;
var
  i : Integer;
begin
  i := FClr.IndexOf(AnsiLowerCase(name));
  if i >= 0 then
//    result := ColorFromAlphaColor($FF, ABCD_ADCB(ColorToRGB(TColor(FClr.Objects[i]))))
 {$WARN UNSAFE_CAST OFF}
   {$IFDEF USE_GDIPLUS}
    result := AlphaMask or ABCD_ADCB(ColorToRGB(TColor(FClr.Objects[i])))
   {$ELSE NOT USE_GDIPLUS}
    result := AlphaMask or ColorToRGB(TColor(FClr.Objects[i]))
   {$ENDIF USE_GDIPLUS}
 {$WARN UNSAFE_CAST ON}
  else
    begin
//      addProp(name, pDefColor);
//      result := ColorFromAlphaColor($FF, ABCD_ADCB(ColorToRGB(pDefColor)));
      {$IFDEF USE_GDIPLUS}
      result := AlphaMask or ABCD_ADCB(ColorToRGB(pDefColor));
      {$ELSE NOT USE_GDIPLUS}
       result := AlphaMask or ColorToRGB(pDefColor)
      {$ENDIF USE_GDIPLUS}
    end
end;

function TRQtheme.GetTColor(const name : TPicName; pDefColor : Cardinal) : Cardinal;
var
  i : Integer;
begin
  i := FClr.IndexOf(AnsiLowerCase(name));
  if i >= 0 then
//    result := ColorFromAlphaColor($FF, ABCD_ADCB(ColorToRGB(TColor(FClr.Objects[i]))))
 {$WARN UNSAFE_CAST OFF}
   {$IFDEF USE_GDIPLUS}
    result := cardinal(FClr.Objects[i])
   {$ELSE NOT USE_GDIPLUS}
    result := cardinal(FClr.Objects[i])
   {$ENDIF USE_GDIPLUS}
 {$WARN UNSAFE_CAST ON}
  else
    begin
//      addProp(name, pDefColor);
//      result := ColorFromAlphaColor($FF, ABCD_ADCB(ColorToRGB(pDefColor)));
      {$IFDEF USE_GDIPLUS}
      result := pDefColor;
      {$ELSE NOT USE_GDIPLUS}
       result := pDefColor
      {$ENDIF USE_GDIPLUS}
    end
end;

function TRQtheme.pic2ico(pTE : TRnQThemedElement; const picName: TPicName; ico:Ticon) : Boolean;
var
  bmp : TRnQBitmap;
//  vIco : TIcon;
  i : Integer;
  hi : HICON;
  s : TPicName;
begin
  if picName = '' then
   begin
    Result := False;
    Exit;
   end;
//  if not GetIco2(picName, ico) then
(*  if (Win32MajorVersion < 5) or (IsWin2K) then
   begin
{    with GetPicSize(picName) do
     if (cx > 0) and (cy > 0) then
     begin
       bmp := createBitmap(cx, cy);
      bmp.PixelFormat := pf24bit;
//       bmp.Canvas.Brush.Color:= $007f017f;
       bmp.Canvas.Brush.Color:= ColorToRGB(clBtnFace);
      bmp.Canvas.FillRect(bmp.Canvas.ClipRect);
      drawPic(bmp.Canvas, 0, 0, picName);
//       bmp.TransparentColor := $007f017f;
       bmp.TransparentColor := ColorToRGB(clBtnFace);
       bmp.Transparent := True;
      vIco := bmp2ico(bmp);
      ico.Assign(vIco);
      vIco.Free;
      bmp.Free;
      Result := True;
     end;}
   end
  else *)
  begin
//   bmp :=TRnQBitmap.Create;
   result := false;
   i := -1;
   if pTE <> RQteDefault then
    begin
      s := te2Str[pTE] + AnsiLowerCase(picName);
      i := FThemePics.IndexOf(s);
    end;
   if i < 0 then
     i := FThemePics.IndexOf(AnsiLowerCase(picName));
   if i >= 0 then
    begin
     with TThemePic(FThemePics.Objects[i]) do
//     if Assigned(TPicObj(FBigPics.Objects[PicIDX]).bmp) then
     if Assigned(FBigPics[PicIDX].bmp) then
      begin
       hi := 0;
//       TPicObj(FBigPics.Objects[TThemePic(FThemePics.Objects[i]).PicIDX]).bmp.GetHICON(hi);
//{
//       bmp := TPicObj(FBigPics.Objects[PicIDX]).bmp.Clone(r
       if isWholeBig then
          FBigPics[PicIDX].bmp.GetHICON(hi)
        else
         begin
           bmp := FBigPics[PicIDX].bmp.Clone(r
      {$IFDEF USE_GDIPLUS}
                      ,TPicObj(FBigPics.Objects[PicIDX]).bmp.GetPixelFormat
      {$ENDIF USE_GDIPLUS}
                      );
           if Assigned(bmp) then
             begin
               bmp.GetHICON(hi);
               if Assigned(Bmp) then
                 Bmp.Free;
               Bmp := NIL;
             end
            else
             hi := 0;
         end;
//}
//       TPicObj(FBigPics.Objects[TThemePic(FThemePics.Objects[i]).PicIDX]).bmp.GetHICON(hi);
       ico.Handle := hi;
       if hi > 0 then
        begin
         result := true;
         DeleteObject(hi);
        end
//       else
//        result := False;
      end
//     else
//       result := False;
    end
  else
   begin
     i := FIntPics.IndexOf(AnsiLowerCase(picName));
     if i >= 0 then
      begin
       hi := ImageList_ExtractIcon(0, FIntPicsIL, i);
       ico.Handle := hi;
       if hi > 0 then
        begin
         result := true;
         DeleteObject(hi);
        end
      end
//     else
//       Result := False;
   end;
  end
//  else
//   Result := True;
end;

function TRQtheme.pic2hIcon(const picName:TPicName; var ico:HICON) : Boolean;
var
  bmp : TRnQBitmap;
//  vIco : TIcon;
  i : Integer;
//  hi : HICON;
begin
//   bmp :=TRnQBitmap.Create;
   if ico <> 0 then
     DeleteObject(ico);
   ico := 0;
   result := false;
   i := FThemePics.IndexOf(AnsiLowerCase(picName));
   if i >= 0 then
    begin
     with TThemePic(FThemePics.Objects[i]) do
//     if Assigned(TPicObj(FBigPics.Objects[PicIDX]).bmp) then
     if Assigned(FBigPics[PicIDX].bmp) then
      begin
//       TPicObj(FBigPics.Objects[TThemePic(FThemePics.Objects[i]).PicIDX]).bmp.GetHICON(hi);
//{
       bmp := FBigPics[PicIDX].bmp.Clone(r
  {$IFDEF USE_GDIPLUS}
                  ,TPicObj(FBigPics.Objects[PicIDX]).bmp.GetPixelFormat
  {$ENDIF USE_GDIPLUS}
                  );
       if Assigned(bmp) then
         begin
           bmp.GetHICON(ico);
           if Assigned(Bmp) then
             Bmp.Free;
           Bmp := NIL;
         end
        else
         ico := 0;
//}
//       TPicObj(FBigPics.Objects[TThemePic(FThemePics.Objects[i]).PicIDX]).bmp.GetHICON(hi);
//       result := True;
//       ico.Handle := hi;
//       DeleteObject(hi);
       result := true;
      end
//     else
//       result := False;
    end
  else
   begin
     i := FIntPics.IndexOf(AnsiLowerCase(picName));
     if i >= 0 then
      begin
       ico := ImageList_ExtractIcon(0, FIntPicsIL, i);
       Result := True;
      end
//     else
//       Result := False;
   end;
end;

function TRQtheme.addBigPic(var pBmp: TRnQBitmap; const origPic: TMemoryStream): Integer;
//var
//  tempPic :TPicObj;
begin
  result := Length(FBigPics);
  SetLength(FBigPics, result + 1);
  FBigPics[Result] := TPicObj.Create;
  FBigPics[Result].bmp := pBmp;
  pBmp := nil;
 {$IFDEF PRESERVE_BIG_FILE}
  if Assigned(origPic) then
   begin
    FBigPics[Result].pic := TMemoryStream.Create;
    origPic.Seek(0, soFromBeginning);
    FBigPics[Result].pic.LoadFromStream(origPic);
    FBigPics[Result].pic.Seek(0, soFromBeginning);
   end;
 {$ENDIF PRESERVE_BIG_FILE}
      FBigPics[Result].ref := 0;
//      FBigPics.AddObject(AnsiLowerCase(name), tempPic)
end;

function TRQtheme.addBigSmile(var pBmp: TRnQBitmap; const origPic: TMemoryStream): Integer;
//var
//  tempPic :TPicObj;
begin
  result := Length(FsmileBigPics);
  SetLength(FsmileBigPics, result + 1);
  FsmileBigPics[Result] := TPicObj.Create;
  FsmileBigPics[Result].bmp := pBmp;
  pBmp := nil;
 {$IFDEF PRESERVE_BIG_FILE}
  if Assigned(origPic) then
   begin
    FSmileBigPics[Result].pic := TMemoryStream.Create;
    origPic.Seek(0, soFromBeginning);
    FSmileBigPics[Result].pic.LoadFromStream(origPic);
    FSmileBigPics[Result].pic.Seek(0, soFromBeginning);
   end;
 {$ENDIF PRESERVE_BIG_FILE}
      FsmileBigPics[Result].ref := 0;
//      FBigPics.AddObject(AnsiLowerCase(name), tempPic)
end;

function TRQtheme.addprop(const name: TPicName; kind:TthemePropertyKind; var pBmp: TRnQBitmap) : Integer;
var
  i : Integer;
//  tempPic :TPicObj;
  thp : TThemePic;
begin
  result := -1;
  if not Assigned(pBmp) then
    exit;
  if kind = TP_smile then
  begin  // pic for smile
{    i := FSmileBigPics.IndexOf(AnsiLowerCase(name));
    if i < 0 then
     begin
      tempPic :=TPicObj.Create;
      tempPic.bmp := pBmp;
      pBmp := nil;
      tempPic.ref := 0;
      result := FSmileBigPics.AddObject(AnsiLowerCase(name), tempPic)
     end
    else
     with TPicObj(FSmileBigPics.Objects[i]) do
     begin
       if Assigned(bmp) then
        bmp.Free;
       bmp := NIL;
       bmp := pBmp;
       pBmp := nil;
       result := i;
     end;}
  end
 else // just pic
  begin
//    i := FBigPics.IndexOf(AnsiLowerCase(name));
    i := FThemePics.IndexOf(AnsiLowerCase(name));
    if i < 0 then
     begin
      thp := TThemePic.Create;
      thp.r.X := 0; thp.r.Y := 0;
      thp.r.Width  := pBmp.Width;
      thp.r.Height := pBmp.Height;
      thp.PicIDX := addBigPic(pBmp, NIL);
      inc(FBigPics[thp.PicIDX].ref);
//      tempPic.bmp := Bmp.Clone(1, 1, Bmp.GetWidth, bmp.GetHeight, bmp.GetPixelFormat);
//      tempPic.bmp := Bmp.Clone;
{      tempPic :=TPicObj.Create;
      tempPic.bmp := pBmp;
      pBmp := nil;
      tempPic.ref := 0;
      result := FBigPics.AddObject(AnsiLowerCase(name), tempPic)}
      result := FThemePics.AddObject(name, thp);
     end
    else
//     with TPicObj(FBigPics.Objects[i]) do
     begin
       thp := TThemePic(FThemePics.Objects[i]);
      thp.r.X := 0; thp.r.Y := 0;
      thp.r.Width  := pBmp.Width;
      thp.r.Height := pBmp.Height;

      if Assigned(FBigPics[thp.PicIDX]) then
        dec(FBigPics[thp.PicIDX].ref);
      thp.PicIDX := addBigPic(pBmp, NIL);
      inc(FBigPics[thp.PicIDX].ref);

//       if Assigned(bmp) then
//        bmp.Free;
//       bmp := NIL;
//       TPicObj(FBigPics.Objects[i]).bmp := Bmp.Clone(0, 0, Bmp.GetWidth, bmp.GetHeight, bmp.GetPixelFormat);
//       bmp := pBmp;
//       pBmp := nil;
//       TPicObj(FBigPics.Objects[i]).ref := 0;
//       TPicObj(FBigPics.Objects[i]).Free;
//       FBigPics.Objects[i] := Bmp.Clone;
       result := i;
     end;
  end
end; // addthemeprop

procedure TRQtheme.addProp(const name: TPicName; kind: TthemePropertyKind; var pic: TThemePic);
var
  i : Integer;
begin
  if not Assigned(pic) then
    exit;
  if kind = TP_smile then
  with FSmilePics do
  begin  // pic for smile
//    i := IndexOf(AnsiLowerCase(name));
    i := IndexOf(name);
    if i < 0 then
     begin
//      AddObject(AnsiLowerCase(name), pic);
      AddObject(name, pic);
      pic := nil;
     end
    else
     begin
       with TThemePic(Objects[i]) do
        begin
         r := pic.r;
         PicIDX := pic.PicIDX;
        end;
       FreeAndNil(Pic);
     end;
  end
 else // just pic
  with FThemePics do
  begin
    i := IndexOf(AnsiLowerCase(name));
    if i < 0 then
     begin
      AddObject(AnsiLowerCase(name), pic);
      pic := nil;
     end
    else
     begin
       with TThemePic(Objects[i]) do
        begin
         r := pic.r;
         PicIDX := pic.PicIDX;
        end;
       FreeAndNil(Pic);
     end;
  end
end;

procedure TRQtheme.addHIco(const name: TPicName; hi: HICON; Internal: Boolean = false);
//procedure TRQtheme.addprop(name:string;hi: HICON; Internal : Boolean = false);
var
  i : Integer;
//  j, cnt : Integer;
//  bmp : TRnQBitmap;
//  ff : TGUID;
begin
  if hi = 0 then
    exit;

  if not Internal then
   begin
{    i := FBigPics.IndexOf(AnsiLowerCase(name));
    if i < 0 then
      begin
//       TRnQBitmap.c
//       i :=
       FBigPics.AddObject(AnsiLowerCase(name), TRnQBitmap.Create(hi));
//       TRnQBitmap(FGPpics.Objects[i]).
      end
    else
     begin
      TRnQBitmap(FBigPics.Objects[i]).Free;
      FBigPics.Objects[i] := TRnQBitmap.Create(hi);
     end;
{     cnt := TRnQBitmap(FGPpics.Objects[i]).GetFrameCount(FrameDimensionResolution);
     if cnt > 1 then
      for j := 0 to cnt-1 do
       begin
         TRnQBitmap(FGPpics.Objects[i]).SelectActiveFrame(FrameDimensionResolution, j);
         if (TRnQBitmap(FGPpics.Objects[i]).GetWidth = icon_size)
            or (TRnQBitmap(FGPpics.Objects[i]).GetHeight = icon_size) then
           break; 
       end;
}
   end;
     if Internal then
      begin
        i := FIntPics.IndexOf(AnsiLowerCase(name));
        if i < 0 then
          begin
//           i :=
            FIntPics.Add(AnsiLowerCase(name));
           ImageList_AddIcon(FIntPicsIL, hi);
//           FIntPicsIL
//           i := FIntPics.AddObject(AnsiLowerCase(name), TRnQBitmap.Create(hi));
          end
         else
         begin
          ImageList_ReplaceIcon(FIntPicsIL, i, hi)
//          TRnQBitmap(FIntPics.Objects[i]).Free;
//          FIntPics.Objects[i] := TRnQBitmap.Create(hi);
         end;
{       if TRnQBitmap(FIntPics.Objects[i]).GetFrameDimensionsCount > 0 then
       begin
        TRnQBitmap(FIntPics.Objects[i]).GetFrameDimensionsList(@ff, 1);
//        cnt := TRnQBitmap(FIntPics.Objects[i]).GetFrameCount(FrameDimensionResolution);
        cnt := TRnQBitmap(FIntPics.Objects[i]).GetFrameCount(ff);
//       cnt := TRnQBitmap(FIntPics.Objects[i]).GetFrameCount(FrameDimensionTime);
       if cnt > 1 then
        for j := 0 to cnt-1 do
         begin
           TRnQBitmap(FIntPics.Objects[i]).SelectActiveFrame(FrameDimensionResolution, j);
           if (TRnQBitmap(FIntPics.Objects[i]).GetWidth = icon_size)
              or (TRnQBitmap(FIntPics.Objects[i]).GetHeight = icon_size) then
             break;
         end;
       end;}
      end
end; // addthemeprop

function TRQtheme.AddPicResource(const name: TPicName; ResourceName: String; Internal: Boolean = false) : Boolean;
var
  bmp: TRnQBitmap;
  str: TResourceStream;
begin
  try
    str := TResourceStream.Create(HInstance, ResourceName, RT_RCDATA);
  except
//    e: EResNotFound
    result := false;
    exit;
  end;
  bmp := TRnQBitmap.Create;
  if not loadPic(TStream(str), bmp, 0, PA_FORMAT_UNK, name) then
    begin
      str.Free;
      exit;
    end;
  addProp(name, TP_pic, bmp);
end;


procedure TRQtheme.addprop(const name: TPicName; const SmlCaption: String;
                           Smile: TRnQBitmap; origSmile: TMemoryStream;
                           var pTP: TThemePic; bStretch: Boolean = false;
                           Ani: Boolean = false; AniIdx: Integer=-1);
var
  i, j : Integer;
  NewSmile : TSmlObj;
  vST : TthemePropertyKind;
  tp  : TThemePic;
  pic : TRnQBitmap;
  origPic: TMemoryStream;
begin
//  if bStretch then
//    vST := TP_ico
//   else
//    vST := TP_pic;
vST := TP_smile;
  i := Fsmiles.IndexOf(name);
  if i < 0 then
   begin
    if not Assigned(Smile) and not Assigned(pTP) then
      exit;
    NewSmile := TSmlObj.Create;
    NewSmile.Animated := Ani;
    NewSmile.SmlStr := TStringList.Create;
    NewSmile.SmlStr.CaseSensitive := True;
    NewSmile.SmlStr.Add(SmlCaption);
    NewSmile.AniIdx := AniIdx;
    Fsmiles.AddObject(name, NewSmile);
    if not Assigned(pTP) then
     begin
      tp := TThemePic.Create;
      with tp.r do
      begin
        x := 0;
        y := 0;
        width := Smile.GetWidth;
        height := Smile.GetHeight;
      end;
  //    pic := Smile.Clone(0, 0, tp.Width, tp.Height, Smile.GetPixelFormat);
      pic := Smile;
      origPic := origSmile;
      tp.picIdx := addBigSmile(pic, origPic);
//      NewSmile.AniIdx :=
      addprop(name, vST, tp);
     end
    else
      addprop(name, vST, pTP);
    pTP := NIL;
//    NewSmile := NIL;
   end
  else
   begin
     j := TSmlObj(Fsmiles.Objects[i]).SmlStr.IndexOf(SmlCaption);
     if j < 0 then
      TSmlObj(Fsmiles.Objects[i]).SmlStr.Add(SmlCaption)
     else
      if Assigned(Smile) or Assigned(pTP) then
       begin
        if not Assigned(pTP) then
         begin
          tp := TThemePic.Create;
          with tp.r do
          begin
            X := 0; Y := 0; Width := Smile.GetWidth; Height := Smile.GetHeight;
          end;
  //        pic := Smile.Clone(0, 0, tp.Width, tp.Height, Smile.GetPixelFormat);
          pic := Smile;
          origPic := origSmile;
          tp.picIdx := addBigSmile(pic, origPic);
          addprop(name, vST, tp);
         end
        else
          addprop(name, vST, pTP);
        pTP := NIL;
//        addprop(name, vST, Smile);
       end;
   end;
end; // theme.addprop

procedure TRQtheme.addprop(name: TPicName; ts: TThemeSourcePath; kind: TthemePropertyKind; const s: String);
var
  StrObj : TStrObj;
  sndObj : TSndObj;
  i : Integer;
  curList : TObjList;
begin
  if name='' then
    exit;
  name := AnsiLowerCase(name);
  if  kind = TP_sound then
  begin
   i := FSounds.IndexOf(name);
   if i < 0 then
    begin
      SndObj := TSndObj.Create;
      i := FSounds.AddObject(name, SndObj);
    end;
   TSndObj(FSounds.Objects[i]).str := s;
   FreeAndNil(TSndObj(FSounds.Objects[i]).s3m);
   if ts.pathType <> pt_path then
     begin
       TSndObj(FSounds.Objects[i]).s3m := TMemoryStream.Create;
       ts.path := '';
       if not loadFile(ts, s, TStream(TSndObj(FSounds.Objects[i]).s3m)) then
         FreeAndNil(TSndObj(FSounds.Objects[i]).s3m);
     end;
   exit;
  end;
  case kind of
   TP_string: curList := FStr;
   else
    exit;
  end;
  begin
   i := curList.IndexOf(name);
   if i < 0 then
     begin
      StrObj := TStrObj.Create;
      StrObj.str := s;
      curList.AddObject(name, StrObj);
     end
    else
     begin
       TStrObj(curList.Objects[i]).str := s;
     end;
  end
end; // addthemeprop
{
procedure TRQtheme.addprop(name:string; fnt: TFont);
var
  i : Integer;
begin
  i := FFonts.IndexOf(AnsiLowerCase(name));
  if i < 0 then
   FFonts.AddObject(AnsiLowerCase(name), fnt)
  else
   begin
    FFonts.Objects[i].Free;
    FFonts.Objects[i] := fnt;
   end;
end;
}

procedure TRQtheme.addprop(const pName:TPicName; fnt: TFontObj);
var
  i : Integer;
  fo : TFontObj;
//  j: Integer;
//  Found : Boolean;
begin
  i := FFonts2.IndexOf(AnsiLowerCase(pName));
  if i < 0 then
    begin
     fo := fnt.Clone;
//     SetLength(fo.prop, 1);
//     fo.prop[0] := fnt;
     FFonts2.AddObject(AnsiLowerCase(pName), fo)
    end
  else
   begin
    if FPT_CHARSET and fnt.flags > 0 then
     begin
       TFontObj(FFonts2.Objects[i]).flags := TFontObj(FFonts2.Objects[i]).flags or FPT_CHARSET;
       TFontObj(FFonts2.Objects[i]).charset := fnt.charset;
     end;
//     else
//       TFontObj(FFonts2.Objects[i]).flags := TFontObj(FFonts2.Objects[i]).flags and not FPT_CHARSET;

    if FPT_SIZE and fnt.flags > 0 then
     begin
       TFontObj(FFonts2.Objects[i]).flags := TFontObj(FFonts2.Objects[i]).flags or FPT_SIZE;
       TFontObj(FFonts2.Objects[i]).size := fnt.size;
     end;
//     else
//       TFontObj(FFonts2.Objects[i]).flags := TFontObj(FFonts2.Objects[i]).flags and not FPT_SIZE;

    if FPT_COLOR and fnt.flags > 0 then
     begin
       TFontObj(FFonts2.Objects[i]).flags := TFontObj(FFonts2.Objects[i]).flags or FPT_COLOR;
       TFontObj(FFonts2.Objects[i]).color := fnt.color;
     end;
//     else
//       TFontObj(FFonts2.Objects[i]).flags := TFontObj(FFonts2.Objects[i]).flags and not FPT_COLOR;

    if FPT_STYLE and fnt.flags > 0 then
     begin
       TFontObj(FFonts2.Objects[i]).flags := TFontObj(FFonts2.Objects[i]).flags or FPT_STYLE;
       TFontObj(FFonts2.Objects[i]).style := fnt.style;
     end;
//     else
//       TFontObj(FFonts2.Objects[i]).flags := TFontObj(FFonts2.Objects[i]).flags and not FPT_STYLE;

    if FPT_NAME and fnt.flags > 0 then
     begin
       TFontObj(FFonts2.Objects[i]).flags := TFontObj(FFonts2.Objects[i]).flags or FPT_NAME;
       if TFontObj(FFonts2.Objects[i]).Name <> NIL then
         StrDispose(TFontObj(FFonts2.Objects[i]).Name);
      {$IFDEF UNICODE}
//       TFontObj(FFonts2.Objects[i]).Name := AnsiStrAlloc(StrLen(fnt.name)+1);
       TFontObj(FFonts2.Objects[i]).Name := StrAlloc(StrLen(fnt.name)+1);
      {$ELSE nonUNICODE}
       TFontObj(FFonts2.Objects[i]).Name := StrAlloc(StrLen(fnt.name)+1);
      {$ENDIF UNICODE}
       StrCopy(TFontObj(FFonts2.Objects[i]).Name, fnt.name);
     end;
//     else
//      begin
//       TFontObj(FFonts2.Objects[i]).flags := TFontObj(FFonts2.Objects[i]).flags and not FPT_NAME;
//       if TFontObj(FFonts2.Objects[i]).Name <> NIL then
//        StrDispose(TFontObj(FFonts2.Objects[i]).Name);
//      end;
   end;
end;

procedure TRQtheme.addProp(const name:TPicName; c: TColor);
var
  i : Integer;
begin
 i := FClr.IndexOf(AnsiLowerCase(name));
 if i < 0 then
   FClr.AddObject(AnsiLowerCase(name), TObject(c))
 else
  begin
   FClr.Objects[i] := TObject(c);
  end;
end;

procedure TRQtheme.loadThemeScript(const fn:string; const path : string);
var
  ts : TThemeSourcePath;
begin
  ts.pathType := pt_path;
    {$IFDEF USE_ZIP}
  ts.zp := nil;
    {$ENDIF USE_ZIP}
    {$IFDEF USE_7Z}
  ts.z7 := nil;
    {$ENDIF USE_7Z}
  ts.ArcFile := '';  
  ts.path := path;
  loadThemeScript(fn, ts);
end;

procedure TRQtheme.loadThemeScript(fn: string; ts : TThemeSourcePath);
var
//  LastPicFName : String; // For support '@' at pics
//  LastLoadedPic : TRnQBitmap;
  LastPicIDX : Integer; // For support '@' at pics

  function fullpath(const fn: string): string;
  begin
    if ansipos(':',fn)=0 then
      result:=ts.path+fn
     else
      result:=fn
  end;
//  function fullpath(fn:string):string;
//  begin if ansipos(':',fn)=0 then result:=path+fn else result:=fn end;

(*  procedure crop(bmp:TRnQBitmap; x,y,dx,dy:integer);
  begin
  if dy < 0 then exit;
//  bmp.Transparent := True;
//  bmp.TransparentColor := bmp.Canvas.Pixels[x, y];
  {$IFDEF USE_32Aplha_Images}
   bmp.PixelFormat:= bmp.PixelFormat;
  {$ENDIF}
  if (x<>0) or (y<>0) then
    bmp.canvas.copyRect(rect(0,0,dx,dy), bmp.canvas, rect(x,y,x+dx,y+dy));
  bmp.Width:=dx;
  bmp.height:=dy;
  bmp.TransparentMode := tmAuto;
  bmp.Transparent := True;
//  bmp.TransparentColor := bmp.Canvas.Pixels[x, y];
  end; // crop
*)

{  procedure parsePic(v : String;var bmp:TRnQBitmap);
  var
    s,fn:string;
    x,y,dx,dy, idx:integer;
  begin
    s:=v;
    fn:=chop(';',s);
    if fn='' then exit;
//    if bmp=NIL then bmp:=TRnQBitmap.create;
    if bmp <> NIL then FreeAndNil(bmp);

    x:=str2valor(chop(';',s));
    y:=str2valor(chop(';',s));
    if (y = -1) and (x <> -1)and (s = '') then
     begin
       idx := x;
       x := -1;
       dx:=-1;
       dy:=-1;
     end
    else
     begin
      dx:=str2valor(chop(';',s));
      dy:=str2valor(chop(';',s));
      idx := str2valor(chop(';',s));
     end;
    if fn = '@' then
      begin
       if Assigned(LastLoadedPic) then
       begin
//        if (LastLoadedPic.GetHorizontalResolution <> Screen.PixelsPerInch)
//         or (LastLoadedPic.GetVerticalResolution <> Screen.PixelsPerInch) then
//           LastLoadedPic.SetResolution(Screen.PixelsPerInch, Screen.PixelsPerInch);
        bmp := LastLoadedPic.Clone(x,y,dx, dy, LastLoadedPic.GetPixelFormat);
        if Assigned(bmp) then
         if (bmp.GetHorizontalResolution <> Screen.PixelsPerInch)
          or (bmp.GetVerticalResolution <> Screen.PixelsPerInch) then
           bmp.SetResolution(Screen.PixelsPerInch, Screen.PixelsPerInch);
       end
//       else
//        bmp := nil;
      end
//      bmp := LastLoadedPic.Clone(0,0,LastLoadedPic.GetWidth, LastLoadedPic.GetHeight, PixelFormat32bppARGB)
//      fn := LastPicFName
    else
    if AnsiStartsText('@pics.', fn) then
      begin
        getPic13(copy(fn,6,length(fn)), bmp);
      end
     else
       begin
        FreeAndNil(LastLoadedPic);
//        LastLoadedPic := TRnQBitmap.Create;
        if not loadPic(ts, fn, LastLoadedPic, idx) then
         begin
          LastLoadedPic := NIL;
          FreeAndNil(bmp);
          Exit;
         end;
        if dy < 0 then
         begin
          x := 0; y := 0;
          if Assigned(LastLoadedPic) then
           begin
            dx := LastLoadedPic.GetWidth;
            dy := LastLoadedPic.GetHeight;
           end
          else
           begin
            dx := 0; dy := 0;
           end;
//          LastLoadedPic.Clone;
         end;
//        else
         begin
          if x < 0 then x := 0;
          if y < 0 then y := 0;

//        if (LastLoadedPic.GetHorizontalResolution <> Screen.PixelsPerInch)
//         or (LastLoadedPic.GetVerticalResolution <> Screen.PixelsPerInch) then
//           LastLoadedPic.SetResolution(Screen.PixelsPerInch, Screen.PixelsPerInch);
          bmp := LastLoadedPic.Clone(x,y,dx, dy,LastLoadedPic.GetPixelFormat);
//        bmp.Assign(LastLoadedPic);
         end;
       end;
//    crop(bmp,x,y,dx,dy);
  end; // parsePic
}
  function parsePic(IsSmile: boolean; const v: AnsiString; const PicName: TPicName = ''): TThemePic;
  var
    s : RawByteString;
    fn: AnsiString;
    x,y,dx,dy, idx:integer;
    w, h : Integer;
    tempPic : TRnQBitmap;
    origPic: TMemoryStream;
    I: Integer;
  begin
    tempPic := nil;
    origPic := nil;
    s := v;
    result := nil;
    fn := chop(RawByteString(';'),s);
    if fn='' then
      exit;
//    if bmp=NIL then bmp:=TRnQBitmap.create;
//    if bmp <> NIL then FreeAndNil(bmp);

    x := str2valor(chop(RawByteString(';'),s));
    y := str2valor(chop(RawByteString(';'),s));
    if (y = -1) and (x <> -1)and (s = '') then
     begin
       idx := x;
       x   := -1;
       dx  := -1;
       dy  := -1;
     end
    else
     begin
      dx  := str2valor(chop(';',s));
      dy  := str2valor(chop(';',s));
      idx := str2valor(chop(';',s));
     end;
    if fn = '@' then
      begin
//       if Assigned(LastLoadedPic) then
       if LastPicIDX >= 0 then
       begin
//        if (LastLoadedPic.GetHorizontalResolution <> Screen.PixelsPerInch)
//         or (LastLoadedPic.GetVerticalResolution <> Screen.PixelsPerInch) then
//           LastLoadedPic.SetResolution(Screen.PixelsPerInch, Screen.PixelsPerInch);
        Result := TThemePic.Create;
{        Result.Left := x;
        Result.Top := y;
        Result.Width := dx;
        Result.Height := dy;}
        Result.R := MakeRectI(x, y, dx, dy);

        Result.PicIDX := LastPicIDX;
       end
//       else
//        bmp := nil;
      end
//      bmp := LastLoadedPic.Clone(0,0,LastLoadedPic.GetWidth, LastLoadedPic.GetHeight, PixelFormat32bppARGB)
//      fn := LastPicFName
    else
      begin
        if AnsiStartsText(AnsiString('@pics.'), fn) then
          begin
            LastPicIDX := -1;
            s := AnsiLowerCase(copy(fn, 7, length(fn)));
            if PicName = s then
             begin
              tempPic := NIL;
              Result := nil;
              Exit;
             end;
            w := 0;
            h := 0;
            i := FThemePics.IndexOf(s);
//            for I := 0 to FThemePics.Count - 1 do
//              if FThemePics.Strings[i] = s then
            if i >=0 then
               with TThemePic(FThemePics.Objects[i]) do
               begin
                 LastPicIDX := PicIDX;
                 if x >=0 then x  := r.X + x
                  else  x  := r.X;
                 if y >= 0 then y :=  r.Y + y
                  else  y  := r.Y;
                 if dx < 0 then dx := r.Width
                  else dx := min(dx, r.Width);
                 if dy < 0 then dy := r.Height
                  else dy := min(dy, r.Height);
//                 break;
               end;
          end
         else
           begin
    //        FreeAndNil(LastLoadedPic);
            LastPicIDX := -1;
    //        LastLoadedPic := TRnQBitmap.Create;
    //        if not loadPic(ts, fn, LastLoadedPic, idx) then
            if loadFile(ts, UnUTF(fn), TStream(origPic)) and
               loadPic(TStream(origPic), tempPic, idx, PA_FORMAT_UNK, UnUTF(fn), True) then
              begin
                w := tempPic.GetWidth;
                h := tempPic.GetHeight;
    //            LastPicIDX := addProp(fn, TP_pic, tempPic);
                LastPicIDX := addBigPic(tempPic, origPic);
                if Assigned(origPic) then
                  FreeAndNil(origPic);
              end
            else
             begin
                if Assigned(tempPic) then
                  tempPic.Free;
                tempPic := NIL;
                if Assigned(origPic) then
                  FreeAndNil(origPic);
                Result := nil;
                Exit;
             end;
          end;
        if LastPicIDX >=0 then
        begin
          if dy < 0 then
           begin
            x := 0; y := 0;
//            if LastPicIDX >=0 then
             begin
              dx := w;
              dy := h;
             end
{            else
             begin
              dx := 0; dy := 0;
             end;}
  //          LastLoadedPic.Clone;
           end;
  //        else
           begin
            if x < 0 then x := 0;
            if y < 0 then y := 0;

  //        if (LastLoadedPic.GetHorizontalResolution <> Screen.PixelsPerInch)
  //         or (LastLoadedPic.GetVerticalResolution <> Screen.PixelsPerInch) then
  //           LastLoadedPic.SetResolution(Screen.PixelsPerInch, Screen.PixelsPerInch);
            Result := TThemePic.Create;
{            Result.Left := x;
            Result.Top := y;
            Result.Width := dx;
            Result.Height := dy;}
            Result.R := MakeRectI(x, y, dx, dy);
            Result.PicIDX := LastPicIDX;

  //          bmp := LastLoadedPic.Clone(x,y,dx, dy,LastLoadedPic.GetPixelFormat);
  //        bmp.Assign(LastLoadedPic);
           end;
         end;  
       end;
//    crop(bmp,x,y,dx,dy);
  end; // parsePic

  function fontAvailable(list: RawByteString): AnsiString;
   var
     s : String;
  begin
    repeat
      Result := chop(AnsiString(';'),list);
      s := string(Result);
    until (list='') or (screen.fonts.IndexOf(s) >= 0);
{    s := chop(AnsiString(';'),list);
    while (list>'') and (screen.fonts.IndexOf(s) < 0) do
      s:=chop(AnsiString(';'), list);
    result:= s;}
  end; // fontAvailable

//  function parseFont(prefix: string; k, v : String; font : TFont): boolean;
//  function parseFont(prefix: string; k, v : String; var fontProp : TFontObj):boolean;
  function parseFont(const prefix: AnsiString; const k, v, ppar: AnsiString): boolean;
  var
    i: integer;
    s: AnsiString;
    fontProp: TFontObj;
  begin
    result := true;
    fontProp := TFontObj.Create;
    if k=prefix+'.name' then
      begin
       fontProp.flags := fontProp.flags or FPT_NAME;
       s := fontAvailable(v);
 {$IFDEF UNICODE}
//       fontProp.name := AnsiStrAlloc(Length(s)+1);
       fontProp.name := StrAlloc(Length(s)+1);
 {$ELSE nonUNICODE}
       fontProp.name := StrAlloc(Length(s)+1);
 {$ENDIF UNICODE}
       StrPCopy(fontProp.name, s);
  //     font.name:=fontAvailable(v);
      end
    else
    if k=prefix+'.size' then
      begin
       fontProp.flags := fontProp.flags or FPT_SIZE;
       fontProp.size := strToInt(v)
  //     font.size:=strToInt(v)
      end
    else
    if k=prefix+'.color' then
      begin
       fontProp.flags := fontProp.flags or FPT_COLOR;
       fontProp.color := str2color(v)
  //     font.color:=str2color(v)
      end
    else
    if k=prefix+'.charset' then
     begin
       fontProp.flags := fontProp.flags or FPT_CHARSET;
      if isOnlyDigits(v) then
        fontProp.charset := StrToInt(v)
  //      font.charset:=strToInt(v)
      else
        if IdentToCharset(v,i) then
          fontProp.charset := i
  //        font.charset:=i
        else
          if IdentToCharset(v+'_CHARSET',i) then
            fontProp.charset := i
  //          font.charset:=i
           else
            begin
              Result := False;
  //            Exit;
            end;
     end
    else
    if k=prefix+'.style' then
      begin
       fontProp.flags := fontProp.flags or FPT_STYLE;
       fontProp.style := str2fontstyle(v)
  //     font.style:=str2fontstyle(v)
      end
    else
      result := false;
    if Result then
      addprop(ppar, fontProp);
    fontProp.Free;
  end; // parseFont

  procedure parseFontFile(const v : AnsiString; const PicName : TPicName = '');
(*  var
    s : RawByteString;
    fn: AnsiString;
    x,y,dx,dy, idx:integer;
    w, h : Integer;
    tempFont : RawByteString;
    hnd : THandle;
    I: Integer;
    fCnt : DWORD;*)
  begin
{    s:=v;
    fn:=chop(RawByteString(';'),s);
    if fn='' then exit;
{    tempFont := loadFromZipOrFile(ts.zp, ts.path, fn);
    hnd := AddFontMemResourceEx(@tempFont[1], Length(tempFont), 0, @fCnt);
    if hnd > 0 then
      begin

      end;
}
  end;


var
  k,v : RawByteString;
  txt,line  : RawByteString;
  param  : AnsiString; // ”казывает на параметр: roaster, menu, tip, history
  prefix : AnsiString; // Prefix for Font and other...
  par : AnsiString;
  LastSmile : AnsiString;
  i   : integer;
  loadedpic  : TRnQBitmap;
  origPic: TMemoryStream;
  themePic : TThemePic;
//  loadedpic  : TRnQBitmap;
 {$IFDEF RNQ_FULL}
  loadedAniPic : TRnQAni;
//  loadedAniPic : TRnQBitmap;
 {$ENDIF RNQ_FULL}
  section   : TRQsection;
  NonAnimated : Boolean;
  hasSmilePic : Boolean;
  Parsed : Boolean;
//  loadedFontProp : TFontProps;
begin
 ts.path :=  ts.path + ExtractFilePath(fn);
 ts.path := includeTrailingPathDelimiter(ts.path);
 if IsPathDelimiter(ts.path, 1) then
   Delete(ts.path, 1, 1);
 fn := ExtractFileName(fn);
 if fn = '' then
  Exit;
// path:=ExtractFilePath(fn);
 inc(curToken);
 // Adding one empty image
    {$IFDEF USE_GDIPLUS}
   loadedpic := TRnQBitmap.Create(icon_size, icon_size, PixelFormat32bppARGB);
    {$ELSE NOT USE_GDIPLUS}

  // loadedpic := TRnQBitmap.Create(icon_size, icon_size);
   loadedpic := TRnQBitmap.Create(GetSystemMetrics(SM_CXICON), GetSystemMetrics(SM_CYICON));
   loadedpic.MakeEmpty;
    {$ENDIF NOT USE_GDIPLUS}
   addProp(PIC_EMPTY, TP_ico, loadedpic);
   loadedpic.Free;
 loadedpic := NIL;
 loadedAniPic := NIL;
 origPic := nil;
 NonAnimated := True;
 themePic := NIL;
 LastPicIDX := -1;
 hasSmilePic := false;
 section:=_null;
 SetLength(prefix, 0);
 txt := loadfile(ts, fn);
 while txt>'' do
  try
   line:=chopline(txt);
   par := trim(line);
   line:=trim(chop('#',line));
   if (line='')or((line[1]=';') and not ((section = _smiles)and hasSmilePic)) then
     continue;
   if (line[1]='[') and (line[length(line)]=']') then
    begin
      param := AnsiLowerCase(copy(line,2,length(line)-2));
      i := pos(AnsiString('.'), param);
      if i > 0 then
        begin
         k := copy(param, 1, i-1);
         prefix := copy(param, i+1, 100) + '.';
         i:=findInStrings(k, RQsectionLabels);
         k := '';
        end
       else
        begin
         i:=findInStrings(param, RQsectionLabels);
         SetLength(prefix, 0);
        end;
    if i<0 then
      begin
        if (section = _smiles) and hasSmilePic then
         else
          begin
           section:=_null;
           continue;
          end;
      end
     else
      begin
        section:=TRQsection(i);
        continue;
      end;
    end;
  v:=line;
  k:=trim(chop('=',v));
  v:=trim(v);
  if k='include' then
   begin
     loadThemeScript(UnUTF(v), ts);
     continue;
   end;

  if section in [_smiles, _smile] then
   begin
   if useTSC in [tsc_all, tsc_smiles] then
   begin
     v := line;
     k := trim(chop(';', v));
     if isSupportedPicFile(UnUTF(k)) then
      begin
        if Assigned(loadedpic) then
          loadedPic.Free;
        loadedPic := NIL;
        NonAnimated := True;
        line := k;
        i := str2valor(chop(';', v));
        LastSmile := '';
//       loadedPic := TRnQBitmap.Create;
        if loadFile(ts, UnUTF(line), TStream(origPic)) then
          begin
           hasSmilePic := loadPic(TStream(origPic), loadedpic, i, PA_FORMAT_UNK, UnUTF(line), True);
           if hasSmilePic then
            begin
             NonAnimated := not loadedpic.Animated;
             if not NonAnimated then
              begin
               loadedAniPic := loadedpic;
    //           loadedpic := loadedAniPic.CloneFrame(-1);
               if (i < 1) or (i > loadedAniPic.NumFrames) then
                i := 1;
               loadedAniPic.CurrentFrame := i;
               loadedpic := loadedAniPic.CloneFrame(-1);
              end;
            end
            else
             begin
              FreeAndNil(origPic);
              msgDlg(getTranslation('Can''t load smile file: ') + UnUTF(line), False, mtError);
             end;
         end
        else
         begin
           if Assigned(origPic) then
              origPic.Free;
           msgDlg(getTranslation('Can''t load smile file: ') + UnUTF(line), false, mtError);
         end;
      end
    else
    if AnsiStartsText(AnsiString('@pics.'), k) then
      begin
       LastSmile := '';
       FreeAndNil(themePic);
       NonAnimated := True;
       themePic := parsePic(True, line);
       if assigned(themePic) then
        hasSmilePic := True;
//       loadedPic := TRnQBitmap.Create;
//       hasSmilePic := loadPic(ts, line, loadedpic, i);
//       addSmile(
      end
    else
     if hasSmilePic then
     begin
      i := -1;
      if LastSmile = '' then
       begin
//         LastSmile := line;
         LastSmile := par;
        {$IFDEF RNQ_FULL}
         if not NonAnimated then
           i := addprop(LastSmile, loadedAniPic)
          else
           if Assigned(loadedAniPic) then
             loadedAniPic.Free;
         loadedAniPic := NIL;
        {$ENDIF RNQ_FULL}
       end;
      if section = _smile then
       Parsed := True // делать Stretch дл€ смайликов
      else
       Parsed := false;
//      addProp(LastSmile, line, loadedPic, Parsed, not NonAnimated, i);
      addProp(LastSmile, string(par), loadedpic, origPic, themePic, Parsed, not NonAnimated, i);
      FreeAndNil(origPic);
      loadedPic := NIL;
//      FreeAndNil(loadedPic);
     {$IFDEF RNQ_FULL}
        if Assigned(loadedAniPic) then
          loadedAniPic.Free;
        loadedAniPic := NIL;
     {$ENDIF RNQ_FULL}
     end;
  	end;
    continue;
   end
  else // not in [_smiles, _smile]
//  if (section in [_pics, _icons]) then
  if (section in [_pics, _icons, _ico]) then
  begin
    FreeAndNil(themePic);
    themePic := parsePic(false, v);
    addProp(prefix + k, TP_pic, themePic);
    FreeAndNil(themePic);
  end
  else if section = _sounds then
   begin
    addProp(k, ts, TP_sound, fullpath(UnUTF(v)));
   end
  else if section = _str then
   begin
    addProp(k, ts, TP_string, UnUTF(ansiReplaceStr(v, AnsiString('\n'),CRLF)));
   end
  else if section = _desc then
   begin
    if desc > '' then
      desc := desc + CRLF;
    desc := desc  + UnUTF(ansiReplaceStr(line, AnsiString('\n'),CRLF));
//    v := GetString('desc', false) + CRLF + ansiReplaceStr(line,'\n',CRLF);
    addProp('desc', ts, TP_string, desc);
   end
  else if section = _fontfile then
   begin
    parseFontFile(v);
   end
  else
  if section = _null then
   begin
   parsed := false;
   k := AnsiLowerCase(k);
   i := Pos(AnsiString('.pic'), k);
    if i > 0 then
     begin
       prefix := copy(k, 1, i-1);
       if prefix = '' then
          par := param
        else
          if param > '' then
           par := param+'.'+prefix
          else
           par := prefix;
       begin
         FreeAndNil(themePic);
         themePic := parsePic(false, v);
         addProp(par, TP_pic, themePic);
         FreeAndNil(themePic);
//         FreeAndNil(loadedPic);
//         parsePic(v, loadedPic);
//         addProp(par, TP_pic, loadedPic);
//         FreeAndNil(loadedPic);
       end;
       parsed := True;
     end;
    i := Pos(AnsiString('font'), k);
    if i > 0 then
     begin
       prefix := copy(k, 1, i-2);
       if prefix = '' then
          par := param
        else
          if param = '' then
            par := prefix
           else
            par := param+'.'+prefix;
        if prefix = '' then
//         parsed := parseFont('font', k, v, loadedFontProp)
         parsed := parseFont('font', k, v, par)
        else
//         parsed := parseFont(prefix + '.font', k, v, loadedFontProp);
         parsed := parseFont(prefix + '.font', k, v, par);
     end;
    if parsed then
//     addProp(par, loadedFontProp)
    else
     if Pos(AnsiString('color'), k) > 0 then
      begin
       i := Pos(AnsiString('color'), k);
       prefix := copy(k, 1, i-2) + copy(k, i+5, length(k));
       if Length(param) > 0 then
         if Length(prefix) > 0 then
           par := param+'.'+prefix
          else
           par := param
        else
         par := prefix;
       addProp(par, str2color(v))
      end
     else
     if Pos(AnsiString('sound'), k) > 0 then
      begin
       i := Pos(AnsiString('sound'), k);
       prefix := copy(k, 1, i-2) + copy(k, i+5, length(k));
       if Length(param) > 0 then
         if Length(prefix) > 0 then
           par := param+'.'+prefix
          else
           par := param
        else
         par := prefix;
       addProp(par, ts, TP_sound, fullpath(UnUTF(v)));
      end
     else
      begin
       if Length(param) > 0 then
         if Length(k) > 0 then
           par := param+'.'+k
          else
           par := param
        else
         if Length(k) > 0 then
           par := k
          else
           par := v;
       addProp(par, ts, TP_string, UnUTF(ansiReplaceStr(v,AnsiString('\n'),CRLF)));
      end;
   end;
  except
  end;
  if Assigned(loadedpic) then
    loadedPic.Free;
  loadedPic := NIL;
  if Assigned(loadedAniPic) then
    loadedAniPic.Free;
  loadedAniPic := NIL;
//  FreeAndNil(LastLoadedPic);
end; // loadThemeScript

function TRQtheme.drawPic(DC: HDC; pX, pY:integer; const picName:TPicName; pEnabled : Boolean = true):Tsize;
var
  i : Integer;
//  gr : TGPGraphics;
//  ia : timage
//  pic : TRnQBitmap;

begin
{  pic := TRnQBitmap.Create;
  GetPic(picName, pic);
  result:=drawPic(cnv,x,y, pic);
  pic.Free;}
  i := FThemePics.IndexOf(AnsiLowerCase(picName));
  if i >= 0 then
   begin
     with TThemePic(FThemePics.Objects[i]) do
     if FBigPics[PicIDX].bmp <> nil then
     begin
       result.cx := r.Width;
       result.cy := r.Height;
       DrawRbmp(DC, FBigPics[PicIDX].bmp,
         makeRectI(pX, pY, result.cx, result.cy), r, pEnabled);
     end
   end
  else
    begin
      i := FIntPics.IndexOf(AnsiLowerCase(picName));
      if i >= 0 then
       begin
//         result.cx:=TRnQBitmap(FIntPics.Objects[i]).GetWidth;
//         result.cy:=TRnQBitmap(FIntPics.Objects[i]).GetHeight;
//         result.cx:= icon_size;
//         result.cy:= icon_size;
         ImageList_GetIconSize(FIntPicsIL, result.cx, result.cy);
         if pEnabled then
          ImageList_Draw(FIntPicsIL, i, DC, pX, pY, ILD_TRANSPARENT)
         else
          ImageList_Draw(FIntPicsIL, i, DC, pX, pY, ILD_TRANSPARENT or ILD_BLEND25);
//         gr := TGPGraphics.Create(cnv.Handle);
//         gr.DrawImage(TRnQBitmap(FIntPics.Objects[i]), x, y, icon_size, icon_size);
//         gr.Free;
       end
      else
        begin
          i := FSmilePics.IndexOf(picName);
          if i >= 0 then
           with TThemePic(FSmilePics.Objects[i]) do
           begin
             result.cx := r.Width;
             result.cy := r.Height;
             DrawRbmp(DC, TPicObj(FSmileBigPics[PicIDX]).bmp,
               MakeRectI(pX, pY, result.cx, result.cy), r, pEnabled);
           end
          else
             begin
               result.cx:=0;
               result.cy:=0;
    //          pic := TRnQBitmap.Create;
    //          pic.Height := 0;
    //          pic.Width  := 0;
    //          addProp(picName, TP_pic, pic);
    //          pic.Free;
             end
        end;
    end;
end;

function TRQtheme.drawPic(DC: HDC; pR: TGPRect; const picName:TPicName; pEnabled : Boolean = true):Tsize;
var
  i : Integer;
  r1 : TGPRect;
begin
  if Length(picName)=0 then
             begin
               result.cx:=0;
               result.cy:=0;
               Exit;
             end;
  i := FThemePics.IndexOf(AnsiLowerCase(picName));
  if i >= 0 then
   with TThemePic(FThemePics.Objects[i]) do
   if FBigPics[PicIDX].bmp <> nil then
   begin
//     result.cx := r.Width;
//     result.cy := r.Height;
     r1 := DestRect( r.size, pR.size);
     inc(r1.X, pR.X);
     inc(r1.Y, pR.Y);
     result := GetSize(pR.size);
     DrawRbmp(DC, FBigPics[PicIDX].bmp, R1, r, pEnabled);
   end else
  else
    begin
      i := FIntPics.IndexOf(AnsiLowerCase(picName));
      if i >= 0 then
       begin
//         result.cx:=TRnQBitmap(FIntPics.Objects[i]).GetWidth;
//         result.cy:=TRnQBitmap(FIntPics.Objects[i]).GetHeight;
//         result.cx:= icon_size;
//         result.cy:= icon_size;
         ImageList_GetIconSize(FIntPicsIL, result.cx, result.cy);
         if pEnabled then
          ImageList_Draw(FIntPicsIL, i, DC, pR.X, pR.Y, ILD_TRANSPARENT)
//          ImageList_DrawEx(FIntPicsIL, i, DC, pX, pY, ILD_TRANSPARENT)
         else
          ImageList_Draw(FIntPicsIL, i, DC, pR.X, pR.Y, ILD_TRANSPARENT or ILD_BLEND25)
//         gr := TGPGraphics.Create(cnv.Handle);
//         gr.DrawImage(TRnQBitmap(FIntPics.Objects[i]), x, y, icon_size, icon_size);
//         gr.Free;
       end
      else
        begin
          i := FSmilePics.IndexOf(picName);
          if i >= 0 then
           with TThemePic(FSmilePics.Objects[i]) do
           begin
//             result.cx := r.Width;
//             result.cy := r.Height;
             r1 := DestRect( r.size, pR.size);
             result := GetSize(pR.size);
             inc(r1.X, pR.X);
             inc(r1.Y, pR.Y);
             DrawRbmp(DC, TPicObj(FSmileBigPics[PicIDX]).bmp, R1, r, pEnabled);
           end
          else
             begin
               result.cx:=0;
               result.cy:=0;
    //          pic := TRnQBitmap.Create;
    //          pic.Height := 0;
    //          pic.Width  := 0;
    //          addProp(picName, TP_pic, pic);
    //          pic.Free;
             end
        end;
    end;
end;

  {$IFDEF USE_GDIPLUS}
function TRQtheme.drawPic(gr: TGPGraphics; x,y: integer; const picName: String; pEnabled: Boolean = true): Tsize;
var
  i : Integer;
//  pic : TRnQBitmap;
begin
{  pic := TRnQBitmap.Create;
  GetPic(picName, pic);
  result:=drawPic(cnv,x,y, pic);
  pic.Free;}
  i := FThemePics.IndexOf(AnsiLowerCase(picName));
  if i >= 0 then
   if TPicObj(FBigPics.Objects[TThemePic(FThemePics.Objects[i]).PicIDX]).bmp <> nil then
   begin
     result.cx := TThemePic(FThemePics.Objects[i]).Width;
     result.cy := TThemePic(FThemePics.Objects[i]).Height;
//     gr.DrawImage(TRnQBitmap(FGPpics.Objects[i]), x, y,result.cx, result.cy);
     gr.DrawImage(TPicObj(FBigPics.Objects[TThemePic(FThemePics.Objects[i]).PicIDX]).bmp,
       MakeRect(x, y, result.cx, result.cy),
//       x, y,
       TThemePic(FThemePics.Objects[i]).Left, TThemePic(FThemePics.Objects[i]).Top,
       result.cx, result.cy, UnitPixel);
//     gr.DrawImage(TRnQBitmap(FGPpics.Objects[i]), x, y, 0, 0,
//       result.cx, result.cy, UnitPixel);
   end else
  else
    begin
{      i := FIntPics.IndexOf(AnsiLowerCase(picName));
      if i >= 0 then
       begin
//         result.cx:=TRnQBitmap(FIntPics.Objects[i]).GetWidth;
//         result.cy:=TRnQBitmap(FIntPics.Objects[i]).GetHeight;
//         gr.DrawImage(TRnQBitmap(FIntPics.Objects[i]), x, y);
//         gr.DrawImage(TRnQBitmap(FIntPics.Objects[i]), x, y, 0, 0,
//           result.cx, result.cy, UnitPixel);
         result.cx:= icon_size;
         result.cy:= icon_size;
         imageList_
         if pEnabled then
          ImageList_Draw(FIntPicsIL, i, cnv.Handle, x, y, ILD_TRANSPARENT)
         else
          ImageList_Draw(FIntPicsIL, i, cnv.Handle, x, y, ILD_TRANSPARENT or ILD_BLEND);
         gr.DrawImage(TRnQBitmap(FIntPics.Objects[i]), x, y,result.cx, result.cy);
//         gr.DrawImage(TRnQBitmap(FIntPics.Objects[i]), x, y, 0, 0,
//           result.cx, result.cy, UnitPixel);
       end
      else                  }
         begin
           result.cx:=0;
           result.cy:=0;
//          pic := TRnQBitmap.Create;
//          pic.Height := 0;
//          pic.Width  := 0;
//          addProp(picName, TP_pic, pic);
//          pic.Free;
         end
    end;
end;
  {$ENDIF USE_GDIPLUS}

//function TRQtheme.drawPic(DC: HDC; x,y:integer; var picElm : TRnQThemedElementDtls):Tsize;
function TRQtheme.drawPic(DC: HDC; p :TPoint; var picElm : TRnQThemedElementDtls):Tsize;
var
  po : TPicObj;
  crd : Cardinal;
begin
   initPic(picElm);

  if picElm.picIdx = -1 then
          begin
            Result.cx := 0;
            Result.cy := 0;
            exit;
          end;
  case picElm.Loc of
   PL_pic:
    begin
//     TRnQBitmap(FGPpics.Objects[picIdx]).SetResolution(
     with TThemePic(FThemePics.Objects[picElm.picIdx]) do
      begin
       result.cx := r.Width;
       result.cy := r.Height;
       po := FBigPics[PicIDX];
//       if po is TPicObj then
       if Assigned(po) then
        begin
         DrawRbmp(DC, po.bmp,
//                 MakeRect(p.X, p.Y, result.cx, result.cy),
                 MakeRect(MakePoint(p), r.size),
                 R,
                 picElm.pEnabled);
        end;
      end;
    end;
   PL_int:
        begin
         if picElm.pEnabled then
           crd := ILD_TRANSPARENT
         else
           crd := ILD_TRANSPARENT or ILD_BLEND25;

         ImageList_Draw(FIntPicsIL, picElm.picIdx, DC, p.x, p.y, crd);
{
         gr := TGPGraphics.Create(cnv.Handle);
         gr.SetInterpolationMode(InterpolationModeHighQualityBicubic);
         gr.DrawImage(TRnQBitmap(FIntPics.Objects[picIdx]), x, y, icon_size, icon_size);
//         gr.DrawImage(TRnQBitmap(FIntPics.Objects[picIdx]), x, y);
         gr.Free;}
//         result.cx:= icon_size;
//         result.cy:= icon_size;
         ImageList_GetIconSize(FIntPicsIL, result.cx, result.cy);
//         result.cx:=TRnQBitmap(FIntPics.Objects[picIdx]).GetWidth;
//         result.cy:=TRnQBitmap(FIntPics.Objects[picIdx]).GetHeight;
        end;
   PL_Ani:
        begin
//         gr := TGPGraphics.Create(cnv.Handle);
//         gr.DrawImage(TRnQAni(FAniSmls.Objects[picIdx]), x, y);
//         gr.Free;
         with TRnQAni(FAniSmls.Objects[picElm.picIdx]) do
          begin
            Draw(DC, p.x, p.y);
            result.cx := Width;
            result.cy := Height;
          end;
        end;
   PL_Smile:
     with TThemePic(FSmilePics.Objects[picElm.picIdx]) do
      begin
       result.cx := r.Width;
       result.cy := r.Height;
       po := FSmileBigPics[PicIDX];
       if Assigned(po) then
        begin
         DrawRbmp(DC, po.bmp,
//                 MakeRect(p.X, p.Y, result.cx, result.cy),
                 MakeRect(MakePoint(p), r.size),
                 R,
                 picElm.pEnabled);
        end;
      end;
   else
          begin
            Result.cx := 0;
            Result.cy := 0;
          end;
  end
end;

function TRQtheme.drawPic(DC: HDC; pR: TGPRect; var picElm : TRnQThemedElementDtls):Tsize;
var
//  i : Integer;
  r1  : TGPRect;
  po  : TPicObj;
  crd : Cardinal;
begin
  initPic(picElm);

  if picElm.picIdx = -1 then
          begin
            Result.cx := 0;
            Result.cy := 0;
            exit;
          end;
  case picElm.Loc of
   PL_pic:
     with TThemePic(FThemePics.Objects[picElm.PicIDX]) do
     if FBigPics[PicIDX].bmp <> nil then
     begin
  //     result.cx := r.Width;
  //     result.cy := r.Height;
       r1 := DestRect( r.size, pR.size);

       result.cx := r1.X + r1.Width;
       result.cy := r1.Y + r1.Height;

//       inc(r1.X, pR.X);
//       inc(r1.Y, pR.Y);
       R1.TopLeft := pR.TopLeft;
//       result := tsize(r1.size);
       po := FBigPics[PicIDX];
//       if po is TPicObj then
       if Assigned(po) then
        begin
         DrawRbmp(DC, po.bmp,
//                 MakeRect(p.X, p.Y, result.cx, result.cy),
                 R1, R, picElm.pEnabled);
        end;
     end;
   PL_int:
     begin
//       result.cx := icon_size;
//       result.cy := icon_size;
       ImageList_GetIconSize(FIntPicsIL, result.cx, result.cy);
       r1 := DestRect(result.cx, result.cy, pR.Width, pR.Height);

       result.cx := r1.X + r1.Width;
       result.cy := r1.Y + r1.Height;
//       result.cx:= icon_size;
//       result.cy:= icon_size;

       inc(r1.X, pR.X);
       inc(r1.Y, pR.Y);

       if picElm.pEnabled then
         crd := ILD_TRANSPARENT
        else
         crd := ILD_TRANSPARENT or ILD_BLEND25;
//       ImageList_Draw(FIntPicsIL, picElm.picIdx, DC, pR.X, pR.Y, crd);
       ImageList_DrawEx(FIntPicsIL, picElm.picIdx, DC, r1.X, r1.Y, r1.Width, r1.Height, CLR_NONE, CLR_NONE, crd);
     end;
   PL_Ani:
        begin
//         gr := TGPGraphics.Create(cnv.Handle);
//         gr.DrawImage(TRnQAni(FAniSmls.Objects[picIdx]), x, y);
//         gr.Free;
         with TRnQAni(FAniSmls.Objects[picElm.picIdx]) do
          begin
            r1 := DestRect(Width, Height, pR.Width, pR.Height);
            inc(r1.X, pR.X);
            inc(r1.Y, pR.Y);
            Draw(DC, R1);
//            result.cx := Width;
//            result.cy := Height;
            result := GetSize(pR.size);
          end;
        end;
   PL_Smile:
     with TThemePic(FSmilePics.Objects[picElm.picIdx]) do
      begin
       result.cx := r.Width;
       result.cy := r.Height;
       po := FSmileBigPics[PicIDX];
       if Assigned(po) then
        begin
          r1 := DestRect(R.size, pR.size);
          result := GetSize(pR.size);
          inc(r1.X, pR.X);
          inc(r1.Y, pR.Y);
          DrawRbmp(DC, po.bmp, R1, r, picElm.pEnabled);
        end;
      end;
   else
          begin
            Result.cx := 0;
            Result.cy := 0;
          end;
   end;
end;

// To Get pic with Alpha channel
function TRQtheme.getPic(DC: HDC; p :TPoint; var picElm : TRnQThemedElementDtls; var is32Alpha : Boolean):Tsize;
var
  po : TPicObj;
begin
   initPic(picElm);

  if picElm.picIdx = -1 then
          begin
            Result.cx := 0;
            Result.cy := 0;
            exit;
          end;
  case picElm.Loc of
   PL_pic:
    begin
//     TRnQBitmap(FGPpics.Objects[picIdx]).SetResolution(
     with TThemePic(FThemePics.Objects[picElm.picIdx]) do
      begin
       result.cx := r.Width;
       result.cy := r.Height;
       po := FBigPics[PicIDX];
       if Assigned(po) then
//       if po is TPicObj then
        begin
         is32Alpha := po.bmp.f32Alpha;
//         GetBmp32(DC, po.bmp,
         DrawRbmp(DC, po.bmp,
//                 MakeRect(p.X, p.Y, result.cx, result.cy),
                 MakeRect(MakePoint(p), r.size),
                 R, picElm.pEnabled, True);
        end;
      end;
    end;
   else
          begin
            Result.cx := 0;
            Result.cy := 0;
          end;
  end

end;


  {$IFDEF USE_GDIPLUS}
function TRQtheme.drawPic(gr: TGPGraphics; x, y: integer; picName: string; var ThemeToken: Integer;
       var picLoc: TPicLocation; var picIdx: Integer; pEnabled: Boolean = true): Tsize;
var
 dc : HDC;
  ia : TGPImageAttributes;
// tb  : TRnQBitmap;
// tgr : TGPGraphics;
begin
   initPic(picName, ThemeToken, picLoc, picIdx);

  if picIdx = -1 then
          begin
            Result.cx := 0;
            Result.cy := 0;
            exit;
          end;
  case picLoc of
   PL_pic:
    begin
//     TRnQBitmap(FGPpics.Objects[picIdx]).SetResolution(
     result.cx := TThemePic(FThemePics.Objects[picIdx]).Width;
     result.cy := TThemePic(FThemePics.Objects[picIdx]).Height;
     if FBigPics.Objects[TThemePic(FThemePics.Objects[picIdx]).PicIDX] is TPicObj then
     begin
//     gr.DrawImage(TRnQBitmap(FGPpics.Objects[i]), x, y,result.cx, result.cy);
      DrawRbmp(gr, TPicObj(FBigPics.Objects[TThemePic(FThemePics.Objects[picIdx]).PicIDX]).bmp,
        MakeRect(x+1, y+1, result.cx, result.cy),
        TThemePic(FThemePics.Objects[picIdx]).Left, TThemePic(FThemePics.Objects[picIdx]).Top,
        result.cx, result.cy, pEnabled);
     end;
    end;
   PL_int:
        begin
//         tb := TRnQBitmap.Create(icon_size, icon_size, gr);
//         tgr := TGPGraphics.Create(tb);
         dc := gr.GetHDC;
         if pEnabled then
          ImageList_Draw(FIntPicsIL, picIdx, dc, x, y, ILD_TRANSPARENT)
         else
          ImageList_Draw(FIntPicsIL, picIdx, dc, x, y, ILD_TRANSPARENT or ILD_BLEND25);
//         gr.DrawImage(TRnQBitmap(FIntPics.Objects[picIdx]), x, y, icon_size, icon_size);
//         gr.DrawImage(TRnQBitmap(FIntPics.Objects[picIdx]), x, y);
         gr.ReleaseHDC(dc);
//         tgr.Free;
//         gr.DrawImage(tb, 0, 0, icon_size, icon_size);
//         tb.Free;
         result.cx:= icon_size;
         result.cy:= icon_size;
//         result.cx:=TRnQBitmap(FIntPics.Objects[picIdx]).GetWidth;
//         result.cy:=TRnQBitmap(FIntPics.Objects[picIdx]).GetHeight;
        end;
{   PL_Ani:
        begin
//         gr := TGPGraphics.Create(cnv.Handle);
//         gr.DrawImage(TRnQAni(FAniSmls.Objects[picIdx]), x, y);
//         gr.Free;
//         TRnQAni(FAniSmls.Objects[picIdx]).Draw(gr, x, y);
//         dc := gr.GetHDC;
//         TRnQAni(FAniSmls.Objects[picIdx]).Draw(dc, x, y);
//         gr.ReleaseHDC(dc);
         result.cx:=TRnQAni(FAniSmls.Objects[picIdx]).Width;
         result.cy:=TRnQAni(FAniSmls.Objects[picIdx]).Height;
        end;}
   else
          begin
            Result.cx := 0;
            Result.cy := 0;
          end;
  end
end;
  {$ENDIF USE_GDIPLUS}
{
function TRQtheme.drawPic(cnv:Tcanvas; x,y:integer; pic:TRnQBitmap):Tsize;
//var
//  b : Boolean;
begin
  if pic=NIL then exit;
//  b := pic.Transparent;
  cnv.draw(x,y,pic);
  result.cx:=pic.width;
  result.cy:=pic.height;
end; // drawPic
}

procedure TRQtheme.ClearThemelist;
  procedure Clear1ThemeList(var tl: aThemeinfo);
  var
   t : ToThemeinfo;
 {$IFNDEF DELPHI9_UP}
   i : Integer;
 {$ENDIF DELPHI_9_DOWN}
  begin
 {$IFDEF DELPHI9_UP}
   for t in tl do begin
 {$ELSE DELPHI_9_dn}
   for i := Low(tl) to High(tl) do begin
    t := tl[i];
 {$ENDIF DELPHI9_UP}
    begin
     SetLength(t.fn, 0);
     SetLength(t.subFile, 0);
     SetLength(t.title, 0);
     SetLength(t.desc, 0);
     SetLength(t.logo, 0);
     t.Free;
    end;
   end; 
   SetLength(tl, 0);
  end;
begin
 Clear1ThemeList(themelist2);
 Clear1ThemeList(smileList);
 Clear1ThemeList(soundList);
end;

procedure TRQtheme.refreshThemelist;
 procedure ProcessFile(Const fn, subfile : String; s : RawByteString);
 var
  line,k,v,section : RawByteString;
  procedure InternalprocessTheme(var ati : aThemeinfo);
  var
    n:integer;
  begin
      n := Length(ati);
      setlength(ati, n+1);
      ati[n] := ToThemeinfo.Create;
      ati[n].fn:=fn;
      ati[n].subFile:=subfile;
      section:='';
      while s>'' do
        begin
        line:=chopline(s);
        if (line>'') and (line[1]='[') then
          begin
          line:=trim(line);
          if line[length(line)]=']' then
            section:=copy(line,2,length(line)-2);
          continue;
          end;
        v:=trim(line);
        k:=AnsiLowerCase(trim(chop('=',v)));
        v:=trim(v);
        if section='' then
          begin
          if k='logo'  then ati[n].logo := UnUTF(v);
          if k='title' then ati[n].title:= UnUTF(v);
          if k='desc'  then ati[n].desc := ansiReplaceStr(UnUTF(v),'\n',CRLF);
          end;
        v := '';
        if section='desc' then
          with ati[n] do
            desc := desc+ UnUTF(line)+CRLF;
        end;
      with ati[n] do
        desc := trimright(desc);
  end;
 begin
     line := trim(chopline(s));
    if (line='&RQ theme file version 1')
       or (line='R&Q theme file version 1') then
     begin
      InternalprocessTheme(themelist2);
     end
    else
     if (line='R&Q smiles file version 1') then
     begin
      InternalprocessTheme(smileList);
     end;
     if (line='R&Q sounds file version 1') then
     begin
      InternalprocessTheme(soundList);
     end;
  end;
  procedure addDefTheme(var ati : aThemeinfo);
  var
    n:integer;
//  line,k,v,section : String;
  begin
      n := Length(ati);
      setlength(ati, n+1);
      ati[n] := ToThemeinfo.Create;
      ati[n].fn := '';
      ati[n].subFile := '';
      ati[n].title:= 'From theme';
  end;
var
  sr:TSearchRec;
  I, e : Integer;
//  str: TStringStream;
  str2: TMemoryStream;
  ts : TThemeSourcePath;
  fn : String;
  //subFile,
  sA : RawByteString;
  w:string;
//  theme_paths : array[0..1] of string;
  theme_paths : array[0..0] of string;
// for RAR
 {$IFDEF USE_RAR}
//  hArcData: THandle;
  RHCode, PFCode: Integer;
  CmtBuf: array[0..Pred(16384)] of Char;
  HeaderData: RARHeaderDataEx;
  OpenArchiveData: RAROpenArchiveDataEx;
  Operation: Integer;
{  IsDirectory : Boolean;}
  StreamPointer : Pointer;
 {$ENDIF USE_RAR}
  ti: Integer;
begin
  theme_paths[0] := fBasePath+themesPath;
//  theme_paths[1] := myPath; // For *.rtz
//  n:=0;
  ClearThemelist;
  addDefTheme(smileList);
  addDefTheme(soundList);
  for e := 0 to Length(ThemeInis) - 1 do
  begin
    if findFirst(theme_paths[0] +'*'+ThemeInis[e], faAnyFile, sr) = 0 then
      repeat
      if sr.name[1]<>'.' then
        begin
        fn:=sr.name;
        sA := loadFileA(theme_paths[0]+fn);
        processFile(fn, '', sA);
        end;
      until findNext(sr) <> 0;
     findClose(sr);
  end;
 {$IFDEF USE_ZIP}
 for ti := Low(theme_paths) to High(theme_paths) do
   for e := 0 to Length(ZipThemes) - 1 do
   begin
    if findFirst(theme_paths[ti]+'*'+ZipThemes[e], faAnyFile, sr) = 0 then
    repeat
    if sr.name[1]<>'.' then
      begin
        fn:=sr.name;
  //      zp := TKAZip.Create(NIL);
  //      zp.Open(myPath+themesPath+fn);
  //      if zp.IsZipFile > 0 then
        ts.zp := TZipFile.Create;
        ts.zp.LoadFromFile(theme_paths[ti] + fn);
        if ts.zp.Count > 0 then
         begin
  {        for I := 0 to zp.Entries.Count - 1 do
           if (LastDelimiter('\/:', zp.Entries.Items[i].FileName) <= 0)and
              (ExtractFileExt(zp.Entries.Items[i].FileName) = '.ini')  then}
          for I := 0 to ts.zp.Count - 1 do
          begin
           w := ts.zp.Name[i];
           if ( LastDelimiter('\/:', w) <= 0)and
              (RnQEndsText(ThemeInis[0], w)
               or RnQEndsText(ThemeInis[1], w)
               or RnQEndsText(ThemeInis[2], w))  then
  //            (ExtractFileExt(zp.Name[i]) = '.ini')  then
             begin
//              str := TStringStream.Create('');
  //            zp.ExtractToStream(zp.Entries.Items[i], str);
              sA := ts.zp.Data[i];
              processFile(fn, w, sA);
              sA := '';
             end;
          end;
          ts.zp.Free;
         end;
      end;
    until findNext(sr) <> 0;
    findClose(sr);
   end;
 {$ENDIF USE_ZIP}
 {$IFDEF USE_7Z}
//  '*.7z;*.7zip;*.rt7'
 try
//   ts.z7 := TSevenZip.Create(NIL);
//   ts.z7 := T7zInArchive.Create('7za.dll');
   ts.z7 := CreateInArchive(CLSID_CFormat7z);
  except
   ts.z7 := NIL;
 end;
 if Assigned(ts.z7) then
 for e := 0 to Length(SevenZipThemes) - 1 do
 begin
  if findFirst(theme_paths[0] +'*'+ SevenZipThemes[e], faAnyFile, sr) = 0 then
  repeat
  if sr.name[1]<>'.' then
    begin
      fn:=sr.name;
//      zp := TKAZip.Create(NIL);
//      zp.Open(myPath+themesPath+fn);
//      if zp.IsZipFile > 0 then
//      ts.z7.SZFileName := theme_paths[0] + fn;
//      zp.LoadFromFile(myPath+themesPath+fn);
      ts.z7.OpenFile(theme_paths[0] + fn);
      if ts.z7.NumberOfItems > 0 then
       begin
        for I := 0 to ts.z7.NumberOfItems - 1 do
        begin
//         w := ts.z7.Files.WStrings[i];
         w := ts.z7.getItemPath(i);
         if (LastDelimiter('\/:', w) <= 0)and
//            (ExtractFileExt(zp.Name[i]) = '.ini')
            (RnQEndsText(ThemeInis[0], w)
             or RnQEndsText(ThemeInis[1], w)
             or RnQEndsText(ThemeInis[2], w)) then
           begin
//            subFile := ;
//            str := TStringStream.Create('');
            str2 := TMemoryStream.Create();
            try
              ts.z7.ExtractItem(i, str2, false);
                if str2.Size > 0 then
                 begin
                  SetLength(sA, str2.Size);
                  CopyMemory(Pointer(sA), str2.Memory, Length(sA));
                  processFile(fn, w, sA);
                 end;
             finally
              sA := '';
              str2.Free;
            end;
           end;
        end;
        ts.z7.Close;
       end;
    end;
  until findNext(sr) <> 0;
  findClose(sr);
 end;
// FreeAndNil(ts.z7);
 ts.z7 := NIL;
 {$ENDIF USE_7Z}
 {$IFDEF USE_RAR}
//  '*.rar;*.rtr'
 for e := 0 to Length(RARThemes) - 1 do
 begin
  if findFirst(theme_paths[0] +'*'+ RARThemes[e], faAnyFile, sr) = 0 then
  repeat
  if sr.name[1]<>'.' then
    begin
     if not IsRARDLLLoaded then
       begin
//      if aRARGetDllVersion > 0 then
         LoadRarLibrary;
        if not IsRARDLLLoaded then
          break;
       end;
      fn:=sr.name;
        ts.pathType := pt_rar;
        ts.ArcFile := theme_paths[0] + fn;
        ts.path := '';
//        FillMemory(@OpenArchiveData.Reserved, SizeOf(OpenArchiveData.Reserved), 0);
        FillMemory(@OpenArchiveData, SizeOf(OpenArchiveData), 0);

 {$IFDEF UNICODE}
        OpenArchiveData.ArcName := '';
        OpenArchiveData.ArcNameW := PWideChar(ts.ArcFile);
 {$ELSE nonUNICODE}
        OpenArchiveData.ArcName := PAnsiChar(ts.ArcFile);
        OpenArchiveData.ArcNameW := '';
 {$ENDIF UNICODE}
        OpenArchiveData.CmtBuf := @CmtBuf;
        OpenArchiveData.CmtBufSize := SizeOf(CmtBuf);
//        OpenArchiveData.OpenMode := RAR_OM_LIST;
                OpenArchiveData.OpenMode := RAR_OM_EXTRACT;
        try
          ts.RarHnd := RAROpenArchiveEx(OpenArchiveData);
         except
           ts.RarHnd := 0;
           OpenArchiveData.OpenResult := MAXWORD;
        end;

        if (OpenArchiveData.OpenResult = 0) then
        begin
//          RARSetCallback (ts.RarHnd, CallbackProc, 0);
          FillMemory(@HeaderData, SizeOf(HeaderData), 0);
          HeaderData.CmtBuf := @CmtBuf;
          HeaderData.CmtBufSize := SizeOf(CmtBuf);

          repeat
            RHCode := RARReadHeaderEx(ts.RarHnd, HeaderData);
            if RHCode <> 0 then
              Break;
//            Write(CR, SFmt(HeaderData.FileName, 39), ' ',
//              (HeaderData.UnpSize + HeaderData.UnpSizeHigh * 4294967296.0):10:0);
{            IsDirectory := (HeaderData.Flags and $00000070) = $00000070; }
//            if not IsDirectory then
             begin
//              ListView1.AddItem(HeaderData.FileName, nil);
 {$IFDEF UNICODE}
               w := AnsiLowerCase(StrPas(HeaderData.FileNameW));
 {$ELSE ~UNICODE}
               w := AnsiLowerCase(StrPas(HeaderData.FileName));
 {$ENDIF ~UNICODE}
               if (LastDelimiter('\/:', w) <= 0)and
      //            (ExtractFileExt(zp.Name[i]) = '.ini')
                  RnQEndsText(ThemeInis[0], w)
                   or RnQEndsText(ThemeInis[1], w)
                   or RnQEndsText(ThemeInis[2], w) then
                 begin
                    Operation := RAR_TEST;
                 end
               else
                    Operation := RAR_SKIP;
             end;
//            if (HeaderData.CmtState = 1) then
//              ShowComment(CmtBuf);
//                  if loadfile(ts, w, TStream(str)) then
//                  if ts.z7.ExtractToStreamF(i, str) >= 0 then
            if Operation = RAR_TEST then
              begin
               str2 := TMemoryStream.Create();
               StreamPointer := @str2;
              end
             else
               StreamPointer := NIL; 
            try
              RARSetCallback (ts.RarHnd, RARCallbackProc, Integer (StreamPointer));
              PFCode:= RARProcessFile(ts.RarHnd, Operation, nil, nil);
              if (PFCode <> 0) then
              begin
  //              OutProcessFileError(PFCode);
                continue;
              end;
              if Operation = RAR_TEST then
               begin
                if str2.Size > 0 then
                 begin
                  SetLength(sA, str2.Size);
                  CopyMemory(Pointer(sA), str2.Memory, Length(sA));
                  processFile(fn, w, sA);
                 end;
               end;
            finally
             if Operation = RAR_TEST then
               str2.Free;
            end;  
          until False;

//          if (RHCode = ERAR_BAD_DATA) then
//            Write(CR, 'File header broken');

          RARCloseArchive(ts.RarHnd);
        end;
          ts.RarHnd := 0;
//       end;
    end;
  until findNext(sr) <> 0;
  findClose(sr);
// end;
   if IsRARDLLLoaded then
     UnLoadRarLibrary;
 end;
 ts.RarHnd := 0;
 {$ENDIF USE_RAR}
end; // refreshThemelist

 {$IFNDEF RNQ_LITE}
procedure TRQtheme.getprops(var PropList : aTthemeProperty);
var
  i, l : Integer;
  tp : TthemeProperty;
begin
{  for i := 0 to FFonts.Count-1 do
    begin
      tp.kind := TP_font;
      tp.section := RQsectionLabels[_null];
      tp.name := FFonts.Strings[i] + '.font';
      l := Length(PropList);
      SetLength(PropList, l+1);
      PropList[l] := tp;
    end;
}
  for i := 0 to FFonts2.Count-1 do
    begin
      tp.kind := TP_font;
      tp.section := RQsectionLabels[_null];
      tp.name := FFonts2.Strings[i] + '.font';
      l := Length(PropList);
      SetLength(PropList, l+1);
      PropList[l] := tp;
    end;
  for i := 0 to FClr.Count-1 do
    begin
      tp.kind := TP_color;
      tp.section := RQsectionLabels[_null];
      tp.name := FClr.Strings[i] + '.color';
      l := Length(PropList);
      SetLength(PropList, l+1);
      PropList[l] := tp;
    end;
  for i := 0 to FSounds.Count-1 do
    begin
      tp.kind := TP_sound;
      tp.section := RQsectionLabels[_sounds];
      tp.name := FSounds.Strings[i];
      l := Length(PropList);
      SetLength(PropList, l+1);
      PropList[l] := tp;
    end;
  for i := 0 to FThemePics.Count-1 do
    begin
      tp.kind := TP_pic;
      tp.section := RQsectionLabels[_pics];
      tp.name := FThemePics.Strings[i];
      l := Length(PropList);
      SetLength(PropList, l+1);
      PropList[l] := tp;
    end;
  for i := 0 to FIntPics.Count-1 do
    begin
      tp.kind := TP_ico;
      tp.section := RQsectionLabels[_icons];
      tp.name := FIntPics.Strings[i];
      l := Length(PropList);
      SetLength(PropList, l+1);
      PropList[l] := tp;
    end;
{    FSmiles : TStringList;
    FStr : TStringList;}
  for i := 0 to FStr.Count-1 do
    begin
      tp.kind := TP_string;
      tp.section := RQsectionLabels[_str];
      tp.name := FStr.Strings[i];
      l := Length(PropList);
      SetLength(PropList, l+1);
      PropList[l] := tp;
    end;
end;
 {$ENDIF RNQ_LITE}

{$IFDEF RNQ_FULL}
function TRQtheme.addProp(name:AnsiString; pic: TRnQAni) : Integer;
//var
//  Index: Integer;
begin
  result := FAniSmls.Add(name);
  FAniSmls.Objects[result] := pic;
  with TRnQAni(FAniSmls.Objects[result]) do
  begin
    CurrentFrame := 1;
  end;
 useAnimated := True;
// result :=index;
end;
{
function TRQtheme.addProp(name:string; pic: TRnQBitmap) : Integer;
//var
//  Index: Integer;
begin
//  Index:= Length(FsmlList);
//  SetLength(smlList, Index+1);
  result := FAniSmls.Add(name);
  TRnQAni
  pic.SelectActiveFrame(FrameDimensionTime, 0);
  FAniSmls.Objects[result] := pic;
  with TRnQAni(FAniSmls.Objects[result]) do
  begin
    Visible:= true;
//    Animate:= true;
    ShowIt:= true;
    CurrentFrame := 1;
  end;
 useAnimated := True;
// result :=index;
end;}


function  TRQtheme.GetAniPic(idx : integer) : TRnQAni;
//var
//  i : Integer;
begin
//  i := FAnismls.IndexOf(AnsiLowerCase(name));
//  if i >= 0 then
//   begin
  try
    result := TRnQAni(FAnismls.Objects[idx]);
  except
    result := NIL;
  end;
//   end
end;



procedure TRQtheme.checkAnimationTime;
var
 I: Integer;
begin
//  for I:= 0 to Count-1 do
  for I:= 0 to FAniSmls.Count-1 do
   TRnQAni(FAniSmls.Objects[I]).RnQCheckTime;
end;

 {$IFDEF SMILES_ANI_ENGINE}
procedure TRQtheme.TickAniTimer(Sender: TObject);
var
  i: Integer;
//  bmp, b1: TRnQBitmap;
  b2 : TBitmap;
  b2DC : HDC;
  paramSmile: TAniPicParams;
//  gr, grb : TGPGraphics;
//  br : TGPBrush;
begin
//  if not UseAnime then Exit;

  checkAnimationTime;
 (*
  if Length(FAniParamList) > 0 then
  begin
    for i:= 0 to Length(FAniParamList)-1 do
    begin
      if FAniDrawCnt = 0 then Exit;
      if (paramSmile.Bounds.Left = 0) and (paramSmile.Bounds.Top = 0)
        then Continue;

      paramSmile:= FAniParamList[i];
      InvalidateRect(chatFrm.ThisChat.historyBox.Handle, @paramSmile.Bounds, false);
    end;
  end;

  (*)
//  tmp_sml := NIL;
//  for i := Low(items) to High(items) do
//   if items[i].
  if Length(FAniParamList) > 0 then
  begin
    b2 := createBitmap(1, 1);
    b2.Height := 0;
    for i:= 0 to Length(FAniParamList)-1 do
   //for i:= Length(smlList)-1 to 0 do
    begin
      if (FAniDrawCnt = 0)or not useAnimated then
        Exit;
      if (paramSmile.Bounds.X = 0) and (paramSmile.Bounds.Y = 0)
      //наложение на верхние стрелки
        then
          Continue;

{      //наложение на нижние стрелки
      if hasDownArrow then
        if paramSmile.Bounds.Bottom > (Height - hDownArrow)
          then Continue;
 }
//      if (i > Low(FAniParamList)) and (i < High(FAniParamList)) then
      paramSmile:= FAniParamList[i];
//      if paramSmile <> nil then
//      if paramSmile.ID = -1 then Continue;
     if Assigned(paramSmile.Canvas) then
      if paramSmile.idx >= 0 then
      begin
//        gr := TGPGraphics.Create(paramSmile.Canvas.Handle);
//        if gr.IsVisible(MakeRect(paramSmile.Bounds)) then
        with GetAniPic(paramSmile.Idx) do
        begin
//         bmp:= TRnQBitmap.Create(Width, Height, PixelFormat32bppRGB);
           if (b2.Width <> Width)or
              (b2.Height <> Height) then
            begin
             b2.Height := 0;
           {$IFDEF DELPHI9_UP}
             b2.SetSize(Width, Height);
           {$ELSE DELPHI_9_dn}
             b2.Width := Width;
             b2.Height := Height;
           {$ENDIF DELPHI9_UP}
            end;
           b2DC := b2.Canvas.Handle;
{          if Assigned(paramSmile.bg) then
           BitBlt(bmp.Canvas.Handle, 0, 0,
            bmp.Width, bmp.Height, paramSmile.bg.Canvas.Handle, 0, 0, SRCCOPY)
          else}
//          grb := TGPGraphics.Create(b2.Canvas.Handle);
//          grb.Clear(aclBlack);
//          grb := TGPGraphics.c
{          if Assigned(AnibgPic) and (not paramSmile.selected) then
            grb.DrawImage(AnibgPic, 0, 0,
             paramSmile.Bounds.Left, paramSmile.Bounds.Top,
             Width, Height, UnitPixel)
           else
            begin
             grb.Clear(paramSmile.color);
//             br := TGPSolidBrush.Create(paramSmile.color);
//             grb.FillRectangle(br, 0, 0, Width, Height);
//             br.Free;
            end;
}
          if Assigned(AnibgPic) and (not paramSmile.selected) then
            BitBlt(b2DC, 0, 0, b2.Width, b2.Height,
                   AnibgPic.Canvas.Handle,
              paramSmile.Bounds.X, paramSmile.Bounds.Y, SRCCOPY)
           else
           begin
             b2.Canvas.Brush.Color := paramSmile.color;
             b2.Canvas.FillRect(b2.Canvas.ClipRect);
           end;

//           b1 := GeTRnQBitmap;
//           b1.SelectActiveFrame(FrameDimensionTime, CurrentFrame-1);

//           Draw(grb, 0, 0);
//            grb.DrawImage(b1, 0, 0);
//           b1.Free;
//           grb.Free;
           Draw(b2DC, 0, 0);
//           BitBlt()
//          paramSmile.Canvas.FillRect(paramSmile.Bounds);
//          Draw(paramSmile.Canvas, paramSmile.Bounds.Left, paramSmile.Bounds.Top);
//          bmp.Transparent := True;
//          bmp.TransparentMode := tmAuto;
        end;

//        if paramSmile.Canvas.HandleAllocated then
//         try
//           if chat
//        gr.DrawImage(bmp, paramSmile.Bounds.Left, paramSmile.Bounds.Top);
//        gr.DrawImage(bmp, MakeRect(paramSmile.Bounds));

//        gr.Free;
          if Assigned(paramSmile.Canvas)
//           and (paramSmile.Canvas.HandleAllocated )
          then
//           BitBlt(paramSmile.Canvas.Handle, paramSmile.Bounds.Left, paramSmile.Bounds.Top,
//            bmp.Width, bmp.Height, paramSmile.bg.Canvas.Handle, 0, 0, SRCCOPY);
//           TransparentBlt(paramSmile.Canvas.Handle, paramSmile.Bounds.Left, paramSmile.Bounds.Top,
//            bmp.Width, bmp.Height, bmp.Canvas.Handle, 0, 0,
//            bmp.Width, bmp.Height, bmp.TransparentColor);   {LDB}

           BitBlt(paramSmile.Canvas.Handle, paramSmile.Bounds.X, paramSmile.Bounds.Y,
            b2.Width, b2.Height, b2DC, 0, 0, SRCCOPY);
//          paramSmile.Canvas.Draw(paramSmile.Bounds.Left,
//                      paramSmile.Bounds.Top, bmp);
//         except
//         end;
{        for j:= 0 to paramSmile.Count-1 do
        begin
          Canvas.Draw((paramSmile.Bounds.Left - j*tmp_sml.Width),
                      (paramSmile.Bounds.Top), tmp_sml);
        end;
}
      end;
    end;
    b2.Free;
  end;
end;

procedure TRQtheme.AddAniParam( PicIdx: Integer; Bounds: TGPRect;
              Color: TColor; cnv, cnvSrc: TCanvas; Sel: Boolean = false);
begin
  Inc(FAniDrawCnt);
  SetLength(FAniParamList, FAniDrawCnt);
  FAniParamList[FAniDrawCnt-1].idx := PicIdx;
  FAniParamList[FAniDrawCnt-1].Bounds := Bounds;
  FAniParamList[FAniDrawCnt-1].Color := Color;
  FAniParamList[FAniDrawCnt-1].canvas := cnv;
  FAniParamList[FAniDrawCnt-1].selected := sel;
//  GetAniPic(PicIdx).Animate := True;

{  if Anipicbg then
   begin
     FAniParamList[FAniDrawCnt-1].bg := TRnQBitmap.Create;
     with FAniParamList[FAniDrawCnt-1].bg do
     begin
       Height := Bounds.Bottom - Bounds.Top;
       Width  := Bounds.Right - Bounds.Left;
       BitBlt(Canvas.Handle, 0, 0, Width, Height, cnvSrc.Handle,
              Bounds.Left, Bounds.Top, SRCCOPY)
     end;
   end
  else
    FAniParamList[FAniDrawCnt-1].bg := NIL;}
  if not FAniTimer.Enabled then
    FAniTimer.Enabled := true;
end;

procedure TRQtheme.ClearAniParams;
//var
// i : Integer;
begin
  FAniDrawCnt:= 0;
  SetLength(FAniParamList,0);
{  for i := 1 to FAniSmls.Count-1 do
  begin
    GetAniPic(i).Animate := False;
  end;
}
  if Assigned(FAniTimer) then
    FAniTimer.Enabled := false;
end;

procedure TRQtheme.ClearAniMNUParams;
//var
// i : Integer;
begin
{  FAniDrawMNUCnt:= 0;
  SetLength(FAniMNUParamList,0);
  for i := 1 to FAniSmls.Count-1 do
  begin
    GetAniPic(i).Animate := False;
  end;
  if Assigned(FAniTimer) then
    FAniTimer.Enabled := false;}
end;
 {$ENDIF SMILES_ANI_ENGINE}

{$ENDIF RNQ_FULL}

procedure TRQtheme.initThemeIcons;
//var
//†i: HICON;
//  ic : TIcon;
//  icn : TMsgDlgType;
//  i : byte;
//  hi: HICON;
begin
//   ic := TIcon.Create;
//   for icn in TMsgDlgTypes do
//   for i := Low(TMsgDlgType)
//    begin
//     ic.handle := LoadIcon(0, IconIDs[icn]);
//     addprop(IconNames[icn], ic, true);
//    end;
//   FIntPics.Objects[FIntPics.Add(PIC_EXCLAMATION)] := TRnQBitmap.Create(0, PWidechar(IDI_EXCLAMATION));
   addHIco(PIC_EXCLAMATION, LoadIcon(0, IDI_EXCLAMATION), true);
   addHIco(PIC_HAND, LoadIcon(0, IDI_HAND), true);
   addHIco(PIC_ASTERISK, LoadIcon(0, IDI_ASTERISK), true);
   addHIco(PIC_QUEST, LoadIcon(0, IDI_QUESTION), true);
{

   ic.Handle := LoadIcon(0, IDI_EXCLAMATION);
   addprop(PIC_EXCLAMATION, LoadIcon(0, IDI_EXCLAMATION), true);
//   addprop(PIC_EXCLAMATION, ic, true);
//   DestroyIcon(h);
   ic.Handle := LoadIcon(0, IDI_HAND);
   addprop(PIC_HAND, ic, true);
   ic.Handle := LoadIcon(0, IDI_ASTERISK);
   addprop(PIC_ASTERISK, ic, true);
   ic.Handle := LoadIcon(0, IDI_QUESTION);
   addprop(PIC_QUEST, ic, true);
//   ic.Handle := LoadIcon(0, IDI_WARNING);
//   addprop(PIC_WARNING, ic, true);
//   ic.Handle := LoadIcon(0, IDI_ERROR);
//   addprop(PIC_ERROR, ic, true);
   ic.Free;
}
end;



  {$IFNDEF USE_GDIPLUS}
procedure TRQtheme.drawTiled(canvas: Tcanvas; const picName: TPicName);
var
  bmp : TBitmap;
  Hdl : HBrush;
begin
 bmp := TBitmap.Create;
 if GetPicOld(picName, bmp) then
 begin
  Hdl := CreatePatternBrush(bmp.Handle);
  canvas.Lock;
   windows.FillRect(canvas.Handle, canvas.ClipRect, Hdl);
  canvas.Unlock;
  DeleteObject(Hdl);
 end;
 Bmp.Free;
end;
  {$ENDIF USE_GDIPLUS}

  {$IFDEF USE_GDIPLUS}
procedure TRQtheme.drawTiled(canvas: Tcanvas; const picName: TPicName);
var
  gr : TGPGraphics;
//  bmp : TRnQBitmap;
//  Handle : HBrush;
  r  : TGPRectF;
begin
 r.X := 0; r.Y := 0;
 r.Width := canvas.ClipRect.Right;
 r.Height := canvas.ClipRect.Bottom;
 gr :=TGPGraphics.Create(canvas.Handle);
 drawTiled(gr, r, picName);
 gr.Free;
end;

procedure TRQtheme.drawTiled(gr:TGPGraphics; r : TGPRectF; const picName : TPicName);
var
  bmp : TGPImage;
//  ia  : TGPImageAttributes;
//  br  : TGPTextureBrush;
  br  : TGPBrush;
//  Handle : HBrush;
begin
// bmp := TRnQBitmap.Create;
 bmp := nil;
 FdrawCS.Acquire;
 try
  if getPic13(picName, bmp) then
  begin
 //  ia := TGPImageAttributes.Create;
 //  ia.SetWrapMode(WrapModeTile);
 //  gr.DrawImage(bmp, r, 0, 0 , bmp.GetWidth, bmp.GetHeight, UnitPixel, ia);
 //  ia.Free;
   try
    br := TGPTextureBrush.Create(bmp);//, WrapModeTile);
 //  br := TGPLinearGradientBrush.Create(r, aclAliceBlue, aclLightCyan, 0);
    gr.FillRectangle(br, r);
    br.Free;
   except

   end;
  end;
 finally
  FdrawCS.Release;
 end;
// Bmp.Free;
end;

procedure TRQtheme.drawStratch(gr:TGPGraphics; r : TGPRectF; const picName : TPicName);
var
  bmp : TGPImage;
//  br  : TGPTextureBrush;
//  Handle : HBrush;
begin
// bmp := TRnQBitmap.Create;
 bmp := nil;
 if getPic13(picName, bmp) then
 begin
  gr.DrawImage(bmp, r);
//  br := TGPTextureBrush.Create(bmp);//, WrapModeTile);
//  gr.FillRectangle(br, r);
//  br.Free;
//  Handle := CreatePatternBrush(bmp.Handle);
//  windows.FillRect(canvas.Handle, canvas.ClipRect, Handle);
//  DeleteObject(Handle);
 end;
// Bmp.Free;
end;

procedure TRQtheme.drawStratch(gr:TGPGraphics; x, y, w, h : Integer; const picName : TPicName);
var
  bmp : TGPImage;
//  br  : TGPTextureBrush;
//  Handle : HBrush;
begin
// bmp := TRnQBitmap.Create;
 bmp := nil;
 if getPic13(picName, bmp) then
 begin
  gr.DrawImage(bmp, x, y, w, h);
 end;
end;
  {$ENDIF USE_GDIPLUS}

procedure TRQtheme.drawTiled(dc: HDC; ClipRect : TRect; const picName : TPicName);
//var
//  br : TBrush;
begin
{  br := TBrush.Create;
  br.bitmap := TRnQBitmap.Create;
  getPic13(picName, br.bitmap);
//  FillRect(dc, trect(0, 0, 5, 5), br.)
  FillRect(dc, ClipRect, br.Handle);
//  fillRect(clipRect);
//  Windows.FillRect(Handle, ClipRect, Brush.GetHandle);
  br.bitmap.Free;
  br.free;}
end;

//var
// wallThTkn : Integer;
// wallImgLoc : TPicLocation;
// wallImgIdx : Integer;

  {$IFNDEF USE_GDIPLUS}
procedure TRQtheme.Draw_wallpaper(DC: HDC; r: TRect);
var
//  bmp : TRnQBitmap;
  Hbr : HBrush;
begin
 begin
//   if theme.GetPicSize(PIC_WALLPAPER).cx = 0 then exit;
//   GDIPlus.Brush := NewGPTextureBrush(theme.getGPimage(WALLPAPER))
//   GDIPlus.FillRectangle(canvas.ClipRect);
//  drawTiled(canvas, PIC_WALLPAPER)
   Hbr := theme.GetBrush(PIC_WALLPAPER);
//   if Hbr = 0 then
{     begin
      bmp := TRnQBitmap.Create;
      if getPic13(PIC_WALLPAPER, bmp, false) then
       Hbr := CreatePatternBrush(bmp.Handle);
     end}
//    else
//      bmp := NIL;
   if Hbr > 0 then
   begin
//    drawTiled(canvas, bmp);
    windows.FillRect(DC, r, Hbr);
    DeleteObject(Hbr);
   end;
//   if Assigned(bmp) then
//     Bmp.Free;

 end;
end; // wallpaperize

 {$ELSE USE_GDIPLUS}
procedure TRQtheme.Draw_wallpaper(DC : HDC; r : TRect);
var
//  bmp : TRnQBitmap;
//  Hbr : HBrush;
  gr : TGPGraphics;
//  bmp : TRnQBitmap;
//  Handle : HBrush;
  r1  : TGPRectF;
begin
 r1.X := r.Left; r1.Y := r.Top;
 r1.Width := r.Right - r.Left;
 r1.Height := r.Bottom - r.Top;
//   if theme.GetPicSize(PIC_WALLPAPER).cx = 0 then exit;
//   GDIPlus.Brush := NewGPTextureBrush(theme.getGPimage(WALLPAPER))
//   GDIPlus.FillRectangle(canvas.ClipRect);
  gr :=TGPGraphics.Create(dc);
  drawTiled(gr, r1, PIC_WALLPAPER);
  gr.Free;
end; // wallpaperize
  {$ENDIF NOT USE_GDIPLUS}
{
function TRQtheme.GetPicRGN(picName:string; var ThemeToken : Integer;
        var picLoc : TPicLocation; var picIdx : Integer):HRGN;
var
  bmp : TRnQBitmap;
  Hbr : HBrush;
  gr  : TGPGraphics;
  r   : TGPRegion;
//  bmp : TRnQBitmap;
//  Handle : HBrush;
  r1  : TGPRectF;
begin
//  if ThemeToken <> curToken then
   initPic(picName, ThemeToken, picLoc, picIdx);

  if picIdx = -1 then
          begin
            Result := 0;
            exit;
          end;
  case picLoc of
   PL_pic:
    begin
         gr := TGPGraphics.Create(TRnQBitmap(FGPpics.Objects[picIdx]));
         r := TGPRegion.Create;
         result := r.GetHRGN(gr);
         r.Free;
         gr.Free;
    end;
(*   PL_int:
        begin
         gr := TGPGraphics.Create(TRnQBitmap(FIntPics.Objects[picIdx]));
         r := TGPRegion.Create;
         result := r.GetHRGN(gr);
         r.Free;
         gr.Free;
        end;
(*   PL_Ani:
        begin
//         gr := TGPGraphics.Create(cnv.Handle);
//         gr.DrawImage(TRnQAni(FAniSmls.Objects[picIdx]), x, y);
//         gr.Free;
(*         TRnQAni(FAniSmls.Objects[picIdx]).Draw(cnv, x, y);
         gr := TGPGraphics.Create(TRnQAni(FAniSmls.Objects[picIdx]).);
         r := TGPRegion.Create;
         result := r.GetHRGN(gr);
         r.Free;
         gr.Free;*)
         result := 0 
        end;   *)
   else
          begin
           result := 0
          end;
  end
end;
}

  {$IFDEF USE_GDIPLUS}
procedure drawdisabled(bmp: TRnQBitmap; gr: TGPGraphics; x, y: Integer);
var
  FMonoBitmap : TRnQBitmap;
  ia   : TGPImageAttributes;
  fgr  : TGPGraphics;
  cm   : TColorMatrix;
  cm2   : TColorMatrix;
  i, j, w, h : Integer;
begin
  w := bmp.GetWidth;
  h := bmp.GetHeight;
//        FMonoBitmap := TRnQBitmap.Create(w, h, PixelFormat1bppIndexed);
        FMonoBitmap := TRnQBitmap.Create(w, h, PixelFormat32bppARGB);
      { Store masked version of image temporarily in FBitmap }
      fgr := TGPGraphics.Create(FMonoBitmap);
      ia := TGPImageAttributes.Create;
//      ia.SetColorKey(0, 0);
      for i := 0 to 2 do
        begin
         cm[0][i] := 0.3;
         cm[1][i] := 0.59;
         cm[2][i] := 0.11;
         cm[3][i] := 0;
         cm[4][i] := 0;
//         cm[i][0] := 0.3;
//         cm[i][1] := 0.3;
//         cm[i][2] := 0.3;
//         cm[i][3] := 0;
//         cm[i][4] := 0;
        end;
      for i := 3 to 4 do
       for j := 0 to 4 do
        begin
         cm[j][i] := 0;
         cm2[j][i] := 0;
//         cm[i][j] := 0;
        end;
      for i := 0 to 2 do
        begin
         cm2[0][i] := 0.5*0.3;
         cm2[1][i] := 0.5*0.59;
         cm2[2][i] := 0.5*0.11;
         cm2[3][i] := 0;
         cm2[4][i] := 0;
//         cm[i][0] := 0.3;
//         cm[i][1] := 0.3;
//         cm[i][2] := 0.3;
//         cm[i][3] := 0;
//         cm[i][4] := 0;
        end;
      cm[3][3] := 1;
      cm2[3][3] := 0.5;
      fgr.Clear(aclTransparent);
//      FMonoBitmap.se
//      fgr.
//      FMonoBitmap.Canvas.Brush.Color := clWhite;
//      FMonoBitmap.Canvas.FillRect(Rect(0, 0, Self.Width, Self.Height));
      fgr.DrawImage(bmp, 0, 0, w, h);
//      ImageList_DrawEx(Handle, Index, FMonoBitmap.Canvas.Handle, 0,0,0,0,
//        CLR_NONE, 0, ILD_NORMAL);
      fgr.Free;
      ia.SetColorMatrix(cm2);
      gr.DrawImage(FMonoBitmap, MakeRect(x+1, y+1, w, h), 0, 0, w, h, UnitPixel, ia);
      ia.SetColorMatrix(cm);
      gr.DrawImage(FMonoBitmap, MakeRect(x, y, w, h), 0, 0, w, h, UnitPixel, ia);
//      gr.DrawImage(FMonoBitmap, x, y, w, h);
      ia.Free;
      FMonoBitmap.Free;
(*      R := Rect(X, Y, X+Width, Y+Height);
      SrcDC := FMonoBitmap.Canvas.Handle;
      { Convert Black to clBtnHighlight }
      Canvas.Brush.Color := clBtnHighlight;
      DestDC := Canvas.Handle;
      Windows.SetTextColor(DestDC, clWhite);
      Windows.SetBkColor(DestDC, clBlack);
      BitBlt(DestDC, X+1, Y+1, Width, Height, SrcDC, 0, 0, ROP_DSPDxax);
      { Convert Black to clBtnShadow }
      Canvas.Brush.Color := clBtnShadow;
      DestDC := Canvas.Handle;
      Windows.SetTextColor(DestDC, clWhite);
      Windows.SetBkColor(DestDC, clBlack);
      BitBlt(DestDC, X, Y, Width, Height, SrcDC, 0, 0, ROP_DSPDxax);
*)
end;
  {$ENDIF USE_GDIPLUS}

{function TE2Str(pTE : TRnQThemedElement) : TPicName;
begin
  case pTE of
    RQteButton: Result := TPicName('button.');
    RQteMenu: Result := 'menu.';
    RQteTrayNotify: Result := 'tray.';
    RQteFormIcon: Result := 'formicon.';
   else
     Result := '';
  end;
end;}


initialization

  theme := TRQtheme.Create;
//  RQSmiles := TRQtheme.Create;
//  RQSmiles.supSmiles := True;
  if (csDesigning in Application.ComponentState) then
   begin
     logpref.evts.onfile := True;
     loggaEvtS('default theme loading', '', True);
     theme.load('', '', True);
   end;

finalization

//  loggaEvt('Before theme unloading', '', True);

  theme.Free;
  theme := NIL;
  loggaEvtS('Theme unloaded', '', True);

//  RQSmiles.free;
//  RQSmiles := NIL;


end.

