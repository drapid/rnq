unit RegUserFrm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, RnQButtons;

type
  TRegUserDlg = class(TForm)
    FNameEdit: TLabeledEdit;
    LNameEdit: TLabeledEdit;
    OkBtn: TRnQButton;
    TosMemo: TMemo;
    CncBtn: TRnQButton;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

function acceptTOS(var firstName, lastName: String; const title: string; const tos: String = ''): Boolean; OverLoad;
function acceptTOS(const title: String; const tos: String = ''): Boolean; OverLoad;

implementation

{$R *.dfm}

uses
  langLib, globalLib;

function acceptTOS(var firstName, lastName: String; const title: string; const tos: String = ''): Boolean;
var
  frm: TRegUserDlg;
begin
  frm := TRegUserDlg.create(Application);
//  frm.txtBox.MaxLength := maxLength;
  translateWindow(frm);
  {$ifdef CPUX64}
  SetWindowLongPtr(frm.handle, GWLP_HWNDPARENT, 0);
  {$else}
  setwindowlong(frm.handle, GWL_HWNDPARENT, 0);
  {$endif CPUX64}
//  You must not call SetWindowLong with the GWL_HWNDPARENT index to change the parent of a child window.
//  Instead, use the SetParent function.
//  SetParent(frm.handle, 0);
  if title > '' then
//    frm.caption:=getTranslation(title)
    frm.caption := title;
  if tos > '' then
    frm.TosMemo.Lines.Text := tos
   else
    frm.TosMemo.Visible := false;
//   else
     ;
//  frm.txtBox.text := pwd;
//  frm.AllowNull := AllowNull;
  bringForeground := frm.handle;
  // setTopMost(frm, True);
  frm.showModal;
  frm.BringToFront;
  result := frm.ModalResult=mrOk;
  if result then
   begin
    firstName := trim(frm.FNameEdit.text);
    lastName := trim(frm.LNameEdit.text);
   end;
  FreeAndNil(frm);
end; //

function acceptTOS(const title: String; const tos: String = ''): Boolean;
var
  frm: TRegUserDlg;
begin
  frm := TRegUserDlg.create(Application);
//  frm.txtBox.MaxLength := maxLength;
  translateWindow(frm);
  {$ifdef CPUX64}
  SetWindowLongPtr(frm.handle, GWLP_HWNDPARENT, 0);
  {$else}
  setwindowlong(frm.handle, GWL_HWNDPARENT, 0);
  {$endif CPUX64}
//  You must not call SetWindowLong with the GWL_HWNDPARENT index to change the parent of a child window.
//  Instead, use the SetParent function.
//  SetParent(frm.handle, 0);
  if title > '' then
//    frm.caption:=getTranslation(title)
    frm.caption := title;
  if tos > '' then
    frm.TosMemo.Lines.Text := tos
   else
    frm.TosMemo.Visible := false;
//   else
     ;
   frm.FNameEdit.Visible := false;
   frm.LNameEdit.Visible := false;
//  frm.txtBox.text := pwd;
//  frm.AllowNull := AllowNull;
  bringForeground := frm.handle;
  // setTopMost(frm, True);
  frm.showModal;
  frm.BringToFront;
  result := frm.ModalResult=mrOk;
  FreeAndNil(frm);
end; //

end.
