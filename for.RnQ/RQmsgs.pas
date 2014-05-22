{
This file is part of R&Q.
Under same license
}
unit RQmsgs;
{$I ForRnQConfig.inc}

 {$IFDEF COMPILER_14_UP}
  {$WEAKLINKRTTI ON}
  {$RTTI EXPLICIT METHODS([]) FIELDS([]) PROPERTIES([])}
 {$ENDIF COMPILER_14_UP}

interface

uses
  Windows, Messages, SysUtils,
  Classes, Graphics, Controls, Forms,
  RDGlobal, RnQButtons, RQMenuItem,
  VirtualTrees, ExtCtrls, StdCtrls;

type
  TmsgsFrm = class(TForm)
    procedure FormShow(Sender: TObject);
    procedure msgListCompareNodes(Sender: TBaseVirtualTree; Node1,
      Node2: PVirtualNode; Column: TColumnIndex; var Result: Integer);
    procedure msgListDrawNode(Sender: TBaseVirtualTree;
      const PaintInfo: TVTPaintInfo);
    procedure msgListMeasureItem(Sender: TBaseVirtualTree;
      TargetCanvas: TCanvas; Node: PVirtualNode; var NodeHeight: Integer);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure OkBtnClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure msgListFreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);
//  public
//    function kind2iconIndex(kind:TMsgDlgType):integer;
   protected
    OkBtn: TRnQButton;
    FTimer : TTimer;
    menu : TRnQPopupMenu;
    OpenChatM : TRQMenuItem;
    procedure onTimer(Sender: TObject);
    procedure menuPopup(Sender: TObject);
    procedure openChat(Sender: TObject);
    procedure CopyText(Sender: TObject);
   public
    msgList: TVirtualDrawTree;
    FSeconds : Integer;
    procedure AddMsg(msg:string; kind:TMsgDlgType; vTime : TDateTime; const uid : AnsiString = '');
  end;

var
  msgsFrm: TmsgsFrm;

implementation

{$R *.dfm}

uses
  Clipbrd, math, Types,//uiTypes,
  RDUtils, RQUtil, RnQlangs, RQThemes, RnQMenu, RnQDialogs,
  RnQSysUtils, RnQGlobal
;

const
  GAP_X=3;
  GAP_Y=3;

procedure TmsgsFrm.onTimer(Sender: TObject);
 begin
  Dec(FSeconds);
    OkBtn.Caption := SMsgDlgOK + ' (' + IntToStr(FSeconds) + ')';
  if FSeconds <= 0 then
  begin
    FTimer.Enabled := False;
    OkBtnClick(nil);
//    ModalResult := OkBtn.ModalResult;
  end
 end;

procedure TmsgsFrm.msgListCompareNodes(Sender: TBaseVirtualTree; Node1,
  Node2: PVirtualNode; Column: TColumnIndex; var Result: Integer);
begin
  if Pmsg(sender.getnodedata(Node1)).time >
      Pmsg(sender.getnodedata(Node2)).time then
    result := -1
   else
    if Pmsg(sender.getnodedata(Node1)).time =
        Pmsg(sender.getnodedata(Node2)).time then
      result := 0
    else
      result := 1;
end;

procedure TmsgsFrm.msgListDrawNode(Sender: TBaseVirtualTree;
  const PaintInfo: TVTPaintInfo);
var
  s, ic:string;
  isFirst, selected:boolean;
  r : TRect;
  clr : TColor;
begin
  selected:= vsSelected in PaintInfo.Node^.States;
  isFirst := PaintInfo.Node = msgList.GetFirst;
  r := PaintInfo.CellRect;
//  PaintInfo.Canvas.fillrect(r);
  inc(r.left, GAP_X);
  dec(r.Right, GAP_X);
  inc(r.Top, GAP_Y shl 1);

  if (isFirst) then
    clr:=clWindowText
   else
    if not selected then
      clr:=clGrayText
     else
      clr:=clHighlightText;
  PaintInfo.Canvas.Font.Color := clr;
    // additional spaces for icon
  with Pmsg(sender.getnodedata(PaintInfo.Node))^ do
  begin
    with theme.drawPic(PaintInfo.Canvas.Handle, r.left, r.top-GAP_Y,
           IconNames[ kind ], isFirst) do
