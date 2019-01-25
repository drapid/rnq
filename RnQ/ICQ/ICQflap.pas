{
  This file is part of R&Q.
  Under same license
}
unit ICQflap;
{$I RnQConfig.inc}
{$I NoRTTI.inc}

interface

uses
  sysutils, types, RDGlobal, RnQProtocol;

const

  FLAP_HEAD_SIZE = 6;
  SNAC_HEAD_SIZE = 10;
type
  TsnacService = word;

  TflapQueue = class(Tobject)
    buff: RawByteString;
    constructor create;
    procedure add(const s: RawByteString);
    function  error: boolean;     // errore di protocollo, è necessario invocare popError per continuare
    function  errorTill: integer; // fino a questo byte i dati sono considerati errati
    function  available: boolean; // disponibilità di un pacchetto
    function  pop: RawByteString;      // estrale il pacchetto
    function  popError: RawByteString;   // estrae i dati errati dalla coda
    function  bodySize: integer;
    procedure reset;
   end; // TflapQueue

// snac/flap/mp
function getFlapChannel(const s: RawByteString): byte;
function getSnacService(const s: RawByteString): TsnacService;
function getSnacRef(const s: RawByteString): dword;
function getSnacFlags(const s: RawByteString): word;
function getMPservice(const s: RawByteString): word;

// build data
function SNAC(fam, sub, flags: word; ref: integer): RawByteString; overload;
function SNAC(fam, sub: word; ref: integer): RawByteString; overload;

function SNAC_ver(fam, sub, flags: word; ref: integer; ver: word): RawByteString; overload;
function SNAC_shortver(fam, sub, flags: word; ref: integer; ver: word): RawByteString; overload;

// read data
function readBUIN2(const s: RawByteString; var ofs: integer): RawByteString;
function readBUIN(const s: RawByteString; var ofs: integer): Integer;
function readBUIN8(const s: RawByteString; var ofs: integer): TUID;

function Length_B8(const UIN: TUID): RawByteString; OverLoad;
function Length_B(const UIN: TUID): RawByteString; OverLoad;

implementation
uses
 {$IFDEF UNICODE}
   AnsiStrings,
 {$ENDIF UNICODE}
   Windows,
   RnQBinUtils, RQUtil, RDUtils;

// For ICQ
function getMPservice(const s: RawByteString): word;
begin
  result := byte(s[16+11]);
  if (result=$DA) or (result=$D0) then
    result := result shl 8+ byte(s[16+11+4])
end; // getMPservice

function getSnacRef(const s: RawByteString): dword;
begin
  result := dword_BEat(s, 13)
end;

function getSnacFlags(const s: RawByteString): word;
begin
  result := word_BEat(s, 11)
end;

function getSnacService(const s: RawByteString): word;
begin
  result := byte(s[8]) shl 8 + byte(s[10])
end;

function getFlapChannel(const s: RawByteString): byte;
begin
  result := Byte(s[2])
end;

function readBUIN2(const s: RawByteString; var ofs: integer): RawByteString;
begin
//result:=strToInt(copy(s,ofs+1,ord(s[ofs])));
  result := copy(s, ofs+1, ord(s[ofs]));
  inc(ofs, 1+ord(s[ofs]));
end; // readBUIN

function readBUIN8(const s: RawByteString; var ofs: integer): TUID;
begin
 {$IFDEF UID_IS_UNICODE}
  result := UnUTF( copy(s, ofs+1, ord(s[ofs])));
 {$ELSE ~UID_IS_UNICODE}
  result := copy(s, ofs+1, ord(s[ofs]));
 {$ENDIF ~UID_IS_UNICODE}
  inc(ofs, 1+ord(s[ofs]));
end; // readBUIN8

function readBUIN(const s: RawByteString; var ofs: integer): Integer;
var
  E: Integer;
//  ss: AnsiString;
  ss: String;
begin
//  result:=strToInt(ss);
  ss := copy(s, ofs+1, byte(s[ofs]));
  Val(ss, Result, E);
  if e <> 0 then
    Result := 0;
//result := copy(s,ofs+1,ord(s[ofs]));
  inc(ofs, 1+ byte(s[ofs]));
end; // readBUIN

function Length_B8(const UIN: TUID): RawByteString;
var
  s: RawByteString;
begin
  s := UTF8Encode(UIN);
  result := AnsiChar(byte(length(s))) + RawByteString(s)
end;

function Length_B(const UIN: TUID): RawByteString;
begin
  result := AnsiChar(byte(length(UIN))) + RawByteString(UIN)
end;

function SNAC(fam, sub, flags: word; ref: integer): RawByteString; overload;
begin
  result := word_BEasStr(fam)+word_BEasStr(sub)+word_BEasStr(flags)+dword_BEasStr(ref)
end;

function SNAC(fam, sub: word; ref: integer): RawByteString; overload;
begin
  result := word_BEasStr(fam)+word_BEasStr(sub)+word_BEasStr(0)+dword_BEasStr(ref)
end;

function SNAC_ver(fam, sub, flags: word; ref: integer; ver: word): RawByteString; overload;
begin
  result := word_BEasStr(fam) + word_BEasStr(sub) + word_BEasStr(flags or $8000)
           + dword_BEasStr(ref) + Length_BE(TLV(1, Word(ver)));
end;

function SNAC_shortver(fam, sub, flags: word; ref: integer; ver: word): RawByteString; overload;
begin
  result := word_BEasStr(fam) + word_BEasStr(sub) + word_BEasStr(flags) + dword_BEasStr(ref);
end;


////////////////////////////// FLAP QUEUE ////////////////////////////

constructor TflapQueue.create;
begin
  reset
end;

procedure TflapQueue.reset;
begin
  buff := ''
end;

procedure TflapQueue.add(const s: RawByteString);
begin
  buff := buff+s
end;

function TflapQueue.error: boolean;
begin
 error := ((buff>'') and (buff[1]<>'*'))
        or ((length(buff)>1) and ((buff[2]=#0) or (buff[2]>#5)))
end; // error

function TflapQueue.errorTill: integer;
begin
  result := -1;
  if buff='' then
    exit;
  result := 1;
  while (result<=length(buff)) and
      ((buff[result]<>'*') or (result<length(buff)) and ((buff[result+1]=#0) or (buff[result+1]>#4))) do
    inc(result);
end; // errorTill

function TflapQueue.popError: RawByteString;
var
  i: integer;
begin
  i := errorTill;
  result := copy(buff, 1, i);
  delete(buff, 1, i);
end; // popError

function TflapQueue.bodySize: integer;
begin
  result := word_BEat(@buff[5])
end;

function TflapQueue.available: boolean;
begin
  result := not error
       and (length(buff) >= FLAP_HEAD_SIZE)   // bodysize exists only if this is true
       and (length(buff) >= FLAP_HEAD_SIZE+bodySize)
end; // available

function TflapQueue.pop: RawByteString;
var
  i: Integer;
begin
  if not available then
   begin
    result := '';
    exit;
   end;
  i := FLAP_HEAD_SIZE + bodysize;
  result := copy(buff, 1, i);
  delete(buff, 1, i);
end; // pop

end.

