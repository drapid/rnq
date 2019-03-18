{
This file is part of R&Q.
Under same license
}
unit RnQProtocol;
{$I RnQConfig.inc}
{$I NoRTTI.inc}

interface
uses
  Windows, Classes, Types, SysUtils,
  RnQNet, RDGlobal,
  RnQPrefsInt, RnQPrefsTypes,
  RnQGraphics32, RDUtils
   ;
//    contacts;

type
  Tstatus = (SC_ONLINE = 0, SC_OFFLINE, SC_UNK);

  TXStatStr = record
                Cap, Desc: String;
              end;
type
  TLIST_TYPES = (LT_ROSTER, LT_VISIBLE, LT_INVISIBLE, LT_TEMPVIS, LT_SPAM);
 PStatusProp = ^TStatusProp;
 TStatusProp = record
   Cptn: String;
   ShortName: TPicName;
   ImageName: TPicName;
   idx: byte;
 end;
type
  TStatusArray = array of TStatusProp;
  TStatusMenu  = array of Byte;

 TOnStatusDisable = packed record
     tips,
     blinking,
     sounds,
     OpenChat: boolean;
   end;

const
  MinProtoID  = 1;
  ICQProtoID  = 1; //!!! ICQ +AIM
 {$IFDEF ICQ_ONLY}
   MAXProtoID  = 1;
   cProtosDesc: array[1..1] of String = ('ICQ');
 {$ELSE ~ICQ_ONLY}
  MRAProtoID = 2; //!!! Mail.ru Agent
  XMPProtoID = 3; //!!! Jabber
  OBIMProtoID = 4;
//  AIMProtoID = 4; //!!! AIM
  WIMProtoID = 5;
  MAXProtoID  = 5;

//  ProtosDesc: array[1..4] of String = ('ICQ', 'AIM', 'Mail.ru Agent', 'XMPP');
  cProtosDesc: array[MinProtoID..MAXProtoID] of String = ('ICQ', 'Mail.ru Agent', 'XMPP', 'OBIMP', 'ICQ Rest');
 {$ENDIF ICQ_ONLY}

