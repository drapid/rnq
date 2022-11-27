{
  This file is part of R&Q.
  Under same license
}
unit RDTipDlg;
{$I forRnQConfig.inc}
{$I NoRTTI.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Types;

type
   Tmodes = (TM_EVENT, TM_PIC, TM_PIC_EX, TM_BDay);
   TTipInfo = record
      mode: Tmodes;
      obj: Pointer;
(*      case Tmodes of
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
*)
    end;

type
  TRDTipFrm = class;
  DoPaintTip = procedure(Sender: TRDTipFrm; mode: Tmodes; info: Pointer; pMaxX, pMaxY: Integer; calcOnly: Boolean);
  DoToShow = function(): Boolean;
  DoTipDestroy = procedure(Sender: TRDTipFrm);

  TtipsAlign  = (alBottomRight, alBottomLeft, alTopLeft, alTopRight, alCenter);
  TtipsAlignSet  = set of TtipsAlign;

  TTipItem = class(TObject)
   public
    form        : TRDTipFrm;
//    ev          : Thevent;
    time        : TDateTime;
    counter     : Integer;
    showSeconds : Word;
    x, y        : Integer;
    destructor TTipItemDestroy;
  end;

  TRDTipFrm = class(TForm)
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  public
   class var
    tipRadius: Integer; // = 15
    TipsMaxCnt: Integer; // = 20;
    TipsMaxTop: Integer; // = 200;
    TipsBtwSpace : Integer;
    TipsAlign    : TtipsAlign;
    TipHorIndent : Integer;
    TipVerIndent : Integer;
    class procedure MoveTips(ParentHandle: HWND = 0);
    class function  AddTip(var item: TTipItem; ti: TTipInfo; needW, needH: Integer; ParentHandle: HWND = 0): Boolean;
    class procedure TipsHideAll;
    class procedure TipsShowTop;
    class function  Add2ShowTip(pInfo: TTipInfo; x, y, Width, Height: Integer): TRDTipFrm;
    class procedure RemoveTip(i: Integer);
  private
    fOnPaintTip: DoPaintTip;
    fOnToShow: DoToShow;
    fOnTipDestroy: DoTipDestroy;
  protected
   class var
    tipsList: TList; // = NIL;
    class constructor TRDTipFrmCreate;
    class destructor  TRDTipFrmDestroy;
    procedure CreateParams(var Params: TCreateParams); override;
    function  preshow(): boolean;
    procedure postshow();
    procedure hide();
    procedure WndProc(var msg: TMessage); override;
    procedure Paint; override;
  public
    info: TTipInfo;
//    counter: integer;
//    time: Tdatetime;
    action: (TA_NULL, TA_LCLICK, TA_2LCLICK, TA_RCLICK, TA_2RCLICK);
    actionCount: integer;
    prevWnd: Thandle;
    mouseDown: boolean;
    isPainting: boolean;
    processing: boolean;
    procedure showTip();

(*
    procedure show(pEv: Thevent; x, y: Integer); overload;
    procedure show(pCnt: TRnQContact; x, y: Integer); overload;
//    procedure show(bmp: Tbitmap); overload;
    procedure show(bmp: Tbitmap; x, y: Integer); overload;
  {$IFNDEF NOT_USE_GDIPLUS}
    procedure show(gpbmp: TGPBitmap; x, y: Integer); overload;
  {$ELSE NOT_USE_GDIPLUS}
    procedure show(gpbmp: TRnQBitmap; x, y: Integer); overload;
  {$ENDIF NOT_USE_GDIPLUS}
*)
    property onPaintTip: DoPaintTip read fonPaintTip write fonPaintTip;
    property onToShow: DoToShow read fOnToShow write fOnToShow;
    property OnTipDestroy: DoTipDestroy read fOnTipDestroy write fOnTipDestroy;
    property currentPPI: Integer read GetParentCurrentDpi;
    class property tips: TList read tipsList;
  end;

implementation

{$R *.dfm}

uses
  math, strUtils,
 {$IFDEF UNICODE}
   AnsiStrings,
 {$ENDIF UNICODE}
  RDSysUtils;

destructor TTipItem.TTipItemDestroy;
begin
  if Assigned(form) then
    begin
      form.Close;
      form := NIL;
    end;
end;

class constructor TRDTipFrm.TRDTipFrmCreate;
begin
  tipRadius := 15;
  TipsMaxCnt := 20;
  TipsMaxTop := 200;
  tipsList := NIL;
end;

class destructor TRDTipFrm.TRDTipFrmDestroy;
begin
  if Assigned(tipsList) then
    FreeAndNil(tipsList);
end;

class function TRDTipFrm.Add2ShowTip(pInfo : TTipInfo; x, y, Width, Height : Integer) : TRDTipFrm;
begin
  Result := TRDTipFrm.Create(NIL);
  Result.info := pInfo;

  Result.Left := x;
  Result.Top  := y;
  Result.Width := Width;
  Result.Height := Height;
end;

procedure TRDTipFrm.showTip;
begin
  if not preshow() then
    exit;
  postshow();
  Paint;
end;

procedure TRDTipFrm.hide();
begin
// hide task button
//  setwindowlong(handle, GWL_HWNDPARENT, RnQmain.handle);
//  setwindowlong(handle, GWL_HWNDPARENT, RnQmain.handle);
// if not transparency.forTray then
  if not alphablend then
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

procedure TRDTipFrm.CreateParams(var Params: TCreateParams);
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


function TRDTipFrm.preshow():boolean;
begin
  result := FALSE;
  if processing or mousedown then
    exit;
  hide();
//  if locked then exit;
  if Assigned(fOnToShow) then
    if not fOnToShow then
      Exit;
  if actionCount>0 then
    exit;  // user interacting with tipfrm
  actioncount := 0;
  processing := TRUE;
  result := TRUE;
end; // preshow

procedure TRDTipFrm.postshow();
var
//  i: integer;
  R: HRGN;
//  hwnd: THandle;
  st: Integer;
begin
{for i:=1 to length(info) do
  if info[i] = #9 then
    info[i]:=' ';}
//  paint;
  if tipRadius > 0 then
  begin
    R := CreateRoundRectRgn(0,0, width+1,1+height, tipRadius, tipRadius);
    SetWindowRgn(Handle, R, False);
    deleteObject(R);
  end;
// if not transparency.forTray then
//   AnimateWindow(handle, 100, AW_ACTIVATE)
//  else
// st := GetWindowLong(Handle, GWL_STYLE);
// SetWindowLong(Handle, GWL_STYLE, st or WS_Popup);
  st := GetWindowLong(Handle, GWL_EXSTYLE);
  SetWindowLong(Handle, GWL_EXSTYLE, st or WS_EX_TOOLWINDOW {AND NOT WS_EX_APPWINDOW});
   showWindow(handle, SW_SHOWNA);
//   hwnd := GetForegroundWindow;
//   showWindow(handle, SW_SHOWNOACTIVATE);
//   if hwnd <> GetForegroundWindow then
//     SetForegroundWindow(hWnd);
  processing := FALSE;
end; // postshow

(*
procedure TRDTipFrm.show(bmp: Tbitmap; x, y: Integer);
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
procedure TRDTipFrm.show(gpbmp:TGPbitmap; x, y : Integer);
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

procedure TRDTipFrm.show(gpbmp:TRnQbitmap; x, y : Integer);
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

procedure TRDTipFrm.show(pEv:Thevent; x, y : Integer);
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

procedure TRDTipFrm.show(pCnt:TRnQContact; x, y : Integer);
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
*)
procedure TRDTipFrm.WndProc(var msg:TMessage);
begin
case msg.msg of
  WM_ACTIVATE:
    if word(msg.wparam) = WA_CLICKACTIVE then
      prevWnd:=msg.lParam;
//  WM_PRINT или WM_PRINTCLIENT
  end;
inherited;
end; // wndproc

procedure TRDTipFrm.paint;
var
  maxX,maxY: integer;
  work: Trect;
//  gr : TGPGraphics;
begin
  work := desktopWorkArea(Application.MainFormHandle);
  isPainting := True;
try
//  case info.mode of
//   TM_EVENT:
     begin
{       maxX := 0; maxY := 0;
       drawEvent(canvas, ev, maxX,maxY, True);
        boundInt(maxY, 0, work.bottom-work.top);
        boundInt(maxX, 0, work.right-work.left);
       drawEvent(canvas, ev, maxX,maxY, False);}
       maxX := self.width;
       maxY := self.height;
       if Assigned(onPaintTip) then
         onPaintTip(Self, info.mode, info.obj, maxX, maxY, False);
//       tipDrawEvent(Canvas.Handle, info.ev, NIL, maxX,maxY, False);
     end;
{   TM_PIC:
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
  end;   }
finally
 isPainting:= false;
end;
{
boundInt(maxY, 0, work.bottom-work.top);
boundInt(maxX, 0, work.right-work.left);
if not visible then
  setBounds( work.right-maxX, work.bottom-maxY, maxX, maxY);}
end; // paint

procedure TRDTipFrm.FormMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
mousedown:=FALSE;
end;

procedure TRDTipFrm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  hide;
  destroyHandle;
  Action := caFree;
end;

procedure TRDTipFrm.FormCreate(Sender: TObject);
begin
 DoubleBuffered := False;
 info.obj := NIL;
{
 info.pic   := NIL;
 info.ev    := NIL;
 info.gppic := NIL;
 info.cnt   := NIL;
}
 isPainting := false;
 processing := false;
end;

procedure TRDTipFrm.FormDestroy(Sender: TObject);
begin
  while isPainting do
    Application.ProcessMessages;
  if Assigned(OnTipDestroy) then
    OnTipDestroy(Self);
(*  case info.mode of
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
  end;*)
end;

procedure TRDTipFrm.FormMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
mousedown:=TRUE;
actionCount:=3;
if action=TA_null then
  begin
  if shift=[ssLeft]  then
    action:=TA_lclick;
  if shift=[ssRight] then
    action:=TA_rclick;
  end
else
  case action of
    TA_lclick: action:= TA_2lclick;
    TA_rclick: action:= TA_2rclick;
    end;
end;

class procedure TRDTipFrm.TipsHideAll;
var
  i: Integer;
  rt: TTipItem;
begin
  If Assigned(tipsList) then
  begin
    for I := 0 to tipsList.Count - 1 do
    begin
     rt := TTipItem(tipsList.Items[i]);
     tipsList.Items[i] := nil;
     if Assigned(rt) and Assigned(rt.form) then
         begin
           rt.form.Close;
           rt.form := NIL;
           rt.Free;
         end;
    end;
    FreeAndNil(tipsList);
//    if tipsList.Count = 0 then
//      FreeAndNil(tipsList);
  end;
end;

class procedure TRDTipFrm.TipsShowTop;
var
  i: Integer;
  rt: TTipItem;
begin
  If Assigned(tipsList) then
  for I := 0 to tipsList.Count - 1 do
  begin
   rt := TTipItem(tipsList.Items[i]);
   if Assigned(rt) and Assigned(rt.form) and
      //formVisible(rt.frm) and
      not isTopMost(rt.form) then
       begin
         setTopMost(rt.form, TRUE);
       end;
  end;
// if formVisible(tipFrm) then setTopMost(tipFrm, TRUE);
//if formVisible(tipfrm) and not isTopMost(tipFrm) then
//  setTopMost(tipFrm, TRUE);
end;

class procedure TRDTipFrm.MoveTips(ParentHandle: HWND = 0);
var
  i:  integer;
  minY: Integer;
  work: Trect;
  rt: TTipItem;
begin
//OutputDebugString('Processing MoveTips');
 if Assigned(tipsList) then
 begin
  work := desktopWorkArea(IfThen(ParentHandle=0, Application.MainFormHandle, ParentHandle));
  case TipsAlign of
    alBottomRight, alBottomLeft:
      begin
        minY := work.Bottom - TipVerIndent;
        for I := 0 to tipsList.Count - 1 do
        begin
         rt := TTipItem(tipsList.Items[i]);
         if Assigned(rt) and Assigned(rt.form) then
            begin
              if minY - rt.y - rt.form.Height > TipsBtwSpace then
              begin
                rt.y := minY - rt.form.Height;
      //          AnimateWindow()
                rt.form.Top := rt.y;
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
         rt := TTipItem(tipsList.Items[i]);
         if Assigned(rt) and Assigned(rt.form) then
            begin
              if rt.y  - minY > TipsBtwSpace then
              begin
                rt.y := minY;
      //          AnimateWindow()
                rt.form.Top := rt.y;
              end;
              minY := rt.y + rt.form.Height + TipsBtwSpace;
            end;
        end;
      end;
  end;
 end;
end;

class procedure TRDTipFrm.RemoveTip(i: Integer);
var
  rt: TTipItem;
begin
  if Assigned(tipsList) and (i < tipsList.Count) then
    begin
      rt := TTipItem(tipsList.Items[i]);
      tipsList.Items[i] := nil;
      if rt <> NIL then
        rt.Free;
    end;
end;

class function TRDTipFrm.AddTip(var item: TTipItem; ti: TTipInfo; needW, needH: Integer; ParentHandle: HWND): Boolean;
var
  i, cnt, idx: Integer;
  minX, minY: Integer;
//  needW, needH : Integer;
  work: Trect;
  not_ok: Boolean;
  rt: TTipItem;
begin
  if not Assigned(tipsList) then
    tipsList := TList.Create;
//  cnt  := 0;
//  Result := false;
//  lastY := work.Bottom;
  not_ok := True;
//  idx := 0;
  work := desktopWorkArea(IfThen(ParentHandle=0, Application.MainFormHandle, ParentHandle));
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
         rt := TTipItem(tipsList.Items[i]);
         if (rt <> NIL) and Assigned(rt.form) then
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
        if (tipsList.count > 0) and
           ((cnt >= tipsMaxCnt) or (minY - work.Top - TipsMaxTop < needH))
           and (idx < tipsList.Count) then
         begin
           rt := TTipItem(tipsList.Items[idx]);
           tipsList.Items[idx] := nil;
           if Assigned(rt) then
            begin
//             rt.frm.Close;
      //       rt.frm.hide();
             rt.form.Free;
             rt.form := NIL;
             rt.Free;
            end;
//           idx := -1;
           dec(cnt);
  //         minY := lastY;
         end;

        MoveTips;

        for I := 0 to tipsList.Count - 1 do
        begin
         rt := TTipItem(tipsList.Items[i]);
         if Assigned(rt) and Assigned(rt.form) then
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
         rt := TTipItem(tipsList.Items[i]);
         if (rt <> NIL) and Assigned(rt.form) then
          begin
            inc(cnt);
            if rt.counter < minX then
             begin
              minX := rt.counter;
              idx  := i;
             end;
            if (rt.y + rt.form.Height > minY) then
             begin
  //              lastY := minY;
              minY := rt.y + rt.form.Height;
             end;
          end;
        end;
        if (tipsList.count >0)and
            ((cnt >= TipsMaxCnt) or (work.Bottom - minY - TipsMaxTop < needH))
           and (idx < tipsList.Count) then
           begin
             rt := TTipItem(tipsList.Items[idx]);
             tipsList.Items[idx] := nil;
             if Assigned(rt) then
               begin
                 rt.form.Close;
                 rt.form := NIL;
          //       rt.frm.hide();
          //       rt.frm.Free;
                 rt.Free;
               end;
//             idx := -1;
             dec(cnt);
    //         minY := lastY;
           end;

        MoveTips;

        for I := 0 to tipsList.Count - 1 do
        begin
         rt := TTipItem(tipsList.Items[i]);
         if Assigned(rt) and Assigned(rt.form) then
           if (rt.x >= 0)and (rt.y >= 0) then
             minY := max(rt.Y + rt.form.Height, minY);
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
         rt := TTipItem(tipsList.Items[i]);
         if Assigned(rt) and Assigned(rt.form) then
           if (rt.x >= 0) and (rt.y >= 0) then
             minY := min(rt.Y, minY);
        end;
        item.Y := minY - needH;
        if (tipsList.Count > 0) then
          Dec(item.Y, TipsBtwSpace);
      end;
    alTopRight,
    alTopLeft:
      begin
        minY := TipVerIndent;
        for I := 0 to tipsList.Count - 1 do
        begin
         rt := TTipItem(tipsList.Items[i]);
         if Assigned(rt) and Assigned(rt.form) then
           if (rt.x >= 0)and (rt.y >= 0) then
             minY := max(rt.Y  + rt.form.Height, minY);
        end;
        item.Y := minY;
        if (tipsList.Count > 0) then
          Inc(item.Y, TipsBtwSpace);
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

  item.form  := TRDTipFrm.Add2ShowTip(ti, item.x, item.Y, needW, needH);

  tipsList.Add(item);
  Result := True;
end;

{
procedure Check4NIL;
var
  i: Integer;
//  rt: TTipItem;
  allClear: Boolean;
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
}

end.