//    with theme.getPicSize(RQteDefault, IconNames[kind], 16) do
     begin
      s:=datetimeToStr( time )+CRLF;
      if cy > 32 then
        inc(r.Left, 2 + cx)
       else
        begin
          ic := StringOfChar(' ',2+ cx div PaintInfo.Canvas.TextWidth(' '));
          s := ic + s;
          if cy > 16 then
            s:= s+ ic;
        end;
      s := s+ text;
      SetBkMode(PaintInfo.Canvas.handle, TRANSPARENT);

      DrawText(PaintInfo.Canvas.Handle, pchar(s), -1, r,
               DT_WORDBREAK+DT_EXTERNALLEADING+DT_NOPREFIX);
     end;
  end;
end;

procedure TmsgsFrm.msgListFreeNode(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
var
  m : Pmsg;
begin
  m := Pmsg(sender.getnodedata(node));
  if m <> NIL then
   begin
     SetLength(m.text, 0);
     SetLength(m.UID, 0);
   end;
end;

procedure TmsgsFrm.msgListMeasureItem(Sender: TBaseVirtualTree;
  TargetCanvas: TCanvas; Node: PVirtualNode; var NodeHeight: Integer);
var
  r:Trect;
  s:string;
  m : Pmsg;
//  l : Integer;
begin
  r:=rect(0, 0, Sender.ClientWidth, 0);
  m := Pmsg(sender.getnodedata(node));
  if m = NIL then
   begin
    NodeHeight := 1;
    exit;
   end;
//  if Tmsg(Pmsg(sender.getnodedata(node))^).text = '' then
//   Exit;
  s := m.text;
//  s := Pmsg(sender.getnodedata(node))^.text;
//  l := Length(msgs)-index-1;
//  s:=msgs[l].text;
  if s = '' then
    begin
     NodeHeight := 1;
     exit;
    end;
  s:='000'+CRLF+s;
  inc(r.Left, GAP_X);
  dec(r.right, GAP_X);
  inc(r.Top, GAP_Y shl 1);
  with theme.getPicSize(RQteDefault, IconNames[m.kind]) do
   begin
    NodeHeight := cy;
    inc(r.Left, cx);
    if cy > 16 then
     dec(r.right, cx);
   end;
//  r.Bottom := 1000;
  DrawText(TargetCanvas.Handle, pchar(s), -1, r,
   DT_WORDBREAK or DT_EXTERNALLEADING or DT_NOPREFIX or DT_CALCRECT);
  NodeHeight:= max(r.Bottom + GAP_Y, NodeHeight);
end;

procedure TmsgsFrm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  try
    FTimer.Enabled := false;
    msgList.Clear;
//  setlength(msgs, 0);
   except
  
  end;
end;

procedure TmsgsFrm.FormCreate(Sender: TObject);
const
  BottomHeight = 40;
begin
  msgList := TVirtualDrawTree.Create(self);
  Self.InsertComponent(msgList);
  with msgList do
  begin
    Parent := self;
    Left := 0;
    Top := 0;
    Width := Self.ClientWidth - GAP_X - GAP_X;
    Height := Self.ClientHeight - BottomHeight - GAP_Y;
    Align := alTop;
    Anchors := [akLeft, akTop, akRight, akBottom];
    Colors.UnfocusedSelectionColor := clBtnShadow;
    DefaultNodeHeight := 1;
{    Header.AutoSizeIndex = 0;
    Header.Font.Charset = DEFAULT_CHARSET;
    Header.Font.Color = clWindowText;
    Header.Font.Height = -11;
    Header.Font.Name = 'Tahoma';
    Header.Font.Style = [];
    Header.MainColumn = -1;
}
    Header.Options := [hoColumnResize, hoDrag];
    TabOrder := 0;
    TreeOptions.AutoOptions := [toAutoDropExpand, toAutoScrollOnExpand, toAutoSort, toAutoTristateTracking, toAutoDeleteMovedNodes];
    TreeOptions.MiscOptions := [toAcceptOLEDrop, toFullRepaintOnResize, toGridExtensions, toInitOnSave, toReportMode, toToggleOnDblClick, toWheelPanning, toVariableNodeHeight];
    TreeOptions.PaintOptions := [toShowButtons, toShowDropmark, toShowHorzGridLines, toShowRoot, toThemeAware, toUseBlendedImages, toUseBlendedSelection];
    TreeOptions.SelectionOptions := TreeOptions.SelectionOptions + [toFullRowSelect, toRightClickSelect];
    OnCompareNodes := msgListCompareNodes;
    OnDrawNode := msgListDrawNode;
    OnMeasureItem := msgListMeasureItem;
//    Columns := <>
    NodeDataSize := SizeOf(Tmsg);
  end;
  OkBtn := TRnQButton.Create(Self);
  Self.InsertComponent(OkBtn);
  with OkBtn do
  begin
    Parent := self;
    Left := 130;
    Top := Self.ClientHeight - BottomHeight + ((BottomHeight-25) div 2);
    Width := 89;
    Height := 25;
    Anchors := [akBottom];
    Default := True;
    ModalResult := 1;
    TabOrder := 1;
    OnClick := OkBtnClick;
    ImageName := 'ok';
  end;

  msgList.Clear;
{$IFDEF DELPHI_9_UP}
  GlassFrame.Enabled := True;
//  GlassFrame.Bottom := 35;
  Self.GlassFrame.Bottom := Self.ClientHeight-msgList.Height-1;
{$ENDIF DELPHI_9_UP}

  menu := TRnQPopupMenu.Create(Self);
  AddToMenu(menu.Items, 'Copy',
       'copy', True, copyText);
//  OpenChatM := AddToMenu(menu.Items, 'Open chat',
//       PIC_MSG, False, openChat);
   OpenChatM := AddToMenu(menu.Items, 'Copy UIN',
          'copy', True, openChat);
  menu.OnPopup := menuPopup;
  msgList.PopupMenu := menu;

  FSeconds := 0;
  FTimer := TTimer.Create(self);
  FTimer.OnTimer := onTimer;
  applyTaskButton(self);
end;

procedure TmsgsFrm.OkBtnClick(Sender: TObject);
begin
  ModalResult := mrOk;
  close;
end;

procedure TmsgsFrm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_CANCEL) or
    (Key =VK_ESCAPE) or
    (Key =VK_RETURN) or
    (Key =VK_ACCEPT) then
   OkBtnClick(nil);
