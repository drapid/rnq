{
  This file is part of R&Q.
  Under same license
}
unit TLG;
{$I RnQConfig.inc}
{$I NoRTTI.inc}

{$DEFINE usesVCL}

interface

uses
  Windows, SysUtils, Classes, Character, Types, JSON, Generics.Collections, Threading,
  ExtCtrls, StrUtils, Math, //OverbyteIcsHttpProt,
  RnQGlobal, RnQNet, RQThemes, RDGlobal, RQUtil, RnQJSON,
  RnQPrefsTypes, groupsLib,
  RnQProtocol, TLGContacts, TLGConsts, //WIM.Stickers,
  RnQPrefsInt,
  RnQPrefsLib,
  mormot.crypt.ecc256r1;


type
  TsplitProc = procedure(const s: RawByteString) of object;

  TmsgID = UInt64;

  TTLGEvent = (
    IE_error = Byte(RnQProtocol.IE_error),
    IE_online,
    IE_offline,
    IE_incoming,
    IE_outgoing,
    IE_msg,
    IE_buzz,
    IE_userinfo = Byte(High(RnQProtocol.TProtoEvent)) + 20,
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

    IE_serverSent,
    IE_serverGot,
    IE_serverSentU,
    IE_serverGotU,
    IE_serverSentJ,
    IE_serverGotJ,

    IE_uinDeleted,
    IE_myinfoACK,
    IE_pause,
    IE_resume,
    IE_ack,
    IE_automsgreq,
    IE_sendingAutomsg,
    IE_serverAck,
    IE_msgError,
    IE_Missed_MSG,
    IE_sendingXStatus,
//    IE_ackXStatus,
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
    IE_MultiChat,

    IE_UpdatePrefsFrm,

    IE_serverHistoryReady,
    IE_serverHistory,
    IE_stickersupdate,
    IE_stickersearchupdate,
    IE_TOS,
    IE_TOS_UPDATE
  );

  TTLGPhase = (
    null_,               // offline
    connecting_,         // trying to reach the login server
    connecting_sms_,     // trying to reach the login server with mobile number
    login_,              // performing login on login server
    login_sms_,          // performing login on login server using code from SMS
    reconnecting_,       // trying to reach the service server
    relogin_,            // performing login on service server
    settingup_,          // setting up things
    online_
  );

  TSessionParams = record
    fetchURL: String;
    aimsid: String;
    devid: String;
    secret: String;
    secretenc64: RawByteString;
//    key: RawByteString;
    token: String;
    tokenExpIn: Integer;
    tokenTime: Integer;
    hostOffset: Integer;
    restToken: String;
    restClientId: String;
  end;

  TTLGSession = class;

  TTLGNotify = procedure(Sender: TTLGSession; event: TTLGEvent) of object;
  TErrorProc = reference to procedure(Resp: TPair<Integer, String>);
  THandlerProc = reference to procedure(RespStrR: RawByteString);
  TReturnData = (RT_None, RT_JSON);

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
    REF_login
  );

  TTLGSessionSubType = (SESS_IM = 0, SESS_AVATARS = 1, SESS_NEW_UIN = 2);

  //internal delegate void Callback(IntPtr ptr);
  Ttd_log_fatal_error_callback_ptr = procedure (error_message: PAnsiChar);

//  TTLGSession = class(TRnQProtocol, IRnQProtocol)
  TTLGSession = class(TRnQProtocol)
   class var
  //Variable that receives the dll pointer
    tdjsonDll: THandle;
    TD_client_create: function(): IntPtr; cdecl;
    TD_client_destroy: procedure(handle: IntPtr); cdecl;
    TD_client_send: procedure(handle: IntPtr; data: PAnsiChar); cdecl;
    TD_client_receive: function(handle: IntPtr; t: double ): PAnsiChar; cdecl;
    TD_client_execute: function(handle: IntPtr; data: PAnsiChar): PAnsiChar; cdecl;
    TD_set_log_file_path: function(path: IntPtr): Int32; cdecl; //Deprecated;
    TD_set_log_max_file_size: procedure(size: Int64); cdecl; //Deprecated;
    TD_set_log_verbosity_level: procedure(level: Int32); cdecl;
    TD_set_log_fatal_error_callback: procedure(callback: Ttd_log_fatal_error_callback_ptr); cdecl;
    fTDClient: IntPtr;

  public
//    const ContactType: TRnQContactType =  TTLGContact;
//    type ContactType = TTLGContact;
    tlgOptions: TRnQPref;
    const ContactType: TClass =  TTLGContact;
  private
    is_closed: Integer;
    phase: TTLGPhase;
//    wasUINwp: Boolean;  // trigger a last result at first result
//    creatingUIN: Boolean;  // this is a special session, to create uin
//    isAvatarSession: Boolean;  // this is a special session, to get avatars
    protoType: TTLGSessionSubType; // main session; to create uin; to get avatars
    previousInvisible: Boolean;
    P_webaware: Boolean;
    P_authneeded: Boolean;
    P_showInfo: Byte;
//    startingInvisible: Boolean;
    StartingVisibility: TVisibility;
    StartingStatus: TTLGStatus;
    CurStatus: TTLGStatus;
    fVisibility: TVisibility;

//    SNACref: TmsgID;
    reqId: TmsgID;
//    cookie: RawByteString;
    waitingNewPwd: RawByteString;
    AttachedLoginPhone: String;

{
    refs: array [1..maxRefs] of record
      kind: TrefKind;
      uid: TUID;
    end;
}
    lastMsgIds: TStringList;
//    SSI_InServerTransaction: Boolean;
//    SSI_InServerTransaction: Integer;
    savingMyInfo: record
      running: Boolean;
      ACKcount: Integer;
      c: TTLGContact;
    end;
    fRoster: TRnQCList;
    fVisibleList: TRnQCList;
    fInvisibleList: TRnQCList;
    tempVisibleList: TRnQCList;
    spamList: TRnQCList;

    fPwd: String;
    LastFetchBaseURL: String;
    PatchVersion: String;

    procedure SetWebAware(value: Boolean);
    procedure SetAuthNeeded(value: Boolean);
    procedure checkOrGetServerHistory(const uid: TUID; retrieve: Boolean = False);

  public
    fECCKeys: record
      generated: Boolean;
      pubEccKey: TECCPublicKey;
      pk: TECCPrivateKey;
    end;
    localSSI_modTime: TDateTime;
    localSSI_itemCnt: Integer;
//    listener: TicqNotify;
//    MyInfo0: TTLGContact;
    birthdayFlag: Boolean;
    CurXStatus: Byte;
    CurXStatusStr: TXStatStr;
    serviceServerAddr: AnsiString;
    serviceServerPort: AnsiString;
    // used to pass valors to listeners
    eventError: TicqError;
    eventOldStatus: TTLGStatus;
    eventOldInvisible: Boolean;
    eventUrgent: Boolean;
    eventAccept: TicqAccept;
    eventContact: TTLGContact;
    eventContacts: TRnQCList;
    eventMsgA: RawByteString;
    eventAddress: String;
    eventNameA: AnsiString;
    eventString: String;
    eventBinData: RawByteString;
//    eventBinData: TBytes;
//    eventFilename: String;
    eventInt: Integer;    // multi-purpose
    eventFlags: Dword;
//    eventFileSize: LongWord;
    eventTime: TDateTime;  // in local time
    eventMsgID: TmsgID;
    eventStream: TMemoryStream;
    eventJSON: TJSONValue;
    eventReqID: RawByteString;
//    eventWID: RawByteString;
//    eventEncoding: TEncoding;

//    acceptKey: String;
//    ConnectSSL: Boolean;
    pPublicEmail,
    ShowClientID,
    UseCryptMsg,
    UseEccCryptMsg,
    SaveToken,
    AvatarsSupport,
    AvatarsAutoGet: Boolean;
    myAvatarHash: RawByteString;

    exectime: Int64;
    CleanDisconnect: Boolean;
//    LastSearchPacks: TStickerPacks;
    EnableRecentlyOffline: Boolean;
    RecentlyOfflineDelay: Integer;
    class var
      TLGstatuses, icqVis: TStatusArray;


    class function NewInstance: TObject; override; {$IFDEF HAS_FINAL} final; {$ENDIF HAS_FINAL}
//    class function GetId: Word; override;
    class function _GetProtoName: String; OverRide; {$IFDEF HAS_FINAL} final; {$ENDIF HAS_FINAL}
//    class function _isValidUid(var uin: TUID): Boolean; override; final;
    class function _isProtoUid(var uin: TUID): Boolean; OverRide; {$IFDEF HAS_FINAL} final; {$ENDIF HAS_FINAL}
    class function _isValidUid1(const uin: TUID): Boolean; OverRide; {$IFDEF HAS_FINAL} final; {$ENDIF HAS_FINAL}
    class function _IsValidPhone(const Phone: TUID): Boolean;
    class function _getDefHost: Thostport; OverRide; {$IFDEF HAS_FINAL} final; {$ENDIF HAS_FINAL}
    class function _getContactClass: TRnQCntClass; OverRide; {$IFDEF HAS_FINAL} final; {$ENDIF HAS_FINAL}
    class function _getProtoServers: String; OverRide; {$IFDEF HAS_FINAL} final; {$ENDIF HAS_FINAL}
    class function _getProtoID: Byte; OverRide; {$IFDEF HAS_FINAL} final; {$ENDIF HAS_FINAL}
    class function _CreateProto(const uid: TUID): TRnQProtocol; OverRide; {$IFDEF DELPHI9_UP} final; {$ENDIF DELPHI9_UP}
    class function  _RegisterUser(var pUID: TUID; var pPWD: String): Boolean; OverRide; {$IFDEF HAS_FINAL} final; {$ENDIF HAS_FINAL}
    class function _MaxPWDLen: Integer; override; final;
//    class function isValidUid(var uin: TUID): Boolean;
//    function isValidUid(var uin: TUID): Boolean;
//    function getContact(uid: TUID): TRnQContact;
//    class function GeTTLGContact(const uid: TUID): TTLGContact; overload;
//    class function GeTTLGContact(uin: Integer): TTLGContact; overload;
    function geTTLGContact(const uid: TUID): TTLGContact; overload;
    function geTTLGContact(const uin: Integer): TTLGContact; overload;

    function getContact(const UID: TUID): TRnQContact; overload; override; final;
    function getContact(const UIN: Integer): TRnQContact; overload;
    function getContactClass: TRnQCntClass; override; final;

    function pwdEqual(const pass: String): Boolean; override; final;
//    procedure setStatusStr(s: String; Pic: AnsiString = '');
    procedure setStatusStr(xSt: Byte; stStr: TXStatStr);
    procedure setStatusFull(st: Byte; xSt: Byte; stStr: TXStatStr);

//    constructor Create; override;
//    destructor Destroy; override;
    class constructor InitTLGProto;
    class destructor UnInitTLGProto;
    class function DLLInitialize: Boolean;
    constructor Create(const id: TUID; subType: TTLGSessionSubType);
    destructor Destroy; OverRide; {$IFDEF HAS_FINAL} final; {$ENDIF HAS_FINAL}
    procedure ResetPrefs; OverRide; {$IFDEF HAS_FINAL} final; {$ENDIF HAS_FINAL}
    procedure GetPrefs(pp: IRnQPref); OverRide; {$IFDEF HAS_FINAL} final; {$ENDIF HAS_FINAL}
    procedure SetPrefs(pp: IRnQPref); OverRide; {$IFDEF HAS_FINAL} final; {$ENDIF HAS_FINAL}
    procedure Clear; OverRide; {$IFDEF HAS_FINAL} final; {$ENDIF HAS_FINAL}
    function RequestPasswordIfNeeded(DoConnect: Boolean = True): Boolean;
    procedure Connect;
    procedure disconnect; OverRide; {$IFDEF HAS_FINAL} final; {$ENDIF HAS_FINAL}
    procedure setStatus(st: Byte); overload; override; final;
    procedure SetStatus(st: Byte; vi: Byte); overload;
    function getPwd: String; override; final;
    procedure setPwd(const value: String); override; final;
    function  td_receive(): RawByteString;
    function  td_send(J: TJSONObject): RawByteString;
    function MakeParams(const Method: AnsiString; const BaseURL: String; const Params: TDictionary<String, String>; Sign: Boolean = True; DoublePercent: Boolean = False): String;
    procedure OpenICQURL(URL: String);
    function ClientLogin: Boolean;
    function StartSession: Boolean;
    function PingSession: Boolean;
    procedure AfterSessionStarted;
    procedure ResetSession;
    procedure EndSession(EndToken: Boolean = False);
    procedure ProcessContactList(const CL: TJSONArray);
    function  ProcessContact(const Buddy: TJSONValue; GroupToAddTo: Integer = -1; Batch: Boolean = False): TTLGContact;
    procedure ProcessNewStatus(var Cnt: TTLGContact; NewStatus: TTLGStatus; CheckInvis: Boolean = False; XStatusStrChanged: Boolean = False; NoNotify: Boolean = False);
    procedure ProcessUsersAndGroups(const JSON: TJSONObject);
    procedure ProcessDialogState(const Dlg: TJSONObject; IsOfflineMsg: Boolean = False);
//    procedure ProcessIMData(const Data: TJSONObject);
    procedure ProcessTyping(const Data: TJSONObject);
    procedure ProcessAddedYou(const Data: TJSONObject);
    procedure ProcessPermitDeny(const Data: TJSONObject);
    procedure checkServerHistory(const uid: TUID);
    procedure getServerHistory(const uid: TUID);
    function RequiresLogin: Boolean;
    function RESTAvailable: Boolean;
    function getSession(updateIfReq: Boolean = True): TSessionParams;

    function getStatus: Byte; override; final;
    function getVisibility: Byte; override; final;
    function IsInvisible: Boolean; override; final;
    function isOnline: Boolean; override; final;
    function isOffline: Boolean; override; final;
    function isReady: Boolean; override; final; // we can send commands
    function isConnecting: Boolean; override; final;
    function isSSCL: Boolean; override; final;
    function imVisibleTo(c: TRnQContact): Boolean; override; final;
    function getStatusName: String; override; final;
    function getStatusImg: TPicName; override; final;
    function getXStatus: Byte; override; final;
    function IsMobileAccount: Boolean;
  public
    // manage contact lists
    function  readList(l: TLIST_TYPES): TRnQCList; override; final;

    procedure AddToList(l: TLIST_TYPES; cl: TRnQCList); overload; override; final;
    procedure RemFromList(l: TLIST_TYPES; cl: TRnQCList); overload; override; final;

    // manage contacts
//    function validUid(var uin: TUID): Boolean; inline;
//    function validUid1(const uin: TUID): Boolean; inline;
//    class function isValidUid(var uin: TUID): Boolean; static;
    procedure AddToList(l: TLIST_TYPES; cnt: TRnQContact); overload; override; final;
    procedure RemFromList(l: TLIST_TYPES; cnt: TRnQContact); overload; override; final;
    function isInList(l: TLIST_TYPES; cnt: TRnQContact): Boolean; override; final;

    function AddContact(c: TRnQContact; IsLocal: Boolean = false): Boolean; OverRide;
    function  removeContact(c: TRnQContact): boolean; OverRide;
    function  deleteGroup(grSSID: Integer): Boolean; OverRide;
    procedure UpdateGroupOf(cnt: TRnQContact); OverLoad; OverRide; {$IFDEF HAS_FINAL} final; {$ENDIF HAS_FINAL}
    procedure UpdateGroupID(grID: Integer); OverRide; {$IFDEF HAS_FINAL} final; {$ENDIF HAS_FINAL}

    procedure InputChangedFor(cnt: TRnQContact; InpIsEmpty: Boolean; timeOut: boolean = false); OverRide; {$IFDEF HAS_FINAL} final; {$ENDIF HAS_FINAL}
    function UpdateGroupOf(c: TTLGContact; grp: Integer): Boolean; OverLoad;
    procedure getClientPicAndDesc4(cnt: TRnQContact; var pPic: TPicName; var CliDesc: String); override; final;
    function maxCharsFor(const c: TRnQContact; isBin: Boolean = false):integer; override; final;
    function compareStatusFor(cnt1, Cnt2: TRnqContact): SmallInt; override; final;
    procedure sendKeepalive; override; final;
    function canAddCntOutOfGroup: Boolean; override; final;

{$IFDEF UNICODE}
//    procedure notificationForMsgW(msgtype: Byte; flags: Byte; urgent: Boolean; msg: String{; offline: Boolean = False});
{$ENDIF UNICODE}
    procedure notificationForMsg(msgtype: Byte; flags: Byte; urgent: Boolean; const msg: RawByteString{; offline: Boolean = False});
    function GetLocalIPStr: String;
    function CreateNewGUID: String;

  public // ICQ Only
//    property SSLserver: String read fSSLServer;
//    property ProxyServer: String read fOscarProxyServer;
    property getProtoType: TTLGSessionSubType read protoType;
    property WebAware: Boolean read P_webaware write SetWebAware;
    property AuthNeeded: Boolean read P_authNeeded write SetAuthNeeded;
    property showInfo: Byte read P_showInfo write P_showInfo;
    property pwd: String read getPwd write setPwd;
    property Visibility: TVisibility read fVisibility write fVisibility;
  private
    function getLocalIP: Integer;
    function serverPort: Word;
    function serverStart: Word;
    //procedure sendAddTempContact(const buinlist: RawByteString); overload; // 030F
  public
    procedure acceptTOS(const fn, ln: String); OverLoad;
    procedure acceptTOS(const tosId: String); OverLoad;
    procedure SSI_UpdateContact(c: TTLGContact);
    procedure SendAddContact(c: TTLGContact);
    procedure SendRemoveContact(c: TTLGContact);

    procedure AddContactToCL(var c: TTLGContact);
    procedure AddContactsToCL(cl: TRnQCList);
    procedure ClearTemporaryVisible;

    procedure RemoveContactFromServer(c: TTLGContact);
    function SendUpdateGroup(const Name: String; ga: TGroupAction; const Old: String = ''): Boolean;

    function useMsgType2for(c: TTLGContact): Boolean;
    procedure SendTyping(c: TTLGContact; NotifType: Word);

    procedure SendCreateUIN(const AcceptKey: RawByteString); deprecated;
    function  UploadAvatar(const fn: TFileName; cnt: TRnQContact = NIL; chat: Boolean = false): Boolean;
//    procedure sendPermsNew;//(c: Tcontact);

    procedure SendSaveMyInfo(c: TTLGContact);
    procedure SendContacts(Cnt: TRnQContact; flags: DWord; cl: TRnQCList); deprecated;
    procedure SendQueryInfo(const uid: TUID); deprecated;
//    procedure SendAddedYou(const uin: TUID);
    function GetMyCaps: RawByteString;

    procedure add2visible(cl: TRnQCList; OnlyLocal: Boolean = False); overload;
    procedure add2invisible(cl: TRnQCList; OnlyLocal: Boolean = False); overload;

    procedure GetProfile(const cnt: TTLGContact);
    procedure GetContactInfo(const UID: TUID; const IncludeField: String);
    procedure GetContactAttrs(const UID: TUID);
    procedure SendContactAttrs(c: TTLGContact);
    procedure GetCL;
    procedure FindContact;
    procedure ValidateSid;
    procedure GetExpressions(const uid: TUID);
    procedure GetAllCaps;
    procedure Test;
    function SendSessionRequest(IsPOST: Boolean; const BaseURL: String; const Query: RawByteString;
                                const Header: AnsiString = ''; const ErrMsg: String = ''; const ErrProc: TErrorProc = nil): Boolean; overload;
    function SendSessionRequest(IsPOST: Boolean; const BaseURL: String; const Query: RawByteString; Ret: TReturnData;
                                var JSON: TJSONObject; const Header: AnsiString = ''; const ErrMsg: String = ''; const ErrProc: TErrorProc = nil): Boolean; overload;
    function SendRequest(IsPOST: Boolean; const BaseURL: String; const Query: RawByteString;
                         const Header: AnsiString = ''; const ErrMsg: String = ''; const ErrProc: TErrorProc = nil): Boolean; overload;
    function SendRequest(IsPOST: Boolean; const BaseURL: String; const Query: RawByteString; Ret: TReturnData;
                         var JSON: TJSONObject; const Header: AnsiString = ''; const ErrMsg: String = ''; const ErrProc: TErrorProc = nil): Boolean; overload;
    procedure SendRequestAsync(IsPOST: Boolean; const BaseURL: String; const Query: RawByteString; const Header: AnsiString = ''; HandlerProc: THandlerProc = nil);
    function SendPresenceState: Boolean;
    procedure SendStatusStr(const st: Byte; const StText: String = '');

  protected
    // event managing
    procedure NotifyListeners(ev: TTLGEvent);
    procedure NotifyListenersSync(ev: TTLGEvent);
    // send packets
    procedure SendEccMSGsnac(const cnt: TTLGContact; const sn: RawByteString); deprecated;
//    procedure sendPermissions;

// TODO:
//    procedure sendRemoveVisible(cl: TRnQCList); overload;
//    procedure sendRemoveInvisible(cl: TRnQCList); overload;
//    procedure sendAddInvisible(cl: TRnQCList); overload;
//    procedure sendAddVisible(cl: TRnQCList); overload;

  private
    procedure GetPermitDeny;
    procedure SetPermitDenyMode(const Mode: String);
    procedure AddToBlock(const c: String);
    procedure RemFromBlock(const c: String);
    function Add2Visible(c: TTLGContact): Boolean; overload;
    function Add2Ignore(c: TTLGContact): Boolean; //overload;
    function RemFromIgnore(c: TTLGContact): Boolean;
    function Add2Invisible(c: TTLGContact): Boolean; overload;
    function AddTemporaryVisible(c: TTLGContact): Boolean; overload;
    function AddTemporaryVisible(cl: TRnQCList): Boolean; overload;
    function RemoveTemporaryVisible(c: TTLGContact): Boolean; overload;
    function RemoveTemporaryVisible(cl: TRnQCList): Boolean; overload;
    function RemoveFromVisible(c: TTLGContact): Boolean; overload;
    procedure RemoveFromVisible(const cl: TRnQCList); overload;
    function RemoveFromInvisible(c: TTLGContact): Boolean; overload;
    procedure RemoveFromInvisible(const cl: TRnQCList); overload;


    procedure GoneOffline; // called going offline
    procedure OnProxyError(Sender: TObject; Error: Integer; const Msg: String);
    procedure parsePagerString(s: RawByteString);

    function dontBotherStatus: boolean;
//    function myUINle: RawByteString;

  public // All
    function CreateDataPayload(Caps: TArray<RawByteString>; const Data: TBytes = nil; Compressed: Integer = -1; CRC: Cardinal = 0; Len: Integer = 0): String;
    function SendMsgOrSticker(Cnt: TRnQContact; var Flags: dword; const Msg: String; MsgType: TMsgType; chatId: String; var RequiredACK: Boolean): RawByteString; // returns handle
    function sendMsg(Cnt: TRnQContact; var Flags: dword; const Msg: String; chatId: String; var RequiredACK: Boolean): Integer; override; final; // returns handle
    function sendMsg2(Cnt: TRnQContact; var Flags: dword; const Msg: String; chatId: String; var RequiredACK: Boolean): RawByteString; override; final; // returns handle
    function SendSticker2(Cnt: TRnQContact; var Flags: dword; const Msg: String; chatId: String; var RequiredACK: Boolean): RawByteString;
    function SendBuzz(Cnt: TRnQContact): Boolean;
    procedure SetListener(l: TProtoNotify); override; final;
    procedure SetMuted(c: TTLGContact; Mute: Boolean);
    procedure AuthRequest(cnt: TRnQContact; const reason: String); OverRide; {$IFDEF HAS_FINAL} final; {$ENDIF HAS_FINAL}
    procedure AuthGrant(Cnt: TRnQContact); OverLoad; OverRide; {$IFDEF HAS_FINAL} final; {$ENDIF HAS_FINAL}
    procedure AuthGrant(c: TTLGContact; Grant: Boolean = True); OverLoad; deprecated;

