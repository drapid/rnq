{
This file is part of R&Q.
Under same license
}
unit Protocols_all;
{$I RnQConfig.inc}
{$I NoRTTI.inc}

interface
uses
  Classes, Forms,
  RnQProtocol, langLib,
 {$IFDEF PROTOCOL_ICQ}
  Protocol_icq, ICQcontacts,
 {$ENDIF PROTOCOL_ICQ}
  automsgDlg, globalLib,
  RnQPrefsLib, RnQPics,
  RDGlobal, outboxLib;


procedure Protos_Events(Sender:TRnQProtocol; event:Integer);
procedure Protos_ShowWP();
function  Protos_getXstsPic(cnt: TRnQContact; isSelf: Boolean = false): TPicName;
procedure Protos_GetOfflineMSGS(pr: TRnQProtocol);
procedure Protos_DelOfflineMSGS(pr: TRnQProtocol);
procedure Protos_OpenMailBox;
procedure Protos_SendSMS(Parent: TComponent; cnt: TRnQContact);
function  Protos_CanSMS(cnt: TRnQContact) : Boolean;
procedure Protos_auth(cnt: TRnQContact);
procedure Protos_AuthDenied(cnt: TRnQContact; const msg: string='');
procedure Protos_DelCntFromSrv(cnt: TRnQContact);

function  addToRoster(c: TRnQcontact; isLocal: Boolean = False): boolean; overload;
function Proto_StsID2Name(Proto: TRnQProtocol; s: Byte; xs: byte): String;
function  status2imgName(s: byte; inv: boolean=FALSE): TPicName; inline;
function  status2imgNameExt(s: byte; inv: boolean=FALSE; extSts: byte= 0): TPicName; inline;

function  setStatus(const proto: TRnQProtocol; st: byte; isAuto: Boolean = False): byte;
function  setStatusFull(const proto: TRnQProtocol; st: byte; xSt: byte; xStStr: TXStatStr; isAuto : Boolean = False): byte;
procedure setVisibility(const proto: TRnQProtocol; vi: byte);
procedure userSetStatus(const proto: TRnQProtocol; st: byte; isShowAMWin: Boolean = True);
procedure usersetVisibility(const proto: TRnQProtocol; vi: byte);

function  sendEmailTo(c: TRnQContact): boolean;
//function  str2db(cls : TRnQCntClass; const s: RawByteString; var ok: boolean):TRnQCList; overload;
//function  str2db(cls : TRnQCntClass; const s: RawByteString): TRnQCList; overload;
function  str2db(pProto: TRnQProtocol; const s: RawByteString; var ok: boolean; pCheckGroups : Boolean):TRnQCList; overload;
function  str2db(pProto: TRnQProtocol; const s: RawByteString): TRnQCList; overload;
//function  getClientFor(c:TRnQcontact; pInInfo : Boolean = False):string;
function  getProtosPref(): TPrefPagesArr;
function  getProtoClass(ProtoID: Byte): TRnQProtoClass;
function  Proto_Outbox_add(kind: Integer; dest: TRnQContact; flags: integer=0; const info:string=''):Toevent;overload;function  Proto_Outbox_add(kind: Integer; dest:TRnQContact; flags:integer; cl:TRnQCList):Toevent; overload;
procedure getTrayIconTip(var vPic: TPicName; var vTip: String);


var
  AntiSpamMsgs: array[0..6] of String =
   (
//   (
    ('Your message has been blocked for antispam reason.'),
    ('You entered invalid code. Try again.'),
    ('Confirmation accepted. Your message recieved. Thank you.'),
    ('You failed antispam verification. You have no attemts. Your UIN (%uin%) is ignored.'),
    ('Please, type digital CODE which you can see below (3 digits).'),
    ('You have attempts: %attempt%.'), //%code%
    ('Please, type answer on question which you can see below.')
{    )
   (
    ('Ваше сообщение заблокировано антиспам плагином.'),
    ('Вы ввели не правильный код. Попробуйте еще раз.'),
    ('Код принят. Ваше сообщение получено. Спасибо.'),
    ('Вы не прошли антиспам проверку. У вас не осталось попыток. Ваш UIN (%uin%) игнорируется.'),
    ('Пожалуйста, введите цифровой КОД который вы видите ниже (3 цифры). '),
    ('Осталось попыток: %attempt%.'#13#10'%code%')
   )}
   );


