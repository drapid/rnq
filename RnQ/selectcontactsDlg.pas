{
This file is part of R&Q.
Under same license
}
unit selectcontactsDlg;
{$I RnQConfig.inc}
{$I NoRTTI.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  StdCtrls, ExtCtrls,
  ComCtrls, Menus, RnQButtons, RnQDialogs, VirtualTrees,
  RnQProtocol
  ;

type
//  TchkState=(CK_on,CK_off);

  PListItem = ^Tlistitem;
  Tlistitem = record
     kind:(LI_group, LI_contact);
//     check:TchkState;
     grpId:integer;
     UID : String;
    end;

  TscOptions=set of (sco_multi,sco_groups, sco_selected, sco_predefined);

  PselectCntsFrm = ^TselectCntsFrm;
  TselectCntsFrm = class(TForm)
    sbar: TStatusBar;
    listPnl: TPanel;
    Label1: TLabel;
    saveBtn: TRnQSpeedButton;
    addBtn: TRnQSpeedButton;
    uinlistBox: TComboBox;
    subBtn: TRnQSpeedButton;
    delBtn: TRnQSpeedButton;
    list: TVirtualDrawTree;
    doBtn: TRnQButton;
    selectBtn: TRnQButton;
    unselectBtn: TRnQButton;
    procedure MenuPopup(Sender: TObject);
    procedure listClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure listDrawNode(Sender: TBaseVirtualTree;
      const PaintInfo: TVTPaintInfo);
    procedure selectBtnClick(Sender: TObject);
    procedure unselectBtnClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure listMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure listKeyPress(Sender: TObject; var Key: Char);
    procedure saveBtnClick(Sender: TObject);
    procedure addBtnClick(Sender: TObject);
    procedure Viewinfo1Click(Sender: TObject);
    procedure Sendmessage1Click(Sender: TObject);
    procedure subBtnClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure delBtnClick(Sender: TObject);
    procedure ApplyCheck(Sender: TBaseVirtualTree; Node: PVirtualNode; Data: Pointer; var Abort: Boolean);
    procedure listGetNodeWidth(Sender: TBaseVirtualTree; HintCanvas: TCanvas;
      Node: PVirtualNode; Column: TColumnIndex; var NodeWidth: Integer);
    procedure listChecked(Sender: TBaseVirtualTree; Node: PVirtualNode);
  public
    cl:TRnQCList;
    proto : TRnQProtocol;
    extra:Tobject;
    options:TscOptions;
    constructor doAll(owner_ :Tcomponent;
                      const caption_, doBtn_ :string;
                      const pProto : TRnQProtocol;
                      cl_ :TRnQCList;      // this object will be freed at close
                      what2do :TnotifyEvent;
                      options_:TscOptions;
                      pfrm : PselectCntsFrm;
                      doNIL : Boolean = false
                      );
    constructor doAll2(owner_ :Tcomponent;
                      const caption_, doBtn_ :string;
                      const pProto : TRnQProtocol;
                      cl_ :TRnQCList;      // this object will be freed at close
                      what2do :TnotifyEvent;
                      options_:TscOptions;
                      pfrm : PselectCntsFrm;
                      doNIL : Boolean = false
                      );
    procedure updateNumLbl;
    function selectedList:TRnQCList;
    function unselectedList:TRnQCList;
    procedure updateList;
    procedure clearList;
    function  findGroupNode(id : Integer) : PVirtualNode;
    procedure toggleAt(Node : PVirtualNode);
    procedure toggle(c:TRnQcontact);
    function  current:TRnQContact;
   private
    menu : TPopupMenu;
    frm  : PselectCntsFrm;
    doNILFrm : Boolean;
  end;

implementation

uses
  RnQLangs, RnQFileUtil, RQUtil, RDGlobal, RQThemes, //menusUnit,
  RnQSysUtils,
  RnQMenu, RnQPics,
  langLib, uinlistLib, globalLib, utilLib,
 {$IFDEF PROTOCOL_ICQ}
  ICQv9,
 {$ENDIF PROTOCOL_ICQ}
  chatDlg, mainDlg, themesLib;

{$R *.DFM}

constructor TselectCntsFrm.doAll(owner_:Tcomponent;
      const caption_,doBtn_:string; const pProto : TRnQProtocol;
      cl_:TRnQCList; what2do:TnotifyEvent; options_:TscOptions;
      pfrm : PselectCntsFrm; doNIL : Boolean = false );
begin
  if cl_ = NIL then exit;
  inherited create(owner_);
  applyTaskButton(self);
  applyCommonSettings(self);
  options := options_;
  caption := getTranslation(caption_);
  doBtn.caption := getTranslation(doBtn_);
  doBtn.onClick:=what2do;
  cl:=TRnQCList(cl_);
  selectBtn.Enabled := sco_multi in options;
  unselectBtn.Enabled := selectBtn.Enabled;
  listPnl.visible:=SCO_predefined in options;
  if not listPnl.visible then
   begin
     selectBtn.Top := selectBtn.Top + listPnl.height;
     unselectBtn.Top := selectBtn.Top;
     doBtn.Top := doBtn.Top + listPnl.height;
     list.Height := list.Height + listPnl.height;
   end;
//  height:=height-listPnl.height;

  updateList;
  frm := pfrm;
  doNILFrm := doNIL;
  translateWindow(self);
  showForm(self);
  bringForeground:=handle;
end;

constructor TselectCntsFrm.doAll2(owner_:Tcomponent;
      const caption_,doBtn_:string; const pProto : TRnQProtocol;
      cl_:TRnQCList; what2do:TnotifyEvent; options_:TscOptions;
      pfrm : PselectCntsFrm; doNIL : Boolean = false );
begin
  if cl_ = NIL then exit;
  inherited create(owner_);
  applyTaskButton(self);
  applyCommonSettings(self);
  options:=options_;
  caption:=caption_;
  doBtn.caption:=doBtn_;
  doBtn.onClick:=what2do;
  proto := pProto;
  cl:=TRnQCList(cl_);
  selectBtn.Enabled := sco_multi in options;
  unselectBtn.Enabled := selectBtn.Enabled;
  listPnl.visible:=SCO_predefined in options;
  if not listPnl.visible then
   begin
     selectBtn.Top := selectBtn.Top + listPnl.height;
     unselectBtn.Top := selectBtn.Top;
     doBtn.Top := doBtn.Top + listPnl.height;
     list.Height := list.Height + listPnl.height;
   end;
//  height:=height-listPnl.height;

  updateList;
  frm := pfrm;
  doNILFrm := doNIL;
  translateWindow(self);
  showForm(self);
  bringForeground:=handle;
end;


// doAll

procedure TselectCntsFrm.clearList;
begin
  list.clear;
end; // clearList

function TselectCntsFrm.findGroupNode(id : Integer) : PVirtualNode;
var
//  i:integer;
  ligrp: Plistitem;
  n : PVirtualNode;
begin
  if id = 0 then
   begin
     result := NIL;
     Exit;
   end;
  n := list.GetFirst;
  while n<>nil do
   begin
    with Tlistitem(PListItem(list.getnodedata(n))^) do
      if (kind=LI_group) and (grpId = ID) then
        begin
         break;
        end;
    n := list.GetNext(n);
   end;
  if n = NIL then
   begin
    list.BeginUpdate;
    n := list.AddChild(NIL);
    ligrp := list.GetNodeData(n);
//    ligrp.check:=li.check;
    ligrp.kind:=LI_group;
    ligrp.grpId:= id;
    ligrp.UID  := '';
    if sco_multi in options then
//      n.CheckType := ctCheckBox
      n.CheckType := ctTriStateCheckBox
     else
      n.CheckType := ctNone;
    n.CheckState := csUncheckedNormal;
    list.EndUpdate;
   end;
  result := n;
end;

procedure TselectCntsFrm.updateList;
var
  li : Plistitem;
  g, n  : PVirtualNode;
//  grp: integer;
  C  : TRnQcontact;
//  chk : TchkState;
begin
 uinlistBox.Items.text:=uinlists.names;
 uinlistBox.text:='';

 clearList;
 if SCO_groups in options then
  sortCLbyGroups(cl)
 else
  sortCL(cl);
 cl.resetEnumeration;
// grp:=0;
// g := NIL;
//groups.
 list.BeginUpdate;
 while cl.hasMore do
  begin
    c := TRnQContact(cl.getNext);
    if c.UID = '' then
     Continue;
{
    if SCO_selected in options then
      chk:=CK_on
    else
      chk:=CK_off;}
    if (SCO_groups in options) then // and (grp<> cl.get(li.UID).group) then
      begin
       g := findGroupNode(c.group);
       if g <> NIL then
       begin
  //       TlistItem(PListItem(List.getnodedata(g)^)^).grpId:= grp;
//         TlistItem(PListItem(List.getnodedata(g))^).check:=chk;
//         g.CheckState := csCheckedNormal;
  //    g := list.AddChild(NIL, ligrp);
  //    list.items.addObject('',ligrp);
       end;
      end
     else
      g := NIL;
    n := list.AddChild(g);
    li := list.GetNodeData(n);
    li.UID := c.UID;
    li.kind:= LI_contact;
//    li.check:=chk;
//    n.CheckType := ctTriStateCheckBox;
//    if li.kind = LI_group then
//      n.CheckType := ctTriStateCheckBox
//     else
    if sco_multi in options then
      n.CheckType := ctCheckBox
     else
      n.CheckType := ctNone;
  //  list.items.addObject(li.contact.displayed,li);
  end;
 list.EndUpdate;
 updateNumLbl;
 list.FullExpand;
end; // updateList


procedure TselectCntsFrm.ApplyCheck(Sender: TBaseVirtualTree; Node: PVirtualNode; Data: Pointer; var Abort: Boolean);
begin
//  TlistItem(PListItem(Sender.getnodedata(Node))^).check := TchkState(Data^);
  if TCheckState(Data^) = csCheckedNormal then
//  if TchkState(Data^) = CK_on then
   Node.CheckState := csCheckedNormal
  else
   Node.CheckState := csUncheckedNormal;
end;

procedure TselectCntsFrm.selectBtnClick(Sender: TObject);
var
//  i:integer;
//  ch : TchkState;
  ch : TCheckState;
begin
//  ch := CK_on;
  ch := csCheckedNormal;
  list.IterateSubtree(nil, ApplyCheck, @ch );
  list.repaint;
  updateNumLbl;
end; // select

procedure TselectCntsFrm.unselectBtnClick(Sender: TObject);
var
//  i:integer;
//  ch : TchkState;
  ch : TCheckState;
begin
//  ch := CK_off;
  ch := csUnCheckedNormal;
  list.IterateSubtree(nil, ApplyCheck, @ch );
  list.repaint;
  updateNumLbl;
end; // unselect

procedure TselectCntsFrm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  clearList;
  menu.Free;
  cl.free;
  cl:=NIL;
  action:=caFree;
  if doNILFrm then frm^ := NIL;
  destroyHandle;
//  self := NIL;
end;

procedure TselectCntsFrm.FormCreate(Sender: TObject);
begin
  list.NodeDataSize := SizeOf(Tlistitem);
  menu := TPopupMenu.Create(self);
  AddToMenu(menu.Items, 'View info', PIC_INFO, True, Viewinfo1Click);
  AddToMenu(menu.Items, 'Send message', PIC_MSG, False, Sendmessage1Click);
  list.PopupMenu := menu;
  menu.OnPopup := MenuPopup;
end;

procedure TselectCntsFrm.updateNumLbl;
var
//  i,
  cnt:integer;
  node : PVirtualNode;
begin
 cnt:=0;
  node := list.GetFirst;
  while (node<>NIL) do
  begin
    with Tlistitem(PListItem(list.getnodedata(Node))^) do
//     if (node.CheckState = csCheckedNormal) (check=CK_on) and (kind=LI_contact) then
     if (node.CheckState = csCheckedNormal) and (kind=LI_contact) then
       inc(cnt);
    node:= list.GetNext(node);
  end;// or (node.kind=NODE_CONTACT) and AnsiStartsText(searching[1], node.contact.displayed);

 sbar.simpletext:=getTranslation('Contacts selected: %d/%d',[cnt,cl.count]);
end; // updateNumLbl

function TselectCntsFrm.selectedList:TRnQCList;
var
  n : PVirtualNode;
begin
 result:=TRnQCList.create;
  n := list.GetFirst;
  while n <> NIL do
   begin
    with Tlistitem(PListItem(list.getnodedata(n))^) do
//      if (check=CK_on) and (kind=LI_contact) then
      if (n.CheckState =csCheckedNormal) and (kind=LI_contact) then
     result.add( Account.AccProto.getContact(UID));
    n := list.GetNext(n);
   end;
end; // selectedList

function TselectCntsFrm.unselectedList:TRnQCList;
var
  n : PVirtualNode;
begin
 result:=TRnQCList.create;
  n := list.GetFirst;
  while n <> NIL do
   begin
    with Tlistitem(PListItem(list.getnodedata(n))^) do
//      if (check=CK_off) and (kind=LI_contact) then
      if (n.CheckState =csUncheckedNormal) and (kind=LI_contact) then
     result.add( Account.AccProto.getContact(UID));
    n := list.GetNext(n);
   end;
end; // unselectedList

procedure TselectCntsFrm.listChecked(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
begin
  updateNumLbl;
end;

procedure TselectCntsFrm.listClick(Sender: TObject);
begin
//  toggleAt(list.FocusedNode);
end;

procedure TselectCntsFrm.listDrawNode(Sender: TBaseVirtualTree;
  const PaintInfo: TVTPaintInfo);
var
  x,y:integer;
//  cnv:Tcanvas;
  oldMode: Integer;
  s : string;
begin
//  cnv := PaintInfo.Canvas;
//  if sender.Selected[PaintInfo.Node] then
//    PaintInfo.Canvas.brush.color:=selectedColor;
//  PaintInfo.Canvas.fillRect(PaintInfo.ContentRect);
   if vsSelected in PaintInfo.Node^.States then
    PaintInfo.Canvas.Font.Color :=clHighlightText
   else
    PaintInfo.Canvas.Font.Color := clWindowText;

  x := PaintInfo.ContentRect.Left+2;
  y := PaintInfo.ContentRect.top;
  with TListItem(Plistitem(list.getnodedata(PaintInfo.Node))^) do
    begin
{    if sco_multi in options then
      if check=CK_on then
        inc(x, theme.drawPic(PaintInfo.Canvas.Handle, x,y,PIC_CHECKED).cx+2)
      else
        inc(x, theme.drawPic(PaintInfo.Canvas.Handle, x,y,PIC_UNCHECKED).cx+2);
}
    case kind of
      LI_contact:
        begin
        PaintInfo.Canvas.font.style:=[];
//        drawTxt(PaintInfo.Canvas.handle, x,y+1, cl.get(UID).displayed);
//        PaintInfo.Canvas.TextOut(x,y+1, cl.get(UID).displayed);
          with  Account.AccProto.getContact(UID) do
          begin
           inc(x, theme.drawPic(PaintInfo.Canvas.Handle, x,y, statusImg).cx+2);
           s := displayed;
          end;
          oldMode:= SetBKMode(PaintInfo.Canvas.Handle, TRANSPARENT);
          textOut(PaintInfo.Canvas.handle, x,y+1, PChar(s), length(s));
          SetBKMode(PaintInfo.Canvas.Handle, oldMode);
        end;
      LI_group:
        begin
//        PaintInfo.Node.States
        if vsExpanded in PaintInfo.Node.States then
          inc(x, theme.drawPic(PaintInfo.Canvas.Handle, x,y, PIC_OPEN_GROUP).cx+2)
         else
          inc(x, theme.drawPic(PaintInfo.Canvas.Handle, x,y, PIC_CLOSE_GROUP).cx+2);
        PaintInfo.Canvas.font.color:=clMaroon;
        PaintInfo.Canvas.font.style:=[fsBold];
        PaintInfo.Canvas.TextOut(x,y+1, groups.id2name(grpId));
//        drawTxt(PaintInfo.Canvas.handle, x,y+1, groups.id2name(grpId));
        end;
      end;
    end;

//  PaintInfo.ContentRect
end;

procedure TselectCntsFrm.listGetNodeWidth(Sender: TBaseVirtualTree;
  HintCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
  var NodeWidth: Integer);
begin
  NodeWidth := 20;
end;

procedure TselectCntsFrm.listMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
//  i:integer;
  n : PVirtualNode;
begin
if not (sco_multi in options) then exit;
  n := list.GetNodeAt(x, y);
//i:=list.ItemAtPos(point(x,y),TRUE);
if n = nil then exit;
(*
case button of
  mbLeft:
//    if (x>=2) and (x<=2+theme.getPicSize(PIC_CHECKED).cx) then
      toggleAt(n);

{  mbRight:
    begin
    list.itemIndex:=i;
    if current<>NIL then
      with mousePos do
        menu.popup(x,y);
    end;}
  end;*)
end;

procedure TselectCntsFrm.MenuPopup(Sender: TObject);
var
 C : TRnQcontact;
// i : Integer;
 it : TMenuItem;
begin
 c := current; 
 if Sender is TPopupMenu then
//  with TPopupMenu(sender) do
   for it in TPopupMenu(sender).Items do
//    for i := 0 to TPopupMenu(sender).Items.Count -1 do
    it.Enabled := C <> NIL;
//         TPopupMenu(sender).Items[i].Enabled := C <> NIL;

end;

procedure TselectCntsFrm.toggle(c:TRnQcontact);
var
//  i:integer;
  n : PVirtualNode;
begin
  if not Assigned(c) then
    Exit;
  n := list.GetFirst;
  repeat
    with Tlistitem(PListItem(list.getnodedata(n))^) do
      if (kind=LI_contact) and (c.equals(UID)) then
        begin
         toggleAt(n);
         exit;
        end;
    n := list.GetNext(n);
  until n=nil;
end; // toggle

procedure TselectCntsFrm.toggleAt(node : PVirtualNode);
//var
//  R:Trect;
//  chk : TchkState;
begin
 if Node = NIL then exit;

 with Tlistitem(PListItem(list.getnodedata(Node))^) do
  begin
    case node.CheckState of
     csUncheckedNormal: Node.CheckState := csCheckedNormal;
     csCheckedNormal: Node.CheckState := csUnCheckedNormal;
    end;
//   else
{    case check of
     CK_on: check:=CK_off;
     CK_off: check:=CK_on;
    end;}
   if kind=LI_group then
    begin
//      list.IterateSubtree(Node, ApplyCheck, @check);
      list.IterateSubtree(Node, ApplyCheck, @Node.CheckState);
{    inc(i);
    with list.items do
      while (i<count) and (Tlistitem(PlistItem(list.getnodedata(Node)^)^).kind=LI_contact) do
        begin
        Tlistitem(objects[i]).check:=check;
        inc(i);
        end;}
      list.repaint;
      updateNumLbl;
      exit;
    end
  end;
 list.InvalidateNode(Node);
//R:=list.itemRect(i);
//invalidateRect(list.handle, @R, FALSE);
 updateNumLbl;
end; // toggleAt

procedure TselectCntsFrm.listKeyPress(Sender: TObject; var Key: Char);
begin
if key in [' ','+','-'] then
  toggleAt(list.FocusedNode);
if key=' ' then key:=#0;
end;

procedure TselectCntsFrm.saveBtnClick(Sender: TObject);
begin
if uinlistBox.text = '' then
  msgDlg('You need to enter a name for this uin-list', True, mtWarning)
else
  if not uinlists.exists(uinlistbox.text) or (messageDlg(getTranslation('This uin-list already exists.\nDo you want to overwrite it?'), mtConfirmation, [mbYes,mbNo], 0)=mrYes) then
    begin
    uinlists.put(uinlistbox.text).cl:=selectedList;
    uinlistBox.Items.text:=uinlists.names;
    saveListsDelayed := True;
//    if not saveFile(userPath+uinlistFilename, uinlists.toString) then
//      msgDlg(getTranslation('Error saving uinlists'), mtError);
    end;
end;

procedure TselectCntsFrm.addBtnClick(Sender: TObject);
var
//  i:integer;
  cl:TRnQCList;
  n : PVirtualNode;
begin
  if not uinlists.exists(uinlistbox.text) then exit;
  cl:=uinlists.get(uinlistbox.text).cl;
  n := list.GetFirst;
  repeat
    with Tlistitem(PListItem(list.getnodedata(n))^) do
      if (kind=LI_contact) and cl.exists(Account.AccProto, uid) then
        begin
//         check:=CK_on;
          n.CheckState := csCheckedNormal
        end;
    n := list.GetNext(n);    
  until n=nil;

 list.repaint;
 updateNumLbl;
// exit;
end;

function TselectCntsFrm.current:TRnQcontact;
begin
  result:=NIL;
  if list.FocusedNode = NIL then exit;
  with Tlistitem(PListItem(list.getnodedata(list.FocusedNode))^) do
  if kind = LI_group then
   result := NIL
  else
   result := Account.AccProto.getContact(UID);
end;

procedure TselectCntsFrm.Viewinfo1Click(Sender: TObject);
var
  cnt: TRnQContact;
begin
  cnt := current;
  if Assigned(cnt) then
   cnt.ViewInfo
end;

procedure TselectCntsFrm.Sendmessage1Click(Sender: TObject);
begin chatFrm.openOn(current) end;

procedure TselectCntsFrm.subBtnClick(Sender: TObject);
var
//  i:integer;
  cl:TRnQCList;
  n : PVirtualNode;
begin
if not uinlists.exists(uinlistbox.text) then exit;
cl:=uinlists.get(uinlistbox.text).cl;
  n := list.GetFirst;
  repeat
    with Tlistitem(PListItem(list.getnodedata(n))^) do
      if (kind=LI_contact) and cl.exists(Account.AccProto, UID) then
        begin
//         check:=CK_off;
          n.CheckState := csUncheckedNormal; 
        end;
    n := list.GetNext(n);
  until n=nil;
  list.repaint;
  updateNumLbl;
//  exit;
end;

procedure TselectCntsFrm.FormShow(Sender: TObject);
begin applyTaskButton(self) end;

procedure TselectCntsFrm.delBtnClick(Sender: TObject);
var
  ul:Puinlist;
begin
ul:=uinlists.get(uinlistBox.text);
if ul=NIL then exit;
if messageDlg(getTranslation('Are you sure you want to delete?'),mtConfirmation,[mbYes,mbNo],0)<>mrYes then exit;
if uinlists.remove(ul) then
	begin
	uinlistBox.Items.text:=uinlists.names;
  with uinlistBox do if Items.count=0 then text:='' else text:=items[0];
	msgDlg('Done', True, mtInformation)
  end
else
	msgDlg('Failed', True, mtError)
end;

end.
