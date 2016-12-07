{
This file is part of R&Q.
Under same license
}
unit pluginLib;
{$I RnQConfig.inc}

{$IFDEF COMPILER12_UP}
  {$WARN IMPLICIT_STRING_CAST OFF}
  {$WARN IMPLICIT_STRING_CAST_LOSS OFF}
  {$WARN SUSPICIOUS_TYPECAST ERROR}
{$ENDIF}

{$I NoRTTI.inc}

interface

uses
  windows, Graphics, classes, Controls, sysutils, RnQProtocol, //contacts, 
  events, types, strutils, RDGlobal,
 {$IFDEF PROTOCOL_ICQ}
  ICQConsts,
 {$ENDIF PROTOCOL_ICQ}
  RnQButtons, ComCtrls;

{$I plugin.inc }
{ $I pluginutil.inc }

type

  Tplugin = class
   public
    hnd: Thandle;
    screenName,
    filename: String;
    fun: TpluginFun;
    funC: TpluginFunC;
    active: boolean;

    function activate: boolean;
    procedure disactivate;
    function cast(data: RawByteString): RawByteString;
    procedure cast_preferences;
    end;

  Tplugins = class
   private
    enumIdx: integer;
    list: Tlist;
   public
    constructor create;
    destructor Destroy; override;

    procedure resetEnumeration;
    function  hasMore: boolean;
    function  getNext: Tplugin;

    procedure load;
    procedure unload;
    function cast(const data: RawByteString): RawByteString; overload;
    function castEv(ev_id: byte; const uin: TUID; flags: Integer; when: Tdatetime; cl: TRnQCList): RawByteString;  overload;
    function castEv(ev_id: byte; const uin: TUID; flags: Integer; when: Tdatetime): RawByteString; overload;
    function castEv(ev_id: byte; const uin: TUID; flags: Integer; when: Tdatetime; const s1: AnsiString): RawByteString; overload;
    function castEv(ev_id: byte; const uin: TUID; flags: Integer; when: Tdatetime; const s1, s2: AnsiString): RawByteString; overload;
    function castEv(ev_id: byte; when: Tdatetime; const name, addr, text: AnsiString): RawByteString; overload;
    function castEv(ev_id: byte; const uin: TUID; flags: Integer; const s1: AnsiString): RawByteString; overload;
    function castEv(ev_id: byte; const uin: TUID; const s1: AnsiString): RawByteString; overload;
    function castEv(ev_id: byte; const uin: TUID; const s1, s2: AnsiString): RawByteString; overload;
    function castEv(ev_id: byte; const uin: TUID; b1: Byte; const s1, s2: AnsiString): RawByteString; overload;
    function castEv(ev_id: byte; const uin: TUID; status, oldstatus: byte; inv, oldInv: boolean): RawByteString; overload;
    function castEv(ev_id: byte; const uin: TUID): RawByteString; overload;
    function castEv(ev_id: byte; uin: Integer): RawByteString; overload;
    function castEv(ev_id: byte; const uin: TUID; flags: integer; cl: TRnQCList): RawByteString; overload;
    function castEv(ev_id: byte): RawByteString; overload;
    function castEv(ev_id: byte; const s1, s2, s3: AnsiString; b: boolean; i: integer): RawByteString; overload;
    function castEvList(ev_id: byte; list: byte; c: TRnQcontact): RawByteString;
    end;


  TPlugButtons = class
   public
    const minBtnWidth = 21;
   public
    btns: Array of TRnQSpeedButton;
    btnCnt: Integer;
   public
//    ButtonCount: Integer;
//    maxID: Integer;
    PluginsTB: TToolBar;
    function Add(proc: Pointer; iIcon: HIcon; const bHint: String; const sPic: AnsiString = ''): integer;
    procedure Del(bAddr: integer);
    procedure Modify(bAddr: Integer; iIcon: HICON; const bHint: String; const sPic: AnsiString = '');
    procedure onToolMouseDown(Sender: TObject; Button: TMouseButton;
              Shift: TShiftState; X, Y: Integer);
    procedure onToolBtnClick(Sender: TObject);
  end;

implementation

uses
  forms,
  RQUtil, RnQLangs, RQThemes, RnQDialogs, RQLog, RnQTips, RDUtils, RnQGlobal,
  mainDlg, chatDlg, outboxLib, globalLib, utilLib, outboxDlg,
  themesLib, iniLib,
 { $IFDEF RNQ_FULL}
  prefDlg, RnQPrefsLib, RnQBinUtils,
 { $ENDIF RNQ_FULL}
  Protocols_all,
 {$IFDEF PROTOCOL_ICQ}
  ICQContacts,
  icqv9, Protocol_ICQ,
 {$ENDIF PROTOCOL_ICQ}
  pluginutil;

 {$IFDEF PROTOCOL_ICQ}
const
  Status2OldStatus : array [TICQStatus] of byte = (0, 6, 7, 1, 2, 3, 4, 5, 8, 9, 10, 11, 12);
  OldStatus2Status : array [TICQStatus] of byte = (0, 3, 4, 5, 6, 7, 1, 2, 8, 9, 10, 11, 12);
  vis2OldVis : array[Tvisibility] of byte = (2, 0, 1, 3, 4);
  OldVis2Vis : array[Tvisibility] of byte = (1, 2, 0, 3, 4);
 {$ENDIF PROTOCOL_ICQ}

var
//  outBuffer:RawByteString;   // callback result buffer
  outBuffer00: RawByteString;   // callback result buffer


function whatwindow(id: byte): Tform;
begin
case id of
  PW_ROSTER: result := RnQmain;
  PW_CHAT: result := chatFrm;
  PW_PREFERENCES: result := prefFrm;
  else result := NIL;
  end;
end; // whatwindow

