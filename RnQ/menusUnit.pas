{
This file is part of R&Q.
Under same license
}
unit menusUnit;
{$I RnQConfig.inc}
{$I NoRTTI.inc}

interface
 uses
   Classes, Menus, RQThemes, RQMenuItem, RnQMenu, RnQProtocol;

  procedure InitMenu;
  procedure InitProtoMenus(pProto: TRnQProtocol);
  procedure InitMenuChats;
  procedure createMenusExt;

  procedure addSmilesToMenu(own: Tcomponent; mi: Tmenuitem; action: TnotifyEvent);
  procedure addGroupsToMenu(own: Tcomponent; mi: Tmenuitem; action: TnotifyEvent; pAddOut: Boolean);
  procedure createFavMenu(root: Tmenuitem; action: TnotifyEvent);

  procedure ClearAllMenuArrays;


var
  aMainMenuUpd, aMainMenuUpd2,
  aStatusMenuUpd, aVisMenuUpd: aTaMenuItemUpd;

  aChatMenuUpd: aTaMenuItemUpd;

  aSendMenu     : aTaMenuItem; // Menu of button "Send" in chat
  aCloseMenu    : aTaMenuItem; // Menu of button "Close" in chat
 {$IFDEF USE_SECUREIM}
  aEncryptMenu  : aTaMenuItem; // Menu of button "Encrypt" in chat
 {$ENDIF USE_SECUREIM}
  aEncryptMenu2 : aTaMenuItem; // Menu of button "Encrypt" in chat
  aFileSendMenu : aTaMenuItem; // Menu of button "Send File" in chat

implementation
  uses
    mainDlg, globalLib, themesLib, chatDlg,
    SysUtils, RDGlobal, RDUtils, RnQSysUtils, RnQGlobal,
    RnQLangs, utilLib, RnQPics,
    shlObj,
    iniLib;

var
  aMainMenu : aTaMenuItem;
  aStsMenu  : aTaMenuItem;
  aVisMenu  : aTaMenuItem;


//const
//  aMainMenu: array[0..1] of TaMenuItem =
//        ((amiName: 'About'; Ev: TmainFrm.About1Click),
//        ( ID: 2; Value: 'Male'));
{
procedure ClearMenuMass(var mass : aTaMenuItem);
var
  i : Byte;
begin
  if Length(mass) > 0 then
  begin
    for I := 0 to Length(mass) - 1 do
    with mass[i] do
      begin
        amiName := '';
        amiCaption := '';
        amiImage := '';
  //      amiEv := NIL;
  //      amiUpd := NIL;
      end;
    SetLength(mass, 0);
  end;
end;

procedure addToMenuMass(var mass : aTaMenuItem; idx : Integer; const name : String;
              const Cptn, Hint : String;
              const ImName : TPicName; Ev, Upd : TNotifyEvent);
var
  i : Byte;
begin
  i := length(mass);
  SetLength(mass, i+1);
  with mass[i] do
    begin
      amiIdx  := idx;
      amiName := name;
      amiCaption := Cptn;
      amiImage := imName;
      amiEv := ev;
      amiUpd := Upd;
    end;
end;
}
procedure InitMenu;
//var
//  I: Integer;
//  st1 : Tstatus;
//  vis1 : Tvisibility;
//  st : TStatusProp;
//  stArr : TStatusArray;
begin
{ $IFDEF RNQ_FULL}
 addToMenuMass(aMainMenu, MaxInt-20, 'MnuPrefs', 'Preferences', '',
      PIC_PREFERENCES, RnQmain.Preferences1Click, nil);
{ $ENDIF RNQ_FULL}
 addToMenuMass(aMainMenu, MaxInt-17, 'MnuMyInfo', 'View my info', '',
      PIC_INFO, RnQmain.Viewmyinfo1Click, nil);
 {$IFDEF RNQ_PLAYER}
 if showRQP and audioPresent then
   addToMenuMass(aMainMenu, MaxInt-15,'MnuRnQPlayer','R&&Q Player', '',
      PIC_PLAYER, RnQmain.mARnQPlayerExecute, nil);
 {$ENDIF RNQ_PLAYER}
 addToMenuMass(aMainMenu, MaxInt-10, 'MnuDivisor', '-', '', '', nil, nil);
