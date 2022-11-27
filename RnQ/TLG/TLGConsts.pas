{
  This file is part of R&Q.
  Under same license
}
unit TLGConsts;
{$I RnQConfig.inc}

interface

uses
  Windows, RDGlobal, RQThemes, RnQProtocol, RnQPics, themesLib;

{$I NoRTTI.inc}

type
  TTLGStatus = (SC_ONLINE = 0, SC_OFFLINE, SC_UNK, SC_OCCUPIED, SC_NA, SC_AWAY);
  TTLGContactType = (CT_UNK = 0, CT_ICQ, CT_OLDICQ, CT_SMS, CT_PHONE);

  TGroupAction = (GA_None = 0, GA_Add, GA_Rename, GA_Remove);

  TMsgType = (MSG_TEXT = 0, MSG_STICKER);

const
  SC_Last = SC_AWAY;
  StatusPriority: array [TTLGStatus] of byte = (0, 8, 9, 1, 2, 3);

type
//  TVisibility = (VI_normal, VI_invisible, VI_privacy, VI_all, VI_CL);
  TVisibility = (VI_normal, VI_invisible);

const
  visibility2ShowStr: array [TVisibility] of String = ('Normal (all but invisible-list)',
    'Invisible'); //, 'Privacy (only visible-list)' , 'Visible to all', 'Visible to contact-list');
  visibility2imgName: array [TVisibility] of TPicName = (PIC_VISIBILITY_NORMAL, PIC_VISIBILITY_NONE);
//    PIC_VISIBILITY_PRIVACY, PIC_VISIBILITY_ALL, PIC_VISIBILITY_CL);
//  visib2str: array [Tvisibility] of TPicName = ('normal', 'invisible', 'privacy', 'all', 'cl');
  visib2str: array [TVisibility] of TPicName = ('normal', 'invisible');
  status2ShowStr: array [TTLGStatus] of string = ('Online', 'Offline', 'Unknown', 'Occupied', 'N/A', 'Away');
  status2Img: array [0 .. Byte(SC_AWAY)] of TPicName = ('online', 'offline', 'unk', 'occupied', 'na', 'away');
  Status2Srv: array [0 .. Byte(SC_AWAY)] of TPicName =
              ('online', 'offline', 'offline', 'occupied', 'na', 'away');
  statusWithAutoMsg = [byte(SC_AWAY), byte(SC_NA), byte(SC_OCCUPIED)];

const
  //DLL name associated with the test project
  {$IFDEF MSWINDOWS}
    tdjsonDllName: String =
        {$IFDEF WIN32} 'tdjson.dll' {$ENDIF}
        {$IFDEF WIN64} 'tdjson-x64.dll' {$ENDIF} {+ SharedSuffix};   //TDLib.dll
  {$ELSE}
    tdjsonDllName: String = 'libtdjson.so' {+ SharedSuffix};
  {$ENDIF}

  //Setting the Receiver Timeout
  WAIT_TIMEOUT: double = 1.0; //1 seconds

  TD_API_ID = -1; // INSERT YOUR ID Here!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  TD_API_HASH = ''; // INSERT YOUR Hash Here!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  TD_test_server_ip = '149.154.167.40:443';
  TD_prod_server_ip = '149.154.167.50:443';

  TD_MSG_SECRET_STRING = 'The Telegram Client';
  maxRefs = 2000;
  maxPwdLength = 16;
  LOGIN_HOST: AnsiString = '127.0.0.1';
  UINToUpdate = 223223181;
  ICQMaxAvatarSize = 7800;

  ICQErrorReconnectDelay = 5000; // Default attempt delay after error

  BALLOON_NEVER = 0;
  BALLOON_ALWAYS = 1;
  BALLOON_BDAY = 2;
  BALLOON_DATE = 3;

  // Client IDs
  RnQclientID = $FFFFF666;

