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
  JSON, RNQJson,
  automsgDlg,
  RnQPrefsTypes,
  RnQPics,
  RDGlobal, outboxLib;

type
  TRnQProtoHelper = class helper for TRnQProtocol
  public
    procedure Event(event: Integer; data: TJSONValue = NIL);
    procedure ShowWP;
    procedure GetOfflineMSGS;
    procedure DelOfflineMSGS;
    procedure OpenMailBox;
    procedure userSetStatus(st: byte; isShowAMWin: Boolean = True);
    procedure usersetVisibility(vi: byte);
    function  UploadAvatar(const fn: String): Boolean;
    procedure ViewSSI;
    procedure EventExtraPics(evKind: Integer;
                             const evBody: RawByteString;
                             var pic1, pic2: TPicName);
    function  status2imgName(s: byte; inv: boolean=FALSE): TPicName;
    function  status2imgNameExt(s: byte; inv: boolean=FALSE; extSts: byte= 0): TPicName;
    function  enterPWD: boolean;
  end;

  TRnQContactHelper = class helper for TRnQContact
  public
    procedure SendSMS(Parent: TComponent);
    function  CanSMS: Boolean;
    function  CanMail: Boolean;
    function  CanBuzz: Boolean;
    function  sendBuzz: Boolean;
    function  CanSendFile: Boolean;
    procedure auth;
    procedure AuthDenied(const msg: string='');
    procedure AuthRequest(const msg: String);
    procedure DelCntFromSrv;
  {$IFDEF RNQ_AVATARS}
    function  AvatarNeedToRefresh: Boolean;
  {$ENDIF RNQ_AVATARS}
    procedure SendFilesTo(const pFiles: String);
    procedure sendSticker(stkr: String);

    function  sendEmailTo: boolean;
    function  GetContactIP: Integer;
    function  GetContactIntIP: Integer;

  end;

function  Protos_getXstsPic(cnt: TRnQContact; isSelf: Boolean = false): TPicName;
procedure ProtoEvent(Sender: TRnQProtocol; event: Integer; data: TJSONValue = NIL);
function  try_load_or_req_avatar(cnt: TRnQContact): Boolean;


function  Proto_StsID2Name(Proto: TRnQProtocol; s: Byte; xs: byte): String;
function  status2imgName(s: byte; inv: boolean=FALSE): TPicName; inline;
function  status2imgNameExt(s: byte; inv: boolean=FALSE; extSts: byte= 0): TPicName; inline;

function  setStatus(const proto: TRnQProtocol; st: byte; isAuto: Boolean = False): byte;
function  setStatusFull(const proto: TRnQProtocol; st: byte; xSt: byte; xStStr: TXStatStr; isAuto: Boolean = False): byte;
procedure setVisibility(const proto: TRnQProtocol; vi: byte);

//function  str2db(cls: TRnQCntClass; const s: RawByteString; var ok: boolean): TRnQCList; overload;
//function  str2db(cls: TRnQCntClass; const s: RawByteString): TRnQCList; overload;
function  str2db(pProto: TRnQProtocol; const s: RawByteString;
                    var ok: boolean; pCheckGroups: Boolean): TRnQCList; overload;
function  str2db(pProto: TRnQProtocol; const s: RawByteString): TRnQCList; overload;
//function  getClientFor(c: TRnQcontact; pInInfo: Boolean = False): string;
function  getProtosPref(): TPrefPagesArr;
function  getProtoClass(ProtoID: Byte): TRnQProtoClass;
function  addToRoster(c: TRnQcontact; isLocal: Boolean = False): boolean; overload;
function  Proto_Outbox_add(kind: Integer; dest: TRnQContact; flags: integer=0; const info: string=''): Toevent; overload;
function  Proto_Outbox_add(kind: Integer; dest: TRnQContact; flags: integer; cl: TRnQCList): Toevent; overload;

procedure getTrayIconTip(var vPic: TPicName; var vTip: String);

procedure Process_InfoRetrives;
procedure Process_xStatusRetrives;

var
  ToUploadAvatarFN: String;

Const
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
    ('���� ��������� ������������� �������� ��������.'),
    ('�� ����� �� ���������� ���. ���������� ��� ���.'),
    ('��� ������. ���� ��������� ��������. �������.'),
    ('�� �� ������ �������� ��������. � ��� �� �������� �������. ��� UIN (%uin%) ������������.'),
    ('����������, ������� �������� ��� ������� �� ������ ���� (3 �����). '),
    ('�������� �������: %attempt%.'#13#10'%code%')
   )}
   );


