{
This file is part of R&Q.
Under same license
}
unit automsgDlg;
{$I Compilers.inc}
{$I RnQConfig.inc}

 {$IFDEF COMPILER_14_UP}
  {$WEAKLINKRTTI ON}
  {$RTTI EXPLICIT METHODS([]) FIELDS([]) PROPERTIES([])}
 {$ENDIF COMPILER_14_UP}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  ExtCtrls, StdCtrls, RnQButtons, VirtualTrees;

type
  TautomsgFrm = class(TForm)
    msgBox: TMemo;
    popupChk: TCheckBox;
    ok2enterChk: TCheckBox;
    nameBox: TEdit;
    Panel1: TPanel;
    Bevel1: TBevel;
    PredBox: TVirtualDrawTree;
    okBtn: TRnQButton;
    cancelBtn: TRnQButton;
    saveBtn: TRnQButton;
    deleteBtn: TRnQButton;
    procedure PredBoxChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure FormCreate(Sender: TObject);
    procedure PredBoxDrawNode(Sender: TBaseVirtualTree;
      const PaintInfo: TVTPaintInfo);
    procedure FormShow(Sender: TObject);
    procedure okBtnClick(Sender: TObject);
    procedure cancelBtnClick(Sender: TObject);
    procedure saveBtnClick(Sender: TObject);
    procedure deleteBtnClick(Sender: TObject);
    procedure predBoxClick(Sender: TObject);
    procedure msgBoxKeyPress(Sender: TObject; var Key: Char);
    procedure ok2enterChkClick(Sender: TObject);
    procedure nameBoxKeyPress(Sender: TObject; var Key: Char);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  public
    lastKey:char;
    procedure saveautomsg;
//  public procedure destroyHandle;
  end;

var
  automsgFrm: TautomsgFrm;

implementation

{$R *.dfm}

uses
  RnQSysUtils,
  globalLib, utilLib, RQUtil;

type
  PAutMsg = ^TAutMsg;
  TAutMsg = record
     Name, Str : String;
  end;  
//procedure TautomsgFrm.destroyHandle; begin inherited end;

procedure TautomsgFrm.FormShow(Sender: TObject);
var
  i:integer;
  s : PAutMsg;
begin
applyTaskButton(self);
msgBox.text:=automessages[0];
popupChk.checked:=popupAutomsg;
ok2enterChk.checked:=okOn2enter_autoMsg;
msgBox.setFocus;
msgBox.SelectAll;

predBox.clear;
for i:=1 to automessages.count-1 do
  if odd(i) then
   begin
    PredBox.BeginUpdate;
    s := PredBox.GetNodeData(predBox.AddChild(NIL));
    s.Name := automessages[i];
    s.Str := automessages[i+1];
    PredBox.EndUpdate;
   end;
end;

procedure TautomsgFrm.okBtnClick(Sender: TObject);
begin
 autoaway.bakmsg:='';
 popupAutomsg:=popupChk.checked;
 setAutomsg(msgBox.text);
 ModalResult := mrOk;
 close;
end;

procedure TautomsgFrm.PredBoxChange(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
begin
 if Node <> NIL then
  msgBox.text:= TAutMsg(PAutMsg(predBox.getnodedata(Node))^).Str;
end;

procedure TautomsgFrm.cancelBtnClick(Sender: TObject);
begin
  ModalResult := mrCancel;
  close;
end;

procedure TautomsgFrm.saveautomsg;
var
  i:integer;
  s : PAutMsg;
begin
if trim(nameBox.text)='' then
  exit;
nameBox.visible:=FALSE;
deleteBtn.enabled:=TRUE;
i:=1;
while i < automessages.count do
  begin
  if compareText(automessages[i], nameBox.text)=0 then
    break;
  inc(i,2);
  end;
if i >= automessages.count then
  begin
    PredBox.BeginUpdate;
    s := PredBox.GetNodeData(predBox.AddChild(NIL));
    s.Name := nameBox.text;
    s.Str := msgBox.text;
    PredBox.EndUpdate;
//  predBox.items.add(nameBox.text);
  automessages.add(nameBox.text);
  automessages.add('');
  end;
automessages[i+1]:=msgBox.text;
end; // saveAutomsg

procedure TautomsgFrm.saveBtnClick(Sender: TObject);
begin
if nameBox.visible then
  saveAutomsg
else
  begin
  deleteBtn.enabled:=FALSE;
  nameBox.visible:=TRUE;
  nameBox.setFocus;
  end
end;

procedure TautomsgFrm.deleteBtnClick(Sender: TObject);
var
  i:integer;
  name:string;
begin
if predBox.FocusedNode = NIL then exit;
//if predBox.itemIndex < 0 then exit;
//name:=predBox.items[predBox.itemIndex];
//predBox.items.delete(predBox.itemIndex);
name:=TAutMsg(PAutMsg(predBox.getnodedata(predBox.FocusedNode))^).Name;
predBox.DeleteNode(predBox.FocusedNode);
i:=1;
while i < automessages.count do
  begin
  if compareText(automessages[i], name)=0 then
    begin
    automessages.delete(i);
    automessages.delete(i);
    break;
    end;
  inc(i,2);
  end;
end;

procedure TautomsgFrm.predBoxClick(Sender: TObject);
begin
msgBox.text:= TAutMsg(PAutMsg(predBox.getnodedata(predBox.FocusedNode))^).Str;
//automessages[succ(predBox.itemIndex)*2]
end;

procedure TautomsgFrm.PredBoxDrawNode(Sender: TBaseVirtualTree;
  const PaintInfo: TVTPaintInfo);
var
  s : String;
  x : Integer;
begin
  s := TAutMsg(PAutMsg(predBox.getnodedata(PaintInfo.Node))^).Name;
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
    PaintInfo.Canvas.textout(PaintInfo.ContentRect.Left +x,2, s);
end;

procedure TautomsgFrm.msgBoxKeyPress(Sender: TObject; var Key: Char);
begin
if (key=#13) and (lastKey=#13) and okOn2enter_automsg then
  begin
  key:=#0;
  okBtnClick(sender);
  end;
lastKey:=key;
end;

procedure TautomsgFrm.ok2enterChkClick(Sender: TObject);
begin
okOn2enter_autoMsg:=ok2enterChk.checked;
end;

procedure TautomsgFrm.nameBoxKeyPress(Sender: TObject; var Key: Char);
begin
if key=#27 then
  begin
  deleteBtn.enabled:=TRUE;
  nameBox.visible:=FALSE;
  end;
if key=#13 then
  begin
  key:=#0;
  saveautomsg;
  end;
end;

procedure TautomsgFrm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  automsgFrm := NIL;
  Action := caFree;
end;

procedure TautomsgFrm.FormCreate(Sender: TObject);
begin
  PredBox.NodeDataSize := SizeOf(TAutMsg)
end;

end.
