{
This file is part of R&Q.
Under same license
}
unit RQMenuItem;
{$I ForRnQConfig.inc}
{$I NoRTTI.inc}

{ $define MirandaSupport}
 { $DEFINE NOT_USE_GDIPLUS}

interface
uses
  Messages, Windows, Graphics, Classes, Types, Menus,
  RDGlobal,
  RQThemes;
  {
const
   CM_MENU_CLOSED = CM_BASE + 1001;
   CM_ENTER_MENU_LOOP = CM_BASE + 1002;
   CM_EXIT_MENU_LOOP = CM_BASE + 1003;
   }

type
   TPopupListEx = class(TPopupList)
   protected
     procedure WndProc(var Message: TMessage) ; override;
   private
     //procedure PerformMessage(cm_msg : integer; msg : TMessage) ;
   end;

  TMenuCloseEvent = procedure (Sender: TObject) of object;

  TRnQPopupMenu = class(TPopupMenu)
  private
    FOnClose: TMenuCloseEvent;
    //procedure WMMENUSELECT(var msg: TWMMENUSELECT); message WM_MENUSELECT;
    procedure ExecuteOnClose;

  protected
//    procedure WndProc(var Message: TMessage) ; override;
    procedure DoPopup(Sender: TObject); override;

  public
    FIsOpenen : boolean;
    constructor Create(AOwner: TComponent); override;
  published
    property Alignment;
    property AutoHotkeys;
    property AutoLineReduction;
    property AutoPopup;
    property BiDiMode;
    property HelpContext;
    property Images;
    property MenuAnimation;
    property OwnerDraw;
    property ParentBiDiMode;
    property TrackButton;
    property OnChange;
    property OnClose: TMenuCloseEvent read FOnClose write FOnClose;
    property OnPopup;
  end;

  TRQMenuItem = class(TMenuItem)
    protected
      fImgElm : TRnQThemedElementDtls;
      FImageName  : TPicName;
//      ThemeToken : Integer;
//      ImageLoc   : TPicLocation;
//      ImageIdx   : Integer;
      procedure AdvancedDrawItem(ACanvas: TCanvas; ARect: TRect;
        State: TOwnerDrawState; TopLevel: Boolean); override;
//      function drawMenuItemR(cnv:Tcanvas; Amenu:Tmenu; item:Tmenuitem;
//        r:Trect; onlysize:boolean=FALSE):Tpoint;
      procedure MeasureItem(ACanvas: TCanvas; var Width, Height: Integer); override;
      procedure SetImageName(const Value: TPicName);
    public
//      FCaptionW: WideString;
      CanTranslate : Boolean;
    {$ifdef MirandaSupport}
      ServiceName : String;
      procedure OnMenuClick(Sender: TObject);
    {$endif}
      PluginProc : Pointer;
//      ProtoLink  : Pointer;
      ProtoLink  : TObject;
//      ProcIdx : Integer;
//      procedure OnPluginMenuClick(Sender: TObject);
      constructor Create(AOwner: TComponent); override;
      procedure onExitMenu(var Msg: TMessage); message WM_EXITMENULOOP;
      property  ImageName : TPicName read FImageName write SetImageName;
  end;
//  function drawMenuItemR(ACanvas : TCanvas; Amenu:Tmenu; item:Tmenuitem;
//                    r:Trect; onlysize:boolean=FALSE;
//                    drawbar : Boolean = True; Selected : Boolean = false):Tpoint;

  function GPdrawmenuitemR7(ACanvas : TCanvas; Amenu: Tmenu; item: Tmenuitem; r: Trect;
           onlysize:boolean=FALSE; drawbar : Boolean = True; Selected : Boolean = false): Tpoint;

 {$IFNDEF NO_WIN98}
//  function drawmenuitemR98(cnv : TCanvas; Amenu:Tmenu; item:Tmenuitem; r:Trect;
//           onlysize:boolean=FALSE; drawbar : Boolean = True; Selected : Boolean = false):Tpoint;
 {$ENDIF NO_WIN98}
  procedure Register;

implementation
 uses
   RnQGlobal, RQUtil, RnQStrings, SysUtils, Forms,
 {$ifdef MirandaSupport}
   m_globaldefs,
   m_api,
 {$endif}
  {$IFNDEF NOT_USE_GDIPLUS}
    GDIPAPI, GDIPOBJ,
  {$ELSE}
   RnQGraphics32,
  {$ENDIF NOT_USE_GDIPLUS}
 {$IFDEF UNICODE}
   AnsiStrings,
 {$ENDIF UNICODE}
   StrUtils, math, ActnList;



{
procedure TPopupMenuX.PerformMessage(cm_msg: integer; msg : TMessage) ;
begin
   if Screen.Activeform <> nil then
     Screen.ActiveForm.Perform(cm_msg, msg.WParam, msg.LParam) ;
end;
}

procedure TRnQPopupMenu.DoPopup(Sender: TObject);
begin
  FIsOpenen := True;  
{             GDIPlus.Brush := NewGPSolidBrush(KOLGDIPV2.LightBlue);
             GDIPlus.DeviceContext := Self.Items. cnv.Handle;
             GDIPlus.FillRectangle(cnv.ClipRect);
//  GDIPlus.Pen := NewGPPen(KOLGDIPV2.Black, 1);
//  GDIPlus.DrawRectangle(ARect);
//  GDIPlus.FillRectangle(0, 40, 10, 10);
             GDIPlus.DeviceContext := 0;
}
  inherited DoPopup(Sender);
end;

constructor TRnQPopupMenu.Create(AOwner: TComponent);
begin
  FIsOpenen := False;
  inherited Create(AOwner);
end;


procedure TRnQPopupMenu.ExecuteOnClose;
begin
  FIsOpenen := False;
  if Assigned(FOnClose) then
    FOnClose(Self);
end;

procedure Register;
begin
  RegisterComponents('RnQ', [TRnQPopupMenu]);
end;


procedure TPopupListEx.WndProc(var Message: TMessage);
var
  nTi : integer;
//  tt : HMENU;
begin
   case message.Msg of
     //WM_ENTERMENULOOP: PerformMessage(CM_ENTER_MENU_LOOP, Message) ;
//     WM_EXITMENULOOP : PerformMessage(CM_EXIT_MENU_LOOP, Message) ;
     WM_MENUSELECT :
     with TWMMenuSelect(Message) do
     begin
       if (Menu = 0) and (Menuflag = $FFFF) then
       begin
          for nTi := 0 to Count-1 do
          begin
            if TObject(Items[nTi]) is TRnQPopupMenu then
            begin
              if TRnQPopupMenu(Items[nTi]).FIsOpenen then
                TRnQPopupMenu(Items[nTi]).ExecuteOnClose;
            end;
          end;
//         PerformMessage(CM_MENU_CLOSED, Message) ;
       end;
     end;
   end;
   inherited;
end;


constructor TRQMenuItem.Create(AOwner: TComponent);
begin
  inherited;
  fImgElm.Element := RQteMenu;
  fImgElm.picName := '';
  fImgElm.ThemeToken := -1;
  CanTranslate := True;
end;


procedure TRQMenuItem.AdvancedDrawItem(ACanvas: TCanvas; ARect: TRect;
        State: TOwnerDrawState; TopLevel: Boolean);
begin
 {$IFNDEF NO_WIN98}
// if Win32MajorVersion < 5 then
//   drawmenuitemR98(ACanvas, TmenuItem(Self).GetParentMenu, self, ARect, false, True, odSelected in State)
//  else
 {$ENDIF WIN98}
   GPdrawmenuitemR7(ACanvas, TmenuItem(Self).GetParentMenu, self, ARect, false, True, odSelected in State);
end;

procedure TRQMenuItem.MeasureItem(ACanvas: TCanvas; var Width, Height: Integer);
var
  p: Tpoint;
begin
 {$IFNDEF NO_WIN98}
// if Win32MajorVersion < 5 then
//   p := drawmenuitemR98(ACanvas, NIL, TmenuItem(Self), rect(0,0,width,height), True)
//  else
 {$ENDIF WIN98}
   p := GPdrawmenuitemR7(ACanvas, NIL, TmenuItem(Self), rect(0,0,width,height), True);
  width := p.x;
//  inc(height, 2);
  inc(p.y, 2);
  if (not MenuHeightPerm) or (height<p.y) then
    height := p.y;
end;