implementation
uses
  SysUtils, StrUtils,
 {$IFDEF UNICODE}
   AnsiStrings,
 {$ENDIF}

  RnQBinUtils, RQUtil, RnQDialogs, RnQLangs, RnQStrings,
  RDUtils, RDSysUtils, RnQGlobal,
 {$IFDEF PROTOCOL_MRA}
  Protocol_MRA, MRAcontacts,
  MRASMSDlg, MRA_proto,
  MRAv1,
 {$ENDIF PROTOCOL_MRA}
 {$IFDEF PROTOCOL_XMP}
  Protocol_XMP, XMPPcontacts,
  XMPPv1,
 {$ENDIF PROTOCOL_XMP}
 {$IFDEF PROTOCOL_BIM}
  Protocol_BIM, BIMcontacts,
  BIM_proto,
  BIMv1,
 {$ENDIF PROTOCOL_BIM}
 {$IFDEF PROTOCOL_ICQ}
  ICQv9,
  ICQConsts, RQ_ICQ,
  viewSSI,
 {$ENDIF PROTOCOL_ICQ}
 {$IFDEF PROTOCOL_WIM}
  Protocol_WIM, WIMcontacts,
  WIM, WIMConsts,
 {$ENDIF PROTOCOL_WIM}
 {$IFDEF PROTOCOL_TLG}
  Protocol_TLG, TLGcontacts,
  TLG, TLGConsts,
 {$ENDIF PROTOCOL_TLG}

  outboxDlg,
  events, pluginutil, pluginLib, history,

  {$IFDEF RNQ_AVATARS}
  RnQ_Avatars,
  {$ENDIF RNQ_AVATARS}
  RnQConst, globalLib,
  utilLib, themesLib, RQThemes, roasterLib,
  MainDlg, chatDlg;

procedure TRnQProtoHelper.Event(event: Integer; data: TJSONValue = NIL);
  {$IFDEF PROTOCOL_ICQ}
var
  icqSess: TicqSession;
  {$ENDIF PROTOCOL_ICQ}
begin
 {$IFNDEF ICQ_ONLY}
  case Self.ProtoID of

    ICQProtoID: begin
 {$ENDIF ICQ_ONLY}
  {$IFDEF PROTOCOL_ICQ}
                 icqSess := TicqSession(Self);
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
    MRAProtoID: ProcessMRAEvents(TMRASession(Self), TMRAEvent(event));
  {$ENDIF PROTOCOL_MRA}

  {$IFDEF PROTOCOL_XMP}
    XMPProtoID: ProcessXMPPEvents(TxmppSession(Self), TxmppEvent(event));
  {$ENDIF PROTOCOL_XMP}

  {$IFDEF PROTOCOL_BIM}
    OBIMProtoID: ProcessBIMEvents(TBIMSession(Self), TBIMEvent(event));
  {$ENDIF PROTOCOL_BIM}

  {$IFDEF PROTOCOL_WIM}
    WIMProtoID: ProcessWIMEvents(TWIMSession(Self), TWIMEvent(event));
  {$ENDIF PROTOCOL_WIM}
  {$IFDEF PROTOCOL_TLG}
    TLGProtoID: ProcessTLGEvents(TTLGSession(Self), TTLGEvent(event), data);
  {$ENDIF PROTOCOL_TLG}
    else
      Assert(True, 'Unknown protocol');
  end;
 {$ENDIF ICQ_ONLY}
end;

procedure TRnQProtoHelper.ShowWP;

begin
 {$IFNDEF ICQ_ONLY}
  if Self.ProtoID = ICQProtoID then
 {$ENDIF ICQ_ONLY}
     showForm(WF_WP)
 {$IFDEF PROTOCOL_MRA}
   else
  if Self.ProtoID = MRAProtoID then
     showForm(WF_WP_MRA)
 {$ENDIF PROTOCOL_MRA}
end;

procedure ProtoEvent(Sender: TRnQProtocol; event: Integer; data: TJSONValue = NIL);
begin
  Sender.Event(event, data);
end;
function  Protos_getXstsPic(cnt: TRnQContact; isSelf: Boolean = false): TPicName;
var
  pr: TRnQProtocol;
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

procedure TRnQProtoHelper.GetOfflineMSGS;
begin
  {$IFDEF PROTOCOL_ICQ}
 if Self is TicqSession then
   TicqSession(Self).sendReqOfflineMsgs
  else
  {$ENDIF PROTOCOL_ICQ}
 {$IFDEF PROTOCOL_MRA}
 if Self is TMRASession then
   TMRASession(Self).sendReqOfflineMsgs
 {$ENDIF PROTOCOL_MRA}
   ;
end;

procedure TRnQProtoHelper.DelOfflineMSGS;
begin
 {$IFDEF PROTOCOL_ICQ}
 if Self is TicqSession then
   TicqSession(Self).sendDeleteOfflineMsgs
 {$ENDIF PROTOCOL_ICQ}
 {$IFDEF PROTOCOL_MRA}
  else
 if Self is TMRASession then
   TMRASession(Self).sendDeleteOfflineMsgs
 {$ENDIF PROTOCOL_MRA}
   ;
end;

procedure TRnQProtoHelper.OpenMailBox;
begin
 {$IFDEF PROTOCOL_MRA}
  if Assigned(Self) and (Self is TMRASession) then
   TMRASession(Self).RequestMPOP_SESSION;
 {$ENDIF PROTOCOL_MRA}
end;

