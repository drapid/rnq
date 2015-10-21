{
This file is part of R&Q.
Under same license
}
unit RQ_ICQ;
{$I RnQConfig.inc}
{$I NoRTTI.inc}

interface
 uses
   Windows, Forms, Classes, Graphics, SysUtils, ICQv9,
   RnQProtocol;

  procedure icq_SinchrCL(icq : ticqSession);
  Procedure ProcessSSIItem(curICQ : TicqSession; item : TOSSIItem);

  function  TypeStringToTypeId(const s : AnsiString) : Integer;
  procedure debug_Snac(const snac : RawByteString; Fn : String);
  function  unFakeUIN(uin : int64 ) : TUID;
 {$IFDEF RNQ_AVATARS}
  procedure avt_icqEvent(thisICQ:TicqSession; ev:TicqEvent);

 {$ENDIF RNQ_AVATARS}
// procedure EvilRequest(sn : TUID);

//type

  function  parse1306(curICQ : TICQSession; var ssiList : Tssi; const snac: RawByteString; ref:integer) : Boolean;

  function  FindSSIItemType(si : Tssi; pType : Byte) : Integer;
  function  FindSSIItemID(si : Tssi; iID : Word) : Integer;
  function  FindSSIItemIDType(si : Tssi; iID : Word; pType : byte) : Integer;
  function  FindSSIItemIDgID(si : Tssi; iID, gID : Word) : Integer;
  function  FindSSIItemName(si : Tssi; iType : Word; const iName : TUID) : Integer;
  procedure clearSSIList(var list : Tssi);
  Function  ReadSSIChunk(const snac : RawByteString; var ofs : Integer; ExtractInfo : Boolean = True) : TOSSIItem;

  function getFirstFlap:word;

//  function qip_msg_decr(s1 : RawByteString; s2: AnsiString; n:integer): AnsiString;
//  function qip_msg_crypt(s1, s2: AnsiString;n:integer): RawByteString;
  function qip_msg_crypt(const s : AnsiString; p : Integer): RawByteString;
  function qip_msg_decr(const s1 : RawByteString; p:integer): AnsiString;
//  function qip_msg_crypt(s1, s2: AnsiString;n:integer): RawByteString;
  function qip_str2pass(const s : RawByteString) : Integer;


{$IFDEF usesDC}
type
  TFilePacket = class(TObject)
   public
    CheckSum : Cardinal;
    FileList : TStringList;
    constructor Create;
    Destructor Destroy; Override;
    function AddFile(fn : String) : Integer;
    function Count : Integer; Inline;
  end;

 function peer_oft_checksum_file(fn : String; InitChkSum : Cardinal = $ffff0000) : Cardinal;
{$ENDIF usesDC}

  procedure parseImgLinks2(var msg: RawByteString);
  function parseTzerTag(const sA: RawByteString): RawByteString;
  function parseTzer2URL(const sA: RawByteString; var sMsg : RawByteString): RawByteString;

var
  Attached_login_email:  string;

var
  isImpCL : Boolean;

var
//  ListLoaded : Boolean;

  icqdebug : Boolean;

var
  CLPktNUM : Byte;

implementation
uses
  DateUtils, ansistrings, AnsiClasses, JSON,
  math, Types, StrUtils,
  RDGlobal, RnQBinUtils, RDFileUtil, RDUtils, Base64,
  RnQGlobal,
 {$IFDEF RNQ_AVATARS}
  RnQ_Avatars,
 {$ENDIF}
  RnQNet, RQUtil, RnQLangs,
  Protocol_ICQ,
  menusUnit,
  UtilLib, roasterlib, mainDlg, GlobalLib,
  ICQConsts, ICQContacts, RnQStrings, RnQDialogs, groupsLib;

Procedure ProcessSSIItem(curICQ : TicqSession; item : TOSSIItem);
var
//  I: Integer;
//  k: Integer;
//  g_id : integer;
  c : TICQcontact;
begin
  with item do
  if ItemType = FEEDBAG_CLASS_ID_BUDDY then
   begin
     c:= curICQ.getICQContact(ItemName);
     if (c=NIL) then exit;
     if c.UID='' then exit;
{      if GroupID = 0 then
        c.group := 2000
       else
        begin
         c.group := groups.ssi2id(GroupID);
         if c.group <0 then
          c.group := GroupID;
        end;
}
      c.SSIID := ItemID;
      c.CntIsLocal := False;
      if Caption > '' then
        c.fDisplay := Caption;
      if FCellular > '' then
        c.ssCell := FCellular;
      if FCellular2 > '' then
        c.ssCell2 := FCellular2;
      if FCellular3 > '' then
        c.ssCell3 := FCellular3;
      if FMail > '' then
        c.ssMail := FMail;
      if Fnote > '' then
        c.ssImportant := Fnote;
      c.Authorized := FAuthorized;
      if (c.display = '') and (c.infoUpdatedTo=0) then
        TCE(c.data^).toquery:=True
      else
        TCE(c.data^).toquery:=false;
   end;
end;

procedure SyncSSILocal(curICQ : TicqSession);
var
  I: Integer;
//  k: Integer;
  g_id : integer;
  c : TICQcontact;
  cnt : TRnQContact;
  locCL, invCL, visCL : TRnQCList;
  s : RawByteString;
