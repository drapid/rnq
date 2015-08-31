unit MRAv1;
{$I Compilers.inc}
{$I RnQConfig.inc}

interface
uses
   Windows, Classes, RnQProtocol, MRA_proto, RnQNet, MRAContacts, flap,
   WinSock;
type
  TmsgID = Integer;
  TmraEvent=(
    IE_error,
    IE_online,
    IE_offline,
    IE_oncoming,
    IE_offgoing,
    IE_userinfo,
    IE_userinfoCP,
    IE_msg,
    IE_email,
    IE_webpager,
    IE_fromMirabilis,
    IE_contacts,
    IE_numOfContactsChanged,
		IE_wpEnd,
    IE_userSimpleInfo,
    IE_statusChanged,
    IE_authReq,
    IE_auth,
    IE_authDenied,
    IE_url,
    IE_gcard,
    IE_wpResult,
    IE_addedYou,
    IE_visibilityChanged,
    IE_toofast,

    IE_connecting,
    IE_connected,
    IE_loggin,
    IE_redirecting,
    IE_redirected,
    IE_almostOnline,

//    IE_serverConnecting,
    IE_serverConnected,
    IE_serverDisconnected,
    IE_serverSent,
    IE_serverGot,
    IE_dcConnected,
    IE_dcDisconnected,
    IE_dcSent,
    IE_dcGot,
    IE_dcError,

    IE_creatingUIN,
    IE_newUin,
    //s@x
    IE_ackImage,
    IE_getImage,
    //\\
    IE_uinDeleted,
    IE_myinfoACK,
    IE_pwdChanged,
    IE_pause,
    IE_ack,
    IE_automsgreq,
    IE_sendingAutomsg,
    IE_endOfOfflineMsgs,
    IE_serverAck,
    IE_msgError,
    IE_Missed_MSG,
    IE_sendingXStatus,
    IE_ackXStatus,
    IE_XStatusReq,

    IE_fileReq,
    IE_fileOk,
    IE_fileDenied,
    IE_fileack,
    IE_fileabort,
    IE_fileDone,
    IE_contactupdate,
    IE_redraw,
    IE_typing,

    IE_getAvtr,
    IE_avatar_changed,
    IE_srvSomeInfo,
// In MRA
    IE_email_cnt,
    IE_email_mpop
  );

  TmraError=(
    EC_rateExceeded,
    EC_cantConnect,
    EC_socket,
    EC_other,
    EC_badUIN,           // at login-time, referred to my own uin
    EC_missingLogin,
    EC_anotherLogin,
    EC_serverDisconnected,
    EC_badPwd,
    EC_cantChangePwd,
    EC_loginDelay,
    EC_cantCreateUIN,
    EC_invalidFlap,
    EC_badContact,
    EC_cantConnect_dc,
    EC_proxy_error,
    EC_proxy_badPwd,
    EC_proxy_unk         // unknown reply
  );

const
  mraError2str:array [TmraError] of string=(
    'Server says you''re reconnecting too fastly, try later or change user.', //'rate exceeded',
    'Cannot connect\n[%d]\n%s',         // 'can''t connect',
    'Disconnected\n[%d]\n%s',           // 'disconnected',
    'Unknown error',                // 'unknown',
    'Your uin is not correct',      // 'incorrect uin',
    'Missing password',             // 'missing pwd',
    'Your current UIN is used by someone else right now, server disconnected you', //'another login',
    'Server disconnected',          // 'server disconnected',
    'Wrong password, correct it and try again\n%s', // 'wrong pwd',
    'Cannot change password',       // 'can''t change pwd',
    'Server is sick, wait 2 seconds and try again',   // 'delay',
    'Can''t create UIN',            //'can''t create uin',
    'FLAP level error',             // 'invalid flap',
    'Queried contact is invalid',   // 'bad contact',
    'can''t directly connect\n[%d]\n%s',
    'proxy: error',
    'PROXY: Invalid user/password', // 'proxy: wrong user/pwd',
    'PROXY: Unknown reply\n[%d]\n%s'      // 'proxy: unk'
  );

  maxRefs=2000;
type
  TwpResult=record
      uin    : TUID;
      nick, first, last:string;
      StsMSG : String;
      authRequired:boolean;
//      status:byte;  // 0=offline 1=online 2=don't know
      gender : byte;
      status : word;  // 0=offline 1=online 2=don't know
      age    : word;
//      BaseID : Word;
      BDay   : TDateTime;
    end; // TwpResult

  TwpSearch=record
//    Token : String;
    email : AnsiString;
    nick,first,last : string;
    gender : byte;
    country:word;
    city_id : Integer;
    ageFrom, ageTo:integer;
    onlineOnly:boolean;
//    wInterest : Word;
    end; // TwpSearch

type
  TMRASession=class;

  TmraNotify=procedure (Sender:TMRASession; event:TmraEvent) of object;

  TmraPhase=(
    null_,               // offline
    connecting_,         // trying to reach the login server
    login_,              // performing login on login server
    reconnecting_,       // trying to reach the service server
    relogin_,            // performing login on service server
    settingup_,          // setting up things
    online_

//    creating_uin_      // asking for a new uin
  );
  TrefKind=(
    REF_null,
    REF_wp,
    REF_query,
    REF_simplequery,
    REF_savemyinfo,
    REF_file,
    REF_status,
    REF_msg,
    REF_contacts,
    REF_auth,
    REF_sms,
    REF_addcontact
  );


  TMRASession = class (TRnQProtocol, IRnQProtocol)
   public
//    const ContactType : TRnQContactType =  TICQContact;
//    type ContactType = TICQContact;
    const ContactType : TClass =  TMRAContact;
   protected
        FRefCount: Integer;
        function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
        function _AddRef: Integer; stdcall;
        function _Release: Integer; stdcall;
   private
    phase              : TmraPhase;
    FLAPseq            : word;
    startingStatus     : byte;
//    SNACref            : TmsgID;
    Q                  : TMRAflapQueue;
    refs               :array [1..maxRefs] of record
                          kind:TrefKind;
                          cnt : TMRAContact;
                        end;

    serviceServerAddr   : AnsiString;
    serviceServerPort   : AnsiString;
    spamList,
    aVisibleList,
    aInvisibleList,
    tempVisibleList,
    aRoaster           : TRnQCList;
    P_pwd              : ShortString;
    function  getPwd : ShortString;
    procedure setPwd(value:ShortString);
    procedure setVisibility(vis : TMRAvisibility);
//    function  addRef(k:TrefKind; uin:TUID):integer;
    function  addRef(k:TrefKind; cnt: TMRAContact): TmsgID;

    procedure connected(Sender: TObject; Error: Word);
    procedure proxy_connected;
    procedure OnProxyError(Sender : TObject; Error : Integer; Msg : String);
    procedure onDataAvailable(Sender: TObject; Error: Word);
    procedure received(Sender: TObject; Error: Word; pkt : AnsiString);
    procedure disconnected(Sender: TObject; Error: Word);
//    procedure sendPkt(s:AnsiString);
    function  sendPkt(MsgType: Cardinal; s: AnsiString='') : cardinal; OverLoad;
    procedure sendPkt(MsgType: Cardinal; FromIP: TInAddr; FromPort: Cardinal; s: AnsiString); OverLoad;

    procedure parse_MyInfo(const pkt : AnsiString);
    procedure parse_SSI(pkt : AnsiString);
    procedure parse_Msg(const pkt : AnsiString);
    procedure parse_Ack(const pkt : AnsiString; seq : Integer);
    procedure parse_CntAddAck(pkt : AnsiString; seq : Integer);
    procedure parse_Status(const pkt : AnsiString);
    procedure Parse_offlineMsg(pkt : AnsiString);
    procedure parse_auth(const pkt : AnsiString);
    procedure parse_Anketa(const pkt : AnsiString; seq : Integer);
   public
    listener           : TmraNotify;
//    aProxy               : Tproxy;
//    loginServerAddr     : AnsiString;
//    loginServerPort     : AnsiString;
//    sock                : TRnQSocket;
//    MyInfo0             : TMRAContact;
    curStatus           : TMRAstatus;
    fVisibility         : TMRAvisibility;
//    curXStatus          : Byte;
    curXStatus : record
         idx : byte;
         id : AnsiString;
         Name, Desc : String;
       end;

    MailsCntAll         : Integer;
    MailsCntUnread      : Integer;

    // used to pass valors to listeners
    eventError          : TmraError;
    eventMsg            : String;
    eventAddress        : string;
    eventName           : string;
    eventData           : AnsiString;
    eventOldStatus      : byte;
    eventOldInvisible   : boolean;
    eventInt            :integer;    // multi-purpose
    eventFlags          :dword;
    eventTime           :TdateTime;  // in local time
    eventMsgID          : TmsgID;
    eventStream         : TMemoryStream;
    eventContact        : TMRAContact;
    eventContacts       : TRnQCList;
    eventWP             :TwpResult;

        procedure AfterConstruction; override;
        procedure BeforeDestruction; override;
        class function NewInstance: TObject; override;
        property RefCount: Integer read FRefCount;

    class function _GetProtoName: string; OverRide;
    class function _isValidUid(var uin:TUID):boolean; OverRide;
    class function _getDefHost : Thostport; OverRide;
    class function _getContactClass : TRnQCntClass; OverRide;
    class function _getProtoServers : String; OverRide;
//    function isValidUid(var uin:TUID):boolean;
//    function getContact(uid : TUID) : TRnQContact;
    class function getMRAContact(const uid : TUID) : TMRAContact;

    function ProtoName : String;
    function ProtoElem : TRnQProtocol;

    function pwdEqual(const pass : String) : Boolean;

    constructor Create(id : TUID);
    destructor Destroy; override;
    procedure ResetPrefs;
    procedure Clear;
    procedure connect; overload;
//    procedure connect(createUIN:boolean; avt_session : Boolean = false); overload;
    procedure disconnect;
    function  isOnline:boolean; inline;
    function  isOffline:boolean;
    function  isReady:boolean;     // we can send commands
    function  isConnecting:boolean;
    function  getStatus: byte;
    procedure setStatus(st: byte); overload;
