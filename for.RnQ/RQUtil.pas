{
  This file is part of R&Q.
  Under same license
}
(* $IMPORTEDDATA ON *)
unit RQUtil;
{$I ForRnQConfig.inc}
{$I NoRTTI.inc}

interface
 uses
   Windows, Graphics, Classes, //ExtCtrls,
   Controls, UITypes,
 {$IFDEF UNICODE}
   AnsiStrings, AnsiClasses,
 {$ENDIF UNICODE}
  {$IFNDEF NOT_USE_GDIPLUS}
    RnQGraphics,
  {$ELSE}
    RnQGraphics32,
  {$ENDIF NOT_USE_GDIPLUS}
   RDGlobal,
   RnQDialogs,
   Forms;

//type
//  TMsgDlgType = (mtWarning, mtError, mtInformation, mtConfirmation, mtCustom);



  function  str2html(const s: String): String;
  function  strFromHTML(const s: String): String; OverLoad;
  function  strFromHTML(const s: RawByteString): RawByteString; OverLoad;

  function  str2fontstyle(const s: AnsiString): Tfontstyles;
  function  fontstyle2str(fs: Tfontstyles): AnsiString;

  function  dateTocoolstr(d: Tdatetime): String;
  function  datetimeToStrMinMax(dt: Tdatetime; min: Tdatetime; max: Tdatetime): String;

  procedure showForm(frm: Tform); overload;

  function absPath(const fn: String): boolean;
  function ExtractFileNameOnly(const fn : String) : String;

  procedure msgDlg(msg: String; NeedTransl: Boolean; kind: TMsgDlgType; const uid: String = '');
  function logTimestamp: String;

  procedure drawTxt(hnd: Thandle; x, y: integer; const s: String);
  procedure drawTxtL(hnd: Thandle; x, y: integer; const s: PChar; L: integer);
  function  txtSize(hnd: Thandle; const s: String): Tsize;
  function  txtSizeL(hnd: Thandle; s: pchar; L: integer): Tsize;
  function  mousePos: Tpoint;
  function  into(p: Tpoint; r: Trect): boolean;

  procedure RestartApp;


  function GetShellVersion: Cardinal;

 {$IFDEF RNQ}
  procedure LoadTranslit;
  procedure UnLoadTranslit;
  function  Translit(const s: String): String;
  function  TxtFromInt(Int: Integer {3 digits}): String;

  procedure SoundPlay(fn: String); overload;
  procedure SoundPlay(fs: TMemoryStream); overload;
  procedure SoundStop;
  procedure SoundInit;
  procedure SoundReset;
  procedure SoundUnInit;
 {$ENDIF RNQ}

  function ExistsFlash: Boolean;
 {$IFNDEF DELPHI9_UP}
  function ThemeControl(AControl: TControl): Boolean;
 {$ENDIF DELPHI9_UP}
//  function DelayedFailureHook(dliNotify: dliNotification; pdli: PDelayLoadInfo): Pointer; stdcall;
  procedure unroundWindow(hnd:Thandle); {$IFDEF HAS_INLINE} inline; {$ENDIF HAS_INLINE}
{
  procedure assignImgIco(img: Timage; ico: Ticon);
  procedure assignImgBmp(img: Timage; bmp: Tbitmap);
}
//  procedure assignImgPic(img: Timage; picName: String);
  procedure parseMsgImages(const imgStr: RawByteString; var imgList: TAnsiStringList);

  function HTMLEntitiesDecode(const HTML: String): String;
  function ParamEncode(const Param: String): UTF8String;
  procedure ODS(const Msg: String);

var
  masterMute: Boolean = false;

implementation
uses
  sysutils, StrUtils, math, DateUtils,

//  MSACMX,
//  ComObj,
  Themes,
  CommCtrl,
  MMSystem, ActiveX, //ShockwaveFlashObjects_TLB,
  RnQBinUtils, RDUtils, RnQGlobal,
  RDFileUtil,
//  RnQFileUtil,
 {$IFDEF RNQ}
   {$IFDEF RNQ_PLAYER}
    BASSplayer,
   {$ELSE RNQ_PLAYER}
    dynamic_bass,
   {$ENDIF RNQ_PLAYER}
   RQThemes,
   VirtualTrees, RQlog, RQmsgs,
  RnQlangs,
 {$ENDIF RNQ}
 {$IFDEF RNQ_PLUGIN}
   RDPlugins,
 {$ENDIF RNQ_PLUGIN}
  Types;

//var
// Soundhndl : HCHANNEL;

function absPath(const fn: String): Boolean;
begin
  result := (length(fn)>2) and ((fn[2]=':') or (fn[1]=PathDelim) and (fn[2]=PathDelim))
end;

function ExtractFileNameOnly(const fn: String): String;
var
  I, K: Integer;
begin
  I := LastDelimiter(PathDelim + DriveDelim, fn);
  K := LastDelimiter('.' + PathDelim + DriveDelim, fn);
  if (K > 0) and (fn[K] = '.') then
    Result := Copy(fn, I+1, K-I-1)
   else
    Result := Copy(fn, I + 1, MaxInt);
end;

function str2fontstyle(const s: AnsiString): Tfontstyles;
begin
  result := [];
  if ansipos(Ansichar('b'),s) > 0 then
    include(result, fsBold);
  if ansipos(Ansichar('i'),s) > 0 then
    include(result, fsItalic);
  if ansipos(Ansichar('u'),s) > 0 then
    include(result, fsUnderline);
end; // str2fontstyle

function fontstyle2str(fs: Tfontstyles): AnsiString;
begin
  result := '';
  if fsBold in fs then
    result := result+'b';
  if fsItalic in fs then
    result := result+'i';
  if fsUnderline in fs then
    result := result+'u';
end; // str2fontstyle

function str2html(const s: string): string;
begin
result := template(s, [
  '&', '&amp;',
  '"', '&quot;',
  '<', '&lt;',
  '>', '&gt;',
  CRLF, '<br>',
  #13, '<br>',
  #10, '<br>'
]);
end; // str2html

function strFromHTML(const s: string): string;
begin
  result := template(s, [
  '&amp;', '&',
  '&quot;', '"',
  '&lt;', '<',
  '&gt;', '>',
  '<br>', CRLF
//  '<br>', #13,
//  '<br>', #10,
]);
end; // str2html

function strFromHTML(const s: RawByteString): RawByteString; OverLoad;
begin
  result := template(s, [
  RawByteString('&amp;'), RawByteString('&'),
  RawByteString('&quot;'), RawByteString('"'),
  RawByteString('&lt;'), RawByteString('<'),
  RawByteString('&gt;'), RawByteString('>'),
  RawByteString('<br>'), CRLF
//  '<br>', #13,
//  '<br>', #10,
   ]);
end; // strFromhtml


procedure msgDlg(msg: String; NeedTransl: Boolean; kind: TMsgDlgType; const uid: String = '');
const
  kind2str: array [TmsgDlgType] of string=('WARNING', 'ERROR', 'INFO', '', '');
begin
 {$IFDEF RNQ}
  if NeedTransl then
    msg := getTranslation(msg);

  loggaEvtS(kind2str[kind]+': '+msg, iconNames[kind]);
 {$ENDIF RNQ}

  if BringInfoFrgd then
    application.bringToFront;

 {$IFDEF RNQ}
  if msgsFrm=NIL then
 {$ENDIF RNQ}
    messageDlg(msg, kind, [mbOk], 0, mbOk, MsgShowTime[kind])
//  ShowMessage(msg)
 {$IFDEF RNQ}
   else
    begin
      msgsFrm.AddMsg(msg, kind, now, uid);
      if BringInfoFrgd then
        msgsFrm.BringToFront;
    end;
 {$ENDIF RNQ}
end; // msgDlg

