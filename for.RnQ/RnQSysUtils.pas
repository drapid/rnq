{
  This file is part of R&Q.
  Under same license
}
unit RnQSysUtils;
{$I ForRnQConfig.inc}
{$I NoRTTI.inc}

interface


uses
  windows, sysutils, Forms, graphics, Classes;

  procedure TrimWorkingSet;
  function IsElevated: Boolean;
  function IsTopMostWindow(Wnd: HWND): Boolean;
  function SetTopMostWindow(Wnd: HWND; Val: Boolean): Boolean;

function MenuFadeEnabled: Boolean;
function TooltipFadeEnabled: Boolean;
function SelectionFadeEnabled: Boolean;

implementation

uses
  wininet, Registry, shellapi, multimon,
  ComObj, ShlObj, StrUtils,
 {$IFDEF RNQ}
   RQlog,
 {$ENDIF RNQ}
  RDUtils, RDGlobal, RnQGlobal;

type
  ELoadLibraryError = class(EOSError);
  EGetProcAddressError = class(EOSError);

function DelayedFailureHook(dliNotify: dliNotification; pdli: PDelayLoadInfo): Pointer; stdcall;
var
  s: String;
begin
  Result := nil;
  case dliNotify of
    dliNoteStartProcessing: ;
    dliNotePreLoadLibrary: ;
    dliNotePreGetProcAddress: ;
    dliFailLoadLibrary:
     begin
      s := Format('Failed to load library "%0:s".'#13#10' Error (%1:d) %2:s', [AnsiString(pdli.szDll),
          pdli.dwLastError, SysErrorMessage(pdli.dwLastError)]);
 {$IFDEF RNQ}
//      RQLog.loggaEvtS(s, PIC_ASTERISK);
      RQLog.LogEvent(s, PIC_ASTERISK);
 {$ENDIF RNQ}
      raise EAbort.Create(s);
//      raise ELoadLibraryError.CreateFmt(
//        'Failed to load library "%0:s".'#13#10' Error (%1:d) %2:s',[AnsiString(pdli.szDll),
//          pdli.dwLastError, SysErrorMessage(pdli.dwLastError)]);
     end;
    dliFailGetProcAddress:
      if pdli.dlp.fImportByName then
        begin
         s := Format('Failed to load function "%0:s" from "%1:s"'#13#10' Error (%2:d) %3:s',
          [
           AnsiString(pdli.dlp.szProcName),
           AnsiString(pdli.szDll),
           pdli.dwLastError,
           SysErrorMessage(pdli.dwLastError)]);
 {$IFDEF RNQ}
//         RQLog.loggaEvtS(s, PIC_ASTERISK);
         RQLog.LogEvent(s, PIC_ASTERISK);
 {$ENDIF RNQ}
         raise EAbort.Create(s);
//         raise EGetProcAddressError.CreateFmt(
//            'Failed to load function "%0:s" from "%1:s"'#13#10' Error (%2:d) %3:s',[
//           AnsiString(pdli.dlp.szProcName), AnsiString(pdli.szDll),
//          pdli.dwLastError, SysErrorMessage(pdli.dwLastError)])
        end
      else
        begin
         s := Format('Failed to load function #%0:d from "%1:s"'#13#10' Error (%2:d) %3:s',[
           pdli.dlp.dwOrdinal, AnsiString(pdli.szDll),
          pdli.dwLastError, SysErrorMessage(pdli.dwLastError)]);
 {$IFDEF RNQ}
//         RQLog.loggaEvtS(s, PIC_ASTERISK);
         RQLog.LogEvent(s, PIC_ASTERISK);
 {$ENDIF RNQ}
         raise EAbort.Create(s);
//         raise EGetProcAddressError.CreateFmt(
//            'Failed to load function #%0:d from "%1:s"'#13#10' Error (%2:d) %3:s',[
//           pdli.dlp.dwOrdinal, AnsiString(pdli.szDll),
//          pdli.dwLastError, SysErrorMessage(pdli.dwLastError)]);
        end;

    dliNoteEndProcessing: ;
  end;
end;

procedure TrimWorkingSet;
var
  MainHandle: THandle;
begin
  try
    MainHandle := OpenProcess(PROCESS_ALL_ACCESS, False, GetCurrentProcessID);
    SetProcessWorkingSetSize(MainHandle, High(SIZE_T), High(SIZE_T));
    CloseHandle(MainHandle);
  except end;
end;

function IsElevated: Boolean;
var
  hToken, hProcess: THandle;
  pTokenInformation: pointer;
  ReturnLength: DWord;
  TokenInformation: TTokenElevation;
begin
  Result := False;
  hProcess := GetCurrentProcess;
  try
    if OpenProcessToken(hProcess, TOKEN_QUERY, hToken) then
    try
      TokenInformation.TokenIsElevated := 0;
      pTokenInformation := @TokenInformation;
      GetTokenInformation(hToken, TokenElevation, pTokenInformation, sizeof(TokenInformation), ReturnLength);
      Result := (TokenInformation.TokenIsElevated > 0);
    finally
      CloseHandle(hToken);
    end;
  except
    Result := false;
  end;
end;

function IsTopMostWindow(Wnd: HWND): Boolean;
begin
  Result := (Wnd > 0) and ((GetWindowLongPtr(Wnd, GWL_EXSTYLE) and WS_EX_TOPMOST) > 0);
end;

function SetTopMostWindow(Wnd: HWND; Val: Boolean): Boolean;
var
  ExStyle: Integer;
begin
  ExStyle := GetWindowLongPtr(Wnd, GWL_EXSTYLE);
  if Val then
  begin
    Result := SetWindowLongPtr(Wnd, GWL_EXSTYLE, ExStyle or WS_EX_TOPMOST) = ExStyle;
    SetWindowPos(Wnd, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOMOVE + SWP_NOSIZE + SWP_NOACTIVATE);
  end
    else
  begin
    Result := SetWindowLongPtr(Wnd, GWL_EXSTYLE, ExStyle and not WS_EX_TOPMOST) = ExStyle;
    SetWindowPos(Wnd, HWND_NOTOPMOST, 0, 0, 0, 0, SWP_NOMOVE + SWP_NOSIZE + SWP_NOACTIVATE);
  end;
end;

function MenuFadeEnabled: Boolean;
var
  Animated: BOOL;
  FadeIn: BOOL;
begin
  Animated := False;
  SystemParametersInfo(SPI_GETMENUANIMATION, 0, @Animated, 0);
  FadeIn := False;
  SystemParametersInfo(SPI_GETMENUFADE, 0, @FadeIn, 0);
  Result := Animated and FadeIn;
end;

function TooltipFadeEnabled: Boolean;
var
  Animated: BOOL;
  FadeInOut: BOOL;
begin
  Animated := False;
  SystemParametersInfo(SPI_GETTOOLTIPANIMATION, 0, @Animated, 0);
  FadeInOut := False;
  SystemParametersInfo(SPI_GETTOOLTIPFADE, 0, @FadeInOut, 0);
  Result := Animated and FadeInOut;
end;

function SelectionFadeEnabled: Boolean;
var
  FadeOut: BOOL;
begin
  FadeOut := False;
  SystemParametersInfo(SPI_GETSELECTIONFADE, 0, @FadeOut, 0);
  Result := FadeOut;
end;



(*
initialization
  if debugHook = 0 then
  {$IFDEF COMPILER_16}
    SetDliFailureHook2(DelayedFailureHook);
  {$ELSE ~COMPILER_16}
  SetDliFailureHook(DelayedFailureHook);
  {$ENDIF COMPILER_16}
*)
end.
