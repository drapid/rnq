{
  This file is part of R&Q.
  Under same license
}
unit ViewPicDimmedDlg;
{$I RnQConfig.inc}
{$I NoRTTI.inc}

interface

uses
  Windows, SysUtils, Graphics, Classes, ExtCtrls,
  Forms, StdCtrls, Controls, Menus,
  ComCtrls, Messages, RnQGraphics32, AnsiClasses;

const
  WM_FADEOUT = WM_USER + 1;

type

  TOnTimerProc = reference to procedure;
  TOneShotTimer = class
    ID: UINT_PTR;
    Proc: TOnTimerProc;
  end;

  TFormEx = class(TForm)
  private
    AnimTimer: TTimer;
    AniTimer: TTimer;
    AlphaValue: Integer;
    Dimmed: Boolean;
    LastImage: Integer;
    ShownImage: Integer;
    images:   Array of TRnQBitmap;
    procedure onAnimTimer(Sender: TObject);
    procedure onAniTimer(Sender: TObject);
    procedure OnCloseImg(Sender: TObject; var Action: TCloseAction);
    procedure OnKeyDownImg(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure OnMouseDownImg(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure UpdateShownImage();
    procedure ShowHideImages();
    procedure PaintPic(Sender: TObject);
    procedure UpdateFormSize();
    procedure FadeOutMsg(var Msg: TMessage); message WM_FADEOUT;
    procedure FadeOut;
    procedure WMAppCommand(var msg: TMessage); message WM_APPCOMMAND;
  public
    otherForm: HWND;
    procedure ShowWithFade();
    procedure startTimer();
    procedure stopTimer();
    procedure updateWindow();
    procedure CreateParams(var Params: TCreateParams); override;
    constructor CreateNew(AOwner: TComponent; DimmedParam: Boolean = False);
  end;
{
  TImageEx = class(TImage)
  public
    ImageStream: TMemoryStream;
    destructor Destroy; override;
    constructor Create(AOwner: TComponent); override;
    procedure OnMouseDownImg(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  end;
}
function viewImageDimmed(const evimage: RawByteString; evoffset: Integer): Tform;
procedure parseMsgImages(const imgStr: RawByteString; var imgList: TAnsiStringList);

procedure SetTimeout(AProc: TOnTimerProc; ATimeout: Cardinal);

implementation
uses
  Types, Generics.Collections,
  strutils, Themes,
  RnQNet, RDGlobal, RDUtils, Base64,
  chatDlg, globalLib, RnQProtocol,
//  roasterLib,
//  events, ICQConsts,
  dateutils, ActiveX;

var
  TimerList: TDictionary<UINT_PTR, TOnTimerProc>;

(*
procedure TImageEx.OnMouseDownImg(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  PostMessage((Parent as TFormEx).otherForm, WM_FADEOUT, 0, 0);
  (Parent as TFormEx).FadeOut;
end;

constructor TImageEx.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  OnMouseDown := OnMouseDownImg;
end;

destructor TImageEx.Destroy;
begin
  if Assigned(ImageStream) then
    ImageStream.Free;
  inherited;
end;

function loadImageEx(var img: TImageEx; var RnQPicStream: TMemoryStream; fitScreen: Boolean = False): String;
var
  ff: TPAFormat;
  bp : TRnQBitmap;
{  png: TPNGImage;
  winimg: TWICImage;
  bmp: TBitmap;
  jpg: TJPEGImage;
  gif: TGIFImage;
  pic: IPicture;}
  a, b: integer;
  h, w: integer;
  r, bRect: TRect;
begin
  img.ImageStream := TMemoryStream.Create;
  img.ImageStream.LoadFromStream(RnQPicStream);

  if Assigned(chatFrm) then
    bRect := Screen.MonitorFromWindow(chatFrm.Handle).BoundsRect
  else
    bRect := Screen.Monitors[0].BoundsRect;

  ff := DetectFileFormatStream(RnQPicStream);
  RnQPicStream.Seek(0, soBeginning);
  loadPic(TStream(RnQPicStream), bp);

  case ff of
    PA_FORMAT_BMP:
      try
{        if fitScreen then
        begin
          bmp := TBitmap.Create;
          bmp.LoadFromStream(RnQPicStream);
          ResampleFullscreen(bmp, bRect);
          img.Picture.Bitmap.Assign(bmp);
          bmp.Free;
        end else
          img.Picture.Bitmap.LoadFromStream(RnQPicStream);
}
        Result := 'BMP';
        img.Tag := 1;
      except
      end;
    PA_FORMAT_JPEG:
      try
{        bmp := TBitmap.Create;
        bmp.PixelFormat := pf24bit;

        if JPEGTurbo then
        begin
          jpg := TJPEGImage.Create;
          jpg.LoadFromStream(RnQPicStream);
          bmp.Assign(jpg);
          jpg.Free;
        end
          else
        begin
          LoadPictureStream(RnQPicStream, pic);
          if pic <> nil then
          begin
            pic.get_Width(a);
            pic.get_Height(b);

            w := MulDiv(a, GetDeviceCaps(bmp.canvas.Handle, LOGPIXELSX), 2540);
            h := MulDiv(b, GetDeviceCaps(bmp.canvas.Handle, LOGPIXELSY), 2540);
            r.Left := 0;
            r.Top := 0;
            r.Right := w;
            r.Bottom := h;
            bmp.SetSize(w, h);
            pic.Render(bmp.canvas.Handle, 0, 0, w, h, 0, b, a, -b, r);
            pic := NIL;
          end;
        end;

        if Assigned(bmp) then
        begin
          if fitScreen then
            ResampleFullscreen(bmp, bRect);
          img.Picture.Bitmap.Assign(bmp);
        end;

        bmp.Free;
}
        Result := 'JPEG';
        img.Tag := 2;
      except
      end;
    PA_FORMAT_PNG:
      try
{        png := TPNGImage.Create;
        png.LoadFromStream(RnQPicStream);

        if fitScreen and not png.Empty then
        begin
          if png.Header.ColorType = COLOR_PALETTE then
            ConvertToRGBA(png);

          bmp := TBitmap.Create;
          bmp.PixelFormat := pf32bit;
          bmp.Assign(png);
          ResampleFullscreen(bmp, bRect);
          img.Picture.Bitmap.Assign(bmp);
          bmp.Free;
        end else
          img.Picture.Assign(png);
        png.Free;
}
        Result := 'PNG';
        img.Tag := 4;
      except
      end;
    PA_FORMAT_TIF:
      try
{        winimg := TWICImage.Create;
        winimg.LoadFromStream(RnQPicStream);

        if fitScreen and not winimg.Empty then
        begin
          bmp := TBitmap.Create;
          bmp.PixelFormat := pf24bit;
          bmp.Assign(winimg);
          ResampleFullscreen(bmp, bRect);
          img.Picture.Bitmap.Assign(bmp);
          bmp.Free;
        end else
          img.Picture.Assign(winimg);
        winimg.Free;
}
        Result := 'TIFF';
        img.Tag := 6;
      except
      end;
    PA_FORMAT_WEBP:
      try
{        winimg := TWICImage.Create;
        winimg.LoadFromStream(RnQPicStream);

        if fitScreen and not winimg.Empty then
        begin
          bmp := TBitmap.Create;
          bmp.PixelFormat := pf32bit;
          bmp.Assign(winimg);
          ResampleFullscreen(bmp, bRect);
          img.Picture.Bitmap.Assign(bmp);
          bmp.Free;
        end else
          img.Picture.Assign(winimg);
        winimg.Free;
}
        Result := 'WEBP';
        img.Tag := 7;
      except
      end;
    // No resize, GIF - animation, ICO - already small :)
    PA_FORMAT_GIF:
      try
{        gif := TGIFImage.Create;
        gif.LoadFromStream(RnQPicStream);
        img.Picture.Assign(gif);
        (img.Picture.Graphic as TGIFImage).Animate := True;
        img.Transparent := True;
        gif.Free;
        }
        Result := 'GIF';
        img.Tag := 3;
      except
      end;
    PA_FORMAT_ICO:
      try
//        img.Picture.Icon.LoadFromStream(RnQPicStream);
//        img.Transparent := True;
        Result := 'ICO';
        img.Tag := 5;
      except
      end;
    PA_FORMAT_UNK:
      try
        Result := '';
        img.Tag := 0;
      except
      end;
  end;
end;
*)

procedure parseMsgImages(const imgStr: RawByteString; var imgList: TAnsiStringList);
var
  pos1, pos2: integer;
  image: RawByteString;
begin
  if not Assigned(imgList) then
    exit;

  image := imgStr;
  repeat
    pos1 := PosEx(RnQImageTag, image);
    if (pos1 > 0) then
    begin
      pos2 := PosEx(RnQImageUnTag, image, pos1 + length(RnQImageTag));
      imgList.Add(Copy(image, pos1 + length(RnQImageTag), pos2 - (pos1 + length(RnQImageTag))));
      image := Copy(image, pos2 + length(RnQImageUnTag), length(image));
    end
    else
      Break;
  until pos1 <= 0;

  image := imgStr;
  repeat
    pos1 := PosEx(RnQImageExTag, image);
    if (pos1 > 0) then
    begin
      pos2 := PosEx(RnQImageExUnTag, image, pos1 + length(RnQImageExTag));
      imgList.Add(Copy(image, pos1 + length(RnQImageExTag), pos2 - (pos1 + length(RnQImageExTag))));
      image := Copy(image, pos2 + length(RnQImageExUnTag), length(image));
    end
    else
      Break;
  until pos1 <= 0;
end;



procedure TFormEx.onAnimTimer(Sender: TObject);
begin
  if AnimTimer.Tag = 1 then
  begin
    if (AlphaValue > 0) and Assigned(self) and self.HandleAllocated then
      try
        if not Dimmed or (Dimmed and (AlphaValue <= 200)) then
          SetLayeredWindowAttributes(handle, 0, AlphaValue, LWA_ALPHA);
        Dec(AlphaValue, 33);
      except
        stopTimer()
      end
    else
      stopTimer();
  end
    else
  begin
    if (((AlphaValue <= 255) and not Dimmed) or ((AlphaValue <= 200) and Dimmed)) and Assigned(self) and self.HandleAllocated then
      try
        SetLayeredWindowAttributes(handle, 0, AlphaValue, LWA_ALPHA);
        Inc(AlphaValue, 25);
      except
        stopTimer()
      end
    else
      stopTimer();
  end;
end;

procedure TFormEx.onAniTimer(Sender: TObject);
begin
  if Assigned(images[ShownImage]) and
     Assigned(images[ShownImage].fBmp) and
     images[ShownImage].Animated then
    if images[ShownImage].RnQCheckTime then
      Invalidate;
end;


procedure TimerProc(hwnd: HWND; uMsg: UINT; idEvent: UINT_PTR; dwTime: DWORD); stdcall;
var
  Proc: TOnTimerProc;
begin
  if TimerList.TryGetValue(idEvent, Proc) then
  try
    KillTimer(0, idEvent);
    Proc();
  finally
    TimerList.Remove(idEvent);
  end;
end;

procedure SetTimeout(AProc: TOnTimerProc; ATimeout: Cardinal);
begin
  TimerList.Add(SetTimer(0, 0, ATimeout, @TimerProc), AProc);
end;

procedure TFormEx.ShowWithFade();
begin
  try
    Show;
    Invalidate;
    if Dimmed then
      startTimer()
    else
      SetTimeout(procedure begin startTimer(); end, 100);
  except
  end;
end;

procedure TFormEx.startTimer();
begin
  if (Assigned(AnimTimer)) then
    AnimTimer.Enabled := true;
end;

procedure TFormEx.stopTimer();
begin
  if (Assigned(AnimTimer)) then
    AnimTimer.Enabled := false;

  if AnimTimer.Tag = 1 then
    Close
  else
    AlphaValue := 255;
end;

procedure TFormEx.updateWindow();
var
  Bitmap: TBitmap;
  BitmapPos: TPoint;
  BitmapSize: TSIZE;
  BlendFunction: _BLENDFUNCTION;
begin
  Bitmap := TBitmap.Create;
  Bitmap.PixelFormat := pf32bit;
  Bitmap.SetSize(1920, 1080);
  Bitmap.Canvas.Brush.Color := clRed;
  Bitmap.Canvas.FillRect(Rect(0, 0, Bitmap.Width, Bitmap.Height));

  BitmapPos := Point(0, 0);
  BitmapSize.cx := 1920;
  BitmapSize.cy := 1080;
  BlendFunction.BlendOp := AC_SRC_OVER;
  BlendFunction.BlendFlags := 0;
  BlendFunction.SourceConstantAlpha := 127;
  BlendFunction.AlphaFormat := AC_SRC_ALPHA;
  UpdateLayeredWindow(Handle, 0, nil, @BitmapSize, Bitmap.Canvas.Handle, @BitmapPos, 0, @BlendFunction, ULW_ALPHA);

  Bitmap.Free;
end;

procedure TFormEx.CreateParams(var Params: TCreateParams);
begin
  inherited;
  Params.ExStyle := Params.ExStyle or WS_EX_NOACTIVATE;
end;

constructor TFormEx.CreateNew(AOwner: TComponent; DimmedParam: Boolean = False);
begin
  inherited CreateNew(AOwner);
  Dimmed := DimmedParam;

  if StyleServices.Enabled and Assigned(self) then
  begin
    SetWindowLong(handle, GWL_EXSTYLE, GetWindowLong(handle, GWL_EXSTYLE) or WS_EX_LAYERED);
    SetLayeredWindowAttributes(Handle, 0, 0, LWA_ALPHA);
  end;

  DoubleBuffered := True;
  BorderStyle := bsNone;
  KeyPreview := True;
  OnClose := OnCloseImg;
  OnKeyDown := OnKeyDownImg;
  OnMouseDown := OnMouseDownImg;
  if not Dimmed then
  begin
    FormStyle := fsStayOnTop;
    SetWindowPos(Handle, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOSIZE or SWP_NOMOVE or SWP_NOACTIVATE);
  end;

  alphaValue := 0;
  animTimer := TTimer.Create(Self);
  animTimer.Enabled := false;
  animTimer.OnTimer := onAnimTimer;
  animTimer.Interval := 10;
  animTimer.Tag := 0;

  aniTimer := TTimer.Create(Self);
  aniTimer.Enabled := false;
  aniTimer.OnTimer := onAniTimer;
  aniTimer.Interval := 20;
  aniTimer.Tag := 0;
end;

procedure TFormEx.FadeOut();
begin
  animTimer.Tag := 1;
  animTimer.Interval := 10;
  animTimer.Enabled := true;
end;

procedure TFormEx.FadeOutMsg(var Msg: TMessage);
begin
  FadeOut;
end;

procedure TFormEx.WMAppCommand(var msg: TMessage);
begin
  if Dimmed then
    PostMessage(otherForm, WM_APPCOMMAND, msg.WParam, msg.LParam)
  else
  case GET_APPCOMMAND_LPARAM(msg.LParam) of
    APPCOMMAND_BROWSER_BACKWARD:
      begin
        dec(ShownImage);
        if ShownImage < 0 then ShownImage := LastImage;
        UpdateShownImage;
        msg.Result := 1;
      end;

    APPCOMMAND_BROWSER_FORWARD:
      begin
        inc(ShownImage);
        if ShownImage > LastImage then ShownImage := 0;
        UpdateShownImage;
        msg.Result := 1;
      end;
  end;
end;

procedure TFormEx.ShowHideImages();
var
  i: integer;
begin
  if images[ShownImage].Animated then
   begin
    AniTimer.Enabled := True;
    images[ShownImage].RnQCheckTime;
   end
   else
    AniTimer.Enabled := False;
  images[ShownImage].Draw(Self.Canvas.Handle,
     DestRect(images[ShownImage].Width, images[ShownImage].Height, Self.Width, Self.Height ));
{
  if Length(images) > 0 then

  for i := 0 to Length(images) - 1 do
  if i = ShownImage then
  begin

    Controls[i].Show;
    if Controls[i].Tag = 3 then
    try
      // Remove flickering, animated GIFs only, doublebuffering messes up PNGs with alpha
      if (((Controls[i] as TImageEx).Picture.Graphic as TGIFImage).Images.Count > 1) then
        DoubleBuffered := True
      else
        DoubleBuffered := False;
    except end else
      DoubleBuffered := False;
  end else
    Controls[i].Hide;
}
end;

procedure TFormEx.PaintPic(Sender: TObject);
begin
  images[ShownImage].Draw(Self.Canvas.Handle,
     DestRect(images[ShownImage].Width, images[ShownImage].Height, Self.Width, Self.Height ));
end;

procedure TFormEx.UpdateShownImage();
begin
  if Dimmed or (ControlCount = 1) then
    Exit;

  AnimateWindow(Handle, 150, AW_BLEND or AW_HIDE);
  UpdateFormSize;
  ShowHideImages;
  AnimateWindow(Handle, 150, AW_BLEND);
end;

procedure TFormEx.UpdateFormSize();
const
  gap : Integer = 50;
var
//  aspect: single;
//  offset: integer;
  img: TRnQBitmap;
  bRect: TRect;
//  sz: TSize;
  d: TGPRect;
begin
//  if ControlCount = 0 then
//    Exit;
  if (Length(images)= 0) or not Assigned(Images[ShownImage]) then
    Exit;

  if Assigned(chatFrm) then
    bRect := Screen.MonitorFromWindow(chatFrm.Handle).BoundsRect
  else
    bRect := Screen.Monitors[0].BoundsRect;

  img := Images[ShownImage];
  d := DestRect(img.Width, img.Height, bRect.Width - gap - gap, bRect.Height - gap - gap);
  Left := d.X + gap;
  Top := d.Y + gap;
  Width := d.Width;
  Height := d.Height;

end;

procedure TFormEx.OnKeyDownImg(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Dimmed then
    PostMessage(otherForm, WM_KEYDOWN, Key, 0)
  else
  if (Key = VK_RIGHT) or (Key = VK_NEXT) or (Key = VK_UP) then
  begin
    inc(ShownImage);
    if ShownImage > LastImage then ShownImage := 0;
    UpdateShownImage;
  end
    else
  if (Key = VK_LEFT) or (Key = VK_PRIOR) or (Key = VK_DOWN) then
  begin
    dec(ShownImage);
    if ShownImage < 0 then ShownImage := LastImage;
    UpdateShownImage;
  end
    else
  begin
    PostMessage(otherForm, WM_FADEOUT, 0, 0);
    FadeOut;
  end;
end;

procedure TFormEx.OnMouseDownImg(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  PostMessage(otherForm, WM_FADEOUT, 0, 0);
  FadeOut;
end;

procedure TFormEx.OnCloseImg(Sender: TObject; var Action: TCloseAction);
begin
  if Assigned(chatFrm) then
    chatFrm.SetFocus;
  Action := caFree;
end;

function viewImageDimmed(const evimage: RawByteString; evoffset: Integer): Tform;
var
  formDim, formImg: TFormEx;
//  img: TImageEx;
  PIn, POut: Pointer;
  RnQPicStream: TMemoryStream;
  OutSize: Cardinal;
  imgList: TAnsiStringList;
  imgcnt: integer;
  imgtag: RawByteString;
  bRect: TRect;
  i, offset: integer;
begin
  formDim := TFormEx.CreateNew(chatFrm, True);
  formImg := TFormEx.CreateNew(chatFrm);
  formImg.otherForm := formDim.Handle;
  formDim.otherForm := formImg.Handle;

  if Assigned(chatFrm) then
    bRect := Screen.MonitorFromWindow(chatFrm.Handle).BoundsRect
  else
    bRect := Screen.Monitors[0].BoundsRect;

  formDim.BoundsRect := bRect;
  formDim.Color := clBlack;
  formImg.OnPaint := formImg.PaintPic;

  imgList := TAnsiStringList.Create;
  parseMsgImages(evimage, imgList);
  formImg.LastImage := imgList.count - 1;

  offset := 1;
  SetLength(formImg.images, imgList.count);
  for imgcnt := 0 to imgList.count - 1 do
  begin
    imgtag := imgList.Strings[imgcnt];
    PIn := @imgtag[1];
    OutSize := CalcDecodedSize(PIn, length(imgtag));
    RnQPicStream := TMemoryStream.Create;
    RnQPicStream.SetSize(OutSize);
    RnQPicStream.position := 0;
    POut := RnQPicStream.Memory;
    Base64Decode(PIn^, length(imgtag), POut^);

    formImg.images[imgcnt] := TRnQBitmap.Create;
    if not loadPic(TStream(RnQPicStream), formImg.images[imgcnt]) then
      FreeAndNil(RnQPicStream);
{
    img := TImageEx.Create(formImg);
    img.Parent := formImg;
    img.AutoSize := True;
    img.Center := True;
    img.Stretch := False;
    img.Proportional := True;
    img.Name := 'image' + IntToStr(imgcnt);
    img.Left := 0;
    img.Top := 0;

    loadImageEx(img, RnQPicStream, True);
    FreeAndNil(RnQPicStream);
}
    if (evoffset >= offset) then
      formImg.ShownImage := imgcnt;

//    if img.Tag = 0 then
//      img.Hide;

    inc(offset, length(imgtag) + length(RnQImageExTag) + length(RnQImageExUnTag));
  end;
  imgList.Free;

  formImg.UpdateFormSize;
  formImg.ShowHideImages;

  formDim.ShowWithFade;
  formImg.ShowWithFade;
  Result := formImg;
end;


initialization

TimerList := TDictionary<UINT_PTR, TOnTimerProc>.Create;

finalization

TimerList.Free;
TimerList := NIL;

end.
