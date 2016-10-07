{
This file is part of R&Q.
Under same license
}
unit ICQ.RESTapi;
{$I RnQConfig.inc}
{$I NoRTTI.inc}

interface
 uses
   Windows, Forms, Classes, Graphics, SysUtils, ICQv9,
   RnQProtocol;


  procedure ICQREST_loginAndCreateSession(const pAcc, pPwd: String; var pSession: TSessionParams);
  procedure ICQREST_refreshSessionSecret(const pAcc, pPwd: String; var pSession: TSessionParams);
  procedure ICQREST_openICQURL(const pURL: String);
  procedure ICQREST_checkServerHistory(ICQ: TicqSession; uid: TUID);
  procedure ICQREST_getServerHistory(ICQ: TicqSession; uid: TUID);
  procedure ICQREST_checkOrGetServerHistory(ICQ: TicqSession; uid: TUID; retrieve: Boolean = False);

implementation
uses
  DateUtils, ansistrings, AnsiClasses,
  math, Types, StrUtils, System.Threading, NetEncoding,
  RDGlobal, RnQBinUtils, RDFileUtil, RDUtils, Base64,
  RnQGlobal, JSON, cHash,
  RnQNet, RQUtil, RnQLangs,
  Protocol_ICQ,
  menusUnit,
  UtilLib, roasterlib, mainDlg, GlobalLib, events,
  ICQConsts, ICQContacts, RnQStrings, RnQDialogs, groupsLib;


procedure ICQREST_openICQURL(const pURL: String);
var
  hash, query, baseUrl, redirectUrl, unixTime, sToken: String;
  hashStr, sSecret: RawByteString;
  session: TSessionParams;
  digest: T256BitDigest;
  icq: TICQSession;
begin
  icq := TICQSession(Account.AccProto.getContact(Account.AccProto.ProtoElem.MyAccNum).fProto);
  session := icq.getSession;

  if (icq.getPwdOnly = '') or ((session.secret = '') and (session.secretenc64 = '')) or (session.token = '') then
  begin
    openURL(pURL);
    Exit;
  end;

  baseUrl := 'http://www.icq.com/karma_api/karma_client2web_login.php';
  sToken := TNetEncoding.url.Encode(session.token);
  if session.secretenc64 = '' then
  begin
    digest := CalcHMAC_SHA256(StrToUTF8(icq.getPwdOnly), StrToUTF8(session.secret));
    sSecret := Base64EncodeString(SHA256DigestToStrA(digest));
  end else
    sSecret := session.secretenc64;
  redirectUrl := TNetEncoding.url.Encode(pURL);
  unixTime := IntToStr(DateTimeToUnix(Now, False));

  query := 'a=' + sToken + '&d=' + redirectUrl + '&k=' + session.devid + '&owner=' + Account.AccProto.ProtoElem.MyAccNum + '&ts=' + unixTime;

  hash := 'GET&' + TNetEncoding.url.Encode(baseUrl) + '&' + TNetEncoding.url.Encode(query);
  digest := CalcHMAC_SHA256(sSecret, StrToUTF8(hash));
  hashStr := Base64EncodeString(SHA256DigestToStrA(digest));

  openURL(StrToUTF8(baseUrl + '?' + query + '&sig_sha256=' + TNetEncoding.url.Encode(hashStr)));
end;

procedure ICQREST_checkServerHistory(ICQ: TicqSession; uid: TUID);
begin
  ICQREST_checkOrGetServerHistory(ICQ, uid, False);
end;

procedure ICQREST_getServerHistory(ICQ: TicqSession; uid: TUID);
begin
  ICQREST_checkOrGetServerHistory(ICQ, uid, True);
end;

procedure ICQREST_checkOrGetServerHistory(ICQ: TicqSession; uid: TUID; retrieve: Boolean = False);

  function sameTextMsgExists(ev: Thevent; const text: String; kind: Integer): Boolean;
  begin
    Result := not (ev = nil) and (ev.getBodyText = text) and (ev.kind = kind);
  end;

  function sameBinMsgExists(ev: Thevent; bin: TBytes; kind: Integer): Boolean;
  begin
//    Result := not (ev = nil) and (ev.getBodyBin = bin) and (ev.kind = kind);
    Result := false;
  end;

