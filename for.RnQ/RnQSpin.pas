unit RnQSpin;

interface
{$I ForRnQConfig.inc}

 {$IFDEF COMPILER_14_UP}
  {$WEAKLINKRTTI ON}
  {$RTTI EXPLICIT METHODS([]) FIELDS([]) PROPERTIES([])}
 {$ENDIF COMPILER_14_UP}

uses Windows, Classes, StdCtrls, ExtCtrls, Controls, Messages, SysUtils,
  Forms, Graphics, //Menus,
  RnQButtons;

const
  InitRepeatPause = 400;  { pause before repeat timer (ms) }
  RepeatPause     = 100;  { pause before hint window displays (ms)}

type

//  TNumGlyphs = Buttons.TNumGlyphs;

  TTimerSpeedButton = class;

{ TRnQSpinButton }

  TRnQSpinButton = class (TWinControl)
  private
    FUpButton: TTimerSpeedButton;
    FDownButton: TTimerSpeedButton;
    FFocusedButton: TTimerSpeedButton;
    FFocusControl: TWinControl;
    FOnUpClick: TNotifyEvent;
    FOnDownClick: TNotifyEvent;
    function CreateButton: TTimerSpeedButton;
//    function GetUpGlyph: TBitmap;
//    function GetDownGlyph: TBitmap;
//    procedure SetUpGlyph(Value: TBitmap);
//    procedure SetDownGlyph(Value: TBitmap);
//    function GetUpNumGlyphs: TNumGlyphs;
//    function GetDownNumGlyphs: TNumGlyphs;
//    procedure SetUpNumGlyphs(Value: TNumGlyphs);
//    procedure SetDownNumGlyphs(Value: TNumGlyphs);
    procedure BtnClick(Sender: TObject);
    procedure BtnMouseDown (Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure SetFocusBtn (Btn: TTimerSpeedButton);
    procedure AdjustSize (var W, H: Integer); reintroduce;
    procedure WMSize(var Message: TWMSize);  message WM_SIZE;
    procedure WMSetFocus(var Message: TWMSetFocus); message WM_SETFOCUS;
    procedure WMKillFocus(var Message: TWMKillFocus); message WM_KILLFOCUS;
    procedure WMGetDlgCode(var Message: TWMGetDlgCode); message WM_GETDLGCODE;
    procedure WMEraseBkgnd(var Msg: TWmEraseBkgnd); message WM_ERASEBKGND;
  protected
    procedure Loaded; override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure Notification(AComponent: TComponent;
      Operation: TOperation); override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure SetBounds(ALeft, ATop, AWidth, AHeight: Integer); override;
  published
    property Align;
    property Anchors;
    property Constraints;
    property Ctl3D;
//    property DownGlyph: TBitmap read GetDownGlyph write SetDownGlyph;
//    property DownNumGlyphs: TNumGlyphs read GetDownNumGlyphs write SetDownNumGlyphs default 1;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property FocusControl: TWinControl read FFocusControl write FFocusControl;
    property ParentCtl3D;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop;
//    property UpGlyph: TBitmap read GetUpGlyph write SetUpGlyph;
//    property UpNumGlyphs: TNumGlyphs read GetUpNumGlyphs write SetUpNumGlyphs default 1;
    property Visible;
    property OnDownClick: TNotifyEvent read FOnDownClick write FOnDownClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnStartDock;
    property OnStartDrag;
    property OnUpClick: TNotifyEvent read FOnUpClick write FOnUpClick;
  end;

{ TRnQSpinEdit }
  {$IFDEF BCB}
  TValueType = (vtInt, vtFloat, vtHex);
  {$ELSE}
  TValueType = (vtInteger, vtFloat, vtHex);
  {$ENDIF BCB}


  TRnQSpinEdit = class(TCustomEdit)
  private
//    FMinValue: LongInt;
//    FMaxValue: LongInt;
//    FIncrement: LongInt;
    FDisplayFormat: string;
    FMinValue: Extended;
    FMaxValue: Extended;
    FOldValue: Extended;
    FIncrement: Extended;
    FDecimal: Byte;
    FButton: TRnQSpinButton;
    FEditorEnabled: Boolean;
    FEnabled : Boolean;
    FValueType: TValueType;
    FThousands: Boolean; // New
    function GetMinHeight: Integer;
    function IsIncrementStored: Boolean;
//    function GetValue: LongInt;
//    function GetValue: Extended; virtual; abstract;
    function GetValue: Extended;
    function CheckValue(NewValue: Extended): Extended;
//    function CheckValueRange(NewValue: Extended; RaiseOnError: Boolean): Extended;
//    function CheckValue (NewValue: LongInt): LongInt;
//    procedure SetValue (NewValue: LongInt);
    procedure SetValue(NewValue: Extended);
    procedure SetValueType(NewType: TValueType); virtual;
//    procedure SetMaxValue(NewValue: Extended);
//    procedure SetMinValue(NewValue: Extended);
//    function IsMaxStored: Boolean;
//    function IsMinStored: Boolean;
//    procedure SetEnabled(NewValue: Boolean);
    function IsValueStored: Boolean;
    procedure SetDecimal(NewValue: Byte);
    procedure SetEditRect;
    function GetAsInteger: Longint;
    procedure SetAsInteger(NewValue: Longint);
    procedure SetThousands(Value: Boolean);
    procedure SetDisplayFormat(const Value: string);
    function IsFormatStored: Boolean;
    procedure WMSize(var Message: TWMSize); message WM_SIZE;
    procedure CMEnter(var Message: TCMGotFocus); message CM_ENTER;
    procedure CMExit(var Message: TCMExit);   message CM_EXIT;
    procedure WMPaste(var Message: TWMPaste);   message WM_PASTE;
    procedure WMCut(var Message: TWMCut);   message WM_CUT;
  protected
    function IsValidChar(Key: Char): Boolean; virtual;
    function DefaultDisplayFormat: string; virtual;
    property DisplayFormat: string read FDisplayFormat write SetDisplayFormat stored IsFormatStored;
    procedure DataChanged; virtual;
    procedure UpClick (Sender: TObject); virtual;
    procedure DownClick (Sender: TObject); virtual;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyPress(var Key: Char); override;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure CreateWnd; override;
  public
    procedure GetChildren(Proc: TGetChildProc; Root: TComponent); override;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property Button: TRnQSpinButton read FButton;
  published
    property Anchors;
    property AutoSelect;
    property AutoSize;
    property Color;
    property Constraints;
    property Ctl3D;
    property DragCursor;
    property DragMode;
    property EditorEnabled: Boolean read FEditorEnabled write FEditorEnabled default True;
//    property Enabled : Boolean read FEnabled write SetEnabled default True;
    property Enabled;
    property Font;
    property Decimal: Byte read FDecimal write SetDecimal default 2;
    property MaxLength;
    property Increment: Extended read FIncrement write FIncrement stored IsIncrementStored;
//    property MaxValue: Extended read FMaxValue write SetMaxValue stored IsMaxStored;
//    property MinValue: Extended read FMinValue write SetMinValue stored IsMinStored;
//    property Increment: LongInt read FIncrement write FIncrement default 1;
//    property MaxValue: LongInt read FMaxValue write FMaxValue;
//    property MinValue: LongInt read FMinValue write FMinValue;
    property MaxValue: Extended read FMaxValue write FMaxValue;
    property MinValue: Extended read FMinValue write FMinValue;
    property ParentColor;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ReadOnly;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property ValueType: TValueType read FValueType write SetValueType
      default {$IFDEF BCB} vtInt {$ELSE} vtInteger {$ENDIF};
    property Value: Extended read GetValue write SetValue stored IsValueStored;
    property AsInteger: Longint read GetAsInteger write SetAsInteger default 0;
//    property Value: LongInt read GetValue write SetValue;
    property Thousands: Boolean read FThousands write SetThousands default False;
    property Visible;
    property OnChange;
    property OnClick;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnStartDrag;
  end;

{ TTimerSpeedButton }

  TTimeBtnState = set of (tbFocusRect, tbAllowTimer);

  TTimerSpeedButton = class(TRnQSpeedButton)
  private
    FRepeatTimer: TTimer;
    FTimeBtnState: TTimeBtnState;
    procedure TimerExpired(Sender: TObject);
  protected
    procedure Paint; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
  public
    destructor Destroy; override;
    property TimeBtnState: TTimeBtnState read FTimeBtnState write FTimeBtnState;
  end;


 procedure Register;

implementation

uses Themes, RDGlobal;

{ $R SPIN}

{ TRnQSpinButton }

constructor TRnQSpinButton.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle - [csAcceptsControls, csSetCaption] +
    [csFramed, csOpaque];
  { Frames don't look good around the buttons when themes are on }
  if ThemeServices.ThemesEnabled then
    ControlStyle := ControlStyle - [csFramed];
  FUpButton := CreateButton;
  FUpButton.ImageName := 'scroll.up';
  FUpButton.Invalidate;
  FDownButton := CreateButton;
  FDownButton.ImageName := 'scroll.down';
  FDownButton.Invalidate;
//  UpGlyph := nil;
//  DownGlyph := nil;

  Width := 22;
  Height := 25;
  FFocusedButton := FUpButton;
end;

function TRnQSpinButton.CreateButton: TTimerSpeedButton;
begin
  Result := TTimerSpeedButton.Create(Self);
  Result.OnClick := BtnClick;
  Result.OnMouseDown := BtnMouseDown;
  Result.Visible := True;
  Result.Enabled := True;
  Result.TimeBtnState := [tbAllowTimer];
  Result.Parent := Self;
  Result.AutoSize := False;
  Result.Constraints.MinHeight := 1+Height div 2;
  Result.Constraints.MaxHeight := Result.Constraints.MinHeight;
end;

procedure TRnQSpinButton.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (AComponent = FFocusControl) then
    FFocusControl := nil;
end;

procedure TRnQSpinButton.AdjustSize(var W, H: Integer);
begin
  if (FUpButton = nil) or (csLoading in ComponentState) then Exit;
  if W < 15 then W := 15;
   FUpButton.Constraints.MinHeight := 1 + H div 2;
   FUpButton.Constraints.MaxHeight := FUpButton.Constraints.MinHeight;
  FUpButton.SetBounds(0, 0, W, H div 2);
   FDownButton.Constraints.MinHeight := 1+ H div 2;
   FDownButton.Constraints.MaxHeight := FDownButton.Constraints.MinHeight;
  FDownButton.SetBounds(0, FUpButton.Height - 1, W, H - FUpButton.Height + 1);
end;

procedure TRnQSpinButton.SetBounds(ALeft, ATop, AWidth, AHeight: Integer);
var
  W, H: Integer;
begin
  W := AWidth;
  H := AHeight;
  AdjustSize(W, H);
  inherited SetBounds(ALeft, ATop, W, H);
end;

procedure TRnQSpinButton.WMSize(var Message: TWMSize);
var
  W, H: Integer;
begin
  inherited;
  { check for minimum size }
  W := Width;
  H := Height;
  AdjustSize(W, H);
  if (W <> Width) or (H <> Height) then
    inherited SetBounds(Left, Top, W, H);
  Message.Result := 0;
end;

procedure TRnQSpinButton.WMSetFocus(var Message: TWMSetFocus);
begin
  FFocusedButton.TimeBtnState := FFocusedButton.TimeBtnState + [tbFocusRect];
  FFocusedButton.Invalidate;
end;

procedure TRnQSpinButton.WMKillFocus(var Message: TWMKillFocus);
begin
  FFocusedButton.TimeBtnState := FFocusedButton.TimeBtnState - [tbFocusRect];
  FFocusedButton.Invalidate;
end;

procedure TRnQSpinButton.KeyDown(var Key: Word; Shift: TShiftState);
begin
  case Key of
    VK_UP:
      begin
        SetFocusBtn (FUpButton);
        FUpButton.Click;
      end;
    VK_DOWN:
      begin
        SetFocusBtn (FDownButton);
        FDownButton.Click;
      end;
    VK_SPACE:
      FFocusedButton.Click;
  end;
end;

procedure TRnQSpinButton.BtnMouseDown (Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then
  begin
    SetFocusBtn (TTimerSpeedButton (Sender));
    if (FFocusControl <> nil) and FFocusControl.TabStop and 
        FFocusControl.CanFocus and (GetFocus <> FFocusControl.Handle) then
      FFocusControl.SetFocus
    else if TabStop and (GetFocus <> Handle) and CanFocus then
      SetFocus;
  end;
end;

procedure TRnQSpinButton.BtnClick(Sender: TObject);
begin
  if Sender = FUpButton then
  begin
    if Assigned(FOnUpClick) then FOnUpClick(Self);
  end
  else
    if Assigned(FOnDownClick) then FOnDownClick(Self);
end;

procedure TRnQSpinButton.SetFocusBtn (Btn: TTimerSpeedButton);
begin
  if TabStop and CanFocus and  (Btn <> FFocusedButton) then
  begin
    FFocusedButton.TimeBtnState := FFocusedButton.TimeBtnState - [tbFocusRect];
    FFocusedButton := Btn;
    if (GetFocus = Handle) then 
    begin
       FFocusedButton.TimeBtnState := FFocusedButton.TimeBtnState + [tbFocusRect];
       Invalidate;
    end;
  end;
end;

procedure TRnQSpinButton.WMGetDlgCode(var Message: TWMGetDlgCode);
begin
  Message.Result := DLGC_WANTARROWS;
end;

procedure TRnQSpinButton.WMEraseBkgnd(var Msg: TWmEraseBkgnd);
begin
  PerformEraseBackground(Self, msg.DC);
   msg.Result := 1;
   msg.Msg := 0;
end;


procedure TRnQSpinButton.Loaded;
var
  W, H: Integer;
begin
  inherited Loaded;
  W := Width;
  H := Height;
  AdjustSize (W, H);
  if (W <> Width) or (H <> Height) then
    inherited SetBounds (Left, Top, W, H);
end;

{function TRnQSpinButton.GetUpGlyph: TBitmap;
begin
  Result := FUpButton.Glyph;
end;


procedure TRnQSpinButton.SetUpGlyph(Value: TBitmap);
begin
  if Value <> nil then
    FUpButton.Glyph := Value
  else
  begin
    FUpButton.Glyph.Handle := LoadBitmap(HInstance, 'SpinUp');
    FUpButton.NumGlyphs := 1;
    FUpButton.Invalidate;
  end;
end;

function TRnQSpinButton.GetUpNumGlyphs: TNumGlyphs;
begin
  Result := FUpButton.NumGlyphs;
end;

procedure TRnQSpinButton.SetUpNumGlyphs(Value: TNumGlyphs);
begin
  FUpButton.NumGlyphs := Value;
end;

function TRnQSpinButton.GetDownGlyph: TBitmap;
begin
  Result := FDownButton.Glyph;
end;

procedure TRnQSpinButton.SetDownGlyph(Value: TBitmap);
begin
  if Value <> nil then
    FDownButton.Glyph := Value
  else
  begin
    FDownButton.Glyph.Handle := LoadBitmap(HInstance, 'SpinDown');
    FUpButton.NumGlyphs := 1;
    FDownButton.Invalidate;
  end;
end;

function TRnQSpinButton.GetDownNumGlyphs: TNumGlyphs;
begin
  Result := FDownButton.NumGlyphs;
end;

procedure TRnQSpinButton.SetDownNumGlyphs(Value: TNumGlyphs);
begin
  FDownButton.NumGlyphs := Value;
end;

{ TRnQSpinEdit }

constructor TRnQSpinEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FButton := TRnQSpinButton.Create(Self);
//  FButton.Width := 15;
  FButton.Height := 17;
  FButton.Visible := True;  
  FButton.Parent := Self;
  FButton.FocusControl := Self;
  FButton.OnUpClick := UpClick;
  FButton.OnDownClick := DownClick;
  Text := '0';
  ControlStyle := ControlStyle - [csSetCaption];
  FIncrement := 1;
  FEditorEnabled := True;
  ParentBackground := False;
end;

destructor TRnQSpinEdit.Destroy;
begin
  FreeAndNil(FButton);
//  FButton := nil;
  inherited Destroy;
end;

procedure TRnQSpinEdit.GetChildren(Proc: TGetChildProc; Root: TComponent);
begin
end;

procedure TRnQSpinEdit.KeyDown(var Key: Word; Shift: TShiftState);
begin
  if Key = VK_UP then UpClick (Self)
  else if Key = VK_DOWN then DownClick (Self);
  inherited KeyDown(Key, Shift);
end;

procedure TRnQSpinEdit.KeyPress(var Key: Char);
begin
  if not IsValidChar(Key) then
  begin
    Key := #0;
    MessageBeep(0)
  end;
  if Key <> #0 then inherited KeyPress(Key);
end;

function TRnQSpinEdit.IsValidChar(Key: Char): Boolean;
begin
//  Result := (Key in [DecimalSeparator, '+', '-', '0'..'9']) or
  Result := (CharInSet(Key, [FormatSettings.DecimalSeparator, '+', '-', '0'..'9'])) or
    ((Key < #32) and (Key <> Chr(VK_RETURN)));
  if not FEditorEnabled and Result and ((Key >= #32) or
      (Key = Char(VK_BACK)) or (Key = Char(VK_DELETE))) then
    Result := False;
end;

procedure TRnQSpinEdit.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
{  Params.Style := Params.Style and not WS_BORDER;  }
  Params.Style := Params.Style or ES_MULTILINE or WS_CLIPCHILDREN;
end;

procedure TRnQSpinEdit.CreateWnd;
begin
  inherited CreateWnd;
  SetEditRect;
end;

procedure TRnQSpinEdit.SetDecimal(NewValue: Byte);
begin
  if FDecimal <> NewValue then
  begin
    FDecimal := NewValue;
    Value := GetValue;
  end;
end;

procedure TRnQSpinEdit.SetEditRect;
var
  Loc: TRect;
begin
  SendMessage(Handle, EM_GETRECT, 0, LongInt(@Loc));
  Loc.Bottom := ClientHeight + 1;  {+1 is workaround for windows paint bug}
  Loc.Right := ClientWidth - FButton.Width - 2;
  Loc.Top := 0;  
  Loc.Left := 0;  
  SendMessage(Handle, EM_SETRECTNP, 0, LongInt(@Loc));
  SendMessage(Handle, EM_GETRECT, 0, LongInt(@Loc));  {debug}
end;

procedure TRnQSpinEdit.WMSize(var Message: TWMSize);
var
  MinHeight: Integer;
begin
  inherited;
  MinHeight := GetMinHeight;
    { text edit bug: if size to less than minheight, then edit ctrl does
      not display the text }
  if Height < MinHeight then   
    Height := MinHeight
  else if FButton <> nil then
  begin
    if NewStyleControls and Ctl3D then
      FButton.SetBounds(Width - FButton.Width - 5, 0, FButton.Width, Height - 5)
    else FButton.SetBounds (Width - FButton.Width, 1, FButton.Width, Height - 3);
    SetEditRect;
  end;
end;

function TRnQSpinEdit.GetMinHeight: Integer;
var
  DC: HDC;
  SaveFont: HFont;
  I: Integer;
  SysMetrics, Metrics: TTextMetric;
begin
  DC := GetDC(0);
  GetTextMetrics(DC, SysMetrics);
  SaveFont := SelectObject(DC, Font.Handle);
  GetTextMetrics(DC, Metrics);
  SelectObject(DC, SaveFont);
  ReleaseDC(0, DC);
  I := SysMetrics.tmHeight;
  if I > Metrics.tmHeight then I := Metrics.tmHeight;
  Result := Metrics.tmHeight + I div 4 + GetSystemMetrics(SM_CYBORDER) * 4 + 2;
end;

procedure TRnQSpinEdit.UpClick (Sender: TObject);
begin
  if ReadOnly then MessageBeep(0)
  else Value := Value + FIncrement;
end;

procedure TRnQSpinEdit.DownClick (Sender: TObject);
begin
  if ReadOnly then MessageBeep(0)
  else Value := Value - FIncrement;
end;

procedure TRnQSpinEdit.WMPaste(var Message: TWMPaste);   
begin
  if not FEditorEnabled or ReadOnly then Exit;
  inherited;
end;

procedure TRnQSpinEdit.WMCut(var Message: TWMPaste);   
begin
  if not FEditorEnabled or ReadOnly then Exit;
  inherited;
end;

procedure TRnQSpinEdit.CMExit(var Message: TCMExit);
begin
  inherited;
  if CheckValue (Value) <> Value then
    SetValue (Value);
end;

function TRnQSpinEdit.GetAsInteger: Longint;
begin
  Result := Trunc(GetValue);
end;

procedure TRnQSpinEdit.SetAsInteger(NewValue: Longint);
begin
  SetValue(NewValue);
end;

procedure TRnQSpinEdit.SetThousands(Value: Boolean);
begin
  if ValueType <> vtHex then
    FThousands := Value;
end;

procedure TRnQSpinEdit.DataChanged;
(*var
  EditFormat: string;
  WasModified: Boolean;
begin
  if (ValueType = vtFloat) //and FFocused
  and (FDisplayFormat <> '') then
  begin
    EditFormat := '0';
    if FDecimal > 0 then
      EditFormat := EditFormat + '.' + MakeStr('#', FDecimal);
    { Changing EditText sets Modified to false }
    WasModified := Modified;
    try
      Text := FormatFloat(EditFormat, Value);
    finally
      Modified := WasModified;
    end;
  end;*)
begin
end;

function TRnQSpinEdit.DefaultDisplayFormat: string;
begin
  Result := ',0.##';
end;

procedure TRnQSpinEdit.SetDisplayFormat(const Value: string);
begin
  if DisplayFormat <> Value then
  begin
    FDisplayFormat := Value;
    Invalidate;
  end;
end;

function TRnQSpinEdit.IsFormatStored: Boolean;
begin
  Result := DisplayFormat <> DefaultDisplayFormat;
end;

procedure TRnQSpinEdit.SetValueType(NewType: TValueType);
begin
  if FValueType <> NewType then
  begin
    FValueType := NewType;
    Value := GetValue;
    if FValueType in [{$IFDEF BCB} vtInt {$ELSE} vtInteger {$ENDIF}, vtHex] then
    begin
      FIncrement := Round(FIncrement);
      if FIncrement = 0 then
        FIncrement := 1;
    end;
    if FValueType = vtHex then
      Thousands := False;
  end;
end;

{procedure TRnQSpinEdit.SetEnabled(NewValue: Boolean);
begin
  if NewValue <> FEnabled then
   begin
    FEnabled := NewValue;
    FButton.Enabled := NewValue;
    inherited enabled := NewValue;
   end;
end;
}

function TRnQSpinEdit.IsValueStored: Boolean;
begin
  Result := GetValue <> 0.0;
end;

function TRnQSpinEdit.IsIncrementStored: Boolean;
begin
  Result := FIncrement <> 1.0;
end;


{function TRnQSpinEdit.GetValue: LongInt;
begin
  try
    Result := StrToInt (Text);
  except
    Result := FMinValue;
  end;
end;}
function DelBSpace(const S: string): string;
var
  I, L: Integer;
begin
  L := Length(S);
  I := 1;
  while (I <= L) and (S[I] = ' ') do
    Inc(I);
  Result := Copy(S, I, MaxInt);
end;

function DelESpace(const S: string): string;
var
  I: Integer;
begin
  I := Length(S);
  while (I > 0) and (S[I] = ' ') do
    Dec(I);
  Result := Copy(S, 1, I);
end;

function DelRSpace(const S: string): string;
begin
  Result := DelBSpace(DelESpace(S));
end;
function DelChars(const S: string; Chr: Char): string;
var
  I: Integer;
begin
  Result := S;
  for I := Length(Result) downto 1 do
  begin
    if Result[I] = Chr then
      Delete(Result, I, 1);
  end;
end;
function ReplaceStr(const S, Srch, Replace: string): string;
var
  I: Integer;
  Source: string;
begin
  Source := S;
  Result := '';
  repeat
    I := Pos(Srch, Source);
    if I > 0 then
    begin
      Result := Result + Copy(Source, 1, I - 1) + Replace;
      Source := Copy(Source, I + Length(Srch), MaxInt);
    end
    else
      Result := Result + Source;
  until I <= 0;
end;

function TextToValText(const AValue: string): string;
var
  I, J: Integer;
begin
  Result := DelRSpace(AValue);
  if FormatSettings.DecimalSeparator <> FormatSettings.ThousandSeparator then
    Result := DelChars(Result, FormatSettings.ThousandSeparator);

  if (FormatSettings.DecimalSeparator <> '.') and (FormatSettings.ThousandSeparator <> '.') then
    Result := ReplaceStr(Result, '.', FormatSettings.DecimalSeparator);
  if (FormatSettings.DecimalSeparator <> ',') and (FormatSettings.ThousandSeparator <> ',') then
    Result := ReplaceStr(Result, ',', FormatSettings.DecimalSeparator);

  J := 1;
  for I := 1 to Length(Result) do
    if Result[I] in ['0'..'9', '-', '+', FormatSettings.DecimalSeparator, FormatSettings.ThousandSeparator] then
    begin
      Result[J] := Result[I];
      Inc(J);
    end;
  SetLength(Result, J - 1);

  if Result = '' then
    Result := '0'
  else
  if Result = '-' then
    Result := '-0';
end;

function RemoveThousands(const AValue: string): string;
begin
  if FormatSettings.DecimalSeparator <> FormatSettings.ThousandSeparator then
    Result := DelChars(AValue, FormatSettings.ThousandSeparator)
  else
    Result := AValue;
end;


function TRnQSpinEdit.GetValue: Extended;
begin
  try
    case ValueType of
      vtFloat:
        begin
          if FDisplayFormat <> '' then
          try
            Result := StrToFloat(TextToValText(Text));
          except
            Result := FMinValue;
          end
          else
          if not TextToFloat(PChar(RemoveThousands(Text)), Result, fvExtended) then
            Result := FMinValue;
        end;
      vtHex:
        Result := StrToIntDef('$' + Text, Round(FMinValue));
    else {vtInteger}
      Result := StrToIntDef(RemoveThousands(Text), Round(FMinValue));
    end;
  except
    if ValueType = vtFloat then
      Result := FMinValue
    else
      Result := Round(FMinValue);
  end;
end;

procedure TRnQSpinEdit.SetValue(NewValue: Extended);
var
  FloatFormat: TFloatFormat;
  WasModified: Boolean;
  s : String;
begin
  if Thousands then
    FloatFormat := ffNumber
  else
    FloatFormat := ffFixed;

  { Changing EditText sets Modified to false }
  WasModified := Modified;
  try
    case ValueType of
      vtFloat:
        if FDisplayFormat <> '' then
          Text := FormatFloat(FDisplayFormat, CheckValue(NewValue))
        else
          Text := FloatToStrF(CheckValue(NewValue), FloatFormat, 15, FDecimal);
      vtHex:
        if ValueType = vtHex then
          Text := IntToHex(Round(CheckValue(NewValue)), 1);
    else {vtInteger}
      begin
      //Text := IntToStr(Round(CheckValue(NewValue)));
        s := FloatToStrF(CheckValue(NewValue), FloatFormat, 15, 0);
        Text := s;
      end;
    end;
    DataChanged;
  finally
    Modified := WasModified;
  end;
end;


{procedure TRnQSpinEdit.SetValue (NewValue: LongInt);
begin
  Text := IntToStr (CheckValue (NewValue));
end;}

{function TRnQSpinEdit.CheckValue (NewValue: LongInt): LongInt;
begin
  Result := NewValue;
  if (FMaxValue <> FMinValue) then
  begin
    if NewValue < FMinValue then
      Result := FMinValue
    else if NewValue > FMaxValue then
      Result := FMaxValue;
  end;
end;}
function TRnQSpinEdit.CheckValue(NewValue: Extended): Extended;
begin
  Result := NewValue;

    if (FMaxValue <> FMinValue) then
    begin
      if NewValue < FMinValue then
        Result := FMinValue
      else
      if NewValue > FMaxValue then
        Result := FMaxValue;
    end;
  {
  if FCheckMinValue or FCheckMaxValue then
  begin
    if FCheckMinValue and (NewValue < FMinValue) then
      Result := FMinValue;
    if FCheckMaxValue and (NewValue > FMaxValue) then
      Result := FMaxValue;
  end;}
end;
{
function TRnQSpinEdit.CheckValueRange(NewValue: Extended; RaiseOnError: Boolean): Extended;
begin
  Result := CheckValue(NewValue);
  if (FCheckMinValue or FCheckMaxValue) and
    RaiseOnError and (Result <> NewValue) then
    raise ERangeError.CreateResFmt(@RsEOutOfRangeFloat, [FMinValue, FMaxValue]);
end;
}

procedure TRnQSpinEdit.CMEnter(var Message: TCMGotFocus);
begin
  if AutoSelect and not (csLButtonDown in ControlState) then
    SelectAll;
  inherited;
end;

{TTimerSpeedButton}

destructor TTimerSpeedButton.Destroy;
begin
  if FRepeatTimer <> nil then
    FRepeatTimer.Free;
  inherited Destroy;
end;

procedure TTimerSpeedButton.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited MouseDown (Button, Shift, X, Y);
  if tbAllowTimer in FTimeBtnState then
  begin
    if FRepeatTimer = nil then
      FRepeatTimer := TTimer.Create(Self);

    FRepeatTimer.OnTimer := TimerExpired;
    FRepeatTimer.Interval := InitRepeatPause;
    FRepeatTimer.Enabled  := True;
  end;
end;

procedure TTimerSpeedButton.MouseUp(Button: TMouseButton; Shift: TShiftState;
                                  X, Y: Integer);
begin
  inherited MouseUp (Button, Shift, X, Y);
  if FRepeatTimer <> nil then
    FRepeatTimer.Enabled  := False;
end;

procedure TTimerSpeedButton.TimerExpired(Sender: TObject);
begin
  FRepeatTimer.Interval := RepeatPause;
  if (FState = bsDown) and MouseCapture then
  begin
    try
      Click;
    except
      FRepeatTimer.Enabled := False;
      raise;
    end;
  end;
end;

procedure TTimerSpeedButton.Paint;
var
  R: TRect;
begin
  inherited Paint;
  if tbFocusRect in FTimeBtnState then
  begin
    R := Bounds(0, 0, Width, Height);
    InflateRect(R, -3, -3);
    if FState = bsDown then
      OffsetRect(R, 1, 1);
    DrawFocusRect(Canvas.Handle, R);
  end;
end;

procedure Register;

begin
  RegisterComponents('RnQ', [TRnQSpinButton]);
  RegisterComponents('RnQ', [TRnQSpinEdit]);
end;

end.
