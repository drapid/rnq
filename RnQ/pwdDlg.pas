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
unit pwdDlg;
{$I RnQConfig.inc}
{$I NoRTTI.inc}
  { $DEFINE USE_TKB}
interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
 {$IFDEF USE_TKB}
  AdvTouchkeyboard,
 {$ENDIF USE_TKB}
  StdCtrls, RnQButtons;

type
  TmsgFrm = class(TForm)
    txtBox: TEdit;
    Label1: TLabel;
    okBtn: TRnQButton;
    KBBtn: TRnQSpeedButton;
    procedure txtBoxKeyPress(Sender: TObject; var Key: Char);
    procedure okBtnClick(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure KBBtnClick(Sender: TObject);
   public
 {$IFDEF USE_TKB}
    tkb: TAdvPopupTouchKeyBoard;
 {$ENDIF USE_TKB}
    result_uin: integer;
    exitCode: (EC_enter, EC_cancel);
    AllowNull: Boolean;
  end;

implementation

uses
  globalLib, utilLib, mainDlg,
  RnQSysUtils, RnQPics,
  RQUtil, RDGlobal, RQThemes, themesLib, RnQLangs;

{$R *.DFM}

procedure TmsgFrm.txtBoxKeyPress(Sender: TObject; var Key: Char);
begin
case key of
  #27:
    begin
    close;
    key := #0;
    end;
  #13:
    begin
    okBtnClick(self);
    key := #0;
    end;
  end;
end; // keypress

procedure TmsgFrm.okBtnClick(Sender: TObject);
begin
  if (trim(txtBox.text) = '') and not AllowNull then
   exit;
  tag := 1;
  exitCode := EC_enter;
  close;
end;

procedure TmsgFrm.FormPaint(Sender: TObject);
//var
// r : TRect;
begin
// Canvas.
//  R := Canvas.ClipRect;
  if not GlassFrame.FrameExtended then
    wallpaperize(canvas)
end;

procedure TmsgFrm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
//destroyHandle;
// Action := caHide;
 Action := caFree;
 {$IFDEF USE_TKB}
  FreeAndNil(tkb);
 {$ENDIF USE_TKB}
end;

procedure TmsgFrm.FormCreate(Sender: TObject);
begin
 theme.pic2ico(RQteFormIcon, PIC_KEY, icon);
 Self.DoubleBuffered := True;
 txtBox.DoubleBuffered := True;
// okBtn.DoubleBuffered := True;
 {$IFDEF USE_TKB}
  tkb := NIL;
 {$ELSE USE_TKB}
  KBBtn.Visible := False;
 {$ENDIF USE_TKB}
 AllowNull := false;
 exitCode := EC_cancel;
end;

procedure TmsgFrm.FormShow(Sender: TObject);
begin
//  Caption := getTranslation('Password') + ' (' + RnQUser + ')';
  txtBox.onKeyDown := RnQmain.pwdBoxKeyDown;
  applyTaskButton(self);
//  okBtn.DoubleBuffered := True;
//  Label1.do
end;

procedure TmsgFrm.KBBtnClick(Sender: TObject);
begin
 {$IFDEF USE_TKB}
  if not Assigned(tkb) then
    tkb := TAdvPopupTouchKeyBoard.Create(Self);
//  tkb.Keyboard.
  tkb.Show;
//  tkb.
 {$ENDIF USE_TKB}
end;

end.
