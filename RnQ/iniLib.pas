{
This file is part of R&Q.
Under same license
}
unit iniLib;
{$I Compilers.inc}
{$I RnQConfig.inc}
{$WARN SYMBOL_PLATFORM OFF}

{$I NoRTTI.inc}

interface

uses
  RnQZip;

procedure beforeWindowsCreation;
procedure afterWindowsCreation;
procedure quit;
procedure startUser;
procedure quitUser;
procedure resetCFG;

procedure UpdateProperties;
function  getCFG:RawByteString;
procedure loadCFG(zp : TZipFile);
//procedure saveCFG;
function  getCommonCFG: AnsiString;
procedure loadCommonCFG;
procedure saveCommonCFG;
//procedure saveAutomessages;
procedure loadAutomessages(zp : TZipFile);
procedure UnloadAutomessages;
procedure loadMacros(zp : TZipFile);
//procedure saveMacros;

//procedure testBall;
//procedure testNTLM;

implementation

uses
  menus, windows, graphics, classes, sysutils, forms, shellapi,
  controls, types, strutils, SysConst, ThemesLib,
  RnQDialogs, RnQLangs, RnQNet, RDtrayLib, RnQGlobal,
  RnQPrefsLib,
  RDUtils, RnQMacros, RnQStrings, RnQCrypt,
  RQUtil, RDGlobal, RQThemes, RDFileUtil,

  roasterlib, usersDlg,
  utilLib, events, chatDlg, globalLib,
  RQlog, pluginLib, outboxLib,
  uinlistlib,
  mainDlg,
  prefDlg,
 {$IFDEF RNQ_AVATARS}
  RnQ_Avatars,
 {$ENDIF}
  groupsLib, langLib, StatusForm,
  RnQProtocol,
  hook,
 {$IFDEF UNICODE}
   AnsiStrings,
 {$ENDIF UNICODE}
//                                             DateUtils,
//                                             EBase64,
    RnQBinUtils,
//  fxRegistryFile,
//   rtf2html,
 {$IFDEF PROTOCOL_ICQ}
   RQ_ICQ, icqv9, ICQConsts,
   wpDlg,
 {$ENDIF PROTOCOL_ICQ}

  OverbyteIcsWinSock,
  RnQTips, history,
  MenuSmiles, menusUnit,
   histUtilsDlg,
   Protocols_all;
var
  initOnce:boolean;

procedure resetCFG;
var
  i:integer;
//  pp:Tproxyproto;
begin
  rosterTitle:='%uin% %nick%';
  showMainBorder := True;
  ShowUINDelimiter := True;
  ResetThemePaths;
  UseContactThemes := False;
  FileSavePath := '%userpath%\Received\%uid%\';
  UnloadAutomessages;
//  autoMessages.clear;
  autoMessages.add('');
  sendOnEnter:=0;
  skipSplash:=FALSE;
  autoSwitchKL:=False;
  //resetTheme;
  sortBy:=SB_event;

//fillChar(icqv9.onStatusDisable, sizeOf(icqv9.onStatusDisable), 0);
//fillChar(mrav1.onStatusDisable, sizeOf(mrav1.onStatusDisable), 0);
  fillChar(onStatusDisable, sizeOf(onStatusDisable), 0);
//icqv9.onStatusDisable[SC_dnd].blinking:=TRUE;
//icqv9.onStatusDisable[SC_dnd].sounds:=TRUE;
//mrav1.onStatusDisable[mSC_dnd].blinking:=TRUE;
//mrav1.onStatusDisable[mSC_dnd].sounds:=TRUE;

  if Assigned(Account.AccProto) then
    Account.AccProto.ResetPrefs;
{  with proxy do
    begin
    enabled:=FALSE;
  //  for pp:=low(pp) to high(pp) do addr[pp].host:='';
    addr.host:='';
  //  addr[PP_SOCKS4].port:='1080';
  //  addr[PP_SOCKS5].port:='1080';
  //  addr[PP_HTTPS].port:='3128';
    addr.port:=1080;
    proto:=PP_NONE;
    auth:=FALSE;
    NTLM := False;
    serv.host := DefLoginServer;
    serv.port := DefLoginPort;
    end;}

  enableIgnoreList:=TRUE;
  ignorelist.clear;
  notinlist.clear;
 {$IFDEF CHECK_INVIS}
   CheckInvis.CList.Clear;
 {$ENDIF}
connectOnConnection:=FALSE;
InitMacroses;
keepalive.enabled:= True;
keepalive.freq:=60;
with RnQmain do
 begin
  width:=120;
  height:=250;
  left:=screen.width-width-30;
 end;

  with transparency do
   begin
    forRoster := False;
    forChat := False;
    active := 200;
    inactive := 86;
    chgOnMouse := True;
    forTray := False;
    tray := 220;
   end;

splitY:=-1;
tempBlinkTime:=80;
okOn2enter_autoMsg := False;
useLastStatus := True;
  //loginServer:='login.icq.com';
  lastStatusUserSet:= byte(SC_UNK);
//  RnQStartingStatus:= byte(SC_ONLINE);
  RnQStartingStatus:= -1; // Last used
  RnQStartingVisibility := 0;//VI_NORMAL;

quoting.cursorBelow := False;
quoting.width := 300;
quoting.quoteselected := True;
//     icqdebug   := false;
inactivehide := False;
inactivehideTime:=50;
focusOnChatPopup := True;
bringInfoFrgd := True; // By Rapid D
checkupdate.lastSerial:=0;
checkupdate.betas := False or PREVIEWversion;
checkupdate.enabled := False or PREVIEWversion;
checkupdate.every:=24;
prefHeight:=390;
minOnOff := False;
minOnOffTime:=30;
useSystemCodePage := True;

showVisAndLevelling := False;

  for I := 0 to Byte(High(TRnQCLIconsSet)) do
   begin
     TO_SHOW_ICON[TRnQCLIconsSet(i)] := True;
     SHOW_ICONS_ORDER[i] := TRnQCLIconsSet(i);
   end;
  TO_SHOW_ICON[CNT_ICON_AVT] := False;


//sendInterests := True;
// curXStatusStr := '';
// curXStatusDesc := '';
  XStatusAsMain := True;
{  for I := low(XStatus6) to High(XStatus6) do
   begin
     ExtStsStrings[i] := XStatus6[i].Caption;
//     ExtStsStrings[i][1] := '';
   end;
}

  SetLength(spamfilter.quests, 0);
  showXStatusMnu := True;
  autoRequestXsts := False;

  blinkWithStatus := True;
  showRQP := False;
{$IFDEF RNQ_FULL}
 {$IFDEF Use_Baloons}
  showBalloons := True;
 {$ELSE Use_Baloons}
  showBalloons := False;
 {$ENDIF Use_Baloons}
{$ENDIF}
  usePlugPanel  := True;
  useCtrlNumInstAlt := False; 

rosterbarOnTop:= False;
filterbarOnTop:=True;
 RnQmain.FilterBar.Visible := False;

doFixWindows := True;
animatedRoster:= False;
blinkSpeed:=5;
userCharSet:=-1;
logpref.writehistory:=TRUE;
logpref.pkts.onWindow:=FALSE;
logpref.pkts.onFile:=FALSE;
logpref.pkts.clear:=FALSE;
logpref.evts.onWindow:=FALSE;
logpref.evts.onFile:=FALSE;
logpref.evts.clear:=FALSE;
rosterItalic:=RI_list;

popupautomsg:=TRUE;
oncomingOnAway:=FALSE;
showOnlyOnline:=FALSE;
showOnlyImVisibleTo:=FALSE;
OnlOfflInOne := false;
showUnkAsOffline := True;
closeAuthAfterReply:=TRUE;
CloseFTWndAuto := False;
autoConsumeEvents:=TRUE;
DsblEvnt4ClsdGrp := False;
RnQmain.roster.ShowHint:=TRUE;
warnVisibilityAutoMsgReq:=TRUE;
showStatusOnTabs:=TRUE;
//webaware:=TRUE;
indentRoster:=FALSE;
NILdoWith := 0;
dontSavePwd := FALSE;
clearPwdOnDSNCT := FALSE;
askPassOnBossKeyOn := False;
MakeBakups:=FALSE;
startMinimized:=FALSE;
autoReconnect:=TRUE;
autoReconnectStop:=false;
SaveIP := false;
quitconfirmation:=FALSE;
minimizeRoster:=TRUE;
showLSB:=TRUE;
popupLSB:=TRUE;
ShowHintsInChat := True;
closeChatOnSend := True;
ClosePageOnSingle := False;
getOfflineMsgs:=TRUE;
delOfflineMsgs:=TRUE;
lockOnStart:=FALSE;
autocopyhist:=TRUE;
bViewTextWrap := True;
  useSmiles:=TRUE;
  ShowSmileCaption := FALSE;
  ShowAniSmlPanel := True;
  prefSmlAutoSize := True;
  DrawSmileGrid := false;
  prefBtnWidth := Btn_Max_Width;
  prefBtnHeight := Btn_Max_Height;

MenuHeightPerm := True;
MenuDrawExt := True;
sendTheAddedYou:=FALSE;
texturizedWindows:=TRUE;
showOncomingDlg:=FALSE;
autoSizeRoster:=FALSE;
autosizeFullRoster:=FALSE;
autosizeUp := False;
showDisconnectedDlg:=TRUE;
//showDisconnectedDlg:=FALSE;
fontstylecodes.enabled:=TRUE;
playSounds:=TRUE;
SoundReset;
autoconnect:=FALSE;
showGroups:=TRUE;
alwaysOnTop:=TRUE;
chatAlwaysOnTop:=FALSE;
avatarShowInChat := True;
avatarShowInHint := True;
avatarShowInTray := True;
useSingleClickTray := True;
autoDeselect:=FALSE;
warnVisibilityExploit:=TRUE;
wheelVelocity:=1;
useDefaultBrowser:=TRUE;
browserCmdLine:='';

with spamfilter do
  begin
	ignoreNIL:=FALSE;
  ignorepagers:=FALSE;
  warn:=FALSE;
  addToHist := True;
  ignoreauthNIL:=false; // By Rapid D
  useBot := False; ////////////////////////////////////////////////////////
  useBotInInvis := False;
  UseBotFromFile := False;
  BotTryesCount  := 3;
  notNIL:=FALSE;
  notEmpty:=FALSE;
  nobadwords:=FALSE;
  multisend:=FALSE;
  badwords:='';
  uingt:=0;
  end;
 with histcrypt do
  begin
   enabled:=FALSE;
   savePwd:=FALSE;
   pwd:='';
  end;
autoaway.autoexit:=TRUE;
autoaway.away:=TRUE;
autoaway.na:=TRUE;
autoaway.ss:=TRUE;
autoaway.boss := True;
autoaway.clearXSts := False;
autoaway.awayTime:=15*(10*60);
autoaway.naTime:=30*(10*60);
autoaway.msg:='';
autoaway.bakmsg:='';
docking.enabled:=TRUE;
docking.appbar:=TRUE;
docking.Dock2Chat := False;
docking.Docked2chat := False;
behaviour[EK_oncoming].trig:=[BE_tray,BE_sound,BE_tip,BE_history];
behaviour[EK_offgoing].trig:=[BE_history,BE_tip];
behaviour[EK_msg].trig:=[BE_tray,BE_openchat,BE_save,BE_sound,BE_history,BE_tip,BE_FLASHCHAT];
behaviour[EK_contacts]:=behaviour[EK_msg];
behaviour[EK_auth]:=behaviour[EK_msg];
behaviour[EK_authDenied]:=behaviour[EK_msg];
behaviour[EK_authreq]:=behaviour[EK_msg];
behaviour[EK_addedyou]:=behaviour[EK_msg];
//behaviour[EK_file].trig:=[BE_tray,BE_save,BE_sound,BE_history];
behaviour[EK_file] :=behaviour[EK_msg];
behaviour[EK_automsgreq].trig:=[BE_history];
behaviour[EK_statuschange].trig:=[BE_history];
//behaviour[EK_statuschangeExt].trig:=[BE_history];
behaviour[EK_gcard].trig:=[BE_tray,BE_sound,BE_history,BE_openchat,BE_save];
behaviour[EK_automsg].trig:=[BE_openchat,BE_history,BE_sound,BE_popup];
 {$IFDEF Use_Baloons}
