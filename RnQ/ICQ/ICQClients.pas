unit ICQClients;

{$I RnQConfig.inc}
{$I NoRTTI.inc}

interface
 uses
   Windows, RDGlobal, ICQContacts;

  procedure LoadClientsDefs;
  procedure getICQClientPicAndDesc(cnt: TICQContact; var pPic: TPicName; var CliDesc: String);

var
  ClientsDefLoaded: Boolean = false;

implementation

 uses
 {$IFDEF USE_ZIP}
   RnQZip,
 {$ENDIF USE_ZIP}
 {$IFDEF UNICODE}
   AnsiStrings,
 {$ENDIF}
   SysUtils, StrUtils,
   OverbyteIcsUtils,
   RQUtil, RnQStrings, RnQLangs, RnQBinUtils,
   RQThemes, RDFileUtil, RDUtils, RnQGlobal, RnQPics,
   Protocol_ICQ, ICQConsts,
   themesLib
   ;

const
// Client IDs
  ANDRQclientID   =$FFFFFF7F;
  RQclientID      =$FFFFFF7F;
  MIRANDAclientID =$FFFFFFFF;
  MIRANDA07ID     =$7FFFFFFF;
  STRICQclientID  =$FFFFFF8F;
  YSMclientID     =$FFFFFFAB;
  MICQclientID    =$7d0001ea;
  MICQ2clientID   =$ffffff42;
  LICQclientID    =$7d000000;
//  vICQclientID    =$04031980;
  JIMMclientID    =$FFFFFFFE;

  PIC_CLI_MIR                     = TPicName('miranda');
  PIC_CLI_JIMM                    = TPicName('jimm');
  PIC_CLI_LITE                    = TPicName('icqlite');
  PIC_CLI_2000                    = TPicName('icq2000');
  PIC_CLI_2001                    = TPicName('icq2001');
  PIC_CLI_2002                    = TPicName('icq2002');
  PIC_CLI_2003                    = TPicName('icq2003');
  PIC_CLI_2003b                   = TPicName('icq2003b');
  PIC_CLI_4                       = TPicName('icq4');
  PIC_CLI_5                       = TPicName('icq5');
  PIC_CLI_51                      = TPicName('icq51');
  PIC_CLI_6                       = TPicName('icq6');
  PIC_CLI_rbr                     = TPicName('rambler');
  PIC_CLI_LICQ                    = TPicName('licq');
  PIC_CLI_MICQ                    = TPicName('micq');
//  PIC_CLI_                     = 'kxicq =
  PIC_CLI_MAC                     = TPicName('macicq');
  PIC_CLI_QIPPDA                  = TPicName('qippda');
//  PIC_CLI_                     = 'ysm =
  PIC_CLI_2GO                     = TPicName('icq2go');
  PIC_CLI_AIM                     = TPicName('aim');
  PIC_CLI_TRIL                    = TPicName('trillian');
  PIC_CLI_mchat                   = TPicName('mchat');

//unknown =
//;stricq =
  PIC_CLI_KOP                     = TPicName('kopete');

type
  TArr = array of RawByteString;
  TCliDefRec = record
    name : String;
    protoVer : Int32;
    DCInfo1,
    DCInfo2,
    DCInfo3 : UInt32;
    Caps, NoCaps : TArr;
    checkBy : set of (CB_proto, CB_DC1, CB_DC2, CB_DC3, CB_MatchCaps, CB_Caps, CB_NoCaps);
    Version : String;
    PicName : TPicName;
   end;

var
  CliDefs : array of TCliDefRec;


procedure LoadClientsDefs;
var
  lastIDX: Integer;

  procedure ParseCaps(var pArr: TArr; pCaps: String);
    function isHex(const ch: Char): Boolean;
    begin
     Result := ((Ch >= '0') and (Ch <= '9')) or
               ((Ch >= 'a') and (Ch <= 'f'))
    end;
  var
    i: Integer;
    s: String;
    idx: Integer;
  begin
    idx := -1;
    SetLength(pArr, 0);
    if Length(pCaps) = 0 then
      Exit;
    while pCaps > '' do
     begin
       i := 1;
       while (i <= Length(pCaps)) and not isHex(pCaps[i]) do
         inc(i);
       delete(pCaps, 1, i-1);
       i := 1;
       while (i <= Length(pCaps)) and isHex(pCaps[i]) do
         inc(i);
       s := Copy(pCaps, 1, i-1);
       if s > '' then
        begin
          Delete(pCaps, 1, i-1);
          inc(idx);
          SetLength(pArr, idx+1);
          pArr[idx] := hex2StrSafe(s);
        end;
     end;

  end;

