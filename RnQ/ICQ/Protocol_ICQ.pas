{
This file is part of R&Q.
Under same license
}
unit Protocol_ICQ;
{$I RnQConfig.inc}
{$I NoRTTI.inc}

interface
 uses
   Windows, Classes,
   outboxlib, events, RDGlobal,
  {$IFDEF usesDC}
     filetransferDlg,
     sendfileDlg,
  {$ENDIF usesDC}
   RnQProtocol,
   RQ_ICQ, ICQcontacts, ICQv9, ICQConsts,
   globalLib, viewinfoDlg;


  {$IFDEF usesDC}
//  procedure receiveFile2(thisICQ : TicqSession; evID : Int64; fromCnt : TContact; fn : String);
//  procedure receiveFile2(d : Tdirect);
  procedure receiveFile(d: TProtoDirect);
  procedure ICQsendfile(c: TICQContact; const fn: string);
//  function  sendICQfiles(uin:TUID; files, msg:string):integer;
  function sendICQfiles(cnt: TRnQContact; files : TFilePacket; msg: string;
              useLocProxy: Boolean; ThrSrv: Boolean; var drct: TICQdirect): integer;
  function  findSendFile(id: Int64): TsendfileFrm;
  function  findRcvFile(id: Int64): TfiletransferFrm;
  {$ENDIF usesDC}

  function  enterICQpwd(const thisICQ: TRnQProtocol): boolean;
  //function  addToRoster(c:Tcontact):boolean; overload;
  procedure sendICQcontacts(cnt: TRnQContact; flags: integer; cl: TRnQCList);
  procedure sendICQaddedYou(cnt: TRnQContact);
  procedure sendICQautomsgreq(cnt: TRnQContact);
  procedure ChangeXStatus(pICQ: TICQSession; const st: Byte;
                          const StName: String = ''; const StText: String = ''
                          ;const ChgdUseOldXSt: Boolean = false);

  procedure loggaICQPkt(const prefix: String; what: TwhatLog; data: RawByteString='');
//  function  findICQViewInfo(c:TRnQContact):TviewInfoFrm;
  procedure ProcessICQEvents(var thisICQ: TICQSession; ev: TicqEvent);


  //function  statusName(s:Tstatus):string;
  function  statusNameExt2(s: byte; extSts : byte = 0; const Xsts: String = ''; const sts6: String = ''): string;
  function  status2imgName(s: byte; inv: boolean=FALSE): TPicName;
  function  status2imgNameExt(s: byte; inv: boolean=FALSE; extSts: byte= 0): TPicName;
//  function  visibility2imgName(vi:Tvisibility):String;
  function  visibilityName(vi: Tvisibility): string;
  function  contactlist2clb(cl: TRnQCList): AnsiString;
  function  clb2contactlist(data: RawByteString): TRnQCList;
  function  str2status(const s: RawByteString): byte;
  function  str2visibility(const s: RawByteString): Tvisibility;

  function  getRnQVerFor(c: TRnQContact): Integer;

  procedure updateClients(pr: TRnQProtocol);

  procedure openICQURL(pr: TRnQProtocol; const pURL: String);

implementation

 uses
   Forms, SysUtils, DateUtils,
   Types, OverbyteIcsWSocket,
 {$IFDEF UNICODE}
   AnsiStrings, AnsiClasses, WideStrUtils,
 {$ENDIF}
   RnQBinUtils, RnQNet, RQUtil, RnQDialogs, RQlog,
//   RnQProtocol,
   rnqLangs, RnQStrings, RQThemes, RnQFileUtil, RDUtils,
   RnQTips, RDtrayLib, RnQGlobal, RnQPics,
   NetEncoding, cHash, Base64,
 {$IFDEF RNQ_AVATARS}
  RnQ_Avatars,
 {$ENDIF}
   utilLib,
   ICQflap,
   wpDlg,
   ICQClients, ICQ.Stickers,
   iniLib, mainDlg,
   pluginutil, pluginLib,
   roasterLib, themesLib,
   history, chatDlg;



function enterICQpwd(const thisICQ: TRnQProtocol): boolean;
var
//  s: AnsiString;
  s: String;
  res: boolean;
  myInf: TRnQContact;
//    i: Integer;
begin
  result := FALSE;
  if enteringICQpwd then exit;
  enteringICQpwd:=TRUE;
  if not Assigned(thisICQ) or
    ((thisICQ is TicqSession) and TicqSession(thisICQ).saveMD5Pwd) then
    s := ''
   else
    s := thisICQ.pwd;
  res:=enterPwdDlg(s, getTranslation('Login password') + ' (' + RnQUser + ')',16);
  if res then
   begin
    if Length(s) > maxPwdLength then
     begin
      msgDlg('Password too long', True, mtError);
      enteringICQpwd := FALSE;
      exit;
     end;
    if thisICQ is TicqSession then
      begin
        myInf := thisICQ.getMyInfo;
        if Assigned(myInf) then
         if not tICQcontact(myInf).isAIM then
          if Length(s) > 8 then
           begin
             msgDlg('Please enter only first 8 symbols of your password', True, mtInformation);
      //     exit;
           end;
      end;
   end;

  enteringICQpwd := FALSE;
  if not res or (s='') then exit;

{  if thisICQ.ProtoElem is TicqSession then
    if LoginMD5 and saveMD5Pwd then
      s := MD5Pass(s);}
  thisICQ.pwd:=s;
//  saveCFG;
  if not dontSavePwd then
    saveCfgDelayed := True;
  result := TRUE;
end; // enterICQpwd

procedure sendICQaddedYou(cnt: TRnQContact);
var
//  c:Tcontact;
  ev: THevent;
begin
//  c:=Tcontact(contactsDB.get(TICQContact, uin));
  plugins.castEv( PE_ADDEDYOU_SENT, cnt.uid);
  TicqSession(cnt.fProto).sendAddedYou(cnt.uid);
  ev := Thevent.new(EK_ADDEDYOU, cnt.fProto.getMyInfo, now,
                  ''{$IFDEF DB_ENABLED},''{$ENDIF DB_ENABLED}, 0);
  ev.fIsMyEvent := True;
  if logpref.writehistory and (BE_save in behaviour[ev.kind].trig) then
    writeHistorySafely(ev, cnt);
  chatFrm.addEvent_openchat(cnt, ev);
end; // sendICQaddedYou

procedure sendICQcontacts(cnt: TRnQContact; flags: integer; cl: TRnQCList);
var
  ev: THevent;
//  c:Tcontact;
begin
//  c:=Tcontact(contactsDB.get(TICQContact, uin));
  plugins.castEv( PE_CONTACTS_SENT, cnt.uid, flags, cl);
  TicqSession(cnt.fProto).sendContacts(cnt, flags, cl);
  ev := Thevent.new(EK_CONTACTS, cnt.fProto.getMyInfo, now,
                  cl.tostring{$IFDEF DB_ENABLED},''{$ENDIF DB_ENABLED}, flags);
  ev.fIsMyEvent := True;
  if logpref.writehistory and (BE_save in behaviour[ev.kind].trig) then
    writeHistorySafely(ev, cnt);
  chatFrm.addEvent_openchat(cnt, ev);
end; // sendICQcontacts

procedure sendICQautomsgreq(cnt: TRnQContact);
var
  oe: Toevent;
begin
  oe := Toevent.create(OE_automsgreq);
  //oe.uid := uin;
  oe.whom := cnt;
  oe.timeSent := now;
  oe.ID := TicqSession(cnt.fProto).sendAutoMsgReq(cnt.uid);
  plugins.castEv( PE_AUTOMSG_REQ_SENT, cnt.uid);
  Account.acks.add(oe);
end; // sendICQautomsgreq

{$IFDEF usesDC}
//function sendICQfiles(uin: TUID; files, msg: string): integer;
function sendICQfiles(cnt: TRnQContact; files: TFilePacket; msg: string;
            useLocProxy: Boolean; ThrSrv: Boolean; var drct: TICQdirect): integer;
//var
//  ss: Tstrings;
//  i, size: integer;
//  drct: Tdirect;
begin
  Result := -1;
//  if not OnlFeature(icq) then
//    Exit;
//  ss := TstringList.create;
//  ss.Text := files;
//  ss.Text := files;
  if files.count=1 then
   begin
//    size := TFileAbout(files.FileList.Objects[0]).Size;
//    result := ICQ.sendFileReq(uin, msg, extractFileName(files.FileList.Strings[0]), size)
//    result := ICQ.sendFileReq(uin, msg, TFileAbout(files.FileList.Objects[0]), useProxy)
//    result := ICQ.sendFileTest($FF, contactsDB.get(uin), extractFileName(files.FileList.Strings[0]), size)
      drct := TICQSession(cnt.fProto).directTo(TICQContact(cnt));
      drct.imserver := True;
      drct.imsender := True;
      drct.kind := DK_file;
      drct.fileDesc := msg;
      drct.stage := 1;
      drct.UseLocProxy := useLocProxy;
      with TFileAbout(files.FileList.Objects[0]) do
       begin
        drct.fileName := fName;
        drct.fileChkSum := CheckSum;
        drct.fileSizeTotal := Size;
       end;
      if ThrSrv then
        drct.mode := dm_bin_proxy
       else
       drct.mode := dm_bin_direct;
      drct.eventID := UInt64(-1);
      result := TICQSession(cnt.fProto).sendFileReqPro(drct)
   end
  else
   begin
//    size:=0;
//    for i:=0 to files.FileList.Count-1 do
//      inc(size, TFileAbout(files.FileList.Objects[i]).Size);
//    result:=ICQ.sendFileReq(uin, msg, intToStr(files.count)+' files', size);
   end;
