//*******************************************************//
//                                                       //
//                      DelphiFlash.com                  //
//              Copyright (c) 2004 FeatherySoft, Inc.    //
//                    info@delphiflash.com               //
//                                                       //
//*******************************************************//

//  Description: Extended ShockwaveFlash visual control
//  Last date update: 9 mar 2004

unit ShockwaveEx;

interface

uses
  Windows, SysUtils, Classes, Controls, OleCtrls, ShockwaveFlashObjects_TLB,
  Messages{$IFNDEF VER130}, Types{$ENDIF};

type
  TShockwaveFlashEx = class(TShockwaveFlash)
  private
    FOnMouseDown: TMouseEvent;
    FOnMouseUp: TMouseEvent;
    FOnMouseMove: TMouseMoveEvent;
    FOnClick: TNotifyEvent;
    fLockMouseClick: boolean;
    WasDown: boolean;
  protected
    procedure WndProc(var Message:TMessage); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure Click; override;
  public
    Procedure CreateWnd; override;
  published
    property OnMouseDown: TMouseEvent read FOnMouseDown write FOnMouseDown;
    property OnMouseUp: TMouseEvent read FOnMouseUp write FOnMouseUp;
    property OnMouseMove: TMouseMoveEvent read FOnMouseMove write FOnMouseMove;
    property OnClick: TNotifyEvent read FOnClick write FOnClick;
    property LockMouseClick: boolean read fLockMouseClick write fLockMouseClick default false;
  end;

procedure Register;

implementation

Procedure TShockwaveFlashEx.CreateWnd;
begin
  inherited;
end;

procedure TShockwaveFlashEx.WndProc(var Message:TMessage);
Var x,y: integer;
    xy: TPoint;
begin
  if not (csDesigning in ComponentState) then
    begin
      x:=TSmallPoint(Message.LParam).x;
      y:=TSmallPoint(Message.LParam).y;
      Case Message.Msg of
        CM_MOUSELEAVE: WasDown:=false;
        WM_LBUTTONDOWN: begin MouseDown(mbLeft,[],x,y); WasDown:=true; end;
        WM_RBUTTONDOWN: WasDown:=true;
        WM_RBUTTONUP: if (PopupMenu<>nil) and (WasDown) Then
          begin
            WasDown:=false;
            xy.X:=x;
            xy.Y:=y;
            xy:=ClientToScreen(xy);
            PopupMenu.Popup(xy.X,xy.Y);
          end;
        WM_LBUTTONUP: begin MouseUp(mbLeft,[],x,y); WasDown:=false; end;
        WM_MOUSEMOVE: MouseMove([],x,y);
      end;
       if (((Message.Msg=WM_RBUTTONDOWN) or (Message.Msg=WM_RBUTTONDOWN)) and (not Menu)) or
           (((Message.Msg=WM_RBUTTONUP) or (Message.Msg=WM_LBUTTONUP)) and (fLockMouseClick))
             then Message.Result := 0
             else inherited WndProc(Message);
      Exit;
    end;
  inherited WndProc(Message);
end;

procedure TShockwaveFlashEx.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Assigned(FOnMouseDown) then
    begin
      FOnMouseDown(Self, Button, Shift, X, Y);
    end;
end;

procedure TShockwaveFlashEx.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Assigned(FOnMouseUp) then
    begin
      FOnMouseUp(Self, Button, Shift, X, Y);
    end;
  if WasDown Then Click;
end;

procedure TShockwaveFlashEx.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  if Assigned(FOnMouseMove) then FOnMouseMove(Self, Shift, X, Y);
end;

procedure TShockwaveFlashEx.Click;
begin
  if Assigned(FOnClick) then FOnClick(Self);
end;

procedure Register;
begin
  RegisterComponents('Flash', [TShockwaveFlashEx]);
end;

end.