var
  query, params, baseUrl, wid, lastMsgId, fromMsgId: String;
  respStr: RawByteString;
  digest: T256BitDigest;
  fs: TMemoryStream;
  json, msg, text, tmp: TJSONValue;
  results, stickerObj: TJSONObject;
  messages: TJSONArray;
  msgCount, unixTime, code, ind, kind: Integer;
  extsticker: TStringDynArray;
  stickerBin: TBytes;
  time: TDateTime;
  outgoing: Boolean;
  ev, evtmp: Thevent;
  cht, cnt: TRnQContact;
//  hist: Thistory;
begin
(*  if not logpref.writehistory or not ICQ.restAvailable then
    Exit;

  cht := ICQ.getContact(uid);
  msgCount := RDUtils.IfThen(retrieve, MAXINT-1, 1);

  fs := TMemoryStream.Create;
  // CL, myInfo, etc
{
  query := session.fetchURL + '&f=json&r=1&timeout=60000&peek=0';
  loggaICQPkt('[GET] Base fetch', WL_sent_text, query);
  LoadFromURL(query, fs);

  fs.Seek(0, soBeginning);
  SetLength(respStr, fs.Size);
  fs.ReadBuffer(respStr[1], fs.Size);
  fs.Clear;
  loggaICQPkt('[GET] Base fetch', WL_rcvd_text, respStr);

  // Get contact info
  baseUrl := 'https://api.icq.net/presence/get';
  params := '694631417';
  query := 'f=json&aimsid=' + session.aimsid + '&mdir=1&t=' + params;
  loggaICQPkt('[GET] Contact info', WL_sent_text, baseUrl + '?' + query);
  LoadFromURL(baseUrl + '?' + query, fs);

  fs.Seek(0, soBeginning);
  SetLength(respStr, fs.Size);
  fs.ReadBuffer(respStr[1], fs.Size);
  fs.Clear;
  loggaICQPkt('[GET] Contact info', WL_rcvd_text, respStr);
}
  fromMsgId := lastMsgIds.Values[uid];
  if fromMsgId = '' then
    fromMsgId := '0';

  baseUrl := 'https://rapi.icq.net/';
  params := '{"sn": "' + uid + '", "fromMsgId": ' + fromMsgId + ', "count": ' + IntToStr(msgCount) + ', "aimSid": "' + fAimSid + '", "patchVersion": ""}';
  query := '{"method": "getHistory", "reqId": "' + IntToStr(reqId) + '-' + IntToStr(DateTimeToUnix(Now, False) - fHostOffset) + '", "authToken": "' + fRESTToken + '", "clientId": ' + fRESTClientId + ', "params": ' + params + ' }';
  loggaICQPkt('[POST] REST contact history', WL_sent_text, query);
  LoadFromURL(baseUrl, fs, 0, False, True, query, True);
  inc(reqId);

  fs.Seek(0, soBeginning);
  SetLength(respStr, fs.Size);
  fs.ReadBuffer(respStr[1], fs.Size);
  fs.Clear;
  loggaICQPkt('[POST] REST contact history', WL_rcvd_text, respStr);
  FreeAndNil(fs);

  json := TJSONObject.ParseJSONValue(UnUTF(respStr));
  if TryStrToInt(((json as TJSONObject).GetValue('status') as TJSONObject).GetValue('code').Value, code) then
  begin
    if not (code = 20000) then
    begin
      OutputDebugString(PChar('Error code: ' + IntToStr(code)));
      Exit;
    end;

    results := (json as TJSONObject).GetValue('results') as TJSONObject;
    if results = nil then
    begin
      OutputDebugString(PChar('No results'));
      Exit;
    end;

    messages := results.GetValue('messages') as TJSONArray;
    if messages.Count = 0 then
    begin
      OutputDebugString(PChar('No new messages on server'));
      Exit;
    end;

    if not retrieve then
    begin
      eventContact := TICQContact(cht);
      notifyListeners(IE_serverHistoryReady);
      Exit;
    end;

    lastMsgId := results.GetValue('lastMsgId').Value;
    ind := lastMsgIds.IndexOfName(uid);
    if ind < 0 then
      lastMsgIds.AddPair(uid, lastMsgId)
    else
      lastMsgIds[ind] := uid + lastMsgIds.NameValueSeparator + lastMsgId;

    hist := Thistory.Create(LowerCase(uid));

    for msg in messages do
    if not (msg = nil) and (msg is TJSONObject) then
    begin
      unixTime := 0;
      TryStrToInt((msg as TJSONObject).GetValue('time').Value, unixTime);
      time := UnixToDateTime(unixTime, False);

      if not LoadEntireHistory and (CompareDateTime(time, NewHistFirstStart) < 0) then
      begin
        OutputDebugString(PChar('Msg was created before the new history'));
        Continue;
      end;

      evtmp := hist.getByTime(time);

      tmp := (msg as TJSONObject).GetValue('outgoing');
      outgoing := not (tmp = nil) and (tmp.Value = 'true');

      if outgoing then
        cnt := Account.AccProto.getMyInfo
      else
        cnt := cht;

      wid := '';
      tmp := (msg as TJSONObject).GetValue('wid');
      if not (tmp = nil) then
      begin
        wid := tmp.Value;
        if not (wid = '') and not (hist.getByWID(wid) = nil) then
        begin
          OutputDebugString(PChar('Msg is already in history (WID ' + wid + ')'));
          Continue;
        end;
      end;

      text := (msg as TJSONObject).GetValue('text');
      stickerObj := (msg as TJSONObject).GetValue('sticker') as TJSONObject;
      if not (stickerObj = nil) then
      begin
        text := stickerObj.GetValue('id');
        extsticker := SplitString(text.Value, ':');
        if EnableStickers and (length(extsticker) >= 4) then
        begin
          kind := EK_msg;
          stickerBin := getSticker(extsticker[1], extsticker[3]);
          if sameBinMsgExists(hist.getByTime(time), stickerBin, kind) then
          begin
            OutputDebugString(PChar('EK_msg with the same sticker is already in history (WID ' + wid + ')'));
            Continue;
          end;
          ev := Thevent.new(kind, cht, cnt, time, '', [], 0, 0, wid);
          ev.outgoing := outgoing;
          ev.setImgBin(stickerBin);
          history.WriteToHistory(ev);
          Continue;
        end;
      end;

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
            Continue;
          end;
          ev := Thevent.new(kind, cht, cnt, time, '[' + GetTranslation('Message deleted') + ']', [], IF_not_delivered, 0, wid);
          ev.outgoing := outgoing;
          history.WriteToHistory(ev);
          Continue;
        end else if tmp.Value = '27:33000' then
        begin
          kind := EK_AddedYou;
          if sameTextMsgExists(evtmp, text.Value, kind) then
          begin
            OutputDebugString(PChar('EK_AddedYou with the same time is already in history'));
            Continue;
          end;
          ev := Thevent.new(kind, cht, cht, time, '', [], 0);
          ev.outgoing := False;
          history.WriteToHistory(ev);
          Continue;
        end else if tmp.Value = '27:33000' then
        begin
          // Bday event is never saved on disk, ignore
          kind := EK_BirthDay;
          Continue;
        end;
      end;

      if not (text = nil) then
      try
        kind := EK_msg;
        if sameTextMsgExists(hist.getByTime(time), text.Value, kind) then
        begin
          OutputDebugString(PChar('EK_msg with the same time/text is already in history (WID ' + wid + ')'));
          Continue;
        end;
        ev := Thevent.new(kind, cht, cnt, time, text.Value, [], 0, 0, wid);
        ev.outgoing := outgoing;
        history.WriteToHistory(ev);
      except
        OutputDebugString(PChar('Not a json'));
      end else
        OutputDebugString(PChar('Empty msg'));
    end;
    hist.Free;
  end else OutputDebugString(PChar('Cannot parse code!'));
*)
end;

