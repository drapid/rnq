unit RnQNet;
{$I forRnQConfig.inc}
{$I NoRTTI.inc}

interface
 uses
  Classes, OverbyteIcsWSocket, OverbyteIcsHttpProt,
  OverbyteIcsNtlmMsgs, OverbyteIcsWSockBuf,
{$IFDEF UseNTLMAuthentication}
  RnQHttpAuth,
{$ENDIF}
  RDGlobal;
//  wsocket, HttpProt;
//  , OverbyteIcsMD5,


type
{$IFDEF UseNTLMAuthentication}
    TRnQHttpNTLMState   = (ntlmNone, ntlmMsg1, ntlmMsg2, ntlmMsg3, ntlmDone);
{$ENDIF}
    TRnQHttpBasicState  = (basicNone, basicMsg1, basicDone);
    TRnQHttpAuthType    = (httpAuthNone, httpAuthBasic, httpAuthNtlm);

type
  TproxyProto = (PP_NONE=0, PP_SOCKS4=1, PP_SOCKS5=2, PP_HTTPS=3);
  Thostport = record
    host: String;
    port: Integer;
  end;

  Tproxy = record
    name : string;
    user : String;
    pwd  : String; // Support Unicode!
//    enabled   : boolean;
    auth      : boolean;
    NTLM      : boolean;
    proto     : TproxyProto;
    addr      : Thostport;
    rslvIP    : Boolean;
 {$IFNDEF PREF_IN_DB}
    serv      : Thostport;
    ssl       : Boolean;
 {$ENDIF ~PREF_IN_DB}

//    addr      : array [Tproxyproto] of Thostport;
//    host,port : string;
  end;
  TarrProxy = array of Tproxy;

const
  proxyProto2Str:array [TproxyProto] of AnsiString=('NONE', 'SOCKS4', 'SOCKS5', 'HTTP/S');

//var
   {:record
    enabled   :boolean;
    auth      :boolean;
    proto     :TproxyProto;
//    addr      :array [Tproxyproto] of Thostport;
    NTLM      :boolean;
    user, pwd :string;
    end; }
   Procedure CopyProxy(var pTo: Tproxy; const pFrom: Tproxy);
   Procedure ClearProxy(var p1: Tproxy);
   Procedure CopyProxyArr(var pATo: TarrProxy; const pAFrom: TarrProxy);
   Procedure ClearProxyArr(var pa: TarrProxy);
//procedure proxy_http_Enable(v_icq : TicqSession);
//   procedure proxy_http_Enable(sock : TRnQSocket);


type
  ThttpProxyInfo = record
         user : String;
         addr, port : String;
         pwd: AnsiString;
         authType : TRnQHttpAuthType;
{$IFDEF UseNTLMAuthentication}
        FNTLMMsg2Info         : TNTLM_Msg2_Info;
        FProxyNTLMMsg2Info    : TNTLM_Msg2_Info;
        FAuthNTLMState        : TRnQHttpNTLMState;
        FProxyAuthNTLMState   : TRnQHttpNTLMState;
{$ENDIF}
        enabled:boolean;
      end;
  TDataReceived   = procedure (Sender: TObject; ErrCode: Word; pkt : RawByteString) of object;
  TProxyLogData   = procedure (Sender: TObject; isReceive : Boolean; Data : RawByteString) of object;

 {$IFDEF USE_SSL}
  TRnQSocket = class (TSslWSocket)
 {$ELSE}
  TRnQSocket = class (TWSocket)
 {$ENDIF USE_SSL}
  private
    FSocksConnected : Boolean;
    FOldOnSessionConnected: TSessionConnected;
    FOldOnDataAvailable: TDataAvailable;
    FServerAddr : String;
    FServerPort : AnsiString;
    FMyBeautifulSocketBuffer: RawByteString;
    FOnDataReceived : TDataReceived;
    FOnProxyTalk : TProxyLogData;

    // server authentication
//    oSeq: AUTH_SEQ;
    // proxy authentication
    pSeq: AUTH_SEQ;

    procedure myOnConnected(Sender: TObject; Error: Word);
    procedure myOnReceived(Sender: TObject; Error: Word);
    procedure ClientConnected(Sender: TObject; Error: Word);
    procedure ClientConnected2(Sender: TObject; Error: Word);
  public
     fAccIDX : Integer;
     http : ThttpProxyInfo;
 {$IFDEF USE_SSL}
     isSSL : Boolean;
    procedure StartTLS;
 {$ENDIF USE_SSL}
  protected
 {$IFDEF USE_SSL}
    SslCtxt: TSslContext;
    procedure SockSslHandshakeDone(Sender: TObject; ErrCode: Word;
               PeerCert: TX509Base; var Disconnect: Boolean);
 {$ENDIF USE_SSL}
    procedure TriggerSessionClosed(Error : Word); override;
    function  GetAddr1 : String;
    function  GetAddr2 : String;
{$IFDEF UseNTLMAuthentication}
//        procedure StartAuthNTLM; virtual;
//        procedure StartProxyAuthNTLM; virtual;  {BLD proxy NTLM support }
        function  GetNTLMMessage1 : AnsiString;
        function  GetNTLMMessage3(const ForProxy: Boolean) : AnsiString;
        function  GetNTLMMessage3_RD(const ForProxy: Boolean; Domain : String = ''): AnsiString;
//        procedure ElaborateNTLMAuth;
//        function  PrepareNTLMAuth(var FlgClean : Boolean) : Boolean;
{$ENDIF}
    procedure TriggerProxyData(isReceive : Boolean; Data : RawByteString);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Connect; override;
    procedure Close; override;
//    procedure CloseDelayed; override;

    procedure DisableProxy();
    procedure proxySettings(proxy : TProxy);
    procedure getFreePort;

