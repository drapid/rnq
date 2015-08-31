unit MRAStatusForm;
{$I Compilers.inc}
{$I RnQConfig.inc}

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
 ExtCtrls, RnQButtons, StdCtrls,
 MRAv1,
 GlobalLib, ComCtrls;

type
  TMRAStatusForm = class(TForm)
    xStatusName: TEdit;
    Bevel1: TBevel;
    XStatusStrMemo: TMemo;
    xSetButton: TRnQButton;
    SBar: TStatusBar;
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure xSetButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure XStatusStrMemoChange(Sender: TObject);
  private
    procedure ChoosingX(Sender:TObject);
    procedure DblClk(Sender:TObject);
    { Private declarations }
  public
    { Public declarations }
    thisPrt : TMRASession;
    procedure ShowNear(mra : TMRASession; mR: TRect; X, Y: Integer);
  end;

var
  xMRAStatusForm: TMRAStatusForm;
//  xStatusbuttons: array [low(aXStatus)..High(aXStatus)] of TRnQSpeedButton;
//  xStatusbuttons: array [low(XStatus6)..High(XStatus6)] of TRnQSpeedButton;
//  xStatus6buttons: array [0..XStatus6Count-1] of TRnQSpeedButton;
  xStatusbuttons: array of TRnQSpeedButton;
  tempStatus:byte;

implementation

uses mainDlg, RnQLangs, utilLib, MRA_proto;

{$R *.dfm}

procedure TMRAStatusForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if ModalResult = mrOk then
   begin
//    RnQmain.sBar.Repaint;
    RnQmain.PntBar.Repaint;
    if thisPrt.isOnline then
//      icq.setStatusStr(ExtStsStrings[icq.curXStatus], xStatus6[icq.curXStatus].pid);
      thisPrt.setStatusStr(thisPrt.curXStatus.id, MRAExtStsStrings[thisPrt.curXStatus.idx]);
//      icq.sendCapabilities;
   end;
  saveListsDelayed := True;
//  SaveExtSts;
end;

procedure TMRAStatusForm.FormCreate(Sender: TObject);
const
  BtnsInRow = 8;
var
  x, k   : integer;
  curBtn : TRnQSpeedButton;
begin
//  for i:=low(aXStatus) to High(aXStatus) do
//  for i:=low(XStatus6) to High(XStatus6) do
  for x:=low(MRAXStatusArray) to High(MRAXStatusArray) do
//  if xsf_6 in MRAXStatusArray[x].flags then
  begin
    k := Length(xStatusButtons);
    curBtn := TRnQSpeedButton.create(Bevel1);
    with curBtn do
    begin
      parent := self;
      height := 21;
      width  := 22;
      top    := 40+24*((k) div BtnsInRow);
      left   := 12+29*((k) mod BtnsInRow);
      GroupIndex := 1;
      Flat   := true;
//      ImageName  := MRAXStatusArray[x].PicName;
      ImageName  := 'mra.'+MRAXStatusArray[x];
//      Glyph  := aXStatus[i].PicName;
//      Hint   := '';//MRAXStatusArray[x].Caption;
      Hint   := MRAXStatusArray[x];
      HelpKeyword := MRAXStatusArray[x];
      ShowHint := True;
      Tag    := x;
      OnClick:=choosingX;
      OnDblClick := DblClk;
    end;
    SetLength(xStatusButtons, k+1);
    xStatusButtons[k] := curBtn;
//    curBtn := NIL;
  end;
  bevel1.Width:=2+BtnsInRow*21+(BtnsInRow-1)*9;
//  bevel1.height:=8+(((High(aXStatus)-1) div BtnsInRow)+1)*21+((High(aXStatus)-1) div BtnsInRow)*3;
  bevel1.height:=8+(round((High(xStatusButtons)+1) / BtnsInRow + 0.5))*(21+3);
  width:=bevel1.Width+22;
  XStatusStrMemo.Top := bevel1.Top + bevel1.height + 5;
  XStatusStrMemo.Height := 60;
  XStatusStrMemo.Width  := bevel1.Width;
  ClientHeight      := {Bevel1.Top + bevel1.Height+10}
                        XStatusStrMemo.Top + XStatusStrMemo.Height+6 +
                        SBar.Height ;

  xSetButton.Left   := bevel1.Left+bevel1.Width-xsetbutton.Width;
  xStatusName.Width := xsetbutton.Left-xStatusName.Left-5;

{  xStatusName.Visible := False;
  xSetButton.Left := XStatusStrMemo.Left;
  xSetButton.Width := XStatusStrMemo.Width;
}
     xStatusName.Visible := True;
     xsetbutton.Width  := 80;
     xSetButton.Left   := bevel1.Left+bevel1.Width-xsetbutton.Width;
     xStatusName.Width := xsetbutton.Left-xStatusName.Left-5;
end;

procedure TMRAStatusForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
//  if key = VK_RETURN then
//    xSetButtonClick(sender)
//  else
    if key = VK_ESCAPE then
      close;