procedure showForm(frm: Tform);
begin
  if frm=NIL then
    exit;
{
if frm = mainFrm then
  begin
  if not formvisible(mainfrm) then mainfrm.toggleVisible;
  exit;
  end;}
  frm.show;
//  ShowWindow(application.handle,SW_HIDE)
end;

procedure drawTxt(hnd: Thandle; x, y: integer; const s: string);
begin
  textOut(hnd, x,y, PChar(s), length(s))
end;

procedure drawTxtL(hnd: Thandle; x, y: integer; const s: pchar; L: integer);
begin
  textOut(hnd, x,y, s, L)
end;

function txtSize(hnd: Thandle; const s: string): TSize;
begin
  GetTextExtentPoint32(hnd, pchar(s), length(s), result)
end;

function txtSizeL(hnd: Thandle; s: pchar; L: integer): TSize;
begin
  GetTextExtentPoint32(hnd,s,l,result)
end;

function mousePos: Tpoint;
begin
  getCursorPos(result)
end;

function into(p: Tpoint; r: Trect): boolean;
begin
  result := (r.Left <= p.x) and (r.right >= p.x) and (r.top <= p.y) and (r.bottom >= p.y)
end;

 {$IFDEF RNQ}

procedure UnLoadTranslit;
var
  i: Integer;
begin
  for i := 0 to TranslitList.Count - 1 do
   begin
    TStrObj(TranslitList.Objects[i]).Free;
    TranslitList.Objects[i] := NIL;
   end;
  FreeAndNil(TranslitList);
end;

procedure LoadTranslit;
var
  txt: RawByteString;
  v, k: RawByteString;
  so: TStrObj;
begin
  TranslitList := TStringList.create;
  TranslitList.Sorted := false;
  txt := loadfileA(myPath+ 'translit.txt');
  while txt>'' do
   try
    v := chopline(txt);
    v := trim(chop('#',v));
    if v='' then
      Continue;
    k := trim(chop('-', v));
    v := trim(v);
    if (k='') or (v = '') then
      Continue;
    so := TStrObj.Create;
    so.str := UnUTF(v);
    TranslitList.AddObject(k, so)
   except;
   end;
  TranslitList.CaseSensitive := True;
  TranslitList.Sorted := True;
  TranslitList.Sort;
end;

function Translit(const s: String): String;
var
  i, k: Integer;
begin
  if Assigned(TranslitList) and (TranslitList.Count > 0) then
    begin
      for i := 1 to Length(s) do
       if s[i] = ' ' then
         result := result + ' '
       else
        if TranslitList.Find(s[i], k) then
         result := result + TStrObj(TranslitList.Objects[k]).str
        else
         result := result + s[i];
    end
  else
   result := s;
end;


procedure SoundInit;
const
//{$IFDEF CPUX64}
//  bass_dll_x64_FN = 'bassx64.dll';
//{$ELSE ~CPUX64}
//{$ENDIF CPUX64}
  bass_dll_FN = 'bass.dll';
var
  b: Boolean;
  err: Integer;
begin
  audioPresent := FALSE;
 {$IFDEF RNQ_PLAYER}
  if not Assigned(RnQbPlayer) then
    RnQbPlayer := TBASSplayer.Create(nil);
  audioPresent := RnQbPlayer.PlayerReady;

 {$ELSE RNQ_PLAYER}

//{$IFDEF CPUX64}
// b := Load_BASSDLL(modulesPath + bass_dll_x64_FN);
// if not b then
//{$ENDIF CPUX64}
   b := Load_BASSDLL(modulesPath + bass_dll_FN);
 if b then
 begin
	// Ensure BASS 2.4 was loaded
	if HIWORD(BASS_GetVersion) <> BASSVERSION then
   begin
    Unload_BASSDLL;
    audioPresent:= FALSE;
    msgDlg('BASS version 2.4 was not loaded!', True, mtError);
//    halt(1);
   end
  else
	// Initialize audio - default device, 44100hz, stereo, 16 bits
//	if not BASS_Init(1, 44100, 0, 0, nil) then
//	if not BASS_Init(-1, 44100, 0, 0, nil) then

 {$IFDEF DELPHI9_UP}// By Rapid D
//	if not BASS_Init(-1, 44100, 0, Application.MainFormHandle, nil) then
	if not BASS_Init(-1, 44100, 0, Application.MainFormHandle, nil) then
 {$ENDIF DELPHI9_UP}// By Rapid D
   begin
    err := BASS_ErrorGetCode;
    audioPresent := FALSE;
    Unload_BASSDLL;
    msgDlg(getTranslation('Error initializing audio!') + CrLfS +
           'Code: '+ IntToStr(err), False, mtError);
   end
 {$IFDEF DELPHI9_UP}// By Rapid D
  else
    audioPresent := TRUE;
 {$ENDIF DELPHI9_UP}// By Rapid D
 end
 else
 audioPresent := FALSE;
 {$ENDIF RNQ_PLAYER}
end;


procedure SoundPlay(fn: string);
begin
  if masterMute or disablesounds or (not playSounds) then
    exit;
  if length(fn) < 2 then
    exit;
  if fn[2] <> ':' then
    fn:= myPath + fn;
  if not audioPresent then
//  waveOutSetVolume (HWAVEOUT hwo, DWORD dwVolume);
    PlaySound(PChar(fn), 0, SND_ASYNC+SND_FILENAME+SND_NODEFAULT+SND_NOWAIT)
//  sound.PlaySound(fn)
   else
 begin
 {$IFDEF RNQ_PLAYER}
  RnQbPlayer.PlaySecondSound(fn, Soundvolume * MaxVolume div 100);

 {$ELSE RNQ_PLAYER}

 	// Play stream, not flushed
  Soundhndl := BASS_StreamCreateFile(False, PChar(fn), 0, 0, BASS_SAMPLE_FLOAT or BASS_STREAM_AUTOFREE
                    {$IFDEF UNICODE}or BASS_UNICODE {$ENDIF UNICODE} );
//  BASS_StreamCreateFile
//  BASS_ChannelSetAttributes( Soundhndl, -1, Soundvolume, -101);
  BASS_ChannelSetAttribute( Soundhndl, BASS_ATTRIB_VOL, Soundvolume / 100);
//  BASS_SetVolume(Soundvolume);
  BASS_ChannelPlay(Soundhndl, false);
 {$ENDIF RNQ_PLAYER}
 end;
//  mmsystem.PlaySound(pchar(fn),0,SND_ASYNC+SND_FILENAME+SND_NODEFAULT+SND_NOWAIT)
end; // playSound

procedure SoundStop;
begin
  if disablesounds or (not playSounds) then
    exit;
  if not audioPresent then
    PlaySound(nil, 0, SND_ASYNC+SND_NODEFAULT + SND_NOWAIT)
//   else
//    BASS_ChannelStop(Soundhndl);
end;

function sendMCIcommand(cmd:PChar):string;
var
  res: array [0..100] of char;
  trash: Thandle;
begin
  trash := 0; // shut up compiler
  mciSendString(cmd, res, length(res), trash);
  result := res;
end; // sendMCI

procedure SoundPlay(fs: TMemoryStream);
var
// p : Pointer;
//  a : array of byte;
  sz : Int64;
begin

  if masterMute or disablesounds or (not playSounds) then
    exit;
  sz := fs.Seek(0, soEnd);
  if sz < 2 then
    exit;
  fs.Seek(0, soBeginning);

  if not audioPresent then
  begin
//    SetLength(a, fs.size+1);
//    fs.Position := 0;
//    fs.ReadBuffer(a[0], fs.Size);
//    PlaySound(@a[0], 0, SND_SYNC+SND_MEMORY+SND_NODEFAULT + SND_NOWAIT);
//    SetLength(a, 0);
    PlaySound(fs.Memory, 0, SND_ASYNC+SND_MEMORY+SND_NODEFAULT + SND_NOWAIT);
    ////////////          VERY BAD!!!!!!!!!!!!!!!!!!!!!!!
    ///  Need copy sound and keep it while playing !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
