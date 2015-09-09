{
This file is part of R&Q.
Under same license
}
unit visibilityDlg;
{$I RnQConfig.inc}
{$I NoRTTI.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  RnQProtocol,
  StdCtrls, Menus, RnQButtons, VirtualTrees;

type
  TvisibilityFrm = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    PMenu1: TPopupMenu;
    PMenu2: TPopupMenu;
    PMenu3: TPopupMenu;
    selectall1: TMenuItem;
    Selectall2: TMenuItem;
    Selectall3: TMenuItem;
    InvisBox: TVirtualDrawTree;
    NormalBox: TVirtualDrawTree;
    VisibleBox: TVirtualDrawTree;
    move2inv: TRnQButton;
    move2normal: TRnQButton;
    move2vis: TRnQButton;
    procedure InvisBoxDrawNode(Sender: TBaseVirtualTree;
      const PaintInfo: TVTPaintInfo);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure normalBoxClick(Sender: TObject);
    procedure invisibleBoxClick(Sender: TObject);
    procedure visibleBoxClick(Sender: TObject);
    procedure move2invClick(Sender: TObject);
    procedure move2normalClick(Sender: TObject);
    procedure move2visClick(Sender: TObject);
    procedure selectall1Click(Sender: TObject);
    procedure Selectall2Click(Sender: TObject);
    procedure Selectall3Click(Sender: TObject);
    procedure NormalBoxFreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);
  private
    thisProto : TRnQProtocol;
    normal:TRnQCList;
    procedure setUpBoxes;
    procedure inv2normal;
    procedure inv2vis;
    procedure normal2vis;
    procedure normal2inv;
    procedure vis2normal;
    procedure vis2inv;
    procedure selectAll(lb:TBaseVirtualTree);
    procedure unselect(Sender: TBaseVirtualTree; Node: PVirtualNode; Data: Pointer; var Abort: Boolean);
    procedure select(Sender: TBaseVirtualTree; Node: PVirtualNode; Data: Pointer; var Abort: Boolean);
  public
    procedure DestroyHandle; Override;
  end;

var
  visibilityFrm: TvisibilityFrm;

implementation

{$R *.DFM}

uses
  RQUtil, RDGlobal, RQThemes,
  RnQSysUtils, RnQPics,
  globalLib, mainDlg, utilLib, themesLib,
  ICQConsts, ICQv9,
  roasterLib;

type
  PVisRec = ^TVisRec;
  TVisRec = record
    s   : string;  
    cnt : TRnQcontact;
  end;


function what2display(c: TRnQContact): string;
begin
  result:=c.displayed+'  '+c.uid
end;

procedure fillUp(lb: TBaseVirtualTree; cl: TRnQCList);
var
  i: integer;
  p: PVisRec;
begin
lb.Clear;
for i:=0 to TList(cl).count-1 do
  begin
   lb.BeginUpdate;
   p := lb.GetNodeData(lb.AddChild(NIL));
   p.cnt:=cl.getAt(i);
   p.s := what2display(p.cnt);
   lb.EndUpdate;
  end;
end; // fillUp

procedure TvisibilityFrm.setUpBoxes;
begin
  fillUp(visibleBox, thisProto.readList(LT_VISIBLE));
  fillUp(normalBox,  normal);
  fillUp(invisBox,   thisProto.readList(LT_INVISIBLE));
end; // setUpBoxes

procedure TvisibilityFrm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  normal.free;
  saveListsDelayed:=TRUE;
  destroyHandle;
  Action := caFree;
  visibilityFrm := nil;
end;

procedure TvisibilityFrm.FormCreate(Sender: TObject);
begin
  InvisBox.NodeDataSize := SizeOf(TVisRec);
  NormalBox.NodeDataSize := SizeOf(TVisRec);
  VisibleBox.NodeDataSize := SizeOf(TVisRec);
end;

function clFromBox(lb:TBaseVirtualTree):TRnQCList;
var
  n : PVirtualNode;
begin
  result:=TRnQCList.create;
  n := lb.GetFirst;
  while n <> NIL do
  begin
   if lb.selected[n] then
    result.add(TVisRec(PVisRec(lb.getnodedata(n))^).cnt);
   n := lb.GetNext(n); 
  end;
end; // clFromBox

procedure TvisibilityFrm.InvisBoxDrawNode(Sender: TBaseVirtualTree;
  const PaintInfo: TVTPaintInfo);
var
  s : String;
  x : Integer;
begin
  s := TVisRec(PVisRec(Sender.getnodedata(PaintInfo.Node))^).s;
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
//  inc(x,
//       theme.drawPic(PaintInfo.Canvas, PaintInfo.ContentRect.Left +3, 0,
//         TlogItem(PLogItem(LogList.getnodedata(PaintInfo.Node)^)^).Img).cx+6;
    SetBkMode(PaintInfo.Canvas.Handle, TRANSPARENT);
    PaintInfo.Canvas.textout(PaintInfo.ContentRect.Left +x,2, s);