(*
function drawmenuitemR98(cnv : TCanvas; Amenu: Tmenu; item: Tmenuitem; r: Trect;
           onlysize:boolean=FALSE; drawbar : Boolean = True; Selected : Boolean = false):Tpoint;
const
  cBarWidth = 20;
var
  x,k:integer;
  picSize : TSize;
  PicName : String;
  s:string;
  fullR : TRect;
  rB : TRect;
  clBar : TColor;
  r1 : TRect;
//  gpR, resR :TGPRectF;
{  gr  : TGPGraphics;
  gfmt :TGPStringFormat;
  br  : TGPBrush;
  pen : TGPPen;}
//  dc  : HDC;

  procedure embossedCenteredLine(x1,x2:integer);
  var
    y:integer;
  begin
    y:=(R.Top+R.bottom) div 2;
{    pen := TGPPen.Create(gpColorFromAlphaColor($FF, clBtnShadow));
    gr.DrawLine(pen, x1,y, x2,y);
    pen.Free;
    inc(y);
    pen := TGPPen.Create(gpColorFromAlphaColor($FF, clBtnHighlight));
    gr.DrawLine(pen, x1,y, x2,y);
    pen.Free;
}
//    move
//    LineTo(dc, )
    cnv.Pen.color:=clBtnShadow;
    cnv.MoveTo(x1,y);
    cnv.lineTo(x2,y);
    inc(y);
    cnv.Pen.color:=clBtnHighlight;
    cnv.MoveTo(x1,y);
    cnv.lineTo(x2,y);
  end; // embossedCenteredLine

var
  res : Tsize;
//  fnt : TGPFont;
      ThemeToken : Integer;
      ImageLoc   : TPicLocation;
      ImageIdx   : Integer;
//  ABitmap : HBITMAP;
  Hbr : HBrush;
begin
  fullR := r;
{  try
    DC := CreateCompatibleDC(ACanvas.Handle);
    with fullR do
    begin
      ABitmap := CreateCompatibleBitmap(ACanvas.Handle, Right-Left, Bottom-Top);
      if (ABitmap = 0) and (Right-Left + Bottom-Top <> 0) then
        raise EOutOfResources.Create('Out of Resources');
      HOldBmp := SelectObject(DC, ABitmap);
      SetWindowOrgEx(DC, Left, Top, Nil);
    end;
  finally

  end;
}
//  itemfocused:=cnv.brush.color = clHighlight;
//  itemfocused:=Selected;
  //  cnv.Font.Color := clMenuText;
  s:=item.caption;
 try

 // Draw Bar and Clear
  if (not onlysize) then
   begin
  //  cnv.brush.color := clMenu;
//    cnv.FillRect(r);
//    if 1=1 then
    if ((item.Tag<4000)or(item.Tag>4999)) then
     begin
{       if drawbar then
       if (Assigned(item.Parent) and (item.Parent.Parent = NIL))
            and (Assigned(Amenu) and (Amenu.Tag = 666)) then
        begin
         r.Left := r.Left + cBarWidth;
         if (item.MenuIndex = 0) and not itemfocused then
//         if item.Parent = NIL then
          with GDIPlus^ do
           begin
//             r1.
             r1 := cnv.ClipRect;
             r1.Right := cBarWidth;
//             r1.Top := r1.Bottom;
//             r1.Bottom := cnv.ClipRect.Top;
//             GDIPlus.Brush := NewGPLinearGradientBrush(cnv.ClipRect, StartColor, EndColor);
//             Brush := NewGPSolidBrush(LightBlue);
             Brush := NewGPSolidBrush(theme.GetAColor('menu.fade1', clBar));
             DeviceContext := cnv.Handle;
             FillRectangle(r1);
             Font := NewGPFont(20, 'Arial', [kol.fsBold]);//, kol.fsItalic]);
             fnt := NewGPStringFormat([SFDirectionVertical, SFNoWrap, SFDirectionRightToLeft]);
             fnt.Alignment := SFAlignmentCenter;
             fnt.LineAlignment := SFAlignmentCenter;
             Brush := NewGPSolidBrush(theme.GetAColor('menu.font', cnv.Font.Color));  //$FF0000FF);
             DrawString('R&Q @ ' + 'http://RnQ.ru', r1, fnt);
//  GDIPlus.Pen := NewGPPen(KOLGDIPV2.Black, 1);
//  GDIPlus.DrawRectangle(ARect);
//  GDIPlus.FillRectangle(0, 40, 10, 10);
             DeviceContext := 0;
             fnt.Free;

           end;
        end;         }
       r1 := r;
       if ((item.Tag<4000)or(item.Tag>4999)) then
         r1.Left := r1.Left + cBarWidth-1;
//      FillGradient(cnv.Handle, r1, 128, theme.GetColor('menu.fade1', clMenuBar),
//                theme.GetColor('menu.fade2', clMenu));
      clBar := theme.GetColor('menu.bar', clMenuBar); //menu.barColor;//clMenuBar;
      if (clBar = clBlack)or(clBar = clDefault) then
        clBar := clBtnFace; //menu.barColor;//clMenuBar;

      if (item.MenuIndex = item.Parent.Count-1) or
         ((item.MenuIndex+1 < item.Parent.Count) and
          (item.Parent.Items[item.MenuIndex+1].Break <> mbNone)) then
      begin
          r1.Bottom := cnv.ClipRect.Bottom
      end;

{      if MenuDrawExt then
      begin
        gr := TGPGraphics.Create(dc);
//        br := TGPSolidBrush.Create(theme.GetAColor('menu.fade1', clBar));
        br := TGPLinearGradientBrush.Create(MakeRect(r), theme.GetAColor('menu.fade1', clBar),
            theme.GetAColor('menu.fade2', clMenu), 0);
        gr.FillRectangle(br, MakeRect(r1));
//      pen := TGPPen.Create(theme.GetAColor('menu.selected', clMenuHighlight));
//      gr.DrawRectangle(pen, MakeRect(r1));
        br.Free;

        br := TGPSolidBrush.Create(gpColorFromAlphaColor($FF, clBar));
        rB := r;
        rB.Right := rB.Left + cBarWidth;
        gr.FillRectangle(br, MakeRect(rB));
        br.Free;
        gr.Free;
      end
      else   }
      begin
//        cnv.brush.color := theme.GetColor('menu.fade1', clBar);
//        cnv.FillRect(r1);
        Hbr := CreateSolidBrush(ColorToRGB(theme.GetColor('menu.fade1', clBar)));
        FillRect(cnv.Handle, r1, hbr);
        DeleteObject(Hbr);

//        cnv.brush.color := clBar;
        Hbr := CreateSolidBrush(ColorToRGB(clBar));
        rB := r;
        rB.Right := rB.Left + cBarWidth;
//        cnv.FillRect(rB);
        FillRect(cnv.Handle, rB, hbr);
        DeleteObject(Hbr);
      end;
     end
    else
     begin
//       bmp := createBitmap(cnv.ClipRect.Right, cnv.ClipRect.Bottom);
//       bmp.PixelFormat :=pf24bit;
       r1 := r;
//       r1 := cnv.ClipRect;
//       r1.Left := r1.Left + cBarWidth;
      if (item.MenuIndex = item.Parent.Count-1) or
          ((item.MenuIndex+1 < item.Parent.Count) and
           (item.Parent.Items[item.MenuIndex+1].Break <> mbNone)) then
       begin
         r1.Bottom := cnv.ClipRect.Bottom
       end;
{
       r1.Right := (r1.Left + r1.Right) div 2;
//       FillGradient(cnv.Handle, r1, 128, theme.GetColor('menu.fade2', clMenu),
//                  theme.GetColor('menu.fade1', clMenuBar));
       gr := TGPGraphics.Create(cnv.Handle);
       br := TGPLinearGradientBrush.Create(MakeRect(r1), theme.GetAColor('menu.fade2', clMenu),
          theme.GetAColor('menu.fade1', clMenuBar), 0);
       gr.FillRectangle(br, MakeRect(r1));
       br.Free;

       r1.Left := r1.Right-2;
       r1.Right := r.Right;
//       FillGradient(cnv.Handle, r1, 128, theme.GetColor('menu.fade1', clMenuBar),
//                  theme.GetColor('menu.fade2', clMenu));

       br := TGPLinearGradientBrush.Create(MakeRect(r1), theme.GetAColor('menu.fade1', clMenuBar),
          theme.GetAColor('menu.fade2', clMenu), 0);
       gr.FillRectangle(br, MakeRect(r1));
       br.Free; 
       gr.Free; }
{       BitBlt(cnv.Handle, r.Left, r.Top, r.Right - r.Left, r.Bottom - r.Top,
              bmp.Canvas.Handle, r.Left, r.Top, SrcCopy);
       bmp.Free;}
  //      cnv.brush.color := clMenu;
//      rB := r;
//      rB.Left := rB.Left + cBarWidth;
  //      cnv.FillRect(r1);
        Hbr := CreateSolidBrush(ColorToRGB(clMenu));
        FillRect(cnv.Handle, r1, hbr);
        DeleteObject(Hbr);
    end;
//    inc(r.Left, cBarWidth);
//    inc(r.Right, cBarWidth);
  end;

  result.x:=0;//cBarWidth;
  result.y:=0;
{  gpR.X := r.Left;
  gpR.Y := r.Top;
  gpR.Width := r.Right - r.Left;
  gpR.Height := r.Bottom - r.Top;  }
//  ACanvas.Font.Size := ACanvas.Font.Size;
  if Selected then
    begin
      cnv.Font.Color := clMenuText;
      cnv.Font := theme.GetFont('menu.selected', cnv.Font)
    end
   else
    cnv.Font := theme.GetFont('menu', cnv.Font);
  if s='-' then
   begin
//    gr := TGPGraphics.Create(dc);
    GetTextExtentPoint32(cnv.handle,pchar(s),length(s), res);
//    res.cy := 3;
    result.y:=res.cy;
    s:=item.hint;
    if s='' then
      begin
        if not onlysize then
         begin
          embossedCenteredLine(R.left, R.right);
         end;
//        gr.Free;
//       DeleteObject(ABitmap);
//       DeleteDC(DC);
       exit;
      end;
    if onlysize then
      k:=DT_CALCRECT
     else
      k:=0;
  //    cnv.font.height:=R.top-R.bottom;
  //    cnv.font.color:=clBtnShadow;
    SetBkMode(cnv.handle, TRANSPARENT);
//    fnt := TGPFont.Create(ACanvas.Font.Name, 9, FontStyleRegular, UnitPoint);
{     if onlysize then
       gr.MeasureString(s, length(s), fnt, gpR, resR)
      else
       begin
         gfmt := TGPStringFormat.Create(StringFormatFlagsNoWrap);
         gfmt.SetLineAlignment(StringAlignmentCenter);
         gfmt.SetAlignment(StringAlignmentCenter);
         br := TGPSolidBrush.Create(gpColorFromAlphaColor($FF, clBtnShadow));
         gr.MeasureString(s, length(s), fnt, gpR, resR);
         gr.DrawString(s, length(s), fnt, gpR, gfmt, br);
         br.Free;
         gfmt.Free;
       end;
    fnt.Free;           }

    drawText(cnv.Handle, PChar(s), -1, R, k or DT_SINGLELINE or DT_VCENTER or DT_CENTER);
    GetTextExtentPoint32(cnv.Handle,pchar(s),length(s), res);
    if not onlysize then
     begin
      embossedCenteredLine(R.left, (R.right - Trunc(res.cy)) div 2);
      embossedCenteredLine( (R.right + Trunc(res.cy)) div 2 ,R.right);
     end;
//    gr.Free;
    result.y:=max(result.y, res.cy);
//    result.y:=max(result.y, Trunc(resR.Height));
//     DeleteObject(ABitmap);
//     DeleteDC(DC);
    exit;
   end;
{  if item.tag=3010 then
   with cnv.font do
    begin
    style:=style+[fsBold];
    Size:=Size+3;
    end;
}
  if onlysize then
    x:=0
//  x:=cBarWidth
   else
    x:=R.Left;

  if Selected then
  begin
    rB := r;
    Inc(rB.Top);
    Dec(rB.Bottom);
    Inc(rB.Left);
    Dec(rB.Right);
//    cnv.brush.color := theme.GetColor('menu.selected', clMenuHighlight);
{    if MenuDrawExt then
     begin
      gr := TGPGraphics.Create(dc);
//    br := TGPSolidBrush.Create(GPtranspPColor(gpColorFromAlphaColor($A0, theme.GetColor('menu.selected', clMenuHighlight))));
      br := TGPLinearGradientBrush.Create(MakeRect(rb), gpColorFromAlphaColor($A0, theme.GetColor('menu.selected', clMenuHighlight)),
          aclTransparent, 90);
//    br := TGPSolidBrush.Create( gpColorFromAlphaColor($A0, theme.GetColor('menu.selected', clMenuHighlight)));
//    br := TGPSolidBrush.Create( theme.GetAColor('menu.selected', clMenuHighlight));
//    br := TGPSolidBrush.Create(GPtranspPColor(theme.GetAColor('menu.selected', clMenuHighlight)));
      gr.FillRectangle(br, MakeRect(rb));
      br.Free;
      pen := TGPPen.Create(theme.GetAColor('menu.selected', clMenuHighlight));
      gr.DrawRectangle(pen, MakeRect(rb));
      pen.Free;
      gr.Free;
     end
    else        }
     begin
        Hbr := CreateSolidBrush(addLuminosity(theme.GetColor('menu.selected', ColorToRGB(clMenuHighlight)), 0.7));
        FillRect(cnv.Handle, rB, hbr);
        DeleteObject(Hbr);

//      cnv.Pen.color := theme.GetColor('menu.selected', clMenuHighlight);
//      cnv.brush.color := addLuminosity(cnv.Pen.color, 0.7);
//      cnv.FillRect(rB);
//      cnv.Brush.Style := bsClear;
//      cnv.RoundRect(r.Left,r.top,r.Right,r.Bottom, 0, 0);
      Dec(r.Top, 1);
      Inc(r.Bottom, 1);
     end;
 end;
  PicName := '';
  if not item.Bitmap.empty then
    begin
      PicName := Str_Error;
    end
  else
  if Assigned(item.Action) then
   begin
     PicName := TAction(item.Action).HelpKeyword;
     if (item is TRQMenuItem) then
       TRQMenuItem(item).ThemeToken := -1;
   end
  else
   if (item is TRQMenuItem) then
     picName:= TRQMenuItem(item).ImageName;
  if PicName<>'' then
   begin
     ThemeToken := -1;
     if (item is TRQMenuItem) then
       picSize := theme.GetPicSize(PicName, TRQMenuItem(item).ThemeToken,
            TRQMenuItem(item).ImageLoc, TRQMenuItem(item).ImageIdx)
      else
       picSize := theme.GetPicSize(PicName, ThemeToken, ImageLoc, ImageIdx);
    inc(x,2);
    if not onlysize then
     begin
      k:=(r.top+r.bottom-picSize.cy) div 2;
//      gr := TGPGraphics.Create(dc);
      if (item is TRQMenuItem) then
        theme.drawPic(cnv.Handle, x,k,PicName,TRQMenuItem(item).ThemeToken,
            TRQMenuItem(item).ImageLoc, TRQMenuItem(item).ImageIdx, item.enabled)
       else
         theme.drawPic(cnv.Handle, x,k,PicName, ThemeToken, ImageLoc, ImageIdx, item.enabled);
//      gr.Free;
     end;
    inc(x, MAX(picSize.cx+2,cBarWidth-2) );
//    inc(x,2);
   end
  else
    inc(x, cBarWidth);
  inc(x,2);
  R.left:=x;
//  gpR.X := r.Left;
  if onlysize then k:=DT_CALCRECT else k:=0;
  SetBkMode(cnv.Handle, TRANSPARENT);
  inc(k, DT_SINGLELINE+DT_VCENTER+DT_LEFT);

 if (item.Tag<4000)or(item.Tag>4999)or(ShowSmileCaption) then
// Не рисуим там, где смайлы
 begin
   if not item.enabled then
    begin
    if not selected then
      begin
  //      cnv.Font.Color := clBtnHighlight;
      OffsetRect(R, 1, 1);
      DrawText(cnv.Handle, pchar(s), -1, R, k);
      OffsetRect(R, -1, -1);
      end;
      cnv.font.color:=clBtnShadow;
    end;
{    if not item.enabled then ACanvas.font.color:=clGrayText;
    fnt := TGPFont.Create(ACanvas.Font.Name, ACanvas.Font.Size, FontStyleRegular, UnitPoint);
//    fnt := TGPFont.Create(ACanvas.Font.Name, ACanvas.Font.Size, FontStyleRegular, UnitPixel);
    gfmt := TGPStringFormat.Create(StringFormatFlagsNoWrap or StringFormatFlagsMeasureTrailingSpaces);
    gfmt.SetLineAlignment(StringAlignmentCenter);
    gfmt.SetHotkeyPrefix(HotkeyPrefixShow);
    gr.MeasureString(s, length(s), fnt,MakePoint(gpR.X, gpR.Y), gfmt, resR);
     if not onlysize then
       begin
//         gfmt.SetAlignment(StringAlignmentCenter);
         br := TGPSolidBrush.Create(gpColorFromAlphaColor($FF, ACanvas.Font.Color));
         gr.DrawString(s, length(s), fnt, gpR, gfmt, br);
         br.Free;
       end;
    gfmt.Free;
    fnt.Free;     }
   drawText(cnv.Handle, PChar(s), -1, R, k);
   inc(x, R.right);
//   inc(x, trunc(resR.Width));
 end;
// else
//   drawText(dc, ' ', -1, R, k);

  if item.Checked then
   begin
     ThemeToken := -1;
     with theme.GetPicSize(PIC_CURRENT, ThemeToken, ImageLoc, ImageIdx) do
      begin
       if not onlysize then
         theme.drawPic(cnv.Handle, r.Right-cx-5, R.Top + (r.Bottom-r.Top - cy)div 2,
           PIC_CURRENT, ThemeToken, ImageLoc, ImageIdx);
        inc(x, cx+2);
      end;
   end;
  result.x:=x;
// gr.Free;
  GetTextExtentPoint32(cnv.Handle,pchar(s),length(s), res);
  result.y:=res.cy;
//  result.y:= Trunc(resR.Height);
  if PicName='' then k:=0 else
    begin
      k:=picSize.cy+2;
    end;
  if result.y<k then result.y:=k;
  if onlysize then
   if item.Count > 0 then
     inc(result.x, 5);

 finally
//  BitBlt(ACanvas.Handle, fullR.Left, fullR.Top,
//    fullR.Right - fullR.Left, fullR.Bottom - fullR.Top,
//    dc, fullR.Left, fullR.Top, SrcCopy);

//  DeleteObject(ABitmap);
//  DeleteDC(DC);
 end;
end;
*)
(*
function GPdrawmenuitemR(ACanvas : TCanvas; Amenu:Tmenu; item:Tmenuitem; r:Trect;
           onlysize:boolean=FALSE; drawbar : Boolean = True; Selected : Boolean = false):Tpoint;
const
  cBarWidth = 20;
var
  x,k:integer;
  picSize : TSize;
  PicName : String;
  s:string;
  fullR : TRect;
  rB : TRect;
  clBar : TColor;
  r1 : TRect;
  gpR, resR :TGPRectF;
  gr  : TGPGraphics;
  gfmt :TGPStringFormat;
  br  : TGPBrush;
  pen : TGPPen;

  procedure embossedCenteredLine(x1,x2:integer);
  var
    y:integer;
  begin
    y:=(R.Top+R.bottom) div 2;
    pen := TGPPen.Create(gpColorFromAlphaColor($FF, clBtnShadow));
    gr.DrawLine(pen, x1,y, x2,y);
    pen.Free;
    inc(y);
    pen := TGPPen.Create(gpColorFromAlphaColor($FF, clBtnHighlight));
    gr.DrawLine(pen, x1,y, x2,y);
    pen.Free;
  end; // embossedCenteredLine

var
  res : Tsize;
  fnt : TGPFont;
      ThemeToken : Integer;
      ImageLoc   : TPicLocation;
      ImageIdx   : Integer;
  dc  : HDC;
  ABitmap, HOldBmp : HBITMAP;
  fontTransp : Byte;
//  Hbr : HBrush;
begin
  fullR := r;
  try
    DC := CreateCompatibleDC(ACanvas.Handle);
    HOldBmp := 0;
    with fullR do
    if ((Right-Left) >0) and ((Bottom-Top) > 0) then
    begin
      ABitmap := CreateCompatibleBitmap(ACanvas.Handle, Right-Left, Bottom-Top);
      if (ABitmap = 0) and (Right>Left)and(Bottom>Top) then
       begin
        DeleteDC(DC);
        DC := 0;
        raise EOutOfResources.Create('Out of Resources');
       end;
      HOldBmp := SelectObject(DC, ABitmap);
      SetWindowOrgEx(DC, Left, Top, Nil);
    end
    else
     ABitmap := 0;
  finally

  end;

//  itemfocused:=cnv.brush.color = clHighlight;
//  itemfocused:=Selected;
  //  cnv.Font.Color := clMenuText;
  s:=item.caption;
 try
  gr := TGPGraphics.Create(dc);

 // Draw Bar and Clear
  if (not onlysize) then
   begin
    r1 := r;
    if (item.MenuIndex = item.Parent.Count-1) or
       ((item.MenuIndex+1 < item.Parent.Count) and
        (item.Parent.Items[item.MenuIndex+1].Break <> mbNone)) then
    begin
        r1.Bottom := ACanvas.ClipRect.Bottom
    end;
    clBar := theme.GetColor('menu.bar', clMenuBar); //menu.barColor;//clMenuBar;
    if ((item.Tag<4000)or(item.Tag>4999)) then
     begin
       r1.Left := r1.Left + cBarWidth-1;
       if (clBar = clBlack)or(clBar = clDefault) then
         clBar := clBtnFace; //menu.barColor;//clMenuBar;
       br := TGPLinearGradientBrush.Create(MakeRect(r), theme.GetAColor('menu.fade1', clBar),
            theme.GetAColor('menu.fade2', clMenu), 0);
     end
     else
       br := TGPSolidBrush.Create(gpColorFromAlphaColor($FF, clMenu));

    gr.FillRectangle(br, MakeRect(r1));
//      pen := TGPPen.Create(theme.GetAColor('menu.selected', clMenuHighlight));
//      gr.DrawRectangle(pen, MakeRect(r1));
    br.Free;

    if ((item.Tag<4000)or(item.Tag>4999)) then
     begin
      begin
//        br := TGPSolidBrush.Create(theme.GetAColor('menu.fade1', clBar));
        br := TGPSolidBrush.Create(gpColorFromAlphaColor($FF, clBar));
        rB := r;
        rB.Right := rB.Left + cBarWidth;
        gr.FillRectangle(br, MakeRect(rB));
        br.Free;
      end
     end
//    inc(r.Left, cBarWidth);
//    inc(r.Right, cBarWidth);
  end;

  result.x:=0;//cBarWidth;
  result.y:=0;
  gpR.X := r.Left;
  gpR.Y := r.Top;
  gpR.Width := r.Right - r.Left;
  gpR.Height := r.Bottom - r.Top;
//  ACanvas.Font.Size := ACanvas.Font.Size;
  if Selected then
    begin
      ACanvas.Font.Color := clMenuText;
      ACanvas.Font := theme.GetFont('menu.selected', ACanvas.Font)
    end
   else
    ACanvas.Font := theme.GetFont('menu', ACanvas.Font);
  if s='-' then
   begin
    res.cy := 3;
    result.y:=res.cy;
    s:=item.hint;
    if s='' then
      begin
        if not onlysize then
          embossedCenteredLine(R.left, R.right);
      end
    else
     begin
       fnt := TGPFont.Create(ACanvas.Font.Name, 9, FontStyleRegular, UnitPoint);
//    DrawText(DC, PChar(s), -1, R, k or DT_SINGLELINE or DT_VCENTER or DT_CENTER, );
//    GetTextExtentPoint32(DC,pchar(s),length(s), res);
//       TextOut()
       gr.MeasureString(s, length(s), fnt, gpR, resR);
        if not onlysize then
          begin
            embossedCenteredLine(R.left, (R.right - Trunc(resR.Width)) div 2);
            embossedCenteredLine( (R.right + Trunc(resR.Width)) div 2 ,R.right);
            gfmt := TGPStringFormat.Create(StringFormatFlagsNoWrap);
            gfmt.SetLineAlignment(StringAlignmentCenter);
            gfmt.SetAlignment(StringAlignmentCenter);
            br := TGPSolidBrush.Create(gpColorFromAlphaColor($FF, clBtnShadow));
//            gr.MeasureString(s, length(s), fnt, gpR, resR);
            gr.DrawString(s, length(s), fnt, gpR, gfmt, br);
            br.Free;
            gfmt.Free;
          end;
       fnt.Free;
       result.y:=max(result.y, Trunc(resR.Height));
     end;
    gr.Free;
    exit;
   end;
{  if item.tag=3010 then
   with cnv.font do
    begin
    style:=style+[fsBold];
    Size:=Size+3;
    end;
}
  if onlysize then
    x:=0
//  x:=cBarWidth
   else
    x:=R.Left;

  if Selected then
  if not onlysize then
  begin
    rB := r;
    Inc(rB.Top);
    Dec(rB.Bottom);
//    Inc(rB.Left);
    Dec(rB.Right);
//    br := TGPSolidBrush.Create( theme.GetAColor('menu.selected', clMenuHighlight));
    br := TGPLinearGradientBrush.Create(MakeRect(rb), gpColorFromAlphaColor($A0, theme.GetColor('menu.selected', clMenuHighlight)),
           aclTransparent, 90);
    gr.FillRectangle(br, MakeRect(rb));
    br.Free;
    pen := TGPPen.Create(theme.GetAColor('menu.selected', clMenuHighlight));
    gr.DrawRectangle(pen, MakeRect(rb));
    pen.Free;
 end;
  PicName := '';
  if not item.Bitmap.empty then
     PicName := Str_Error
   else
    if Assigned(item.Action) then
     begin
       PicName := TAction(item.Action).HelpKeyword;
       if (item is TRQMenuItem) then
         TRQMenuItem(item).ThemeToken := -1;
     end
    else
     if (item is TRQMenuItem) then
       picName:= TRQMenuItem(item).ImageName;
  if PicName<>'' then
   begin
     ThemeToken := -1;
     if (item is TRQMenuItem) then
       picSize := theme.GetPicSize(PicName, TRQMenuItem(item).ThemeToken,
            TRQMenuItem(item).ImageLoc, TRQMenuItem(item).ImageIdx)
      else
       picSize := theme.GetPicSize(PicName, ThemeToken, ImageLoc, ImageIdx);
    inc(x,2);
    if not onlysize then
     begin
      k:=(r.top+r.bottom-picSize.cy) div 2;
      if (item is TRQMenuItem) then
        theme.drawPic(gr, x,k,PicName,TRQMenuItem(item).ThemeToken,
            TRQMenuItem(item).ImageLoc, TRQMenuItem(item).ImageIdx, item.enabled)
       else
         theme.drawPic(gr, x,k,PicName, ThemeToken, ImageLoc, ImageIdx, item.enabled);
     end;
    inc(x, MAX(picSize.cx+2,cBarWidth-2) );
//    inc(x,2);
   end
  else
    inc(x, cBarWidth);
  inc(x,2);
  R.left:=x;
  gpR.X := r.Left;
  resR.Height := 0;
  resR.Width  := 0;

 if (item.Tag<4000)or(item.Tag>4999)or(ShowSmileCaption) then
// Не рисуим там, где смайлы
 begin
{   if not item.enabled then
    begin
    if not selected then
      begin
  //      cnv.Font.Color := clBtnHighlight;
      OffsetRect(R, 1, 1);
      DrawText(dc, pchar(s), -1, R, k);
      OffsetRect(R, -1, -1);
      end;
  //    cnv.font.color:=clBtnShadow;
    end;}
    if not item.enabled then
      fontTransp := $70
     else
      fontTransp := $FF;
//     ACanvas.font.color:=clGrayText;

    fnt := TGPFont.Create(ACanvas.Font.Name, ACanvas.Font.Size, FontStyleRegular, UnitPoint);
//    fnt := TGPFont.Create(ACanvas.Font.Name, ACanvas.Font.Size, FontStyleRegular, UnitPixel);
    gfmt := TGPStringFormat.Create(StringFormatFlagsNoWrap or StringFormatFlagsMeasureTrailingSpaces);
    gfmt.SetLineAlignment(StringAlignmentCenter);
    gfmt.SetHotkeyPrefix(HotkeyPrefixShow);
    gr.MeasureString(s, length(s), fnt,MakePoint(gpR.X, gpR.Y), gfmt, resR);
     if not onlysize then
       begin
         br := TGPSolidBrush.Create(gpColorFromAlphaColor(fontTransp, ACanvas.Font.Color));
         gr.DrawString(s, length(s), fnt, gpR, gfmt, br);
         br.Free;
       end;
    gfmt.Free;
    fnt.Free;
   inc(x, trunc(resR.Width));
 end;

  if item.Checked then
   begin
     ThemeToken := -1;
     with theme.GetPicSize(PIC_CURRENT, ThemeToken, ImageLoc, ImageIdx) do
      begin
       if not onlysize then
         theme.drawPic(gr, r.Right-cx-5, R.Top + (r.Bottom-r.Top - cy)div 2,
           PIC_CURRENT, ThemeToken, ImageLoc, ImageIdx);
        inc(x, cx+2);
      end;
   end;
  result.x:=x;
  result.y:= Trunc(resR.Height);
  if PicName='' then k:=0 else
    begin
      k:=picSize.cy+2;
    end;
  if result.y<k then result.y:=k;
  if onlysize then
   if item.Count > 0 then
     inc(result.x, 5);

  gr.Free;
 finally
  if not onlysize then
    BitBlt(ACanvas.Handle, fullR.Left, fullR.Top,
     fullR.Right - fullR.Left, fullR.Bottom - fullR.Top,
     dc, fullR.Left, fullR.Top, SrcCopy);

  SelectObject(DC, HOldBmp);
  DeleteObject(ABitmap);
  DeleteDC(DC);
 end;
end;
*)


