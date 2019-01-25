{
This file is part of R&Q.
Under same license
}
unit MRAsmsDlg;
{$I Compilers.inc}
{$I RnQConfig.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  StdCtrls, ExtCtrls, RnQButtons, RnQProtocol, MRAContacts;

type
  TMRAsmsFrm = class(TForm)
    msgBox: TMemo;
    Label1: TLabel;
    SendBtn: TRnQSpeedButton;
    charsBox: TLabeledEdit;
    delivery_receiptBox: TCheckBox;
    PhoneBox: TComboBox;
    RnQSpeedButton1: TRnQSpeedButton;
    procedure SendBtnClick(Sender: TObject);
    procedure msgBoxChange(Sender: TObject);
  public
//    constructor doAll(owner_ :Tcomponent; msg,dest:string);
    constructor doAll(owner_ :Tcomponent; cnt : TRnQContact; msg:string = '');
  private
    contact : TMRAContact;
  end;

//var
//  smsFrm: TMRAsmsFrm;

implementation

uses
  globalLib, utilLib, langLib, RQGlobal, RQThemes, RQUtil, themesLib,
  MRAv1;

{$R *.dfm}

constructor TMRAsmsFrm.doAll(owner_ :Tcomponent; cnt : TRnQContact; msg:string = '');
begin
  if not Assigned(cnt) or
     not (cnt is TMRAContact)  then
    Exit; 
inherited create(owner_);
position:=poDefaultPosOnly;
  theme.pic2ico(RQteFormIcon, PIC_SMS, icon);
  msgBox.text:=msg;
  contact := TMRAContact(cnt);
translateWindow(self);
showForm(self);
bringForeground:=handle;
msgBoxChange(nil);
end;

procedure TMRAsmsFrm.SendBtnClick(Sender: TObject);
var
//  i : Integer;
  ph : AnsiString;
begin
  ph := PhoneBox.Text;
  if Length(ph) < 7 then
    Exit;
  TMRASession(contact.fProto).sendSMS(contact, ph, msgBox.Text);
// OnlFeature;
// for i := 1 to destBox.Lines.Count do
//  ICQ.sendSMS(destBox.Lines[i], msgBox.Text, delivery_receiptBox.Checked);
end;

procedure TMRAsmsFrm.msgBoxChange(Sender: TObject);
begin
  charsBox.text:=intToStr(length(msgBox.Text));
end;

end.