function whatlist(id: byte): TRnQCList;
begin
case id of
  PL_ROSTER:         result := Account.AccProto.readList(LT_ROSTER);
  PL_VISIBLELIST:     result := Account.AccProto.readList(LT_VISIBLE);
  PL_INVISIBLELIST:   result := Account.AccProto.readList(LT_INVISIBLE);
  PL_IGNORELIST:      result := ignoreList;
  PL_TEMPVISIBLELIST: result := Account.AccProto.readList(LT_TEMPVIS);
  PL_DB :     result := Account.AccProto.contactsDB;
  PL_NIL :    Result := notInList; // not in list
  else result:=NIL;
  end;
end; // whatlist

procedure addCL2list(id: byte; CL: TRnQCList);
begin
case id of
 {$IFDEF UseNotSSI}
  PL_ROSTER: Account.AccProto.AddToList(LT_ROSTER, cl);
 {$ENDIF UseNotSSI}
  PL_VISIBLELIST:  Account.AccProto.AddToList(LT_VISIBLE, cl);
  PL_INVISIBLELIST:  Account.AccProto.AddToList(LT_INVISIBLE, cl);
//  PL_IGNORELIST:   ICQ.ignoreList;
  PL_TEMPVISIBLELIST: Account.AccProto.AddToList(LT_TEMPVIS, cl);
  PL_DB : Account.AccProto.contactsDB.add(cl);
  PL_NIL : notInList.add(cl); // not in list
//  else result := NIL;
  end;
end; // whatlist

function add2list(id: byte; C: TRnQcontact): Boolean;
begin
 result := True;
 case id of
  PL_ROSTER:         Account.AccProto.AddToList(LT_ROSTER, c);
  PL_VISIBLELIST:     Account.AccProto.AddToList(LT_VISIBLE, c);
  PL_INVISIBLELIST:   Account.AccProto.AddToList(LT_INVISIBLE, c);
  PL_IGNORELIST:     begin result := True; addToIgnorelist(c) end;
  PL_TEMPVISIBLELIST: Account.AccProto.AddToList(LT_TEMPVIS, c);
  PL_DB :             result := Account.AccProto.contactsDB.add(c);
  PL_NIL :            result := notInList.add(c); // not in list
  else result := false;
 end;
end;

function rem_fr_list(id: byte; C: TRnQcontact): Boolean;
begin
 result := True; 
 case id of
  PL_ROSTER:         Account.AccProto.RemFromList(LT_ROSTER, c);
  PL_VISIBLELIST:     Account.AccProto.RemFromList(LT_VISIBLE, c);
  PL_INVISIBLELIST:   Account.AccProto.RemFromList(LT_INVISIBLE, c);
  PL_IGNORELIST: begin result := True; removeFromIgnorelist(c); end;
  PL_TEMPVISIBLELIST: Account.AccProto.RemFromList(LT_TEMPVIS, c);
  PL_DB :             result := Account.AccProto.contactsDB.remove(c);
  PL_NIL :            result := notInList.remove(c); // not in list
  else result := false;
 end;
end;

function _contactinfo(c: TRnQcontact): RawByteString;
begin
if c=NIL then
  begin
  result:='';
  exit;
  end;
 {$IFDEF PROTOCOL_ICQ}
  if c is TICQcontact then
    result:=_int(TICQcontact(c).uinInt)
      +AnsiChar(Status2OldStatus[TICQcontact(c).status]) // For old
      +AnsiChar(TICQcontact(c).invisible)
      +_istring(c.displayed)
      +_istring(c.first)
      +_istring(c.last)
   else
 {$ENDIF PROTOCOL_ICQ}
    result:=_int(StrToIntDef(c.uid2cmp, 0))
      +AnsiChar(0)
      +AnsiChar(0)
      +_istring(c.displayed)
      +_istring(c.first)
      +_istring(c.last);
end; // _contactinfo

function _icontactinfo(c: TRnQcontact): RawByteString;
begin
  result := _istring(_contactinfo(c))
end;

function _get(what: byte): RawByteString;
begin
  result := AnsiChar(PM_GET)+AnsiChar(what)
end;

function _event(what: byte): RawByteString;
begin
  result := AnsiChar(PM_EVENT)+AnsiChar(what)
end;

//function callbackStr(const data: RawByteString): RawByteString; stdcall;
procedure callbackStr3(const data: RawByteString; var res: RawByteString);
var
  resStr: RawByteString;

  function minimum(min: integer): boolean;
  begin
    result := length(data) >= min;
    if not result then
      resStr := AnsiChar(PM_ERROR)+ AnsiCHAR(PERR_BAD_REQ);
  end; // minimum

const
  tenthsPerDay=10*60*60*24;

var
  b: boolean;
  i, k: integer;
  w: Tform;
  bmp: TBitmap;
//  R: TRect;
  cl: TRnQCList;
  cnt: TRnQContact;
  ints: TintegerDynArray;
  rct: TRect;
  tS, tS2: RawByteString;
  sU: String;
  PrefVal: TPrefElement;
begin
  ints := NIL;
  if data='' then
    begin
      resStr := AnsiChar(PM_ACK)+AnsiChar(PA_OK);
//      Result := resStr;
      Res := resStr;
      exit;
    end;

  resStr := AnsiChar(PM_ABORT);
 try

case _byte_at(data,1) of
  PM_CMD: if minimum(2) then
    case _byte_at(data,2) of
      PC_SET_AUTOMSG: if minimum(2+4) then
        setAutoMsg(_istring_at(data,3));
      PC_SEND_MSG: if minimum(2+3*4) then
        begin
//        outbox.add(OE_msg, IntToStr(_int_at(data,3)), _int_at(data,7), _istring_at(data,11));
         Proto_Outbox_add(OE_msg, Account.AccProto.getContact(IntToStr(_int_at(data,3))), _int_at(data,7), _istring_at(data,11));
        end;
      PC_ADD_MSG: if minimum(2+4 + 8+4) then        // By Rapid D
        begin
 {$IFDEF PROTOCOL_ICQ}
         if Account.AccProto.ProtoElem is TicqSession then
         with TICQSession(Account.AccProto.ProtoElem) do
          begin
