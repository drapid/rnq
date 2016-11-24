{
This file is part of R&Q.
Under same license
}
unit prefDlg;
{$I RnQConfig.inc}
{$I NoRTTI.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Forms,
  Controls, ExtCtrls,
 {$IFDEF PREF_IN_DB}
  DBPrefsLib,
 {$ELSE ~PREF_IN_DB}
  RnQPrefsLib,
 {$ENDIF PREF_IN_DB}
  RnQButtons, RnQDialogs, VirtualTrees, StdCtrls;

type

  TprefFrm = class(TForm)
    framePnl: TPanel;
    Bevel: TBevel;
    PrefList: TVirtualDrawTree;
    resetBtn: TRnQButton;
    okBtn: TRnQButton;
    closeBtn: TRnQButton;
    applyBtn: TRnQButton;
    procedure PrefListDrawNode(Sender: TBaseVirtualTree;
      const PaintInfo: TVTPaintInfo);
    procedure PrefListChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
//    procedure PrefListGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
//      Column: TColumnIndex; TextType: TVSTTextType; var CellText: WideString);
    procedure FormCreate(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure closeBtnClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure resetBtnClick(Sender: TObject);
    procedure applyBtnClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure okBtnClick(Sender: TObject);
    procedure pagesBoxClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure PrefListGetNodeWidth(Sender: TBaseVirtualTree;
      HintCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
      var NodeWidth: Integer);
    procedure PrefListFreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure HideAllPages(Sender: TBaseVirtualTree; Node: PVirtualNode; Data: Pointer; var Abort: Boolean);
  public
    arrPages: array of TPrefPage;
    procedure reset;
    procedure apply;
//    procedure updateVisible;
//    procedure setPics();
//  public procedure destroyHandle;
    procedure SetViewMode(pages: array of TPrefPage);
    procedure SetBtnEnable(Value: Boolean);
    procedure SetActivePage(i: Integer); Overload;
    procedure SetActivePage(const pn: String); Overload;
    procedure onTimer;
//    procedure SetViewMode(const Mode: TfrmViewMode);
  private
    procedure sortPrefPages;
  end;

var
  prefFrm: TprefFrm = NIL;
  blinkExCount: word;

implementation
{$R *.DFM}

uses
  Themes, Dwmapi,
  RQUtil, RDGlobal, RQThemes, RnQLangs, LangLib,
  RnQSysUtils, RnQGlobal, RnQPics,
  iniLib, globalLib, utilLib, mainDlg,
  connection_fr,
  antispam_fr,
  design_fr,
  chat_frOld,
  tips_fr,
  autoaway_fr,
  start_fr,
  hotkeys_fr,
  security_fr,
  events_fr,
  plugins_fr,
  update_fr,
  themedit_fr,
  other_fr,

  Protocols_all;
  //ThemesLib, mainDlg;

//procedure warnOnlineOption;
//begin msgDlg(getTranslation('This option will be applied as soon as you go online'),mtWarning) end;

procedure TprefFrm.HideAllPages(Sender: TBaseVirtualTree; Node: PVirtualNode; Data: Pointer; var Abort: Boolean);
begin
//  node.
//  if (sender is PrefList) then
  with TPrefPage(PPrefPage(Sender.getnodedata(Node))^).frame do
   begin
     Visible := False;
//     BringToFront;
//     Invalidate;
   end;
  Invalidate;
end;

procedure TprefFrm.onTimer;
var
  pp: TPrefPage;
begin
{    for i := Low(prefFrm.arrPages) to High(prefFrm.arrPages) do
     if prefFrm.arrPages[i].frameClass = TdesignFr then
      if Assigned(prefFrm.arrPages[i].frame) then
      begin
        blinkExCount:=succ(blinkExCount) mod TdesignFr(prefFrm.arrPages[i].frame).blinkSlider.position;
        if blinkExCount = 0 then
         TdesignFr(prefFrm.arrPages[i].frame).BlinkPBox.Visible :=
           not TdesignFr(prefFrm.arrPages[i].frame).BlinkPBox.Visible;
        break;
     end;}
    for pp in prefFrm.arrPages do
     if pp.frameClass = TdesignFr then
      if Assigned(pp.frame) then
      with TdesignFr(pp.frame) do
       begin
        blinkExCount := succ(blinkExCount) mod blinkSlider.position;
        if blinkExCount = 0 then
           BlinkPBox.Visible := not BlinkPBox.Visible;
        break;
      end;
end;


procedure TprefFrm.reset;
var
  {$IFDEF DELPHI9_UP}
  pp: TPrefPage;
  {$ELSE}
  i: byte;
  {$ENDIF DELPHI9_UP}
begin

 SetBtnEnable(false);
 try
  {$IFDEF DELPHI9_UP}
  for pp in arrPages do
   if Assigned( pp.frame ) then
  {$ELSE not DELPHI9_UP}
  for i := 0 to Length(arrPages)-1 do
   if Assigned( arrPages[i].frame ) then
  {$ENDIF DELPHI9_UP}
  try
  {$IFDEF DELPHI9_UP}
   pp.frame.resetPage;
   pp.frame.updateVisPage;
  {$ELSE not DELPHI9_UP}
   arrPages[i].frame.resetPage;
   arrPages[i].frame.updateVisPage;
  {$ENDIF DELPHI9_UP}
   Application.ProcessMessages;
  except
    msgDlg(getTranslation('Error on reset page')+' "' +
        {$IFDEF DELPHI9_UP}
           getTranslation(pp.Caption) + '"!', False, mtError);
        {$ELSE DELPHI9_UP}
           getTranslation(arrPages[i].Caption) + '"!', mtError);
        {$ENDIF DELPHI9_UP}
  end;
 finally
   SetBtnEnable(True);
 end;
end; // reset

procedure TprefFrm.apply;
var
  {$IFDEF DELPHI9_UP}
  pp: TPrefPage;
  {$ELSE DELPHI9_UP}
  i: byte;
  {$ENDIF DELPHI9_UP}
begin
 SetBtnEnable(false);
 try
  {$IFDEF DELPHI9_UP}
  for pp in arrPages do
   if Assigned( pp.frame ) then
  {$ELSE DELPHI9_UP}
  for i := 0 to Length(arrPages)-1 do
   if Assigned( arrPages[i].frame ) then
  {$ENDIF DELPHI9_UP}
    try
  {$IFDEF DELPHI9_UP}
     pp.frame.applyPage;
    {$ELSE DELPHI9_UP}
     arrPages[i].frame.applyPage;
    {$ENDIF DELPHI9_UP}
     Application.ProcessMessages;
    except
      msgDlg(getTranslation('Error on apply page')+' "' +
          {$IFDEF DELPHI9_UP}
             getTranslation(pp.Caption) + '"!', False, mtError);
          {$ELSE DELPHI9_UP}
             getTranslation(arrPages[i].Caption) + '"!', mtError);
          {$ENDIF DELPHI9_UP}
    end;

  //repaintAllWindows;
  if Assigned(RnQmain) then
