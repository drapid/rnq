unit RnQMacros;
{$I RnQConfig.inc}
{$I NoRTTI.inc}

interface

uses
  windows, graphics, types, Menus, classes, RDGlobal;

type
  Tmacro = record
    hk: Tshortcut;
    sw: boolean;
    opcode: integer;
    data: RawByteString;
   end;
  Tmacros = array of Tmacro;
  TRnQMACROS = record
    Name: String;
    Cptn: String;
    DefShortCut: String;
    ev: procedure;
  end;

  TRnQbtn = record
    Name,
    Cptn,
    Hint: String;
    ImageName: TPicName;
//    DefShortCut: String;
    ev: procedure;
  end;


  function  InitMacroses: Boolean;

  function  removeMacro(i: integer): boolean;
  function  findHK(hk: Tshortcut): integer;
  function  addMacro(hk: Tshortcut; sw: boolean; op: integer): boolean;
  procedure executeMacro(m: integer);
// convert
  procedure str2macros(s: RawByteString; var m: Tmacros);
  function  str2macro(s: RawByteString): Tmacro;
  function  macros2str(m: Tmacros): RawByteString;

  procedure popupMenu(m: Tpopupmenu);

  procedure popupHintByMacro();
  procedure toggleAutosize;
  procedure toggleShowGroups;
  procedure startMenuViaMacro;
  procedure stopMenuViaMacro;
  procedure MacroBossMode;


//var
//  chatButtons : array[0..0] of TRnQbtn;

implementation
uses
  forms,
  RQUtil, RDUtils, RnQSysUtils, RnQBinUtils, RnQLangs, RnQGlobal,
  RnQGraphics32, tipDlg,
  roasterLib, utilLib, RnQConst, globalLib, iniLib, themesLib,
 {$IFDEF RNQ_PLAYER}
   uSimplePlayer,
 {$ENDIF RNQ_PLAYER}
  mainDlg, RnQTips, chatDlg, addContactDlg,
  Protocols_all,
  RnQProtocol;
{const
  macroses : array[0..34] of TRnQMACROS = (
  (   Name:'chat'; Cptn:'show/hide chat window'; DefShortCut:'ctrl+shift+o'; ev:),
    ( Name:'roaster'; Cptn:'show/hide contact list'; DefShortCut:''),
    ( Name:'tray'; Cptn:'simulate double-click on tray'; DefShortCut:'ctrl+shift+i'),
    ( Name:'clear event'; Cptn:'clear event'; DefShortCut:''),
    ( Name:'clear events'; Cptn:'clear all events'; DefShortCut:''),
    ( Name:'pop event'; Cptn:'pop event'; DefShortCut:''; ev: chopAndRealizeEvent),
    ( Name:'quit'; Cptn:'quit'; DefShortCut:''),
    ( Name:'shutdown'; Cptn:'shutdown the computer'; DefShortCut:''),
    ( Name:'groups'; Cptn:'show/hide groups'; DefShortCut:''),
    ( Name:'main menu'; Cptn:'pop up main menu'; DefShortCut:''),
    ( Name:'status menu'; Cptn:'pop up status menu'; DefShortCut:''),
    ( Name:'visibility menu'; Cptn:'pop up visibility menu'; DefShortCut:''),
    ( Name:'browser'; Cptn:'open browser'; DefShortCut:''),
    ( Name:'offline contacts'; Cptn:'show/hide offline contacts'; DefShortCut:''),
    ( Name:'autosize'; Cptn:'toggle autosize'; DefShortCut:''),
    ( Name:'connect'; Cptn:'connect'; DefShortCut:''),
    ( Name:'cd play'; Cptn:'play audio cd'; DefShortCut:''),
    ( Name:'cd stop'; Cptn:'stop/eject audio cd'; DefShortCut:''),
    ( Name:'view info'; Cptn:'show contact info'; DefShortCut:''),
    ( Name:'by uin'; Cptn:'show ''add by uin'' dialog'; DefShortCut:''),
    ( Name:'wp'; Cptn:'show white-pages'; DefShortCut:''),
    ( Name:'toggle border'; Cptn:'toggle contact list border'; DefShortCut:''),
    ( Name:'preferences'; Cptn:'show preferences'; DefShortCut:''),
    ( Name:'lock'; Cptn:'lock'; DefShortCut:''),
    ( Name:'show hint'; Cptn:'contact tip pop up'; DefShortCut:''; ev: popupHintByMacro),
    ( Name:'tip'; Cptn:'simulate double-click on tip message'; DefShortCut:''),
    ( Name:'reload theme'; Cptn:'reload theme'; DefShortCut:''; ev=reloadCurrentTheme),
    ( Name:'reload language'; Cptn:'reload language'; DefShortCut:''),
    ( Name:'visible to'; Cptn:'visible to selected contact'; DefShortCut:''),
    ( Name:'toggle sound'; Cptn:'sound on/off'; DefShortCut:''),
//( Name:''; Cptn:''; DefShortCut:''),

    ( Name:'RnQPlay'; Cptn:'Play'; DefShortCut:'ctrl+shift+ins'),
    ( Name:'RnQPause'; Cptn:'Pause'; DefShortCut:'ctrl+shift+home'),
    ( Name:'RnQStop'; Cptn:'Stop'; DefShortCut:'ctrl+shift+end'),
    ( Name:'RnQNext'; Cptn:'Next'; DefShortCut:'ctrl+shift+pgdn'),
    ( Name:'RnQPrev'; Cptn:'Prev'; DefShortCut:'ctrl+shift+pgup')
   );
}