behaviour[EK_typingBeg].trig := [BE_tip, BE_BALLOON];
behaviour[EK_typingFin].trig := [BE_tip, BE_BALLOON];
 {$ELSE not Use_Baloons}
behaviour[EK_typingBeg].trig := [BE_TIP];
behaviour[EK_typingFin].trig := [BE_TIP];
 {$ENDIF Use_Baloons}
behaviour[EK_XstatusMsg].trig:=[BE_history];
behaviour[EK_Xstatusreq].trig:=[BE_history];

for i:=1 to EK_last do
  begin
  behaviour[i].tiptimes := False;
  behaviour[i].tiptime:=50;
  behaviour[i].tiptimeplus:=50;
  end;
behaviour[EK_msg].tiptimes := True;
behaviour[EK_msg].tiptime:=1;
behaviour[EK_url]:=behaviour[EK_msg];
behaviour[EK_typingBeg].tiptime := 20;
behaviour[EK_typingFin].tiptime := 20;


 TipsMaxCnt   := 20;
 TipsBtwSpace := 2;
 TipsAlign    := alBottomRight;
 TipsMaxAvtSizeUse := True;
 TipsMaxAvtSize := 100;

end; // resetCFG

procedure UpdateProperties;
var
  pp : TRnQPref;
//  l : RawByteString;
  sU : String;
  i : Integer;
  myInf : TRnQContact;
  mainRect : TRect;
  WinRect : TRect;
begin
//  pp := TRnQPref.Create;
  pp := MainPrefs;

//  if Assigned(Account.AccProto) and Assigned(Account.AccProto.getMyInfo) and (Account.AccProto.getMyInfo.UID > '') then
  if Assigned(Account.AccProto) and //Assigned(Account.AccProto.MyInfo) and (Account.AccProto.getMyInfo.UID > '') then
     (Account.AccProto.ProtoElem.MyAccNum > '') then
    begin
//    l := StrToUTF8(MainProto.getMyInfo.displayed)
      myInf := Account.AccProto.getMyInfo;
      if Assigned(myInf) then
        pp.addPrefStr('account-name', myInf.displayed);
    end;
//   else
//    l := '';
//  pp.addPrefBlob('account-name', l);
  pp.addPrefInt('version', RnQBuild);
  if histcrypt.savePwd then
    begin
//      pp.addPrefBlob('history-crypt-password', passcrypt(histcrypt.pwd));
      pp.addPrefBlob64('history-crypt-password64', passcrypt(histcrypt.pwd));
    end
   else
    begin
      pp.DeletePref('history-crypt-password64');
    end;
  pp.DeletePref('history-crypt-password');
  for i:=1 to EK_last do
   begin
    sU := String(event2str[i])+'-behaviour';
    pp.addPrefStr(sU, beh2str(i));
   end;
  if Assigned(RnQmain) then
    begin
     if Assigned(RnQmain.Parent) then
       mainRect.TopLeft := RnQmain.Parent.ClientToScreen(Point(RnQmain.Left, RnQmain.Top))
      else
       mainRect.TopLeft := Point(RnQmain.Left, RnQmain.Top);
     mainRect.Right := mainRect.Left + RnQmain.Width;
     mainRect.Bottom := mainRect.Top + RnQmain.Height;
    end
   else
    mainRect := Rect(0,0,0,0);
  WinRect := Screen.DesktopRect;
  sU := '-' + intToStr(WinRect.Right-WinRect.Left) + 'x' +
        intToStr(WinRect.Bottom-WinRect.Top);
  pp.addPrefInt('window-top'+sU, mainRect.top);
  pp.addPrefInt('window-height'+sU, mainRect.Bottom - mainRect.Top);
  pp.addPrefInt('window-left'+sU, mainRect.left);
  pp.addPrefInt('window-width'+sU, mainRect.Right - mainRect.Left);

  pp.addPrefInt('window-top', mainRect.Top);
  pp.addPrefInt('window-height', mainRect.Bottom - mainRect.Top);
  pp.addPrefInt('window-left', mainRect.left);
  pp.addPrefInt('window-width', mainRect.Right - mainRect.Left);
  pp.addPrefInt('chat-top', chatfrmXY.Top);
  pp.addPrefInt('chat-height', chatfrmXY.height);
  pp.addPrefInt('chat-left', chatfrmXY.left);
  pp.addPrefInt('chat-width', chatfrmXY.width);
  pp.addPrefBool('chat-maximized', chatfrmXY.maximized);
  pp.addPrefBool('transparency',transparency.forRoster);
  pp.addPrefBool('transparency-chat', transparency.forChat);
  pp.addPrefBool('transparency-tray', transparency.forTray);
  pp.addPrefBool('transparency-chgonmouse', transparency.chgOnMouse);
  pp.addPrefInt('transparency-active', transparency.active);
  pp.addPrefInt('transparency-inactive', transparency.inactive);
  pp.addPrefInt('transparency-vtray', transparency.tray);

  pp.addPrefStr('proxy-name', MainProxy.name);
  pp.addPrefStr('proxy-host', MainProxy.addr.host);
  pp.addPrefInt('proxy-port', MainProxy.addr.port);
  pp.addPrefBool('proxy-auth', MainProxy.auth);
  pp.addPrefStr('proxy-user', MainProxy.user);
//  pp.addPrefBlob('proxy-pass', passCrypt(StrToUTF8(MainProxy.pwd)));
  pp.addPrefBlob64('proxy-pass64', passCrypt(StrToUTF8(MainProxy.pwd)));
  pp.addPrefBool('proxy-NTLM', MainProxy.NTLM);
  pp.addPrefStr('proxy-proto', proxyproto2str[MainProxy.proto]);
  pp.addPrefStr('ports-listen', portsListen.getString);

  pp.addPrefBool('auto-size', autoSizeRoster);
  pp.addPrefBool('auto-size-full', autosizeFullRoster);
  pp.addPrefBool('auto-size-up', autosizeUp);
  pp.addPrefBool('reopen-chats-on-start', reopenchats);
  pp.addPrefBool('skip-splash', skipSplash);
  pp.addPrefBool('fix-windows-position', doFixWindows);
  pp.addPrefBool('start-minimized', startMinimized);
  pp.addPrefBool('auto-reconnect', autoReconnect);
  pp.addPrefBool('auto-reconnect-stop', autoReconnectStop);
  pp.addPrefBool('save-ip', SaveIP);

  pp.addPrefBool('use-last-status', useLastStatus);
  pp.addPrefBool('close-auth-after-reply', closeAuthAfterReply);
  pp.addPrefBool('close-ft-after-end', CloseFTWndAuto);
  pp.addPrefBool('inactive-hide', inactivehide);
  pp.addPrefBool('check-betas', checkupdate.betas);
  pp.addPrefBool('get-offline-msgs', getOfflineMsgs);
  pp.addPrefBool('del-offline-msgs', delOfflineMsgs);
  pp.addPrefBool('roaster-bar-on-top', rosterbarOnTop);
  pp.addPrefBool('filter-bar-on-top', filterbarOnTop);

  pp.addPrefBool('dont-save-password', dontSavePwd);
  pp.addPrefBool('clear-password-on-disconnect', clearPwdOnDSNCT);
  pp.addPrefBool('ask-password-after-bossmode', askPassOnBossKeyOn);
  pp.addPrefBool('make-bakups-on-save', MakeBakups);
  pp.addPrefBool('oncoming-on-away', oncomingOnAway);

  pp.addPrefInt('last-update-info', checkupdate.lastSerial);
  pp.addPrefTime('last-update-check-time', checkupdate.last);
//+'last-update-check-time='+dateToStr(checkupdate.last)+CRLF
  pp.addPrefInt('wheel-velocity', wheelVelocity);
  pp.addPrefInt('inactive-hide-time', inactivehideTime);

  pp.addPrefBool('auto-connect', autoconnect);
  pp.addPrefBool('minimize-roaster', minimizeRoster);
  pp.addPrefBool('connect-on-connection', connectOnConnection);
  pp.addPrefBool('quit-confirmation', quitconfirmation);
  pp.addPrefBool('min-on-off', minOnOff);
  pp.addPrefInt('min-on-off-time', minOnOffTime);
  pp.addPrefInt('sound-volume', Soundvolume);
  pp.addPrefBool('play-sounds', playSounds);
  pp.addPrefBool('lock-on-start', lockOnStart);
  pp.addPrefBool('ok-double-enter-auto-msg', okOn2enter_autoMsg);
  pp.addPrefBool('auto-check-update', checkupdate.enabled);
  pp.addPrefBool('show-only-online-contacts', showOnlyOnline);
  pp.addPrefBool('show-only-im-visible-to-contacts', showOnlyImVisibleTo);
  pp.addPrefBool('show-all-contacts-in-one', OnlOfflInOne);
  pp.addPrefBool('show-unk-as-offline', showUnkAsOffline);
  pp.addPrefBool('show-oncoming-dialog', showOncomingDlg);
  pp.addPrefBool('send-added-you', sendTheAddedYou);
  pp.addPrefBool('always-on-top', alwaysOnTop);
  pp.addPrefBool('chat-always-on-top', chatAlwaysOnTop);
  pp.addPrefBool('chat-show-avatars-chat', avatarShowInChat);
  pp.addPrefBool('chat-show-avatars-hint', avatarShowInHint);
  pp.addPrefBool('chat-show-avatars-tray', avatarShowInTray);
  pp.addPrefBool('use-single-click-tray', useSingleClickTray);
  pp.addPrefBool('warn-visibility-automsgreq', warnVisibilityAutoMsgReq);
  pp.addPrefInt('split-y', splitY);
  pp.addPrefInt('blink-speed', blinkSpeed);
  pp.addPrefInt('temp-blink-time', tempBlinkTime);

  pp.addPrefBool('show-statusbar', RnQmain.bar.Visible);
  pp.addPrefBool('show-filterbar', RnQmain.FilterBar.Visible);
  pp.addPrefBool('show-contact-tip', RnQmain.roster.ShowHint);
  pp.addPrefInt('show-tips-count', TipsMaxCnt);
  pp.addPrefInt('show-tips-align', byte(TipsAlign));
  pp.addPrefInt('show-tips-btw-space', TipsBtwSpace);
  pp.addPrefInt('show-tips-ver-indent', TipVerIndent);
  pp.addPrefInt('show-tips-hor-indent', TipHorIndent);
  pp.addPrefBool('show-tips-use-avt-size', TipsMaxAvtSizeUse);
  pp.addPrefInt('show-tips-avt-size', TipsMaxAvtSize);


  pp.addPrefBool('popup-automsg', popupAutomsg);
//+'save-not-in-list='+yesno[saveNIL]+CRLF
  pp.addPrefInt('not-in-list-do', NILdoWith);
  pp.addPrefBool('animated-roaster', animatedRoster);
  pp.addPrefBool('show-groups', showGroups);
  pp.addPrefBool('visibility-level-flag', showVisAndLevelling);
  pp.addPrefBool('system-cp-flag', useSystemCodePage);
