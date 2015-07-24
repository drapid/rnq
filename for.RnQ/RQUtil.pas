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
   Controls,
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


function  DestRect(const W, H, cw, ch :Integer): TGPRect; overload;
function  DestRect(const PicSize, DestSize : TGPSize): TGPRect; overload;
function  BoundsSize(srcSize, maxSize : TSize) : TSize; overload;
function  BoundsSize(srcCX, srcCY, maxCX, maxCY : Longint) : TSize; overload;

{function GradientFill(Handle: HDC;
                      pVertex: Pointer;  dwNumVertex: DWORD;
                      pMesh: Pointer;  dwNumMesh: DWORD;
                      dwMode: DWORD): DWORD; stdcall; External 'msimg32.dll';}
//procedure GPFillGradient(DC: HDC; ARect: TRect; StartColor, EndColor: Cardinal); overload;
//procedure GPFillGradient(gr : TGPGraphics; ARect: TRect; StartColor, EndColor: Cardinal); overload;

{function FillGradient(DC: HDC; ARect: TRect; ColorCount: Integer;
  StartColor, EndColor: TColor): Boolean; overload;

function FillGradient2(DC: HDC; ARect: TRect; ColorCount: Integer;
  StartColor, EndColor: TColor): Boolean; overload;
}


  function  str2html(const s:string):string;
  function  strFromHTML(const s:string):string;

  function  dateTocoolstr(d:Tdatetime):string;
  function  datetimeToStrMinMax(dt:Tdatetime; min:Tdatetime; max:Tdatetime):string;

procedure showForm(frm:Tform); overload;

  function absPath(const fn:string):boolean;
  function ExtractFileNameOnly(const fn : String) : String;

  procedure msgDlg(msg: string; NeedTransl: Boolean; kind: TMsgDlgType; const uid: AnsiString = '');
  function logTimestamp:string;

  procedure drawTxt(hnd: Thandle; x,y: integer; const s: string);
  procedure drawTxtL(hnd: Thandle; x,y: integer; const s: pchar; L: integer);
  function  txtSize(hnd: Thandle; const s: string):Tsize;
  function  txtSizeL(hnd: Thandle; s: pchar; L: integer):Tsize;
  function  mousePos:Tpoint;
  function  into(p:Tpoint; r:Trect):boolean;

 procedure RestartApp;


 procedure LoadTranslit;
 procedure UnLoadTranslit;
 function  Translit(const s : String) : String;
function GetShellVersion: Cardinal;
function TxtFromInt(Int: Integer {3 digits}): String;

  procedure SoundPlay(fn:string); overload;
  procedure SoundPlay(fs: TMemoryStream); overload;
  procedure SoundStop;
  procedure SoundInit;
  procedure SoundReset;
  procedure SoundUnInit;

  function ExistsFlash: Boolean;
 {$IFNDEF DELPHI9_UP}
  function ThemeControl(AControl: TControl): Boolean;
 {$ENDIF DELPHI9_UP}
//  function DelayedFailureHook(dliNotify: dliNotification; pdli: PDelayLoadInfo): Pointer; stdcall;

type
  Pmsg = ^Tmsg;
  Tmsg = record
     text:string;
     UID : AnsiString;
     kind:TMsgDlgType;
     time:Tdatetime;
//     cnt : tcontact;
    end;


var
  masterMute : Boolean = false;
//  msgs :array of Tmsg;

implementation
uses
  sysutils, StrUtils, math, DateUtils,

//  MSACMX,
//  ComObj,
  Themes,
  CommCtrl,
  MMSystem, ActiveX, //ShockwaveFlashObjects_TLB,
 {$IFDEF UNICODE}
   AnsiStrings,
 {$ENDIF UNICODE}
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

function absPath(const fn:string):boolean;
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