procedure executeMacro(m: integer);
var
//  s: string;
  c: TRnQContact;
begin
  if BossMode.isBossKeyOn and askPassOnBossKeyOn
      and Assigned(Account.AccProto) and (Length(Account.AccProto.pwd) > 0)
      and (m <> OP_BOSSKEY) then
    Exit;

//  if m in [OP_CHAT, OP_ROASTER, OP_TRAY, OP_QUIT, op] then

case m of
  OP_CHAT:
    if chatFrm.isVisible then
      begin
      chatFrm.close;
      restoreForeWindow;
      end
    else
      if chatFrm.chats.count > 0 then
        begin
        oldForeWindow:=getForegroundWindow;
        bringForeground:=chatFrm.handle;
        chatFrm.open;
        end;
  OP_ROSTER: RnQmain.toggleVisible;
  OP_TRAY: trayAction;
  OP_CLEAREVENT:
    begin
    if not (chatFrm.isVisible and chatFrm.sawAllHere) and not eventQ.empty then
      eventQ.pop.free;
    TipsHideAll;
//    tipFrm.hide();
    end;
  OP_CLEAREVENTS:
    begin
    eventQ.clear;
    TipsHideAll;
//    tipfrm.hide();
    end;
  OP_POPEVENT: chopAndRealizeEvent;
  OP_QUIT: RnQmain.close;
  OP_SHUTDOWN: ExitWindows(0,0);
  OP_GROUPS: toggleShowGroups;
  OP_MAINMENU: popupMenu(RnQmain.menu);
  OP_STATUSMENU: popupMenu(RnQmain.statusMenuNEW);
  OP_VISIBILITYMENU: if Assigned(RnQmain.vismenuExt) then popupMenu(RnQmain.vismenuExt);
  OP_BROWSER: openURL(' ');
  OP_OFFLINECONTACTS: toggleOnlyOnline;
  OP_AUTOSIZE: toggleAutosize;
  OP_CONNECT: doConnect;
{  OP_CD_PLAY:
    begin
    if sendMCIcommand('status cdaudio mode')='open' then
      sendMCIcommand('set cdaudio door closed');
    sendMCIcommand('play cdaudio');
    end;
  OP_CD_STOP:
    begin
    if s='playing' then
      sendMCIcommand('stop cdaudio')
    else
      if s='open' then
        sendMCIcommand('set cdaudio door closed')
      else
        sendMCIcommand('set cdaudio door open');
    end;}
  OP_VIEWINFO:
       begin
         if Assigned(clickedContact) then
           clickedContact.ViewInfo
       end;
  OP_ADDBYUIN: RnQmain.byUIN1Click(NIL);//showForm(addContactFrm);
  OP_WP: Account.AccProto.ShowWP;
  OP_TOGGLEBORDER: toggleMainfrmBorder;
  OP_PREFERENCES: showForm(WF_PREF);
  OP_LOCK: doLock;
  OP_HINT: popupHintByMacro();
{  OP_TIP:
    begin
    tipFrm.actionCount:=1;
    tipFrm.action:=TA_2lclick;
    end;}
  OP_RELOADTHEME: reloadCurrentTheme();
  OP_RELOADLANG: reloadCurrentLang();
  OP_VISIBLE_TO:
    begin
      c := focusedContact;
      if (c=NIL) or c.imVisibleTo then
        exit;
      c.fProto.AddToList(LT_TEMPVIS, c);
      roasterLib.redraw(c);
    end;
  OP_TOGGLE_SOUND:
    begin
    playSounds := not playSounds;