//    function RealSend(Data : Pointer; Len : Integer) : Integer; override;
//    function RealSend(var Data : TWSocketData; Len : Integer) : Integer; override;
//    function Send(Data: Pointer; Len: Integer): Integer; override;
//    function Send(const Data : TWSocketData; Len : Integer) : Integer; override;

//    function SendStr(const Str : String) : Integer; override;
//    function Receive(Buffer: Pointer; BufferSize: Integer): Integer; override;
//    function Receive(Buffer : TWSocketData; BufferSize: Integer) : Integer;  {overload; } override;
//    function ReceiveStr: string; override;
    property Addr : String read  GetAddr1 write SetAddr;
    property AddrPort : String read GetAddr2;
    property OnDataReceived : TDataReceived read FOnDataReceived write FOnDataReceived;
    property OnProxyTalk : TProxyLogData read FOnProxyTalk write FOnProxyTalk;
   end;

const
  ProxyUnkError = 'PROXY: Unknown reply\n[%d]\n%s';
  SSLError = 'SSL: libeay32.dll or ssleay32.dll not found\n%s';
  ImageContentTypes: array [0 .. 25] of string = (
    'image/bmp', 'image/x-bmp', 'image/x-bitmap', 'image/x-xbitmap', 'image/x-win-bitmap', 'image/x-windows-bmp', 'image/ms-bmp', 'image/x-ms-bmp', 'application/bmp', 'application/x-bmp', 'application/x-win-bitmap',
    'image/jpeg', 'image/jpg', 'application/jpg', 'application/x-jpg',
    'image/gif',
    'image/png', 'application/png', 'application/x-png',
    'image/ico', 'image/x-icon', 'application/ico', 'application/x-ico',
    'image/tiff', 'image/x-tiff',
    'image/webp'
  );
  ImageExtensions: array [0 .. 25] of string = (
    'bmp', 'bmp', 'bmp', 'bmp', 'bmp', 'bmp', 'bmp', 'bmp', 'bmp', 'bmp', 'bmp',
    'jpg', 'jpg', 'jpg', 'jpg',
    'gif',
    'png', 'png', 'png',
    'ico', 'ico', 'ico', 'ico',
    'tiff', 'tiff',
    'webp'
  );

  procedure SetupProxy(var httpCli: TSslHttpCli);
  function HeaderFromURL(const URL: String): String;
  function LoadFromURL0(const URL: String; var fn: String; Threshold: LongInt = 0; ExtByContent: Boolean = False): Boolean;
  function LoadFromURL(const URL: String; var fn: String; var fs: TMemoryStream; Threshold: LongInt = 0;
                       ExtByContent: boolean = false; DoPOST: boolean = false; POSTData: RawByteString = ''; showErrors: boolean = true): boolean; overload;
  function LoadFromURL(const URL: String; var fn: String; Threshold: LongInt = 0; ExtByContent: boolean = false;
                       DoPOST: boolean = false; POSTData: RawByteString = ''; showErrors: boolean = true): boolean; overload;
  function LoadFromURL(const URL: String; var fs: TMemoryStream; Threshold: LongInt = 0; ExtByContent: boolean = false;
                       DoPOST: boolean = false; POSTData: RawByteString = ''; showErrors: boolean = true): boolean; overload;

var
  MainProxy : Tproxy;
  AllProxies : TarrProxy;

implementation

  uses
    Windows, Base64, SysUtils, StrUtils,
    RDUtils,
    RnQPrefsLib,
 {$IFDEF UNICODE}
   AnsiStrings,
 {$ENDIF UNICODE}
//    OverbyteIcsLogger,
 {$IFDEF RNQ}
    RnQLangs, RnQDialogs,
    RQUtil,
 {$ENDIF RNQ}
 {$IFDEF RNQ_PLUGIN}
   RDPlugins,
 {$ENDIF RNQ_PLUGIN}
    RnQGraphics32
   ;

(*
procedure proxy_http_Enable(v_icq : TicqSession);
begin
  v_icq.sock.http.enabled:=proxy.enabled and (proxy.proto=PP_HTTPS);
  if (proxy.proto=PP_HTTPS) then
   begin
    v_icq.sock.http.addr:=proxy.addr.host;
    v_icq.sock.http.port:=IntToStr(proxy.addr.port);
   end
  else
   begin
    v_icq.sock.http.addr:='';
    v_icq.sock.http.port:='';
   end;
  if proxy.auth then
    begin
//      if not proxy.NTLM then
        begin
        //  sock.SocksAuthentication :=
          v_icq.sock.http.user:=proxy.user;
          v_icq.sock.http.pwd:=proxy.pwd;
          if proxy.NTLM then
            v_icq.sock.http.authType := RnQNet.httpAuthNtlm
          else
            v_icq.sock.http.authType := RnQNet.httpAuthBasic;
        end
{       else
        begin
          v_icq.http.user:='';
          v_icq.http.pwd:='';
          v_icq.http.authType := httpAuthNtlm;
        end;}
    end
  else
    begin
      v_icq.sock.http.authType := RnQNet.httpAuthNone;
      v_icq.sock.http.user:='';
      v_icq.sock.http.pwd:='';
    end;
end;
*)
(*procedure proxy_http_Enable(proxy : TProxy; sock : TRnQSocket);
begin
  sock.http.enabled := proxy.enabled and (proxy.proto=PP_HTTPS);
  if (proxy.proto=PP_HTTPS) then
   begin
    sock.http.addr:=proxy.addr.host;
    sock.http.port:=IntToStr(proxy.addr.port);
   end
  else
   begin
    sock.http.addr:='';
    sock.http.port:='';
   end;
  if proxy.auth then
    begin
//      if not proxy.NTLM then
        begin
        //  sock.SocksAuthentication :=
          sock.http.user:=proxy.user;
          sock.http.pwd:=proxy.pwd;
          if proxy.NTLM then
            sock.http.authType := RnQNet.httpAuthNtlm
          else
            sock.http.authType := RnQNet.httpAuthBasic;
        end
{       else
        begin
          v_icq.http.user:='';
          v_icq.http.pwd:='';
          v_icq.http.authType := httpAuthNtlm;
        end;}
    end
  else
    begin
      sock.http.authType := RnQNet.httpAuthNone;
      sock.http.user:='';
      sock.http.pwd:='';
    end;
end;
*)
Procedure CopyProxy(var pTo : Tproxy; const pFrom : Tproxy);
begin
//     p1.enabled:= p2.enabled;
     pTo.name   := pFrom.name;
     pTo.proto  := pFrom.proto;
{     for pp:=low(pp) to high(pp) do
      begin
       proxy.addr[pp].host:=proxyes[lastProxy].addr[pp].host;
       proxy.addr[pp].port:=proxyes[lastProxy].addr[pp].port;
      end;}
      pTo.addr.host:=pFrom.addr.host;
      pTo.addr.port:=pFrom.addr.port;
 {$IFDEF PREF_IN_DB}
 {$ELSE ~PREF_IN_DB}
      pTo.serv.host := pFrom.serv.host;
      pTo.serv.port := pFrom.serv.port;
      pTo.ssl := pFrom.ssl;
 {$ENDIF PREF_IN_DB}
     pTo.user := pFrom.user;
     pTo.pwd  := pFrom.pwd;
     pTo.auth := pFrom.auth;
     pTo.NTLM := pFrom.NTLM;
     pTo.rslvIP := pFrom.rslvIP;