//      amiEv := mainFrm.About1Click;
 addToMenuMass(aMainMenu, MaxInt-6, 'MnuAbout', 'About program', '',
      PIC_RNQ, RnQmain.About1Click, nil);
 addToMenuMass(aMainMenu, MaxInt-5, 'MnuHelp', 'Help', '',
      PIC_HELP, RnQmain.mAHelpExecute, RnQmain.mAHelpUpdate);
 addToMenuMass(aMainMenu, MaxInt-4, 'MnuHide', 'Hide', '',
      PIC_HIDE, RnQmain.Hide1Click, RnQmain.mAhideUpdateEx);
// addToMenuMass(aMainMenu, MaxInt-3, 'MnuRestart', 'Restart', '',
//      'restart', RnQmain.ReStart, nil);
 addToMenuMass(aMainMenu, MaxInt-2, 'MnuExit', 'Exit', '',
      PIC_QUIT, RnQmain.Exit1Click, nil);
end;

procedure InitProtoMenus(pProto: TRnQProtocol);

var
  I: Integer;
  b: Byte;
//  vis1: Tvisibility;
//  st: TStatusProp;
  stArr, visArr: TStatusArray;
begin
////////////// Status Menu \\\\\\\\\\\\\\\\\
  ClearMenuMass(aStsMenu);
  i := 1;
  stArr := pProto.statuses;
  for b in pProto.getStatusMenu do
  begin
   addToMenuMass(aStsMenu, i, stArr[b].ShortName, stArr[b].Cptn, '',
      stArr[b].ImageName, RnQmain.StatusMenuClick, nil);
   aStsMenu[i-1].amiTag := b;
   inc(i);
  end;
  addToMenuMass(aStsMenu, i, 'amSplit1', '-',
      '', '', NIL, nil);
  inc(i);
  addToMenuMass(aStsMenu, i, 'autoMsg1', 'Auto-message',
      '', 'msg', RnQmain.Automessage1Click, RnQmain.AAutomessage1Update);
  inc(i);
  addToMenuMass(aStsMenu, i, 'XStatus1', 'XStatus',
      '', 'xstatus', RnQmain.mAXStatusExecute, RnQmain.mAXStatusUpdate);

////////////// Vis Menu \\\\\\\\\\\\\\\\\
  ClearMenuMass(aVisMenu);
  i := 1;
  visArr := pProto.getVisibilitis;
  if Assigned(visArr) then
    begin
     RnQmain.visibilityBtn.Visible := True;
     for b in pProto.getVisMenu do
      begin
       addToMenuMass(aVisMenu, i, visArr[b].ShortName, visArr[b].Cptn, '',
          visArr[b].ImageName, RnQmain.VisMenuClick, nil);
       aVisMenu[i-1].amiTag := b;
       inc(i);
      end;
    end
   else
    RnQmain.visibilityBtn.Visible := False;

  SetLength(aMainMenuUpd2, 0);

  FreeAndNil(RnQmain.statusMenuNEW);
  SetLength(aStatusMenuUpd, 0);
  clearMenu(RnQmain.Status1);

  RnQmain.statusMenuNEW := TPopupMenu.Create(RnQmain);
  for i := 0 to Length(aStsMenu)-1 do
   begin
    AddToMenu('', aStsMenu[i], RnQmain.statusMenuNEW.Items, aStatusMenuUpd);
    AddToMenu('', aStsMenu[i], RnQmain.Status1, aMainMenuUpd2);
   end;
  RnQmain.statusMenuNEW.OnPopup := RnQmain.StatusMenuPopup;

  FreeAndNil(RnQmain.vismenuExt);
  SetLength(aVisMenuUpd, 0);
  clearMenu(RnQmain.mainmenuvisibility1);

  RnQmain.vismenuExt := TPopupMenu.Create(RnQmain);
  for i := 0 to Length(aVisMenu)-1 do
   begin
    AddToMenu('', aVisMenu[i], RnQmain.vismenuExt.Items, aVisMenuUpd);
    AddToMenu('', aVisMenu[i], RnQmain.mainmenuvisibility1, aMainMenuUpd2);
   end;
  applyCommonSettings(RnQmain.statusMenuNEW);
  applyCommonSettings(RnQmain.vismenuExt);