//    saveCFG;
    saveCfgDelayed := True;
    end;
 {$IFDEF RNQ_PLAYER}
  OP_PLR_PLAY:
    begin
      if Assigned(RnQPlayer) then
       RnQPlayer.btnPlayClick(NIL);
    end;
  OP_PLR_PAUSE:
      if Assigned(RnQPlayer) then
       RnQPlayer.btnPauseClick(NIL);
  OP_PLR_STOP:
      if Assigned(RnQPlayer) then
       RnQPlayer.btnStopClick(NIL);
  OP_PLR_NEXT:
      if Assigned(RnQPlayer) then
       RnQPlayer.btnNextClick(NIL);
  OP_PLR_PREV:
      if Assigned(RnQPlayer) then
       RnQPlayer.btnPrevClick(NIL);
  OP_PLR_ADD:
      if Assigned(RnQPlayer) then
       RnQPlayer.btnAddClick(NIL);
 {$ENDIF RNQ_PLAYER}
  OP_BOSSKEY:  MacroBossMode;
  OP_RESTARTRNQ: RnQmain.ReStart(nil);
  OP_SEARCHALLHISTORY : showForm(WF_SEARCH);
  end;
end; // executeMacro

function  InitMacroses : Boolean;
begin
  setlength(macros, 0);
  addMacro(TextToShortCut('ctrl+shift+i'), TRUE, OP_TRAY);
  addMacro(TextToShortCut('ctrl+shift+o'), TRUE, OP_CHAT);
  addMacro(TextToShortCut('ctrl+o'), FALSE, OP_OFFLINECONTACTS);
  addMacro(TextToShortCut('ctrl+g'), FALSE, OP_GROUPS);
  addMacro(TextToShortCut('ctrl+a'), FALSE, OP_AUTOSIZE);
  addMacro(TextToShortCut('ctrl+p'), FALSE, OP_PREFERENCES);
  addMacro(TextToShortCut('alt+i'), FALSE, OP_VIEWINFO);
  addMacro(TextToShortCut('F11'), FALSE, OP_TOGGLEBORDER);
  addMacro(TextToShortCut('F3'), FALSE, OP_HINT);
  addMacro(TextToShortCut('ctrl+shift+m'), FALSE, OP_MAINMENU);
  result := True;
end;

function removeMacro(i:integer):boolean;
begin
result:=(i>=0) and (i<length(macros));
if result then
  begin
  while i<length(macros)-1 do
    begin
    macros[i]:=macros[i+1];
    inc(i);
    end;
  setLength(macros, i);
  end;
end; // removeMacro

function findHK(hk:Tshortcut):integer;
begin
for result:=0 to length(macros)-1 do
  if macros[result].hk = hk then
    exit;
result:=-1;
end; // findHK

function addMacro(hk:Tshortcut; sw:boolean; op:integer):boolean;
var
  i:integer;
begin
if hk=0 then
  begin
  result:=FALSE;
  exit;
  end;
i:=findHK(hk);
result:=i<0;
if result then
  begin
  i:=length(macros);
  setLength(macros, i+1);
  end;

macros[i].hk:=hk;
macros[i].sw:=sw;
macros[i].opcode:=op;
end; // addMacro

const
  MFK_HK=1;
  MFK_SW=2;
  MFK_OP=3;

function macro2str(m:Tmacro):RawByteString;
begin
result:=
  TLV2(MFK_HK, int2str(m.hk))
 +TLV2(MFK_SW, bool2str(m.sw))
 +TLV2(MFK_OP, int2str(m.opcode))
end; // macro2str

function str2macro(s: RawByteString):Tmacro;
var
  t, l: integer;
  d: AnsiString;
begin
  while s > '' do
   begin
    t := dword_LEat(@s[1]); // 1234
    l := dword_LEat(@s[5]); // 5678
    d := copy(s,9,l);
    case t of
      MFK_HK: result.hk := str2int(d);
      MFK_SW: result.sw := boolean(d[1]);
      MFK_OP: result.opcode := str2int(d);
      end;
    delete(s,1,8+l);
   end;
end; // str2macro

function macros2str(m: Tmacros): RawByteString;
var
  i: integer;
  s: RawByteString;
begin
 result := '';
 for i:=0 to length(m)-1 do
  begin
   s := macro2str(m[i]);
   result := result+int2str(length(s))+s;
  end;
end; // macros2str

procedure str2macros(s: RawByteString; var m: Tmacros);
var
  l, n: integer;
begin
  n := 0;
  while length(s) > 0 do
    begin
      l := str2int(s);
      inc(n);
      setLength(m, n);
      m[n-1] := str2macro( copy(s,5,l) );
      delete(s, 1, 4+l);
    end;
