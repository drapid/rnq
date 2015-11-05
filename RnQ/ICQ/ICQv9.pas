{
This file is part of R&Q.
Under same license
}
unit ICQv9;
{$I RnQConfig.inc}
{$I NoRTTI.inc}

{$DEFINE usesVCL}
{ $DEFINE usesDC}

interface

uses
  windows, sysutils, classes,
  RnQNet,
  WinSock,
  ICQflap,
  RnQProtocol,
  ICQContacts, strutils,
  RQThemes, RDGlobal, RQUtil,
  RnQPrefsLib,
  ICQConsts;

type
  TwpResult=packed record
      nick,first,last,email:string;
      StsMSG : String;
      BDay   : TDateTime;
      uin    : TUID;
      authRequired:boolean;
//      status:byte;  // 0=offline 1=online 2=don't know
      gender : byte;
      status : word;  // 0=offline 1=online 2=don't know
      age    : word;
      BaseID : Word;
    end; // TwpResult

  TwpSearch=packed record
    nick,first,last,email,city,state, keyword:string;
    uin:TUID;
    Token : RawByteString;
    gender, lang:byte;
    onlineOnly:boolean;
    country:word;
    wInterest : Word;
    age:integer;
   end; // TwpSearch

  TOSSIItem = class(TObject)
   public
    ItemType : Byte;
    FAuthorized: boolean;
    ItemID, GroupID: integer;
    ItemName : AnsiString;
//    ItemNameU  : String;
    FInfoToken : RawByteString;
    FProto     : RawByteString; // may be "facebook" or "gtalk"
    ExtData    : RawByteString;
//    Debug      : String;
//    ExtInfo:   string;
    //    FNick,
    Caption    : String;
    Fnote      : String;
    FCellular  : String;
    FCellular2 : String;
    FCellular3 : String;
    FMail      : String;
    FFirstMsg: TDateTime;
    isNIL : Boolean; // In Not-In-List group
    function   Clone : TOSSIItem;
  end;

  Tssi = record
    itemCnt: integer;
    modTime: TDateTime;
    items:   TStringList;
  end;

type
  TsplitProc=procedure(const s: RawByteString) of object;
  TsplitSSIProc=procedure(items: array of TOSSIItem) of object;

  PSSIEvent = ^TSSIEvent;
  TSSIEvent = class(TObject)
   public
    // ack fields
    timeSent:TdateTime;
    ID  : Int64;
    NUM : Integer;
    kind: integer;
//    uin:integer;
//    flags : Cardinal;
//    UID   : TUID;
    Item  : TOSSIItem;
//    email : string;
//    info  : string;
//    cl:TRnQCList;
//    wrote,lastmodify:Tdatetime;
//    filepos:integer;
    constructor Create;// override;
    destructor Destroy; override; {$IFDEF DELPHI9_UP} final; {$ENDIF DELPHI9_UP}
//    function   toString:string;
//    procedure  fromString(s:string);
    function   Clone : TSSIEvent;
   end; // TSSIEvent

  TSSIacks = class(Tlist)

//    function  toString:string;
//    procedure fromString(s:string);

    function empty:boolean;

    destructor Destroy; override; {$IFDEF DELPHI9_UP} final; {$ENDIF DELPHI9_UP}
    procedure Clear; override; {$IFDEF DELPHI9_UP} final; {$ENDIF DELPHI9_UP}
//    procedure clearU;
//    function add(kind: Integer; dest:TUID; flags:integer=0; const info:string=''):TSSIEvent; overload;
//    function add(kind: Integer; dest:TUID; flags:integer; cl:TRnQCList):TSSIEvent; overload;
//    function add(ref : Int64; Num : Integer; kind: Integer; dest:TUID):TSSIEvent; overload;
    function add(ref : Int64; Num : Integer; kind: Integer; item : TOSSIItem):TSSIEvent; overload;
    function getAt(const idx:integer):TSSIEvent;
    function findID(id:Integer; NUM:Integer = -1):integer;
//    function remove(ev:TSSIEvent):boolean; overload;
//    function stFor(who:Tcontact):boolean;

//    procedure updateScreenFor(uin: TUID);
   end; // TSSIacks

  TmsgID = int64;

  TicqEvent= (
    IE_error = Byte(RnQProtocol.IE_error),
    IE_online,
    IE_offline,
    IE_oncoming,
    IE_offgoing,
    IE_msg,
    IE_buzz,
    IE_userinfo = Byte(High(RnQProtocol.TProtoEvent))+20,
    IE_userinfoCP,
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
    IE_ProxySent,
    IE_ProxyGot,
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
    IE_contactSelfDeleted,
    IE_redraw,
    IE_typing,

    IE_getAvtr,
    IE_avatar_changed,
    IE_srvSomeInfo,
    IE_StickerMsg,
    IE_MultiChat
  );

  TicqPhase=(
    null_,               // offline
 {$IFDEF USE_REGUIN}
    creating_uin_,      // asking for a new uin
 {$ENDIF USE_REGUIN}
    connecting_,         // trying to reach the login server
    login_,              // performing login on login server
    reconnecting_,       // trying to reach the service server
    relogin_,               // performing login on service server
    settingup_,          // setting up things
    online_

  );

  TicqSession=class;

  TicqNotify=procedure (Sender:TicqSession; event:TicqEvent) of object;

  TicqDCmode=(DC_NONE, DC_UPONAUTH, DC_ROSTER, DC_EVERYONE, DC_FAKE );

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
    REF_login
  );

  TSessionParams = record
    secret     : String;
    token      : String;
    tokenExpIn : Integer;
    tokenTime  : Integer;
  end;


{$IFDEF usesDC}

  TICQdirect=class(TProtoDirect)
{  private
    P_host, P_port: AnsiString;
  public
    sock    : TRnQSocket;
    eventID : TmsgID;
    contact : TICQContact;
    directs : Tdirects;
    imserver : boolean;
    imSender : Boolean;
    needResume : Boolean;
    Directed : Boolean;
    UseLocProxy : Boolean;
    mode : TDirectMode;
    stage : byte;
    kind :(DK_none, DK_file);
    fileDesc : String;
//    fileName :string;
//    fileData :string;
    buf : RawByteString;
    fileCntReceived, fileCntTotal:integer;
    fileSizeReceived, fileSizeTotal: Int64;
    transferChkSum, fileChkSum : Cardinal;
    receivedChkSum : Cardinal;
//    Received : Int64;
    fileName: String;
    myspeed :integer;
    hisVer :integer;
    AOLProxy : record
                 ip   : Cardinal;
                 port : word;
               end;
    data :pointer;}
    constructor Create; Override;
//    destructor Destroy; override;
   private
//    FOnDataAvailable, FOnDisconnect : TDirectDataAvailable;
//    FOnDataNext     : TDirectDataNext;
//    FOnNotification : TDirectNotification;
    procedure connected(Sender: TObject; Error: Word);
    procedure received(Sender: TObject; Error: Word);
    procedure sended(Sender: TObject; Error: Word);
    procedure disconnected(Sender: TObject; Error: Word);
//    function  myPort:integer;
    function  myinfo:TICQContact;
//    procedure sendPkt(const s: RawByteString);
    function  sendProxyCMD(cmd, flags :word; const data: RawByteString):boolean;

    procedure connected2cli;
//    procedure sendACK1;
//    procedure sendACK2;
//    procedure sendACK3;
//    procedure sendVcard;
//    procedure sendSpeed;
//    procedure parseFileDC0101(s : RawByteString);
    function  parseFileDC0101(s : RawByteString) : Boolean;
    function  parseFileDC0205(s : RawByteString) : Boolean; // Resume request
    procedure sendFilePrompt; // 0101
    procedure sendACK_File;   // 0202
    procedure sendDone_File;  // 0204
//    procedure parseVcard(s : RawByteString);
   public
//    destructor Destroy;
    procedure connect;
    procedure connect2proxy;
    procedure listen;
    procedure close;
    procedure Failed;
//    procedure ProcessSend;
    procedure DoneTransfer;
//    procedure logMsg(err : Word; const msg : String);
//    property ICQ : TicqSession read TicqSession(fproto);
   end; // TICQdirect
{$ENDIF usesDC}

  TICQSessionSubType = (SESS_IM=0, SESS_AVATARS=1, SESS_NEW_UIN=2);

//  TicqSession = class(TRnQProtocol, IRnQProtocol)
  TicqSession = class(TRnQProtocol)
   public
//    const ContactType : TRnQContactType =  TICQContact;
//    type ContactType = TICQContact;
    const ContactType : TClass =  TICQContact;
   private
    phase              : TicqPhase;
    wasUINwp           : boolean;  // trigger a last result at first result
//    creatingUIN        : boolean;  // this is a special session, to create uin
//    isAvatarSession    : boolean;  // this is a special session, to get avatars
    protoType : TICQSessionSubType; // main session; to create uin; to get avatars
    previousInvisible  : boolean;
    P_webaware         : boolean;
    P_authneeded       : boolean;
    P_showInfo         : byte;
//    startingInvisible  : boolean;
    startingVisibility : Tvisibility;
    startingStatus     : TICQstatus;
    curStatus          : TICQstatus;
    fVisibility        : Tvisibility;

    Q                  : TflapQueue;
    FLAPseq            : word;
    SNACref            : TmsgID;
    cookie             : RawByteString;
    waitingNewPwd      : RawByteString;
    cookieTime         : TDateTime;
    P_DCmode           : TicqDCmode;
    fDC_Fake_ip        : TInAddr;
    fDC_Fake_port      : word;
    fSSLServer         : String;
    fOscarProxyServer  : String;
    refs               :array [1..maxRefs] of record
                          kind:TrefKind;
                          uid : TUID;
                        end;
    SSIacks            : TSSIacks;
//    SSI_InServerTransaction : Boolean;
    SSI_InServerTransaction : Integer;

    savingMyInfo       :record
                          running:boolean;
                          ACKcount:integer;
                          c:TICQContact;
                         end;
    fRoster           :TRnQCList;
    fVisibleList       :TRnQCList;
    fInvisibleList     :TRnQCList;
{$IFDEF UseNotSSI}
    fIntVisibleList    :TRnQCList;
    fIntInvisibleList  :TRnQCList;
    fUseSSI, fUseLSI   : Boolean;
{$ENDIF UseNotSSI}
    tempVisibleList    :TRnQCList;
    spamList           :TRnQCList;

    fPwd               : String;
    fPwdHash           : ShortString;
    fSessionSecret     : String;
    fSessionToken      : String;
    fSessionTokenExpIn : Integer;
    fSessionTokenTime  : Integer;

    buzzedLastTime     : TDateTime;
//    getAvatarFor       : Integer;
    procedure setWebaware(value:boolean);
    procedure setAuthNeeded(value:boolean);
    procedure setDCmode(v:TicqDCmode);
    procedure set_DCfakeIP(ip : TInAddr);
    procedure setDCfakePort(port: Word);
    procedure setVisibility(v: Tvisibility);
    procedure proxy_connected;

 {$IFDEF UseNotSSI}
    procedure sendAddContact(const buinlist:AnsiString); overload;
    procedure sendRemoveContact(const buinlist:AnsiString); overload;
    procedure sendAddVisible(const buinlist:AnsiString); overload;
    procedure sendRemoveVisible(const buinlist:AnsiString); overload;
    procedure sendAddInvisible(const buinlist:AnsiString); overload;
    procedure sendRemoveInvisible(const buinlist:AnsiString); overload;
 {$ENDIF UseNotSSI}
    procedure sendAddTempContact(cl:TRnQCList); overload;
    procedure sendRemoveTempContact(const buinlist:AnsiString); // 0310

   public
      {$IFDEF RNQ_AVATARS}
        mainICQ : TicqSession; // Is PROTO_ICQ
        avt_icq : TicqSession;
      {$ENDIF RNQ_AVATARS}
//    localSSI,
    serverSSI: Tssi;
    localSSI_modTime : TDateTime;
    localSSI_itemCnt : Integer;
//    listener            : TicqNotify;
//    MyInfo0             : TICQcontact;
    birthdayFlag        : boolean;
    curXStatus          : byte;
    curXStatusStr       : TXStatStr;
    serviceServerAddr   : AnsiString;
    serviceServerPort   : AnsiString;
    // used to pass valors to listeners
    eventError          :TicqError;
    eventOldStatus      :TICQstatus;
    eventOldInvisible   :boolean;
    eventUrgent         :boolean;
    eventAccept         :TicqAccept;
    eventContact        :TICQContact;
    eventContacts       :TRnQCList;
    eventWP             :TwpResult;
    eventMsgA           : RawByteString;
    eventAddress        : string;
    eventNameA          : AnsiString;
    eventData           : RawByteString;
//    eventFilename       : string;
    eventInt            :integer;    // multi-purpose
    eventFlags          :dword;
//    eventFileSize       :LongWord;
    eventTime           :TdateTime;  // in local time
    eventMsgID          :TmsgID;
    eventStream: TMemoryStream;
{$IFDEF usesDC}
    eventDirect         :TICQDirect;
{$ENDIF usesDC}

//    acceptKey: string;
    uploadAvatarFN : String;
//    ConnectSSL : Boolean;
    pPublicEmail,
    showClientID,
    offlineMsgsChecked,
    SupportUTF,
    SendingUTF,
    UseCryptMsg,
    UseAdvMsg,
   {$IFDEF ICQ_OLD_STATUS}
  //    UseOldXSt,
   {$ENDIF ICQ_OLD_STATUS}
   {$IFDEF UseNotSSI}
     LoginMD5,
     useSSI2, useLSI2,
   {$ENDIF UseNotSSI}
    saveMD5Pwd,
    AvatarsSupport,
    AvatarsAutoGet,
    AvatarsAutoGetSWF : Boolean;
    myAvatarHash : RawByteString;

        class function NewInstance: TObject; override; {$IFDEF DELPHI9_UP} final; {$ENDIF DELPHI9_UP}
//    class function GetId: Word; override;
    class function _GetProtoName: string; OverRide; {$IFDEF DELPHI9_UP} final; {$ENDIF DELPHI9_UP}
//    class function _isValidUid(var uin:TUID):boolean; OverRide; final;
    class function _isProtoUid(var uin: TUID): boolean; OverRide; {$IFDEF DELPHI9_UP} final; {$ENDIF DELPHI9_UP}
    class function _isValidUid1(const uin: TUID): boolean; OverRide; {$IFDEF DELPHI9_UP} final; {$ENDIF DELPHI9_UP}
    class function _getDefHost: Thostport; OverRide; {$IFDEF DELPHI9_UP} final; {$ENDIF DELPHI9_UP}
    class function _getContactClass: TRnQCntClass; OverRide; {$IFDEF DELPHI9_UP} final; {$ENDIF DELPHI9_UP}
    class function _getProtoServers: String; OverRide; {$IFDEF DELPHI9_UP} final; {$ENDIF DELPHI9_UP}
    class function _getProtoID: Byte; OverRide; {$IFDEF DELPHI9_UP} final; {$ENDIF DELPHI9_UP}
    class function _CreateProto(const uid: TUID): TRnQProtocol; OverRide; {$IFDEF DELPHI9_UP} final; {$ENDIF DELPHI9_UP}
    class function  _RegisterUser(var pUID: TUID; var pPWD : String) : Boolean; OverRide; {$IFDEF DELPHI9_UP} final; {$ENDIF DELPHI9_UP}
    class function _MaxPWDLen: Integer; OverRide; final;
//    class function isValidUid(var uin:TUID):boolean;
//    function isValidUid(var uin:TUID):boolean;
//    function getContact(uid : TUID) : TRnQContact;
//    class function getICQContact(const uid: TUID): TICQContact; OverLoad;
//    class function getICQContact(uin: Integer): TICQContact; OverLoad;
    function getICQContact(const uid: TUID): TICQContact; OverLoad;
    function getICQContact(uin: Integer): TICQContact; OverLoad;

    function  getContact(const UID: TUID): TRnQContact; OverRide; {$IFDEF DELPHI9_UP} final; {$ENDIF DELPHI9_UP}
    function  getContactClass: TRnQCntClass; OverRide; {$IFDEF DELPHI9_UP} final; {$ENDIF DELPHI9_UP}

    function pwdEqual(const pass: String): Boolean; OverRide; {$IFDEF DELPHI9_UP} final; {$ENDIF DELPHI9_UP}

    property DCmode: TicqDCmode read P_dcmode write setDCmode;
    property DCfakeIP: TInAddr read fDC_Fake_ip write set_DCfakeIP;
    property DCfakePort: word read fDC_Fake_port write setDCfakePort;
 {$IFDEF UseNotSSI}
    property UseSSI: boolean read fUseSSI;
    property UseLSI3: boolean read fUseLSI;
 {$ENDIF UseNotSSI}
    procedure setDCfakeIP(ip: AnsiString);
//    procedure setStatusStr(s: String; Pic: AnsiString = '');
    procedure setStatusStr(xSt: byte; stStr: TXStatStr);
    procedure setStatusFull(st: byte; xSt: byte; stStr : TXStatStr);

//    constructor Create; override;
//    destructor Destroy; override;
    constructor Create(const id: TUID; subType : TICQSessionSubType);
    destructor Destroy; OverRide; {$IFDEF DELPHI9_UP} final; {$ENDIF DELPHI9_UP}
    procedure ResetPrefs; OverRide; {$IFDEF DELPHI9_UP} final; {$ENDIF DELPHI9_UP}
    procedure GetPrefs(var pp: TRnQPref); OverRide; {$IFDEF DELPHI9_UP} final; {$ENDIF DELPHI9_UP}
    procedure SetPrefs(pp: TRnQPref); OverRide; {$IFDEF DELPHI9_UP} final; {$ENDIF DELPHI9_UP}
    procedure Clear; OverRide; {$IFDEF DELPHI9_UP} final; {$ENDIF DELPHI9_UP}
    procedure connect;
//    procedure connect(createUIN: boolean; avt_session : Boolean = false); overload;
    procedure disconnect; OverRide; {$IFDEF DELPHI9_UP} final; {$ENDIF DELPHI9_UP}
//    procedure setStatus(s: Tstatus; inv: boolean);
    procedure setStatus(st: byte); overload; OverRide; {$IFDEF DELPHI9_UP} final; {$ENDIF DELPHI9_UP}
    procedure setStatus(s: TICQstatus; vis: Tvisibility); overload;
    function  getPwd: String; OverRide; Final;
    function  getPwdOnly: String; //OverRide; Final;
    procedure setPwd(const value: String); OverRide; Final;
    procedure refreshSessionSecret();
    function  getSession: TSessionParams; //OverRide; Final;

    function  getStatus: byte; OverRide; {$IFDEF DELPHI9_UP} final; {$ENDIF DELPHI9_UP}
    function  getVisibility: byte; OverRide; {$IFDEF DELPHI9_UP} final; {$ENDIF DELPHI9_UP}
    function  IsInvisible: Boolean; OverRide; {$IFDEF DELPHI9_UP} final; {$ENDIF DELPHI9_UP}
    function  isOnline: boolean; OverRide; {$IFDEF DELPHI9_UP} final; {$ENDIF DELPHI9_UP}
    function  isOffline: boolean; OverRide; {$IFDEF DELPHI9_UP} final; {$ENDIF DELPHI9_UP}
    function  isReady: boolean; OverRide; {$IFDEF DELPHI9_UP} final; {$ENDIF DELPHI9_UP}     // we can send commands
    function  isConnecting: boolean; OverRide; {$IFDEF DELPHI9_UP} final; {$ENDIF DELPHI9_UP}
    function  isSSCL: boolean; OverRide; {$IFDEF DELPHI9_UP} final; {$ENDIF DELPHI9_UP}
    function  imVisibleTo(c: TRnQContact): boolean; OverRide; {$IFDEF DELPHI9_UP} final; {$ENDIF DELPHI9_UP}
    function  getStatusName: String; OverRide; {$IFDEF DELPHI9_UP} final; {$ENDIF DELPHI9_UP}
    function  getStatusImg: TPicName; OverRide; {$IFDEF DELPHI9_UP} final; {$ENDIF DELPHI9_UP}
    function  getXStatus: byte; OverRide; {$IFDEF DELPHI9_UP} final; {$ENDIF DELPHI9_UP}
   public
    // manage contact lists
    function  readList(l: TLIST_TYPES) : TRnQCList; OverRide; {$IFDEF DELPHI9_UP} final; {$ENDIF DELPHI9_UP}

    procedure AddToList(l: TLIST_TYPES; cl: TRnQCList); OverLoad; OverRide; {$IFDEF DELPHI9_UP} final; {$ENDIF DELPHI9_UP}
    procedure RemFromList(l: TLIST_TYPES; cl: TRnQCList); OverLoad; OverRide; {$IFDEF DELPHI9_UP} final; {$ENDIF DELPHI9_UP}

    // manage contacts
//    function  validUid(var uin: TUID): boolean;  inline;
//    function  validUid1(const uin: TUID): boolean;  {$IFDEF HAS_INLINE} inline; {$ENDIF HAS_INLINE}
//    class function  isValidUid(var uin: TUID): boolean; Static;
    procedure AddToList(l: TLIST_TYPES; cnt: TRnQContact); OverLoad; OverRide; {$IFDEF DELPHI9_UP} final; {$ENDIF DELPHI9_UP}
    procedure RemFromList(l: TLIST_TYPES; cnt: TRnQContact); OverLoad; OverRide; {$IFDEF DELPHI9_UP} final; {$ENDIF DELPHI9_UP}
    function  isInList(l: TLIST_TYPES; cnt: TRnQContact) : Boolean; OverRide; {$IFDEF DELPHI9_UP} final; {$ENDIF DELPHI9_UP}

    function  addContact(c: TRnQContact; isLocal: Boolean = false):boolean; overload;OverRide; {$IFDEF DELPHI9_UP} final; {$ENDIF DELPHI9_UP}
    function  removeContact(cnt: TRnQContact): boolean;OverRide; {$IFDEF DELPHI9_UP} final; {$ENDIF DELPHI9_UP}

    procedure InputChangedFor(cnt: TRnQContact; InpIsEmpty : Boolean; timeOut : boolean = false); OverRide; {$IFDEF DELPHI9_UP} final; {$ENDIF DELPHI9_UP}
    procedure UpdateGroupOf(cnt: TRnQContact); OverRide; {$IFDEF DELPHI9_UP} final; {$ENDIF DELPHI9_UP}
    procedure getClientPicAndDesc4(cnt: TRnQContact; var pPic : TPicName; var CliDesc : String); OverRide; {$IFDEF DELPHI9_UP} final; {$ENDIF DELPHI9_UP}
    function  maxCharsFor(const c: TRnQContact; isBin : Boolean = false):integer; OverRide; {$IFDEF DELPHI9_UP} final; {$ENDIF DELPHI9_UP}
    function  compareStatusFor(cnt1, Cnt2: TRnqContact) : Smallint; OverRide; {$IFDEF DELPHI9_UP} final; {$ENDIF DELPHI9_UP}
    procedure sendKeepalive; OverRide; {$IFDEF DELPHI9_UP} final; {$ENDIF DELPHI9_UP}
    function  canAddCntOutOfGroup: Boolean; OverRide; {$IFDEF DELPHI9_UP} final; {$ENDIF DELPHI9_UP}

    function  getNewDirect: TProtoDirect; OverRide; {$IFDEF DELPHI9_UP} final; {$ENDIF DELPHI9_UP}

  {$IFDEF UNICODE}
//    procedure notificationForMsgW(msgtype:byte; flags:byte; urgent:boolean;
//                    msg:string{; offline:boolean = false});
  {$ENDIF UNICODE}
    procedure notificationForMsg(msgtype: byte; flags:byte; urgent:boolean;
                    const msg: RawByteString{; offline:boolean = false});
    function  getLocalIPstr: string;

{$IFDEF usesDC}
    function  directTo(c: TICQContact): TICQDirect;
{$ENDIF usesDC}
   public // ICQ Only
    property SSLserver: String read fSSLServer;
    property ProxyServer: String read fOscarProxyServer;
    property getProtoType: TICQSessionSubType read protoType;
    property webaware: boolean  read P_webaware write setWebaware;
    property authNeeded: boolean  read P_authNeeded write setAuthNeeded;
    property showInfo: Byte read P_showInfo write P_showInfo;
    property pwd: String read getPwd write setPwd;
    property visibility: Tvisibility read fVisibility write setVisibility;
 {$IFDEF UseNotSSI}
    procedure updateVisibility;
 {$ENDIF UseNotSSI}
   private
    function  getLocalIP: integer;
    function  serverPort: word;
    function  serverStart: word;
    procedure sendAddTempContact(const buinlist: RawByteString); overload; // 030F
    function  sendFLAP(ch: word; const data: RawByteString): boolean;
    function  sendSNAC(fam,sub: word; const data: RawByteString): boolean; OverLoad;
    function  sendSNAC(fam,sub, flags: word; const data: RawByteString): boolean; OverLoad;
   public // ICQ Only
    procedure SSIdeleteContact(cnt: TRnQContact);
    procedure SSIAddContact(c: TICQContact);
    procedure SSI_DeleteItem(gID, iID, Tp: word; const iName : AnsiString = ''; const pExtData : RawByteString = '');
    procedure SSI_UpdateContact(c: TICQContact);
    procedure SSI_UpdateGroup(c: TICQContact);
    procedure SSIdeleteGroup(gID: integer);
    function  SSI_deleteAvatar: Boolean;
    procedure SSIUpdateGroup(const args: array of integer);

    procedure addContact(cl: TRnQCList; SendIt: Boolean = True); overload;
 {$IFDEF UseNotSSI}
    procedure setVisibleList(cl: TRnQCList);
    procedure setInvisibleList(cl: TRnQCList);
 {$ENDIF UseNotSSI}
    procedure clearTemporaryVisible;
    procedure RequestContactList(isImp: Boolean = True);

    function  useMsgType2for(c: TICQContact):boolean;
    procedure sendWPsearch(wp: TwpSearch; idx: Integer);
    procedure sendWPsearch2(wp: TwpSearch; idx: Integer; IsWP : Boolean = True);
    procedure sendAuthReq(const uin: TUID; const msg:string);
    procedure sendAuth(const uin: TUID);
    procedure sendAuthDenied(const uin: TUID; const msg:string='');
    function  getDCModeStr  : AnsiString;
    function  getDCfakeIP   : AnsiString;
    function  getDCfakePort : Integer;
    function  getUINStatus( const uin : TUID ) : Integer;
    function  CheckInvisibility2( const uin : TUID ) : Integer;
    function  CheckInvisibility3( const uin : TUID ) : Integer;
//    procedure  CheckInvisibility( uin : dword );
    procedure SendTYPING(cnt : TRnQContact; notif_type : Word);
    procedure RemoveMeFromHisCL(const uin : TUID);

    procedure sendCreateUIN(const acceptKey : RawByteString);
    procedure sendDeleteUIN;
    procedure sendsaveMyInfoNew(c: TICQContact);
    procedure sendPermsNew;//(c: Tcontact);
    procedure sendSticker(const uin: TUID; const sticker: String);
    procedure sendInfoStatus(const s: String);
    procedure getUINStatusNEW(const UID: TUID);
    procedure sendPrivacy(em: Word; ShareWeb: Boolean; authReq: Boolean);
    procedure sendReqOfflineMsgs;
    procedure sendDeleteOfflineMsgs;
    procedure sendContacts(cnt: TRnQContact; flags: dword; cl: TRnQCList);
    procedure sendQueryInfo(uin: Integer);
    procedure sendSimpleQueryInfo(const uin: TUID);
    procedure sendAdvQueryInfo(const uin: TUID; const token: RawByteString);
    procedure sendFullQueryInfo(const uin: TUID);
    procedure sendNewQueryInfo(const uin: TUID);
    procedure sendAddedYou(const uin: TUID);
    procedure sendStatusCode(sendVis: Boolean = True);
    procedure sendXStatusCodeOnly();
    procedure sendCapabilities;
    procedure resetStatusCode;
    procedure SSIAuth_REPLY(const uin: TUID; isAccept: Boolean; const msg: String = '');

    function  sendAutoMsgReq(const uin: TUID): integer;
    procedure sendFileAbort(cnt: TICQContact; msgID: TmsgID);
    procedure sendFileAck(msgID: TmsgID);

    function  RequestIcon(c: TICQContact): Boolean;
    function  uploadAvatar(const fn: String): Boolean;
    procedure RequestXStatus(const uin: TUID);
{$IFDEF usesDC}
//    function  sendFileReq(uin:TUID; msg,fn:string; size:integer):integer; // returns handle
    function  sendFileReq(const uin:TUID; const msg:string; fa : TFileAbout; useProxy : Boolean):integer;
    function  sendFileReq2(drct : TICQDirect):integer;
    function  sendFileReqPro(drct : TICQDirect):integer;
    procedure sendFileOk(Drct : TICQDirect; SendMsg : Boolean = False;
                         isListen : Boolean = false; useProxy : Boolean = false);
//    function  sendFileTest(msgID:TmsgID; c:Tcontact; fn:string; size:integer) : Integer;
    procedure ProcessReceiveFile(dirct : TICQDirect);
{$ENDIF usesDC}
    procedure add2visible(cl:TRnQCList; OnlyLocal : Boolean = false); overload;
    procedure add2invisible(cl:TRnQCList; OnlyLocal : Boolean = false); overload;

  protected
    // event managing
    procedure notifyListeners(ev: TicqEvent);
    // send packets
    procedure sendMSGsnac(const uin: TUID; const sn: RawByteString);
    procedure sendCryptMSGsnac(const uin: TUID; const sn: RawByteString);
    procedure sendSMS(dest, msg: string; ack: boolean);

//    procedure sendPermissions;

{$IFDEF UseNotSSI}
    procedure sendAddContact(cl: TRnQCList; OnlyLocal: Boolean = False); overload;
    procedure sendRemoveContact(cl: TRnQCList); overload;
{$ENDIF UseNotSSI}
    procedure sendRemoveVisible(cl: TRnQCList); overload;
    procedure sendRemoveInvisible(cl: TRnQCList); overload;
    procedure sendAddInvisible(cl: TRnQCList); overload;
    procedure sendAddVisible(cl: TRnQCList); overload;

    procedure sendACK(cont: TICQContact; status: integer; const msg: string; DownCnt: word = $FFFF);
    procedure sendVisibility;

    procedure parseTYPING_NOTIFICATION(const pkt : RawByteString);
   {$IFDEF RNQ_AVATARS}
    procedure parse0121(const pkt : RawByteString; flags : Word);
    procedure iconUploadAck(const pkt : RawByteString);
//    procedure RequestIcon(uin : Integer; hash : String);
    procedure parseIcon(const pkt: RawByteString);
    procedure initAvatarSess;
   {$ENDIF RNQ_AVATARS}
    procedure sendMyXStatus(cont : TICQContact; msgID : Int64);

    procedure SSIreqRoster;
//    function  SSI_Item2packet(item : TOSSIItem) : String;

//    procedure SSIUpdateGroup( grID : Integer);
    procedure SSI_UpdateGroups(const args:array of integer);
//    procedure SSIRenameGroup(gID:integer; gName:string);
//    procedure renameSSIGroup(gID:integer; gName:string);
   private
    function  add2visible(c:TICQContact):boolean; overload;
    function  add2ignore(c:TICQContact):boolean; //overload;
    function  remFromIgnore(c:TICQContact):boolean;
    function  add2invisible(c:TICQContact):boolean; overload;
    function  addTemporaryVisible(c:TICQContact):boolean; overload;
    function  addTemporaryVisible(cl:TRnQCList):boolean; overload;
    function  removeTemporaryVisible(c:TICQContact):boolean; overload;
    function  removeTemporaryVisible(cl:TRnQCList):boolean; overload;
    function  removeFromVisible(c:TICQContact):boolean; overload;
    procedure removeFromVisible(const cl:TRnQCList); overload;
    function  removeFromInvisible(c:TICQContact):boolean; overload;
    procedure removeFromInvisible(const cl:TRnQCList); overload;

    procedure SSIsendAddTempVisible(const buid : AnsiString);
    procedure SSIsendDelTempVisible(const buid : AnsiString);

    procedure SSI_AddVisItem(const UID : TUID; iType : Word);
    procedure SSI_DelVisItem(const UID : TUID; iType : Word);

    procedure SSI_UpdateItem(const iName, iExtData : RawByteString; gID, iID, Tp : word);
    Function  SSI_CreateItem(const iName, iExtData : RawByteString; gID, iID, Tp : word) : word;
    procedure SSI_CreateItems(Items : array of TOSSIItem);
    procedure SSI_DeleteItems(Items : array of TOSSIItem);

 {$IFDEF USE_REGUIN}
    procedure send170c;
    procedure parse170d(const snac: RawByteString);
 {$ENDIF USE_REGUIN}

    procedure sendChangePwd(const newPwd: RawByteString);
    procedure parseGCdata(const snac:RawByteString; offline:boolean=FALSE);
//    procedure parseStatus(snac:string; ofs:integer);
    procedure parseOnlineInfo(const snac: RawByteString; pOfs: Integer; cont : TICQContact; isSt : Boolean;
                   isMsg : Boolean = True; ShowCntSts : Boolean = True);
    procedure parseStatus(const snac: RawByteString; ofs:integer; cont : TICQContact;
                  isInvis : Boolean = false; Status_changed : Boolean = False);
 {$IFDEF USE_REGUIN}
    procedure parseNewUIN(const snac: RawByteString);
 {$ENDIF USE_REGUIN}
    procedure parseCookie(const flap : RawByteString);
    procedure parseREDIRECTxSERVICE(const pkt : RawByteString); // 0105
    procedure parseOncomingUser(const snac : RawByteString);
    procedure parseOffgoingUser(const snac : RawByteString);
    procedure parseMsgError(const snac : RawByteString; ref: integer);
    procedure parseServerAck(const snac : RawByteString; ref: integer);
    procedure parseSRV_LOCATION_ERROR(const snac: RawByteString; ref: integer);
    procedure parseSRV_LOGIN_REPLY(const snac: RawByteString);
    procedure parseAuthKey(const snac: RawByteString);
    procedure parse1503(const snac: RawByteString; ref:integer; flags : word);
    procedure parse040A(const snac: RawByteString);
    procedure parse040B(const snac: RawByteString);
    procedure parse010F(const snac: RawByteString);
    procedure parse0206(snac : RawByteString);
    procedure parse020C(const snac : RawByteString; ref : Integer);
    procedure parseIncomingMsg(snac : RawByteString);
    procedure goneOffline; // called going offline
{$IFDEF usesDC}
    procedure dc_connected(Sender: TObject; Error: Word);
{$ENDIF usesDC}
    procedure connected(Sender: TObject; Error: Word);
    procedure OnProxyTalk(Sender : TObject; isReceive : Boolean; Data : RawByteString);
    procedure OnProxyError(Sender : TObject; Error : Integer; Msg : String);
    procedure onDataAvailable(Sender: TObject; Error: Word);
    procedure received(Sender: TObject; Error: Word; pkt : RawByteString);
    procedure disconnected(Sender: TObject; Error: Word);
    procedure parseContactsString(s: RawByteString);
    procedure parseAuthString(s: RawByteString);
    procedure parsePagerString(s: RawByteString);

    procedure parseAuthReq(const pkt : RawByteString);

    procedure newLogin;
    procedure SSIreqLimits;
    procedure SSIchkRoster;
    procedure SSIsendReady;
    procedure SSIstart();
    procedure SSIstop(needSend : Boolean = false);
//    procedure SSIUpdate(ID : String);
    procedure SplitCL2SSI_DelItems(proc:TsplitSSIProc; cl:TRnQCList; Tp : word);
//    procedure SSInewGroup(gID:integer; gName:string; iID : integer = 0);
//    procedure SSIAddContact(vUIN, vName: String;
//              vMail: String=''; vSMS: String=''; cmnt: String='');
//    procedure SSInewContact(gID,cID:integer; nUIN,cName, vMail, vSMS, cmnt:string);
    function SSI_sendAddContact(cnt : TICQContact; needAuth : Boolean = false; pItem : TOSSIItem = NIL) : Word;
//    procedure SSInewContactauth(gID,cID:integer; nUIN,cName:string);
//    procedure SSIdeleteContact(gID,cID:integer; nUIN,cName:string);
    procedure parse131b(const pkt : RawByteString);
    procedure parse131C(const pkt : RawByteString);
    procedure parse1308090A(const snac:RawByteString; ref:integer; iType : Word);
//    procedure parse1308(snac:string; ref:integer);
//    procedure parse1309(snac:string; ref:integer);
//    procedure parse130A(snac:string; ref:integer);
    procedure parse130E(const snac: RawByteString; ref:integer);  //SSIackParse(Pkt: String); // #$13#$0E
    procedure ProcessSSIacks;
    procedure parse1311(const snac: RawByteString; ref: Integer); // SSI_Begin transaction
    procedure parse1312(const snac: RawByteString; ref: Integer); // SSI_END transaction
    procedure sendLogin;
    procedure sendImICQ;
    procedure sendCookie;
    procedure SendReqBuddy(Second: Boolean = False);

    procedure sendIMparameter(chn: AnsiChar);
    procedure sendClientReady;
    procedure sendAckTo107;
    function  addRef(k: TrefKind; const uin: TUID):integer;
    function  dontBotherStatus:boolean;
    function  myUINle: RawByteString;
    function  getFullStatusCode:dword;

   public // All
    function  sendMsg(cnt: TRnQContact; var flags: dword; const msg: string; var requiredACK:boolean):integer; OverRide; {$IFDEF DELPHI9_UP} final; {$ENDIF DELPHI9_UP} // returns handle
    procedure sendSMS2(dest, msg: String; ack: Boolean);
    function  sendBuzz(cnt: TRnQContact): Boolean;
    procedure SetListener(l: TProtoNotify); OverRide; {$IFDEF DELPHI9_UP} final; {$ENDIF DELPHI9_UP}
    procedure AuthGrant(Cnt: TRnQContact); OverRide; {$IFDEF DELPHI9_UP} final; {$ENDIF DELPHI9_UP}
    procedure AuthRequest(cnt: TRnQContact; const reason: String); OverRide; {$IFDEF DELPHI9_UP} final; {$ENDIF DELPHI9_UP}

    function  isMyAcc(c: TRnQContact) : Boolean; OverRide; {$IFDEF DELPHI9_UP} final; {$ENDIF DELPHI9_UP}
    function  getMyInfo: TRnQContact; OverRide; {$IFDEF DELPHI9_UP} final; {$ENDIF DELPHI9_UP}
//    procedure setMyInfo(cnt : TRnQContact);
    function  getStatuses: TStatusArray; OverRide; {$IFDEF DELPHI9_UP} final; {$ENDIF DELPHI9_UP}
    function  getVisibilitis : TStatusArray; OverRide; {$IFDEF DELPHI9_UP} final; {$ENDIF DELPHI9_UP}
    function  getStatusMenu  : TStatusMenu; OverRide; {$IFDEF DELPHI9_UP} final; {$ENDIF DELPHI9_UP}
    function  getVisMenu     : TStatusMenu; OverRide; {$IFDEF DELPHI9_UP} final; {$ENDIF DELPHI9_UP}
    function  getStatusDisable : TOnStatusDisable; OverRide; {$IFDEF DELPHI9_UP} final; {$ENDIF DELPHI9_UP}
    function  getPrefPage : TPrefFrameClass; OverRide; {$IFDEF DELPHI9_UP} final; {$ENDIF DELPHI9_UP}
   public
    function  GenSSID : Integer;
    procedure applyBalloon;
   public
//    property  statuses : TStatusArray read getStatuses;
    property  MyInfo :TRnQContact read getMyInfo;
  end; // TicqSession

 TICQProtoClass = class of TICQSession;
 {$IFNDEF ICQ_OLD_STATUS}
const
    UseOldXSt = False;
 {$ENDIF ICQ_OLD_STATUS}
 {$IFNDEF UseNotSSI}
const
    LoginMD5  = True;
 {$ENDIF UseNotSSI}

var
//  My_proto_ver : Byte = 10;
//  ICQ_TCP_VERSION := My_proto_ver;

//  sendInterests,
  supportInvisCheck,
  addTempVisMsg,

  showInvisSts,

  AvatarsNotDnlddInform,
  avtSessInit  : Boolean;
  ToUploadAvatarFN : String;
  ToUploadAvatarHash : RawByteString;
  ExtClientCaps : RawByteString;
  AddExtCliCaps : Boolean;
  sendBalloonOn     :integer;
  sendBalloonOnDate :Tdatetime;
 {$IFDEF RNQ_FULL}
//  SendedFlaps : LongWord;
//  ICQMaxFlaps : LongWord = 70;
 {$ENDIF}
//  onStatusDisable :array [SC_ONLINE..pred(SC_OFFLINE)] of record
//  onStatusDisable :array [SC_ONLINE..pred(SC_)] of record
//  onStatusDisable :array [TICQstatus] of TOnStatusDisable;


var
  ICQstatuses, icqVis : TStatusArray;
  statMenu, icqVisMenu : TStatusMenu;


implementation

uses
   Controls, dateUtils, Math,
 {$IFDEF UNICODE}
   AnsiStrings, AnsiClasses,
 {$ENDIF UNICODE}
   RnQZip, OverbyteIcsZLibHigh,
   OverbyteIcsMD5, OverbyteIcsWSocket,
//   ElAES,
   aes_type, aes_ecb,
   RnQDialogs, RnQLangs, RDUtils, RnQBinUtils,
   Base64, //ZLibEx,
   RDFileUtil, RnQCrypt,
//   rtf2html,
 {$IFDEF RNQ_AVATARS}
   RnQ_Avatars,
 {$ENDIF}
   globalLib, UtilLib,
   RQ_ICQ, ICQClients, ICQ.Stickers,
   themesLib,

   RnQStrings, outboxLib, icq_fr,
   Protocol_ICQ;//, outboxLib;

const
  DT2100miliseconds=1/(SecsPerDay*10);
var
  lastSendedFlap : TDateTime;

procedure splitCL(proc:TsplitProc; cl:TRnQCList);
var
  i,cnt:integer;
  s: RawByteString;
begin
if TList(cl).count=0 then
  begin
  proc('');
  exit;
  end;
i:=0;
while (i< TList(cl).count) do
  begin
  if i > 0 then
    sleep(1000);
  cnt:=600;
  s:='';
  while (i< TList(cl).count) and (cnt>0) do
    begin
    s:=s + TICQContact(cl.getAt(i)).buin;
    inc(i);
    dec(cnt);
    end;
  proc(s);
  end;
end;

procedure splitSSICL(proc: TsplitProc; cl: TRnQCList; OnlyLocal: Boolean);
var
  i, cnt: integer;
  s: RawByteString;
begin
  if TList(cl).count=0 then
    begin
    proc('');
    exit;
    end;
  i := 0;
  while (i< TList(cl).count) do
   begin
    if i > 0 then
      sleep(1000);
    cnt := 100;
    s := '';
    while (i< TList(cl).count) and (cnt>0) do
      begin
       with TICQContact(cl.getAt(i)) do
       if CntIsLocal or (not OnlyLocal and not Authorized) then
        begin
         s := s + buin;
         dec(cnt);
        end;
       inc(i);
      end;
    proc(s);
   end;
end;

procedure splitSSICL60(proc: TsplitProc; cl: TRnQCList; OnlyLocal: Boolean);
var
  i, cnt: integer;
  s: RawByteString;
begin
  if TList(cl).count=0 then
    begin
    proc('');
    exit;
    end;
  i:=0;
  while (i< TList(cl).count) do
   begin
    if i > 0 then
      sleep(1000);
    cnt:=10;
    s:='';
    while (i< TList(cl).count) and (cnt>0) do
      begin
       with TICQContact(cl.getAt(i)) do
       if CntIsLocal or (not OnlyLocal and not Authorized) then
        begin
         s:=s + buin;
         dec(cnt);
        end;
       inc(i);
      end;
    proc(s);
   end;
end;

function SSI_Item2packet(item: TOSSIItem): RawByteString;
begin
  if Assigned(item) and (item is TOSSIItem) then
   with item do
    Result := Length_BE(ItemName) + word_BEasStr(GroupID) +
              word_BEasStr(ItemID) + word_BEasStr(ItemType) +
              Length_BE(ExtData)
  else
   Result := '';
end;

procedure SplitCL2SSI_Items(proc: TsplitSSIProc; cl: TRnQCList;
                     iExtData: RawByteString; gID, iID, Tp: word);
var
  i, len1, LenAll:integer;
  k : Integer;
  arr : array of TOSSIItem;
//  s:string;
begin
  if TList(cl).count=0 then
    begin
    proc([]);
    exit;
    end;
  i:=0;
  while (i< TList(cl).count) do
   begin
    if i > 0 then
      sleep(1000);
    LenAll := 0;
    SetLength(arr, 0);
//    s:='';
    while (i< TList(cl).count) and (LenAll<6000) do
      begin
       with cl.getAt(i) do
        begin
//         s:=s + buin;
         k := length(arr);
         SetLength(arr, k + 1);
         arr[k] := TOSSIItem.Create;
         with arr[k] do
          begin
            ItemType := Tp;
            ItemName := UID;
            ItemID   := 0;
            ExtData  := '';
            Len1 := Length(SSI_Item2packet(arr[k]));
          end;
         Inc(LenAll, len1); 
        end;
       inc(i);
//       dec(cnt);
      end;
    proc(arr);
   end;
end;

function code2status(code:dword):TICQstatus;
begin
code:=code and ($FFFF-8-flag_invisible);
case code of
  $10: begin result:=SC_OCCUPIED; exit end;
  4: begin result:=SC_NA; exit end;
  2: begin result:=SC_DND; exit end;
  end;
for result:=low(result) to high(result) do
  if status2code[result] = code then
    exit;
result:= SC_ONLINE;
end; // code2status

function sameMethods(a,b:TicqNotify):boolean;
begin result:= double((@a)^) = double((@b)^) end;

function encrypted(const s: RawByteString): RawByteString;
const
  cryptData:array [1..16] of byte=($F3,$26,$81,$C4,$39,$86,$DB,$92,$71,$A3,$B9,$E6,$53,$7A,$95,$7C);
var
  i:integer;
begin
i:=length(s);
setLength(result,i);
while i > 0 do
  begin
  byte(result[i]):=byte(s[i]) xor cryptData[i];
  dec(i);
  end;
end; // encrypted

{
function str2url(const s:string):string;
var
  i:integer;
  ss:string;
begin
result:='';
for i:=1 to length(s) do
  begin
  case s[i] of
    ' ':ss:='%20';
    'A'..'Z','a'..'z','0'..'9':ss:=s[i];
    else ss:='%'+intToHex(ord(s[i]),2);
    end;
  result:=result+ss;
  end;
end; // str2url}

function str2url(const s: AnsiString): AnsiString;
var
  i:integer;
  ss: AnsiString;
begin
result:='';
for i:=1 to length(s) do
  begin
  case s[i] of
    ' ':ss:='%20';
    'A'..'Z','a'..'z','0'..'9':ss:=s[i];
    else ss:='%'+IntToHexA(Byte(s[i]),2);
    end;
  result:=result+ss;
  end;
end; // str2url

function str2html(const s: AnsiString): AnsiString;
var
  i:integer;
  ss: AnsiString;
begin
result:='';
for i:=1 to length(s) do
  begin
  case s[i] of
{    'à':ss:='&egrave;';
    'è':ss:='&egrave;';
    'é':ss:='&eacute;';
    'ì':ss:='&igrave;';
    'ò':ss:='&ograve;';
    'ù':ss:='&ugrave;';
    'É':ss:='&Eacute;';}
    '<': ss := '&lt;';
    '>': ss := '&gt;';
    '"': ss := '&quot;';
    '&': ss := '&amp;';
    else ss:=s[i];
    end;
  result:=result+ss;
  end;
end; // str2html

{
function str2html2(const s:string):string;
begin
  result:=template(s, [
    '<', '&lt;',
    '>', '&gt;'
//    CRLF, '<br/>',
//    #13, '<br/>',
//    #10, '<br/>',
//    '&', '&amp;'
  ]);
end; // str2html
}
function str2html2(const s: AnsiString): AnsiString;
begin
  result := template(s, [
    AnsiString('<'), AnsiString('&lt;'),
    AnsiString('>'), AnsiString('&gt;')
//    CRLF, '<br/>',
//    #13, '<br/>',
//    #10, '<br/>',
//    '&', '&amp;'
  ]);
end; // str2html

function xml_sms(me:TRnQcontact; const dest,msg: AnsiString; ack:boolean): AnsiString;
const
  yesno:array [boolean] of AnsiString=('No','Yes');
begin
result:=
 '<icq_sms_message>'+
 '<destination>'+dest+'</destination>'+
 '<text>'+str2html(msg)+'</text>'+
 '<codepage>1251</codepage>'+
 '<senders_UIN>'+ me.uid +'</senders_UIN>'+
 '<senders_name>'+AnsiString(me.displayed)+'</senders_name>'+
 '<delivery_receipt>'+yesno[ack]+'</delivery_receipt>'+
 '<time>'+ AnsiString( formatDatetime('ddd, dd mmm yyyy hh:nn:ss GMT', now-gmtoffset) )+'</time>'+
 '</icq_sms_message>';
end; // xml_sms

/////////////////////////////////////////////////////////
{$IFDEF usesDC}

constructor TICQDirect.create;
begin
{  sock:=TRnQSocket.create(NIL);
  sock.tag:=integer(@self);
  sock.OnDataAvailable:=received;
  sock.OnSessionClosed:=disconnected;
  //sock.OnSocksError := OnProxyError;
  imserver:=TRUE;
  kind:=DK_none;
  stage := 0;
  mode := dm_bin_direct;
  Directed := False;
  needResume := False;
  AOLProxy.ip := 0;
  AOLProxy.port := 0;
  UseLocProxy := True;
  myspeed:=100;}
  Inherited;
  sock.OnDataAvailable:=received;
  sock.OnSessionClosed:=disconnected;
end; // create

procedure TICQDirect.listen;
var
  i : Integer;
  s : Boolean;
begin
  sock.OnSessionAvailable:=connected;
  imserver := TRUE;
  Directed := False;
//  mode := dm_init;
  sock.addr:='0.0.0.0';
  sock.Port:= '0';
  s := false;
  for I := 0 to portsListen.PortsCount do
   try
      sock.Port := IntToStr(portsListen.getRandomPort);
      sock.listen;
      s := True;
      Break;
    except
      S := false;
   end;
  if not s then
   begin
//     sock.getFreePort;
     sock.Port:= '0';
     sock.listen;
   end;
  logMsg(0, getTranslation('Listening port: %s', [sock.Port]));
//  sock.port:='20000';
  if (mode = dm_bin_direct) and (not imSender)and (kind = DK_file) then
    TicqSession(directs.proto).sendFileOk(Self, True);

end; // listen

function TICQdirect.sendProxyCMD(cmd, flags :word; const data: RawByteString):boolean;
var
  s: RawByteString;
begin
  result:=FALSE;
  if sock.State <> wsConnected then exit;
  s:=word_BEasStr((Length(Data) + 10)) // Len
      +#$04#$4A // PackVer
      +word_BEasStr(cmd) // CmdType
      +z          // Unknown
      +word_BEasStr(flags) // Flags
      +data;
  sendPkt(s);
  s:='';
  result:=TRUE;
end; // sendFLAP

procedure TICQDirect.connect;
begin
  sock.OnSessionConnected:=connected;
  imserver:=FALSE;
  mode := dm_bin_direct;
//sock.addr:=dword_LE2ip(contact.connection.ip);
  Directed := False;
  if (sock.State = wsConnected)or
     (sock.State = wsListening)
  then   
   begin
    sock.Close;
    sock.WaitForClose;  // prevent to change properties while the socket is open
   end;
  if UseLocProxy then
    sock.proxySettings(directs.proto.aProxy)
   else
    sock.DisableProxy;
  if (TICQcontact(contact).connection.internal_ip > 0)
    and (TICQcontact(contact).connection.ft_port > 0) then
   begin
//    sock.addr := dword_LE2ip(contact.connection.internal_ip);
    sock.addr := dword_LE2ipU(TICQcontact(contact).connection.internal_ip);
    sock.port := intToStr(TICQcontact(contact).connection.ft_port);
    sock.connect;
   end; 
end; // connect

procedure TICQDirect.connect2proxy;
begin
  sock.OnSessionConnected:=connected;
  imserver:=FALSE;
  mode := dm_bin_proxy;
//sock.addr:=dword_LE2ip(contact.connection.ip);
  Directed := False;
  if (sock.State = wsConnected)or
     (sock.State = wsListening)
  then
   begin
    sock.Close;
    sock.WaitForClose;  // prevent to change properties while the socket is open
   end;

//  if UseLocProxy then
    sock.proxySettings(directs.proto.aProxy)
//   else
//    DisableProxy(sock)
   ;

  if stage = 1 then
   begin
    if imSender then
      sock.addr := TicqSession(directs.proto).ProxyServer
     else
      sock.addr := dword_LE2ipU(AOLProxy.ip);
    sock.port := TicqSession(directs.proto).serviceServerPort;
   end
  else
   if stage = 2 then
    begin
      if not imSender then
        sock.addr := TicqSession(directs.proto).ProxyServer
       else
        sock.addr := dword_LE2ipU(AOLProxy.ip)
       ;
      sock.port := TicqSession(directs.proto).serviceServerPort;
    end
  else
  if stage = 3 then
   begin
    if imSender then
      sock.addr := TicqSession(directs.proto).ProxyServer
     else
      sock.addr := dword_LE2ipU(AOLProxy.ip)
     ;
    sock.port := TicqSession(directs.proto).serviceServerPort;
   end;
 try
  // Need make asynchronized call
  sock.Connect
 except
  on E:Exception do
   begin
{     eventMsgA := E.Message;
     eventError:=EC_cantconnect;
     eventInt:=WSocket_WSAGetLastError;
     notifyListeners(IE_error);}
//     goneOffline;
   end
  else
   begin
{    eventMsgA := '';
    eventError:=EC_cantconnect;
    eventInt:=WSocket_WSAGetLastError;
    eventMsgA := WSocketErrorDesc(eventInt);
    notifyListeners(IE_error);}
//    goneOffline;
   end;
 end;
end;

procedure TICQDirect.connected2cli;
begin
   Directed := True;
   begin
     if (not imSender)and (kind = DK_file) then
       TicqSession(directs.proto).sendFileOk(Self, True);
     if imSender and (kind = DK_file) then
       sendFilePrompt;
   end;
end;

procedure TICQDirect.Failed;
begin
  sock.close
end;

procedure TICQDirect.close;
begin sock.close end;

procedure TICQDirect.connected(Sender: TObject; Error: Word);
var
  icq:TicqSession;
  a : Word;
begin
  icq:= TicqSession(directs.proto);
  icq.eventDirect:=self;
if error<>0 then
  begin
   icq.eventMsgA := '';
   a := WSocket_WSAGetLastError;
  if a <> 0 then
   begin
    error:= a;
    icq.eventMsgA := WSocketErrorDesc(error);
   end; 
  icq.eventInt:=error;
  icq.eventError:=EC_cantconnect_dc;
  icq.notifyListeners(IE_error);
  exit;
  end;
  if imserver then
    sock.dup(sock.accept);
 P_host:=sock.GetPeerAddr;
 P_port:=sock.GetPeerPort;
 icq.notifyListeners(IE_dcConnected);
 if mode = dm_bin_proxy then
  if (((stage=1)or(stage=3))and(not imSender))or
     ((stage=2)and imSender) then
    begin
     sendProxyCMD(4, 0, myinfo.buin + word_BEasStr(AOLProxy.port) + qword_LEasStr(eventID) +
                        TLV($01, CAPS_sm2big(CAPS_sm_FILE_TRANSFER)));
    end
   else
    begin
     sendProxyCMD(2, 0, myinfo.buin + qword_LEasStr(eventID) +
                        TLV($01, CAPS_sm2big(CAPS_sm_FILE_TRANSFER)));
    end
  else
    Connected2Cli;
end; // connected

procedure TICQDirect.disconnected(Sender: TObject; Error: Word);
begin
  with TicqSession(directs.proto) do
  begin
    eventDirect:=self;
    notifyListeners(IE_dcDisconnected);
  end;
  if Assigned(OnDisconnect) then
    OnDisconnect(self, 0);
end; // disconnected

procedure TICQDirect.sended(Sender: TObject; Error: Word);
var
  b : Boolean;
begin
  SetLength(buf, 0);
  b := false;
  if Assigned(OnDataNext) then
    OnDataNext(self, buf, b);
  if Length(buf)>0 then
    sendPkt(buf);
  if b then
   sock.Close;
end;

procedure TICQDirect.received(Sender: TObject; Error: Word);
const
  Z=#0#0#0#0;
var
  s, s1: RawByteString;
  l, ofs:integer;
  msg_type : word;
begin
// queue in buf
//buf:=buf+sock.receiveStr;
 {$IFDEF UNICODE}
  s := sock.ReceiveStrA;
 {$ELSE nonUNICODE}
  s := sock.ReceiveStr;
 {$ENDIF UNICODE}
// extract the packet from buf
{if length(buf) < 2 then exit;
l:=word_LEat(@buf[1]);
if length(buf) < l+2 then exit;
s:=copy(buf,1,l+2);
delete(buf,1,l+2);}
// log
 if not (Directed and not imSender and (mode = dm_bin_direct)) then
  with TicqSession(directs.proto) do
  begin
   eventData := s;
   eventDirect:=self;
   notifyListeners(IE_dcGot);
  end;
  if mode= dm_bin_proxy then
   begin
     l := word_BEat(s, 1);
     msg_type := word_BEat(s, 5);
     case msg_type of
      1: begin
           Failed;
           Exit;
         end;
      3: begin
           if l > 15 then
           begin
             AOLProxy.port := word_BEat(s, 13);
             ofs := 15;
//             AOLProxy.ip   := readBEDWORD(s, ofs);
             AOLProxy.ip   := readDWORD(s, ofs);
             if not imSender then
               TicqSession(directs.proto).sendFileOk(self, True, false, True)
              else
               TicqSession(directs.proto).sendFileReqPro(self);
           end
           else
            Failed;
           Exit;
         end;
      5: begin
          mode := dm_bin_direct;
          connected2cli;
         end;   
     end;
     exit;
   end;
//delete(s,1,2);
// reply
  if imSender then
    begin
     if kind = DK_file then
         if (Length(s) >4)and(AnsiStartsText(AnsiString('OFT2'), s)) then
           begin
             msg_type := word_BEat(s, 7);
             case msg_type of
{              $0101 : // Prompt. This is sent by the file sender to indicate that the client is ready to begin sending data.
                      begin
                        s1 := Copy(s, 1, 6) + #02#02 + Copy(s, 9, MAXSHORT);
//                        Self.fileTotal := 0;
                        sendPkt(s1);
                        mode := dm_bin_direct;
      //                  sendACK_File;
                      end;
              $0106 : // Sender Resume. The sender has agreed to begin the transfer at the point the receiver specified.
                      begin
                        s1 := Copy(s, 1, 6) + #02#07 + Copy(s, 9, MAXSHORT);
                        sendPkt(s1);
                      end;
}
              $0202, $0207:
                  begin
                   if msg_type=$0202 then
                      fileSizeReceived := 0
                    else
                     ;  
                   with TicqSession(directs.proto) do
                    begin
                     eventcontact := TICQcontact(contact);
                     eventMsgID   := eventID;
                     eventDirect  := self;
                     notifyListeners(IE_fileack);
                    end;
                  end;
              $0204:
                  begin
//                   mode :=
                   close;
                   with TicqSession(directs.proto) do
                    begin
  //                   directs.icq.eventcontact := contact;
                     eventMsgID  := eventID;
                     notifyListeners(IE_fileDone);
                    end;
                  end;
              $0205:
                  begin
                    s1 := Copy(s, 1, 6) + #01#06 + Copy(s, 9, MAXSHORT);
                    parseFileDC0205(s);
                    sendPkt(s1);
//                    sendACK_File;
                  end
             end;
      //       разбираем инфу!
           end;
    end
  else // not imSender
   if (kind = DK_file) then
    begin
     if //(mode <> dm_bin_receive)and
       (Length(s) >4)and(AnsiStartsText(AnsiString('OFT2'), s)) then
       begin
         msg_type := word_BEat(s, 7);
         case msg_type of
          $0101 : // Prompt. This is sent by the file sender to indicate that the client is ready to begin sending data.
                  begin
                    parseFileDC0101(s);
                    sendACK_File;
//                    s1 := Copy(s, 1, 6) + #02#02 + Copy(s, 9, MAXSHORT);
//                    sendPkt(s1);
                    if not needResume then
                      mode := dm_bin_direct;
  //                  sendACK_File;
                  end;
          $0106 : // Sender Resume. The sender has agreed to begin the transfer at the point the receiver specified.
                  begin
                    s1 := Copy(s, 1, 6) + #02#07 + Copy(s, 9, MAXSHORT);
                    sendPkt(s1);

                    mode := dm_bin_direct;
                  end;
         end;
//         Filename := 'data5.txt';
  //       разбираем инфу!
       end
      else
       begin
        if mode = dm_bin_direct then
         begin
          buf := s;
          if Assigned(OnDataAvailable) then
           OnDataAvailable(self, 0);
         end;
       end;
    end;
//  case s[1] of
//    #$FF:sendACK1;
//    end;
s:='';
end; // received

procedure TICQdirect.DoneTransfer;
begin
  sendDone_File;
  if (fileCntTotal=1) or
     ((fileCntTotal >0) and (fileCntReceived >= fileCntTotal)) then
    close;
end;

function TICQDirect.myinfo:TICQcontact;
begin result:= TICQcontact(directs.proto.getMyInfo) end;

function TICQDirect.parseFileDC0101(s : RawByteString) : Boolean;
var
  evID : Int64;
  encrypted : Word;
  compressed : Word;
  errStr : String;
  ofs : Integer;
  ptype : Word;
  enc : byte;
begin
  ofs := 7;
  pType := readWORD(s, ofs);
//  ofs := 9;
  evID := //qword_LEat(@s[9]);
          readQWORD(s, ofs);
  Result := True;        
  encrypted := readBEWORD(s, ofs); //$10);
  if encrypted <> 0 then
   begin
    errStr := 'Unknown encryption';
    result := false;
    Exit;
   end;
  compressed := readBEWORD(s, ofs); //$12);
  if compressed <> 0 then
   begin
    errStr := 'Unknown compression';
    result := false;
    Exit;
   end;
  fileCntTotal := readBEWORD(s, ofs); //$14);
  if fileCntTotal = 0 then
   begin
    errStr := 'No files';
    result := false;
    Exit;
   end;
  if readBEWORD(s, ofs) = 0 then
   begin
    errStr := 'No files left';
    result := false;
    Exit;
   end;
  readBEWORD(s, ofs); // Total Parts (TotPrts)
  readBEWORD(s, ofs); // Parts Left (PrtsLeft)
  fileSizeTotal := readBEDWORD(s, ofs); // Total Size (TotSz)
  if fileSizeTotal = 0 then
   begin
    errStr := 'File size is zero';
    result := false;
    Exit;
   end;
  readBEDWORD(s, ofs); // The size (Size)
  readINT(s, ofs); // Modification Time (ModTime)
  transferChkSum := readBEDWORD(s, ofs); // Checksum (Checksum)
  readBEDWORD(s, ofs); // The Received Resource Fork Checksum (RfrcvCsum)
  readBEDWORD(s, ofs); // The Resource Fork Size (RfSize)
  readBEDWORD(s, ofs); // The Creation Time (CreTime)
  readBEDWORD(s, ofs); // The Resource Fork Checksum (RfCsum)
  readBEDWORD(s, ofs); // The Bytes Received (nRecvd)
  readBEDWORD(s, ofs); // The Received Checksum (RecvCsum)
  inc(ofs, 32); // The Identification String (IDString)
  readBYTE(s, ofs); // The Flags (Flags)
  readBYTE(s, ofs); // The List Name Offset (NameOff) defaults to 0x1C (Decimal: 28)
  readBYTE(s, ofs); // The List Size Offset (SizeOff) default is 0x11(Decimal: 17)
  inc(ofs, 69); // The “Dummy” block (Dummy)
  inc(ofs, 16); // The Macintosh File Information (MacFileInfo)
  enc := readWORD(s, ofs);
  readWORD(s, ofs); // The Encoding Subcode (Subcode) observed to be only 0x0000
  if enc <> 2 then
    begin

    end
   else // Unicode
    begin
    end;
 if not Result then
   logMsg(99, errStr);
//  пишем тута!
//  word_BEat(s, 7);
  ;
end;

function TICQDirect.parseFileDC0205(s : RawByteString) : Boolean;
var
  evID : Int64;
//  encrypted : Word;
//  compressed : Word;
  errStr : String;
  ofs : Integer;
  ptype : Word;
//  enc : byte;
begin
  ofs := 7;
  pType := readWORD(s, ofs);
//  ofs := 9;
  evID := //qword_LEat(@s[9]);
          readQWORD(s, ofs);
  Result := True;        
//  encrypted :=
  readBEWORD(s, ofs); //$10);
{  if encrypted <> 0 then
   begin
    errStr := 'Unknown encryption';
    result := false;
    Exit;
   end;}
//  compressed :=
  readBEWORD(s, ofs); //$12);
{  if copressed <> 0 then
   begin
    errStr := 'Unknown compression';
    result := false;
    Exit;
   end;}
//  fileCntTotal :=
  readBEWORD(s, ofs); //$14);
{  if fileCntTotal = 0 then
   begin
    errStr := 'No files';
    result := false;
    Exit;
   end;}
  if readBEWORD(s, ofs) = 0 then
   begin
    errStr := 'No files left';
    result := false;
    Exit;
   end;
  readBEWORD(s, ofs); // Total Parts (TotPrts)
  readBEWORD(s, ofs); // Parts Left (PrtsLeft)
//  fileSizeTotal :=
  readBEDWORD(s, ofs); // Total Size (TotSz)
{  if fileSizeTotal = 0 then
   begin
    errStr := 'File size is zero';
    result := false;
    Exit;
   end;}
  readBEDWORD(s, ofs); // The size (Size)
  readINT(s, ofs); // Modification Time (ModTime)
//  transferChkSum :=
  readBEDWORD(s, ofs); // Checksum (Checksum)
  readBEDWORD(s, ofs); // The Received Resource Fork Checksum (RfrcvCsum)
  readBEDWORD(s, ofs); // The Resource Fork Size (RfSize)
  readBEDWORD(s, ofs); // The Creation Time (CreTime)
  readBEDWORD(s, ofs); // The Resource Fork Checksum (RfCsum)
  self.fileSizeReceived := readBEDWORD(s, ofs); // The Bytes Received (nRecvd)
  Self.receivedChkSum   := readBEDWORD(s, ofs); // The Received Checksum (RecvCsum)
{  inc(ofs, 32); // The Identification String (IDString)
  readBYTE(s, ofs); // The Flags (Flags)
  readBYTE(s, ofs); // The List Name Offset (NameOff) defaults to 0x1C (Decimal: 28)
  readBYTE(s, ofs); // The List Size Offset (SizeOff) default is 0x11(Decimal: 17)
  inc(ofs, 69); // The “Dummy” block (Dummy)
  inc(ofs, 16); // The Macintosh File Information (MacFileInfo)
  enc := readWORD(s, ofs);
  readWORD(s, ofs); // The Encoding Subcode (Subcode) observed to be only 0x0000
  if enc <> 2 then
    begin

    end
   else // Unicode
    begin
    end;}
    
 if not Result then
   logMsg(99, errStr);
//  пишем тута!
//  word_BEat(s, 7);
  ;
end;

procedure TICQDirect.sendACK_File; // 0202 , 0205
var
  s : RawByteString;
  data : RawByteString;
  i : Integer;
begin
  data := #02;
  if needResume then
    data := data + #05
   else
    begin
      data := data + #02;
      fileSizeReceived := 0;
      receivedChkSum := $FFFF0000;
    end;
  data := data +
          qword_LEasStr(eventID) + // Cookie
          #00#00 +                 // Encrypt
          #00#00 +                 // Comp
          word_BEasStr(1)+         // TotFil
          word_BEasStr(1)+         // FilLft
          word_BEasStr(1*1)+       // TotPrts
          word_BEasStr(1*1)+       // PrtsLft
          dword_BEasStr(fileSizeTotal)+// TotSz
          dword_BEasStr(fileSizeTotal)+// Size
          dword_BEasStr(0)+        // ModTime
          dword_BEasStr(fileChkSum)+ // Checksum
          dword_BEasStr($FFFF0000)+  // RfrcvCsum
          dword_BEasStr(0)+          //RfSize
          dword_BEasStr(0)+          //CreTime
          dword_BEasStr($FFFF0000)+  //RfcSum
          dword_BEasStr(fileSizeReceived)+ //nRecvd
          dword_BEasStr(receivedChkSum)+   //RecvCsum
          'CoolFileXfer'+z+  //IDString
          z+z+z+z+  //IDString
          #$20+                       //Flags: $20 – Negotiation, $01 – Done
          #$1C+                       //NameOff
          #$11+                       //SizeOff
          z+z+z+z+z+                  //Dummy
          z+z+z+z+z+                  //Dummy
          z+z+z+z+z+                  //Dummy
          z+z+#00+                    //Dummy
          z+z+z+z+                    // MacFileInfo
          word_BEasStr(2)+            // Encoding: 0000-ASCII, 0002 - UTF-16BE or UCS-2BE, 0003 - ISO-8859-1
          word_BEasStr(0)+            // Subcode
          StrToUnicode(fileName + #00);
  i := Length(data);
  if i < $100-6 then
   begin
    SetLength(data, $100-6);
    FillMemory(@data[i+1], ($100-6-i), 0);
   end;
  s := 'OFT2' + word_BEasStr(length(data)+6)+data;
  sendPkt(s);
end;

procedure TICQDirect.sendDone_File; // 0204
var
  s : RawByteString;
  data : RawByteString;
  i : Integer;
begin
  data := #02#04 +
          qword_LEasStr(eventID) + // Cookie
          #00#00 +                 // Encrypt
          #00#00 +                 // Comp
          word_BEasStr(1)+         // TotFil
          word_BEasStr(1)+         // FilLft
          word_BEasStr(1*1)+       // TotPrts
          word_BEasStr(1*1)+       // PrtsLft
          dword_BEasStr(fileSizeTotal)+// TotSz
          dword_BEasStr(fileSizeTotal)+// Size
          dword_BEasStr(0)+        // ModTime
          dword_BEasStr(fileChkSum)+ // Checksum
          dword_BEasStr($FFFF0000)+  // RfrcvCsum
          dword_BEasStr(0)+          //RfSize
          dword_BEasStr(0)+          //CreTime
          dword_BEasStr($FFFF0000)+  //RfcSum
          dword_BEasStr(fileSizeTotal)+          //nRecvd
          dword_BEasStr(fileChkSum)+  //RecvCsum
          'CoolFileXfer'+z+  //IDString
          z+z+z+z+  //IDString
          #$20+                       //Flags: $20 – Negotiation, $01 – Done
          #$1C+                       //NameOff
          #$11+                       //SizeOff
          z+z+z+z+z+                  //Dummy
          z+z+z+z+z+                  //Dummy
          z+z+z+z+z+                  //Dummy
          z+z+#00+                    //Dummy
          z+z+z+z+                    // MacFileInfo
          word_BEasStr(2)+            // Encoding: 0000-ASCII, 0002 - UTF-16BE or UCS-2BE, 0003 - ISO-8859-1
          word_BEasStr(0)+            // Subcode
          StrToUnicode(fileName + #00);
  i := Length(data);
  if i < $100-6 then
   begin
    SetLength(data, $100-6);
    FillMemory(@data[i+1], ($100-6-i), 0);
   end;
  s := 'OFT2' + word_BEasStr(length(data)+6)+data;
  sendPkt(s);
end;

procedure TICQDirect.sendFilePrompt; // 0101
var
  s : RawByteString;
  data : RawByteString;
  i : Integer;
begin
  data := #01#01 +
          qword_LEasStr(eventID) + // Cookie
          #00#00 +                 // Encrypt
          #00#00 +                 // Comp
          word_BEasStr(1)+         // TotFil
          word_BEasStr(1)+         // FilLft
          word_BEasStr(1*1)+       // TotPrts
          word_BEasStr(1*1)+       // PrtsLft
          dword_BEasStr(fileSizeTotal)+// TotSz
          dword_BEasStr(fileSizeTotal)+// Size
          dword_BEasStr(0)+        // ModTime
          dword_BEasStr(fileChkSum)+ // Checksum
          dword_BEasStr($FFFF0000)+  // RfrcvCsum
          dword_BEasStr(0)+          //RfSize
          dword_BEasStr(0)+          //CreTime
          dword_BEasStr($FFFF0000)+  //RfcSum
          dword_BEasStr(0)+          //nRecvd
          dword_BEasStr($FFFF0000)+  //RecvCsum
          'CoolFileXfer'+z+  //IDString
          z+z+z+z+  //IDString
          #$20+                       //Flags: $20 – Negotiation, $01 – Done
          #$1C+                       //NameOff
          #$11+                       //SizeOff
          z+z+z+z+z+                  //Dummy
          z+z+z+z+z+                  //Dummy
          z+z+z+z+z+                  //Dummy
          z+z+#00+                    //Dummy
          z+z+z+z+                    // MacFileInfo
          word_BEasStr(2)+            // Encoding: 0000-ASCII, 0002 - UTF-16BE or UCS-2BE, 0003 - ISO-8859-1
          word_BEasStr(0)+            // Subcode
          StrToUnicode(fileName + #00);
  i := Length(data);
  if i < $100-6 then
   begin
    SetLength(data, $100-6);
    FillMemory(@data[i+1], ($100-6-i), 0);
   end;
  s := 'OFT2' + word_BEasStr(length(data)+6)+data;
  sendPkt(s);
end;


{
procedure TICQDirect.parseVcard(s:string);
begin
hisVer:=ord(s[2]);
if contact=NIL then
  begin
  contact:=contactsDB.get(dword_LEat(@s[16]));
  contact.connection.port:=word_LEat(@s[29]);
  end;
end; // parseVcard

procedure TICQDirect.sendACK1;
begin sendPkt(#1#0#0#0) end;

procedure TICQDirect.sendACK2;
begin sendPkt(#1+dword_LEasStr(myspeed)+WNTS(myinfo.displayed)) end;

procedure TICQDirect.sendACK3;
begin sendPkt(#3+Z+Z+dword_LEasStr(myspeed)+#1#0#0) end;

procedure TICQDirect.sendVcard;
begin
sendPkt(
  #$FF+char(6)+#0#$2B#0+dword_LEasStr(contact.uid)+#0#0+
  dword_LEasStr(directs.icq.serverPort)+directs.icq.myUINle+
  dword_LEasStr(directs.icq.getLocalIP)+#127#0#0#1+#4+
  dword_LEasStr(directs.icq.serverPort)+dword_LEasStr(contact.dc_cookie)+
  #$50#0#0#0#3#0#0#0#0#0#0#0
);
end;

procedure TICQDirect.sendSpeed;
begin sendPkt(#5+dword_LEasStr(myspeed)) end;

}
///////////////////////////////////////////////////////////////////////

{$ENDIF usesDC}
///////////////////////////////////////////////////////////////////////

class function TicqSession._RegisterUser(var pUID : TUID; var pPWD : String) : Boolean;
begin
{$IFDEF USE_REGUIN}
  newaccountFrm:=TnewaccountFrm.create(NIL);
  translateWindow(newaccountFrm);
  if newaccountFrm.showModal = mrOk then
    begin
      Result := True;
      pUID := ...
//      pUID :=
    end;
//  ForceForegroundWindow(handle);
  freeAndNIL(newaccountFrm);
{$ELSE}
  Result := False;
  openURL('http://www.icq.com/join/');
{$ENDIF USE_REGUIN}
end;

class function TicqSession._CreateProto(const uid : TUID) : TRnQProtocol;
begin
  Result := TicqSession.Create(uid, SESS_IM);
end;

constructor TicqSession.create(const id : TUID; subType : TICQSessionSubType);
begin

  protoType := subType;
  fContactClass := TICQcontact;

  inherited create;

  phase:=null_;
  listener:=NIL;
  avt_icq := NIL;

  if id='' then
    begin
      MyAccount := '';
//      myinfo0:=NIL
    end
   else
    begin
//      myinfo0 := getICQContact(id);
//      MyAccount := myinfo0.UID2cmp;
      MyAccount := TICQContact.trimUID(id);
    end;
  if (MyAccount <> '') and
    (pos(AnsiChar('@'), MyAccount) > 1) then
    Attached_login_email := MyAccount
   else
    Attached_login_email := '';
  fPwd     := '';
  fPwdHash := '';
  fSessionTokenExpIn := 86400;
  SNACref:=1;
//  FLAPseq:=$6700+random($100);
//  FLAPseq := Flap_start;
//  FLAPseq :=  Flap_start+random($100);
//  FLAPseq := Flap_Start1;   // 20090122 - из-за ICQ 6.5
  FLAPseq := getFirstFlap;
  lastSendedFlap := now;
  curStatus := SC_OFFLINE;
  fVisibility := VI_normal;
  curXStatus := 0;
  startingStatus := SC_ONLINE;

sock:=TRnQSocket.create(NIL);
sock.OnSessionConnected:=connected;
sock.OnDataAvailable:= onDataAvailable;
sock.OnDataReceived := received;
sock.OnSessionClosed:= disconnected;
sock.OnSocksError := OnProxyError;
sock.OnProxyTalk := OnProxyTalk;
//sock.FlushTimeout
//sock.http.enabled:=FALSE;

  cookie := '';
  cookieTime := 0;
  with _getDefHost do
   begin
    loginServerAddr := host;
    loginServerPort := IntToStrA(port);
   end;
Q:=TflapQueue.create;

  if subType = SESS_IM then
   begin
    {$IFDEF usesDC}
      directs:= Tdirects.create(self);
    {$ENDIF usesDC}
    DCmode:=DC_none;
    showInfo := 2;
    webaware := True;
    fRoster      := TRnQCList.create;
    fVisibleList  := TRnQCList.create;
    fInvisibleList:= TRnQCList.create;
    {$IFDEF UseNotSSI}
     fIntVisibleList  := TRnQCList.create;
     fIntInvisibleList:= TRnQCList.create;
     fUseSSI := True;
     fUseLSI := False;
    {$ENDIF UseNotSSI}
    tempVisibleList:=TRnQCList.create;
    spamList := TRnQCList.Create;

    SSIacks := TSSIacks.Create;

    savingmyinfo.running:=FALSE;
      uploadAvatarFN := '';
      avtSessInit := False;
    {$IFDEF RNQ_AVATARS}
      avt_icq := TicqSession.create('', SESS_AVATARS);
//      avt_icq.listener := RnQmain.avticqEvent;
      avt_icq.listener:= self.listener;
      avt_icq.mainICQ := self;
    {$ENDIF RNQ_AVATARS}

    {$IFDEF usesDC}
    // server:=Twsocket.create(NIL);
    //  server.OnSessionAvailable:=dc_connected;
    {$ENDIF usesDC}
   end;

end; // create

procedure TicqSession.ResetPrefs;
var
  i : Integer;
begin
//  ICQ.readList(LT_VISIBLE).clear;
//  ICQ.readList(LT_INVISIBLE).clear;
  inherited ResetPrefs;

  fVisibleList.clear;
  fInvisibleList.Clear;
  DCmode := DC_NONE;
  setDCfakeIP('6.6.6.0');
  DCfakePort := 666;
  curXStatus := 0;
  authNeeded:=True;

  with aProxy do
   begin
//    enabled:=FALSE;
  //  for pp:=low(pp) to high(pp) do addr[pp].host:='';
    addr.host:='';
  //  addr[PP_SOCKS4].port:='1080';
  //  addr[PP_SOCKS5].port:='1080';
  //  addr[PP_HTTPS].port:='3128';
    addr.port:=1080;
    proto:=PP_NONE;
    auth:=FALSE;
    NTLM := False;
    serv := TicqSession._getDefHost;
    ssl := False;
   end;

  pPublicEmail := False;
  showClientID := True;
  offlineMsgsChecked := TRUE;
    supportInvisCheck := false;
 {$IFDEF CHECK_INVIS}
    CheckInvis.ShowInvisibility:=TRUE;
    CheckInvis.AutoCheck:=false;
    CheckInvis.AutoCheckInterval:=180;
    CheckInvis.ChkInvisInterval :=3.5;
    CheckInvis.AutoCheckOnSend := false;
    CheckInvis.AutoCheckGoOfflineUsers := false;
    CheckInvis.Method := 0;
    showCheckedInvOfl := True;
//    CheckInvis.AutoCheckOnSend := false;
 {$ENDIF}
  AddExtCliCaps := False;
  ExtClientCaps := '';
  typingInterval := 5;
  SupportUTF  := True;
  SendingUTF  := True;
  UseCryptMsg := True;
  UseAdvMsg   := True;
  useFBcontacts := false;
  AvatarsSupport := True;
  AvatarsAutoGet := True;
{$IFDEF RNQ_LITE}
  AvatarsAutoGetSWF := False;
  AvatarsNotDnlddInform := True;
{$ELSE RNQ_FULL}
  AvatarsAutoGetSWF := True;
  AvatarsNotDnlddInform := False;
{$ENDIF RNQ_LITE}
  myAvatarHash := '';
 saveMD5Pwd:=False;
// icq.myInfo.Icon_hash_safe := '';

//      useSSI := True;
 {$IFDEF ICQ_OLD_STATUS}
//   UseOldXSt := False;
 {$ENDIF ICQ_OLD_STATUS}
 {$IFDEF UseNotSSI}
   LoginMD5:=True;
   useSSI2 := masterUseSSI;
 {$ENDIF UseNotSSI}
//    serverSSI.itemCnt := 0;
//    serverSSI.modTime := 0;
//    serverSSI.items   := nil;
    clearSSIList(serverSSI);
    localSSI_itemCnt  := 0;
    localSSI_modTime  := 0;
{    localSSI.itemCnt  := 0;
    localSSI.modTime  := 0;
    localSSI.items    := nil;}
  showInvisSts := True;
  addTempVisMsg := False;
  sendBalloonOn:=BALLOON_NEVER;
  onStatusDisable[byte(SC_dnd)].blinking:=TRUE;
  onStatusDisable[byte(SC_dnd)].sounds:=TRUE;
  for I := low(XStatusArray) to High(XStatusArray) do
   begin
     ExtStsStrings[i].Cap := getTranslation(XStatusArray[i].Caption);
     ExtStsStrings[i].Desc := '';
   end;
end;

procedure TicqSession.GetPrefs(var pp : TRnQPref);
var
  i : Integer;
  s : String;
  sR : RawByteString;
begin
  if (MyAccount <> '') and
    (pos(AnsiChar('@'), MyAccount) <= 0) then
   pp.addPrefStr('oscar-uid', MyAccount);
  pp.addPrefBool('add-to-vislist-before-msg', addTempVisMsg);
  pp.addPrefBool('add-client-caps', AddExtCliCaps);
  pp.addPrefStr('add-client-caps-str', Str2hex(ExtClientCaps));
  pp.addPrefInt('send-balloon-on', sendBalloonOn);
  pp.addPrefDate('send-balloon-on-date', sendBalloonOnDate);
 try
   pp.addPrefBool('public-email', pPublicEmail);
   pp.addPrefBool('login-md5', LoginMD5);
   pp.addPrefBool('save-md5-pass', saveMD5Pwd);
  except
//    msgDlg('Какая-то глупая ошибка :(((', mtError);
 end;
//  pp.addPrefStr('server-host', MainProxy.serv.host);
//  pp.addPrefInt('server-port', MainProxy.serv.port);
  pp.addPrefBool('connection-ssl', MainProxy.ssl);
  pp.addPrefInt('typing-notify-interval', typingInterval);
  pp.addPrefBool('support-utf8', SupportUTF);
  pp.addPrefBool('sending-utf8', SendingUTF);
  pp.addPrefBool('use-crypt-msg', useCryptMsg);
  pp.addPrefBool('use-adv-msg', useAdvMsg);
  pp.addPrefBool('use-xmpp-contacts', useFBcontacts);
  pp.addPrefBool('avatars-flag', AvatarsSupport);
  pp.addPrefBool('avatars-auto-load-flag', AvatarsAutoGet);
  pp.addPrefBool('avatars-auto-swf-flag', AvatarsAutoGetSWF);
  pp.addPrefBool('avatars-not-downloaded-inform-flag', AvatarsNotDnlddInform);
  pp.addPrefStr('avatar-my', Str2hex(myAvatarHash));
 {$IFDEF CHECK_INVIS}
  pp.addPrefBool('invisibility-flag', CheckInvis.ShowInvisibility);
  pp.addPrefBool('check-invisibility-every', CheckInvis.AutoCheck);
  pp.addPrefInt('check-invisibility-interval', CheckInvis.AutoCheckInterval);
  pp.addPrefInt('check-invis-interval', Round(CheckInvis.ChkInvisInterval*10));
  pp.addPrefBool('support-invis-check', supportInvisCheck);
  pp.addPrefBool('check-invisibility-on-send', CheckInvis.AutoCheckOnSend);
  pp.addPrefBool('check-invisibility-on-offl', CheckInvis.AutoCheckGoOfflineUsers);
  pp.addPrefInt('check-invisibility-method', CheckInvis.Method);
  pp.addPrefBool('show-checked-offlines', showCheckedInvOfl);
 {$ENDIF}
  pp.addPrefBool('show-invis-status', showInvisSts);
 {$IFDEF UseNotSSI}
  pp.addPrefBool('use-ssi', useSSI2);
  pp.addPrefBool('use-lsi', useLSI2);
 {$ELSE UseNotSSI}
  pp.addPrefBool('use-lsi', False);
  pp.addPrefBool('use-ssi', True);
 {$ENDIF UseNotSSI}
//  pp.addPrefTime('local-ssi-time', localSSI.modTime);
//  pp.addPrefInt('local-ssi-count', localSSI.itemCnt);
  pp.addPrefTime('local-ssi-time', localSSI_modTime);
  pp.addPrefInt('local-ssi-count', localSSI_itemCnt);

    //for st:=SC_ONLINE to pred(SC_OFFLINE) do
   for i in self.getStatusMenu do
//    for i := byte(low(tICQStatus)) to byte(high(tICQstatus)) do
    if i <> byte(SC_OFFLINE) then
     begin
      s := status2Img[i]+'-disable-';
      pp.addPrefBool( s+'blinking', onStatusDisable[i].blinking);
      pp.addPrefBool( s+'tips', onStatusDisable[i].tips);
      pp.addPrefBool( s+'sounds', onStatusDisable[i].sounds);
      pp.addPrefBool( s+'openchat', onStatusDisable[i].OpenChat);
     end;
//    icq := TicqSession(mainproto.ProtoElem);
    pp.addPrefBool('auth-needed', self.authneeded);
    pp.addPrefStr('dc-mode', self.getDCModeStr);
    pp.addPrefStr('dc-fake-ip', self.getDCfakeIP);
    pp.addPrefInt('dc-fake-port', self.getDCfakePort);
    pp.addPrefBool('webaware', self.webaware);
    pp.addPrefBool('show-client-id', showClientID);
//    pp.addPrefBool('use-old-xstatus', useOldxSt);
    pp.addPrefInt('xstatus', self.curXStatus);
    pp.addPrefInt('icq-showinfo', self.showInfo);
//      +'proxy='+yesno[ICQ.proxy.enabled]+CRLF
//      +'proxy='+yesno[false]+CRLF // for old R&Q
      ;
      //for pp:=low(pp) to high(pp) do result:=result
      //  +'proxy-'+proxyproto2str[pp]+'-host='+proxy.addr[pp].host+CRLF
      //  +'proxy-'+proxyproto2str[pp]+'-port='+proxy.addr[pp].port+CRLF;
  if not (RnQstartingStatus in [Low(status2Img)..High(status2Img)]) then
    pp.addPrefStr('starting-status', 'last_used')
   else
    pp.addPrefStr('starting-status', status2Img[RnQstartingStatus]);
  pp.addPrefStr('starting-visibility', visib2str[TVisibility(RnQstartingVisibility)]);

  pp.addPrefStr('last-set-status', status2Img[lastStatusUserSet]);


  inherited GetPrefs(pp);

// Added here to safe MD5 hash
  if not dontSavePwd //and not locked
  then
    begin
      if saveMD5Pwd then
        sR := fPwdHash
       else
        sR := StrToUTF8(fPwd);
//      pp.addPrefBlob('crypted-password', passCrypt(sR));
      pp.addPrefBlob64('crypted-password64', passCrypt(sR))
    end
   else
    begin
      pp.DeletePref('crypted-password64');
    end;

end;

procedure TicqSession.SetPrefs(pp : TRnQPref);
var
  i : Integer;
  sU, sU2 : String;
  st: Byte;
  l : RawByteString;
  myInf : TRnQContact;
begin
  inherited SetPrefs(pp);

  pp.getPrefStr('oscar-uid', sU);
  if sU > '' then
    MyAccount := sU;

  pp.getPrefBool('public-email', pPublicEmail);
  pp.getPrefBool('add-client-caps', AddExtCliCaps);
  ExtClientCaps := hex2str(pp.getPrefBlobDef('add-client-caps-str'));

     case pp.getPrefIntDef('dc-mode') of
      0 : dcMode := DC_NONE;
      1 : dcMode := DC_UPONAUTH;
      2 : dcMode := DC_ROSTER;
      3 : dcMode := DC_EVERYONE;
     end;
     setDCfakeIP(pp.getPrefBlobDef('dc-fake-ip'));
     DCfakePort := pp.getPrefIntDef('dc-fake-port', DCfakePort);
     authneeded := pp.getPrefBoolDef('auth-needed', authneeded);
     webaware   := pp.getPrefBoolDef('webaware', webaware);
     showInfo   := pp.getPrefIntDef('icq-showinfo', showInfo);
     i := pp.getPrefIntDef('xstatus');
     if i >=0 then
      begin
//        if i > High(XStatus6) then
        if (i in [low(XStatusArray)..High(XStatusArray)])
//             and (xsf_6 in XStatusArray[i].flags)
         then
          curXStatus := i
         else
          curXStatus := 0
      end;

     pp.getPrefInt('send-balloon-on', sendBalloonOn);
     pp.getPrefDate('send-balloon-on-date', sendBalloonOnDate);
 {$IFDEF ICQ_OLD_STATUS}
//      pp.getPrefBool('use-old-xstatus', useOldxSt);
 {$ENDIF ICQ_OLD_STATUS}
   {$IFDEF UseNotSSI}
      pp.getPrefBool('login-md5', LoginMD5);
   {$ENDIF UseNotSSI}
   {$IFDEF UseNotSSI}
      pp.getPrefBool('use-ssi', useSSI2);
      pp.getPrefBool('use-lsi', useLSI2);
   {$ENDIF UseNotSSI}
//      pp.getPrefInt('local-ssi-count', localSSI.itemCnt);
//      pp.getPrefDateTime('local-ssi-time', localSSI.modTime);
      pp.getPrefInt('local-ssi-count', localSSI_itemCnt);
      pp.getPrefDateTime('local-ssi-time', localSSI_modTime);

      for st := Byte(low(tICQstatus)) to Byte(high(tICQstatus)) do
  //  for st:=SC_ONLINE to pred(SC_OFFLINE) do
      with onStatusDisable[byte(st)] do
       begin
//        sU2 := status2Img[st];
        sU2 := status2Img[st] + '-disable-';
//        sU := sU2+'-disable-blinking';
        sU := sU2+'blinking';
        pp.getPrefBool(sU, blinking);
//        sU := sU2+'-disable-tips';
        sU := sU2+'tips';
        pp.getPrefBool(sU, tips);
//        sU := sU2+'-disable-sounds';
        sU := sU2+'sounds';
        pp.getPrefBool(sU, sounds);
//        sU := sU2+'-disable-openchat';
        sU := sU2+'openchat';
        pp.getPrefBool(sU, OpenChat);
       end;

  pp.getPrefBool('add-to-vislist-before-msg', addTempVisMsg);
 {$IFDEF CHECK_INVIS}
  pp.getPrefBool('support-invis-check', supportInvisCheck);
  pp.getPrefBool('invisibility-flag', CheckInvis.ShowInvisibility);
  pp.getPrefBool('check-invisibility-every', CheckInvis.AutoCheck);
  pp.getPrefInt('check-invisibility-interval', CheckInvis.AutoCheckInterval);
  CheckInvis.ChkInvisInterval := pp.getPrefIntDef('check-invis-interval', trunc(CheckInvis.ChkInvisInterval * 10)) / 10;
  pp.getPrefBool('check-invisibility-on-send', CheckInvis.AutoCheckOnSend);
  pp.getPrefBool('check-invisibility-on-offl', CheckInvis.AutoCheckGoOfflineUsers);
  CheckInvis.Method := pp.getPrefIntDef('check-invisibility-method', CheckInvis.Method);
  pp.getPrefBool('show-checked-offlines', showCheckedInvOfl);
 {$ENDIF}
  pp.getPrefBool('save-md5-pass', saveMD5Pwd);
  if pp.prefExists('crypted-password64') then
    l := passDecrypt(pp.getPrefBlob64Def('crypted-password64'))
   else
    l := passDecrypt(pp.getPrefBlobDef('crypted-password'));
  if saveMD5pwd then
    begin
      pwd := '';
      if (length(l) < 16) and (length(l) > 0)  then
        fPwdHash := MD5Pass(l)
       else
        fPwdHash := l
    end
   else
    begin
      pwd:= UnUTF(l);
      fPwdHash := '';
    end;
  l := '';
  pp.getPrefInt('typing-notify-interval', typingInterval);
  pp.getPrefBool('support-utf8', SupportUTF);
  pp.getPrefBool('use-crypt-msg', useCryptMsg);
  pp.getPrefBool('sending-utf8', SendingUTF);
  pp.getPrefBool('use-adv-msg', useAdvMsg);
  pp.getPrefBool('use-xmpp-contacts', useFBcontacts);
  pp.getPrefBool('avatars-flag', AvatarsSupport);
  pp.getPrefBool('avatars-auto-load-flag', AvatarsAutoGet);
  pp.getPrefBool('avatars-auto-swf-flag', AvatarsAutoGetSWF);
  pp.getPrefBool('avatars-not-downloaded-inform-flag', AvatarsNotDnlddInform);
  pp.getPrefBool('show-invis-status', showInvisSts);
  pp.getPrefBool('show-client-id', showClientID);

  pp.getPrefBool('connection-ssl', MainProxy.ssl);
  pp.getPrefStr('server-host', MainProxy.serv.host);
  pp.getPrefInt('server-port', MainProxy.serv.port);
  l := pp.getPrefBlobDef('starting-status');
    if l='last_used' then
      RnQstartingStatus:=-1
     else
      RnQstartingStatus:= str2status(l);
  l := pp.getPrefBlobDef('starting-visibility');
    RnQstartingVisibility:= Byte(str2visibility(l));

  l := pp.getPrefBlobDef('last-set-status');
    lastStatusUserSet := str2status(l);

//  setVisibility(self, byte(RnQstartingVisibility));
    visibility:=Tvisibility(RnQstartingVisibility);
   {$IFDEF UseNotSSI}
    updateVisibility;
   {$ENDIF UseNotSSI}


  myAvatarHash := hex2str(pp.getPrefBlobDef('avatar-my'));
  if contactsDB.idxOf(TICQContact, MyAccount)>=0 then
   with TICQcontact(getMyInfo) do
    begin
//        status := ticqStatus(SC_OFFLINE);
      ICQIcon.hash_safe := myAvatarHash;
    end;

  applyBalloon();

  fSSLServer := pp.getPrefStrDef('oscar-ssl-server',
                             ICQ_SECURE_LOGIN_SERVER0);
  fOscarProxyServer := pp.getPrefStrDef('oscar-proxy-server',
                             AOL_FILE_TRANSFER_SERVER0);

end;


procedure TicqSession.Clear;
begin
//  myinfo0:=NIL;
  readList(LT_ROSTER).clear;
  readList(LT_VISIBLE).Clear;
  readList(LT_INVISIBLE).Clear;
  readList(LT_TEMPVIS).Clear;
  readList(LT_SPAM).Clear;

{$IFDEF UseNotSSI}
  fIntVisibleList.clear;
  fIntInvisibleList.clear;
{$ENDIF UseNotSSI}
  FreeAndNil(eventContacts);
  eventContact := NIL;
end;

destructor TicqSession.destroy;
begin
 {$IFDEF usesDC}
  directs.free;
// server.Free;
 {$ENDIF usesDC}
 {$IFDEF RNQ_AVATARS}
  if Assigned(avt_icq) then
    freeAndNIL(avt_icq);
 {$ENDIF RNQ_AVATARS}

Q.free;
sock.free;
fRoster.free;
fVisibleList.free;
fInvisibleList.free;
{$IFDEF UseNotSSI}
fIntVisibleList.free;
fIntInvisibleList.free;
{$ENDIF UseNotSSI}
tempvisibleList.free;
spamList.Free;
SSIacks.Free;

//  imageStream.Free;
  inherited destroy;
end; // destroy

function TicqSession.myUINle: RawByteString;
begin result:=dword_LEasStr(StrToIntDef(myAccount, 0)) end;

function  TicqSession.getMyInfo : TRnQcontact;
begin
//  result := MyInfo0;
  Result := contactsDB.add(Self, MyAccount);
end;
{procedure TicqSession.setMyInfo(cnt : TRnQContact);
begin
  myInfo := TICQContact(cnt);
end;}
function TicqSession.isMyAcc(c : TRnQContact) : Boolean;
begin
//  result := MyInfo0.equals(c);
  Result := Assigned(c) and c.equals(MyAccount)
end;

function TicqSession.canAddCntOutOfGroup : Boolean;
begin
 {$IFDEF UseNotSSI}
    Result := not (UseSSI);
 {$ELSE UseNotSSI}
   result := false;
 {$ENDIF UseNotSSI}
end;

function TicqSession.pwdEqual(const pass : String) : Boolean;
begin
  Result := ((pass<>'')and(pass = fPwd)) or (MD5Pass(pass) = fPwdHash);
end;

function  TicqSession.getPwd : String;
begin
  if saveMD5Pwd then
    Result := fPwdHash
   else
    Result := fPwd;
end;

function TicqSession.getPwdOnly: String;
begin
  Result := fPwd;
end;

function TicqSession.getSession: TSessionParams;
var
  params: TSessionParams;
begin
  if (fSessionToken = '') or
     (fSessionTokenTime = 0) or
     (fSessionTokenTime + fSessionTokenExpIn > DateTimeToUnix(Now, False)) then
     refreshSessionSecret();

  params.secret := fSessionSecret;
  params.token := fSessionToken;
  params.tokenExpIn := fSessionTokenExpIn;
  params.tokenTime := fSessionTokenTime;
  Result := params;
end;

procedure TicqSession.setPwd(const value:String);
 procedure chg(const v : String);
 begin
   if saveMD5pwd and LoginMD5 then
     begin
       fPwd := '';
       if v > '' then
         fPwdHash := MD5Pass(v)
        else
         fPwdHash := '';
       // For login by mail
       if (MyAccount <> '') and
          (pos(AnsiChar('@'), MyAccount) > 1) then
         fPwd := v;
     end
    else
     begin
       fPwd := v;
       fPwdHash := '';
     end;
 end;
begin
if not pwdEqual(Value) and (length(value) <= maxPwdLength) then
  if isOnline and (value > '') then
    begin
//     if (not saveMD5Pwd) and (MD5Pass(fpwd)=Value) then ;;;
     if messageDlg(getTranslation('Really want to change password on server?'), mtConfirmation, [mbYes,mbNo],0, mbNo, 20) = mrYes then
      begin
       sendChangePwd(value);
       chg(value);
      end
    end
  else
    chg(value);
end; // setPwd

function TicqSession.sendFLAP(ch: word; const data: RawByteString): boolean;
var
  s: RawByteString;
begin
  result := FALSE;
  if sock.State <> wsConnected then exit;
  s := RawByteString('*')
    + AnsiChar(ch)
    + word_BEasStr(FLAPseq)
    + word_BEasStr(length(data))
    + data;
  try
   while abs(now - lastSendedFlap) < DT2100miliseconds do
//    Application.ProcessMessages
    ;
   sock.sendStr(RawByteString(s));
   lastSendedFlap := now;
{  if phase=online_ then
   begin
    inc(SendedFlaps);
    if (SendedFlaps > ICQMaxFlaps)and (phase=online_)  then
      sock.Pause;
   end;}
   eventData:=s;
   notifyListeners(IE_serverGot);
   inc(FLAPseq);
   if FLAPseq >= $8000 then FLAPseq:=0;
  except
  end;
  s := '';
  result := TRUE;
end; // sendFLAP

function TicqSession.sendSNAC(fam, sub: word; const data: RawByteString): boolean;
begin
  result := sendFLAP(SNAC_CHANNEL, SNAC(fam,sub, SNACref)+data)
end;

function TicqSession.sendSNAC(fam,sub, flags:word; const data: RawByteString):boolean;
begin
  result := sendFLAP(SNAC_CHANNEL, SNAC(fam,sub,flags, SNACref)+data)
end;

procedure TicqSession.sendKeepalive;
begin
    sendFLAP(KEEPALIVE_CHANNEL,'');
   {$IFDEF RNQ_AVATARS}
//  if (not isAvatarSession) and avt_icq.isOnline then
  if (protoType = SESS_IM) and avt_icq.isOnline then
    avt_icq.sendFLAP(KEEPALIVE_CHANNEL,'')
   {$ENDIF RNQ_AVATARS}
end;

procedure TicqSession.notifyListeners(ev:TicqEvent);
begin
  if assigned(listener) then
//    listener(self,ev);
   listener(self, Integer(ev));
end; // notifyListeners

function TicqSession.isOffline:boolean;
begin
  result:= phase=null_
end;

function TicqSession.isOnline:boolean;
begin
  result:= phase=online_
end;

function TicqSession.isConnecting:boolean;
begin
//  result:=not (isOffline or isOnline)
  result:=(phase<>online_) and (phase<>null_)
end;

{$IFDEF usesDC}
procedure TicqSession.dc_connected(Sender: TObject; Error: Word);
var
  a : Word;
begin
if error<>0 then
  begin
    a := WSocket_WSAGetLastError;
  if a <> 0 then
   begin
    error := a;
    eventMsgA := WSocketErrorDesc(error)
   end;
  eventInt := error;
  eventError:=EC_cantconnect_dc;
  notifyListeners(IE_error);
  exit;
  end;
//eventDirect:=directs.newFor(NIL);
//eventDirect.sock.dup(server.accept);
notifyListeners(IE_dcConnected);
end; // dc_connected
{$ENDIF usesDC}

procedure TicqSession.goneOffline;
var
  i:integer;
begin
  if phase=null_ then exit;
  phase:=null_;
//  if not isAvatarSession then
  if protoType = SESS_IM then
   begin
      tempvisibleList.clear;
      clearSSIList(serverSSI);
    {$IFDEF usesDC}
    // if DCmode <> DC_none then
    //  if Assigned(server) then
    //   server.close;
    {$ENDIF usesDC}
      curStatus := SC_OFFLINE;
        with fRoster, TList(fRoster) do
         for i:=0 to count-1 do
          with TICQContact(getAt(i)) do
           begin
            OfflineClear;
            status:= SC_UNK;
          end;
   end;
  notifyListeners(IE_offline);
end; // goneOffline

procedure TicqSession.disconnect;
begin
 sendFLAP(LOGOUT_CHANNEL, '');   // Посылаем серверу отключение
 q.reset;
 sock.close;
 goneOffline;
end;

procedure TicqSession.connected(Sender: TObject; Error: Word);
begin
  eventTime := now;
  if error <> 0 then
  begin
    goneOffline;
    eventInt:=WSocket_WSAGetLastError;
    if eventInt=0 then
     eventInt:=error;
    eventMsgA := WSocketErrorDesc(eventInt);
    eventError:=EC_cantconnect;
    notifyListeners(IE_error);
    exit;
  end;
  eventAddress:=sock.Addr;
  if sock.SslEnable then
   eventAddress := eventAddress + '  '+ crlf + sock.SslVersion +'; '+ sock.SslCipher;
  notifyListeners(IE_serverConnected);
  proxy_connected;
end; // connected

procedure TicqSession.proxy_connected;
begin
{$IFDEF USE_REGUIN}
//if creatingUIN then
  if protoType = SESS_NEW_UIN then
   begin
    phase:=creating_uin_;
    notifyListeners(IE_connected);
   end
 else
{$ENDIF USE_REGUIN}
  case phase of
    connecting_:
      begin
//        FLAPseq := Flap_Start1;   // 20090122 - èç-çà ICQ 6.5
        FLAPseq := getFirstFlap;
      phase:=login_;
      notifyListeners(IE_connected);
      end;
    reconnecting_:
      begin
//        FLAPseq := Flap_Start2;   // 20090122 - èç-çà ICQ 6.5
        FLAPseq := getFirstFlap;
      phase:=relogin_;
      notifyListeners(IE_redirected);
      end;
    end
end; // proxy_connected

procedure TicqSession.disconnected(Sender: TObject; Error: Word);
begin
q.reset;
eventAddress:=sock.addr;
eventMsgA := '';
notifyListeners(IE_serverDisconnected);
if error <> 0 then
  begin
  goneOffline;
  eventInt:=WSocket_WSAGetLastError;
//  GetWinsockErr
  if eventInt=0 then eventInt:=error;
  eventMsgA := WSocketErrorDesc(eventInt);
  eventError:=EC_socket;
  notifyListeners(IE_error);
  exit;
  end;
if (phase<>login_)or(cookie='') then
  goneOffline;
end; // disconnected

function TicqSession.isReady:boolean;
begin
  result := phase in [SETTINGUP_,ONLINE_]
end;

function TicqSession.isSSCL:boolean;
begin
  Result :=
 {$IFDEF UseNotSSI}
       self.useSSI
 {$ELSE ~UseNotSSI}
       True;
 {$ENDIF UseNotSSI}
end;

procedure TicqSession.sendVisibility;
var
  i : Integer;
  s : RawByteString;
begin
  if isReady then
  begin
        s := TLV($CA, AnsiChar(visibility2SSIcode[visibility]))+      // PD_MODE
             TLV($D0, #1)+               //
             TLV($D1, #1)+
             TLV($D2, #1)+
             TLV($D3, #1)+
             TLV($CB, AnsiString(#$FF#$FF#$FF#$FF))
//             +TLV($15F, 0)             // WEB_PD_MODE
             ; // PD_MASK
      i := FindSSIItemType(serverSSI, FEEDBAG_CLASS_ID_PDINFO);
      if i >= 0 then
        begin
//          serverSSI.items
          with TOSSIItem(serverSSI.items.Objects[i]) do
           begin
//            s := getTLVSafe($CA, ExtInfo);
//            s := replaceAddTLV($CA, ExtInfo, 1, Char(visibility2SSIcode[visibility]));
//            s := TLV($CA, Char(visibility2SSIcode[visibility]))+
//                 TLV($D0, #1)+TLV($D1, #1)+TLV($D2, #1)+TLV($D3, #1)+
//                 TLV($CB, #$FF#$FF#$FF#$FF);
            SSI_UpdateItem(ItemName, s, GroupID, ItemID, FEEDBAG_CLASS_ID_PDINFO);
           end;
        end
      else
       begin
//        s := TLV($CA, Char(visibility2SSIcode[visibility]))+
//             TLV($D0, #1)+TLV($D1, #1)+TLV($D2, #1)+TLV($D3, #1)+
//             TLV($CB, #$FF#$FF#$FF#$FF);
        SSI_CreateItem('', S, 0, 0, FEEDBAG_CLASS_ID_PDINFO);
       end;
  end;
end;

procedure TicqSession.resetStatusCode; //011E
begin
  if not isReady then Exit;

  sendSNAC(ICQ_SERVICE_FAMILY, $1E, TLV($06, dword_Zero));
//  addRef(REF_status, '');
end;

procedure TicqSession.sendStatusCode(sendVis : Boolean); //011E
const
  vcookie=#1#2#3#4;
var
  dc : RawByteString;
//  i : Integer;
  i : Cardinal;
  StFirst : Boolean;
  xStsTLV : RawByteString;
  Pck     : RawByteString;
begin
  if not isReady then
    exit;

  if DCmode = DC_none then
    dc := Z+dword_BEasStr(0)
   else
    if DCmode = DC_FAKE then
      dc := dword_LEasStr(fDC_Fake_ip.S_addr) + dword_BEasStr(fDC_Fake_port)
     else
      dc:=dword_LEasStr(getLocalIP) +
//  server.GetXAddr + //#127#0#0#1+
        dword_BEasStr(serverPort);
  if sock.http.enabled then
    dc := dc+#1#0
   else
    if sock.SocksServer <> '' then
      dc := dc+#2#0
     else
      dc := dc+#4#0;
 dc:=dc + AnsiChar(ICQ_TCP_VERSION)+vcookie+dword_BEasStr($50)
//  + #0#0#0#3+dword_BEasStr(myinfo.lastUpdate_dw)+dword_BEasStr(myinfo.lastInfoUpdate_dw)+Z+#0#0;
  + #0#0#0#1;
 if showClientID then
   begin
     i := RnQBuild;
    if LiteVersion then
     i:= $40000000 or i;
    if TestVersion then
     i:= $80000000 or i;
    dc := dc +dword_BEasStr(RnQclientID)+dword_BEasStr(i)
   end
  else
   dc := dc + dword_BEasStr(Random($40FFFFFF)) + dword_BEasStr(Random($40FFFFFF));
 dc := dc+ dword_BEasStr(Random($40FFFFFF)) +#0#0;

  StFirst := True;
  if previousInvisible<>isInvisible then
    begin
{$IFDEF UseNotSSI}
      if not useSSI then
       sendAddVisible(fIntVisibleList);
{$ENDIF UseNotSSI}
      if isInvisible then
       StFirst := False;
    end;
//  else
{
  if UseOldXSt then
    xStsTLV := TLV($1D, word_BEasStr($02) + AnsiChar(#$04) + BUIN( Length_BE('')+Length_BE('') // 'iso-8859-1'
                     )+
                   TLV(BART_TYPE_STATUS_MOOD, ''))
   else
    xStsTLV := TLV($1D, word_BEasStr($02) + AnsiChar(#$04) + BUIN( Length_BE(StrToUTF8(ExtStsStrings[curXStatus].Desc))+
                     Length_BE('') // 'iso-8859-1'
                     )+
                   TLV(BART_TYPE_STATUS_MOOD, XStatusArray[curXStatus].pid6));
}
    xStsTLV := TLV($1D, word_BEasStr(BART_TYPE_STATUS_STR) +
                     AnsiChar(BART_FLAGS_DATA) +
//                     Length_B( Length_BE(StrToUTF8(ExtStsStrings[curXStatus].Desc))+
                     Length_B( Length_BE(StrToUTF8(curXStatusStr.Desc))+
                               Length_BE('') // 'iso-8859-1'
                      )
                     +
                     TLV(BART_TYPE_STATUS_MOOD, '')
{
                     word_BEasStr(BART_TYPE_STATUS_MOOD) +
                      AnsiChar(BART_FLAGS_DATA)+
//                      Length_B(XStatusArray[curXStatus].pid6)
                      Length_B('')
}
                   );
  Pck := TLV(6, getFullStatusCode)
//      + TLV(8, #0#0)
      + TLV(8, #$0A#$07) // From ICQ7.6 beta
    //  +TLV(8, #$22#01)
      + TLV($C, dc)
    //  +TLV($11, #1#$2C#$35#$FB#$3B)
    //  +TLV($12, #0#0)
      + TLV($1F, #0#0)
      + xStsTLV;
  if StFirst then
   begin
    sendSNAC(ICQ_SERVICE_FAMILY, $1E, Pck);
    sleep(100);
   end;
//   else
    if
 {$IFDEF UseNotSSI}
      useSSI and
 {$ENDIF UseNotSSI}
      sendVis
    then
      sendVisibility;
  if not StFirst then
    begin
      sleep(100);
      sendSNAC(ICQ_SERVICE_FAMILY, $1E, Pck);
    end;

// ssi_
{pkt.createSNAC(1,$11,0);
pkt.addDword_BE(0);
pkt.send(sock);
addRef(REF_null,0);}

 if previousInvisible<>isInvisible then
  begin
    {$IFDEF UseNotSSI}
    if not useSSI and not isInvisible then
      sendAddInvisible(fIntInvisibleList);
    {$ENDIF UseNotSSI}

    eventContact:=NIL;
    notifyListeners(IE_visibilityChanged);
  end;
 previousInvisible:= isInvisible;
end; // sendStatusCode

procedure TicqSession.sendXStatusCodeOnly(); //011E
var
  xStsTLV : RawByteString;
begin
  if not isReady then Exit;

  xStsTLV := TLV($1D,
             word_BEasStr(BART_TYPE_XSTATUS) +
             AnsiChar(BART_FLAGS_DATA) +
//           Length_B(Length_BE(StrToUTF8(ExtStsStrings[curXStatus].Desc))+
             Length_B(Length_BE(StrToUTF8(curXStatusStr.Desc)) + Length_BE('')) + // 'iso-8859-1'
             word_BEasStr(BART_TYPE_STATUS_MOOD) +
             Length_BE(XStatusArray[curXStatus].pid6)
  );

  sendSNAC(ICQ_SERVICE_FAMILY, $1E, xStsTLV);
  addRef(REF_status, '');
end; // sendStatusCode

//procedure TicqSession.setStatusStr(s : String; Pic : String = '');
procedure TicqSession.setStatusStr(xSt: byte; stStr: TXStatStr);
var
  s: String;
begin
  eventContact := NIL;
  if not (xSt in [Low(XStatusArray)..High(XStatusArray)]) then
    Exit;

  curXStatus := xSt;
  eventInt := xSt;
  curXStatusStr.Cap := stStr.Cap;
  curXStatusStr.Desc := stStr.Desc;
  eventNameA := StrToUTF8(stStr.Cap);
  eventMsgA  := StrToUTF8(stStr.Desc);
//  eventMsg  := AnsiToUtf8(stStr.Desc);
  notifyListeners(IE_sendingXStatus);
//  title := eventName;
//  s := eventMsg;
  s := UTF8ToStr(eventNameA);

  if //(eventName > '') and
     (curXStatusStr.Cap <> s) then
    curXStatusStr.Cap := s;
  s := UTF8ToStr(eventMsgA);
  if //(eventMsg > '') and
     (curXStatusStr.Desc <> s) then
    curXStatusStr.Desc := s;

  if isReady then
   begin
//  if UseOldXSt then
    sendCapabilities;
//   else
    sendStatusCode(false);
//  sendSNAC(ICQ_SERVICE_FAMILY, $1E, TLV($1D, word_BEasStr($02) + #$04 + BUIN( Length_BE(StrToUTF8(s))+
//                                 Length_BE('') // 'iso-8859-1'
//                                    )+
//                              TLV($0E, Pic))
//          );
//  sendSNAC(ICQ_SERVICE_FAMILY, $1E, TLV($1D, TLV($0E, Pic))
//          );
   end;
end;

procedure TicqSession.setStatusFull(st: byte; xSt : byte; stStr : TXStatStr);
var
  s : String;
  ChangedSts, ChangedXStsID, ChangedXStsDesc : Boolean;
begin
  eventContact := NIL;
  if not (xSt in [0.. High(XStatusArray)]) then
    xSt := 0;
  ChangedXStsID := curXStatus <> xSt;
  ChangedXStsDesc := curXStatusStr.Desc <> stStr.Desc;
  if ChangedXStsID or ChangedXStsDesc then
    begin
      curXStatus := xSt;
      eventInt := xSt;
      curXStatusStr.Desc := stStr.Desc;
      eventNameA := StrToUTF8(stStr.Cap);
      eventMsgA  := StrToUTF8(stStr.Desc);
    //  eventMsg  := AnsiToUtf8(stStr.Desc);
      notifyListeners(IE_sendingXStatus);
    //  title := eventName;
    //  s := eventMsg;
      s := UTF8ToStr(eventNameA);
      if //(eventName > '') and
         (curXStatusStr.Cap <> s) then
        curXStatusStr.Cap := s;
      s := UTF8ToStr(eventMsgA);
      if //(eventMsg > '') and
         (curXStatusStr.Desc <> s) then
        curXStatusStr.Desc := s;
    end;


  if st = byte(SC_OFFLINE) then
   begin
    disconnect;
    exit;
   end;
//if (s = myinfo.status) and (inv = myinfo.invisible) then exit;
//  if (st = byte(myinfo.status)) then exit;
  ChangedSts := st <> byte(curStatus);
  if not (ChangedSts or ChangedXStsID or ChangedXStsDesc) then
    Exit;
  if ChangedSts then
   begin
    eventOldStatus    := curStatus;
    eventOldInvisible := IsInvisible;
    startingStatus    := TICQStatus(st);
   end;

  if isReady then
    begin
      curStatus := TICQStatus(st);
      if ChangedSts or ChangedXStsDesc then
        sendStatusCode(False);
    //  eventContact:=myinfo;
      eventContact:= NIL;
      notifyListeners(IE_statuschanged);
      if ChangedXStsID then
        sendCapabilities;
    end
   else
    connect;

end;


{$IFDEF UseNotSSI}
procedure TicqSession.sendAddVisible(const buinlist:RawByteString);
begin
  if not isReady or not isInvisible then exit;
  sendSNAC(ICQ_BOS_FAMILY, 5, buinlist);
end; // sendAddVisible

procedure TicqSession.sendRemoveVisible(const buinlist:RawByteString);
begin
  if not isReady or not isInvisible then exit;
  sendSNAC(ICQ_BOS_FAMILY, 6, buinlist);
end; // sendRemoveVisible

procedure TicqSession.sendAddInvisible(const buinlist:RawByteString);
begin
  if not isReady or isInvisible then exit;
  sendSNAC(ICQ_BOS_FAMILY, 7, buinlist);
end; // sendAddInvisible

procedure TicqSession.sendRemoveInvisible(const buinlist: RawByteString);
begin
  if not isReady or isInvisible then exit;
  sendSNAC(ICQ_BOS_FAMILY, 8, buinlist);
end; // sendRemoveInvisible

procedure TicqSession.sendRemoveContact(cl: TRnQCList);
begin
  if not useSSI then
    splitCL(sendRemoveContact,cl)
//   else
//    SplitCL2SSI_Items(SSI, cl, '', 0, 0, FEEDBAG_CLASS_ID);
end;
{$ENDIF UseNotSSI}

procedure TicqSession.sendAddVisible(cl: TRnQCList);
begin
{$IFDEF UseNotSSI}
  if not useSSI then
    splitCL(sendAddVisible,cl)
   else
{$ENDIF UseNotSSI}
    SplitCL2SSI_Items(SSI_CreateItems, cl, '', 0, 0, FEEDBAG_CLASS_ID_PERMIT);
end;

procedure TicqSession.sendAddInvisible(cl: TRnQCList);
begin
{$IFDEF UseNotSSI}
  if not useSSI then
    splitCL(sendAddInvisible,cl)
   else
{$ENDIF UseNotSSI}
    SplitCL2SSI_Items(SSI_CreateItems, cl, '', 0, 0, FEEDBAG_CLASS_ID_DENY);
end;

procedure TicqSession.sendRemoveVisible(cl: TRnQCList);
begin
{$IFDEF UseNotSSI}
  if not useSSI then
    splitCL(sendRemoveVisible,cl)
   else
{$ENDIF UseNotSSI}
    SplitCL2SSI_DelItems(SSI_DeleteItems, cl, FEEDBAG_CLASS_ID_PERMIT);
end;

procedure TicqSession.sendRemoveInvisible(cl: TRnQCList);
begin
{$IFDEF UseNotSSI}
  if not useSSI then
    splitCL(sendRemoveInvisible,cl)
   else
{$ENDIF UseNotSSI}
    SplitCL2SSI_DelItems(SSI_DeleteItems, cl, FEEDBAG_CLASS_ID_DENY);
end;


{$IFDEF UseNotSSI}
procedure TicqSession.sendAddContact(cl: TRnQCList; OnlyLocal: Boolean);
begin
 if not useSSI then
  splitCL(sendAddContact,cl)
 else
//  msgDlg(Str_unsupported, mtError);
  splitSSICL(sendAddContact,cl, OnlyLocal)
end;

procedure TicqSession.sendAddContact(const buinlist: RawByteString);
begin
  if (buinlist='') or not isReady then
    exit;
  sendSNAC(ICQ_BUDDY_FAMILY, 04, buinlist);
end; // sendAddContact

procedure TicqSession.sendRemoveContact(const buinlist: RawByteString);
begin
  if (buinlist='') or not isReady then
    exit;
  sendSNAC(ICQ_BUDDY_FAMILY, 5, buinlist);
end; // sendRemoveContact

{$ENDIF UseNotSSI}
procedure TicqSession.sendAddTempContact(const buinlist: RawByteString); // 030F
begin
  if (buinlist='') or not isReady then exit;
  sendSNAC(ICQ_BUDDY_FAMILY, $0F, buinlist);
 addRef(REF_null,'');
end; // sendAddTempContact
procedure TicqSession.sendAddTempContact(cl:TRnQCList);
begin
//  msgDlg(Str_unsupported, mtError);
  splitSSICL60(sendAddTempContact,cl, True)
end;
procedure TicqSession.sendRemoveTempContact(const buinlist: AnsiString); // 0310
begin
  if (buinlist='') or not isReady then exit;
  sendSNAC(ICQ_BUDDY_FAMILY, $10, buinlist);
end; // sendRemoveTempContact


{$IFDEF usesDC}

//function TicqSession.sendFileReq(uin:TUID; msg,fn:string; size:integer):integer;
function TicqSession.sendFileReq(const uin:TUID; const msg:string; fa : TFileAbout; useProxy : Boolean):integer;
var
  c:TICQcontact;
  proxyIP : Integer;
  proxyPort  : Integer;
  s : RawByteString;
begin
result:=-1;
if not isReady then exit;

c := getICQContact(uin);
if not imVisibleTo(c) then
 if addTempVisMsg then
  addTemporaryVisible(c);

{
sendSNAC(ICQ_MSG_FAMILY, CLI_META_MSG, qword_LEasStr(SNACref)+#0#2
  +BUIN(uin)
  +TLV(5, #0#0
    +qword_LEasStr(SNACref)+CAPS_sm2big(CAPS_sm_ICQSERVERRELAY)+TLV($A,#0#1)
    +TLV($F,'')+TLV(3, dword_BEasStr(getLocalIP))+TLV(5,word_BEasStr(serverPort))
    +TLV($2711, header2711+char(MTYPE_FILEREQ)+#0
      +word_LEasStr(word(status2code[myinfo.status]))+#1#0+WNTS(msg)
      +Z+WNTS(fn)+dword_LEasStr(size)+Z )
  )
  +TLV(3,'')
);
}
{  if sock.http.enabled then
    begin
      proxyIP := WSocketResolveHost(sock.http.addr).S_addr;
      s := TLV($10, '');
      port := 0;
    end
   else}
    begin
      eventDirect:=directTo(c);
      eventDirect.imserver := True;
      eventDirect.imsender := True;
      eventDirect.kind := DK_file;
      eventDirect.fileName := fa.fName;
      eventDirect.fileChkSum := fa.CheckSum;
      eventDirect.stage := 1;
      eventDirect.fileSizeTotal := fa.Size;
      eventDirect.eventID := SNACref;
//      eventDirect.fi
      if not useProxy then
        eventDirect.listen
       else
        begin
          eventDirect.stage := 1;
          eventDirect.connect2proxy;
          exit;
        end;
//      port := serverStart;
      proxyPort := //StrToInt(eventDirect.port);
        eventDirect.myPort;
      proxyIP := getLocalIP;
      s := '';
    end;

  sendSNAC(ICQ_MSG_FAMILY, CLI_META_MSG, qword_LEasStr(SNACref)+#0#2
   + Length_B(uin)
   +TLV(5, #0#0 // Request
    + qword_LEasStr(eventDirect.eventID)
    + CAPS_sm2big(CAPS_sm_FILE_TRANSFER)
    + TLV($0A, #0#1) // Request Number
    + TLV($0F, '') // Mystery Block
//    + TLV($0E, 'en')
    + TLV($0D, 'utf-8')
    + TLV($0C, str2html2(StrToUtf8('<ICQ_COOL_FT><FS>' + eventDirect.fileName +'</FS><S>'
                         + IntToStr(eventDirect.fileSizeTotal) + '</S>'
//                         + '<SID>1</SID><DESC></DESC></ICQ_COOL_FT>'
                         + '<SID>1</SID></ICQ_COOL_FT>'
                       )))
//    + TLV($0D, 'unicode-2-0')
//    + TLV($0C, StrToUnicode(str2html2('<ICQ_COOL_FT><FS>' + fn+'</FS><S>' + intToStr(size) + '</S>'
//                       + '<SID>1</SID><DESC></DESC></ICQ_COOL_FT>'
//                       + '<SID>1</SID></ICQ_COOL_FT>'
//                       )))
    + TLV($02, dword_LEasStr(proxyIP))     //proxy ip or my IP
    + TLV($16, dword_LEasStr(not proxyIP)) //proxy ip or my IP check
    + s                                    // has proxy flag
    + TLV($03, dword_LEasStr(getLocalIP))  // Proxy IP
    + TLV($05, word_BEasStr(proxyPort))
 //    + TLV($17, word_LEasStr(not proxyPort)) //word_BEasStr(serverPort)
    + TLV($17, word_LEasStr($FFFF)) //word_BEasStr(serverPort)
    + TLV($2711, word_BEasStr(1) // Multiple Files Flag. A value of 0x0001 indicates - only one file;  while a value of 0x0002 indicates that more than one file is being transferred
               + word_BEasStr(1) // File Count, the total number of files that will be transmitted during this file transfer
               + dword_BEasStr(eventDirect.fileSizeTotal)// Total Bytes, the sum of the size in bytes of all files to be transferred
               + StrToUTF8(eventDirect.fileName)+ #00)
    + TLV($2712, 'utf-8')));
  result:=addRef(REF_file,uin);
end; // sendFileReq

function TicqSession.sendFileReqPro(drct : TICQDirect):integer;
var
  c:TRnQContact;
  proxyIP, myIP : Integer;
  ProxyPort  : Integer;
  s : RawByteString;
begin
  result:=-1;
  if not isReady then exit;

  c:= drct.contact;
  if not imVisibleTo(c) then
   if addTempVisMsg then
    addTemporaryVisible(TICQcontact(c));

  eventDirect := drct;
  if eventDirect.eventID <= 0 then
    eventDirect.eventID := SNACref;
  Result := eventDirect.eventID;

  if drct.mode = dm_bin_proxy then
     if drct.AOLProxy.port > 0 then
      begin
        s := TLV($10, '');
        proxyIP := drct.AOLProxy.ip;
        proxyPort := drct.AOLProxy.port;
        myIP := 0;
      end
     else
        begin
          eventDirect.stage := 1;
          eventDirect.connect2proxy;
          exit;
        end
   else
    begin
      s := '';
      if drct.stage = 1 then
        drct.listen;
      proxyIP := getLocalIP;
      proxyPort := drct.myPort;
      myIP := proxyIP;//getLocalIP;
    end;
  if drct.fileDesc = '' then
   drct.fileDesc := '<ICQ_COOL_FT><FS>' + drct.fileName +'</FS><S>' + intToStr(drct.fileSizeTotal) + '</S>'
//                       + '<SID>1</SID><DESC></DESC></ICQ_COOL_FT>'
                       + '<SID>1</SID></ICQ_COOL_FT>';
  sendSNAC(ICQ_MSG_FAMILY, CLI_META_MSG, qword_LEasStr(drct.eventID)+#0#2
   + c.buin
   +TLV(5, #0#0 // Request
    + qword_LEasStr(drct.eventID)
    + CAPS_sm2big(CAPS_sm_FILE_TRANSFER)
    + TLV($0A, word_BEasStr(eventDirect.stage)) // Request Number
    + TLV($0F, '')   // Mystery Block
//    + TLV($0E, 'en')
    + TLV($0D, 'utf-8')
    + TLV($0C, str2html2(StrToUTF8(drct.fileDesc)))
//    + TLV($0D, 'unicode-2-0')
//    + TLV($0C, StrToUnicode(str2html2('<ICQ_COOL_FT><FS>' + fn+'</FS><S>' + intToStr(size) + '</S>'
//                       + '<SID>1</SID><DESC></DESC></ICQ_COOL_FT>'
//                       + '<SID>1</SID></ICQ_COOL_FT>'
//                       )))
    + TLV($02, dword_LEasStr(proxyIP))     //proxy ip or my IP
    + TLV($16, dword_LEasStr(not proxyIP)) //proxy ip or my IP check
//    + TLV($03, dword_LEasStr(getLocalIP))  // Client IP Address
    + TLV($03, dword_LEasStr(myIP))  // Client IP Address
    + TLV($05, word_BEasStr(proxyPort))
//    + TLV($17, word_LEasStr(not proxyPort)) //word_BEasStr(serverPort)
    + TLV($17, word_BEasStr(not proxyPort)) // in ICQ6 it seems BE
//    + TLV($17, word_LEasStr($FFFF)) //word_BEasStr(serverPort)
    + s                                    // has proxy flag
    + TLV($2711, word_BEasStr(1) // Multiple Files Flag. A value of 0x0001 indicates - only one file;  while a value of 0x0002 indicates that more than one file is being transferred
               + word_BEasStr(1) // File Count, the total number of files that will be transmitted during this file transfer
               + dword_BEasStr(drct.fileSizeTotal)// Total Bytes, the sum of the size in bytes of all files to be transferred
               + StrToUtf8(drct.fileName)+ AnsiChar(#00))
    + TLV($2712, 'utf-8')));
  result:=addRef(REF_file,c.UID);
end; // sendFileReq

function TicqSession.sendFileReq2(drct : TICQDirect):integer;
var
//  c:Tcontact;
  proxyIP : Integer;
  port  : Integer;
  s : RawByteString;
begin
  result:=-1;
  if not isReady then exit;

//  c:=contactsDB.get(uin);
  if not imVisibleTo(drct.contact) then
   if addTempVisMsg then
     addTemporaryVisible(TICQcontact(drct.contact));

  if sock.http.enabled then
    begin
      proxyIP := WSocketResolveHost(sock.http.addr).S_addr;
      s := TLV($10, '');
      port := 0;
    end
   else
    begin
//      eventDirect:=directTo(c);
      drct.imserver := True;
//      eventDirect.kind := DK_file;
      drct.listen;
//      eventDirect.fileTotal := size;
//      port := serverStart;
      port := //StrToInt(eventDirect.port);
        drct.myPort;
      proxyIP := getLocalIP;
      s := '';
    end;

  sendSNAC(ICQ_MSG_FAMILY, CLI_META_MSG, qword_LEasStr(SNACref)+#0#2
   + (drct.contact.buin)
   +TLV(5, #0#0 // Request
    + qword_LEasStr(SNACref)+CAPS_sm2big(CAPS_sm_FILE_TRANSFER)
    + TLV($0A, #00#02) // Request Number
    + TLV($02, dword_LEasStr(proxyIP))     //proxy ip or my IP
    + TLV($16, dword_LEasStr(not proxyIP)) //proxy ip or my IP check
    + s                                    // has proxy flag
    + TLV($03, dword_LEasStr(getLocalIP))  // Proxy IP
    + TLV($05, word_BEasStr(port))
 //    + TLV($17, word_LEasStr(not port)) //word_BEasStr(serverPort)
    + TLV($17, word_BEasStr($FFFF)) //word_BEasStr(serverPort)
     )
   );
  result:=addRef(REF_file, drct.contact.UID);
end; // sendFileReq

procedure TicqSession.sendFileOk(Drct : TICQDirect; SendMsg : Boolean = False;
                  isListen : Boolean = false; useProxy : Boolean = false);
begin
//if not isReady then exit;

//if not imVisibleTo(c) then
// if addTempVisMsg then
//   addTemporaryVisible(c);
  if not SendMsg then
   begin
//      eventDirect:=directTo(c);
      eventDirect := Drct;
//      eventDirect.kind := DK_file;
//      eventDirect.eventID := msgID;
//      eventDirect.fileName := eventFilename;
//      eventDirect.fileTotal := eventFileSize;

      if isListen then
        begin
//          eventDirect.port := 20000;
          eventDirect.listen;
        end
       else
        eventDirect.connect;
   end;
 if SendMsg then
 begin
   if useProxy then
      sendSNAC(ICQ_MSG_FAMILY, CLI_META_MSG, qword_LEasStr(Drct.eventID)+#0#2
       + Drct.contact.buin// BUIN(drсt.contact.UID)
//       + TLV(5, #0#0 // Request
       + TLV(5, #0#2 // Accept
         + qword_LEasStr(Drct.eventID)+CAPS_sm2big(CAPS_sm_FILE_TRANSFER)
         + TLV($0A, #00#02) // Request Number
         + TLV($02, dword_LEasStr(Drct.AOLProxy.ip))     //proxy ip or my IP
         + TLV($16, dword_LEasStr(not Drct.AOLProxy.ip)) //proxy ip or my IP check
//         + TLV($03, dword_LEasStr(getLocalIP))  // Proxy IP
         + TLV($05, word_LEasStr(Drct.AOLProxy.port))
         + TLV($17, word_LEasStr(not Drct.AOLProxy.port)) //word_BEasStr(serverPort)
//        + TLV($17, word_LEasStr($FFFF)) //word_BEasStr(serverPort)
         + TLV($10, '')                    // has proxy flag
         )
       )
//     sendSNAC(ICQ_MSG_FAMILY, CLI_META_MSG, qword_LEasStr(msgID)+#0#2
//         +BUIN(c.uid)
//         +TLV(5, #0#2+qword_LEasStr(msgID)+CAPS_sm2big(CAPS_sm_FILE_TRANSFER)//+TLV($A,#0#2)
//             )
//          );

    else
// Send File OK
     sendSNAC(ICQ_MSG_FAMILY, CLI_META_MSG, qword_LEasStr(Drct.eventID)+#0#2
         +Drct.contact.buin //  BUIN(c.uid)
         + TLV(5, #0#2 // Accept
                 +qword_LEasStr(Drct.eventID)
                 +CAPS_sm2big(CAPS_sm_FILE_TRANSFER)//+TLV($A,#0#2)
             )
          );
 end;
end; // sendFileOK

procedure TicqSession.ProcessReceiveFile(dirct : TICQDirect);
begin
//  if not isReady then exit;

  if not imVisibleTo(dirct.contact) then
   if addTempVisMsg then
     addTemporaryVisible(TICQcontact(dirct.contact));
  eventDirect := dirct;
  if (dirct.mode = dm_bin_direct) then
    begin
     if ((dirct.imSender)and (dirct.stage = 1))or
        ((not dirct.imSender)and (dirct.stage = 2)) then
       dirct.listen
      else
       dirct.connect
    end
   else
    if dirct.stage = 1 then
      dirct.connect2proxy
     else 
      sendSNAC(ICQ_MSG_FAMILY, CLI_META_MSG, qword_LEasStr(dirct.eventID)+#0#2
       + dirct.contact.buin// BUIN(drct.contact.UID)
       + TLV(5, #0#0 // Request
//       + TLV(5, #0#2 // Accept
         + qword_LEasStr(dirct.eventID)+CAPS_sm2big(CAPS_sm_FILE_TRANSFER)
         + TLV($0A, #00#02) // Request Number
         + TLV($02, dword_LEasStr(0))     //proxy ip or my IP
         + TLV($16, dword_LEasStr($FFFFFFFF)) //proxy ip or my IP check
         + TLV($03, dword_LEasStr(0))  // Client IP
//         + TLV($05, word_BEasStr(Drct.AOLProxy.port))
//         + TLV($17, word_LEasStr(not Drct.AOLProxy.port)) //word_BEasStr(serverPort)
//        + TLV($17, word_LEasStr($FFFF)) //word_BEasStr(serverPort)
//         + TLV($10, '')                    // has proxy flag
         )
       )
end; // sendFileOK
{$ENDIF usesDC}

procedure TicqSession.sendFileAbort(cnt : TICQcontact; msgID:TmsgID);
//var
//  c:Tcontact;
begin
if not isReady then exit;

//c:=contactsDB.get(refs[msgID].uid);
if not imVisibleTo(cnt) then
  if addTempVisMsg then
  addTemporaryVisible(cnt);

sendSNAC(ICQ_MSG_FAMILY, CLI_META_MSG, qword_LEasStr(msgID)+#0#2
  + cnt.buin
  +TLV(5, #0#0+qword_LEasStr(msgID)+CAPS_sm2big(CAPS_sm_FILE)+TLV($B,#0#1) )
);
end; // sendFileAbort

procedure TicqSession.sendFileAck(msgID:TmsgID);
var
  c:TICQcontact;
begin
if not isReady then exit;
c:= getICQContact(refs[msgID].uid);
if not imVisibleTo(c) then
 if addTempVisMsg then
  addTemporaryVisible(c);

sendSNAC(ICQ_MSG_FAMILY, CLI_META_MSG, qword_LEasStr(msgID)+#0#2
  + Length_B(refs[msgID].uid)
  +TLV(5, #0#2+qword_LEasStr(msgID) + CAPS_sm2big(CAPS_sm_ICQSERVERRELAY ))
);
end; // sendFileAck

procedure TicqSession.sendAuthReq(const uin:TUID; const msg:string);
var
  c:TICQcontact;
  iam : TRnQContact;
begin
c:=getICQContact(uin);
if not imVisibleTo(c) then
 if addTempVisMsg then
   addTemporaryVisible(c);
  iam := getMyInfo;
sendSNAC(ICQ_MSG_FAMILY, CLI_META_MSG, qword_LEasStr(SNACref)+#0#4
  + Length_B(uin)
  +TLV(5, myUINle+ AnsiChar(MTYPE_AUTHREQ)+ AnsiChar(#0)
//    +WNTS(getMyInfo.nick+#$FE+getMyInfo.first+#$FE+getMyInfo.last+#$FE+ MyInfo0.email+#$FE#0#$FE+msg)
    +WNTS(StrToUTF8(iam.nick)+AnsiChar(#$FE)+
          StrToUTF8(iam.first)+AnsiChar(#$FE)+
          StrToUTF8(iam.last)+AnsiChar(#$FE)+
          ''+AnsiString(#$FE#0#$FE)+
          StrToUTF8(msg))
  )
);
end; // sendAuthReq

procedure TicqSession.sendMSGsnac(const uin : TUID; const sn : RawByteString);
begin
  sendSNAC(ICQ_MSG_FAMILY, CLI_META_MSG, qword_LEasStr(SNACref)+#0#2
    + Length_B(uin)
    +TLV(5, #0#0+qword_LEasStr(SNACref)+ CAPS_sm2big(CAPS_sm_ICQSERVERRELAY)
      +TLV($A,#0#1)
      +TLV($F,'')
      +TLV($2711, header2711 + sn )
      )
{	/*
	 * Set the Buddy Icon Requested flag.
	 * XXX - Every time?  Surely not...
	 */
	if (args->flags & AIM_IMFLAGS_BUDDYREQ) {
		byte_stream_put16(&data, 0x0009);
		byte_stream_put16(&data, 0x0000);
	}
//    +TLV(3,'')
  );
end;

procedure TicqSession.sendCryptMSGsnac(const uin : TUID; const sn : RawByteString);
begin
  sendSNAC(ICQ_MSG_FAMILY, CLI_META_MSG, qword_LEasStr(SNACref)+#0#2
    + Length_B(uin)
    +TLV(5, #0#0+qword_LEasStr(SNACref)+ BigCapability[CAPS_big_CryptMsg].v
      +TLV($A,#0#1)
      +TLV($F,'')
      +TLV($2711, header2711 + sn )
      )
//    +TLV(3,'')
    +TLV(6, '')  // <--  if (args->flags & AIM_IMFLAGS_OFFLINE)
  );
end;

function TicqSession.sendMsg(cnt: TRnQContact; var flags:dword; const msg:string; var requiredACK:boolean):integer;
// $0406
var
  c:TICQcontact;
  status : AnsiString;
  sutf   : RawByteString;

//  buf, destBuf : TStringStream;
  buf, destBuf : TMemoryStream;
//  s : String;
  Msg2 : String;
  sA, Msg2Send : RawByteString;
//  key : TAESKey256;
//  key : AnsiString;
  key : array [0..31] of byte;
  ctx : TAESContext;
  CrptMsg : RawByteString;
  I, len, len2: Integer;
  crc : Cardinal;
  CompressType : Word;
  flagChar,priorityChar: AnsiChar;
  isUnicode : Boolean;
  lShouldEncr : Boolean;
//    key : String;
//    sendKey : String;
    MD5Digest  : TMD5Digest;
    MD5Context : TMD5Context;
  isBin : boolean;
begin
  result:=-1;
  if not isReady then exit;

//  c:= getICQContact(uin);
  c:= TICQcontact(cnt);
  isBin := (AnsiPos(RnQImageTag, msg) > 0) or ((AnsiPos(RnQImageExTag, msg) > 0))
      or (IF_Bin and flags>0)
      ;
  if isBin then
    flags := flags or IF_Bin;

  if not UseAdvMsg then
    flags := flags or IF_Simple;

  if not imVisibleTo(c) then
   if addTempVisMsg then
    addTemporaryVisible(c);

  if imVisibleTo(c) then
    status := word_LEasStr(getFullStatusCode)
   else
    status := #00#00;

  flagChar:=#0;
  if IF_multiple and flags>0 then
    flagChar:=#$80;
  priorityChar:=#1;
  if IF_urgent and flags>0 then
    priorityChar:=#2;
  if IF_noblink and flags>0 then
    priorityChar:=#4;

  if c.SendTransl and not isBin then
    Msg2 := Translit(msg)
   else
    Msg2 := msg;

  sutf := '';
  lShouldEncr := UseCryptMsg and c.Crypt.supportCryptMsg and not isBin;
  if ( useMsgType2For(c)
      or lShouldEncr)
     and not (IF_Simple and flags > 0) then
  begin
   requiredACK:=TRUE;
   if SendingUTF and ((CAPS_sm_UTF8 in c.capabilitiesSm)or c.isAIM or (c.status = SC_OFFLINE))
       and not isBin then
     begin
//       sutf := Length_DLE(GUIDToString(msgUtf));
       sutf := Length_DLE(msgUTFstr);
       Msg2Send := StrToUTF8(Msg2);
     end
    else
     begin
//       sutf := '';
       Msg2Send := AnsiString(msg2);
     end;
   if lShouldEncr then
     begin
       len := Length(Msg2Send);
       crc := (ZipCrc32($FFFFFFFF, @Msg2Send[1], Len)XOR $FFFFFFFF);
       CompressType := 0;
       buf := TMemoryStream.create;
       destBuf := TMemoryStream.create;
       buf.Write(Msg2Send[1], Len);
       buf.Position := 0;
       ZlibCompressStreamEx(buf, destBuf, clMax, zsZLib, false);
       buf.free;
//       Msg2Send :=  ZCompressStrEx(msg, clMax);
//       if Length(Msg2Send) < Len then
       i := destBuf.Size;
       if i+4 < Len then
        begin
          setLength(Msg2Send, i+4);
          move(i, Msg2Send[1], 4);
          destBuf.Position := 0;
          destBuf.Read(Msg2Send[5], i);
//          CopyMemory(@Msg2Send[5], destBuf.Memory, i);
          CompressType := 1;
//          msg := Msg2Send;
        end;
       destBuf.free;

       sA := IntToHexA(SNACref, 2);
       FillChar(MD5Digest, sizeOf(TMD5Digest), 0);
       MD5Init(MD5Context);
       MD5UpdateBuffer(MD5Context, PByte(sa), length(sa));
       MD5UpdateBuffer(MD5Context, PByte(not2Translate[2]), length(not2Translate[2]));
       sA := MyAccount;
       MD5UpdateBuffer(MD5Context, PByte(sa), length(sa));
       MD5UpdateBuffer(MD5Context, PAnsiChar(AIM_MD5_STRING), length(AIM_MD5_STRING));
       MD5Final(MD5Digest, MD5Context);
       for I := 0 to 15 do
        Key[i] := Byte(MD5Digest[I]);

       sa := IntToHexA(len, 2);
       FillChar(MD5Digest, sizeOf(TMD5Digest), 0);
       MD5Init(MD5Context);
       MD5UpdateBuffer(MD5Context, PByte(sa), length(sa));
       MD5UpdateBuffer(MD5Context, PByte(not2Translate[2]), length(not2Translate[2]));
       sa := c.UID2cmp;
       MD5UpdateBuffer(MD5Context, PByte(sa), length(sa));
       MD5UpdateBuffer(MD5Context, PAnsiChar(AIM_MD5_STRING), length(AIM_MD5_STRING));
       MD5Final(MD5Digest, MD5Context);
       for I := 0 to 15 do
        Key[i+16] := Byte(MD5Digest[I]);
{
       sA := MD5Pass(RawByteString(IntToHexA(SNACref, 2)) + not2Translate[2] + RawByteString(MyAccount) + AIM_MD5_STRING);
       for I := 1 to 16 do
        Key[i-1] := Byte(sA[I]);

       sA := MD5Pass(RawByteString(IntToHexA(len, 2)) + not2Translate[2] + RawByteString(c.UID2cmp) + AIM_MD5_STRING);
       for I := 1 to 16 do
        Key[i+15] := Byte(sA[I]);
}

{
        buf := TStringStream.Create(msg);
        destBuf := TStringStream.Create('');
        EncryptAESStreamECB(buf, 0, key, destBuf);
        msg := destBuf.DataString;
        msg := Base64EncodeString(msg);
}
       AES_ECB_Init_Encr(key, 256, ctx);
//       len2 := length(msg);
       i := len mod AESBLKSIZE;
       if (i>0) then
         begin
           len2 := len + AESBLKSIZE - i;
           SetLength(Msg2Send, len2);
           FillChar(Msg2Send[len+1], AESBLKSIZE - i, 0);
         end
        else
          len2 := len;
       SetLength(CrptMsg, len2);
       AES_ECB_Encrypt(@Msg2Send[1], @CrptMsg[1], len2, ctx);
       Msg2Send := Base64EncodeString(CrptMsg);
       sendCryptMSGsnac(c.UID, AnsiChar(MTYPE_PLAIN)+flagChar
          + status
          + priorityChar+#0
          + WNTS(Msg2Send)
          + dword_LEasStr(len)
          + dword_LEasStr(crc)
          + word_LEasStr(CompressType) // Ìåòîä àðõèâàöèè
          + dword_LEasStr(0)+dword_LEasStr($FFFFFF)
//          + sutf
  //      )
  //    )
  //    +TLV(3,'')
       );
       flags := flags or IF_Encrypt;
     end
    else
    if UseCryptMsg and (CAPS_big_QIP_Secure in c.capabilitiesBig)
         and (c.Crypt.qippwd > 0) and not isBin then
      begin  // QIP crypt message
       Msg2Send := qip_msg_crypt(msg2, c.Crypt.qippwd);
//       sutf := Length_DLE(GUIDToString(msgQIPpass));
       sutf := Length_DLE(msgQIPpassStr);
       sendMSGsnac(c.UID, AnsiChar(MTYPE_PLAIN)+flagChar
          +status
          +priorityChar+#0
          +WNTS(Msg2Send)
          +dword_LEasStr(0)+dword_LEasStr($FFFFFF)
          +sutf
  //      )
  //    )
  //    +TLV(3,'')
       );
       flags := flags or IF_Encrypt;
      end
    else
{  sendSNAC(ICQ_MSG_FAMILY, CLI_META_MSG, qword_LEasStr(SNACref)+#0#2
    +BUIN(uin)
    +TLV(5, #0#0+qword_LEasStr(SNACref)+ CAPS_sm2big(CAPS_sm_ICQSERVERRELAY)
      +TLV($A,#0#1)
      +TLV($F,'')
      +TLV($2711,
        header2711+}
     sendMSGsnac(c.UID, AnsiChar(MTYPE_PLAIN)+flagChar
        +status
        +priorityChar+#0
        +WNTS(Msg2Send)
        +dword_LEasStr(0)+dword_LEasStr($FFFFFF)
        +sutf
//      )
//    )
//    +TLV(3,'')
  );
  end
 else
  begin // Simple MSG
//  requiredACK:=FALSE;
  requiredACK:=True;
   if SendingUTF
//     or (c.status = SC_OFFLINE)
//      and ((CAPS_sm_UTF8 in c.capabilitiesSm)or c.isAIM) and (c.isOnline)
      and not isBin
     then
//     if SendingUTF then
      begin
       sutf := #$00#$02; // UNICODE - ISO 10646.USC-2 Unicode
       isUnicode := True;
//      msg := StrToUTF8(msg);
//       if (c.status = SC_OFFLINE) and (IsSupportHTML) then
//        msg := '<HTML><BODY dir="ltr"><FONT face="Arial" color="#000000" size="2">'+
//               msg + '</FONT></BODY></HTML>';
//       msg := StrToUnicode(msg);
       Msg2Send := StrToUnicode(msg2);
      end
    else
      begin
//       sutf := z;
//       sutf := #$00#$03; // LATIN_1 - ISO 8859-1
       sutf := #$00#$00; // ASCII - ANSI ASCII -- ISO 646
       isUnicode := False;
       Msg2Send := RawByteString(msg2);
      end;
   flags := IF_Simple or flags;   
    sendSNAC(ICQ_MSG_FAMILY, CLI_META_MSG, qword_LEasStr(SNACref)+#0#1
      +c.buin
      +TLV(2,
         TLV($0501, AnsiChar(#1)+ RawByteString(IfThen(isUnicode, AnsiChar(#6))))  // Need for ICQ 2003b!!!!
//         TLV($0501, #01)
//         TLV($0501, #01#06)
        +TLV($0101, sutf+#$00#$00+Msg2Send) )   // msg-data-1
//      +TLV(5, myUINle+char(MSG_MSG)+flagChar+WNTS(msg) )   // msg-data-4
      +TLV(6, '')  // <--	if (args->flags & AIM_IMFLAGS_OFFLINE)
  );
  end;
result:=addRef(REF_msg,c.UID2Cmp);
//  if requiredACK then
//    acks.add(OE_msg, uin, 0, 'MSG').ID := result;

end; // sendMsg

function TicqSession.sendBuzz(cnt: TRnQContact): Boolean;
var
  c: TICQContact;
begin
  Result := False;
  if not isReady or (SecondsBetween(Now, buzzedLastTime) < 15) then Exit;

  buzzedLastTime := Now;
  c := TICQcontact(cnt);
  sendSNAC(ICQ_MSG_FAMILY, CLI_META_MSG, qword_LEasStr(SNACref) + #00#02 + Length_B(c.UID)
    + TLV($05, #00#00 + qword_LEasStr(SNACref) + BigCapability[CAPS_big_Buzz].v
      + TLV($0A, #00#01)
      + TLV($0F, '')
      + TLV($0E, 'en')
      + TLV($0D, 'us-ascii'))
    + TLV($03, #00#00));
  addRef(REF_msg, c.UID2Cmp);

  Result := True;
end;

function TicqSession.sendAutoMsgReq(const uin:TUID):integer;
var
  c: TICQContact;
  msgtype:byte;
  s:TICQstatus;
begin
result:=-1;
c:= getICQContact(uin);
if c.status <> SC_ONLINE then s:=c.status
else s:=c.prevStatus;
case s of
  SC_OCCUPIED: msgtype:=MTYPE_AUTOBUSY;
  SC_NA: msgtype:=MTYPE_AUTONA;
  SC_DND: msgtype:=MTYPE_AUTODND;
  SC_F4C: msgtype:=MTYPE_AUTOFFC;
  else msgtype:=MTYPE_AUTOAWAY;
  end;
if not isReady then exit;

  sendMSGsnac(uin, AnsiChar(msgtype)+ AnsiChar(#3)+Z+WNTS('') );
result:=addRef(REF_msg,uin);
end; // sendAutoMsgReq

procedure TicqSession.sendAddedYou(const uin:TUID);
var
  c:TICQcontact;
begin
if not isReady then exit;

c:= getICQContact(uin);
if not imVisibleTo(c) then
  if addTempVisMsg then
    addTemporaryVisible(c);

sendSNAC(ICQ_MSG_FAMILY, CLI_META_MSG, qword_LEasStr(SNACref)+#0#4
  + Length_B(uin)
  +TLV(5, myUINle+ AnsiChar(MTYPE_ADDED)+#$00+WNTS('') )
  +TLV(6,'')
);
end; // sendAddedYou

procedure TicqSession.sendContacts(cnt : TRnQContact;flags:dword; cl:TRnQCList);
var
  s: RawByteString;
//  c:Tcontact;
begin
  if not isReady then exit;
  if cl.empty then exit;

  //c:=getICQContact(uin));
  if not imVisibleTo(cnt) then
    if addTempVisMsg then
     addTemporaryVisible(TICQContact(cnt));

  s := IntToStrA(TList(cl).count)+#$FE;
  cl.resetEnumeration;
  while cl.hasMore do
   with cl.getNext do
    s:=s + uid +#$FE + StrToUTF8(nick) + #$FE;

sendSNAC(ICQ_MSG_FAMILY, CLI_META_MSG, qword_LEasStr(SNACref)+#0#4
  + cnt.buin 
  +TLV(5, myUINle+ AnsiChar(MTYPE_CONTACTS)+ AnsiChar(#00)+WNTS(s))
  +TLV(6,'')
);
addRef(REF_contacts,cnt.uid);
end; // sendContacts

procedure TicqSession.sendAuth(const uin:TUID);
var
  c:TICQcontact;
begin
if not isReady then exit;
c:=getICQContact(uin);
if not imVisibleTo(c) then
  if addTempVisMsg then
   addTemporaryVisible(c);
sendSNAC(ICQ_MSG_FAMILY, CLI_META_MSG, qword_LEasStr(SNACref)+#0#4
  + Length_B(uin)
  +TLV(5, myUINle+ AnsiChar(MTYPE_AUTHOK)+#0+WNTS(''))
  +TLV(6, '')
);
addRef(REF_auth,uin);
end; // sendAuth

procedure TicqSession.sendAuthDenied(const uin:TUID; const msg:string);
begin
if not isReady then exit;
sendSNAC(ICQ_MSG_FAMILY, CLI_META_MSG, qword_LEasStr(SNACref)+#0#4
  + Length_B(uin)
  +TLV(5, myUINle+ AnsiChar(MTYPE_AUTHDENY)+#0+WNTS(StrToUTF8(msg)))
  +TLV(6, '')
);
end; // sendAuth

procedure TicqSession.sendNewQueryInfo(const uin: TUID);
var
  a : Integer;
begin
  if not isReady then Exit;
  // new UIN info request 2502 with 2503 presponse (unparsed for now)
  a := StrToIntDef(uin, 0);
  if a > 0 then
  sendSNAC($25, $02, Length_BE('ru-RU') +
                     word_Zero +
                     dword_BEasStr($01) +
                     dword_BEasStr($02) +
                     dword_BEasStr($01) + // number of included account blocks
                     dword_BEasStr($000100D1) + // data block label
                     Length_BE(word_BEasStr($01) + // block number
                               Length_BE(uin)) + // target UIN
                     dword_Zero + dword_Zero +
                     dword_BEasStr($14) +
                     dword_BEasStr($00010004) +
                     dword_BEasStr($01));
  addRef(REF_query, '');
end;

procedure TicqSession.sendSimpleQueryInfo(const uin:TUID);
var
  a : Integer;
begin
  if not isReady then exit;
  a := StrToIntDef(uin, 0);
  if a > 0 then
   sendSNAC(ICQ_EXTENSIONS_FAMILY, CLI_META_REQ, TLV(1, Length_LE( myUINle
     + word_LEasStr(CLI_META_INFO_REQ)
     + word_Zero
     + word_LEasStr(META_REQUEST_PROFILE_INFO)
     + dword_LEasStr(a)
    )));
  addRef(REF_simplequery, uin);
end; // sendSimpleQueryInfo

procedure TicqSession.sendFullQueryInfo(const uin: TUID);
var
  a : Integer;
begin
  if not isReady then
    Exit;
  a := StrToIntDef(uin, 0);
  if a > 0 then
  sendSNAC(ICQ_EXTENSIONS_FAMILY, CLI_META_REQ, TLV(1, Length_LE(myUINle
    + word_LEasStr(CLI_META_INFO_REQ)
    + word_Zero
    + word_LEasStr(META_REQUEST_FULL_INFO)
    + dword_LEasStr(a)))
  );
  addRef(REF_query, uin);
end; // sendMultiQueryInfo

procedure TicqSession.sendQueryInfo(uin: Integer);
//const
//  TAB:array [boolean] of AnsiChar=(#$B2,#$D0);
var
  wpS : TwpSearch;
  cnt : TICQcontact;
begin
  if not isReady then exit;
  if uin = 0 then Exit;
{
  sendSNAC(ICQ_EXTENSIONS_FAMILY, 2, TLV(1, Length_LE( myUINle
                      +#$D0#7#0#0+TAB[getMyInfo.equals(uin)]+#04
//                      +dword_LEasStr(StrToIntDef(uin, 0))
                      +dword_LEasStr(uin)
           )));
addRef(REF_query, intToStr(uin));
}
  cnt := getICQContact(uin);
  if not Assigned(cnt) then
    Exit;
  wpS.uin := Int2UID(uin);
  wpS.token := cnt.InfoToken;
  sendWPsearch2(wpS, 0, False);
end; // sendQueryInfo

{procedure TicqSession.sendQueryInfo(uin:TUID);
var
  wp : TwpSearch;
begin
  wp.uin := uin;
  sendWPsearch(wp, 0);
end; // sendQueryInfo}

procedure TicqSession.sendWPsearch(wp: TwpSearch; idx : Integer);
  function TLVIfNotNull(t : word; s : RawByteString) : RawByteString;
  begin
    if s > '' then
     result := TLV_LE(t, WNTS(s));
  end;
  function TLVIfbNotNull(t : word; b : byte) : RawByteString;
  begin
    if b > 0 then
     result := TLV_LE(t, AnsiChar(b));
  end;
  function TLVIfWNotNull(t : word; w : word) : RawByteString;
  begin
    if w > 0 then
     result := TLV_LE(t, word_LEasStr(w));
  end;
  function TLVIfDWNotNull(t : word; d : dword) : RawByteString;
  begin
    if d > 0 then
     result := TLV_LE(t, dword_BEasStr(d));
  end;
  function TLVIfINotNull(t : word; w : word; s : RawByteString) : RawByteString;
  begin
    if (w > 0) or (s > '') then
     result := TLV_LE(t, word_LEasStr(w) + WNTS(s));
  end;
const
  TAB:array [boolean] of AnsiChar=(#$B2,#$D0);
var
  s : RawByteString;
begin
  if not isReady then exit;
  wasUINwp:=wp.uin > '';
  if wasUINwp then
   begin
//    s := TAB[myinfo.uin=wp.uin]+#4+dword_LEasStr(wp.uin);
     s := #$1F#5 + dword_LEasStr(StrToIntDef(wp.uin, 0));
  end
  else
{  if wp.email > '' then
   begin
     s := word_LEasStr(META_SEARCH_EMAIL)
        + TLV_LE(User_email, WNTS(wp.email));
   end
  else}
   begin
     s := word_LEasStr(META_SEARCH_GENERIC)
        + TLVIfNotNull(User_First, wp.first)
        + TLVIfNotNull(User_Last, wp.last)
        + TLVIfNotNull(User_Nick, wp.nick)
        + TLVIfNotNull(User_email, wp.email)
        + TLVIfNotNull(User_City, wp.city)
        + TLVIfNotNull(User_State, wp.state)
        + TLVIfINotNull(User_Inter, wp.wInterest, wp.keyword)
        + TLVIfWNotNull(User_Lang, wp.lang)
        + TLVIfbNotNull(User_Gender, wp.gender)
        + TLVIfDWNotNull(User_Age, wp.age)
        + TLVIfbNotNull(User_OnOf, Byte(wp.onlineOnly))
        + TLVIfWNotNull(User_Cntry, wp.country)
//        + TLVIfNotNull(User_, wp.)
//        + TLVIfNotNull(User_, wp.)
   end;

  sendSNAC(ICQ_EXTENSIONS_FAMILY, CLI_META_REQ, TLV(1, Length_LE( myUINle
    + word_LEasStr(CLI_META_INFO_REQ)
    + word_LEasStr(idx)
    + s)));
  if wasUINwp then
    addRef(REF_wp,wp.uin)
  else
    addRef(REF_wp, '');
end; // sendWPsearch

procedure TicqSession.sendWPsearch2(wp:TwpSearch; idx : Integer; IsWP : Boolean = True);
  function TLVIfNotNull(t: word; const s: RawByteString) : RawByteString; inline;
  begin
    if s > '' then
     result := TLV(t, WNTS(s));
  end;
  function TLVIfbNotNull(t: word; b: byte) : RawByteString; inline;
  begin
    if b > 0 then
     result := TLV(t, AnsiChar(b));
  end;
  function TLVIfWNotNull(t: word; w: word): RawByteString; inline;
  begin
    if w > 0 then
     result := TLV(t, word_BEasStr(w));
  end;
  function TLVIfDWNotNull(t: word; d: dword): RawByteString; inline;
  begin
    if d > 0 then
     result := TLV(t, dword_BEasStr(d));
  end;
  function TLVIfDWLENotNull(t: word; d: dword): RawByteString; inline;
  begin
    if d > 0 then
     result := TLV(t, dword_LEasStr(d));
  end;
  function TLVIfINotNull(t: word; w: word; const s: RawByteString): RawByteString; inline;
  begin
    if (w > 0) or (s > '') then
     result := TLV(t, word_LEasStr(w) + WNTS(s));
  end;
{
  function TLVIfSNotNull(t : word; s : RawByteString) : RawByteString;
  begin
    if (s > '') then
     result := TLV(t, Length_LE(s));
  end;}
//const
//  TAB:array [boolean] of AnsiChar=(#$B2,#$D0);
var
  s : RawByteString;
begin
  if not isReady then
    exit;

  wasUINwp := false;

  if (not IsWP) and (wp.uin > '') then
   s:= //TLV($05B9, Word($8000)) +  #$00#$00#$00#$00+
//      Length_BE(#00#01#00#02#00#02)
//      + #$00#$00#$04#$E3#$00#$00#$00#$02
//      + #$00#$03#$00#$00
      SNAC_ver($05B9, 02, $8000, 0, 02)
      + word_BEasStr($00)
      + word_BEasStr(GetACP)
      + dword_BEasStr($02)
      + TLV(03, '')
//      + TLV(02, Word(idx))
        + TLV(01,
           TLV_IFNN(META_COMPAD_UID, wp.uin)+
           TLV_IFNN(META_COMPAD_INFO_HASH, wp.Token)
             )
  else
   begin
     s := #$05#$B9#$0F#$A0#$00#$00#$00#$00#$00#$00
      //  SNAC_shortver($05B9, $0FA0, 0, 0, 02)
//      + #$00#$00#$04#$E3#$00#$00
             + word_BEasStr($00)
//             + word_BEasStr(GetACP)
             + word_BEasStr($FDE9) // UTF8
             + word_BEasStr($00)
      + TLV(02, Word(idx))
      + TLV(01,
//        + TLVIfNotNull(User_First, wp.first)
//        + TLVIfNotNull(User_Last, wp.last)
//          TLVIfNotNull(META_COMPAD_UID, wp.uin)
          TLV_IFNN(CP_User_NICK, StrToUTF8(wp.nick))
//        + TLVIfNotNull(User_email, wp.email)
         + TLVIfDWNotNull(CP_User_Cntry, wp.country)
         + TLV_IFNN(CP_User_City, StrToUTF8(wp.city))
//        + TLVIfNotNull(User_State, wp.state)
//        + TLVIfINotNull(User_Inter, wp.wInterest, wp.keyword)
         + TLVIfWNotNull(CP_User_Lang, wp.lang)
         + TLVIfbNotNull(CP_User_Gender, wp.gender)
         + TLVIfDWLENotNull(CP_User_Age, wp.age)
         + TLVIfWNotNull(CP_User_ONLINE, word(wp.onlineOnly))
//         + TLVIfNotNull(User_, wp.)
//         + TLVIfNotNull(User_, wp.)
        );
   end;

  sendSNAC(ICQ_EXTENSIONS_FAMILY, CLI_META_REQ, TLV(1, Length_LE( myUINle
    + word_LEasStr(CLI_META_INFO_REQ)
    + word_LEasStr(idx)
    + word_LEasStr(META_SEARCH_COMPAD)
    + Length_LE(s) )));
//  if wasUINwp then
//    addRef(REF_wp,wp.uin)
//  else
    if IsWP then
      addRef(REF_wp, '');
end; // sendWPsearch2

procedure TicqSession.getUINStatusNEW(const UID: TUID);
begin
  if not isReady then
    exit;
  if UID > '' then
  sendSnac(ICQ_EXTENSIONS_FAMILY, CLI_META_REQ,
        TLV(1, Length_LE( myUINle
           + word_LEasStr(CLI_META_INFO_REQ)
           + word_LEasStr($03)
           + word_LEasStr(META_SEARCH_COMPAD)
           + Length_LE(//#$05#$b9#$00#$02#$80#$00#$00#$00#$00#$00+
//              #$00#$06#$00#$01#$00#$02#$00#$02+
              SNAC_ver($05B9, 02, $8000, 0, 02)+
              #$00#$00#$04#$e3#$00#$00#$00#$02+
              TLV(3, '')+
              TLV(1,  #00#$32 + Length_LE(UID))
                    )
              )
           )
          );
end;

procedure TicqSession.sendAdvQueryInfo(const uin: TUID; const token: RawByteString);
begin
  if not isReady then
    exit;
  if not (uin = '') then
  sendSnac(ICQ_EXTENSIONS_FAMILY, CLI_META_REQ,
    TLV(1, Length_LE(myUINle
           + word_LEasStr(CLI_META_INFO_REQ)
           + word_LEasStr($03)
           + word_LEasStr(META_SEARCH_COMPAD)
           + Length_LE(SNAC_shortver($05B9, $0fa0, $00, $00, $02)
             + word_BEasStr($00)
             + word_BEasStr(GetACP)
             + dword_BEasStr($02)
             + TLV(3, '')
             + TLV(1,
                  TLV_IFNN(META_COMPAD_UID, uin)
                + TLV_IFNN(META_COMPAD_INFO_HASH, token))
           ))
    )
  );
end;


procedure TicqSession.sendReqOfflineMsgs;
begin
  if not TICQcontact(getMyInfo).isAIM then
    sendSNAC(ICQ_EXTENSIONS_FAMILY, CLI_META_REQ,
           TLV(1, Length_LE( myUINle +#$3C#0#0#0)))
   else
    sendSNAC(ICQ_MSG_FAMILY, $10, ''); // ICBM__OFFLINE_RETRIEVE
end;

procedure TicqSession.sendDeleteOfflineMsgs;
begin
  sendSNAC(ICQ_EXTENSIONS_FAMILY, CLI_META_REQ,
           TLV(1, Length_LE( myUINle +#$3E#0#0#0)))
end;

procedure TicqSession.sendDeleteUIN;
begin
  sendSNAC(ICQ_EXTENSIONS_FAMILY, CLI_META_REQ,
      TLV(1, Length_LE( myUINle
     + word_LEasStr(CLI_META_INFO_REQ)
     + word_LEasStr($01)
     + word_LEasStr(META_REQUEST_DELETE_UIN)
     +myUINle
     +WNTS(pwd)
  )));
end; // sendDeleteUIN

procedure TicqSession.sendSMS(dest, msg: string; ack: boolean);
begin
  if not isReady then
    exit;
  sendSNAC(ICQ_EXTENSIONS_FAMILY, CLI_META_REQ,
     TLV(1, Length_LE( myUINle
    + word_LEasStr(CLI_META_INFO_REQ)
    + word_Zero
    + word_LEasStr(META_REQUEST_SEND_SMS)
    + RawByteString(#00#01#00#$16)
    + StringOfChar(AnsiChar(#00),18)
    + Length_BE( xml_sms(getMyInfo, dest, msg, ack) )
 )));
 addRef(REF_sms, '');
end; // sendSMS

procedure TicqSession.sendSMS2(dest, msg: String; ack: Boolean);
var
  req: RawByteString;
begin
  if not isReady then
    Exit;

  msg := '<HTML><BODY dir="ltr"><FONT face="Arial" color="#000000" size="2">' + msg + '</FONT></BODY></HTML>';
  msg := StrToUnicode(msg);

  OutputDebugString(PChar(hexdumps(msg)));

  req := qword_LEasStr(SNACref) + word_BEasStr(MTYPE_PLAIN)
    + Length_B(dest)
    + TLV(CLI_META_MSG_DATA,
      AnsiChar(CLI_META_REQ_CAPS_BYTE)
      + AnsiChar(CLI_META_FRAG_VERSION_BYTE)
      + Length_BE(#$01) // no caps
      + AnsiChar(CLI_META_FRAG_ID_BYTE)
      + AnsiChar(CLI_META_FRAG_VERSION_BYTE)
      + Length_BE(word_BEasStr(CLI_META_MSG_CHARSET) + word_BEasStr(CLI_META_MSG_LANGUAGE) + msg))
    + TLV(CLI_META_STORE_IF_OFFLINE, '')
    + TLV(CLI_META_MSG_OWNER, '230490')
    + TLV(CLI_META_MSG_UNK, #$00#$00#$00#$01);

  if ack then
    req := req + TLV(CLI_META_MSG_ACK, '');

  sendSNAC(ICQ_MSG_FAMILY, CLI_META_MSG, req);
  addRef(REF_sms, '');
end; // sendSMS2

procedure TicqSession.sendsaveMyInfoNew(c: TICQcontact);
//const
//  tab1:array [boolean] of AnsiChar=(#1,#0);
//  tab2:array [boolean] of AnsiChar=(#0,#1);
var
  sb : RawByteString;
//  zi : Integer;
begin
  if c.birth > 1 then
    c.age := YearsBetween(now, c.birth);
{
  if c.birth > 1 then
   sb:=Word_LEasStr(yearOf(c.birth))
    +Word_LEasStr(monthOf(c.birth))
    +Word_LEasStr(dayOf(c.birth))
  else
    sb:=#00#00+Z;
}
  if c.birth > 712 then
    sb := QWord_BEasStr(DoubleAsInt64(c.birth - 2))
   else
    sb := Z + Z;

//  if not tryStrToInt(c.zip, zi) then
//    zi := 0;
//  if not tryStrToInt(c.workzip, zi) then
//    zi := 0;
  savingMyInfo.ACKcount := 3;

{
  sendSnac(ICQ_EXTENSIONS_FAMILY, CLI_META_REQ,
     TLV(1, Length_LE( myUINle
   + #$D0#07#02#00#$3A#$0C
//   + TLV_LE(User_First, WNTS(c.first))
//   + TLV_LE(User_Last, WNTS(c.last))
//   + TLV_LE(User_Nick, WNTS(c.nick))
   + TLV_LE(User_email, WNTS(c.email) + AnsiChar(publicEmailTab[pPublicEmail]))
//   + TLV_LE(User_Age, Word_LEasStr(c.age))
   + TLV_LE(User_Gender, AnsiChar(c.gender))
   + TLV_LE(User_Lang, Word_LEasStr(c.lang[1]))
   + TLV_LE(User_Lang, Word_LEasStr(c.lang[2]))
   + TLV_LE(User_Lang, Word_LEasStr(c.lang[3]))
   + TLV_LE(User_City, WNTS(c.city))
   + TLV_LE(User_State, WNTS(c.state))
   + TLV_LE(User_Cntry, Word_LEasStr(c.country))
   + TLV_LE(User_Inter, Word_LEasStr(c.interests.InterestBlock[0].Code)
       + WNTS(strings2Str(',', c.interests.InterestBlock[0].Names)))
   + TLV_LE(User_Inter, Word_LEasStr(c.interests.InterestBlock[1].Code)
       + WNTS(strings2Str(',', c.interests.InterestBlock[1].Names)))
   + TLV_LE(User_Inter, Word_LEasStr(c.interests.InterestBlock[2].Code)
       + WNTS(strings2Str(',', c.interests.InterestBlock[2].Names)))
   + TLV_LE(User_Inter, Word_LEasStr(c.interests.InterestBlock[3].Code)
       + WNTS(strings2Str(',', c.interests.InterestBlock[3].Names)))
//   + TLV_LE(User_URL, #00#00+WNTS(c.homepage))
   + TLV_LE(User_URL, WNTS(c.homepage))
   + TLV_LE(User_Birth, sb)
   + TLV_LE(User_MarSts, AnsiChar(c.MarStatus))
//   + TLV_LE(User_Notes, WNTS(c.about))
   + TLV_LE(User_GMTos, AnsiChar(c.GMThalfs))
//   + TLV_LE(User_WebSt, tab2[webaware])
//   + TLV_LE(User_Auth, tab1[authNeeded])
//   + TLV_LE(User_HmZip, dword_LEasStr(zi))
   + TLV_LE(User_HmZip2, WNTS(c.zip))
   + TLV_LE(User_HmCel, WNTS(c.cellular))

   + TLV_LE(User_WkURL,   WNTS(c.workpage))
   + TLV_LE(User_WkPos,   WNTS(c.workPos))
   + TLV_LE(User_WkDept,  WNTS(c.workDep))
   + TLV_LE(User_WkCmpny, WNTS(c.workCompany))
   + TLV_LE(User_WkCity,  WNTS(c.workcity))
   + TLV_LE(User_WkState, WNTS(c.workstate))
   + TLV_LE(User_WkCntry, Word_LEasStr(c.workCountry))
//   + TLV_LE(User_WkZip,   WNTS(c.workzip))
   + TLV_LE(User_WkZip,   dword_LEasStr(zi))
   + TLV_LE(User_WkCell,  WNTS(c.workphone))

//   + TLV(User_, WNTS(c.))
   )));
}
  sendSNAC(ICQ_EXTENSIONS_FAMILY, CLI_META_REQ,
     TLV(1, Length_LE( myUINle
      + word_LEasStr(CLI_META_INFO_REQ)
      + word_LEasStr($02)
      + word_LEasStr(META_SAVE_PROFILE)

      + Length_LE( SNAC_ver($05B9, $03, $00, 00, 02)
             + word_BEasStr($00)
//             + word_BEasStr(GetACP)
             + word_BEasStr($FDE9) // UTF8
             + dword_BEasStr($02)
             + TLV(3, TLV(META_COMPAD_NICK, StrToUTF8(c.nick))
                    + TLV(META_COMPAD_FNAME, StrToUTF8(c.first))
                    + TLV(META_COMPAD_LNAME, StrToUTF8(c.last))
                    + TLV(META_COMPAD_GENDER, AnsiChar(c.gender))
                    + TLV(META_COMPAD_MARITAL_STATUS, c.MarStatus)
                    + TLV(META_COMPAD_BDAY, sb)
                    + TLV(META_COMPAD_LANG1, Word_BEasStr(c.lang[1]))
                    + TLV(META_COMPAD_LANG2, Word_BEasStr(c.lang[2]))
                    + TLV(META_COMPAD_LANG3, Word_BEasStr(c.lang[3]))
                    + TLV(META_COMPAD_ABOUT, StrToUTF8(c.about))
        // Home info
        + TLV(META_COMPAD_HP, StrToUTF8(c.homepage))
        + TLV(META_COMPAD_HOMES, TLV(1,
            TLV(META_COMPAD_HOMES_ADDRESS, StrToUTF8(c.address))
          + TLV(META_COMPAD_HOMES_CITY, StrToUTF8(c.city))
          + TLV(META_COMPAD_HOMES_STATE, copy(StrToUTF8(c.state), 1, 18)) // 19 bytes limit, but it truncates cyrillic
          + TLV(META_COMPAD_HOMES_COUNTRY, DWord_BEasStr(c.country))
          + TLV(META_COMPAD_HOMES_ZIP, StrToUTF8(c.zip))
          ))
        // Work info
        + TLV(META_COMPAD_WORKS, TLV(1,
            TLV(META_COMPAD_WORKS_ORG, StrToUTF8(c.workCompany))
          + TLV(META_COMPAD_WORKS_POSITION, StrToUTF8(c.workPos))
          + TLV(META_COMPAD_WORKS_DEPT, StrToUTF8(c.workDep))
          + TLV(META_COMPAD_WORKS_PAGE, StrToUTF8(c.workpage))
          + TLV(META_COMPAD_WORKS_ADDRESS, StrToUTF8(c.workaddress))
          + TLV(META_COMPAD_WORKS_CITY, StrToUTF8(c.workcity))
          + TLV(META_COMPAD_WORKS_STATE, copy(StrToUTF8(c.workstate), 1, 18)) // 19 bytes limit, but it truncates cyrillic
          + TLV(META_COMPAD_WORKS_COUNTRY, DWord_BEasStr(c.workcountry))
          + TLV(META_COMPAD_WORKS_ZIP, StrToUTF8(c.workzip))
          ))
        // Mobile
        + TLV(META_COMPAD_PHONES, word_BEasStr($06) +
            Length_BE(
              TLV(META_COMPAD_PHONES_NUM, StrToUTF8(c.regular))
            + TLV(META_COMPAD_PHONES_CNT, $01)) +

            Length_BE(
              TLV(META_COMPAD_PHONES_NUM, StrToUTF8(c.workphone))
            + TLV(META_COMPAD_PHONES_CNT, $02)) +

            Length_BE(
              TLV(META_COMPAD_PHONES_NUM, StrToUTF8(c.cellular))
            + TLV(META_COMPAD_PHONES_CNT, $03)) +
            // Faxes
            Length_BE(
              TLV(META_COMPAD_PHONES_NUM, '')
            + TLV(META_COMPAD_PHONES_CNT, $04)) +

            Length_BE(
              TLV(META_COMPAD_PHONES_NUM, '')
            + TLV(META_COMPAD_PHONES_CNT, $05)) +
            // Empty
            Length_BE(
              TLV(META_COMPAD_PHONES_NUM, '')
            + TLV(META_COMPAD_PHONES_CNT, $06))
          )
        // Birth info
        + TLV(META_COMPAD_FROM, TLV(1,
            TLV(META_COMPAD_FROM_COUNTRY, DWord_BEasStr(c.birthcountry))
          + TLV(META_COMPAD_FROM_CITY, copy(StrToUTF8(c.birthcity), 1, 18)) // 19 bytes limit, but it truncates cyrillic
          + TLV(META_COMPAD_FROM_STATE, StrToUTF8(c.birthstate))
//          + TLV(META_COMPAD_FROM_ADDRESS, StrToUTF8(''))
          ))
        // Interests
        + TLV(META_COMPAD_INTERESTS, word_BEasStr($04) +
            Length_BE(
              TLV(META_COMPAD_INTEREST_TEXT, StrToUTF8(Trim(c.interests.InterestBlock[0].Names.Text)))
            + TLV(META_COMPAD_INTEREST_ID, Word(c.interests.InterestBlock[0].Code))) +

            Length_BE(
              TLV(META_COMPAD_INTEREST_TEXT, StrToUTF8(Trim(c.interests.InterestBlock[1].Names.Text)))
            + TLV(META_COMPAD_INTEREST_ID, Word(c.interests.InterestBlock[1].Code))) +

            Length_BE(
              TLV(META_COMPAD_INTEREST_TEXT, StrToUTF8(Trim(c.interests.InterestBlock[2].Names.Text)))
            + TLV(META_COMPAD_INTEREST_ID, Word(c.interests.InterestBlock[2].Code))) +

            Length_BE(
              TLV(META_COMPAD_INTEREST_TEXT, StrToUTF8(Trim(c.interests.InterestBlock[3].Names.Text)))
            + TLV(META_COMPAD_INTEREST_ID, Word(c.interests.InterestBlock[3].Code)))
          )
        + TLV(META_COMPAD_GMT, word_BEasStr(c.GMThalfs))
        )
       )
      )
     )
    );
end;

procedure TicqSession.sendPermsNew;//(c:Tcontact);
const
  tab1:array [boolean] of AnsiChar=(#1,#0);
  tab2:array [boolean] of AnsiChar=(#0,#1);
//var
//  sb : String;
//  zi : Integer;
begin
 if not isReady then exit;
{  if c.birth > 1 then
    c.age:=trunc((now-c.birth)/365);
  if c.birth > 1 then
   sb:=Word_LEasStr(yearOf(c.birth))
    +Word_LEasStr(monthOf(c.birth))
    +Word_LEasStr(dayOf(c.birth))
  else
    sb:=#00#00+Z;
//  if not tryStrToInt(c.zip, zi) then
//    zi := 0;
}
  savingMyinfo.ACKcount := 0;
{
  sendSNAC(ICQ_EXTENSIONS_FAMILY, CLI_META_REQ,
    TLV(1, Length_LE(myUINle
      + word_LEasStr(CLI_META_INFO_REQ)
      + word_LEasStr($02)
      + word_LEasStr(META_SEND_PERM)
      + Length_LE(SNAC_ver($05B9, $03, $00, $00, $02)
      + word_BEasStr($00)
      + word_BEasStr(GetACP)
      + dword_BEasStr($02)
      + TLV(3, TLV(META_COMPAD_INFO_SHOW, 0))))
    )
  );
}
  sendSnac(ICQ_EXTENSIONS_FAMILY, CLI_META_REQ,
     TLV(1, Length_LE( myUINle
   + #$D0#07#02#00#$3A#$0C
{   + TLV_LE(User_First, WNTS(c.first))
   + TLV_LE(User_Last, WNTS(c.last))
   + TLV_LE(User_Nick, WNTS(c.nick))
   + TLV_LE(User_email, WNTS(c.email) + AnsiChar(publicEmailTab[pPublicEmail]))
//   + TLV_LE(User_Age, Word_LEasStr(c.age))
   + TLV_LE(User_Gender, char(c.gender))
   + TLV_LE(User_Lang, Word_LEasStr(c.lang[1]))
   + TLV_LE(User_Lang, Word_LEasStr(c.lang[2]))
   + TLV_LE(User_Lang, Word_LEasStr(c.lang[3]))
   + TLV_LE(User_City, WNTS(c.city))
   + TLV_LE(User_State, WNTS(c.state))
   + TLV_LE(User_Cntry, Word_LEasStr(c.country))
   + TLV_LE(User_Inter, Word_LEasStr(c.interests.InterestBlock[0].Code)
       + WNTS(strings2Str(',', c.interests.InterestBlock[0].Names)))
   + TLV_LE(User_Inter, Word_LEasStr(c.interests.InterestBlock[1].Code)
       + WNTS(strings2Str(',', c.interests.InterestBlock[1].Names)))
   + TLV_LE(User_Inter, Word_LEasStr(c.interests.InterestBlock[2].Code)
       + WNTS(strings2Str(',', c.interests.InterestBlock[2].Names)))
   + TLV_LE(User_Inter, Word_LEasStr(c.interests.InterestBlock[3].Code)
       + WNTS(strings2Str(',', c.interests.InterestBlock[3].Names)))
//   + TLV_LE(User_URL, #00#00+WNTS(c.homepage))
   + TLV_LE(User_URL, WNTS(c.homepage))
   + TLV_LE(User_Birth, sb)
   + TLV_LE(User_Notes, WNTS(c.about))
   + TLV_LE(User_GMTos, char(c.GMThalfs)) }
   + TLV_LE(User_Auth, tab1[authNeeded])
   + TLV_LE(User_WebSt, tab2[webaware])
   //   + TLV_LE(User_HmZip, dword_LEasStr(zi))
{   + TLV_LE(User_HmZip2, WNTS(c.zip))
   + TLV_LE(User_HmCel, WNTS(c.cellular))
}
//   + TLV(User_, WNTS(c.))
   )));

end;

procedure TicqSession.sendInfoStatus(const s : String);
begin
  sendSnac(ICQ_EXTENSIONS_FAMILY, CLI_META_REQ,
        TLV(1, Length_LE( myUINle
          + word_LEasStr(CLI_META_INFO_REQ)
          + word_LEasStr($02)
          + word_LEasStr(META_SAVE_PROFILE)
          + Length_LE(SNAC_ver($05B9, $03, $00, $00, $02)
            + word_BEasStr($00)
            + word_BEasStr(GetACP)
            + dword_BEasStr($02)
            + TLV(3, TLV(META_COMPAD_STS_MSG, StrToUTF8(s)))
             )
            )
           )
          );
end;

procedure TicqSession.sendPrivacy(em: Word; shareWeb: Boolean; authReq: Boolean);
var
  weba, auth: Word;
begin
  if ShareWeb then
    weba := 1
   else
    weba := 0;

  if authReq then
    auth := 0
  else
    auth := 1;

  showInfo := em;
  webaware := ShareWeb;
  sendSnac(ICQ_EXTENSIONS_FAMILY, CLI_META_REQ,
       TLV(1, Length_LE( myUINle
               + word_LEasStr(CLI_META_INFO_REQ)
               + word_LEasStr($02)
               + word_LEasStr(META_SAVE_PROFILE)
               + Length_LE(SNAC_ver($05B9, $03, $00, $00, $02)
                  + word_BEasStr($00)
                  + word_BEasStr(GetACP)
                  + dword_BEasStr($02)
                  + TLV(3,
                        TLV(META_COMPAD_INFO_SHOW, em)
                      + TLV(META_COMPAD_WEBAWARE, AnsiChar(weba))
                      + TLV(META_COMPAD_AUTH, auth)
                   ))
                    )
              )
          );
end;


{procedure TicqSession.sendPermissions;
const
  tab1:array [boolean] of AnsiChar=(#1,#0);
  tab2:array [boolean] of AnsiChar=(#0,#1);
begin
if not isReady then exit;
sendSNAC(ICQ_EXTENSIONS_FAMILY, CLI_META_REQ, TLV(1, Length_LE( myUINle
  +#$D0#7#0#0#$24#4
  +tab1[authNeeded]+tab2[webaware]+#1#0
)));
end; // sendPermissions
}

procedure TicqSession.sendChangePwd(const newPwd: RawByteString);
begin
  if not isReady then exit;
  waitingNewPwd:=newPwd;
  sendSNAC(ICQ_EXTENSIONS_FAMILY, CLI_META_REQ,
    TLV(1, Length_LE(myUINle
      + word_LEasStr(CLI_META_INFO_REQ)
      + word_Zero
      + word_LEasStr(META_SAVE_PROFILE)
      + WNTS(newpwd))
    )
  );
end; // sendChangePwd

procedure TicqSession.sendSticker(const uin: TUID; const sticker: String);
begin
  sendSnac(ICQ_MSG_FAMILY, CLI_META_MSG, #$AB#$AB#$AB#$AB#$AB#$AB#$AB#$AB
         + word_BEasStr(MTYPE_PLAIN) + Length_B(uin)
         + TLV(CLI_META_STORE_IF_OFFLINE, '')
         + TLV(CLI_META_MSG_DATA,
               AnsiChar(CLI_META_REQ_CAPS_BYTE)
             + AnsiChar(CLI_META_FRAG_VERSION_BYTE)
             + Length_BE(word_BEasStr(CLI_META_REQ_CAP))
             + AnsiChar(CLI_META_FRAG_ID_BYTE)
             + AnsiChar(CLI_META_FRAG_VERSION_BYTE)
             + Length_BE(word_BEasStr(CLI_META_MSG_CHARSET) + word_BEasStr(CLI_META_MSG_LANGUAGE))) // Empty msg
         + TLV(CLI_META_STICKER_DATA, sticker)
  );
end;

procedure TicqSession.parseAuthKey(const snac: RawByteString);
var
    I          : Integer;
    MD5Digest  : TMD5Digest;
    MD5Context : TMD5Context;
    key : RawByteString;
    sendKey : RawByteString;
    ppp : RawByteString;
begin
    i := 1;
    key := getWNTS(snac, i);
    if saveMD5pwd and LoginMD5 and (fPwdHash > '') then
      ppp := fPwdHash
     else
      ppp := fPwd;

//    sendKey := MD5Pass(key + ppp + AIM_MD5_STRING);
    FillChar(MD5Digest, sizeOf(TMD5Digest), 0);
    MD5Init(MD5Context);
    MD5UpdateBuffer(MD5Context, PAnsiChar(key), length(key));
    MD5UpdateBuffer(MD5Context, PAnsiChar(@ppp[1]), length(ppp));
    MD5UpdateBuffer(MD5Context, PAnsiChar(AIM_MD5_STRING), length(AIM_MD5_STRING));
    MD5Final(MD5Digest, MD5Context);
    sendKey := '';
    for I := 0 to 15 do
      sendKey := sendKey + AnsiChar(MD5Digest[I]);
//   sendFLAP( LOGIN_CHANNEL, #0#0#0#1
   if saveMD5Pwd then
     key := TLV($4C, '')
    else
     key := '';

   if sock.SslEnable then
     key := key + TLV($8C, ''); // use SSL

// Sending  1702
   sendSNAC( $17, $02,
       TLV(1, MyAccount)
      +TLV($25, sendKey)
    // By Rapid D
//      +TLV($4C, '')
      +TLV(3, 'ICQBasic')
      +TLV($16, word($010A))
      +TLV($17, word($0014)) // CLIENT_VERSION_MAJOR
      +TLV($18, word($0022)) // CLIENT_VERSION_MINOR
      +TLV($19, word($0001)) // CLIENT_VERSION_LESSER
//      +TLV($1A, word(RnQBuild))
//      +TLV($1A, word($666))
      +TLV($1A, word(MAXWORD-666)) // CLIENT_VERSION_BUILD
      +TLV($14, integer($666)) // CLIENT_DISTRIBUTION
{
      +TLV(3, 'ICQ Inc. - Product of ICQ (TM).2003b.5.56.1.3916.85')
      +TLV($16, word($010A))
      +TLV($17, word($0002))
      +TLV($18, word($0038))
      +TLV($19, word($0001))
      +TLV($1A, word($0f4c))
}
//      +TLV($14, integer($55))
      +TLV($E,'us')
      +TLV($F,'en')
 {$IFDEF UseNotSSI}
      +TLV($4A, #00)   // SSI use flag//  	SSI flag: 1 - SSI only, 0 - family 0x03
 {$ELSE UseOnlySSI}
      +TLV($4A, #01)   // SSI use flag//  	SSI flag: 1 - SSI only, 0 - family 0x03
 {$ENDIF UseNotSSI}
      +key
   );
  notifyListeners(IE_loggin);
end;

procedure TicqSession.parseSRV_LOGIN_REPLY(const snac:RawByteString);
begin
end;


procedure TicqSession.parseCookie(const flap:RawByteString);
var
  add: RawByteString;
  i:integer;
 {$IFDEF USE_SSL}
  useSSL : Boolean;
 {$ENDIF USE_SSL}
begin
  i:=findTLV(8, flap);
  if i > 0 then
    begin
     eventInt := getTLVwordBE(@flap[i]);
    case eventInt of
      $01:eventError :=EC_badUIN;
      $04:eventError :=EC_badPwd;
      $05:eventError :=EC_badPwd;
      $18:eventError :=EC_rateExceeded;
      $1D:eventError :=EC_loginDelay;
      else eventError:=EC_other;
      end;
    if eventInt <> $1C then // if recommended update, then continue logon
     begin
       eventMsgA := getTLV(4, flap);
       disconnect;
       notifyListeners(IE_error);
       exit;
     end;
    end;
  if existsTLV(9, flap) then
    begin
      eventError:=EC_serverDisconnected;
      case getTLVwordBE(9, flap) of
        $01:eventError :=EC_badUIN;
        $04:eventError :=EC_badPwd;
        $05:eventError :=EC_badPwd;
        $18:eventError :=EC_rateExceeded;
        $1D:eventError :=EC_loginDelay;
       else eventError:=EC_other;
      end;
//      if existsTLV($0B) then
      eventMsgA := getTLV($0B, flap);
      disconnect;
      notifyListeners(IE_error);
      exit;
    end;
  if pos(AnsiChar('@'), MyAccount) > 1 then
   MyAccount := getTLV(1, flap);
  add:=getTLV(5, flap);
  serviceServerAddr:=copy(add,1,pos(AnsiChar(':'),add)-1);
  serviceServerPort:=copy(add,pos(AnsiChar(':'),add)+1,10);
  cookie := getTLV(6, flap);

 {$IFDEF USE_SSL}
  useSSL := aProxy.ssl;
  if useSSL then
   begin
//    SSL_CERTNAME := getTLV($8D, pkt);
//    SSL_STATE    := getTLVbyte($8E, pkt);
{
NOT_USED	0	SSL is not supported or not requested for this connection
USE	1	SSL is being used
RESUME	2	SSL is being used and SSL resume is supported if desired
}
      add := getTLVSafe($8E, flap);
      if (add = '')or (add = #0) then
        useSSL := false;
   end;
 {$ENDIF USE_SSL}


  sock.close;
  sock.WaitForClose;  // prevent to change properties while the socket is open
{  if sock.http.enabled then
    begin
    sock.addr:=sock.http.addr;
    sock.port:=sock.http.port;
    end
  else}
    begin
    sock.addr:=serviceServerAddr;
    sock.port:=serviceServerPort;
    end;
  phase:=RECONNECTING_;
    eventAddress := sock.AddrPort;
  notifyListeners(IE_redirecting);

  sock.isSSL := useSSL;

//    notifyListeners(IE_serverConnecting);
  sock.Connect;
end; // parseCookie

procedure TicqSession.parseREDIRECTxSERVICE(const pkt : RawByteString); // 0105
var
  add: RawByteString;
  i : integer;
begin
   {$IFDEF RNQ_AVATARS}
{ if Copy(pkt, 1, 2) <> #$00#$0D then
  begin
//   i := getTLVwordBE(@pkt[1]);
   i:=system.swap(word((@pkt[1])^));
//   getBEWNTS(pkt, i);
   pkt := copy(pkt, i+3, length(pkt)- i-2);
  end;
}
 i := getTLVwordBE($0d, pkt);
 if i = $10 then
  begin
    add:=getTLV(5, pkt);
    i := pos(AnsiChar(':'),add);
    if i > 0 then
     begin
      avt_icq.serviceServerAddr := copy(add, 1, i-1);
      avt_icq.serviceServerPort := copy(add, i+1, 10);
     end
    else
     begin
      avt_icq.serviceServerAddr := add;
      avt_icq.serviceServerPort := loginServerPort;
     end;

    avt_icq.cookie:=getTLV(6, pkt);
    avt_icq.cookieTime := now;
//    SSL_CERTNAME := getTLV($8D, pkt);
//    SSL_STATE    := getTLVbyte($8E, pkt);
{
NOT_USED	0	SSL is not supported or not requested for this connection
USE	1	SSL is being used
RESUME	2	SSL is being used and SSL resume is supported if desired
}
//   proxy_http_Enable(avt_icq.sock);
 {$IFDEF USE_SSL}
   avt_icq.sock.isSSL := false;//self.sock.isSSL;
 {$ENDIF USE_SSL}
   avt_icq.connect;//(false, True);
  end;
   {$ENDIF RNQ_AVATARS}
// notifyListeners(IE_connect_avt);
end;

procedure TicqSession.parseOncomingUser(const snac: RawByteString); // Snac 030B
var
  s: RawByteString;
  ofs, t, i, l :integer;
  TLVCnt : Word;
//  found:boolean;
begin
eventFlags:=0;
eventTime:=now;
ofs:=1;
eventContact:= getICQContact(getBUIN2(snac,ofs));
inc(ofs, 2);
  TLVCnt := readBEWORD(snac, ofs);

  if existsTLV($b, snac,ofs) then
    eventContact.typing.bSupport := True
   else
    begin
     eventContact.typing.bSupport := false;
     eventContact.typing.bIsTyping := false;
    end;

  t := ofs;
  i := 0;
  l := Length(snac);
  while (i < TLVCnt)and (t < l) do
   begin
//    inc(t, 2);
//    t := findTLV(5, snac,ofs);
    inc(t, word_BEat(snac, t+2) + 4);
    inc(i);
   end;
  s := Copy(snac, ofs, t-ofs);
 //  Delete(snac, ofs, t-ofs);
//  ofs := 1;
  parseOnlineInfo(s, 1, eventContact, True, false);
  s := '';


//parseStatus(snac,ofs);
{with eventContact do
  if status = SC_OFFLINE then     // there could be no status specified, then SC_ONLINE
    begin
		prevStatus:=status;
    status:=SC_ONLINE;
    notifyListeners(IE_oncoming);
    lastTimeSeenOnline:=eventTime;
    end;
}
//  parseOnlineInfo(snac,ofs, eventContact, true);

end; // parseOncomingUser


procedure TicqSession.parseOnlineInfo(const snac: RawByteString; pOfs: Integer; cont : TICQcontact; isSt : Boolean;
                                      isMsg: Boolean; ShowCntSts: Boolean);
var
  ofs: Integer;
  s: RawByteString;
  pS: PAnsiChar;
  moodText, xStatusText: String;
  cap, capSm: RawByteString;
  found, status_changed: Boolean;
  i : Integer;
  t : Byte;
  nickFlags : Int64;
  skipIt, moodPresText, moodPresIcon : Boolean;
  oldPic : TPicName;
begin
  ofs := pOfs;
  status_changed := False;

  i := findTLV($02, snac,ofs);
  if i > 0 then
    cont.createTime:=UnixToDateTime(getTLVdwordBE(@snac[i]));

  i := findTLV($03, snac,ofs); // Signon time
  if i > 0 then
    cont.onlineSince:=UnixToDateTime(getTLVdwordBE(@snac[i]))+GMToffset
  else
    cont.onlineSince:=0;
//  if existsTLV(3, snac,ofs) then
//    myinfo.memberSince:= UnixToDateTime(getTLVdwordBE(3, snac,ofs));

  i := findTLV($04, snac,ofs); // Idle time in minutes
  if i>0 then
    cont.IdleTime:= getTLVwordBE(@snac[i])
   else
    cont.IdleTime:= 0;

  i := findTLV($05, snac,ofs); // Approximation of AIM membership
  if i>0 then
    cont.memberSince:=UnixToDateTime(getTLVdwordBE(@snac[i]));

  i := findTLV($0A, snac,ofs); // Network byte order IP address
  if i>0 then
   cont.connection.ip:=getTLVdwordBE(@snac[i]);

  i := findTLV($0F, snac,ofs); // Online time in seconds
  if i>0 then
    cont.OnlineTime := getTLVdwordBE(@snac[i])
   else
    cont.OnlineTime := 0;

  i := findTLV($14, snac,ofs); // Set in first nick info. Identifies the instance number of this client

  i := findTLV($01, snac,ofs); // NICK_FLAGS - Flags that represent the user's state
   if i>0 then
     nickFlags := getTLVwordBE(@snac[i])
    else
     nickFlags := 0;
  cont.isMobile := nickFlags and $0080 > 0;

  i := findTLV($44, snac, ofs); // Last time client was present
  if i > 0 then
  begin
    cont.noClient := not (getTLVdwordBE(@snac[i]) = $FFFFFFFF);
    cont.clientClosed := UnixToDateTime(getTLVdwordBE(@snac[i]));
  end;
(*
{  i := findTLV($1F, snac,ofs); // NICK_FLAGS2 - Upper bytes of nick flags, can be any size. nickFlags = NICK_FLAG | (NICK_FLAGS2 << 16)
   if i>0 then
     nickFlags := nickFlags or (NICK_FLAGS2 shl 16)
{
UNCONFIRMED	0x0001	Unconfirmed account
AOL	0x0004	AOL user
AIM	0x0010	AIM user
UNAVAILABLE	0x0020	User is away
ICQ	0x0040	ICQ user; AIM bit will also be set
WIRELESS	0x0080	On a mobile device
IMF	0x0200	Using IM Forwarding
BOT	0x0400	Bot user
ONE_WAY_WIRELESS	0x1000	One way wireless device
NO_KNOCK_KNOCK	0x00040000	Do not display the "not on your Buddy List" knock-knock as the server took care of it or the sender is trusted
FORWARD_MOBILE	0x00080000	If no active instances forward to mobile
}
*)
//  i := findTLV($14, snac,ofs); // Set in first nick info. Identifies the instance number of this client
//  i := findTLV($23, snac,ofs); // BUDDYFEED_TIME - Last Buddy Feed update time
  i := findTLV($26, snac,ofs); // SIG_TIME - Time that the profile was set
  if i>0 then
    cont.lastInfoUpdate:=UnixToDateTime(getTLVdwordBE(@snac[i]))+GMToffset;
//   else
//    cont.lastInfoUpdate := 0;

//  i := findTLV($27, snac,ofs); // AWAY_TIME - Time that away was set
//  i := findTLV($2A, snac,ofs); // GEO_COUNTRY - Two character country code. Sent from host to client if country is known

 found := false;
 i := findTLV($19, snac,ofs);  // Short form of capabilities
 if i>0 then
	with cont do
     begin
		 s:=getTLV(@snac[i]);
	   capabilitiesBig:=[];
	   capabilitiesSm:=[];
	   capabilitiesXTraz:=[];
     extracapabilities:='';
      while s > '' do
       begin
        capSm:=copy(s,1,2);
        delete(s,1,2);
        found:=FALSE;
         for i:=1 to length(CapsSmall) do
          if capSm = CapsSmall[i].v then
          begin
             include(capabilitiesSm,i);
             found:=TRUE;
             break;
          end;
         if not found then
          extracapabilities:=extracapabilities+
           CapsMakeBig1 + capSm + CapsMakeBig2;
       end;
	  // temporary fix for icq2go, this prevents from using type-2 messages
//	   icq2go:=(CAPS_sm_UTF8 in capabilitiesSm) and not (CAPS_sm_ICQSERVERRELAY in capabilitiesSm);
//     if CAPS_big_Tril in capabilitiesBig then icq2go := true;
      found := True;
	 end;

{  if isSt then
    begin
     t := $D;
    end
   else
    begin
     t := $05;
    end;
}
 i := findTLV($0D, snac,ofs);
 if i>0 then
 	with cont do
	  begin
     s:=getTLV(@snac[i]);
     if not found then
      begin
       capabilitiesBig:=[];
       capabilitiesSm:=[];
       capabilitiesXTraz := [];
       extracapabilities:='';
      end;
     t := 0;
      while s > '' do
        begin
        cap:=copy(s,1,16);
        delete(s,1,16);
        found:=FALSE;
        for i:=1 to length(BigCapability) do
          if cap = BigCapability[i].v then
            begin
             include(capabilitiesBig,i);
             found:=TRUE;
             break;
            end;
        if copy(cap, 1, 2) = CapsMakeBig1 then
          if copy(cap, 5, 12) = CapsMakeBig2 then
           begin
             cap := copy(cap, 3, 2);
             for i:=1 to length(CapsSmall) do
              if cap = CapsSmall[i].v then
              begin
                 include(capabilitiesSm,i);
                 found:=TRUE;
                 break;
              end;
           end;
        if not found then
         begin
           for i:= 0 to High(XStatusArray) do
            if xsf_Old in XStatusArray[i].flags then
             if cap = XStatusArray[i].pidOld then
              begin
               include(capabilitiesXTraz,i);
               found := TRUE;
               break;
              end;
         end;
      if not found then
          extracapabilities:=extracapabilities+cap;
        end;
	  // temporary fix for icq2go, this prevents from using type-2 messages
	   icq2go:=(CAPS_sm_UTF8 in capabilitiesSm) and not (CAPS_sm_ICQSERVERRELAY in capabilitiesSm);
      if not (CAPS_sm_ICQSERVERRELAY in capabilitiesSm) then
        icq2go := True;
     if CAPS_big_Tril in capabilitiesBig then icq2go := true;
     if (proto = 8) and (CAPS_big_Lite in capabilitiesBig) then icq2go := true;
     if CAPS_big_MTN in capabilitiesBig then cont.typing.bSupport := True;

{     if xStatus <> t then
       begin
        status_changed := True;
        xStatus := t;
        xStatusStr := '';
        xStatusDecs := '';
       end;
}
	  end;

  if CAPS_big_CryptMsg in cont.capabilitiesBig then
    cont.Crypt.supportCryptMsg   := True
   else
    cont.Crypt.supportCryptMsg   := False
   ;

  moodPresText := False;
  moodPresIcon := False;
  moodText := '';
//{$IFDEF RNQ_AVATARS}
  i := findTLV($1D, snac, ofs); // Expressions
  if i>0 then
    begin
     s:=getTLV(@snac[i]);
     if s > '' then
       begin
        skipIt := False;
  //	with eventContact do
        while Length(s) > 3 do
         begin
           i := Length(s);
           case word_BEat(@s[1]) of
             1, 8:  // BART_BUDDY_ICON
                begin
                 t := Byte(s[4]);
                 if (t > 0) and not skipIt then
                 begin
                  skipIt := True;
                  cont.Icon.ID := word_BEat(@s[1]);
                  cont.Icon.Flags := Byte(s[3]);
                  cont.Icon.HL := t;
                  cont.ICQIcon.hash := copy(s,5, cont.Icon.HL);
                  if (cont.ICQIcon.hash = AvtHash_NoAvt)
                     or (cont.ICQIcon.hash = BART_ID_EMPTY) then
                    cont.ICQIcon.hash := '';
                  if (Length(cont.ICQIcon.hash) = 16) and
                     (cont.ICQIcon.hash <> cont.ICQIcon.hash_safe)then
                    begin
                      eventContact := cont;
                      notifyListeners(IE_avatar_changed);
                    end;
                  if isMyAcc(cont) then
                   myAvatarHash := cont.ICQIcon.hash;
                 end;
//                  i := 4 + cont.Icon.HL;
                 i := 4 + t;
                end;
             2:  // BART_STATUS_TEXT - StringTLV format; DATA flag is always set
                begin
                 moodPresText := True;
                 t := Byte(s[4]);
                 if t > 0 then
                 begin
                  i := word_BEat(@s[5]);
                  if (i + 6) <= length(s) then
                   begin
                     if i >0 then
//                       moodText := excludeTrailingCRLF(unUTF( unUTF(copy(s, 7, i))))
                       moodText := excludeTrailingCRLF(unUTF(copy(s, 7, i)))
                      else
                       moodText := '';
                   end;
                 end
                 else
                    moodText := '';
                 ;
                 i := 4 + t;
                end;
             $0D, // STATUS_STR_TOD - Time when the status string is set
             $0F:  // CURRENT_AV_TRACK - XML file; Data flag should not be set
                begin
                 t := Byte(s[4]);
//                 if t > 0 then
//                 begin
//                 end;
                 i := 4 + t;
                end;
             $10:
               begin
                 moodPresText := True;
                 t := Byte(s[4]);
                 if t > 0 then
                 begin
                  i := word_BEat(@s[5]);
                  if (i + 6) <= length(s) then
                   begin
                     if i > 0 then
                       xStatusText := excludeTrailingCRLF(unUTF(copy(s, 7, i)))
                      else
                       xStatusText := '';
                   end;
                 end
                 else
                    xStatusText := '';

                 i := 4 + t;
               end;
             BART_TYPE_STATUS_MOOD:  // BART_STATUS_ICON
                begin
                 moodPresIcon := True;
//                 t := word_BEat(@s[3]);
                 t := byte(s[4]);
                 i := t;
//                 if t > 0 then
//                 begin
//                  i := word_BEat(@s[5]);
//                  if (i +6) < length(s) then
                   begin
                    cap := copy(s, 5, i);
                    found := False;
//                    cont.xStatusStr := excludeTrailingCRLF(unUTF( unUTF(copy(s, 7, i))));
                     for i:= 0 to High(XStatusArray) do
                      if xsf_6 in XStatusArray[i].flags then
                       if cap = XStatusArray[i].pid6 then
                        begin
                         found := TRUE;
                         if cont.xStatus <> i then
                           begin
                            status_changed := True;
                            cont.xStatus := i;
//                            cont.xStatusStr := '';
//                            cont.xStatusDecs := '';
                           end;
                         break;
                        end;
                     if not found then
                       begin
                         i := 0;
                         if cont.xStatus <> i then
                           begin
                            status_changed := True;
                            cont.xStatus := i;
//                            cont.xStatusStr := '';
//                            cont.xStatusDecs := '';
                           end;
                       end;
                   end;
//                 end;
                 i := 4 + t;
                end;
             	1024: // EMOTICON_SET - Set of default Emoticons
                begin
                 t := Byte(s[4]);
                 i := 4 + t;
                end
               else
                begin
                 t := Byte(s[4]);
                 i := 4 + t;
                end;
           end;
           Delete(s, 1, i);
         end;
//        if Length(s) > i+1 then
       end;
    end;
//{$ENDIF}
 skipIt := not moodPresIcon or ((cont.xStatus = 0) and (cont.capabilitiesXTraz <> []));
 if not isMsg then
 begin
//   if not moodPresIcon then
   if skipIt then
    if (cont.capabilitiesXTraz = []) then
      begin
       if (cont.xStatus <> 0) then
          status_changed := True;
       cont.xStatus := 0;
       cont.xStatusStr := '';
      end
     else
      for t in cont.capabilitiesXTraz do
      if (cont.xStatus <> t) then //and(cont.status <> ICQcontacts.SC_OFFLINE) then
       begin
        begin
         status_changed := True;
         cont.xStatus := t;
         cont.xStatusStr := '';
    //     if not isMsg then
         if not moodPresText then
           cont.xStatusDesc := '';
        end;
       end;
   if (moodPresIcon or (cont.capabilitiesXTraz = [])) then
  //  if moodPresText then
      begin
       if (cont.capabilitiesXTraz = [])or status_changed then
         cont.xStatusStr := '';
      end;

   if moodPresText then
      begin
       if cont.xStatusDesc <> moodText then
         begin
           status_changed := True;
           cont.xStatusDesc := moodText;
         end;
      end;

 end;


// if not isMyAcc(cont) then
 begin
  s:=getTLV($0C, snac,ofs);
  if Length(s) > 30 then
    begin
      pS := @s[1];
    cont.connection.internal_ip:=dword_BEat(pS);
    cont.connection.port:=dword_BEat(pS + 4);
{    cont.proto:=word_BEat(@s[10]);
    cont.connection.dc_cookie:=dword_BEat(@s[12]);
    cont.lastupdate_dw:=dword_BEat(@s[24]);
    cont.lastinfoupdate_dw:=dword_BEat(@s[28]);
    cont.lastStatusUpdate_dw:=dword_BEat(@s[32]);}
    cont.proto:=word_BEat(pS + 9);
    cont.connection.dc_cookie:=dword_BEat(pS+11);
    cont.lastupdate_dw:=dword_BEat(pS+23);
    cont.lastinfoupdate_dw:=dword_BEat(pS+27);
    cont.lastStatusUpdate_dw:=dword_BEat(pS+31);
    cont.lastUpdate:=UnixToDateTime(cont.lastupdate_dw)+GMToffset;
//    cont.lastInfoUpdate:=UnixToDateTime(cont.lastinfoupdate_dw)+GMToffset;
    cont.lastStatusUpdate:=UnixToDateTime(cont.laststatusupdate_dw)+GMToffset;
    end
  else
   if not isMsg then
    begin
  //  cont.internal_ip:=0;
    cont.connection.port:=0;
    cont.connection.dc_cookie:=0;
    cont.proto:=0;
    cont.lastupdate_dw:=0;
    cont.lastinfoupdate_dw:=0;
    cont.laststatusupdate_dw:=0;
    end;
 end;
// cont.ClientStr := getClientPicFor(cont);


 if ShowCntSts then
  begin
    eventContact := cont;
    if //not cont.equals(myAccount) and
      ( (not isMsg)or(supportInvisCheck) ) then
     begin
  {    if not existsTLV(6, snac,ofs) then
       begin
        cont.status := SC_ONLINE;
        notifyListeners(IE_oncoming);
        exit;
       end;}
      parseStatus(snac, ofs, cont, not isSt, status_changed);
     end
    else
     if status_changed then
       notifyListeners(IE_statuschanged)
      else
       notifyListeners(IE_contactupdate);
  end;

  oldPic := cont.ClientPic;
  getClientPicAndDesc4(cont, cont.ClientPic, cont.ClientDesc);
  if cont.ClientPic <> oldPic then
   begin
     eventContact := cont;
     notifyListeners(IE_redraw);
   end;
end;

procedure TicqSession.parseStatus(const snac: RawByteString; ofs:integer; cont : TICQcontact; isInvis : Boolean = false; Status_changed : Boolean = False);
var
  newStatus:TICQstatus;
  newInvis:boolean;
  code:integer;
  i : Integer;
begin
if (not cont.isAIM) and (not existsTLV(6, snac,ofs)) then
  begin
   if cont.OnlineTime =0 then
    exit;
  end;

  cont.prevStatus  := cont.status;
  eventOldStatus   := cont.status;
  eventOldInvisible:= cont.invisible;
  i := findTLV($06, snac, ofs);
  if i > 0 then
    code := getTLVdwordBE(@snac[i])
   else
    code := 0;
  newStatus:=code2status(code);
  newInvis :=code and flag_invisible>0;

  cont.birthFlag := code and flag_birthday>0;

 if (cont.status = SC_OFFLINE)
  or (cont.invisibleState = 2) then
  begin
  cont.status:=newStatus;
  cont.invisible:=newInvis;
  if isInvis then
   begin
    if (newStatus <> eventOldStatus) or (newInvis<> eventOldInvisible) then
    begin
//    cont.status:=newStatus;
      cont.invisibleState := 2;
      eventContact := cont;
      notifyListeners(IE_statuschanged);
    end;
   end
  else
   begin
    cont.invisibleState := 0;
    eventContact := cont;
    notifyListeners(IE_oncoming);
   end;
  cont.lastTimeSeenOnline:=eventTime;
  end
else
  if (newStatus <> eventOldStatus) or (newInvis<> eventOldInvisible) then
    begin
    cont.status:=newStatus;
    cont.invisible:=newInvis;
    eventContact := cont;
    notifyListeners(IE_statuschanged);
    end
  else
   begin
     eventContact := cont;
     if Status_changed then
       notifyListeners(IE_statuschanged)
      else
       notifyListeners(IE_contactupdate);
   end;
end; // parseStatus

procedure TicqSession.parseOffgoingUser(const snac: RawByteString);
var
  ofs, l, t : Integer;
  TLVCnt, i : word;
  notMe : Boolean;
  s : RawByteString;
  cnt : TICQcontact;
begin
  eventFlags:=0;
  eventTime:=now;
  ofs:=1;
  l := Length(snac);
  while ofs < l-5 do
  begin
    cnt := getICQContact(getBUIN2(snac,ofs));
    notMe := True;//not isMyAcc(eventContact);
    if notMe and Assigned(cnt) then
      begin
        cnt.prevStatus:=cnt.status;
        eventOldStatus:=cnt.status;
        eventOldInvisible:=cnt.invisible;
        cnt.status:= SC_OFFLINE;
        cnt.invisible:=FALSE;

        with cnt do
         begin
//          capabilitiesBig:=[];
//          capabilitiesSm:=[];
//          capabilitiesXTraz := [];
//          extracapabilities:='';
         end;

         if (cnt.prevStatus <> cnt.status) then
          begin
            cnt.lastTimeSeenOnline:=eventTime;
            eventContact:= cnt;
            notifyListeners(IE_offgoing);
          end;
      end;
//    eventContact.warn
    inc(ofs, 2); // warning level (unused in ICQ)
    TLVCnt := readBEWORD(snac, ofs);
    t := ofs;
    i := 0;
    while (i < TLVCnt)and (t < l) do
     begin
  //    inc(t, 2);
  //    t := findTLV(5, snac,ofs);
      inc(t, word_BEat(snac, t+2) + 4);
      inc(i);
     end;
    s := Copy(snac, ofs, t-ofs);
    if (TLVCnt >= 2)and notMe and Assigned(cnt) then
//       parseOnlineInfo(s, 1, cnt, True);
//       parseOnlineInfo(s, 1, cnt, false, false);
       parseOnlineInfo(s, 1, cnt, false, True);
//    Delete(snac, ofs, t-ofs);
    ofs := t;
  end;
 {$IFDEF UseNotSSI}
{  if
    useSSI and useLSI and
    not eventContact.CntIsLocal
    and not eventContact.Authorized
    and (eventContact.prevStatus <> eventContact.status)
//   and existsTLV($1D, snac, ofs)
  then
    begin
//      eventFlags := 1;
      sendRemoveContact(eventContact.buin);
      sendAddContact(eventContact.buin);
    end;}
 {$ENDIF UseNotSSI}
end; // parseoffgoingUser

procedure TicqSession.parseContactsString(s: RawByteString);
var
  c:TICQcontact;
  vUID : TUID;
begin
eventContacts:=TRnQCList.create;
chop(#$FE,s);      // skippo il numero dei contatti
while s > '' do
  try
    vUID := chop(#$FE,s);
    c:=getICQContact(vUID);
    if c.equals(MyAccount) then
      chop(#$FE,s)
    else
     begin
          if not fRoster.exists(c) then
            c.nick:= UnUTF(chop(#$FE,s))
           else
            chop(#$FE,s);
      eventContacts.add(c);
     end;
  except
  end;
end; // parseContactsString

procedure TicqSession.parseAuthString(s: RawByteString);
var
  sU : String;
begin
 with eventContact do
  begin
    sU := UnUTF(chop(#$FE,s));
    if nick='' then
      nick := sU;
    sU := UnUTF(chop(#$FE,s));
    if first='' then
      first := sU;
    sU := UnUTF(chop(#$FE,s));
    if last='' then
      last := sU;
    sU := UnUTF(chop(#$FE,s));
    if email='' then
      email := sU;
  end;
 chop(#$FE,s);   // skip unknown char
//s := UTF8ToStrSmart(s);
// eventMsg:= unUTF(s);
 eventMsgA := s;
end; // parseAuthString

procedure TicqSession.notificationForMsg(msgtype: byte; flags: byte; urgent: boolean;
                              const msg: RawByteString{; offline:boolean = false});
var
  mm: RawByteString;
  strs : TAnsiStringDynArray;
begin
  if msgtype in MTYPE_AUTOMSGS then
  begin
    notifyListeners(IE_automsgreq);
    exit;
  end;
// sefg if msg='' then exit;
//eventFlags:=0;
  if flags and $80 > 0 then
    inc(eventFlags, IF_multiple);
  if flags and $40 > 0 then
    inc(eventFlags, IF_no_matter);
  if urgent then
    inc(eventFlags, IF_urgent);
//if offline then inc(eventFlags, IF_offline);
case msgtype of
  MTYPE_PLAIN:
    begin
      eventMsgA := msg;
      notifyListeners(IE_msg);
    end;
  MTYPE_URL:
    begin
      mm := msg;
      eventMsgA:=chop(#$FE,RawByteString(mm));
      eventAddress:=mm;
      notifyListeners(IE_url);
    end;
  MTYPE_CONTACTS:
    begin
      parseContactsString(msg);
      notifyListeners(IE_contacts);
    end;
  MTYPE_ADDED:
    begin
      parseAuthString(msg);
      notifyListeners(IE_addedYou);
    end;
  MTYPE_AUTHREQ:
    begin
      parseAuthString(msg);
      notifyListeners(IE_authReq);
    end;
  MTYPE_EEXPRESS:
    begin
      parsePagerString(msg);
      notifyListeners(IE_email);
    end;
  MTYPE_SERVER:
    begin
      parsePagerString(msg);
      notifyListeners(IE_fromMirabilis);
    end;
  MTYPE_WWP:
    begin
      parsePagerString(msg);
      notifyListeners(IE_webpager);
    end;
  MTYPE_STICKER:
    begin
      eventMsgA := msg;
      strs := SplitAnsiString(eventData, ':');
      if (length(strs) >= 4) then
        eventAddress := getStickerURL(strs[1], strs[3]);
      notifyListeners(IE_StickerMsg);
    end;
  MTYPE_CHAT:
    begin
      eventMsgA := msg;
      notifyListeners(IE_MultiChat);
    end;
  end;
end; // notificationForMsg

procedure TicqSession.parseGCdata(const snac: RawByteString; offline: boolean=FALSE);
var
  i, ll, ofs,v: integer;
  s: AnsiString;
begin
  if Length(snac) < 40 then
    Exit;

  ofs:=1;
  inc(ofs, 15);
  ll := dword_LEat(@snac[ofs]);
  inc(ofs, 4);
  i := dword_LEat(@snac[ofs]);
  inc(ofs, 4);

{  inc(ofs, 20);
if pos('Greeting Card', getDLS(snac, ofs))=0 then exit;
inc(ofs,3);}
v:= byte(snac[ofs]) shl 8 + Byte(snac[ofs+2]);  // get version
inc(ofs, i);
case v of
  $0100,             // 1.0 not tested
  $0101: inc(ofs,4);
  else //inc(ofs,12);    // for version 1.2+
  end;

  if v >= $3132 then
    eventNameA := getDLS(snac, ofs)
   else
    eventNameA := '';
  getDLS(snac,ofs);  // version
  getDLS(snac,ofs);  // theme
  if v < $3132 then
   begin
    s:='http://www.icq.americangreetings.com/icqorder.pd?mode=send';
    s:=s+'&pre_title='+str2url(getDLS(snac,ofs));
    s:=s+'&design='+str2url(getDLS(snac,ofs));
    s:=s+'&title='+str2url(getDLS(snac,ofs));
    s:=s+'&recipient='+str2url(getDLS(snac,ofs));
    s:=s+'&text='+str2url(getDLS(snac,ofs));
    s:=s+'&sender='+str2url(getDLS(snac,ofs));
    inc(ofs,4); // skip version
   end
  else
   begin
     getDLS(snac,ofs);  //title
     getDLS(snac,ofs); // recipient
     eventMsgA := getDLS(snac,ofs); // text
     getDLS(snac,ofs); // sender
    inc(ofs,4); // skip version
   end;
if v>=$3132 then
  eventAddress:=getDLS(snac,ofs)
else
  eventAddress:=s;
notifyListeners(IE_gcard);
end; // parseGCdata

procedure TicqSession.parseSRV_LOCATION_ERROR(const snac: RawByteString; ref: integer);
//var
//  i : Integer;
begin
{  i:=acks.findID(ref);
    if i>=0 then
     begin
    	with acks.getAt(i) do
       begin
        sendSNAC(ICQ_MSG_FAMILY, CLI_META_MSG, qword_LEasStr(SNACref)+#0#2
          +BUIN(uin)
           + word_BEasStr(5)+word_BEasStr($60)
//          +TLV(5, #0#0+//qword_LEasStr(SNACref)//+capability[1]
            + #0#0 + qword_LEasStr(0) + z+z+z+z
            +TLV($A,#0#1)
            +TLV($F,'')
//            +TLV($2711,
              + word_BEasStr($2711)+word_BEasStr($38)+
              header2711_2+//char(MTYPE_PLAIN)+flagChar+
              #$E8 + #03+
              word_LEasStr(getFullStatusCode)//  +priorityChar+#0
              +#00+#$21
              +#3+#0
              + #0 + #01 + #00 +#00 +#06 +#00+#00
//              +WNTS('')
//              +dword_LEasStr(0)+dword_LEasStr($FFFFFF)
//            )
//          )
        );
        acks.add(OE_msg, uin, 0, 'InvAll').ID := addRef(REF_msg,uin);
       end;
      acks.Delete(i);
     end;
}
  eventMsgID:=ref;
  if Length(snac) >= 2 then
    eventInt := word_BEat(@snac[1])
   else
    eventInt := 0; ;
//  eventError := ;
  eventFlags := IF_urgent;
//  event
  notifyListeners(IE_msgError);
end; // parseSRV_LOCATION_ERROR

procedure TicqSession.parseMsgError(const snac: RawByteString; ref: integer);
begin
  eventMsgID:=ref;
  eventInt:=word_BEat(@snac[1]);
  eventFlags := 0;
  notifyListeners(IE_msgError);
end; // parseMsgError

procedure TicqSession.parseServerAck(const snac: RawByteString; ref:integer);
var
  ofs:integer;
begin
  eventMsgID:=qword_LEat(@snac[1]);
  ofs:=11;
  eventContact:=getICQContact(getBUIN2(snac,ofs));
  notifyListeners(IE_serverAck);
end; // parseServerAck

procedure TicqSession.parseIncomingMsg(snac: RawByteString); // 0407
var
  t, i : Integer;
  ofs, ofs2, l, l2 : integer;
  isTzer: Boolean;
  isAutoMsg: Boolean;
  thisCnt : TICQcontact;
  CharsetNumber, CharsetSubset : Word;
  msgDwnCnt, TLVcnt : Word;
  CompressType : Word;
  priority, msgtype, msgflags, TypeId: byte;
  msgLen, origMsgLen, msgCRC, origMsgCRC: Cardinal;
//    buf, destBuf : TStringStream;
  buf, destBuf : TMemoryStream;
//    key : TAESKey256;
   key : array [0..31] of byte;
    MD5Digest  : TMD5Digest;
    MD5Context : TMD5Context;
   ctx : TAESContext;
   CrptMsg : RawByteString;
  PlugNameLen : longWord;
//  msgGUID : TGUID;
  Plugin : AnsiString;
  Cap : RawByteString;
//  bufStr : TMemoryStream;
  msgEnc, msg, sA : RawByteString;
// {$IFDEF UNICODE}
//  msgU : UnicodeString;
// {$ENDIF UNICODE}
  PlugName : AnsiString;
begin
  eventFlags := 0;
//  msgDwnCnt  := $FFFF;
  eventMsgID := qword_LEat(@snac[1]);
  ofs := 11;
  thisCnt := getICQContact(getBUIN2(snac,ofs));
  eventTime := now;
  inc(ofs, 2);
  TLVCnt := readBEWORD(snac, ofs);
  t := ofs;
  i := 0;
  l := Length(snac);
  while (i < TLVCnt)and (t < l) do
   begin
//    inc(t, 2);
//    t := findTLV(5, snac,ofs);
    inc(t, word_BEat(snac, t+2) + 4);
    inc(i);
   end;
  sA := Copy(snac, ofs, t-ofs);
  Delete(snac, ofs, t-ofs);
  isAutoMsg := existsTLV(04, sA);
//  ofs := 1;
  parseOnlineInfo(sA, 1, thisCnt, false);
  sA := '';

if thisCnt.typing.bIsTyping then
 begin
  thisCnt.typing.bIsTyping := false;
  eventContact := thisCnt;
  notifyListeners(IE_redraw);
 end;
case Byte(snac[10]) of // msg format
  1:begin // Simply(old-type) message
    if existsTLV($06, snac,ofs) then
     begin
      eventFlags := eventFlags or IF_offline;
      i := findTLV($16, snac,ofs);
      if i>0 then
//        eventTime:= UnixToDateTime(getTLVdwordBE(@snac[i])) + GMToffset0;
        eventTime:= UnixToDateTime(getTLVdwordBE(@snac[i])) + GMToffset;
     end;
    sA := getTLVSafe($02, snac, ofs);
    isTzer := false;
    if sA >= '' then
    begin
      isTzer := false;
      ofs2 := 1;
      t := Byte(sA[ofs2]);
      if t = $05 then
      begin
        inc(ofs2, 2);
        t := readBEWORD(sA, ofs2);
        cap := copy(sA, ofs2, min(16, t)); // first cap only, enough?
        if cap = BigCapability[CAPS_big_tZers].v then
          isTzer := True;

        inc(ofs2, t);
        if t < length(sA) then
          t := Byte(sA[ofs2]);
      end;
      if t = $10 then // Caps are required
       begin
         inc(ofs2, 2);
         t := readBEWORD(sA, ofs2);
         cap := copy(sA, ofs2, min(16, t)); // first cap only, enough?
         if cap = BigCapability[CAPS_big_tZers].v then
           isTzer := True;
         inc(ofs2, t);

        if t < length(sA) then
          t := Byte(sA[ofs2]);
       end;


      if t = $01 then
      begin
        inc(ofs2, 2);
        l := readBEWORD(sA, ofs2)-4;
        CharsetNumber := readBEWORD(sA, ofs2);     //The encoding used for the message.
                                                //0x0000: US-ASCII
                                                //0x0002: UCS-2BE (or UTF-16?)
                                                //0x0003: local 8bit encoding, eg iso-8859-1, cp-1257, cp-1251.
                                                //Beware that UCS-2BE will contain zero-bytes for characters in the US-ASCII range.
                                                // 0006 - Unicode
        CharsetSubset := readBEWORD(sA, ofs2);         //Unknown; seen: 0x0000 = 0, 0xffff = -1.
        msg := copy(sA, ofs2, l);
       if CharsetNumber = 6 then
         begin
           eventFlags := eventFlags or IF_Unicode;
         end
        else
       if CharsetNumber = 2 then
         begin
           eventFlags := eventFlags or IF_UTF8_TEXT;
           msg := WideBEToUTF8(msg);
         end
        ;

    end;

    sA := getTLVSafe($24, snac, ofs); // MSG-GUID

    sA := getTLVSafe($32, snac, ofs); // Original Sender
    if sA > '' then
    begin
        // MultiChatMsg
           eventContact := thisCnt;
           eventAddress := sA; // Original Sender
           eventMsgA := msg;
           notificationForMsg(MTYPE_CHAT, eventFlags, TRUE, eventMsgA);
           exit;
    end;

    sA := getTLVSafe($31, snac, ofs);
    if (sA > '') then
      begin
        eventMsgA := msg;
        eventData := sA;
        msg := '';
        eventContact := thisCnt;
        notificationForMsg(MTYPE_STICKER, eventFlags, TRUE, eventMsgA);
        exit;
      end
     else
       if isTzer then
         begin
           eventAddress := parseTzer2URL(msg, eventMsgA);
           notificationForMsg(MTYPE_PLAIN, eventFlags, TRUE, eventMsgA);
           Exit;
         end;

//    if CharsetNumber = 2 then
//      msg := UnWideStr(msg);
//    {$IFDEF UNICODE}
//     notificationForMsgW(MTYPE_PLAIN, eventFlags,TRUE,msgU);
//    {$ELSE nonUNICODE}
      begin
       eventContact := thisCnt;
       notificationForMsg(MTYPE_PLAIN, eventFlags, TRUE, msg);
      end;
//    {$ENDIF UNICODE}
      end;

    end;
  2:begin //Advanced(new-type)
//    i := findTLV(5, snac,ofs);
//    inc(i, word_BEat(snac, i+2) + 4);
//    if existsTLV(5, snac,i) then
//      begin
//       eventContact.memberSince:= UnixToDateTime(getTLVdwordBE(5, snac,ofs));
////       getTLV(5, snac, i)
//       ofs:=findTLV(5, snac,i)+4
//      end
//     else
      ofs:=findTLV(5, snac,ofs)+4;
    case Byte(snac[ofs+1]) of
      1:begin
         eventContact := thisCnt;
         notifyListeners(IE_fileabort);
         exit;
        end;
      2:begin
//        notifyListeners(IE_fileack);
        exit;
        end;
      end;
    inc(ofs, 2+8);
    Cap := copy(Snac, ofs, 16);
    inc(ofs, 16);
    i := findTLV($04, snac,ofs);
    if i>0 then
      thisCnt.connection.ip:=getTLVdwordBE(@snac[i]);
    i := findTLV($05, snac,ofs);
    if i>0 then
      thisCnt.connection.port:=getTLVwordBE(@snac[i]);
    if existsTLV($06, snac,ofs) then
     begin
      i := findTLV($16, snac,ofs);
      if i>0 then
        eventTime:= UnixToDateTime(getTLVdwordBE(@snac[i])) + GMToffset0;
     end;
    if Cap = BigCapability[CAPS_big_Buzz].v then
    begin
      eventContact := thisCnt;
      notifyListeners(IE_buzz);
      Exit;
    end
    else if Cap = BigCapability[CAPS_big_Chat].v then
    begin
      i := findTLV($0A, snac, ofs);
      t := 0;
      if i > 0 then
        t := getTLVwordBE(@snac[i]);

      sA := getTLVSafe($0D, snac, ofs);
      msgEnc := getTLVSafe($2711, snac, ofs);

      if sA = 'utf-8' then
        msg := unUTF(msgEnc)
      else if sA = 'us-ascii' then
        msg := msgEnc
      else // unknown codepage
        msg := unUTF(msgEnc);

      // msg ~ aol://2719:10-4-chat1245382434654977163
      // What to do with this group chatroom?
    end else
    if Cap = CAPS_sm2big(CAPS_sm_FILE_TRANSFER) then
     begin
       msgEnc := getTLVSafe($0D, snac, ofs);
       msg := getTLVSafe($0C, snac, ofs);
       eventMsgA := msg;
       sA := getTLVSafe($03, snac, ofs);
       if sA > '' then
         thisCnt.connection.internal_ip := dword_BEat(@sA[1])
        else
         thisCnt.connection.internal_ip := 0;
       thisCnt.connection.ft_port := thisCnt.connection.port;

       sA := getTLVSafe($2712, snac, ofs);

    {$IFDEF usesDC}
       eventDirect := NIL;
       i := findTLV($0A, snac, ofs);
       t := 0;
       if i > 0 then
        t := getTLVwordBE(@snac[i]);
       if t=1 then // First request
        begin
          eventDirect := directTo(thisCnt);
          eventDirect.eventID := eventMsgID;
          eventDirect.kind    := DK_file;
//          eventDirect.fileName := ;
          eventDirect.imSender := False;
          eventDirect.mode := dm_bin_direct;
          eventDirect.fileCntTotal := 1;
          eventDirect.fileDesc := unUTF(eventMsgA);//getTLVSafe($0C, snac, ofs);
//          eventDirect.fileDesc := '';
          eventDirect.stage := 1;
//    {$ENDIF usesDC}

           if findTLV($2711, snac, ofs)>0 then
           if eventDirect <> NIL then
            begin
             msg := getTLVSafe($2711, snac, ofs);
             i := word_BEat(msg, 1);
             if i = 1 then
               CrptMsg := copy(msg, 9, length(msg) -9)
              else
               CrptMsg := '';
             if sA = 'utf-8' then
               eventDirect.fileName := unUTF(CrptMsg)
              else
             if sA = 'us-ascii' then
               eventDirect.fileName := CrptMsg
              else // unknown codepage
               eventDirect.fileName := unUTF(CrptMsg)
//               eventDirect.fileName := CrptMsg
               ;
    //          else
    //           if s = 'Unicode'
               ;
             eventDirect.fileSizeTotal  := dword_BEat(@msg[5]);
            end;
//    {$IFDEF usesDC}
        end
       else
       if t > 1 then
        begin
         eventDirect := TICQdirect(directs.findID(eventMsgID));
        end;
       i := findTLV($10, snac,ofs);
        if Assigned(eventDirect) then
           if i>0 then
             begin
               i := findTLV($02, snac,ofs);
               eventDirect.stage := t;
               if i > 0 then
                 eventDirect.AOLProxy.ip := getTLVdwordBE(@snac[i]);
               i := findTLV($05, snac,ofs);
               if i > 0 then
                 eventDirect.AOLProxy.port := getTLVwordBE(@snac[i]);
               if t>1 then
               begin
                 if eventDirect.mode <> dm_bin_proxy then
                  begin
                    if eventDirect.imSender then
                      begin
                       if messageDlg(getTranslation('Do you want to send files through server?'), mtConfirmation, [mbYes,mbNo],0, mbYes, 20) = mrYes then
                         eventDirect.mode := dm_bin_proxy
                        else
                         sendFileAbort(TICQcontact(eventDirect.contact), eventDirect.eventID);
                      end
                     else
                       if messageDlg(getTranslation('Do you want to receive files through server?'), mtConfirmation, [mbYes,mbNo],0, mbYes, 20) = mrYes then
                         eventDirect.mode := dm_bin_proxy
                        else
                         sendFileAbort(TICQcontact(eventDirect.contact), eventDirect.eventID);
                  end;
                 if eventDirect.mode = dm_bin_proxy then
  //               if (eventDirect.imSender and (t=3))or
                 if ((t=3))or
                    (not eventDirect.imSender  and (t=2)) then //
                  begin
                   eventDirect.connect2proxy;
                  end;
                 exit;
               end
               else
                eventDirect.mode := dm_bin_proxy;
             end
          else
           if t=2 then
             if eventDirect.imSender then
              begin
               if thisCnt.connection.internal_ip > 0 then
                 begin
                   eventDirect.P_host := dword_LE2ip(thisCnt.connection.internal_ip);
                   eventDirect.P_port := IntToStrA(thisCnt.connection.ft_port);
                   eventDirect.stage  := 2;
                   eventDirect.imserver := false;
                   eventDirect.connect;
                 end
                else
                 begin
                   i := findTLV($02, snac,ofs);
                   eventDirect.AOLProxy.ip := $FFFFFFFF;
                   if i > 0 then
                     eventDirect.AOLProxy.ip := getTLVdwordBE(@snac[i]);
                   if eventDirect.AOLProxy.ip = 0 then
                    begin
                     if messageDlg(getTranslation('Do you want to send files through server?'), mtConfirmation, [mbYes,mbNo],0, mbYes, 20) = mrYes then
                      begin
                       eventDirect.stage := 3;
                       eventDirect.mode := dm_bin_proxy;
                       eventDirect.connect2proxy;
                      end
                     else
                      sendFileAbort(TICQcontact(eventDirect.contact), eventDirect.eventID);
                    end;
                 end;
               Exit;
              end;
{       s := getTLVSafe($05, snac, ofs);
       if s > '' then
         eventContact.ft_port := word_LEat(@s[1])
        else
         eventContact.ft_port := 0;
}
//       i := findTLV($10, snac,ofs);
//       if i>0 then
//         eventContact.connection.proxy_ip := getTLVdwordBE(@snac[i]);
//       s := getTLVSafe($2711, snac, ofs);
//       debug_Snac(snac, 'FileTransfer.snacs.txt');
//            if eventFilename > '' then
           eventContact := thisCnt;
           if Assigned(eventDirect) then
              if eventDirect.imSender then
//                notifyListeners(IE_fileack)
               else
                notifyListeners(IE_filereq)
            else
             if (eventMsgID <= maxRefs)and (eventMsgID >= 1) then
              if refs[eventMsgID].kind = REF_file then
                notifyListeners(IE_fileok);
    {$ENDIF usesDC}
     end
    else
    if Cap = BigCapability[CAPS_big_CryptMsg].v then
     begin
      ofs:=findTLV($2711, snac,ofs)+4;
      msgDwnCnt := word_LEat(@snac[ofs]);
      msgDwnCnt := word_LEat(@snac[ofs + msgDwnCnt]);
      inc(ofs, byte(snac[ofs])+2);
      inc(ofs, byte(snac[ofs])+2);
  //    priority := ord(snac[ofs+4]);
  //  if Length(snac) < 7 then
  //   exit;
      msgtype:=byte(snac[ofs]);
      msgflags:=byte(snac[ofs+1]);
      priority:=byte(snac[ofs+4]);
      inc(ofs,6);
      msg:=getWNTS(snac, ofs);

       origMsgLen := cardinal( readDWORD(snac, ofs));
       origMsgCRC := readDWORD(snac, ofs);
       CompressType := readWORD(snac, ofs);
       if not (CompressType in [0,1]) then
         msg := getTranslation('R&Q error: Unknown type of compress [%d]', [CompressType])
       else
       begin
         eventFlags := eventFlags or IF_Encrypt;
         CrptMsg := Base64DecodeString(msg);

         sA := IntToHexA(eventMsgID, 2);
         FillChar(MD5Digest, sizeOf(TMD5Digest), 0);
         MD5Init(MD5Context);
         MD5UpdateBuffer(MD5Context, PByte(sa), length(sa));
         MD5UpdateBuffer(MD5Context, PByte(not2Translate[2]), length(not2Translate[2]));
         sA := thisCnt.UID2cmp;
         MD5UpdateBuffer(MD5Context, PByte(sa), length(sa));
         MD5UpdateBuffer(MD5Context, PAnsiChar(AIM_MD5_STRING), length(AIM_MD5_STRING));
         MD5Final(MD5Digest, MD5Context);
         for I := 0 to 15 do
          Key[i] := Byte(MD5Digest[I]);

         sA := IntToHexA(origMsgLen, 2);
         FillChar(MD5Digest, sizeOf(TMD5Digest), 0);
         MD5Init(MD5Context);
         MD5UpdateBuffer(MD5Context, PByte(sa), length(sa));
         MD5UpdateBuffer(MD5Context, PByte(not2Translate[2]), length(not2Translate[2]));
         sA := MyAccount;
         MD5UpdateBuffer(MD5Context, PByte(sa), length(sa));
         MD5UpdateBuffer(MD5Context, PAnsiChar(AIM_MD5_STRING), length(AIM_MD5_STRING));
         MD5Final(MD5Digest, MD5Context);
         for I := 0 to 15 do
          Key[i+16] := Byte(MD5Digest[I]);
{
         sA := MD5Pass(RawByteString(IntToHexA(eventMsgID, 2)) + not2Translate[2] + RawByteString(thisCnt.UID2cmp) + AIM_MD5_STRING);
         for I := 1 to 16 do
          Key[i-1] := Byte(sA[I]);

         sA := MD5Pass(RawByteString(IntToHexA(origMsgLen, 2)) + not2Translate[2] + RawByteString(MyAccount) + AIM_MD5_STRING);
         for I := 1 to 16 do
          Key[i+15] := Byte(sA[I]);
}
{         buf := TStringStream.Create(msg);
          destBuf := TStringStream.Create('');
          if buf.Size mod SizeOf(TAESBuffer) > 0 then
            buf.Size := buf.Size + SizeOf(TAESBuffer) - buf.Size mod SizeOf(TAESBuffer);
          DecryptAESStreamECB(buf, 0, key, destBuf);
          msg := destBuf.DataString; //destBuf.ReadString(Length( OrigMemo.Text));
}
         AES_ECB_Init_Decr(key, 256, ctx);
         i := Length(CrptMsg);
         SetLength(Msg, i+AESBLKSIZE);
         AES_ECB_Decrypt(@CrptMsg[1], @msg[1], i, ctx);

         setLength(msg, origMsgLen);
//          buf.Free;
//          destBuf.Free;
         if CompressType = 1 then
           begin
//             msg := ZDecompressStrEx(msg);
             Buf := TMemoryStream.create;
             destBuf := TMemoryStream.create;
             buf.Write(msg[5], origMsgLen);
             buf.Position := 0;
             ZlibDecompressStream(buf, destBuf);
             buf.free;
      //       Msg2Send :=  ZCompressStrEx(msg, clMax);
      //       if Length(Msg2Send) < Len then
             setLength(msg, destBuf.Size);
             destBuf.Position := 0;
             CopyMemory(@msg[1], destBuf.Memory, destBuf.Size);
             destBuf.free;
           end;
          if Length(msg) > 0 then
           begin
            msgCRC := (ZipCrc32($FFFFFFFF, @msg[1], origMsgLen)XOR $FFFFFFFF);
            if msgCRC <> origMsgCRC then
              msg := getTranslation('R&Q error: Could''t decrypt message. Bad CRC.\n[%s]', [msg]);
           end;
          eventContact := thisCnt;
          notificationForMsg(msgtype, msgflags, priority=2, msg);

          case getStatus of
            byte(SC_away): sendACK(thisCnt, ACK_AWAY,'');
            byte(SC_na): sendACK(thisCnt, ACK_NA,'');
            byte(SC_dnd), byte(SC_occupied): if priority=2 then
                                               sendACK(thisCnt, ACK_OK, '', msgDwnCnt)
                                              else
                                               sendACK(thisCnt, ACK_NOBLINK,'')
            else sendACK(thisCnt, ACK_OK, '', msgDwnCnt)
          end;
        end;
     end
(*    else
    if Cap = BigCapability[CAPS_big_QIP_SEQURE].v then
     begin
      ofs:=findTLV($2711, snac,ofs)+4;
      msgDwnCnt := word_LEat(@snac[ofs]);
      msgDwnCnt := word_LEat(@snac[ofs + msgDwnCnt]);
      inc(ofs, Byte(snac[ofs])+2);
      inc(ofs, Byte(snac[ofs])+2);
  //    priority := ord(snac[ofs+4]);
  //  if Length(snac) < 7 then
  //   exit;
      msgtype := Byte(snac[ofs]);
      msgflags:= Byte(snac[ofs+1]);
      priority:= Byte(snac[ofs+4]);
      inc(ofs,6);

      msg:=getWNTS(snac, ofs);

{      if  then
         msg := getTranslation('R&Q error: Unknown type of compress [%d]', [CompressType])
       else
       begin
         eventFlags := eventFlags or IF_Encrypt;
//         CrptMsg := Base64DecodeString(msg);
         msg := qip_msg_decr(msg);
       end}
     end*)
    else
    if Cap = CAPS_sm2big(CAPS_sm_ICQSERVERRELAY) then
     begin
      ofs:=findTLV($2711, snac,ofs)+4;
      msgDwnCnt := word_LEat(@snac[ofs]);
      msgDwnCnt := word_LEat(@snac[ofs + msgDwnCnt]);
      inc(ofs, Byte(snac[ofs])+2);
      inc(ofs, Byte(snac[ofs])+2);
  //    priority := ord(snac[ofs+4]);
  //  if Length(snac) < 7 then
  //   exit;
      msgtype := Byte(snac[ofs]);
      msgflags:= Byte(snac[ofs+1]);
      priority:= Byte(snac[ofs+4]);
      inc(ofs,6);

      msg:=getWNTS(snac, ofs);

    if msgtype = MTYPE_PLAIN then
     if (ofs + 12) < Length(snac) then
     try
       readINT(snac, ofs); // FG
       readINT(snac, ofs); // BG
       PlugNameLen := readINT(snac, ofs);
       PlugName := copy(snac, ofs, PlugNameLen);
       inc(ofs, PlugNameLen);
//       msgGUID := StringToGUID(PlugName);
//       if GUIDToString(msgQIPpass) = PlugName then
       if SameText(msgQIPpassStr, PlugName) then
         begin
           eventflags := eventflags or IF_Encrypt;
           if thisCnt.crypt.qippwd > 0 then
             msg := qip_msg_decr(msg, thisCnt.crypt.qippwd)
            else
             msg := getTranslation('R&Q error: Could''t decrypt message. Need password.\n[%s]', [msg]);
         end;
{       if IsEqualGUID(msgGUID, msgRTF) then
        begin
          msg := RtfToHtml(msg);
        end;}
     except

     end;
    // for now we are not able to manage filetransfers
//    if msgtype = MTYPE_FILEREQ then
//      begin
//      sendACK(ACK_FILEDENY, 'sorry, i''m not able to receive file at the moment', snac);
//      exit;
//      end;
    eventContact := thisCnt;
      if dontBotherStatus and ((priority = 1) or (msgtype in MTYPE_AUTOMSGS))
        and (msgtype <> MTYPE_FILEREQ) AND (msgtype <> MTYPE_PLUGIN) then
        begin
         case getStatus of
          byte(SC_dnd): sendACK(thisCnt, ACK_DND,'', msgDwnCnt);
          byte(SC_occupied): sendACK(thisCnt, ACK_OCCUPIED,'', msgDwnCnt);
         end;
         notificationForMsg(msgtype, msgflags or $40, false, msg);
        exit;
        end;
      // here we can be bothered :P
{      if msgtype=MTYPE_FILEREQ then
        begin
        thisCnt.connection.ft_port:=word_BEat(@snac[ofs]);
        inc(ofs, 4);
        eventFilename:=getWNTS(snac, ofs);
        eventInt:=dword_LEat(@snac[ofs]);
  //      if eventFilename > '' then
  //        notifyListeners(IE_filereq)
  //      else
          if refs[eventMsgID].kind = REF_file then
            notifyListeners(IE_fileok);
        exit;
        end
      else}
      if msgtype=MTYPE_PLUGIN then
       begin
  //        debug_Snac(snac, 'FileSend.snac');
         inc(ofs, 2);
         Plugin := copy(snac, ofs, 16);
         inc(ofs, 16); inc(ofs, 2);
//         PlugNameLen := dword_LEat(@snac[ofs]); inc(ofs, 4);
         PlugNameLen := readINT(snac, ofs);
         PlugName := copy(snac, ofs, PlugNameLen);
         inc(ofs, PlugNameLen);
         TypeId := TypeStringToTypeId(PlugName);
           if TypeId = MTYPE_FILEREQ then
           begin
             inc(ofs, 19);
            eventMsgA := getWNTS(snac, ofs);
            thisCnt.connection.ft_port := word_BEat(@snac[ofs]);
            inc(ofs, 2);
//            FFSeq2 := word_BEat(@snac[ofs]);
            inc(ofs, 2);
            eventDirect.fileName := getWNTS(snac, ofs);
            eventDirect.fileSizeTotal := dword_LEat(@snac[ofs]);
            inc(ofs, 4);
            if eventDirect.fileName > '' then
              notifyListeners(IE_filereq)
            else
             if (eventMsgID <= maxRefs)and (eventMsgID >= 1) then
              if refs[eventMsgID].kind = REF_file then
                notifyListeners(IE_fileok);
           end
           else if TypeId in [MTYPE_PLAIN, MTYPE_AUTOAWAY] then
            begin
              inc(ofs, 6);
              inc(ofs, 9);
  //            len := dword_LEat(@snac[ofs]);
              inc(ofs, 4);

              msglen := dword_LEat(@snac[ofs]);
              inc(ofs, 4);
              msg := copy(snac,ofs,msglen);
              notificationForMsg(TypeId, msgflags, priority=2, msg);

            end
           else if TypeId = MTYPE_XSTATUS then
            begin
              notifyListeners(IE_XStatusReq);
//              if UseOldXSt then
                sendMyXStatus(thisCnt, eventMsgID);
              exit;
            end
  //        else if TypeId =
  {                  Inc(Pkt^.Len, 19);
                    fDesc := GetDWStr(Pkt);
                    aPort := GetInt(Pkt, 2);
                    FFSeq2:= GetInt(Pkt, 2);
                    fName := GetWStr(Pkt);
                    fSize := GetInt(Pkt, 4);
  }        else if TypeId = MTYPE_GCARD then
            parseGCdata( copy(snac, ofs, length(snac)) )

         //(cap = MsgCapabilities[1]))
  //       Capabs := copy(msg, MsgOfs, 4);
       end
      else
  //     if msgtype =  then
       begin
        eventContact := thisCnt;
        notificationForMsg(msgtype, msgflags, priority=2, msg);
       end;

      case getStatus of
        byte(SC_away): sendACK(thisCnt, ACK_AWAY,'');
        byte(SC_na): sendACK(thisCnt, ACK_NA,'');
        byte(SC_dnd), byte(SC_occupied): if priority=2 then
                                           sendACK(thisCnt, ACK_OK, '', msgDwnCnt)
                                          else
                                           sendACK(thisCnt, ACK_NOBLINK,'')
        else sendACK(thisCnt, ACK_OK, '', msgDwnCnt)
      end;
    end;
  end;
  4:begin
      ofs := findTLV(5, snac, ofs);
      if ofs >= 0 then
      begin
        msg := ptrWNTS(@snac[ofs+10]);
        msgtype := Byte(snac[ofs+8]);
        eventContact := thisCnt;
        if msgtype=MTYPE_PLUGIN then
          parseGCdata( copy(snac, ofs+4+6+3+length(msg), length(snac)) )
         else
          notificationForMsg(msgtype, Byte(snac[ofs+9]), not dontBotherStatus, msg);
      end;
    end;
  end; // case
end; // parseincomingMsg

procedure TicqSession.parsePagerString(s: RawByteString);
begin
  eventNameA := chop(#$FE,s);
  chop(#$FE,s);
  chop(#$FE,s);
  eventAddress := chop(#$FE,s);
  chop(#$FE,s);
  eventMsgA := s;
end; // parsePagerString

procedure TicqSession.parseAuthReq(const pkt: RawByteString);
var
  ofs : Integer;
  uin : TUID;
//  Some : String;
begin
  ofs := 1;
//  Some := getBEWNTS(pkt, ofs);
  UIN  := getBUIN2(pkt, ofs);
  eventContact := getICQContact(UIN);
  eventTime := now;
//  contactsDB.get(UIN).
  eventMsgA := getBEWNTS(pkt, ofs);
//  icq.eventFlags
  notifyListeners(IE_authReq);
end;


procedure TicqSession.parse1503(const snac: RawByteString; ref:integer; flags : word);
var
  ofs:integer;

  procedure extractWP;
  var
    next:integer;
  begin
    next:=readWORD(snac, ofs);
    inc(next,ofs);
    eventwp.uin    := Int2UID(readINT(snac, ofs));
    eventwp.nick   := UnUTF(getWNTS(snac, ofs));
    eventwp.first  := UnUTF(getWNTS(snac, ofs));
    eventwp.last   := UnUTF(getWNTS(snac, ofs));
    eventwp.email  := UnUTF(getWNTS(snac, ofs));
    eventwp.authRequired:=readBYTE(snac, ofs)=0;
    eventwp.status := readWORD(snac, ofs);
    eventWP.gender := readBYTE(snac, ofs);
    eventWP.age := readWORD(snac, ofs);
    eventWP.bday := 0;
     try
       inc(ofs, 3);
//       eventWP.BaseID := getWNTS(snac, ofs); //The base ID. (ðàìáëåð, áèãìèð, àòëàñ ...)
      except
     end;
    ofs:=next;

    // request issued from white pages
    if wasUINwp or (refs[ref].kind = REF_wp) then
      begin
      notifyListeners(IE_wpResult);
      exit;
      end;

    // request issued for internal use
    eventContact:= getICQContact(eventWP.uin);
    with eventContact do
     begin
      nick:=eventwp.nick;
      first:=eventwp.first;
      last:=eventwp.last;
      email:=eventwp.email;
      notifyListeners(IE_userinfo);
     end;
  end; // extractWP

  procedure extractWP_CP;
  var
    s : RawByteString;
    Pkt1, Pkt2 : RawByteString;
    isExstsTLV : Boolean;
    t, i, k, ofs1, code : Integer;
    t64 : Int64;
    sU, PhoneNum, PhoneCnt : String;
    cnt : TICQcontact;
  begin
    eventwp.uin    := getTLVSafe(META_COMPAD_UID, snac, ofs);
    if eventwp.uin > '' then
    begin
      eventwp.nick   := unUTF( getTLVSafe(META_COMPAD_NICK, snac, ofs) );
      eventwp.first  := unUTF( getTLVSafe(META_COMPAD_FNAME, snac, ofs) );
      eventwp.last   := unUTF( getTLVSafe(META_COMPAD_LNAME, snac, ofs) );
      eventwp.email  := unUTF( getTLVSafe(META_COMPAD_EMAIL, snac, ofs));
      eventwp.authRequired:= getTLVSafe(META_COMPAD_AUTH, snac, ofs) = #1;// readBYTE(snac, ofs)=0;

      eventwp.status := 00; //readWORD(snac, ofs);
      s := getTLVSafe(META_COMPAD_STATUS, snac, ofs);
      if Length(s) = 2 then
        eventwp.status := word_LEat(Pointer(s));

      eventWP.gender := 0;
      s := getTLVSafe(META_COMPAD_GENDER, snac, ofs);
      if s > '' then
        eventWP.gender := Byte(s[1]);

      Int64((@eventWP.bday)^)   := getTLVqwordBE(META_COMPAD_BDAY, snac, ofs);
      if eventWP.bday > 0 then
        begin
          eventWP.bday := eventWP.bday + 2;
          eventWP.age  := YearsBetween(now, eventWP.bday)
        end
       else
        eventWP.age := 00; //getTLVSafe(snac, ofs);
      eventWP.StsMSG := unUTF( getTLVSafe(META_COMPAD_STS_MSG, snac, ofs) );
      if wasUINwp or (refs[ref].kind = REF_wp) then
        begin
        notifyListeners(IE_wpResult);
        exit;
        end;
      // request issued for internal use (Get status string)
//      eventContact:=
      cnt := getICQContact(eventWP.uin);
      if Assigned(cnt) then
      with cnt do
       begin
         infoUpdatedTo := now;
        nick := eventwp.nick;
        first := eventwp.first;
        last := eventwp.last;
        email := eventwp.email;
        ICQ6Status := eventwp.StsMSG;
        birth := eventWP.bday;
        gender := eventWP.gender;
        s := getTLVSafe(META_COMPAD_LANG1, snac, ofs);
        if Length(s) >=2 then
          cnt.lang[1] := word_BEat(Pointer(s))
         else
          cnt.lang[1] := 0;
        s := getTLVSafe(META_COMPAD_LANG2, snac, ofs);
        if Length(s) >=2 then
          cnt.lang[2] := word_BEat(Pointer(s))
         else
          cnt.lang[2] := 0;
        s := getTLVSafe(META_COMPAD_LANG3, snac, ofs);
        if Length(s) >=2 then
          cnt.lang[3] := word_BEat(Pointer(s))
         else
          cnt.lang[3] := 0;
        about := UnUTF(getTLVSafe(META_COMPAD_ABOUT, snac, ofs));
//        Pkt1 := getTLVSafe(META_COMPAD_Mails, snac, ofs);

        isExstsTLV := existsTLV(META_COMPAD_HOMES, snac, ofs);
        Pkt1 := getTLVSafe(META_COMPAD_HOMES, snac, ofs);
         Pkt1 := getTLVSafe(1, Pkt1);
          if pkt1 <> '' then
           begin
            city  := unUTF(getTLVSafe(META_COMPAD_HOMES_CITY, Pkt1));
            state := unUTF(getTLVSafe(META_COMPAD_HOMES_STATE, Pkt1));
            s := getTLVSafe(META_COMPAD_HOMES_COUNTRY, Pkt1);
            if s <> '' then
              country := dword_BEat(Pointer(s));
           end;

        Pkt1 := getTLVSafe(META_COMPAD_FROM, snac, ofs);
         Pkt1 := getTLVSafe(1, Pkt1);
          if pkt1 <> '' then
           begin
            birthcity  := unUTF(getTLVSafe(META_COMPAD_FROM_CITY, Pkt1));
            birthstate := unUTF(getTLVSafe(META_COMPAD_FROM_STATE, Pkt1));
            s := getTLVSafe(META_COMPAD_FROM_COUNTRY, Pkt1);
            if s <> '' then
              birthCountry := dword_BEat(@s[1]);
           end
             else
           if isExstsTLV then
            begin
              birthcity    := '';
              birthstate   := '';
              birthCountry := 0;
           end;

         Pkt1 := getTLVSafe(META_COMPAD_PHONES, snac, ofs);
         if (Pkt1 > '') and (Length(Pkt1) > 3) then
         begin
           t := word_BEat(Pkt1, 1);
           ofs1 := 3;
           if t > 0 then
           for i := 1 to t do
           begin
             Pkt2 := getBEWNTS(Pkt1, ofs1);
             PhoneNum := UnUTF(getTLVSafe(META_COMPAD_PHONES_NUM, Pkt2, 1));
             PhoneCnt := getTLVSafe(META_COMPAD_PHONES_CNT, Pkt2, 1);
             if Length(PhoneCnt) >= 2 then
               code := word_BEat(PhoneCnt, 1)
             else
               code := 0;
             case code of
               1: regular := PhoneNum;
               2: workphone := PhoneNum;
               3: cellular := PhoneNum;
             end;
           end;
         end
           else
         begin
           regular := '';
           workphone := '';
           cellular := unUTF(getTLVSafe(META_COMPAD_MOBILE, snac, ofs));
         end;

        homepage := getTLVSafe(META_COMPAD_HP, snac, ofs);

        MarStatus := $00;
        s := getTLVSafe(META_COMPAD_MARITAL_STATUS, snac, ofs);
        if s > '' then
          MarStatus := word_BEat(@s[1]);

        isExstsTLV := existsTLV(META_COMPAD_WORKS, snac, ofs);
        Pkt1 := getTLVSafe(META_COMPAD_WORKS, snac, ofs);
         Pkt1 := getTLVSafe(1, Pkt1);
          if pkt1 <> '' then
           begin
            workpage  := unUTF(getTLVSafe(META_COMPAD_WORKS_PAGE, Pkt1));
            workPos   := unUTF(getTLVSafe(META_COMPAD_WORKS_POSITION, Pkt1));
            workCompany := unUTF(getTLVSafe(META_COMPAD_WORKS_ORG, Pkt1));
            workaddress := unUTF(getTLVSafe(META_COMPAD_WORKS_ADDRESS, Pkt1));
            workcity  := unUTF(getTLVSafe(META_COMPAD_WORKS_CITY, Pkt1));
            workstate := unUTF(getTLVSafe(META_COMPAD_WORKS_STATE, Pkt1));
            workDep     := unUTF(getTLVSafe(META_COMPAD_WORKS_DEPT, Pkt1));
            workZip   := unUTF(getTLVSafe(META_COMPAD_WORKS_ZIP, Pkt1));
            //workphone := '';
            workfax := '';
            s := getTLVSafe(META_COMPAD_WORKS_COUNTRY, Pkt1);
            if s <> '' then
              workCountry := dword_BEat(Pointer(s));
           end
          else
           if isExstsTLV then
            begin
              workpage    := '';
              workPos     := '';
              workCompany := '';
              workaddress := '';
              workcity    := '';
              workstate   := '';
              workDep     := '';
              //workphone := '';
              workfax := '';
              workCountry := 0;
           end;

        isExstsTLV := existsTLV(META_COMPAD_INTERESTs, snac, ofs);
        Pkt1 := getTLVSafe(META_COMPAD_INTERESTs, snac, ofs);
         if Length(Pkt1) >= 2 then
         begin
          k := word_BEat(Pointer(Pkt1));
          if k = 0 then
            cnt.clearInterests
          else
          if (k >0)and(k <=4) then
           begin
             cnt.interests.Count := k;
             ofs1 := 3;
             for I := 1 to k do
              begin
                Pkt2 := getBEWNTS(Pkt1, ofs1);
                s := getTLVSafe(META_COMPAD_INTEREST_ID, Pkt2, 1);
                 if Length(s) >= 2 then
                   code := word_BEat(Pointer(s))
                  else
                   code := 0;
                 s := getTLVSafe(META_COMPAD_INTEREST_TEXT, Pkt2, 1);
                 sU := UnUTF(s);
                cnt.AddInterest(i-1, code, sU);
              end;
           end
           else
           if isExstsTLV then
            begin
              cnt.clearInterests;
           end;
         end;
        Pkt1 := getTLVSafe(META_COMPAD_INFO_CHG, snac, ofs);
        if Length(Pkt1) = 8 then
          begin
//            t64 := qword_LEat(@Pkt1[1]);
//            Qword_BEat
//            t64 := Qword_BEat(@Pkt1[1]);
//            cnt.lastInfoUpdate := Tdatetime(t64)+GMToffset;
            Int64((@cnt.lastInfoUpdate)^)   := Qword_BEat(Pointer(Pkt1));
          end;
        Pkt1 := getTLVSafe(META_COMPAD_GMT, snac, ofs);
        if Length(Pkt1) = 2 then
          cnt.GMThalfs := SmallInt(word_BEat(Pointer(Pkt1)));

//        eventContact.gender := getTLVSafe(META_COMPAD_GENDER, snac, ofs)
        if cnt.equals(MyAccount) then
         begin
          showInfo := getTLVwordBE(META_COMPAD_INFO_SHOW, snac, ofs);
           s := getTLVSafe(META_COMPAD_WEBAWARE, snac, ofs);
           if Length(s) >= 1 then
             P_webaware := Byte(s[1]) = 1;
         end;
        eventContact := cnt;
        notifyListeners(IE_userinfoCP);
       end;
    end;
  end;


var
  d,m:byte;
  i : byte;
  msgtype,msgflags:byte;
  ReplyType, replySubtype : Word;
  y:word;
  msg: RawByteString;

  cont : TICQContact;
//  msgU,
  sU : String;
  OldNick : String;
  cntUID : TUID;
begin
  eventFlags := 0;
  cntUID := refs[ref].uid;
  if cntUID > '' then
    cont := getICQContact(cntUID)
   else
    cont := NIL;
  eventTime := now;
  ofs := 1;
  readBEWORD(snac, ofs); // TLV.Type(1) - encapsulated META_DATA
  readBEWORD(snac, ofs); // TLV.Length
  readWORD(snac, ofs);   // data chunk size (TLV.Length-2)
  readINT(snac, ofs);    // request owner uin
  ReplyType := readWORD(snac, ofs);   //	reply type: SRV_META_INFO_REPLY
  readWORD(snac, ofs);  // request sequence number
//ofs:=11;
//         ReWrite Переделать!!!
case ReplyType of
  $0042: notifyListeners(IE_endOfOfflineMsgs);
  $0041:  // offline messages
    begin
//    inc(ofs,4);
    cont := getICQContact(readINT(snac, ofs));
    y := readWORD(snac, ofs);
    m := readBYTE(snac, ofs);
    d := readBYTE(snac, ofs);
    if not tryEncodeDate(y,m,d, eventTime) then
      eventTime := 0;
    d := readBYTE(snac, ofs); // hours
    m := readBYTE(snac, ofs);
    eventTime := eventTime+EncodeTime(d,m,0,0)+GMToffset0;
    msgtype := readBYTE(snac, ofs);
    msgflags := readBYTE(snac, ofs);
    msgflags := msgflags or IF_offline;
    msg := getWNTS(snac, ofs);
    eventContact := cont;
    if msgtype=MTYPE_PLUGIN then
      parseGCdata(copy(snac,ofs,length(snac)), TRUE)
    else
      begin
//        msgu := UnUTF(msg);
        notificationForMsg(msgtype, msgflags, not dontBotherStatus, msg);
      end;
    end;
  $07DA:
   begin
    replySubtype := readWORD(snac, ofs);
    case replySubtype of // Case2
      $0FB4 : // last wp result (ComPad)
        begin    // last wp result
//        cont.infoUpdatedTo:=now;
//        if ord(snac[ofs])=$A then
        if readBYTE(snac, ofs)=$A then
          begin
//          inc(ofs,3);
           readWORD(snac, ofs); // following data size
           readWORD(snac, ofs); // $05B9
           readWORD(snac, ofs); // $0004 or $0009 
           y := readWORD(snac, ofs); // $8000 or $0000
           if y = $0080 then
            inc(ofs, $10);
           inc(ofs, $11); // Unknown data
            eventInt := readBEWORD(snac, ofs); // Count of all
            readBEWORD(snac, ofs); // Всего поисков
            readBEWORD(snac, ofs); // Текущие поиск
            readBEWORD(snac, ofs); // following data size
           extractWP_CP;
//          eventInt:=readINT(snac, ofs);
//                eventInt:=-1; // Just for now
          end
        else
          eventInt:=-1;
        if refs[ref].kind = REF_wp then
          notifyListeners(IE_wpEnd)
         else
          if Assigned(cont) then
           begin
            eventContact := cont;
            notifyListeners(IE_userSimpleInfo);
           end;
        end;
//      $B40F : // wp result (ComPad)
      $0FAA: // wp result (ComPad)
        begin // simple query and wp result
        y := word_BEat(snac, ofs);
//        cont.nodb:=FALSE;
//        cont.infoUpdatedTo:=now;
//        if ord(snac[ofs+2])=$A then
        if readBYTE(snac, ofs)=$A then
          begin
//           inc(ofs,3);
           readWORD(snac, ofs); // following data size
           inc(ofs, $1D); // Unknown data
            readBEWORD(snac, ofs); // following data size
           extractWP_CP;
           eventInt := 0;
           eventContact := cont;
           if y = $B40F then
             notifyListeners(IE_wpEnd)
            else
             notifyListeners(IE_userSimpleInfo);
          end
        else
          if refs[ref].kind = REF_wp then
            begin
            eventInt := -1;
            notifyListeners(IE_wpEnd);
            end
          else
            begin
            if Assigned(cont) then
              cont.nodb := TRUE;
            eventError := EC_badContact;
            eventContact := cont;
            notifyListeners(IE_error);
            end;
        end;
//    else
//    case ord(snac[ofs+4]) of   // Case3
      META_simple_query, SRV_USER_FOUND:   // simple query and wp result
        begin
//        if ord(snac[ofs+2])=$A then
        if readBYTE(snac, ofs)=$A then
          begin
//          inc(ofs,3);
          // Для обновления ника на серваке
          if Assigned(cont) then
 {$IFDEF UseNotSSI}
           if useSSI then
 {$ENDIF UseNotSSI}
             OldNick := cont.displayed;
//          nick:=unUTF(getWNTS(snac, ofs));

          extractWP;
          if Assigned(cont) then
          begin
            cont.nodb := FALSE;
            cont.infoUpdatedTo := now;
            if cont.display = cont.UID then
              if cont.nick > '' then
                cont.fDisplay := '';
             if
 {$IFDEF UseNotSSI}
              useSSI and
 {$ENDIF UseNotSSI}
              (cont.displayed <> OldNick) and
                isInList(LT_ROSTER, cont) and
                not cont.CntIsLocal and (cont.SSIID > 0) then
               SSI_UpdateContact(cont);
          end;
          eventInt:=0;
          eventContact := cont;
          if wasUINwp then
            notifyListeners(IE_wpEnd)
           else
            notifyListeners(IE_userSimpleInfo);
          end
        else
          if refs[ref].kind = REF_wp then
            begin
            eventInt :=-1;
            notifyListeners(IE_wpEnd);
            end
          else
            begin
            if Assigned(cont) then
              cont.nodb := TRUE;
            eventError := EC_badContact;
            eventContact := cont;
            notifyListeners(IE_error);
            end;
        end;
      SRV_LAST_USER_FOUND:   // last wp result
        begin
          if Assigned(cont) then
            cont.infoUpdatedTo := now;
//        if ord(snac[ofs+2])=$A then
          if readBYTE(snac, ofs)=$A then
           begin
//          inc(ofs,3);
            extractWP;
            eventInt := readINT(snac, ofs);
           end
          else
           eventInt:=-1;
          if refs[ref].kind = REF_wp then
            notifyListeners(IE_wpEnd);
        end;
(*      META_NOTES_USERINFO:   // query result (about)
        begin
          if Assigned(cont) then
          begin
            cont.infoUpdatedTo:=now;
            inc(ofs,1);
            cont.about:=unUTF(getWNTS(snac, ofs));
            if (flags and 1) = 0 then
              notifyListeners(IE_userinfo);
          end;
        end;
      META_AFFILATIONS_USERINFO:
        begin
        cont.infoUpdatedTo:=now;
//        if snac[ofs+2]=#$14 then
        if readBYTE(snac, ofs)=$14 then
          cont.nodb:=TRUE;
        if (flags and 1) = 0 then
          notifyListeners(IE_userinfo);
        end;
      META_BASIC_USERINFO:   // query result (main, home)
        begin
        inc(ofs,1);
        if Assigned(cont) then
        with cont do
          begin
          noDB:=FALSE;
          infoUpdatedTo:=now;
 {$IFDEF UseNotSSI}
           if useSSI then
 {$ENDIF UseNotSSI}
             OldNick := displayed;
          nick:=unUTF(getWNTS(snac, ofs));
          if (display = UID) and (nick > '') then
            display := '';
          first:=unUTF(getWNTS(snac, ofs));
          last:=unUTF(getWNTS(snac, ofs));
          email:=getWNTS(snac, ofs);
          city:=getWNTS(snac, ofs);
          state:=getWNTS(snac, ofs);
          // skip 3
          getWNTS(snac, ofs); // 	home phone
          getWNTS(snac, ofs); //  home fax
          getWNTS(snac, ofs); //  home address
          cellular:=unUTF(getWNTS(snac, ofs));
          SMSable:=pos(' SMS',cellular)>0;
          if SMSable then
            delete(cellular,length(cellular)-3,4);
          zip:=getWNTS(snac, ofs);
          country:=readWORD(snac, ofs);
          GMThalfs:=readBYTE(snac, ofs);
          readBYTE(snac, ofs); // authorization flag
          readBYTE(snac, ofs); // webaware flag
          readBYTE(snac, ofs); // direct connection permissions
//          pPublicEmail:= not boolean(readBYTE(snac, ofs));
          pPublicEmail:= boolean(readBYTE(snac, ofs));
           if
 {$IFDEF UseNotSSI}
            useSSI and
 {$ENDIF UseNotSSI}
            (displayed <> OldNick) and
              not cont.CntIsLocal and (cont.SSIID > 0) then
             SSI_UpdateContact(cont);
          end;
        if (flags and 1) = 0 then
          notifyListeners(IE_userinfo);
        end;
      META_MORE_USERINFO:   // query result (homepage/more)
        begin
        inc(ofs,1);
        if Assigned(cont) then
        with cont do
          begin
          infoUpdatedTo:=now;
          age:=readWORD(snac, ofs);
          gender:=readBYTE(snac, ofs);
          homepage:=getWNTS(snac, ofs);
          y:=readWORD(snac, ofs);
          m:=readBYTE(snac, ofs);
          d:=readBYTE(snac, ofs);
          if y > 0 then
            begin
             if not tryEncodeDate(y,m,d, birth) then
               birth:=0;
            end
           else
             birth:=0;
          lang[1]:=readBYTE(snac, ofs);
          lang[2]:=readBYTE(snac, ofs);
          lang[3]:=readBYTE(snac, ofs);
           readWORD(snac, ofs); // unknown
           getWNTS(snac, ofs);  // original from: city string
           getWNTS(snac, ofs);  // original from: state string
           readWORD(snac, ofs); // original from: country code
           MarStatus := readBYTE(snac, ofs); // user Marital Status
          if Equals(MyAccount) then
          begin
           inc(ofs, 4); // 	unknown
           getWNTS(snac, ofs);  // unknown
           inc(ofs, 4); // 	unknown
           inc(ofs, 4); // 	unknown
           Attached_login_email := getWNTS(snac, ofs); //
          end;

          end;
        if (flags and 1) = 0 then
          notifyListeners(IE_userinfo);
        end;
      META_WORK_USERINFO:   // query result (work)
        begin
          inc(ofs,1);
          with cont do
           begin
            infoUpdatedTo:=now;
            workcity :=unUTF(getWNTS(snac, ofs));
            workstate := getWNTS(snac, ofs);
            workphone := getWNTS(snac, ofs);
            workfax := getWNTS(snac, ofs);
            workaddress := getWNTS(snac, ofs);
            workzip := getWNTS(snac, ofs);

            workCountry := readWORD(snac, ofs);
            workCompany := getWNTS(snac, ofs);
            workDep := getWNTS(snac, ofs);
            workPos := getWNTS(snac, ofs);
             readWORD(snac, ofs);
            workpage := getWNTS(snac, ofs);
           end;
        if (flags and 1) = 0 then
          notifyListeners(IE_userinfo);
        end;
      META_INTERESTS_USERINFO:  // Interests
        begin
//          if ord(snac[ofs+2])=$A then
          if readBYTE(snac, ofs)=$A then
           with cont do
            begin
//            inc(ofs,3);
             infoUpdatedTo:=now;
              Interests.Count := readBYTE(snac, ofs); // Êîë-âî èíòåðåñîâ
//              SetLength(Interests.InterestBlock, Interests.Count);
//              if Interests.Count > 0 then
              for i := 0 to 3 do
               begin
                 Interests.InterestBlock[i].Code := readWORD(snac, ofs);
//                 Interests.InterestBlock[i].Str := getWNTS(snac, ofs)
                 if i < Interests.Count then
                   sU := unUTF(getWNTS(snac, ofs))
                  else
                   sU := '';
                 if (Interests.InterestBlock[i].Names <> NIL)
                   AND Assigned(Interests.InterestBlock[i].Names) then
                   Interests.InterestBlock[i].Names.Clear
                  else
                   Interests.InterestBlock[i].Names:=TStringList.Create;
                 while sU<>'' do
                   Interests.InterestBlock[i].Names.Add(chop(',',sU));
//                 Interests.InterestBlock[i].Count:=int.Count+1;
               end;
//               Interests[i].code := readWORD(snac, ofs);
//               Interests[i].Str := getWNTS(snac, ofs);
            end
          else
            eventInt:=-1;

        if (flags and 1) = 0 then
          notifyListeners(IE_userinfo);
        end;
*)
      META_UNREGISTER_ACK:
            begin
              eventContact := cont;
              notifyListeners(IE_uinDeleted);
            end;
      META_SET_PASSWORD_ACK:
//        if ord(snac[ofs+2])=$A then
        if readBYTE(snac, ofs)=$A then
          begin
            fPwd := '';
            fPwdHash := '';
            if saveMD5pwd and LoginMD5 then
              fPwdHash := MD5Pass(waitingNewPwd)
             else
              fPwd     := waitingNewPwd;
               ;
            notifyListeners(IE_pwdChanged);
          end
        else
          begin
          eventError:=EC_cantchangePwd;
          notifyListeners(IE_error);
          end;
      META_SET_WORKINFO_ACK,META_SET_MOREINFO_ACK,
      META_SET_NOTES_ACK,META_SET_EMAILINFO_ACK,
      META_SET_FULLINFO_ACK:   // acks to save-my-info
        begin
        inc(savingMyinfo.ACKcount);
        if savingMyinfo.ACKcount = 4 then
          begin
          savingMyinfo.running:=FALSE;
          sendStatusCode(False); // needed(?) for the server to save publicemail
          notifyListeners(IE_myinfoACK);
          end;
        end;
//      end;//case3
    end; //case2
   end; // 07DA
  end;//case1
end; // parse1503

 {$IFDEF USE_REGUIN}
procedure TicqSession.parseNewUIN(const snac: RawByteString);
begin
  if Length(snac) > 50 then
   begin
    eventContact:= getICQContact(dword_LEat(@snac[47]));
    notifyListeners(IE_newUIN);
   end;
end; // parseNewUIN
 {$ENDIF USE_REGUIN}

//var
//  myBeautifulSocketBuffer:string;

procedure TicqSession.onDataAvailable(Sender: TObject; Error: Word);
var
  pkt : RawByteString;
begin
 {$IFDEF UNICODE}
  pkt := sock.ReceiveStrA;
 {$ELSE nonUNICODE}
  pkt := sock.ReceiveStr;
 {$ENDIF UNICODE}
  received(sender, Error, pkt);
end;

procedure TicqSession.OnProxyError(Sender : TObject; Error : Integer; Msg : String);
begin
// if not isAva then

 if error <> 0 then
  begin
    goneOffline;
//    eventInt:=WSocket_WSAGetLastError;
//    if eventInt=0 then
     eventInt:=error;
    eventMsgA := msg;
    eventError:=EC_cantconnect;
    notifyListeners(IE_error);
//  exit;
  end;
end;

procedure TicqSession.OnProxyTalk(Sender : TObject; isReceive : Boolean; Data : RawByteString);
begin
  eventData:= Data;
  if isReceive then
    notifyListeners(IE_serverSent)
   else
    notifyListeners(IE_serverGot)
     ;
end;


procedure TicqSession.received(Sender: TObject; Error: Word; pkt : RawByteString);
var
//  pkt, s:string;
  channel,ref:integer;
  flags : Word;
  oldVis : Tvisibility;
  service:TsnacService;
  i : Integer;
//  i, j: Integer;
begin
 try
//  pkt := sock.ReceiveStr;

Q.add(pkt);
if Q.error then
  begin
   eventData:=q.popError;
    notifyListeners(IE_serverSent);
   eventError:=EC_invalidFlap;
   eventMsgA := '';
   notifyListeners(IE_error);
   disconnect;
  end;
while Q.available do
  begin
  pkt:=Q.pop;
  eventData:=pkt;
  notifyListeners(IE_serverSent);

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
  if (flags and $8000)<>0 then
   begin
     i := word_BEat(@pkt[1]);
     delete(pkt,1,i+2);
   end;
  if Length(pkt)= 0 then
    Exit;
  case phase of
 {$IFDEF USE_REGUIN}
    CREATING_UIN_:
      case channel of
        LOGIN_CHANNEL:
          begin
          sendFLAP(LOGIN_CHANNEL, #0#0#0#1);
          //sendCreateUIN;
          send170c;
          notifyListeners(IE_creatingUIN);
          notifyListeners(IE_ackImage);
          end;
        SNAC_CHANNEL:
          if service = $170d then
          begin
            //ShowMessage('image complete');
            parse170d(pkt);
            //disconnect;
          end
          else
          if service = $1705 then
            begin
             parseNewUIN(pkt);
             disconnect;
            end
          else
            begin
             eventError:=EC_cantCreateUin;
             notifyListeners(IE_error);
            end;
        LOGOUT_CHANNEL:
            begin
              eventError:=EC_cantCreateUin;
              notifyListeners(IE_error);
            end;
        end;
{$ENDIF USE_REGUIN}
    LOGIN_:
       begin
//         if not isAvatarSession then
         if protoType = SESS_IM then
          begin
           case channel of
            LOGIN_CHANNEL:
              if LoginMD5 then
                newLogin       // 1706
               else
                if pkt=#0#0#0#1 then
                  sendLogin;
            SNAC_CHANNEL:
                 case service of
                   $1703: parseCookie(pkt); //SRV_LOGIN_REPLY(pkt);
                   $1707: parseAuthKey(pkt);
                 end;
            LOGOUT_CHANNEL: parseCookie(pkt);
            end;
          end
         else
    //    avt_connecting_,
    //    RELOGIN_:
          begin
          case channel of
            LOGIN_CHANNEL: if copy(pkt, 1, 4)=#0#0#0#1 then sendCookie;
            SNAC_CHANNEL:
              if service=$0103 then     // server is ready
                begin
    //              parse0103(pkt);
                  sendImICQ;     // $0117
                  phase:=SETTINGUP_;
                end;
            end;
          end;
       end;
    RELOGIN_:
          begin
          case channel of
            LOGIN_CHANNEL: if copy(pkt, 1, 4)=#0#0#0#1 then sendCookie;
            SNAC_CHANNEL:
              if service=$0103 then     // server is ready
                begin
    //              parse0103(pkt);
                  sendImICQ;     // $0117
                  phase:=SETTINGUP_;
                end;
            end;
          end;
  SETTINGUP_:
      case service of
        $0118:
          begin     // ack to I'm ICQ
          sendSNAC(ICQ_SERVICE_FAMILY, 6, '');
//          if not isAvatarSession then
          if protoType = SESS_IM then
           begin
            sendSNAC(ICQ_SERVICE_FAMILY, $E, '');// 010E

     {$IFDEF UseNotSSI}
            if useSSI then
     {$ENDIF UseNotSSI}
             begin
               SSIreqLimits;
             end;

            sendSNAC(ICQ_LOCATION_FAMILY, 2, ''); // 0202
            SendReqBuddy; // 0302 BUDDY__RIGHTS_QUERY

            sendSNAC(ICQ_MSG_FAMILY, 4, ''); // 0404
            sendSNAC(ICQ_BOS_FAMILY, 2, ''); // 0902
          end;
          notifyListeners(IE_almostonline);
          end;
        $0107: begin
                 sendAckTo107;
//                 if isAvatarSession then
                 if protoType = SESS_AVATARS then
                  begin
                   sendClientReady;
                    phase:=ONLINE_;
                  end;
               end;
        $010F: parse010F(pkt);
        $0903:
          begin
          serverStart;
          sendCapabilities;     // $0204
          if (protoType = SESS_IM) then
           begin
              sendIMparameter(#00);
    //          sendIMparameter(#01); // $0402
    //          sendIMparameter(#02);
    //          sendIMparameter(#04);
    //          fRoster.setStatus(SC_OFFLINE);
    //          ICQCL_setStatus(fRoster, ICQcontacts.SC_OFFLINE);
              with fRoster do
               begin
                resetEnumeration;
                while hasMore do
                  with TICQContact(getNext) do
                   begin
              {$IFDEF UseNotSSI}
                  need to add some logic!!!!
              {$ENDIF UseNotSSI}
                     if CntIsLocal or not Authorized then
                       status := SC_UNK
                      else
                       status := SC_OFFLINE;

                    invisible:=FALSE;
                end;
                end;
    //          myinfo.proto:=My_proto_ver;  // By Rapid D
    //          myinfo.status:=startingStatus;
    //          myinfo.invisible:=startingVisibility in [VI_invisible, VI_privacy];
              curStatus := startingStatus;
              fVisibility := startingVisibility;
    //          if not useSSI then
               begin
                sendSimpleQueryInfo(MyAccount);
                sendSimpleQueryInfo(Int2UID(uinToUpdate));
               end;

              {$IFDEF UseNotSSI}
               if not useSSI then
                 sendAddContact(fRoster);
              {$ENDIF UseNotSSI}
              previousInvisible:= IsInvisible;
    //          sendPermsNew;
     {$IFDEF UseNotSSI}
              if not useSSI then
                sendStatusCode(False); //011E
    //          sendPermissions;
    //          sendSSIReady;
              if useSSI then
     {$ENDIF UseNotSSI}
               begin
                SSIchkRoster;
//                SSIreqRoster;
                CLPktNUM := 0;
               end;
    //          if curXStatus > 0 then
                setStatusStr(curXStatus, ExtStsStrings[curXStatus]);
              SSI_InServerTransaction := 0;
     {$IFDEF UseNotSSI}
              if not useSSI then
                sendClientReady;
    //          sendSNAC(ICQ_LOCATION_FAMILY, $04, TLV($04, ''));
    //          sendSNAC(ICQ_SERVICE_FAMILY, $1E, TLV($06, getFullStatusCode));
    //          sendAIMOnline;
     {$ENDIF UseNotSSI}
           end;
          if
 {$IFDEF UseNotSSI}
            (not useSSI) or
 {$ENDIF UseNotSSI}
//            isAvatarSession
            (protoType = SESS_AVATARS)
          then
           begin
            phase:=ONLINE_;
            notifyListeners(IE_online);
           end;
          end;
        $1306:
           begin
             isImpCL := True;
             oldVis := Visibility;
             if parse1306(self, serverSSI, pkt, ref) then
 {$IFDEF UseNotSSI}
              if useSSI then
 {$ENDIF UseNotSSI}
               begin
//                sendSNAC(ICQ_LISTS_FAMILY, 07, '');
                if (phase <> ONLINE_) then
                 begin
//                  fVisibility := VI_invisible;
                  fVisibility := oldVis;
                   sendStatusCode; //011E
                  SSIsendReady;
                   sendVisibility;
                  sendClientReady;
                  {$IFDEF UseNotSSI}
                   if useLSI3 then
                     sendAddContact(fRoster);
//                     sendAddTempContact(fRoster);
                  {$ENDIF UseNotSSI}
                  phase:=ONLINE_;
//                  status := startingStatus;
//                  myinfo.status := startingStatus;
                  fVisibility := oldVis;
                  notifyListeners(IE_online);
                  Visibility := fVisibility;
                 end;
//                sendStatusCode; //011E
               end;
           end;
        $130F:
           begin
//             sendSNAC(ICQ_LISTS_FAMILY, 07, '');
            if
 {$IFDEF UseNotSSI}
              useSSI and
 {$ENDIF UseNotSSI}
              (phase <> ONLINE_) then
             begin
              sendStatusCode; //011E
//              Visibility := oldVis;
              sendClientReady;
              {$IFDEF UseNotSSI}
                if useLSI3 then
                 sendAddContact(fRoster);
//                   sendAddTempContact(fRoster);
              {$ENDIF UseNotSSI}
              phase:=ONLINE_;
              notifyListeners(IE_online);
             end;
            SSIsendReady;
            sendStatusCode; //011E
           end;
        end;
    ONLINE_:
      if channel <> SNAC_CHANNEL then
        begin
        eventError:=EC_serverDisconnected;
        if existsTLV(9,pkt) then
          case getTLVwordBE(9, pkt) of
            1: eventError:=EC_anotherLogin
            end;
        notifyListeners(IE_error);
        disconnect;
        end
      else
        case service of
          $0105: parseREDIRECTxSERVICE(pkt);
          $010A: notifyListeners(IE_toofast);
          $010B: notifyListeners(IE_pause);

          $010F: parse010F(pkt);
   {$IFDEF RNQ_AVATARS}
          $0121: parse0121(pkt, flags); // Need Upload Avatar
   {$ENDIF RNQ_AVATARS}
          $0201: parseSRV_LOCATION_ERROR(pkt, ref);

          $0206: parse0206(pkt);
//          $0206: debug_Snac(pkt, 'InvisCheckNNN.txt');
          $020C: parse020C(pkt, ref);

          $030B: parseOncomingUser(pkt);
          $030C: parseOffgoingUser(pkt);
          $0401: parseMsgError(pkt,ref);
          $0407: parseIncomingMsg(pkt);
          $040A: parse040A(pkt); // SRV_MISSED_MESSAGE
          $040B: parse040B(pkt); // auto-messages
          $040C: parseServerAck(pkt,ref);
          $0414: parseTYPING_NOTIFICATION(pkt);
          $0417: notifyListeners(IE_endOfOfflineMsgs);
        {$IFDEF RNQ_AVATARS}
          $1003: iconUploadAck(pkt);
          $1007: parseIcon(pkt);
        {$ENDIF RNQ_AVATARS}

          $1306: parse1306(self, serverSSI, pkt, ref);{SRV_REPLYROSTER} // By Rapid D
          $1308: Parse1308090A(pkt, ref, SSI_OPERATION_CODES_ADD);
          $1309: Parse1308090A(pkt, ref, SSI_OPERATION_CODES_UPDATE);
          $130A: Parse1308090A(pkt, ref, SSI_OPERATION_CODES_REMOVE);
          $130E: Parse130E(pkt, ref);
          $1311: Parse1311(pkt, ref);
          $1312: Parse1312(pkt, ref);

          $1319: parseAuthReq(pkt);
          $131B: parse131b(pkt); // Auth Denied
          $131C: parse131C(pkt); // "You were added" message
////////////////////////////////////////////////////////////
///////////////!!!!!!!!!!!NEED TO ADD!!!!!!!!!//////////////
///    { TODO : Add 15,01 - parse error of Short contact info request }
//          $1501: parse1501Error(pkt, ref, flags);
////////////////////////////////////////////////////////////
          $1503: parse1503(pkt, ref, flags);
          $2503: ;// new UIN info, need to parse
                  // https://sites.google.com/site/imaderingcity/im-world/im-protocols/icq-protocol/148
          end;
    end;//case
  if Q.error then
    begin
    eventData:=q.popError;
    eventError:=EC_invalidFlap;
    notifyListeners(IE_error);
    end;
  end;
except
end;
eventData:='';
end; // received

procedure TicqSession.sendIMparameter(chn : AnsiChar); // 0402
const
  CHANNEL_MSGS_ALLOWED = $00000001; //Wants ICBMs on this channel 
  MISSED_CALLS_ENABLED = $00000002; //Wants MISSED_CALLS on this channel 
  EVENTS_ALLOWED = $00000008;       //Wants CLIENT_EVENTs 
  SMS_SUPPORTED = $00000010;        //Aware of sending to SMS 
  unk0_ALLOWED = $00000080;
  OFFLINE_MSGS_ALLOWED = $00000100; //Support offline IMs; client is capable of storing and retrieving 
  unk1_ALLOWED = $00000200; //
  HTML_ALLOWED = $00000400; // Seems it HTML support
  unk2_ALLOWED = $00000800;
  unk3_ALLOWED = $00040000;
var
  i : word;
//  Chr3 : Char;
begin
  i := MISSED_CALLS_ENABLED or CHANNEL_MSGS_ALLOWED;
  if ((chn=#0)or (chn = #1)or(chn = #2)) and SupportTypingNotif then
    i := i or EVENTS_ALLOWED;
//  if ((chn = #1)or(chn = #2)) then
    i := i or OFFLINE_MSGS_ALLOWED;   // Или это убивает офлайн-сообщения :)
  i := i or unk1_ALLOWED;
//  i := i or $0700; // Seems it HTML support
//  Chr3 := #00;
  sendSNAC(ICQ_MSG_FAMILY, 2, AnsiChar(#$00) + chn + dword_BEasStr(i) + #$1F#$40+ #$03#$E7+#$03#$E7+Z)
//  sendSNAC(ICQ_MSG_FAMILY,2, #$00 + chn + #$00#$00 + #00 + Chr(i) + #$1F#$40+ #$03#$E7+#$03#$E7+Z)
//  sendSNAC(ICQ_MSG_FAMILY,2, #$00 + chn + #$00#$00 + word_LEasStr(i) + #$1F#$40+ #$03#$E7+#$03#$E7+Z)
end;

procedure TicqSession.sendClientReady;
const
  cver = #$01#$10#$12#$46;
begin
// if isAvatarSession then
 if protoType = SESS_AVATARS then
   sendSNAC(ICQ_SERVICE_FAMILY, 2, #$00#$10#$00#$01 + cver)
  else
   sendSNAC(ICQ_SERVICE_FAMILY, 2,
    #$00#$22#$00#$01 + cver +
    #$00#$01#$00#$04 + cver +
//    #$00#$10#$00#$01 + #$00#$10#$08#$E4);
//     #$00#$01#$00#$03 + #$01#$10#$04#$7B +
     #$00#$13#$00#$04 + cver +
     #$00#$02#$00#$01 + cver +
     #$00#$03#$00#$01 + cver +
     #$00#$15#$00#$01 + cver +
     #$00#$04#$00#$01 + cver +
     #$00#$06#$00#$01 + cver +
     #$00#$09#$00#$01 + cver +
//     #$00#$10#$00#$01 + #$01#$10#$08#$E4 +
     #$00#$0A#$00#$01 + cver +
     #$00#$0B#$00#$01 + cver)
end;

procedure TicqSession.sendCapabilities; // 0204
var
  s : RawByteString;
begin
//  s := '';
  s := CAPS_sm2big(CAPS_sm_ICQSERVERRELAY) + CAPS_sm2big(CAPS_sm_ICQ);
//  sm := sm + CapsSmall[24].v + CapsSmall[25].v;
  s := s + CAPS_sm2big(CAPS_sm_AIM) + CAPS_sm2big(CAPS_sm_ShortCaps);

  if SupportTypingNotif then
    s := s + BigCapability[CAPS_big_MTN].v;

//  s := s + BigCapability[CAPS_big_RTF].v;
  if SupportUTF then
    s := s + CAPS_sm2big(CAPS_sm_UTF8);



  if UseCryptMsg then
   begin
    s := s + BigCapability[CAPS_big_CryptMsg].v;
    s := s + BigCapability[CAPS_big_QIP_Secure].v; // QIP protect message
   end;
//    sm := sm + CapsSmall[CAPS_sm_UTF8].v;
  if AvatarsSupport then
   begin
    s := s + CAPS_sm2big(CAPS_sm_Avatar);
//    sm := sm + CapsSmall[CAPS_sm_Avatar].v;
//    s := s + BigCapability[CAPS_big_Xtraz].v ;
   end;

//  s := s + CAPS_sm2big(10);
//  s:= s+ XStatus6[curXStatus].pid;
  if {UseOldXSt and} (curXStatus > 0) then
    s:= s+ XStatusArray[curXStatus].pidOld;

  s := s +
{$IFDEF usesDC}
           CAPS_sm2big(CAPS_sm_FILE_TRANSFER)+
{$ENDIF usesDC}
           CAPS_sm2big(CAPS_sm_NEW_STAT)

//           +BigCapability[CAPS_big_tZers].v
        ;

{  s := s + // Testing Chat
           BigCapability[5].v
         +
           BigCapability[17].v
         ;
}
//  s := s +myInfo.extracapabilities;
  if AddExtCliCaps and (Length(ExtClientCaps)=16) then
    s := s+ ExtClientCaps;
  

  sendSNAC(ICQ_LOCATION_FAMILY, 4, TLV($05, s)
//      +  TLV($19, sm)
      );
end;

procedure TicqSession.sendImICQ;
begin
// if isAvatarSession then
 if protoType = SESS_AVATARS then
   sendSNAC(ICQ_SERVICE_FAMILY, $17, #$00#$10#$00#$01)
  else
   sendSNAC(ICQ_SERVICE_FAMILY, $17,  #$00#$22#$00#$01 +
                    #$00#$01#$00#$04+
                    #$00#$02#$00#$01+
                    #$00#$03#$00#$01+
                    #$00#$04#$00#$01+
                    #$00#$06#$00#$01+
                    #$00#$09#$00#$01+
                    #$00#$0B#$00#$01+
//                      #$00#$10#$00#$01+
                    #$00#$13#$00#$04+
                    #$00#$15#$00#$01+
                    #$00#$0A#$00#$01)
end;

procedure TicqSession.sendCookie;
begin
  sendFLAP(LOGIN_CHANNEL, RawByteString(#0#0#0#1) + RawByteString(TLV(6,cookie)));
  cookie:=''; // free mem
  cookieTime := 0;
end; // sendCookie

procedure TicqSession.sendAckTo107;
begin sendSNAC(1,8, #$00#$01#$00#$02#$00#$03#$00#$04#$00#$05) end;

procedure TicqSession.newLogin;
var
  s : RawByteString;
begin
  s := #0#0#0#1;
  if Pos(AnsiChar('@'), MyAccount) > 1 then
   begin
    s := s + TLV($56, '');
    sendFLAP( LOGIN_CHANNEL, s
      +TLV(1, MyAccount)
      +TLV(2, encrypted(fPwd))
    // By Rapid D
      +TLV(3, 'ICQBasic')
      +TLV($16, word($010A))
      +TLV($17, word($0014))
      +TLV($18, word($0022))
      +TLV($19, word($0001))
    //  +TLV($1A, word(RnQBuild))
      +TLV($1A, word($666))
      +TLV($14, integer($666))
      +TLV($E,'us')
      +TLV($F,'en')
    );
   end
  else
   begin

     sendFLAP( LOGIN_CHANNEL, s  +
              TLV( $8003, #$00#$10#$00#$00));

    // if Assigned(myInfo) then
  sendSNAC(ICQ_BUCP_FAMILY, $06, TLV($01, MyAccount)
    //     + TLV($4B, '') // Unknown
    //     + TLV($5A, '') // Unknown
   );
   end;
end;

procedure TicqSession.sendLogin;
var
  s : RawByteString;
begin
  s := #0#0#0#1;
//  if Assigned(myInfo) then
   if Pos(AnsiChar('@'), MyAccount) > 1 then
    s := s + TLV($56, '');
sendFLAP( LOGIN_CHANNEL, s
  +TLV(1, MyAccount)
  +TLV(2, encrypted(pwd))
// By Rapid D
  +TLV(3, 'ICQBasic')
  +TLV($16, word($010A))
  +TLV($17, word($0014))
  +TLV($18, word($0022))
  +TLV($19, word($0001))
//  +TLV($1A, word(RnQBuild))
  +TLV($1A, word($666))
  +TLV($14, integer($666))

{  +TLV(3, 'ICQ Inc. - Product of ICQ (TM).2003b.5.56.1.3916.85')
  +TLV($16, word($010A))
  +TLV($17, word($0002))
  +TLV($18, word($0038))
  +TLV($19, word($0001))
  +TLV($1A, word($0f4c))
  +TLV($14, integer($55))
}
  +TLV($E,'us')
  +TLV($F,'en')

);
notifyListeners(IE_loggin);
end; // sendLogin

procedure TicqSession.SendReqBuddy(Second: Boolean = False);
var
  vS : RawByteString;
begin
  if Second then
    vS := ''
  else
// Seems it for support of offline messages
// Some
//  vS := TLV(05, word_BEasStr(BART_SUPPORTED or OFFLINE_BART_SUPPORTED));

//  vS := TLV(05, word_BEasStr(BART_SUPPORTED or INITIAL_DEPARTS));
    vS := TLV(05, word_BEasStr(BART_SUPPORTED or INITIAL_DEPARTS or
                               OFFLINE_BART_SUPPORTED or REJECT_PENDING_BUDDIES));
  if useFBcontacts then
   begin
    if not Second then
    begin
      vS := vS + TLV(06, AnsiChar(1)+ AnsiChar(0)+AnsiChar(1)); // Don't know what
      vS := vS + TLV(07, AnsiChar(0)); // Don't know what
    end;

    vS := vS + TLV(08, AnsiChar(1)); // ICQ_FACEBOOK_SUPPORT;
   end;

  sendSNAC(ICQ_BUDDY_FAMILY, 2, vS); // 0302 BUDDY__RIGHTS_QUERY
end;

function TicqSession.removeContact(cnt:TRnQContact):boolean;
var
  isLocal ,delLocSrv
    : Boolean;
  c : TICQContact;
begin
  c := TICQContact(cnt);
  isLocal := cnt.CntIsLocal;
  delLocSrv := isLocal or not cnt.Authorized;
  Result := notInList.remove(cnt);
  result := fRoster.remove(cnt) or Result;
  if result then
   begin
    removeFromVisible(c);
    if
     {$IFDEF UseNotSSI}
      useSSI and
     {$ENDIF UseNotSSI}
      not isLocal then
        SSIdeleteContact(c);
   {$IFDEF UseNotSSI}
    if useSSI then
      begin
       if useLSI3 and delLocSrv then
         sendRemoveTempContact(c.buin)
      end
     else
      if useLSI3 and not useSSI or delLocSrv then
        sendRemoveContact(c.buin);
   {$ENDIF UseNotSSI}
    c.status:= SC_UNK;
    c.SSIID := 0;
    eventInt:= TList(fRoster).count;
    notifyListeners(IE_numOfContactsChanged);
   end
end; // removeContact

//procedure TicqSession.setStatus(s:Tstatus; inv:boolean);
procedure TicqSession.setStatus(s:TICQstatus; vis: Tvisibility);
begin
  if s = SC_OFFLINE then
   begin
    disconnect;
    exit;
   end;
//if (s = myinfo.status) and (inv = myinfo.invisible) then exit;
//  if (s = myinfo.status) and (vis = visibility) then exit;
  if (s = curStatus) and (vis = visibility) then exit;
  eventOldStatus := curStatus;
  eventOldInvisible := IsInvisible;
  startingStatus:=s;
//startingInvisible:=inv;
  startingVisibility := vis;
  if isReady then
    begin
      if (vis in [VI_invisible, VI_privacy]) <> IsInvisible then
        clearTemporaryVisible;
//      myinfo.status :=s;
//      myinfo.invisible := (vis in [VI_invisible, VI_privacy]);
      curStatus := s;
      visibility := vis;
      sendStatusCode(False);
//      eventContact:=myinfo;
      eventContact:= NIL;
      notifyListeners(IE_statuschanged);
    end
   else
    connect;
end; // setStatus

procedure TicqSession.setStatus(st:byte);
begin
  if st = byte(SC_OFFLINE) then
   begin
    disconnect;
    exit;
   end;
//if (s = myinfo.status) and (inv = myinfo.invisible) then exit;
//  if (st = byte(myinfo.status)) then exit;
  if (st = byte(curStatus)) then exit;
  eventOldStatus := curStatus;
  eventOldInvisible := IsInvisible;
  startingStatus:=TICQStatus(st);
//startingInvisible:=inv;
//  startingVisibility := vis;
  if isReady then
    begin
    //  if (vis in [VI_invisible, VI_privacy]) <> myinfo.invisible then
    //    clearTemporaryVisible;
    //  myinfo.status := TICQStatus(st);
    //  myinfo.invisible := (vis in [VI_invisible, VI_privacy]);
          curStatus := TICQStatus(st);
      sendStatusCode(False);
    //  eventContact:=myinfo;
      eventContact:= NIL;
      notifyListeners(IE_statuschanged);
    end
   else
    connect;
end; // setStatus

function TicqSession.getStatus: byte;
begin
{if myinfo=NIL then
  result:= byte(SC_UNK)
else
  result:= byte(myinfo.status)}
  result:= byte(curStatus)
end;

function TicqSession.getXStatus:byte;
begin
  Result := curXStatus;
end;

function TicqSession.getStatusName: String;
begin
  if (XStatusAsMain and (curStatus = SC_ONLINE)) and (curXStatus > 0) then
    begin
{      if UseOldXSt and (ExtStsStrings[curXStatus].cap > '') then
//        result := getTranslation(Xsts)
        result := ExtStsStrings[curXStatus].cap
       else}
        if curXStatusStr.Desc > '' then
  //        result := getTranslation(Xsts)
          result := curXStatusStr.Desc
         else
//          result := getTranslation(XStatusArray[extSts].Caption)
          result := getTranslation(status2ShowStr[curStatus])
    end
   else
//    if sts6 > '' then
//      result := sts6
//     else
      result := getTranslation(status2ShowStr[curStatus])
end;

function TicqSession.getStatusImg : TPicName;
begin
  if XStatusAsMain and (curXStatus > 0) then
    Result := XStatusArray[curXStatus].PicName
   else
    begin
     result := status2imgName(byte(curStatus), isInvisible);
    end;
end;

function TicqSession.getVisibility : byte;
begin
  result:= byte(fVisibility)
end;

//function TicqSession.validUid(var uin:TUID):boolean;
(*function TicqSession.validUid1(const uin:TUID):boolean;
//var
// i : Int64;
// k : Integer;
// fUIN : Int64;
begin
 Result := TicqSession._isValidUid1(uin);
{  Result := False;
  uin := trimUID(uin);
  val(uin, fuin, k);
  if k = 0 then
    begin
      result := True;
      uin := unFakeUIN(fuin)
    end
   else
    if (copy(uin,1,4)=AIMprefix) then
      begin
        uin := copy(uin, 5, length(uin));
        Result := Length(uin) > 0;
      end;
    ;         }
//  result:= (TryStrToInt64(ExtractFileName(uin), i) AND (i > 0)) or (copy(uin,1,4)=AIMprefix)
end;
*)

{class function TicqSession.GetId: Word;
begin
  result := 0;
end;}
class function TicqSession._GetProtoName: string;
begin
  result := 'ICQ';
end;

class function TicqSession._getDefHost : Thostport;
begin
  Result.host := //'login.icq.com';
                 ICQServers[0];
  Result.Port := 5190;
end;

function TicqSession.getICQContact(const uid: TUID) : TICQContact;
begin
//  result := TICQContact(contactsDB.get(TICQContact, uid));
  result := TICQContact(contactsDB.add(Self, uid));
end;

function TicqSession.getICQContact(uin: Integer): TICQContact;
begin
//  result := TICQContact(contactsDB.get(TICQContact, uin));
  result := TICQContact(contactsDB.add(Self, IntToStr(uin)));
end;

class function TicqSession._isProtoUid(var uin: TUID): boolean; //Static;
//function TicqSession.isValidUid(var uin:TUID):boolean; //Static;
var
// i : Int64;
 k : Integer;
 fUIN : Int64;
 temp : TUID;
begin
  Result := False;
  temp := TICQContact.trimUID(uin);
  val(temp, fuin, k);
  if k = 0 then
    begin
      result := True;
      uin := unFakeUIN(fuin)
    end
   else
    if (copy(uin,1,4)=AIMprefix) then
      begin
        temp := copy(temp, 5, length(temp));
        Result := Length(temp) > 0;
        if Result then
         uin := temp;
      end;
    ;
end;

//class function isValidUid(var uin:TUID):boolean; override;
class function TicqSession._isValidUid1(const uin:TUID):boolean; //Static;
//function TicqSession.isValidUid(var uin:TUID):boolean; //Static;
var
// i : Int64;
 k : Integer;
 fUIN : Int64;
 temp : TUID;
begin
  Result := False;
  temp := TICQContact.trimUID(uin);
  if Length(temp) = 0 then
    Exit;
  val(temp, fuin, k);
  if k = 0 then
    begin
      result := True;
//      uin := unFakeUIN(fuin)
    end
   else
     if not(temp[1] in ['0'..'9']) then Result := True;
    ;
end;


procedure TicqSession.addContact(cl:TRnQCList; SendIt : Boolean = True);
begin
  if cl=NIL then exit;
  if TList(cl).count = 0 then
    exit;
  cl:= cl.clone.remove(fRoster);
  if isReady then
    ICQCL_SetStatus(cl, SC_OFFLINE)
   else
    ICQCL_SetStatus(cl, SC_UNK);
  fRoster.add(cl);
{$IFDEF UseNotSSI}
  if isReady and SendIt then
    sendAddContact(cl);
{$ENDIF UseNotSSI}
  eventInt:= TList(fRoster).count;
  notifyListeners(IE_numOfContactsChanged);
  cl.free;
end; // addContact

function TicqSession.addContact(c:TRnQContact; isLocal : Boolean = false):boolean;
//var
//  i : Integer;
begin
  result:=FALSE;
  if (c=NIL)or (c.UID2cmp = '') then exit;
  result := fRoster.add(c);
  Result := Result or ({$IFDEF UseNotSSI} useSSI and {$ENDIF UseNotSSI}
                       not isLocal and c.CntIsLocal);

//c.CntIsLocal := True;
//c.SSIID := 0;
 if result then
  begin
   if isReady then
    begin
      if TICQcontact(c).status = SC_UNK then
        TICQcontact(c).status:= SC_OFFLINE;
      TICQcontact(c).invisible:=FALSE;
      if
 {$IFDEF UseNotSSI}
       useSSI and
 {$ENDIF UseNotSSI}
        not isLocal then
        SSIAddContact(TICQcontact(c))
 {$IFDEF UseNotSSI}
      else
       if useSSI and c.CntIsLocal then
         begin
          if useLSI3 then
//           sendAddTempContact(c.buin);
            sendAddContact(c.buin);
         end
        else
         if useLSI3 and (not useSSI or c.CntIsLocal) then // not c.Authorized then
          sendAddContact(c.buin);
 {$ENDIF UseNotSSI}
    end;
//  if c.status = SC_OFFLINE then
//    getUINStatus(c.UID);
   eventInt:= TList(fRoster).count;
   notifyListeners(IE_numOfContactsChanged);
  end
 else
 {$IFDEF UseNotSSI}
  if useSSI then
 {$ENDIF UseNotSSI}
   begin
      SSI_UpdateGroup(TICQcontact(c));      // Çðÿ òóò!!!
   end;
  ;
end; // addContact

function TicqSession.readList(l : TLIST_TYPES):TRnQCList;
begin
 case l of
   LT_ROSTER:    result:=fRoster;
   LT_VISIBLE:   result:=fVisibleList;
   LT_INVISIBLE: result:=fInvisibleList;
   LT_TEMPVIS:   result:=tempvisibleList;
   LT_SPAM:      result:=spamList;
  else
   Result := NIL;
 end;
end;

procedure TicqSession.AddToList(l : TLIST_TYPES; cl:TRnQCList);
begin
 case l of
   LT_ROSTER:    addContact(cl);
   LT_VISIBLE:   add2visible(cl);
   LT_INVISIBLE: add2invisible(cl);
   LT_TEMPVIS:   addTemporaryVisible(cl);
//   LT_SPAM:      ;
//  else
//   Result := NIL;
 end;
end;

procedure TicqSession.RemFromList(l : TLIST_TYPES; cl:TRnQCList);
begin
 case l of
//   LT_ROSTER:   //removeContact( addContact(cl);
   LT_VISIBLE:   removeFromVisible(cl);
   LT_INVISIBLE: removeFromInvisible(cl);
   LT_TEMPVIS:   removeTemporaryVisible(cl);
//   LT_SPAM:      result:=spamList;
 end;
end;

procedure TicqSession.AddToList(l : TLIST_TYPES; cnt:TRnQcontact);
begin
 case l of
   LT_ROSTER:   addContact(TICQContact(cnt));
   LT_VISIBLE:   add2visible(TICQContact(cnt));
   LT_INVISIBLE: add2invisible(TICQContact(cnt));
   LT_TEMPVIS:   addTemporaryVisible(TICQContact(cnt));
   LT_SPAM:      add2ignore(TICQContact(cnt));
 end;
end;
procedure TicqSession.RemFromList(l : TLIST_TYPES; cnt:TRnQcontact);
begin
 case l of
   LT_ROSTER:   removeContact(TICQContact(cnt));
   LT_VISIBLE:   removeFromVisible(TICQContact(cnt));
   LT_INVISIBLE: removeFromInvisible(TICQContact(cnt));
   LT_TEMPVIS:   removeTemporaryVisible(TICQContact(cnt));
   LT_SPAM:      remFromIgnore(TICQContact(cnt));
 end;
end;

function TicqSession.isInList(l : TLIST_TYPES; cnt:TRnQContact) : Boolean;
begin
 case l of
   LT_ROSTER:    result:= fRoster.exists(cnt);
   LT_VISIBLE:   result:= fVisibleList.exists(cnt);
   LT_INVISIBLE: result:= fInvisibleList.exists(cnt);
   LT_TEMPVIS:   result:= tempvisibleList.exists(cnt);
   LT_SPAM:      result:= spamList.exists(cnt);
  else
   Result := false;
 end;
end;

function TicqSession.add2visible(c:TICQcontact):boolean;
begin
result:=FALSE;
if c=NIL then exit;
tempVisibleList.remove(c);
result:=not fVisibleList.exists(c);
if result then
  begin
  removeFromInvisible(c);
 {$IFDEF UseNotSSI}
  if not useSSI then
   begin
    addContact(c);
    fVisibleList.add(c);
   end;
 {$ENDIF UseNotSSI}
  if isReady
 {$IFDEF UseNotSSI}
    and (isInvisible or useSSI)
 {$ENDIF UseNotSSI}
  then
    begin
     {$IFDEF UseNotSSI}
     if not useSSI then
       sendAddVisible(c.buin)
      else
     {$ENDIF UseNotSSI}
       SSI_AddVisItem(c.UID, FEEDBAG_CLASS_ID_PERMIT)
//       sendAddVisible(c)
     ;
    eventContact:=c;
    notifyListeners(IE_visibilityChanged);
    end;
  end;
end; // add2visible

procedure TicqSession.add2visible(cl:TRnQCList; OnlyLocal : Boolean = false);
begin
  if cl=NIL then exit;
  if TList(cl).count = 0 then exit;
  tempVisibleList.remove(cl);
  cl:= cl.clone.remove(fVisibleList);
 {$IFDEF UseNotSSI}
  if not useSSI then
   begin
    removeFromInvisible(cl);
    addContact(cl);
    fVisibleList.add(cl);
   end;
 {$ENDIF UseNotSSI}
if isReady
 {$IFDEF UseNotSSI}
 and (useSSI or isInvisible)
 {$ENDIF UseNotSSI}
then
  begin
 {$IFDEF UseNotSSI}
  if useSSI then
 {$ENDIF UseNotSSI}
    fVisibleList.add(cl);
  sendAddVisible(cl);
  eventContact:=NIL;
  notifyListeners(IE_visibilityChanged);
  end;
cl.free;
end; // add2visible

function TicqSession.add2ignore(c:TICQcontact):boolean;
begin
  Result := True;
  if isReady
 {$IFDEF UseNotSSI}
   and useSSI
 {$ENDIF UseNotSSI}
  then
    SSI_AddVisItem(c.UID, FEEDBAG_CLASS_ID_IGNORE_LIST)
end;

function TicqSession.remFromIgnore(c:TICQcontact):boolean;
begin
  Result := True;
  if isReady
 {$IFDEF UseNotSSI}
   and useSSI
 {$ENDIF UseNotSSI}
  then
    SSI_DelVisItem(c.UID, FEEDBAG_CLASS_ID_IGNORE_LIST)
end;

{$IFDEF UseNotSSI}
procedure TicqSession.setVisibleList(cl:TRnQCList);
var
  tmp:TRnQCList;
begin
  if useSSI then Exit;

removeFromInvisible(cl);
tempVisibleList.remove(cl);
tmp:=TRnQCList.create;

// remove visible-cl
tmp.add(fIntVisibleList).remove(cl);
if not tmp.empty then sendRemoveVisible(tmp);
// add cl-visible
tmp.clear;
tmp.add(cl).remove(fIntVisibleList);
if not tmp.empty then sendAddVisible(tmp);

fIntVisibleList.assign(cl);

if isReady and isInvisible then
  begin
  eventContact:=NIL;
  notifyListeners(IE_visibilityChanged);
  end;
tmp.free;
end; // setVisibleList

procedure TicqSession.setInvisibleList(cl:TRnQCList);
var
  tmp:TRnQCList;
begin
  if useSSI then Exit;
removeFromVisible(cl);
tempVisibleList.remove(cl);
tmp:=TRnQCList.create;

// remove invisible-cl
tmp.add(fIntInvisibleList).remove(cl);
if not tmp.empty then sendRemoveInvisible(tmp); // add cl-invisible
// add cl-invisible
tmp.clear;
tmp.add(cl).remove(fIntInvisibleList);
if not tmp.empty then sendAddInvisible(tmp);

tmp.free;
fIntInvisibleList.assign(cl);

if isReady and not isInvisible then
  begin
  eventContact:=NIL;
  notifyListeners(IE_visibilityChanged);
  end;
end; // setInvisibleList
{$ENDIF UseNotSSI}

function TicqSession.removeFromVisible(c:TICQcontact):boolean;
begin
result:=FALSE;
if c=NIL then exit;
removeTemporaryVisible(c);
{$IFDEF UseNotSSI}
  result:= useSSI or fIntVisibleList.remove(c);
  if not useSSI then
    fVisibleList.remove(c);
if result then
{$ENDIF UseNotSSI}
  if isReady
 {$IFDEF UseNotSSI}
   and (useSSI or isInvisible)
 {$ENDIF UseNotSSI}
  then
    begin
 {$IFDEF UseNotSSI}
    if not useSSI then
      sendRemoveVisible(c.buin)
     else
 {$ENDIF UseNotSSI}
      SSI_DelVisItem(c.UID2cmp, FEEDBAG_CLASS_ID_PERMIT);
    eventCOntact:=c;
    notifyListeners(IE_visibilityChanged);
    end;
end; // removeFromVisible

procedure TicqSession.removeFromVisible(const cl:TRnQCList);
var
  cl1 : TRnQCList;
begin
  if cl=NIL then exit;
  removeTemporaryVisible(cl);
 {$IFDEF UseNotSSI}
  if not useSSI then
    begin
      cl1 := cl.clone.intersect(fIntVisibleList);
      fIntVisibleList.remove(cl1);
    end
   else
 {$ENDIF UseNotSSI}
    begin
      cl1 := cl.clone.intersect(fVisibleList);
      fVisibleList.remove(cl1);
    end;
  if isReady and
 {$IFDEF UseNotSSI}
   (useSSI or isInvisible) and
 {$ENDIF UseNotSSI}
   not cl1.empty then
    begin
    sendRemoveVisible(cl1);
    eventContact:=NIL;
    notifyListeners(IE_visibilityChanged);
    end;
  cl1.free;
end; // removeFromVisible

function TicqSession.add2invisible(c:TICQcontact):boolean;
begin
result:=FALSE;
if c=NIL then exit;
removeTemporaryVisible(c);
result := fInvisibleList.add(c);
if result then
  begin
    removeFromVisible(c);
    if isReady  then

 {$IFDEF UseNotSSI}
    if not useSSI then
     begin
      if not isInvisible then
      begin
       sendAddInvisible(c.buin);
       eventContact:=c;
       notifyListeners(IE_visibilityChanged);
      end;
     end
    else
 {$ENDIF UseNotSSI}
     SSI_AddVisItem(c.UID, FEEDBAG_CLASS_ID_DENY)
  end;
end; // add2invisible

procedure TicqSession.add2invisible(cl:TRnQCList; OnlyLocal : Boolean = false);
begin
  if cl=NIL then exit;
  if TList(cl).count = 0 then exit;
  removeTemporaryVisible(cl);
  cl:= cl.clone.remove(fInvisibleList);
  removeFromVisible(cl);
 {$IFDEF UseNotSSI}
  if not useSSI then
    fInvisibleList.add(cl);
 {$ENDIF UseNotSSI}
  if isReady
 {$IFDEF UseNotSSI}
   and (useSSI or not isInvisible)
 {$ENDIF UseNotSSI}
  then
  begin
 {$IFDEF UseNotSSI}
    if useSSI then
 {$ENDIF UseNotSSI}
      fInVisibleList.add(cl);
    sendAddInvisible(cl);
    eventContact:=NIL;
    notifyListeners(IE_visibilityChanged);
  end;
cl.free;
end; // add2invisible

function TicqSession.removeFromInvisible(c:TICQcontact):boolean;
begin
  result:=FALSE;
  if c=NIL then exit;
//  if not useSSI then
    removeTemporaryVisible(c);
 {$IFDEF UseNotSSI}
   if not useSSI then
     result:= fIntInvisibleList.remove(c)
    else
     result := True;
//  result:= fInvisibleList.remove(c);
if result then
 {$ELSE UseNotSSI}
  result:= True;
 {$ENDIF UseNotSSI}
  if isReady
 {$IFDEF UseNotSSI}
   and (useSSI or not isInvisible)
 {$ENDIF UseNotSSI}
  then
    begin
 {$IFDEF UseNotSSI}
    if not useSSI then
      begin
       sendRemoveInvisible(c.buin);
       eventContact:=c;
       notifyListeners(IE_visibilityChanged);
      end
     else
 {$ENDIF UseNotSSI}
      SSI_DelVisItem(c.UID, FEEDBAG_CLASS_ID_DENY);
    end;
end; // removeFromInvisible

procedure TicqSession.removeFromInvisible(const cl:TRnQCList);
var
  cl1 : TRnQCList;
begin
  if cl=NIL then exit;
  removeTemporaryVisible(cl);
 {$IFDEF UseNotSSI}
  if not useSSI then
    begin
      cl1 := TRnQCList(cl.clone.intersect(fIntInvisibleList));
      fIntInvisibleList.remove(cl1);
    end
   else
 {$ENDIF UseNotSSI}
    begin
      cl1 := cl.clone.intersect(fInvisibleList);
      fInvisibleList.remove(cl1);
    end;
if isReady and
 {$IFDEF UseNotSSI}
 (useSSI or not isInvisible) and
 {$ENDIF UseNotSSI}
 not cl1.empty then
  begin
  sendRemoveInvisible(cl1);
  eventContact:=NIL;
  notifyListeners(IE_visibilityChanged);
  end;
 cl1.free;
end; // removeFromInvisible

procedure TicqSession.SSIsendAddTempVisible(const buid : AnsiString);
begin
// sendSNAC(ICQ_LISTS_FAMILY, $37, #$01#$01 + #0+buid + #00#00);
 sendSNAC(ICQ_BOS_FAMILY, $0A, buid);
end;

procedure TicqSession.SSIsendDelTempVisible(const buid : AnsiString);
begin
// sendSNAC(ICQ_LISTS_FAMILY, $37, #$01#$01 + #0+buid + #00#00);
 sendSNAC(ICQ_BOS_FAMILY,$0B, buid);
end;

function TicqSession.addTemporaryVisible(c:TICQcontact):boolean;
begin
  result:=FALSE;
  if not isReady then exit;
  result:=TRUE;
  tempvisibleList.add(c);
 {$IFDEF UseNotSSI}
  if not useSSI then
    begin
      if isInvisible then
        sendAddVisible(c.buin)
      else
        sendRemoveInvisible(c.buin);
    end
   else
 {$ENDIF UseNotSSI}
//      if myinfo.invisible then
      SSIsendAddTempVisible(c.buin);
  eventContact:=c;
  notifyListeners(IE_visibilityChanged);
end; // addTemporaryVisible

function TicqSession.addTemporaryVisible(cl:TRnQCList):boolean;
begin
  result:=FALSE;
  if CL=NIL then exit;
  if not isReady then exit;
  result:=TRUE;
  cl := cl.clone.remove(tempvisibleList);
  tempvisibleList.add(cl);
 {$IFDEF UseNotSSI}
  if not useSSI then
    begin
      if isInvisible then
        sendAddVisible(cl.buinlist)
      else
        sendRemoveInvisible(cl.buinlist);
    end
   else
 {$ENDIF UseNotSSI}
    SSIsendAddTempVisible(cl.buinlist);
(*
cl.resetEnumeration();
{ così non va bene, troppi SNAC inviati. bisogna suddividere CL tra visibleTo
{ e not visibleTo, e inviare solo 2 SNAC. }
while cl.hasMore do
  with cl.getNext() do
    if myinfo.invisible then
      sendAddVisible(buin)
    else
      sendRemoveInvisible(buin);*)
  eventContact:=NIL;
  notifyListeners(IE_visibilityChanged);
  cl.free;
end; // addTemporaryVisible

function TicqSession.removeTemporaryVisible(c:TICQcontact):boolean;
begin
  result:=tempvisibleList.remove(c);
  if not result or not isReady then exit;
 {$IFDEF UseNotSSI}
  if not useSSI then
    begin
      if isInvisible then
        sendRemoveVisible(c.buin)
      else
        sendAddInvisible(c.buin);
    end
   else
 {$ENDIF UseNotSSI}
     SSIsendDelTempVisible(c.buin);
  eventContact:=c;
  notifyListeners(IE_visibilityChanged);
end; // removeTemporaryVisible

function TicqSession.removeTemporaryVisible(cl:TRnQCList):boolean;
begin
  result:=TRUE;
  cl:= cl.clone.intersect(tempVisibleList);
  if isReady and not cl.empty then
  begin
    tempvisibleList.remove(cl);
 {$IFDEF UseNotSSI}
    if not useSSI then
      begin
        if isInvisible then
          sendRemoveVisible(cl)
        else
          sendAddInvisible(cl);
      end
     else
 {$ENDIF UseNotSSI}
       SSIsendDelTempVisible(cl.buinlist);
    eventContact:=NIL;
    notifyListeners(IE_visibilityChanged);
  end;
  cl.free;
end; // removeTemporaryVisible

procedure TicqSession.clearTemporaryVisible;
begin
  removeTemporaryVisible(tempVisibleList)
end;

function TicqSession.useMsgType2for(c:TICQcontact):boolean;
begin
  result:=(not (c.status in [SC_OFFLINE, SC_UNK])) //and (not c.invisible)
              and (not c.icq2go)
              and (c.proto>7)
//              and (not ((getClientPicFor(c) = PIC_RNQ) and (getRnQVerFor(c) < 1053)))
              and ( (CAPS_sm_ICQSERVERRELAY in c.capabilitiesSm)
//                   or
//                    (CAPS_big_CryptMsg in c.capabilitiesBig)
                   )
end;

procedure TicqSession.sendCreateUIN(const acceptKey : RawByteString);
const
  s=#03#$46#0#0;
//  unk = #0#0#0#0;
  cook = #0#0#0#0;
begin
//sendSNAC(ICQ_BUCP_FAMILY, 4,
//  TLV(1, Z+#$28#0#3#0+Z+Z+s+s+Z+Z+Z+Z+WNTS(pwd)+s+#0#0#$CF#1));

 sendSNAC(ICQ_BUCP_FAMILY, 4,
  word_BEasStr(1)+word_BEasStr(50+length(pwd))+
  z+
  #$28#0#0#0+
  z+z+
  cook+
  cook+
  z+z+z+z+
  AnsiChar(length(pwd))+#0+ AnsiString(pwd)+
  cook+
  z+
  #0#9+Word_BEasStr(length(acceptKey))+acceptKey);
{
 sendSNAC(ICQ_BUCP_FAMILY, 4, TLV(1, Z+#$28#0#3#0
  z+z+
  cook+
  cook+
  z+z+z+z+
  word_LEasStr(length(pwd))+ pwd+#00
  cook
}  
end; // sendCreateUIN

function TicqSession.maxCharsFor(const c:TRnQcontact; isBin : Boolean = false):integer;
begin
{  if not c.isOnline then
//    result:=450
    result:=1000
   else}
  if useMsgType2for(TICQContact(c)) then result:=7000
   else result:=2540;
  with TICQContact(c) do
  begin
    if not isBin then
      if SendingUTF and (CAPS_sm_UTF8 in capabilitiesSm) then
        result := Result div 2;
    if UseCryptMsg and Crypt.supportCryptMsg then
      result := Result * 3 div 4;
  end;
end; // maxCharsFor

function TicqSession.imVisibleTo(c:TRnQcontact):boolean;
begin
 {$IFDEF UseNotSSI}
  if not useSSI then
     result:= //isOnline and
      (
       (visibility = VI_all) or
       ((visibility = VI_normal) and not fIntInvisibleList.exists(c)) or
       ((visibility = VI_privacy) and (fIntVisibleList.exists(c) or tempvisibleList.exists(c))) or
       ((visibility = VI_invisible) and tempvisibleList.exists(c))
      )
   else
 {$ENDIF UseNotSSI}
     result:= //isOnline and
      ((visibility = VI_all) or tempvisibleList.exists(c) or
         ((visibility = VI_privacy) and (fVisibleList.exists(c)))
      or
        ((visibility = VI_normal) and (not fInvisibleList.exists(c)))
      or
        ((visibility = VI_CL) and (fRoster.exists(c)))// not c.CntIsLocal)
//      or
//        ((visibility = VI_invisible) and tempvisibleList.exists(c))
       )
end; // imVisibleTo

function TicqSession.getLocalIPstr:string;
begin
//  try
   Result:=sock.GetXaddr;
   if compareText(result,'error')=0 then result:='';
//  except
//    result:='';
//  end;
end; // getLocalIPstr

function TicqSession.getLocalIP:integer;
begin
 try
  result:=WSocketResolveHost(getLocalIPstr).S_addr;
 except
  result:=0;
 end;
end;

procedure TicqSession.sendACK(cont : TICQContact; status:integer;
                              const msg:string; DownCnt: word = $FFFF);
var
//  s,tlv:string;
//  ofs:integer;
  mt : Byte;
  mtf : AnsiChar;
  msg2 : String;
  sutf, msg2Send : RawByteString;
begin
//  ofs:=11;
//  eventContact:=contactsDB.get(getBUIN2(snac,ofs));
  if not Assigned(cont) or not imVisibleTo(cont) then exit;

// Not answer to somebody not in list
  if not cont.isInRoster then
    Exit;

//  sutf := '';
  case status of
    ACK_OCCUPIED,
    ACK_DND,
    ACK_AWAY,
    ACK_NA:
      begin
        if cont.SendTransl then
          msg2 := Translit(msg)
         else
          msg2 := msg;
        eventMsgA := StrToUTF8(msg2);
        notifyListeners(IE_sendingAutomsg);
        msg2 := UnUTF(eventMsgA);
        if CAPS_sm_UTF8 in cont.capabilitiesSm then
          begin
  //        sutf := Length_DLE(GUIDToString(msgUtf));
            sutf := Length_DLE(msgUTFstr);
            msg2Send := StrToUTF8(msg2);
          end
         else
          msg2Send := msg2; // In ANSI
      end
      ;
   end;
  if Length(msg2Send) > 8000 then
   msg2Send := copy(msg2Send, 1, 8000);
{inc(ofs, 4);
tlv:=getTLV(5, snac,ofs);
tlv:=getTLV($2711, tlv,1+2+8+16);
s:=copy(tlv,1,47);  // chunk1+chunk2+msgtype+msgflags
s[27]:=#0;  // zeroes firewall details
s:=s+Dword_LEasStr(status)+WNTS(msg);
case ord(tlv[46]) of
  MTYPE_PLAIN: s:=s+ Z+#$FF#$FF#$FF#$FF;
  MTYPE_PLUGIN:
    begin
    ofs:=pos('Greeting Card',tlv)-4-20;
    s:=s+ copy(tlv, ofs, 4+20+length('Greeting Card')+7) +Z;
    end;
  MTYPE_FILEREQ: s:=s+ Z+#$01#$00#$00#$C8#$06#$C9#$00+Z;
  end;
sendSNAC(ICQ_MSG_FAMILY, $B, copy(snac, 1, 11+ord(snac[11]))+#0#3 +s);
}
    mtf := #03;
case status of
  ACK_OCCUPIED: mt := MTYPE_AUTOBUSY;
  ACK_DND: mt :=MTYPE_AUTODND;
  ACK_NA: mt := MTYPE_AUTONA;
//  ACK_: mt := MTYPE_AUTONA;
  ACK_AWAY: mt := MTYPE_AUTOAWAY;
  else
   begin
    mt := MTYPE_PLAIN;
    mtf := #00;
   end;
  end;

  if (CAPS_sm_ICQSERVERRELAY in cont.capabilitiesSm) then

    sendSNAC(ICQ_MSG_FAMILY, $0B, //qword_LEasStr(SNACref)
  //     copy(snac, 1, 11+ord(snac[11]))
       int2str64(eventMsgID)
       +#0#2
       + cont.buin
      +#0#3
      + header2711_0 + #03#00#00#00
      + #00 + word_LEasStr(DownCnt) + #$E#00 + word_LEasStr(DownCnt)+Z+Z+Z
      + AnsiChar(mt) + mtf
      + z
      + WNTS(msg2Send)
          +z+dword_LEasStr($FFFFFF)
          +sutf

  //    +TLV(3,'')
    )
  else
    sendSNAC(ICQ_MSG_FAMILY, $0B, //qword_LEasStr(SNACref)
  //     copy(snac, 1, 11+ord(snac[11]))
       int2str64(eventMsgID)
       +#0#1 // word	 	message channel
       + cont.buin
       +#0#3 //  	reason code
       + #05#01 + Length_BE('')
       + #01#01 + Length_BE(#00#00 + #$FF#$FF + msg2Send)
    )

end; // sendACK

procedure TicqSession.sendMyXStatus(cont : TICQContact; msgID : Int64);
//const
//  ch = '11';
var
  sR: RawByteString;
  title, msg : RawByteString;
  s1 : RawByteString;
//  ofs:integer;
begin
//ofs:=11;
//eventContact := cont;
 if curXStatus = 0 then exit;

//if (title ='') and (msg = '') then exit;
 if not imVisibleTo(cont) then exit;

    eventInt := curXStatus;
//    title := strToUtf8(getTranslation(ExtStsStrings[curXStatus].Cap));
//    eventNameA := strToUtf8(ExtStsStrings[curXStatus].Cap);
    eventNameA := '';
    eventMsgA := strToUtf8(curXStatusStr.Desc);
//    msg := AnsiToUtf8( applyVars(cont, curXStatusDesc));

//    msg := strToUtf8( getXStatusMsgFor(cont));
    msg := '';
    eventContact := cont;
    notifyListeners(IE_sendingXStatus);

//    title := eventNameA;
    title := '';
    msg   := eventMsgA;

 if (title ='') and (msg = '') then exit;

  s1 := '<ret event=''OnRemoteNotification''><srv>'+
         '<id>cAwaySrv</id><val srv_id=''cAwaySrv''>' +
         '<Root><CASXtraSetAwayMessage></CASXtraSetAwayMessage>'+
           '<uin>' + myAccount +
           '</uin><index>' + AnsiString(intToStr(curXStatus)) + '</index>' +
           '<title>' + title + '</title><desc>'+msg+'</desc>' +
         '</Root>..</val></srv>'+
         '<srv><id>cRandomizerSrv</id>'+
           '<val srv_id=''cRandomizerSrv''>undefined</val>'+
         '</srv></ret>'
 ;
//  s := #0#2 +BUIN(cont.uid) + #00#03
  sR := #0#2 + cont.buin + #00#03
        + header2711_1+ AnsiChar(MTYPE_PLUGIN)+#00+
        word_LEasStr(getFullStatusCode)
        +#00#00
        +WNTS('')
        + Length_LE(MsgCapabilities[1]
           + #$08#$00
           + Length_DLE(Plugin_Script)
           + #$00#$00#$01 + z+z+z)
        + Length_DLE(Length_DLE(
         '<NR><RES>'+ str2html2(s1) +'</RES></NR>'+CRLF))
    ;
//  sendMSGsnac(cont.uin, s);
  sendSNAC(ICQ_MSG_FAMILY, $0B, qword_LEasStr(msgID)
    + sR);
//    +TLV(3,'')
//  );
end; // sendACK10

procedure TicqSession.setWebaware(value: boolean);
begin
  P_webaware := value;
//  sendPermsNew;
//sendStatusCode;
end; // setWebaware

procedure TicqSession.setAuthNeeded(value: boolean);
begin
  P_authNeeded := value;
//  sendPermsNew;
//  sendPermissions;
end; // setAuthNeeded

procedure TicqSession.setVisibility(v: Tvisibility);
begin
 {$IFDEF UseNotSSI}
  if not useSSI and (v = VI_CL) then
    v := VI_normal;
 {$ENDIF UseNotSSI}
{  if Assigned(myInfo) then
   case v of
    VI_invisible,
    VI_privacy: myinfo.invisible := True;
    VI_normal,
    VI_all,
    VI_CL: myinfo.invisible := False;
   end;}
  fVisibility := v;
  startingVisibility := v;
  if {((fVisibility <> v) or MustSend)and} isOnline then
   begin
//    fVisibility := v;
//    sendVisibility;
    if
 {$IFDEF UseNotSSI}
     useSSI and
 {$ENDIF UseNotSSI}
     not showInvisSts
    then
      sendVisibility
     else
      sendStatusCode;
   end
{  else
   begin
    fVisibility := v;
    startingVisibility := v;
   end};
  eventContact:=NIL;
  notifyListeners(IE_visibilityChanged);
end;

function TicqSession.IsInvisible : Boolean;
begin
   case fVisibility of
    VI_invisible,
    VI_privacy: Result := True;
//    VI_normal,
//    VI_all,
//    VI_CL: myinfo.invisible := False;
    else
      result := false;
   end;
end;

 {$IFDEF UseNotSSI}
procedure TicqSession.updateVisibility;
begin
 if not useSSI then
  case Self.visibility of
    VI_invisible: Self.setVisibleList(NIL);
    VI_all: Self.setInvisibleList(NIL);
    VI_privacy, VI_normal:
      begin
      Self.setVisibleList(fVisibleList);
      Self.setInvisibleList(fInvisibleList);
      end;
    end;
end; // updateICQvisibility
 {$ENDIF UseNotSSI}



function TicqSession.addRef(k:TrefKind; const uin:TUID):integer;
begin
result:=SNACref;
refs[SNACref].kind:=k;
refs[SNACref].uid:=uin;
inc(SNACref);
if SNACref > maxRefs then
  SNACref:=1;
end; // addRef

function TicqSession.dontBotherStatus:boolean;
begin result:=getStatus in [byte(SC_occupied), byte(SC_dnd)] end;

procedure TicqSession.parse010F(const snac: RawByteString);
var
//  ofs:integer;
  s : RawByteString;
//  s:string;
  ofs, t, i, l :integer;
  TLVCnt : Word;
begin
 ofs := 1;
//  if snac[ofs] = #0 then
//    getBEWNTS(snac, ofs);             //I Don't know WHAT IS THAT!!!
// ofs:=ord(snac[ofs])+5;
 eventContact:= getICQContact(getBUIN2(snac,ofs));
  inc(ofs, 2);
  TLVCnt := readBEWORD(snac, ofs);

  t := ofs;
  i := 0;
  l := Length(snac);
  while (i < TLVCnt)and (t < l) do
   begin
//    inc(t, 2);
//    t := findTLV(5, snac,ofs);
    inc(t, word_BEat(snac, t+2) + 4);
    inc(i);
   end;
  s := Copy(snac, ofs, t-ofs);
//  Delete(snac, ofs, t-ofs);
//  ofs := 1;
  parseOnlineInfo(s, 1, eventContact, True, True, false);
  s := '';

//  parseOnlineInfo(snac, ofs, eventContact, True, True);
(*
 if existsTLV(3, snac,ofs) then
   myinfo.onlineSince:=UnixToDateTime(getTLVdwordBE(3, snac,ofs))+GMToffset
  else
   myinfo.onlineSince:=0;
 if existsTLV(2, snac,ofs) then
  myinfo.memberSince:=UnixToDateTime(getTLVdwordBE(2, snac,ofs));

 {$IFDEF RNQ_AVATARS}
if existsTLV($1D, snac,ofs) then
  begin
   s:=getTLV($1D, snac,ofs);
   if s > '' then
     begin
//	with eventContact do
      eventContact.Icon.ID := word_BEat(@s[1]);
      eventContact.Icon.Flags := Byte(s[3]);
      eventContact.Icon.HL := Byte(s[4]);
      eventContact.Icon.hash := copy(s,5, eventContact.Icon.HL);
      if eventContact.Icon.hash = AvtHash_NoAvt then
        eventContact.Icon.hash := '';
      if (Length(eventContact.Icon.hash) = 16) and (eventContact.Icon.hash <> eventContact.Icon.hash_safe)then
        notifyListeners(IE_avatar_changed);

     end;
  end;
{$ENDIF}

 if existsTLV($0A, snac,ofs) then
  myinfo.connection.ip:=UnixToDateTime(getTLVdwordBE(2, snac,ofs));
*)  
end; // parse010F

procedure TicqSession.parse0206(snac : RawByteString);
var
//  uin : Integer;
  ofs, i, l : Integer;
//  h :  Integer;
  TLVCnt, t : Word;
  found : Boolean;
  s, cap :  RawByteString;
//  ctt : Tcontact;
begin
  eventFlags:=0;
  eventTime:=now;
  ofs:=1;
  eventContact:= getICQContact(getBUIN2(snac,ofs));
  inc(ofs, 2);
  TLVCnt := readBEWORD(snac, ofs);
  t := ofs;
  i := 0;
  l := Length(snac);
  while (i < TLVCnt)and (t < l) do
   begin
//    inc(t, 2);
//    t := findTLV(5, snac,ofs);
    inc(t, word_BEat(@snac[t+2]) + 4);
//      h := word_BEat(@snac[t+2];
//      inc(t, h + 4);
    inc(i);
   end;
  s := Copy(snac, ofs, t-ofs);
  Delete(snac, ofs, t-ofs);
//  ofs := ;
  if TLVCnt > 1 then
    parseOnlineInfo(s, 1, eventContact, false, false)
   else
    if eventContact.invisibleState = 2 then
     begin
       eventContact.prevStatus  := eventContact.status;
       eventOldStatus   := eventContact.status;
       eventOldInvisible:= eventContact.invisible;
       eventContact.status := SC_OFFLINE;
       eventContact.invisible := false;
//      eventContact.invisibleState := 0;
      notifyListeners(IE_statuschanged);
     end;
  s := '';

 i := findTLV($05, snac,ofs);
 if i>0 then
 	with eventContact do
	  begin
     s:=getTLV(@snac[i]);
     t := 0;
       capabilitiesBig:=[];
       capabilitiesSm:=[];
       capabilitiesXTraz := [];
       extracapabilities:='';
      while s > '' do
        begin
        cap:=copy(s,1,16);
        delete(s,1,16);
        found:=FALSE;
        for i:=1 to length(BigCapability) do
          if cap = BigCapability[i].v then
            begin
             include(capabilitiesBig,i);
             found:=TRUE;
             break;
            end;
        if copy(cap, 1, 2) = CapsMakeBig1 then
          if copy(cap, 5, 12) = CapsMakeBig2 then
           begin
             cap := copy(cap, 3, 2);
             for i:=1 to length(CapsSmall) do
              if cap = CapsSmall[i].v then
              begin
                 include(capabilitiesSm,i);
                 found:=TRUE;
                 break;
              end;
           end;
        if not found then
         begin
           for i:= 1 to High(XStatusArray) do
            if xsf_Old in XStatusArray[i].flags then
             if cap = XStatusArray[i].pidOld then
              begin
               include(capabilitiesXTraz,i);
               found := TRUE;
               break;
              end;
         end;
      if not found then
          extracapabilities:=extracapabilities+cap;
        end;
	  // temporary fix for icq2go, this prevents from using type-2 messages
	   icq2go:=(CAPS_sm_UTF8 in capabilitiesSm) and not (CAPS_sm_ICQSERVERRELAY in capabilitiesSm);
      if not (CAPS_sm_ICQSERVERRELAY in capabilitiesSm) then
        icq2go := True;
     if CAPS_big_Tril in capabilitiesBig then icq2go := true;
     if (proto = 8) and (CAPS_big_Lite in capabilitiesBig) then icq2go := true;
     
     if CAPS_big_MTN in capabilitiesBig then typing.bSupport := True;
{     if xStatus <> t then
       begin
//        status_changed := True;
        xStatus := t;
        xStatusStr := '';
        xStatusDecs := '';
       end;}
	  end;
 for I in eventContact.capabilitiesXTraz do
 if (eventContact.xStatus <> i) then
  begin
    begin
//      status_changed := True;
      eventContact.xStatus := i;
    end;
  end;

  eventContact.Crypt.supportCryptMsg := CAPS_big_CryptMsg in eventContact.capabilitiesBig;

//  getTLV()
end;

procedure TicqSession.parse020C(const snac : RawByteString; ref : Integer);
//var
//  uin : Integer;
//  ofs : Integer;
//  ctt : Tcontact;
begin
  eventMsgID:=ref;
  eventInt:=word_BEat(@snac[1]);
//  event
  notifyListeners(IE_srvSomeInfo);
end;

procedure TicqSession.parse040A(const snac: RawByteString);
var
  ofs, i, l:integer;
//  accept:byte;
  MissedType : Word;
  uid : TUID;
begin
  ofs:=1;
  MissedType := readWORD(snac, ofs);
  uid := getBUIN2(snac, ofs);
  eventFlags := readWORD(snac, ofs);
  eventContact:= getICQContact(uid);
  l := readWORD(snac, ofs);
  for I := 0 to l - 1 do
   begin
    inc(ofs, 2);
    inc(ofs, readWORD(snac, ofs));
   end;
//    eventFileSize := readWORD(snac, ofs);
  eventMsgID := readWORD(snac, ofs);
  eventInt := readWORD(snac, ofs);
  notifyListeners(IE_Missed_MSG);

///////////////////////////////// ДОПИСАТЬ!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
{  eventInt:=dword_LEat(@snac[ofs]);
  inc(ofs, 10+1+ord(snac[11])+2+47);
  accept:=ord(snac[ofs]);
  inc(ofs,4);
  eventMsg:=getWNTS(snac,ofs);
  eventContact:=contactsDB.get(refs[eventInt].uin);
  eventOldStatus:=eventContact.status;
  eventOldInvisible:=eventContact.invisible;}
end;
// auto-messages
procedure TicqSession.parse040B(const snac: RawByteString);
var
  ofs, k:integer;
  accept:byte;
  channel : word;
  uin : TUID;

//  CharsetNumber, CharsetSubset : Word;
  priority, msgtype, msgflags, TypeId :byte;
  msgLen : dword;
  PlugNameLen : longWord;
//  msg : String;
  PlugName : AnsiString;
  Plugin : AnsiString;
//  Cap : String[16];

  s2 : RawByteString;
begin
  eventFlags := 0;
  ofs:=1;
  eventInt := dword_LEat(@snac[ofs]);
  eventMsgID := readQWORD(snac, ofs);
//  ofs:=9;
  channel := readBEWORD(snac, ofs);
  uin := getBUIN2(snac, ofs);
  eventContact := getICQContact(uin);
  //  uin := Copy(snac, 12, ord(snac[11]));
  //inc(ofs, 10+1+ord(snac[11])+2+47);
  inc(ofs, 2);
  if channel = 2 then
  begin
//    some := getWNTS
    if Length(snac) > ofs+4+6 then
      begin
        inc(ofs, word_LEat(@snac[ofs])+2);
        inc(ofs, word_LEat(@snac[ofs])+2);
        msgtype := Byte(snac[ofs]);
        msgflags:= Byte(snac[ofs+1]);
        priority:= Byte(snac[ofs+4]);
        inc(ofs,6);
        eventMsgA := getWNTS(snac, ofs);
      end
     else
      begin
        msgtype := 0;
        msgflags:= 0;
        priority:= 0;
        eventMsgA := '';
      end;
      // here we can be bothered :P
{      if msgtype=MTYPE_FILEREQ then
        begin
        eventcontact.ft_port:=word_BEat(@snac[ofs]);
        inc(ofs, 4);
        eventFilename:=getWNTS(snac, ofs);
        eventInt:=dword_LEat(@snac[ofs]);
  //      if eventFilename > '' then
  //        notifyListeners(IE_filereq)
  //      else
          if refs[eventMsgID].kind = REF_file then
            notifyListeners(IE_fileok);
        exit;
        end;}
      if msgtype=MTYPE_PLUGIN then
       begin
  //        debug_Snac(snac, 'FileSend.snac');
         inc(ofs, 2);
         Plugin := copy(snac, ofs, 16);
         inc(ofs, 16); inc(ofs, 2);
         PlugNameLen := dword_LEat(@snac[ofs]);
         inc(ofs, 4);
         PlugName := copy(snac, ofs, PlugNameLen);
         inc(ofs, PlugNameLen);
         TypeId := TypeStringToTypeId(PlugName);
 {          if TypeId = MTYPE_FILEREQ then
           begin
             inc(ofs, 19);
  //          eventport:=word_BEat(@snac[ofs]);
            inc(ofs, 2);
  //          FFSeq2 := word_BEat(@snac[ofs]);
            inc(ofs, 2);
            inc(ofs, 4);
            eventFilename := getWNTS(snac, ofs);
            eventFileSize := dword_LEat(@snac[ofs]);
            inc(ofs, 4);
            if eventFilename > '' then
              notifyListeners(IE_filereq)
            else
              if refs[eventMsgID].kind = REF_file then
                notifyListeners(IE_fileok);
           end
           else }
           if TypeId in [MTYPE_PLAIN, MTYPE_AUTOAWAY] then
            begin
              inc(ofs, 6);
              inc(ofs, 9);
  //            len := dword_LEat(@snac[ofs]);
              inc(ofs, 4);

              msglen := dword_LEat(@snac[ofs]);
              inc(ofs, 4);
              eventMsgA := copy(snac,ofs,msglen);
//              notificationForMsg(TypeId, msgflags, priority=2, msg, FALSE);

            end 
           else
           if TypeId = MTYPE_XSTATUS then
            begin
              if Pos(PLUGIN_SCRIPT, snac) > 0 then
              begin
               eventContact := getICQContact(uin);
               eventTime := now;
               s2 := copy(snac, ofs, length(snac)-ofs);
               ofs := Pos(AnsiString('title&gt;'), s2);
               if ofs > 0 then
                begin
                 ofs := ofs + length('title&gt;');
                 k := Pos(AnsiString('&lt;/title'), s2);
                 if (k > ofs) then
//                  eventMsg := unUTF(copy(snac, ofs, k-ofs))
                  eventMsgA := copy(s2, ofs, k-ofs) // In UTF8!
                 else
                  eventMsgA := '';
                end
                else
                 eventMsgA := '';
               ofs := Pos(AnsiString('&lt;desc&gt;'), s2);
               if ofs > 0 then
                 begin
                  ofs := ofs + length('&lt;desc&gt;');
                  k := Pos(AnsiString('&lt;/desc&gt;'), s2);
                  if (k > ofs) then
                   eventData := copy(s2, ofs, k-ofs)
                  else
                   eventData := '';
                 end
                else
                  eventData := '';
               notifyListeners(IE_ackXStatus);
               exit;
              end;

              exit;
            end
  //        else if TypeId =
  {                  Inc(Pkt^.Len, 19);
                    fDesc := GetDWStr(Pkt);
                    aPort := GetInt(Pkt, 2);
                    FFSeq2:= GetInt(Pkt, 2);
                    fName := GetWStr(Pkt);
                    fSize := GetInt(Pkt, 4);
  }        else if TypeId = MTYPE_GCARD then
            parseGCdata( copy(snac, ofs, length(snac)) )

         //(cap = MsgCapabilities[1]))
  //       Capabs := copy(msg, MsgOfs, 4);
       end
{      else
  //     if msgtype =  then
        notificationForMsg(msgtype, msgflags, priority=2, msg, FALSE);
}
  end
  else
   begin
    if length(snac) > (ofs + 47) then
      begin
       inc(ofs, 47);
       accept:= Byte(snac[ofs]);
       inc(ofs,4);
//    eventMsg:= UnUTF(getWNTS(snac,ofs));
       eventMsgA:= getWNTS(snac,ofs);
       eventContact:= getICQContact(refs[eventInt].uid);
      end
     else
      begin
       accept:= 0;
       eventMsgA:= '';
       eventContact := getICQContact(uin);
      end;
    eventOldStatus:=eventContact.status;
    eventOldInvisible:=eventContact.invisible;
    case accept of
      $0,$C: eventAccept:=AC_ok;
      $9:
        begin
        eventContact.status:=SC_occupied;
        eventAccept:=AC_denied;
        end;
      $A:
        begin
        eventContact.status:=SC_dnd;
        eventAccept:=AC_denied;
        end;
      $4:
        begin
        eventContact.status:=SC_away;
        eventAccept:=AC_away;
        end;
      $E:
        begin
        eventContact.status:=SC_na;
        eventAccept:=AC_away;
        end;
      end;
    if eventOldStatus<>eventContact.status then
      eventContact.prevStatus:=eventContact.status;
    if (eventOldStatus<>eventContact.status) or (eventOldInvisible<>eventContact.invisible) then
      begin
      eventFlags:=0;
      eventTime:=now;
      notifyListeners(IE_statuschanged);
      end;

   end;
  if (eventInt >= Low(refs))
     and  (eventInt <= High(refs)) then
  case refs[eventInt].kind of
    REF_file:
      begin
      notifyListeners(IE_fileDenied);
      exit;
      end;
    REF_msg, REF_contacts:
      begin
      refs[eventInt].kind:=REF_null;
      notifyListeners(IE_ack);
      end;
    end;
// ofs  := pos(MsgCapabilities[1], snac);
// if ofs > 0 then
//   begin
//     ofs := ofs +1+ dword_LEat(@snac[ofs-2]);
//   end;
end; // parse040B

{$IFDEF usesDC}
function TicqSession.getNewDirect : TProtoDirect;
begin
  Result := TICQdirect.Create;
//  Result.directs :=
end;

function TicqSession.directTo(c:TICQcontact): TICQdirect;
begin result:= TICQdirect(directs.newFor(c)) end;
{$ENDIF usesDC}

function TicqSession.serverPort:word;
{$IFDEF usesDC}
//var
//  s : String;
//  p : Integer;
{$ENDIF usesDC}
begin
  try
{$IFDEF usesDC}
//    s := server.getxport;
//    if (s <> '') and (TryStrToInt(s, p)) then
//      result:=p
//    else
{$ENDIF usesDC}
      result:=0;
  except result:=0
  end
end;

function TicqSession.serverStart:word;
begin
if (DCmode = DC_none)or(DCmode = DC_FAKE) then
  begin
  result:=0;
  exit;
  end;
{$IFDEF usesDC}
{server.port:='0';
server.addr:='0.0.0.0';
server.listen;
}
{$ENDIF usesDC}
result:=serverPort;
end; // serverStart

{function TicqSession.getIPasDword_BE:string;
var
  saddr:TSockAddrIn;
  l:integer;
begin
l:=sizeOf(saddr);
if sock.GetSockName(saddr,l)=0 then
  with saddr.sin_addr.s_un_b do
    result:=s_b1+s_b2+s_b3+s_b4
else
  result:=''
end; // getIPasDword_BE
}

//procedure TicqSession.connect;
//begin connect(FALSE) end;

procedure TicqSession.connect;//(createUIN:boolean; avt_session : Boolean = false);
begin
 if not isOffline then exit;
// if (not avt_session) then
// if protoType <> SESS_AVATARS then
  if (protoType = SESS_IM) and
     (((fPwd = '') and (fPwdHash= ''))or (MyAccount='')) then
  begin
   eventError:=EC_missingLogin;
   notifyListeners(IE_error);
   exit;
  end;
// creatingUIN := createUIN;
// isAvatarSession := avt_session;
 {$IFDEF UseNotSSI}
  fUseSSI := useSSI2;
  fUseLSI := useLSI2;
 {$ENDIF UseNotSSI}

 sock.Close;
 sock.WaitForClose;  // prevent to change properties while the socket is open

 sock.proto:='tcp';
{ if sock.http.enabled then
  begin
   sock.Addr:= sock.http.addr;
   sock.Port:= sock.http.port;
  end
 else
}
// if avt_session then
 if (protoType = SESS_AVATARS) then
  begin
   sock.addr:=serviceServerAddr;
   sock.port:=serviceServerPort;
   CopyProxy(aProxy, MainProxy);
  end
 else
  begin
   sock.addr := loginServerAddr;
   sock.port := loginServerPort;
  end;
// if avt_session then
 if (protoType = SESS_AVATARS) then
  phase:= relogin_
 else
  phase:=CONNECTING_;
// sock.MultiThreaded := True; 
 eventAddress := sock.AddrPort;
 notifyListeners(IE_connecting);
 try
  // Need make asynchronized call
  sock.Connect
 except
  on E:Exception do
   begin
     eventMsgA := E.Message;
     eventError:=EC_cantconnect;
     eventInt:=WSocket_WSAGetLastError;
     notifyListeners(IE_error);
     goneOffline;
   end
  else
   begin
    eventMsgA := '';
    eventError:=EC_cantconnect;
    eventInt:=WSocket_WSAGetLastError;
    eventMsgA := WSocketErrorDesc(eventInt);
    notifyListeners(IE_error);
    goneOffline;
   end;
 end;
end; // connect

// Get session data for web login
procedure TicqSession.refreshSessionSecret();
var
  fs: TMemoryStream;
  session: RawByteString;
  Params, KeyValPair: TStringList;
  i: Integer;
begin
  if not (MyAccNum = '') and not (fPwd = '') then
  begin
    fs := TMemoryStream.Create;
    LoadFromUrl('https://api.login.icq.net/auth/clientLogin', fs, 0, false, true,
                'devId=ic1nmMjqg7Yu-0hL&f=qs&s=' + String(MyAccNum) + '&pwd=' + fPwd, false);
    SetLength(session, fs.Size);
    fs.ReadBuffer(session[1], fs.Size);
    fs.Free;

    Params := TStringList.Create;
    KeyValPair := TStringList.Create;
    try
      Params.Delimiter := '&';
      Params.StrictDelimiter := true;
      Params.DelimitedText := UTF8ToStr(session);

      KeyValPair.Delimiter := '=';
      KeyValPair.StrictDelimiter := true;

      for i := 0 to Params.Count -1 do
      begin
        KeyValPair.Clear;
        KeyValPair.DelimitedText := UTF8ToStr(StringReplace(Params.Strings[i], '+', ' ', [rfReplaceAll]));
        if KeyValPair.Count >= 2 then
        begin
          if (KeyValPair.Strings[0] = 'statusCode') then
            if not ((KeyValPair.Strings[1] = '200') or (KeyValPair.Strings[1] = '304')) then Break;
          if (KeyValPair.Strings[0] = 'statusText') then
            if not (KeyValPair.Strings[1] = 'OK') then Break;

          if (KeyValPair.Strings[0] = 'token_a') then
            fSessionToken := KeyValPair.Strings[1];
          if (KeyValPair.Strings[0] = 'token_expiresIn') then
            TryStrToInt(KeyValPair.Strings[1], fSessionTokenExpIn);
          if (KeyValPair.Strings[0] = 'hostTime') then
            TryStrToInt(KeyValPair.Strings[1], fSessionTokenTime);
          if (KeyValPair.Strings[0] = 'sessionSecret') then
            fSessionSecret := KeyValPair.Strings[1];
        end;
      end;
    finally
      Params.Free;
    end;
  end;
end;

function Ticqsession.getFullStatusCode:dword;
begin
  result:=0;
  case DCmode of
    DC_roster: inc(result, flag_dcForRoster);
    DC_uponauth, DC_none : inc(result, flag_dcByRequest);
  //  DC_none: inc(result, flag_dcForNone);
    end;
  if webaware then inc(result, flag_webaware);
  if birthdayFlag then inc(result, flag_birthday);
  if
 {$IFDEF UseNotSSI}
   not useSSI or
 {$ENDIF UseNotSSI}
   showInvisSts
  then
    if isInvisible then inc(result, flag_invisible);
  inc(result, status2code[curStatus]);
end; // getFullStatusCode

procedure TicqSession.SetListener(l : TProtoNotify);
begin
  listener := l;
  if (protoType = SESS_IM) and Assigned(avt_icq) then
    avt_icq.listener := l;
end;


procedure TicqSession.setDCmode(v:TicqDCmode);
begin
  if P_dcmode<>v then
   begin
    P_dcmode:=v;
    serverStart;
//    sendStatusCode(false);
   end;
end; // setDCmode

function Ticqsession.getDCModeStr : AnsiString;
begin
 case DCmode of
   DC_NONE     : result := '0';
   DC_UPONAUTH : result := '1';
   DC_ROSTER  : result := '2';
   DC_EVERYONE : result := '3';
   DC_FAKE     : Result := '4';
 end;
end;

procedure Ticqsession.set_DCfakeIP(ip : in_addr);
begin
  fDC_Fake_ip := ip;
  if DCmode = DC_FAKE then
    sendStatusCode(false);
end;

procedure Ticqsession.setDCfakeIP(ip : AnsiString);
begin
  fDC_Fake_ip.S_addr := inet_addr(pAnsiChar(ip));
  if DCmode = DC_FAKE then
    sendStatusCode(false);
end;

function Ticqsession.getDCfakeIP : AnsiString;
begin
  Result := inet_ntoa(fDC_Fake_ip);
end;

procedure Ticqsession.setDCfakePort(port: Word);
begin
  fDC_Fake_port := port;
  if DCmode = DC_FAKE then
    sendStatusCode(false);
end;

function Ticqsession.getDCfakePort : Integer;
begin
  Result := fDC_Fake_port;
end;

function TicqSession.CheckInvisibility2(const uin : TUID ) : Integer;
//var
// id : integer;
begin
{
  sendSNAC(ICQ_MSG_FAMILY, CLI_META_MSG, qword_LEasStr(SNACref)+#0#2
    +BUIN(uin)
     + word_BEasStr(5)+word_BEasStr($60)
//          +TLV(5, #0#0+//qword_LEasStr(SNACref)//+capability[1]
      + #0#0 + qword_LEasStr(0) + z+z+Chr(Random(200))+#0+Chr(Random(200))+#0+z
//      + #0#0 + qword_LEasStr(0) + z+z+z+z
      +TLV($A,#0#1)
      +TLV($F,'')
//            +TLV($2711,
        + word_BEasStr($2711)+word_BEasStr($38)+
        header2711_2+//char(MTYPE_PLAIN)+flagChar+
        #$E8 + #03+
        word_LEasStr(getFullStatusCode)//  +priorityChar+#0
        +#00+#$21
        +#3+#0
        + #0 + #01 + #00 +#00 +#06 +#00+#00
//              +WNTS('')
//              +dword_LEasStr(0)+dword_LEasStr($FFFFFF)
//            )
//          )
  );
{  sendSNAC(ICQ_LOCATION_FAMILY, $15, //qword_LEasStr(SNACref) +
  #0#0#0#5 +BUIN(uin)
  );
}
{  sendSNAC(ICQ_MSG_FAMILY, CLI_META_MSG, qword_LEasStr(SNACref)+#0#2
    +BUIN(uin)
    +TLV(6, '')
  );
}
  sendSNAC(ICQ_MSG_FAMILY, CLI_META_MSG, qword_LEasStr(SNACref)+#0#4
    + Length_B(uin)
//    +TLV(5, word_LEasStr(myInfo.uin)+#$09 + #$07 + #$07+ #0#0#0)
    +TLV(5, myUINle+ #$07+ #0#0#0)
  );
//  sendSNAC(ICQ_LOCATION_FAMILY, $0B, chr(Length('R@p|d D')) + 'R@p|d D');
//  sendSNAC(ICQ_LOCATION_FAMILY, $0B, chr(Length('RapidD2006')) + 'RapidD2006');

 sendSnac(ICQ_LOCATION_FAMILY, $05, word_BEasStr(04)+ Length_B(uin));
// sendSnac(ICQ_LOCATION_FAMILY, $05, word_LEasStr(05)+ BUIN(uin));
  result := addRef(REF_msg,uin);
//  acks.add(OE_msg, uin, 0, 'Inv').ID := id;
//  result := 0;
end;

function TicqSession.CheckInvisibility3(const uin : TUID ) : Integer;
begin
  Result := -1;
end;

function TicqSession.getUINStatus(const uin : TUID ) : Integer;
//var
// id : integer;
begin
{
  sendSNAC(ICQ_MSG_FAMILY, CLI_META_MSG, qword_LEasStr(SNACref)+#0#2
    +BUIN(uin)
     + word_BEasStr(5)+word_BEasStr($60)
//          +TLV(5, #0#0+//qword_LEasStr(SNACref)//+capability[1]
      + #0#0 + qword_LEasStr(0) + z+z+Chr(Random(200))+#0+Chr(Random(200))+#0+z
//      + #0#0 + qword_LEasStr(0) + z+z+z+z
      +TLV($A,#0#1)
      +TLV($F,'')
//            +TLV($2711,
        + word_BEasStr($2711)+word_BEasStr($38)+
        header2711_2+//char(MTYPE_PLAIN)+flagChar+
        #$E8 + #03+
        word_LEasStr(getFullStatusCode)//  +priorityChar+#0
        +#00+#$21
        +#3+#0
        + #0 + #01 + #00 +#00 +#06 +#00+#00
//              +WNTS('')
//              +dword_LEasStr(0)+dword_LEasStr($FFFFFF)
//            )
//          )
  );
{
  sendSNAC(ICQ_LOCATION_FAMILY, $15, //qword_LEasStr(SNACref) +
    word_BEasStr(05) + //
    BUIN(uin)
  );
{
  sendSNAC(ICQ_MSG_FAMILY, CLI_META_MSG, qword_LEasStr(SNACref)+#0#2
    +BUIN(uin)
    +TLV(6, '')
  );
}
 sendSnac(ICQ_LOCATION_FAMILY, $05, word_BEasStr(04)+ Length_B(uin));
{
SIG	0x00000001	The AIM signature
UNAVAILABLE	0x00000002	The away message
CAPABILITIES	0x00000004	CAPABILITIES UUID array; short caps will be represented in long form
CERTS	0x00000008	The CERT Blob
HTML_INFO	0x00000400	Return HTML formatted Buddy Info page
}
// sendSnac(ICQ_LOCATION_FAMILY, $05, word_LEasStr(05)+ BUIN(uin));
  result := addRef(REF_msg,uin);
//  acks.add(OE_msg, uin, 0, 'Inv').ID := id;
//  result := 0;
end;

procedure TicqSession.SendTYPING(cnt : TRnQContact; notif_type : Word);
begin
  if (not isOnline) or (not imVisibleTo(cnt)) then exit;
  sendSNAC(ICQ_MSG_FAMILY, $14, qword_LEasStr(0) + #00#01 + cnt.buin + word_BEasStr(notif_type))
end;

{This command requests the server side contact list.
It has no parameters, and always causes SRV_REPLYROSTER (rather than
SRV_REPLYROSTEROK). My guess is that CLI_REQROSTER is sent instead of
CLI_CHECKROSTER when the client does not have a cached copy of the contact
list; ie, the first time a user logs in with a particular client.}
procedure TicqSession.RequestContactList(isImp : Boolean = True);
begin
  if not isOnline then Exit;
  isImpCL := isImp;
  CLPktNUM := 0;
//  if not isImpCL then
//  begin
//    ImpCL := TcontactList.Create;
//    ListLoaded := false;
//  end;
//  icq.sendFLAP(SNAC_CHANNEL, SNAC($13, $04, 0, $00010004));
  sendSNAC(ICQ_LISTS_FAMILY, $04, '');
end;


procedure TicqSession.RemoveMeFromHisCL(const uin : TUID);
begin
  sendSNAC(ICQ_LISTS_FAMILY, $16, Length_B(uin));
end;

procedure TicqSession.AuthGrant(cnt : TRnQContact);
begin
  sendSNAC(ICQ_LISTS_FAMILY, $14, cnt.BUIN + Length_BE('Hi') + #00#00);
end;

procedure TicqSession.SSIAuth_REPLY(const uin : TUID; isAccept : Boolean; const msg : String = '');
const
  ReplyType : array[False..True] of AnsiChar = (#$00, #$01);
var
  str1 : RawByteString;
begin
  if isAccept then
    str1 := ''
   else
    str1 := StrToUTF8(msg);
  sendSNAC(ICQ_LISTS_FAMILY, $1A, Length_B(uin) + ReplyType[isAccept] + Length_BE(str1))
end;

procedure TicqSession.parseTYPING_NOTIFICATION(const pkt : RawByteString);
var
  ofs : Integer;
begin
 try
  ofs := 1;
  eventMsgID :=
    readQWORD(pkt, ofs);
    readWORD(pkt, ofs);
  eventContact := getICQContact(getBUIN2(pkt,ofs));
  eventInt     := readBEWORD(pkt, ofs);
  eventTime    := now;
  case eventInt of
    MTN_FINISHED, MTN_TYPED : eventContact.typing.bIsTyping := false;
    MTN_BEGUN  : eventContact.typing.bIsTyping := True;
    MTN_CLOSED : eventContact.typing.bIsTyping := False; 
  end;
  notifyListeners(IE_typing);
 except
 end;
end;


 {$IFDEF USE_REGUIN}
procedure TicqSession.parse170d(const snac: RawByteString);
//const
//  JPEG_HDR = #$FF#$D8#$FF#$E0;
var
  tmpStr: RawByteString;
//  i : Integer;
begin
   {$IFDEF RNQ_AVATARS}
//    i:= pos(JPEG_HDR, snac);
  tmpStr:= Copy(snac, i, length(snac));
  eventStream := TMemoryStream.Create;
  eventStream.Clear;
  eventStream.Write(tmpStr[1], Length(tmpStr));
  eventStream.Seek(0,0);
  //saveFile('img.jpg', tmpStr);
  tmpStr:= '';
//  snac:='';
  notifyListeners(IE_getImage);
   {$ENDIF RNQ_AVATARS}
end;

procedure TicqSession.send170C;
begin
  sendSNAC(ICQ_BUCP_FAMILY, $0c, #00#00);
end;
 {$ENDIF USE_REGUIN}

 {$IFDEF RNQ_AVATARS}

function TicqSession.SSI_deleteAvatar : Boolean;
var
  i : Integer;
begin
 Result := False;
 if isOffline then //OnlFeature
 else
  if not Assigned(serverSSI.items) then
    RequestContactList(false)
   else
    begin
      i := FindSSIItemType(serverSSI, FEEDBAG_CLASS_ID_BART);
      if i >= 0 then
       begin
         with TOSSIItem(serverSSI.items.Objects[i]) do
          SSI_DeleteItem(GroupID, ItemID, ItemType, ItemName, ExtData);
//         serverSSI.items.Delete(i);
         result := True;
       end;  
    end;
//  if avt_icq.isOnline then
//    avt_icq.sendSNAC(ICQ_AVATAR_FAMILY, $02, #00+ #01 + Length_BE(''));
end;

procedure TicqSession.parse0121(const pkt : RawByteString; flags : Word);
  procedure SSI_UpdateAvatar(ch : AnsiChar; flags : Byte; const hash : RawByteString);
   var
     i : Integer;
     s : RawByteString;
     b : Boolean;
  begin
    b := True;
      i := FindSSIItemType(serverSSI, FEEDBAG_CLASS_ID_BART);
      s :=  {TLV($131, '') +} TLV($D5, AnsiChar(flags)+ Length_B(hash));
      if i >= 0 then
       with TOSSIItem(serverSSI.items.Objects[i]) do
        begin
          if ExtData = s then
            b := False
           else
//           if hash = '' then
//              SSI_DeleteItem(GroupID, ItemID, ItemType)
              SSI_DeleteItem(GroupID, ItemID, ItemType, ItemName, ExtData);
{            else
             begin
//              if ItemName <> IntToStr(Byte(ch)) then
//                SSI_UpdateItem(ItemName, TLV($D5, Char(flags)+BUIN('')), GroupID, ItemID, ItemType);
              SSI_UpdateItem(IntToStr(Byte(ch)), s, GroupID, ItemID, ItemType);
             end;}
        end;
//      else
//       SSI_CreateItem(ch, s, 0, $5566, FEEDBAG_CLASS_ID_BART);
    if b then
      SSI_CreateItem(IntToStrA(Byte(ch)), s, 0, 0, FEEDBAG_CLASS_ID_BART);
  end;
var
  i,
  ofs : Integer;
  ch : AnsiChar;
  cnt : TICQcontact;
begin
{  if (Length(pkt) > 2) and
     (pkt[1] = #0) and (pkt[2] = #6) then
  begin
    pkt := copy(pkt, 9, 1000);
  end;
}
 ch := pkt[2];
 IF (pkt[1] = #0) and ((ch = #1) or (ch = #8)) then
  begin
   ofs := 3;
    cnt := TICQcontact(getMyInfo);
    cnt.Icon.Flags := readBYTE(pkt, ofs);
    i := readBYTE(pkt, ofs);
{    if (i = 16) and (copy(pkt, ofs, i) = myInfo.Icon.hash) then
     begin
      i := FindSSIItemType(serverSSI, FEEDBAG_CLASS_ID_BART);
      if i >= 0 then
       with TOSSIItem(serverSSI.items.Objects[i]) do
        SSI_UpdateItem('1', TLV($D5, #$01+#$10 + myInfo.Icon.hash),
         GroupID, ItemID, ItemType)
      else
       SSI_CreateItem('1', TLV($D5, #$01+#$10 + myInfo.Icon.hash),
            0, $5566, FEEDBAG_CLASS_ID_BART);
     end;
}
    if i = 0 then
     begin
       myAvatarHash := '';
       cnt.ICQIcon.hash := '';
     end
    else
    if (i = 16) then
     begin
      cnt.ICQIcon.hash := copy(pkt, ofs, i);

//     if (flags and $8000) > 0 then
      begin
//         myAvatarHash := myInfo.Icon.hash;
       if myAvatarHash = cnt.ICQIcon.hash then
        begin
         if (cnt.Icon.Flags and $80) > 0 then
           uploadAvatar(uploadAvatarFN);
         uploadAvatarFN := '';
        end
       else
        begin
         myAvatarHash := cnt.ICQIcon.hash;
         SSI_UpdateAvatar(ch, cnt.Icon.Flags, cnt.ICQIcon.hash);
        end;
      end;
     end;

  end
  ;
{  else
   IF (pkt[1] = #0) and (pkt[2] = #8) then
    begin
       if (flags and $8000) > 0 then
        begin
          ofs := 3;
          myInfo.Icon.Flags := readBYTE(pkt, ofs);
          i := readBYTE(pkt, ofs);
          if (i = 16) then
            myInfo.Icon.hash := copy(pkt, ofs, i);
//         uploadAvatar(uploadAvatarFN);
         uploadAvatarFN := '';
        myAvatarHash :=myInfo.Icon.hash;
       SSI_UpdateAvatar(myInfo.Icon.hash);
        end;
    end
}
end;

procedure TicqSession.iconUploadAck(const pkt : RawByteString); // $1003
var
  b : Byte;
begin
  if Length(pkt)= 0 then
    Exit;
  b := byte(pkt[1]);
  if b <> 0 then
     msgDlg(getTranslation('Error [%d] - avatar not uploaded', [b])+
      CRLF+ getTranslation(BART__REPLY_CODES[b]), False, mtError);
  if Length(pkt)= 21 then
   begin
//    icq.myInfo.Icon.hash := copy(pkt, 6, $10);
//    myAvatarHash := icq.myInfo.Icon.hash;
   end;
//  eventMsg := icq.myInfo.icon.Hash;
  if uploadAvatarFN > '' then
    begin
      eventMsgA := copy(pkt, 6, $10);
      notifyListeners(IE_addedYou);
    end;
end;
{procedure TicqSession.RequestIcon(uin : Integer; hash : String);
begin
  sendSNAC(ICQ_AVATAR_FAMILY, $06, BUIN(uin) + #01 + #00#01+#01+#$10 + hash);
end;}

function TicqSession.RequestIcon(c : TICQcontact) : Boolean;
begin
  Result := False;
  if protoType = SESS_AVATARS then
    begin
     if isOnline then
       begin
        sendSNAC(ICQ_AVATAR_FAMILY, $06, c.buin + AnsiChar(#01) +
          word_BEasStr(c.Icon.ID) + AnsiChar(c.Icon.Flags)+
          AnsiChar(length(c.ICQIcon.hash)) +
     //     #00#01+ #01+
     //    #$10 +
          c.ICQIcon.hash);
        Result := True;
       end
      else
       Result := False;
    end
   else
    if avt_icq.isOnline then
      Result := avt_icq.RequestIcon(c)
     else
      if isOnline and avt_icq.isOffline then
        initAvatarSess;
end;

procedure TicqSession.initAvatarSess;
//var
//  s : RawByteString;
begin
  if not avtSessInit then
   begin
    avtSessInit := True;
    if (avt_icq.cookie > '') and (avt_icq.cookieTime > now - 30*DTseconds) then
      begin
//        proxy_http_Enable(avt_icq);
        avt_icq.sock.proxySettings(aProxy);
 {$IFDEF USE_SSL}
        avt_icq.sock.isSSL := false;//self.sock.isSSL;
 {$ENDIF USE_SSL}
        avt_icq.connect;//(false, True);
      end
     else
      begin
{        if avt_icq.sock.isSSL then
          s := TLV($8c, '') // Request SSL Connection
         else
          s := '';}
//        self.sendSNAC(ICQ_SERVICE_FAMILY, 4, #$00#$10 + s);
        self.sendSNAC(ICQ_SERVICE_FAMILY, 4, #$00#$10);
      end;
 {$IFDEF UseNotSSI}
    if not self.useSSI and not Assigned(serverSSI.items) then
      RequestContactList(self, false)
 {$ENDIF UseNotSSI}
   end;
end;

procedure TicqSession.parseIcon(const pkt: RawByteString);
//const
//  JPEG_HDR = #$FF#$D8#$FF#$E0;
var
  tmpStr: RawByteString;
  ofs : Integer;
  i : Integer;
begin
  ofs := 1;
  if not Assigned(mainICQ) then
    Exit;
  eventContact := mainICQ.getICQContact(getBUIN2(pkt,ofs));
  readWORD(pkt, ofs);
  readByte(pkt, ofs);
  i:=byte(pkt[ofs]);
//  result:=copy(s,ofs+2,i-1);
  inc(ofs, 1+i);

  readByte(pkt, ofs); // unknown (command ?)
  readWORD(pkt, ofs); // icon id (not sure)
  readByte(pkt, ofs); // icon flags (bitmask, purpose unknown)
  i:=readByte(pkt, ofs); // md5 hash size (16) - yes, again
  eventMsgA := Copy(pkt, ofs, i);
  inc(ofs, i);
//  i := word_BEat(@pkt[ofs]);
  tmpStr :=getBEWNTS(pkt, ofs);
  if tmpStr > '' then
  begin
//  tmpStr:= Copy(snac, pos(JPEG_HDR, snac), length(snac));
    eventStream:= TMemoryStream.Create;
    eventStream.Clear;
    eventStream.Write(tmpStr[1], Length(tmpStr));
    eventStream.Seek(0,0);
    tmpStr:= '';
//    eventFilename := PAFormat[DetectAvatarFormatBuffer(tmpStr)];
    notifyListeners(IE_getAvtr);
  //  eventContact.icon := TJpegImage.Create;
  //  eventContact.icon.LoadFromStream(imageStream);
  //  imageStream.Clear;
  //  imageStream.free;
    //saveFile('img.jpg', tmpStr);
  end;
  tmpStr:= '';
end;


function TicqSession.uploadAvatar(const fn : String) : Boolean; // 1002
{  procedure SSI_UpdateAvatar(ch : Char; hash : String);
   var
     i : Integer;
     s : String;
  begin
      i := FindSSIItemType(serverSSI, FEEDBAG_CLASS_ID_BART);
      s := TLV($131, '') + TLV($D5, ch+BUIN(hash));
      if i >= 0 then
       with TOSSIItem(serverSSI.items.Objects[i]) do
        begin
          if ExtData <> s then
           if hash = '' then
              SSI_DeleteItem(GroupID, ItemID, ItemType)
            else
              SSI_UpdateItem('1', s, GroupID, ItemID, ItemType);
        end
      else
       SSI_CreateItem('1', s, 0, $5566, FEEDBAG_CLASS_ID_BART);
  end;}
var
 buf : RawByteString;
// hash : String;
 fs : Integer;
 ch : AnsiChar;
begin
  Result := False;
  if not Assigned(avt_icq) then
   begin
     Exit;
   end;
  uploadAvatarFN := fn;
  if fn = '' then
    Exit;
  fs := sizeOfFile(fn);
  if fs > ICQMaxAvatarSize then
   begin
     msgDlg('Picture too big', True, mtError);
     Result := True;
     exit;
   end;
  if fs = 0 then
   begin
     Result := True;
     exit;
   end;

  if not avt_icq.IsOnline then
   begin
    initAvatarSess;
    Exit;
   end;

  if lowercase(ExtractFileExt(fn)) = '.xml' then
   ch := #08
  else
   ch := #01;
  buf := loadFileA(fn);
//  Hash := hex2Str(GetMD5(@buf[1], Length(buf))); Íåïðàâèëüíî ñ÷èòàåò õýø :(
//  if myAvatarHash <> hash then
//    SSI_UpdateAvatar(ch, hash)
//   else
    begin
     if (getMyInfo.icon.ID <> byte(ch)) and (getMyInfo.icon.ID > 0) then
      begin
        SSI_deleteAvatar;
//      avt_icq.sendSNAC(ICQ_AVATAR_FAMILY, $02, #00+ AnsiChar(myInfo.icon.ID) + Length_BE(''));
      end;
     avt_icq.sendSNAC(ICQ_AVATAR_FAMILY, $02, AnsiChar(#00)+ ch + Length_BE(buf));
     Result := True;
    end;
end;
 {$ENDIF RNQ_AVATARS}

procedure TicqSession.SSIreqLimits; // $1302 - FEEDBAG__RIGHTS_QUERY
const
  INTERACTION_SUPPORTED = $0001;   //Client supports interactions 
  AUTHORIZATION_SUPPORTED = $0002; //Client supports Buddy authorization 
  DOMAIN_SN_SUPPORTED  = $0004;    //Client supports a@b.com 
  ICQ_NUM_SUPPORTED    = $0008;    //Client supports 1234567890 
  SMS_NUM_SUPPORTED    = $0010;    //Client supports +17035551212 
  ALIAS_ATTR_SUPPORTED = $0020;    //Client supports alias attribute 
  SMARTGRP_SUPPORTED   = $0040;    //Client supports smart groups
  some1_supported      = $0080;
begin
//  sendSNAC(ICQ_LISTS_FAMILY, $02, '');
  sendSNAC(ICQ_LISTS_FAMILY, $02, TLV($0B, Word_BEAsStr(INTERACTION_SUPPORTED or
     AUTHORIZATION_SUPPORTED or ICQ_NUM_SUPPORTED or DOMAIN_SN_SUPPORTED or
     ALIAS_ATTR_SUPPORTED
//     or SMARTGRP_SUPPORTED
//     or some1_supported
     ))); // Experimental
end;

procedure TicqSession.SSIreqRoster;
begin
  sendSNAC(ICQ_LISTS_FAMILY, $04, '');
end;

procedure TicqSession.SSIchkRoster;
begin
  sendSNAC(ICQ_LISTS_FAMILY, $05, dword_BEasStr(DateTimeToUnix(localSSI_modTime)) +
            word_BEasStr(localSSI_itemCnt));
end;

procedure TicqSession.SSIsendReady;
begin
  sendSNAC(ICQ_LISTS_FAMILY, $07, '');
end;

procedure TICQSession.SSIstart();
begin
//  sendFLAP(SNAC_CHANNEL, SNAC($13, $11, 0, $00000011));
  inc(SSI_InServerTransaction);
  if SSI_InServerTransaction = 1 then
    sendSNAC(ICQ_LISTS_FAMILY, $11, '')
end;

procedure TICQSession.SSIstop(needSend : Boolean);
begin
//  sendFLAP(SNAC_CHANNEL, SNAC($13, $12, 0, $00000012));
  if needSend or (SSI_InServerTransaction = 1) then
    sendSNAC(ICQ_LISTS_FAMILY, $12, '');
  SSI_InServerTransaction := 0;
end;

{
procedure TICQSession.SSInewGroup(gID:integer; gName:string; iID : integer = 0);
begin
//showmessage(inttostr(gid));
//  sendSNAC(ICQ_LISTS_FAMILY, $8, Length_BE(gName)+word_LEasStr(gID)+#$00#$00+
//         #$00#$01#$00#$00);
  sendSNAC(ICQ_LISTS_FAMILY, $08, Length_BE(gName)+word_BEasStr(gID)+ word_BEasStr(iID)+
        word_BEasStr(FEEDBAG_CLASS_ID_GROUP)+ #$00#$00);

 // Drunken
//  sendFLAP(SNAC_CHANNEL, SNAC($13, $8, $9, $00000003)+Length_BE(gName)+word_BEasStr(gID)+ word_BEasStr(iID)+
//          word_BEasStr(FEEDBAG_CLASS_ID_GROUP)+ #$00#$00);
end;

procedure TICQSession.SSIUpdate(ID : String );
begin
//  sendSNAC(ICQ_LISTS_FAMILY,$8, Length_BE(nUIN)+word_LEasStr(gID)+
//  word_LEasStr(random(65025))+#$00#$00+
//    Length_BE(TLV($0131, cName)+TLV($0066,'')));
end;
}

function TICQSession.GenSSID : Integer;
var
  a : Word;
begin
  repeat
   a := random($7FFF);
  until (FindSSIItemID(serverSSI, a)<0) and (groups.ssi2id(a) < 0) and (a>0); //(contactsDB.idxBySSID(a) >=0)or (groups.ssi2id(a) >= 0);
  Result := a;
end;

//procedure TICQSession.SSIAddContact(vUIN, vName: String;
//              vMail: String=''; vSMS: String=''; cmnt: String='');
procedure TICQSession.SSIAddContact(c : TICQcontact);
//  var asd:integer;
begin
  if fRoster.exists(c) then
    begin
 {$IFDEF UseNotSSI}
     if c.CntIsLocal then
      sendRemoveContact(c.buin);
 {$ENDIF UseNotSSI}
    end
   else
    c.CntIsLocal := True;
//  c.SSIID := GenSSID;
  c.SSIID := 0;
//  C.CntIsLocal := True;
// if c. then

  SSIstart;
  SSI_sendAddContact(c);
//  SSIstart;
end;

procedure TICQSession.SSI_UpdateContact(c : TICQcontact);
var
 i : integer;
// s : AnsiString;
begin
//  c.SSIID := GenSSID;
//  i := FindSSIItemID(serverSSI, c.SSIID);
  if c.SSIID >0 then
    i := FindSSIItemIDType(serverSSI, c.SSIID, FEEDBAG_CLASS_ID_BUDDY)
   else
    begin
      i := FindSSIItemName(serverSSI, FEEDBAG_CLASS_ID_BUDDY, c.UID2cmp);
      if i >=0 then
        c.SSIID := TOSSIItem(serverSSI.items.Objects[i]).ItemID;
    end;
  if i <0 then Exit;

//  s := '';
//  if c.displayed<>c.uinAsStr then
//    s := TLV($0131, StrToUTF8(c.displayed));
//  if needAuth then
//    s := s + TLV($0066,'');
//  if c.important > '' then
//   s := s + TLV($13C, StrToUTF8(c.important));

  with TOSSIItem(serverSSI.items.Objects[i]) do
   begin
    if (c.Display > '') and (c.displayed<>c.uinAsStr)and (c.displayed <> c.UID) then
     begin
      Caption := c.displayed;
      ExtData := replaceAddTLV($0131, ExtData, 1, StrToUTF8(c.displayed));
     end
     else
      begin
        ExtData := deleteTLV($0131, ExtData );
        Caption := '';
      end;
     ;
    if c.ssCell > '' then
      ExtData := replaceAddTLV($13A, ExtData, 1, StrToUTF8(c.ssCell))
     else
      ExtData := deleteTLV($13A, ExtData);
    if c.ssCell2 > '' then
      ExtData := replaceAddTLV($138, ExtData, 1, StrToUTF8(c.ssCell2))
     else
      ExtData := deleteTLV($138, ExtData);
    if c.ssCell3 > '' then
      ExtData := replaceAddTLV($158, ExtData, 1, StrToUTF8(c.ssCell3))
     else
      ExtData := deleteTLV($158, ExtData);
    if c.ssImportant > '' then
      ExtData := replaceAddTLV($13C, ExtData, 1, StrToUTF8(c.ssImportant))
     else
      ExtData := deleteTLV($13C, ExtData);
    if c.ssMail > '' then
      ExtData := replaceAddTLV($137, ExtData, 1, StrToUTF8(c.ssMail))
     else
      ExtData := deleteTLV($137, ExtData);
    FCellular := c.ssCell;
    FCellular2:= c.ssCell2;
    FCellular3:= c.ssCell2;
    Fnote := c.ssImportant;
    FMail := c.ssMail;
//    ExtInfo  := ;
    SSIstart;
    SSI_UpdateItem(ItemName, ExtData, GroupID, ItemID, ItemType);
    SSIstop;
   end;
end;

procedure TICQSession.UpdateGroupOf(cnt : TRnQContact);
begin
  if cnt is TICQContact then
   if
 {$IFDEF UseNotSSI}
    useSSI and
 {$ENDIF UseNotSSI}
    not cnt.CntIsLocal then
   SSI_UpdateGroup(TICQContact(cnt));
end;

procedure TICQSession.SSI_UpdateGroup(c : TICQcontact);
var
  i : integer;
  gID : Integer;
  na : Boolean;
  pItem : TOSSIItem;
begin
  i := FindSSIItemName(serverSSI, FEEDBAG_CLASS_ID_BUDDY, c.UID);
  if i >= 0 then // Just Change group
   begin
//  c.SSIID := GenSSID;
    gID := groups.idxOf(c.group);
    if gID >= 0 then
    begin
     with TOSSIItem(serverSSI.items.Objects[i]) do
     begin
      gID := groups.a[gID].ssiID;
      if (gID <> 0)and (gID <> GroupID) then
        begin
         na := not c.Authorized;
         SSIstart;
//         SSI_DeleteItem(GroupID, ItemID, ItemType, c.UID, ExtData);
         SSI_DeleteItem(GroupID, ItemID, ItemType);
         SSIstart;
//         c.SSIID := ItemID;
//         c.SSIID := SSI_sendAddContact(c, na, pItem);
         pItem := Clone;
//         if (pItem.ItemID = 0) then
//           pItem.ItemID := GenSSID; // Seems it makes unauth :(
           pItem.ItemID := ItemID;
         c.SSIID := pItem.ItemID;
          pItem.GroupID := gID;
          pItem.ExtData := deleteTLV($149, deleteTLV($6A, pItem.ExtData));
          sendSNAC(ICQ_LISTS_FAMILY, SSI_OPERATION_CODES_ADD, //$9,
                   SSI_Item2packet(pItem));
          SSIacks.Add(SNACref, 0, SSI_OPERATION_CODES_ADD, pItem);
          inc(SNACref);
          if SNACref > maxRefs then
            SNACref:=1;

  //       SSIUpdateGroup([groups.ssi2id(GroupID), c.group]);
  //    SSIstop;
        end;
     end;
    end;
   end;
end;


procedure TICQSession.SSI_AddVisItem(const UID : TUID; iType : Word);
//var
//  asd:integer;
begin
//  asd := GenSSID;
  SSI_CreateItem(uid, '', 0, 0, iType);
//  SSI_CreateItem(uid, TLV($0131, UID)+ TLV($0145, dword_BEasStr(DateTimeToUnix(now))), 0, 0, iType);
end;

procedure TICQSession.SSI_DelVisItem(const UID : TUID; iType : Word);
var
  i : integer;
begin
//  asd := GenSSID;
//  SSI_CreateItem(uid, '', 0, asd, iType);
  i := FindSSIItemName(serverSSI, iType, UID);
  if i >= 0 then
    begin
     with TOSSIItem(serverSSI.items.Objects[i]) do
      SSI_DeleteItem(0, ItemID, iType, ItemName);
    end;
end;

procedure TICQSession.SSI_UpdateGroups(const args:array of integer);
var
  i, g, ll : Integer;
  grID : Integer;
  arr : array of integer;
begin
  SetLength(arr, 0);
  ll := 0;
  for g := 0 to Length(args) - 1 do
  begin
    if args[g] = 0 then
      begin
        i := FindSSIItemIDgID(serverSSI, 0, 0);
        if i >=0 then
         with TOSSIItem(serverSSI.items.Objects[i]) do
          begin
            ItemName := '';
            ExtData  := TLV($C8, groups.getAllSSI);
//            SSI_UpdateItem('RnQ', ExtData, 0, 0, FEEDBAG_CLASS_ID_GROUP);
            SSI_UpdateItem('', ExtData, 0, 0, FEEDBAG_CLASS_ID_GROUP);
//            UpdStr := UpdStr+Length_BE('')+word_BEasStr(0)+word_BEasStr(0) +
//                word_BEasStr(FEEDBAG_CLASS_ID_GROUP)+
//                Length_BE(TLV($C8, groups.getAllSSI));
          end
         else
//            SSI_CreateItem('RnQ', TLV($C8, groups.getAllSSI),
            SSI_CreateItem('', TLV($C8, groups.getAllSSI),
              0, 0, FEEDBAG_CLASS_ID_GROUP);
      end
     else
      begin
        grID := groups.ssi2id(args[g]);
        if grID >=0 then
          begin
            inc(ll);
            SetLength(arr, ll);
            arr[ll-1] := grID
          end;
      end;
  end;
  if ll > 0 then
    SSIUpdateGroup(arr);
end;

procedure TICQSession.SSIUpdateGroup(const args:array of integer);
var
  i, g : Integer;
//  grID : Integer;
  UpdStr : RawByteString;
  InTrans : Boolean;
begin
  UpdStr := '';
  InTrans := False;
//  if not SSI_InServerTransaction then
  if SSI_InServerTransaction = 0 then
   begin
    SSIstart;
    InTrans := True;
   end;
  for g := 0 to Length(args) - 1 do
  if groups.exists(args[g]) then
  begin
   with groups.a[groups.idxOf(args[g])] do
    if ssiid = 0 then
      begin
        ssiID := GenSSID;
        SSI_CreateItem(StrToUTF8(name), ICQCL_C8SSIByGrp(fRoster, args[g]),
         ssiID, 0, FEEDBAG_CLASS_ID_GROUP);

        SSI_UpdateGroups([0]);
{        i := FindSSIItemIDgID(serverSSI, 0, 0);
        if i >=0 then
         with TOSSIItem(serverSSI.items.Objects[i]) do
          begin
            ItemName := '';
            ExtData  := TLV($C8, groups.getAllSSI);
            UpdStr := UpdStr+Length_BE('')+word_BEasStr(0)+word_BEasStr(0) +
                word_BEasStr(FEEDBAG_CLASS_ID_GROUP)+
                Length_BE(TLV($C8, groups.getAllSSI));
          end
         else
            SSI_CreateItem('RnQ', TLV($C8, groups.getAllSSI),
              0, 0, FEEDBAG_CLASS_ID_GROUP);
}
//        SSI_UpdateItem('', TLV($C8, groups.getAllSSI),
//         0, 0, FEEDBAG_CLASS_ID_GROUP)
      end
     else
      begin
//      SSI_UpdateItem(name, TLV($C8, contactsDB.SSIByGrp(args[g])),
//       ssiID, 0, FEEDBAG_CLASS_ID_GROUP);
        i := FindSSIItemIDgID(serverSSI, 0, ssiID);
        if i >=0 then
         with TOSSIItem(serverSSI.items.Objects[i]) do
          begin
            ItemName := StrToUTF8(name);
            ExtData  := ICQCL_C8SSIByGrp(fRoster, args[g]);
            UpdStr := UpdStr+Length_BE(ItemName)+word_BEasStr(ssiID)+word_BEasStr(0) +
                word_BEasStr(FEEDBAG_CLASS_ID_GROUP)+
                Length_BE(ExtData);
          end
//         else
//            SSI_CreateItem('RnQ', TLV($C8, groups.getAllSSI),
//              0, 0, FEEDBAG_CLASS_ID_GROUP);
      end;
  end;
  if UpdStr > '' then
    sendSNAC(ICQ_LISTS_FAMILY, SSI_OPERATION_CODES_UPDATE,
            UpdStr);
  if InTrans then
    SSIstop;
  inc(SNACref);
  if SNACref > maxRefs then
    SNACref:=1;
end;
{
procedure TICQSession.SSICreateGroup( grID : Integer);
begin
  if groups.exists(grID) then
  begin
   with groups.a[groups.idxOf(grID)] do
    if ssiid = 0 then

//      SSI_UpdateItem(name, TLV($C8, groups.getAllSSI),
//       ssiID, 0, FEEDBAG_CLASS_ID_GROUP)
     else
      SSI_UpdateItem(name, TLV($C8, contactsDB.SSIByGrp(grID)),
       ssiID, 0, FEEDBAG_CLASS_ID_GROUP);
  end;
end;
}
//procedure TICQSession.SSInewContact(gID,cID:integer; nUIN, cName, vMail, vSMS, cmnt:string);
function TICQSession.SSI_sendAddContact(cnt : TICQcontact; needAuth : Boolean = false; pItem : TOSSIItem = NIL) : Word;
var
  s : RawByteString;
//  item : TOSSIItem;
begin
//sendSNAC(ICQ_LISTS_FAMILY, $8, Length_BE(nUIN)+word_LEasStr(gID)+
//  word_LEasStr(random(65025))+#$00#$00+
//    Length_BE(TLV($0131, cName)+TLV($0066,'')));
//asd:=random(65025);

//sendFLAP(SNAC_CHANNEL, SNAC(ICQ_LISTS_FAMILY, $8, $9, $00000003)+
// SSI_CreateItem()
{  item := TOSSIItem.Create;
  with item do
   begin
    ItemType := FEEDBAG_CLASS_ID_BUDDY;
    ItemID   := cnt.SSIID;
    GroupID  := groups.id2ssi(cnt.group);
    ItemName := cnt.uinAsStr;
    ExtData  := '';
   end;
}
  if Assigned(pItem) then // (pItem.ExtData > '') then
    s := pItem.ExtData
   else
   begin
    s := '';
    if (cnt.display > '') AND (cnt.displayed<>cnt.uinAsStr) and (cnt.displayed <> cnt.UID) then
      s := TLV($0131, StrToUTF8(cnt.displayed));
  {
    if cnt.localMail > '' then
     s := s + TLV($0137, cnt.localMail);
    if cnt.localCell > '' then
     s := s + TLV($013A, cnt.localCell);
    if cnt.important > '' then
     s := s + TLV($013C, StrToUTF8(cnt.important));
  }
     s := s + TLV($0137, StrToUTF8(cnt.ssMail));
     s := s + TLV($013A, StrToUTF8(cnt.ssCell));
     s := s + TLV($0138, StrToUTF8(cnt.ssCell2));
     s := s + TLV($0158, StrToUTF8(cnt.ssCell3));
     s := s + TLV($013C, StrToUTF8(cnt.ssImportant));

  //   s := s + TLV($0137, '') + TLV($013A, '') + TLV($013C, '');

    if needAuth then
      s := s + TLV($0066,'');
  //  cnt.CntIsLocal := False;
   end;
  inc(SNACref);
  if SNACref > maxRefs then
    SNACref:=1;
  cnt.SSIID := 0;
  result := SSI_CreateItem(cnt.UID2cmp, s, groups.id2ssi(cnt.group), cnt.SSIID, FEEDBAG_CLASS_ID_BUDDY);
{
   sendSNAC(ICQ_LISTS_FAMILY, SSI_OPERATION_CODES_ADD, $9,
          Length_BE(cnt.uinAsStr)+
          word_BEasStr(groups.id2ssi(cnt.group))+
          word_BEasStr(cnt.SSIID)+
          #$00#$00+
          Length_BE(s)
    );

  SSIacks.Add(SNACref, 0, SSI_OPERATION_CODES_ADD, item);
//  SSIacks.Add(SNACref, 0, SSI_OPERATION_CODES_ADD, cnt.uinAsStr);
  inc(SNACref);
  if SNACref > maxRefs then
    SNACref:=1;
}
//sendFLAP(SNAC_CHANNEL, SNAC(ICQ_LISTS_FAMILY, $8, $9, $00000003)+Length_BE(nUIN)+
//  word_LEasStr(gID)+
//  word_LEasStr(cID)+#$00#$00+
//    IfThen(cName>'', Length_BE(TLV($0131, StrToUTF8(cName))), '')
//    );
end;

//procedure TICQSession.SSIdeleteContact(gID,cID:integer; nUIN,cName:string);
procedure TICQSession.SSIdeleteContact(cnt : TRnQcontact);
begin
  if cnt.SSIID = 0 then
    Exit;
  SSIstart;
  SSI_DeleteItem(groups.id2ssi(cnt.group), cnt.SSIID, FEEDBAG_CLASS_ID_BUDDY);
//  SSIUpdateGroup(cnt.group);
//  SSIstop;
end;

procedure TICQSession.SSI_DeleteItem(gID, iID, Tp : word;
             const iName : AnsiString = ''; const pExtData : RawByteString = '');
var
  i : Integer;
  item : TOSSIItem;
begin
  if (gID=0)and(iID=0)and (tp <> FEEDBAG_CLASS_ID_GROUP) then
    Exit;
  sendSNAC(ICQ_LISTS_FAMILY, SSI_OPERATION_CODES_REMOVE, //$9,
            Length_BE(iName)+word_BEasStr(gID)+word_BEasStr(iID) +
            word_BEasStr(Tp)+ Length_BE(pExtData));
  if iID = 0 then
    i := FindSSIItemIDgID(serverSSI, iID, gID)
   else
    i := FindSSIItemID(serverSSI, iID);
  if i >= 0 then
    begin
      item := TOSSIItem(serverSSI.items.Objects[i]).Clone;
      SSIacks.Add(SNACref, 0, SSI_OPERATION_CODES_REMOVE, item);
      inc(SNACref);
      if SNACref > maxRefs then
        SNACref:=1;
//
//       TOSSIItem(serverSSI.items.Objects[i]).Free;
//       serverSSI.items.Objects[i] := NIL;
//       serverSSI.items.Delete(i);
    end
end;

procedure TICQSession.SSI_UpdateItem(const iName, iExtData : RawByteString; gID, iID, Tp : word);
var
 i : Integer;
begin
  sendSNAC(ICQ_LISTS_FAMILY, SSI_OPERATION_CODES_UPDATE, //$9,
            Length_BE(iName)+word_BEasStr(gID)+word_BEasStr(iID) +
            word_BEasStr(Tp)+
            Length_BE(iExtData));
  if iID = 0 then
    i := FindSSIItemIDgID(serverSSI, iID, gID)
   else
    i := FindSSIItemID(serverSSI, iID);
  if i >=0 then
   with TOSSIItem(serverSSI.items.Objects[i]) do
    begin
      ItemName := iName;
      ExtData  := iExtData;
    end;
  inc(SNACref);
  if SNACref > maxRefs then
    SNACref:=1;
end;

function TICQSession.SSI_CreateItem(const iName, iExtData : RawByteString; gID, iID, Tp : word) : Word;
var
  item : TOSSIItem;
begin
//  SSIstart;

  if (iID = 0) and (Tp<> FEEDBAG_CLASS_ID_GROUP) then
   iID := GenSSID;

  item := TOSSIItem.Create;
  with item do
   begin
    ItemType := Tp;
    ItemID   := iID;
    GroupID  := gID;
    ItemName := iName;
    ExtData  := iExtData;
   end;
//  with item do
  sendSNAC(ICQ_LISTS_FAMILY, SSI_OPERATION_CODES_ADD, //$9,
            SSI_Item2packet(item));
//            Length_BE(ItemName) + word_BEasStr(GroupID) + word_BEasStr(ItemID) +
//            word_BEasStr(ItemType) + Length_BE(ExtData));
  SSIacks.Add(SNACref, 0, SSI_OPERATION_CODES_ADD, item);
  inc(SNACref);
  if SNACref > maxRefs then
    SNACref:=1;
  Result := iID;
end;

procedure TICQSession.SSI_CreateItems(Items : array of TOSSIItem);
var
  i : Integer;
  s : RawByteString;
begin
  if Length(Items) = 0 then
    Exit;
  s := '';
  for I := Low(Items) to High(Items) do
  begin
    if (Items[i].ItemID = 0) and (Items[i].ItemType<> FEEDBAG_CLASS_ID_GROUP) then
     Items[i].ItemID := GenSSID;
    s := s + SSI_Item2packet(Items[i]);
  end;
  sendSNAC(ICQ_LISTS_FAMILY, SSI_OPERATION_CODES_ADD, //$9,
           s);
  for I := Low(Items) to High(Items) do
  begin
    SSIacks.Add(SNACref, i-Low(Items), SSI_OPERATION_CODES_ADD, Items[i]);
  end;
  inc(SNACref);
  if SNACref > maxRefs then
    SNACref:=1;
//  Result := iID;
end;

procedure TICQSession.SSI_DeleteItems(Items : array of TOSSIItem);
var
  i : Integer;
  s : RawByteString;
begin
  if Length(Items) = 0 then
    Exit;
  s := '';
  for I := Low(Items) to High(Items) do
  begin
    s := s + SSI_Item2packet(Items[i]);
  end;
  sendSNAC(ICQ_LISTS_FAMILY, SSI_OPERATION_CODES_REMOVE, //$9,
            s);
  for I := Low(Items) to High(Items) do
  begin
    SSIacks.Add(SNACref, i-Low(Items), SSI_OPERATION_CODES_REMOVE, Items[i]);
  end;
  inc(SNACref);
  if SNACref > maxRefs then
    SNACref:=1;
//
//       TOSSIItem(serverSSI.items.Objects[i]).Free;
//       serverSSI.items.Objects[i] := NIL;
//       serverSSI.items.Delete(i);
end;

procedure TICQSession.SSIdeleteGroup(gID:integer);
begin
//showmessage(inttostr(gid));
//  sendSNAC(ICQ_LISTS_FAMILY, $8, Length_BE(gName)+word_LEasStr(gID)+#$00#$00+
//         #$00#$01#$00#$00);
//  sendSNAC(ICQ_LISTS_FAMILY, SSI_OPERATION_CODES_REMOVE,
//            Length_BE(gName)+word_BEasStr(gID)+#$00#$00 + #$00#$01#$00#$00);
  SSI_DeleteItem(gID, 0, FEEDBAG_CLASS_ID_GROUP);
end;
{
procedure TICQSession.renameSSIGroup(gID:integer; gName:string);
begin
  SSIstart;
  SSIrenameGroup(gID, gName);
  SSIstop;
end;
{
procedure TICQSession.SSIRenameGroup(gID:integer; gName:string);
var
  s : String;
  i : Integer;
begin
//  sendSNAC(ICQ_LISTS_FAMILY, SSI_OPERATION_CODES_UPDATE, $9,
//          Length_BE(gName)+word_BEasStr(gID)+ word_BEasStr(iID)+
//          word_BEasStr(FEEDBAG_CLASS_ID_GROUP)+ #$00#$00);
  i := groups.ssi2id(gID);
  if i >=0 then
   with groups.get(i) do
    begin
     s := roster.SSIByGrp(i);
     SSI_UpdateItem(gName, , gID, 0, FEEDBAG_CLASS_ID_GROUP);
    end;
end;
}

procedure TICQSession.RequestXStatus(const uin : TUID);
const
  i = 2;
var
  s : RawByteString;
begin
//  if CAPS_sm_ICQSERVERRELAY in then

  s := '<srv><id>cAwaySrv</id>'+
       '<req><id>AwayStat</id><trans>' + IntToStrA(i)+ '</trans>'+
       '<senderId>' + StrToUTF8(MyAccount) + '</senderId></req></srv>';
  sendMSGsnac(uin, AnsiChar(MTYPE_PLUGIN)+#00+
        word_LEasStr(getFullStatusCode)
        +#01+#0
        +WNTS('')
        + Length_LE(MsgCapabilities[1]
           + #$08#$00
           + Length_DLE(Plugin_Script)
           + #$00#$00#$01 + z+z+z)
        + Length_DLE(Length_DLE(
         '<N><QUERY>'+ str2html2('<Q><PluginID>srvMng</PluginID></Q>') +
         '</QUERY><NOTIFY>'+ str2html2(s) +
          '</NOTIFY></N>'+CRLF)));
end;

procedure TicqSession.AuthRequest(cnt : TRnQContact; const reason : String);
begin
//   sendSNAC(ICQ_LISTS_FAMILY, $14, BUIN(uin) + Length_BE('') + #$00#$00);
//   AuthGrant(cnt);
  sendSNAC(ICQ_LISTS_FAMILY, $18, cnt.buin + Length_BE(StrToUtf8(reason)) + #$00#$00);
end;

Procedure TICQSession.ProcessSSIacks;
var
  i, t, j: Integer;
  item1 : TSSIEvent;
  item  : TOSSIItem;
  cnt   : TICQcontact;
begin
  t := 0;
  while t < SSIacks.Count do
  begin
   item1 := SSIacks.getAt(t);
   if (item1.ID = 0) and Assigned(item1.Item) then
    begin
      SSIacks.Delete(t);
      item := item1.Item;
      item1.Item := NIL;
      case item1.kind of
       SSI_OPERATION_CODES_REMOVE:
        begin
          if item.ItemID = 0 then
            i := FindSSIItemIDgID(serverSSI, item.ItemID, item.GroupID)
           else
            i := FindSSIItemID(serverSSI, item.ItemID);
          if i >=0 then
          begin
            TOSSIItem(serverSSI.items.Objects[i]).Free;
            serverSSI.items.Objects[i] := NIL;
            serverSSI.items.Delete(i);
            Dec(serverSSI.itemCnt);
          end;
          if item.ItemType = FEEDBAG_CLASS_ID_BUDDY then
           begin
             cnt := getICQContact(item.ItemName);
             if Assigned(cnt) then
               begin
                if (cnt.SSIID > 0) and (cnt.SSIID <> item.ItemID) and
                   (FindSSIItemID(serverSSI, cnt.SSIID)>0) then
                  begin
                   // Just deleting temporary contact
                  end
                 else
                  begin
                    cnt.CntIsLocal := True;
                    cnt.SSIID := 0;
                    cnt.Authorized := False;
    //                addContact(cnt, True);
     {$IFDEF UseNotSSI}
                    sendAddContact(cnt.buin);
     {$ENDIF UseNotSSI}
                    eventContact := cnt;
    //                notifyListeners(IE_contactupdate);
                    notifyListeners(IE_contactSelfDeleted);
                  end;
               end;
           end;
          FreeAndNil(Item);
        end;
       SSI_OPERATION_CODES_ADD:
        begin
          if item.ItemID = 0 then
            i := FindSSIItemIDgID(serverSSI, item.ItemID, item.GroupID)
           else
            i := FindSSIItemID(serverSSI, item.ItemID);
          if i >=0 then
            begin
              TOSSIItem(serverSSI.items.Objects[i]).Free;
              serverSSI.items.Objects[i] := Item;
              serverSSI.items.Strings[i] := item.ItemName;
             if item.ItemType = FEEDBAG_CLASS_ID_BUDDY then
              begin
               cnt := getICQContact(item.ItemName);
               if Assigned(cnt) then
//               i := contactsDB.idxBySSID(item.ItemID);
//               if i >= 0 then
                 begin
                  // NEED PARSE SSI INFO!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
//                  cnt := contactsDB.getAt(i);
                  cnt.SSIID := item.ItemID;
                  cnt.CntIsLocal := False;
                  cnt.Authorized := not existsTLV($66, item.ExtData);
                  j := groups.ssi2id(item.GroupID);
                  if j > 0 then
                    cnt.group := j;
//                  addContact(roster.getAt(i), True);
                  eventContact := cnt;
                  notifyListeners(IE_contactupdate);
                 end;
              end;
//              item.Free
            end
           else
           begin
            serverSSI.items.AddObject(item.ItemName, item);
            Inc(serverSSI.itemCnt);
            case item.ItemType of
              FEEDBAG_CLASS_ID_BUDDY:
                begin
                 cnt := getICQContact(item.ItemName);
                 if Assigned(cnt) then
                   begin
    //                cnt := contactsDB.getAt(i);
                    cnt.CntIsLocal := False;
                    cnt.SSIID := item.ItemID;
                    cnt.Authorized := not existsTLV($66, item.ExtData);
//                    cnt.Authorized := False;
//                    addContact(cnt, True);
                   end;
                end;
              FEEDBAG_CLASS_ID_GROUP:
                begin
                 groups.add(item.ItemName, item.ItemID);
                end;
            end;
//            TOSSIItem(serverSSI.items.Objects[i]).Free;
//            serverSSI.items.Objects[i] := item;
//            serverSSI.items.Strings[i] := item.ItemName;
           end;
        end;
       SSI_OPERATION_CODES_UPDATE:
        begin
          if item.ItemID = 0 then
            i := FindSSIItemIDgID(serverSSI, item.ItemID, item.GroupID)
           else
            i := FindSSIItemID(serverSSI, item.ItemID);
          if i >=0 then
          begin
            TOSSIItem(serverSSI.items.Objects[i]).Free;
            serverSSI.items.Objects[i] := Item;
            serverSSI.items.Strings[i] := item.ItemName;
//            serverSSI.items.Delete(i);
            if item.ItemType = FEEDBAG_CLASS_ID_BUDDY then
             begin
               cnt := getICQContact(item.ItemName);
               if Assigned(cnt) then
//               i := contactsDB.idxBySSID(item.ItemID);
//               if i >= 0 then
                 begin
                  // NEED PARSE SSI INFO!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
//                  cnt := contactsDB.getAt(i);
                  cnt.CntIsLocal := False;
//                  SSIID := 0;
                  cnt.Authorized := not existsTLV($66, item.ExtData);
//                  addContact(roster.getAt(i), True);
                  eventContact := cnt;
                  notifyListeners(IE_contactupdate);
                 end;
             end;
           end;
        end;
      end;
      item1.Free;
    end
    else
     inc(t);
  end;
end;

// Server ask us to add, update or delete item
procedure TicqSession.parse1308090A(const snac: RawByteString; ref: integer; iType: Word);
var
  ofs, l, n : Integer;
  item:  TOSSIItem;
begin
//  appendFile(logPath + 'Packets.Strange.txt', '<-13-08---------->'+logTimestamp+CRLF+hexDump(snac));
  ofs := 1;
  l := Length(snac) - 8;
  if l < 0 then Exit;
{  if word_BEat(@snac[ofs]) = $06 then
   begin
//    Thing :=
    getBEWNTS(snac, ofs);             //I Don't know WHAT IS THAT!!!
   end;
}
  n := 0;
  repeat
//    item := ReadSSIChunk(snac, ofs, False);
    item := ReadSSIChunk(snac, ofs, True);
    SSIacks.add(0, n, iType, item);
//    Item := nil;
    inc(n);
  until (ofs >= l);
//  if not SSI_InServerTransaction then
  if SSI_InServerTransaction = 0 then
    ProcessSSIacks;
end;

procedure TICQSession.parse1311(const snac: RawByteString; ref: Integer); // SSI_Begin transaction
begin
//  SSI_InServerTransaction := True;
  SSI_InServerTransaction := 1;
end;

procedure TICQSession.parse1312(const snac: RawByteString; ref: Integer);
begin
//  SSI_InServerTransaction := False;
  SSI_InServerTransaction := 0;
  ProcessSSIacks;
end;
{This command is sent as what is perhaps an acknowledgement reply to at least CLI_ADDBUDDY and CLI_UPDATEGROUP.}
procedure TicqSession.parse130E(const snac: RawByteString; ref:integer);
var
  ofs, i, l, t : Integer;
  gID : Integer;
  ack, n : Word;
  cnt : TICQcontact;
begin
  ofs := 1;
  l := Length(snac) - 1;
  if l < 0 then Exit;
{  if word_BEat(@snac[ofs]) = $06 then
   begin
//    Thing :=
    getBEWNTS(snac, ofs);             //I Don't know WHAT IS THAT!!!
   end;}
  n := 0;
  repeat
    ack := readBEWORD(snac, ofs);
//  SSIacks.Add(SNACref, 0, SSI_OPERATION_CODES_ADD, cnt.uinAsStr);
    t := SSIacks.findID(ref, n);
    inc(n);
    if t >=0 then
     begin
      with SSIacks.getAt(t) do
      if Assigned(Item) then
      begin
       case kind of
         SSI_OPERATION_CODES_ADD:
        if (ack = $000E)and(item.ItemType = FEEDBAG_CLASS_ID_BUDDY) then //Can't add this contact because it requires authorization
         begin
          cnt := getICQContact(Item.ItemName);
          cnt.Authorized := false;
          if not existsTLV($66, item.ExtData) then
            begin
//              cnt.SSIID := Item.ItemID;
              if SSI_InServerTransaction > 0 then
               begin
    //          SSIstart;
                SSI_sendAddContact(cnt, True);
    //            SSI_UpdateGroup(item.GroupID);
    //            SSIUpdateGroup(cnt.group);
    //            SSIstop;
               end
    //          addContact(cnt, True);
              else // неудачно добавили :(
               begin
                 cnt.CntIsLocal := True;
                 cnt.SSIID := 0;
               end;
            end
           else
            if SSI_InServerTransaction > 0 then
             begin
              cnt.CntIsLocal := True;
              SSI_InServerTransaction := 1;
              SSIstop;
             end;
         end
         else
          if (ack = 0) and (Item.ItemName > '') then
          begin
           case Item.ItemType of
             FEEDBAG_CLASS_ID_BUDDY:
               begin
                cnt := getICQContact(Item.ItemName);
                cnt.cntIsLocal := False;
                cnt.SSIID := Item.ItemID;
                cnt.Authorized := not existsTLV($66, item.ExtData);
//                if SSI_InServerTransaction then
                if SSI_InServerTransaction > 0 then
                 begin
//                  SSI_UpdateItem(item.)
                  SSI_UpdateGroups(item.GroupID);
//                  SSIUpdateGroup(cnt.group);
//                  if SSI_InServerTransaction = 1 then
                  SSI_InServerTransaction := 1;
                  SSIstop;
                 end;
 {$IFDEF UseNotSSI}
                if not cnt.Authorized then
                  sendAddContact(cnt.buin);
 {$ENDIF UseNotSSI}
                if cnt.infoUpdatedTo=0 then
//                  cnt.toQuery := True;
                   TCE(cnt.data^).toquery := True;
//                  sendQueryInfo(cnt.uid);
                eventContact := cnt;
                notifyListeners(IE_contactupdate);
               end;
             FEEDBAG_CLASS_ID_GROUP:
               begin
//                if SSI_InServerTransaction then
                if SSI_InServerTransaction >0 then
                 begin
                  if item.GroupID <> 0 then
                   SSI_UpdateGroups([0]);
//                   SSI_UpdateGroups(item.GroupID);
                  SSIstop;
                 end;
               end;
             FEEDBAG_CLASS_ID_PERMIT:
               begin
                cnt := getICQContact(Item.ItemName);
                fVisibleList.add(cnt);
                eventContact := cnt;
                notifyListeners(IE_contactupdate);
               end;
             FEEDBAG_CLASS_ID_DENY:
               begin
                cnt := getICQContact(Item.ItemName);
                fInVisibleList.add(cnt);
                eventContact := cnt;
                notifyListeners(IE_contactupdate);
               end;
             FEEDBAG_CLASS_ID_IGNORE_LIST:
               begin
                cnt := getICQContact(Item.ItemName);
                ignoreList.add(cnt);
                spamList.add(cnt);
                eventContact := cnt;
                notifyListeners(IE_contactupdate);
               end;
           end;
           serverSSI.items.AddObject(Item.ItemName, item);
           Inc(serverSSI.itemCnt);
           item := NIL;
          end
          else
           if (ack = $0A) and (Item.ItemName > '') then
             case Item.ItemType of
              FEEDBAG_CLASS_ID_BUDDY:
                begin
                  cnt := getICQContact(Item.ItemName);
                  cnt.cntIsLocal := True;
                  cnt.SSIID := 0;
                end;
              FEEDBAG_CLASS_ID_GROUP:
                begin
                  i := groups.ssi2id(Item.ItemID);
                  if i >= 0 then
                    groups.a[groups.idxOf(i)].ssiID := 0;
                end;
             end;

         SSI_OPERATION_CODES_REMOVE:
          if (Item.ItemName > '') and
             ((ack = 0)or ((ack=02) and (Item.ItemType = FEEDBAG_CLASS_ID_BUDDY))) then
          begin
           case Item.ItemType of
             FEEDBAG_CLASS_ID_BUDDY:
               begin
                cnt := getICQContact(Item.ItemName);
                eventContact := cnt;
//                if SSI_InServerTransaction then
                if SSI_InServerTransaction >1 then
                 begin
                  gID := groups.idxOf(cnt.group);
                  if (gID >= 0)and(groups.a[gID].ssiID <> item.GroupID) then
                    begin
                      SSI_UpdateGroups([item.GroupID, groups.a[gID].ssiID]);
//                      SSI_InServerTransaction := 1;
                      SSIstop(True);
                    end
                 end;
                  if SSI_InServerTransaction = 1 then
                    begin
                     cnt.cntIsLocal := True;
                     cnt.Authorized := False;
                     cnt.SSIID := 0;
                     SSI_UpdateGroups(item.GroupID);
                     SSIstop;
                    end;
//                addContact(cnt, True);
                notifyListeners(IE_contactupdate);
               end;
             FEEDBAG_CLASS_ID_PERMIT:
               begin
                cnt := getICQContact(Item.ItemName);
                fVisibleList.remove(cnt);
                eventContact := cnt;
                notifyListeners(IE_contactupdate);
               end;
             FEEDBAG_CLASS_ID_DENY:
               begin
                cnt := getICQContact(Item.ItemName);
                fInVisibleList.remove(cnt);
                eventContact := cnt;
                notifyListeners(IE_contactupdate);
               end;
             FEEDBAG_CLASS_ID_IGNORE_LIST:
               begin
                cnt := getICQContact(Item.ItemName);
                ignoreList.remove(cnt);
                spamList.remove(cnt);
                eventContact := cnt;
                notifyListeners(IE_contactupdate);
               end;
           end;
           i := FindSSIItemIDgID(serverSSI, item.ItemID, item.GroupID);
           if i >=0 then
             begin
              TOSSIItem(serverSSI.items.Objects[i]).Free;
              serverSSI.items.Objects[i] := NIL;
              serverSSI.items.Delete(i);
              Dec(serverSSI.itemCnt);
             end;
          end;
       end;
       FreeAndNil(Item);   
      end;
       SSIacks.Delete(t);
     end;
  until ofs >= l;
end;

procedure TicqSession.parse131b(const pkt : RawByteString);
var
  ofs : Integer;
  i : Integer;
begin
  ofs := 1;
{  if pkt[ofs] = #0 then
   begin
//    dec(ofs);
//    Thing :=
    getBEWNTS(pkt, ofs);             //I Don't know WHAT IS THAT!!!
//    Inc(ofs);
   end;}
  eventContact := getICQContact(getBUIN2(pkt,ofs));
  i := readBYTE(pkt, ofs);
  if i = 1 then
   eventAccept := AC_OK
  else
   eventAccept := AC_DENIED;
  eventMsgA := getWNTS(pkt, ofs);
  notifyListeners(IE_authDenied);
end;
procedure TicqSession.parse131C(const pkt : RawByteString);
var
  ofs : Integer;
//  i : Integer;
begin
  ofs := 1;
{  if pkt[ofs] = #0 then
   begin
//    dec(ofs);
//    Thing :=
    getBEWNTS(pkt, ofs);             //I Don't know WHAT IS THAT!!!
//    Inc(ofs);
   end;}
  eventContact := getICQContact(getBUIN2(pkt,ofs));
  eventTime := Now;
  eventFlags := 0;
  notifyListeners(IE_addedYou);
end;

{procedure TicqSession.InitSSI_Lists;
var
  I: Integer;
  item:  TOSSIItem;
begin
  clearSSIList(localSSI);
  if not Assigned(localSSI.items) then
   begin
     localSSI.items := TStringList.Create;
     localSSI.itemCnt := 0;
     localSSI.modTime := 0;
   end;
  // Add Groups
  for I := 0 to Account.groups.count - 1 do
  begin
    item  := TOSSIItem.Create;
    with item do
    begin
      ItemName := StrToUTF8(Account.groups.a[i].name);         //The name of the group.
      GroupID := Account.groups.a[i].ssiID;
    //This field seems to be a tag or marker associating different groups together into a larger group such as the Ignore List or 'General' contact list group, etc.
      ItemID := 0;
    //This is a random number generated when the user is added to the contact list, or when the user is ignored.
      ItemType := FEEDBAG_CLASS_ID_GROUP;
    //This field seems to indicate what type of group this is.
      ExtData := '';
//      Debug := '';
    //    c := nil;
      Caption   := '';
      FMail     := '';
      FCellular := '';
      FFirstMsg := 0;
      FAuthorized := True;
    end;
    localSSI.items.AddObject(item.ItemName, item);
    item := nil;
  end;
  // Add buddyes
  with readList(LT_ROSTER).clone do
  begin
   resetEnumeration;
   while hasMore do
       with TICQcontact(getNext) do
        begin
         item  := TOSSIItem.Create;
         with item do
         begin
           ItemName := UID;         //The name of the group.
           i := Account.groups.idxOf(group);
           if i >=0 then
             GroupID := Account.groups.a[i].ssiID
            else
             GroupID := 0;
         //This field seems to be a tag or marker associating different groups together into a larger group such as the Ignore List or 'General' contact list group, etc.
           ItemID := SSIID;
         //This is a random number generated when the user is added to the contact list, or when the user is ignored.
           ItemType := FEEDBAG_CLASS_ID_BUDDY;
         //This field seems to indicate what type of group this is.
           ExtData := '';
//           Debug := '';
         //    c := nil;
           Caption   := displayed;
           FMail     := ssMail;
           FCellular := ssCell;
           Fnote     := ssImportant;
           FFirstMsg := 0;
           FAuthorized := Authorized;
         end;
         localSSI.items.AddObject(item.ItemName, item);
         item := nil;
        end;
  end;
  localSSI.itemCnt := localSSI.items.Count;
end;}

procedure TicqSession.SplitCL2SSI_DelItems(proc: TsplitSSIProc; cl: TRnQCList; Tp: word);
var
  i, len1, LenAll: integer;
  k, l: Integer;
  arr : array of TOSSIItem;
//  s:string;
begin
  if TList(cl).count=0 then
    begin
    proc([]);
    exit;
    end;
  i:=0;
  while (i< TList(cl).count) do
   begin
    if i > 0 then
      sleep(1000);
    LenAll := 0;
    SetLength(arr, 0);
//    s:='';
    while (i< TList(cl).count) and (LenAll<6000) do
      begin
       with cl.getAt(i) do
        begin
//         s:=s + buin;
          l := FindSSIItemName(serverSSI, Tp, UID);
          if l >= 0 then
            begin
             k := length(arr);
             SetLength(arr, k + 1);
             arr[k] :=TOSSIItem(serverSSI.items.Objects[l]).Clone;
             Len1 := Length(SSI_Item2packet(arr[k]));
             Inc(LenAll, len1);
            end;
        end;
       inc(i);
//       dec(cnt);
      end;
    proc(arr);
   end;
end;

function TOSSIItem.Clone : TOSSIItem;
begin
  result := TOSSIItem.Create;
  Result.ItemType := Self.ItemType;
  Result.ItemID := Self.ItemID;
  Result.GroupID := Self.GroupID;
  Result.ItemName := Self.ItemName;
  Result.ExtData := Self.ExtData;
//  Result.Debug := Self.Debug;
  Result.FAuthorized := Self.FAuthorized;
  Result.isNIL := Self.isNIL;

  Result.Caption := Self.Caption;
  Result.Fnote := Self.Fnote;
  Result.FInfoToken := Self.FInfoToken;
  Result.FProto := Self.FProto;
  Result.FCellular := Self.FCellular;
  Result.FCellular2:= Self.FCellular2;
  Result.FCellular3:= Self.FCellular2;
  Result.FMail := Self.FMail;
  Result.FFirstMsg := Self.FFirstMsg;
end;

constructor TSSIEvent.Create;
begin
  inherited;
  kind  := -1;
  ID    := -1;
  NUM   := -1;
//    uin:integer;
//  flags := 0;
//  UID   := '';
  Item  := NIL;
//  email := '';
//  info  := '';
//  cl    := NIL;
end;

destructor TSSIEvent.Destroy;
begin
//  if Assigned(cl) then FreeAndNil(cl);
  if Assigned(Item) then FreeAndNil(Item);
  inherited;
end;

function TSSIEvent.Clone : TSSIEvent;
begin
  result := TSSIEvent.Create;
  Result.timeSent := Self.timeSent;
  Result.ID := Self.ID;
  Result.NUM := Self.NUM;
  Result.kind := Self.kind;
//  Result.UID := Self.UID;
  if Assigned(self.Item) then
   begin
     Result.Item := TOSSIItem.Create;
     Result.Item.ItemType := Self.Item.ItemType;
     Result.Item.FAuthorized := Self.Item.FAuthorized;
     Result.Item.ItemID := Self.Item.ItemID;
     Result.Item.GroupID := Self.Item.GroupID;
     Result.Item.ItemName := Self.Item.ItemName;
     Result.Item.Caption := Self.Item.Caption;
     Result.Item.ExtData := Self.Item.ExtData;
//     Result.Item.Debug := Self.Item.Debug;
   end
  else
    Result.Item := NIL;
//  Result.info := Self.info;
//  Result. := Self.;
end;


destructor TSSIacks.Destroy;
begin
  clear;
  inherited
end;

{
function TSSIacks.add(ref : Int64; Num : Integer; kind: Integer; dest:TUID):TSSIEvent;
begin
  result:=TSSIEvent.create;
  add(result);
  result.ID := ref;
  result.NUM:= Num;
  result.kind:=kind;
  result.uid:=dest;
end;}

function TSSIacks.add(ref : Int64; Num : Integer; kind: Integer; item : TOSSIItem):TSSIEvent;
begin
  result:=TSSIEvent.create;
  add(result);
  result.ID   := ref;
  result.NUM  := Num;
  result.kind :=kind;
  Result.Item := item;
end;

function TSSIacks.empty:boolean;
begin result:=count=0 end;

procedure TSSIacks.Clear;
var
  i:integer;
  e : TSSIEvent;
begin
for i:=count-1 downto 0 do
 begin
  e := getAt(i);
  if e <> NIL then
  with e do
    try
//     updateScreenFor(uid);
     free;
    except
    end;
 end;
inherited;
//saveOutboxDelayed:=TRUE;
end;

function TSSIacks.getAt(const idx:integer):TSSIEvent;
begin
if (idx>=0) and (idx<count) then
  result:=list[idx]
else
  result:=NIL;
end; // getAt

function TSSIacks.findID(id:Integer; NUM:Integer = -1):integer;
var
 e : TSSIEvent;
begin
for result:=count-1 downto 0 do
 begin
  e := getAt(result);
  if ( e<> NIL) AND (e.id = id) AND
     ((NUM < 0) or (NUM = e.NUM) ) then
    exit;
 end;
result:=-1;
end; // findID

// Set an implicit refcount so that refcounting
// during construction won't destroy the object.
class function TicqSession.NewInstance: TObject;
begin
  Result := inherited NewInstance;
  TicqSession( Result ).FRefCount := 1;
end;

class function TicqSession._getContactClass : TRnQCntClass;
begin
  Result := TICQContact;
end;
class function TicqSession._getProtoServers : String;
var
  i : Integer;
begin
  Result := '';
  for I := 0 to Length(ICQServers) - 1 do
    Result := Result + ICQServers[i]+ CRLF;
end;
class function TicqSession._getProtoID : Byte;
begin
  Result := ICQProtoID;
end;

function TicqSession.getContactClass : TRnQCntClass;
begin
  Result := TICQContact;
end;

class function TicqSession._MaxPWDLen: Integer;
begin
  Result := maxPwdLength;
end;

function TicqSession.getContact(const UID : TUID) : TRnQContact;
begin
  result := getICQContact(uid);
end;

function TicqSession.getStatuses: TStatusArray;
begin
  Result := ICQstatuses;
end;

function TicqSession.getVisibilitis : TStatusArray;
begin
  Result := icqVis;
end;

function TicqSession.getStatusMenu : TStatusMenu;
begin
  Result := statMenu;
end;

function TicqSession.getVisMenu : TStatusMenu;
begin
  Result := icqVisMenu;
end;

function TicqSession.getStatusDisable : TOnStatusDisable;
begin
  result := onStatusDisable[byte(curStatus)];
end;

procedure TicqSession.InputChangedFor(cnt :TRnQcontact; InpIsEmpty : Boolean; timeOut : boolean = false);
begin
  if (not SupportTypingNotif)or(not isSendTypingNotif) or not Assigned(cnt) then
    Exit;
  with TICQContact(cnt) do
  if (not (TICQContact(cnt).status in [SC_OFFLINE, SC_UNK])) and (typing.bSupport) then
    begin
      if (not InpIsEmpty) then
        begin
          if timeOut then
            begin
              typing.bIamTyping:=false;
              SendTYPING(cnt, MTN_TYPED);
            end
           else
            begin
             if not typing.bIamTyping then
              begin
               typing.bIamTyping:=true;
               SendTYPING(cnt, MTN_BEGUN);
              end;
             typing.typingTime:=now;
            end;
        end
      else if typing.bIamTyping then
        begin
          SendTYPING(cnt, MTN_FINISHED);
          typing.bIamTyping:=false;
        end
    end
end;


{
function TicqSession.sendFileTest(msgID:TmsgID; c:Tcontact; fn:string; size:integer) : Integer;
begin
//if not isReady then exit;

//if not imVisibleTo(c) then
// if addTempVisMsg then
//   addTemporaryVisible(c);
   begin
      eventDirect:=directTo(c);
      eventDirect.kind := DK_file;
      eventDirect.eventID := msgID;
      eventDirect.imSender := True;
      eventDirect.fileName := fn;
      eventDirect.fileTotal := size;
      //eventDirect.listen;
      eventDirect.connect;
   end;
   Result := msgID;
end; // sendFileOK
}

function TicqSession.compareStatusFor(cnt1, Cnt2 : TRnqContact) : Smallint;
begin
  if StatusPriority[TICQContact(cnt1).status] < StatusPriority[TICQContact(Cnt2).status] then
    result := -1
  else if StatusPriority[TICQContact(cnt1).status] > StatusPriority[TICQContact(Cnt2).status] then
    result := +1
  else
    Result := 0;
end;

procedure TicqSession.getClientPicAndDesc4(cnt:TRnQContact;
              var pPic : TPicName; var CliDesc : String);
var
  c : TICQContact;
begin
  if isOffline or (cnt=NIL) or cnt.isOffline then exit;
  if cnt is TICQContact then
    c := TICQContact(cnt)
   else
    Exit;

  getICQClientPicAndDesc(c, pPic, CliDesc);
end; // getClientPicAndDesc4

function TicqSession.getPrefPage : TPrefFrameClass;
begin
  result := TicqFr;
end;

procedure TicqSession.applyBalloon;
  function sameMonthDay(d1,d2:Tdatetime):boolean;
  begin
    result:=(MonthOf(d1)=monthOf(d2)) and (dayOf(d1)=dayOf(d2))
  end;
begin
// Assert(1=1,'applyBalloon need to define');
  if getMyInfo=NIL then
   raise Exception.create('applyBalloon: ICQ.myinfo is NIL');
   self.birthdayFlag := (sendBalloonOn=BALLOON_BDAY) and
               sameMonthDay(self.getMyInfo.birth,now)
               or (sendBalloonOn=BALLOON_DATE) and sameMonthDay(sendBalloonOnDate,now)
               or (sendBalloonOn=BALLOON_ALWAYS);
end; // applyBalloon


procedure InitICQProto;
var
  b, b2 : Byte;
begin
  SetLength(ICQstatuses, Byte(HIGH(tICQstatus))+1);
  for b := byte(LOW(tICQstatus)) to byte(HIGH(tICQstatus)) do
    with ICQstatuses[b] do
     begin
      idx := b;
      ShortName := status2img[b];
      Cptn      := status2ShowStr[TICQstatus(b)];
//      ImageName := 'status.' + status2str[st1];
      ImageName := 'status.' + ShortName;
     end;
  setLength(statMenu, 6);
  b2 := 0;
  statMenu[b2] := Byte(SC_ONLINE);inc(b2);
//  statMenu[1] := Byte(SC_F4C);inc(b2);
  statMenu[b2] := Byte(SC_OCCUPIED);inc(b2);
  statMenu[b2] := Byte(SC_DND);inc(b2);
  statMenu[b2] := Byte(SC_AWAY);inc(b2);
  statMenu[b2] := Byte(SC_NA);inc(b2);
//  statMenu[b2] := Byte(SC_Evil);inc(b2);
//  statMenu[b2] := Byte(SC_Depression);inc(b2);
  statMenu[b2] := Byte(SC_OFFLINE);

  SetLength(icqVis, Byte(HIGH(Tvisibility))+1);
  for b := byte(LOW(Tvisibility)) to byte(HIGH(Tvisibility)) do
    with ICQvis[B] do
     begin
      idx := b;
      ShortName := visib2str[Tvisibility(b)];
      Cptn      := visibility2ShowStr[Tvisibility(b)];
//      ImageName := 'status.' + status2str[st1];
      ImageName := visibility2imgName[Tvisibility(b)];
     end;
  setLength(icqVisMenu, 5);
  icqVisMenu[0] := Byte(VI_all);
  icqVisMenu[1] := Byte(VI_normal);
  icqVisMenu[2] := Byte(VI_CL);
  icqVisMenu[3] := Byte(VI_privacy);
  icqVisMenu[4] := Byte(VI_invisible);

//  ICQHelper := TICQHelper.Create;
//  RegisterProto(ICQHelper);
  RegisterProto(TicqSession);
end;

procedure UnInitICQProto;
var
  b : Byte;
begin
//var
//  B : Byte;
  for b := byte(LOW(tICQstatus)) to byte(HIGH(tICQstatus)) do
    with ICQstatuses[b] do
     begin
      SetLength(ShortName, 0);
      SetLength(Cptn, 0);
      SetLength(ImageName, 0);
     end;
  SetLength(ICQstatuses, 0);
  setLength(statMenu, 0);
  for b := byte(LOW(Tvisibility)) to byte(HIGH(Tvisibility)) do
    with ICQvis[B] do
     begin
      SetLength(ShortName, 0);
      SetLength(Cptn, 0);
      SetLength(ImageName, 0);
     end;
  SetLength(icqVis, 0);
  setLength(icqVisMenu, 0);
end;


INITIALIZATION

  InitICQProto;

FINALIZATION
  UnInitICQProto;
end.
