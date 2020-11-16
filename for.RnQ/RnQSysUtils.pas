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


implementation

uses
  wininet, Registry, shellapi, multimon,
  ComObj, ShlObj, StrUtils,
  RQlog,
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
      RQLog.loggaEvtS(s, PIC_ASTERISK);
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
         RQLog.loggaEvtS(s, PIC_ASTERISK);
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
         RQLog.loggaEvtS(s, PIC_ASTERISK);
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
