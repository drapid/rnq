unit xmpp_fr;

interface
{$I RnQConfig.inc}
{$I NoRTTI.inc}

uses 
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  StdCtrls,
  RnQPrefsInt, RnQPrefsTypes,
  RDGlobal, ExtCtrls, RnQSpin,
  XMPPv1, ComCtrls;

type
  TxmppFr = class(TPrefFrame)
    PageControl1: TPageControl;
    TS1: TTabSheet;
    PrtySpin: TRnQSpinEdit;
    SrvEdit: TLabeledEdit;
    LPr: TLabel;
    TSSecurity: TTabSheet;
    Label23: TLabel;
    pwdBox: TEdit;
    SSLChk: TCheckBox;
    ServerCBox: TComboBox;
    portBox: TLabeledEdit;
  private
    { Private declarations }
    fXMPP: TXMPPSession;
  public
//    procedure initProps;
    procedure initPage(prefs: IRnQPref); Override; final;
    procedure applyPage; Override; final;
    procedure resetPage; Override; final;
//    procedure updateVisible;
    { Public declarations }
  end;

implementation

{$R *.dfm}

uses
   RnQProtocol, globalLib;

procedure TxmppFr.initPage;
var
  I: Integer;
//  Acc: PRnQAccount;
begin
  Inherited;
(* {$IFDEF PREF_IN_DB}
  if fAccIDX in [Low(main.Accounts)..High(main.Accounts)] then
    Acc := @main.Accounts[fAccIDX]
   else
    Acc := NIL;
 {$ELSE ~PREF_IN_DB}
   Acc := @Account;
 {$ENDIF PREF_IN_DB}
  fXMPP := NIL;
  if not Assigned(Acc)
    or (Acc.AccProto.ProtoID <> XMPProtoID) then
    Exit;
  fXMPP := TXMPPSession(Acc.AccProto);
*)
  fXMPP := TXMPPSession(Account.AccProto);
end;

//procedure initProps;
procedure TxmppFr.applyPage;
begin
  if Assigned(fXMPP)and
     (fXMPP.ProtoID = XMPProtoID) then
    begin
      fXMPP.ServerJID := SrvEdit.Text;

      fXMPP.pwd := pwdBox.text;
      fXMPP.fPriority := PrtySpin.AsInteger;
    end;
end;

procedure TxmppFr.resetPage;
begin
  if Assigned(fXMPP)and
     (fXMPP.ProtoID = XMPProtoID) then
    begin
      SrvEdit.Text := fXMPP.ServerJID;
      pwdBox.text  := fXMPP.pwd;
      PrtySpin.AsInteger := fXMPP.fPriority;
    end;
end;

//INITIALIZATION
//  AddPrefPage(2, TxmppFr, 'XMPP');
end.
