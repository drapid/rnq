{
This file is part of R&Q.
Under same license
}
unit RnQ_Avatars;
{$I Compilers.inc}
{$I RnQConfig.inc}
{$I NoRTTI.inc}

interface

uses
  Windows, Forms,
  SysUtils, Classes, Graphics, Controls, ExtCtrls,
  {$IFNDEF NOT_USE_GDIPLUS}
    GDIPAPI,
    GDIPOBJ,
    RnQGraphics,
  {$ELSE}
    RnQGraphics32,
//    RnQAni,
  {$ENDIF NOT_USE_GDIPLUS}
   RDGlobal,
  ICQContacts, RnQProtocol;//, HttpProt;

//const
//   AvatarFile = '%s\%d.jpeg';

//type
//  TPAFormat = (PA_FORMAT_UNK, PA_FORMAT_BMP, PA_FORMAT_JPEG,
//               PA_FORMAT_GIF, PA_FORMAT_PNG, PA_FORMAT_XML);

function FormatAvatarFileName(const APath : String;const AUIN: AnsiString; AFormat: TPAFormat): String;
//function DetectAvatarFormatBuffer(pBuffer: String): TPAFormat;
  {$IFNDEF NOT_USE_GDIPLUS}
function DetectAvatarFormatGUID(fmt: TGUID): TPAFormat;
  {$ENDIF NOT_USE_GDIPLUS}
function GetDomain(url : String) : String;
//function get_flashFile_from_xml(const fn : String; const uin : AnsiString) : String;
//function get_flashFile_from_xml(str: TStream; const uin : AnsiString) : String;
procedure avatars_save_and_load(cnt : TRnQContact; const hash : RawByteString;
                                var str : TMemoryStream);

procedure loadAvatars(const proto : TRnQProtocol; path : String);
procedure updateAvatarFor(c : TRnQContact);
procedure Check_my_avatar(const proto : TRnQProtocol);
procedure ClearAvatar(var cnt : TICQContact);
function  try_load_avatar(c : TICQContact; const hash : RawByteString) :Boolean;
//function try_load_avatar2(bmp:TBitmap; hash : String) :Boolean ;
//function try_load_avatar3(var bmp:TRnQBitmap; const hash : AnsiString) :Boolean;
function LoadAvtByHash(const hash : RawByteString; var bmp : TRnQBitmap;
                       var hasAvatar : Boolean; var pPicFile : String) : Boolean;
procedure updateAvatar(c : TRnQContact{; pWriteLog : boolean = false});

 {$IFDEF PROTOCOL_MRA}
const
  MRA_PHOTO_URL = 'http://obraz.foto.mail.ru/%s/%s/_mrimavatar';
  MRA_PHOTO_THUMB_URL = 'http://obraz.foto.mail.ru/%s/%s/_mrimavatarsmall';
 {$ENDIF PROTOCOL_MRA}


 {$IFDEF PROTOCOL_ICQ}
const
  ICQ_PHOTO_URL = 'http://www.icq.com/img/show_photo.php?uin=';
  ICQ_PHOTO_THUMB_URL = 'http://www.icq.com/img/show_thumb.php?uin=';
  ICQ_PHOTO_AVATAR = 'http://c.icq.com/people/img/show_photo.phpc?uin=%s&th_type=1&gender=%d';
  ICQ_PHOTO_USER_URL = 'http://www.icq.com/img/whitepages/show_user_photo.php?uin=';
type
//  TOnDownloadedProc = Procedure(fn : String; size : Int64; proto : TRnQProtocol; uid : TUID);
  TOnDownloadedProc = Procedure(fn : String; size : Int64; cnt : TRnQContact);
  TLoadURLParams = record
    URL:String;
    fn : String;
    Treshold : LongInt;
    ExtByContent : Boolean;
//    UID : TUID;
//    fProto : TRnQProtocol;
    cnt : TRnQContact;
    Proc : TOnDownloadedProc;
  end;

  function LoadFromURL2(params : TLoadURLParams) : Boolean;
  procedure OnPhotoDownLoaded(fn : String; size : Int64; cnt : TRnQContact);
//  procedure OnPhotoDownLoaded(fn : String; size : Int64; uid : AnsiString);
 {$ENDIF PROTOCOL_ICQ}

var
   AvatarPath: String;

implementation

 uses
   StrUtils, math,
   RQUtil, RnQLangs, RnQDialogs, RnQNet, RnQFileUtil, RDUtils, RnQGlobal,
//   RQlog,
   utilLib, globalLib,
   ICQConsts, ICQv9, Protocol_ICQ,
 {$IFDEF UNICODE}
   AnsiStrings,
 {$ENDIF UNICODE}
 {$IFDEF AVT_IN_DB}
  RnQ2SQL,
  RnQDB,
  DISQLite3Api,
 {$ENDIF AVT_IN_DB}
   roasterLib,
   ShockwaveFlashObjects_TLB,
//    FlashPlayerControl,
   viewinfoDlg, chatDlg;

procedure SaveAvatar(const hash : RawByteString; picFmt : TPAFormat;
                     picType : Integer; const str : TMemoryStream);
var
 {$IFDEF AVT_IN_DB}