end;

procedure TMRAStatusForm.FormShow(Sender: TObject);
var
//  i:integer;
  btn : TRnQSpeedButton;
begin
  for btn in xStatusButtons do
    if thisPrt.curXStatus.idx = btn.Tag then
      btn.down:=true;
  tempStatus := thisPrt.curXStatus.idx;

//    xstatusname.text:=curXStatusStr;
//    XStatusStrMemo.Text := curXStatusDesc;
  xstatusname.text := MRAExtStsStrings[tempStatus].Cap;
  XStatusStrMemo.Text := MRAExtStsStrings[tempStatus].Desc;
  XStatusStrMemoChange(XStatusStrMemo);
end;

procedure TMRAStatusForm.xSetButtonClick(Sender: TObject);
begin
//  curXStatusStr  := xstatusName.Text;
  thisPrt.curXStatus.idx  := tempStatus;
//  curXStatusDesc := XStatusStrMemo.Text;
  thisPrt.curXStatus.id := MRAXStatusArray[tempStatus];
  if xstatusname.text <> MRAExtStsStrings[tempStatus].Cap then
    MRAExtStsStrings[tempStatus].Cap  := Copy(xstatusname.text, 1, MaxXStatusLen);
  if XStatusStrMemo.Text <> MRAExtStsStrings[tempStatus].Desc then
    MRAExtStsStrings[tempStatus].Desc := Copy(XStatusStrMemo.Text, 1, MaxXStatusDescLen);

//  ChangeXStatus(tempStatus, xstatusname.text, XStatusStrMemo.Text);
  self.ModalResult:=mrOK;
end;

procedure TMRAStatusForm.XStatusStrMemoChange(Sender: TObject);
var
  s : AnsiString;
begin
  sbar.panels[0].text:=getTranslation('Chars:')+' '+intToStr(length(XStatusStrMemo.Text));
  s := AnsiToUtf8(XStatusStrMemo.Text);
  sbar.panels[1].text:=getTranslation('left:')+' '+intToStr(250 - length(s));
end;

procedure TMRAStatusForm.DblClk(Sender:TObject);
begin
  choosingX(sender);
  xSetButtonClick(NIL);
//  self.ModalResult:=mrOK;
end;

procedure TMRAStatusForm.choosingX(sender:TObject);
begin
//  if tempStatus <> TRnQSpeedButton(Sender).tag then
  if xstatusname.text <> MRAExtStsStrings[tempStatus].Cap then
    MRAExtStsStrings[tempStatus].Cap  := Copy(xstatusname.text, 1, MaxXStatusLen);
  if XStatusStrMemo.Text <> MRAExtStsStrings[tempStatus].Desc then
    MRAExtStsStrings[tempStatus].Desc := Copy(XStatusStrMemo.Text, 1, MaxXStatusDescLen);

  tempStatus:=TRnQSpeedButton(Sender).tag;
//  if tempStatus <> curXStatus then
   begin
//    xstatusname.text := getTranslation(aXStatus[tempStatus].Caption);
    xstatusname.text := MRAExtStsStrings[tempStatus].Cap;
    XStatusStrMemo.Clear;
    XStatusStrMemo.Text := MRAExtStsStrings[tempStatus].Desc;
   end
{  else
   begin
    xstatusname.text := curXStatusStr;
    XStatusStrMemo.Text := curXStatusDesc;
   end}
end;

procedure TMRAStatusForm.ShowNear(mra : TMRASession; mR: TRect; X, Y: Integer);
var
  MonRect : TRect;
  P : TPoint;
begin
  P.X := X;
  P.Y := Y;
  thisPrt := mra;
  MonRect := Screen.MonitorFromPoint(P).WorkareaRect;
  if roasterbarOnTop then
    begin
      if mR.Top - self.Height < MonRect.Top then
       begin
        self.Top :=  mR.Top;
        if (mR.Left - self.Width) < MonRect.Left then
          self.Left := mR.Right
        else
          self.Left := mR.Left - self.Width;
       end
      else
       begin
        self.Top :=  mR.Top - self.Height;
        if (mR.Left + self.Width) > MonRect.Right then
         self.Left := MonRect.Right - self.Width
        else
         self.Left := mR.Left;
       end;
    end
    else
    begin
      if mR.Bottom + self.Height > MonRect.Bottom then
       begin
        self.Top :=  mR.Bottom - self.Height;
        if (mR.Left - self.Width) < MonRect.Left then
          if (mR.Right + self.Width) < MonRect.Right then
            self.Left := mR.Right// + self.Width
           else
            self.Left := mR.Right - self.Width
         else
          self.Left := mR.Left - self.Width;
       end
      else
       begin
        self.Top :=  mR.Bottom;
        if (mR.Left + self.Width) > MonRect.Right then
          self.Left := MonRect.Right - self.Width
        else
          self.Left := mR.Left;
       end;
    end;
    try
//      Self.
      if not Visible then
        ShowModal
       else
        Show;
    except

    end;
end;

end.