procedure TRnQProtoHelper.userSetStatus(st: byte; isShowAMWin: Boolean = True);
begin
  protocols_all.setStatus(Self, st);
  if autoaway.bakmsg > '' then
    setAutomsg(autoaway.bakmsg);
 {$IFDEF PROTOCOL_ICQ}
  if isShowAMWin and popupAutomsg and
    (st in statusWithAutoMsg) then
   begin
    if not Assigned(automsgFrm) then
     begin
      automsgFrm := TautomsgFrm.Create(Application);
      translateWindow(automsgFrm);
     end;
    automsgFrm.show;
   end;
 {$ENDIF PROTOCOL_ICQ}
  lastStatusUserSet := st;
end; // userSetStatus

procedure TRnQProtoHelper.usersetVisibility(vi: byte);
begin
 {$IFDEF PROTOCOL_ICQ}
//  if proto.ProtoName = 'ICQ' then
  if Self is TicqSession then
   begin
// {$IFDEF UseNotSSI}
//  if vi <> icq.visibility then
    TicqSession(Self).clearTemporaryVisible;
// {$ENDIF UseNotSSI}
   end;
 {$ENDIF PROTOCOL_ICQ}
  setvisibility(Self, vi);
end; // userSetStatus

procedure TRnQProtoHelper.ViewSSI;
begin
 {$IFDEF PROTOCOL_ICQ}
    if Self._getProtoID = ICQProtoID then
      if Assigned(SSIForm) then
        SSIForm.Show
       else
        begin
          SSIForm := TSSIForm.Create(Application);
          applyCommonsettings(SSIForm);
          translateWindow(SSIForm);
//          SSIForm.AssignProto(Self);
    //      SSIForm.Show;
          showForm(SSIForm);
        end;
 {$ENDIF PROTOCOL_ICQ}
end;


procedure TRnQProtoHelper.EventExtraPics(evKind: Integer;
                                const evBody: RawByteString;
                                var pic1, pic2: TPicName);
var
  st: Integer;
  b: byte;
begin
  { TODO 3 -oRapid D : MUST add various protocols!!! }
  pic1 := '';
  pic2 := '';
     case evKind of
       EK_ONCOMING,
       EK_STATUSCHANGE:
         begin
           if length(evBody) >= 4 then
             begin
 //            vPicName := status2imgName(Tstatus(str2int(s)), (length(s)>4) and boolean(s[5]));
//            statusDrawExt(cnv.Handle, curX+2, curY, Tstatus(str2int(s)), (length(s)>4) and boolean(s[5]), infoToXStatus(s))
              st := str2int(evBody);
              if st in [byte(Low(Self.statuses))..byte(High(Self.statuses))] then
              begin
                b := infoToXStatus(evBody);
  //              if (not XStatusAsMain) and (st <> SC_ONLINE)and (b>0) then
                if (st <> byte(SC_ONLINE))or(not XStatusAsMain)or (b=0)  then
                 begin
                   pic1 := status2imgName(st, (length(evBody)>4) and boolean(evBody[5]))
//                   pic1 := Self.Statuses[st].ImageName;
                 end;
   {$IFDEF PROTOCOL_ICQ}
                if (b > 0) and (b <= high(XStatusArray)) then
                  pic2 := XStatusArray[b].PicName;
   {$ENDIF PROTOCOL_ICQ}
              end;
             end;
         end;
       EK_XstatusMsg:
         begin
   {$IFDEF PROTOCOL_ICQ}
           if length(evBody) >= 1 then
            if (byte(evBody[1]) <= High(XStatusArray)) then
              pic1 := XStatusArray[byte(evBody[1])].PicName;
   {$ENDIF PROTOCOL_ICQ}
//            statusDrawExt(cnv.Handle, x+2,y, SC_UNK, false, ord(s[1]));
//            statusDrawExt(cnv.Handle, curX+2, curY, Tstatus(str2int(s), false, ord(s[1]));
 //            vPicName := status2imgName(Tstatus(str2int(s)), (length(s)>4) and boolean(s[5]));
         end;
       EK_OFFGOING:
         pic1 := status2imgName(byte(SC_OFFLINE));
     end;
end;

function TRnQProtoHelper.status2imgName(s: byte; inv: boolean=FALSE): TPicName;
//const
//  prefix = 'status.';
var
  st: TStatusArray;
begin
  st := Self.statuses;
 if s in [byte(LOW(st)).. byte(HIGH(st))] then
//   result := prefix + st[s].ImageName
   result := st[s].ImageName
//   result := sta 'status.' + status2str[s]
  else
   result := PIC_STATUS_UNK;

 if inv then
//  inc(result, PIC_INVISIBLE_STATUS_ONLINE-PIC_STATUS_ONLINE);
   result := INVIS_PREFIX + result;
end;

function TRnQProtoHelper.status2imgNameExt(s: byte; inv: boolean=FALSE; extSts: byte= 0): TPicName;
begin
 {$IFDEF ICQ_ONLY}
  Result := protocol_icq.status2imgNameExt(s, inv, extSts);
 {$ELSE ~ICQ_ONLY}
   Result := status2imgName(s, inv)
 {$ENDIF ICQ_ONLY}
