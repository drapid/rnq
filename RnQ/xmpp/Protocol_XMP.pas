{
This file is part of R&Q.
Under same license
}
unit Protocol_XMP;
{$I RnQConfig.inc}
{$I NoRTTI.inc}

interface
 uses
   Classes, outboxlib, events,
   XMPPContacts, XMPPv1, XMPP_proto,
   RnQProtocol, RnQProtoUtils;//, viewMRAinfoDlg;


  procedure loggaXMPPPkt(what: TwhatLog; data: RawByteString='');
//  function  findMRAViewInfo(c:TRnQContact):TviewMRAInfoFrm;
  procedure ProcessXMPPEvents(thisXMP: TxmppSession; ev: TxmppEvent);

  function  XMPPstr2status(const s: RawByteString): byte;
  function  XMPPstr2visibility(const s: RawByteString): TxmppVisibility;

//  function  Proto_get_Ack(proto: TRnQProtocol): Toutbox;
//  function  enterProtoPWD(const thisProto: TRnQProtocol): boolean;

implementation

 uses
   Forms,
   OverbyteIcsWSocket,
 {$IFDEF UNICODE}
   AnsiStrings,
 {$ENDIF}
   utilLib, RnQConst, globalLib, RnQNet,
   RQUtil, RnQDialogs, RQlog,
   RnQTips,
   rnqLangs, RnQStrings, RnQGlobal,
   RnQBinUtils, RnQFileUtil, RQThemes,
   iniLib, mainDlg, RnQtraylib,
   pluginutil, pluginLib, SysUtils, RDGlobal, RDUtils,
   roasterLib, themesLib,
 {$IFDEF RNQ_AVATARS}
  RnQ_Avatars,
 {$ENDIF}
   Protocols_all,
   chatDlg;

function Proto_get_Ack(proto: TRnQProtocol): Toutbox;
begin
  Result := Account.acks;
end;

procedure loggaXMPPPkt(what: TwhatLog; data: RawByteString='');
var
  head, s: string;
//  isPacket: Boolean;
begin
 s := '';
// isPacket := False;
{ if Length(Data) > 10 then
   isPacket := cardinal(dword_LEat(@data[1])) = CS_MAGIC;
 if isPacket then
  if what in [WL_serverGot, WL_serverSent] then
//   if getFlapChannel(data) = SNAC_CHANNEL then
     s := '(' + IntToHex((getMRASnacService(data)), 2) + ') ';
}
 s := s + LogWhatNames[what];

