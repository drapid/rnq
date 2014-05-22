{
This file is part of R&Q.
Under same license
}
unit sendfileDlg;
{$I RnQConfig.inc}

{$IFDEF COMPILER_14_UP}
  {$WEAKLINKRTTI ON}
  {$RTTI EXPLICIT METHODS([]) FIELDS([]) PROPERTIES([])}
{$ENDIF COMPILER_14_UP}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  RnQButtons, ExtCtrls, StdCtrls, ComCtrls, VirtualTrees,
  ICQcontacts, ICQv9, RQ_ICQ;

type
  TCalcTime = record
          startTime : TDateTime;
          curBT : byte;
          prevRcvd : Int64;
          bt : array[0..19] of record
            bytes : Int64;
            startTime : TDateTime;
           end;
        end;

type
  TsendfileFrm = class(TForm)
    tree: TVirtualDrawTree;
    P1: TPanel;
    toBox: TLabeledEdit;
    FilesCnt: TLabeledEdit;
    Llog: TLabel;
    msgBox: TMemo;
    LPrg: TLabel;
    FilePrgrs: TProgressBar;
    SrvChk: TCheckBox;
    LocProxyChk: TCheckBox;
    CancelBtn: TRnQButton;
    sBtn: TRnQButton;
    TimePanel: TPanel;
    TimeLEdit: TLabeledEdit;
    TimeLeftLEdit: TLabeledEdit;
    SpeedLEdit: TLabeledEdit;
    T1: TTimer;
    Spl1: TSplitter;
    LPerc: TLabel;
    ClsWinChk: TCheckBox;
    procedure FormResize(Sender: TObject);
    procedure sendBtnClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure treeFreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure treeDrawNode(Sender: TBaseVirtualTree;
      const PaintInfo: TVTPaintInfo);
    procedure SrvChkClick(Sender: TObject);
    procedure CancelBtnClick(Sender: TObject);
    procedure T1Timer(Sender: TObject);
    procedure treeGetNodeWidth(Sender: TBaseVirtualTree; HintCanvas: TCanvas;
      Node: PVirtualNode; Column: TColumnIndex; var NodeWidth: Integer);
    procedure FormCreate(Sender: TObject);
    procedure ClsWinChkClick(Sender: TObject);
  private
    times : TCalcTime;
    function FillFilesTree(files : TstringList) : Integer;
  public
    contact:TICQContact;
//    files:string;
    fileList : TstringList;
    ID: Int64;
    current : Integer;
    fp : TFilePacket;
    fstr  : TFileStream;
    dirct : TICQdirect;
    fSize : Int64;
    sendedSize : Int64;
    Closing : Boolean;
    constructor doAll(owner_ :Tcomponent; contact_:TICQcontact; files_:string);
    procedure doTransfer(dr : TICQdirect);
    procedure doDoneTransfer;
    procedure someData(Sender: TObject; var Data : RawByteString; var IsLast : Boolean);
    procedure senddata(sender:Tobject; bytes:integer);
    procedure CancelTrasfer;
    procedure EndTrasfer;
    procedure Disconnected(Sender: TObject; ErrCode: Word);
    procedure notifFunc(Sender: TObject; ErrCode: Word; msg : String);
    procedure SetPrgrsPos(pos : Integer);
  end;

implementation

{$R *.dfm}
uses
  math, OverbyteIcsWSocket,
  RnQSysUtils, RDFileUtil, RQUtil, RDGlobal, RDUtils,
  RQThemes, RnQLangs, RnQPics,
  globalLib, utilLib, langLib, themesLib,
  Protocol_ICQ;

const
   BufSize = 8192;
type
  PfiItem = ^TfiItem;
  TfiItem = record
     path, fn : String;
     fs : Int64;
  end;

procedure TsendFileFrm.SetPrgrsPos(pos : Integer);
begin
  FilePrgrs.Position := pos;
  FilePrgrs.Hint := intToStr(pos) + '%';
  LPerc.Caption := intToStr(pos) + '%';
  if pos = 100 then
    begin
      LPerc.Caption := 'Done';
      CancelBtn.Caption := getTranslation('Close');
    end;
end;

function TsendFileFrm.FillFilesTree(files : TstringList) : Integer;
var
//  ss:Tstrings;
  i : integer;
  fiItem : PfiItem;
  n : PVirtualNode;
begin
  Result := 0;