end;

function TRnQProtoHelper.enterPWD: boolean;
var
  s, sUIN: String;
  res: boolean;
  myInf: TRnQContact;
begin
  result := FALSE;
  if enteringProtoPWD then
    exit;
  enteringProtoPWD := TRUE;
  try
   {$IFDEF PROTOCOL_ICQ}
    if (Self is TicqSession) and (TicqSession(Self).saveMD5Pwd) then
      s := ''
     else
   {$ENDIF PROTOCOL_ICQ}
      s := Self.pwd;
    sUIN := Self._GetProtoName + '#'+  Self.MyAccNum;
  //  res := enterPwdDlg(s, getTranslation('Login password') + ' (' + RnQUser + ')', 16);
//    res := enterPwdDlg(s, getTranslation('Login password') + ' (' + sUIN + ')', 16);
    res := enterPwdDlg(s, getTranslation('Login password') + ' (' + sUIN + ')', Self._MaxPWDLen);
    {$IFDEF PROTOCOL_ICQ}
    if (Self is TicqSession) and (Length(s) > maxPwdLength)
       or (Length(s) > Self._MaxPWDLen) then
      begin
       msgDlg('Password too long', True, mtError);
       exit;
      end;
    if Self is TicqSession then
      begin
        myInf := Self.getMyInfo;
        if Assigned(myInf) then
         if not tICQcontact(myInf).isAIM then
          if Length(s) > 8 then
           begin
             msgDlg('Please enter only first 8 symbols of your password', True, mtInformation);
      //     exit;
           end;
      end;
    {$ENDIF PROTOCOL_ICQ}
  finally
    enteringProtoPWD := FALSE;
  end;

  if not res or (s='') then exit;
{  if thisICQ.ProtoElem is TicqSession then
    if LoginMD5 and saveMD5Pwd then
      s := MD5Pass(s);}
  Self.pwd := s;
//  saveCFG;
  if not dontSavePwd then
    saveCfgDelayed := True;
  result := TRUE;
end; // enterICQpwd

function TRnQProtoHelper.UploadAvatar(const fn: String): Boolean;
begin
  Result := false;
  if (fn > '') and self.isOnline then
  {$IFDEF PROTOCOL_ICQ}
   if self is TicqSession then
    begin
     Result := TicqSession(self).uploadAvatar(fn)
    end
   else
  {$ENDIF PROTOCOL_ICQ}
  {$IFDEF PROTOCOL_WIM}
   if self is TWIMSession then
    begin
     Result := TWIMSession(self).uploadAvatar(fn);
    end
   else
  {$ENDIF PROTOCOL_WIM}
  {$IFDEF PROTOCOL_BIM}
   if proto is TBIMSession then
    begin
     TBIMSession(proto).uploadAvatar(fn);
     Result := True;
    end;
  {$ENDIF PROTOCOL_BIM}
  {$IFDEF PROTOCOL_TLG}
   if self is TTLGSession then
    begin
     Result := TTLGSession(self).uploadAvatar(fn);
    end
   else
  {$ENDIF PROTOCOL_TLG}
end;

/////////////////////////////////////////////
//  TRnQContactHelper
/////////////////////////////////////////////
procedure TRnQContactHelper.SendSMS(Parent: TComponent);
begin
  if Assigned(Self) then
   {$IFDEF PROTOCOL_MRA}
    if Self.fProto.ProtoID = MRAProtoID then
     begin
      TMRAsmsFrm.doAll(Parent, Self);
     end;
   {$ENDIF PROTOCOL_MRA}
end;

function TRnQContactHelper.CanSMS: Boolean;
begin
  Result := Assigned(Self) and
 {$IFDEF PROTOCOL_MRA}
    Assigned(Self.fProto) and (Self.fProto.ProtoID = MRAProtoID);
 {$ELSE nonPROTOCOL_MRA}
     false
 {$ENDIF PROTOCOL_MRA}
end;

function TRnQContactHelper.CanMail: Boolean;
begin
  Result := Assigned(Self) and
    ( (1=2)
 {$IFDEF PROTOCOL_ICQ}
     or
      ( (Self is TICQcontact) and (TICQcontact(Self).email > '') )
 {$ENDIF PROTOCOL_ICQ}
 {$IFDEF PROTOCOL_MRA}
     or
//      ( Assigned(cnt.fProto) and (cnt.fProto.ProtoID = MRAProtoID) )
      ( Self is TMRAcontact)
 {$ENDIF PROTOCOL_MRA}
 {$IFDEF PROTOCOL_BIM}
     or
      ( (Self is TBIMContact) and (TBIMcontact(Self).email > '') )
 {$ENDIF PROTOCOL_BIM}
     );
end;

function TRnQContactHelper.CanBuzz: Boolean;
begin
 {$IFDEF PROTOCOL_ICQ}
  if Assigned(Self) and (Self is TICQContact) then
    Result := CAPS_big_Buzz in TICQContact(Self).capabilitiesBig
   else
 {$ENDIF PROTOCOL_ICQ}
 {$IFDEF PROTOCOL_WIM}
  if Assigned(Self) and (Self is TWIMContact) then
    Result := CAPS_big_Buzz in TWIMContact(Self).capabilitiesBig
   else
 {$ENDIF PROTOCOL_WIM}
   Result := false;
