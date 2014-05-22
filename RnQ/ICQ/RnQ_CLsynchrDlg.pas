unit RnQ_CLsynchrDlg;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  ExtCtrls, VirtualTrees, RnQButtons, contacts;

type
  TCLsyncDlg = class(TForm)
    SCList: TVirtualDrawTree;
    Panel1: TPanel;
    ApplyBtn: TRnQSpeedButton;
    CancelBtn: TRnQSpeedButton;
    procedure CancelBtnClick(Sender: TObject);
    procedure SCListMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure SCListCompareNodes(Sender: TBaseVirtualTree; Node1,
      Node2: PVirtualNode; Column: TColumnIndex; var Result: Integer);
    procedure SCListDrawNode(Sender: TBaseVirtualTree;
      const PaintInfo: TVTPaintInfo);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    SyncCL : TcontactList;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  CLsyncDlg: TCLsyncDlg;

implementation

uses RQ_ICQ,
  RQUtil, RQGlobal, RQThemes,
  globalLib, groupsLib;//, chatDlg, LangLib, utilLib, icqv9,

type
  PTreeRec = ^TTreeRec;
  TTreeRec = record
    ssiID,
    rtype,
    copyTo,
    present : byte;
    ServDispl,
    UID,
    displ   : String;
  end;

const
 CT_SERVER = 0;
 CT_LOCAL  = 1;
 CT_NONE   = 2;
 rt_grp    = 1;
 rt_cnt    = 2; 
//var


{$R *.dfm}

procedure TCLsyncDlg.CancelBtnClick(Sender: TObject);
begin
  Close;
end;

procedure TCLsyncDlg.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  SCList.Clear;
  SyncCL.Clear;
//  impCL.Clear;
//  impCL.Free;
  Action := caFree;
  CLsyncDlg := NIL;
end;

procedure TCLsyncDlg.FormShow(Sender: TObject);
var
  tr : PTreeRec;
  gn : PVirtualNode;
  g, gid: Integer;
  gr : Tgroup;
begin
  theme.pic2ico(PIC_DOWNLOAD, icon);
  applyTaskButton(self);
//  RQ_icq.RequestContactList(false);
//  while not ListLoaded do
//   Application.ProcessMessages;
  SCList.NodeDataSize := SizeOf(TTreeRec);
//  SCList.NodeDataSize := SizeOf(Tcontact);
  SCList.Clear;
  SyncCL := TcontactList.Create;
  gn := NIL;
//  SyncCL.add(impCL);
  SyncCL.add(icq.readRoaster);
  for g := 0 to groups.count - 1 do
    begin
      gn := SCList.AddChild(NIL);
      tr := SCList.GetNodeData(gn);
       tr^.present := 0;
       gr := groups.a[g];
       with gr do
        begin
         tr^.UID := '';
         tr.ssiID := ssiID;
         tr^.displ := gr.name;
         tr^.copyTo := CT_SERVER;
         tr.rtype := rt_grp;
         gid := id;
        end;
//      SyncCL.
      SyncCL.resetEnumeration;
      while SyncCL.hasMore do
       with SyncCL.getNext do
       if group = gid then
       begin
         tr := SCList.GetNodeData(SCList.AddChild(gn));
         tr.rtype := rt_cnt;
         tr^.present := 0;
         tr^.UID := uid;
         tr^.displ := displayed;
         tr^.copyTo := CT_SERVER;
       end;
    end;

  SCList.SortTree(1, sdAscending);
end;

procedure TCLsyncDlg.SCListDrawNode(Sender: TBaseVirtualTree;
  const PaintInfo: TVTPaintInfo);
var
  cnv : TCanvas;
//  c   : Tcontact;
  x   : Integer;
  s   : String;
begin
cnv:=paintinfo.canvas;
//PTreeRec(Pointer(PaintInfo.Node^.Data)).;
//c:=PTreeRec(sender.getnodedata(paintinfo.node)^);
 if vsSelected in PaintInfo.Node^.States then
  cnv.Font.Color :=clHighlightText
 else
  cnv.Font.Color := clWindowText;
 if vsSelected in PaintInfo.Node^.States then
  cnv.Font.Color :=clHighlightText
 else
  cnv.Font.Color := clWindowText;
  case PaintInfo.Column of
{   0: begin
        case PTreeRec(sender.getnodedata(paintinfo.node)^)^.present of
         0 : theme.drawPic(cnv, PaintInfo.ContentRect.Left, 0, PIC_DOWN);
         1 : theme.drawPic(cnv, PaintInfo.ContentRect.Left, 0, PIC_UP);
         2 : theme.drawPic(cnv, PaintInfo.ContentRect.Left, 0, PIC_CURRENT);
        end;
      end;
}
   0:  begin
         s := PTreeRec(sender.getnodedata(paintinfo.node))^.displ
              + ' '+ PTreeRec(sender.getnodedata(paintinfo.node))^.UID;
         cnv.textout(PaintInfo.ContentRect.Left,2, s);
       end;
   1:  begin
         cnv.textout(PaintInfo.ContentRect.Left,2,
           PTreeRec(sender.getnodedata(paintinfo.node))^.ServDispl);
       end;
   3:  begin
         cnv.textout(PaintInfo.ContentRect.Left,2,
           PTreeRec(sender.getnodedata(paintinfo.node))^.displ);
       end;
//   cnv.textout(PaintInfo.ContentRect.Left ,2, c.uinAsStr)
   2: case PTreeRec(sender.getnodedata(paintinfo.node))^.copyTo of
       CT_SERVER : theme.drawPic(cnv, PaintInfo.ContentRect.Left, 0, PIC_LEFT);
       CT_LOCAL : theme.drawPic(cnv, PaintInfo.ContentRect.Left, 0, PIC_RIGHT);
       CT_NONE : theme.drawPic(cnv, PaintInfo.ContentRect.Left, 0, PIC_EMPTY);
      end;
  end;

end;

procedure TCLsyncDlg.SCListCompareNodes(Sender: TBaseVirtualTree; Node1,
  Node2: PVirtualNode; Column: TColumnIndex; var Result: Integer);
begin
  if PTreeRec(sender.getnodedata(Node1))^.displ >
    PTreeRec(sender.getnodedata(Node2))^.displ
  then
    result := 1
  else
   if PTreeRec(sender.getnodedata(Node1))^.displ <
    PTreeRec(sender.getnodedata(Node2))^.displ
   then
    result := -1
   else
    result := 0;
end;

procedure TCLsyncDlg.SCListMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  node : PVirtualNode;
begin
  if Button = mbLeft then
  begin
   node := SCList.GetNodeAt(X, Y);
   if node <> NIL then
//    if Y <
    if SCList.Header.Columns.ColumnFromPosition(Point(X, 0)) = 2 then
     if PTreeRec(SCList.getnodedata(node))^.copyTo = CT_LOCAL then
       PTreeRec(SCList.getnodedata(node))^.copyTo := CT_SERVER
     else
      if PTreeRec(SCList.getnodedata(node))^.copyTo = CT_SERVER then
       PTreeRec(SCList.getnodedata(node))^.copyTo := CT_LOCAL;
  end;
end;

end.

