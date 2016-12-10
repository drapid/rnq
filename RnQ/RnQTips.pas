{
This file is part of R&Q.
Under same license
}
unit RnQTips;
{$I RnQConfig.inc}
{$I NoRTTI.inc}

interface

uses
  Windows, Graphics, Types, Classes, SysUtils, Forms,
  events, RnQProtocol,
  tipDlg;


//  procedure TipAdd2(ev: Thevent; bmp2: tbitmap; seconds: Integer = -1);
  procedure TipAdd3(ev: Thevent; bmp2: tbitmap = NIL; pCnt: TRnQContact = NIL; seconds: Integer = -1);
//  procedure TipAdd(bmp: Tbitmap; seconds: Integer = -1); overload;
//  procedure TipAdd(ev: Thevent; seconds: Integer = -1); overload;
//  procedure TipAdd(gpBmp: tGPbitmap; seconds: Integer = -1); overload;
  procedure TipRemove(ev: Thevent); overload;
  procedure TipRemove(cnt: TRnQcontact); overload;
  procedure TipsUpdateByCnt(c: TRnQcontact);
  procedure TipsProced;
  procedure tipDrawEvent(destDC: HDC; ev: Thevent; pCnt: TRnQContact;
              var maxX, maxY: integer; calcOnly: Boolean; PPI: NativeInt);

implementation

 uses
   math, StrUtils, Base64,
   RDUtils, RnQGraphics32, RnQSysUtils, RnQBinUtils,
   RQUtil, RDGlobal, RQThemes, RnQLangs, RnQGlobal,
   globalLib, utilLib, RnQtrayLib, RnQPics,
 {$IFDEF UNICODE}
   AnsiStrings,
//   Character,
 {$ENDIF}
 {$IFDEF PROTOCOL_ICQ}
   protocol_ICQ, ICQConsts,
 {$ENDIF PROTOCOL_ICQ}
   Protocols_all,
   chatDlg, mainDlg;

procedure TipsDraw(Sender: TtipFrm; mode: Tmodes; info: Pointer; pMaxX, pMaxY: Integer; calcOnly : Boolean);
begin
  case mode of
    TM_EVENT:
      tipDrawEvent(Sender.Canvas.Handle, Thevent(info), NIL, pMaxX, pMaxY, calcOnly, Sender.CurrentPPI);
    TM_PIC:
      Sender.Canvas.Draw(0,0, TBitmap(info));
    TM_PIC_EX:
       DrawRbmp(Sender.Canvas.Handle, TRnQBitmap(info));
    TM_BDay:
      tipDrawEvent(Sender.Canvas.Handle, NIL, TRnQContact(info), pMaxX, pMaxY, calcOnly, Sender.CurrentPPI);
  end;
end;

procedure TipsDestroy(Sender: TtipFrm);
begin
  case Sender.info.mode of
    TM_EVENT:
      if Assigned(Sender.info.obj) then
       begin
        Thevent(Sender.info.obj).Free;
        Sender.info.obj := NIL;
       end;
    TM_PIC:
      if Assigned(Sender.info.obj) then
       begin
         TBitmap(Sender.info.obj).Free;
         Sender.info.obj := NIL;
       end;
    TM_PIC_EX:
      if Assigned(Sender.info.obj) then
       begin
         TRnQBitmap(Sender.info.obj).Free;
         Sender.info.obj := NIL;
       end;
    TM_BDay:
      if Assigned(Sender.info.obj) then
       begin
//         info.cnt.Free;
         Sender.info.obj := NIL;
       end;
  end;
end;

function CopyPic(BMP: TBitmap): TBitmap;
type
  PColor32 = ^TColor32;
  TColor32 = type Cardinal;
function SetAlpha(Color32: TColor32; NewAlpha: Integer): TColor32;
begin
  if NewAlpha < 0 then
    NewAlpha := 0
   else if NewAlpha > 255 then
    NewAlpha := 255;
  Result := (Color32 and $00FFFFFF) or (TColor32(NewAlpha) shl 24);
end;
var
//  R:TRect;
    r, C: Cardinal;
    PC: PColor32;
begin
  Result := Tbitmap.create;
   begin
    Result.PixelFormat      := bmp.PixelFormat;
    Result.SetSize(bmp.Width, bmp.Height);
    Result.Transparent      := bmp.Transparent;
    Result.TransparentColor := bmp.TransparentColor;
    Result.TransparentMode  := bmp.TransparentMode;
//      R := Rect(0 ,20, 100, 100);
//    FillRect(pic.Canvas.Handle, r, CreateSolidBrush(clRed));
    BitBlt(Result.Canvas.Handle, 0, 0, Result.Width, Result.Height,
           bmp.Canvas.Handle, 0, 0, SrcCopy);
    if Result.PixelFormat = pf32bit then
     begin
     for R:=0 to bmp.Height-1 do
      begin
       PC:=Pointer(Result.ScanLine[r]);
       for C:=0 to bmp.Width-1 do
        begin
          PC^:=SetAlpha(PC^,$FF);
          Inc(PC);
        end;
      end;
     end;
//          DrawText(pic.Canvas.Handle, PChar('Привет'), -1, R, DT_SINGLELINE);// or DT_VCENTER);
   end;
//  mode := TM_PIC;
//counter := 0;
//time := now;
//  ev := NIL;
end;

