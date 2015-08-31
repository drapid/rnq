unit MRA_proto;
{$I Compilers.inc}
{$I RnQConfig.inc}

interface
   uses
     RnQProtocol, MRAContacts, themesLib;
     
const
 PROTO_VERSION_MAJOR   =  1;
 PROTO_VERSION_MINOR   =  $10;
 PROTO_VERSION = (Cardinal(PROTO_VERSION_MAJOR) shl 16) or (Cardinal(PROTO_VERSION_MINOR));
 CS_MAGIC =  $DEADBEEF;		// Клиентский Magic ( C <-> S )
 Z=#0#0#0#0;


type
  mrim_packet_header_t = record
    magic : cardinal;		// Magic
    proto,		// Версия протокола
    seq,		// Sequence
    msg,		// Тип пакета
    dlen, 	 // Длина данных
    from,		// Адрес отправителя
    fromport : Cardinal;	// Порт отправителя
    reserved : array [1..16] of char;	// Зарезервировано
  end;

(***************************************************************************

		ПРОТОКОЛ СВЯЗИ КЛИЕНТ-СЕРВЕР

 ***************************************************************************)
const
 MRIM_CS_HELLO   = $1001;  // C -> S
    // empty

 MRIM_CS_HELLO_ACK  = $1002;  // S -> C
    // mrim_connection_params_t

 MRIM_CS_LOGIN_ACK  = $1004;  // S -> C
    // empty
    
 MRIM_CS_LOGIN_REJ = $1005;  // S -> C
    // LPS reason
    
 MRIM_CS_PING      = $1006;  // C -> S
    // empty
    
 MRIM_CS_MESSAGE	 = $1008;  // C -> S

 	// UL flags
	// LPS to
	// LPS message
	// LPS rtf-formatted message (>=1.1)
	MESSAGE_FLAG_OFFLINE	 = $00000001;
	MESSAGE_FLAG_NORECV		 = $00000004;
	MESSAGE_FLAG_AUTHORIZE = $00000008; 	// X-MRIM-Flags: 00000008
	MESSAGE_FLAG_SYSTEM		 = $00000040;
	MESSAGE_FLAG_RTF		   = $00000080;
	MESSAGE_FLAG_CONTACT	 = $00000200;
	MESSAGE_FLAG_NOTIFY		 = $00000400;
	MESSAGE_FLAG_MULTICAST = $00001000;
  MESSAGE_FLAG_SMS_DELIVERY_REPORT = $00002000;

  MESSAGE_FLAG_UNK1 = $00200000; // Base64
 MAX_MULTICAST_RECIPIENTS = 50;
	MESSAGE_USERFLAGS_MASK = $000036A8;	// Flags that user is allowed to set himself

 MRIM_CS_MESSAGE_ACK	= $1009;  // S -> C
	// UL msg_id
	// UL flags
	// LPS from
	// LPS message
	// LPS rtf-formatted message (>=1.1)

	
 MRIM_CS_MESSAGE_RECV  = $1011;	// C -> S
	// LPS from
	// UL msg_id

 MRIM_CS_MESSAGE_STATUS = $1012;	// S -> C
	// UL status
	MESSAGE_DELIVERED	       = $0000; // Message delivered directly to user
	MESSAGE_REJECTED_NOUSER	 = $8001; // Message rejected - no such user
	MESSAGE_REJECTED_INTERR	 = $8003;	// Internal server error
	MESSAGE_REJECTED_LIMIT_EXCEEDED	= $8004; // Offline messages limit exceeded
	MESSAGE_REJECTED_TOO_LARGE	    = $8005; // Message is too large
	MESSAGE_REJECTED_DENY_OFFMSG    = $8006; // User does not accept offline messages

 MRIM_CS_USER_STATUS = $100F;	// S -> C
	// UL status
	STATUS_OFFLINE	      = $00000000;
	STATUS_ONLINE		      = $00000001;
	STATUS_AWAY		        = $00000002;
	STATUS_UNDETERMINATED	= $00000003;
  STATUS_USER_DEFINED   = $00000004; // xStatus 
	STATUS_FLAG_INVISIBLE	= $80000000;
	// LPS user

	
 MRIM_CS_LOGOUT	 = $1013;	// S -> C
	// UL reason
	LOGOUT_NO_RELOGIN_FLAG = $0010;		// Logout due to double login
	
 MRIM_CS_CONNECTION_PARAMS = $1014;	// S -> C
	// mrim_connection_params_t

 MRIM_CS_USER_INFO	= $1015;  // S -> C
	// (LPS key, LPS value)* X
	
			
 MRIM_CS_ADD_CONTACT	 = $1019; // C -> S
	// UL flags (group(2) or usual(0) 
	// UL group id (unused if contact is group)
	// LPS contact
	// LPS name
	// LPS unused
	CONTACT_FLAG_REMOVED   = $00000001;
	CONTACT_FLAG_GROUP	   = $00000002;
	CONTACT_FLAG_INVISIBLE = $00000004;
	CONTACT_FLAG_VISIBLE	 = $00000008;
	CONTACT_FLAG_IGNORE	   = $00000010;
	CONTACT_FLAG_SHADOW	   = $00000020;
  CONTACT_FLAG_MOBILE    = $00100000;
	
 MRIM_CS_ADD_CONTACT_ACK	= $101A;	// S -> C
	// UL status
	// UL contact_id or (u_long)-1 if status is not OK
	
	CONTACT_OPER_SUCCESS = $0000;
	CONTACT_OPER_ERROR	 = $0001;
	CONTACT_OPER_INTERR	 = $0002;
	CONTACT_OPER_NO_SUCH_USER	= $0003;
	CONTACT_OPER_INVALID_INFO	= $0004;
	CONTACT_OPER_USER_EXISTS	= $0005;
	CONTACT_OPER_GROUP_LIMIT	= $6;
	
 MRIM_CS_MODIFY_CONTACT	 = $101B; // C -> S
	// UL id
	// UL flags - same as for MRIM_CS_ADD_CONTACT
	// UL group id (unused if contact is group)
	// LPS contact
	// LPS name
	// LPS unused
	
 MRIM_CS_MODIFY_CONTACT_ACK	 = $101C; // S -> C
	// UL status, same as for MRIM_CS_ADD_CONTACT_ACK

 MRIM_CS_OFFLINE_MESSAGE_ACK	= $101D; // S -> C
	// UIDL
	// LPS offline message

 MRIM_CS_DELETE_OFFLINE_MESSAGE	 = $101E; // C -> S
	// UIDL


 MRIM_CS_AUTHORIZE	= $1020; // C -> S
	// LPS user
	
 MRIM_CS_AUTHORIZE_ACK = $1021; // S -> C
	// LPS user

 MRIM_CS_CHANGE_STATUS	= $1022;	// C -> S
	// UL new status


 MRIM_CS_GET_MPOP_SESSION	= $1024;	// C -> S
	
	
 MRIM_CS_GET_MPOP_SESSION_ACK	 = $1025; // S -> C
	MRIM_GET_SESSION_FAIL	   = 0;
	MRIM_GET_SESSION_SUCCESS = 1;
	//UL status 
	// LPS mpop session

