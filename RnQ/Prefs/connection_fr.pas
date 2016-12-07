unit connection_fr;
{$I RnQConfig.inc}
{$I NoRTTI.inc}

interface

uses 
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  ExtCtrls, StdCtrls, RnQSpin, RDGlobal,
 {$IFDEF PREF_IN_DB}
  DBPrefsLib,
 {$ELSE ~PREF_IN_DB}
  RnQPrefsLib,
 {$ENDIF PREF_IN_DB}
  RnQButtons, RnQNet;

type
  TconnectionFr = class(TPrefFrame)
    autoreconnectChk: TCheckBox;
    proxyGroup: TGroupBox;
    kaChk: TCheckBox;
    kaSpin: TRnQSpinEdit;
    Label9: TLabel;
    disconnectedChk: TCheckBox;
    conOnConChk: TCheckBox;
    LEProxyName: TLabeledEdit;
    ProxyDelBtn: TRnQSpeedButton;
    ProxyAddBtn: TRnQSpeedButton;
    ProxyIDBox: TComboBox;
    ServerCBox: TComboBox;
    portBox: TLabeledEdit;
    ServerLbl: TLabel;
    GroupBox1: TGroupBox;
    proxyhostBox: TLabeledEdit;
    proxyportBox: TLabeledEdit;
    authGroup: TGroupBox;
    L6: TLabel;
    proxyuserBox: TLabeledEdit;
    proxypwdBox: TEdit;
    proxyproto: TRadioGroup;
    authChk: TCheckBox;
    ntlmauth: TCheckBox;
    StopRcnctChk: TCheckBox;
    SSLChk: TCheckBox;
    PortsLEdit: TLabeledEdit;
    RslvIPChk: TCheckBox;
    SaveIPChk: TCheckBox;
    procedure authChkClick(Sender: TObject);
    procedure portBoxChange(Sender: TObject);
    procedure proxyprotoClick(Sender: TObject);
    procedure ProxyIDBoxChange(Sender: TObject);
    procedure ProxyAddBtnClick(Sender: TObject);
    procedure ProxyDelBtnClick(Sender: TObject);
    procedure AddFWExeptBtnClick(Sender: TObject);
  private
    { Private declarations }
    procedure ApplyProxy;
    procedure resetProxy;
    procedure PrefToProxy(var prxy : TProxy);
    procedure ProxyToPref(prxy : TProxy);
  public
    procedure initPage; Override;
    procedure applyPage; Override;
    procedure resetPage; Override;
    procedure updateVisPage; Override;
    { Public declarations }
  end;

implementation

uses
  prefDlg, utilLib, mainDlg, RQUtil,
  globalLib
  ;

{$R *.dfm}

var
  lastProxy : Integer;
  v_proxyes   : TarrProxy;
//  temp_proxyes   : TarrProxy;


procedure TconnectionFr.authChkClick(Sender: TObject);
begin
  updateVisPage;
{  if useproxy1.checked then
    begin
	  if Tproxyproto(proxyproto.itemIndex)=PP_HTTPS then
	    if portbox.text='5190' then portBox.text:='443';
    end
   else
	 if portbox.text='443' then portBox.text:='5190' else
}
end;

procedure TconnectionFr.portBoxChange(Sender: TObject);
begin onlyDigits(sender) end;

procedure TconnectionFr.ProxyAddBtnClick(Sender: TObject);
var
  i  : Integer;
//  pp : TproxyProto;
begin
  i := Length(v_proxyes);
  SetLength(v_proxyes, i+1);
  ProxyIDBox.Items.Add('Proxy' + IntToStr(i+1));
  with v_proxyes[i] do
   begin
    enabled:=True;
    name := 'Proxy' + IntToStr(i+1);