//  ss:=TstringList.create;
//  ss.Text:=files;
  tree.Clear;
  tree.BeginUpdate;
  for i:=0 to files.Count-1 do
    begin
      n := tree.AddChild(NIL);
      fiItem := tree.GetNodeData(n);
      fiItem.path := ExtractFilePath(files[i]);
      fiItem.fn := ExtractFileName(files[i]);
      fiItem.fs := sizeOfFile(files[i]);
      inc(result, fiItem.fs);
      n.CheckType := ctCheckBox;
      n.CheckState := csCheckedNormal;
    end;
  tree.EndUpdate;  
end;

constructor TsendFileFrm.doAll(owner_ :Tcomponent; contact_:TICQcontact; files_:string);
begin
  inherited create(owner_);
  position:=poDefaultPosOnly;
  contact:=contact_;
///////////// TEST!!!!!!!!!!!!!!!!
///
//  contact.connection.ft_port := 20000;
//  contact.connection.internal_ip := $7F000001;
///
//////////////////////////////////

  caption:= getTranslation('File transfer to %s', [contact.displayed + ' ('+contact.uin2Show+')']);
  fileList := TstringList.create;
  fp := TFilePacket.Create;
  fileList.Text:=files_;
  if fileList.Count = 1 then
    begin
      FilesCnt.EditLabel.Caption := getTranslation('File');
      FilesCnt.Text := ExtractFileName(fileList[0]) + ' (' + size2str(sizeOfFile(fileList[0])) + ')';
    end
   else
    begin
      FilesCnt.EditLabel.Caption := getTranslation('Total files');
      FilesCnt.Text := IntToStr(fileList.Count) + ' files';
    end;
//  files:=files_;
  tree.NodeDataSize := SizeOf(tfiItem);
  tree.Visible := fileList.Count > 1;
  msgBox.Text := getTranslation('Please receive file');
  Spl1.Visible := tree.Visible;
  if tree.Visible then
    FillFilesTree(fileList)
   else
    Self.Width := Self.Width - tree.Width;
  ClsWinChk.Checked := CloseFTWndAuto;
  SrvChkClick(Self);
  childWindows.Add(self);
  //applyTaskButton(self);
  Theme.pic2ico(RQteFormIcon, PIC_FILE, icon);
  translateWindow(self);
  showForm(self);
  bringForeground:=handle;
  ID:=-1;
  current := 0;
end; // doAll

procedure TsendfileFrm.FormResize(Sender: TObject);
begin
  tree.top:=0;
  tree.left:=msgBox.boundsrect.right+2;
  tree.width:=clientwidth-tree.left;
  tree.height:=clientHeight-tree.top;
end;

procedure TsendfileFrm.sendBtnClick(Sender: TObject);
var
  I: Integer;
  s : String;
begin
//  if not OnlFeature then
//    Exit;
 fstr  := NIL;
 fSize := 0;
  s := msgBox.Text;
  sBtn.enabled:=FALSE;
  if fp.FileList.Count < fileList.Count then
   begin
     for I := 0 to fileList.Count - 1 do
       begin
         fp.AddFile(fileList.Strings[i]);
       end;
   end;
//  msgBox.Lines.Add('ChkSum = ' + IntToHex(fp.CheckSum, 2));
//  ID:=sendICQfiles(contact.uid, fileList.Text, msgBox.Text);
  sendedSize := 0;
  current := 0;
  times.curBT := 0;
  times.prevRcvd := 0;
  for I := Low(times.bt) to High(times.bt) do
    times.bt[i].bytes := 0;

  ID:=sendICQfiles(contact, fp, s, LocProxyChk.Checked, SrvChk.Checked, dirct);

  SrvChk.Enabled := false;
  LocProxyChk.Enabled := False;

//ani.visible:=TRUE;
//ani.active:=TRUE;
//ModalResult := mrOk;
//close;
end;

procedure TsendfileFrm.treeDrawNode(Sender: TBaseVirtualTree;
  const PaintInfo: TVTPaintInfo);
var
  x //,y
   : Integer;
  fiItem : PfiItem;
  oldMode : Integer;
begin
  begin
     if vsSelected in PaintInfo.Node^.States then
       paintinfo.canvas.Font.Color := clHighlightText
      else
       paintinfo.canvas.Font.Color := clWindowText;
     x := PaintInfo.ContentRect.Left;
//     y := 0;
     fiItem := PfiItem(sender.getnodedata(paintinfo.node));
//     inc(x, theme.drawPic(paintinfo.canvas.Handle, x,y+1, IcItem.IconName).cx+2);

     oldMode := SetBKMode(paintinfo.canvas.Handle, TRANSPARENT);
      paintinfo.canvas.textout(x, 2, fiItem.fn);
     SetBKMode(paintinfo.canvas.Handle, oldMode);
  end;
