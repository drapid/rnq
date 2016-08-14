{
This file is part of R&Q2.
Under same license
}
unit RnQDBPrefs;
{$I ForRnQConfig.inc}

 {$IFDEF COMPILER_14_UP}
  {$WEAKLINKRTTI ON}
  {$RTTI EXPLICIT METHODS([]) FIELDS([]) PROPERTIES([])}
 {$ENDIF COMPILER_14_UP}

interface
 uses
   Windows, Forms, Classes, iniFiles,
   ASGSQLite3Api,
   RnQDB, RDGlobal;


type
  TElemType = (ET_String = 0, ET_Integer, ET_Blob, ET_Blob64, ET_Double, ET_Date, ET_Time, ET_Bool);
  TPrefElem =  record
    case TElemType of
      ET_String : (sVal : PChar);
      ET_Integer: (iVal : Integer);
      ET_Blob   : (bVal : PAnsiChar);
      ET_Blob64 : (rVal : PAnsiChar);
      ET_Double : (dVal : Double);
      ET_Date   : (tVal : TDateTime);
      ET_Bool   : (yVal : Boolean);
  end;

  TPrefElement =  Class(TObject) //record
   public
    ElType : TElemType;
    elem   : TPrefElem;
    procedure Clear;
    Destructor Destroy; OverRide;
    function AsBlob : RawByteString;
    function Clone : TPrefElement;
  end;

type
   TRnQPref = class
     private
       fPrefStr : THashedStringList;
       fInUpdate : Boolean;
     public
      AccID : String;
      constructor Create;
      Destructor Destroy; OverRide;
      procedure Load(const cfg : RawByteString);
 {$IFDEF DB_ENABLED}
      procedure LoadFromDB(pDB : sqlite3_ptr);
      procedure Save2DB(pDB : sqlite3_ptr);
 {$ENDIF DB_ENABLED}
      procedure resetPrefs;
      procedure getPrefStr(const key:String; var Val : String);
      procedure getPrefBool(const key:String; var Val : Boolean);
      procedure getPrefBlob(const key:String; var Val : RawByteString);
      procedure getPrefBlob64(const key:String; var Val : RawByteString);
      procedure getPrefInt(const key:String; var Val : Integer);
      procedure getPrefDate(const key:String; var Val : TDateTime);
      procedure getPrefDateTime(const key:String; var Val : TDateTime);
      procedure getPrefValue(const key:String; et : TElemType; var Val : TPrefElem);
      function getPrefBoolDef(const key:String; const DefVal : Boolean): Boolean;
      function getPrefBlobDef(const key:String; const DefVal : RawByteString = ''): RawByteString;
      function getPrefBlob64Def(const key:String; const DefVal : RawByteString = ''): RawByteString;
      function getPrefStrDef(const key:String; const DefVal : String = ''): String;
      function getPrefIntDef(const key:String; const DefVal : Integer = -1) : Integer;
      function getPrefVal(const key:String) : TPrefElement;

      function getAllPrefs : RawByteString;

      procedure DeletePref(const key:String);
      function  prefExists(const key:String) : Boolean;

      procedure addPref(const key: String; const valType : Integer;
                        const Val: RawByteString);
      procedure addPrefBlobOld(const key : String; const Val : RawByteString);
      procedure addPrefBlob64(const key : String; const Val : RawByteString);
      procedure addPrefInt(const key : String; const Val : Integer);
      procedure addPrefBool(const key : String; const Val : Boolean);
      procedure addPrefStr(const key : String; const Val : String);
      procedure addPrefTime(const key : String; const Val : TDateTime);
 {$IFDEF DELPHI_9_UP}
      procedure addPrefDate(const key : String; const Val : TDate);
 {$ENDIF DELPHI_9_UP}
      procedure addPrefParam(param : TObject);
      procedure addPrefArrParam(param : array of TObject);
      procedure getPrefArrParam(param : array of TObject);

      procedure initPrefBool(const key : String; const Val : Boolean);
      procedure initPrefInt(const key : String; const Val : Integer);
      procedure initPrefStr(const key : String; const Val : String);

      procedure BeginUpdate;
      procedure EndUpdate;

      property  isUpdating : Boolean read fInUpdate;
   end;


  TPrefFrame = class(TFrame)
  public
    FOldCreateOrder : Boolean;
    FPixelsPerInch  : Integer;
    FTextHeight     : Integer;
    fAccIDX         : Integer;
    procedure applyPage; virtual; abstract;
    procedure resetPage; virtual; abstract;
    procedure updateVisPage; virtual;
    procedure initPage; virtual;
    procedure unInitPage; virtual;
  published
    property TabOrder;
    property TabStop;
    property OldCreateOrder: Boolean read FOldCreateOrder write FOldCreateOrder;
    property PixelsPerInch: Integer read FPixelsPerInch write FPixelsPerInch stored False;
    property TextHeight: Integer read FTextHeight write FTextHeight;
//    property OldCreateOrder;
//    property PixelsPerInch;
//    property TextHeight;
    property ClientHeight;
    property ClientWidth;
    property AccIDX : Integer read fAccIDX;
  end;

  TPrefFrameClass = class of TPrefFrame;

  PPrefPage = ^TPrefPage;
  TPrefPage = class
   public
    idx   : byte;
    frame : TPrefFrame;
    frameClass : TPrefFrameClass;
    GroupName : String;
    Name,
    Caption : string;
    fProtoIDX : Integer;
//    proto : IRnQProtocol;
   public
     destructor Destroy; override;
     function Clone : TPrefPage;
  end;
  TPrefPagesArr = array of TPrefPage;

//  function getPrefString(const key:String; const DefVal : String):string;

//  Procedure PrefAddStr(const k : String; v : String; Mas : THashedStringList);

//  procedure ClearPrefs;
//  procedure resetPrefs;

  procedure ClearPrefElement(vt : TElemType; var val : TPrefElem);
  procedure CopyPrefElement(vt0 : TElemType; val0 : TPrefElem;
                            vt : TElemType; var val : TPrefElem);


type
  TPortElement =  Class(TObject) //record
   public
    Count : Integer;
    lPort, rPort : Integer;
  end;

  TPortList = class(TStringList)
    public
     PortsCount : Integer;
     procedure AddPorts(pLPort : Integer; pRPort : Integer = 0);
     procedure parseString(const s : String);
     function getString : String;
     function getRandomPort : Integer;
  end;


implementation
 uses
   StrUtils,
   SysUtils, Character, ExtCtrls, StdCtrls, Controls,
 {$IFDEF DB_ENABLED}
//  RnQ2SQL,
//   SQLite3Commons,
//   SynCommons,
   RnQ2SQL,
 {$ENDIF DB_ENABLED}
   RnQStrings, RQUtil, RnQSpin, RDUtils, RQlog,
 {$IFDEF UNICODE}
   AnsiStrings,
 {$ENDIF UNICODE}
   Base64;

 {$IFDEF DB_ENABLED}
