{
This file is part of R&Q.
Under same license
}
unit RnQTips;
{$I Compilers.inc}
{$I RnQConfig.inc}

interface

uses
  Windows, Graphics, Types, Classes, SysUtils, Forms,
  events, RnQProtocol,
  {$IFNDEF NOT_USE_GDIPLUS}
//   GDIPAPI, GDIPOBJ,
  {$ENDIF NOT_USE_GDIPLUS}
  tipDlg;

type
  TRnQTip = class(TObject)
   public
    frm         : TtipFrm;
//    ev          : Thevent;
    time        : TDateTime;
    counter     : Integer;
    showSeconds : Word;
    x, y        : Word;
  end;

  procedure MoveTips;
//  procedure TipAdd2(ev:Thevent; bmp2 : tbitmap; seconds : Integer = -1);
  procedure TipAdd3(ev:Thevent; bmp2 : tbitmap = NIL; pCnt : TRnQContact = NIL; seconds : Integer = -1);
//  procedure TipAdd(bmp : Tbitmap; seconds : Integer = -1); overload;
//  procedure TipAdd(ev:Thevent; seconds : Integer = -1); overload;
//  procedure TipAdd(gpBmp : tGPbitmap; seconds : Integer = -1); overload;
  procedure TipRemove(ev:Thevent); overload;
  procedure TipRemove(cnt : TRnQcontact); overload;
  procedure TipsUpdateByCnt(c : TRnQcontact);
  procedure TipsHideAll;
  procedure TipsShowTop;
  procedure TipsProced;
  procedure tipDrawEvent(destDC: HDC; ev : Thevent; pCnt : TRnQContact;
              var maxX,maxY:integer; calcOnly : Boolean);

type
  TtipsAlign  = (alBottomRight, alBottomLeft, alTopLeft, alTopRight, alCenter);
  TtipsAlignSet  = set of TtipsAlign;
var
  TipsMaxCnt   : Integer;
  TipsBtwSpace : Integer;
  TipsAlign    : TtipsAlign;
  TipHorIndent : Integer;
  TipVerIndent : Integer;

implementation

 uses
   math, StrUtils, Base64,
   RDGlobal, RQUtil, RnQGraphics32, RnQSysUtils, RnQBinUtils,
   globalLib, utilLib, RDtrayLib, RnQPics, RQThemes, RnQLangs,
 {$IFDEF UNICODE}
   AnsiStrings,
//   Character,
 {$ENDIF}
   protocol_ICQ, ICQConsts,
   chatDlg, mainDlg;


var
  tipsList: TList = NIL;
  TipsMaxTop : Integer = 200;


procedure TipAdd3(ev:Thevent; bmp2 : tbitmap = NIL; pCnt : TRnQContact = NIL; seconds : Integer = -1);
var
//  isEv : Boolean;
//  isPic : Boolean;
  tipType : byte; {1 - ev, 2 - pic, 3 - birthday}

  item : TRnQTip;
  cnt, idx: Integer;
  minX, minY, needW, needH : Integer;
  work:Trect;
  not_ok : Boolean;
  rt : TRnQTip;

  sR : RawByteString;
  s3m : TMemoryStream;
  sl : Integer;
  i, k : Integer;
  pic : TBitmap;

begin
  if ( TipsMaxCnt = 0 ) then exit;

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
           ( TipsMaxCnt = 0 ) or
           ( (ev.kind in [EK_msg,EK_url]) // user reading this message in chat window
             and chatFrm.isVisible
             and (ev.who.equals(chatFrm.thisChat.who))
           )
        then exit;

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

        work  := desktopWorkArea;
        item      := TRnQTip.Create;
        item.frm  := Ttipfrm.create(NIL);
        item.frm.alphablend:=transparency.forTray;
        if transparency.forTray then
          item.frm.AlphaBlendValue := transparency.tray;
        needW := 0; needH := 0;
        tipDrawEvent(item.frm.Canvas.Handle, ev, NIL, needW, needH, True);
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
        work  := desktopWorkArea;
        needH := bmp2.Height;
        needW := bmp2.Width;

        item      := TRnQTip.Create;
        item.frm  := Ttipfrm.create(NIL);
        item.frm.alphablend:=transparency.forTray;
        if transparency.forTray then
          item.frm.AlphaBlendValue := transparency.tray;
        item.time := now;
        item.showSeconds := seconds;
        item.counter := seconds;
    end;
   3: begin // Show birthday
