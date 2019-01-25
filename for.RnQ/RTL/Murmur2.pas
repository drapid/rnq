{$OVERFLOWCHECKS OFF}
unit Murmur2;
 
interface
 
uses
  SysUtils, Classes;
 
function CalcMurmur2(const Bytes: TBytes; const Seed: LongWord = $9747B28C): LongWord; overload;
function CalcMurmur2(Stream: TStream; const Seed: LongWord = $9747B28C): LongWord; overload;
 
implementation
 
function CalcMurmur2(const Bytes: TBytes; const Seed: LongWord = $9747B28C): LongWord;
var
  hash: LongWord;
  len: LongWord;
  k: LongWord;
  data: Integer;
const
  // 'm' and 'r' are mixing constants generated offline.
  // They're not really 'magic', they just happen to work well.
  m = $5BD1E995;
  r = 24;
begin
  len := Length(Bytes);
 
  // The default seed, $9747b28c, is from the original C library
 
  // Initialize the hash to a 'random' value
  hash := Seed xor len;
 
  // Mix 4 bytes at a time into the hash
  data := 0;
 
  while (len >= 4) do
  begin
    k := PLongWord(@Bytes[data])^;
 
    k := k * m;
    k := k xor (k shr r);
    k := k * m;
 
    hash := hash * m;
    hash := hash xor k;
 
    inc(data, 4);
    dec(len, 4);
  end;
 
  { Handle the last few bytes of the input array
    S: ... $69 $18 $2f
  }
  Assert(len <= 3);
  if len = 3 then
    hash := hash xor (LongWord(Bytes[data + 2]) shl 16);
  if len >= 2 then
    hash := hash xor (LongWord(Bytes[data + 1]) shl 8);
  if len >= 1 then
  begin
    hash := hash xor (LongWord(Bytes[data]));
    hash := hash * m;
  end;
 
  // Do a few final mixes of the hash to ensure the last few
  // bytes are well-incorporated.
  hash := hash xor (hash shr 13);
  hash := hash * m;
  hash := hash xor (hash shr 15);
 
  Result := hash;
end;
 
function CalcMurmur2(Stream: TStream; const Seed: LongWord = $9747B28C): LongWord;
var
  SavePosition: Int64;
  Bytes: TBytes;
begin
  SavePosition := Stream.Position;
  try
    Stream.Position := 0;
    SetLength(Bytes, Stream.Size);
    Stream.ReadBuffer(Pointer(Bytes)^, Length(Bytes));
    Result := CalcMurmur2(Bytes);
  finally
    Stream.Position := SavePosition;
  end;
end;
 
end.