procedure TipAdd3(ev: Thevent; bmp2: tbitmap = NIL; pCnt: TRnQContact = NIL; seconds: Integer = -1);
var
//  isEv: Boolean;
//  isPic: Boolean;
  tipType: byte; {1 - ev, 2 - pic, 3 - birthday}

  item: TRnQTip;
//  cnt, idx: Integer;
//  minX, minY,
  needW, needH: Integer;
  work: Trect;
//  not_ok: Boolean;
//  rt: TRnQTip;

  sR: RawByteString;
  s3m: TMemoryStream;
  sl: Integer;
  i, k: Integer;
  pic: TBitmap;

  ti: TTipInfo;
  tempPic: TBitmap;
begin
//  if ( TipsMaxCnt = 0 ) then
  if MainPrefs.getPrefIntDef('show-tips-count', 20)=0 then
    exit;

  if locked then
    exit;

  if Assigned(ev) then
    tipType := 1
   else
    if Assigned(bmp2) then
      tipType := 2
     else
      if Assigned(pCnt) then
        tipType := 3
       else
        Exit;


  case tipType of
    1: begin // Show event
        if ( (ev<>NIL) and not (BE_TIP in supportedBehactions[ev.kind])
           ) or
           ( (ev.kind in [EK_msg,EK_url]) // user reading this message in chat window
             and chatFrm.isVisible
             and (ev.who.equals(chatFrm.thisChat.who))
           )
        then
          exit;

        if ev.kind in [EK_url,EK_msg,EK_contacts,EK_authReq,EK_automsg] then
        begin
      //    sa := ev.bInfo;
          sR := ev.getBodyBin;
          if ev.kind = EK_msg then
           begin
            i := AnsiPos(RnQImageTag, sR);
            k := PosEx(RnQImageUnTag, sR, i+10);
            if (i > 0) and (k > 5) then
            begin
             s3m := TMemoryStream.Create;
             s3m.SetSize(k-i-10);
             s3m.Write(sR[i+10], k-i-10);
             pic := NIL;
        //     p:=Copy(s, i+10, k-i-10);
        //     pic := TBitmap.Create;
             wbmp2bmp(s3m, pic);
             s3m.Free;
//             TipAdd(pic, 30);
             TipAdd3(NIL, pic, NIl, 30);
        //     Show(bmp);
             FreeAndNil(pic);
             exit;
            end;
        //    i := Pos('<RnQImageEx>', s);
        //    k := PosEx('</RnQImageEx>', s, i+12);
        //    if (i > 0) and (k > 5) then
        //    begin
        //     p:=Copy(s, i+12, k-i-12);
        //     s := '';
        //     s := Base64Decode(p);
        //     p := '';
        //        RnQPicStream := TMemoryStream.Create;
        //        RnQPicStream.SetSize(Length(s));
        //        RnQPicStream.Write(s[1], Length(s));
        //        vRnQpicEx := nil;
        //        if loadPic(RnQPicStream, vRnQpicEx) then
        //          TipAdd(vRnQpicEx, 30);
        //        vRnQpicEx.Free;
        //        RnQPicStream.Free;
        ////     Show(bmp);
        ////     FreeAndNil(pic);
        //     exit;
        //    end;
           end;
      //    p := sa;
         sl := Length(sR) + Length(ev.getBodyText);
         sR := '';
        end
         else
      //    p := ''
          sl := 0;
        ;

        work  := desktopWorkArea(Application.MainFormHandle);
        item  := TRnQTip.Create;

        needW := 0; needH := 0;
        tempPic := createBitmap(1, 1);
        tipDrawEvent(tempPic.Canvas.Handle, ev, NIL, needW, needH, True, RnQmain.currentPPI);
        tempPic.Free;
        needH := min(work.Bottom - work.Top - TipsMaxTop, needH);
      //  needW := min()
        item.time := ev.when;
        item.showSeconds := seconds;
        item.counter := item.showSeconds;
      //  item.ev := ev;

        with behaviour[ev.kind] do
        begin
          item.counter := TipTime;
          if behaviour[ev.kind].TipTimes then
            item.counter := item.counter * sl + TipTimePlus;
          if item.counter <= 0 then
           item.counter := 20;
        end;
    end;
   2: begin  // Show pic
        work  := desktopWorkArea(Application.MainFormHandle);
        needH := bmp2.Height;
        needW := bmp2.Width;

        item      := TRnQTip.Create;
        item.time := now;
        item.showSeconds := seconds;
        item.counter := seconds;
    end;
   3: begin // Show birthday
//        Exit;

        work  := desktopWorkArea(Application.MainFormHandle);
        item      := TRnQTip.Create;
        needW := 0; needH := 0;

        tempPic := createBitmap(1, 1, RnQmain.currentPPI);
        tipDrawEvent(tempPic.Canvas.Handle, NIL, pCnt, needW, needH, True, RnQmain.currentPPI);
        tempPic.Free;
        needH := min(work.Bottom - work.Top - TipsMaxTop, needH);
      //  needW := min()
        item.time := now;
        item.showSeconds := MAXWORD;
        item.counter := MAXWORD;
    end
   else
     Exit;
  end;

  case tipType of
    1: begin