//  i : Integer;
//    bType : Integer;
//    hash : RawByteString;
    InsAVTStmt : sqlite3_stmt_ptr;
    Tail : PAnsiChar;
 {$ELSE ~AVT_IN_DB}
  s : String;
 {$ENDIF ~AVT_IN_DB}
begin
  if str.Size = 0 then
    Exit;
 {$IFDEF AVT_IN_DB}
  begin
      begin
        try
          begin
           SQLite3_Prepare_v2(avtDB, PAnsiChar(SQLInsertAVT), Length(SQLInsertAVT), @InsAVTStmt, @Tail);

           sqlite3_bind_blob(InsAVTStmt, 1, PAnsiChar(hash), 16, NIL);
           sqlite3_bind_int (InsAVTStmt, 2, picType);
//           sqlite3_bind_blob(InsAVTStmt, 3, PAnsiChar(blob), Length(blob), nil);
           sqlite3_bind_blob(InsAVTStmt, 3, str.Memory, str.Size, nil);
          end;
         if Sqlite3_Step(InsAVTStmt) = SQLITE_ROW then
           begin
//             Result := True;
           end;
//         SQLite3_Reset(InsAVTStmt);
         SQLite3_Finalize(InsAVTStmt);
        finally
        end;
      end;
  end;
 {$ELSE ~AVT_IN_DB}
  s := AccPath + avtPath + str2hexU(hash) + PAFormat[picFmt];
  str.SaveToFile(s);
 {$ENDIF AVT_IN_DB}
end;

function FormatAvatarFileName(const APath : String;const AUIN: AnsiString; AFormat: TPAFormat): String;
begin
  Result:= Format('%s%s%s', [APath, AUIN, PAFormat[AFormat]]);
end;

{function DetectAvatarFormatBuffer(pBuffer: String): TPAFormat;
var
  s : String;
begin
  s := Copy(pBuffer, 1, 4);
  if s = 'GIF8' then
    Result:= PA_FORMAT_GIF
  else if (s = JPEG_HDR) or (s = JPEG_HDR2) then
    Result:= PA_FORMAT_JPEG
  else if StartsText('BM', s) then
    Result:= PA_FORMAT_BMP
  else if s = '<?xm' then
    Result:= PA_FORMAT_XML
  else if StartsText('‰PNG', s) then
    Result:= PA_FORMAT_PNG
  else
    Result:= PA_FORMAT_UNK;
end;
}
  {$IFNDEF NOT_USE_GDIPLUS}
function DetectAvatarFormatGUID(fmt: TGUID): TPAFormat;
begin
  if IsEqualGUID(fmt, ImageFormatJPEG) then
    result := PA_FORMAT_JPEG
   else
  if IsEqualGUID(fmt, ImageFormatPNG) then
    result := PA_FORMAT_PNG
   else
  if IsEqualGUID(fmt, ImageFormatGIF) then
    result := PA_FORMAT_GIF
   else
  if IsEqualGUID(fmt, ImageFormatBMP) then
    result := PA_FORMAT_BMP
   else
  if IsEqualGUID(fmt, ImageFormatMemoryBMP) then
    result := PA_FORMAT_BMP
   else
    result := PA_FORMAT_UNK;
end;
  {$ENDIF NOT_USE_GDIPLUS}

function GetDomain(url : String) : String;
var
  i, k, l : Integer;
begin
  i := 1;
  if AnsiStartsText('http://', url) then
    Delete(url, 1, 7);
  i := StrUtils.PosEx('/', url,i);
  Delete(url, i, 10000);
  k := 1;
  repeat
   l := k+1;
   k := StrUtils.PosEx('.', url, l);
   if k>0 then
     i := l;
  until k <= 0;
  result := copy(url, i, 10000);
end;

//function get_flashFile_from_xml(const fn : String; const uin : AnsiString) : String;
function get_flashFile_from_xml(str: TStream; const hash : RawByteString;
                    const uin : TUID) : String;
var
 i, k : Integer;
 url, u1 : String;
 s   : RawByteString;
begin
 result := '';
// s := loadFileA(fn);
 setLength(s, str.Size);
 if str.Size > 0 then
  str.Read(Pointer(s)^, length(s));
 i := Pos(AnsiString('<URL>'), s);
//      if matches(s,i, RnQImageTag) then
 if i < 10 then
  exit;
 k := PosEx(AnsiString('</URL>'), s, i+5);
 if k <= 5 then exit;
 url := Copy(s, i+5, k-i-5);
 i := Pos(CRLF, url);
 if i > 5 then
  url := Copy(url, 1, i-1);
 if Pos('icq_player.swf', url) > 0 then
   begin
    if AvatarsNotDnlddInform then
      msgDlg('Unsupported format of flash-avatar', True, mtError, uin);
   end
  else
   begin
    u1 := LowerCase(GetDomain(url));
    if (u1 = 'icq.com') or (u1='oddcast.com')or(u1='rnq.ru') then
     begin
//       result := ChangeFileExt(fn, '.xml.swf');
//       Result := str2hexU(hash) + '.xml.swf';
       Result := AccPath + avtPath + str2hexU(hash) + '.xml.swf';
       if not LoadFromURL(url, result, 0, True) then
         result := '';
     end
    else
     if AvatarsNotDnlddInform then
       msgDlg(getTranslation('Bad address of flash-avatar.\n%s', [url]), False, mtError, uin);
   end;