//    saveCFG;
    saveCfgDelayed := True;
  saveCommonCFG;
 finally
   SetBtnEnable(True);
 end;
end; // apply

procedure TprefFrm.FormShow(Sender: TObject);
begin
// prefFrm.height := prefHeight;
  applyTaskButton(self);
  caption := getTranslation('Preferences for %s', [RnQUser]);
{  if (ICQ <> NIL) AND (ICQ.myInfo <> NIL) then
    caption := getTranslation('Preferences for %s',[ICQ.myinfo.displayed])
   else
    caption := getTranslation('Preferences for %s', [RnQUser]);}

// theme.pic2ico(PIC_PREFERENCES, icon);
end;

procedure TprefFrm.resetBtnClick(Sender: TObject);
begin reset end;

procedure TprefFrm.applyBtnClick(Sender: TObject);
begin
  apply;
  reset; // to update screen
end;

procedure TprefFrm.FormClose(Sender: TObject; var Action: TCloseAction);
var
  i: Byte;
//  p: TPrefPage;
begin
  updateSWhotkeys;
  hotkeysEnabled := TRUE;
  Action := caFree;
  prefFrm := NIL;

  for i := Low(arrPages) to High(arrPages) do
   if Assigned(arrPages[i]) then
   begin
    try
     if arrPages[i].frame <> NIL then
      begin
       arrPages[i].frame.unInitPage;
       Application.ProcessMessages;
       FreeAndNil(arrPages[i].frame);
      end;
    except
      on e: Exception do
       begin