const
//  SQLSelectAllPrefs : AnsiString = 'SELECT key, val_type, val FROM Pref;';
  SQLSelectAllPrefs : AnsiString = 'SELECT key, val_type, val FROM Pref'+
    ' WHERE AccID IS NULL;';

  SQLSelectAccPrefs : AnsiString = 'SELECT key, val_type, val FROM Pref'+
    ' WHERE AccID = ?;';
 {$ENDIF DB_ENABLED}

procedure TPrefFrame.updateVisPage;
begin end;
procedure TPrefFrame.initPage;
begin end;
procedure TPrefFrame.unInitPage;
begin end;


(*
Procedure PrefAddVal(const k : String; const v : AnsiString; Mas : THashedStringList);
var
//  so : TPUStrObj;
  El : TPrefElement;
  i : Integer;
begin
  i := Mas.IndexOf(k);
  if i>=0 then
    begin
      el := TPrefElement(Mas.Objects[i]);
//     so := TPUStrObj(Mas.Objects[i]);
//      FreeMemory(so.Str);
      el.Clear;
    end
   else
    el := TPrefElement.Create;
//  so.Str := GetMemory(Length(v)+1);
  el.ElType := ET_Blob;
//  el.elem.sVal :=AllocMem((Length(v)+1)*SizeOf(Char));
//  el.elem.bVal :=AllocMem((Length(v)+1)*SizeOf(AnsiChar));
//  GetMem(el.elem.bVal, Length(v) + 1);
{$IFDEF UNICODE}
  el.elem.bVal := AnsiStrAlloc(Length(v) + 1);
{$ELSE nonUNICODE}
  el.elem.bVal := StrAlloc(Length(v) + 1);
{$ENDIF UNICODE}
//{$IFNDEF UNICODE}
//  StrCopy(so.Str, PChar(v));
//{$ELSE UNICODE}
//  StrCopy(PAnsiChar(el.elem.bVal), PAnsiChar(v));
  CopyMemory(el.elem.bVal, @V[1], Length(V));
//{$ENDIF UNICODE}
  if i<0 then
    Mas.AddObject(k, el);
end;
*)

(*

{Procedure loadPrefFile(zp : TZipFile);
  function fullpath(fn:string):string;
  begin if ansipos(':',fn)=0 then result:=myPath+fn else result:=fn end;
var
  s : AnsiString;
  k,v:string;
  i, j : Integer;
begin
  i := -1;
  if Assigned(zp) then
   try
     i := zp.IndexOf(configFileName);
     if i >= 0 then
      s := zp.Uncompressed[i];
    except
     i := -1;
     s := '';
   end;
  if i < 0 then
    if FileExists(userPath+configFileName) then
      s := loadfile(userPath+configFileName)
     else
      s := loadfile(userPath+oldconfigFileName);
  loadPrefStr(s);
  s := loadfile(cmdlinepar.extraini);
  loadPrefStrs(s);
  s := '';
end;
}

procedure ClearPrefs;
begin
  if Assigned(PrefStr) then
    begin
     resetPrefs;
     FreeAndNil(PrefStr);
    end;
end;

*)
{ TRnQPref }

procedure TRnQPref.addPrefBlobOld(const key: String;
  const Val: RawByteString);
var
//  so : TPUStrObj;
  El : TPrefElement;
  i : Integer;
begin
  if key = '' then
    Exit;
  i := fPrefStr.IndexOf(key);
  if i>=0 then
    begin
      el := TPrefElement(fPrefStr.Objects[i]);
//     so := TPUStrObj(Mas.Objects[i]);
//      FreeMemory(so.Str);
      el.Clear;
    end
   else
    el := TPrefElement.Create;
//  so.Str := GetMemory(Length(v)+1);
  el.ElType := ET_Blob;
//  el.elem.sVal :=AllocMem((Length(v)+1)*SizeOf(Char));
//  el.elem.bVal :=AllocMem((Length(v)+1)*SizeOf(AnsiChar));
//  GetMem(el.elem.bVal, Length(v) + 1);
(*
{$IFDEF UNICODE}
  el.elem.bVal := AnsiStrAlloc(Length(Val) + 1);
{$ELSE nonUNICODE}
  el.elem.bVal := StrAlloc(Length(Val) + 1);
{$ENDIF UNICODE}
  CopyMemory(el.elem.bVal, @Val[1], Length(Val)+1);
*)
//  El.elem.bVal := StrNew(PAnsiChar(Val));
  El.elem.bVal := AllocMem((Length(Val)+1));
//  CopyMemory(el.elem.bVal, @Val[1], Length(Val));
  CopyMemory(el.elem.bVal, Pointer(Val), Length(Val));
//{$IFNDEF UNICODE}
//  StrCopy(so.Str, PChar(v));
//{$ELSE UNICODE}
//  StrCopy(PAnsiChar(el.elem.bVal), PAnsiChar(Val));
//{$ENDIF UNICODE}
  if i<0 then
    i := fPrefStr.AddObject(key, el);
//  Result := i;
end;
{
procedure TRnQPref.addPrefBlobOld2(const key : String; const Val : RawByteString);
var
  El : TPrefElement;
  i : Integer;
begin
  if key = '' then
    Exit;
  i := fPrefStr.IndexOf(key);
  if i>=0 then
    begin
      el := TPrefElement(fPrefStr.Objects[i]);
      el.Clear;
    end
   else
    el := TPrefElement.Create;
  el.ElType := ET_Blob;
  El.elem.bVal := AllocMem((Length(Val)+1));
  CopyMemory(el.elem.bVal, Pointer(Val), Length(Val));
  if i<0 then
    i := fPrefStr.AddObject(key, el);
end;
}
procedure TRnQPref.addPref(const key: String; const valType : Integer;
  const Val: RawByteString);
var
//  so : TPUStrObj;
  El : TPrefElement;
  i : Integer;
begin
  if key = '' then
    Exit;
  i := fPrefStr.IndexOf(key);
  if i>=0 then
    begin
      el := TPrefElement(fPrefStr.Objects[i]);
//     so := TPUStrObj(Mas.Objects[i]);
//      FreeMemory(so.Str);
      el.Clear;
    end
   else
    el := TPrefElement.Create;
//  so.Str := GetMemory(Length(v)+1);
  el.ElType := ET_Blob;
//  el.elem.sVal :=AllocMem((Length(v)+1)*SizeOf(Char));
//  el.elem.bVal :=AllocMem((Length(v)+1)*SizeOf(AnsiChar));
//  GetMem(el.elem.bVal, Length(v) + 1);
(*
{$IFDEF UNICODE}
  el.elem.bVal := AnsiStrAlloc(Length(Val) + 1);
{$ELSE nonUNICODE}
  el.elem.bVal := StrAlloc(Length(Val) + 1);
{$ENDIF UNICODE}
  CopyMemory(el.elem.bVal, @Val[1], Length(Val)+1);
*)
//  El.elem.bVal := StrNew(PAnsiChar(Val));
  El.elem.bVal := AllocMem((Length(Val)+1));
