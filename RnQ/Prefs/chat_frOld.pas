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
  RnQSpin, ComCtrls, VirtualTrees, RnQButtons;

type
  TchatFr = class(TPrefFrame)
    ChatPrefPages: TPageControl;
    CommonSheet: TTabSheet;
    SmileSheet: TTabSheet;
    sendonenterLbl: TLabel;
    sendonenterSpin: TRnQSpinButton;
    singleChk: TCheckBox;
    statusontabChk: TCheckBox;
    cursorbelowChk: TCheckBox;
    quoteselectedChk: TCheckBox;
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
    SpellSheet: TTabSheet;
    SpellCheckActive: TCheckBox;
    LangList: TVirtualDrawTree;
    langLbl: TLabel;
    warningLbl: TLabel;
    refreshBtn: TButton;
    manageBtn: TButton;
    howotLbl: TLabel;
    GroupBox2: TGroupBox;
    underSize: TComboBox;
    ColorBtn: TColorPickerButton;
    TSHistory: TTabSheet;
    stylecodesChk: TCheckBox;
    autodeselectChk: TCheckBox;
    autocopyChk: TCheckBox;
    DrawEmojiChk: TCheckBox;
    SmilesChk: TCheckBox;
    procedure sendonenterSpinTopClick(Sender: TObject);
    procedure sendonenterSpinBottomClick(Sender: TObject);
    procedure SmlUseSizeChkClick(Sender: TObject);
    procedure LangListDrawNode(Sender: TBaseVirtualTree; const PaintInfo: TVTPaintInfo);
    procedure LangListFreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure refreshBtnClick(Sender: TObject);
    procedure manageBtnClick(Sender: TObject);
  private
    sendonenterTmp: integer;
 {$IFDEF CHAT_SPELL_CHECK}
    spellLanguages2: TStringList;
    procedure refreshLangList;
    procedure resetLangs;
 {$ENDIF CHAT_SPELL_CHECK}
  public
    procedure initPage(prefs: TRnQPref); Override; final;
    procedure applyPage; Override; final;
    procedure resetPage; Override; final;
    procedure updateVisPage; Override; final;
    procedure unInitPage; Override; final;
  end;

  PLangItem = ^TLangItem;
  TLangItem = record
    lang: PChar;
    locale: String;
  end;

implementation
uses
  RnQlangs, RnQGlobal, Winapi.ShellAPI, Winapi.ActiveX,
 {$IFDEF CHAT_SPELL_CHECK}
  MsSpellCheckLib_TLB,
 {$ENDIF CHAT_SPELL_CHECK}
  chatDlg, MenuSmiles, globalLib;

const
  s = 'Send when i press "ENTER" key %d times';

{$R *.dfm}

procedure TchatFr.sendonenterSpinTopClick(Sender: TObject);
begin
  if sendOnEnterTMP<3 then
    inc(sendOnEnterTMP);
  sendonenterLbl.Caption := getTranslation(s, [sendonenterTMP]);
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

procedure TchatFr.refreshBtnClick(Sender: TObject);
begin
 {$IFDEF CHAT_SPELL_CHECK}
  refreshLangList;
  resetLangs;
 {$ENDIF CHAT_SPELL_CHECK}
end;

// GetUILanguage(LOCALE_SENGLISHLANGUAGENAME)
function GetUILanguage(LCTYPE: LCTYPE): String;
var
  Buffer: array [0..255] of Char;
begin
  GetLocaleInfo(LOCALE_CUSTOM_UI_DEFAULT, LCTYPE, Buffer, SizeOf(Buffer));
  Result := String(Buffer);
end;

procedure TchatFr.manageBtnClick(Sender: TObject);
var
//  res: Cardinal;
  path, localS, localE: String;
  len: Integer;
begin
  if CheckWin32Version(10, 0) then
    ShellExecute(Self.Handle, 'open', 'ms-settings:regionlanguage', '', '', SW_SHOWNORMAL)
  else
  begin
    path := '\Packages\windows.immersivecontrolpanel_cw5n1h2txyewy\LocalState\Indexed\Settings\%s\AAA_SystemSettings_Language_Add_Profile.settingcontent-ms';
    localS := '%LocalAppData%';
    len := ExpandEnvironmentStrings(PChar(localS), PChar(localE), 0);
    if len > 0 then
    begin
      SetLength(localE, len - 1);
      ExpandEnvironmentStrings(PChar(localS), PChar(localE), len);
      if ShellExecute(Self.Handle, 'open', PChar(localE.Trim + Format(path, ['ru-RU'])), '', '', SW_SHOWNORMAL) <= 32 then
        ShellExecute(Self.Handle, 'open', PChar(localE.Trim + Format(path, ['en-US'])), '', '', SW_SHOWNORMAL);
    end;
  end;
