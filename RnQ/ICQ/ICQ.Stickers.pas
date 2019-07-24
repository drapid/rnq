unit ICQ.Stickers;
{$I forRnQConfig.inc}
{$I RnQConfig.inc }
{$I NoRTTI.inc}

interface

uses
  Windows, Classes, SysUtils, Generics.Collections, JSON, RnQJSON;


const
  stickerExtNames: array [1..30] of Integer =
  (1,  2,  79, 80, 81, 87, 95, 97, 106, 107, 109, 111, 112, 113, 118, 119, 121, 123, 124, {149,} 151, 157, 158, 180, 203, 205, 209, 211, 213, 217, 108);
  stickerExtCounts: array [1..30] of Integer =
  (26, 36, 10, 10, 10, 8,  25, 10, 10,  10,  36,  20,  20,  24,  24,  24,  24,  8,   24,  {24,}  20,  60,  30,  40,  16,  8,   16,  50,  24,  20,  8);
  stickerExtHints: array [1..30] of String = (
    'Pandas', 'Whiskers', 'Super Joe', 'Kittens', 'Holiday Cake', 'Smurfs', 'Memes', 'Bro', 'Boomz Man', 'Boomz Girl',
    'Crackers', 'Chickens', 'Horror', 'Holiday Cards', 'I Love You', 'Supercharged stickers', 'Obrigado, Brasil!',
    'Onca', 'Russian words', 'Bate-papo maneiro', 'Emoticons', 'Paranormal Love', 'Warm Together', 'Just in case',
    'Nauryz', 'Spring festivities', 'Nichosi-meme', 'Snob Dog', 'Sonya', 'Musical Cat'
  );
//  ImageContentTypes: array [0 .. 7] of string = ('image/bmp', 'image/jpeg', 'image/gif', 'image/png', 'image/x-icon', 'image/tiff', 'image/x-tiff', 'image/webp');

type
  PMemoryStream = ^TMemoryStream;

  TStickerPack = record
    Id: Integer;
    StoreId: String;
    Name: String;
    Desc: String;
    Purchased: Boolean;
    UserSticker: Boolean;
    IsEnabled: Boolean;
    Priority: Integer;
    Count: Integer;
    class function fromJSON(const JSON: TJSONObject): TStickerPack; static;
  end;

  TStickerPacks = array of TStickerPack;

  function getSticker(const ext, sticker: String;
                      pifs: TMemoryStream = NIL; const forceSize: String = ''): RawByteString;

  function getStickerURL(const ext, sticker: RawByteString; const forceSize: String = ''): RawByteString;

  procedure ClearStickerPacks;
  procedure AddStickerPack(pak: TStickerPack);

  procedure ChangeStickerPackStatus(const PackId: String; Status: Boolean);
  function GetStickerPacksCount: Integer;
  function GetStickerPacks(ActiveOnly: Boolean = False): TStickerPacks;

  function GetCachedPickers: String;
  procedure RemoveStickerPackCache(const PackId: String);

var
  HiddenStickerPacks, DupStickerPacks: TList<Integer>;

implementation

uses
  Base64, StrUtils,
  RDGlobal, RnQGlobal,
  RDUtils, globalLib,
  RnQPrefsLib,
{$IFDEF UNICODE}
  AnsiStrings,
{$ENDIF UNICODE}
  RnQNet;

function getSticker(const ext, sticker: String;
                    pifs: TMemoryStream = NIL; const forceSize: String = ''): RawByteString;
var
  URL, fn, size: string;
  stickerForChat: RawByteString;
  fs: TMemoryStream;
//  pfs: PMemoryStream;
  StickerResolution: Integer;
  EnableStickersCache: Boolean;
begin
  if pifs = nil then
  begin
    fs := TMemoryStream.Create;