end;

procedure TmsgsFrm.FormShow(Sender: TObject);
begin
  caption:=getTranslation('R&Q for %s',[rnquser]);
  OkBtn.Caption := SMsgDlgOK + ' (' + IntToStr(FSeconds) + ')';
  FTimer.Enabled := True;
end;

procedure TmsgsFrm.menuPopup(Sender: TObject);
var
  b : Boolean;
begin
  b := False;
{  if Assigned(MainProto) then
   begin
    with msgList do
    if focusedNode<>NIL then
      b := Pmsg(getnodedata(focusednode)).UID > '';
   end;
  if Assigned(OpenChatM) then
    OpenChatM.Visible := b;
}
end;

procedure TmsgsFrm.openChat(Sender: TObject);
var
//  cnt : TRnQContact;
  s : String;
begin
{  cnt := NIL;
  if Assigned(MainProto) then
   begin
    with msgList do
    if focusedNode<>NIL then
      cnt := mainProto.getContact(Pmsg(getnodedata(focusednode)).UID);
    chatFrm.openOn(cnt);
   end;}
  with msgList do
  if focusedNode<>NIL then
   begin
    s := Pmsg(getnodedata(focusednode)).UID;
    convertAllNewlinesToCRLF(s);
    clipboard.asText := s;
   end;
end;

procedure TmsgsFrm.AddMsg(msg: string; kind: TMsgDlgType; vTime: TDateTime;
  const uid: AnsiString);
var
  vmsg : Pmsg;
  n : PVirtualNode;
  SetFirst : Boolean;
begin
      if msgList.FocusedNode = msgList.GetFirst then
        setFirst:= True
       else
        setFirst:= False;
      msgList.BeginUpdate;
      n := msgList.AddChild(nil);
      vmsg := msgList.GetNodeData(n);
      vmsg.text := msg;
      vmsg.kind := kind;
      vmsg.time := vTime;
      vmsg.UID  := uid;
      n.States := n.States - [vsHeightMeasured];
      msgList.MeasureItemHeight(msgList.Canvas, n);
      msgList.EndUpdate;
      FSeconds := max(MsgShowTime[kind], FSeconds);
//      vmsg := nil;
      if SetFirst then
       begin
         msgList.ClearSelection;
         msgList.FocusedNode := n;
         msgList.Selected[n] := True;
       end;
      theme.pic2ico(RQteFormIcon, iconNames[kind], self.Icon);
//      theme.GetIco2(iconNames[kind], self.Icon);
      if not self.Visible then
        showForm(self)
       else
        msgList.InvalidateNode(n);
end;

procedure TmsgsFrm.CopyText(Sender: TObject);
var
  s : String;
begin
  with msgList do
  if focusedNode<>NIL then
   begin
    s := Pmsg(getnodedata(focusednode)).text;
    convertAllNewlinesToCRLF(s);
    clipboard.asText := s;
   end;
end;

end.