//        item.frm.show(ev, item.x, item.Y);
        ti.mode := TM_EVENT;
        ti.obj := ev.clone;
      end;
    2: begin
//        item.form.show(bmp2, item.x, item.Y);
        ti.mode := TM_PIC;
        ti.obj := CopyPic(bmp2);
      end;
    3: begin
//        item.frm.show(pCnt, item.x, item.Y);
        ti.mode := TM_BDay;
        ti.obj := pCnt;
               end;
      end;

  if AddTip(item, ti, needW, needH) then
      begin
     item.form.onPaintTip  := TipsDraw;
     item.form.OnTipDestroy := TipsDestroy;
     item.form.alphablend:= MainPrefs.getPrefBoolDef('transparency-tray', False);
//      transparency.forTray;
     if item.form.alphablend then
//       item.form.AlphaBlendValue := transparency.tray;
       item.form.AlphaBlendValue := MainPrefs.getPrefIntDef('transparency-vtray', 220);
//      item.form.show(bmp);
      item.form.showTip;
      end;
end;

procedure TipRemove(ev: Thevent);
var
  i: Integer;
  rt: TRnQTip;
begin
  If Assigned(tipsList) then
  begin
    for I := 0 to tipsList.Count - 1 do
    begin
     rt := TRnQTip(tipsList.Items[i]);
     if Assigned(rt) and Assigned(rt.form) then
        if (rt.form.info.mode = TM_EVENT)and
           (rt.form.info.obj = ev)
        then
         begin
           tipsList.Items[i] := nil;
           rt.form.Close;
           rt.form := NIL;
           rt.Free;
         end;
    end;
//    Check4NIL;
//    if tipsList.Count = 0 then
//      FreeAndNil(tipsList);
    MoveTips;
  end;
end;

procedure TipRemove(cnt: TRnQcontact);
var
  i: Integer;
  rt: TRnQTip;
begin
  if not Assigned(cnt) then
    Exit;
  If Assigned(tipsList) then
  begin
    for I := 0 to tipsList.Count - 1 do
    begin
     rt := TRnQTip(tipsList.Items[i]);
     if Assigned(rt) and Assigned(rt.form) and
        (((rt.form.info.mode = TM_EVENT)and Assigned(rt.form.info.obj) and
         Assigned(Thevent(rt.form.info.obj).who) and
         Thevent(rt.form.info.obj).who.equals(cnt))
         or
         ((rt.form.info.mode = TM_BDay)and Assigned(rt.form.info.obj) and
          TRnQContact(rt.form.info.obj).equals(cnt))
        ) then
          try
           tipsList.Items[i] := nil;
           rt.form.Close;
           rt.form := NIL;
           rt.Free;
          except
          end;
    end;
//    Check4NIL;
//    if tipsList.Count = 0 then
//      FreeAndNil(tipsList);
  end;
  MoveTips;
end;

procedure TipsUpdateByCnt(c: TRnQcontact);
var
  i: Integer;
  rt: TRnQTip;
begin
  If Assigned(tipsList) then
  for I := 0 to tipsList.Count - 1 do
  begin
   rt := TRnQTip(tipsList.Items[i]);
   if Assigned(rt) and Assigned(rt.form) and
      (rt.form.info.mode =TM_EVENT) and
      Assigned(rt.form.info.obj) and
      Thevent(rt.form.info.obj).who.equals(c) then
       begin
         rt.form.Repaint;
       end;
  end;
end;


procedure TipsProced;
var
  I: Integer;
  tipFrm: TtipFrm;
  cur_ev: Thevent;
  rt: TRnQTip;
  vCnt: TRnQContact;
begin
  If Assigned(tipsList) then
  if tipsList.Count > 0 then
   for I := tipsList.Count - 1 downto 0 do
    if not Assigned(tipsList.Items[i]) then
     tipsList.Delete(i);

 if Assigned(tipsList) then
 for I := 0 to tipsList.Count - 1 do
 begin
  rt := TRnQTip(tipsList.Items[i]);
  if Assigned(rt) then
  begin
   tipFrm := rt.form;
   if assigned(tipFrm) then
   with tipFrm do
   if not mousedown then
    if actionCount=0 then
      begin
      // shutdown tip-window
        if rt.counter >= 0 then
        dec(rt.counter);
        if rt.counter <= 0 then
         begin
//          hide();
          tipsList.Items[i] := nil;
          tipFrm.Close;
          rt.form := nil;
//          TRnQTip(tipsList.Items[i]).frm.Free;
          rt.Free;
          MoveTips;
         end;
      end
    else
      begin
      // manages tip-window clicks
      dec(actionCount);
      if actionCount = 0 then
        begin
          if (info.mode = TM_EVENT) and (info.obj <> NIL) then
            cur_ev := Thevent(info.obj).clone
           else
            cur_ev := NIL;
          Close;
          tipsList.Items[i] := nil;
          rt.form := nil;
