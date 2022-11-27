{
  This file is part of R&Q.
  Under same license
}
unit Protocol_TLG;
{$I RnQConfig.inc}

interface

uses
  Windows, Classes,
  OverbyteIcsHttpProt,
  outboxlib, events, RnQProtocol, RnQProtoUtils,
  TLGcontacts, TLG, TLGConsts, RDGLobal, JSON, RnQJSON;

{$I NoRTTI.inc}

  procedure SendTLGContacts(cnt: TRnQContact; flags: integer; cl: TRnQCList);
//  procedure SendWIMAddedYou(cnt: TRnQContact);
  procedure ChangeXStatus(pWIM: TTLGSession; const st: Byte; const StName: String = ''; const StText: String = '');

  procedure LoggaTLGPkt(const Prefix: String; What: TWhatLog; Data: RawByteString = '');
  procedure ProcessTLGEvents(var thisProto: TTLGSession; ev: TTLGEvent; data: TJSONValue);


  //function  statusName(s:Tstatus):string;
  function  statusNameExt2(s: byte; extSts: byte = 0; const Xsts: String = ''; const sts6: String = ''): string;
  function  status2imgName(s: byte; inv: boolean=FALSE): TPicName;
  function  status2imgNameExt(s: byte; inv: boolean=FALSE; extSts: byte= 0): TPicName;
//  function  visibility2imgName(vi: Tvisibility): String;
  function  visibilityName(vi: Tvisibility): string;
  function str2status(const s: AnsiString): byte;
  function str2visibility(const s: AnsiString): Tvisibility;

  function  getRnQVerFor(c: TRnQContact): Integer;

  procedure updateClients(pr: TRnQProtocol);


implementation

uses
  Forms, SysUtils, Types, StrUtils, DateUtils,
 {$IFDEF UNICODE}
   AnsiStrings, AnsiClasses, WideStrUtils, Character,
 {$ENDIF}
  RnQBinUtils, RnQNet, RQUtil, RnQDialogs, RQlog,
  rnqLangs, RnQStrings, RQThemes, RDFileUtil, RDUtils,
  RnQTips, RnQTrayLib, RnQGlobal, RnQPics, RnQConst, RnQNet.Cache,
{$IFDEF RNQ_AVATARS}
  RnQ_Avatars,
{$ENDIF}
  globalLib, utilLib, iniLib,
  Protocols_all,
  RegUserFrm,
//  ICQClients,
//  WIM.Stickers,       
  pluginutil, pluginLib,
  roasterLib, themesLib, history,
  mainDlg, chatDlg;


{
procedure SendWIMAddedYou(cnt: TRnQContact);
var
  ev: THevent;
begin
  plugins.castEv(PE_ADDEDYOU_SENT, cnt.UID);
  TTLGSession(cnt.fProto).SendAddedYou(cnt.UID);
  ev := THevent.new(EK_ADDEDYOU, cnt, cnt.fProto.getMyInfo, Now, '', [], 0);
  ev.outgoing := True;
  if logpref.writehistory and (BE_save in behaviour[ev.kind].trig) then
    WriteToHistory(ev);
  chatFrm.AddEvent_OpenChat(cnt, ev);
end; // SendWIMAddedYou
}
procedure sendTLGcontacts(cnt: TRnQContact; flags: integer; cl: TRnQCList);
var
  ev: THevent;
//  c: Tcontact;
begin
//  c := Tcontact(contactsDB.get(TTLGContact, uin));
  plugins.castEv( PE_CONTACTS_SENT, cnt.uid, flags, cl);
  TTLGSession(cnt.Proto).sendContacts(cnt, flags, cl);
  ev := Thevent.new(EK_CONTACTS, cnt, now, cl.tostring, '', 0, flags);
  ev.fIsMyEvent := True;
  if logpref.writehistory and (BE_save in behaviour[ev.kind].trig) then
    writeHistorySafely(ev);
  chatFrm.addEvent_openchat(cnt, ev);
end; // sendWIMcontacts

procedure ChangeXStatus(pWIM: TTLGSession; const st: Byte; const StName: String = ''; const StText: String = '');
var
  b: Boolean;
begin
  if (st in [Low(0)..High(0)])
//     and ((UseOldXSt and (xsf_Old in XStatusArray[st].flags))
//        or (xsf_6 in XStatusArray[st].flags))
        then
  begin
    b := pWIM.curXStatus <> st;
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
      pWIM.setStatusStr(st, ExtStsStrings[st]);
      RnQmain.PntBar.Repaint;
//      saveListsDelayed := True;
      saveCfgDelayed := True;
//    SaveExtSts;
     end;
  end;
end;

procedure LoggaTLGPkt(const Prefix: String; What: TWhatLog; Data: RawByteString = '');
var
  Head, s: String;
begin
  if Prefix > '' then
    s := Prefix + ' '
  else
    s := '';

  s := s + LogWhatNames[What];
  if not (Data = '') then
  if What in [WL_connected, WL_disconnected, WL_connecting] then
  begin
    s := s + ' ' + Data;
    Data := '';
  end else
    s := s + ' size: ' + IntToStr(Length(Data), 4);

  Head := LogTimestamp + s;
  LogProtoPkt(What, Head, Data, True);
end; // loggaPkt

function statusNameExt2(s: Byte; extSts: Byte = 0; const Xsts: String = ''; const sts6: String = ''): String;
begin
  if ({XStatusAsMain}False or (s = Byte(SC_ONLINE))) and (extSts > 0) then
    begin
      if XSts > '' then
//        result := getTranslation(Xsts)
        result := Xsts
       else
        if sts6 > '' then
          result := sts6
         else
//          result := getTranslation(XStatusArray[extSts].Caption)
          result := getTranslation(status2ShowStr[TTLGStatus(s)])
    end
   else
//    if sts6 > '' then
//      result := sts6
//     else
      result := getTranslation(status2ShowStr[TTLGStatus(s)])
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

function status2imgNameExt(s: Byte; inv: Boolean = False; extSts: Byte = 0): TPicName;
const
  prefix = 'status.';
begin
// if False{XStatusAsMain} and (extSts > 0) then
//   result := XStatusArray[extSts].PicName
// else
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
begin
  result := getTranslation(visibility2ShowStr[vi])
end;

function str2status(const s: AnsiString): byte;
var
  ss: TPicName;
begin
  ss := LowerCase(s);
  for result := byte(low(status2img)) to byte(high(status2img)) do
    // if LowerCase(status2img[TICQStatus(result)]) = s then
    if status2img[result] = ss then
      exit;
  result := byte(SC_ONLINE); // shut up compiler warning