//        arrPages[i].frame := NIL;
        msgDlg(getTranslation('Error on uninit page')+' "' +
             getTranslation(arrPages[i].Caption) + '"!' + CRLF+
             e.Message, False, mtError);
       end;
    end;
    arrPages[i].frame := NIL;
//    SetLength(arrPages[i].Name, 0);
//    SetLength(arrPages[i].Caption, 0);
//    arrPages[i].frameClass := NIL;
    FreeAndNil(arrPages[i]);
   end;
  SetLength(arrPages, 0);
end;

procedure TprefFrm.FormCreate(Sender: TObject);
begin
  PrefList.NodeDataSize := SizeOf(TPrefPage);
end;

procedure TprefFrm.okBtnClick(Sender: TObject);
begin
  hide;
  apply;
  close;
end;

procedure TprefFrm.pagesBoxClick(Sender: TObject);
//var
//  i: integer;
begin
  if PrefList.FocusedNode = NIL then
   exit;
  PrefList.IterateSubtree(nil, HideAllPages, NIL);
  with TPrefPage(PPrefPage(PrefList.getnodedata(PrefList.FocusedNode))^).frame do
   begin
     Visible := True;
     BringToFront;
     Invalidate;
   end;
{  i:=pagesBox.itemIndex;
  if i<0 then exit;
  updateSWhotkeys;
  Tframe(pagesBox.items.objects[i]).BringToFront;
  Tframe(pagesBox.items.objects[i]).Invalidate;}
end;

procedure TprefFrm.PrefListChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
begin
  pagesBoxClick(nil);
end;

procedure TprefFrm.PrefListDrawNode(Sender: TBaseVirtualTree;
  const PaintInfo: TVTPaintInfo);
var
  s: String;
  x: Integer;
begin
  if not Assigned(TPrefPage(PPrefPage(PrefList.getnodedata(PaintInfo.Node))^)) then
    Exit;
  s := TPrefPage(PPrefPage(PrefList.getnodedata(PaintInfo.Node))^).Caption;
{  if vsSelected in PaintInfo.Node.States then
   begin
    if Sender.Focused then
      PaintInfo.Canvas.Font.Color := clHighlightText
    else
      PaintInfo.Canvas.Font.Color := clWindowText;
   end
  else}
    PaintInfo.Canvas.Font.Color := clWindowText;
  x := PaintInfo.ContentRect.Left;
  if vsHasChildren in PaintInfo.Node.States then
    if vsExpanded in PaintInfo.Node.States then
      inc(x, theme.drawPic(PaintInfo.Canvas.Handle, x + 2, 1, PIC_OPEN_GROUP).cx + 2)
     else
      inc(x, theme.drawPic(PaintInfo.Canvas.Handle, x + 2, 1, PIC_CLOSE_GROUP).cx + 2)
   else
    inc(x, 6);

//  inc(x, theme.drawPic(PaintInfo.Canvas, PaintInfo.ContentRect.Left +3, 0,
//         TlogItem(PLogItem(LogList.getnodedata(PaintInfo.Node)^)^).Img).cx+6);
  SetBkMode(PaintInfo.Canvas.Handle, TRANSPARENT);
  PaintInfo.Canvas.textout(x + 2, 2, s);
end;