implementation
uses
  SysUtils, StrUtils,
 {$IFDEF UNICODE}
   AnsiStrings,
 {$ENDIF}

  RnQBinUtils, RQUtil, RnQDialogs, RnQLangs, RnQStrings,
  RDUtils, RnQSysUtils, RnQGlobal,
 {$IFDEF PROTOCOL_MRA}
  Protocol_MRA, MRAcontacts,
  MRASMSDlg, MRA_proto,
  MRAv1,
 {$ENDIF PROTOCOL_MRA}
 {$IFDEF PROTOCOL_XMP}
  Protocol_XMP, XMPPcontacts,
//  MRASMSDlg, MRA_proto,
  XMPPv1,
 {$ENDIF PROTOCOL_XMP}
 {$IFDEF PROTOCOL_BIM}
  Protocol_BIM, BIMcontacts,
//  MRASMSDlg,
  BIM_proto,
  BIMv1,
 {$ENDIF PROTOCOL_BIM}
 {$IFDEF PROTOCOL_ICQ}
  ICQv9,
  ICQConsts, RQ_ICQ,
 {$ENDIF PROTOCOL_ICQ}

  pluginutil, pluginLib, history,

//  globalLib,
  utilLib, themesLib, RQThemes, roasterlib,
  MainDlg, chatDlg, events, outboxDlg;

procedure Protos_Events(Sender:TRnQProtocol; event:Integer);
  {$IFDEF PROTOCOL_ICQ}
var
  icqSess : TicqSession;
  {$ENDIF PROTOCOL_ICQ}
begin
 {$IFNDEF ICQ_ONLY}
  case Sender.ProtoID of
    ICQProtoID: begin
 {$ENDIF ICQ_ONLY}
  {$IFDEF PROTOCOL_ICQ}
                 icqSess := TicqSession(Sender);
                {$IFDEF RNQ_AVATARS}
                 if icqSess.getProtoType = SESS_AVATARS then
                   avt_icqEvent(icqSess, TicqEvent(event))
                  else
                {$ENDIF RNQ_AVATARS}
                   ProcessICQEvents(icqSess, TicqEvent(event));
  {$ENDIF PROTOCOL_ICQ}
 {$IFNDEF ICQ_ONLY}
                end;
  {$IFDEF PROTOCOL_MRA}
    MRAProtoID: ProcessMRAEvents(TMRASession(Sender), TMRAEvent(event));
  {$ENDIF PROTOCOL_MRA}
  {$IFDEF PROTOCOL_XMP}
    XMPProtoID: ProcessXMPPEvents(TxmppSession(Sender), TxmppEvent(event));
  {$ENDIF PROTOCOL_XMP}
  {$IFDEF PROTOCOL_BIM}
    OBIMProtoID: ProcessBIMEvents(TBIMSession(Sender), TBIMEvent(event));
  {$ENDIF PROTOCOL_BIM}
  end;
 {$ENDIF ICQ_ONLY}
end;

procedure Protos_ShowWP();
begin
 {$IFNDEF ICQ_ONLY}
  if Account.AccProto.ProtoElem.ProtoID = ICQProtoID then
 {$ENDIF ICQ_ONLY}
     showForm(WF_WP)
 {$IFDEF PROTOCOL_MRA}
   else
  if Account.AccProto.ProtoElem.ProtoID = MRAProtoID then
     showForm(WF_WP_MRA)
 {$ENDIF PROTOCOL_MRA}
end;

function  Protos_getXstsPic(cnt : TRnQContact; isSelf : Boolean = false) : TPicName;
var
  pr : TRnQProtocol;
begin
  Result := '';
  if isSelf then
    begin
     if Assigned(Account.AccProto) then
     begin
      pr := Account.AccProto.ProtoElem;
 {$IFNDEF ICQ_ONLY}
      case pr.ProtoID of
        ICQProtoID:
 {$ENDIF ICQ_ONLY}
         begin
  {$IFDEF PROTOCOL_ICQ}
          if TICQSession(pr).curXStatus > 0 then
           begin
            Result := XStatusArray[TICQSession(pr).curXStatus].PicName;
           end
  {$ENDIF PROTOCOL_ICQ}
         end;
   {$IFDEF PROTOCOL_MRA}
        MRAProtoID:
         begin
          if TMRASession(pr).curXStatus.id > '' then
           begin
            Result := 'mra.'+TMRASession(pr).curXStatus.id;
           end
         end
   {$ENDIF PROTOCOL_MRA}
 {$IFNDEF ICQ_ONLY}
      end
 {$ENDIF ICQ_ONLY}
     end;
    end
   else
    begin
      if Assigned(cnt) then
   {$IFDEF PROTOCOL_ICQ}
       if cnt is TICQcontact then
         Result := XStatusArray[TICQcontact(cnt).xStatus].PicName
        else
   {$ENDIF PROTOCOL_ICQ}
   {$IFDEF PROTOCOL_MRA}
       if cnt is TMRAcontact then
         Result := 'mra.'+ TMRAcontact(cnt).xStatus.id;
   {$ENDIF PROTOCOL_MRA}
    end;