//+'send-interests='+yesno[sendInterests]+CRLF

  for I := 0 to Byte(High(TRnQCLIconsSet)) do
   if TRnQCLIconsSet(i) <> CNT_TEXT then
    pp.addPrefBool(RnQCLIcons[TRnQCLIconsSet(i)].PrefText, TO_SHOW_ICON[TRnQCLIconsSet(i)]);
  pp.addPrefStr('show-cl-icons-order', ICON_ORDER_PREF);

  pp.addPrefBool('show-xstatus-in-menu-flag', showXStatusMnu);

 {$IFDEF RNQ_FULL}
  pp.addPrefBool('show-balloons-flag', showBalloons);
 {$ENDIF}
  pp.addPrefBool('use-plugin-panel', usePlugPanel);
  pp.addPrefBool('chat-use-ctrl-num-instead-alt-num', useCtrlNumInstAlt);

  pp.addPrefBool('use-smiles', useSmiles);
  pp.addPrefBool('smiles-captions', ShowSmileCaption);
  pp.addPrefBool('smiles-show-panel', ShowAniSmlPanel);
  pp.addPrefBool('smiles-panel-btn-autosize', prefSmlAutoSize);
  pp.addPrefBool('smiles-panel-draw-grid', DrawSmileGrid);
  pp.addPrefInt('smiles-panel-btn-width', prefBtnWidth);
  pp.addPrefInt('smiles-panel-btn-height', prefBtnHeight);
  pp.addPrefBool('menu-height-perm', MenuHeightPerm);
  pp.addPrefBool('menu-draw-ext', MenuDrawExt);
  pp.addPrefInt('send-on-enter', sendOnEnter);

  pp.addPrefStr('disabled-plugins', disabledPlugins);

  pp.addPrefBool('show-status-on-tabs', showStatusOnTabs);
  pp.addPrefBool('auto-deselect', autoDeselect);
  pp.addPrefBool('single-message-by-default', singledefault);
  pp.addPrefBool('auto-copy', autocopyhist);
  pp.addPrefBool('hist-msg-view-wrap', bViewTextWrap);
  pp.addPrefBool('indent-contact-list', indentRoster);
  pp.addPrefBool('auto-consume-events', autoConsumeEvents);
  pp.addPrefBool('disable-events-on-closed-groups', DsblEvnt4ClsdGrp);
  pp.addPrefBool('show-disconnected-dialog', showDisconnectedDlg);
  pp.addPrefBool('keep-alive', keepalive.enabled);
  pp.addPrefInt('keep-alive-freq', keepalive.freq);
  pp.addPrefInt('italic-mode', rosterItalic);
  pp.addPrefBool('focus-on-chat-popup', focusOnChatPopup);
  pp.addPrefBool('bring-info-frgd', bringInfoFrgd);

  pp.addPrefBool('enable-ignore-list', enableIgnoreList);
  pp.addPrefBool('use-contacts-themes', UseContactThemes);
  pp.addPrefInt('preferences-height', prefHeight);
  pp.addPrefBool('docking-enabled', docking.enabled);
  pp.addPrefBool('docking-active', docking.active);
  pp.addPrefBool('docking-resize', docking.appbar);
  pp.addPrefBool('docking-right', docking.pos=DP_right);
  pp.addPrefInt('docking-bak-x', docking.bakOfs.x);
  pp.addPrefInt('docking-bak-y', docking.bakOfs.y);
  pp.addPrefInt('docking-bak-width', docking.bakSize.x);
  pp.addPrefInt('docking-bak-height', docking.bakSize.y);
  pp.addPrefBool('docking-dock2chat', docking.Dock2Chat);
  pp.addPrefBool('docking-docked2chat', docking.Docked2chat);
  pp.addPrefBool('autoaway-exit', autoaway.autoexit);
  pp.addPrefBool('autoaway-away', autoaway.away);
  pp.addPrefInt('autoaway-away-time', autoaway.awayTime);
  pp.addPrefBool('autoaway-na', autoaway.na);
  pp.addPrefBool('autoaway-ss', autoaway.ss);
  pp.addPrefBool('autoaway-boss', autoaway.boss);
  pp.addPrefBool('autoaway-clear-xstatus', autoaway.clearXSts);
  pp.addPrefInt('autoaway-na-time', autoaway.naTime);
  pp.addPrefBool('ignore-not-in-list', spamfilter.ignoreNIL);
  pp.addPrefBool('ignore-pagers', spamfilter.ignorePagers);
  pp.addPrefBool('ignore-authreq-notinlist', spamfilter.ignoreauthNIL);

  pp.addPrefBool('spam-ignore-not-in-list', spamfilter.notNIL);
  pp.addPrefBool('spam-ignore-empty-history', spamfilter.notEmpty);
  pp.addPrefBool('spam-ignore-bad-words', spamfilter.noBadwords);
  pp.addPrefBool('spam-ignore-multisend', spamfilter.multisend);
  pp.addPrefBool('spam-warn', spamfilter.warn);
  pp.addPrefBool('spam-add-history', spamfilter.addToHist);
  pp.addPrefInt('spam-uin-greater-than', spamfilter.uingt);
  pp.addPrefBool('spam-use-bot', spamfilter.useBot);
  pp.addPrefBool('spam-use-bot-in-invis', spamfilter.useBotInInvis);
  pp.addPrefBool('spam-use-bot-file', spamfilter.UseBotFromFile);
  pp.addPrefInt('spam-bot-tryes', spamfilter.BotTryesCount);
  pp.addPrefBool('history-crypt-enabled', histcrypt.enabled);
  pp.addPrefBool('history-crypt-save-password', histcrypt.savePwd);
  pp.addPrefBool('chat-lsb-popup', popupLSB);
  pp.addPrefBool('chat-lsb-show', showLSB);
  pp.addPrefBool('chat-hints-show', ShowHintsInChat);
  pp.addPrefBool('chat-close-on-send', closeChatOnSend);
  pp.addPrefBool('chat-close-page-on-single', ClosePageOnSingle);

  pp.addPrefBool('use-default-browser', useDefaultBrowser);
  pp.addPrefStr('browser-command-line', browserCmdLine);
  pp.addPrefStr('sort-by', sortby2str[sortBy]);
//  pp.addPrefBlob('starting-status', status2Img[TICQStatus(startingStatus)]);

// +'xstatusstr'+curXStatusStr+CRLF
// +'xstatus-desc'+curXStatusDesc+CRLF
  pp.addPrefBool('xstatus-auto-request', autoRequestXsts);
  pp.addPrefBool('xstatus-as-main', XStatusAsMain);
  pp.addPrefBool('blink-with-status', blinkWithStatus);
  pp.addPrefBool('log-events-file', logpref.evts.onFile);
  pp.addPrefBool('log-events-window', logpref.evts.onWindow);
  pp.addPrefBool('log-events-clear', logpref.evts.clear);
  pp.addPrefBool('log-packets-file', logpref.pkts.onFile);
  pp.addPrefBool('log-packets-window', logpref.pkts.onWindow);
  pp.addPrefBool('log-packets-clear', logpref.pkts.clear);
  pp.addPrefBool('font-style-codes', fontstylecodes.enabled);
  pp.addPrefBool('write-history', logpref.writehistory);
  pp.addPrefBool('quote-selected', quoting.quoteselected);
  pp.addPrefInt('quoting-width', quoting.width);
  pp.addPrefBool('quoting-cursor-below', quoting.cursorBelow);
  pp.addPrefBool('texturized-windows', texturizedWindows);
  pp.addPrefBool('show-main-border', showMainBorder);
  pp.addPrefBool('show-uin-delimiter', ShowUINDelimiter);
  pp.addPrefBool('auto-switch-keyboard-layout', autoSwitchKL);
  pp.addPrefBool('warn-visibility-exploit', warnVisibilityExploit);

  pp.addPrefStr('files-recv-path', FileSavePath);
  pp.addPrefStr('roaster-title', rosterTitle);
  pp.addPrefStr('spam-bad-words', spamfilter.badwords);
  pp.addPrefStr('theme', theme.ThemePath.fn);
  pp.addPrefStr('theme-sub', theme.ThemePath.subfn);
  pp.addPrefStr('theme-smiles', RQSmilesPath.fn);
  pp.addPrefStr('theme-smiles-sub', RQSmilesPath.subfn);
  pp.addPrefStr('theme-sounds', RQSoundsPath.fn);
  pp.addPrefStr('theme-sounds-sub', RQSoundsPath.subfn);


 if Assigned(Account.AccProto)then
   Account.AccProto.GetPrefs(pp);
 plugins.castEv( PE_PROPERTIES_CHANGED);
//  pp.Free;
end;

function getCFG: RawByteString;
//var
//  pp : TRnQPref;
begin
{
  pp := TRnQPref.Create;
  ApplyProp(pp);
  Result := pp.getAllPrefs;
  pp.Free;
}
  Result := MainPrefs.getAllPrefs;
end; // getCFG

(*
procedure saveCFG;
var
  s : String;
//  zf : TZipFile;
begin
 if fantomWork then Exit;

  s := getCFG;
//  if FileExists(userPath+oldconfigFileName) then
//   DeleteFile(userPath+oldconfigFileName);
  savefile(userPath+configFileName, s, True);
{
  zf := TZipFile.Create;
  zf.AddFile(configFileName);
  zf.Data[0] := s;
  zf.SaveToFile(userPath+configFileName + '.zip');
  zf.Free;
}
end;*)

procedure setcommoncfg(cfg: RawByteString);
var
  l,h, v: RawByteString;

  function yesno:boolean;
  begin result:=l='yes' end;

  function int:integer;
  var
    bb : Integer;
  begin
//    if not tryStrToInt(l, result) then
//      result:= 0;
    Val(l, Result, bb);
    if bb <> 0 then
     Result := 0;
  end;

begin
if cfg = '' then exit;
docking.pos:=DP_right;

while cfg > '' do
  begin
//  l:=chop(CRLF,cfg);
//  h:=chop('=',l);
    l:=chop(CRLF,cfg);
    h:=LowerCase(Trim(chop(AnsiString('='),l)));
    v := trim(l);
    l := LowerCase(v);
  try
  if h='auto-start-uin' then autostartUIN   := l else
  if h='check-read-only' then check4readonly:= yesno else
  if h='last-server-ip' then lastserverIP   := l else
  if h='last-server-addr' then lastserverAddr   := l else
  if h='last-user' then lastUser   := l else
  if h='users-path' then usersPath := UnUTF(v) else
  if h='main-path' then RnQMainPath := UnUTF(v) else
  if h='langs-filename' then gLangFile := UnUTF(v) else
  if h='langs-sub-filename' then gLangSubFile := UnUTF(v);
  except end
  end;
  if not saveIP then
    lastServerIP := '';
end; // setcommoncfg

function getCommonCFG: AnsiString;
begin
  result:=''
  +'auto-start-uin='   + autostartUIN + CRLF
  +'check-read-only='  + yesno[check4readonly]+CRLF
  +'last-server-ip='   + AnsiString(lastserverIP) + CRLF
  +'last-server-addr=' + AnsiString(lastserverAddr) + CRLF
  +'users-path='       + StrToUTF8(usersPath) + CRLF
  +'main-path='        + StrToUTF8(RnQMainPath) + CRLF
  +'last-user='        + lastUser  + CRLF
  +'langs-filename='   + StrToUTF8(gLangFile) + CRLF
  +'langs-sub-filename=' + StrToUTF8(gLangSubFile) + CRLF;
end;

procedure resetCommonCFG;
begin
//  lastServerIP:= '205.188.179.233';
//  lastserverAddr := TicqSession._getDefHost.host;
  lastServerIP:= '';
  lastserverAddr := '';
//  lastserverAddr := '';
  check4readonly:=TRUE;
  autostartUIN := '';
  lastUser     := '';
  usersPath    := cmdLinePar.userPath;
  RnQMainPath  := cmdLinePar.mainPath;
  gLangFile    := '';
  gLangSubFile := '';
end; // resetCommonCFG

procedure setCFG(pp : TRnQPref);
var
  l//,h
  : AnsiString;
//  lastVersion:integer;
  i:integer;
