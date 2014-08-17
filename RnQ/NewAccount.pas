{
This file is part of R&Q.
Under same license
}
unit NewAccount;

{$I Compilers.inc}
{$I RnQConfig.inc}
{$I NoRTTI.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  StdCtrls, RnQButtons,
  RnQprotocol;

type
  TNewAccFrm = class(TForm)
    AccCBox: TComboBox;
    L1: TLabel;
    AccEdit: TEdit;
    Label1: TLabel;
    OkBtn: TRnQButton;
    CnclBtn: TRnQButton;
    procedure FormCreate(Sender: TObject);
    procedure AccCBoxCloseUp(Sender: TObject);
    procedure OkBtnClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    function getProto : TRnQProtoClass;
  end;

//var
//  NewAccFrm: TNewAccFrm;

implementation

{$R *.dfm}

uses
   Protocols_all,
   RDGlobal, RQUtil, RnQLangs, RnQDialogs;

procedure TNewAccFrm.AccCBoxCloseUp(Sender: TObject);
begin
  if AccEdit.Visible then
    ActiveControl := AccEdit;
end;

procedure TNewAccFrm.FormCreate(Sender: TObject);
var
//  s : String;
  b : Byte;
begin
 {$IFNDEF ICQ_ONLY}
  for b in cUsedProtos do
    AccCBox.AddItem(cProtosDesc[b], NIL);
 {$ELSE ICQ_ONLY}
    AccCBox.AddItem('ICQ', NIL);
    AccCBox.AddItem('AIM', NIL);
 {$ENDIF ICQ_ONLY}
  AccCBox.ItemIndex := 0;
  if AccCBox.Items.Count <=1 then
    AccCBox.Enabled := false;
end;

function TNewAccFrm.getProto: TRnQProtoClass;
//type
//  ff = array [cUsedProtos] of byte;
var
  i : Integer;
begin
 {$IFNDEF ICQ_ONLY}
  i := AccCBox.ItemIndex;
  if i in [Byte(Low(cUsedProtos))..Byte(High(cUsedProtos))] then
    Result := getProtoClass(Byte(cUsedProtos[i]))
//  if i in [Byte(Low(RnQProtos))..Byte(High(RnQProtos))] then
//    Result := RnQProtos[i]
   else
 {$ELSE ICQ_ONLY}
 {$ENDIF ICQ_ONLY}
//    Result := TicqSession;
  {$IFDEF PROTOCOL_ICQ}
    Result := getProtoClass(ICQProtoID)
  {$ELSE ~PROTOCOL_ICQ}
    Result := NIL;
  {$ENDIF PROTOCOL_ICQ}
end;

procedure TNewAccFrm.OkBtnClick(Sender: TObject);
var
  pr : TRnQProtoClass;
begin
  pr := getProto;
  if Assigned(pr) and pr._isValidUid1(AccEdit.Text) then
    ModalResult := mrOk
   else
    begin
      ModalResult := mrNone;
      msgDlg(getTranslation('Not valid user identifier - %s', [AccEdit.Text]), False, mtError);
    end;
end;

end.
