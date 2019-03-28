{
  This file is part of R&Q.
  Under same license
}
unit WIM;
{$I RnQConfig.inc}
{$I NoRTTI.inc}

{$DEFINE usesVCL}

interface

uses
  Windows, SysUtils, Classes, Character, Types, JSON, Generics.Collections, Threading,
  ExtCtrls, StrUtils, Math, OverbyteIcsHttpProt,
  RnQGlobal, RnQNet, RQThemes, RDGlobal, RQUtil, RnQJSON,
  RnQPrefsTypes, groupsLib,
  RnQProtocol, WIMContacts, WIMConsts, WIM.Stickers,
  RnQPrefsInt,
  SynEcc;


type
  TWPResult = packed record
    nick, first, last, email: String;
    StsMSG: String;
    BDay: TDateTime;
    uin: TUID;
    authRequired: Boolean;
//    status: Byte;  // 0=offline 1=online 2=don't know
    gender: Byte;
    status: Word;  // 0=offline 1=online 2=don't know
    age: Word;
    BaseID: Word;
  end; // TWPResult

  TWPSearch = packed record
    nick, first, last, email, city, state, keyword: String;
    uin: TUID;
    Token: RawByteString;
    gender: Byte;
    lang: AnsiString;
    onlineOnly: Boolean;
    country: Word;
    wInterest: Word;
    age: Integer;
  end; // TWPSearch

