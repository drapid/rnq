unit RnQNet.Uploads.Tar;
{$I forRnQConfig.inc}
{$I NoRTTI.inc}

interface

uses
  Classes,
  RDGlobal,
  RnQNet.Uploads.Lib
  ;

type
  TtarStreamWhere = (TW_HEADER, TW_FILE, TW_PAD);

  TtarStream = class(TarchiveStream)
   protected
    fs: TFileStream;
    block: TStringStream;
    lastSeekFake: int64;
    where: TtarStreamWhere;
    function  fsInit(): boolean;
    procedure headerInit(); // fill block with header
    procedure padInit(full: boolean=FALSE); // fill block with pad
    function  headerLengthForFilename(const fn: string):integer;
    procedure calculate(); override;
   public
    fileNamesOEM: boolean;
    constructor create;
    destructor Destroy; override;
    function Read(var Buffer; Count: Longint): Longint; override;
    function Write(const Buffer; Count: Longint): Longint; override;
    function Seek(const Offset: Int64; Origin: TSeekOrigin=soBeginning): Int64; override;

    procedure reset(); override;
  end; // TtarStream

implementation

uses
  Windows, SysUtils, StrUtils, DateUtils, math,
{$IFDEF UNICODE}
  AnsiStrings,
{$ENDIF UNICODE}
  RDFileUtil, RDUtils, RnQBinUtils
;

function FileSize(const aFilename: String): Int64;
var
  info: TWin32FileAttributeData;
begin
  result := -1;

  if not GetFileAttributesEx(PChar(aFileName), GetFileExInfoStandard, @info) then
    Exit;

  result := Int64(info.nFileSizeLow) or Int64(info.nFileSizeHigh shl 32);
end;

function InputText(Boundry, Name, Value: RawByteString): RawByteString;
begin
  result := format(AnsiString(RawByteString('%s') + CRLF + 'Content-Disposition: form-data; name="%s"' + CRLF + CRLF + '%s' + CRLF),
            [AnsiString('--') + boundry, name, value]);
end;



//////////// TtarStream

constructor TtarStream.create;
begin
  block := TStringStream.create('');
  lastSeekFake := -1;
  where := TW_HEADER;
  fileNamesOEM := FALSE;
  inherited;
end; // create

destructor TtarStream.destroy;
begin
  freeAndNIL(fs);
  inherited;
end; // destroy

procedure TtarStream.reset();
begin
inherited;
block.size:=0;
end; // reset

function TtarStream.fsInit(): boolean;
begin
  if assigned(fs) and (fs.FileName = flist[cur].src) then
    begin
      result := TRUE;
      exit;
    end;
  result:=FALSE;
  try
    freeAndNIL(fs);
    fs := TfileStream.Create(flist[cur].src, fmOpenRead+fmShareDenyWrite);
    result := TRUE;
   except
    fs := NIL;
  end;
end; // fsInit