//  if pTo.serv.host = '' then
//   pTo.serv.host := DefLoginServer;
//  if pTo.serv.port <= 0 then
//   pTo.serv.port := DefLoginPort;
end;

Procedure ClearProxy(var p1 : Tproxy);
begin
     p1.name   := '';
     p1.proto := PP_NONE;
{     for pp:=low(pp) to high(pp) do
      begin
       proxy.addr[pp].host:=proxyes[lastProxy].addr[pp].host;
       proxy.addr[pp].port:=proxyes[lastProxy].addr[pp].port;
      end;}
      p1.addr.host:= '';
     p1.rslvIP := True;
     p1.user := '';
     p1.pwd  := '';
 {$IFDEF PREF_IN_DB}
 {$ELSE ~PREF_IN_DB}
      p1.serv.host := '';
 {$ENDIF PREF_IN_DB}
end;

Procedure CopyProxyArr(var pATo : TarrProxy; const pAFrom : TarrProxy);
var
  I: Integer;
begin
  ClearProxyArr(pATo);
  SetLength(pATo, Length(pAFrom));
  if Length(pAFrom) > 0 then
   for I := Low(pAFrom) to High(pAFrom) do
//    ClearProxy(pa[i]);
    CopyProxy(pATo[i], pAFrom[i]);
//  SetLength(pa, 0);
end;

procedure ClearProxyArr(var pa : TarrProxy);
var
  I: Integer;
begin
  if Length(pa) > 0 then
   begin
     for I := Low(pa) to High(pa) do
      ClearProxy(pa[i]);
     SetLength(pa, 0);
   end;
end;

{ TRnQSocket }

constructor TRnQSocket.Create(AOwner: TComponent);
begin
  inherited;
  http.enabled := false;
  fAccIDX := -1;
 {$IFDEF USE_SSL}
  SslCtxt := NIL;
 {$ENDIF USE_SSL}
{  IcsLogger := TIcsLogger.Create(AOwner);
  IcsLogger.LogFileName := 'sckt.log';
  IcsLogger.LogOptions := [loDestFile, loWsockErr, loWsockInfo, loWsockDump,
//                           loSslErr,      loSslInfo,      loSslDump,
                           loProtSpecErr, loProtSpecInfo, loProtSpecDump];
}
end;

procedure TRnQSocket.Connect;
var
  Mtd : Pointer;
begin
  FSocksConnected := false;
  http.FProxyAuthNTLMState := ntlmNone;
  FServerAddr := FAddrStr;
  FServerPort := Port;

  AuthTerm(@pSeq);
  fillchar(pSeq, sizeof(pSeq), 0);
  AuthInit(@pSeq);

 {$IFDEF USE_SSL}
  if isSSL then
   begin
    OnSslHandshakeDone := SockSslHandshakeDone;
    if not Assigned(SslCtxt) then
      SslCtxt := TSslContext.Create(self);
//     else
//      SslCtxt.InitContext

//    SslCtxt.IcsLogger := Self.IcsLogger;
//    SslCtxt.SslVersionMethod := sslTLS_V1_CLIENT;
//    SslCtxt.SslCipherList := 'ALL:eNULL:aNULL:@STRENGTH';
    SslCtxt.SslCipherList := 'DEFAULT:@STRENGTH';

//    SslCtxt.SslSessionCacheModes := [];
    SslCtxt.SslVersionMethod     := sslV23;
    SslCtxt.SslVerifyPeer := False;
//    SslCtxt.SslVerifyDepth := 1;
    SslCtxt.SslVerifyPeerModes := [SslVerifyMode_NONE];
    SslCtxt.SslVerifyDepth := 9;
    SslContext := SslCtxt;
    SslEnable := False;
    SslMode := sslModeClient;
   end;
 {$ENDIF USE_SSL}

  if http.enabled then //and (http.authType <> httpAuthNone) then
    begin
      Addr := http.addr;
      Port := http.port;
      Mtd := @TRnQSocket.myOnConnected;
      if Mtd <> TMethod(FOnSessionConnected).Code then
      begin
        FOldOnSessionConnected := OnSessionConnected;
        FOnSessionConnected := myOnConnected;
      end;
      Mtd := @TRnQSocket.myOnReceived;
      if Mtd <> TMethod(FOnDataAvailable).Code then
      begin
        FOldOnDataAvailable := OnDataAvailable;
        FOnDataAvailable := myOnReceived;
      end;
    end
 {$IFDEF USE_SSL}
   else
    if isSSL then
     begin
      Mtd := @TRnQSocket.myOnConnected;
      if Mtd <> TMethod(FOnSessionConnected).Code then
      begin
        FOldOnSessionConnected := OnSessionConnected;
        FOnSessionConnected := myOnConnected;
        FOldOnDataAvailable := OnDataAvailable;
      end;
     end
 {$ENDIF USE_SSL}
  ;
  inherited;
