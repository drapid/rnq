{
Copyright (C) 2002-2004  Massimo Melina (www.rejetto.com)

This file is part of &RQ.

    &RQ is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    &RQ is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with &RQ; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
}
unit hook;
{$I Compilers.inc}
{$I RnQConfig.inc}
{$I NoRTTI.inc}

interface

uses
  windows, sysutils, messages, classes;

 {$IFNDEF NO_WIN98}
const
  HOOK_VER=5;
  DLLname='hook.dll';
  mapfile='andrqHook5';
type
  Tshared=record
    sign:array [1..3] of char;
    ver:integer;
    runs:integer;
    keyMoved :integer;
    end;
 {$ENDIF WIN98}

procedure installHook(hdl : THandle);
//procedure installHook;
procedure uninstallHook;
//function  isHooked:boolean; {$IFDEF DELPHI_9_UP} inline; {$ENDIF DELPHI_9_UP}
function isMoved : Boolean;

var
 {$IFNDEF NO_WIN98}
  shared:^Tshared;
 {$ENDIF WIN98}
  isHooked  : boolean;
  isLocked  : Boolean = false; 

  function RegisterSessionNotification(Wnd: HWND; dwFlags: DWORD): Boolean; 
  function UnRegisterSessionNotification(Wnd: HWND): Boolean; 

implementation

uses
  globalLib, utilLib, RQLog;

type
  TintFun=function:integer;
const
  // The WM_WTSSESSION_CHANGE message notifies applications of changes in session state. 
  WM_WTSSESSION_CHANGE = $2B1; 

  // wParam values: 
{  WTS_CONSOLE_CONNECT = 1; 
  WTS_CONSOLE_DISCONNECT = 2; 
  WTS_REMOTE_CONNECT = 3; 
  WTS_REMOTE_DISCONNECT = 4; 
  WTS_SESSION_LOGON = 5; 
  WTS_SESSION_LOGOFF = 6; 
  WTS_SESSION_LOCK = 7; 
  WTS_SESSION_UNLOCK = 8; 
  WTS_SESSION_REMOTE_CONTROL = 9;}

  // Only session notifications involving the session attached to by the window 
  // identified by the hWnd parameter value are to be received. 
  NOTIFY_FOR_THIS_SESSION = 0; 
  // All session notifications are to be received. 
  NOTIFY_FOR_ALL_SESSIONS = 1; 

var
 {$IFNDEF NO_WIN98}
  hookOn, hookOff, hookVer : procedure; stdcall;
  fileHnd, DLLhnd:Thandle;
 {$ENDIF NO_WIN98}
  oldHook : Boolean;
  FRegisteredSessionNotification : Boolean;
  SessNotifHndl : THandle;
 {$IFNDEF NO_WIN98}
   lastMousePos :Tpoint;
   lastKeybPos :integer;
 {$ENDIF NO_WIN98}
  GetLII  : function (var plii: TLastInputInfo): BOOL; stdcall;

//  GetLastInputInfo

 {$IFNDEF NO_WIN98}
procedure unload;
begin
if shared<>NIL then
  begin
  if shared^.runs=0 then
    hookOff;
  UnmapViewOfFile(shared);
  shared:=NIL;
  end;
if fileHnd<>0 then
  begin
  CloseHandle(fileHnd);
  fileHnd:=0;
  end;
if DLLhnd<>0 then
  begin
  loggaEvt('hook.dll: unloading');
  FreeLibrary(DLLhnd);
  DLLhnd:=0;
  end;
end; // unload
 {$ENDIF WIN98}

procedure installHook(hdl : THandle);
var
 hndl : THandle;
begin
 SessNotifHndl := hdl;
 FRegisteredSessionNotification := RegisterSessionNotification(SessNotifHndl, NOTIFY_FOR_THIS_SESSION);
 if Win32MajorVersion >= 5 then
 begin
   hndl := GetModuleHandle('user32.dll');
   @GetLII := GetProcAddress(hndl, 'GetLastInputInfo');
   if @GetLII = NIL then Exit;
   isHooked:=TRUE;
   oldHook := false;
 end
 {$IFNDEF NO_WIN98}
 else
 begin
  // load DLL
  DLLhnd:=LoadLibrary(PChar(DLLname));
  if DLLhnd = 0 then
    begin
    loggaEvt('hook.dll: unable to load');
    unload;
    exit;
    end;
  @hookOn :=GetProcAddress(DLLhnd, 'hookOn');
  @hookOff:=GetProcAddress(DLLhnd, 'hookOff');
  @hookVer:=GetProcAddress(DLLhnd, 'hookVer');
  if not assigned(hookOn)
  or not assigned(hookOff)
  or not assigned(hookVer)
  or (TintFun(HookVer) <> HOOK_VER) then
    begin
    loggaEvt('hook.dll: wrong version');
    unload;
    exit;
    end;
  // open mapped file
  fileHnd:=OpenFileMapping(FILE_MAP_WRITE,False,mapfile);
  if fileHnd=0 then
    begin
    if TintFun(hookOn)<>0 then
      begin
      loggaEvt('hook.dll: unable to init');
      unload;
      exit;
      end;
    fileHnd:=OpenFileMapping(FILE_MAP_WRITE,False,mapfile);
    if fileHnd=0 then
      begin
      loggaEvt('hook.dll: unable to communicate');
      unload;
      exit;
      end;
    end;
  shared:=MapViewOfFile(fileHnd,FILE_MAP_WRITE,0,0,0);
  if shared=NIL then
    loggaEvt('hook.dll: unable to communicate(2)')
  else
    if (shared^.sign<>'&RQ') or (shared^.ver<>HOOK_VER) then
      loggaEvt('hook.dll: wrong version')
    else
      begin
      loggaEvt('hook.dll: on');
      inc(shared^.runs);
      oldHook := True;
      isHooked:=TRUE;
      exit;
      end;
  unload;
 end;
 {$ENDIF NO_WIN98}