//           eventContact := Account.AccProto.getContact(IntToStr(_int_at(data,3)));
           eventContact := getICQContact(_int_at(data,3));
           eventTime := _dt_at(data,7);
           eventFlags := 0;
           notificationForMsg(MTYPE_PLAIN,0, TRUE, _istring_at(data, 15));
//          ICQ.notifyListeners();
          end;
 {$ENDIF PROTOCOL_ICQ}
        end;
      PC_POPUP_ADD: if minimum(2+4+4) then        // By Rapid D
        begin
          bmp := TBitmap.Create;
          bmp.Handle := _int_at(data,3);
//          TipAdd(bmp, _int_at(data,7));
          TipAdd3(NIL, bmp, NIL, _int_at(data,7));
//          bmp.ReleaseHandle;
          FreeAndNil(bmp);
        end;
      PC_ADD_TO_INPUT: if minimum(2+4) then        // By Rapid D
        begin
          if (chatFrm.thisChat <> NIL)and(chatFrm.thisChat.chatType = CT_IM) then
           begin
            tS := _istring_at(data, 3);
            sU := UnUTF(tS);
            SU := applyVars(chatFrm.thisChat.who, SU);
            chatFrm.thisChat.input.SelText := SU;
           end;
        end;
      PC_SEND_CONTACTS: if minimum(2+3*4) then
        begin
 {$IFDEF PROTOCOL_ICQ}
         if Account.AccProto.ProtoElem is TicqSession then
          begin
            Proto_Outbox_add(OE_contacts, TicqSession(Account.AccProto.ProtoElem).getICQContact(_int_at(data,3)),
                _int_at(data,7), ints2cl(_intlist_at(data,11)));
          end;
 {$ENDIF PROTOCOL_ICQ}
        end;
      PC_SEND_ADDEDYOU: if minimum(2+4) then
        begin
           Proto_Outbox_add(OE_addedyou, Account.AccProto.getContact(intToStr(_int_at(data,3))));
        end;
 {$IFDEF PROTOCOL_ICQ}
      PC_SEND_AUTOMSG_REQ: if minimum(2+4) then
        sendICQautomsgreq(Account.AccProto.getContact(intToStr(_int_at(data,3))));
 {$ENDIF PROTOCOL_ICQ}
      PC_LIST_REMOVE,
      PC_LIST_ADD: if minimum(2+1+4) then
        begin
        k :=_byte_at(data,3);
//        if cl=NIL then
//          outBuffer:=char(PM_ERROR)+char(PERR_UNEXISTENT)
//        else
          begin
          b:= _byte_at(data,2)=PC_LIST_ADD;
          ints:=_intlist_at(data,4);
          for i:=0 to length(ints)-1 do
            if b then
              begin
              if not add2list(k, Account.AccProto.getContact(intToStr(ints[i]))) then
                ints[i]:=0;
              end
            else
              if not rem_fr_list(k, Account.AccProto.getContact(intToStr(ints[i]))) then
                ints[i]:=0;
          packArray(ints, 0);
          if length(ints)>0 then
            resStr := AnsiChar(PM_ERROR)+AnsiChar(PERR_FAILED_FOR)+_intlist(ints);
          ints:=NIL;
          end;
        end;
      PC_QUIT: MustQuit := True; //quit;
 {$IFDEF PROTOCOL_ICQ}
      PC_SET_STATUS: if minimum(2+1) then
        userSetStatus(Account.AccProto, OldStatus2Status[TICQStatus(_byte_at(data,3))], false);
      PC_SET_VISIBILITY: if minimum(2+1) then
        userSetVisibility(Account.AccProto, oldVis2Vis[TVisibility(_byte_at(data,3))]);
      PC_SET_XSTATUS: if minimum(2+1) then
          begin
            tS := '';
            tS2 := '';
            if length(data)>2+1+4 then
             tS :=_istring_at(data, 2+1 +1);
            if length(data)>2+1+4+4+length(tS) then
             tS2 :=_istring_at(data, 2+1+4+length(tS) +1);
            ChangeXStatus(TicqSession(Account.AccProto.ProtoElem), (_byte_at(data,3)), tS, tS2);
          end;
 {$ENDIF PROTOCOL_ICQ}
      PC_CONNECT: doConnect;
      PC_DISCONNECT: userSetStatus(Account.AccProto, byte(SC_OFFLINE));
      PC_PLAYSOUND  : if minimum(2+4) then        // By Rapid D
             theme.PlaySound(_istring_at(data, 3));
      PC_PLAYSOUNDFN: if minimum(2+4) then        // By Rapid D
             SoundPlay(_istring_at(data, 3));
      PC_SHOWINFO  : if minimum(2+4) then        // By Rapid D
             begin
               cnt := Account.AccProto.getContact(_istring_at(data, 3));
               if Assigned(cnt) then
                 cnt.ViewInfo;
             end;
      PC_OPENCHAT  : if minimum(2+4) then        // By Rapid D
             begin
               cnt := Account.AccProto.getContact(_istring_at(data, 3));
               if Assigned(cnt) then
                 chatFrm.openOn(cnt);
             end;
      PC_ADDBUTTON : if minimum(2+4+4+4) then
          begin
            tS :=_istring_at(data, 11);
            if length(data)>2+4+4+4+length(tS) then
             tS :=_istring_at(data, 2+4+4+4+1+length(tS))
            else
             tS := '';
            resStr := //#00#00#00 + //outBuffer+char(PM_DATA) +
                        _int(chatFrm.plugBtns.Add(Pointer(_int_at(data, 3)),
                              _int_at(data, 7), _istring_at(data, 11), tS)+1);
          end;
      PC_DELBUTTON: if minimum(4) then chatFrm.plugBtns.Del(_int_at(data, 3)-1);
      PC_MODIFY_BUTTON : if minimum(2+4+4+4) then
          begin
            tS :=_istring_at(data, 11);
            if length(data)>2+4+4+4+length(tS) then
             tS :=_istring_at(data, 2+4+4+4+length(tS)+1)
            else
             tS := '';
            chatFrm.plugBtns.Modify(_int_at(data, 3)-1,
                _int_at(data, 7), _istring_at(data, 11), tS);
          end;
      PC_ADDCONTACTMENU : if minimum(2+4) then
          begin
            i := RnQmain.AddContactMenuItem(
                    PCLISTMENUITEM(Pointer(_int_at(data, 2+1))) // Proc
{                _int_at(data, 2+1+4),       // menuIcon
                _istring_at(data, 2+1+4+4),  // menuCaption
                _istring_at(data, 15),  // menuHint
                _int_at(data, 19),      // position
                _istring_at(data, 23),  // PopupName
                _int_at(data, 27),      // popupPosition
                _int_at(data, 31),      // hotKey
                _istring_at(data, 35)   // PicName
}
               );
            {
            tS :=_istring_at(data, 11);
            if length(data)>2+4+4+4+length(tS) then
             tS :=_istring_at(data, 2+4+4+4+1+length(tS))
            else
             tS := '';
            outBuffer := //#00#00#00 + //outBuffer+char(PM_DATA) +
                        _int(chatFrm.plugBtns.Add(Pointer(_int_at(data, 3)),
                              _int_at(data, 7), _istring_at(data, 11), tS)+1);}
            if i > 0 then
              resStr := //#00#00#00 + //outBuffer+
                         AnsiChar(PM_DATA) +_int(i)
             else
              resStr :=AnsiChar(PM_ERROR);
          end;
      PC_MODIFYCONTACTMENU : if minimum(2+4+4) then
          begin