end; // str2status

function str2visibility(const s: AnsiString): Tvisibility;
var
  ss: TPicName;
begin
  ss := LowerCase(s);
  for result := low(result) to high(result) do
    if visib2str[result] = ss then
      exit;
  result := VI_normal; // shut up compiler warning
end; // str2visibility

function findTLGViewInfo(c: TRnQcontact): TRnQViewInfoForm;
var
  i: Integer;
begin
  with childWindows do
  begin
    i := 0;
    while i < count do
    begin
      if TObject(items[i]) is TRnQViewInfoForm then
      begin
        result := TRnQViewInfoForm(items[i]);
        if result.contact.equals(c) then
          Exit;
      end;
      inc(i);
    end;
  end;
  result := nil;
end; // findViewInfo


procedure onGetServerHistory(chat: TTLGContact; hist: TJSONValue);

  function sameTextMsgExists(ev: Thevent; const text: String; kind: Integer): Boolean;
  begin
    Result := not (ev = nil) and (ev.getBodyText = text) and (ev.kind = kind);
  end;

  function sameBinMsgExists(ev: Thevent; bin: RawByteString; kind: Integer): Boolean;
  begin
    Result := not (ev = nil) and (ev.getBodyBin = bin) and (ev.kind = kind);
  end;

var
//  query, params, lastMsgId, fromMsgId, PatchVer: String;
//  respStr: RawByteString;
//  msg, Patch: TJSONValue;
//  json, results
//  messages, Patches: TJSONArray;
  wid: String;
  msg, text, tmp: TJSONValue;
  stickerObj: TJSONObject;
  msgCount, unixTime, code, ind, kind: Integer;
  PatchMsgId: Int64;
  extsticker: TStringDynArray;
  stickerBin: RawByteString;
  time: TDateTime;
  outgoing: Boolean;
  ev, evtmp, evtmp2: Thevent;
//  cht, cnt: TRnQContact;
  cnt: TRnQContact;
  histF: Thistory;
  histArr: TJSONArray;


  procedure FreeBeforeContinue;
  begin
    if Assigned(evtmp) then
      FreeAndNil(evtmp);
    if Assigned(evtmp2) then
      FreeAndNil(evtmp2);
  end;

begin
  evtmp := nil;
  evtmp2 := nil;
  histArr := TJSONArray(hist);

//    histF := Thistory.Create(LowerCase(uid));
    histF := Thistory.Create;
    histF.load(chat, true);

    for msg in histArr do
    if not (msg = nil) and (msg is TJSONObject) then
    begin
      msg.GetValueSafe('time', unixTime);
      time := UnixToDateTime(unixTime, False);
{
      if not LoadEntireHistory and (CompareDateTime(time, NewHistFirstStart) < 0) then
      begin
        OutputDebugString(PChar('Msg was created before the new history'));
        Continue;
      end;
 }
      evtmp := histF.getByTime(time);

      tmp := (msg as TJSONObject).GetValue('outgoing');
      outgoing := not (tmp = nil) and (tmp.Value = 'true');

      if outgoing then
        cnt := Account.AccProto.getMyInfo
      else
        cnt := chat;

      wid := '';
      tmp := (msg as TJSONObject).GetValue('wid');
      if Assigned(tmp) then
      begin
        tmp.TryGetValue(wid);
        evtmp2 := histF.getByWID(wid);
        if not (wid = '') and not (evtmp2 = nil) then
        begin
          OutputDebugString(PChar('Msg is already in history (WID ' + wid + ')'));
          FreeBeforeContinue;
          Continue;
        end;
        if Assigned(evtmp2) then
          FreeAndNil(evtmp2);
      end;

      text := (msg as TJSONObject).GetValue('text');
      stickerObj := (msg as TJSONObject).GetValue('sticker') as TJSONObject;
{      if not (stickerObj = nil) then
      begin
        text := stickerObj.GetValue('id');
        extsticker := SplitString(text.Value, ':');
//        if EnableStickers and (length(extsticker) >= 4) then
        if (length(extsticker) >= 4) then
        begin
          kind := EK_msg;
          stickerBin := GetSticker(extsticker[1], extsticker[3]);
          evtmp2 := histF.getByTime(time);
          if sameBinMsgExists(evtmp2, stickerBin, kind) then
          begin
            OutputDebugString(PChar('EK_msg with the same sticker is already in history (WID ' + wid + ')'));
            FreeBeforeContinue;
            Continue;
          end;
          if Assigned(evtmp2) then
            FreeAndNil(evtmp2);
          ev := Thevent.new(kind, chat, time, 0, 0, wid);
          ev.fIsMyEvent := outgoing;
//          ev.setImgBin(stickerBin);
//          histF.WriteToHistory(ev.clone);
          ev.Free;
          FreeBeforeContinue;
          Continue;
        end;
      end;
  }
      { TODO: Add bday, buddy_added and other events }
      tmp := (msg as TJSONObject).GetValue('eventTypeId');
      if not (tmp = nil) then
      begin
        if tmp.Value = '27:51000' then
        begin
          kind := EK_msg;
          if sameTextMsgExists(evtmp, text.Value, kind) then
          begin
            OutputDebugString(PChar('EK_msg with the same time is already in history'));
            FreeBeforeContinue;
            Continue;
          end;
          ev := Thevent.new(kind, chat, time, '', '[' + GetTranslation('Message deleted') + ']', IF_not_delivered, 0, wid);
          ev.fIsMyEvent := outgoing;
//          histF.WriteToHistory(ev.clone);
          ev.Free;
          FreeBeforeContinue;
          Continue;
        end else if tmp.Value = '27:33000' then
        begin
          kind := EK_AddedYou;
          if sameTextMsgExists(evtmp, text.Value, kind) then
          begin
            OutputDebugString(PChar('EK_AddedYou with the same time is already in history'));
            FreeBeforeContinue;
            Continue;
          end;
          ev := Thevent.new(kind, chat, time, 0);
          ev.fIsMyEvent := False;
//          histF.WriteToHistory(ev.clone);
          ev.Free;
          FreeBeforeContinue;
          Continue;
        end else if tmp.Value = '27:33000' then
        begin
          // Bday event is never saved on disk, ignore
          kind := EK_BirthDay;
          FreeBeforeContinue;
          Continue;
        end;
      end;

      if not (text = nil) then
      try
        kind := EK_msg;
        evtmp2 := histF.getByTime(time);
        if sameTextMsgExists(evtmp2, text.Value, kind) then
        begin
          OutputDebugString(PChar('EK_msg with the same time/text is already in history (WID ' + wid + ')'));
          FreeBeforeContinue;
          Continue;
        end;
        if Assigned(evtmp2) then
          FreeAndNil(evtmp2);
        ev := Thevent.new(kind, chat, time, '', text.Value, 0, 0, wid);
        ev.fIsMyEvent := outgoing;
