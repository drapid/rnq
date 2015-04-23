{
This file is part of R&Q.
Under same license
}
unit aboutDlg;
{$I RnQConfig.inc}
{$I NoRTTI.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, 
  {$IFDEF USE_GDIPLUS}
    GDIPAPI,
    GDIPOBJ,
  {$ENDIF USE_GDIPLUS}
  RnQButtons, RQThemes,
  StdCtrls, ExtCtrls, RDGlobal;

type
  TaboutFrm = class(TForm)
    MThanks: TMemo;
    versionLbl: TLabel;
    AbPnl: TPanel;
    forumLbl: TLabel;
    L5: TLabel;
    L3: TLabel;
    RDLbl: TLabel;
    L6: TLabel;
    L2: TLabel;
    L1: TLabel;
    BtnPnl: TPanel;
    CrdBtn: TRnQButton;
    OkBtn: TRnQButton;
    Lbl: TLabel;
    BuiltLbl: TLabel;
    procedure L6Click(Sender: TObject);
    procedure wwwLblClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure lblMouseEnter(Sender: TObject);
    procedure lblMouseLeave(Sender: TObject);
    procedure RDLblClick(Sender: TObject);
//    procedure antonLblClick(Sender: TObject);
    procedure forumLblClick(Sender: TObject);
  { $IFDEF USE_GDIPLUS}
    procedure T1Timer(Sender: TObject);
  { $ENDIF USE_GDIPLUS}
    procedure AboutPBoxPaint(Sender: TObject);
    procedure CrdBtnClick(Sender: TObject);
    procedure OkBtnClick(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
  public
    procedure view;
    procedure CreateParams(var Params: TCreateParams); override;
//  public procedure destroyHandle;
  private
    AboutPBox: TRnQPntBox;
  {$IFDEF USE_GDIPLUS}
    rnqicon : TGPBitmap;
//  {$ELSE NOT USE_GDIPLUS}
    picTok : Integer;
    PicLoc : TPicLocation;
    PicIdx : Integer;
  {$ENDIF USE_GDIPLUS}
    curAngle : Integer;
//    curSize : Single;
    curNapr  : Integer;
    t1 : TTimer;
  end;

var
  aboutFrm: TaboutFrm =  nil;

implementation

uses
  DwmApi, Math, Types, UITypes,
  RQUtil, RnQLangs, RnQSysUtils, RnQBinUtils, RnQGraphics32, RnQPics,
  mainDlg, utilLib, globalLib,
//  aarotate,
//  , shellapi
  themesLib;
//var
//  eggCounter:integer;

{$R *.DFM}

procedure TaboutFrm.CrdBtnClick(Sender: TObject);
begin
  MThanks.Visible := not MThanks.Visible;
  AbPnl.Visible := not MThanks.Visible;
  if AbPnl.Visible then
    CrdBtn.Caption := getTranslation('Credits >')
   else
    CrdBtn.Caption := getTranslation('< About');
end;

procedure TaboutFrm.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  with Params do
  begin
//    Style := Style and (not WS_CAPTION);
//    Style := Style and not WS_OVERLAPPEDWINDOW or WS_BORDER and (not WS_CAPTION);
//    Style := (Style or WS_POPUP) and (not WS_DLGFRAME);
    ExStyle := ExStyle or WS_EX_APPWINDOW
  end;
end;

procedure TaboutFrm.view;
var
  bt : TDateTime;
begin
//eggCounter:=0;
(* {$IFDEF RNQ_FULL}
   versionLbl.caption:=ip2str(RnQversion) +  ' (' + intToStr(RnQBuild) + ')';
 {$ELSE}
   versionLbl.caption:=ip2str(RnQversion) +  ' lite (' + intToStr(RnQBuild) + ')';
 {$ENDIF}
*)
  versionLbl.caption:=getTranslation('Build %d', [RnQBuild]);
{$IFDEF CPUX64}
  versionLbl.caption := versionLbl.caption + ' x64';
{$ENDIF CPUX64}
{$IFDEF UNICODE}
{$ELSE nonUNICODE}
  versionLbl.caption := versionLbl.caption + ' Ansi';
{$ENDIF UNICODE}
  if LiteVersion then
    versionLbl.caption := versionLbl.caption + #13' Lite';
  bt := builtTime;
  BuiltLbl.Caption := 'Built: '+ DateTimeToStr(bt);
  MThanks.Height := AbPnl.Height;
 showForm(self);
end;

procedure TaboutFrm.wwwLblClick(Sender: TObject);
begin openURL(rnqSite) end;

procedure TaboutFrm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
//destroyHandle;
 aboutFrm := nil;
// Im.Picture.free;
  {$IFDEF USE_GDIPLUS}
 rnqicon.Free;
 rnqicon := NIL;
  {$ENDIF USE_GDIPLUS}
 Action := caFree;
//  free;
end;

procedure TaboutFrm.FormCreate(Sender: TObject);
//var
//  formrgn:hrgn;
begin
// destroyHandle
  AboutPBox := TRnQPntBox.Create(self);
  Self.InsertComponent(AboutPBox);
  AboutPBox.Parent  := Self;
  AboutPBox.Top     := 6;
  AboutPBox.Width   := 64;
  AboutPBox.Left    := Self.ClientWidth - 10 - AboutPBox.Width;
  AboutPBox.Height  := 64;
//  AboutPBox.Height  := 85;
  AboutPBox.OnPaint := AboutPBoxPaint;
  AboutPBox.ControlStyle :=AboutPBox.ControlStyle + [ csOpaque ] ;
  { $IFDEF USE_GDIPLUS}
  t1 := TTimer.Create(Self);
  t1.Interval := 40;
  t1.OnTimer := T1Timer;
  t1.Enabled := False;
  { $ENDIF USE_GDIPLUS}
  theme.pic2ico(RQteFormIcon, PIC_RNQ, icon);
  Lbl.Caption := 'R&Q IM';

//  ControlStyle := ControlStyle + [ csOpaque ] ;
//  AboutPBox.
(*
self.brush.style:=bsclear;
{делаем форму круглой}
GetWindowRgn(self.Handle, formRgn);
DeleteObject(formRgn);
formrgn:= CreateroundRectRgn(0,
0,self.width,self.Height,
//self.width,self.width
  5, 5
);
SetWindowRgn(self.Handle, formrgn, TRUE);*)
//  Self.DoubleBuffered := True;
//  AbPnl.DoubleBuffered := True;
//  AbPnl.pa
end;

procedure TaboutFrm.FormKeyPress(Sender: TObject; var Key: Char);
begin
//  if Key in [#0013, #0027] then
  if (Key =#0013) or (Key = #0027) then
   close;
end;

//procedure TaboutFrm.destroyHandle; begin inherited end;

procedure TaboutFrm.FormShow(Sender: TObject);
  {$IFDEF USE_GDIPLUS}
var
 ico : HICON;
  {$ENDIF USE_GDIPLUS}
begin
 {$IFDEF USE_GDIPLUS}
  ico := CopyImage(Application.Icon.Handle, IMAGE_ICON, 48, 48, LR_COPYFROMRESOURCE);
  rnqicon := TGPBitmap.Create(ico);
//  DrawIconEx(PaintBox1.Canvas.Handle, 16, 190, SmallIcon,32, 32, 0, 0, DI_NORMAL);
  DestroyIcon(ico);
 {$ENDIF USE_GDIPLUS}
  t1.Enabled := True;
  curAngle := 0;
//   curSize := 20;
  curNapr := -1;
  if DwmCompositionEnabled then
   BtnPnl.BevelOuter := bvNone;
//  theme.GetIco2(PIC_RNQ, Im.Picture.Icon);
//  assignImgIco(Im, Application.Icon);
//  Im.Picture.Icon := Application.Icon;
//  im.Width := 64;
//  im.Stretch := True;
//  applyTaskButton(self);
end;

procedure TaboutFrm.lblMouseEnter(Sender: TObject);
begin with (sender as Tlabel).font do Style:=Style+[fsUnderline] end;

procedure TaboutFrm.lblMouseLeave(Sender: TObject);
begin with (sender as Tlabel).font do Style:=Style-[fsUnderline] end;

procedure TaboutFrm.OkBtnClick(Sender: TObject);
begin
  Close;
end;

procedure TaboutFrm.AboutPBoxPaint(Sender: TObject);
const
  PiDiv = Pi / 180;
  {$IFDEF USE_GDIPLUS}
var
 gr : TGPGraphics;
  fnt : TGPFont;
  res : Tsize;
  gpR, resR :TGPRectF;
//  gfmt :TGPStringFormat;
//  br  : TGPBrush;
  pen : TGPPen;
// bmp : TGPBitmap;
// ia  : TGPImageAttributes;
// mx  : TGPMatrix;
 x, y : Integer;
  dc  : HDC;
  ABitmap, HOldBmp : HBITMAP;
  fullR : TRect;
//  D : Double;
//  size : Double;
{  rr  : TGPRect;
  i, j : Integer;
  ia : TGPImageAttributes;
    disCM   : TColorMatrix;}
  s : string;  
begin
  x := 32;
  y := 28;
  fullR := AboutPBox.Canvas.ClipRect;
  try
    DC := CreateCompatibleDC(AboutPBox.Canvas.Handle);
    with fullR do
    begin
      ABitmap := CreateCompatibleBitmap(AboutPBox.Canvas.Handle, Right-Left, Bottom-Top);
      if (ABitmap = 0) and (Right-Left + Bottom-Top <> 0) then
        raise EOutOfResources.Create('Out of Resources');
      HOldBmp := SelectObject(DC, ABitmap);
      SetWindowOrgEx(DC, Left, Top, Nil);
    end;
  finally
  end;

  gr :=TGPGraphics.Create(DC);
  gr.Clear(gpColorFromAlphaColor($FF, Self.Brush.Color));
{  s := 'R&Q';
  D := min(AboutPBox.Width, AboutPBox.Height); 
  gpR.X := (fullR.Right + fullR.Left - D) / 2;
  gpR.Y := (fullR.Top + fullR.Bottom - D) / 2;
  gpR.Width  := D;
  gpR.Height := D;
  size := min(curSize, 40);
     br := TGPSolidBrush.Create(aclGreen);
     gr.FillEllipse(br, gpR);
     br.Free;
       fnt := TGPFont.Create(AboutPBox.Canvas.Font.Name, size, FontStyleRegular, UnitPoint);
       gr.MeasureString(s, length(s), fnt, gpR, resR);

            gr.SetClip(gpR);

       gpR.X := fullR.Left-50;
       gpR.Width := fullR.Right - fullR.Left + 100;
//       gpR.X := (fullR.Right + fullR.Left - resR.Width) / 2;
//       gpR.Width := resR.Width;
            br := TGPSolidBrush.Create(gpColorFromAlphaColor($FF, clWhite));
//            gfmt := TGPStringFormat.Create(StringFormatFlagsNoClip or StringFormatFlagsNoWrap);
//            gfmt := TGPStringFormat.Create(StringFormatFlagsNoClip or StringFormatFlagsNoFitBlackBox);
            gfmt := TGPStringFormat.Create(0);
            gfmt.SetLineAlignment(StringAlignmentCenter);
            gfmt.SetAlignment(StringAlignmentCenter);
//            gr.draws
//            gr.MeasureString(s, length(s), fnt, gpR, resR);
            gr.DrawString(s, length(s), fnt, gpR, gfmt, br);
            br.Free;
            gfmt.Free;
//  gr.DrawLine()
  gpR.X := (fullR.Right + fullR.Left - D) / 2;
  gpR.Width  := D;
   pen := TGPPen.Create(aclGray, 2);
   gr.DrawEllipse(pen, gpR);
   pen.Free;

{ Old
}
  gr.SetCompositingQuality(CompositingQualityHighQuality);
  gr.SetInterpolationMode(InterpolationModeHighQuality);
//  bmp := TGPBitmap.Create(Application.Icon.Handle);
//  mx  := TGPMatrix.Create(MakeRect(0, 0, 32, 32), MakePoint(16, 16));
//  mx.Rotate(15);
//  ia := TGPImageAttributes.Create;
//  ia.
//  gr.TranslateTransform(-x - 16, -y-16);
  gr.TranslateTransform(x, y);
  gr.RotateTransform(curAngle, MatrixOrderPrepend);
  gr.DrawImage(rnqicon, -24, -24, 48, 48);
{
  gr.ResetTransform;
  gr.TranslateTransform(x, y);
  gr.RotateTransform(curAngle, MatrixOrderPrepend);
  gr.ScaleTransform(1, -1);
//  gr.RotateTransform(180, MatrixOrderPrepend);
  rr.X := -24; rr.Y := -24; rr.Width := 48; rr.Height := 48;
      for i := 0 to 2 do
        begin
         disCM[0][i] := 0.3;
         disCM[1][i] := 0.59;
         disCM[2][i] := 0.11;
         disCM[3][i] := 0;
         disCM[4][i] := 0.5;
        end;
      for i := 3 to 4 do
       for j := 0 to 4 do
         disCM[j][i] := 0;
      disCM[3][3] := 1;
      for i := 0 to 4 do
       for j := 0 to 4 do
        begin
         disCM[i][j] := 0.5* disCM[i][j];
//         disCMb[i][j] := 0.5* disCM[i][j];
        end;
         ia := TGPImageAttributes.Create;
         ia.SetColorMatrix(disCM);
  gr.DrawImage(rnqicon, rr, 0, 0, 48, 48, UnitPixel, ia);
  gr.TranslateTransform(0, 48);
  ia.Free;                                }
//  gr.TranslateClip(16, 16);
//  gr.SetTransform(mx);
//  gr.DrawImage(bmp, 0, 0, 10, 10);
//  gr.DrawImage(bmp, 0, 20, 16, 16);
//  gr.DrawImage(bmp.GetThumbnailImage(16, 16), 20, 20, 16, 16);
//  gr.DrawImage(bmp, 0, 80, 48, 48);
//  mx.Free;
//  bmp.Free;
  gr.Free;

  BitBlt(AboutPBox.Canvas.Handle, fullR.Left, fullR.Top,
    fullR.Right - fullR.Left, fullR.Bottom - fullR.Top,
    dc, fullR.Left, fullR.Top, SrcCopy);

  SelectObject(DC, HOldBmp);
  DeleteObject(ABitmap);
  DeleteDC(DC);
  {$ELSE NOT USE_GDIPLUS}
const
  sizeM = 48;
  cntr = sizeM div 2;
  addict = 5;
  cntr1 = cntr + addict;
//  Pidiv =
var
  ico : HICON;
//  i : Integer;
//  err : Integer;
{  XForm: TXForm;
  S, C: Single;
  Degrees: Single;}
  bmp : TBitmap;
  bmp2 : TBitmap;
  DC : HDC;
begin
//  ico := 0;
//  AboutPBox.Canvas.FillRect(AboutPBox.Canvas.ClipRect);
//  DC := AboutPBox.Canvas.Handle;
//  bmp := createBitmap(AboutPBox.Canvas);
  bmp:=Tbitmap.create;
  bmp.PixelFormat := pf32bit;
  with AboutPBox.Canvas.ClipRect do
    bmp.SetSize(right-left+1, bottom-top+1);
  bmp.Canvas.Brush := AboutPBox.Canvas.Brush;
  bmp.Canvas.FillRect(bmp.Canvas.ClipRect);
//  DC := bmp.Canvas.Handle;

  bmp2:=Tbitmap.create;
  bmp2.PixelFormat := pf32bit;
  with AboutPBox.Canvas.ClipRect do
    bmp2.SetSize(right-left+1, bottom-top+1);
  bmp2.Canvas.Brush := AboutPBox.Canvas.Brush;
  bmp2.Canvas.FillRect(bmp2.Canvas.ClipRect);
  DC := bmp2.Canvas.Handle;

(*
  SetStretchBltMode(dc, HALFTONE);

  { To use coordinate transformations, you need to switch to advanced graphics
    mode first. Note that this does NOT work on Windows 9x and Windows Me! }
  SetGraphicsMode(DC,GM_ADVANCED);
  { Fill the transformation matrix and set the world transform to this matrix.
    After this, most graphic operations will be affected by the modified
    coordinate space. }
  Degrees := curAngle * Pi / 180;

  { To blit using rotation, the transformation matix should be filled as
    follows:
    |Cosine of angle           Sine of angle  |
    |Negative sine of angle    Cosine of angle| }
  S := Sin(Degrees);
  C := Cos(Degrees);

  XForm.eM11 := c;
  XForm.eM12 := s;
  XForm.eM21 := -s;
  XForm.eM22 := c;
//  XForm.eDx := cntr - c*cntr + s*cntr;
//  XForm.eDy := cntr - c*cntr - s*cntr;
  XForm.eDx := cntr1*(1 - c + s);
  XForm.eDy := cntr1*(1 - c - s);
  SetWorldTransform(DC, XForm);
  { You can use a regular BitBlt now to copy the bitmap to the canvas }
*)
{  ico2 := 0;
  if theme.pic2hIcon(PIC_RNQ, ico2) then
   if ico2 > 0 then
    begin
     ico := CopyImage(ico2, IMAGE_ICON, 48, 48, LR_COPYFROMRESOURCE);
     DeleteObject(ico2);}
    begin
//      hnd := GetModuleHandle(NIL);
//         ico := LoadImage(MainInstance, 'MAINICON', IMAGE_ICON, sizeM, sizeM, LR_LOADFROMFILE);
{         ico := LoadImage(MainInstance, 'MAINICON', IMAGE_ICON, sizeM, sizeM, LR_LOADFROMFILE);
         if ico = 0 then
          err := GetLastError();
         loggaPkt(WL_connected, intToStr(err));
//         loggaPkt(WL_connected, FormatMessage(FORMAT_MESSAGE_FROM_SYSTEM, 0, err, 0, );
//         msgDlg(intToStr(err), mt_Error);
//         ico := LoadImage(Application.Handle, MAKEINTRESOURCE(0), IMAGE_ICON, sizeM, sizeM, LR_LOADFROMFILE);
}
     ico := CopyImage(Application.Icon.Handle, IMAGE_ICON, sizeM, sizeM, LR_COPYFROMRESOURCE);
//     DrawIcon(AboutPBox.Canvas.Handle, 0, 0, ico);
//     DrawIconEx(DC, 0, 0, ico, sizeM, sizeM, 0, 0, DI_NORMAL);
     DrawIconEx(DC, addict, addict, ico, sizeM, sizeM, 0, 0, DI_NORMAL);
//     DrawIconEx(DC, -cntr, -cntr, ico, sizeM, sizeM, 0, 0, DI_NORMAL);
//     PlgBlt() ????????????????????????????????????????
//     DrawIconEx(AboutPBox.Canvas.Handle, 0, 0, ico, 48, 48, 0, 0, DI_NORMAL);
//     DeleteObject(ico);
//   theme.drawPic(AboutPBox.Canvas.Handle, 0, 0, PIC_RNQ, picTok, PicLoc, PicIdx);
     DestroyIcon(ico);
    end;
(*
  { To switch back to normal mode, you need to reset the world transform back
    to the identity matrix first and reset the graphics mode to compatible
    mode }
  ModifyWorldTransform(DC, XForm, MWT_IDENTITY);
  SetGraphicsMode(DC, GM_COMPATIBLE);

//  bmp2 := AARotatedBMP(bmp, curAngle, 0, false);
  BitBlt(AboutPBox.Canvas.Handle, 0, 0, bmp.Width, bmp.Height, dc, 0,0, SrcCopy);
//  BitBlt(AboutPBox.Canvas.Handle, 0, 0, bmp2.Width, bmp2.Height,
//      bmp2.Canvas.Handle, round((bmp2.Width- bmp.Width) / 2), round((bmp2.Height- bmp.Height) / 2), SrcCopy);
*)

  SmoothRotate(bmp2, bmp, cntr1, cntr1, curAngle);
  BitBlt(AboutPBox.Canvas.Handle, 0, 0, bmp.Width, bmp.Height,
         bmp.Canvas.Handle, 0,0, SrcCopy);
  bmp2.Free;

  bmp.Free;
//  bmp2.Free;
  {$ENDIF USE_GDIPLUS}
end;

procedure TaboutFrm.RDLblClick(Sender: TObject);
begin exec('mailto:Rapid@rnq.ru?subject=[RnQ]') end;

  { $IFDEF USE_GDIPLUS}
procedure TaboutFrm.T1Timer(Sender: TObject);
begin
  if curAngle = -30 then
   curNapr := +1
  else
  if curAngle = 30 then
   curNapr := -1;

  if curNapr = 1 then
    inc(curAngle, 1)
   else
    dec(curAngle, 1);

{
  if curSize <= 15 then
   curNapr := +1
  else
  if curSize >= 45 then
   curNapr := -1;

  if curNapr = 1 then
    curSize := curSize + 0.1
   else
    curSize := curSize - 0.1;
}
  if Assigned(AboutPBox) then
    AboutPBox.Repaint;
end;
  { $ENDIF USE_GDIPLUS}

procedure TaboutFrm.forumLblClick(Sender: TObject);
begin openURL(rnqSite) end;

procedure TaboutFrm.L6Click(Sender: TObject);
begin
  exec('mailto:support@RnQ.ru?subject=About RnQ')
end;

end.