begin
  if not Assigned(curICQ) then
    Exit;
  locCL := TRnQCList.Create;
  invCL := TRnQCList.Create;
  visCL := TRnQCList.Create;

  with ContactsDB do
    begin
      resetEnumeration;
      while hasMore do
        begin
         cnt := getNext;
         cnt.CntIsLocal := True;
         cnt.SSIID := 0;
         cnt.Authorized := false;
        end;
    end;
  for I := 0 to groups.count - 1 do
    groups.a[i].ssiID := 0;
 {$IFDEF UseNotSSI}
  if curICQ.useSSI then
 {$ENDIF UseNotSSI}
   begin
//    invisibleList.Clear;
//    visibleList.Clear;
    curICQ.readList(LT_INVISIBLE).Clear;
    curICQ.readList(LT_VISIBLE).Clear;
    ignoreList.remove(curICQ.readList(LT_SPAM));
    curICQ.readList(LT_SPAM).Clear;
   end;

  for I := 0 to curICQ.serverSSI.items.Count - 1 do
   with TOSSIItem(curICQ.serverSSI.items.Objects[i]) do
   case ItemType of
    FEEDBAG_CLASS_ID_PDINFO:
        begin
          s := getTLVSafe($CA, ExtData);
          if s > '' then
           if Byte(s[1]) in [Low(visibilitySSI2vis)..High(visibilitySSI2vis)] then
              curICQ.visibility := visibilitySSI2vis[Byte(s[1])];
        end;
    FEEDBAG_CLASS_ID_GROUP:
        begin
          if GroupID = 0 then
            Continue;
          g_id:=groups.name2id(unUTF(ItemName));
          if g_id < 0 then
            with groups do
             begin
              g_id:=add(GroupID);
              with a[idxOf(g_id)] do
               begin
                ssiID := GroupID;
                name:=unUTF(ItemName);
               end;
             end
           else
            with groups do
              with a[idxOf(g_id)] do
                ssiID := GroupID;
         end;
    FEEDBAG_CLASS_ID_PERMIT,
    FEEDBAG_CLASS_ID_DENY,
    FEEDBAG_CLASS_ID_IGNORE_LIST,
    FEEDBAG_CLASS_ID_BUDDY:
         BEGIN
           c :=curICQ.getICQContact(ItemName);
           if (c=NIL) then Continue;
           if c.UID='' then Continue;
           case ItemType of
            FEEDBAG_CLASS_ID_BUDDY:
              begin
                if GroupID = 0 then
                  c.group := 2000
                 else
                  begin
                   c.group := groups.ssi2id(GroupID);
                   if c.group <0 then
                    c.group := GroupID;
                  end;
                c.SSIID := ItemID;
                c.CntIsLocal := False;
                c.fDisplay := Caption;
                if FCellular > '' then
                  c.ssCell := FCellular;
                if FCellular2 > '' then
                  c.ssCell2 := FCellular2;
                if FCellular3 > '' then
                  c.ssCell3 := FCellular3;
                if FMail > '' then
                  c.ssMail := FMail;
                if Fnote > '' then
                  c.ssImportant := Fnote;
                c.InfoToken := FInfoToken;
                c.fServerProto := FProto;
                if c.Authorized <> FAuthorized then
                 begin
                  c.Authorized := FAuthorized;
                  if FAuthorized and (c.status = SC_UNK) then
                    c.status := SC_OFFLINE;
                 end;
                if (c.display = '') and (c.infoUpdatedTo=0) then
                  TCE(c.data^).toquery:=True
                else
                  TCE(c.data^).toquery:=false;

                notInList.remove(c);
                locCL.add(c)
              end;
            FEEDBAG_CLASS_ID_PERMIT:
                if not curICQ.isInList(LT_VISIBLE, c) then
                 visCL.add(c);
            FEEDBAG_CLASS_ID_DENY:
                if not curICQ.isInList(LT_INVISIBLE, c) then
                 invCL.add(c);
            FEEDBAG_CLASS_ID_IGNORE_LIST:
                if not curICQ.isInList(LT_SPAM, c) then
                  curICQ.readList(LT_SPAM).add(c);
           end;
         END
    else
   end;
 {$IFDEF UseNotSSI}
   if not curICQ.useSSI then
     begin
       curICQ.addContact(locCL, True);
       curICQ.add2visible(visCL, not curICQ.useSSI);
       curICQ.add2invisible(invCL, not curICQ.useSSI);
     end
    else
 {$ENDIF UseNotSSI}
     begin
       curICQ.addContact(locCL, False);
       curICQ.readList(LT_VISIBLE).add(visCL);
       curICQ.readList(LT_INVISIBLE).add(invCL);
     end;
   ignoreList.add(curICQ.readList(LT_SPAM));
   locCL.Free;
   invCL.Free;
   visCL.Free;
   curICQ.localSSI_itemCnt := curICQ.serverSSI.itemCnt;
   curICQ.localSSI_modTime := curICQ.serverSSI.modTime;
 {$IFDEF UseNotSSI}
   if not curICQ.useSSI then
     roasterlib.rebuild;
 {$ENDIF UseNotSSI}
end;

procedure SyncSSIServer;
//var
//  I: Integer;
//  k: Integer;
//  item:  TOSSIItem;
begin
//	if icq.waiting_for_ack then
//		 Exit;

 // 1st - modify groups
{
  for I := 0 to serverSSI.items.Count - 1 do
   with TOSSIItem(serverSSI.items.Objects[i]) do
   if ItemType = FEEDBAG_CLASS_ID_GROUP then
    if groups.ssi2id(GroupID) > 0 then

      for k := 0 to serverSSI.items.Count - 1 do
        if TOSSIItem(serverSSI.items.Objects[k]).GroupID =
             TOSSIItem(serverSSI.items.Objects[i]).GroupID then
}

end;