//    function AddRef(k: TRefKind; const uin: TUID): Integer;
    function IncReqId: TmsgID;
    function isMyAcc(c: TRnQContact): Boolean; override; final;
    function getMyInfo: TRnQContact; override; final;
//    procedure setMyInfo(cnt: TRnQContact);
    function getStatuses: TStatusArray; override; final;
    function getVisibilities: TStatusArray; override; final;
    function  getStatusMenu: TStatusMenu; OverRide; {$IFDEF HAS_FINAL} final; {$ENDIF HAS_FINAL}
    function  getVisMenu: TStatusMenu; OverRide; {$IFDEF HAS_FINAL} final; {$ENDIF HAS_FINAL}
    function  getStatusDisable: TOnStatusDisable; OverRide; {$IFDEF HAS_FINAL} final; {$ENDIF HAS_FINAL}
    function  getPrefPage: TPrefFrameClass; OverRide; {$IFDEF HAS_FINAL} final; {$ENDIF HAS_FINAL}

    function GenSSID: Integer;
    procedure ApplyBalloon;
    property Statuses: TStatusArray read GetStatuses;
    property MyInfo: TRnQContact read getMyInfo;
    procedure SendSMS(const Dest, Msg: String; Ack: Boolean);
    procedure GetStoreStickerPacks;
    procedure SearchStoreStickerPacks(const Query: String);
//    function GetStoreStickerPack(const PackId: String): TStickerPack;
//    procedure BuyStickerPack(const PackId: String);
//    procedure RemoveStickerPack(const PackId: String);
  end; // TTLGSession

  TTLGProtoClass = class of TTLGSession;

var
//  sendInterests,
//  SupportInvisCheck,
  AddTempVisMsg,

  showInvisSts,

  AvatarsNotDnlddInform: Boolean;
  ExtClientCaps: RawByteString;
  AddExtCliCaps: Boolean;
  SendBalloonOn: Integer;
  SendBalloonOnDate: TDateTime;

  statMenu, icqVisMenu: TStatusMenu;
//  reqId: Integer = 1;

type
  TJSONHelper = class helper for TJSONObject
    function s(s: String): String;
    function o(s: String): TJSONObject;
  end;

implementation

uses
  Controls, dateUtils,
{$IFDEF UNICODE}
   AnsiStrings, AnsiClasses,
{$ENDIF UNICODE}
  RnQZip,
  mormot.crypt.core,
  RnQDialogs, RnQLangs, RDUtils, RDFileUtil, RnQCrypt, Base64,
{$IFDEF RNQ_AVATARS}
  RnQ_Avatars,
{$ENDIF}
  globalLib, utilLib, RnQConst, RnQProtoUtils,
  TLG_Fr,
//  themesLib, mainDlg,
  RnQStrings,
  Protocol_TLG, NetEncoding,
  viewTLGinfodlg;

//var
//  lastSendedFlap: TDateTime;


function TJSONHelper.s(s: String): String;
var
  v: TJSONValue;
begin
  if self.TryGetValue(s, v) then
    Result := v.Value
   else
    Result := '';
end;

function TJSONHelper.o(s: String): TJSONObject;
var
  v: TJSONObject;
begin
  if self.TryGetValue(s, v) then
    Result := v
   else
    Result := NIL;
end;

function sameMethods(a, b: TTLGNotify): boolean;
begin result := double((@a)^) = double((@b)^) end;

function str2url(const s: AnsiString): AnsiString;
var
  i: integer;
  ss: AnsiString;
begin
  result := '';
  for i:=1 to length(s) do
    begin
    case s[i] of
      ' ': ss := '%20';
      'A'..'Z','a'..'z','0'..'9': ss := s[i];
      else ss := '%'+IntToHexA(Byte(s[i]),2);
      end;
    result := result+ss;
    end;
end; // str2url

function str2html(const s: AnsiString): AnsiString;
var
  i: integer;
  ss: AnsiString;