procedure ICQREST_loginAndCreateSession(const pAcc, pPwd: String; var pSession: TSessionParams);
var
  query, hash, baseUrl, unixTime, sToken: String;
  sSecret, hashStr, respStr: RawByteString;
  digest: T256BitDigest;
  fs: TMemoryStream;
  session: RawByteString;
  JSONObject: TJSONObject;
  i: Integer;
begin
  if (pAcc = '') or (pPwd = '') then
    Exit;

  query := 'https://wlogin.icq.com/siteim/icqbar/php/proxy_jsonp.php?sk=0.36625886284782827&username=' + String(pAcc) + '&password=' + pPwd + '&time=' + IntToStr(DateTimeToUnix(Now, False)) + '&remember=1';
  loggaICQPkt('[GET] Login and create session', WL_sent_text, query);
  fs := TMemoryStream.Create;
  LoadFromUrl(query, fs);
  if fs.Size = 0 then
   begin
    fs.Free;
    Exit;
   end;

  SetLength(session, fs.Size);
  if fs.Size>0 then
    fs.ReadBuffer(session[1], fs.Size);
  fs.Clear;

  loggaICQPkt('[GET] Login and create session', WL_rcvd_text, session);

  try
    JSONObject := TJSONObject.ParseJSONValue(session) as TJSONObject;
    if Assigned(JSONObject) then
    if (JSONObject.GetValue('statusCode').Value = '200') or (JSONObject.GetValue('statusCode').Value = '304') then
    begin
      pSession.FetchURL := JSONObject.GetValue('fetchBaseURL').Value;
      pSession.AimSid := JSONObject.GetValue('aimsid').Value;
      pSession.DevId := JSONObject.GetValue('k').Value;
      pSession.SecretEnc64 := JSONObject.GetValue('sessionKey').Value;
      pSession.Token := JSONObject.GetValue('a').Value;
      pSession.TokenTime := StrToInt(JSONObject.GetValue('ts').Value);
      pSession.HostOffset := StrToInt(JSONObject.GetValue('tsDelta').Value);
    end;

    if (pPwd = '') or ((pSession.Secret = '') and (pSession.SecretEnc64 = '')) or (pSession.Token = '') then
    begin
      OutputDebugString(PChar('Not enough data for REST auth'));
      Exit;
    end;

    sToken := TNetEncoding.url.Encode(pSession.Token);
    if pSession.SecretEnc64 = '' then
    begin
      digest := CalcHMAC_SHA256(StrToUTF8(pPwd), StrToUTF8(pSession.Secret));
      sSecret := Base64EncodeString(SHA256DigestToStrA(digest));
    end else
      sSecret := pSession.SecretEnc64;
{
    // Start session (auth is not working)
    baseUrl := 'https://api.icq.net/aim/startSession';
    unixTime := IntToStr(DateTimeToUnix(Now, False) - session.hostOffset);

    query := 'a=' + sToken + '&f=json&k=' + session.devid + '&imf=plain&clientName=SiteIM&buildNumber=410&majorVersion=11&minorVersion=9999&pointVersion=0&clientVersion=5000' +
    '&events=myInfo,presence,buddylist,typing,sentIM,dataIM,userAddedToBuddyList,service,webrtcMsg,mchat,hist,hiddenChat,diff,permitDeny' +
    '&includePresenceFields=aimId,buddyIcon,bigBuddyIcon,displayId,friendly,offlineMsg,state,statusMsg,userType,phoneNumber,cellNumber,smsNumber,workNumber,otherNumber,capabilities,ssl,abPhoneNumber,moodIcon,lastName,abPhones,abContactName,lastseen,mute' +
    '&assertCaps=0946134E4C7F11D18222444553540000' +
    '&interestCaps=8eec67ce70d041009409a7c1602a5c84' +
    '&invisible=false&language=en-us&mobile=0&rawMsg=0&deviceId=dev1&sessionTimeout=86400&inactiveView=offline&activeTimeout=30' +
    '&ts=' + unixtime + '&view=online';

    hash := 'POST&' + TNetEncoding.url.Encode(baseUrl) + '&' + TNetEncoding.url.Encode(query);
    digest := CalcHMAC_SHA256(sSecret, StrToUTF8(hash));
    hashStr := Base64EncodeString(SHA256DigestToStrA(digest));
    query := query + '&sig_sha256=' + TNetEncoding.url.Encode(hashStr);

    fn := 'C:\SpeedProgs\Inet\Chat\RnQ\Build\response.dat';
    LoadFromURL(baseUrl, fn, 0, False, True, query, True);
}
    // REST token
    baseUrl := 'https://rapi.icq.net/genToken';
    unixTime := IntToStr(DateTimeToUnix(Now, False) - pSession.HostOffset);
    query := 'a=' + sToken + '&k=' + pSession.DevId + '&ts=' + unixTime;

    hash := 'POST&' + TNetEncoding.url.Encode(baseUrl) + '&' + TNetEncoding.url.Encode(query);
    digest := CalcHMAC_SHA256(sSecret, StrToUTF8(hash));
    hashStr := Base64EncodeString(SHA256DigestToStrA(digest));
    query := query + '&sig_sha256=' + TNetEncoding.url.Encode(hashStr);
    loggaICQPkt('[POST] REST auth token', WL_sent_text, baseUrl + '?' + query);

    LoadFromURL(baseUrl, fs, 0, False, True, query, True);
    fs.Seek(0, soBeginning);
    SetLength(respStr, fs.Size);
    if fs.Size > 0 then
      fs.ReadBuffer(respStr[1], fs.Size);
    fs.Clear;

    JSONObject := TJSONObject.ParseJSONValue(respStr) as TJSONObject;
    if Assigned(JSONObject) then
    begin
      pSession.RESTToken := (JSONObject.GetValue('results') as TJSONObject).GetValue('authToken').Value;
      loggaICQPkt('[POST] REST auth token', WL_rcvd_text, respStr);
    end else
    begin
      pSession.RESTToken := '';
      loggaICQPkt('[POST] REST auth token', WL_rcvd_text, 'Failed to get auth token');
      Exit;
    end;

    // REST client id
    baseUrl := 'https://rapi.icq.net/';
    unixTime := IntToStr(DateTimeToUnix(Now, False) - pSession.HostOffset);
    query := '{"method": "addClient", "reqId": "1-' + unixTime + '", "authToken": "' + pSession.RESTToken + '", "params": ""}';
    loggaICQPkt('[POST] REST client id', WL_sent_text, query);
    LoadFromURL(baseUrl, fs, 0, False, True, query, True);

    fs.Seek(0, soBeginning);
    SetLength(respStr, fs.Size);
    if fs.Size>0 then
      fs.ReadBuffer(respStr[1], fs.Size);
    fs.Clear;

    JSONObject := TJSONObject.ParseJSONValue(respStr) as TJSONObject;
    if Assigned(JSONObject) then
    begin
      pSession.RESTClientId := (JSONObject.GetValue('results') as TJSONObject).GetValue('clientId').Value;
      loggaICQPkt('[POST] REST client id', WL_rcvd_text, respStr);
    end else
    begin
      pSession.RESTClientId := '';
      loggaICQPkt('[POST] REST client id', WL_rcvd_text, 'Failed to get client id');
    end;
  finally
    FreeAndNil(fs)
  end;