end; // sendICQfiles

//procedure receiveFile2(thisICQ: TicqSession; evID: Int64; fromCnt: TContact;
//                       fn: String);
procedure receiveFile(d: TProtodirect);
//var
//  d: Tdirect;
begin
 {$IFNDEF usesDC}
    msgDlg(getTranslation('%s - would like to send you file "%s"', [fromCnt.displayed, thisICQ.eventFilename]),  mtInformation);
    thisICQ.sendFileAbort(fromCnt, thisICQ.eventMsgID);
 {$ELSE usesDC}
{   d := thisICQ.directTo(fromCnt);
   d.eventID  := evID;
   d.kind := DK_file;
   d.fileName := fn;
   d.imSender := False;
   d.mode := dm_bin_direct;
   d.stage := 1;}
  TfiletransferFrm.doAll(d);
//  TfiletransferFrm.doAll(thisICQ, evID, fromCnt, fn);
 {$ENDIF usesDC}
end; // receiveFile


{
procedure receiveFile(d: Tdirect);
begin
  TfiletransferFrm.doAll(d);
  if not (d.sock.State in [wsListening, wsConnecting, wsSocksConnected, wsConnected]) then
    d.connect;
end; // receiveFile
}

procedure ICQsendfile(c: TICQcontact; const fn: string);
//var
//  d: TDirect;
begin
//  d := TICQSession(c.iProto.ProtoElem).directTo(c);
//  d.fileName := fn;
//  TfiletransferFrm.doAll(d);
//  direct.connect;
  TsendFileFrm.doAll(mainDlg.RnQmain, c, fn);

end; // sendfile
{$ENDIF usesDC}

procedure ChangeXStatus(pICQ: TICQSession; const st: Byte;
        const StName: String = ''; const StText: String = ''
       ;const ChgdUseOldXSt: Boolean = false);
var
  b: Boolean;
begin
  if (st in [Low(XStatusArray)..High(XStatusArray)])
//     and ((UseOldXSt and (xsf_Old in XStatusArray[st].flags))
//        or (xsf_6 in XStatusArray[st].flags))
        then
  begin
    b := pICQ.curXStatus <> st;
//    if StName > '' then
     if StName <> getTranslation(ExtStsStrings[st].Cap) then
      begin
       b := True;
       ExtStsStrings[st].Cap  := Copy(StName, 1, 100);
      end;
//    if StText > '' then
     if StText <> getTranslation(ExtStsStrings[st].Desc) then
      begin
       b := True;
       ExtStsStrings[st].Desc := Copy(StText, 1, 255);
      end;

//    RnQmain.sBar.Repaint;
    if b then
     begin
      pICQ.setStatusStr(st, ExtStsStrings[st]);
      RnQmain.PntBar.Repaint;
//      saveListsDelayed := True;
      saveCfgDelayed := True;
//    SaveExtSts;
     end;
  end;
end;

function getDescForSnac(const s: RawByteString): string;
begin
case getSnacService(s) of
  $0102: result := 'ready';
  $0103: result := 'supported snac families list';
  $0104: result := 'request service';
  $0105: result := 'redirect to requested service';
  $0106: result := 'rates request';
  $0107: result := 'rates';
  $0108: result := 'rates ack';
  $010A: result := 'rate update or warning';
  $010B: result := 'server pause';
  $010C: result := 'client pause ack';
  $010D: result := 'server resume';
  $010E: result := 'my info request';
  $010F: result := 'my info';
  $0113: result := 'motd';
  $0115: result := 'list of well known urls';
  $0117: result := 'i''m icq';
  $0118: result := 'you''re icq';
  $011E: result := 'set status';
  $0121: result := 'own extended status';
  $0202: result := 'location rights request';
  $0203: result := 'location rights';
  $0204: result := 'set capabilities';
  $0205: result := 'user info request';
  $0206: result := 'user info';
  $0302: result := 'buddy rights request';
  $0303: result := 'buddy rights';
  $0304: result := '+roster';
  $0305: result := '-roster';
  $030a: result := 'can''t notify';
  $030b: result := 'oncoming/new status';
  $030c: result := 'offgoing';
  $0401: result := 'error msg';
  $0402: result := 'im rights request';
  $0404: result := 'im rights request';
  $0405: result := 'im rights';
  $0406: result := 'out msg';
  $0407: result := 'in msg';
  $040B: result := 'ack msg';
  $040C: result := 'server ack msg';
  $0410: result := 'ICBM: offline messages request';
  $0414: result := 'typing notification';
  $0417: result := 'ICBM: no more offline msgs';
  $0902: result := 'bos rights request';
  $0903: result := 'bos rights';
  $0905: result := '+visible';
  $0906: result := '-visible';
  $0907: result := '+invisible';
  $0908: result := '-invisible';
  $0B02: result := 'min stats report interval';
  $1006: result := 'avatar request';
  $1007: result := 'avatar';
  $1301: result := 'client or server error';
  $1302: result := 'SSI limits request';
  $1303: result := 'SSI limits response';
  $1304: result := 'contact list request';
  $1305: result := 'contact list check request';
  $1306: result := 'reply CL';
  $1307: result := 'activate server-side contact list';
  $1308: result := 'SSI edit: add item(s)';
  $1309: result := 'SSI edit: update item(s)';
  $130A: result := 'SSI edit: remove item(s)';
  $130E: result := 'SSI edit server ack';
  $130F: result := 'client local SSI is up-to-date';
  $1311: result := 'SSI edit: Start transaction';
  $1312: result := 'SSI edit: End transaction';
  $1314: result := 'grant future auth';
  $1315: result := 'future auth granted';
  $1316: result := 'delete yoursef from another CL';
  $1318: result := 'request auth';
  $1319: result := 'auth request';
  $131a: result := 'reply to auth';
  $131b: result := 'auth reply';
  $131c: result := 'you were added';
  $1502:
    case getMPservice(s) of
      $3C: result := 'offline msgs request';
      $3E: result := 'delete offline msgs';
      $D098: result := 'xml';
      $D01F,
      $D069: result := 'ask short contact info';
      $D0BA: result := 'ask short contact info (2001)';
      $D0B2: result := 'ask contact info';
      $D015: result := 'ask wp (short)';
      $D05F: result := 'ask wp (short) (2001)';
      $D033: result := 'ask wp (full)';
      $D0D0: result := 'ask my contact info';
      $D0EA: result := 'save my info (home)';
      $D0FD: result := 'save my info (hp/more)';
      $D006: result := 'save my info (about)';
      $D0F3: result := 'save my info (work)';
      $D00B: result := 'save my info (emails)';
      $D010: result := 'save my info (interests)';
      $D02E: result := 'change password';
      $D0C4: result := 'remove user';
      $D024: result := 'set permissions';
      $D082: result := 'out sms';
      $D029: result := 'search by email';
      $D073: result := 'search by email (2001)';
      else result := 'out multipurpose';
      end;
  $1503:
    case getMPservice(s) of
      $41: result := 'offline msg';
      $42: result := 'no more offline msgs';
      $DA9A,
      $DAA4: result := 'short contact info';
      $DAAE: result := 'short contact info (last)';
      $DAE6: result := 'contact info (about)';
      $DAC8: result := 'contact info (main)';
      $DADC: result := 'contact info (hp)';
      $DAD2: result := 'contact info (work)';
      $DA0E: result := 'contact info (unk)';
      $DAFA: result := 'contact info (past background)';
      $DAF0: result := 'contact info (interests)';
      $DAEB: result := 'contact info (emails)';
      $DAB4: result := 'uin info';
      $DAAA: result := 'password changed';
      $DA64: result := 'info saved (main)';
      $DA78: result := 'info saved (hp/more)';
      $DA82: result := 'info saved (about)';
      $DA6E: result := 'info saved (work)';
      $DA87: result := 'info saved (emails)';
      $DA8C: result := 'info saved (interests)';
      else result := 'in multipurpose';
      end;
    $1702: result := 'md5 login start';
    $1703: result := 'server login or error reply';
    $1706: result := 'md5 authkey request';
    $1707: result := 'md5 authkey response';
    $2502: result := 'new uin info request';
    $2503: result := 'new uin info response';
  else
    if getSnacService(s) and $FF=1 then
      result := getTranslation(Str_Error)
    else
      result := getTranslation(Str_unk);
  end;
end; // getDescForSnac

procedure loggaICQPkt(const prefix: String; what: TwhatLog; data: RawByteString='');
var
  head, s: string;
begin
 if prefix > '' then
   s := prefix + ' '
  else
   s := '';

 if what in [WL_serverGot, WL_serverSent] then
 if Length(Data) > 10 then
   if getFlapChannel(data) = SNAC_CHANNEL then
    s := s + '(' + IntToHex(hi(getSnacService(data)), 2) +',' + IntToHex(lo(getSnacService(data)), 2) + ') ';
 s := s + LogWhatNames[what];
if data>'' then
  if what in [WL_CONNECTED, WL_DISCONNECTED, WL_connecting] then
    begin
    s := s+' '+data;
    data := '';
    end
  else
    s := s+' size:'+intToStr(length(data),4);
case what of
  WL_serverGot, WL_serverSent:
    if length(data) >= FLAP_HEAD_SIZE then
      case getFlapChannel(data) of
        LOGIN_CHANNEL:     s := s+' (login flap)';
        LOGOUT_CHANNEL:    s := s+' (logout flap)';
        KEEPALIVE_CHANNEL: s := s+' (keepalive flap)';
        SNAC_CHANNEL:      s := s+' ref:'+intToHex(getSnacRef(data),8)+' '+getDescForSnac(data);
        end;
  end;

  head := logtimestamp+s;
  logProtoPkt(what, head, data)
