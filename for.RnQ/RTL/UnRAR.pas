// Delphi interface unit for UnRAR.dll
// Translated from unrar.h
// Use Delphi 2.0 and higher to compile this module
//
// Ported to Delphi by Eugene Kotlyarov, fidonet: 2:5058/26.9 ek@oris.ru
// Fixed version by Alexey Torgashin <alextp@mail.ru>, 2:5020/604.24@fidonet
//
// Revisions:
// Aug 2001 - changed call convention for TChangeVolProc and TProcessDataProc
//          - added RARGetDllVersion function, see comment below
//
// Jan 2002 - Added RARSetCallback  // eugene
//
// Oct 2002 - Added RARHeaderDataEx, RAROpenArchiveDataEx // eugene

unit UnRAR;

interface

uses Windows;

const
  ERAR_END_ARCHIVE    = 10;
  ERAR_NO_MEMORY      = 11;
  ERAR_BAD_DATA       = 12;
  ERAR_BAD_ARCHIVE    = 13;
  ERAR_UNKNOWN_FORMAT = 14;
  ERAR_EOPEN          = 15;
  ERAR_ECREATE        = 16;
  ERAR_ECLOSE         = 17;
  ERAR_EREAD          = 18;
  ERAR_EWRITE         = 19;
  ERAR_SMALL_BUF      = 20;
  ERAR_UNKNOWN        = 21;

  RAR_OM_LIST         =  0;
  RAR_OM_EXTRACT      =  1;

  RAR_SKIP            =  0;
  RAR_TEST            =  1;
  RAR_EXTRACT         =  2;

  RAR_VOL_ASK         =  0;
  RAR_VOL_NOTIFY      =  1;

  RAR_DLL_VERSION     =  3;

  UCM_CHANGEVOLUME    =  0;
  UCM_PROCESSDATA     =  1;
  UCM_NEEDPASSWORD    =  2;

type
  RARHeaderData = packed record
    ArcName: packed array[0..Pred(260)] of AnsiChar;
    FileName: packed array[0..Pred(260)] of AnsiChar;
    Flags: UINT;
    PackSize: UINT;
    UnpSize: UINT;
    HostOS: UINT;
    FileCRC: UINT;
    FileTime: UINT;
    UnpVer: UINT;
    Method: UINT;
    FileAttr: UINT;
    CmtBuf: PChar;
    CmtBufSize: UINT;
    CmtSize: UINT;
    CmtState: UINT;
  end;

  RARHeaderDataEx = packed record
    ArcName: packed array [0..1023] of Ansichar;
    ArcNameW: packed array [0..1023] of WideChar;
    FileName: packed array [0..1023] of Ansichar;
    FileNameW: packed array [0..1023] of WideChar;
    Flags: UINT;
    PackSize: UINT;
    PackSizeHigh: UINT;
    UnpSize: UINT;
    UnpSizeHigh: UINT;
    HostOS: UINT;
    FileCRC: UINT;
    FileTime: UINT;
    UnpVer: UINT;
    Method: UINT;
    FileAttr: UINT;
    CmtBuf: PChar;
    CmtBufSize: UINT;
    CmtSize: UINT;
    CmtState: UINT;
    Reserved: packed array [0..1023] of UINT;
  end;

  RAROpenArchiveData = packed record
    ArcName: PAnsiChar;
    OpenMode: UINT;
    OpenResult: UINT;
    CmtBuf: PChar;
    CmtBufSize: UINT;
    CmtSize: UINT;
    CmtState: UINT;
  end;

  RAROpenArchiveDataEx = packed record
    ArcName: PAnsiChar;
    ArcNameW: PWideChar;
    OpenMode: UINT;
    OpenResult: UINT;
    CmtBuf: PChar;
    CmtBufSize: UINT;
    CmtSize: UINT;
    CmtState: UINT;
    Flags: UINT;
  Reserved: packed array [0..31] of UINT;
//    Callback : UNRARCALLBACK;
//    UserData : LPARAM;
//    Reserved: packed array [0..28] of UINT;
  end;

  TUnrarCallback = function (Msg: UINT; UserData, P1, P2: Integer) :Integer; stdcall;

const
{$IFDEF WIN64}
  _unrar = 'unrar64.dll';
{$ELSE}
  _unrar = 'unrar.dll';
{$ENDIF}

{function RAROpenArchive(var ArchiveData: RAROpenArchiveData): THandle;
  stdcall; external _unrar;
function RAROpenArchiveEx(var ArchiveData: RAROpenArchiveDataEx): THandle;
  stdcall; external _unrar;
function RARCloseArchive(hArcData: THandle): Integer;
  stdcall; external _unrar;
function RARReadHeader(hArcData: THandle; var HeaderData: RARHeaderData): Integer;
  stdcall; external _unrar;
function RARReadHeaderEx(hArcData: THandle; var HeaderData: RARHeaderDataEx): Integer;
  stdcall; external _unrar;
function RARProcessFile(hArcData: THandle; Operation: Integer; DestPath, DestName: PChar): Integer;
  stdcall; external _unrar;
procedure RARSetCallback(hArcData: THandle; UnrarCallback: TUnrarCallback; UserData: Integer);
  stdcall; external _unrar;
procedure RARSetPassword(hArcData: THandle; Password: PChar);
  stdcall; external _unrar;
}
// Wrapper for DLL's function - old unrar.dll doesn't export RARGetDllVersion
// Returns: -1 = DLL not found; 0 = old ver. (C-style callbacks); >0 = new ver.
function aRARGetDllVersion: integer;

