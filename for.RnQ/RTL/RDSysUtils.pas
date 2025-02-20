{
  This file is part of R&Q.
  Under same license
}
unit RDSysUtils;
{$I ..\ForRnQConfig.inc}
{$I ..\noRTTI.inc}

interface


uses
  windows, sysutils, //IOUtils,
  shellapi, ShlObj,
  {$IFDEF FMX}
  FMX.Types,
  FMX.Forms,
  FMX.Graphics,
  {$ELSE ~FMX}
  Forms, graphics,
  {$ENDIF FMX}
  Classes,
  RDGlobal;

type
  TLogEvt = procedure (s: String; const img: TPicName = '';
                   const pFlush: Boolean = false);


  function  connectionAvailable: boolean;
  function  getDefaultBrowser(const proto: string = 'http'): string;
  procedure exec(const cmd: string; const pars: string = '');
  function  DSiExecute(const commandLine: string;
    visibility: integer = SW_SHOWDEFAULT; const workDir: string = '';
    wait: boolean = false): cardinal;
//  procedure openURL(url: AnsiString);
  procedure openURL(const pURL: String; const useDefaultBrowser: boolean;
                  const browserCmdLine: String);

//��� ����, ����� ������ ��������� Delphi �� ������ ���������� ����� ����� ��������������� ��������� �����:
// Not Found!!!!
//  function RegisterServiceProcess(dwProcessID, dwType: Integer): Integer; stdcall; external 'KERNEL32.DLL';
//  procedure HideFromProcess;

  //function  getSpecialFolder(const what: string): string;
  {$IFNDEF FMX}
  function  getSpecialFolder(const what: Integer): String;
  function  desktopWorkArea(clHandle: THandle): TRect;
  {$ENDIF FMX}
  function  expandEnv(const env: String): String;
  //function  getURLfromFav(fn: string): string;
  function  ForceForegroundWindow(hwnd: THandle; doRestore: boolean=TRUE): Boolean;

  {$IFNDEF FMX}
  //function  getRegion(bmp: TGPBitmap): HRGN;
  function  getRegion(bmp: Tbitmap): HRGN;
  function  isTopMost(frm: Tform): boolean;
  function  setTopMost(frm: Tform; val: boolean): boolean;
  function  formVisible(frm: Tform): boolean;
  procedure applyTaskButton(frm: Tform);
  {$ENDIF FMX}

{ Clipboard }

  function  DSiIsHtmlFormatOnClipboard: boolean;
  function  DSiGetHtmlFormatFromClipboard: string;
  procedure DSiCopyHtmlFormatToClipboard(const sHtml: string; const sText: string = '');

  function  DSiAddApplicationToFirewallExceptionList(const entryName,
    applicationFullPath: string): boolean;

  function  validFilename(const s: string): string;
  {$IFNDEF FMX}
  procedure addLinkToFavorites(const link: string);

  procedure setAppBarSize(const hnd: HWND; const R: TRect;
                          const pCallbackMessage: Integer;
                          const pIsLeft: Boolean);
  {$ENDIF ~FMX}

  procedure dockSet(const hnd: HWND; const pOn: boolean; const pCallbackMessage: Integer);
  function  IsCanShowNotifications: Boolean;
  function  GetScaleFactor(hnd: HWND): Integer; deprecated 'Need to add support for scaled monitors';


  procedure WaitOrKill(var Thread: THandle; Time: cardinal);

  function  resolveLnk(const fn: UnicodeString): UnicodeString;
  procedure ResolveLinkInfo(LinkPath: UnicodeString; Handle: THandle; var ProgramPath, ProgramWorkPath, ProgramInfo, ProgramParams: UnicodeString);

  function  GetThumbFromCache(AFileName: UnicodeString; out Bmp: TBitmap; AMaxSize: Integer = 120): HRESULT;

{$IFDEF FPC}
// // Taskbar notification definitions
type
  QUERY_USER_NOTIFICATION_STATE = Integer;
  {$EXTERNALSYM QUERY_USER_NOTIFICATION_STATE}
const
  QUNS_NOT_PRESENT             = 1;  // The user is not present.  Heuristic check for modes like: screen saver, locked machine, non-active FUS session
  {$EXTERNALSYM QUNS_NOT_PRESENT}
  QUNS_BUSY                    = 2;  // The user is busy.  Heuristic check for modes like: full-screen app
  {$EXTERNALSYM QUNS_BUSY}
  QUNS_RUNNING_D3D_FULL_SCREEN = 3;  // full-screen (exlusive-mode) D3D app
  {$EXTERNALSYM QUNS_RUNNING_D3D_FULL_SCREEN}
  QUNS_PRESENTATION_MODE       = 4;  // Windows presentation mode (laptop feature) is turned on
  {$EXTERNALSYM QUNS_PRESENTATION_MODE}
  QUNS_ACCEPTS_NOTIFICATIONS   = 5;  // notifications can be freely sent
  {$EXTERNALSYM QUNS_ACCEPTS_NOTIFICATIONS}
  QUNS_QUIET_TIME              = 6;   // We are in OOBE quiet period
  {$EXTERNALSYM QUNS_QUIET_TIME}

function SHQueryUserNotificationState(
  var pquns: QUERY_USER_NOTIFICATION_STATE): HResult; stdcall;
{$ENDIF FPC}


