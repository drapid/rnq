{
This file is part of R&Q.
Under same license
}
unit MenuSmiles;
{$I RnQConfig.inc}
{$I NoRTTI.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  ExtCtrls, RDGlobal, RQThemes, RnQGraphics32;

type
  TFSmiles = class(TForm)
    MenuSmilesBox: TPaintBox;
    UpdTmr: TTimer;
//    procedure MenuSmilesBoxPaint(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure UpdTmrTimer(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure MenuSmilesBoxClick(Sender: TObject);
    procedure MenuSmilesBoxMouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: Integer);
    procedure MenuSmilesBoxPaint(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure MenuSmilesBoxMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormHide(Sender: TObject);
  private
    { Private declarations }
//    menu_pic : TBitmap;
//    menu_btAc, menu_btIn : TBitmap;
    fLastMousePos : TPoint;
    FAniParamList: TAniSmileParamsArray;
    FAniDrawCnt : Integer;
    DrawLines, DrawSmiles : Integer;
    procedure RenderAllMenu(cnv : TCanvas);
    procedure TickAniTimer(Sender: TObject);
    procedure AddAniParam( PicIdx, SmlIDX : Integer; Bounds: TGPRect;
              Color: TColor; cnv, cnvSrc : TCanvas; Sel : Boolean = false);
    procedure ClearAniParams;
    procedure DrawSmilesMenu(DC0 : HDC; i : Integer);
    procedure SetMenuSel(i : Integer);
  public
    { Public declarations }
    procedure CreateParams( var Params: TCreateParams );override;
  end;
  procedure ShowSmileMenu(t: tpoint);

const
  Smile_Btn_space = 3;
  Btn_Max_Width   = 45;
  Btn_Max_Height  = 30;
  Smile_Text_Height = 12;

var
  FSmiles: TFSmiles;
  SmileToken : Integer;
  prefBtnWidth, prefBtnHeight : Integer;
  prefSmlAutoSize : Boolean;
  DrawSmileGrid : Boolean;

implementation

uses
   chatDlg, RnQLangs, RnQGlobal,
//   RnQAni,
   globalLib,
   RQUtil,
   math;

{$R *.dfm}

type
  TConfRec = record
   Up, Down, Brd : DWORD;
   Angle,BrdSize : integer;
  end;

var
  menusel, oldsel : integer;
  Btn_Width : Integer;
  Btn_Height : Integer;
  Btn_Height_Full : Integer;

procedure gotochat;
var
  v: hwnd;
//  l: integer;
begin
  v := chatFrm.Handle;
//  RQ_GetWindow(PW_CHAT, v, l, l, l, l);
  SetForegroundWindow(v);
end;

procedure DrawSelBG(dc : HDC; r : TRect);
var
  FadeColor1, FadeColor2: Cardinal;
  bgClr : TColor;
  rB : TRect;
//  oldBr,
  brF : HBRUSH;
begin
//   FadeColor2 := AlphaMask or Cardinal(ColorToRGB(theme.GetColor('menu.selected', clMenuHighlight)));
   bgClr := theme.GetColor('menu.smiles.selected', clMenuHighlight);
   FadeColor2 := AlphaMask or Cardinal(ColorToRGB(bgClr));
   FadeColor1 := AlphaMask or MidColor(clWhite, FadeColor2, 0.4);
{   if Win32MajorVersion >=6 then
    begin
      FadeColor1 := FadeColor1 and $90FFFFFF;
//      FadeColor2 := FadeColor2 and $80FFFFFF;
    end;}
   rB := r;
   rB.Bottom := r.Top + (r.Bottom - r.Top) div 2+1;
   FillGradient(DC, rB,  FadeColor1,  MidColor(FadeColor1, FadeColor2, 0.66),  gdVertical);//, $90);
   rB.Top := rB.Bottom;
   rB.Bottom := r.Bottom;
   FillGradient(DC, rB,  FadeColor2,  MidColor(FadeColor1, FadeColor2, 0.66),  gdVertical);//, $90);

   rB.Top := r.Top;
//   brF := CreateSolidBrush(ColorToRGB(theme.GetColor('menu.selected', clMenuHighlight)));
   brF := CreateSolidBrush(ColorToRGB(bgClr));
//   brF := CreateSolidBrush(FadeColor2);
   FrameRect(DC, rB, brF);
   DeleteObject(brF);
end;

procedure Add2input(const s : String);
begin
  chatFrm.thisChat.input.SelText:= s;
end;

function getmenuselrect(col, row: integer): trect;
begin
  result.Left := col * (Btn_Width + Smile_Btn_space) + Smile_Btn_space;
  result.Right := result.Left + Btn_Width;
  result.Top := row * (Btn_Height_Full + Smile_Btn_space) + Smile_Btn_space;
  result.Bottom := result.Top + Btn_Height;
  if ShowSmileCaption then
    inc(result.Bottom, Smile_Text_Height);
end;

procedure TFSmiles.RenderAllMenu(cnv : TCanvas);
var
//  gr: TGPGraphics;
  i, c, y: integer;
  r: TRect;
  r2: TGPRect;
  SmileObj: TSmlObj;
  brF: HBRUSH;
  s: String;
  menu_pic: TBitmap;
  ts: Boolean;
//  brLog : tagLOGBRUSH;
begin
{  begin
    if menu_pic <> nil then
      menu_pic.free;
  end;
  FillRect(menu_pic.Canvas.Handle, menu_pic.Canvas.ClipRect, CreateSolidBrush(ColorToRGB(clMenu)) );
}
  ts := UpdTmr.Enabled;
  UpdTmr.Enabled := False;
  menu_pic := createBitmap(MenuSmilesBox.Width, MenuSmilesBox.Height);
 if Assigned(menu_pic) then
 try
  menu_pic.Canvas.Brush.Color := cnv.Brush.Color;
  brF := CreateSolidBrush(ColorToRGB(theme.GetColor('menu.smiles.bg', clMenu)));
//  FillRect(menu_pic.Canvas.Handle, Rect(0, 0, MenuSmilesBox.Width, MenuSmilesBox.Height), GetSysColorBrush(COLOR_MENU));
  FillRect(menu_pic.Canvas.Handle, Rect(0, 0, MenuSmilesBox.Width, MenuSmilesBox.Height), brF);
  DeleteObject(brF);

  ClearAniParams;

//        brF := CreateSolidBrush(ColorToRGB(clMenu));
//  FillRect(cnv.Handle, Rect(0, 0, MenuSmilesBox.Width, MenuSmilesBox.Height), GetSysColorBrush(COLOR_MENU));
//   DeleteObject(brF);
{  brLog.lbColor := ColorToRGB(clBlack);
  brLog.lbStyle := BS_HATCHED;
  brLog.lbHatch := HS_CROSS;
  brF := CreateBrushIndirect(brLog);}
//  gr.DrawImage(menu_bg, 0, 0);
 if DrawSmiles > 0 then
 begin
  for i := 0 to DrawSmiles - 1 do
  begin
    c := i div DrawLines;
    y := i mod DrawLines;
    r2 := makeRect(getmenuselrect(c, y));
//    SmileObj := rqSmiles.GetSmileObj(i);
//    if rqSmiles.useAnimated AND SmileObj.Animated then
    SmileObj := theme.GetSmileObj(i);
    if ShowAniSmlPanel and theme.useAnimated AND SmileObj.Animated then
      AddAniParam(SmileObj.AniIdx, i, r2, clMenu, cnv, NIL);
    DrawSmilesMenu(menu_pic.Canvas.Handle, i);
{    if ShowSmileCaption then
     begin
       r.Top := r.Bottom;
       inc(r.Bottom, Smile_Text_Height);
       s := SmileObj.SmlStr.Strings[0];
//       cnv.TextRect(r, r.Left, r.Top, SmileObj.SmlStr.Strings[0]);
       menu_pic.Canvas.TextRect(r, s, [tfBottom, tfCenter, tfLeft, tfEditControl]);
     end;}
  end;
  if DrawSmileGrid then
  begin
    menu_pic.Canvas.Pen.Color := clDkGray;
    menu_pic.Canvas.Pen.Style := psDot;
    for I := 1 to DrawLines - 1 do
     begin
      MoveToEx(menu_pic.Canvas.Handle, 0, i * (Btn_Height_Full+Smile_Btn_space) + 1, NIL);
      LineTo(menu_pic.Canvas.Handle, MenuSmilesBox.Width, i * (Btn_Height_Full+Smile_Btn_space) + 1)
     end;
    y := DrawSmiles mod DrawLines;
    if y > 0 then
      c := (DrawSmiles div DrawLines) + 1
     else
      c := (DrawSmiles div DrawLines);
    for I := 1 to c - 1 do
     begin
      MoveToEx(menu_pic.Canvas.Handle, i * (Btn_Width+Smile_Btn_space) + 1, 0, NIL);
      LineTo(menu_pic.Canvas.Handle, i * (Btn_Width+Smile_Btn_space) + 1, MenuSmilesBox.Height)
     end;
  end;
 end
 else
  begin
    r := Rect(0, Smile_Btn_space, MenuSmilesBox.Width, MenuSmilesBox.Height);
//    DrawSelBG(cnv.Handle, r);
    menu_pic.Canvas.Font.Size := 7;
    s := getTranslation('Haven''t smiles to show');
//       cnv.TextRect(r, r.Left, r.Top, SmileObj.SmlStr.Strings[0]);
    menu_pic.Canvas.TextRect(r, s, [tfVerticalCenter, tfCenter, tfEditControl]);
  end;
//    FrameRect(cnv.Handle, r, brF);
//  DeleteObject(brF);
//  r.Left := 0;
//  r.Top
//    brLog.lbColor := ColorToRGB(clBlack);
//    brLog.lbStyle := BS_HATCHED;
//    brLog.lbHatch := HS_CROSS;
//    brF := CreateBrushIndirect(brLog);
  brF := CreateSolidBrush(ColorToRGB(clBlack));
  FrameRect(menu_pic.Canvas.Handle, Rect(0, 0, MenuSmilesBox.Width, MenuSmilesBox.Height), brF);
  DeleteObject(brF);
  BitBlt(cnv.Handle, 0, 0, MenuSmilesBox.Width, MenuSmilesBox.Height,
         menu_pic.Canvas.Handle, 0,0, SRCCOPY);
 finally
  menu_pic.Free;
 end;
  UpdTmr.Enabled := ts;
end;


procedure TFSmiles.CreateParams( var Params: TCreateParams );
begin
  inherited CreateParams( Params );
  with Params do
  begin
//    Style := Style or ws_Overlapped;
    style :=  Style or WS_OVERLAPPED;
//ExStyle := WS_EX_OVERLAPPEDWINDOW or WS_EX_NOPARENTNOTIFY;

//    WndParent := fprefs.Handle;
    WndParent := chatFrm.Handle;
  end;
//  ShowWindow(Application.Handle,SW_HIDE)
end;

procedure TFSmiles.FormShow(Sender: TObject);
var
//tt : integer;
//  dl1,
  dc1 : Integer;
begin
//if themechanged then ParseSmile;
//for tt := 0 to smiles.count-1 do
// smiles.pics[tt].first := true;
//  with RQSmiles do
  MenuSmilesBox.Font.Size := 7;
  with theme do
  begin
   if not TryStrToInt(GetString('smile.menu.count'), DrawSmiles) then
     DrawSmiles := SmilesCount
    else
     if (DrawSmiles > SmilesCount) or (DrawSmiles = 0) then
      DrawSmiles := SmilesCount;
   if not TryStrToInt(GetString('smile.menu.cnt'), DrawLines) then
     begin
//    if not ShowSmileCaption then
      DrawLines:=Round(sqrt(DrawSmiles)+1);       //mn
//      dl1 := DrawLines;
      dc1 := DrawSmiles div DrawLines;
      if dc1 > 1 then
       while (DrawLines > 1)and ((DrawSmiles div DrawLines) = dc1) do
        dec(DrawLines);
//     else
//      DrawLines := max(Round(sqrt(DrawSmiles*2)+1), 10);
     end;
  end;
 SetMenuSel(-1);
 UpdTmr.Enabled := True;
 fLastMousePos := Point(-1, -1);
end;


procedure TFSmiles.UpdTmrTimer(Sender: TObject);
begin
 if GetForegroundWindow<>self.Handle then
  begin
    self.Hide;
    UpdTmr.Enabled := False;
  end;
 TickAniTimer(NIL);
end;

procedure TFSmiles.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  row,col : Integer;
//  DrawLines, SmileCount: integer;
//  showCnt : Integer;
begin
//  smilecount :=  RQSmiles.SmilesCount;
//drawlines := fprefs.LINES.Position;
  row := menusel mod DrawLines;
  col := menusel div DrawLines;
  case key of
    VK_ESCAPE :
      begin
        self.Hide;
        gotochat;
      end;
    VK_UP :
      begin
        case row of
         0  : row := DrawLines-1;
         -1 : row := DrawLines-1;
        else
         dec(row)
        end;
        if (col*DrawLines + row)> DrawSmiles-1 then row := (DrawSmiles mod Drawlines)-1;
      end;
    VK_DOWN :
      begin
       if (row = DrawLines-1)or(row = -1) then row := 0 else inc(row);
       if (col*DrawLines + row)>DrawSmiles-1 then row := 0;
      end;
    VK_RIGHT :
     begin
      if row = -1 then row := 0;
      if col = ceil(DrawSmiles/DrawLines)-1 then col := 0 else inc(col);
      if (col*DrawLines + row)>DrawSmiles-1 then col := 0;
     end;
    VK_LEFT :
     begin
      if row = -1 then row := 0;
      if col = 0 then col := ceil(DrawSmiles/DrawLines)-1 else dec(col);
      if (col*DrawLines + row)>DrawSmiles-1 then dec(col);
     end;
    VK_RETURN,VK_SPACE :
     begin
      if menusel>-1 then
      begin
       Add2input(theme.GetSmileName(menusel));
       self.Hide;
       gotochat;
      end;
     end;
  end;
//menusel := menusel + 1;
  SetMenuSel(col*DrawLines + row);
end;

procedure TFSmiles.MenuSmilesBoxClick(Sender: TObject);
begin
  if menusel>-1 then
  begin
   Add2input(theme.GetSmileName(menusel));
   self.Hide;
  end;
  gotochat;
end;

procedure TFSmiles.MenuSmilesBoxMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var
  i,col,row:integer;
  p : tpoint;
//  menup : boolean;
begin
//  menup := ((sender as tpaintbox).Name = 'MenuSmilesBox');
  GetCursorPos(p);
//  if menup then
    p := ScreenToClient(p);
  if (fLastMousePos.X = p.X)and(fLastMousePos.y = p.y) then
    Exit;
///   else
//    p := FPrefs.MenuPaint.ScreenToClient(p);
  fLastMousePos := p;
  for i :=0 to DrawSmiles-1 do
  begin
   col := i div DrawLines;
   row := i mod DrawLines;
     begin
      if PtInRect(getmenuselrect(col,row),p) and self.Visible then
       menusel := i;
     end
  end;
  if menusel <> oldsel then
   SetMenuSel(menusel);
end;

procedure TFSmiles.DrawSmilesMenu(DC0 : HDC; i : Integer);
var
// i,
 col, row : integer;
// rend : string;
 r, r2 : TRect;
// menup : boolean;
//  oldF : HFONT;
  SmileObj: TSmlObj;
  Ani : TRnQAni;
  StatImName : TPicName;
  b2 : TBitmap;
  brF : HBRUSH;
  sz : TSize;
  h : Integer; 
  DC : HDC;
  DrawOnBMP : Boolean;
//  bgClr : Cardinal;
//  bgClr : TColor;
begin
//  MenuSmilesBox.Canvas.Draw(0, 0, menu_pic);
  if (i >=0)and(i < DrawSmiles) then
   begin
    col := i div DrawLines;
    row := i mod DrawLines;
    r := getmenuselrect(col,row);

    SmileObj := theme.GetSmileObj(i);
    if ShowAniSmlPanel and SmileObj.Animated then
      begin
       Ani := theme.GetAniPic(SmileObj.AniIdx);
       sz.cx := Ani.Width;
       sz.cy := Ani.Height;
//       Ani.Animate := True;
      end
     else
      begin
        StatImName := SmileObj.SmlStr.Strings[0];
        sz := theme.GetPicSize(RQteDefault, StatImName);
      end;
    h := Btn_Height;
//    if ShowSmileCaption then
//      inc(h, Smile_Text_Height);

    DrawOnBMP := (sz.cx > Btn_Width)or(sz.cy > Btn_Height);
    if DrawOnBMP then
      begin
       b2 := createBitmap( Btn_Width, h);
       DC := b2.Canvas.Handle;
       r2 := Rect(0, 0, Btn_Width, h);
      end
     else
      begin
       b2 := NIL;
       DC := DC0;
       r2 := r;
      end;
    if i = menusel then
       DrawSelBG(DC, r2)
     else
      begin
//        brF := CreateSolidBrush(ColorToRGB(clMenu))
//        theme.GetAColor('menu.fade2', clMenu)
//        FillRect(MenuSmilesBox.Canvas.Handle, r,  );
//        FillRect(DC, r2, GetSysColorBrush(COLOR_MENU));
//        brF := CreateSolidBrush(ColorToRGB(clMenu));
//        bgClr := theme.GetColor('menu.smiles.bg', clMenu);
        brF := CreateSolidBrush(ColorToRGB(theme.GetColor('menu.smiles.bg', clMenu)));
        FillRect(DC, r2, brF);
        DeleteObject(brF);
      end;
    if ShowSmileCaption then
      dec(r2.Bottom, Smile_Text_Height);

    if ShowAniSmlPanel and SmileObj.Animated then
       Ani.Draw(DC, r2.Left + (Btn_Width-sz.cx)div 2, r2.Top+(Btn_Height-sz.cy) div 2)
     else
       theme.drawPic(DC, r2.Left + (Btn_Width-sz.cx)div 2,
                         r2.Top+(Btn_Height-sz.cy) div 2,
                     StatImName);
    if ShowSmileCaption then
     begin
       SelectObject(dc0, MenuSmilesBox.Font.Handle);
       SetBKMode(DC0, TRANSPARENT);
       r2 := r;
       r2.Top := r2.Bottom - Smile_Text_Height;
        if i = menusel then
            DrawSelBG(DC0, r2)
         else
          begin
//            FillRect(DC0, r2, GetSysColorBrush(COLOR_MENU));
            brF := CreateSolidBrush(ColorToRGB(theme.GetColor('menu.smiles.bg', clMenu)));
            FillRect(DC0, r2, brF);
            DeleteObject(brF);
          end;
//       inc(r2.Bottom, Smile_Text_Height);
//       inc(r.Bottom, Smile_Text_Height);
//       s := SmileObj.SmlStr.Strings[0];
//       cnv.TextRect(r, r.Left, r.Top, SmileObj.SmlStr.Strings[0]);
       DrawText(DC0, PChar(SmileObj.SmlStr.Strings[0]),
                      Length(SmileObj.SmlStr.Strings[0]), r2,
                      DT_BOTTOM or DT_CENTER or DT_LEFT or DT_EDITCONTROL);
     end;
//    animateimage(i);
//    rqSmiles.
//    renderimage(g,smiles.pics[i].pic,getmenuselrect(c,r),false);
    if DrawOnBMP then
     begin
       BitBlt(DC0, r.Left, r.Top,
               Btn_Width, h, DC, 0, 0, SRCCOPY);
       b2.Free;
     end;
   end;
end;

procedure TFSmiles.SetMenuSel(i : Integer);
begin
  Menusel := i;
  if menusel <> oldsel then
   begin
     DrawSmilesMenu(MenuSmilesBox.Canvas.Handle, oldsel);
     DrawSmilesMenu(MenuSmilesBox.Canvas.Handle, menusel);
     oldsel := menusel;
     if (menusel>=0)and(menusel < theme.SmilesCount) then
       MenuSmilesBox.Hint := theme.GetSmileObj(menusel).SmlStr.Strings[0]
      else
       MenuSmilesBox.Hint := '';
   end;
end;

procedure TFSmiles.MenuSmilesBoxPaint(Sender: TObject);
//var
//g: TGPGraphics;
//sb : TGPSolidBrush;
//gpnt : TGPPointf;
//fnt : TGPFont;
// i : integer;
// col, row : integer;
// rend : string;
// r : TRect;
// menup : boolean;
//  SmileObj: TSmlObj;
begin
//menup := ((sender as tpaintbox).Name = 'MenuSmilesBox');
  begin
//   if menusel <> oldsel then
   RenderAllMenu(MenuSmilesBox.Canvas);
//   g := TGPGraphics.Create((sender as TPaintBox).Canvas.Handle);
//   TPaintBox(Sender).Canvas.Draw(0, 0, menu_pic);
  end;
//  for i := 0 to DrawSmiles-1 do
//   DrawSmilesMenu(i);
  oldsel := menusel
end;


procedure TFSmiles.TickAniTimer(Sender: TObject);
var
  i: Integer;
//  bmp, b1: TRnQBitmap;
  b2 : TBitmap;
//  testSmile: TGifImage;
  paramSmile: TAniPicParams;
//  gr, grb : TGPGraphics;
//  br : TGPBrush;
  brF : HBrush;
begin
//  if not UseAnime then Exit;

  theme.checkAnimationTime;
//  tmp_sml := NIL;
//  for i := Low(items) to High(items) do
//   if items[i].
  if Length(FAniParamList) > 0 then
  begin
//    b2 := createBitmap( paramSmile.Bounds.Right-paramSmile.Bounds.Left,
//            paramSmile.Bounds.Bottom-paramSmile.Bounds.Top);
    b2 := createBitmap( Btn_Width, Btn_Height);
    for i:= 0 to Length(FAniParamList)-1 do
   //for i:= Length(smlList)-1 to 0 do
    begin
      if (FAniDrawCnt = 0)or not theme.useAnimated then
        Exit;
{      if (paramSmile.Bounds.Left = 0) and (paramSmile.Bounds.Top = 0)
      //наложение на верхние стрелки
        then Continue;
}
{      //наложение на нижние стрелки
      if hasDownArrow then
        if paramSmile.Bounds.Bottom > (Height - hDownArrow)
          then Continue;
 }
//      if (i > Low(FAniParamList)) and (i < High(FAniParamList)) then
      paramSmile:= FAniParamList[i];
//      if paramSmile <> nil then
//      if paramSmile.ID = -1 then Continue;
     if Assigned(paramSmile.Canvas) then
      if paramSmile.idx >= 0 then
      begin
        with theme.GetAniPic(paramSmile.Idx) do
        begin
           begin
             if paramSmile.smileIDX = menusel then
               begin
                 DrawSelBG(b2.Canvas.Handle, Rect(0,0,b2.Width, b2.Height));
               end
              else
               begin
//                 b2.Canvas.Brush.Color := paramSmile.color;
//                 b2.Canvas.FillRect(b2.Canvas.ClipRect);
                brF := CreateSolidBrush(ColorToRGB(theme.GetColor('menu.smiles.bg', clMenu)));
                FillRect(b2.Canvas.Handle, b2.Canvas.ClipRect, brF);
                DeleteObject(brF);
               end;
           end;
//           Draw(b2.Canvas.Handle, 0, 0);
            Draw(b2.Canvas.Handle, (Btn_Width-Width)div 2,
                 (Btn_Height- Height) div 2)
        end;

          if Assigned(paramSmile.Canvas)
//           and (paramSmile.Canvas.HandleAllocated )
          then
           BitBlt(paramSmile.Canvas.Handle, paramSmile.Bounds.X, paramSmile.Bounds.Y,
            b2.Width, b2.Height, b2.Canvas.Handle, 0, 0, SRCCOPY);
      end;
    end;
    b2.Free;
  end;
end;

procedure TFSmiles.FormCreate(Sender: TObject);
begin
  oldsel := -1;
  menusel := -1;
//  menu_btAc := createBitmap(Btn_Width, Btn_Height);
//  menu_btIn := createBitmap(Btn_Width, Btn_Height);
end;

procedure TFSmiles.FormHide(Sender: TObject);
begin
  ClearAniParams;
end;

procedure TFSmiles.MenuSmilesBoxMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
if (Button<>mbRight) or (menusel=0) then exit;
{if smiles.pics[menusel].SmileStop<>-1 then
begin
 smiles.pics[menusel].SmileStop:= -1;
 unblocksmile(smiles.pics[menusel].codes[0]);
end else
begin
smiles.pics[menusel].SmileStop := smiles.pics[menusel].activeframe;
blocksmile(smiles.pics[menusel].codes[0],smiles.pics[menusel].SmileStop);
end;}
end;

procedure TFSmiles.AddAniParam( PicIdx, SmlIDX : Integer; Bounds: TGPRect;
              Color: TColor; cnv, cnvSrc : TCanvas; Sel : Boolean = false);
begin
  Inc(FAniDrawCnt);
  SetLength(FAniParamList,FAniDrawCnt);
  FAniParamList[FAniDrawCnt-1].idx := PicIdx;
  FAniParamList[FAniDrawCnt-1].SmileIDX := SmlIdx;
  FAniParamList[FAniDrawCnt-1].Bounds := Bounds;
  FAniParamList[FAniDrawCnt-1].Color := Color;
  FAniParamList[FAniDrawCnt-1].canvas := cnv;
  FAniParamList[FAniDrawCnt-1].selected := sel;
//  rqSmiles.GetAniPic(PicIdx).Animate := True;

{  if Anipicbg then
   begin
     FAniParamList[FAniDrawCnt-1].bg := TRnQBitmap.Create;
     with FAniParamList[FAniDrawCnt-1].bg do
     begin
       Height := Bounds.Bottom - Bounds.Top;
       Width  := Bounds.Right - Bounds.Left;
       BitBlt(Canvas.Handle, 0, 0, Width, Height, cnvSrc.Handle,
              Bounds.Left, Bounds.Top, SRCCOPY)
     end;
   end
  else
    FAniParamList[FAniDrawCnt-1].bg := NIL;}
//  if not FAniTimer.Enabled then
//    FAniTimer.Enabled := true;
end;

procedure TFSmiles.ClearAniParams;
//var
// i : Integer;
begin
  FAniDrawCnt:= 0;
  SetLength(FAniParamList,0);
{  for i := 1 to FAniSmls.Count-1 do
  begin
    GetAniPic(i).Animate := False;
  end;}
//  if Assigned(FAniTimer) then
//    FAniTimer.Enabled := false;
end;

procedure ShowSmileMenu(t: tpoint);
var
  ar: array[1..4] of TRect;
  scr, intr, a: Trect;
  i, p1, p2: integer;
begin
  fsmiles.FormShow(nil);

 if theme.SmilesCount > 0 then
 begin
  if prefSmlAutoSize then
   begin
    if SmileToken <> theme.token then
    begin
     SmileToken := theme.token;
     Btn_Width  := 25;
     Btn_Height := 20;
     for I := 0 to FSmiles.DrawSmiles - 1 do
     with theme.GetPicSize(RQteDefault, theme.GetSmileObj(i).SmlStr.Strings[0]) do
     begin
      Btn_Width  := min(Btn_Max_Width,  max(cx, Btn_Width ));
      Btn_Height := min(Btn_Max_Height, max(cy, Btn_Height));
      if (Btn_Height = Btn_Max_Height)
         and (Btn_Width = Btn_Max_Width) then
        Break;
     end;
     inc(Btn_Width, 2);
     inc(Btn_Height, 2);
    end;
   end
  else
   begin
     Btn_Width  := prefBtnWidth;
     Btn_Height := prefBtnHeight;
   end;
  Btn_Height_Full := Btn_Height;
  if ShowSmileCaption then
    inc(Btn_Height_Full, Smile_Text_Height);
  fsmiles.ClientHeight := (Btn_Height_Full + Smile_Btn_space) * FSmiles.DrawLines + Smile_Btn_space;
  fsmiles.ClientWidth := (MenuSmiles.Btn_Width + Smile_Btn_space) * (ceil(FSmiles.DrawSmiles /
      FSmiles.DrawLines)) + Smile_Btn_space;
 end
 else
  begin
    fsmiles.ClientHeight := Smile_Text_Height + Smile_Btn_space shl 1;
    fsmiles.ClientWidth := 200;
  end;

//    r := Screen.MonitorFromWindow(self.Handle).WorkareaRect;
//  scr := Rect(0, 0, Screen.Width, Screen.Height);
  scr := Screen.MonitorFromPoint(t).WorkareaRect;
  ar[1] := Rect(t.X, t.Y - fsmiles.Height, t.X + fsmiles.Width, t.Y);
  ar[2] := Rect(t.X - fsmiles.Width, t.Y - fsmiles.Height, t.X, t.Y);
  ar[3] := Rect(t.X, t.Y, t.X + fsmiles.Width, t.Y + fsmiles.Height);
  ar[4] := Rect(t.X - fsmiles.Width, t.Y, t.X, t.Y + fsmiles.Height);
  a := Rect(0, 0, 0, 0);
  for i := 1 to 4 do
  begin
    IntersectRect(intr, ar[i], scr);
    p1 := (intr.Right - intr.Left) * (intr.Bottom - intr.Top);
    p2 := (a.Right - a.Left) * (a.Bottom - a.Top);
    if p1 > p2 then
    begin
      a := intr;
      fsmiles.Top := ar[i].Top;
      fsmiles.Left := ar[i].Left;
    end;
  end;
  FSmiles.Show;
end;

end.