//    for pp:=low(pp) to high(pp) do addr[pp].host:='';
//    addr[PP_SOCKS4].port:='1080';
//    addr[PP_SOCKS5].port:='1080';
//    addr[PP_HTTPS].port:='3128';
    if Assigned(Account.AccProto) then
     serv := Account.AccProto.ProtoElem._getDefHost;
    addr.host:='';
    addr.port:=1080;
    proto:=PP_NONE;
    auth:=FALSE;
    rslvIP := True;
    NTLM := False;
    ssl := False;
   end;
  ProxyIDBox.ItemIndex := i;
  ProxyIDBoxChange(ProxyIDBox);
end;

procedure TconnectionFr.ProxyDelBtnClick(Sender: TObject);
var
  i, j  : Integer;
  pr : array of Tproxy;
//  pp : TproxyProto;
begin
  i := ProxyIDBox.ItemIndex;
  if ProxyIDBox.Items.Count <= 1 then Exit;

  if Length(v_proxyes) = i+1 then
    begin
      ClearProxy(v_proxyes[length(v_proxyes)-1]);
      SetLength(v_proxyes, length(v_proxyes)-1);
      ProxyIDBox.Items.Delete(i);
      ProxyIDBox.ItemIndex := i-1;
      ProxyIDBoxChange(ProxyIDBox);
    end
   else
    begin
      SetLength(pr, length(v_proxyes) - i-1);
      for j := i+1 to length(v_proxyes)-1 do
        pr[j-i-1] := v_proxyes[j];
      SetLength(v_proxyes, length(v_proxyes)-1);
      for j := i to length(v_proxyes)-1 do
        v_proxyes[j] := pr[j-i];
      lastProxy := -1;
      ProxyIDBox.Items.Delete(i);
      ProxyIDBox.ItemIndex := i;
      ProxyIDBoxChange(ProxyIDBox);
    end;
end;

procedure TconnectionFr.ProxyIDBoxChange(Sender: TObject);
//var
//  pp: TproxyProto;
begin
  if lastProxy <> ProxyIDBox.ItemIndex then
   begin
     if (lastProxy >= Low(v_proxyes))and (lastProxy <= High(v_proxyes)) then
       PrefToProxy(v_proxyes[lastProxy]);
     lastProxy := ProxyIDBox.ItemIndex;

//     ProxyIDBox.Items.Strings[lastProxy] := LEProxyName.Text;
//     CopyProxy(icq.fProxy, v_proxyes[lastProxy]);
     CopyProxy(MainProxy, v_proxyes[lastProxy]);
   end;
  resetProxy;
end;

procedure TconnectionFr.proxyprotoClick(Sender: TObject);
begin
  updateVisPage;
//  proxyhostBox.text:=host;
//  proxyportBox.text:=port;
//  if useproxy1.checked then
  if Assigned(Sender) then
    if Tproxyproto(proxyproto.itemIndex)=PP_HTTPS then
	    if portbox.text='5190' then
        portBox.text:='443'
       else
//	  else
//	    if portbox.text='443' then portBox.text:='5190' else
end;


procedure TconnectionFr.initPage;
var
  pp: Tproxyproto;
begin
  if Assigned(Account.AccProto) then
    begin
     ServerCBox.Items.Text := Account.AccProto.ProtoElem._getProtoServers
    end
   else
    ServerCBox.Items.Text := 'login.icq.com';
  proxypwdBox.onKeyDown := RnQmain.pwdboxKeyDown;
  proxyproto.Items.Clear();
  for pp:=low(pp) to high(pp) do
    proxyproto.Items.add(proxyproto2str[pp]);

  proxyGroup.Width := ClientWidth - GAP_SIZE2;
//  portBox.Width := 50; //proxyGroup.Width - portBox.left - GAP_SIZE2;
  ServerCBox.Width := SSLChk.Left - ServerCBox.Left - GAP_SIZE2;