//        histF.WriteToHistory(ev.clone);
        ev.Free;
      except
        OutputDebugString(PChar('Not a json'));
      end else
        OutputDebugString(PChar('Empty msg'));
      if Assigned(evtmp) then
        FreeAndNil(evtmp);
    end;
    hist.Free;
  //end else OutputDebugString(PChar('Cannot parse code!'));
end;


procedure ProcessTLGEvents(var thisProto: TTLGSession; ev: TTLGEvent; data: TJSONValue);
var
  c: TTLGContact;
  b: Boolean;
  i: Integer;
  sU: String;
  rS: RawByteString;
  e, TempEv: Thevent;
  TempCh: TchatInfo;
  TempHist: Thistory;
  vS: AnsiString;
  cuid: TUID;
  DlgType: TMsgDlgType;
  Temp: String;
  eventWID: String;
begin
  c := thisProto.eventContact;
  thisProto.eventContact := nil;
  if Assigned(c) then
    cuid := c.uid2cmp
  else
    cuid := '';

  // these WIMevents are associated with hevents
  if ev in [TTLGEvent(IE_msg), IE_url, IE_buzz, IE_contacts, IE_authReq, IE_addedyou,
      TTLGEvent(IE_incoming), TTLGEvent(IE_outgoing), IE_auth, IE_authDenied,
      IE_automsgreq, IE_statuschanged, IE_gcard, IE_ack,
      IE_email, IE_webpager, IE_fromMirabilis, IE_TYPING, //IE_ackXStatus,
      IE_XStatusReq, IE_MultiChat] then
  begin
    e := Thevent.new(EK_null, c, thisProto.eventTime, thisProto.eventFlags, thisProto.eventMsgID, eventWID);
    e.otherpeer := c;
    if ev in [IE_contacts] then
    begin
      e.cl := thisProto.eventContacts.clone;
      e.cl.remove(thisProto.getMyInfo);
      e.cl.remove(c);
    end else if ev in [IE_url, IE_authreq] then
      begin
        e.fBin := '';
        e.txt := UnUTF(thisProto.eventMsgA);
      end
    else if ev in [IE_ack, IE_authDenied] then
      begin
        e.fBin := AnsiChar(thisProto.eventAccept);
        e.txt := UnUTF(thisProto.eventMsgA);
      end;
  end else
    e := nil;

case ev of
	IE_serverAck:
  	begin
      i := Account.acks.findID(thisProto.eventReqID);
      if i >= 0 then  // exploit only for automsgreq
       if Account.acks.getAt(i).kind = OE_msg then
        begin
          c := Account.acks.getAt(i).whom as TTLGContact;
          TempCh := chatFrm.chats.byContact(c);
          if TempCh <> NIL then
              begin
                 TempEv := TempCh.historyBox.history.getByID(thisProto.eventReqID);
                 if TempEv <> NIL then
                  begin
//                    TempEv.flags := TempEv.flags OR IF_SERVER_ACCEPT;// IF_MSG_SERVER;
                    if thisProto.eventMsgA = 'sent' then
                      TempEv.flags := TempEv.flags or IF_Server_Accept
                     else if thisProto.eventMsgA = 'failed' then
                      TempEv.flags := TempEv.flags or IF_Not_Delivered
                     else if thisProto.eventMsgA = 'delivered' then
                      TempEv.flags := TempEv.flags or IF_Delivered;
                    TempEv.writeWID(thisProto.eventMsgID, eventWID);
  //                 TempEv := NIL;
                    TempCh.repaint();
                  end;
              end;

        if (Account.acks.getAt(i).flags and IF_Simple > 0) then
          Account.acks.Delete(i);
      end
    end;
  IE_srvSomeInfo:
    begin
      i:= Account.acks.findID(thisProto.eventReqId);
      if i>=0 then
      	with Account.acks.getAt(i) do
        begin
         if kind = OE_MSG then
        	begin
         {$IFDEF CHECK_INVIS}
//          c := TTLGContact(contactsDB.get(TTLGContact, uid));
          c := TTLGContact(whom);
           if (not c.isOnline)
             or (c.invisibleState = 2) then
             if (c.invisibleState = 0) then
            	begin
                c.invisibleState := 2;
                roasterLib.update(c);
                roasterLib.updateHiddenNodes;
                redraw(c);
//				      if not thisProto.imVisibleTo(c) then
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
    i := Account.acks.findID(thisProto.eventReqId);
    if i>=0 then
    	with Account.acks.getAt(i) do
       begin
        if kind = OE_AUTOMSGREQ then
        	begin
         {$IFDEF CHECK_INVIS_OLD}
//          c:=contactsDB.get(uin);
          c := whom;
          if not c.isOnline then
          	if thisProto.eventInt=9 then
            	begin
				      if not thisProto.imVisibleTo(c) then
				      	addTempVisibleFor(5, c);
			      	msgDlg(getTranslation('%s - %s is actually online but invisible to you',[c.uin2Show,c.displayed]), False, mtInformation);
              end
            else
	          	msgDlg(getTranslation('%s - %s is actually offline',[c.uin2Show,c.displayed]), False, mtInformation)
          else
			      if not thisProto.imVisibleTo(c) then
            	addTempVisibleFor(5, c);
         {$ENDIF}
           if not (thisProto.eventInt = 4) then
             Account.acks.Delete(i);
          end;
        if kind = OE_MSG then
        	begin
         {$IFDEF CHECK_INVIS}
//          c := TTLGContact(contactsDB.get(uid));
          c := TTLGContact(whom);
          if (not c.isOnline)
             or (c.invisibleState = 2) then
          begin
//          	if thisProto.eventInt=$0E then
          	if (thisProto.eventInt = 9) then
             if (c.invisibleState = 0) then
            	begin
                c.invisibleState := 2;
//                c.status := SC_ONLINE;
                roasterLib.update(c);
                roasterLib.updateHiddenNodes;
                redraw(c);
//				      if not thisProto.imVisibleTo(c) then
//				      	addTempVisibleFor(5, c);
//			      	msgDlg(getTranslation('%s - %s is actually online but invisible to you',[c.uin2Show,c.displayed]), mtInformation);
              end
             else
            else
          	if (thisProto.eventInt = 4)and(thisProto.eventFlags = IF_urgent)and
                ( info = 'Inv2') then
