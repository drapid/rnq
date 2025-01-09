unit RnQJSON;

interface

uses
  {$IFDEF FPC}
   fpJSON;
  {$ELSE ~FPC}
   JSON;
  {$ENDIF FPC}

type
  {$IFDEF FPC}
  TJSONValue = TJSONData;
  {$ENDIF FPC}

  TJSONHelper = class helper for TJSONValue
  public
    function GetValueSafe<T>(const Key: String; out Data: T): Boolean;
  end;

  function ParseJSON(const RespStr: String; out JSON: TJSONObject): Boolean; overload;
  function ParseJSON(const RespStr: String; out JSON: TJSONArray): Boolean; overload;
  function ParseJSON(const RespStrR: UTF8String; out JSON: TJSONObject): Boolean; overload;
  function ParseJSON(const RespStrR: UTF8String; out JSON: TJSONArray): Boolean; overload;

  function formatJSON(JSON: TJSONValue): String;

implementation
uses
  SysUtils, //System.Generics.Collections,
  RDGlobal, RDUtils;


function TJSONHelper.GetValueSafe<T>(const Key: String; out Data: T): Boolean;
var
  ValVal: TJSONValue;
  sTmp: String;
  rTmp: RawByteString;
  iTmp: Integer;
  cTmp: Cardinal;
  uTmp: UInt64;
  Tmp64: Int64;
  bTmp: Boolean;
begin
  Result := False;

  if not (Self is TJSONObject) then
    Exit;

 {$IFDEF FPC}
  ValVal := TJSONObject(Self).Elements[Key];
 {$ELSE ~FPC}
  ValVal := TJSONObject(Self).GetValue(Key);
 {$ENDIF FPC}
  if not Assigned(ValVal) then
    Exit;

  if TypeInfo(T) = TypeInfo(String) then
  begin
    // Decode UTF8
    sTmp := '';
   {$IFDEF FPC}
    sTmp := ValVal.AsUnicodeString;
    Result := True;
   {$ELSE ~FPC}
    Result := ValVal.TryGetValue(sTmp);
   {$ENDIF ~FPC}
//    PString(@Data)^ := UnUTF(sTmp);
    PString(@Data)^ := sTmp;
  end else if TypeInfo(T) = TypeInfo(RawByteString) then
  begin
    // Keep UTF8
    rTmp := '';
   {$IFDEF FPC}
    rTmp := ValVal.AsString;
    Result := True;
   {$ELSE ~FPC}
    Result := ValVal.TryGetValue(rTmp);
   {$ENDIF ~FPC}
    PRawByteString(@Data)^ := rTmp;
  end else if TypeInfo(T) = TypeInfo(Integer) then
  begin
    iTmp := 0;
   {$IFDEF FPC}
    iTmp := ValVal.AsInteger;
    Result := True;
   {$ELSE ~FPC}
    Result := ValVal.TryGetValue(iTmp);
   {$ENDIF ~FPC}
    PInteger(@Data)^ := iTmp;
  end else if TypeInfo(T) = TypeInfo(Cardinal) then
  begin
    cTmp := 0;
   {$IFDEF FPC}
    cTmp := ValVal.AsLargeInt;
    Result := True;
   {$ELSE ~FPC}
    Result := ValVal.TryGetValue(cTmp);
   {$ENDIF ~FPC}
    PCardinal(@Data)^ := cTmp;
  end else if TypeInfo(T) = TypeInfo(UInt64) then
  begin
    uTmp := 0;
   {$IFDEF FPC}
    uTmp := ValVal.AsQWord;
    Result := True;
   {$ELSE ~FPC}
    Result := ValVal.TryGetValue(uTmp);
   {$ENDIF ~FPC}
    PUInt64(@Data)^ := uTmp;
  end else if TypeInfo(T) = TypeInfo(Int64) then
  begin
    Tmp64 := 0;
   {$IFDEF FPC}
    Tmp64 := ValVal.AsInt64;
    Result := True;
   {$ELSE ~FPC}
    Result := ValVal.TryGetValue(Tmp64);
   {$ENDIF ~FPC}
    PInt64(@Data)^ := Tmp64;
  end else if TypeInfo(T) = TypeInfo(Boolean) then
  begin
    bTmp := false;
   {$IFDEF FPC}
    bTmp := ValVal.AsBoolean;
    Result := True;
   {$ELSE ~FPC}
    Result := ValVal.TryGetValue(bTmp);
   {$ENDIF ~FPC}
    PBoolean(@Data)^ := bTmp;
  end
//  else raise Exception.Create('Unknown data type: ' + DataType.ToString);
end;

function ParseJSON(const RespStr: String; out JSON: TJSONObject): Boolean;
var
  TmpJSON: TJSONValue;
begin
  Result := False;
  JSON := nil;
 {$IFDEF FPC}
  TmpJSON := GetJSON(RespStr, True);
 {$ELSE ~FPC}
  TmpJSON := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes(RespStr), 0);
 {$ENDIF sFPC}
  if not Assigned(TmpJSON) then
    Exit;
  if TmpJSON is TJSONObject then
  begin
    JSON := TmpJSON as TJSONObject;
    Result := True;
  end else
    FreeAndNil(TmpJSON);
end;

function ParseJSON(const RespStr: String; out JSON: TJSONArray): Boolean;
var
  TmpJSON: TJSONValue;