//    procedure setStatusStr(stID : AnsiString; stCap, stDesc : String);
    procedure setStatusStr(stID : AnsiString; stStr : TXStatStr);
    function  getVisibility : byte;
    function  IsInvisible : Boolean;
    function  getStatusName: String;
    function  getStatusImg : AnsiString;

    function  imVisibleTo(c:TRnQContact):boolean;
    function  maxCharsFor(c:TRnQContact):integer;
    function  getClientPicFor(c:TRnQContact) : AnsiString;
    function  isMyAcc(c : TRnQContact) : Boolean;

    // manage contact lists
    function  readList(l : TLIST_TYPES):TRnQCList;
    procedure AddToList(l : TLIST_TYPES; cl:TRnQCList); overLoad;
    procedure RemFromList(l : TLIST_TYPES; cl:TRnQCList); OverLoad;
    // manage contacts
    procedure AddToList(l : TLIST_TYPES; cnt:TRnQContact); OverLoad;
    procedure RemFromList(l : TLIST_TYPES; cnt:TRnQContact); OverLoad;

    function  addContact(c:TRnQContact; isLocal : Boolean = false):boolean;
    function  removeContact(cnt:TRnQContact):boolean;

    function  validUid(var uin:TUID):boolean;
//    function  getContact(uid : TUID) : TRnQContact;

    function  sendMsg(cnt : TRnQContact; var flags:dword; msg:string; var requiredACK:boolean):integer; // returns handle
    function  SendSMS(cnt : TRnQContact; phnN : AnsiString; msg : String) : Integer;
    procedure AuthGrant(Cnt : TRnQContact);
    procedure AuthRequest(cnt : TRnQContact; reason : String);
    procedure UpdateGroupOf(cnt : TRnQContact);
    procedure RequestMPOP_SESSION;
    procedure sendWPsearch(wp:TwpSearch; idx : Integer);

    procedure sendAck(mail : AnsiString; id : TmsgID);
    // event managing

    procedure InputChangedFor(cnt :TRnQContact; InpIsEmpty : Boolean; timeOut : boolean = false);
    function  compareStatusFor(cnt1, Cnt2 : TRnqContact) : Smallint;

    function  getMyInfo : TRnQContact;
//    procedure setMyInfo(cnt : TRnQContact);
    function  getContactClass : TRnQCntClass;
    function  getContact(const UID : TUID) : TRnQContact;
    function  getStatuses : TStatusArray;
    function  getVisibilitis : TStatusArray;
    function  getStatusMenu : TStatusMenu;
    function  getVisMenu    : TStatusMenu;
    function  getStatusDisable : TOnStatusDisable;
    property  pwd:ShortString  read getPwd write setPwd;
//    property  statuses : TStatusArray read getStatuses;
    property  visibility : TMRAvisibility read fVisibility write setVisibility;


   public
     OfflMsgs : array of Int64;
    procedure sendReqOfflineMsgs;
    procedure sendDeleteOfflineMsgs;
    procedure sendKeepalive;
    procedure sendStatusCode;
    procedure SSI_updateContact(c : TMRAContact);
    procedure ReqUserInfo(cnt : TRnQContact);
   protected
    procedure goneOffline; // called going offline
    // event managing
    procedure notifyListeners(ev:TmraEvent);

    procedure SSIAddContact(c : TMRAContact; reason : String = '');
    function  GetCurStatCode : AnsiString;
//    procedure SSIdeleteContact(c : TMRAContact);
  end;
{
  TMRAHelper = class(TRnQProtoHelper)
//    constructor Create; Virtual; Abstract;
//    destructor Destroy; Virtual; Abstract;
//    const ContactType : TRnQContactType =  TICQContact;
//    class function GetId: Word; virtual; abstract;
    function GetProtoName: string; OverRide;
    function isValidUid(var uin:TUID):boolean; OverRide;
    function GetClass : TRnQProtoClass; OverRide;
//    class function getProtoByUID(uid : TUID) : TRnQProtoClass;
  end;
}

var
  MRAstatuses, MRAVis : TStatusArray;
  statMenu, mraVisMenu : TStatusMenu;
//  onStatusDisable :array [TMRAstatus] of TOnStatusDisable;

implementation
   uses
     SysUtils, OverbyteIcsWSocket, StrUtils, RQUtil, RQGlobal,
     RnQLangs, RnQStrings, RQThemes,
     globalLib, themesLib, groupsLib;
{ TMRASession }

procedure TMRASession.AddToList(l: TLIST_TYPES; cl: TRnQCList);
begin

end;

procedure TMRASession.AddToList(l: TLIST_TYPES; cnt: TRnQContact);
begin
 case l of
   LT_ROASTER:   addContact(cnt);
   LT_VISIBLE:   //add2visible(TICQContact(cnt));
          begin
            if not isReady then
              Exit;
            if not aVisibleList.exists(cnt) then
             begin
              aVisibleList.add(cnt);
              aInvisibleList.remove(cnt);
              SSI_updateContact(TMRAContact(cnt));
              eventCOntact:= TMRAContact(cnt);
              notifyListeners(IE_visibilityChanged);
             end;
          end;
   LT_INVISIBLE: //add2invisible(TICQContact(cnt));
          begin
            if not isReady then
              Exit;
            if not aInvisibleList.exists(cnt) then
             begin
              aInvisibleList.add(cnt);
              aVisibleList.remove(cnt);
              SSI_updateContact(TMRAContact(cnt));
              eventCOntact:= TMRAContact(cnt);
              notifyListeners(IE_visibilityChanged);
             end;
          end;
   LT_TEMPVIS:   Exit;//addTemporaryVisible(TICQContact(cnt));
   LT_SPAM:      //add2ignore(TICQContact(cnt));
          begin
            if not isReady then
              Exit;
            if not spamList.exists(cnt) then
             begin
              spamList.add(cnt);
              SSI_updateContact(TMRAContact(cnt));
              eventCOntact:= TMRAContact(cnt);
              notifyListeners(IE_visibilityChanged);
             end;
          end;
 end;
end;

function TMRASession.compareStatusFor(cnt1, Cnt2: TRnqContact): Smallint;
begin
  if StatusPriority[TMRAContact(cnt1).status] < StatusPriority[TMRAContact(Cnt2).status] then
    result := -1
  else if StatusPriority[TMRAContact(cnt1).status] > StatusPriority[TMRAContact(Cnt2).status] then
    result := +1
  else
    Result := 0;
end;

function TMRASession.addRef(k:TrefKind; cnt: TMRAContact): TmsgID;
begin
result:= FLAPseq;
refs[FLAPseq].kind:=k;
refs[FLAPseq].cnt:= cnt;
{
inc(SNACref);
if SNACref > maxRefs then
  SNACref:=1;}
end; // addRef


procedure TMRASession.connect;
begin
 if not isOffline then exit;
// if (not avt_session) then
  if (P_pwd = '') or (MyAccount='') then
  begin
   eventError:=EC_missingLogin;
   notifyListeners(IE_error);
   exit;
  end;
 sock.proto:='tcp';
 sock.addr:=loginServerAddr;
 sock.port:=loginServerPort;

 phase := connecting_;
 FLAPseq := 1;
// SNACref := 1;
 eventAddress := sock.addrPort;
 notifyListeners(IE_connecting);
 try
  sock.Connect
 except
  on E:Exception do
   begin
     eventMsg := E.Message;
     eventError:=EC_cantconnect;
     eventInt:=WSocket_WSAGetLastError;
     notifyListeners(IE_error);
     goneOffline;
   end
  else
   begin
    eventMsg := '';
    eventError:=EC_cantconnect;
    eventInt:=WSocket_WSAGetLastError;
    eventMsg := WSocketErrorDesc(eventInt);
    notifyListeners(IE_error);
    goneOffline;
   end;
 end;

end;


procedure TMRASession.disconnect;
begin
 q.reset;
 sock.close;
 goneOffline;
end;

procedure TMRASession.connected(Sender: TObject; Error: Word);
begin
  eventTime := now;
  if error <> 0 then
  begin
    goneOffline;
    eventInt:=WSocket_WSAGetLastError;
    if eventInt=0 then
     eventInt:=error;
    eventMsg := WSocketErrorDesc(eventInt);
    eventError := EC_cantconnect;
    notifyListeners(IE_error);
    exit;
  end;
  eventAddress:=sock.Addr;
  notifyListeners(IE_serverConnected);
  proxy_connected;
end;

procedure TMRASession.disconnected(Sender: TObject; Error: Word);
begin
q.reset;
eventAddress:=sock.addr;
eventMsg := '';
notifyListeners(IE_serverDisconnected);
if error <> 0 then
  begin
  goneOffline;
  eventInt:=WSocket_WSAGetLastError;
//  GetWinsockErr
  if eventInt=0 then eventInt:=error;
  eventMsg := WSocketErrorDesc(eventInt);
  eventError:=EC_socket;
  notifyListeners(IE_error);
  exit;
  end;
//if (phase<>login_) then
//if (phase<>relogin_) then
if (phase<>reconnecting_) then
  goneOffline;
end;

procedure TMRASession.onDataAvailable(Sender: TObject; Error: Word);
var
  pkt : AnsiString;
begin
  pkt := sock.ReceiveStr;
  received(sender, Error, pkt);
end;

procedure TMRASession.OnProxyError(Sender: TObject; Error: Integer;
  Msg: String);
begin
 if error <> 0 then
  begin
    goneOffline;
//    eventInt:=WSocket_WSAGetLastError;
//    if eventInt=0 then
     eventInt:=error;
    eventMsg := msg;
    eventError:=EC_cantconnect;
    notifyListeners(IE_error);
//  exit;
  end;
end;

procedure TMRASession.proxy_connected;
begin
{if creatingUIN then
  begin
  phase:=creating_uin_;
  notifyListeners(IE_connected);
  end
else}
  case phase of
    connecting_:
      begin
      phase:=login_;
      notifyListeners(IE_connected);
      end;
    reconnecting_:
      begin
       phase:=relogin_;
       notifyListeners(IE_redirected);
       sendPkt(MRIM_CS_HELLO);
      end;
    end
end;

procedure TMRASession.received(Sender: TObject; Error: Word; pkt: AnsiString);
var
//  channel,
  ref:integer;
//  flags : Word;
//  oldVis : Tvisibility;
  service:TsnacService;
  ofs : Integer;
begin
  if phase = login_ then
   begin
     eventData:=pkt;
     notifyListeners(IE_serverSent);
     pkt := chopline(pkt);
     serviceServerAddr := chop(':', pkt);
     serviceServerPort := pkt;
     phase := reconnecting_;
      sock.close;
      sock.WaitForClose;  // prevent to change properties while the socket is open
        begin
        sock.addr:=serviceServerAddr;
        sock.port:=serviceServerPort;
        end;
      phase:=RECONNECTING_;
      eventAddress := sock.addrPort;
      notifyListeners(IE_redirecting);
      sock.Connect;
      Exit;
   end;
Q.add(pkt);
if Q.error then
  begin
  eventData:=q.popError;
  eventError:=EC_invalidFlap;
  notifyListeners(IE_error);
  disconnect;
  end;