end;

function TRnQContactHelper.sendBuzz: Boolean;
begin
  if 1=2 then
   else
 {$IFDEF PROTOCOL_ICQ}
  if Assigned(Self) and (Self is TICQContact) then
    Result := TICQSession(Self.Proto).SendBuzz(Self)
   else
 {$ENDIF PROTOCOL_ICQ}
 {$IFDEF PROTOCOL_WIM}
  if Assigned(Self) and (Self is TWIMContact) then
    Result := TWIMSession(Self.Proto).SendBuzz(Self)
   else
 {$ENDIF PROTOCOL_WIM}
   Result := false;
end;

procedure TRnQContactHelper.sendSticker(stkr: String);
begin
 {$IFDEF PROTOCOL_ICQ}
  if Assigned(Self) and (Self is TICQContact) then
    TICQSession(Self.Proto).sendSticker(self.UID2cmp, stkr);
 {$ENDIF PROTOCOL_ICQ}
 {$IFDEF PROTOCOL_WIM}
  if Assigned(Self) and (Self is TWIMContact) then
    TWIMSession(Self.Proto).sendSticker(TWIMContact(self), stkr);
 {$ENDIF PROTOCOL_WIM}
end;

function TRnQContactHelper.CanSendFile: Boolean;
begin
  Result :=
{$IFDEF PROTOCOL_ICQ}
        (Self is TICQcontact) and
 {$IFDEF usesDC}
        Assigned(Self) and Self.fProto.IsOnline and
            TICQContact(Self).isAcceptFile;
 {$else not usesDC}
        false;
 {$ENDIF  usesDC}
{$ELSE ~PROTOCOL_ICQ}
        false;
{$ENDIF PROTOCOL_ICQ}
end;

procedure TRnQContactHelper.auth;
var
  ev: THevent;
begin
//  c := Tcontact(contactsDB.get(TICQContact, uin));
  plugins.castEv(PE_AUTH_SENT, Self.uid);
//ICQ.sendAuth(uin);
  with Self.fProto do
   begin
     AuthGrant(Self);
 {$IFNDEF ICQ_ONLY}
     case ProtoID of
       ICQProtoID:
 {$ENDIF ICQ_ONLY}
             begin
 {$IFDEF PROTOCOL_ICQ}
               TicqSession(ProtoElem).SSIAuth_REPLY(Self.uid, True);
 {$ENDIF PROTOCOL_ICQ}
             end;
 {$IFNDEF ICQ_ONLY}
//       XMPProtoID : TxmppSession(ProtoElem).AuthCancel(cnt);
     end;
 {$ENDIF ICQ_ONLY}
   end;
  ev := Thevent.new(EK_auth, Self.Proto.getMyInfo, now, 0);
  ev.fIsMyEvent := True;
  if logpref.writehistory and (BE_save in behaviour[ev.kind].trig) then
    writeHistorySafely(ev, Self);
  chatFrm.addEvent_openchat(Self, ev);
end; // sendICQauth

procedure TRnQContactHelper.AuthDenied(const msg: string='');
var
//  c: TRnQcontact;
  ev: THevent;
begin
//  c := contactsDB.get(TICQContact, uin);
  plugins.castEv(PE_AUTHDENIED_SENT, Self.uid, msg);
//ICQ.sendAuthDenied(uin, msg);
  with Self.fProto do
 {$IFNDEF ICQ_ONLY}
   case ProtoID of
     ICQProtoID:
 {$ENDIF ICQ_ONLY}
           begin
 {$IFDEF PROTOCOL_ICQ}
             TicqSession(ProtoElem).SSIAuth_REPLY(Self.uid, False, msg);
 {$ENDIF PROTOCOL_ICQ}
           end;
 {$IFNDEF ICQ_ONLY}
   {$IFDEF PROTOCOL_XMP}
     XMPProtoID: TxmppSession(ProtoElem).AuthCancel(Self);
   {$ENDIF PROTOCOL_XMP}
   end;
 {$ENDIF ICQ_ONLY}
  ev := Thevent.new(EK_authDenied, Self.Proto.getMyInfo, now, '', msg, 0);
  ev.fIsMyEvent := True;
  if logpref.writehistory and (BE_save in behaviour[ev.kind].trig) then
    writeHistorySafely(ev, Self);
  chatFrm.addEvent_openchat(Self, ev);
end;

procedure TRnQContactHelper.AuthRequest(const msg: String);
begin
 {$IFDEF PROTOCOL_ICQ}
  if Self is TICQContact then
    TicqSession(Self.Proto).AuthRequest(Self, msg)
   else
 {$ENDIF PROTOCOL_ICQ}
 {$IFDEF PROTOCOL_BIM}
  if Self is TBIMContact then
    TBIMContact(Self).AuthRequest(Self, msg)
   else
 {$ENDIF PROTOCOL_BIM}
 {$IFDEF PROTOCOL_XMP}
  if Self is TxmppContact then
   else
 {$ENDIF PROTOCOL_XMP}
 {$IFDEF PROTOCOL_WIM}
  if Self is TWIMContact then
    TWIMSession(Self.fProto).AuthRequest(Self, msg)
   else
 {$ENDIF PROTOCOL_WIM}