end;

 {$IFDEF CHAT_SPELL_CHECK}
procedure TchatFr.refreshLangList;
var
  iscf: ISpellCheckerFactory;
  langs: IEnumString;
  lang: PChar;
  fetched: Cardinal;
  n: PVirtualNode;
  LangItem: PLangItem;
  locid: Cardinal;
begin

  LangList.NodeDataSize := SizeOf(TLangItem);
  LangList.Clear;
  iscf := nil;
  if Succeeded(CoCreateInstance(CLASS_SpellCheckerFactory, nil, CLSCTX_INPROC_SERVER, IID_ISpellCheckerFactory, iscf)) and Assigned(iscf) then
  begin
    langs := nil;
    iscf.Get_SupportedLanguages(langs);
    if Assigned(langs) then
    while langs.RemoteNext(1, lang, fetched) = S_OK do
    begin
      n := LangList.AddChild(nil);
      LangItem := LangList.GetNodeData(n);
      LangItem.lang := lang;

      locid := Languages.LocaleIDFromName[lang];
      if locid = 0 then
        LangItem.locale := lang
      else
        LangItem.locale := Languages.NameFromLocaleID[locid];

      n.CheckType := ctCheckBox;
      n.CheckState := csUncheckedNormal;
    end;
  end;
end;

procedure TchatFr.resetLangs;
var
  lang: String;
  n: PVirtualNode;
  d: Pointer;
begin
  for lang in spellLanguages2 do
  begin
    n := LangList.GetFirst;
    while not (n = nil) do
    begin
      d := LangList.GetNodeData(n);
      if (d <> NIL) and (PLangItem(d).lang = lang) then
        n.CheckState := csCheckedNormal;
      n := LangList.GetNext(n);
    end;
  end;
  LangList.Refresh;
end;
 {$ENDIF CHAT_SPELL_CHECK}

procedure TchatFr.initPage;
begin
  Inherited;
 {$IFDEF CHAT_SPELL_CHECK}
  spellLanguages2 := TStringList.Create;
  spellLanguages2.Delimiter := ',';
  spellLanguages2.StrictDelimiter := True;

  if CheckWin32Version(6, 2) then
    refreshLangList
  else begin
    EnableSpellCheck := False;
    SpellSheet.TabVisible := False;
  end;
 {$ENDIF CHAT_SPELL_CHECK}

  sendonenterLbl.Caption := getTranslation(s, [sendonenter]);
end;

procedure TchatFr.unInitPage;
begin
 {$IFDEF CHAT_SPELL_CHECK}
  FreeAndNil(spellLanguages2);
 {$ENDIF CHAT_SPELL_CHECK}
end;

procedure TchatFr.LangListDrawNode(Sender: TBaseVirtualTree; const PaintInfo: TVTPaintInfo);
var
  oldMode: Integer;
  d: Pointer;
begin
  PaintInfo.Canvas.Font.Color := clWindowText;
  oldMode := SetBKMode(PaintInfo.canvas.Handle, TRANSPARENT);
  d := Sender.GetNodeData(PaintInfo.Node);
  if d <> NIL then
    PaintInfo.Canvas.TextOut(PaintInfo.ContentRect.Left, 1, PLangItem(d).locale);
  SetBKMode(PaintInfo.Canvas.Handle, oldMode);
end;

procedure TchatFr.LangListFreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);
begin
{$WARN UNSAFE_CODE OFF}
  with TLangItem(PLangItem(Sender.GetNodeData(Node))^) do
{$WARN UNSAFE_CODE ON}
  begin
    lang := '';
    SetLength(locale, 0);
  end;
end;

procedure TchatFr.applyPage;
var
  lShowAniSmlPanel: Boolean;
  prefSmlAutoSize: Boolean;
  n: PVirtualNode;