end;

procedure Protos_GetOfflineMSGS(pr : TRnQProtocol);
begin
  {$IFDEF PROTOCOL_ICQ}
 if pr is TicqSession then
   TicqSession(pr).sendReqOfflineMsgs
  {$ENDIF PROTOCOL_ICQ}
 {$IFDEF PROTOCOL_MRA}
  else
 if pr is TMRASession then
   TMRASession(pr).sendReqOfflineMsgs
 {$ENDIF PROTOCOL_MRA}
   ;
end;

procedure Protos_DelOfflineMSGS(pr : TRnQProtocol);
begin
 {$IFDEF PROTOCOL_ICQ}
 if pr is TicqSession then
   TicqSession(pr).sendDeleteOfflineMsgs
 {$ENDIF PROTOCOL_ICQ}
 {$IFDEF PROTOCOL_MRA}
  else
 if pr is TMRASession then
   TMRASession(pr).sendDeleteOfflineMsgs
 {$ENDIF PROTOCOL_MRA}
   ;
end;

procedure Protos_OpenMailBox;
begin
 {$IFDEF PROTOCOL_MRA}
  if Assigned(Account.AccProto) and (Account.AccProto.ProtoElem is TMRASession) then
   TMRASession(Account.AccProto.ProtoElem).RequestMPOP_SESSION;
 {$ENDIF PROTOCOL_MRA}
end;

procedure Protos_SendSMS(Parent : TComponent; cnt : TRnQContact);
begin
  if Assigned(cnt) then
   {$IFDEF PROTOCOL_MRA}
    if cnt.fProto.ProtoID = MRAProtoID then
     begin
      TMRAsmsFrm.doAll(Parent, cnt);
     end;
   {$ENDIF PROTOCOL_MRA}
end;

function  Protos_CanSMS(cnt : TRnQContact) : Boolean;
begin
  Result := Assigned(cnt) and
 {$IFDEF PROTOCOL_MRA}
    Assigned(cnt.fProto) and (cnt.fProto.ProtoID = MRAProtoID);
 {$ELSE nonPROTOCOL_MRA}
     false
 {$ENDIF PROTOCOL_MRA}
end;

procedure Protos_auth(cnt : TRnQContact);
var
  ev:THevent;
begin
//  c:=Tcontact(contactsDB.get(TICQContact, uin));
  plugins.castEv( PE_AUTH_SENT, cnt.uid);
//ICQ.sendAuth(uin);
  with cnt.fProto do
   begin
     AuthGrant(cnt);
 {$IFNDEF ICQ_ONLY}
     case ProtoID of
       ICQProtoID :
 {$ENDIF ICQ_ONLY}
             begin
 {$IFDEF PROTOCOL_ICQ}
               TicqSession(ProtoElem).SSIAuth_REPLY(cnt.uid, True);
 {$ENDIF PROTOCOL_ICQ}
             end;
 {$IFNDEF ICQ_ONLY}
//       XMPProtoID : TxmppSession(ProtoElem).AuthCancel(cnt);
     end;
 {$ENDIF ICQ_ONLY}
   end;
  ev:=Thevent.new(EK_auth, cnt.fProto.getMyInfo, now, ''{$IFDEF DB_ENABLED},''{$ENDIF DB_ENABLED}, 0);
  ev.fIsMyEvent := True;
  if logpref.writehistory and (BE_save in behaviour[ev.kind].trig) then
    writeHistorySafely(ev, cnt);
  chatFrm.addEvent_openchat(cnt, ev);
end; // sendICQauth

procedure Protos_AuthDenied(cnt : TRnQContact; const msg:string='');
var
//  c:TRnQcontact;
  ev:THevent;
begin
//  c:= contactsDB.get(TICQContact, uin);
  plugins.castEv( PE_AUTHDENIED_SENT, cnt.uid, msg);