end;

procedure TRnQContactHelper.DelCntFromSrv;
begin
  with Self.fProto do
 {$IFNDEF ICQ_ONLY}
   case ProtoID of
     ICQProtoID :
 {$ENDIF ICQ_ONLY}
           begin
    {$IFDEF PROTOCOL_ICQ}
            TICQSession(ProtoElem).SSIdeleteContact(Self);
    {$ENDIF PROTOCOL_ICQ}
           end;
 {$IFNDEF ICQ_ONLY}
//     XMPProtoID: TxmppSession(ProtoElem).AuthCancel(cnt);
   end;
 {$ENDIF ICQ_ONLY}
end;

  {$IFDEF RNQ_AVATARS}
function TRnQContactHelper.AvatarNeedToRefresh: Boolean;
begin
 {$IFDEF PROTOCOL_ICQ}
  if Self is TICQContact then
    Result := TicqSession(Self.fProto).AvatarsSupport and
      (length(TICQContact(Self).ICQIcon.hash) = 16) and
      (TICQContact(Self).ICQIcon.hash <>
       Self.Icon.hash_safe)
   else
 {$ENDIF PROTOCOL_ICQ}
 {$IFDEF PROTOCOL_BIM}
  if Self is TBIMContact then
    Result := (length(TBIMContact(Self).BIMIcon.hash) = 16) and
      (TBIMContact(Self).BIMIcon.hash <>
       Self.Icon.hash_safe)
   else
 {$ENDIF PROTOCOL_BIM}
 {$IFDEF PROTOCOL_XMP}
  if Self is TxmppContact then
    Result := ((length(TxmppContact(Self).XIcon.hash) = 20) or
               (length(TxmppContact(Self).XIcon.hash) = 40)) and
      (TxmppContact(Self).XIcon.hash <>
       Self.Icon.hash_safe)
   else
 {$ENDIF PROTOCOL_XMP}
 {$IFDEF PROTOCOL_WIM}
  if Self is TWIMContact then
    Result := TWIMSession(Self.fProto).AvatarsSupport and
      (length(TWIMContact(Self).IconID) = 16) and
      (TWIMContact(Self).IconID <>
       Self.Icon.hash_safe)
   else
 {$ENDIF PROTOCOL_WIM}
    Result := false;
end;
  {$ENDIF RNQ_AVATARS}

procedure TRnQContactHelper.SendFilesTo(const pFiles: String);
begin
 {$IFDEF PROTOCOL_ICQ}
  if Self is TICQcontact then
    ICQsendfile(TICQcontact(Self), pFiles);
 {$ENDIF PROTOCOL_ICQ}
end;

function TRnQContactHelper.sendEmailTo: boolean;
var
  ml: String;
begin
  if Self = NIL then
    exit(false)
 {$IFDEF PROTOCOL_ICQ}
  else
  if Self is TICQContact then
    ml := TICQContact(Self).email
 {$ENDIF PROTOCOL_ICQ}
 {$IFDEF PROTOCOL_MRA}
  else if Self is TMRAContact then
    ml := Self.uid
 {$ENDIF PROTOCOL_MRA}
   else
    ml := '';
  result := ml > '';
  if result then
    exec('mailto:'+ ml);
end; // sendEmailTo

function TRnQContactHelper.GetContactIP: Integer;
begin
{$IFDEF PROTOCOL_ICQ}
  if Self is TICQContact then
    Result := TICQContact(Self).connection.ip
   else
{$ENDIF PROTOCOL_ICQ}
    Result := 0;
end;

function TRnQContactHelper.GetContactIntIP: Integer;
begin
{$IFDEF PROTOCOL_ICQ}
  if Self is TICQContact then
    Result := TICQContact(Self).connection.internal_ip
   else
{$ENDIF PROTOCOL_ICQ}
    Result := 0;
end;


function Proto_StsID2Name(Proto: TRnQProtocol; s: Byte; xs: byte): String;
var
  arr: TStatusArray;
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
  st: TStatusArray;
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

//function  status2imgNameExt(pr : TRnQProtocol; s: byte; inv: boolean=FALSE; extSts: byte= 0): TPicName;
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
    autoaway.triggered := TR_none;
  result := byte(proto.getStatus);

 {$IFDEF PROTOCOL_ICQ}
  if proto is TicqSession then
    begin
      if not (st in [byte(SC_away), byte(SC_na)]) then
        imAwaySince := 0
      else
       if not (byte(lastStatus) in [byte(SC_away), byte(SC_na)]) then
        imAwaySince := now;
    end
 {$ENDIF PROTOCOL_ICQ}
 {$IFDEF PROTOCOL_MRA}
  else if proto is TMRASession then
    begin
      if not (st = byte(mSC_away)) then
        imAwaySince := 0
      else
       if not (byte(lastStatus) = byte(mSC_away)) then
        imAwaySince := now;
    end
 {$ENDIF PROTOCOL_MRA}
   ;
  lastStatus := st;
  if proto.isOffline and (st<>byte(SC_OFFLINE)) then
    doConnect
   else
    proto.setStatus(st);
  if st = byte(SC_OFFLINE) then
   begin
    stayconnected := FALSE;
    setProgBar(proto, 0);
    resolving := FALSE;
   end;
