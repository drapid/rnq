{
This file is part of R&Q.
Under same license
}
unit chat_frOld;
{$I Compilers.inc}
{$I RnQConfig.inc}
{$I NoRTTI.inc}

interface

uses 
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  StdCtrls, utilLib, RDGlobal,
  RnQPrefsLib, RnQSpin, ComCtrls, VirtualTrees;

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
if sendOnEnterTMP<3 then inc(sendOnEnterTMP);
sendonenterLbl.Caption:=getTranslation(s,[sendonenterTMP]);
end;

procedure TchatFr.SmlUseSizeChkClick(Sender: TObject);
begin
  updateVisPage;
end;

procedure TchatFr.sendonenterSpinBottomClick(Sender: TObject);
begin
if sendOnEnterTMP>0 then dec(sendOnEnterTMP);
sendonenterLbl.Caption:=getTranslation(s,[sendonenterTMP]);
end;

procedure TchatFr.initPage;
begin
  sendonenterLbl.Caption:=getTranslation(s,[sendonenter]);
end;

procedure TchatFr.applyPage;
begin
  fontstylecodes.enabled:=stylecodesChk.checked;
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
  bViewTextWrap := msgWrapBox.Checked;
  closeChatOnSend := ClsSndChk.Checked;
  ClosePageOnSingle := ClsPgOnSnglChk.Checked;
  ShowSmileCaption := ChkShowSmileCptn.Checked;
  if ShowAniSmlPanel <> SmlPnlChk.Checked then
   begin
     ShowAniSmlPanel := SmlPnlChk.Checked;
     chatFrm.SetSmilePopup(not ShowAniSmlPanel);
   end;
  DrawSmileGrid := SmlGridChk.Checked;
  if prefSmlAutoSize <> not SmlUseSizeChk.Checked then
   begin
    prefSmlAutoSize := not SmlUseSizeChk.Checked;
    SmileToken := -1;
   end;
  prefBtnWidth := SmlBtnWidthTrk.Position;
  prefBtnHeight := SmlBtnHeightTrk.Position;
//
end;

procedure TchatFr.resetPage;
begin
  stylecodesChk.checked:=fontstylecodes.enabled;
  autocopyChk.checked:=autoCopyHist;
  autodeselectChk.checked:=autodeselect;
  singleChk.checked:=singleDefault;
  statusontabChk.checked:=showStatusOnTabs;
  cursorbelowChk.checked:=quoting.cursorBelow;
  sendOnEnterTmp      :=sendonenter;
  quoteselectedChk.checked:=quoting.quoteselected;
  chatOnTopChk.Checked:=chatAlwaysOnTop;
  ChkDefCP.Checked    := useSystemCodePage;
  PlugPanelChk.Checked := usePlugPanel;
  HintsShowChk.Checked := showHintsInChat;
  msgWrapBox.Checked   := bViewTextWrap;
  ClsSndChk.Checked    := closeChatOnSend;
  ChkShowSmileCptn.Checked := ShowSmileCaption;
  ClsPgOnSnglChk.Checked := ClosePageOnSingle;
  SmlPnlChk.Checked  := ShowAniSmlPanel;
  SmlGridChk.Checked := DrawSmileGrid;
  SmlUseSizeChk.Checked := not prefSmlAutoSize;
  SmlBtnWidthTrk.Position  := prefBtnWidth;
  SmlBtnHeightTrk.Position := prefBtnHeight;
end;

procedure TchatFr.updateVisPage;
begin
  SmlBtnWidthTrk.Enabled := SmlUseSizeChk.Checked;
  SmlBtnHeightTrk.Enabled := SmlBtnWidthTrk.Enabled;

end;

end.