//            i :=
            RnQmain.UpdateContactMenuItem(_int_at(data, 2+1),
                    PCLISTMENUITEM(Pointer(_int_at(data, 2+4+1)))); // Proc
          end;
      PC_DELETECONTACTMENU: if minimum(2+4) then
        RnQmain.DelContactMenuItem(_int_at(data, 3));
{      PC_UNLOAD:
         begin
          unloadPluginName := _istring_at(data, 3);
          unloadPlugin:=True;
         end;}
      PC_RELOAD_THEME: reloadCurrentTheme;
      PC_RELOAD_LANG : reloadCurrentLang;
     //by S@x
      PC_TAB_ADD:
      begin
        //msgDlg(_istring_at(data, 3), mtInformation);
        resStr := _int(CHAT_TAB_ADD(_int_at(data, 3), _int_at(data, 7), _istring_at(data, 11)));
      end;
      PC_TAB_MODIFY:
      begin
        //msgDlg(_istring_at(data, 3), mtInformation);
        CHAT_TAB_MODIFY(_int_at(data, 3), _int_at(data, 7), _istring_at(data, 11));
      end;
      PC_TAB_DELETE:
      begin
        //msgDlg(_istring_at(data, 3), mtInformation);
        CHAT_TAB_DELETE(_int_at(data, 3));
      end;
      else resStr := AnsiChar(PM_ERROR)+AnsiChar(PERR_UNK_REQ);
      end;//case
  PM_GET: if minimum(2) then
    case _byte_at(data,2) of
      PG_USER:
//        if MainProto.myinfo=NIL then
        if Account.AccProto.ProtoElem.MyAccNum='' then
          resStr := AnsiChar(PM_ERROR)+AnsiChar(PERR_NOUSER)
        else
          resStr := AnsiChar(PM_DATA)+_int(StrToIntDef(Account.AccProto.ProtoElem.MyAccNum, 0)) +
                      _istring(Account.AccProto.ProtoElem.MyAccNum);
      PG_DISPLAYED_NAME: resStr := AnsiChar(PM_DATA)+_istring( Account.AccProto.getContact(IntToStrA(_int_at(data,3))).displayed );
      PG_ANDRQ_VER: resStr := AnsiChar(PM_DATA)+_int( RQversion );
      PG_ANDRQ_VER_STR: resStr := AnsiChar(PM_DATA)+_istring( ip2str(RQversion) );
      PG_RNQ_BUILD: resStr := AnsiChar(PM_DATA)+_int( RnQBuild ) + _dt(BuiltTime);
      PG_TIME: resStr := AnsiChar(PM_DATA)+_dt( now );
 {$IFDEF PROTOCOL_ICQ}
      PG_CONTACTINFO:
               if minimum(6) then
                 begin
                    i := _int_at(data,3);
//                   tS := IntToStrA(_int_at(data,3));
//                   outBuffer:=AnsiChar(PM_DATA)+_icontactinfo( Account.AccProto.getContact(tS) );
                   resStr := AnsiChar(PM_DATA)+_icontactinfo( Account.AccProto.getICQContact(i) );
                 end;
 {$ENDIF PROTOCOL_ICQ}
      PG_LIST: if minimum(3) then
        begin
        cl:=whatlist(_byte_at(data,3));
        if cl=NIL then
          resStr :=AnsiChar(PM_ERROR)+AnsiChar(PERR_UNEXISTENT)
        else
          resStr :=AnsiChar(PM_DATA)+_intlist(cl.toIntArray);
        end;

      PG_CHAT_XYZ:
        begin
          //ShowMessage('chat coord request');
          if chatFrm.pagectrl.pagecount = 0 then
           resStr :=AnsiChar(PM_DATA)+_intlist([0,0,0,0])
          else
          begin
            rct:= chatFrm.pagectrl.activepage.boundsrect;