type
  TsplitProc = procedure(const s: RawByteString) of object;

  TmsgID = UInt64;

  TWIMEvent = (
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
    IE_stickersearchupdate
  );

  TwimPhase = (
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

  TWIMSession = class;

  TWIMNotify = procedure(Sender: TWIMSession; event: TwimEvent) of object;
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

  TWIMSessionSubType = (SESS_IM = 0, SESS_AVATARS = 1, SESS_NEW_UIN = 2);

//  TWIMSession = class(TRnQProtocol, IRnQProtocol)
  TWIMSession = class(TRnQProtocol)
  public
//    const ContactType: TRnQContactType =  TWIMContact;
//    type ContactType = TWIMContact;
    const ContactType: TClass =  TWIMContact;
  private
    phase: TwimPhase;
//    wasUINwp: Boolean;  // trigger a last result at first result
//    creatingUIN: Boolean;  // this is a special session, to create uin
//    isAvatarSession: Boolean;  // this is a special session, to get avatars
    protoType: TWIMSessionSubType; // main session; to create uin; to get avatars
    previousInvisible: Boolean;
    P_webaware: Boolean;
    P_authneeded: Boolean;
    P_showInfo: Byte;
//    startingInvisible: Boolean;
    StartingVisibility: TVisibility;
    StartingStatus: TWIMStatus;
    CurStatus: TWIMStatus;
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
      c: TWIMContact;
    end;
    fRoster: TRnQCList;
    fVisibleList: TRnQCList;
    fInvisibleList: TRnQCList;
    tempVisibleList: TRnQCList;
    spamList: TRnQCList;

    fPwd: String;
    fSession: TSessionParams;
    LastFetchBaseURL: String;
    PatchVersion: String;

    BuzzedLastTime: TDateTime;
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
//    MyInfo0: TWIMContact;
    birthdayFlag: Boolean;
    CurXStatus: Byte;
    CurXStatusStr: TXStatStr;
    serviceServerAddr: AnsiString;
    serviceServerPort: AnsiString;
    // used to pass valors to listeners
    eventError: TicqError;
    eventOldStatus: TWIMStatus;
    eventOldInvisible: Boolean;
    eventUrgent: Boolean;
    eventAccept: TicqAccept;
    eventContact: TWIMContact;
    eventContacts: TRnQCList;
    eventWP: TwpResult;
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
    eventWID: RawByteString;
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

    httpPoll: TSslHttpCli;
//    httpPoll: TSslHttpRest;
    timeout: TTimer;
//    pollStream: TStringStream;
    pollStream: TMemoryStream;
    exectime: Int64;
    CleanDisconnect: Boolean;
    LastSearchPacks: TStickerPacks;
    EnableRecentlyOffline: Boolean;
    RecentlyOfflineDelay: Integer;
    class var
      WIMstatuses, icqVis: TStatusArray;


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
//    class function GeTWIMContact(const uid: TUID): TWIMContact; overload;
//    class function GeTWIMContact(uin: Integer): TWIMContact; overload;
    function getWIMContact(const uid: TUID): TWIMContact; overload;
    function getWIMContact(const uin: Integer): TWIMContact; overload;

    function getContact(const UID: TUID): TRnQContact; overload; override; final;
    function getContact(const UIN: Integer): TRnQContact; overload;
    function getContactClass: TRnQCntClass; override; final;

    function pwdEqual(const pass: String): Boolean; override; final;
//    procedure setStatusStr(s: String; Pic: AnsiString = '');
    procedure setStatusStr(xSt: Byte; stStr: TXStatStr);
    procedure setStatusFull(st: Byte; xSt: Byte; stStr: TXStatStr);

//    constructor Create; override;
//    destructor Destroy; override;
    class constructor InitWIMProto;
    class destructor UnInitWIMProto;
    constructor Create(const id: TUID; subType: TWIMSessionSubType);
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
    function MakeParams(const Method: AnsiString; const BaseURL: String; const Params: TDictionary<String, String>; Sign: Boolean = True; DoublePercent: Boolean = False): String;
    procedure OpenICQURL(URL: String);
    function ClientLogin: Boolean;
    function StartSession: Boolean;
    function PingSession: Boolean;
    procedure AfterSessionStarted;
    procedure ResetSession;
    procedure EndSession(EndToken: Boolean = False);
    procedure PollError(const ExtraError: String = '');
    procedure StartPolling;
    procedure RestartPolling(Delay: Integer = 1);
    procedure AbortPolling(Sender: TObject);
    procedure PollURL(const URL: String);
    procedure PollRequestDone(Sender: TObject; RqType: THttpRequest; ErrCode: Word);
    procedure ProcessContactList(const CL: TJSONArray);
    function  ProcessContact(const Buddy: TJSONObject; GroupToAddTo: Integer = -1; Batch: Boolean = False): TWIMContact;
    procedure ProcessNewStatus(var Cnt: TWIMContact; NewStatus: TWIMStatus; CheckInvis: Boolean = False; XStatusStrChanged: Boolean = False; NoNotify: Boolean = False);
    procedure ProcessUsersAndGroups(const JSON: TJSONObject);
    procedure ProcessDialogState(const Dlg: TJSONObject; IsOfflineMsg: Boolean = False);
//    procedure ProcessIMData(const Data: TJSONObject);
    procedure ProcessIMState(const Data: TJSONObject);
    procedure ProcessTyping(const Data: TJSONObject);
    procedure ProcessAddedYou(const Data: TJSONObject);
    procedure ProcessPermitDeny(const Data: TJSONObject);
    procedure InitWebRTC;
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
    function UpdateGroupOf(c: TWIMContact; grp: Integer): Boolean; OverLoad;
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
    property getProtoType: TWIMSessionSubType read protoType;
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
  public // ICQ Only
    procedure SSI_UpdateContact(c: TWIMContact);
    procedure SendAddContact(c: TWIMContact);
    procedure SendRemoveContact(c: TWIMContact);

    procedure AddContactToCL(var c: TWIMContact);
    procedure AddContactsToCL(cl: TRnQCList);
    procedure ClearTemporaryVisible;

    procedure RemoveContactFromServer(c: TWIMContact);
    function SendUpdateGroup(const Name: String; ga: TGroupAction; const Old: String = ''): Boolean;

    function useMsgType2for(c: TWIMContact): Boolean;
    procedure SendTyping(c: TWIMContact; NotifType: Word);

    procedure SendCreateUIN(const AcceptKey: RawByteString); deprecated;
    function  UploadAvatar(const fn: TFileName; cnt: TRnQContact = NIL; chat: Boolean = false): Boolean;
//    procedure sendPermsNew;//(c: Tcontact);

    procedure SendSaveMyInfo(c: TWIMContact);
    function SendSticker(const Cnt: TRnQContact; const sticker: String): RawByteString;
    procedure SendContacts(Cnt: TRnQContact; flags: DWord; cl: TRnQCList); deprecated;
    procedure SendQueryInfo(const uid: TUID); deprecated;
//    procedure SendAddedYou(const uin: TUID);
    function GetMyCaps: RawByteString;

    procedure add2visible(cl: TRnQCList; OnlyLocal: Boolean = False); overload;
    procedure add2invisible(cl: TRnQCList; OnlyLocal: Boolean = False); overload;

    procedure GetProfile(const UID: TUID);
    procedure GetContactInfo(const UID: TUID; const IncludeField: String);
    procedure GetContactAttrs(const UID: TUID);
    procedure SendContactAttrs(c: TWIMContact);
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
    procedure NotifyListeners(ev: TWIMEvent);
    // send packets
    procedure SendEccMSGsnac(const cnt: TWIMContact; const sn: RawByteString); deprecated;
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
    function Add2Visible(c: TWIMContact): Boolean; overload;
    function Add2Ignore(c: TWIMContact): Boolean; //overload;
    function RemFromIgnore(c: TWIMContact): Boolean;
    function Add2Invisible(c: TWIMContact): Boolean; overload;
    function AddTemporaryVisible(c: TWIMContact): Boolean; overload;
    function AddTemporaryVisible(cl: TRnQCList): Boolean; overload;
    function RemoveTemporaryVisible(c: TWIMContact): Boolean; overload;
    function RemoveTemporaryVisible(cl: TRnQCList): Boolean; overload;
    function RemoveFromVisible(c: TWIMContact): Boolean; overload;
    procedure RemoveFromVisible(const cl: TRnQCList); overload;
    function RemoveFromInvisible(c: TWIMContact): Boolean; overload;
    procedure RemoveFromInvisible(const cl: TRnQCList); overload;


    procedure GoneOffline; // called going offline
    procedure OnProxyError(Sender: TObject; Error: Integer; const Msg: String);
    procedure parsePagerString(s: RawByteString);

    function dontBotherStatus: boolean;
//    function myUINle: RawByteString;

  public // All
    function CreateDataPayload(Caps: TArray<RawByteString>; const Data: TBytes = nil; Compressed: Integer = -1; CRC: Cardinal = 0; Len: Integer = 0): String;
    function SendMsgOrSticker(Cnt: TRnQContact; var Flags: dword; const Msg: String; MsgType: TMsgType; var RequiredACK: Boolean): RawByteString; // returns handle
    function sendMsg(Cnt: TRnQContact; var Flags: dword; const Msg: String; var RequiredACK: Boolean): Integer; override; final; // returns handle
    function sendMsg2(Cnt: TRnQContact; var Flags: dword; const Msg: String; var RequiredACK: Boolean): RawByteString; override; final; // returns handle
    function SendSticker2(Cnt: TRnQContact; var Flags: dword; const Msg: String; var RequiredACK: Boolean): RawByteString;
    function SendBuzz(Cnt: TRnQContact): Boolean;
    procedure SetListener(l: TProtoNotify); override; final;
    procedure SetMuted(c: TWIMcontact; Mute: Boolean);
    procedure AuthRequest(cnt: TRnQContact; const reason: String); OverRide; {$IFDEF HAS_FINAL} final; {$ENDIF HAS_FINAL}
    procedure AuthGrant(Cnt: TRnQContact); OverLoad; OverRide; {$IFDEF HAS_FINAL} final; {$ENDIF HAS_FINAL}
    procedure AuthGrant(c: TWIMContact; Grant: Boolean = True); OverLoad; deprecated;

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
    function GetStoreStickerPack(const PackId: String): TStickerPack;
    procedure BuyStickerPack(const PackId: String);
    procedure RemoveStickerPack(const PackId: String);
  end; // TWIMSession

  TWIMProtoClass = class of TWIMSession;

  TWIMAsync = class(TSslHttpCli)
  public
    Contact: TWIMContact;
  end;

var
//  sendInterests,
  SupportInvisCheck,
  AddTempVisMsg,

  showInvisSts,

  AvatarsNotDnlddInform: Boolean;
  ExtClientCaps: RawByteString;
  AddExtCliCaps: Boolean;
  SendBalloonOn: Integer;
  SendBalloonOnDate: TDateTime;

  statMenu, icqVisMenu: TStatusMenu;
//  reqId: Integer = 1;

implementation

uses
  Controls, dateUtils,
{$IFDEF UNICODE}
   AnsiStrings, AnsiClasses,
{$ENDIF UNICODE}
  RnQZip, SynCrypto,
  RnQDialogs, RnQLangs, RDUtils, RDFileUtil, RnQCrypt, Base64,
{$IFDEF RNQ_AVATARS}
  RnQ_Avatars,
{$ENDIF}
  globalLib, utilLib, RnQConst, RnQProtoUtils,
//  ICQClients,
  WIM_Fr,
//  themesLib, mainDlg,
  RnQStrings,
  Protocol_WIM, NetEncoding,
  viewWIMinfodlg;

//var
//  lastSendedFlap: TDateTime;



function sameMethods(a, b: TWIMNotify): boolean;
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

function xml_sms(me: TRnQcontact; const dest, msg: AnsiString; ack: boolean): AnsiString;
const
  yesno: array [boolean] of AnsiString = ('No', 'Yes');
begin
result :=
  '<icq_sms_message>' +
  '<destination>' + dest + '</destination>' +
  '<text>' + str2html(msg) + '</text>' +
  '<codepage>1251</codepage>' +
  //'<encoding>utf8</encoding>' +
  '<senders_UIN>' + me.uid + '</senders_UIN>' +
  '<senders_name>' + AnsiString(me.displayed4All) + '</senders_name>' +
  '<delivery_receipt>' + yesno[ack] + '</delivery_receipt>' +
  '<time>' + AnsiString(FormatDatetime('ddd, dd mmm yyyy hh:nn:ss', now - gmtoffset)) + ' GMT</time>' +
  '</icq_sms_message>';
end; // xml_sms

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
//  Result := TNetEncoding.URL.Encode(text); // Shit at emoji/unicode
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

class function TWIMSession._RegisterUser(var pUID: TUID; var pPWD: String): Boolean;
begin
  Result := False;
  openURL('https://icq.com/join/');
end;

class function TWIMSession._CreateProto(const uid: TUID): TRnQProtocol;
begin
  Result := TWIMSession.Create(uid, SESS_IM);
end;

constructor TWIMSession.Create(const id: TUID; subType: TWIMSessionSubType);
begin
  protoType := subType;
  fContactClass := TWIMContact;

  inherited Create;

  phase := null_;
  listener := nil;

  if id = '' then
  begin
    MyAccount := '';
//    myinfo0 := nil
  end
    else
  begin
//    myinfo0 := GeTWIMContact(id);
//    MyAccount := myinfo0.UID2cmp;
    MyAccount := TWIMContact.trimUID(id);
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
  fSession.HostOffset := 0;
  fSession.tokenExpIn := 0; // Never
  fSession.DevId := ICQ_DEV_ID;
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
    fECCKeys.generated := ecc_make_key(fECCKeys.pubEccKey, fECCKeys.pk);

//    pollStream := TStringStream.Create('', TEncoding.UTF8);
    pollStream := TMemoryStream.Create();
    httpPoll := TSslHttpCli.Create(nil);
    httpPoll.FollowRelocation := True;
    httpPoll.OnRequestDone := PollRequestDone;
    httpPoll.RcvdStream := pollStream;
    httpPoll.Connection := 'keep-alive';
    timeout := TTimer.Create(nil);
    timeout.OnTimer := AbortPolling;
    timeout.Interval := 58000;
    timeout.Enabled := False;
  end;
end; // create

procedure TWIMSession.ResetPrefs;
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
  supportInvisCheck := False;
  EnableRecentlyOffline := False;
  RecentlyOfflineDelay := 15;
  AddExtCliCaps := False;
  ExtClientCaps := '';
  SupportTypingNotif := True;
  isSendTypingNotif  := True;
  TypingInterval := 5;
  UseCryptMsg := True;
  UseEccCryptMsg := True;
  useFBcontacts := False;
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
  for I := low(XStatusArray) to High(XStatusArray) do
  begin
    ExtStsStrings[i].Cap := getTranslation(XStatusArray[i].Caption);
    ExtStsStrings[i].Desc := '';
  end;
end;

procedure TWIMSession.GetPrefs(pp: IRnQPref);
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
  pp.addPrefBool('use-xmpp-contacts', useFBcontacts);
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
//    for i := byte(low(TWIMStatus)) to byte(high(TWIMStatus)) do
    if i <> byte(SC_OFFLINE) then
     begin
      s := status2Img[i]+'-disable-';
      pp.addPrefBool( s+'blinking', onStatusDisable[i].blinking);
      pp.addPrefBool( s+'tips', onStatusDisable[i].tips);
      pp.addPrefBool( s+'sounds', onStatusDisable[i].sounds);
      pp.addPrefBool( s+'openchat', onStatusDisable[i].OpenChat);
     end;
//    icq := TWIMSession(mainproto.ProtoElem);
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

  if SaveToken then
  begin
    pp.addPrefBlob64('crypted-session-key64', passCrypt(fSession.secretenc64));
    pp.addPrefBlob64('crypted-auth-token64', passCrypt(fSession.token));
    pp.addPrefInt('auth-token-time', fSession.tokenTime);
    pp.addPrefInt('auth-token-expiresin', fSession.tokenExpIn);
  end;
  pp.addPrefInt('session-last-host-offset', fSession.hostOffset);
end;

procedure TWIMSession.SetPrefs(pp: IRnQPref);
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
       if (i in [low(XStatusArray)..High(XStatusArray)])
//             and (xsf_6 in XStatusArray[i].flags)
       then
         curXStatus := i
       else
         curXStatus := 0;
     end;

     pp.getPrefInt('send-balloon-on', SendBalloonOn);
     pp.getPrefDate('send-balloon-on-date', SendBalloonOnDate);
      pp.getPrefInt('local-ssi-count', localSSI_itemCnt);
      pp.getPrefDateTime('local-ssi-time', localSSI_modTime);

      for st := Byte(low(TWIMStatus)) to Byte(high(TWIMStatus)) do
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

  if SaveToken then
  begin
    fSession.secretenc64 := passDecrypt(pp.getPrefBlob64Def('crypted-session-key64'));
    fSession.token := passDecrypt(pp.getPrefBlob64Def('crypted-auth-token64'));
    pp.getPrefInt('auth-token-time', fSession.tokenTime);
    pp.getPrefInt('auth-token-expiresin', fSession.tokenExpIn);
  end;
  pp.getPrefInt('session-last-host-offset', fSession.hostOffset);

  pp.getPrefInt('typing-notify-interval', TypingInterval);
  pp.getPrefBool('use-crypt-msg', useCryptMsg);
  pp.getPrefBool('use-ecc-crypt-msg', useEccCryptMsg);
  pp.getPrefBool('use-xmpp-contacts', useFBcontacts);
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
  if contactsDB.idxOf(TWIMContact, MyAccount) >= 0 then
  with TWIMContact(GetMyInfo) do
  begin
//    status := TWIMStatus(SC_OFFLINE);
    IconID := MyAvatarHash;
  end;

  ApplyBalloon();

//  fSSLServer := pp.getPrefStrDef('oscar-ssl-server',
//                             ICQ_SECURE_LOGIN_SERVER0);
//  fOscarProxyServer := pp.getPrefStrDef('oscar-proxy-server',
//                             AOL_FILE_TRANSFER_SERVER0);
end;


procedure TWIMSession.Clear;
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

destructor TWIMSession.Destroy;
begin
//  Q.free;
  lastMsgIds.free;
  sock.free;
  fRoster.free;
  fVisibleList.free;
  fInvisibleList.free;
  tempvisibleList.free;
  spamList.Free;
  FreeAndNil(pollStream);
  timeout.Enabled := False;
  FreeAndNil(timeout);
  FreeAndNil(httpPoll);
  inherited destroy;
end; // destroy

function TWIMSession.GetMyInfo: TRnQcontact;
begin
//  result := MyInfo0;
  Result := contactsDB.add(Self, MyAccount);
end;
{procedure TWIMSession.setMyInfo(cnt: TRnQContact);
begin
  myInfo := TWIMContact(cnt);
end;}

function TWIMSession.IsMyAcc(c: TRnQContact): Boolean;
begin
//  result := MyInfo0.equals(c);
  Result := Assigned(c) and c.equals(MyAccount)
end;

function TWIMSession.IncReqId: TmsgID;
begin
  reqId := reqId + 1;
  Result := reqId;
end;

function TWIMSession.canAddCntOutOfGroup: Boolean;
begin
  result := True;
end;

procedure TWIMSession.sendKeepalive;
begin
end;

function TWIMSession.pwdEqual(const pass: String): Boolean;
begin
  Result := ((pass<>'') and (pass = fPwd));
end;

function TWIMSession.getPwd: String;
begin
  Result := fPwd;
end;

function TWIMSession.RequiresLogin: Boolean;
begin
  Result := (fSession.secretenc64 = '') or (fSession.token = '') or (fSession.tokenTime = 0) or
            (not (fSession.tokenExpIn = 0) and (fSession.tokenTime + fSession.tokenExpIn < DateTimeToUnix(Now, False)));
end;

function TWIMSession.RESTAvailable: Boolean;
begin
  Result := not (fSession.aimsid = '') and not (fSession.restToken = '') and not (fSession.restClientId = '');
end;

function TWIMSession.getSession(updateIfReq: Boolean = True): TSessionParams;
begin
  if updateIfReq and RequiresLogin then
    StartSession;

  Result.fetchURL := fSession.fetchURL;
  Result.aimsid := fSession.aimsid;
  Result.devid := fSession.devid;
  Result.secret := fSession.secret;
  Result.secretenc64 := fSession.secretenc64;
  Result.token := fSession.token;
  Result.tokenExpIn := fSession.tokenExpIn;
  Result.tokenTime := fSession.tokenTime;
  Result.hostOffset := fSession.hostOffset;
  Result.restToken := fSession.restToken;
  Result.restClientId := fSession.restClientId;
end;

procedure TWIMSession.setPwd(const value: String);
begin
  if (Length(value) <= maxPwdLength) then
  if not (value = fPwd) then
    fPwd := value;
end; // setPwd

procedure TWIMSession.NotifyListeners(ev: TWIMEvent);
begin
  if Assigned(Listener) then
    Listener(Self, Integer(ev));
end; // notifyListeners

function TWIMSession.isOffline: boolean;
begin
  Result := phase = null_
end;

function TWIMSession.isOnline: boolean;
begin
  Result := phase = online_
end;

function TWIMSession.isConnecting: boolean;
begin
//  Result := not (isOffline or isOnline)
  Result := (phase <> online_) and (phase <> null_)
end;

procedure TWIMSession.GoneOffline;
begin
  if phase = null_ then
    Exit;
  phase := null_;

  tempvisibleList.clear;
  CurStatus := SC_OFFLINE;
  fRoster.ForEach(procedure(cnt: TRnQContact)
  begin
    TWIMContact(cnt).OfflineClear;
    TWIMContact(cnt).Status := SC_UNK;
  end);
  notifyListeners(IE_offline);
end; // GoneOffline

procedure TWIMSession.Disconnect;
begin
  CleanDisconnect := True;
  if phase = online_ then
    EndSession(not SaveToken)
  else
    Phase := null_;
end;

function TWIMSession.IsReady: Boolean;
begin
  Result := phase in [settingup_, online_]
end;

function TWIMSession.isSSCL: boolean;
begin
  Result :=
       True;
end;

function TWIMSession.IsMobileAccount: Boolean;
begin
  Result := String(MyAccount).StartsWith('+');;
end;

function TWIMSession.SendSessionRequest(IsPOST: Boolean; const BaseURL: String; const Query: RawByteString; const Header: AnsiString = '';
                                        const ErrMsg: String = ''; const ErrProc: TErrorProc = nil): Boolean;
var
  q: RawByteString;
begin
  if fSession.aimsid = '' then
    Exit(False);
  q := 'f=json&aimsid=' + ParamEncode(fSession.aimsid) + '&r=' + CreateNewGUID + Query;
  Result := SendRequest(IsPOST, BaseURL, q, Header, ErrMsg, ErrProc);
end;

function TWIMSession.SendSessionRequest(IsPOST: Boolean; const BaseURL: String; const Query: RawByteString; Ret: TReturnData;
                                        var JSON: TJSONObject; const Header: AnsiString = ''; const ErrMsg: String = ''; const ErrProc: TErrorProc = nil): Boolean;
var
  q: RawByteString;
begin
  if fSession.aimsid = '' then
    Exit(False);
  q := 'f=json&aimsid=' + ParamEncode(fSession.aimsid) + '&r=' + CreateNewGUID + Query;
  Result := SendRequest(IsPOST, BaseURL, q, Ret, JSON, Header, ErrMsg, ErrProc);
end;

function TWIMSession.SendRequest(IsPOST: Boolean; const BaseURL: String; const Query: RawByteString; const Header: AnsiString = '';
                                 const ErrMsg: String = ''; const ErrProc: TErrorProc = nil): Boolean;
var
  JSON: TJSONObject;
begin
  JSON := nil;
  Result := SendRequest(IsPOST, BaseURL, Query, RT_None, JSON, Header, ErrMsg, ErrProc);
end;

function TWIMSession.SendRequest(IsPOST: Boolean; const BaseURL: String; const Query: RawByteString; Ret: TReturnData; var JSON: TJSONObject;
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

procedure TWIMSession.SendRequestAsync(IsPOST: Boolean; const BaseURL: String; const Query: RawByteString; const Header: AnsiString = ''; HandlerProc: THandlerProc = nil);
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

function TWIMSession.SendPresenceState: Boolean;
var
  Query: RawByteString;
  BaseURL: String;
begin
  Result := False;
  BaseURL := WIM_HOST + 'presence/setState';
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
end; // SendWebStatusAndVis

procedure TWIMSession.SendStatusStr(const st: Byte; const StText: String = '');
var
  Query: UTF8String;
  BaseURL, TmpStr: String;
begin
  eventContact := nil;
  if not (st in [Low(XStatusArray)..High(XStatusArray)]) then
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
end; // SendWebStatusStr

//procedure TWIMSession.setStatusStr(s: String; Pic: String = '');
procedure TWIMSession.setStatusStr(xSt: byte; stStr: TXStatStr);
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

procedure TWIMSession.setStatusFull(st: byte; xSt : byte; stStr : TXStatStr);
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
    startingStatus    := TWIMStatus(st);
   end;

  if IsReady then
    begin
      curStatus := TWIMStatus(st);
    //  eventContact := myinfo;
      eventContact:= NIL;
      notifyListeners(IE_statuschanged);
    end
   else
    Connect;
end;

procedure TWIMSession.SendEccMSGsnac(const cnt: TWIMContact; const sn: RawByteString);
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
    PBKDF2_HMAC_SHA256(EccKey, not2Translate[2] + AIM_MD5_STRING + IntToHex(l1, 2) + u1 + IntToHex(l2, 2) + u2, 3, Key)
  else
  begin
    sr := MD5Pass(IntToHex(l1, 2) + (not2Translate[2]) + u1 + AIM_MD5_STRING);
    CopyMemory(@Key[0], @sr[1], SizeOf(TMD5Digest));

    sr := MD5Pass(IntToHex(l2, 2) + not2Translate[2] + u2 + AIM_MD5_STRING);
    CopyMemory(@Key[16], @sr[1], SizeOf(TMD5Digest));
  end;
end;

function TWIMSession.SendMsg(Cnt: TRnQContact; var Flags: dword; const Msg: String; var RequiredACK: Boolean): Integer;
begin
  Result := -1;
  SendMsgOrSticker(Cnt, flags, Msg, MSG_TEXT, RequiredACK);
end;

function TWIMSession.SendMsg2(Cnt: TRnQContact; var Flags: dword; const Msg: String; var RequiredACK: Boolean): RawByteString;
begin
  Result := SendMsgOrSticker(Cnt, flags, Msg, MSG_TEXT, RequiredACK);
end;

function TWIMSession.SendSticker2(Cnt: TRnQContact; var Flags: dword; const Msg: String; var RequiredACK: Boolean): RawByteString;
begin
  Result := SendMsgOrSticker(Cnt, flags, Msg, MSG_STICKER, RequiredACK);
end;

function TWIMSession.SendMsgOrSticker(Cnt: TRnQContact; var Flags: dword;
                                      const Msg: String; MsgType: TMsgType;
                                      var RequiredACK: Boolean): RawByteString;
const
  AESBLKSIZE = SizeOf(TAESBlock);
var
  c: TWIMContact;
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
begin
  Result := '';
  RequiredACK := false;
  if not IsReady then
    Exit;

  c := TWIMContact(Cnt);
  isBin := (Pos(RnQImageTag, msg) > 0) or ((Pos(RnQImageExTag, msg) > 0)) or (IF_Bin and flags > 0);
  if isBin then
    flags := flags or IF_Bin;

//  if not imVisibleTo(c) then
//    if addTempVisMsg then
//      AddTemporaryVisible(c); // TODO: New proto implementation

  IsSticker := MsgType = MSG_STICKER;
  if c.SendTransl and not isBin and not IsSticker then
    ReadyMsg := Translit(Msg)
  else
    ReadyMsg := Msg;

  Encrypted := 0;
  RequiredACK := True;

  ShouldEncrypt := (UseCryptMsg and (c.Crypt.supportCryptMsg or (fECCKeys.generated and UseEccCryptMsg and c.crypt.supportEcc))) and not isBin;
  if ShouldEncrypt and not IsSticker then
  begin
    Msg2 := TEncoding.UTF8.GetBytes(ReadyMsg);
    Len := Length(Msg2);
    CRC := ZipCrc32($FFFFFFFF, @Msg2[0], Len) XOR $FFFFFFFF;
    Compressed := 0;
    Msg2Enc := ZCompressBytes(Msg2);

    if Assigned(Msg2Enc) then
    if Length(Msg2Enc) < Len then
    begin
      Msg2 := Msg2Enc;
      Len := Length(Msg2Enc);
      Compressed := 1;
    end;

    CalcKey(fECCKeys.Generated and UseEccCryptMsg and c.Crypt.SupportEcc, c.Crypt.EccMsgKey, MyAccount, c.UID2cmp, 0, Len, Key);

    i := Len mod AESBLKSIZE;
    if (i > 0) then
    begin
      Len2 := Len + AESBLKSIZE - i;
      SetLength(Msg2, Len2);
      FillChar(Msg2[Len], AESBLKSIZE - i, 0);
    end else
      Len2 := Len;

    SetLength(CrptMsg, Len2);
    Ctx := TAESECB.Create(key[0], 256);
    Ctx.Encrypt(@Msg2[0], @CrptMsg[0], Len2);
    Ctx.Free;
    SetLength(Msg2, 0);
    Base64EncodeBytes(CrptMsg, Msg2);
    if fECCKeys.generated and UseEccCryptMsg and c.crypt.supportEcc then
      Encrypted := 2
    else
      Encrypted := 1;
    flags := flags or IF_Encrypt;

    if Encrypted = 2 then
      ReadyMsg := CreateDataPayload([
        Str2Hex('RDEC0' + Copy(c.Crypt.EccPubKey, 1, 11)),
        Str2Hex('RDEC1' + Copy(c.Crypt.EccPubKey, 12, 11)),
        Str2Hex('RDEC2' + Copy(c.Crypt.EccPubKey, 23, 11))
      ], Msg2, Compressed, CRC, Len)
    else if Encrypted = 1 then
      ReadyMsg := CreateDataPayload([Str2Hex(BigCapability[CAPS_big_CryptMsg].v)], Msg2, Compressed, CRC, Len);
  end else
  if UseCryptMsg and (CAPS_big_QIP_Secure in c.capabilitiesBig) and (c.Crypt.qippwd > 0) and not isBin then
  begin  // QIP crypt message
    // Still relevant?
(*
    Msg2Send := qip_msg_crypt(msg2send, c.Crypt.qippwd);
//    sutf := Length_DLE(GUIDToString(msgQIPpass));
    sutf := Length_DLE(msgQIPpassStr);
    flags := flags or IF_Encrypt;
*)
  end;

//  Result := addRef(REF_msg, c.UID2Cmp);
  Result := CreateNewGUID;
  RequiredACK := True;

  Params := TDictionary<String, String>.Create;
  Params.Add('f', 'json');
  Params.Add('aimsid', fSession.aimsid);
  Params.Add('t', c.UID2cmp);
//  Params.Add('r', IntToStr(Result));

  Params.Add('r', Result);
  // parts[quotes], mentions
  Params.Add(IfThen(IsSticker, 'stickerId', 'message'), ReadyMsg);
  // (is_sms)
  // 'displaySMSSegmentData':  'true'
  // else
  Params.Add('offlineIM', '1');
  Params.Add('notifyDelivery', 'true');
  BaseURL := WIM_HOST + IfThen(IsSticker, 'im/sendSticker', 'im/sendIM');


  Handler := procedure(RespStrR: RawByteString)
  var
    Tmp, tmp2: TJSONValue;
    JSON, data: TJSONObject;
    sID: String;
    lReqId: String;
    resp: TPair<Integer, String>;
  begin
    if ParseJSON(UTF8String(RespStrR), JSON) then
    try
      Resp := CheckResponseData(JSON, lReqId);

      if not Assigned(JSON) or (resp.key <> 200) then
        Exit;
      eventReqID := lReqId;
//      TJSONObject(tmp).GetValueSafe('requestId', sID);
//          if TryStrToInt(sID, eventInt) then
            begin
              data := TJSONObject(JSON).GetValue('data') AS TJSONObject;
              if not Assigned(data) then
                Exit;
              Tmp := data.GetValue('histMsgId');
              eventMsgID := StrToInt64(tmp.Value);
              Tmp := data.GetValue('state');
              if tmp <> NIL then
                eventMsgA := tmp.Value
               else
                eventMsgA := '';
              Tmp := data.GetValue('msgId');
              if tmp <> NIL then
                eventWID := tmp.Value
               else
                eventWID := '';
              notifyListeners(IE_serverAck);
            end;
    finally
      FreeAndNil(JSON);
    end;
  end;


  SendRequestAsync(True, BaseURL, MakeParams('POST', BaseURL, Params, False), 'Send ' + IfThen(IsSticker, 'sticker', 'message'), handler);
  Params.Free;
end; // SendMsg

function TWIMSession.SendSticker(const Cnt: TRnQContact; const sticker: String): RawByteString;
var
  f: DWord;
  ack: Boolean;
begin
  Result := '';
  if Assigned(Cnt) then
    Result := SendMsgOrSticker(Cnt, f, sticker, MSG_STICKER, ack);
end;

function TWIMSession.CreateDataPayload(Caps: TArray<RawByteString>; const Data: TBytes = nil; Compressed: Integer = -1; CRC: Cardinal = 0; Len: Integer = 0): String;
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

function TWIMSession.SendBuzz(Cnt: TRnQContact): Boolean;
var
  Params: TDictionary<String, String>;
  Pair: TJSONPair;
  c: TWIMContact;
  BaseURL: String;
begin
  Result := False;
  if not IsReady or (SecondsBetween(Now, buzzedLastTime) < 15) then
    Exit;

  BuzzedLastTime := Now;
  c := TWIMContact(Cnt);

  Params := TDictionary<String, String>.Create;
  try
    Params.Add('f', 'json');
    Params.Add('aimsid', fSession.aimsid);
    Params.Add('t', c.UID2Cmp);
//    Params.Add('r', IntToStr(AddRef(REF_msg, c.UID2Cmp)));
    Params.Add('r', CreateNewGUID);
    Params.Add('message', CreateDataPayload([Str2Hex(BigCapability[CAPS_big_Buzz].v)]));
    Params.Add('offlineIM', '1');
    Params.Add('notifyDelivery', 'true');
    BaseURL := WIM_HOST + 'im/sendIM';
    SendRequestAsync(True, BaseURL, MakeParams('POST', BaseURL, Params, False), 'Send buzz');
    Result := True;
  finally
    Params.Free;
  end;
end;

procedure TWIMSession.SendContacts(Cnt: TRnQContact; flags: DWord; cl: TRnQCList);
var
  s: RawByteString;
  c: TRnQContact;
begin
  if not IsReady then exit;
  if cl.empty then exit;

  //c:=GeTWIMContact(uin));
  if not imVisibleTo(Cnt) then
    if addTempVisMsg then
     addTemporaryVisible(TWIMContact(Cnt));

  s := IntToStr(TList(cl).count)+#$FE;
  for c in cl do
    s := s + UTF(c.UID2cmp) +#$FE + UTF(c.nick) + #$FE;
end; // SendContacts

procedure TWIMSession.SendQueryInfo(const uid: TUID);
var
  wpS: TWpSearch;
  c: TWIMContact;
begin
  if not IsReady then
    Exit;

  c := GetWIMContact(uid);
  if not Assigned(c) then
    Exit;
OutputDebugString(PChar('SendQueryInfo'));
  GetProfile(uid);
// TODO: White pages search... or just leave GetProfile()
//  wpS.uin := uid;
//  wpS.token := cnt.InfoToken;
//  SendWPSearch2(wpS, 0, False);
end; // sendQueryInfo

{procedure TWIMSession.sendQueryInfo(uin:TUID);
var
  wp : TwpSearch;
begin
  wp.uin := uin;
  sendWPsearch(wp, 0);
end; // sendQueryInfo}


procedure TWIMSession.GetProfile(const uid: TUID);
var
  JSON: TJSONObject;
  Query: UTF8String;
  BaseURL: String;
  user, groups: TJSONValue;
  users: TJSONArray;
begin
  if not IsReady or (UID = '') then
    Exit;

  BaseURL := WIM_HOST + 'presence/get';
  Query := '&mdir=1' +
           '&t=' + ParamEncode(String(UID)) +
           AllFieldsAsQuery;
  if SendSessionRequest(False, BaseURL, Query, RT_JSON, JSON, 'Contact info') then
  try
    ProcessUsersAndGroups(JSON);
  finally
    JSON.Free;
  end;

  GetContactAttrs(UID);
end;

procedure TWIMSession.GetContactAttrs(const UID: TUID);
var
  c: TWIMContact;
  JSON: TJSONObject;
  Query: UTF8String;
  BaseURL: String;
begin
  BaseURL := WIM_HOST + 'buddylist/getBuddyAttribute';
  Query := '&buddy=' + ParamEncode(String(UID));
  if SendSessionRequest(False, BaseURL, Query, RT_JSON, JSON, 'Get contact [' + String(UID) + '] attributes') then
  try
    c := getWIMContact(UID);
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
end;

procedure TWIMSession.SendContactAttrs(c: TWIMContact);
var
  Query: UTF8String;
  BaseURL: String;
  Params: TDictionary<String, String>;
begin
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
end;

procedure TWIMSession.GetContactInfo(const uid: TUID; const IncludeField: String);
var
  JSON: TJSONObject;
  Query: UTF8String;
  BaseURL: String;
  user: TJSONValue;
  users: TJSONArray;
begin
  if not IsReady or (IncludeField = '') then
    Exit;

  BaseURL := WIM_HOST + 'presence/get';
  Query := '&mdir=0&t=' + ParamEncode(String(UID)) +
           '&' + IncludeField + '=1'; // No profile, but still some other fields are there
  if SendSessionRequest(False, BaseURL, Query, RT_JSON, JSON, 'Get contact [' + String(UID) + '] info [' + IncludeField + ']') then
  try
    ProcessUsersAndGroups(JSON);
  finally
    JSON.Free;
  end;
end;

procedure TWIMSession.GetCL;
var
  JSON: TJSONObject;
  Query: UTF8String;
  BaseURL: String;
begin
  if not IsReady then
    Exit;

//  BaseURL := WIM_HOST + 'buddylist/get';
//  Query := '&includeBuddies=0'; // groups+users or groups only

  BaseURL := WIM_HOST + 'presence/get';
  Query := '&mdir=1' +
           '&bl=1' +
           AllFieldsAsQuery;
  if SendSessionRequest(False, BaseURL, Query, RT_JSON, JSON, 'Get CL', 'Failed to get CL') then
  try
    ProcessContactList(JSON.GetValue('groups') as TJSONArray);
  finally
    JSON.Free;
  end;
end;

procedure TWIMSession.FindContact;
var
//  JSON: TJSONObject;
  Query: UTF8String;
  BaseURL: String;
begin
  if not IsReady then
    Exit;

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

procedure TWIMSession.ValidateSid;
var
  Query: UTF8String;
  BaseURL: String;
begin
  if not IsReady then
    Exit;

  BaseURL := WIM_HOST + 'aim/validateSid';
  SendSessionRequest(False, BaseURL, '', 'Validate AimSid');
end;

procedure TWIMSession.GetExpressions(const uid: TUID); // Avatars only?
var
  Query: UTF8String;
  BaseURL: String;
begin
  BaseURL := WIM_HOST + 'expressions/get2'; // expressions/get
  Query := 'f=json' +
           '&t=' + ParamEncode(String(uid));
  SendRequest(False, BaseURL, Query, 'Get expressions');
end;

procedure TWIMSession.GetAllCaps;
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

  BaseURL := WIM_HOST + 'presence/get';
  Query := '&capabilities=1';
  if fRoster.Count > 0 then
    for Cnt in fRoster do
      if not (TWIMContact(cnt).Status in [SC_OFFLINE, SC_UNK]) then
        Query := Query + '&t=' + String(Cnt.UID2cmp);
  if SendSessionRequest(True, BaseURL, Query, RT_JSON, JSON, 'Get caps for all online contacts') then
  try
    ProcessUsersAndGroups(JSON);
  finally
    JSON.Free;
  end;
end;

procedure TWIMSession.Test;
var
  Query: UTF8String;
  BaseURL: String;
//  Params: TDictionary<String, String>;
begin
  BaseURL := WIM_HOST + 'aim/getSMSInfo';
  Query := '&phone=911';
  SendSessionRequest(True, BaseURL, Query, 'Test');

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

procedure TWIMSession.GetStoreStickerPacks;
var
  BaseURL: String;
  Params: TDictionary<String, String>;
  Handler: THandlerProc;
begin
  if RequiresLogin then
    Exit;

  BaseURL := STORE_HOST + 'openstore/contentlist';
  Params := TDictionary<String, String>.Create();
  Params.Add('a', fSession.token);
  Params.Add('f', 'json');
  Params.Add('k', fSession.DevId);
  Params.Add('ts', IntToStr(DateTimeToUnix(Now, False) - fSession.hostOffset));
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
end;

procedure TWIMSession.SearchStoreStickerPacks(const Query: String);
var
  BaseURL: String;
  Params: TDictionary<String, String>;
  Handler: THandlerProc;
begin
  if RequiresLogin then
    Exit;

  BaseURL := STORE_HOST + 'store/showcase';
  Params := TDictionary<String, String>.Create();
  Params.Add('a', fSession.Token);
  Params.Add('f', 'json');
  Params.Add('k', fSession.DevId);
  Params.Add('ts', IntToStr(DateTimeToUnix(Now, False) - fSession.HostOffset));
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
end;

function TWIMSession.GetStoreStickerPack(const PackId: String): TStickerPack;
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

procedure TWIMSession.BuyStickerPack(const PackId: String);
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

procedure TWIMSession.RemoveStickerPack(const PackId: String);
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

procedure TWIMSession.SendSMS(const Dest, Msg: String; Ack: Boolean);
begin
  if not IsReady then
     Exit;

  // TODO?
end; // sendSMS

procedure TWIMSession.SendSaveMyInfo(c: TWIMContact);
var
  BaseURL: String;
  Params: TDictionary<String, String>;
begin
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
end;

procedure TWIMSession.notificationForMsg(msgType: Byte; flags: Byte; urgent: Boolean; const msg: RawByteString{; offline:boolean = false});
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

procedure TWIMSession.parsePagerString(s: RawByteString);
begin
  eventNameA := chop(#$FE, s);
  chop(#$FE, s);
  chop(#$FE, s);
  eventAddress := UnUTF(chop(#$FE, s));
  chop(#$FE, s);
  eventMsgA := s;
end; // parsePagerString




procedure TWIMSession.OnProxyError(Sender: TObject; Error: Integer; const Msg: String);
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


function TWIMSession.GetMyCaps: RawByteString;
var
  s: RawByteString;
begin
  Result := Str2Hex(CAPS_sm2big(CAPS_sm_Emoji));
  Result := Result + ',' + Str2Hex(CAPS_sm2big(CAPS_sm_UniqueID));
  Result := Result + ',' + Str2Hex(CAPS_sm2big(CAPS_sm_MailNotify));
//  Result := Result + ',' + Str2Hex(CAPS_sm2big(CAPS_sm_IntroDlgStates)); // intro/tail messages
  Result := Result + ',' + Str2Hex(CAPS_sm2big(CAPS_sm_UTF8));
  Result := Result + ',' + Str2Hex(BigCapability[CAPS_big_Buzz].v);

//  if ShowClientID then
//    Result := Result + ',' + Str2Hex(BigCapability[CAPS_big_Build].v);
  if SupportTypingNotif then
    Result := Result + ',' + Str2Hex(BigCapability[CAPS_big_MTN].v);
  if AvatarsSupport then
    Result := Result + ',' + Str2Hex(CAPS_sm2big(CAPS_sm_Avatar));

  // What are thoooooose?!
  //Result := Result + ',' + '094613584C7F11D18222444553540000';
  //Result := Result + ',' + '0946135C4C7F11D18222444553540000';
  //Result := Result + ',' + '0946135E4C7F11D18222444553540000';

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

    Result := Result + ',' + Str2Hex(BigCapability[CAPS_big_CryptMsg].v);
//    Result := Result + ',' + Str2Hex(BigCapability[CAPS_big_QIP_Secure].v); // QIP protect message
  end;

//  if (curXStatus > 0) and not (XStatusArray[curXStatus].pidOld = '') then
//    Result := Result + ',' + Str2Hex(XStatusArray[curXStatus].pidOld);

  if AddExtCliCaps and (Length(ExtClientCaps) = 16) then
    Result := Result + ',' + Str2Hex(ExtClientCaps);
end;

function TWIMSession.RemoveContact(c: TRnQContact): Boolean;
var
  IsLocal: Boolean;
begin
  IsLocal := c.CntIsLocal or (c.group = 0);
  Result := NotInList.remove(c);
  Result := fRoster.remove(c) or Result;
  if Result then
  begin
    RemoveFromVisible(TWIMContact(c));
    if not IsLocal and IsReady then
      SendRemoveContact(TWIMContact(c));
    TWIMContact(c).status := SC_UNK;
    c.SSIID := 0;
    eventInt := TList(fRoster).Count;
    notifyListeners(IE_numOfContactsChanged);
  end
end;

procedure TWIMSession.RemoveContactFromServer(c: TWIMContact);
begin
  if IsReady then
    SendRemoveContact(c);
  eventContact := c;
  notifyListeners(IE_contactupdate);
end;
{
procedure TWIMSession.SetStatus(s:TWIMStatus; vis: Tvisibility);
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
procedure TWIMSession.SetStatus(st: Byte);
var
  savedSt: TWIMStatus;
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
    StartingStatus := TWIMStatus(st);
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
    CurStatus := TWIMStatus(st);
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

procedure TWIMSession.SetStatus(st: Byte; vi: Byte);
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
    StartingStatus := TWIMStatus(st);
  end;

  if not (vi = Byte(Visibility)) then
  begin
    eventOldInvisible := IsInvisible;
    StartingVisibility := TVisibility(vi);
  end;

  if IsReady then
  begin
    CurStatus := TWIMStatus(st);
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

function TWIMSession.GetStatus: Byte;
begin
  Result:= Byte(CurStatus)
end;

function TWIMSession.GetXStatus: Byte;
begin
  Result := CurXStatus;
end;

function TWIMSession.getStatusName: String;
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

function TWIMSession.getStatusImg: TPicName;
begin
  if False{XStatusAsMain} and (curXStatus > 0) then
    Result := XStatusArray[curXStatus].PicName
   else
    begin
     result := status2imgName(byte(curStatus), isInvisible);
    end;
end;

function TWIMSession.GetVisibility: Byte;
begin
  Result := Byte(fVisibility)
end;

//function TWIMSession.validUid(var uin:TUID):boolean;
(*function TWIMSession.validUid1(const uin:TUID):boolean;
//var
// i : Int64;
// k : Integer;
// fUIN : Int64;
begin
 Result := TWIMSession._isValidUid1(uin);
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

{class function TWIMSession.GetId: Word;
begin
  result := 0;
end;}

class function TWIMSession._GetProtoName: string;
begin
  result := 'WIM';
end;

class function TWIMSession._getDefHost : Thostport;
begin
  Result.host := //'login.icq.com';
                 ICQServers[0];
  Result.Port := 5190;
end;

function TWIMSession.GetWIMContact(const uid: TUID): TWIMContact;
begin
  Result := TWIMContact(contactsDB.add(Self, uid));
end;

function TWIMSession.GetWIMContact(const uin: Integer): TWIMContact;
begin
//  result := TWIMContact(contactsDB.get(TWIMContact, uin));
  result := TWIMContact(contactsDB.add(Self, IntToStr(uin)));
end;

class function TWIMSession._IsValidPhone(const Phone: TUID): Boolean;
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
end;

class function TWIMSession._isProtoUid(var uin: TUID): boolean; //Static;
//function TWIMSession.isValidUid(var uin:TUID):boolean; //Static;
var
// i: Int64;
 k: Integer;
 fUIN: Int64;
 temp: TUID;
begin
  Result := False;
  temp := TWIMContact.trimUID(uin);
  if Length(Temp) = 0 then
    Exit;
  if temp[1] = '+' then
    Exit(_IsValidPhone(temp));

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

//class function isValidUid(var uin: TUID): boolean; override;
class function TWIMSession._isValidUid1(const uin: TUID): boolean; //Static;
//function TWIMSession.isValidUid(var uin: TUID): boolean; //Static;
var
// i: Int64;
 k: Integer;
 fUIN: Int64;
 temp: TUID;
begin
  Result := False;
  temp := TWIMContact.trimUID(uin);
  if Length(temp) = 0 then
    Exit;
  val(temp, fuin, k);
  if k = 0 then
    begin
      result := True;
//      uin := unFakeUIN(fuin)
    end
   else
     if not(temp[1] in ['0'..'9']) then
       Result := True;
    ;
end;

procedure TWIMSession.AddContactToCL(var c: TWIMContact);
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

procedure TWIMSession.AddContactsToCL(cl: TRnQCList);
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

function TWIMSession.AddContact(c: TRnQContact; IsLocal: Boolean = False): boolean;
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
      if TWIMContact(c).Status = SC_UNK then
        TWIMContact(c).Status := SC_OFFLINE;
      TWIMContact(c).InvisibleState := 0;
      if not isLocal then
      begin
        if c.isInRoster then
        begin
          c.SSIID := 0;
          SendAddContact(TWIMContact(c))
        end else
          c.CntIsLocal := True;
      end;
    end;
    eventInt := TList(fRoster).Count;
    notifyListeners(IE_numOfContactsChanged);
  end else
    //SSI_UpdateGroup(TWIMContact(c));
end; // AddContact

function TWIMSession.ReadList(l: TLIST_TYPES): TRnQCList;
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

procedure TWIMSession.AddToList(l: TLIST_TYPES; cl: TRnQCList);
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

procedure TWIMSession.RemFromList(l: TLIST_TYPES; cl: TRnQCList);
begin
 case l of
//   LT_ROSTER:   //removeContact( addContact(cl);
   LT_VISIBLE:   removeFromVisible(cl);
   LT_INVISIBLE: removeFromInvisible(cl);
   LT_TEMPVIS:   removeTemporaryVisible(cl);
//   LT_SPAM:      result := spamList;
 end;
end;

procedure TWIMSession.AddToList(l: TLIST_TYPES; cnt: TRnQcontact);
begin
 case l of
   LT_ROSTER:   addContact(TWIMContact(cnt));
   LT_VISIBLE:   add2visible(TWIMContact(cnt));
   LT_INVISIBLE: add2invisible(TWIMContact(cnt));
   LT_TEMPVIS:   addTemporaryVisible(TWIMContact(cnt));
   LT_SPAM:      add2ignore(TWIMContact(cnt));
 end;
end;
procedure TWIMSession.RemFromList(l: TLIST_TYPES; cnt: TRnQcontact);
begin
 case l of
   LT_ROSTER:   removeContact(TWIMContact(cnt));
   LT_VISIBLE:   removeFromVisible(TWIMContact(cnt));
   LT_INVISIBLE: removeFromInvisible(TWIMContact(cnt));
   LT_TEMPVIS:   removeTemporaryVisible(TWIMContact(cnt));
   LT_SPAM:      remFromIgnore(TWIMContact(cnt));
 end;
end;

function TWIMSession.isInList(l: TLIST_TYPES; cnt: TRnQContact): Boolean;
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

function TWIMSession.add2visible(c: TWIMContact): boolean;
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

procedure TWIMSession.add2visible(cl: TRnQCList; OnlyLocal: Boolean = false);
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

function TWIMSession.add2ignore(c: TWIMContact): boolean;
var
  Query: UTF8String;
  BaseURL: String;
begin
  Result := False;
  if IsReady then
  begin
    BaseURL := WIM_HOST + 'preference/setPermitDeny';
    Query := '&pdIgnore=' + ParamEncode(String(c.UID2Cmp));
    Result := SendSessionRequest(False, BaseURL, Query, 'Add to ignore list');
  end;
end;

function TWIMSession.remFromIgnore(c: TWIMContact): boolean;
var
  Query: UTF8String;
  BaseURL: String;
begin
  Result := False;
  if IsReady then
  begin
    BaseURL := WIM_HOST + 'preference/setPermitDeny';
    Query := '&pdIgnoreRemove=' + ParamEncode(String(c.UID2Cmp));
    Result := SendSessionRequest(False, BaseURL, Query, 'Remove from ignore list');
  end;
end;

procedure TWIMSession.GetPermitDeny;
var
  JSON: TJSONObject;
  Query: UTF8String;
  BaseURL: String;
begin
  if not IsReady then
    Exit;

  BaseURL := WIM_HOST + 'preference/getPermitDeny';
  Query := '';
  if SendSessionRequest(False, BaseURL, Query, RT_JSON, JSON, 'Get permit/deny lists') then
  try
    ProcessPermitDeny(JSON);
  finally
    JSON.Free;
  end;
end;

procedure TWIMSession.SetPermitDenyMode(const Mode: String);
var
  JSON: TJSONObject;
  Query: UTF8String;
  BaseURL: String;
begin
  if not IsReady then
    Exit;

  BaseURL := WIM_HOST + 'preference/setPermitDeny';
  Query := '&pdMode=' + Mode;
  if SendSessionRequest(False, BaseURL, Query, RT_JSON, JSON, 'Set permit/deny mode') then
  try
    //ProcessPermitDeny(JSON);
  finally
    JSON.Free;
  end;
end;

procedure TWIMSession.AddToBlock(const c: String); // Unused
var
  Query: UTF8String;
  BaseURL: String;
begin
  if not IsReady then
    Exit;

  BaseURL := WIM_HOST + 'preference/setPermitDeny';
  Query := '&pdBlock=' + ParamEncode(c);
  SendSessionRequest(False, BaseURL, Query, 'Add contact to block list');
end;

procedure TWIMSession.RemFromBlock(const c: String); // Unused
var
  Query: UTF8String;
  BaseURL: String;
begin
  if IsReady then
  begin
    BaseURL := WIM_HOST + 'preference/setPermitDeny';
    Query := '&pdBlockRemove=' + ParamEncode(c);
    SendSessionRequest(False, BaseURL, Query, 'Remove contact from block list');
  end;
end;

procedure TWIMSession.SetMuted(c: TWIMcontact; Mute: Boolean);
var
  Query: UTF8String;
  BaseURL: String;
begin
  if IsReady then
  begin
    BaseURL := WIM_HOST + 'buddylist/Mute';
    Query := '&buddy=' + c.UID2Cmp +
             '&eternal=' + IfThen(Mute, '1', '0');
    SendSessionRequest(False, BaseURL, Query, '(Un)mute contact');
  end;
end;

function TWIMSession.RemoveFromVisible(c:TWIMContact):boolean;
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

procedure TWIMSession.removeFromVisible(const cl: TRnQCList);
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

function TWIMSession.add2invisible(c: TWIMContact): boolean;
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

procedure TWIMSession.add2invisible(cl: TRnQCList; OnlyLocal: Boolean = false);
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

function TWIMSession.RemoveFromInvisible(c: TWIMContact): boolean;
begin
  Result := False;
  if c = nil then
    Exit;
  RemoveTemporaryVisible(c);
  Result := True;
  if IsReady then
    //SSI_DelVisItem(c.UID, FEEDBAG_CLASS_ID_DENY);
end; // RemoveFromInvisible

procedure TWIMSession.removeFromInvisible(const cl: TRnQCList);
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

function TWIMSession.AddTemporaryVisible(c: TWIMContact): Boolean;
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

function TWIMSession.AddTemporaryVisible(cl: TRnQCList): Boolean;
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

function TWIMSession.RemoveTemporaryVisible(c: TWIMContact): boolean;
begin
  Result := tempvisibleList.remove(c);
  if not Result or not IsReady then
    Exit;
  //SSIsendDelTempVisible(c.buin);
  eventContact := c;
  notifyListeners(IE_visibilityChanged);
end; // RemoveTemporaryVisible

function TWIMSession.RemoveTemporaryVisible(cl: TRnQCList): boolean;
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

procedure TWIMSession.ClearTemporaryVisible;
begin
  RemoveTemporaryVisible(tempVisibleList)
end;

function TWIMSession.useMsgType2for(c: TWIMContact): boolean;
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

procedure TWIMSession.SendCreateUIN(const AcceptKey: RawByteString);
begin
  // TODO? New proto can do this?
end; // sendCreateUIN

function TWIMSession.UploadAvatar(const fn: TFileName; cnt: TRnQContact = NIL; chat: Boolean = false): Boolean;
var
  Query: RawByteString;
  BaseURL: String;
  buf: RawByteString;
  json: TJSONObject;
  lReqId, iconId: String;
begin
  Result := False;
  BaseURL := WIM_HOST + 'expressions/upload';
  Query := 'f=json&aimsid=' + ParamEncode(fSession.aimsid) + '&r=' + CreateNewGUID;
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
end;

function TWIMSession.maxCharsFor(const c: TRnQcontact; isBin: Boolean = false): integer;
begin
{  if not c.isOnline then
//  Result := 450
  Result := 1000
  else}
//  if useMsgType2for(TWIMContact(c)) then
    Result := 7000
//  else
//    Result := 2540
   ;

  with TWIMContact(c) do
  begin
    if not isBin then
      Result := Result div 2;
    if UseCryptMsg and (Crypt.supportCryptMsg or (UseEccCryptMsg and fECCKeys.generated and Crypt.supportEcc)) then
      Result := Result * 3 div 4;
  end;
end; // maxCharsFor

function TWIMSession.imVisibleTo(c: TRnQcontact): boolean;
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

function TWIMSession.GetLocalIPStr: String;
begin
//  try
   if compareText(result, 'error') = 0 then result:='';
//  except
//    result:='';
//  end;
end; // getLocalIPstr

function TWIMSession.getLocalIP: integer;
begin
  try
    Result := 0;
  except
    Result := 0;
  end;
end;

function TWIMSession.CreateNewGUID: String;
//var
//  UID: TGUID;
begin
//  CreateGuid(UID);
  Result := String(CreateGUID).Trim(['{', '}']).ToLower;
end;

procedure TWIMSession.SetWebAware(value: boolean);
begin
  P_webaware := value;
end; // setWebaware

procedure TWIMSession.SetAuthNeeded(value: boolean);
begin
  P_authNeeded := value;
end; // setAuthNeeded

function TWIMSession.IsInvisible: Boolean;
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

function TWIMSession.dontBotherStatus: boolean;
begin
  result := getStatus in [byte(SC_occupied)]
end;

function TWIMSession.serverPort: word;
begin
  Result := 0;
end;

function TWIMSession.serverStart: word;
begin
  Result := serverPort;
end; // serverStart

function TWIMSession.RequestPasswordIfNeeded(DoConnect: Boolean = True): Boolean;
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

procedure TWIMSession.Connect;
begin
  if not IsOffline then
    Exit;

  if RequestPasswordIfNeeded then
    Exit;

  if IsMobileAccount then
    phase := connecting_sms_
   else
    phase := connecting_;
  eventAddress := WIM_HOST;
  notifyListeners(IE_connecting);
  reqId := 1;

  if StartSession then
    AfterSessionStarted
  else
    GoneOffline;
end; // Connect

procedure TWIMSession.AfterSessionStarted;
begin
  curStatus := StartingStatus;
  StartPolling;
  if LastStatus = Byte(SC_OFFLINE) then
    SetStatus(Byte(SC_ONLINE), Byte(VI_normal))
  else if not ExitFromAutoaway then
    SetStatus(Byte(LastStatus), Byte(Visibility));
end;

function TWIMSession.MakeParams(const Method: AnsiString; const BaseURL: String; const Params: TDictionary<String, String>; Sign: Boolean = True; DoublePercent: Boolean = False): String;
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
    Result := Result + '&sig_sha256=' + ParamEncode(Hash256String(fSession.secretenc64, hash));
  end;
end;

procedure TWIMSession.OpenICQURL(URL: String);
var
  BaseURL: String;
  Params: TDictionary<String, String>;
begin
  if fSession.token = '' then
  begin
    OpenURL(URL);
    Exit;
  end;

  BaseURL := 'https://www.icq.com/karma_api/karma_client2web_login.php';

  Params := TDictionary<String, String>.Create();
  Params.Add('ts', IntToStr(DateTimeToUnix(Now, False) - fSession.hostOffset));
  Params.Add('owner', MyAccNum);
  Params.Add('a', fSession.token);
  Params.Add('k', fSession.devid);
  Params.Add('d', URL);
  OpenURL(BaseURL + '?' + MakeParams('GET', BaseURL, Params));
  Params.Free;
end;

function TWIMSession.ClientLogin: Boolean;
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

  if phase = login_sms_ then
  begin
    fSession.secretenc64 := '';
    BaseURL := SMS_REG + 'requestPhoneValidation.php';
    Query := 'locale=ru' +
             '&msisdn=' + ParamEncode(MyAccNum) +
             '&smsFormatType=human' +
             '&k=' + fSession.DevId +
             '&r=' + CreateNewGUID;

    ErrHandler := procedure(Resp: TPair<Integer, String>)
    begin
      ResetSession;
      eventInt := Resp.Key;
      eventMsgA := GetTranslation(Resp.Value);
      if Resp.Key = Integer(EAC_Unknown) then
        eventError := EC_Login_Seq_Failed
      else
        eventError := EC_other;
      NotifyListeners(IE_error);
    end;

    if SendRequest(False, BaseURL, Query, RT_JSON, JSON, 'Request SMS code', '', ErrHandler) then
    try
      JSON.GetValueSafe('trans_id', TransId);

      SMSCode := '';
      InputQuery(GetTranslation('Phone login'), GetTranslation('Enter SMS code'), SMSCode);

      if (Trim(SMSCode) = '') or not IsOnlyDigits(SMSCode) then
      begin
        ResetSession;
        Exit;
      end;

      BaseURL := SMS_REG + 'loginWithPhoneNumber.php';
      Query := '&msisdn=' + ParamEncode(MyAccNum) +
//               '&locale=ru' +
               '&trans_id=' + ParamEncode(TransId) +
               '&k=' + fSession.DevId +
               '&r=' + CreateNewGUID +
               'f=json' +
               '&sms_code=' + Trim(SMSCode) +
               '&create_account=1'
               ;

      if SendRequest(False, BaseURL, Query, RT_JSON, JSON, 'Login using phone and create auth data', '', ErrHandler) then
      begin
        Result := True;
        if JSON.GetValueSafe('phone_verified', lPhone_verified) and not lPhone_verified then
          msgDlg('The phone is not verified', True, mtWarning, MyAccNum);

        JSON.GetValueSafe('sessionKey', fSession.secretenc64);
        fSession.tokenTime := DateTimeToUnix(Now, False);

        if not (JSON.GetValue('hostTime') = nil) then
          fSession.hostOffset := DateTimeToUnix(Now, False) - StrToInt(JSON.GetValue('hostTime').Value)
        else
          fSession.hostOffset := 0;
        if not (JSON.Values['token'] = nil) then
         with JSON.Values['token'] do
          begin
            GetValueSafe('a', fSession.token);
            GetValueSafe('expiresIn', fSession.tokenExpIn);
          end;
        if JSON.Values['loginId'] <> NIL then
          begin
            myAccount := JSON.Values['loginId'].Value;
          end;

      end;
    finally
      FreeAndNil(JSON);
    end;
  end
    else
  begin
    BaseURL := LOGIN_HOST + 'auth/clientLogin';
    Query := 'f=json' +
             '&clientName=' + ParamEncode(IfThen(ShowClientID, 'R&Q', 'Mail.ru Windows ICQ')) +
             '&clientVersion=' + IfThen(ShowClientID, '0.11.9999.' + IntToStr(RnQBuild) , '10.0.12393') +
             '&devId=' + fSession.devid +
             '&tokenType=longterm' +
             '&s=' + ParamEncode(String(MyAccNum)) +
             '&pwd=' + ParamEncode(fPwd);

    ErrHandler := procedure(Resp: TPair<Integer, String>)
    begin
      ResetSession;
      eventInt := Resp.Key;
      eventMsgA := GetTranslation(Resp.Value);
      if Resp.Key = Integer(EAC_Unknown) then
        eventError := EC_Login_Seq_Failed
      else if Resp.Key = Integer(EAC_Wrong_Login) then
        eventError := EC_badPwd
      else
        eventError := EC_other;
      NotifyListeners(IE_error);
    end;

    if SendRequest(True, BaseURL, Query, RT_JSON, JSON, 'Login using UIN and create auth data', '', ErrHandler) then
    try
      Result := True;
      JSON.GetValueSafe('sessionSecret', fSession.secret);
      fSession.tokenTime := DateTimeToUnix(Now, False);

      if not (JSON.GetValue('hostTime') = nil) then
        fSession.hostOffset := DateTimeToUnix(Now, False) - StrToInt(JSON.GetValue('hostTime').Value)
       else
        fSession.hostOffset := 0;
      if not (JSON.GetValue('token') = nil) then
        with JSON.GetValue('token') do
         begin
           GetValueSafe('a', fSession.token);
           GetValueSafe('expiresIn', fSession.tokenExpIn);
         end;
     finally
       FreeAndNil(JSON);
    end;
  end;
{
  BaseURL := 'https://icq.com/siteim/icqbar/php/proxy_jsonp_connect.php';
  query := 'username=' + String(MyAccNum) + '&password=' + fPwd + '&time=' + IntToStr(DateTimeToUnix(Now, False)) + '&remember=1';
  LoggaWIMPkt('[POST] Login and create session', WL_sent_text, BaseURL + '?' + query);
//  LoggaWIMPkt('[POST] Login and create session', WL_sent_text, 'https://icq.com/siteim/icqbar/php/proxy_jsonp_connect.php?[...]');
  fs := TMemoryStream.Create;
  LoadFromUrl(BaseURL, fs, 0, False, True, query);
  SetLength(session, fs.Size);
  fs.ReadBuffer(session[1], fs.Size);
  fs.Clear;

  LoggaWIMPkt('[POST] Login and create session', WL_rcvd_text, session);

  try
    json := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes(session)) as TJSONObject;
    if Assigned(json) then
    if json.GetValue('statusCode').Value = '200' then
    begin
      fDevId := json.GetValue('k').Value;
      fSessionKey := json.GetValue('sessionKey').Value;
      fSessionToken := json.GetValue('a').Value;
      fSessionTokenTime := StrToInt(json.GetValue('ts').Value);
      if not (json.GetValue('tsDelta') = nil) then
        fHostOffset := StrToInt(json.GetValue('tsDelta').Value)
      else
        fHostOffset := 0;
    end;
    FreeAndNil(json);
}
  if phase = login_sms_  then
  begin
    if fSession.secretenc64 = '' then
    begin
      ODS('Not enough data to login!');
      Exit;
    end;
  end
    else
      begin
       if (getPwd = '') or (fSession.secret = '') or (fSession.token = '') then
        begin
          OutputDebugString(PChar('Not enough data to login!'));
          Exit;
        end;
      fSession.secretenc64 := Hash256String(UTF(getPwd), UTF(fSession.secret));
     end;
end;

function TWIMSession.StartSession: Boolean;
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

  if RequiresLogin and not UsingSaved then
  begin
    eventInt := Integer(EAC_Not_Enough_Data);
    eventMsgA := '';
    eventError := EC_other;
    notifyListeners(IE_error);
    Exit;
  end;

  // Start session
  BaseURL := WIM_HOST + 'aim/startSession';
  UnixTime := IntToStr(DateTimeToUnix(Now, False) - fSession.hostOffset);

  AutoCaps := '';


//  if AddExtCliCaps and (Length(ExtClientCaps) = 16) then
//    Caps := Caps + ',' + Str2Hex(ExtClientCaps);

  Params := TDictionary<String, String>.Create();
  Params.Add('f', 'json');
  Params.Add('k', fSession.devid);
  Params.Add('a', fSession.token);
  Params.Add('clientName', IfThen(ShowClientID, 'R&Q', 'Mail.ru Windows ICQ'));
  Params.Add('clientVersion', IfThen(ShowClientID, IntToStr(RnQBuild), '5000'));
  Params.Add('majorVersion', IfThen(ShowClientID, '0', '100'));
  Params.Add('minorVersion', IfThen(ShowClientID, '11', '0'));
  Params.Add('buildNumber', IfThen(ShowClientID, '9999', '12393'));
  Params.Add('pointVersion', IfThen(ShowClientID, IntToStr(RnQBuild), '0'));
//  Params.Add('c', 'WebIM.jscb_tmp_c38690'); // callback
  Params.Add('assertCaps', GetMyCaps);
  Params.Add('interestCaps', AutoCaps);
  Params.Add('ts', UnixTime);
  Params.Add('imf', 'plain');
  Params.Add('invisible', IfThen(Visibility = VI_invisible, 'true', 'false'));
  Params.Add('inactiveView', 'offline');
  // Full invisibility is not working, "offline" presence event is still being sent to others when starting/ending session
  Params.Add('view', IfThen(Visibility = VI_invisible, 'invisible', 'online'));
  Params.Add('activeTimeout', '180');
  Params.Add('mobile', '0');
  Params.Add('rawMsg', '0');
  Params.Add('language', 'en-us');
  Params.Add('deviceId', 'dev1');
  Params.Add('sessionTimeout', '7776000'); // 90 days
  Params.Add('events', 'myInfo,presence,buddylist,typing,dataIM,userAddedToBuddyList,service,webrtcMsg,mchat,hist,hiddenChat,diff,permitDeny,imState,notification,apps' + ',offlineIM,sentIM,alert');
  Params.Add('includePresenceFields', AllFieldsAsParam);
//  Params.Add('nonce', UnixTime + '-' + nonce);

  ErrHandler := procedure(Resp: TPair<Integer, String>)
  begin
    if ((Resp.Key = Integer(EAC_Auth_Required)) or (Resp.Key = Integer(EAC_Wrong_DevKey))) and UsingSaved then
    begin
      Relogin := True;
      ResetSession;
      RequestPasswordIfNeeded(False);
      ProcResult := StartSession;
    end else
    begin
      SeqFailed := True;
      eventInt := Resp.Key;
      eventMsgA := GetTranslation(Resp.Value);
      if Resp.Key = Integer(EAC_Unknown) then
        eventError := EC_Login_Seq_Failed
      else
        eventError := EC_other;
      notifyListeners(IE_error);
    end;
  end;

  if SendRequest(True, BaseURL, MakeParams('POST', BaseURL, Params), RT_JSON, JSON, 'Start session', '', ErrHandler) then
  try

    ProcResult := JSON.GetValueSafe('aimsid', sU);
    fSession.aimsid := sU;
    ProcResult := ProcResult and JSON.GetValueSafe('fetchBaseURL', sU);
    fSession.fetchURL := sU;
    ProcResult := ProcResult and JSON.GetValueSafe('ts', ts);
    LastFetchBaseURL := fSession.fetchURL;
    fSession.hostOffset := DateTimeToUnix(Now, False) - ts;
    ProcResult := ProcResult and (LastFetchBaseURL > '');
    val := JSON.getValue('myInfo');
    if val is TJSONObject then
      begin
//       FreeAndNil(JSON);
       JSON := val as TJSONObject;
       ProcessContact(JSON)
      end;
  finally
    FreeAndNil(JSON);
  end;

  Result := ProcResult;
  Params.Free;

  if Relogin then
    Exit;

  if SeqFailed then
  begin
    ResetSession;
    Exit;
  end;

  phase := settingup_;
  notifyListeners(IE_connected);

  if Result then
  begin
    BaseURL := WIM_HOST + 'timezone/set';
    Query := '&TimeZoneOffset=' + IntToStr(DateTimeToUnix(Now, True) - (DateTimeToUnix(Now, False) + fSession.hostOffset));
    SendSessionRequest(False, BaseURL, Query, 'Set timezone');
  end;

  notifyListeners(IE_almostOnline);
Exit;
  // REST token
  BaseURL := REST_HOST + 'genToken';
  UnixTime := IntToStr(DateTimeToUnix(Now, False) - fSession.hostOffset);

//  params.Clear;
  Params := TDictionary<String, String>.Create();
  params.Add('a', fSession.token);
  params.Add('k', fSession.devid);
  params.Add('ts', UnixTime);

  SendRequest(True, BaseURL, MakeParams('POST', BaseURL, Params), RT_JSON, JSON, 'Generate REST auth token', '');
  params.Free;

  if Assigned(JSON) then
  try
    if JSON.GetValue('results') = nil then
    begin
      fSession.restToken := '';
      LoggaWIMPkt('[POST] REST auth token', WL_rcvd_text, 'Failed to get auth token: ' + (json.GetValue('status') as TJSONObject).GetValue('reason').Value);
      MsgDlg('Failed to get REST auth token', True, mtError);
    end
   else
      begin
        fSession.restToken := TJSONObject(JSON.GetValue('results')).GetValue('authToken').Value;
        LoggaWIMPkt('[POST] REST auth token', WL_rcvd_text, RespStr);
      end;
  finally
    FreeAndNil(json);
  end;

  // REST client id
  if not (fSession.restToken = '') then
  begin
    UnixTime := IntToStr(DateTimeToUnix(Now, False) - fSession.hostOffset);
    BaseURL := REST_HOST;
    Query := '{"method": "addClient", "reqId": "' + IntToStr(reqId) + '-' + UnixTime + '", "authToken": "' + fSession.restToken + '", "params": ""}';
    SendRequest(True, BaseURL, Query, RT_JSON, JSON, 'Get REST client id', '');
    Inc(reqId);
    if Assigned(JSON) then
    try
      if (json.GetValue('results') = nil) then
        begin
          fSession.restClientId := '';
          LoggaWIMPkt('[POST] REST client id', WL_rcvd_text, 'Failed to get client id: ' + (json.GetValue('status') as TJSONObject).GetValue('reason').Value);
          MsgDlg('Failed to get REST client id', True, mtError);
        end
          else
        begin
          fSession.restClientId := (json.GetValue('results') as TJSONObject).GetValue('clientId').Value;
          LoggaWIMPkt('[POST] REST client id', WL_rcvd_text, RespStr);
        end;
    finally
      FreeAndNil(JSON);
    end;
  end;

  Result := True;
end;

function TWIMSession.PingSession: Boolean;
var
  JSON: TJSONObject;
  Query: UTF8String;
  BaseURL: String;
  ts: Integer;
begin
  Result := False;
  BaseURL := WIM_HOST + 'aim/pingSession';
  Query := '&k=' + fSession.DevId;
  Result := SendSessionRequest(False, BaseURL, Query, RT_JSON, JSON, 'Restore session');
  if Result then
  try
    JSON.GetValueSafe('aimsid', fSession.AimSid);
    JSON.GetValueSafe('fetchBaseURL', fSession.fetchURL);
    JSON.GetValueSafe('ts', ts);
    LastFetchBaseURL := fSession.fetchURL;
    fSession.hostOffset := DateTimeToUnix(Now, False) - ts;
    AfterSessionStarted;
  finally
    JSON.Free;
  end;
end;

procedure TWIMSession.ResetSession;
begin
  fSession.secret := '';
  fSession.secretenc64 := '';
  fSession.token := '';
  fSession.tokenTime := 0;
  fSession.tokenExpIn := 0;
  fSession.hostOffset := 0;
end;

procedure TWIMSession.EndSession(EndToken: Boolean = False);
var
  Query: RawByteString;
  BaseURL: String;
begin
  BaseURL := WIM_HOST + 'aim/endSession';
  Query := IfThen(EndToken, '&invalidateToken=1');
  SendSessionRequest(False, BaseURL, Query, 'End current session');
  GoneOffline;

  if EndToken then
    ResetSession;
end;

procedure TWIMSession.PollError(const ExtraError: String = '');
begin
  if CleanDisconnect then
    Exit;

  MsgDlg(GetTranslation('Failed to start listening for events, waiting %d sec before retry...', [Round(ICQErrorReconnectDelay / 1000)]) +
         IfThen(ExtraError = '', '', #13#10 + '[' + ExtraError + ']'), False, mtError);

  TTask.Create(procedure
  begin
    Sleep(ICQErrorReconnectDelay);
    TThread.Synchronize(nil, procedure
    begin
      if not Running then
        Exit;
      // Try to use existing session, get new initial fetch url and start polling again. Go offline if all fails.
      if not PingSession then
        EndSession;
    end);
  end).Start;
end;

procedure TWIMSession.StartPolling;
var
  BaseURL: String;
begin
  if fSession.fetchURL = '' then
    exit;
  BaseURL := fSession.fetchURL.TrimRight(['/']);
  if (pos('?', BaseURL) = 0) then
    BaseURL := BaseURL + '?'
  else
    BaseURL := BaseURL + '&';
  BaseURL := BaseURL + 'f=json&r=' + IntToStr(IncReqId) + '&timeout=60000&peek=0';

  LoggaWIMPkt('[GET] Event fetch loop started', WL_sent_text, BaseURL);
  PollURL(BaseURL);

  phase := online_;
  NotifyListeners(IE_online);
end;

procedure TWIMSession.AbortPolling(Sender: TObject);
begin
  httpPoll.Abort;
end;

procedure TWIMSession.PollURL(const URL: String);
begin
  if not Running then
    Exit;

  if not Assigned(HttpPoll) or (URL = '') then
  begin
    PollError('ERR_UNASSIGNED');
    Exit;
  end;

  httpPoll.URL := URL;
  SetupProxy(TSslHttpCli(httpPoll));

  exectime := DateTimeToUnix(Now, False);

  try
    httpPoll.GetAsync;
    timeout.Enabled := True;
  except
    on E: OverbyteIcsHttpProt.EHttpException do
    begin
      HandleError(E, URL, '', False);
      PollError('ERR_GETFAIL');
    end;
  end;
end;

procedure TWIMSession.PollRequestDone(Sender: TObject; RqType: THttpRequest; ErrCode: Word);
var
  t, ts, code: Integer;
  RespStrR: RawByteString;
  Resp: TPair<Integer, String>;
  JSON: TJSONObject;
  event, etype, edata: TJSONValue;
  events: TJSONArray;

  function UnixTimeInMs: Int64;
  var
    ST: SystemTime;
    DT: TDateTime;
  begin
    Windows.GetSystemTime(ST);
    DT := SysUtils.EncodeDate(ST.wYear, ST.wMonth, ST.wDay) +
          SysUtils.EncodeTime(ST.wHour, ST.wMinute, ST.wSecond, ST.wMilliseconds);
    Result := DateUtils.MilliSecondsBetween(DT, UnixDateDelta);
  end;

var
  Freq, StartCount, StopCount: Int64;
  TimingSeconds: real;
  cli: TSslHttpCli;
  lReqId: String;
  eTypeV: String;
begin
  timeout.Enabled := False;

  if not Assigned(Sender) then
  begin
    PollError('ERR_NOSENDER');
    Exit;
  end;

  cli := Sender as TSslHttpCli;
  with cli do
  begin
    if Assigned(SendStream) then
      SendStream.Free;

//    RespStr := pollStream.DataString;
//    RespStrR := StrToUTF8(pollStream.DataString);
    if pollStream.Size > 0 then
      begin
        SetLength(RespStrR, pollStream.Size);
        pollStream.Seek(0, soBeginning);
        pollStream.Read(RespStrR[1], Length(RespStrR));
      end
     else
       RespStrR := '';
    pollStream.Clear;
  end;

  // Abort and request fetch URL again every <60 sec to stay online
  if ErrCode = httperrAborted then
  begin
    RestartPolling(1000);
    Exit;
  end;

  // 5 sec delay after HTTP error
  if not (cli.StatusCode = 200) then
  begin
    MsgDlg('Fetch event bad code: ' + IntToStr(cli.StatusCode) + #13#10#13#10 + cli.RcvdHeader.Text + #13#10#13#10 + UnUTF(RespStrR), False, mtInformation);
    if (cli.StatusCode >= 500) and (cli.StatusCode < 600) then
      RestartPolling(ICQErrorReconnectDelay)
    else
      PollError('ERR_HTTPCODE');
    Exit;
  end;

  if (RespStrR='') and (cli.ContentLength >0) then
    begin
      if cli.State =  httpWaitingBody then
        exit;
    end;

  if Trim(RespStrR) = '' then
  begin
    PollError('ERR_EMPTYRESP');
    Exit;
  end;

  ts := 0;
  JSON := nil;
  if not (Trim(RespStrR) = '') then
  try
    eventNameA := '[POST] Fetched new events';
    eventMsgA := RespStrR;
    NotifyListeners(IE_serverSentJ);

    LastFetchBaseURL := '';
    if not ParseJSON(UTF8String(RespStrR), JSON) then
    begin
      PollError('ERR_NOTAJSON');
      Exit;
    end;
    Resp := CheckResponseData(JSON, lReqId);
    if Resp.Key = Integer(EAC_OK) then
    if not (JSON.GetValue('fetchBaseURL') = nil) then
    begin
      JSON.GetValueSafe('fetchBaseURL', LastFetchBaseURL);
      JSON.GetValueSafe('fetchTimeout', t);
      t := Max(60, t);
      timeout.Interval := (t - (2 + Random(3))) * 1000;
      JSON.GetValueSafe('timeToNextFetch', t);
      JSON.GetValueSafe('ts', ts);
      fSession.hostOffset := DateTimeToUnix(Now, False) - ts;
//      OutputDebugString(PChar('exec = ' + IntToStr(exectime)));
//      OutputDebugString(PChar('next url = ' + LastFetchBaseURL));
//      OutputDebugString(PChar('timeToNextFetch = ' + IntToStr(t)));

      events := JSON.GetValue('events') as TJSONArray;
      for event in events do
      if Assigned(event) and (event is TJSONObject) then
      begin
        etype := TJSONObject(event).GetValue('type');
        edata := TJSONObject(event).GetValue('eventData');
        if Assigned(etype) and Assigned(edata) then
         begin
          etypev := etype.Value;
          if etypev = 'buddylist' then
          begin
  QueryPerformanceFrequency(Freq);
  QueryPerformanceCounter(StartCount);
            try
              if edata is TJSONObject then
                ProcessContactList(TJSONObject(edata).GetValue('groups') as TJSONArray);
             except
                on E: Exception do
                   msgDlg('Error in event buddylist: '+ e.Message, false, mtError);
            end;
  QueryPerformanceCounter(StopCount);
  TimingSeconds := (StopCount - StartCount) / Freq;
  ODS('Populating CL: ' + floattostr(TimingSeconds));
            // Get caps of users currently online
            GetAllCaps;
            // Get own profile's settings
            GetProfile(MyAccNum);
          end else if (etypev = 'presence') or (etypev = 'myInfo') then
            ProcessContact(TJSONObject(edata))
          else if (etypev = 'histDlgState') or (etypev = 'offlineIM') then
            ProcessDialogState(TJSONObject(edata), etypev = 'offlineIM')
          else if etypev = 'imState' then
            ProcessIMState(TJSONObject(edata))
          else if etypev = 'typing' then
            ProcessTyping(TJSONObject(edata))
          else if etypev = 'userAddedToBuddyList' then
            ProcessAddedYou(TJSONObject(edata))
          else if etypev = 'permitDeny' then
            ProcessPermitDeny(TJSONObject(edata))
          else if etypev = 'diff' then
          begin
  //          TJSONArray(edata)
          end else
            ODS('Unhandled event type: ' + etype.Value);
         end;
      end;
    end
      else // Events that do not continue events fetching
    begin
      LastFetchBaseURL := '';

      events := json.GetValue('events') as TJSONArray;
      for event in events do
      if Assigned(event) and (event is TJSONObject) then
      begin
        etype := TJSONObject(event).GetValue('type');
        edata := TJSONObject(event).GetValue('eventData');
        if Assigned(etype) then
        if etype.Value = 'sessionEnded' then
        begin
          if Assigned(edata) and (edata is TJSONObject) then
            if edata.GetValueSafe('endCode', code) then
              if (code = 142) or  // "offReason" : "Killed Sessions"
                 (code = 26) then // "offReason" : "User Initiated Bump"
                CleanDisconnect := True;
          GoneOffline;
        end;
      end;
    end;
  finally
    JSON.Free;
  end;

  RestartPolling(t);
end;

procedure TWIMSession.RestartPolling(Delay: Integer = 1);
begin
  if (LastFetchBaseURL = '') then
    PollError('ERR_UNCLEAN')
  else
  TTask.Create(procedure
  begin
    Sleep(Max(100, Delay)); // Min 100ms between fetches, just in case :)
    TThread.Synchronize(nil, procedure
    begin
      if not Running then
        Exit;
      PollURL(LastFetchBaseURL);
    end);
  end).Start;
end;

procedure TWIMSession.ProcessContactList(const CL: TJSONArray);
var
  buddy, group: TJSONValue;
  buddies: TJSONArray;
  id, gID: Integer;
  pG: PGroup;
  name: String;
//  c: TWIMContact;
begin
  if not Assigned(CL) then
    Exit;

//  RnQmain.roster.BeginUpdate;
  try
    groups.MakeAllLocal;
    for group in CL do
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
  finally
//    RnQmain.roster.EndUpdate;
  end;
end;

function TWIMSession.ProcessContact(const Buddy: TJSONObject; GroupToAddTo: Integer = -1; Batch: Boolean = False): TWIMContact;
var
  i, Mute: Integer;
  b, LoadingCL, FoundCap: Boolean;
  Tmp, Phone1, Phone2, Phone3, PhoneType, OldXStatusStr: String;
  OldPic: TPicName;
  TheCap, TheCap2: RawByteString;
  UnixTime: Integer;
  NewStatus: TWIMStatus;
  NewInvis: Boolean;
  Profile, TmpObj: TJSONObject;
  Cap, Ph, TmpArr: TJSONValue;
  Caps: TJSONArray;
  tmpId: RawByteString;
begin
  Result := nil;

  if not Assigned(Buddy) then
    Exit;

  Result := getWIMContact(Buddy.GetValue('aimId').Value);
  if not Assigned(Result) then
    Exit;

//  if Buddy.GetValueSafe('abContactName', Name) then
//    if not (Name = '') then
//      Result.nick := Name
//  if (Result.nick = '') then
  begin
    if Buddy.GetValueSafe('displayId', Tmp) then
      if (Tmp <> '')and (tmp <> Result.UID2cmp) then
        Result.nick := Tmp;
    if Buddy.GetValueSafe('friendly', Tmp) then
//      if not (Tmp = '') then
      Result.fDisplay := Tmp;
//        Result.nick := Tmp;
  end;

  if Buddy.GetValueSafe('emailId', Tmp) then
    if not TryStrToInt(Tmp, i) then
      Result.Email := Tmp;

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

  Buddy.GetValueSafe('userType', Tmp);
  Result.UserType := CT_UNK;
  if Tmp = 'sms' then
  begin
    Result.UserType := CT_SMS;
    Result.SMSable := True;
  end else if Tmp = 'phone' then
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

  if not (Buddy.GetValue('capabilities') = nil) then
  begin
    Result.LastCapsUpdate := Now;
    Result.CapabilitiesSm := [];
    Result.CapabilitiesBig := [];
    Result.CapabilitiesXTraz := [];
    Result.ExtraCapabilities := '';
    Caps := Buddy.GetValue('capabilities') as TJSONArray;
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

  Result.Authorized := True; // Assume this is the default :)

  // Owner only
  if Buddy.GetValueSafe('attachedPhoneNumber', Tmp) then
    if not (Tmp = '') then
      AttachedLoginPhone := Tmp;

  Profile := TJSONObject(Buddy.GetValue('profile'));
  if Assigned(Profile) then
  begin
    Profile.GetValueSafe('firstName', Result.first);
    Profile.GetValueSafe('lastName', Result.last);

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

    if Profile.GetValueSafe('relationshipStatus', Tmp) then
    begin
      if Tmp = 'single' then
        Result.MarStatus := $000A
      else if Tmp = 'dating' then
        Result.MarStatus := $000D
      else if Tmp = 'longTermRelationship' then
        Result.MarStatus := $000B
      else if Tmp = 'engaged' then
        Result.MarStatus := $000C
      else if Tmp = 'married' then
        Result.MarStatus := $0014
      else if Tmp = 'divorced' then
        Result.MarStatus := $001E
      else if Tmp = 'separated' then
        Result.MarStatus := $001F
      else if Tmp = 'widowed' then
        Result.MarStatus := $0028
      else if Tmp = 'openRelationship' then
        Result.MarStatus := $0032
      else if Tmp = 'askMe' then
        Result.MarStatus := $0033
      else if Tmp = 'other' then
        Result.MarStatus := $00FF
      else
        Result.MarStatus := $0000;
    end else Result.MarStatus := $0000;

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
      if Profile.GetValueSafe('webAware', i) then
        webAware := i = 1;
      if Profile.GetValueSafe('authRequired', i) then
        authNeeded := i = 1;
      if Profile.GetValueSafe('hideLevel', Tmp) then
      if Tmp = 'none' then
        showInfo := 0
      else if Tmp = 'emailsAndCellular' then
        showInfo := 1
      else if Tmp = 'allExceptFln' then
        showInfo := 2
      else if Tmp = 'all' then
        showInfo := 3
      else
        showInfo := 0;

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

procedure TWIMSession.ProcessNewStatus(var Cnt: TWIMContact; NewStatus: TWIMStatus;
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

procedure TWIMSession.ProcessUsersAndGroups(const JSON: TJSONObject);
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

procedure TWIMSession.ProcessDialogState(const Dlg: TJSONObject; IsOfflineMsg: Boolean = False);
const
  AESBLKSIZE = SizeOf(TAESBlock);
var
  c: TWIMContact;
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

  function CheckDataPayload(var Msg: String): Boolean;
  var
    Payload: TJSONObject;
    RQCaps, RQCap: TJSONValue;
    RQType, Cap: String;
    Caps: TArray<AnsiString>;
    Pub: array [0..2] of Integer;
    Encryped, ECC, i: Integer;
    My: TWIMContact;
  begin
    Result := False;
    Encryped := 0;
    if ParseJSON(Msg, Payload) then
    try
      Payload.GetValueSafe('type', RQType);
      if not (RQType = 'RnQDataIM') then
        Exit;
      RQCaps := Payload.GetValue('caps');
      if not Assigned(RQCaps) or not (RQCaps is TJSONArray) then
        Exit;

      Payload.GetValueSafe('data', Msg);

      // No caps? Get data as is
      if TJSONArray(RQCaps).Count = 0 then
        Exit;

      for RQCap in TJSONArray(RQCaps) do
        if Assigned(RQCap) and (RQCap is TJSONString) then
          Insert(TJSONString(RQCap).Value, Caps, High(Caps));

      // Buzz
      if MatchText(Str2Hex(BigCapability[CAPS_big_Buzz].v), Caps) then
      begin
        eventContact := c;
        NotifyListeners(IE_buzz);
        Result := True;
        Exit;
      end;

      // Regular crypt
      if MatchText(Str2Hex(BigCapability[CAPS_big_CryptMsg].v), Caps) then
        Encryped := 1;

      // ECC crypt
      ECC := 0;
      for i := Low(Caps) to High(Caps) do
      begin
        if AnsiStartsStr('RDEC0', Caps[i]) then
          begin Pub[0] := i; Inc(ECC); end
        else if AnsiStartsStr('RDEC1', Caps[i]) then
          begin Pub[1] := i; Inc(ECC, 2); end
        else if AnsiStartsStr('RDEC2', Caps[i]) then
          begin Pub[2] := i; Inc(ECC, 4); end;
      end;

      if ECC = 7 then
      begin
        My := TWIMContact(GetMyInfo);
        if My.Crypt.EccPubKey = Copy(Hex2Str(Caps[Pub[0]]), 6, 11) + Copy(Hex2Str(Caps[Pub[1]]), 6, 11) + Copy(Hex2Str(Caps[Pub[2]]), 6, 11) then
          Encryped := 2
        else
        begin
          eventError := EC_FailedDecrypt;
          eventMsgA := GetTranslation('Message was encrypted using another public key');
          NotifyListeners(IE_error);
          Exit;
        end;
      end;

      if Encryped > 0 then
        DecryptMessage(Encryped, Payload, Msg);
    finally
      FreeAndNil(Payload);
    end;
  end;

  procedure ProcessMsg(Msg: TJSONObject; chat: TWIMContact = NIL);
  var
    UnixTime, ID: Integer;
    MsgID: TMsgID;
    WID, sID, lSender: String;
    chatObj: TJSONValue;
  begin
    if not Assigned(Msg) then
      Exit;

    if Msg.GetValueSafe('outgoing', outgoing) then
    if outgoing then // Backup ack, should be acked from imState already
    with Msg do
    begin
      eventFlags := 0;
      eventMsgA := '';

      if GetValueSafe('time', UnixTime) then
        eventTime := UnixToDateTime(UnixTime, False);

      if GetValueSafe('wid', WID) then
        eventWID := WID;

      if GetValueSafe('msgId', MsgID) then
        eventMsgID := MsgID;

      GetValueSafe('reqId', sID);
      eventReqID := sID;
      if TryStrToInt(sID, ID) then
      begin
        eventInt := ID;
      end;
      NotifyListeners(IE_serverAck);

      Exit;
    end;

    SetLength(eventBinData, 0);
    eventFlags := 0;
    eventMsgA := '';
//    eventEncoding := TEncoding.Default;

    lSender := '';
    chatObj := TJSONObject(Msg).GetValue('chat');
    if Assigned(chatObj) and (chatObj is TJSONObject) then
      begin
        chatObj.GetValueSafe('sender', lSender);
      end;


    if IsOfflineMsg then
      eventFlags := eventFlags or IF_offline
    else
      ProcessNewStatus(c, c.Status, True); // Check for invisibility (non-offline message from offline contact)

    // offlineIM/dataIM:
    // "imf": "plain"
    // "autoresponse" : 0
    mtype := 'text'; // text or sticker
    if Msg.GetValueSafe('mediaType', sTmp) then
      if not (sTmp = '') then
        mtype := sTmp;
    if IsOfflineMsg and Msg.GetValueSafe('stickerId', sTmp) then
      mtype := 'sticker';

//    if EnableStickers and (mtype = 'sticker') then
    if (mtype = 'sticker') then
    begin
      if IsOfflineMsg then
        StickerStr := sTmp
      else
      begin
        Sticker := TJSONObject(Msg).GetValue('sticker');
        if Sticker.GetValueSafe('id', sTmp) then
          StickerStr := sTmp
      end;

      ExtSticker := SplitString(StickerStr, ':');
      if (Length(ExtSticker) >= 4) then
        eventBinData := GetSticker(ExtSticker[1], ExtSticker[3]);

      eventString := '';
    end else if Msg.GetValueSafe(IfThen(IsOfflineMsg, 'message', 'text'), sTmp) then
      eventString := sTmp;
    if Msg.GetValueSafe(IfThen(IsOfflineMsg, 'msgId', 'wid'), sTmp) then
      eventWID := sTmp;
    if Msg.GetValueSafe(IfThen(IsOfflineMsg, 'timestamp', 'time'), iTmp) then
      eventTime := UnixToDateTime(iTmp, False)
    else
      eventTime := Now;

//    eventAddress := sA; // For multichat

// delUpto, tail, intro, persons[]

//  "yours" : {
//    "lastRead" : "6640070768770154834"
//  },
//  "theirs" : {
//    "lastDelivered" : "6640435849580249672",
//    "lastRead" : "6640435849580249672"
//  },

    // Process special RnQ messages
    if not (eventString = '') and ContainsStr(eventString, 'RnQDataIM') then
      if CheckDataPayload(eventString) then
        Exit;

    eventContact := c;
    if lSender <> '' then
      begin
        eventAddress := lSender;
        notifyListeners(IE_MultiChat);
      end
     else
    notifyListeners(IE_msg);
  end;

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
    c := getWIMContact(sn);

  if not Assigned(c) then
  begin
    eventError := EC_MalformedMsg;
    eventMsgA := Dlg.ToString;
    notifyListeners(IE_error);
    Exit;
  end;

  if IsOfflineMsg then
    ProcessMsg(Dlg)
  else
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
  end;
end;

procedure TWIMSession.ProcessIMState(const Data: TJSONObject);
var
  IMState: TJSONValue;
  IMStates: TJSONArray;
  sID, WID, State: String;
  UnixTime, ID: Integer;
  MsgID: TMsgID;
begin
  if not Assigned(Data) then
    Exit;

  IMStates := Data.GetValue('imStates') as TJSONArray;
  if Assigned(IMStates) then
  for IMState in IMStates do
  with IMState do
  begin
    GetValueSafe('state', State);

    if State = '' then
      Continue;

    eventFlags := 0;
    eventMsgA := State;

    if Data.GetValueSafe('ts', UnixTime) then
      eventTime := UnixToDateTime(UnixTime, False);

    if GetValueSafe('msgId', WID) then
      eventWID := WID;

    if GetValueSafe('histMsgId', MsgID) then
      eventMsgID := MsgID;

    GetValueSafe('sendReqId', sID);
    eventReqID := sID;
    if TryStrToInt(sID, ID) then
    begin
      eventInt := ID;
    end;
    if sID > '' then
      notifyListeners(IE_serverAck);
  end;
end;

procedure TWIMSession.ProcessTyping(const Data: TJSONObject);
var
  c: TWIMContact;
  TypingStatus: String;
begin
  if not Assigned(Data) then
    Exit;

  c := GetWIMContact(Data.GetValue('aimId').Value);
  if not Assigned(c) then
    Exit;

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

procedure TWIMSession.ProcessAddedYou(const Data: TJSONObject);
var
  c: TWIMContact;
  NeedAuth: Integer;
  Name, Msg: String;
begin
  if not Assigned(Data) then
    Exit;

  c := GetWIMContact(Data.GetValue('requester').Value);
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

procedure TWIMSession.ProcessPermitDeny(const Data: TJSONObject);
var
  c: TWIMContact;
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
      c := getWIMContact(TJSONString(Item).Value);
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

// Not working, for VoIP?
procedure TWIMSession.InitWebRTC;
var
  BaseURL, UnixTime: String;
  Params: TDictionary<String, String>;
begin
  UnixTime := IntToStr(DateTimeToUnix(Now, False) - fSession.hostOffset);
  Params := TDictionary<String, String>.Create;
  Params.Add('a', fSession.token);
  Params.Add('f', 'json');
  Params.Add('k', fSession.devid);
  Params.Add('r', IntToStr(DateTimeToUnix(Now, False) * 1000) + '_' + IntToStr(Random(32767)));
  Params.Add('ts', UnixTime);
  BaseURL := WIM_HOST + 'webrtc/alloc';
  SendRequest(True, BaseURL, MakeParams('POST', BaseURL, Params), 'Init WebRTC');
end;

procedure TWIMSession.checkServerHistory(const uid: TUID);
begin
  checkOrGetServerHistory(uid, False);
end;

procedure TWIMSession.getServerHistory(const uid: TUID);
begin
  checkOrGetServerHistory(uid, True);
end;

procedure TWIMSession.checkOrGetServerHistory(const uid: TUID; retrieve: Boolean = False);

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
    Params := '{"sn": "' + UID + '", "fromMsgId": ' + From + IfThen(Till = '', '', ', "tillMsgId": ' + Till) + ', "count": ' + IntToStr(Count) + ', "aimSid": "' + fSession.aimsid + '", "patchVersion": "' + PatchVer + '"}';
    Query := '{"method": "getHistory", "reqId": "' + IntToStr(ReqId) + '-' + IntToStr(DateTimeToUnix(Now, False) - fSession.HostOffset) + '", "authToken": "' + fSession.restToken + '", "clientId": ' + fSession.RESTClientId + ', "params": ' + Params + ' }';

    Header := '[POST] Get a chunk of server history [' + From + ':' + IntToStr(Count) + ']';
    LoggaWIMPkt(Header, WL_sent_text, Query);
    LoadFromURLAsString(REST_HOST, Result, Query);
    LoggaWIMPkt(Header, WL_rcvd_text, Result);
    Inc(ReqId);
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
    eventContact := TWIMContact(cht);
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

procedure TWIMSession.SetListener(l : TProtoNotify);
begin
  listener := l;
end;

procedure TWIMSession.SendTyping(c: TWIMContact; NotifType: Word);
var
  TypingStatus: RawByteString;
  Query: RawByteString;
  BaseURL: String;
begin
  if not Assigned(c) or (not IsOnline) or (not ImVisibleTo(c)) then
    Exit;

  TypingStatus := 'none';
  if NotifType = MTN_BEGUN then
    TypingStatus := 'typing'
  else if NotifType = MTN_TYPED then
    TypingStatus := 'typed';

  BaseURL := WIM_HOST + 'im/setTyping';
  Query := '&t=' + ParamEncode(String(c.UID2cmp)) +
           '&typingStatus=' + TypingStatus;
  SendSessionRequest(False, BaseURL, Query, 'Send typing');
end;



function TWIMSession.GenSSID : Integer;
var
  a : Word;
begin
//  repeat
   a := random($7FFF);
//  until (FindSSIItemID(serverSSI, a)<0) and (groups.ssi2id(a) < 0) and (a>0); //(contactsDB.idxBySSID(a) >=0)or (groups.ssi2id(a) >= 0);
  Result := a;
end;

procedure TWIMSession.SendAddContact(c: TWIMContact);
var
  JSON: TJSONObject;
  Query: RawByteString;
  BaseURL, ResCode: String;
  Results: TJSONArray;
  Code: Integer;
begin
  BaseURL := WIM_HOST + 'buddylist/addBuddy';
  Query := '&buddy=' + ParamEncode(String(c.UID2cmp))+
           '&aimsid=' + ParamEncode(fSession.aimsid);
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
        GetProfile(c.UID2cmp);
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
end;

procedure TWIMSession.SSI_UpdateContact(c: TWIMContact);
var
  Query: RawByteString;
  BaseURL: String;
begin
  BaseURL := WIM_HOST + 'buddylist/setBuddyAttribute';
  Query := '&buddy=' + ParamEncode(String(c.UID2cmp)) +
           '&friendly=' + ParamEncode(c.Display);
  SendSessionRequest(False, BaseURL, Query, 'Rename contact', 'Failed to rename contact');
end;

procedure TWIMSession.SendRemoveContact(c: TWIMContact);
var
  Query: RawByteString;
  BaseURL: String;
begin
  BaseURL := WIM_HOST + 'buddylist/removeBuddy';
  Query := '&buddy=' + ParamEncode(String(c.UID2cmp)) +
           '&allGroups=1';
  if SendSessionRequest(False, BaseURL, Query, 'Remove contact', 'Failed to remove contact') then
    c.CntIsLocal := c.IsInRoster
end;

procedure TWIMSession.UpdateGroupOf(cnt: TRnQContact);
begin

end;

function TWIMSession.UpdateGroupOf(c: TWIMContact; grp: Integer): Boolean;
var
  Query: RawByteString;
  BaseURL: String;
//  Code: Integer;
begin
  Result := False;
  if c.CntIsLocal then
    Exit;

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
end;

function TWIMSession.SendUpdateGroup(const Name: String; ga: TGroupAction; const Old: String = ''): Boolean;
var
  Query: RawByteString;
  BaseURL: String;
//  Code: Integer;
begin
  Result := False;
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
end;

function TWIMSession.deleteGroup(grSSID: Integer): Boolean;
begin
  Result := False;
  notAvailable;
end;

procedure TWIMSession.UpdateGroupID(grID: Integer);
begin
  notAvailable;
end;

procedure TWIMSession.AuthGrant(Cnt: TRnQContact);
begin
  AuthGrant(cnt as TWIMContact);
end;

procedure TWIMSession.AuthGrant(c: TWIMContact; Grant: Boolean = True);
var
  Query: RawByteString;
  BaseURL, ResCode: String;
begin
  BaseURL := WIM_HOST + 'buddylist/authorizeUser';
  Query := RawByteString('&t=') + ParamEncode(String(c.UID2cmp)) +
           '&authorized=' + IfThen(Grant, RawByteString('1'), RawByteString('0'));
  SendSessionRequest(False, BaseURL, Query, IfThen(Grant, 'Grant', 'Deny') + ' auth', 'Failed to ' + IfThen(Grant, 'grant', 'deny') + ' authorization');
end;

procedure TWIMSession.AuthRequest(cnt: TRnQContact; const Reason: String);
var
  Query: RawByteString;
  BaseURL: String;
  iam: TRnQContact;
  rsn: String;
begin
  if not ImVisibleTo(cnt) then
    if AddTempVisMsg then
      AddTemporaryVisible(cnt as TWIMContact);
  iam := GetMyInfo;

  if Reason = '' then
    rsn := GetTranslation(Str_AuthRequest)
   else
    rsn := Reason;

  BaseURL := WIM_HOST + 'buddylist/requestAuthorization';
  Query := '&t=' + ParamEncode(String(cnt.UID2cmp)) +
           '&authorizationMsg=' + ParamEncode(rsn);
  SendSessionRequest(False, BaseURL, Query, 'Request auth', 'Failed to request authorization')
end;

// Set an implicit refcount so that refcounting
// during construction won't destroy the object.
class function TWIMSession.NewInstance: TObject;
begin
  Result := inherited NewInstance;
  TWIMSession(Result).FRefCount := 1;
end;

class function TWIMSession._getContactClass: TRnQCntClass;
begin
  Result := TWIMContact;
end;

class function TWIMSession._getProtoServers: String;
var
  i: Integer;
begin
  Result := '';
  for I := 0 to Length(ICQServers) - 1 do
    Result := Result + ICQServers[i]+ CRLF;
end;

class function TWIMSession._getProtoID : Byte;
begin
  Result := WIMProtoID;
end;

function TWIMSession.GetContactClass: TRnQCntClass;
begin
  Result := TWIMContact;
end;

class function TWIMSession._MaxPWDLen: Integer;
begin
  Result := maxPwdLength;
end;

function TWIMSession.GetContact(const UID: TUID): TRnQContact;
begin
  result := GetWIMContact(uid);
end;

function TWIMSession.GetContact(const UIN: Integer): TRnQContact;
begin
  result := GetWIMContact(uin);
end;

function TWIMSession.GetStatuses: TStatusArray;
begin
  Result := WIMstatuses;
end;

function TWIMSession.GetVisibilities: TStatusArray;
begin
  Result := icqVis;
end;

function TWIMSession.GetStatusMenu: TStatusMenu;
begin
  Result := statMenu;
end;

function TWIMSession.GetVisMenu: TStatusMenu;
begin
  Result := icqVisMenu;
end;

function TWIMSession.GetStatusDisable: TOnStatusDisable;
begin
  result := onStatusDisable[byte(curStatus)];
end;

procedure TWIMSession.InputChangedFor(cnt: TRnQContact; InpIsEmpty: Boolean; timeOut: boolean = false);
var
  c: TWIMContact;
begin
  if (not SupportTypingNotif) or (not IsSendTypingNotif) or not Assigned(cnt) then
    Exit;
  c := cnt as TWIMContact;
  with TWIMContact(c) do
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
function TWIMSession.sendFileTest(msgID:TmsgID; c:Tcontact; fn:string; size:integer) : Integer;
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

function TWIMSession.compareStatusFor(cnt1, Cnt2: TRnqContact): Smallint;
begin
  if StatusPriority[TWIMContact(cnt1).status] < StatusPriority[TWIMContact(Cnt2).status] then
    result := -1
  else if StatusPriority[TWIMContact(cnt1).status] > StatusPriority[TWIMContact(Cnt2).status] then
    result := +1
  else
    Result := 0;
end;

procedure TWIMSession.getClientPicAndDesc4(cnt: TRnQContact;
              var pPic: TPicName; var CliDesc: String);
var
  c: TWIMContact;
begin
  if isOffline or (cnt=NIL) or cnt.isOffline then
    exit;
  if cnt is TWIMContact then
    c := TWIMContact(cnt)
   else
    Exit;
  pPic := '';
  CliDesc := Str_unk;

//  getICQClientPicAndDesc(c, pPic, CliDesc);
end; // getClientPicAndDesc4

function TWIMSession.getPrefPage: TPrefFrameClass;
begin
  result := TWIMFr;
end;

procedure TWIMSession.ApplyBalloon;
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

class constructor TWIMSession.InitWIMProto;
var
  b, b2: Byte;
begin
  SetLength(WIMStatuses, Byte(HIGH(TWIMStatus))+1);
  for b := byte(LOW(TWIMStatus)) to byte(HIGH(TWIMStatus)) do
    with WIMStatuses[b] do
     begin
      idx := b;
      ShortName := status2img[b];
      Cptn      := status2ShowStr[TWIMStatus(b)];
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
  RegisterProto(TWIMSession);
end;

class destructor TWIMSession.UnInitWIMProto;
var
  b: Byte;
begin
  if Length(WIMStatuses) > 0 then
  for b := Byte(Low(TWIMStatus)) to byte(High(TWIMStatus)) do
  with WIMStatuses[b] do
  begin
    SetLength(ShortName, 0);
    SetLength(Cptn, 0);
    SetLength(ImageName, 0);
  end;
  SetLength(WIMStatuses, 0);
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