//  st:TICQstatus;
//  pp:Tproxyproto;
{
  function yesno:boolean;
  begin result:=comparetext(l,AnsiString('yes'))=0 end;

  function int:integer;
  var
    bb : Integer;
  begin
//    if not tryStrToInt(l, result) then
//      result:= 0;
    Val(l, Result, bb);
    if bb <> 0 then
     Result := 0;
  end;

  function dt:Tdatetime;
  var
    df : TFormatSettings;
  begin
    GetLocaleFormatSettings(0, df);
    df.ShortDateFormat := 'dd.mm.yyyy';
    df.DateSeparator := '.';
    result:=StrToDate(l, df);
  end;

  function dtt:Tdatetime;
  var
    df : TFormatSettings;
  begin
    GetLocaleFormatSettings(0, df);
//    df.LongDateFormat := 'dd.mm.yyyy';
    df.ShortDateFormat := 'dd.mm.yyyy';
    df.DateSeparator := '.';
    df.LongTimeFormat := 'hh:mm:ss';
    df.ShortTimeFormat := 'hh:mm:ss';
    df.TimeSeparator := ':';
    result:=StrToDateTime(l, df);
  end;

  function sc:TShortCut;
  begin
  if comparetext(l,AnsiString('none'))=0 then result:=0
  else result:=textToShortCut(l);
  end;
}
var
//  pp : TRnQPref;
  sU : String;
  sR : RawByteString;
  WinRect : TRect;
  mainRect2 : TGPRect;
//  sU2
begin
//if cfg = '' then exit;
//lastVersion:=0;
//docking.pos:=DP_right;

//  pp := TRnQPref.Create;
//  pp := MainPrefs;
//  pp.Load(cfg);

//  pPublicEmail := pp.getPrefBool('public-email', True);
  pp.getPrefStr('theme', theme.ThemePath.fn);
  pp.getPrefStr('theme-sub', theme.ThemePath.subfn);
  pp.getPrefStr('theme-smiles', RQSmilesPath.fn);
  pp.getPrefStr('theme-smiles-sub', RQSmilesPath.subfn);
  pp.getPrefStr('theme-sounds', RQSoundsPath.fn);
  pp.getPrefStr('theme-sounds-sub', RQSoundsPath.subfn);
  pp.getPrefBool('use-contacts-themes', UseContactThemes);
  pp.getPrefStr('roaster-title', rosterTitle);
  pp.getPrefBool('show-main-border', showMainBorder);
  pp.getPrefBool('show-uin-delimiter', ShowUINDelimiter);
  pp.getPrefBool('fix-windows-position', doFixWindows);
  pp.getPrefBool('reopen-chats-on-start', reopenchats);
  pp.getPrefBool('connect-on-connection', connectOnConnection);
  pp.getPrefBool('get-offline-msgs', getOfflineMsgs);
  pp.getPrefBool('del-offline-msgs', delOfflineMsgs);
  pp.getPrefBool('minimize-roaster', minimizeRoster);
  pp.getPrefBool('use-default-browser', useDefaultBrowser);
  pp.getPrefStr('browser-command-line', browserCmdLine);
  pp.getPrefStr('disabled-plugins', disabledPlugins);
  pp.getPrefInt('last-update-info', checkupdate.lastSerial);
  pp.getPrefInt('wheel-velocity', wheelVelocity);
  pp.getPrefInt('split-y', splitY);
  pp.getPrefBool('auto-switch-keyboard-layout', autoSwitchKL);
  pp.getPrefDateTime('last-update-check-time', checkupdate.last);
  pp.getPrefBool('skip-splash', skipSplash);
  pp.getPrefBool('ok-double-enter-auto-msg', okOn2enter_autoMsg);
  pp.getPrefBool('start-minimized', startMinimized);
  pp.getPrefBool('warn-visibility-automsgreq', warnVisibilityAutoMsgReq);
  pp.getPrefBool('auto-reconnect', autoReconnect);
  pp.getPrefBool('auto-reconnect-stop', autoReconnectStop);
  pp.getPrefBool('save-ip', SaveIP);
  pp.getPrefBool('auto-check-update', checkupdate.enabled);
  pp.getPrefBool('lock-on-start', lockOnStart);
  pp.getPrefBool('chat-lsb-popup', popupLSB);
  pp.getPrefBool('chat-lsb-show', showLSB);
  pp.getPrefBool('chat-hints-show', ShowHintsInChat);
  pp.getPrefBool('chat-close-on-send', closeChatOnSend);
  pp.getPrefBool('chat-close-page-on-single', ClosePageOnSingle);
  pp.getPrefBool('popup-automsg', popupAutomsg);
  pp.getPrefBool('animated-roaster', animatedRoster);
  pp.getPrefBool('inactive-hide', inactivehide);
  pp.getPrefBool('font-style-codes', fontstylecodes.enabled);
  pp.getPrefBool('roaster-bar-on-top', rosterbarOnTop);
  pp.getPrefBool('filter-bar-on-top', filterbarOnTop);
  pp.getPrefBool('oncoming-on-away', oncomingOnAway);
  pp.getPrefBool('use-last-status', useLastStatus);

  for i:=1 to EK_last do
   begin
    sU := event2str[i]+'-behaviour';
    l := beh2str(i);
    pp.getPrefBlob(sU, RawByteString(l));
//    if l <> '' then
    behaviour[i]:=str2beh(l)
   end;

  pp.getPrefInt('inactive-hide-time', inactivehideTime);
  pp.getPrefInt('blink-speed', blinkSpeed);
  pp.getPrefBool('texturized-windows', texturizedWindows);
  pp.getPrefBool('dont-save-password', dontSavePwd);
  pp.getPrefBool('clear-password-on-disconnect', clearPwdOnDSNCT);
  pp.getPrefBool('ask-password-after-bossmode', askPassOnBossKeyOn);
  pp.getPrefBool('make-bakups-on-save', MakeBakups);
  pp.getPrefBool('always-on-top', alwaysOnTop);
  pp.getPrefBool('chat-always-on-top', chatAlwaysOnTop);
  pp.getPrefBool('chat-show-avatars-chat', avatarShowInChat);
  pp.getPrefBool('chat-show-avatars-hint', avatarShowInHint);
  pp.getPrefBool('chat-show-avatars-tray', avatarShowInTray);
  pp.getPrefBool('use-single-click-tray', useSingleClickTray);
  pp.getPrefBool('check-betas', checkupdate.betas);
  pp.getPrefBool('send-added-you', sendTheAddedYou);
  pp.getPrefBool('show-groups', showGroups);
  RnQmain.roster.ShowHint := pp.getPrefBoolDef('show-contact-tip', RnQmain.roster.ShowHint);
  pp.getPrefInt('show-tips-count', TipsMaxCnt);
  TipsAlign := TtipsAlign(byte(pp.getPrefIntDef('show-tips-align', Byte(TipsAlign))));
  pp.getPrefInt('show-tips-btw-space', TipsBtwSpace);
  pp.getPrefInt('show-tips-ver-indent', TipVerIndent);
  pp.getPrefInt('show-tips-hor-indent', TipHorIndent);
  pp.getPrefBool('show-tips-use-avt-size', TipsMaxAvtSizeUse);
  pp.getPrefInt('show-tips-avt-size', TipsMaxAvtSize);
  pp.getPrefBool('close-auth-after-reply', closeAuthAfterReply);
  pp.getPrefBool('close-ft-after-end', CloseFTWndAuto);
  pp.getPrefBool('quoting-cursor-below', quoting.cursorBelow);
  pp.getPrefBool('quote-selected', quoting.quoteselected);
  pp.getPrefInt('quoting-width', quoting.width);
  pp.getPrefBool('quit-confirmation', quitconfirmation);
  pp.getPrefBool('log-events-file', logpref.evts.onFile);
  pp.getPrefBool('log-events-window', logpref.evts.onWindow);
  pp.getPrefBool('log-events-clear', logpref.evts.clear);
  pp.getPrefBool('log-packets-file', logpref.pkts.onFile);
  pp.getPrefBool('log-packets-window', logpref.pkts.onWindow);
  pp.getPrefBool('log-packets-clear', logpref.pkts.clear);
  pp.getPrefBool('write-history', logpref.writehistory);
  pp.getPrefBool('indent-contact-list', indentRoster);
  pp.getPrefBool('auto-consume-events', autoConsumeEvents);
  pp.getPrefBool('disable-events-on-closed-groups', DsblEvnt4ClsdGrp);
  pp.getPrefBool('focus-on-chat-popup', focusOnChatPopup);
  pp.getPrefBool('bring-info-frgd', bringInfoFrgd);
  pp.getPrefBool('show-status-on-tabs', showStatusOnTabs);
  pp.getPrefBool('show-disconnected-dialog', showDisconnectedDlg);
  RnQmain.bar.visible := pp.getPrefBoolDef('show-statusbar', True);
  RnQmain.FilterBar.visible := pp.getPrefBoolDef('show-filterbar', False);
  pp.getPrefBool('use-smiles', useSmiles);
  pp.getPrefBool('smiles-captions', ShowSmileCaption);
  pp.getPrefBool('smiles-show-panel', ShowAniSmlPanel);
  pp.getPrefBool('smiles-panel-btn-autosize', prefSmlAutoSize);
  pp.getPrefBool('smiles-panel-draw-grid', DrawSmileGrid);
  pp.getPrefInt('smiles-panel-btn-width', prefBtnWidth);
  pp.getPrefInt('smiles-panel-btn-height', prefBtnHeight);
  pp.getPrefBool('menu-height-perm', MenuHeightPerm);
  pp.getPrefBool('menu-draw-ext', MenuDrawExt);
  NILdoWith := pp.getPrefIntDef('not-in-list-do', 0);
  pp.getPrefInt('italic-mode', rosterItalic);
  pp.getPrefBool('auto-copy', autocopyhist);
  pp.getPrefBool('hist-msg-view-wrap', bViewTextWrap);

  for I := 0 to Byte(High(TRnQCLIconsSet)) do
   if TRnQCLIconsSet(i) <> CNT_TEXT then
    pp.getPrefBool(RnQCLIcons[TRnQCLIconsSet(i)].PrefText, TO_SHOW_ICON[TRnQCLIconsSet(i)]);
  pp.getPrefBlob('show-cl-icons-order', sR);
  ICON_ORDER_PREF_parse(sR);

  pp.getPrefBool('visibility-level-flag', showVisAndLevelling);
  pp.getPrefBool('system-cp-flag', useSystemCodePage);
  pp.getPrefBool('show-xstatus-in-menu-flag', showXStatusMnu);
   {$IFDEF RNQ_FULL}
      pp.getPrefBool('show-balloons-flag', showBalloons);
   {$ENDIF}
  pp.getPrefBool('use-plugin-panel', usePlugPanel);
  pp.getPrefBool('chat-use-ctrl-num-instead-alt-num', useCtrlNumInstAlt);
  pp.getPrefBool('single-message-by-default', singledefault);
  pp.getPrefBool('show-oncoming-dialog', showOncomingDlg);
  pp.getPrefBool('min-on-off', minOnOff);
  pp.getPrefInt('min-on-off-time', minOnOffTime);
  pp.getPrefBool('keep-alive', keepalive.enabled);
  pp.getPrefInt('keep-alive-freq', keepalive.freq);
  pp.getPrefBool('enable-ignore-list', enableIgnorelist);
  pp.getPrefBool('ignore-not-in-list', spamfilter.ignoreNIL);
  pp.getPrefBool('ignore-pagers', spamfilter.ignorePagers);
  pp.getPrefBool('ignore-authreq-notinlist', spamfilter.ignoreauthNIL);
  pp.getPrefBool('spam-warn', spamfilter.warn);
  pp.getPrefBool('spam-add-history', spamfilter.addToHist);
  pp.getPrefBool('spam-ignore-not-in-list', spamfilter.notNIL);
  pp.getPrefBool('spam-ignore-empty-history', spamfilter.notEmpty);
  pp.getPrefBool('spam-ignore-bad-words', spamfilter.noBadwords);
  pp.getPrefBool('spam-ignore-multisend', spamfilter.multisend);
