{
This file is part of R&Q.
Under same license
}
unit NotRnQUtils;
{$I ForRnQConfig.inc}
{$I NoRTTI.inc}

interface
//uses
//  iniFiles,

 {$IFNDEF RNQ}
  function getTranslation(const key: AnsiString; const args: array of const): String; overload;
  function getTranslation(const key: AnsiString): String;  overload;

 {$IFDEF UNICODE}
  function getTranslation(const key: UnicodeString; const args: array of const): string; overload;
  function getTranslation(const key: UnicodeString): string; overload;
 {$ENDIF UNICODE}

 {$ENDIF RNQ}

implementation

uses
   SysUtils, StrUtils, Masks;

//////////////////////////////////////////////////////////////////////////
 {$IFNDEF RNQ}
function getTranslation(const key: AnsiString): string;
begin
  result := key;
  result := ansiReplaceStr(result, '\n', #13);
end; // getTranslation

function getTranslation(const key: Ansistring; const args: array of const): String;
//var
//  s : extended;
begin
  Result := key;

  if Length(args) > 0 then
   try
    result:=format(result, args);
   except

   end;
  result:=ansiReplaceStr(result, '\n', #13);
//result:=ansiReplaceStr(result, '\s', ' ');
end; // getTranslation

 {$IFDEF UNICODE}
function getTranslation(const key: String): string;
begin
  Result := key;
  result:=ansiReplaceStr(result,'\n', #13);
end; // getTranslation

function getTranslation(const key: string; const args: array of const):string;
//var
//  s : extended;
begin
  Result := key;
  if Length(args) > 0 then
   try
    result:=format(result, args);
   except

   end;
  result:=ansiReplaceStr(result,'\n',#13);
//result:=ansiReplaceStr(result,'\s',' ');
end; // getTranslation
 {$ENDIF UNICODE}

 {$ENDIF RNQ}


end.