end; // str2macros


procedure popupHintByMacro();
var
  bmp: Tbitmap;
  r: Trect;
  node: Tnode;
  pt: Tpoint;
begin
  bmp := createBitmap(1, 1, RnQmain.currentPPI);
  pt := RnQmain.roster.ScreenToClient(mousepos);
  if within(0, pt.x, RnQmain.roster.width)
  and within(0, pt.y, RnQmain.roster.height) then
    node := roasterLib.nodeAt(pt.x, pt.y)
  else
    node := NIL;
  if node=NIL then
    node := clickedNode;
  if node<>NIL then
    begin
//    drawNodeHint(bmp.canvas, node.treenode, r);
    drawHint(bmp.canvas, node.kind,
             node.groupId, node.contact, r, True, RnQmain.currentPPI);
    bmp.Width := r.Right+1;
    bmp.Height := r.bottom+1;
//    drawNodeHint(bmp.canvas, node.treenode, r);
    drawHint(bmp.canvas, node.kind,
             node.groupId, node.contact, r, False, RnQmain.currentPPI);
//    TipAdd(bmp, 50);
    TipAdd3(NIL, bmp, NIL, 50);
//    tipfrm.show(bmp);
    end;
  bmp.free;
end; // popupHintByMacro

procedure popupMenu(m: Tpopupmenu);
begin
 if docking.Dock2Chat and docking.Docked2chat then
   bringForeground := chatFrm.Handle
  else
   bringForeground := RnQmain.handle;
  m.Popup(Screen.Width div 2, screen.Height div 2);
end; // popupMenu

procedure toggleAutosize;
begin
  autosizeRoster := not autosizeRoster;
//  design_fr.resetAutosize();
  autosizeDelayed := TRUE;
end; // toggleAutosize

procedure toggleShowGroups;
begin
  showGroups:=not showGroups;
  saveCfgDelayed := True;
//design_fr.prefToggleShowGroups;
  rosterRebuildDelayed := TRUE;
end;

procedure startMenuViaMacro;
begin
 menuViaMacro := TRUE;
 ShowWindow(application.handle, SW_SHOW);
 application.bringtofront;
end; // startMenuViaMacro

procedure stopMenuViaMacro;
begin
  menuViaMacro:=FALSE
end;

procedure MacroBossMode;
var
  pass: String;
  s: String;
begin
   if BossMode.isBossKeyOn and askPassOnBossKeyOn then
    begin
      if (AccPass > '') or
         (Assigned(Account.AccProto) and (Length(Account.AccProto.pwd) > 0)) then
        begin
          if enteringProtoPWD then
            Exit;
          if AccPass > '' then
            s := 'Account password'
           else
            s := 'Enter your password';
          enteringProtoPWD := TRUE;
          enterPwdDlg(pass, getTranslation(s));
          enteringProtoPWD := false;
        end;
      if (AccPass > '') then
        begin
         if (AccPass <> pass) then
           Exit;
        end
       else
        if (Assigned(Account.AccProto) and
           (Length(Account.AccProto.pwd) > 0)) then
         begin
          if not Account.AccProto.pwdEqual(pass) then
            Exit;
         end;
    end;
  BossMode.isBossKeyOn := not BossMode.isBossKeyOn;
  if BossMode.isBossKeyOn then
    begin
      BossMode.toShowChat := chatFrm.Visible;
      BossMode.toShowCL := formVisible(RnQmain) and (RnQmain.windowstate<>wsMinimized);
      if docking.Dock2Chat and docking.Docked2chat AND NOT RnQmain.Floating
         and BossMode.toShowChat then
        BossMode.toShowChat := False;
      if BossMode.toShowChat then
        begin
          chatFrm.close;
          restoreForeWindow;
        end;
      if BossMode.toShowCL then
        begin
         RnQmain.toggleVisible;
        end;
      BossMode.activeChat := True;
      TipsHideAll;
    end
   else
    begin
      if not BossMode.activeChat then
       if BossMode.toShowChat then
        if chatFrm.chats.count > 0 then
         begin
          chatFrm.open;
         end;
      if BossMode.toShowCL and not formVisible(RnQmain) then
       begin
        bringForeground := 0;
        RnQmain.toggleVisible;
       end;
      if BossMode.activeChat then
       if BossMode.toShowChat then
        if chatFrm.chats.count > 0 then
         begin
          chatFrm.open;
         end;
    end;
  if assigned(statusIcon) and assigned(statusIcon.trayIcon) then
    statusIcon.trayIcon.update;
end;

end.