//    pfs := @fs;
  end
  else
    fs := pifs;

  if not(forceSize = '') then
    size := forceSize
  else
    begin
      StickerResolution := MainPrefs.getPrefIntDef('chat-images-sticker-size', 0);
      case StickerResolution of
        0:
          size := 'small';
        1:
          size := 'medium';
        2:
          size := 'large';
      end;
    end;

  URL := 'http://www.icq.com/store/stickers/' + ext + '/' + sticker + '/' + size;
  fn := myPath + 'Stickers\' + ext + '_' + sticker + '_' + size + '.png';

  EnableStickersCache := MainPrefs.getPrefBoolDef('chat-images-enable-stickers-cache', True);

  if EnableStickersCache and FileExists(fn) then
    fs.LoadFromFile(fn)
   else
    begin
      if LoadFromURL(URL, fs) then
        if EnableStickersCache then
         begin
           if not FileExists(fn) then
            begin
             if not DirectoryExists(myPath + 'Stickers\') then
               CreateDir(myPath + 'Stickers\');
             fs.SaveToFile(fn);
            end;
      end;
    end;

  fs.Seek(0, 0);
  SetLength(stickerForChat, fs.size);
  if fs.size > 0 then
    begin
      fs.ReadBuffer(stickerForChat[1], fs.size);
      Result := RnQImageExTag + Base64EncodeString(stickerForChat) + RnQImageExUnTag;
    end
   else
    Result := '';

  if pifs = nil then
    fs.Free
   else
    fs.Seek(0, 0);
end;

function getStickerURL(const ext, sticker: RawByteString; const forceSize: String = ''): RawByteString;
var
  size: string;
  stickerForChat: RawByteString;
  StickerResolution: Integer;
begin
  if not(forceSize = '') then
    size := forceSize
  else
    begin
      StickerResolution := MainPrefs.getPrefIntDef('chat-images-sticker-size', 0);
      case StickerResolution of
        0:
          size := 'small';
        1:
          size := 'medium';
        2:
          size := 'large';
      end;
    end;

  Result := 'http://www.icq.com/store/stickers/' + ext + '/' + sticker + '/' + size;
end;

class function TStickerPack.fromJSON(const JSON: TJSONObject): TStickerPack;
begin
  Result := Default(TStickerPack);
  with JSON do
  begin
    GetValueSafe('id', Result.Id);
    GetValueSafe('name', Result.Name);
    GetValueSafe('description', Result.Desc);
    GetValueSafe('count', Result.Count);
    GetValueSafe('purchased', Result.Purchased);
    GetValueSafe('usersticker', Result.UserSticker);
    GetValueSafe('priority', Result.Priority);
    GetValueSafe('is_enabled', Result.IsEnabled);
    GetValueSafe('store_id', Result.StoreId);
  end;
end;


procedure ClearStickerPacks;
begin

end;

procedure AddStickerPack(pak: TStickerPack);
begin

end;

procedure ChangeStickerPackStatus(const PackId: String; Status: Boolean);
begin

end;

function GetStickerPacksCount: Integer;
//var
//  qry: TFDQuery;
begin
  Result := 0;
{
  qry := TFDQuery.Create(sql);
  try
    qry.Connection := sql;
    qry.SQL.Text := 'SELECT COUNT(*) FROM "' + dbStickers + '"';
    if qry.OpenOrExecute and (qry.RecordCount > 0) then
    begin
      qry.First;
      Result := qry.Fields[0].AsInteger;
    end;
  finally
    if Assigned(qry) then
      FreeAndNil(qry);
  end;
}
end;

function GetStickerPacks(ActiveOnly: Boolean = False): TStickerPacks;
//var
//  qry: TFDQuery;
begin
{
  qry := TFDQuery.Create(sql);
  try
    qry.Connection := sql;
    qry.SQL.Text := 'SELECT * FROM "' + dbStickers + '"' + IfThen(ActiveOnly, ' WHERE "purchased" = 1', '') + ' ORDER BY "Id"';
    if not QueryToStickersArray(qry, Result) then
      SetLength(Result, 0);
  finally
    if Assigned(qry) then
      FreeAndNil(qry);
  end;
}
end;

procedure RemoveStickerPackCache(const PackId: String);
var
  sr: TSearchRec;
begin
  if FindFirst(StickerPath + PackId + '_*_*.png', faAnyFile, sr) = 0 then
  repeat
    if not (sr.name = '.') and not (sr.name = '..') then
      DeleteFile(StickerPath + sr.name);
  until FindNext(sr) <> 0;
  FindClose(sr);
end;

function CheckPickerCache(Ext: Integer): Boolean;
begin
  Result := FileExists(StickerPath + IntToStr(Ext) + '_picker_small.png');
end;

function GetCachedPickers: String;
var
  i: Integer;
  s: TStickerPacks;
begin
  Result := '';
  s := GetStickerPacks(True);
  for i := 0 to Length(s) - 1 do
    if CheckPickerCache(s[i].Id) then
      Result := Result + 'picker:n' + IntToStr(s[i].Id) + #10;
  Result := Trim(Result);
end;


initialization

  HiddenStickerPacks := TList<Integer>.Create;
  HiddenStickerPacks.AddRange([87, 108, 205, 209]);
  DupStickerPacks := TList<Integer>.Create;
  DupStickerPacks.AddRange([116288, 194855, 234247 {Cute Pigs - Incomplete set}]);

finalization

  HiddenStickerPacks.Free;
  DupStickerPacks.Free;

end.