function GPdrawmenuitemR7(ACanvas : TCanvas; Amenu:Tmenu; item:Tmenuitem; r:Trect;
           onlysize:boolean=FALSE; drawbar : Boolean = True; Selected : Boolean = false):Tpoint;
const
  cBarWidth1 = 20;
var
  x,k:integer;
  picSize : TSize;
  s   : string;
  fullR : TRect;
  rB  : TRect;
  r1  : TRect;
  clBar : TColor;
//  gpR, resR :TGPRectF;
  {$IFNDEF NOT_USE_GDIPLUS}
  gr  : TGPGraphics;
//  gfmt :TGPStringFormat;
  br  : TGPBrush;
  pen : TGPPen;
  {$ENDIF NOT_USE_GDIPLUS}
  dc  : HDC;

{  procedure embossedCenteredLine(x1,x2:integer);
  var
    y:integer;
  begin
    y:=(R.Top+R.bottom) div 2;
    pen := TGPPen.Create(gpColorFromAlphaColor($FF, clBtnShadow));
    gr.DrawLine(pen, x1,y, x2,y);
    pen.Free;
    inc(y);
    pen := TGPPen.Create(gpColorFromAlphaColor($FF, clBtnHighlight));
    gr.DrawLine(pen, x1,y, x2,y);
    pen.Free;
  end; // embossedCenteredLine
}
  procedure embossedCenteredLine(x1,x2:integer);
  var
    y:integer;
    oldP, hp : HPEN;
  begin
    y:=(R.Top+R.bottom) div 2;
{    pen := TGPPen.Create(gpColorFromAlphaColor($FF, clBtnShadow));
    gr.DrawLine(pen, x1,y, x2,y);
    pen.Free;
    inc(y);
    pen := TGPPen.Create(gpColorFromAlphaColor($FF, clBtnHighlight));
    gr.DrawLine(pen, x1,y, x2,y);
    pen.Free;
}
//    move
//    LineTo(dc, )
    hp := CreatePen(PS_SOLID, 1, ColorToRGB(clBtnShadow));
    oldP := SelectObject(DC, hp);
    MoveToEx(DC, x1,y, NIL);
    lineTo(DC, x2,y);
    inc(y);
    hp := CreatePen(PS_SOLID, 1, ColorToRGB(clBtnHighlight));
    hp := SelectObject(DC, hp);
    DeleteObject(hp);
    MoveToEx(DC, x1,y, NIL);
    lineTo(DC, x2,y);
    hp := SelectObject(DC, oldP);
    DeleteObject(hp);
  end; // embossedCenteredLine

