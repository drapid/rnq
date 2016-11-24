unit icq_fr;
{$I RnQConfig.inc}
{$I NoRTTI.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  ComCtrls, StdCtrls, ExtCtrls, RnQButtons, RnQSpin, RDGlobal,
  selectcontactsDlg,
  RnQPrefsLib,
  Mask, Menus;

type
  TicqFr = class(TPrefFrame)
    plBg: TPanel;
    O: TPageControl;
    TS1: TTabSheet;
    birthGrp: TRadioGroup;
    bdayBox: TDateTimePicker;
    addedYouChk: TCheckBox;
    clientidChk: TCheckBox;
    webawareChk: TCheckBox;
    visibilityexploitChk: TCheckBox;
    dcGrp: TRadioGroup;
    authNeededChk: TCheckBox;
    AddTrafTB: TTabSheet;
    GBTyping: TGroupBox;
    Label2: TLabel;
    Label3: TLabel;
    ChkSendTyping: TCheckBox;
    MTNIdleSpin: TRnQSpinEdit;
    GBInvis: TGroupBox;
    Label1: TLabel;
    ChkinvisCheck: TCheckBox;
    CheckInvisSpin: TRnQSpinEdit;
    ChkInvisSend: TCheckBox;
    ChkInvisGoOfl: TCheckBox;
    ShwOfflBox: TCheckBox;
    ChkSupInvChk: TCheckBox;
    ChkTyping: TCheckBox;
    SendUTF8Chk: TCheckBox;
    Label4: TLabel;
    ChkIntervSpin: TRnQSpinEdit;
    Label5: TLabel;
    UTF8MsgsChk: TCheckBox;
    ChkInvisRG: TRadioGroup;
    ProtVerCBox: TComboBox;
    AutoReqXStChk: TCheckBox;
    TestWWBtn: TRnQButton;
    SBSelInvisCl: TRnQButton;
    MsgCryptChk: TCheckBox;
    useSSIChk: TCheckBox;
    PrivacyGrp: TRadioGroup;
    AvatarsTS: TTabSheet;
    AvatarGrp: TGroupBox;
    AvtAutLoadChk: TCheckBox;
    AvtAutGetChk: TCheckBox;
    CheckBox1: TCheckBox;
    RnQSpinEdit1: TRnQSpinEdit;
    NotDnlddInfoChk: TCheckBox;
    SupAvtChk: TCheckBox;
    UseLSIChk: TCheckBox;
    ShowInvChk: TCheckBox;
    CapEdit: TMaskEdit;
    CapsPpp: TPopupMenu;
    AddCapsBtn: TRnQButton;
    AddCapsChk: TCheckBox;
    CapsLabel: TLabel;
    FileTrTS: TTabSheet;
    FTPortsEdit: TLabeledEdit;
    SecTS: TTabSheet;
    pwdBox: TEdit;
    Label23: TLabel;
    SaveMD5chk: TCheckBox;
    LoginRG: TRadioGroup;
    AdvMsgChk: TCheckBox;
    XMPPChk: TCheckBox;
    procedure SBSelInvisClClick(Sender: TObject);
    procedure UpdVis1(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure UpdVis(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure AddCapsChkClick(Sender: TObject);
    procedure AddCapsBtnClick(Sender: TObject);
    procedure onCapsMenuClick(Sender: TObject);
    procedure CapEditChange(Sender: TObject);
  private
    { Private declarations }
//   var
    wnd: TselectCntsFrm;
  public
    { Public declarations }
    procedure CloseAction(Sender: Tobject);

    procedure initPage; Override; final;
    procedure unInitPage; Override; final;
    procedure applyPage; Override; final;
    procedure resetPage; Override; final;
    procedure updateVisPage; Override; final;
  end;

implementation

{$R *.dfm}

uses
  utilLib, RnQLangs, RDUtils, RnQCrypt, RnQPics,
  ICQv9, Protocol_ICQ, ICQConsts, RnQProtocol, //contacts,
  RnQMenu, menusUnit, themesLib, globalLib,
  RQUtil, RnQFileUtil, RnQDialogs, mainDlg;

type
  TCapsRec = record
     v: AnsiString;
     S: String;
     pic: TPicName;
   end;
const
  CliCaps : array[0..3] of TCapsRec = (
      (v: '&RQinside'; S: '&RQ'; pic: PIC_CLI_NRQ),
      (v: 'Smaper '; S: 'Smaper'; pic: PIC_CLI_smaper),
      (v: 'PIGEON!'; S: 'Pigeon'; pic: PIC_CLI_pigeon),
      (v: 'SIM client'; S: 'SIM'; pic: PIC_CLI_SIM)
      ) ;
  TypNotifCap = 'Typing Notification';
  ChkInvCap = 'Support invisibility check';
var
  needSaveChkList: Boolean;

procedure TicqFr.initPage;
var
  I: Integer;
begin
  pwdBox.onKeyDown := RnQmain.pwdboxKeyDown;
//  pwdBox.Width := ServerCBox.Width;
  pwdBox.Width := TS1.Clientwidth - GAP_SIZE2 - pwdBox.Left;

  birthGrp.width  := TS1.Clientwidth - GAP_SIZE2;
  birthGrp.Left   := GAP_SIZE;
  dcGrp.left      := GAP_SIZE;
  PrivacyGrp.Left := GAP_SIZE;
  dcGrp.width   := birthGrp.width;
{$IFDEF UseNotSSI}
//  dcGrp.width   := 190;
  LoginRG.width := dcGrp.width;
//  LoginRG.left  := birthGrp.width - LoginRG.width + GAP_SIZE;
  LoginRG.left  := GAP_SIZE;
  LoginRG.Visible := True;
//  OldxStChk.Visible := True;

   useSSIChk.Visible := True;
   UseLSIChk.Visible := True;
{$ELSE}
  LoginRG.Visible := False;
//  OldxStChk.Visible := False;

   useSSIChk.Visible := False;
   UseLSIChk.Visible := False;
{$ENDIF UseNotSSI}

  PrivacyGrp.Top := dcGrp.top + dcGrp.height + GAP_SIZEd2;
  PrivacyGrp.Width := birthGrp.width;

//  birthGrp.top:=  dcGrp.top + dcGrp.height + GAP_SIZE;
  birthGrp.top := PrivacyGrp.top + PrivacyGrp.height + GAP_SIZEd2;
  bdayBox.top  := birthGrp.top + birthGrp.height - bdayBox.height - GAP_SIZEd2;

  GBTyping.width :=  birthGrp.width;
  GBInvis.width  :=  birthGrp.width;
  AvatarGrp.Width := birthGrp.width;

  GBTyping.Caption := '   ' + getTranslation(TypNotifCap);
  GBInvis.Caption := '   ' + getTranslation(ChkInvCap);

  bdayBox.Format := getTranslation('MMMM d');
  {$IFDEF RNQ_FULL}
  {$ELSE}
//   TabSheet2.TabVisible := false;
  {$ENDIF}
  webawareChk.Width := TestWWBtn.Left - webawareChk.Left - 5;
  ShwOfflBox.Width := GBInvis.Width - 10;

  for I := 0 to Length(CliCaps) - 1 do
    AddToMenu(CapsPpp.Items, dupAmperstand(CliCaps[i].S), CliCaps[i].pic, false,
              onCapsMenuClick, false).Tag := i;
end;

procedure TicqFr.unInitPage;
begin
  clearMenu(CapsPpp.Items);
end;

procedure TicqFr.AddCapsBtnClick(Sender: TObject);
begin
//  with TRnQButton(Sender).BoundsRect do
//    with ClientToScreen(point(left,bottom)) do
  with mousePos do
		  CapsPpp.Popup(X,Y)
end;

procedure TicqFr.onCapsMenuClick(Sender: TObject);
var
  s : RawByteString;
begin
//  with TRnQButton(Sender).BoundsRect do
//    with ClientToScreen(point(left,bottom)) do
//  with mousePos do
//		  CapsPpp.Popup(X,Y)
  s := cliCaps[TMenuItem(Sender).Tag].v;
//  CapEdit.Text := str2hex(s, ' ');
  CapEdit.Text := str2hexU(s);
//  CapEdit.EditText := str2hex(s);
end;

procedure TicqFr.CapEditChange(Sender: TObject);
begin
  CapsLabel.Caption := hex2StrU(CapEdit.Text);
end;



procedure TicqFr.AddCapsChkClick(Sender: TObject);
begin
  updateVisPage;
end;

procedure TicqFr.applyPage;
var
  mustUpdPerms,
  mustUpdPerms2,
  mustUpdSts,
  mustUpdCaps: Boolean;
//  tempStatus: byte;
  fICQ: TICQSession;
  i, l: Integer;
begin
  if not Assigned(Account.AccProto)
    or (Account.AccProto.ProtoName <> 'ICQ') then
    Exit;
  fICQ := TICQSession(Account.AccProto.ProtoElem);

  if (fICQ.saveMD5Pwd <> SaveMD5chk.Checked) then
   begin
     fICQ.saveMD5Pwd   := SaveMD5chk.Checked;
     if fICQ.saveMD5Pwd then
//       pwdBox.text := MD5Pass(pwdBox.text)
       pwdBox.text := '                '// MD5Pass(pwdBox.text)
      else
       pwdBox.text := '';
   end;
  if not fICQ.saveMD5Pwd then
     fICQ.pwd := pwdBox.text;

//    fICQ.loginServerPort := portBox.text;
  mustUpdCaps  := False;
  mustUpdSts   := False;
  mustUpdPerms := False;
  mustUpdPerms2 := false;
//  sendInterests := sendInterChk.Checked;
  if sendBalloonOn<>birthGrp.itemindex then
  begin
    sendBalloonOn := birthGrp.itemindex;
    fICQ.applyBalloon;
    mustUpdSts := True;
  end;
  sendBalloonOnDate:=bdayBox.Date;
  case dcGrp.ItemIndex of
    0: if fICQ.DCmode <> DC_NONE then begin mustUpdSts :=True; fICQ.DCmode:=DC_NONE; end;
    1: if fICQ.DCmode <> DC_ROSTER then begin mustUpdSts :=True; fICQ.DCmode:=DC_ROSTER; end;
    2: if fICQ.DCmode <> DC_EVERYONE then begin mustUpdSts :=True; fICQ.DCmode:=DC_EVERYONE; end;
    3: if fICQ.DCmode <> DC_FAKE then begin mustUpdSts :=True; fICQ.DCmode:=DC_FAKE; end;
   end;
  if fICQ.showclientid<>clientidChk.checked then
   begin
    fICQ.showclientid := clientidChk.checked;
    mustUpdSts := True;
   end;
  if (AddCapsChk.Checked <> AddExtCliCaps) then
   begin
    AddExtCliCaps := AddCapsChk.Checked;
    mustUpdCaps   := True;
   end;
  if (ExtClientCaps <> hex2StrU(CapEdit.Text)) then
   begin
    if Length(CapEdit.Text) > 2 then
      begin
        ExtClientCaps := hex2StrU(CapEdit.Text);
        l := Length(ExtClientCaps);
        if l < 16 then
         begin
           SetLength(ExtClientCaps, 16);
           for I := l+1 to 16 do
             ExtClientCaps[i] := #00;
         end;
      end
     else
      ExtClientCaps := '';
    if AddExtCliCaps then
     mustUpdCaps   := True;
   end;
  if showInvisSts <> ShowInvChk.Checked then
    begin
     if not showInvisSts and (fICQ.visibility in [VI_invisible, VI_privacy]) then
      begin
       fICQ.sendStatusCode(false);
       mustUpdSts := false;
      end;
     showInvisSts := ShowInvChk.Checked;
    end;
//   ProtVerCBox
  if fICQ.SupportUTF <> SendUTF8Chk.Checked then
   begin
    fICQ.SupportUTF := SendUTF8Chk.Checked;
    mustUpdCaps := True;
   end;
  if fICQ.UseCryptMsg <> MsgCryptChk.Checked then
   begin
    fICQ.UseCryptMsg := MsgCryptChk.Checked;
    mustUpdCaps := True;
   end;
  fICQ.SendingUTF := UTF8MsgsChk.Checked;
  fICQ.UseAdvMsg := AdvMsgChk.Checked;
  useFBcontacts := XMPPChk.Checked;
  warnVisibilityExploit := visibilityexploitChk.checked;
  if fICQ.webaware <> webawareChk.checked then
  begin
    fICQ.webaware := webawareChk.checked;
//    ICQ.webaware:=webaware;
//    mustUpdPerms := True;
    mustUpdPerms2 := True;
    mustUpdSts   := True;
  end;
  if PrivacyGrp.ItemIndex <> fICQ.showInfo then
  begin
    fICQ.showInfo := PrivacyGrp.ItemIndex;
    mustUpdPerms2 := True;
//    mustUpdSts   := True;
  end;

  sendTheAddedYou:=addedYouChk.checked;
  if fICQ.authNeeded<>authNeededChk.checked then
   begin
    fICQ.authNeeded := authNeededChk.checked;
    mustUpdPerms := True;
    mustUpdSts := True;
   end;
  if fICQ.SupportTypingNotif <> ChkTyping.Checked then
   begin
     mustUpdCaps := True;
     fICQ.SupportTypingNotif := ChkTyping.Checked;
   end;
  fICQ.isSendTypingNotif := ChkSendTyping.Checked;
  typingInterval := MTNIdleSpin.AsInteger;
  {$IFDEF CHECK_INVIS}
    supportInvisCheck := ChkSupInvChk.Checked;
    CheckInvis.AutoCheck := ChkinvisCheck.Checked;
    CheckInvis.AutoCheckInterval := CheckInvisSpin.AsInteger;
    CheckInvis.ChkInvisInterval  := ChkIntervSpin.Value;
    CheckInvis.AutoCheckOnSend   := ChkInvisSend.Checked;
    CheckInvis.AutoCheckGoOfflineUsers :=  ChkInvisGoOfl.Checked;
    CheckInvis.Method := ChkInvisRG.ItemIndex;
    showCheckedInvOfl := ShwOfflBox.Checked;
  {$ENDIF}
  fICQ.AvatarsSupport := SupAvtChk.Checked;
  fICQ.AvatarsAutoGet := AvtAutLoadChk.Checked;
  fICQ.AvatarsAutoGetSWF := AvtAutGetChk.Checked;
  AvatarsNotDnlddInform := NotDnlddInfoChk.Checked;
  autoRequestXsts := AutoReqXStChk.Checked;
{$IFDEF UseNotSSI}
{  if OldxStChk.Checked <> UseOldXSt then
   begin
     UseOldXSt   := OldxStChk.Checked;
     try
       tempStatus := icq.curXStatus;
       if (not UseOldXSt and (xsf_6 in XStatusArray[tempStatus].flags))
                         or (UseOldXSt and (xsf_Old in XStatusArray[tempStatus].flags)) then
        else
         icq.curXStatus := 0;
      except
     end;
     mustUpdCaps := True;
     mustUpdSts  := True;
   end;}
  LoginMD5 := LoginRG.ItemIndex = 1;
  useSSI2 := useSSIChk.Checked;
  useLSI2 := UseLSIChk.Checked;
{$ENDIF UseNotSSI}
 if mustUpdCaps and fICQ.isOnline then
  fICQ.sendCapabilities;
 if mustUpdSts and fICQ.isOnline then
  fICQ.sendStatusCode;
 if mustUpdPerms and fICQ.isOnline then
  begin
   fICQ.sendStatusCode;
   fICQ.sendPermsNew;
  end;
 if mustUpdPerms2 and fICQ.isOnline then
  begin
   fICQ.sendPrivacy(PrivacyGrp.ItemIndex, webawareChk.checked, authNeededChk.Checked);
  end;
 if needSaveChkList then
   saveListsDelayed := True;
//  if not saveFile(userPath+CheckInvisFileName+'.txt', CheckInvis.CList.toString, True) then
//    msgDlg(getTranslation('Error saving Check-invisibility list'),mtError);
end;

procedure TicqFr.resetPage;
var
  fICQ: TICQSession;
begin
  if not Assigned(Account.AccProto)
    or (Account.AccProto.ProtoName <> 'ICQ') then
    Exit;
  fICQ := TICQSession(Account.AccProto.ProtoElem);

  pwdBox.text        := fICQ.pwd;
  SaveMD5chk.Checked := fICQ.saveMD5Pwd;
//  sendInterChk.Checked := sendInterests;
  birthGrp.ItemIndex:=sendBalloonOn;
  bdayBox.Date:=sendBalloonOnDate;
  case fICQ.DCmode of
    DC_ROSTER: dcGrp.ItemIndex:=1;
    DC_EVERYONE: dcGrp.ItemIndex:=2;
//    DC_FAKE: dcGrp.ItemIndex := 3;
    else
//    DC_NONE:
      dcGrp.ItemIndex:=0;
    end;
  visibilityexploitChk.checked:=warnVisibilityExploit;
  clientidChk.checked:= fICQ.showclientid;
  AddCapsChk.Checked := AddExtCliCaps;
  CapEdit.Text := str2hexU(ExtClientCaps);
  SendUTF8Chk.Checked := fICQ.SupportUTF;
  UTF8MsgsChk.Checked := fICQ.SendingUTF;
  MsgCryptChk.Checked := fICQ.UseCryptMsg;
  AdvMsgChk.Checked   := fICQ.UseAdvMsg;
  XMPPChk.Checked     := useFBcontacts;
  ShowInvChk.Checked  := showInvisSts;
  addedYouChk.checked := sendTheAddedYou;
  webawareChk.checked := fICQ.webaware;
  PrivacyGrp.ItemIndex  := fICQ.showInfo;
  authNeededChk.checked := fICQ.authNeeded;
  ChkTyping.Checked   := fICQ.SupportTypingNotif;
  ChkSendTyping.Checked := fICQ.isSendTypingNotif;
  MTNIdleSpin.Value := typingInterval;
   {$IFDEF CHECK_INVIS}
    ChkSupInvChk.Checked  := supportInvisCheck;
    ChkinvisCheck.Checked := CheckInvis.AutoCheck;
    CheckInvisSpin.Value  := CheckInvis.AutoCheckInterval;
    ChkIntervSpin.Value   := CheckInvis.ChkInvisInterval;
    ChkInvisSend.Checked  := CheckInvis.AutoCheckOnSend;
    ChkInvisGoOfl.Checked := CheckInvis.AutoCheckGoOfflineUsers;
    ChkInvisRG.ItemIndex  := CheckInvis.Method;
    ShwOfflBox.Checked    := showCheckedInvOfl;
   {$ELSE}
    ChkSupInvChk.Checked  := False;
    ChkSupInvChk.Enabled  := False;
   {$ENDIF}
   SupAvtChk.Checked     := fICQ.AvatarsSupport;
   AvtAutLoadChk.Checked := fICQ.AvatarsAutoGet;
   AvtAutGetChk.Checked  := fICQ.AvatarsAutoGetSWF;
   NotDnlddInfoChk.Checked := AvatarsNotDnlddInform;
   AutoReqXStChk.Checked := autoRequestXsts;
   needSaveChkList       := false;
{$IFDEF UseNotSSI}
   if LoginMD5 then
     LoginRG.ItemIndex := 1
    else
     LoginRG.ItemIndex := 0;
   useSSIChk.Checked := useSSI2;
   UseLSIChk.Checked := useLSI2;
//   OldxStChk.Checked := UseOldXSt;
{$ELSE UseNotSSI}
   useSSIChk.Checked := True;
   useSSIChk.Enabled := False;
{$ENDIF UseNotSSI}
end;

procedure TicqFr.updateVisPage;
begin
  GBTyping.Visible := ChkTyping.Checked;
  if ChkTyping.Checked then
    begin
      ChkTyping.Caption := '';
      ChkTyping.Width := ChkTyping.Height;
    end
   else
    begin
      ChkTyping.Caption := getTranslation(TypNotifCap);
      ChkTyping.Width := GBTyping.width;
    end;

//  GBTyping.Enabled := ChkTyping.Checked;
 {$IFDEF CHECK_INVIS}
  GBInvis.Visible  := ChkSupInvChk.Checked;
 {$ELSE ~CHECK_INVIS}
  GBInvis.Visible  := False;
 {$ENDIF CHECK_INVIS}
  if ChkSupInvChk.Checked then
    begin
      ChkSupInvChk.Caption := '';
      ChkSupInvChk.Width := ChkTyping.Height;
    end
   else
    begin
      ChkSupInvChk.Caption := getTranslation(ChkInvCap);
      ChkSupInvChk.Width := GBTyping.width;
    end;

  bdayBox.Enabled  := birthGrp.itemindex = 3;
  webawareChk.Enabled := Assigned(Account.AccProto) and Account.AccProto.isOnline;
  PrivacyGrp.Enabled  := webawareChk.Enabled;
{$IFDEF UseNotSSI}
//  useSSIChk.Enabled   := not webawareChk.Enabled;
  UseLSIChk.Enabled  := useSSIChk.Enabled and useSSIChk.Checked;
{$ELSE UseNotSSI}
//   useSSIChk.Enabled := False;
   UseLSIChk.Enabled := useSSIChk.Enabled;
{$ENDIF UseNotSSI}
  ShowInvChk.Enabled := useSSIChk.Checked;
  CapEdit.Enabled    := AddCapsChk.Checked;
  AddCapsBtn.Enabled := AddCapsChk.Checked;

  SaveMD5chk.Enabled := LoginMD5;
  if not LoginMD5 then
    SaveMD5chk.Checked := false;
  Label23.Enabled := not SaveMD5chk.Checked;
  pwdBox.Enabled  := Label23.Enabled;
end;


procedure TicqFr.SpeedButton1Click(Sender: TObject);
begin
 openURL('http://wwp.icq.com/scripts/online.dll?icq='+
          Account.AccProto.getMyInfo.UID2cmp+'&img=3')
end;

procedure TicqFr.UpdVis(Sender: TObject);
begin
  updateVisPage;
end;

procedure TicqFr.UpdVis1(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  updateVisPage;
end;

procedure TicqFr.SBSelInvisClClick(Sender: TObject);
begin
 if Assigned(wnd) then
  SetForegroundWindow(wnd.Handle)
 else
 begin
   wnd := TselectCntsFrm.doAll(TForm(parent),
                              'Select Invisibility check list', 'Select',
                              Account.AccProto,
                              Account.AccProto.readList(LT_ROSTER).clone, //.add(notinlist),
                              CloseAction,
                              [sco_multi,sco_groups,sco_predefined],
                              @wnd, True
                              );
//wnd.toggle(thisContact);
 {$IFDEF CHECK_INVIS}
  CheckInvis.CList.resetEnumeration;
  while CheckInvis.CList.hasMore do
    wnd.toggle(CheckInvis.CList.getNext);
 {$ENDIF}
//wnd.icon:=theme.getIco(ICO_MSG);
//wnd.extra:=Tincapsulate.aString(msg);
 end;
 needSaveChkList := True;
end;

procedure TicqFr.CloseAction(sender:Tobject);
var
  wnd: TselectCntsFrm;
//  cl: TcontactList;
//  msg: string;
begin
  wnd := (sender as Tcontrol).parent as TselectCntsFrm;
 {$IFDEF CHECK_INVIS}
   CheckInvis.CList := wnd.selectedList;
 {$ENDIF}
  //cl.free;
  wnd.extra.free;
  wnd.close;
end; // sendmessage action

//INITIALIZATION

//  AddPrefPage(2, TicqFr, 'ICQ');
end.