//  portBox.left := 320 + GAP_SIZE;
  portBox.left := ServerCBox.Left + ServerCBox.Width + portBox.EditLabel.Width
                  + GAP_SIZE + GAP_SIZE2 + GAP_SIZE2;

  LEProxyName.left := ServerCBox.left;
  LEProxyName.Width := ServerCBox.Width;// - GAP_SIZE;

  proxyhostBox.left := ServerCBox.left - 3;
  proxyhostBox.Width := ServerCBox.Width;// - GAP_SIZE;

  proxyportBox.left := portBox.left - 3;
//  proxyportBox.Width := proxyGroup.Width - 320 - GAP_SIZE2;
  proxyportBox.Width := portBox.Width;

  proxyproto.left:=  GAP_SIZE2;

  updateVisPage;
end;

procedure TconnectionFr.ApplyProxy;
var
//  pp: TproxyProto;
  i : Integer;
begin
  i := ProxyIDBox.ItemIndex;
  if (i < low(v_proxyes)) or (i > High(v_proxyes)) then
   Exit;
  CopyProxy(MainProxy, v_proxyes[i]);
end;

procedure TconnectionFr.PrefToProxy(var prxy : TProxy);
begin
  prxy.serv.host := ServerCBox.Text;// hostBox.text;
  prxy.serv.port := StrToIntDef(portBox.text, 0);
  prxy.name := LEProxyName.Text;
  prxy.proto:=Tproxyproto(proxyproto.itemIndex);
  prxy.addr.host:=proxyhostBox.text;
  prxy.addr.port:=StrToIntDef(proxyportBox.text, 0);
  prxy.user := proxyuserBox.text;
  prxy.pwd  := proxypwdBox.text;
  prxy.auth := authChk.checked;
  prxy.NTLM := NTLMauth.Checked;
  prxy.ssl := SSLChk.Checked;
  prxy.rslvIP := RslvIPChk.Checked;
end;
procedure TconnectionFr.ProxyToPref(prxy : TProxy);
begin
  with prxy do
   begin
    ServerCBox.text := serv.host;
    portBox.text    := intToStr(serv.port);
    authGroup.visible:= auth;
    LEProxyName.Text := name;
    proxyhostBox.text:= addr.host;
    proxyportBox.text:=intToStr(addr.port);
    proxyproto.OnClick := NIL;
    proxyproto.itemIndex:=ord(proto);
    proxyproto.OnClick := proxyprotoClick;
    proxyuserBox.text:= user;
    proxypwdBox.text := pwd;
    authChk.checked     := auth;
    NTLMauth.Checked := NTLM;
    SSLChk.Checked   := prxy.ssl;
    RslvIPChk.Checked := rslvIP;
   end;
end;

procedure TconnectionFr.AddFWExeptBtnClick(Sender: TObject);
begin
// Need to add Administrator's privileges first!
//  DSiAddApplicationToFirewallExceptionList('RnQ', myPath + ExtractFileName(ParamStr(0)));
end;

procedure TconnectionFr.applyPage;
//var
//  pp: TproxyProto;
begin
  connectOnConnection:=conOnConChk.checked;
  autoreconnect:=autoreconnectChk.checked;
  autoReconnectStop := StopRcnctChk.Checked;
  SaveIP := SaveIPChk.Checked;

  keepalive.enabled:=kaChk.checked;
  keepalive.freq:=round(kaSpin.value);
  keepalive.timer:=keepalive.freq;
  showDisconnectedDlg:=disconnectedChk.checked;

//   ApplyProxy;
//        CopyProxy(v_proxyes[ProxyIDBox.ItemIndex], icq.proxy);
//  icq.proxy.enabled:= proxyproto.itemIndex > 0;
  PrefToProxy(MainProxy);
  if (ProxyIDBox.ItemIndex >= low(v_proxyes)) and
     (ProxyIDBox.ItemIndex <= High(v_proxyes)) then
     with v_proxyes[ProxyIDBox.ItemIndex] do
       begin
        CopyProxy(v_proxyes[ProxyIDBox.ItemIndex], MainProxy);
{
        PrefToProxy(v_proxyes[ProxyIDBox.ItemIndex]);
//         ProxyIDBox.Items.Strings[ProxyIDBox.ItemIndex] := name;
//         ProxyIDBox.Items.Strings[ProxyIDBox.ItemIndex] := LEProxyName.Text;
//        CopyProxy(MainProxy, v_proxyes[ProxyIDBox.ItemIndex]);
}
       end;

  CopyProxyArr(AllProxies, v_proxyes);
  portsListen.parseString(PortsLEdit.Text);
