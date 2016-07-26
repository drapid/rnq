{
This file is part of R&Q.
Under same license
}
unit usersDlg;
{$I RnQConfig.inc}
  { $UNDEF RNQ_FULL}
{$I NoRTTI.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  ExtCtrls, RnQButtons, RnQDialogs, VirtualTrees, StdCtrls,
  RnQProtocol, globallib;

type
  TusersFrm = class(TForm)
    P1: TPanel;
    importBtn: TRnQSpeedButton;
    deleteaccountBtn: TRnQSpeedButton;
    UsersBox: TVirtualDrawTree;
    okBtn: TRnQButton;
    newuserBtn: TRnQButton;
    deleteuserBtn: TRnQButton;
    newaccountBtn: TRnQButton;
    PntBox: TPaintBox;
    procedure UsersBoxCompareNodes(Sender: TBaseVirtualTree; Node1,
      Node2: PVirtualNode; Column: TColumnIndex; var Result: Integer);
    procedure UsersBoxDrawNode(Sender: TBaseVirtualTree;
      const PaintInfo: TVTPaintInfo);
    procedure usersBoxDblClick(Sender: TObject);
    procedure newuserBtnClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure usersBoxKeyPress(Sender: TObject; var Key: Char);
   { $IFDEF RNQ_FULL}
    procedure newaccountBtnClick(Sender: TObject);
//    procedure importBtnClick(Sender: TObject);
   { $ENDIF RNQ_FULL}
    procedure FormPaint(Sender: TObject);
    procedure deleteuserBtnClick(Sender: TObject);
    procedure deleteaccountBtnClick(Sender: TObject);
    procedure okBtnClick(Sender: TObject);
    procedure usersBoxClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure L1Click(Sender: TObject);
    procedure L1MouseEnter(Sender: TObject);
    procedure L1MouseLeave(Sender: TObject);
    procedure UsersBoxFreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure UsersBoxChecked(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure UsersBoxFocusChanged(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex);
    procedure UsersBoxFocusChanging(Sender: TBaseVirtualTree; OldNode,
      NewNode: PVirtualNode; OldColumn, NewColumn: TColumnIndex;
      var Allowed: Boolean);
    procedure PntBoxPaint(Sender: TObject);
  private
    selected: boolean;
    RnQVer, RnQVer0, RnQVerT: String;
    MouseOnLabel: Boolean;
    function CheckPass: Boolean;
  public
    startIt: boolean;
    resAccPass: String;
    procedure refreshUsers;
    function  doSelect:TUID;
    function  selectUIN(const uin: TUID): boolean;
    function  uinAt(idx: integer): TUID;
    procedure newuser(cls: TRnQProtoClass; const uin: TUID);
  end;

  function  findInAvailableUsers(const uin: TUID): integer;
  procedure clearAvailableUsers;
  procedure refreshAvailableUsers;
  function getUserAutoStart(var pass: String): TUID;

var
  usersFrm: TusersFrm;
  availableUsers : array of TRnQUser;

implementation

{$R *.DFM}

uses
  UxTheme, DwmApi, Themes, strutils,
  ShlObj,
   NewAccount,
   { $IFDEF RNQ_FULL}
//     importDlg,
{$IFDEF USE_REGUIN}
   newaccountDlg,
{$ENDIF USE_REGUIN}
 {$IFDEF UNICODE}
   AnsiStrings,
 {$ENDIF UNICODE}
 {$IFDEF ICQ_ONLY}
   ICQv9,
 {$ENDIF ICQ_ONLY}
 {$IFDEF PROTOCOL_ICQ}
   ICQConsts,
 {$ENDIF PROTOCOL_ICQ}
   { $ENDIF}
//  newaccountDlg,
  RDFileUtil,
  RnQZip, RDUtils, RnQSysUtils, RnQGlobal,
  mainDlg,
  utilLib, RnQLangs, langLib, iniLib, RQUtil, RDGlobal;

const
 Have2Sel = 'You have to select a user to delete it';

var
  deletedMe: boolean;

procedure TusersFrm.refreshUsers;
var
//  toSelect:integer;
  i: integer;
  ur : PRnQUser;
  n, s : PVirtualNode;
begin
  usersBox.clear;
// toSelect:=-1;
  s := nil;
  for i:=0 to length(availableUsers)-1 do
   with availableUsers[i] do
    begin
     n := UsersBox.AddChild(nil);
     ur := UsersBox.GetNodeData(n);
     ur^ := availableUsers[i];
//     ur.name := name;
//     ur.uinStr :=
//    usersBox.items.add(uinStr+'  '+name);
     if LowerCase(uin)=lastUser then
      begin
//      toSelect := i;
       s := n;
      end;
    end;
//  UsersBox.Sort;
//if toSelect >= 0 then
  if Assigned(s) then
   begin
    UsersBox.Selected[s] := True;
    usersBox.FocusedNode := s;
//    usersBox.itemIndex := toSelect;
    okbtn.enabled := TRUE;
   end;
{else
  if usersBox.items.count > 0 then
    begin
    usersBox.itemIndex:=0;
    okBtn.enabled:=TRUE;
    end
  else
    begin
    usersBox.itemIndex:=-1;
    okBtn.enabled:=FALSE;
    end;    }
  if UsersBox.GetLast = nil then
    okBtn.enabled := FALSE;
  
end;  // refreshUsers

function TusersFrm.doSelect: TUID;
begin
  startIt := FALSE;
  resAccPass := '';
  showModal;
  if not selected and not startIt then
    result := ''
  else
    if usersBox.FocusedNode <> NIL then
      result := TRnQUser(PRnQUser(usersBox.getnodedata(usersBox.FocusedNode))^).uin
     else
      result := '';
// if Result > '' then
//  masterUseSSI := ssiChk.Checked;
end; // doSelect

procedure TusersFrm.usersBoxDblClick(Sender: TObject);
begin okBtnClick(sender) end;

procedure TusersFrm.UsersBoxDrawNode(Sender: TBaseVirtualTree;
  const PaintInfo: TVTPaintInfo);
var
  s: String;
  x: Integer;
//  cr : Boolean;
begin
  with TRnQUser(PRnQUser(usersBox.getnodedata(PaintInfo.Node))^) do
   begin
    s :=
 {$IFNDEF ICQ_ONLY}
        '('+proto._GetProtoName+') ' +
 {$ENDIF ICQ_ONLY}
        prefix+ uin + ' ' + name;
    if encr then
     s := s + '  *KEY*'
   end;
  if vsSelected in PaintInfo.Node.States then
   begin
    if Sender.Focused then
      PaintInfo.Canvas.Font.Color := clHighlightText
    else
      PaintInfo.Canvas.Font.Color := clWindowText;
   end
  else
    PaintInfo.Canvas.Font.Color := clWindowText;
  x := PaintInfo.ContentRect.Left;
//  inc(x, theme.drawPic(PaintInfo.Canvas, PaintInfo.ContentRect.Left +3, 0,
//         TlogItem(PLogItem(LogList.getnodedata(PaintInfo.Node)^)^).Img).cx+6);
  SetBkMode(PaintInfo.Canvas.Handle, TRANSPARENT);
//  PaintInfo.Canvas.textout(PaintInfo.ContentRect.Left +x,2, s);
  PaintInfo.Canvas.textout(x, 2, s);
end;

procedure TusersFrm.UsersBoxFocusChanged(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex);
begin
{  if ssiChk.Enabled then
  if Node <> NIL then
   with TRnQUser(PRnQUser(Sender.getnodedata(Node))^) do
    ssiChk.Checked := SSI;}
  OKbtn.enabled:= usersBox.FocusedNode <> NIL
end;

procedure TusersFrm.UsersBoxFocusChanging(Sender: TBaseVirtualTree; OldNode,
  NewNode: PVirtualNode; OldColumn, NewColumn: TColumnIndex;
  var Allowed: Boolean);
begin
{  if ssiChk.Enabled then
  if OldNode <> NIL then
   with TRnQUser(PRnQUser(Sender.getnodedata(OldNode))^) do
    SSI := ssiChk.Checked;}
  OKbtn.enabled:= usersBox.FocusedNode <> NIL
end;

procedure TusersFrm.UsersBoxFreeNode(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
begin
   with TRnQUser(PRnQUser(usersBox.getnodedata(Node))^) do
    begin
     SetLength(name, 0);
//     SetLength(uinStr, 0);
     SetLength(SubPath, 0);
     SetLength(path, 0);
     SetLength(uin, 0);
    end;
end;

{ $IFDEF RNQ_FULL}
procedure TusersFrm.newaccountBtnClick(Sender: TObject);
begin
{$IFDEF USE_REGUIN}
  newaccountFrm := TnewaccountFrm.create(NIL);
  translateWindow(newaccountFrm);
  newaccountFrm.showModal;
  ForceForegroundWindow(handle);
{$ELSE}
  openURL('http://icq.com/register/');
{$ENDIF USE_REGUIN}
end;

{$IFDEF RNQ_FULL2}
procedure TusersFrm.importBtnClick(Sender: TObject);
begin
{importFrm:=TimportFrm.create(NIL);
importFrm.filename:=getICQfolder;
translateWindow(importFrm);
importFrm.showModal;
ForceForegroundWindow(handle);
if startIt then
  close;}
end;
{$ENDIF RNQ_FULL2}

procedure TusersFrm.newuserBtnClick(Sender: TObject);
var
  uin: TUID;
  NewAccDlg: TNewAccFrm;
begin
  uin:='';
  NewAccDlg := TNewAccFrm.Create(Application);
  translateWindow(NewAccDlg);
  if NewAccDlg.ShowModal = mrOk then
    newuser(NewAccDlg.getProto, NewAccDlg.AccEdit.Text);
  NewAccDlg.Free;
//  if enterUINdlg(NIL, uin,'New user UIN') then
//    newUser(uin);
  if okBtn.Enabled then
    okBtn.SetFocus;
//  okBtn.
end;

procedure TusersFrm.FormShow(Sender: TObject);
begin
//applyTaskButton(self);
  selected:=FALSE;
//hideTaskButtonIfUhave2;
// ActiveControl := UsersBox;

 if UsersBox.ChildCount[UsersBox.RootNode] = 0 then
   newuserBtn.SetFocus;
end;

procedure TusersFrm.L1Click(Sender: TObject);
begin
//  openURL(rnqSite);
    exec(rnqSite);
end;

procedure TusersFrm.L1MouseEnter(Sender: TObject);
begin
//    with (sender as Tlabel).font do Style:=Style+[fsUnderline]
  if MouseOnLabel <> True then
   begin
    MouseOnLabel := True;
    PntBox.Repaint;
   end;
end;

procedure TusersFrm.L1MouseLeave(Sender: TObject);
begin
//  with (sender as Tlabel).font do Style:=Style-[fsUnderline]
  if MouseOnLabel <> false then
   begin
    MouseOnLabel := false;
    PntBox.Repaint;
   end;
end;

procedure TusersFrm.usersBoxKeyPress(Sender: TObject; var Key: Char);
begin
if key=#13 then
  begin
    selected:= usersBox.FocusedNode <> NIL;
    if selected then
      close
    else
      newuserBtnClick(nil);
  end;
end;

procedure TusersFrm.FormPaint(Sender: TObject);
begin
  if not GlassFrame.FrameExtended then
    wallpaperize(canvas)
end;

function TusersFrm.selectUIN(const uin: TUID): boolean;
var
//  i:integer;
  n: PVirtualNode;
begin
  result := FALSE;
//i:=0;
  n := UsersBox.GetFirst;
  while n <> NIL do
   begin
    if TRnQUser(PRnQUser(usersBox.getnodedata(n))^).uin = uin then
     begin
      usersBox.Selected[n] := True;
//      usersBox.itemIndex:=i;
      okBtn.enabled:=TRUE;
      result:=TRUE;
      exit;
      break;
     end;
    n := usersBox.GetNext(n);
   end;
{while i < usersBox.items.count do
  begin
  if uinAt(i) = uin then
    begin
    usersBox.itemIndex:=i;
    okBtn.enabled:=TRUE;
    result:=TRUE;
    exit;
    end;
  inc(i);
  end;
}
end;

function TusersFrm.uinAt(idx: integer): TUID;
begin
  if idx >= length(availableUsers) then
    result:=''
   else
    result := availableUsers[idx].uin;
end;

procedure TusersFrm.UsersBoxChecked(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
begin

end;

// uinAt

procedure TusersFrm.deleteuserBtnClick(Sender: TObject);
var
  UINtoDelete: TUID;
  Path: String;
  itsme: boolean;
  continue: boolean;
  u: TRnQUser;
begin
//if usersBox.itemIndex < 0 then
if usersBox.FocusedNode = NIL then
  msgDlg(Have2Sel, True, mtInformation)
else
  begin
    u := TRnQUser(PRnQUser(usersBox.getnodedata(usersBox.FocusedNode))^);
  UINtoDelete:= u.uin;
//  path := u.path + u.uinStr;
  path := u.path + u.SubPath;
//  uinAt(usersBox.ItemIndex);
  if UINtoDelete = '' then
   begin
     msgDlg(Have2Sel, True, mtInformation);
     Exit;
   end;
  itsme := Assigned(Account.AccProto) and (Account.AccProto.getMyInfo<>NIL) and (Account.AccProto.getMyInfo.equals(UINtoDelete));
  if itsme then
    begin
    continue:=messageDlg(getTranslation('The user you are trying to delete is the one in use right now.\nIt will be closed to be deleted. Continue?',[UINtoDelete]), mtConfirmation, [mbYes,mbNo], 0) = mrYes;
    deletedMe:=continue;
    if continue then quitUser;
    end
  else
    continue := messageDlg(getTranslation('Are you sure you want to delete %s ?',[UINtoDelete]), mtConfirmation, [mbYes,mbNo], 0) = mrYes;
  if continue then
//    if delSUBtree(UINtoDelete) then
    if delTree(Path) then
      begin
      refreshAvailableUsers;
      refreshUsers;
      msgDlg('User deleted!', True, mtInformation)
      end
    else
      msgDlg('Error deleting this user!', True, mtError);
  end
end;

procedure TusersFrm.deleteaccountBtnClick(Sender: TObject);
begin
//removeFrm:=TremoveFrm.create(mainFrm);
// notAvailable
end;

procedure TusersFrm.okBtnClick(Sender: TObject);
begin
//if usersBox.itemIndex < 0 then exit;
  if usersBox.FocusedNode = NIL then exit;
  if not CheckPass then
   begin
    ModalResult := mrNone;
    Exit;
   end;
  selected:=TRUE;
  close;
end;

procedure TusersFrm.PntBoxPaint(Sender: TObject);
const
  sizeM: Integer = 48;
var
//  vImgElm : TRnQThemedElementDtls;
//  thmTkn : Integer;
//  picLoc : TPicLocation;
//  picIdx : Integer;
  cnv: Tcanvas;
  oldMode: Integer;
//  bmp : TBitmap;
   TextLen: Integer;
   TextRect, R: TRect;
   TextFlags: Cardinal;
   Options: TDTTOpts;
   PaintOnGlass: Boolean;
  MemDC: HDC;
  PaintBuffer: HPAINTBUFFER;
//  br : HBRUSH;
  oldF : HFONT;
  ico : HICON;
  sz : TSize;
begin
  cnv := (Sender as TPaintBox).Canvas;
  R := (Sender as TPaintBox).ClientRect;
//  SizeM :=
    PaintOnGlass := StyleServices.Enabled and DwmCompositionEnabled and
      not (csDesigning in ComponentState);
    if PaintOnGlass then
    begin
      PaintOnGlass := self.GlassFrame.Enabled and self.GlassFrame.FrameExtended;
    end;
  PaintBuffer := 0;  
  begin
    try
      TextRect := r;//rect(r.left,r.Top+2,r.Left+round((r.right-r.left)*progLogon),r.bottom-2);
//      cnv.font.color:=clHighlightText;
      if MouseOnLabel then
        begin
         cnv.font.color:= clBlue;
         with cnv.font do Style:=Style+[fsUnderline];
        end
       else
        begin
         cnv.font.color:= clInfoText;
         with cnv.font do Style:=Style-[fsUnderline];
        end;
      if PaintOnGlass then
        begin
         PaintBuffer := BeginBufferedPaint(cnv.Handle, TextRect, BPBF_TOPDOWNDIB, nil, MemDC);
        end
       else
         MemDC := cnv.Handle;
//      br := CreateSolidBrush(ColorToRGB(clHighlight));
//      br := GetSysColorBrush(COLOR_HIGHLIGHT);
//      FillRect(MemDC, TextRect, br);
      TextRect := r;
      inc(TextRect.Top, 15);
//      TextRect.Left := r.Right - x - 4;
      dec(TextRect.bottom, (Sender as TPaintBox).Height - sizeM - 5);
//      inc(TextRect.Bottom, 1);
      if PaintOnGlass then
        begin
          BufferedPaintClear(PaintBuffer, @r);
          TextLen := Length(RnQVer);
          TextFlags := DT_CENTER or DT_VCENTER;

          FillChar(Options, SizeOf(Options), 0);
          Options.dwSize := SizeOf(Options);
          Options.dwFlags := DTT_COMPOSITED or DTT_GLOWSIZE or DTT_TEXTCOLOR;
          if MouseOnLabel then
            Options.iGlowSize := 20
           else
            Options.iGlowSize := 2;
    //      Options.
          Options.crText := ColorToRGB(cnv.Font.Color);

//          with StyleServices.GetElementDetails(twCaptionActive) do
          with StyleServices.GetElementDetails(tttBaloonLink) do
            DrawThemeTextEx(StyleServices.Theme[element], MemDC, Part, State,
//            with StyleServices.GetElementDetails(teEditTextNormal) do
//              DrawThemeTextEx(StyleServices.Theme[teEdit], Memdc, Part, State,
//                PWideChar(WideString(RnQVer)), TextLen, TextFlags, @TextRect, Options);
                PWideChar(RnQVer), TextLen, TextFlags, TextRect, Options);
        end
       else
        begin
          oldMode := SetBkMode(MemDC, TRANSPARENT);
          oldF := SelectObject(MemDC, cnv.Font.Handle);
          SetTextAlign (MemDC, GetTextAlign(MemDC) or (TA_CENTER) or VTA_CENTER);
//          SetTextAlign (MemDC, (TA_CENTER));
//          TextRect.Top := TextRect.bottom - 30;
          GetTextExtentPoint32(Cnv.Handle, PChar(RnQVer0), Length(RnQVer0), sz);
//          newLineHeight(sz.cy);
          ExtTextOut(MemDC, (TextRect.Right+ TextRect.Left) shr 1, (TextRect.Top + TextRect.Bottom )shr 1- sz.cy,
                     ETO_CLIPPED, @TextRect, PChar(RnQVer0), Length(RnQVer0), NIL);
          if RnQVerT > '' then
             ExtTextOut(MemDC, (TextRect.Right+ TextRect.Left) shr 1, (TextRect.Top + TextRect.Bottom )shr 1,
                     ETO_CLIPPED, @TextRect, PChar(RnQVerT), Length(RnQVerT), NIL);
//          cnv.TextRect(TextRect, TextRect.Left, TextRect.Top, RnQVer);
//          SetBkMode(MemDC, oldMode);
          SelectObject(MemDC, oldF);
        end;

//      br := 0;
//      DeleteObject(br);
//      s := intToStr(round(progLogon*100))+'%';

     ico := CopyImage(Application.Icon.Handle, IMAGE_ICON, sizeM, sizeM, LR_COPYFROMRESOURCE);
//     DrawIcon(AboutPBox.Canvas.Handle, 0, 0, ico);
//     DrawIconEx(AboutPBox.Canvas.Handle, 0, 0, ico, sizeM, sizeM, 0, 0, DI_NORMAL);

     DrawIconEx(MemDC, (r.Left + r.Right-sizeM)shr 1, r.Bottom - sizeM -5, ico, sizeM, sizeM, 0, 0, DI_NORMAL);
//     DeleteObject(ico);
     DestroyIcon(ico);

//      TextOut(MemDC, r.left+2,y, PAnsiChar(s), Length(s));
//      SetBkMode(MemDC, oldMode);
//      SelectObject(MemDC, oldF);
    finally
      if PaintOnGlass then
        begin
//         BufferedPaintMakeOpaque(PaintBuffer, @TextRect);
         EndBufferedPaint(PaintBuffer, True);
        end;
    end;
  end
end;

procedure TusersFrm.usersBoxClick(Sender: TObject);
begin
OKbtn.enabled:= usersBox.FocusedNode <> NIL
//usersBox.itemIndex >= 0;
end;

procedure TusersFrm.UsersBoxCompareNodes(Sender: TBaseVirtualTree; Node1,
  Node2: PVirtualNode; Column: TColumnIndex; var Result: Integer);
var
 i : Int64;
 u1, u2 : TUID;
begin
  u1 := TRnQUser(PRnQUser(Sender.getnodedata(Node1))^).uin;
  u2 := TRnQUser(PRnQUser(Sender.getnodedata(Node2))^).uin;
// if Column = 0 then
   if TryStrToInt64(u1, i) or TryStrToInt64(u2, i) then
     result := compareInt(StrToIntDef(u1, MaxInt), StrToIntDef(u2, MaxInt))
    else
     result:= CompareText(u1, u2)
//  else
//   result:= -CompareText(Tcontact(sender.getnodedata(Node1)^).displayed,
//      Tcontact(Sender.getnodedata(Node2)^).displayed);
end;

procedure TusersFrm.newuser(cls: TRnQProtoClass; const uin: TUID);
var
//  s:string;
//  i, k:integer;
  tUserPath : String;
  b : Boolean;
  u : PRnQUser;
  n : PVirtualNode;
  onlyUID : TUID;
  prCl : TRnQProtoClass;
begin
//  s:= uin;
    if cmdLinePar.userPath > '' then
      tUserPath := cmdLinePar.userPath
     else
      tUserPath := myPath + accountsPath;
//   prCl := NIL;
   prCl := cls;
//   if cls = NIL then
   begin
     onlyUID := uin;
     b := false;
    if cls = NIL then
     for prCl in RnQProtos do
      begin
       onlyUID := uin;
//       if prCl._isValidUid(onlyUID) then
       if prCl._isProtoUid(onlyUID) then
        begin
//         result:= True;
         onlyUID := prCl._getContactClass.trimUID(onlyUID);
         b := True;
         break;
        end;
      end
     else
      begin
       onlyUID := prCl._getContactClass.trimUID(uin);
       b := prCl._isValidUid1(onlyUID);
      end
       ;
//    val(uin, k, i);
     if not b then
       begin
         msgDlg(getTranslation('Not valid user identifier - %s', [uin]), False, mtError);
         exit;
       end;
     if selectUIN(onlyUID) then
       begin
         msgDlg(getTranslation('%s already exists',[uin]), False, mtError);
         exit;
       end;
    if isOnlyDigits(onlyUID) then
      tUserPath := tUserPath +  onlyUID + PathDelim
     else
//      if prCl = TicqSession then
      if prCl._getProtoID = ICQProtoID then
        tUserPath := tUserPath +  'AIM_'+ onlyUID + PathDelim
       else
        tUserPath := tUserPath +  prCl._GetProtoName +'_'+ onlyUID + PathDelim;
//    if i <> 0 then
//     tUserPath := tUserPath + AIMprefix;
//    tUserPath := tUserPath + String(uin) + PathDelim;
    IOresult;
    mkdir(tUserPath);
 {$IFNDEF DB_ENABLED}
    mkdir(tUserPath+historyPath);
 {$ENDIF ~DB_ENABLED}
    IOresult;
    UsersBox.BeginUpdate;
    n := UsersBox.AddChild(NIL);
    u := UsersBox.GetNodeData(n);
    u.uin    := onlyUID;
 {$IFDEF ICQ_ONLY}
    u.proto  := TICQSession;
 {$ELSE ~ICQ_ONLY}
    u.proto  := prCl;
 {$ENDIF ICQ_ONLY}
    u.name   := '';
//    u.uinStr := '';
    u.SubPath := '';
    u.path   := tUserPath;
    u.SSI    := masterUseSSI;
    UsersBox.EndUpdate;
    lastUser := onlyUID;
//    i:=usersBox.items.add(uin);
    refreshAvailableUsers;
    refreshUsers;

  //  usersBox.Items.IndexOfName(s);
{    UsersBox.FocusedNode := n;
    UsersBox.Selected[UsersBox.FocusedNode] := True;}
//    usersBox.itemIndex := usersBox.Items.IndexOf(uin+'   ');
  //  usersBox.itemIndex:=i;
    usersBoxClick(NIL);
   end;
end; // newuser

procedure TusersFrm.FormCreate(Sender: TObject);
begin
  RnQVer := getTranslation('Build %d', [RnQBuild]);
{$IFDEF CPUX64}
  RnQVer := RnQVer + ' x64';
{$ENDIF CPUX64}

   RnQVer0:= RnQVer;
   RnQVerT := '';


  if LiteVersion or PREVIEWversion then
    RnQVer:= RnQVer + crlf;

  if LiteVersion then
   begin
    RnQVerT := RnQVerT+'Lite';
   end;
  if PREVIEWversion then
   begin
    if LiteVersion then
      RnQVerT := RnQVerT+' ';
    RnQVerT := RnQVerT+'Test';
   end;
  RnQVer := RnQVer + RnQVerT;

  UsersBox.NodeDataSize := SizeOf(TrnqUser);
  { $IFDEF RNQ_FULL}
 { $IFDEF USE_REGUIN}
    newaccountBtn.Enabled := True;
    newaccountBtn.OnClick := newaccountBtnClick;
  { $ELSE}
//    newaccountBtn.Enabled := False;
 { $ENDIF USE_REGUIN}
  {$IFDEF RNQ_FULL2}
    importBtn.Visible := True;
    importBtn.OnClick := importBtnClick;
  {$ELSE RNQ_FULL2}
    importBtn.Visible := False;
  {$ENDIF RNQ_FULL2}
  refreshAvailableUsers;
  refreshUsers;
//  L1.DoubleBuffered := True;
//  self.DoubleBuffered := True;
//  UsersBox.DoubleBuffered := True;
  Self.GlassFrame.Right := ClientWidth - UsersBox.Width;
  Self.GlassFrame.Enabled := Self.GlassFrame.Enabled //and not PrefsPnl.Visible
    and StyleServices.Enabled;
//  PrefsPnl.DoubleBuffered := True;
//  Panel1.DoubleBuffered := True;
end;

procedure TusersFrm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
if deletedMe and not selected then
  begin
   hideForm(RnQmain);
   quit;
  end;
end;

procedure TusersFrm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
   VK_ESCAPE : Close;
   VK_DELETE : deleteuserBtnClick(nil);
   VK_INSERT : newuserBtnClick(nil);
  end;
end;

function TusersFrm.CheckPass : Boolean;
var
//  a : Boolean;
  pt : String;
//  newAccPass : AnsiString;
begin
  Result := True;
  if usersBox.FocusedNode <> NIL then
   with TRnQUser(PRnQUser(usersBox.getnodedata(usersBox.FocusedNode))^) do
    begin
      Result := not encr;
      if Result then Exit;
//      pt := path+ uinStr+ PathDelim + dbFilename + '5';
      pt := path+ SubPath + PathDelim + dbFilename + '5';

      Result := CheckAccPas(uin, pt, resAccPass);
{      newAccPass := '';
      if enterPwdDlg(newAccPass, getTranslation('Password') + ' (' + uinStr + ')', 16) then
         if CheckZipFilePass(pt, dbFilename, newAccPass) then
           begin
             resAccPass := newAccPass;
             Result := True
           end
          else
           begin
            Result := False;
            msgDlg('Wrong password', True, mtWarning)
           end
       else
        msgDlg('Please enter password', True, mtWarning);
}
    end;
end;

function findInAvailableUsers(const uin: TUID): integer;
begin
  for result:=0 to length(availableusers)-1 do
    if availableusers[result].uin = uin then
      exit;
  result := -1;
end; // findInAvailableUsers

procedure clearAvailableUsers;
var
  i: Integer;
begin
  for i := 0 to Length(availableUsers)-1 do
   begin
     SetLength(availableUsers[i].name, 0);
//     SetLength(availableUsers[i].uinStr, 0);
     SetLength(availableUsers[i].SubPath, 0);
     SetLength(availableUsers[i].path, 0);
     SetLength(availableUsers[i].uin, 0);
     SetLength(availableUsers[i].Prefix, 0);
   end;
  setlength(availableUsers, 0);
end;

procedure refreshAvailableUsers;
  function getNick_SSI(protoClass: TRnQProtoClass; path: string;
                       var pSSI: Boolean; uid: TUID;
                       var nick: String; var isEncripted: Boolean): Boolean;
      function yesno(const l: String): boolean;
      begin result := LowerCase(l)='yes' end;
  var
    db: TRnQCList;
    ini: TStrings;
    zf: TZipFile;
    s: AnsiString;
    cf: string;
    i: Integer;
//    cnt: TRnQcontact;
    save: Boolean;
  begin
    result := False;
    nick := '';
    save := false;
    isEncripted := False;
    ini := TstringList.create;
    db := nil;
    pSSI := masterUseSSI;
    cf := path+ PathDelim +dbFileName + '5';
    if not FileExists(cf) then
      cf := path+ PathDelim +dbFileName + '4';
    if FileExists(cf) then
      begin
         zf := TZipFile.Create;
         try
           zf.LoadFromFile(cf);
           i := zf.IndexOf('about.txt');
           if i >=0 then
            begin
             isEncripted := zf.IsEncrypted(i);
             Result := True;
             if not isEncripted then
              begin
               ini.Text := zf.data[i];
               s := ini.values['account-name'];
               nick := unUTF( s );
               pSSI := yesno(ini.Values['use-ssi']);
              end;
            end;
           if not Result then
            begin
             i := zf.IndexOf(configFileName);
             if i >=0 then
              begin
               isEncripted := zf.IsEncrypted(i);
               Result := True;
               if not isEncripted then
                begin
                 ini.Text := zf.data[i];
                 s := ini.values['account-name'];
                 nick := unUTF(s);
                 pSSI := yesno(ini.Values['use-ssi']);
                end;
              end;
            end;
{
           if not Result then
            begin
             i := zf.IndexOf(dbFileName);
             if i >=0 then
              begin
               isEncripted := zf.IsEncrypted(i);
               Result := True;
               if not isEncripted then
                begin
                  s := zf.data[i];
                  db := str2db(protoClass._getContactClass, s);
                  cnt := db.get(protoClass._getContactClass, uid);
                  if Assigned(cnt) then
                    nick := cnt.nick;
                  freeDB(db);
                end;
              end;
            end;
}
          except
           s := '';
         end;
         zf.Free;
      end;
    if not result then
     begin
      cf := path+ PathDelim + configFileName;
      if fileExists(cf) then
        begin
          save := True;
          result := True;
          try
            ini.LoadFromFile(cf);
           except
            ini.Clear;
          end;
          nick := UnUTF(ini.values['account-name']);
          pSSI := yesno(ini.Values['use-ssi']);
        end
       else
        begin
          cf := path + PathDelim +OldconfigFileName;
          if fileExists(cf) then
            begin
              Result := True;
              save := True;
              ini.LoadFromFile(cf);
              nick := ini.values['account-name'];
              pSSI := yesno(ini.Values['use-ssi']);
            end
        end;
     end;
    if not result then
     begin
  //     loadDB(path+ PathDelim, db)
        begin
         zf := TZipFile.Create;
         try
           if FileExists(path+ PathDelim +dbFileName + '3') then
             zf.LoadFromFile(path+ PathDelim +dbFileName + '3');
           i := zf.IndexOf(dbFileName);
           if i >=0 then
             s := zf.data[i];
          except
           s := '';
         end;
         zf.Free;
        end;
       if s = '' then
         s := loadFileA(path+ PathDelim +dbFileName);
{
      if s > '' then
       begin
        Result := True;
        db:=str2db(protoClass._getContactClass, s);
        cnt := db.get(protoClass._getContactClass, uid);
        if Assigned(cnt) then
          nick := cnt.nick;
       end;
}
//      if not result then
//        nick := ' ';
      if save then
       begin
        ini.values['account-name']:= StrToUTF8(nick);
  //      ini.Values['use-ssi'] := yesno();
        ini.saveToFile(cf);
       end;
      freeDB(db);
     end;
    ini.free;
  end; // getNick

  procedure addAvailableUser(protoClass: TRnQProtoClass; UID: TUID;
          pPath, pPrefix: string);
  var
    n: integer;
  begin
    n := length(availableUsers);
    setlength(availableUsers, n+1);
//    with availableUsers[n] do
    begin
//      availableUsers[n].uinStr:=extractFileName(pPath);
      with availableUsers[n] do
       begin
//        if copy(uinStr, 1, 4) = AIMprefix then
//         uinStr := copy(uinStr, 5, length(uinStr));
//        uinStr:=extractFileName(pPath);
        SubPath := extractFileName(pPath);
 {$IFNDEF ICQ_ONLY}
        proto := protoClass;
//        if (protoClass <> TicqSession) then
//          uinStr := protoClass._GetProtoName + '_' + uid
//         else
 {$ELSE ICQ_ONLY}
//        uinStr := UID;
        proto := TICQSession;
 {$ENDIF ~ICQ_ONLY}
        uin := UID;
//         uid := uinStr;
         getNick_SSI(protoClass, pPath, SSI, UID, name, encr);
         Prefix := pPrefix;
         path:= ExtractFilePath(pPath);
       end;
    end;
  end; // addAvailableUser

  procedure searchIn(path: string; Prefix : String = '');

  var
//  code:integer;
    sr: TsearchRec;
//   i:integer;
    s: String;
    s2: TUID;
//   prCl : TRnQProtoHelper;
    prCl: TRnQProtoClass;
  begin
  path := includeTrailingPathDelimiter(path);
  ZeroMemory(@sr.FindData, SizeOf(TWin32FindData));
  if FindFirst(path+'*', faDirectory, sr)=0 then
    repeat
    if (sr.Attr and faDirectory > 0) and (sr.name <> '.')and (sr.name <> '..') then
      begin
        s := ExtractFileName(sr.name);
//      val(sr.Name, i, code);
//      if TicqSession.isValidUID(s)
//      if TRnQProtocol(icq).isValidUID(s)
       for prCl in RnQProtos do
        begin
         s2 := s;
//         if prCl._isValidUid(s2)
         if prCl._isProtoUid(s2)
//      if icq.isValidUID(s)
//        or (copy(sr.Name, 1, 4) = 'AIM_')
        then
         begin
          addAvailableUser(prCl, s2, path+sr.name, Prefix);
          break;
         end;
        end;
      end;
    until FindNext(sr) > 0;
  FindClose(sr);
  end;

var
  s: string;
  i, j, n: integer;
  found: Boolean;
  ss: TUID;
//  uid : AnsiString;
begin
  clearAvailableUsers;
  searchIn(myPath);
  if RnQMainPath > '' then
    searchIn(myPath+RnQMainPath, 'Old\');

//  s := getSpecialFolder('AppData')+'R&Q\';
  s := getSpecialFolder(CSIDL_APPDATA)+'R&Q\';
  searchIn(s, 'App\');

  if (cmdLinePar.userPath > '') and not AnsiSameText(cmdLinePar.userPath, usersPath) then
   if LowerCase(s) <> LowerCase(cmdLinePar.userPath) then
     searchIn(cmdLinePar.userPath, 'User\');

  s := usersPath;
  while s>'' do
    searchIn(chop(';',s), 'Users path\');

  s := mypath + accountsPath;
  if s <> usersPath then
    while s>'' do
      searchIn(chop(';',s));

  if cmdLinePar.startUser > '' then
   begin
    found := false;
    for n := 0 to length(availableUsers) - 1 do
     begin
      ss := cmdLinePar.startUser;
      if availableUsers[n].proto._isProtoUid(ss)
        and (availableUsers[n].uin = ss) then
       found := true;
     end;
    if not found then
     begin
//      fantomWork := True;    // New фича 2007.10.09
 {$IFDEF ICQ_ONLY}
      addAvailableUser(TicqSession, cmdLinePar.startUser, myPath + cmdLinePar.startUser, 'CMD\');
 {$ENDIF ICQ_ONLY}
     end;
   end;

 n := length(availableUsers);
 for i:=0 to n-2 do
  for j:=i+1 to n-1 do
    swap4(availableUsers[i], availableUsers[j], sizeOf(availableUsers[i]),
      availableUsers[i].uin > availableUsers[j].uin );
end; // refreshAvailableUsers

function getUserAutoStart(var pass: String): TUID;
var
  i: Integer;
begin
  refreshAvailableUsers;
  uin2Bstarted := '';
//  AccPass := '';
  pass := '';
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
         uin2Bstarted := autostartUIN;
         masterUseSSI := cmdLinePar.ssi or availableusers[i].SSI;
       end
     else
      if length(availableusers)=1 then
        begin
          uin2Bstarted := availableusers[0].uin;
          masterUseSSI := cmdLinePar.ssi or availableusers[0].SSI;
        end
   end;
  if uin2Bstarted > '' then
    begin
      i := findInAvailableUsers(uin2Bstarted);
      if i >=0 then
       begin
//       if needCheckPass then
        with availableUsers[i] do
        if encr and not CheckAccPas(uin, path+ SubPath + PathDelim + dbFilename + '5', pass)  then
         begin
//           halt(0);
           uin2Bstarted := '';
         end;
       end
      else
       uin2Bstarted := '';
    end;
end;

end.