begin
  lPrefs.addPrefArrParam([DrawEmojiChk]);

  fontstylecodes.enabled := stylecodesChk.checked;
  autoCopyHist := autocopyChk.checked;
  autodeselect := autodeselectChk.checked;
  singleDefault := singleChk.checked;
  showStatusOnTabs := statusontabChk.checked;
  quoting.cursorBelow := cursorbelowChk.checked;
  sendOnEnter := sendOnEnterTMP;
  quoting.quoteselected := quoteselectedChk.checked;
  chatAlwaysOnTop := chatOnTopChk.Checked;
  useSystemCodePage := ChkDefCP.Checked;
  usePlugPanel := PlugPanelChk.Checked;
  showHintsInChat := HintsShowChk.Checked;
  closeChatOnSend := ClsSndChk.Checked;
  ClosePageOnSingle := ClsPgOnSnglChk.Checked;
  ShowSmileCaption := ChkShowSmileCptn.Checked;
  lShowAniSmlPanel := lPrefs.getPrefBoolDef('smiles-show-panel', True);
  if lShowAniSmlPanel <> SmlPnlChk.Checked then
   begin
     lShowAniSmlPanel := SmlPnlChk.Checked;
     lPrefs.addPrefBool('smiles-show-panel', lShowAniSmlPanel);
     chatFrm.SetSmilePopup(not lShowAniSmlPanel);
   end;

  lPrefs.addPrefArrParam([msgWrapBox, SmlGridChk]);

  prefSmlAutoSize := lPrefs.getPrefBoolDef(SmlUseSizeChk.HelpKeyword, True);
  if prefSmlAutoSize <> not SmlUseSizeChk.Checked then
   begin
//    prefSmlAutoSize := not SmlUseSizeChk.Checked;
    lPrefs.addPrefBool(SmlUseSizeChk.HelpKeyword, not SmlUseSizeChk.Checked);
//    SmileToken := -1;
   end;
//

  if prefSmlAutoSize <> not SmlUseSizeChk.Checked then
   begin
    prefSmlAutoSize := not SmlUseSizeChk.Checked;
//    SmileToken := -1;
   end;
  lPrefs.addPrefInt(SmlBtnWidthTrk.HelpKeyword, SmlBtnWidthTrk.Position);
  lPrefs.addPrefInt(SmlBtnHeightTrk.HelpKeyword, SmlBtnHeightTrk.Position);

 {$IFDEF CHAT_SPELL_CHECK}
  EnableSpellCheck := SpellCheckActive.Checked;
  spellLanguages2.Clear;
  n := LangList.GetFirstChecked;
  while not (n = nil) do
  begin
    spellLanguages2.Add(PLangItem(LangList.GetNodeData(n)).lang);
    n := LangList.GetNextChecked(n);
  end;

  lPrefs.addPrefStrList('spellcheck-languages', spellLanguages2);

  spellErrorColor := ColorBtn.SelectionColor;
  spellErrorStyle := underSize.ItemIndex;
  if Assigned(chatFrm) then
  with chatFrm do
  begin
//    UpdateChatSettings;
    InitSpellCheck;
    SpellCheck;
  end;
 {$ENDIF CHAT_SPELL_CHECK}
end;

procedure TchatFr.resetPage;
begin
  lPrefs.getPrefArrParam([DrawEmojiChk]);

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

  lPrefs.getPrefArrParam([msgWrapBox, SmlGridChk]);

  SmlBtnWidthTrk.Position := lPrefs.getPrefIntDef(SmlBtnWidthTrk.HelpKeyword, Btn_Max_Width);;
  SmlBtnHeightTrk.Position := lPrefs.getPrefIntDef(SmlBtnHeightTrk.HelpKeyword, Btn_Max_Height);
  SmlUseSizeChk.Checked := not lPrefs.getPrefBoolDef(SmlUseSizeChk.HelpKeyword, True);

  SmlPnlChk.Checked := lPrefs.getPrefBoolDef('smiles-show-panel', True); //ShowAniSmlPanel

 {$IFDEF CHAT_SPELL_CHECK}
  lPrefs.getPrefStrList('spellcheck-languages', spellLanguages2);
  SpellCheckActive.Checked := EnableSpellCheck;
  ColorBtn.SelectionColor := spellErrorColor;
  underSize.ItemIndex := spellErrorStyle;
  if SpellSheet.TabVisible then
    resetLangs;
 {$ENDIF CHAT_SPELL_CHECK}
end;

procedure TchatFr.updateVisPage;
begin
  SmlBtnWidthTrk.Enabled := SmlUseSizeChk.Checked;
  SmlBtnHeightTrk.Enabled := SmlBtnWidthTrk.Enabled;

end;

end.