//        Exit;

        work  := desktopWorkArea;
        item      := TRnQTip.Create;
        item.frm  := Ttipfrm.create(NIL);
        item.frm.alphablend:=transparency.forTray;
        if transparency.forTray then
          item.frm.AlphaBlendValue := transparency.tray;
        needW := 0; needH := 0;
        tipDrawEvent(item.frm.Canvas.Handle, NIL, pCnt, needW, needH, True);
        needH := min(work.Bottom - work.Top - TipsMaxTop, needH);
      //  needW := min()
        item.time := now;
        item.showSeconds := MAXWORD;
        item.counter := MAXWORD;
    end
   else
     Exit;
  end;

  if not Assigned(tipsList) then
    tipsList := TList.Create;
  cnt  := 0;
//  lastY := work.Bottom;
  not_ok := True;
  idx := 0;
  case TipsAlign of
    alBottomRight,
    alBottomLeft:
      while not_ok do
      begin
       minY := work.Bottom;
       minX := MaxInt;
       cnt := 0;
       idx := 0;
        for I := 0 to tipsList.Count - 1 do
        begin
         rt := TRnQTip(tipsList.Items[i]);
         if (rt <> NIL) and Assigned(rt.frm) then
          begin
            inc(cnt);
            if rt.counter < minX then
             begin
              minX := rt.counter;
              idx  := i;
             end;
            if (rt.y < minY) then
               begin
  //              lastY := minY;
                minY := rt.y;
               end;
          end;
        end;
        if (tipsList.count >0)and
           ((cnt >= TipsMaxCnt) or (minY - work.Top - TipsMaxTop < needH))
           and (idx < tipsList.Count) then
         begin
           rt := TRnQTip(tipsList.Items[idx]);
           tipsList.Items[idx] := nil;
           if Assigned(rt) then
            begin
//             rt.frm.Close;
      //       rt.frm.hide();
             rt.frm.Free;
             rt.frm := NIL;
             rt.Free;
            end;
           idx := -1;
           dec(cnt);
  //         minY := lastY;
         end;

        MoveTips;

        for I := 0 to tipsList.Count - 1 do
        begin
         rt := TRnQTip(tipsList.Items[i]);
         if Assigned(rt) and Assigned(rt.frm) then
           if (rt.x >= 0)and (rt.y >= 0) then
             minY := min(rt.Y, minY);
        end;
        not_ok := (cnt > 0) and (minY - work.Top - TipsMaxTop < needH)
      end;
    alTopRight,
    alTopLeft:
      while not_ok do
      begin
       minY := TipVerIndent;
       minX := MaxInt;
       cnt := 0;
       idx := 0;
        for I := 0 to tipsList.Count - 1 do
        begin
         rt := TRnQTip(tipsList.Items[i]);
         if (rt <> NIL) and Assigned(rt.frm) then
          begin
            inc(cnt);
            if rt.counter < minX then
             begin
              minX := rt.counter;
              idx  := i;
             end;
            if (rt.y + rt.frm.Height > minY) then
             begin
  //              lastY := minY;
              minY := rt.y + rt.frm.Height;
             end;
          end;
        end;
        if (tipsList.count >0)and
            ((cnt >= TipsMaxCnt) or (work.Bottom - minY - TipsMaxTop < needH))
           and (idx < tipsList.Count) then
           begin
             rt := TRnQTip(tipsList.Items[idx]);
             tipsList.Items[idx] := nil;
             if Assigned(rt) then
               begin
                 rt.frm.Close;
                 rt.frm := NIL;
          //       rt.frm.hide();
          //       rt.frm.Free;
                 rt.Free;
               end;
             idx := -1;
             dec(cnt);
    //         minY := lastY;
           end;

        MoveTips;

        for I := 0 to tipsList.Count - 1 do
        begin
         rt := TRnQTip(tipsList.Items[i]);
         if Assigned(rt) and Assigned(rt.frm) then
           if (rt.x >= 0)and (rt.y >= 0) then
             minY := max(rt.Y + rt.frm.Height, minY);
        end;
        not_ok := (cnt > 0) and (work.Bottom - minY - TipsMaxTop < needH)
      end;
  end;