//          TRnQTip(tipsList.Items[i]).frm.Free;
          rt.Free;
          MoveTips;
          if assigned(cur_ev) then
          case action of
            TA_2lclick:
              begin
                if Assigned(cur_ev.otherpeer) then
                  vCnt := cur_ev.otherpeer
                 else
                  vCnt := cur_ev.who;
                 chatFrm.openOn(vCnt);
                 if not chatFrm.moveToTimeOrEnd(vCnt, cur_ev.when) then
                  chatFrm.addEvent(vCnt, cur_ev.clone);
              end;
            TA_rclick: eventQ.removeEvent(cur_ev.who);
          end;
          action := TA_null;
          cur_ev.Free;
        end;
      end;
  end;
 end;

 if ShowBalloonTime > 0 then
  begin
    Dec(ShowBalloonTime, RnQmain.timer.Interval);
    if ShowBalloonTime <= 0 then
      statusIcon.hideBalloon;
  end;
end;


procedure tipDrawEvent(destDC: HDC; ev: Thevent; pCnt: TRnQContact;
             var maxX, maxY: integer; calcOnly: Boolean; PPI: NativeInt);
var
  x,y,h: integer;
  fullR, Rcap,
  R,
  work: Trect;
//  pc: pchar;
  vSize: Tsize;
  font : TFont;

//  gr: TGPGraphics;
//  fnt: TGPFont;
//  gfmt: TGPStringFormat;
//  br: TGPBrush;
//  pen: TGPPen;
//  gpR, resR: TGPRectF;
//  pth: TGPGraphicsPath;
  res: TSize;
//  cname,
  info,
  sA: RawByteString;
  s: String;
  days2BD: SmallInt;

  dc: HDC;
  ABitmap, HOldBmp: HBITMAP;

  oldFont: HFONT;
  brLog: LOGBRUSH;
  oldBr, hb: HBRUSH;
  oldPen, Hp: HPEN;
  oldMode: Integer;
  ta: UINT;
  ClrBg: TColor;
  Clr2: Cardinal;

  rad: Integer;

  i, k: Integer;
//  l, m: Integer;
//  proc: Byte;
  RnQPicStream: TMemoryStream;
  vRnQpicEx: TRnQBitmap;
    b: Byte;
    st: byte;
  drawAvt: Boolean;
  thisCnt: TRnQContact;
  stsArr: TStatusArray;
//  xStsArr: TXStatStrArr;

  p: TPicName;
//  picN: TPicName;
  r2: TGPRect;
  ms: Integer;
  recalcPPI: Boolean;
  GAP: Integer;
begin
//inherited;
  if calcOnly then
   begin
     maxX := 0;
     maxY := 0;
   end;

  if (pCnt= NIL) and ((ev = nil) or (ev.who =NIL)) then
    exit;

  if (PPI > 30) and (PPI <> cDefaultDPI) then
    begin
      recalcPPI := True;
    end
   else
    begin
      recalcPPI := false;
      PPI := cDefaultDPI;
    end;

  fullR.Left := 0;
  fullR.Top := 0;
  fullR.Right := maxX;
  fullR.Bottom := maxY;

  if calcOnly then
   begin
    fullR.Right := MIN(MAXSHORT, maxX);
    fullR.Bottom := MIN(MAXSHORT, maxY);
   end;


  HOldBmp := 0;
//  if not calcOnly then
  try
    DC := CreateCompatibleDC(destDC);
    with fullR do
    begin
      ABitmap := CreateCompatibleBitmap(destDC, Right-Left, Bottom-Top);
      if (ABitmap = 0) and (Right-Left + Bottom-Top <> 0) then
        raise EOutOfResources.Create('Out of Resources');
      HOldBmp := SelectObject(DC, ABitmap);
      SetWindowOrgEx(DC, Left, Top, Nil);
    end;
  finally
  end;
//  else
//   DC := 0;

 try
  thisCnt := NIL;

   if Assigned(ev) and Assigned(ev.otherpeer) then
     thisCnt := ev.otherpeer
   else
   if Assigned(ev) and Assigned(ev.who) then
     thisCnt := ev.who
    else
     if Assigned(pCnt) then
       thisCnt := pCnt
      else
       s := '';
  if Assigned(thisCnt) then
    s := thisCnt.displayed;

    if Assigned(ev) and Assigned(ev.otherpeer) and
       Assigned(ev.who) and (ev.who <> ev.otherpeer) then
     s := s + ' (' +ev.who.displayed + ')';


//cname := contact.displayed;
  work := desktopWorkArea(Application.MainFormHandle);

  if recalcPPI then
    begin
      GAP := MulDiv(2, PPI, cDefaultDPI);
      x := MulDiv(4, PPI, cDefaultDPI);
    end
   else
    begin
      GAP := 2;
      x := 4;
    end;
  y := GAP;
//  R.left:=x;
  if calcOnly then
   begin
    maxX := x;
    maxY := y;
   end;
//  gpR.Y := y;
//  gpR.X := x;
{   begin
     h := FontStyleRegular;
    if fsBold in font.Style then
     h := h or FontStyleBold;
    if fsItalic in font.Style then
     h := h or FontStyleItalic;
    fnt := TGPFont.Create(font.Name, font.Size, h, UnitPoint);
   end;
  gfmt := TGPStringFormat.Create(//StringFormatFlagsNoWrap or
             StringFormatFlagsMeasureTrailingSpaces);
  gfmt.SetLineAlignment(StringAlignmentNear);
  gfmt.SetHotkeyPrefix(HotkeyPrefixNone);}