const
  CLSID_LocalThumbnailCache: TGuid = '{50EF4544-AC9F-4A8E-B21B-8A26180DB13F}';
  CLSID_SharedBitmap: TGuid = '{4db26476-6787-4046-b836-e8412a9e8a27}';

type
  {$EXTERNALSYM WTS_FLAGS}
  WTS_FLAGS = (
    WTS_EXTRACT = 0,
    WTS_INCACHEONLY = 1,
    WTS_FASTEXTRACT = 2,
    WTS_FORCEEXTRACTION = 4,
    WTS_SLOWRECLAIM = 8,
    WTS_EXTRACTDONOTCACHE = 32,
    WTS_SCALETOREQUESTEDSIZE = 64,
    WTS_SKIPFASTEXTRACT = 128,
    WTS_EXTRACTINPROC = 256
  );

  {$EXTERNALSYM WTS_CACHEFLAGS}
  WTS_CACHEFLAGS = (
    WTS_DEFAULT = 0,
    WTS_LOWQUALITY = 1,
    WTS_CACHED = 2
  );
  PWTS_CACHEFLAGS = ^WTS_CACHEFLAGS;

  {$EXTERNALSYM WTS_ALPHATYPE}
  WTS_ALPHATYPE = (
    WTSAT_UNKNOWN = 0,
    WTSAT_RGB = 1,
    WTSAT_ARGB = 2
  );

  {$EXTERNALSYM WTS_THUMBNAILID}
  WTS_THUMBNAILID = record
    rgbKey: array[0..15] of Byte;
  end;
  PWTS_THUMBNAILID = ^WTS_THUMBNAILID;

  {$EXTERNALSYM ISharedBitmap}
  ISharedBitmap = interface(IUnknown)
    ['{091162a4-bc96-411f-aae8-c5122cd03363}']
    function GetSharedBitmap(out phbm: HBITMAP): HRESULT; stdcall;
    function GetSize(out pSize: TSize): HRESULT; stdcall;
    function GetFormat(out pat: WTS_ALPHATYPE): HRESULT; stdcall;
    function InitializeBitmap(hbm: HBITMAP; wtsAT: WTS_ALPHATYPE): HRESULT; stdcall;
    function Detach(out phbm: HBITMAP): HRESULT; stdcall;
  end;

  {$EXTERNALSYM IThumbnailCache}
  IThumbnailCache = interface(IUnknown)
    ['{F676C15D-596A-4ce2-8234-33996F445DB1}']
    function GetThumbnail(pShellItem: IShellItem; cxyRequestedThumbSize: UINT;
      flags: WTS_FLAGS; out ppvThumb: ISharedBitmap; pOutFlags: PWTS_CACHEFLAGS;
      pThumbnailID: PWTS_THUMBNAILID): HRESULT; stdcall;
    function GetThumbnailByID(thumbnailID: WTS_THUMBNAILID; cxyRequestedThumbSize: UINT;
      out ppvThumb: ISharedBitmap; pOutFlags: PWTS_CACHEFLAGS): HRESULT; stdcall;
  end;

implementation

uses
  wininet, Registry, multimon, ActiveX,
  ComObj, StrUtils,
 {$IFNDEF FMX}
  RnQ.Graphics.Utils,
 {$ENDIF ~FMX}
 {$IFDEF FPC}
  Win32Extra,
 {$ENDIF FPC}
  RDUtils;

{$IFDEF FPC}
  function SHQueryUserNotificationState; external shell32 name 'SHQueryUserNotificationState';

{$ENDIF FPC}

function connectionAvailable: boolean;
var
  d: dword;
begin
  result := InternetGetConnectedState(@d, 0);
end; // connectionAvailable


function getDefaultBrowser(const proto: string='http'): string;
var
  reg: Tregistry;
begin
  result := '';
  reg := Tregistry.create;
  reg.RootKey := HKEY_CLASSES_ROOT;
  if reg.openKey(proto+'\shell\open\command', FALSE) then
    begin
     result := reg.readString('');
     reg.closeKey;
    end;
  reg.free;
