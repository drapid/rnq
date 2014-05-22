{
This file is part of R&Q.
Under same license
}
unit StatusForm;
{$I RnQConfig.inc}

{$IFDEF COMPILER_14_UP}
  {$WEAKLINKRTTI ON}
  {$RTTI EXPLICIT METHODS([]) FIELDS([]) PROPERTIES([])}
{$ENDIF COMPILER_14_UP}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
 ExtCtrls, RnQButtons, StdCtrls,
 RnQProtocol,
 ComCtrls;

type
  TStsBtn = TRnQSpeedButton;

type
  TxStatusForm = class(TForm)
    xStatusName: TEdit;
    Bevel1: TBevel;
    XStatusStrMemo: TMemo;
    xSetButton: TRnQButton;
    SBar: TStatusBar;
    OldxStChk: TCheckBox;
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure xSetButtonClick(Sender: TObject);
    procedure XStatusStrMemoChange(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure OldxStChkClick(Sender: TObject);
  private
    BtnWidth : Integer;
    BtnHeight : Integer;
    thisProto : TRnQProtocol;
    protoIs : Byte;
    xStatusbuttons: array of TStsBtn;
    procedure ChoosingX(Sender:TObject);
    procedure DblClk(Sender:TObject);
    { Private declarations }
    procedure Init;
    procedure SetNameVis;
  public
    { Public declarations }
//    procedure ShowNear(icq : TICQSession; mR: TRect; X, Y: Integer);
    procedure ShowNear(mR: TRect; X, Y: Integer);
//    constructor ShowNear2(owner_ :Tcomponent; proto : IRnQProtocol; mR: TRect; X, Y: Integer);
//    constructor ShowNear2(owner_ :TWinControl; proto : IRnQProtocol; mR: TRect; X, Y: Integer);
    class procedure ShowNear2(owner_ :TWinControl; const proto : TRnQProtocol; mR: TRect; X, Y: Integer);
  end;

  function OpenedXStForm : Boolean;

var
//  xStatusForm: TxStatusForm;
//  xStatusbuttons: array [low(aXStatus)..High(aXStatus)] of TStsBtn;
//  xStatusbuttons: array [low(XStatus6)..High(XStatus6)] of TStsBtn;
//  xStatus6buttons: array [0..XStatus6Count-1] of TStsBtn;
  tempStatus:byte;

implementation

uses
  Types,
  RDGlobal, RDUtils, RnQLangs, RQThemes, RnQGraphics32,
  utilLib, langLib, GlobalLib,
  ICQConsts, Protocol_ICQ, icqv9,
 {$IFDEF PROTOCOL_MRA}
     MRAv1, MRA_proto,
 {$ENDIF PROTOCOL_MRA}
     mainDlg;

{$R *.dfm}

procedure TxStatusForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
{
  if ModalResult = mrOk then
   begin
//    RnQmain.sBar.Repaint;
    RnQmain.PntBar.Repaint;
    if thisProto.isOnline then
      if thisProto.ProtoElem is TicqSession then
//      icq.setStatusStr(ExtStsStrings[icq.curXStatus], xStatus6[icq.curXStatus].pid);
//      thisICQ.setStatusStr(ExtStsStrings[thisICQ.curXStatus], XStatusArray[thisICQ.curXStatus].pid6);
//      if UseOldXSt then
        ChangeXStatus(TicqSession(thisProto.ProtoElem), tempStatus, xstatusname.text, XStatusStrMemo.Text)
//       else
//        thisICQ.setStatusStr(thisICQ.curXStatus, ExtStsStrings[thisICQ.curXStatus]);
//      icq.sendCapabilities;
      else if thisProto.ProtoElem is TMRASession then
        with TMRASession(thisProto.ProtoElem) do
          setStatusStr(curXStatus.id, MRAExtStsStrings[curXStatus.idx]);
   end;
}
  saveListsDelayed := True;
  if Assigned(childWindows) then
    childWindows.remove(self);
  Action := caFree;
//  SaveExtSts;
end;

procedure TxStatusForm.SetNameVis;
begin
 {$IFDEF ICQ_OLD_STATUS}
//  if pVis then
{  if (protoIs = IS_ICQ) and (thisUseOldXSt) then
    begin
     xStatusName.Visible := True;
     xsetbutton.Width  := 80;
     xSetButton.Left   := bevel1.Left+bevel1.Width-xsetbutton.Width;
     xStatusName.Width := xsetbutton.Left-xStatusName.Left-5;
    end
   else}
 {$ENDIF ICQ_OLD_STATUS}
   begin
    xStatusName.Visible := False;
    xSetButton.Left  := XStatusStrMemo.Left;
    xSetButton.Width := XStatusStrMemo.Width;
    xSetButton.Anchors := [akRight, akTop, akLeft];
   end
end;

procedure TxStatusForm.Init;
const
 {$IFDEF ICQ_OLD_STATUS}
  BtnsInRow = 8;
 {$ELSE}
  BtnsInRow = 7;
 {$ENDIF ICQ_OLD_STATUS}
  procedure addBtn(x : Integer);
  var
    k   : integer;
    curBtn : TStsBtn;
  begin
    k := Length(xStatusButtons);
    curBtn := TStsBtn.create(Bevel1);
    with curBtn do
    begin
      parent := self;
      height := BtnHeight;
      width  := BtnWidth;
      top    := Bevel1.Top + 8 +(BtnHeight+3)*((k) div BtnsInRow);
      left   := Bevel1.Left + 5 +(BtnWidth+4)*((k) mod BtnsInRow);
      GroupIndex := 1;
      Flat   := true;
      if protoIs = ICQProtoID then
        begin
          ImageName  := XStatusArray[x].PicName;
    //      Glyph  := aXStatus[i].PicName;
          Hint   := XStatusArray[x].Caption;
    {$IFDEF ICQ_OLD_STATUS}
//          Enabled := (not lastUseOldXSt and (xsf_6 in XStatusArray[x].flags))
//                        or (lastUseOldXSt and (xsf_Old in XStatusArray[x].flags));
//          Enabled := (not thisUseOldXSt and (xsf_6 in XStatusArray[x].flags))
//                        or (thisUseOldXSt and (xsf_Old in XStatusArray[x].flags));
          Enabled := True;
          Visible := Enabled;
    {$ENDIF ICQ_OLD_STATUS}
        end
 {$IFDEF PROTOCOL_MRA}
       else
      if protoIs = IS_MRA then
        begin
          ImageName  := 'mra.'+MRAXStatusArray[x];
          Hint   := MRAXStatusArray[x];
          HelpKeyword := Hint;
        end
 {$ENDIF PROTOCOL_MRA}
      ;
      ShowHint := True;
      Tag    := x;
      OnClick := choosingX;
      OnDblClick := DblClk;
    end;
    SetLength(xStatusButtons, k+1);
    xStatusButtons[k] := curBtn;
  end;
var
  x : integer;
 {$IFDEF ICQ_OLD_STATUS}
  nf : TNotifyEvent;
 {$ENDIF ICQ_OLD_STATUS}
begin
//  childWindows.Add(self);
  with theme.GetPicSize(RQteButton, status2imgName(byte(SC_ONLINE)), icon_size) do
   begin
     BtnHeight := bound(cy, icon_size, 32)+8;
     BtnWidth  := bound(cx, icon_size, 32)+8;
   end;

  if protoIs = ICQProtoID then
    begin
    {$IFDEF ICQ_OLD_STATUS}
{      thisUseOldXSt := UseOldXSt;
      nf := OldxStChk.OnClick;
      OldxStChk.OnClick := NIL;
      OldxStChk.Checked := thisUseOldXSt;
      OldxStChk.OnClick := nf;}
    {$ELSE }
//      OldxStChk.Visible := false;
    {$ENDIF ICQ_OLD_STATUS}
      for x:=low(XStatusArray) to High(XStatusArray) do
//        if xsf_6 in XStatusArray[x].flags then
        if xsf_Old in XStatusArray[x].flags then
          addBtn(x);
    {$IFDEF ICQ_OLD_STATUS}
{       for x:=low(XStatusArray) to High(XStatusArray) do
        if not (xsf_6 in XStatusArray[x].flags) then
          addBtn(x);}
    {$ENDIF ICQ_OLD_STATUS}
    end
 {$IFDEF PROTOCOL_MRA}
   else
  if protoIs = MRAProtoID then
    begin
      OldxStChk.Checked := false;
      for x:=low(MRAXStatusArray) to High(MRAXStatusArray) do
        addBtn(x);
    end
 {$ENDIF PROTOCOL_MRA}
   ;
//  bevel1.height:=8+(((High(aXStatus)-1) div BtnsInRow)+1)*21+((High(aXStatus)-1) div BtnsInRow)*3;
  bevel1.height:=8+(round((High(xStatusButtons)+1) / BtnsInRow + 0.5))*(BtnHeight+3);
  clientwidth:= 22 + 4+BtnsInRow*(BtnWidth+4);
  Bevel1.Width := clientwidth - 16;
//  bevel1.Width+22;
//  bevel1.Width:=4+BtnsInRow*(BtnWidth+4) - 4;
  XStatusStrMemo.Top := bevel1.Top + bevel1.height + 5;
 {$IFDEF ICQ_OLD_STATUS}
{  if (protoIs = IS_ICQ) then
    begin
     OldxStChk.Visible := True;
     XStatusStrMemo.Height := OldxStChk.Top - 6 - XStatusStrMemo.Top;
    end
   else}
 {$ENDIF ICQ_OLD_STATUS}
    begin
     OldxStChk.Visible := False;
     XStatusStrMemo.Height := SBar.Top - 6 - XStatusStrMemo.Top;
    end;
//  XStatusStrMemo.Height := 60;
  XStatusStrMemo.Width  := bevel1.Width;
  ClientHeight      := {Bevel1.Top + bevel1.Height+10}
                        XStatusStrMemo.Top + XStatusStrMemo.Height+6 +
                        SBar.Height ;
  ClientHeight      := XStatusStrMemo.Top + 90;
  Self.Constraints.MinHeight := Height;
  Self.Constraints.MinWidth := width;

  SetNameVis;
end;

procedure TxStatusForm.OldxStChkClick(Sender: TObject);
 {$IFDEF ICQ_OLD_STATUS}
var
  x : integer;
  btn : TStsBtn;
  b : Boolean;
 {$ENDIF ICQ_OLD_STATUS}
begin
 {$IFDEF ICQ_OLD_STATUS}
{  if (protoIs = IS_ICQ) then
   begin
    thisUseOldXSt := not thisUseOldXSt;
    SetNameVis;
    b := False;
      if (not thisUseOldXSt and (xsf_6 in XStatusArray[tempStatus].flags))
              or (thisUseOldXSt and (xsf_Old in XStatusArray[tempStatus].flags)) then
       else
        begin
         b := True;
//         tempStatus := 0;
        end;
    for btn in xStatusButtons do
     begin
      x := btn.Tag;
      if b and (x=0) then
       begin
        btn.down:=true;
        ChoosingX(btn);
       end;
      if not (xsf_6 in XStatusArray[x].flags) then
       begin
        btn.Enabled := //(not thisUseOldXSt and (xsf_6 in XStatusArray[x].flags)) or
                     (thisUseOldXSt and (xsf_Old in XStatusArray[x].flags));
        btn.Visible := btn.Enabled;
       end;
//      if (tempStatus = btn.Tag) and btn.Enabled then
//        btn.down:=true;
     end;
   end;}
 {$ENDIF ICQ_OLD_STATUS}
end;

procedure TxStatusForm.FormDestroy(Sender: TObject);
//var
//  btn : TStsBtn;
begin
//  for btn in xStatusButtons do
//   btn.Free;
  SetLength(xStatusButtons, 0);
end;

procedure TxStatusForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
//  if key = VK_RETURN then
//    xSetButtonClick(sender)
//  else
    if key = VK_ESCAPE then
      close;
end;

procedure TxStatusForm.FormShow(Sender: TObject);
var
//  i:integer;
  btn : TStsBtn;
begin
  tempStatus := thisProto.getXStatus;
  if protoIs = ICQProtoID then
    begin
{      if (not UseOldXSt and (xsf_6 in XStatusArray[tempStatus].flags))
                        or (UseOldXSt and (xsf_Old in XStatusArray[tempStatus].flags)) then
       else
         tempStatus := 0;
}
    {$IFDEF ICQ_OLD_STATUS}
{      if lastUseOldXSt <> UseOldXSt then
        for btn in xStatusButtons do
          begin
            btn.Enabled := (not UseOldXSt and (xsf_6 in XStatusArray[btn.Tag].flags))
                        or (UseOldXSt and (xsf_Old in XStatusArray[btn.Tag].flags));
            btn.Visible := btn.Enabled;
          end;
      lastUseOldXSt := UseOldXSt;
}
    {$ENDIF ICQ_OLD_STATUS}
    end;

  for btn in xStatusButtons do
    if (tempStatus = btn.Tag) and btn.Enabled then
      btn.down:=true;
//    xstatusname.text:=curXStatusStr;
//    XStatusStrMemo.Text := curXStatusDesc;
  xstatusname.text := ExtStsStrings[tempStatus].Cap;
  XStatusStrMemo.Text := ExtStsStrings[tempStatus].Desc;
  XStatusStrMemoChange(XStatusStrMemo);
(*
 {$IFDEF ICQ_OLD_STATUS}
  if (protoIs = IS_ICQ) and (UseOldXSt) then
    begin
     xStatusName.Visible := True;
     xsetbutton.Width  := 80;
     xSetButton.Left   := bevel1.Left+bevel1.Width-xsetbutton.Width;
     xStatusName.Width := xsetbutton.Left-xStatusName.Left-5;
    end
   else
 {$ENDIF ICQ_OLD_STATUS}
   begin
    xStatusName.Visible := False;
    xSetButton.Left := XStatusStrMemo.Left;
    xSetButton.Width := XStatusStrMemo.Width;
   end *)
end;

procedure TxStatusForm.xSetButtonClick(Sender: TObject);
var
  b : Boolean;
begin
//  curXStatusStr  := xstatusName.Text;
//  curXStatusDesc := XStatusStrMemo.Text;
  if protoIs = ICQProtoID then
   begin
{  thisICQ.curXStatus     := tempStatus;

  if xstatusname.text <> ExtStsStrings[tempStatus].Cap then
    ExtStsStrings[tempStatus].Cap  := Copy(xstatusname.text, 1, MaxXStatusLen);
  if XStatusStrMemo.Text <> ExtStsStrings[tempStatus].Desc then
    ExtStsStrings[tempStatus].Desc := Copy(XStatusStrMemo.Text, 1, MaxXStatusDescLen);
}
//    ChangeXStatus(tempStatus, xstatusname.text, XStatusStrMemo.Text);
//     {$IFDEF ICQ_OLD_STATUS}
//       b := UseOldXSt <> thisUseOldXSt;
//       UseOldXSt := thisUseOldXSt;
//     {$ELSE }
       b := False;
//     {$ENDIF ICQ_OLD_STATUS}
     ChangeXStatus(TicqSession(thisProto.ProtoElem), tempStatus, xstatusname.text, XStatusStrMemo.Text, b);
   end
 {$IFDEF PROTOCOL_MRA}
  else
  if protoIs = MRAProtoID then
   begin
//      thisPrt.curXStatus.id := MRAXStatusArray[tempStatus];
      if xstatusname.text <> MRAExtStsStrings[tempStatus].Cap then
        MRAExtStsStrings[tempStatus].Cap  := Copy(xstatusname.text, 1, MaxXStatusLen);
      if XStatusStrMemo.Text <> MRAExtStsStrings[tempStatus].Desc then
        MRAExtStsStrings[tempStatus].Desc := Copy(XStatusStrMemo.Text, 1, MaxXStatusDescLen);
      with TMRASession(thisIProto.ProtoElem) do
       begin
        curXStatus.id := MRAXStatusArray[tempStatus];
        setStatusStr(curXStatus.id, MRAExtStsStrings[curXStatus.idx]);
       end;
     saveCfgDelayed := True;
     RnQmain.PntBar.Repaint;
   end
 {$ENDIF PROTOCOL_MRA}
   ;
  self.ModalResult:=mrOK;
end;

procedure TxStatusForm.XStatusStrMemoChange(Sender: TObject);
var
  s : RawByteString;
begin
  sbar.panels[0].text:=getTranslation('Chars:')+' '+intToStr(length(XStatusStrMemo.Text));
  s := StrToUtf8(XStatusStrMemo.Text);
  sbar.panels[1].text:=getTranslation('left:')+' '+intToStr(250 - length(s));
end;

procedure TxStatusForm.DblClk(Sender:TObject);
begin
  choosingX(sender);
  xSetButtonClick(NIL);
//  self.ModalResult:=mrOK;
end;

procedure TxStatusForm.choosingX(sender:TObject);
begin
//  if tempStatus <> TStsBtn(Sender).tag then
  if protoIs = ICQProtoID then
    begin
      if xstatusname.text <> ExtStsStrings[tempStatus].Cap then
        ExtStsStrings[tempStatus].Cap  := Copy(xstatusname.text, 1, MaxXStatusLen);
      if XStatusStrMemo.Text <> ExtStsStrings[tempStatus].Desc then
        ExtStsStrings[tempStatus].Desc := Copy(XStatusStrMemo.Text, 1, MaxXStatusDescLen);
    end
 {$IFDEF PROTOCOL_MRA}
   else
  if protoIs = IS_MRA then
    begin
      if xstatusname.text <> MRAExtStsStrings[tempStatus].Cap then
        MRAExtStsStrings[tempStatus].Cap  := Copy(xstatusname.text, 1, MaxXStatusLen);
      if XStatusStrMemo.Text <> MRAExtStsStrings[tempStatus].Desc then
        MRAExtStsStrings[tempStatus].Desc := Copy(XStatusStrMemo.Text, 1, MaxXStatusDescLen);
    end
 {$ENDIF PROTOCOL_MRA}
   ;

  tempStatus:=TStsBtn(Sender).tag;
  XStatusStrMemo.Clear;

  if protoIs = ICQProtoID then
    begin
      xstatusname.text := ExtStsStrings[tempStatus].Cap;
      XStatusStrMemo.Text := ExtStsStrings[tempStatus].Desc;
    end
 {$IFDEF PROTOCOL_MRA}
   else
  if protoIs = IS_MRA then
    begin
      xstatusname.text := MRAExtStsStrings[tempStatus].Cap;
      XStatusStrMemo.Text := MRAExtStsStrings[tempStatus].Desc;
    end
 {$ENDIF PROTOCOL_MRA}
   ;
 XStatusStrMemoChange(XStatusStrMemo);
end;

procedure TxStatusForm.ShowNear(mR: TRect; X, Y: Integer);
var
  MonRect : TRect;
  P : TPoint;
begin
  P.X := X;
  P.Y := Y;
  MonRect := Screen.MonitorFromPoint(P).WorkareaRect;
  if rosterbarOnTop then
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
//        Show
       else
        Show;
    except

    end;
end;

//constructor TxStatusForm.ShowNear2(owner_ :Tcomponent; proto : IRnQProtocol; mR: TRect; X, Y: Integer);
//constructor TxStatusForm.ShowNear2(owner_ :TWinControl; proto : IRnQProtocol; mR: TRect; X, Y: Integer);
class Procedure TxStatusForm.ShowNear2(owner_ :TWinControl; const proto : TRnQProtocol; mR: TRect; X, Y: Integer);
var
  xStForm : TxStatusForm;
  curProtoIs : Byte;
begin
  if not Assigned(proto) then
    Exit;
  curProtoIs := proto._getProtoID;


  xStForm := TxStatusForm.Create(owner_);
//  xStForm.Parent :=  owner_;
//  xStForm.ParentWindow := owner_.Handle;
  xStForm.thisProto := proto;
  xStForm.protoIs := curProtoIs;
  xStForm.Init;
  translateWindow(xStForm);
//   xStForm.ShowNear(TicqSession(proto.ProtoElem), mR, x, y);
  childWindows.Add(xStForm);

   xStForm.ShowNear(mR, x, y);
//   xStForm.Free;
end;

function OpenedXStForm : Boolean;
var
  i:integer;
  c : TComponent;
begin
  if Assigned(childWindows) then
  with childWindows do
   begin
    i:=0;
    while i < count do
     begin
      c := items[i];
      if Tobject(c) is TxStatusForm then
       begin
        result:=True;
        exit;
       end;
      inc(i);
     end;
   end;
  result:= False;
end; // OpenedXStForm


end.