//ICQ.sendAuthDenied(uin,msg);
  with cnt.fProto do
 {$IFNDEF ICQ_ONLY}
   case ProtoID of
     ICQProtoID :
 {$ENDIF ICQ_ONLY}
           begin
 {$IFDEF PROTOCOL_ICQ}
             TicqSession(ProtoElem).SSIAuth_REPLY(cnt.uid, False, msg);
 {$ENDIF PROTOCOL_ICQ}
           end;
 {$IFNDEF ICQ_ONLY}
   {$IFDEF PROTOCOL_XMP}
     XMPProtoID : TxmppSession(ProtoElem).AuthCancel(cnt);
   {$ENDIF PROTOCOL_XMP}
   end;
 {$ENDIF ICQ_ONLY}
  ev:=Thevent.new(EK_authDenied, cnt.fProto.getMyInfo, now{$IFDEF DB_ENABLED},''{$ENDIF DB_ENABLED}, msg, 0);
  ev.fIsMyEvent := True;
  if logpref.writehistory and (BE_save in behaviour[ev.kind].trig) then
    writeHistorySafely(ev, cnt);
  chatFrm.addEvent_openchat(cnt, ev);
end;

procedure Protos_DelCntFromSrv(cnt : TRnQContact);
begin
  with cnt.fProto do
 {$IFNDEF ICQ_ONLY}
   case ProtoID of
     ICQProtoID :
 {$ENDIF ICQ_ONLY}
           begin
 {$IFDEF PROTOCOL_ICQ}
             TICQSession(ProtoElem).SSIdeleteContact(clickedContact);
 {$ENDIF PROTOCOL_ICQ}
           end;
 {$IFNDEF ICQ_ONLY}
//     XMPProtoID : TxmppSession(ProtoElem).AuthCancel(cnt);
   end;
 {$ENDIF ICQ_ONLY}
end;

function Proto_StsID2Name(Proto: TRnQProtocol; s: Byte; xs: byte): String;
var
  arr : TStatusArray;
begin
  arr := Proto.statuses;
  if (s >= Low(arr)) and (s <= High(arr)) then
    Result := getTranslation(arr[s].Cptn)
   else
    Result := Str_unk;
end;

function  status2imgName(//pr : TRnQProtocol;
                         s: byte; inv: boolean=FALSE): TPicName;
 {$IFDEF ICQ_ONLY}
begin
  result := protocol_icq.status2imgName(s, inv);
 {$ELSE ~ICQ_ONLY}
var
  st : TStatusArray;
begin
  st := Account.AccProto.statuses;
 if s in [byte(LOW(st)).. byte(HIGH(st))] then
//   result := prefix + st[s].ImageName
   result := st[s].ImageName
//   result := sta 'status.' + status2str[s]
  else
   result := PIC_STATUS_UNK;

 if inv then
//  inc(result, PIC_INVISIBLE_STATUS_ONLINE-PIC_STATUS_ONLINE);
   result := INVIS_PREFIX + result;
 {$ENDIF ICQ_ONLY}
end;

//function  status2imgNameExt(pr : TRnQProtocol; s: byte; inv:boolean=FALSE; extSts : byte= 0):TPicName;
function  status2imgNameExt(s: byte; inv: boolean=FALSE; extSts: byte= 0):TPicName;
begin
{ if XStatusAsMain and (extSts > 0) and
//    Assigned(pr) and (extSts <= High(pr.xStsStringArray))
   (extSts <= High(XStatusArray))
 then
//   result := pr.xStsStringArray[extSts].PicName
   result := XStatusArray[extSts].PicName
  else
   Result := status2imgName(s, inv)
}
 {$IFDEF ICQ_ONLY}
  Result := protocol_icq.status2imgNameExt(s, inv, extSts);
 {$ELSE ~ICQ_ONLY}
   Result := status2imgName(s, inv)
 {$ENDIF ICQ_ONLY}
end;


function setStatus(const proto: TRnQProtocol; st: byte; isAuto: Boolean = False): byte;
begin
  if not isAuto then
    autoaway.triggered:=TR_none;
  result := byte(proto.getStatus);

 {$IFDEF PROTOCOL_ICQ}
  if proto is TicqSession then
    begin
      if not (st in [byte(SC_away), byte(SC_na)]) then
        imAwaySince:=0
      else
       if not (byte(lastStatus) in [byte(SC_away), byte(SC_na)]) then
        imAwaySince:=now;
    end
 {$ENDIF PROTOCOL_ICQ}
 {$IFDEF PROTOCOL_MRA}
  else if proto is TMRASession then
    begin
      if not (st = byte(mSC_away)) then
        imAwaySince:=0
      else
       if not (byte(lastStatus) = byte(mSC_away)) then
        imAwaySince:=now;
    end
 {$ENDIF PROTOCOL_MRA}
   ;
  lastStatus:=st;
  if proto.isOffline and (st<>byte(SC_OFFLINE)) then
    doConnect
   else
    proto.setStatus(st);
  if st= byte(SC_OFFLINE) then
   begin
    stayconnected:=FALSE;
    setProgBar(proto, 0);
    resolving:=FALSE;
   end;