var
  res : Tsize;
  vBarWidth : Integer;
//  fnt : TGPFont;
    vImgElm : TRnQThemedElementDtls;
//  PicName : String;
//      ThemeToken : Integer;
//      ImageLoc   : TPicLocation;
//      ImageIdx   : Integer;
//  cnv : TCanvas;
  oldFont : HFONT;
  ABitmap, HOldBmp : HBITMAP;
  BI : TBitmapInfo;
  FadeColor1, FadeColor2, FadeColor3: Cardinal;
  oldColor : Cardinal;
  oldBr, brF : HBRUSH;
  oldPen, Hp : HPEN;
  oldMode: Integer;
  brLog: LOGBRUSH;
  fontTransp : Byte;
  hls : Thls;
//  Hbr : HBrush;
begin
  fullR := r;
  try
    DC := CreateCompatibleDC(ACanvas.Handle);
//    cnv := TCanvas.Create;
//    cnv.Handle := dc;
//    cnv.ClipRect.Left := 0;
//    cnv.ClipRect.Top := 0;
//    cnv.ClipRect.Right := Right-Left;
//    cnv.ClipRect.Left := 0;

    HOldBmp := 0;
    with fullR do
    if ((Right-Left) >0) and ((Bottom-Top) > 0) then
    begin
            BI.bmiHeader.biSize := SizeOf(TBitmapInfoHeader);
            BI.bmiHeader.biWidth  := Right-Left;
            BI.bmiHeader.biHeight := Bottom-Top;
            BI.bmiHeader.biPlanes := 1;
            BI.bmiHeader.biBitCount := 32;
            BI.bmiHeader.biCompression := BI_RGB;
            ABitmap := CreateDIBitmap(ACanvas.Handle, BI.bmiHeader, 0, NIL, BI, DIB_RGB_COLORS);