end;

procedure ICQREST_refreshSessionSecret(const pAcc, pPwd: String; var pSession: TSessionParams);
var
  fs: TMemoryStream;
  session: RawByteString;
  Params, KeyValPair: TStringList;
  i: Integer;
begin
  if not (pAcc = '') and not (pPwd = '') then
  begin
    fs := TMemoryStream.Create;
    LoadFromUrl('https://api.login.icq.net/auth/clientLogin', fs, 0, false, true,
                'devId=' + ICQ_DEV_ID +'&f=qs&s=' + String(pAcc) + '&pwd=' + pPwd, false);
    SetLength(session, fs.Size);
    if fs.Size > 0 then
      fs.ReadBuffer(session[1], fs.Size);
    fs.Free;

    Params := TStringList.Create;
    KeyValPair := TStringList.Create;
    try
      Params.Delimiter := '&';
      Params.StrictDelimiter := true;
      Params.DelimitedText := UTF8ToStr(session);

      KeyValPair.Delimiter := '=';
      KeyValPair.StrictDelimiter := true;

      for i := 0 to Params.Count -1 do
      begin
        KeyValPair.Clear;
        KeyValPair.DelimitedText := UTF8ToStr(StringReplace(Params.Strings[i], '+', ' ', [rfReplaceAll]));
        if KeyValPair.Count >= 2 then
        begin
          if (KeyValPair.Strings[0] = 'statusCode') then
            if not ((KeyValPair.Strings[1] = '200') or (KeyValPair.Strings[1] = '304')) then Break;
          if (KeyValPair.Strings[0] = 'statusText') then
            if not (KeyValPair.Strings[1] = 'OK') then Break;

          if (KeyValPair.Strings[0] = 'token_a') then
            pSession.Token := KeyValPair.Strings[1];
          if (KeyValPair.Strings[0] = 'token_expiresIn') then
            TryStrToInt(KeyValPair.Strings[1], pSession.TokenExpIn);
          if (KeyValPair.Strings[0] = 'hostTime') then
            TryStrToInt(KeyValPair.Strings[1], pSession.TokenTime);
          if (KeyValPair.Strings[0] = 'sessionSecret') then
            pSession.Secret := KeyValPair.Strings[1];
        end;
      end;
    finally
      Params.Free;
    end;
  end;
end;

end.

