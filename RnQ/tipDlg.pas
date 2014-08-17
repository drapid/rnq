{
This file is part of R&Q.
Under same license
}
unit tipDlg;
{$I RnQConfig.inc}
{$I NoRTTI.inc}


interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Types,
  {$IFNDEF NOT_USE_GDIPLUS}
    GDIPAPI,
    GDIPOBJ,
    RnQGraphics,
  {$ELSE}
    RnQGraphics32,
  {$ENDIF NOT_USE_GDIPLUS}
  RnQProtocol,
  events;

type
   Tmodes = (TM_EVENT, TM_PIC, TM_PIC_EX, TM_BDay);
   TTipInfo = record
      mode: Tmodes;
      case Tmodes of
         TM_EVENT  : (ev  : Thevent);
         TM_PIC    : (pic : Tbitmap);
         TM_PIC_EX : (
                    {$IFNDEF NOT_USE_GDIPLUS}
                      gpPic : TGPBitmap;
                    {$ELSE NOT_USE_GDIPLUS}
                      gpPic : TRnQBitmap;
                    {$ENDIF NOT_USE_GDIPLUS}
            );
         TM_BDay : (cnt : TRnQContact);
    end;

type
  TtipFrm = class(TForm)
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    function preshow():boolean;
    procedure postshow();
    procedure hide();
    procedure WndProc(var msg:TMessage); override;
  public
    info : TTipInfo;
(*
//    evkind:integer;
    mode: (TM_EVENT, TM_PIC, TM_PIC_EX);
    ev : Thevent;
//    info:string;
//    contact:Tcontact;
    pic:Tbitmap;
  {$IFNDEF NOT_USE_GDIPLUS}
    gpPic : TGPBitmap;
  {$ELSE NOT_USE_GDIPLUS}
    gpPic : TRnQBitmap;
  {$ENDIF NOT_USE_GDIPLUS}
*)
//    counter:integer;
//    time:Tdatetime;
    action: (TA_NULL, TA_LCLICK, TA_2LCLICK, TA_RCLICK, TA_2RCLICK);
    actionCount: integer;
    prevWnd:Thandle;
    mouseDown:boolean;
    isPainting:boolean;
    procedure Paint; override;
    procedure show(pEv:Thevent; x, y : Integer); overload;
    procedure show(pCnt:TRnQContact; x, y : Integer); overload;
//    procedure show(bmp:Tbitmap); overload;
    procedure show(bmp:Tbitmap; x, y : Integer); overload;
  {$IFNDEF NOT_USE_GDIPLUS}
    procedure show(gpbmp:TGPBitmap; x, y : Integer); overload;
  {$ELSE NOT_USE_GDIPLUS}
    procedure show(gpbmp:TRnQBitmap; x, y : Integer); overload;
  {$ENDIF NOT_USE_GDIPLUS}
  end;


//var
//  tipDrawType : Byte;

implementation

{$R *.dfm}

uses
  math, strUtils,
 {$IFDEF UNICODE}
   AnsiStrings,
 {$ENDIF UNICODE}
  RDGlobal, RQThemes, RnQSysUtils,
//  RnQDialogs, RQUtil, RnQUtils, RnQBinUtils, RnQLangs,
  globalLib, mainDlg, utilLib, chatDlg,
  themesLib, RnQTips,
  RQlog;
var
  processing:boolean=FALSE;
//const
//  round_R = 15;

procedure Ttipfrm.hide();
begin
// hide task button
//  setwindowlong(handle, GWL_HWNDPARENT, RnQmain.handle);
//  setwindowlong(handle, GWL_HWNDPARENT, RnQmain.handle);
 if not transparency.forTray then
   AnimateWindow(handle, 200, AW_BLEND or AW_HIDE)
  else
   showWindow(handle, SW_HIDE);
//counter:=0;
if prevWnd>0 then
  begin
  forceForegroundWindow(prevWnd);
  prevWnd:=0;
  end;
end; // hide

procedure TtipFrm.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  with Params do
  begin
    WndParent := GetDesktopWindow;
//    Style := WS_CLIPSIBLINGS or WS_CHILD;
    ExStyle := WS_EX_TOPMOST or WS_EX_TOOLWINDOW;
//    WindowClass.Style := CS_DBLCLKS or CS_SAVEBITS;
    Style := Style or BS_OWNERDRAW;
  end;
end;


function Ttipfrm.preshow():boolean;
begin
  result:=FALSE;
  if processing or mousedown then exit;
  hide();
  if locked then exit;
  if actionCount>0 then exit;  // user interacting with tipfrm
  actioncount:=0;
  processing:=TRUE;
  result:=TRUE;
end; // preshow

procedure Ttipfrm.postshow();
var
//  i:integer;
  R:HRGN;
//  hwnd:THandle;
  rad : Integer;
  st : Integer;
begin
{for i:=1 to length(info) do
  if info[i] = #9 then
    info[i]:=' ';}