//            if chatFrm.fp.Visible then
            inc(rct.Top, chatFrm.pagectrl.Top);
            //rct.topleft:=  chatFrm.pagectrl.activepage.ClientToScreen(rct.topleft);
            //rct.bottomright:=  chatFrm.pagectrl.activepage.ClientToScreen(rct.bottomright);
            resStr :=AnsiChar(PM_DATA)+_intlist([rct.top,rct.left,rct.right,rct.bottom]);
          end;
        end;

      PG_NOF_UINLISTS: resStr := AnsiChar(PM_DATA)+_int( uinlists.count );
      PG_UINLIST: if minimum(2+4) then
        begin
        i:=_int_at(data,3);
        if (i >= 0) and (i < uinlists.count) then
          resStr:=AnsiChar(PM_DATA)+_intlist( uinlists.getAt(i).cl.toIntArray )
        else
          resStr:=AnsiChar(PM_ERROR)+ AnsiChar(PERR_UNEXISTENT);
        end;
      PG_AWAYTIME:
        if Account.AccProto.getMyInfo=NIL then
          resStr := AnsiChar(PM_ERROR)+ AnsiCHAR(PERR_NOUSER)
        else
          resStr := AnsiChar(PM_DATA)+_dt( autoaway.time/tenthsPerDay );
      PG_ANDRQ_PATH: resStr:=AnsiChar(PM_DATA)+_istring( mypath );
      PG_USERTIME:
        if Account.AccProto.getMyInfo=NIL then
          resStr := AnsiChar(PM_ERROR)+AnsiChar(PERR_NOUSER)
        else
          resStr := AnsiChar(PM_DATA)+_dt( usertime/tenthsPerDay );
      PG_USER_PATH:
        if Account.AccProto.getMyInfo=NIL then
          resStr := AnsiChar(PM_ERROR)+AnsiChar(PERR_NOUSER)
        else
          resStr := AnsiChar(PM_DATA)+_istring( AccPath );
      PG_CONNECTIONSTATE:
        if Account.AccProto.isOnline then
          resStr := AnsiChar(PM_DATA)+AnsiChar( PCS_CONNECTED )
        else
          if Account.AccProto.isOffline then
            resStr := AnsiChar(PM_DATA)+AnsiChar( PCS_DISCONNECTED )
          else
            resStr := AnsiChar(PM_DATA)+AnsiChar( PCS_CONNECTING );
      PG_WINDOW:
        begin
        w:=whatwindow(_byte_at(data,3));
        if w=NIL then
          resStr := AnsiChar(PM_ERROR)+AnsiChar(PERR_UNEXISTENT)
        else
          resStr := AnsiChar(PM_DATA)+_int([ w.handle, w.left, w.top, w.width, w.height ]);
        end;
      PG_AUTOMSG: resStr := AnsiChar(PM_DATA)+_istring(automessages[0]);
      PG_CHAT_UIN:
          begin
            sU := chatFrm.thisChatUID;
            if sU > '' then
              resStr := AnsiChar(PM_DATA)+_int(StrToIntDef(sU, 0)) + _istring(sU)
             else
              resStr := AnsiChar(PM_ERROR)+_int(0);
          end;
      PG_TRANSLATE:
        resStr := AnsiChar(PM_DATA) + _istring(getTranslation(_istring_at(data, 3)));
      PG_THEME_PIC:
          begin
            bmp := TBitmap.Create;
            if theme.GetPicOld(LowerCase(_istring_at(data, 3)), bmp) then
              resStr := AnsiChar(PM_DATA) + _int(bmp.ReleaseHandle)
             else
              resStr := AnsiChar(PM_ERROR);
            FreeAndNil(bmp);
          end;
      PG_PREF_VALUE:  { TODO : Сделать PG_PREF_VALUE !!!! }
          begin
            if minimum(2+4) then
              begin
                tS := _istring_at(data, 3);
                PrefVal := MainPrefs.getPrefVal(tS);
                if PrefVal <> NIL then
                  begin
                    resStr := AnsiChar(PM_DATA) + AnsiChar(PrefVal.ElType) +
                                 _istring(PrefVal.AsBlob);
                    PrefVal.Free;
                  end
                 else
                  resStr := AnsiChar(PM_ABORT);
              end
             else
              resStr := AnsiChar(PM_ABORT);
          end;
      PG_STATUS:
          begin
 {$IFDEF PROTOCOL_ICQ}
            if Assigned(Account.AccProto) then
             begin
              if Account.AccProto.ProtoElem is TICQSession then
                begin
                  resStr := AnsiChar(PM_DATA) + AnsiChar(Status2OldStatus[TICQStatus(Account.AccProto.getStatus)])
                     + AnsiChar(vis2OldVis[TICQSession(Account.AccProto.ProtoElem).visibility])
                     + AnsiChar(TICQSession(Account.AccProto.ProtoElem).curXStatus);
                  if TICQSession(Account.AccProto.ProtoElem).curXStatus > 0 then
                    resStr := resStr
                     + _istring(ExtStsStrings[TICQSession(Account.AccProto.ProtoElem).curXStatus].Cap)
                     + _istring(ExtStsStrings[TICQSession(Account.AccProto.ProtoElem).curXStatus].Desc)
                   else
                    resStr := resStr + _istring('') + _istring('');
                end
               else
                  resStr := AnsiChar(PM_DATA) + AnsiChar(Status2OldStatus[TICQStatus(Account.AccProto.getStatus)])
                     + AnsiChar(vis2OldVis[Tvisibility(Account.AccProto.getVisibility)])
                     + AnsiChar(0) + _istring('') + _istring('');
             end
            else
 {$ENDIF PROTOCOL_ICQ}
             resStr := AnsiChar(PM_ERROR);
          end;
      PG_XSTATUS:
          begin
 {$IFDEF PROTOCOL_ICQ}
             if minimum(2+1) then
               i := byte(data[3])
              else
               i := $FF;
            if not (i in [Low(XStatusArray)..High(XStatusArray)]) then
             i := TICQSession(Account.AccProto.ProtoElem).curXStatus;
            resStr := AnsiChar(PM_DATA) + AnsiChar(byte(i)) +
                         _istring(getTranslation(ExtStsStrings[i].Cap)) +
                         _istring(getXStatusMsgFor(nil));
 {$ENDIF PROTOCOL_ICQ}
          end;
       else resStr := AnsiChar(PM_ERROR)+AnsiChar(PERR_UNK_REQ);
      end;//case
  else resStr := AnsiChar(PM_ERROR)+AnsiChar(PERR_UNK_REQ);
  end;//case
 finally
