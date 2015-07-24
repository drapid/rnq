{
This file is part of R&Q.
Under same license
}
unit hotkeys_fr;
{$I RnQConfig.inc}
{$I NoRTTI.inc}

interface

uses 
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  ComCtrls, StdCtrls, VirtualTrees,
  RnQButtons, RnQMacros, RDGlobal, RnQPrefsLib;

type
  ThotkeysFr = class(TPrefFrame)
    hotkey: THotKey;
    Label1: TLabel;
    Label2: TLabel;
    swChk: TCheckBox;
    actionBox: TComboBox;
    Label3: TLabel;
    Label4: TLabel;
    winkeyChk: TCheckBox;
    HKTree: TVirtualDrawTree;
    btnDefault: TRnQButton;
    saveBtn: TRnQButton;
    deleteBtn: TRnQButton;
    replaceBtn: TRnQButton;
    procedure HKTreeChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure HKTreeDrawNode(Sender: TBaseVirtualTree;
      const PaintInfo: TVTPaintInfo);
    procedure btnDefaultClick(Sender: TObject);
    procedure FrameContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure saveBtnClick(Sender: TObject);
    procedure deleteBtnClick(Sender: TObject);
    procedure replaceBtnClick(Sender: TObject);
    procedure HKTreeFreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure ClearAll(Sender: TBaseVirtualTree; Node: PVirtualNode; Data: Pointer; var Abort: Boolean);
  private
    function winkey():integer;
  public
    procedure initPage; Override;
    procedure applyPage; Override;
    procedure resetPage; Override;
    procedure unInitPage; Override;
   procedure fillMacrosGrid(pMacros:Tmacros);
//    procedure updateVisible;
  end;

//  function  macroopcodeName(m:integer):string;
//  procedure fillMacrosGrid(macros:Tmacros);

implementation

{$R *.dfm}

uses
  RnQLangs, RDUtils, utilLib, Menus, StrUtils, globalLib;

type
  PHKItem = ^THKItem;
  THKItem = record
     s : array[0..2] of string;
//      s0, s1, s2 : String;
  end;

function macroopcodeName(m: integer): string;
begin result := getTranslation(globalLib.macro2str[m]) end;

procedure ThotkeysFr.fillMacrosGrid(pMacros:Tmacros);
var
  i:integer;
  HKitem : PHKItem;
//  grid:TStringGrid;
begin
 HKTree.Clear;
// if prefPages[thisPrefIdx].frame = NIL then exit;
//  grid:=ThotkeysFr(prefPages[thisPrefIdx].frame).grid;
{  grid.rowCount:=length(macros)+1;
  grid.cells[0,0]:='SW';
  grid.cells[1,0]:='HOTKEY';
  grid.cells[2,0]:='ACTION';}
  HKTree.BeginUpdate;
  for i:=0 to length(macros)-1 do
    begin
     HKitem := HKTree.GetNodeData(HKTree.AddChild(nil));
     HKitem.s[0] := macroopcodeName(pMacros[i].opcode);
     HKitem.s[1] := IfThen(pMacros[i].hk and $1000>0, 'WIN+', '')+ shortcutToText(pMacros[i].hk);
     if pMacros[i].sw then
       HKitem.s[2] := getTranslation( 'Yes' )
      else
       HKitem.s[2] := getTranslation( 'No');
//    grid.cells[2,i+1]:=macroopcodeName(macros[i].opcode);}
    end;
  HKTree.EndUpdate;
end; // fillMacrosGrid

function ThotkeysFr.winkey():integer;
begin result:=ifThen(winkeyChk.Checked,$1000) end;

procedure ThotkeysFr.saveBtnClick(Sender: TObject);
begin
  if actionBox.itemIndex < 0 then Exit;
addMacro(hotkey.hotkey+winkey(), swChk.checked, actionBox.itemIndex+1);
fillMacrosGrid(macros);
//grid.row:=grid.rowCount-1;
end;

procedure ThotkeysFr.deleteBtnClick(Sender: TObject);
begin
  if HKTree.SelectedCount = 1 then
   if removeMacro(HKTree.GetFirstSelected.Index) then
    begin
      HKTree.DeleteSelectedNodes;