//      ABitmap := CreateCompatibleBitmap(ACanvas.Handle, Right-Left, Bottom-Top);
      if (ABitmap = 0) and (Right>Left)and(Bottom>Top) then
       begin
        DeleteDC(DC);
        DC := 0;
        raise EOutOfResources.Create('Out of Resources');
       end;
      HOldBmp := SelectObject(DC, ABitmap);
      SetWindowOrgEx(DC, Left, Top, Nil);
    end
    else
     ABitmap := 0;
  finally

  end;
  vImgElm.pEnabled := item.Enabled;
  vImgElm.Element  := RQteMenu;
  vImgElm.ThemeToken := -1;
//  itemfocused:=cnv.brush.color = clHighlight;
//  itemfocused:=Selected;
  //  cnv.Font.Color := clMenuText;
  s:=item.caption;
  vBarWidth := StrToIntDef(theme.GetString('menu.bar.width'), cBarWidth1);
 try
 // Draw Bar and Clear
  if (not onlysize) then
   begin
    r1 := r;
    if (item.MenuIndex = item.Parent.Count-1) or
       ((item.MenuIndex+1 < item.Parent.Count) and
        (item.Parent.Items[item.MenuIndex+1].Break <> mbNone)) then
    begin
        r1.Bottom := ACanvas.ClipRect.Bottom
    end;
    clBar := theme.GetColor('menu.bar', clMenuBar); //menu.barColor;//clMenuBar;
  {$IFNDEF NOT_USE_GDIPLUS}
    gr := TGPGraphics.Create(dc);
   {$IFDEF USE_SMILE_MENU}
    if ((item.Tag>4000)and(item.Tag<4999)) then
       br := TGPSolidBrush.Create(gpColorFromAlphaColor($FF, clMenu))
     else
   {$ENDIF USE_SMILE_MENU}
      begin
       r1.Left := r1.Left + cBarWidth-1;
       if (clBar = clBlack)or(clBar = clDefault) then
         clBar := clBtnFace; //menu.barColor;//clMenuBar;
       br := TGPLinearGradientBrush.Create(MakeRect(r), theme.GetAColor('menu.fade1', clBar),
            theme.GetAColor('menu.fade2', clMenu), 0);
      end

    gr.FillRectangle(br, MakeRect(r1));
