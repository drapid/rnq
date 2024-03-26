unit RnQNet.Uploads.Lib;
{$I forRnQConfig.inc}
{$I NoRTTI.inc}

interface

uses
  Classes,
  RDGlobal
  ;

type
  TarchiveStream = class(Tstream)
  protected
    pos, cachedTotal: int64;
    cur: integer;
    aHTTPHeader: RawByteString;
    procedure invalidate();
    procedure calculate(); virtual; abstract;
    function getTotal(): int64;
  public
    flist: array of record
      src,          // full path of the file on the disk
      dst: string;  // full path of the file in the archive
      firstByte,    // offset of the file inside the archive
      mtime,
      size: int64;
      data: Tobject;  // extra data
     end;
    onDestroy: TNotifyEvent;

    constructor create;
    destructor  Destroy; override;
    function   addFile(const src: string; dst: string=''; data: Tobject=NIL): boolean; virtual;
    function   count(): integer;
    procedure  reset(); virtual;
    property   totalSize: int64 read getTotal;
    property   current: integer read cur;
  end; // TarchiveStream

implementation

uses
  Windows, SysUtils, StrUtils, DateUtils, math,
{$IFDEF UNICODE}
  AnsiStrings,
{$ENDIF UNICODE}
  RDFileUtil, RDUtils
;

function InputText(Boundry, Name, Value: RawByteString): RawByteString;
begin
  result := format(AnsiString(RawByteString('%s') + CRLF + 'Content-Disposition: form-data; name="%s"' + CRLF + CRLF + '%s' + CRLF),
            [AnsiString('--') + boundry, name, value]);
end;

//////////// TarchiveStream

function TarchiveStream.getTotal():int64;
begin
  if cachedTotal < 0 then
    calculate();
  result := cachedTotal;
end; // getTotal

function TarchiveStream.addFile(const src: string; dst: string=''; data: Tobject=NIL): boolean;

  function getMtime(fh: Thandle): int64;
  var
    ctime, atime, mtime: Tfiletime;
    st: TSystemTime;
  begin
    getFileTime(fh, @ctime, @atime, @mtime);
    fileTimeToSystemTime(mtime, st);
    result:=dateTimeToUnix(SystemTimeToDateTime(st));
  end; // getMtime

var
  i, fh: integer;
begin
  result := FALSE;
  fh := fileopen(src, fmOpenRead+fmShareDenyNone);
  if fh = -1 then
    exit;
  result := TRUE;
  if dst = '' then
    dst := extractFileName(src);
  i := length(flist);
  setLength(flist, i+1);
  flist[i].src := src;
  flist[i].dst := dst;
  flist[i].data := data;
  flist[i].size := sizeOfFile(src);
  flist[i].mtime := getMtime(fh);
  flist[i].firstByte := -1;
  fileClose(fh);
  invalidate();
end; // addFile

procedure TarchiveStream.invalidate();
begin
  cachedTotal := -1
end;

constructor TarchiveStream.create;
begin
  inherited;
  reset();
end; // create

destructor TarchiveStream.destroy;
begin
  if assigned(onDestroy) then
    onDestroy(self);
  inherited;
end; // destroy

procedure TarchiveStream.reset();
begin
  flist := NIL;
  cur := 0;
  pos := 0;
  invalidate();
end; // reset

function TarchiveStream.count(): integer;
begin
  result := length(flist)
end;


end.
