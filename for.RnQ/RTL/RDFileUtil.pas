{
This file is part of R&Q.
Under same license
}
unit RDFileUtil;
{$I ForRnQConfig.inc}
{$I NoRTTI.inc}

interface
uses
   Windows, RDGlobal,
 {$IFDEF USE_ZIP}
  RnQZip,
 {$ENDIF USE_ZIP}
 {$IFDEF USE_RAR}
//   ztvUnRar,
  unrar,
 {$ENDIF USE_RAR}
 {$IFDEF USE_7Z}
   SevenZip,
 {$ENDIF USE_7Z}

    Classes;

type
  TPathType =  (pt_path
      {$IFDEF USE_ZIP}
         , pt_zip
      {$ENDIF USE_ZIP}
      {$IFDEF USE_RAR}
         , pt_rar
      {$ENDIF USE_RAR}
      {$IFDEF USE_7Z}
         , pt_7z
      {$ENDIF USE_7Z}
    );

  TThemePath = record
    pathType: TPathType;
    fn, subfn: string;
  end;

  TThemeSourcePath = record
    pathType: TPathType;
{    case TPathType of
      pt_path: (path: string[255]);
      pt_zip: (zp: TZipFile);
//    end;}
    path: string;
    ArcFile: String;
    {$IFDEF USE_ZIP}
//      zp: TKAZip;
      zp: TZipFile;
//      zp: TVCLUnZip;
    {$ENDIF USE_ZIP}
    {$IFDEF USE_RAR}
//      rarFile: String;
       RarHnd: THandle;
//      rr: TUnRar;
    {$ENDIF USE_RAR}
      {$IFDEF USE_7Z}
//       z7: TSevenZip;
//       z7: T7zInArchive;
       z7: I7zInArchive;
      {$ENDIF USE_7Z}
 end;

// file management
 {$IFDEF USE_RAR}
  function RARCallbackProc(msg: UINT; UserData, P1, P2: integer): integer; stdcall;
 {$ENDIF USE_RAR}

  function loadFile(pt: TThemeSourcePath; fn: String): RawByteString; overload;
  function loadFile(pt: TThemeSourcePath; fn: String; var ResStream: TStream): Boolean; overload;
  function ExistsFile(pt: TThemeSourcePath; fn: String): Boolean;
  function  GetStream(const fn: String): TStream;
//  function  loadFile(fn:string): RawByteString; overload;
  function loadFileA(const fn: String): RawByteString; overload;
  function  loadFile(fs: TStream; const StreamName: String): AnsiString; overload;
  function  loadFile(const fn: String; from: int64=0; size: int64=-1): RawByteString; overload;
  function  saveFile2(const fn: String; const data: RawByteString;
               needSafe: Boolean = false; MakeBackups: Boolean = false): boolean;
  function  saveTextFile(const fn: String; const s: String): Boolean;
  function  fileIsWritible(const fn: String): boolean;
  function  sizeOfFile(const fn: String): int64;
  function  partDeleteFile(fn: String; from, length: integer): boolean;
  function  CreateDirRecursive(const fpath: String): Boolean;

  {$IFDEF USE_ZIP}
  function  loadFromZipOrFile(zp: TZipFile; const uPath: String;
                              const fn: String): RawByteString;
  {$ENDIF}
  function NeedPassForFile(pt: TThemeSourcePath; fn: string): Boolean;

//  procedure WorkThread(LV: Pointer); stdcall;

implementation
  uses
// {$IFDEF USE_ZIP}
//  KAZip,
//  SXZipUtils,
//   VCLUnZip,
//  SciZipFile,
// {$ENDIF USE_ZIP}
// {$IFDEF USE_RAR}
//   ztvUnRar,
// {$ENDIF USE_RAR}
(*
 {$IFDEF RNQ}
    RQUtil, RnQGlobal,
    RnQLangs,
    RnQDialogs,
 {$ENDIF RNQ}
*)
    RDUtils,
    StrUtils,
    SysUtils
    ;

function  ExistsFile(pt: TThemeSourcePath; fn: string): Boolean;
  function fullpath(const fn: string): string;
  begin if ansipos(':',fn)=0 then result:=pt.path+fn else result:=fn end;
   {$IFDEF USE_RAR}
var
  hArcData: THandle;
  RHCode, PFCode: Integer;
  CmtBuf: array[0..Pred(16384)] of Char;
//  HeaderData: RARHeaderData;
  HeaderDataEx: RARHeaderDataEx;
  OpenArchiveData: RAROpenArchiveDataEx;
  Operation: Integer;
  WeLoadedDLL : Boolean;
//  Mode: Integer;
  s: String;
   {$ENDIF USE_RAR}
begin
  Result := False;
  case pt.pathType of
    pt_path:
     begin
       result := FileExists(fullpath(fn))
     end;
   {$IFDEF USE_ZIP}
    pt_zip:
          if Assigned(pt.zp) then
           begin
    //          i := pt.zp.Entries.IndexOf(pt.path+ fn);
              result := pt.zp.IndexOf(pt.path+ fn) >= 0;
           end;
   {$ENDIF USE_ZIP}
   {$IFDEF USE_7Z}
    pt_7z:
          if Assigned(pt.z7) then
           begin
           //  ZipFile.CentralDirectory
//              i := pt.z7.GetIndexByFilename(pt.path+ fn);
             s := pt.path + fn;
             isFound := False;
              for I := 0 to pt.z7.NumberOfItems - 1 do
//              if (pt.z7.getItemPath(i) =pt.path) and
//                 (pt.z7.GetItemName(i) = fn) then
               if (pt.z7.getItemPath(i) = s) then
                begin
                  Result := True;
                  Exit;
                end;
           end
         else
           result := false;
   {$ENDIF USE_7Z}
    {$IFDEF USE_RAR}
     pt_rar:
//      if Assigned(ts.rr) then
       if aRARGetDllVersion > 0 then
       begin
         if not IsRARDLLLoaded then
           begin
            LoadRarLibrary;
            WeLoadedDLL := IsRARDLLLoaded;
           end
          else
            WeLoadedDLL := false;
         if IsRARDLLLoaded then
//          i := ts.zp.Entries.IndexOf(ts.path+ fn);
//          if i >=0 then
           begin
             Result := False;
            if pt.RarHnd = 0 then
              begin
 {$IFDEF UNICODE}
                OpenArchiveData.ArcName := '';
                OpenArchiveData.ArcNameW := PWideChar(pt.ArcFile);
 {$ELSE nonUNICODE}
                OpenArchiveData.ArcName := PAnsiChar(pt.ArcFile);
                OpenArchiveData.ArcNameW := '';
 {$ENDIF UNICODE}
                OpenArchiveData.CmtBuf := @CmtBuf;
                OpenArchiveData.CmtBufSize := SizeOf(CmtBuf);
                OpenArchiveData.OpenMode := RAR_OM_EXTRACT;
                hArcData := RAROpenArchiveEx(OpenArchiveData);
                if (OpenArchiveData.OpenResult <> 0) then
                begin
          //        OutOpenArchiveError(OpenArchiveData.OpenResult, ArcName);
                  Exit;
                end;
//                pt.RarHnd := hArcData;
              end
             else
              hArcData := pt.RarHnd;

      //      ShowArcInfo(OpenArchiveData.Flags, ArcName);

      //      if (OpenArchiveData.CmtState = 1) then
      //        ShowComment(CmtBuf);

//            mode := EM_PRINT;
//            RARSetCallback (hArcData, RARCallbackProc, NIL);

//            HeaderData.CmtBuf := nil;
            HeaderDataEx.CmtBuf := nil;

            repeat
//              RHCode := RARReadHeader(hArcData, HeaderData);
              RHCode := RARReadHeaderEx(hArcData, HeaderDataEx);
              if RHCode <> 0 then
                Break;

      {        case Mode of
                EM_EXTRACT: Write(CR, 'Extracting ', SFmt(HeaderData.FileName, 45));
                EM_TEST:    Write(CR, 'Testing ', SFmt(HeaderData.FileName, 45));
                EM_PRINT:   Write(CR, 'Printing ', SFmt(HeaderData.FileName, 45), CR);
              end;
      }
  {$IFDEF UNICODE}
              s := LowerCase(StrPas(HeaderDataEx.FileNameW));
  {$ELSE nonUNICODE}
              s := LowerCase(StrPas(HeaderDataEx.FileName));
  {$ENDIF UNICODE}
              if {( and faDirectory = 0) and} (s = LowerCase(pt.path+fn)) then
                Operation := RAR_TEST
               else
                Operation := RAR_SKIP;
//              PFCode := RARProcessFile(hArcData, Operation, nil, nil);
              if Operation <> RAR_SKIP then
                begin
                 Result := True;
                 Break;
                end;
              if (PFCode = 0) then
      //          Write(' Ok')
              else begin
      //          OutProcessFileError(PFCode);
                Break;
              end;
            until False;

      //      if (RHCode = ERAR_BAD_DATA) then
      //        Write(CR, 'File header broken');
            if hArcData <> pt.RarHnd then
             RARCloseArchive(hArcData);
//            result := loadFile(ZipStream);
//            result := CreateAni(ZipStream, b);
//            ResStream.Free;
//             Result := True;
           end;
         if WeLoadedDLL then
           UnLoadRarLibrary;
       end
      else
     Result := False;
    {$ENDIF USE_RAR}
//    else
//     Result := False;
  end;
end;

function loadFile(pt: TThemeSourcePath; fn: string): RawByteString;
  function fullpath(const fn: string): string;
  begin if ansipos(':',fn)=0 then result:=pt.path+fn else result:=fn end;
var
  ZipStream: TMemoryStream;
begin
  if pt.pathType = pt_path then
   result := loadFileA(fullpath(fn))
  else
   begin
     ZipStream := NIL;
     if loadFile(pt, fn, Tstream(ZipStream)) then
       result := loadFile(ZipStream, pt.path+ fn)
      else
       result := '';
     if Assigned(ZipStream) then
      try
       ZipStream.Free;
       except
      end;
   end;
end;

{$IFDEF USE_RAR}
function RARCallbackProc(msg: UINT; UserData, P1, P2: integer) :integer; stdcall;
  var
//    Ch: Char;
  //  I: Integer;
//    C: PChar;
    buf: RawByteString;
//    str : TMemoryStream;
  begin
    Result := 0;
    case msg of
  {    UCM_CHANGEVOLUME:
        if (P2 = RAR_VOL_ASK) then begin
          Write(CR, 'Insert disk with ', PChar(P1), ' and press ''Enter'' or enter ''Q'' to exit ');
          Readln(Ch);
          if (UpCase (Ch) = 'Q') then
            Result := -1;
        end;
      UCM_NEEDPASSWORD:
        begin
          Write(CR, 'Please enter the password for this archive: ');
          Readln(S);
          C := PChar(S);
          Move(pointer(C)^, pointer(p1)^, StrLen(C) + 1);
            //+1 to copy the zero
        end;
  }
      UCM_PROCESSDATA: begin
        if (UserData <> 0) then// and (PINT (UserData)^ = EM_PRINT) then
        begin
          SetLength(buf, p2);
//          str := Pointer(UserData);
//          CopyMemory(@buf[1], Pointer(P1), P2);
          Move(Pointer(P1)^, Pointer(buf)^, p2);
  //        Flush (Output);
          TStream(Pointer(UserData)^).WriteBuffer(Pointer(buf)^, P2);
//          Form1.Memo1.Lines.Add(s);
          buf := '';
          // Windows.WriteFile fails on big data
  //        for I := 0 to P2 - 1 do
  //          Write(PChar(P1 + I)^);
  //        Flush (Output);
        end;
      end;
    end;
  end;
{$ENDIF USE_RAR}
function  loadFile(pt: TThemeSourcePath; fn: string; var ResStream: TStream):Boolean;
  function fullpath(const fn: string): string;
  begin if ansipos(':',fn)=0 then result:=pt.path+fn else result:=fn end;
   { $IFDEF USE_ZIP}
var
//  ZipStream : TMemoryStream;
  tStr : TStream;
  i : Integer;
   {$IFDEF USE_7Z}
  isFound : Boolean;
   {$ENDIF USE_7Z}
   { $ENDIF USE_ZIP}
   {$IFDEF USE_RAR}
var
  hArcData: THandle;
  RHCode, PFCode: Integer;
  CmtBuf: array[0..Pred(16384)] of Char;
//  HeaderData: RARHeaderData;
  HeaderDataEx: RARHeaderDataEx;
  OpenArchiveData: RAROpenArchiveDataEx;
  Operation: Integer;
  WeLoadedDLL : Boolean;
//  Mode: Integer;
  s: String;
   {$ENDIF USE_RAR}
begin
  Result := False;
  case pt.pathType of
    pt_path:
     begin
      tStr := GetStream(fullpath(fn));
      if Assigned(tStr) then
       begin
        if not Assigned(ResStream) then
          ResStream := TMemoryStream.Create;
        ResStream.Size := 0;
        ResStream.CopyFrom(tStr, tStr.Size);
        tStr.Free;
//        tStr := NIL;
        Result := True;
       end;
     end;
   {$IFDEF USE_ZIP}
    pt_zip:
          if Assigned(pt.zp) then
           begin
    //          i := pt.zp.Entries.IndexOf(pt.path+ fn);
              i := pt.zp.IndexOf(pt.path+ fn);
              if i >=0 then
               begin
                if not Assigned(ResStream) then
                  ResStream := TMemoryStream.Create;
                ResStream.Size := 0;
                ResStream.Position := 0;
                Result := pt.zp.ExtractToStream(i, ResStream);
    //          pt.zp.WriteFileToStream(ZipStream, pt.path+ fn);
    //          pt.zp.UnZipToStream(ZipStream, pt.path+ fn);
               end
           end;
   {$ENDIF USE_ZIP}
   {$IFDEF USE_7Z}
    pt_7z:
          if Assigned(pt.z7) then
           begin
           //  ZipFile.CentralDirectory
//              i := pt.z7.GetIndexByFilename(pt.path+ fn);
             s := pt.path + fn;
             isFound := False;
              for I := 0 to pt.z7.NumberOfItems - 1 do
//              if (pt.z7.getItemPath(i) =pt.path) and
//                 (pt.z7.GetItemName(i) = fn) then
               if (pt.z7.getItemPath(i) = s) then
                begin
                  isFound := True;
                  break;
                end;
              if isFound and (i >=0) then
               begin
//                ZipStream:= TMemoryStream.Create;
//                ZipStream.Clear;
                if not Assigned(ResStream) then
                  ResStream := TMemoryStream.Create;
                ResStream.Size := 0;
//                Result := pt.z7.ExtractToStreamF(i, ResStream) >= 0;
                pt.z7.ExtractItem(i, ResStream, false);
                ResStream.Position := 0;
    //          pt.zp.WriteFileToStream(ZipStream, pt.path+ fn);
    //            pt.zp.UnZipToStream(ZipStream, pt.path+ fn);
    //            ZipStream.SaveToFile(ExtractFilePath(pt.zp.FileName) + fn);
    //            Result := loadPic(ExtractFilePath(pt.zp.FileName) + fn, bmp, idx);
//                result := loadPic(ZipStream, bmp, idx);
//                if not result then
//                 ZipStream.Free;
                Result := True;
               end;
           end
         else
           result := false;
   {$ENDIF USE_7Z}
    {$IFDEF USE_RAR}
     pt_rar:
//      if Assigned(ts.rr) then
       if aRARGetDllVersion > 0 then
       begin
         if not IsRARDLLLoaded then
           begin
            LoadRarLibrary;
            WeLoadedDLL := IsRARDLLLoaded;
           end
          else
            WeLoadedDLL := false;
         if IsRARDLLLoaded then
//          i := ts.zp.Entries.IndexOf(ts.path+ fn);
//          if i >=0 then
           begin
             if not Assigned(ResStream) then
               ResStream := TMemoryStream.Create;
             ResStream.Size := 0;
             Result := False;
            if pt.RarHnd = 0 then
              begin
 {$IFDEF UNICODE}
                OpenArchiveData.ArcName := '';
                OpenArchiveData.ArcNameW := PWideChar(pt.ArcFile);
 {$ELSE nonUNICODE}
                OpenArchiveData.ArcName := PAnsiChar(pt.ArcFile);
                OpenArchiveData.ArcNameW := '';
 {$ENDIF UNICODE}
                OpenArchiveData.CmtBuf := @CmtBuf;
                OpenArchiveData.CmtBufSize := SizeOf(CmtBuf);
                OpenArchiveData.OpenMode := RAR_OM_EXTRACT;
                hArcData := RAROpenArchiveEx(OpenArchiveData);
                if (OpenArchiveData.OpenResult <> 0) then
                begin
          //        OutOpenArchiveError(OpenArchiveData.OpenResult, ArcName);
                  Exit;
                end;
//                pt.RarHnd := hArcData;
              end
             else
              hArcData := pt.RarHnd;

      //      ShowArcInfo(OpenArchiveData.Flags, ArcName);

      //      if (OpenArchiveData.CmtState = 1) then
      //        ShowComment(CmtBuf);

//            mode := EM_PRINT;
            RARSetCallback (hArcData, RARCallbackProc, Integer (@ResStream));
      //      RARSetCallback (hArcData, CallbackProc, Integer (@PRINT));

//            HeaderData.CmtBuf := nil;
            HeaderDataEx.CmtBuf := nil;

            repeat
//              RHCode := RARReadHeader(hArcData, HeaderData);
              RHCode := RARReadHeaderEx(hArcData, HeaderDataEx);
              if RHCode <> 0 then
                Break;

      {        case Mode of
                EM_EXTRACT: Write(CR, 'Extracting ', SFmt(HeaderData.FileName, 45));
                EM_TEST:    Write(CR, 'Testing ', SFmt(HeaderData.FileName, 45));
                EM_PRINT:   Write(CR, 'Printing ', SFmt(HeaderData.FileName, 45), CR);
              end;
      }
  {$IFDEF UNICODE}
              s := LowerCase(StrPas(HeaderDataEx.FileNameW));
  {$ELSE nonUNICODE}
              s := LowerCase(StrPas(HeaderDataEx.FileName));
  {$ENDIF UNICODE}
              if {( and faDirectory = 0) and} (s = LowerCase(pt.path+fn)) then
                Operation := RAR_TEST
               else
                Operation := RAR_SKIP;
              PFCode := RARProcessFile(hArcData, Operation, nil, nil);
              if Operation <> RAR_SKIP then
                begin
                 Result := True;
                 Break;
                end; 
              if (PFCode = 0) then
      //          Write(' Ok')
              else begin
      //          OutProcessFileError(PFCode);
                Break;
              end;
            until False;

      //      if (RHCode = ERAR_BAD_DATA) then
      //        Write(CR, 'File header broken');
            if hArcData <> pt.RarHnd then
             RARCloseArchive(hArcData);
//            result := loadFile(ZipStream);
//            result := CreateAni(ZipStream, b);
//            ResStream.Free;
//             Result := True;
           end;
         if WeLoadedDLL then
           UnLoadRarLibrary;
       end
      else
     Result := False;
    {$ENDIF USE_RAR}
//    else
//     Result := False;
  end;
end;

function NeedPassForFile(pt: TThemeSourcePath; fn: string):Boolean;
var
  i : Integer;
   {$IFDEF USE_RAR}
var
  hArcData: THandle;
  RHCode, PFCode: Integer;
  CmtBuf: array[0..Pred(16384)] of AnsiChar;
//  HeaderData: RARHeaderData;
  HeaderDataEx: RARHeaderDataEx;
  OpenArchiveData: RAROpenArchiveDataEx;
  Operation: Integer;
  WeLoadedDLL : Boolean;
//  Mode: Integer;
  s : String;
   {$ENDIF USE_RAR}
begin
  Result := False;
  case pt.pathType of
    pt_path: Result := false;
   {$IFDEF USE_ZIP}
    pt_zip:
          if Assigned(pt.zp) then
           begin
    //          i := pt.zp.Entries.IndexOf(pt.path+ fn);
              i := pt.zp.IndexOf(pt.path+ fn);
              if i >=0 then
               begin
                Result := pt.zp.IsEncrypted(i);
               end
           end;
   {$ENDIF USE_ZIP}
   {$IFDEF USE_7Z}
    pt_7z:
         Result := false;
{          if Assigned(pt.z7) then
           begin
              i := pt.z7.GetIndexByFilename(pt.path+ fn);
              if i >=0 then
               begin
                Result := pt.z7.
               end;
           end;}
   {$ENDIF USE_7Z}
    {$IFDEF USE_RAR}
     pt_rar:
//      if Assigned(ts.rr) then
       if aRARGetDllVersion > 0 then
       begin
         if not IsRARDLLLoaded then
           begin
            LoadRarLibrary;
            WeLoadedDLL := IsRARDLLLoaded;
           end
          else
            WeLoadedDLL := false;
         if IsRARDLLLoaded then
//          i := ts.zp.Entries.IndexOf(ts.path+ fn);
//          if i >=0 then
           begin
             Result := False;
            if pt.RarHnd = 0 then
              begin
 {$IFDEF UNICODE}
                OpenArchiveData.ArcName := '';
                OpenArchiveData.ArcNameW := PChar(pt.ArcFile);
 {$ELSE nonUNICODE}
                OpenArchiveData.ArcName := PAnsiChar(pt.ArcFile);
                OpenArchiveData.ArcNameW := '';
 {$ENDIF UNICODE}
                OpenArchiveData.CmtBuf := @CmtBuf;
                OpenArchiveData.CmtBufSize := SizeOf(CmtBuf);
                OpenArchiveData.OpenMode := RAR_OM_LIST;
                hArcData := RAROpenArchiveEx(OpenArchiveData);
                if (OpenArchiveData.OpenResult <> 0) then
                begin
          //        OutOpenArchiveError(OpenArchiveData.OpenResult, ArcName);
                  Exit;
                end;
//                pt.RarHnd := hArcData;
              end
             else
              hArcData := pt.RarHnd;
      //      ShowArcInfo(OpenArchiveData.Flags, ArcName);

      //      if (OpenArchiveData.CmtState = 1) then
      //        ShowComment(CmtBuf);

//            mode := EM_PRINT;
            RARSetCallback (hArcData, RARCallbackProc, Integer (@Result));
      //      RARSetCallback (hArcData, CallbackProc, Integer (@PRINT));

//            HeaderData.CmtBuf := nil;
            HeaderDataEx.CmtBuf := nil;

            repeat
//              RHCode := RARReadHeader(hArcData, HeaderData);
              RHCode := RARReadHeaderEx(hArcData, HeaderDataEx);
              if RHCode <> 0 then
                Break;

      {        case Mode of
                EM_EXTRACT: Write(CR, 'Extracting ', SFmt(HeaderData.FileName, 45));
                EM_TEST:    Write(CR, 'Testing ', SFmt(HeaderData.FileName, 45));
                EM_PRINT:   Write(CR, 'Printing ', SFmt(HeaderData.FileName, 45), CR);
              end;
      }
  {$IFDEF UNICODE}
              s := LowerCase(StrPas(HeaderDataEx.FileNameW));
  {$ELSE nonUNICODE}
              s := LowerCase(StrPas(HeaderDataEx.FileName));
  {$ENDIF UNICODE}
              if {( and faDirectory = 0) and} (s = LowerCase(pt.path+fn)) then
                Operation := RAR_TEST
               else
                Operation := RAR_SKIP;
              PFCode := RARProcessFile(hArcData, Operation, nil, nil);
              if Operation <> RAR_SKIP then
                begin
                 Result := True;
                 Break;
                end;
              if (PFCode = 0) then
      //          Write(' Ok')
              else begin
      //          OutProcessFileError(PFCode);
                Break;
              end;
            until False;

      //      if (RHCode = ERAR_BAD_DATA) then
      //        Write(CR, 'File header broken');
            if hArcData <> pt.RarHnd then
             RARCloseArchive(hArcData);
//            result := loadFile(ZipStream);
//            result := CreateAni(ZipStream, b);
//            ResStream.Free;
//             Result := True;
           end;
         if WeLoadedDLL then
           UnLoadRarLibrary;
       end
      else
     Result := False;
    {$ENDIF USE_RAR}
//    else
//     Result := False;
  end;
end;


function GetStream(const fn: String): TStream;
//var
// fs: TFileStream;
begin
  result := NIL;
  if not FileExists(fn) then
    exit;
  try
    result := TFileStream.Create(fn, fmOpenRead or fmShareDenyNone);
  except
    result := NIL;
  end;
end;

{function loadFile(fn: string): RawByteString;
var
 fs: TFileStream;
begin
  result:='';
  if not FileExists(fn) then exit;
  try
    fs := TFileStream.Create(fn, fmOpenRead or fmShareDenyNone);
    setLength(result, fs.Size);
    if fs.Size > 1 then
      fs.Read(result[1], length(result))
     else
      result := '';
    fs.Free;
  except
    result := '';
  end;
end; // loadFile
}
function  loadFileA(const fn: string): RawByteString; overload;
var
 fs : TFileStream;
begin
  result:='';
  if not FileExists(fn) then exit;
  try
    fs := TFileStream.Create(fn, fmOpenRead or fmShareDenyNone);
    setLength(result, fs.Size);
    if fs.Size > 1 then
      fs.Read(Pointer(result)^, length(result))
     else
      result := '';
    fs.Free;
  except
    result := '';
  end;
end; // loadFile


function validFilepath(const fn: string; acceptUnits: boolean=TRUE): boolean;
//type
//  TcharSet = set of char;

  function poss(chars: TSysCharSet; const s: string; ofs: integer=1): integer;
  begin
    for result := ofs to length(s) do
      if s[result] in chars then
        exit;
    result := 0;
  end; // poss
var
  withUnit: boolean;
begin
  withUnit := (length(fn) > 2) and (upcase(fn[1]) in ['A'..'Z']) and (fn[2] = ':');

  result := (fn > '')
  and (posEx(':', fn, IfThen(withUnit,3,1)) = 0)
  and (poss([#0..#31,'?','*','"','<','>','|'], fn) = 0)
  and (length(fn) <= 255+IfThen(withUnit, 2));
end;

function isAbsolutePath(const path: string): boolean;
begin
  result := (path > '') and (path[1] = '\') or (length(path) > 1) and (path[2] = ':')
end;

function loadFile(const fn: string; from: int64=0; size: int64=-1): RawByteString;
var
 fs : TFileStream;
begin
  result:='';
  if not validFilepath(fn) then
    exit;
  if not isAbsolutePath(fn) then
    chDir(extractFilePath(ExpandFileName(paramStr(0))));
  if not FileExists(fn) then exit;
  try
    fs := TFileStream.Create(fn, fmOpenRead or fmShareDenyNone);
    setLength(result, fs.Size);
    if fs.Size > 1 then
      fs.Read(Pointer(result)^, length(result))
     else
      result := '';
    fs.Free;
  except
    result := '';
  end;
end;

function loadFile(fs: TStream; const StreamName: String): AnsiString;
begin
  result := '';
  try
    fs.Position := 0;
    setLength(result, fs.Size);
    if fs.Size > 1 then
      fs.Read(Pointer(result)^, length(result))
     else
      result := '';
//    fs.Free;
  except
    result := '';
  end;
end; // loadFile

function saveFile2(const fn: string; const data: RawByteString;
                  needSafe: Boolean = false; MakeBackups: Boolean = false): boolean;
{var
  f: file;
begin
  result := FALSE;
  if fn='' then
    exit;
  IOresult;
  assignFile(f,fn);
  rewrite(f,1);
  if IOresult <> 0 then
    exit;
  blockWrite(f, data[1], length(data));
  if IOresult <> 0 then
    exit;
  closeFile(f);
  result := TRUE;}
var
 fs: TFileStream;
 md: Word;
// ff, bs: PAnsiChar;
// ff, bs: String;
begin
  result := false;
  if fn = '' then
   exit;
//  if FileExists(fn) then
//    md := fmOpenReadWrite
//   else
  md := fmCreate;
  fs := NIL;
  try
    if needSafe and MakeBackups then
     try
{       ff := fn + #0;
       bs := fn + '.bak'#0;
//      StrPCopy(ff, fn);
//      StrPCopy(bs, fn + '.bak');
      CopyFile(PAnsiChar(@ff[1]), PAnsiChar(@bs[1]), false);
}      
   // Just Rename, cause we write new file
       RenameFile(fn, fn + '.bak');
//      StrDispose(ff);
//      StrDispose(bs);
     except
     end;
    fs := NIL;
    fs := TFileStream.Create(fn, md);
//    fs.Seek(0, soFromEnd);
    fs.Write(data[1], length(data));
    result := True;
    if Assigned(fs) then
     FreeAndNil(fs);
  except
    if Assigned(fs) then
     FreeAndNil(fs);
    result := false;
  end;
end; // saveFile

function saveTextFile(const fn: String; const s: String): Boolean;
const
  UTF8_BOM: RawByteString = RawByteString(#$EF#$BB#$BF);
var
 fs: TFileStream;
 md: Word;
 data: RawByteString;
begin
  result := false;
  if fn = '' then
   exit;
  md := fmCreate;
  fs := NIL;
  try
{    if needSafe and MakeBackups then
     try
       RenameFile(fn, fn + '.bak');
     except
     end;}
    fs := NIL;
    fs := TFileStream.Create(fn, md);
    data := UTF8Encode(s);
    if length(data) > 0 then
      begin
        fs.Write(UTF8_BOM[1], 3);
        fs.Write(data[1], length(data));
      end;
    result := True;
    if Assigned(fs) then
     FreeAndNil(fs);
  except
    if Assigned(fs) then
     FreeAndNil(fs);
    result := false;
  end;
end;

function fileIsWritible(const fn: String): boolean;
var
 fs: TFileStream;
begin
  if not FileExists(fn) then
   result := True
  else
  try
    fs := TFileStream.Create(fn, fmOpenReadWrite);
    result := True;
    fs.Free;
  except
    result := False;
  end;
end;

function partDeleteFile(fn: string; from, length: integer): boolean;
const
  bufdim=64*1024;
var
  f: file;
  buf: string;
  dim, i, left: integer;
begin
result := FALSE;
IOresult;
assignFile(f,fn);
reset(f,1);
if IOresult<>0 then exit;
i:=from;
if length<0 then
  seek(f,from)
else
  begin
  left:=fileSize(f)-from-length;
  setLength(buf, bufdim);
  while left > 0 do
    begin
    seek(f,i+length);
    blockRead(f, buf[1], bufdim, dim);
    seek(f,i);
    blockWrite(f, buf[1], dim);
    inc(i, dim);
    dec(left, dim);
    if IOresult<>0 then exit;
    end;
  if from+length < filesize(f) then
    seek(f,filesize(f)-length)
  else
    seek(f,from);
  end;
truncate(f);
closeFile(f);
result:=IOresult=0;
end; // partDeleteFile

function sizeOfFile(const fn: string): int64;
type
  PInt64Rec = ^Int64Rec;
var
//  f: file;
//  bak: integer;
//  ff: Cardinal;
  FA: WIN32_FILE_ATTRIBUTE_DATA;
begin
//  ff := OpenFile(fn, )
//  size := GetFileSize(ff, 0);
//  CloseHandle(ff);
(*
  IOresult;
  assignFile(f,fn);
  bak := fileMode;
  filemode := 0;
  {$I-}
  reset(f, 1);
  filemode := bak;
  result := FileSize(f);
  closeFile(f);
  if IOresult<>0 then
    result := -1;
*)
  // Took from mormot2
  // 5 times faster than CreateFile, GetFileSizeEx, CloseHandle
  if GetFileAttributesEx(pointer(fn), GetFileExInfoStandard, @FA) then
  begin
    PInt64Rec(@result)^.Lo := FA.nFileSizeLow;
    PInt64Rec(@result)^.Hi := FA.nFileSizeHigh;
  end
  else
    result := 0;
end; // sizeOfFile

function CreateDirRecursive(const fpath: String): Boolean;
var
  s: String;
begin
  s := ExtractFileDir(fpath);
  Result := DirectoryExists(fpath);
  if not Result then
    begin
      Result := CreateDirRecursive(s);
      if Result then
        Result := CreateDir(fpath);
    end;
end;

{$IFDEF USE_ZIP}
function  loadFromZipOrFile(zp: TZipFile; const uPath: String; const fn: String): RawByteString;
var
  i: Integer;
  str: TMemoryStream;
begin
  result := '';
  i := -1;
  if Assigned(Zp) then
    begin
      i := Zp.IndexOf(fn);
      if i >=0 then
       begin
//       Result := Zp.Uncompressed[i];
         str := TMemoryStream.Create;
         zp.ExtractToStream(i, str);
         SetLength(Result, str.Size);
//         CopyMemory(@Result[1], str.Memory, str.Size);
         if Length(Result) > 0 then
//           CopyMemory(Pointer(Result), str.Memory, Length(Result));
           Move(str.Memory^, Pointer(Result)^, Length(Result));
         str.Free;
//         zp.
       end;
    end;
//   else
  if i < 0 then
    Result := loadFileA(uPath+fn);
end;
{$ENDIF USE_ZIP}


end.