end;

procedure TsendfileFrm.treeFreeNode(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
begin
  with TfiItem(PfiItem(Sender.getnodedata(Node))^) do
   begin
     path := '';
     fn := '';
   end;
end;

procedure TsendfileFrm.treeGetNodeWidth(Sender: TBaseVirtualTree;
  HintCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
  var NodeWidth: Integer);
var
  k : Integer;
  s : string;
  r : TRect;
  res : Tsize;
begin
  k := DT_CALCRECT;
  s := TfiItem(PfiItem(Sender.getnodedata(Node))^).fn;
  r := HintCanvas.ClipRect;
  drawText(HintCanvas.Handle, PChar(s), -1, R, k or DT_SINGLELINE or DT_VCENTER or DT_CENTER);
    GetTextExtentPoint32(HintCanvas.Handle,pchar(s),length(s), res);
  NodeWidth := res.cx + 10;
end;

procedure TsendfileFrm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  childWindows.remove(self);
  Closing := True;
  CancelTrasfer;
//ani.active:=FALSE;
  FreeAndNil(fp);
  action:=caFree;
  destroyHandle;
end;

procedure TsendfileFrm.FormCreate(Sender: TObject);
begin
 fstr  := NIL;
 fSize := 0;
 Closing := False;
end;

procedure TsendfileFrm.FormShow(Sender: TObject);
begin
 if  contact.displayed = contact.UID then
   toBox.Text := contact.uin2Show
  else
   toBox.Text := contact.displayed + ' (' +contact.uin2Show + ')';
// FilesCnt.Text := 1;
 applyTaskButton(self);
end;

procedure TsendfileFrm.CancelBtnClick(Sender: TObject);
begin
  CancelTrasfer;
  close;
end;

procedure TsendfileFrm.CancelTrasfer;
begin
  if Assigned(dirct) then
  begin
    if (ID > 0)and(FilePrgrs.Position < 100) then
     TICQSession(contact.fProto).sendFileAbort(contact, ID);
    EndTrasfer;
  end;
end;

procedure TsendfileFrm.ClsWinChkClick(Sender: TObject);
begin
  CloseFTWndAuto := ClsWinChk.Checked;
end;

procedure TsendfileFrm.EndTrasfer;
begin
  T1.Enabled := false;
  if sendedSize = fSize then
    TimeLeftLEdit.Text := '0'
   else
    TimeLeftLEdit.Text := getTranslation('Canceled');
//  SpeedLEdit.Text := '0';
  if Assigned(dirct) then
   begin
     msgBox.Lines.Add(getTranslation('End transfer'));
     FreeAndNil(dirct);
   end;
  if Assigned(fileList) then
    FreeAndNil(fileList);
  if Assigned(fstr) then
    FreeAndNil(fstr);
  ID := 0;
  if CloseFTWndAuto and not Closing then
    Close;
end;

procedure TsendfileFrm.senddata(sender: Tobject; bytes: integer);
var
  i, l : Integer;
  Data : RawByteString;
//  curPos : Int64;
begin
   if bytes <=0 then Exit;
   if sendedSize = 0 then
    begin
     times.startTime := now;
     times.bt[0].startTime := times.startTime;
     T1.Enabled := True;
    end;
   inc(sendedSize, bytes);
   if fstr.Position < fSize then
    begin
      l := min(BufSize, fSize-fstr.Position);
      l := min(BufSize-TCustomWSocket(sender).BufferedByteCount, l);
      if l > 0 then
       begin
        SetLength(Data, l);
        i := fstr.Read(Data[1], l);
        if i < l then
         SetLength(Data, i);
        TCustomWSocket(sender).PutDataInSendBuffer(@Data[1], i);
       end;
      SetPrgrsPos(100 * sendedSize div fSize);
    end
   else
    if TCustomWSocket(sender).BufferedByteCount = 0 then
    begin
//      SetLength(Data, 0);
      SetPrgrsPos(100);
      EndTrasfer;
    end
     else
      begin
        if fSize > 0 then
          SetPrgrsPos(100 * sendedSize div fSize);
      end;
//   IsLast := fstr.Position = fSize;
   
   ;
end;


procedure TsendfileFrm.someData(Sender: TObject; var Data : RawByteString; var IsLast : Boolean);
var
  i, l : Integer;
  curPos : Int64;
begin
  if Assigned(fstr) then
  begin
   curPos := fstr.Position;
   if curPos < fSize then
    begin
      l := min(BufSize, fSize);
      SetLength(Data, l);
      i := fstr.Read(Data[1], l);
      if i < l then
       SetLength(Data, i);
//       inc(sendedSize, i);
//      inc(curPos, i);
    end
   else
    begin
      SetLength(Data, 0);
      EndTrasfer;
      SetPrgrsPos(100);
    end;
   IsLast := fstr.Position = fSize;

   ;
  end;
end;

procedure TsendfileFrm.SrvChkClick(Sender: TObject);
begin
  if SrvChk.Enabled then
  begin
    LocProxyChk.Enabled := not SrvChk.Checked;
    if SrvChk.Checked then
      LocProxyChk.Checked := True;
  end;
end;

procedure TsendfileFrm.T1Timer(Sender: TObject);
var
  speed, tLeft : Int64;
  b : Int64;
  I, PrevTimeIDX: byte;
  dt : TDateTime;
  ts : Double;
begin
  b := 0;
  times.bt[times.curBT].bytes := sendedSize - times.prevRcvd;
  times.prevRcvd := sendedSize;
  if times.curBT = High(times.bt) then
    times.curBT := Low(times.bt)
   else
    inc(times.curBT);
  for I := Low(times.bt) to High(times.bt) do
    inc(b, times.bt[i].bytes);
  if (times.bt[Low(times.bt)].StartTime = times.startTime) then
    PrevTimeIDX := Low(times.bt)
   else
    PrevTimeIDX := times.curBT;
 dt := times.bt[PrevTimeIDX].StartTime;
 times.bt[times.curBT].StartTime := now;
 ts := (times.bt[times.curBT].StartTime - dt);
 if ts > 0 then
  begin
   speed := round(b /(ts*SecsPerDay));
   if speed > 1024 then
     SpeedLEdit.Text := FloatToStr(round(100*(speed / 1024)) /100) + ' KB/sec'
    else
     SpeedLEdit.Text := intToStr(speed) + ' Bytes/sec';
  end
 else
  speed := 0;
 TimeLEdit.Text := getTranslation('%d:%.2d',[trunc((now - times.startTime) *MinsPerDay), trunc((now - times.startTime)*SecsPerDay) mod 60]);
 if speed > 0 then
   begin
    tLeft := (fSize - sendedSize) div speed;
    TimeLeftLEdit.Text :=getTranslation('%d:%.2d',[tLeft div 60, tLeft mod 60]);
   end
  else
   begin
    TimeLeftLEdit.Text := '...';
   end;
end;

procedure TsendfileFrm.Disconnected(Sender: TObject; ErrCode: Word);
begin
  if ErrCode > 0 then
   begin
     CancelTrasfer;
//     Exit;
   end
  else
    EndTrasfer;
//   if ;
end;

procedure TsendfileFrm.notifFunc(Sender: TObject; ErrCode: Word; msg : String);
begin
  if msg > '' then
    msgBox.Lines.Add(msg);
end;

procedure TsendfileFrm.doDoneTransfer;
begin
  SetPrgrsPos(100);
  EndTrasfer;
end;

procedure TsendfileFrm.doTransfer(dr : TICQdirect);
//var
//  i : Integer;
begin
  if (self = nil)or (not Assigned(fileList)) then
    Exit;
  if current < fileList.Count then
   begin
    dirct := dr;
    if not Assigned(fstr) then
    begin
      fstr := TFileStream.Create(fileList.Strings[current], fmOpenRead or fmShareDenyWrite);
      if Assigned(fstr) then
      begin
        fSize := fstr.Size;
        dirct.OnDataNext   := someData;
        dirct.OnDisconnect := Disconnected;
        dirct.OnNotification := notifFunc;
        dirct.sock.OnSendData := senddata;
//        if dirct.fileSizeReceived > 0 then
          sendedSize := dirct.fileSizeReceived;
        fstr.Position := dirct.fileSizeReceived;
        times.prevRcvd := sendedSize;
        if fSize > 0 then
          SetPrgrsPos(100 * sendedSize div fSize);
//        SetPrgrsPos(0);
        msgBox.Lines.Add(getTranslation('Sending'));
        dirct.ProcessSend;
      end
      else
       begin
        fSize := -1;
        msgBox.Lines.Add(getTranslation('Error opening file'));
       end;
    end;

//    dirct.p
//    dirct.sock.OnDataSent := ;
{    SetLength(dirct.buf, BufSize);
    i := fs.Read(dirct.buf[1], BufSize);
    if i < BufSize then
     SetLength(dirct.buf, i);
    dirct.sendPkt(dirct.buf);
}
   end;
end;

end.