//  l := pp.getPrefBlobDef('spam-bad-words');
//    spamfilter.badwords:=ansiReplaceStr(l,CRLF, AnsiChar(';'));
  spamfilter.badwords := ansiReplaceStr( pp.getPrefStrDef('spam-bad-words'),CRLF, AnsiChar(';'));
  pp.getPrefInt('spam-uin-greater-than', spamfilter.uingt);
  pp.getPrefBool('spam-use-bot', spamfilter.usebot);
  pp.getPrefBool('spam-use-bot-in-invis', spamfilter.useBotInInvis);
  pp.getPrefBool('spam-use-bot-file', spamfilter.UseBotFromFile);
  pp.getPrefInt('spam-bot-tryes', spamfilter.BotTryesCount);
  boundInt(spamfilter.BotTryesCount, 2, 6);
  pp.getPrefBool('history-crypt-enabled', histcrypt.enabled);
  pp.getPrefBool('history-crypt-save-password', histcrypt.savePwd);
  if pp.prefExists('history-crypt-password64') then
    histcrypt.pwd := passDecrypt(pp.getPrefBlob64Def('history-crypt-password64'))
   else
    histcrypt.pwd := passDecrypt(pp.getPrefBlobDef('history-crypt-password'));

  WinRect := Screen.DesktopRect;
  sU := '-' + intToStr(WinRect.Right-WinRect.Left) + 'x' +
        intToStr(WinRect.Bottom-WinRect.Top);
  MainRect2.y := pp.getPrefIntDef('window-top'+sU);
  MainRect2.x := pp.getPrefIntDef('window-left'+sU);
  MainRect2.width := pp.getPrefIntDef('window-width'+sU);
  MainRect2.height := pp.getPrefIntDef('window-height'+sU);

  if (MainRect2.Y = -1)or (MainRect2.X = -1) then
    begin
     MainRect2.Y := pp.getPrefIntDef('window-top', RnQmain.top);
     MainRect2.X := pp.getPrefIntDef('window-left', RnQmain.left);
    end;
  if (MainRect2.width = -1)or (MainRect2.height = -1) then
    begin
     MainRect2.width  := pp.getPrefIntDef('window-width', RnQmain.width);
     MainRect2.height := pp.getPrefIntDef('window-height', RnQmain.height);
    end;

  RnQmain.top    := MainRect2.Y;
  RnQmain.left   := MainRect2.X;
  RnQmain.width  := MainRect2.width;
  RnQmain.height := MainRect2.height;

  pp.getPrefBool('auto-size-up', autosizeUp);
  pp.getPrefBool('auto-size', autosizeRoster);
  pp.getPrefBool('auto-size-full', autosizeFullRoster);

  pp.getPrefInt('preferences-height', prefHeight);
  pp.getPrefBool('docking-enabled', docking.enabled);
  pp.getPrefBool('docking-active', docking.active);
  pp.getPrefBool('docking-resize', docking.appbar);
  pp.getPrefInt('docking-bak-x', docking.bakOfs.x);
  pp.getPrefInt('docking-bak-y', docking.bakOfs.y);
  pp.getPrefInt('docking-bak-width', docking.bakSize.x);
  pp.getPrefInt('docking-bak-height', docking.bakSize.y);
  if pp.getPrefBoolDef('docking-right', True) then
    docking.pos := DP_right
   else
    docking.pos := DP_left;
  pp.getPrefBool('docking-Dock2Chat', docking.Dock2Chat);
  pp.getPrefBool('docking-Docked2chat', docking.Docked2chat);
  pp.getPrefInt('chat-top', chatfrmXY.top);
  pp.getPrefInt('chat-height', chatfrmXY.height);
  pp.getPrefInt('chat-left', chatfrmXY.left);
  pp.getPrefInt('chat-width', chatfrmXY.width);
  pp.getPrefBool('chat-maximized', chatfrmXY.maximized);
  pp.getPrefBool('auto-connect', autoconnect);
  pp.getPrefBool('play-sounds', playSounds);
  pp.getPrefInt('sound-volume', Soundvolume);
  pp.getPrefBool('show-only-online-contacts', showOnlyOnline);
  pp.getPrefBool('show-only-im-visible-to-contacts', showOnlyImVisibleTo);
  pp.getPrefBool('show-all-contacts-in-one', OnlOfflInOne);
  pp.getPrefBool('show-unk-as-offline', showUnkAsOffline);
  l := pp.getPrefBlobDef('sort-by');
    sortBy:=str2sortby(l);
  pp.getPrefBool('auto-deselect', autodeselect);
  pp.getPrefInt('temp-blink-time', tempBlinkTime);
  pp.getPrefBool('transparency', transparency.forRoster);
  pp.getPrefBool('transparency-chat', transparency.forChat);
  pp.getPrefBool('transparency-tray', transparency.forTray);
  pp.getPrefBool('transparency-chgonmouse', transparency.chgOnMouse);
  pp.getPrefInt('transparency-active', transparency.active);
  pp.getPrefInt('transparency-inactive', transparency.inactive);
  pp.getPrefInt('transparency-vtray', transparency.tray);
  pp.getPrefBool('warn-visibility-exploit', warnVisibilityExploit);
  pp.getPrefBool('autoaway-exit', autoaway.autoexit);
  pp.getPrefBool('autoaway-away', autoaway.away);
  pp.getPrefInt('autoaway-away-time', autoaway.awayTime);
  pp.getPrefBool('autoaway-na', autoaway.na);
  pp.getPrefInt('autoaway-na-time', autoaway.naTime);
  pp.getPrefBool('autoaway-ss', autoaway.ss);
  pp.getPrefBool('autoaway-boss', autoaway.boss);
  pp.getPrefBool('autoaway-clear-xstatus', autoaway.clearXSts);
  pp.getPrefBool('xstatus-auto-request', autoRequestXsts);
  pp.getPrefBool('xstatus-as-main', XStatusAsMain);
  pp.getPrefBool('blink-with-status', blinkWithStatus);
  pp.getPrefStr('files-recv-path', FileSavePath);

  pp.getPrefStr('proxy-host', MainProxy.addr.host);
  pp.getPrefInt('proxy-port', MainProxy.addr.port);
  if pp.getPrefBoolDef('proxy-ver5', True) then
    MainProxy.proto:=PP_SOCKS5
   else
    MainProxy.proto:=PP_SOCKS4;
  if not pp.getPrefBoolDef('proxy', False) then
    MainProxy.proto := PP_NONE;
  pp.getPrefStr('proxy-name', MainProxy.name);
  pp.getPrefBool('proxy-auth', MainProxy.auth);
  pp.getPrefBool('proxy-ntlm', MainProxy.NTLM);
  pp.getPrefStr('proxy-user', MainProxy.user);
//  MainProxy.user := pp.getPrefStrDef('proxy-user');
  if pp.prefExists('proxy-pass64') then
    l := pp.getPrefBlob64Def('proxy-pass64')
   else
    l := pp.getPrefBlobDef('proxy-pass');

  MainProxy.pwd := UnUTF(passDecrypt(l));
  l := pp.getPrefBlobDef('proxy-proto');
    i:=findInStrings(l, proxyproto2str);
    if i < 0 then
      begin
       MainProxy.proto:=PP_NONE;
      end
    else
      begin
       MainProxy.proto:=TproxyProto(i);
      end;

  sU := '';
  pp.getPrefStr('ports-listen', sU);
  portsListen.parseString(sU);

  pp.getPrefInt('send-on-enter', sendOnEnter);

//  pp.getPrefBool('', );
//  pp.getPrefStr('', );
//  pp.getPrefInt('', );
//  pp.getPrefDateTime('', );

//  pp.Free;
//  pp := NIL;

