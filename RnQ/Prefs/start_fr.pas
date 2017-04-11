{
This file is part of R&Q.
Under same license
}
unit start_fr;
{$I RnQConfig.inc}
{$I NoRTTI.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  StdCtrls, ComCtrls, ExtCtrls, RnQButtons, RDGlobal, RnQPrefsLib;

type
  TstartFr = class(TPrefFrame)
    Pages: TPageControl;
    MainTab: TTabSheet;
    autoconnectChk: TCheckBox;
    splashChk: TCheckBox;
    readonlyChk: TCheckBox;
    minimizedChk: TCheckBox;
    lockonstartChk: TCheckBox;
    getofflinemsgsChk: TCheckBox;
    delofflinemsgsChk: TCheckBox;
    reopenchatsChk: TCheckBox;
    Label13: TLabel;
    autostart1: TEdit;
    Label24: TLabel;
    startingStatusBox: TComboBox;
    laststatus1: TCheckBox;
    Label25: TLabel;
    startingVisibilityBox: TComboBox;
    userspathBox: TLabeledEdit;
    CurUINBtn: TRnQButton;
    procedure Button1Click(Sender: TObject);
    procedure startingStatusBoxDrawItem(Control: TWinControl;
      Index: Integer; Rect: TRect; State: TOwnerDrawState);
    procedure startingVisibilityBoxDrawItem(Control: TWinControl;
      Index: Integer; Rect: TRect; State: TOwnerDrawState);
    procedure startingStatusBoxMeasureItem(Control: TWinControl; Index: Integer;
      var Height: Integer);
    procedure startingVisibilityBoxMeasureItem(Control: TWinControl;
      Index: Integer; var Height: Integer);
  private
    { Private declarations }
  public
    procedure initPage; Override; final;
    procedure applyPage; Override; final;
    procedure resetPage; Override; final;
//    procedure updateVisible;
    { Public declarations }
  end;

implementation

uses
  RnQProtocol,
  utilLib, RQUtil, menusUnit, RnQLangs,
  math, RnQConst, globalLib,
  RnQGraphics32, RQThemes;

{$R *.dfm}

const
  UseLastSts =  'Use last set status';

procedure TstartFr.Button1Click(Sender: TObject);
begin autostart1.text := Account.AccProto.ProtoElem.MyAccNum end;

procedure TstartFr.startingStatusBoxDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  cnv: Tcanvas;
  st: Int8;
  gR: TGPRect;
  s, s1: String;
  ch: Char;
begin
  cnv := startingstatusbox.canvas;
  cnv.fillrect(rect);
  gr.x := 2+rect.left;
  gr.y := rect.top;
  s1 := startingstatusBox.Items[index];
  if s1 > '' then
    begin
      ch := s1[1];
      if ch >= '0' then
        st := (Int16(ch) - Int16('0'))
       else
        st := -1;
    end
   else
    st := -1;
//  st:= byte(startingstatusBox.items.objects[index]) - 1;
//inc(x, 2+Theme.drawPic(cnv.Handle, x,y,status2imgName(st)).cx);
//cnv.textout(x,y, statusNameExt2(st));
//  if st <=  then
  if st < 0 then
    begin
      s := getTranslation(UseLastSts);
      inc(Rect.Left, 2);
    end
   else
    with Account.AccProto.getStatuses[st] do
     begin
      with theme.GetPicSize(RQteDefault, ImageName) do
       begin
        gr.Height := min(Rect.Bottom - Rect.Top, cy);
        gr.Width  := min(Rect.Right - Rect.Left, cx);
       end;
      inc(gr.x, 2+theme.drawPic(cnv.Handle, gr,ImageName).cx);
      Rect.Left := gr.x;
      s := getTranslation(Cptn);
  //    cnv.textout(gr.x, gr.y, s);
     end;
  DrawText(cnv.Handle, PChar(s), Length(s), Rect, DT_SINGLELINE or DT_VCENTER);
end;

procedure TstartFr.startingStatusBoxMeasureItem(Control: TWinControl;
  Index: Integer; var Height: Integer);
var
  st: Int8;
  ch: Char;
begin
  Height := 20;
  if (index >=0) and (startingstatusBox.items.Count >= index) then
   begin
    ch := startingstatusBox.items[index][1];
    if ch >= '0' then
      st := (Word(ch) - Word('0'))
     else
      st := -1;
    if st >= 0 then
     with Account.AccProto.getStatuses[st] do
      begin
       Height := max(theme.GetPicSize(RQteDefault, ImageName).cy+2, 20);
      end;
   end
end;

procedure TstartFr.startingVisibilityBoxDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  cnv:Tcanvas;
  st: byte;
  gR: TGPRect;
  s: String;
  visArr: TStatusArray;
begin
  cnv := startingvisibilitybox.canvas;
  gr.x := 2+rect.left;
  gr.y := rect.top;
  st := byte(TComboBox(Control).items.objects[index]);
  cnv.fillrect(rect);
  visArr := Account.AccProto.getVisibilitis;
  if Assigned(visArr) then
   with visArr[st] do
   begin
    with theme.GetPicSize(RQteDefault, ImageName) do
     begin
      gr.Height := min(Rect.Bottom - Rect.Top, cy);
      gr.Width  := min(Rect.Right - Rect.Left, cx);
     end;
    inc(gr.x, 2+theme.drawPic(cnv.Handle, gr,ImageName).cx);
    Rect.Left := gr.x;
    s := getTranslation(Cptn);
//    cnv.textout(gr.x, gr.y, s);
    DrawText(cnv.Handle, PChar(s), Length(s), Rect, DT_SINGLELINE or DT_VCENTER);
   end;
{
vi:=Tvisibility(startingvisibilityBox.items.objects[index]);
inc(x, 2+theme.drawPic(cnv.Handle, x,y,visibility2imgName[vi]).cx);
cnv.textout(x,y,visibilityName(vi));}
end;

procedure TstartFr.startingVisibilityBoxMeasureItem(Control: TWinControl;
  Index: Integer; var Height: Integer);
var
  st: byte;
  visArr: TStatusArray;
begin
  if (index >=0) and (TComboBox(Control).items.Count >= index) then
   begin
    st := byte(TComboBox(Control).items.objects[index]);
    visArr := Account.AccProto.getVisibilitis;
    if Assigned(visArr) then
     with visArr[st] do
      begin
       Height := max(theme.GetPicSize(RQteDefault, ImageName).cy+2, 20);
      end;
   end
end;

procedure TstartFr.initPage;
var
//  st: byte;
  b: Byte;
  ch: Char;
//  vi: Tvisibility;
begin
  startingStatusBox.Items.Add(' '); // Last used status
  for b in Account.AccProto.getStatusMenu do
   begin
    ch := Chr(Byte('0')+byte(b));
    startingStatusBox.Items.Add(Ch);
   end;
  startingVisibilityBox.Items.Clear();
//  for vi:=low(vi) to high(vi) do
//  for vi in visiMenu do
//    startingVisibilityBox.Items.AddObject('',Tobject(vi));
  for b in Account.AccProto.getVisMenu do
   begin
    ch := Chr(Byte('0')+byte(b));
    startingVisibilityBox.Items.AddObject(ch,Tobject(b));
   end;
//  startingVisibilityBox.DropDownCount := 16;

  autostart1.top :=  reopenchatsChk.boundsrect.bottom + GAP_SIZE;
  Label13.top := autostart1.top + 4;
  CurUINBtn.top := autostart1.top - 2;
  CurUINBtn.left := MainTab.Width - GAP_SIZE - CurUINBtn.width;
  autostart1.width := CurUINBtn.left - autostart1.left - GAP_SIZE;

  startingStatusBox.top :=  autostart1.boundsrect.bottom + GAP_SIZE2;
  startingStatusBox.width := MainTab.Width - GAP_SIZE - startingStatusBox.left;

  Label24.top := startingStatusBox.top + 4;
  laststatus1.top :=  startingStatusBox.boundsrect.bottom + GAP_SIZE;

  startingVisibilityBox.top :=  laststatus1.boundsrect.bottom + GAP_SIZE;
  startingVisibilityBox.width := startingStatusBox.width;

  Label25.top := startingVisibilityBox.top + 4;

  userspathBox.top :=  startingVisibilityBox.boundsrect.bottom + GAP_SIZE2 + userspathBox.editlabel.height;
  userspathBox.left := GAP_SIZE;
  userspathBox.width := MainTab.Width - GAP_SIZE2;
end;

procedure TstartFr.applyPage;
var
  ch: Char;
//  i, code: integer;
begin
  userspath := userspathBox.text;
  reopenchats := reopenchatsChk.checked;
  getofflinemsgs := getofflinemsgsChk.checked;
  delofflinemsgs := delofflinemsgsChk.checked;
  check4readonly := readonlyChk.checked;
  autostartUIN := autostart1.text;
{  if Assigned(Account.AccProto) then
//   if not Account.AccProto.ProtoElem._isValidUid(autostartUIN) then
   if not Account.AccProto.ValidUid1(autostartUIN) then
//  if not TicqSession._isValidUid(autostartUIN) then
//
//  val(autostart1.text,i,code);
//  if (code=0) and validUIN(autostart1.text) then
//    autostartUIN:=autostart1.text
//  else
    autostartUIN := '';
}
  startMinimized := minimizedChk.checked;
  skipSplash := splashChk.checked;
  autoconnect := autoconnectChk.checked;
  with startingstatusBox do
   begin
    if itemIndex = 0  then
      RnQstartingStatus:= -1
     else
      if itemIndex >= 0 then
       begin
        ch := items[itemIndex][1];
        if ch >= '0' then
          RnQstartingStatus:= Word(ch) - Word('0')
         else
          RnQstartingStatus:= -1;
       end;
   end;
  with startingVisibilityBox do
   if itemIndex >= 0 then
     RnQstartingVisibility := Byte(items.objects[itemIndex]);
  uselastStatus := laststatus1.checked;
  lockOnStart := lockOnStartChk.checked;
end;


procedure TstartFr.resetPage;
  procedure placeComboBox(cb: TcomboBox; val: Int8);
  var
    i: integer;
  begin
   for i:=0 to cb.items.count-1 do
//    if cb.items.objects[i] = obj then
    if ((val >=0) and (cb.items[i] >= '0') and ((Word(cb.items[i][1]) - Word('0')) = val))
       or ((val <0) and (cb.items[i] < '0')) then
     begin
      cb.itemindex := i;
      exit;
     end;
   cb.itemIndex := -1;
  end; // placeComboBox
begin

  userspathBox.text := userspath;
  reopenchatsChk.checked := reopenchats;
  getofflinemsgsChk.checked := getofflinemsgs;
  delofflinemsgsChk.checked := delofflinemsgs;
  readonlyChk.checked := check4readonly;
  if autostartUIN = '' then
    autostart1.text := ''
  else
    autostart1.text := autostartUIN;
  minimizedChk.checked := startMinimized;
  autoconnectChk.checked := autoconnect;
//  placeComboBox(startingStatusBox, Tobject(RnQstartingstatus));
//  placeComboBox(startingvisibilityBox, Tobject(RnQstartingvisibility));
  placeComboBox(startingStatusBox, RnQstartingstatus);
  placeComboBox(startingvisibilityBox, RnQstartingvisibility);
  lastStatus1.checked := uselaststatus;
  splashChk.checked := skipSplash;
  lockOnStartChk.checked := lockOnStart;
end;

end.