function str2html(const s: string): string;
begin
result:=template(s, [
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
result:=template(s, [
  '&amp;', '&',
  '&quot;', '"',
  '&lt;', '<',
  '&gt;', '>',
  '<br>', CRLF
//  '<br>', #13,
//  '<br>', #10,
]);
end; // str2html


procedure msgDlg(msg:string; NeedTransl : Boolean; kind:TMsgDlgType; const uid : AnsiString = '');
const
  kind2str:array [TmsgDlgType] of string=('WARNING','ERROR','INFO','','');
begin
  if NeedTransl then
    msg := getTranslation(msg);

 {$IFDEF RNQ}
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
  if frm=NIL then exit;
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
begin textOut(hnd, x,y, PChar(s), length(s)) end;

procedure drawTxtL(hnd: Thandle; x, y: integer; const s: pchar; L: integer);
begin textOut(hnd, x,y, s, L) end;

function txtSize(hnd: Thandle; const s: string): TSize;
begin GetTextExtentPoint32(hnd, pchar(s), length(s), result) end;

function txtSizeL(hnd: Thandle; s: pchar; L: integer): TSize;
begin GetTextExtentPoint32(hnd,s,l,result) end;

function mousePos: Tpoint;
begin getCursorPos(result) end;

function into(p: Tpoint; r: Trect): boolean;
begin result:=(r.Left <= p.x) and (r.right >= p.x) and (r.top <= p.y) and (r.bottom >= p.y) end;


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
  txt : RawByteString;
  v, k : RawByteString;
  so : TStrObj;
begin
  TranslitList := TStringList.create;
  TranslitList.Sorted := false;
  txt:= loadfileA(myPath+ 'translit.txt');
  while txt>'' do
   try
    v:=chopline(txt);
    v:=trim(chop('#',v));
    if v='' then Continue;
    k := trim(chop('-', v));
    v := trim(v);
    if (k='') or (v = '') then Continue;
    so :=TStrObj.Create;
    so.str := v;
    TranslitList.AddObject(k, so)
   except;
   end;
  TranslitList.CaseSensitive := True;
  TranslitList.Sorted := True;
  TranslitList.Sort;
end;

function Translit(const s : String) : String;
var
  i, k : Integer;
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
{$IFDEF CPUX64}
  bass_dll_x64_FN = 'bassx64.dll';
{$ELSE ~CPUX64}
{$ENDIF CPUX64}
  bass_dll_FN = 'bass.dll';
var
 b : Boolean;
begin
  audioPresent:=FALSE;
 {$IFDEF RNQ_PLAYER}
  if not Assigned(RnQbPlayer) then
    RnQbPlayer:= TBASSplayer.Create(nil);
  audioPresent:= RnQbPlayer.PlayerReady;

 {$ELSE RNQ_PLAYER}

{$IFDEF CPUX64}
 b := Load_BASSDLL(bass_dll_x64_FN);
 if not b then
{$ENDIF CPUX64}
   b := Load_BASSDLL(bass_dll_FN);
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
    audioPresent:=FALSE;
    Unload_BASSDLL;
    msgDlg('Error initializing audio!', True, mtError);
   end
 {$IFDEF DELPHI9_UP}// By Rapid D
  else
    audioPresent:=TRUE;
 {$ENDIF DELPHI9_UP}// By Rapid D
 end
 else
 audioPresent:=FALSE;
 {$ENDIF RNQ_PLAYER}
end;


procedure SoundPlay(fn: string);
begin
 if masterMute or disablesounds or (not playSounds) then exit;
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
  if disablesounds or (not playSounds) then exit;
  if not audioPresent then
    PlaySound(nil, 0, SND_ASYNC+SND_NODEFAULT + SND_NOWAIT)
//   else
//    BASS_ChannelStop(Soundhndl);
end;

function sendMCIcommand(cmd:PChar):string;
var
  res:array [0..100] of char;
  trash:Thandle;
begin
trash:=0; // shut up compiler
mciSendString(cmd, res, length(res), trash);
result:=res;
end; // sendMCI

procedure SoundPlay(fs: TMemoryStream);
var
// p : Pointer;
//  a : array of byte;
  sz : Int64;
begin

  if masterMute or disablesounds or (not playSounds) then exit;
  sz := fs.Seek(0, soEnd);
  if sz < 2 then exit;
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

function GetShellVersion: Cardinal;
begin
  if ShellVersion=0
   then ShellVersion:=GetFileVersion ('shell32.dll');
  Result:=ShellVersion;
end;



function transpColor(cl : TColor; alpha : Byte): TColor;
var
 dw : Cardinal;
 cf : Double;
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
 iArr:array[1..3] of Integer;
 res, line: String;
 i,k: Integer;
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

function BoundsSize(srcCX, srcCY, maxCX, maxCY : Longint) : TSize;
begin
  if (srcCX > maxCX )
   or (srcCY > maxCY) then
  begin
   if srcCX * maxCY < srcCY * maxCX then
     begin
       Result.cx := maxCY * srcCX div srcCY;
//       Result.cx := MulDiv(maxCY, srcCX, srcCY);
       Result.cy := maxCY;
     end
    else
     begin
       Result.cx := maxCX;
       Result.cy := maxCX * srcCY div srcCX;
//       Result.cy := MulDiv(maxCX, srcCY, srcCX);
     end;
  end
  else
   begin
    result.cx := srcCX;
    result.cy := srcCY;
   end;
end;

function BoundsSize(srcSize, maxSize : TSize) : TSize;
begin
  if (srcSize.cx > maxSize.cx )
   or (srcSize.cy > maxSize.cy) then
  begin
   if srcSize.cx * maxSize.cy < srcSize.cy * maxSize.cx then
     begin
       Result.cx := maxSize.cy*srcSize.cx div srcSize.cy;
//       Result.cx := MulDiv(maxSize.cy, srcSize.cx, srcSize.cy);
       Result.cy := maxSize.cy;
     end
    else
     begin
       Result.cx := maxSize.cx;
       Result.cy := maxSize.cx*srcSize.cy div srcSize.cx;
     end;
  end
  else
   result := srcSize;
end;

{function DestRect(W, H, cw, ch :Integer): TRect;
const
  Stretch = false;
  Proportional = True;
  Center  = True;  
var
//  w, h, cw, ch: Integer;
  xyaspect: Double;
begin
//  w := Picture.GetWidth;
//  h := Picture.GetHeight;
//  cw := ClientWidth;
//  ch := ClientHeight;
  if Stretch or (Proportional and ((w > cw) or (h > ch))) then
  begin
    if Proportional and (w > 0) and (h > 0) then
    begin
      xyaspect := w / h;
      if w > h then
      begin
        w := cw;
        h := Trunc(cw / xyaspect);
        if h > ch then  // woops, too big
        begin
          h := ch;
          w := Trunc(ch * xyaspect);
        end;
      end
      else
      begin
        h := ch;
        w := Trunc(ch * xyaspect);
        if w > cw then  // woops, too big
        begin
          w := cw;
          h := Trunc(cw / xyaspect);
        end;
      end;
    end
    else
    begin
      w := cw;
      h := ch;
    end;
  end;

  with Result do
  begin
    Left := 0;
    Top := 0;
    Right := w;
    Bottom := h;
  end;

  if Center then
    OffsetRect(Result, (cw - w) div 2, (ch - h) div 2);
end;}

function DestRect(const W, H, cw, ch :Integer): TGPRect;
const
  Stretch = false;
  Proportional = True;
  Center  = True;
var
//  w, h, cw, ch: Integer;
  xyaspect: Double;
//  i, j : Integer;
begin
//  w := Picture.GetWidth;
//  h := Picture.GetHeight;
//  cw := ClientWidth;
//  ch := ClientHeight;
  with Result do
  begin
//    X := 0;
//    Y := 0;
    Width := min(cW, w);
    Height := min(cH, h);
  end;

  if Stretch or (Proportional and ((w > cw) or (h > ch))) then
  begin
    if Proportional and (w > 0) and (h > 0) then
    begin
      xyaspect := w / h;
      if w > h then
      begin
//        w := cw;
//        Result.Width := cw;
        Result.Height := Trunc(cw / xyaspect);
        if Result.Height > ch then  // woops, too big
        begin
          Result.Height := ch;
          Result.Width := Trunc(ch * xyaspect);
        end;
      end
      else
      begin
//        h := ch;
        Result.Width := Trunc(ch * xyaspect);
        if Result.Width > cw then  // woops, too big
        begin
          Result.Width := cw;
          Result.Height := Trunc(cw / xyaspect);
        end;
      end;
    end
{    else
    begin
      w := cw;
      h := ch;
    end;}
  end;

  if Center then
   begin
//    OffsetRect(Result, (cw - w) div 2, (ch - h) div 2);
//     inc(Result.X, (cw - w) div 2);
//     inc(Result.Y, (ch - h) div 2);
     Result.X := (cw - Result.Width) div 2;
     Result.Y := (ch - Result.Height) div 2;
   end;
end;

function  DestRect(const PicSize, DestSize : TGPSize): TGPRect;
const
  Stretch = false;
  Proportional = True;
  Center  = True;
var
//  w, h, cw, ch: Integer;
  xyaspect: Double;
begin
//  w := Picture.GetWidth;
//  h := Picture.GetHeight;
//  cw := ClientWidth;
//  ch := ClientHeight;
//  Result.size := DestSize;
  with Result do
  begin
//    X := 0;
//    Y := 0;
    Width := min(DestSize.Width, PicSize.Width);
    Height := min(DestSize.Height, PicSize.Height);
  end;
  if Stretch or (Proportional and ((PicSize.Width > DestSize.Width)
                               or (PicSize.Height > DestSize.Height))) then
  begin
    if Proportional and (PicSize.Width > 0) and (PicSize.Height > 0) then
    begin
      xyaspect := PicSize.Width / PicSize.Height;
      if PicSize.Width > PicSize.Height then
      begin
//        Result.Width := DestSize.Width;
        Result.Height := Trunc(DestSize.Width / xyaspect);
        if Result.Height > DestSize.Height then  // woops, too big
        begin
          Result.Height := DestSize.Height;
          Result.Width := Trunc(DestSize.Height * xyaspect);
        end;
      end
      else
      begin
//        Result.Height := DestSize.Height;
        Result.Width := Trunc(DestSize.Height * xyaspect);
        if Result.Width > DestSize.Width then  // woops, too big
        begin
          Result.Width := DestSize.Width;
          Result.Height := Trunc(DestSize.Width / xyaspect);
        end;
      end;
    end
{    else
    begin
      Result.Width := DestSize.Width;
      Result.Height := DestSize.Height;
    end;}
  end
  ;
{
  with Result do
  begin
    X := 0;
    Y := 0;
    Width := w;
    Height := h;
  end;
}
  if Center then
   begin
//    OffsetRect(Result, (cw - w) div 2, (ch - h) div 2);
//     inc(Result.X, (DestSize.Width - Result.Width) div 2);
//     inc(Result.Y, (DestSize.Height - Result.Height) div 2);
     Result.X := (DestSize.Width - Result.Width) div 2;
     Result.Y := (DestSize.Height - Result.Height) div 2;
   end
  else
   begin
     Result.X := 0;
     Result.Y := 0;
   end
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
  if AControl = nil then exit;
  Result := (not (csDesigning in AControl.ComponentState) and ThemeServices.ThemesEnabled) or
            ((csDesigning in AControl.ComponentState) and (AControl.Parent <> nil) and
             (ThemeServices.ThemesEnabled //and not UnthemedDesigner(AControl.Parent)
             )
             );
end;
 {$ENDIF DELPHI9_UP}


procedure drawCoolText(cnv:Tcanvas; const text:string);
var
  i,l,n,escpos:integer;
  r:Trect;
  st:Tfontstyles;
  startX:integer;

  procedure turnStyle(v:graphics.TFontStyle);
  begin
  if v in st then st:=st-[v] else st:=st-[v];
  cnv.font.style:=st;
  end;

begin
i:=1;
r:=cnv.ClipRect;
l:=length(text);
st:=cnv.font.Style;
startX:=cnv.penpos.x;
while i<=l do
  begin
  escpos:=i;
  while (escpos<=l) and (text[escpos]<>#27) do inc(escpos);
  if escpos>l then n:=l-i+1
  else n:=escpos-i;
  r.Left:=cnv.PenPos.X;
  r.top:=cnv.PenPos.y;
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

function datetimeToStrMinMax(dt: Tdatetime; min: Tdatetime; max: Tdatetime): string; overload;
begin
if dt=0 then
  result:=''
else
  if (dt<min) or (dt>max) then
    result:=getTranslation('Invalid')
  else
    result:=formatDatetime(timeformat.info, dt);
end; // datetimeToStrMinMax

function dateTocoolstr(d: Tdatetime): string;
begin
case trunc(now)-trunc(d) of
  0: result:=getTranslation('Today');
  1: result:=getTranslation('Yesterday');
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
begin result:=formatDatetime(timeformat.log, now)+'> ' end;




end.