end;

// inv2vis

procedure TvisibilityFrm.inv2normal;
var
  cl:TRnQCList;
begin
  cl:=clFromBox(invisBox);
  normal.add(cl);
 {$IFDEF UseNotSSI}
  if (thisProto.ProtoElem is TicqSession) and  not TicqSession(thisProto.ProtoElem).useSSI then
//    thisProto.readInvisible.remove(cl)
    thisProto.readList(LT_INVISIBLE).remove(cl)
   else
 {$ENDIF UseNotSSI}
//    thisICQ.removeFromInvisible(cl)
    thisProto.RemFromList(LT_INVISIBLE, cl);
   ;
  cl.free;
end; // inv2normal

procedure TvisibilityFrm.inv2vis;
var
  cl:TRnQCList;
begin
  cl:=clFromBox(invisBox);
 {$IFDEF UseNotSSI}
  if (thisProto.ProtoElem is TicqSession) and  not TicqSession(thisProto.ProtoElem).useSSI then
    begin
//      thisICQ.readVisible.add(cl);
      thisProto.readList(LT_VISIBLE).add(cl);
//      thisICQ.readInvisible.remove(cl);
      thisProto.readList(LT_INVISIBLE).remove(cl);
    end
   else
 {$ENDIF UseNotSSI}
    begin
      thisProto.AddToList(LT_VISIBLE, cl);
      thisProto.RemFromList(LT_INVISIBLE, cl);
    end;
  cl.free;
end;

procedure TvisibilityFrm.normal2vis;
var
  cl:TRnQCList;
begin
  cl:=clFromBox(normalBox);
 {$IFDEF UseNotSSI}
  if (thisProto.ProtoElem is TicqSession) and  not TicqSession(thisProto.ProtoElem).useSSI then
//    thisICQ.readVisible.add(cl)
    thisProto.readList(LT_VISIBLE).add(cl)
   else
 {$ENDIF UseNotSSI}
    thisProto.AddToList(LT_VISIBLE, cl);
  normal.remove(cl);
  cl.free;
end; // normal2vis

procedure TvisibilityFrm.normal2inv;
var
  cl:TRnQCList;
begin
  cl:=clFromBox(normalBox);
 {$IFDEF UseNotSSI}
  if (thisProto.ProtoElem is TicqSession) and  not TicqSession(thisProto.ProtoElem).useSSI then
//    thisICQ.readInvisible.add(cl)
    thisProto.readList(LT_INVISIBLE).add(cl)
   else
 {$ENDIF UseNotSSI}
    thisProto.AddToList(LT_INVISIBLE, cl);
  normal.remove(cl);
  cl.free;
end; // normal2inv

procedure TvisibilityFrm.vis2normal;
var
  cl:TRnQCList;
begin
  cl:=clFromBox(visibleBox);
 {$IFDEF UseNotSSI}
  if (thisProto.ProtoElem is TicqSession) and  not TicqSession(thisProto.ProtoElem).useSSI then
//    thisICQ.readVisible.remove(cl)
    thisProto.readList(LT_VISIBLE).remove(cl)
   else
 {$ENDIF UseNotSSI}
    thisProto.RemFromList(LT_VISIBLE, cl);
//  vis.remove(cl);
  normal.add(cl);
  cl.free;
end; // vis2normal

procedure TvisibilityFrm.vis2inv;
var
  cl:TRnQCList;
begin
  cl:=clFromBox(visibleBox);
 {$IFDEF UseNotSSI}
  if (thisProto.ProtoElem is TicqSession) and  not TicqSession(thisProto.ProtoElem).useSSI then
    begin
//      thisICQ.readVisible.remove(cl);
      thisProto.readList(LT_VISIBLE).remove(cl);
//      thisICQ.readInvisible.add(cl);
      thisProto.readList(LT_INVISIBLE).add(cl);
    end
   else
 {$ENDIF UseNotSSI}
    begin
      thisProto.RemFromList(LT_VISIBLE, cl);
      thisProto.AddToList(LT_INVISIBLE, cl);
    end;
  cl.free;
end; // vis2inv

procedure TvisibilityFrm.FormShow(Sender: TObject);
begin
  theme.pic2ico(RQteFormIcon, PIC_VISIBILITY, icon);
  applyTaskButton(self);
//  thisProto := ActiveProto;
  thisProto := Account.AccProto;
{  move2inv.Enabled := not useSSI;
  move2normal.Enabled := not useSSI;
  move2vis.Enabled := not useSSI;}
  normal:=thisProto.readList(LT_ROSTER).clone.remove(thisProto.readList(LT_INVISIBLE)).remove(thisProto.readList(LT_VISIBLE));
  setUpBoxes;
end; // formshow


procedure TvisibilityFrm.unselect(Sender: TBaseVirtualTree; Node: PVirtualNode; Data: Pointer; var Abort: Boolean);
begin
  sender.Selected[Node] := False;
end;

