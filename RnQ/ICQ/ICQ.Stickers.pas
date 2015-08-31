unit ICQ.Stickers;
{$I forRnQConfig.inc}
{$I RnQConfig.inc }
{$I NoRTTI.inc}

interface

uses
  Windows, Classes;


//const
//  ImageContentTypes: array [0 .. 7] of string = ('image/bmp', 'image/jpeg', 'image/gif', 'image/png', 'image/x-icon', 'image/tiff', 'image/x-tiff', 'image/webp');

type
  PMemoryStream = ^TMemoryStream;

  function getSticker(const ext, sticker: String;
                      fsPtr: PMemoryStream = nil; forceSize: String = ''): RawByteString;

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
                    fsPtr: PMemoryStream = nil; forceSize: String = ''): RawByteString;
var
  URL, fn, size: string;
  stickerForChat: RawByteString;
  fs: TMemoryStream;
  pfs: PMemoryStream;
  StickerResolution: Integer;
  EnableStickersCache: Boolean;
begin
  if fsPtr = nil then
  begin
    fs := TMemoryStream.Create;
    pfs := @fs;
  end
  else
    pfs := fsPtr;

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
    pfs.LoadFromFile(fn)
   else
    begin
      LoadFromURL(URL, pfs^);

      if EnableStickersCache then
       begin
         if not FileExists(fn) then
          begin
           if not DirectoryExists(myPath + 'Stickers\') then
             CreateDir(myPath + 'Stickers\');
           pfs.SaveToFile(fn);
          end;
      end;
    end;

  pfs.Seek(0, 0);
  SetLength(stickerForChat, pfs.size);
  pfs.ReadBuffer(stickerForChat[1], pfs.size);
  Result := RnQImageExTag + Base64EncodeString(stickerForChat) + RnQImageExUnTag;

  if fsPtr = nil then
    pfs.Free
  else
    pfs.Seek(0, 0);
end;

end.