const
  CliCFGFN = 'clients.cfg';
var
  Changed: Boolean;
  sp: TThemeSourcePath;
  sA: RawByteString;
  Size: Integer;
  Encoding: TEncoding;
  lPath, fn: String;
  lDef: RawByteString;
  line: String;
  v, k: String;
begin
  Changed := ClientsDefLoaded;
  ClientsDefLoaded := False;
  SetLength(CliDefs, 0);
  lPath := mypath+themesPath;
  fn := lPath + 'clients.zip';
  if FileExists(fn) then
    begin
     sp.pathType := pt_zip;
     sp.path := '';
//     sp.ArcFile := 'clients.zip';
//     sp.zp := NIL;
     sp.zp := TZipFile.Create;
     sp.zp.LoadFromFile(fn);
    end
   else
    begin
     sp.pathType := pt_path;
     sp.path := lPath + 'Clients' + PathDelim;
    end;
  try
    sA := loadFile(sp, CliCFGFN);
    Encoding := NIL;
    Size := TEncoding.GetBufferEncoding(tbytes(PAnsiChar(sA)), Encoding);
    lDef := Encoding.GetString(tbytes(PAnsiChar(sA)), Size, Length(sA) - Size);

    if lDef > '' then
      begin
       CLientsDefLoaded := True;
      end
     else
      begin
        if Changed then
          updateClients(NIL);
        Exit;
      end;

    while lDef>'' do
     begin
       line := trim(chopline(lDef));
       if (line='')or(line[1]=';') then
         continue;
       if (line[1]='[') and (line[length(line)]=']') then
        begin
          LastIDX := Length(CliDefs);
          SetLength(CliDefs, lastIDX + 1);
          continue;
        end;
      v := line;
      k := AnsiLowerCase(trim(chop('=',v)));
      v := trim(v);
      if k = 'name' then
          CliDefs[lastIDX].name := v
       else
      if k = 'protover' then
        begin
          Include(CliDefs[lastIDX].checkBy, CB_proto);
          CliDefs[lastIDX].protoVer := StrToIntDef(v, -1)
        end
       else
      if k = 'dcinfo1' then
        begin
          Include(CliDefs[lastIDX].checkBy, CB_DC1);
          CliDefs[lastIDX].DCInfo1 := hexToInt(v)
        end
       else
      if k = 'dcinfo2' then
        begin
          Include(CliDefs[lastIDX].checkBy, CB_DC2);
          CliDefs[lastIDX].DCInfo2 := hexToInt(v)
        end
       else
      if k = 'dcinfo3' then
        begin
          Include(CliDefs[lastIDX].checkBy, CB_DC3);
          CliDefs[lastIDX].DCInfo3 := hexToInt(v)
        end
       else
      if k = 'caps' then
        begin
          if (Length(v) > 0) and (v[1]='!') then
            begin
              Include(CliDefs[lastIDX].checkBy, CB_MatchCaps);
              Delete(v, 1, 1);
            end
           else
            Include(CliDefs[lastIDX].checkBy, CB_Caps);
          ParseCaps(CliDefs[lastIDX].Caps, AnsiLowerCase(v));
        end
       else
      if k = 'nocaps' then
        begin
          Include(CliDefs[lastIDX].checkBy, CB_NoCaps);
          ParseCaps(CliDefs[lastIDX].NoCaps, AnsiLowerCase(v));
        end
       else
      if k = 'version' then
        CliDefs[lastIDX].Version := v
       else
      if k = 'pic' then
        CliDefs[lastIDX].PicName := v


      ;
     end;
    theme.loadThemeScript('clients.pics.ini', sp);
   finally
    if (sp.pathType=pt_zip) and Assigned(sp.zp) then
      FreeAndNil(sp.zp);
  end;
  lDef := '';
  updateClients(NIL);
end;

procedure getClientPicAndDescExt(cnt: TICQContact; var pPic: TPicName; var CliDesc: String);
 var
  CapsArr: TArr;

    procedure assignCaps;
     var
      i, a: Integer;
    begin
      a := 0;
      for i in cnt.capabilitiesSm do
        begin
          inc(a);
          SetLength(CapsArr, a);
          CapsArr[a-1] := CAPS_sm2big(i);
        end;
      for i in cnt.capabilitiesBig do
        begin
          inc(a);
          SetLength(CapsArr, a);
          CapsArr[a-1] := BigCapability[i].v;
        end;