procedure TvisibilityFrm.select(Sender: TBaseVirtualTree; Node: PVirtualNode; Data: Pointer; var Abort: Boolean);
begin
  sender.Selected[Node] := True;
end;

procedure TvisibilityFrm.normalBoxClick(Sender: TObject);
begin
 VisibleBox.IterateSubtree(NIL, unselect, NIL);
 invisbox.IterateSubtree(NIL, unselect, NIL);
end;

procedure TvisibilityFrm.NormalBoxFreeNode(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
begin
  TVisRec(PVisRec(Sender.getnodedata(Node))^).s := '';
end;

procedure TvisibilityFrm.invisibleBoxClick(Sender: TObject);
begin
 VisibleBox.IterateSubtree(NIL, unselect, NIL);
 normalbox.IterateSubtree(NIL, unselect, NIL);
end;

procedure TvisibilityFrm.visibleBoxClick(Sender: TObject);
begin
 invisbox.IterateSubtree(NIL, unselect, NIL);
 normalbox.IterateSubtree(NIL, unselect, NIL);
end;

procedure TvisibilityFrm.move2invClick(Sender: TObject);
begin
  if
 {$IFDEF UseNotSSI}
  (not (thisProto.ProtoElem is TicqSession) or TicqSession(thisProto.ProtoElem).useSSI) and
//   icq.useSSI and
 {$ENDIF UseNotSSI}
    not thisProto.isOnline then
    begin
     OnlFeature(thisProto, false);
     Exit;
    end;
  if normalBox.SelectedCount > 0 then
    normal2inv;
  if visibleBox.SelectedCount > 0 then
    vis2inv;
  if invisBox.SelectedCount = 0 then
    setUpBoxes;
 {$IFDEF UseNotSSI}
  if (thisProto.ProtoElem is TicqSession) then
    TicqSession(thisProto.ProtoElem).updateVisibility;
//  ICQ.updateVisibility;
 {$ENDIF UseNotSSI}
  saveListsDelayed:=TRUE;
  RnQmain.roster.repaint;
end;

procedure TvisibilityFrm.move2normalClick(Sender: TObject);
begin
  if
 {$IFDEF UseNotSSI}
//   icq.useSSI and
  (not (thisProto.ProtoElem is TicqSession) or TicqSession(thisProto.ProtoElem).useSSI) and
 {$ENDIF UseNotSSI}
   not thisProto.isOnline then
    begin
     OnlFeature(thisProto, false);
     Exit;
    end;
  if invisBox.SelectedCount > 0 then
    inv2normal;
  if visibleBox.SelectedCount > 0 then
    vis2normal;
  if normalBox.SelectedCount = 0 then
    setUpBoxes;
 {$IFDEF UseNotSSI}
  if (thisProto.ProtoElem is TicqSession) then
    TicqSession(thisProto.ProtoElem).updateVisibility;
//  ICQ.updateVisibility;
 {$ENDIF UseNotSSI}
  saveListsDelayed:=TRUE;
  RnQmain.roster.repaint;
end;

procedure TvisibilityFrm.move2visClick(Sender: TObject);
begin
  if
 {$IFDEF UseNotSSI}
//   icq.useSSI and
  (not (thisProto.ProtoElem is TicqSession) or TicqSession(thisProto.ProtoElem).useSSI) and
 {$ENDIF UseNotSSI}
    not thisProto.isOnline then
    begin
     OnlFeature(thisProto, false);
     Exit;
    end;
  if normalBox.SelectedCount > 0 then
    normal2vis;
  if invisBox.SelectedCount > 0 then
    inv2vis;
  if visibleBox.SelectedCount = 0 then
    setUpBoxes;
 {$IFDEF UseNotSSI}
  if (thisProto.ProtoElem is TicqSession) then
    TicqSession(thisProto.ProtoElem).updateVisibility;
//  ICQ.updateVisibility;
 {$ENDIF UseNotSSI}
  saveListsDelayed:=TRUE;
  RnQmain.roster.repaint;
end;

procedure TvisibilityFrm.selectAll(lb:TBaseVirtualTree);
//var
//  i:integer;
begin
  if lb<>normalBox then
    normalbox.IterateSubtree(NIL, unselect, NIL);
  if lb<>visibleBox then
    VisibleBox.IterateSubtree(NIL, unselect, NIL);
  if lb<>invisBox then
    InvisBox.IterateSubtree(NIL, unselect, NIL);

  lb.IterateSubtree(NIL, select, NIL);
end; // selectAll

procedure TvisibilityFrm.selectall1Click(Sender: TObject);
begin
  selectAll(invisBox)
end;

procedure TvisibilityFrm.Selectall2Click(Sender: TObject);
begin
  selectAll(normalBox)
end;

procedure TvisibilityFrm.Selectall3Click(Sender: TObject);
begin
  selectAll(visibleBox)
end;

procedure TvisibilityFrm.destroyHandle;
begin
  inherited
end;

end.