const
  // By Rapid D
  IF_Simple = 1 shl 5; // msg is simple
  // IF_MSG_OK   = 1 shl 8;      // msg was delivered!
  // IF_MSG_ERROR= 1 shl 9;      // msg was NOT delivered!
  IF_no_matter = 1 shl 10;
  last_IF = 1 shl 10; // useful for external additional flags

  AvtHash_NoAvt = AnsiString(#$B4#$32#$5C#$25#$34#$3D#$41#$13#$72#$90#$9D#$C0#$E7#$3A#$71#$73);
  // Hash of Avatar "No photo has been uploaded"

  word_Zero = AnsiString(#00#00);
  dword_Zero = AnsiString(#00#00#00#00);
  Z = dword_Zero;

  BigCapability: array [1 .. 32] of record
    v: String[16];
    s: AnsiString;
  end = (
  (v: #$97#$B1#$27#$51#$24#$3C#$43#$34#$AD#$22#$D6#$AB#$F7#$3F#$14#$92; s: 'RTF messages'), // RTF
  (v: #$2E#$7A#$64#$75#$FA#$DF#$4D#$C8#$88#$6F#$EA#$35#$95#$FD#$B6#$DF; s: 'ICQ 2001'),
  // AIM_CAPS_2001 or OLD_UTF
  (v: #$56#$3F#$C8#$09#$0B#$6F#$41#$BD#$9F#$79#$42#$26#$09#$DF#$A2#$F3; s: 'Typing notifications'),
  // mini typing notification (MTN) (for 2003b, ..., lite4)
  (v: #$97#$B1#$27#$51#$24#$3C#$43#$34#$AD#$22#$D6#$AB#$F7#$3F#$14#$09; s: 'Secure IM Trillian'),
  // Is Trillian
  (v: #$74#$8F#$24#$20#$62#$87#$11#$D1#$82#$22#$44#$45#$53#$54#$00#$00; s: 'Chat'),
  // Can participate in centralized text conferences
  (v: #$1A#$09#$3C#$6C#$D7#$FD#$4E#$C5#$9D#$51#$A6#$47#$4E#$34#$F5#$A0; s: 'Xtraz'),
  (v: #$D3#$D4#$53#$19#$8B#$32#$40#$3B#$AC#$C7#$D1#$A9#$E2#$B5#$81#$3E; s: 'QIP-ProtectMsg'),
  // (V: #$17#$8C#$2D#$9B#$DA#$A5#$45#$BB#$8D#$DB#$F3#$BD#$BD#$53#$A1#$0A; s: 'Lite-AIM Cap1'),
  (v: #$17#$8C#$2D#$9B#$DA#$A5#$45#$BB#$8D#$DB#$F3#$BD#$BD#$53#$A1#$0A; s: 'IM is ICQLite'),
  // );
  // ExtCapability:array [1..6] of record v : string[16]; s : String end=(

  (v: #$F2#$E7#$C7#$F4#$FE#$AD#$4D#$FB#$B2#$35#$36#$79#$8B#$DF#$00#$00; s: 'Trillian'), // Trillian
  (v: #$09#$49#$13#$44#$4C#$7F#$11#$D1#$82#$22#$44#$45#$53#$54#$00#$00; s: 'kxICQ2'), // Is kxICQ2
  (v: #$DD#$16#$F2#$02#$84#$E6#$11#$D4#$90#$DB#$00#$10#$4B#$9B#$4B#$7D; s: 'MacICQ'), // MacICQ
  (v: #$09#$49#$13#$49#$4C#$7F#$11#$D1#$82#$22#$44#$45#$53#$54#$00#$00; s: 'LICQ'), // LICQ
  (v: #$56#$3F#$C8#$09#$0B#$6F#$41#$51#$49#$50#$20#$32#$30#$30#$35#$61; s: 'QIP 2005'), // QIP 2005
  (v: #$74#$ED#$C3#$36#$44#$DF#$48#$5B#$8B#$1C#$67#$1A#$1F#$86#$09#$9F; s: 'IM2'),

  (v: #$E3#$62#$C1#$E9#$12#$1A#$4B#$94#$A6#$26#$7A#$74#$DE#$24#$27#$0D; s: 'Push2Talk'),
  (v: #$B9#$97#$08#$B5#$3A#$92#$42#$02#$B0#$69#$F1#$E7#$57#$BB#$2E#$17; s: 'ICQ Voice Chat'),
  (v: #$67#$36#$15#$15#$61#$2D#$4C#$07#$8F#$3D#$BD#$E6#$40#$8E#$A0#$41; s: 'Xtraz MultiUser Chat'),
  (v: #$7E#$11#$B7#$78#$A3#$53#$49#$26#$A8#$02#$44#$73#$52#$08#$C4#$2A; s: 'Lsp-RU-Rambler'),
  (v: #$B6#$07#$43#$78#$F5#$0C#$4A#$C7#$90#$92#$59#$38#$50#$2D#$05#$91; s: 'ICQ-XVideo'),
  (v: #$01#$00#$11#$00#$00#$00#$00#$00#$11#$00#$00#$00#$00#$2a#$02#$b5; s: 'AIM'),
  (v: #$B2#$EC#$8F#$16#$7C#$6F#$45#$1B#$BD#$79#$DC#$58#$49#$78#$88#$B9; s: 'tZers'), // 21
  (v: #$01#$38#$CA#$7B#$76#$9A#$49#$15#$88#$F2#$13#$FC#$00#$97#$9E#$A8; s: 'ICQ6'),
  (v: #$D6#$68#$7F#$4F#$3D#$C3#$4b#$db#$8A#$8C#$4C#$1A#$57#$27#$63#$CD; s: 'R&Q-ProtectMsg'), // 23
  (v: #$7C#$73#$75#$02#$C3#$BE#$4F#$3E#$A6#$9F#$01#$53#$13#$43#$1E#$1A; s: 'qip Infium'),
  (v: #$56#$6D#$49#$43#$51#$20#$76#$30#$2E#$31#$2E#$34#$62#$00#$00#$00; s: 'vmICQ'),
  (v: #$7C#$53#$3F#$FA#$68#$00#$4F#$21#$BC#$FB#$C7#$D2#$43#$9A#$AD#$31; s: 'qip-plugins'),
  (v: #$56#$3F#$C8#$09#$0B#$6F#$41#$51#$49#$50#$20#$20#$20#$20#$20#$21; s: 'QIP PDA WM'),
  (v: #$51#$AD#$D1#$90#$72#$04#$47#$3D#$A1#$A1#$49#$F4#$A3#$97#$A4#$1F; s: 'QIP PDA Symbian'),
  (v: #$7A#$7B#$7C#$7D#$7E#$7F#$0A#$03#$0B#$04#$01#$53#$13#$43#$1E#$1A; s: 'qip 2010'),
  (v: #$35#$CA#$0A#$C9#$E4#$67#$48#$AB#$9D#$FA#$1D#$23#$41#$F0#$08#$32; s: 'tZers [Mults]'),
  (v: #$4D#$6F#$64#$20#$62#$79#$20#$4D#$69#$6B#$61#$6E#$6F#$73#$68#$69; s: 'R&Q build by Mikanoshi'),
  (v: #$F2#$3D#$D3#$84#$7B#$52#$40#$EC#$B5#$CE#$10#$64#$59#$A4#$C9#$7D; s: 'Buzz support')
  // (V: #$B7#$07#$43#$78#$F5#$0C#$77#$77#$97#$77#$57#$78#$50#$2D#$05#$70; s: 'Status [Sad]'),
  // (V: #$B7#$07#$43#$78#$F5#$0C#$77#$77#$97#$77#$57#$78#$50#$2D#$05#$75; s: 'Status [Free for chat]'),
  // (V: #$B7#$07#$43#$78#$F5#$0C#$77#$77#$97#$77#$57#$78#$50#$2D#$05#$76; s: 'Status [At home]'),
  // (V: #$B7#$07#$43#$78#$F5#$0C#$77#$77#$97#$77#$57#$78#$50#$2D#$05#$77; s: 'Status [At work]'),
  // (V: #$B7#$07#$43#$78#$F5#$0C#$77#$77#$97#$77#$57#$78#$50#$2D#$05#$78; s: 'Status [At Lunch]'),
  // (V: #$B7#$07#$43#$78#$F5#$0C#$77#$77#$97#$77#$57#$78#$50#$2D#$05#$79; s: 'Status [Angry]')
  // 8C543DFC69024D25BFFAC0D3419CAF30 -- ????
  );
// capIs2002    = {0x10, 0xcf, 0x40, 0xd1, 0x4c, 0x7f, 0x11, 0xd1, 0x82, 0x22, 0x44, 0x45, 0x53, 0x54, 0x00, 0x00};
// capStr20012  = {0xa0, 0xe9, 0x3f, 0x37, 0x4f, 0xe9, 0xd3, 0x11, 0xbc, 0xd2, 0x00, 0x04, 0xac, 0x96, 0xdd, 0x96};
  CapsMakeBig1 = AnsiString(#$09#$46);
  CapsMakeBig2 = AnsiString(#$4C#$7F#$11#$D1#$82#$22#$44#$45#$53#$54#$00#$00);

  // #$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00#$00  // Anti-invischeck
  msgUTFstr = '{0946134E-4C7F-11D1-8222-444553540000}';
  msgRTF: TGUID = '{97B12751-243C-4334-AD22-D6ABF73F1492}';
  msgRnQpass: TGUID = '{e92a62a2-e32a-49dc-acc6-22066bd4f316}';

  // Message types
  MTYPE_PLAIN = $01; // Plain text (simple) message
  MTYPE_CHAT = $02; // Chat request message
  MTYPE_FILEREQ = $03; // File request / file ok message
  MTYPE_URL = $04; // URL message (0xFE formatted)
  MTYPE_AUTHREQ = $06; // Authorization request message (0xFE formatted)
  MTYPE_AUTHDENY = $07; // Authorization denied message (0xFE formatted)
  MTYPE_AUTHOK = $08; // Authorization given message (empty)
  MTYPE_SERVER = $09; // Message from OSCAR server (0xFE formatted)
  MTYPE_ADDED = $0C; // "You-were-added" message (0xFE formatted)
  MTYPE_WWP = $0D; // Web pager message (0xFE formatted)
  MTYPE_EEXPRESS = $0E; // Email express message (0xFE formatted)
  MTYPE_CONTACTS = $13; // Contact list message
  MTYPE_PLUGIN = $1A; // Plugin message described by text string
  MTYPE_AUTOAWAY = $E8; // Auto away message
  MTYPE_AUTOBUSY = $E9; // Auto occupied message
  MTYPE_AUTONA = $EA; // Auto not available message
  MTYPE_AUTOFFC = $EC; // Auto free for chat message

  MTYPE_XSTATUS = $61;
  MTYPE_GCARD = $62;

  MTYPE_UNKNOWN = $00; // Unknown message, only used internally by this plugin

  MTYPE_AUTOMSGS = [MTYPE_AUTOAWAY, MTYPE_AUTOBUSY, MTYPE_AUTONA, MTYPE_AUTOFFC];

  PLUGIN_SCRIPT = AnsiString('Script Plug-in: Remote Notification Arrive');
  ACK_OK = 0;
  ACK_FILEDENY = 1;
  ACK_OCCUPIED = 9;
  ACK_AWAY = 4;
  ACK_NA = $E;
  ACK_NOBLINK = $C;

  MTN_FINISHED = $0000; // typing finished sign
  MTN_TYPED = $0001; // text typed sign
  MTN_BEGUN = $0002; // typing begun sign
  MTN_CLOSED = $000F; // Closed chat

type
  TICQAccept = (AC_OK, AC_DENIED, AC_AWAY);

  TICQError = (EC_rateExceeded, EC_cantConnect, EC_socket, EC_other, EC_badUIN,
    // at login-time, referred to my own uin
    EC_missingLogin, EC_anotherLogin, EC_serverDisconnected, EC_badPwd, EC_cantChangePwd,
    EC_loginDelay, EC_cantCreateUIN, EC_invalidFlap, EC_badContact, EC_cantConnect_dc,
    EC_proxy_error, EC_proxy_badPwd, EC_proxy_unk, // unknown reply
    EC_MalformedMsg, EC_AddContact_Error, EC_Login_Seq_Failed, EC_FailedDecrypt,
    EC_StoreProblem);

  TICQAuthError = (
    EAC_Not_Enough_Data = -1,
    EAC_Unknown = 0,
    EAC_OK = 200, // no error
    EAC_Wrong_Login = 330,
    EAC_Invalid_Request = 400,
    EAC_Auth_Required = 401,
    EAC_Req_Timeout = 408,
    EAC_Wrong_DevKey = 440,
    EAC_Missing_Param = 460,
    EAC_Param_Error = 462,
    EAC_Rate_Limit = 607
  );

const
  ICQError2Str: array [TICQError] of String =
    ('Server says you''re reconnecting too fastly, try later or change user.', // 'rate exceeded',
    'Cannot connect\n[%d] %s', // 'can''t connect',
    'Disconnected\n[%d] %s', // 'disconnected',
    'Unknown error', // 'unknown',
    'Your uin is not correct', // 'incorrect uin',
    'Missing password', // 'missing pwd',
    'Your current UIN is used by someone else right now, server disconnected you',
    // 'another login',
    'Server disconnected', // 'server disconnected',
    'Wrong password, correct it and try again', // 'wrong pwd',
    'Cannot change password', // 'can''t change pwd',
    'Server is sick, wait 2 seconds and try again', // 'delay',
    'Can''t create UIN', // 'can''t create uin',
    'FLAP level error', // 'invalid flap',
    'Queried contact is invalid', // 'bad contact',
    'can''t directly connect\n[%d] %s', 'proxy: error', 'PROXY: Invalid user/password',
    // 'proxy: wrong user/pwd',
    'PROXY: Unknown reply\n[%d] %s',      // 'proxy: unk'
    'Couldn''t parse incoming event\nRaw input:\n%s',
    'Failed to add contact\n%s',
    'Login sequence cannot be completed due to error on one of the stages',
    'Could''t decrypt message\n%s',
    'Failed to process store purchase\n%s');
(*
  ICQAuthErrors: array [330, 408] of String = (

    'Invalid nick or password', 'Service temporarily unavailable', 'All other errors',
    'Wrong password, correct it and try again', // 'AUTH_ERR_INCORR_NICK_OR_PASSWORD',
    'Mismatch nick or password, re-enter', 'Internal client error (bad input to authorizer)',
    'Invalid account', 'Deleted account', 'Expired account', 'No access to database', // $0A
    'No access to resolver', 'Invalid database fields', // $0C
    'Bad database status', 'Bad resolver status', 'Internal error', 'Service temporarily offline',
    // $10
    'Suspended account', 'DB send error', 'DB link error', 'Reservation map error',
    'Reservation link error', // $15
    'Too many clients from the same ip address',
    'Too many clients from the same ip address (reservation)',
    'Server says you''re reconnecting too fastly, try later or change user.',
    // 'AUTH_ERR_RESERVATION_RATE',        // $18
    'User too heavily warned', 'Reservation timeout', // $1A
    'You are using an older version of ICQ. Upgrade required', // $1B
    'You are using an older version of ICQ. Upgrade recommended',
    'Rate limit exceeded. Please try to reconnect in a few minutes', // $1D
    'Can ''t register on the ICQ network. Reconnect in a few minutes', // $1E
    'AUTH_ERR_SECURID_TIMEOUT', // upd, 2006: AUTH_ERR_TOKEN_SERVER_TIMEOUT
    'Invalid SecurID', // upd, 2006: AUTH_ERR_INVALID_TOKEN_KEY
    'AUTH_ERR_MC_ERROR', 'AUTH_ERR_CREDIT_CARD_VALIDATION', // upd 2006 // ...
    'AUTH_ERR_REQUIRE_REVALIDATION', // upd 2006
    'AUTH_ERR_LINK_RULE_REJECT', // upd 2006
    'AUTH_ERR_MISS_INFO_OR_INVALID_SNAC', // upd 2006
    'AUTH_ERR_LINK_BROKEN', // upd 2006
    'AUTH_ERR_INVALID_CLIENT_IP', // upd 2006
    'AUTH_ERR_PARTNER_REJECT', // upd 2006
    'AUTH_ERR_SECUREID_MISSING', // upd 2006
    'AUTH_ERR_BUMP_USER',
    'Failed to get all the data required for starting a new session'); // upd 2019
*)
type
  XStatusFlags = (xsf_Old, xsf_6);
  XStatusFlagsSet = set of XStatusFlags;

const
icq_missed_msgs:
array [0 .. 4] of string = ('Message was invalid', 'Message was too large', 'Message rate exceeded',
  'Sender too evil (sender warn level > your max_msgs_evil)',
  'You are too evil (sender max_msg_revil < your warn level)');

var
  // ExtStsStrings : array[low(aXStatus)..High(aXStatus),0..1] of string;
  // ExtStsStrings : array[low(XStatus6)..High(XStatus6)] of string;
  // ExtStsStrings : array[low(XStatusArray)..High(XStatusArray)] of string;
  ExtStsStrings: array [0 .. 0] of TXStatStr;
  StatusesArray: TStatusArray;

type
  TFileAbout = class(TObject)
    fPath: String;
    fName: String;
    Size: Int64;
    Processed: Int64;
    CheckSum: Cardinal;
  end;

const
  TLGServers: array [0 .. 1] of string = (TD_test_server_ip, TD_prod_server_ip );


implementation

uses
  SysUtils, RDUtils;

end.