end; // loggaPkt

function  statusNameExt2(s: byte; extSts: byte = 0; const Xsts: String = ''; const sts6: String = ''): string;
begin
  if (XStatusAsMain or (s = byte(SC_ONLINE))) and (extSts > 0) then
    begin
      if XSts > '' then
//        result := getTranslation(Xsts)
        result := Xsts
       else
        if sts6 > '' then
          result := sts6
         else
//          result := getTranslation(XStatusArray[extSts].Caption)
          result := getTranslation(status2ShowStr[TICQstatus(s)])
    end
   else
//    if sts6 > '' then
//      result := sts6
//     else
      result := getTranslation(status2ShowStr[TICQstatus(s)])
end;

function status2imgName(s: byte; inv: boolean=FALSE): TPicName;
const
  prefix = 'status.';
begin
 if s in [byte(LOW(status2Img)).. byte(HIGH(status2Img))] then
  result := prefix + status2Img[s]
//   result := sta 'status.' + status2str[s]
 else
  result := prefix + status2Img[byte(SC_UNK)];
{case s of
  SC_ONLINE: result:=PIC_STATUS_ONLINE;
  SC_occupied: result:=PIC_STATUS_OCCUPIED;
  SC_f4c: result:=PIC_STATUS_F4C;
  SC_dnd: result:=PIC_STATUS_DND;
  SC_na: result:=PIC_STATUS_NA;
  SC_away: result:=PIC_STATUS_AWAY;
  SC_OFFLINE: result:=PIC_STATUS_OFFLINE;
  SC_Evil: result:=PIC_STATUS_EVIL;
  SC_Depress: result:=PIC_STATUS_DEPRESS;
  else
    begin
    result:=PIC_STATUS_UNK;
    exit;
    end;
  end;}
if inv then
//  inc(result, PIC_INVISIBLE_STATUS_ONLINE-PIC_STATUS_ONLINE);
 result := INVIS_PREFIX + result;
end; // status2imgdx

function status2imgNameExt(s: byte; inv: boolean=FALSE; extSts: byte= 0): TPicName;
const
  prefix = 'status.';
begin
 if XStatusAsMain and (extSts > 0) then
   result := XStatusArray[extSts].PicName
 else
 begin
   if s in [byte(SC_ONLINE)..byte(SC_Last)] then
    result := prefix + status2Img[s]
   else
    result := prefix + status2Img[Byte(SC_UNK)];
   if inv then
     result := INVIS_PREFIX + result;
 end;
end; // status2imgdx

function visibilityName(vi: Tvisibility): string;
begin result:=getTranslation(visibility2ShowStr[vi]) end;

function clb2contactlist(data: RawByteString): TRnQCList;
var
  grpname: String;
  line: RawByteString;
  grp: integer;
  c: TICQContact;