end;

procedure avatars_save_and_load(cnt : TRnQContact; const hash : RawByteString;
                                var str : TMemoryStream);
var
  s : string;
  PicFmt : TPAFormat;
  bb : Integer;
begin
  PicFmt := DetectFileFormatStream(str);
 {$IFDEF AVT_IN_DB}
  if PicFmt = PA_FORMAT_XML then
    bb := AVTTypeXML
   else
    bb := AVTTypePic;
 {$ELSE ~AVT_IN_DB}
   bb := 0;
 {$ENDIF AVT_IN_DB}
//  s := AccPath + avtPath + str2hexU(hash) + PAFormat[PicFmt];
  SaveAvatar(hash, picFmt, bb, str);
  if cnt is TICQcontact then
    begin
      TICQcontact(cnt).ICQIcon.hash_safe := hash;
         if PicFmt <> PA_FORMAT_UNK then
          if PicFmt = PA_FORMAT_XML then
           begin
            if TicqSession(cnt.fProto).AvatarsAutoGetSWF then
             begin
//               s := get_flashFile_from_xml(s, cnt.UID);
               str.Position := 0;
               s := get_flashFile_from_xml(str, hash, cnt.UID);
               if cnt.icon.ToShow = IS_AVATAR then
               if s > '' then
               begin
                 cnt.icon_Path := s;
//                 if not Assigned(thisICQ.eventContact.iconBmp) then
//                   thisICQ.eventContact.icon := graphics.TBitmap.Create;
//                   thisICQ.eventContact.iconBmp := TGPBitmap.Create;
                 if not loadPic2(s, cnt.icon.Bmp) then
                  begin
                    msgDlg(getTranslation('Could''t load avatar for %s', [cnt.displayed]), False,
                         mtInformation, cnt.UID);
                  end;
                 if LowerCase(ExtractFileExt(s)) = '.swf' then
                   cnt.icon.IsBmp := false
                  else
                   cnt.icon.IsBmp := True
                   ;
//                 if (thisICQ.eventContact.icon.Height = 0)or
//                    (thisICQ.eventContact.icon.Width = 0) then
//                   FreeAndNil(thisICQ.eventContact.icon);
               end;
             end
            else
             if cnt.icon.ToShow = IS_AVATAR then
             begin
              if Assigned(cnt.icon.Bmp) then
               cnt.icon.Bmp.Free;
              cnt.icon.Bmp := NIL;
              if AvatarsNotDnlddInform then
                msgDlg(getTranslation('%s has flash avatar, but it not auto-loaded',
                            [cnt.displayed]), False, mtInformation);
             end;
          end
         else
           begin
            if cnt.icon.ToShow = IS_AVATAR then
             begin
//             if not Assigned(thisICQ.eventContact.icon) then
//               thisICQ.eventContact.icon := graphics.TBitmap.Create;
//              loadPic2(s, cnt.icon.Bmp);
              str.Position := 0;
              if loadPic(TStream(str), cnt.icon.Bmp, 0, PicFmt) then
                begin
                  StretchPic(cnt.icon.Bmp, maxPICAVTH, maxPICAVTW);
                end;

              cnt.icon.IsBmp := True;
              if cnt.icon.Bmp.Animated then
                cnt.icon_Path := '';
//             if (thisICQ.eventContact.icon.Height = 0)or
//                (thisICQ.eventContact.icon.Width = 0) then
//               FreeAndNil(thisICQ.eventContact.icon);
             end;
           end
          else
           if cnt.icon.ToShow = IS_AVATAR then
           begin
              if Assigned(cnt.icon.Bmp) then
                cnt.icon.Bmp.Free;
              cnt.icon.Bmp := NIL;
            msgDlg(getTranslation('%s has avatar of unsupported type',
                          [cnt.displayed]), False, mtError);
           end;
//         find
//        thisICQ.eventContact.icon.LoadFromStream(thisICQ.imageStream);
    end;
end;

function LoadAvtByHash(const hash : RawByteString; var bmp : TRnQBitmap;
                       var hasAvatar : Boolean; var pPicFile : String) : Boolean;
var
  sr:TsearchRec;
//  PicFile : String;
  path : String;
 {$IFDEF AVT_IN_DB}
   str : TMemoryStream;
  i : Integer;
//    bType : Integer;
//    hash : RawByteString;
    LoadAVTStmt : sqlite3_stmt_ptr;
    Tail : PAnsiChar;
    ptr : Pointer;
 {$ENDIF AVT_IN_DB}
begin
  Result := False;

 {$IFDEF AVT_IN_DB}
  begin
      begin
//        try
          begin
           SQLite3_Prepare_v2(avtDB, PAnsiChar(SQLLoadAVTbyHash), Length(SQLLoadAVTbyHash), @LoadAVTStmt, @Tail);

           sqlite3_bind_blob(LoadAVTStmt, 1, PAnsiChar(hash), 16, NIL);
//           sqlite3_bind_int (LoadAVTStmt, 2, picType);
          end;
         if Sqlite3_Step(LoadAVTStmt) = SQLITE_ROW then
           begin
             pPicFile := '';
             i := sqlite3_column_bytes(LoadAVTStmt, 0);
             if i > 0 then
               begin
                 hasAvatar := True;