//      pen := TGPPen.Create(theme.GetAColor('menu.selected', clMenuHighlight));
//      gr.DrawRectangle(pen, MakeRect(r1));
//      pen.Free;
    br.Free;
    FreeAndNil(gr);
  {$ELSE NOT_USE_GDIPLUS}
   {$IFDEF USE_SMILE_MENU}
    if ((item.Tag>4000)and(item.Tag<4999)) then
      begin
//       brF := CreateSolidBrush(ColorToRGB(clMenu));
       FillRect(DC, R1, GetSysColorBrush(COLOR_MENU));
//       DeleteObject(brF);
      end
     else
   {$ENDIF USE_SMILE_MENU}
     begin
       r1.Left := r1.Left + vBarWidth-1;
       if (clBar = clBlack)or(clBar = clDefault) then
         clBar := clBtnFace; //menu.barColor;//clMenuBar;
       FillGradient(DC, R1, theme.GetAColor('menu.fade1', clBar), theme.GetAColor('menu.fade2', clMenu), gdHorizontal)
//       br := TGPLinearGradientBrush.Create(MakeRect(r), theme.GetAColor('menu.fade1', clBar),
//            theme.GetAColor('menu.fade2', clMenu), 0);
     end;
  {$ENDIF NOT_USE_GDIPLUS}

   {$IFDEF USE_SMILE_MENU}
    if ((item.Tag<4000)or(item.Tag>4999)) then
   {$ENDIF USE_SMILE_MENU}
     begin
      begin
        rB := r;
        rB.Right := rB.Left + vBarWidth;
//        br := TGPSolidBrush.Create(theme.GetAColor('menu.fade1', clBar));
{        br := TGPSolidBrush.Create(gpColorFromAlphaColor($FF, clBar));
        gr.FillRectangle(br, MakeRect(rB));
        br.Free;
}
//        hp := CreatePen(PS_SOLID, 1, ColorToRGB(clBtnShadow));
//        oldPen := SelectObject(DC, hp);
         brF := CreateSolidBrush(ColorToRGB(clBar));
//         brF := GetSysColorBrush(COLOR_MENU);
         FillRect(DC, rB, brF);
         DeleteObject(brF);
//         brF := 0;
//        Rectangle(DC, r.Left, r.Top, r.Left + cBarWidth, r.Bottom);
//        SelectObject(DC, oldPen);
//        DeleteObject(hp);
      end
     end;
//    inc(r.Left, cBarWidth);
//    inc(r.Right, cBarWidth);
  end;

  result.x:=0;//cBarWidth;
  result.y:=0;
  rB := r;
//  gpR.X := r.Left;
//  gpR.Y := r.Top;
//  gpR.Width := r.Right - r.Left;
//  gpR.Height := r.Bottom - r.Top;
//  ACanvas.Font.Size := ACanvas.Font.Size;
  ACanvas.Font.Assign(Screen.menuFont);
  if Selected then
    begin
      ACanvas.Font.Color := clMenuText;
      theme.ApplyFont('menu.selected', ACanvas.Font);
    end
   else
      theme.ApplyFont('menu', ACanvas.Font);
  if s='-' then
   begin
    res.cy := 3;
    result.y:=res.cy;
    s:=item.hint;
    if s='' then
      begin
        if not onlysize then
          embossedCenteredLine(R.left, R.right);
      end
     else
      begin
//       fnt := TGPFont.Create(ACanvas.Font.Name, 9, FontStyleRegular, UnitPoint);
//       brLog.lbStyle  := BS_SOLID;
//       brLog.lbColor  := ColorToRGB(ACanvas.Font.Color);
//       brLog.lbHatch  := 0;
//       brF := CreateBrushIndirect(brLog);
//       oldBr := SelectObject(DC, brF);
       oldFont := SelectObject(DC, ACanvas.Font.Handle);
       oldColor := SetTextColor(DC, ColorToRGB(ACanvas.Font.Color));
  //         CreateFontIndirect()
//       Hp := CreatePen(PS_SOLID, 1, ColorToRGB(ACanvas.Font.Color));
//       oldPen := SelectObject(dc, Hp);
       DrawText(DC, PChar(s), -1, R, DT_CALCRECT or DT_SINGLELINE or DT_VCENTER);
       GetTextExtentPoint32(DC,pchar(s),length(s), res);
//       TextOut()
//       gr.MeasureString(s, length(s), fnt, gpR, resR);
       result.y:=max(result.y, Trunc(res.cy));
        if not onlysize then
          begin
//            embossedCenteredLine(R.left, (R.right - Trunc(resR.Width)) div 2);
//            embossedCenteredLine( (R.right + Trunc(resR.Width)) div 2 ,R.right);
            r := fullR;
            embossedCenteredLine(R.left, (R.right - Trunc(res.cx) -4) div 2);
            embossedCenteredLine( (R.right + Trunc(res.cx) + 4) div 2 ,R.right);
             oldMode:= SetBKMode(DC, TRANSPARENT);
             drawText(DC, PChar(s), -1, R, DT_SINGLELINE or DT_VCENTER or DT_CENTER);
             SetBKMode(DC, oldMode);
          end;
//       SelectObject(DC, oldBr);
//       DeleteObject(brF);
//       SelectObject(DC, oldPen);
//       DeleteObject(Hp);
//       SetTextColor(DC, oldColor);
       SelectObject(DC, oldFont);
//       fnt.Free;
      end;
//    FreeAndNil(gr);
    exit;
   end;
{  if item.tag=3010 then
   with cnv.font do
    begin
    style:=style+[fsBold];
    Size:=Size+3;
    end;
}
  if onlysize then
    x:=0