//   result:=resStr;
   res:=resStr;
 end;
end; // callbackStr

    {$WARN UNSAFE_CODE OFF}
function callback(data: Pinteger): pointer; stdcall;
var
  s, s2: RawByteString;
  ppp: TThreadProcedure;
begin
  result := NIL;
  if data=NIL then
    exit;
//  FoutBufferCS.Acquire;
//  try
    setlength(s, data^);
    if Length(s) > 0 then
      begin
       inc(data);
       move(data^, s[1], length(s));
      end;
//    ppp := TThreadProcedure((@RunCBS));

    ppp :=   procedure
              begin
//                s2 := callbackStr2(s);
                callbackStr3(s, s2);
              end;
    try
      TThread.Synchronize(NIL, ppp);
     except
      s2 := AnsiChar(PM_ABORT);
    end;

    //    callbackStr(s);
    outBuffer00 := _int(length(s2)) + s2;
    result := @outBuffer00[1];
//   finally
//    FoutBufferCS.Release;
//  end;
end; // callback

////////////////////////////////////////////////////////////////////////

function Tplugin.activate: boolean;
var
  s: RawByteString;
begin
  result := FALSE;
  if active then
    exit;
  loggaEvtS(filename+': loading');
  hnd := LoadLibrary(PChar(myPath+pluginsPath+filename));
//  hnd := LoadLibraryEx(PChar(myPath+pluginsPath+filename));
  if hnd=0 then
    exit;
  fun := GetProcAddress(hnd, PAnsiChar('pluginFun'));
  if not assigned(fun) then
    fun := GetProcAddress(hnd, '_pluginFun');
  if assigned(fun) then
    loggaEvtS(filename+': found pluginFun');
  funC := GetProcAddress(hnd,'pluginFunC');
  if not assigned(funC) then
    funC := GetProcAddress(hnd,'_pluginFunC');
  if assigned(funC) then
    loggaEvtS(filename+': found pluginFunC');
  if not assigned(fun) and not assigned(funC) then
   begin
    loggaEvtS(filename+': neither pluginFun and pluginFunC found');
    freeLibrary(hnd);
    exit;
   end;
  active := TRUE;
  screenName := filename;
  //fun(NIL);
  loggaEvtS(filename+': initializing');
  s := cast(_event(PE_INITIALIZE)
    +_int(integer(@callback))+_int(APIversion)
    +_istring(myPath)+_istring(AccPath)+_int(StrToIntDef(lastUser, 0))
  );
  if (s>'') then
   if (ord(s[1])=PM_DATA) then
    begin
     screenName := _istring_at(s,2);
     loggaEvtS(filename+': name: '+screenname);
    end
   else
   if (ord(s[1])=PM_ABORT) then
    begin
     result := False;
     try
       freeLibrary(hnd);
       hnd := 0;
      except
     end;
     exit;
    end;
  result := TRUE;
end; // activate

procedure Tplugin.disactivate;
begin
  if not active then
    exit;
  try
   loggaEvtS(filename+': disactivating');
   cast(_event(PE_FINALIZE));
   Application.ProcessMessages;
   Application.ProcessMessages;
  except
   loggaEvtS(filename+': ERROR on disactivating!!!!', IconNames[mtError]);
  end;
  try
    freeLibrary(hnd);
  except
   loggaEvtS(filename+': ERROR on freing!!!!', IconNames[mtError]);
  end;
  hnd := 0; fun := NIL; funC := NIL;
  active := FALSE;
end; // disactivate

function Tplugin.cast(data: RawByteString): RawByteString;
var
  p: Pinteger;
begin
  result := '';
  if not active or not (assigned(fun) or assigned(funC)) then
    exit;
  data := _int(length(data))+data;
  p := nil;
//loggaEvt(format('%s: sending %d bytes',[filename,length(data)]));
 try
  if assigned(fun) then
    p := fun(@data[1])
  else
    p := funC(@data[1]);
 except
   on E: Exception do
    msgDlg(getTranslation('Error at plugin "%s": %s', [screenName, e.Message]), False, mtError);
   else
    msgDlg(getTranslation('Error at plugin "%s"', [screenName]), False, mtError);
//   msgDlg(getTranslation('Error at plugin "%s"', [screenName]), mtError);
 end;
if assigned(p) then
  begin
  //loggaEvt(format('%s: received %d bytes',[filename,p^]));
  try
   setlength(result, p^);
   inc(p);
   move(p^, result[1], length(result));
  except
   setlength(result, 0);
   result := '';
   msgDlg(getTranslation('Error at plugin "%s"', [screenName]), False, mtError);
  end;
  end;
end; // cast
    {$WARN UNSAFE_CODE ON}

procedure Tplugin.cast_preferences;
begin cast(_event(PE_PREFERENCES)) end;

///////////////////////////////////////////////////////////////////////

constructor Tplugins.create;
begin
  list := Tlist.create;
end; // create

destructor Tplugins.Destroy;
begin
  unload;
  list.free;
end; // destroy

procedure Tplugins.resetEnumeration;
begin enumIdx:=0 end;

function Tplugins.hasMore: boolean;
begin result := enumIdx<list.count end;

    {$WARN UNSAFE_CAST OFF}
function Tplugins.getNext: Tplugin;
begin
  result := Tplugin(list[enumIdx]);
  inc(enumIdx);