procedure TprefFrm.PrefListFreeNode(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
begin
  TPrefPage(PPrefPage(PrefList.getnodedata(Node))^).Free;
end;

procedure TprefFrm.PrefListGetNodeWidth(Sender: TBaseVirtualTree;
  HintCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
  var NodeWidth: Integer);
var
  k: Integer;
  s: string;
  r: TRect;
  res: Tsize;
begin
  k := DT_CALCRECT;
  s := TPrefPage(PPrefPage(PrefList.getnodedata(Node))^).Caption;
  r := HintCanvas.ClipRect;
  drawText(HintCanvas.Handle, PChar(s), -1, R, k or DT_SINGLELINE or DT_VCENTER or DT_CENTER);
  GetTextExtentPoint32(HintCanvas.Handle, PChar(s), Length(s), res);
  NodeWidth := res.cx + 10;
end;

{procedure TprefFrm.PrefListGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
  Column: TColumnIndex; TextType: TVSTTextType; var CellText: WideString);
begin
  CellText := TPrefPage(PPrefPage(PrefList.getnodedata(Node))^).Caption;
end;
}
procedure TprefFrm.FormDestroy(Sender: TObject);
var
  I: Integer;
begin
  if Length(arrPages) > 0 then
  begin
    for I := 0 to Length(arrPages) - 1 do
//     arrPages[i].free;
      FreeAndNil(arrPages[i]);
    SetLength(arrPages, 0);
  end;
  freeAndNIL(prefFrm);
end;

procedure TprefFrm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
    closeBtn.Click;
//    closeBtnClick(nil);
end;

procedure TprefFrm.sortPrefPages;
var
  i: Integer;
  pp: TPrefPage;
  bool: Boolean;
begin
  for i:=Low(arrPages) to High(arrPages) do
   begin
    if arrPages[i].idx = 0 then
     arrPages[i].idx := 100;
//     SetLength(arrPages[i].Caption, 0);
    arrPages[i].Caption := getTranslation(arrPages[i].Caption);
   end;
  repeat
    bool := true;
    for i:=0 to High(arrPages)-1 do
    if arrPages[i].idx > arrPages[i+1].idx then
      begin
         pp := arrPages[i];
         arrPages[i] := arrPages[i+1];
         arrPages[i+1] := pp;
         bool := false
      end;
  until bool;
end;

procedure TprefFrm.closeBtnClick(Sender: TObject);
begin
  Close;
end;

procedure TprefFrm.FormPaint(Sender: TObject);
begin
//  wallpaperize(canvas);
end;

procedure TprefFrm.SetViewMode(pages: array of TPrefPage);
var
  i, j, k: integer;
//var
  pg: PPrefPage;
  protoPages: TPrefPagesArr;
  FRM_H_Scaled, FRM_W_Scaled: Integer;
//  FrameClass: TClass;
  n: PVirtualNode;
