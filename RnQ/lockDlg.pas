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
unit lockDlg;
{$I RnQConfig.inc}
{$I NoRTTI.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  StdCtrls, ExtCtrls,
  RnQButtons, RnQDialogs;

type
  TlockFrm = class(TForm)
    Label1: TLabel;
    pwdBox: TEdit;
    OkBtn: TRnQButton;
    QuitBtn: TRnQButton;
    PaintBox1: TPaintBox;
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure OkBtnClick(Sender: TObject);
    procedure QuitBtnClick(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    { Private declarations }
//  public procedure destroyHandle;
  end;

var
  lockFrm: TlockFrm;

implementation

{$R *.DFM}

uses
 {$IFDEF UNICODE}
   AnsiStrings,
 {$ENDIF UNICODE}
  RDGlobal,
  globalLib, UtilLib, RnQLangs, RQUtil, RnQSysUtils, RnQCrypt,
  ICQv9,
  iniLib,
  mainDlg, chatDlg;

procedure TlockFrm.FormShow(Sender: TObject);
begin
pwdBox.onKeyDown:=RnQmain.pwdBoxKeyDown;
applyTaskButton(self);
if formVisible(RnQmain) then
  RnQmain.toggleVisible;
chatFrm.close;
locked:=TRUE;
if not startingLock then
//  saveCFG;  // eventually delete password from file
  saveCfgDelayed := True;
//tipFrm.hide();
bringForeground:=handle;
pwdBox.Text:='';
pwdBox.SetFocus();
end;

procedure TlockFrm.OkBtnClick(Sender: TObject);
var
  sA : AnsiString;
  rr : Boolean;
begin
  if AccPass > '' then
    rr := compareText(AccPass, pwdBox.text) = 0
   else
    begin
      if LoginMD5 and  Account.AccProto.saveMD5Pwd then
        sA := MD5Pass(pwdBox.text)
       else
        sA := pwdBox.text;
      rr := compareText(sA, Account.AccProto.pwd) = 0;
    end;
if rr then
  begin
  locked:=FALSE;
  if not startingLock then
//    saveCFG;
    saveCfgDelayed := True;
  close
  end
else
  msgDlg('The password you entered is incorrect', True, mtError);
end;

procedure TlockFrm.QuitBtnClick(Sender: TObject);
begin
  ModalResult := mrAbort;
  RnQmain.close;
end;

procedure TlockFrm.FormPaint(Sender: TObject);
begin
  wallpaperize(canvas)
end;

procedure TlockFrm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  ModalResult := mrOk;
  Action := caFree;
  destroyHandle;
  lockFrm := nil;
end;

procedure TlockFrm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if locked then
    CanClose := False
   else
    CanClose := True;
end;

//procedure TlockFrm.destroyHandle; begin inherited end;

procedure TlockFrm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_RETURN then
    OkBtnClick(nil);
end;

end.