end; // setStatus

function setStatusFull(const proto: TRnQProtocol; st: byte; xSt: byte; xStStr: TXStatStr; isAuto: Boolean = False): byte;
//var
//  xStsD : TXStatStr;
begin
  if not isAuto then
    autoaway.triggered := TR_none;
  result := byte(proto.getStatus);

 {$IFDEF PROTOCOL_ICQ}
  if proto is TicqSession then
    begin
      if not (st in [byte(SC_away), byte(SC_na)]) then
        imAwaySince := 0
      else
       if not (byte(lastStatus) in [byte(SC_away), byte(SC_na)]) then
        imAwaySince := now;
    end
  else
 {$ENDIF PROTOCOL_ICQ}
 {$IFDEF PROTOCOL_MRA}
  if proto is TMRASession then
    begin
      if not (st = byte(mSC_away)) then
        imAwaySince := 0
      else
       if not (byte(lastStatus) = byte(mSC_away)) then
        imAwaySince := now;
    end
 {$ENDIF PROTOCOL_MRA}
   ;
  lastStatus := st;
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
  if st = byte(SC_OFFLINE) then
   begin
    stayconnected := FALSE;
    setProgBar(proto, 0);
    resolving := FALSE;
   end;
end; // setStatusFull

procedure setVisibility(const proto: TRnQProtocol; vi: byte);
 {$IFDEF PROTOCOL_ICQ}
var
//  changeStatus: boolean;
  icq: TicqSession;
 {$ENDIF PROTOCOL_ICQ}
begin
 {$IFDEF PROTOCOL_ICQ}
 if proto.ProtoElem is TicqSession then
 begin
  icq := proto.ProtoElem as TicqSession;
  ICQ.visibility := Tvisibility(vi);
 {$IFDEF UseNotSSI}
  ICQ.updateVisibility;
 {$ENDIF UseNotSSI}
 end
 {$ENDIF PROTOCOL_ICQ}
 {$IFDEF PROTOCOL_WIM}
 if proto is TWIMSession then
   begin
    with proto AS TWIMSession do
     begin
      setStatus(getStatus, vi);
     end;
   end
  else
 {$ENDIF PROTOCOL_WIM}
 {$IFDEF PROTOCOL_MRA}
 else
   if proto.ProtoElem is TMRASession then
    begin
      TMRASession(proto).visibility := TMRAvisibility(vi);
    end
 {$ENDIF PROTOCOL_MRA}
  ;

 RnQmain.updateStatusGlyphs;
end; // setVisibility



function str2db(pProto: TRnQProtocol; const s: RawByteString;
                var ok: boolean; pCheckGroups: Boolean): TRnQCList;
const
  ErrCorupted = 'The contacts database is corrupted, some data is lost';
var
  t, l, i, tInt: integer;
  d: RawByteString;
  c: TRnQContact;
  vUID: TUID;
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
    t := dword_LEat(s, i+1); // 1234
    l := dword_LEat(s, i+5); // 5678
    if length(s)-pred(i) < l then
      begin
      msgDlg(ErrCorupted, True, mtError);
      exit;
      end;
    d := copy(s, i+9, l);
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
//                  c := (result.get(cls, d));
                   vUID := UnUTF(d);
                    c := result.add(pProto, vUID);
//                  c.CntIsLocal := False;
                 end;
      DBFK_GROUP:
                  begin
                    system.move(d[1], tInt, 4);
                    c.groupId := tInt;
                    if pCheckGroups then
                     if not groups.exists(tInt) then
                       c.groupId := 0;
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
ok := TRUE;
end; // str2db

function str2db(pProto: TRnQProtocol; const s: RawByteString): TRnQCList;
var
  asd: boolean;
begin
  result := str2db(pProto, s, asd, false)
end;