//white pages!
 MRIM_CS_WP_REQUEST	 = $1029; //C->S
//DWORD field, LPS value
 PARAMS_NUMBER_LIMIT	= 50;
 PARAM_VALUE_LENGTH_LIMIT	= 64;

//if last symbol in value eq '*' it will be replaced by LIKE '%' 
// params define
// must be in consecutive order (0..N) to quick check in check_anketa_info_request
  MRIM_CS_WP_REQUEST_PARAM_USER      = 0;
  MRIM_CS_WP_REQUEST_PARAM_DOMAIN    = 1;
  MRIM_CS_WP_REQUEST_PARAM_NICKNAME  = 2;
  MRIM_CS_WP_REQUEST_PARAM_FIRSTNAME = 3;
  MRIM_CS_WP_REQUEST_PARAM_LASTNAME  = 4;
  MRIM_CS_WP_REQUEST_PARAM_SEX       = 5;
  MRIM_CS_WP_REQUEST_PARAM_BIRTHDAY  = 6;
  MRIM_CS_WP_REQUEST_PARAM_DATE1     = 7;
  MRIM_CS_WP_REQUEST_PARAM_DATE2     = 8;
  //!!!!!!!!!!!!!!!!!!!online request param must be at end of request!!!!!!!!!!!!!!!
  MRIM_CS_WP_REQUEST_PARAM_ONLINE    = 9;
  MRIM_CS_WP_REQUEST_PARAM_STATUS    = 10; // we do not used it, yet
  MRIM_CS_WP_REQUEST_PARAM_CITY_ID   = 11;
  MRIM_CS_WP_REQUEST_PARAM_ZODIAC    = 12;
  MRIM_CS_WP_REQUEST_PARAM_BIRTHDAY_MONTH = 13;
  MRIM_CS_WP_REQUEST_PARAM_BIRTHDAY_DAY   = 14;
  MRIM_CS_WP_REQUEST_PARAM_COUNTRY_ID     = 15;
