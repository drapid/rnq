unit MRAcontacts;

{$I Compilers.inc}
{$I RnQConfig.inc}

interface

uses
  classes, sysutils,
    RnQGraphics32,
   types, RQThemes, RnQProtocol;

type
  TMRAstatus= (SC_ONLINE = 0, SC_OFFLINE, SC_UNK,
               mSC_AWAY=3);
//  Tmras = Tstatus + TMRAstatus;
const
  StatusPriority : array[TMRAStatus] of byte= (0,8,9, 1);
//  statMenu : array[0..6] of TMRAStatus = (mSC_ONLINE, mSC_F4C, mSC_OCCUPIED, mSC_DND,
//           mSC_AWAY, mSC_NA, mSC_OFFLINE);
const
//  IS_AVATAR = 0;
  IS_PHOTO  = 1;
  IS_NONE   = 2;

type
  TMRAContact = class(TRnQContact)
    invisible:boolean;
    status, prevStatus: TMRAStatus;
    gender : Byte;
    xStatus : record
         id : AnsiString;
         Name, Desc : String;
       end;
    ClientID : String;
//    ssPhones : AnsiString;
    ssCells : AnsiString;
    City_id : Integer;
//    Location : String;
    Country_id : Integer;
    Location_id : Integer;
    zodiac : byte;
    hisPhones : AnsiString;
//    Authorized : Boolean;
//    onlineSince :
    infoUpdatedTo : TDateTime;
   public
    constructor Create(const uin_: TUID); override;
    destructor Destroy; override;
//     class operator Implicit(const a: AnsiString) : TContact; inline;// Implicit conversion of an Integer to type TMyClass
    procedure clear; override;
    procedure setOffline;
    procedure OfflineClear;
    function  isOnline : Boolean; override;
    function  isInvisible : Boolean; override;
    function  isOffline : Boolean; override;
    function  canEdit : Boolean; override;
    function  getStatusName : String; OverLoad; OverRide;
    function  statusImg : AnsiString; OverRide;
    function  getStatus : byte; OverRide;
    procedure SetDisplay(const s : String); OverRide;
    function  uin2Show:string; OverRide;
    procedure ViewInfo; OverRide;
    procedure GetDomUser(var d, u : AnsiString);
    class function trimUID(const uid : TUID) : TUID; OverRide;
   end; // Tcontact

IMPLEMENTATION
  uses
    RnQLangs, globalLib, mainDlg, utilLib, RQUtil, StrUtils,
    RQGlobal,
    mra_Proto, viewMRAinfoDlg, Protocol_MRA, MRAv1;

constructor TMRAContact.create(const uin_: TUID);
begin
  inherited create(uin_);
  iProto := mainProto;
  clear;
//  uid:=uin_;
  if assigned(onContactCreation) then onContactCreation(self);
end; // create

destructor TMRAContact.Destroy;
begin
// if assigned(onContactDestroying) then onContactDestroying(self);
// onContactDestroying := NIL;
 clear;
 inherited Destroy;
end;

function TMRAContact.getStatusName: String;
begin
  if (XStatusAsMain and (status = SC_ONLINE)) and (xStatus.id > '') then
    begin
      if xStatus.Name > '' then
//        result := getTranslation(Xsts)
        result := xStatus.Name
       else
        if xStatus.Desc > '' then
  //        result := getTranslation(Xsts)
          result := xStatus.Desc
         else
//          result := getTranslation(XStatusArray[extSts].Caption)
            result := getTranslation(MRAstatus2ShowStr[status])
    end
   else
    result := getTranslation(MRAstatus2ShowStr[status])
end;

function TMRAContact.isInvisible: Boolean;
begin
  Result := false;
end;

function TMRAContact.isOffline: Boolean;
begin
  result := status = SC_OFFLINE;
end;

function TMRAContact.isOnline: Boolean;
begin
  result := not (status in [SC_OFFLINE, SC_UNK])
end;

procedure TMRAContact.OfflineClear;
begin
  invisible := False;
  typing.bIsTyping := False;
  typing.bIAmTyping := False;
//  crypt.supportCryptMsg := False;
  xStatus.id := '';
  xStatus.Name := '';
  xStatus.Desc := '';
//  ICQVer := '';
end;

procedure TMRAContact.SetDisplay(const s: String);
begin
  inherited;
  TMRASession(iProto.ProtoElem).SSI_UpdateContact(self);
end;

procedure TMRAContact.setOffline;
begin
  status := SC_OFFLINE;
  OfflineClear;
end;

function TMRAContact.statusImg: AnsiString;
begin
  Result := '';
  if xStatus.id > '' then
   begin
    Result := 'mra.'+xStatus.id;
    with theme.GetPicSize(RQteDefault, Result) do
     if (cx = 0)or(cy = 0) then
      result := '';
   end;
  if Result = '' then
   Result := MRAstatus2ImgName(status, invisible);
end;

function TMRAContact.getStatus : byte;
begin
  result := byte(status);
end;

function TMRAContact.uin2Show: string;
begin
  Result := UID;
end;

class function TMRAContact.trimUID(const uid : TUID) : TUID;
var
  i : word;
begin
  result := '';
//  i := 1;
//  while i <= Length(uid) do
  for I := 1 to length(uid) do
   begin
    if not (uid[i] in BreakChars) then
     Result := Result + uid[i];
//    inc(i);
   end;
end;

procedure TMRAContact.GetDomUser(var d, u : AnsiString);
var
// u, d : AnsiString;
 i, k : Integer;
begin
  d := UID2cmp;
  u := chop('@', d);
  i := 1;
  repeat
    k := i;
    i := PosEx('.', d, i+1);
  until (i <= 0);
  d := chop(k, d);
end;
// destroy

function TMRAContact.canEdit: Boolean;
begin
  Result := True;
end;

procedure TMRAContact.clear;
//var
//  i : Byte;
begin
//uid:='';
//nick:='';
//first:='';
//last:='';
  status := SC_UNK;
  prevStatus := SC_UNK;
  icon.ToShow := IS_PHOTO;
  icon.Path := '';
  FreeAndNil(icon.Bmp);
  FreeAndNil(icon.cash);
  ClientID := '';
  ssCells  := ''; 

  OfflineClear;
end;

procedure TMRAcontact.ViewInfo;
var
  vi:TRnQviewInfoForm;
begin
// if c is TICQcontact then  // ICQ
  begin
   vi:=findViewInfo(self);
   if vi = NIL then
    try
//     vi :=
     TviewMRAinfoFrm.doAll(RnQmain, self)
    except
    end
   else
    vi.bringToFront;
  end;
end;


end.