begin
result := TRnQCList.create;
while data>'' do
  try
    line := trim(chop(AnsiString(#10),data));
    grpname := UnUTF(chop(AnsiString(';'),line));
    c := TICQContact(TRnQProtocol.contactsDB.get(TICQContact, chop(AnsiString(';'),line)));
   	if c.nick='' then
      c.nick := chop(AnsiString(';'),line)
     else
      c.fDisplay := chop(AnsiString(';'),line);
    if (c.group=0) and (grpname>'') then
      begin
      grp := groups.name2id(grpname);
      if grp<0 then
        begin
        grp := groups.add;
        groups.a[groups.idxOf(grp)].name := grpname;
        end;
      c.group := grp;
      end;
    result.add(c);
  except
  end;
end; // clb2contactlist

function contactlist2clb(cl: TRnQCList): AnsiString;
var
  i: integer;
//  s: string;
begin
  result := '';
  for i:=0 to TList(cl).count-1 do
   begin
//    s := '';
    with TRnQcontact(cl.getat(i)) do
      result := result+
        AnsiString(groups.id2name(group))+';'+ uid+';'+AnsiString(displayed)+';'+CRLF
   end;
end; // contactlist2clb

function str2status(const s: RawByteString): byte;
var
  ss: TPicName;
begin
  ss := LowerCase(s);
 for result:=byte(low(status2img)) to byte(high(status2img)) do
//  if LowerCase(status2img[TICQStatus(result)]) = s then
  if status2img[result] = ss then
    exit;
 result := byte(SC_ONLINE); // shut up compiler warning
end; // str2status

function str2visibility(const s: RawByteString): Tvisibility;
var
  ss: TPicName;
begin
  ss := LowerCase(s);
  for result := low(result) to high(result) do
   if visib2str[result] = ss then
     exit;
  result := VI_normal; // shut up compiler warning
end; // str2visibility


function findICQViewInfo(c: TRnQcontact): TviewInfoFrm;
var
  i: integer;
begin
  with childWindows do
    begin
      i := 0;
      while i < count do
       begin
        if Tobject(items[i]) is TviewInfoFrm then
          begin
            result := TviewInfoFrm(items[i]);
            if result.contact.equals(c) then
              exit;
          end;
        inc(i);
       end;
    end;
  result := NIL;
end; // findViewInfo

  {$IFDEF usesDC}
function findSendfile(id: Int64): TsendfileFrm;
var
  i: integer;
begin
with childWindows do
  begin
  i := 0;
  while i < count do
    begin
    if Tobject(items[i]) is TsendfileFrm then
      begin
      result:=TsendfileFrm(items[i]);
      if result.id = id then
        exit;
      end;
    inc(i);
    end;
  end;
result := NIL;
end; // findSendfile

function findRcvfile(id: Int64): TfiletransferFrm;
var
  i: integer;
begin
with childWindows do
  begin
  i:=0;
  while i < count do
    begin
    if Tobject(items[i]) is TfiletransferFrm then
      begin
      result := TfiletransferFrm(items[i]);
      if result.id = id then
        exit;
      end;
    inc(i);
    end;
  end;
result := NIL;
end; // findRcvfile
  {$ENDIF usesDC}


procedure ProcessICQEvents(var thisICQ: TICQSession; ev: TicqEvent);
var
  c: TICQcontact;
  b: boolean;
  i: integer;
  sU: string;
  e, TempEv: Thevent;
  TempCh: TchatInfo;
  vS: AnsiString;
  cuid: TUID;
  SA: RawByteString;
  session: TSessionParams;
 {$IFDEF usesDC}

  vSendFileForm: TsendfileFrm;
 {$ENDIF usesDC}
begin
  c := thisICQ.eventContact;
  thisICQ.eventContact := NIL;
  if Assigned(c) then
    cuid := c.uid2cmp
   else
    cuid := '';
// these icqevents are associated with hevents
if ev in [TicqEvent(IE_msg),IE_url,IE_contacts,IE_authReq,IE_addedyou,
      TicqEvent(IE_oncoming), TicqEvent(IE_offgoing),IE_auth,IE_authDenied,
      IE_automsgreq, IE_statuschanged, IE_gcard, IE_ack,
   {$IFDEF usesDC} IE_filereq, {$ENDIF usesDC}
      IE_email, IE_webpager, IE_fromMirabilis, IE_TYPING, IE_ackXStatus, IE_XStatusReq,
      IE_StickerMsg, IE_MultiChat] then
  begin
  e := Thevent.new(EK_null, c, thisICQ.eventTime,
                 ''{$IFDEF DB_ENABLED},''{$ENDIF DB_ENABLED}, thisICQ.eventFlags,
                 thisICQ.eventMsgID, thisICQ.eventWID);
  e.otherpeer := c;
  if ev in [IE_contacts] then
    begin
     e.cl := thisICQ.eventContacts.clone;
     e.cl.remove(thisICQ.getMyInfo);
     e.cl.remove(c);
    end
   else if ev in [IE_url, IE_authreq] then
 {$IFDEF DB_ENABLED}
    begin
      e.fBin := '';
      e.txt := UnUTF(thisICQ.eventMsgA);
    end
 {$ELSE ~DB_ENABLED}
    e.setInfo(thisICQ.eventMsgA)
 {$ENDIF ~DB_ENABLED}
   else if ev in [IE_ack, IE_authDenied] then
 {$IFDEF DB_ENABLED}
    begin
      e.fBin := AnsiChar(thisICQ.eventAccept);
      e.txt := UnUTF(thisICQ.eventMsgA);
    end;
 {$ELSE ~DB_ENABLED}
    e.setInfo(AnsiChar(thisICQ.eventAccept)+thisICQ.eventMsgA);
 {$ENDIF ~DB_ENABLED}
  end
else
  e:=NIL;
case ev of
	IE_serverAck:
  	begin
    i := Account.acks.findID(thisICQ.eventMsgID);
    if i >= 0 then  // exploit only for automsgreq
    	begin
        if Account.acks.getAt(i).kind = OE_msg then
           begin
             TempCh := chatFrm.chats.byContact(c);
             if TempCh <> NIL then
              begin
    //            TempCh.historyBox.history.
                 TempEv := TempCh.historyBox.history.getByID(thisICQ.eventMsgID);
                 if TempEv <> NIL then
                  begin
                    TempEv.flags := TempEv.flags OR IF_SERVER_ACCEPT;// IF_MSG_SERVER;
                    TempEv.writeWID(thisICQ.eventMsgID, thisICQ.eventWID);
  //                 TempEv := NIL;
                  end;
                 TempCh.repaint();
              end;

            {$IFDEF CHECK_INVIS}
        //	    c := contactsDB.get(acks.getAt(i).uid);
        //       c := thisICQ.eventContact;
              if not c.isOnline then
//                if acks.getAt(i).kind = OE_MSG then
                begin
                  if showCheckedInvOfl and not checkInvis.CList.exists(c)
                     and not autoCheckInvQ.exists(c) then
                  if Account.acks.getAt(i).info = 'Inv' then
                    msgDlg(getTranslation('%s - %s is actually offline',[c.uin2Show,c.displayed]), False, mtInformation);
                  c.setOffline;
        //          c.ICQVer := '';
                  if Assigned(autoCheckInvQ) then
                    autoCheckInvQ.remove(c);
                  roasterLib.update(c);
                  roasterLib.updateHiddenNodes;
        //          chatFrm.userChanged(c);
                  redraw(c);
//                end
        //        else  // Старый алгоритм, сделанный Rejetto
        //      	begin
        //  	      if not thisICQ.imVisibleTo(c) then addTempVisibleFor(5, c);
        //        	msgDlg(getTranslation('%s - %s is actually online but invisible to you',[c.uin2Show,c.displayed]), mtInformation);
                end;
            {$ENDIF}
             if (Account.acks.getAt(i).flags and IF_Simple >0) then
              Account.acks.Delete(i);
           end
      end;
    end;
  IE_srvSomeInfo:
    begin
      i := Account.acks.findID(thisICQ.eventMsgID);
      if i>=0 then
      	with Account.acks.getAt(i) do
        begin
         if kind = OE_MSG then
        	begin
         {$IFDEF CHECK_INVIS}
//          c:=TICQContact(contactsDB.get(TICQContact, uid));
          c:=TICQContact(whom);
           if (not c.isOnline)
             or (c.invisibleState = 2) then
             if (c.invisibleState = 0) then
            	begin
                c.invisibleState := 2;
                c.invisible := True;
                if not CheckInvis.CList.exists(c) and Assigned(autoCheckInvQ) then
                 autoCheckInvQ.Add(c);
                roasterLib.update(c);
//                chatFrm.userChanged(c);
                roasterLib.updateHiddenNodes;
                redraw(c);
//				      if not thisICQ.imVisibleTo(c) then
//				      	addTempVisibleFor(5, c);
//			      	msgDlg(getTranslation('%s - %s is actually online but invisible to you',[c.uin2Show,c.displayed]), mtInformation);
              end;
           {$ENDIF}
           Account.acks.Delete(i);
          end;
        end;
    end;
  IE_msgError:
  	begin
    i := Account.acks.findID(thisICQ.eventMsgID);
    if i>=0 then
    	with Account.acks.getAt(i) do
       begin
        if kind = OE_AUTOMSGREQ then
        	begin
         {$IFDEF CHECK_INVIS_OLD}
//          c:=contactsDB.get(uin);
          c := whom;
          if not c.isOnline then
          	if thisICQ.eventInt=9 then
            	begin
				      if not thisICQ.imVisibleTo(c) then
				      	addTempVisibleFor(5, c);
			      	msgDlg(getTranslation('%s - %s is actually online but invisible to you',[c.uin2Show,c.displayed]), False, mtInformation);
              end
            else
	          	msgDlg(getTranslation('%s - %s is actually offline',[c.uin2Show,c.displayed]), False, mtInformation)
          else
			      if not thisICQ.imVisibleTo(c) then
            	addTempVisibleFor(5, c);
         {$ENDIF}
           Account.acks.Delete(i);
          end;
        if kind = OE_MSG then
        	begin
         {$IFDEF CHECK_INVIS}
//          c:=TICQContact(contactsDB.get(uid));
          c := TICQContact(whom);
          if (not c.isOnline)
             or (c.invisibleState = 2) then
          begin
//          	if thisICQ.eventInt=$0E then
          	if (thisICQ.eventInt = 9) then
             if (c.invisibleState = 0) then
            	begin
                c.invisibleState := 2;
                c.invisible := True;
//                c.status := SC_ONLINE;
                if not CheckInvis.CList.exists(c) and Assigned(autoCheckInvQ) then
                 autoCheckInvQ.Add(c);
                roasterLib.update(c);
                roasterLib.updateHiddenNodes;
//                chatFrm.userChanged(c);
                redraw(c);
//				      if not thisICQ.imVisibleTo(c) then
//				      	addTempVisibleFor(5, c);
//			      	msgDlg(getTranslation('%s - %s is actually online but invisible to you',[c.uin2Show,c.displayed]), mtInformation);
              end
             else
            else
          	if (thisICQ.eventInt = 4)and(thisICQ.eventFlags = IF_urgent)and
                ( info = 'Inv2') then
//             if (c.invisibleState = 0) then
            	begin
                c.invisibleState := 2;
                c.invisible := True;
//                c.status := SC_ONLINE;
                if not CheckInvis.CList.exists(c) and Assigned(autoCheckInvQ) then
                 autoCheckInvQ.Add(c);
                roasterLib.update(c);
                roasterLib.updateHiddenNodes;
//                chatFrm.userChanged(c);
                redraw(c);
//				      if not thisICQ.imVisibleTo(c) then
//				      	addTempVisibleFor(5, c);
//			      	msgDlg(getTranslation('%s - %s is actually online but invisible to you',[c.uin2Show,c.displayed]), mtInformation);
              end
//             else
            else
             if ( info = 'Inv') then

              begin
                c.status := SC_OFFLINE;
                c.invisibleState := 0;
                c.invisible := False;
//                c.status := SC_OFFLINE;
                roasterLib.update(c);
                roasterLib.updateHiddenNodes;
//                chatFrm.userChanged(c);
                redraw(c);
                if showCheckedInvOfl
                   and
                    (not (checkInvis.CList.exists(c)
                          and checkInvis.AutoCheck))
                   and not autoCheckInvQ.exists(c) then
      //          if acks.getAt(i).info = 'Inv' then
                  msgDlg(getTranslation('%s - %s is actually offline',[c.uin2Show,c.displayed]), False, mtInformation);
                if Assigned(autoCheckInvQ) then
                  autoCheckInvQ.remove(c);
              end
             else
              if ( info = 'MSG') then
               begin
                 TempCh := chatFrm.chats.byContact(c);
                 if TempCh <> NIL then
                  begin
        //            TempCh.historyBox.history.
                     TempEv := TempCh.historyBox.history.getByID(thisICQ.eventMsgID);
                     if TempEv <> NIL then
                      begin
                       TempEv.flags := TempEv.flags OR IF_not_delivered;// IF_MSG_OK;
                       TempCh.repaint();
                      end;
//                     TempEv := NIL;
                  end;
                TempCh.repaint();
               end;

          end
          else
           {$ENDIF}
              if ( info = 'MSG') then
               begin
                 TempCh := chatFrm.chats.byContact(c);
                 if TempCh <> NIL then
                  begin
        //            TempCh.historyBox.history.
                     TempEv := TempCh.historyBox.history.getByID(thisICQ.eventMsgID);
                     if TempEv <> NIL then
                      begin
                       TempEv.flags := TempEv.flags OR IF_not_delivered;// IF_MSG_OK;
                       TempCh.repaint();
                      end;
//                     TempEv := NIL;
                  end;
               end;
//			      if not thisICQ.imVisibleTo(c) then
//            	addTempVisibleFor(5, c);
          Account.acks.Delete(i);
          end;
       end;
    end;
  IE_Missed_MSG:
    begin
      sU := getTranslation('You have missed %d messages from %s!', [thisICQ.eventMsgID, c.displayed]);
      sU := sU + CRLF + getTranslation('Reason') + ': ' + getTranslation(icq_missed_msgs[thisICQ.eventInt]);
    	msgDlg(sU, False, mtWarning);
    end;
  IE_sendingAutomsg:
    begin
     vS := getAutomsgFor(c);
//     if vS <> '' then
       thisICQ.eventMsgA := vS;
     plugins.castEv( PE_AUTOMSG_SENT, cuid, thisICQ.eventMsgA);
    end;
  IE_sendingXStatus:
    begin
//    thisICQ.eventName := AnsiToUtf8(getTranslation(ExtStsStrings[thisICQ.curXStatus][0]));
     thisICQ.eventMsgA := StrToUtf8(getXStatusMsgFor(c));
//     sa := StrToUtf8(thisICQ.eventMsg);
     Vs := plugins.castEv( PE_XSTATUSMSG_SENDING, cuid, thisICQ.eventInt,
                           StrToUtf8(thisICQ.eventNameA), thisICQ.eventMsgA);
//      vS := plugins.castEv( PE_MSG_GOT, cuid, e.flags, e.when, thisICQ.eventMsg);
      if not isAbort(vS) then
       begin
         if (vS>'') then
          if(ord(vS[1])=PM_DATA) then
          try
           i := _int_at(vS, 2);
//           thisICQ.eventName := UnUTF(_istring_at(vS, 2));
           thisICQ.eventNameA := _istring_at(vS, 2);  // In UTF8
           if length(vS)>2+4+ i then
//            thisICQ.eventMsg := UnUTF(_istring_at(vS, 2+4+ i))
            thisICQ.eventMsgA := _istring_at(vS, 2+4 + i) // In UTF8
//           else
//            oe.info := send_msg;
          except
            thisICQ.eventNameA := '';
            thisICQ.eventMsgA := StrToUtf8(getXStatusMsgFor(c));
          end
          else
           if (ord(vS[1])=PM_ABORT) then
             begin thisICQ.eventMsgA := ''; thisICQ.eventNameA := ''; end
            else begin end;
//         else
//           send_msg := oe.info;
//        if behave(e, EK_msg, thisICQ.eventMsg) then
//          NILifNIL(c);
       end
      else
       begin thisICQ.eventMsgA := ''; thisICQ.eventNameA := ''; end
    end;
  IE_endOfOfflineMsgs:
    begin
    if delOfflineMsgs then
      begin
      thisICQ.sendDeleteOfflineMsgs;
      thisICQ.offlineMsgsChecked:=TRUE;
      end;
    disableSounds:=FALSE;
    saveInboxDelayed:=TRUE;
    end;
{$IFDEF usesDC}
  IE_filereq: begin
//               receiveFile2(thisICQ, thisICQ.eventMsgID, c, thisICQ.eventFilename);
               if findRcvFile(thisICQ.eventMsgID)=NIL then
                begin
//                  Vs := plugins.castEv( PE_XSTATUSMSG_SENDING, cuid, thisICQ.eventInt,
//                          thisICQ.eventName, thisICQ.eventMsg);
                 e.ID := thisICQ.eventMsgID;
                 if c.connection.internal_ip > 0 then
                   sA := TLV(6, c.connection.internal_ip)
                  else
                   sA := '';
 {$IFDEF DB_ENABLED}
                 e.fBin := TLV(1, StrToUTF8(thisICQ.eventDirect.fileName))+
                            TLV(2, thisICQ.eventDirect.fileCntTotal)+
                            TLV(3, thisICQ.eventDirect.fileSizeTotal)+
                            TLV(4, thisICQ.eventMsgA)+
                            TLV(5, c.connection.ip)+
                            sA;
                 e.txt := '';
 {$ELSE ~DB_ENABLED}
     e.SetInfo(TLV(1, StrToUTF8(thisICQ.eventDirect.fileName))+
                            TLV(2, thisICQ.eventDirect.fileCntTotal)+
                            TLV(3, thisICQ.eventDirect.fileSizeTotal)+
                            TLV(4, thisICQ.eventMsgA)+
                            TLV(5, c.connection.ip)+
                            sA);
 {$ENDIF ~DB_ENABLED}
                 if behave(e, EK_file) then
                    NILifNIL(c);
//                 receiveFile(thisICQ.eventDirect);
                end;
{
       if behave(e, EK_file) then
      begin
                redraw(c);
      NILifNIL(c);
      end;}
              end;
  IE_fileack:
    begin
      if c.equals(thisICQ.eventDirect.contact) then
       begin
//         file
//         thisICQ.eventDirect.
        vSendFileForm := findSendfile(thisICQ.eventMsgID);
        if thisICQ.eventDirect.Directed then
         if Assigned(vSendFileForm) then
          vSendFileForm.doTransfer(thisICQ.eventDirect);
       end;
    end;
//  IE_fileok: receiveFile(thisICQ.eventDirect);
  IE_fileDone:
       begin
//         file
//         thisICQ.eventDirect.
        vSendFileForm := findSendfile(thisICQ.eventMsgID);
        if Assigned(vSendFileForm) then
          vSendFileForm.doDoneTransfer;
       end;
{$ENDIF usesDC}
  IE_automsgreq:
    if not isAbort(plugins.castEv( PE_AUTOMSG_REQ_GOT, cuid)) then
    	begin
    	if warnVisibilityExploit and not thisICQ.imVisibleTo(c) then
      	msgDlg(getTranslation('%s - %s is using visibility exploit to check your online presence',[c.uin2Show,c.displayed]), False, mtWarning);
      behave(e, EK_automsgreq);
      end;
  IE_ack:
    begin
    i := Account.acks.findID(thisICQ.eventInt);
    if i >= 0 then
     begin
//      sU := thisICQ.eventMsg;
      sU := UnUTF(thisICQ.eventMsgA);
      if Account.acks.getAt(i).kind = OE_AUTOMSGREQ then
        begin
        if thisICQ.eventAccept <> AC_ok then
          c.lastAccept := thisICQ.eventAccept;

        pTCE(c.data).lastAutoMsg := sU;
        plugins.castEv( PE_AUTOMSG_GOT, cuid, sU);
        behave(e, EK_automsg);
        end
      else
      if Account.acks.getAt(i).kind = OE_msg then
       begin
         TempCh := chatFrm.chats.byContact(c);
         if TempCh <> NIL then
          begin
//            TempCh.historyBox.history.
             TempEv := TempCh.historyBox.history.getByID(thisICQ.eventMsgID);
             if TempEv <> NIL then
              TempEv.flags := TempEv.flags OR IF_delivered;// IF_MSG_OK;
//             TempEv := NIL;
           TempCh.repaint();
          end;
       end
      else
       begin
        b := (c.lastAccept<>thisICQ.eventAccept) or (TCE(c.data^).lastAutoMsg<>sU);
        case thisICQ.eventAccept of
          AC_away:
            if b then
              begin
              plugins.castEv( PE_AUTOMSG_GOT, cuid, sU);
              behave(e, EK_automsg);
              end;
          AC_denied:
            begin
{            if messageDlg(getTranslation('User only accept urgent messages.\nSend urgent?\n\nAuto-message:\n%s',
               [s]), mtConfirmation, [mbYes,mbNo], 0) = mrYes then
              begin
              with acks.getAt(i) do flags:=flags or IF_urgent;
              sendICQmsg(acks.getAt(i));
              end;}
            end;
          end;
        pTCE(c.data).lastPriority := Account.acks.getAt(i).flags and (IF_urgent+IF_noblink);
        pTCE(c.data).lastAutoMsg := sU;//thisICQ.eventMsg;
        c.lastAccept  := thisICQ.eventAccept;
       end;
//      Account.acks.delete(i);
     end;
    end;
  IE_authDenied:
    begin
      case thisICQ.eventAccept of
          AC_OK:
             begin
              plugins.castEv( PE_AUTH_GOT, cUID);
              msgDlg(getTranslation('%s was grant you an autorization', [c.displayed]), False, mtInformation);
             end;
          AC_denied:
            begin
              plugins.castEv( PE_AUTHDENIED_GOT, cUID);
              msgDlg(getTranslation('%s was declined you an autorization', [c.displayed]), False, mtInformation);
            end;
      end;
    end;
  IE_pause: msgDlg('You''ll be soon disconnected cause the server is in pause.', True, mtWarning);
  IE_pwdChanged:
    begin
//    saveCFG;
    if not dontSavePwd then
      saveCfgDelayed := True;
    msgDlg('Your password has been changed.', True, mtInformation);
    end;
  IE_myinfoACK: msgDlg('Your information has been saved.', True, mtInformation);
  IE_wpEnd:
    if (wpFrm<>NIL) then
      begin
       if thisICQ.eventInt > 0 then
       begin
        wpFrm.N_Allresults := thisICQ.eventInt;
        wpFrm.updateNumResults;
//        msgDlg(getTranslation('End of search\nThere are %d more results but ICQ server shows only first ones, sorry.', [thisICQ.eventInt]),mtInformation);
       end;
       wpFrm.stopSearch;
      end;
  IE_userSimpleInfo:
     begin
      if (thisICQ.eventWP.uin = IntToStrA(uinToUpdate)) and
         (checkupdate.enabled or PREVIEWversion) then
       begin
        checkupdate.autochecking := True;
        c.nick  := thisICQ.eventwp.nick;
        c.first := thisICQ.eventwp.first;
        c.last  := thisICQ.eventwp.last;
        CheckUpdates(c);
       end;
     end;
  IE_fileDenied: msgDlg('File transfer denied', True, mtWarning);
  IE_wpResult: if (wpFrm<>NIL) then wpFrm.addResult(thisICQ.eventWP);
{$IFDEF usesDC}
  IE_dcConnected: loggaICQPkt('Direct', WL_connected, thisICQ.eventDirect.host);
  IE_dcDisconnected: loggaICQPkt('Direct', WL_disconnected, thisICQ.eventDirect.host);
  IE_dcSent: loggaICQPkt('Direct', WL_meSent, thisICQ.eventData);
  IE_dcGot: loggaICQPkt('Direct', WL_heSent, thisICQ.eventData);
{$ENDIF usesDC}
  IE_serverSent: loggaICQPkt('', WL_serverSent, thisICQ.eventData);
  IE_serverGot: loggaICQPkt('', WL_serverGot, thisICQ.eventData);
  IE_ProxySent: loggaICQPkt('Proxy', WL_serverSent, thisICQ.eventData);
  IE_ProxyGot: loggaICQPkt('Proxy', WL_serverGot, thisICQ.eventData);
  IE_serverConnected: loggaICQPkt('', WL_connected, thisICQ.eventAddress);
  IE_serverDisconnected: loggaICQPkt('', WL_disconnected, thisICQ.eventAddress);
//  IE_serverConnecting: loggaICQPkt(WL_connecting, thisICQ.eventAddress);
  IE_connecting:
    begin
     loggaICQPkt('', WL_connecting, thisICQ.eventAddress);
     disableSounds:=FALSE;
     setProgBar(thisICQ, 1/progLogonTotal);
     thisICQ.sock.proxySettings(thisICQ.aProxy);
    end;
  IE_connected: setProgBar(thisICQ, 2/progLogonTotal);
  IE_loggin: setProgBar(thisICQ, 3/progLogonTotal);
  IE_redirecting:
    begin
     loggaICQPkt('', WL_connecting, thisICQ.eventAddress);
     setProgBar(thisICQ, 4/progLogonTotal);
     thisICQ.sock.proxySettings(thisICQ.aProxy);
    end;
  IE_redirected: setProgBar(thisICQ, 5/progLogonTotal);
  IE_almostonline: setProgBar(thisICQ, 6/progLogonTotal);
  IE_visibilityChanged:
    if assigned(c) then
      begin
      plugins.castEv( PE_VISIBILITY_CHANGED, cuid);
      roasterLib.redraw(c)
      end
    else
      begin
      plugins.castEv( PE_VISIBILITY_CHANGED, '');
      rosterRepaintDelayed:=TRUE;
      end;
  IE_error:
    if thisICQ.eventError = EC_SSI_error then
    begin
      case thisICQ.eventInt of
        $01: thisICQ.eventMsgA := 'Invalid SNAC header.';
        $02: thisICQ.eventMsgA := 'Server rate limit exceeded';
        $03: thisICQ.eventMsgA := 'Client rate limit exceeded';
        $04: thisICQ.eventMsgA := 'Recipient is not logged in';
        $05: thisICQ.eventMsgA := 'Requested service unavailable';
        $06: thisICQ.eventMsgA := 'Requested service not defined';
        $07: thisICQ.eventMsgA := 'You sent obsolete SNAC';
        $08: thisICQ.eventMsgA := 'Not supported by server';
        $09: thisICQ.eventMsgA := 'Not supported by client';
        $0A: thisICQ.eventMsgA := 'Refused by client';
        $0B: thisICQ.eventMsgA := 'Reply too big';
        $0C: thisICQ.eventMsgA := 'Responses lost';
        $0D: thisICQ.eventMsgA := 'Request denied';
        $0E: thisICQ.eventMsgA := 'Incorrect SNAC format';
        $0F: thisICQ.eventMsgA := 'Insufficient rights';
        $10: thisICQ.eventMsgA := 'In local permit/deny (recipient blocked)';
        $11: thisICQ.eventMsgA := 'Sender too evil';
        $12: thisICQ.eventMsgA := 'Receiver too evil';
        $13: thisICQ.eventMsgA := 'User temporarily unavailable';
        $14: thisICQ.eventMsgA := 'No match';
        $15: thisICQ.eventMsgA := 'List overflow';
        $16: thisICQ.eventMsgA := 'Request ambiguous';
        $17: thisICQ.eventMsgA := 'Server queue full';
        $18: thisICQ.eventMsgA := 'Not while on AOL';
      end;
      msgDlg(getTranslation(icqerror2str[thisICQ.eventError], [getTranslation(thisICQ.eventMsgA)]), False, mtError);
    end
    else if thisICQ.eventError = EC_badContact then

      loggaEvtS(format('ERROR: bad contact: %s',[cuid]))
    else
      begin
        setProgBar(thisICQ, 0);
        theme.PlaySound(Str_Error); //sounds.onError);
        if (thisICQ.eventError in [
          EC_badUIN,
          EC_badPwd,
          EC_proxy_badPwd,
//          EC_anotherLogin,
          EC_invalidFlap,
          EC_rateExceeded,
          EC_missingLogin
        ]) or (autoReconnectStop and (thisICQ.eventError = EC_anotherLogin))
          then
          stayConnected:=FALSE;
        if (autoReconnectStop and (thisICQ.eventError = EC_anotherLogin)) then
          lastStatusUserSet := byte(SC_OFFLINE);
        if thisICQ.eventError = EC_missingLogin then
          if enterICQpwd(thisICQ) then doConnect
          else
        else
          if showDisconnectedDlg or not (thisICQ.eventError in [
            EC_rateExceeded,
            EC_cantConnect,
            EC_socket,
            EC_serverDisconnected,
            EC_loginDelay,
            EC_invalidFlap
          ]) then
//            if thisICQ.eventError = EC_proxy_unk then
//               msgDlg(___('icqerror '+icqerror2str[thisICQ.eventError], [thisICQ.eventMsg]), mtError)
//              msgDlg(getTranslation(icqerror2str[thisICQ.eventError], [thisICQ.eventMsg]), mtError)
//            else
              msgDlg(getTranslation(icqerror2str[thisICQ.eventError], [thisICQ.eventInt, thisICQ.eventMsgA]), False, mtError);
        if thisICQ.eventError = EC_badPwd then
         begin
          sU := thisICQ.pwd;
          thisICQ.pwd := '';
          if enterICQpwd(thisICQ) then
           begin
            thisICQ.disconnect();
            doConnect();
           end
           else
            thisICQ.pwd := sU;
         end
        else if thisICQ.eventError = EC_other then
          msgDlg(getTranslation(ICQauthErrors[thisICQ.eventInt],[thisICQ.eventMsgA]), False, mtError)
      end;
  IE_statuschanged:
    begin
      if not Assigned(c) then //or thisICQ.isMyAcc(c) then
       begin
        plugins.castEv( PE_STATUS_CHANGED, cuid, thisICQ.getStatus, byte(thisICQ.eventOldStatus),  thisICQ.IsInvisible, thisICQ.eventOldInvisible);
        updateViewInfo(thisICQ.getMyInfo);
//        myStatus := thisICQ.getStatus;
        if thisICQ.getStatus <> byte(SC_OFFLINE) then
          lastStatus := thisICQ.getStatus;
        RnQmain.updateStatusGlyphs;
        roasterLib.updateHiddenNodes;
        roasterLib.redraw;
       end
      else
      begin
       plugins.castEv( PE_STATUS_CHANGED, cuid, byte(c.status), byte(thisICQ.eventOldStatus), c.invisible, thisICQ.eventOldInvisible);
       updateViewInfo(c);
        if thisICQ.isInList(LT_ROSTER, c) then
          begin
          if (c.status <> SC_OFFLINE)  then
            {$IFDEF CHECK_INVIS}
             if (c.invisibleState = 2) then
             begin
  //            c.invisibleState := 0;
               if not CheckInvis.CList.exists(c) and Assigned(autoCheckInvQ) then
                 autoCheckInvQ.Add(c);
               c.invisible := True;
             end
             else
            {$ENDIF}
           else
            begin
              c.setOffline;
  //            c.ICQVer := '';
            {$IFDEF CHECK_INVIS}
              if CheckInvis.AutoCheckGoOfflineUsers then
                if not CheckInvis.CList.exists(c) and Assigned(autoCheckInvQ) then
                  autoCheckInvQ.Add(c);
            {$ENDIF}
            end;
          roasterLib.update(c);//  Что-то нада убрать тут!!!!
  //        roasterLib.redraw(c);
          roasterLib.updateHiddenNodes;
  //        chatFrm.userChanged(c);
           redraw(c);
 {$IFDEF DB_ENABLED}
          e.fBin := int2str(integer(c.status))+ AnsiChar(c.invisible) + AnsiChar(c.xStatus);
 {$ELSE ~DB_ENABLED}
          e.f_info:= int2str(integer(c.status))+ AnsiChar(c.invisible) + AnsiChar(c.xStatus);
 {$ENDIF ~DB_ENABLED}
          if //(c.xStatus > 0) or
           (c.xStatusDesc > '') then
            begin
 {$IFDEF DB_ENABLED}
              e.txt   := c.xStatusDesc;
 {$ELSE ~DB_ENABLED}
              e.f_info := e.f_info + _istring(StrToUtf8(c.xStatusDesc));
 {$ENDIF ~DB_ENABLED}
              e.flags := e.flags or IF_XTended_EVENT;
            end;
          if oncomingOnAway
          and (thisICQ.eventOldStatus in [SC_AWAY,SC_NA])
          and not (c.status in [SC_AWAY,SC_NA])
          and (noOncomingCounter = 0) then
            behave(e, EK_oncoming)
          else
  //          if c.xStatus > 0 then
  //            behave(e, EK_statuschangeExt)
  //           else
              behave(e, EK_statuschange);
          end;
{
      if //(c.xStatus > 0) or
         (c.xStatusDecs > '') then
       begin
        e.info := char(c.xStatus) + _istring(c.xStatusStr) + _istring(c.xStatusDecs);
//        if c.status = SC_OFFLINE then
//          e.flags := e.flags or
        behave(e, EK_XstatusMsg);
       end;
}
       if autoRequestXsts
          and (c.capabilitiesXTraz <> [])
          and thisICQ.imVisibleTo(c)
          and Assigned(reqXStatusQ) then
         reqXStatusQ.Add(c);
      end;
      autosizeDelayed:=TRUE;
    end;
   {$IFDEF RNQ_AVATARS}
  IE_avatar_changed:
    if thisICQ.AvatarsSupport then
     begin
      if not try_load_avatar(c, c.ICQIcon.hash, c.Icon.Hash_safe) then
       if thisICQ.AvatarsAutoGet then
          reqAvatarsQ.add(c)
        else
         if c.icon.ToShow = IS_AVATAR then
           ClearAvatar(TRnQContact(c));
//      if ShowAvt then
      if TO_SHOW_ICON[CNT_ICON_AVT] then
        redraw(c);
     end;
   {$ENDIF RNQ_AVATARS}
  IE_ackXStatus:
    begin
      c.xStatusStr := excludeTrailingCRLF(UnUTF(thisICQ.eventMsgA));
      c.xStatusDesc := excludeTrailingCRLF(unUTF(thisICQ.eventData));
 {$IFDEF DB_ENABLED}
      if c.xStatus > 0 then
        begin
          e.fBin := AnsiChar(c.xStatus) + _istring(StrToUTF8(c.xStatusStr));
        end
       else
        e.fBin := AnsiChar(#00) + _istring(StrToUTF8(c.xStatusStr));
      e.txt   := c.xStatusDesc;
 {$ELSE ~DB_ENABLED}
      if c.xStatus > 0 then
        e.f_info := AnsiChar(c.xStatus) + _istring(StrToUTF8(c.xStatusStr)) + _istring(StrToUTF8(c.xStatusDesc))
       else
        e.f_info := #00 + _istring(StrToUTF8(c.xStatusStr));
 {$ENDIF ~DB_ENABLED}
      behave(e, EK_XstatusMsg);
      updateViewInfo(c);
    end;
  IE_XStatusReq:
    begin
    if not isAbort(plugins.castEv( PE_XSTATUS_REQ_GOT, cuid)) then
    	begin
    	if warnVisibilityExploit and not thisICQ.imVisibleTo(c) then
      	msgDlg(getTranslation('%s - %s is using visibility exploit to check your online presence',[c.uin2Show,c.displayed]), False, mtWarning);
      behave(e, EK_Xstatusreq);
      end;
    end;
  IE_online,
  IE_offline:
    begin
    outboxCount:=-1;
    keepalive.timer:=keepalive.freq*2;
    b := false;
//    b := myStatus <> byte(SC_OFFLINE);
//    myStatus:= thisICQ.getStatus;
    b := b or (thisICQ.getStatus <> byte(SC_OFFLINE));
    b := b or (ev=IE_offline);
    setProgBar(thisICQ, 0);
    if ev=IE_online then
     begin
       //  вызов балуна
      {$IFDEF Use_Baloons}
      statusIcon.showballoon(2000, getTranslation('Online'),
                             Application.MainForm.Caption, bitinfo);
      {$ENDIF Use_Baloons}
      thisICQ.offlineMsgsChecked := FALSE;
      checkupdate.checking := false;
 {$IFDEF UseNotSSI}
      if not thisICQ.useSSI and (thisICQ.readList(LT_ROSTER).count < 1) then
//        thisICQ.SSIreqRoster;
        RQ_ICQ.RequestContactList(thisICQ);
 {$ENDIF UseNotSSI}
      outboxCount := timeBetweenMsgs;
      stayconnected := autoreconnect;
      plugins.castEv(PE_CONNECTED);
      if getOfflineMsgs then
        thisICQ.sendReqOfflineMsgs
      else
        if delOfflineMsgs then
          begin
          thisICQ.offlineMsgsChecked:=TRUE;
          thisICQ.sendDeleteOfflineMsgs;
          end;
       {$IFDEF CHECK_INVIS}
      checkInvis.lastAllChkTime := now;
       {$ENDIF}
      toReconnectTime := 50;
 {$IFDEF UseNotSSI}
      {$IFDEF RNQ_AVATARS}
        Check_my_avatar(thisICQ);
      {$ENDIF RNQ_AVATARS}
 {$ENDIF UseNotSSI}
  {$IFDEF ICQ_REST_API}
          if thisICQ.useWebProtocol then
            thisICQ.getSession;
  {$ENDIF ICQ_REST_API}
     end
    else
      begin
//        inc(saveDBtimer, saveDBdelay);
        incDBTimer;
     {$IFDEF RNQ_FULL}
//      statusIcon.showballoon(2000, getTranslation('Offline'),
//                             Application.MainForm.Caption, bitinfo);
     {$ENDIF RNQ_FULL}
       if clearPwdOnDSNCT and dontSavePwd then
        if Assigned(thisICQ) and thisICQ.isOffline then
         thisICQ.pwd := '';
       with TRnQProtocol.contactsDB.clone do
       begin
        resetEnumeration;
        while hasMore do
            with TICQcontact(getNext) do
             begin
              OfflineClear;
              status := SC_UNK;
             end;
         free;
       end;
      {$IFDEF CHECK_INVIS}
       autoCheckInvQ.Clear;
       CheckInvQ.Clear;
      {$ENDIF CHECK_INVIS}
        Account.acks.Clear;
      plugins.castEv(PE_DISCONNECTED);

  {$IFDEF ICQ_REST_API}
        if thisICQ.useWebProtocol then
        begin
          session := thisICQ.getSession(False);
          if not (session.aimsid = '') then
          begin
            SU := '';
            LoadFromURL0('http://api.icq.net/aim/endSession?f=json&r=1&aimsid=' + session.aimsid, sU);
            loggaEvtS('AIM session ' + session.aimsid + ' closed');
          end;
        end;
  {$ENDIF ICQ_REST_API}
      end;
    noOncomingCounter:=150;
    with chatFrm do
      if thisChat <> NIL then
        userChanged(thisChat.who);
    chatFrm.pageCtrl.repaint;
    RnQmain.updateStatusGlyphs;
    if b then
     roasterLib.rebuild;
    end;
  IE_numOfContactsChanged:
     begin
//    contactsPnl.text:=intToStr(thisICQ.readroster.count);
//       contactsPnlStr := intToStr(TList(thisICQ.readList(LT_ROSTER)).count);
       contactsPnlStr := intToStr(thisICQ.eventInt);
//       roasterLib.rebuild;
     end;
  IE_userinfo:
    begin
    plugins.castEv( PE_USERINFO_CHANGED, cuid );
    updateViewInfo(c);
    if thisICQ.isMyAcc(c) then
      RnQmain.updateCaption
    else
      roasterLib.redraw(c);
    TipsUpdateByCnt(c);
    if checkupdate.checking and (cuid = IntToStr(uinToUpdate)) then
       CheckUpdates(c);
//   roasterLib.updateHiddenNodes;
//   chatFrm.userChanged(c);
     redraw(c);
    dbUpdateDelayed:=TRUE;
    end;
  IE_userinfoCP:
    begin
    plugins.castEv( PE_USERINFO_CHANGED, cuid );
    updateViewInfo(c);
    if thisICQ.isMyAcc(c) then
      RnQmain.updateCaption
    else
      roasterLib.redraw(c);
    TipsUpdateByCnt(c);
    if checkupdate.checking and (cuid = IntToStr(uinToUpdate)) then
       CheckUpdates(c);
//   roasterLib.updateHiddenNodes;
//   chatFrm.userChanged(c);
     redraw(c);
    dbUpdateDelayed:=TRUE;
    end;
  IE_oncoming:
    begin
       {$IFDEF CHECK_INVIS}
        c.invisibleState := 0;
        if Assigned(autoCheckInvQ) then
          autoCheckInvQ.remove(c);
       {$ENDIF}
      plugins.castEv( PE_STATUS_CHANGED, cuid, byte(c.status), byte(thisICQ.eventOldStatus), c.invisible, FALSE );
  //                chatFrm.userChanged(c);
      roasterLib.update(c);
      redraw(c);
      roasterLib.updateHiddenNodes;
      TCE(c.data^).lastOncoming := thisICQ.eventTime;
      updateViewInfo(c);
 {$IFDEF DB_ENABLED}
      e.fBin :=int2str(integer(c.status))+AnsiChar(c.invisible)+AnsiChar(c.xStatus);
 {$ELSE ~DB_ENABLED}
      e.f_info:=int2str(integer(c.status))+AnsiChar(c.invisible)+AnsiChar(c.xStatus);
 {$ENDIF DB_ENABLED}
      if noOncomingCounter = 0 then
        behave(e, EK_oncoming)
       else
        if noOncomingCounter < 50 then
          begin
          inc(noOncomingCounter,10);
          boundInt(noOncomingCounter, 0,50);
          end;
      if autoRequestXsts
         and (c.capabilitiesXTraz <> [])
         and thisICQ.imVisibleTo(c)
         and Assigned(reqXStatusQ) then
        reqXStatusQ.Add(c);
    autosizeDelayed:=TRUE;
    end;
  IE_offgoing:
    begin
    plugins.castEv( PE_STATUS_CHANGED, cuid, byte(c.status), byte(thisICQ.eventOldStatus), FALSE, thisICQ.eventOldInvisible );
    if roasterLib.focusedContact=c then
      roasterLib.focusPrevious;
          begin
            c.OfflineClear;
          {$IFDEF CHECK_INVIS}
            if CheckInvis.AutoCheckGoOfflineUsers then
              if not CheckInvis.CList.exists(c) and Assigned(autoCheckInvQ) then
                autoCheckInvQ.Add(c);
          {$ENDIF}
          end;

    roasterLib.update(c);
    roasterLib.updateHiddenNodes;
//                chatFrm.userChanged(c);
      redraw(c);
    updateViewInfo(c);
    behave(e, EK_offgoing);
    autosizeDelayed:=TRUE;
    end;
  IE_contactupdate:
    begin
      roasterLib.update(c);
      roasterLib.updateHiddenNodes;
//                chatFrm.userChanged(c);
         redraw(c);
      updateViewInfo(c);
//      autosizeDelayed:=TRUE;
    end;
  IE_contactSelfDeleted:
    begin
      msgDlg(getTranslation('Contact %s [%s] Deleted himself from your Contact List', [c.displayed, c.uin2Show]),
              false, mtInformation, c.UID);
      roasterLib.update(c);
      roasterLib.updateHiddenNodes;
//                chatFrm.userChanged(c);
      redraw(c);
      updateViewInfo(c);
//      autosizeDelayed:=TRUE;
    end;
  IE_redraw:
     roasterLib.redraw(c);
  IE_typing: if not filterRefuse(c) then
    begin
//     e.kind:=EK_Typing;
     roasterLib.redraw(c);
     if thisICQ.eventInt = MTN_CLOSED then
      begin
        // Закрыли чат
      end;

     if c.typing.bistyping then
      behave(e, EK_typingBeg)
     else
      behave(e, EK_typingFin);
    end;
  IE_contacts:
    if not e.cl.empty
    and not isAbort(plugins.castEv( PE_CONTACTS_GOT,cuid,e.flags,e.when,e.cl )) then
     begin
 {$IFDEF DB_ENABLED}
       e.fBin := e.cl.tostring;
       e.txt := '';
 {$ELSE ~DB_ENABLED}
       e.SetInfo(e.cl.tostring);
 {$ENDIF ~DB_ENABLED}
       if behave(e, EK_contacts) then
         NILifNIL(c);
     end;
  IE_authReq:
    if not filterRefuse(c, '',IF_auth) and not isAbort(plugins.castEv( PE_AUTHREQ_GOT, cuid, e.flags, e.when, thisICQ.eventMsgA ))
    and behave(e, EK_authReq) then
      begin
//                roasterLib.updateHiddenNodes;
//                chatFrm.userChanged(c);
                redraw(c);
      NILifNIL(c);
      end;
  IE_addedYou:
    if not isAbort(plugins.castEv( PE_ADDEDYOU_GOT, cuid, e.flags, e.when ))
    and behave(e, EK_addedyou) then
      begin
//                roasterLib.updateHiddenNodes;
//                chatFrm.userChanged(c);
                redraw(c);
      NILifNIL(c);
      end;
  IE_url:
  	if (Length(thisICQ.eventAddress)=0) then
     begin
      if warnVisibilityExploit and not thisICQ.imVisibleTo(c) then
      	msgDlg(getTranslation('%s - %s is using visibility exploit to check your online presence',[c.uin2Show,c.displayed]), False, mtWarning, cUID)
     end
    else
     begin
      sU := UnUTF(thisICQ.eventMsgA);
      if not isAbort(plugins.castEv( PE_URL_GOT, cuid, e.flags, e.when, thisICQ.eventAddress, sU )) then
        begin
 {$IFDEF DB_ENABLED}
         e.fBin := '';
         e.txt := thisICQ.eventAddress+#10+sU;
 {$ELSE ~DB_ENABLED}
         e.SetInfo(thisICQ.eventAddress+#10+sU);
 {$ENDIF ~DB_ENABLED}
         if behave(e, EK_url) then
           NILifNIL(c);
        end;
     end;
  IE_buzz:
     begin
       if behave(e, EK_buzz) then
         NILifNIL(c);
     end;
  IE_msg:
     begin
//      e.fBin := '';
//      e.txt := UnUTF(thisICQ.eventMsgA);
//      e.ParseMsgStr(thisICQ.eventMsgA);

//      if EnableImgLinksIn then
//         parseImgLinks2(eventMsgA);

      vS := plugins.castEv( PE_MSG_GOT, cuid, e.flags, e.when, thisICQ.eventMsgA);
      if not isAbort(vS) then
       begin
        if (vS>'') and (ord(vS[1])=PM_DATA) then
         begin
           thisICQ.eventMsgA := _istring_at(vS, 2);
           e.flags := e.flags and not IF_CODEPAGE_MASK;
         end;
        if e.flags and IF_CODEPAGE_MASK = 0 then
         if IsUTF8String(thisICQ.eventMsgA) then
          e.flags := e.flags or IF_UTF8_TEXT;
        e.ParseMsgStr(thisICQ.eventMsgA);
        if behave(e, EK_msg) then
          NILifNIL(c);
       end;
     end;
  IE_MultiChat:
     begin
      if thisICQ.eventAddress > '' then
        e.who := thisICQ.getICQContact(thisICQ.eventAddress);

      vS := plugins.castEv( PE_MSG_GOT, cuid, e.flags, e.when, thisICQ.eventMsgA);
      if not isAbort(vS) then
       begin
        if (vS>'') and (ord(vS[1])=PM_DATA) then
         begin
           thisICQ.eventMsgA := _istring_at(vS, 2);
           e.flags := e.flags and not IF_CODEPAGE_MASK;
         end;
        if e.flags and IF_CODEPAGE_MASK = 0 then
         if IsUTF8String(thisICQ.eventMsgA) then
          e.flags := e.flags or IF_UTF8_TEXT;
        e.ParseMsgStr(thisICQ.eventMsgA);
        if behave(e, EK_msg) then
          NILifNIL(c);
       end;
     end;
  IE_gcard:
    if not isAbort(plugins.castEv( PE_GCARD_GOT, cuid, e.flags, e.when, thisICQ.eventAddress )) then
      begin
 {$IFDEF DB_ENABLED}
         e.fBin := '';
         e.txt := thisICQ.eventAddress;
 {$ELSE ~DB_ENABLED}
         e.SetInfo(thisICQ.eventAddress);
 {$ENDIF ~DB_ENABLED}
       if behave(e, EK_gcard) then
         NILifNIL(c);
      end;
  IE_email:
    begin
      sU := UnUTF(thisICQ.eventMsgA);
      if not filterRefuse(NIL, sU, IF_PAGER) and not isAbort(plugins.castEv( PE_EMAILEXP_GOT, e.when, thisICQ.eventNameA, thisICQ.eventAddress, thisICQ.eventMsgA )) then
      msgDlg('___EMAIL EXPRESS___'+
         #13+ UnUTF(thisICQ.eventNameA)+' ('+thisICQ.eventAddress+')'+
         #13+ sU, False, mtInformation);
    end;
  IE_webpager:
    begin
      sU := UnUTF(thisICQ.eventMsgA);
      if not filterRefuse(NIL, sU, IF_PAGER) and not isAbort(plugins.castEv( PE_WEBPAGER_GOT, e.when, thisICQ.eventNameA, thisICQ.eventAddress, thisICQ.eventMsgA )) then
      msgDlg('___WEB PAGER___'+
         #13+ UnUTF(thisICQ.eventNameA)+' ('+ thisICQ.eventAddress+')'+
         #13+ sU, False, mtInformation);
    end;
  IE_fromMirabilis:
    begin
      sU := UnUTF(thisICQ.eventMsgA);
      if not filterRefuse(NIL, sU) and not isAbort(plugins.castEv( PE_FROM_MIRABILIS, e.when, thisICQ.eventNameA, thisICQ.eventAddress, thisICQ.eventMsgA )) then
      msgDlg('___FROM MIRBILIS___'+
         #13+ UnUTF(thisICQ.eventNameA)+' ('+thisICQ.eventAddress+')'+
         #13+ sU, False, mtInformation);
    end;
  IE_StickerMsg:
    begin
      if thisICQ.eventAddress > '' then
        begin
 {$IFDEF DB_ENABLED}
         e.fBin := '';
         e.txt := thisICQ.eventMsgA + CRLF + thisICQ.eventAddress;
 {$ELSE ~DB_ENABLED}
         e.SetInfo(thisICQ.eventMsgA + CRLF + thisICQ.eventAddress);
 {$ENDIF ~DB_ENABLED}
        end
       else
        begin
         e.ParseMsgStr(thisICQ.eventMsgA);
        end;
      if behave(e, EK_msg) then
        NILifNIL(c);
    end;
  end;
 if thisICQ.eventFlags and IF_offline > 0 then
  if ev in [IE_msg,IE_url,IE_addedYou,IE_authReq,IE_contacts] then
  // we already played a sound for the first offline message, let's make no other sound
    disableSounds :=TRUE;
 if Assigned(e) then
  e.free;
 if Assigned(statusIcon) then
   statusIcon.update;
end; // icqEvent

function getRnQVerFor(c: TRnQContact): Integer;
var
  s: RawByteString;
  capa: RawByteString;
  i: integer;
begin
  result := 0;
  if c=NIL then
    exit;
  case TICQcontact(c).lastupdate_dw of
    RnQclientID:
      result    := TICQcontact(c).lastinfoupdate_dw and ($FFFFFF); // Rapid D
  end;
  if result > 0 then
    exit;

  s:= TICQcontact(c).extracapabilities;
 while s > '' do
  begin
   capa:=chop(17,0,s);
    if pos(AnsiString('R&Qinside'),capa) > 0 then
    begin
{     result:='R&Q ';
     if capa[14] = #1 then
       result:=result + 'lite '
     else if capa[14] = #2 then
       result:=result + 'test ';
}
     i := (Byte(capa[15]) shl 8) + Byte(capa[16]);
     if i > 0 then
       result := i
     else
       result := Byte(@capa[14]);
    end;
  end;

{if result > 0 then exit;

   for I := CAPS_Ext_CLI_First to CAPS_Ext_CLI_Last do
     if i in c.capabilitiesBig then
      begin
       result := BigCapability[i].s;
       if i = CAPS_big_QIP then
        if c.lastupdate_dw > 0 then
         result := result + ' (' +ip2str(c.lastupdate_dw) + ')';
       Exit;
      end;

if CAPS_big_SecIM in c.capabilitiesBig then
  begin
    result := PIC_CLI_TRIL;
    exit;
  end;
}
end; // getRnQVerFor

procedure updateClients(pr: TRnQProtocol);
var
  cnt: TRnQContact;
begin
  if Assigned(Account.AccProto) then
    if Account.AccProto is TicqSession then
      begin
        for cnt in Account.AccProto.readList(LT_ROSTER) do
          Account.AccProto.getClientPicAndDesc4(cnt, cnt.ClientPic, cnt.ClientDesc)

      end;
end;

procedure openICQURL(pr: TRnQProtocol; const pURL: String);
begin
  {$IFDEF ICQ_REST_API}
  ICQREST_openICQURL(pURL);
  {$ELSE ~ICQ_REST_API}
  openURL(pURL);
  {$ENDIF ~ICQ_REST_API}
end;

end.
