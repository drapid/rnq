{
This file is part of R&Q.
Under same license
}
unit chat_frOld;
{$I RnQConfig.inc}
{$I NoRTTI.inc}

interface

uses 
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  StdCtrls, utilLib, RDGlobal,
 {$IFDEF PREF_IN_DB}
  DBPrefsLib,
 {$ELSE ~PREF_IN_DB}
  RnQPrefsLib,
 {$ENDIF PREF_IN_DB}
  RnQSpin, ComCtrls, VirtualTrees;

type
  TchatFr = class(TPrefFrame)
    ChatPrefPages: TPageControl;
    CommonSheet: TTabSheet;
    SmileSheet: TTabSheet;
    sendonenterLbl: TLabel;
    sendonenterSpin: TRnQSpinButton;
    autocopyChk: TCheckBox;
    autodeselectChk: TCheckBox;
    singleChk: TCheckBox;
    statusontabChk: TCheckBox;
    cursorbelowChk: TCheckBox;
    quoteselectedChk: TCheckBox;
    stylecodesChk: TCheckBox;
    chatOnTopChk: TCheckBox;
    ChkDefCP: TCheckBox;
    PlugPanelChk: TCheckBox;
    HintsShowChk: TCheckBox;
    msgWrapBox: TCheckBox;
    ClsSndChk: TCheckBox;
    SmlPnlChk: TCheckBox;
    ChkShowSmileCptn: TCheckBox;
    GroupBox1: TGroupBox;
    BtnWidthLabel: TLabel;
    SmlUseSizeChk: TCheckBox;
    SmlGridChk: TCheckBox;
    SmlBtnWidthTrk: TTrackBar;
    BtnHeightLabel: TLabel;
    SmlBtnHeightTrk: TTrackBar;
    ClsPgOnSnglChk: TCheckBox;
    SepSmilesChk: TCheckBox;
    TSBtns: TTabSheet;
    IconsGrp: TGroupBox;
    SpinBtn: TRnQSpinButton;
    BtnsList: TVirtualDrawTree;
    procedure sendonenterSpinTopClick(Sender: TObject);
    procedure sendonenterSpinBottomClick(Sender: TObject);
    procedure SmlUseSizeChkClick(Sender: TObject);
  public
    sendonenterTmp:integer;
    procedure initPage; Override; final;
    procedure applyPage; Override; final;
    procedure resetPage; Override; final;
    procedure updateVisPage; Override; final;
  end;

implementation
uses
   RnQlangs, RnQGlobal, chatDlg, MenuSmiles, globalLib;

const
  s = 'Send when i press "ENTER" key %d times';

{$R *.dfm}

procedure TchatFr.sendonenterSpinTopClick(Sender: TObject);
begin
  if sendOnEnterTMP<3 then
    inc(sendOnEnterTMP);
  sendonenterLbl.Caption := getTranslation(s,[sendonenterTMP]);
end;

procedure TchatFr.SmlUseSizeChkClick(Sender: TObject);
begin
  updateVisPage;
end;

procedure TchatFr.sendonenterSpinBottomClick(Sender: TObject);
begin
  if sendOnEnterTMP>0 then
    dec(sendOnEnterTMP);
  sendonenterLbl.Caption := getTranslation(s, [sendonenterTMP]);
end;

procedure TchatFr.initPage;
begin
  sendonenterLbl.Caption := getTranslation(s, [sendonenter]);
end;

procedure TchatFr.applyPage;
var
  lShowAniSmlPanel: Boolean;
  prefSmlAutoSize: Boolean;
