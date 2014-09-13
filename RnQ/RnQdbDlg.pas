{
This file is part of R&Q.
Under same license
}
unit RnQdbDlg;
{$I Compilers.inc}
{$I RnQConfig.inc}
{$I NoRTTI.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Forms,
  ExtCtrls, ComCtrls, VirtualTrees, StdCtrls, Controls, Menus, VTHeaderPopup,
  RQMenuItem, RnQButtons, RnQDialogs
  ;

type
  TRnQdbFrm = class(TForm)
    panel: TPanel;
    GroupBox1: TGroupBox;
    nilChk: TRadioButton;
    removenilhistoriesChk: TCheckBox;
    barPnl: TPanel;
    resizeBtn: TRnQSpeedButton;
    sbar: TStatusBar;
    dbTree: TVirtualDrawTree;
    purgeBtn: TRnQButton;
    reportBtn: TRnQButton;
    VTHPMenu: TVTHeaderPopupMenu;
    procedure dbTreeHeaderClick(Sender: TVTHeader; HitInfo: TVTHeaderHitInfo);
    procedure dbTreeCompareNodes(Sender: TBaseVirtualTree; Node1,
      Node2: PVirtualNode; Column: TColumnIndex; var Result: Integer);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure dbTreeDrawNode(Sender: TBaseVirtualTree;
      const PaintInfo: TVTPaintInfo);
    procedure FormShow(Sender: TObject);
    procedure resizeBtnClick(Sender: TObject);
    procedure reportBtnClick(Sender: TObject);
    procedure purgeBtnClick(Sender: TObject);
    procedure VTHPMenuPopup(Sender: TObject);
  private
    { Private declarations }
    menu : TRnQPopupMenu;
    AddAllToCL, AddToCL : TRQMenuItem;
    panelexpanded : boolean;
    report:string;
    procedure menuPopup(Sender: TObject);
    procedure ViewinfoClick(Sender: TObject);
    procedure addContactActn(sender:Tobject);
    procedure AddALLcontactsToList(Sender: TObject);
    procedure openChat(Sender: TObject);
    procedure deleteC(Sender: TObject);
  public
    procedure updateList;
//    function  currentContact:Tcontact;
    procedure minimizePanel;
    procedure restorePanel;
    { Public declarations }
  end;

var
  RnQdbFrm: TRnQdbFrm;

implementation

{$R *.dfm}

uses
  RnQLangs, RnQStrings, RDUtils,
  RnQSysUtils, RnQPics,
  RQUtil, RDGlobal, RQThemes, RnQMenu, menusUnit,
  RnQProtocol,
  globalLib, chatDlg, utilLib, themesLib,
  ViewHEventDlg,
  icqv9, ICQcontacts,
  Protocol_ICQ, icqConsts;

const
  COLUMN_UID    = 0;
  COLUMN_DISPL  = 1;
  COLUMN_IMP    = 2;
  COLUMN_AVTMD5 = 3;
  COLUMN_BIRTHDAY = 4;
  COLUMN_DAYS2BD  = 5;
  COLUMN_LASTLOG  = 6;

procedure TRnQdbFrm.minimizePanel;
begin
resizeBtn.ImageName := PIC_DOWN;
if not panelExpanded then exit;
resizeBtn.width:= theme.getPicSize(RQteButton, PIC_DOWN).cx+4;
resizeBtn.Repaint;
panel.visible:=FALSE;
height:=height-panel.height;
panelExpanded:=FALSE;
end; // minimizePanel

procedure TRnQdbFrm.restorePanel;
begin
resizeBtn.ImageName := PIC_UP;
if panelExpanded then exit;
resizeBtn.width:= theme.getPicSize(RQteButton, PIC_UP).cx+4;
resizeBtn.Repaint;
height:=height+panel.height;
barPnl.visible:=FALSE;
panel.visible:=TRUE;
barPnl.visible:=TRUE;
panelExpanded:=TRUE;
end; // minimizePanel

procedure TRnQdbFrm.updateList;
var
//  i,j:integer;
  c:TRnQContact;
//  cl:TcontactList;
begin
  if not visible then exit;
  dbTree.Clear;
  dbTree.BeginUpdate;
  with contactsDB, TList(contactsDB) do
   begin
//   dbTree.
    resetEnumeration;
    while hasMore do
      begin
       c := TRnQContact(getNext);
       dbTree.AddChild(nil, c);
      end;
    sbar.simpleText:=getTranslation('contacts in db: %d',[count]);
   end;
  dbTree.EndUpdate;

  dbTree.SortTree(dbTree.Header.SortColumn, dbTree.Header.SortDirection);
end; // updatelist


procedure TRnQdbFrm.purgeBtnClick(Sender: TObject);

  procedure purgeHistories;
  var
    sr:Tsearchrec;
    path:string;
//    uin:integer;
  begin
  if not removenilhistoriesChk.checked then exit;
 {$IFNDEF DB_ENABLED}
  path:= Account.ProtoPath + historyPath;
  if findFirst( path+'*', faAnyfile, sr ) = 0 then
    repeat
    if sr.attr and faDirectory <> 0 then continue;
    try
//      uin:=strToInt(sr.name);
      if unexistant(sr.name) then
        if DeleteFile(path+sr.name) then
          report:=report + getTranslation('history %s deleted',[sr.name])+CRLF
        else
          report:=report+getTranslation(Str_Error)+getTranslation(': cannot delete file ')+sr.name+CRLF;
    except end;
    until findNext(sr) <> 0;
  findClose( SR );
 {$ENDIF ~DB_ENABLED}
  end; // purgeHistories

  procedure purgeContacts;
  var
    c:TRnQcontact;
    s : String;
    i:integer;
    removeIt:boolean;
  begin
  for i:= TList(contactsDB).count-1 downto 0 do
    begin
    c:=contactsDB.getAt(i);
    removeIt:=FALSE;
    if nilChk.checked then removeIt:=unexistant(c.uid);
    removeIt := removeIt and not TCE(c.data^).dontdelete;
    if removeIt then
      begin
        s := c.displayed+' (UIN '+c.uid+')';
        contactsDB.remove(c);
        report:=report+getTranslation('contact %s deleted',[s])+CRLF;
      { The c object should be freed but, since objects are shared, we would
      { need a garbage collector system. since we are talking about few kbytes
      { i think it is fair to send back this to the next quit ;)
      }
      end;
    end;
  end; // purgeContacts

begin
report:=report+'---'+getTranslation('Start')+' '+datetimeToStr(now)+CRLF;
purgeContacts;
updateList;
purgeHistories;
report:=report+'---'+getTranslation('End')+' '+datetimeToStr(now)+CRLF;
reportBtn.Visible:=TRUE;
end;

procedure TRnQdbFrm.reportBtnClick(Sender: TObject);
begin
  viewTextWindow(getTranslation('Report'), report)
end;

procedure TRnQdbFrm.resizeBtnClick(Sender: TObject);
begin
  if panelexpanded then
    minimizePanel
   else
    restorePanel
end;

procedure TRnQdbFrm.FormShow(Sender: TObject);
begin
//  panelexpanded :=
  minimizePanel;
  theme.pic2ico(RQteFormIcon, PIC_DB, icon);
  applyTaskButton(self);
  updateList;
end;

procedure TRnQdbFrm.dbTreeCompareNodes(Sender: TBaseVirtualTree; Node1,
  Node2: PVirtualNode; Column: TColumnIndex; var Result: Integer);
var
 i : Int64;
 c1, c2 : TRnQContact;
 isICQ : Boolean;
begin
 c1 := TRnQcontact(sender.getnodedata(Node1)^);
 c2 := TRnQContact(sender.getnodedata(Node2)^);
 isICQ := (c1 is ticqContact)and(c2 is ticqContact);
 
 case Column of
   COLUMN_UID:
     if TryStrToInt64(c1.UID, i)
      and TryStrToInt64(c2.UID, i) then
       result := compareInt(StrToInt64(c1.UID), StrToInt64(c2.UID))
      else
       result:= CompareText(c1.UID, c2.UID);
   COLUMN_DISPL:
     result:= CompareText(c1.displayed, c2.displayed);
   COLUMN_IMP :
        result:= CompareText(c1.lclImportant, c2.lclImportant);
   COLUMN_AVTMD5 :
       if isICQ then
         result:= CompareText(TICQContact(c1).ICQicon.Hash_safe, TICQContact(c2).ICQicon.Hash_safe)
        else
         result := 0;
   COLUMN_BIRTHDAY :
     Result := CompareDate(c1.GetBDay, c2.GetBDay);
   COLUMN_DAYS2BD  :
     Result := compareInt(c1.Days2BD, c2.Days2BD);
   COLUMN_LASTLOG :
     Result := CompareDate(c1.lastTimeSeenOnline, c2.lastTimeSeenOnline);
 end;
end;

procedure TRnQdbFrm.dbTreeDrawNode(Sender: TBaseVirtualTree;
  const PaintInfo: TVTPaintInfo);
var
  cnv : TCanvas;
  c   : TRnQcontact;
  dd  : tdate;
  i   : SmallInt;
//  x   : Integer;
begin
cnv:=paintinfo.canvas;
c:=TRnQcontact(sender.getnodedata(paintinfo.node)^);
         if vsSelected in PaintInfo.Node^.States then
          cnv.Font.Color :=clHighlightText
         else
          cnv.Font.Color := clWindowText;
if c.fProto.readList(LT_ROSTER).exists(c) then
  cnv.Font.Style := [fsBold]
 else
  cnv.Font.Style := [];
  case PaintInfo.Column of
   COLUMN_UID: // UIN
    cnv.textout(PaintInfo.ContentRect.Left ,2, c.uid);
   COLUMN_DISPL: // Displayed
    cnv.textout(PaintInfo.ContentRect.Left,2, c.displayed);
   COLUMN_IMP: // Important string
    cnv.textout(PaintInfo.ContentRect.Left,2, c.lclImportant);
   COLUMN_AVTMD5: // Avatar MD5
       if c is TICQContact then
         cnv.textout(PaintInfo.ContentRect.Left,2, str2hexU(TICQContact(c).ICQicon.Hash_safe));
   COLUMN_BIRTHDAY:
     begin
       dd := c.GetBDay;
       if dd > 0 then
          cnv.textout(PaintInfo.ContentRect.Left,2, DateToStr(dd));
     end;
   COLUMN_DAYS2BD:
     begin
       i := c.Days2BD;
       if (i >= 0) and (i <1000) then
          cnv.textout(PaintInfo.ContentRect.Left,2, intToStr(i))
//        else
//          cnv.textout(PaintInfo.ContentRect.Left,2, '');
     end;
   COLUMN_LASTLOG :
     begin
       dd := c.lastTimeSeenOnline;
       if dd > 0 then
          cnv.textout(PaintInfo.ContentRect.Left,2, DateTimeToStr(dd));
     end;
  end;
end;

procedure TRnQdbFrm.dbTreeHeaderClick(Sender: TVTHeader; HitInfo: TVTHeaderHitInfo);
begin
  if HitInfo.Button = mbLeft then
  begin
    if HitInfo.Column = Sender.SortColumn then
     if Sender.SortDirection = sdAscending then
      Sender.SortDirection := sdDescending
     else Sender.SortDirection := sdAscending
    else
     Sender.SortColumn := HitInfo.Column;
  end;
end;

procedure TRnQdbFrm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  RnQdbFrm := NIL;
  Action := caFree;
end;

procedure TRnQdbFrm.ViewinfoClick(Sender: TObject);
var
  cnt : TRnQContact;
begin
  with dbTree do
  if focusedNode<>NIL then
    cnt := TRnQContact(getnodedata(focusednode)^);
//  if cnt is TICQContact then
//    viewInfoAbout(TICQContact(cnt));
  cnt.ViewInfo;
end;

procedure TRnQdbFrm.VTHPMenuPopup(Sender: TObject);
begin
  applyCommonSettings(TControl(Sender));
end;

procedure TRnQdbFrm.addContactActn(sender:Tobject);
begin
  with dbTree do
  if focusedNode<>NIL then
    addToRoster(TRnQcontact(getnodedata(focusednode)^), (sender as TRQmenuitem).tag )
end;

procedure TRnQdbFrm.menuPopup(Sender: TObject);
var
 curContact : TRnQcontact;
  I: Integer;
begin
  curContact := NIL;
  with dbTree do
  if focusedNode <> NIL then
   begin
   if (TRnQcontact(getnodedata(focusednode)^) Is TRnQcontact)  then
    curContact := TRnQcontact(getnodedata(focusednode)^);
   end
  else
    curContact := NIL;
  if curContact = nil then
   begin
    for I := 0 to menu.Items.Count - 1 do
      if menu.Items.Items[i] <> AddAllToCL then
        menu.Items.Items[i].Enabled := False;
//    AddToCL.visible:=false;
    Exit;
   end
  else
    for I := 0 to menu.Items.Count - 1 do
      if menu.Items.Items[i] <> AddAllToCL then
        menu.Items.Items[i].Enabled := True;

//if (row>=1) and (row <= contactsDB.count) then
  begin
//  grid.row:=row;
  AddToCL.visible:=Assigned(curContact) and not curContact.fProto.readList(LT_ROSTER).exists(curContact);
  if AddToCL.visible then
    addGroupsToMenu(self, AddToCL, addContactActn, True);
  end;
end;

procedure TRnQdbFrm.AddALLcontactsToList(Sender: TObject);
var
  i:integer;
begin
if messageDlg(getTranslation('Are you sure?'),mtConfirmation,[mbYes,mbNo],0)=mrNo then exit;
with contactsDB, TList(contactsDB) do
  for i:=0 to count-1 do
    addToRoster(TRnQcontact(getAt(i)));
end;

procedure TRnQdbFrm.openChat(Sender: TObject);
begin
  with dbTree do
  if focusedNode<>NIL then
    chatFrm.openOn(TRnQcontact(getnodedata(focusednode)^));
end;

procedure TRnQdbFrm.deleteC(Sender: TObject);
var
//  i : Integer;
  na : TNodeArray;
  n : PVirtualNode;
begin
  na := dbTree.GetSortedSelection(True);
  for n in na do
   begin
//    contactsDB.remove(Tcontact(n.Data));
    contactsDB.remove(TRnQcontact((@n^.Data)^));
   end;
  dbTree.DeleteSelectedNodes

//  grid.
//  for i :=
//  begin result:=Tcontact(grid.objects[0,grid.row]) end;
//  updateList;
end;

procedure TRnQdbFrm.FormCreate(Sender: TObject);
var
// mi : TRQMenuItem;
 i : Integer;
begin
  dbTree.NodeDataSize := SizeOf(TRnQContact);
  menu := TRnQPopupMenu.Create(Self);
  dbTree.PopupMenu := menu;
  menu.OnPopup := menuPopup;
  dbTree.OnDblClick := ViewinfoClick;
  AddToMenu(menu.Items, 'View info',
       PIC_INFO, True, ViewinfoClick);
  AddToCL := AddToMenu(menu.Items, 'Add to contact list',
//       PIC_ADD_CONTACT, false, addContactActn);
       PIC_ADD_CONTACT, false);
  AddAllToCL := AddToMenu(menu.Items, 'Add ALL contacts to the list',
       PIC_ADD_CONTACT, False, AddALLcontactsToList);
  AddToMenu(menu.Items, 'Open chat',
       PIC_MSG, False, openChat);
  AddToMenu(menu.Items, 'Delete',
       PIC_DELETE, False, deleteC);

  panelexpanded := TRUE;
  report := '';
  for i := 0 to dbTree.Header.Columns.Count-1 do
    dbTree.Header.Columns.Items[i].Text :=
      getTranslation(dbTree.Header.Columns.Items[i].Text);
end;

procedure TRnQdbFrm.FormDestroy(Sender: TObject);
var
  i : Integer;
begin
  for i := 0 to menu.Items.Count-1 do
    menu.Items[0].Free;
  menu.Free;
  dbTree.Clear;
end;

end.
