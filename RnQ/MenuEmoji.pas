{
  This file is part of R&Q.
  Under same license
}
unit MenuEmoji;
{$I RnQConfig.inc}
{$I NoRTTI.inc}


interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Types, StdCtrls, RnQNet, RnQProtocol, utilLib,
  ExtCtrls, Math, Character,
  System.Actions, Vcl.ActnList, //Generics.Collections,
  RDGlobal, RnQGraphics32, RnQButtons, RnQImageGrid;

type
  TEmojiFrm = class(TForm)
    UpdTmr: TTimer;
    exts: TPanel;
    actList: TActionList;
    NextExt: TAction;
    PrevExt: TAction;
    procedure FormShow(Sender: TObject);
    procedure UpdTmrTimer(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure showEmojiExt(ext: Integer);
    procedure OnExtBtnClick(Sender: TObject);
    procedure InvalidateEmoji(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure SendSelectedEmoji(Sender: TCustomImageGrid; Index: Integer);
    procedure CreateExtBtns;
    procedure RefreshExtBtnStates;
    procedure PutEmoji(FExt, FEmoji: Integer);
    function GetEmoji(num: Integer): TGraphic;
    procedure NextExtExecute(Sender: TObject);
    procedure PrevExtExecute(Sender: TObject);
    procedure FormHide(Sender: TObject);
    constructor Create(parent: TWinControl); OverLoad;
  private
    { Private declarations }
    parentWnd: TWinControl;
    rnqContact: TRnQContact;
    procedure  GoToChat;
  public
    { Public declarations }
    procedure CreateParams( var Params: TCreateParams ); override;
    property  currentPPI: Integer read GetParentCurrentDpi;
  end;
  procedure ShowEmojiMenu(rnqcon: TRnQContact; parent: TWinControl; t: tpoint);

var
//  rnqContact: TRnQContact;
  EmojiFrm: TEmojiFrm;

implementation

uses
  RnQLangs, RnQGlobal, RQUtil, RQThemes, chatDlg,
  {$IFNDEF USE_MORMOT_COLLECTIONS}
  Generics.Collections,
  {$ELSE USE_MORMOT_COLLECTIONS}
  mormot.core.base,
  mormot.core.collections,
  {$ENDIF USE_MORMOT_COLLECTIONS}
  EmojiConst;

var
  {$IFNDEF USE_MORMOT_COLLECTIONS}
  emojiGrids: TDictionary<Integer, TAwImageGrid>;
  {$ELSE USE_MORMOT_COLLECTIONS}
  emojiGrids: IKeyValue<Integer, TAwImageGrid>;
  {$ENDIF USE_MORMOT_COLLECTIONS}
  extPos: Integer = 1;
  openedExt: Integer = 1;
  emojiSize: Integer = 22;

{$R *.dfm}

procedure TEmojiFrm.GoToChat;
begin
  if Assigned(parentWnd) then
    SetForegroundWindow(parentWnd.Handle);
end;

procedure TEmojiFrm.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  with Params do
  begin
    Style := Style or WS_OVERLAPPED;
    Style := Style and not WS_CLIPCHILDREN;
    if Assigned(parentWnd) then
      WndParent := parentWnd.Handle;
    ExStyle := ExStyle or WS_EX_LAYERED;
  end;
end;

procedure TEmojiFrm.FormShow(Sender: TObject);
begin
  showEmojiExt(openedExt);
end;

procedure TEmojiFrm.UpdTmrTimer(Sender: TObject);
begin
  if GetForegroundWindow <> Self.Handle then
  begin
    Self.Hide;
    UpdTmr.Enabled := False;
  end;
end;

procedure TEmojiFrm.PrevExtExecute(Sender: TObject);
begin
  if openedExt <= Low(emojiExtNumbers) then
    openedExt := High(emojiExtNumbers)
  else
    dec(openedExt);

  RefreshExtBtnStates;
  showEmojiExt(openedExt);
end;

procedure TEmojiFrm.PutEmoji(FExt, FEmoji: Integer);
var
  emojiGrid: TAwImageGrid;
  png: TGraphic;
  cp: String;
  pic: TRnQThemeBitmap;
begin
  png := GetEmoji(FEmoji);
  if not png.Empty then
  begin
    emojiGrid := emojiGrids.Items[FExt];
    if not (emojiGrid = nil) then
    begin
      cp := GetEmojiStr(FEmoji);
      emojiGrid.Items.AddThumb(cp, png);
    end;
  end;
end;

procedure TEmojiFrm.showEmojiExt(ext: Integer);
var
  emojiGrid: TAwImageGrid;
  num: Integer;
begin
  if not emojiGrids.ContainsKey(ext) then
  begin
    emojiGrid := TAwImageGrid.Create(EmojiFrm);
    with emojiGrid do
    begin
      Width := 0;
      Height := 0;
      Parent := EmojiFrm;
      DoubleBuffered := True;
      Align := alClient;
      AlignWithMargins := True;
      Margins.Top := 7;
      Margins.Left := 7;
      Margins.Right := 1;
      Margins.Bottom:= 3;

      AutoHideScrollBar := True;
      BorderStyle := bsNone;
      CellAlignment := taCenter;
      CellLayout := tlCenter;
      InCellMargin := MulDiv(6, currentPPI, cDefaultDPI);
      CellHeight := emojiSize + InCellMargin*2;
//      CellWidth := emojiSize + InCellMargin*2;
      CellWidth := CellHeight;
      CellSpacing := MulDiv(2, currentPPI, cDefaultDPI);
      Color := clBtnFace;
      WheelScrollLines := 1;
      Sorted := False;
      Stretch := True;
      DragScroll := False;
      MarkerStyle := psClear;
      Cursor := crHandPoint;
      Tag := 0;

      OnMouseDown := InvalidateEmoji;
      OnMouseUp := InvalidateEmoji;
      OnClickCell := SendSelectedEmoji;
    end;

  {$IFNDEF USE_MORMOT_COLLECTIONS}
    emojiGrids.AddOrSetValue(ext, emojiGrid);
  {$ELSE USE_MORMOT_COLLECTIONS}
    emojiGrids[ext] := emojiGrid;
  {$ENDIF USE_MORMOT_COLLECTIONS}
    emojiGrid.Items.BeginUpdate;
    for num in GetEmojiCont(ext) do
      PutEmoji(ext, num);
    emojiGrid.Items.EndUpdate;
  end
    else
  emojiGrid := emojiGrids.Items[ext];

  emojiGrid.BringToFront;
  emojiGrid.SetFocus;
  openedExt := ext;
  UpdTmr.Enabled := True;
end;

procedure TEmojiFrm.InvalidateEmoji(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  (Sender as TAwImageGrid).Invalidate;
end;

procedure TEmojiFrm.NextExtExecute(Sender: TObject);
begin
  if openedExt >= High(emojiExtNumbers) then
    openedExt := Low(emojiExtNumbers)
  else
    inc(openedExt);

  RefreshExtBtnStates;
  showEmojiExt(openedExt);
end;

procedure Add2input(const s: String);
begin
  if chatFrm.thisChat.input.Text = '' then
    chatFrm.thisChat.input.SelText := s
  else
    chatFrm.thisChat.input.SelText := ' ' + s;
end;

procedure TEmojiFrm.SendSelectedEmoji(Sender: TCustomImageGrid; Index: Integer);
begin
  Self.Hide;
  GoToChat;
  Add2Input((Sender as TAwImageGrid).FileNames[Index]);
end;


function TEmojiFrm.GetEmoji(num: Integer): TGraphic;
begin
  Result := TRnQThemeBitmap.Create(GetEmojiPicName(num), RQteEmoji);
end;

procedure TEmojiFrm.CreateExtBtns();
var
  i: Integer;
  extBtn: TRnQSpeedButton;
//  png: TGraphic;
begin
  for i := exts.ComponentCount - 1 downto 0 do
    if exts.Components[i] is TRnQSpeedButton then
      if (exts.Components[i] as TRnQSpeedButton).Tag > 0 then
        exts.Components[i].Free;

  for i := 1 to emojiContentsCount do
  begin
    extBtn := TRnQSpeedButton.Create(exts);
    with extBtn do
    begin
      Parent := exts;
      Left := exts.Width;
      Align := alLeft;
      AlignWithMargins := true;
      AllowAllUp := True;
      Flat := True;
      Margins.Bottom := MulDiv(5, currentPPI, cDefaultDPI);
      Margins.Left := Margins.Bottom;
      Margins.Right := 0;
      Margins.Top := Margins.Bottom;
      Spacing := 0;
//      VerticalOffset := 0;
      Transparent := True;
      Width := emojiSize + Margins.Bottom + Margins.Bottom;
      ImageName := TE2Str[RQteEmoji] + GetEmojiPicName(emojiExtNumbers[i]);
{
      try
        png := GetEmoji(emojiExtNumbers[i]);
        Glyph.Assign(png);
        png.Free;
      except end;
}
      Tag := i;
      OnClick := OnExtBtnClick;
      Cursor := crHandPoint;
      Hint := GetTranslation(emojiExtHints[i]);
      ShowHint := false;
      RefreshExtBtnStates;
    end;
  end;
end;

constructor TEmojiFrm.Create(parent: TWinControl);
begin
  parentWnd := parent;
  Inherited Create(TComponent(NIL));
end;

procedure TEmojiFrm.FormCreate(Sender: TObject);
begin
//  parentWnd := Sender As TWinControl;
  {$IFNDEF USE_MORMOT_COLLECTIONS}
  emojiGrids := TDictionary<Integer, TAwImageGrid>.Create;
  {$ELSE USE_MORMOT_COLLECTIONS}
  emojiGrids := Collections.NewKeyValue<Integer, TAwImageGrid>;
  {$ENDIF USE_MORMOT_COLLECTIONS}

  CreateExtBtns;
end;

procedure TEmojiFrm.FormHide(Sender: TObject);
var
  {$IFNDEF USE_MORMOT_COLLECTIONS}
  pair: TPair<Integer, TAwImageGrid>;
  {$ELSE USE_MORMOT_COLLECTIONS}
  oeVal: TAwImageGrid;
  {$ENDIF USE_MORMOT_COLLECTIONS}
begin
 {$IFNDEF USE_MORMOT_COLLECTIONS}
  for pair in emojiGrids do
  if Assigned(pair.Value) then
  if not (pair.Key = openedExt) then
  begin
    pair.Value.Free;
    emojiGrids.Remove(pair.Key);
  end;
 {$ELSE USE_MORMOT_COLLECTIONS}
//  if not emojiGrids.TryGetValue(openedExt, oeVal) then
//    oeVal := NIL;
//  emojiGrids.Clear;
//  if oeVal <> NIL then
//    emojiGrids.Add(openedExt, oeVal);
 {$ENDIF USE_MORMOT_COLLECTIONS}
end;

procedure TEmojiFrm.OnExtBtnClick(Sender: TObject);
begin
  showEmojiExt((Sender as TRnqSpeedButton).Tag);
  RefreshExtBtnStates;
end;

procedure TEmojiFrm.RefreshExtBtnStates;
var
  i: Integer;
  btn: TRnQSpeedButton;
begin
  for i := exts.ComponentCount - 1 downto 0 do
    if exts.Components[i] is TRnQSpeedButton then
    begin
      btn := exts.Components[i] as TRnQSpeedButton;
      if btn.Tag = openedExt then
        btn.FState := bsExclusive
      else
        btn.FState := bsUp;
      btn.Invalidate;
    end;
end;

procedure TEmojiFrm.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  Index: Integer;
begin
  case key of
    VK_ESCAPE:
    begin
      Self.Hide;
      GoToChat;
    end;
    VK_RETURN, VK_SPACE:
    begin
      Index := emojiGrids.Items[openedExt].ItemIndex;
      if (Index >= 0) and (Index < emojiGrids.Items[openedExt].Count) then
      begin
        Self.Hide;
        GoToChat;
        Add2input(emojiGrids.Items[openedExt].FileNames[Index]);
      end;
    end;
  end;
end;

procedure TEmojiFrm.FormPaint(Sender: TObject);
var
  DC: HDC;
  Rgn: HRGN;
  brF: HBRUSH;
begin
  inherited;
  DC := GetDCEx(Handle, 0, DCX_PARENTCLIP);
  Rgn := CreateRectRgn(ClientRect.Left, ClientRect.Top, ClientRect.Right, ClientRect.Bottom);
  SelectClipRgn(DC, Rgn);
  DeleteObject(Rgn);

  SelectObject(DC, GetStockObject(DC_BRUSH));

  brF := CreateSolidBrush(ColorToRGB(clSilver));
  FrameRect(Canvas.Handle, Rect(0, 0, EmojiFrm.Width, EmojiFrm.Height), brF);
  FrameRect(Canvas.Handle, Rect(0, 0, EmojiFrm.Width, exts.Height + 2), brF);
  DeleteObject(brF);

  ReleaseDC(Handle, DC);
end;

procedure ShowEmojiMenu(rnqcon: TRnQContact; parent: TWinControl; t: tpoint);
var
  ar: array[1..4] of TRect;
  scr, intr, a: Trect;
  i, p1, p2: integer;
  tmp: String;
  m: TMonitor;
begin

  try
//    EmojiSprite := TPNGImage.Create;
//    if theme.GetOrigPic(RQteDefault, 'emojisprite', mem) then
    if theme.PicExists(RQteDefault, TPicName('emoji.sprite')) then
    begin
//      EmojiSprite.LoadFromStream(mem);
//      mem.Free;
    end
      else
    begin
      msgDlg('Emoji image cannot be found in current smiles file', True, mtError);
      Exit;
    end;

    tmp := theme.GetString('emoji.size');
    if not (tmp = '') then
      emojiSize := StrToInt(tmp);
  except end;


  m := Screen.MonitorFromPoint(t);

  scr := m.WorkareaRect;

  emojiSize := MulDiv( emojiSize, m.PixelsPerInch, cDefaultDPI);

  if not Assigned(EmojiFrm) then
    EmojiFrm := TEmojiFrm.Create(parent);
  EmojiFrm.parentWnd := parent;

  EmojiFrm.Height := (emojiSize + MulDiv(10 + 10, m.PixelsPerInch, cDefaultDPI)) * 5 + EmojiFrm.exts.Height;
  EmojiFrm.Width := (emojiSize + MulDiv(10 + 6, m.PixelsPerInch, cDefaultDPI)) * emojiContentsCount;

  ar[1] := Rect(t.X, t.Y - EmojiFrm.Height, t.X + EmojiFrm.Width, t.Y);
  ar[2] := Rect(t.X - EmojiFrm.Width, t.Y - EmojiFrm.Height, t.X, t.Y);
  ar[3] := Rect(t.X, t.Y, t.X + EmojiFrm.Width, t.Y + EmojiFrm.Height);
  ar[4] := Rect(t.X - EmojiFrm.Width, t.Y, t.X, t.Y + EmojiFrm.Height);
  a := Rect(0, 0, 0, 0);

  for i := 1 to 4 do
  begin
    Types.IntersectRect(intr, ar[i], scr);
    p1 := (intr.Right - intr.Left) * (intr.Bottom - intr.Top);
    p2 := (a.Right - a.Left) * (a.Bottom - a.Top);
    if p1 > p2 then
    begin
      a := intr;
      EmojiFrm.Top := ar[i].Top;
      EmojiFrm.Left := ar[i].Left;
    end;
  end;
  EmojiFrm.rnqContact := rnqcon;

  EmojiFrm.Show;
end;

end.