//  gr.MeasureString(s, length(s), fnt, MakePoint(gpR.X, gpR.Y), gfmt, resR);
//  gr.MeasureString(cname, Length(cname), fnt, gpR, resR);

  days2BD := -1;
  if Assigned(ev) then
    p := event2imgName(ev.kind)
   else
    if Assigned(pCnt) then
      begin
       days2BD := pCnt.Days2Bd;
       case days2BD of
         0: p := PIC_BIRTH;
         1: p := PIC_BIRTH1;
         2: p := PIC_BIRTH2;
        else
          p := PIC_BIRTH + 'n';
       end;
      end
     else
       p:= '';
  if not calcOnly then   // Paint Background
    begin
//     gr := TGPGraphics.Create(DC);
{     gr := TGPGraphics.Create(dc);
     //cnv.Brush.Style:=bsSolid;
     //cnv.brush.color:=theme.GetColor('tip.bg');//tip.bgcolor;
     //cnv.fillRect(cnv.ClipRect);
     br := TGPSolidBrush.Create(theme.GetAColor('tip.bg', clInfoBk));
     gr.FillRectangle(br, MakeRect(fullR));
     br.Free;
     FreeAndNil(gr);}
      ClrBg := theme.GetColor('tip.bg', clInfoBk);
      ClrBg := theme.GetColor('tip.bg.' + p, ClrBg);

     hb := CreateSolidBrush(ColorToRGB(ClrBg));
//     oldBr := SelectObject(DC, hb);
     FillRect(DC, fullR, hB);
     DeleteObject(hB);
//      if Not calcOnly then
    // Caption BG
      Rcap.Left := 1;
      Rcap.Top  := 1;
      Rcap.Right := maxX-1;
      Rcap.Bottom := 20;
//      Clr2 := theme.GetAColor('tip.caption', ClrBg);
      Clr2 := theme.GetAColor('tip.caption.' + p, theme.GetColor('tip.caption', ClrBg));
   {$IFDEF USE_GDIPLUS}
       GPFillGradient(DC, Rcap, Clr2, AlphaMask or ABCD_ADCB(ColorToRGB(ClrBg)), gdVertical);
   {$ELSE NOT USE_GDIPLUS}
       FillGradient(DC, Rcap, Clr2, AlphaMask or Cardinal(ColorToRGB(ClrBg)), gdVertical);
   {$ENDIF USE_GDIPLUS}

    // Info BG
      Rcap.Left := 1;
      Rcap.Right := maxX-1;
      Rcap.Bottom := maxY-1;
      if recalcPPI then
        Rcap.Top  := MulDiv(21, PPI, cDefaultDPI)
       else
        Rcap.Top  := 21;
//      Clr2 := theme.GetAColor('tip.info', ClrBg);
      Clr2 := theme.GetAColor('tip.info.' + p, theme.GetColor('tip.info', ClrBg));
   {$IFDEF USE_GDIPLUS}
     GPFillGradient(DC, Rcap, Clr2, AlphaMask or ABCD_ADCB(ColorToRGB(ClrBg)), gdVertical);
   {$ELSE NOT USE_GDIPLUS}
       FillGradient(DC, Rcap, Clr2, AlphaMask or Cardinal(ColorToRGB(ClrBg)), gdVertical);
   {$ENDIF USE_GDIPLUS}
    end;
  if calcOnly then
    vSize := theme.GetPicSize(RQteDefault, p, 0, PPI)
   else
    vSize := theme.drawPic(DC, x,y, p, true, PPI)
;
  p := '';
  inc(x, vSize.cx + GAP);
//  gpR.X := x;
  r := fullR;
  r.Left := x;
  font := TFont.Create;
  font.Assign(Screen.HintFont);
  theme.ApplyFont('tip.contact', font);
   oldFont := SelectObject(DC, Font.Handle);
//   oldColor :=
   SetTextColor(DC, ColorToRGB(Font.Color));
//  DrawText(DC, PChar(s), -1, R, DT_CALCRECT or DT_SINGLELINE);// or DT_VCENTER);
  DrawText(DC, PChar(s), length(s), R, DT_CALCRECT or DT_SINGLELINE);// or DT_VCENTER);
  GetTextExtentPoint32(DC, pchar(s), length(s), res);

//  inc(x, cnv.textWidth(cname)+3);
  inc(x, res.cx + 3);
//  h:=cnv.textHeight('J')*4 div 3;
//if size.cy > h then
//  h:=size.cy;
//  gpR.Y := h - Round(resR.Height);
  h := max(vSize.cy, res.cy);
  r.Top := h - res.cy;

  if not calcOnly then
    begin
      r.BottomRight := fullR.BottomRight;
//  cnv.textOut(x,y+2,cname);
//      br := TGPSolidBrush.Create(gpColorFromAlphaColor($FF, theme.GetFont('tip.contact').Color));
//      gr.DrawString(s, length(s), fnt, gpR, gfmt, br);
//      br.Free;


//       oldFont := SelectObject(DC, Font.Handle);
//       oldColor :=
//       SetTextColor(DC, ColorToRGB(Font.Color));
         oldMode:= SetBKMode(DC, TRANSPARENT);
//        DrawText(DC, PChar(s), -1, R, DT_SINGLELINE  or DT_NOPREFIX); //or DT_VCENTER
        DrawText(DC, PChar(s), Length(s), R, DT_SINGLELINE  or DT_NOPREFIX); //or DT_VCENTER
