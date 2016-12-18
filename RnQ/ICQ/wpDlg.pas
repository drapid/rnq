{
This file is part of R&Q.
Under same license
}
unit wpDlg;
{$I RnQConfig.inc}
{$I NoRTTI.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  StdCtrls, ExtCtrls, VirtualTrees, ComCtrls, Menus, VTHeaderPopup,
  RnQProtocol,
  ICQv9,
  RnQButtons, RnQDialogs, RQMenuItem, RDFileUtil;

type
  TwpSearchType = (wpUIN, wpMail, wpKeywords, wpInfo, wpFull, wpComPad);
   Presults = ^Tresults;
   Tresults = array[1..9] of string;
{        c1 : String;  // Online
        c2 : String;  // UIN
        c3 : String;  // Nick
        c4 : String;  // First name
        c5 : String;  // Last name
        c6 : String;  // Email
       end;}

  TwpFrm = class(TForm)
    Panel1: TPanel;
    sbar: TPanel;
    clearBtn: TRnQSpeedButton;
    pcSearch: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    TabSheet4: TTabSheet;
    TabSheet5: TTabSheet;
    TabSheet6: TTabSheet;
    emailBox2: TLabeledEdit;
    keyBox2: TLabeledEdit;
    nickBox2: TLabeledEdit;
    firstBox2: TLabeledEdit;
    lastBox2: TLabeledEdit;
    uinBox2: TLabeledEdit;
    Panel2: TPanel;
    Label5: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    ageBox: TComboBox;
    genderBox: TComboBox;
    countryBox: TComboBox;
    langBox: TComboBox;
    nickBox: TLabeledEdit;
    firstBox: TLabeledEdit;
    cityBox: TLabeledEdit;
    lastBox: TLabeledEdit;
    emailBox: TLabeledEdit;
    uinBox: TLabeledEdit;
    stateBox: TLabeledEdit;
    accumulateChk: TCheckBox;
    onlineChk: TCheckBox;
    Label12: TLabel;
    Label1: TLabel;
    keyBox: TLabeledEdit;
    InterestCombo2: TComboBox;
    Label2: TLabel;
    InterestCombo1: TComboBox;
    Label3: TLabel;
    AddSB: TRnQSpeedButton;
    resultTree: TVirtualDrawTree;
    nickCPbox: TLabeledEdit;
    CountryCPCBox: TComboBox;
    CityCPLEdit: TLabeledEdit;
    LangCPCBox: TComboBox;
    AgeCPCBox: TComboBox;
    GenderCPCBox: TComboBox;
    Label4: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label11: TLabel;
    searchBtn: TRnQButton;
    VTHPMenu: TVTHeaderPopupMenu;
    procedure resultTreeCompareNodes(Sender: TBaseVirtualTree; Node1,
      Node2: PVirtualNode; Column: TColumnIndex; var Result: Integer);
    procedure resultTreeDrawNode(Sender: TBaseVirtualTree;
      const PaintInfo: TVTPaintInfo);
    procedure AddSBClick(Sender: TObject);
    procedure clearBtnClick(Sender: TObject);
    procedure searchBtnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Viewinfo1Click(Sender: TObject);
    procedure uinBoxChange(Sender: TObject);
    procedure resultsDblClick(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure Label12Click(Sender: TObject);
    procedure Sendmessage1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure menuPopup(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Label1Click(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure menusaveastxt1Click(Sender: TObject);
//    procedure menusaveasclb1Click(Sender: TObject);
    procedure pcSearchChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure VTHPMenuPopup(Sender: TObject);
    procedure resultTreeHeaderClick(Sender: TVTHeader;
      HitInfo: TVTHeaderHitInfo);
//s@x -  procedure resultsDrawCell(Sender: TObject; ACol, ARow: Integer;
//      Rect: TRect; State: TGridDrawState);
  private
    Nresults: integer;
    menu: TRnQPopupMenu;
    AddToCL : TRQMenuItem;
    wp  : TwpSearch;
    idx : integer;
    thisICQ : TICQSession;
  public
    N_Allresults : Integer;
    SearchType: TwpSearchType;

    constructor WP4ICQ(pProto : TRnQProtocol);
    procedure stopSearch;
    procedure cleanResults;
    procedure addResult(wp: TwpResult);
    procedure updateNumResults;
    function  selectedContact: TRnQcontact;
    procedure addcontactAction(sender: Tobject);
    procedure DestroyHandle; Override;
    //s@X
    procedure SetControlEnable(Value: Boolean);
  end;

var
  wpFrm: TwpFrm;

implementation

uses
  RnQLangs, RnQStrings, RnQPics,
  RQUtil, RDGlobal, RQThemes, RnQMenu, RnQSysUtils, RnQBinUtils,
  globallib, mainDlg, viewinfoDlg, chatDlg, utilLib,
  themesLib, RQCodes,
  RQ_ICQ, ICQConsts, ICQContacts, Protocol_ICQ,
  menusUnit;

{$R *.DFM}

procedure TwpFrm.clearBtnClick(Sender: TObject);
begin
  uinBox.text := '';
  nickBox.text := '';
  firstBox.text := '';
  lastBox.text := '';
  emailBox.text := '';
  cityBox.text := '';
  countryBox.itemIndex := 0;
  ageBox.itemIndex := 0;
  genderBox.itemIndex := 0;
  langBox.itemIndex := 0;
  stateBox.text := '';
  onlineChk.checked := FALSE;
end; // clearBtn

procedure TwpFrm.searchBtnClick(Sender: TObject);

  function intValue(s: string): integer;
  begin
    s := trim(s);
    if s = '' then
      result := 0
    else
      result := strToInt(s)
  end; // intValue

var
  uin: TUID;
begin
//  if searchBtn.Kind = bkNo then
  if searchBtn.Caption = getTranslation('S&top') then
  begin
    stopSearch;
    exit;
  end;
  if not OnlFeature(thisICQ) then
    exit;
  wp.Token := '';  
 (* if uinBox.text > '' then
  begin
  {$IFDEF RNQ_FULL}
    uin := unFakeUIN(StrToInt64(uinBox.text));
 {$ELSE}
    uin := StrToInt(uinBox.text);
 {$ENDIF}
    if not validUIN(uin) then
    begin
      sbar.caption := getTranslation('Invalid UIN');
      exit;
    end;
    wp.uin := uin;
  end
  else  *)

  FillMemory(@wp, SizeOf(wp), 0);
  case SearchType of

 wpUIN:
   begin

     if uinBox2.text = '' then
      exit;

//     uin := unFakeUIN(StrToInt64(uinBox2.text));
     uin := uinBox2.text;
     if not thisICQ.validUID1(uin) then
     begin
       sbar.caption := getTranslation('Invalid UIN');
       exit;
     end;
     wp.uin := uin;

  end;
 wpMail:
   begin
     wp.uin := '';
     wp.email := trim(emailBox2.Text);

   end;
 wpKeywords:
   begin
     wp.wInterest:= StrToInterestI(InterestCombo2.text);
     wp.keyword:= trim(keyBox2.text);
   end;
 wpInfo:
   begin

     wp.nick := trim(nickBox2.Text);
     wp.first := trim(firstBox2.Text);
     wp.last := trim(lastBox2.Text);

   end;
 wpFull:
   begin
     wp.uin := '';
     wp.nick := trim(nickBox.Text);
     wp.first := trim(firstBox.Text);
     wp.last := trim(lastBox.Text);
     wp.email := trim(emailBox.Text);
     wp.city := trim(cityBox.Text);
     wp.age := StrToAgeI(trim(ageBox.Text));
     wp.onlineOnly := onlineChk.checked;
     wp.gender := StrToGenderI(genderBox.text);
//     wp.country := StrToCountryI(countryBox.text);
     wp.country := CB2ID(countryBox);
     wp.state := trim(stateBox.text);
     wp.lang := StrToLanguageI(langBox.text);
     wp.wInterest:= StrToInterestI(InterestCombo1.text);
     wp.keyword:= trim(keyBox.text);
   end;
 wpComPad:
   begin
     wp.uin := '';
     wp.nick := trim(nickCPbox.Text);
     wp.first := ''; //trim(firstBox.Text);
     wp.last := ''; //trim(lastBox.Text);
     wp.email := ''; //trim(emailBox.Text);
     wp.city := trim(CityCPLEdit.Text);
     wp.age := StrToAgeI(trim(AgeCPCBox.Text));
     wp.onlineOnly := False; //onlineChk.checked;
     wp.gender := StrToGenderI(GenderCPCBox.text);
//     wp.country := StrToCountryI(CountryCPCBox.text);
     wp.country := CB2ID(CountryCPCBox);
     wp.state := ''; //trim(stateBox.text);
     wp.lang := StrToLanguageI(LangCPCBox.text);
     wp.wInterest:= 0; //StrToInterestI(InterestCombo1.text);
     wp.keyword:= ''; //trim(keyBox.text);
   end;
 end;

 { wp.uin := 0;
  wp.nick := trim(nickBox.Text);
  wp.first := trim(firstBox.Text);
  wp.last := trim(lastBox.Text);
  wp.email := trim(emailBox.Text);
  wp.city := trim(cityBox.Text);
//wp.age:=ageCodes.FromString(trim(ageBox.Text));
  wp.age := StrToAgeI(trim(ageBox.Text));
//  wp.age := System.swap(Word(StrToInt(age1CBox.Text))) shl 16 + System.swap(Word(StrToInt(age2CBox.Text)));
  wp.onlineOnly := onlineChk.checked;
//wp.gender:=genderCodes.fromString(genderBox.text);
  wp.gender := StrToGenderI(genderBox.text);
//wp.country:=countryCodes.fromString(countryBox.text);
  wp.country := StrToCountryI(countryBox.text);
  wp.state := trim(stateBox.text);
//wp.lang:=languageCodes.fromString(langBox.text);
  wp.lang := StrToLanguageI(langBox.text);        }

  if not accumulateChk.checked then
    cleanResults;
//  searchBtn.kind := bkNo;
  searchBtn.Caption := getTranslation('S&top');

  N_Allresults := 0;
//s@X
  SetControlEnable(false);

  Cursor := crHourGlass;
//  ani.Active := TRUE;
  idx := 0;
   if SearchType = wpComPad then
     thisICQ.sendWPsearch2(wp, 0)
    else
     thisICQ.sendWPsearch(wp, 0);
end; // searchBtn

procedure TwpFrm.stopSearch;
begin
  Cursor := crDefault;
//  ani.Active := FALSE;
//  searchBtn.kind := bkOK;
  searchBtn.Caption := getTranslation('&Search');
//s@X
  SetControlEnable(true);
  resultTree.SortTree(resultTree.Header.SortColumn, resultTree.Header.SortDirection);
end;

procedure TwpFrm.updateNumResults;
begin
  if N_Allresults > 0 then
    sbar.caption := getTranslation('results: %d from %d', [Nresults, N_Allresults])
   else
    sbar.caption := getTranslation('results: %d', [Nresults]);
end;

procedure TwpFrm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TwpFrm.FormCreate(Sender: TObject);
var
  i: byte;
begin
  menu := TRnQPopupMenu.Create(Self);
  menu.OnPopup := menuPopup;
  resultTree.PopupMenu := menu;
  resultTree.NodeDataSize := SizeOf(Tresults);
  AddToMenu(menu.Items, getTranslation('View info'),
       PIC_INFO, True, Viewinfo1Click);
  AddToCL := AddToMenu(menu.Items, getTranslation('Add to contact list'),
//       PIC_ADD_CONTACT, false, addContactActn);
       PIC_ADD_CONTACT, false);
//  AddToMenu(menu.Items, getTranslation('Add ALL contacts to the list'),
//       PIC_ADD_CONTACT, False, AddALLcontactsToList);
  AddToMenu(menu.Items, getTranslation('Open chat'),
       PIC_MSG, False, Sendmessage1Click);
  AddToMenu(menu.Items, getTranslation('Save as txt'),
       PIC_SAVE, False, menusaveastxt1Click);
//  AddToMenu(menu.Items, getTranslation('Save as clb'), PIC_SAVE, False, menusaveasclb1Click);

  ageBox.items.text := CRLF + AgesToStr;
  genderBox.Items.text := CRLF + GendersToStr;
//  countryBox.Items.text := CRLF + CountrysToStr; //countryCodes.strings;
   CountrysToCB(countryBox);
  langBox.Items.text := CRLF + LanguagesToStr;

  AgeCPCBox.items.text := CRLF + AgesToStr;
  GenderCPCBox.Items.text := CRLF + GendersToStr;
//  CountryCPCBox.Items.text := CRLF + CountrysToStr; //countryCodes.strings;
   CountrysToCB(CountryCPCBox);
  LangCPCBox.Items.text := CRLF + LanguagesToStr;

  InterestCombo2.Items.text:=CRLF+InterestsToStr;
  InterestCombo1.Items.text:=CRLF+InterestsToStr;
//s@X

  for i := 0 to resultTree.Header.Columns.Count - 1 do
   resultTree.Header.Columns.Items[i].Text :=
     getTranslation(resultTree.Header.Columns.Items[i].Text);
//  results.Columns[6].Caption := getTranslation('Age');
  cleanResults;
  pcSearchChange(pcSearch);

  thisICQ := TicqSession(Account.AccProto);
end;

procedure TwpFrm.cleanResults;
//var
//  i: integer;
begin
  Nresults := 0;
  N_Allresults := 0;
  AddSB.Enabled := searchBtn.Enabled and (Nresults > N_Allresults);
//  AddSB.Enabled := Nresults > 0;
//s@X
//results.rowCount:=2;
  resultTree.Clear;

  updateNumResults;
end; // cleanResults

procedure TwpFrm.addResult(wp: TwpResult);
var
  s: string;
//  i: integer;
//  li: TListItem;
  n: PVirtualNode;
//  r: Tresults;
  tr: Presults;
  cs: TCheckState;
begin
// does already exist ?
  n := resultTree.GetFirst;
  if n <> nil then
   begin
    repeat
      if Tresults(Presults(resultTree.getnodedata(n))^)[2] = wp.uin then
       exit;
      n := resultTree.GetNext(n);
    until n=nil;
   end;

  inc(Nresults);
//  if Nresults > 1 then
//    results.rowCount:=1+Nresults;

  case wp.status of
    0: s := getTranslation('No');
    1: s := getTranslation('Yes');
  else
    s := '?';
  end;

//  li := TListItem.Create(results.Items);
  n := resultTree.AddChild(nil);
  tr := resultTree.GetNodeData(n);
      if wp.status = 1 then
        begin
         tr^[1] := char(SC_ONLINE);
         cs := csCheckedNormal
        end
      else if wp.status = 0 then
           begin
            tr^[1] := char(SC_OFFLINE);
            cs := csUncheckedNormal
           end
        else
          begin
           tr^[1] := char(SC_UNK);
           cs := csMixedNormal;
          end;
  n.CheckState := cs;
//     tr^.c1 := char;
     tr^[2] := wp.uin;
     tr^[3] := wp.nick;
     tr^[4] := wp.first;
     tr^[5] := wp.last;
     tr^[6] := wp.email;
     tr^[7] := '';
     if wp.gender > 0 then
       tr^[7] := copy(GendersByID(wp.gender), 1, 1);
     if wp.age > 0 then
      begin
       if tr^[7] > '' then
        tr^[7] := tr^[7] + '-';
       tr^[7] := tr^[7]  + IntToStr(wp.age);
      end;
     if wp.authRequired then
       tr^[8] := getTranslation('Authorize')
      else
     tr^[8] := getTranslation('Always');
     if wp.BDay > 0 then
       tr^[9] := DateToStr(wp.BDay)
      else
       tr^[9] := '';

  updatenumResults;
end;

procedure TwpFrm.AddSBClick(Sender: TObject);
begin
  inc(idx);
   if SearchType = wpComPad then
     thisICQ.sendWPsearch2(wp, idx)
    else
     thisICQ.sendWPsearch(wp, idx);
end;

// addResult

function TwpFrm.selectedContact: TRnQContact;
begin
  if resultTree.SelectedCount = 0 then
    result := nil
   else
    result := thisICQ.getContact(Tresults(Presults(resultTree.getnodedata(resultTree.GetFirstSelected))^)[2]);
end;

procedure TwpFrm.Viewinfo1Click(Sender: TObject);
begin
  if resultTree.SelectedCount = 0 then
    Exit;
//  viewInfoAbout(selectedContact);
  selectedContact.ViewInfo; 
end;

procedure TwpFrm.VTHPMenuPopup(Sender: TObject);
begin
  applyCommonSettings(TControl(Sender));
end;

constructor TwpFrm.WP4ICQ(pProto: TRnQProtocol);
begin
  Self.Create(Application);
//  Self.thisICQ := pProto;
  thisICQ := TicqSession(pProto);
end;

procedure TwpFrm.uinBoxChange(Sender: TObject);
begin
  onlyDigits(sender)
end;

procedure TwpFrm.resultsDblClick(Sender: TObject);
begin
  viewinfo1click(self);
end;

procedure TwpFrm.resultTreeCompareNodes(Sender: TBaseVirtualTree; Node1,
  Node2: PVirtualNode; Column: TColumnIndex; var Result: Integer);
begin
{  if Column = 0 then
    result := CompareText(IntToStr(Node1..ImageIndex),  IntToStr(Node2.ImageIndex))
  else
//   if
}
    result := - CompareText(Tresults(Presults(resultTree.getnodedata(Node1))^)[Column+1],
      Tresults(Presults(resultTree.getnodedata(Node2))^)[Column+1])
end;

procedure TwpFrm.resultTreeDrawNode(Sender: TBaseVirtualTree;
  const PaintInfo: TVTPaintInfo);
var
  cnv: Tcanvas;
  x, y: integer;
  s: Tstatus;
begin
  x:=PaintInfo.ContentRect.left;
  y := PaintInfo.ContentRect.top;
  cnv := PaintInfo.Canvas;
  cnv.FillRect(PaintInfo.CellRect);
  if PaintInfo.Column = 0 then
  begin
{    case PaintInfo.Node.CheckState of
      csUncheckedNormal : s := SC_OFFLINE;
      csCheckedNormal   : s := SC_ONLINE;
     else
       s := SC_UNK;
    end;
}
//    statusDraw(cnv, x, y, s);
    s := tstatus(Presults(sender.getnodedata(paintinfo.node))^[1][1]);
    ICQstatusDrawExt(cnv.Handle, x, y, byte(s), false, 0, GetParentCurrentDpi);
//    draws
//    theme.drawPic(cnv, x, y, status2imgName(s));
    Exit;
  end;

if (poDrawSelection in PaintInfo.PaintOptions)
   and (vsSelected in PaintInfo.Node.States) then
  begin
  cnv.Brush.Color:=clHighlight;
  cnv.font.Color:=clHighlightText;
  end
else
  begin
  cnv.Brush.Color:=clWindow;
  cnv.font.Color:=clWindowText;
  end;
{if gdFixed in state then
  begin
  cnv.Brush.Color:=clBtnFace;
  cnv.Font.color:=clBtnText;
  inc(x,3);
  inc(y,2);
  end;}
 try
//  if isOnlyDigits(Presults(sender.getnodedata(paintinfo.node))^[2]) then
   if thisICQ.readList(LT_ROSTER).exists(thisICQ, Presults(sender.getnodedata(paintinfo.node))^[2]) then
     cnv.font.Color := clGrayText;
  except
 end;
 cnv.TextRect(PaintInfo.CellRect, x,y, Presults(sender.getnodedata(paintinfo.node))^[PaintInfo.Column+1]);
end;

procedure TwpFrm.resultTreeHeaderClick(Sender: TVTHeader;
  HitInfo: TVTHeaderHitInfo);
begin
  if HitInfo.Column = Sender.SortColumn then
    if Sender.SortDirection = sdAscending then
      Sender.SortDirection := sdDescending
     else
      Sender.SortDirection := sdAscending
   else
    Sender.SortColumn := HitInfo.Column;
end;

procedure TwpFrm.FormPaint(Sender: TObject);
begin
  wallpaperize(canvas);
end;

procedure TwpFrm.Label12Click(Sender: TObject);
begin
  with onlineChk do
    checked := not checked
end;

procedure TwpFrm.Sendmessage1Click(Sender: TObject);
begin
  if resultTree.SelectedCount = 0 then
    Exit;
  chatFrm.openOn(selectedContact)
end;

procedure TwpFrm.addcontactAction(sender: Tobject);
begin
  addToRoster(selectedContact, (sender as TRQmenuitem).tag)
end;

procedure TwpFrm.destroyHandle;
begin
  inherited
end;

procedure TwpFrm.FormShow(Sender: TObject);
begin
  applyTaskButton(self);
  theme.pic2ico(RQteFormIcon, PIC_WP, icon);
end;

procedure TwpFrm.menuPopup(Sender: TObject);
begin
  if resultTree.SelectedCount = 0 then
    begin
      AddToCL.visible := False;
      Exit;
    end
   else
    begin
    end;
  AddToCL.visible:=not thisICQ.isInList(LT_ROSTER, selectedContact);
  if AddToCL.visible then
    addGroupsToMenu(self, AddToCL, addcontactAction, True);
//  addGroupsToMenu(self, Addtocontactlist1, addcontactAction);
end;

procedure TwpFrm.FormDestroy(Sender: TObject);
var
  i : Integer;
begin
  for i := 0 to menu.Items.Count-1 do
    menu.Items[0].Free;
  menu.Free;
  wpFrm := NIL;
end;

procedure TwpFrm.Label1Click(Sender: TObject);
begin
  with accumulateChk do
    checked := not checked
end;

procedure TwpFrm.FormResize(Sender: TObject);
begin
//s@X
  // results.height:=clientHeight-sbar.BoundsRect.bottom-5
end;

procedure TwpFrm.menusaveastxt1Click(Sender: TObject);
var
//  i: integer;
  s, str: string;
  n : PVirtualNode;
  rr : Tresults;
begin
  s := '';
  n := resultTree.GetFirst;
  if n <> nil then
    repeat
      rr := Tresults(Presults(resultTree.getnodedata(n))^);
      s := s + Format('%s %s %s %s' + CRLF, [rr[2], rr[3], rr[4], rr[5]]);
      n := resultTree.GetNext(n);
    until n=nil;

  str := openSavedlg(self, '', false, 'txt');
  if str > '' then
  begin
    if saveFile2(str, s) then
      msgDlg('Done', True, mtInformation)
    else
      msgDlg(Str_Error, True, mtError);
  end;
end;

{
procedure TwpFrm.menusaveasclb1Click(Sender: TObject);
var
//  i: integer;
  cl: TRnQCList;
  c: TICQContact;
  n : PVirtualNode;
  str : String;
  res : Tresults;
begin
  cl := TRnQCList.Create;
  n := resultTree.GetFirst;
  if n <> nil then
   begin
    repeat
      res := Tresults(Presults(resultTree.getnodedata(n))^);
      c := thisICQ.getICQContact(res[2]);
      c.nick  := res[3];
      c.first := res[4];
      c.last  := res[5];
      c.email := res[6];
      cl.add(c);
      n := resultTree.GetNext(n);
    until n=nil;
   end;
  str := openSavedlg(self, '', false, 'clb');
  if str > '' then
  begin
    if savefile(str, contactlist2clb(cl)) then
      msgDlg('Done', True, mtInformation)
    else
      msgDlg(Str_Error, True, mtError);
    cl.resetEnumeration();
    while cl.hasMore() do
      cl.getNext.Free();
  end;
  cl.free();
end;}

procedure TwpFrm.SetControlEnable(Value: Boolean);
begin
  uinBox.Enabled := Value;
  nickBox.Enabled := Value;
  firstBox.Enabled := Value;
  lastBox.Enabled := Value;
  emailBox.Enabled := Value;
  countryBox.Enabled := Value;
  cityBox.Enabled := Value;
  stateBox.Enabled := Value;
  genderBox.Enabled := Value;
  ageBox.Enabled := Value;
  langBox.Enabled := Value;
  onlineChk.Enabled := Value;
  accumulateChk.Enabled := Value;
  Label8.Enabled := Value;
  Label9.Enabled := Value;
  Label5.Enabled := Value;
  Label10.Enabled := Value;
  Label12.Enabled := Value;
  Label1.Enabled := Value;

  uinBox2.Enabled := Value;
  emailBox2.Enabled := Value;
  InterestCombo2.Enabled := Value;
  keyBox2.Enabled := Value;
  nickBox2.Enabled := Value;
  firstBox2.Enabled := Value;
  lastBox2.Enabled := Value;
  InterestCombo1.Enabled := Value;
  keyBox.Enabled := Value;
  Label2.Enabled := Value;
  Label3.Enabled := Value;


  nickCPbox.Enabled := Value;
  CountryCPCBox.Enabled := Value;
  CityCPLEdit.Enabled := Value;
  GenderCPCBox.Enabled := Value;
  AgeCPCBox.Enabled := Value;
  LangCPCBox.Enabled := Value;

  if Value then
  begin
    searchBtn.ImageName := PIC_SEARCH;
//    searchBtn.Invalidate;
//    resultTree.OnCompareNodes:= resultsCompare;
  end
  else
  begin
    searchBtn.ImageName := PIC_CLOSE;
//    searchBtn.Invalidate;
//    results.OnCompare:= nil;
  end;
//  AddSB.Enabled := searchBtn.Enabled and (Nresults > 0);
  AddSB.Enabled := searchBtn.Enabled and (N_Allresults > Nresults);

end;

procedure TwpFrm.pcSearchChange(Sender: TObject);
const
 l1 = 54;
 l2 = 136;
begin
 searchBtn.Parent:= pcSearch.ActivePage;
// AVI.Parent:= pcSearch.ActivePage;
 Caption:= getTranslation('Search by "%s"', [pcSearch.ActivePage.Caption]);

 case TwpSearchType(pcSearch.ActivePageIndex) of
 wpUIN:
   begin
     SearchType:= wpUIN;
     pcSearch.height:= l1 + uinBox2.Height;
   end;
 wpMail:
   begin
     SearchType:= wpMail;
     pcSearch.height:= l1 + uinBox2.Height;
   end;
 wpKeywords:
   begin
     SearchType:= wpKeywords;
     pcSearch.height:= l1 + uinBox2.Height;
   end;
 wpInfo:
   begin
     SearchType:= wpInfo;
     pcSearch.height:= l1 + uinBox2.Height;
   end;
 wpFull:
   begin
     SearchType:= wpFull;
     pcSearch.height:= l2;
   end;
 wpComPad:
   begin
     SearchType:= wpComPad;
     pcSearch.height:= l2;
   end;
 else
     SearchType:= wpFull;
     pcSearch.height:= l2;
 end;

end;



end.