//                 Result := True;
                 ptr := sqlite3_column_blob(LoadAVTStmt, 0);
                 str := TMemoryStream.Create;
                 str.Size := i;
                 CopyMemory(str.Memory, ptr, i);
                 try
                  Result := loadPic(TStream(str), Bmp);
                  if Result then
                    begin
                      StretchPic(Bmp, maxPICAVTH, maxPICAVTW);
                    end
                   else
                     begin
//                      DeleteFile(pPicFile);
                      pPicFile := '';
                     end;
                     ;
                  finally
                   str.Free;
                 end;
               end;
           end;
//         SQLite3_Reset(LoadAVTStmt);
         SQLite3_Finalize(LoadAVTStmt);
//        finally
//        end;
      end;
  end;
  if Result then
    Exit;
 {$ENDIF AVT_IN_DB}

  path := AccPath + avtPath;
  if (path='') or not directoryExists(path) then exit;
  path := includeTrailingPathDelimiter(path);
  ZeroMemory(@sr.FindData, SizeOf(TWin32FindData));
     if FindFirst(path+ str2hexU(hash)+'.*', faAnyFile, sr) = 0 then
     repeat
//      if (sr.name<>'.') and (sr.name<>'..') then
      if (sr.name='.') or (sr.name='..') then Continue;
      pPicFile := path + sr.name;
 //      if sr.Attr and faDirectory > 0 then
      if isSupportedPicFile(sr.name) then
        begin
          hasAvatar := True;
          begin
            Result := loadPic2(pPicFile, Bmp);
            if Result then
              begin
                StretchPic(Bmp, maxPICAVTH, maxPICAVTW);
                Break;
              end
             else
               begin
                DeleteFile(pPicFile);
                pPicFile := '';
               end;
               ;
          end;
        end
       else
      if lowercase(ExtractFileExt(sr.name)) = '.swf' then
         begin
           begin
             begin
  //            c.iconPath := path+sr.name;
  //            c.iconIsBmp := false;
  //            if not Assigned(bmp) then
  //              bmp := TBitmap.Create;
              Result := loadPic2(pPicFile, bmp);
//              if Result then
                Break
             end;
           end;
         end;
     until findNext(sr) <> 0;
     findClose(sr);
end;

function try_load_avatar(c : TICQcontact; const hash : RawByteString) :Boolean ;
var
 path : String;
//  sr:TsearchRec;
  hasAvatar, b : Boolean;
begin
  result := false;
  if not Account.AccProto.AvatarsSupport then
    Exit;
  hasAvatar := c.icon.ToShow <> IS_AVATAR;
//  if not hasAvatar then

  if not hasAvatar then
  begin
   if (hash > '') then
   begin
    b := LoadAvtByHash(hash, c.icon.Bmp, hasAvatar, path);
    if b then
      begin
        if Assigned(c.icon.Bmp) then
          c.icon.IsBmp := c.icon.Bmp.fFormat <> PA_FORMAT_SWF
         else
          c.icon.IsBmp := False;
        if not c.icon.IsBmp then
          c.icon_Path := path
         else
          c.Icon_Path := '';
      end
{     else
     begin
      path := AccPath + avtPath;
      if (path='') or not directoryExists(path) then exit;

      path:=includeTrailingPathDelimiter(path);

      if FindFirst(path+ str2hexU(hash)+'.*', faAnyFile, sr) = 0 then
      repeat
      if (sr.name<>'.') and (sr.name<>'..') then
  //      if sr.Attr and faDirectory > 0 then
  //        deltree(path+sr.name)
  //      else
        if isSupportedPicFile(path+sr.name) then
         begin
          hasAvatar := True;
           begin
  //          b := pos('.photo.', sr.Name) > 1;
  //          if ((c.icon.ToShow = IS_AVATAR) and (not b))
  //           or ((c.icon.ToShow = IS_PHOTO) and b) then
             begin
  //            if not Assigned(c.iconBmp) then
  //              c.icon := TBitmap.Create;
              if loadPic2(path+sr.name, c.icon.Bmp) then
                StretchPic(c.icon.Bmp, maxPICAVTH, maxPICAVTW)
               else
                begin
                 DeleteFile(path+sr.name);
                 hasAvatar := False;
                end;
              c.icon.IsBmp := True;
              if hasAvatar then
               if c.icon.Bmp.Animated then
                c.icon_Path := path+sr.name;
  //           c.icon.Transparent := True;
             end;
           end;
         end
        else
         if lowercase(ExtractFileExt(sr.name)) = '.swf' then
         begin
           hasAvatar := True;
           begin
  //          b := pos('.photo.', sr.Name) > 1;
  //          if ((c.icon.ToShow = IS_AVATAR) and (not b))
  //           or ((c.icon.ToShow = IS_PHOTO) and b) then
             begin
              c.icon_Path := path+sr.name;
              c.icon.IsBmp := false;
  //            if not Assigned(c.icon) then
  //              c.icon := TBitmap.Create;
              if not loadPic2(path+sr.name, c.icon.Bmp) then
               begin
                DeleteFile(path+sr.name);
                hasAvatar := False;
               end;
  //           c.icon.Transparent := True;
             end;
           end;
         end
  //       else
  //        if lowercase(ExtractFileExt(sr.name)) = '.xml' then
  //          DeleteFile(path+sr.name);
      until findNext(sr) <> 0;
      findClose(sr);
     end;}
   end;
  end;
   if not hasAvatar then
      c.ICQIcon.hash_safe := ''
     else
      c.ICQIcon.hash_safe := hash;
  updateAvatarFor(c);
  result := (hash = '') or hasAvatar;