end;

destructor TRnQSocket.Destroy;
begin
  SetLength(http.addr, 0);
  SetLength(http.port, 0);
  SetLength(http.user, 0);
  SetLength(http.pwd, 0);
 {$IFDEF USE_SSL}
  SslContext := NIL;
  if Assigned(SslCtxt) then
    SslCtxt.Free;
  SslCtxt := NIL;
 {$ENDIF USE_SSL}

  AuthTerm(@pSeq);

  inherited;
end;

procedure TRnQSocket.TriggerProxyData(isReceive : Boolean; Data : RawByteString);
begin
  if Assigned(FOnProxyTalk) then
    FOnProxyTalk(Self, isReceive, Data);
end;

procedure TRnQSocket.myOnConnected(Sender: TObject; Error: Word);
var
//  eventData, s : AnsiString;
  vData, vRaw : RawByteString;
begin
  if error <> 0 then
   begin
//     if Assigned(FOldOnSessionConnected) then
//       FOldOnSessionConnected(Sender, Error);
     ClientConnected(Sender, Error);
     Exit;
   end;
if http.enabled and not FSocksConnected then
  begin
{  if phase = CONNECTING_ then
    eventData:=loginServerAddr+':'+loginServerPort
  else
    eventData:=serviceServerAddr+':'+serviceServerPort;
}
  vData := AnsiString(FServerAddr) + ':' + FServerPort;

  if (http.user > '') or (http.authType = httpAuthNtlm) then
    begin
{$IFDEF UseNTLMAuthentication}
      if (http.authType = httpAuthNtlm) and (http.FProxyAuthNTLMState = ntlmNone) then
       http.FProxyAuthNTLMState := ntlmMsg1;

      if (http.authType = httpAuthNtlm) then
        begin
          if (http.FProxyAuthNTLMState <> ntlmMsg1) then begin
            if (http.FAuthNTLMState = ntlmMsg1) then
                vRaw := AnsiString('Authorization: NTLM ') + GetNTLMMessage1 + AnsiString(CRLF)
            else if (http.FAuthNTLMState = ntlmMsg3) then
                vRaw := AnsiString('Authorization: NTLM ') + GetNTLMMessage3(False) + AnsiString(CRLF)
          end
        end
       else //if (http.FAuthBasicState = basicMsg1) then
         vRaw := AnsiString('Authorization: Basic ') +
                Base64EncodeString(AnsiString(http.user) + ':' + http.pwd)
//                EncodeStr(encBase64, http.user + ':' + http.pwd)
               + CRLF;
{$ELSE}
//        if (FAuthBasicState = basicMsg1) then
     vRaw := AnsiString('Authorization: Basic ') +
            Base64EncodeString(http.user + ':' + http.pwd)
//            EncodeStr(encBase64, http.user + ':' + http.pwd)
           + CRLF;
{$ENDIF}

{$IFDEF UseNTLMAuthentication}
        if (http.FProxyAuthNTLMState = ntlmMsg1) then
            vRaw := vRaw+ 'Proxy-Authorization: NTLM ' + GetNTLMMessage1 + CRLF
        else if (http.FProxyAuthNTLMState = ntlmMsg3) then
//            s := s+ 'Proxy-Authorization: NTLM ' + GetNTLMMessage3(True) + CRLF
            vRaw := vRaw+ 'Proxy-Authorization: NTLM ' + GetNTLMMessage3_RD(True) + CRLF
        else
{$ENDIF}
//        if (FProxyAuthBasicState = basicMsg1) then
            vRaw := vRaw+ AnsiString('Proxy-Authorization: Basic ') +
                   Base64EncodeString(AnsiString(http.user) + AnsiString(':') + http.pwd)
//                   EncodeStr(encBase64, http.user + ':' + http.pwd)
                   + AnsiString(CRLF);

//    s:=base64encode(http.user+':'+http.pwd);
//    s:=
//      'Authorization: Basic '+s+CRLF+
//      'Proxy-authorization: Basic '+s+CRLF;
    end;
  vData :=
    'CONNECT '+vData+' HTTP/1.0'+CRLF+
//    'User-agent: ICQ/2000b (Mozilla 1.24b; Windows; I; 32-bit)'+CRLF+
//      SetRequestHeader('Connection', 'keep-alive');
    'Connection' + ': ' + 'keep-alive'+CRLF+
    vRaw+    // eventually empty
    CRLF;
   sendStr(vData);
   TriggerProxyData(false, vData);
  end
 else
  ClientConnected(Sender, Error);
end;

procedure TRnQSocket.myOnReceived(Sender: TObject; Error: Word);
const
   socksAuthenticationFailed = 20015;
var
  pkt, s : RawByteString;
  i, j: Integer;
  eventError : word;
begin
  eventError := 0;
  if http.enabled and not FSocksConnected then
   begin
   {$IFDEF UNICODE}
     pkt := ReceiveStrA;
   {$ELSE nonUNICODE}
     pkt := ReceiveStrA;
   {$ENDIF UNICODE}