//  CopyMemory(el.elem.bVal, @Val[1], Length(Val));
  CopyMemory(el.elem.bVal, Pointer(Val), Length(Val));
//{$IFNDEF UNICODE}
//  StrCopy(so.Str, PChar(v));
//{$ELSE UNICODE}
//  StrCopy(PAnsiChar(el.elem.bVal), PAnsiChar(Val));
//{$ENDIF UNICODE}
  if i<0 then
    i := fPrefStr.AddObject(key, el);
//  Result := i;
end;

procedure TRnQPref.addPrefBlob64(const key : String;
                                 const Val : RawByteString);
var
  El : TPrefElement;
  i : Integer;
begin
  if key = '' then
    Exit;
  i := fPrefStr.IndexOf(key);
  if i>=0 then
    begin
      el := TPrefElement(fPrefStr.Objects[i]);
      el.Clear;
    end
   else
    el := TPrefElement.Create;
  el.ElType := ET_Blob64;
  El.elem.rVal := AllocMem((Length(Val)+1));
//  CopyMemory(el.elem.bVal, @Val[1], Length(Val));
  CopyMemory(el.elem.rVal, Pointer(Val), Length(Val));
  if i<0 then
    i := fPrefStr.AddObject(key, el);
//  Result := i;
end;

procedure TRnQPref.addPrefBool(const key: String; const Val: Boolean);
var
  El : TPrefElement;
  i : Integer;
begin
  if key = '' then
    Exit;
  i := fPrefStr.IndexOf(key);
  if i>=0 then
    begin
      el := TPrefElement(fPrefStr.Objects[i]);
      el.Clear;
    end
   else
    el := TPrefElement.Create;
  el.ElType := ET_Bool;
  el.elem.yVal := Val;
  if i<0 then
    i := fPrefStr.AddObject(key, el);
//  Result := i;
end;

 {$IFDEF DELPHI_9_UP}
procedure TRnQPref.addPrefDate(const key: String; const Val: TDate);
var
  El : TPrefElement;
  i : Integer;
begin
  if key = '' then
    Exit;
  i := fPrefStr.IndexOf(key);
  if i>=0 then
    begin
      el := TPrefElement(fPrefStr.Objects[i]);
      el.Clear;
    end
   else
    el := TPrefElement.Create;
  el.ElType := ET_Date;
  el.elem.tVal := Val;
  if i<0 then
    i := fPrefStr.AddObject(key, el);
//  Result := i;
end;
 {$ENDIF DELPHI_9_UP}

procedure TRnQPref.addPrefInt(const key: String; const Val: Integer);
var
  El : TPrefElement;
  i : Integer;
begin
  if key = '' then
    Exit;
  i := fPrefStr.IndexOf(key);
  if i>=0 then
    begin
      el := TPrefElement(fPrefStr.Objects[i]);
      el.Clear;
    end
   else
    el := TPrefElement.Create;
  el.ElType := ET_Integer;
  el.elem.iVal := Val;
  if i<0 then
    i := fPrefStr.AddObject(key, el);
//  Result := i;
end;

procedure TRnQPref.addPrefParam(param: TObject);
begin
  if param is TCheckBox then
    addPrefBool(TCheckBox(param).HelpKeyword, TCheckBox(param).Checked);

end;

procedure TRnQPref.addPrefArrParam(param: array of TObject);
var
  pp : TObject;
begin
  for pp in param do
    if (pp is TCheckBox) {and (TCheckBox(pp).HelpKeyword > '')} then
     begin
      if TCheckBox(pp).HelpKeyword = '' then
        loggaEvtS('Parameter object ['+ TCheckBox(pp).Name + '], not have parameter-name', PIC_ASTERISK)
       else
        addPrefBool(TCheckBox(pp).HelpKeyword, TCheckBox(pp).Checked);
     end
    else
    if (pp is TrnqSpinEdit) then
      if TrnqSpinEdit(pp).HelpKeyword = '' then
        loggaEvtS('Parameter object ['+ TrnqSpinEdit(pp).Name + '], not have parameter-name', PIC_ASTERISK)
       else
        addPrefInt(TrnqSpinEdit(pp).HelpKeyword, TrnqSpinEdit(pp).AsInteger)
    else
    if (pp is TEdit) then
      if TEdit(pp).HelpKeyword = '' then
        loggaEvtS('Parameter object ['+ TEdit(pp).Name + '], not have parameter-name', PIC_ASTERISK)
       else
        addPrefStr(TEdit(pp).HelpKeyword, TEdit(pp).Text)
    else
    if (pp is TLabeledEdit) then
      if TControl(pp).HelpKeyword = '' then
        loggaEvtS('Parameter object ['+ TControl(pp).Name + '], not have parameter-name', PIC_ASTERISK)
       else
        addPrefStr(TControl(pp).HelpKeyword, TLabeledEdit(pp).Text)
    else
    if (pp is TRadioButton) then
     begin
      if TControl(pp).HelpKeyword = '' then
        loggaEvtS('Parameter object ['+ TControl(pp).Name + '], not have parameter-name', PIC_ASTERISK)
       else
        addPrefBool(TCheckBox(pp).HelpKeyword, TRadioButton(pp).Checked);
     end
end;

procedure TRnQPref.getPrefArrParam(param : array of TObject);
var
  pp : TObject;
  i : Integer;
  b : Boolean;
begin
  for pp in param do
    if (pp is TCheckBox) {and (TCheckBox(pp).HelpKeyword > '')} then
     begin
      if TCheckBox(pp).HelpKeyword = '' then
        loggaEvtS('Parameter object ['+ TCheckBox(pp).Name + '], not have parameter-name', PIC_ASTERISK)
       else
        begin
          b := TCheckBox(pp).Checked;
          getPrefBool(TControl(pp).HelpKeyword, b);
          TCheckBox(pp).Checked := b;
        end;
     end
    else
    if (pp is TrnqSpinEdit) then
     begin
      if TrnqSpinEdit(pp).HelpKeyword = '' then
        loggaEvtS('Parameter object ['+ TrnqSpinEdit(pp).Name + '], not have parameter-name', PIC_ASTERISK)
       else
        begin
          i := TrnqSpinEdit(pp).AsInteger;
          getPrefInt(TrnqSpinEdit(pp).HelpKeyword, i);
          TrnqSpinEdit(pp).AsInteger := i;
        end;
     end
    else
    if (pp is TEdit) then
     begin
      if TEdit(pp).HelpKeyword = '' then
        loggaEvtS('Parameter object ['+ TEdit(pp).Name + '], not have parameter-name', PIC_ASTERISK)
       else
        begin
          TEdit(pp).Text := getPrefStrDef(TControl(pp).HelpKeyword, '');
        end;
     end
    else
    if (pp is TRadioButton) then
     begin
      if TControl(pp).HelpKeyword = '' then
        loggaEvtS('Parameter object ['+ TControl(pp).Name + '], not have parameter-name', PIC_ASTERISK)
       else
        begin
          b := TRadioButton(pp).Checked;
          getPrefBool(TControl(pp).HelpKeyword, b);
          TRadioButton(pp).Checked := b;
        end;
     end