end; // setStatus

function setStatusFull(const proto: TRnQProtocol; st: byte; xSt: byte; xStStr: TXStatStr; isAuto : Boolean = False): byte;
//var
//  xStsD : TXStatStr;
begin
  if not isAuto then
    autoaway.triggered:=TR_none;
  result := byte(proto.getStatus);

 {$IFDEF PROTOCOL_ICQ}
  if proto is TicqSession then
    begin
      if not (st in [byte(SC_away), byte(SC_na)]) then
        imAwaySince:=0
      else
       if not (byte(lastStatus) in [byte(SC_away), byte(SC_na)]) then
        imAwaySince:=now;
    end
  else
 {$ENDIF PROTOCOL_ICQ}
 {$IFDEF PROTOCOL_MRA}
  if proto is TMRASession then
    begin
      if not (st = byte(mSC_away)) then
        imAwaySince:=0
      else
       if not (byte(lastStatus) = byte(mSC_away)) then
        imAwaySince:=now;
    end
 {$ENDIF PROTOCOL_MRA}
   ;
  lastStatus:=st;
  if proto.isOffline and (st<>byte(SC_OFFLINE)) then
    begin
 {$IFDEF PROTOCOL_ICQ}
      TicqSession(Proto).setStatusStr(xSt, xStStr);
 {$ENDIF PROTOCOL_ICQ}
      doConnect
    end
   else
    begin
     {$IFDEF PROTOCOL_ICQ}
      if proto is TicqSession then
        begin
          TicqSession(proto).setStatusFull(st, xSt, xStStr);
        end
      else
     {$ENDIF PROTOCOL_ICQ}
       proto.setStatus(st);
    end;
  if st= byte(SC_OFFLINE) then
   begin
    stayconnected:=FALSE;
    setProgBar(proto, 0);
    resolving:=FALSE;
   end;
end; // setStatusFull

procedure userSetStatus(const proto: TRnQProtocol; st: byte; isShowAMWin: Boolean = True);
begin
  setStatus(proto, st);
  if autoaway.bakmsg > '' then
    setAutomsg(autoaway.bakmsg);
 {$IFDEF PROTOCOL_ICQ}
  if isShowAMWin and popupAutomsg and (st in statusWithAutoMsg) then
   begin
    if not Assigned(automsgFrm) then
     begin
      automsgFrm := TautomsgFrm.Create(Application);
      translateWindow(automsgFrm);
     end;
    automsgFrm.show;
   end;
 {$ENDIF PROTOCOL_ICQ}
  lastStatusUserSet:=st;
end; // userSetStatus

procedure setVisibility(const proto: TRnQProtocol; vi: byte);
 {$IFDEF PROTOCOL_ICQ}
var
//  changeStatus:boolean;
  icq : TicqSession;
 {$ENDIF PROTOCOL_ICQ}
begin
 {$IFDEF PROTOCOL_ICQ}
 if proto.ProtoElem is TicqSession then
 begin
  icq := proto.ProtoElem as TicqSession;
  ICQ.visibility:=Tvisibility(vi);
 {$IFDEF UseNotSSI}
  ICQ.updateVisibility;
 {$ENDIF UseNotSSI}
 end
 {$ENDIF PROTOCOL_ICQ}
 {$IFDEF PROTOCOL_MRA}
 else
   if proto.ProtoElem is TMRASession then
    begin
      TMRASession(proto.ProtoElem).visibility := TMRAvisibility(vi);
    end
 {$ENDIF PROTOCOL_MRA}
  ;

 RnQmain.updateStatusGlyphs;
end; // setVisibility

procedure usersetVisibility(const proto: TRnQProtocol; vi: byte);
begin
 {$IFDEF PROTOCOL_ICQ}
//  if proto.ProtoName = 'ICQ' then
  if proto.ProtoElem is TicqSession then
   begin
