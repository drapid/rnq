{
This file is part of R&Q.
Under same license
}
unit filetransferDlg;
{$I RnQConfig.inc}

{$IFDEF COMPILER_14_UP}
  {$WEAKLINKRTTI ON}
  {$RTTI EXPLICIT METHODS([]) FIELDS([]) PROPERTIES([])}
{$ENDIF COMPILER_14_UP}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  StdCtrls, ComCtrls, ExtCtrls, RnQButtons, icqv9, RnQProtocol;

type
  TCalcTime = record
          startTime : TDateTime;
          prevRcvd : Int64;
          curBT : byte;
          bt : array[0..19] of record
            bytes : Int64;
            startTime : TDateTime;
           end;
        end;

type
  TfiletransferFrm = class(TForm)
    box: TMemo;
    FTProgress: TProgressBar;
    FNLEdit: TLabeledEdit;
    PathLEdit: TLabeledEdit;
    PathBtn: TRnQSpeedButton;
    SizeLEdit: TLabeledEdit;
    AcceptBtn: TRnQButton;
    CloseBtn: TRnQButton;
    SenderLEdit: TLabeledEdit;
    LocProxyChk: TCheckBox;
    OpenBtn: TRnQButton;
    SrvChk: TCheckBox;
    TimePanel: TPanel;
    TimeLEdit: TLabeledEdit;
    TimeLeftLEdit: TLabeledEdit;
    SpeedLEdit: TLabeledEdit;
    T1: TTimer;
    ClsWinChk: TCheckBox;
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure someDataRCVD(Sender: TObject; ErrCode: Word);
    procedure Disconnected(Sender: TObject; ErrCode: Word);
    procedure notifFunc(Sender: TObject; ErrCode: Word; msg : String);
    procedure EndTrasfer;
    procedure AcceptBtnClick(Sender: TObject);
    procedure CloseBtnClick(Sender: TObject);
    procedure PathBtnClick(Sender: TObject);
    procedure OpenBtnClick(Sender: TObject);
    procedure SrvChkClick(Sender: TObject);
    procedure T1Timer(Sender: TObject);
    procedure ClsWinChkClick(Sender: TObject);
  public
    id : Int64;
    fSize : Int64;
    direct : TProtoDirect;
    fn :string;
//    fs :integer;
    constructor doAll(d: TProtoDirect);
//    constructor doAll(thisICQ : TicqSession; evID : Int64; fromCnt : TContact;
//                       fn : String); Overload;
  protected
    fpath : String;
    myICQ : TICQSession;
    fstr : TStream;
    rcvdSize : Int64;
    times : TCalcTime;
    FileDone : Boolean;
    Closing : Boolean;
//    transferID : Int64;
//    who : TContact;
//    state : byte;
    procedure SetPrgrsPos(pos : Integer);
  end;

var
  filetransferFrm: TfiletransferFrm;

implementation

{$R *.dfm}

uses
  globalLib, mainDlg, langLib,
  RDGlobal, RDFileUtil, RDUtils, RnQNet,
  rqUtil, RQThemes, RnQSysUtils, RnQDialogs, RnQPics,
  ICQContacts, RQ_ICQ, ICQConsts,
  themesLib, utilLib, RnQLangs;

const
  CantCrDir = 'Error. Can''t create directory!';
  CantCrFile = 'Error!!! Can''t create file.';

constructor TfiletransferFrm.doAll(d: TProtoDirect);
//constructor TfiletransferFrm.doAll(thisICQ: TicqSession; evID: Int64;
//  fromCnt: TContact; fn: String);
begin
  if not Assigned(d) then
   begin
//     result := NIL;
     Exit;
   end;
  inherited create(rnqmain);
  position:=poDefaultPosOnly;
  childWindows.Add(self);
  Theme.pic2ico(RQteFormIcon, PIC_FILE, icon);
  translateWindow(self);
  id := d.eventID;
  direct := d;
  SrvChk.Checked := False;
//  LocProxyChk.Checked := True;
  if d.mode = dm_bin_proxy then
    begin
      SrvChk.Checked := True;
      SrvChk.Enabled := False;
    end
   else
     SrvChk.Enabled := True;
   ;
  SrvChkClick(nil);
  LocProxyChk.Enabled := SrvChk.Enabled;
//  direct     := myICQ.directTo(who);
//  who        := d.contact;
//  transferID := d.eventID;
//  direct.eventID := evID;
//  direct.imSender := False;
//  direct.kind := DK_file;
//  direct.mode := dm_bin_direct;
  myICQ      := TicqSession(d.directs.proto);
//  fn :=
  SenderLEdit.Text := direct.contact.displayed + ' ('+direct.contact.uin2Show+')';
  FNLEdit.Text     := d.fileName;
//  if FNLEdit.Text = '' then
//    FNLEdit.Text := 'Unknown';
//  fpath := userPath + 'Received\' + d.fileName;
  fpath := IncludeTrailingPathDelimiter(fileIncomePath(direct.contact))+ FNLEdit.Text;
  PathLEdit.Text   := fpath;
  SizeLEdit.Text   := size2str(d.fileSizeTotal);
  SetPrgrsPos(0);
  FileDone := False;
  Closing := False;
    AcceptBtn.Enabled := True;
  ClsWinChk.Checked := CloseFTWndAuto;
  showForm(self);
  bringForeground:=handle;
