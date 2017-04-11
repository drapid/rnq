{
This file is part of R&Q.
Under same license
}
unit plugins_fr;
{$I RnQConfig.inc}
{$I NoRTTI.inc}

interface

uses 
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  StdCtrls,
 {$IFDEF PREF_IN_DB}
  DBPrefsLib,
 {$ELSE ~PREF_IN_DB}
  RnQPrefsLib,
 {$ENDIF PREF_IN_DB}
  RnQButtons, VirtualTrees;

type
  TpluginsFr = class(TPrefFrame)
    Label1: TLabel;
    reloadBtn: TRnQButton;
    prefBtn: TRnQButton;
    PluginsList: TVirtualDrawTree;
    procedure reloadBtnClick(Sender: TObject);
    procedure prefBtnClick(Sender: TObject);
//    procedure listClick(Sender: TObject);
    procedure PluginsListDrawNode(Sender: TBaseVirtualTree;
      const PaintInfo: TVTPaintInfo);
    procedure PluginsListFreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);
  private
    procedure fillPluginsGrid;
  public
    procedure initPage; Override;
    procedure applyPage; Override;
    procedure resetPage; Override;
//    procedure updateVisible;
  end;

implementation

uses
  RnQConst, globalLib, RDGlobal, pluginLib, RnQLangs, RDUtils;//, RQThemes;

{$R *.dfm}

type
  PPlItem = ^TPlItem;
  TPlItem = record
     s : array[0..1] of string;
     Pl : Tplugin;
  end;

procedure TpluginsFr.reloadBtnClick(Sender: TObject);
begin
  plugins.unload;
  plugins.load;
  resetPage;
end;

procedure TpluginsFr.prefBtnClick(Sender: TObject);
var
  n: PVirtualNode;
begin
{with list do
  if ItemIndex >= 0 then
    Tplugin(items.Objects[ItemIndex]).cast_preferences;
}
  n := PluginsList.FocusedNode;
  if n <> NIL then
    PPlItem(PluginsList.GetNodeData(n)).Pl.cast_preferences;
end;

(*
procedure TpluginsFr.listClick(Sender: TObject);
var
  n : PVirtualNode;
begin
{with list do
  if ItemIndex >= 0 then
    fileBox.text:=Tplugin(items.Objects[ItemIndex]).filename;}
  n := PluginsList.FocusedNode;
//  if n <> NIL then
//    fileBox.text:=PPlItem(PluginsList.GetNodeData(n)).Pl.filename;
end;
*)

procedure TpluginsFr.PluginsListDrawNode(Sender: TBaseVirtualTree;
  const PaintInfo: TVTPaintInfo);
var
  PlItem : PPlItem;
  OldMode : Integer;
begin
  if PaintInfo.Column in [0..1] then
  begin
     if vsSelected in PaintInfo.Node.States then
       paintinfo.canvas.Font.Color := clHighlightText
      else
       paintinfo.canvas.Font.Color := clWindowText;
//     x := PaintInfo.ContentRect.Left;
//     y := 0;
     PlItem := PPlItem(sender.getnodedata(paintinfo.node));
//     inc(x, theme.drawPic(paintinfo.canvas.Handle, x,y+1, IcItem.IconName).cx+2);

     oldMode := SetBKMode(paintinfo.canvas.Handle, TRANSPARENT);
      paintinfo.canvas.textout(PaintInfo.ContentRect.Left, 2, PlItem.s[PaintInfo.Column]);
     SetBKMode(paintinfo.canvas.Handle, oldMode);
  end;

end;