// {$IFDEF UseNotSSI}
//  if vi <> icq.visibility then
    TicqSession(proto.ProtoElem).clearTemporaryVisible;
// {$ENDIF UseNotSSI}
   end;
 {$ENDIF PROTOCOL_ICQ}
  setvisibility(proto, vi);
end; // userSetStatus

function sendEmailTo(c: TRnQContact): boolean;
var
  ml: String;
begin
  if c = NIL then
    exit
 {$IFDEF PROTOCOL_ICQ}
  else
  if c is TICQContact then
    ml := TICQContact(c).email
 {$ENDIF PROTOCOL_ICQ}
 {$IFDEF PROTOCOL_MRA}
  else if c is TMRAContact then
    ml := c.uid
 {$ENDIF PROTOCOL_MRA}
   else
    ml := '';
  result:=ml > '';
  if result then
    exec('mailto:'+ ml);
end; // sendEmailTo

function str2db(pProto: TRnQProtocol; const s: RawByteString;
                var ok: boolean; pCheckGroups: Boolean): TRnQCList;
const
  ErrCorupted = 'The contacts database is corrupted, some data is lost';
var
  t,l,i: integer;
  d: RawByteString;
//  c:TICQcontact;
  c: TRnQContact;
 {$IFDEF PROTOCOL_MRA}
  cntMRA : TMRAContact;
 {$ENDIF PROTOCOL_MRA}
 {$IFDEF PROTOCOL_ICQ}
  cntICQ : TICQContact;
 {$ENDIF PROTOCOL_ICQ}
  vUID : TUID;
begin
  ok := FALSE;
  result := TRnQCList.create;
  C := NIL;  // shut up compiler
  i := 0;
while i < length(s) do
  begin
    d := '';
    if length(s)-pred(i) < 8 then
     begin
      msgDlg(ErrCorupted, True, mtError);
      exit;
     end;
   try
    t:= dword_LEat(@s[i+1]); // 1234
    l:=dword_LEat(@s[i+5]); // 5678
    if length(s)-pred(i) < l then
      begin
      msgDlg(ErrCorupted, True, mtError);
      exit;
      end;
    d:=copy(s,i+9,l);
    inc(i, 8+l);
    if (t <> DBFK_OLDUIN) AND (t <> DBFK_UID) AND not Assigned(c) then
     Continue;
    case t of
      DBFK_OLDUIN: if str2int(d) > 0 then
                    begin
//                     c:=(result.get(cls, str2int(d)));
                     c := result.add(pProto, intToStr(str2int(d)));
//                     c.CntIsLocal := False;
                    end;
      DBFK_UID: if d > '' then
                 begin
//                  c:= (result.get(cls, d));
                   vUID := UnUTF(d);
                    c := result.add(pProto, vUID);
//                  c.CntIsLocal := False;
                 end;
      DBFK_Authorized: c.Authorized := boolean(d[1]);
      DBFK_DISPLAY:    c.fDisplay:= UnUTF(d);
      DBFK_NICK:       c.nick := UnUTF(d);
      DBFK_FIRST:      c.first:= UnUTF(d);
      DBFK_LAST:       c.last := UnUTF(d);

      DBFK_GROUP:
                  begin
                    system.move(d[1], c.group, 4);
                    if pCheckGroups then
                     if not groups.exists(c.group) then
                       c.group := 0;
                  end;
      DBFK_NOTES:      TCE(c.data^).notes:= UnUTF(d);
      DBFK_DONTDELETE: TCE(c.data^).dontdelete:=boolean(d[1]);
      DBFK_ASKEDAUTH:  TCE(c.data^).askedAuth:=boolean(d[1]);
      DBFK_QUERY:      TCE(c.data^).toquery:=boolean(d[1]);
      DBFK_SENDTRANSL: c.SendTransl := boolean(d[1]);
      DBFK_BIRTH:      system.move(d[1], c.birth, 8);
      DBFK_BIRTHL:     system.move(d[1], c.birthL, 8);
      DBFK_LASTBDINFORM: system.move(d[1], c.LastBDInform, 8);
      DBFK_lclNoteStr: c.lclImportant := UnUTF(d);
      DBFK_ICONSHOW:   system.move(d[1], c.icon.ToShow, 1);
      DBFK_SSIID: begin
                       c.SSIID := str2int(d);
                       c.CntIsLocal := c.SSIID = 0;
                  end;
      else
       begin
        c.ParseDBrow(t, d);
       end
      ;