//  MRIM_CS_WP_REQUEST_PARAM_MAX       = 16;
  MRIM_CS_WP_REQUEST_PARAM_LOCATION  = 16;
  MRIM_CS_WP_REQUEST_PARAM_PHONE     = 17;
  MRIM_CS_WP_REQUEST_PARAM_MAX       = 18;

MRIM_CS_ANKETA_INFO = $1028; //S->C
//DWORD status
MRIM_ANKETA_INFO_STATUS_OK = 1;
MRIM_ANKETA_INFO_STATUS_NOUSER = 0;
MRIM_ANKETA_INFO_STATUS_DBERR = 2;
MRIM_ANKETA_INFO_STATUS_RATELIMERR = 3;
//DWORD fields_num
//DWORD max_rows
//DWORD server_time sec since 1970 (unixtime)
// fields set //%fields_num == 0
//values set //%fields_num == 0
//LPS value (numbers too)


MRIM_CS_MAILBOX_STATUS = $1033;
//DWORD new messages in mailbox


MRIM_CS_CONTACT_LIST2 = $1037; //S->C
// UL status
GET_CONTACTS_OK = $0000;
GET_CONTACTS_ERROR = $0001;
GET_CONTACTS_INTERR = $0002;
//DWORD status - if ...OK than this staff:
//DWORD groups number
//mask symbols table:
//'s' - lps
//'u' - unsigned long
//'z' - zero terminated string 
//LPS groups fields mask 
//LPS contacts fields mask 
//group fields
//contacts fields
//groups mask 'us' == flags, name
//contact mask 'uussuu' flags, flags, internal flags, status
CONTACT_INTFLAG_NOT_AUTHORIZED = $0001;


//old packet cs_login with cs_statistic
MRIM_CS_LOGIN2  = $1038; // C -> S
MAX_CLIENT_DESCRIPTION = 256;
// LPS login
// LPS password
// DWORD status
//+ statistic packet data:
// LPS client description //max 256


 // By Rapid D
MRIM_CS_SMS_SEND = $00001039;
// DWORD Some
// LPS To
// LPS Message