//         SetBKMode(DC, oldMode);
//      GetTextExtentPoint32(DC,pchar(s),length(s), res);
    end;
//  fnt.Free;
   SelectObject(DC, oldFont);
//  font.Free;
//  font := theme.GetFont('tip');
//  font := Screen.HintFont;
  font.Assign(Screen.HintFont);
  theme.ApplyFont('tip', font);
  drawAvt := false;
{   begin
     h := FontStyleRegular;
    if fsBold in font.Style then
     h := h or FontStyleBold;
    if fsItalic in font.Style then
     h := h or FontStyleItalic;
    fnt := TGPFont.Create(font.Name, font.Size, h, UnitPoint);
   end;}

  if Assigned(ev) then
    s := getTranslation(tipevent2str[ev.kind])
   else
    if Assigned(pCnt) then
      begin
       if days2BD in [0..2] then
         s := getTranslation(tipBirth2str[days2BD])
        else
         s:= intToStr(days2BD) + ' days to birthday';
       drawAvt := True;
      end
     else
       s:= '';
  R := fullR;
  R.Left := x;
//  R.Top  := y+2;
  r.Top := h - res.cy;
//  gpR.X := x;
//  gpR.Y := y+2;
  oldFont := SelectObject(DC, Font.Handle);
//   oldColor :=
    SetTextColor(DC, ColorToRGB(Font.Color));
//         CreateFontIndirect()
//  gr.MeasureString(s, length(s), fnt, MakePoint(gpR.X, gpR.Y), gfmt, resR);
//    DrawText(DC, PChar(s), -1, R, DT_CALCRECT or DT_SINGLELINE or DT_NOPREFIX); // or DT_VCENTER
    DrawText(DC, PChar(s), Length(s), R, DT_CALCRECT or DT_SINGLELINE or DT_NOPREFIX); // or DT_VCENTER
    GetTextExtentPoint32(DC,pchar(s),length(s), res);
  if not calcOnly then
    begin
//  cnv.textOut(x,y+2,cname);
//      br := TGPSolidBrush.Create(gpColorFromAlphaColor($FF, theme.GetFont('tip').Color));
//      gr.DrawString(s, length(s), fnt, gpR, gfmt, br);
//      br.Free;
         oldMode:= SetBKMode(DC, TRANSPARENT);
//        DrawText(DC, PChar(s), -1, R, DT_SINGLELINE or DT_NOPREFIX); //or DT_VCENTER
        DrawText(DC, PChar(s), Length(s), R, DT_SINGLELINE or DT_NOPREFIX); //or DT_VCENTER
//         SetBKMode(DC, oldMode);
    end;

//cnv.textOut(x, y+2, s);
//inc(x, cnv.textWidth(s)+2);
//  inc(x, round(resR.Width)+2);
  inc(x, res.cx + GAP);

  if Assigned(ev) then
   if ev.kind in [EK_ONCOMING, EK_STATUSCHANGE] then
         begin
//           sa := ev.bInfo;
           sa := ev.getBodyBin;
           if length(sa) >= 4 then
             begin
              st := (str2int(sa));

              if Assigned(thisCnt) then
              begin
                 stsArr := thisCnt.fProto.statuses;
                 if {(st >= Low(stsArr)) and} (st <=High(stsArr)) then
              begin
                b := infoToXStatus(sa);
                p := status2imgName(st, (length(sa)>4) and boolean(sa[5]));
  //              if (not XStatusAsMain) and (st <> SC_ONLINE)and (b>0) then
                if (st <> byte(SC_ONLINE))or(not XStatusAsMain)or (b=0)  then
                 begin
                 if calcOnly then
                     inc(X, theme.GetPicSize(RQteDefault, p, PPI).cx)
                  else
                      inc(X, theme.drawPic(DC, X+2, Y, p, true, PPI).cx);
                  ;
                  inc(X, 2);
                 end;
  //              with statusDrawExt(cnv.Handle, curX+2, curY, Tstatus(str2int(s)), (length(s)>4) and boolean(s[5])) do
 {$IFDEF PROTOCOL_ICQ}
                if (b > 0) then
                begin
                 if {(b >= Low(xStsArr)) and} (b <= High(XStatusArray)) then
                 begin
                   p := XStatusArray[b].PicName;
                   if calcOnly then
                     inc(X, theme.GetPicSize(RQteDefault, p, PPI).cx+1)
                    else
                     theme.drawPic(DC, X+1, Y, p, True, PPI);
                 end;
               end;
 {$ENDIF PROTOCOL_ICQ}
              end;
             end;
         end;
         end;
  inc(x, GAP * 2);