//  function readWNTS(snac : String; var ofs : integer): string; inline;
//  begin Result := getBEWNTS(snac, ofs); end;

  function ReadSSIChunk(const snac : RawByteString; var ofs : Integer; ExtractInfo : Boolean = True) : TOSSIItem;
  var
    Len:   word;
    CList, s1 : RawByteString;
    ofs00, i : integer;
    bday  : TDateTime;
  begin
    Result  := TOSSIItem.Create;
    with Result do
    begin
      ItemName := getBEWNTS(snac, ofs);         //The name of the group.
    //This field seems to be a tag or marker associating different groups together into a larger group such as the Ignore List or 'General' contact list group, etc.
      GroupID := readBEWORD(snac, ofs);
    //This is a random number generated when the user is added to the contact list, or when the user is ignored.
      ItemID := readBEWORD(snac, ofs);
      //This field seems to indicate what type of group this is.
      ItemType := readBEWORD(snac, ofs);
      //The length in bytes of the following TLVs.
     Len   := word_LEat(@snac[ofs]);
     Clist := getBEWNTS(snac, ofs);
      ExtData := Clist;
     isNIL := False;
     FAuthorized := True;
//      Debug := Clist;
    end;
    //    c := nil;
    if ExtractInfo then
    if Clist > '' then
      try
        Result.Caption   := unUTF(getTLVSafeDelete($0131, Clist));
//        deleteTLV($0131, Clist);
        Result.FMail     := unUTF(getTLVSafeDelete($0137, Clist));
        Result.FCellular := unUTF(getTLVSafeDelete($013A, Clist));
        Result.FCellular2:= unUTF(getTLVSafeDelete($0138, Clist));
        Result.FCellular3:= unUTF(getTLVSafeDelete($0158, Clist));
        Result.Fnote     := unUTF(getTLVSafeDelete($013C, Clist));
        s1               := getTLVSafeDelete($0145, Clist);
        if s1 > '' then
         Result.FFirstMsg := UnixToDateTime(dword_BEat(@s1[1])) // getTLVdwordBE($0145, Clist));
        else
         Result.FFirstMsg := 0;
        Result.isNIL := existsTLV($6A, CList);
        Result.FAuthorized := not existsTLV($66, CList);
         Clist := deleteTLV($0066, Clist);
        Result.FInfoToken  := getTLVSafeDelete($015C, Clist);
        Result.Fproto := UnUTF(getTLVSafeDelete($0084, Clist));
//        Result.Debug := '';
        ofs00 := 1;
        //        while word_BEat(@s[ofs00])<>idx do
        try
          while ofs00 < length(Clist) do
          begin
            i := word_BEat(@Clist[ofs00]);