MRIM_CS_SMS_ACK  = $00001040;

 MRIM_CS_FILE_TRANSFER = $1026;
        //LPS TO/FROM
        //DWORD id_request - uniq per connect 
        //DWORD FILESIZE 
        //LPS:  //LPS Files (FileName;FileSize;FileName;FileSize;) 
                //LPS DESCRIPTION 
                //LPS Conn (IP:Port;IP:Port;)
 MRIM_CS_FILE_TRANSFER_ACK = $1027; // S->C
        //DWORD status
         FILE_TRANSFER_STATUS_OK =                1 ;
         FILE_TRANSFER_STATUS_DECLINE =           0 ;
         FILE_TRANSFER_STATUS_ERROR =             2 ;
         FILE_TRANSFER_STATUS_INCOMPATIBLE_VERS = 3 ;
         FILE_TRANSFER_MIRROR   =                 4 ;
        //LPS TO/FROM 
        //DWORD id_request 
        //LPS DESCRIPTION

MRIM_CS_FILE_TRANSFER_SERV_REQ   = $1044;
MRIM_CS_FILE_TRANSFER_SERV_REPLY = $1045;


MRIM_CS_NEW_MAIL = $1048; //S->C
// UL How many LPS
// LPS From
// LPS Subject
// DWORD time
// DWORD Some


// For RnQ

type
//  TMRAvisibility=(mVI_invisible, mVI_privacy, mVI_normal, mVI_all, mVI_CL);
  TMRAvisibility=(mVI_normal, mVI_privacy);

const
  MRAvisibility2ShowStr : array [TMRAvisibility] of AnsiString =
//       ('Invisible', 'Privacy (only visible-list)',
//        'Normal (all but invisible-list)', 'Visible to all', 'Visible to contact-list');
       ('Normal (all but invisible-list)', 'Privacy (only visible-list)');
  MRAvisibility2imgName : array [TMRAvisibility] of AnsiString = (PIC_VISIBILITY_NORMAL, PIC_VISIBILITY_PRIVACY);
  MRAvisib2str:array [TMRAvisibility] of string=('normal', 'invisible');
//  MRAstatus2str:array [TMRAstatus] of AnsiString=('online','occupied','dnd','na','away',
//    'f4c','offline','unk');
//  MRAstatus2ShowStr:array [TMRAstatus] of string=('Online','Offline','Unknown',
//    'Occupied','Don''t disturb', 'N/A', 'Away', 'Free for chat');
  MRAstatus2ShowStr:array [TMRAstatus] of string=('Online','Offline','Unknown','Away');
  MRAstatus2Img:array [TMRAstatus] of AnsiString=('online','offline','unk','away');
  MRAstatus2code : array[TMRAStatus] of byte= (STATUS_ONLINE, STATUS_OFFLINE, STATUS_UNDETERMINATED, STATUS_AWAY);
  MRAstatus2codeStr : array[TMRAStatus] of AnsiString=
     ('STATUS_ONLINE', 'STATUS_OFFLINE', 'STATUS_UNDETERMINATED', 'STATUS_AWAY');

//  function  statusNameExt2(s:TMRAstatus; extSts : byte = 0; Xsts : String = ''; sts6 : String = ''):string;
  function  MRAstatus2imgName(s:TMRAstatus; inv:boolean=FALSE):String;
//  function  status2imgNameExt(s:TMRAstatus; inv:boolean=FALSE; extSts : byte= 0):String;
//  function  MRAvisibility2imgName(vi:TMRAvisibility):String;

const
  MRAprefix = 'MRA_';
  MRA_GroupID_Ofs = 13;

//const
//  MRAServers : array[0..0] of string =('mrim.mail.ru');

const
{  MRAXStatusArray : array[0..0] of record
                                pid : AnsiString;
                                PicName : AnsiString;
                                Caption : String;
                        end =
    ((pid: ''; PicName: 'st_custom.none'; Caption: 'None')
    );
}
  MRAXStatusArray: array [0..50] of string = ('',
	'status_5',     'status_18',   	  'status_19',
 	'status_7', 	  'status_10',  	  'status_47',
  'status_22',    'status_26',	    'status_24',
 	'status_27',    'status_23',    	'status_4',
	'status_9',     'status_6',	      'status_21',
 	'status_20',    'status_17',   	  'status_8',
	'status_15',    'status_16',	    'status_28',
 	'status_51',    'status_52',      'status_46',
	'status_12',    'status_13',   	  'status_11',
 	'status_14',    'status_48',   	  'status_53',
	'status_29',    'status_30',  	  'status_32',
 	'status_33',    'status_40',    	'status_41',
  'status_34', 	  'status_35',    	'status_36',
 	'status_37',    'status_38',  	  'status_39',
	'status_42',    'status_43',      'status_49',
	'status_44',    'status_45',  	  'status_50',
  'status_chat',  'status_dnd'
  );