while Q.available do
  begin
  pkt:=Q.pop;
  eventData:=pkt;
  notifyListeners(IE_serverSent);
{
  channel:=getFlapChannel(pkt);
  if channel = SNAC_CHANNEL then
    begin
    service:= getSnacService(pkt);
    ref    := getSnacRef(pkt);
    flags  := getSnacFlags(pkt);
    delete(pkt,1,16);  // remove header
    end
  else
    begin
    service:=0;
    ref:=0;
    flags := 0;
    delete(pkt,1,6);  // remove header
    end;
}
    service:= getMRASnacService(pkt);
    ref    := getMRASnacRef(pkt);
//    flags  := getMRASnacFlags(pkt);
    delete(pkt,1, SizeOf(mrim_packet_header_t));  // remove header
  case phase of
    relogin_:
      case service of
        MRIM_CS_HELLO_ACK:
              begin
                ofs := 1;
                keepalive.enabled := True;
                keepalive.freq := readINT(pkt, ofs);
//                if startingStatus = x then

                sendPkt(MRIM_CS_LOGIN2, Length_DLE(MyAccount)+
                                      Length_DLE(P_pwd)+
{                                      dword_LEasStr(MRAstatus2code[TMRAStatus(startingStatus)])+
                          Length_DLE('STATUS_ONLINE')+

                          Length_DLE(StrToUnicodeLE('Online'))+
                          Length_DLE('')+
                          dword_LEasStr($3FF)+}
                          GetCurStatCode+ 
                           Length_DLE('client="R&Q" version="11" build="'+IntToStr(RnQBuild)+'"')+
                          Length_DLE('ru')+
                          Length_DLE('R&Q ' + IntToStr(RnQBuild))
                       );
              end;
        MRIM_CS_LOGIN_ACK:
              begin
//                MyInfo.status := TMRAStatus(startingStatus);
                curStatus := TMRAStatus(startingStatus);
                phase := online_;
                notifyListeners(IE_online);
              end;
        MRIM_CS_LOGIN_REJ:
              begin
                ofs := 1;
                eventMsg := getDLS(pkt, ofs);
                eventError := EC_badPwd;
                notifyListeners(IE_error);
              end;
      end;
     online_:
       case service of
         MRIM_CS_USER_INFO: parse_MyInfo(pkt);
         MRIM_CS_CONTACT_LIST2: parse_SSI(pkt);
         MRIM_CS_ADD_CONTACT_ACK: parse_CntAddAck(pkt, ref);
         MRIM_CS_MESSAGE_ACK: parse_Msg(pkt);
         MRIM_CS_MESSAGE_STATUS: parse_Ack(pkt, ref);
         MRIM_CS_USER_STATUS: parse_Status(pkt);
         MRIM_CS_OFFLINE_MESSAGE_ACK: Parse_offlineMsg(pkt);
         MRIM_CS_AUTHORIZE_ACK: parse_auth(pkt);
         MRIM_CS_ANKETA_INFO: parse_Anketa(pkt, ref);
         MRIM_CS_MAILBOX_STATUS:
              begin
                ofs := 1;
                MailsCntUnread := readINT(pkt, ofs);
                eventInt := MailsCntUnread;
                notifyListeners(IE_email_cnt);
              end;
         MRIM_CS_GET_MPOP_SESSION_ACK:
              begin
                ofs := 1;
                eventInt := readINT(pkt, ofs);
                if eventInt = MRIM_GET_SESSION_SUCCESS then
                  begin
                    eventData := getDLS(pkt, ofs);
                    notifyListeners(IE_email_mpop);
                  end;
              end;
       end;
  end;
  end;
end;

procedure TMRASession.Clear;
begin
  MyAccount := '';
//  myinfo0:=NIL;
  readList(LT_ROASTER).clear;
  readList(LT_VISIBLE).Clear;
  readList(LT_INVISIBLE).Clear;
  readList(LT_TEMPVIS).Clear;
  readList(LT_SPAM).Clear;

  FreeAndNil(eventContacts);
  eventContact := NIL;
end;

constructor TMRASession.create(id : TUID);
begin
  inherited create;
  phase:=null_;
  listener:=NIL;
  curStatus := SC_OFFLINE;
  fVisibility := mVI_normal;
  curXStatus.idx := 0;
  curXStatus.id := '';
  curXStatus.Name := '';
  curXStatus.Desc := '';
  startingStatus := 0;

  if id='' then
    begin
      MyAccount := '';
//      myinfo0   := NIL
    end
   else
    begin
//      myinfo0   := getMRAContact(id);
//      MyAccount := myinfo0.UID2cmp;
//      MyAccount := getMRAContact(id).UID2cmp;
      MyAccount := TMRAContact.trimUID(id);
    end;
  P_pwd:='';
//  SNACref:=1;
//  FLAPseq:=$6700+random($100);
  FLAPseq := 1;
sock:=TRnQSocket.create(NIL);
sock.OnSessionConnected := connected;
sock.OnDataAvailable    := onDataAvailable;
sock.OnDataReceived     := received;
sock.OnSessionClosed    := disconnected;
sock.OnSocksError       := OnProxyError;
  with _getDefHost do
   begin
    loginServerAddr     := host;
    loginServerPort     := IntToStr(port);
   end;
Q := TMRAflapQueue.create;
aRoaster        := TRnQCList.create;
aVisibleList    := TRnQCList.create;
aInvisibleList  := TRnQCList.create;
tempVisibleList := TRnQCList.create;
spamList        := TRnQCList.Create;

end;

destructor TMRASession.Destroy;
begin
Q.free;
sock.free;
aRoaster.free;
aVisibleList.free;
aInvisibleList.free;
tempvisibleList.free;
spamList.Free;
  inherited;
end;

function TMRASession.getClientPicFor(c: TRnQContact): AnsiString;
var
  i, k : Integer;
  str : AnsiString;
begin
  if c is TMRAContact then
   begin
     i := Pos('client=', TMRAContact(c).ClientID);
     str := '';
     if i > 0 then
      begin
        k := PosEx('" ', TMRAContact(c).ClientID, i+8);
        if k > 0 then
          str := copy(TMRAContact(c).ClientID, i+8, k);
      end;
     if str > '' then
       if str = 'R&Q' then
        Result := PIC_RNQ;

     if Length(Result) = 0 then
       result := PIC_CLI_MAGENT;
   end
  else
   result := PIC_CLI_MAGENT;
end;

class function TMRASession.getMRAContact(const uid: TUID): TMRAContact;
begin
  result := TMRAContact(contactsDB.get(TMRAContact, uid));
end;

function TMRASession.getMyInfo: TRnQContact;
begin
//  result := MyInfo0;
  Result := contactsDB.get(TMRAContact, MyAccount);
end;

function TMRASession.isMyAcc(c : TRnQContact) : Boolean;
begin
//  result := MyInfo0.Equals(c);
  Result := Assigned(c) and c.equals(MyAccount);
end;

function TMRASession.getPwd: ShortString;
begin
  Result := P_pwd;
end;

class function TMRASession._getContactClass : TRnQCntClass;
begin
  Result := TMRAContact;
end;
function TMRASession.getContactClass : TRnQCntClass;
begin
  Result := TMRAContact;
end;
function TMRASession.getContact(const UID : TUID) : TRnQContact;
begin
  result := TMRASession.getMRAContact(uid);
end;

class function TMRASession._GetProtoName: string;
begin
  result := 'MRA';
end;

class function TMRASession._isValidUid(var uin: TUID): boolean;
begin
  result := (copy(uin,1,4)=MRAprefix) and (
            AnsiEndsText('@mail.ru', uin)
         or AnsiEndsText('@bk.ru', uin)
         or AnsiEndsText('@list.ru', uin)
         or AnsiEndsText('@inbox.ru', uin)
         or AnsiEndsText('@corp.mail.ru', uin));
  if Result then
      begin
        uin := copy(uin, 5, length(uin));
        Result := Length(uin) > 0;
      end;
end;

class function TMRASession._getDefHost : Thostport;
begin
  Result.host := 'mrim.mail.ru';
  Result.Port := 443;
//  Result.Port := 2042;
end;

class function TMRASession._getProtoServers : String;
begin
  Result := _getDefHost.host;
end;

function TMRASession.ProtoElem : TRnQProtocol;
begin
  Result := self;
end;

function TMRASession.ProtoName : String;
begin
  Result := _GetProtoName;
end;

function TMRASession.getStatuses: TStatusArray;
begin
  Result := MRAstatuses;
end;

function TMRASession.getVisibilitis: TStatusArray;
begin
  Result := MRAVis;
end;

function TMRASession.getStatusMenu : TStatusMenu;
begin
  Result := TStatusMenu(statMenu);
end;

function TMRASession.getVisMenu : TStatusMenu;
begin
  Result := TStatusMenu(mraVisMenu);
end;

function TMRASession.getStatusDisable : TOnStatusDisable;
begin
  result := onStatusDisable[byte(curStatus)];
end;

procedure TMRASession.goneOffline;
var
  i:integer;
begin
  if phase=null_ then exit;
  phase:=null_;
{    if assigned(myinfo) then
      begin
      myinfo.status:=SC_OFFLINE;
      myinfo.invisible:=FALSE;
      end;}
    curStatus := SC_OFFLINE;
//    fVisibility:=;
    with aRoaster do
     for i:=0 to count-1 do
      with TMRAContact(getAt(i)) do
       begin
        status:=SC_UNK;
        OfflineClear;
      end;
    if Length(OfflMsgs)>0 then
     begin
       SetLength(OfflMsgs, 0);
     end;
  notifyListeners(IE_offline);
end;

function TMRASession.imVisibleTo(c: TRnQContact): boolean;
begin
//  result := True;
     result:=(tempvisibleList.exists(c) or
         ((visibility = mVI_privacy) and (aVisibleList.exists(c)))
      or
        ((visibility = mVI_normal) and (not aInvisibleList.exists(c)))
       )
end;

procedure TMRASession.InputChangedFor(cnt: TRnQContact; InpIsEmpty,
  timeOut: boolean);
begin

end;

function TMRASession.isConnecting: boolean;
begin
//  result:=not (isOffline or isOnline)
  result:=(phase<>online_) and (phase<>null_)
end;

function TMRASession.isOffline: boolean;
begin
  result:= phase=null_
end;

function TMRASession.isOnline: boolean;
begin
  result := phase = online_;
end;

function TMRASession.isReady: boolean;
begin
  result:=phase in [SETTINGUP_,ONLINE_]
end;

