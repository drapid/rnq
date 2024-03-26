{
  Copyright (C) 2002-2004  Massimo Melina (www.rejetto.com)

  This file is part of &RQ.

    &RQ is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    &RQ is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with &RQ; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
}
unit outboxDlg;
{$I RnQConfig.inc}
{$I NoRTTI.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  StdCtrls, ExtCtrls, ComCtrls, Menus,
  VirtualTrees.BaseAncestorVCL, VirtualTrees.BaseTree, VirtualTrees.AncestorVCL,
  VirtualTrees.DrawTree, VirtualTrees.Types,
  RnQButtons,
  outboxLib,
  RnQProtocol
  ;

type
  ToutboxFrm = class(TForm)
    menu: TPopupMenu;
    Viewinfo1: TMenuItem;
    Sendmsg1: TMenuItem;
    Panel1: TPanel;
    Panel2: TPanel;
    Splitter2: TSplitter;
    Panel3: TPanel;
    memo: TMemo;
    Panel4: TPanel;
    groupbox: TGroupBox;
    charsLbl: TLabel;
    infoLbl: TLabel;
    processChk00: TCheckBox;
    Bevel: TBevel;
    list: TVirtualDrawTree;
    deleteBtn: TRnQButton;
    saveBtn: TRnQButton;
    closeBtn: TRnQButton;
    procedure listChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure listDrawNode(Sender: TBaseVirtualTree;
      const PaintInfo: TVTPaintInfo);
    procedure FormCreate(Sender: TObject);
    procedure closeBtnClick(Sender: TObject);
    procedure listKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure listClick(Sender: TObject);
    procedure deleteBtnClick(Sender: TObject);
    procedure SplitterMoved(Sender: TObject);
    procedure memoChange(Sender: TObject);
    procedure saveBtnClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Sendmsg1Click(Sender: TObject);
    procedure Viewinfo1Click(Sender: TObject);
    procedure listMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure listDblClick(Sender: TObject);
    procedure menuPopup(Sender: TObject);
    procedure processChk00Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  public
    lastSelected: TOevent;
    function  selectedContact: TRnQContact;
    procedure updateList;
    procedure updateMemo;
    procedure updateChars;
//    function  validIdx(i: integer): boolean;
    procedure open(c: TRnQcontact=NIL);
   public
    procedure DestroyHandle; OverRide;
  end;

var
  outboxFrm: ToutboxFrm;

implementation

{$R *.DFM}

uses
  strutils, Themes, Dwmapi,
  RnQLangs, RQUtil, RDGlobal, RQThemes, RnQStrings,
  RDSysUtils, RnQPics,
  chatDlg, events, globalLib, utilLib, themesLib;

//function ToutboxFrm.validIdx(i:integer):boolean;
//begin result:=(i>=0) and (i<list.items.count) end;

procedure ToutboxFrm.updateList;
var
  i: integer;
  o: POEvent;
begin
  if self = NIL then
    Exit;
  list.clear;
  for i:=0 to Account.outbox.count-1 do
   begin
     list.BeginUpdate;
     o := list.GetNodeData(list.AddChild(NIL));
     o^ := Account.outbox.list[i];
     list.EndUpdate;
//    list.items.addObject('', outbox.list[i]);
   end;
  updatememo;
end; // updateList

procedure ToutboxFrm.updatememo;
var
  s, s1: string;
begin
  memo.readonly := TRUE;
if list.FocusedNode = NIL then
//not validIdx(list.itemIndex) then
  begin
  infoLbl.caption:='';
  memo.clear;
  updateChars;
  saveBtn.enabled:=FALSE;
  exit;
  end;

lastSelected := TOevent(POevent(list.getnodedata(list.FocusedNode))^);
//list.Items.Objects[list.itemIndex] as TOevent;
with lastSelected do
  begin
  memo.text := info;
   if kind= OE_msg then
     memo.readonly := FALSE;
  saveBtn.enabled := FALSE;
  case kind of
    OE_msg, OE_contacts, OE_addedYou, OE_auth, OE_authDenied:
      s := getTranslation(OEvent2ShowStr[kind]);
    else s:='';
    end;
  if Assigned(whom) then
    s1 := whom.displayed
   else
    s1 := Str_unk;
  infoLbl.caption:=getTranslation('%0:s%1:s for %2:s\nWrote: %3:s\nLast modify: %4:s',[
    ifThen(flags and IF_multiple >0, '('+getTranslation('multi-send')+') '),
    s, s1,
    datetimeToStr(wrote),
    ifThen(lastmodify>0, datetimeToStr(lastmodify), datetimeToStr(wrote))
  ]);
  end;

updateChars;
end;

procedure ToutboxFrm.updateChars;
begin
  charsLbl.caption := getTranslation('Chars:')+' '+intToStr(length(memo.text))
end;

procedure ToutboxFrm.FormShow(Sender: TObject);
begin
  processChk00.Checked := outboxprocessChk;
  theme.pic2ico(RQteFormIcon, PIC_OUTBOX, icon);
//theme.getPic(PIC_DELETE, deleteBtn.glyph);
//theme.getPic(PIC_SAVE, saveBtn.glyph);
  applyTaskButton(self);
end;

procedure ToutboxFrm.listDrawNode(Sender: TBaseVirtualTree;
  const PaintInfo: TVTPaintInfo);
var
  oe: TOevent;
  cnv: Tcanvas;
  x, y: integer;
//  c: Tcontact;
  s1: String;
  msg: string;
  bmp: AnsiString;
//  oldClr: Tcolor;

  procedure outText(s: string);
  begin
    cnv.textOut(x, y, s);
    inc(x, cnv.textWidth(s));
  end;

begin
  cnv := PaintInfo.canvas;
  cnv.fillRect(PaintInfo.ContentRect);
  if vsSelected in PaintInfo.Node.States then
   begin
    if Sender.Focused then
      PaintInfo.Canvas.Font.Color := clHighlightText
    else
      PaintInfo.Canvas.Font.Color := clWindowText;
   end
  else
    PaintInfo.Canvas.Font.Color := clWindowText;

  oe := TOevent(POevent(Sender.getnodedata(PaintInfo.Node))^);
//list.Items.Objects[index] as TOevent;
x:=PaintInfo.ContentRect.Left+2;
y:=PaintInfo.ContentRect.top;
cnv.font.size:=-10;
  if oe.kind = OE_email then
    s1 := oe.email
   else
//  c:= Tcontact(contactsDB.get(oe.uid))
    if Assigned(oe.whom) then
      s1 := oe.whom.displayed
     else
      s1 := Str_unk; 

case oe.kind of
  OE_msg: bmp := PIC_MSG;
  OE_contacts: bmp := PIC_CONTACTS;
  OE_addedYou: bmp := PIC_ADD_CONTACT;
  OE_auth:
    begin
    bmp := '';
    msg := getTranslation('Yes');
    end;
  OE_authDenied:
    begin
    bmp := '';
    msg := getTranslation('No');
    end;
  else exit;
  end;
if bmp<>'' then
  inc(x, theme.drawPic(cnv.Handle,x,y,bmp, True, GetParentCurrentDpi).cx+2)
else
  begin
//  cnv.Font.style:=[fsBold];
{  if vsSelected	in PaintInfo.Node.States then
    outText(msg)
  else
    begin
    oldClr:=cnv.brush.color;
    cnv.brush.color:=clBtnFace;
    cnv.Pen.color:=oldClr;
    cnv.Ellipse(x,y,x+cnv.textWidth(msg),y+cnv.textHeight(msg));
    cnv.brush.color:=oldClr;
    SetBkMode(cnv.handle, TRANSPARENT);
    outText(msg);
    SetBkMode(cnv.handle, OPAQUE);
    end;}
    outText(msg);
  cnv.Font.style := [];
  inc(x,4);
  end;
  outText(s1);
end;

// list drawitem

procedure ToutboxFrm.listChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
begin
 updatememo;
 deleteBtn.enabled := list.FocusedNode<>NIL;
 saveBtn.enabled := FALSE;
end;

procedure ToutboxFrm.listClick(Sender: TObject);
begin
  updatememo;
  deleteBtn.enabled := list.FocusedNode<>NIL;
  saveBtn.enabled := FALSE;
end;

procedure ToutboxFrm.deleteBtnClick(Sender: TObject);
var
  ev: TOevent;
//  i: integer;
  n: PVirtualNode;
begin
  if list.SelectedCount <= 0 then
    Exit;
  n := list.GetFirst;
  while n <> NIL do
  begin
   if list.Selected[n] then
    begin
     ev := TOevent(POevent(list.getnodedata(n))^);
//     ev:=list.Items.Objects[i] as TOevent;
     Account.outbox.remove(ev);
     ev.free;
    end;
   n := list.GetNext(n);
  end;
//  updateList;
  list.DeleteSelectedNodes;
  list.FocusedNode := list.GetFirst;
  if list.FocusedNode <> NIL then
    list.Selected[list.FocusedNode] := True;
  if list.GetLast = NIL then
   begin
//  if list.Count=0 then
     listClick(sender);
//     deleteBtn.Enabled:=False;
   end;
end;

procedure ToutboxFrm.SplitterMoved(Sender: TObject);
begin
//list.height := splitter.top;
//memo.height := clientHeight-splitter.height-list.height
end;

procedure ToutboxFrm.memoChange(Sender: TObject);
begin
  saveBtn.enabled := TRUE;
  updateChars;
end;

procedure ToutboxFrm.saveBtnClick(Sender: TObject);
begin
 if list.FocusedNode = NIL then
    Exit;
//with list.Items.Objects[list.itemIndex] as TOevent do
 with TOevent(POevent(list.getnodedata(list.FocusedNode))^) do
  begin
    info := memo.text;
    lastmodify := now;
  end;
  saveBtn.enabled := FALSE;
end;

procedure ToutboxFrm.FormResize(Sender: TObject);
//var
//  i: integer;
begin
{if memo.boundsrect.Bottom > clientHeight then
  begin
  i := clientHeight-splitter.boundsrect.bottom;
  if i > 10 then
    memo.height:=i;
  end;  }
end;

procedure ToutboxFrm.open(c: TRnQcontact=NIL);
var
//  i: integer;
  n: PVirtualNode;
begin
 lastSelected := NIL;
 n := NIL;
 updateList;
if c=NIL then
//  list.get
//  i := list.items.indexOfObject(lastSelected)
else
  begin
    n := list.GetLast();
    while (n <> NIL) and (c.equals(TOevent(POevent(list.getnodedata(n))^).whom)) do
     n := list.GetPrevious(n);
  end;
if n = NIL then
  if list.GetLast <> NIL then
    n := list.GetFirst
//  else
    ;
if n <> NIL then
  begin
    list.FocusedNode := n;
    list.Selected[n] := True;
  end;
updateMemo;
deleteBtn.enabled:= n <> NIL;
show;
end; // open

procedure ToutboxFrm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  outboxprocessChk := processChk00.Checked;
  destroyHandle;
  Action := caFree;
  outboxFrm := NIL;
end;

procedure ToutboxFrm.FormCreate(Sender: TObject);
begin
  list.NodeDataSize := SizeOf(TOEvent);
  Bevel.Visible := not (StyleServices.Enabled and DwmCompositionEnabled);
end;

function ToutboxFrm.selectedContact:TRnQContact;
begin
result:=NIL;
if (lastSelected<>NIL) then
  with lastSelected do
    if kind <> OE_email then
//      result:=contactsDB.get(UID);
      result := whom;
end; // selectedContact

procedure ToutboxFrm.Sendmsg1Click(Sender: TObject);
begin
  if lastSelected = NIL then
    exit;
  Account.outbox.remove(lastSelected);
  processOevent(lastSelected);
  lastSelected.Free;
  updateList;
end;

procedure ToutboxFrm.Viewinfo1Click(Sender: TObject);
begin
  if selectedContact<>NIL then
//    viewinfoAbout(selectedContact)
    selectedContact.ViewInfo;
end;

procedure ToutboxFrm.listMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
if button=mbRight then
  if selectedContact<>NIL then
    with mousePos do
      menu.popup(x,y);
end;

procedure ToutboxFrm.listDblClick(Sender: TObject);
begin
  if selectedContact<>NIL then
    chatFrm.openOn(selectedContact)
end;

procedure ToutboxFrm.destroyHandle;
begin
  inherited
end;

procedure ToutboxFrm.menuPopup(Sender: TObject);
begin
  if (lastSelected = NIL)or (lastSelected.whom = NIL) then
    exit;

  Sendmsg1.Enabled := lastSelected.whom.Proto.isOnline;
end;

procedure ToutboxFrm.processChk00Click(Sender: TObject);
begin
  outboxprocessChk := processChk00.Checked;
end;

procedure ToutboxFrm.FormDestroy(Sender: TObject);
begin
  Self := nil;
end;

procedure ToutboxFrm.listKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if key=VK_DELETE then
   deleteBtnClick(nil);
end;

procedure ToutboxFrm.closeBtnClick(Sender: TObject);
begin
  Close;
end;

end.