//  minX :=

  case TipsAlign of
    alBottomRight,
    alBottomLeft:
      begin
        minY := work.Bottom - TipVerIndent;
        for I := 0 to tipsList.Count - 1 do
        begin
         rt := TRnQTip(tipsList.Items[i]);
         if Assigned(rt) and Assigned(rt.frm) then
           if (rt.x >= 0)and (rt.y >= 0) then
             minY := min(rt.Y, minY);
        end;
       item.Y := minY - needH - TipsBtwSpace;
      end;
    alTopRight,
    alTopLeft:
      begin
        minY := TipVerIndent;
        for I := 0 to tipsList.Count - 1 do
        begin
         rt := TRnQTip(tipsList.Items[i]);
         if Assigned(rt) and Assigned(rt.frm) then
           if (rt.x >= 0)and (rt.y >= 0) then
             minY := max(rt.Y  + rt.frm.Height, minY);
        end;
       item.Y := minY + TipsBtwSpace;
      end;
  end;

  case TipsAlign of
    alBottomRight,
    alTopRight:
      begin
       item.x := work.Right - TipHorIndent - needW;
      end;
    alBottomLeft,
    alTopLeft:
      begin
       item.x := TipHorIndent;
      end;
  end;

  item.frm.Width := needW;
  item.frm.Height := needH;
  case tipType of
    1:
      item.frm.show(ev, item.x, item.Y);
    2:
      item.frm.show(bmp2, item.x, item.Y);
    3:
      item.frm.show(pCnt, item.x, item.Y);
  end;

  tipsList.Add(item);
//  tipfrm.show(bmp);
end;

procedure Check4NIL;
var
  i : Integer;
//  rt : TRnQTip;
  allClear : Boolean;
begin
  If Assigned(tipsList) then
  begin
    allClear := True;
    for I := 0 to tipsList.Count - 1 do
    begin
     if tipsList.Items[i] <> NIL then
      begin
       allClear := false;
       Break;
      end;
    end;
    if allClear then
      FreeAndNil(tipsList);
  end;

end;

procedure TipRemove(ev:Thevent);
var
  i : Integer;
  rt : TRnQTip;
begin
  If Assigned(tipsList) then
  begin
    for I := 0 to tipsList.Count - 1 do
    begin
     rt := TRnQTip(tipsList.Items[i]);
     if Assigned(rt) and Assigned(rt.frm) then
        if (rt.frm.info.mode = TM_EVENT)and
           (rt.frm.info.ev = ev)
        then
         begin
           tipsList.Items[i] := nil;
           rt.frm.Close;
           rt.frm := NIL;
           rt.Free;
         end;
    end;
//    Check4NIL;
//    if tipsList.Count = 0 then
//      FreeAndNil(tipsList);
    MoveTips;
  end;
end;

procedure TipRemove(cnt : TRnQcontact);
var
  i : Integer;
  rt : TRnQTip;
