unit ICQ.Stickers;
{$I forRnQConfig.inc}
{$I RnQConfig.inc }
{$I NoRTTI.inc}

interface

uses
  Windows, Classes;


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

  function getSticker(const ext, sticker: String;
                      pifs: TMemoryStream = NIL; const forceSize: String = ''): RawByteString;

  function getStickerURL(const ext, sticker: RawByteString; const forceSize: String = ''): RawByteString;

  function make_sticker_url(set_id: Integer; sticker_id: Integer; const size: String): String;
  function make_big_icon_url(set_id: Integer): String;

implementation

uses
  Base64, SysUtils, StrUtils,
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

function make_sticker_url(set_id: Integer; sticker_id: Integer; size: String): String;
begin
  Result := 'https://c.icq.com/store/stickers/' + set_id + '/' + sticker_id + '/' + size + '.png';
end;

function make_big_icon_url(set_id: Integer): String;
begin
  Result := 'https://c.icq.com/store/stickers/'+ set_id + '/icon/large.png';
end;

(*
procedure parse_StickerFile(node: TJSONObject);
begin
  node.
            auto iter_id = _node.FindMember("id");
            if (iter_id == _node.MemberEnd() || !iter_id->value.IsInt())
                return false;

            set_id(iter_id->value.GetInt());

            auto iter_name = _node.FindMember("name");
            if (iter_name != _node.MemberEnd() && iter_name->value.IsString())
                set_name(rapidjson_get_string(iter_name->value));

            auto iter_show = _node.FindMember("is_enabled");
            if (iter_show != _node.MemberEnd() && iter_show->value.IsBool())
                set_show(iter_show->value.GetBool());

            auto iter_purchased = _node.FindMember("purchased");
            if (iter_purchased != _node.MemberEnd() && iter_purchased->value.IsBool())
                set_purchased(iter_purchased->value.GetBool());

            auto iter_usersticker = _node.FindMember("usersticker");
            if (iter_usersticker != _node.MemberEnd() && iter_usersticker->value.IsBool())
                set_user(iter_usersticker->value.GetBool());

            auto iter_store_id = _node.FindMember("store_id");
            if (iter_store_id != _node.MemberEnd() && iter_store_id->value.IsString())
                set_store_id(rapidjson_get_string(iter_store_id->value));

            auto iter_description = _node.FindMember("description");
            if (iter_description != _node.MemberEnd() && iter_description->value.IsString())
                set_description(rapidjson_get_string(iter_description->value));

            auto iter_icons = _node.FindMember("contentlist_sticker_picker_icon");
            if (iter_icons != _node.MemberEnd() && iter_icons->value.IsObject())
            {
                auto iter_icon_20 = iter_icons->value.FindMember("xsmall");
                if (iter_icon_20 != iter_icons->value.MemberEnd() && iter_icon_20->value.IsString())
                    put_icon(set_icon(set_icon_size::_20, rapidjson_get_string(iter_icon_20->value)));

                auto iter_icon_32 = iter_icons->value.FindMember("small");
                if (iter_icon_32 != iter_icons->value.MemberEnd() && iter_icon_32->value.IsString())
                    put_icon(set_icon(set_icon_size::_32, rapidjson_get_string(iter_icon_32->value)));

                auto iter_icon_48 = iter_icons->value.FindMember("medium");
                if (iter_icon_48 != iter_icons->value.MemberEnd() && iter_icon_48->value.IsString())
                    put_icon(set_icon(set_icon_size::_48, rapidjson_get_string(iter_icon_48->value)));

                auto iter_icon_64 = iter_icons->value.FindMember("large");
                if (iter_icon_64 != iter_icons->value.MemberEnd() && iter_icon_64->value.IsString())
                    put_icon(set_icon(set_icon_size::_64, rapidjson_get_string(iter_icon_64->value)));
            }

            auto iter_content = _node.FindMember("content");
end;
*)

end.