//  paint;
  if not TryStrToInt(theme.GetString('tip.radius'), rad) then
   rad := 0;
  if rad > 0 then
  begin
    R:=CreateRoundRectRgn(0,0,width+1,1+height,rad,rad);
    SetWindowRgn(Handle,R, False);
    deleteObject(R);
  end;
// if not transparency.forTray then
//   AnimateWindow(handle, 100, AW_ACTIVATE)
//  else
// st := GetWindowLong(Handle, GWL_STYLE);
// SetWindowLong(Handle, GWL_STYLE, st or WS_Popup);
  st:=GetWindowLong(Handle, GWL_EXSTYLE);
  SetWindowLong(Handle, GWL_EXSTYLE, st or WS_EX_TOOLWINDOW {AND NOT WS_EX_APPWINDOW});
   showWindow(handle, SW_SHOWNA);
//   hwnd := GetForegroundWindow;
//   showWindow(handle, SW_SHOWNOACTIVATE);
//   if hwnd <> GetForegroundWindow then
//     SetForegroundWindow(hWnd);
  processing:=FALSE;
end; // postshow

procedure Ttipfrm.show(bmp:Tbitmap; x, y : Integer);
type
  PColor32 = ^TColor32;
  TColor32 = type Cardinal;
function SetAlpha(Color32: TColor32; NewAlpha: Integer): TColor32;
begin
  if NewAlpha < 0 then NewAlpha := 0
  else if NewAlpha > 255 then NewAlpha := 255;
  Result := (Color32 and $00FFFFFF) or (TColor32(NewAlpha) shl 24);
end;

var
//  R:TRect;
    r, C:Cardinal;
    PC:PColor32;
begin
  info.mode:=TM_PIC;
  if bmp=NIL then hide();
  if info.pic=NIL then
    info.pic:=Tbitmap.create
   else
    info.pic.ReleaseHandle;
  if not preshow() then exit;

//  gpPic := NIL;
//  pic.Assign(bmp);
   begin
    info.pic.PixelFormat      := bmp.PixelFormat;
    info.pic.SetSize(bmp.Width, bmp.Height);
    info.pic.Transparent      := bmp.Transparent;
    info.pic.TransparentColor := bmp.TransparentColor;
    info.pic.TransparentMode  := bmp.TransparentMode;
//      R := Rect(0 ,20, 100, 100);
//    FillRect(pic.Canvas.Handle, r, CreateSolidBrush(clRed));
    BitBlt(info.pic.Canvas.Handle, 0, 0, info.pic.Width, info.pic.Height,
           bmp.Canvas.Handle, 0, 0, SrcCopy);
    if info.pic.PixelFormat = pf32bit then
     begin
     for R:=0 to bmp.Height-1 do
      begin
       PC:=Pointer(info.pic.ScanLine[r]);
       for C:=0 to bmp.Width-1 do
        begin
          PC^:=SetAlpha(PC^,$FF);
          Inc(PC);
        end;
      end;
     end;
//          DrawText(pic.Canvas.Handle, PChar('Привет'), -1, R, DT_SINGLELINE);// or DT_VCENTER);
   end;
//  mode:=TM_PIC;
//counter:=0;
//time:=now;
//  ev := NIL;
  Left := x;
  Top  := y;
  Width  := bmp.Width;
  Height := bmp.Height;
  postShow();
end; // show

  {$IFNDEF NOT_USE_GDIPLUS}
procedure Ttipfrm.show(gpbmp:TGPbitmap; x, y : Integer);
begin
mode:=TM_PIC_EX;
if gpbmp=NIL then hide();
if pic=NIL then
  pic:=Tbitmap.create
 else
  pic.ReleaseHandle;
if not preshow() then exit;
 gpPic := gpbmp.Clone(MakeRect(0, 0, gpbmp.GetWidth, gpbmp.GetHeight), gpbmp.GetPixelFormat);
//pic.Assign(bmp);
mode:=TM_PIC_EX;
  pic := nil;
//counter:=0;
//time:=now;
  ev := NIL;
  Left := x;
  Top  := y;
  Width  := gpbmp.GetWidth;
  Height := gpbmp.GetHeight;
  postShow();
end; // show
  {$ELSE NOT_USE_GDIPLUS}

procedure Ttipfrm.show(gpbmp:TRnQbitmap; x, y : Integer);
begin
  info.mode:=TM_PIC_EX;
  if gpbmp=NIL then hide();
{  if pic=NIL then
    info.pic:=Tbitmap.create
   else
    info.pic.ReleaseHandle;}
  if not preshow() then exit;
  info.gpPic := gpbmp.Clone(MakeRect(0, 0, gpbmp.GetWidth, gpbmp.GetHeight));
//pic.Assign(bmp);
//  mode:=TM_PIC_EX;
//  pic := nil;
//counter:=0;
//time:=now;
//  ev := NIL;
  Left := x;
  Top  := y;
  Width  := gpbmp.GetWidth;
  Height := gpbmp.GetHeight;
  postShow();
