{
  This file is part of R&Q.
  Under same license
}
unit RnQPrefsInt;
{$I ForRnQConfig.inc}
{$I NoRTTI.inc}

interface
 uses
   Windows, Classes,
//   Forms,
   // iniFiles,
   RDGlobal;

type
  TPrefKey = String;
  IRnQPref = interface
     function  getDPrefStr(const key: TPrefKey): String;
     function  getDPrefStrList(const key: TPrefKey): TStringList;
     function  getDPrefBool(const key: TPrefKey): Boolean;
     function  getDPrefBlob(const key: TPrefKey): RawByteString;
     function  getDPrefBlob64(const key: TPrefKey): RawByteString;
     function  getDPrefInt(const key: TPrefKey): Integer;
     function  getDPrefDate(const key: TPrefKey): TDateTime;
     function  getDPrefDateTime(const key: TPrefKey): TDateTime;
     function  getDPrefGuid(const key: TPrefKey): TGUID;

     function  getPrefStr(const key: TPrefKey; var Val: String): Boolean;
     function  getPrefStrList(const key: TPrefKey; var Val: TStringList): Boolean;
     function  getPrefBool(const key: TPrefKey; var Val: Boolean): Boolean;
     function  getPrefBlob(const key: TPrefKey; var Val: RawByteString): Boolean;
     function  getPrefBlob64(const key: String; var Val: RawByteString): Boolean;
     function  getPrefInt(const key: TPrefKey; var Val: Integer): Boolean;
     function  getPrefDate(const key: String; var Val: TDateTime): Boolean;
     function  getPrefDateTime(const key: String; var Val: TDateTime): Boolean;
//     procedure getPrefValue(const key: TPrefKey; et: TElemType; var Val: TPrefElem);
     function  getPrefGuid(const key: TPrefKey; var Val: TGUID): Boolean;
     function  getPrefBoolDef(const key: TPrefKey; const DefVal: Boolean): Boolean;
     function  getPrefBlobDef(const key: TPrefKey; const DefVal: RawByteString = ''): RawByteString;
     function  getPrefBlob64Def(const key: TPrefKey; const DefVal: RawByteString = ''): RawByteString;
     function  getPrefStrDef(const key: TPrefKey; const DefVal: String = ''): String;
     function  getPrefIntDef(const key: TPrefKey; const DefVal: Integer = -1): Integer;
//     function getPrefVal(const key: TPrefKey): TPrefElement;

     procedure DeletePref(const key: TPrefKey);
     function  prefExists(const key: TPrefKey): Boolean;

     procedure addPrefBlobOld(const key: TPrefKey; const Val: RawByteString);
     procedure addPrefBlob64(const key: TPrefKey; const Val: RawByteString);
     procedure addPrefInt(const key: TPrefKey; const Val: Integer);
     procedure addPrefBool(const key: TPrefKey; const Val: Boolean);
     procedure addPrefStr(const key: TPrefKey; const Val: String);
     procedure addPrefStrList(const key: TPrefKey; const Val: TStringList);
     procedure addPrefTime(const key: TPrefKey; const Val: TDateTime);
 {$IFDEF DELPHI9_UP}
     procedure addPrefDate(const key: TPrefKey; const Val: TDate);
 {$ENDIF DELPHI9_UP}
     procedure addPrefGuid(const key: TPrefKey; const Val: TGUID);
     procedure addPrefParam(param: TObject);
 {$IFDEF RNQ}
     procedure addPrefArrParam(param: array of TObject);
     procedure getPrefArrParam(param: array of TObject);
 {$ENDIF RNQ}
     procedure initPrefBool(const key: TPrefKey; const Val: Boolean);
     procedure initPrefInt(const key: TPrefKey; const Val: Integer);
     procedure initPrefStr(const key: TPrefKey; const Val: String);

     procedure BeginUpdate;
     procedure EndUpdate;

//     property  isUpdating: Boolean;
  end;


implementation


end.