end;

procedure TRnQPref.addPrefStr(const key, Val: String);
var
//  so : TPUStrObj;
  El : TPrefElement;
  i : Integer;
begin
  if key = '' then
    Exit;
  i := fPrefStr.IndexOf(key);
  if i>=0 then
    begin
      el := TPrefElement(fPrefStr.Objects[i]);
//     so := TPUStrObj(Mas.Objects[i]);
//      FreeMemory(so.Str);
      el.Clear;
    end
   else
    el := TPrefElement.Create;
//  so.Str := GetMemory(Length(v)+1);
  el.ElType := ET_String;
//  el.elem.sVal := StrAlloc(Length(Val) + 1);
//{$IFNDEF UNICODE}
//  StrCopy(so.Str, PChar(v));
//{$ELSE UNICODE}
//  CopyMemory(el.elem.sVal, @Val[1], ByteLength(Val));
  El.elem.bVal := AllocMem((Length(Val)+1) * SizeOf(Char));
 {$IFDEF DELPHI_9_UP}
//  CopyMemory(el.elem.bVal, @Val[1], ByteLength(Val));
  CopyMemory(el.elem.bVal, Pointer(Val), ByteLength(Val));
 {$ELSE DELPHI_9_dn}
  CopyMemory(el.elem.bVal, Pointer(Val), Length(Val));
 {$ENDIF DELPHI_9_UP}
//  StrCopy(PChar(el.elem.sVal), PChar(Val));
//{$ENDIF UNICODE}
  if i<0 then
    i := fPrefStr.AddObject(key, el);
//  Result := i;
end;

procedure TRnQPref.addPrefTime(const key: String; const Val: TDateTime);
var
  El : TPrefElement;
  i : Integer;
begin
  if key = '' then
    Exit;
  i := fPrefStr.IndexOf(key);
  if i>=0 then
    begin
      el := TPrefElement(fPrefStr.Objects[i]);
      el.Clear;
    end
   else
    el := TPrefElement.Create;
  el.ElType := ET_Time;
  el.elem.tVal := Val;
  if i<0 then
    i := fPrefStr.AddObject(key, el);
//  Result := i;
end;

constructor TRnQPref.Create;
begin
  inherited;
//  if not Assigned(fPrefStr) then
  AccID := '';

  fPrefStr := THashedStringList.Create;
  fPrefStr.CaseSensitive := False;
  fInUpdate := false;
end;

procedure TRnQPref.DeletePref(const key: String);
var
//  so : TPUStrObj;
  El : TPrefElement;
  i : Integer;
begin
  i := fPrefStr.IndexOf(key);
  if i>=0 then
    begin
      el := TPrefElement(fPrefStr.Objects[i]);
//     so := TPUStrObj(Mas.Objects[i]);
//      FreeMemory(so.Str);
      fPrefStr.Objects[i] := NIL;
      el.Clear;
      El.Free;
      fPrefStr.Delete(i);
    end
end;

function TRnQPref.prefExists(const key:String) : Boolean;
begin
  Result := fPrefStr.IndexOf(key) >= 0;
end;

destructor TRnQPref.Destroy;
begin
  resetPrefs;
  fPrefStr.Free;
  fPrefStr := NIL;
  inherited;
end;

procedure TRnQPref.resetPrefs;
var
  i : Integer;
//  so : TPUStrObj;
  el : TPrefElement;
begin
  if Assigned(fPrefStr) then
    begin
     for I := 0 to fPrefStr.Count - 1 do
      begin
//       so := TPUStrObj(fPrefStr.Objects[i]);
       el := TPrefElement(fPrefStr.Objects[i]);
       el.Clear;
       fPrefStr.Objects[i] := NIL;
       el.Free;
      end;
     fPrefStr.Clear;
    end;
end; // resetLanguage

procedure TRnQPref.Load(const cfg : RawByteString);
var
  l: RawByteString;
  key : String;
  hhh : RawByteString;
  pp : PAnsiChar;
  p1, p2, // Position of CRLF
  len,
  m1, m : Integer;
//  lastVersion:integer;
//  i:integer;
begin
  if cfg = '' then exit;
  fPrefStr.Sorted := False;
  p1 := 1;
//  p2 := 1;
  len := Length(cfg);
 try
