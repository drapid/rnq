unit XMPPv1;
{$I RnQConfig.inc}
{$I NoRTTI.inc}

interface
uses
   Windows, Classes, //WinSock,
   RnQProtocol, RnQNet, RnQBinUtils, RDGlobal, RQThemes,
   XMPPContacts, XMPP_proto,
  RnQPrefsInt, RnQPrefsTypes,
  NativeXML, RnQXml;

type
  TmsgID = Integer;
  TxmppEvent = (
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
//    IE_fromMirabilis,
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
//    IE_sendingXStatus,
//    IE_ackXStatus,
//    IE_XStatusReq,

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

  TxmppError = (
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
  xmppError2str: array [TxmppError] of string=(
    'Server says you''re reconnecting too fastly, try later or change user.', //'rate exceeded',
    'Cannot connect\n[%d]\n%s',     // 'can''t connect',
    'Disconnected\n[%d]\n%s',       // 'disconnected',
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

  maxRefs = 2000;
type
  TwpResult = record
      uin: TUID;
      nick, first, last: string;
      StsMSG: String;
      authRequired: boolean;
//      status: byte;  // 0=offline 1=online 2=don't know
      gender: byte;
      status: word;  // 0=offline 1=online 2=don't know
      age: word;
//      BaseID: Word;
      BDay: TDateTime;
    end; // TwpResult

  TwpSearch = record
//    Token: String;
    email: String;
    nick, first, last: string;
    gender: byte;
    country: word;
    city_id: Integer;
    ageFrom, ageTo: integer;
    onlineOnly: boolean;
//    wInterest: Word;
    end; // TwpSearch

type
  TxmppSession = class;

  TxmppNotify = procedure (Sender: TxmppSession; event: TxmppEvent) of object;

  TxmppPhase = (
    null_,               // offline
//    connecting_,         // trying to reach the login server
//    login_,              // performing login on login server
    reconnecting_,       // trying to reach the service server
    relogin_,            // performing login on service server
    settingup_,          // setting up things
    online_

//    creating_uin_      // asking for a new uin
  );
  TrefKind = (
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


//  TxmppSession = class (TRnQProtocol, IRnQProtocol)
  TxmppSession = class (TRnQProtocol)
   public
    procedure PlaceCall(cnt: TRnQContact; useVideo: boolean);
//    const ContactType: TRnQContactType =  TICQContact;
//    type ContactType = TICQContact;
    const ContactType: TClass =  TxmppContact;
    function  sendXML(XML: TRnQXml): cardinal;
   protected
//        FRefCount: Integer;
{
        function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
        function _AddRef: Integer; stdcall;
        function _Release: Integer; stdcall;
}
   private
    mediaCaps_         : UTF8String;
    mechs: TMechsSet;
    curLoginType: TMechanism;
    fChal: RawByteString;
    fScramNonce: RawByteString;
    fScramServerSign: RawByteString;


    phase              : TxmppPhase;
    FLAPseq            : word;
    ServerStreamID     : String;
    tlsRequired        : Boolean;
    startingStatus     : byte;
    MSGref             : TmsgID;
    Q                  : TxmppflapQueue;
    refs               : array [1..maxRefs] of record
                          kind: TrefKind;
                          cnt: TxmppContact;
                        end;

    serviceServerAddr   : AnsiString;
    serviceServerPort   : AnsiString;
    spamList,
    aVisibleList,
    aInvisibleList,
    tempVisibleList,
    aRoster           : TRnQCList;
    P_pwd              : String;
    procedure setVisibility(vis: TxmppVisibility);
//    function  addRef(k: TrefKind; uin: TUID): integer;
    function  addRef(k: TrefKind; cnt: TxmppContact): TmsgID;

    procedure connected(Sender: TObject; Error: Word);
    procedure proxy_connected;
    procedure OnProxyError(Sender: TObject; Error: Integer; Msg: String);
    procedure onDataAvailable(Sender: TObject; Error: Word);
    procedure received(Sender: TObject; Error: Word; pkt: RawByteString);
    procedure Process_received_XML(pXMLEl: TsdElement);
    procedure Process_Online_XML(pXMLEl: TsdElement);
    procedure disconnected(Sender: TObject; Error: Word);
//    procedure sendPkt(s: AnsiString);
    function  sendPkt(const s: RawByteString=''): cardinal; OverLoad;
//    procedure sendPkt(MsgType: Cardinal; FromIP: TInAddr; FromPort: Cardinal; const s: RawByteString); OverLoad;
    procedure sendCaps(); // XEP-0030
    procedure send_version(pXMLEl: TsdElement);
    procedure send_ping(pXMLEl: TsdElement);
    procedure replyService_Discovery(pXMLEl: TsdElement);
    procedure send_status();

    procedure parse_MyInfo(const pkt: RawByteString);
    procedure parse_Ack(const pkt: RawByteString; seq: Integer);
    procedure parse_CntAddAck(pkt: RawByteString; seq: Integer);
    procedure Parse_offlineMsg(pkt: RawByteString);
    procedure parse_auth(const pkt: RawByteString);
    procedure parse_Anketa(const pkt: RawByteString; seq: Integer);
    procedure parse_Avatar(pXMLEl: TsdElement);
    procedure parse_LoginAck(pXMLEl: TsdElement);
    procedure parse_features(pXMLEl: TsdElement);
    procedure req_roster();
    procedure process_roster(pXMLEl: TsdElement; isFullRoster: Boolean = false);
    procedure parse_presence(pXMLEl: TsdElement);
    procedure parse_Msg(pXMLEl: TsdElement);
    procedure ReqClientCaps(cnt: TRnQContact; rid: Int8;
                 s1, s2: String; isFull: boolean = True);
    procedure parse_discoCaps(pXMLEl: TsdElement);

    procedure SSIdeleteContact(c: TxmppContact);
   public
     AccJID: String;
     ServerJID: String;
     fPriority: Integer;
//    listener: TmraNotify;
//    aProxy: Tproxy;
//    loginServerAddr: AnsiString;
//    loginServerPort: AnsiString;
//    sock: TRnQSocket;
//    MyInfo0: TMRAContact;
    curStatus: TxmppStatus;
    fVisibility: TxmppVisibility;
//    curXStatus          : Byte;
    curXStatus: record
         idx: byte;
         id: AnsiString;
         Name, Desc: String;
       end;

    MailsCntAll         : Integer;
    MailsCntUnread      : Integer;

    // used to pass valors to listeners
    eventError          : TxmppError;
    eventMsg            : String;
    eventAddress        : string;
    eventName           : string;
    eventData           : RawByteString;
    eventOldStatus      : byte;
    eventOldInvisible   : boolean;
    eventInt            : integer;    // multi-purpose
    eventFlags          : dword;
    eventTime           : TdateTime;  // in local time
    eventMsgID          : TmsgID;
    eventStream         : TMemoryStream;
//    eventContact        : TxmppContact;
    eventContactRes     : Txmpp_cnt_res;
    eventContacts       : TRnQCList;
    eventWP             : TwpResult;

//        class function NewInstance: TObject; override; {$IFDEF DELPHI9_UP} final; {$ENDIF DELPHI9_UP}

    class function _GetProtoName: string; OverRide; final;
//    class function _isValidUid(var uin: TUID): boolean; OverRide; final;
    class function _isProtoUid(var uin: TUID): boolean; OverRide; final;
    class function _isValidUid1(const uin: TUID): boolean; OverRide; final;
    class function _getDefHost: Thostport; OverRide; final;
    class function _getContactClass: TRnQCntClass; OverRide; final;
    class function _getProtoServers: String; OverRide; final;
    class function _getProtoID: Byte; OverRide; final;
    class function _MaxPWDLen: Integer; OverRide; final;
//    function isValidUid(var uin: TUID): boolean;
//    function getContact(uid: TUID): TRnQContact;
    function getxmppContact(const uid: TUID): TxmppContact;
    class function _CreateProto(const uid: TUID): TRnQProtocol; OverRide; final;
    class function _RegisterUser(var pUID: TUID; var pPWD: String): Boolean; OverRide; {$IFDEF DELPHI9_UP} final; {$ENDIF DELPHI9_UP}
    class function getUserHost(jid: TUID): String;

    function  getPwd: String; OverRide; {$IFDEF DELPHI9_UP} final; {$ENDIF DELPHI9_UP}
    procedure setPwd(const value: String); OverRide; {$IFDEF DELPHI9_UP} final; {$ENDIF DELPHI9_UP}
    function pwdEqual(const pass: String): Boolean; OverRide; {$IFDEF DELPHI9_UP} final; {$ENDIF DELPHI9_UP}

    constructor Create(const id: TUID);
    destructor Destroy; OverRide; {$IFDEF DELPHI9_UP} final; {$ENDIF DELPHI9_UP}
    procedure ResetPrefs; OverRide; {$IFDEF DELPHI9_UP} final; {$ENDIF DELPHI9_UP}
    procedure GetPrefs(pp: IRnQPref); OverRide; {$IFDEF DELPHI9_UP} final; {$ENDIF DELPHI9_UP}
    procedure SetPrefs(pp: IRnQPref); OverRide; {$IFDEF DELPHI9_UP} final; {$ENDIF DELPHI9_UP}
    procedure Clear; OverRide; {$IFDEF DELPHI9_UP} final; {$ENDIF DELPHI9_UP}
    function  getDefHost: Thostport; OverRide; {$IFDEF DELPHI9_UP} final; {$ENDIF DELPHI9_UP}
    procedure connect; overload;
//    procedure connect(createUIN:boolean; avt_session : Boolean = false); overload;
    procedure disconnect; OverRide; {$IFDEF DELPHI9_UP} final; {$ENDIF DELPHI9_UP}
    function  isOnline: boolean; OverRide; {$IFDEF DELPHI9_UP} final; {$ENDIF DELPHI9_UP}
    function  isOffline: boolean; OverRide; {$IFDEF DELPHI9_UP} final; {$ENDIF DELPHI9_UP}
    function  isReady: boolean; OverRide; {$IFDEF DELPHI9_UP} final; {$ENDIF DELPHI9_UP}    // we can send commands
    function  isConnecting: boolean; OverRide; {$IFDEF DELPHI9_UP} final; {$ENDIF DELPHI9_UP}
    function  isSSCL: boolean; OverRide; {$IFDEF DELPHI9_UP} final; {$ENDIF DELPHI9_UP}
    function  getStatus: byte; OverRide; {$IFDEF DELPHI9_UP} final; {$ENDIF DELPHI9_UP}
    procedure setStatus(st: byte); overload; OverRide; {$IFDEF DELPHI9_UP} final; {$ENDIF DELPHI9_UP}
//    procedure setStatusStr(stID: AnsiString; stCap, stDesc: String);
    procedure setStatusStr(stID: AnsiString; stStr: TXStatStr);
    function  getVisibility: byte; OverRide; {$IFDEF DELPHI9_UP} final; {$ENDIF DELPHI9_UP}
    function  IsInvisible: Boolean; OverRide; {$IFDEF DELPHI9_UP} final; {$ENDIF DELPHI9_UP}
    function  getStatusName: String; OverRide; {$IFDEF DELPHI9_UP} final; {$ENDIF DELPHI9_UP}
    function  getStatusImg: TPicName; OverRide; {$IFDEF DELPHI9_UP} final; {$ENDIF DELPHI9_UP}
    function  getXStatus: byte; OverRide; {$IFDEF DELPHI9_UP} final; {$ENDIF DELPHI9_UP}

    function  imVisibleTo(c: TRnQContact): boolean; OverRide; {$IFDEF DELPHI9_UP} final; {$ENDIF DELPHI9_UP}
    function  maxCharsFor(const c: TRnQContact; isBin: Boolean = false): integer; OverRide; {$IFDEF DELPHI9_UP} final; {$ENDIF DELPHI9_UP}
    procedure getClientPicAndDesc4(cnt: TRnQContact; var pPic: TPicName; var CliDesc : String); OverRide; {$IFDEF DELPHI9_UP} final; {$ENDIF DELPHI9_UP}
    function  isMyAcc(c: TRnQContact): Boolean; OverRide; {$IFDEF DELPHI9_UP} final; {$ENDIF DELPHI9_UP}
    function  canAddCntOutOfGroup: Boolean; OverRide; {$IFDEF DELPHI9_UP} final; {$ENDIF DELPHI9_UP}

    // manage contact lists
    function  readList(l: TLIST_TYPES): TRnQCList; OverRide; {$IFDEF DELPHI9_UP} final; {$ENDIF DELPHI9_UP}
    procedure AddToList(l: TLIST_TYPES; cl: TRnQCList); overLoad; OverRide; {$IFDEF DELPHI9_UP} final; {$ENDIF DELPHI9_UP}
    procedure RemFromList(l: TLIST_TYPES; cl: TRnQCList); OverLoad; OverRide; {$IFDEF DELPHI9_UP} final; {$ENDIF DELPHI9_UP}
    // manage contacts
    procedure AddToList(l: TLIST_TYPES; cnt: TRnQContact); OverLoad; OverRide; {$IFDEF DELPHI9_UP} final; {$ENDIF DELPHI9_UP}
    procedure RemFromList(l: TLIST_TYPES; cnt: TRnQContact); OverLoad; OverRide; {$IFDEF DELPHI9_UP} final; {$ENDIF DELPHI9_UP}
    function  isInList(l: TLIST_TYPES; cnt: TRnQContact) : Boolean; OverRide; {$IFDEF DELPHI9_UP} final; {$ENDIF DELPHI9_UP}

    function  addContact(c: TRnQContact; isLocal: Boolean = false): boolean; OverRide; {$IFDEF DELPHI9_UP} final; {$ENDIF DELPHI9_UP}
    function  removeContact(cnt: TRnQContact): boolean; OverRide; {$IFDEF DELPHI9_UP} final; {$ENDIF DELPHI9_UP}

//    function  deleteGroup(grSSID: Integer): Boolean; OverRide; {$IFDEF DELPHI9_UP} final; {$ENDIF DELPHI9_UP}

//    function  validUid(var uin: TUID): boolean;
//    function  validUid1(const uin: TUID): boolean;
//    function  getContact(uid: TUID): TRnQContact;

    function  sendMsg(cnt: TRnQContact; var flags: dword; const msg: string; var requiredACK: boolean): integer; Overload; OverRide; {$IFDEF DELPHI9_UP} final; {$ENDIF DELPHI9_UP}// returns handle
//    function  sendMsg(cnt: TRnQContact; var flags: dword; const msg: string; var requiredACK: boolean): integer; OverLoad;// returns handle
    function  sendMsg(cnt: TRnQContact; var flags: dword; const msg: string; var requiredACK: boolean; CnTResourse: String): integer; Overload;
    function  SendSMS(cnt: TRnQContact; const phnN: AnsiString; const msg: String): Integer;
    procedure AuthGrant(Cnt: TRnQContact); OverRide; {$IFDEF DELPHI9_UP} final; {$ENDIF DELPHI9_UP}
    procedure AuthCancel(Cnt: TRnQContact);
    procedure AuthRequest(cnt: TRnQContact; const reason: String); OverRide; {$IFDEF DELPHI9_UP} final; {$ENDIF DELPHI9_UP}
    procedure UpdateGroupOf(cnt: TRnQContact); OverRide; {$IFDEF DELPHI9_UP} final; {$ENDIF DELPHI9_UP}
//    procedure UpdateGroupID(grID: Integer); OverRide; {$IFDEF DELPHI9_UP} final; {$ENDIF DELPHI9_UP}

    procedure sendWPsearch(wp: TwpSearch; idx: Integer);

    procedure sendAck(const mail: AnsiString; id: TmsgID);
    function  getFlapBuf: RawByteString;
    // event managing

    procedure InputChangedFor(cnt: TRnQContact; InpIsEmpty: Boolean; timeOut: boolean = false); OverRide; {$IFDEF DELPHI9_UP} final; {$ENDIF DELPHI9_UP}
    function  compareStatusFor(cnt1, Cnt2: TRnqContact): Smallint; OverRide; {$IFDEF DELPHI9_UP} final; {$ENDIF DELPHI9_UP}
    procedure sendKeepalive; OverRide; {$IFDEF DELPHI9_UP} final; {$ENDIF DELPHI9_UP}

    function  getMyInfo: TRnQContact; OverRide; {$IFDEF DELPHI9_UP} final; {$ENDIF DELPHI9_UP}
//    procedure setMyInfo(cnt: TRnQContact);
    function  getContactClass: TRnQCntClass; OverRide; {$IFDEF DELPHI9_UP} final; {$ENDIF DELPHI9_UP}
    function  getContact(const UID: TUID): TRnQContact; OverRide; {$IFDEF DELPHI9_UP} final; {$ENDIF DELPHI9_UP}
    function  getStatuses: TStatusArray; OverRide; {$IFDEF DELPHI9_UP} final; {$ENDIF DELPHI9_UP}
    function  getVisibilitis: TStatusArray; OverRide; {$IFDEF DELPHI9_UP} final; {$ENDIF DELPHI9_UP}
    function  getStatusMenu: TStatusMenu; OverRide; {$IFDEF DELPHI9_UP} final; {$ENDIF DELPHI9_UP}
    function  getVisMenu: TStatusMenu; OverRide; {$IFDEF DELPHI9_UP} final; {$ENDIF DELPHI9_UP}
    function  getStatusDisable: TOnStatusDisable; OverRide; {$IFDEF DELPHI9_UP} final; {$ENDIF DELPHI9_UP}

    property  pwd: String  read getPwd write setPwd;
//    property  statuses: TStatusArray read getStatuses;
    property  visibility: TxmppVisibility read fVisibility write setVisibility;
    property  eventContact: TxmppContact read eventContactRes.cnt;

    procedure setMediaCaps(caps: UTF8String);

   public
     showclientid,
     getOfflineMsgs,
     delOfflineMsgs,
     offlineMsgsChecked: Boolean;
     OfflMsgs: array of Int64;
    procedure sendReqOfflineMsgs;
    procedure sendDeleteOfflineMsgs;
    procedure SSI_updateContact(c: TxmppContact);
    procedure ReqUserInfo(cnt: TRnQContact);
    function  RequestIcon(cnt: TRnQContact): Boolean;
    procedure OpenGroupChat(chat: String; Nick: String; pass: String='');
    function  getPrefPage: TPrefFrameClass; OverRide; {$IFDEF DELPHI9_UP} final; {$ENDIF DELPHI9_UP}
   protected
    procedure goneOffline; // called going offline
    // event managing
    procedure notifyListeners(ev: TxmppEvent);

    procedure SSIAddContact(c: TxmppContact);
    function  GetCurStatCode(IsFutureStat: Boolean = false): RawByteString;
  end;

var
  xmppStatuses, xmppVis: TStatusArray;
  statMenu, xmppVisMenu: TStatusMenu;
//  onStatusDisable: array [TMRAstatus] of TOnStatusDisable;

implementation

uses
     SysUtils, DateUtils, StrUtils,
 {$IFDEF UNICODE}
   AnsiStrings,
  AnsiClasses,
 {$ENDIF UNICODE}
  OverbyteIcsWSocket, //OverbyteIcsSHA1,
  Base64, RnQCrypt, AES_HMAC_Syn, SynCrypto,
  RQUtil, RDUtils, RnQDialogs, RnQLangs, RnQStrings,
  RnQFileUtil,
  Protocol_XMP,
  RnQConst, globalLib, themesLib, utilLib,
  xmpp_fr;
{ TxmppSession }

procedure TxmppSession.AddToList(l: TLIST_TYPES; cl: TRnQCList);
begin

end;

procedure TxmppSession.AddToList(l: TLIST_TYPES; cnt: TRnQContact);
begin
 case l of
   LT_ROSTER:   addContact(cnt);
   LT_VISIBLE:   //add2visible(TICQContact(cnt));
          begin
            if not isReady then
              Exit;
            if not aVisibleList.exists(cnt) then
             begin
              aVisibleList.add(cnt);
              aInvisibleList.remove(cnt);
              SSI_updateContact(TxmppContact(cnt));
              eventContactRes.cnt:= TxmppContact(cnt);
              eventContactRes.resNum:= -1;
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
              SSI_updateContact(TxmppContact(cnt));
              eventContactRes.cnt:= TxmppContact(cnt);
              eventContactRes.resNum:= -1;
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
              SSI_updateContact(TxmppContact(cnt));
              eventContactRes.cnt:= TxmppContact(cnt);
              eventContactRes.resNum:= -1;
              notifyListeners(IE_visibilityChanged);
             end;
          end;
 end;
end;

function TxmppSession.compareStatusFor(cnt1, Cnt2: TRnqContact): Smallint;
begin
  if StatusPriority[TxmppContact(cnt1).status] < StatusPriority[TxmppContact(Cnt2).status] then
    result := -1
  else if StatusPriority[TxmppContact(cnt1).status] > StatusPriority[TxmppContact(Cnt2).status] then
    result := +1
  else
    Result := 0;
end;

function TxmppSession.addRef(k: TrefKind; cnt: TxmppContact): TmsgID;
begin
{  result := FLAPseq;
}
  Result := MSGref;

  refs[MSGref].kind := k;
  refs[MSGref].cnt := cnt;

  inc(MSGref);
  if MSGref > maxRefs then
    MSGref := 1;
end; // addRef


procedure TxmppSession.connect;
begin
  if not isOffline then
    exit;
// if (not avt_session) then
  if (P_pwd = '') or (MyAccount='') then
  begin
   eventError := EC_missingLogin;
   notifyListeners(IE_error);
   exit;
  end;
  sock.proto := 'tcp';

  sock.addr := loginServerAddr;
  sock.port := loginServerPort;

 // phase := connecting_;
 phase := reconnecting_;
 FLAPseq := 1;
// SNACref := 1;
  MSGref := 1;
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
      eventError := EC_cantconnect;
      eventInt := WSocket_WSAGetLastError;
    eventMsg := WSocketErrorDesc(eventInt);
    notifyListeners(IE_error);
    goneOffline;
   end;
 end;

end;


procedure TxmppSession.disconnect;
begin
 q.reset;
 sock.close;
 goneOffline;
end;

procedure TxmppSession.connected(Sender: TObject; Error: Word);
begin
  eventTime := now;
  if error <> 0 then
  begin
    goneOffline;
    eventInt := WSocket_WSAGetLastError;
    if eventInt=0 then
     eventInt := error;
    eventMsg := WSocketErrorDesc(eventInt);
    eventError := EC_cantconnect;
    notifyListeners(IE_error);
    exit;
  end;
//  eventMsg := 'SSL: ' + sock.SslCipher;
  eventAddress := sock.Addr;
  if sock.SslEnable then
   eventAddress := eventAddress + '  '+ crlf + sock.SslVersion +'; '+ sock.SslCipher;
  notifyListeners(IE_serverConnected);
  proxy_connected;
end;

procedure TxmppSession.disconnected(Sender: TObject; Error: Word);
begin
  q.reset;
  eventAddress := sock.addr;
  eventMsg := '';
  notifyListeners(IE_serverDisconnected);
  if error <> 0 then
    begin
      goneOffline;
      eventInt := WSocket_WSAGetLastError;
    //  GetWinsockErr
      if eventInt=0 then
        eventInt := error;
      eventMsg := WSocketErrorDesc(eventInt);
      eventError := EC_socket;
      notifyListeners(IE_error);
      exit;
    end;
  //if (phase<>login_) then
  //if (phase<>relogin_) then
  if (phase<>reconnecting_) then
    goneOffline;
end;

procedure TxmppSession.onDataAvailable(Sender: TObject; Error: Word);
const
  dataLen = 16384-2;
var
  pkt: RawByteString;
//  p: RawByteString;
  lCount: Integer;
begin
{  pkt := '';
  SetLength(p, dataLen);
  lCount := sock.Receive(@p[1], dataLen);
  while lCount > 0 do
    begin
      pkt := pkt + copy(p, 1, lCount);
      lCount := sock.Receive(@p[1], dataLen);
    end;}
(*
 {$IFDEF UNICODE}
  pkt := sock.ReceiveStrA;
 {$ELSE nonUNICODE}
  pkt := sock.ReceiveStr;
 {$ENDIF UNICODE}
*)
    lCount := sock.RcvdCount;

    if lCount < 0 then begin  { GetRcvdCount returned an error }
        SetLength(pkt, 0);
        Exit;
    end;

    if lCount = 0 then        { GetRcvdCount say nothing, will try anyway }
        LCount := dataLen;    { some reasonable arbitrary value           }

    SetLength(pkt, lCount);
    lCount := sock.Receive(@pkt[1], lCount);
    if lCount > 0 then
        SetLength(pkt, lCount)
    else
        SetLength(pkt, 0);

  received(sender, Error, pkt);
end;

procedure TxmppSession.OnProxyError(Sender: TObject; Error: Integer;
  Msg: String);
begin
 if error <> 0 then
  begin
    goneOffline;
//    eventInt:=WSocket_WSAGetLastError;
//    if eventInt=0 then
    eventInt := error;
    eventMsg := msg;
    eventError := EC_cantconnect;
    notifyListeners(IE_error);
//  exit;
  end;
end;

procedure TxmppSession.proxy_connected;
var
  xml: TRnQXML;
//  xelm: TsdElement;
  ss: RawByteString;
begin
{if creatingUIN then
  begin
  phase:=creating_uin_;
  notifyListeners(IE_connected);
  end
else}
  case phase of
{    connecting_:
      begin
      phase:=login_;
      notifyListeners(IE_connected);
      end;}
    reconnecting_:
      begin
       phase := relogin_;
       notifyListeners(IE_redirected);
{       xelm := xml.Root.Items.Add('iq');
       xelm.Properties.Add('type', 'get');
       xelm.Properties.Add('to', 'talk.google.com');
       xelm.Properties.Add('id', 'reg_1');
       xelm.Items.
//       xml.
//<iq type="get" to="capulet.com" id="reg_1"> <query xmlns="jabber:iq:register"/> </iq>
}
        xml := TRnQXML.CreateEx(NIL, false, false, True, nsStream + ':stream');
        xml.PreserveWhiteSpace := False;
        xml.XmlFormat := xfCompact;
        xml.NodeClosingStyle := ncDefault;
        xml.Root.NodeClosingStyle := ncNone;

//        xml.EolStyle := esCRLF;
//        xml.Options := xml.Options + [sxoTrimPrecedingTextWhitespace];
//        xml.Options := xml.Options + [sxoDoNotSaveProlog];
//        xml.Options := xml.Options + [sxoNotCloseRootElem, sxoSaveWithoutLineBreaks];

//        xml.Prolog.Version := '1.0';
//        xml.Prolog.Encoding := '';
//        with xml.Root.Items.Add('stream:stream') do
        with xml.Root do
         begin
//           Name := 'stream';
//           NameSpace := nsStream;
           AttributeAdd('to', ServerJID);
           AttributeAdd('xmlns', 'jabber:client');
           AttributeAdd('xmlns:stream','http://etherx.jabber.org/streams');
           AttributeAdd('version','1.0');
         end;
{
//        xml.Prolog.Encoding := 'UTF8';
      //  xml.Options :=
        with xml.Root.Items.Add('iq') do
         begin
           Properties.Add('type', 'get');
//           Properties.Add('to', 'talk.google.com');
           Properties.Add('to', 'yandex.ru');
           Properties.Add('id', 'reg_1');
           Items.Add('query').Properties.Add('xmlns','jabber:iq:register');
         end;
      //<iq type="get" to="capulet.com" id="reg_1"> <query xmlns="jabber:iq:register"/> </iq>
}
//        ss := '<stream:stream '+xml.XMLData + '>';
//        ss := xml.SaveToRaw;
        ss := xml.WriteToRaw;
        xml.Free;
       sendPkt(ss);
      end;
    end
end;

procedure TxmppSession.Process_received_XML(pXMLEl: TsdElement);
begin
   case phase of
    relogin_:
      begin
        parse_LoginAck(pXMLEl);
      end;
     online_:
      begin
        Process_Online_XML(pXMLEl);
      end;
   end;
end;

procedure TxmppSession.Process_Online_XML(pXMLEl: TsdElement);
var
//  vXML: TJclSimpleXML;
  item: TsdElement;
//  item, item2: TXmlNode;
  vS: string;
begin
//        if pXMLEl.NameSpace = nsStream then
//          begin
           if pXMLEl.Name = 'stream:stream' then
            begin
              vS := pXMLEl.AttributeValueByNameWide['id'];
              if vS > '' then
                ServerStreamID := vS;
(*
              if pXMLEl.Items.Count > 0 then
               begin
                 Process_Online_XML(pXMLEl.Items.Item[0]);
{
                 vXML := TJclSimpleXML.Create;
                 vXML.Root := TsdElementClassic(pXMLEl.Items.Item[0]);
                 Process_Online_XML(vXML.Root);
                 vXML.Free;}
//                 vS := pXML.Root.Items.Item[0].SaveToString;
//                 pkt2 := vS;
//                 received(sender, Error, pkt2);
               end;*)
            end
           else
           if pXMLEl.Name = 'stream:features' then
            begin
              parse_features(pXMLEl);
            end
//          end
         else
          if pXMLEl.Name = 'iq' then
           begin
             vS := pXMLEl.AttributeValueByNameWide['type'];
             if vS = 'result' then
               begin
                 if StartsStr('getpic', pXMLEl.AttributeValueByName['id']) then
                   parse_Avatar(pXMLEl)
                 else
                   begin
                 if pXMLEl.ContainerCount > 0 then
                  begin
                   item := TsdElement(pXMLEl.Containers[0]);
                   if Item.Name = 'bind' then
                     begin
                       if (item.ContainerCount > 0) then
                        begin
                          item := TsdElement(item.Containers[0]);
                            vS := item.ValueUnicode;
  //                          vS :=  Items.Value('jid');
                          if vS > '' then
                            AccJID := vS;
                        end;
                      XMPPCL_SetStatus(aRoster, SC_OFFLINE);
  //                      ICQCL_setStatus(aRoster, ICQcontacts.SC_OFFLINE);
                      req_roster();
                      curStatus := TxmppStatus(startingStatus);
                      send_Status();
                      phase := online_;
                      notifyListeners(IE_online);
                     end
                    else
                   if Item.Name = 'query' then
                     begin
                         vS := item.AttributeValueByNameWide['xmlns'];
                       if vS = 'jabber:iq:roster' then
                        begin // Process roster
                          process_roster(item, item.AttributeValueByName['id']='rstr1');
                        end
                       else if vS = 'http://jabber.org/protocol/disco#info' then
                        begin // Process disco
                          parse_discoCaps(pXMLEl);
                        end
                       ;
                     end;
                  end;
                   end;
               end
             else
             if vS = 'get' then
               begin
                 if pXMLEl.ContainerCount > 0 then
                  begin
                   item := TsdElement(pXMLEl.Containers[0]);
                   if Item.Name = 'query' then
                     begin
                       vS := item.AttributeValueByName['xmlns'];
                       if vS = XEP0092_Software_Version then
                         begin
                           send_version(pXMLEl);
                         end
                       else
                       if vS = XEP0030_Service_Discovery then
                         begin
                           replyService_Discovery(pXMLEl);
                         end;
                     end
                   else if Item.Name = 'ping' then // XEP-0199: XMPP Ping
                     begin
                       vS := item.AttributeValueByName['xmlns'];
                       if vS = XEP0199_XMPP_Ping then
                         begin
                           send_ping(pXMLEl);
                         end;
                     end;
                  end;
               end
             else
             if vS = 'set' then
               begin
                  begin
{                 if pXMLEl.Items.Count > 0 then
                  begin
                   item := pXMLEl.Items.Item[0];
                   if Item.Name = 'query' then
                     begin
                       vS := item.Properties.Value('xmlns');
                       if vS = 'jabber:iq:version' then
                         begin
                           send_version(pXMLEl);
                         end;
                     end;
                  end;}
                  end;
               end
           end
          else
          if pXMLEl.Name = 'message' then
           begin
             parse_Msg(pXMLEl);
           end
          else
          if pXMLEl.Name = 'presence' then
           begin
             parse_presence(pXMLEl);
           end;
 ;
end;

procedure TxmppSession.received(Sender: TObject; Error: Word; pkt: RawByteString);
{type
  TReadStatus = (rsWaitingOpeningTag, rsOpeningName, rsTypeOpeningTag, rsEndSingleTag,
    rsWaitingClosingTag1, rsWaitingClosingTag2, rsClosingName);
var
  lPos: TReadStatus;
  St, lName, lValue, lNameSpace: string;
  Ch: Char;}
var
//  ref: integer;
//  oldVis: Tvisibility;
//  service: TsnacService;
  ofs1, ofs2, readedLen: Int64;
  xml, xml2: TRnQXML;
  Stream, Str2: TStringStream;
//  StrStream: TJclUTF8Stream;
//  pkt2: RawByteString;
  item: TXmlNode;
  bXX: Byte;
  tryAgain, isOk : Boolean;
  I, k: Integer;
begin
  eventData := pkt;
  notifyListeners(IE_serverSent);
  Q.add(pkt);
  tryAgain := True;
  while tryAgain and Q.available do
   begin
     pkt := Q.pop;
(*
  if pkt > '' then
   begin
     appendFile(logPath+packetslogFilename + '.3', #13#10+ '=============================='+#13#10);
     appendFile(logPath+packetslogFilename + '.3', pkt);
   end;
*)
      begin
        Stream := TStringStream.Create(pkt);
//        StrStream := TJclUTF8Stream.Create(Stream, True);
        xml := TRnQXml.CreateEx(nil, false, false, false, '');
        xml.PreserveWhiteSpace := False;
//        xml.XmlFormat := xfReadable;
        xml.XmlFormat := xfCompact;
        xml.Charset := 'utf-8';
        xml.FixStructuralErrors := False;
        bXX := 0;
        ofs1 := 0;
        ofs2 := Stream.Size;
           repeat
            Stream.Position := ofs1;
            try
              bXX := xml.LoadNodeFromStream(Stream, readedLen);
//??????              isOk := (bXX=2) and (xml.Root <> nil) and (pkt[ofs1+readedLen]='>');
              isOk := (bXX=2) and (xml.Root <> nil);
             except
//              on e:EJclSimpleXMLError do
               begin
                isOk := false;
                bXX := 0;
                readedLen := 0;
               end;
            end;
            if isOk  then
             begin
              inc(ofs1, readedLen);
              if (xml.Root.Name = 'stream:stream') then
                begin
                  xml2 := TRnQXml.CreateEx(NIL, false, false, True, '');
                  xml2.Root.Assign(xml.Root);
                  begin
                    for I := xml2.Root.NodeCount-1 downto 0 do
                      if not(xml2.Root.Nodes[i] is TsdAttribute) then
                       xml2.Root.NodeDelete(i);
                  end;
      //            xml2.Root.NodesClear;
                  Process_received_XML(xml2.Root);
                  xml2.Free;
                  k := XML.Root.ContainerCount;
                    if (k > 0) then
                     begin
                       for I := 0 to k - 1 do
                        begin
                          item := XML.Root.Containers[i];
                          if item is TsdElement then
                            Process_received_XML(TsdElement(item));
                        end;
                     end;
                end
               else
                Process_received_XML(xml.Root);
//              xml.Root.Clear;
              xml.Clear;
              bXX := 0;
             end;
           until not(isOk);
//        if (bXX = 1) and not isOk then
        if not isOk then
         begin
           i := ofs2 - ofs1;
           if i > 0 then
            begin
//             SetLength(pkt, i);
//             StrStream.ReadBuffer(pkt[1], ofs);
             Stream.Position := ofs1;
             SetLength(pkt, i);
             Stream.ReadBuffer(pkt[1], i);
//             q.buff := pkt + q.buff;
             tryAgain := Q.available;
             if tryAgain then
               pkt := pkt + q.pop;
             q.ReturnStr(pkt);
            end;
         end;
        Stream.Free;
        xml.Free;
      end;
//   end;
  end;
end;

procedure TxmppSession.Clear;
begin
  MyAccount := '';
//  myinfo0:=NIL;
  readList(LT_ROSTER).clear;
  readList(LT_VISIBLE).Clear;
  readList(LT_INVISIBLE).Clear;
  readList(LT_TEMPVIS).Clear;
  readList(LT_SPAM).Clear;

  FreeAndNil(eventContacts);
  eventContactRes.cnt := NIL;
end;

function TxmppSession.getDefHost: Thostport;
var
  h: String;
  I: Integer;
begin
  Result := _getDefHost;
  h := getUserHost(MyAccount);
  if h > '' then
    begin
      for I := Low(cXMPP_Host2Servers) to (High(cXMPP_Host2Servers) div 2) do
        if cXMPP_Host2Servers[i*2] = h then
         begin
          Result.host := cXMPP_Host2Servers[i*2+1];
          Exit;
         end;
      Result.host := h;
    end;
end;

class function TxmppSession._CreateProto(const uid : TUID) : TRnQProtocol;
begin
  result := TxmppSession.Create(uid);
end;

class function TxmppSession._RegisterUser(var pUID: TUID; var pPWD: String): Boolean;
begin
  msgDlg('Unsupported function', True, mtWarning);
  Result := false;
end;

constructor TxmppSession.create(const id: TUID);
begin

  mediaCaps_ := '';
//  protoType := subType;
  fContactClass := TXMPPContact;

//  uid := id;
//  if pos('@', id) > 1 then
//    uid := chop('@', uid);

//  inherited create(id);
  inherited create;
  MyAccount := id;

  phase := null_;
  listener := NIL;
  curStatus := SC_OFFLINE;
  fVisibility := mVI_normal;
  curXStatus.idx := 0;
  curXStatus.id := '';
  curXStatus.Name := '';
  curXStatus.Desc := '';
  startingStatus := 0;
{
  if id='' then
    begin
      MyAccount := '';
//      myinfo0   := NIL
    end
   else
    begin
      MyAccount := TxmppContact.trimUID(id);
    end;
}
  P_pwd := '';
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
    loginServerPort     := IntToStrA(port);
   end;
Q := TxmppFlapQueue.create;
aRoster        := TRnQCList.create;
aVisibleList    := TRnQCList.create;
aInvisibleList  := TRnQCList.create;
tempVisibleList := TRnQCList.create;
spamList        := TRnQCList.Create;

end;

destructor TxmppSession.Destroy;
begin
  Q.free;
  sock.free;
  aRoster.free;
  aVisibleList.free;
  aInvisibleList.free;
  tempvisibleList.free;
  spamList.Free;
  inherited;
end;

procedure TxmppSession.getClientPicAndDesc4(cnt: TRnQContact;
              var pPic: TPicName; var CliDesc: String);
//function TxmppSession.getClientPicFor(c: TRnQContact): AnsiString;
var
  i: Integer;
//  str: String;
begin
{  if c is TxmppContact then
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
  else}
//   result := PIC_CLI_JABBER;
  pPic := '';
  if Cnt is TxmppContact then
    begin
     i := TxmppContact(Cnt).findDefRes;
     if i >= 0 then
       CliDesc := TxmppContact(Cnt).resources[i].ClientID;
    end
   else
    CliDesc := '';
end;

function TxmppSession.getxmppContact(const uid: TUID): TxmppContact;
begin
//  result := TxmppContact(contactsDB.get(TxmppContact, uid));
  result := TxmppContact(contactsDB.add(Self, uid));
end;

function TxmppSession.getMyInfo: TRnQContact;
begin
//  result := MyInfo0;
  Result := contactsDB.add(Self, MyAccount);
end;

function TxmppSession.isMyAcc(c : TRnQContact) : Boolean;
begin
//  result := MyInfo0.Equals(c);
  Result := Assigned(c) and c.equals(MyAccount);
end;
function TxmppSession.canAddCntOutOfGroup : Boolean;
begin
  Result := True;
end;

function TxmppSession.isSSCL:boolean;
begin
  Result := True;
end;


function TxmppSession.getPwd: String;
begin
  Result := P_pwd;
end;

class function TxmppSession._getContactClass : TRnQCntClass;
begin
  Result := TxmppContact;
end;
function TxmppSession.getContactClass : TRnQCntClass;
begin
  Result := TxmppContact;
end;
function TxmppSession.getContact(const UID : TUID) : TRnQContact;
begin
  result := getxmppContact(uid);
end;

class function TxmppSession._getProtoID : Byte;
begin
  Result := XMPProtoID;
end;

class function TxmppSession._GetProtoName: string;
begin
  result := 'XMP';
end;

class function TxmppSession._isProtoUid(var uin: TUID): boolean;
begin
  result := (copy(uin,1,4)=XMPPprefix);
  if Result then
      begin
        uin := copy(uin, 5, length(uin));
        Result := Length(uin) > 0;
      end;
end;

    //class function TxmppSession._isValidUid(var uin: TUID): boolean;
class function TxmppSession._isValidUid1(const uin: TUID): boolean;
begin
  Result := Pos('@', uin) > 0;
end;

class function TxmppSession._getDefHost: Thostport;
begin
  Result.host := cXMPP_Servers[0];
//  Result.host := 'ya.ru';
//  Result.Port := 443;
  Result.Port := 5222;
//  Result.Port := 2042;
end;

class function TxmppSession.getUserHost(jid: TUID): String;
var
  d, u: TUID;
begin
  TxmppContact.UID2DomUser(jid, d, u);
  Result := d;
end;

class function TxmppSession._getProtoServers: String;
var
  i: Integer;
begin
  Result := '';
  for I := 0 to Length(cXMPP_Servers) - 1 do
    Result := Result + cXMPP_Servers[i]+ CRLF;
end;

class function TxmppSession._MaxPWDLen: Integer;
begin
  Result := cXMPP_MaxPWDLen;
end;

function TxmppSession.getStatuses: TStatusArray;
begin
  Result := xmppStatuses;
end;

function TxmppSession.getVisibilitis: TStatusArray;
begin
  Result := xmppVis;
end;

function TxmppSession.getStatusMenu: TStatusMenu;
begin
  Result := TStatusMenu(statMenu);
end;

function TxmppSession.getVisMenu: TStatusMenu;
begin
  Result := TStatusMenu(xmppVisMenu);
end;

function TxmppSession.getStatusDisable: TOnStatusDisable;
begin
  result := onStatusDisable[byte(curStatus)];
end;

procedure TxmppSession.goneOffline;
var
  i: integer;
begin
  ServerStreamID := '';
  tlsRequired := False;

  if phase=null_ then
    exit;
  phase := null_;
  MSGref := 0;
{    if assigned(myinfo) then
      begin
      myinfo.status:=SC_OFFLINE;
      myinfo.invisible:=FALSE;
      end;}
    curStatus := SC_OFFLINE;
//    fVisibility:=;
    with aRoster do
     for i:=0 to count-1 do
      with TxmppContact(getAt(i)) do
       begin
        SetStatus(SC_UNK);
        OfflineClear;
      end;
    if Length(OfflMsgs)>0 then
     begin
       SetLength(OfflMsgs, 0);
     end;
  notifyListeners(IE_offline);
end;

function TxmppSession.imVisibleTo(c: TRnQContact): boolean;
begin
//  result := True;
     result:=(tempvisibleList.exists(c) or
         ((visibility = mVI_privacy) and (aVisibleList.exists(c)))
      or
        ((visibility = mVI_normal) and (not aInvisibleList.exists(c)))
       )
end;

procedure TxmppSession.InputChangedFor(cnt: TRnQContact; InpIsEmpty,
  timeOut: boolean);
begin

end;

function TxmppSession.isConnecting: boolean;
begin
//  result:=not (isOffline or isOnline)
  result:=(phase<>online_) and (phase<>null_)
end;

function TxmppSession.isOffline: boolean;
begin
  result:= phase=null_
end;

function TxmppSession.isOnline: boolean;
begin
  result := phase = online_;
end;

function TxmppSession.isReady: boolean;
begin
  result:=phase in [SETTINGUP_,ONLINE_]
end;

function TxmppSession.getStatus: byte;
begin
{  if myinfo=NIL then
    result := byte(SC_UNK)
  else
    result := byte(myinfo.status)}
  result := byte(curStatus)
end;

function TxmppSession.getStatusName: String;
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
            result := getTranslation(XMPPstatus2ShowStr[curStatus])
    end
   else
    result := getTranslation(XMPPstatus2ShowStr[curStatus])
end;

function TxmppSession.getStatusImg: TPicName;
begin
{  Result := '';
  if curXStatus.id > '' then
   begin
    Result := 'mra.'+curXStatus.id;
    with theme.GetPicSize(RQteDefault, Result) do
     if (cx = 0)or(cy = 0) then
      result := '';
   end;
  if Result = '' then}
   Result := XMPPstatus2imgName(curStatus, IsInvisible);
end;

procedure TxmppSession.setStatus(st: byte);
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
  curStatus := txmppStatus(st);
//  myinfo.invisible := (vis in [VI_invisible, VI_privacy]);
//  sendStatusCode(False);
  send_status;
  eventContactRes.cnt:= NIL;
  notifyListeners(IE_statuschanged);
  end
else
  connect;
end; // setStatus

function TxmppSession.getXStatus: byte;
begin
  result := curXStatus.idx;
end;

//procedure TxmppSession.setStatusStr(stID: AnsiString; stCap, stDesc: String);
procedure TxmppSession.setStatusStr(stID: AnsiString; stStr: TXStatStr);
//var
//  s: String;
begin
  eventContactRes.cnt := NIL;
//  eventInt := curXStatus;
{  eventName := stID;
  eventMsg  := stStr.Cap;
  eventData := stStr.Desc;
  notifyListeners(IE_sendingXStatus);
//  title := eventName;
//  s := eventMsg;
  curXStatus.id := eventName;
  curXStatus.Name := eventMsg;
  curXStatus.Desc := eventData;}

  curXStatus.id := stID;
  curXStatus.Name := stStr.Cap;
  curXStatus.Desc := stStr.Desc;

//  sendInfoStatus(s);
  send_status;
end;

function TxmppSession.getVisibility: byte;
begin
  result:= byte(fVisibility)
end;


function TxmppSession.maxCharsFor(const c: TRnQContact; isBin: Boolean = false): integer;
begin
  Result := 64000;
end;

function TxmppSession.pwdEqual(const pass: String): Boolean;
begin
  result := P_pwd = pass;
end;

function TxmppSession.readList(l: TLIST_TYPES): TRnQCList;
begin
// result := NIl;
//   result:=spamList;
 case l of
   LT_ROSTER:    result := aRoster;
   LT_VISIBLE:   result := aVisibleList;
   LT_INVISIBLE: result := aInvisibleList;
   LT_TEMPVIS:   result := tempvisibleList;
   LT_SPAM:      result := spamList;
  else
   Result := nil; 
 end;
end;

procedure TxmppSession.RemFromList(l: TLIST_TYPES; cnt: TRnQContact);
begin
 case l of
   LT_ROSTER:
          begin
            if not isReady then
              Exit;
            with readList(l) do
            if exists(cnt) then
             begin
              removeContact(cnt);
//              SSI_updateContact(TMRAContact(cnt));
//              eventCOntact := TMRAContact(cnt);
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
              SSI_updateContact(TxmppContact(cnt));
              eventContactRes.cnt := TxmppContact(cnt);
              eventContactRes.resNum := -1;
              notifyListeners(IE_visibilityChanged);
             end;
          end;
   LT_TEMPVIS:   Exit;//addTemporaryVisible(TICQContact(cnt));
 end;
end;

function TxmppSession.isInList(l: TLIST_TYPES; cnt: TRnQContact): Boolean;
begin
 case l of
   LT_ROSTER:    result := aRoster.exists(cnt);
   LT_VISIBLE:   result := aVisibleList.exists(cnt);
   LT_INVISIBLE: result := aInvisibleList.exists(cnt);
   LT_TEMPVIS:   result := tempvisibleList.exists(cnt);
   LT_SPAM:      result := spamList.exists(cnt);
  else
   Result := false;
 end;
end;


procedure TxmppSession.RemFromList(l: TLIST_TYPES; cl: TRnQCList);
var
  cl1: TRnQCList;
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
    cnt := TxmppContact(cl.getNext);
    SSI_updateContact(TxmppContact(cnt));
    eventContactRes.cnt:= TxmppContact(cnt);
    eventContactRes.resNum := -1;
    notifyListeners(IE_visibilityChanged);
   end;
  cl.Free; 
end;

function TxmppSession.addContact(c: TRnQContact; isLocal: Boolean = false): boolean;
begin
  result := FALSE;
  if (c=NIL)or (c.UID2cmp = '') then
    exit;
  result := aRoster.add(c);
  result := result or (not isLocal and c.CntIsLocal);
// c.SSIID := 0;
 if result then
  begin
  if isReady then
    begin
//      TMRAcontact(c).status:= SC_OFFLINE;
//      TMRAcontact(c).invisible:=FALSE;
      if not isLocal then
        SSIAddContact(TxmppContact(c))
    end;
//  if c.status = SC_OFFLINE then
//    getUINStatus(c.UID);
  eventInt := aRoster.count;
  notifyListeners(IE_numOfContactsChanged);
  end
 else
   begin
     UpdateGroupOf(c);
//      SSI_UpdateGroup(TICQcontact(c));      // Зря тут!!!
   end;
  ;
end;

function TxmppSession.removeContact(cnt: TRnQContact): boolean;
var
  isLocal, delLocSrv: Boolean;
  c: TxmppContact;
begin
  c := TxmppContact(cnt);
  isLocal := cnt.CntIsLocal;
  delLocSrv := isLocal or not cnt.Authorized;
  result:= aRoster.remove(cnt);
  if result then
   begin
    RemFromList(LT_VISIBLE, cnt);
    if not isLocal then
      SSIdeleteContact(c);
//      SSI_updateContact(c);
    c.SetStatus(SC_UNK);
    c.SSIID := 0;
    c.CntIsLocal := True;
    eventInt:= aRoster.count;
    notifyListeners(IE_numOfContactsChanged);
   end
end;

procedure TxmppSession.ResetPrefs;
var
  h: String;
begin
  aProxy.proto := PP_NONE;
//  aProxy.serv  := TxmppSession._getDefHost;
//  aProxy.ssl := True;

  aProxy.serv := getDefHost;
  aProxy.ssl := True;
  h := getUserHost(MyAccNum);
  if h > '' then
    ServerJID := h
   else
    ServerJID := 'gmail.com';

  offlineMsgsChecked := TRUE;
  getOfflineMsgs := TRUE;
  delOfflineMsgs := TRUE;

//        ServerJID := 'ya.ru';
//        ServerJID := 'talk.google.com';
end;

procedure TxmppSession.GetPrefs(pp: IRnQPref);
var
  i: Integer;
  sU: String;
begin
  Inherited;
     for i := low(self.getstatuses) to high(self.getStatuses) do
     with onStatusDisable[i] do
      begin
        sU := String(XMPPstatus2Img[txmppStatus(i)] + TPicName('-disable-'));
        pp.addPrefBool( sU+'blinking', blinking);
        pp.addPrefBool( sU+'tips', tips);
        pp.addPrefBool( sU+'sounds', sounds);
        pp.addPrefBool( sU+'openchat', OpenChat);
      end;
  if not (RnQstartingStatus in [Byte(Low(XMPPstatus2Img))..Byte(High(XMPPstatus2Img))]) then
    pp.addPrefStr('starting-status', 'last_used')
   else
    pp.addPrefStr('starting-status', String(XMPPstatus2Img[TxmppStatus(RnQstartingStatus)]));

  pp.addPrefStr('last-set-status', String(XMPPstatus2Img[TxmppStatus(lastStatusUserSet)]));

  pp.addPrefStr('starting-visibility', String(XMPPvisib2str[TxmppVisibility(RnQstartingVisibility)]));
  pp.addPrefStr('server-jid', ServerJID);
  if not dontSavePwd //and not locked
  then
    pp.addPrefBlob64('crypted-password64', passCrypt(StrToUTF8(pwd)))
   else
    pp.DeletePref('crypted-password64');
  pp.DeletePref('crypted-password');

  pp.addPrefBool('get-offline-msgs', getOfflineMsgs);
  pp.addPrefBool('del-offline-msgs', delOfflineMsgs);

end;

procedure TxmppSession.SetPrefs(pp: IRnQPref);
var
  i: byte;
  l: RawByteString;
  sU, sU2: String;
begin
  for i := low(getStatuses) to high(getStatuses) do
   with onStatusDisable[i] do
    begin
      sU2 := String(XMPPstatus2Img[txmppStatus(i)]) + '-disable-';
      sU := sU2+'blinking';
      pp.getPrefBool(sU, blinking);
      sU := sU2+'tips';
      pp.getPrefBool(sU, tips);
      sU := sU2+'sounds';
      pp.getPrefBool(sU, sounds);
      sU := sU2+'openchat';
      pp.getPrefBool(sU, OpenChat);
    end;

  if pp.prefExists('crypted-password64') then
    pwd := UnUTF(passDecrypt(pp.getPrefBlob64Def('crypted-password64')))
   else
    pwd := UnUTF(passDecrypt(pp.getPrefBlobDef('crypted-password')));

  l := pp.getPrefBlobDef('starting-status');
    if l='last_used' then
      RnQstartingStatus:=-1
     else
      RnQstartingStatus := XMPPstr2status(l);

  l := pp.getPrefBlobDef('last-set-status');
    lastStatusUserSet := XMPPstr2status(l);

  l := pp.getPrefBlobDef('starting-visibility');
    RnQstartingVisibility := Byte(XMPPstr2visibility(l));
  pp.getPrefStr('server-jid', ServerJID);
  pp.getPrefBool('connection-ssl', MainProxy.ssl);
  pp.getPrefStr('server-host', MainProxy.serv.host);
  pp.getPrefInt('server-port', MainProxy.serv.port);

  pp.getPrefBool('get-offline-msgs', getOfflineMsgs);
  pp.getPrefBool('del-offline-msgs', delOfflineMsgs);
end;

//procedure TxmppSession.sendPkt(s: AnsiString);
{procedure TxmppSession.sendPkt(const s: RawByteString =);
var
  pck: mrim_packet_header_t;
  s1: RawByteString;
begin
 if sock.State <> wsConnected then exit;

 pck.magic := CS_MAGIC;
 pck.proto := PROTO_VERSION;
 pck.seq   := FLAPseq;
 pck.msg   := MsgType;
// pck.from:=inet_addr(pchar(FromIP));
 pck.from  := FromIP.S_addr;
 pck.fromport:=FromPort;
 FillMemory(@pck.reserved[1], 16, 0);
 pck.dlen  := Length(s);
 SetLength(s1, SizeOf(mrim_packet_header_t));
// StrLCopy(@s1[1], @pck, SizeOf(mrim_packet_header_t));
 copyMemory(@s1[1], @pck, SizeOf(mrim_packet_header_t));
 s1 := s1 + s;
 try
   sock.sendStr(s1);
//  lastSendedFlap := now;
  eventData := s;
  notifyListeners(IE_serverGot);
  inc(FLAPseq);
  if FLAPseq = maxRefs then FLAPseq:= 1;
 except
 end;
s1:='';
//result:=TRUE;
// SetLength(FBody,0);
end;}

function TxmppSession.sendXML(XML: TRnQXML): cardinal;
begin
//  xml.Options := xml.Options + [sxoTrimPrecedingTextWhitespace];
//  xml.Options := xml.Options + [sxoDoNotSaveProlog, sxoSaveWithoutLineBreaks];
  xml.PreserveWhiteSpace := False;
//  xml.XmlFormat := xfReadable;
//  xml.EolStyle := esCRLF;
{
  xml.Options := xml.Options + [sxoTrimPrecedingTextWhitespace,
                      sxoDoNotSaveProlog, sxoSaveWithoutLineBreaks, sxoDoNotSaveBOM];
  xml.Options := xml.Options - [sxoAutoIndent];
  xml.Options := xml.Options - [sxoAutoEncodeValue];}
//  xml.Options := xml.Options
  Result := sendPkt(xml.WriteToRaw);
end;

function TxmppSession.sendPkt(const s: RawByteString): cardinal;
//var
//  s1: RawByteString;
begin
  Result := FLAPseq;
 if sock.State <> wsConnected then exit;
// s1 := s;
// s1 := s1 + s;
 try
   sock.sendStr(RawByteString(s));
//  sock.PutStringInSendBuffer(s);
//  lastSendedFlap := now;
{  if phase=online_ then
   begin
    inc(SendedFlaps);
    if (SendedFlaps > ICQMaxFlaps)and (phase=online_)  then
      sock.Pause;
   end;}
//  Result := FLAPseq;
  eventData := s;
  notifyListeners(IE_serverGot);
  inc(FLAPseq);
  if FLAPseq >= maxRefs then
    FLAPseq := 1;
 except
 end;
//s1:='';
end;

procedure TxmppSession.setMediaCaps(caps : UTF8String);
begin
  mediaCaps_ := caps;
  send_status();
end;

procedure TxmppSession.sendCaps();
begin
//  <presence from="xxx2 <at> gmail.com/MonalE97B8DDF" to="xxx <at> gmail.com"> <priority>24</priority> <c node="http://monal.im" ver="2.0.6.2" ext="avatar voice-v1" xmlns="http://jabber.org/protocol/caps"/>  <x xmlns="vcard-temp:x:update"/></presence>

end;

{procedure TxmppSession.setMyInfo(cnt: TRnQContact);
begin
  MyInfo0 := TMRAContact(cnt);
end;
}

procedure TxmppSession.setPwd(const value: String);
begin
  if (value<>pwd) and (length(value) <= cXMPP_MaxPWDLen) then
  if isOnline and (value > '') then
//     if messageDlg(getTranslation('Really want to change password on server?'), mtConfirmation, [mbYes,mbNo],0, mbNo, 20) = mrYes then
   else
    P_pwd := Value;
end;

procedure TxmppSession.setVisibility(vis: TxmppVisibility);
begin
  if vis <> fVisibility then
   begin
     eventOldInvisible := fVisibility = mVI_privacy;
     eventOldStatus := byte(curStatus);
     fVisibility := vis;
     send_status;
//     eventContact:=myinfo;
     eventContactRes.cnt := NIL;
     notifyListeners(IE_statuschanged);
   end;
//  if Assigned(myinfo) then
//    myinfo.invisible := fVisibility = mVI_privacy;
end;

function TxmppSession.IsInvisible: Boolean;
begin
  Result := fVisibility = mVI_privacy;
end;

procedure TxmppSession.UpdateGroupOf(cnt: TRnQContact);
begin
//  MRIM_CS_MODIFY_CONTACT
  SSI_updateContact(TxmppContact(cnt));
end;

//function TxmppSession.validUid(var uin: TUID): boolean;
{function TxmppSession.validUid1(const uin: TUID): boolean;
begin
 Result := TxmppSession._isValidUid1(uin);
end;}

(*
function TxmppSession.QueryInterface(const IID: TGUID; out Obj): HResult;
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

function TxmppSession._AddRef: Integer;
begin
  Result := InterlockedIncrement( FRefCount );
end;

function TxmppSession._Release: Integer;
begin
  Result := InterlockedDecrement( FRefCount );
//  if Result = 0 then
//    Destroy;
end;

// Set an implicit refcount so that refcounting
// during construction won't destroy the object.
class function TxmppSession.NewInstance: TObject;
begin
  Result := inherited NewInstance;
  TxmppSession( Result ).FRefCount := 1;
end;
*)

procedure TxmppSession.notifyListeners(ev: TxmppEvent);
begin
  if assigned(listener) then
//   listener(self, ev);
   listener(self, Integer(ev));
end;


procedure TxmppSession.parse_LoginAck(pXMLEl : TsdElement);
var
  xml: TRnQXML;
  item: TsdElement;
  i, k: Integer;
  StartTLS: Boolean;
  AllowPlain: Boolean;
  AllowMD5: Boolean;
  AllowSHA1: Boolean;
  AllowOAUTH2: Boolean;
  AllowGOOGLE_TOKEN: Boolean;
  u, d: TUID;
  ns: String;
  m: TMechanism;
begin
  if pXMLEl.Name = 'success' then
   begin
     phase := online_;
      xml := TRnQXML.CreateEx(nil, false, false, True, nsStream + ':stream');
      xml.NodeClosingStyle := ncDefault;
      xml.Root.NodeClosingStyle := ncNone;
//        xml.Prolog.Version := '1.0';
//        xml.Options := xml.Options + [sxoNotCloseRootElem, sxoSaveWithoutLineBreaks];
//        xml.Prolog.Encoding := '';
        with xml.Root do
         begin
           AttributeAdd('to', ServerJID);
           AttributeAdd('xmlns', 'jabber:client');
           AttributeAdd('xmlns:stream', 'http://etherx.jabber.org/streams');
           AttributeAdd('version', '1.0');
         end;
//      sendPkt('<auth xmlns=''urn:ietf:params:xml:ns:xmpp-sasl'' mechanism=''PLAIN'' />');
       sendXML(xml);
       xml.Free;
     exit;
   end;

  StartTLS   := False;
  AllowPlain := False;
  AllowMD5   := False;
  AllowSHA1  := False;
  AllowOAUTH2 := False;
  AllowGOOGLE_TOKEN := False;
  if pXMLEl.Name = 'stream:features' then
    begin
      for I := 0 to pXMLEl.ContainerCount -1 do
       begin
         item := TsdElement(pXMLEl.Containers[i]);
         if item.Name = 'starttls' then
           begin
             tlsRequired := item.NodeByName('required') <> NIL;
             StartTLS := tlsRequired;
           end
         else if item.Name = 'mechanisms' then
          for k := 0 to item.ContainerCount-1 do
            begin
              if item.Containers[k].Name = 'mechanism' then
               begin
                 if item.Containers[k].Value = 'PLAIN' then
                   AllowPlain := True
                 else
                 if item.Containers[k].Value = 'DIGEST-MD5' then
                   AllowMD5 := True
                 else
                 if item.Containers[k].Value = 'X-OAUTH2' then
                   AllowOAUTH2 := True
                 else
                 if item.Containers[k].Value = 'X-GOOGLE-TOKEN' then
                   AllowGOOGLE_TOKEN := True
                 ;
               end;
            end;
       end;
    end;

  if StartTLS then
    begin
//<starttls xmlns='urn:ietf:params:xml:ns:xmpp-tls'/>
      xml := TRnQXML.CreateEx(nil, false, false, True, 'starttls');
//      xml.Prolog.Encoding := '';
      with xml.Root do
         begin
//           Name := 'starttls';
//           NameSpace := 'stream';
           AttributeAdd('xmlns', 'urn:ietf:params:xml:ns:xmpp-tls');
         end;
       sendXML(xml);
       xml.Free;
      Exit;
    end;

  if pXMLEl.Name = 'proceed' then
    begin
      phase := reconnecting_;
      sock.startTLS;
      Exit;
    end
  else if pXMLEl.Name = 'failure' then
    begin
      ns := pXMLEl.AttributeValueByNameWide['xmlns'];
      if ns = 'urn:ietf:params:xml:ns:xmpp-sasl' then
        begin
          eventMsg := pXMLEl.ValueUnicode;
          eventError := EC_badPwd;
          disconnect;
          notifyListeners(IE_error);
          Exit;
        end;
    end;

  if AllowPlain then
    begin
      xml := TRnQXML.CreateEx(NIL, false, false, True, 'auth');
//        xml.Prolog.Version := '1.0';
//        xml.Prolog.Encoding := '';
        with xml.Root do
         begin
//           Name := 'auth';
//           NameSpace := 'stream';
           TxmppContact(getMyInfo).GetDomUser(d, u);
           AttributeAdd('to', d);
           AttributeAdd('xmlns', 'urn:ietf:params:xml:ns:xmpp-sasl');
           AttributeAdd('mechanism', MechanismNames[SM_PLAIN]);
//           Properties.Add('stream','http://etherx.jabber.org/streams').NameSpace := 'xmlns';
           Value := Base64EncodeString(StrToUTF8(LowerCase(MyAccount)) + AnsiChar(#0) + StrToUTF8(u) + AnsiChar(#0) + StrToUTF8(pwd));
         end;
//      sendPkt('<auth xmlns=''urn:ietf:params:xml:ns:xmpp-sasl'' mechanism=''PLAIN'' />');
       sendXML(xml);
       xml.Free;
      curLoginType := SM_PLAIN;
    end;
end;

procedure TxmppSession.parse_features(pXMLEl: TsdElement);
var
  xml: TRnQXML;
//  item: TsdElement;
//  i, k: Integer;
//  u, d: AnsiString;
begin
//  if pXML.Root.Name = 'success' then
   begin
      xml := TRnQXML.CreateEx(NIL, false, false, True, 'iq');
//        xml.Prolog.Version := '1.0';
//        xml.Options := xml.Options + [sxoSaveWithoutLineBreaks];
//        xml.Prolog.Encoding := '';
        with xml.Root do
         begin
//           Name := 'iq';
//           NameSpace := 'stream';
           AttributeAdd('id', 'bind_1');
           AttributeAdd('type', 'set');
           with NodeNew('bind') do
            begin
             AttributeAdd('xmlns', 'urn:ietf:params:xml:ns:xmpp-bind');
             NodeNew('resource').Value := 'rnq';
            end;
         end;
       sendXML(xml);
       xml.Free;

      xml := TRnQXML.CreateEx(nil, false, false, True, 'iq');
//        xml.Prolog.Version := '1.0';
//        xml.Options := xml.Options + [sxoSaveWithoutLineBreaks];
//        xml.Prolog.Encoding := '';
        with xml.Root do
         begin
//           Name := 'iq';
           AttributeAdd('to', ServerJID);
           AttributeAdd('id', 'sess_1');
           AttributeAdd('type', 'set');
           with NodeNew('session') do
            begin
             AttributeAdd('xmlns', 'urn:ietf:params:xml:ns:xmpp-session');
             NodeNew('resource').Value := 'rnq';
            end;
         end;
       sendXML(xml);
       xml.Free;
     exit;
   end;
end;

//procedure TxmppSession.send_version(pXML : TJclSimpleXML);
procedure TxmppSession.send_version(pXMLEl : TsdElement);
var
  xml: TRnQXML;
//  item: TsdElement;
begin
      xml := TRnQXML.CreateEx(NIL, false, false, True, 'iq');
//        xml.Prolog.Version := '1.0';
//        xml.Options := xml.Options + [sxoSaveWithoutLineBreaks];
//        xml.Prolog.Encoding := '';
        with xml.Root do
         begin
           AttributeAdd(UTF8String('id'), pXMLEl.AttributeValueByName['id']);
           AttributeAdd('to', ServerJID);
           AttributeAdd('type', 'result');
           with NodeNew('query') do
            begin
             AttributeAdd('xmlns', 'jabber:iq:version');
             if showclientid then
               begin
                 NodeNew('name').Value := 'R&Q';
                 NodeNew('version').ValueUnicode := intToStr(RnQBuild);
                 NodeNew('os').Value := 'Win';
               end
              else
               begin
                 NodeNew('name');
                 NodeNew('version');
                 NodeNew('os');
               end
            end;
         end;
       sendXML(xml);
       xml.Free;
end;

procedure TxmppSession.req_roster();
var
  xml: TRnQXML;
//  item: TsdElement;
begin
      xml := TRnQXML.CreateEx(nil, false, false, True, 'iq');
//        xml.Prolog.Version := '1.0';
//        xml.Options := xml.Options + [sxoSaveWithoutLineBreaks];
//        xml.Prolog.Encoding := '';
        with xml.Root do
         begin
           AttributeAdd('type', 'get');
           AttributeAdd('id', 'rstr1');
           NodeNew('query').AttributeAdd('xmlns', 'jabber:iq:roster');
         end;
       sendXML(xml);
       xml.Free;
end;

procedure TxmppSession.replyService_Discovery(pXMLEl : TsdElement);
var
  xml: TRnQXML;
  item: TsdElement;
begin
  // Поддержка только пока следующих расширений
  //  XEP-0092: Software Version (jabber_iq_version)
{
  Result := UTF8Encode(CompressSpaces(Format(
            '<iq                                                            ' +
            '    type=''result''                                            ' +
            '    to=''%S''                                                  ' +
            '    from=''%S''                                                ' +
            '    id=''%S''>                                                 ' +
            '  <query xmlns=''http://jabber.org/protocol/disco#info''>      ' +
            '    <feature var=''jabber:iq:version''/>                       ' +
            '  </query>                                                     ' +
            '</iq>                                                          ' ,
            [JIDTo, JIDFrom, JIDID])));}
      xml := TRnQXML.CreateEx(nil, false, false, True, 'iq');
//        xml.Prolog.Version := '1.0';
//        xml.Options := xml.Options + [sxoSaveWithoutLineBreaks];
//        xml.Prolog.Encoding := '';
        with xml.Root do
         begin
           AttributeAdd('type', 'result');
           AttributeAdd(Utf8String('id'), pXMLEl.AttributeValueByName['id']);
           item := TsdElement(NodeNew('query'));
           item.AttributeAdd('xmlns', XEP0030_Service_Discovery);
           item.NodeNew('feature').AttributeAdd('var', XEP0092_Software_Version);
         end;
       sendXML(xml);
       xml.Free;
end;

procedure TxmppSession.send_ping(pXMLEl : TsdElement);
var
  xml: TRnQXML;
//  item: TsdElement;
begin
  xml := TRnQXML.CreateEx(nil, false, false, True, 'iq');
//        xml.Prolog.Version := '1.0';
//  xml.Options := xml.Options + [sxoSaveWithoutLineBreaks];
//  xml.Prolog.Encoding := '';
  with xml.Root do
    begin
       AttributeAdd(UTF8String('id'), pXMLEl.AttributeValueByName['id']);
       AttributeAdd(UTF8String('to'), pXMLEl.AttributeValueByName['from']);
       AttributeAdd('type', 'result');
       AttributeAdd(UTF8String('from'), pXMLEl.AttributeValueByName['to']);
    end;
  sendXML(xml);
  xml.Free;
end;

procedure TxmppSession.process_roster(pXMLEl: TsdElement; isFullRoster: Boolean = false);
var
  item: TsdElement;
  item2: TXmlNode;
  i: Integer;
//  g_id,
  g_fl, srv_fl, l: Integer;
  vJID, vS1, vS2: String;
  cnt: TxmppContact;
  locCL: TRnQCList;
//  invCL, visCL: TRnQCList;
begin
  locCL := TRnQCList.Create;
  for I := 0 to pXMLEl.ContainerCount - 1 do
   begin
    item := TsdElement(pXMLEl.Containers[i]);
    if item.Name = 'item' then
      begin
        vJID := item.AttributeValueByNameWide['jid'];
        if vJID <> '' then
         begin
           cnt := getxmppContact(vJID);
           vS1 := item.AttributeValueByNameWide['subscription'];
           if vS1 <> '' then
             begin
               if vS1 = 'none' then
                begin
                 cnt.Authorized := false;
                 cnt.AuthorizedHim := False;
                end
               else
               if vS1 = 'to' then
                begin
                 cnt.Authorized := True;
                 cnt.AuthorizedHim := False;
                end
               else
               if vS1 = 'from' then
                begin
                 cnt.Authorized := False;
                 cnt.AuthorizedHim := True;
                end
               else
               if vS1 = 'both' then
                begin
                 cnt.Authorized := True;
                 cnt.AuthorizedHim := True;
                end
             end;
           vS1 := item.AttributeValueByNameWide['name'];
//           if vS1 <> '' then
             begin
               cnt.Display := vS1;
             end;
           item2 := item.NodeByName('group');
           if Assigned(item2) then
             begin
               vS2 := item2.Value;
               cnt.SetGroupName(vS2);
             end
            else
             vS2 := '';
           cnt.CntIsLocal := False;
           notInList.remove(cnt);
           locCL.add(cnt);
         end;
      end;
   end;
//  locCL.
    with locCL, TList(locCL) do
     for i:=0 to count-1 do
      with TxmppContact(getAt(i)) do
       begin
        if not Authorized then
          SetStatus(SC_UNK);
        OfflineClear;
      end;
  readList(LT_ROSTER).add(locCL);
  locCL.Free;
//  addContact(locCL, False);
{  readList(LT_VISIBLE).add(visCL);
  readList(LT_INVISIBLE).add(invCL);
  ignoreList.add(readList(LT_SPAM));
  invCL.Free;
  visCL.Free;}

 notifyListeners(IE_numOfContactsChanged);
end;

procedure TxmppSession.parse_presence(pXMLEl : TsdElement);
var
  vS, s2, s3: String;
  sA: RawByteString;
  uid: TUID;
//  res: TXMP_RESRC;
  resNum: Int8;
  isGTalk: Boolean;
  st: TXMPPstatus;
  item2 : TXmlNode;
  cont : TxmppContact;
begin
  vS := pXMLEl.AttributeValueByNameWide['from'];
  uid := vS;
  cont := getxmppContact(uid);
  resNum := cont.AddRes(uid);
  if Assigned(cont) then
  begin
    eventOldStatus := byte(cont.status);
    eventOldInvisible := cont.invisible;
   vS := pXMLEl.AttributeValueByNameWide['type'];
   if vS = '' then
     begin
       st := SC_ONLINE;
       item2 := pXMLEl.NodeByName('show');
       if Assigned(item2) then
         vS := item2.ValueUnicode
        else
         vS := '';
       if vS = 'away' then
         st := mSC_AWAY
       else
       if vS = 'chat' then
         st := mSC_CHAT
       else
       if vS = 'dnd' then
         st := mSC_DND
       else
       if vS = 'xa' then
         st := mSC_XA;
       cont.SetStatus(st, resNum);
       item2 := pXMLEl.NodeByName('status');
       if Assigned(item2) then
         vS := item2.ValueUnicode
        else
         vS := '';
       cont.resources[resNum].xStatus.Desc := vS;

       item2 := pXMLEl.NodeByName('priority');
       if Assigned(item2) then
         vS := item2.ValueUnicode
        else
         vS := '';
       if vS > '' then
         cont.resources[resNum].priority := StrToIntDef(vS, 0);

       item2 := pXMLEl.NodeByAttributeValue('x', 'xmlns', 'vcard-temp:x:update');
       if Assigned(item2) then
         begin
           item2 := item2.NodeByName('Photo');
           if Assigned(item2) then
             sA := item2.Value
            else
             sA := '';
           if sA > '' then
             if Length(sA) = 40 then
               cont.XIcon.Hash := hex2StrSafe(sA)
              else
               cont.XIcon.Hash := sA;

             if (Length(cont.XIcon.hash) = 20) and
                (cont.XIcon.hash <> cont.Icon.hash_safe)then
              begin
                eventContactRes.cnt := cont;
                eventContactRes.resNum := resNum;
                notifyListeners(IE_avatar_changed);
              end;
         end
        else
         vS := '';

       item2 := pXMLEl.NodeByAttributeValue('c', 'xmlns', 'http://jabber.org/protocol/caps');
       isGTalk := False;
       if not Assigned(item2) then
        begin
         item2 := pXMLEl.NodeByAttributeValue('caps:c', 'xmlns:caps', 'http://jabber.org/protocol/caps');
         isGTalk := True;
        end;

       if Assigned(item2) then
         begin
           vS := item2.AttributeValueByNameWide['node'];
           if vS > '' then
             begin
               s2 := item2.AttributeValueByNameWide['ver'];
               cont.resources[resNum].caps_hash := s2;
               if s2 > '' then
                 begin
                   ReqClientCaps(cont, resNum, vS, s2);
                 end;
               if not isGTalk then
                begin
                 s2 := item2.AttributeValueByNameWide['ext'];
                 if (s2 > '') and not isGTalk then
                   begin // MUST add caching of requests
                     repeat
                       s3 := chop(' ', s2);
                       ReqClientCaps(cont, resNum, vS, s3, False);
                     until (s2='');
                   end;
                end;
             end;
         end
        else
         vS := '';

       eventContactRes.cnt := cont;
       eventContactRes.resNum := resNum;
       notifyListeners(IE_statusChanged);
     end
   else
   if vS = 'unavailable' then
     begin
       cont.SetStatus(SC_OFFLINE, resNum);
       eventContactRes.cnt := cont;
       eventContactRes.resNum := resNum;
       notifyListeners(IE_statusChanged);
     end
   else
   if vS = 'subscribe' then
     begin
       eventMsg := 'Please authorise me';
       eventContactRes.cnt := cont;
       eventContactRes.resNum := resNum;
       notifyListeners(IE_authReq);
     end
   else
   if vS = 'subscribed' then
     begin
       cont.Authorized := True;
       eventContactRes.cnt := cont;
       eventContactRes.resNum := resNum;
       notifyListeners(IE_contactupdate);
     end
   else
   if vS = 'unsubscribed' then
     begin
       cont.Authorized := False;
       eventContactRes.cnt := cont;
       eventContactRes.resNum := resNum;
       notifyListeners(IE_contactupdate);
     end
   ;
  end;
end;

procedure TxmppSession.ReqClientCaps(cnt: TRnQContact; rid: Int8;
               s1, s2: String; isFull: boolean = True);
var
  xml: TRnQXML;
  nd: TXmlNode;
begin
  xml := TRnQXML.CreateEx(nil, false, false, True, 'iq');
    with xml.Root do
     begin
       if isFull then
         AttributeAdd('id', 'disco1')
        else
         AttributeAdd('id', 'disco_add');
       AttributeAdd('to', TxmppContact(cnt).GetResUID(rid));
       AttributeAdd('type', 'get');

       nd := NodeNew('query');
       nd.AttributeAdd('xmlns', 'http://jabber.org/protocol/disco#info');
       nd.AttributeAdd('node', s1+'#'+s2);
     end;
   sendXML(xml);
   xml.Free;
end;

procedure TxmppSession.parse_discoCaps(pXMLEl: TsdElement);
var
  n1, n2: TXmlNode;
  isFullDisco: Boolean;
  l: TList;
  i, a: Integer;
  vS: String;
  cnt: TxmppContact;
  resNum: Int8;
  rid: TUID;
begin
  n1 := pXMLEl.NodeByName('query');
  if Assigned(n1) then
  begin
    vS := pXMLEl.AttributeValueByNameWide['from'];

    cnt := getxmppContact(vS);
    if not Assigned(cnt) then
      Exit;
    resNum := cnt.AddRes(vS);
    if resNum < 0 then
      Exit;
    l := TList.Create;
    vS := pXMLEl.AttributeValueByNameWide['id'];
    isFullDisco := vS = 'disco1';
    if isFullDisco then
     begin
      n1.NodesByName('identity', l);
    if l.Count > 0 then
     for I := 0 to l.Count-1 do
      begin
          n2 := TXmlNode(l.Items[i]);
          vS := n2.AttributeValueByNameWide['category'];
        if vS = 'client' then
          begin
             vS := n2.AttributeValueByNameWide['name'];
            cnt.resources[resNum].ClientID := vS;
          end;
      end;
    l.Clear;
     end;
    n1.NodesByName('feature', l);
    i := l.Count;
    if isFullDisco then
      a := 0
     else
      a := Length(cnt.resources[resNum].caps);

    SetLength(cnt.resources[resNum].caps, a+i);
    if i > 0 then
     for I := 0 to l.Count-1 do
      begin
        n2 := TXmlNode(l.Items[i]);
        vS := n2.AttributeValueByNameWide['var'];
        cnt.resources[resNum].caps[a+i] := vS;
      end;
    l.Clear;
    l.Free;
  end;

end;

procedure TxmppSession.parse_Msg(pXMLEl: TsdElement);
var
  vS, vS2, vType: String;
//  elms: TRnQXMLNamedElems;
  I, cnt: Integer;
begin
  vS := pXMLEl.AttributeValueByNameWide['type'];
  vS2 := pXMLEl.AttributeValueByNameWide['from'];

  vType := pXMLEl.AttributeValueByNameWide['type'];
  if vType = 'error' then
    begin
      eventContactRes.cnt := getxmppContact(vS2);
      eventMsgID := StrToInt64Def(pXMLEl.AttributeValueByNameWide['id'], -1);
      notifyListeners(IE_msgError);
      Exit;
    end;

  eventContactRes.cnt := getxmppContact(vS2);
  eventFlags := 0;
  if Assigned(eventContact) then
   begin
    eventContact.typing.bIsTyping := False;
    eventTime := now;
    cnt := pXMLEl.ContainerCount;
    for I := 0 to cnt - 1 do
     begin
      if pXMLEl.Containers[i].Name = 'body' then
        begin

         eventMsg := strFromHTML(pXMLEl.Containers[i].ValueUnicode);
         notifyListeners(IE_msg);
        end;
     end;
   end;
//  notifyListeners(IE_msg);
end;


procedure TxmppSession.send_status();
var
  xml: TRnQXML;
  item: TsdElement;
  n: TXmlNode;
  caps: UTF8String;
begin
      xml := TRnQXML.CreateEx(nil, false, false, True, 'presence');
//        xml.Prolog.Version := '1.0';
//        xml.Options := xml.Options + [sxoSaveWithoutLineBreaks];
//        xml.Prolog.Encoding := '';
        with xml.Root do
         begin
           NodeNew('priority').ValueAsInteger := fPriority;
           n := NodeNew('c');
           n.AttributeAdd(UTF8String('node'), UTF8String(not2Translate[not2TranslateSite]));
           n.AttributeAdd('ver', '0.1');

           caps := 'avatar';
           if mediaCaps_<>'' then
             caps := caps+' '+mediaCaps_;
           n.AttributeAdd(UTF8String('ext'), mediaCaps_);
           n.AttributeAdd('xmlns', 'http://jabber.org/protocol/caps');

           NodeNew('show').Value := XMPPstatus2codeStr[curStatus];
           NodeNew('status').ValueUnicode := curXStatus.Desc;
         end;
{
       <x xmlns="vcard-temp:x:update"/>
}
       sendXML(xml);
       xml.Free;
end;

function TxmppSession.sendMsg(cnt: TRnQContact; var flags: dword; const msg: string; var requiredACK: boolean): integer; // returns handle
begin
 Result := sendMsg(cnt, flags, msg, requiredACK, ''); // returns handle
end;

function TxmppSession.sendMsg(cnt: TRnQContact; var flags: dword; const msg: string; var requiredACK: boolean; CnTResourse: String): integer; // returns handle
var
  mraMsgFlags : Integer;
//  mail, s : AnsiString;
  xml : TRnQXML;
  item : TsdElement;
  toS : String;
begin
  mraMsgFlags := 0;
      xml := TRnQXML.CreateEx(nil, false, false, True, 'message');
//        xml.Prolog.Version := '1.0';
//        xml.Options := xml.Options + [sxoSaveWithoutLineBreaks];
//        xml.Prolog.Encoding := '';
        with xml.Root do
         begin
           toS := cnt.UID2cmp;
           if CnTResourse > '' then
             toS := toS + '/' + CnTResourse;
           AttributeAdd('to', toS);
           AttributeAdd('id', IntToStr(MSGref));
//           Properties.Add('type', 'normal');
           AttributeAdd('type', 'chat');
           NodeNew('body').ValueUnicode := str2html(msg);

         end;
  Result := sendXML(xml);
  xml.Free;
  Result := addRef(REF_msg, TxmppContact(cnt));
//  requiredACK := False;
  requiredACK := True;
end;


procedure TxmppSession.parse_MyInfo(const pkt: RawByteString);
var
  fName, fValue : String;
  ofs : Integer;
begin
  ofs := 1;
//  while ofs < (Length(pkt)-6) do
//    begin
//     fName := unUTF(getDLS(pkt, ofs));
//     fValue := unUTF(getDLS(pkt, ofs));
//     if fName = 'MESSAGES.TOTAL' then
//       MailsCntAll := StrToIntDef(fValue, 0)
//     else if fName = 'MESSAGES.UNREAD' then
//       MailsCntUnread := StrToIntDef(fValue, 0)
//     else if fName = 'MRIM.NICKNAME' then
////       with getMyInfo
////       MyInfo0.nick := unUTF(fValue);
////       getMyInfo.nick := unUTF(fValue);
//       getMyInfo.nick := fValue;
//    end;

  eventInt := MailsCntUnread;
  notifyListeners(IE_email_cnt);
end;


procedure TxmppSession.parse_Ack(const pkt : RawByteString; seq : Integer);
var
  ofs, st : Integer;
begin
  ofs := 1;
{  st := readINT(pkt, ofs);
  eventInt   := seq;
  eventMsgID := seq;
  if st = MESSAGE_DELIVERED then
    notifyListeners(IE_ack)
   else
    notifyListeners(IE_msgError);}
end;

procedure TxmppSession.parse_CntAddAck(pkt : RawByteString; seq : Integer);
var
  st : Integer;
  ofs : Integer;
  id  : Integer;
  cnt : TxmppContact;
begin
  ofs := 1;
{  st := readINT(pkt, ofs);
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
      cnt := refs[seq].cnt;
      if Assigned(cnt) then
       begin
        cnt.CntIsLocal := True;
        cnt.SSIID := 0;
        eventContact := cnt;
        notifyListeners(IE_contactupdate);
       end;
     end;}
end;

procedure TxmppSession.Parse_offlineMsg(pkt : RawByteString);
var
  id : Int64;
  i, ofs : Integer;
  mraMsgFlags : Integer;
  mail : AnsiString;
  s : AnsiString;
  msg : AnsiString;
  bnd, dt : AnsiString;
  c : TxmppContact;
  isBase64 : Boolean;
begin
  ofs := 1;
{
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

  i := pos(AnsiString('From: '),pkt);
  s := Copy(pkt, i+Length('From:'), MAXWORD);
  s := Trim(chop(#10, s));
  mail := s;
  eventContact := getMRAContact(mail);

  i := pos(AnsiString('Date: '),pkt);
  s := Copy(pkt, i+Length('Date:'), MAXWORD);
  dt := Trim(chop(#10, s));
  eventTime := now;
//  mail := s;
  i := pos(AnsiString('X-MRIM-Flags: '),pkt);
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

  i := pos(AnsiString('Boundary: '),pkt);
  if i > 0 then
    begin
      s := Copy(pkt, i+Length('Boundary:'), MAXWORD);
      bnd := Trim(chop(#10, s));

      i := pos(AnsiString('Version: '),pkt);
      s := Copy(pkt, i+Length('Version:'), MAXWORD);
      chop(#10, s);
      chop(#10, s);
    //  i := pos(bnd, s);
      msg := chop(bnd, s);
      SetLength(msg, length(msg)-3);
    end
   else
    begin
    i := pos(AnsiString('boundary='),pkt);
    if i > 0 then
      begin
        s := Copy(pkt, i+Length('boundary='), MAXWORD);
        bnd := Trim(chop(#10, s));

        i := pos(AnsiString('text/plain;'),pkt);
        msg := Copy(pkt, i+Length('text/plain;'), MAXWORD);
        s := chop(bnd, msg);
        msg := '';
        i := pos(AnsiString('Content-Transfer-Encoding:'), s);
        if i > 0 then
         begin
          if pos(AnsiString('Content-Transfer-Encoding: base64'), s) > 0 then
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
  s := msg;
//  eventMsg := msg;

  if (mraMsgFlags and MESSAGE_FLAG_CONTACT<>0) then
   begin
    eventContacts:=TRnQCList.create;
//    s := eventMsg;
    while s > '' do
      try
        c:=getMRAContact(chop(#$FE,s));
        if isMyAcc(c) then
          chop(#$FE,s)
        else
         begin
          if Assigned(c) and not aRoster.exists(c) then
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
    if Length(s) > 1 then
     begin
      s := Base64DecodeString(s);
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
      eventMsg := unUTF(Base64DecodeString(s));
  eventMsg := dt + CRLF+ eventMsg;

  notifyListeners(IE_msg);
}
end;

procedure TxmppSession.parse_auth(const pkt : RawByteString);
var
  mail : AnsiString;
  ofs : Integer;
//  c : TMRAContact;
begin
  ofs := 1;
{  mail := getDLS(pkt, ofs);
  eventContact := getMRAContact(mail);
  if Assigned(eventContact) then
    begin
     eventContact.Authorized := True;
//     notifyListeners(IE_statuschanged);
     notifyListeners(IE_contactupdate);
    end;
}
end;

procedure TxmppSession.parse_Anketa(const pkt : RawByteString; seq : Integer);
type
  TField = record
     fName, fValue : String;
   end;
  TFieldsArray = array of TField;
var
  isWPSearch : Boolean;
begin
end;

   {$IFDEF RNQ_AVATARS}
procedure TxmppSession.parse_Avatar(pXMLEl: TsdElement);
var
  vS: String;
  item2: TXmlNode;
  cont: TxmppContact;
  tmpStr: RawByteString;
  i: Integer;
begin
  vS := pXMLEl.AttributeValueByNameWide['from'];
  cont := getxmppContact(vS);
  if Assigned(cont) then
  begin
//   vS := pXMLEl.AttributeValueByNameWide['type'];

   vS := pXMLEl.AttributeValueByNameWide['id'];
   if StartsStr('getpic', vS) then
     begin
       item2 := pXMLEl.NodeByName('vCard');
       if Assigned(item2) and (item2.AttributeValueByName['xmlns']='vcard-temp') then
         begin
           item2 := item2.NodeByName('PHOTO');
           if Assigned(item2) then
             begin
               item2 := item2.NodeByName('BINVAL');
               if Assigned(item2) then
                 begin
                   tmpStr := item2.Value;
//                   tmpStr := (vS);
                   if tmpStr > '' then
                     begin
                       i := length(tmpStr) mod 4;
                       if i <> 0 then
                         tmpStr := tmpStr + StringOfChar(AnsiChar('='), i);
                      tmpStr := Base64DecodeString(tmpStr);
                      if tmpStr > '' then
                      begin
                        eventStream:= TMemoryStream.Create;
                        eventStream.Clear;
                        eventStream.Write(tmpStr[1], Length(tmpStr));
                        eventStream.Seek(0,0);
                        tmpStr:= '';
                    //    eventFilename := PAFormat[DetectAvatarFormatBuffer(tmpStr)];
                        eventContactRes.cnt := cont;
                        notifyListeners(IE_getAvtr);
                      end;
                       tmpStr := '';
                     end;
                 end
                else
                 vS := '';
             end;
         end;
     end;
  end;
end;
   {$ENDIF RNQ_AVATARS}

procedure TxmppSession.sendReqOfflineMsgs;
begin
end;

procedure TxmppSession.sendDeleteOfflineMsgs;
var
  i,k : Integer;
begin
{  k := Length(OfflMsgs);
  if k>0 then
   begin
    for I := 0 to k - 1 do
      sendPkt(MRIM_CS_DELETE_OFFLINE_MESSAGE, qword_LEasStr(OfflMsgs[i]));
    SetLength(OfflMsgs, 0);
   end;}
end;

procedure TxmppSession.sendKeepalive;
begin
//  sendPkt(MRIM_CS_PING);
end;

function  TxmppSession.GetCurStatCode(IsFutureStat: Boolean = false): RawByteString;
{var
  st1, stCode: cardinal;
  s1: RawByteString;
  st: Byte;}
begin
{  if IsFutureStat then
    st := startingStatus
   else
    st := Byte(curStatus);

  if fVisibility = mVI_privacy then
       stCode := STATUS_FLAG_INVISIBLE
      else
       stCode := 0;
  if curXStatus.id = '' then
    begin
     st1 := MRAstatus2code[TMRAStatus(st)] or stCode;
     s1 := Length_DLE(MRAstatus2codeStr[TMRAStatus(st)])+
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
}
end;

function TxmppSession.SendSMS(cnt : TRnQContact; const phnN : AnsiString; const msg : String) : Integer;
var
  mraMsgFlags : Integer;
//  mail, s : AnsiString;
begin
  mraMsgFlags := 0;
{  Result := sendPkt(MRIM_CS_SMS_SEND, //dword_LEasStr(SNACref)+
                    dword_LEasStr(mraMsgFlags)+
                    Length_DLE(phnN)+
                    Length_DLE(StrToUnicodeLE(msg))
                   );
//  result:=addRef(REF_msg, cnt.UID);
//  requiredACK := True;
}
end;

procedure TxmppSession.sendAck(const mail : AnsiString; id : TmsgID);
begin
{  sendPkt(MRIM_CS_MESSAGE_RECV, //dword_LEasStr(SNACref)+
                    Length_DLE(mail)+
                    dword_LEasStr(id)
                   );
}
end;

function TxmppSession.getFlapBuf : RawByteString;
begin
  Result := q.str
end;

procedure TxmppSession.AuthGrant(Cnt : TRnQContact);
var
  xml : TRnQXML;
begin
  xml := TRnQXML.CreateEx(nil, false, false, True, 'presence');
//        xml.Prolog.Version := '1.0';
//        xml.Options := xml.Options + [sxoSaveWithoutLineBreaks];
//        xml.Prolog.Encoding := '';
        with xml.Root do
         begin
//           toS := cnt.UID2cmp;
//           if CnTResourse > '' then
//             toS := toS + '/' + CnTResourse;
           AttributeAdd('to', cnt.UID2cmp);
//           Properties.Add('type', 'normal');
           AttributeAdd('type', 'subscribed');
//           Properties.Add('from', getMyInfo.UID2cmp);
//           Items.Add('body', str2html(msg));
         end;
  sendXML(xml);
  xml.Free;
end;

procedure TxmppSession.AuthCancel(Cnt : TRnQContact);
var
  xml : TRnQXML;
begin
  xml := TRnQXML.CreateEx(nil, false, false, True, 'presence');
//        xml.Prolog.Version := '1.0';
//        xml.Options := xml.Options + [sxoSaveWithoutLineBreaks];
//        xml.Prolog.Encoding := '';
        with xml.Root do
         begin
//           toS := cnt.UID2cmp;
//           if CnTResourse > '' then
//             toS := toS + '/' + CnTResourse;
           AttributeAdd('to', cnt.UID2cmp);
//           Properties.Add('type', 'normal');
           AttributeAdd('type', 'unsubscribed');
//           Properties.Add('from', getMyInfo.UID2cmp);
//           Items.Add('body', str2html(msg));
         end;
  sendXML(xml);
  xml.Free;
end;

procedure TxmppSession.AuthRequest(cnt : TRnQContact; const reason : String);
var
  xml : TRnQXML;
begin
  xml := TRnQXML.CreateEx(nil, false, false, True, 'presence');
//        xml.Prolog.Version := '1.0';
//        xml.Options := xml.Options + [sxoSaveWithoutLineBreaks];
//        xml.Prolog.Encoding := '';
        with xml.Root do
         begin
//           toS := cnt.UID2cmp;
//           if CnTResourse > '' then
//             toS := toS + '/' + CnTResourse;
           AttributeAdd('to', cnt.UID2cmp);
//           Properties.Add('type', 'normal');
           AttributeAdd('type', 'subscribe');
//           Properties.Add('from', getMyInfo.UID2cmp);
//           Items.Add('body', str2html(msg));
         end;
  sendXML(xml);
  xml.Free;
end;

procedure TxmppSession.SSIAddContact(c : TxmppContact);
var
  xml : TRnQXML;
  item : TsdElement;
begin
  xml := TRnQXML.CreateEx(nil, false, false, True, 'iq');
//        xml.Prolog.Version := '1.0';
//        xml.Options := xml.Options + [sxoSaveWithoutLineBreaks];
//        xml.Prolog.Encoding := '';
        with xml.Root do
         begin
//           toS := cnt.UID2cmp;
//           if CnTResourse > '' then
//             toS := toS + '/' + CnTResourse;
           AttributeAdd('type', 'set');
//           Properties.Add('from', getMyInfo.UID2cmp);
           item := TsdElement(NodeNew('query'));
           Item.AttributeAdd('xmlns', 'jabber:iq:roster');
           Item := TsdElement(item.NodeNew('item'));
           Item.AttributeAdd('jid', c.UID2cmp);
           Item.AttributeAdd('name', c.displayed4All);
//           item.NodeNew('group').Value := groups.id2name(c.fGroupID);
           item.NodeNew('group').Value := groups.id2name(c.group);
         end;
  sendXML(xml);
  xml.Free;
//    Exit;
end;

procedure TxmppSession.SSIdeleteContact(c : TxmppContact);
var
  xml : TRnQXML;
  item : TsdElement;
begin
  xml := TRnQXML.CreateEx(nil, false, false, True, 'iq');
//        xml.Prolog.Version := '1.0';
//        xml.Options := xml.Options + [sxoSaveWithoutLineBreaks];
//        xml.Prolog.Encoding := '';
        with xml.Root do
         begin
//           toS := cnt.UID2cmp;
//           if CnTResourse > '' then
//             toS := toS + '/' + CnTResourse;
           AttributeAdd('type', 'set');
//           Properties.Add('from', getMyInfo.UID2cmp);
           item := TsdElement(NodeNew('query'));
           Item.AttributeAdd('xmlns', 'jabber:iq:roster');
             Item := TsdElement(item.NodeNew('item'));
             Item.AttributeAdd('jid', c.UID2cmp);
             Item.AttributeAdd('subscription', 'remove');
         end;
  sendXML(xml);
  xml.Free;
end;

procedure TxmppSession.SSI_updateContact(c : TxmppContact);
begin

end;

procedure TxmppSession.ReqUserInfo(cnt : TRnQContact);
//var
//  u, d : AnsiString;
begin
{  if not Assigned(cnt) or not isReady then
    Exit;
  d := cnt.UID2cmp;
  u := chop('@', d);
//  addRef(REF_wp, TMRAContact(cnt));
  sendPkt(MRIM_CS_WP_REQUEST, dword_LEasStr(MRIM_CS_WP_REQUEST_PARAM_USER)+
                              Length_DLE(u)+
                              dword_LEasStr(MRIM_CS_WP_REQUEST_PARAM_DOMAIN)+
                              Length_DLE(d))
}
end;

function TxmppSession.RequestIcon(cnt: TRnQContact): Boolean;
var
  xml: TRnQXML;
  item: TsdElement;
begin
  if isOnline then
    begin
     xml := TRnQXML.CreateEx(nil, false, false, True, 'iq');
          with xml.Root do
           begin

             AttributeAdd('to', cnt.UID2cmp);
             AttributeAdd('type', 'get');
             AttributeAdd('id', 'getpic'+ intToStr(FLAPseq));

             item := TsdElement(NodeNew('vCard'));
             Item.AttributeAdd('xmlns', 'vcard-temp');
           end;
     sendXML(xml);
     xml.Free;
     Result := True;
    end
   else
     Result := false;
end;

procedure TxmppSession.OpenGroupChat(chat, Nick: String; pass: String);
var
  xml: TRnQXML;
  item: TsdElement;
begin
  xml := TRnQXML.CreateEx(nil, false, false, True, 'presence');
        with xml.Root do
         begin

           AttributeAdd('to', chat+'/'+Nick);
           AttributeAdd('xml:lang', 'ru');
{
           item := Items.Add('x');
           Item.Properties.Add('xmlns', 'vcard-temp:x:update');
           item.Items.Add('photo', my_photo_hash);
}
           item := TsdElement(NodeNew('c'));
           Item.AttributeAdd('xmlns', 'http://jabber.org/protocol/caps');
           Item.AttributeAdd('node', 'http://rnq.ru');

           NodeNew('x').AttributeAdd('xmlns', 'http://jabber.org/protocol/muc');
         end;
  sendXML(xml);
  xml.Free;
end;

procedure TxmppSession.sendWPsearch(wp:TwpSearch; idx : Integer);
var
  pkt : AnsiString;
begin
  pkt := '';
{  if Length(wp.nick) > 0 then
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
}
end;

function TxmppSession.getPrefPage : TPrefFrameClass;
begin
  Result := TxmppFr;
end;

procedure TxmppSession.PlaceCall(cnt: TRnQContact; useVideo: boolean);
var
  contact: TXMPPContact;
  res: int8;
begin
  if cnt=NIL then
    exit;
  Exit;
  contact := getxmppContact(cnt.UID);
end;


procedure InitxmppProto;
var
  b1: Byte;
begin
//  SetLength(MRAstatuses, Byte(HIGH(TMRAstatus))+1);
  SetLength(XMPPstatuses, Byte(HIGH(TxmppStatus))+1);
  for b1 := byte(LOW(TxmppStatus)) to byte(HIGH(TxmppStatus)) do
    with XMPPstatuses[b1] do
     begin
      idx := b1;
      ShortName := XMPPstatus2img[TxmppStatus(b1)];
      Cptn      := XMPPstatus2ShowStr[TxmppStatus(b1)];
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

  SetLength(XMPPVis, Byte(HIGH(TxmppVisibility))+1);
  for b1 := byte(LOW(TxmppVisibility)) to byte(HIGH(TxmppVisibility)) do
    with XMPPVis[b1] do
     begin
      idx := b1;
      ShortName := XMPPvisib2str[TxmppVisibility(b1)];
      Cptn      := XMPPvisibility2ShowStr[TxmppVisibility(b1)];
//      ImageName := 'status.' + status2str[st1];
      ImageName := XMPPvisibility2imgName[TxmppVisibility(b1)];
     end;
  setLength(xmppVisMenu, 2);
  xmppVisMenu[0] := Byte(mVI_normal);
  xmppVisMenu[1] := Byte(mVI_privacy);
end;

procedure UnInitxmppProto;
var
  b2 : Byte;
begin
  for b2 := byte(LOW(TxmppStatus)) to byte(HIGH(TxmppStatus)) do
    with XMPPstatuses[B2] do
     begin
      SetLength(ShortName, 0);
      SetLength(Cptn, 0);
      SetLength(ImageName, 0);
     end;
  SetLength(XMPPstatuses, 0);
  setLength(statMenu, 0);

  for b2 := byte(LOW(TxmppVisibility)) to byte(HIGH(TxmppVisibility)) do
    with XMPPVis[B2] do
     begin
      SetLength(ShortName, 0);
      SetLength(Cptn, 0);
      SetLength(ImageName, 0);
     end;
  SetLength(XMPPVis, 0);
  setLength(xmppVisMenu, 0);
end;


INITIALIZATION
  InitxmppProto;
  RegisterProto(TxmppSession);
//  MRAHelper := TMRAHelper.Create;
//  RegisterProto(MRAHelper);

FINALIZATION
  UnInitxmppProto;

end.