begin
  if not Assigned(cnt) then
    Exit;
  If Assigned(tipsList) then
  begin
    for I := 0 to tipsList.Count - 1 do
    begin
     rt := TRnQTip(tipsList.Items[i]);
     if Assigned(rt) and Assigned(rt.frm) and
        (((rt.frm.info.mode = TM_EVENT)and Assigned(rt.frm.info.ev) and
         Assigned(rt.frm.info.ev.who) and rt.frm.info.ev.who.equals(cnt))
         or
         ((rt.frm.info.mode = TM_BDay)and Assigned(rt.frm.info.cnt) and
         Assigned(rt.frm.info.cnt) and rt.frm.info.cnt.equals(cnt))
        ) then
          try
           tipsList.Items[i] := nil;
           rt.frm.Close;
           rt.frm := NIL;
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

procedure TipsHideAll;
var
  i : Integer;
  rt : TRnQTip;
begin
  If Assigned(tipsList) then
  begin
    for I := 0 to tipsList.Count - 1 do
    begin
     rt := TRnQTip(tipsList.Items[i]);
     tipsList.Items[i] := nil;
     if Assigned(rt) and Assigned(rt.frm) then
         begin
           rt.frm.Close;
           rt.frm := NIL;
           rt.Free;
         end;
    end;
    FreeAndNil(tipsList);
//    if tipsList.Count = 0 then
//      FreeAndNil(tipsList);
  end;
end;

procedure TipsUpdateByCnt(c : TRnQcontact);
var
  i : Integer;
  rt : TRnQTip;
begin
  If Assigned(tipsList) then
  for I := 0 to tipsList.Count - 1 do
  begin
   rt := TRnQTip(tipsList.Items[i]);
   if Assigned(rt) and Assigned(rt.frm) and
      (rt.frm.info.mode =TM_EVENT) and
      Assigned(rt.frm.info.ev) and
      rt.frm.info.ev.who.equals(c) then
       begin
         rt.frm.Repaint;
       end;
  end;
end;

procedure TipsShowTop;
var
  i : Integer;
  rt : TRnQTip;
begin
  If Assigned(tipsList) then
  for I := 0 to tipsList.Count - 1 do
  begin
   rt := TRnQTip(tipsList.Items[i]);
   if Assigned(rt) and Assigned(rt.frm) and
      //formVisible(rt.frm) and
      not isTopMost(rt.frm) then
       begin
         setTopMost(rt.frm, TRUE);
       end;
  end;
// if formVisible(tipFrm) then setTopMost(tipFrm, TRUE);
//if formVisible(tipfrm) and not isTopMost(tipFrm) then
//  setTopMost(tipFrm, TRUE);
end;


procedure TipsProced;
var
  I: Integer;
  tipFrm : TtipFrm;
  cur_ev : Thevent;
  rt : TRnQTip;
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
   tipFrm := rt.frm;
   if assigned(tipFrm) then
   with tipFrm do if not mousedown then
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
          rt.frm := nil;
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
          if (info.mode = TM_EVENT) and (info.ev <> NIL) then
            cur_ev := info.ev.clone
           else
            cur_ev := NIL;
          Close;
          tipsList.Items[i] := nil;
          rt.frm := nil;
//          TRnQTip(tipsList.Items[i]).frm.Free;
          rt.Free;
          MoveTips;
          if assigned(cur_ev) then
          case action of
            TA_2lclick:
              begin
                 chatFrm.openOn(cur_ev.who);
                 if not chatFrm.moveToTimeOrEnd(cur_ev.who, cur_ev.when) then
                  chatFrm.addEvent(cur_ev.who, cur_ev.clone);
              end;
            TA_rclick: eventQ.removeEvent(cur_ev.who);
          end;
          action:=TA_null;
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

procedure MoveTips;
var
  i :  integer;
  minY : Integer;
  work:Trect;
  rt : TRnQTip;