//  PlaySound(pAnsiChar(fn), 0, SND_ASYNC+SND_FILENAME+SND_NODEFAULT+SND_NOWAIT)
  end
  else
 begin
 {$IFDEF RNQ_PLAYER}
  RnQbPlayer.PlaySecondSound(fn, Soundvolume * MaxVolume div 100);

 {$ELSE RNQ_PLAYER}

{    SetLength(a, fs.size+1);
    fs.Position := 0;
    fs.ReadBuffer(a[0], fs.Size);
 	// Play stream, not flushed
    Soundhndl := BASS_StreamCreateFile(True, @a[0], 0, fs.Size, BASS_STREAM_AUTOFREE);
}
    Soundhndl := BASS_StreamCreateFile(True, fs.Memory, 0, sz, BASS_SAMPLE_FLOAT or BASS_STREAM_AUTOFREE);
//  BASS_StreamCreateFile
//    BASS_ChannelSetAttributes( Soundhndl, -1, Soundvolume, -101);
    BASS_ChannelSetAttribute( Soundhndl, BASS_ATTRIB_VOL, Soundvolume / 100);
    BASS_ChannelPlay(Soundhndl, false);
//    BASS_ChannelPlay(Soundhndl, True);
//    SetLength(a, 0);
 {$ENDIF RNQ_PLAYER}
 end;
//  mmsystem.PlaySound(pchar(fn),0,SND_ASYNC+SND_FILENAME+SND_NODEFAULT+SND_NOWAIT)
end; // playSound

procedure SoundReset;
begin
 if audioPresent then
 try
  Soundvolume := 100;
  except
 end; 
end;
procedure SoundUnInit;
begin
 {$IFDEF RNQ_PLAYER}
  FreeAndNil(RnQbPlayer);
 {$ELSE RNQ_PLAYER}
    // Close BASS
 if audioPresent then
 begin
   if audioPresent and not disablesounds and playSounds then
     while BASS_ChannelIsActive(Soundhndl) = BASS_ACTIVE_PLAYING do
      Application.ProcessMessages;

  audioPresent := False;
  disablesounds := True;
//  BASS_ChannelStop(Soundhndl);
//  BASS_Free;
   Unload_BASSDLL;
 end;
 {$ENDIF RNQ_PLAYER}
end;

 {$ENDIF RNQ}

function GetShellVersion: Cardinal;
begin
  if ShellVersion=0 then
    ShellVersion := GetFileVersion ('shell32.dll');
  Result := ShellVersion;
end;



function transpColor(cl: TColor; alpha: Byte): TColor;
var
 dw: Cardinal;
 cf: Double;
begin
  dw := ColorToRGB(cl);
  cf := alpha / $FF;
  result := round((dw shr 16 and $FF) * cf)shl 16 + round((dw shr 8 and $FF) * cf) shl 8 + round((dw and $FF) * cf);
end;

{
function GPtranspPColor(cl : Cardinal): Cardinal;
// Применяет прозрачность к цвету, как если он рисуеться на белом фоне
var
// dw : Cardinal;
 cf : Double;
 b  : Byte;
begin

//  dw := ColorToRGB(cl);
  cf := (cl and AlphaMask) shr ALPHA_SHIFT / $FF;
  b  := round($FF * (1-cf));
  result := ALPHA_MASK + round((cl shr RED_SHIFT and $FF) * cf +b)shl RED_SHIFT
          + round((cl shr GREEN_SHIFT and $FF) * cf +b) shl GREEN_SHIFT
          + round((cl and $FF) * cf + b);
end;
}

type
 TMatrix = packed array[0..6,0..3] of Byte;

var
  abc: packed array[0..9] of TMatrix =
  (
  ((0,1,1,0),(1,0,0,1),(1,0,0,1),(1,0,0,1),(1,0,0,1),(1,0,0,1),(0,1,1,0)),
  ((0,0,1,0),(0,1,1,0),(1,0,1,0),(0,0,1,0),(0,0,1,0),(0,0,1,0),(1,1,1,1)),
  ((0,1,1,0),(1,0,0,1),(0,0,0,1),(0,0,1,0),(0,1,0,0),(1,0,0,0),(1,1,1,1)),
  ((0,1,1,0),(1,0,0,1),(0,0,0,1),(0,1,1,0),(0,0,0,1),(1,0,0,1),(0,1,1,0)),
  ((1,0,0,1),(1,0,0,1),(1,0,0,1),(1,1,1,1),(0,0,0,1),(0,0,0,1),(0,0,0,1)),
  ((1,1,1,1),(1,0,0,0),(1,1,1,0),(0,0,0,1),(0,0,0,1),(1,0,0,1),(0,1,1,0)),
  ((0,1,1,0),(1,0,0,1),(1,0,0,0),(1,1,1,0),(1,0,0,1),(1,0,0,1),(0,1,1,0)),
  ((1,1,1,1),(0,0,0,1),(0,0,0,1),(0,0,1,0),(0,1,0,0),(0,1,0,0),(0,1,0,0)),
  ((0,1,1,0),(1,0,0,1),(1,0,0,1),(0,1,1,0),(1,0,0,1),(1,0,0,1),(0,1,1,0)),
  ((0,1,1,0),(1,0,0,1),(1,0,0,1),(0,1,1,1),(0,0,0,1),(1,0,0,1),(0,1,1,0))
  );
 
function GetRow(sym, row: integer): string;
var
 line: string;
 i: integer;
begin
 line:='';
 for i:=0 to 3 do
  begin
    if abc[sym][row,i]=1 then
     line:=line+'#'
    else
     line:=line+'_';
  end;
  result:=line;
end;

function TxtFromInt(Int: Integer {3 digits}): String;
var
 iArr: array[1..3] of Integer;
 res, line: String;
 i, k: Integer;
begin
// Randomize;
 if (Int<100)or(Int>999) then
  begin
    result:='PLUGIN ERROR: Invalid input parameters'+CRLF;
    exit;
  end;
 iArr[1]:= Int div 100;
 iArr[2]:= (Int - iArr[1]*100) div 10;
 iArr[3]:= (Int - iArr[1]*100 - iArr[2]*10);
 for i:=0 to 6 do
  begin
    line:='';
    for k:=1 to 3 do
    begin
     line:=line+'_'+GetRow(iArr[k],i);
    end;
   res:=res+CRLF+line;
  end;
  result:=res;
end;

//procedure KillApplication(Restart: boolean);
procedure RestartApp;
var
  StartInfo: TStartupInfo;
  ProcInfo: TProcessInformation;
  StartDir: string;
begin
//  if Restart then
  begin
    GetStartupInfo(StartInfo);