procedure TtarStream.headerInit();

  function num(i: int64; const fieldLength: integer): RawByteString;
  const
    CHARS: array [0..7] of AnsiChar = '01234567';
  var
    d: integer;
  begin
    result := dupeString(RawByteString(' '), fieldLength);
    d := fieldLength-1;
    while d > 0 do
      begin
        result[d] := CHARS[i and 7];
        dec(d);
        i := i shr 3;
        if i = 0 then
          break;
      end;
  end; // num

  function str(s: RawByteString; fieldLength: integer; fill: RawByteString=#0): RawByteString;
  begin
    setLength(s, min(length(s), fieldLength-1));
    result := s+dupeString(fill, fieldLength-length(s));
  end; // str

  function sum(const s: RawBytestring): integer;
  var
    i: integer;
  begin
    result := 0;
    for i:=1 to length(s) do
      inc(result, ord(s[i]));
  end; // sum

  procedure applyChecksum(var s: RawByteString);
  var
    chk: RawByteString;
  begin
    chk := num(sum(s), 7)+' ';
    chk[7] := #0;
    move(chk[1], s[100+24+12+12+1], length(chk));
  end; // applyChecksum

const
  FAKE_CHECKSUM = '        ';
var
  fn: string;
  fn2: AnsiString;
  pre, s, fnU: RawByteString;
begin
  fn := replaceStr(flist[cur].dst, '\', '/');
  if fileNamesOEM then
    begin
      CharToOem(pChar(fn), pAnsiChar(fn2));
      fn := fn2;
    end;

  pre := '';
  fnU := StrToUTF8(fn);
  if length(fnU) >= 100 then
    begin
      pre := str('././@LongLink', 124)+num(length(fnU)+1, 12)+num(0, 12)
        +FAKE_CHECKSUM+'L';
      applyChecksum(pre);
      pre := str(pre, 512)+str(fnU, 512);
    end;
{ // old ustar format
  s := str(fnU, 100)
    +'100666 '#0'     0 '#0'     0 '#0 // file mode, uid, gid
    +num(flist[cur].size, 12) // file size
    +num(flist[cur].mtime, 12)  // mtime
    +FAKE_CHECKSUM
    +'0'+str('', 100)       // link properties
    +'ustar  '#0+str('user',32) + str('group',32);    // not actually used
}
 // posix format
  s := str(fnU, 100)
    +'100666 '#0'0000000'#0'0000000'#0 // file mode, uid, gid
    + #$80#0#0#0
    + qword_BEasStr(flist[cur].size) // file size
    +num(flist[cur].mtime, 12)  // mtime
    +FAKE_CHECKSUM
    +'0'+str('', 100)       // link properties
    +'ustar'#0'00'+str('',32) + str('',32);    // not actually used

  applyChecksum(s);
  s := str(s, 512); // pad
  block.Size := 0;
//  block.WriteString(pre+s);
  if Length(pre) > 0 then
    {$IFDEF FPC}
    block.Write(pre[1], Length(pre));
    {$ELSE ~FPC}
    block.WriteData(@pre[1], Length(pre));
    {$ENDIF ~FPC}
  if Length(s) > 0 then
    {$IFDEF FPC}
    block.Write(s[1], Length(s));
    {$ELSE ~FPC}
    block.WriteData(@s[1], Length(s));
    {$ENDIF ~FPC}
  block.seek(0, soBeginning);
end; // headerInit

function TtarStream.write(const Buffer; Count: Longint): Longint;
begin
  raise EWriteError.Create('write unsupproted')
end;

function gap512(i: int64): word; inline;
begin
  result := i and 511;
  if result > 0 then
    result:=512-result;
end; // gap512

function eos(s: Tstream): boolean;
begin
  result := s.position >= s.size
end;

procedure TtarStream.padInit(full: boolean=FALSE);
begin
  block.Size := 0;
  block.WriteString(dupeString(#0, math.IfThen(full, 512, gap512(pos)) ));
  block.Seek(0, soBeginning);
end; // padInit

function TtarStream.headerLengthForFilename(const fn: string): integer;
begin
  result := length(fn);
  result := 512 * math.IfThen(result<100, 1, 3+result div 512);
end; // headerLengthForFilename

procedure TtarStream.calculate();
var
  pos: int64;
  i: integer;
begin
pos:=0;
for i:=0 to length(flist)-1 do
  with flist[i] do
    begin
    firstByte:=pos;
    inc(pos, size+headerLengthForFilename(dst));
    inc(pos, gap512(pos));
    end;
inc(pos, 512); // last empty block
cachedTotal:=pos;
end; // calculate

function TtarStream.seek(const Offset: Int64; Origin: TSeekOrigin): Int64;

  function left(): int64;
  begin
    result := offset-pos
  end;

  procedure fineSeek(s: Tstream);
  begin
    inc(pos, s.seek(left(), soBeginning))
  end;

  function skipMoreThan(size: int64):boolean;
  begin
    result := left() > size;
    if result then
      inc(pos, size);
  end;

var
  bak: int64;
  prevCur: integer;
begin
{ The lastSeekFake trick is a way to fastly manage a sequence of
  seek(0,soCurrent); seek(0,soEnd); seek(0,soBeginning);
  such sequence called very often, while it is used to just read
  the size of the stream, no real seeking requirement.
}
  bak:=lastSeekFake;
  lastSeekFake:=-1;
  if totalSize <0 then
    calculate;
  if (origin = soCurrent) and (offset <> 0) then
    seek(pos+offset, soBeginning);
  if origin = soEnd then
    if offset < 0 then
      seek(totalSize+offset, soBeginning)
     else
      begin
        lastSeekFake:=pos;
        pos:=totalsize;
      end;
  result:=pos;
  if origin <> soBeginning then
    exit;
  if bak >= 0 then
  begin
    pos:=bak;
    exit;
  end;

// here starts the normal seeking algo

prevCur := cur;
cur:=0;  // flist index
pos:=0;  // current position in the file
block.size:=0;
while (left() > 0) and (cur < length(flist)) do
  begin
  // are we seeking inside this header?
  if not skipMoreThan(headerLengthForFilename(flist[cur].dst)) then
    begin
    if (prevCur <> cur) or (where <> TW_HEADER) or eos(block) then
      headerInit();
    fineSeek(block);
    where:=TW_HEADER;
    break;
    end;
  // are we seeking inside this file?
  if not skipMoreThan(flist[cur].size) then
    begin
    if not fsInit() then
      raise Exception.Create('TtarStream.seek: cannot open '+flist[cur].src);
    fineSeek(fs);
    where:=TW_FILE;
    break;
    end;
  // are we seeking inside this pad?
  if not skipMoreThan(gap512(pos)) then
    begin
    padInit();
    fineSeek(block);
    where:=TW_PAD;
    break;
    end;
  inc(cur);
  end;//while
if left() > 0 then
  begin
  padInit(TRUE);
  fineSeek(block);
  end;
result:=pos;
end; // seek

function TtarStream.read(var Buffer; Count: Longint): Longint;
var
  p: Pbyte;

  procedure goForth(d: int64); overload;
  begin
    dec(count, d);
    inc(pos, d);
    inc(p, d);
  end; // goForth

  procedure goForth(s: Tstream); overload;
  begin
    goForth( s.read(p^, count) )
  end;

var
  i, posBak: int64;
begin
posBak:=pos;
p:=@buffer;
while (count > 0) and (cur < length(flist)) do
  case where of
    TW_HEADER:
      begin
      if block.size = 0 then
        headerInit();
      goForth(block);
      if not eos(block) then continue;
      where:=TW_FILE;
      block.size:=0;
      end;
    TW_FILE:
      begin
      fsInit();
      if assigned(fs) then
        goForth(fs);
      { We reserved a fixed space for this file in the archive, but the file
        may not exist anymore, or its size may be shorter than expected,
        so we can't rely on eos(fs) to know if we are done in this section.
        Lets calculate how far we are from the theoretical end of the file,
        and decide after it.
      }
      i:=headerLengthForFilename(flist[cur].dst);
      i:=flist[cur].firstByte+i+flist[cur].size-pos;
      if count >= i then
        where:=TW_PAD;
      // In case the file is shorter, we pad the rest with NUL bytes
      i:=min(count, max(0,i));
      fillChar(p^,i,0);
      goForth(i);
      end;
    TW_PAD:
      begin
        if block.size = 0 then
          padInit();
        goForth(block);
        if not eos(block) then
          continue;
        where:=TW_HEADER;
        block.size:=0;
        inc(cur);
      end;
    end;//case

// last empty block
if count > 0 then
  begin
  padInit(TRUE);
  goForth(block);
  end;
result:=pos-posBak;
end; // read

end.