begin
//OutputDebugString('Processing MoveTips');
 if Assigned(tipsList) then
 begin
  work:=desktopWorkArea;
  case TipsAlign of
    alBottomRight, alBottomLeft:
      begin
        minY := work.Bottom - TipVerIndent;
        for I := 0 to tipsList.Count - 1 do
        begin
         rt := TRnQTip(tipsList.Items[i]);
         if Assigned(rt) and Assigned(rt.frm) then
            begin
              if minY - rt.y  - rt.frm.Height > 10 then
              begin
                rt.y := minY - rt.frm.Height;
      //          AnimateWindow()
                rt.frm.Top := rt.y;
              end;
              minY := rt.y - TipsBtwSpace;
            end;
        end;
      end;
    alTopLeft, alTopRight:
      begin
        minY := TipVerIndent;
        for I := 0 to tipsList.Count - 1 do
        begin
         rt := TRnQTip(tipsList.Items[i]);
         if Assigned(rt) and Assigned(rt.frm) then
            begin
              if rt.y  - minY > 10 then
              begin
                rt.y := minY;
      //          AnimateWindow()
                rt.frm.Top := rt.y;
              end;
              minY := rt.y + rt.frm.Height + TipsBtwSpace;
            end;
        end;
      end;
  end;
 end;
end;

procedure tipDrawEvent(destDC: HDC; ev : Thevent; pCnt : TRnQContact;
             var maxX,maxY:integer; calcOnly : Boolean);
var
  x,y,h:integer;
  fullR, Rcap,
  R,
  work:Trect;
//  pc:pchar;
  vSize:Tsize;
  font : TFont;

//  gr: TGPGraphics;
//  fnt : TGPFont;
//  gfmt :TGPStringFormat;
//  br  : TGPBrush;
//  pen : TGPPen;
//  gpR, resR :TGPRectF;
//  pth :TGPGraphicsPath;
  res : TSize;
//  cname,
  info,
  sA : RawByteString;
  s  : String;
  days2BD : SmallInt;

  dc  : HDC;
  ABitmap, HOldBmp : HBITMAP;

  oldFont    : HFONT;
  brLog      : LOGBRUSH;
  oldBr, hb  : HBRUSH;
  oldPen, Hp : HPEN;
  oldMode : Integer;
  ta  : UINT;
  ClrBg : TColor;
  Clr2 : Cardinal;

  rad     : Integer;

  i, k : Integer;
//  l, m : Integer;
//  proc : Byte;
  RnQPicStream : TMemoryStream;
  vRnQpicEx : TRnQBitmap;
  p : AnsiString;
    b : Byte;
    st : byte;
  drawAvt : Boolean;
  thisCnt : TRnQContact;
  r2 : TGPRect;
begin
//inherited;
  if calcOnly then
   begin
     maxX := 0;
     maxY := 0;
   end;

  if (pCnt= NIL) and ((ev = nil) or (ev.who =NIL)) then
    exit;

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
  if Assigned(ev) and Assigned(ev.who) then
    thisCnt := ev.who
   else
    if Assigned(pCnt) then
      thisCnt := pCnt
     else
      s := '';
  if Assigned(thisCnt) then
    s := thisCnt.displayed;
//cname:=contact.displayed;
  work := desktopWorkArea;

  x:=4;
//  R.left:=x;
  y:=2;
  if calcOnly then
   begin
    maxX:=x;
    maxY:=y;
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
   {$IFNDEF NOT_USE_GDIPLUS}
       GPFillGradient(DC, Rcap, Clr2, AlphaMask or ABCD_ADCB(ColorToRGB(ClrBg)), gdVertical);
   {$ELSE NOT_USE_GDIPLUS}
       FillGradient(DC, Rcap, Clr2, AlphaMask or ColorToRGB(ClrBg), gdVertical);
   {$ENDIF NOT_USE_GDIPLUS}

    // Info BG
      Rcap.Left := 1;
      Rcap.Top  := 21;
      Rcap.Right := maxX-1;
      Rcap.Bottom := maxY-1;
