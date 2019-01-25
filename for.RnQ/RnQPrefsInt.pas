{
  This file is part of R&Q.
  Under same license
}
unit RnQPrefsInt;
{$I ForRnQConfig.inc}
{$I NoRTTI.inc}

interface
 uses
   Windows, Forms, Classes,// iniFiles,
   RDGlobal;

type
  IRnQPref = interface
     function  getPrefStr(const key: String; var Val: String): Boolean;
     function  getPrefStrList(const key: String; var Val: TStringList): Boolean;
     function  getPrefBool(const key: String; var Val: Boolean): Boolean;
     procedure getPrefBlob(const key: String; var Val: RawByteString);
     procedure getPrefBlob64(const key: String; var Val: RawByteString);
     function  getPrefInt(const key: String; var Val: Integer): Boolean;
     procedure getPrefDate(const key: String; var Val: TDateTime);
     procedure getPrefDateTime(const key: String; var Val: TDateTime);
//     procedure getPrefValue(const key: String; et: TElemType; var Val: TPrefElem);
     function getPrefGuid(const key: String; var Val: TGUID): Boolean;
     function getPrefBoolDef(const key: String; const DefVal: Boolean): Boolean;
     function getPrefBlobDef(const key: String; const DefVal: RawByteString = ''): RawByteString;
     function getPrefBlob64Def(const key: String; const DefVal: RawByteString = ''): RawByteString;
     function getPrefStrDef(const key: String; const DefVal: String = ''): String;
     function getPrefIntDef(const key: String; const DefVal: Integer = -1): Integer;
//     function getPrefVal(const key: String): TPrefElement;

     procedure DeletePref(const key: String);
     function prefExists(const key: String): Boolean;

     procedure addPrefBlobOld(const key: String; const Val: RawByteString);
     procedure addPrefBlob64(const key: String; const Val: RawByteString);
     procedure addPrefInt(const key: String; const Val: Integer);
     procedure addPrefBool(const key: String; const Val: Boolean);
     procedure addPrefStr(const key: String; const Val: String);
     procedure addPrefStrList(const key: String; const Val: TStringList);
     procedure addPrefTime(const key: String; const Val: TDateTime);
 {$IFDEF DELPHI9_UP}
     procedure addPrefDate(const key: String; const Val: TDate);
 {$ENDIF DELPHI9_UP}
     procedure addPrefGuid(const key: String; const Val: TGUID);
     procedure addPrefParam(param: TObject);
 {$IFDEF RNQ}
     procedure addPrefArrParam(param: array of TObject);
     procedure getPrefArrParam(param: array of TObject);
 {$ENDIF RNQ}
     procedure initPrefBool(const key: String; const Val: Boolean);
     procedure initPrefInt(const key: String; const Val: Integer);
     procedure initPrefStr(const key: String; const Val: String);

     procedure BeginUpdate;
     procedure EndUpdate;

//     property  isUpdating: Boolean;
  end;


implementation


end.