// obsolete functions
type
  TChangeVolProc = function(ArcName: PChar; Mode: Integer): Integer; stdcall;
  TProcessDataProc = function(Addr: PUChar; Size: Integer): Integer; stdcall;

{
procedure RARSetChangeVolProc(hArcData: THandle; ChangeVolProc: TChangeVolProc);
  stdcall; external _unrar;
procedure RARSetProcessDataProc(hArcData: THandle; ProcessDataProc: TProcessDataProc);
  stdcall; external _unrar;
}

var
  // Flag for: Is Dll loaded...
  IsRARDLLLoaded: boolean = false;
  // function Pointer - Dll is always dynamicly loaded
  RAROpenArchive        : function(var ArchiveData: RAROpenArchiveData): THandle; stdcall;
  RAROpenArchiveEx      : function(var ArchiveData: RAROpenArchiveDataEx): THandle; stdcall;
  RARCloseArchive       : function(hArcData: THandle): integer; stdcall;
  RARReadHeader         : function(hArcData: THandle; var HeaderData: RARHeaderData): Integer; stdcall;
  RARReadHeaderEx       : function(hArcData: THandle; var HeaderData: RARHeaderDataEx): Integer; stdcall;
  RARProcessFile        : function(hArcData: THandle; Operation: Integer; DestPath, DestName: PChar): Integer; stdcall;
  RARSetCallback        : procedure(hArcData: THandle; Callback: TUnRarCallback; UserData: longint); stdcall;
  RARSetChangeVolProc   : procedure(hArcData: THandle; ChangeVolProc: TChangeVolProc); stdcall;
  RARSetProcessDataProc : procedure(hArcData: THandle; ProcessDataProc: TProcessDataProc); stdcall;
  RARSetPassword        : procedure(hArcData: THandle; Password: PChar); stdcall;
  RARGetDllVersion      : function:Integer; stdcall;

// helper functions for (un)loading the Dll and check for loaded
procedure LoadRarLibrary;
procedure UnLoadRarLibrary;
function  IsRarLoaded: boolean;

implementation

type
  TRARGetDllVersion = function: integer; stdcall;

var
  // Dll-Handle
  h: THandle;

// Loads the UnRar.dll
procedure LoadRarLibrary;
begin
  // UnRar.dll must exists in typically dll-paths
  // 1. Application-Directory
  // 2. Current Directory
  // 3. System-Directory
  // 4. Windows-Direcory
  // 5. Directories from PATH-Variable
  h := LoadLibrary(_unrar);
  if h <> 0 then
  begin
    IsRARDLLLoaded := true;
    @RAROpenArchive        := GetProcAddress(h, 'RAROpenArchive');
    @RAROpenArchiveEx      := GetProcAddress(h, 'RAROpenArchiveEx');
    @RARCloseArchive       := GetProcAddress(h, 'RARCloseArchive');
    @RARReadHeader         := GetProcAddress(h, 'RARReadHeader');
    @RARReadHeaderEx       := GetProcAddress(h, 'RARReadHeaderEx');
    @RARProcessFile        := GetProcAddress(h, 'RARProcessFile');
    @RARSetCallback        := GetProcAddress(h, 'RARSetCallback');
    @RARSetChangeVolProc   := GetProcAddress(h, 'RARSetChangeVolProc');
    @RARSetProcessDataProc := GetProcAddress(h, 'RARSetProcessDataProc');
    @RARSetPassword        := GetProcAddress(h, 'RARSetPassword');
    @RARGetDllVersion      := GetProcAddress(h, 'RARGetDllVersion');
  end
  else
   IsRARDLLLoaded := false;
end;

// Unloading Library
procedure UnLoadRarLibrary;
begin
  if h <> 0 then
  begin
    FreeLibrary(h);
    IsRARDLLLoaded := false;
    h := 0;
    RAROpenArchive        := nil;
    RAROpenArchiveEx      := nil;
    RARCloseArchive       := nil;
    RARReadHeader         := nil;
    RARReadHeaderEx       := nil;
    RARProcessFile        := nil;
    RARSetCallback        := nil;
    RARSetChangeVolProc   := nil;
    RARSetProcessDataProc := nil;
    RARSetPassword        := nil;
    RARGetDllVersion      := nil;
  end;
end;

// returns true if UnRar.Dll is loaded
function IsRarLoaded: boolean;
begin
  Result := IsRARDLLLoaded;
end;

function aRARGetDllVersion: integer;
var
  h: THandle;
  f: TRARGetDllVersion;
begin
//  h := 0;
//  try
    h := LoadLibrary(_unrar);
    if h = 0 then begin
      Result := -1;
      Exit
    end;
    f := GetProcAddress(h, 'RARGetDllVersion');
    if @f = nil then
      Result := 0
    else
      Result := f;
//  finally
   FreeLibrary(h);
//  end;
end;

{
initialization
  LoadRarLibrary;

finalization
  UnLoadRarLibrary;
}

end.