//inc(y, h);
//  inc(y, max(round(resR.Height), vSize.cy) + 2);
  inc(y, max(res.cy, vSize.cy) + GAP);
  if calcOnly then
   begin
    maxX := x;
    maxY := y;
   end;

  if Assigned(ev) then
  begin
    drawAvt := False;
  //  if ev.kind in [EK_url,EK_msg,EK_contacts,EK_authReq,EK_automsg, EK_statuschange, EK_ONCOMING] then
    if ev.kind = EK_msg then
      begin
  //    info := ev.decrittedInfoOrg
  //    info := ev.bInfo
        info := ev.getBodyBin
      end
     else
      info := '';
    i := Pos(RnQImageExTag, info);
    k := PosEx(RnQImageExUnTag, info, i+12);
    if (i > 0) and (k > 5) then
    begin
     p := Copy(info, i+12, k-i-12);
     sa := '';
     try
       sa := Base64DecodeString(p);
     except
       sa := '';
     end;
     p := '';
     if sa > '' then
     begin
        RnQPicStream := TMemoryStream.Create;
        RnQPicStream.SetSize(Length(sa));
        RnQPicStream.Position := 0;
        RnQPicStream.Write(sa[1], Length(sa));
        vRnQpicEx := nil;
        if loadPic(TStream(RnQPicStream), vRnQpicEx, 0, PA_FORMAT_UNK, 'Tray.RnQImageEx') then
         begin
//          resR.Width := vRnQpicEx.GetWidth;
//          resR.Height := vRnQpicEx.GetHeight;
          res.cx := vRnQpicEx.GetWidth;
          res.cy := vRnQpicEx.GetHeight;
          { TODO -oRapid D -cHiDPI : Add HiDPI }
          if calcOnly then
            begin
             maxY := Y + res.cy + 7;
             maxX := max(maxX, res.cx) + 7;
            end
           else
             DrawRbmp(DC, vRnQpicEx, 4, y);
          vRnQpicEx.Free;
         end
        else
         try
          RnQPicStream.Free;
         except
         end;
     end;
    end
    else

//  if ev.kind in [EK_url,EK_msg,EK_contacts,EK_authReq,EK_automsg, EK_file] then
   if ev.isHasBody then
    begin
//      gpR.Y := y;
//      gpR.X := 4;
      r.Left := 4;
      r.Top  := y;
      r.Bottom := 10000;
      if calcOnly then
        begin
          i := R.Left + (work.right-work.left) div 3;
//        gpR.Width :=(work.right-work.left) div 3
         r.Right := i;
        end
       else
//        gpR.Width :=maxX;
         r.Right := maxX;
//      R.top:=y;
//      R.right:=(work.right-work.left) div 3;
//      R.bottom:=y;
      s := ev.getBodyText;  // By Rapid D!
//      pc:=@info[1];
//      drawText(cnv.handle, pc, -1, R, DT_WORDBREAK+DT_EXTERNALLEADING+DT_NOPREFIX+DT_CALCRECT );
//      drawText(cnv.handle, pc, -1, R, DT_WORDBREAK+DT_EXTERNALLEADING+DT_NOPREFIX );
//       gr.MeasureString(s, length(s), fnt, gpR, gfmt, resR);
//       oldFont := SelectObject(DC, Font.Handle);
//       oldColor :=
      if s > '' then
      begin
        ta := GetTextAlign(DC);
        SetTextAlign(DC, ta or TA_LEFT or TA_TOP or TA_NOUPDATECP); // Need to DrawText and DrawTextEx
        if not calcOnly then
        begin
         SetTextColor(DC, ColorToRGB(Font.Color));
     //  cnv.textOut(x,y+2,cname);
         {
          gr := TGPGraphics.Create(DC);
           br := TGPSolidBrush.Create(gpColorFromAlphaColor($FF, theme.GetFont('tip').Color));
           gr.DrawString(s, length(s), fnt, gpR, gfmt, br);
           br.Free;
          FreeAndNil(GR);}
            oldMode:= SetBKMode(DC, TRANSPARENT);
            DrawText(DC, PChar(s), Length(s), R, DT_WORDBREAK or DT_EXTERNALLEADING or DT_NOPREFIX);
//            DrawTextEx(DC, @s[1], Length(s), R, DT_WORDBREAK or DT_EXTERNALLEADING or DT_NOPREFIX, NIL); // or DT_VCENTER  or DT_SINGLELINE
//          SetBKMode(DC, oldMode);
        end
       else
        begin
//         r.Bottom := 0;
         DrawText(DC, PChar(s), Length(s), R, DT_CALCRECT or DT_WORDBREAK or DT_EXTERNALLEADING or DT_NOPREFIX); // or DT_VCENTER  or DT_SINGLELINE
//         s := s + ' '#13#10;
//         DrawTextEx(DC, @s[1], Length(s), R, DT_CALCRECT or DT_WORDBREAK or DT_EXTERNALLEADING or DT_NOPREFIX, NIL); // or DT_VCENTER  or DT_SINGLELINE
{         l := Length(s);
         m := 1; R.Right := 0; R.Bottom := 0;
         while l > 0 do
          begin
           GetTextExtentExPoint(DC, @s[m], l, i, @k, NIL, vSize);
           GetTextExtentPoint32(DC, @s[m], k, vSize);
           Dec(l, k);
           Inc(m, k);
           if R.Right < vSize.cx then
             r.Right := vSize.cx;
           Inc(r.Bottom, vSize.cy);
          end;
//          r.Right := vSize.cx;
//          r.Bottom := vSize.cy;
}
         if R.Right > i then
           r.Right := i;
//         GetTextExtentPoint32(DC,pchar(s),length(s), res);
//         maxY := Round(gpR.Y + resR.Height) + 3;
//         maxX := max(maxX, round(resR.Width)) + 3;
//         maxY := R.Top + res.cy + 5;
//         maxX := max(maxX, res.cx) + 5;
         maxY := max(maxY, R.Bottom) + GAP*3;
         maxX := max(maxX, r.Right) + GAP*3;
        end;
      end;