//      Clr2 := theme.GetAColor('tip.info', ClrBg);
      Clr2 := theme.GetAColor('tip.info.' + p, theme.GetColor('tip.info', ClrBg));
   {$IFNDEF NOT_USE_GDIPLUS}
     GPFillGradient(DC, Rcap, Clr2, AlphaMask or ABCD_ADCB(ColorToRGB(ClrBg)), gdVertical);
   {$ELSE NOT_USE_GDIPLUS}
       FillGradient(DC, Rcap, Clr2, AlphaMask or ColorToRGB(ClrBg), gdVertical);
   {$ENDIF NOT_USE_GDIPLUS}
    end;
  if calcOnly then
    vSize:=theme.GetPicSize(RQteDefault, p)
   else
    vSize:=theme.drawPic(DC, x,y, p)
;
  p := '';
  inc(x, vSize.cx+2);
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
  GetTextExtentPoint32(DC,pchar(s), length(s), res);

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
{   begin
     h := FontStyleRegular;
    if fsBold in font.Style then
     h := h or FontStyleBold;
    if fsItalic in font.Style then
     h := h or FontStyleItalic;
    fnt := TGPFont.Create(font.Name, font.Size, h, UnitPoint);
   end;}

  if Assigned(ev) then
    s:=getTranslation(tipevent2str[ev.kind])
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

//cnv.textOut(x,y+2, s);
//inc(x, cnv.textWidth(s)+2);
//  inc(x, round(resR.Width)+2);
  inc(x, res.cx+2);

  if Assigned(ev) then
   if ev.kind in [EK_ONCOMING, EK_STATUSCHANGE] then
         begin
//           sa := ev.bInfo;
           sa := ev.getBodyBin;
           if length(sa) >= 4 then
             begin
              st := (str2int(sa));

              if (st >= Low(Account.AccProto.statuses)) and
                 (st <= High(Account.AccProto.statuses)) then
              begin
                b := infoToXStatus(sa);
  //              if (not XStatusAsMain) and (st <> SC_ONLINE)and (b>0) then
                if (st <> byte(SC_ONLINE))or(not XStatusAsMain)or (b=0)  then
                 if calcOnly then
                   inc(X, theme.GetPicSize(RQteDefault, status2imgNameExt(st, (length(sa)>4) and boolean(sa[5]))).cx+2)
                  else
                   inc(X, statusDrawExt(DC, X+2, Y, st, (length(sa)>4) and boolean(sa[5])).cx+2)
                  ;
  //              with statusDrawExt(cnv.Handle, curX+2, curY, Tstatus(str2int(s)), (length(s)>4) and boolean(s[5])) do
                if (b > 0) then
                 if calcOnly then
                   inc(X, theme.GetPicSize(RQteDefault, XStatusArray[b].PicName).cx+1)
                  else
                   theme.drawPic(DC, X+1, Y, XStatusArray[b].PicName);
              end;
             end;
         end;
  inc(x, 4);
//inc(y, h);
//  inc(y, max(round(resR.Height), vSize.cy) + 2);
  inc(y, max(res.cy, vSize.cy) + 2);
  if calcOnly then
   begin
    maxX:=x;
    maxY:=y;
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
     p:=Copy(info, i+12, k-i-12);
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
         maxY := max(maxY, R.Bottom) + 5;
         maxX := max(maxX, r.Right) + 5;
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
        if TipsMaxAvtSizeUse then
          begin
           with BoundsSize(icon.Bmp.GetWidth, icon.Bmp.GetHeight, TipsMaxAvtSize, TipsMaxAvtSize) do
            begin
             R2.Width := cx;
             R2.Height := cy;
            end;
          end
         else
          begin
           R2.Width  := icon.Bmp.GetWidth;
           R2.Height := icon.Bmp.GetHeight;
          end;
        if not calcOnly then
          DrawRbmp(DC, icon.Bmp, R2);
    //    cnv.Draw(5, y+3,  contact.icon);
        inc(y, 10 + R2.Height);
        if calcOnly then
         begin
          maxY := Y;
          if r2.X+ R2.Width + 8 > maxX then
            maxX := r2.X + R2.Width + 8;
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