function TMRASession.getStatus: byte;
begin
{  if myinfo=NIL then
    result:=byte(SC_UNK)
  else
    result:= byte(myinfo.status)}
  result:= byte(curStatus)
end;

function TMRASession.getStatusName: String;
begin
  if (XStatusAsMain and (curStatus = SC_ONLINE)) and (curXStatus.id > '') then
    begin
      if curXStatus.Name > '' then
//        result := getTranslation(Xsts)
        result := curXStatus.Name
       else
        if curXStatus.Desc > '' then
  //        result := getTranslation(Xsts)
          result := curXStatus.Desc
         else
//          result := getTranslation(XStatusArray[extSts].Caption)
            result := getTranslation(MRAstatus2ShowStr[curStatus])
    end
   else
    result := getTranslation(MRAstatus2ShowStr[curStatus])
end;

function TMRASession.getStatusImg : AnsiString;
begin
  Result := '';
  if curXStatus.id > '' then
   begin
    Result := 'mra.'+curXStatus.id;
    with theme.GetPicSize(RQteDefault, Result) do
     if (cx = 0)or(cy = 0) then
      result := '';
   end;
  if Result = '' then
   Result := MRAstatus2ImgName(curStatus, IsInvisible);
end;

procedure TMRASession.setStatus(st:byte);
begin
  if st = byte(SC_OFFLINE) then
   begin
    disconnect;
    exit;
   end;
//if (s = myinfo.status) and (inv = myinfo.invisible) then exit;
//  if (st = byte(myinfo.status)) then exit;
  if (st = byte(curStatus)) then exit;
  eventOldStatus := byte(curStatus);
  eventOldInvisible := fVisibility <> mVI_normal;
  startingStatus:=st;
//startingInvisible:=inv;
//  startingVisibility := vis;
if isReady then
  begin
//  if (vis in [VI_invisible, VI_privacy]) <> myinfo.invisible then
//    clearTemporaryVisible;
//  myStatus := st;
//  myinfo.status := tmraStatus(st);
  curStatus := tmraStatus(st);
//  myinfo.invisible := (vis in [VI_invisible, VI_privacy]);
//  sendStatusCode(False);
  sendStatusCode();
  eventContact:= NIL;
  notifyListeners(IE_statuschanged);
  end
else
  connect;
end; // setStatus

//procedure TMRASession.setStatusStr(stID : AnsiString; stCap, stDesc : String);
procedure TMRASession.setStatusStr(stID : AnsiString; stStr : TXStatStr);
//var
//  s : String;
begin
  eventContact := NIL;
//  eventInt := curXStatus;
  eventName := stID;
  eventMsg  := AnsiToUtf8(stStr.Cap);
  eventData := AnsiToUtf8(stStr.Desc);
  notifyListeners(IE_sendingXStatus);
//  title := eventName;
//  s := eventMsg;
  curXStatus.id := eventName;
  curXStatus.Name := unUtf(eventMsg);
  curXStatus.Desc := unUtf(eventData);
//  sendInfoStatus(s);
  sendStatusCode();
end;

function TMRASession.getVisibility : byte;
begin
  result:= byte(fVisibility)
end;


function TMRASession.maxCharsFor(c: TRnQContact): integer;
begin
  Result := 2500;
end;

function TMRASession.pwdEqual(const pass: String): Boolean;
begin
  result := P_pwd = pass;
end;

function TMRASession.readList(l: TLIST_TYPES): TRnQCList;
begin
// result := NIl;
//   result:=spamList;
 case l of
   LT_ROASTER:   result:=aRoaster;
   LT_VISIBLE:   result:=aVisibleList;
   LT_INVISIBLE: result:=aInvisibleList;
   LT_TEMPVIS:   result:=tempvisibleList;
   LT_SPAM:      result:=spamList;
  else
   Result := nil; 
 end;
end;

procedure TMRASession.RemFromList(l: TLIST_TYPES; cnt: TRnQContact);
begin
 case l of
   LT_ROASTER:
          begin
            if not isReady then
              Exit;
            with readList(l) do
            if exists(cnt) then
             begin
              removeContact(cnt);
//              SSI_updateContact(TMRAContact(cnt));
//              eventCOntact:= TMRAContact(cnt);
//              notifyListeners(IE_visibilityChanged);
             end;
          end;
   LT_VISIBLE, LT_INVISIBLE, LT_SPAM:
          begin
            if not isReady then
              Exit;
            with readList(l) do
            if exists(cnt) then
             begin
              remove(cnt);
              SSI_updateContact(TMRAContact(cnt));
              eventCOntact:= TMRAContact(cnt);
              notifyListeners(IE_visibilityChanged);
             end;
          end;
   LT_TEMPVIS:   Exit;//addTemporaryVisible(TICQContact(cnt));
 end;
end;

procedure TMRASession.RemFromList(l: TLIST_TYPES; cl: TRnQCList);
var
  cl1 : TRnQCList;
  cnt: TRnQContact;
begin
  if l = LT_TEMPVIS then
    Exit;
  if not isReady then
    Exit;
  cl1 := readList(l);
  cl:= cl.clone.intersect(cl1);
  cl1.remove(cl);
  cl.resetEnumeration;
  while cl.hasMore do
   begin
    cnt := TMRAContact(cl.getNext);
    SSI_updateContact(TMRAContact(cnt));
    eventCOntact:= TMRAContact(cnt);
    notifyListeners(IE_visibilityChanged);
   end;
  cl.Free; 
end;

function TMRASession.addContact(c:TRnQContact; isLocal : Boolean = false):boolean;
begin
  result:=FALSE;
  if (c=NIL)or (c.UID2cmp = '') then exit;
  result := aRoaster.add(c);
  result := result or (not isLocal and c.CntIsLocal);
// c.SSIID := 0;
 if result then
  begin
  if isReady then
    begin
//      TMRAcontact(c).status:= SC_OFFLINE;
//      TMRAcontact(c).invisible:=FALSE;
      if not isLocal then
        SSIAddContact(TMRAcontact(c))
    end;
//  if c.status = SC_OFFLINE then
//    getUINStatus(c.UID);
  eventInt:=aRoaster.count;
  notifyListeners(IE_numOfContactsChanged);
  end
 else
   begin
     UpdateGroupOf(c);
//      SSI_UpdateGroup(TICQcontact(c));      // «р€ тут!!!
   end;
  ;
end;

function TMRASession.removeContact(cnt: TRnQContact): boolean;
var
  isLocal ,delLocSrv
    : Boolean;
  c : TMRAContact;
begin
  c := TMRAContact(cnt);
  isLocal := cnt.CntIsLocal;
  delLocSrv := isLocal or not cnt.Authorized;
  result:= aRoaster.remove(cnt);
  if result then
   begin
    RemFromList(LT_VISIBLE, cnt);
    if not isLocal then
//      SSIdeleteContact(c);
      SSI_updateContact(c);
    c.status:= SC_UNK;
    c.SSIID := 0;
    c.CntIsLocal := True;
    eventInt:= aRoaster.count;
    notifyListeners(IE_numOfContactsChanged);
   end
end;

procedure TMRASession.ResetPrefs;
begin
  aProxy.proto := PP_NONE;
  aProxy.serv  := TMRASession._getDefHost;
end;

//procedure TMRASession.sendPkt(s: AnsiString);
procedure TMRASession.sendPkt(MsgType: Cardinal; FromIP: TInAddr; FromPort: Cardinal; s: AnsiString);
var
  pck : mrim_packet_header_t;
  s1 : AnsiString;
begin
 if sock.State <> wsConnected then exit;

 pck.magic :=CS_MAGIC;
 pck.proto :=PROTO_VERSION;
 pck.seq   :=FLAPseq;
 pck.msg   :=MsgType;
// pck.from:=inet_addr(pchar(FromIP));
 pck.from  := FromIP.S_addr;
 pck.fromport:=FromPort;
 FillMemory(@pck.reserved[1], 16, 0);
 pck.dlen  := Length(s);
 SetLength(s1, SizeOf(mrim_packet_header_t));
 StrLCopy(@s1[1], @pck, SizeOf(mrim_packet_header_t));
 s1 := s1 + s;
 try
   sock.sendStr(s1);
//  lastSendedFlap := now;
{  if phase=online_ then
   begin
    inc(SendedFlaps);
    if (SendedFlaps > ICQMaxFlaps)and (phase=online_)  then
      sock.Pause;
   end;}
  eventData:=s;
  notifyListeners(IE_serverGot);
  inc(FLAPseq);
  if FLAPseq = maxRefs then FLAPseq:= 1;
 except
 end;
s1:='';
//result:=TRUE;

// SetLength(FBody,0);
end;

function TMRASession.sendPkt(MsgType: Cardinal; s: AnsiString) : cardinal;
var
//  pck : mrim_packet_header_t;
  s1 : AnsiString;
begin
  Result := FLAPseq;
 if sock.State <> wsConnected then exit;
{ FillMemory(@pck, SizeOf(mrim_packet_header_t), 0);
 pck.magic :=CS_MAGIC;
 pck.proto :=PROTO_VERSION;
 pck.seq   :=FLAPseq;
 pck.msg   :=MsgType;
// pck.from:=inet_addr(pchar(FromIP));
 pck.from  := 0;
 pck.fromport:= 0;
// FillMemory(@pck.reserved[1], 16, 0);

 pck.dlen  := Length(s);
}
// SetLength(s1, SizeOf(mrim_packet_header_t));
 s1 := Dword_LEasStr(CS_MAGIC)
  +Dword_LEasStr(PROTO_VERSION)
  +Dword_LEasStr(FLAPseq)
  +Dword_LEasStr(MsgType)
  +Dword_LEasStr(length(s))
  +Dword_LEasStr(0)
  +Dword_LEasStr(0)
  +z+z+Z+Z
  +s;
// s1 := s1 + s;
 try
   sock.sendStr(s1);
//  lastSendedFlap := now;
{  if phase=online_ then
   begin
    inc(SendedFlaps);
    if (SendedFlaps > ICQMaxFlaps)and (phase=online_)  then
      sock.Pause;
   end;}
//  Result := FLAPseq;
  eventData := s1;
  notifyListeners(IE_serverGot);
  inc(FLAPseq);
  if FLAPseq >= maxRefs then
    FLAPseq:=1;
 except
 end;
s1:='';
end;

{procedure TMRASession.setMyInfo(cnt: TRnQContact);
begin
  MyInfo0 := TMRAContact(cnt);
end;
}

procedure TMRASession.setPwd(value: ShortString);
begin
  if (value<>pwd) and (length(value) <= 16) then
  if isOnline and (value > '') then