//             if (c.invisibleState = 0) then
            	begin
                c.invisibleState := 2;
//                c.status := SC_ONLINE;
                roasterLib.update(c);
                roasterLib.updateHiddenNodes;
                redraw(c);
//				      if not thisProto.imVisibleTo(c) then
//				      	addTempVisibleFor(5, c);
//			      	msgDlg(getTranslation('%s - %s is actually online but invisible to you',[c.uin2Show,c.displayed]), mtInformation);
              end
//             else
            else
             if ( info = 'Inv') then

              begin
                c.status := SC_OFFLINE;
                c.invisibleState := 0;
//                c.status := SC_OFFLINE;
                roasterLib.update(c);
                roasterLib.updateHiddenNodes;
                redraw(c);
              end
             else
              if (info = 'MSG') then
              begin
                TempHist := chatFrm.ChatBox.GetHistory(c.UID);
                if not (TempHist = nil) then
                begin
                 TempEv := TempHist.getByMsgID(thisProto.eventMsgID);
                 if not (TempEv = nil) then
                 begin
                   TempEv.flags := TempEv.flags OR IF_not_delivered;// IF_MSG_OK;
                   chatFrm.ChatBox.updateMsgStatus(TempEv);
                   FreeAndNil(TempEv);
                 end;
                end;
              end;
          end
          else
          {$ENDIF}
              if (info = 'MSG') then
              begin
                 TempCh := chatFrm.chats.byContact(c);
                 if TempCh <> NIL then
                  begin
        //            TempCh.historyBox.history.
                     TempEv := TempCh.historyBox.history.getByID(thisProto.eventReqID);
                     if TempEv <> NIL then
                      begin
                       TempEv.flags := TempEv.flags OR IF_not_delivered;// IF_MSG_OK;
                       TempCh.repaint();
                      end;
//                     TempEv := NIL;
                  end;
              end;
//			      if not thisProto.imVisibleTo(c) then
//            	addTempVisibleFor(5, c);

            // Do not remove and wait for received ack if sending to offline client,
            // because sometimes it's not even an error when multiple clients are connected
            if not (thisProto.eventInt = 4) then
              Account.acks.Delete(i);
          end;
       end;
    end;
  IE_Missed_MSG:
    begin
      sU := getTranslation('You have missed %d messages from %s!', [thisProto.eventMsgID, c.displayed]);
      sU := sU + CRLF + getTranslation('Reason') + ': ' + getTranslation(ICQ_missed_msgs[thisProto.eventInt]);
    	msgDlg(sU, False, mtWarning);
    end;
  IE_sendingAutomsg:
    begin
      vS := getAutomsgFor(c);
//      if vS <> '' then
      thisProto.eventMsgA := vS;
      plugins.castEv(PE_AUTOMSG_SENT, cuid, thisProto.eventMsgA);
    end;
  IE_sendingXStatus:
    begin
//    thisProto.eventName := AnsiToUtf8(getTranslation(ExtStsStrings[thisProto.curXStatus][0]));
     thisProto.eventMsgA := UTF(getXStatusMsgFor(c));
//     sa := StrToUtf8(thisProto.eventMsg);
     Vs := plugins.castEv( PE_XSTATUSMSG_SENDING, cuid, thisProto.eventInt,
                           UTF(thisProto.eventNameA), thisProto.eventMsgA);
//      vS := plugins.castEv( PE_MSG_GOT, cuid, e.flags, e.when, thisProto.eventMsg);
      if not isAbort(vS) then
       begin
         if (vS>'') then
          if(ord(vS[1])=PM_DATA) then
          try
           i := _int_at(vS, 2);
//           thisProto.eventName := UnUTF(_istring_at(vS, 2));
           thisProto.eventNameA := _istring_at(vS, 2);  // In UTF8
           if length(vS)>2+4+ i then
//            thisProto.eventMsg := UnUTF(_istring_at(vS, 2+4+ i))
            thisProto.eventMsgA := _istring_at(vS, 2+4 + i) // In UTF8
//           else
//            oe.info := send_msg;
          except
            thisProto.eventNameA := '';
            thisProto.eventMsgA := UTF(getXStatusMsgFor(c));
          end
          else
           if (ord(vS[1])=PM_ABORT) then
             begin thisProto.eventMsgA := ''; thisProto.eventNameA := ''; end
            else begin end;
//         else
//           send_msg := oe.info;
//        if behave(e, EK_msg, thisProto.eventMsg) then
//          NILifNIL(c);
       end
      else
       begin thisProto.eventMsgA := ''; thisProto.eventNameA := ''; end
    end;
  IE_automsgreq:
    if not isAbort(plugins.castEv(PE_AUTOMSG_REQ_GOT, cuid)) then
    begin
//    	if warnVisibilityExploit and not thisProto.imVisibleTo(c) then
//      	msgDlg(getTranslation('%s - %s is using visibility exploit to check your online presence',[c.uin2Show,c.displayed]), False, mtWarning);
      behave(e, EK_automsgreq);
    end;
  IE_ack:
    begin
      i:= Account.acks.findID(thisProto.eventReqId);
      if i >= 0 then
      begin
        sU := UnUTF(thisProto.eventMsgA);
        if Account.acks.getAt(i).kind = OE_AUTOMSGREQ then
        begin
          if thisProto.eventAccept <> AC_ok then
            c.lastAccept:=thisProto.eventAccept;

          pTCE(c.data).lastAutoMsg := sU;
          plugins.castEv(PE_AUTOMSG_GOT, cuid, sU);
          behave(e, EK_automsg);
        end
          else
        if Account.acks.getAt(i).kind = OE_msg then
        begin
         TempCh := chatFrm.chats.byContact(c);
         if TempCh <> NIL then
          begin
//            TempCh.historyBox.history.
             TempEv := TempCh.historyBox.history.getByID(thisProto.eventReqID);
             if TempEv <> NIL then
              TempEv.flags := TempEv.flags OR IF_delivered;// IF_MSG_OK;
