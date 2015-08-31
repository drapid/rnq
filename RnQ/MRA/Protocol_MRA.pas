unit Protocol_MRA;
{$I Compilers.inc}
{$I RnQConfig.inc}

interface
 uses
   Classes, MRAcontacts, outboxlib, events, MRAv1, MRA_proto,
   RnQProtocol, globalLib, viewMRAinfoDlg;


  procedure loggaMRAPkt(what:TwhatLog; data: AnsiString='');
//  function  findMRAViewInfo(c:TRnQContact):TviewMRAInfoFrm;


implementation

 uses
   OverbyteIcsWSocket,
   utilLib, Flap,
   RQUtil, RnQDialogs,
   rnqLangs, RnQStrings,
   RnQFileUtil,
   iniLib, mainDlg,
   pluginutil, pluginLib, SysUtils, RQGlobal,
   roasterLib, themesLib,
   chatDlg;


function GetPacketName(UL: Cardinal): String;
begin
  case UL of
    $1001 : Result:= 'CLI_MRIM_CS_HELLO';
    $1002 : Result:= 'SRV_MRIM_CS_HELLO_ACK';
    $1004 : Result:= 'SRV_MRIM_CS_LOGIN_ACK';
    $1005 : Result:= 'SRV_MRIM_CS_LOGIN_REJ';
    $1006 : Result:= 'CLI_MRIM_CS_PING';
    $1008 : Result:= 'CLI_MRIM_CS_MESSAGE';
    $1009 : Result:= 'SRV_MRIM_CS_MESSAGE_ACK';
    $1011 : Result:= 'CLI_MRIM_CS_MESSAGE_RECV';
    $1012 : Result:= 'SRV_MRIM_CS_MESSAGE_STATUS';
    $100F : Result:= 'SRV_MRIM_CS_USER_STATUS';
    $1013 : Result:= 'SRV_MRIM_CS_LOGOUT';
    $1014 : Result:= 'SRV_MRIM_CS_CONNECTION_PARAMS';
    $1015 : Result:= 'SRV_MRIM_CS_USER_INFO';
    $1019 : Result:= 'CLI_MRIM_CS_ADD_CONTACT';
    $101A : Result:= 'SRV_MRIM_CS_ADD_CONTACT_ACK';
    $101B : Result:= 'CLI_MRIM_CS_MODIFY_CONTACT';
    $101C : Result:= 'SRV_MRIM_CS_MODIFY_CONTACT_ACK';
    $101D : Result:= 'SRV_MRIM_CS_OFFLINE_MESSAGE_ACK';
    $101E : Result:= 'CLI_MRIM_CS_DELETE_OFFLINE_MESSAGE';
//    $100F : Result:= 'CLI_MRIM_CS_USER_STATUS';
    $1020 : Result:= 'CLI_MRIM_CS_AUTHORIZE';
    $1021 : Result:= 'SRV_MRIM_CS_AUTHORIZE_ACK';
    $1022 : Result:= 'CLI_MRIM_CS_CHANGE_STATUS';
    $1024 : Result:= 'CLI_MRIM_CS_GET_MPOP_SESSION';
    $1025 : Result:= 'SRV_MRIM_CS_MPOP_SESSION';
    $1026 : Result:= 'CLI_MRIM_CS_FILE_TRANSFER';
    $1027 : Result:= 'SRV_MRIM_CS_FILE_TRANSFER_ACK';
    $1029 : Result:= 'CLI_MRIM_CS_WP_REQUEST';
    $1028 : Result:= 'SRV_MRIM_CS_ANKETA_INFO';
    $1033 : Result:= 'SRV_MRIM_CS_MAILBOX_STATUS';
    $1037 : Result:= 'SRV_MRIM_CS_CONTACT_LIST2';
    $1038 : Result:= 'CLI_MRIM_CS_LOGIN2';
    $1039 : Result:= 'CLI_MRIM_CS_SMS';
    $1040 : Result:= 'SRV_MRIM_CS_SMS_ACK';
  else
    Result:= 'MRIM_UNKNOWN_' + IntToHex(UL, 8);
  end;
end;

procedure loggaMRAPkt(what:TwhatLog; data:AnsiString='');
var
  head,s:string;
  isPacket : Boolean;
begin
 s := '';
 isPacket := False;
 if Length(Data) > 10 then
   isPacket := cardinal(dword_LEat(@data[1])) = CS_MAGIC;
 if isPacket then
  if what in [WL_serverGot, WL_serverSent] then
//   if getFlapChannel(data) = SNAC_CHANNEL then
     s := '(' + IntToHex((getMRASnacService(data)), 2) + ') ';

 s:=s + LogWhatNames[what];
if data>'' then
  if what in [WL_CONNECTED, WL_DISCONNECTED, WL_connecting] then
    begin
    s:=s+' '+data;
    data:='';
    end
  else
    s:=s+' size:'+intToStr(length(data),4);

 if isPacket then
  case what of
   WL_serverGot, WL_serverSent:
     if length(data) >= 16 then
      s:=s+' ref:'+intToHex(getMRASnacRef(data),8)+' '+GetPacketName(getMRASnacService(data));
  end;

  head:=logtimestamp+s;
  logProtoPkt(what, head, data)
end; // loggaPkt

function findMRAViewInfo(c:TRnQcontact):TviewMRAInfoFrm;
var
  i:integer;
begin
with childWindows do
  begin
  i:=0;
  while i < count do
    begin
    if Tobject(items[i]) is TviewMRAInfoFrm then
      begin
      result:=TviewMRAInfoFrm(items[i]);
      if result.contact.equals(c) then
        exit;
      end;
    inc(i);
    end;
  end;
result:=NIL;
end; // findViewInfo


end.