end;

{function try_load_avatar2(bmp:TBitmap; hash : String) :Boolean ;
var
 path : String;
  sr:TsearchRec;
  hasAvatar : Boolean;
//  hasAvatar, b : Boolean;
begin
  result := false;
  if not AvatarsSupport then
    Exit;
  path := userPath + avtPath;
  if (path='') or not directoryExists(path) then exit;

  path:=includeTrailingPathDelimiter(path);

  begin
   hasAvatar := False;
   if (hash > '') then
   if FindFirst(path+ str2hex(hash)+'.*', faAnyFile, sr) = 0 then
    repeat
    hasAvatar := True;
    if (sr.name<>'.') and (sr.name<>'..') then
//      if sr.Attr and faDirectory > 0 then
//        deltree(path+sr.name)
//      else
      if isSupportedPicFile(path+sr.name) then
       begin
         begin
//          b := pos('.photo.', sr.Name) > 1;
           begin
//            if not Assigned(bmp) then
//              bmp := TBitmap.Create;
            if loadPic2(path+sr.name, bmp) then
              StretchPic(bmp, maxAVTH, maxAVTW);
//            c.iconIsBmp := True;
//           c.icon.Transparent := True;
           end;
         end;
       end
      else
       if lowercase(ExtractFileExt(sr.name)) = '.swf' then
       begin
         begin
           begin
//            c.iconPath := path+sr.name;
//            c.iconIsBmp := false;
//            if not Assigned(bmp) then
//              bmp := TBitmap.Create;
            loadPic2(path+sr.name, bmp);
//           c.icon.Transparent := True;
           end;
         end;
       end;
    until findNext(sr) <> 0;
    findClose(sr);
   end;
  result := hasAvatar;
end;

function try_load_avatar3(var bmp:TRnQBitmap; const hash : AnsiString) :Boolean;
var
 path : String;
  sr:TsearchRec;
  hasAvatar : Boolean;
//  I: Integer;
//  hasAvatar, b : Boolean;
begin
  result := false;
  if not AvatarsSupport then
    Exit;
  path := AccPath + avtPath;
  if (path='') or not directoryExists(path) then exit;

  path:=includeTrailingPathDelimiter(path);
//  for I := 0 to Length(hash) - 1 do

  begin
   hasAvatar := False;
   if (hash > '') then
   begin
     if FindFirst(path+ str2hexU(hash)+'.*', faAnyFile, sr) = 0 then
      repeat
      hasAvatar := True;
      if (sr.name<>'.') and (sr.name<>'..') then
        if isSupportedPicFile(path+sr.name) then
         begin
           begin
  //          b := pos('.photo.', sr.Name) > 1;
             begin
  //            if not Assigned(bmp) then
  //              bmp := TBitmap.Create;
              if loadPic2(path+sr.name, bmp) then
                StretchPic(bmp, maxPICAVTH, maxPICAVTW)
               else
                DeleteFile(path+sr.name);
  //            c.iconIsBmp := True;
  //           c.icon.Transparent := True;
             end;
           end;
         end
        else
         if lowercase(ExtractFileExt(sr.name)) = '.swf' then
         begin
           begin
             begin
  //            c.iconPath := path+sr.name;
  //            c.iconIsBmp := false;
  //            if not Assigned(bmp) then
  //              bmp := TBitmap.Create;
              loadPic2(path+sr.name, bmp);
             end;
           end;
         end;
      until findNext(sr) <> 0;
      findClose(sr);
   end;
  end;
  result := hasAvatar;
end;
}


procedure updateAvatar(c : TRnQcontact{; pWriteLog : boolean = false});
var
  sr:TsearchRec;
//  path,
//  uinStr : String;
//  uin, code : Integer;
//  c : Tcontact;
  PicFile : String;
//  b,
  hasAvatar, loaded : Boolean;
begin
   if Assigned(c.icon.Bmp) then
    FreeAndNil(c.icon.Bmp);
   if (c is TICQcontact) and (c.icon.ToShow = IS_AVATAR) and (TICQcontact(c).ICQIcon.hash_safe > '') then
   begin
    hasAvatar := False;
    loaded    := False;
//    hsh := TICQcontact(c).ICQIcon.hash_safe;
    if TICQcontact(c).ICQIcon.hash_safe <> z+z+z+z then
    begin
     loaded := False;
     if (c.icon.ToShow = IS_AVATAR) then
      begin
{       if pWriteLog then
        loggaEvt('Avatars: loading for '+ c.UID + ', hash = '+
                 str2hex(TICQcontact(c).ICQIcon.hash_safe), '', True);}
       loaded := LoadAvtByHash(TICQcontact(c).ICQIcon.hash_safe, c.icon.Bmp, hasAvatar, PicFile);
      end;
     if hasAvatar and not loaded then
       msgDlg(getTranslation('Couldn''t load avatar for %s', [c.UID]), False, mtError, c.UID);
