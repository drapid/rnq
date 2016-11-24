{
This file is part of R&Q.
Under same license
}
unit HistAllSearch;
{$I RnQConfig.inc}
{$I NoRTTI.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  StdCtrls, ExtCtrls, RnQButtons, VirtualTrees,
  RnQProtocol;

type
  TAllHistSrchForm = class(TForm)
    SearchEdit: TLabeledEdit;
    caseChk: TCheckBox;
    reChk: TCheckBox;
    RoasterChk: TCheckBox;
    SchBtn: TRnQButton;
    HistPosTree: TVirtualDrawTree;
    procedure SchBtnClick(Sender: TObject);
    procedure HistPosTreeFreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure FormCreate(Sender: TObject);
    procedure HistPosTreeDrawNode(Sender: TBaseVirtualTree;
      const PaintInfo: TVTPaintInfo);
    procedure HistPosTreeGetNodeWidth(Sender: TBaseVirtualTree;
      HintCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
      var NodeWidth: Integer);
    procedure HistPosTreeDblClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure HistPosTreeKeyPress(Sender: TObject; var Key: Char);
//    procedure SearchEditKeyDown(Sender: TObject; var Key: Word;
//      Shift: TShiftState);
  private
    { Private declarations }
    stop2search : Boolean;
    thisProto : TRnQProtocol;
  public
    { Public declarations }
  end;

var
  AllHistSrchForm: TAllHistSrchForm;

implementation
{$R *.dfm}
  uses
    StrUtils, RnQFileUtil, RQUtil, RDGlobal, RnQLangs, RQThemes,
    RnQSysUtils, RnQPics,
    history,
 {$IFNDEF DB_ENABLED}
//    RegExpr,
    RegularExpressions,
 {$ENDIF ~DB_ENABLED}
    events, globalLib,
    chatDlg,
    themesLib;

type
  PHSItem = ^THSItem;
  THSItem = record
     NodeType : (NT_UID, NT_POSITION);
     sUID : TUID;
     pos  : Integer;
     time : TDateTime;  
//     Pl : Tplugin;
  end;


procedure TAllHistSrchForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if stop2search = false then
   begin
    stop2search := True;
    HistPosTree.Clear;
   end;
  AllHistSrchForm := NIL;
  Action := caFree;
end;

procedure TAllHistSrchForm.FormCreate(Sender: TObject);
begin
  HistPosTree.NodeDataSize := SizeOf(THSItem);
// childWindows.Add(self);
end;

procedure TAllHistSrchForm.FormShow(Sender: TObject);
begin
  applyTaskButton(self);
  theme.pic2ico(RQteFormIcon, PIC_SEARCH, icon);
  stop2search := True;
//  thisProto := activeProto;
  thisProto := Account.AccProto;
//  DoubleBuffered := True;
end;

procedure TAllHistSrchForm.HistPosTreeDblClick(Sender: TObject);
var
  n : PVirtualNode;
  cnt : TRnQContact;
begin
  n := HistPosTree.FocusedNode;
  if n <> NIL then
   with PHSItem(HistPosTree.GetNodeData(n))^ do
   if NodeType = NT_POSITION then
     begin
      cnt := thisProto.getContact(sUID);
      chatFrm.openchat(cnt, True);
      chatFrm.moveToTime(cnt, time);
     end
    else
     Inherited;

end;

procedure TAllHistSrchForm.HistPosTreeDrawNode(Sender: TBaseVirtualTree;
  const PaintInfo: TVTPaintInfo);
var
  hsItem : PHSItem;
  OldMode : Integer;
//  s : string;
begin
     if vsSelected in PaintInfo.Node.States then
       paintinfo.canvas.Font.Color := clHighlightText
      else
       paintinfo.canvas.Font.Color := clWindowText;
//     x := PaintInfo.ContentRect.Left;
//     y := 0;
     hsItem := PHSItem(sender.getnodedata(paintinfo.node));
//     inc(x, theme.drawPic(paintinfo.canvas.Handle, x,y+1, IcItem.IconName).cx+2);

     oldMode := SetBKMode(paintinfo.canvas.Handle, TRANSPARENT);
      case hsItem.NodeType of
       NT_UID:
         begin
//          if contactsDB.exists(Account.AccProto, hsItem.sUID) then
          if thisProto.ContactExists(hsItem.sUID) then
           with thisProto.getContact(hsItem.sUID) do
            if displayed <> UID then
              paintinfo.canvas.textout(PaintInfo.ContentRect.Left, 2,
                displayed + ' "' + hsItem.sUID +'" (' + IntToStr(paintinfo.Node.ChildCount) + ')')
             else
              paintinfo.canvas.textout(PaintInfo.ContentRect.Left, 2,
                '"' + hsItem.sUID +'" (' + IntToStr(paintinfo.Node.ChildCount) + ')');
         end;
       NT_POSITION:
         paintinfo.canvas.textout(PaintInfo.ContentRect.Left, 2, DateTimeToStr(hsItem.time));
      end;
     SetBKMode(paintinfo.canvas.Handle, oldMode);
end;

procedure TAllHistSrchForm.HistPosTreeFreeNode(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
begin
//  with THSItem(Sender.getnodedata(Node)^) do
  with PHSItem(Sender.getnodedata(Node))^ do
   begin
     sUID := '';
   end;
end;

procedure TAllHistSrchForm.HistPosTreeGetNodeWidth(Sender: TBaseVirtualTree;
  HintCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
  var NodeWidth: Integer);
begin
  NodeWidth := 200;
end;

procedure TAllHistSrchForm.HistPosTreeKeyPress(Sender: TObject; var Key: Char);
var
  n : PVirtualNode;
  cnt : TRnQContact;
begin
  if key = #13 then
   begin
    n := HistPosTree.FocusedNode;
    if n <> NIL then
     with PHSItem(HistPosTree.GetNodeData(n))^ do
     if NodeType = NT_POSITION then
       begin
        cnt := thisProto.getContact(sUID);
        chatFrm.openchat(cnt, True);
        chatFrm.moveToTime(cnt, time);
        key := #0;
       end
   end;
end;

procedure TAllHistSrchForm.SchBtnClick(Sender: TObject);
 {$IFNDEF DB_ENABLED}
  procedure processHistory(hist : Thistory; uid : TUID);
   var
    ParentNode : PVirtualNode;
      procedure addPosition(pos : Integer; time : TDateTime);
      var
        N : PVirtualNode;
        hsItem : PHSItem;
      begin
       if ParentNode = NIL then
        begin
         ParentNode := HistPosTree.AddChild(NIL);
         hsItem := HistPosTree.GetNodeData(ParentNode);
         hsItem.NodeType := NT_UID;
         hsItem.sUID := uid;
        end;
       n := HistPosTree.AddChild(ParentNode);
       hsItem := HistPosTree.GetNodeData(n);
       hsItem.NodeType := NT_POSITION;
       hsItem.sUID := uid;
       hsItem.pos  := pos;
       hsItem.time := time;
//       n.CheckType := ctCheckBox;
      end;
  var
//    re:Tregexpr;
    re: TRegEx;
    l_RE_opt: TRegExOptions;
    i: Integer;
  //  w2s,
    s: string;
    found: boolean;
  begin
    ParentNode := NIL;
    if reChk.Checked then
      begin
{      re:=TRegExpr.Create;
      re.ModifierI:=not caseChk.checked;
      re.Expression := SearchEdit.Text;
        try
          re.Compile
        except
          FreeAndNIL(re);
          exit;
        end;}
        l_RE_opt := [roCompiled];
        if not caseChk.Checked then
          Include(l_RE_opt, roIgnoreCase)
         else
          Exclude(l_RE_opt, roIgnoreCase)
        ;
        re:= TRegEx.Create(SearchEdit.Text, l_RE_opt);
      end;
    i:=0;
    while (i >= 0) and (i < hist.Count) do
      begin
        if stop2search then
         Break;
//        s := Thevent(hist[i]).decrittedInfo;
        s := Thevent(hist[i]).getBodyText;
        if reChk.Checked then
//          found:=re.exec(s)
          found := re.IsMatch(s)
         else
          begin
          if not caseChk.checked then
            found := AnsiContainsText(s, SearchEdit.Text)
           else
    //        s:=uppercase(s);
            found:=pos(SearchEdit.Text,s) > 0;
    //      found:=AnsiPos(w2s,s) > 0;
          end;
        if found then
          begin
    //      historyBox.rsb_position:=i-historyBox.offset;
           addPosition(i, Thevent(hist[i]).when);
          end;
        inc(i);
        Application.ProcessMessages;
        if stop2search then
         Break;
      end;
  // sbar.simpletext:=getTranslation('Nothing found, sorry');
  end;
 {$ENDIF ~DB_ENABLED}
var
  sr:TsearchRec;
  hist : Thistory;
  cnt  : TRnQContact;
  fn : string;
  fnUID : TUID;
begin
  if stop2search then
   begin
    stop2search := False;
    SchBtn.Caption := getTranslation('&Stop');
    HistPosTree.Clear;
 {$IFDEF DB_ENABLED}
 {$ELSE ~DB_ENABLED}
       if FindFirst(Account.ProtoPath+historyPath  +'*.*', faAnyFile, sr) = 0 then
       repeat
        if (sr.name<>'.') and (sr.name<>'..') then
         if (sr.Attr and faDirectory = 0) then
        begin
         if stop2search then
          Break;
         fn := ExtractFileName(sr.Name);
         fnUID := fn;
         fn := '';
         if RoasterChk.Checked then
          if not Account.AccProto.readList(LT_ROSTER).exists(Account.AccProto, fnUID) then
            Continue;
         Hist := Thistory.Create;
  //       fn := userPath+historyPath + spamsFilename;
         try
//         if Hist.fromString(loadFile(userPath + historyPath+sr.name), True) then
           cnt := Account.AccProto.getContact(fnUID);
           if Hist.load(cnt, True) then
             processHistory(hist, fnUID);
          except
         end;
         fnUID := '';
//         hist.Clear;
         hist.Free;
        end;
       until findNext(sr) <> 0;
       findClose(sr);
 {$ENDIF ~DB_ENABLED}
    SchBtn.Caption := getTranslation('&Search');
    stop2search := True;
   end
  else
  stop2search := True;
end;

{
procedure TAllHistSrchForm.SearchEditKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if key=VK_RETURN then
    SchBtnClick(NIL);
end;
}

end.