begin
  FRM_H_Scaled := MulDiv(FRM_HEIGHT, self.Monitor.PixelsPerInch, PixelsPerInch);
  FRM_W_Scaled := MulDiv(FRM_WIDTH, self.Monitor.PixelsPerInch, PixelsPerInch);
  if Length(pages) = 0 then
    begin
{      SetLength(arrPages, Length(prefPages));
      j := 0;
      for i := 0 to Length(prefPages)-1 do
        begin
         if PrefIsVisiblePage(prefPages[i].Name) then
          begin
           arrPages[j] := prefPages[i].Clone;
           inc(j);
          end;
        end;}
      j := Length(prefPages);
      SetLength(arrPages, j);
      for i := 0 to j-1 do
        arrPages[i] := prefPages[i].Clone;

      protoPages := getProtosPref;
      k := Length(protoPages);
      if k > 0 then
       begin
         SetLength(arrPages, j+k);
         for I := 0 to k - 1 do
          begin
           arrPages[j+i] := protoPages[i];
           protoPages[i] := NIL;
          end;
         SetLength(protoPages, 0);
       end;

      clientWidth :=  GAP_SIZE + PrefList.Width + GAP_SIZE + FRM_W_Scaled + GAP_SIZE;
      clientHeight :=  GAP_SIZE + FRM_H_Scaled + GAP_SIZE + Bevel.Height + GAP_SIZE + okBtn.Height + GAP_SIZE;
      PrefList.Visible := true;
      resetBtn.Visible := true;

      resetBtn.top := clientHeight - resetBtn.height - GAP_SIZE;
      resetBtn.left := GAP_SIZE;


      applyBtn.top  := resetBtn.top;
      applyBtn.left := clientWidth - applyBtn.Width - GAP_SIZE;

      closeBtn.top  := resetBtn.top;
      closeBtn.left := applyBtn.left - closeBtn.Width - GAP_SIZE;

      okBtn.top  := resetBtn.top;
      okBtn.left := closeBtn.left - okBtn.Width - GAP_SIZE;


      Bevel.left := GAP_SIZE;
      Bevel.Width := clientWidth - GAP_SIZE - GAP_SIZE;
      Bevel.top :=  resetBtn.top - Bevel.Height - GAP_SIZE;

      Self.GlassFrame.Bottom := resetBtn.height + GAP_SIZE shl 1 + 2;

      PrefList.height := Bevel.top - GAP_SIZE - GAP_SIZE;
      PrefList.top := GAP_SIZE;
      PrefList.left := GAP_SIZE;

      framePnl.height := PrefList.height;
      framePnl.top := GAP_SIZE;
      framePnl.left := PrefList.left + PrefList.Width + GAP_SIZE;
      framePnl.Width := clientWidth - framePnl.left - GAP_SIZE;
    end
   else
    begin
      SetLength(arrPages, Length(pages));
      for i := 0 to Length(pages)-1 do
        begin
         arrPages[i] := pages[i].Clone;
        end;
      clientWidth :=  GAP_SIZE + FRM_W_Scaled + GAP_SIZE;
      clientHeight :=  GAP_SIZE + FRM_H_Scaled + GAP_SIZE + Bevel.Height + GAP_SIZE + okBtn.Height + GAP_SIZE;
      PrefList.Visible := false;
      resetBtn.Visible := false;

      applyBtn.top  := clientHeight - resetBtn.height - GAP_SIZE;
      applyBtn.left := GAP_SIZE;

      closeBtn.top  := applyBtn.top;
      closeBtn.left := clientWidth - closeBtn.Width - GAP_SIZE;

      okBtn.top  := applyBtn.top;
      okBtn.left := closeBtn.left - okBtn.Width - GAP_SIZE;

      framePnl.top := GAP_SIZE;
      framePnl.left := GAP_SIZE;
      framePnl.height := FRM_H_Scaled;
      framePnl.Width := clientWidth - framePnl.left - GAP_SIZE;

      Bevel.left := GAP_SIZE;
      Bevel.Width := clientWidth - GAP_SIZE - GAP_SIZE;
      Bevel.top :=  applyBtn.top - Bevel.Height - GAP_SIZE;

      Self.GlassFrame.Bottom := resetBtn.height + GAP_SIZE shl 1 + 2;
    end;

  Bevel.Visible := not(StyleServices.Enabled and DwmCompositionEnabled);

  sortPrefPages;
  try
   for i := 0 to Length(arrPages)-1 do
   begin
    try
//     pagesBox.items.Add(arrPages[i].Cptn);
//     FrameClass := GetClass(FrameClassName);
//      MainFrame := TFrameClass(FrameClass).Create(self);
     arrPages[i].frame := arrPages[i].frameClass.Create(self);
//     pagesBox.items.objects[i] := arrPages[i].frame;
     with arrPages[i].frame do
      begin
        Name := 'Page' + IntToStr(i);
        align := alClient;
        Parent := framePnl;
      end;
     PrefList.BeginUpdate;
     n := PrefList.AddChild(nil);
     pg := PrefList.GetNodeData(n);
     pg^ := arrPages[i].Clone;
     PrefList.EndUpdate;
//     pg := nil;
     Application.ProcessMessages;
     arrPages[i].frame.initPage;
     Application.ProcessMessages;
     applyCommonsettings(arrPages[i].frame);
     translateComponent(arrPages[i].frame, Self);
    except
      on e: Exception do
       begin
        arrPages[i].frame := NIL;
        msgDlg(getTranslation('Error on create page')+' "' +
             getTranslation(arrPages[i].Caption) + '"!' + CRLF+
             e.Message, False, mtError);
       end;
    end;
   end;
   SetActivePage(0);