procedure TpluginsFr.PluginsListFreeNode(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
begin
 {$WARN UNSAFE_CODE OFF}
  with TPlItem(PPlItem(Sender.getnodedata(Node))^) do
 {$WARN UNSAFE_CODE ON}
//  with PPlItem(Sender.getnodedata(Node)) do
   begin
     s[0] := '';
     s[1] := '';
   end;
end;

procedure TpluginsFr.applyPage;
var
//  i: Integer;
  s, pluginsOn, pluginsOff: String;
  n: PVirtualNode;
begin
//  i:=0;
  pluginsOn:='';
  pluginsOff:='';
  plugins.resetEnumeration;
  n := PluginsList.GetFirst;
  while plugins.hasMore do
    with plugins.getNext do
     begin
      if n <> NIL then
      if n.CheckState = csCheckedNormal then
        begin
        pluginsOn:=pluginsOn+filename+';';
        activate;
        end
      else
        begin
        pluginsOff:=pluginsOff+filename+';';
        disactivate;
        end;
//      inc(i);
      n := PluginsList.GetNext(n);
     end;
  // add to pluginsOff all disabledPlugins that do not appear in the list
  // to remember old disabled plugins
  while disabledPlugins > '' do
    begin
    s := chop(';', disabledPlugins);
    if (s>'') and (0=pos(s,pluginsOn+pluginsOff)) then
      pluginsOff := s+';'+pluginsOff;
    end;
  disabledPlugins := pluginsOff;
end;

procedure TpluginsFr.initPage;
begin
//  theme.getPic(PIC_PREFERENCES, prefBtn.glyph);
//  theme.getPic(PIC_REFRESH, reloadBtn.glyph);
  PluginsList.NodeDataSize := SizeOf(TPlItem);

  PluginsList.width := ClientWidth - GAP_SIZE2;

  reloadBtn.top :=  clientHeight - GAP_SIZE - reloadBtn.Height;
  reloadBtn.left :=  GAP_SIZE;

  prefBtn.top := reloadBtn.top;
  prefBtn.left := reloadBtn.left + reloadBtn.Width + GAP_SIZE;
{
  fileBox.top := reloadBtn.top - GAP_SIZE - fileBox.Height;
  fileBox.left := 60 + GAP_SIZE;
  fileBox.Width := PluginsList.width - 60;
}
  PluginsList.top := Label1.top + Label1.height + GAP_SIZE;
//  PluginsList.height := fileBox.top - PluginsList.top - GAP_SIZE;
  PluginsList.height := reloadBtn.top - GAP_SIZE - PluginsList.top - GAP_SIZE;
end;

procedure TpluginsFr.fillPluginsGrid;
var
//  i: integer;
  PlItem: PPlItem;
  n: PVirtualNode;
  pl: Tplugin;
begin
  PluginsList.Clear;
// if prefPages[thisPrefIdx].frame = NIL then exit;
  PluginsList.BeginUpdate;
  plugins.resetEnumeration;
  while plugins.hasMore do
   begin
     pl:=plugins.getNext;
     n := PluginsList.AddChild(nil);
     PlItem := PluginsList.GetNodeData(n);
     if pl.screenname='' then
       PlItem.s[0] :='('+getTranslation('Filename')+') '+pl.filename
      else
       PlItem.s[0] := pl.screenname;
     PlItem.s[1] := pl.filename;
     PlItem.Pl   := pl; 
     n.CheckType := ctCheckBox;
     if 0=pos(pl.filename, disabledPlugins) then
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

  PluginsList.EndUpdate;
end; // fillPluginsGrid

procedure TpluginsFr.resetPage;
//var
//  pl:Tplugin;
begin

  //ignoreBox.width:= clientWidth - GAP_SIZE2;
  //ignoreBox.height:=  clientHeight - GAP_SIZE2 - ignoreBox.top - addBtn.Height;
{ list.Clear;

plugins.resetEnumeration;
while plugins.hasMore do
  begin
  pl:=plugins.getNext;
  PluginsList.add
  with list do
    begin
    if pl.screenname='' then
      items.add('('+getTranslation('Filename')+') '+pl.filename)
    else
      items.add(pl.screenName);
    items.objects[items.count-1]:=Tobject(pl);
    checked[items.count-1]:= 0=pos(pl.filename, disabledPlugins);
    end;
  end;
}
  fillPluginsGrid;  
end;

end.