begin
  Result := False;
  JSON := nil;
 {$IFDEF FPC}
  TmpJSON := GetJSON(RespStr, True);
 {$ELSE ~FPC}
  TmpJSON := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes(RespStr), 0);
 {$ENDIF FPC}
  if not Assigned(TmpJSON) then
    Exit;
  if TmpJSON is TJSONArray then
  begin
    JSON := TmpJSON as TJSONArray;
    Result := True;
  end else
    FreeAndNil(TmpJSON);
end;

function ParseJSON(const RespStrR: UTF8String; out JSON: TJSONObject): Boolean;
var
  TmpJSON: TJSONValue;
begin
  Result := False;
  JSON := nil;
{$IFDEF FPC}
  try
    TmpJSON := GetJSON(RespStrR, True);
   except
    TmpJSON := NIL;
  end;
{$ELSE ~FPC}
{$IF RTLVersion >= 33}
  TmpJSON := TJSONObject.ParseJSONValue(RespStrR, True, true);
 {$ELSE}
  TmpJSON := TJSONObject.ParseJSONValue(RespStrR, True);
{$IFEND}
{$ENDIF FPC}
  if not Assigned(TmpJSON) then
    Exit;
  if TmpJSON is TJSONObject then
  begin
    JSON := TmpJSON as TJSONObject;
    Result := True;
  end else
    FreeAndNil(TmpJSON);
end;

function ParseJSON(const RespStrR: UTF8String; out JSON: TJSONArray): Boolean;
var
  TmpJSON: TJSONValue;
begin
  Result := False;
  JSON := nil;
{$IFDEF FPC}
  TmpJSON := GetJSON(RespStrR, True);
{$ELSE ~FPC}
{$IF RTLVersion >= 33}
  TmpJSON := TJSONObject.ParseJSONValue(RespStrR, True, true);
 {$ELSE}
  TmpJSON := TJSONObject.ParseJSONValue(RespStrR, True);
{$IFEND}
{$ENDIF FPC}
  if not Assigned(TmpJSON) then
    Exit;
  if TmpJSON is TJSONArray then
  begin
    JSON := TmpJSON as TJSONArray;
    Result := True;
  end else
    FreeAndNil(TmpJSON);
end;

const INDENT_SIZE = 2;
{$IFNDEF FPC}
function PrettyPrintJSON(Value: TJSONValue; Indent: Integer = 0): String; forward;

function PrettyPrintPair(Value: TJSONPair; Last: Boolean; Indent: Integer): String;
const
  TEMPLATE = '%s : %s';
var
  Line: string;
  JSONText: String;
begin
  try
    JSONText := PrettyPrintJSON(Value.JsonValue, Indent);
    Line := Format(TEMPLATE, [Value.JsonString.ToString, Trim(JSONText)]);
  except end;

  Line := StringOfChar(' ', Indent * INDENT_SIZE) + Line;
  if not Last then
    Line := Line + ',';
  Result := Line;
end;

function PrettyPrintArrayValue(Value: TJSONValue; Last: Boolean; Indent: Integer): String;
const
  TEMPLATE = '%s';
var
  Line: string;
  JSONText: String;
begin
  try
    JSONText := PrettyPrintJSON(Value, Indent);
    Line := Format(TEMPLATE, [Trim(JSONText)]);
  except end;

  Line := StringOfChar(' ', Indent * INDENT_SIZE) + Line;
  if not Last then
    Line := Line + ',';
  Result := Line;
end;
{$ENDIF ~FPC}

function PrettyPrintJSON(Value: TJSONValue; Indent: Integer = 0): String;
var
  i: Integer;
begin
 {$IFDEF FPC}
  Result := Value.FormatJSON([], INDENT_SIZE);
 {$ELSE ~FPC}
  if Value is TJSONObject then
  begin
    Result := Result + CRLF + StringOfChar(' ', Indent * INDENT_SIZE) + '{';
    for i := 0 to TJSONObject(Value).Count - 1 do
      Result := Result + CRLF + PrettyPrintPair(TJSONObject(Value).Pairs[i], i = TJSONObject(Value).Count - 1, Indent + 1);
    Result := Result + CRLF + StringOfChar(' ', Indent * INDENT_SIZE) + '}';
  end
  else if Value is TJSONArray then
  begin
    Result := Result + CRLF + StringOfChar(' ', Indent * INDENT_SIZE) + '[';
    for i := 0 to TJSONArray(Value).Count - 1 do
      Result := Result + CRLF + PrettyPrintArrayValue(TJSONArray(Value).Items[i], i = TJSONArray(Value).Count - 1, Indent + 1);
    Result := Result + CRLF + StringOfChar(' ', Indent * INDENT_SIZE) + ']';
  end else
    Result := Result + CRLF + StringOfChar(' ', Indent * INDENT_SIZE) + Value.ToString;
 {$ENDIF FPC}
end;


function formatJSON(JSON: TJSONValue): String;
begin
  Result := '';
  if Assigned(json) then
  {$IFDEF FPC}
    Result := JSON.FormatJSON([], INDENT_SIZE);
  {$ELSE ~FPC}
{$IF RTLVersion >= 33}
    begin
      Result := Trim(json.Format);
    end
 {$ELSE}
   Result := Trim(PrettyPrintJSON(json));
{$IFEND}
  {$ENDIF FPC}
end;

end.
