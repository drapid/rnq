(******************************************************)
(*                                                    *)
(*            EldoS SecureBlackbox Library            *)
(*                                                    *)
(*      Copyright (c) 2002-2007 EldoS Corporation     *)
(*           http://www.secureblackbox.com            *)
(*                                                    *)
(******************************************************)

{ $I SecBbox.inc}

{$J+}

unit RnQHTTPAuth;

interface
{$I ForRnQConfig.inc}
{$I NoRTTI.inc}

uses
  SysUtils,
  Classes,
  Windows,
  RDGlobal;

type PPointer = ^Pointer;
type PInteger = ^Integer;
type PLongWord = ^LongWord;
//function AddAuthorizationHeader(var Str : string; Scheme : string; AuthData : string;
//  UserName : string; Password : string; var NeedMoreData : boolean; ForProxy: boolean):boolean;
//  forward;

const
  cAuth  : string = 'Authorization: ';
  cAuth2 : string = 'authorization: ';
  cPAuth : string = 'Proxy-Authorization: ';
  cPAuth2: string = 'proxy-authorization: ';
  cBasic : string = 'basic';

var
  secInit : boolean = false; // daca pachetul pornit

{$ifdef BUILDER_USED}
{$HPPEMIT '#define SECURITY_WIN32'}
{$HPPEMIT '#include <sspi.h>'}
{$endif}

type
  
  {$ifdef VCL50}
  {$EXTERNALSYM CredHandle}
  {$endif}
  CredHandle = packed record
    dwLower : ^LongWord;
    dwUpper : ^LongWord;
  end;
  {$ifdef VCL50}
  {$EXTERNALSYM CtxtHandle}
  {$endif}
  CtxtHandle  = CredHandle;
  {$ifdef VCL50}
  {$EXTERNALSYM PCredHandle}
  {$endif}
  PCredHandle = ^CredHandle;
  {$ifdef VCL50}
  {$EXTERNALSYM PCtxtHandle}
  {$endif}
  PCtxtHandle = ^CtxtHandle;

  {$ifdef VCL50}
  {$EXTERNALSYM SecPkgInfo}
  {$endif}
  SecPkgInfoA = packed record
    fCapabilities : LongWord;        // Capability bitmask
    wVersion      : Word;            // Version of driver
    wRPCID        : Word;            // ID for RPC Runtime
    cbMaxToken    : LongWord;        // Size of authentication token (max)
    Name          : PAnsiChar;           // Text name
    Comment       : PAnsiChar;           // Comment
  end;
  {$ifdef VCL50}
  {$EXTERNALSYM PSecPkgInfo}
  {$endif}
  PSecPkgInfoA = ^SecPkgInfoA;

  {$ifdef VCL50}
  {$EXTERNALSYM SecBuffer}
  {$endif}
  SecBuffer = packed record
    cbBuffer   : LongWord;           // Size of the buffer, in bytes
    BufferType : LongWord;           // Type of the buffer (below)
    pvBuffer   : pointer;            // Pointer to the buffer
  end;
  {$ifdef VCL50}
  {$EXTERNALSYM PSecBuffer}
  {$endif}
  PSecBuffer = ^SecBuffer;

  {$ifdef VCL50}
  {$EXTERNALSYM SecBufferDesc}
  {$endif}
  SecBufferDesc = packed record
    ulVersion : LongWord;            // Version number
    cBuffers  : LongWord;            // Number of buffers
    pBuffers  : PSecBuffer;          // Pointer to array of buffers
  end;
  {$ifdef VCL50}
  {$EXTERNALSYM PSecBufferDesc}
  {$endif}
  PSecBufferDesc = ^SecBufferDesc;
  pint64 = ^int64;


  SEC_GET_KEY_FN = procedure (Arg : pointer; Principal : pointer; KeyVer : LongWord;
    Key : ppointer; Status : PInteger); stdcall;

  FREE_CREDENTIALS_HANDLE_FN      = function (cred : PCredHandle):Integer; stdcall;
  ACQUIRE_CREDENTIALS_HANDLE_FN_A = function (p1 : PAnsiChar; p2 : PAnsiChar; p3 : LongWord;
    p4 : pointer; p5 : pointer; p6 : SEC_GET_KEY_FN; p7 : pointer; p8 : PCredHandle;
    p9 : pint64):Integer; stdcall;
  QUERY_SECURITY_PACKAGE_INFO_FN_A = function (p1 : PAnsiChar; p2 : PSecPkgInfoA):Integer; stdcall;
  FREE_CONTEXT_BUFFER_FN           = function (buf : pointer):Integer; stdcall;
  INITIALIZE_SECURITY_CONTEXT_FN_A = function (p1 : PCredHandle; p2 : PCtxtHandle; p3 : PAnsiChar;
    p4 : LongWord; p5 : LongWord; p6 : LongWord; p7 : PSecBufferDesc; p8 : LongWord;
    p9 : PCtxtHandle; p10 : PSecBufferDesc; p11 : PLongWord; p12 : pint64):Integer; stdcall;
  COMPLETE_AUTH_TOKEN_FN         = function (p1 : PCtxtHandle; p2 : PSecBufferDesc):Integer; stdcall;
  ENUMERATE_SECURITY_PACKAGES_FN_A = function (p1 : PLongWord; p2 : PSecPkgInfoA):Integer; stdcall;
  DELETE_SECURITY_CONTEXT_FN     = function (ctx : PCtxtHandle):Integer; stdcall;

  secFuncsA = packed record
    pFreeCredentialsHandle     : FREE_CREDENTIALS_HANDLE_FN;
    pAcquireCredentialsHandle  : ACQUIRE_CREDENTIALS_HANDLE_FN_A;
    pQuerySecurityPackageInfo  : QUERY_SECURITY_PACKAGE_INFO_FN_A;
    pFreeContextBuffer         : FREE_CONTEXT_BUFFER_FN;
    pInitializeSecurityContext : INITIALIZE_SECURITY_CONTEXT_FN_A;
    pCompleteAuthToken         : COMPLETE_AUTH_TOKEN_FN;
    pEnumerateSecurityPackages : ENUMERATE_SECURITY_PACKAGES_FN_A;
    pDeleteSecurityContext     : DELETE_SECURITY_CONTEXT_FN;
  end;

  {$ifdef VCL50}
  {$EXTERNALSYM SEC_WINNT_AUTH_IDENTITY}
  {$endif}
  SEC_WINNT_AUTH_IDENTITY = packed record
    User           : PAnsiChar;
    UserLength     : LongWord;
    Domain         : PAnsiChar;
    DomainLength   : LongWord;
    Password       : PAnsiChar;
    PasswordLength : LongWord;
    Flags          : LongWord;
  end;
  PSEC_WINNT_AUTH_IDENTITY = ^SEC_WINNT_AUTH_IDENTITY;


  AUTH_SEQ = packed record
    NewConversation : boolean;
    hcred           : CredHandle;
    HaveCredHandle  : boolean;
    MaxToken        : LongWord;
    HaveCtxtHandle  : boolean;
    hctxt           : CredHandle;
    UUEncodeData    : boolean;
    AuthIdentity    : SEC_WINNT_AUTH_IDENTITY;
  end;
  PAUTH_SEQ = ^AUTH_SEQ;

function AddAuthorizationHeader(var Str : AnsiString; const Scheme : string; const AuthData : RawByteString;
  const UserName : string; const Password : string; var NeedMoreData : boolean; ForProxy: boolean; aSeq : PAUTH_SEQ):boolean;

procedure ValidateSecPacks(ls : TStringList);

procedure AuthInit(pAS : PAUTH_SEQ);
procedure AuthTerm(pAS : PAUTH_SEQ);

var
  secDLL  : string = '';
  secLib  : HMODULE;
  sfProcs : secFuncsA;

{$R-}
implementation

 {$IFDEF UNICODE}
uses
   AnsiStrings;
 {$ENDIF}

const

  {$ifdef VCL50}
  {$EXTERNALSYM SEC_WINNT_AUTH_IDENTITY_ANSI}
  {$endif}
  SEC_WINNT_AUTH_IDENTITY_ANSI    = 1;
  
  {$ifdef VCL50}
  {$EXTERNALSYM SECPKG_CRED_OUTBOUND}
  {$endif}
  SECPKG_CRED_OUTBOUND            = 2;
  
  {$ifdef VCL50}
  {$EXTERNALSYM SECBUFFER_TOKEN}
  {$endif}
  SECBUFFER_TOKEN                 = 2;

  TOKEN_SOURCE_NAME       : PAnsiChar = 'InetSvcs';

  {$ifdef VCL50}
  {$EXTERNALSYM SECURITY_NATIVE_DREP}
  {$endif}
  SECURITY_NATIVE_DREP            = $10;
  
  {$ifdef VCL50}
  {$EXTERNALSYM SEC_I_CONTINUE_NEEDED}
  {$endif}
  SEC_I_CONTINUE_NEEDED           = $90312;
  
  {$ifdef VCL50}
  {$EXTERNALSYM SEC_I_COMPLETE_NEEDED}
  {$endif}
  SEC_I_COMPLETE_NEEDED           = $90313;

  {$ifdef VCL50}
  {$EXTERNALSYM SEC_I_COMPLETE_AND_CONTINUE}
  {$endif}
  SEC_I_COMPLETE_AND_CONTINUE     = $90314;

  
procedure ValidateSecPacks(ls : TStringList);
type
  ASecPkgInfo=array[0..0] of SecPkgInfoA;
  PASecPkgInfo=^ASecPkgInfo;
var
  pSec : PSecPkgInfoA;
  zSec : PASecPkgInfo;
  cSec, i, j: LongWord;
  ss : Integer;
  found : boolean;
begin
  pSec := nil;
  ss := sfProcs.pEnumerateSecurityPackages(@cSec, @pSec);
  zSec := PASecPkgInfo(pSec);
  if ss = 0 then
    for i := ls.Count downto 1 do
    begin
      found := false;
      if LowerCase(ls[i - 1]) = LowerCase(cBasic) then
        continue;
      for j := 1 to cSec do
        if ls[i - 1] = zSec[j - 1].Name then
        begin
          found := true;
          break;
        end;
      if not found then
        ls.Delete(i - 1);
    end;
  if Assigned(pSec) then
    sfProcs.pFreeContextBuffer(pSec);
end;

{$R-}

procedure AuthIdFree(ai: PSEC_WINNT_AUTH_IDENTITY);
begin
  if Assigned(ai^.User) then
    AnsiStrings.StrDispose(ai^.User);
  if Assigned(ai^.Password) then
    AnsiStrings.StrDispose(ai^.Password);
  if Assigned(ai^.Domain) then
    AnsiStrings.StrDispose(ai^.Domain);
  fillchar(ai^, sizeof(ai^), 0);
end;

procedure AuthInit(pAS : PAUTH_SEQ);
begin
  pAS^.NewConversation := true;
  pAS^.HaveCredHandle := false;
  pAS^.HaveCtxtHandle := false;
  pAS^.UUEncodeData := true;
  AuthIdFree(@pAS^.AuthIdentity);
end;

procedure AuthTerm(pAS : PAUTH_SEQ);
begin
  if pAS^.HaveCredHandle then
    sfProcs.pFreeCredentialsHandle(@pAS^.hcred);
  pAS^.HaveCredHandle := false;
  if pAS^.HaveCtxtHandle then
    sfProcs.pDeleteSecurityContext(@pAS^.hctxt);
  pAS^.HaveCtxtHandle := false;
end;

const
  six2pr:array[0..63] of char = (
    'A','B','C','D','E','F','G','H','I','J','K','L','M',
    'N','O','P','Q','R','S','T','U','V','W','X','Y','Z',
    'a','b','c','d','e','f','g','h','i','j','k','l','m',
    'n','o','p','q','r','s','t','u','v','w','x','y','z',
    '0','1','2','3','4','5','6','7','8','9','+','/');

function UUencode(const s : string):string;
var
  x : Integer;
  i : Integer;
  o : Integer;
begin
  SetLength(result, Length(s) + ((Length(s) + 3) div 3) + 4);

  x := 1;
  o := 1;
  i := 0;
  while i < Length(s) do
  begin
    result[o] := six2pr[byte(s[x]) shr 2];
    inc(o);
    result[o] := six2pr[((byte(s[x]) shl 4) and $30) or ((byte(s[x + 1]) shr 4) and $f)];
    inc(o);
    result[o] := six2pr[((byte(s[x + 1]) shl 2) and $3c) or ((byte(s[x + 2]) shr 6) and 3)];
    inc(o);
    result[o] := six2pr[byte(s[x + 2]) and $3f];
    inc(o);
    inc(x, 3);
    inc(i, 3);
  end;

  if i = (Length(s) + 1) then
    result[o - 1] := '='
  else
  if i = (Length(s) + 2) then
  begin
    result[o - 1] := '=';
    result[o - 2] := '=';
  end;

  SetLength(result, o - 1);
end;

const
  pr2six:array[AnsiChar] of byte=(
    64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,
    64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,62,64,64,64,63,
    52,53,54,55,56,57,58,59,60,61,64,64,64,64,64,64,64,0,1,2,3,4,5,6,7,8,9,
    10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,64,64,64,64,64,64,26,27,
    28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,
    64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,
    64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,
    64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,
    64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,
    64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,
    64,64,64,64,64,64,64,64,64,64,64,64,64);

function UUdecode(const s : AnsiString) : string;
var
  nbytesdecoded : Integer;
  x : Integer;
  y : Integer;
  nprbytes : Integer;
begin
  x := 1;
  while (x <= Length(s)) and (pr2six[s[x]] <= 63) do
    inc(x);
  nprbytes := x - 1;
  nbytesdecoded := ((nprbytes + 3) div 4) * 3;
  SetLength(result, nbytesdecoded + 4);

  y := 1;
  x := 1;
  while nprbytes > 0 do
  begin
    result[y] := char((pr2six[s[x]] shl 2) or (pr2six[s[x + 1]] shr 4));
    inc(y);
    result[y] := char((pr2six[s[x + 1]] shl 4) or (pr2six[s[x + 2]] shr 2));
    inc(y);
    result[y] := char((pr2six[s[x + 2]] shl 6) or (pr2six[s[x + 3]]));
    inc(y);
    inc(x, 4);
    dec(nprbytes, 4);
  end;

  if (nprbytes and 3) <> 0 then
  begin
    if pr2six[s[x - 2]] > 63 then
      result[nbytesdecoded - 1] := #0
    else
      result[nbytesdecoded] := #0;
  end;

  SetLength(result, nbytesdecoded);
end;

procedure CrackUserAndDomain(const DomainAndUser : AnsiString; var User : AnsiString; var Domain : AnsiString);
const
  DefaultDomain : string = '';
var
  x : Integer;
  n : LongWord;
begin
  x := pos('/', DomainAndUser);
  if x <= 0 then
    x := pos('\', DomainAndUser);
  if x <= 0 then
  begin
    if DefaultDomain = '' then
    begin
      SetLength(DefaultDomain, MAX_COMPUTERNAME_LENGTH + 1);
      n := MAX_COMPUTERNAME_LENGTH + 1;
      GetComputerName(PChar(DefaultDomain), n);
      SetLength(DefaultDomain, n);
    end;
    Domain := DefaultDomain;
    User   := DomainAndUser;
  end
  else
  begin
    Domain := Copy(DomainAndUser, 1, x - 1);
    User   := Copy(DomainAndUser, x + 1, Length(DomainAndUser));
  end;
end;

function AuthConverse(pAS : PAUTH_SEQ; BuffIn : AnsiString; var BuffOut : AnsiString;
  var NeedMoreData : boolean; const Package : RawByteString;
  User : AnsiString; const Password : AnsiString):boolean;
var
  ss                : integer;
  Domain            : AnsiString;
  Lifetime          : int64;
  AuthIdentity      : SEC_WINNT_AUTH_IDENTITY;
  pAuthIdentity     : PSEC_WINNT_AUTH_IDENTITY;
  pspkg             : PSecPkgInfoA;
  OutBuffDesc       : SecBufferDesc;
  OutSecBuff        : SecBuffer;
  InBuffDesc        : SecBufferDesc;
  InSecBuff         : SecBuffer;
  buff              : pointer;
  ContextAttributes : LongWord;
  fReply            : boolean;
label
  ex;
begin
  result := false;
  //pauthIdentity := nil;

  if pAS^.UUEncodeData and (BuffIn <> '') then
    BuffIn := UUdecode(BuffIn);
  if pAS^.NewConversation then
  begin
    if (User <> '') or (Password <> '') then
    begin
      pAuthIdentity := @pAS^.AuthIdentity;
      if User <> '' then
        CrackUserAndDomain(User, User, Domain);

      AuthIdFree(@pAS^.AuthIdentity);
      pAS^.AuthIdentity.User           := AnsiStrings.StrNew(PAnsiChar(User));
      pAS^.AuthIdentity.UserLength     := Length(User);

      pAS^.AuthIdentity.Password       := AnsiStrings.StrNew(PAnsiChar(Password));
      pAS^.AuthIdentity.PasswordLength := Length(Password);

      pAS^.AuthIdentity.Domain         := AnsiStrings.StrNew(PAnsiChar(Domain));
      pAS^.AuthIdentity.DomainLength   := Length(Domain);

      pAS^.AuthIdentity.Flags := SEC_WINNT_AUTH_IDENTITY_ANSI;
    end
    else
    begin
      pAuthIdentity := @AuthIdentity;
      AuthIdentity.User           := AnsiStrings.StrNew(PAnsiChar(nil));
      AuthIdentity.UserLength     := 0;

      AuthIdentity.Password       := AnsiStrings.StrNew(PAnsiChar(nil));
      AuthIdentity.PasswordLength := 0;

      AuthIdentity.Domain         := AnsiStrings.StrNew(PAnsiChar(nil));
      AuthIdentity.DomainLength   := 0;

      AuthIdentity.Flags := SEC_WINNT_AUTH_IDENTITY_ANSI;
    end;

    ss := sfProcs.pAcquireCredentialsHandle(nil,    // New principal
      PAnsiChar(Package), // Package name
      SECPKG_CRED_OUTBOUND,
      nil,            // Logon ID
      pAuthIdentity,  // Auth Data
      nil,            // Get key func
      nil,            // Get key arg
      @pAS^.hcred,
      @Lifetime);

    if ss = 0 then
    begin
      pAS^.HaveCredHandle := true;
      ss := sfProcs.pQuerySecurityPackageInfo(PAnsiChar(Package), @pspkg);
    end;

    if ss <> 0 then
      exit;

    pAS^.MaxToken := pspkg^.cbMaxToken;
    sfProcs.pFreeContextBuffer(pspkg);
  end;

  GetMem(buff, pAS^.MaxToken);
  try
    OutBuffDesc.ulVersion := 0;
    OutBuffDesc.cBuffers  := 1;
    OutBuffDesc.pBuffers  := @OutSecBuff;

    OutSecBuff.cbBuffer   := pAS^.MaxToken;
    OutSecBuff.BufferType := SECBUFFER_TOKEN;
    OutSecBuff.pvBuffer   := buff;

    if BuffIn <> '' then
    begin
      InBuffDesc.ulVersion  := 0;
      InBuffDesc.cBuffers   := 1;
      InBuffDesc.pBuffers   := @InSecBuff;
    
      InSecBuff.cbBuffer    := Length(BuffIn);
      InSecBuff.BufferType  := SECBUFFER_TOKEN;
      InSecBuff.pvBuffer    := PAnsiChar(BuffIn);
    end;

    ContextAttributes := 0;
    if pAS^.NewConversation then
      ss := sfProcs.pInitializeSecurityContext(@pAS^.hcred, nil, TOKEN_SOURCE_NAME, 0, 0,
        SECURITY_NATIVE_DREP, nil, 0, @pAS^.hctxt, @OutBuffDesc, @ContextAttributes, @Lifetime)
    else
      ss := sfProcs.pInitializeSecurityContext(@pAS^.hcred, @pAS^.hctxt, TOKEN_SOURCE_NAME, 0, 0,
        SECURITY_NATIVE_DREP, @InBuffDesc, 0, @pAS^.hctxt, @OutBuffDesc, @ContextAttributes,
        @Lifetime);

    if ss < 0 then
      exit;

    pAS^.HaveCtxtHandle := true;

    fReply := OutSecBuff.cbBuffer <> 0;
    if (ss = SEC_I_COMPLETE_NEEDED) or (ss = SEC_I_COMPLETE_AND_CONTINUE) then
    begin
      if Assigned(sfProcs.pCompleteAuthToken) then
      begin
        ss := sfProcs.pCompleteAuthToken(@pAS^.hctxt, @OutBuffDesc);
        if ss < 0 then
          exit;
      end
      else
        exit;
    end;

    if fReply then
    begin
      SetLength(BuffOut, OutSecBuff.cbBuffer);
      Move(buff^, BuffOut[1], OutSecBuff.cbBuffer);
      if pAS^.UUEncodeData then
        BuffOut := UUencode(BuffOut);
    end;

    if pAS^.NewConversation then
      pAS^.NewConversation := false;

    NeedMoreData := (ss = SEC_I_CONTINUE_NEEDED) or (ss = SEC_I_COMPLETE_AND_CONTINUE);

    result := true;
  finally
    FreeMem(buff);
  end;
end;

function AddAuthorizationHeader(var Str : AnsiString; const Scheme : string; const AuthData : RawByteString;
  const UserName : string; const Password : string; var NeedMoreData : boolean; ForProxy: boolean; aSeq : PAUTH_SEQ):boolean;
var
  hs : AnsiString;
begin
  result := false;
  // pe startul NeedMoreData semnifica de asamenea cu FInAuth
  if not NeedMoreData then
    AuthInit(aSeq);
  if not AuthConverse(aSeq, AuthData, hs, NeedMoreData, Scheme, UserName, Password) then
    exit;
  if ForProxy then
    Str := cPAuth+Scheme+' '+hs
  else
    Str := cAuth+Scheme+' '+hs;
  result := true;
end;

(*
constructor TAuthHttpCli.Create(Aowner:TComponent);
begin
  inherited;
  FAuthPrefs := TStringList.Create;
  FInAuth := false;
  FMoreAuth := false;
  FAuthFailed := false;
end;

destructor TAuthHttpCli.Destroy;
begin
  FreeAndNil(FAuthPrefs);
  inherited;
end;


procedure TAuthHttpCli.TriggerHeaderEnd;
begin
  if (((AuthorizationRequest.Count > 0) and (Pos(' ',AuthorizationRequest[0]) < 1))
    or ((ProxyAuthRequest.Count > 0) and (Pos(' ',ProxyAuthRequest[0]) < 1)))
    and FInAuth then
  begin
    FAuthFailed := true;
    FInAuth := false;
  end;
  inherited;
  FInAuth := FMoreAuth;
end;
*)

type
  pboolean=^boolean;

(*
procedure TAuthHttpCli.TriggerBeforeHeaderSend(const Method : String; Headers : TStrings);
var
  x, y, meth, z : integer;
  meth2         : integer;
  hs, ad, ad2   : string;
  More          : boolean;
  BasicAuth     : string;
  BasicProxyAuth: string;
begin
  inherited;
  if not secInit then
    exit;
  //if (AuthorizationRequest.Count < 0) and (ProxyAuthRequest.Count < 0) then
  //  exit;
  ValidateSecPacks(AuthPrefs);

  // if we have not defined
  if (AuthPrefs.Count = 0) or (lowercase(AuthPrefs.Text) = cBasic + #13#10) then exit;

  BasicAuth := '';
  BasicProxyAuth := '';

  x := 0;
  while x < Headers.Count do
  begin
    if (LowerCase(Copy(Headers[x], 1, Length(cAuth2))) = cAuth2) then
    begin
      BasicAuth := Headers[x];
      Headers.Delete(x);
      continue;
    end;
    if (LowerCase(Copy(Headers[x], 1, Length(cPAuth2))) = cPAuth2) then
    begin
      BasicProxyAuth := Headers[x];
      Headers.Delete(x);
    end;
    inc(x);
  end;
    
  meth := -1;
  for x := 0 to AuthPrefs.Count - 1 do
  begin
    for y := 0 to AuthorizationRequest.Count - 1 do
    begin
      if LowerCase(Copy(Trim(AuthorizationRequest[y]), 1, Length(AuthPrefs[x]))) =
        LowerCase(AuthPrefs[x]) then
        begin
          meth := x;
          ad := Trim(AuthorizationRequest[y]);
          z := pos(' ', ad);
          if z > 0 then
            ad := Copy(ad, z + 1, Length(ad))
          else
            ad := '';
          break;
        end;
    end;
    if meth >= 0 then
      break;
  end;
  meth2 := -1;
  for x := 0 to AuthPrefs.Count - 1 do
  begin
    for y := 0 to ProxyAuthRequest.Count - 1 do
    begin
      if LowerCase(Copy(Trim(ProxyAuthRequest[y]), 1, Length(AuthPrefs[x]))) =
        LowerCase(AuthPrefs[x]) then
        begin
          meth2 := x;
          ad2 := Trim(ProxyAuthRequest[y]);
          z := pos(' ', ad2);
          if z > 0 then
            ad2 := Copy(ad2, z + 1, Length(ad2))
          else
            ad2 := '';
          break;
        end;
    end;
    if meth2 >= 0 then
      break;
  end;
  // aici noi avem un index de metoda din AuthPrefs in meth si meth2
  if (meth < 0) and (meth2 < 0) then
    exit;
  // departam inutila metoda din Headers daca nu "Basic" metoda se foloseste
  // si adaugam noua metoda a folosut a de mine
  if meth >= 0 then
    if LowerCase(AuthPrefs[meth]) <> cBasic then
    begin
      More := FInAuth;
      if not FInAuth then
        FInAuth := true;
      AddAuthorizationHeader(hs, AuthPrefs[meth], ad, FUsername, FPassword, More, false);
      Headers.Add(hs);
      //if FSavePrAuth <> '' then
      //  Headers.Add(FSavePrAuth);
      FMoreAuth := More;
    end
    else
    begin
      if BasicAuth <> '' then
        Headers.Add(BasicAuth)
      else
        FAuthFailed := true;
      FInAuth := false;
    end;
  if meth2 >= 0 then
    if LowerCase(AuthPrefs[meth2]) <> cBasic then
    begin
      More := FInAuth;
      if not FInAuth then
        FInAuth := true;
      AddAuthorizationHeader(hs, AuthPrefs[meth2], ad2, FProxyUsername, FProxyPassword, More, true);
      //FSavePrAuth := hs;
      Headers.Add(hs);
      FMoreAuth := More;
    end
    else
    begin
      if BasicProxyAuth <> '' then
        Headers.Add(BasicProxyAuth)
      else
        FAuthFailed := true;
      FInAuth := false;
    end;
  AuthorizationRequest.Clear;
  ProxyAuthRequest.Clear;
end;
*)

(*
procedure TAuthHttpCli.DoRequestSync(Rq : THttpRequest);
begin
  if FAuthFailed and not FMoreAuth then
    FAuthFailed := false;
  try
    inherited DoRequestSync(Rq);
    if FInAuth then
      FInAuth := false;
  except
    on E:EHttpException do
    begin
      if ((E.ErrorCode = 401) or (E.ErrorCode = 407)) and not FAuthFailed then
        DoRequestSync(Rq)
      else
        raise;
    end;
  end;
end;
*)

procedure InitAuthLib;
begin
  secInit := false;
  if Win32Platform = VER_PLATFORM_WIN32_NT then
    secDLL := 'security.dll'
  else
  if Win32Platform = VER_PLATFORM_WIN32_WINDOWS then
    secDLL := 'secur32.dll'
  else
    exit;
  {$ifdef VCL50}
  secLib := SafeLoadLibrary(secDLL);
  {$else}
  secLib := LoadLibrary(PChar(secDLL));
  {$endif}
  if secLib < 1 then
    exit;
  sfProcs.pFreeCredentialsHandle := FREE_CREDENTIALS_HANDLE_FN(GetProcAddress(secLib,
    'FreeCredentialsHandle'));
  sfProcs.pQuerySecurityPackageInfo := QUERY_SECURITY_PACKAGE_INFO_FN_A(GetProcAddress(secLib,
    'QuerySecurityPackageInfoA'));
  sfProcs.pAcquireCredentialsHandle := ACQUIRE_CREDENTIALS_HANDLE_FN_A(GetProcAddress(secLib,
    'AcquireCredentialsHandleA'));
  sfProcs.pFreeContextBuffer := FREE_CONTEXT_BUFFER_FN(GetProcAddress(secLib,
    'FreeContextBuffer'));
  sfProcs.pInitializeSecurityContext := INITIALIZE_SECURITY_CONTEXT_FN_A(GetProcAddress(secLib,
    'InitializeSecurityContextA'));
  sfProcs.pCompleteAuthToken := COMPLETE_AUTH_TOKEN_FN(GetProcAddress(secLib,
    'CompleteAuthToken'));
  sfProcs.pEnumerateSecurityPackages := ENUMERATE_SECURITY_PACKAGES_FN_A(GetProcAddress(secLib,
    'EnumerateSecurityPackagesA'));
  sfProcs.pDeleteSecurityContext := DELETE_SECURITY_CONTEXT_FN(GetProcAddress(secLib,
    'DeleteSecurityContext'));
  if not Assigned(sfProcs.pFreeCredentialsHandle) or
    not Assigned(sfProcs.pQuerySecurityPackageInfo) or
    not Assigned(sfProcs.pAcquireCredentialsHandle) or
    not Assigned(sfProcs.pFreeContextBuffer) or
    not Assigned(sfProcs.pInitializeSecurityContext) or
    not Assigned(sfProcs.pEnumerateSecurityPackages) then
  begin
    FreeLibrary(secLib);
    secLib := 0;
    exit;
  end;

  secInit := true;
end;

procedure TermAuthLib;
begin
  if secLib > 0 then
    FreeLibrary(secLib);
end;

initialization
  InitAuthLib;
finalization
  TermAuthLib;
end.