//     else
//      c.about := c.about + CRLF + IntToStr(t) + ' - ' + d;
     end;//case
     SetLength(D, 0);
   except
   end;
  end;
ok:=TRUE;
end; // str2db

function str2db(pProto : TRnQProtocol; const s: RawByteString):TRnQCList;
var
  asd:boolean;
begin
  result:=str2db(pProto, s,asd, false)
end;

(*
function getClientFor(c:TRnQcontact; pInInfo : Boolean = False):string;
begin
  result:='';
  if c=NIL then exit;
  if c.fProto.isOffline then
    Exit;
  if not pInInfo then
    c.ClientStr := c.fProto.getClientPicFor(c);

  Result := c.fProto.getClientDescFor(c);
end; // getClientFor
*)

function  getProtosPref() : TPrefPagesArr;
var
  cl : TPrefFrameClass;
begin
//  SetLength(Result, length(Account.AccProto));
  if Assigned(Account.AccProto) then
   begin
    cl := Account.AccProto.getPrefPage;
    if cl <> NIL then
      begin
        SetLength(Result, 1);
        Result[0] := TPrefPage.Create;
        with Result[0] do
         begin
          idx := 2;
          frame := NIL;
          frameClass := cl;
          Name := Account.AccProto.ProtoName + Account.AccProto.getMyInfo.UID2cmp;
          Caption := Account.AccProto.ProtoName +' ('+ Account.AccProto.getMyInfo.UID2cmp + ')';
         end;
      end;
   end;

end;

function  getProtoClass(ProtoID : Byte) : TRnQProtoClass;
begin
 {$IFNDEF ICQ_ONLY}
  case ProtoID of
 {$IFDEF PROTOCOL_ICQ}
    ICQProtoID: Result := TicqSession;
 {$ENDIF PROTOCOL_ICQ}
  {$IFDEF PROTOCOL_MRA}
    MRAProtoID: Result := TMRASession;
  {$ENDIF PROTOCOL_MRA}
  {$IFDEF PROTOCOL_XMP}
    XMPProtoID: Result := TxmppSession;
  {$ENDIF PROTOCOL_XMP}
  {$IFDEF PROTOCOL_BIM}
    OBIMProtoID: Result := TBIMSession;
  {$ENDIF PROTOCOL_BIM}
   else
    Result := NIL;
  end;
 {$ELSE ICQ_ONLY}
    Result := TicqSession;
 {$ENDIF ICQ_ONLY}
end;

function  Proto_Outbox_add(kind: Integer; dest:TRnQContact; flags:integer=0; const info:string=''):Toevent;
//var
//  pr : TRnQProtocol;
begin
  if Assigned(dest) then
    begin
//     pr := dest.fProto;
//     result := main.Accounts[pr.AccIDX].outbox.add(kind, dest, flags, info);
     result := Account.outbox.add(kind, dest, flags, info);
      if Assigned(outboxFrm) then
        outboxFrm.updateList;
    end
   else
    Result := NIL;
end;

function  Proto_Outbox_add(kind: Integer; dest:TRnQContact; flags:integer; cl:TRnQCList):Toevent;
//var
//  pr : TRnQProtocol;
begin
  if Assigned(dest) then
    begin
//     pr := dest.fProto;
//     result := main.Accounts[pr.AccIDX].outbox.add(kind, dest, flags, cl);
     result := Account.outbox.add(kind, dest, flags, cl);
      if Assigned(outboxFrm) then
        outboxFrm.updateList;
    end
   else
    Result := NIL;
end;

procedure getTrayIconTip(var vPic : TPicName; var vTip : String);
var
  e:Thevent;
//  nIco : String;
//  IcoDtl : TRnQThemedElementDtls;
//  IcoPicName : TPicName;
//  s:string;
  MyInf : TRnQContact;
begin
  if BossMode.isBossKeyOn then
   begin
     vPic := PIC_CLIENT_LOGO;
     vTip := 'R&&&Q';
     Exit;
   end
  else
  if (eventQ=NIL) or eventQ.empty or (blinkWithStatus and not (blinking or Account.AccProto.getStatusDisable.blinking)) then
   begin
    if not Assigned(Account.AccProto) then
//      IcoDtl.picName := status2imgName(byte(SC_UNK), false)
       vPic := status2imgName(byte(SC_UNK), false)
     else
      if Account.AccProto.isOnline then
       begin