//     if messageDlg(getTranslation('Really want to change password on server?'), mtConfirmation, [mbYes,mbNo],0, mbNo, 20) = mrYes then
   else
    P_pwd := Value;
end;

procedure TMRASession.setVisibility(vis : TMRAvisibility);
begin
  if vis <> fVisibility then
   begin
     eventOldInvisible := fVisibility = mVI_privacy;
     eventOldStatus := byte(curStatus);
     fVisibility := vis;
     sendStatusCode;
//     eventContact:=myinfo;
     eventContact:= NIL;
     notifyListeners(IE_statuschanged);
   end;
//  if Assigned(myinfo) then
//    myinfo.invisible := fVisibility = mVI_privacy;
end;

function TMRASession.IsInvisible : Boolean;
begin
  Result := fVisibility = mVI_privacy;
end;

procedure TMRASession.UpdateGroupOf(cnt: TRnQContact);
begin
//  MRIM_CS_MODIFY_CONTACT
  SSI_updateContact(TMRAContact(cnt));
end;

function TMRASession.validUid(var uin: TUID): boolean;
begin
 Result := TMRASession._isValidUid(uin);
end;

function TMRASession.QueryInterface(const IID: TGUID; out Obj): HResult;
const
  E_NOINTERFACE = HResult( $80004002 );
begin
  if GetInterface( IID, Obj ) then
  begin
    Result := 0;
  end else
  begin
    Result := E_NOINTERFACE;
  end;
end;

function TMRASession._AddRef: Integer;
begin
  Result := InterlockedIncrement( FRefCount );
end;

function TMRASession._Release: Integer;
begin
  Result := InterlockedDecrement( FRefCount );
//  if Result = 0 then
//    Destroy;
end;

procedure TMRASession.AfterConstruction;
begin
// Release the constructor's implicit refcount
  InterlockedDecrement( FRefCount );
end;

procedure TMRASession.BeforeDestruction;
begin
  //if RefCount <> 0 then Error( reInvalidPtr );
end;

// Set an implicit refcount so that refcounting
// during construction won't destroy the object.
class function TMRASession.NewInstance: TObject;
begin
  Result := inherited NewInstance;
  TMRASession( Result ).FRefCount := 1;
end;


procedure TMRASession.notifyListeners(ev: TmraEvent);
begin
  if assigned(listener) then
   listener(self,ev);
end;

procedure TMRASession.parse_MyInfo(const pkt : AnsiString);
var
  fName, fValue : AnsiString;
  ofs : Integer;
begin
  ofs := 1;
  while ofs < (Length(pkt)-6) do
    begin
     fName := unUTF(getDLS(pkt, ofs));
     fValue := unUTF(getDLS(pkt, ofs));
     if fName = 'MESSAGES.TOTAL' then
       MailsCntAll := StrToIntDef(fValue, 0)
     else if fName = 'MESSAGES.UNREAD' then
       MailsCntUnread := StrToIntDef(fValue, 0)
     else if fName = 'MRIM.NICKNAME' then
//       with getMyInfo
//       MyInfo0.nick := unUTF(fValue);
//       getMyInfo.nick := unUTF(fValue);
       getMyInfo.nick := fValue;
    end;

  eventInt := MailsCntUnread;
  notifyListeners(IE_email_cnt);
end;

procedure TMRASession.parse_SSI(pkt : AnsiString);
var
  st, ofs,
  GroupsCnt  : Integer;
  GroupMask, CntMask : AnsiString;
  I: Integer;
  g_id, g_fl, srv_fl, l : Integer;
  ItemName, uid, phn : AnsiString;
  xStID, xStName, xStDesc : AnsiString;
  ItemCpt : String;
  cli : AnsiString;
  s   : AnsiString;
  ll, u : Integer;
  k: Integer;
//  gr : TGroup;
  c : TMRAContact;
  locCL, invCL, visCL : TRnQCList;
begin
  ofs := 1;
  st := readINT(pkt, ofs);
  GroupsCnt := readINT(pkt, ofs);
  GroupMask := getDLS(pkt, ofs);
  CntMask := getDLS(pkt, ofs);
  locCL := TRnQCList.Create;
  invCL := TRnQCList.Create;
  visCL := TRnQCList.Create;

  for i := Low(groups.a) to High(groups.a) do
   groups.a[i].ssiID := 0;

  l := Length(GroupMask);
  for I := 0 to GroupsCnt - 1 do
   begin
     g_fl := readINT(pkt, ofs);
     ItemName := getDLS(pkt, ofs);
     if l > 2 then
     for k := 3 to l do
       case GroupMask[k] of
        'u': u := readINT(pkt, ofs);
        's': s := getDLS(pkt, ofs);
        'z': break;
       end;
     g_id:=groups.name2id(unUTF(ItemName));
     if g_id < 0 then
       with groups do
         begin
          g_id:=add();
          with a[idxOf(g_id)] do
           begin
            ssiID := i+ MRA_GroupID_Ofs;
            name:=unUTF(ItemName);
           end;
         end
      else
        with groups do
          with a[idxOf(g_id)] do
            ssiID := i+ MRA_GroupID_Ofs;
   end;
     g_id:=groups.name2id('Phone');
     if g_id < 0 then
       with groups do
         begin
          g_id:=add();
          with a[idxOf(g_id)] do
           begin
            ssiID := 103;
            name:='Phone';
           end;
         end
      else
        with groups do
          with a[idxOf(g_id)] do
            ssiID := 103;

  l := Length(CntMask);
  i := $13;
  while ofs < Length(pkt)-l do
   begin
     g_fl   := readINT(pkt, ofs);
     g_id   := readINT(pkt, ofs);
     ItemName := getDLS(pkt, ofs);
     ItemCpt  := getDLS(pkt, ofs);
     srv_fl := readINT(pkt, ofs);
     st     := readINT(pkt, ofs);
     phn    := getDLS(pkt, ofs);
  // For 1.E
     xStID   := getDLS(pkt, ofs);
     xStName := getDLS(pkt, ofs);
     xStDesc := getDLS(pkt, ofs);
     ll := 0;
     k := 11;
     if l > k then
      begin
       case CntMask[k] of
        'u': u := readINT(pkt, ofs);
        's': s := getDLS(pkt, ofs);
        'z': break;
       end;
       cli   := getDLS(pkt, ofs);
       ll := 2;
      end;
//     if l > 7 then
//     for k := 8 to l do
     if l > 10+ll then
     for k := 11+ll to l do
       case CntMask[k] of
        'u': u := readINT(pkt, ofs);
        's': s := getDLS(pkt, ofs);
        'z': break;
       end;
     inc(i);

     if ((g_fl and CONTACT_FLAG_GROUP) > 0) then
         Continue;
     if ((g_fl and CONTACT_FLAG_MOBILE) > 0) then
//         Continue
       uid := unUTF(ItemCpt) + '@' +ItemName
      else
       uid := ItemName;
     c := getMRAContact(UID);
           if (c=NIL) then Continue;
           if c.UID='' then Continue;
//                if g_id = 0 then
//                  c.group := 2000
//                 else
                  begin
                   c.group := groups.ssi2id(g_id + MRA_GroupID_Ofs);
                   if c.group <0 then
//                    c.group := g_id;
                     c.group := 2000
                  end;
                c.SSIID := i;
//                c.CntIsLocal := False;
                c.fDisplay := unUTF(ItemCpt);
{                if FCellular > '' then
                  c.ssCell := FCellular;
                if FMail > '' then
                  c.ssMail := FMail;
                if Fnote > '' then
                  c.ssImportant := Fnote;
                c.InfoToken := FInfoToken;
}
                c.ssCells := phn;
                c.ClientID := cli; 
                c.Authorized := (srv_fl and CONTACT_INTFLAG_NOT_AUTHORIZED)=0;
                if (c.display = '') and (c.infoUpdatedTo=0) then
                  TCE(c.data^).toquery:=True
                else
                  TCE(c.data^).toquery:=false;
                c.invisible := (st and STATUS_FLAG_INVISIBLE <> 0);
                st := (st and not STATUS_FLAG_INVISIBLE);
                if st <> STATUS_USER_DEFINED then
                 begin
                   c.xStatus.id   := '';
                   c.xStatus.Name := '';
                   c.xStatus.Desc := '';
                 end;
                case st of
                 STATUS_ONLINE: c.status := SC_ONLINE;
                 STATUS_OFFLINE: c.status := SC_OFFLINE;
                 STATUS_AWAY: c.status := mSC_AWAY;
                 STATUS_USER_DEFINED:
                     begin
                       c.status := SC_ONLINE;
                       c.xStatus.id   := xStID;
                       c.xStatus.Name := unUTF(xStName);
                       c.xStatus.Desc := unUTF(xStDesc);
                     end
                else
//                 STATUS_UNDETERMINATED:
                 c.status := SC_UNK;
                end;

     if (g_fl and CONTACT_FLAG_INVISIBLE) > 0 then
      invCL.add(c);
     if (g_fl and CONTACT_FLAG_VISIBLE) > 0 then
      visCL.add(c);
     if (g_fl and CONTACT_FLAG_IGNORE) > 0 then
       if not readList(LT_SPAM).exists(c) then
         readList(LT_SPAM).add(c);
     if (g_fl and (CONTACT_FLAG_SHADOW or CONTACT_FLAG_REMOVED))=0 then
      begin
       c.CntIsLocal := False;
       notInList.remove(c);
       locCL.add(c);
      end;
   end;

  readList(LT_ROASTER).add(locCL);
//  addContact(locCL, False);
  readList(LT_VISIBLE).add(visCL);
  readList(LT_INVISIBLE).add(invCL);
  ignoreList.add(readList(LT_SPAM));
   locCL.Free;
   invCL.Free;
   visCL.Free;

 notifyListeners(IE_numOfContactsChanged);
end;


procedure TMRASession.parse_Msg(const pkt : AnsiString);
var
  ofs, i : Integer;
  mraMsgFlags : Integer;
  mail, s : AnsiString;
  c : TMRAContact;
begin
  eventTime := now;
  ofs := 1;
  eventMsgID := readINT(pkt, ofs);
  mraMsgFlags := readINT(pkt, ofs);
  mail     := getDLS(pkt, ofs);
  eventMsg := getDLS(pkt, ofs);

  if (mraMsgFlags and MESSAGE_FLAG_SYSTEM<>0) then
    begin
//      notifyListeners(IE_SYS_NOTIFY);
      exit;
    end;
  eventContact := getMRAContact(mail);
  if (mraMsgFlags and MESSAGE_FLAG_NOTIFY<>0) then
    begin
{      case eventInt of
        MTN_FINISHED, MTN_TYPED : eventContact.typing.bIsTyping := false;
        MTN_BEGUN  : eventContact.typing.bIsTyping := True;
        MTN_CLOSED : eventContact.typing.bIsTyping := False;
      end;
}
      eventInt := $0002;
      eventContact.typing.bIsTyping := True; 