end;

procedure TfiletransferFrm.FormShow(Sender: TObject);
begin
  applyTaskButton(self)
end;

procedure TfiletransferFrm.OpenBtnClick(Sender: TObject);
begin
  exec(ExtractFilePath(fpath));
end;

procedure TfiletransferFrm.PathBtnClick(Sender: TObject);
var
  l : String;
begin
//  l := openSaveDlg(self, false, '*', 'All files', 'Save file as', PathLEdit.Text);
  l := openSaveDlg(self, '', false, '', '', PathLEdit.Text);
  if Length(l) > 0 then
    PathLEdit.Text := l;
end;

procedure TfiletransferFrm.FormClose(Sender: TObject; var Action: TCloseAction);
//var
//  tmp:Tdirect;
begin
  childWindows.remove(self);
  Closing := True;
  EndTrasfer;
  FreeAndNil(direct);
{  if Assigned(direct) then
   begin
    tmp:=direct;
    direct:=NIL;
    tmp.free;
   end;}
  FreeAndNil(fstr);
  action:=caFree;
  destroyHandle;
end;

procedure TfiletransferFrm.someDataRCVD(Sender: TObject; ErrCode: Word);
var
 i, l : Integer;
 md : Word;
begin
  if ErrCode > 0 then
   begin
//     CancelTrasfer;
     Exit;
   end;
  if not Assigned(fstr) then
   begin
    fn := direct.fileName;
    fsize := direct.fileSizeTotal;
    if fn > '' then
    begin
      if FileExists(fpath) then
        md := fmOpenWrite
       else
        md := fmCreate;
      try
        if not CreateDirRecursive(ExtractFileDir(fpath)) then
         begin
          msgDlg(CantCrDir, True, mtError);
          raise Exception.Create(getTranslation(CantCrDir));
         end;
        fstr := TFileStream.Create(fpath, md or fmShareDenyWrite);
        if not direct.needResume then
          begin
            fstr.Size := 0;
            fstr.Position := 0
          end
         else
          fstr.Position := rcvdSize;
        times.startTime := now;
        times.bt[0].startTime := times.startTime;
        t1.Enabled := True;
       except
        box.Lines.Add(CantCrFile);
        msgDlg(CantCrFile, True, mtError);
//        wasErr := True;
        EndTrasfer;
      end;
    end;
//    fsize := 0;
   end;
  if Assigned(fstr) then
  begin
//   if fstr.Position < fstr.Size then
    begin
      l := Length(direct.buf);
      i := fstr.Write(direct.buf[1], l);
//      rcvdSize := fstr.Size;
      rcvdSize := fstr.Position;

      if (i > 0)and(fSize <> rcvdSize)  then
        begin
//          inc(fsize, i);
          if fsize > 0 then
            SetPrgrsPos(trunc(100*rcvdSize/fsize))
           else
            SetPrgrsPos(25);
        end
       else
        if fSize = rcvdSize then
         begin
           box.Lines.Add('File received!');
           FileDone := True;
           SetPrgrsPos(100);
           TICQdirect(direct).DoneTransfer;
         end;
//        FTProgress.Position := 15;
//      if i < BufSize then
//       SetLength(direct.buf, i);
//      dirct.sendPkt(direct.buf);
    end
//   else
//    begin
//
//    end;
   ;
  end;
end;

procedure TfiletransferFrm.SrvChkClick(Sender: TObject);
begin
  if SrvChk.Enabled then
  begin
    LocProxyChk.Enabled := not SrvChk.Checked;
    if SrvChk.Checked then
      LocProxyChk.Checked := True;
  end;
end;

procedure TfiletransferFrm.AcceptBtnClick(Sender: TObject);
var
  wasErr : Boolean;
  needRes : Boolean;
  fp : TFilePacket;
  i : Integer;
begin
//  fsize := 0;
  SetPrgrsPos(0);
  rcvdSize := 0;
  times.curBT := 0;
  times.prevRcvd := 0;
  for I := Low(times.bt) to High(times.bt) do
    times.bt[i].bytes := 0;
  needRes := false;
      try
        fpath := PathLEdit.Text;
        if not CreateDirRecursive(ExtractFileDir(fpath)) then
          begin
           box.Lines.Add(getTranslation(CantCrDir));
           Exit;
          end;
//        fstr := TFileStream.Create(fpath + fn, md or fmShareDenyWrite);
       except
        box.Lines.Add(getTranslation(CantCrDir));
        Exit;
//        wasErr := True;
//        EndTrasfer;
      end;
  if FileExists(fpath) then
    begin
     case messageDlg(getTranslation('File already exists. Try to resume receive?'), mtConfirmation, [mbYes, mbIgnore ,mbAbort],0, mbYes, 20) of