end; // show
  {$ENDIF NOT_USE_GDIPLUS}

procedure Ttipfrm.show(pEv:Thevent; x, y : Integer);
//var
//  s, p : String;
//  i, k : Integer;
//  bmp : TBitmap;
begin
  if pEv = NIL then Exit;
  if (pEv<>NIL) and not (BE_TIP in supportedBehactions[pEv.kind]) then exit;
  if (pEv.kind in [EK_msg,EK_url]) // user reading this message in chat window
  and chatFrm.isVisible
  and (pEv.who.equals(chatFrm.thisChat.who)) then
    exit;
  if not preshow() then exit;
  info.mode:=TM_EVENT;
  info.ev  := pEv.clone;
{
  if ev.kind in [EK_url,EK_msg,EK_contacts,EK_authReq,EK_automsg] then
    info := ev.decrittedInfoOrg
   else
    info := '';}
//  gpPic := NIL;
//  pic := nil;
//  contact := pEv.who;
  Left := x;
  Top  := y;
//  Width  := bmp.Width;
//  Height := bmp.Height;

  postShow();
end; // show Event

procedure Ttipfrm.show(pCnt:TRnQContact; x, y : Integer);
begin
  if pCnt = NIL then Exit;
//  if (pCnt<>NIL) and not (BE_TIP in supportedBehactions[pEv.kind]) then exit;
  if not preshow() then exit;
  info.mode := TM_BDay;
  info.cnt  := pCnt;
  Left := x;
  Top  := y;
  postShow();
end; // show BirthDay

procedure Ttipfrm.WndProc(var msg:TMessage);
begin
case msg.msg of
  WM_ACTIVATE:
    if word(msg.wparam) = WA_CLICKACTIVE then
      prevWnd:=msg.lParam;
//  WM_PRINT или WM_PRINTCLIENT
  end;
inherited;
end; // wndproc

procedure Ttipfrm.paint;
var
  maxX,maxY:integer;
  work:Trect;
//  gr : TGPGraphics;
begin
  work:=desktopWorkArea;
  isPainting := True;
try
  case info.mode of
   TM_EVENT:
     begin
{       maxX := 0; maxY := 0;
       drawEvent(canvas, ev, maxX,maxY, True);
        boundInt(maxY, 0, work.bottom-work.top);
        boundInt(maxX, 0, work.right-work.left);
       drawEvent(canvas, ev, maxX,maxY, False);}
       maxX := self.width;
       maxY := self.height;
       tipDrawEvent(Canvas.Handle, info.ev, NIL, maxX,maxY, False);
     end;
   TM_PIC:
     if info.pic <> NIL then
     begin
      maxX := info.pic.Width;
      maxY := info.pic.Height;
      canvas.Draw(0,0, info.pic);
     end;
   TM_PIC_EX:
     if info.gpPic <> NIL then
     begin
       maxX:= info.gpPic.GetWidth;
       maxY:= info.gpPic.GetHeight;
       DrawRbmp(canvas.Handle, info.gpPic);
     end;
   TM_BDay:
     begin
       maxX := self.width;
       maxY := self.height;
       tipDrawEvent(Canvas.Handle, NIL, info.cnt, maxX,maxY, False);
     end;
  end;
finally
 isPainting:= false;
end;
{
boundInt(maxY, 0, work.bottom-work.top);
boundInt(maxX, 0, work.right-work.left);
if not visible then
  setBounds( work.right-maxX, work.bottom-maxY, maxX, maxY);}
end; // paint

procedure TtipFrm.FormMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
mousedown:=FALSE;
end;

procedure TtipFrm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  hide;
  destroyHandle;
  Action := caFree;
end;

procedure TtipFrm.FormCreate(Sender: TObject);
begin
 DoubleBuffered := False;
 info.pic   := NIL;
 info.ev    := NIL;
 info.gppic := NIL;
 info.cnt   := NIL;
 isPainting := false;
end;

procedure TtipFrm.FormDestroy(Sender: TObject);
begin
  while isPainting do
    Application.ProcessMessages;
  case info.mode of
    TM_EVENT:
      if Assigned(info.ev) then
       begin
        info.ev.Free;
        info.ev := NIL;
       end;
    TM_PIC:
      if Assigned(info.pic) then
       begin
         info.pic.Free;
         info.pic := NIL;
       end;
    TM_PIC_EX:
      if Assigned(info.gppic) then
       begin
         info.gppic.Free;
         info.gpPic := NIL;
       end;
    TM_BDay:
      if Assigned(info.cnt) then
       begin
//         info.cnt.Free;
         info.cnt := NIL;
       end;
  end;
end;

procedure Ttipfrm.FormMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
mousedown:=TRUE;
actionCount:=3;
if action=TA_null then
  begin
  if shift=[ssLeft]  then action:=TA_lclick;
  if shift=[ssRight] then action:=TA_rclick;
  end
else
  case action of
    TA_lclick: action:= TA_2lclick;
    TA_rclick: action:= TA_2rclick;
    end;
end;

end.

