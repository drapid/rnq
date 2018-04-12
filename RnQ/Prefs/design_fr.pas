{
This file is part of R&Q.
Under same license
}
unit design_fr;
{$I RnQConfig.inc}
{$I NoRTTI.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  ActiveX,
  StdCtrls, ExtCtrls, ComCtrls, RDGlobal,
  RnQPrefsInt, RnQPrefsTypes,
  RnQSpin, VirtualTrees;

type
  TdesignFr = class(TPrefFrame)
    plBg: TPanel;
    PageCtrl: TPageControl;
    CommonTab: TTabSheet;
    textureChk: TCheckBox;
    GrBox2: TGroupBox;
    Label20: TLabel;
    Label22: TLabel;
    blinkSlider: TTrackBar;
    Label21: TLabel;
    BlinkPBox: TPaintBox;
    ChkMenuHeight: TCheckBox;
    ShXstInMnuChk: TCheckBox;
    BlnsShowChk: TCheckBox;
    RstrSheet: TTabSheet;
    indentChk: TCheckBox;
    sortbyGrp: TRadioGroup;
    TabSheet2: TTabSheet;
    dockGrp: TRadioGroup;
    italicGrp: TRadioGroup;
    roasterbarGrp: TRadioGroup;
    autosizeGrp: TRadioGroup;
    TtlGrBox: TGroupBox;
    roastertitleBox: TLabeledEdit;
    hideoncloseChk00: TRadioButton;
    TabSheet3: TTabSheet;
    transpGr: TGroupBox;
    Label14: TLabel;
    Label15: TLabel;
    Label1: TLabel;
    Label2: TLabel;
    roastertranspChk: TCheckBox;
    chattranspChk: TCheckBox;
    transpActive: TTrackBar;
    transpInactive: TTrackBar;
    avtTS: TTabSheet;
    AvtShwChtChk: TCheckBox;
    AvtShwHntChk: TCheckBox;
    AvtShwTraChk: TCheckBox;
    ChkExtStsMainMenu: TCheckBox;
    filterbarGrp: TRadioGroup;
    BlinkStsChk: TCheckBox;
    ShowBrdrChk: TCheckBox;
    EyeLevChk: TCheckBox;
    AvtMaxSzChk: TCheckBox;
    AvtMaxSzSpin: TRnQSpinEdit;
    IconsGrp: TGroupBox;
    RnQSpinButton1: TRnQSpinButton;
    IconsList: TVirtualDrawTree;
    aniroasterChk: TCheckBox;
    SingleClickChk: TCheckBox;
    Dock2ChatChk: TCheckBox;
    Label3: TLabel;
    groupsChk: TCheckBox;
    onlyvisibletoChk: TCheckBox;
    onlyonlineChk: TCheckBox;
    UINDelimChk: TCheckBox;
    CntThmChk: TCheckBox;
    ontop1: TCheckBox;
    showcontacttipChk: TCheckBox;
    LangCBox: TComboBox;
    LangLbl: TLabel;
    unAuthShowChk: TCheckBox;
    AutoSzUpChk: TCheckBox;
    procedure transpChange(Sender: TObject);
    procedure transpExit(Sender: TObject);
    procedure IconsListDrawNode(Sender: TBaseVirtualTree;
      const PaintInfo: TVTPaintInfo);
    procedure IconsListFreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure BlinkPBoxPaint(Sender: TObject);
    procedure IconsListDragOver(Sender: TBaseVirtualTree; Source: TObject;
      Shift: TShiftState; State: TDragState; Pt: TPoint; Mode: TDropMode;
      var Effect: Integer; var Accept: Boolean);
    procedure IconsListDragDrop(Sender: TBaseVirtualTree; Source: TObject;
      DataObject: IDataObject; Formats: TFormatArray; Shift: TShiftState;
      Pt: TPoint; var Effect: Integer; Mode: TDropMode);
  private
    { Private declarations }
    procedure fillIconsGrid();
    function ApplyIconsGrid : Boolean;
    procedure ResetIconsGrid;
  public
    procedure initPage(prefs: IRnQPref); Override; final;
    procedure applyPage; Override; final;
    procedure resetPage; Override; final;
    { Public declarations }
   procedure resetAutosize;
   procedure prefToggleShowGroups;
   procedure prefToggleOnlyOnline;
  end;


implementation

uses
  utilLib, RQThemes, themesLib, mainDlg,
  RnQLangs, RnQGlobal,
  roasterLib, RnQConst, globalLib,
  RnQGraphics32, RnQPics
//  ICQContacts
  ;

{$R *.dfm}

type
  PIcItem = ^TIcItem;
  TIcItem = TRnQCLIcons;
//  TIcItem = record
//     s: array[0..1] of string;
//  end;
//  TIcItem = string;
const
  sb2index: array [TsortBy] of integer=(0, 1, 2, 3);

procedure TdesignFr.transpChange(Sender: TObject);
begin
  with (sender as Ttrackbar) do
    if focused then
      applyTransparency(position)
end;

procedure TdesignFr.transpExit(Sender: TObject);
begin applyTransparency() end;


procedure TdesignFr.resetAutosize();
begin
// if prefPages[thisPrefIdx].frame <> NIL then
//  with TdesignFr(prefPages[thisPrefIdx].frame) do
  if not autosizeRoster then
    autosizeGrp.ItemIndex := 0
   else
    if not autosizeFullRoster then
      autosizeGrp.ItemIndex := 1
     else
      autosizeGrp.ItemIndex := 2;
end; // resetAutosize

procedure TdesignFr.prefToggleShowGroups;
begin
// if prefPages[thisPrefIdx].frame <> NIL then
//  with TdesignFr(prefPages[thisPrefIdx].frame) do
    groupsChk.checked := showGroups;
end;

procedure TdesignFr.preftoggleOnlyOnline;
begin
// if prefPages[thisPrefIdx].frame <> NIL then
//  with TdesignFr(prefPages[thisPrefIdx].frame) do
    onlyonlineChk.checked := showOnlyOnline;
end;

procedure TdesignFr.fillIconsGrid();
var
//  i: integer;
  ico: TRnQCLIconsSet;
  icIt: TRnQCLIcons;
  IcItem: PIcItem;
  n: PVirtualNode;
begin
  IconsList.Clear;
// if prefPages[thisPrefIdx].frame = NIL then exit;
  IconsList.BeginUpdate;
//  for i:= Low(RnQCLIcons) to High(RnQCLIcons) do
//  for icIt in RnQCLIcons do
   for ico in SHOW_ICONS_ORDER do
    begin
     icIt := RnQCLIcons[ico];
     n := IconsList.AddChild(nil);
     IcItem := IconsList.GetNodeData(n);
     IcItem.IDX  := icIt.IDX;
     IcItem.Name := gettranslation(icIt.Name);
     IcItem.IconName := icIt.IconName;
     if icIt.IDX = CNT_TEXT then
       begin
         n.CheckType  := ctNone;
         n.CheckState := csCheckedNormal;
//         Include(n.States, vsDisabled);
       end
      else
       begin
         n.CheckType  := ctCheckBox;
         n.CheckState := csCheckedNormal;
       end;
    end;
  IconsList.EndUpdate;
end; // fillIconsGrid

Function TdesignFr.ApplyIconsGrid: Boolean;
var
  IcItem: PIcItem;
  n: PVirtualNode;
  b: Boolean;
begin
  Result := False;
  n := IconsList.GetFirst;
  while n <> NIL do
   begin
     IcItem := IconsList.GetNodeData(n);
     if (SHOW_ICONS_ORDER[n.Index] <> IcItem.IDX) then
      begin
       Result := True;
       SHOW_ICONS_ORDER[n.Index] := IcItem.IDX;
      end;
     if IcItem.IDX <> CNT_TEXT then
       begin
         b := (n.CheckState = csCheckedNormal);
         if (TO_SHOW_ICON[IcItem.IDX] <> b) then
           begin
             Result := True;
             TO_SHOW_ICON[IcItem.IDX] := b;
           end;
       end;
     n := IconsList.GetNext(n);
   end;
end; // ApplyIconsGrid

procedure TdesignFr.ResetIconsGrid;
const
//  csBool: array[false..true] of TCheckState = (csCheckedNormal, csUncheckedNormal);
  csBool: array[Boolean] of TCheckState = (csUncheckedNormal, csCheckedNormal);
var
//  i: integer;
  IcItem: PIcItem;
  n: PVirtualNode;
begin
  n := IconsList.GetFirst;
  IconsList.BeginUpdate;
  while n <> NIL do
   begin
     IcItem := IconsList.GetNodeData(n);
     if IcItem.IDX <> CNT_TEXT then
       n.CheckState := csBool[TO_SHOW_ICON[IcItem.IDX]];
     n := IconsList.GetNext(n);
   end;
  IconsList.EndUpdate;

end; // ResetIconsGrid

procedure TdesignFr.initPage;
begin
  Inherited;
{  with theme.GetPicSize(RQteDefault, PIC_MSG, 10) do
   begin
//    blinkImg.Picture.Bitmap.SetSize(cy, cx);
//    theme.drawPic(blinkImg.picture.Bitmap.Canvas.Handle, 0,0,PIC_MSG);
     BlinkPBox.Width  := cx;
     BlinkPBox.Height := cy;
   end;
}
 {$IFDEF RNQ_FULL}
 {$ELSE}
   ShXstChk.visible := False;
 {$ENDIF}
  GrBox2.width := CommonTab.Clientwidth - GAP_SIZE2;
  sortbyGrp.width := GrBox2.width;
  IconsGrp.Width := GrBox2.width;
  autosizeGrp.left := GAP_SIZE;
  autosizeGrp.width := (CommonTab.Clientwidth - autosizeGrp.left) div 2 - GAP_SIZE;
  //dockGrp.left:= autosizeGrp.left + autosizeGrp.width + GAP_SIZE;
  dockGrp.width := autosizeGrp.width;
  dockGrp.left := GrBox2.width - dockGrp.width + GAP_SIZE;

  italicGrp.top :=  autosizeGrp.top + autosizeGrp.height + GAP_SIZE;
  italicGrp.left := autosizeGrp.left;
  italicGrp.width := autosizeGrp.width;

  roasterbarGrp.top := italicGrp.top;
  roasterbarGrp.left := dockGrp.left;
  roasterbarGrp.width := dockGrp.width div 2 - 2;

  filterbarGrp.top := italicGrp.top;
  filterbarGrp.left := roasterbarGrp.left + roasterbarGrp.width + 4;
  filterbarGrp.width := roasterbarGrp.width;

  TtlGrBox.top := italicGrp.top + italicGrp.height + GAP_SIZE;
  TtlGrBox.left := italicGrp.left;
  TtlGrBox.width := GrBox2.width;

  transpGr.top :=  GAP_SIZE;
  transpGr.left := GAP_SIZE;
  transpGr.width := GrBox2.width;
  IconsList.NodeDataSize := SizeOf(TIcItem);
  fillIconsGrid;

// ѕолучаем список всех кодировок
//  EnumSystemCodePages(
end;

procedure TdesignFr.applyPage;
  function index2sb(i: integer): TsortBy;
  begin
    result := low(TsortBy);
    while result <= high(TsortBy) do
      if i = sb2index[result] then
        exit
      else
        inc(result);
    Result := SB_EVENT;
  end; // index2sb
var
  needApplyTransp,
  needRebuildCL,
  needRepaintCL,
  needUpdCapt: Boolean;
begin
  needApplyTransp := False;
  needRebuildCL := False;
  needRepaintCL := false;

  rosterbarOnTop := roasterbarGrp.ItemIndex=0;
  filterBarOnTop := filterbarGrp.ItemIndex=0;
  animatedRoster := aniroasterChk.checked;

 {$IFDEF RNQ_FULL}
//   showXStatus := ShXstChk.Checked;
   showXStatusMnu := ShXstInMnuChk.Checked;
 {$ENDIF}
  needRepaintCL := ApplyIconsGrid or needRepaintCL;

  if RnQmain.bar.visible <> (roasterbarGrp.itemIndex<>2) then
   begin
//    needRebuildCL := True;
    RnQmain.bar.visible := not RnQmain.bar.visible;
   end;

  if RnQmain.FilterBar.visible <> (filterbarGrp.itemIndex<>2) then
   begin
//    needRebuildCL := True;
    RnQmain.FilterBar.visible := not RnQmain.FilterBar.visible;
   end;

  if sortBy <> index2sb(sortbyGrp.itemIndex) then
   begin
    needRebuildCL := True;
    sortBy := index2sb(sortbyGrp.itemIndex);
   end;

  needRepaintCL := needRepaintCL
                   or (ShowUINDelimiter <> UINDelimChk.Checked)
                   or (rosterItalic <> italicGrp.itemindex)
                   or (showVisAndLevelling <> EyeLevChk.Checked)
                   or (UseContactThemes <> CntThmChk.Checked)
                   or (XStatusAsMain <> ChkExtStsMainMenu.Checked)
                   or (indentRoster <> indentChk.checked)
  ;

  needRebuildCL := needRebuildCL
                   or (showonlyonline <> onlyonlineChk.checked)
                   or (showOnlyImVisibleTo <> onlyvisibletoChk.checked)
                   or (showGroups <> groupsChk.checked)
                   or (showUnkAsOffline <> unAuthShowChk.Checked)
  ;
  needUpdCapt := ShowUINDelimiter <> UINDelimChk.Checked;

  ShowUINDelimiter := UINDelimChk.Checked;
  rosterItalic := italicGrp.itemindex;
  showVisAndLevelling := EyeLevChk.Checked;
//  UseContactThemes := CntThmChk.Checked;
  SetContactsThemeUse(CntThmChk.Checked);
  showonlyonline:=onlyonlineChk.checked;
  showOnlyImVisibleTo:= onlyvisibletoChk.checked;
  showUnkAsOffline   := unAuthShowChk.Checked;
  XStatusAsMain    := ChkExtStsMainMenu.Checked;
  showGroups:=groupsChk.checked;
  indentRoster:=indentChk.checked;

  needUpdCapt := needUpdCapt or (rosterTitle <> roasterTitleBox.Text);
  rosterTitle := roasterTitleBox.Text;

  blinkSpeed  := blinkSlider.position;

  RnQmain.roster.ShowHint := showcontacttipChk.Checked;
  texturizedWindows := textureChk.checked;
  case autosizeGrp.ItemIndex of
    0: autosizeRoster:=FALSE;
    1:begin
      autosizeRoster := TRUE;
      autosizeFullRoster := FALSE;
      end;
    2:begin
      autosizeRoster := TRUE;
      autosizeFullRoster := TRUE;
      end;
    end;
  autosizeUp := AutoSzUpChk.Checked;
  if showMainBorder <> ShowBrdrChk.Checked then
   begin
    showMainBorder := ShowBrdrChk.Checked;
    toggleMainfrmBorder(True, showMainBorder);
   end;
  alwaysOnTop := ontop1.checked;

  useSingleClickTray := SingleClickChk.Checked;

  needApplyTransp := needApplyTransp or (transparency.forRoster <> roastertranspChk.checked)
                      or (transparency.forChat<>chattranspChk.checked)
                      or (transparency.active<>transpActive.position)
                      or (transparency.inactive<>transpInactive.position);
  transparency.forRoster := roastertranspChk.checked;
  transparency.forChat := chattranspChk.checked;
  transparency.active := transpActive.position;
  transparency.inactive := transpInactive.position;

  MenuHeightPerm   := ChkMenuHeight.Checked;
//  MenuDrawExt    := ChkExtDrawMenu.Checked;
  blinkWithStatus  := BlinkStsChk.Checked;
  showBalloons     := BlnsShowChk.Checked;

  avatarShowInChat  := AvtShwChtChk.Checked;
  avatarShowInHint  := AvtShwHntChk.Checked;
  avatarShowInTray  := AvtShwTraChk.Checked;
  TipsMaxAvtSizeUse := AvtMaxSzChk.Checked;
  TipsMaxAvtSize    := AvtMaxSzSpin.AsInteger;

  docking.enabled  := dockGrp.itemIndex>0;
  docking.appBar   := dockGrp.itemIndex=2;
  dockSet;

  docking.Dock2Chat := Dock2ChatChk.Checked;

  applyDocking;

  if needApplyTransp then applyTransparency;

  if needUpdCapt then RnQmain.updateCaption;

  setRosterAnimation(animatedRoster);
  RnQmain.formresize(self);

  if needRebuildCL then
    rosterRebuildDelayed := TRUE
   else
  if needRepaintCL then
    rosterRepaintDelayed := TRUE;
end;

procedure TdesignFr.BlinkPBoxPaint(Sender: TObject);
begin
  theme.drawPic(TPaintBox(Sender).Canvas.Handle, 0,0, PIC_MSG, True, getParentCurrentDPI);
//  theme.drawPic(blinkImg.picture.Bitmap.Canvas.Handle, 0,0,PIC_MSG);
end;

procedure TdesignFr.resetPage;
begin

  resetAutosize();
  AutoSzUpChk.Checked := autosizeUp;
{  onlycloseChk.checked := TRUE;
  hideoncloseChk.Checked := True;//hideOnClose;
  closeandminChk.checked := showRosterMinButton;
  roundwindowsChk.Checked := roundedWindows;}
  roasterTitleBox.Text := rosterTitle;
  if not RnQmain.bar.visible then
    roasterbarGrp.ItemIndex:=2
   else
    if rosterbarOnTop then
      roasterbarGrp.ItemIndex:=0
     else
      roasterbarGrp.ItemIndex:=1;
  if not RnQmain.FilterBar.visible then
    FilterBarGrp.ItemIndex:=2
   else
    if FilterBarOnTop then
      FilterBarGrp.ItemIndex := 0
     else
      FilterBarGrp.ItemIndex := 1;
  showcontacttipChk.Checked := RnQmain.roster.ShowHint;
  aniroasterChk.checked := animatedRoster;
  UINDelimChk.Checked   := ShowUINDelimiter;
  italicGrp.itemindex   := rosterItalic;
 {$IFDEF RNQ_FULL}
  ShXstInMnuChk.Checked := showXStatusMnu;
 {$ENDIF}
  ResetIconsGrid;

  EyeLevChk.Checked    := showVisAndLevelling;
  blinkSlider.position := blinkSpeed;
  BlinkStsChk.Checked    := blinkWithStatus;
  if not docking.enabled then
    dockGrp.itemIndex := 0
  else
    if not docking.appBar then
      dockGrp.itemIndex := 1
    else
      dockGrp.itemIndex := 2;
  Dock2ChatChk.Checked := docking.Dock2Chat;

  sortbyGrp.itemIndex    := sb2index[sortBy];
  ShowBrdrChk.Checked    := showMainBorder;
  groupsChk.checked      := showGroups;
  indentChk.checked      := indentRoster;
  onlyonlineChk.checked  := showonlyonline;
  onlyvisibletoChk.checked := showOnlyImVisibleTo;
  unAuthShowChk.Checked  := showUnkAsOffline;
  ontop1.checked         := alwaysOnTop;
  SingleClickChk.Checked := useSingleClickTray;

  roastertranspChk.checked := transparency.forRoster;
  chattranspChk.checked  := transparency.forChat;
  transpActive.position  := transparency.active;
  transpInactive.position  := transparency.inactive;
  textureChk.checked     := texturizedWindows;
  ChkMenuHeight.Checked  := MenuHeightPerm;
//  ChkExtDrawMenu.Checked := MenuDrawExt;
  ChkExtStsMainMenu.Checked := XStatusAsMain;
  BlnsShowChk.Checked    := showBalloons;
  CntThmChk.Checked      := UseContactThemes;

  AvtShwChtChk.Checked := avatarShowInChat;
  AvtShwHntChk.Checked := avatarShowInHint;
  AvtShwTraChk.Checked := avatarShowInTray;
  AvtMaxSzChk.Checked  := TipsMaxAvtSizeUse;
  AvtMaxSzSpin.AsInteger := TipsMaxAvtSize;
end;

procedure TdesignFr.IconsListDragDrop(Sender: TBaseVirtualTree; Source: TObject;
  DataObject: IDataObject; Formats: TFormatArray; Shift: TShiftState;
  Pt: TPoint; var Effect: Integer; Mode: TDropMode);
var
  Attachmode: TVTNodeAttachMode;
  Nodes: TNodeArray;
  i: Integer;
begin
  if Source = Sender then
    Effect := DROPEFFECT_MOVE
   else
    Exit;
  Nodes := nil;
  // ќпредел€ем, куда добавл€ть узел в зависимости от того, куда была
  // брошена ветка.
  case Mode of
   dmAbove:
    AttachMode := amInsertBefore;
   dmOnNode:
//    AttachMode := amAddChildLast;
// —уЄм после строки!!!
    AttachMode := amInsertAfter;
   dmBelow:
    AttachMode := amInsertAfter;
   else
    AttachMode := amNowhere;
  end;
//  if DataObject = nil then
  // ” нас точно известно, что !!!!Source = Sender!!!!
  if 1=1 then
    begin
// ≈сли не пришло интерфейса, то вставка проходит через VCL метод
     begin
      // ¬ставка из VT. ћожем спокойно пользоватьс€ его методами
      // копировани€ и перемещени€.
//      DetermineEffect;
      // ѕолучаем список узлов, которые будут участвовать в Drag&Drop
      Nodes := Sender.GetSortedSelection(True);
      // » работаем с каждым
      if Effect = DROPEFFECT_COPY then
        begin
         for i := 0 to High(Nodes) do
          Sender.CopyTo(Nodes[i], Sender.DropTargetNode, AttachMode, False);
        end
       else
        for i := 0 to High(Nodes) do
          Sender.MoveTo(Nodes[i], Sender.DropTargetNode, AttachMode, False);
     end
    end
   else
    begin
// OLE drag&drop.
// Effect нужен дл€ передачи его источнику drag&drop, чтобы тот решил
// что он будет делать со своими перетаскиваемыми данными.
// Ќапример, при DROPEFFECT_MOVE (перемещение) их нужно будет удалить,
// при копировании - сохранить.
      if Source is TBaseVirtualTree then
//        DetermineEffect
       else
        begin
         if Boolean(Effect and DROPEFFECT_COPY) then
           Effect := DROPEFFECT_COPY
          else
           Effect := DROPEFFECT_MOVE;
        end;
//      InsertData(Sender as TVirtualStringTree, DataObject, Formats, Effect, AttachMode);
    end;
//  IcItem := PIcItem(sender.getnodedata(paintinfo.node));
end;

procedure TdesignFr.IconsListDragOver(Sender: TBaseVirtualTree; Source: TObject;
  Shift: TShiftState; State: TDragState; Pt: TPoint; Mode: TDropMode;
  var Effect: Integer; var Accept: Boolean);
begin
  Accept := Source = Sender;
  if Accept then
    Effect := DROPEFFECT_MOVE
end;

procedure TdesignFr.IconsListDrawNode(Sender: TBaseVirtualTree;
  const PaintInfo: TVTPaintInfo);
var
//  x, y: Integer;
  IcItem: PIcItem;
  oldMode: Integer;
  gR: TGPRect;
begin
//  if PaintInfo.Column in [0..0] then
  begin
//     if vsSelected in PaintInfo.Node^.States then
//       paintinfo.canvas.Font.Color := clHighlightText
//      else
       paintinfo.canvas.Font.Color := clWindowText;
     gR.X := PaintInfo.ContentRect.Left;
     gR.Y := 0;
     gr.Height := PaintInfo.ContentRect.Bottom - PaintInfo.ContentRect.Top;
     gr.Width  := gr.Height;
     IcItem := PIcItem(sender.getnodedata(paintinfo.node));
//     inc(x, theme.drawPic(paintinfo.canvas.Handle, x,y+1, IcItem.IconName).cx+2);
     inc(gR.x, theme.drawPic(paintinfo.canvas.Handle, gR, IcItem.IconName, True, GetParentCurrentDpi).cx+2);

     oldMode := SetBKMode(paintinfo.canvas.Handle, TRANSPARENT);
      paintinfo.canvas.textout(gR.x, 2, IcItem.Name);
     SetBKMode(paintinfo.canvas.Handle, oldMode);
  end;
end;

procedure TdesignFr.IconsListFreeNode(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
begin
  with TIcItem(PIcItem(Sender.getnodedata(Node))^) do
   begin
     Name := '';
     IconName := '';
   end;
end;

end.