//    if ((phase in [CONNECTING_,RECONNECTING_]) or
//       ((phase = relogin_) and isAvatarSession)) and sock.http.enabled then
     begin
      FMyBeautifulSocketBuffer:= FMyBeautifulSocketBuffer+pkt;
      if pos(AnsiString(CRLFCRLF), FMyBeautifulSocketBuffer) = 0 then exit;
      pkt := chop(AnsiString(CRLFCRLF), RawByteString(FMyBeautifulSocketBuffer));
//      eventData:=pkt+CRLFCRLF;
//      notifyListeners(IE_serverSent);
        TriggerProxyData(True, pkt);

//      eventError:=EC_other;
      if (SameText(Copy(pkt, 1, 6), AnsiString('<HTML>')) or
            SameText(Copy(pkt, 1, 9), AnsiString('<!DOCTYPE'))) then
       begin
         j := Pos(AnsiString('</HTML>'), pkt);
         if j <=0 then
           j := 1;
         i := PosEx(AnsiString('HTTP/1'), pkt, j);
        if i < 0 then
           i := PosEx(AnsiString('HTTPS/1'), pkt, j);
          ;
        if i >=0 then
          pkt := Copy(pkt, i, 10000)
       end;
      if AnsiStartsText(AnsiString('HTTPS/1.0 200'), pkt)
      or AnsiStartsText(AnsiString('HTTPS/1.1 200'), pkt)
      or AnsiStartsText(AnsiString('HTTP/1.1  200'), pkt)
      or AnsiStartsText(AnsiString('HTTP/1.0  200'), pkt)
      or AnsiStartsText(AnsiString('HTTP/1.0 200'), pkt)
      or AnsiStartsText(AnsiString('HTTP/1.1 200'), pkt) then
          ClientConnected(Sender, 0)
      else
        if AnsiStartsStr(AnsiString('HTTP/1.0 407'), pkt) or
           AnsiStartsStr(AnsiString('HTTP/1.1 407'), pkt)
    //      or PosEx('HTTP/1.1 407')
         then
          if (http.authType = httpAuthNtlm) and (http.FProxyAuthNTLMState = ntlmMsg1) then
           begin
            i := Pos(AnsiString(' NTLM '), pkt);
            if i > 0 then
              begin
               inc(i, 6);
               j := PosEx(AnsiString(CRLF), pkt, i);
               s := Copy(pkt, i, j-i);
               http.FProxyNTLMMsg2Info  := NtlmGetMessage2(s);
               http.FProxyAuthNTLMState := ntlmMsg3;
               myOnConnected(sender, 0);
  //             connected(NIL, 0);
               exit;
              end
             else
              begin

              end;
           end
          else
           begin
//           TriggerSessionClosed();
             DataAvailableError(socksAuthenticationFailed, 'PROXY: Invalid user/password');
//           eventError:=EC_proxy_badPwd
             eventError  := 1;
           end
        else
          begin
//           eventError:=EC_proxy_unk;
           eventError:=1;
           DataAvailableError(socksAuthenticationFailed, pkt);
//           eventMsg:=pkt;
          end;

      // pass what follows to the snac cruncher
      pkt:= FMyBeautifulSocketBuffer;
      FMyBeautifulSocketBuffer:='';

      if eventError <> 0 then
        begin
    //    eventMsg := WSocketErrorDesc(eventInt);
    //    eventMsg := '';
//        notifyListeners(IE_error);
//        disconnect;
          Close;
         exit;
        end;
      end;
      if pkt > '' then
       if Assigned(OnDataReceived) then
         OnDataReceived(Sender, Error, pkt);
    end;
// ClientConnected
end;

 {$IFDEF USE_SSL}
procedure TRnQSocket.SockSslHandshakeDone(Sender: TObject; ErrCode: Word;
    PeerCert: TX509Base; var Disconnect: Boolean);
begin
  ClientConnected2(Sender, ErrCode);
end;

procedure TRnQSocket.StartTLS;
begin
  isSSL := True;
   begin
    OnSslHandshakeDone := SockSslHandshakeDone;
    if not Assigned(SslCtxt) then
      SslCtxt := TSslContext.Create(self);
    SslCtxt.SslCipherList := 'DEFAULT:@STRENGTH';

//    SslCtxt.SslVersionMethod     :=  sslV23;
    SslCtxt.SslVersionMethod     :=  sslTLS_V1;
    SslCtxt.SslVerifyPeer := False;
//    SslCtxt.SslVerifyDepth := 1;
    SslCtxt.SslVerifyPeerModes := [SslVerifyMode_NONE];
    SslCtxt.SslVerifyDepth := 9;
    SslContext := SslCtxt;
    SslMode := sslModeClient;
    SslEnable := True;
    StartSslHandshake;
   end;
end;
 {$ENDIF USE_SSL}

procedure TRnQSocket.Close;
begin
  if Assigned(FOldOnSessionConnected) then
    FOnSessionConnected := FOldOnSessionConnected;
  FOldOnSessionConnected := nil;
  if Assigned(FOldOnDataAvailable) then
    FOnDataAvailable := FOldOnDataAvailable;
  FOldOnDataAvailable := nil;
//  if not FSecureClient.Active then
//    FErrorOccured := true;
  inherited;

end;

procedure TRnQSocket.ClientConnected(Sender: TObject; Error: Word);
begin
 {$IFDEF USE_SSL}
  if isSSL and (Error=0) then
    begin
      try
        self.SslEnable := True;
        self.StartSslHandshake;
       except
         on E: Exception do
           begin
             if Assigned(FOnSocksError) then
               FOnSocksError(Self, 1001, E.Classname + ' ' + E.Message);
             Close;
           end;
      end;
    end
   else
 {$ENDIF USE_SSL}
    ClientConnected2(Sender, Error);
end;


procedure TRnQSocket.ClientConnected2(Sender: TObject; Error: Word);
var
  FOldOnData : TDataAvailable;