begin
  Result := '';
  for i := 1 to length(s) do
  begin
    case s[i] of
{      'à':ss:='&egrave;';
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
    Result := Result + ss;
  end;
end; // str2html

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

procedure ShowRequestError(const BaseMsg: String; RespCode: Integer; const RespText: String);
begin
  MsgDlg('This feature isn''t available yet.\nCome back tomorrow...', True, mtInformation)
end;

function ParamEncode(const Param: String; DoublePercent: Boolean = False): RawByteString;
const
  HexMap: RawByteString = '0123456789ABCDEF';

  function IsSafeChar(ch: Byte): Boolean;
  begin
    if (ch >= 48) and (ch <= 57) then Result := True // 0-9
    else if (ch >= 65) and (ch <= 90) then Result := True // A-Z
    else if (ch >= 97) and (ch <= 122) then Result := True // a-z
    else if (ch = 33) then Result := True // !
    else if (ch >= 39) and (ch <= 42) then Result := True // '()*
    else if (ch >= 45) and (ch <= 46) then Result := True // -.
    else if (ch = 95) then Result := True // _
    else if (ch = 126) then Result := True // ~
    else Result := False;
  end;
var
  I, J: Integer;
  SrcUTF8: RawByteString;
  ch: AnsiChar;
  bb: Byte;
begin
  Result := '';
  if DoublePercent then
    SrcUTF8 := UTF8Encode(Param.Replace('%', '%25')) // Double encode percent
   else
    SrcUTF8 := UTF8Encode(Param);

  I := 1; J := 1;
  SetLength(Result, Length(SrcUTF8) * 3);
  while I <= Length(SrcUTF8) do
  begin
    ch := SrcUTF8[I];
    bb := Ord(ch);
    if IsSafeChar(bb) then
    begin
      Result[J] := ch;
      Inc(J);
    end
      else
    begin
      Result[J] := '%';
      Result[J+1] := HexMap[(bb shr 4) + 1];
      Result[J+2] := HexMap[(bb and $F) + 1];
      Inc(J,3);
    end;
    Inc(I);
  end;

  SetLength(Result, J - 1);
end;

function CheckResponseData(var JSON: TJSONObject; var pReqID: String): TPair<Integer, String>;
var
  Tmp: TJSONValue;
begin
  Result.Key := 0;
  Result.Value := '';
  if Assigned(JSON) then
  begin
    Tmp := JSON.GetValue('response');
    if Assigned(Tmp) and (Tmp is TJSONObject) then
    begin
      JSON := Tmp as TJSONObject;
      JSON.GetValueSafe('statusCode', Result.Key);
      JSON.GetValueSafe('statusText', Result.Value);
      if Result.Key = 200 then
      begin
        JSON.GetValueSafe('requestId', pReqID);
        Tmp := JSON.GetValue('data');
        if Assigned(Tmp) and (Tmp is TJSONObject) then
          JSON := Tmp as TJSONObject;
      end;
    end;
  end;
end;

class function TTLGSession._RegisterUser(var pUID: TUID; var pPWD: String): Boolean;
begin
  Result := False;
//  openURL('https://icq.com/join/');
end;

class function TTLGSession._CreateProto(const uid: TUID): TRnQProtocol;
begin
  Result := TTLGSession.Create(uid, SESS_IM);
end;

constructor TTLGSession.Create(const id: TUID; subType: TTLGSessionSubType);
var
  lInit: Boolean;
begin
//  if fTDClient then
  if tdjsonDll = 0 then
   lInit := DLLInitialize;

  if lInit then
    begin
     fTDClient := TD_client_create;

    end;
  protoType := subType;
  fContactClass := TTLGContact;

  inherited Create;

  phase := null_;
  listener := nil;
  is_closed := 1;

  if id = '' then
  begin
    MyAccount := '';
//    myinfo0 := nil
  end
    else
  begin
//    myinfo0 := GeTTLGContact(id);
//    MyAccount := myinfo0.UID2cmp;
    MyAccount := TTLGContact.trimUID(id);
    if _IsValidPhone(MyAccount) then
      AttachedLoginPhone := MyAccount;
  end;
{
  if (MyAccount <> '') and
    (pos(AnsiChar('@'), MyAccount) > 1) then
    Attached_login_email := MyAccount
  else
    Attached_login_email := '';
}
  fPwd := '';
//  SNACref := 1;
  reqId := 1;
//  lastSendedFlap := now;
  curStatus := SC_OFFLINE;
  fVisibility := VI_normal;
  curXStatus := 0;
  startingStatus := SC_ONLINE;

  sock := TRnQSocket.create(NIL);
//  cookie := '';
  PatchVersion := '';

  with _getDefHost do
  begin
    loginServerAddr := host;
    loginServerPort := IntToStr(port);
  end;
//  Q := TflapQueue.create;
  lastMsgIds := TStringList.Create;

  if subType = SESS_IM then
  begin
    showInfo := 2;
    webaware := True;
    fRoster := TRnQCList.create;
    fVisibleList := TRnQCList.create;
    fInvisibleList := TRnQCList.create;
    tempVisibleList := TRnQCList.create;
    spamList := TRnQCList.Create;

    savingmyinfo.running := False;
    fECCKeys.generated := Ecc256r1MakeKey(fECCKeys.pubEccKey, fECCKeys.pk);

    tlgOptions := TRnQPref.Create;
  end;
end; // create

procedure TTLGSession.ResetPrefs;
var
  i: Integer;
begin
//  ICQ.readList(LT_VISIBLE).clear;
//  ICQ.readList(LT_INVISIBLE).clear;
  inherited ResetPrefs;

  fVisibleList.clear;
  fInvisibleList.Clear;
  curXStatus := 0;
  authNeeded := True;
  pPublicEmail := False;
  ShowClientID := True;
  EnableRecentlyOffline := False;
  RecentlyOfflineDelay := 15;
  AddExtCliCaps := False;
  ExtClientCaps := '';
  SupportTypingNotif := True;
  isSendTypingNotif  := True;
  TypingInterval := 5;
  UseCryptMsg := True;
  UseEccCryptMsg := True;
  AvatarsSupport := True;
  AvatarsAutoGet := True;
  AvatarsNotDnlddInform := False;
  MyAvatarHash := '';
  SaveToken := True;
  localSSI_itemCnt  := 0;
  localSSI_modTime  := 0;
  showInvisSts := True;
  addTempVisMsg := False;
  SendBalloonOn := BALLOON_NEVER;
  onStatusDisable[byte(SC_OCCUPIED)].blinking := TRUE;
  onStatusDisable[byte(SC_OCCUPIED)].sounds := TRUE;
//  for I := low(XStatusArray) to High(XStatusArray) do
//  begin
//    ExtStsStrings[i].Cap := getTranslation(XStatusArray[i].Caption);
//    ExtStsStrings[i].Desc := '';
//  end;
end;

procedure TTLGSession.GetPrefs(pp: IRnQPref);
var
  i: Integer;
  s: String;
  sR: RawByteString;
begin
  if (MyAccount <> '') and
    (pos(AnsiChar('@'), MyAccount) <= 0) then
   pp.addPrefStr('oscar-uid', MyAccount);
  pp.addPrefBool('add-to-vislist-before-msg', addTempVisMsg);
  pp.addPrefBool('add-client-caps', AddExtCliCaps);
  pp.addPrefBlob64('add-client-caps-str', ExtClientCaps);
  pp.addPrefInt('send-balloon-on', SendBalloonOn);
  pp.addPrefDate('send-balloon-on-date', SendBalloonOnDate);
  try
    pp.addPrefBool('public-email', pPublicEmail);
    pp.addPrefBool('save-token', SaveToken);
  except
//    msgDlg('Какая-то глупая ошибка :(((', mtError);
  end;
//  pp.addPrefStr('server-host', MainProxy.serv.host);
//  pp.addPrefInt('server-port', MainProxy.serv.port);
  pp.addPrefBool('typing-notify-flag', SupportTypingNotif);
  pp.addPrefBool('show-typing', isSendTypingNotif);
  pp.addPrefInt('typing-notify-interval', TypingInterval);
  pp.addPrefBool('use-crypt-msg', useCryptMsg);
  pp.addPrefBool('use-ecc-crypt-msg', useEccCryptMsg);
  pp.addPrefBool('avatars-flag', AvatarsSupport);
  pp.addPrefBool('avatars-auto-load-flag', AvatarsAutoGet);
  pp.addPrefBool('avatars-not-downloaded-inform-flag', AvatarsNotDnlddInform);
  pp.addPrefBlob64('avatar-my', myAvatarHash);
 {$IFDEF CHECK_INVIS}
  pp.addPrefBool('support-invis-check', supportInvisCheck);
 {$ENDIF}
  pp.addPrefBool('recently-offline-enable', EnableRecentlyOffline);
  pp.addPrefInt('recently-offline-delay', RecentlyOfflineDelay);
  pp.addPrefBool('show-invis-status', showInvisSts);
  pp.addPrefBool('use-lsi', False);
  pp.addPrefBool('use-ssi', True);
//  pp.addPrefTime('local-ssi-time', localSSI.modTime);
//  pp.addPrefInt('local-ssi-count', localSSI.itemCnt);
  pp.addPrefTime('local-ssi-time', localSSI_modTime);
  pp.addPrefInt('local-ssi-count', localSSI_itemCnt);

    //for st:=SC_ONLINE to pred(SC_OFFLINE) do
   for i in self.getStatusMenu do
//    for i := byte(low(TTLGStatus)) to byte(high(TTLGStatus)) do
    if i <> byte(SC_OFFLINE) then
     begin
      s := status2Img[i]+'-disable-';
      pp.addPrefBool( s+'blinking', onStatusDisable[i].blinking);
      pp.addPrefBool( s+'tips', onStatusDisable[i].tips);
      pp.addPrefBool( s+'sounds', onStatusDisable[i].sounds);
      pp.addPrefBool( s+'openchat', onStatusDisable[i].OpenChat);
     end;
//    icq := TTLGSession(mainproto.ProtoElem);
    pp.addPrefBool('auth-needed', self.authneeded);
    pp.addPrefBool('webaware', self.webaware);
    pp.addPrefBool('show-client-id', ShowClientID);
    pp.addPrefInt('xstatus', self.curXStatus);
    pp.addPrefInt('icq-showinfo', self.showInfo);
      ;
  if not (RnQstartingStatus in [Low(status2Img)..High(status2Img)]) then
    pp.addPrefStr('starting-status', 'last_used')
   else
    pp.addPrefStr('starting-status', status2Img[RnQstartingStatus]);
  pp.addPrefStr('starting-visibility', visib2str[TVisibility(RnQStartingVisibility)]);

  pp.addPrefStr('last-set-status', status2Img[lastStatusUserSet]);

  inherited GetPrefs(pp);

  if not dontSavePwd //and not locked
  then
    begin
      sR := UTF(fPwd);
//      pp.addPrefBlob('crypted-password', passCrypt(sR));
      pp.addPrefBlob64('crypted-password64', passCrypt(sR))
    end
   else
    begin
      pp.DeletePref('crypted-password64');
    end;
  pp.DeletePref('crypted-password');

end;

procedure TTLGSession.SetPrefs(pp: IRnQPref);
var
  i: Integer;
  sU, sU2: String;
  st: Byte;
  l: RawByteString;
//  myInf: TRnQContact;
begin
  inherited SetPrefs(pp);

  pp.getPrefStr('oscar-uid', sU);
  if sU > '' then
    MyAccount := sU;

  pp.getPrefBool('public-email', pPublicEmail);
  pp.getPrefBool('add-client-caps', AddExtCliCaps);
  ExtClientCaps := hex2str(pp.getPrefBlobDef('add-client-caps-str'));

     authneeded := pp.getPrefBoolDef('auth-needed', authneeded);
     webaware   := pp.getPrefBoolDef('webaware', webaware);
     showInfo   := pp.getPrefIntDef('icq-showinfo', showInfo);
     i := pp.getPrefIntDef('xstatus');
     if i >= 0 then
     begin
//       if i > High(XStatus6) then
         curXStatus := 0;
     end;

     pp.getPrefInt('send-balloon-on', SendBalloonOn);
     pp.getPrefDate('send-balloon-on-date', SendBalloonOnDate);
      pp.getPrefInt('local-ssi-count', localSSI_itemCnt);
      pp.getPrefDateTime('local-ssi-time', localSSI_modTime);

      for st := Byte(low(TTLGStatus)) to Byte(high(TTLGStatus)) do
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
 {$ENDIF}
  pp.getPrefBool('recently-offline-enable', EnableRecentlyOffline);
  pp.getPrefInt('recently-offline-delay', RecentlyOfflineDelay);
  pp.getPrefBool('save-token', SaveToken);
  if pp.prefExists('crypted-password64') then
    l := passDecrypt(pp.getPrefBlob64Def('crypted-password64'))
   else
    l := passDecrypt(pp.getPrefBlobDef('crypted-password'));
  pwd := UnUTF(l);
  l := '';
  pp.getPrefBool('typing-notify-flag', SupportTypingNotif);
  pp.getPrefBool('show-typing', isSendTypingNotif);


  pp.getPrefInt('typing-notify-interval', TypingInterval);
  pp.getPrefBool('use-crypt-msg', useCryptMsg);
  pp.getPrefBool('use-ecc-crypt-msg', useEccCryptMsg);
  pp.getPrefBool('avatars-flag', AvatarsSupport);
  pp.getPrefBool('avatars-auto-load-flag', AvatarsAutoGet);
  pp.getPrefBool('avatars-not-downloaded-inform-flag', AvatarsNotDnlddInform);
  pp.getPrefBool('show-invis-status', showInvisSts);
  pp.getPrefBool('show-client-id', ShowClientID);

  l := pp.getPrefBlobDef('starting-status');
    if l='last_used' then
      RnQstartingStatus := -1
     else
      RnQstartingStatus := str2status(l);
  l := pp.getPrefBlobDef('starting-visibility');
    RnQStartingVisibility := Byte(str2visibility(l));

  l := pp.getPrefBlobDef('last-set-status');
    lastStatusUserSet := str2status(l);

  Visibility := TVisibility(RnQStartingVisibility);

  MyAvatarHash := pp.getPrefBlobDef('avatar-my');
  if Length(MyAvatarHash) > 256 then
    MyAvatarHash := Copy(MyAvatarHash, 1, 256);
  if contactsDB.idxOf(TTLGContact, MyAccount) >= 0 then
  with TTLGContact(GetMyInfo) do
  begin
//    status := TTLGStatus(SC_OFFLINE);
    IconID := MyAvatarHash;
  end;

  ApplyBalloon();

//  fSSLServer := pp.getPrefStrDef('oscar-ssl-server',
//                             ICQ_SECURE_LOGIN_SERVER0);
//  fOscarProxyServer := pp.getPrefStrDef('oscar-proxy-server',
//                             AOL_FILE_TRANSFER_SERVER0);
end;


procedure TTLGSession.Clear;
begin
//  myinfo0:=NIL;
  readList(LT_ROSTER).clear;
  readList(LT_VISIBLE).Clear;
  readList(LT_INVISIBLE).Clear;
  readList(LT_TEMPVIS).Clear;
  readList(LT_SPAM).Clear;

  FreeAndNil(eventContacts);
  eventContact := NIL;
end;

destructor TTLGSession.Destroy;
begin
//  Q.free;
  lastMsgIds.free;
  sock.free;
  fRoster.free;
  fVisibleList.free;
  fInvisibleList.free;
  tempvisibleList.free;
  spamList.Free;
  tlgOptions.Free;
  tlgOptions := NIL;
  inherited destroy;
end; // destroy

function TTLGSession.GetMyInfo: TRnQcontact;
begin
//  result := MyInfo0;
  Result := contactsDB.add(Self, MyAccount);
end;
{procedure TTLGSession.setMyInfo(cnt: TRnQContact);
begin
  myInfo := TTLGContact(cnt);
end;}

function TTLGSession.IsMyAcc(c: TRnQContact): Boolean;
begin
//  result := MyInfo0.equals(c);
  Result := Assigned(c) and c.equals(MyAccount)
end;

function TTLGSession.IncReqId: TmsgID;
begin
  reqId := reqId + 1;
  Result := reqId;
end;

function TTLGSession.canAddCntOutOfGroup: Boolean;
begin
  result := True;
end;

procedure TTLGSession.sendKeepalive;
begin
end;

function TTLGSession.pwdEqual(const pass: String): Boolean;
begin
  Result := ((pass<>'') and (pass = fPwd));
end;

function TTLGSession.getPwd: String;
begin
  Result := fPwd;
end;

function TTLGSession.RequiresLogin: Boolean;
begin
  Result := True;
end;

function TTLGSession.RESTAvailable: Boolean;
begin
  Result := false;
end;

function TTLGSession.getSession(updateIfReq: Boolean = True): TSessionParams;
begin
  if updateIfReq and RequiresLogin then
    StartSession;

end;

procedure TTLGSession.setPwd(const value: String);
begin
  if (Length(value) <= maxPwdLength) then
  if not (value = fPwd) then
    fPwd := value;
end; // setPwd

procedure TTLGSession.NotifyListeners(ev: TTLGEvent);
begin
  if Assigned(Listener) then
    Listener(Self, Integer(ev));
end; // notifyListeners

procedure TTLGSession.notifyListenersSync(ev: TTLGEvent);
var
  s: TJSONValue;
begin
  if Assigned(Listener) then
   begin
     s := eventJSON;
     eventJSON := NIL;
    TThread.Synchronize(nil, procedure
    begin
      if not Running then
        Exit;
      Listener(Self, Integer(ev), s);
      if s <> NIL then
        s.Free;
      s := NIL;
    end);
   end;
end; // notifyListeners

function TTLGSession.isOffline: boolean;
begin
  Result := phase = null_
end;

function TTLGSession.isOnline: boolean;
begin
  Result := phase = online_
end;

function TTLGSession.isConnecting: boolean;
begin
//  Result := not (isOffline or isOnline)
  Result := (phase <> online_) and (phase <> null_)
end;

procedure TTLGSession.GoneOffline;
begin
  is_closed := 1;
  if phase = null_ then
    Exit;
  phase := null_;

  tempvisibleList.clear;
  CurStatus := SC_OFFLINE;
  fRoster.ForEach(procedure(cnt: TRnQContact)
  begin
    TTLGContact(cnt).OfflineClear;
    TTLGContact(cnt).Status := SC_UNK;
  end);
  notifyListeners(IE_offline);
end; // GoneOffline

procedure TTLGSession.Disconnect;
begin
  CleanDisconnect := True;
  if phase = online_ then
    EndSession(not SaveToken)
  else
    Phase := null_;
end;

function TTLGSession.IsReady: Boolean;
begin
  Result := phase in [settingup_, online_]
end;

function TTLGSession.isSSCL: boolean;
begin
  Result :=
       True;
end;

function TTLGSession.IsMobileAccount: Boolean;
begin
  Result := String(MyAccount).StartsWith('+');;
end;

function TTLGSession.SendSessionRequest(IsPOST: Boolean; const BaseURL: String; const Query: RawByteString; const Header: AnsiString = '';
                                        const ErrMsg: String = ''; const ErrProc: TErrorProc = nil): Boolean;
var
  q: RawByteString;
begin
    Exit(False);
end;

function TTLGSession.SendSessionRequest(IsPOST: Boolean; const BaseURL: String; const Query: RawByteString; Ret: TReturnData;
                                        var JSON: TJSONObject; const Header: AnsiString = ''; const ErrMsg: String = ''; const ErrProc: TErrorProc = nil): Boolean;
var
  q: RawByteString;
begin
    Exit(False);
//  Result := SendRequest(IsPOST, BaseURL, q, Ret, JSON, Header, ErrMsg, ErrProc);
end;

function TTLGSession.SendRequest(IsPOST: Boolean; const BaseURL: String; const Query: RawByteString; const Header: AnsiString = '';
                                 const ErrMsg: String = ''; const ErrProc: TErrorProc = nil): Boolean;
var
  JSON: TJSONObject;
begin
  JSON := nil;
//  Result := SendRequest(IsPOST, BaseURL, Query, RT_None, JSON, Header, ErrMsg, ErrProc);
end;

function TTLGSession.SendRequest(IsPOST: Boolean; const BaseURL: String; const Query: RawByteString; Ret: TReturnData; var JSON: TJSONObject;
                                 const Header: AnsiString = ''; const ErrMsg: String = ''; const ErrProc: TErrorProc = nil): Boolean;
var
  Prefix: String;
  RespStrR: RawByteString;
  Resp: TPair<Integer, String>;
  lReqId: String;
begin
  if not Running then
    Exit;
  Result := False;
  Exit;

  Prefix := IfThen(IsPOST, '[POST] ', '[GET] ');
  eventNameA := Prefix + Header;
  if IsPOST then
    eventString := BaseURL + CRLF + Query
   else
    eventString := BaseURL + '?' + Query;
  notifyListeners(IE_serverGotU);
  if IsPOST then
    LoadFromURLAsString(BaseURL, RespStrR, Query)
  else
    LoadFromURLAsString(BaseURL + '?' + Query, RespStrR);

  eventNameA := Prefix + Header;
  eventMsgA := RespStrR;
  notifyListeners(IE_serverSentJ);

  if not ParseJSON(UTF8String(RespStrR), JSON) then
    Exit;

  try
    Resp := CheckResponseData(JSON, lReqId);
    if Resp.Key = Integer(EAC_OK) then
      Result := True
    else if Assigned(ErrProc) then
      ErrProc(Resp)
    else if not (ErrMsg = '') then
      MsgDlg(Format(GetTranslation(ErrMsg) + #13#10 + GetTranslation('Server returned error:') + #13#10 + '%s', [Resp.Value]), False, mtError)
    else
    begin
      eventInt := Resp.Key;
      eventMsgA := Resp.Value;
      eventError := EC_other;
      NotifyListeners(IE_error);
    end;
  finally
    if Ret = RT_None then
      FreeAndNil(JSON);
  end;
end;

procedure TTLGSession.SendRequestAsync(IsPOST: Boolean; const BaseURL: String; const Query: RawByteString; const Header: AnsiString = ''; HandlerProc: THandlerProc = nil);
var
  Prefix: String;
begin
  Prefix := IfThen(IsPOST, '[POST] ', '[GET] ');
  eventNameA := Prefix + Header;
  eventString := BaseURL + '?' + Query;
  notifyListeners(IE_serverGotU);

  TTask.Create(procedure
  var
    RespStr: RawByteString;
  begin
    if IsPOST then
      LoadFromURLAsString(BaseURL, RespStr, Query)
    else
      LoadFromURLAsString(BaseURL + '?' + Query, RespStr);

    TThread.Synchronize(nil, procedure
    begin
      if not Running then
        Exit;

      if Assigned(HandlerProc) then
        HandlerProc(RespStr);

      eventNameA := Prefix + Header;
      eventMsgA := RespStr;
      notifyListeners(IE_serverSent);
    end);
  end).Start;
end;

function TTLGSession.SendPresenceState: Boolean;
var
  Query: RawByteString;
  BaseURL: String;
begin
  Result := False;
{  BaseURL := WIM_HOST + 'presence/setState';
  Query :=
//           '&view=' + IfThen(Visibility = VI_invisible, 'invisible', Status2Srv[Byte(curStatus)]) +
           '&view=' + Status2Srv[Byte(curStatus)] +
           '&invisible=' + IfThen(Visibility = VI_invisible, '1', '0') +
           '&assertCaps=' + GetMyCaps;
           //IfThen(curStatus = SC_AWAY, '&away=Seeya', ''); // Not really useful, only you receive your awayMsg :)
  if SendSessionRequest(False, BaseURL, Query, 'Set status and visibility', 'Failed to set status') then
  begin
    // Not needed, same info as in myInfo in fetched event
    //ProcessContaсt(json.GetValue('myInfo') as TJSONObject)
    Result := True;
  end;
}
end; // SendWebStatusAndVis

procedure TTLGSession.SendStatusStr(const st: Byte; const StText: String = '');
var
  Query: UTF8String;
  BaseURL, TmpStr: String;
begin
  eventContact := nil;
{
  if not (st in [0..0]) then
    Exit;

  // XStatus is just for local display
  if StText <> ExtStsStrings[st].Desc then
    ExtStsStrings[st].Desc := StText;

  curXStatus := st;
  eventInt := st;
  curXStatusStr.Cap := ExtStsStrings[st].Cap;
  curXStatusStr.Desc := ExtStsStrings[st].Desc;
  eventNameA := UTF(ExtStsStrings[st].Cap);
  eventMsgA := UTF(ExtStsStrings[st].Desc);
  notifyListeners(IE_sendingXStatus);

  TmpStr := UnUTF(eventNameA);
  if curXStatusStr.Cap <> TmpStr then
    curXStatusStr.Cap := TmpStr;
  TmpStr := UnUTF(eventMsgA);
  if curXStatusStr.Desc <> TmpStr then
    curXStatusStr.Desc := TmpStr;

//  RnQmain.PntBar.Repaint;
  SaveCfgDelayed := True;

  if IsReady then
  if not (Visibility = VI_invisible) then // Do not change msg if invisible, it generates "offline" presence event
  begin
    BaseURL := WIM_HOST + 'presence/setStatus';
    Query := '&statusMsg=' + ParamEncode(curXStatusStr.Desc);
    if SendSessionRequest(True, BaseURL, Query, 'Set status string', 'Failed to set status message') then
    begin
      // Not needed, same info as in myInfo in fetched event
      //ProcessContaсt(json.GetValue('myInfo') as TJSONObject)
    end;
  end;
}
end; // SendWebStatusStr

//procedure TTLGSession.setStatusStr(s: String; Pic: String = '');
procedure TTLGSession.setStatusStr(xSt: byte; stStr: TXStatStr);
var
  s: String;
begin
  eventContact := NIL;
  if not (xSt in [0..0]) then
    Exit;

  curXStatus := xSt;
  eventInt := xSt;
  curXStatusStr.Cap := stStr.Cap;
  curXStatusStr.Desc := stStr.Desc;
  eventNameA := UTF(stStr.Cap);
  eventMsgA  := UTF(stStr.Desc);
//  eventMsg  := AnsiToUtf8(stStr.Desc);
  notifyListeners(IE_sendingXStatus);
//  title := eventName;
//  s := eventMsg;
  s := UnUTF(eventNameA);

  if //(eventName > '') and
     (curXStatusStr.Cap <> s) then
    curXStatusStr.Cap := s;
  s := UnUTF(eventMsgA);
  if //(eventMsg > '') and
     (curXStatusStr.Desc <> s) then
    curXStatusStr.Desc := s;

  if IsReady then
  begin
//  sendSNAC(ICQ_SERVICE_FAMILY, $1E, TLV($1D, word_BEasStr($02) + #$04 + BUIN( Length_BE(StrToUTF8(s))+
//                                 Length_BE('') // 'iso-8859-1'
//                                    )+
//                              TLV($0E, Pic))
//          );
//  sendSNAC(ICQ_SERVICE_FAMILY, $1E, TLV($1D, TLV($0E, Pic))
//          );
  end;
end;

procedure TTLGSession.setStatusFull(st: byte; xSt: byte; stStr: TXStatStr);
var
  s : String;
  ChangedSts, ChangedXStsID, ChangedXStsDesc : Boolean;
begin
  eventContact := NIL;
  if not (xSt in [0.. 0]) then
    xSt := 0;
  ChangedXStsID := curXStatus <> xSt;
  ChangedXStsDesc := curXStatusStr.Desc <> stStr.Desc;
  if ChangedXStsID or ChangedXStsDesc then
    begin
      curXStatus := xSt;
      eventInt := xSt;
      curXStatusStr.Desc := stStr.Desc;
      eventNameA := UTF(stStr.Cap);
      eventMsgA  := UTF(stStr.Desc);
    //  eventMsg  := AnsiToUtf8(stStr.Desc);
      notifyListeners(IE_sendingXStatus);
    //  title := eventName;
    //  s := eventMsg;
      s := UnUTF(eventNameA);
      if //(eventName > '') and
         (curXStatusStr.Cap <> s) then
        curXStatusStr.Cap := s;
      s := UnUTF(eventMsgA);
      if //(eventMsg > '') and
         (curXStatusStr.Desc <> s) then
        curXStatusStr.Desc := s;
    end;


  if st = byte(SC_OFFLINE) then
  begin
    Disconnect;
    Exit;
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
    startingStatus    := TTLGStatus(st);
   end;

  if IsReady then
    begin
      curStatus := TTLGStatus(st);
    //  eventContact := myinfo;
      eventContact:= NIL;
      notifyListeners(IE_statuschanged);
    end
   else
    Connect;
end;

procedure TTLGSession.SendEccMSGsnac(const cnt: TTLGContact; const sn: RawByteString);
var
  cap: RawByteString;
  mykey: RawByteString;
begin
  cap := 'RDEC0' + Copy(cnt.crypt.EccPubKey, 1, 11);
  SetLength(mykey, SizeOf(fECCKeys.pubEccKey));
  CopyMemory(@mykey[1], @fECCKeys.pubEccKey[0], Length(mykey));
end;

procedure CalcKey(isEcc: Boolean; const EccKey, u1, u2: RawByteString; l1, l2: Int64; var key: TSHA256Digest);
var
  sr: RawByteString;
begin
  if isEcc then
    PBKDF2HMACSHA256(EccKey, not2Translate[2] + TD_MSG_SECRET_STRING + IntToHex(l1, 2) + u1 + IntToHex(l2, 2) + u2, 3, Key)
  else
  begin
    sr := MD5Pass(IntToHex(l1, 2) + (not2Translate[2]) + u1 + TD_MSG_SECRET_STRING);
    CopyMemory(@Key[0], @sr[1], SizeOf(TMD5Digest));

    sr := MD5Pass(IntToHex(l2, 2) + not2Translate[2] + u2 + TD_MSG_SECRET_STRING);
    CopyMemory(@Key[16], @sr[1], SizeOf(TMD5Digest));
  end;
end;

function TTLGSession.SendMsg(Cnt: TRnQContact; var Flags: dword; const Msg: String; chatId: String; var RequiredACK: Boolean): Integer;
begin
  Result := -1;
  SendMsgOrSticker(Cnt, flags, Msg, MSG_TEXT, chatId, RequiredACK);
end;

function TTLGSession.SendMsg2(Cnt: TRnQContact; var Flags: dword; const Msg: String; chatId: String; var RequiredACK: Boolean): RawByteString;
begin
  Result := SendMsgOrSticker(Cnt, flags, Msg, MSG_TEXT, chatId, RequiredACK);
end;

function TTLGSession.SendSticker2(Cnt: TRnQContact; var Flags: dword; const Msg: String; chatId: String; var RequiredACK: Boolean): RawByteString;
begin
  Result := SendMsgOrSticker(Cnt, flags, Msg, MSG_STICKER, chatId, RequiredACK);
end;

function TTLGSession.SendMsgOrSticker(Cnt: TRnQContact; var Flags: dword;
                                      const Msg: String; MsgType: TMsgType;
                                      chatId: String;
                                      var RequiredACK: Boolean): RawByteString;
const
  AESBLKSIZE = SizeOf(TAESBlock);
var
  c: TTLGContact;
  Msg2, Msg2Enc, CrptMsg: TBytes;
  ReadyMsg: String;
  Key: TSHA256Digest;
  Ctx: TAESECB;
  i, Len, Len2, Compressed, Encrypted: Integer;
  crc: Cardinal;
  ShouldEncrypt, IsBin, IsSticker: Boolean;
  Params: TDictionary<String, String>;
  BaseURL: String;
  Handler: THandlerProc;
  msgJ, msgCntJ, msgtxtj: TJSONObject;
begin
  Result := '';
  RequiredACK := false;
  if not IsReady then
    Exit;

  c := TTLGContact(Cnt);
  isBin := (Pos(RnQImageTag, msg) > 0) or ((Pos(RnQImageExTag, msg) > 0)) or (IF_Bin and flags > 0);
  if isBin then
    flags := flags or IF_Bin;

  msgJ := TJSONObject.Create;
  msgJ.AddPair('@type', 'sendMessage');
  msgJ.AddPair('chat_id', chatId);

  msgCntJ := TJSONObject.Create;
  msgCntJ.AddPair('@type', 'inputMessageText');

  msgTxtj := TJSONObject.Create;
  msgTxtJ.AddPair('@type', 'formattedText');
  msgTxtJ.AddPair('text', msg);

  msgCntJ.AddPair('text', msgTxtj);
  msgJ.AddPair('input_message_content', msgCntJ);
  //send request
//  ReturnStr :=
    td_send(msgJ);
  msgJ.free;
  msgJ := NIL;
  exit;


//  if not imVisibleTo(c) then
//    if addTempVisMsg then
//      AddTemporaryVisible(c); // TODO: New proto implementation



end; // SendMsg

function TTLGSession.CreateDataPayload(Caps: TArray<RawByteString>; const Data: TBytes = nil; Compressed: Integer = -1; CRC: Cardinal = 0; Len: Integer = 0): String;
var
  JSON: TJSONObject;
  CapsArr: TJSONArray;
  Cap: String;
begin
  Result := TEncoding.UTF8.GetString(Data);
  JSON := TJSONObject.Create;
  try
    CapsArr := TJSONArray.Create;
    for Cap in Caps do
    CapsArr.Add(Cap);

    JSON.AddPair(TJSONPair.Create('type', 'RnQDataIM'));
    JSON.AddPair(TJSONPair.Create('caps', CapsArr));
    if Assigned(Data) then
      JSON.AddPair(TJSONPair.Create('data', TEncoding.ANSI.GetString(Data)));
    if not (Compressed = -1) then
      JSON.AddPair(TJSONPair.Create('compressed', TJSONNumber.Create(Compressed)));
    if not (CRC = 0) then
      JSON.AddPair(TJSONPair.Create('crc', TJSONNumber.Create(CRC)));
    if not (Len = 0) then
      JSON.AddPair(TJSONPair.Create('length', TJSONNumber.Create(Len)));
    Result := JSON.ToString;
  finally
    JSON.Free;
  end;
end;

function TTLGSession.SendBuzz(Cnt: TRnQContact): Boolean;
begin
  Result := False;
end;

procedure TTLGSession.SendContacts(Cnt: TRnQContact; flags: DWord; cl: TRnQCList);
var
  s: RawByteString;
  c: TRnQContact;
begin
  if not IsReady then exit;
  if cl.empty then exit;

  //c:=GeTTLGContact(uin));
  if not imVisibleTo(Cnt) then
    if addTempVisMsg then
     addTemporaryVisible(TTLGContact(Cnt));

  s := IntToStr(TList(cl).count)+#$FE;
  for c in cl do
    s := s + UTF(c.UID2cmp) +#$FE + UTF(c.nick) + #$FE;
end; // SendContacts

procedure TTLGSession.SendQueryInfo(const uid: TUID);
var
//  wpS: TWpSearch;
  c: TTLGContact;
begin
  if not IsReady then
    Exit;

  c := GeTTLGContact(uid);
  if not Assigned(c) then
    Exit;
OutputDebugString(PChar('SendQueryInfo'));
  GetProfile(c);
// TODO: White pages search... or just leave GetProfile()
//  wpS.uin := uid;
//  wpS.token := cnt.InfoToken;
//  SendWPSearch2(wpS, 0, False);
end; // sendQueryInfo

{procedure TTLGSession.sendQueryInfo(uin:TUID);
var
  wp : TwpSearch;
begin
  wp.uin := uin;
  sendWPsearch(wp, 0);
end; // sendQueryInfo}


procedure TTLGSession.GetProfile(const cnt: TTLGContact);
var
  j: TJSONObject;
  Query: UTF8String;
  BaseURL: String;
  user, groups: TJSONValue;
//  users: TJSONArray;
begin
  if not IsReady or (cnt = NIL) then
    Exit;

  j := TJSONObject.Create;
  j.AddPair('@type', 'getUserFullInfo');
  j.AddPair('user_id', cnt.TLG_ID);
  td_send(j);
  J.Free;
end;

procedure TTLGSession.GetContactAttrs(const UID: TUID);
var
  c: TTLGContact;
  JSON: TJSONObject;
  Query: UTF8String;
  BaseURL: String;
begin
{
  BaseURL := WIM_HOST + 'buddylist/getBuddyAttribute';
  Query := '&buddy=' + ParamEncode(String(UID));
  if SendSessionRequest(False, BaseURL, Query, RT_JSON, JSON, 'Get contact [' + String(UID) + '] attributes') then
  try
    c := geTTLGContact(UID);
    if Assigned(c) then
    with JSON do
    begin
      GetValueSafe('note', c.ssImportant);
      GetValueSafe('smsNumber', c.ssCell);
      GetValueSafe('workNumber', c.ssCell2);
      GetValueSafe('phoneNumber', c.ssCell3);
      GetValueSafe('otherNumber', c.ssCell4);
      GetValueSafe('friendly', c.ssNickname)
    end;
  finally
    JSON.Free;
  end;
}
end;

procedure TTLGSession.SendContactAttrs(c: TTLGContact);
var
  Query: UTF8String;
  BaseURL: String;
  Params: TDictionary<String, String>;
begin
{
  Params := TDictionary<String, String>.Create();
  BaseURL := WIM_HOST + 'buddylist/setBuddyAttribute';
  Params.Clear;
  Params.Add('buddy', String(c.UID2Cmp));
  if not IsMyAcc(c) then // Returns error for own contact
    Params.Add('friendly', c.ssNickname);
  Params.Add('note', c.ssImportant); // Not working, value stays unchanged on server
  Params.Add('smsNumber', c.ssCell);
  Params.Add('workNumber', c.ssCell2);
  Params.Add('phoneNumber', c.ssCell3);
  Params.Add('otherNumber', c.ssCell4);
  SendSessionRequest(True, BaseURL, '&' + MakeParams('POST', BaseURL, Params, False), 'Save my contact attributes', 'Failed to save your contact attributes');
  Params.Free;
}
end;

procedure TTLGSession.GetContactInfo(const uid: TUID; const IncludeField: String);
var
  JSON: TJSONObject;
  Query: UTF8String;
  BaseURL: String;
  user: TJSONValue;
  users: TJSONArray;
begin
  if not IsReady or (IncludeField = '') then
    Exit;
{
  BaseURL := WIM_HOST + 'presence/get';
  Query := '&mdir=0&t=' + ParamEncode(String(UID)) +
           '&' + IncludeField + '=1'; // No profile, but still some other fields are there
  if SendSessionRequest(False, BaseURL, Query, RT_JSON, JSON, 'Get contact [' + String(UID) + '] info [' + IncludeField + ']') then
  try
    ProcessUsersAndGroups(JSON);
  finally
    JSON.Free;
  end;
}
end;

procedure TTLGSession.GetCL;
var
  J: TJSONObject;
begin
  if not IsReady then
    Exit;

  j := TJSONObject.Create;
  j.AddPair('@type', 'getContacts');
  j.AddPair('@extra', IntToStr(incReqId));
  td_send(j);
  j.Free;
end;

procedure TTLGSession.FindContact;
var
//  JSON: TJSONObject;
  Query: UTF8String;
  BaseURL: String;
begin
  if not IsReady then
    Exit;
{
  BaseURL := WIM_HOST + 'presence/get';
  Query := '&mdir=1';
  if SendSessionRequest(False, BaseURL, Query, 'Find contact') then
{
  try
    ProcessUsersAndGroups(JSON);
  finally
    JSON.Free;
  end;
}
end;

procedure TTLGSession.ValidateSid;
var
  Query: UTF8String;
  BaseURL: String;
begin
  if not IsReady then
    Exit;
{
  BaseURL := WIM_HOST + 'aim/validateSid';
  SendSessionRequest(False, BaseURL, '', 'Validate AimSid');
}
end;

procedure TTLGSession.GetExpressions(const uid: TUID); // Avatars only?
var
  Query: UTF8String;
  BaseURL: String;
begin
{
  BaseURL := WIM_HOST + 'expressions/get2'; // expressions/get
  Query := 'f=json' +
           '&t=' + ParamEncode(String(uid));
  SendRequest(False, BaseURL, Query, 'Get expressions');
}
end;

procedure TTLGSession.GetAllCaps;
var
  JSON: TJSONObject;
  Query: UTF8String;
  BaseURL: String;
  Cnt: TRnQContact;
  user: TJSONValue;
  users: TJSONArray;
begin
  if not IsReady then
    Exit;
{
  BaseURL := WIM_HOST + 'presence/get';
  Query := '&capabilities=1';
  if fRoster.Count > 0 then
    for Cnt in fRoster do
      if not (TTLGContact(cnt).Status in [SC_OFFLINE, SC_UNK]) then
        Query := Query + '&t=' + String(Cnt.UID2cmp);
  if SendSessionRequest(True, BaseURL, Query, RT_JSON, JSON, 'Get caps for all online contacts') then
  try
    ProcessUsersAndGroups(JSON);
  finally
    JSON.Free;
  end;
}
end;

procedure TTLGSession.Test;
var
  Query: UTF8String;
  BaseURL: String;
//  Params: TDictionary<String, String>;
begin
{
  BaseURL := WIM_HOST + 'aim/getSMSInfo';
  Query := '&phone=911';
  SendSessionRequest(True, BaseURL, Query, 'Test');
}
//  Params := TDictionary<String, String>.Create();
//  Params.Add('f', 'json');
//  Params.Add('k', fDevId);
//  Params.Add('a', fAuthToken);
//  Params.Add('ts', IntToStr(DateTimeToUnix(Now, False) - fHostOffset));
//  SendSessionRequest(False, BaseURL, MakeParams('GET', BaseURL, Params), 'Test', '');
//  Params.Free;
end;

function CheckSimpleData(var JSON: TJSONObject; StatusOnly: Boolean = False): Boolean;
var
  Tmp: TJSONValue;
begin
  Result := True;
  Tmp := JSON.GetValue('status');
  if not Assigned(Tmp) or not (Tmp is TJSONNumber) or not (TJSONNumber(Tmp).AsInt = 200) then
    Exit(False);
  if not StatusOnly then
  begin
    Tmp := JSON.GetValue('data');
    if not Assigned(Tmp) or not (Tmp is TJSONObject) then
      Exit(False);
    JSON := TJSONObject(Tmp);
  end;
end;

procedure TTLGSession.GetStoreStickerPacks;
var
  BaseURL: String;
  Params: TDictionary<String, String>;
  Handler: THandlerProc;
begin
  if RequiresLogin then
    Exit;
{
  BaseURL := STORE_HOST + 'openstore/contentlist';
  Params := TDictionary<String, String>.Create();
  Params.Add('r', CreateNewGUID);
//  Params.Add('platform', 'windows');
  Params.Add('client', 'icq');
//  Params.Add('lang', IfThen(IsRuLang, 'ru-ru', 'en-us'));
  Params.Add('lang', 'en-us');

  Handler := procedure(RespStrR: RawByteString)
  var
    Tmp: TJSONValue;
    JSON: TJSONObject;
    Sticker: TJSONValue;
    Stickers: TJSONArray;
    SRecord: TStickerPack;
  begin
    if ParseJSON(UTF8String(RespStrR), JSON) then
    try
      if not CheckSimpleData(JSON, True) then
        Exit;
      Tmp := JSON.GetValue('stickers');
      if not Assigned(Tmp) or not (Tmp is TJSONObject) then
        Exit;
      Tmp := TJSONObject(Tmp).GetValue('sets');
      if not Assigned(Tmp) or not (Tmp is TJSONArray) then
        Exit;

      ClearStickerPacks;
      Stickers := TJSONArray(Tmp);
      for Sticker in Stickers do
      if Assigned(Sticker) then
      begin
        SRecord := TStickerPack.fromJSON(TJSONObject(Sticker));

        // Skip duplicates
        if DupStickerPacks.Contains(SRecord.Id) then
          Continue;

        // Skip disabled, but not the hidden ones
        if not SRecord.IsEnabled and not HiddenStickerPacks.Contains(SRecord.Id) then
          Continue;

        AddStickerPack(SRecord);
      end;
    finally
      FreeAndNil(JSON);
    end;
    NotifyListeners(IE_stickersupdate);
  end;

  SendRequestAsync(False, BaseURL, MakeParams('GET', BaseURL, Params), 'Get store sticker packs', Handler);

  Params.Free;
}
end;

procedure TTLGSession.SearchStoreStickerPacks(const Query: String);
var
  BaseURL: String;
  Params: TDictionary<String, String>;
  Handler: THandlerProc;
begin
  if RequiresLogin then
    Exit;
{
  BaseURL := STORE_HOST + 'store/showcase';
  Params := TDictionary<String, String>.Create();
  Params.Add('r', CreateNewGUID);
  Params.Add('platform', 'windows');
  Params.Add('client', 'icq');
//  Params.Add('lang', IfThen(IsRuLang, 'ru-ru', 'en-us'));
  Params.Add('lang', IfThen(false, 'ru-ru', 'en-us'));
  Params.Add('search', Trim(Query));

  Handler := procedure(RespStrR: RawByteString)
  var
    Tmp: TJSONValue;
    JSON: TJSONObject;
    Res: TJSONValue;
    Ress: TJSONArray;
    SRecord: TStickerPack;
  begin
    SetLength(LastSearchPacks, 0);
    if ParseJSON(UTF8String(RespStrR), JSON) then
    try
      if not CheckSimpleData(JSON) then
        Exit;
      Tmp := JSON.GetValue('top');
      if not Assigned(Tmp) or not (Tmp is TJSONArray) then
        Exit;

      Ress := TJSONArray(Tmp);
      for Res in Ress do
      if Assigned(Res) then
      begin
        SRecord := TStickerPack.fromJSON(TJSONObject(Res));
        SetLength(LastSearchPacks, Length(LastSearchPacks) + 1);
        LastSearchPacks[Length(LastSearchPacks) - 1] := SRecord;
      end;
    finally
      FreeAndNil(JSON);
    end;
    NotifyListeners(IE_stickersearchupdate);
  end;

  SendRequestAsync(False, BaseURL, MakeParams('GET', BaseURL, Params), 'Search store sticker packs', Handler);

  Params.Free;
}
end;
{
function TTLGSession.GetStoreStickerPack(const PackId: String): TStickerPack;
var
  Tmp: TJSONValue;
  JSON: TJSONObject;
  BaseURL: String;
  Params: TDictionary<String, String>;
  Handler: THandlerProc;
begin
  Result := Default(TStickerPack);
  if RequiresLogin or (PackId = '') then
    Exit;

  BaseURL := STORE_HOST + 'openstore/packinfo';
  Params := TDictionary<String, String>.Create();
  Params.Add('a', fSession.Token);
  Params.Add('f', 'json');
  Params.Add('k', fSession.DevId);
  Params.Add('ts', IntToStr(DateTimeToUnix(Now, False) - fSession.HostOffset));
  Params.Add('r', CreateNewGUID);
  Params.Add('platform', 'windows');
  Params.Add('client', 'icq');
//  Params.Add('lang', IfThen(IsRuLang, 'ru-ru', 'en-us'));
  Params.Add('lang', IfThen(False, 'ru-ru', 'en-us'));
  Params.Add('id', PackId);

  SendRequest(False, BaseURL, MakeParams('GET', BaseURL, Params), RT_JSON, JSON, 'Get sticker pack store id');
  if Assigned(JSON) then
  try
    if CheckSimpleData(JSON) then
      Result := TStickerPack.fromJSON(JSON);
  finally
    FreeAndNil(JSON);
  end;
  Params.Free;
end;

procedure TTLGSession.BuyStickerPack(const PackId: String);
var
  SRecord: TStickerPack;
  BaseURL: String;
  Params: TDictionary<String, String>;
  Handler: THandlerProc;
  PID: Integer;
begin
  // Packs that cannot be purchased
  if TryStrToInt(PackId, PID) then
  if HiddenStickerPacks.Contains(PID) then
  begin
    ChangeStickerPackStatus(PackId, True);
    NotifyListeners(IE_stickersupdate);
    Exit;
  end;

  SRecord := GetStoreStickerPack(PackId);
  if SRecord.StoreId = '' then
    MsgDlg(GetTranslation(ICQError2Str[EC_StoreProblem], [GetTranslation('Unable to get sticker pack store id')]), False, mtError);

  if RequiresLogin or (PackId = '') or (SRecord.StoreId = '') then
    Exit;

  BaseURL := STORE_HOST + 'store/buy/free';
  Params := TDictionary<String, String>.Create();
  Params.Add('a', fSession.Token);
  Params.Add('f', 'json');
  Params.Add('k', fSession.DevId);
  Params.Add('ts', IntToStr(DateTimeToUnix(Now, False) - fSession.HostOffset));
  Params.Add('r', CreateNewGUID);
  Params.Add('platform', 'windows');
  Params.Add('client', 'icq');
//  Params.Add('lang', IfThen(IsRuLang, 'ru-ru', 'en-us'));
  Params.Add('lang', IfThen(False, 'ru-ru', 'en-us'));
  Params.Add('product', SRecord.StoreId);

  Handler := procedure(RespStrR: RawByteString)
  var
    Tmp: TJSONValue;
    JSON: TJSONObject;
    Verified: Boolean;
  begin
    if ParseJSON(UTF8String(RespStrR), JSON) then
    try
      if not CheckSimpleData(JSON) then
        Exit;

      JSON.GetValueSafe('is_verified', Verified);

      if Verified then
      begin
        AddStickerPack(SRecord);
        ChangeStickerPackStatus(PackId, True);
        NotifyListeners(IE_stickersupdate);
      end
        else
      begin
        eventError := EC_StoreProblem;
        eventMsgA := GetTranslation('Purchase data failed the verification');
        NotifyListeners(IE_error);
      end;
    finally
      FreeAndNil(JSON);
    end;
  end;

  SendRequestAsync(True, BaseURL + '?' + MakeParams('GET', BaseURL, Params), 'product=' + SRecord.StoreId, 'Buy free sticker pack', Handler);
  Params.Free;
end;

procedure TTLGSession.RemoveStickerPack(const PackId: String);
var
  BaseURL: String;
  Params: TDictionary<String, String>;
  Handler: THandlerProc;
  PID: Integer;
begin
  // Packs that cannot be purchased
  if TryStrToInt(PackId, PID) then
  if HiddenStickerPacks.Contains(PID) then
  begin
    ChangeStickerPackStatus(PackId, False);
    RemoveStickerPackCache(PackId);
    NotifyListeners(IE_stickersupdate);
    Exit;
  end;

  if RequiresLogin or (PackId = '') then
    Exit;

  BaseURL := STORE_HOST + 'store/deletepurchase';
  Params := TDictionary<String, String>.Create();
  Params.Add('a', fSession.Token);
  Params.Add('f', 'json');
  Params.Add('k', fSession.DevId);
  Params.Add('ts', IntToStr(DateTimeToUnix(Now, False) - fSession.HostOffset));
  Params.Add('r', CreateNewGUID);
  Params.Add('platform', 'windows');
  Params.Add('client', 'icq');
//  Params.Add('lang', IfThen(IsRuLang, 'ru-ru', 'en-us'));
  Params.Add('lang', IfThen(False, 'ru-ru', 'en-us'));
//  Params.Add('product_id', 'ai_s1');

  Handler := procedure(RespStrR: RawByteString)
  var
    Tmp: TJSONValue;
    JSON: TJSONObject;
    Status: String;
  begin
    if ParseJSON(UTF8String(RespStrR), JSON) then
    try
      if not CheckSimpleData(JSON, True) then
        Exit;

      JSON.GetValueSafe('description', Status);

      if Status = 'OK' then
      begin
        ChangeStickerPackStatus(PackId, False);
        RemoveStickerPackCache(PackId);
        NotifyListeners(IE_stickersupdate);
      end
        else
      begin
        eventError := EC_StoreProblem;
        eventMsgA := GetTranslation('Cannot remove sticker pack: %s', [Status]);
        NotifyListeners(IE_error);
      end;
    finally
      FreeAndNil(JSON);
    end;
  end;

  SendRequestAsync(True, BaseURL + '?' + MakeParams('GET', BaseURL, Params), 'product_id=' + PackId, 'Remove sticker pack', Handler);
  Params.Free;
end;
 }
procedure TTLGSession.SendSMS(const Dest, Msg: String; Ack: Boolean);
begin
  if not IsReady then
     Exit;

  // TODO?
end; // sendSMS

procedure TTLGSession.SendSaveMyInfo(c: TTLGContact);
var
  BaseURL: String;
  Params: TDictionary<String, String>;
begin
(*
  if c.birth > 0 then
    c.age := YearsBetween(Now, c.birth);
  SavingMyInfo.ACKcount := 3;

  BaseURL := WIM_HOST + 'memberDir/update';

  Params := TDictionary<String, String>.Create();
  Params.Add('set=firstName', c.First);
  Params.Add('set=lastName', c.Last);
//  Params.Add('set=nick', c.Nick);
  Params.Add('set=friendlyName', c.Nick);
//  Params.Add('set=relationshipStatus', SrvMarStsByID(c.MarStatus));
  Params.Add('set=birthDate', IntToStr(DateTimeToUnix(c.Birth)));
  Params.Add('set=gender', IfThen(c.Gender = 2, 'male', IfThen(c.Gender = 1, 'female', 'unknown')));
  Params.Add('set=lang1', c.Lang[1]);
  Params.Add('set=lang2', c.Lang[2]);
  Params.Add('set=lang3', c.Lang[3]);
  Params.Add('set=tz', '99'{Result.GMThalfs});
  Params.Add('set=aboutMe', c.About);
//  Params.Add('set=originAddress', '{city=' + ParamEncode(c.BirthCity) + ',state=' + ParamEncode(c.BirthState) + ',' +
//                                   'country=' + ParamEncode(c.BirthCountry) + '}');
//  Params.Add('set=homeAddress', '{street=' + ParamEncode(c.Address) + ',city=' + ParamEncode(c.City) + ',' +
//                                 'state=' + ParamEncode(c.State) + ',zip=' + ParamEncode(c.ZIP) + ',' +
//                                 'country=' + ParamEncode(c.Country) + '}');
  Params.Add('set=homeAddress', '{city=' + ParamEncode(c.City) + ',state=' + ParamEncode(c.State) + ',' +
                                 'country=' + ParamEncode(c.Country) + '}');
//  Params.Add('set=phones', '[{type=home,phone=666h} {type=work,phone=666w} {type=mobile,phone=666m} {type=homeFax,phone=666hf} {type=workFax,phone=666wf} {type=other,phone=666o}]');
//  Params.Add('set=jobs', '[{title=1,company=2,website=3,department=4,industry=arts,subIndustry=music,startDate=444,endDate=666,street=5,city=6,state=7,zip=8,country=' + ParamEncode(c.Country) + '}]');
//  Params.Add('set=interests', '[{code=art,text=test}]');

  if SendSessionRequest(True, BaseURL, '&' + MakeParams('POST', BaseURL, Params, False, True), 'Save my info', 'Failed to save your information') then
    NotifyListeners(IE_MyInfoAck);

  Params.Free;
*)
end;

procedure TTLGSession.notificationForMsg(msgType: Byte; flags: Byte; urgent: Boolean; const msg: RawByteString{; offline:boolean = false});
var
  mm: RawByteString;
begin
  if msgType in MTYPE_AUTOMSGS then
  begin
    notifyListeners(IE_automsgreq);
    Exit;
  end;
//sefg if msg='' then exit;
//eventFlags:=0;
  if flags and $80 > 0 then inc(eventFlags, IF_multiple);
  if flags and $40 > 0 then inc(eventFlags, IF_no_matter);
  if urgent then inc(eventFlags, IF_urgent);
//if offline then inc(eventFlags, IF_offline);
  case msgtype of
    MTYPE_PLAIN:
      begin
        eventMsgA := msg;
        eventString := UnUTF(msg);
        notifyListeners(IE_msg);
      end;
    MTYPE_URL:
      begin
        mm := msg;
        eventMsgA := chop(#$FE, RawByteString(mm));
        eventAddress := mm;
        notifyListeners(IE_url);
      end;
    MTYPE_CONTACTS:
      begin
//        parseContactsString(msg);
        notifyListeners(IE_contacts);
      end;
    MTYPE_ADDED:
      begin
//        parseAuthString(msg);
        notifyListeners(IE_addedYou);
      end;
    MTYPE_AUTHREQ:
      begin
//        parseAuthString(msg);
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
    MTYPE_CHAT:
      begin
        eventMsgA := msg;
        notifyListeners(IE_MultiChat);
      end;
  end;
end; // notificationForMsg



function parseTzerTag(sA: RawByteString): RawByteString;
var
  p: Integer;
  imgStr: RawByteString;
  ext: RawByteString;
begin
  p := PosEx('name="', sA);
  Result := getTranslation('tZer') + ': ' + copy(sA, p + 6, PosEx('"', sA, p + 7) - p - 6) + #13#10;
  p := PosEx('url="', sA);
  Result := Result + copy(sA, p + 5, PosEx('"', sA, p + 6) - p - 5) + #13#10;
  p := PosEx('thumb="', sA);
  ext := copy(sA, p + 7, PosEx('"', sA, p + 8) - p - 7);

  try
    imgStr := '';
    LoadFromURLAsString(ext, imgStr);

    if Trim(imgStr) = '' then
      imgStr := ext
    else
      imgStr := RnQImageExTag + Base64EncodeString(imgStr) + RnQImageExUnTag;
  except
    imgStr := ext;
  end;
  Result := Result + imgStr + #13#10;
end;

procedure TTLGSession.parsePagerString(s: RawByteString);
begin
  eventNameA := chop(#$FE, s);
  chop(#$FE, s);
  chop(#$FE, s);
  eventAddress := UnUTF(chop(#$FE, s));
  chop(#$FE, s);
  eventMsgA := s;
end; // parsePagerString




procedure TTLGSession.OnProxyError(Sender: TObject; Error: Integer; const Msg: String);
begin
// if not isAva then

 if error <> 0 then
  begin
    GoneOffline;
//    eventInt := WSocket_WSAGetLastError;
//    if eventInt=0 then
     eventInt := error;
    eventMsgA := msg;
    eventError := EC_cantconnect;
    notifyListeners(IE_error);
//  exit;
  end;
end;


function TTLGSession.GetMyCaps: RawByteString;
var
  s: RawByteString;
begin
  Result := '';

  if UseCryptMsg then
  begin
    if fECCKeys.Generated then
    begin
      SetLength(s, 11);
      CopyMemory(@s[1], @fECCKeys.pubEccKey[0], Length(s));
      Result := Result + ',' + Str2Hex('RDEC0' + s);
      CopyMemory(@s[1], @fECCKeys.pubEccKey[11], Length(s));
      Result := Result + ',' + Str2Hex('RDEC1' + s);
      CopyMemory(@s[1], @fECCKeys.pubEccKey[22], Length(s));
      Result := Result + ',' + Str2Hex('RDEC2' + s);
    end;

  end;

//  if (curXStatus > 0) and not (XStatusArray[curXStatus].pidOld = '') then
//    Result := Result + ',' + Str2Hex(XStatusArray[curXStatus].pidOld);

  if AddExtCliCaps and (Length(ExtClientCaps) = 16) then
    Result := Result + ',' + Str2Hex(ExtClientCaps);
end;

function TTLGSession.RemoveContact(c: TRnQContact): Boolean;
var
  IsLocal: Boolean;
begin
  IsLocal := c.CntIsLocal or (c.groupId = 0);
  Result := NotInList.remove(c);
  Result := fRoster.remove(c) or Result;
  if Result then
  begin
    RemoveFromVisible(TTLGContact(c));
    if not IsLocal and IsReady then
      SendRemoveContact(TTLGContact(c));
    TTLGContact(c).status := SC_UNK;
    c.SSIID := 0;
    eventInt := TList(fRoster).Count;
    notifyListeners(IE_numOfContactsChanged);
  end
end;

procedure TTLGSession.RemoveContactFromServer(c: TTLGContact);
begin
  if IsReady then
    SendRemoveContact(c);
  eventContact := c;
  notifyListeners(IE_contactupdate);
end;
{
procedure TTLGSession.SetStatus(s:TTLGStatus; vis: Tvisibility);
begin
  if s = SC_OFFLINE then
   begin
    disconnect;
    exit;
   end;

  if (s = curStatus) and (vis = visibility) then exit;
  eventOldStatus := curStatus;
  eventOldInvisible := IsInvisible;
  StartingStatus:=s;
  StartingVisibility := vis;
  if IsReady then
    begin
      if (vis in [VI_invisible, VI_privacy]) <> IsInvisible then
        clearTemporaryVisible;
      curStatus := s;
      visibility := vis;
      sendStatusCode(False);
      eventContact:= NIL;
      notifyListeners(IE_statuschanged);
    end
   else
    connect;
end; // setStatus
}
procedure TTLGSession.SetStatus(st: Byte);
var
  savedSt: TTLGStatus;
begin
  if st = Byte(SC_OFFLINE) then
  begin
    Disconnect;
    Exit;
  end;

//  if (st = Byte(CurStatus)) and (vi = Byte(Visibility)) then
  if st = Byte(CurStatus) then
    Exit;

  if not (st = Byte(CurStatus)) then
  begin
    savedSt := CurStatus;
    StartingStatus := TTLGStatus(st);
  end;
{
  if not (vi = Byte(Visibility)) then
  begin
    eventOldInvisible := IsInvisible;
    StartingVisibility := TVisibility(vi);
  end;
}
  if IsReady then
  begin
    CurStatus := TTLGStatus(st);
//    Visibility := TVisibility(vi);
    if SendPresenceState then
    begin
      eventContact := nil;
      eventOldStatus := savedSt;
      if not (eventOldStatus = CurStatus) then
        notifyListeners(IE_statuschanged);
      if not (eventOldInvisible = IsInvisible) then
        notifyListeners(IE_visibilityChanged);
    end; // else restore status and vis?
//    SendStatusStr(CurXStatus, ExtStsStrings[CurXStatus].Desc);
  end else
    Connect;
end; // SetStatus

procedure TTLGSession.SetStatus(st: Byte; vi: Byte);
begin
  if st = Byte(SC_OFFLINE) then
  begin
    Disconnect;
    Exit;
  end;

  if vi > Byte(High(TVisibility)) then
    vi := 0;

  if (st = Byte(CurStatus)) and (vi = Byte(Visibility)) then
    Exit;

  if not (st = Byte(CurStatus)) then
  begin
    eventOldStatus := CurStatus;
    StartingStatus := TTLGStatus(st);
  end;

  if not (vi = Byte(Visibility)) then
  begin
    eventOldInvisible := IsInvisible;
    StartingVisibility := TVisibility(vi);
  end;

  if IsReady then
  begin
    CurStatus := TTLGStatus(st);
    Visibility := TVisibility(vi);
    if SendPresenceState then
    begin
      eventContact := nil;
      if not (eventOldStatus = CurStatus) then
        notifyListeners(IE_statuschanged);
      if not (eventOldInvisible = IsInvisible) then
        notifyListeners(IE_visibilityChanged);
    end; // else restore status and vis?
//    SendStatusStr(CurXStatus, ExtStsStrings[CurXStatus].Desc);
  end else
    Connect;
end;

function TTLGSession.GetStatus: Byte;
begin
  Result:= Byte(CurStatus)
end;

function TTLGSession.GetXStatus: Byte;
begin
  Result := CurXStatus;
end;

function TTLGSession.getStatusName: String;
begin
  if ({XStatusAsMain}False and (curStatus = SC_ONLINE)) and (curXStatus > 0) then
    begin
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

function TTLGSession.getStatusImg: TPicName;
begin
//  if False{XStatusAsMain} and (curXStatus > 0) then
//    Result := XStatusArray[curXStatus].PicName
//   else
    begin
     result := status2imgName(byte(curStatus), isInvisible);
    end;
end;

function TTLGSession.GetVisibility: Byte;
begin
  Result := Byte(fVisibility)
end;

//function TTLGSession.validUid(var uin:TUID):boolean;
(*function TTLGSession.validUid1(const uin:TUID):boolean;
//var
// i : Int64;
// k : Integer;
// fUIN : Int64;
begin
 Result := TTLGSession._isValidUid1(uin);
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

{class function TTLGSession.GetId: Word;
begin
  result := 0;
end;}

class function TTLGSession._GetProtoName: string;
begin
  result := 'TLG';
end;

class function TTLGSession._getDefHost : Thostport;
begin
  Result.host := //'login.icq.com';
                 TLGServers[0];
  Result.Port := 5190;
end;

function TTLGSession.GeTTLGContact(const uid: TUID): TTLGContact;
begin
  Result := TTLGContact(contactsDB.add(Self, uid));
end;

function TTLGSession.GeTTLGContact(const uin: Integer): TTLGContact;
begin
//  result := TTLGContact(contactsDB.get(TTLGContact, uin));
  result := TTLGContact(contactsDB.add(Self, IntToStr(uin)));
end;

class function TTLGSession._IsValidPhone(const Phone: TUID): Boolean;
var
  k: Integer;
  Temp: TUID;
begin
  Result := True;
  Temp := String(Phone).Trim();
  if Length(Temp) = 0 then
    Exit(False);
  if not (Phone[1] = '+') then
    Exit(False);
  for k := 1 to Length(Phone) do
    if not (Phone[k] in ['0'..'9','+']) then
      Result := False;
  Result := Result and (length(Phone) = 12);
  
end;

class function TTLGSession._isProtoUid(var uin: TUID): boolean; //Static;
//function TTLGSession.isValidUid(var uin:TUID):boolean; //Static;
var
// i: Int64;
 k: Integer;
 fUIN: Int64;
 temp: TUID;
begin
  Result := False;
  temp := TTLGContact.trimUID(uin);
//  temp := trim(uin);
  if Length(Temp) = 0 then
    Exit;
  if temp[1] = '+' then
    Exit(_IsValidPhone(temp))
   else
    Exit(_IsValidPhone('+' + temp))
    ;

end;

//class function isValidUid(var uin: TUID): boolean; override;
class function TTLGSession._isValidUid1(const uin: TUID): boolean; //Static;
//function TTLGSession.isValidUid(var uin: TUID): boolean; //Static;
var
// i: Int64;
 k: Integer;
 fUIN: Int64;
 temp: TUID;
begin
  Result := False;
  temp := TTLGContact.trimUID(uin);
  if Length(temp) = 0 then
    Exit;
    ;
  if temp[1] = '+' then
    Exit(_IsValidPhone(temp))
   else
    Exit(_IsValidPhone('+' + temp))
    ;
end;

procedure TTLGSession.AddContactToCL(var c: TTLGContact);
begin
  if not Assigned(c) then
    Exit;
  if c.isInRoster then
    Exit;
//  if IsReady then
//    c.status := SC_OFFLINE
//  else
//    c.status := SC_UNK;
  fRoster.add(c);
  eventInt := TList(fRoster).count;
  notifyListeners(IE_numOfContactsChanged);
end; // AddContacts

procedure TTLGSession.AddContactsToCL(cl: TRnQCList);
begin
  if cl = nil then
    Exit;
  if TList(cl).count = 0 then
    Exit;
  cl := cl.clone.remove(fRoster);
  if IsReady then
    ICQCL_SetStatus(cl, SC_OFFLINE)
  else
    ICQCL_SetStatus(cl, SC_UNK);
  fRoster.add(cl);
  eventInt := TList(fRoster).count;
  notifyListeners(IE_numOfContactsChanged);
  cl.Free;
end; // AddContacts

function TTLGSession.AddContact(c: TRnQContact; IsLocal: Boolean = False): boolean;
begin
  Result := False;
  if (c = nil) or (c.UID2cmp = '') then
    Exit;
  Result := fRoster.add(c);
  Result := Result or (not IsLocal and c.CntIsLocal);

  if Result then
  begin
    if IsReady then
    begin
      if TTLGContact(c).Status = SC_UNK then
        TTLGContact(c).Status := SC_OFFLINE;
      TTLGContact(c).InvisibleState := 0;
      if not isLocal then
      begin
        if c.isInRoster then
        begin
          c.SSIID := 0;
          SendAddContact(TTLGContact(c))
        end else
          c.CntIsLocal := True;
      end;
    end;
    eventInt := TList(fRoster).Count;
    notifyListeners(IE_numOfContactsChanged);
  end else
    //SSI_UpdateGroup(TTLGContact(c));
end; // AddContact

function TTLGSession.ReadList(l: TLIST_TYPES): TRnQCList;
begin
  case l of
    LT_ROSTER:    result := fRoster;
    LT_VISIBLE:   result := fVisibleList;
    LT_INVISIBLE: result := fInvisibleList;
    LT_TEMPVIS:   result := tempvisibleList;
    LT_SPAM:      result := spamList;
   else
    Result := NIL;
  end;
end;

procedure TTLGSession.AddToList(l: TLIST_TYPES; cl: TRnQCList);
begin
  case l of
    LT_ROSTER:    AddContactsToCL(cl);
    LT_VISIBLE:   add2visible(cl);
    LT_INVISIBLE: add2invisible(cl);
    LT_TEMPVIS:   addTemporaryVisible(cl);
//   LT_SPAM:      ;
//  else
//   Result := NIL;
 end;
end;

procedure TTLGSession.RemFromList(l: TLIST_TYPES; cl: TRnQCList);
begin
 case l of
//   LT_ROSTER:   //removeContact( addContact(cl);
   LT_VISIBLE:   removeFromVisible(cl);
   LT_INVISIBLE: removeFromInvisible(cl);
   LT_TEMPVIS:   removeTemporaryVisible(cl);
//   LT_SPAM:      result := spamList;
 end;
end;

procedure TTLGSession.AddToList(l: TLIST_TYPES; cnt: TRnQcontact);
begin
 case l of
   LT_ROSTER:   addContact(TTLGContact(cnt));
   LT_VISIBLE:   add2visible(TTLGContact(cnt));
   LT_INVISIBLE: add2invisible(TTLGContact(cnt));
   LT_TEMPVIS:   addTemporaryVisible(TTLGContact(cnt));
   LT_SPAM:      add2ignore(TTLGContact(cnt));
 end;
end;
procedure TTLGSession.RemFromList(l: TLIST_TYPES; cnt: TRnQcontact);
begin
 case l of
   LT_ROSTER:   removeContact(TTLGContact(cnt));
   LT_VISIBLE:   removeFromVisible(TTLGContact(cnt));
   LT_INVISIBLE: removeFromInvisible(TTLGContact(cnt));
   LT_TEMPVIS:   removeTemporaryVisible(TTLGContact(cnt));
   LT_SPAM:      remFromIgnore(TTLGContact(cnt));
 end;
end;

function TTLGSession.isInList(l: TLIST_TYPES; cnt: TRnQContact): Boolean;
begin
 case l of
   LT_ROSTER:    result := fRoster.exists(cnt);
   LT_VISIBLE:   result := fVisibleList.exists(cnt);
   LT_INVISIBLE: result := fInvisibleList.exists(cnt);
   LT_TEMPVIS:   result := tempvisibleList.exists(cnt);
   LT_SPAM:      result := spamList.exists(cnt);
  else
   Result := false;
 end;
end;

function TTLGSession.add2visible(c: TTLGContact): boolean;
begin
  result := FALSE;
  if c=NIL then
    exit;
  tempVisibleList.remove(c);
  result := not fVisibleList.exists(c);
  if result then
  begin
    removeFromInvisible(c);
    if IsReady then
    begin
       //SSI_AddVisItem(c.UID, FEEDBAG_CLASS_ID_PERMIT);
      eventContact := c;
      notifyListeners(IE_visibilityChanged);
    end;
  end;
end; // add2visible

procedure TTLGSession.add2visible(cl: TRnQCList; OnlyLocal: Boolean = false);
begin
  if cl=NIL then
    exit;
  if TList(cl).count = 0 then
    exit;
  tempVisibleList.remove(cl);
  cl := cl.clone.remove(fVisibleList);
  if IsReady then
  begin
    fVisibleList.add(cl);
    //sendAddVisible(cl);
    eventContact := NIL;
    notifyListeners(IE_visibilityChanged);
  end;
  cl.free;
end; // add2visible

function TTLGSession.add2ignore(c: TTLGContact): boolean;
var
  Query: UTF8String;
  BaseURL: String;
begin
  Result := False;
  if IsReady then
  begin
//    BaseURL := WIM_HOST + 'preference/setPermitDeny';
//    Query := '&pdIgnore=' + ParamEncode(String(c.UID2Cmp));
//    Result := SendSessionRequest(False, BaseURL, Query, 'Add to ignore list');
  end;
end;

function TTLGSession.remFromIgnore(c: TTLGContact): boolean;
var
  Query: UTF8String;
  BaseURL: String;
begin
  Result := False;
  if IsReady then
  begin
//    BaseURL := WIM_HOST + 'preference/setPermitDeny';
//    Query := '&pdIgnoreRemove=' + ParamEncode(String(c.UID2Cmp));
//    Result := SendSessionRequest(False, BaseURL, Query, 'Remove from ignore list');
  end;
end;

procedure TTLGSession.GetPermitDeny;
var
  JSON: TJSONObject;
  Query: UTF8String;
  BaseURL: String;
begin
  if not IsReady then
    Exit;
{
  BaseURL := WIM_HOST + 'preference/getPermitDeny';
  Query := '';
  if SendSessionRequest(False, BaseURL, Query, RT_JSON, JSON, 'Get permit/deny lists') then
  try
    ProcessPermitDeny(JSON);
  finally
    JSON.Free;
  end;
}
end;

procedure TTLGSession.SetPermitDenyMode(const Mode: String);
var
  JSON: TJSONObject;
  Query: UTF8String;
  BaseURL: String;
begin
  if not IsReady then
    Exit;
{
  BaseURL := WIM_HOST + 'preference/setPermitDeny';
  Query := '&pdMode=' + Mode;
  if SendSessionRequest(False, BaseURL, Query, RT_JSON, JSON, 'Set permit/deny mode') then
  try
    //ProcessPermitDeny(JSON);
  finally
    JSON.Free;
  end;
}
end;

procedure TTLGSession.AddToBlock(const c: String); // Unused
var
  Query: UTF8String;
  BaseURL: String;
begin
  if not IsReady then
    Exit;
{
  BaseURL := WIM_HOST + 'preference/setPermitDeny';
  Query := '&pdBlock=' + ParamEncode(c);
  SendSessionRequest(False, BaseURL, Query, 'Add contact to block list');
}
end;

procedure TTLGSession.RemFromBlock(const c: String); // Unused
var
  Query: UTF8String;
  BaseURL: String;
begin
  if IsReady then
  begin
//    BaseURL := WIM_HOST + 'preference/setPermitDeny';
//    Query := '&pdBlockRemove=' + ParamEncode(c);
//    SendSessionRequest(False, BaseURL, Query, 'Remove contact from block list');
  end;
end;

procedure TTLGSession.SetMuted(c: TTLGContact; Mute: Boolean);
var
  Query: UTF8String;
  BaseURL: String;
begin
  if IsReady then
  begin
//    BaseURL := WIM_HOST + 'buddylist/Mute';
//    Query := '&buddy=' + c.UID2Cmp +
//             '&eternal=' + IfThen(Mute, '1', '0');
//    SendSessionRequest(False, BaseURL, Query, '(Un)mute contact');
  end;
end;

function TTLGSession.RemoveFromVisible(c:TTLGContact):boolean;
begin
  Result := False;
  if c = nil then
    exit;
  RemoveTemporaryVisible(c);
  if IsReady then
  begin
    //SSI_DelVisItem(c.UID2cmp, FEEDBAG_CLASS_ID_PERMIT);
    eventCOntact := c;
    notifyListeners(IE_visibilityChanged);
  end;
end; // removeFromVisible

procedure TTLGSession.removeFromVisible(const cl: TRnQCList);
var
  cl1: TRnQCList;
begin
  if cl=NIL then
    exit;
  removeTemporaryVisible(cl);
    begin
      cl1 := cl.clone.intersect(fVisibleList);
      fVisibleList.remove(cl1);
    end;
  if IsReady and not cl1.empty then
   begin
    //sendRemoveVisible(cl1);
    eventContact := NIL;
    notifyListeners(IE_visibilityChanged);
   end;
  cl1.free;
end; // removeFromVisible

function TTLGSession.add2invisible(c: TTLGContact): boolean;
begin
  Result := False;
  if c = nil then
    Exit;
  RemoveTemporaryVisible(c);
  Result := fInvisibleList.add(c);
  if Result then
  begin
    RemoveFromVisible(c);
    if IsReady then
      //SSI_AddVisItem(c.UID, FEEDBAG_CLASS_ID_DENY)
  end;
end; // add2invisible

procedure TTLGSession.add2invisible(cl: TRnQCList; OnlyLocal: Boolean = false);
begin
  if cl=NIL then
    exit;
  if TList(cl).count = 0 then
    exit;
  removeTemporaryVisible(cl);
  cl:= cl.clone.remove(fInvisibleList);
  removeFromVisible(cl);
  if IsReady then
  begin
    fInVisibleList.add(cl);
    //sendAddInvisible(cl);
    eventContact := NIL;
    notifyListeners(IE_visibilityChanged);
  end;
  cl.free;
end; // add2invisible

function TTLGSession.RemoveFromInvisible(c: TTLGContact): boolean;
begin
  Result := False;
  if c = nil then
    Exit;
  RemoveTemporaryVisible(c);
  Result := True;
  if IsReady then
    //SSI_DelVisItem(c.UID, FEEDBAG_CLASS_ID_DENY);
end; // RemoveFromInvisible

procedure TTLGSession.removeFromInvisible(const cl: TRnQCList);
var
  cl1: TRnQCList;
begin
  if cl=NIL then
    exit;
  removeTemporaryVisible(cl);
    begin
      cl1 := cl.clone.intersect(fInvisibleList);
      fInvisibleList.remove(cl1);
    end;
  if IsReady and not cl1.empty then
  begin
    //sendRemoveInvisible(cl1);
    eventContact := NIL;
    notifyListeners(IE_visibilityChanged);
  end;
  cl1.free;
end; // removeFromInvisible

function TTLGSession.AddTemporaryVisible(c: TTLGContact): Boolean;
begin
  result := FALSE;
  if not IsReady then
    exit;
  result := TRUE;
  tempvisibleList.add(c);
  // TODO: Server side
  eventContact := c;
  notifyListeners(IE_visibilityChanged);
end; // AddTemporaryVisible

function TTLGSession.AddTemporaryVisible(cl: TRnQCList): Boolean;
begin
  Result := False;
  if CL = nil then
    Exit;
  if not IsReady then
    Exit;
  Result := True;
  cl := cl.clone.remove(tempvisibleList);
  tempvisibleList.add(cl);
  //SSIsendAddTempVisible(cl.buinlist);
  eventContact := nil;
  notifyListeners(IE_visibilityChanged);
  cl.free;
end; // AddTemporaryVisible

function TTLGSession.RemoveTemporaryVisible(c: TTLGContact): boolean;
begin
  Result := tempvisibleList.remove(c);
  if not Result or not IsReady then
    Exit;
  //SSIsendDelTempVisible(c.buin);
  eventContact := c;
  notifyListeners(IE_visibilityChanged);
end; // RemoveTemporaryVisible

function TTLGSession.RemoveTemporaryVisible(cl: TRnQCList): boolean;
begin
  Result := True;
  cl:= cl.clone.intersect(tempVisibleList);
  if IsReady and not cl.empty then
  begin
    tempvisibleList.remove(cl);
    //SSIsendDelTempVisible(cl.buinlist);
    eventContact := nil;
    notifyListeners(IE_visibilityChanged);
  end;
  cl.free;
end; // RemoveTemporaryVisible

procedure TTLGSession.ClearTemporaryVisible;
begin
  RemoveTemporaryVisible(tempVisibleList)
end;

function TTLGSession.useMsgType2for(c: TTLGContact): boolean;
begin
  Result := (not (c.status in [SC_OFFLINE, SC_UNK])) //and (not c.invisible)
             and (not c.icq2go)
             and (c.protoV > 7)
//             and ((UseCryptMsg and c.Crypt.supportCryptMsg)
//                  or (UseCryptMsg and fECCKeys.generated and UseEccCryptMsg and c.Crypt.supportEcc))

//             and (not ((getClientPicFor(c) = PIC_RNQ) and (getRnQVerFor(c) < 1053)))
//             and ((CAPS_sm_ICQSERVERRELAY in c.capabilitiesSm)
//             or (CAPS_big_CryptMsg in c.capabilitiesBig)or (UseCryptMsg and c.Crypt.supportCryptMsg)
end;

procedure TTLGSession.SendCreateUIN(const AcceptKey: RawByteString);
begin
  // TODO? New proto can do this?
end; // sendCreateUIN

procedure TTLGSession.acceptTOS(const fn, ln: String);
var
  j: TJSONObject;
begin
  j := TJSONObject.Create;
  j.AddPair('@type', 'registerUser');
  j.AddPair('first_name', fn);
  if ln > '' then
    j.AddPair('last_name', ln);
  //send request
//  ReturnStr :=
  td_send(j);
  j.Free;
end;

procedure TTLGSession.acceptTOS(const tosId: String);
var
  v: TJSONObject;
begin
  v := TJSONObject.Create;
  v.AddPair('@type', 'acceptTermsOfService');
  v.AddPair('terms_of_service_id', tosId);
  //send request
//  ReturnStr :=
  td_send(v);
end;

function TTLGSession.UploadAvatar(const fn: TFileName; cnt: TRnQContact = NIL; chat: Boolean = false): Boolean;
var
  Query: RawByteString;
  BaseURL: String;
  buf: RawByteString;
  json: TJSONObject;
  lReqId, iconId: String;
begin
  Result := False;
{
  BaseURL := WIM_HOST + 'expressions/upload';
//  Query := 'f=json&aimsid=' + ParamEncode(fSession.aimsid) + '&r=' + CreateNewGUID;
  Query := Query + '&type=largeBuddyIcon';
           //IfThen(curStatus = SC_AWAY, '&away=Seeya', ''); // Not really useful, only you receive your awayMsg :)
  if cnt <> NIL then
    Query := Query + '&t=' + ParamEncode(cnt.UID2cmp)
   else if (chat) then
    Query := Query + '&livechat=1';

  buf := loadFileA(fn);
  if SendRequest(True, BaseURL + '?' + Query, buf, RT_JSON, json, 'Upload avatar', 'Failed to upload avatar') then
  begin
    CheckResponseData(json, lReqId);
    json.GetValueSafe('id', iconId);
    if iconId <> '' then
      begin
      end;
    Result := True;
  end;
}
end;

function TTLGSession.maxCharsFor(const c: TRnQcontact; isBin: Boolean = false): integer;
begin
{  if not c.isOnline then
//  Result := 450
  Result := 1000
  else}
//  if useMsgType2for(TTLGContact(c)) then
    Result := 7000
//  else
//    Result := 2540
   ;

  with TTLGContact(c) do
  begin
    if not isBin then
      Result := Result div 2;
    if UseCryptMsg and (Crypt.supportCryptMsg or (UseEccCryptMsg and fECCKeys.generated and Crypt.supportEcc)) then
      Result := Result * 3 div 4;
  end;
end; // maxCharsFor

function TTLGSession.imVisibleTo(c: TRnQcontact): boolean;
begin
  Result := (Visibility = VI_normal) or
            ((Visibility = VI_invisible) and fVisibleList.exists(c));
{
  Result := ((Visibility = VI_all) or TempVisibleList.exists(c) or
            ((Visibility = VI_privacy) and (fVisibleList.exists(c))) or
            ((Visibility = VI_normal) and (not fInvisibleList.exists(c))) or
            ((Visibility = VI_CL) and (fRoster.exists(c))));// not c.CntIsLocal))
}
end; // imVisibleTo

function TTLGSession.GetLocalIPStr: String;
begin
//  try
   if compareText(result, 'error') = 0 then result:='';
//  except
//    result:='';
//  end;
end; // getLocalIPstr

function TTLGSession.getLocalIP: integer;
begin
  try
    Result := 0;
  except
    Result := 0;
  end;
end;

function TTLGSession.CreateNewGUID: String;
//var
//  UID: TGUID;
begin
//  CreateGuid(UID);
  Result := String(CreateGUID).Trim(['{', '}']).ToLower;
end;

procedure TTLGSession.SetWebAware(value: boolean);
begin
  P_webaware := value;
end; // setWebaware

procedure TTLGSession.SetAuthNeeded(value: boolean);
begin
  P_authNeeded := value;
end; // setAuthNeeded

function TTLGSession.IsInvisible: Boolean;
begin
   case fVisibility of
    VI_invisible: Result := True;
//    VI_privacy: Result := True;
//    VI_normal,
//    VI_all,
//    VI_CL: myinfo.invisible := False;
    else
      result := false;
   end;
end;

function TTLGSession.dontBotherStatus: boolean;
begin
  result := getStatus in [byte(SC_occupied)]
end;

function TTLGSession.serverPort: word;
begin
  Result := 0;
end;

function TTLGSession.serverStart: word;
begin
  Result := serverPort;
end; // serverStart

function TTLGSession.RequestPasswordIfNeeded(DoConnect: Boolean = True): Boolean;
begin
  Result := False;
  if not IsMobileAccount and RequiresLogin and ((fPwd = '') or (MyAccount = '')) then
  begin
    eventString := IfThen(DoConnect, '', 'pwdonly');
    eventError := EC_missingLogin;
    NotifyListeners(IE_error);
    Result := True;
  end;
end;

procedure TTLGSession.Connect;
begin
  if not IsOffline then
    Exit;

  if RequestPasswordIfNeeded then
    Exit;

  if IsMobileAccount then
    phase := connecting_sms_
   else
    phase := connecting_;
//  eventAddress := TD_test_server_ip;
  eventAddress := TD_prod_server_ip;
  notifyListeners(IE_connecting);
  reqId := 1;

  if StartSession then
    AfterSessionStarted
  else
    GoneOffline;
end; // Connect

procedure TTLGSession.AfterSessionStarted;
begin
  curStatus := StartingStatus;
  if LastStatus = Byte(SC_OFFLINE) then
    SetStatus(Byte(SC_ONLINE), Byte(VI_normal))
  else if not ExitFromAutoaway then
    SetStatus(Byte(LastStatus), Byte(Visibility));
end;

function TTLGSession.MakeParams(const Method: AnsiString; const BaseURL: String; const Params: TDictionary<String, String>; Sign: Boolean = True; DoublePercent: Boolean = False): String;
var
//  hash: String;
  hash: RawByteString;
  encparams: TStringList;
begin
  encparams := TStringList.Create;
  encparams.Sorted := True;
  encparams.StrictDelimiter := True;
  encparams.Delimiter := '&';
  encparams.QuoteChar := #0;

  with Params.GetEnumerator do
  begin
    while MoveNext do
      encparams.Add(Current.Key + '=' + IfThen(Current.Key = 'stickerId', Current.Value, ParamEncode(Current.Value, DoublePercent)));
    Free;
  end;
  Result := encparams.DelimitedText;
  encparams.Free;

  if Sign then
  begin
    hash := RawByteString(method) + RawByteString('&') + ParamEncode(BaseURL) + '&' + ParamEncode(Result);
//    Result := Result + '&sig_sha256=' + ParamEncode(Hash256String(fSession.secretenc64, hash));
  end;
end;

procedure TTLGSession.OpenICQURL(URL: String);
var
  BaseURL: String;
  Params: TDictionary<String, String>;
begin
//  if fSession.token = '' then
  begin
    OpenURL(URL);
    Exit;
  end;

  BaseURL := 'https://www.icq.com/karma_api/karma_client2web_login.php';

end;

function TTLGSession.ClientLogin: Boolean;
var
  JSON: TJSONObject;
  Query: RawByteString;
  BaseURL, TransId, SMSCode: String;
  ErrHandler: TErrorProc;
  lPhone_verified: Boolean;
begin
  Result := False;
  if (MyAccNum = '') or (not IsMobileAccount and (fPwd = '')) then
    Exit;

  if phase = connecting_sms_ then
    phase := login_sms_
   else
    phase := login_;
  notifyListeners(IE_loggin);

  Result := True;
end;

function TTLGSession.StartSession: Boolean;
var
  Query, sR: RawByteString;
  ts: Integer;
  sU: String;
  Hash, BaseURL, UnixTime, AutoCaps: String;
  RespStr: RawByteString;
  Params: TDictionary<String, String>;
  JSON: TJSONObject;
  UsingSaved, Relogin, SeqFailed, ProcResult: Boolean;
  UID: TGUID;
  ErrHandler: TErrorProc;
  val: TJSONValue;
begin
  Result := False;
  ProcResult := False;
  UsingSaved := True;
  SeqFailed := False;
  Relogin := False;

  if RequiresLogin then
  begin
    UsingSaved := False;
    if not ClientLogin then
      Exit;
  end else
    OutputDebugString(PChar('Using saved token & key!'));
{
  if RequiresLogin and not UsingSaved then
  begin
    eventInt := Integer(EAC_Not_Enough_Data);
    eventMsgA := '';
    eventError := EC_other;
    notifyListeners(IE_error);
    Exit;
  end;
}
  if FTDClient = 0 then
  Begin
    eventInt := Integer(EAC_Not_Enough_Data);
    eventMsgA := 'Create a client to start the service';
    eventError := EC_other;
    notifyListeners(IE_error);
    Exit;
  end
  Else
    Begin
      if is_closed = 0 then
        begin
          eventInt := Integer(EAC_Unknown);
          eventMsgA := 'The service is active!';
          eventError := EC_other;
          notifyListeners(IE_error);
          Exit;
        end
      Else
        begin

          is_closed := 0; //Start Service

          TThread.CreateAnonymousThread(
          procedure
          begin
            while is_closed = 0 do
            Begin
              td_receive;
            End
          end).Start;

//          memSend.Lines.Add('Service Started!!!');

        end;
    end;


  // Start session

  if Relogin then
    Exit;

  if SeqFailed then
  begin
    ResetSession;
    Exit;
  end;

  phase := settingup_;
  notifyListeners(IE_connected);

  notifyListeners(IE_almostOnline);

  Result := True;
end;

function TTLGSession.PingSession: Boolean;
var
  JSON: TJSONObject;
  Query: UTF8String;
  BaseURL: String;
  ts: Integer;
begin
  Result := False;
//  BaseURL := WIM_HOST + 'aim/pingSession';
end;

procedure TTLGSession.ResetSession;
begin
end;

procedure TTLGSession.EndSession(EndToken: Boolean = False);
var
  Query: RawByteString;
  BaseURL: String;
begin
{
  BaseURL := WIM_HOST + 'aim/endSession';
  Query := IfThen(EndToken, '&invalidateToken=1');
//  SendSessionRequest(False, BaseURL, Query, 'End current session');
  GoneOffline;

  if EndToken then
    ResetSession;
}
end;


function TTLGSession.td_send(J: TJSONObject): RawByteString;
var
  JsonAnsiStr: RawByteString;
begin
  JsonAnsiStr := StrToUTF8(J.ToJSON);
  LoggaTLGPkt('', WL_sent_json8, JsonAnsiStr);
  td_client_send(FTDClient, PAnsiChar(JsonAnsiStr));
  Result := '';
//  LoggaTLGPkt('', WL_rcvd_text8, JsonAnsiStr);
end;

function TTLGSession.td_receive(): RawByteString;
var
  ReturnStr:  RawByteString;
  JsonAnsiStr: AnsiString;
  I: Integer;
  J, CTInt: Integer;

  JO, JOParam, TLOAuthState,
  TLOEvent, TLOUpdateMessage,
  TLOContent, TLOText, TLOChat,
  TLOUsers, TLOUser: TJSONObject;

  TLAContacts, TLAMessages: TJSONArray;
//  ContactTreeNode, GroupTreeNode : TTreeNode;
  params: TJSONArray;
  eventType: String;
  SMSCode: String;

begin

  {$REGION 'IMPLEMENTATION'}
  ReturnStr := TD_client_receive(FTDClient, WAIT_TIMEOUT);
  if ReturnStr = '' then
    Exit;
  if ReturnStr > '' then
   begin
    eventNameA := '';
    eventMsgA := ReturnStr;
    NotifyListeners(IE_serverSentJ);
//    LoggaTLGPkt('', WL_rcvd_json8, ReturnStr);
   end;

  if not ParseJSON(UTF8String(ReturnStr), TLOEvent) then
    Exit;

//  TLOEvent := TJSONObject(ReturnStr);

  if TLOEvent <> NIl then
  Begin
    eventType := TLOEvent.s('@type');

    if eventType = 'updateOption' then
      begin
        var vn, vv, vt: String;
        var vvj: TJSONValue;
        var vb: Boolean;
        if not TLOEvent.GetValueSafe('name', vn) then
          Exit;
        vvj := TLOEvent.GetValue('value');
        if not Assigned(vvj) then
          tlgOptions.DeletePref(vn)
         else
          begin
           if not vvj.GetValueSafe('@type', vt) then
             Exit;
           if vt = 'optionValueBoolean' then
            begin
             if vvj.getValueSafe('value', vb) then
                tlgOptions.addPrefBool(vn, vb);
            end
           else
            tlgOptions.addPrefStr(vn, vvj.ToString)
          end;
      end;


    {$REGION 'Authorization'}
    //# process authorization states
{
    if eventType = 'ok' then
      begin
        if phase = login_sms_ then
         begin
          phase := online_;
          NotifyListeners(IE_online);
         end;

      end;
}
    if eventType = 'updateAuthorizationState' then
    Begin
      CTInt := 0; //Test....
      TLOAuthState := TLOEvent.O('authorization_state');

      //# if client is closed, we need to destroy it and create new client
      if TLOAuthState.S('@type') = 'authorizationStateClosed' then
      Begin
        is_closed := 1; //Stop Service
        Exit;
      End;

    //  # set TDLib parameters
    //  # you MUST obtain your own api_id and api_hash at https://my.telegram.org
    //  # and use them in the setTdlibParameters call
      if TLOAuthState.S('@type') = 'authorizationStateWaitTdlibParameters' then
      Begin

        JOParam := TJSONObject.Create;
//        JOParam.AddPair('use_test_dc', TJSONFalse);
//        JOParam.AddPair('use_test_dc', TJSONTrue.Create);
        JOParam.AddPair('use_test_dc', TJSONFalse.Create);
        JOParam.AddPair('database_directory', Account.ProtoPath + 'tdlib');
        JOParam.AddPair('files_directory', Account.ProtoPath + 'myfiles');
        JOParam.AddPair('use_file_database', TJSONTrue.Create);
        JOParam.AddPair('use_chat_info_database', TJSONTrue.Create);
        JOParam.AddPair('use_message_database', TJSONTrue.Create);
        JOParam.AddPair('use_secret_chats', TJSONTrue.Create);

        JOParam.AddPair('api_id', TJSONNumber.Create(TD_API_ID));

          JsonAnsiStr := TD_API_HASH;
        JOParam.AddPair('api_hash', JsonAnsiStr);
        JOParam.AddPair('system_language_code', 'en');
        JOParam.AddPair('device_model', 'MegaComputer');
          {$IFDEF WIN32}
        JOParam.AddPair('system_version', 'WIN32');
          {$ENDIF}
          {$IFDEF WIN64}
        JOParam.AddPair('system_version', 'WIN64');
          {$ENDIF}
        JOParam.AddPair('application_version', '0.9.9.' + IntToStr(RnQBuild));
        JOParam.AddPair('enable_storage_optimizer', TJSONTrue.Create);
        JOParam.AddPair('ignore_file_names', TJSONFalse.Create);

        JO := nil;
        JO := TJSONObject.Create;
        JO.AddPair('@type', 'setTdlibParameters');
        JO.AddPair('parameters', JOParam);
        try
          //Send Request
          ReturnStr := td_send(JO);
         finally
          JO.Free;
          JO := NIL;
        end;
      End;

      //# set an encryption key for database to let know TDLib how to open the database
      if TLOAuthState.S('@type') = 'authorizationStateWaitEncryptionKey' then
      Begin

        JO := TJSONObject.Create;
        JO.AddPair('@type', 'checkDatabaseEncryptionKey');
        JO.AddPair('encryption_key', '');

        try
          //Send Request
          ReturnStr := td_send(JO);
         finally
          JO.Free;
          JO := NIL;
        end;
      End;

      //# enter phone number to log in
      if TLOAuthState.S('@type') = 'authorizationStateWaitPhoneNumber' then
      Begin
        //Clear Variable
        JsonAnsiStr:='';

        //Convert String to AnsiString Type
        JsonAnsiStr := MyAccount;

        JO := TJSONObject.Create;
        JO.AddPair('@type', 'setAuthenticationPhoneNumber');
        JO.AddPair('phone_number', MyAccount);

        try
          //Send Request
          ReturnStr := td_send(JO);
         finally
          JO.Free;
          JO := NIL;
        end;
      End;

      //# wait for authorization code
      if TLOAuthState.S('@type') = 'authorizationStateWaitCode' then
      Begin
        //Clear Variable
         // { TODO : get length of code and ask from user }

        if not InputQuery(GetTranslation('Phone login'), GetTranslation('Enter SMS code'), SMSCode) then
        begin
          EndSession();
          Exit;
        end;

        if (Trim(SMSCode) = '') or not IsOnlyDigits(SMSCode) then
        begin
          EndSession();
          Exit;
        end;
        JsonAnsiStr:='';

        //Convert String to AnsiString Type
        JsonAnsiStr := SMSCode; // InputBox('User Authorization', 'Enter the authorization code', '');

        JO := TJSONObject.Create;
        JO.AddPair('@type', 'checkAuthenticationCode');
        JO.AddPair('code', JsonAnsiStr);

        try
          //Send Request
          ReturnStr := td_send(JO);
         finally
          JO.Free;
          JO := NIL;
        end;
      End;

      //# wait for first and last name for new users
      if TLOAuthState.S('@type') = 'authorizationStateWaitRegistration' then
      Begin
      // need register user
        if TLOAuthState.Values['terms_of_service'] <> NIL then
          begin
            var s: String := '';
            var v1: TJSONValue := TLOAuthState.Values['terms_of_service'].FindValue('text');
            if v1 <> NIL then
              begin
                if v1.TryGetValue('@type', s) and (s = 'formattedText') then
                   v1.TryGetValue('text', s);
                eventJSON := v1;
                NotifyListenersSync(ie_tos);
              end;
          end;
      End;

      //# wait for password if present
      if TLOAuthState.S('@type') = 'authorizationStateWaitPassword' then
      Begin
        //Clear Variable
        JsonAnsiStr := '';

        eventString := 'Enter the access code';
        eventError := EC_missingLogin;
        NotifyListeners(IE_error);


        //Convert String to AnsiString Type
//        JsonAnsiStr := InputBox('User Authentication ',' Enter the access code', '');
//        if not InputQuery(GetTranslation('User Authentication '), GetTranslation(' Enter the access code'), s) then
        if pwd = '' then
        begin
          EndSession();
          Exit;
        end;

        JO := TJSONObject.Create;
        JO.AddPair('@type', 'checkAuthenticationPassword');
        JO.AddPair('password', pwd);

        //Send Request
        try
          //Send Request
          ReturnStr := td_send(JO);
         finally
          JO.Free;
          JO := NIL;
        end;

      End;

    End;
    {$ENDREGION 'Authorization'}

    {$REGION 'error'}
    if eventType = 'error' then
    Begin
      //if an error is found, stop the process
      if is_Closed = 0 then  //Restart Service
      Begin
         is_Closed := 1;
         is_Closed := 0;
      End;

      LoggaTLGPkt('An error was found:'+ #10#13 +
                  'code : ' + TLOEvent.S('code'), WL_disconnected, 'message : '+TLOEvent.S('message'));

      eventJSON := TLOEvent;
      NotifyListenersSync(IE_error);
    end;
    {$ENDREGION 'error'}

    if eventType = 'updateTermsOfService' then
     begin
       eventJSON := TLOEvent;
       NotifyListenersSync(ie_tos_update);
     end;

    if eventType = 'updateConnectionState' then
     begin
       var v: TJSONValue;
       var s: String;
       if TLOEvent.TryGetValue('state', v) and Assigned(v) then
         if v.TryGetValue('@type', s) then
           if s = 'connectionStateConnecting' then
             begin

             end
            else
           if s = 'connectionStateReady' then
             begin
               if phase <> online_ then
                 begin
                   phase := online_;
                   NotifyListenersSync(IE_online);

                   GetCL;

                   JO := TJSONObject.Create;
                   JO.AddPair('@type', 'getChats');
                   JO.AddPair('offset_order', '9223372036854775807');
                   JO.AddPair('limit', IntToStr(2000));
//                   JO.AddPair('@extra', IntToStr(incReqId));
                    try
                      //Send Request
                      ReturnStr := td_send(JO);
                     finally
                      JO.Free;
                      JO := NIL;
                    end;

                   JO := TJSONObject.Create;
                   JO.AddPair('@type', 'getChats');
       //  'chat_list'  - chatListArchive, and chatListMain
                   JO.AddPair('chat_list', TJSONObject.Create.AddPair('@type', 'chatListMain' ));
                   JO.AddPair('offset_order', '9223372036854775807');
//                   JO.AddPair('offset_order', intToStr(ROUND(Power(2, 63) - 1))); //This is a big number
                   JO.AddPair('offset_chat_id', '0');
                   JO.AddPair('limit', IntToStr(2000));
                   JO.AddPair('@extra', IntToStr(incReqId));
                    try
                      //Send Request
                      ReturnStr := td_send(JO);
                     finally
                      JO.Free;
                      JO := NIL;
                    end;

                 end;
             end;
     end;

    {$REGION 'getMe'}
    if TLOAuthState <> Nil then
      if TLOAuthState.S('@type') = 'authorizationStateReady' then
      Begin
        JO := TJSONObject.Create;
        JO.AddPair('@type', 'getMe');
        JO.AddPair('@extra', IntToStr(incReqId));

        //Send Request
        try
          //Send Request
          ReturnStr := td_send(JO);
         finally
          JO.Free;
          JO := NIL;
        end;

        phase := settingup_;
        notifyListeners(IE_connected);
{
        if TLOGetMe = Nil then
        Begin
          TLOGetMe := SO;
          TLOGetMe.S['@type'] := 'getMe';
          memSend.Lines.Add(td_send(TLOGetMe.Cast.ToAnsiString));
          memReceiver.Lines.Add(TLOGetMe.Cast.ToAnsiString);
        End;}
      End;


    if eventType = 'user' then  //updateUser
    Begin
//      parseinfo
//      eventContact := Self.getMyInfo;
//      eventContact
//      TLOMe := TLOEvent.AsObject;
    End;

    {$ENDREGION 'getMe'}

    {$REGION 'CL'}
    if eventType = 'users' then  //
    Begin
      var v: TJSONValue;
      var va: TJSONArray;
      v := TLOEvent.GetValue('user_ids');
      va := TJSONArray.Create;
      if v.TryGetValue(va) then
        ProcessContactList(va);
//      ProcessUsersAndGroups(JSON);
    End;
    {$ENDREGION 'CL'}

    {$REGION 'getContacts FULL'}
    //  getContacts - Ok
    if eventType = 'updateUser' then  //updateUser
    Begin
      var v: TJSONValue;
      v := TLOEvent.GetValue('user');
      ProcessContact(v);
//      ProcessUsersAndGroups(JSON);
    End;
    {$ENDREGION 'getContacts'}
(*
    {$REGION 'searchPublicChat'}
    //Return of searchPublicChat - OK....
    if eventType = 'chat' then
    Begin
      TLOChat := Nil;
      TLOChat := TLOEvent.AsObject;
      with ViewCtt.Items do
      begin
        if TLOChat.S['title'] <> '' then
        Begin
          { Add the root node in group type }
          GroupTreeNode := AddChild(GroupListTreeNode,  TLOChat.S['title']);

          { Add child nodes in root node}
          if TLOChat.I['id'].ToString <> '' then
          AddChild(GroupTreeNode,'ID : '+TLOChat.I['id'].ToString);
        End
        Else
          if TLOChat.I['id'].ToString <> '' then
          Begin
            { Add the root node }
            GroupTreeNode := AddChild(GroupListTreeNode, TLOChat.I['id'].ToString);
            { Add child nodes }
            AddChild(GroupTreeNode,'ID : '+TLOChat.I['id'].ToString);
          End;
      End;
    End;
    {$ENDREGION 'searchPublicChat'}
*)
    {$REGION 'updateNewMessage'}
    //Handling New incoming messages  //updateNewMessage - OK
    if eventType = 'updateNewMessage' then
    Begin
//      TLOUpdateMessage := Nil;
//      TLOContent :=  Nil;
      TLOUpdateMessage := TLOEvent.O('message');
      TLOContent :=  TLOUpdateMessage.O('content');

      //If it's a text message
      if TLOContent.S('@type') = 'messageText' then
      Begin
        TLOText := TLOContent.O('text');
        eventJSON := TLOContent;
        notifyListenersSync(IE_msg);
{        if CurrentChatStr = TLOUpdateMessage.I['chat_id'].ToString then
        Begin
          if TLOMe.I['id'].ToString = TLOUpdateMessage.I['sender_user_id'].ToString then
            memChatMSG.Say(User2, TLOUpdateMessage.I['sender_user_id'].ToString, TLOText.S['text'])
          else
            memChatMSG.Say(User1, TLOUpdateMessage.I['sender_user_id'].ToString, TLOText.S['text']);
        End;}
      End;

    end;
    {$ENDREGION 'updateNewMessage'}
(*
    {$REGION 'searchChatMessage'}
    if eventType = 'messages' then  //updateUser
    Begin
//      TLAMessages := Nil;
//      TLOContent  := Nil;
//      TLOText := Nil;
      for I := TLOEvent.I['total_count'] - 1 Downto 0 do
      Begin
        TLAMessages := TLOEvent.A['messages'];
        TLOContent := TLAMessages.O[I];
        TLOText := TLOContent.O['content'].O['text'];

        if TLOText.S['text'] <> '' then
        Begin
          if CurrentChatStr = TLOContent.I['chat_id'].ToString then
          Begin
            if TLOMe.I['id'].ToString = TLOContent.I['sender_user_id'].ToString then
              memChatMSG.Say(User2, TLOContent.I['sender_user_id'].ToString, TLOText.S['text'])
            else
              memChatMSG.Say(User1, TLOContent.I['sender_user_id'].ToString, TLOText.S['text']);
          End;
        End;
      End;


    End;
    {$ENDREGION 'searchChatMessage'}

    //# handle an incoming update or an answer to a previously sent request
    if TLOEvent.AsJSON() <> '{}' then
      Result := 'RECEIVING : '+ TLOEvent.AsJSON;
*)

  End;
  JO := NIl;
  JOParam := NIl;
  TLOAuthState := NIl;
  TLOEvent := NIl;
  TLOUpdateMessage := NIl;
  TLOContent := NIl;
  TLOText := NIl;
  TLOUsers := NIl;
  TLAContacts := NIl;
//  ContactTreeNode := NIl;
  {$ENDREGION 'IMPLEMENTATION'}
End;


procedure TTLGSession.ProcessContactList(const CL: TJSONArray);
var
  buddy, group: TJSONValue;
  buddies: TJSONArray;
  id, gID: Integer;
  pG: PGroup;
  name: String;
//  c: TTLGContact;
begin
  if not Assigned(CL) then
    Exit;

//  RnQmain.roster.BeginUpdate;
  try
    groups.MakeAllLocal;
//    for a in cl do
//
//    cl
{    for group in CL do
    if Assigned(Group) and (Group is TJSONObject) then
    begin
      group.GetValueSafe('name', name);
      group.GetValueSafe('id', id);
      gID := groups.ssi2id(id);
      if gID >= 0 then
        begin
          groups.rename(gID, name, True);
        end
      else
        begin
          gID := groups.name2id(name);
          if gID >= 0 then
            begin
              pG := groups.get(gID);
              if pG.ssiID >=0 then
                groups.Add(name, id)
               else
                pG.ssiID := id;
            end
           else
            groups.Add(name, id)
        end;

      buddies := TJSONObject(group).GetValue('buddies') as TJSONArray;
      for buddy in buddies do
      if Assigned(buddy) and (buddy is TJSONObject) then
        ProcessContact(buddy as TJSONObject, id, True);
    end;
}
  finally
//    RnQmain.roster.EndUpdate;
  end;
end;

function TTLGSession.ProcessContact(const Buddy: TJSONValue; GroupToAddTo: Integer = -1; Batch: Boolean = False): TTLGContact;
var
  i, Mute: Integer;
  b, LoadingCL, FoundCap: Boolean;
  Tmp, Phone1, Phone2, Phone3, PhoneType, OldXStatusStr: String;
  OldPic: TPicName;
  TheCap, TheCap2: RawByteString;
  UnixTime: Integer;
  NewStatus: TTLGStatus;
  NewInvis: Boolean;
//  Profile, TmpObj: TJSONObject;
  Cap, Ph, TmpArr: TJSONValue;
  Caps: TJSONArray;
  tmpId: RawByteString;
  v: TJSONValue;
begin
  Result := nil;

  if not Assigned(Buddy) then
    Exit;
  if not Buddy.TryGetValue('phone_number', v) then
    Exit;
  if v = NIL then
    Exit;

  Result := geTTLGContact(v.Value);
  if not Assigned(Result) then
    Exit;

  Result.allInfo := StrToUTF8(Buddy.ToString);

  if Buddy.TryGetValue('id', v) then
    Result.TLG_ID := v.Value;
//  if Buddy.GetValueSafe('abContactName', Name) then
//    if not (Name = '') then
//      Result.nick := Name
//  if (Result.nick = '') then
  begin
    if Buddy.GetValueSafe('username', Tmp) then
      if (Tmp <> '')and (tmp <> Result.UID2cmp) then
        Result.nick := Tmp;
    if Buddy.GetValueSafe('friendly', Tmp) then
//      if not (Tmp = '') then
      Result.fDisplay := Tmp;
//        Result.nick := Tmp;
  end;

  if Buddy.GetValueSafe('id', Tmp) then
    if TryStrToInt(Tmp, i) then
      Result.tlg_id := Tmp;

  if Buddy.GetValueSafe('first_name', Tmp) then
    Result.first := Tmp;

  if Buddy.GetValueSafe('last_name', Tmp) then
    Result.last := Tmp;


  // "abPhones" array - more phones, especially for CT_SMS contacts
//  Buddy.GetValueSafe('abPhoneNumber', Phone1);
  if Buddy.GetValueSafe('cellNumber', Tmp) then
    Result.Cellular := Tmp;
  if Buddy.GetValueSafe('phoneNumber', Tmp) then
    Result.Regular := Tmp;
  if Buddy.GetValueSafe('smsNumber', Tmp) then
    Result.SMSMobile := Tmp;
  Result.SMSable := not (Result.SMSMobile = '');
  if Buddy.GetValueSafe('workNumber', Tmp) then
    Result.Workphone := Tmp;
  // otherNumber

  if Buddy.GetValueSafe('official', i) then
    Result.Official := i = 1;

  Result.UserType := CT_UNK;
  if Buddy.GetValueSafe('userType', Tmp) then
    if Tmp = 'sms' then
    begin
      Result.UserType := CT_SMS;
      Result.SMSable := True;
    end
    else if Tmp = 'phone' then
      Result.UserType := CT_PHONE
    else if Tmp = 'icq' then
      Result.UserType := CT_ICQ
    else if Tmp = 'oldIcq' then
      Result.UserType := CT_OLDICQ;
  //Other possible types:
  //aim	- AIM or AOL
  //interop	- Gatewayed from another network
  //imserv - IMServ group target

  if Buddy.GetValueSafe('deleted', b) then
    Result.NoDB := true;
{
  if (Buddy.TryGetValue('capabilities', v)) and (v <> NIL) then
  begin
    Result.LastCapsUpdate := Now;
    Result.CapabilitiesSm := [];
    Result.CapabilitiesBig := [];
    Result.CapabilitiesXTraz := [];
    Result.ExtraCapabilities := '';
    Caps := v as TJSONArray;
    if Assigned(Caps) then
    for Cap in Caps do
    if Assigned(Cap) then
    begin
      TheCap := hex2StrU(Cap.Value);
      FoundCap := False;

      for i := 1 to Length(BigCapability) do
      if TheCap = BigCapability[i].v then
      begin
        Include(Result.CapabilitiesBig, i);
        FoundCap := True;
        Break;
      end;

      if Copy(TheCap, 1, 2) = CapsMakeBig1 then
      if Copy(TheCap, 5, 12) = CapsMakeBig2 then
      begin
        TheCap2 := Copy(TheCap, 3, 2);
        for i := 1 to Length(CapsSmall) do
        if TheCap2 = CapsSmall[i].v then
        begin
          Include(Result.CapabilitiesSm, i);
          FoundCap := True;
          Break;
        end;
      end;

      if not FoundCap then
        Result.ExtraCapabilities := Result.ExtraCapabilities + TheCap;
    end;

    Result.Crypt.SupportCryptMsg := CAPS_big_CryptMsg in Result.CapabilitiesBig;
    Result.Crypt.SupportEcc := False;
    i := Pos('RDEC0', Result.ExtraCapabilities);
    if i > 0 then
    begin
      Result.Crypt.EccPubKey := Copy(Result.ExtraCapabilities, i + 5, 11);
      i := Pos('RDEC1', Result.ExtraCapabilities);
      if i > 0 then
      begin
        Result.Crypt.EccPubKey := Result.Crypt.EccPubKey + Copy(Result.ExtraCapabilities, i + 5, 11);
        i := Pos('RDEC2', Result.ExtraCapabilities);
        if i > 0 then
        begin
          Result.Crypt.EccPubKey := Result.Crypt.EccPubKey + copy(Result.ExtraCapabilities, i + 5, 11);
          Result.Crypt.SupportEcc := Length(Result.Crypt.EccPubKey) = 33;
          if Result.Crypt.SupportEcc and fECCKeys.generated then
          begin
            SetLength(Result.Crypt.EccMsgKey, SizeOf(TECCSecretKey));
            if not ecdh_shared_secret(PECCPublicKey(Result.Crypt.EccPubKey)^, fECCKeys.pk, PECCSecretKey(Result.Crypt.EccMsgKey)^) then
            begin
              Result.Crypt.EccMsgKey := '';
              Result.Crypt.SupportEcc := False;
            end;
          end;
        end;
      end;
    end;

    Result.Typing.bSupport := CAPS_big_MTN in Result.CapabilitiesBig;
  end;

  UnixTime := -1;
  if Buddy.GetValueSafe('lastseen', UnixTime) then
    if UnixTime = 0 then
      Result.LastTimeSeenOnline := Now
     else
      Result.LastTimeSeenOnline := UnixToDateTime(UnixTime, False);

  NewInvis := False;
  Result.isMobile := False;
  if Buddy.GetValueSafe('state', Tmp) then
    begin
      if Tmp = 'online' then
        NewStatus := SC_ONLINE
      else if tmp = 'offline' then
        NewStatus := SC_OFFLINE
      else if tmp = 'occupied' then
        NewStatus := SC_OCCUPIED
      else if tmp = 'na' then
        NewStatus := SC_NA
      else if tmp = 'busy' then
        NewStatus := SC_OCCUPIED
      else if tmp = 'away' then
        NewStatus := SC_AWAY
      else if (tmp = 'mobile') and (UnixTime=0) then
        begin
          NewStatus := SC_ONLINE;
          Result.isMobile := True;
        end
      else if tmp = 'invisible' then
        begin
          NewStatus := SC_ONLINE;
          NewInvis := True;
        end;
    end
   else if (UnixTime <> 0) then
      NewStatus := SC_OFFLINE
   ;

  if Buddy.GetValueSafe('onlineTime', UnixTime) then
    Result.OnlineTime := UnixTime;

  if Buddy.GetValueSafe('idleTime', UnixTime) then
    Result.IdleTime := UnixTime;

  if Buddy.GetValueSafe('statusTime', UnixTime) then
    Result.LastStatusUpdate := UnixToDateTime(UnixTime, False);

//  if Buddy.GetValueSafe('awayTime', UnixTime) then
//    Result.AwayTime := UnixTime;

  if Buddy.GetValueSafe('memberSince', UnixTime) then
    Result.MemberSince := UnixToDateTime(UnixTime);
  if Buddy.GetValueSafe('mute', Mute) then
    Result.Muted := Mute > 0
   else
    Result.Muted := False;

  // awayMsg, profileMsg - ?
  try
    OldXStatusStr := Result.xStatusStr;
    if Buddy.GetValueSafe('statusMsg', Tmp) then
      Result.xStatusStr := HTMLEntitiesDecode(Tmp);
    if (Result.xStatusStr = '') and Buddy.GetValueSafe('moodTitle', Tmp) then
      Result.xStatusStr := HTMLEntitiesDecode(Tmp);
  //XStatusArray[curXStatus].pid6
  except
    // Cannot decode HTML for some reason
  end;
}
  Result.Authorized := True; // Assume this is the default :)

  // Owner only
  if Buddy.GetValueSafe('attachedPhoneNumber', Tmp) then
    if not (Tmp = '') then
      AttachedLoginPhone := Tmp;

//  Profile := TJSONObject(Buddy.GetValue('profile'));
//  if Assigned(Profile) then
  begin
    buddy.GetValueSafe('first_name', Result.first);
    buddy.GetValueSafe('last_name', Result.last);
{
//    if Profile.GetValueSafe('nick', Tmp) and (Tmp<>'') then
//      Result.Nick := Tmp
    if Profile.GetValueSafe('nick', Tmp) then
      Result.Nick := Tmp;
    if Profile.GetValueSafe('friendlyName', Tmp) then
      Result.Nick := Tmp;

    if Profile.GetValueSafe('authRequired', i) then
      Result.Authorized := i = 0;

    if Profile.GetValueSafe('gender', Tmp) then
    begin
      if Tmp = 'female' then
        Result.gender := 1
      else if Tmp = 'male' then
        Result.gender := 2
      else
        Result.gender := 0;
    end else Result.gender := 0;

     if Profile.GetValueSafe('birthDate', Tmp) then
      if TryStrToInt(Tmp, UnixTime) then
        if UnixTime < 0 then
          Result.birth := 0
        else
          Result.birth := UnixToDateTime(UnixTime, True);

    TmpArr := Profile.GetValue('homeAddress');
    if Assigned(TmpArr) and (TmpArr is TJSONArray) and (TJSONArray(TmpArr).Count > 0) then
    begin
      TmpObj := TJSONObject(TJSONArray(TmpArr).Get(0));
      TmpObj.GetValueSafe('country', Result.Country);
      TmpObj.GetValueSafe('state', Result.State);
      TmpObj.GetValueSafe('street', Result.Address);
      TmpObj.GetValueSafe('city', Result.City);
      TmpObj.GetValueSafe('zip', Result.ZIP);
    end;

    TmpArr := Profile.GetValue('originAddress');
    if Assigned(TmpArr) and (TmpArr is TJSONArray) and (TJSONArray(TmpArr).Count > 0) then
    begin
      TmpObj := TJSONObject(TJSONArray(TmpArr).Get(0));
      TmpObj.GetValueSafe('country', Result.BirthCountry);
      TmpObj.GetValueSafe('state', Result.BirthState);
      TmpObj.GetValueSafe('street', Result.BirthAddress);
      TmpObj.GetValueSafe('city', Result.BirthCity);
      TmpObj.GetValueSafe('zip', Result.BirthZIP);
    end;

    // Not there in new proto
    Profile.GetValueSafe('lang1', Result.Lang[1]);
    Profile.GetValueSafe('lang2', Result.Lang[2]);
    Profile.GetValueSafe('lang3', Result.Lang[3]);

    TmpArr := Profile.GetValue('phones');
    if Assigned(TmpArr) and (TmpArr is TJSONArray) and (TJSONArray(TmpArr).Count > 0) then
    for Ph in TJSONArray(TmpArr) do
    if Assigned(Ph) then
    begin
      Ph.GetValueSafe('type', PhoneType);
      Ph.GetValueSafe('phone', Tmp);
      if not (Tmp = '') then
      begin
        if PhoneType = 'home' then
          Result.Regular := Tmp
        else if PhoneType = 'mobile' then
          Result.Cellular := Tmp
        else if PhoneType = 'work' then
          Result.WorkPhone := Tmp
        else if PhoneType = 'other' then
          Result.OtherPhone := Tmp
      end;
    end;

    if Profile.GetValueSafe('tz', Tmp) then // Minutes from GMT?..
      if TryStrToInt(Tmp, i) then
        Result.GMThalfs := SmallInt(0); // 0 for now

    Profile.GetValueSafe('aboutMe', Result.About);
    Profile.GetValueSafe('statusLine', Result.LifeStatus);
    Profile.GetValueSafe('website1', Result.Homepage);

    // Possible fields: jobs[], validatedEmail, pendingEmail, emails[], studies[], interests[], groups[], pasts[]
    // anniversary, children, smoking, height, lastupdated, hideFlag, validatedCellular
{
    "birthDate" : -2147472000,
    "education" : "unknown",
    "religion" : "unknown",
    "hairColor" : "unknown",
    "sexualOrientation" : "unknown",

    "userType" : "oldIcq",
    "online" : "false",
    "photo" : "false",
    "betaFlag" : 0,
    "autoSms" : "false", // autoforward IM to SMS
}

    // Owner only
    if Result.UID2cmp = MyAccNum then
    begin
      Result.Authorized := True;
//      if Profile.GetValueSafe('webAware', i) then
//        webAware := i = 1;
//      if Profile.GetValueSafe('authRequired', i) then
//        authNeeded := i = 1;
//      if Profile.GetValueSafe('hideLevel', Tmp) then
//      if Tmp = 'none' then
//        showInfo := 0
//      else if Tmp = 'emailsAndCellular' then
//        showInfo := 1
//      else if Tmp = 'allExceptFln' then
//        showInfo := 2
//      else if Tmp = 'all' then
//        showInfo := 3
//      else
//        showInfo := 0;

//    "privateKey" : "945b74c51c594c4c987f0b194fdabbd6",
//    "allowEmail" : "false",
    end;
  end;

  //location - Information that the user has provided about their location
  //pending	- ICQWEB: For buddylist events, any pending authorization buddies will have this flag
  //recent - For buddylist events, any buddies in the Recent Buddies group will have this set
  //bot -	For buddylist events, any buddies that are BOTs will have this set
  //shared - For buddylist events, any buddies in the a shared buddies group will have this set

  LoadingCL := GroupToAddTo >= 0;

  // Add to roster if it's CL response and group is defined
  if LoadingCL then
  begin
    Result.CntIsLocal := False;
    Result.SetGroupSSID(GroupToAddTo);
    if not Result.IsInRoster then
      fRoster.add(Result);
  end;

  // Handle status change
  ProcessNewStatus(Result, NewStatus, NewInvis, not (OldXStatusStr = Result.xStatusStr), Batch);

  OldPic := Result.ClientPic;
  GetClientPicAndDesc4(Result, Result.ClientPic, Result.ClientDesc);
  if not (Result.ClientPic = OldPic) and not Batch then
  begin
    eventContact := Result;
    NotifyListeners(IE_redraw);
  end;

  if Buddy.GetValueSafe('iconId', Tmp) then
    begin
      try
        tmpId := hex2strU(tmp);
       except
        tmpId := tmp;
      end;
      if not (tmpId = Result.IconID) then
      begin
    OutputDebugString(PChar('New avatar for ' + String(Result.UID2cmp) + ': ' + Tmp));
        Result.IconID := tmpId;
        eventContact := Result;
        notifyListeners(IE_avatar_changed);
        if IsMyAcc(Result) then
          MyAvatarHash := Result.IconID;
      end;
    end;

  Result.InfoUpdatedTo := now;
  eventTime := Now;
  eventContact := Result;
  notifyListeners(IE_userinfo);
end;

procedure TTLGSession.ProcessNewStatus(var Cnt: TTLGContact; NewStatus: TTLGStatus;
                           CheckInvis: Boolean = False; XStatusStrChanged: Boolean = False; NoNotify: Boolean = False);
var
  OldInvis, NewInvis: Integer;
  StatusChanged: Boolean;
  InvisChanged: Boolean;
begin
  OldInvis := Cnt.InvisibleState;
  NewInvis := OldInvis;

  if NewStatus = SC_ONLINE then
    NewInvis := 0
  else if (Cnt.Status = SC_OFFLINE) and CheckInvis then
    NewInvis := 2
  else if (Cnt.Status = SC_ONLINE) and CheckInvis then
    NewInvis := 1;

  Cnt.PrevStatus := Cnt.Status;
  eventOldStatus := Cnt.Status;
  eventOldInvisible := Cnt.IsInvisible;
  eventContact := Cnt;
  eventTime := Now;
  Cnt.birthFlag := birthdayFlag and (not (Cnt.birth = 0) or not (Cnt.birthL = 0));

  StatusChanged := not (NewStatus = eventOldStatus);
  InvisChanged := not (NewInvis = OldInvis);
//OutputDebugString(PChar(String(Cnt.uid2cmp) + ': ' + inttostr(integer(eventOldStatus)) + ' -> ' + inttostr(integer(newstatus))));
//OutputDebugString(PChar(String(Cnt.uid2cmp) + ': ' + inttostr(OldInvis) + ' -> ' + inttostr(NewInvis)));
  if StatusChanged or InvisChanged then
  begin
    Cnt.Status := NewStatus;
    Cnt.InvisibleState := NewInvis;
  end;

  // Very slow with large CL otherwise
  if NoNotify then
    Exit;

  if StatusChanged then
  begin
    if Cnt.PrevStatus = SC_UNK then
      notifyListeners(IE_statuschanged)
    else if Cnt.PrevStatus = SC_OFFLINE then
      notifyListeners(IE_incoming)
    else
    begin
      Cnt.LastTimeSeenOnline := eventTime;
      notifyListeners(IE_outgoing);
    end;
  end else if InvisChanged then
  begin
    if OldInvis = 0 then
      notifyListeners(IE_statuschanged)
    else
      notifyListeners(IE_incoming);
  end else if XStatusStrChanged then
    notifyListeners(IE_statuschanged)
  else
    notifyListeners(IE_contactupdate);
end; // ProcessNewStatus

procedure TTLGSession.ProcessUsersAndGroups(const JSON: TJSONObject);
var
  user, groups: TJSONValue;
  users: TJSONArray;
begin
  if not IsReady then
    Exit;

  groups := JSON.GetValue('groups');
  if Assigned(groups) and (groups is TJSONArray) then
    ProcessContactList(TJSONArray(groups));

  users := JSON.GetValue('users') as TJSONArray;
  if Assigned(users) then
  for user in users do
    ProcessContact(TJSONObject(user), -1, True);
end;

procedure TTLGSession.ProcessDialogState(const Dlg: TJSONObject; IsOfflineMsg: Boolean = False);
const
  AESBLKSIZE = SizeOf(TAESBlock);
var
  c: TTLGContact;
  starting, outgoing: Boolean;
  rbsTmp: RawByteString;
  sn, mtype, sTmp, StickerStr: String;
  iTmp: Integer;
  ExtSticker: TStringDynArray;
  Theirs, Msg, MsgPos, Sticker: TJSONValue;
  Msgs: TJSONArray;

  procedure DecryptMessage(Encrypted: Integer; Payload: TJSONObject; var Msg: String);
  var
    RQCompressed, RQLen: Integer;
    RQCRC: Cardinal;
    Ctx: TAESECB;
    Key: TSHA256Digest;
    Msg2, CrptMsg: TBytes;
    i: Integer;
  begin
    Payload.GetValueSafe('compressed', RQCompressed);
    Payload.GetValueSafe('crc', RQCRC);
    Payload.GetValueSafe('length', RQLen);

    if RQLen = 0 then
    begin
      eventError := EC_FailedDecrypt;
      eventMsgA := GetTranslation('Zero length message');
      NotifyListeners(IE_error);
      Exit;
    end else if RQCRC = 0 then
    begin
      eventError := EC_FailedDecrypt;
      eventMsgA := GetTranslation('Incorrect CRC');
      NotifyListeners(IE_error);
      Exit;
    end else if not (RQCompressed in [0,1]) then
    begin
      eventError := EC_FailedDecrypt;
      eventMsgA := GetTranslation('Unknown type of compression [%d]', [RQCompressed]);
      NotifyListeners(IE_error);
      Exit;
    end else if c.Crypt.EccMsgKey = '' then
    begin
      eventError := EC_FailedDecrypt;
      eventMsgA := GetTranslation('Unable to create encryption key');
      NotifyListeners(IE_error);
      Exit;
    end;

    eventFlags := eventFlags or IF_Encrypt;

    Msg2 := TEncoding.ANSI.GetBytes(Msg); // Should be Base64
    Base64DecodeBytes(Msg2, CrptMsg);
    SetLength(Msg2, 0);

    CalcKey(Encrypted = 2, IfThen(Encrypted = 2, c.Crypt.EccMsgKey, ''), c.UID2cmp, MyAccount, 0, RQLen, Key);

    i := Length(CrptMsg);
    SetLength(Msg2, i + AESBLKSIZE);
    ctx := TAESECB.Create(Key[0], 256);
    ctx.Decrypt(@CrptMsg[0], @Msg2[0], i);
    ctx.Free;

    if RQCompressed = 1 then
      Msg2 := ZDecompressBytes(Msg2);

    SetLength(Msg2, RQLen);
    if Length(Msg2) > 0 then
    if not ((ZipCrc32($FFFFFFFF, @Msg2[0], RQLen) XOR $FFFFFFFF) = RQCRC) then
    begin
      eventError := EC_FailedDecrypt;
      eventMsgA := GetTranslation('Bad CRC');
      NotifyListeners(IE_error);
      //eventFlags := eventFlags and not IF_Bin and not IF_CODEPAGE_MASK;
    end else
      Msg := TEncoding.UTF8.GetString(Msg2)
    else
    begin
      eventError := EC_FailedDecrypt;
      eventMsgA := GetTranslation('Zero length message');
      NotifyListeners(IE_error);
    end;
    {
    eventContact := c;
    notificationForMsg(msgtype, msgflags, priority=2, msg);
    case getStatus of
      byte(SC_away): sendACK(thisCnt, ACK_AWAY, '');
      byte(SC_na): sendACK(thisCnt, ACK_NA, '');
      byte(SC_dnd), byte(SC_occupied):
        if priority = 2 then
          sendACK(thisCnt, ACK_OK, '', msgDwnCnt)
        else
          sendACK(thisCnt, ACK_NOBLINK,'')
      else sendACK(thisCnt, ACK_OK, '', msgDwnCnt)
    end;
    }
  end;


//  procedure ProcessMsg(Msg: TJSONObject; chat: TTLGContact = NIL);
//  var
//    UnixTime, ID: Integer;
//    MsgID: TMsgID;
//    WID, sID, lSender: String;
//    chatObj: TJSONValue;
//  begin
//    if not Assigned(Msg) then
//      Exit;
//
//    if Msg.GetValueSafe('outgoing', outgoing) then
//    if outgoing then // Backup ack, should be acked from imState already
//    with Msg do
//    begin
//      eventFlags := 0;
//      eventMsgA := '';
//
//      if GetValueSafe('time', UnixTime) then
//        eventTime := UnixToDateTime(UnixTime, False);
//
//      if GetValueSafe('wid', WID) then
//        eventWID := WID;
//
//      if GetValueSafe('msgId', MsgID) then
//        eventMsgID := MsgID;
//
//      GetValueSafe('reqId', sID);
//      eventReqID := sID;
//      if TryStrToInt(sID, ID) then
//      begin
//        eventInt := ID;
//      end;
//      NotifyListeners(IE_serverAck);
//
//      Exit;
//    end;
//
//    SetLength(eventBinData, 0);
//    eventFlags := 0;
//    eventMsgA := '';
////    eventEncoding := TEncoding.Default;
//
//    lSender := '';
//    chatObj := TJSONObject(Msg).GetValue('chat');
//    if Assigned(chatObj) and (chatObj is TJSONObject) then
//      begin
//        chatObj.GetValueSafe('sender', lSender);
//      end;
//
//
//    if IsOfflineMsg then
//      eventFlags := eventFlags or IF_offline
//    else
//      ProcessNewStatus(c, c.Status, True); // Check for invisibility (non-offline message from offline contact)
//
//    // offlineIM/dataIM:
//    // "imf": "plain"
//    // "autoresponse" : 0
//    mtype := 'text'; // text or sticker
//    if Msg.GetValueSafe('mediaType', sTmp) then
//      if not (sTmp = '') then
//        mtype := sTmp;
//    if IsOfflineMsg and Msg.GetValueSafe('stickerId', sTmp) then
//      mtype := 'sticker';
//
////    if EnableStickers and (mtype = 'sticker') then
//    if (mtype = 'sticker') then
//    begin
//      if IsOfflineMsg then
//        StickerStr := sTmp
//      else
//      begin
//        Sticker := TJSONObject(Msg).GetValue('sticker');
//        if Sticker.GetValueSafe('id', sTmp) then
//          StickerStr := sTmp
//      end;
//
//      ExtSticker := SplitString(StickerStr, ':');
////      if (Length(ExtSticker) >= 4) then
////        eventBinData := GetSticker(ExtSticker[1], ExtSticker[3]);
//
//      eventString := '';
//    end else if Msg.GetValueSafe(IfThen(IsOfflineMsg, 'message', 'text'), sTmp) then
//      eventString := sTmp;
//    if Msg.GetValueSafe(IfThen(IsOfflineMsg, 'msgId', 'wid'), sTmp) then
//      eventWID := sTmp;
//    if Msg.GetValueSafe(IfThen(IsOfflineMsg, 'timestamp', 'time'), iTmp) then
//      eventTime := UnixToDateTime(iTmp, False)
//    else
//      eventTime := Now;
//
////    eventAddress := sA; // For multichat
//
//// delUpto, tail, intro, persons[]
//
////  "yours" : {
////    "lastRead" : "6640070768770154834"
////  },
////  "theirs" : {
////    "lastDelivered" : "6640435849580249672",
////    "lastRead" : "6640435849580249672"
////  },
//
//    // Process special RnQ messages
//    if not (eventString = '') and ContainsStr(eventString, 'RnQDataIM') then
//      if CheckDataPayload(eventString) then
//        Exit;
//
//    eventContact := c;
//    if lSender <> '' then
//      begin
//        eventAddress := lSender;
//        notifyListeners(IE_MultiChat);
//      end
//     else
//    notifyListeners(IE_msg);
//  end;

begin
  if not Assigned(Dlg) then
    Exit;

  if not Dlg.GetValueSafe('starting', starting) then
   starting := false;

  if IsOfflineMsg then
    Dlg.GetValueSafe('aimId', sn)
  else
    Dlg.GetValueSafe('sn', sn);

  c := nil;
  if not (sn = '') then
    c := geTTLGContact(sn);

  if not Assigned(c) then
  begin
    eventError := EC_MalformedMsg;
    eventMsgA := Dlg.ToString;
    notifyListeners(IE_error);
    Exit;
  end;

//  if IsOfflineMsg then
//    ProcessMsg(Dlg)
//  else
  with Dlg do
  begin
    if not GetValueSafe('unreadCnt', iTmp) then
      iTmp := 0;

    if starting and (iTmp=0) then
      Exit; // Skip last messages for sidebar

    GetValueSafe('unreadMentionMeCount', iTmp);
    if GetValueSafe('patchVersion', sTmp) then
      PatchVersion := sTmp;

    // Delivery/read status
    Theirs := GetValue('theirs');
    if Assigned(Theirs) then
    begin
      eventContact := c;
      if Theirs.GetValueSafe('lastDelivered', sTmp) then
        if TryStrToUInt64(sTmp, eventMsgID) then
          NotifyListeners(IE_ack);

//      if Theirs.GetValueSafe('lastRead', sTmp) then
//        if TryStrToUInt64(sTmp, eventMsgID) then
//          NotifyListeners(IE_readAck);
    end;
(*
    Msgs := GetValue('messages') as TJSONArray;
    if Assigned(Msgs) then
      for Msg in Msgs do
        if Msg is TJSONObject then
          ProcessMsg(TJSONObject(Msg), c);

    MsgPos := GetValue('intro');
    if Assigned(MsgPos) and (MsgPos is TJSONObject) then
    begin
      Msgs := TJSONObject(MsgPos).GetValue('messages') as TJSONArray;
      if Assigned(Msgs) then
        for Msg in Msgs do
          if Msg is TJSONObject then
            ProcessMsg(TJSONObject(Msg));
    end;

    MsgPos := GetValue('tail');
    if Assigned(MsgPos) and (MsgPos is TJSONObject) then
    begin
      Msgs := TJSONObject(MsgPos).GetValue('messages') as TJSONArray;
      if Assigned(Msgs) then
        for Msg in Msgs do
          if Msg is TJSONObject then
            ProcessMsg(TJSONObject(Msg));
    end;
*)
  end;
end;

procedure TTLGSession.ProcessTyping(const Data: TJSONObject);
var
  c: TTLGContact;
  TypingStatus: String;
  attr: TJSONValue;
begin
  if not Assigned(Data) then
    Exit;

  c := GeTTLGContact(Data.GetValue('aimId').Value);
  if not Assigned(c) then
    Exit;

  attr := Data.GetValue('MChat_Attrs');
  eventAddress := '';
  if Assigned(attr) and (attr is TJSONObject) then
    begin
      attr.GetValueSafe('sender', eventAddress);
    end;

  Data.GetValueSafe('typingStatus', TypingStatus);
  if TypingStatus = 'typing' then
    eventInt := MTN_BEGUN
  else if TypingStatus = 'typed' then
    eventInt := MTN_TYPED
  else
    eventInt := MTN_FINISHED;

  eventTime := Now;
  eventContact := c;
//  eventMsgID := ?;
  case eventInt of
    MTN_FINISHED, MTN_TYPED, MTN_CLOSED: eventContact.typing.bIsTyping := False;
    MTN_BEGUN: eventContact.typing.bIsTyping := True;
  end;
  notifyListeners(IE_typing);
end;

procedure TTLGSession.ProcessAddedYou(const Data: TJSONObject);
var
  c: TTLGContact;
  NeedAuth: Integer;
  Name, Msg: String;
begin
  if not Assigned(Data) then
    Exit;

  c := GeTTLGContact(Data.GetValue('requester').Value);
  if not Assigned(c) then
    Exit;

  //Data.GetValueSafe('displayAIMid', Name);
  Data.GetValueSafe('authRequested', NeedAuth);
  Data.GetValueSafe('msg', Msg);

  eventContact := c;
  eventTime := Now;
  eventFlags := 0;
  eventMsgA := Msg;
  NotifyListeners(IE_addedYou);

  if NeedAuth = 1 then
  begin
    eventContact := c;
    eventTime := Now;
    eventFlags := 0;
    eventMsgA := Msg;
    NotifyListeners(IE_authReq);
  end;
end;

procedure TTLGSession.ProcessPermitDeny(const Data: TJSONObject);
var
  c: TTLGContact;
  Mode: String;
  Item, Items: TJSONValue;
  cl: TRnQCList;
begin
  if not Assigned(Data) then
    Exit;

  SpamList.Clear;
  Items := Data.GetValue('ignores');
  if Assigned(Items) and (Items is TJSONArray) then
  for Item in TJSONArray(Items) do
  begin
    c := nil;
    if not (TJSONString(Item).Value = '') then
      c := geTTLGContact(TJSONString(Item).Value);
    if not Assigned(c) then
      Continue;
    SpamList.Add(c);
    AddToIgnoreList(c, True);
    eventContact := c;
    NotifyListeners(IE_contactupdate);
  end;

  fVisibleList.Clear;
  Items := Data.GetValue('allows');
  if Assigned(Items) and (Items is TJSONArray) then
   begin
    cl := TRnQCList.Create;
    for Item in TJSONArray(Items) do
      begin
        if not (TJSONString(Item).Value = '') then
          cl.add(Self, TJSONString(Item).Value)
      end;
     add2visible(cl, True);
     cl.Free;
   end;

(* Clear unsupported block list?
  Items := Data.GetValue('blocks');
  if Assigned(Items) and (Items is TJSONArray) then
    for Item in TJSONArray(Items) do
      RemFromBlock(TJSONString(Item).Value);
*)
  if Data.GetValueSafe('pdMode', Mode) then
    if not (Mode = '') then
      if (SpamList.Count > 0) and not (Mode = 'denySome') then
        SetPermitDenyMode('denySome');

  NotifyListeners(IE_UpdatePrefsFrm);
end;

procedure TTLGSession.checkServerHistory(const uid: TUID);
begin
  checkOrGetServerHistory(uid, False);
end;

procedure TTLGSession.getServerHistory(const uid: TUID);
begin
  checkOrGetServerHistory(uid, True);
end;

procedure TTLGSession.checkOrGetServerHistory(const uid: TUID; retrieve: Boolean = False);

var
  query, params, wid, lastMsgId, fromMsgId, PatchVer: String;
  respStr: RawByteString;
  msg, Patch, text, tmp: TJSONValue;
  json, results, stickerObj: TJSONObject;
  messages, Patches: TJSONArray;
  msgCount, unixTime, code, ind, kind: Integer;
  PatchMsgId: Int64;
  extsticker: TStringDynArray;
  stickerBin: RawByteString;
  time: TDateTime;
  outgoing: Boolean;
  cht, cnt: TRnQContact;

  function GetHistoryChunk(const From: String; Count: Integer; const Till: String = ''): RawByteString;
  var
    Header: String;
  begin
//    Params := '{"sn": "' + UID + '", "fromMsgId": ' + From + IfThen(Till = '', '', ', "tillMsgId": ' + Till) + ', "count": ' + IntToStr(Count) + ', "aimSid": "' + fSession.aimsid + '", "patchVersion": "' + PatchVer + '"}';
//    Query := '{"method": "getHistory", "reqId": "' + IntToStr(ReqId) + '-' + IntToStr(DateTimeToUnix(Now, False) - fSession.HostOffset) + '", "authToken": "' + fSession.restToken + '", "clientId": ' + fSession.RESTClientId + ', "params": ' + Params + ' }';
{
    Header := '[POST] Get a chunk of server history [' + From + ':' + IntToStr(Count) + ']';
    LoggaTLGPkt(Header, WL_sent_text, Query);
    LoadFromURLAsString(REST_HOST, Result, Query);
    LoggaTLGPkt(Header, WL_rcvd_text, Result);
    Inc(ReqId);
}
  end;

begin
  if not restAvailable then
    Exit;

  cht := getContact(uid);
  msgCount := RDUtils.IfThen(retrieve, MAXINT-1, 1);
  PatchVer := 'init';

  fromMsgId := lastMsgIds.Values[uid];
  if fromMsgId = '' then
    FromMsgId := '-1';

  RespStr := GetHistoryChunk(FromMsgId, MsgCount);
  if not ParseJSON(UTF8String(respStr), JSON) then
    Exit;

  if TJSONObject(JSON.GetValue('status')).GetValue('code').TryGetValue(Code) then
  if not (Code = 20000) then
  begin
    ODS('Error code: ' + IntToStr(Code));
    Exit;
  end;

  Results := TJSONObject(JSON.GetValue('results'));
  if Results = nil then
  begin
    ODS('No results');
    Exit;
  end;

  Results.GetValueSafe('patchVersion', PatchVer);
  Patches := TJSONArray(Results.GetValue('patch'));
  for Patch in Patches do
  if Assigned(Patch) and (Patch is TJSONObject) then
  begin
    PatchMsgId := StrToInt64(TJSONString(TJSONObject(Patch).GetValue('msgId')).Value);
    GetHistoryChunk(IntToStr(PatchMsgId - 1), 1);
    Break;
  end;

  Messages := TJSONArray(Results.GetValue('messages'));
  if Messages.Count = 0 then
  begin
    ODS('No new messages on server');
    Exit;
  end;

  if not Retrieve then
  begin
    eventContact := TTLGContact(cht);
    NotifyListeners(IE_serverHistoryReady);
    Exit;
  end;

  Results.GetValueSafe('lastMsgId', LastMsgId);
  Ind := LastMsgIds.IndexOfName(UID);
  if Ind < 0 then
    LastMsgIds.AddPair(UID, LastMsgId)
   else
    LastMsgIds[Ind] := UID + LastMsgIds.NameValueSeparator + LastMsgId;

  eventJSON := messages;
  NotifyListeners(IE_serverHistory);

end;

procedure TTLGSession.SetListener(l : TProtoNotify);
begin
  listener := l;
end;

procedure TTLGSession.SendTyping(c: TTLGContact; NotifType: Word);
var
  TypingStatus: RawByteString;
  Query: RawByteString;
  BaseURL: String;
begin
  if not Assigned(c) or (not IsOnline) or (not ImVisibleTo(c)) then
    Exit;
{
  TypingStatus := 'none';
  if NotifType = MTN_BEGUN then
    TypingStatus := 'typing'
  else if NotifType = MTN_TYPED then
    TypingStatus := 'typed';

  BaseURL := WIM_HOST + 'im/setTyping';
  Query := '&t=' + ParamEncode(String(c.UID2cmp)) +
           '&typingStatus=' + TypingStatus;
  SendSessionRequest(False, BaseURL, Query, 'Send typing');
}
end;



function TTLGSession.GenSSID : Integer;
var
  a : Word;
begin
//  repeat
   a := random($7FFF);
//  until (FindSSIItemID(serverSSI, a)<0) and (groups.ssi2id(a) < 0) and (a>0); //(contactsDB.idxBySSID(a) >=0)or (groups.ssi2id(a) >= 0);
  Result := a;
end;

procedure TTLGSession.SendAddContact(c: TTLGContact);
var
  JSON: TJSONObject;
  Query: RawByteString;
  BaseURL, ResCode: String;
  Results: TJSONArray;
  Code: Integer;
begin
{
  BaseURL := WIM_HOST + 'buddylist/addBuddy';
//  Query := '&buddy=' + ParamEncode(String(c.UID2cmp))+
//           '&aimsid=' + ParamEncode(fSession.aimsid);
  if c.getGroupName > '' then
    Query := Query + '&group=' + ParamEncode(c.getGroupName);
  Query := Query +
           '&authorizationMsg=' + ParamEncode(GetTranslation(Str_AuthRequest)) +
           '&preAuthorized=1';
  if SendSessionRequest(False, BaseURL, Query, RT_JSON, JSON, 'Add contact', 'Failed to add contact') then
  begin
    Results := JSON.GetValue('results') as TJSONArray;
    if Assigned(Results) and (Results.Count > 0) then
    if not (Results.Get(0) = nil) then
    if Results.Get(0).GetValueSafe('resultCode', ResCode) then
    if TryStrToInt(ResCode, Code) then
    begin
      if Code = 0 then // Success! Remove local state and get profile of a newly added contact
      begin
        c.CntIsLocal := False;
        GetProfile(c);
      end
        else
      begin
        eventError := EC_AddContact_Error;
        eventInt := Code;
        notifyListeners(IE_error);

        // Already in CL? Request it again
        if Code = 3 then
          GetCL;
      end;
    end;
  end;
}
end;

procedure TTLGSession.SSI_UpdateContact(c: TTLGContact);
var
  Query: RawByteString;
  BaseURL: String;
begin
{
  BaseURL := WIM_HOST + 'buddylist/setBuddyAttribute';
  Query := '&buddy=' + ParamEncode(String(c.UID2cmp)) +
           '&friendly=' + ParamEncode(c.Display);
  SendSessionRequest(False, BaseURL, Query, 'Rename contact', 'Failed to rename contact');
}
end;

procedure TTLGSession.SendRemoveContact(c: TTLGContact);
var
  Query: RawByteString;
  BaseURL: String;
begin
{
  BaseURL := WIM_HOST + 'buddylist/removeBuddy';
  Query := '&buddy=' + ParamEncode(String(c.UID2cmp)) +
           '&allGroups=1';
  if SendSessionRequest(False, BaseURL, Query, 'Remove contact', 'Failed to remove contact') then
    c.CntIsLocal := c.IsInRoster
}
end;

procedure TTLGSession.UpdateGroupOf(cnt: TRnQContact);
begin

end;

function TTLGSession.UpdateGroupOf(c: TTLGContact; grp: Integer): Boolean;
var
  Query: RawByteString;
  BaseURL: String;
//  Code: Integer;
begin
  Result := False;
  if c.CntIsLocal then
    Exit;
{
  BaseURL := WIM_HOST + 'buddylist/moveBuddy';
  Query := '&buddy=' + ParamEncode(String(c.UID2cmp)) +
           '&group=' + ParamEncode(c.getGroupName) +
           '&newGroup=' + ParamEncode(groups.id2name(grp));
  if SendSessionRequest(False, BaseURL, Query, 'Move contact', 'Failed to move contact') then
  begin
    Result := True;
    eventContact := c;
    notifyListeners(IE_contactupdate);
  end;
}
end;

function TTLGSession.SendUpdateGroup(const Name: String; ga: TGroupAction; const Old: String = ''): Boolean;
var
  Query: RawByteString;
  BaseURL: String;
//  Code: Integer;
begin
  Result := False;
{
  if ga = GA_Add then
  begin
    BaseURL := WIM_HOST + 'buddylist/addGroup';
    Query := '&group=' + ParamEncode(Name);
    Result := SendSessionRequest(False, BaseURL, Query, 'Add group', 'Failed to add group');
  end else if (ga = GA_Rename) and not (Old = '') then
  begin
    BaseURL := WIM_HOST + 'buddylist/renameGroup';
    Query := '&oldGroup=' + ParamEncode(Old) +
             '&newGroup=' + ParamEncode(Name);
    Result := SendSessionRequest(False, BaseURL, Query, 'Rename group', 'Failed to rename group');
  end else if ga = GA_Remove then
  begin
    BaseURL := WIM_HOST + 'buddylist/removeGroup';
    Query := '&group=' + ParamEncode(Name);
    Result := SendSessionRequest(False, BaseURL, Query, 'Remove group', 'Failed to remove group');
  end else
    Exit;
}
end;

function TTLGSession.deleteGroup(grSSID: Integer): Boolean;
begin
  Result := False;
  notAvailable;
end;

procedure TTLGSession.UpdateGroupID(grID: Integer);
begin
  notAvailable;
end;

procedure TTLGSession.AuthGrant(Cnt: TRnQContact);
begin
  AuthGrant(cnt as TTLGContact);
end;

procedure TTLGSession.AuthGrant(c: TTLGContact; Grant: Boolean = True);
var
  Query: RawByteString;
  BaseURL, ResCode: String;
begin
{
  BaseURL := WIM_HOST + 'buddylist/authorizeUser';
  Query := RawByteString('&t=') + ParamEncode(String(c.UID2cmp)) +
           '&authorized=' + IfThen(Grant, RawByteString('1'), RawByteString('0'));
  SendSessionRequest(False, BaseURL, Query, IfThen(Grant, 'Grant', 'Deny') + ' auth', 'Failed to ' + IfThen(Grant, 'grant', 'deny') + ' authorization');
}
end;

procedure TTLGSession.AuthRequest(cnt: TRnQContact; const Reason: String);
var
  Query: RawByteString;
  BaseURL: String;
  iam: TRnQContact;
  rsn: String;
begin
{
  if not ImVisibleTo(cnt) then
    if AddTempVisMsg then
      AddTemporaryVisible(cnt as TTLGContact);
  iam := GetMyInfo;

  if Reason = '' then
    rsn := GetTranslation(Str_AuthRequest)
   else
    rsn := Reason;

  BaseURL := WIM_HOST + 'buddylist/requestAuthorization';
  Query := '&t=' + ParamEncode(String(cnt.UID2cmp)) +
           '&authorizationMsg=' + ParamEncode(rsn);
  SendSessionRequest(False, BaseURL, Query, 'Request auth', 'Failed to request authorization')
}
end;

// Set an implicit refcount so that refcounting
// during construction won't destroy the object.
class function TTLGSession.NewInstance: TObject;
begin
  Result := inherited NewInstance;
  TTLGSession(Result).FRefCount := 1;
end;

class function TTLGSession._getContactClass: TRnQCntClass;
begin
  Result := TTLGContact;
end;

class function TTLGSession._getProtoServers: String;
var
  i: Integer;
begin
  Result := '';
  for I := 0 to Length(TLGServers) - 1 do
    Result := Result + TLGServers[i]+ CRLF;
end;

class function TTLGSession._getProtoID : Byte;
begin
  Result := TLGProtoID;
end;

function TTLGSession.GetContactClass: TRnQCntClass;
begin
  Result := TTLGContact;
end;

class function TTLGSession._MaxPWDLen: Integer;
begin
  Result := maxPwdLength;
end;

function TTLGSession.GetContact(const UID: TUID): TRnQContact;
begin
  result := GeTTLGContact(uid);
end;

function TTLGSession.GetContact(const UIN: Integer): TRnQContact;
begin
  result := GeTTLGContact(uin);
end;

function TTLGSession.GetStatuses: TStatusArray;
begin
  Result := TLGstatuses;
end;

function TTLGSession.GetVisibilities: TStatusArray;
begin
  Result := icqVis;
end;

function TTLGSession.GetStatusMenu: TStatusMenu;
begin
  Result := statMenu;
end;

function TTLGSession.GetVisMenu: TStatusMenu;
begin
  Result := icqVisMenu;
end;

function TTLGSession.GetStatusDisable: TOnStatusDisable;
begin
  result := onStatusDisable[byte(curStatus)];
end;

procedure TTLGSession.InputChangedFor(cnt: TRnQContact; InpIsEmpty: Boolean; timeOut: boolean = false);
var
  c: TTLGContact;
begin
  if (not SupportTypingNotif) or (not IsSendTypingNotif) or not Assigned(cnt) then
    Exit;
  c := cnt as TTLGContact;
  with TTLGContact(c) do
  if (not (c.Status in [SC_OFFLINE, SC_UNK])) {and (typing.bSupport)} then
  begin
    if (not InpIsEmpty) then
    begin
      if TimeOut then
      begin
        typing.bIamTyping := False;
        SendTyping(c, MTN_TYPED);
      end
        else
      begin
        typing.TypingTime := Now;
        if not typing.bIamTyping then
        begin
          typing.bIamTyping := True;
          SendTyping(c, MTN_BEGUN);
        end;
      end;
    end else if typing.bIamTyping then
    begin
      SendTyping(c, MTN_FINISHED);
      typing.bIamTyping := False;
    end
  end
end;
{
function TTLGSession.sendFileTest(msgID:TmsgID; c:Tcontact; fn:string; size:integer) : Integer;
begin
//if not IsReady then exit;

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

function TTLGSession.compareStatusFor(cnt1, Cnt2: TRnqContact): Smallint;
begin
  if StatusPriority[TTLGContact(cnt1).status] < StatusPriority[TTLGContact(Cnt2).status] then
    result := -1
  else if StatusPriority[TTLGContact(cnt1).status] > StatusPriority[TTLGContact(Cnt2).status] then
    result := +1
  else
    Result := 0;
end;

procedure TTLGSession.getClientPicAndDesc4(cnt: TRnQContact;
              var pPic: TPicName; var CliDesc: String);
var
  c: TTLGContact;
begin
  if isOffline or (cnt=NIL) or cnt.isOffline then
    exit;
  if cnt is TTLGContact then
    c := TTLGContact(cnt)
   else
    Exit;
  pPic := '';
  CliDesc := Str_unk;

//  getICQClientPicAndDesc(c, pPic, CliDesc);
end; // getClientPicAndDesc4

function TTLGSession.getPrefPage: TPrefFrameClass;
begin
  result := TTLGFr;
end;

procedure TTLGSession.ApplyBalloon;
  function SameMonthDay(d1, d2: TDateTime): Boolean;
  begin
    Result := (MonthOf(d1) = MonthOf(d2)) and (DayOf(d1) = DayOf(d2))
  end;
begin
  if GetMyInfo = nil then
    raise Exception.create('ApplyBalloon: ICQ.MyInfo is nil');

  Self.birthdayFlag := (SendBalloonOn = BALLOON_BDAY) and SameMonthDay(self.getMyInfo.birth, Now)
                       or (SendBalloonOn = BALLOON_DATE) and SameMonthDay(SendBalloonOnDate, Now)
                       or (SendBalloonOn = BALLOON_ALWAYS);
end; // ApplyBalloon

class function TTLGSession.DLLInitialize: Boolean;
var
  dllFilePath: String;
begin
  Result := False;
  dllFilePath := tdjsonDllName;
  if tdjsonDll = 0 then
    tdjsonDll := SafeLoadLibrary(dllFilePath);
  if tdjsonDll = 0 then
    begin
      dllFilePath := modulesPath + tdjsonDllName;
      tdjsonDll := SafeLoadLibrary(dllFilePath);
    end;
  if tdjsonDll = 0 then
    begin
      dllFilePath := ExtractFilePath(paramStr(0)) + modulesPath + tdjsonDllName;
      tdjsonDll := SafeLoadLibrary(dllFilePath);
    end;

    if tdjsonDll <> 0 then
    begin
      @TD_client_create := GetProcAddress(tdjsonDll, 'td_json_client_create');
      if not Assigned(TD_client_create) then
        Exit;
      @TD_client_destroy := GetProcAddress(tdjsonDll, 'td_json_client_destroy');
      if not Assigned(TD_client_destroy) then
        Exit;
      @TD_client_send := GetProcAddress(tdjsonDll, 'td_json_client_send');
      if not Assigned(TD_client_send) then
        Exit;
      @TD_client_receive := GetProcAddress(tdjsonDll, 'td_json_client_receive');
      if not Assigned(TD_client_receive) then
        Exit;
      @TD_client_execute := GetProcAddress(tdjsonDll, 'td_json_client_execute');
      if not Assigned(TD_client_execute) then
        Exit;
          //Deprecated
          @TD_set_log_file_path := GetProcAddress(tdjsonDll, 'td_set_log_file_path');
          if not Assigned(TD_set_log_file_path) then
            Exit;
          //Deprecated
          @TD_set_log_max_file_size := GetProcAddress(tdjsonDll, 'td_set_log_max_file_size');
          if not Assigned(TD_set_log_max_file_size) then
            Exit;
      @TD_set_log_verbosity_level := GetProcAddress(tdjsonDll, 'td_set_log_verbosity_level');
      if not Assigned(TD_set_log_verbosity_level) then
        Exit;
      @TD_set_log_fatal_error_callback := GetProcAddress(tdjsonDll, 'td_set_log_fatal_error_callback');
      if not Assigned(TD_set_log_fatal_error_callback) then
        Exit;
    end;

  Result := tdjsonDll <> 0;
end;

class constructor TTLGSession.InitTLGProto;
var
  b, b2: Byte;
begin
  tdjsonDll := 0;
   begin
      SetLength(TLGstatuses, Byte(HIGH(TTLGStatus))+1);
      for b := byte(LOW(TTLGStatus)) to byte(HIGH(TTLGStatus)) do
        with TLGstatuses[b] do
         begin
          idx := b;
          ShortName := status2img[b];
          Cptn      := status2ShowStr[TTLGStatus(b)];
    //      ImageName := 'status.' + status2str[st1];
          ImageName := 'status.' + ShortName;
         end;
      setLength(statMenu, 5);
      b2 := 0;
      statMenu[b2] := Byte(SC_ONLINE);inc(b2);
    //  statMenu[1] := Byte(SC_F4C);inc(b2);
      statMenu[b2] := Byte(SC_OCCUPIED);inc(b2);
      statMenu[b2] := Byte(SC_AWAY);inc(b2);
      statMenu[b2] := Byte(SC_NA);inc(b2);
    //  statMenu[b2] := Byte(SC_Evil);inc(b2);
    //  statMenu[b2] := Byte(SC_Depression);inc(b2);
      statMenu[b2] := Byte(SC_OFFLINE);

      SetLength(icqVis, Byte(HIGH(TVisibility))+1);
      for b := byte(LOW(Tvisibility)) to byte(HIGH(TVisibility)) do
        with ICQvis[B] do
         begin
          idx := b;
          ShortName := visib2str[TVisibility(b)];
          Cptn      := visibility2ShowStr[TVisibility(b)];
    //      ImageName := 'status.' + status2str[st1];
          ImageName := visibility2imgName[TVisibility(b)];
         end;
    {
      setLength(icqVisMenu, 5);
      icqVisMenu[0] := Byte(VI_all);
      icqVisMenu[1] := Byte(VI_normal);
      icqVisMenu[2] := Byte(VI_CL);
      icqVisMenu[3] := Byte(VI_privacy);
      icqVisMenu[4] := Byte(VI_invisible);
    }
      setLength(icqVisMenu, 2);
      icqVisMenu[0] := Byte(VI_normal);
      icqVisMenu[1] := Byte(VI_invisible);
    //  ICQHelper := TICQHelper.Create;
    //  RegisterProto(ICQHelper);
      RegisterProto(TTLGSession);
    end;
end;

class destructor TTLGSession.UnInitTLGProto;
var
  b: Byte;
begin
  if Length(TLGstatuses) > 0 then
  for b := Byte(Low(TTLGStatus)) to byte(High(TTLGStatus)) do
  with TLGstatuses[b] do
  begin
    SetLength(ShortName, 0);
    SetLength(Cptn, 0);
    SetLength(ImageName, 0);
  end;
  SetLength(TLGstatuses, 0);
  SetLength(statMenu, 0);

  if Length(ICQVis) > 0 then
  for b := Byte(Low(TVisibility)) to byte(High(TVisibility)) do
  with ICQVis[B] do
  begin
    SetLength(ShortName, 0);
    SetLength(Cptn, 0);
    SetLength(ImageName, 0);
  end;
  SetLength(ICQVis, 0);
  SetLength(icqVisMenu, 0);
end;

end.