//             TempEv := NIL;
           TempCh.repaint();
          end;
        end
          else
        begin
          b := (c.lastAccept <> thisProto.eventAccept) or (TCE(c.data^).lastAutoMsg <> sU);
          case thisProto.eventAccept of
            AC_away:
              if b then
              begin
                plugins.castEv( PE_AUTOMSG_GOT, cuid, sU);
                behave(e, EK_automsg);
              end;
            AC_denied:
            begin
{             if messageDlg(getTranslation('User only accept urgent messages.\nSend urgent?\n\nAuto-message:\n%s',
              [s]), mtConfirmation, [mbYes,mbNo], 0) = mrYes then
              begin
                with acks.getAt(i) do flags:=flags or IF_urgent;
                sendWIMmsg(acks.getAt(i));
              end;}
            end;
          end;
          pTCE(c.data).lastPriority:= Account.acks.getAt(i).flags and (IF_urgent+IF_noblink);
          pTCE(c.data).lastAutoMsg := sU;//thisProto.eventMsg;
          c.lastAccept  := thisProto.eventAccept;
        end;
        Account.acks.delete(i);
      end;
    end;
  IE_authDenied:
    begin
      case thisProto.eventAccept of
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
  IE_toofast: msgDlg('You''re sending too fast!', True, mtWarning);
  IE_pause: msgDlg('You''ll be disconnected soon because server was paused.', True, mtWarning);
  IE_resume: msgDlg('Server was resumed, you may not be disconnected after all.', True, mtWarning);
{  IE_pwdChanged:
    begin
//    saveCFG;
    if not dontSavePwd then
      saveCfgDelayed := True;
    msgDlg('Your password has been changed.', True, mtInformation);
    end;}
  IE_myinfoACK: msgDlg('Your information has been saved.', True, mtInformation);
  IE_wpEnd:
{    if (wpFrm<>NIL) then
      begin
       if thisProto.eventInt > 0 then
       begin
        wpFrm.N_Allresults := thisProto.eventInt;
        wpFrm.updateNumResults;
//        msgDlg(getTranslation('End of search\nThere are %d more results but WIM server shows only first ones, sorry.', [thisProto.eventInt]),mtInformation);
       end;
       wpFrm.stopSearch;
      end; };
  IE_userSimpleInfo:
     begin
{      if (thisProto.eventWP.uin = IntToStr(UINToUpdate)) and checkupdate.enabled then
       begin
        checkupdate.autochecking := True;
        c.nick  := thisProto.eventwp.nick;
        c.first := thisProto.eventwp.first;
        c.last  := thisProto.eventwp.last;
//        CheckUpdates(c);
       end;}
     end;
  IE_fileDenied: msgDlg('File transfer denied', True, mtWarning);
//  IE_wpResult: if (wpFrm <> nil) then wpFrm.addResult(thisProto.eventWP);
  IE_serverSent: LoggaTLGPkt(thisProto.eventNameA, WL_rcvd_text, thisProto.eventMsgA);
  IE_serverSentU:  LoggaTLGPkt(thisProto.eventNameA, WL_rcvd_text8, UTF8Encode(thisProto.eventString));
  IE_serverGot: LoggaTLGPkt(thisProto.eventNameA, WL_sent_text, thisProto.eventMsgA);
  IE_serverGotU: LoggaTLGPkt(thisProto.eventNameA, WL_sent_text8, UTF8Encode(thisProto.eventString));
  IE_serverSentJ:  LoggaTLGPkt(thisProto.eventNameA, WL_rcvd_json8, thisProto.eventMsgA);
  IE_serverGotJ: LoggaTLGPkt(thisProto.eventNameA, WL_sent_json8, thisProto.eventMsgA);
  IE_connecting:
    begin
     LoggaTLGPkt('', WL_connecting, thisProto.eventAddress);
     DisableSounds := False;
     SetProgBar(thisProto, 1/progLogonTotal);
    end;
  IE_loggin: SetProgBar(thisProto, 2/progLogonTotal);
  IE_connected: SetProgBar(thisProto, 3/progLogonTotal);
  IE_redirecting:
    begin
     LoggaTLGPkt('', WL_connecting, thisProto.eventAddress);
     SetProgBar(thisProto, 4/progLogonTotal);
    end;
  IE_redirected: SetProgBar(thisProto, 5/progLogonTotal);
  IE_almostonline: SetProgBar(thisProto, 6/progLogonTotal);
  IE_visibilityChanged:
    if Assigned(c) then
    begin
      plugins.castEv(PE_VISIBILITY_CHANGED, cuid);
      roasterLib.Redraw(c)
    end
      else
    begin
      plugins.castEv(PE_VISIBILITY_CHANGED, '');
      rosterRepaintDelayed := TRUE;
     end;
  IE_tos:
     if data <> NIL then
      begin
       var
         fn, ln, tos, s: String;
         var v: TJSONValue;
         var ent: TJSONArray;
         if data.TryGetValue('@type', s) and (s = 'formattedText') then
          begin
           data.TryGetValue('text', tos);
           if not data.TryGetValue('entities', ent) or not Assigned(ent) or (ent.Count = 0)  then
             tos := Format(tos, []);
          end;

       if acceptTOS(fn, ln, getTranslation('Accept terms and enter user info'), tos) then
         thisProto.acceptTOS(fn, ln);
      end;
  IE_tos_update:
     if data <> NIL then
      begin
       var
         fn, ln, tos, s, tosId: String;
       var tosJ, v: TJSONValue;
         var ent: TJSONArray;
         if data.TryGetValue('@type', s) and (s = 'updateTermsOfService') then
           begin
             data.TryGetValue('terms_of_service_id', tosId);
             if data.TryGetValue('terms_of_service', v) and Assigned(v) then
               v.TryGetValue('text', tosJ)
           end;
         if tosId > '' then
         if tosJ.TryGetValue('@type', s) and (s = 'formattedText') then
          begin
           tosJ.TryGetValue('text', tos);
           if not tosJ.TryGetValue('entities', ent) or not Assigned(ent) or (ent.Count = 0)  then
             tos := Format(tos, []);
          end;

       if acceptTOS(getTranslation('Accept terms'), tos) then
         thisProto.acceptTOS(tosId);
      end;
  IE_error:
     if data <> NIL then
       begin
         var err: String := '';
         var errM: String := '';
         var v: TJSONValue;
         if data.TryGetValue('code', v) then
           err := v.ToString;
         if data.TryGetValue('message', v) then
           errM := v.ToString;
         if (err <> '') or (errm <> '') then
          msgDlg(err + ' - ' + errm, False, mtError);

       end
      else
    if thisProto.eventError = EC_Login_Seq_Failed then
    begin
      setProgBar(thisProto, 0);
      msgDlg(getTranslation(ICQError2Str[thisProto.eventError], [thisProto.eventMsgA]), False, mtError)
    end else if thisProto.eventError = EC_MalformedMsg then
      msgDlg(getTranslation(ICQError2Str[thisProto.eventError], [thisProto.eventMsgA]), False, mtError)
    else if thisProto.eventError = EC_FailedDecrypt then
      msgDlg(GetTranslation(icqerror2str[thisProto.eventError], [thisProto.eventMsgA]), False, mtError)
    else if thisProto.eventError = EC_AddContact_Error then
    begin
      DlgType := mtError;
      case thisProto.eventInt of
        1: thisProto.eventMsgA := 'Server DB error';
        3: begin thisProto.eventMsgA := 'Contact was already in your CL, fetching it again'; DlgType := mtInformation; end;
        13: thisProto.eventMsgA := 'Request was not executed';
        17: thisProto.eventMsgA := 'Too many contacts in your CL';
        26: thisProto.eventMsgA := 'Operation timed out on server';
      end;
      msgDlg(getTranslation(ICQError2Str[thisProto.eventError], [getTranslation(thisProto.eventMsgA)]), False, DlgType);
    end else if thisProto.eventError = EC_badContact then
      loggaEvtS(format('ERROR: bad contact: %s',[cuid]))
    else
      begin
        SetProgBar(thisProto, 0);
        theme.PlaySound(Str_Error); //sounds.onError);
        if (thisProto.eventError in [
          EC_badUIN,
          EC_badPwd,
          EC_proxy_badPwd,
//          EC_anotherLogin,
          EC_invalidFlap,
          EC_rateExceeded,
          EC_missingLogin
        ]) then
          StayConnected := False;
        if thisProto.eventError = EC_missingLogin then
          if thisProto.enterPWD then doConnect
          else
        else
          if showDisconnectedDlg or not (thisProto.eventError in [
            EC_rateExceeded,
            EC_cantConnect,
            EC_socket,
            EC_serverDisconnected,
            EC_loginDelay,
            EC_invalidFlap
          ]) then