if data>'' then
  if what in [WL_CONNECTED, WL_DISCONNECTED, WL_connecting] then
    begin
      s := s+' '+data;
      data := '';
    end
  else
    s := s+' size:'+intToStr(length(data),4);
{
 if isPacket then
  case what of
   WL_serverGot, WL_serverSent:
     if length(data) >= 16 then
      s:=s+' ref:'+intToHex(getMRASnacRef(data),8)+' '+GetPacketName(getMRASnacService(data));
  end;
}
{
  if data > '' then
   begin
     appendFile(logPath+packetslogFilename + '.2', #13#10+ '=============================='+#13#10);
     appendFile(logPath+packetslogFilename + '.2', data);
   end;
}
  head := logtimestamp+s;
  logProtoPkt(what, head, data);
{
  if logpref.pkts.onwindow and assigned(logfrm) then
    begin
//    h := s;
    logFrm.dumpBox.Text := TxmppSession(Account.AccProto).getFlapBuf;
    end;
}
end; // loggaPkt

{function findMRAViewInfo(c: TRnQcontact): TviewMRAInfoFrm;
var
  i: integer;
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
}

procedure ProcessXMPPEvents(thisXMP: TxmppSession; ev: TxmppEvent);
var
  c: TxmppContact;
  b: boolean;
  i: integer;
//  s,
  cuid: string;
  e, TempEv: Thevent;
  TempCh: TchatInfo;
//  vS: String;
//  vSU: String;
  vSA: RawByteString;
  vThisAcks: Toutbox;
begin
  c := thisXMP.eventContactRes.cnt;
  if Assigned(c) then
    cuid := c.uid;
// these icqevents are associated with hevents
 if ev in [XMPPv1.IE_msg, XMPPv1.IE_url, XMPPv1.IE_contacts, XMPPv1.IE_authReq,
      XMPPv1.IE_addedyou, XMPPv1.IE_oncoming, XMPPv1.IE_offgoing, XMPPv1.IE_auth,
      XMPPv1.IE_authDenied, XMPPv1.IE_automsgreq, XMPPv1.IE_statuschanged,
      XMPPv1.IE_gcard, XMPPv1.IE_ack, XMPPv1.IE_email, XMPPv1.IE_webpager,
//      XMPPv1.IE_fromMirabilis,
      XMPPv1.IE_TYPING//, XMPPv1.IE_ackXStatus, XMPPv1.IE_XStatusReq
      ] then
  begin
  e := Thevent.new(EK_null, c, thisXMP.eventTime,
                    '', thisXMP.eventFlags);
  e.otherpeer := c;
{  if ev in [XMPPv1.IE_contacts] then
    begin
    e.cl:=thisXMP.eventContacts.clone;
    e.cl.remove(thisXMP.myInfo);
    e.cl.remove(c);
    end;}
  if ev in [XMPPv1.IE_msg, XMPPv1.IE_url, XMPPv1.IE_authreq] then
   begin
 { $IFDEF DB_ENABLED}
//    e.fBin := '';
//    e.txt := thisXMP.eventMsg;
 { $ELSE ~DB_ENABLED}
    e.setInfo(thisXMP.eventMsg);
 { $ENDIF ~DB_ENABLED}
   end;
//  if ev in [XMPPv1.IE_ack, XMPPv1.IE_authDenied] then
//    e.setInfo(char(thisXMP.eventAccept)+thisXMP.eventMsg);
  end
 else
  e:=NIL;
 case ev of
  XMPPv1.IE_serverSent: loggaXMPPPkt(WL_rcvd_text,thisXMP.eventData);
  XMPPv1.IE_serverGot:  loggaXMPPPkt(WL_sent_text,thisXMP.eventData);
  XMPPv1.IE_serverConnected:    loggaXMPPPkt(WL_connected, thisXMP.eventAddress);
  XMPPv1.IE_serverDisconnected: loggaXMPPPkt(WL_disconnected, thisXMP.eventAddress);
  XMPPv1.IE_connecting:
    begin
      loggaXMPPPkt(WL_connecting, thisXMP.eventAddress);
      disableSounds:=FALSE;
      setProgBar(thisXMP, 1/progLogonTotal);
      thisXMP.sock.proxySettings(thisXMP.aProxy);
    end;
  XMPPv1.IE_connected: setProgBar(thisXMP, 2/progLogonTotal);
  XMPPv1.IE_loggin:    setProgBar(thisXMP, 3/progLogonTotal);
  XMPPv1.IE_redirecting:
    begin
      loggaXMPPPkt(WL_connecting, thisXMP.eventAddress);
      setProgBar(thisXMP, 4/progLogonTotal);
      thisXMP.sock.proxySettings(thisXMP.aProxy);
    end;
  XMPPv1.IE_redirected:   setProgBar(thisXMP, 5/progLogonTotal);
  XMPPv1.IE_almostonline: setProgBar(thisXMP, 6/progLogonTotal);
  XMPPv1.IE_visibilityChanged:
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
  XMPPv1.IE_error:
    if thisXMP.eventError = XMPPv1.EC_badContact then
      loggaEvtS(format('ERROR: bad contact: %s',[thisXMP.eventContact.uid]))
    else
      begin
        setProgBar(thisXMP, 0);
        theme.PlaySound(Str_Error); //sounds.onError);
        if (thisXMP.eventError in [
          XMPPv1.EC_badUIN,
          XMPPv1.EC_badPwd,
          XMPPv1.EC_proxy_badPwd,
//          EC_anotherLogin,
          XMPPv1.EC_invalidFlap,
          XMPPv1.EC_rateExceeded,
          XMPPv1.EC_missingLogin
        ]) or (autoReconnectStop and (thisXMP.eventError = XMPPv1.EC_anotherLogin))
          then
          stayConnected:=FALSE;
        if (autoReconnectStop and (thisXMP.eventError = XMPPv1.EC_anotherLogin)) then
          lastStatusUserSet := byte(SC_OFFLINE);
        if thisXMP.eventError = XMPPv1.EC_missingLogin then
          if thisXMP.enterPWD then
            doConnect//(thisXMP)
           else
        else
        if thisXMP.eventError = XMPPv1.EC_badPwd then
         begin
           msgDlg(getTranslation(xmppError2str[thisXMP.eventError], [thisXMP.eventMsg]), False, mtError);
//          thisXMP.pwd := '';
          if thisXMP.enterPWD then
            begin
            thisXMP.disconnect();
            doConnect;//(thisXMP);
            end;
         end
        else
          if showDisconnectedDlg or not (thisXMP.eventError in [
            XMPPv1.EC_rateExceeded,
            XMPPv1.EC_cantConnect,
            XMPPv1.EC_socket,
            XMPPv1.EC_serverDisconnected,
            XMPPv1.EC_loginDelay,
            XMPPv1.EC_invalidFlap
          ]) then
//            if thisICQ.eventError = EC_proxy_unk then
//               msgDlg(___('icqerror '+icqerror2str[thisICQ.eventError], [thisICQ.eventMsg]), mtError)
//              msgDlg(getTranslation(icqerror2str[thisICQ.eventError], [thisICQ.eventMsg]), mtError)
//            else
              msgDlg(getTranslation(xmppError2str[thisXMP.eventError], [thisXMP.eventInt, thisXMP.eventMsg]), False, mtError);
//        if thisXMP.eventError = XMPPv1.EC_other then
//          msgDlg(getTranslation(ICQauthErrors[thisXMP.eventInt],[thisXMP.eventMsg]), mtError)
      end;
  XMPPv1.IE_online,
  XMPPv1.IE_offline:
    begin
    outboxCount:=-1;
    keepalive.timer:=keepalive.freq;
    b := false;
//    b := myStatus <> byte(SC_OFFLINE);
//    myStatus:= thisICQ.getStatus;
    b := b or (thisXMP.getStatus <> byte(SC_OFFLINE));
    b := b or (ev=XMPPv1.IE_offline);
    setProgBar(thisXMP, 0);
    if ev = XMPPv1.IE_online then
     begin
       //  вызов балуна
      {$IFDEF Use_Baloons}
       statusIcon.showballoon(2000, getTranslation('Online'),
                              Application.MainForm.Caption, bitinfo);
//       showballoon(RnQmain.handle,100, 2000, getTranslation('Online'), RnQmain.Caption, bitinfo);
      {$ENDIF Use_Baloons}
      thisXMP.offlineMsgsChecked := FALSE;
      outboxCount := timeBetweenMsgs;
      stayconnected := autoreconnect;
      plugins.castEv(PE_CONNECTED);
      if thisXMP.getOfflineMsgs then
        thisXMP.sendReqOfflineMsgs
      else
        if thisXMP.delOfflineMsgs then
          begin
          thisXMP.offlineMsgsChecked := TRUE;
          thisXMP.sendDeleteOfflineMsgs;
          end;
      if (Length(thisXMP.OfflMsgs)=0) then
       thisXMP.offlineMsgsChecked:=TRUE;
       {$IFDEF CHECK_INVIS}
      checkInvis.lastAllChkTime := now;
       {$ENDIF}
      toReconnectTime := 50;
     end
    else
      begin
//        inc(saveDBtimer, saveDBdelay);
        incDBTimer;
     {$IFDEF RNQ_FULL}
//      showballoon(handle,100, 2000, getTranslation('Offline'), Caption, bitinfo);
     {$ENDIF RNQ_FULL}
       if clearPwdOnDSNCT and dontSavePwd then
        if Assigned(thisXMP) and thisXMP.isOffline then
         thisXMP.pwd := '';
       with thisXMP.contactsDB.clone do
       begin
        resetEnumeration;
        while hasMore do
            with TxmppContact(getNext) do
             begin
              setStatus(xmppContacts.SC_UNK);
              OfflineClear;
             end;
         free;
       end;
      {$IFDEF CHECK_INVIS}
       autoCheckInvQ.Clear;
       CheckInvQ.Clear;
      {$ENDIF CHECK_INVIS}

//       vThisAcks := Proto_get_Ack(thisXMP);
//       if Assigned(vThisAcks) then
//         vThisAcks.Clear;
       Account.acks.Clear;

      plugins.castEv(PE_DISCONNECTED);
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
  XMPPv1.IE_statuschanged:
    begin
      if not Assigned(c) or thisXMP.isMyAcc(c) then
       begin
        plugins.castEv( PE_STATUS_CHANGED, cuid, thisXMP.getStatus, byte(thisXMP.eventOldStatus), thisXMP.IsInvisible, thisXMP.eventOldInvisible);
        updateViewInfo(thisXMP.getMyInfo);
//        myStatus := thisXMP.getStatus;
        if thisXMP.getStatus <> byte(SC_OFFLINE) then
          lastStatus:= thisXMP.getStatus;
        RnQmain.updateStatusGlyphs;
        roasterLib.redraw;
       end
      else
      begin
       plugins.castEv( PE_STATUS_CHANGED, cuid, byte(c.status), byte(thisXMP.eventOldStatus), c.invisible, thisXMP.eventOldInvisible);
       updateViewInfo(c);
        if c.isInRoster then
          begin
          if (c.status <> TxmppStatus(SC_OFFLINE))  then
           else
            begin
              c.setOffline;
  //            c.ICQVer := '';
            end;
          roasterLib.update(c);//  Что-то нада убрать тут!!!!
  //        roasterLib.redraw(c);
          roasterLib.updateHiddenNodes;
  //        chatFrm.userChanged(c);
           redraw(c);
  //        e.info:=int2str(integer(c.status))+char(c.invisible) +char(c.xStatus);
 {$IFDEF DB_ENABLED}
          e.fBin :=int2str(integer(c.status))+AnsiChar(c.invisible) + AnsiChar(#0);//AnsiChar(c.xStatus.id);
 {$ELSE ~DB_ENABLED}
          e.f_info := int2str(integer(c.status))+ AnsiChar(c.invisible) + AnsiChar(0);

 {$ENDIF ~DB_ENABLED}
          if oncomingOnAway
          and (thisXMP.eventOldStatus in [byte(mSC_AWAY)])
          and not (c.status in [mSC_AWAY])
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
//       if autoRequestXsts and (c.xStatus > 0) and thisICQ.imVisibleTo(c) then
//         reqXStatusQ.Add(c);
}
      end;
      autosizeDelayed:=TRUE;
    end;
  XMPPv1.IE_userinfo:
    begin
      plugins.castEv( PE_USERINFO_CHANGED, cuid );
      updateViewInfo(c);
      if thisXMP.isMyAcc(c) then
        RnQmain.updateCaption
      else
        roasterLib.redraw(c);
      TipsUpdateByCnt(c);
  //   roasterLib.updateHiddenNodes;
  //   chatFrm.userChanged(c);
       redraw(c);
      dbUpdateDelayed:=TRUE;
    end;
   {$IFDEF RNQ_AVATARS}
  IE_avatar_changed:
//    if thisXMP.AvatarsSupport then
     begin
      if not try_load_avatar(c, c.XIcon.hash, c.Icon.Hash_safe) then
//       if thisXMP.AvatarsAutoGet then
          reqAvatarsQ.add(c)
//        else
//         if c.icon.ToShow = IS_AVATAR then
//           ClearAvatar(TRnQContact(c));
        ;
      if TO_SHOW_ICON[CNT_ICON_AVT] then
        redraw(c);
     end;
   {$ENDIF RNQ_AVATARS}
  IE_getAvtr:
    begin
      if Assigned(thisXMP.eventStream) and
         Assigned(c) then
       begin
        if thisXMP.eventStream.size > 0 then
         begin
          avatars_save_and_load(c,
                                c.XIcon.Hash,
                                c.Icon.Hash_safe,
                                thisXMP.eventStream);
          if Assigned(thisXMP.eventStream) then
            freeAndNil(thisXMP.eventStream);
          updateAvatarFor(c);
         end
        else
          freeAndNil(thisXMP.eventStream);
       end;
    end;
{
  XMPPv1.IE_wpResult: if (wpMRAFrm<>NIL) then wpMRAFrm.addResult(thisXMP.eventContact);
  XMPPv1.IE_wpEnd:
    if (wpMRAFrm<>NIL) then
      begin
       if thisXMP.eventInt > 0 then
       begin
        wpMRAFrm.N_Allresults := thisXMP.eventInt;
        wpMRAFrm.updateNumResults;
//        msgDlg(getTranslation('End of search\nThere are %d more results but ICQ server shows only first ones, sorry.', [thisICQ.eventInt]),mtInformation);
       end;
       wpMRAFrm.stopSearch;
      end;
}
  XMPPv1.IE_numOfContactsChanged:
     begin
//    contactsPnl.text := intToStr(thisICQ.readroaster.count);
       contactsPnlStr := intToStr(TList(thisXMP.readList(LT_ROSTER)).count);
       roasterLib.rebuild;
     end;
  XMPPv1.IE_authReq:
     if not filterRefuse(c, '', IF_auth) and not isAbort(plugins.castEv( PE_AUTHREQ_GOT, cuid, e.flags, e.when, thisXMP.eventMsg ))
        and behave(e, EK_authReq) then
      begin
//                roasterLib.updateHiddenNodes;
//                chatFrm.userChanged(c);
                redraw(c);
      NILifNIL(c);
      end;
  XMPPv1.IE_msg:
     begin
      vSA := plugins.castEv( PE_MSG_GOT, cuid, e.flags, e.when, StrToUTF8(thisXMP.eventMsg));
      if not isAbort(vSA) then
       begin
        if (vSA>'') and (ord(vSA[1])=PM_DATA) then
         thisXMP.eventMsg := UnUTF(_istring_at(vSA, 2));
 { $IFDEF DB_ENABLED}
//         e.fBin := '';
//         e.txt := thisXMP.eventMsg;
 { $ELSE ~DB_ENABLED}
         e.flags := (e.flags and not IF_CODEPAGE_MASK) or IF_UTF8_TEXT;
         e.SetInfo(StrToUTF8(thisXMP.eventMsg));
 { $ENDIF ~DB_ENABLED}
        if behave(e, EK_msg) then
          NILifNIL(c);
       end;
     end;
  XMPPv1.IE_contactupdate:
    begin
      roasterLib.update(c);
      roasterLib.updateHiddenNodes;
//                chatFrm.userChanged(c);
         redraw(c);
      updateViewInfo(c);
//      autosizeDelayed:=TRUE;
    end;
  XMPPv1.IE_redraw:
     roasterLib.redraw(c);
  XMPPv1.IE_typing: if not filterRefuse(c) then
    begin
//     e.kind := EK_Typing;
     roasterLib.redraw(c);
{     if thisXMP.eventInt = MTN_CLOSED then
      begin
        // Закрыли чат
      end;
}
     if c.typing.bistyping then
      behave(e, EK_typingBeg)
     else
      behave(e, EK_typingFin);
    end;
  XMPPv1.IE_email_cnt:
    begin
     {$IFNDEF DB_ENABLED}
      RnQmain.MlCntBtn.Caption := getTranslation('Mails in box: %d', [thisXMP.eventInt]);
     {$ENDIF ~DB_ENABLED}
    end;
  XMPPv1.IE_email_mpop:
    begin
//      openURL('http://win.mail.ru/cgi-bin/auth?Login='+ thisXMP.getMyInfo.UID2cmp+'&agent='+thisXMP.eventData,
//              useDefaultBrowser, browserCmdLine);
    end;
  XMPPv1.IE_email:
    begin
     {$IFNDEF DB_ENABLED}
      RnQmain.MlCntBtn.Caption := getTranslation('Mails in box: %d', [thisXMP.MailsCntUnread]);
     {$ENDIF ~DB_ENABLED}
      if not filterRefuse(NIL, thisXMP.eventMsg,IF_PAGER) and
         not isAbort(plugins.castEv( PE_EMAILEXP_GOT, e.when, thisXMP.eventName, thisXMP.eventAddress, thisXMP.eventMsg )) then
        begin
//        msgDlg('___EMAIL EXPRESS___'+
//         #13+ thisXMP.eventName+' (From: '+thisXMP.eventAddress+')'+
//         #13+ thisXMP.eventMsg,mtInformation);
 { $IFDEF DB_ENABLED}
//          e.fBin := '';
//          e.txt := 'Mail from: '+thisXMP.eventAddress + #13 + thisXMP.eventName;
 { $ELSE ~DB_ENABLED}
          e.setInfo('Mail from: '+thisXMP.eventAddress + #13 + thisXMP.eventName);
 { $ENDIF ~DB_ENABLED}
          e.kind := EK_MSG;
//          TipAdd(e);
          TipAdd3(e);
        end;
    end;
  XMPPv1.IE_msgError:
  	begin
//     vThisAcks := Proto_get_Ack(thisXMP);
     vThisAcks := Account.acks;
     if not Assigned(vThisAcks) then
       Exit;
     i := vThisAcks.findID(thisXMP.eventMsgID);
     if i>=0 then
    	with vThisAcks.getAt(i) do
        if kind = OE_MSG then
       begin
//          c:=TICQContact(contactsDB.get(uid));
          c := TxmppContact(whom);
//          	if thisICQ.eventInt=$0E then
              if ( info = 'MSG') then
               begin
                 TempCh := chatFrm.chats.byContact(c);
                 if TempCh <> NIL then
                  begin
        //            TempCh.historyBox.history.
                     TempEv := TempCh.historyBox.history.getByID(thisXMP.eventMsgID);
                     if TempEv <> NIL then
                      begin
                       TempEv.flags := TempEv.flags OR IF_not_delivered;// IF_MSG_OK;
                       TempCh.repaint();
                      end;
//                     TempEv := NIL;
                  end;
                TempCh.repaint();
               end;
          vThisAcks.Delete(i);
       end;
    end;
  XMPPv1.IE_ack:
    begin
     vThisAcks := Proto_get_Ack(thisXMP);
     if not Assigned(vThisAcks) then
       Exit;
     i:= vThisAcks.findID(thisXMP.eventInt);
    if i >= 0 then
     begin
      if vThisAcks.getAt(i).kind = OE_msg then
       begin
         TempCh := chatFrm.chats.byContact(vThisAcks.getAt(i).whom);
         if TempCh <> NIL then
          begin
//            TempCh.historyBox.history.
             TempEv := TempCh.historyBox.history.getByID(thisXMP.eventMsgID);
             if TempEv <> NIL then
              TempEv.flags := TempEv.flags OR IF_delivered;// IF_MSG_OK;
//             TempEv := NIL;
           TempCh.repaint();
          end;
       end;
      vThisAcks.delete(i);
     end;
    end;
 end;
 FreeAndNil(e);
  if Assigned(statusIcon) then
   statusIcon.update;
end;

function XMPPstr2status(const s: RawByteString): byte;
var
  ss: TPicName;
begin
  ss := LowerCase(s);
 for result:=byte(low(XMPPstatus2Img)) to byte(high(XMPPstatus2Img)) do
//  if LowerCase(status2img[TICQStatus(result)]) = s then
  if XMPPstatus2Img[tXMPPStatus(result)] = ss then
    exit;
 result:= byte(SC_ONLINE); // shut up compiler warning
end; // XMPPstr2status

function XMPPstr2visibility(const s: RawByteString):TxmppVisibility;
var
  ss : TPicName;
begin
  ss:=LowerCase(s);
 for result:=low(result) to high(result) do
  if XMPPvisib2str[result] = ss then
    exit;
 result:=mVI_normal; // shut up compiler warning
end; // str2visibility

end.
