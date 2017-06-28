{
This file is part of R&Q.
Under same license
}
unit XMPP_proto;
{$I RnQConfig.inc}
{$I NoRTTI.inc}

interface
 uses
   RnQProtocol, themesLib,
 {$IFDEF UNICODE}
   AnsiClasses,
 {$ENDIF UNICODE}
   RDGlobal, RnQPics, XMPPcontacts;
     
const
 PROTO_VERSION_MAJOR   =  1;
 PROTO_VERSION_MINOR   =  $1;
 PROTO_VERSION = (Cardinal(PROTO_VERSION_MAJOR) shl 16) or (Cardinal(PROTO_VERSION_MINOR));
 Z=#0#0#0#0;


// For RnQ

type
//  TMRAvisibility = (mVI_invisible, mVI_privacy, mVI_normal, mVI_all, mVI_CL);
  TxmppVisibility = (mVI_normal, mVI_privacy);

  TMechanism = (SM_PLAIN, SM_MD5, SM_OAUTH, SM_OAUTH2, SM_GOOGLE, SM_SCRAM_SHA1,
                SM_SCRAM_SHA256, SM_SCRAM_SHA1_PLUS, SM_SCRAM_SHA256_PLUS);
  TMechsSet = set of TMechanism;

const
  MechanismNames: array[TMechanism] of String =
       ( 'PLAIN', 'DIGEST-MD5', 'XOAUTH', 'X-OAUTH2', 'X-GOOGLE-TOKEN', 'SCRAM-SHA-1',
         'SCRAM-SHA-256', 'SCRAM-SHA-1-PLUS', 'SCRAM-SHA-256-PLUS'
        );

const
  XMPPvisibility2ShowStr: array [TxmppVisibility] of String =
//       ('Invisible', 'Privacy (only visible-list)',
//        'Normal (all but invisible-list)', 'Visible to all', 'Visible to contact-list');
       ('Normal (all but invisible-list)', 'Privacy (only visible-list)');
  XMPPvisibility2imgName: array [TxmppVisibility] of AnsiString = (PIC_VISIBILITY_NORMAL, PIC_VISIBILITY_PRIVACY);
  XMPPvisib2str: array [TxmppVisibility] of AnsiString = ('normal', 'invisible');
//  MRAstatus2str: array [TMRAstatus] of AnsiString=('online','occupied','dnd','na','away',
//    'f4c','offline','unk');
//  MRAstatus2ShowStr: array [TMRAstatus] of string=('Online','Offline','Unknown',
//    'Occupied','Don''t disturb', 'N/A', 'Away', 'Free for chat');
  XMPPstatus2ShowStr: array [TXMPPstatus] of string =
     ('Online','Offline','Unknown','Away', 'Don''t disturb', 'N/A', 'Free for chat');
  XMPPstatus2Img: array [TXMPPstatus] of TPicName =
     ('online','offline','unk','away', 'dnd', 'na', 'f4c');
//  XMPPstatus2code: array[TXMPPstatus] of byte= (STATUS_ONLINE, STATUS_OFFLINE, STATUS_UNDETERMINATED, STATUS_AWAY);
  XMPPstatus2codeStr: array[TXMPPstatus] of UTF8String=
     ('', '', '', 'away', 'dnd', 'xa', 'chat');

//  function  statusNameExt2(s: TMRAstatus; extSts: byte = 0; Xsts: String = ''; sts6: String = ''):string;
  function  XMPPstatus2imgName(s: TXMPPstatus; inv: boolean=FALSE): AnsiString;
//  function  status2imgNameExt(s: TMRAstatus; inv: boolean=FALSE; extSts: byte= 0): String;
//  function  MRAvisibility2imgName(vi: TMRAvisibility): String;

const
  XMPPprefix = 'XMP_';
//  XMPP_GroupID_Ofs = 13;

const
  cXMPP_Servers: array[0..2] of string =('talk.google.com', 'xmpp.yandex.com', 'rnq.ru');
  cXMPP_MaxPWDLen = 255;
  cXMPP_Host2Servers: array[0..5] of string =('gmail.com', 'talk.google.com',
                   'yandex.ru', 'xmpp.yandex.com',
                   'ya.ru', 'xmpp.yandex.com');

type
  TXMPPflapQueue = class(Tobject)
//    buff: RawByteString;
    bff: TAnsiStringList;
    constructor create;
    procedure add(const s: RawByteString);
    procedure ReturnStr(const s: RawByteString);