//      HKTree.GetNext()
    end;
//  fillMacrosGrid(macros);
end;

procedure ThotkeysFr.replaceBtnClick(Sender: TObject);
//VAR
//  n : PVirtualNode;
begin
  if HKTree.SelectedCount = 1 then
   begin
//     n := HKTree.FocusedNode;
     if removeMacro(HKTree.GetFirstSelected.Index) then
     begin
      addMacro(hotkey.hotkey+winkey(), swChk.checked, actionBox.itemIndex+1);
//    with THKItem(PHKItem(HKTree.getnodedata(HKTree.GetFirstSelected))^) do
//     s0 := macroopcodeName(macros[i].opcode);
//     s1 := IfThen(macros[i].hk and $1000>0, 'WIN+', '')+ shortcutToText(macros[i].hk);
//     s2 := IfThen(macros[i].sw, getTranslation('Yes'), getTranslation('No'));

      fillMacrosGrid(macros);
  //  grid.row:=grid.rowCount-1;
    end;
//     HKTree.fo
   end;
end;

procedure ThotkeysFr.initPage;
var
  i : Integer;
begin
  HKTree.NodeDataSize := SizeOf(THKItem);
//  for i := 0 to HKList.Columns.Count-1 do
//    HKList.Columns.Items[i].Caption :=
//       getTranslation(HKList.Columns.Items[i].Caption);
  actionBox.Items.Clear();
  for i:=succ(OP_none) to OP_last do
    actionBox.items.add(macroopcodeName(i));


  HKTree.width:= Clientwidth - GAP_SIZE2;
  HKTree.left:= GAP_SIZE;
  HKTree.top:= GAP_SIZE;

  hotkey.left:= 75;
  hotkey.width:= Clientwidth - hotkey.left - GAP_SIZE;
  hotkey.top:= HKTree.top + HKTree.Height + GAP_SIZE;

  swChk.left:= hotkey.left;
  swChk.top:= hotkey.top + hotkey.Height + GAP_SIZE;

  winkeyChk.left:= (hotkey.width div 2) + swChk.left;
  winkeyChk.top:= swChk.top;

  actionBox.left:= hotkey.left;
  actionBox.top:= swChk.top + swChk.Height + GAP_SIZE;
  actionBox.width:= hotkey.width;

  btnDefault.top:= actionBox.top + actionBox.Height + GAP_SIZE;
  btnDefault.left:= GAP_SIZE;

  replaceBtn.top:=  btnDefault.top;
  replaceBtn.left:=  Clientwidth - replaceBtn.width - GAP_SIZE;

  deleteBtn.top:=  btnDefault.top;
  deleteBtn.left:=  replaceBtn.left - deleteBtn.width - GAP_SIZE;

  saveBtn.top:=  btnDefault.top;
  saveBtn.left:=  deleteBtn.left - saveBtn.width - GAP_SIZE;

  Label2.top := hotkey.top + 4;
  Label3.top := actionBox.top + 4;
end;

procedure ThotkeysFr.unInitPage;
begin
  HKTree.IterateSubtree(nil, ClearAll, NIL);
  HKTree.Clear;
end;
procedure ThotkeysFr.applyPage;
begin
end;

procedure ThotkeysFr.resetPage;
begin
  fillMacrosGrid(macros);
end;

procedure ThotkeysFr.FrameContextPopup(Sender: TObject; MousePos: TPoint;
  var Handled: Boolean);
begin
  removeSWhotkeys
end;


procedure ThotkeysFr.HKTreeChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
var
  aRow : Integer;
begin
  if node = nil then
    exit;
aRow := node.Index;
if (aRow<0)or(length(macros) < aRow) then exit;
with macros[aRow] do
  begin
  hotkey.hotkey:=hk;
  swChk.checked:=sw;
  winkeyChk.Checked:=hk and $1000>0;
  actionBox.itemIndex:=opcode-1;
  end;
end;

procedure ThotkeysFr.HKTreeDrawNode(Sender: TBaseVirtualTree;
  const PaintInfo: TVTPaintInfo);
