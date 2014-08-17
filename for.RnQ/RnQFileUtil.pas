{
This file is part of R&Q.
Under same license
}
unit RnQFileUtil;
{$I ForRnQConfig.inc}
{$I NoRTTI.inc}

interface
  uses
   Windows, RDGlobal,
    Classes;

// file management
  function  appendFile(const fn:string; const data: RawByteString):boolean;

implementation
  uses
 {$IFDEF RNQ}
    RQUtil, RnQGlobal,
    RnQLangs,
    RnQDialogs,
 {$ENDIF RNQ}
    SysUtils
    ;


function appendFile(const fn:string; const data: RawByteString):boolean;
var
 fs : TFileStream;
 md : Word;
  b : Boolean;
begin
  if FileExists(fn) then
    md := fmOpenWrite
   else
    md := fmCreate;
  fs := NIL;
  try
    md := md or fmShareDenyWrite;
    fs := TFileStream.Create(fn, md);
//    if fs then
    fs.Seek(0, soFromEnd);
    fs.WriteBuffer(data[1], length(data));
    result := True;
    fs.Free;
  except
    if Assigned(fs) then fs.Free;
    result := false;
 {$IFDEF RNQ}
     b := logpref.evts.onfile;
     logpref.evts.onfile := False;
     msgdlg( getTranslation('Coudn''t append file %s', [fn]), False, mtError);
     logpref.evts.onfile := b;
 {$ENDIF RNQ}
  end;
{
var
  f:file;
  b : Boolean;
begin
  IOresult;
  assignFile(f,fn);
  reset(f,1);
  if IOresult <> 0 then
    rewrite(f,1)
  else
    seek(f,fileSize(f));
  blockWrite(f, data[1], length(data));
  closeFile(f);
  result:=IOresult=0;
  if not result then
   begin
     b := logpref.evts.onfile;
     logpref.evts.onfile := False;
     msgdlg( getTranslation('Coudn''t append file %s', [fn]), mtError);
     logpref.evts.onfile := b;
   end;      }
end; // appendFile


end.