begin
  fontstylecodes.enabled := stylecodesChk.checked;
  autoCopyHist:=autocopyChk.checked;
  autodeselect:=autodeselectChk.checked;
  singleDefault:=singleChk.checked;
  showStatusOnTabs:=statusontabChk.checked;
  quoting.cursorBelow:=cursorbelowChk.checked;
  sendOnEnter:=sendOnEnterTMP;
  quoting.quoteselected:=quoteselectedChk.checked;
  chatAlwaysOnTop:=chatOnTopChk.Checked;
  useSystemCodePage := ChkDefCP.Checked;
  usePlugPanel := PlugPanelChk.Checked;
  showHintsInChat := HintsShowChk.Checked;
  closeChatOnSend := ClsSndChk.Checked;
  ClosePageOnSingle := ClsPgOnSnglChk.Checked;
  ShowSmileCaption := ChkShowSmileCptn.Checked;
  lShowAniSmlPanel := MainPrefs.getPrefBoolDef('smiles-show-panel', True);
  if lShowAniSmlPanel <> SmlPnlChk.Checked then
   begin
     lShowAniSmlPanel := SmlPnlChk.Checked;
     MainPrefs.addPrefBool('smiles-show-panel', lShowAniSmlPanel);
     chatFrm.SetSmilePopup(not lShowAniSmlPanel);
   end;

  MainPrefs.addPrefArrParam([msgWrapBox, SmlGridChk]);

  prefSmlAutoSize := MainPrefs.getPrefBoolDef(SmlUseSizeChk.HelpKeyword, True);
  if prefSmlAutoSize <> not SmlUseSizeChk.Checked then
   begin
//    prefSmlAutoSize := not SmlUseSizeChk.Checked;
    MainPrefs.addPrefBool(SmlUseSizeChk.HelpKeyword, not SmlUseSizeChk.Checked);
//    SmileToken := -1;
   end;
//

  if prefSmlAutoSize <> not SmlUseSizeChk.Checked then
   begin
    prefSmlAutoSize := not SmlUseSizeChk.Checked;
//    SmileToken := -1;
   end;
  MainPrefs.addPrefInt(SmlBtnWidthTrk.HelpKeyword, SmlBtnWidthTrk.Position);
  MainPrefs.addPrefInt(SmlBtnHeightTrk.HelpKeyword, SmlBtnHeightTrk.Position);
end;

procedure TchatFr.resetPage;
begin
  stylecodesChk.checked := fontstylecodes.enabled;
  autocopyChk.checked := autoCopyHist;
  autodeselectChk.checked := autodeselect;
  singleChk.checked := singleDefault;
  statusontabChk.checked := showStatusOnTabs;
  cursorbelowChk.checked := quoting.cursorBelow;
  sendOnEnterTmp      := sendonenter;
  quoteselectedChk.checked := quoting.quoteselected;
  chatOnTopChk.Checked := chatAlwaysOnTop;
  ChkDefCP.Checked    := useSystemCodePage;
  PlugPanelChk.Checked := usePlugPanel;
  HintsShowChk.Checked := showHintsInChat;
  ClsSndChk.Checked    := closeChatOnSend;
  ChkShowSmileCptn.Checked := ShowSmileCaption;
  ClsPgOnSnglChk.Checked := ClosePageOnSingle;

  MainPrefs.getPrefArrParam([msgWrapBox, SmlGridChk]);

  SmlBtnWidthTrk.Position  := MainPrefs.getPrefIntDef(SmlBtnWidthTrk.HelpKeyword, Btn_Max_Width);;
  SmlBtnHeightTrk.Position := MainPrefs.getPrefIntDef(SmlBtnHeightTrk.HelpKeyword, Btn_Max_Height);
  SmlUseSizeChk.Checked := not MainPrefs.getPrefBoolDef(SmlUseSizeChk.HelpKeyword, True);

  SmlPnlChk.Checked  := MainPrefs.getPrefBoolDef('smiles-show-panel', True); //ShowAniSmlPanel
end;

procedure TchatFr.updateVisPage;
begin
  SmlBtnWidthTrk.Enabled := SmlUseSizeChk.Checked;
  SmlBtnHeightTrk.Enabled := SmlBtnWidthTrk.Enabled;

end;

end.

