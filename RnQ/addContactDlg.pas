{
This file is part of R&Q.
Under same license
}
unit addContactDlg;
{$I RnQConfig.inc}
{$I NoRTTI.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  ExtCtrls, StdCtrls, Menus,
  RnQProtocol,
  RnQButtons, RnQDialogs;

type
  TaddContactFrm = class(TForm)
    Label1: TLabel;
    uinBox: TLabeledEdit;
    addBtn: TRnQButton;
    LocalChk: TCheckBox;
    procedure FormPaint(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure addBtnClick(Sender: TObject);
    procedure addcontactAction(sender:Tobject);
    procedure FormShow(Sender: TObject);
    procedure uinBoxChange(Sender: TObject);
    procedure uinBoxKeyPress(Sender: TObject; var Key: Char);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    menu: TPopupMenu;
    c: TRnQContact;
    thisProto : TRnQProtocol;
  public
    constructor Create(AOwner: TComponent; proto : TRnQProtocol); reIntroduce;
    procedure DestroyHandle; Override;
  end;

//var
//  addContactFrm: TaddContactFrm;

implementation

uses
  RnQLangs, RQUtil, RDGlobal, RQThemes,
  menusUnit, RnQSysUtils, RnQPics,
  utilLib, globalLib, themesLib, mainDlg, roasterLib;

{$R *.DFM}

procedure TaddContactFrm.FormPaint(Sender: TObject);
begin
  if not GlassFrame.FrameExtended then
    wallpaperize(canvas)
end;

procedure TaddContactFrm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
destroyHandle;
Action := caFree;
end;

procedure TaddContactFrm.FormCreate(Sender: TObject);
begin
  menu := TPopupMenu.Create(Self);
  Self.menu := menu;
end;

procedure TaddContactFrm.FormDestroy(Sender: TObject);
begin
  menu.Free;
end;

procedure TaddContactFrm.addBtnClick(Sender: TObject);
var
//  i: integer;
  uid: TUID;
begin
   uid := TUID(trim(uinBox.text));
//   if not thisProto.validUid(uid) then
   if not thisProto.ValidUid1(uid) then
     msgDlg('Invalid UIN', True, mtError)
    else
     begin
      c := thisProto.getContact(uid);
      if not Assigned(c) then
       begin
        msgDlg('Couldn''t create contact!', True, mtError);
        Exit;
       end;
//  if c=icq.myinfo then
//    msgDlg(getTranslation('Invalid UIN'),mtWarning)
//  else
//      if roasterLib.exists(c) then
      if c.isInRoster then
        begin
         roasterLib.focus(c);
         msgDlg(getTranslation('%s already exists',[uid]), False, mtWarning)
        end
       else
        begin
         addGroupsToMenu(self, menu.items, addcontactAction,
                         LocalChk.Checked or thisProto.canAddCntOutOfGroup);
  //      applyCommonSettings(menu);
         with clientToScreen(addBtn.BoundsRect.bottomRight) do
          menu.popup(x,y);
        end;
  end
end;

procedure TaddContactFrm.addcontactAction(sender:Tobject);
begin
//  if LocalChk.Checked then
  addToRoster(c, (sender as Tmenuitem).tag, LocalChk.Checked);
  close;
  saveListsDelayed := True;
end;

constructor TaddContactFrm.Create(AOwner: TComponent; proto: TRnQProtocol);
begin
  inherited create(AOwner);
  thisProto := proto;
  LocalChk.Enabled := thisProto.isSSCL and thisProto.isOnline;
  LocalChk.Checked := not LocalChk.Enabled;//not (LocalChk.Checked);
end;

procedure TaddContactFrm.destroyHandle;
begin
  inherited
end;

procedure TaddContactFrm.FormShow(Sender: TObject);
begin
//  theme.getPic(PIC_ADD_CONTACT, addBtn.glyph);
  theme.pic2ico(RQteFormIcon, PIC_ADD_CONTACT, icon);
  uinbox.text:='';
  uinbox.setFocus;
  applyTaskButton(self);
end;

procedure TaddContactFrm.uinBoxChange(Sender: TObject);
begin
//  onlydigits(sender)
end;

procedure TaddContactFrm.uinBoxKeyPress(Sender: TObject; var Key: Char);
begin
case key of
  #27: close;
  #13: addBtnClick(self);
  end;
end;

end.