end; // getNext

procedure Tplugins.load;
var
  sr: TsearchRec;
  plugin: Tplugin;
begin
loggaEvtS('scanning for plugins: '+myPath+pluginsPath+'*.dll');
if findFirst(myPath+pluginsPath+'*.dll', faAnyFile, sr) = 0 then
  repeat
  plugin := Tplugin.create;
  list.add(plugin);
  with plugin do
    begin
    filename := sr.name;
    screenName := '';
    if ansiContainsText(disabledPlugins, filename) then
      loggaEvtS(filename+': skipped (disabled)')
    else
      if activate then
        loggaEvtS(filename+': activated')
      else
        begin
        loggaEvtS(filename+': activation failed');
        list.Remove(plugin);
        plugin.free;
        end;
    end;
  until findNext(sr) <> 0;
findClose(sr);
loggaEvtS('scanning end');
end; // load

procedure Tplugins.unload;
var
  s: String;
  pl: Tplugin;
begin
  while list.count > 0 do
  try
    pl := Tplugin(list.last);
    s := pl.screenName + ' (' + pl.filename + ')';
    pl.disactivate;
    pl.free;
    list.delete(list.count-1);
   except
      loggaEvtS('Error in unloading ' + s);
  end;
end; // unload
    {$WARN UNSAFE_CAST ON}

function Tplugins.cast(const data: RawByteString): RawByteString;
var
  plugin: Tplugin;
begin
  result := '';
  resetEnumeration;
  while hasMore do
   begin
    plugin := getNext;
    result := result + plugin.cast(data);
   end;
end; // cast

function Tplugins.castEv(ev_id: byte; const s1, s2, s3: AnsiString; b: boolean; i: integer): RawByteString;
begin result := cast( AnsiChar(PM_EVENT)+AnsiChar(ev_id)+_istring(s1)+_istring(s2)+_istring(s3)+AnsiChar(b)+_int(i)) end;

function Tplugins.castEv(ev_id: byte; const uin: TUID; flags: integer; when: Tdatetime; cl: TRnQCList): RawByteString;
begin result := cast( AnsiChar(PM_EVENT)+AnsiChar(ev_id)+_int(StrToIntDef(uin, 0))+_int(flags)+_dt(when)+_intlist(cl.toIntArray) ) end;

function Tplugins.castEv(ev_id: byte; const uin: TUID; flags: integer; when: Tdatetime): RawByteString;
begin result := cast( AnsiChar(PM_EVENT)+AnsiChar(ev_id)+_int(StrToIntDef(uin, 0))+_int(flags)+_dt(when) ) end;

function Tplugins.castEV(ev_id: byte; const uin: TUID; flags: integer; when: Tdatetime; const s1: AnsiString): RawByteString;
begin result := cast( AnsiChar(PM_EVENT)+AnsiChar(ev_id)+_int(StrToIntDef(uin, 0))+_int(flags)+_dt(when)+_istring(s1) ) end;

function Tplugins.castEv(ev_id: byte; const uin: TUID; flags: integer; when: Tdatetime; const s1, s2: AnsiString): RawByteString;
begin result := cast( AnsiChar(PM_EVENT)+AnsiChar(ev_id)+_int(StrToIntDef(uin, 0))+_int(flags)+_dt(when)+_istring(s1)+_istring(s2) ) end;

function Tplugins.castEv(ev_id: byte; when: Tdatetime; const name, addr, text: AnsiString): RawByteString;
begin result := cast( AnsiChar(PM_EVENT)+AnsiChar(ev_id)+_dt(when)+_istring(name)+_istring(addr)+_istring(text) ) end;

function Tplugins.castEv(ev_id: byte; const uin: TUID; flags: integer; const s1: AnsiString): RawByteString;
begin result := cast( AnsiChar(PM_EVENT)+AnsiChar(ev_id)+_int(StrToIntDef(uin, 0))+_int(flags)+_istring(s1) ) end;

function Tplugins.castEv(ev_id: byte; const uin: TUID; const s1: AnsiString): RawByteString;
begin result := cast( AnsiChar(PM_EVENT)+AnsiChar(ev_id)+_int(StrToIntDef(uin, 0))+_istring(s1) ) end;

function Tplugins.castEv(ev_id: byte; const uin: TUID; const s1, s2: AnsiString): RawByteString;
begin result := cast( AnsiChar(PM_EVENT)+AnsiChar(ev_id)+_int(StrToIntDef(uin, 0))+_istring(s1)+_istring(s1) ) end;

function Tplugins.castEv(ev_id: byte; const uin: TUID; b1: Byte; const s1, s2: AnsiString): RawByteString;
begin result := cast( AnsiChar(PM_EVENT)+AnsiChar(ev_id)+_int(StrToIntDef(uin, 0)) + AnsiChar(b1) +_istring(s1)+_istring(s2) ) end;

function Tplugins.castEv(ev_id: byte; const uin: TUID; status, oldstatus: byte; inv, oldInv: boolean ): RawByteString;
begin
  result := cast( AnsiChar(PM_EVENT)+AnsiChar(ev_id)+_int(StrToIntDef(uin, 0))
 {$IFDEF PROTOCOL_ICQ}
        +AnsiChar(Status2OldStatus[TICQStatus(status)])+AnsiChar(Status2OldStatus[TICQStatus(oldstatus)])
 {$ELSE ~PROTOCOL_ICQ}
//        +AnsiChar(0)+AnsiChar(0)
        +AnsiChar(status)+AnsiChar(oldstatus)
 {$ENDIF PROTOCOL_ICQ}
        +AnsiChar(inv)+AnsiChar(oldInv) )
end;

function Tplugins.castEv(ev_id: byte; const uin: TUID; flags: integer; cl: TRnQCList): RawByteString;
begin result:=cast( AnsiChar(PM_EVENT)+AnsiChar(ev_id)+_int(StrToIntDef(uin, 0))+_int(flags)+_intlist(cl.toIntArray) ) end;

