unit HistWork;

interface

//uses windows, classes;

procedure AddHistory(OldPath,NewPath: ShortString; uin : LongInt; var s: String);
//function AddHistory(OldPath,NewPath,OldPas,NewPas: ShortString; var s: String): Byte;
procedure AddFile(OldPath,NewPath : ShortString; var s: String);
//function AddEvent(filename: PChar; EType: Byte; Uin: LongInt; DT: TDateTime; TextMessage: PChar; flags: Byte): Byte;
//procedure CnvJimmToRq(OutUIN:Integer; path: ShortString; var s: String);
//procedure Cure(path: ShortString; var S: String);
//procedure RunChkDates(path: ShortString);

var
//     Splicing: function (Path1,Path2,Pas1,Pas2: ShortString; hash1,hash2:Pchar; Buf : pchar; BufLen : cardinal; var size: Word): Byte; StdCall;
     Splicing: procedure (path1,path2: ShortString; uinout: LongInt; Buf1: pAnsiChar; Buf1Len: cardinal); StdCall;
//     ReNum: function (Path1,Path2,pas1,pas2: ShortString; hash1,hash2:Pchar): Byte;  StdCall;
     ReNum: procedure(InFile, OutFile: ShortString; Buf1: pAnsiChar; Buf1Len: cardinal); StdCall;
//     AddMessage: function (filename: PChar; EType: Byte; Uin: LongInt; DT: TDateTime; TextMessage: PChar; flags: Byte): Byte; StdCall;
//     JimmToRq : procedure (OutUIN:Integer; path: ShortString); StdCall;
     JimmToRq : procedure (OutUIN:Integer; path: ShortString; Buf1 : pAnsiChar; Buf1Len : cardinal; var size: word);StdCall;
//     CureHistory: procedure (path: ShortString; Buf1 : pchar; Buf1Len : cardinal); StdCall;
//     CheckDates: procedure (path: ShortString); StdCall;
     LibHandle: THandle;

implementation

procedure AddHistory(OldPath, NewPath: ShortString; uin: LongInt; var s: String);
var
    Buf: array[word] of AnsiChar;
//    size: word;
begin
 try
  if @Splicing <> nil then
    Splicing(OldPath, NewPath, uin, Buf, sizeof(Buf));
  s := Buf;
 except
  s := 'Error!'
 end;
end;

procedure AddFile(OldPath, NewPath: ShortString; var s: String);
var
    Buf: array[word] of AnsiChar;
begin
 try
  if @ReNum <> nil then
     ReNum(OldPath,NewPath,Buf,sizeof(Buf));
  s := Buf;
 except
  s := 'Error!'
 end;
end;
{
function AddEvent(filename: PChar; EType: Byte; Uin: LongInt; DT: TDateTime; TextMessage: PChar; flags: Byte): Byte;
begin
  if @AddMessage <> nil then
     Result := AddMessage(filename,EType,Uin,DT,TextMessage,flags);
end;


procedure CnvJimmToRq(OutUIN:Integer; path: ShortString; var s: String);
var
    Buf : array[word] of char;
    size: word;
begin
  if @JimmToRq <> nil then
    begin
     JimmToRq(OutUIN,path, Buf,sizeof(Buf), size);
     s := Buf;
    end
  else
    s := 'Function not found in DLL'#13#10'Update HistoryLib.DLL!';
end;

procedure Cure(path: ShortString; var S: String);
var
    Buf : array[word] of char;
    size: word;
begin
  if @CureHistory <> nil then
    begin
     CureHistory(path, Buf,sizeof(Buf));
     s := Buf;
    end
  else
    s := 'Function not found in DLL'#13#10'Update HistoryLib.DLL!';
end;
}

{procedure RunChkDates(path: ShortString);
begin
 try
  if @CheckDates <> nil then
     CheckDates(Path);
 except
 end;
end;
}
end.