//        nIco := status2imgNameExt(status, invisibleModeBool, ICQ.curXStatus);
//        s := statusNameExt2(myStatus, TicqSession(MainProto.ProtoElem).curXStatus);
//        IcoDtl.picName := status2imgNameExt(myStatus, invisibleModeBool, TicqSession(MainProto.ProtoElem).curXStatus);
        vTip := Account.AccProto.getStatusName;
//        IcoDtl.picName := MainProto.getStatusImg;
        vPic := Account.AccProto.getStatusImg;
       end
    else
      if Account.AccProto.isConnecting or resolving then
        begin
          vTip :=getTranslation('Connecting');
//          nIco := PIC_CONNECTING;
//          IcoDtl.ThemeToken := -1;
          if Account.AccProto.ProtoElem.progLogon>0 then
            begin
//              nIco := PIC_CONNECTING + IntToStr(Trunc(progLogon * 8));
//              IcoDtl.picName := PIC_CONNECTING + IntToStrA(Trunc(progLogon * 8));
              vPic := PIC_CONNECTING + IntToStrA(Trunc(Account.AccProto.ProtoElem.progLogon * 8));
//              with theme.GetPicSize(IcoDtl) do
              with theme.GetPicSize(RQteTrayNotify, vPic) do
              if not( (cx>0)and(cy>0)) then
               begin
//               nIco := PIC_CONNECTING;
//                IcoDtl.picName := PIC_CONNECTING;
                vPic := PIC_CONNECTING;
               end;
            end
           else
//            IcoDtl.picName := PIC_CONNECTING;
            vPic := PIC_CONNECTING;
          if Account.AccProto.IsInvisible then
//            nIco := INVIS_PREFIX + nIco;
//            IcoDtl.picName := INVIS_PREFIX + IcoDtl.picName;
           vPic := INVIS_PREFIX + vPic;
//          IcoDtl.ThemeToken := -1;
        end
      else
        begin
//          s:=statusNameExt2(byte(SC_OFFLINE));
          vTip := getTranslation(Account.AccProto.statuses[byte(SC_OFFLINE)].Cptn);
//          nIco := status2imgNameExt(SC_OFFLINE, invisibleModeBool);
//          IcoDtl.picName := status2imgNameExt(byte(SC_OFFLINE), invisibleModeBool);
//          IcoDtl.picName := status2imgName(byte(SC_OFFLINE), MainProto.IsInvisible);
          vPic := status2imgName(byte(SC_OFFLINE), Account.AccProto.IsInvisible);
        end;
    MyInf := Account.AccProto.getmyinfo;
    if assigned(MyInf) then
//    if assigned(Account.AccProto.myinfo) then
      vTip:= getTranslation('%s [%s]',[vTip, MyInf.displayed +' / '+ MyInf.uin2Show])
    else
      vTip:='R&&&Q';
   end
  else
    begin
     e:=eventQ.top;
     if Assigned(e) then
      begin
       if blinking or Account.AccProto.getStatusDisable.blinking then
  //       nIco:=e.pic
//         IcoDtl.picName := e.pic
         vPic := e.pic
        else
         vPic := PIC_EMPTY;
       if (e.who=NIL)or(not (e.who is Trnqcontact)) then
         vTip :=getTranslation(Str_Error)
       else
     //    s:=gettr('tray '+event2str[e.kind],[e.who.displayed]);
         vTip :=getTranslation(trayevent2str[e.kind],[e.who.displayed]);
      end;
    end;
end;

function addToRoster(c: TRnQContact; isLocal: Boolean = False): boolean;
begin
  notInList.remove(c);
//      c.CntIsLocal := isLocal;
      if isLocal then
        c.SSIID := 0;
      result:= c.fProto.addContact(c, isLocal);
  if not result then exit;
  roasterlib.update(c);
  roasterLib.focus(c);
  saveListsDelayed:=TRUE;
  autosizeDelayed:=TRUE;
  plugins.castEvList( PE_LIST_ADD, PL_ROSTER, c);
 {$IFDEF UseNotSSI}
  if c is TICQcontact then
//  if (not icq.useSSI)and icq.useLSI3 then
   with TicqSession(c.iProto.ProtoElem) do
    if not UseSSI and useLSI2 then
     begin
      if StrToIntDef(c.uid, 0) > 0 then
       begin
        if TICQcontact(c).infoUpdatedTo=0 then
          sendQueryInfo(StrToIntDef(c.UID2cmp, 0));
        if sendTheAddedYou then
          Account.outbox.add(OE_addedYou, c);
       end;
     end;
 {$ENDIF UseNotSSI}
end; // addToRoster


end.
