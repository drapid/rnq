{
This file is part of R&Q.
Under same license
}
unit events_fr;
{$I RnQConfig.inc}
{$I NoRTTI.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  ExtCtrls, StdCtrls, ComCtrls, RnQButtons, RnQSpin,
  RnQProtocol, RDGlobal,
 {$IFDEF PREF_IN_DB}
  DBPrefsLib,
 {$ELSE ~PREF_IN_DB}
  RnQPrefsLib,
 {$ENDIF PREF_IN_DB}
  VirtualTrees;

type
  TeventsFr = class(TPrefFrame)
    Label3: TLabel;
    s: TPageControl;
    MainTS: TTabSheet;
    Label4: TLabel;
    DLLLbl: TLabel;
    SndVolSlider: TTrackBar;
    autoconsumeChk: TCheckBox;
    BringInfoChk: TCheckBox;
    focuschatpopupChk: TCheckBox;
    minOnOffChk: TCheckBox;
    oncomingOnAwayChk: TCheckBox;
    minOnOffSpin: TRnQSpinEdit;
    TestVolSButton: TRnQButton;
    EvntGrp: TGroupBox;
    Label1: TLabel;
    Label5: TLabel;
    Label9: TLabel;
    tipSpin: TRnQSpinEdit;
    tiptimesChk: TCheckBox;
    tipplusSpin: TRnQSpinEdit;
    TestEvBtn: TRnQButton;
    TrigList: TVirtualDrawTree;
    eventBox: TComboBox;
    DisEvTS: TTabSheet;
    GroupBox1: TGroupBox;
    Label2: TLabel;
    TipsChk: TCheckBox;
    BlinkChk: TCheckBox;
    SndChk: TCheckBox;
    chatChk: TCheckBox;
    statusBox: TComboBox;
    VolLbl: TLabel;
    playSnds: TCheckBox;
    LogTS: TTabSheet;
    PckLogGrp: TGroupBox;
    pktclearChk: TCheckBox;
    pktfileChk: TCheckBox;
    pktwndChk: TCheckBox;
    EvLogGrp: TGroupBox;
    evtwndChk: TCheckBox;
    evtfileChk: TCheckBox;
    evtclearChk: TCheckBox;
    BDTS: TTabSheet;
    BD1Chk: TCheckBox;
    BD1Spin: TRnQSpinEdit;
    LDays1: TLabel;
    BD2Chk: TCheckBox;
    BD2Spin: TRnQSpinEdit;
    LDays2: TLabel;
    ClosedGrpChk: TCheckBox;
    procedure RnQSpeedButton1Click(Sender: TObject);
    procedure TestVolSButtonClick(Sender: TObject);
    procedure eventBoxSelect(Sender: TObject);
    procedure trigBoxClickCheck(Sender: TObject);
    procedure tipSpinChange(Sender: TObject);
    procedure tiptimesChkClick(Sender: TObject);
    procedure tipplusSpinChange(Sender: TObject);
    procedure UpdVis(Sender: TObject);
    procedure eventBoxDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure TrigListDrawNode(Sender: TBaseVirtualTree;
      const PaintInfo: TVTPaintInfo);
    procedure TrigListChecked(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure TrigListFreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure statusBoxSelect(Sender: TObject);
    procedure TipsChkClick(Sender: TObject);
    procedure statusBoxDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure eventBoxMeasureItem(Control: TWinControl; Index: Integer;
      var Height: Integer);
    procedure statusBoxMeasureItem(Control: TWinControl; Index: Integer;
      var Height: Integer);
  private
    { Private declarations }
    settingStatus : Boolean;
//    vOnStatusDisable : array[TICQstatus] of TOnStatusDisable;
    vOnStatusDisable : array of TOnStatusDisable;
    function currentStatus: byte;
  public
    procedure initPage; Override;
    procedure unInitPage; Override;
    procedure applyPage; Override;
    procedure resetPage; Override;
    procedure updateVisPage; Override;
    { Public declarations }
  end;

implementation

{$R *.dfm}

uses
  utilLib, events, globalLib,
  RnQGraphics32, RnQGlobal,
  RnQTips, RnQLangs, Dynamic_BASS,
  Math, pluginutil,
  RQThemes, RQUtil, RnQBinUtils;//, prefDlg;

type
  PAcItem = ^TAcItem;
  TAcItem = record
//     s : array[0..1] of string;
     ac : Tbehaction;
     s : string;
  end;

const
  PrefIsShowBDFirst  = 'is-show-bd-first';
  PrefShowBDFirst    = 'show-bd-first';
  PrefIsShowBDBefore = 'is-show-bd-before';
  PrefShowBDBefore   = 'show-bd-before';

var
  tempBeh :Tbehaviours;

procedure TeventsFr.eventBoxSelect(Sender: TObject);
var
  i: integer;
  ac: Tbehaction;
  b: boolean;
  AcItem : PAcItem;
  n : PVirtualNode;
begin
  i := eventBox.itemIndex + 1;
{  trigBox.items.Clear;
  for ac := low(ac) to high(ac) do
  begin
    trigBox.items.add(behactionName(ac));
    trigBox.ItemEnabled[ord(ac) - ord(low(ac))] := ac in supportedBehactions[i];
    trigBox.checked[ord(ac) - ord(low(ac))] := ac in tempBeh[i].trig;
  end;}
  TrigList.Clear;
  for ac := low(ac) to high(ac) do
  begin
     n := TrigList.AddChild(nil);
     AcItem := TrigList.GetNodeData(n);
     AcItem.s := behactionName(ac);
     AcItem.ac := ac;
     if ac in supportedBehactions[i] then
       n.CheckType := ctCheckBox
      else
       begin
        n.CheckType := ctCheckBox;
        Include(n.States, vsDisabled);
//        n.di
        n.CheckState := csMixedNormal
       end;
     if ac in tempBeh[i].trig then
       n.CheckState := csCheckedNormal
      else
       n.CheckState := csUncheckedNormal;
  end;
  
  b := BE_tip in supportedBehactions[i];
  tipSpin.enabled := b;
  tipSpin.value := tempBeh[i].tiptime / 10;
  tiptimesChk.enabled := b;
  tiptimesChk.checked := tempBeh[i].tiptimes;
  tipplusSpin.enabled := b and tiptimesChk.checked;
  tipplusSpin.value := tempBeh[i].tiptimeplus / 10;
end;

procedure TeventsFr.trigBoxClickCheck(Sender: TObject);
var
  i: integer;
//  ac: Tbehaction;
  n : PVirtualNode;
  AcItem : PAcItem;
begin
  i := eventBox.itemIndex + 1;
  if i = 0 then Exit;

{  for ac := low(ac) to high(ac) do
    if trigBox.checked[ord(ac) - ord(low(ac))] then
      include(tempBeh[i].trig, ac)
    else
      exclude(tempBeh[i].trig, ac);
}
  n := TrigList.GetFirst;
  while n <> NIL do
   begin
     AcItem := TrigList.GetNodeData(n);
     if n.CheckState = csCheckedNormal then
       include(tempBeh[i].trig, AcItem.ac)
      else
       exclude(tempBeh[i].trig, AcItem.ac);
     n := TrigList.GetNext(n);
   end;
end;

procedure TeventsFr.TrigListChecked(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
var
  i: integer;
  AcItem : PAcItem;
begin
  if Node <> NIL then
  begin
    i := eventBox.itemIndex + 1;
    if i in [1..EK_last] then
    begin
     AcItem := TrigList.GetNodeData(Node);
     if Node.CheckState = csCheckedNormal then
       include(tempBeh[i].trig, AcItem.ac)
      else
       exclude(tempBeh[i].trig, AcItem.ac);
    end;
  end;
end;

procedure TeventsFr.TrigListDrawNode(Sender: TBaseVirtualTree;
  const PaintInfo: TVTPaintInfo);
var
//  x,y : Integer;
  AcItem : PAcItem;
  oldMode : Integer;
begin
//  if PaintInfo.Column in [0..0] then
  begin
    if vsDisabled in PaintInfo.Node.States then
      paintinfo.canvas.Font.Color := clGrayText
     else
//     if (vsSelected in PaintInfo.Node^.States) and  then
//       paintinfo.canvas.Font.Color := clHighlightText
//      else
       paintinfo.canvas.Font.Color := clWindowText;

//     x := PaintInfo.ContentRect.Left;
//     if PaintInfo.Node.CheckType = ctNone then
//       inc(x,
//     y := 0;
     AcItem := PAcItem(sender.getnodedata(paintinfo.node));
//     inc(x, theme.drawPic(paintinfo.canvas.Handle, x,y+1, IcItem.IconName).cx+2);

     oldMode := SetBKMode(paintinfo.canvas.Handle, TRANSPARENT);
//      paintinfo.canvas.textout(x, 2, AcItem.s);
      paintinfo.canvas.textout(PaintInfo.ContentRect.Left, 1, AcItem.s);
     SetBKMode(paintinfo.canvas.Handle, oldMode);
  end;
end;

procedure TeventsFr.TrigListFreeNode(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
begin
 {$WARN UNSAFE_CODE OFF}
  with TAcItem(PAcItem(Sender.getnodedata(Node))^) do
 {$WARN UNSAFE_CODE ON}
   begin
     SetLength(s, 0);
//     s := '';
   end;
end;

procedure TeventsFr.tipSpinChange(Sender: TObject);
begin
  if eventBox.itemIndex >=0 then
    tempBeh[eventBox.itemIndex + 1].tiptime := round(tipSpin.value * 10)
end;

procedure TeventsFr.tiptimesChkClick(Sender: TObject);
begin
  if eventBox.itemIndex >=0 then
    tempBeh[eventBox.itemIndex + 1].tiptimes := tiptimesChk.checked;
  updateVisPage;
end;

procedure TeventsFr.tipplusSpinChange(Sender: TObject);
begin
  if eventBox.itemIndex >=0 then
    tempBeh[eventBox.itemIndex + 1].tiptimeplus := round(tipplusSpin.value * 10)
end;

procedure TeventsFr.TipsChkClick(Sender: TObject);
var
  st:byte;
begin
  st := currentStatus;
  if st =$FF then Exit;
  if not settingStatus then
   begin
    vOnStatusDisable[st].tips     := TipsChk.Checked;
    vOnStatusDisable[st].blinking := BlinkChk.Checked;
    vOnStatusDisable[st].sounds   := SndChk.Checked;
    vOnStatusDisable[st].OpenChat := chatChk.Checked;
   end;
end;

procedure TeventsFr.UpdVis(Sender: TObject);
begin updateVisPage end;

procedure TeventsFr.eventBoxDrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
var
  cnv: Tcanvas;
//  x, y: integer;
  i : NativeInt;
  gR : TGPRect;
  picElm : TRnQThemedElementDtls;
  s : String;
begin
  gR.X := 2 + rect.left;
  gR.Y := rect.top;
 {$WARN UNSAFE_CAST OFF}
  i := NativeInt(TComboBox(Control).items.objects[index]);
 {$WARN UNSAFE_CAST ON}
  s := TComboBox(Control).Items.Strings[Index];
//  s := getTranslation(event2ShowStr[i]);
  cnv := TComboBox(Control).canvas;
  cnv.fillrect(rect);
  picElm.ThemeToken := 0;
  picElm.picName := event2imgName(i);
  picElm.Element := RQteDefault;
  picElm.pEnabled := True;
    with theme.GetPicSize(picElm, 20, GetParentCurrentDpi) do
     begin
      gr.Height := min(Rect.Bottom - Rect.Top, cy);
      gr.Width  := min(Rect.Right - Rect.Left, cx);
     end;
//  inc(gr.x, 2 + theme.drawPic(cnv.Handle, gR, event2imgName(i)).cx);
   inc(gr.x, 2 + theme.drawPic(cnv.Handle, gR, picElm, GetParentCurrentDpi).cx);
//  cnv.textout(x, y, s);
  Rect.Left := gR.X;
  DrawText(cnv.Handle, PChar(s), Length(s), Rect, DT_SINGLELINE or DT_VCENTER);
end;


procedure TeventsFr.eventBoxMeasureItem(Control: TWinControl; Index: Integer;
  var Height: Integer);
var
//  st: byte;
  Img : AnsiString;
begin
  if (index >=0) and (TComboBox(Control).items.Count >= index)
     and (TComboBox(Control).items.objects[index] <> NIL) then
   begin
//    st := byte(startingstatusBox.items.objects[index]);
 {$WARN UNSAFE_CAST OFF}
    Img := event2imgName(integer(TComboBox(Control).items.objects[index]));
 {$WARN UNSAFE_CAST ON}
     begin
       Height := max(theme.GetPicSize(RQteDefault, Img).cy+2, 20);
     end;
   end
end;

procedure TeventsFr.statusBoxDrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
var
  cnv: Tcanvas;
//  x, y: integer;
  st: byte;
  gR : TGPRect;
//  sp : PStatusProp;
  picElm : TRnQThemedElementDtls;
  s : String;
begin
  cnv := statusbox.canvas;
  gR.X := 2 + rect.left;
  gR.Y := rect.top;
  st := byte(TComboBox(Control).items.objects[index]);
{
//  sp := PStatusProp(statusBox.items.objects[index]);
//  inc(x, 2 + theme.drawPic(cnv.Handle, x, y, status2imgName(byte(st))).cx);
  inc(x, 2 + theme.drawPic(cnv.Handle, x, y, sp.ImageName).cx);
//  cnv.textout(x, y, statusNameExt2(st));
  cnv.textout(x, y, getTranslation(sp.Cptn));
}
  cnv.fillrect(rect);
  picElm.ThemeToken := 0;
  with Account.AccProto.getStatuses[st] do
   begin
    picElm.picName := ImageName;
    picElm.Element := RQteDefault;
    picElm.pEnabled := True;
    with theme.GetPicSize(picElm, 20) do
     begin
      gr.Height := min(Rect.Bottom - Rect.Top, cy);
      gr.Width  := min(Rect.Right - Rect.Left, cx);
     end;
    inc(gr.x, 2 + theme.drawPic(cnv.Handle, gR, picElm, GetParentCurrentDpi).cx);
    s := getTranslation(Cptn);
//  cnv.textout(x, y, s);
    Rect.Left := gR.X;
    DrawText(cnv.Handle, PChar(s), Length(s), Rect, DT_SINGLELINE or DT_VCENTER);
   end;
end;

procedure TeventsFr.statusBoxMeasureItem(Control: TWinControl; Index: Integer;
  var Height: Integer);
var
  st: byte;
begin
  if (index >=0) and (TComboBox(Control).items.Count >= index) then
   begin
    st := byte(TComboBox(Control).items.objects[index]);
    with Account.AccProto.getStatuses[st] do
     begin
       Height := max(theme.GetPicSize(RQteDefault, ImageName).cy+2, 20);
     end;
   end
end;

procedure TeventsFr.statusBoxSelect(Sender: TObject);
var
  st : byte;
begin
  st := currentStatus;
  if st = $FF then Exit;

{
  disableBox.checked[0] := onStatusDisable[currentStatus].tips;
  disableBox.checked[1] := onStatusDisable[currentStatus].blinking;
  disableBox.checked[2] := onStatusDisable[currentStatus].sounds;
  disableBox.checked[3] := onStatusDisable[currentStatus].OpenChat;}
  settingStatus := True;
  TipsChk.Checked  := vOnStatusDisable[st].tips;
  BlinkChk.Checked := vOnStatusDisable[st].blinking;
  SndChk.Checked   := vOnStatusDisable[st].sounds;
  chatChk.Checked  := vOnStatusDisable[st].OpenChat;
  settingStatus := False;
end;

procedure TeventsFr.initPage;
var
  i : Integer;
  st: byte;
  w : Integer;
//  st : TStatusProp;
//  sp : PStatusProp;
begin
  TrigList.NodeDataSize := SizeOf(TAcItem);
  for i:=1 to EK_last do
//    eventBox.Items.AddObject('',Tobject(i));
 {$WARN UNSAFE_CAST OFF}
    eventBox.Items.AddObject(getTranslation(event2ShowStr[i]),Tobject(i));
 {$WARN UNSAFE_CAST ON}

  EvntGrp.left  := GAP_SIZE;

  w := MainTS.ClientWidth - GAP_SIZE2;
  EvntGrp.width := w;

  PckLogGrp.Width := w;
  EvLogGrp.Width := w;


//  eventBox.left:= 60;
  eventBox.left := TrigList.Left + EvntGrp.Left;
  eventBox.width:= EvntGrp.width - eventBox.left - 10;
//  trigBox.width:=  eventBox.width;
  TrigList.width := eventBox.width;

  GroupBox1.width := EvntGrp.width;
  GroupBox1.left  := GAP_SIZE;

  statusBox.left := eventBox.left;
  statusBox.width:= eventBox.width;
//  disableBox.width:=  statusBox.width;

  SetLength(vOnStatusDisable, High(Account.AccProto.statuses)+1);
  // minus Offline&Unk
//for st:=SC_ONLINE to pred(SC_OFFLINE) do
//  for st := Low(MainProto.statuses) to High(MainProto.statuses) do
//  for st in MainProto.statuses do
  for st in Account.AccProto.getStatusMenu do
//  if (Byte(st.idx) <> Byte(SC_OFFLINE))and (Byte(st.idx) <> Byte(SC_UNK)) then
  if (st <> Byte(SC_OFFLINE))and (st <> Byte(SC_UNK)) then
  begin
{    New(sp);
    sp.idx := st.idx;
    sp.ShortName := st.ShortName;
    sp.Cptn := st.Cptn;
    sp.ImageName := st.ImageName;
    statusBox.Items.AddObject('',Tobject(sp));}
    statusBox.Items.AddObject('',Tobject(st));
  end;
  settingStatus := False;
end;

procedure TeventsFr.unInitPage;
//var
//  I: Integer;
begin
  statusBox.OnDrawItem := NIL;
{  for I := 0 to statusBox.Items.Count - 1 do
    begin
//     PStatusProp(statusBox.Items.Objects[i]).ShortName := '';
//     PStatusProp(statusBox.Items.Objects[i]).Cptn := '';
//     PStatusProp(statusBox.Items.Objects[i]).ImageName := '';
//     Dispose(PStatusProp(statusBox.Items.Objects[i]));
     statusBox.Items.Objects[i] := nil;
    end;}
  SetLength(vOnStatusDisable, 0);
  TrigList.Clear;
end;
  
procedure TeventsFr.applyPage;
var
  st : byte;
begin

  behaviour:=tempBeh;

  focusOnChatPopup:=focuschatpopupChk.checked;
  minOnOff:=minOnOffChk.checked;
  minOnOffTime:=round(minOnOffSpin.value);
  oncomingOnAway:=oncomingOnAwayChk.checked;
  BringInfoFrgd := BringInfoChk.Checked;
  Soundvolume := SndVolSlider.Position;
  autoconsumeevents:=autoconsumeChk.checked;
  playSounds:=playSnds.checked;
  for st := Low(Account.AccProto.statuses) to High(Account.AccProto.statuses) do
   begin
    OnStatusDisable[st].tips     := vOnStatusDisable[st].tips;
    OnStatusDisable[st].blinking := vOnStatusDisable[st].blinking;
    OnStatusDisable[st].sounds   := vOnStatusDisable[st].sounds;
    OnStatusDisable[st].OpenChat := vOnStatusDisable[st].OpenChat;
   end;
  DsblEvnt4ClsdGrp := ClosedGrpChk.Checked;
  logpref.pkts.onWindow:=pktwndChk.checked;
  logpref.pkts.onFile:=pktfileChk.checked;
  logpref.pkts.clear:=pktclearChk.checked;
  logpref.evts.onWindow:=evtwndChk.checked;
  logpref.evts.onFile:=evtfileChk.checked;
  logpref.evts.clear:=evtclearChk.checked;
  MainPrefs.addPrefBool(PrefIsShowBDFirst, BD1Chk.Checked);
  MainPrefs.addPrefBool(PrefIsShowBDBefore, BD2Chk.Checked);
  MainPrefs.addPrefInt(PrefShowBDFirst, BD1Spin.AsInteger);
  MainPrefs.addPrefInt(PrefShowBDBefore, BD2Spin.AsInteger);
end;

procedure TeventsFr.resetPage;
var
  st : byte;
begin

  focuschatpopupChk.checked:=focusOnChatPopup;
  minOnOffSpin.value:=minOnOffTime;
  minOnOffChk.checked:=minOnOff;
  oncomingOnAwayChk.checked:=oncomingOnAway;
  tempBeh:=behaviour;
  if eventBox.itemIndex=-1 then
    eventBox.itemIndex:=0;
  eventBox.onSelect(self);
{   try
    SndVolSlider.Max := BASS_GetConfig( BASS_CONFIG_MAXVOL);// := 100;
    except
   end;}
  BringInfoChk.Checked := BringInfoFrgd;
  SndVolSlider.Position := Soundvolume;
  autoconsumeChk.checked:=autoconsumeevents;
  playSnds.checked:=playSounds;
  for st := Low(Account.AccProto.statuses) to High(Account.AccProto.statuses) do
   begin
    vOnStatusDisable[st].tips     := OnStatusDisable[st].tips;
    vOnStatusDisable[st].blinking := OnStatusDisable[st].blinking;
    vOnStatusDisable[st].sounds   := OnStatusDisable[st].sounds;
    vOnStatusDisable[st].OpenChat := OnStatusDisable[st].OpenChat;
   end;
  ClosedGrpChk.Checked := DsblEvnt4ClsdGrp;
  if statusBox.itemIndex=-1 then
    statusBox.itemIndex:=0;
  statusBox.onSelect(self);
  pktwndChk.checked:=logpref.pkts.onWindow;
  pktfileChk.checked:=logpref.pkts.onFile;
  pktclearChk.checked:=logpref.pkts.clear;
  evtwndChk.checked:=logpref.evts.onWindow;
  evtfileChk.checked:=logpref.evts.onFile;
  evtclearChk.checked:=logpref.evts.clear;

  BD1Chk.Checked := MainPrefs.getPrefBoolDef(PrefIsShowBDFirst, True);
  BD2Chk.Checked := MainPrefs.getPrefBoolDef(PrefIsShowBDBefore, True);
  BD1Spin.AsInteger := MainPrefs.getPrefIntDef(PrefShowBDFirst, 7);
  BD2Spin.AsInteger := MainPrefs.getPrefIntDef(PrefShowBDBefore, 3);
end;

procedure TeventsFr.updateVisPage;
begin
  minOnOffSpin.enabled:=minOnOffChk.checked;
  tipplusSpin.enabled:=tiptimesChk.checked;
  TestVolSButton.Enabled := playSnds.Checked;
  SndVolSlider.Enabled := playSnds.Checked and audioPresent;
  SndVolSlider.Visible := audioPresent;
  VolLbl.Enabled := audioPresent;
  DLLLbl.Caption := getTranslation('Need bass.dll version %s', [intToStr(HiByte(BASSVERSION)) + '.' + intToStr(loByte(BASSVERSION))]);
  DLLLbl.Visible := not audioPresent;
end;

procedure TeventsFr.TestVolSButtonClick(Sender: TObject);
begin
  Soundvolume := SndVolSlider.Position;
  try theme.PlaySound('oncoming'); except end;
end;

procedure TeventsFr.RnQSpeedButton1Click(Sender: TObject);
var
  e: Thevent;
  i: Integer;
  s: AnsiString;
//  sR: RawByteString;
begin
  i := eventBox.itemIndex + 1;
  s := '';
  if i = EK_AUTOMSG then
    s := #00;
  if (i = EK_statuschange)or(i = EK_oncoming) then
    e := Thevent.new(i, Account.AccProto.getMyInfo,
            now, int2str(integer(SC_ONLINE))+AnsiChar(True) +AnsiChar(20)
            {$IFDEF DB_ENABLED},''{$ENDIF DB_ENABLED}, 0)
   else
  if i = EK_XstatusMsg then
    begin
     e := Thevent.new(i, Account.AccProto.getMyInfo, now, ''
             {$IFDEF DB_ENABLED},''{$ELSE ~DB_ENABLED}{$ENDIF DB_ENABLED}, 0);
 {$IFDEF DB_ENABLED}
        e.fBin := AnsiChar(integer(SC_ONLINE)) + _istring('Status');
        e.txt  := 'Status description';
 {$ELSE ~DB_ENABLED}
        e.f_info := AnsiChar(integer(SC_ONLINE)) + _istring('Status') + _istring('Status description')
 {$ENDIF ~DB_ENABLED}
    end
   else
    e := Thevent.new(i, Account.AccProto.getMyInfo, now, s
             {$IFDEF DB_ENABLED},{$ELSE ~DB_ENABLED}+{$ENDIF DB_ENABLED} 'Testing'+CRLF  + 'Second row ------- :)', 0);


//  TipAdd(e);
  TipAdd3(e);
//  tipfrm.show(e);
  e.Free;
end;

function TeventsFr.currentStatus: byte;
begin
//  result := (statusBox.itemIndex + ord(SC_ONLINE))
  if statusBox.itemIndex >=0 then
//    result := PStatusProp(statusBox.items.objects[statusBox.itemIndex]).idx;// byte(statusBox.items.objects[statusBox.itemIndex]);
    result := byte(statusBox.items.objects[statusBox.itemIndex])
   else
    Result := $FF; 

end;

end.