(*
function getClientFor(c: TRnQcontact; pInInfo: Boolean = False): string;
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

function  getProtosPref(): TPrefPagesArr;
var
  cl: TPrefFrameClass;
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

function  getProtoClass(ProtoID: Byte): TRnQProtoClass;
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
  {$IFDEF PROTOCOL_WIM}
    WIMProtoID: Result := TWIMSession;
  {$ENDIF PROTOCOL_WIM}
  {$IFDEF PROTOCOL_TLG}
    TLGProtoID: Result := TTLGSession;
  {$ENDIF PROTOCOL_TLG}
   else
    Result := NIL;
  end;
 {$ELSE ICQ_ONLY}
    Result := TicqSession;
 {$ENDIF ICQ_ONLY}
end;

//function try_load_avatar(cnt: TRnQContact): Boolean;
function try_load_or_req_avatar(cnt: TRnQContact): Boolean;
begin
  Result := false;
  if not Assigned(cnt) then
    Exit;
  {$IFDEF PROTOCOL_ICQ}
  if cnt.Proto is TicqSession then
    begin
     if not TicqSession(cnt.Proto).AvatarsSupport then
       exit;
     Result := RnQ_Avatars.try_load_avatar(cnt, TICQContact(cnt).ICQIcon.Hash,
                     cnt.Icon.hash_safe);
     if not Result then
       Result := TicqSession(cnt.Proto).RequestIcon(TICQContact(cnt));
    end
   else
  {$ENDIF PROTOCOL_ICQ}
  {$IFDEF PROTOCOL_BIM}
  if cnt.Proto is TBIMSession then
    begin
     Result := RnQ_Avatars.try_load_avatar(cnt, TBIMContact(cnt).BIMIcon.Hash,
                     TBIMContact(cnt).BIMIcon.hash_safe);
     if not Result then
       Result := TBIMSession(cnt.Proto).RequestIcon(TBIMContact(cnt));
    end;
  {$ENDIF PROTOCOL_BIM}
  {$IFDEF PROTOCOL_XMP}
  if cnt.Proto is TxmppSession then
    begin
//     if not TxmppSession(cnt.fProto).AvatarsSupport then
//       exit;
     Result := RnQ_Avatars.try_load_avatar(cnt, TxmppContact(cnt).XIcon.Hash,
                     cnt.Icon.hash_safe);
     if not Result then
       Result := TxmppSession(cnt.Proto).RequestIcon(TxmppContact(cnt));
    end
   else
  {$ENDIF PROTOCOL_XMP}
  {$IFDEF PROTOCOL_WIM}
  if cnt.Proto is TWIMSession then
    begin
     if not TWIMSession(cnt.Proto).AvatarsSupport then
       exit;
     Result := RnQ_Avatars.try_load_avatar(cnt, TWIMContact(cnt).IconID,
                     cnt.Icon.hash_safe);
     if not Result then
       begin
         DownloadAvtByHash(TWIMContact(cnt));
         Result := True;
       end;
    end
   else
  {$ENDIF PROTOCOL_WIM}
end;

procedure Process_InfoRetrives;
begin
 {$IFDEF PROTOCOL_ICQ}
//  if (Account.AccProto.ProtoElem.ProtoID = ICQProtoID) then
  if (Account.AccProto is TicqSession) then
   begin
    if assigned(retrieveQ) and (Account.AccProto.isOnline) and not retrieveQ.empty then
    begin
     TicqSession(Account.AccProto).sendSimpleQueryInfo(retrieveQ.getAt(0).uid);
     retrieveQ.delete(0);
     saveListsDelayed := True;
//     saveRetrieveQ;
    end;
   end;
 {$ENDIF PROTOCOL_ICQ}
end;

procedure Process_xStatusRetrives;
begin
 {$IFDEF PROTOCOL_ICQ}
  if (Account.AccProto is TicqSession) then
   begin
    if assigned(reqXStatusQ) and not reqXStatusQ.empty and Assigned(Account.AccProto)
       and Account.AccProto.isOnline then
     begin
       TicqSession(Account.AccProto).RequestXStatus(reqXStatusQ.getAt(0).UID);
       reqXStatusQ.delete(0);
     end;
   end;
 {$ENDIF PROTOCOL_ICQ}
end;

function  Proto_Outbox_add(kind: Integer; dest: TRnQContact; flags: integer=0; const info: string=''): Toevent;
//var
//  pr: TRnQProtocol;
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

function  Proto_Outbox_add(kind: Integer; dest: TRnQContact; flags: integer; cl: TRnQCList): Toevent;
//var
//  pr: TRnQProtocol;
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

procedure getTrayIconTip(var vPic: TPicName; var vTip: String);
var
  e: Thevent;
//  nIco: String;
//  IcoDtl: TRnQThemedElementDtls;
//  IcoPicName: TPicName;
//  s: string;
  MyInf: TRnQContact;
begin
  vPic := PIC_CLIENT_LOGO;
  vTip := Application.Title;
  if BossMode.isBossKeyOn then
   begin
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
          vTip := getTranslation('Connecting');
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
      vTip := getTranslation('%s [%s]', [vTip, MyInf.displayed +' / '+ MyInf.uin2Show])
    else
      vTip := 'R&&&Q';
   end
  else
    begin
     e := eventQ.top;
     if Assigned(e) then
      begin
       if blinking or Account.AccProto.getStatusDisable.blinking then
  //       nIco:=e.pic
//         IcoDtl.picName := e.pic
         vPic := e.pic
        else
         vPic := PIC_EMPTY;
       if (e.who=NIL)or(not (e.who is Trnqcontact)) then
         vTip := getTranslation(Str_Error)
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
  result:= c.Proto.addContact(c, isLocal);
  if not result then
    exit;
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