//       SelectObject(DC, oldFont);
//      inc(R.bottom,7);
//      inc(R.right,7);
//      maxY:=R.bottom;
//      if R.right > maxX then
//        maxX:=R.right;
    end
   ELSE
    if ev.kind in [EK_oncoming, EK_offgoing] then
      drawAvt := True;
  end;


 {$IFDEF RNQ_AVATARS}
    if drawAvt and avatarShowInTray and Assigned(thisCnt) then
     with thisCnt do
     if Assigned(icon.Bmp) then
      begin
        R2.x := 8;
        R2.y  := y;
        if mainprefs.getPrefBoolDef('show-tips-use-avt-size', True) then
          begin
           ms := mainPrefs.getPrefIntDef('show-tips-avt-size', 100); //TipsMaxAvtSize
           if (PPI > 30)and (PPI <> cDefaultDPI) then
             ms := MulDiv(ms, PPI, cDefaultDPI);
           R2.size := MakeSize(icon.Bmp.getSize(PPI));
           with BoundsSize(R2.Width, R2.Height, ms, ms) do
            begin
             R2.Width := cx;
             R2.Height := cy;
            end;
          end
         else
          begin
           R2.size := MakeSize(icon.Bmp.getSize(PPI));
          end;
        if not calcOnly then
          DrawRbmp(DC, icon.Bmp, R2);
    //    cnv.Draw(5, y+3,  contact.icon);
        inc(y, GAP*5 + R2.Height);
        if calcOnly then
         begin
          maxY := Y;
          if (r2.X+ R2.Width + GAP*4) > maxX then
            maxX := r2.X + R2.Width + GAP*4;
         end;
      end;
   {$ENDIF RNQ_AVATARS}

  SelectObject(DC, oldFont);
  font.Free;
//  fnt.Free;
//  gfmt.Free;

//cnv.Brush.Style := bsClear;
//cnv.r
//cnv.RoundRect(0, 0, maxX, maxY, round_R+1, round_R+1);
//cnv.frameRect(rect(0,0,maxX,maxY));
      begin
       if not TryStrToInt(theme.GetString('tip.radius'), rad) then
         rad := 0;
       if rad > 0 then
        begin
{         gr := TGPGraphics.Create(DC);
         pth := TGPGraphicsPath.Create(FillModeAlternate);
    //     pth.AddRectangle(MakeRect(fullR));
         pth.StartFigure;
         pth.AddArc(0, 0, rad+1, rad+1, 180, 90);
         pth.AddArc(maxX - rad-2, 0, rad+1, rad+1, -90, 90);
         pth.AddArc(maxX - rad-2, maxY-rad-2, rad+1, rad+1, 0, 90);
         pth.AddArc(0, maxY-rad-2, rad+1, rad+1, 90, 90);
         pth.CloseFigure;
         pen := TGPPen.Create(aclBlack);
         gr.DrawPath(pen, pth);
         pen.Free;
         pth.Free;
         gr.Free;}
         brLog.lbStyle := BS_HOLLOW;
//         brLog.lbColor := ColorToRGB(theme.GetColor('tip.bg', clInfoBk));
         brLog.lbColor := 0;
         hb := CreateBrushIndirect(brLog);
          oldBr  := SelectObject(DC, hb);
         Hp := CreatePen(PS_SOLID, 1, clBlack);
          oldPen := SelectObject(DC, hp);
         RoundRect(DC, 0, 0, maxX, maxY, rad+1, rad+1);
         SelectObject(DC, oldBr);
          DeleteObject(hb);
         SelectObject(DC, oldPen);
          DeleteObject(hp);
        end
       else
        begin
    //     pen := TGPPen.Create(aclBlack);
    //     gr.DrawRectangle(pen, 0, 0, maxX-1, maxY-1);
    //     pen.Free;

    //     hB := //CreateSolidBrush(ColorToRGB(theme.GetColor('tip.bg', clInfoBk)));
//         brLog.lbStyle := BS_HOLLOW;
         brLog.lbStyle := BS_SOLID;
//         brLog.lbColor := ColorToRGB(theme.GetColor('tip.bg', clInfoBk));
         brLog.lbColor := 0;
         hb := CreateBrushIndirect(brLog);
//         Hp := CreatePen(PS_SOLID, 1, clBlack);
//         oldPen := SelectObject(DC, hp);
         oldBr  := SelectObject(DC, hb);
//         FillRect(DC, fullR, hb);
         FrameRect(DC, fullR, hb);
//         FrameRect(DC, )
//         Rectangle(DC, 0, 0, maxX, maxY);
         SelectObject(DC, oldBr);
         DeleteObject(hb);
//         SelectObject(DC, oldPen);
//         DeleteObject(hB);
        end;

      end;

 finally
  if not calcOnly then
    BitBlt(destDC, fullR.Left, fullR.Top,
     fullR.Right - fullR.Left, fullR.Bottom - fullR.Top,
     dc, fullR.Left, fullR.Top, SrcCopy);

  SelectObject(DC, HOldBmp);
  DeleteObject(ABitmap);
  DeleteDC(DC);
 end;
end; // tipDrawEvent


end.