//     hasAvatar := loaded;
     if loaded then
      begin
       if Assigned(c.icon.Bmp) and
            (c.icon.Bmp.Animated or (c.icon.Bmp.fFormat = PA_FORMAT_SWF))
        then
         c.icon_Path := PicFile
        else
         c.icon_Path := '';
       if Assigned(c.icon.Bmp) and (c.icon.Bmp.fFormat = PA_FORMAT_SWF) then
         c.icon.IsBmp := False
        else
         c.icon.IsBmp := True;
      end;
    end;
    if not hasAvatar or not loaded then
      TICQcontact(c).ICQIcon.hash_safe := '';
   end
   else
    if c.icon.ToShow = IS_PHOTO then
     begin
       if findFirst(AccPath + avtPath+c.UID+'.photo.*', faAnyFile, sr) = 0 then
        begin
         PicFile := AccPath + avtPath + sr.name;
         if isSupportedPicFile(PicFile) then
          begin
{            if pWriteLog then
              loggaEvt('Avatars: loading photo for '+ c.UID + ', file = '+ PicFile, '', True);}
             if loadPic2(PicFile, c.icon.Bmp) then
//             if Assigned(c.iconBmp) then
               StretchPic(c.icon.Bmp, maxPICAVTH, maxPICAVTW);
             c.icon.IsBmp := True;
             if Assigned(c.icon.Bmp) and c.icon.Bmp.Animated then
               c.icon_Path := PicFile
              else
               c.icon_Path := '';
          end;
        end;
       findClose(sr);
{        if lowercase(ExtractFileExt(sr.name)) = '.swf' then
            c.icon.Path := path+sr.name;
            c.icon.IsBmp := false;
//            if not Assigned(c.icon) then
//              c.icon := TBitmap.Create;
            if not loadPic2(path+sr.name, c.icon.Bmp) then
}
     end;
end;

procedure loadAvatars(const proto : TRnQProtocol; path : String);
var
//  sr:TsearchRec;
//  path,
//  uinStr : String;
//  uin, code : Integer;
  cnt : TRnQContact;
//  c : TICQcontact;
//  b, hasAvatar, loaded : Boolean;
begin
//  path := userPath + avtPath;
  if not Account.AccProto.AvatarsSupport then
    Exit;
  if (path='') or not directoryExists(path) then exit;

  path:=includeTrailingPathDelimiter(path);
 with proto.readList(LT_ROSTER) do
 begin
  resetEnumeration;
  while hasMore do
  begin
   cnt := getNext;
//   if cnt is TICQContact then
    begin
//     c := TICQContact(cnt);
     cnt.icon.Bmp := NIL;
     updateAvatar(cnt{, True});
//     Application.ProcessMessages;
    end;
  end;
 end;
end;


procedure updateAvatarFor(c : TRnQcontact);
var
 frm  : TRnQViewInfoForm;
 ci   : TchatInfo;
 i    : integer;
 pnl  : TPanel;
 ctrl : TWinControl;
// gr   : TGPGraphics;
 fn : String;
 cnt  : TICQContact;
 w, h : Double;
 b1, b : Boolean;
begin
  if c is TICQcontact then
    cnt := TICQcontact(c)
   else
    cnt := NIL;

  if Assigned(c) then
  begin
    frm := findViewInfo(c);
    if Assigned(frm) then
      begin
        frm.UpdateCntAvatar;
      end;
  end;

  if (not avatarShowInChat) then
    exit;
//  if not Assigned(cnt.icon.Bmp) then
//     exit;
  i := chatFrm.chats.idxOf(c);
  if i >= 0 then
  begin
   ci := chatFrm.chats.byIdx(i);
   if not Assigned(ci.inputPnl) then
    Exit;
   if (not Assigned(c.icon.Bmp)) or
       ((not c.icon.IsBmp)and(c.icon_Path = '')) then // Clear pic
   begin
     with ci.avtPic do
       try
         if Assigned(ci.avtsplitr) then
           FreeAndNil(ci.avtsplitr);
         try
           if Assigned(AvtPBox) then
             FreeAndNil(AvtPBox);
          except
         end;
         if Assigned(swf) then
          begin
           ctrl := swf.Parent;
           FreeAndNil(swf);
           if Assigned(ctrl) then
            FreeAndNil(ctrl);
          end;
         if Assigned(PicAni) then
           FreeAndNil(PicAni);
        except
       end;
     exit;
   end;
{   else
    begin
      if Assigned(PicAni) then
        FreeAndNil(PicAni);}
   if Assigned(ci.avtPic.PicAni) then
      FreeAndNil(ci.avtPic.PicAni);
   pnl := NIL;
   with ci.avtPic do
   if c.icon.IsBmp then
     begin
       if Assigned(swf) then
        begin
         ctrl := swf.Parent;
         FreeAndNil(swf);
         if Assigned(ctrl) then
          FreeAndNil(ctrl);
        end;
       if not Assigned(AvtPBox) then
        begin
         if Assigned(ci.avtsplitr) then
           FreeAndNil(ci.avtsplitr);
         ci.inputPnl.FullRepaint := false;

