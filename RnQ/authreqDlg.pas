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
unit authreqDlg;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  StdCtrls, RnQButtons, ExtCtrls, Menus,
  RnQProtocol;

{$I RnQConfig.inc}
{$I NoRTTI.inc}

type
  TauthreqFrm = class(TForm)
    Label1: TLabel;
    msgBox: TMemo;
    addmenu: TPopupMenu;
    closeChk: TCheckBox;
    Label2: TLabel;
    AuthBtn: TRnQButton;
    noBtn: TRnQButton;
    reasonBtn: TRnQButton;
    viewinfoBtn: TRnQButton;
    sendBtn: TRnQButton;
    addBtn: TRnQButton;
    procedure authBtnClick(Sender: TObject);
    procedure noBtnClick(Sender: TObject);
    procedure reasonBtnClick(Sender: TObject);
    procedure closeBtnClick(Sender: TObject);
    procedure viewinfoBtnClick(Sender: TObject);
    procedure addBtnClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormPaint(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure closeChkClick(Sender: TObject);
    procedure sendBtnClick(Sender: TObject);
    procedure Label2Click(Sender: TObject);
  public
    contact:TRnQContact;
    constructor doAll(owner_ :Tcomponent; c:TRnQContact; reason:string);
    procedure addcontactAction(sender:Tobject);
  end;

implementation

{$R *.DFM}

uses
  RnQLangs, RQUtil, RDGlobal, RQThemes,
  RnQSysUtils, RnQPics,
  globalLib, utilLib, outboxLib, mainDlg, langLib, chatDlg,
  Protocols_all,
  themesLib, menusUnit;

constructor TauthreqFrm.doAll(owner_ :Tcomponent; c:TRnQContact; reason:string);
begin
inherited create(owner_);
position:=poDefaultPosOnly;
contact:=c;
applyCommonSettings(self);
childWindows.Add(self);

//theme.getPic(PIC_ADD_CONTACT, addBtn.glyph);
//theme.getPic(PIC_INFO, viewinfoBtn.glyph);
label1.caption:=getTranslation('%s asks to add you to his/her contact list.',[c.displayed]);
msgBox.text:=reason;
theme.pic2ico(RQteFormIcon, PIC_AUTH_REQ, icon);
//theme.getIco2(PIC_AUTH_REQ, icon);
closeChk.checked:=closeAuthAfterReply;

translateWindow(self);
showForm(self);
bringForeground:=handle;
end;

procedure TauthreqFrm.authBtnClick(Sender: TObject);
begin
  Proto_Outbox_add(OE_auth, contact);
  if closeAuthAfterReply then
    close;
end;

procedure TauthreqFrm.noBtnClick(Sender: TObject);
begin
  Proto_Outbox_add(OE_authDenied, contact);
  if closeAuthAfterReply then
    close;
end;

procedure TauthreqFrm.reasonBtnClick(Sender: TObject);
begin
//notAvailable;
//exit;
  Proto_Outbox_add(OE_authDenied, contact, 0, msgBox.Text);
  if closeAuthAfterReply then
    close;
end;

procedure TauthreqFrm.closeBtnClick(Sender: TObject);
begin
  close
end;

procedure TauthreqFrm.viewinfoBtnClick(Sender: TObject);
begin
//  viewInfoabout(contact)
  contact.ViewInfo;
end;

procedure TauthreqFrm.addBtnClick(Sender: TObject);
begin
addGroupsToMenu(self, addmenu.items, addcontactAction, True);
with clientToScreen(addBtn.BoundsRect.bottomRight) do
  addmenu.popup(x,y);
end;

procedure TauthreqFrm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
childWindows.remove(self);
action:=caFree;
destroyHandle;
end;

procedure TauthreqFrm.FormPaint(Sender: TObject);
begin
  wallpaperize(canvas)
end;

procedure TauthreqFrm.addcontactAction(sender: Tobject);
begin
  addToRoster(contact, (sender as Tmenuitem).tag)
end;

procedure TauthreqFrm.FormShow(Sender: TObject);
begin
  applyTaskButton(self)
end;

procedure TauthreqFrm.closeChkClick(Sender: TObject);
begin
  closeAuthAfterReply:=closeChk.checked
end;

procedure TauthreqFrm.sendBtnClick(Sender: TObject);
begin
  chatFrm.openOn(contact)
end;

procedure TauthreqFrm.Label2Click(Sender: TObject);
begin
  with closeChk do
    checked:=not checked
end;

end.