//    StartDir := GetCurrentDir;
    StartDir := myPath;
    FillChar(ProcInfo, SizeOf(TProcessInformation), #0);

    CreateProcess(nil, GetCommandLine, nil, nil, False,
      CREATE_NEW_PROCESS_GROUP + NORMAL_PRIORITY_CLASS, nil,
      PChar(StartDir), StartInfo, ProcInfo);
  end;
  // TODO: call all the "finalization" sections, with a timeout.
  TerminateProcess(GetCurrentProcess, 1);
end;

function ExistsFlash : Boolean;
//var
//  rr : HResult; res : Pointer;
begin
  Result := True
//  rr := CoGetClassObject(CLASS_ShockwaveFlash, 0, nil, IID_IShockwaveFlash, res);
//  Result := rr = S_OK;
//  if Result then
//    IClassFactory(res)._Release;
end;

 {$IFNDEF DELPHI9_UP}
function ThemeControl(AControl: TControl): Boolean;
begin
  Result := False;
  if AControl = nil then
    exit;
  Result := (not (csDesigning in AControl.ComponentState) and ThemeServices.ThemesEnabled) or
            ((csDesigning in AControl.ComponentState) and (AControl.Parent <> nil) and
             (ThemeServices.ThemesEnabled //and not UnthemedDesigner(AControl.Parent)
             )
             );
end;
 {$ENDIF DELPHI9_UP}


procedure drawCoolText(cnv: Tcanvas; const text: string);
var
  i, l, n, escpos: integer;
  r: Trect;
  st: Tfontstyles;
  startX: integer;

  procedure turnStyle(v: graphics.TFontStyle);
  begin
    if v in st then
      st := st-[v]
     else
      st := st-[v];
    cnv.font.style := st;
  end;

begin
  i := 1;
  r := cnv.ClipRect;
  l := length(text);
  st := cnv.font.Style;
  startX := cnv.penpos.x;
  while i<=l do
    begin
    escpos := i;
    while (escpos<=l) and (text[escpos]<>#27) do
      inc(escpos);
    if escpos>l then
      n := l-i+1
     else
      n := escpos-i;
    r.Left := cnv.PenPos.X;
    r.top := cnv.PenPos.y;
    DrawText(cnv.handle, @text[i], n, r, DT_SINGLELINE);
    inc(i,n);
    if escpos <= l then
      begin
      inc(i,2);
      case text[escpos] of
        'b': turnStyle(fsBold);
        'i': turnStyle(fsItalic);
        'u': turnStyle(fsItalic);
        'r': cnv.MoveTo(startX, cnv.penpos.Y+cnv.TextHeight('I'));
        end;
      end;
    end;
end; // drawCoolText

{$IFNDEF RNQ}
function getTranslation(s: String): String;
begin
  Result := s;
end;
{$ENDIF RNQ}

function datetimeToStrMinMax(dt: Tdatetime; min: Tdatetime; max: Tdatetime): string; overload;
begin
  if dt=0 then
    result := ''
   else
    if (dt<min) or (dt>max) then
      result := getTranslation('Invalid')
     else
      result := formatDatetime(timeformat.info, dt);
end; // datetimeToStrMinMax

function dateTocoolstr(d: Tdatetime): string;
begin
case trunc(now)-trunc(d) of
  0: result := getTranslation('Today');
  1: result := getTranslation('Yesterday');
  2..5: result:= FormatSettings.LongDayNames[dayofweek(d)];
  else
    begin
      if (trunc(now)-trunc(d) > 365) then
        result := intToStr(YearOf(d)) + ' '
       else
        result := '';
      result:= result + capitalize(FormatSettings.LongMonthNames[monthOf(d)])+' '+intToStr(dayOf(d));
    end;
  end
end; // dateToCoolstr

function logTimestamp: string;
begin result := formatDatetime(timeformat.log, now)+'> ' end;


procedure unroundWindow(hnd: Thandle); {$IFDEF HAS_INLINE} inline; {$ENDIF HAS_INLINE}
begin SetWindowRgn(hnd, 0, True) end;

(*
procedure assignImgPic(img: Timage; picName: String);
//var
//  bmp: Tbitmap;
begin
{ theme.GetPic(picName, bmp);
 img.Picture.Bitmap.Destroy;
 img.Picture.Bitmap.assign(bmp);}
//  theme.GetPic(picName, img.Picture.Bitmap);
 //img.Picture.Bitmap.FreeImage;
// img.Transparent:=bmp.Transparent;
 img.Transparent:=True;
// img.height:=bmp.height;
// img.width:=bmp.width;
// bmp.Free;
end; // assignImgBmp
procedure assignImgBmp(img: Timage; bmp: Tbitmap);
begin
  img.Picture.Bitmap.Destroy;
  img.Picture.Bitmap.assign(bmp);
  //img.Picture.Bitmap.FreeImage;
  img.Transparent := bmp.Transparent;
  img.height := bmp.height;
  img.width := bmp.width;
end; // assignImgBmp

procedure assignImgIco(img: Timage; ico: Ticon);
begin
  img.Picture.icon.assign(ico);
  img.width := ico.width*2;
  img.height := ico.height*2;
end; // assignImgIco
*)

procedure parseMsgImages(const imgStr: RawByteString; var imgList: TAnsiStringList);
var
  pos1, pos2: integer;
  image: RawByteString;
begin
  if not Assigned(imgList) then
    exit;

  image := imgStr;
  repeat
    pos1 := PosEx(RnQImageTag, image);
    if (pos1 > 0) then
    begin
      pos2 := PosEx(RnQImageUnTag, image, pos1 + length(RnQImageTag));
      imgList.Add(Copy(image, pos1 + length(RnQImageTag), pos2 - (pos1 + length(RnQImageTag))));
      image := Copy(image, pos2 + length(RnQImageUnTag), length(image));
    end
    else
      Break;
  until pos1 <= 0;

  image := imgStr;
  repeat
    pos1 := PosEx(RnQImageExTag, image);
    if (pos1 > 0) then
    begin
      pos2 := PosEx(RnQImageExUnTag, image, pos1 + length(RnQImageExTag));
      imgList.Add(Copy(image, pos1 + length(RnQImageExTag), pos2 - (pos1 + length(RnQImageExTag))));
      image := Copy(image, pos2 + length(RnQImageExUnTag), length(image));
    end
    else
      Break;
  until pos1 <= 0;
end;

function HTMLEntitiesDecode(const HTML: String): String;

  function UCS4CharToString(uch: UCS4Char): UnicodeString;
  var
    s: UCS4String;
  begin
    SetLength(s, 2);
    s[0] := uch;
    s[1] := 0; // Null terminator
    Result := UCS4StringToUnicodeString(s);
  end;

  function GetCharRef(const sValue: UnicodeString; StartIndex: Integer; out CharRef: string): UnicodeString;
  var
    i: Integer;
    len: Integer;
    nChar: UCS4Char;
  begin
    Result := '';
    CharRef := '';

    len := Length(sValue) - StartIndex + 1;
    if len < 4 then
      Exit;
    i := StartIndex;
    if sValue[i] <> '&' then Exit;
    Inc(i);
    if sValue[i] <> '#' then Exit;
    Inc(i);

    if sValue[i] = 'x' then
    begin
      Inc(i); // Skip the x
      while CharInSet(sValue[i], ['0'..'9', 'a'..'f', 'A'..'F']) do
      begin
        Inc(i);
        if i > Length(sValue) then
          Exit;
      end;
      if sValue[i] <> ';' then
        Exit;

      charRef := Copy(sValue, StartIndex, (i-StartIndex)+1);
      nChar := StrToInt('$'+Copy(charRef, 4, Length(charRef)-4));
    end
      else
    begin
      while CharInSet(sValue[i], ['0'..'9']) do
      begin
        Inc(i);
        if i > Length(sValue) then
          Exit;
      end;
      if sValue[i] <> ';' then
        Exit;

      charRef := Copy(sValue, StartIndex, (i-StartIndex)+1);
      nChar := StrToInt(Copy(charRef, 3, Length(charRef)-3));
    end;
    Result := UCS4CharToString(nChar);
  end;

  function GetEntityRef(const sValue: string; StartIndex: Integer; out CharRef: string): UnicodeString;

    function IsNameStartChar(ch: WideChar): Boolean;
    begin
      // NameStartChar ::= ":" | [A-Z] | "_" | [a-z] | [#xC0-#xD6] | [#xD8-#xF6] | [#xF8-#x2FF] | [#x370-#x37D] | [#x37F-#x1FFF] | [#x200C-#x200D] | [#x2070-#x218F] | [#x2C00-#x2FEF] | [#x3001-#xD7FF] | [#xF900-#xFDCF] | [#xFDF0-#xFFFD] | [#x10000-#xEFFFF]
      Result := False;
      case ch of
        ':', 'A'..'Z', '_', 'a'..'z', #$C0..#$D6, #$D8..#$F6, #$F8..#$FF: Result := True;
        #$100..#$2FF, #$370..#$37D, #$37F..#$409, #$450..#$FFF: Result := True;
        #$1000..#$1FFF, #$200C..#$200D, #$2070..#$218F, #$2C00..#$2FEF, #$3001..#$D7FF, #$F900..#$FDCF, #$FDF0..#$FFFD: Result := True;
      else
        case Integer(ch) of
          $10000..$EFFFF: Result := True;
        end;
      end;
    end;

    function IsNameChar(ch: WideChar): Boolean;
    begin
      if IsNameStartChar(ch) then
      begin
        Result := True;
        Exit;
      end;

      case ch of
        '-', '.', '0'..'9', #$B7, #$0300..#$036F, #$203F..#$2040: Result := True;
      else
        Result := False;
      end;
    end;

    type
      THtmlEntity = record
        entity: string;
        ch: UCS4Char;
      end;
    const
      HtmlEntities: array[0..252] of THtmlEntity = (
                (entity: 'apos';        ch: 39; ), // apostrophe (originally only existed in xml, and not in HTML. Was added to HTML5
                (entity: 'quot';        ch: 34; ),  // quotation mark = APL quote, U+0022
                (entity: 'amp';     ch: 38; ),  // ampersand, U+0026
                (entity: 'lt';          ch: 60; ),  // less-than sign, U+003C
                (entity: 'gt';          ch: 62; ),  // greater-than sign, U+003E
                (entity: 'OElig';       ch: 338;    ),  // latin capital ligature OE, U+0152
                (entity: 'oelig';       ch: 339;    ),  // latin small ligature oe, U+0153
                (entity: 'Scaron';  ch: 352;    ),  // latin capital letter S with caron, U+0160
                (entity: 'scaron';  ch: 353;    ),  // latin small letter s with caron, U+0161
                (entity: 'Yuml';        ch: 376;    ),  // latin capital letter Y with diaeresis, U+0178
                (entity: 'circ';        ch: 710;    ),  // modifier letter circumflex accent, U+02C6
                (entity: 'tilde';       ch: 732;    ),  // small tilde, U+02DC
                (entity: 'nbsp';        ch: 160;    ),  // no-break space = non-breaking space,    U+00A0
                (entity: 'iexcl';       ch: 161;    ),  // inverted exclamation mark, U+00A1
                (entity: 'cent';        ch: 162;    ),  // cent sign, U+00A2
                (entity: 'pound';       ch: 163;    ),  // pound sign, U+00A3
                (entity: 'curren';  ch: 164;    ),  // currency sign, U+00A4
                (entity: 'yen';     ch: 165;    ),  // yen sign = yuan sign, U+00A5
                (entity: 'brvbar';  ch: 166;    ),  // broken bar = broken vertical bar,    U+00A6
                (entity: 'sect';        ch: 167;    ),  // section sign, U+00A7
                (entity: 'uml';     ch: 168;    ),  // diaeresis = spacing diaeresis,    U+00A8
                (entity: 'copy';        ch: 169;    ),  // copyright sign, U+00A9
                (entity: 'ordf';        ch: 170;    ),  // feminine ordinal indicator, U+00AA
                (entity: 'laquo';       ch: 171;    ),  // left-pointing double angle quotation mark = left pointing guillemet, U+00AB
                (entity: 'not';     ch: 172;    ),  // not sign, U+00AC
                (entity: 'shy';     ch: 173;    ),  // soft hyphen = discretionary hyphen,    U+00AD
                (entity: 'reg';     ch: 174;    ),  // registered sign = registered trade mark sign,    U+00AE
                (entity: 'macr';        ch: 175;    ),  // macron = spacing macron = overline  = APL overbar, U+00AF
                (entity: 'deg';     ch: 176;    ),  // degree sign, U+00B0
                (entity: 'plusmn';  ch: 177;    ),  // plus-minus sign = plus-or-minus sign,    U+00B1
                (entity: 'sup2';        ch: 178;    ),  // superscript two = superscript digit two  = squared, U+00B2
                (entity: 'sup3';        ch: 179;    ),  // superscript three = superscript digit three  = cubed, U+00B3
                (entity: 'acute';       ch: 180;    ),  // acute accent = spacing acute,    U+00B4
                (entity: 'micro';       ch: 181;    ),  // micro sign, U+00B5
                (entity: 'para';        ch: 182;    ),  // pilcrow sign = paragraph sign,    U+00B6
                (entity: 'middot';  ch: 183;    ),  // middle dot = Georgian comma = Greek middle dot, U+00B7
                (entity: 'cedil';       ch: 184;    ),  // cedilla = spacing cedilla, U+00B8
                (entity: 'sup1';        ch: 185;    ),  // superscript one = superscript digit one,    U+00B9
                (entity: 'ordm';        ch: 186;    ),  // masculine ordinal indicator,    U+00BA
                (entity: 'raquo';       ch: 187;    ),  // right-pointing double angle quotation mark =  right pointing guillemet, U+00BB
                (entity: 'frac14';  ch: 188;    ),  // vulgar fraction one quarter  = fraction one quarter, U+00BC
                (entity: 'frac12';  ch: 189;    ),  // vulgar fraction one half  = fraction one half, U+00BD
                (entity: 'frac34';  ch: 190;    ),  // vulgar fraction three quarters  = fraction three quarters, U+00BE
                (entity: 'iquest';  ch: 191;    ),  // inverted question mark  = turned question mark, U+00BF
                (entity: 'Agrave';  ch: 192;    ),  // latin capital letter A with grave  = latin capital letter A grave,    U+00C0
                (entity: 'Aacute';  ch: 193;    ),  // latin capital letter A with acute,    U+00C1
                (entity: 'Acirc';       ch: 194;    ),  // latin capital letter A with circumflex,    U+00C2
                (entity: 'Atilde';  ch: 195;    ),  // latin capital letter A with tilde,    U+00C3
                (entity: 'Auml';        ch: 196;    ),  // latin capital letter A with diaeresis,    U+00C4
                (entity: 'Aring';       ch: 197;    ),  // latin capital letter A with ring above  = latin capital letter A ring,    U+00C5
                (entity: 'AElig';       ch: 198;    ),  // latin capital letter AE  = latin capital ligature AE,    U+00C6
                (entity: 'Ccedil';  ch: 199;    ),  // latin capital letter C with cedilla,    U+00C7
                (entity: 'Egrave';  ch: 200;    ),  // latin capital letter E with grave,    U+00C8
                (entity: 'Eacute';  ch: 201;    ),  // latin capital letter E with acute,    U+00C9
                (entity: 'Ecirc';       ch: 202;    ),  // latin capital letter E with circumflex,    U+00CA
                (entity: 'Euml';        ch: 203;    ),  // latin capital letter E with diaeresis,    U+00CB
                (entity: 'Igrave';  ch: 204;    ),  // latin capital letter I with grave,    U+00CC
                (entity: 'Iacute';  ch: 205;    ),  // latin capital letter I with acute,    U+00CD
                (entity: 'Icirc';       ch: 206;    ),  // latin capital letter I with circumflex,    U+00CE
                (entity: 'Iuml';        ch: 207;    ),  // latin capital letter I with diaeresis,    U+00CF
                (entity: 'ETH';     ch: 208;    ),  // latin capital letter ETH, U+00D0
                (entity: 'Ntilde';  ch: 209;    ),  // latin capital letter N with tilde,    U+00D1
                (entity: 'Ograve';  ch: 210;    ),  // latin capital letter O with grave,    U+00D2
                (entity: 'Oacute';  ch: 211;    ),  // latin capital letter O with acute,    U+00D3
                (entity: 'Ocirc';       ch: 212;    ),  // latin capital letter O with circumflex,    U+00D4
                (entity: 'Otilde';  ch: 213;    ),  // latin capital letter O with tilde,    U+00D5
                (entity: 'Ouml';        ch: 214;    ),  // latin capital letter O with diaeresis,    U+00D6
                (entity: 'times';       ch: 215;    ),  // multiplication sign, U+00D7
                (entity: 'Oslash';  ch: 216;    ),  // latin capital letter O with stroke  = latin capital letter O slash,    U+00D8
                (entity: 'Ugrave';  ch: 217;    ),  // latin capital letter U with grave,    U+00D9
                (entity: 'Uacute';  ch: 218;    ),  // latin capital letter U with acute,    U+00DA
                (entity: 'Ucirc';       ch: 219;    ),  // latin capital letter U with circumflex,    U+00DB
                (entity: 'Uuml';        ch: 220;    ),  // latin capital letter U with diaeresis,    U+00DC
                (entity: 'Yacute';  ch: 221;    ),  // latin capital letter Y with acute,    U+00DD
                (entity: 'THORN';       ch: 222;    ),  // latin capital letter THORN,    U+00DE
                (entity: 'szlig';       ch: 223;    ),  // latin small letter sharp s = ess-zed,    U+00DF
                (entity: 'agrave';  ch: 224;    ),  // latin small letter a with grave  = latin small letter a grave,    U+00E0
                (entity: 'aacute';  ch: 225;    ),  // latin small letter a with acute,    U+00E1
                (entity: 'acirc';       ch: 226;    ),  // latin small letter a with circumflex,    U+00E2
                (entity: 'atilde';  ch: 227;    ),  // latin small letter a with tilde,    U+00E3
                (entity: 'auml';        ch: 228;    ),  // latin small letter a with diaeresis,    U+00E4
                (entity: 'aring';       ch: 229;    ),  // latin small letter a with ring above  = latin small letter a ring,    U+00E5
                (entity: 'aelig';       ch: 230;    ),  // latin small letter ae  = latin small ligature ae, U+00E6
                (entity: 'ccedil';  ch: 231;    ),  // latin small letter c with cedilla,    U+00E7
                (entity: 'egrave';  ch: 232;    ),  // latin small letter e with grave,    U+00E8
                (entity: 'eacute';  ch: 233;    ),  // latin small letter e with acute,    U+00E9
                (entity: 'ecirc';       ch: 234;    ),  // latin small letter e with circumflex,    U+00EA
                (entity: 'euml';        ch: 235;    ),  // latin small letter e with diaeresis,    U+00EB
                (entity: 'igrave';  ch: 236;    ),  // latin small letter i with grave,    U+00EC
                (entity: 'iacute';  ch: 237;    ),  // latin small letter i with acute,    U+00ED
                (entity: 'icirc';       ch: 238;    ),  // latin small letter i with circumflex,    U+00EE
                (entity: 'iuml';        ch: 239;    ),  // latin small letter i with diaeresis,    U+00EF
                (entity: 'eth';     ch: 240;    ),  // latin small letter eth, U+00F0
                (entity: 'ntilde';  ch: 241;    ),  // latin small letter n with tilde,    U+00F1
                (entity: 'ograve';  ch: 242;    ),  // latin small letter o with grave,    U+00F2
                (entity: 'oacute';  ch: 243;    ),  // latin small letter o with acute,    U+00F3
                (entity: 'ocirc';       ch: 244;    ),  // latin small letter o with circumflex,    U+00F4
                (entity: 'otilde';  ch: 245;    ),  // latin small letter o with tilde,    U+00F5
                (entity: 'ouml';        ch: 246;    ),  // latin small letter o with diaeresis,    U+00F6
                (entity: 'divide';  ch: 247;    ),  // division sign, U+00F7
                (entity: 'oslash';  ch: 248;    ),  // latin small letter o with stroke,    = latin small letter o slash,    U+00F8
                (entity: 'ugrave';  ch: 249;    ),  // latin small letter u with grave,    U+00F9
                (entity: 'uacute';  ch: 250;    ),  // latin small letter u with acute,    U+00FA
                (entity: 'ucirc';       ch: 251;    ),  // latin small letter u with circumflex,    U+00FB
                (entity: 'uuml';        ch: 252;    ),  // latin small letter u with diaeresis,    U+00FC
                (entity: 'yacute';  ch: 253;    ),  // latin small letter y with acute,    U+00FD
                (entity: 'thorn';       ch: 254;    ),  // latin small letter thorn,    U+00FE
                (entity: 'yuml';        ch: 255;    ),  // latin small letter y with diaeresis,    U+00FF
                (entity: 'fnof';        ch: 402;    ),  // latin small f with hook = function  = florin, U+0192
                (entity: 'Alpha';       ch: 913;    ),  // greek capital letter alpha, U+0391
                (entity: 'Beta';        ch: 914;    ),  // greek capital letter beta, U+0392
                (entity: 'Gamma';       ch: 915;    ),  // greek capital letter gamma,    U+0393
                (entity: 'Delta';       ch: 916;    ),  // greek capital letter delta,    U+0394
                (entity: 'Epsilon'; ch: 917;    ),  // greek capital letter epsilon, U+0395
                (entity: 'Zeta';        ch: 918;    ),  // greek capital letter zeta, U+0396
                (entity: 'Eta';     ch: 919;    ),  // greek capital letter eta, U+0397
                (entity: 'Theta';       ch: 920;    ),  // greek capital letter theta,    U+0398
                (entity: 'Iota';        ch: 921;    ),  // greek capital letter iota, U+0399
                (entity: 'Kappa';       ch: 922;    ),  // greek capital letter kappa, U+039A
                (entity: 'Lambda';  ch: 923;    ),  // greek capital letter lambda,    U+039B
                (entity: 'Mu';          ch: 924;    ),  // greek capital letter mu, U+039C
                (entity: 'Nu';          ch: 925;    ),  // greek capital letter nu, U+039D
                (entity: 'Xi';          ch: 926;    ),  // greek capital letter xi, U+039E
                (entity: 'Omicron'; ch: 927;    ),  // greek capital letter omicron, U+039F
                (entity: 'Pi';          ch: 928;    ),  // greek capital letter pi, U+03A0
                (entity: 'Rho';     ch: 929;    ),  // greek capital letter rho, U+03A1
                // there is no Sigmaf, and no U+03A2 character either
                (entity: 'Sigma';       ch: 931;    ),  // greek capital letter sigma,    U+03A3
                (entity: 'Tau';     ch: 932;    ),  // greek capital letter tau, U+03A4
                (entity: 'Upsilon'; ch: 933;    ),  // greek capital letter upsilon,    U+03A5
                (entity: 'Phi';     ch: 934;    ),  // greek capital letter phi,    U+03A6
                (entity: 'Chi';     ch: 935;    ),  // greek capital letter chi, U+03A7
                (entity: 'Psi';     ch: 936;    ),  // greek capital letter psi,    U+03A8
                (entity: 'Omega';       ch: 937;    ),  // greek capital letter omega,    U+03A9
                (entity: 'alpha';       ch: 945;    ),  // greek small letter alpha,    U+03B1
                (entity: 'beta';        ch: 946;    ),  // greek small letter beta, U+03B2
                (entity: 'gamma';       ch: 947;    ),  // greek small letter gamma,    U+03B3
                (entity: 'delta';       ch: 948;    ),  // greek small letter delta,    U+03B4
                (entity: 'epsilon'; ch: 949;    ),  // greek small letter epsilon,    U+03B5
                (entity: 'zeta';        ch: 950;    ),  // greek small letter zeta, U+03B6
                (entity: 'eta';     ch: 951;    ),  // greek small letter eta, U+03B7
                (entity: 'theta';       ch: 952;    ),  // greek small letter theta,    U+03B8
                (entity: 'iota';        ch: 953;    ),  // greek small letter iota, U+03B9
                (entity: 'kappa';       ch: 954;    ),  // greek small letter kappa,    U+03BA
                (entity: 'lambda';  ch: 955;    ),  // greek small letter lambda,    U+03BB
                (entity: 'mu';          ch: 956;    ),  // greek small letter mu, U+03BC
                (entity: 'nu';          ch: 957;    ),  // greek small letter nu, U+03BD
                (entity: 'xi';          ch: 958;    ),  // greek small letter xi, U+03BE
                (entity: 'omicron'; ch: 959;    ),  // greek small letter omicron, U+03BF NEW
                (entity: 'pi';          ch: 960;    ),  // greek small letter pi, U+03C0
                (entity: 'rho';     ch: 961;    ),  // greek small letter rho, U+03C1
                (entity: 'sigmaf';  ch: 962;    ),  // greek small letter final sigma,    U+03C2
                (entity: 'sigma';       ch: 963;    ),  // greek small letter sigma,    U+03C3
                (entity: 'tau';     ch: 964;    ),  // greek small letter tau, U+03C4
                (entity: 'upsilon'; ch: 965;    ),  // greek small letter upsilon,    U+03C5
                (entity: 'phi';     ch: 966;    ),  // greek small letter phi, U+03C6
                (entity: 'chi';     ch: 967;    ),  // greek small letter chi, U+03C7
                (entity: 'psi';     ch: 968;    ),  // greek small letter psi, U+03C8
                (entity: 'omega';       ch: 969;    ),  // greek small letter omega,    U+03C9
                (entity: 'thetasym';    ch: 977;    ),  // greek small letter theta symbol,    U+03D1 NEW
                (entity: 'upsih';       ch: 978;    ),  // greek upsilon with hook symbol,    U+03D2 NEW
                (entity: 'piv';     ch: 982;    ),  // greek pi symbol, U+03D6
                (entity: 'bull';        ch: 8226;   ),  // bullet = black small circle,  U+2022
                (entity: 'hellip';  ch: 8230;   ),  // horizontal ellipsis = three dot leader,  U+2026
                (entity: 'prime';       ch: 8242;   ),  // prime = minutes = feet, U+2032
                (entity: 'Prime';       ch: 8243;   ),  // double prime = seconds = inches,  U+2033
                (entity: 'oline';       ch: 8254;   ),  // overline = spacing overscore,  U+203E NEW
                (entity: 'frasl';       ch: 8260;   ),  // fraction slash, U+2044 NEW
                (entity: 'ensp';        ch: 8194;   ),  // en space, U+2002
                (entity: 'emsp';        ch: 8195;   ),  // em space, U+2003
                (entity: 'thinsp';  ch: 8201;   ),  // thin space, U+2009
                (entity: 'zwnj';        ch: 8204;   ),  // zero width non-joiner, U+200C NEW RFC 2070
                (entity: 'zwj';     ch: 8205;   ),  // zero width joiner, U+200D NEW RFC 2070
                (entity: 'lrm';     ch: 8206;   ),  // left-to-right mark, U+200E NEW RFC 2070
                (entity: 'rlm';     ch: 8207;   ),  // right-to-left mark, U+200F NEW RFC 2070
                (entity: 'ndash';       ch: 8211;   ),  // en dash, U+2013
                (entity: 'mdash';       ch: 8212;   ),  // em dash, U+2014
                (entity: 'lsquo';       ch: 8216;   ),  // left single quotation mark, U+2018
                (entity: 'rsquo';       ch: 8217;   ),  // right single quotation mark, U+2019
                (entity: 'sbquo';       ch: 8218;   ),  // single low-9 quotation mark, U+201A NEW
                (entity: 'ldquo';       ch: 8220;   ),  // left double quotation mark, U+201C
                (entity: 'rdquo';       ch: 8221;   ),  // right double quotation mark, U+201D
                (entity: 'bdquo';       ch: 8222;   ),  // double low-9 quotation mark, U+201E NEW
                (entity: 'dagger';  ch: 8224;   ),  // dagger, U+2020
                (entity: 'Dagger';  ch: 8225;   ),  // double dagger, U+2021
                (entity: 'permil';  ch: 8240;   ),  // per mille sign, U+2030
                (entity: 'lsaquo';  ch: 8249;   ),  // single left-pointing angle quotation mark, U+2039
                (entity: 'rsaquo';  ch: 8250;   ),  // single right-pointing angle quotation mark, U+203A
                (entity: 'euro';        ch: 8364;   ),  // euro sign, U+20AC NEW
                (entity: 'weierp';  ch: 8472;   ),  // script capital P = power set   = Weierstrass p, U+2118
                (entity: 'image';       ch: 8465;   ),  // blackletter capital I = imaginary part,  U+2111
                (entity: 'real';        ch: 8476;   ),  // blackletter capital R = real part symbol,  U+211C
                (entity: 'trade';       ch: 8482;   ),  // trade mark sign, U+2122
                (entity: 'alefsym'; ch: 8501;   ),  // alef symbol = first transfinite cardinal,  U+2135 NEW  (alef symbol is NOT the same as hebrew letter alef, U+05D0 although the same glyph could be used to depict both characters)
                (entity: 'larr';        ch: 8592;   ),  // leftwards arrow, U+2190
                (entity: 'uarr';        ch: 8593;   ),  // upwards arrow, U+2191
                (entity: 'rarr';        ch: 8594;   ),  // rightwards arrow, U+2192
                (entity: 'darr';        ch: 8595;   ),  // downwards arrow, U+2193
                (entity: 'harr';        ch: 8596;   ),  // left right arrow, U+2194
                (entity: 'crarr';       ch: 8629;   ),  // downwards arrow with corner leftwards   = carriage return, U+21B5 NEW
                (entity: 'lArr';        ch: 8656;   ),  // leftwards double arrow, U+21D0
                (entity: 'uArr';        ch: 8657;   ),  // upwards double arrow, U+21D1
                (entity: 'rArr';        ch: 8658;   ),  // rightwards double arrow,  U+21D2
                (entity: 'dArr';        ch: 8659;   ),  // downwards double arrow, U+21D3
                (entity: 'hArr';        ch: 8660;   ),  // left right double arrow,  U+21D4
                (entity: 'forall';  ch: 8704;   ),  // for all, U+2200
                (entity: 'part';        ch: 8706;   ),  // partial differential, U+2202
                (entity: 'exist';       ch: 8707;   ),  // there exists, U+2203
                (entity: 'empty';       ch: 8709;   ),  // empty set = null set = diameter,  U+2205
                (entity: 'nabla';       ch: 8711;   ),  // nabla = backward difference,  U+2207
                (entity: 'isin';        ch: 8712;   ),  // element of, U+2208
                (entity: 'notin';       ch: 8713;   ),  // not an element of, U+2209
                (entity: 'ni';          ch: 8715;   ),  // contains as member, U+220B
                (entity: 'prod';        ch: 8719;   ),  // n-ary product = product sign,  U+220F
                (entity: 'sum';     ch: 8721;   ),  // n-ary sumation, U+2211
                (entity: 'minus';       ch: 8722;   ),  // minus sign, U+2212
                (entity: 'lowast';  ch: 8727;   ),  // asterisk operator, U+2217
                (entity: 'radic';       ch: 8730;   ),  // square root = radical sign,  U+221A
                (entity: 'prop';        ch: 8733;   ),  // proportional to, U+221D
                (entity: 'infin';       ch: 8734;   ),  // infinity, U+221E
                (entity: 'ang';     ch: 8736;   ),  // angle, U+2220
                (entity: 'and';     ch: 8743;   ),  // logical and = wedge, U+2227
                (entity: 'or';          ch: 8744;   ),  // logical or = vee, U+2228
                (entity: 'cap';     ch: 8745;   ),  // intersection = cap, U+2229
                (entity: 'cup';     ch: 8746;   ),  // union = cup, U+222A
                (entity: 'int';     ch: 8747;   ),  // integral, U+222B
                (entity: 'there4';  ch: 8756;   ),  // therefore, U+2234
                (entity: 'sim';     ch: 8764;   ),  // tilde operator = varies with = similar to,  U+223C
                (entity: 'cong';        ch: 8773;   ),  // approximately equal to, U+2245
                (entity: 'asymp';       ch: 8776;   ),  // almost equal to = asymptotic to,  U+2248
                (entity: 'ne';          ch: 8800;   ),  // not equal to, U+2260
                (entity: 'equiv';       ch: 8801;   ),  // identical to, U+2261
                (entity: 'le';          ch: 8804;   ),  // less-than or equal to, U+2264
                (entity: 'ge';          ch: 8805;   ),  // greater-than or equal to,  U+2265
                (entity: 'sub';     ch: 8834;   ),  // subset of, U+2282
                (entity: 'sup';     ch: 8835;   ),  // superset of, U+2283
                (entity: 'nsub';        ch: 8836;   ),  // not a subset of, U+2284
                (entity: 'sube';        ch: 8838;   ),  // subset of or equal to, U+2286
                (entity: 'supe';        ch: 8839;   ),  // superset of or equal to,  U+2287
                (entity: 'oplus';       ch: 8853;   ),  // circled plus = direct sum,  U+2295
                (entity: 'otimes';  ch: 8855;   ),  // circled times = vector product,  U+2297
                (entity: 'perp';        ch: 8869;   ),  // up tack = orthogonal to = perpendicular,  U+22A5
                (entity: 'sdot';        ch: 8901;   ),  // dot operator, U+22C5
                (entity: 'lceil';       ch: 8968;   ),  // left ceiling = apl upstile,  U+2308
                (entity: 'rceil';       ch: 8969;   ),  // right ceiling, U+2309
                (entity: 'lfloor';  ch: 8970;   ),  // left floor = apl downstile,  U+230A
                (entity: 'rfloor';  ch: 8971;   ),  // right floor, U+230B
                (entity: 'lang';        ch: 9001;   ),  // left-pointing angle bracket = bra,  U+2329
                (entity: 'rang';        ch: 9002;   ),  // right-pointing angle bracket = ket,  U+232A
                (entity: 'loz';     ch: 9674;   ),  // lozenge, U+25CA
                (entity: 'spades';  ch: 9824;   ),  // black spade suit, U+2660
                (entity: 'clubs';       ch: 9827;   ),  // black club suit = shamrock,  U+2663
                (entity: 'hearts';  ch: 9829;   ),  // black heart suit = valentine,  U+2665
                (entity: 'diams';       ch: 9830;   )   // black diamond suit, U+2666
            );

    var
      i: Integer;
      len: Integer;
      nChar: UCS4Char;
      runEntity: String;
    begin
      // EntityRef  ::=  '&' Name ';'
      // Name    ::=  NameStartChar (NameChar)*
      // NameStartChar  ::=  ":" | [A-Z] | "_" | [a-z] | [#xC0-#xD6] | [#xD8-#xF6] | [#xF8-#x2FF] | [#x370-#x37D] | [#x37F-#x1FFF] | [#x200C-#x200D] | [#x2070-#x218F] | [#x2C00-#x2FEF] | [#x3001-#xD7FF] | [#xF900-#xFDCF] | [#xFDF0-#xFFFD] | [#x10000-#xEFFFF]
      // NameChar          ::=  NameStartChar | "-" | "." | [0-9] | #xB7 | [#x0300-#x036F] | [#x203F-#x2040]

      Result := '';
      CharRef := '';

      len := Length(sValue) - StartIndex + 1;
      if len < 4 then
        Exit;
      i := StartIndex;
      if sValue[i] <> '&' then Exit;
      Inc(i);

      if not IsNameStartChar(sValue[i]) then
        Exit;

      Inc(i);
      while IsNameChar(sValue[i]) do
      begin
        Inc(i);
        if i > Length(sValue) then
          Exit;
      end;
      if sValue[i] <> ';' then
        Exit;

      charRef := Copy(sValue, StartIndex, (i-StartIndex)+1);

      for i := Low(HtmlEntities) to High(HtmlEntities) do
      begin
        // Now strip off the & and ;
        runEntity := Copy(charRef, 2, Length(charRef)-2);

        // Case sensitive check; as entites are case sensitive
        if runEntity = HtmlEntities[i].entity then
        begin
          nChar := HtmlEntities[i].ch;
          Result := UCS4CharToString(nChar);
          Exit;
        end;
      end;

      // It looks like a valid entity reference, but we don't recognize the text.
      // It's probably garbage that we might be able to fix
      ODS('HtmlDecode: Unknown HTML entity reference: "' + charRef + '"');
    end;

var
  i: Integer;
  entity: UnicodeString;
  entityChar: UnicodeString;
begin
  i := 1;
  Result := '';

  while i <= Length(HTML) do
  begin
    if HTML[i] <> '&' then
    begin
      Result := Result + HTML[i];
      Inc(i);
      Continue;
    end;

    entityChar := GetCharRef(HTML, i, {out}entity);
    if entityChar <> '' then
    begin
      Result := Result + entityChar;
      Inc(i, Length(entity));
      Continue;
    end;

    entityChar := GetEntityRef(HTML, i, {out}entity);
    if entityChar <> '' then
    begin
      Result := Result + entityChar;
      Inc(i, Length(entity));
      Continue;
    end;

    Result := Result + HTML[i];
    Inc(i);
  end;
end;

function ParamEncode(const Param: String): UTF8String;
const
  HexMap: UTF8String = '0123456789ABCDEF';

  function IsSafeChar(ch: Integer): Boolean;
  begin
    if (ch >= 48) and (ch <= 57) then Result := True // 0-9
    else if (ch >= 65) and (ch <= 90) then Result := True // A-Z
    else if (ch >= 97) and (ch <= 122) then Result := True // a-z
    else if (ch = 33) then Result := True // !
    else if (ch >= 39) and (ch <= 42) then Result := True // '()*
    else if (ch >= 45) and (ch <= 46) then Result := True // -.
    else if (ch = 95) then Result := True // _
    else if (ch = 126) then Result := True // ~
    else Result := False;
  end;
var
  I, J: Integer;
  SrcUTF8: UTF8String;
begin
  Result := '';
  SrcUTF8 := UTF8Encode(Param);

  I := 1; J := 1;
  SetLength(Result, Length(SrcUTF8) * 3);
  while I <= Length(SrcUTF8) do
  begin
    if IsSafeChar(Ord(SrcUTF8[I])) then
    begin
      Result[J] := SrcUTF8[I];
      Inc(J);
    end
      else
    begin
      Result[J] := '%';
      Result[J+1] := HexMap[(Ord(SrcUTF8[I]) shr 4) + 1];
      Result[J+2] := HexMap[(Ord(SrcUTF8[I]) and 15) + 1];
      Inc(J,3);
    end;
    Inc(I);
  end;

  SetLength(Result, J - 1);
//  Result := TNetEncoding.URL.Encode(text); // Shit at emoji/unicode
end;
{
function CustomURLEncode(text: String): String;
var
  chr: Char;
begin
  Result := '';
  for chr in text do
  if CharInSet(chr, ['A'..'Z', 'a'..'z', '-', '_', '.', '~']) or chr.IsDigit then
    Result := Result + chr
  else
    Result := Result + '%' + IntToHex(Ord(chr), 2);
end;
}

procedure ODS(const Msg: String);
begin
  if IsDebuggerPresent then
    OutputDebugString(PChar(Msg));
end;


end.
