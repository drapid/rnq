unit ignore_fr;

interface
{$I Compilers.inc}
{$I RnQConfig.inc}

 {$IFDEF COMPILER_14_UP}
  {$WEAKLINKRTTI ON}
  {$RTTI EXPLICIT METHODS([]) FIELDS([]) PROPERTIES([])}
 {$ENDIF COMPILER_14_UP}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  StdCtrls, Menus, RnQButtons, RnQDialogs, GlobalLib;

type
  TignoreFr = class(TPrefFrame)
    ignoreChk: TCheckBox;
    ignoreBox: TListBox;
    PopupMenu: TPopupMenu;
    menuviewinfo: TMenuItem;
    addBtn: TRnQButton;
    removeBtn: TRnQButton;
    procedure ignoreBoxDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure ignoreBoxDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure removeBtnClick(Sender: TObject);
    procedure addBtnClick(Sender: TObject);
    procedure menuviewinfoClick(Sender: TObject);
    procedure ignoreBoxContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
  private
     currentContact : Tcontact;
    { Private declarations }
  public
    procedure applyPage; Override;
    procedure resetPage; Override;
    { Public declarations }
  end;

implementation

uses
  RQGlobal, RQThemes, RnQFileUtil,
  icqv9, 
   utilLib, mainDlg, RQUtil, RnQLangs;

{$R *.dfm}

procedure TignoreFr.ignoreBoxDragDrop(Sender, Source: TObject; X,Y: Integer);
begin addToIgnoreList(clickedContact) end;

procedure TignoreFr.ignoreBoxDragOver(Sender, Source: TObject; X,Y: Integer; State: TDragState; var Accept: Boolean);
begin accept:=source=RnQmain.roaster end;

procedure TignoreFr.removeBtnClick(Sender: TObject);
var
  i:integer;
begin
 for i:=ignoreBox.count-1 downto 0 do
  if ignoreBox.selected[i] then
    ignoreList.remove(ignoreBox.items.objects[i]);
 ignoreBox.deleteSelected;
 saveLists;
end;

procedure TignoreFr.addBtnClick(Sender: TObject);
begin
  msgDlg(getTranslation('for now you can only drag&drop your contacts from the contact-list, sorry'),mtInformation);
end;

procedure TignoreFr.menuviewinfoClick(Sender: TObject);
begin
  viewInfoAbout(currentContact)
end;

procedure TignoreFr.ignoreBoxContextPopup(Sender: TObject;
  MousePos: TPoint; var Handled: Boolean);
var
  i : Integer;
begin
  i := ignoreBox.ItemAtPos(MousePos, True);
  if i >=0 then
   currentContact := Tcontact(ignoreBox.items.objects[i]);
  PopupMenu.Popup(ignoreBox.ClientToScreen(MousePos).X, ignoreBox.ClientToScreen(MousePos).Y)
end;

procedure TignoreFr.applyPage;
var
  i : Integer;
begin
  enableIgnorelist:=ignoreChk.checked;
  Ignorelist.clear;
  with ignoreBox do
    for i:=0 to count-1 do
      Ignorelist.add(items.objects[i]);
  if not saveFile(userPath+ignoreFileName+'.txt', ignorelist.toString, True) then
    msgDlg(getTranslation('Error saving ignore list'),mtError);
end;

procedure TignoreFr.resetPage;
var
  i : Integer;
begin
  addBtn.top:=  clientHeight - GAP_SIZE - addBtn.Height;
  addBtn.left:=  GAP_SIZE;

  removeBtn.top:=  addBtn.top;
  removeBtn.left:=  addBtn.left + addBtn.Width +GAP_SIZE;

  ignoreBox.width:= clientWidth - GAP_SIZE2;
  ignoreBox.height:=  clientHeight - GAP_SIZE2 - ignoreBox.top - addBtn.Height;

  ignoreChk.checked:=enableIgnorelist;
  ignoreBox.clear;
  with ignoreList do
    for i:=0 to count-1 do
      ignoreBox.addItem(getAt(i).displayed,getAt(i));
end;

INITIALIZATION

  AddPrefPage(0, TignoreFr, 'Ignore list');
end.