end; // getDefaultBrowser

  function DSiExecute(const commandLine: string; visibility: integer;
    const workDir: string; wait: boolean): cardinal;
  var
    processInfo: TProcessInformation;
    startupInfo: TStartupInfo;
    useWorkDir: string;
  begin
    if workDir = '' then
      GetDir(0, useWorkDir)
    else
      useWorkDir := workDir;
    FillChar(startupInfo, SizeOf(startupInfo), #0);
    startupInfo.cb := SizeOf(startupInfo);
    startupInfo.dwFlags := STARTF_USESHOWWINDOW;
    startupInfo.wShowWindow := visibility;
    if not CreateProcess(nil, PChar(commandLine), nil, nil, false,
             CREATE_NEW_CONSOLE or NORMAL_PRIORITY_CLASS, nil,
             PChar(useWorkDir), startupInfo, processInfo)
    then
      Result := MaxInt
    else begin
      if wait then begin
        WaitForSingleObject(processInfo.hProcess, INFINITE);
        GetExitCodeProcess(processInfo.hProcess, Result);
      end
      else
        Result := 0;
      CloseHandle(processInfo.hProcess);
      CloseHandle(processInfo.hThread);
    end;
  end; { DSiExecute }


procedure exec(const cmd: string; const pars: string = '');
//var
// Dir3: IAsyncCall;
//  s : String;
begin
// Dir3 := AsyncCall(@shellexecute, [0, 'open', pchar(cmd), pchar(pars), NIL, SW_SHOWNORMAL]);
// Dir3 := AsyncCallEx(@LoadFromURL2, prm);
// while (AsyncMultiSync([Dir3], True, 10) < 0)or not Dir3.Finished do
//    Application.ProcessMessages;
  shellexecute(0, 'open', PChar(cmd), PChar(pars), NIL, SW_SHOWNORMAL);
{  if pars > '' then
    s := cmd + ' ' + pars
   else
    s := cmd;
  DSiExecute(s, SW_SHOWNORMAL);
 }
end;

procedure OpenURLdef(url: String);
var
//  szTemp: CHAR[256];
  s: String;
begin
//	sprintf(szTemp, "url.dll,FileProtocolHandler %s", url);
  s := 'url.dll,FileProtocolHandler ' + url;
	ShellExecute(0, NIL, 'rundll32.exe', PChar(s), NIL, SW_SHOWNORMAL);
end;


//procedure openURL(url: AnsiString);
procedure openURL(const pURL: String; const useDefaultBrowser: boolean;
                  const browserCmdLine: String);
var
//  prg, par, proto: AnsiString;
  url, prg, par, proto: String;
  i: integer;
begin
  if pURL='' then
    exit;
//  if pos(AnsiString('://'),url) = 0 then
  i := pos('://', pURL);
  if i = 0 then
    proto := ''
   else
    proto := Copy(pURL, 1, i-1);
  i := length(pURL);
  if pURL[i]='?' then
    url := Copy(pURL, 1, i-1)
   else
    url := pURL;
  if (proto='') or (proto='http') then
   begin
    if useDefaultBrowser or (Length(browserCmdLine)=0) then
     begin
      exec(url);
      exit;
     end;
    prg := browserCmdLine;
    par := '';
    // search the point where the filename ends (and then come parameters)
    i := ipos('.exe', prg);
    if i>0 then
     begin
      inc(i, 4);
      if prg[i]='"' then
        inc(i);
     end;
    if i<length(prg) then
     begin
      par := copy(prg,i+1,length(prg))+' ';
      delete(prg, i, length(prg));
     end;
//    if pos(AnsiString('%1'), par) = 0 then
    if pos('%1', par) = 0 then
      par := par+' '+url
     else
//      par := AnsiReplaceStr(par, AnsiString('%1'),url);
      par := AnsiReplaceStr(par, '%1', url);
    exec(prg, trim(par));
   end
  else
   exec(url);
end; // openURL

{
procedure HideFromProcess;
begin
//   if not (csDesigning in ComponentState) then
     RegisterServiceProcess(GetCurrentProcessID, 1);
end;
}

  {$IFNDEF FMX}
function getSpecialFolder(const what: Integer): string;
var
  szPath: array[0..MAX_PATH] of Char;
begin
  if (SUCCEEDED(SHGetFolderPath(Application.MainFormHandle, what, 0, 0, @szPath[0]))) then
    begin
     Result := IncludeTrailingPathDelimiter(StrPas(PChar(@szPath[0])));
    end
   else
    result := '';
end;
  {$ENDIF ~FMX}
{
function getSpecialFolder(const what: string): string;
const
  keyName='Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders';
var
  reg:Tregistry;
begin
reg:=Tregistry.create;
if reg.openKey(keyName, FALSE) then
  begin
  result:=IncludeTrailingPathDelimiter(reg.readString(what));
  reg.closeKey;
  end;
reg.free;
end; // getSpecialFolder}

function expandEnv(const env: String): String;
var
//  path: String;
  len: Integer;
begin
  len := ExpandEnvironmentStrings(PChar(env), PChar(Result), 0);
  if len > 0 then
  begin
    SetLength(Result, len - 1);
    ExpandEnvironmentStrings(PChar(env), PChar(Result), len);
    Result := Result.Trim;
  end else
    Result := env;
end;

  {$IFNDEF FMX}
function getCLMon(clHanlde: THandle): TMonitor;
var
  mon: TMonitor;
begin
  mon := Screen.MonitorFromWindow(clHanlde);
  if (mon = nil) and (Screen.MonitorCount > 0) then
    mon := Screen.Monitors[0];
  result := mon;
end;

function desktopWorkArea(clHandle: THandle): TRect;
var
  mon: TMonitor;
begin
  mon := getCLMon(clHandle);
  if (mon = nil) then
    SystemParametersInfo(SPI_GETWORKAREA, 0, @result, 0)
  else
    result := mon.WorkareaRect;
end;
  {$ENDIF FMX}

function ForceForegroundWindow(hwnd: THandle; doRestore: boolean=TRUE): boolean;
const
  SPI_GETFOREGROUNDLOCKTIMEOUT = $2000;
  SPI_SETFOREGROUNDLOCKTIMEOUT = $2001;
var
  ForegroundThreadID: DWORD;
  ThisThreadID: DWORD;
  timeout: DWORD;
begin
  result := FALSE;
  if IsIconic(hwnd) and isWindowVisible(hwnd) then
    if doRestore then
      ShowWindow(hwnd, SW_RESTORE)
     else
      exit;

  if GetForegroundWindow = hwnd then
  begin
   result := TRUE;
   exit;
  end;
// Windows 98/2000 doesn't want to foreground a window when some other
// window has keyboard focus
  if ((Win32Platform = VER_PLATFORM_WIN32_NT) and (Win32MajorVersion = 5) and (Win32MinorVersion = 0)) // Win2K
     or ((Win32Platform = VER_PLATFORM_WIN32_WINDOWS) and // Win98
         ((Win32MajorVersion > 4) or ((Win32MajorVersion = 4) and (Win32MinorVersion > 0)))
        ) then
   begin
   ForegroundThreadID := GetWindowThreadProcessID(GetForegroundWindow, nil);
   ThisThreadID := GetWindowThreadPRocessId(hwnd, nil);
   if AttachThreadInput(ThisThreadID, ForegroundThreadID, true) then
     begin
     BringWindowToTop(hwnd); // IE 5.5 related hack
     SetForegroundWindow(hwnd);
     AttachThreadInput(ThisThreadID, ForegroundThreadID, false);
     end;
   if GetForegroundWindow<>hwnd then
     begin
     SystemParametersInfo(SPI_GETFOREGROUNDLOCKTIMEOUT, 0, @timeout, 0);
     SystemParametersInfo(SPI_SETFOREGROUNDLOCKTIMEOUT, 0, NIL, SPIF_SENDCHANGE);
     BringWindowToTop(hwnd); // IE 5.5 related hack
     SetForegroundWindow(hWnd);
     SystemParametersInfo(SPI_SETFOREGROUNDLOCKTIMEOUT, 0, TObject(timeout), SPIF_SENDCHANGE);
     end;
  end
else
  begin
    BringWindowToTop(hwnd); // IE 5.5 related hack
    SetForegroundWindow(hwnd);
  end;
  Result := (GetForegroundWindow = hwnd);
end; // ForceForegroundWindow

{
function getURLfromFav(fn: string): string;
var
  f: TextFile;
  s: string;
begin
  result := '';
  assignFile(f,fn);
  reset(f);
  while not eof(f) do
  begin
  readln(f,s);
  if s='[InternetShortcut]' then
    begin
    readln(f,s);
    result:=copy(s,5,length(s));
    break;
    end;
  end;
  closeFile(f);
end; // getURLfromFav
}


function getProxyFromIE: Boolean;
const
  keyName='Software\Microsoft\Windows\CurrentVersion\Internet Settings';
var
  reg: Tregistry;
  prox: String;
begin
  Result := False;
  reg := Tregistry.create;
  if reg.openKey(keyName, FALSE) then
   begin
     prox := reg.ReadString('ProxyServer');
     if prox > '' then
       Result := True;
   end;
  reg.Free;
end;

{
procedure GetProxyData(var ProxyEnabled: boolean; var ProxyServer: string; var ProxyPort: integer);
var
  ProxyInfo: PInternetProxyInfo;
  Len: LongWord;
  i, j: integer;
begin
  Len := 4096;
  ProxyEnabled := false;
  GetMem(ProxyInfo, Len);
  try
    if InternetQueryOption(nil, INTERNET_OPTION_PROXY, ProxyInfo, Len)
    then
      if ProxyInfo^.dwAccessType = INTERNET_OPEN_TYPE_PROXY then
      begin
        ProxyEnabled:= True;
        ProxyServer := ProxyInfo^.lpszProxy;
        showmessage('!');
      end
  finally
    FreeMem(ProxyInfo);
  end;

  if ProxyEnabled and (ProxyServer <> '') then
  begin
    i := Pos('http=', ProxyServer);
    if (i > 0) then
    begin
      Delete(ProxyServer, 1, i+5);
      j := Pos(';', ProxyServer);
      if (j > 0) then
        ProxyServer := Copy(ProxyServer, 1, j-1);
    end;
    i := Pos(':', ProxyServer);
    if (i > 0) then
    begin
      ProxyPort := StrToIntDef(Copy(ProxyServer, i+1, Length(ProxyServer)-i), 0);
      ProxyServer := Copy(ProxyServer, 1, i-1)
    end
  end;
end;
}

  {$IFNDEF FMX}
    {$WARN UNSAFE_CODE OFF}
function getRegion(bmp: Tbitmap): HRGN;
var
  span: HRGN;
  x, y, sx: integer;
  p: ^integer;
  transcolor: integer;

  procedure addspan;
  begin
    span:=CreateRectRgn(sx, y, x, y+1);
    CombineRgn(result, result, span, RGN_OR);
    DeleteObject(span);
    sx := -1;
  end;

begin
  if not bmp.Transparent then
   begin
     result := 0;
     exit;
   end;
  result := CreateRectRgn(0,0,0,0);
  if bmp=NIL then
    exit;
  with bmp do
  begin
//  pixelFormat := pf32bit;
    transcolor := ABCD_ADCB(bmp.TransparentColor AND $FFFFFF);
    for y:=0 to height-1 do
     begin
       p := bmp.scanline[y];
       sx := -1;
       for x:=0 to bmp.width-1 do
        begin
         if (p^ <> transcolor) and (sx < 0) then
           sx := x;
         if (p^ = transcolor) and (sx >= 0) then
           addspan;
         inc(p);
        end;
       if sx >= 0 then
         addspan;
     end;
  end;
end; // getRegion

function getRegion32(bmp: Tbitmap): HRGN;
var
  span: HRGN;
  x, y, sx: integer;
  p: ^integer;
//  transcolor: integer;

  procedure addspan;
  begin
    span := CreateRectRgn(sx, y, x, y+1);
    CombineRgn(result, result, span, RGN_OR);
    DeleteObject(span);
    sx := -1;
  end;

begin
  if not bmp.Transparent then
   begin
     result := 0;
     exit;
   end;
  result := CreateRectRgn(0,0,0,0);
  if bmp=NIL then
    exit;
  with bmp do
  begin
    pixelFormat := pf32bit;
//  transcolor := bmp.TransparentColor AND $FFFFFF;
    for y:=0 to height-1 do
     begin
      p := bmp.scanline[y];
      sx := -1;
      for x:=0 to bmp.width-1 do
       begin
        if (p^ and AlphaMask > 0) and (sx < 0) then
          sx := x;
//        if (p^ <> transcolor) and (sx < 0) then sx:=x;
        if (p^ and AlphaMask = 0) and (sx >= 0) then
          addspan;
        inc(p);
       end;
      if sx >= 0 then
        addspan;
     end;
  end;
end; // getRegion2
    {$WARN UNSAFE_CODE ON}
  {$ENDIF ~FMX}

function isTopMost(frm: Tform): boolean;
begin
  {$IFDEF FMX}
  result := frm.FormStyle = TFormStyle.StayOnTop;
  {$ELSE ~FMX}
  result := Assigned(frm) and ((getWindowLong(frm.handle, GWL_EXSTYLE) and WS_EX_TOPMOST) > 0)
  {$ENDIF FMX}
end; // isTopMost

function setTopMost(frm: Tform; val: boolean): boolean;
//begin frm.FormStyle:=fsStayOnTop;
var
  i: integer;
begin
  if not Assigned(frm) then
     Result := False
   else
with frm do
  begin
  {$IFDEF FMX}
    if val then
      begin
        frm.FormStyle := TFormStyle.StayOnTop;
        frm.BringToFront;
      end
     else
      begin
        if frm.FormStyle = TFormStyle.StayOnTop then
          frm.FormStyle := TFormStyle.Normal
      end;
  {$ELSE ~FMX}
    i := getWindowLong(handle, GWL_EXSTYLE);
    if val then
      begin
      result := setWindowLong(handle, GWL_EXSTYLE,  i or WS_EX_TOPMOST) = i;
      SetWindowPos(Handle, HWND_TOPMOST, 0,0,0,0, SWP_NOMOVE+SWP_NOSIZE+SWP_NOACTIVATE)
      end
    else
      begin
      result := setWindowLong(handle, GWL_EXSTYLE,  i and not WS_EX_TOPMOST) = i;
      SetWindowPos(Handle, HWND_NOTOPMOST, Left, Top, Width, Height, SWP_NOMOVE+SWP_NOSIZE+SWP_NOACTIVATE);
      end;
  {$ENDIF FMX}
  end;
end; // setTopMost

  {$IFNDEF FMX}
function formVisible(frm: Tform): boolean;
begin
  result := (frm<>NIL) and isWindowVisible(frm.handle)
end;
  {$ENDIF ~FMX}


{ Clipboard }

var
  GCF_HTML: UINT;

  {:Checks if HTML format is stored on the clipboard.
    @since   2008-04-29
    @author  gabr
  }
  function DSiIsHtmlFormatOnClipboard: boolean;
  begin
    Result := IsClipboardFormatAvailable(GCF_HTML);
  end; { DSiIsHtmlFormatOnClipboard }

  {:Retrieves HTML format from the clipboard. If there is no HTML format on the clipboard,
    function returns empty string.
    @since   2008-04-29
    @author  MP002, gabr
  }
  function DSiGetHtmlFormatFromClipboard: string;
  var
    hClipData       : THandle;
    idxEndFragment  : integer;
    idxStartFragment: integer;
    pClipData       : PChar;
  begin
    Result := '';
    if DSiIsHtmlFormatOnClipboard then begin
      Win32Check(OpenClipboard(0));
      try
        hClipData := GetClipboardData(GCF_HTML);
        if hClipData <> 0 then begin
          pClipData := GlobalLock(hClipData);
          Win32Check(assigned(pClipData));
          try
            idxStartFragment := Pos('<!--StartFragment-->', pClipData); // len = 20
            idxEndFragment := Pos('<!--EndFragment-->', pClipData);
            if (idxStartFragment >= 0) and (idxEndFragment >= idxStartFragment) then
              Result := Copy(pClipData, idxStartFragment + 20, idxEndFragment - idxStartFragment - 20);
           finally
            GlobalUnlock(hClipData);
          end;
        end;
       finally
        Win32Check(CloseClipboard);
      end;
    end;
  end; { DSiGetHtmlFormatFromClipboard }

  {:Copies HTML (and, optionally, text) format to the clipboard.
    @since   2008-04-29
    @author  MP002, gabr
  }
  procedure DSiCopyHtmlFormatToClipboard(const sHtml, sText: string);

    function MakeFragment(const sHtml: string): string;
    const
      CVersion       = 'Version:1.0'#13#10;
      CStartHTML     = 'StartHTML:';
      CEndHTML       = 'EndHTML:';
      CStartFragment = 'StartFragment:';
      CEndFragment   = 'EndFragment:';
      CHTMLIntro     = '<sHtml><head><title>HTML clipboard</title></head><body><!--StartFragment-->';
      CHTMLExtro     = '<!--EndFragment--></body></sHtml>';
      CNumberLengthAndCR = 10;
      CDescriptionLength = // Let the compiler determine the description length.
        Length(CVersion) + Length(CStartHTML) + Length(CEndHTML) +
        Length(CStartFragment) + Length(CEndFragment) + 4*CNumberLengthAndCR;
    var
      description     : string;
      idxEndFragment  : integer;
      idxEndHtml      : integer;
      idxStartFragment: integer;
      idxStartHtml    : integer;
    begin
      // The sHtml clipboard format is defined by using byte positions in the entire block
      // where sHtml text and fragments start and end. These positions are written in a
      // description. Unfortunately the positions depend on the length of the description
      // but the description may change with varying positions. To solve this dilemma the
      // offsets are converted into fixed length strings which makes it possible to know
      // the description length in advance.
      idxStartHtml := CDescriptionLength;              // position 0 after the description
      idxStartFragment := idxStartHtml + Length(CHTMLIntro);
      idxEndFragment := idxStartFragment + Length(sHtml);
      idxEndHtml := idxEndFragment + Length(CHTMLExtro);
      description := CVersion +
        SysUtils.Format('%s%.8d', [CStartHTML, idxStartHtml]) + #13#10 +
        SysUtils.Format('%s%.8d', [CEndHTML, idxEndHtml]) + #13#10 +
        SysUtils.Format('%s%.8d', [CStartFragment, idxStartFragment]) + #13#10 +
        SysUtils.Format('%s%.8d', [CEndFragment, idxEndFragment]) + #13#10;
      Result := description + CHTMLIntro + sHtml + CHTMLExtro;
    end; { MakeFragment }

  var
    clipFormats: array[0..1] of UINT;
    clipStrings: array[0..1] of string;
    hClipData  : HGLOBAL;
    iFormats   : integer;
    pClipData  : PChar;

  begin { DSiCopyHtmlFormatToClipboard }
    Win32Check(OpenClipBoard(0));
    try
      //most descriptive first as per api docs
      clipStrings[0] := MakeFragment(sHtml);
      if sText = '' then
        clipStrings[1] := sHtml
      else
        clipStrings[1] := sText;
      clipFormats[0] := GCF_HTML;
      clipFormats[1] := CF_TEXT;
      Win32Check(EmptyClipBoard);
      for iFormats := 0 to High(clipStrings) do begin
        if clipStrings[iFormats] = '' then
          continue;
        hClipData := GlobalAlloc(GMEM_DDESHARE + GMEM_MOVEABLE, Length(clipStrings[iFormats]) + 1);
        Win32Check(hClipData <> 0);
        try
          pClipData := GlobalLock(hClipData);
          Win32Check(assigned(pClipData));
          try
    {$WARN UNSAFE_CODE OFF}
            Move(PChar(clipStrings[iFormats])^, pClipData^, Length(clipStrings[iFormats]) + 1);
    {$WARN UNSAFE_CODE ON}
           finally
            GlobalUnlock(hClipData);
          end;
          Win32Check(SetClipboardData(clipFormats[iFormats], hClipData) <> 0);
          hClipData := 0;
        finally
          if hClipData <> 0 then
            GlobalFree(hClipData);
        end;
      end;
     finally
      Win32Check(CloseClipboard);
    end;
  end; { DSiCopyHtmlFormatToClipboard }


  {:Adds application to the list of firewall exceptions. Based on the code at
    http://www.delphi3000.com/articles/article_5021.asp?SK=.
    CoInitialize must be called before using this function.
    @author  gabr
    @since   2009-02-05
  }
const // firewall management constants
  NET_FW_PROFILE_DOMAIN     = 0;
  NET_FW_PROFILE_STANDARD   = 1;
  NET_FW_IP_VERSION_ANY     = 2;
  NET_FW_IP_PROTOCOL_UDP    = 17;
  NET_FW_IP_PROTOCOL_TCP    = 6;
  NET_FW_SCOPE_ALL          = 0;
  NET_FW_SCOPE_LOCAL_SUBNET = 1;

  function DSiAddApplicationToFirewallExceptionList(const entryName,
    applicationFullPath: string): boolean;
  var
    app    : OleVariant;
    fwMgr  : OleVariant;
    profile: OleVariant;
  begin
    Result := false;
    try
      fwMgr := CreateOLEObject('HNetCfg.FwMgr');
      profile := fwMgr.LocalPolicy.CurrentProfile;
      app := CreateOLEObject('HNetCfg.FwAuthorizedApplication');
      app.ProcessImageFileName := applicationFullPath;
      app.Name := EntryName;
      app.Scope := NET_FW_SCOPE_ALL;
      app.IpVersion := NET_FW_IP_VERSION_ANY;
      app.Enabled :=true;
      profile.AuthorizedApplications.Add(app);
      Result := true;
    except
      on E: EOleSysError do
        SetLastError(cardinal(E.ErrorCode));
    end;
  end; { DSiAddApplicationToFirewallExceptionList }

type
  ELoadLibraryError = class(EOSError);
  EGetProcAddressError = class(EOSError);


function CheckAutorun(pKey : String): boolean;
// pKey = 'R&Q_' + lastUser
var
  Registry: TRegistry;
begin
  Registry := TRegistry.Create(KEY_READ);
  result := False;
  try
    Registry.OpenKey('Software\Microsoft\Windows\CurrentVersion\Run', False);
    if (Registry.ReadString(pKey) <> '' ) then
      result := True
  finally
    Registry.Free;
  end;
end;

procedure SetAutorun(const exeFN: String; _on_: boolean; const pKey: String);
// pKey = 'R&Q_' + lastUser
var
  Registry: TRegistry;
  FName: string;
begin
  Registry := TRegistry.Create();
  try
    Registry.OpenKey('Software\Microsoft\Windows\CurrentVersion\Run', False);
    if _on_ then
    begin
      FName := exeFN;
      Registry.WriteString(pKey, FName);
    end
    else
     Registry.DeleteValue(pKey);
  finally
    Registry.Free;
  end;

end;

function validFilename(const s: string): string;
const
  invalid='\/:*?"<>|';
var
  i: integer;
begin
  result := s;
  i := length(result);
  while i > 0 do
   begin
    if pos(result[i], invalid) > 0 then
      delete(result,i,1);
    dec(i);
   end;
end; // validFilename

  {$IFNDEF FMX}
procedure addLinkToFavorites(const link: string);
var
  s: string;
  f: textFile;
begin
//  s:=getSpecialFolder('Favorites')+ PathDelim +getTranslation('from R&Q');
//  s:=getSpecialFolder('Favorites')+ PathDelim + 'R&Q';
  s := getSpecialFolder(CSIDL_FAVORITES)+ PathDelim + 'R&Q';
  mkdir(s);
  IOresult;
  assignFile(F, IncludeTrailingPathDelimiter(s)+validFilename(link)+'.url');
  rewrite(f);
  writeln(f, '[InternetShortcut]');
  writeln(f, 'URL='+link);
  closeFile(f);
end; // addLinkToFavorites
  {$ENDIF ~FMX}

procedure dockSet(const hnd: HWND; const pOn: boolean; const pCallbackMessage: Integer);
var
  abd: APPBARDATA;
begin
  abd.cbsize := sizeOf(abd);
  abd.hWnd := hnd;
  abd.uCallbackMessage := pCallbackMessage;
  {$IFDEF FPC}
  if pOn then
    SHAppBarMessage(ABM_NEW, @abd)
  else
    SHAppBarMessage(ABM_REMOVE, @abd);
  {$ELSE ~FPC}
  if pOn then
    SHAppBarMessage(ABM_NEW, abd)
  else
    SHAppBarMessage(ABM_REMOVE, abd);
  {$ENDIF FPC}
end; // dockSet

  {$IFNDEF FMX}
procedure setAppBarSize(const hnd: HWND; const R: TRect;
                        const pCallbackMessage: Integer;
                        const pIsLeft: Boolean);
var
  abd: APPBARDATA;
  scale: Integer;
  rs: TRect;
begin

  rs := r;
  if Application.MainForm.Scaled then
    begin
      {TODO -oRapid D -cGeneral : Add support for scaled monitors}
      scale := RDSysUtils.GetScaleFactor(hnd);
      if scale <> 100 then
       begin
        rs.Left := MulDiv(r.Left, scale, 100);
        rs.Top := MulDiv(r.Top, scale, 100);
        rs.Bottom := MulDiv(r.Bottom, scale, 100);
        rs.Right := MulDiv(r.Right, scale, 100);
       end
    end;

  abd.cbsize := sizeOf(abd);
  abd.hWnd := hnd;
  abd.uCallbackMessage := pCallbackMessage;
  abd.rc := rs;
  if pIsLeft then
    abd.uedge := ABE_LEFT
   else
    abd.uedge := ABE_RIGHT;
  {$IFDEF FPC}
  SHAppBarMessage(ABM_SETPOS, @abd);
  {$ELSE ~FPC}
  SHAppBarMessage(ABM_SETPOS, abd);
  {$ENDIF FPC}
end; // setAppBarSize
  {$ENDIF ~FMX}


function  IsCanShowNotifications: Boolean;
var
  MachState: Integer;
begin
  Result := True;
  try
    if CheckWin32Version(6, 0) then
     if(SUCCEEDED(SHQueryUserNotificationState(MachState))) then
      Result := MachState <> QUNS_RUNNING_D3D_FULL_SCREEN
   except

  end;
end;


function  GetScaleFactor(hnd: HWND): Integer;
//var
//  hm: HMONITOR;
//  Scale: Integer;
begin
      {TODO -oRapid D -cGeneral : Add support for scaled monitors}
  result := 100;
//
//  hm := MonitorFromWindow(hnd, MONITOR_DEFAULTTONEAREST);
//  hm.
// if SUCCEEDED(GetScaleFactorForMonitor(hm, Scale)) then
//   Result := Scale;
end;

{
const
  CTK_ICON = 1;

function mostRecentFileFrom(path:string):integer;
var
  sr:TsearchRec;
  t:integer;
begin
result:=0;
path:=IncludeTrailingPathDelimiter(path);
if FindFirst(path+'*.*', faAnyFile, sr)=0 then
  repeat
  if sr.time > result then result:=sr.time;
  if (sr.name[1]<>'.') and (sr.Attr and faDirectory >0) then
    begin
    t:=mostRecentFileFrom(path+sr.name+ PathDelim);
    if t > result then result:=t;
    exit;
    end;
  until FindNext(sr) > 0;
findClose(sr);
end; // mostRecentFileFrom
}


  {$IFNDEF FMX}
procedure applyTaskButton(frm:Tform);
var
  i:integer;
begin
//setParent(frm.handle, 0);   //this seems to work not, ugh
  setwindowlong(frm.handle, GWL_HWNDPARENT, 0);
  i:=getWindowLong(frm.handle, GWL_EXSTYLE);
  setWindowLong(frm.handle, GWL_EXSTYLE, i or WS_EX_APPWINDOW);
end;
  {$ENDIF ~FMX}

procedure WaitOrKill(var Thread: THandle; Time: cardinal);
begin
 if Thread=0 then exit;
 if WaitForSingleObject(Thread,Time)=WAIT_TIMEOUT then begin
  TerminateThread(Thread,0);
  CloseHandle(Thread);
  Thread:=0;
 end;
end;

function resolveLnk(const fn: UnicodeString): UnicodeString;
Var
  sl: IShellLinkW;
  buffer: array [0..MAX_PATH] of WideChar;
  fd: TWin32FindDataW;
  fnW: WideString;
begin
  result := fn;
  try
    fnW := result;
    olecheck(coCreateInstance(CLSID_ShellLink, nil, CLSCTX_INPROC_SERVER, IShellLink, sl));
    olecheck((sl as IPersistFile).load(pwidechar(fnW), STGM_READ));
    if (sl as IPersistFile).Load(PWideChar(fnW), STGM_READ) = 0 then begin
      olecheck(sl.resolve(0, SLR_ANY_MATCH or SLR_NO_UI));
     {$IFDEF FPC}
      olecheck(sl.getPath(Buffer, MAX_PATH, @fd, 0));
     {$ELSE ~FPC}
      olecheck(sl.getPath(Buffer, MAX_PATH, fd, 0));
     {$ENDIF FPC}
      result := buffer;
    end;
  except // convertion failed, but keep original filename
  end;
end; // resolveLnk

procedure ResolveLinkInfo(LinkPath: UnicodeString; Handle: THandle; var ProgramPath, ProgramWorkPath, ProgramInfo, ProgramParams: UnicodeString);
Var
   Desc : Array[0..MAX_PATH] of WideChar;
   IU   : IUnknown;
   SL   : IShellLinkW;
   PF   : IPersistFile;
//   HRES : HRESULT;
   FD   : TWin32FindDataW;
begin
  CoInitialize(nil);
  IU := CreateComObject(CLSID_ShellLink);
  SL := IU as IShellLinkW;
  PF := SL as IPersistFile;

  olecheck(PF.Load(PWideChar(WideString(LinkPath)), STGM_READ));
  olecheck(SL.Resolve(Handle, SLR_ANY_MATCH));
 {$IFDEF FPC}
  olecheck(SL.GetPath(Desc, MAX_PATH, @FD, SLGP_UNCPRIORITY));
 {$ELSE ~FPC}
  olecheck(SL.GetPath(Desc, MAX_PATH, FD, SLGP_UNCPRIORITY));
 {$ENDIF FPC}
  ProgramPath := StrPas(Desc);


  SL.GetDescription(Desc, MAX_PATH);
  ProgramInfo := StrPas(Desc);

  SL.GetWorkingDirectory(Desc, MAX_PATH);
  ProgramWorkPath := StrPas(Desc);

  SL.GetArguments(Desc, MAX_PATH);
  ProgramParams := StrPas(Desc);

end;

function GetThumbFromCache(AFileName: UnicodeString; out Bmp: TBitmap; AMaxSize: Integer = 120): HRESULT;
var
  thumbcache: IThumbnailCache;
  sharedbmp: ISharedBitmap;
  shellitem: IShellItem;
//  thumbflags: PWTS_CACHEFLAGS;
//  thumbid: PWTS_THUMBNAILID;
  thumbsize: TSize;
  hBmp: HBITMAP;
  pat: WTS_ALPHATYPE;
begin
  Result := $80000001;
 {$IFDEF FMX}
   Exit;
 {$ELSE ~FMX}

  if not Assigned(Bmp) then
    Exit;
  try
    Result := CoInitialize(Nil);

    Result := CoCreateInstance(
      CLSID_LocalThumbnailCache,
      nil,
      CLSCTX_INPROC,
      IThumbnailCache,
      thumbcache
    );

    if Succeeded(Result) then
    begin
      Result := SHCreateItemFromParsingName(
        PWideChar(AFileName),
        nil,
        IShellItem,
        shellitem
      );

      if Succeeded(Result) then
      begin
        Result := thumbcache.GetThumbnail(
          shellitem,
          AMaxSize,
          WTS_EXTRACT,
          sharedbmp,
          nil, //thumbflags,
          nil //thumbid
        );

        if Succeeded(Result) then
        begin
          sharedbmp.GetSize(thumbsize);
          sharedbmp.GetFormat(pat);

          Result := sharedbmp.GetSharedBitmap(hBmp);
          if Succeeded(Result) then
          begin
            bmp.SetSize(thumbsize.cx, thumbsize.cy);
            bmp.Handle := hBmp;
           {$IFDEF FPC}
            bmp.FreeImage;
           {$ELSE ~FPC}
            bmp.Dormant;
           {$ENDIF FPC}
            if pat = WTSAT_RGB then
              bmp.PixelFormat := pf24bit;

            StretchPic(bmp, AMaxSize, MulDiv(AMaxSize,thumbsize.cy, thumbsize.cx));
            FlipVertical(Bmp);
          end;
        end;

        CoUninitialize;
      end;
    end;
   except
    Result := $80000001;
  end;
 {$ENDIF FMX}
end;

end.
