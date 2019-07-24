unit RnQJSON;

interface
uses
   JSON;

type
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
  SysUtils, System.Generics.Collections,
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

  ValVal := TJSONObject(Self).GetValue(Key);
  if not Assigned(ValVal) then
    Exit;

  if TypeInfo(T) = TypeInfo(String) then
  begin
    // Decode UTF8
    Result := ValVal.TryGetValue(sTmp);
//    PString(@Data)^ := UnUTF(sTmp);
    PString(@Data)^ := sTmp;
  end else if TypeInfo(T) = TypeInfo(RawByteString) then
  begin
    // Keep UTF8
    Result := ValVal.TryGetValue(rTmp);
    PRawByteString(@Data)^ := rTmp;
  end else if TypeInfo(T) = TypeInfo(Integer) then
  begin
    Result := ValVal.TryGetValue(iTmp);
    PInteger(@Data)^ := iTmp;
  end else if TypeInfo(T) = TypeInfo(Cardinal) then
  begin
    Result := ValVal.TryGetValue(cTmp);
    PCardinal(@Data)^ := cTmp;
  end else if TypeInfo(T) = TypeInfo(UInt64) then
  begin
    Result := ValVal.TryGetValue(uTmp);
    PUInt64(@Data)^ := uTmp;
  end else if TypeInfo(T) = TypeInfo(Int64) then
  begin
    Result := ValVal.TryGetValue(Tmp64);
    PInt64(@Data)^ := Tmp64;
  end else if TypeInfo(T) = TypeInfo(Boolean) then
  begin
    Result := ValVal.TryGetValue(bTmp);
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
  TmpJSON := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes(RespStr), 0);
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
  TmpJSON := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes(RespStr), 0);
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
{$IF RTLVersion >= 33}
  TmpJSON := TJSONObject.ParseJSONValue(RespStrR, True, true);
 {$ELSE}
  TmpJSON := TJSONObject.ParseJSONValue(RespStrR, True);
{$IFEND}
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
{$IF RTLVersion >= 33}
  TmpJSON := TJSONObject.ParseJSONValue(RespStrR, True, true);
 {$ELSE}
  TmpJSON := TJSONObject.ParseJSONValue(RespStrR, True);
{$IFEND}
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

function PrettyPrintJSON(Value: TJSONValue; Indent: Integer = 0): String;
var
  i: Integer;
begin
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
end;


function formatJSON(JSON: TJSONValue): String;
begin
  Result := '';
  if Assigned(json) then
{$IF RTLVersion >= 33}
    begin
      Result := Trim(json.Format);
    end
 {$ELSE}
   Result := Trim(PrettyPrintJSON(json));
{$IFEND}
end;

end.