//            if thisProto.eventError = EC_proxy_unk then
//               msgDlg(___('WIMerror '+WIMerror2str[thisProto.eventError], [thisProto.eventMsg]), mtError)
//              msgDlg(getTranslation(WIMerror2str[thisProto.eventError], [thisProto.eventMsg]), mtError)
//            else
              msgDlg(getTranslation(ICQError2Str[thisProto.eventError], [thisProto.eventInt, thisProto.eventMsgA]), False, mtError);
        if thisProto.eventError = EC_badPwd then
         begin
          sU := thisProto.pwd;
          thisProto.pwd := '';
          if thisProto.enterPWD then
           begin
            thisProto.Disconnect;
            DoConnect;
           end
           else
            thisProto.pwd := sU;
         end
        else if thisProto.eventError = EC_other then
        begin
          case TICQAuthError(thisProto.eventInt) of
            EAC_Not_Enough_Data: Temp := 'Failed to get all the data required for starting a new session';
            EAC_Unknown: Temp := 'Unknown error';
            EAC_Wrong_Login: Temp := 'Wrong login';
            EAC_Invalid_Request: Temp := 'Invalid request';
            EAC_Auth_Required: Temp := 'Authorization required';
            EAC_Req_Timeout: Temp := 'Request timeout';
            EAC_Wrong_DevKey: Temp := 'Wrong DevId key';
            EAC_Missing_Param: Temp := 'Missing required parameter';
            EAC_Param_Error: Temp := 'Parameter error';
            EAC_Rate_Limit: Temp := 'Request was rate limited';
          end;
          Temp := GetTranslation(Temp);
          if not (thisProto.eventMsgA = '') then
            Temp := Temp + #13#10 + String(thisProto.eventMsgA);
          msgDlg(Temp, False, mtError)
        end;
      end;
  IE_statuschanged:
    begin
      if not Assigned(c) then //or thisProto.isMyAcc(c) then
      begin
        plugins.castEv(PE_STATUS_CHANGED, cuid, thisProto.GetStatus, byte(thisProto.eventOldStatus), thisProto.IsInvisible, thisProto.eventOldInvisible);
        UpdateViewInfo(thisProto.GetMyInfo);
        if thisProto.GetStatus <> Byte(SC_OFFLINE) then
          LastStatus := thisProto.GetStatus;
        RnQmain.UpdateStatusGlyphs;
        roasterLib.UpdateHiddenNodes;
        roasterLib.Redraw;
      end
        else
      begin
        plugins.castEv(PE_STATUS_CHANGED, cuid, Byte(c.status), byte(thisProto.eventOldStatus), c.isInvisible, thisProto.eventOldInvisible);
        UpdateViewInfo(c);
        if c.IsInRoster then
        begin
          if (c.status = SC_OFFLINE) then
            c.SetOffline;
          roasterLib.update(c);//  Что-то нада убрать тут!!!!
          roasterLib.updateHiddenNodes;
          redraw(c);
          e.fBin := int2str(integer(c.status))+ AnsiChar(c.isInvisible) + AnsiChar(c.xStatus);
          if //(c.xStatus > 0) or
           (c.xStatusDesc > '') then
            begin
              e.txt   := c.xStatusDesc;
              e.flags := e.flags or IF_XTended_EVENT;
            end;

          if oncomingOnAway
          and (thisProto.eventOldStatus in [SC_AWAY, SC_NA])
          and not (c.status in [SC_AWAY, SC_NA])
          and (noOncomingCounter = 0) then
            behave(e, EK_oncoming)
          else
            behave(e, EK_statuschange);
        end;

        if autoRequestXsts
           and (c.capabilitiesXTraz <> [])
           and thisProto.ImVisibleTo(c)
           {and Assigned(reqXStatusQ)} then
          //reqXStatusQ.Add(c);
      end;
      AutosizeDelayed := True;
//      if Assigned(chatFrm) then
//        chatFrm.RefreshTaskbarButtons;
    end;
  {$IFDEF RNQ_AVATARS}
  IE_avatar_changed:
    if thisProto.AvatarsSupport then
    begin
      if thisProto.AvatarsAutoGet then
        reqAvatarsQ.add(c)
      else if c.icon.ToShow = IS_AVATAR then
        ClearAvatar(TRnQContact(c));
//      if ShowAvt then
      if TO_SHOW_ICON[CNT_ICON_AVT] then
        redraw(c);
     end;
  {$ENDIF RNQ_AVATARS}