//  x:=cBarWidth
   else
    x:=R.Left;

  if Selected and not onlysize then
  begin
    rB := r;
    Inc(rB.Top);
    Dec(rB.Bottom);
//    Inc(rB.Left);
//    Dec(rB.Right);
  {$IFNDEF NOT_USE_GDIPLUS}
   gr := TGPGraphics.Create(dc);
//    br := TGPSolidBrush.Create( theme.GetAColor('menu.selected', clMenuHighlight));
    br := TGPLinearGradientBrush.Create(MakeRect(rb), theme.GetAColor('menu.selected0', aclTransparent),
           gpColorFromAlphaColor($A0, theme.GetColor('menu.selected', clMenuHighlight)),
           90);
    gr.FillRectangle(br, MakeRect(rb));
    br.Free;
//    pen := TGPPen.Create(theme.GetAColor('menu.selected', clMenuHighlight));
    pen := TGPPen.Create(theme.GetAColor('menu.selected', clMenuHighlight));
    gr.DrawRectangle(pen, MakeRect(rb));
    pen.Free;
//      pen := TGPPen.Create(theme.GetAColor('menu.selected', clMenuHighlight));
//      gr.DrawRectangle(pen, MakeRect(r1));
//      pen.Free;
   FreeAndNil(gr);
  {$ELSE NOT_USE_GDIPLUS}

{
   FillGradient(DC, rB,
           $00000000,
           AlphaMask or Cardinal(ColorToRGB(theme.GetColor('menu.selected', clMenuHighlight))),
//           $0000FF00, gdVertical);
           gdVertical);
}

   rB.Bottom := r.Top + (r.Bottom - r.Top) div 2+1;
{
   FillGradient(DC, rB,
           $00000000,
//           MidColor($00000000, AlphaMask or Cardinal(ColorToRGB(theme.GetColor('menu.selected', clMenuHighlight)))),
//           AlphaMask,
//           theme.GetAColor('menu.fade2', clMenu),
//           MidColor(AlphaMask, AlphaMask or Cardinal(ColorToRGB(theme.GetColor('menu.selected', clMenuHighlight)))),
//           MidColor(theme.GetAColor('menu.fade2', clMenu), AlphaMask or Cardinal(ColorToRGB(theme.GetColor('menu.selected', clMenuHighlight))), 0.66),
           MidColor($00000000, AlphaMask or Cardinal(ColorToRGB(theme.GetColor('menu.selected', clMenuHighlight))), 0.66),
           gdVertical);
   rB.Top := rB.Bottom;
   rB.Bottom := r.Bottom;
   FillGradient(DC, rB,
//           MidColor($00000000, AlphaMask or Cardinal(ColorToRGB(theme.GetColor('menu.selected', clMenuHighlight)))),
           AlphaMask or Cardinal(ColorToRGB(theme.GetColor('menu.selected', clMenuHighlight))),
           MidColor($00000000, AlphaMask or Cardinal(ColorToRGB(theme.GetColor('menu.selected', clMenuHighlight))), 0.66),
//           MidColor(theme.GetAColor('menu.fade2', clMenu), AlphaMask or Cardinal(ColorToRGB(theme.GetColor('menu.selected', clMenuHighlight))), 0.66),
//           AlphaMask or Cardinal(ColorToRGB(theme.GetColor('menu.selected', clMenuHighlight))) div 2,
           gdVertical);}
{
   if Win32MajorVersion >=6 then
     FadeColor1 := theme.GetTColor('menu.selected0', $00000000)
//     FadeColor1 := $00000000
    else
     FadeColor1 := theme.GetAColor('menu.selected0', theme.GetAColor('menu.fade2', clMenu));
}
   FadeColor2 := AlphaMask or Cardinal(ColorToRGB(theme.GetColor('menu.selected', clMenuHighlight)));
   FadeColor1 := AlphaMask or MidColor(clWhite, FadeColor2, 0.4);
   if not item.Enabled then
{     if Win32MajorVersion >=6 then
       begin
        FadeColor1 := FadeColor1 and $50FFFFFF;
        FadeColor2 := FadeColor2 and $50FFFFFF;
       end
      else}
       begin
        FadeColor1 := FadeColor1 and $50FFFFFF;
        FadeColor2 := FadeColor2 and $50FFFFFF;
       end
    else
     if Win32MajorVersion >=6 then
       begin
//        FadeColor1 := FadeColor1 and $B0FFFFFF;
//        FadeColor2 := FadeColor2 and $D0FFFFFF;
        FadeColor1 := FadeColor1 and $B0FFFFFF;
        FadeColor2 := FadeColor2 and $B0FFFFFF;
       end;
   FadeColor3 := MidColor(FadeColor1, FadeColor2, 0.66);

   FillGradient(DC, rB,  FadeColor1,  FadeColor3,  gdVertical);//, $90);
   rB.Top := rB.Bottom;
   rB.Bottom := r.Bottom;
   FillGradient(DC, rB,  FadeColor2,  FadeColor3,  gdVertical);//, $90);

{
   brF := CreateSolidBrush(ColorToRGB(theme.GetColor('menu.selected', clMenuHighlight)));
   Hp  := CreatePen(PS_SOLID, 1, ColorToRGB(addLuminosity(theme.GetColor('menu.selected', clMenuHighlight), -0.2)));
   oldPen := SelectObject(DC, Hp);
   oldBr  := SelectObject(DC, brF);
   RoundRect(DC, rB.Left, rB.Top, rB.Right, rB.Bottom, 3, 3);
   SelectObject(DC, oldPen);
   DeleteObject(Hp);
   SelectObject(DC, oldBr);
//   FrameRect(DC, rB, brF);
   DeleteObject(brF);
}
//   if item.Enabled then
    begin
     rB.Top := r.Top;
     brF := CreateSolidBrush(ColorToRGB(theme.GetColor('menu.selected', clMenuHighlight)));
  //   brF := CreateSolidBrush(FadeColor2);
     FrameRect(DC, rB, brF);
     DeleteObject(brF);
    end; 
  {$ENDIF NOT_USE_GDIPLUS}
 end;


  if (Win32MajorVersion >=6) and
     item.Checked and not onlysize and not Selected then
   begin
      rB := r;
      Inc(rB.Top);
      Dec(rB.Bottom);
  //    Inc(rB.Left);
      Dec(rB.Right);
     rB.Bottom := r.Top + (r.Bottom - r.Top) div 2+1;
  {
     if Win32MajorVersion >=6 then
       FadeColor1 := theme.GetTColor('menu.selected0', $00000000)
  //     FadeColor1 := $00000000
      else
       FadeColor1 := theme.GetAColor('menu.selected0', theme.GetAColor('menu.fade2', clMenu));
  }
     FadeColor2 := AlphaMask or Cardinal(ColorToRGB(theme.GetColor('menu.selected', clMenuHighlight)));
     FadeColor1 := AlphaMask or MidColor(clWhite, FadeColor2, 0.4);
//     if Win32MajorVersion >=6 then
      begin
        FadeColor1 := FadeColor1 and $55FFFFFF;
        FadeColor2 := FadeColor2 and $55FFFFFF;
      end;
     FadeColor3 := MidColor(FadeColor1, FadeColor2, 0.66);
     FillGradient(DC, rB,  FadeColor1,  FadeColor3,  gdVertical);
     rB.Top := rB.Bottom;
     rB.Bottom := r.Bottom;
     FillGradient(DC, rB,  FadeColor2,  FadeColor3,  gdVertical);

//     rB.Top := r.Top;
//     brF := CreateSolidBrush(ColorToRGB(theme.GetColor('menu.selected', clMenuHighlight)));
  //   brF := CreateSolidBrush(FadeColor2);
//     FrameRect(DC, rB, brF);
//     DeleteObject(brF);
   end;

  vImgElm.picName := '';
  picSize.cy := 0;
  if not item.Bitmap.empty then
    begin
//     PicName := Str_Error
      picSize.cx := item.Bitmap.Width;
      picSize.cy := item.Bitmap.Height;
      inc(x,2);
      if not onlysize then
       begin
        k:=(r.top+r.bottom-picSize.cy) div 2;
