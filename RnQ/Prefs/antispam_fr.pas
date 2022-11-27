{
This file is part of R&Q.
Under same license
}
unit antispam_fr;
{$I RnQConfig.inc}
{$I NoRTTI.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  StdCtrls, ExtCtrls, ComCtrls, VirtualTrees, Menus,
  RnQButtons, RnQSpin, RDGlobal,
  RnQPrefsInt, RnQPrefsTypes,
  RnQConst,
  RnQProtocol;


type
  TantispamFr = class(TPrefFrame)
    plBg: TPanel;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    IgnoreAuthNILChk: TCheckBox;
    ignorepagersChk: TCheckBox;
    ignorenilChk: TCheckBox;
    warnChk: TCheckBox;
    gb: TGroupBox;
    notnilChk: TCheckBox;
    badwordsChk: TCheckBox;
    notemptyChk: TCheckBox;
    multisendChk: TCheckBox;
    uingtChk: TCheckBox;
    badwordsBox: TMemo;
    uingSpin: TRnQSpinEdit;
    UseBotChk: TCheckBox;
    SpamFileChk: TCheckBox;
    QuestBox: TComboBox;
    QstGrp: TGroupBox;
    QuestAddBtn: TRnQSpeedButton;
    QuestDelBtn: TRnQSpeedButton;
    QuestMemo: TMemo;
    qstLbl: TLabel;
    TrCntBox: TComboBox;
    Label1: TLabel;
    AnsMemo: TMemo;
    Label2: TLabel;
    IgnoreSht: TTabSheet;
    IgnoreTree: TVirtualDrawTree;
    AddIgnBtn: TRnQButton;
    AddIgnSrvBtn: TRnQButton;
    RmvIgnSrvBtn: TRnQButton;
    RmvIgnBtn: TRnQButton;
    UseIgnChk: TCheckBox;
    BotInInvisChk: TCheckBox;
    AddSpamToHistChk: TCheckBox;
    procedure QuestBoxChange(Sender: TObject);
    procedure QuestAddBtnClick(Sender: TObject);
    procedure QuestDelBtnClick(Sender: TObject);
    procedure IgnoreTreeFreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure IgnoreTreeDrawNode(Sender: TBaseVirtualTree;
      const PaintInfo: TVTPaintInfo);
    procedure RmvIgnBtnClick(Sender: TObject);
    procedure AddIgnBtnClick(Sender: TObject);
    procedure AddIgnSrvBtnClick(Sender: TObject);
  private
    lastqst: Integer;
    qst: TQuestAnsArr;
    menu: TPopupMenu;
    { Private declarations }
    procedure LoadQuests;
    procedure SaveQuests;
    procedure fillIgnoreList;
    procedure AddToIgnoreAction(sender: Tobject);
//    procedure addBtnClick(Sender: TObject);
    procedure Sendmessage1Click(Sender: TObject);
    procedure Viewinfo1Click(Sender: TObject);
    function  current: TRnQcontact;
    procedure MenuPopup(Sender: TObject);
  public
    procedure applyPage; Override;
    procedure resetPage; Override;
    procedure initPage(prefs: IRnQPref); Override;
    procedure updateVisPage; Override;
    { Public declarations }
  end;

implementation

{$R *.dfm}
uses
  StrUtils, Math,
  RnQMenu, RDUtils, RnQLangs,
  RQThemes, RnQPics, utilLib,
  globalLib, selectcontactsDlg,
  chatDlg
  ;

type
  PIgnItem = ^TIgnItem;
  TIgnItem = record
//     s: array[0..1] of string;
     s0: string;
     s1: TUID;
     isSrv: Boolean;
//     Pl: T;
  end;

procedure TantispamFr.updateVisPage;
begin
{$IFDEF UseNotSSI}
  AddIgnSrvBtn.Enabled := useSSI2;
{$ELSE UseNotSSI}
  AddIgnSrvBtn.Enabled := True;
{$ENDIF UseNotSSI}
end;


procedure TantispamFr.fillIgnoreList;
var
//  i: integer;
  PlItem: PIgnItem;
  n: PVirtualNode;
  cnt: tRnQcontact;
begin
  IgnoreTree.Clear;
// if prefPages[thisPrefIdx].frame = NIL then exit;
  IgnoreTree.BeginUpdate;
  ignoreList.resetEnumeration;
  while ignoreList.hasMore do
   begin
     cnt := ignoreList.getNext;
     n := IgnoreTree.AddChild(nil);
     PlItem := IgnoreTree.GetNodeData(n);
     PlItem.s0 := cnt.displayed;

     if PlItem.s0 <> String(cnt.UID) then
       PlItem.s0 := PlItem.s0 + ' ('+ cnt.uin2Show +')';
//      else
//       PlItem.s0 := s;
     PlItem.s1 := cnt.UID;
     PlItem.isSrv := cnt.isInList(LT_SPAM);
//     PlItem.Pl   := pl;
//     n.CheckType := ctCheckBox;
{     if 0=pos(pl.filename, disabledPlugins) then
       n.CheckState := csCheckedNormal
      else
       n.CheckState := csUncheckedNormal;
{  with list do
    begin
    if pl.screenname='' then
      items.add('('+getTranslation('Filename')+') '+pl.filename)
    else
      items.add(pl.screenName);
    items.objects[items.count-1]:=Tobject(pl);
    checked[items.count-1]:= 0=pos(pl.filename, disabledPlugins);
    end;}
  end;

  IgnoreTree.EndUpdate;
end;

procedure TantispamFr.IgnoreTreeDrawNode(Sender: TBaseVirtualTree;
  const PaintInfo: TVTPaintInfo);
var
  PItem: PIgnItem;
  x, OldMode: Integer;
begin
//  if PaintInfo.Column in [0..1] then
  begin
     if vsSelected in PaintInfo.Node.States then
       paintinfo.canvas.Font.Color := clHighlightText
      else
       paintinfo.canvas.Font.Color := clWindowText;
     x := PaintInfo.ContentRect.Left;
//     y := 0;
     PItem := PIgnItem(sender.getnodedata(paintinfo.node));
     if PItem.isSrv then
       inc(x, theme.drawPic(paintinfo.canvas.Handle, x,1, PIC_SPECIAL).cx+2);

     oldMode := SetBKMode(paintinfo.canvas.Handle, TRANSPARENT);
//      paintinfo.canvas.textout(x, 2, PItem.s[PaintInfo.Column]);
      paintinfo.canvas.textout(x, 2, PItem.s0);
     SetBKMode(paintinfo.canvas.Handle, oldMode);
  end;
end;

procedure TantispamFr.IgnoreTreeFreeNode(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
begin
  with TIgnItem(Sender.getnodedata(Node)^) do
//  with PPlItem(Sender.getnodedata(Node)) do
   begin
     s0 := '';
     s1 := '';
   end;
end;

// fillIgnoreGrid

function TantispamFr.current: TRnQcontact;
var
  d: Pointer;
begin
  result := NIL;
  if IgnoreTree.FocusedNode = NIL then
    exit;
//  if TIgnItem(PListItem(IgnoreTree.getnodedata(IgnoreTree.FocusedNode))^).kind = LI_group then
//   result := NIL
//  else
   d := IgnoreTree.getnodedata(IgnoreTree.FocusedNode);
   if d <> NIL then
     result := Account.AccProto.getContact(TIgnItem(PIgnItem(d)^).s1);
end;

procedure TantispamFr.MenuPopup(Sender: TObject);
var
 C: TRnQcontact;
// i: Integer;
 it: TMenuItem;
begin
 c := current;
 if Sender is TPopupMenu then
//  with TPopupMenu(sender) do
   for it in TPopupMenu(sender).Items do
//    for i := 0 to TPopupMenu(sender).Items.Count -1 do
    it.Enabled := C <> NIL;
//         TPopupMenu(sender).Items[i].Enabled := C <> NIL;

end;
procedure TantispamFr.Viewinfo1Click(Sender: TObject);
var
  cnt: TRnQContact;
begin
  cnt := current;
  if Assigned(cnt) then
    cnt.ViewInfo;
end;

procedure TantispamFr.Sendmessage1Click(Sender: TObject);
begin
  chatFrm.openOn(current)
end;


procedure TantispamFr.initPage;
begin
  Inherited;
  badwordsBox.Width := gb.Width - GAP_SIZE2;
  badwordsBox.left := GAP_SIZE;;

  uingSpin.left := GAP_SIZE + 150;
  uingSpin.Width := gb.Width - GAP_SIZE2 - 150;
  IgnoreTree.NodeDataSize := SizeOf(TIgnItem);
  menu := TPopupMenu.Create(self);
  AddToMenu(menu.Items, 'View info', PIC_INFO, True, Viewinfo1Click);
  AddToMenu(menu.Items, 'Send message', PIC_MSG, False, Sendmessage1Click);
  IgnoreTree.PopupMenu := menu;
  menu.OnPopup := MenuPopup;
end;

procedure TantispamFr.AddIgnBtnClick(Sender: TObject);
var
  cntcts: TselectCntsFrm;
begin
//  cntcts := TselectContactsFrm.Create(Self);
  cntcts := TselectCntsFrm.doAll(Self, 'Select contacts to ignore',
     'Select', Account.AccProto,
     notInList.clone.add(Account.AccProto.readList(LT_ROSTER)), AddToIgnoreAction,
     [sco_groups], @cntcts);
end;

procedure TantispamFr.AddIgnSrvBtnClick(Sender: TObject);
var
  n: PVirtualNode;
  cnt: TRnQcontact;
begin
  n := IgnoreTree.FocusedNode;
  if (n = NIL)
{$IFDEF UseNotSSI}
   or not useSSI2
{$ENDIF UseNotSSI}
  then
    Exit;
  if not OnlFeature(Account.AccProto)  then
    Exit;
  cnt := Account.AccProto.getContact(PIgnItem(IgnoreTree.GetNodeData(n)).s1);
//  if useSSI then
  if Assigned(cnt)and Assigned(Account.AccProto)and Account.AccProto.isOnline
{$IFDEF UseNotSSI}
   and useSSI2
{$ENDIF UseNotSSI}
  then
    begin
     Account.AccProto.AddToList(LT_SPAM, cnt);
     PIgnItem(IgnoreTree.GetNodeData(n)).isSrv := True;
    end;
end;

procedure TantispamFr.AddToIgnoreAction(sender: Tobject);
var
  wnd: TselectCntsFrm;
  cntct: TRnQContact;
//  histFile: String;
//  rslt: String;
//  fn: String;
  PlItem: PIgnItem;
  n: PVirtualNode;
begin
  if (not (sender is Tcontrol))or(not((sender as Tcontrol).parent is TselectCntsFrm)) then
   Exit;
  wnd := (sender as Tcontrol).parent as TselectCntsFrm;
  cntct := wnd.current;
  if cntct = NIL then
//    msgDlg('You must select contact', mtInformation)
   else
    begin
     addToIgnorelist(cntct, True);

     n := IgnoreTree.AddChild(nil);
     PlItem := IgnoreTree.GetNodeData(n);
     PlItem.s0 := cntct.displayed;
     if PlItem.s0 <> String(cntct.UID) then
       PlItem.s0 := PlItem.s0 + '('+cntct.uin2Show+')';
//      else
//       PlItem.s0 := cntct.UID;
     PlItem.s1 := cntct.UID;
//     PlItem.isSrv := usessi and ICQ.isOnline;
//     PlItem.isSrv := usessi and ICQ.isOnline;
     PlItem.isSrv := Account.AccProto.isInList(LT_SPAM, cntct);

    end;
  wnd.Close;
  self.SetFocus;
end;


procedure TantispamFr.applyPage;
begin
  enableIgnorelist := UseIgnChk.checked;
  spamfilter.warn := warnChk.checked;
  spamfilter.addToHist := AddSpamToHistChk.Checked;
  spamfilter.ignoreNIL := ignorenilChk.checked;
  spamfilter.ignorepagers := ignorepagersChk.checked;
//  spamfilter.
  spamfilter.ignoreauthNIL := IgnoreAuthNILChk.checked;
  spamfilter.multisend := multisendChk.checked;
  spamfilter.notnil := notnilChk.checked;
  spamfilter.notEmpty := notemptyChk.checked;
  spamfilter.noBadwords := badwordsChk.checked;
  spamfilter.badwords := AnsiReplaceStr(badwordsBox.text, CRLF, ';');
  if TrCntBox.ItemIndex in [0..4] then
    spamfilter.BotTryesCount := TrCntBox.ItemIndex + 2;
  if uingtChk.checked then
    spamfilter.uingt := round(uingSpin.value)
   else
    spamfilter.uingt := 0;
// Bot
  spamfilter.useBot := UseBotChk.Checked;
  spamfilter.useBotInInvis := BotInInvisChk.Checked;
  spamfilter.UseBotFromFile := SpamFileChk.Checked;
  SaveQuests;
end;

procedure TantispamFr.resetPage;
begin
  UseIgnChk.checked := enableIgnorelist;
  ignorenilChk.checked := spamfilter.ignoreNIL;
  ignorepagersChk.checked := spamfilter.ignorePagers;
  warnChk.checked := spamfilter.warn;
  AddSpamToHistChk.Checked := spamfilter.addToHist;
  IgnoreAuthNILChk.checked := spamfilter.ignoreauthNIL;
  notnilChk.checked := spamfilter.notNil;
  notemptyChk.checked := spamfilter.notEmpty;
  multisendChk.checked := spamfilter.multisend;
  badwordsChk.checked := spamfilter.noBadwords;
  badwordsBox.lines.text := AnsiReplaceStr(spamfilter.badwords,';',CRLF);
  uingtChk.checked := spamfilter.uingt > 0;
  if spamfilter.uingt=0 then
    uingSpin.value := 150000000
   else
    uingSpin.value := spamfilter.uingt;

// Bot
  UseBotChk.Checked := spamfilter.useBot;
  BotInInvisChk.Checked := spamfilter.useBotInInvis;
  SpamFileChk.Checked := spamfilter.UseBotFromFile;
  TrCntBox.ItemIndex := bound(spamfilter.BotTryesCount - 2, 0, 4);

  LoadQuests;
  lastqst := -1;
  if QuestBox.Items.Count > 0 then
    QuestBox.ItemIndex := 0;
  QuestBoxChange(QuestBox);
{     QuestBox.ItemIndex := QuestBox.Items.Count-1;
     lastqst := QuestBox.ItemIndex;
     QuestEdit.Text := qst[lastqst].q;
     AnsEdit.Text   := qst[lastqst].a;}
  fillIgnoreList;
end;

procedure TantispamFr.RmvIgnBtnClick(Sender: TObject);
var
  n: PVirtualNode;
  cnt: TRnQcontact;
begin
  n := IgnoreTree.FocusedNode;
  if n = NIL then
    Exit;
  cnt := ignoreList.get(Account.AccProto.getContactClass, PIgnItem(IgnoreTree.GetNodeData(n)).s1);
//  if icq.readSpamList.exists(PIgnItem(IgnoreTree.GetNodeData(n)).s[1]) then
  removeFromIgnorelist(cnt);
  IgnoreTree.FocusedNode := IgnoreTree.GetPrevious(n);
  if IgnoreTree.FocusedNode = NIL then
    IgnoreTree.FocusedNode := IgnoreTree.GetNext(n);
  if IgnoreTree.FocusedNode <> NIL then
    IgnoreTree.Selected[IgnoreTree.FocusedNode] := True;
  IgnoreTree.DeleteNode(n);
//  if n <> NIL then
//    PPlItem(IgnoreTree.GetNodeData(n)).Pl.cast_preferences;
end;

procedure Answers0(var ans: array of string);
// Init ans array
  var
    I: Integer;
  begin
     for I := Low(ans) to High(ans) do
       SetLength(ans[i], 0);
//     SetLength(ans, 0);
  end;

procedure TantispamFr.LoadQuests;
var
//  cfg, l, h: string;
  i: Integer;
begin
  SetLength(qst, Length(spamfilter.quests));
  QuestBox.Items.Clear;
  qst := Copy(spamfilter.quests);
  for i := 0 to Length(spamfilter.quests) - 1 do
    begin
//     qst[i] := spamfilter.quests[i];
{
     qst[i].q := spamfilter.quests[i].q;
     Answers0(qst[i].a);
     SetLength(qst[i].a, length(spamfilter.quests[i].ans));
     for j := 0 to Length(spamfilter.quests[i].ans) - 1 do
       qst[i].a[j] := spamfilter.quests[i].ans[j];
}
     QuestBox.Items.Add(getTranslation('Question') + IntToStr(i+1));
    end;
end;

procedure TantispamFr.SaveQuests;
var
//  cfg: string;
  I: Integer;
begin
  if QuestBox.ItemIndex >=0 then
     with qst[QuestBox.ItemIndex] do
       begin
         q := QuestMemo.Text;
         Answers0(ans);
         SetLength(ans, 0);
         for I := 0 to AnsMemo.Lines.Count - 1 do
          if Trim(AnsMemo.Lines.Strings[i]) > '' then
           begin
            SetLength(ans, length(ans)+1);
            ans[Length(ans)-1] := Trim(AnsMemo.Lines.Strings[i]);
           end;
       end;
  SetLength(spamfilter.quests, Length(qst));
  spamfilter.quests := Copy(qst);
{
//  QuestBox.Items.Clear;
  for I := 0 to Length(qst) - 1 do
    begin
     spamfilter.quests[i].q := qst[i].q;
//     spamfilter.quests[i].a := qst[i].a;
     Answers0(spamfilter.quests[i].ans);
     SetLength(spamfilter.quests[i].ans, 0);
     for J := 0 to Length(qst[i].ans) - 1 do
       begin
        SetLength(spamfilter.quests[i].ans, length(spamfilter.quests[i].ans)+1);
        spamfilter.quests[i].ans[Length(spamfilter.quests[i].ans)-1] := qst[i].ans[J];
       end;
//      QuestBox.Items.Add('Question' + IntToStr(i+1));
    end;}
  saveListsDelayed := True;
//  SaveSpamQuests;
end;


procedure TantispamFr.QuestAddBtnClick(Sender: TObject);
var
  i: Integer;
begin
  i := Length(qst);
  SetLength(qst, i+1);
  QuestBox.Items.Add(getTranslation('Question') + IntToStr(i+1));
  with qst[i] do
   begin
    q := '';
    Answers0(ans);
    SetLength(ans, 0);
   end;
  QuestBox.ItemIndex := i;
  QuestBoxChange(QuestBox);
end;

procedure TantispamFr.QuestBoxChange(Sender: TObject);
var
  I: Integer;
begin
  if lastqst <> QuestBox.ItemIndex then
   begin
     if (lastqst >= Low(qst))and (lastqst <= High(qst)) then
     with qst[lastqst] do
       begin
         q := QuestMemo.Text;
//         a := AnsEdit.Text;
         Answers0(ans);
         SetLength(ans, 0);
         for I := 0 to AnsMemo.Lines.Count - 1 do
          if Trim(AnsMemo.Lines.Strings[i]) > '' then
           begin
            SetLength(ans, length(ans)+1);
            ans[Length(ans)-1] := Trim(AnsMemo.Lines.Strings[i]);
           end;
       end;
     if QuestBox.ItemIndex = -1 then
       begin
        lastqst := QuestBox.ItemIndex;
        QuestMemo.Text := '';
        AnsMemo.Text   := '';
        QuestMemo.Enabled := False;
        AnsMemo.Enabled := False;
       end
     else
      begin
        lastqst := QuestBox.ItemIndex;
        QuestMemo.Text := qst[lastqst].q;
        AnsMemo.Text   := '';
        for I := 0 to Length(qst[lastqst].ans) - 1 do
          AnsMemo.Lines.Add(qst[lastqst].ans[i]);
        QuestMemo.Enabled := True;
        AnsMemo.Enabled := True;
      end;
   end;
end;

procedure TantispamFr.QuestDelBtnClick(Sender: TObject);
var
  i, j: Integer;
begin
  i := QuestBox.ItemIndex;
  if (QuestBox.Items.Count <= 0) or (i = -1) then
    Exit;

  if Length(qst) <> i+1 then
    for j := i + 1 to Length(qst) - 1 do
      qst[j - 1] := qst[j];
  SetLength(qst, Length(qst) - 1);

  QuestBox.Items.Delete(i);
  if Length(qst) = i then
    QuestBox.ItemIndex := i-1
   else
    begin
      lastqst := -1;
      QuestBox.ItemIndex := i;
    end;
  QuestBoxChange(QuestBox);
  QuestBox.Repaint;
end;

end.