begin
  FSocksConnected := True;
  if Assigned(FOldOnSessionConnected) then
  begin
    FOldOnData := FOnDataAvailable;
    FOldOnSessionConnected(Sender, Error);
//    if TMethod(FOnDataAvailable).Code <> TMethod(FOldOnData).Code then
//    begin
//      FOldOnDataAvailable := FOnDataAvailable;
//      FOnDataAvailable := FOldOnData;
//    end;
    if Assigned(FOldOnDataAvailable) then
      FOnDataAvailable := FOldOnDataAvailable;
    FOldOnDataAvailable := nil;
  end
  else
  if Assigned(FOnSessionConnected) then
    FOnSessionConnected(Sender, Error) ;

//  if FSecureClient.Enabled and FSecureClient.Active then
//    DoSSLEstablished();
end;

procedure TRnQSocket.DisableProxy();
begin
    self.http.authType := RnQNet.httpAuthNone;
    self.http.user:='';
    self.http.pwd:='';
    self.http.addr:='';
    self.http.port:='';
    self.http.enabled := False;
    self.socksServer:='';
    self.socksPort:='';
    self.SocksAuthentication:=socksNoAuthentication;
end;


procedure TRnQSocket.proxySettings(proxy : TProxy);
  procedure disblHTTP;
  begin
    http.authType := RnQNet.httpAuthNone;
    http.user:='';
    http.pwd:='';
    http.addr:='';
    http.port:='';
    http.enabled := False;
  end;
  procedure disblSOCKS;
  begin
    socksServer:='';
    socksPort:='';
    SocksAuthentication:=socksNoAuthentication;
  end;

begin
  if self.State <> wsClosed then
    exit;
//  proxy_http_Enable(sock);
  case proxy.proto of
    PP_NONE:
        begin
          disblHTTP;
          disblSOCKS;
        end;
    PP_SOCKS4,
    PP_SOCKS5:
        begin
          disblHTTP;
          socksServer:=proxy.addr.host;
          socksPort := intToStr(proxy.addr.port);
          if proxy.proto = PP_SOCKS4 then
            socksLevel:='4'
           else
            socksLevel:='5';
          if proxy.auth then
            SocksAuthentication:=socksAuthenticateUsercode
           else
            SocksAuthentication:=socksNoAuthentication;
        //  if proxy.NTLM then sock.SocksAuthentication := s
        //  if not proxy.NTLM then
            begin
            //  sock.SocksAuthentication :=
              SocksUsercode:=proxy.user;
              SocksPassword:=proxy.pwd;
            end
        end;
    PP_HTTPS:
        begin
          disblSOCKS;
          http.enabled := True;
          http.addr:=proxy.addr.host;
          http.port:= IntToStr(proxy.addr.port);
          if proxy.auth then
            begin
                http.user := proxy.user;
                http.pwd  := proxy.pwd;
                if proxy.NTLM then
                  http.authType := RnQNet.httpAuthNtlm
                else
                  http.authType := RnQNet.httpAuthBasic;
            end
           else
            http.authType := RnQNet.httpAuthNone;
        end;
  end;
end; // proxySettings

procedure TRnQSocket.getFreePort;
begin
  Port := '0';
end;

{
procedure TRnQSocket.CloseDelayed;
begin
  inherited;

end;

function TRnQSocket.RealSend(Data: Pointer; Len: Integer): Integer;
begin

end;

function TRnQSocket.Receive(Buffer: Pointer; BufferSize: Integer): Integer;
begin

end;

function TRnQSocket.ReceiveStr: string;
begin

end;

function TRnQSocket.Send(Data: Pointer; Len: Integer): Integer;
begin

end;

function TRnQSocket.SendStr(const Str: String): Integer;
begin

end;
}

procedure TRnQSocket.TriggerSessionClosed(Error: Word);
begin
//  if FState <> wsClosed then begin
  if FState = wsClosed then
  begin
    Addr := FServerAddr;
    Port := FServerPort;
  end;
  inherited;
end;

function TRnQSocket.GetAddr1 : String;
begin
//  if FSocksConnected then
  if FState = wsClosed then
    Result := FAddrStr
   else
    Result := FServerAddr;
//   else
//    Addr;
end;

function TRnQSocket.GetAddr2 : String;
begin
  Result := GetAddr1 + ':' + Port;