end;

procedure InitMenuChats;
begin
  addToMenuMass(aSendMenu, 1, 'SendMultiple', 'Multiple', '',
      '', chatFrm.Sendmultiple1Click, nil);
  addToMenuMass(aSendMenu, 2, 'SendWhenVis', 'When i''m visible to him/her', '',
      PIC_VISIBLE_TO, chatFrm.SendWhenImVisibleToHimHer1Click, nil);
  addToMenuMass(aSendMenu, 3, 'SendAllOpen', 'To all open chats', '',
      '', chatFrm.chatSendMenuOpen1Click, nil);

  addToMenuMass(aCloseMenu, 1, 'CloseAll', 'Close all', '',
      '', chatFrm.CloseAll1Click, nil);
  addToMenuMass(aCloseMenu, 2, 'CloseAllbutThisone', 'Close all but this one', '',
      '', chatFrm.Closeallbutthisone1Click, nil);
  addToMenuMass(aCloseMenu, 3, 'CloseAllOFFLINEs', 'Close all OFFLINEs', '',
      '', chatFrm.CloseallOFFLINEs1Click, nil);
  addToMenuMass(aCloseMenu, 4, 'chatcloseignore1', 'Close and Add to Ignore list', '',
      '', chatFrm.chatcloseignore1Click, nil);
  addToMenuMass(aCloseMenu, 5, 'CloseallandAddtoIgnorelist1', 'Close all NIL and Add to Ignore list', '',
      '', chatFrm.CloseallandAddtoIgnorelist1Click, nil);

 {$IFDEF USE_SECUREIM}
  addToMenuMass(aEncryptMenu, 1, 'SendInit', 'Init', '',
      '', chatFrm.EncryptSendInit, nil);
  addToMenuMass(aEncryptMenu, 2, 'SetPWD', 'Set password', '',
      '', chatFrm.EncryptSetPWD, nil);
 {$ENDIF USE_SECUREIM}
  addToMenuMass(aEncryptMenu2, 2, 'SetPWD', 'Set password', '',
      PIC_KEY, chatFrm.EncryptSetPWD, nil);
  addToMenuMass(aEncryptMenu2, 3, 'clrPWD', 'Clear password', '',
      'clear', chatFrm.EncryptClearPWD, nil);

  addToMenuMass(aFileSendMenu, 1, 'DirectSend', 'Send through protocol', '',
      '', chatFrm.RnQFileBtnClick, nil);
  addToMenuMass(aFileSendMenu, 2, 'UploadRGHost', 'Upload file to RGHost', '',
      '', chatFrm.RnQFileUploadClick, nil);
//  addToMenuMass(aFileSendMenu, 3, 'UploadMikanoshi', 'Upload file to Mikanoshi', '',
//      '', chatFrm.RnQFileUploadMClick, nil);
  addToMenuMass(aFileSendMenu, 3, 'UploadRnQ', 'Upload file to RnQ.ru', '',
      '', chatFrm.RnQFileUploadRClick, nil);

 addToMenuMass(aFileSendMenu, 3, 'UploadRnQTar', 'Upload multiple files to RnQ.ru', '',
      '', chatFrm.RnQFileUploadMClick, nil);

end;


procedure createMenusExt;
var
  i: Integer;
//  mi: TRQMenuItem;
begin
  RnQmain.menu.Items.OnAdvancedDrawItem := RnQmain.menuDrawItem;
  for i := 0 to Length(aMainMenu)-1 do
   begin
//    mi :=
    AddToMenu('', aMainMenu[i], RnQmain.menu.Items, aMainMenuUpd);
//    if @aMainMenu[i].amiUpd <> nil then
//     begin
//      k := length(aMainMenuUpd);
//      SetLength(aMainMenuUpd, k+1);
//      aMainMenuUpd[k].amiuMenu := mi;
//      aMainMenuUpd[k].amiuEv   := aMainMenu[i].amiUpd;
//     end;
   end;
end;

procedure addSmilesToMenu(own: Tcomponent; mi: Tmenuitem; action: TnotifyEvent);
var
  i: integer;
  smiles_count, smlcnt: Integer;
  dc1: Integer;
  so: TSmlObj;