//      for i in capabilitiesXTraz do
//           XStatusArray[i].;
      if length(cnt.extracapabilities) > 15 then
       for I := 0 to length(cnt.extracapabilities) div 16 - 1 do
        begin
          inc(a);
          SetLength(CapsArr, a);
          CapsArr[a-1] := copy(cnt.extracapabilities, i*16+1, 16);
        end;
    end;

    function isMatch(pDef: TCliDefRec): Boolean;
      function CapsInArr(const pS: RawByteString): Boolean;
       var
        i: Integer;
      begin
        Result := False;
        for i := 0 to high(CapsArr) do
         if AnsiStartsStr(pS, CapsArr[i]) then
          begin
            Result := True;
            Exit;
          end;
      end;
   var
    i: Integer;
  begin
    Result := false;
    if CB_proto in pDef.checkBy then
      if cnt.proto <> pDef.protoVer then
        Exit;
    if CB_DC1 in pDef.checkBy then
      if cnt.lastUpdate_dw <> pDef.DCInfo1 then
        Exit;
    if CB_DC2 in pDef.checkBy then
      if cnt.lastinfoupdate_dw <> pDef.DCInfo2 then
        Exit;
    if CB_DC3 in pDef.checkBy then
      if cnt.lastStatusUpdate_dw <> pDef.DCInfo3 then
        Exit;

    if CB_MatchCaps in pDef.checkBy then
      if Length(pDef.Caps) <> Length(CapsArr) then
        Exit;
    if (CB_MatchCaps in pDef.checkBy) or (CB_Caps in pDef.checkBy) then
     begin
       for i := 0 to high(pDef.Caps) do
        if not CapsInArr(pDef.Caps[i]) then
          Exit;
     end;
    if (CB_NoCaps in pDef.checkBy) then
     begin
       for i := 0 to high(pDef.NoCaps) do
        if CapsInArr(pDef.NoCaps[i]) then
          Exit;
     end;
    Result := True;
  end;
  function GetCliName(pIdx: Integer): String;
    function EvalVers: String;
     var
      Res: String;
        procedure ProcessDCInfo(idx, val: Integer);
        var
          i, j, p, d: Integer;
          l, par, par2: String;
          parCh: Char;
        begin
          l := 'dcinfo' + IntToStr(idx) + '(';
          i := Pos(l, Res);
          if i > 0 then
            begin
              j := PosEx(')', Res, i+1);
              if j >0 then
               begin
                 par := copy(Res, i + Length(l), j-i - Length(l));
                 p := pos('#', par);
                 if p > 0 then
                   parCh := par[p]
                  else
                   begin
                     p := pos('+', par);
                     if p > 0 then
                       parCh := par[p]
                      else
                       begin
                         p := pos('*', par);
                         if p > 0 then
                           parCh := par[p]
                          else
                           begin
                             p := pos('@', par);
                             if p > 0 then
                               parCh := par[p]
                           end;
                       end;
                   end;
                 if p > 0 then
                  begin
                   par2 := Copy(par, p+1, 2);
                   d := StrToIntDef(par2, 4);
                   d := (val shl ((4-d) *8)) shr ((4-d) *8);
                   case parCh of
                    '#': l := IntToStr(d);
                    '+': l := format('%d%d%d%d', [byte(d shr 24), byte(d shr 16), byte(d shr 8), byte(d)]);
                    '*': l := ip2str(d);
                    else
                     l := ip2str(d);
                   end;
                  end
                 else
                  begin
                   l := ip2str(val);
                  end;
                 Res := Copy(Res, 1, i-1) + l + Copy(Res, j+1, 255);
               end;
            end;
        end;
        procedure ProcessCaps();
        var
          i, j, p, a, d : Integer;
          l, par, par2 : String;
          p2, l2 : RawByteString;
          parCh : Char;
        begin
          i := Pos('cap(', Res);
          if i > 0 then
            begin
              j := PosEx(')', Res, i+1);
              if j >0 then
               begin
                 par := copy(Res, i + 4, j-i - 4);
                 p := pos('#', par);
                 if p <= 0 then
                   begin
                     p := pos('+', par);
                     if p <= 0 then
                       begin
                         p := pos('*', par);
                         if p <= 0 then
                           p := pos('@', par);
                       end;
                   end;
                 if p > 0 then
                   begin
                    parCh := par[p];
                    l  := '';
                    par2 := Copy(par, p+1, 2);
                    d := StrToIntDef(par2, -1);
                    if d <0 then
                     if parCh = '@' then
                       d := 15
                      else
                       d := 4;
                    par2 := Copy(par, 1, p-1);
                    p2 := hex2StrSafe(par2);
                    l2 := '';
                    for a := low(CapsArr) to high(CapsArr) do
                     begin
                       if AnsiStartsStr(p2, CapsArr[a]) then
                        begin
                         l2 := CapsArr[a];
                         Break;
                        end;
                     end;
                    if l2 > '' then
                     begin
                       l2 := Copy(l2, (p div 2)+1, d);
                       if ParCh='@' then
                         begin
                          l := '';
                          for a := 1 to Length(l2) do
                           if Byte(l2[a]) > 30 then
                             l := l + AnsiChar(Byte(l2[a]))
                            else
                             break;
                         end
                        else
                         begin
                           if Length(l2) > 0 then
                            begin
                             if parCh = '+' then
                               par2 := ''
                              else
                               par2 := '.';
                             for a := 1 to Length(l2) do
                               l := l + IntToStr(Byte(l2[a])) + par2;
                             l := Copy(l, 1, Length(l)-1);
                            end;
                         end;
                     end
                     else
                      l := '??';
                   end
                  else
                   l := '?';
                 Res := Copy(Res, 1, i-1) + l + Copy(Res, j+1, 255);
               end;
            end;
        end;
    begin
      Res := AnsiLowerCase(cliDefs[pIdx].Version);
      ProcessDCInfo(1, cnt.lastUpdate_dw);
      ProcessDCInfo(2, cnt.lastinfoupdate_dw);
      ProcessDCInfo(3, cnt.lastStatusUpdate_dw);
      ProcessCaps();

      Result := Res;