(*  IE_ackXStatus:
    begin
      c.xStatusStr := excludeTrailingCRLF(UnUTF(thisProto.eventMsgA));
      c.xStatusDesc := excludeTrailingCRLF(unUTF(thisProto.eventData));
      if c.xStatus > 0 then
        begin
          e.fBin := AnsiChar(c.xStatus) + _istring(StrToUTF8(c.xStatusStr));
        end
       else
        e.fBin := AnsiChar(#00) + _istring(StrToUTF8(c.xStatusStr));
      e.txt   := c.xStatusDesc;
      behave(e, EK_XstatusMsg);
      updateViewInfo(c);

    end;
*)
  IE_XStatusReq:
    if not isAbort(plugins.castEv( PE_XSTATUS_REQ_GOT, cuid)) then
    begin
// 	    if warnVisibilityExploit and not thisProto.imVisibleTo(c) then
//    	  msgDlg(getTranslation('%s - %s is using visibility exploit to check your online presence',[c.uin2Show,c.displayed]), False, mtWarning);
      behave(e, EK_Xstatusreq);
    end;
  IE_online,
  IE_offline:
    begin
      outboxCount := -1;
      b := false;
//      b := myStatus <> byte(SC_OFFLINE);
//      myStatus:= thisProto.getStatus;
      b := b or (thisProto.getStatus <> byte(SC_OFFLINE));
      b := b or (ev = IE_offline);
      setProgBar(thisProto, 0);
      if ev = IE_online then
      begin
        //  вызов балуна
        {$IFDEF Use_Baloons}
        statusIcon.showballoon(2000, getTranslation('Online'), Application.MainForm.Caption, bitInfo{, 'status.' + status2Img[thisProto.getStatus]});
        {$ENDIF Use_Baloons}
        checkupdate.checking := False;
        outboxCount := timeBetweenMsgs;
        StayConnected := AutoReconnect;
        thisProto.CleanDisconnect := False;
        plugins.castEv(PE_CONNECTED);
        toReconnectTime := 50;
      end
        else
      begin
        incDBTimer;
        if clearPwdOnDSNCT and dontSavePwd then
          if Assigned(thisProto) and thisProto.isOffline then
            thisProto.pwd := '';
        with TRnQProtocol.contactsDB.clone do
        begin
          ForEach(procedure(cnt: TRnQContact)
          begin
            TTLGContact(cnt).OfflineClear;
            TTLGContact(cnt).Status := SC_UNK;
          end);
          Free;
        end;
        Account.acks.Clear;
        plugins.castEv(PE_DISCONNECTED);
      end;
      noOncomingCounter := 150;

      if Assigned(chatFrm) then
      with chatFrm do
        if thisChat <> NIL then
          userChanged(thisChat.who);
      TThread.Synchronize(nil, procedure
        begin
          RnQmain.UpdateStatusGlyphs;
          if b then
            roasterLib.rebuild;
    //      UpdatePrefsFrm
        end);
    end;
  IE_numOfContactsChanged:
     begin
       contactsPnlStr := IntToStr(thisProto.eventInt);
     end;
  IE_userinfo, IE_userinfoCP:
    begin
      plugins.castEv(PE_USERINFO_CHANGED, cuid);
      UpdateViewInfo(c);
      if thisProto.IsMyAcc(c) then
        RnQmain.UpdateCaption
      else
        roasterLib.redraw(c);
      TipsUpdateByCnt(c);
//      if checkupdate.checking and (cuid = UINToUpdate) then
//         CheckUpdates(c);
//    roasterLib.updateHiddenNodes;
      redraw(c);
      dbUpdateDelayed := True;
    end;
  IE_incoming:
    begin
      {$IFDEF CHECK_INVIS}
      c.invisibleState := 0;
      {$ENDIF}
      plugins.castEv(PE_STATUS_CHANGED, cuid, byte(c.status), byte(thisProto.eventOldStatus), c.isInvisible, False);
      roasterLib.update(c);
      redraw(c);
      roasterLib.updateHiddenNodes;
      TCE(c.data^).lastOncoming := thisProto.eventTime;
      updateViewInfo(c);
      e.fBin :=int2str(integer(c.status))+AnsiChar(c.isInvisible)+AnsiChar(c.xStatus);
      if noOncomingCounter = 0 then
        behave(e, EK_ONCOMING)
      else if noOncomingCounter < 50 then
      begin
        inc(noOncomingCounter,10);
        boundInt(noOncomingCounter, 0,50);
      end;
      if autoRequestXsts
         and (c.capabilitiesXTraz <> [])
         and thisProto.imVisibleTo(c)
         {and Assigned(reqXStatusQ)} then
      //reqXStatusQ.Add(c);
      autosizeDelayed := True;
    end;
  IE_outgoing:
    begin
      plugins.castEv(PE_STATUS_CHANGED, cuid, byte(c.status), byte(thisProto.eventOldStatus), False, thisProto.eventOldInvisible);
      if roasterLib.focusedContact = c then
        roasterLib.focusPrevious;
      c.OfflineClear;

      roasterLib.update(c);
      roasterLib.updateHiddenNodes;
      redraw(c);
      updateViewInfo(c);
      behave(e, EK_offgoing);
      AutosizeDelayed := True;
    end;
  IE_contactupdate:
    begin
      roasterLib.update(c);
      roasterLib.updateHiddenNodes;
      redraw(c);
      updateViewInfo(c);
//      if Assigned(chatFrm) then
//        chatFrm.RefreshTaskbarButtons;
//      autosizeDelayed := True;
    end;
  IE_contactSelfDeleted:
    begin
      msgDlg(getTranslation('Contact %s [%s] Deleted himself from your Contact List', [c.displayed, c.uin2Show]),
              false, mtInformation, c.UID);
      roasterLib.update(c);
      roasterLib.updateHiddenNodes;
      redraw(c);
      updateViewInfo(c);
//      autosizeDelayed:=TRUE;
    end;
  IE_redraw:
     roasterLib.redraw(c);
  IE_typing:
    if not filterRefuse(c) then
    begin
      roasterLib.Redraw(c);
      if thisProto.eventInt = MTN_CLOSED then
      begin
        // Закрыли чат
      end;
      if thisProto.eventAddress <> '' then
        e.otherpeer := thisProto.geTTLGContact(thisProto.eventAddress);

      if c.typing.bIsTyping then
        behave(e, EK_typingBeg)
      else
        behave(e, EK_typingFin);
    end;
  IE_contacts:
    if not e.cl.empty
    and not isAbort(plugins.castEv( PE_CONTACTS_GOT,cuid,e.flags,e.when,e.cl )) then
     begin
       e.fBin := e.cl.tostring;
       e.txt := '';
       if behave(e, EK_contacts) then
         NILifNIL(c);
     end;
  IE_authReq:
    if not filterRefuse(c, '',IF_auth) and not isAbort(plugins.castEv( PE_AUTHREQ_GOT, cuid, e.flags, e.when, thisProto.eventMsgA ))
    and behave(e, EK_authReq) then
      begin
//        roasterLib.updateHiddenNodes;
        redraw(c);
        NILifNIL(c);
      end;
  IE_addedYou:
    if not isAbort(plugins.castEv( PE_ADDEDYOU_GOT, cuid, e.flags, e.when ))
    and behave(e, EK_addedyou) then
      begin
//        roasterLib.updateHiddenNodes;
        redraw(c);
        NILifNIL(c);
      end;
  IE_url:
  	if (Length(thisProto.eventAddress)=0) then
     begin
//      if warnVisibilityExploit and not thisProto.imVisibleTo(c) then
//      	msgDlg(getTranslation('%s - %s is using visibility exploit to check your online presence',[c.uin2Show,c.displayed]), False, mtWarning, cUID)
     end
    else
     begin
      sU := UnUTF(thisProto.eventMsgA);
      if not isAbort(plugins.castEv( PE_URL_GOT, cuid, e.flags, e.when, thisProto.eventAddress, sU )) then
        begin
         e.fBin := '';
         e.txt := thisProto.eventAddress+#10+sU;
         if behave(e, EK_url) then
           NILifNIL(c);
        end;
     end;
  IE_buzz:
     begin
       if behave(e, EK_buzz) then
         NILifNIL(c);
     end;
  IE_msg, IE_MultiChat:
     begin
       if (ev = IE_MultiChat) and (thisProto.eventAddress > '') then
         e.who := thisProto.geTTLGContact(thisProto.eventAddress);

       begin
//         Temp := UnUTF(thisProto.eventMsgA);
         rS := UTF8Encode(thisProto.eventString);
         e.flags := e.flags and not IF_CODEPAGE_MASK; // Clear Encodings flags
//         e.flags := e.flags and not IF_Bin; // Clear bin flag
         e.flags := e.flags or IF_UTF8_TEXT;
         vS := plugins.castEv(PE_MSG_GOT, cuid, e.flags, e.when, rS);
{
       end else
       begin
        Temp := thisProto.eventData;
        vS := plugins.castEv(PE_MSG_GOT, cuid, e.flags, e.when, thisProto.eventData);
}
       end;

       if not isAbort(vS) then
       begin
         if (vS > '') and (ord(vS[1]) = PM_DATA) then
         begin
           rS := _istring_at(vS, 2);
           e.flags := e.flags and not IF_CODEPAGE_MASK; // Clear Encodings flags
           e.flags := e.flags and not IF_Bin; // Clear bin flag
         end;

        if e.flags and IF_CODEPAGE_MASK = 0 then
         if IsUTF8String(rS) then
          e.flags := e.flags or IF_UTF8_TEXT;
        e.ParseMsgStr(rS);

//         if Length(thisProto.eventBinData) > 0 then
//           e.setImgBin(thisProto.eventBinData);
         if behave(e, EK_msg) then
           NILifNIL(c);
       end;
     end;
  IE_gcard:
    if not isAbort(plugins.castEv(PE_GCARD_GOT, cuid, e.flags, e.when, thisProto.eventAddress)) then
    begin
         e.fBin := '';
         e.txt := thisProto.eventAddress;
       if behave(e, EK_gcard) then
         NILifNIL(c);
    end;
  IE_email:
    begin
      sU := UnUTF(thisProto.eventMsgA);
      if not filterRefuse(NIL, sU, IF_PAGER) and not isAbort(plugins.castEv(PE_EMAILEXP_GOT, e.when, thisProto.eventNameA, thisProto.eventAddress, thisProto.eventMsgA)) then
      msgDlg('___EMAIL EXPRESS___'+
         #13+ UnUTF(thisProto.eventNameA)+' ('+thisProto.eventAddress+')'+
         #13+ sU, False, mtInformation);
    end;
  IE_webpager:
    begin
      sU := UnUTF(thisProto.eventMsgA);
      if not filterRefuse(NIL, sU, IF_PAGER) and not isAbort(plugins.castEv( PE_WEBPAGER_GOT, e.when, thisProto.eventNameA, thisProto.eventAddress, thisProto.eventMsgA )) then
      msgDlg('___WEB PAGER___'+
         #13+ UnUTF(thisProto.eventNameA)+' ('+ thisProto.eventAddress+')'+
         #13+ sU, False, mtInformation);
    end;
  IE_fromMirabilis:
    begin
      sU := UnUTF(thisProto.eventMsgA);
      if not filterRefuse(NIL, sU) and not isAbort(plugins.castEv( PE_FROM_MIRABILIS, e.when, thisProto.eventNameA, thisProto.eventAddress, thisProto.eventMsgA )) then
      msgDlg('___FROM MIRBILIS___'+
         #13+ UnUTF(thisProto.eventNameA)+' ('+thisProto.eventAddress+')'+
         #13+ sU, False, mtInformation);
    end;
  IE_serverHistoryReady:
    begin
//      TempCh := chatFrm.chats.byContact(c);
//      if TempCh <> nil then
//        TempCh.historyBox.ShowServerHistoryNotif;
    end;
  IE_serverHistory:
    begin
      onGetServerHistory(thisProto.eventContact, thisProto.eventJSON);
//      TempCh := chatFrm.chats.byContact(c);
//      if TempCh <> nil then
//        TempCh.historyBox.ShowServerHistoryNotif;
    end;
  IE_UpdatePrefsFrm:
    begin
//      if Assigned(PrefSheetFrm) then
//        PrefSheetFrm.Reset;
    end;
  end;
 if thisProto.eventFlags and IF_offline > 0 then
  if ev in [IE_msg, IE_MultiChat, IE_url,IE_addedYou,IE_authReq,IE_contacts] then
  // we already played a sound for the first offline message, let's make no other sound
    disableSounds := TRUE;
 if Assigned(e) then
  e.free;
 if Assigned(statusIcon) then
   statusIcon.update;
end; // WIMEvent

function getRnQVerFor(c:TRnQContact):Integer;
var
  s: RawByteString;
  capa: RawByteString;
  i:integer;
begin
  result:=0;
  if c=NIL then exit;
  case TTLGContact(c).lastupdate_dw of
    RnQclientID:
      Result := TTLGContact(c).lastinfoupdate_dw and ($FFFFFF); // Rapid D
  end;
  if result > 0 then exit;

  s:= TTLGContact(c).extracapabilities;
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
  if Assigned(Account.AccProto) and (Account.AccProto is TTLGSession) then
    for cnt in Account.AccProto.readList(LT_ROSTER) do
      Account.AccProto.getClientPicAndDesc4(cnt, cnt.ClientPic, cnt.ClientDesc)
end;


end.