//        BitBlt(DC, x, k, picSize.cx, picSize.cy, item.Bitmap.Canvas.Handle, 0,0,SRCCOPY);
        {$IFNDEF NO_WIN98}
         if  Win32MajorVersion < 5 then
           DrawTransparentBitmap(DC, item.Bitmap.Handle, MakeRect(x, k, picSize.cx, picSize.cy),
             picSize.cx, picSize.cy, ColorToRGB(item.Bitmap.TransparentColor) and not AlphaMask)
          else
       {$ENDIF NO_WIN98}
           TransparentBlt(DC, x, k, picSize.cx, picSize.cy, item.Bitmap.Canvas.Handle,
             0, 0, picSize.cx, picSize.cy, ColorToRGB(item.Bitmap.TransparentColor) and not AlphaMask);
       end;
      inc(x, MAX(picSize.cx+2, vBarWidth-2) );
    end
   else
    begin
      if Assigned(item.Action) then
       begin
         vImgElm.PicName := TAction(item.Action).HelpKeyword;
         if (item is TRQMenuItem) then
          begin
           if TRQMenuItem(item).fImgElm.picName <> vImgElm.PicName then
            begin
             TRQMenuItem(item).fImgElm.picName := vImgElm.PicName;
             TRQMenuItem(item).fImgElm.ThemeToken := -1;
            end;
          end;
       end
      else
       if (item is TRQMenuItem) then
         vImgElm.picName:= TRQMenuItem(item).fImgElm.picName;

      //  if not AnsiStartsText('menu.', PicName) then
      //    PicName := 'menu.' + PicName;
        if vImgElm.PicName<>'' then
         begin
           vImgElm.ThemeToken := -1;
           vImgElm.pEnabled := item.enabled;
           if (item is TRQMenuItem) then
             TRQMenuItem(item).fImgElm.pEnabled := item.enabled;
           if (item is TRQMenuItem) then
//             if ((item.Tag>=4000)and(item.Tag<4999)) then
//               picSize := rqSmiles.GetPicSize(TRQMenuItem(item).fImgElm)
//              else
               picSize := theme.GetPicSize(TRQMenuItem(item).fImgElm)
            else
//             if ((item.Tag>=4000)and(item.Tag<4999)) then
//               picSize := rqSmiles.GetPicSize(vImgElm)
//              else
               picSize := theme.GetPicSize(vImgElm);
          inc(x,2);
          if not onlysize then
           begin
            k:=(r.top+r.bottom-picSize.cy) div 2;
            if (item is TRQMenuItem) then
//              if ((item.Tag>=4000)and(item.Tag<4999)) then
//                rqSmiles.drawPic(DC, Point(x,k), TRQMenuItem(item).fImgElm)
//               else
                theme.drawPic(DC, Point(x,k), TRQMenuItem(item).fImgElm)
             else
//              if ((item.Tag>=4000)and(item.Tag<4999)) then
//                rqSmiles.drawPic(DC, Point(x,k), vImgElm)
//               else
                theme.drawPic(DC, Point(x,k), vImgElm);
           end;
          inc(x, MAX(picSize.cx+2, vBarWidth-2) );
      //    inc(x,2);
         end
        else
          inc(x, vBarWidth);
    end;
  inc(x,2);
  R.left:=x;
//  gpR.X := r.Left;
  rB.Left := r.Left;
//  rB.Top  := trunc(gpR.Y);
//  rB.Right :=
//  resR.Height := 0;
//  resR.Width  := 0;
  res.cx := 0;
  res.cy := 0;

  {$IFDEF USE_SMILE_MENU}
 if (item.Tag<4000)or(item.Tag>4999)or(ShowSmileCaption) then
  {$ENDIF USE_SMILE_MENU}
// Не рисуим там, где смайлы
 begin
{   if not item.enabled then
    begin
    if not selected then
      begin
  //      cnv.Font.Color := clBtnHighlight;
      OffsetRect(R, 1, 1);
      DrawText(dc, pchar(s), -1, R, k);
      OffsetRect(R, -1, -1);
      end;
  //    cnv.font.color:=clBtnShadow;
    end;}
    if not item.enabled then
//      fontTransp := $70
      begin
//        hls := color2hls(ACanvas.Font.Color);
//        hls.s := hls.s -0.5;
//        hls.l := hls.l +
//        ACanvas.Font.Color := hls2color(hls);
        ACanvas.font.color:=clGrayText;
      end
     else
      fontTransp := $FF;
//     ACanvas.font.color:=clGrayText;
//    fnt := TGPFont.Create(ACanvas.Font.Name, ACanvas.Font.Size, FontStyleRegular, UnitPoint);
//     fnt := TGPFont.Create(ACanvas.Font.Name, ACanvas.Font.Size, FontStyleRegular, UnitPixel);
//    gfmt := TGPStringFormat.Create(StringFormatFlagsNoWrap or StringFormatFlagsMeasureTrailingSpaces);
//    gfmt.SetLineAlignment(StringAlignmentCenter);
//    gfmt.SetHotkeyPrefix(HotkeyPrefixShow);
//    gr.MeasureString(s, length(s), fnt,MakePoint(gpR.X, gpR.Y), gfmt, resR);
//     brLog.lbStyle  := BS_HATCHED;
//     brLog.lbColor  := ColorToRGB(ACanvas.Font.Color);
//     brLog.lbHatch  := HS_CROSS;
//     brF := CreateBrushIndirect(brLog);
//     oldBr := SelectObject(DC, brF);
//         CreateFontIndirect()
//     Hp := CreatePen(PS_SOLID, 5, ColorToRGB(ACanvas.Font.Color));
//     oldPen := SelectObject(dc, Hp);
     oldFont := SelectObject(DC, ACanvas.Font.Handle);
     oldColor := SetTextColor(DC, ColorToRGB(ACanvas.Font.Color));
    DrawText(DC, PChar(s), -1, R, DT_CALCRECT or DT_SINGLELINE or DT_VCENTER);
    GetTextExtentPoint32(DC,pchar(s),length(s), res);
     if not onlysize then
       begin
         R.left:=x;
         R.BottomRight := fullR.BottomRight;
         oldMode:= SetBKMode(DC, TRANSPARENT);
         drawText(DC, PChar(s), -1, R, DT_SINGLELINE or DT_VCENTER);
         SetBKMode(DC, oldMode);
//         inc(x, R.right);
//         br := TGPSolidBrush.Create(gpColorFromAlphaColor(fontTransp, ACanvas.Font.Color));
//         gr.DrawString(s, length(s), fnt, gpR, gfmt, br);
//         br.Free;
       end;
//     SelectObject(DC, oldBr);
//     DeleteObject(brF);
//     SelectObject(DC, oldPen);
//     DeleteObject(Hp);
     SelectObject(DC, oldFont);
    inc(x, trunc(res.cx));
//    gfmt.Free;
//    fnt.Free;
//   inc(x, trunc(resR.Width));
 end;


  if (Win32MajorVersion <6) and item.Checked then
   begin
     vImgElm.ThemeToken := -1;
     vImgElm.picName := PIC_CURRENT;
     vImgElm.pEnabled := item.Enabled;
     with theme.GetPicSize(vImgElm) do
      begin
       if not onlysize then
         theme.drawPic(DC, Point(fullR.Right-cx-5, fullR.Top + (fullR.Bottom-fullR.Top - cy)div 2),
           vImgElm);
        inc(x, cx+2);
      end;
   end;
   
  result.x:=x;
//  result.y:= Trunc(resR.Height);
  result.y:= res.cy;
//  if (picSize.cy > 0) then
    k:=picSize.cy+2;
//   else
//    k:=0;
  if result.y<k then result.y:=k;
  if onlysize then
   if item.Count > 0 then
     inc(result.x, 5);

 finally
  if not onlysize then
    BitBlt(ACanvas.Handle, fullR.Left, fullR.Top,
     fullR.Right - fullR.Left, fullR.Bottom - fullR.Top,
     dc, fullR.Left, fullR.Top, SrcCopy);

  SelectObject(DC, HOldBmp);
  DeleteObject(ABitmap);
  DeleteDC(DC);
 end;
end;


{$ifdef MirandaSupport}
procedure TRQMenuItem.OnMenuClick (Sender: TObject);
begin
  if ServiceName <> '' then
    CallService(PChar(ServiceName), 0, 0);
end;
{$endif}

procedure TRQMenuItem.onExitMenu(var Msg: TMessage);
begin
end;

procedure TRQMenuItem.SetImageName(const Value: TPicName);
begin
 FImageName := Value;
 fImgElm.picName := LowerCase(Value);
 fImgElm.Element := RQteMenu;
 fImgElm.ThemeToken := -1;
 fImgElm.picIdx  := -1;
end;


{
initialization
   Popuplist.Free; //free the "default", "old" list
   PopupList:= TPopupListEx.Create; //create the new one
   // The new PopupList will be freed by
   // finalization section of Menus unit.
}

end.