function Tplugins.castEv(ev_id: byte; const uin: TUID): RawByteString;
begin result := cast( AnsiChar(PM_EVENT)+AnsiChar(ev_id)+_int(StrToIntDef(uin, 0)) ) end;

function Tplugins.castEv(ev_id: byte; uin: Integer): RawByteString;
begin result := cast( AnsiChar(PM_EVENT)+AnsiChar(ev_id)+_int(uin) ) end;

function Tplugins.castEv(ev_id: byte): RawByteString;
begin result := cast( AnsiChar(PM_EVENT)+AnsiChar(ev_id) ) end;

function Tplugins.castEvList(ev_id: byte; list: byte; c: TRnQContact): RawByteString;
begin result := cast( AnsiChar(PM_EVENT)+AnsiChar(ev_id)+AnsiChar(list)+_intlist([StrToIntDef(c.uid2cmp, 0)]) ) end;


function TPlugButtons.Add(proc: Pointer; iIcon: HIcon;
                          const bHint: String; const sPic: AnsiString): integer;
var
  i: Integer;
begin
  i := Length(btns);
  SetLength(btns, i+1);
  btns[i] := TRnQSpeedButton.Create(PluginsTB);
  btns[i].OnMouseDown := onToolMouseDown;
  btns[i].OnClick := onToolBtnClick;
  btns[i].Parent := PluginsTB;
  btns[i].GroupIndex := 0;

//  btns[i].GroupIndex := -1;
  btns[i].Tag := Integer(proc);
  btns[i].ShowHint := false;
  btns[i].Flat := true;
  btns[i].Transparent := false;
  if sPic = '' then
    btns[i].ImageName := AnsiString('pluginbtn') + AnsiString(IntToStr(i))
   else
    btns[i].ImageName := sPic;
//  btns[i].NumGlyphs := 1;
  Modify(i, iIcon, bHint, sPic);
  btns[i].top := (chatFrm.panel.clientheight-btns[i].height) div 2;
//  theme.addProp(btns[i].ImageName, TP_pic,
//  btns[i].width:=btns[i].Glyph.width+5;
  if btns[i].width < minBtnWidth then
    btns[i].width := minBtnWidth;
//  btns[i].Constraints.MaxHeight := 21;
//  btns[i].Constraints.MinHeight := 21;
{  if chatFrm.tbPlugins.ButtonCount = 0 then
    begin
      vtb := TToolButton.Create(chatFrm.tbPlugins);
      vtb.Style := tbsSeparator;
      vtb.Parent := chatFrm.tbPlugins;
    end;}
  btns[i].Left := PluginsTB.Width;
//  chatFrm.tbPlugins.FlipChildren(true);
//  toolbar.Buttons[0] := toolbar.ButtonCount;
//  vToolBut.index := toolbar.ButtonCount;
//  chatFrm.tbPlugins.bu
//  .Buttons[0].Index := 1;
//  InsertComponent(vToolBut);
  INC(btnCnt);
  result := i;
end;

procedure TPlugButtons.Del(bAddr: integer);
var
  i : Integer;
begin
// deBUG!!!!!!!
  i := bAddr;// - 1;
  if (i < Low(btns)) or (i > High(btns)) then
    Exit;
  if btns[i] <> NIL then
   begin
//     theme.delPic(btns[i].ImageName);
     btns[i].Visible := false;
     btns[i].ImageName := '';
     btns[i].Free;
   end;
  btns[i] := NIL;
  DEC(btnCnt);
//  if btnCnt = 0 then

{  while (i = length(btns)) AND(length(btns) > 0) AND btns[bAddr] = NIL do
   begin
    SetLength(btns, i-1);
    theme.delPic(btns[i].ImageName);
    dec(i);
   end;
{  if chatFrm.tbPlugins.ButtonCount = 1 then
    chatFrm.tbPlugins.Buttons[0].Free;}
end;

procedure TPlugButtons.Modify(bAddr: Integer; iIcon: HICON; //THandle;
                              const bHint: String; const sPic: AnsiString);
var
  i: Integer;
  w: Integer;
begin
 i := bAddr; // - 1;
  if (i < Low(btns)) or (i > High(btns)) then
    Exit;
 if btns[i] <> NIL then
 begin
  if iIcon <> 0 then
   begin
    if sPic <> '' then
      theme.addHIco(sPic, iIcon, True)
     else
      theme.addHIco(btns[i].ImageName, iIcon, True);
    w := theme.getPicSize(RQteButton, btns[i].ImageName, 16).cx + 5;
    w := bound(w+5, 16+5, btns[i].height+2);
    btns[i].width := w;
   end;
  if sPic <> '' then
     btns[i].ImageName := sPic;
  if bHint <> '' then
    btns[i].Hint := getTranslation(bHint);
  btns[i].Repaint;  
 end;
end;


procedure TPlugButtons.onToolMouseDown(Sender: TObject; Button: TMouseButton;
    Shift: TShiftState; X, Y: Integer);
var
  pr: procedure(button: integer);
//  St : boolean;
begin
  if Button = mbLeft then
   exit;
  pr := Pointer(TRnQSpeedButton(Sender).Tag);
  try
   pr(Integer(Button));
  except
   msgDlg(getTranslation('Error at plugin "%s"', [TRnQSpeedButton(Sender).Hint]), False, mtError);
  end;
end;

procedure TPlugButtons.onToolBtnClick(Sender: TObject);
var
  pr: procedure(button: integer);
begin
  pr := Pointer(TRnQSpeedButton(Sender).Tag);
  try
   pr(Integer(mbLeft));
  except
   msgDlg(getTranslation('Error at plugin "%s"', [TRnQSpeedButton(Sender).Hint]), False, mtError);
  end;
end;

end.