end;
{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
{$IFDEF UseNTLMAuthentication}
function TRnQSocket.GetNTLMMessage1: AnsiString;
begin
    { Result := FNTLM.GetMessage1(FNTLMHost, FNTLMDomain);            }
    { it is very common not to send domain and workstation strings on }
    { the first message                                               }
    Result := NtlmGetMessage1('', '');
end;



{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
function TRnQSocket.GetNTLMMessage3(const ForProxy: Boolean): AnsiString;
var
    Hostname : String;
begin
    { get local hostname }
    try
        Hostname := LocalHostName;
    except
        Hostname := '';
    end;

    { domain is not used             }
    { hostname is the local hostname }
    if ForProxy then begin
        Result := NtlmGetMessage3('',
                                  Hostname,
                                  http.user, //FProxyUsername,
                                  http.pwd,// FProxyPassword,
                                  http.FProxyNTLMMsg2Info.Challenge)
    end
    else begin
        Result := NtlmGetMessage3('',
                                  Hostname,
{                                 FNTLMUsercode, FNTLMPassword, }
//                                  FCurrUsername, FCurrPassword,
                                  http.user, http.pwd,
                                  http.FNTLMMsg2Info.Challenge);
    end;
end;
function TRnQSocket.GetNTLMMessage3_RD(const ForProxy: Boolean; Domain : String = ''): AnsiString;
var
  Hostname, usr : String;
//  res : AnsiString;
  nmd: Boolean;
  AuthDt: RawByteString;
  i: Integer;
begin
  if secInit and (http.user= '') and (http.pwd = '') then
   begin
     SetLength(AuthDt, sizeof(http.FProxyNTLMMsg2Info.Challenge));
     CopyMemory(@AuthDt[1], @http.FProxyNTLMMsg2Info.Challenge[0], Length(AuthDt));
     AddAuthorizationHeader(Result, 'NTLM', AuthDt,
         http.user, http.pwd, nmd, ForProxy, @pSeq);
   end
  else
   begin
    usr := http.user;
    if Domain > '' then
      begin
       if AnsiStartsText(Domain, http.user) then
         usr := Copy(http.user, Length(Domain)+2, length(http.user))
      end
     else
      if Pos('\', http.user) > 0 then
       begin
         i := Pos('\', http.user);
         Domain := copy(http.user, 1, i-1);
         usr := Copy(http.user, i+1, length(http.user))
       end;

      { get local hostname }
      try
          Hostname := LocalHostName;
      except
          Hostname := '';
      end;

      { domain is not used             }
      { hostname is the local hostname }
      if ForProxy then begin
          Result := NtlmGetMessage3(Domain,
                                    Hostname,
                                    usr, //FProxyUsername,
                                    http.pwd,// FProxyPassword,
                                    http.FProxyNTLMMsg2Info.Challenge)
      end
      else begin
          Result := NtlmGetMessage3('',
                                    Hostname,
  {                                 FNTLMUsercode, FNTLMPassword, }
  //                                  FCurrUsername, FCurrPassword,
                                    usr, http.pwd,
                                    http.FNTLMMsg2Info.Challenge);
      end;
    end;
end;
{$ENDIF}

 {$IFDEF RNQ_FULL}

procedure SetupProxy(var httpCli: TSslHttpCli);
begin
  httpCli.SocksServer := '';
  httpCli.SocksPort := '';
  httpCli.SocksAuthentication := socksNoAuthentication;
  httpCli.Proxy := '';
  httpCli.ProxyPort := '';
  if (StrUtils.StartsText('https://', httpCli.URL)) then
    httpCli.SslContext := TSslContext.Create(nil);

  if (MainProxy.proto in [PP_SOCKS4, PP_SOCKS5, PP_HTTPS]) then
  case MainProxy.proto of
    PP_SOCKS4, PP_SOCKS5:
    begin
      // sock.socksServer:=proxy.addr[proxy.proto].host;
      // sock.socksPort:=proxy.addr[proxy.proto].port;
      httpCli.SocksServer := MainProxy.addr.host;
      httpCli.SocksPort := intToStr(MainProxy.addr.port);

      if MainProxy.proto = PP_SOCKS4 then
        httpCli.SocksLevel := '4'
      else
        httpCli.SocksLevel := '5';
      httpCli.SocksAuthentication := socksNoAuthentication;
      if MainProxy.auth then
        httpCli.SocksAuthentication := socksAuthenticateUsercode;
      // if proxy.NTLM then sock.SocksAuthentication := s
      // if not proxy.NTLM then
      begin
        // sock.SocksAuthentication :=
        httpCli.SocksUsercode := MainProxy.user;
        httpCli.SocksPassword := MainProxy.pwd;
      end
    end;
    PP_HTTPS:
    begin
      httpCli.Proxy := MainProxy.addr.host;
      httpCli.ProxyPort := intToStr(MainProxy.addr.port);
      // mainfrm.httpClient.ProxyConnection
      if MainProxy.auth then
      begin
        httpCli.ProxyUsername := MainProxy.user;
        httpCli.ProxyPassword := MainProxy.pwd;
        if MainProxy.NTLM then
          httpCli.ProxyAuth := OverbyteIcsHttpProt.httpAuthNtlm
        else
          httpCli.ProxyAuth := OverbyteIcsHttpProt.httpAuthBasic;
      end
    end
  end;
end;

function LoadFromURL(const URL: String; var fn: String; Threshold: LongInt = 0; ExtByContent: boolean = false;
  DoPOST: boolean = false; POSTData: RawByteString = ''; showErrors: boolean = true): boolean;
var
  fs: TMemoryStream;
begin
  fs := nil;
  Result := LoadFromURL(URL, fn, fs, Threshold, ExtByContent, DoPOST, POSTData, showErrors);
end;

function LoadFromURL(const URL: String; var fs: TMemoryStream; Threshold: LongInt = 0; ExtByContent: boolean = false;
  DoPOST: boolean = false; POSTData: RawByteString = ''; showErrors: boolean = true): boolean;
var
  fn: String;
begin
  Result := LoadFromURL(URL, fn, fs, Threshold, ExtByContent, DoPOST, POSTData, showErrors);
end;

function LoadFromURL(const URL: String; var fn: String; var fs: TMemoryStream; Threshold: LongInt = 0;
  ExtByContent: boolean = false; DoPOST: boolean = false; POSTData: RawByteString = ''; showErrors: boolean = true): boolean;
var
  // idx: Integer;
  AvStream: TMemoryStream;
  httpCli: TSslHttpCli;
  ft: TPAFormat;
begin
  Result := false;
  // idx:=  HasAvatar(UIN);
  try
    httpCli := TSslHttpCli.Create(nil);
    httpCli.URL := URL;
    httpCli.FollowRelocation := True;
    SetupProxy(httpCli);

    AvStream := TMemoryStream.Create;
    httpCli.RcvdStream := AvStream;

    Result := false;
    try
      if Threshold > 0 then
      begin
        httpCli.Head;
        if httpCli.ContentLength > Threshold then
          Exit;
      end;
      // httpCli.Options
      try
        // httpCli.MultiThreaded := True;
        // httpCli.ThreadDetach;
        if DoPOST then
        begin
          httpCli.SendStream := TMemoryStream.Create;
          httpCli.SendStream.Write(POSTData[1], Length(POSTData));
          httpCli.SendStream.Seek(0, 0);
          httpCli.Post;
        end
        else
          httpCli.Get;
        // httpCli.ThreadAttach;
        Result := true;
      except
        on E: EHttpException do
          if showErrors then
            if E.ErrorCode = 3 then
              msgDlg(getTranslation(SSLError, [E.Message]), false, mtError)
            else if E.ErrorCode <> 404 then
              msgDlg(getTranslation(ProxyUnkError, [E.ErrorCode, E.Message]), false, mtError)
      end;

      if Result then
      begin
        AvStream.Seek(0, 0);
        if not (fs = nil) then
        begin
          AvStream.SaveToStream(fs);
          fs.Seek(0, 0);
        end
        else if not(fn = '') then
        begin
          if ExtByContent then
          begin
            ft := DetectFileFormatStream(AvStream);
            if ft <> PA_FORMAT_UNK then
              fn := ChangeFileExt(fn, PAFormat[ft]);
          end;
          AvStream.SaveToFile(fn);
        end;
      end;
    finally
      httpCli.Free;
      FreeAndNil(AvStream);
    end;
  except

  end;
end;

function LoadFromURL0(const URL: String; var fn: String; Threshold: LongInt = 0; ExtByContent: Boolean = false): Boolean;
// {$IFNDEF RNQ_LITE}
var
  AvStream: TMemoryStream;
  httpCli: THttpCli;
  ft : TPAFormat;
begin
  Result := False;

 try
  httpCli := THttpCli.Create(NIL);
//  proxySettings(httpCli.CtrlSocket);
      begin
       httpCli.socksServer:='';
       httpCli.socksPort:='';
       httpCli.SocksAuthentication:=socksNoAuthentication;
       httpCli.Proxy := '';
       httpCli.ProxyPort := '';
      end;
//proxysettings(httpCli.CtrlSocket);
  begin

    if //proxy.enabled and
      (MainProxy.proto in [PP_SOCKS4, PP_SOCKS5, PP_HTTPS]) then
       case MainProxy.proto of
         PP_SOCKS4,
         PP_SOCKS5:
            begin
          //  sock.socksServer:=proxy.addr[proxy.proto].host;
          //  sock.socksPort:=proxy.addr[proxy.proto].port;
              httpCli.SocksServer:=MainProxy.addr.host;
              httpCli.socksPort := intToStr(MainProxy.addr.port);

              if MainProxy.proto = PP_SOCKS4 then
                httpCli.SocksLevel:='4'
              else
                httpCli.socksLevel:='5';
              httpCli.SocksAuthentication:=socksNoAuthentication;
              if MainProxy.auth then
                httpCli.SocksAuthentication:=socksAuthenticateUsercode;
            //  if proxy.NTLM then sock.SocksAuthentication := s
            //  if not proxy.NTLM then
                begin
                //  sock.SocksAuthentication :=
                  httpCli.SocksUsercode := MainProxy.user;
                  httpCli.SocksPassword := MainProxy.pwd;
                end
            end;
          PP_HTTPS:
           begin
            httpCli.Proxy := MainProxy.addr.host;
            httpCli.ProxyPort := intToStr(MainProxy.addr.port);
        //    mainfrm.httpClient.ProxyConnection
            if MainProxy.auth then
             begin
              httpCli.ProxyUsername:= MainProxy.user;
              httpCli.ProxyPassword:= MainProxy.pwd;
              if MainProxy.NTLM then
                httpCli.ProxyAuth := OverbyteIcsHttpProt.httpAuthNtlm
               else
                httpCli.ProxyAuth := OverbyteIcsHttpProt.httpAuthBasic;
             end
           end
      end
  end;

  AvStream:= TMemoryStream.Create;

  httpCli.RcvdStream:= AvStream;
  httpCli.URL:= URL;
  result := False;
  try
    if Threshold > 0 then
     begin
      httpCli.Head;
      if httpCli.ContentLength > Threshold then
        Exit;
     end;
//    httpCli.Options
    try
//     httpCli.MultiThreaded := True;
//     httpCli.ThreadDetach;
//     httpCli.
     httpCli.Get;
//     httpCli.ThreadAttach;
     Result := True;
    except
     on e:EHttpException do
      if e.ErrorCode <> 404 then
        msgDlg(getTranslation(ProxyUnkError, [e.ErrorCode, e.Message]), False, mtError)
    end;
//    httpCli.
    if Result then
     begin
       AvStream.Seek(0,0);
       if ExtByContent then
        begin
         ft := DetectFileFormatStream(AvStream);
         if ft <> PA_FORMAT_UNK then
          fn := ChangeFileExt(fn, PAFormat[ft]);
        end;
       AvStream.SaveToFile(fn);
     end;
   finally
    httpCli.Free;
    AvStream.Clear;
    FreeAndNil(AvStream);
  end;
 except

 end;
end;
(* {$ELSE}
begin
  msgDlg('Not supported in Lite version', mtWarning);
end;
// {$ENDIF RNQ_LITE} *)
 {$ENDIF RNQ_FULL}

function HeaderFromURL(const URL: String): String;
var
  AvStream: TMemoryStream;
  httpCli: TSslHttpCli;
begin
  Result := '';
  try
    httpCli := TSslHttpCli.Create(nil);
    httpCli.URL := URL;
    SetupProxy(httpCli);

    AvStream := TMemoryStream.Create;
    httpCli.RcvdStream := AvStream;

    try
      httpCli.Head;
      Result := httpCli.ContentType;
    except end;
  finally
    httpCli.Free;
    FreeAndNil(AvStream);
  end;
end;



//FINALIZATION
//  ClearProxyArr(AllProxies);
end.