begin
// chatFrm.smileMenuExt.Items.OnAdvancedDrawItem := mainFrm.menuDrawItem;
 mi.clear;
 with theme do
// with RQSmiles do
 begin
   if not TryStrToInt(GetString('smile.menu.count'), smiles_count) then
     smiles_count := SmilesCount
    else
     if (smiles_count > SmilesCount) or (smiles_count = 0) then
      smiles_count := SmilesCount;
   if not TryStrToInt(GetString('smile.menu.cnt'), smlcnt) then
    if not ShowSmileCaption then
      begin
       smlcnt := Round(sqrt(smiles_count)+1);       //mn
       dc1 := smiles_count div smlcnt;
       if dc1 > 1 then
        while (smlcnt > 1)and ((smiles_count div smlcnt) = dc1) do
         dec(smlcnt);
      end
     else
      smlcnt := 10;
   for i:=0 to smiles_count-1 do
    with AddToMenu(mi, '', GetSmileName(i), false, action) do
     begin
       so := Theme.GetSmileObj(i);
       Caption := so.SmlStr.Strings[0];
//        ImageName := caption;
       Hint := caption;
       tag := 4000+i;
  //  if (i mod smlcnt=0)and(i<>0) then item.Break:=mbBarBreak;
        if (i mod smlcnt=0)and(i<>0) then
          Break := mbBreak;
     end;
 end;
//applyCommonSettings(own);
end; // addSmilesToMenu

procedure addGroupsToMenu(own: Tcomponent; mi: Tmenuitem;
                          action: TnotifyEvent; pAddOut: Boolean);
var
  i: integer;
  ss: Tstringlist;
begin
  mi.clear;
  if pAddOut then
   begin
    AddToMenu(mi, getTranslation('Out of groups'), PIC_OUT_OF_GROUPS,
        false, action).Tag := 2000;
    AddToMenu(mi, '-', '', false);
   end;

  ss:=Tstringlist.create;
  for i:=0 to groups.count-1 do
   if pAddOut or (groups.a[i].ssiID > 0) then
    ss.AddObject(dupAmperstand(groups.a[i].name), Tobject(groups.a[i].id));
  ss.sort;
  for i:=0 to ss.Count-1 do
   with AddToMenu(mi, ss[i], PIC_CLOSE_GROUP, false, action, False) do
    begin
     CanTranslate := False;
     Tag := integer(ss.objects[i]);
    end;
  ss.free;
  applyCommonSettings(own);
  //mi.Enabled := true;
end; // addGroupsToMenu

procedure createFavMenuFrom(path: String; root: TMenuItem; action: TnotifyEvent);
var
  sr: TSearchRec;
Begin
  path:=IncludeTrailingPathDelimiter(path);
  if findFirst( path+'*.*', faDirectory, sr ) = 0 then
    repeat
    if sr.attr and faDirectory <> 0 then
      begin
      if (sr.name='.') or (sr.name='..') then continue;
      createFavMenuFrom(path+sr.name,
        AddToMenu(root, dupAmperstand(sr.name), PIC_CLOSE_GROUP, false), action);
      continue;
      end;
    if compareText(copy(sr.name, length(sr.name)-3, 4), '.url')=0 then
      begin
       AddToMenu(root, dupAmperstand(copy(sr.name, 1, length(sr.name)-4)),
         PIC_URL, false, action).hint:=path+sr.name;
      end;
    until findNext(sr) <> 0;
  findClose( SR );
end; // createFavMenuFrom

procedure createFavMenu(root: Tmenuitem; action: TnotifyEvent);
begin
//  createFavMenuFrom(getSpecialFolder('Favorites'), root, action)
  createFavMenuFrom(getSpecialFolder(CSIDL_FAVORITES), root, action)
end;


procedure ClearAllMenuArrays;
begin
  ClearMenuMass(aSendMenu);
  ClearMenuMass(aCloseMenu);
 {$IFDEF USE_SECUREIM}
  ClearMenuMass(aEncryptMenu);
 {$ENDIF USE_SECUREIM}
  ClearMenuMass(aEncryptMenu2);
  ClearMenuMass(aMainMenu);
  ClearMenuMass(aStsMenu);
  ClearMenuMass(aVisMenu);
end;

initialization

finalization
  ClearAllMenuArrays;

end.