begin
{  case PaintInfo.Column of
   0: begin
         if vsSelected in PaintInfo.Node^.States then
          paintinfo.canvas.Font.Color :=clHighlightText
         else
          paintinfo.canvas.Font.Color := clWindowText;
         paintinfo.canvas.textout(PaintInfo.ContentRect.Left,2,
           PHKItem(sender.getnodedata(paintinfo.node))^.s0);
      end;
   1:  begin
         if vsSelected in PaintInfo.Node^.States then
          paintinfo.canvas.Font.Color :=clHighlightText
         else
          paintinfo.canvas.Font.Color := clWindowText;
         paintinfo.canvas.textout(PaintInfo.ContentRect.Left,2,
           PHKItem(sender.getnodedata(paintinfo.node))^.s1);
       end;
   2:  begin
         if vsSelected in PaintInfo.Node^.States then
          paintinfo.canvas.Font.Color :=clHighlightText
         else
          paintinfo.canvas.Font.Color := clWindowText;
         paintinfo.canvas.textout(PaintInfo.ContentRect.Left,2,
           PHKItem(sender.getnodedata(paintinfo.node))^.s2);
       end;
  end;
 }
  if PaintInfo.Column in [0..2] then
  begin
         if vsSelected in PaintInfo.Node^.States then
          paintinfo.canvas.Font.Color :=clHighlightText
         else
          paintinfo.canvas.Font.Color := clWindowText;
         paintinfo.canvas.textout(PaintInfo.ContentRect.Left,2,
           PHKItem(sender.getnodedata(paintinfo.node))^.s[PaintInfo.Column]);
  end;
end;

procedure ThotkeysFr.HKTreeFreeNode(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
var
  HKitem : PHKItem;
begin
     HKitem := HKTree.GetNodeData(Node);
     SetLength(HKitem^.s[0], 0);
     SetLength(HKitem^.s[1], 0);
     SetLength(HKitem^.s[2], 0);
end;

procedure ThotkeysFr.ClearAll(Sender: TBaseVirtualTree; Node: PVirtualNode; Data: Pointer; var Abort: Boolean);
var
  HKitem : PHKItem;
begin
     HKitem := Sender.GetNodeData(Node);
     SetLength(HKitem^.s[0], 0);
     SetLength(HKitem^.s[1], 0);
     SetLength(HKitem^.s[2], 0);
end;

procedure ThotkeysFr.btnDefaultClick(Sender: TObject);
begin
  setlength(macros, 0);
  addMacro(TextToShortCut('ctrl+shift+i'), TRUE, OP_TRAY);
  addMacro(TextToShortCut('ctrl+shift+o'), TRUE, OP_CHAT);
  addMacro(TextToShortCut('ctrl+o'), FALSE, OP_OFFLINECONTACTS);
  addMacro(TextToShortCut('ctrl+g'), FALSE, OP_GROUPS);
  addMacro(TextToShortCut('ctrl+a'), FALSE, OP_AUTOSIZE);
  addMacro(TextToShortCut('ctrl+p'), FALSE, OP_PREFERENCES);
  addMacro(TextToShortCut('alt+i'), FALSE, OP_VIEWINFO);
  addMacro(TextToShortCut('F11'), FALSE, OP_TOGGLEBORDER);
  addMacro(TextToShortCut('F3'), FALSE, OP_HINT);
  addMacro(TextToShortCut('ctrl+shift+m'), FALSE, OP_MAINMENU);
 {$IFDEF RNQ_PLAYER}
  addMacro(TextToShortCut('ctrl+shift+ins'), True, OP_PLR_PLAY);
  addMacro(TextToShortCut('ctrl+shift+home'), True, OP_PLR_PAUSE);
  addMacro(TextToShortCut('ctrl+shift+end'), True, OP_PLR_STOP);
  addMacro(TextToShortCut('ctrl+shift+pgup'), True, OP_PLR_PREV);
  addMacro(TextToShortCut('ctrl+shift+pgdn'), True, OP_PLR_NEXT);
 {$ENDIF RNQ_PLAYER}

  fillMacrosGrid(macros);
end;

end.