//         img := TImage.create(ci.inputPnl);
//         AvtPBox := TPaintBox.Create(ci.inputPnl);
         AvtPBox := TRnQPntBox.Create(ci.inputPnl);
         AvtPBox.parent := ci.inputPnl;
         AvtPBox.align  := alRight;
         AvtPBox.OnPaint := chatFrm.AvtPBoxPaint;
//         AvtPBox.ControlStyle := AvtPBox.ControlStyle + [ csOpaque ] ;
         AvtPBox.ControlStyle := AvtPBox.ControlStyle - [ csOpaque ] ;
//         img.Center := True;
//         img.Proportional := True;
        end;
       if Assigned(c.icon.Bmp) then
       begin
         if c.icon.Bmp.Animated then
          begin
  {          if Length(c.icon_Path) = 0 then
              PicAni := NIL
             else
              PicAni := CreateAni(c.icon_Path, b);}
              with c.icon.Bmp do
                PicAni := Clone(MakeRect(0, 0, fWidth, fHeight) );
  //          if Assigned(PicAni) then
  //            PicAni.Animate := true;
          end;

         AvtPBox.Width  := c.icon.Bmp.GetWidth;
  //       AvtPBox.Height := cnt.iconBmp.GetHeight;
  //        gr := TGPGraphics.Create(Img.Canvas.Handle);
  //        gr.DrawImage(cnt.iconBmp, 0, 0, Img.Width, Img.Height);
  //        gr.Free;
  //       Img.Width
  //       Img.Picture.Assign(cnt.icon);
         if c.icon.Bmp.GetHeight > 0 then
          AvtPBox.Width := min(c.icon.Bmp.GetWidth, Trunc(ci.inputPnl.Height/c.icon.Bmp.GetHeight * c.icon.Bmp.GetWidth)) + 5;
       end;
       AvtPBox.Invalidate;
//       img.Transparent := cnt.iconBmp.Transparent;
     end
    else
     if c.icon_Path > '' then
     begin
       if Assigned(AvtPBox) then
        FreeAndNil(AvtPBox);
       if not Assigned(swf) then
        begin
         if Assigned(ci.avtsplitr) then
           FreeAndNil(ci.avtsplitr);
         try
           pnl := nil;
           pnl := TPanel.Create(ci.inputPnl);
           pnl.parent := ci.inputPnl;
           pnl.align  := alRight;
           pnl.BevelOuter := bvNone;
           swf :=  TShockwaveFlash.Create(pnl);
//           swf :=  TFlashPlayerControl.Create(pnl);
//           swf := TTransparentFlashPlayerControl.Create(pnl);
           swf.parent := pnl;
           swf.TabStop := False;
           swf.align  := alClient;
          except
            swf := NIL;
            if Assigned(pnl) then
             FreeAndNil(pnl);
         end;
//         swf.parent := pnl;
//         swf.align  := alClient;

//         swf.BackgroundColor :=

//       pnl.Caption := swf.FlashVars;
//         pnl.Width := swf.Height;
//         pnl.Color  := ci.input.Color;
        end;
       if Assigned(swf) then
       begin
         swf.WMode := StringToOleStr('TRANSPARENT');
         swf.Movie := c.icon_Path;
         swf.Menu := False;
         swf.BackgroundColor := ABCD_ADCB(ColorToRGB(ci.input.Color));
  //       swf.BackgroundColor := ABCD_ADCB($FFFFFFFF);
  //       swf.BGColor := 'Transparent';
  //       swf.Height;
  //       swf.ClientWidth := 100;
  //       pnl.Width := swf.ClientWidth + 2;
  //       swf.GotoFrame(7);
         swf.Repaint;
         swf.Play;
//         swf.WMode := 'transparent';
         swf.WMode := 'TRANSPARENT';
         try
          w := swf.TGetPropertyNum('/', 8); // WIDTH
          h := swf.TGetPropertyNum('/', 9); // HEIGHT
         except
           w :=1; h := 1;
         end;
         if (w> maxSWFAVTW) or (h > maxSWFAVTH) then
          if w * maxSWFAVTH < h * maxSWFAVTW then
            begin
             swf.Width := trunc(maxSWFAVTH*w / h); swf.Height := maxSWFAVTH;
            end
          else
            begin
             swf.Width := maxSWFAVTW; swf.Height := trunc(maxSWFAVTW*h / w);
            end;
         if (w > 0) and (h > 0) then
//          if Assigned(pnl) and Assigned(swf) and Assigned(ci) then
//           pnl.Width := round(w * (pnl.Height / h));

          if Assigned(pnl) and Assigned(swf) and Assigned(ci) and Assigned(ci.inputPnl) then
            pnl.Width := trunc(w * (ci.inputPnl.Height / h));

//       swf.BrowseProperties;
//       swf.Width := swf.Width + 2;
//       pnl.Width := Round(pnl.Height * 2 / 3);
//       pnl.Width := ci.inputPnl.Height;

//         swf.TSetProperty();
//         SetVariable('info', 'Testing');
//       swf.TGotoFrame('face', 7);
//       cnt.important := swf.TCurrentLabel('face');
//       cnt.important := swf.GetVariable('face');
//       swf.SetVariable('face', '_level0.sad');
//       if swf.FrameLoaded(7) then
//         swf.FrameNum := 7;
//       swf.GotoFrame(2);
       end;
     end;
    if not Assigned(ci.avtsplitr) then
    begin
      ci.avtsplitr:=Tsplitter.create(ci.historyBox);
      //chat.splitter.ResizeStyle:=rsUpdate;
      ci.avtsplitr.minsize:=10;
    //  chat.avtsplitr.parent:=sheet;
      ci.avtsplitr.parent := ci.inputPnl;
      ci.avtsplitr.align  := alRight;
      ci.avtsplitr.Width  := 5;