//        CliDefs[pIdx].Version;
    end;
  var
    i: Integer;
  begin
    Result := CliDefs[pIdx].name;
    i := Pos('%', Result);
    if i > 0 then
     begin
       Result := StringReplace(Result, '%', EvalVers, []);
     end;
  end;
var
  i: Integer;
  s: String;
begin
  assignCaps;
  for i := low(CliDefs) to high(CliDefs) do
   begin
     if isMatch(CliDefs[i]) then
      begin
       s := CliDefs[i].Version;
       pPic := CliDefs[i].PicName;
       CliDesc := GetCliName(i);
       Exit;
      end;
   end;
  pPic := Str_unk;
  CliDesc := getTranslation(Str_unk);
end;


procedure getClientPicAndDescInt(c:TICQContact;
              var pPic: TPicName; var CliDesc: String);
//function getClientPicFor(c:Tcontact):string;
var
  s, capa: RawByteString;
  i: integer;
begin

{  if c=ICQ.myinfo then
	begin
    result := 'RnQ';
    exit;
  end;
}

  case c.lastupdate_dw of
    YSMclientID: begin pPic := 'ysm'; CliDesc := 'YSM'; end;
    ANDRQclientID: begin
                     pPic := PIC_CLI_NRQ;
                     CliDesc  := '&RQ ' +ip2str(C.lastinfoupdate_dw);
                   end;
    RnQclientID: begin
                   pPic   := PIC_CLI_RNQ;
                  CliDesc    := 'R&Q ';
                  if C.lastinfoupdate_dw and $40000000 <> 0 then
                   CliDesc    := CliDesc + 'Lite ';
                  CliDesc    := CliDesc + intToStr(C.lastinfoupdate_dw and ($FFFFFF)); // Rapid D
                  if C.lastinfoupdate_dw and $80000000 <> 0 then
                   CliDesc    := CliDesc + ' Test';

                  if CAPS_big_Build in c.capabilitiesBig then
                   CliDesc := CliDesc + 'Mikanoshi''s Build';
                 end;
    JIMMclientID: if c.lastStatusUpdate_dw = JIMMclientID then
                    begin
                      pPic := PIC_CLI_JIMM;
                      CliDesc := 'Jimm';
                    end;
    MIRANDAclientID,
    MIRANDA07ID:
       begin
         pPic := PIC_CLI_MIR;
         if C.lastinfoupdate_dw and $80000000 <> 0 then
          CliDesc :='Miranda '+ip2str(integer(C.lastinfoupdate_dw AND not $80000000))+ ' alpha'
         else
          CliDesc :='Miranda '+ip2str(integer(C.lastinfoupdate_dw));
       end;
  {  MIRANDACoffeeID:
       begin
         if c.lastinfoupdate_dw and $80000000 <> 0 then
          result:='Miranda Coffee '+ip2str(integer(c.lastinfoupdate_dw AND not $80000000))+ ' alpha'
         else
          result:='Miranda Coffee '+ip2str(integer(c.lastinfoupdate_dw));
       end;
  }
  //  YSMclientID: result:='YSM';
    MICQclientID,
    MICQ2clientID: begin
                     pPic := PIC_CLI_MICQ;
                     CliDesc := 'MICQ '+ip2str(C.lastinfoupdate_dw);
                   end;
    LICQclientID: begin
                    pPic:= PIC_CLI_LICQ;
                    CliDesc := 'LICQ '+ip2str(C.lastinfoupdate_dw);
                  end;
  //  RCQclientID: result := 'RCQ ' + ip2str(c.lastinfoupdate_dw); // Rapid D
    STRICQclientID: begin
                      pPic := 'stricq2';
                      CliDesc := 'StrICQ 2';
                    end;
    end;
  if pPic > '' then
    exit;

 s := c.extracapabilities;
 while s > '' do
  begin
   capa := chop(17,0,s);
   if pos(AnsiString('&RQinside'), capa) > 0 then
    begin
      pPic := PIC_CLI_NRQ;
      CliDesc := '&RQ '+ip2str(str2int(@capa[10]));
     exit;
    end else
    if pos(AnsiString('R&Qinside'), capa) > 0 then
    begin
     pPic := PIC_CLI_RNQ;
       CliDesc := 'R&Q ';
       if capa[14] = #1 then
         CliDesc := CliDesc + 'lite '
       else if capa[14] = #2 then
         CliDesc := CliDesc + 'test ';
       i := (Byte(capa[15]) shl 8) + Byte(capa[16]);
       if i > 0 then
         CliDesc := CliDesc + IntToStr(i)
       else
         CliDesc := CliDesc +ip2str(str2int(@capa[10]));
       if CAPS_big_Build in c.capabilitiesBig then
         CliDesc := CliDesc + 'Mikanoshi''s Build';
     exit;
    end else
    if pos(AnsiString('mChat icq'),capa) > 0 then
    begin
     pPic := PIC_CLI_mchat;
     CliDesc := 'mChat (' + copy(capa, 11, 6) + ')';
     exit;
    end else