//            Result.Debug := Result.Debug +
{
            s := 'TLV(' + IntToHex(i, 2) + ') '+
//            Result.Debug := Result.Debug +
              str2hex(Copy(Clist, ofs00 + 4, word_BEat(@Clist[ofs00 + 2])));
{            if i = $6D then
             begin
//              Int64((@bday)^)   := Qword_BEat(@Clist[ofs00 + 4]);
//              item.ExtInfo := item.ExtInfo +'(' + DateToStr(bDay) + ')';
             end;
}
            if i = $15D then
             begin
              Int64((@bday)^)   := Qword_BEat(@Clist[ofs00 + 4]);
//              Result.Debug := Result.Debug + s + '(' + DateTimeToStr(bDay) + ')';
             end
            else
            if (i = $67)or (i = $160)or(i = $6D) then
             begin
              bday := UnixToDateTime(dword_BEat(@Clist[ofs00 + 4]));
              if (Result.ItemType = FEEDBAG_CLASS_ID_DELETED)and(i = $6D) then
                Result.FFirstMsg := bday
               else
//                Result.Debug := Result.Debug + s + '(' + DateTimeToStr(bDay) + ')';
             end
//            else
//              Result.Debug := Result.Debug + s
             ;

//            Result.Debug := Result.Debug + CRLF;
            Inc(ofs00, word_BEat(@Clist[ofs00 + 2]) + 4);
            //          if ofs00 >= length(Clist) then
            //            exit;
          end;
        except
//          Result.Debug := str2hex(Clist);
        end;
        //        result:=ofs;
        //       getTLV(@s[1])
        //       CList
        //       item.ExtInfo :=
      except
        Result.Caption   := '';
        Result.FMail     := '';
        Result.FCellular := '';
        Result.FCellular2:= '';
        Result.FCellular3:= '';
        Result.Fnote     := '';
        Result.FInfoToken:= '';
        Result.FFirstMsg := 0;
        Result.FAuthorized := True;
      end
    else
    begin
      Result.Caption   := '';
      Result.FMail     := '';
      Result.FCellular := '';
      Result.FCellular2:= '';
      Result.FCellular3:= '';
      Result.Fnote     := '';
      Result.FInfoToken:= '';
      Result.FFirstMsg := 0;
      Result.FAuthorized := True;
    end;
  end;


function parse1306(curICQ : TICQSession; var ssiList : Tssi; const snac: RawByteString; ref: integer) : Boolean;
var
  //  UINList: TList;
  ofs: integer;
  //  c : Tcontact;
  //  pkt : TRawPkt;
  item:  TOSSIItem;
  Count: word;
  i:     word;
  //  dw : DWORD;
  Vers:  integer;
//  Thing: string;
  ts:    RawByteString;  // Строка со временем последнего изменения
begin
  if icqdebug then
    begin
      saveFile2(mypath+'ServList'+ intToStr(CLPktNUM) + '.ssi', snac);
    end;
  ofs  := 1;
  Vers := readBYTE(snac, ofs); //(snac, ofs);
{  i    := word_BEat(@snac[ofs]);
  if i > 1200 then
  begin
    Dec(ofs);
    Thing := getBEWNTS(snac, ofs);             //I Don't know WHAT IS THAT!!!
    Inc(ofs);
  end;
}
  Count := readBEWORD(snac, ofs);
  //(snac, ofs);              //Total count of following groups. This is the size of the server side contact list and should be saved and sent with CLI_CHECKROSTER.

  //  CL := TcontactList.Create;
  if CLPktNUM = 0 then
  begin
    try
     clearSSIList(ssiList);
//    serverSSI.itemCnt := 0;
//     if Assigned(serverSSI.items) then
//      serverSSI.items.Clear;
//     FreeAndNil(serverSSI.items);
    Except
    end;
    if not Assigned(ssiList.items) then
      ssiList.items := TStringList.Create;
  end;

  if Count < 1 then
   begin
    result := True;
    CLPktNUM := 0;
    isImpCL := False;
    Exit;
   end;

  inc(ssiList.itemCnt, Count);
  //  isImpCL := True;
   for i := 0 to Count - 1 do
    begin
      item := ReadSSIChunk(snac, ofs);
      ssiList.items.AddObject(Item.ItemName, Item);
      Item := nil;
      if ofs >= Length(snac)-4 then
       break;
    end;
  //  ts := dword_LEat(@snac[length(snac)-4])
  ts := copy(snac, length(snac) - 3, 4);
  if ts <> z then
   begin
    ssiList.modTime := UnixToDateTime(dword_BEat(@ts[1]));
    result := True;
    CLPktNUM := 0;
   end
   else
    begin
     result := False;
     inc( CLPktNUM );
    end;

   if result then
   begin
    if isImpCL then
     SyncSSILocal(curICQ);
    isImpCL := False;
   end;
end;

procedure icq_SinchrCL(icq : ticqSession);
begin
  icq.RequestContactList(False);
end;


function TypeStringToTypeId(const s : Ansistring) : Integer;
var
  nTypeID : Integer;
begin
  nTypeID := 0;
	if (s = Str_message) then
			nTypeID := MTYPE_PLAIN
  else if s = 'StatusMsgExt' then
    nTypeID := MTYPE_AUTOAWAY
	else if (s = 'Web Page Address (URL)') or
     (s = 'Send Web Page Address (URL)') or
     (s = 'Send URL') then
    	nTypeID := MTYPE_URL
	else if (s = 'Contacts') or
	        (s = 'Send Contacts') then
			nTypeID := MTYPE_CONTACTS
	else if (s = 'ICQ Chat') then
		nTypeID := MTYPE_CHAT
	else if (s = 'Send / Start ICQ Chat') then
		nTypeID := MTYPE_CHAT
	else if (s ='File') or
		      (s = 'File Transfer')or
          (s = 'Файл') then
		nTypeID := MTYPE_FILEREQ
	else if (s = 'Request For Contacts') then
		nTypeID := MTYPE_PLUGIN
  else if s=PLUGIN_SCRIPT then
    nTypeID := MTYPE_XSTATUS
  else if (s = 'Greeting Card') or
          (s = 'Send Greeting Card')or
          (s = 'Отправить открытку') then
    nTypeID := MTYPE_GCARD
	else if (s = 'T-Zer Message')or(s = 'Send Tzer') then
			nTypeID := MTYPE_PLAIN
  else if s = 'StatusMsgExt' then
  else if pos(AnsiString('Сообщ'), s) > 0 then
    nTypeID := MTYPE_PLAIN;

	result := nTypeID;
end;

procedure debug_Snac(const snac : RawByteString; Fn : String);
begin
//        appendFile(mypath+Fn, snac);
//        appendFile(mypath+Fn, '---------------------'#$0A);
end;


function unFakeUIN(uin : int64) : TUID;
var
  x: int64;
begin
// x := MaxLongint;
 x := UIN;
 while x > 4294967296 do
  x := x - 4294967296;
 result := IntToStrA(x);
end;


 {$IFDEF RNQ_AVATARS}
procedure avt_icqEvent(thisICQ:TicqSession; ev:TicqEvent);
//var
//  s : string;
//  i : Integer;
//  PicFmt : TPAFormat;
begin
case ev of
  TicqEvent(IE_online), TicqEvent(IE_offline):
       avtSessInit := False;
//  IE_offline:logBox.text:= (getTranslation('Offline'));

  IE_serverDisconnected:
    begin
       avtSessInit := False;
     {$IFDEF AVATARS_DEBUG}
      loggaICQPkt('Avatar', WL_disconnected, thisICQ.eventAddress);
     {$ENDIF AVATARS_DEBUG}
//      if Assigned(icq) and icq.isOnline then
//        icq.sendSNAC(ICQ_SERVICE_FAMILY, 4, #$00#$10);
    end;
     {$IFDEF AVATARS_DEBUG}
  IE_serverConnected: loggaICQPkt('Avatar', WL_connected, thisICQ.eventAddress);
  IE_serverSent: loggaICQPkt('Avatar', WL_serverSent,thisICQ.eventData);
  IE_serverGot: loggaICQPkt('Avatar', WL_serverGot,thisICQ.eventData);
     {$ENDIF AVATARS_DEBUG}

  IE_connecting:
    begin
    thisICQ.sock.proxySettings(MainProxy);
//      proxySettings(ICQ.fProxy, thisICQ.sock);
    end;
  IE_getAvtr:
    begin
      if Assigned(thisICQ.eventStream) and
         Assigned(thisICQ.eventContact) then
       begin
        if thisICQ.eventStream.size > 0 then
         begin
          avatars_save_and_load(thisICQ.eventContact, thisICQ.eventMsgA,
                                thisICQ.eventStream);
          if Assigned(thisICQ.eventStream) then
            freeAndNil(thisICQ.eventStream);
          updateAvatarFor(thisICQ.eventContact);
         end
        else
          freeAndNil(thisICQ.eventStream);
       end;
    end;
{  IE_addedYou:
    begin
      i := FindSSIItemType(serverSSI, FEEDBAG_CLASS_ID_BART);
      if i >= 0 then
       with TOSSIItem(serverSSI.items.Objects[i]) do
        begin
          if ExtData <> TLV($D5, #$01+#$10 + thisICQ.eventMsg) then
           ICQ.SSI_UpdateItem('1', TLV($D5, #$01+#$10 + thisICQ.eventMsg),
                GroupID, ItemID, ItemType);
        end
      else
       ICQ.SSI_CreateItem('1', TLV($D5, #$01+#$10 + thisICQ.eventMsg),
            0, $5566, FEEDBAG_CLASS_ID_BART);
    end;
}
  TicqEvent(IE_error):
    begin
//     {$IF PREVIEWversion}
//      msgDlg('Avatars: '+getTranslation(icqerror2str[thisICQ.eventError], [thisICQ.eventInt, thisICQ.eventMsg]), mtError);
//     {$IFEND }
//     theme.PlaySound(Str_Error);
    end;
  end;
{  if ev = IE_serverDisconnected then
   begin
//     FreeAndNil(avt_icq);
   end;}
end;
 {$ENDIF RNQ_AVATARS}

{procedure EvilRequest(sn : TUID);
begin
  if not icq.isOnline then Exit;
  ICQ.sendSNAC(ICQ_MSG_FAMILY, $08, word_BEasStr(1) + BUIN(sn));
end;


{
type
  TRQTaskID = (idRemoveContact, idAddGroup, idRenameGroup,
               idAddContact, idRenameContact, idRemoveGroup);

  TRQTask = class
    ID: TRQTaskID;
    C: TContact;
    G: TGroup;
    // тут еще что хочешь добавь
  end;
procedure TfrmCL.SynchronizeList;
var
  AddList, RemoveList, CommonList: TStringList;
  AddGroup, RemoveGroup, CommonGroup: TStringList;
  I, Index: Integer;

  function IndexOfID(Groups: TGroups; ID: Integer): Integer;
  begin
    Result:= Groups.idxOf(ID);
  end;

  function IndexOfName(Groups: TGroups; Name: String): Integer;
  var
    I: Integer;
  begin
    Result:= -1;
    for I := 0 to Groups.Count - 1 do
    begin
      if Groups.a[I].name <> Name then Continue;
      Result:= I;
      Exit;
    end;
  end;

begin
  mm.Text:= '';

  //////////////////////////////////////////////////////////////////////////////
  /// сравниваем группы
  //////////////////////////////////////////////////////////////////////////////
  AddGroup:= TStringList.Create;
  AddGroup.NameValueSeparator:= ';';
  RemoveGroup:= TStringList.Create;
  RemoveGroup.NameValueSeparator:= ';';
  CommonGroup:= TStringList.Create;
  CommonGroup.NameValueSeparator:= ';';

  for I := 0 to Groups.Count - 1 do
  begin
    // ищем группы с одним ID, но возможно с разными именами
    Index:= IndexOfID(ServerGroups, Groups.a[I].id);
    if Index >= 0 then
    begin
      if ServerGroups.a[Index].name <> Groups.a[I].name then
      begin
        ServerGroups.a[Index].name:= Groups.a[I].name;
        mm.Lines.Add('Переименовать группу "'+ Groups.a[I].name +'"');
        CommonGroup.Add(IntToStr(Groups.a[I].id)+';'+Groups.a[I].name);
      end
      else
      begin
        mm.Lines.Add('Группа существует "'+ Groups.a[I].name +'"');
        CommonGroup.Add(IntToStr(Groups.a[I].id)+';'+Groups.a[I].name);
      end;
    end
    else
    begin
      // ищем группы с одним именем и меняем их ID на нужный
      Index:= IndexOfName(ServerGroups, Groups.a[I].name);
      if Index >= 0 then
      begin
        //changeId(ServerGroups.a[Index].id, Groups.a[I].id, DB);
        Groups.a[I].id:= ServerGroups.a[Index].id;
        mm.Lines.Add('Сменить ID локальной группе "'+ Groups.a[I].name +'"');
        CommonGroup.Add(IntToStr(Groups.a[I].id)+';'+Groups.a[I].name);
      end
      else
      begin
        // никаких совпадений нет, значит добавляем новую группу
        mm.Lines.Add('Добавить группу "'+ Groups.a[I].name +'"');
        AddGroup.Add(IntToStr(Groups.a[I].id)+';'+Groups.a[I].name);
      end;
    end;
  end;

  for I := 0 to ServerGroups.Count - 1 do
  begin
    if (AddGroup.IndexOfName(IntToStr(ServerGroups.a[I].id)) = -1) and
       (CommonGroup.IndexOfName(IntToStr(ServerGroups.a[I].id)) = -1)
    then
    begin
      mm.Lines.Add('Удалить группу "'+ ServerGroups.a[I].name +'"');
      RemoveGroup.Add(IntToStr(ServerGroups.a[I].id)+';'+ServerGroups.a[I].name);
    end;
  end;

  //////////////////////////////////////////////////////////////////////////////
  /// сравниваем контакты
  //////////////////////////////////////////////////////////////////////////////
  AddList:= TStringList.Create;
  RemoveList:= TStringList.Create;
  CommonList:= TStringList.Create;

  for I := 0 to ClientList.Count - 1 do
  begin
    if ServerList.exists(ClientList.getAt(I).uin) then
      CommonList.Add(ClientList.getAt(I).uinAsStr)
    else
    begin
      AddList.Add(ClientList.getAt(I).uinAsStr);
      mm.Lines.Add('Добавить номер '+ClientList.getAt(I).uinAsStr);
    end;
  end;

  for I := 0 to ServerList.Count - 1 do
  begin
    if not ClientList.exists(ServerList.getAt(I).uin) then
    begin
      RemoveList.Add(ServerList.getAt(I).uinAsStr);
      mm.Lines.Add('Удалить номер '+ServerList.getAt(I).uinAsStr);
    end;
  end;

  for I := 0 to CommonList.Count - 1 do
  begin
    Index:= StrToInt(CommonList[I]);
    if ClientList.get(Index).group <> ServerList.get(Index).group then
    begin
      mm.Lines.Add('Переместить номер '+ServerList.get(Index).uinAsStr+
                  ' в группу c ID: '+ IntToStr(ClientList.get(Index).group));
    end;
  end;


  AddList.Clear;
  FreeAndNil(AddList);

  RemoveList.Clear;
  FreeAndNil(AddList);

  CommonList.Clear;
  FreeAndNil(CommonList);

  AddGroup.Clear;
  FreeAndNil(AddList);

  RemoveGroup.Clear;
  FreeAndNil(AddList);

  CommonGroup.Clear;
  FreeAndNil(CommonList);
end;

}

procedure clearSSIList(var list : Tssi);
var
  I: Integer;
//  k: Integer;
begin
// if Assigned(list.) then
  try
    if Assigned(list.items) then
     begin
      for I := list.items.Count-1 downto 0 do
       TOSSIItem(list.items.Objects[i]).Free;
      list.items.Clear;
      list.items.Free;
      list.items := NIL;
     end;
//    FreeAndNil(list.items);
   except
  end;
  list.itemCnt := 0;
  list.modTime := 0; 
end;

function FindSSIItemType(si : Tssi; pType : Byte) : Integer;
var
  i : Integer;
begin
  Result := -1;
  if Assigned(si.items) then
  for I := 0 to si.items.Count - 1 do
   if TOSSIItem(si.items.Objects[i]).ItemType = pType then
    begin
     Result := i;
     Break;
    end;
end;
function  FindSSIItemID(si : Tssi; iID : Word) : Integer;
var
  i : Integer;
begin
  Result := -1;
  if Assigned(si.items) then
  for I := 0 to si.items.Count - 1 do
   if TOSSIItem(si.items.Objects[i]).ItemID = iID then
    begin
     Result := i;
     Break;
    end;
end;

function  FindSSIItemIDType(si : Tssi; iID : Word; pType : byte) : Integer;
var
  i : Integer;
  it : TOSSIItem;
begin
  Result := -1;
  if Assigned(si.items) then
  for I := 0 to si.items.Count - 1 do
   begin
     it := TOSSIItem(si.items.Objects[i]);
     if (it.ItemType = pType)and (it.ItemID = iID) then
      begin
       Result := i;
       Break;
      end;
   end;
end;

function  FindSSIItemIDgID(si : Tssi; iID, gID : Word) : Integer;
var
  i : Integer;
begin
  Result := -1;
  if Assigned(si.items) then
  for I := 0 to si.items.Count - 1 do
   if (TOSSIItem(si.items.Objects[i]).ItemID = iID)
    and (TOSSIItem(si.items.Objects[i]).GroupID = gID) then
    begin
     Result := i;
     Break;
    end;
end;

function  FindSSIItemName(si : Tssi; iType : Word; const iName : TUID) : Integer;
var
  i : Integer;
begin
  Result := -1;
  if Assigned(si.items) then
  for I := 0 to si.items.Count - 1 do
   with TOSSIItem(si.items.Objects[i]) do
   if (ItemType = iType) and (ItemName = iName) then
    begin
     Result := i;
     Break;
    end;
end;


{$IFDEF usesDC}
const
  CHECKSUM_BUFFER_SIZE = 256 * 1024;

type
  PChecksumData = ^TChecksumData;
  TSourceFunc =  procedure(cd : PChecksumData);
  TChecksumData = record
      conn : TProtoDirect;
//      xfer : PurpleXfer;
//      GSourceFunc callback;
      callback : TSourceFunc;
      size : Int64;
      checksum : cardinal;
      total : Int64;
//      file  : TFILE;
      Stream : TStream;
      buffer : array[1..CHECKSUM_BUFFER_SIZE] of byte;
      timer  : THandle;
  end;

procedure peer_oft_checksum_destroy(cs : PChecksumData);
begin
end;

function peer_oft_checksum_chunk(buffer : PByteArray; bufferlen :Integer; prevchecksum : cardinal; odd : Boolean) : cardinal;
var
	checksum, oldchecksum : Cardinal;
	i : Integer;
//	val : Shortint;
	val : DWORD;
begin
  i := 0;
	checksum := (prevchecksum shr 16) and $ffff;
	if (odd) then
   begin
		(*
     * This is one hell of a hack, but it should always work.
		 * Essentially, I am reindexing the array so that index 1
		 * is the first element.  Since the odd and even bytes are
		 * detected by the index number.
		 *)
    i := 1;
    inc(bufferlen);
    dec(buffer);
   end;
	while i < bufferlen do
   begin
    oldchecksum := checksum;
		if (i and 1) > 0 then
			val := buffer[i]
		else
			val := buffer[i] shl 8;
		dec(checksum, val);
		{*
		 * The following appears to be necessary.... It happens
		 * every once in a while and the checksum doesn't fail.
		 *}
		if (checksum > oldchecksum) then
			dec(checksum);
    inc(i);
  end;
	checksum := ((checksum and $0000ffff) + (checksum shr 16));
	checksum := ((checksum and $0000ffff) + (checksum shr 16));
	result := checksum shl 16;
end;

function peer_oft_checksum_file_piece(data : PChecksumData) : Boolean;
var
	checksum_data : PChecksumData;
	rep : Boolean;
  bytes : Int64;
begin
	checksum_data := data;
	rep := FALSE;

	if (checksum_data.total < checksum_data.size) then
	begin
		bytes := MIN(CHECKSUM_BUFFER_SIZE,
				checksum_data.size - checksum_data.total);

    checksum_data.Stream.Position := checksum_data.total;
    bytes := checksum_data.Stream.Read(checksum_data.buffer, bytes);
		if (bytes > 0) then
		begin
			checksum_data.checksum := peer_oft_checksum_chunk(@checksum_data.buffer, bytes, checksum_data.checksum, (checksum_data.total and 1) > 0);
			inc(checksum_data.total,bytes);
			rep := TRUE;
		end;
	end;

	if (not rep) then
   begin
		if Assigned(checksum_data.callback) then
			checksum_data.callback(checksum_data);
		peer_oft_checksum_destroy(checksum_data);
   end;

	result := rep;
end;

function peer_oft_checksum_file(fn : string; InitChkSum : Cardinal = $ffff0000) : Cardinal;
var
	checksum_data : PChecksumData;
//	checksum_data : TChecksumData;
begin

//	checksum_data := g_malloc0(sizeof(ChecksumData));
  new(checksum_data);
//	checksum_data := new( g_malloc0(sizeof(ChecksumData));
//	checksum_data.conn := conn;
	checksum_data.conn := NIL;
//	checksum_data.xfer := xfer;
//	checksum_data.callback := callback;
	checksum_data.callback := NIL;
	checksum_data.checksum := InitChkSum;
	checksum_data.Stream := GetStream(fn);
	checksum_data.total := 0;

	if (checksum_data.Stream = NIL) then
	begin
    checksum_data.size := 0;
    Result := 0;
//		g_free(checksum_data);
	end
	else
  begin
    checksum_data.size := checksum_data.Stream.Size;
//		checksum_data.timer := purple_timeout_add(10,
//				peer_oft_checksum_file_piece, checksum_data);
//		conn.checksum_data = checksum_data;
    while peer_oft_checksum_file_piece(checksum_data) do
      Application.ProcessMessages;
    Result := checksum_data.checksum;
	end;
  if Assigned(checksum_data.Stream) then
   checksum_data.Stream.Free;
  checksum_data.Stream := NIL;
  FreeMemory(checksum_data);
end;

constructor TFilePacket.Create;
begin
  FileList := TStringList.Create;
  CheckSum := $FFFF0000;
end;

destructor TFilePacket.Destroy;
var
  I: Integer;
begin
  if Assigned(FileList) then
   begin
     for I := 0 to FileList.Count - 1 do
       begin
         TFileAbout(FileList.Objects[i]).fPath := '';
         TFileAbout(FileList.Objects[i]).fName := '';
         FileList.Objects[i].Free;
         FileList.Objects[i] := NIL;
       end;
     FileList.Clear;
     FileList.Free;
     FileList := NIL;
   end;
  Inherited; 
end;

function TFilePacket.Count : Integer;
begin
  Result := FileList.Count;
end;

function TFilePacket.AddFile(fn : String) : Integer;
var
  fa : TFileAbout;
begin
  fa := TFileAbout.Create;
  fa.Size := sizeOfFile(fn);
  fa.Processed := 0;
  fa.fPath := ExtractFilePath(fn);
  fa.fName := ExtractFileName(fn);
  Result := FileList.AddObject(fn, fa);
  CheckSum := peer_oft_checksum_file(fn, CheckSum);
  fa.CheckSum := CheckSum;
end;

{$ENDIF usesDC}


function getFirstFlap:word;
//var a,b,c,d:word;
var a,b,c,d: Integer;
begin
  a:=random(65535) and $7FFF;
  b:=a;
  c:=0;
  while a<>0 do begin
    inc(c,a);
    a:=a div 8;
  end;
  d:=b-c;
//  dec(d,c);
  result:=(((((d and $FF) xor (b and $FF))+(d and $FFFFFF00)) and 7) xor b)+3;
end;


function qip_msg_crypt(const s: AnsiString; p: Integer): RawByteString;
//                 текст    пароль
const
  n0=$1B5F;
var
  s5: RawByteString;
  n, l, i:integer;
begin
  Result:=s;
  if p=0 then exit;
  Result:='';
  s5 := '';
  n := n0;
  l := Length(s);
  if l>0 then
   for I := 1 to l do
    begin
      s5 := s5+ AnsiChar(Byte(s[i]) xor byte(n shr 8));
      n:=(Byte(s5[i])+n)*$A8C3+p;
    end;
//  s5:=_005D6FF8(Result); //похоже на кодирование base64
  Result:= Base64EncodeString(s5);
end;

function qip_str2pass(const s: RawByteString): Integer;
var
  l, i : Integer;
begin
  Result := 0;
  l := Length(s);
  if l > 0 then
   begin
     Result := $3E9;
     for I := 1 to l do
      Result := Result+ Byte(s[i]);
   end;
end;

function qip_msg_decr(const s1: RawByteString; p: integer): AnsiString;
const
  n0=$1B5F;
var
  s4 : RawByteString;
//  a,
  n, l : integer;
  I: Integer;
begin
  if p=0 then
   begin
    Result:=s1;
    exit;
   end;
  Result:='';
  n := n0;
//  a:=0;
  s4 := Base64DecodeString(s1); //похоже на декодирование base64
  l := Length(s4);
  if l>0 then
   for I := 1 to l do
    begin
      Result := Result+AnsiChar(Byte(s4[i]) xor byte(n shr 8));
      n := (Byte(s4[i])+n)*$A8C3+p;
    end;
end;

procedure parseImgLinks2(var msg: RawByteString);
var
  msgTmp, sA, imgStr, mime, fileIdStr: RawByteString;
  buf: TMemoryStream;
  strs : TAnsiStringDynArray;
  i, j, p: Integer;
  JSONObject, JSONObject2: TJSONObject;
begin
  if (msg <> '') then
  begin
    msgTmp := msg;
    strs := SplitAnsiString(msgTmp, ' ;,"'''#13#10);
    for i := Low(strs) to High(strs) do
{ TODO -oRapid D : Add parallel downloads }
    if AnsiStartsText('http://', strs[i]) or StartsText('https://', strs[i]) or StartsText('www.', strs[i]) then
    begin
      if AnsiContainsText(strs[i], 'files.icq.net/') then
        begin
          buf := TMemoryStream.Create;
          fileIdStr := AnsiReplaceText(Trim(strs[i]), 'files.icq.net/get/', 'files.icq.com/getinfo?file_id=');
          fileIdStr := AnsiReplaceText(fileIdStr, 'files.icq.net/files/get?fileId=', 'files.icq.com/getinfo?file_id=');
          LoadFromURL(fileIdStr, buf);
          SetLength(imgStr, buf.Size);
          buf.ReadBuffer(imgStr[1], buf.Size);
          buf.Free;
          if imgStr > '' then
           begin
            JSONObject := TJSONObject.ParseJSONValueUTF8(@imgStr[1], 1, length(imgStr)) as TJSONObject;
            if Assigned(JSONObject) then
            begin
              try
                JSONObject2 := TJSONObject.ParseJSONValue(TJSONArray(JSONObject.GetValue('file_list')).Items[0].ToJSON) as TJSONObject;
                sA := JSONObject2.GetValue('dlink').Value + '?no-download=1';
                mime := JSONObject2.GetValue('mime').Value;
                JSONObject2.Free;
               except
              end;
              JSONObject.Free;
            end;

           end;
        end
       else
        sA := Trim(strs[i]);

      if MatchText(mime, ImageContentTypes) or MatchText(HeaderFromURL(sA), ImageContentTypes) then
      begin
        buf := TMemoryStream.Create;
        LoadFromURL(sA, buf);
        SetLength(imgStr, buf.Size);
        buf.ReadBuffer(imgStr[1], buf.Size);
        buf.Free;
        msgTmp := ReplaceText(msgTmp, strs[i], strs[i] + RnQImageExTag + Base64EncodeString(imgStr) + RnQImageExUnTag);
      end;
    end;
  end;

  if not (msgTmp = msg) then
    msg := msgTmp;
end;

function parseTzer2URL(const sA: RawByteString; var sMsg : RawByteString): RawByteString;
var
  p : Integer;
begin
  p := PosEx(AnsiString('name="'), sA);
  sMsg := getTranslation('tZer') + ': ' + copy(sA, p + 6, PosEx(AnsiString('"'), sA, p + 7) - p - 6) + #13#10;
  p := PosEx(AnsiString('url="'), sA);
  sMsg := sMsg + copy(sA, p + 5, PosEx(AnsiString('"'), sA, p + 6) - p - 5) + #13#10;

  p := PosEx(AnsiString('thumb="'), sA);
  Result := copy(sA, p + 7, PosEx(AnsiString('"'), sA, p + 8) - p - 7);
end;

function parseTzerTag(const sA: RawByteString): RawByteString;
var
  p : Integer;
  ext, imgStr: RawByteString;
  buf: TMemoryStream;
begin
  p := PosEx(AnsiString('name="'), sA);
  Result := getTranslation('tZer') + ': ' + copy(sA, p + 6, PosEx(AnsiString('"'), sA, p + 7) - p - 6) + #13#10;
  p := PosEx(AnsiString('url="'), sA);
  Result := Result + copy(sA, p + 5, PosEx(AnsiString('"'), sA, p + 6) - p - 5) + #13#10;
  p := PosEx(AnsiString('thumb="'), sA);
  ext := copy(sA, p + 7, PosEx(AnsiString('"'), sA, p + 8) - p - 7);

  try
    imgStr := '';
    buf := TMemoryStream.Create;
    if LoadFromURL(ext, buf) then
      begin
       SetLength(imgStr, buf.Size);
       buf.ReadBuffer(imgStr[1], buf.Size);
      end;
    buf.Free;

    if Trim(imgStr) = '' then
      imgStr := ext
    else
      imgStr := RnQImageExTag + Base64EncodeString(imgStr) + RnQImageExUnTag;
   except
    imgStr := ext;
  end;
  Result := Result + imgStr + #13#10;
end;


end.