//      ci.avtsplitr.OnCanResize  := chatFrm.AvtsplitterMoving;
      ci.avtsplitr.OnMoved  := chatFrm.AvtSplitterMoved;
    end;
    if ci.input.Width < 5 then
      ci.input.Width := 5;
  end;
  if TO_SHOW_ICON[CNT_ICON_AVT] then
   roasterLib.redraw(c);
end;

procedure ClearAvatar(var cnt : TICQcontact);
var
 frm : TRnQViewInfoForm;
 ci : TchatInfo;
 i : integer;
// pnl : TPanel;
 ctrl : TWinControl;
begin
  if not Assigned(cnt.icon.Bmp) then
    exit;
  FreeAndNil(cnt.icon.Bmp);
  cnt.icon_Path := '';
  frm := findViewInfo(cnt);
  if Assigned(frm) then
    frm.ClearAvatar;
//    frm.AvtImg.Picture.Assign(cnt.icon);

  if not avatarShowInChat then
    exit;
  i := chatFrm.chats.idxOf(cnt);
  if i >= 0 then
  begin
   ci := chatFrm.chats.byIdx(i);
   with ci.avtPic do
    begin
       if Assigned(swf) then
        begin
         ctrl := swf.Parent;
         FreeAndNil(swf);
         if Assigned(ctrl) then
          FreeAndNil(ctrl);
        end;
       if Assigned(AvtPBox) then
        FreeAndNil(AvtPBox);
       if Assigned(PicAni) then
        FreeAndNil(PicAni);
    end;
   if Assigned(ci.avtsplitr) then
     FreeAndNil(ci.avtsplitr);
  end;
end;

procedure Check_my_avatar(const proto : TRnQProtocol);
var
 path : String;
  sr:TsearchRec;
begin
  if not Account.AccProto.AvatarsSupport then
    Exit;
 {$IFDEF UseNotSSI}
//  if icq.useSSI then
  if not (proto.ProtoElem is TICQSession)
     or TICQSession(proto.ProtoElem).useSSI then
 {$ENDIF UseNotSSI}
   Exit;
  path := AccPath + avtPath;
  if (path='') or not directoryExists(path) then exit;
  if length(TICQContact(proto.getMyInfo).ICQIcon.hash_safe) < 16 then exit;


  path:=includeTrailingPathDelimiter(path);

   if FindFirst(path+ str2hexU(TICQContact(proto.getMyInfo).ICQIcon.hash_safe)+'.*', faAnyFile, sr) = 0 then
    repeat
    if (sr.name<>'.') and (sr.name<>'..') then
//      if sr.Attr and faDirectory > 0 then
//        deltree(path+sr.name)
//      else
      if lowercase(ExtractFileExt(path+sr.name)) = '.swf' then continue;
      if PosEx('.xml.', sr.name, 15) > 0 then Continue;

      ToUploadAvatarFN := path+sr.name;
      ToUploadAvatarHash := TICQContact(proto.getMyInfo).ICQIcon.hash_safe;
    until findNext(sr) <> 0;
    findClose(sr);
end;

 {$IFDEF PROTOCOL_ICQ}
procedure OnPhotoDownLoaded(fn : String; size : Int64; cnt : TRnQContact);
// This function is of type TOnDownloadedProc
var
 frm  : TviewInfoFrm;
// cnt  : TICQcontact;
begin
//  cnt := TICQcontact(proto.getContact(uid));
  if cnt = NIL then
    Exit;
  frm := TviewInfoFrm(findViewInfo(cnt));
  if Assigned(frm) then
   begin
     try
      if Assigned(frm.contactPhoto) then
       frm.contactPhoto.Free;
      except
     end;
     frm.contactPhoto := NIL;
     loadPic2(fn, frm.contactPhoto);
     if Assigned(frm.PhotoPBox) then
//       frm.PhotoPBox.Repaint;
       frm.PhotoPBox.Invalidate;
   end;
  if cnt.icon.ToShow = IS_PHOTO then
//    updateAvatar(cnt, TICQcontact(cnt).ICQIcon.Hash_safe);
    updateAvatar(cnt);
end;

function LoadFromURL2(params : TLoadURLParams) : Boolean;
var
  fn : String;
begin
  fn := params.fn;
  Result := LoadFromURL(params.URL, fn, params.Treshold, params.ExtByContent);
  if Result then
    params.proc(fn, 0, params.cnt);
end;
 {$ENDIF PROTOCOL_ICQ}


{

initialization
   AvatarPath:= ExtractFilePath(ParamStr(0))+'avatars';
   if not DirectoryExists(AvatarPath) then
     MkDir(AvatarPath);

   AvList:=  TRQAvatarList.Create;
   LoadAvatar(0, AvList.avNone);


finalization
   AvList.ClearAvatarList;
   FreeAndNil(AvList);
}
end.