//  while p2 > 0 do
  while p1 < len do
  begin
    p2 := p1;
    m1 := 1;
    while (p2 < len) and not(cfg[p2] in [#10, #13]) do
     Inc(p2);
    if (p2<len) and (cfg[p2+1] in [#10, #13]) then
     inc(m1); // #13 + #10
//    p2 := PosEx(CRLF, cfg, p1);
//    if p2 > 0 then
      l := Copy(cfg, p1, p2-p1);
//     else
//      l := Copy(cfg, p1, len);
    p1 := p2 + m1;
//    l:=chop(CRLF,cfg);
//    hhh := LowerCase(chop(AnsiString('='),l));
//    hhh := copy(Trim(LowerCase(chop('=',l))), 1, 1000);
//    hhh := Trim(LowerCase(chop(RawByteString('='),l)));
    m := pos(RawByteString('='), l);
//    hhh := Copy(l, m+1, $FFFF);
    hhh := LowerCase(Trim(Copy(l, 1, m-1)));
    delete(l, 1, m);

    pp := PAnsiChar(hhh);
    key := pp;
//    PrefAddVal(key, l, fPrefStr);
    addPrefBlobOld(key, l);
  end;
 finally
  fPrefStr.Sorted := True;
 end;
end;

 {$IFDEF DB_ENABLED}
procedure TRnQPref.LoadFromDB(pDB : sqlite3_ptr);
var
  stmt : sqlite3_stmt_ptr;
  sql : AnsiString;
  ss : AnsiString;
  Tail : PWideChar;
  i : Integer;

  l: RawByteString;
  p : Pointer;
  itemType : Integer;
  key : String;
  Acc : AnsiString;
begin
//  loading := True;
  try
{   if AccID = '' then
     sql := SQLSelectAllPrefs
    else}
     sql := SQLSelectAccPrefs;
   i := sqlite3_prepare_v2(pDB, PUTF8Char(sql), Length(sql), Stmt, PUTF8Char(Tail));

//   if AccID > '' then
    begin
     Acc := StrToUTF8(AccID);
     SQLite3_Bind_text(stmt, 1, PUTF8Char(Acc), Length(Acc), SQLITE_TRANSIENT);
    end;

      if Stmt <> NIL then
//   if Stmt <> 0 then
    try
      while Sqlite3_Step(Stmt) = SQLITE_ROW do
        begin
          key := Sqlite3_Column_Text(Stmt, 0);
          itemType := Sqlite3_Column_Int(Stmt, 1);
//          l := Sqlite3_Column_Blob(Stmt, 2);
          P := sqlite3_column_blob(Stmt, 2);
          i := sqlite3_column_bytes(Stmt, 2);
          if (i > 0) and (p <> NIL) then
            begin
//              SetString(l, P, i);
              SetLength(l, i);
              CopyMemory(pointer(l), p, i);
            end
           else
            l := '';
          addPref(key, itemType, l);
        end;
    finally
//      Stmt.Free;
      if sqlite3_finalize(stmt) <> SQLITE_OK then
        ;
    end;
 finally
//  loading := false;
//  Result := Rows;
 end;
end;

procedure TRnQPref.Save2DB(pDB : sqlite3_ptr);
var
  stmt : sqlite3_stmt_ptr;
  sql : AnsiString;
  ss : AnsiString;
  Tail : PWideChar;
  i, k : Integer;

  l: RawByteString;
  itemType : Integer;
  keyA : RawByteString;
  valA : RawByteString;
  valT : Integer;
  Acc : AnsiString;
begin
//  loading := True;
  try
   execSQL(pDB, 'BEGIN TRANSACTION');
   sql := SQLInsertPref;
   i := sqlite3_prepare_v2(pDB, Putf8Char(sql), Length(sql), Stmt, Putf8Char(Tail));

      if Stmt <> NIL then
//   if Stmt <> 0 then
    for k := 0 to fPrefStr.Count - 1 do
     begin
      try
       if Assigned(fPrefStr.Objects[k]) then
        begin
          keyA := StrToUTF8(fPrefStr.Strings[k]);
          with TPrefElement(fPrefStr.Objects[k]) do
           begin
            valA := AsBlob;
            valT := Integer(ElType);
           end;
        end;
//       if AccID > '' then
         begin
          Acc := StrToUTF8(AccID);
          SQLite3_Bind_text(stmt, 1, PUTF8Char(Acc), Length(Acc), SQLITE_TRANSIENT);
         end;
//        else
//         SQLite3_bind
//         sqlite3_bind_zeroblob(stmt, 1, 0);
       SQLite3_Bind_text(stmt, 2, PUTF8Char(keyA), Length(keyA), SQLITE_TRANSIENT);
       SQLite3_Bind_Int(stmt, 3, valT);
       SQLite3_Bind_Blob(stmt, 4, PUTF8Char(valA), Length(valA), SQLITE_TRANSIENT);

       i := Sqlite3_Step(stmt);
{       if (i = SQLITE_ROW)or(i = SQLITE_DONE) then
         begin
           Result := True;
         end;}
      finally
       SQLite3_Reset(stmt);
      end;
     end;

 finally
    SQLite3_Finalize(stmt);
    execSQL(pDB, 'COMMIT TRANSACTION');
//  loading := false;
//  Result := Rows;
 end;
end;
 {$ENDIF DB_ENABLED}


function TRnQPref.getAllPrefs: RawByteString;
var
  I: Integer;
//  s : String;
begin
  Result := '';
  for I := 0 to fPrefStr.Count - 1 do
   begin
//     s := fPrefStr.Strings[i];
//     if s > '' then
     if Assigned(fPrefStr.Objects[i]) then
      Result := Result + AnsiString(fPrefStr.Strings[i]) + '='+
        TPrefElement(fPrefStr.Objects[i]).AsBlob + CRLF;
   end;

end;

procedure TRnQPref.getPrefBlob(const key:String; var Val : RawByteString);
var
  i : Integer;
  el : TPrefElement;
begin
   begin
//    Result := '';
     i := fPrefStr.IndexOf(key);
     if i >= 0 then
      begin
       el := TPrefElement(fPrefStr.Objects[i]);
       if el.ElType = ET_Blob then
         Val := ansistrings.StrPas(el.elem.bVal)
        else
       if el.ElType = ET_Blob64 then
         Val := ansistrings.StrPas(el.elem.rVal)
//        else
//         Result := DefVal;
      end
   end;
end;

procedure TRnQPref.getPrefBlob64(const key:String; var Val : RawByteString);
var
  i : Integer;
  el : TPrefElement;
begin
   begin
//    Result := '';
     i := fPrefStr.IndexOf(key);
     if i >= 0 then
      begin
       el := TPrefElement(fPrefStr.Objects[i]);
       if el.ElType = ET_Blob then
         Val := Base64DecodeString(ansistrings.StrPas(el.elem.bVal))
        else
       if el.ElType = ET_Blob64 then
         Val := ansistrings.StrPas(el.elem.rVal)
//        else
//         Result := DefVal;
      end
   end;
end;

function TRnQPref.getPrefBlobDef(const key:String; const DefVal : RawByteString): RawByteString;
var
  i : Integer;
  el : TPrefElement;
begin
   begin
    Result := '';
     i := fPrefStr.IndexOf(key);
     if i >= 0 then
      begin
       el := TPrefElement(fPrefStr.Objects[i]);
       if el.ElType = ET_Blob then
         Result := AnsiStrings.StrPas(el.elem.bVal)
        else
         Result := DefVal;
      end
     else
      begin
//        PrefAddStr(key, DefVal, PrefStr);
       Result := DefVal;
      end;
   end;
end;

function TRnQPref.getPrefBlob64Def(const key:String;
                         const DefVal : RawByteString): RawByteString;
var
  i : Integer;
  el : TPrefElement;
  sr : RawByteString;
begin
   begin
    Result := '';
     i := fPrefStr.IndexOf(key);
     if i >= 0 then
      begin
       el := TPrefElement(fPrefStr.Objects[i]);

       if el.ElType = ET_Blob then
         begin
           sr := ansistrings.StrPas(el.elem.rVal);
           if sr > '' then
             Result := Base64DecodeString(sr);
         end
        else
         if el.ElType = ET_Blob64 then
           Result := ansistrings.StrPas(el.elem.rVal)
          else
           Result := DefVal;
      end
     else
      begin
//        PrefAddStr(key, DefVal, PrefStr);
       Result := DefVal;
      end;
   end;
end;

procedure TRnQPref.getPrefStr(const key:String; var Val : String);
var
  i : Integer;
  el : TPrefElement;
begin
   begin
//    Result := '';
     i := fPrefStr.IndexOf(key);
     if i >= 0 then
      begin
       el := TPrefElement(fPrefStr.Objects[i]);
       if el.ElType = ET_Blob then
         Val := UnUTF(AnsiStrings.StrPas(el.elem.bVal))
        else
       if el.ElType = ET_String then
         Val := StrPas(el.elem.sVal)
//        else
//         Result := DefVal;
      end
   end;
end;

function TRnQPref.getPrefStrDef(const key:String; const DefVal : String): String;
var
  i : Integer;
  el : TPrefElement;
begin
   begin
    Result := '';
     i := fPrefStr.IndexOf(key);
     if i >= 0 then
      begin
       el := TPrefElement(fPrefStr.Objects[i]);
       if el.ElType = ET_Blob then
         Result := UnUTF(AnsiStrings.StrPas(el.elem.bVal))
        else
       if el.ElType = ET_String then
         Result := StrPas(el.elem.sVal)
        else
         Result := DefVal;
      end
     else
      begin
//        PrefAddStr(key, DefVal, PrefStr);
       Result := DefVal;
      end;
   end;
end;

  function yesnof(l : PAnsiChar):boolean; {$IFDEF DELPHI_9_UP}inline;{$ENDIF DELPHI_9_UP}
  const
    yyy = AnsiString('yes');
  begin
//    result := comparetext(l,)=0
    result := AnsiStrings.StrIComp(l, PAnsiChar(yyy)) = 0
  end;

procedure TRnQPref.getPrefBool(const key:String; var Val : Boolean);
var
  i : Integer;
  el : TPrefElement;
begin
   begin
     i := fPrefStr.IndexOf(key);
     if i >= 0 then
      begin
       el := TPrefElement(fPrefStr.Objects[i]);
       if el.ElType = ET_Blob then
         Val := yesnof(el.elem.bVal)
        else
       if el.ElType = ET_Bool then
         Val := el.elem.yVal
//        else
//         Result := DefVal;
      end
{     else
      begin
//        PrefAddStr(key, DefVal, PrefStr);
       Result := DefVal;
      end;}
   end;
end;

function TRnQPref.getPrefBoolDef(const key:String; const DefVal : Boolean): Boolean;
(*  function yesno(l : PAnsiChar):boolean; {$IFDEF DELPHI_9_UP}inline;{$ENDIF DELPHI_9_UP}
  const
    yyy = AnsiString('yes');
  begin
//    result := comparetext(l,)=0
    result := StrIComp(l, PAnsiChar(yyy)) = 0
  end;*)
var
  i : Integer;
  el : TPrefElement;
begin
   begin
    Result := DefVal;
     i := fPrefStr.IndexOf(key);
     if i >= 0 then
      begin
       el := TPrefElement(fPrefStr.Objects[i]);
       if el.ElType = ET_Blob then
         Result := yesnof(el.elem.bVal)
        else
       if el.ElType = ET_Bool then
         Result := el.elem.yVal
//        else
//         Result := DefVal;
      end
{     else
      begin
//        PrefAddStr(key, DefVal, PrefStr);
       Result := DefVal;
      end;}
   end;
end;

procedure TRnQPref.getPrefInt(const key:String; var Val : Integer);
  function int(l : PAnsiChar):integer; {$IFDEF DELPHI_9_UP}inline;{$ENDIF DELPHI_9_UP}
  var
    bb : Integer;
//    ss : AnsiString;
    ss : String;
  begin
    ss := l;
    System.Val(ss, Result, bb);
    if bb <> 0 then
     Result := 0;
  end;
var
  i : Integer;
  el : TPrefElement;
begin
   begin
     i := fPrefStr.IndexOf(key);
     if i >= 0 then
      begin
       el := TPrefElement(fPrefStr.Objects[i]);
       if el.ElType = ET_Blob then
         Val := int(el.elem.bVal)
        else
       if el.ElType = ET_Integer then
         Val := el.elem.iVal
//        else
//         Result := DefVal;
      end
{     else
      begin
//        PrefAddStr(key, DefVal, PrefStr);
       Result := DefVal;
      end;}
   end;
end;

function TRnQPref.getPrefIntDef(const key:String; const DefVal : Integer) : Integer;
  function int(l : PAnsiChar):integer; {$IFDEF DELPHI_9_UP}inline;{$ENDIF DELPHI_9_UP}
  var
    bb : Integer;
//    ss : AnsiString;
    ss : String;
  begin
    ss := l;
    System.Val(ss, Result, bb);
    if bb <> 0 then
     Result := 0;
  end;
var
  i : Integer;
  el : TPrefElement;
begin
  Result := DefVal;
   begin
     i := fPrefStr.IndexOf(key);
     if i >= 0 then
      begin
       el := TPrefElement(fPrefStr.Objects[i]);
       if el.ElType = ET_Blob then
         Result := int(el.elem.bVal)
        else
       if el.ElType = ET_Integer then
         Result := el.elem.iVal
//        else
//         Result := DefVal;
      end
{     else
      begin
//        PrefAddStr(key, DefVal, PrefStr);
       Result := DefVal;
      end;}
   end;
end;

procedure TRnQPref.getPrefDate(const key:String; var Val : TDateTime);
  function dt(l : PAnsiChar):Tdatetime; {$IFDEF DELPHI_9_UP}inline;{$ENDIF DELPHI_9_UP}
  var
    df : TFormatSettings;
    s : string;
  begin
   try
//    GetLocaleFormatSettings(0, df);
    df := TFormatSettings.Create('');
    df.ShortDateFormat := 'dd.mm.yyyy';
    df.DateSeparator := '.';
    s := Copy(l, 1, 10);
    result:=StrToDate(s, df);
   except
    result := 0;
   end;
  end;
var
  i : Integer;
  el : TPrefElement;
begin
   begin
     i := fPrefStr.IndexOf(key);
     if i >= 0 then
      begin
       el := TPrefElement(fPrefStr.Objects[i]);
       if el.ElType = ET_Blob then
         Val := dt(el.elem.bVal)
        else
       if el.ElType = ET_Date then
         Val := el.elem.tVal
//        else
//         Result := DefVal;
      end
{     else
      begin
//        PrefAddStr(key, DefVal, PrefStr);
       Result := DefVal;
      end;}
   end;
end;

procedure TRnQPref.getPrefDateTime(const key:String; var Val : TDateTime);
  function dtt(l : PAnsiChar):Tdatetime; {$IFDEF DELPHI_9_UP}inline;{$ENDIF DELPHI_9_UP}
  var
    df : TFormatSettings;
  begin
//    GetLocaleFormatSettings(0, df);
    df := TFormatSettings.Create('');
//    df.LongDateFormat := 'dd.mm.yyyy';
    df.ShortDateFormat := 'dd.mm.yyyy';
    df.DateSeparator := '.';
    df.LongTimeFormat := 'hh:mm:ss';
    df.ShortTimeFormat := 'hh:mm:ss';
    df.TimeSeparator := ':';
    result:=StrToDateTime(l, df);
  end;
var
  i : Integer;
  el : TPrefElement;
begin
   begin
     i := fPrefStr.IndexOf(key);
     if i >= 0 then
      try
       el := TPrefElement(fPrefStr.Objects[i]);
       if el.ElType = ET_Blob then
         Val := dtt(el.elem.bVal)
        else
       if el.ElType = ET_Time then
         Val := el.elem.tVal
//        else
//         Result := DefVal;
      except
        Val := 0;
      end
{     else
      begin
//        PrefAddStr(key, DefVal, PrefStr);
       Result := DefVal;
      end;}
   end;
end;

function TRnQPref.getPrefVal(const key:String) : TPrefElement;
var
  i : Integer;
//  el : TPrefElement;
begin
   begin
//    Result := '';
     i := fPrefStr.IndexOf(key);
     if i >= 0 then
      begin
       Result := TPrefElement(fPrefStr.Objects[i]).Clone;
      end
     else
       Result := NIL;
   end;
end;

procedure TRnQPref.getPrefValue(const key:String; et : TElemType; var Val : TPrefElem);
var
  i : Integer;
begin
   begin
//    Result := '';
     i := fPrefStr.IndexOf(key);
     if i >= 0 then
       begin
        CopyPrefElement(TPrefElement(fPrefStr.Objects[i]).ElType,
            TPrefElement(fPrefStr.Objects[i]).elem,
            et,
            Val)
       end
      else
       val.dVal := 0;
   end;

end;

procedure TRnQPref.initPrefBool(const key: String; const Val: Boolean);
begin
  if not prefExists(key) then
    addPrefBool(key, Val);
end;

procedure TRnQPref.initPrefInt(const key : String; const Val : Integer);
begin
  if not prefExists(key) then
    addPrefInt(key, Val);
end;

procedure TRnQPref.initPrefStr(const key : String; const Val : String);
begin
  if not prefExists(key) then
    addPrefStr(key, Val);
end;

procedure TRnQPref.BeginUpdate;
begin
  fInUpdate := True;
end;

procedure TRnQPref.EndUpdate;
begin
  fInUpdate := false;
end;

{ TPrefElement }

function TPrefElement.AsBlob: RawByteString;
begin
  case ElType of
    ET_String: begin
                 if elem.sVal <> NIL then
                   Result := StrToUTF8(StrPas(elem.sVal))
                  else
                   Result := '';
               end;
    ET_Integer:begin
                 Result := IntToStrA(elem.iVal);
               end;
    ET_Blob:   begin
                 if elem.bVal <> NIL then
                   Result := AnsiStrings.StrPas(elem.bVal)
                  else
                   Result := '';
               end;
    ET_Blob64:   begin
                 if elem.rVal <> NIL then
                   Result := Base64EncodeString(ansistrings.StrPas(elem.rVal))
                  else
                   Result := '';
               end;
    ET_Double: Str(elem.dVal : 0:4, Result);// :=  FloatToStr(elem.dVal);
    ET_Date: Result := AnsiString(FormatDateTime(Def_DateFormat, elem.tVal));
    ET_Bool: Result := yesno[elem.yVal];
    ET_Time: Result := AnsiString(FormatDateTime(Def_DateTimeFormat, elem.tVal));
  end;
end;

procedure TPrefElement.Clear;
begin
  case ElType of
    ET_String: begin
                 if elem.sVal <> NIL then
//                   StrDispose(elem.sVal);
                  FreeMemory(elem.sVal);
//                 elem.sVal := NIL;
               end;
//    ET_Integer: ;
    ET_Blob:   begin
                 if elem.bVal <> NIL then
//                   StrDispose(elem.bVal);
                  FreeMemory(elem.bVal);
//                 elem.bVal := NIL;
               end;
    ET_Blob64:   begin
                 if elem.rVal <> NIL then
//                   StrDispose(elem.bVal);
                  FreeMemory(elem.rVal);
//                 elem.bVal := NIL;
               end
   else
     elem.dVal := 0;
//    ET_Double: ;
//    ET_Date: ;
  end;
  ElType := ET_Integer;
  elem.dVal := 0;
end;

function TPrefElement.Clone: TPrefElement;
var
  l : Integer;
begin
  Result := TPrefElement.Create;
  Result.ElType := Self.ElType;
  case ElType of
    ET_String: begin
                 if elem.sVal <> NIL then
                   begin
                    l := StrLen(elem.sVal);
                    Result.elem.sVal := AllocMem((l+1) * SizeOf(Char));
                    CopyMemory(Result.elem.sVal, elem.sVal, l*SizeOf(Char));
                   end
                  else
                   Result.elem.sVal := NIL;
               end;
//    ET_Integer: ;
    ET_Blob:   begin
                 if elem.bVal <> NIL then
                   begin
                    l := AnsiStrings.StrLen(elem.bVal);
                    Result.elem.bVal := AllocMem((l+1));
                    CopyMemory(Result.elem.bVal, elem.bVal, l);
                   end
                  else
                   Result.elem.bVal := NIL;
               end;
    ET_Blob64:   begin
                 if elem.rVal <> NIL then
                   begin
                    l := ansistrings.StrLen(elem.rVal);
                    Result.elem.rVal := AllocMem((l+1));
                    CopyMemory(Result.elem.rVal, elem.rVal, l);
                   end
                  else
                   Result.elem.rVal := NIL;
               end
   else
     Result.elem.dVal := self.elem.dVal;
//    ET_Double: ;
//    ET_Date: ;
  end;
end;

destructor TPrefElement.Destroy;
begin
  Clear;
  inherited;
end;


destructor TPrefPage.Destroy;
begin
  SetLength(Self.Name, 0);
  SetLength(Self.Caption, 0);
end;

function TPrefPage.Clone : TPrefPage;
begin
  Result := TPrefPage.Create;
  Result.idx := Self.idx;
  Result.frame := Self.frame;
  Result.frameClass := Self.frameClass;
  Result.Name := Self.Name;
  Result.Caption := Self.Caption;
  Result.GroupName := Self.GroupName;
end;

procedure ClearPrefElement(vt : TElemType; var val : TPrefElem);
begin
  case vt of
    ET_String: begin
                 if val.sVal <> NIL then
//                   StrDispose(elem.sVal);
                  FreeMemory(val.sVal);
//                 elem.sVal := NIL;
               end;
//    ET_Integer: ;
    ET_Blob:   begin
                 if val.bVal <> NIL then
//                   StrDispose(elem.bVal);
                  FreeMemory(val.bVal);
//                 elem.bVal := NIL;
               end;
    ET_Blob64:   begin
                 if val.rVal <> NIL then
//                   StrDispose(elem.bVal);
                  FreeMemory(val.rVal);
//                 elem.bVal := NIL;
               end
   else
     val.dVal := 0;
//    ET_Double: ;
//    ET_Date: ;
  end;
  val.dVal := 0;
end;

procedure CopyPrefElement(vt0 : TElemType; val0 : TPrefElem;
                          vt : TElemType; var val : TPrefElem);
var
  l : Integer;
  strA : RawByteString;
  s : String;
begin
  case vt of
    ET_String:
            if vt0 = ET_String then
               begin
                 if val0.sVal <> NIL then
                   begin
                    l := StrLen(val0.sVal);
                    val.sVal := AllocMem((l+1) * SizeOf(Char));
                    CopyMemory(val.sVal, val0.sVal, l*SizeOf(Char));
                   end
                  else
                   val.sVal := NIL;
               end
             else
            if vt0 = ET_Blob then
               begin
                 s := UnUTF(ansistrings.StrPas(val0.bVal));
                 l := Length(s);
                 val.sVal := AllocMem((l+1) * SizeOf(Char));
                 CopyMemory(val.sVal, Pointer(s), l*SizeOf(Char));
  { TODO : Add all variants!!!! }
               end;
//    ET_Integer: ;
    ET_Blob:
       begin
        case vt0 of
          ET_String: begin
                       if val0.sVal <> NIL then
                         strA := StrToUTF8(StrPas(val0.sVal))
                        else
                         strA := '';
                     end;
          ET_Integer:begin
                       strA := IntToStrA(val0.iVal);
                     end;
          ET_Blob:   begin
                       if val0.bVal <> NIL then
                         begin
                          strA := ansistrings.StrPas(val0.bVal)
//                          l := StrLen(val0.bVal);
//                          val.bVal := AllocMem((l+1));
//                          CopyMemory(val.bVal, val0.bVal, l);
                         end
                        else
                         strA := '';
                     end;
          ET_Double: Str(val0.dVal : 0:4, strA);// :=  FloatToStr(elem.dVal);
          ET_Date: strA := AnsiString(FormatDateTime(Def_DateFormat, val0.tVal));
          ET_Bool: strA := yesno[val0.yVal];
          ET_Time: strA := AnsiString(FormatDateTime(Def_DateTimeFormat, val0.tVal));
        end;
        if strA > '' then
          begin
            l := ansistrings.StrLen(val0.bVal);
            val.bVal := AllocMem((l+1));
            CopyMemory(val.bVal, val0.bVal, l);
          end
         else
          val.sVal := NIL;
       end;
    ET_Bool:
       begin
         if vt0 = ET_Blob then
           Val.yVal := yesnof(val0.bVal)
          else
         if vt0 = ET_Bool then
           Val.yVal := val0.yVal
       end
   else
     val.dVal := val0.dVal;
//    ET_Double: ;
//    ET_Date: ;
  end;
end;


procedure TPortList.AddPorts(pLPort : Integer; pRPort : Integer = 0);
var
  pe : TPortElement;
begin
  pe := TPortElement.Create;
  pe.Count := 1;
  pe.lPort := 0;
  pe.rPort := 0;
  if (pLPort > 0) and (pRPort > 0) then
    begin
      pe.Count := pRPort - pLPort + 1;
      pe.lPort := pLPort;
      pe.rPort := pRPort;
    end
   else
    if (pLPort > 0) then
      pe.lPort := pLPort
     else
      if (pRPort > 0) then
        pe.lPort := pRPort
       else
        pe.Count := 0;

  Inc(PortsCount, pe.Count);
  if pe.Count = 0 then
    pe.Free
   else
    begin
      AddObject(Format('%5.5d', [pe.lPort]), pe);
    end;
end;

function TPortList.getRandomPort: Integer;
var
  r, i, a, p : Integer;
begin
  p := 0;
  if PortsCount > 0 then
   begin
     r := Random(PortsCount);
     for I := 0 to Count do
       begin
         a := TPortElement(Objects[i]).Count;
         if a > r then
           begin
             p := TPortElement(Objects[i]).lPort + r;
             Break;
           end
          else
           dec(r, a);
       end;
   end;
  Result := p;
end;

function TPortList.getString: String;
var
  I: Integer;
  pe : TPortElement;
  res : String;
  s : String;
begin
  res := '';
  for I := 1 to Self.Count do
   begin
    pe := TPortElement(self.Objects[i-1]);
    s := IntToStr( pe.lPort );
    if pe.rPort > 0 then
      s := s + '-' + IntToStr( pe.rPort );
    if i > 1 then
      res := res + ', ' + s
     else
      res := res + s;
   end;
  Result := res;

end;

procedure TPortList.parseString(const s : String);
type
  TLastState = (LS_numberL, LS_numberR, LS_delimiter, LS_hyphen, LS_end);
var
  st, ost : tlastState;
  I: Integer;
  ch : Char;
  lastNum : String;
  lastPort, rPort : Integer;
begin
  Clear;
  PortsCount := 0;
  st := LS_numberL;
  ost := LS_delimiter;
  lastNum := '';
  lastPort := 0;
  for I := 1 to Length(s)+1 do
    begin
      if I <= Length(s) then
        begin
          ch := s[i];
          if IsDigit(ch) then
              st := LS_numberL
           else
            if ch = '-' then
              st := LS_hyphen
             else
              st := LS_delimiter;
        end
       else
        begin
          ch := #0;
          st := LS_end;
        end;
      case st of
        LS_numberL:
            case ost of
              LS_numberL: lastNum := lastNum + ch;
              LS_numberR:
                  begin
                    lastNum := lastNum + ch;
                    st := LS_numberR;
                  end;
              LS_delimiter:
                  begin
                    if lastPort >0 then
                      AddPorts(lastPort);
                    lastPort := 0;
                    lastNum := ch;
                  end;
              LS_hyphen:
                  begin
                    lastNum := lastNum + ch;
                    st := LS_numberR;
                  end;
            end;
        LS_numberR:
             // Can't be here
             ;
        LS_delimiter:
            case ost of
              LS_numberL:
                begin
                  lastPort :=  StrToIntDef(lastNum, 0);
                  lastNum := '';
                end;
              LS_numberR:
                begin
                  rPort := StrToIntDef(lastNum, 0);
                  lastNum := '';
                  if rPort > 0 then
                    AddPorts(lastPort, rPort)
                   else
                    AddPorts(lastPort);
                  st := LS_numberL;
                end;
              LS_delimiter: ;
              LS_hyphen: st := LS_hyphen;
            end;
        LS_hyphen:
            case ost of
              LS_numberL:
                begin
                  lastPort := StrToIntDef(lastNum, 0);
                  lastNum := '';
                  if lastPort > 0 then
                    st := LS_numberR
                   else
                    st := LS_numberL;
                end;
              LS_numberR:
                begin
                  rPort := StrToIntDef(lastNum, 0);
                  lastNum := '';
                  if rPort > 0 then
                    begin
                      AddPorts(lastPort, rPort);
                      st := LS_numberL;
                    end
                   else
                    //Add(IntToStr(lastPort))
                     ;
                end;
              LS_delimiter:
                begin
                  if lastPort > 0 then
                    st := LS_numberR
                   else
                    st := LS_numberL;
                end;
              LS_hyphen: ;
            end;
        LS_end:
            case ost of
              LS_numberL:
                begin
                  lastPort := StrToIntDef(lastNum, 0);
                  lastNum := '';
                  if lastPort > 0 then
                    AddPorts(lastPort);
                end;
              LS_numberR:
                begin
                  rPort := StrToIntDef(lastNum, 0);
                  lastNum := '';
                  if rPort > 0 then
                    AddPorts(lastPort, rPort)
                   else
                    AddPorts(lastPort);
                end;
              LS_delimiter, LS_hyphen:
                begin
                  if lastPort > 0 then
                    AddPorts(lastPort);
                end;
            end;
      end;
      ost := st;
    end;
  Sort;
end;


end.