const
  cUsedProtos2 = [ICQProtoID
 {$IFNDEF ICQ_ONLY}
   {$IFDEF PROTOCOL_MRA}
      ,MRAProtoID
   {$ENDIF PROTOCOL_MRA}
   {$IFDEF PROTOCOL_XMP}
      ,XMPProtoID
   {$ENDIF PROTOCOL_XMP}
   {$IFDEF PROTOCOL_BIM}
      ,OBIMProtoID
   {$ENDIF PROTOCOL_BIM}
   {$IFDEF PROTOCOL_WIM}
      ,WIMProtoID
   {$ENDIF PROTOCOL_WIM}
 {$ENDIF ICQ_ONLY}
   ];

  cProtocolsCount =
   {$IFDEF PROTOCOL_ICQ}
      1+
   {$ENDIF PROTOCOL_ICQ}
   {$IFDEF PROTOCOL_MRA}
      1+
   {$ENDIF PROTOCOL_MRA}
   {$IFDEF PROTOCOL_XMP}
      1+
   {$ENDIF PROTOCOL_XMP}
   {$IFDEF PROTOCOL_BIM}
      1+
   {$ENDIF PROTOCOL_BIM}
   {$IFDEF PROTOCOL_WIM}
      1+
   {$ENDIF PROTOCOL_WIM}
      0;


  cUsedProtos: array[0..cProtocolsCount-1] of byte =
 {$IFDEF ICQ_ONLY}
   (ICQProtoID
 {$ELSE ~ICQ_ONLY}
    (
   {$IFDEF PROTOCOL_ICQ}
      ICQProtoID
   {$ENDIF PROTOCOL_ICQ}
   {$IFDEF PROTOCOL_MRA}
      MRAProtoID
   {$ENDIF PROTOCOL_MRA}
   {$IFDEF PROTOCOL_BIM}
      OBIMProtoID
   {$ENDIF PROTOCOL_BIM}
   {$IFDEF PROTOCOL_XMP}
      XMPProtoID
   {$ENDIF PROTOCOL_XMP}
   {$IFDEF PROTOCOL_WIM}
      WIMProtoID
   {$ENDIF PROTOCOL_WIM}
 {$ENDIF ICQ_ONLY}
   );

type
 {$IFDEF UID_IS_UNICODE}
  TUID = String;
  TUID_Char = Char;
  PUID_Char = PChar;
 {$ELSE ansi}
  TUID = AnsiString;
  TUID_Char = AnsiChar;
 {$ENDIF UID_IS_UNICODE}
  TRnQContact = class;
  TRnQCList = class;
  TRnQCntClass = class of TRnQContact;

  TRnQProtocol = class;
  TProtoNotify = procedure (Sender: TRnQProtocol; event: Integer);
  TRnQProtoClass = class of TRnQProtocol;

  TProtoEvent=(
    IE_error,
    IE_online,
    IE_offline,
    IE_oncoming,
    IE_offgoing,
    IE_msg
   );
{$IFDEF usesDC}
  TProtoDirect = class;

  Tdirects = class(Tlist)
    proto: TRnQProtocol;
    constructor create(sess_: TRnQProtocol);
    destructor Destroy; override;
    function  newFor(c: TRnQContact): TProtoDirect;
    function  findID(id: UInt64): TProtoDirect;
   end; // Tdirects

//  TDirectMode = (dm_init, dm_bin_direct, dm_bin_proxy_init, dm_bin_proxy);
  TDirectMode = (dm_bin_direct, dm_bin_proxy);
  TDirectDataAvailable     = procedure (Sender: TObject; ErrCode: Word) of object;
  TDirectDataNext          = procedure (Sender: TObject; var Data: RawByteString;
                                        var IsLast: Boolean) of object;
  TDirectNotification      = procedure (Sender: TObject; ErrCode: Word;
                                        msg: String) of object;

  TProtoDirect=class
  protected
    P_host, P_port: AnsiString;
  public
    sock    : TRnQSocket;
    eventID : UInt64;
    contact : TRnQContact;
    directs : Tdirects;
    imserver: boolean;
    imSender: Boolean;
    needResume: Boolean;
    Directed: Boolean;
    UseLocProxy: Boolean;
    mode: TDirectMode;
    stage: byte;
    kind:(DK_none, DK_file);
    fileDesc: String;
//    fileName: string;
//    fileData: string;
    buf: RawByteString;
    fileCntReceived, fileCntTotal: integer;
    fileSizeReceived, fileSizeTotal: Int64;
    transferChkSum, fileChkSum: Cardinal;
    receivedChkSum: Cardinal;
//    Received: Int64;
    fileName: String;
    myspeed: integer;
    hisVer: integer;
    AOLProxy : record
                 ip   : Cardinal;
                 port : word;
               end;
    data: pointer;
    constructor Create; Virtual;
    destructor Destroy; override;
   protected
    FOnDataAvailable, FOnDisconnect : TDirectDataAvailable;
    FOnDataNext     : TDirectDataNext;
    FOnNotification : TDirectNotification;
{    procedure connected(Sender: TObject; Error: Word);
    procedure received(Sender: TObject; Error: Word);
    procedure sended(Sender: TObject; Error: Word);
    procedure disconnected(Sender: TObject; Error: Word);
}
    function  myPort: integer;
//    function  myinfo:TRnQContact;

    procedure sendPkt(const s: RawByteString);
   public
//    destructor Destroy;
{    procedure connect;
    procedure connect2proxy;
    procedure listen;
    procedure close;
    procedure Failed;
}
    procedure ProcessSend;
//    procedure DoneTransfer;
    procedure logMsg(err: Word; const msg: String);

    property OnDataAvailable : TDirectDataAvailable       read  FOnDataAvailable
                                                          write FOnDataAvailable;
    property OnDataNext      : TDirectDataNext            read  FOnDataNext
                                                          write FOnDataNext;
    property OnDisconnect    : TDirectDataAvailable       read  FOnDisconnect
                                                          write FOnDisconnect;
    property OnNotification : TDirectNotification         read FOnNotification
                                                          write FOnNotification;
    property  host: AnsiString read P_host;
    property  port: AnsiString read P_port;
   end; // Tdirect
{$ENDIF usesDC}


//  IRnQProtocol = interface;
(*
  IRnQProtocol = interface//(IInterface)
   ['{BBAA1D48-8480-4E7D-ADEB-EE6AE65D393D}']
//   public
//    listener            :TicqNotify;
//    sock                :Twsocket;
//    server              :Twsocket;
//    directs             :Tdirects;
//    myInfo : TContact;
//    constructor create;
//    destructor destroy;
//    procedure connect; overload;
//    procedure connect(createUIN:boolean); overload;
//   public
    function  getStatuses: TStatusArray;
    function  getVisibilitis: TStatusArray;
    function  getStatusMenu: TStatusMenu;
    function  getVisMenu: TStatusMenu;
    function  getContactClass: TRnQCntClass;
    function  getContact(const UID: TUID): TRnQContact;
      { Get the algorithm name }
    function  ProtoName: String;
    function  ProtoElem: TRnQProtocol;
    procedure GetPrefs(var pp: TRnQPref);
    procedure SetPrefs(pp: TRnQPref);
    procedure ResetPrefs;
    procedure Clear;

    procedure disconnect;
//    procedure setStatus(s: Tstatus; inv: boolean);
//    function  getStatus: Tstatus;
    function  isOnline: boolean;
    function  isOffline: boolean;
    function  isReady: boolean;     // we can send commands
    function  isConnecting: boolean;
    function  getStatus: byte;
    procedure setStatus(st: Byte);
    function  getVisibility: byte;
    function  IsInvisible: Boolean;
    function  getStatusName: String;
    function  getStatusImg: TPicName;
    function  getXStatus: byte;

    function  imVisibleTo(c: TRnQContact): boolean;
    procedure getClientPicAndDesc4(c: TRnQContact; var pPic : TPicName; var CliDesc : String);
    function  isMyAcc(c: TRnQContact): Boolean;
    function  getMyInfo: TRnQContact;
    function  maxCharsFor(const c: TRnQContact): integer;
//    function  canSendMsgFor(c: TRnQContact; msg: String):integer;


    // manage contact lists
    function  readList(l: TLIST_TYPES): TRnQCList;
    procedure AddToList(l: TLIST_TYPES; cl: TRnQCList); overLoad;
    procedure RemFromList(l: TLIST_TYPES; cl: TRnQCList); OverLoad;
    // manage contacts
    procedure AddToList(l: TLIST_TYPES; cnt: TRnQContact); OverLoad;
    procedure RemFromList(l: TLIST_TYPES; cnt: TRnQContact); OverLoad;

    function  addContact(c: TRnQContact; isLocal: Boolean = false):boolean;
    function  removeContact(c: TRnQContact): boolean;

    function  validUid1(const uin: TUID): boolean;
//    function  getContact(uid: TUID): TRnQContact;

    function  sendMsg(cnt: TRnQContact; var flags: dword; const msg:string; var requiredACK:boolean):integer; // returns handle
    procedure UpdateGroupOf(cnt: TRnQContact);

    // event managing

    procedure InputChangedFor(cnt: TRnQContact; InpIsEmpty: Boolean; timeOut: boolean = false);
    function  compareStatusFor(cnt1, Cnt2: TRnqContact): Smallint;

    procedure sendkeepalive;
//    procedure notifyListeners(ev: TicqEvent);
    // send packets
{
//    function  sendFLAP(ch: word; data: string): boolean;
//    function  sendSNAC(fam, sub: word; data: string):boolean;
//    procedure sendKeepalive;
//    function  sendMsg(uin, flags: dword; msg:string; var requiredACK:boolean):integer; // returns handle
//    procedure sendSMS(dest, msg: string; ack: boolean);
    function  sendAutoMsgReq(uin: integer): integer;
    procedure sendContacts(uin, flags: dword; cl: TcontactList);
    procedure sendQueryInfo(uin: integer);
    procedure sendAddedYou(uin: integer);
    function  sendFileReq(uin: integer; msg, fn: string; size:integer):integer; // returns handle
    procedure sendFileOk(msgID: TmsgID; c: Tcontact);
    procedure sendFileAck(msgID: TmsgID);
    procedure sendFileAbort(msgID: TmsgID);

    procedure sendACK(status: integer; msg, snac: string);
    procedure sendStatusCode;
    procedure sendCreateUIN;
    procedure sendDeleteUIN;
    procedure sendSaveMyInfoAs(c: Tcontact);
    procedure sendReqOfflineMsgs;
    procedure sendDeleteOfflineMsgs;

    procedure RemoveMeFromHisCL(uin: Integer);
}
    procedure SetListener(l: TProtoNotify);
    procedure AuthGrant(Cnt: TRnQContact);
    procedure AuthRequest(cnt: TRnQContact; const reason : String);
    function  getPwd: String;
    procedure setPwd(const pPWD: String);
    function  pwdEqual(const pass: String): Boolean;
//    procedure setMyInfo(cnt: TRnQContact);
    function  getStatusDisable: TOnStatusDisable;
    function  getPrefPage: TPrefFrameClass;
    property  pwd: String read getPwd write setPwd;
//    property  MyInfo: TRnQContact read getMyInfo write setMyInfo;
    property  statuses: TStatusArray read getStatuses;
   end; // IRnQProtocol
*)

//  TRnQProtocol = class (TObject, IRnQProtocol)
  TRnQProtocol = class
//    constructor Create; Virtual; Abstract;
//    destructor Destroy; Virtual; Abstract;
//    const ContactType : TRnQContactType =  TICQContact;
//    class function GetId: Word; virtual; abstract;
   protected
       FRefCount: Integer;
       MyAccount: TUID;
       listener: TProtoNotify;
   public
    fContactClass: TRnQCntClass;
    progLogon: double;
    loginServerAddr     : String;
    loginServerPort     : AnsiString;
    sock                : TRnQSocket;
    aProxy              : Tproxy;
    AccIDX              : Integer;
{$IFDEF usesDC}
//    server              : Twsocket;
    directs             : Tdirects;
{$ENDIF usesDC}
    SupportTypingNotif,
    isSendTypingNotif   : Boolean;
    class var contactsDB: TRnQCList;
//    contactsDB: TRnQCList;
    class constructor Create;
    class destructor Destroy;
    class function _GetProtoName: string; virtual; abstract;
    class function _isProtoUid(var uin: TUID): boolean; virtual; abstract;
    class function _isValidUid1(const uin: TUID): boolean; virtual; abstract;
    class function _getDefHost: Thostport; virtual; abstract;
    class function _getContactClass: TRnQCntClass; virtual; abstract;
    class function _getProtoServers: String; virtual; abstract;
    class function _getProtoID: Byte; Virtual; Abstract;
    class function _MaxPWDLen: Integer; virtual; abstract;

//    class function _CreateProto(const uid: TUID): IRnQProtocol; Virtual; Abstract;
    class function _CreateProto(const uid: TUID): TRnQProtocol; Virtual; Abstract;
    class function _RegisterUser(var pUID: TUID; var pPWD: String): Boolean; Virtual; Abstract;
//    Constructor Create(uid: TUID); Virtual; Abstract;
    procedure SetListener(l: TProtoNotify); Virtual;


    function  getStatuses: TStatusArray; Virtual; Abstract;
    function  getVisibilities: TStatusArray; Virtual; Abstract;
    function  getStatusMenu: TStatusMenu; Virtual; Abstract;
    function  getVisMenu: TStatusMenu; Virtual; Abstract;
    function  getContactClass: TRnQCntClass; Virtual; Abstract;
    function  getContact(const I: Integer): TRnQContact; OverLoad; Virtual;
    function  getContact(const UID: TUID): TRnQContact; OverLoad; Virtual; Abstract;
//    function  ProtoName: String; Virtual; Abstract;
    function  ProtoName: String; {$IFDEF HAS_INLINE} inline; {$ENDIF HAS_INLINE}
    function  ProtoElem: TRnQProtocol; {$IFDEF HAS_INLINE} inline; {$ENDIF HAS_INLINE}
    procedure GetPrefs(pp: IRnQPref); Virtual;
    procedure SetPrefs(pp: IRnQPref); Virtual;
    procedure ResetPrefs; Virtual;
    procedure Clear; Virtual; Abstract;
    function  getDefHost: Thostport; virtual;

    procedure disconnect; Virtual; Abstract;
//    procedure setStatus(s: Tstatus; inv: boolean);
//    function  getStatus: Tstatus;
    function  isOnline: boolean; Virtual; Abstract;
    function  isOffline: boolean; Virtual; Abstract;
    function  isReady: boolean;  Virtual; Abstract;    // we can send commands
    function  isConnecting: boolean; Virtual; Abstract;
    function  isSSCL: boolean; Virtual; Abstract;
    function  getStatus: byte; Virtual; Abstract;
    procedure setStatus(st: Byte); Virtual; Abstract;
    function  getVisibility: byte; Virtual; Abstract;
    function  IsInvisible: Boolean; Virtual; Abstract;
    function  getStatusName: String; Virtual; Abstract;
    function  getStatusImg: TPicName; Virtual; Abstract;
    function  getXStatus: byte; Virtual; Abstract;

    function  imVisibleTo(c: TRnQContact): boolean; Virtual; Abstract;
    procedure getClientPicAndDesc4(cnt: TRnQContact; var pPic: TPicName; var CliDesc: String); Virtual; Abstract;
    function  isMyAcc(c: TRnQContact): Boolean; Virtual; Abstract;
    function  maxCharsFor(const c: TRnQContact; isBin: Boolean = false): integer; Virtual; Abstract;
//    function  canSendMsgFor(c:TRnQContact; msg : String):integer;
    function  canAddCntOutOfGroup: Boolean; Virtual; Abstract;

    // manage contact lists
    function  readList(l: TLIST_TYPES): TRnQCList; Virtual; Abstract;
    procedure AddToList(l: TLIST_TYPES; cl: TRnQCList); overLoad; Virtual; Abstract;
    procedure RemFromList(l: TLIST_TYPES; cl: TRnQCList); OverLoad; Virtual; Abstract;
    // manage contacts
    procedure AddToList(l: TLIST_TYPES; cnt: TRnQContact); OverLoad; Virtual; Abstract;
    procedure RemFromList(l: TLIST_TYPES; cnt: TRnQContact); OverLoad; Virtual; Abstract;
    function  isInList(l: TLIST_TYPES; cnt: TRnQContact) : Boolean; Virtual; Abstract;

    function  addContact(c: TRnQContact; isLocal: Boolean = false): boolean; Virtual; Abstract;
    function  removeContact(c: TRnQContact): boolean; Virtual; Abstract;

    function  deleteGroup(grSSID: Integer): Boolean; Virtual; Abstract;

    function  validUid1(const uin: TUID): boolean; inline;
//    function  getContact(uid: TUID): TRnQContact;
    function  ContactExists(const UID: TUID): Boolean;

    function  sendMsg(cnt: TRnQContact; var flags: dword; const msg: string; var requiredACK: boolean): integer; Virtual; Abstract; // returns handle
    procedure UpdateGroupOf(cnt: TRnQContact); Virtual; Abstract;
    procedure UpdateGroupID(grID: Integer); Virtual; Abstract;

{$IFDEF usesDC}
    function getNewDirect: TProtoDirect; Virtual; Abstract;
{$ENDIF usesDC}

    // event managing

    procedure InputChangedFor(cnt: TRnQContact; InpIsEmpty: Boolean; timeOut: boolean = false); Virtual; Abstract;
    function  compareStatusFor(cnt1, Cnt2: TRnqContact): Smallint; Virtual; Abstract;

    procedure sendKeepalive; Virtual; Abstract;

    procedure AuthGrant(Cnt: TRnQContact); Virtual; Abstract;
    procedure AuthRequest(cnt: TRnQContact; const reason : String); Virtual; Abstract;
    function  getPwd: String; Virtual; Abstract;
    procedure setPwd(const pPWD: String); Virtual; Abstract;
    function  pwdEqual(const pass: String) : Boolean; Virtual; Abstract;
    function  getMyInfo: TRnQContact; Virtual; Abstract;
//    procedure setMyInfo(cnt: TRnQContact);
    function  getStatusDisable: TOnStatusDisable; Virtual; Abstract;
    function  getPrefPage: TPrefFrameClass; Virtual; Abstract;

    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
        procedure AfterConstruction; override; final;
        procedure BeforeDestruction; override; final;
    function getShowStr: String;

    property ProtoID: byte read _getProtoID;
//    class function getProtoByUID(uid : TUID) : TRnQProtoClass;
    property MyAccNum: TUID read MyAccount;
    property RefCount: Integer read FRefCount;

    property  pwd: String read getPwd write setPwd;
//    property  MyInfo :TRnQContact read getMyInfo write setMyInfo;
    property  statuses: TStatusArray read getStatuses;
    property curXStatus: Byte read getXStatus;
  end;
//type

//  TRnQProto = class (TRnQProtocol, IRnQProtocol)
//  end;
{
  TRnQProtoHelper = class //(TObject, IRnQProtocol)
//    constructor Create; Virtual; Abstract;
//    destructor Destroy; Virtual; Abstract;
//    const ContactType : TRnQContactType =  TICQContact;
//    class function GetId: Word; virtual; abstract;
    function GetProtoName: string; virtual; abstract;
    function isValidUid(var uin:TUID):boolean; virtual; abstract;
    function GetClass : TRnQProtoClass; virtual; abstract;
//    class function getProtoByUID(uid : TUID) : TRnQProtoClass;
  end;
}

//  PRnQContact = ^TRnQContact;

  TRnQContact = class //(TObject)
   public
    UID: TUID;
    UID2cmp: TUID; // LowerCase and without delimiters
    SSIID: Integer;
//    ClientStr : AnsiString;
    ClientPic: TPicName;
    ClientDesc: String;
    fDisplay,       // if user want to rename this contact
    nick,
    first,
    last,
    lclImportant: String;
    antispam: record
       Tryes: Byte;
       lastQuests: array of String;
     end;
    CntIsLocal: Boolean;
    Authorized,
    SendTransl: Boolean; // By Rapid D
    typing: packed record
      typingTime: TDateTime;
      bSupport,
      bIsTyping,
      bIAmTyping: Boolean;
     end;
    group: Integer;
    birth,
    birthL,       // Local Birthdate
    LastBDInform,
    lastTimeSeenOnline: TdateTime;   // local time
     {$IFDEF RNQ_AVATARS}
     Icon_Path: String;
//     icon : packed record
     icon: packed record
       Bmp: TRnQBitmap;
       cache: TRnQBitmap;
       ToShow: Byte;
       Flags: byte;
       HL: byte;
//    icon_ShowPh : Boolean;
       IsBmp: Boolean;
       ID: Word;
       Hash_safe: RawByteString;
//    icon : Tbitmap;
      end;
      {$ENDIF RNQ_AVATARS}
    data: pointer;
   protected
//    iProto: IRnQProtocol;
    fProto: TRnQProtocol;
   public
    class function trimUID(const uid: TUID): TUID; virtual; abstract;
    constructor Create(pProto: TRnQProtocol; const uin_: TUID); Virtual;
    destructor Destroy; override;
    procedure clear; Virtual; abstract;
    procedure clear1;
    function  getStatus: byte; virtual; abstract;
    function  getStatusName: String; virtual; abstract;
    function  statusImg: TPicName; virtual; abstract;
    function  isOnline    : Boolean; virtual; abstract;
    function  isInvisible : Boolean; virtual; abstract;
    function  isOffline   : Boolean; virtual; abstract;
    function  canEdit: Boolean; virtual; abstract;
    function _getProtoID: Byte; inline;
    function  displayed: string;
    function  displayed4All: string;
    function  uin2Show: String; virtual; abstract;
    function  getFN: String;
    function  equals(c: TRnQContact): boolean; ReIntroduce; OverLoad;
    function  equals(const pUID: TUID): boolean; ReIntroduce; OverLoad;
    function  equals(pUIN: Integer): boolean; ReIntroduce; OverLoad;
    procedure SetDisplay(const s: String); Virtual;
    function  GetDBrow: RawByteString; virtual; abstract;
    function  ParseDBrow(ItemType: Integer; const item: RawByteString): Boolean; virtual;
    procedure ViewInfo; virtual; abstract;
    function  isAcceptFile: Boolean; Virtual;
    function  GetBDay: TDateTime;
    function  Days2Bd: smallInt;
    function  imVisibleTo: Boolean;
    function  isInRoster: Boolean;
    function  isInList(l: TLIST_TYPES): Boolean;
    procedure AddToList(l: TLIST_TYPES); inline;
    procedure RemFromList(l: TLIST_TYPES); inline;
    function  isMyAcc: Boolean;
//   public
//    function  GetProto: IRnQProtocol;
    procedure SetGroupName(const pName: String);
    function  buin: RawByteString;
    function  UIDasInt: Integer;
    function  getGroupName: String;
    property  Display: string read fDisplay write SetDisplay;
    property  ProtoID: byte read _getProtoID;
    property  Proto: TRnQProtocol read fProto;
    property  Status: byte read getStatus;
  end;

  TCListEnumerator = class
  private
    FIndex: Integer;
    FCL: TRnQCList;
  public
    constructor Create(pCL: TRnQCList);
    function GetCurrent: TRnQContact; inline;
    function MoveNext: Boolean;
    property Current: TRnQContact read GetCurrent;
  end;

  TcontactProc = procedure(c: TRnQContact);
{$IFDEF DELPHI9_UP}
  TRnQContactType = type of TRnQContact;
{$ELSE DELPHI_9_DOWN}
  TRnQContactType = class of TRnQContact;
{$ENDIF DELPHI9_UP}
  TRnQCList = class(Tlist)
   protected
    enumIdx: integer;
   public
    function  GetEnumerator: TCListEnumerator;
    procedure resetEnumeration;
    function  hasMore: boolean;
    function  getNext: TRnQContact;
    function  get(cls: TRnQContactType; const UID: TUID): TRnQContact; OverLoad;
    function  get(cls: TRnQContactType; const uin: integer): TRnQcontact; overload; //OverRide;
    function  getAt(const idx: integer): TRnQContact;
    function  putAt(const idx: integer; c: TRnQContact): Boolean;
    function  exists(const c: TRnQContact): Boolean; overload;
    function  exists(const pProto: TRnQProtocol; const uin: TUID): boolean; overload;
    function  empty: boolean;
    function  add(const pProto: TRnQProtocol; const UID: TUID): TRnQcontact; overload; //OverRide;
    function  add(c: TRnQContact): boolean; overload;
    function  add(p: pointer): boolean; overload;
    function  add(cl: TRnQCList): TRnQCList; overload;
    function  remove(const c: TRnQContact): Boolean; overload;
    function  remove(p: pointer): boolean; overload;
    function  remove(cl: TRnQCList): TRnQCList; overload;
    function  intersect(cl: TRnQCList): TRnQCList;
    function  toString: RawByteString; reintroduce;
//    function  fromString(cls: TRnQContactType; const s: RawByteString; db:TRnQCList):boolean;
    function  fromString(pr: TRnQProtocol; const s: RawByteString; db: TRnQCList): boolean;
    function  clone: TRnQCList;
    procedure assign(cl: TRnQCList);
    procedure apply(p: TcontactProc);
//    procedure setStatus(st: TStatus);
//    function  idxOf(iProto: IRnQProtocol; uin: TUID): integer; overload;
    function  idxOf(cls: TRnQContactType; const uin: TUID): integer; overload;
    function  idxOf(uin: Integer): integer; overload;
    function  _idxOf(const uid: TUID): integer; overload;
//    function  idxBySSID(ssid: Word): integer;
    function  buinlist: RawByteString;
    function  toIntArray: TIntegerDynArray;
    procedure ForEach(const AIteratorEvent: TProc<TRnQContact> );
    procedure ForEachAsync(const AIteratorEvent: TProc<TRnQContact> );

//    function  getCount(group: integer=-1; OnlyOnline: Boolean = false): integer;
    function  getCount(group: integer; OnlyOnline: Boolean = false): integer;
    procedure getOnlOfflCount(var pOnlCount, pOfflCount: Integer);
//    procedure SetStatus(st: Byte);
//    function  C8SSIByGrp(grID: Integer): String;
//    function  SSIByGrp(grID: Integer): String;
    property Count;
   end; // TcontactList


var
//  protocols: array of IRnQProtocol;
  RnQProtos: array of TRnQProtoClass;
//  RnQProtos: array of TRnQProtoHelper;
//  contactsDB: TRnQCList;
  onContactCreation, onContactDestroying: TcontactProc;
  onStatusDisable: array [0..15] of TOnStatusDisable;

  masterUseSSI: Boolean; // ICQ - Use Server Side Information

//  procedure RegisterProtocol(proto: IRnQProtocol);
//  procedure RegisterProto(proto: TRnQProtoHelper);
  procedure RegisterProto(proto: TRnQProtoClass);

//  function ActiveProto: IRnQProtocol; Inline;

  function  Int2UID(const i: Integer): TUID; Inline;
  function  Raw2UID(const s: RawByteString): TUID;
  function  UID2RAW(const u: TUID): RawByteString;

const
 // Flags for messages
  IF_multiple = 1 shl 0;      // multiple recipients
  IF_offline  = 1 shl 1;      // sent while you were offline
  IF_urgent   = 1 shl 2;      // send msg urgent
  IF_noblink  = 1 shl 3;      // send to contact list

  IF_no_matter  = 1 shl 10;  // If set, don't play sound

const // Avatar type
  IS_AVATAR = 0;
  IS_PHOTO  = 1;
  IS_NONE   = 2;

var
  GMToffset:  TdateTime;  // add it to a GMT time, subtract it from your local time
  GMToffset0: TdateTime;  // For OfflineMsg-s & ViewInfo

implementation

uses
   StrUtils, OverbyteIcsWSocket, System.Threading,
 {$IFDEF UNICODE}
   AnsiStrings,
 {$ENDIF UNICODE}
   RnQBinUtils, RnQFileUtil,
//   RQLog, RQUtil,
   RnQGlobal, RnQCrypt, RnQPics,
   RnQConst, globalLib,
   mainDlg,
   ThemesLib;

//  ActProto: Integer;

{function ActiveProto: IRnQProtocol; inline;
begin
//  if (ActProto >=0) and (ActProto < Length(protocols)) then
//    Result := protocols[ActProto]
//   else
//    Result := NIL;
  result := ICQ;
end;
}
{function trimUID(uid: TUID): TUID;
var
  i: word;
begin
  result := '';
//  i := 1;
//  while i <= Length(uid) do
  for I := 1 to length(uid) do
   begin
    if uid[i] in UID_CHARS then
     Result := Result + uid[i];
//    inc(i);
   end;
end;
}

function TRnQProtocol.QueryInterface(const IID: TGUID; out Obj): HResult;
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


function TRnQProtocol._AddRef: Integer;
begin
  Result := InterlockedIncrement( FRefCount );
end;

function TRnQProtocol._Release: Integer;
begin
  Result := InterlockedDecrement( FRefCount );
//  if Result = 0 then
//    Destroy;
end;

procedure TRnQProtocol.AfterConstruction;
begin
// Release the constructor's implicit refcount
  InterlockedDecrement( FRefCount );
end;

procedure TRnQProtocol.BeforeDestruction;
begin
  //if RefCount <> 0 then Error( reInvalidPtr );
end;

class constructor TRnQProtocol.Create;
begin
  contactsDB := TRnQCList.create;
end;

class destructor TRnQProtocol.Destroy;
begin
  contactsDB.free;
  contactsDB := NIL;
end;

procedure TRnQProtocol.SetListener(l: TProtoNotify);
begin
  listener := l;
end;

function TRnQProtocol.getContact(const I: Integer): TRnQContact;
begin
  Result := getContact(IntToStr(i));
end;

function TRnQProtocol.ProtoName: String;
begin
  Result := _GetProtoName;
end;

function TRnQProtocol.ProtoElem: TRnQProtocol;
begin
  Result := self;
end;

function TRnQProtocol.validUid1(const uin: TUID): boolean;
begin
 Result := (Length(uin)>0) and self._isValidUid1(uin);
end;

function TRnQProtocol.ContactExists(const UID: TUID): Boolean;
begin
  Result := contactsDB.exists(self, uid);
end;

function TRnQProtocol.getShowStr: String;
var
  mi: TRnQContact;
begin
  mi := getMyInfo;
  if Assigned(mi) then
    Result := getMyInfo.displayed
   else
    Result := String(MyAccNum);
  Result := '(' + _GetProtoName + ') ' + Result;
end;

procedure TRnQProtocol.GetPrefs(pp: IRnQPref);
begin
  pp.addPrefStr('last-server-ip', lastserverIP);
  pp.addPrefStr('last-server-addr', lastserverAddr);
  pp.addPrefStr('server-host', MainProxy.serv.host);
  pp.addPrefInt('server-port', MainProxy.serv.port);
//  pp.addPrefStr('server-host', LoginServer.host);
//  pp.addPrefInt('server-port', LoginServer.port);

  pp.addPrefBool('typing-notify-flag', SupportTypingNotif);
  pp.addPrefBool('show-typing', isSendTypingNotif);

  if not dontSavePwd //and not locked
  then
    pp.addPrefBlob64('crypted-password64', passCrypt(StrToUTF8(pwd)))
   else
    pp.DeletePref('crypted-password64');
  pp.DeletePref('crypted-password');
end;

procedure TRnQProtocol.SetPrefs(pp: IRnQPref);
begin
  if pp.prefExists('crypted-password64') then
    pwd := UnUTF(passDecrypt(pp.getPrefBlob64Def('crypted-password64')))
   else
    pwd := String(passDecrypt(AnsiString(pp.getPrefBlobDef('crypted-password'))));

  pp.getPrefStr('last-server-ip', lastserverIP);
  pp.getPrefStr('last-server-addr', lastserverAddr);
  pp.getPrefBool('typing-notify-flag', SupportTypingNotif);
  pp.getPrefBool('show-typing', isSendTypingNotif);
end;

procedure TRnQProtocol.ResetPrefs;
begin
  lastServerIP := '';
  lastserverAddr := '';
  SupportTypingNotif := True;
  isSendTypingNotif  := True;
  pwd := '';
end;

function TRnQProtocol.getDefHost: Thostport;
begin
  Result := _getDefHost;
end;

{ TRnQContact }
{function TRnQContact.GetProto: IRnQProtocol;
begin
  result := ICQ;
end;}
constructor TRnQcontact.create(pProto: TRnQProtocol; const uin_: TUID);
begin
  inherited create;
  clear1;
  uid := trimUID(uin_);
  UID2cmp := LowerCase(uid);
  fProto := pProto;
  icon.Bmp := NIL;
//  if assigned(onContactCreation) then onContactCreation(self);
end; // create

destructor TRnQcontact.Destroy;
//var
//  i: Byte;
begin
 if assigned(onContactDestroying) then onContactDestroying(self);
  SetLength(UID2cmp, 0);
  SetLength(uid, 0);
 inherited Destroy;
end;

function TRnQContact._getProtoID: Byte;
begin
  Result := fProto.ProtoID;
end;

function TRnQContact.displayed: string;
begin
  if display > '' then
    result := display else
  if nick > '' then
    result := nick else
  if first > '' then
    result := first else
  if last > '' then
    result := last else
   result := String(uid);
  if Length(result) > MaxDispayedLen then
    SetLength(result, MaxDispayedLen);
end;

function TRnQContact.displayed4All: string;
begin
  if nick > '' then
    result := nick else
  if first > '' then
    result := first else
  if last > '' then
    result := last else
   result := String(uid);
  if Length(result) > MaxDispayedLen then
    SetLength(result, MaxDispayedLen);
end;

function TRnQcontact.getFN: String;
 {$IFNDEF ICQ_ONLY}
var
  s: String;
 {$ENDIF ~ICQ_ONLY}
begin
 {$IFNDEF ICQ_ONLY}
  s := Self.fProto.ProtoName;
  if s='ICQ' then
 {$ENDIF ~ICQ_ONLY}
    Result := String(UID2cmp)
 {$IFNDEF ICQ_ONLY}
   else
    Result := s + '_' + UID2cmp;
 {$ENDIF ~ICQ_ONLY}
end;

// destroy

procedure TRnQcontact.clear1;
begin
  uid := '';
  UID2cmp := '';
  nick := '';
  first := '';
  last := '';
//  status := SC_UNK;
  fDisplay := '';
  birthL := 0;
  SSIID := 0;
//  ClientStr := '';
  ClientPic := '';
  ClientDesc := '';
  lclImportant := '';
  CntIsLocal := True;
  antispam.Tryes := 0;
  icon.Bmp := NIL;
  icon.cache := NIL;
//  antispam.lastQuests
//nodb := FALSE;
end; // clear

function TRnQcontact.equals(c: TRnQcontact): boolean;
//var
//  i, j: Byte;
begin
  try
   if (not assigned(self)) or (not assigned(c)) or (UID2cmp='') or (c.UID2cmp='') then
    result := false
   else
{    begin
      i := 1; j := 1;
      repeat
         while uid[i] = ' ' do inc(i);
         while c.uid[j] = ' ' do inc(j);
         if (UpperCase(uid[i]) <> UpperCase(c.uid[j])) then
          begin
            result := false;
            Exit;
          end;
         inc(i); inc(j);
      until (j > Length(c.UID)) or (i > Length(UID));
      if (j > Length(c.UID)) and (i > Length(UID)) then
        result := True
       else
        result := false;
    end;}
//
  result := (c.UID2cmp = UID2cmp)
  except
   result := False;
  end;
end;

function TRnQcontact.equals(pUIN: Integer): boolean;
var
//  i, j: Byte;
  vUID: TUID;
begin
//  try
  vUID := Int2UID(pUIN);
   if (not assigned(self)) or (self.UID2cmp='') or (vUID='') then
    result := false
   else
{    begin
      i := 1; j := 1;
      repeat
         while uid[i] = ' ' do inc(i);
         while pUIN[j] = ' ' do inc(j);
         if (UpperCase(uid[i]) <> UpperCase(pUIN[j])) then
          begin
            result := false;
            Exit;
          end;
         inc(i); inc(j);
      until (j > Length(pUIN)) or (i > Length(UID));
      if (j > Length(pUIN)) and (i > Length(UID)) then
        result := True
       else
        result := false;
    end;}
//
  result := (UID2cmp = vUID)
//  except
//   result := False;
//  end;
end;

function TRnQcontact.equals(const pUID: TUID): boolean;
var
//  i, j: Byte;
  vUID: TUID;
begin
  try
   vUID := LowerCase(trimUID(pUID));
   if (not assigned(self)) or (self.UID2cmp='') or (vUID='') then
    result := false
   else
{    begin
      i := 1; j := 1;
      repeat
         while uid[i] = ' ' do inc(i);
         while pUIN[j] = ' ' do inc(j);
         if (UpperCase(uid[i]) <> UpperCase(pUIN[j])) then
          begin
            result := false;
            Exit;
          end;
         inc(i); inc(j);
      until (j > Length(pUIN)) or (i > Length(UID));
      if (j > Length(pUIN)) and (i > Length(UID)) then
        result := True
       else
        result := false;
    end;}
//
  result := (UID2cmp = vUID)
  except
   result := False;
  end;
end;

procedure TRnQcontact.SetDisplay(const s: String);
begin
  fDisplay := s;
end;

function TRnQcontact.buin: RawByteString;
begin
// result := intToStr(uin);
// result := uid;
// Result := uinAsStr;
  result := AnsiChar(length(UID2cmp))+ AnsiString( UID2cmp ); // !!!!!!!!!
end; // buin

function TRnQcontact.UIDasInt: Integer;
begin
 {$IFDEF UID_IS_UNICODE}
  result := StrToIntDef(uid2cmp, 0); // !!!!!!!!!
 {$ELSE UID_IS_UNICODE}
  result := StrToIntDef(String(uid2cmp), 0); // !!!!!!!!!
 {$ENDIF UID_IS_UNICODE}
end;

function TRnQcontact.ParseDBrow(ItemType: Integer; const item: RawByteString): Boolean;
begin
  Result := True;
    case ItemType of
      DBFK_Authorized: Authorized := boolean(item[1]);
      DBFK_DISPLAY:    fDisplay := UnUTF(item);
      DBFK_NICK:       nick := UnUTF(item);
      DBFK_FIRST:      first := UnUTF(item);
      DBFK_LAST:       last := UnUTF(item);

      DBFK_NOTES:      if Assigned(data) then TCE(data^).notes:= UnUTF(item);
      DBFK_DONTDELETE: if Assigned(data) then TCE(data^).dontdelete := boolean(item[1]);
      DBFK_ASKEDAUTH:  if Assigned(data) then TCE(data^).askedAuth := boolean(item[1]);
      DBFK_QUERY:      if Assigned(data) then TCE(data^).toquery := boolean(item[1]);
      DBFK_SENDTRANSL: SendTransl := boolean(item[1]);
      DBFK_BIRTH:      system.move(item[1], birth, 8);
      DBFK_BIRTHL:     system.move(item[1], birthL, 8);
      DBFK_LASTBDINFORM: system.move(item[1], LastBDInform, 8);
      DBFK_lclNoteStr: lclImportant := UnUTF(item);
      DBFK_ICONSHOW:   system.move(item[1], icon.ToShow, 1);
      DBFK_ICONMD5:    self.Icon.hash_safe := item;
      DBFK_SSIID: begin
                       SSIID := str2int(item);
                       CntIsLocal := SSIID = 0;
                  end;
      else
       begin
        Result := False;
       end
      ;
    end;
end;

function TRnQcontact.imVisibleTo: Boolean;
begin
  Result := fProto.imVisibleTo(self);
end;

function TRnQcontact.isInRoster: Boolean;
begin
  Result := fProto.isInList(LT_ROSTER, self);
end;

function TRnQContact.isAcceptFile: Boolean;
begin
  Result := false;
end;

function TRnQcontact.isInList(l: TLIST_TYPES): Boolean;
begin
  Result := fProto.isInList(l, self);
end;

function TRnQcontact.isMyAcc: Boolean;
begin
  Result := fProto.isMyAcc(Self);
end;

procedure TRnQcontact.AddToList(l: TLIST_TYPES);
begin
  fProto.AddToList(l, self);
end;

procedure TRnQcontact.RemFromList(l: TLIST_TYPES);
begin
  fProto.RemFromList(l, self);
end;

function TRnQcontact.GetBDay: TDateTime;
begin
  if birthL > 0 then
   result := birthL
  else
   if birth > 0 then
     result := birth
    else
     result := 0;
end;

function TRnQcontact.Days2Bd: smallInt;
const
//  maxDate = EncodeDate(3000, 1, 1);
  maxYear = 3000;
  maxDate = maxYear * 365 + maxYear div 4 - maxYear div 100 + maxYear div 400 + 1 - DateDelta;
var
 bd: TDateTime;
 y, m, d: Word;
 y2, m2, d2: Word;
begin
  bd := GetBDay;
  if (bd = 0) or (bd > maxDate) then
    Result := 2000//-1
  else
   begin
    DecodeDate(date, y,m,d);
    DecodeDate(bd, y2,m2,d2);
    if (m2 < m) or ((m2=m) and (d2 < d)) then
      y2 := y+1
     else
      y2 := y;
    if not TryEncodeDate(y2, m2, d2, bd) then
      if not TryEncodeDate(y2, m2+1, 1, bd) then // if 29 February :)
        begin
          Result := 2000;
          Exit;
        end;
    Result := Trunc(bd - Date);
   end;
end;

function TRnQcontact.getGroupName: String;
begin
  result := groups.id2name(group)
end;

procedure TRnQcontact.SetGroupName(const pName: String);
var
  gId: Integer;
begin
  gID := groups.name2id(pName);
  if gID >= 0 then
    begin
      self.group := gID
    end
   else
    begin
       if pName > '' then
         begin
           gID := groups.add();
           groups.rename(gID, pName);
         end
        else
          gId := 2000;
    end;
  self.group := gID;
end;

{ TCListEnumerator }

constructor TCListEnumerator.Create(pCL: TRnQCList);
begin
  inherited Create;
  FIndex := -1;
  FCL := pCL;
end;

function TCListEnumerator.GetCurrent: TRnQContact;
begin
  Result := FCL.getAt(FIndex);
end;

function TCListEnumerator.MoveNext: Boolean;
begin
  Result := FIndex < FCL.Count - 1;
  if Result then
    Inc(FIndex);
end;

/////////////// TRnQCList  ///////////////////////////////////////////////

function TRnQCList.getAt(const idx: integer): TRnQcontact;
begin
if (idx>=0) and (idx<count) then
//  result:=TRnQContact(items[idx])
//  result:= PRnQContact(List^[Idx])^
//  result:= TRnQContact(List^[Idx])
  result := TRnQContact(List[Idx])
else
  result := NIL
end; // getAt

function TRnQCList.idxOf(cls: TRnQContactType; const uin: TUID): integer;
var
  min, max: integer;
  u: TUID;
  uid: TUID;
  c: TRnQcontact;
begin
  UID := LowerCase(cls.trimUID(uin));
  if TList(Self).count = 0 then
   begin
    result := -1;
    exit;
   end;
  min := 0;
  max := TList(Self).count - 1;
  repeat
    result := (min+max) div 2;
    c := getAt(result);
    if Assigned(c) then
      u := c.UID2cmp
     else
      u := '';
    if u = uid then
      exit
    else
      if u > uid then
        max := result-1
      else
        min := result+1;
  until min > max;
  result := -1;
end; // idxOf

function TRnQCList._idxOf(const uid: TUID): integer;
var
  min, max: integer;
  u: TUID;
//  uid: TUID;
  c: TRnQcontact;
begin
//  UID := AnsiLowerCase(iProto.getContactClass.trimUID(uin));
  if count = 0 then
   begin
    result := -1;
    exit;
   end;
  min := 0;
  max := count-1;
  repeat
    result := (min+max) div 2;
    c := getAt(result);
    if Assigned(c) then
      u := c.UID2cmp
     else
      u := '';
    if u = uid then
      exit
    else
      if u > uid then
        max := result-1
      else
        min := result+1;
  until min > max;
  result := -1;
end; // idxOf

function TRnQCList.idxOf(uin: Integer): integer;
var
  min, max: integer;
//  u: TUID;
  uid: TUID;
  c: TRnQcontact;
begin
  uid := Int2UID(uin);
  min := 0;
  max := count-1;
  if max > 0 then
  repeat
    result := (min+max) div 2;
    c := getAt(result);
    if Assigned(c) then
     begin
      if c.UID2cmp = uid then
        exit
      else
        if c.UID2cmp > uid then
          max := result-1
        else
          min := result+1;
     end
    else
      min := result+1;
  until min > max;
  result := -1;
end; // idxOf

function TRnQCList.exists(const c: TRnQContact): boolean;
begin result := (c<>NIL) and (_idxOf(c.UID2cmp)>=0) end;

function TRnQCList.exists(const pProto: TRnQProtocol; const uin: TUID): boolean;
begin result := idxOf(pProto.getContactClass, uin)>=0 end;

function TRnQCList.add(p: pointer): boolean;
begin result := Tobject(p) is TRnQContact and add(TRnQContact(p)) end;

function TRnQCList.add(c: TRnQContact): boolean;
var
  i: integer;
  min, max: integer;
  cnt: TRnQContact;
begin
  result := (c<>NIL) and not exists(c);
if result then
  begin
//  i := 0;
//  while (i<count) and (c.UID2cmp > getAt(i).UID2cmp) do
//    inc(i);
    min := 0;
    max := count-1;
    if max >= 0 then
    repeat
      i := (min+max) div 2;
//      i:=(min+max) shr 1;
      cnt := getAt(i);
      if Assigned(cnt) then
       begin
//        if c.UID2cmp = getAt(i).UID2cmp then
//          exit
//        else
          if c.UID2cmp > cnt.UID2cmp then
            min := i+1
          else
            max := i-1;
       end
      else
        min:= i+1;
    until min > max;
    i := min;
  insert(i, c);
  end;
end; // add

function TRnQCList.putAt(const idx: integer; c: TRnQContact): boolean;
begin
  result := (c<>NIL) and not exists(c);
  if result then
    insert(idx, c);
end; // putAt

function TRnQCList.empty: boolean;
begin
  result := count=0
end;

function TRnQCList.remove(const c: TRnQContact): boolean;
begin result := inherited remove(c) >= 0 end;

function TRnQCList.remove(p: pointer): boolean;
//begin result:= Tobject(p^) is TRnQContact and remove(PRnQContact(p)^) end;
begin result := Tobject(p^) is TRnQContact and remove(TRnQContact(p)) end;

function TRnQCList.add(cl: TRnQCList): TRnQCList;
var
  i: integer;
begin
  result := self;
  if cl=NIL then
    exit;
  for i:=0 to cl.count-1 do
    add(cl.getAt(i));
end; // add

function TRnQCList.get(cls: TRnQContactType; const uin: integer): TRnQContact;
var
  i: integer;
begin
  i := idxOf(uin);
  if i >= 0 then
    result := TRnQContact(getAt(i))
   else
    begin
{
     result := cls.create(IntToStrA(uin));
     add(result);
}
     result := NIL;
    end;
end; // getDB

function TRnQCList.add(const pProto: TRnQProtocol; const uid: TUID): TRnQcontact;
var
  i: integer;
  cls: TRnQCntClass;
  u: TUID;
begin
  Result := NIL;
  cls := pProto.getContactClass;
  if (Length(UID) = 0) then
    Exit;
  u := LowerCase(cls.trimUID(uid));
  if Length(u)=0 then
    Exit;
  i := _idxOf(u);
  if i >= 0 then
    result:= getAt(i)
   else
    begin
//     result:= iProto.getContact(uid);
     result := cls.Create(pProto, uid);
     add(result);
    end;
end; // add


function TRnQCList.get(cls: TRnQContactType; const uid: TUID): TRnQContact;
var
  i: integer;
  u: TUID;
begin
  Result := NIL;
  if (Length(UID) = 0) then
    Exit;
  u := LowerCase(cls.trimUID(uid));
  if (Length(u)=0) then
    Exit;
  i := _idxOf(u);
  if i >= 0 then
    result:= getAt(i)
   else
    begin
{     result:= cls.create(uid);
     add(result);}
     result := NIL;
    end;
end; // getDB


function TRnQCList.remove(cl: TRnQCList): TRnQCList;
begin
  result := self;
  if cl=NIL then
    exit;
  inherited assign(cl, laSrcUnique);
end; // remove

function TRnQCList.intersect(cl: TRnQCList): TRnQCList;
begin
  result := self;
  if cl=NIL then
  begin
    clear;
    exit;
  end;
  inherited assign(cl, laAnd);
end; // intersect

function TRnQCList.toString: RawByteString;
var
  i: integer;
begin
  result := '';
  for i:=0 to count-1 do
//  result:=result + TRnQContact(items[i]).uid + CRLF;
//  result:=result + PRnQContact(List^[I]).uid + CRLF;
//    result:=result + StrToUTF8(TRnQContact(List^[I]).UID) + CRLF;
    result:=result + StrToUTF8(TRnQContact(List[I]).UID) + CRLF;
end;

//function TRnQCList.fromString(cls: TRnQContactType; const s: RawByteString; db: TRnQCList): boolean;
function TRnQCList.fromString(pr: TRnQProtocol; const s: RawByteString; db: TRnQCList): boolean;
var
  i: integer;
  s1: RawByteString;
  ofs: Integer;
  len: Integer;
begin
  result := TRUE;
  clear;
  ofs := 1;
// i := 1;
  len := Length(s);
// while s>'' do
// while i>0 do
 while ofs<Len do
  begin
  //  i:=pos(#10,s);
    i := posEx(AnsiString(#10), s, ofs);
    if (i>1) and (s[i-1]=#13) then
      dec(i);
    if i=0 then
      i := Len+1;
  //  s1 := copy(s,1,i-1);
    s1 := copy(s, ofs, i-ofs);
    try
//      add(db.get(cls, UTF8ToStr(s1)))
      add(db.add(pr, TUID(UTF8ToStr(s1))))
     except
      result := FALSE
    end;
    if s[i]=#13 then
      inc(i);
  //  system.delete(s,1,i);
    ofs := i+1;
  end;
end; // fromString

function TRnQCList.clone: TRnQCList;
var
  i: integer;
begin
  result := TRnQCList.create;
  for i:=0 to count-1 do
    result.add(getAt(i))
end; // clone

procedure TRnQCList.ForEach(const AIteratorEvent: TProc<TRnQContact> );
var
  cnt: TRnQContact;
begin
  if Self.Count > 0 then
    for cnt in Self do
      AIteratorEvent(cnt);
end;

procedure TRnQCList.ForEachAsync(const AIteratorEvent: TProc<TRnQContact> );
begin
  if Self.Count > 0 then
    TParallel.&For(0, Self.Count-1,  procedure(i: integer)
     begin
       AIteratorEvent(Self.Items[i]);
     end);
end;

function TRnQCList.GetEnumerator: TCListEnumerator;
begin
  Result := TCListEnumerator.Create(Self);
end;

procedure TRnQCList.resetEnumeration;
begin enumIdx := 0 end;

function TRnQCList.hasMore: boolean;
begin
  result := enumIdx<count
end;

function TRnQCList.getNext: TRnQContact;
begin
 result := getAt(enumIdx);
 inc(enumIdx);
end; // getNext

procedure TRnQCList.assign(cl: TRnQCList);
begin
  if cl=NIL then
    clear
   else
    inherited assign(cl, laCopy)
end;

procedure TRnQCList.apply(p: TcontactProc);
var
  i: integer;
begin
  i := 0;
  while i < count do
  begin
  //  p(PRnQContact(items[i])^);
    p(TRnQContact(items[i]));
    inc(i);
  end;
end;

function TRnQCList.buinlist: RawByteString;
var
  i: integer;
begin
  result := '';
  i := 0;
  while i < count do
  begin
  //    result := result+ PRnQContact(items[i]).buin;
      result := result+ TRnQContact(items[i]).buin;
    inc(i);
  end;
end; // buinList

function TRnQCList.toIntArray: TIntegerDynArray;
var
  i: integer;
begin
  setlength(result, count);
  for i:=0 to count-1 do
    result[i] :=  TRnQContact(items[i]).UIDasInt;
end; // toIntArray

function TRnQCList.getCount(group: integer; OnlyOnline: Boolean = false): integer;
var
  i: integer;
begin
  if group=-1 then
   begin
    result := inherited count;
    exit;
   end;
  result := 0;
 for i:=0 to count-1 do
//  if (TRnQContact(items[i]).group = group)
//     and ((not OnlyOnline) or TRnQContact(items[i]).isOnline) then
//  if (TRnQContact(List^[I]).group = group)
//  if (TRnQContact(List^[I]).group = group)
  if (TRnQContact(List[I]).group = group)
//     and ((not OnlyOnline) or TRnQContact(List^[I]).isOnline) then
     and ((not OnlyOnline) or TRnQContact(List[I]).isOnline) then
    inc(result);
end; // count

procedure TRnQCList.getOnlOfflCount(var pOnlCount, pOfflCount: Integer);
var
//  a, b,
  i: Integer;
begin
  pOnlCount := 0;
  pOfflCount:=0;
  for i:=0 to TList(self).count-1 do
    with TRnQcontact(getAt(i)) do
//      if group = groupid then
        if isOffline then
          inc(pOfflCount)
         else
          inc(pOnlCount);
//  pOnlCount := a;
//  pOfflCount := b;
end;

{procedure TRnQCList.SetStatus(st: Byte);
var
  i: integer;
  cnt: TRnQContact;
begin
  for i:=0 to count-1 do
   begin
    cnt := getAt(i);
//    if cnt is TICQContact then
//      TICQContact(cnt).status := st;
    cnt.status := st;
   end;
end;}



{procedure RegisterProto(proto: TRnQProtoHelper);
var
  i: Integer;
begin
  i := Length(RnQProtos);
  SetLength(RnQProtos, i+1);
  RnQProtos[i] := proto;
end;
                }
procedure RegisterProto(proto: TRnQProtoClass);
var
  i: Integer;
begin
  i := Length(RnQProtos);
  SetLength(RnQProtos, i+1);
  RnQProtos[i] := proto;
end;

{$IFDEF usesDC}
constructor Tdirects.create(sess_: TRnQProtocol);
begin
  proto := sess_;
end; // create

destructor Tdirects.Destroy;
var
  i: Integer;
begin
for i:=count-1 downto 0 do
  TProtoDirect(items[i]).free;
inherited;
end; // destroy


function Tdirects.newFor(c: TRnQContact): TProtoDirect;
begin
  result := c.fProto.getNewDirect;
  if Assigned(Result) then
   begin
    result.contact:=c;
    result.directs:=self;
    add(result);
   end;
end; // newFor

function Tdirects.findID(id: UInt64): TProtoDirect;
var
  i: Integer;
begin
  Result := NIL;
  for i:=count-1 downto 0 do
   if TProtoDirect(items[i]).eventID = id then
    begin
      Result := TProtoDirect(items[i]);
      Exit;
    end;

end;

///////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////

constructor TProtoDirect.create;
begin
  sock := TRnQSocket.create(NIL);
  sock.tag := integer(@self);
//  sock.OnDataAvailable:=received;
//  sock.OnSessionClosed:=disconnected;
  //sock.OnSocksError := OnProxyError;
  imserver := TRUE;
  kind := DK_none;
  stage := 0;
  mode := dm_bin_direct;
  Directed := False;
  needResume := False;
  AOLProxy.ip := 0;
  AOLProxy.port := 0;
  UseLocProxy := True;
  myspeed := 100;
end; // create

destructor TProtoDirect.Destroy;
begin
  directs.remove(self);
  if (sock.State = wsConnected)or
     (sock.State = wsListening)
  then
   begin
    sock.Close;
    sock.WaitForClose;  // prevent to change properties while the socket is open
   end;

  sock.free;
  SetLength(buf, 0);
  SetLength(P_host, 0);
  SetLength(P_port, 0);
  SetLength(fileName, 0);
//  SetLength(buf, 0);
  inherited;
end; // destroy



procedure TProtoDirect.ProcessSend;
var
  b: Boolean;
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

function TProtoDirect.myPort: integer;
begin
  tryStrToInt(sock.getxPort, result)
end;

procedure TProtoDirect.sendPkt(const s: RawByteString);
begin
//s:=word_LEasStr(length(s))+s;
//sock.sendStr(s);
  sock.PutStringInSendBuffer(s);
  if sock.State <> wsClosed then
    begin
      sock.Send(nil, 0);
//sock.SendFlags :=
//sock.SocketSndBufSize
//sock.Send(s);
{
      with TicqSession(directs.proto) do
//      with directs.proto do
      begin
       eventData:=s;
       eventDirect:=self;
       notifyListeners(IE_dcSent);
      end;}
    end;
end; // sendPkt

procedure TProtoDirect.logMsg(err: Word; const msg: String);
begin
  if Assigned(OnNotification) then
    OnNotification(Self, err, msg);
end;


{$ENDIF usesDC}
///////////////////////////////////////////////////////////////////////


function  Int2UID(const i: Integer): TUID;
begin
 {$IFDEF UID_IS_UNICODE}
   Result := IntToStr(i)
 {$ELSE ansi}
   Result := IntToStrA(i)
 {$ENDIF UID_IS_UNICODE}
end;

function  Raw2UID(const s: RawByteString): TUID;
begin
 {$IFDEF UID_IS_UNICODE}
   Result := unUTF(s)
 {$ELSE ansi}
   Result := s
 {$ENDIF UID_IS_UNICODE}
end;

function  UID2RAW(const u: TUID): RawByteString;
begin
 {$IFDEF UID_IS_UNICODE}
   Result := StrToUTF8(u)
 {$ELSE ansi}
   Result := u
 {$ENDIF UID_IS_UNICODE}
end;

var
  TZinfo: TTimeZoneInformation;

INITIALIZATION

  GetTimeZoneInformation(TZinfo);
  case GetTimeZoneInformation(TZInfo) of
    TIME_ZONE_ID_STANDARD: GMToffset := TZInfo.StandardBias;
    TIME_ZONE_ID_DAYLIGHT: GMToffset := TZInfo.DaylightBias;
    else GMToffset := 0;
    end;
  GMToffset := -(TZinfo.bias+GMToffset)/(24*60);
  GMToffset0 := -(TZinfo.bias)/(24*60);
//  ActProto := -1;

end.