var
  MRAExtStsStrings : array[low(MRAXStatusArray)..High(MRAXStatusArray)] of TXStatStr;

type
  TMRAflapQueue=class(Tobject)
    buff: AnsiString;
    constructor create;
    procedure add(s:AnsiString);
    function  error:boolean;     // errore di protocollo, и necessario invocare popError per continuare
    function  errorTill:integer; // fino a questo byte i dati sono considerati errati
    function  available:boolean; // disponibilitа di un pacchetto
    function  pop:AnsiString;        // estrale il pacchetto
    function  popError:string;   // estrae i dati errati dalla coda
    function  bodySize:integer;
    procedure reset;
    end; // TflapQueue

 
implementation
   uses
     flap;

function  MRAstatus2imgName(s:TMRAstatus; inv:boolean=FALSE):String;
begin
 if s in [LOW(TMRAstatus)..HIGH(TMRAstatus)] then
  result := 'status.' + MRAstatus2img[s]
//   result := sta 'status.' + status2str[s]
 else
  result := 'status.' + MRAstatus2img[SC_UNK];
if inv then
 result := INVIS_PREFIX + result;
end;

{function  MRAvisibility2imgName(vi:TMRAvisibility):String;
begin
 case vi of
   mVI_invisible:result:=PIC_VISIBILITY_NONE;
//   mVI_privacy:  result:=PIC_VISIBILITY_PRIVACY;
   mVI_normal :  result:=PIC_VISIBILITY_NORMAL;
//   mVI_all    :  result:=PIC_VISIBILITY_ALL;
//   mVI_CL     :  result:=PIC_VISIBILITY_CL;
 end;
end;
}

////////////////////////////// FLAP QUEUE ////////////////////////////

constructor TMRAflapQueue.create;
begin reset end;

procedure TMRAflapQueue.reset;
begin buff:='' end;

procedure TMRAflapQueue.add(s:AnsiString);
begin buff:=buff+s end;

function TMRAflapQueue.error:boolean;
begin
error:=((length(buff)>4) and (cardinal(dword_LEat(@buff[1])) <> CS_MAGIC));
//  or ((length(buff)>1) and ((buff[2]=#0) or (buff[2]>#5)))
end; // error

function TMRAflapQueue.errorTill:integer;
begin
result:=-1;
if buff='' then exit;
result:=1;
while (result<=length(buff)-4) and
      ((cardinal(dword_LEat(@buff[1])) <> CS_MAGIC)) do
  inc(result);
end; // errorTill

function TMRAflapQueue.popError:string;
var
  i:integer;
begin
i:=errorTill;
result:=copy(buff,1,i);
delete(buff,1,i);
end; // popError

function TMRAflapQueue.bodySize:integer;
begin result:=word_LEat(@buff[17]) end;

function TMRAflapQueue.available:boolean;
begin
result:=not error
   and (length(buff) >= SizeOf(mrim_packet_header_t))   // bodysize exists only if this is true
   and (length(buff) >= SizeOf(mrim_packet_header_t) + bodySize)
end; // available

function TMRAflapQueue.pop:string;
begin
if not available then
  begin
  result:='';
  exit;
  end;
result:= copy(buff, 1, SizeOf(mrim_packet_header_t)+bodysize);
delete(buff,1, SizeOf(mrim_packet_header_t)+bodySize);
end; // pop


end.