//  SaveProxies(v_proxyes);
  saveCfgDelayed := True;
end;

procedure TconnectionFr.resetProxy;
begin
//  proxyGroup.visible:=proxy.enabled;
// with icq.proxy do
  if (ProxyIDBox.ItemIndex >= low(v_proxyes)) and
     (ProxyIDBox.ItemIndex <= High(v_proxyes)) then
    ProxyToPref(v_proxyes[ProxyIDBox.ItemIndex]);
  proxyprotoClick(nil);
end;

procedure TconnectionFr.resetPage;
var
  foundProxy : Boolean;
//  pp: TproxyProto;
  I: Integer;
  CurrentProxy : string;
begin
  kaChk.checked := keepalive.enabled;
  kaSpin.value  := keepalive.freq;
  conOnConChk.checked      := connectOnConnection;
  autoreconnectChk.checked := autoreconnect;
  StopRcnctChk.Checked     := autoReconnectStop;
  disconnectedChk.checked  := showDisconnectedDlg;
  SaveIPChk.Checked := SaveIP;
//  ServerCBox.text := proxy.serv.host;
//  portBox.text    := intToStr(proxy.serv.port);

  ProxyIDBox.Items.Clear;
  CopyProxyArr(v_proxyes, AllProxies);
//  LoadProxies(v_proxyes);
  for I := 0 to Length(v_proxyes) - 1 do
     ProxyIDBox.Items.Add(v_proxyes[i].name);

//  if CurrentProxy then
  if Length(v_proxyes) = 0 then
    begin
      I := 0;
//      ClearProxy(MainProxy);
      MainProxy.name := 'Default';
      if Assigned(Account.AccProto) then
        MainProxy.serv := Account.AccProto.ProtoElem._getDefHost
       else
        begin
          MainProxy.serv.host := ServerCBox.Items[0];
          MainProxy.serv.port := 443;
        end;
      ProxyIDBox.Items.Add(MainProxy.name);
      ProxyIDBox.ItemIndex := 0;
      SetLength(v_proxyes, 1);
      CopyProxy(v_proxyes[i], MainProxy);
    end
   else
    begin
     CurrentProxy := MainProxy.name;
{     if CurrentProxy = '' then
      CurrentProxy := proxyes[0].name;}
     foundProxy := False;

     for I := 0 to Length(v_proxyes) - 1 do
      if v_proxyes[i].name = CurrentProxy then
       begin
         ProxyIDBox.ItemIndex := i;
         foundProxy := True;
         break;
       end;
     if not foundProxy then
      begin
       ProxyIDBox.ItemIndex := 0;
      end;
     ApplyProxy;

    end;
    ;
  lastProxy := ProxyIDBox.ItemIndex;
  PortsLEdit.Text := portsListen.getString;
  resetProxy;
end;

procedure TconnectionFr.updateVisPage;
begin
//  proxyGroup.visible:=useproxy1.checked;
  authChk.enabled:=(proxyproto.ItemIndex > 0)and (proxyproto.ItemIndex<>ord(PP_SOCKS4));
  authGroup.visible:=authChk.checked and authChk.enabled;
  ntlmauth.Visible := authGroup.visible;
  ntlmauth.Enabled:=authChk.checked and authChk.enabled;
//  proxyuserBox.Enabled := not ntlmauth.Checked;
//  proxypwdBox.Enabled := proxyuserBox.Enabled;
//  l6.Enabled := proxypwdBox.Enabled;
end;

end.