//     case messageDlg(getTranslation('File already exists. Do you want to overwrite it?'), mtConfirmation, [mbRetry, mbIgnore ,mbAbort],0, mbRetry, 20) of
       mrYes: needRes := True;
       mrAbort: Exit;
     end;
    end;
  direct.data:=self;
  direct.OnDataAvailable := someDataRCVD;
  direct.OnDisconnect    := Disconnected;
  direct.OnNotification  := notifFunc;
  direct.needResume      := needRes;
  if needRes then
   begin
     fp := TFilePacket.Create;
     fp.AddFile(fpath);

     rcvdSize := TFileAbout(fp.FileList.Objects[0]).Size;
     times.prevRcvd := rcvdSize;
     direct.fileSizeReceived := rcvdSize;
     direct.receivedChkSum   := TFileAbout(fp.FileList.Objects[0]).CheckSum;
//     FTProgress.Position :=
     fp.Free;
   end;

{  if direct.contact.connection.internal_ip > 0 then
    direct.stage := 1
   else
    if proxy.proto = PP_NONE then
      direct.stage := 2
     else
      begin
        direct.stage := 1;
        direct.mode := dm_bin_proxy;
      end;
     ;
}
//  FileDone := False;
//  direct.stage := 1;
  direct.UseLocProxy := LocProxyChk.Checked;
//  if ProxyChk.Checked and ProxyChk.Enabled then
  if SrvChk.Checked and SrvChk.Enabled then
    begin
      direct.mode := dm_bin_proxy;
      direct.stage := 3;
    end
   else
    if not SrvChk.Checked then
      direct.mode := dm_bin_direct;

  SrvChk.Enabled := false;
  LocProxyChk.Enabled := False;
//  direct.stage := 2;
  try
      wasErr := False;
      myICQ.ProcessReceiveFile(TICQdirect(direct));
//      myICQ.sendFileOk(transferID, who);
     except
       wasErr := True;
  end;
  if not wasErr then
    AcceptBtn.Enabled := False;
//  direct:=myICQ.eventDirect;
//  fstr := NIL;
//  direct.fileName := fn;
//  if wasErr then
//    myICQ.sendFileReq2(Direct);
//  if not (thisICQ.eventDirect.sock.State in [wsListening, wsConnecting, wsSocksConnected, wsConnected]) then
//    thisICQ.eventDirect.connect;
end;

procedure TfiletransferFrm.CloseBtnClick(Sender: TObject);
begin
  Close;
end;

procedure TfiletransferFrm.ClsWinChkClick(Sender: TObject);
begin
  CloseFTWndAuto := ClsWinChk.Checked;
end;

procedure TfiletransferFrm.Disconnected(Sender: TObject; ErrCode: Word);
begin
  if ErrCode > 0 then
   begin
//     CancelTrasfer;
//     Exit;
   end
  else
    EndTrasfer;
//   if ;
end;

procedure TfiletransferFrm.notifFunc(Sender: TObject; ErrCode: Word; msg : String);
begin
  if msg > '' then
    box.Lines.Add(msg);
end;


procedure TfiletransferFrm.EndTrasfer;
begin
  t1.Enabled := false;
  if not FileDone then
   if Assigned(direct) then
     myICQ.sendFileAbort(TICQcontact(direct.contact), direct.eventID);
//   else
  try
    if Assigned(direct) then
      FreeAndNil(direct);
   except    
  end;
//  if Assigned(fileList) then
//    FreeAndNil(fileList);
  if Assigned(fstr) then
   begin
    FreeAndNil(fstr);
   end;
  if CloseFTWndAuto and not Closing then
    Close;
end;

procedure TfiletransferFrm.T1Timer(Sender: TObject);
var
  speed, tLeft : Int64;
  b : Integer;
  I, PrevTimeIDX: byte;
  dt : TDateTime;
  ts : Double;
begin
  b := 0;
  times.bt[times.curBT].bytes := rcvdSize - times.prevRcvd;
  times.prevRcvd := rcvdSize;
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
   speed := round(b /(ts*SecsPerDay))
  else
   speed := 0;

 if speed > 1024 then
   SpeedLEdit.Text := FloatToStr(round(100*(speed / 1024)) /100) + ' KB/sec'
  else
   SpeedLEdit.Text := intToStr(speed) + ' Bytes/sec';
 TimeLEdit.Text := getTranslation('%d:%.2d',[trunc((now - times.startTime) *MinsPerDay), trunc((now - times.startTime)*SecsPerDay) mod 60]);
 if speed > 0 then
   begin
    tLeft := (fSize - rcvdSize) div speed;
    TimeLeftLEdit.Text :=getTranslation('%d:%.2d',[tLeft div 60, tLeft mod 60]);
   end
  else
   begin
    TimeLeftLEdit.Text := '...';
   end;
end;

procedure TfiletransferFrm.SetPrgrsPos(pos : Integer);
begin
  FTProgress.Position := pos;
  FTProgress.Hint := intToStr(pos) + '%';
//  LPerc.Caption := intToStr(pos) + '%';
  if pos = 100 then
    begin
      FTProgress.Hint := 'Done';
//      LPerc.Caption := 'Done';
//      CancelBtn.Caption := getTranslation('Close');
    end;
end;

end.