//      eventContact.typing.bIsTyping := True;
      notifyListeners(IE_typing);
      exit;
    end;
  if (mraMsgFlags and MESSAGE_FLAG_OFFLINE<>0) then
    eventFlags := IF_offline
   else
    eventFlags := 0;
  if (mraMsgFlags and MESSAGE_FLAG_MULTICAST<>0) then
    eventFlags := eventFlags or IF_multiple;

  if (mraMsgFlags and MESSAGE_FLAG_NORECV=0) then
   begin
     SendAck(mail, eventMsgID);
   end;


  if (mraMsgFlags and MESSAGE_FLAG_CONTACT<>0) then
   begin
    eventContacts:=TRnQCList.create;
    s := eventMsg;
    while s > '' do
      try
        c:=getMRAContact(chop(#$FE,s));
        if isMyAcc(c) then
          chop(#$FE,s)
        else
         begin
          if Assigned(c) and not aRoaster.exists(c) then
            c.nick:=chop(#$FE,s)
           else
            chop(#$FE,s);
          eventContacts.add(c);
         end;
      except
      end;
     notifyListeners(IE_contacts);
     exit;
   end;

  if (mraMsgFlags and MESSAGE_FLAG_AUTHORIZE<>0) then
   begin
//    if mraMsgFlags and MESSAGE_FLAG_UNK1 <> 0 then
    if Length(eventMsg) > 1 then
     begin
      s := Base64Decode(eventMsg);
      i := 1;
      if Length(s) >= 12 then
       begin
        readINT(s, i);
        getDLS(s, i);
        eventMsg := getDLS(s, i);
       end;
     end;

     notifyListeners(IE_authReq);
     exit;
   end;
  eventMsg := unUTF(eventMsg);
  if Assigned(eventContact) then
    eventContact.typing.bIsTyping := false;
  notifyListeners(IE_msg);
end;

procedure TMRASession.parse_Ack(const pkt : AnsiString; seq : Integer);
var
  ofs, st : Integer;
begin
  ofs := 1;
  st := readINT(pkt, ofs);
  eventInt   := seq;
  eventMsgID := seq;
  if st = MESSAGE_DELIVERED then
    notifyListeners(IE_ack)
   else
    notifyListeners(IE_msgError);
end;

procedure TMRASession.parse_CntAddAck(pkt : AnsiString; seq : Integer);
var
  st : Integer;
  ofs : Integer;
  id  : Integer;
  cnt : TMRAContact;
begin
  ofs := 1;
  st := readINT(pkt, ofs);
  id := readINT(pkt, ofs);
  if st = CONTACT_OPER_SUCCESS then
    begin
      if (seq >= 1) and (seq <= maxRefs) and
         (refs[seq].kind=REF_addcontact) then
       begin
         cnt := refs[seq].cnt;
         if Assigned(cnt) then
          begin
           cnt.CntIsLocal := False;
           if (st <> CONTACT_OPER_USER_EXISTS)and
              (st <> CONTACT_OPER_INTERR) then
             cnt.SSIID := id;
           eventContact := cnt;
           notifyListeners(IE_contactupdate);
          end;
       end;
    end
   else
    if (st <> CONTACT_OPER_USER_EXISTS) then
     begin
      cnt.CntIsLocal := True;
      cnt.SSIID := 0;
      eventContact := cnt;
      notifyListeners(IE_contactupdate);
     end;

end;

procedure TMRASession.parse_Status(const pkt : AnsiString);
var
  st : Integer;
  ofs : Integer;
  mail, cli : AnsiString;
//  c : TMRAContact;
  xStID, xStName, xStDesc : AnsiString;
  fl : Cardinal;
begin
  ofs := 1;
  st := readINT(pkt, ofs);

  // For 1.E
     xStID   := getDLS(pkt, ofs);
     xStName := getDLS(pkt, ofs);
     xStDesc := getDLS(pkt, ofs);

  mail := getDLS(pkt, ofs);
  fl := readINT(pkt, ofs);
  cli := getDLS(pkt, ofs);

  eventContact := getMRAContact(mail);
  if Assigned(eventContact) then
   begin
    eventOldStatus := byte(eventContact.status);
    eventOldInvisible := eventContact.invisible;
    eventContact.invisible := (st and STATUS_FLAG_INVISIBLE <> 0);
    st := (st and not STATUS_FLAG_INVISIBLE);
    if st <> STATUS_USER_DEFINED then
      begin
        eventContact.xStatus.id := '';
        eventContact.xStatus.Name := '';
        eventContact.xStatus.Desc := '';
      end;
    case st of
     STATUS_ONLINE:  eventContact.status := SC_ONLINE;
     STATUS_OFFLINE: eventContact.status := SC_OFFLINE;
     STATUS_AWAY:    eventContact.status := mSC_AWAY;
     STATUS_USER_DEFINED:
        begin
          eventContact.status := SC_ONLINE;
          eventContact.xStatus.id   := xStID;
          eventContact.xStatus.Name := unUTF(xStName);
          eventContact.xStatus.Desc := unUTF(xStDesc);
//          eventContact.xStatus.id :=
        end
    else
//                 STATUS_UNDETERMINATED:
     eventContact.status := SC_UNK;
    end;
    eventContact.ClientID := cli;
    notifyListeners(IE_statusChanged);
   end;
end;

procedure TMRASession.Parse_offlineMsg(pkt : AnsiString);
var
  id : Int64;
  i, ofs : Integer;
  mraMsgFlags : Integer;
  mail : AnsiString;
  s : AnsiString;
  msg : AnsiString;
  bnd, dt : AnsiString;
  c : TMRAContact;
  isBase64 : Boolean;
begin
  ofs := 1;
//  id := readINT(pkt, ofs);
  id := readQWORD(pkt, ofs);
  if delOfflineMsgs then
    sendPkt(MRIM_CS_DELETE_OFFLINE_MESSAGE, qword_LEasStr(id))
   else
    begin
      i := Length(OfflMsgs);
      SetLength(OfflMsgs, i+1);
      OfflMsgs[i] := id;
      offlineMsgsChecked := false;
    end;

  i := pos('From: ',pkt);
  s := Copy(pkt, i+Length('From:'), MAXWORD);
  s := Trim(chop(#10, s));
  mail := s;
  eventContact := getMRAContact(mail);

  i := pos('Date: ',pkt);
  s := Copy(pkt, i+Length('Date:'), MAXWORD);
  dt := Trim(chop(#10, s));
  eventTime := now;
//  mail := s;
  i := pos('X-MRIM-Flags: ',pkt);
  s := Copy(pkt, i+Length('X-MRIM-Flags:'), MAXWORD);
  s := Trim(chop(#10, s));
  mraMsgFlags := hexToInt(s);

  eventFlags := IF_offline;
  if (mraMsgFlags and MESSAGE_FLAG_MULTICAST<>0) then
    eventFlags := eventFlags or IF_multiple;

  if (mraMsgFlags and MESSAGE_FLAG_SYSTEM<>0) then
    begin
//      notifyListeners(IE_SYS_NOTIFY);
      exit;
    end;

  isBase64 := false;
  
  i := pos('Boundary: ',pkt);
  if i > 0 then
    begin
      s := Copy(pkt, i+Length('Boundary:'), MAXWORD);
      bnd := Trim(chop(#10, s));

      i := pos('Version: ',pkt);
      s := Copy(pkt, i+Length('Version:'), MAXWORD);
      chop(#10, s);
      chop(#10, s);
    //  i := pos(bnd, s);
      msg := chop(bnd, s);
      SetLength(msg, length(msg)-3);
    end
   else
    begin
    i := pos('boundary=',pkt);
    if i > 0 then
      begin
        s := Copy(pkt, i+Length('boundary='), MAXWORD);
        bnd := Trim(chop(#10, s));

        i := pos('text/plain;',pkt);
        msg := Copy(pkt, i+Length('text/plain;'), MAXWORD);
        s := chop(bnd, msg);
        msg := '';
        i := pos('Content-Transfer-Encoding:', s);
        if i > 0 then
         begin
          if pos('Content-Transfer-Encoding: base64', s) > 0 then
            isBase64 := True;
          chop(#10, s);
         end;
        chop(#10, s);
        chop(#10, s);
      //  i := pos(bnd, s);
//        msg := chop(bnd, s);
        msg := s;
        SetLength(msg, length(msg)-3);
        if length(msg) > 0 then
         if msg[length(msg)] = #13 then
          SetLength(msg, length(msg)-1);
      end
     else
      begin
        i := pos(CRLFCRLF, pkt);
        if i > 0 then
          msg := Copy(pkt, i+Length(CRLFCRLF), MAXWORD)
         else
          msg := '';
        bnd := '';
      end;
    end;
  eventMsg := msg;

  if (mraMsgFlags and MESSAGE_FLAG_CONTACT<>0) then
   begin
    eventContacts:=TRnQCList.create;
    s := eventMsg;
    while s > '' do
      try
        c:=getMRAContact(chop(#$FE,s));
        if isMyAcc(c) then
          chop(#$FE,s)
        else
         begin
          if Assigned(c) and not aRoaster.exists(c) then
            c.nick:=chop(#$FE,s)
           else
            chop(#$FE,s);
          eventContacts.add(c);
         end;
      except
      end;
     notifyListeners(IE_contacts);
     exit;
   end;

  if (mraMsgFlags and MESSAGE_FLAG_AUTHORIZE<>0) then
   begin
//    if mraMsgFlags and MESSAGE_FLAG_UNK1 <> 0 then
    if Length(eventMsg) > 1 then
     begin
      s := Base64Decode(eventMsg);
      i := 1;
      if Length(s) >= 12 then
       begin
        readINT(s, i);
        getDLS(s, i);
        eventMsg := unUTF(getDLS(s, i));
       end;
     end;

     eventMsg := dt + CRLF+ eventMsg;
     notifyListeners(IE_authReq);
     exit;
   end
   else
    if isBase64 then
      eventMsg := unUTF(Base64Decode(eventMsg));
  eventMsg := dt + CRLF+ eventMsg;

  notifyListeners(IE_msg);
end;

procedure TMRASession.parse_auth(const pkt : AnsiString);
var
  mail : AnsiString;
  ofs : Integer;
//  c : TMRAContact;
begin
  ofs := 1;
  mail := getDLS(pkt, ofs);
  eventContact := getMRAContact(mail);
  if Assigned(eventContact) then
    begin
     eventContact.Authorized := True;
//     notifyListeners(IE_statuschanged);
     notifyListeners(IE_contactupdate);
    end;
end;

procedure TMRASession.parse_Anketa(const pkt : AnsiString; seq : Integer);
type
  TField = record
     fName, fValue : String;
   end;
  TFieldsArray = array of TField;
var
  isWPSearch : Boolean;

  procedure ParseFields(ff : TFieldsArray);
  var
    i : Integer;
//    k : Integer;
    cnt : TMRAContact;
    un, dm, s : String;
    yy, mm, dd : Integer;
  begin
    cnt := NIL;
    for i:= 0 to Length(ff) - 1 do
     begin
       if AnsiCompareText(ff[i].fName, 'USERNAME') = 0 then
         un := ff[i].fValue
       else if AnsiCompareText(ff[i].fName, 'DOMAIN') = 0 then
         begin
           dm := ff[i].fValue;
           cnt := getMRAContact(un+'@'+dm);
         end
       else if not Assigned(cnt) then Exit
       else if AnsiCompareText(ff[i].fName, 'NICKNAME') = 0 then
         cnt.nick := unUTF(ff[i].fValue)
       else if AnsiCompareText(ff[i].fName, 'FIRSTNAME') = 0 then
         cnt.first := unUTF(ff[i].fValue)
       else if AnsiCompareText(ff[i].fName, 'LASTNAME') = 0 then
         cnt.last := unUTF(ff[i].fValue)
       else if AnsiCompareText(ff[i].fName, 'SEX') = 0 then
         begin
           if ff[i].fValue = '1' then
             cnt.gender := 2 // Male
           else if ff[i].fValue = '2' then
             cnt.gender := 1 // Female
           else
             cnt.gender := 0
         end
       else if AnsiCompareText(ff[i].fName, 'Birthday') = 0 then
         begin
          if Length(ff[i].fValue) = 10 then
           try
             s := Copy(ff[i].fValue, 1, 4);
             yy := StrToIntDef(s, 0);
             s := Copy(ff[i].fValue, 6, 2);
             mm := StrToIntDef(s, 0);
             s := Copy(ff[i].fValue, 9, 2);
             dd := StrToIntDef(s, 0);
             if not TryEncodeDate(yy, mm, dd, cnt.birth) then
               cnt.birth := 0;
            except
           end
          else
           cnt.birth := 0;
         end
       else if AnsiCompareText(ff[i].fName, 'CITY_ID') = 0 then
         begin
           cnt.City_id := StrToIntDef(ff[i].fValue, 0)
         end
       else if AnsiCompareText(ff[i].fName, 'Country_id') = 0 then
         begin
           cnt.Country_id := StrToIntDef(ff[i].fValue, 0)
         end
       else if AnsiCompareText(ff[i].fName, 'LOCATION_id') = 0 then
         begin
           cnt.Location_id := StrToIntDef(ff[i].fValue, 0)
         end

       else if AnsiCompareText(ff[i].fName, 'ZODIAC') = 0 then
         begin
           cnt.zodiac := StrToIntDef(ff[i].fValue, 0)
         end

       else if AnsiCompareText(ff[i].fName, 'PHONE') = 0 then
         begin
           cnt.hisPhones := ff[i].fValue
         end

       ;
     end;
    if Assigned(cnt) then
     begin
       eventContact := cnt;
       if isWPSearch then
//         begin
         notifyListeners(IE_wpResult)
        else
         notifyListeners(IE_userinfo);
     end;
//          User:= MMP_GetLPS(@Pack, Data, Offset);
//          Domain:= MMP_GetLPS(@Pack, Data, Offset);
//          Nickname:= MMP_GetLPS(@Pack, Data, Offset);
//          FistName:= MMP_GetLPS(@Pack, Data, Offset);
//          LastName:= MMP_GetLPS(@Pack, Data, Offset);
//          Sex:= MMP_GetLPS(@Pack, Data, Offset);
//          Birth_Day:= MMP_GetLPS(@Pack, Data, Offset);
//          IDCity:= MMP_GetLPS(@Pack, Data, Offset);
//          Location:= MMP_GetLPS(@Pack, Data, Offset);
//          Zodiac:= MMP_GetLPS(@Pack, Data, Offset);
//          BirthMonth:= MMP_GetLPS(@Pack, Data, Offset);
//          BirthDay:= MMP_GetLPS(@Pack, Data, Offset);
//          IDCountry:= MMP_GetLPS(@Pack, Data, Offset);
//          Phone:= MMP_GetLPS(@Pack, Data, Offset);
//          mrim_Status:= MMP_GetLPS(@Pack, Data, Offset);
  end;
var
  st : Integer;
  ofs : Integer;
//  mail, cli : AnsiString;
//  c : TMRAContact;
//  xStID, xStName, xStDesc : AnsiString;
  i, fields, k : Integer;
  MaxRows : Integer;
  ServerTime : Integer;
  fieldsArr : TFieldsArray;
begin
  ofs := 1;
  st := readINT(pkt, ofs);
  isWPSearch := false;
  MaxRows := 0;
  if (seq >= 1) and (seq <= maxRefs) and
         (refs[seq].kind=REF_wp) then
   begin
//       isWPSearch := not Assigned(refs[seq].cnt);
       isWPSearch := True;
   end;
  if st = MRIM_ANKETA_INFO_STATUS_OK then
   begin
    fields := readINT(pkt, ofs);

    MaxRows:= readINT(pkt, ofs);
    ServerTime:= readINT(pkt, ofs);
    SetLength(fieldsArr, fields);
      for i:= 0 to fields - 1 do
       begin
         fieldsArr[i].fName := getDLS(pkt, ofs);
       end;
    k := 1;
    while (ofs < Length(pkt)-4)and(k <= MaxRows) do
    begin
      for i:= 0 to fields - 1 do
       begin
         fieldsArr[i].fValue := getDLS(pkt, ofs);
       end;
      ParseFields(fieldsArr);
      for i:= 0 to fields - 1 do
       begin
         fieldsArr[i].fValue := '';
       end;
      inc(k); 
    end;


    for i:= 0 to fields - 1 do
     begin
       fieldsArr[i].fName := '';
//       fieldsArr[i].fValue := '';
     end;
    SetLength(fieldsArr, 0);
   end
   else
  if st = MRIM_ANKETA_INFO_STATUS_NOUSER then
    begin
      MaxRows := 0;
    end;
     ;
  if isWPSearch then
      begin
        eventInt := MaxRows;
        notifyListeners(IE_wpEnd);
      end;

end;

procedure TMRASession.sendReqOfflineMsgs;
begin
end;

procedure TMRASession.sendDeleteOfflineMsgs;
var
  i,k : Integer;
begin
  k := Length(OfflMsgs);
  if k>0 then
   begin
    for I := 0 to k - 1 do
      sendPkt(MRIM_CS_DELETE_OFFLINE_MESSAGE, qword_LEasStr(OfflMsgs[i]));
    SetLength(OfflMsgs, 0);
   end;
end;

procedure TMRASession.sendKeepalive;
begin
  sendPkt(MRIM_CS_PING);
end;

function  TMRASession.GetCurStatCode : AnsiString;
var
  st1, stCode : cardinal;
  s1 : AnsiString;
begin
     if fVisibility = mVI_privacy then
       stCode := STATUS_FLAG_INVISIBLE
      else
       stCode := 0;
  if curXStatus.id = '' then
    begin
     st1 := MRAstatus2code[TMRAStatus(curStatus)] or stCode;
     s1 := Length_DLE(MRAstatus2codeStr[TMRAStatus(curStatus)])+
           dword_LEasStr(0)+
           dword_LEasStr(0)+
           dword_LEasStr($3FF);
    end
   else
    begin
     st1 := STATUS_USER_DEFINED or stCode;
     s1 := Length_DLE(curXStatus.id)+
           Length_DLE(StrToUnicodeLE(curXStatus.Name))+
           Length_DLE(StrToUnicodeLE(curXStatus.Desc))+
           dword_LEasStr($3FF);
    end;
 Result := dword_LEasStr(st1) + s1;
end;

procedure TMRASession.sendStatusCode;
//var
//  st1, stCode : cardinal;
//  s1 : AnsiString;
begin
{     if fVisibility = mVI_privacy then
       stCode := STATUS_FLAG_INVISIBLE
      else
       stCode := 0;
  if curXStatus.id = '' then
    begin
     st1 := MRAstatus2code[TMRAStatus(curStatus)] or stCode;
     s1 := Length_DLE(MRAstatus2codeStr[TMRAStatus(curStatus)])+
           dword_LEasStr(0)+
           dword_LEasStr(0)+
           dword_LEasStr($3FF);
    end
   else
    begin
     st1 := STATUS_USER_DEFINED or stCode;
     s1 := Length_DLE(curXStatus.id)+
           Length_DLE(StrToUnicodeLE(curXStatus.Name))+
           Length_DLE(StrToUnicodeLE(curXStatus.Desc))+
           dword_LEasStr($3FF);
    end;
}    
  sendPkt(MRIM_CS_CHANGE_STATUS, GetCurStatCode);
end;

function TMRASession.sendMsg(cnt : TRnQContact; var flags:dword; msg:string; var requiredACK:boolean):integer; // returns handle
var
  mraMsgFlags : Integer;
//  mail, s : AnsiString;
begin
  mraMsgFlags := 0;
  Result := sendPkt(MRIM_CS_MESSAGE, //dword_LEasStr(SNACref)+
                    dword_LEasStr(mraMsgFlags)+
                    Length_DLE(cnt.UID2cmp)+
                    Length_DLE(StrToUnicodeLE(msg))+
                    Length_DLE(' ')
                   );
//  result:=addRef(REF_msg, cnt.UID);
  requiredACK := True;
//  result := FLAPseq;
end;

function TMRASession.SendSMS(cnt : TRnQContact; phnN : AnsiString; msg : String) : Integer;
var
  mraMsgFlags : Integer;
//  mail, s : AnsiString;
begin
  mraMsgFlags := 0;
  Result := sendPkt(MRIM_CS_SMS_SEND, //dword_LEasStr(SNACref)+
                    dword_LEasStr(mraMsgFlags)+
                    Length_DLE(phnN)+
                    Length_DLE(StrToUnicodeLE(msg))
                   );
//  result:=addRef(REF_msg, cnt.UID);
//  requiredACK := True;
end;

procedure TMRASession.sendAck(mail : AnsiString; id : TmsgID);
begin
  sendPkt(MRIM_CS_MESSAGE_RECV, //dword_LEasStr(SNACref)+
                    Length_DLE(mail)+
                    dword_LEasStr(id)
                   );
end;

procedure TMRASession.AuthGrant(Cnt : TRnQContact);
begin
  sendPkt(MRIM_CS_AUTHORIZE, Length_DLE(cnt.UID2cmp));
end;

procedure TMRASession.AuthRequest(cnt : TRnQContact; reason : String);
var
  mraMsgFlags : Integer;
//  mail, s : AnsiString;
  s : AnsiString;
begin
  mraMsgFlags := MESSAGE_FLAG_AUTHORIZE;// or MESSAGE_FLAG_NORECV;
  s := dword_LEasStr(2) + Length_DLE(MyAccount)+ Length_DLE(StrToUnicodeLE(reason));

{  sendPkt(MRIM_CS_MESSAGE, //dword_LEasStr(SNACref)+
                    dword_LEasStr(mraMsgFlags)+
                    Length_DLE(cnt.UID2cmp)+
                    Length_DLE(reason)+
                    Length_DLE('')
                   );
}
  sendPkt(MRIM_CS_MESSAGE, //dword_LEasStr(SNACref)+
                    dword_LEasStr(mraMsgFlags)+
                    Length_DLE(cnt.UID2cmp)+
                    Length_DLE(Base64Encode(s))+
//                    Length_DLE('')
                    dword_LEasStr(0)
                   );


end;

procedure TMRASession.SSIAddContact(c : TMRAContact; reason : String = '');
var
  mraMsgFlags : Integer;
  s : AnsiString;

begin
  mraMsgFlags := 0;
//    Exit;
  if aVisibleList.exists(c) then
    mraMsgFlags := mraMsgFlags or CONTACT_FLAG_VISIBLE;
  if aInVisibleList.exists(c) then
    mraMsgFlags := mraMsgFlags or CONTACT_FLAG_INVISIBLE;
  if spamList.exists(c) then
    mraMsgFlags := mraMsgFlags or CONTACT_FLAG_IGNORE;

  if aRoaster.exists(c) then
   begin
    if reason = '' then
     reason := getTranslation(Str_authRequest) +
         ' ' + getMyInfo.displayed4All+
         ' UID#:' + getMyInfo.uin2Show;
    s := dword_LEasStr(2) + Length_DLE(MyAccount)+ Length_DLE(StrToUnicodeLE(reason));
   end
  else
   begin
     mraMsgFlags := mraMsgFlags or CONTACT_FLAG_SHADOW;
     s := '';
   end; 

  addRef(REF_addcontact, c);
  sendPkt(MRIM_CS_ADD_CONTACT,
                    dword_LEasStr(mraMsgFlags)+
                    dword_LEasStr(groups.id2ssi(c.group)-MRA_GroupID_Ofs)+
                    Length_DLE(c.UID2cmp)+
                    Length_DLE(StrToUnicodeLE(c.Display))+
                    Length_DLE(c.ssCells)+
                    Length_DLE(Base64Encode(s))+
                    dword_LEasStr(0)
  );
end;

{procedure TMRASession.SSIdeleteContact(c : TMRAContact);
var
  mraMsgFlags : Cardinal;
//  mail, s : AnsiString;
begin
  mraMsgFlags := CONTACT_FLAG_REMOVED;
  sendPkt(MRIM_CS_MODIFY_CONTACT,
                    dword_LEasStr(c.SSIID)+
                    dword_LEasStr(mraMsgFlags)+
                    dword_LEasStr(groups.id2ssi(c.group)-MRA_GroupID_Ofs)+
                    Length_DLE(c.UID2cmp)+
                    Length_DLE(c.Display)
  )
end;
}
procedure TMRASession.SSI_updateContact(c : TMRAContact);
var
  mraMsgFlags : Cardinal;
begin
  if c.SSIID = 0 then
    Exit;
  mraMsgFlags := 0;
//  mraMsgFlags := CONTACT_FLAG_SHADOW;
  if not aRoaster.exists(c) then
    mraMsgFlags := mraMsgFlags or CONTACT_FLAG_REMOVED;
//    Exit;
  if aVisibleList.exists(c) then
    mraMsgFlags := mraMsgFlags or CONTACT_FLAG_VISIBLE;
  if aInVisibleList.exists(c) then
    mraMsgFlags := mraMsgFlags or CONTACT_FLAG_INVISIBLE;
  if spamList.exists(c) then
    mraMsgFlags := mraMsgFlags or CONTACT_FLAG_IGNORE;

  sendPkt(MRIM_CS_MODIFY_CONTACT,
                    dword_LEasStr(c.SSIID)+
                    dword_LEasStr(mraMsgFlags)+
                    dword_LEasStr(groups.id2ssi(c.group)-MRA_GroupID_Ofs)+
                    Length_DLE(c.UID2cmp)+
                    Length_DLE(StrToUnicodeLE(c.Display))+
                    Length_DLE(c.ssCells)
  )
end;

procedure TMRASession.ReqUserInfo(cnt : TRnQContact);
var
  u, d : AnsiString;
begin
  if not Assigned(cnt) or not isReady then
    Exit;
  d := cnt.UID2cmp;
  u := chop('@', d);
//  addRef(REF_wp, TMRAContact(cnt));
  sendPkt(MRIM_CS_WP_REQUEST, dword_LEasStr(MRIM_CS_WP_REQUEST_PARAM_USER)+
                              Length_DLE(u)+
                              dword_LEasStr(MRIM_CS_WP_REQUEST_PARAM_DOMAIN)+
                              Length_DLE(d))
end;

procedure TMRASession.RequestMPOP_SESSION;
begin
  sendPkt(MRIM_CS_GET_MPOP_SESSION);
end;

procedure TMRASession.sendWPsearch(wp:TwpSearch; idx : Integer);
var
  pkt : AnsiString;
begin
  pkt := '';
  if Length(wp.nick) > 0 then
    pkt := pkt + dword_LEasStr(MRIM_CS_WP_REQUEST_PARAM_NICKNAME)+
           Length_DLE(wp.nick);
  if Length(wp.first) > 0 then
    pkt := pkt + dword_LEasStr(MRIM_CS_WP_REQUEST_PARAM_FIRSTNAME)+
           Length_DLE(wp.first);
  if Length(wp.last) > 0 then
    pkt := pkt + dword_LEasStr(MRIM_CS_WP_REQUEST_PARAM_LASTNAME)+
           Length_DLE(wp.last);
  if wp.gender > 0 then
    pkt := pkt + dword_LEasStr(MRIM_CS_WP_REQUEST_PARAM_SEX)+
           Length_DLE(IntToStr(3-wp.gender));
  if wp.country > 0 then
    pkt := pkt + dword_LEasStr(MRIM_CS_WP_REQUEST_PARAM_COUNTRY_ID)+
           Length_DLE(IntToStr(wp.country));
  if wp.ageFrom > 0 then
    pkt := pkt + dword_LEasStr(MRIM_CS_WP_REQUEST_PARAM_DATE1)+
           Length_DLE(IntToStr(wp.ageFrom));
  if wp.ageTo > 0 then
    pkt := pkt + dword_LEasStr(MRIM_CS_WP_REQUEST_PARAM_DATE2)+
           Length_DLE(IntToStr(wp.ageTo));


  if wp.onlineOnly then
    pkt := pkt + dword_LEasStr(MRIM_CS_WP_REQUEST_PARAM_COUNTRY_ID)+
           Length_DLE(IntToStr(1));
  if pkt>'' then
   begin
    addRef(REF_wp, NIL);
    sendPkt(MRIM_CS_WP_REQUEST, pkt);
   end;
end;

{function TMRAHelper.GetProtoName: string;
begin
  Result := 'ICQ';
end;
function TMRAHelper.isValidUid(var uin:TUID):boolean;
begin
  Result := TMRASession.isValidUid(uin);
end;
function TMRAHelper.GetClass : TRnQProtoClass;
begin
  Result := TMRASession;
end;
}
var
//  TZinfo:TTimeZoneInformation;
//  st1 : TMRAstatus;
  b1, b2 : Byte;
//  MRAHelper : TMRAHelper;

INITIALIZATION

//  SetLength(MRAstatuses, Byte(HIGH(TMRAstatus))+1);
  SetLength(MRAstatuses, Byte(HIGH(TMRAstatus))+1);
  for b1 := byte(LOW(TMRAstatus)) to byte(HIGH(TMRAstatus)) do
    with MRAstatuses[b1] do
     begin
      idx := b1;
      ShortName := MRAstatus2img[TMRAstatus(b1)];
      Cptn      := MRAstatus2ShowStr[TMRAstatus(b1)];
      ImageName := 'status.' + ShortName;
     end;
  setLength(statMenu, 3);
  statMenu[0] := Byte(SC_ONLINE);
//  statMenu[1] := Byte(mSC_F4C);
//  statMenu[2] := Byte(mSC_OCCUPIED);
//  statMenu[3] := Byte(mSC_DND);
  statMenu[1] := Byte(mSC_AWAY);
//  statMenu[5] := Byte(mSC_NA);
  statMenu[2] := Byte(SC_OFFLINE);

  SetLength(MRAVis, Byte(HIGH(TMRAvisibility))+1);
  for b1 := byte(LOW(TMRAvisibility)) to byte(HIGH(TMRAvisibility)) do
    with MRAVis[b1] do
     begin
      idx := b1;
      ShortName := MRAvisib2str[TMRAvisibility(b1)];
      Cptn      := MRAvisibility2ShowStr[TMRAvisibility(b1)];
//      ImageName := 'status.' + status2str[st1];
      ImageName := MRAvisibility2imgName[TMRAvisibility(b1)];
     end;
  setLength(mraVisMenu, 2);
  mraVisMenu[0] := Byte(mVI_normal);
  mraVisMenu[1] := Byte(mVI_privacy);

  RegisterProto(TMRASession);
//  MRAHelper := TMRAHelper.Create;
//  RegisterProto(MRAHelper);


FINALIZATION

  for b2 := byte(LOW(TMRAstatus)) to byte(HIGH(TMRAstatus)) do
    with MRAstatuses[B2] do
     begin
      SetLength(ShortName, 0);
      SetLength(Cptn, 0);
      SetLength(ImageName, 0);
     end;
  SetLength(MRAstatuses, 0);
  setLength(statMenu, 0);

  for b2 := byte(LOW(TMRAvisibility)) to byte(HIGH(TMRAvisibility)) do
    with MRAVis[B2] do
     begin
      SetLength(ShortName, 0);
      SetLength(Cptn, 0);
      SetLength(ImageName, 0);
     end;
  SetLength(MRAVis, 0);
  setLength(mraVisMenu, 0);

end.