end; // installHook

procedure uninstallHook;
begin
  if not isHooked then exit;
  if FRegisteredSessionNotification then
    UnRegisterSessionNotification(SessNotifHndl) ;
  SessNotifHndl := 0;
  isHooked:=FALSE;
 {$IFNDEF NO_WIN98}
  if oldHook then
  begin
    dec(shared^.runs);
    loggaEvt('hook.dll: off');
    unload;
  end;
 {$ENDIF WIN98}
end; // uninstallHook

//function isHooked:boolean; {$IFDEF DELPHI_9_UP} inline; {$ENDIF DELPHI_9_UP}
//begin result:=hooked end;
//

function LastInput: DWord;
var
  LInput: TLastInputInfo;
begin
  LInput.cbSize := SizeOf(TLastInputInfo);
  GetLII(LInput);
  Result := GetTickCount - LInput.dwTime;
end;

function isMoved : Boolean;
 {$IFNDEF NO_WIN98}
var
  pt:Tpoint;
 {$ENDIF NO_WIN98}
begin
 result := False;
 {$IFNDEF NO_WIN98}
 if oldHook then
  begin
    pt:=mousePos;
    // track mouse activity
    if (pt.x<>lastMousePos.x) or (pt.y<>lastMousePos.y) or (shared^.keyMoved<>lastKeybPos) then
      begin
       lastMousePos:=pt;
       lastKeybPos:=shared^.keyMoved;
       result := True;
      end;
  end
 else
 {$ENDIF WIN98}
    if (LastInput+5 < autoaway.time) then
      result := True;
end;

function RegisterSessionNotification(Wnd: HWND; dwFlags: DWORD): Boolean; 
  // The RegisterSessionNotification function registers the specified window 
  // to receive session change notifications. 
  // Parameters: 
  // hWnd: Handle of the window to receive session change notifications. 
  // dwFlags: Specifies which session notifications are to be received: 
  // (NOTIFY_FOR_THIS_SESSION, NOTIFY_FOR_ALL_SESSIONS) 
type 
  TWTSRegisterSessionNotification = function(Wnd: HWND; dwFlags: DWORD): BOOL; stdcall; 
var 
  hWTSapi32dll: THandle; 
  WTSRegisterSessionNotification: TWTSRegisterSessionNotification; 
begin 
  Result := False; 
  hWTSAPI32DLL := LoadLibrary('Wtsapi32.dll'); 
  if (hWTSAPI32DLL > 0) then 
  begin 
    try @WTSRegisterSessionNotification := 
        GetProcAddress(hWTSAPI32DLL, 'WTSRegisterSessionNotification'); 
      if Assigned(WTSRegisterSessionNotification) then 
      begin 
        Result:= WTSRegisterSessionNotification(Wnd, dwFlags); 
      end; 
    finally 
      if hWTSAPI32DLL > 0 then 
        FreeLibrary(hWTSAPI32DLL); 
    end; 
  end; 
end; 

function UnRegisterSessionNotification(Wnd: HWND): Boolean;
  // The RegisterSessionNotification function unregisters the specified window 
  // Parameters: 
  // hWnd: Handle to the window 
type 
  TWTSUnRegisterSessionNotification = function(Wnd: HWND): BOOL; stdcall; 
var 
  hWTSapi32dll: THandle; 
  WTSUnRegisterSessionNotification: TWTSUnRegisterSessionNotification; 
begin 
  Result := False; 
  hWTSAPI32DLL := LoadLibrary('Wtsapi32.dll'); 
  if (hWTSAPI32DLL > 0) then 
  begin 
    try @WTSUnRegisterSessionNotification := 
        GetProcAddress(hWTSAPI32DLL, 'WTSUnRegisterSessionNotification'); 
      if Assigned(WTSUnRegisterSessionNotification) then 
      begin 
        Result:= WTSUnRegisterSessionNotification(Wnd); 
      end; 
    finally 
      if hWTSAPI32DLL > 0 then 
        FreeLibrary(hWTSAPI32DLL); 
    end; 
  end; 
end; 

function IsFullScreenMode() : Boolean;
var
  w, h : Integer;
  Wnd : HWND;
  rcWindow : TRECT;
begin
  w := GetSystemMetrics(SM_CXSCREEN);
  h := GetSystemMetrics(SM_CYSCREEN);

//  Wnd := 0;
//  repeat
//    Wnd := FindWindowEx(0, Wnd, NIL, NIL);
    Wnd := GetForegroundWindow;
    if Wnd >0 then
    if (GetWindowLong(Wnd, GWL_EXSTYLE) and WS_EX_TOPMOST)>0 then
    begin
      GetWindowRect(Wnd, rcWindow);
      if ((w = (rcWindow.right - rcWindow.left)) and
         (h = (rcWindow.bottom - rcWindow.top))) then
        begin
           result := true;
           Exit;
        end;
    end;
//  until Wnd = 0;
  result := false;
end;


begin
  isHooked:=FALSE;
  SessNotifHndl := 0;
  FRegisteredSessionNotification := false;
 {$IFNDEF NO_WIN98}
  shared:=NIL;
  DLLhnd:=0;
  fileHnd:=0;
 {$ENDIF WIN98}
end.
