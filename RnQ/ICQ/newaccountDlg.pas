{
This file is part of R&Q.
Under same license
}
unit newaccountDlg;
{$I RnQConfig.inc}

{$IFDEF COMPILER_14_UP}
  {$WEAKLINKRTTI ON}
  {$RTTI EXPLICIT METHODS([]) FIELDS([]) PROPERTIES([])}
{$ENDIF COMPILER_14_UP}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  {$IFNDEF NOT_USE_GDIPLUS}
    RnQGraphics,
  {$ELSE}
    RnQGraphics32,
  {$ENDIF NOT_USE_GDIPLUS}
  StdCtrls,
  RnQProtocol,
  icqv9, RnQDialogs, RnQButtons, ExtCtrls;

type
  TnewaccountFrm = class(TForm)
    L2: TLabel;
    pBox2: TEdit;
    btnGetPicture: TRnQSpeedButton;
    RnQSpeedButton1: TRnQSpeedButton;
    L3: TLabel;
    edWord: TEdit;
    okBtn: TRnQSpeedButton;
    L1: TLabel;
    logBox: TEdit;
    pl: TPanel;
    PBox: TPaintBox;
    procedure edWordChange(Sender: TObject);
    procedure btnGetPictureClick(Sender: TObject);
    procedure RnQSpeedButton1Click(Sender: TObject);
    procedure okBtnClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure PBoxPaint(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure pBox2Change(Sender: TObject);
  public
    newICQ : TicqSession;
    bmp : TRnQBitmap;
//    procedure icqEvent(thisICQ:TicqSession; ev:TicqEvent);
    procedure ProtoEvent(Sender:TRnQProtocol; event:Integer);
  end;

var
  newaccountFrm: TnewaccountFrm;

implementation

uses
  globalLib, RnQLangs, RnQStrings,
  mainDlg, usersDlg, utilLib,
  RnQNet,
//  prefDlg,
  RQUtil, RQGlobal,
  RQThemes,
  ICQConsts, Protocol_ICQ;

{$R *.DFM}

procedure TnewaccountFrm.okBtnClick(Sender: TObject);
begin
{logBox.clear;
if pwdBox.text = '' then
  begin
  msgDlg(getTranslation('You HAVE TO select a password to create a new UIN'),mtError);
  exit;
  end;
newICQ.pwd:=pwdBox.text;
newICQ.connect(TRUE);
pwdBox.enabled:=FALSE;
okBtn.enabled:=FALSE; }
// newICQ.acceptKey:= trim(edWord.text);
 newICQ.sendCreateUIN(trim(edWord.text));
 pBox2.enabled:=true;

end;

procedure TnewaccountFrm.PBoxPaint(Sender: TObject);
//var
//  gr : TGPGraphics;
begin
  if Assigned(Sender) and Assigned(Bmp) then
   begin
    DrawRbmp(TPaintBox(sender).Canvas.Handle, bmp)
{    gr := TGPGraphics.Create(TPaintBox(sender).Canvas.Handle);
//    ia.SetWrapMode(w)
//    with DestRect(Bmp.GetWidth, Bmp.GetHeight,
//                  TPaintBox(sender).ClientWidth, TPaintBox(sender).ClientHeight) do
//     gr.DrawImage(Bmp, Left, Top, Right-Left, Bottom - Top);
     gr.DrawImage(Bmp, 0, 0, Bmp.GetWidth, Bmp.GetHeight);
    gr.Free;}
   end;
end;

procedure TnewaccountFrm.pBox2Change(Sender: TObject);
begin
 btnGetPicture.Enabled := Length(pBox2.Text) > 1;
// okBtn.Enabled := Length(pwdBox.Text) > 1;
end;

// ok

procedure TnewaccountFrm.ProtoEvent(Sender:TRnQProtocol; event:Integer);
//procedure TnewaccountFrm.icqEvent(thisICQ:TicqSession; ev:TicqEvent);
var
//  s:string;
  u : TUID;
  thisICQ:TicqSession;
  i : Integer;
begin
  thisICQ := TicqSession(Sender);
case TicqEvent(event) of
  IE_serverSent: loggaICQPkt('Reg.UIN', WL_serverSent,thisICQ.eventData);
  IE_serverGot: loggaICQPkt('Reg.UIN', WL_serverGot,thisICQ.eventData);
  IE_serverConnected: loggaICQPkt('Reg.UIN', WL_connected, thisICQ.eventAddress);
  IE_serverDisconnected:
    begin
      loggaICQPkt('Reg.UIN', WL_disconnected, thisICQ.eventAddress);
//      if Assigned(icq) and icq.isOnline then
//        icq.sendSNAC(ICQ_SERVICE_FAMILY, 4, #$00#$10);
    end;
  IE_offline: ;//logBox.text:= (getTranslation('Offline'));
  IE_connecting:
    begin
    proxySettings(thisICQ.aProxy, thisICQ.sock);
    logBox.text:= (getTranslation('Connecting'));
    end;
  IE_creatingUIN: logBox.text:= (getTranslation('Connected, creating uin'));
  IE_newUIN:
    begin
//     logBox.text:= (getTranslation('The new UIN is %d',[thisICQ.eventContact.uin]));
     logBox.text:= (getTranslation('The new UID is %s',[thisICQ.eventContact.UID]));
     IOresult;
//     s:=intToStr(thisICQ.eventContact.uin);
     u := thisICQ.eventContact.UID;
     usersFrm.newuser(TicqSession, u);
     i:=findInAvailableUsers(uin2Bstarted);
     if i >= 0 then
      with availableUsers[i] do
       begin
         pwd := thisICQ.pwd;
       end;
   end;
  IE_getImage:
    begin
      edWord.Enabled:= true;
      if thisICQ.eventStream.size > 0 then
      begin
        if not loadPic(TStream(thisICQ.eventStream), Bmp) then
         FreeAndNil(thisICQ.eventStream);
        PBox.Repaint;
      end;
    end;
  IE_error:
    begin
     theme.PlaySound(Str_Error);
     pBox2.enabled:=true;

//    logBox.lines.add(___('icqerror '+icqerror2str[thisICQ.eventError], [thisICQ.eventInt]));
     logBox.text:= (getTranslation(icqerror2str[thisICQ.eventError], [thisICQ.eventInt, thisICQ.eventMsgA]));
     msgDlg(logBox.text, False, mtError);
    end;
  end;
end; // icqEvent

procedure TnewaccountFrm.FormShow(Sender: TObject);
begin
applyTaskButton(self);
{pwdBox.onKeyDown := RnQmain.pwdBoxKeyDown;
newICQ:=TicqSession.create;
newICQ.listener:=icqEvent;
pwdBox.enabled:=TRUE;
//okBtn.enabled:=TRUE;
logBox.clear;}
pBox2.setFocus;
end; // formshow

procedure TnewaccountFrm.FormPaint(Sender: TObject);
begin wallpaperize(canvas) end;

procedure TnewaccountFrm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
 newICQ.free;
 newICQ := NIL;
 FreeAndNil(bmp);
 action:=caFree;
 destroyHandle;
end;

procedure TnewaccountFrm.FormCreate(Sender: TObject);
begin
  bmp := NIL;
  applyTaskButton(self);
  pBox2.onKeyDown := RnQmain.pwdBoxKeyDown;
  newICQ:=TicqSession.create('', SESS_NEW_UIN);
//  newICQ.listener:=icqEvent;
//  newICQ.listener := protoEvent;
  newICQ.SetListener(protoEvent);
  if newICQ.aProxy.addr.host = '' then
    newICQ.aProxy.serv.host := 'login.icq.com';
  if newICQ.aProxy.addr.port <= 0 then
    newICQ.aProxy.serv.port := 5190;
  pBox2.enabled:=TRUE;
  //okBtn.enabled:=TRUE;
//  pwdBox.setFocus;
  btnGetPicture.Enabled := False;
  logBox.clear;
end;

procedure TnewaccountFrm.RnQSpeedButton1Click(Sender: TObject);
//var
//  CnctnPref : TForm;
//  i : Integer;
//  pp : TPrefPage;
begin
  showForm(WF_PREF, 'Connection', vmShort);
end;

procedure TnewaccountFrm.btnGetPictureClick(Sender: TObject);
begin
 if pBox2.text = '' then
  exit;
 logBox.Clear;
 newICQ.disconnect;
 if Assigned(bmp) then
  FreeAndNil(bmp);
// Image.Picture:= nil;
 newICQ.pwd:=pBox2.text;
 CopyProxy(newICQ.aProxy, MainProxy);
//   proxy_http_Enable(newICQ);
//  proxy_http_Enable(newICQ.sock);
 if newICQ.aProxy.serv.host > '' then
   newICQ.loginServerAddr := newICQ.aProxy.serv.host;
 if newICQ.aProxy.serv.port > 0 then
   newICQ.loginServerPort := IntToStr(newICQ.aProxy.serv.port);
// if newICQ.http.enabled then
//   newICQ.loginServerPort := '443'
//  else
//   newICQ.loginServerPort := '5190';
 newICQ.connect;
 pBox2.enabled:=FALSE;
 okBtn.enabled:=FALSE;
end;

procedure TnewaccountFrm.edWordChange(Sender: TObject);
begin
  okBtn.enabled:= trim(edWord.Text)<>'';
end;

end.