//     if pos('Smaper v',capa) > 0 then
     if AnsiStartsText(AnsiString('Smaper '),capa) then
      begin
       pPic := PIC_CLI_smaper;
       CliDesc := 'Smaper (' + copy(capa, 9, 5) + ')';
       exit;
      end else
     if AnsiStartsText(AnsiString('PIGEON!'), capa) then
      begin
       pPic := PIC_CLI_pigeon;
       CliDesc := 'PIGEON!';
       exit;
      end else
     if AnsiStartsText(AnsiString(#$DE#$AD#$BE#$EF#$01),capa) then
      begin
       pPic := PIC_CLI_MAGENT;
       CliDesc := 'Mail.ru agent Symbian (' + Trim(copy(capa, 6, 4)) + ')';
       exit;
      end else
     if AnsiStartsText(AnsiString('J2ME m@agent'),capa) then
      begin
       pPic := PIC_CLI_MAGENT;
       CliDesc := 'Mail.ru agent Java';
       exit;
      end else
//  if pos(#$97#$B1#$27#$51#$24#$3C#$43#$34#$AD#$22#$D6#$AB#$F7#$3F#$14,capa) > 0 then
   if pos(Copy(BigCapability[CAPS_big_SecIM].v, 1, 15) ,capa) > 0 then
  	begin
    i:= Byte(capa[16]);
      case i of
        65..255: begin
                   pPic := PIC_CLI_SIM;
                   CliDesc := format('SIM %d.%d',[pred(i shr 6),i and 63]);
                   Exit;
                 end;
        1,64: begin
                pPic := PIC_CLI_KOP;
                CliDesc :='Kopete';
                Exit;
              end;
      end;
    end else
   if pos(AnsiString('SIM client'), capa) > 0 then
     begin
       pPic := PIC_CLI_SIM;
//       CliDesc :='SIM '+ip2str(BSwapInt(str2int(@capa[13])));
       CliDesc := 'SIM '+ip2str(icsSwap32(str2int(@capa[13])));
       Exit;
    end else
   if pos(AnsiString('Licq client'), capa) >0 then //4C69637120636C69656E742001670201
     begin
       pPic := PIC_CLI_LICQ;
       CliDesc := 'Licq ';//+ip2str(invert(str2int(@capa[13])));
       Exit;
     end else
   if pos(AnsiString('mICQ © R.K. '),capa) > 0 then
    begin
      pPic := PIC_CLI_MICQ;
//      CliDesc := 'mICQ '+ip2str(BSwapInt(str2int(@capa[13])));
      CliDesc := 'mICQ '+ip2str(icsSwap32(str2int(@capa[13])));
    end;

//   if pos(ExtCapability[2],capa) > 0 then
//     result := PIC_CLI_;
//   if pos(ExtCapability[3],capa) > 0 then
//     result:='MacICQ';
//   if pos(BigCapability[CAPS_big_SecIM].v,capa) > 0 then
//     result := PIC_CLI_TRIL else
//   if pos('mICQ © R.K. ',capa) > 0 then
//     result := PIC_CLI_m;
  end;
  if pPic > '' then
    exit;

  if CAPS_big_CryptMsg in c.capabilitiesBig then
  begin
   pPic := PIC_CLI_RNQ;
   CliDesc := 'R&Q';
   exit;
  end else
  if CAPS_big_SecIM in C.capabilitiesBig then
    begin
      pPic := PIC_CLI_TRIL;
      CliDesc := 'Trillian';
      exit;
    end else
     if CAPS_big_qipInf in C.capabilitiesBig then
      begin
        pPic := PIC_CLI_QIP;
        CliDesc := 'QIP Infium';
        if C.lastupdate_dw > 0 then
          CliDesc := CliDesc + ' (' +IntToStr(C.lastupdate_dw) + ')';
        exit;
      end
     else
      if (CAPS_big_qip2010 in C.capabilitiesBig) then
        begin
          pPic := PIC_CLI_QIP;
          CliDesc := 'QIP 2010';
          if C.lastupdate_dw > 0 then
            CliDesc := CliDesc + ' (' +IntToStr(C.lastupdate_dw) + ')';
          exit;
        end
       else
        if (CAPS_big_QIP in C.capabilitiesBig) then
         begin
          pPic := PIC_CLI_QIP;
          CliDesc := 'QIP 2005';
          if C.lastupdate_dw > 0 then
            CliDesc := CliDesc + ' (' + ip2str(C.lastupdate_dw) + ')';
          exit;
         end;

{
     for I := CAPS_Ext_CLI_First to CAPS_Ext_CLI_Last do
       if i in C.capabilitiesBig then
        begin
         CliDesc := BigCapability[i].s;
         if i = CAPS_big_QIP then
          if C.lastupdate_dw > 0 then
           CliDesc := CliDesc + ' (' +ip2str(C.lastupdate_dw) + ')';
         Exit;
        end;
}

if c.icq2go then
 begin
  if c.isAIM then
    begin
      pPic := PIC_CLI_AIM;
      CliDesc := 'AIM';
    end
   else
    if CAPS_big_Tril in c.capabilitiesBig then
      begin
        pPic := PIC_CLI_TRIL;
        CliDesc := 'Trillian';
      end
    else
     begin
      pPic := PIC_CLI_2GO;
       if C.isMobile then
         CliDesc := 'ICQ Mobile'
        else
         CliDesc := 'ICQ2GO';
     end;
 end
else
{if (CAPS_big_QIP in c.capabilitiesBig)
    or(CAPS_big_qipInf in c.capabilitiesBig)
    or(CAPS_big_qip2010 in c.capabilitiesBig)
  then
    begin
      pPic :=PIC_CLI_QIP;
      CliDesc := 'QIP';
      if C.lastupdate_dw > 0 then
        CliDesc := CliDesc + ' (' +IntToStr(C.lastupdate_dw) + ')';
    end
else}
if CAPS_big_LICQ in c.capabilitiesBig then
  begin
     pPic := PIC_CLI_LICQ;
     CliDesc := 'Licq';
  end
else
if CAPS_big_SecIM in c.capabilitiesBig then
  begin
     pPic := PIC_CLI_TRIL;
     CliDesc := 'Trillian';
  end
else
if CAPS_big_macICQ in c.capabilitiesBig then
  begin
    pPic := PIC_CLI_MAC;
    CliDesc := PIC_CLI_MAC;
  end
else
  case c.proto of
//    4: result := 'ICQ 98';
//    6: result := 'ICQ 99';
    7: begin
         pPic := PIC_CLI_2000;
         CliDesc := 'ICQ 2000';
       end;
    8:
      if CAPS_big_Tril in c.capabilitiesBig then
        begin
          pPic := PIC_CLI_TRIL;
          CliDesc := 'Trillian';
        end
       else
      if CAPS_sm_UTF8 in c.capabilitiesSm then
        begin
          pPic := PIC_CLI_2003;
          CliDesc := 'ICQ 2003';
        end
       else
      if CAPS_big_2001 in c.capabilitiesBig then
        begin
          pPic := PIC_CLI_2001;
          CliDesc := 'ICQ 2001';
        end
       else
      if CAPS_big_RTF in c.capabilitiesBig then
        begin
          pPic := PIC_CLI_2002;
          CliDesc := 'ICQ 2002';
        end
       else
        begin
        	pPic := PIC_CLI_2001;
          CliDesc := 'ICQ 2001';
        end;
    9:if (CAPS_big_RMBLR in c.capabilitiesBig) then
        begin
          pPic := PIC_CLI_rbr;
          CliDesc := 'Rambler ICQ';
        end
       else
        if CAPS_big_ICQ6 in c.capabilitiesBig then
          begin
           pPic := PIC_CLI_6;
           CliDesc := 'ICQ 6';
          end
         else
           if (CAPS_big_Xtraz in c.capabilitiesBig)
            and (CAPS_big_RTF in c.capabilitiesBig) then
             if CAPS_big_tZers in c.capabilitiesBig then
               begin
                 pPic := PIC_CLI_51;
                 CliDesc := 'ICQ 5.1';
               end
              else
               if CAPS_sm_FILE_TRANSFER in c.capabilitiesSm then
                 begin
                   pPic := PIC_CLI_5;
                   CliDesc := 'ICQ 5';
                 end
                else
                 begin
                  pPic := PIC_CLI_LITE;
                  CliDesc := 'ICQ Lite v4';
                 end
            else
             begin
               pPic := PIC_CLI_LITE;
               CliDesc := 'ICQ Lite';
             end;
    10:
     if CAPS_big_RTF in c.capabilitiesBig then
       begin
         pPic := PIC_CLI_2003b;
         CliDesc := 'ICQ 2003b';
       end
      else;
    11:
      if CAPS_big_qipWM in c.capabilitiesBig then
        begin
          pPic := PIC_CLI_QIPPDA;
          CliDesc := BigCapability[CAPS_big_qipWM].s
        end
       else
      if CAPS_big_qipSym in c.capabilitiesBig then
        begin
          pPic := PIC_CLI_QIPPDA;
          CliDesc := BigCapability[CAPS_big_qipSym].s
        end
      else;
    else
//      if CAPS_big_MTN in c.capabilitiesBig then result := '&RQ Typing' else
      if CAPS_big_Tril in c.capabilitiesBig then
        begin
          pPic := PIC_CLI_TRIL;
          CliDesc := 'Trillian';
        end
       else
      if CAPS_sm_UTF8 in c.capabilitiesSm then
        begin
          pPic := PIC_CLI_2003;
          CliDesc := 'ICQ 2003';
        end
       else
      if CAPS_big_2001 in c.capabilitiesBig then
        begin
          pPic := PIC_CLI_2001;
          CliDesc := 'ICQ 2001';
        end
       else
      if CAPS_big_RTF in c.capabilitiesBig then
        begin
          pPic := PIC_CLI_2002;
          CliDesc := 'ICQ 2002'
        end
       else
//        result := 'ICQ 2000';
        begin
          pPic := Str_unk;
          CliDesc := getTranslation(Str_unk);
        end;
    end;
end; // getClientPicAndDescInt


procedure getICQClientPicAndDesc(cnt: TICQContact; var pPic: TPicName; var CliDesc: String);
begin
  pPic := '';
  CliDesc := '';
  if cnt=NIL then
    exit;

 if ClientsDefLoaded then
   getClientPicAndDescExt(cnt, pPic, CliDesc)
  else
   getClientPicAndDescInt(cnt, pPic, CliDesc)
  ;
end;

end.