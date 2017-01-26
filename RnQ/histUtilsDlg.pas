unit histUtilsDlg;
{$I RnQConfig.inc}
{$I NoRTTI.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  StdCtrls, RnQButtons;

type
  ThistUtilsFrm = class(TForm)
    loadHistBtn: TRnQSpeedButton;
    loadHist1Btn: TRnQSpeedButton;
    Label1: TLabel;
    Label2: TLabel;
    Memo1: TMemo;
    RepHistBtn: TRnQButton;
    procedure FormShow(Sender: TObject);
    procedure loadHist1BtnClick(Sender: TObject);
    procedure loadHistBtnClick(Sender: TObject);
    procedure RepHistBtnClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure AddHistToContactAction(sender:Tobject);
  end;

  function load: boolean;
  function unLoad: boolean;

var
  histUtilsFrm: ThistUtilsFrm;

implementation
uses
  RDGlobal, RDFileUtil, RQUtil, RnQDialogs, RnQLangs,
  selectcontactsDlg, globalLib, mainDlg,
  rnqProtocol, history,
  HistWork, chatDlg, utilLib;

{$R *.dfm}

var
   loadedLib: Boolean;

function load: boolean;
begin
  @Splicing := nil;
  @ReNum := nil;
  @JimmToRq := nil;
//  @CheckDates := nil;
//  @CureHistory := nil;
  result := false;
  try
    LibHandle := LoadLibrary('HistoryLib.DLL');
    if LibHandle >= 32 then
     begin
      @Splicing := GetProcAddress(LibHandle,'Splicing');
      @ReNum := GetProcAddress(LibHandle,'ReNum');
  //    @AddMessage := GetProcAddress(LibHandle,'AddMessage');
      @JimmToRq := GetProcAddress(LibHandle,'JimmToRq');
  //    @CheckDates := GetProcAddress(LibHandle,'CheckDates');
  //    @CureHistory := GetProcAddress(LibHandle,'CureHistory');
      if @JimmToRq = nil then
        result := True;
     end;
  except
  end;
end;

function unLoad: boolean;
begin
  @Splicing := nil;
  @ReNum := nil;
//  @AddMessage := nil;
  @JimmToRq := nil;
//  @CureHistory := nil;
  FreeLibrary(LibHandle);
  result := True;
end;


procedure ThistUtilsFrm.loadHistBtnClick(Sender: TObject);
var
  dir: String;
  rslt: String;
//  fn: String;
begin
 //chatFrm.closeAllPages;
  if chatFrm.chats.count > 0 then
   begin
    if messageDlg(getTranslation('Close all chats?'), mtConfirmation, [mbYes,mbNo],0, mbNo, 20) = mrYes then
      chatFrm.closeAllPages
     else
      begin
       msgDlg('Please close all chat pages!', True, mtInformation);
       exit;
      end;
   end;
//   if OpenDirDialog(self.Handle, getTranslationW('Select directory with history'), dir) then
   if OpenDirDialog(self.Handle, getTranslation('Select directory with history'), dir) then
//   fn := opendlg(self, '', '', 'Select directory with history');
//   if fn > '' then
    begin
//      dir := ExtractFileDir(FN);
      AddHistory(dir, Account.ProtoPath+historyPath, StrToIntDef(Account.AccProto.getmyInfo.UID2cmp, 0), rslt);
//      str2strings(';', rslt, LogList.Items);
//      str2strings(';', rslt, Memo1.Lines);
      Memo1.Text := rslt
    end;
end;

procedure ThistUtilsFrm.RepHistBtnClick(Sender: TObject);
begin
{var
  rslt: String;
  fn: String;
  hist: Thistory;
begin

     fn := openSavedlg(self, 'Select file with history', True);
     if fn > '' then
       begin
         RenameFile(fn, fn+'Rep.Safe');
         hist := Thistory.Create;
         hist.RepaireHistoryFile(fn+'Rep.Safe', rslt);
         saveFile(fn, hist.toString);
         Memo1.Text := rslt
       end;
}
end;

procedure ThistUtilsFrm.loadHist1BtnClick(Sender: TObject);
var
  cntcts: TselectCntsFrm;
begin
//  cntcts := TselectContactsFrm.Create(Self);
  cntcts := TselectCntsFrm.doAll(RnQmain, 'Select contact whom to add history',
     'Select', Account.AccProto,
     notInList.clone.add(Account.AccProto.readList(LT_ROSTER)), AddHistToContactAction,
     [], @cntcts);
end;

procedure ThistUtilsFrm.AddHistToContactAction(sender: Tobject);
var
  wnd: TselectCntsFrm;
  cntct: TRnQContact;
  histFile: String;
  rslt: String;
  fn: String;
begin
  wnd := (sender as Tcontrol).parent as TselectCntsFrm;
  cntct := wnd.current;
  if cntct = NIL then
    msgDlg('You must select contact', True, mtInformation)
   else
    begin
     fn := openSavedlg(self, 'Select file with history', True);
     if fn > '' then
       begin
         histFile := FN;
         AddFile(fn, Account.ProtoPath+historyPath+ cntct.uid2cmp, rslt);
         Memo1.Text := rslt
       end;
    end;
  wnd.Close;
  self.SetFocus;
end;

{
procedure ThistUtilsFrm.RepHistBtnClick(Sender: TObject);
var
//  dir  : String;
  rslt : String;
//  fn : String;
begin
//  fn := opendlg(self, '', '', 'Select file with history');
//  if fn > '' then
    begin
//      Cure(fn, rslt);
      Cure(userPath+historyPath, rslt);
      Memo1.Text := rslt
    end;
end;}

procedure ThistUtilsFrm.FormShow(Sender: TObject);
begin
  if @Splicing <> nil then
    loadHistBtn.Enabled := True
   else
    loadHistBtn.Enabled := false;
  if @ReNum <> nil then
    loadHist1Btn.Enabled := True
   else
    loadHist1Btn.Enabled := false;
{  if @JimmToRq <> nil then
    CnvJimmHstBtn.Enabled := True
   else
    CnvJimmHstBtn.Enabled := false;
  if @CureHistory <> nil then
    RepHistBtn.Enabled := True
   else
    RepHistBtn.Enabled := false;}
end;
{
procedure ThistUtilsFrm.RnQSpeedButton1Click(Sender: TObject);
var
  dir : String;
begin
   if OpenDirDialog(self.Handle, getTranslation('Select directory with history'), dir) then
    begin
        RunChkDates(dir);
      Memo1.Text := ''
    end;
end;
}

INITIALIZATION
   loadedLib := false;

FINALIZATION
  if loadedLib then
    unLoad;


end.
