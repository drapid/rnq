{
This file is part of R&Q.
Under same license
}
unit security_fr;
{$I RnQConfig.inc}
{$I NoRTTI.inc}

interface

uses 
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  StdCtrls, RnQButtons,
 {$IFDEF PREF_IN_DB}
  DBPrefsLib,
 {$ELSE ~PREF_IN_DB}
  RnQPrefsLib,
 {$ENDIF PREF_IN_DB}
  RDGlobal, ExtCtrls;

type
  TsecurityFr = class(TPrefFrame)
    histcryptEnableChk: TCheckBox;
    cryptGroup: TGroupBox;
    histcryptSavePwdChk: TCheckBox;
    dontsavepwdChk: TCheckBox;
    writeHistoryChk: TCheckBox;
    DelHistChk: TCheckBox;
    MakeBakChk: TCheckBox;
    AddTempVisMsgChk: TCheckBox;
    histcryptChangeBtn: TRnQButton;
    CplPwdChk: TCheckBox;
    AskPassOnBossChk: TCheckBox;
    SetAccPassBtn: TRnQButton;
    HistCryptBtn: TRnQButton;
    procedure histcryptEnableChkClick(Sender: TObject);
    procedure histcryptChangeBtnClick(Sender: TObject);
    procedure dontsavepwdChkClick(Sender: TObject);
    procedure SetAccPassBtnClick(Sender: TObject);
    procedure HistCryptBtnClick(Sender: TObject);
   protected
    newHistPwd: String;
//    newAccPass: AnsiString;
   public
//    procedure initProps;
    procedure applyPage; Override;
    procedure resetPage; Override;
    procedure updateVisPage; Override;

  end;

implementation

uses
  utilLib, RnQLangs, RQUtil, RnQDialogs, langLib, RnQGlobal,
  changepwddlg, globalLib,
 {$IFDEF DB_ENABLED}
  RnQDB,
 {$ENDIF DB_ENABLED}
 {$IFDEF PROTOCOL_ICQ}
  ICQv9,
 {$ENDIF PROTOCOL_ICQ}
  history;

{$R *.dfm}

procedure TsecurityFr.histcryptEnableChkClick(Sender: TObject);
begin
 with histcryptEnableChk do
  if checked and not histcrypt.enabled then
    if messageDlg(getTranslation('You are invited to NOT use this function for now. It''s still under test.\nContinue?'),mtWarning,[mbYes,mbNo],0)=mrNo then
      begin
      checked:=FALSE;
      exit;
      end;
 updateVisPage
end;

procedure TsecurityFr.dontsavepwdChkClick(Sender: TObject);
begin
 updateVisPage
end;

procedure TsecurityFr.histcryptChangeBtnClick(Sender: TObject);
begin enterPwdDlg(newHistPwd) end;


procedure TsecurityFr.applyPage;
begin
  logpref.writehistory:=writehistoryChk.checked;
  dontSavePwd        := dontsavepwdChk.checked;
  clearPwdOnDSNCT    := CplPwdChk.Checked and dontsavepwdChk.checked;
  askPassOnBossKeyOn := AskPassOnBossChk.Checked;
  MakeBackups     := MakeBakChk.Checked;
 {$IFDEF PROTOCOL_ICQ}
  addTempVisMsg  := AddTempVisMsgChk.Checked;
 {$ENDIF PROTOCOL_ICQ}
  histcrypt.savePwd:=histcryptSavePwdChk.checked;

  with histcrypt do
    if histcryptEnableChk.checked and (newHistPwd='') then
      msgDlg('You did not entered any password, so encryption will be disabled!', True, mtError)
    else
     {$IFDEF RNQ_FULL2}
      if (pwd<>newHistPwd) or (enabled<>histcryptEnableChk.checked) then
        begin
        if (pwd='') and enabled then
          begin
          msgDlg('You have to enter the old password!', True, mtWarning);
          enterPwdDlg(pwd);
          end;
        if messageDlg(getTranslation('You asked to change history encryption.\nR&&Q must convert all histories and it can be lengthy. Proceed?'), mtConfirmation, [mbYes,mbNo], 0)=mrYes then
          if histcryptEnableChk.checked then
            convertHistoriesDlg(pwd, newHistPwd)
          else
            convertHistoriesDlg(pwd, '');
        end;
    {$ENDIF}
//  if newAccPass <> '' then
//    AccPass := newAccPass;
//  newAccPass := '';
//  saveCfgDelayed := True;
end;

procedure TsecurityFr.resetPage;
begin
  writehistoryChk.checked     := logpref.writehistory;
  dontsavepwdChk.checked      := dontSavePwd;
  CplPwdChk.Checked           := clearPwdOnDSNCT;
  AskPassOnBossChk.Checked    := askPassOnBossKeyOn;
  MakeBakChk.Checked          := MakeBackups;
 {$IFDEF PROTOCOL_ICQ}
  AddTempVisMsgChk.Checked    := addTempVisMsg;
 {$ENDIF PROTOCOL_ICQ}
  histcryptEnableChk.checked  := histcrypt.enabled;
  histcryptSavePwdChk.checked := histcrypt.savePwd;
  newHistPwd:=histcrypt.pwd;
//  newAccPass := '';
end;

procedure TsecurityFr.SetAccPassBtnClick(Sender: TObject);
begin
//  enterPwdDlg(newAccPass, getTranslation('Account password'), 16);
   if not Assigned(changeAccPwdFrm) then
    begin
      changeAccPwdFrm := TchangePwdFrm.Create(NIL, True);
      changeAccPwdFrm.Caption := 'Change account password';
      translateWindow(changeAccPwdFrm);
    end;
   changeAccPwdFrm.showModal
end;

procedure TsecurityFr.HistCryptBtnClick(Sender: TObject);
var
  hp: string;
begin
 {$IFDEF DB_ENABLED}
  hp := '';
  enterPwdDlg(hp, getTranslation('History password'), 16, True);
  SetDBPass(hp);
 {$ENDIF DB_ENABLED}
end;

procedure TsecurityFr.updateVisPage;
begin
  cryptGroup.visible := histcryptEnableChk.checked;
  CplPwdChk.Enabled  := dontsavepwdChk.Checked;
 {$IFDEF RNQ_FULL}
 {$ELSE}
   histcryptChangeBtn.Visible := false;
 {$ENDIF}
 {$IFDEF DB_ENABLED}
   HistCryptBtn.Visible := True;
 {$ELSE ~DB_ENABLED}
   HistCryptBtn.Visible := False;
 {$ENDIF ~DB_ENABLED}
end;

end.