// backward compatibility
{if lastVersion < $00080104 then  // here i introduced BE_history
  for i:=1 to EK_last do
    if BE_history in supportedBehactions[i] then
      include(behaviour[i].trig, BE_history);
// end of backward compatibility}
boundInt(inactivehideTime, 0,60*60*10);
boundInt(blinkSpeed, 1,15);
boundInt(transparency.active, 0,255);
boundInt(transparency.inactive, 0,255);
//  l := curXStatusStr;
//  mainFrm.ChangeXStatus(curXStatus);
//  curXStatusStr := l;
//   RnQmain.sbar.Repaint;
  if Assigned(RnQmain) and Assigned(RnQmain.PntBar) then
    RnQmain.PntBar.Repaint;
histcrypt.pwdKey:=calculate_KEY1(histcrypt.pwd);

setVisibility(Account.AccProto, byte(RnQstartingVisibility));

dockSet;
  applyDocking;
  applyTransparency;

end; // setcfg

procedure loadCFG(zp : TZipFile);
var
 fn : String;
 s : RawByteString;
 i : Integer;
begin
  i := -1;
  if Assigned(zp) then
   try
     i := zp.IndexOf(configFileName);
     if i >= 0 then
      s := zp.data[i];
    except
     i := -1;
     s := '';
   end;
  if i < 0 then
   begin
    if FileExists(AccPath+configFileName) then
      fn := AccPath+configFileName
     else
      fn := AccPath+oldconfigFileName;
    if not FileExists(fn) then
      fn := myPath + defaultsConfigFileName;
    s := loadfileA(fn);
   end;

  MainPrefs.Load(s);
  s := loadfileA(cmdlinepar.extraini);
  MainPrefs.Load(s);
  s := '';
end;

procedure loadCommonCFG;
begin setcommonCFG(loadfileA(myPath+commonFileName)) end;

procedure saveCommonCFG;
begin
  savefile2(myPath+commonFileName, getCommonCFG, True, MakeBakups)
end;

function readOnlyFiles:boolean;

{  function recur(const path:string):boolean;
  var
    sr:TsearchRec;
  begin
  result:=TRUE;
  if FindFirst(path+'*.*', faAnyFile, sr)=0 then
    repeat
    if (sr.Attr and faReadOnly > 0) or (sr.name[1]<>'.') and (sr.Attr and faDirectory >0) and recur(path+sr.name+PathDelim) then
      begin
      findClose(sr);
      exit;
      end;
    until FindNext(sr) > 0;
  findClose(sr);
  result:=FALSE;
  end;
}
  function fileIsReadOnly(f : string) : Boolean;
  var
    i:integer;
  begin
    i:=FileGetAttr(f);
    if (i >= 0) and (i and faReadOnly >0) then
      result := TRUE
     else
      Result := False;
  end;
//var
//  i:integer;
//  sr:TsearchRec;
begin
  result:= fileIsReadOnly(myPath+commonFileName);
  if Result then
    Exit;
  if fileIsReadOnly(Account.ProtoPath + dbFilename+'5') {or
//  if fileIsReadOnly(userPath+dbFilename+'4') {or
     fileIsReadOnly(userPath+extstatusesFilename) or
     fileIsReadOnly(userPath+automsgFilename) or
     fileIsReadOnly(userPath+configFileName) or
     fileIsReadOnly(userPath+groupsFilename) or
     fileIsReadOnly(userPath+inboxFilename) or
     fileIsReadOnly(userPath+outboxFilename) or
     fileIsReadOnly(userPath+macrosFilename) or
     fileIsReadOnly(userPath+uinlistFilename) or
     fileIsReadOnly(userPath+SpamQuestsFilename) or
     fileIsReadOnly(userPath+reopenchatsFileName) or
     fileIsReadOnly(userPath+proxiesFilename) or
     fileIsReadOnly(userPath+rosterFileName1) or
     fileIsReadOnly(userPath+visibleFileName1) or
     fileIsReadOnly(userPath+invisibleFileName1) or
     fileIsReadOnly(userPath+ignoreFileName1) or
     fileIsReadOnly(userPath+nilFilename1) or
     fileIsReadOnly(userPath+retrieveFilename1)} then
    Result := True;
//  Exit;
{if FindFirst(mypath+'*.*', faDirectory, sr)=0 then
  repeat
  if (sr.Attr and faDirectory >0) and isOnlyDigits(sr.name) and recur(mypath+sr.name+PathDelim) then
    begin
    findClose(sr);
    exit;
    end;
  until FindNext(sr) > 0;
findClose(sr);
}
//result:=FALSE;
end; // readOnlyFiles

procedure beforeWindowsCreation;

  procedure parseCmdLinePar;
  var
    i:integer;
    s:string;
    UIN : TUID;
   prCl : TRnQProtoClass;
  begin
  myPath:=ExtractFilePath(paramStr(0));
  cmdlinepar.extraini := '';
  cmdlinepar.startUser:= '';
  cmdLinePar.mainPath := '';
  cmdLinePar.userPath := '';
  cmdLinePar.logpath  := '';
  logPath := myPath;
  cmdLinePar.useproxy := '';
  cmdLinePar.ssi := False;
//  masterUseSSI := False;
//  cmdLinePar.ssi := True;
  masterUseSSI := True;
//  icqdebug := False;
 {$IFDEF LANGDEBUG}
  lang_debug := False;
  xxx := false;
 {$ENDIF LANGDEBUG}
  i:=0;
  while i < paramCount() do
    begin
      inc(i);
      s:=paramStr(i);
      if s='--add-ini' then
        begin
        inc(i);
        cmdlinepar.extraini:=paramstr(i);
        end
    {$IFDEF RNQ_PLAYER}
      else
       if s='--rqp' then
        showRQP := True
    {$ENDIF RNQ_PLAYER}
      else
       if s='--ssi' then
        begin
          masterUseSSI := True;
          cmdLinePar.ssi := True;
        end
      else
       if s='--nossi' then
        begin
          masterUseSSI := False;
          cmdLinePar.ssi := False;
        end
      else
       if s='--nosound' then
        begin
          masterMute := True;
        end
      else
    {$IFDEF LANGDEBUG}
       if s='--lang' then
        lang_debug := True
      else
    {$ENDIF}
       if s='--xxx' then
         xxx := True
//      else
//       if s='--icqdebug' then
//         icqdebug := True
      else
       if s='--mainpath' then
        begin
         inc(i);
         cmdLinePar.mainPath := paramstr(i);
         cmdLinePar.mainPath := includeTrailingPathDelimiter(cmdLinePar.mainPath);
         if not DirectoryExists(cmdLinePar.mainPath) then
           begin
            if messageDlg(getTranslation('Directory "%s" does not exist. Do you want to create it?', [cmdLinePar.mainPath]), mtConfirmation, [mbYes,mbNo],0) = mrYes then
              CreateDir(cmdLinePar.mainPath)
             else
              cmdLinePar.mainPath := '';
           end;
        end
      else
       if s='--userpath' then
        begin
         inc(i);
         cmdLinePar.userPath := paramstr(i);
         cmdLinePar.userPath := includeTrailingPathDelimiter(cmdLinePar.userPath);
         if not DirectoryExists(cmdLinePar.userPath) then
           begin
            if messageDlg(getTranslation('Directory "%s" does not exist. Do you want to create it?', [cmdLinePar.userPath]), mtConfirmation, [mbYes,mbNo],0) = mrYes then
              CreateDir(cmdLinePar.userPath)
             else
              cmdLinePar.userPath := '';
           end;
        end
      else
       if s='--logpath' then
        begin
         inc(i);
         cmdLinePar.logpath := paramstr(i);
         cmdLinePar.logpath := includeTrailingPathDelimiter(cmdLinePar.logpath);
         if not DirectoryExists(cmdLinePar.logpath) then
           cmdLinePar.logpath := '';
        end
      else
       if s='--proxy' then
        begin
         inc(i);
         cmdLinePar.useproxy := paramstr(i);
//         cmdLinePar.useproxy := includeTrailingPathDelimiter(cmdLinePar.useproxy);
//         if not DirectoryExists(cmdLinePar.logpath) then
//           cmdLinePar.logpath := '';
        end
      else
      // is it an UIN ?
      try
//        if TryStrToInt64(ExtractFileName(s), uin) and validUIN(uin) then
        for prCl in RnQProtos do
         begin
         uin := s;
//         if prCl._isValidUid(uin) then
         if prCl._isProtoUid(uin) then
          cmdlinepar.startUser:=uin;
         end;
       except
      end;

    end
  end; // parseCmdLinePar

var
  s : String;
//  needCheckPass : Boolean;
  i : Integer;
//  l : RawByteString;
//  A, B : Integer;
//  Control : TControl;
//  d : Double;
//  aI : Int64;
//  sA : AnsiString;
//  dd : TDate;
begin
// msgDlg(UnixToDateTime(getTLVdwordBE(2, snac,ofs));
// msgDlg(DateToStr(UnixToDateTime($40E2D73A)), mtInformation);
//msgDlg(DateToStr(UnixToDateTime($40E2D73A)), mtInformation);
//msgDlg(DateToStr(UnixToDateTime($40E39EFB)), false, mtInformation);
//  l := #$40#$DE#$84#$00#$00#$00#$00#$00;
//  l := #$40#$E0#$0E#$C0#$00#$00#$00#$00;
//  l := #$40#$E0#$0E#$C0#$00#$00#$00#$00;
//  l := #$40#$E0#$86#$9C#$00#$00#$00#$00;
{  Int64((@dd)^)   := Qword_BEat(@l[1]);
//  dd := UnixToDateTime(Qword_BEat(@l[1]));
//  dd := UnixToDateTime(dword_BEat(@l[1]));
  if dd < Now then
    s := DateToStr(dd)
   else
//    s := IntToHex(DateTimeToUnix(now), 2);
    s := IntToHex(Int64((@dd)^), 2);
//  Int64((@dd)^)   := Qword_BEat(@l[1]);
  msgDlg(s, False, mtInformation);
}
// d := DateTimeToJulianDate(StrToDate('01.01.1981'));
// msgDlg(intToStr(invert(0139847)), mtConfirmation);
// ai := $9876ABCDEF;
// msgDlg(IntToHex(Int64(SwapLong(ai)), 8), mtConfirmation);
// SwapLong(@ai, 1);
// msgDlg(IntToHex(ai, 8), mtConfirmation);

// d := DateTimeToModifiedJulianDate(StrToDate('01.01.1981'));
// msgDlg(IntToHex((Int64((@d)^)), 8), mtConfirmation);
// i := $40DD9B4000000000;
// i := $40E323782635DAD5;
// d := Double((@i)^);
// msgDlg(DateToStr(ModifiedJulianDateToDateTime(d)), mtInformation);
// msgDlg(DateToStr(JulianDateToDateTime(d)), mtInformation);

// msgDlg(int2str64(int64((@d)^)), mtConfirmation);
// msgDlg(IntToHex(DateTimeToUnix(now), 8), mtInformation);
//   sA := '/LXcUfUBfTTCMnuJyI+0tWhkMQ08nEQ=';
//  sA := '/l5ajWuLiXce4gEmVNmDVTNnne4j';
//  sA := 'U4JhnJXr1qoN+lFNYw==';
//  sA := 'U4JhnJXr1qoN+lFN';
//  sA := qip_msg_decr(sA, '123', $1B5F);
// msgDlg(sA, false, mtInformation);
//
//  sA := 'How are you?';
//  sA := qip_msg_crypt(sA, '123', $1B5F);
//   sA := Base64DecodeString('AHRlc3QwMQAxMjM0NTY=');
//   msgDlg(sA, false, mtInformation);
// msgDlg(GetDomain('http://c.icq.com/xtraz/img/avatar/avatar_10529.swf'), mtInformation);
{   s := openSavedlg(NIL, True, '*');
   if s > '' then
    begin
     i := peer_oft_checksum_file(s);
     msgDlg(IntToHex(i, 2), mtInformation);
    end;
}
  if initOnce then
   begin
    exit;
   end;
  initOnce:=TRUE;
  startTime:=now;
  Application.Initialize;
  Application.ShowMainForm := False;
  application.HintHidePause:=60000;
  Application.Title := 'R&Q';

  parseCmdLinePar;

  WM_TASKBARCREATED:=RegisterWindowMessage('TaskbarCreated');

  {/$IFDEF usesDC}
  {/$ENDIF usesDC}
  timeformat.chat:= FormatSettings.shortdateformat+' hh:nn:ss';
  timeformat.info:= FormatSettings.shortdateformat+' hh:nn';
  timeformat.clock:='hh:nn';
  timeformat.log:= FormatSettings.shortdateformat+' hh:nn:ss.zzz';
  timeformat.automsg:='hh:nn';

  supportedBehactions[EK_msg]:=allBehactions;
  supportedBehactions[EK_url]:=allBehactions;
  supportedBehactions[EK_oncoming]:=allBehactions;
  supportedBehactions[EK_offgoing]:=allBehactions;
  supportedBehactions[EK_contacts]:=allBehactions;
  supportedBehactions[EK_addedyou]:=allBehactions;
  supportedBehactions[EK_auth]:=allBehactions;
  supportedBehactions[EK_authReq]:=allBehactions;
  supportedBehactions[EK_authDenied]:=allBehactions;
  supportedBehactions[EK_automsgreq]:=allBehactions;
  supportedBehactions[EK_statuschange]:=allBehactions;
//  supportedBehactions[EK_statuschangeExt]:=allBehactions;
  supportedBehactions[EK_gcard]:=allBehactions;
//  supportedBehactions[EK_file]:=allBehactionsButTip;
  supportedBehactions[EK_file]:=allBehactions;
  supportedBehactions[EK_automsg] :=allBehactions;
  supportedBehactions[EK_typingBeg] := mtnBehactions;
  supportedBehactions[EK_typingFin] := mtnBehactions;
  supportedBehactions[EK_XstatusMsg]:=allBehactions;
  supportedBehactions[EK_Xstatusreq]:=allBehactions;

  resetCommonCFG;
  loadCommonCFG;

  LoadSomeLanguage;
//  LangVar := TRnQLang.Create;
//  LangVar.loadLanguage;

  if check4readonly and readOnlyFiles then
   begin
     msgDlg('Some files are read-only, so R&&Q can''t start', True, mtWarning);
     halt;
   end;


  AllProxies := NIL;
  refreshAvailableUsers;
  uin2Bstarted := '';
  AccPass := '';
//  needCheckPass := True;
  if cmdlinepar.startUser > '' then
    begin
     uin2Bstarted := extractFileName(cmdlinepar.startuser);
    end
  else
   begin
     i := findInAvailableUsers(autostartUIN);
     if i >= 0 then
       begin
         uin2Bstarted:=autostartUIN;
         masterUseSSI := cmdLinePar.ssi or availableusers[i].SSI;
       end
     else
      if length(availableusers)=1 then
        begin
          uin2Bstarted:=availableusers[0].uin;
          masterUseSSI := cmdLinePar.ssi or availableusers[0].SSI;
        end
   end;
  if uin2Bstarted > '' then
    begin
      i:=findInAvailableUsers(uin2Bstarted);
      if i >=0 then
       begin
//       if needCheckPass then
        with availableUsers[i] do
        if encr and not CheckAccPas(uin, path+ SubPath + PathDelim + dbFilename + '5', AccPass)  then
         begin
//           halt(0);
           uin2Bstarted := '';
         end;
       end
      else
       uin2Bstarted := '';
    end;
  if  uin2Bstarted = '' then
    begin
     uin2Bstarted:=showUsers(AccPass);
//     needCheckPass := False;
    end;

  if uin2Bstarted='' then halt(0);

  repeat
    s := 'R&Q' + uin2Bstarted;
    Mutex:=OpenMutex(MUTEX_MODIFY_STATE, false, PChar(s));
    if Mutex<>0 then
    begin
      CloseHandle(Mutex);
//      needCheckPass := false;
//      mutex := 0;
      msgDlg(Str_already_run, True, mtWarning);
      uin2Bstarted:=showUsers(AccPass);
      if uin2Bstarted='' then halt(0);
  //    Halt(0);
    end;
  until Mutex=0;

   i:=findInAvailableUsers(uin2Bstarted);
   if i < 0 then
     begin
      msgDlg('StartUser: Bad UIN', True, mtError);
      halt(1);
     end;


  Account.acks   := Toutbox.create;
  Account.outbox := Toutbox.create;
//  visibleList:=TRnQContactList.create;
//  invisibleList:=TRnQContactList.create;
  notinlist:=TRnQCList.create;
  ignoreList:=TRnQCList.create;
  autoMessages:=TstringList.create;
  updateViewInfoQ:=TRnQCList.create;

   {$IFDEF CHECK_INVIS}
    CheckInvis.CList:=TRnQCList.create;
   {$ENDIF}
  groups:=Tgroups.create;
  //theme.smiles.root:=myPath;
  uinlists:=Tuinlists.create;
  retrieveQ:=TRnQCList.create;
  reqAvatarsQ:=TRnQCList.create;
  reqXStatusQ:=TRnQCList.create;
   {$IFDEF CHECK_INVIS}
  checkInvQ:=TRnQCList.create;
  autoCheckInvQ:=TRnQCList.create;
   {$ENDIF CHECK_INVIS}
  LoadTranslit;

  childWindows:=Tlist.create;
  resolving:=FALSE;
  locked:=FALSE;
  autoaway.time:=0;
  userTime:=-1;
  eventQ:=TeventQ.create;
  statusIcon:=TstatusIcon.create;
  statusIcon.OnGetPicTip := Protocols_All.getTrayIconTip;
  eventQ.onNewTop:=statusIcon.update;
  hotkeysEnabled:=TRUE;
  plugins:=Tplugins.create;
  portsListen := TPortList.Create;
end; // beforeWindowsCreation

procedure startUser;
  procedure ParseAbout(zp : TZipFile; var UID : TUID);
  var
    i : Integer;
    cfg, l, h : RawByteString;
  begin
    cfg := '';
    if Assigned(zp) then
     try
       i := zp.IndexOf(AboutFileName);
       if i >= 0 then
        cfg := zp.data[i];
      except
     end;
    while cfg > '' do
      begin
    //  l:=chop(CRLF,cfg);
    //  h:=chop('=',l);
        l:=LowerCase(chop(CRLF,cfg));
        h:=Trim(chop(AnsiString('='),l));
        l := trim(l);
        try
          if h='account-id' then
            begin
              UID := l;
              Break;
            end;
        finally
        end;
      end;
  end;

const
  maxProg=17;
var
  i //, k
    :integer;
  thisUser : TRnQUser;
//  useProxy : Integer;
//  v_proxyes : TarrProxy;
  s  : String;
//  pr : TRnQProtocol;
  dbZip : TZipFile;
  zipPrefs : Boolean;
  MyInf : TRnQContact;
  AccUID : TUID;
begin
 i:=findInAvailableUsers(uin2Bstarted);
 if i < 0 then
  begin
   msgDlg('StartUser: Bad UIN', True, mtError);
   halt(1);
  end;
  s := 'R&Q' + uin2Bstarted;
//there is no previous Mutex so create new one
  Mutex:=CreateMutex(nil,false, PChar(s));

//take ownership of our mutex
  WaitForSingleObject(Mutex,INFINITE);

  thisUser := availableUsers[i];
  AccPath := thisUser.path + thisUser.SubPath + PathDelim;


  logpref.evts.onWindow := True;
//  loadCommonCFG;

  if cmdLinePar.logpath > '' then
    logPath := cmdLinePar.logpath
   else
    logPath := mypath;

  loggaEvtS('user: ('+ thisUser.proto._GetProtoName+')'+
                  thisUser.uin+' starting');

  setProgBar(nil, 1/maxProg);


  MainPrefs := TRnQPref.Create;


  fantomWork := not DirectoryExists(AccPath); // New фича 2007.10.09

  helpExists := FileExists(myPath + docsPath + getTranslation(helpFilename));

  zipPrefs := false;
  dbZip := NIL;

  s := AccPath + dbFilename + '5';
  if not FileExists(s) then
    s := AccPath + dbFilename + '4';
  if not FileExists(s) then
   begin // Trying to find saved files
     s := AccPath + dbFilename + '5.new';
     if not FileExists(s) then
       begin
         s := AccPath + dbFilename + '5.bak';
         if not FileExists(s) then
           s := '';
       end
   end;
    
  if (s > '') then
   begin
     dbZip := TZipFile.Create;
     try
       dbZip.LoadFromFile(s);
       zipPrefs := dbZip.Count > 0;
       dbZip.Password := AccPass;
      except
        msgDlg('Error while opening DB archive', True, mtError);
//       zipPrefs := false;
     end;
     if not zipPrefs then
      begin
       FreeAndNil(dbZip);
      end;
   end;

  loadCFG(dbZip);
  loggaEvtS('CFG: loaded');

  AccUID := uin2Bstarted;
  ParseAbout(dbZip, AccUID);
  if AccUID = '' then
    AccUID := uin2Bstarted;

 with thisUser do
  begin
   Account.ProtoPath := AccPath;
 {$IFDEF ICQ_ONLY}
   Account.AccProto := TicqSession.Create(AccUID, SESS_IM);
 {$ELSE ~ICQ_ONLY}
   Account.AccProto := proto._CreateProto(AccUID).ProtoElem;
 {$ENDIF ICQ_ONLY}

 {$IFNDEF ICQ_ONLY}
   if proto._getProtoID = MRAProtoID then
      begin
        RnQmain.MlCntBtn.Visible := True;
        RnQmain.MlCntBtn.Caption := getTranslation('Mails in box: %d', [0]);
      end
    else
 {$ENDIF ICQ_ONLY}
      RnQmain.MlCntBtn.Visible := False;

   RnQUser := AccUID + ' "'+ name+ '"';
   if pwd > '' then
     Account.AccProto.pwd := pwd;
  end;

//mainfrm.setProgBar(2/maxProg);     // все равно лишнее, т.к. диалог

  keepalive.timer:=0;
  stayconnected:=FALSE;

//  MainProto.ProtoElem.listener:= RnQmain.ProtoEvent;
  Account.AccProto.SetListener(RnQmain.ProtoEvent);
  Account.AccProto.ProtoElem.sock.OnDnsLookupDone := RnQmain.dnslookup;
  InitProtoMenus;
  resetCFG;

  setCFG(MainPrefs);

// reset log files
  if logpref.evts.clear then deletefile(logPath+eventslogFilename);
  if logpref.pkts.clear then deletefile(logPath+packetslogFilename);

  if logpref.evts.onfile and not fileIsWritible(logPath+eventslogFilename) then
   begin
    logpref.evts.onfile := False;
    msgDlg(getTranslation('Can''t write to file: "%s"',[eventslogFilename]), False, mtError);
   end;
  if logpref.pkts.onfile and not fileIsWritible(logPath+packetslogFilename) then
   begin
    logpref.pkts.onfile := False;
    msgDlg(getTranslation('Can''t write to file: "%s"',[packetslogFilename]), False, mtError);
   end;

  loggaEvtS('R&Q: '+intToStrA(RnQBuild) +' starting');

  LoadProxies(dbZip, AllProxies);
  loggaEvtS('theme: loading');
  reloadCurrentTheme;
  picDrawFirstLtr := theme.ThemePath.fn = '';
  loggaEvtS('theme: loaded');


  loggaEvtS('DB: loading');
  groups.fromString(loadFromZipOrFile(dbZip, Account.ProtoPath, groupsFilename));
  loadDB(dbZip, True);
  loggaEvtS('DB: loaded');

//mainfrm.setProgBar(3/maxProg);     // показывается только после loadCfg

  if Assigned(Account.AccProto) then
    Account.AccProto.SetPrefs(MainPrefs);

//mainfrm.setProgBar(4/maxProg);

  startTimer;

  if cmdLinePar.useproxy > '' then
   begin
//     LoadProxies(v_proxyes);
     for I := 0 to Length(AllProxies) - 1 do
      if (AllProxies[i].name = cmdLinePar.useproxy)or
         ('"'+AllProxies[i].name+'"' = cmdLinePar.useproxy)  then
       begin
//         useProxy := i;
         CopyProxy(MainProxy, AllProxies[i]);
         break;
       end;
//     ClearProxyArr(v_proxyes);
   end;
  if MainProxy.serv.host = '' then
    MainProxy.serv := Account.AccProto.ProtoElem._getDefHost;
//showForm(mainfrm);
  setProgBar(nil, 5/maxProg);

  if not startMinimized then
    showForm(RnQmain);
  setProgBar(nil, 7/maxProg);
  toggleMainfrmBorder(True, showMainBorder);
  chatFrm.SetSmilePopup(not ShowAniSmlPanel);
loggaEvtS('hotkeys: loading');
loadMacros(dbZip);
  setProgBar(nil, 8/maxProg);
updateSWhotkeys;
loggaEvtS('hotkeys: loaded');
if not skipsplash then showSplash;
  lastUser  := uin2Bstarted;
  if RnQStartingStatus < 0 then
    lastStatus := lastStatusUserSet
   else
    begin
      lastStatusUserSet:= byte(SC_UNK);
      lastStatus:= RnQstartingStatus;
    end;
if PREVIEWversion and (Account.AccProto.ProtoElem is TicqSession) then
 begin
  checkupdate.autochecking := True;
  if contactsDB.exists(Account.AccProto, IntToStrA(uinToUpdate)) then
   if CheckUpdates(TicqSession(Account.AccProto.ProtoElem).getICQContact(uinToUpdate)) then // contactsDB.get( TICQContact, uinToUpdate)) then
    begin
     halt(1);
    end;
 end;
//  MainProto.MyInfo := MainProto.getContact(lastUser);
//ICQ.myinfo:= TicqSession.getICQContact(lastUser);
{
  if MainProto.ProtoName = 'ICQ' then
   begin
    with TICQcontact(MainProto.getMyInfo) do
      begin
//        status := ticqStatus(SC_OFFLINE);
        ICQIcon.hash_safe := myAvatarHash;
      end;
   end;
}
//setVisibility(MainProto, byte(VI_normal));
setVisibility(Account.AccProto, byte(RnQstartingVisibility));
//myStatus:= byte(SC_OFFLINE);

  setProgBar(nil, 9/maxProg);
LoadExtSts(dbZip);
loadSpamQuests(dbZip);
loggaEvtS('lists: loading');
loadLists(Account.AccProto, dbZip, Account.ProtoPath);
loggaEvtS('lists: loaded');

mainDlg.RnQmain.roster.Visible := True;
mainDlg.RnQmain.SetFocusedControl(mainDlg.RnQmain.roster);
// lastUser := intToStr(StrToInt('Bag'));
  setProgBar(nil, 10/maxProg);
//icq.webaware:=webaware;

  RnQUser := Account.AccProto.ProtoElem.MyAccNum;
  MyInf := Account.AccProto.getMyInfo;
  if Assigned(MyInf) then
    RnQUser := MyInf.displayed;

  if not skipsplash then
    theme.PlaySound('start');

loggaEvtS('Various lists: loading');
  setProgBar(nil, 11/maxProg);
// load tables
  setProgBar(nil, 12/maxProg);
loadAutoMessages(dbZip);
  setProgBar(nil, 13/maxProg);

//loggaEvt('outbox: loading');
loadOutInbox(dbZip);
//loggaEvt('outbox: loaded');
//loggaEvt('inbox: loading');
//loadInbox((dbZip));
//loggaEvt('inbox: loaded');
  setProgBar(nil, 14/maxProg);

loggaEvtS('Various lists: loaded');

  RnQmain.updateCaption;
  loggaEvtS('Lang: Translating');
   translateWindows;
  loggaEvtS('Lang: Translated');
 rosterRebuildDelayed:=TRUE;
{ $I-}
 {$IFNDEF DB_ENABLED}
  if not DirectoryExists(Account.ProtoPath+historyPath) then
   mkdir(Account.ProtoPath+historyPath);
 {$ENDIF DB_ENABLED}
{ $I+}
   {$IFDEF RNQ_AVATARS}
 IOresult;
  if not DirectoryExists(AccPath + avtPath) then
    mkdir(AccPath + avtPath);
 IOresult;
  loggaEvtS('Avatars: loading');
  loadAvatars(Account.AccProto, AccPath + avtPath);
  loggaEvtS('Avatars: loaded');
   {$ENDIF RNQ_AVATARS}
 setRosterAnimation(animatedRoster);
 statusIcon.trayicon.show;
 statusIcon.update;
 contactsPnlStr := intToStr(TList(Account.AccProto.readList(LT_ROSTER)).count);
 Account.acks.clear;
  if assigned(prefFrm) then
    prefFrm.reset;
  setProgBar(nil, 15/maxProg);
 {$IFDEF DB_ENABLED}
  RnQmain.mAHistoryUtils.Visible := false;
 {$ELSE ~DB_ENABLED}
  RnQmain.mAHistoryUtils.Visible := histUtilsDlg.load;
 {$ENDIF ~DB_ENABLED}
  setProgBar(nil, 16/maxProg);
  setupChatButtons;
  chatFrm.UpdatePluginPanel;
  plugins.load;
  if reopenchats then
   begin
//    chatFrm.Visible := False;
    chatFrm.loadPages(loadFromZipOrFile(dbZip, Account.ProtoPath, reopenchatsFileName));
//    chatFrm.Visible := True;
   end;
// if Assigned(dbZip) then
   FreeAndNil(dbZip);

// All loaded!

  try  // If exists old type files - delete them all
    RenameFile(AccPath +dbFileName+'4', AccPath + dbFileName + '4.bak');
    DeleteFile(AccPath +dbFileName+'4');
    DeleteFile(AccPath +dbFileName+'3');
    DeleteFile(AccPath +dbFileName);
   {$IFDEF CHECK_INVIS}
    DeleteFile(AccPath + CheckInvisFileName1);
   {$ENDIF CHECK_INVIS}
    DeleteFile(AccPath + rosterFileName1);
    DeleteFile(AccPath + groupsFilename);
    DeleteFile(AccPath + visibleFileName1);
    DeleteFile(AccPath + invisibleFileName1);
    DeleteFile(AccPath + ignoreFileName1);
    DeleteFile(AccPath + nilFilename1);
    DeleteFile(AccPath + retrieveFilename1);
    DeleteFile(AccPath + configFileName);
    DeleteFile(AccPath + inboxFilename);
    DeleteFile(AccPath + outboxFilename);
    DeleteFile(AccPath + macrosFileName);
    DeleteFile(AccPath + uinlistFilename);
    DeleteFile(AccPath + reopenchatsFileName);
    DeleteFile(AccPath + automsgFilename);
    DeleteFile(AccPath + SpamQuestsFilename);
    DeleteFile(AccPath + extstatusesFilename);
    DeleteFile(AccPath + proxiesFileName);
   except
//    RnQFileUtil.saveFile(userPath+dbFileName, s, True);
    msgDlg('Error on deleting old lists', True, mtError);
  end;



 if lockOnStart then
  begin
    startingLock:=TRUE;
    if not doLock then
      Exit;
  enD;
 startingLock:=FALSE;

 if docking.Dock2Chat and docking.Docked2chat then
   begin
     RnQmain.WindowState := wsNormal;
     showForm(RnQmain);
     bringForeground:= chatFrm.Handle
   end
  else
   bringForeground:=RnQmain.handle;
 userTime:=0;
  setProgBar(nil, 0);
  if autoConnect then
    doConnect;
 loggaEvtS('user: started');
 CheckBDays;
//if not startMinimized then
//  showForm(mainfrm);
//SetMenu(mainFrm.Handle, mainFrm.menu.Handle);

end; // startUser


procedure quitUser;
var
  pr : TRnQProtocol;
begin
if userTime < 0 then exit;
userTime:=-1;

  loggaEvtS('Quit user');
  stopMainTimer;
  TipsHideAll;
  chatFrm.closeAllPages(True);
  mainDlg.RnQmain.roster.Visible := False;

{if notInList.empty or (NILdoWith = 1)
   or ((NILdoWith = 0) and (messageDlg(getTranslation('You have some not-in-list contact.\nDo you want to see them next time?'),mtConfirmation,[mbyes,mbNo],0, mbYes, 30) = mrNo)) then
  deleteFile(userPath+nilFileName1)
else
  if not saveFile(userPath+nilFileName1, notinlist.toString) then
    msgDlg(getTranslation('Error saving not-in-list'),mtError);
}
  if (NILdoWith = 1) or
     ((NILdoWith = 0) and not notInList.empty
      and (messageDlg(getTranslation('You have some not-in-list contact.\nDo you want to see them next time?'),mtConfirmation,[mbyes,mbNo],0, mbYes, 30) = mrNo)
     )  then
    notInList.Clear;

//theme.PlaySound('quit');


  flushHistoryWritingQ();
  FlushLogPktFile();
  FlushLogEvFile();

  roasterLib.clear;
  if not (startingLock or fantomWork) then
   begin
//    groups.save;
//    saveLists(MainProto);
//    saveInbox;
//    saveOutbox;
//    saveCFG;
//    saveAutoMessages;
//    saveMacros;
//    saveDB;
//    saveRetrieveQ;
//    if reopenchats then chatFrm.savePages;
//    SaveExtSts;
//    SaveSpamQuests;
    UpdateProperties;
    savecommonCFG;
    saveAllLists(Account.ProtoPath, Account.AccProto, AllProxies);
   end
//  else
//   roasterLib.clear;
    ;
 loggaEvtS('Properties saved');

  AccPass := '';
  MainPrefs.Free;
  MainPrefs := NIl;

  Account.Outbox.Clear;
  eventQ.clear;
  groups.clear;
  UnloadAutomessages;
  RnQmain.roster.Clear;
  FreeAndNil(prefFrm);
 FreeAndNil(wpFrm);  // we must free it before closeAllChildWindows to avoid AV
//freeandnil();
  RnQmain.closeAllChildWindows;

 plugins.unload;
 Account.AccProto.clear;

 notinlist.clear;
 retrieveQ.clear;
 reqAvatarsQ.Clear;
 {$IFDEF CHECK_INVIS}
  autoCheckInvQ.Clear;
  CheckInvQ.Clear;
  if Assigned(CheckInvis.CList) then
    CheckInvis.CList.Clear;
 {$ENDIF}

 clearDB(contactsDB);
  try
    if Assigned(Account.AccProto) then
     begin
      pr := Account.AccProto.ProtoElem;
      Account.AccProto := NIL;
      pr.Free;
     end;
   except
  end;
  try
    Account.AccProto := NIL;
   except
  end;

 reqXStatusQ.Clear;
 DragAcceptFiles(RnQmain.Handle, FALSE);
 RnQmain.oldHandle := 0;

 theme.ClearThemelist;
  if Assigned(ContactsTheme) then
    ContactsTheme.Clear(tsc_all);
//rqSmiles.Clear(tsc_all);
Theme.Clear(tsc_all);
//destroy our mutex
 try
  CloseHandle(Mutex);
  Mutex := 0;
 Except
 end;
 loggaEvtS('User exited');
//  FreeAndNil(RnQprefs);
end; // quitUser

const
  splitMsg='automsg: ';
  autoaway_name='AUTO-AWAY';

{procedure saveAutomessages;
var
  i:integer;
  s:string;
begin
s:=automessages[0]+CRLF;
i:=1;
while i < automessages.count do
  begin
  s:=s+splitMsg+automessages[i]+CRLF+automessages[i+1]+CRLF;
  inc(i,2);
  end;

s:=s+splitMsg+autoaway_name+CRLF+autoaway.msg+CRLF;
saveFile(userPath+automsgFileName, s);
s:='';
end; // saveautomessages}

procedure loadAutomessages(zp : TZipFile);
var
  s : RawByteString;
  name,text:string;

  function split(sp: RawByteString): String;
  var
    i:integer;
  begin
    i:=pos(sp,s);
    if i=0 then
      i:=length(s)+1;
    result := UnUTF(copy(s,1,i-1));
    delete(s,1,i+length(sp)-1);
  end; // chop

begin
//s:=loadFile(userPath+automsgFileName);
  s:= loadFromZipOrFile(zp, Account.ProtoPath, automsgFileName);
{if s = '' then
  begin
//  s:=loadFile(langPath+defaultPrefix+automsgFileName);
   s:=loadFile(defaultPrefix+automsgFileName);
//  if s = '' then
//    s:=loadFile(defaultlangPath+defaultPrefix+automsgFileName);
  end;
}
automessages.clear;
automessages.add(excludeTrailingCRLF(split(splitMsg)));
while s > '' do
  begin
  name:= excludeTrailingCRLF(split(CRLF));
  text:= excludeTrailingCRLF(split(splitMsg));
  if name = autoaway_name then
    autoaway.msg:=text
   else
    begin
     automessages.add(name);
     automessages.add(text);
    end;
  end;
end; // loadAutomessages

procedure UnloadAutomessages;
begin
  automessages.Clear;
end;

{procedure saveMacros;
begin saveFile(userPath+macrosFileName, macros2str(macros), True) end;
}
procedure loadMacros(zp : TZipFile);
var
  s : RawByteString;
  i : Integer;
begin
  i := -1;
  if Assigned(zp) then
   try
     i := zp.IndexOf(macrosFileName);
     if i >= 0 then
      s := zp.Data[i];
    except
     i := -1;
     s := '';
   end;
  if i < 0 then
    s := loadFileA(Account.ProtoPath + macrosFileName);
  str2macros(s, macros)
end;

procedure quit;
begin
 if not initOnce then exit;
 initOnce:=FALSE;
   plugins.castEv( PE_QUIT); // Added For Test Purpose

 SoundUnInit;
 disablesounds := True;

 running := false;
 stayconnected:=FALSE;

 stopMainTimer;

 try
   Account.AccProto.disconnect;
   Application.ProcessMessages;
  except
 end;
 uninstallHook;

 RnQmain.hide;
 freeAndNIL(statusIcon);
 eventQ.OnNewTop:=NIL;
 chatFrm.updateChatfrmXY;
 quitUser;
 quitconfirmation := false;
 FreeAndNil(logfrm);

// applyDocking(True);
 RnQmain.roster.EndUpdate;

// freeAndNIL(xStatusForm);
// ClearThemelist;
 UnLoadTranslit;
 freeAndNIL(plugins);
 ClearLanguage;

 clearAvailableUsers;
 ClearPrefPages;

  try
    if Assigned(Account.AccProto) then
      Account.AccProto.ProtoElem.Free;
   except
  end;
  try
    Account.AccProto := NIL;
   except
  end;

//  freeAndNIL(visibleList);
//  freeAndNIL(invisibleList);
  freeAndNIL(notinlist);
  freeAndNIL(ignoreList);

  freeAndNIL(autoMessages);
  freeAndNIL(updateViewInfoQ);

  freeAndNIL(childWindows);

  {$IFDEF CHECK_INVIS}
 freeAndNIL(CheckInvis.CList);
 freeAndNIL(autoCheckInvQ);
 freeAndNIL(CheckInvQ);
  {$ENDIF CHECK_INVIS}
 FreeAndNil(reqXStatusQ);
 FreeAndNil(reqAvatarsQ);
 freeAndNIL(retrieveQ);
 freeAndNIL(groups);
 freeAndNIL(Account.outbox);
// acks.clear;
 freeAndNIL(Account.acks);
 freeAndNIL(eventQ);
// freeAndNIL(statusIcon);
 freeAndNIL(uinlists);
// freeAndNIL(Account.AccProto);
 freeAndNIL(prefFrm);
 FreeAndNil( portsListen );
  FlushLogPktFile();
 loggaEvtS('shutdown', '', True);
//  FlushLogEvFile();

// RnQmain.Close;
 application.Terminate;
end; // quit

procedure afterWindowsCreation;
var
  i:integer;
begin
  hintMode:=HM_null;
  application.OnHint := RnQmain.displayHint;

  RnQmain.roster.NodeDataSize := SizeOf(Pointer);
  running:=TRUE;
  mainfrmHandleUpdate;

  applyDocking;
  applyTransparency;
  for i:=0 to Screen.FormCount-1 do
    applyCommonSettings(screen.forms[i]);
 {$IFNDEF NO_WIN98}
  if not isHooked then
    msgDlg('Error loading HOOK.DLL\nSome features won''t work', True, mtWarning);
 {$ENDIF NO_WIN98}

  SoundInit;
//ShowHintsInChat2 := True;
end; // afterWindowsCreation


begin
 initOnce:=FALSE;
 onContactCreation:=ContactCreation;
 onContactDestroying:=contactDestroying;
end.