//   PrefList.FocusedNode := PrefList.GetFirst;
//   PrefList.Selected[PrefList.FocusedNode] := True;
//   pagesBoxClick(NIL);
  except
    prefFrm := nil;
  end;

 reset;

end;


procedure TprefFrm.SetBtnEnable(Value: Boolean);
begin
  if not Assigned(Self) then
    Exit;

  resetBtn.Enabled := Value;
  okBtn.Enabled := Value;
  closeBtn.Enabled := Value;
  applyBtn.Enabled := Value;
end;

procedure TprefFrm.SetActivePage(i: Integer);
var
  k: Integer;
  n: PVirtualNode;
//  r: Tresults;
begin
//        prefFrm.pagesBox.ItemIndex:=i;
//   prefFrm.PrefList.FocusedNode := prefFrm.PrefList.get
  n := PrefList.GetFirst;
  k := 1;
  if n <> nil then
   begin
    repeat
//      if TPrefPage(PPrefPage(PrefList.getnodedata(n))^) [2] = wp.uin then
//       exit;
      n := PrefList.GetNext(n);
      inc(k);
    until (n=nil) or (k>i);
   end;
   if (n = NIL)or(i=0) then
     prefFrm.PrefList.FocusedNode := prefFrm.PrefList.GetFirst
    else
     prefFrm.PrefList.FocusedNode := n;
//   prefFrm.PrefList.SelectedCount := 0;
   if prefFrm.PrefList.FocusedNode <> NIL then
     prefFrm.PrefList.Selected[prefFrm.PrefList.FocusedNode] := True;
   pagesBoxClick(NIL);
end;

procedure TprefFrm.SetActivePage(const pn: String);
var
//  k: Integer;
  n: PVirtualNode;
//  r: Tresults;
begin
//        prefFrm.pagesBox.ItemIndex:=i;
//   prefFrm.PrefList.FocusedNode := prefFrm.PrefList.get
  n := PrefList.GetFirst;
//  k := 1;
  if (n <> nil)and(pn <> '') then
   begin
    repeat
//      if TPrefPage(PPrefPage(PrefList.getnodedata(n))^) [2] = wp.uin then
//       exit;
      n := PrefList.GetNext(n);
      if n <> NIL then
       if pn = TPrefPage(PPrefPage(PrefList.getnodedata(N))^).Name then
        break;
//      inc(k);
    until (n=nil);
   end;
   if (n = NIL)or(pn='') then
     prefFrm.PrefList.FocusedNode := prefFrm.PrefList.GetFirst
    else
     prefFrm.PrefList.FocusedNode := n;
//   prefFrm.PrefList.SelectedCount := 0;
   if prefFrm.PrefList.FocusedNode <> NIL then
     prefFrm.PrefList.Selected[prefFrm.PrefList.FocusedNode] := True;
   pagesBoxClick(NIL);
end;


INITIALIZATION

 AddPrefPage1(1, TconnectionFr, 'Connection');
 AddPrefPage1(3, TantispamFr, 'Anti-spam');
 AddPrefPage1(4, TautoawayFr, 'Auto-away');

 AddPrefPage1(5, TdesignFr, 'Design');
 AddPrefPage1(6, TchatFr, 'Chat');
 AddPrefPage1(7, TTipsFr, 'Tips');

 AddPrefPage1(10, TstartFr, 'Start');

 AddPrefPage1(15, TsecurityFr, 'Privacy & Security');
 AddPrefPage1(16, ThotkeysFr, 'Hotkeys');

 AddPrefPage1(20, TeventsFr, 'Events');
// AddPrefPage1(21, TlogFr, 'Log packets & events');

 AddPrefPage1(30, TpluginsFr, 'Plugins');

 AddPrefPage1(95, TupdateFr, 'Auto-update');

 AddPrefPage1(96, TthemeditFr, 'Theme editor');
 AddPrefPage1(99, TotherFr, 'Other');

end.