//    function  error: boolean;     // errore di protocollo, è necessario invocare popError per continuare
//    function  errorTill: integer; // fino a questo byte i dati sono considerati errati
    function  available: boolean; // disponibilità di un pacchetto
    function  pop: RawByteString; // estrale il pacchetto
    function  popAll: RawByteString;
//    function  popError: AnsiString;   // estrae i dati errati dalla coda
//    function  bodySize: integer;
    function  str: RawByteString; //
    procedure reset;
    end; // TflapQueue

const
  // * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
  // XEP-0092: Software Version (jabber_iq_version)
  XEP0092_Software_Version
                 = 'jabber:iq:version';
  // XEP-0012: Last Activity
  XEP0012_Last_Activity
                 = 'jabber:iq:last';
  // XEP-0030: Service Discovery
  XEP0030_Service_Discovery
                 = 'http://jabber.org/protocol/disco#info';

  // XEP-0199: XMPP Ping (urn:xmpp:ping)
  XEP0199_XMPP_Ping
                 = 'urn:xmpp:ping';

  nsStream        = 'stream';

implementation
uses
 {$IFDEF UNICODE}
  AnsiStrings,
 {$ENDIF UNICODE}
  RnQbinUtils;

function  XMPPstatus2imgName(s: TXMPPstatus; inv: boolean=FALSE): TPicName;
begin
 if s in [LOW(TXMPPstatus)..HIGH(TXMPPstatus)] then
  result := 'status.' + XMPPstatus2img[s]
//   result := sta 'status.' + status2str[s]
 else
  result := 'status.' + XMPPstatus2img[SC_UNK];
if inv then
 result := INVIS_PREFIX + result;
end;

{function  MRAvisibility2imgName(vi: TMRAvisibility): String;
begin
 case vi of
   mVI_invisible: result := PIC_VISIBILITY_NONE;
//   mVI_privacy:  result := PIC_VISIBILITY_PRIVACY;
   mVI_normal:  result := PIC_VISIBILITY_NORMAL;
//   mVI_all:  result := PIC_VISIBILITY_ALL;
//   mVI_CL:  result := PIC_VISIBILITY_CL;
 end;
end;
}

////////////////////////////// FLAP QUEUE ////////////////////////////

constructor TXMPPflapQueue.create;
begin
  bff := TAnsiStringList.Create;
  reset
end;

procedure TXMPPflapQueue.reset;
begin
//  buff:=''
  bff.Clear;
end;

procedure TXMPPflapQueue.add(const s: RawByteString);
begin
//  buff:=buff+s
  bff.Add(s);
end;

procedure TXMPPflapQueue.ReturnStr(const s: RawByteString);
begin
  bff.Insert(0, s);
end;

{function TXMPPflapQueue.error:boolean;
begin
//error:=((length(buff)>4) and (cardinal(dword_LEat(@buff[1])) <> CS_MAGIC));
//  or ((length(buff)>1) and ((buff[2]=#0) or (buff[2]>#5)))
  result := False;
end; // error

function TXMPPflapQueue.errorTill:integer;
begin
result:=-1;
if buff='' then exit;
result:=1;
while (result<=length(buff)-4) and
       not ((buff[Result] = '<') and (buff[Result+1] = 'i')
            and (buff[Result+2] = 'q') and (buff[Result+3] = ' ')) do
  inc(result);
end; // errorTill

function TXMPPflapQueue.popError:AnsiString;
var
  i:integer;
begin
i:=errorTill;
result:=copy(buff,1,i);
delete(buff,1,i);
end; // popError
}
{function TXMPPflapQueue.bodySize:integer;
begin
  result:=word_LEat(@buff[17])
end;}

function TXMPPflapQueue.available: boolean;
begin
//result:=not error
//   and (length(buff) > 5)
  Result := bff.Count > 0;
end; // available

function TXMPPflapQueue.pop: RawByteString;
//var
//  i: Integer;
begin
 if not available then
 begin
  result := '';
  exit;
 end;
 Result := bff.Strings[0];
 bff.Delete(0);
//   Result := '';
end; // pop

function TXMPPflapQueue.popAll: RawByteString;
begin
  result := '';
  while available do
   begin
    Result := Result + bff.Strings[0];
    bff.Delete(0);
   end;
end;

function TXMPPflapQueue.str: RawByteString;
begin
 if not available then
 begin
  result := '';
  exit;
 end;
 Result := bff.Strings[0];
end; // pop

end.
