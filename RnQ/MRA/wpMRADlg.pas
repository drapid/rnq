{
Copyright (C) 2002-2004  Massimo Melina (www.rejetto.com)

This file is part of &RQ.

    &RQ is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    &RQ is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with &RQ; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
}
unit wpMRADlg;
{$I Compilers.inc}
{$I RnQConfig.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  StdCtrls, ExtCtrls,
  RnQProtocol, MRAcontacts,
  ComCtrls, Menus,
  RnQButtons, RnQDialogs, RQMenuItem, RnQFileUtil,
  VirtualTrees, VTHeaderPopup, MRAv1, RnQSpin;

type
  TwpSearchType = (wpMail, wpInfo, wpFull);
   Presults = ^Tresults;
   Tresults = array[1..8] of string;
{        c1 : String;  // Online
        c2 : String;  // UIN
        c3 : String;  // Nick
        c4 : String;  // First name
        c5 : String;  // Last name
        c6 : String;  // Email
       end;}

  TwpMRAFrm = class(TForm)
    Panel1: TPanel;
    sbar: TPanel;
    clearBtn: TRnQSpeedButton;
    pcSearch: TPageControl;
    TabSheet2: TTabSheet;
    emailBox2: TLabeledEdit;
    TabSheet4: TTabSheet;
    TabSheet5: TTabSheet;
    nickBox2: TLabeledEdit;
    firstBox2: TLabeledEdit;
    lastBox2: TLabeledEdit;
    Panel2: TPanel;
    Label5: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    genderBox: TComboBox;
    countryBox: TComboBox;
    nickBox: TLabeledEdit;
    firstBox: TLabeledEdit;
    cityBox: TLabeledEdit;
    lastBox: TLabeledEdit;
    stateBox: TLabeledEdit;
    accumulateChk: TCheckBox;
    onlineChk: TCheckBox;
    Label12: TLabel;
    Label1: TLabel;
    AddSB: TRnQSpeedButton;
    resultTree: TVirtualDrawTree;
    VTHPMenu: TVTHeaderPopupMenu;
    searchBtn: TRnQButton;
    AgeFromSpin: TRnQSpinEdit;
    AgeToSpin: TRnQSpinEdit;
    procedure resultTreeHeaderClick(Sender: TVTHeader; Column: TColumnIndex;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
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
    procedure menusaveasclb1Click(Sender: TObject);
    procedure pcSearchChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure VTHPMenuPopup(Sender: TObject);
//s@x -  procedure resultsDrawCell(Sender: TObject; ACol, ARow: Integer;
//      Rect: TRect; State: TGridDrawState);
  private
    Nresults: integer;
    menu: TRnQPopupMenu;
    AddToCL : TRQMenuItem;
    wp  : TwpSearch;
    idx : integer;
    thisMRA : TMRASession;
  public
    N_Allresults : Integer;
    SearchType: TwpSearchType;

    procedure stopSearch;
    procedure cleanResults;
//    procedure addResult(wp: TwpResult);
    procedure addResult(cnt: TMRAContact);
    procedure updateNumResults;
    function  selectedContact: TRnQcontact;
    procedure addcontactAction(sender: Tobject);
    procedure DestroyHandle; Override;
    //s@X
    procedure SetControlEnable(Value: Boolean);
  end;

var
  wpMRAFrm: TwpMRAFrm;

implementation

uses
  globallib, mainDlg, viewinfoDlg, chatDlg, utilLib,
  RnQLangs, RnQStrings,
  RQUtil, RQGlobal, RQThemes, themesLib, RQCodes,
  flap, menusUnit;

{$R *.DFM}

const
  WP_COLUMN_GENDER = 6;
  WP_COLUMN_AUTH = 7;
  WP_COLUMN_BIRTH = 8;
procedure TwpMRAFrm.clearBtnClick(Sender: TObject);
begin
//  uinBox.text := '';
  nickBox.text := '';
  firstBox.text := '';
  lastBox.text := '';
  emailBox2.text := '';
  cityBox.text := '';
  countryBox.itemIndex := 0;
  AgeFromSpin.Value := 0;
  AgeToSpin.Value := 0;
  genderBox.itemIndex := 0;
  stateBox.text := '';
  onlineChk.checked := FALSE;
end; // clearBtn

procedure TwpMRAFrm.searchBtnClick(Sender: TObject);

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
  if not OnlFeature(thisMRA) then
    exit;
//  wp.Token := '';
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

 wpMail:
   begin
//     wp.uin := '';
     uin := thisMRA._GetProtoName +'_'+ trim(emailBox2.Text);
     if not thisMRA.validUid(uin) then
     begin
       sbar.caption := getTranslation('Invalid UID');
       exit;
     end;
     wp.email := uin;

   end;
 wpInfo:
   begin

     wp.nick := trim(nickBox2.Text);
     wp.first := trim(firstBox2.Text);
     wp.last := trim(lastBox2.Text);

   end;
 wpFull:
   begin
//     wp.uin := '';
     wp.nick := trim(nickBox.Text);
     wp.first := trim(firstBox.Text);
     wp.last := trim(lastBox.Text);
     wp.email := trim(emailBox2.Text);
     wp.city_id := 0;//trim(cityBox.Text);
     wp.ageFrom := AgeFromSpin.AsInteger;
     wp.ageTo := AgeToSpin.AsInteger;
     wp.onlineOnly := onlineChk.checked;
     wp.gender := StrToGenderI(genderBox.text);
//     wp.country := StrToCountryI(countryBox.text);
     wp.Country:= CB2ID(countryBox);
//     wp.state := trim(stateBox.text);
//     wp.lang := StrToLanguageI(langBox.text);
//     wp.wInterest:= StrToInterestI(InterestCombo1.text);
//     wp.keyword:= trim(keyBox.text);
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

  if not accumulateChk.checked then cleanResults;
//  searchBtn.kind := bkNo;
  searchBtn.Caption := getTranslation('S&top');

  N_Allresults := 0;
//s@X
  SetControlEnable(false);

  Cursor := crHourGlass;
//  ani.Active := TRUE;
  idx := 0;
//   if SearchType = wpComPad then
//     thisICQ.sendWPsearch2(wp, 0)
//    else
//     thisICQ.sendWPsearch(wp, 0);
  thisMRA.sendWPsearch(wp, 0);
end; // searchBtn

procedure TwpMRAFrm.stopSearch;
begin
  Cursor := crDefault;
//  ani.Active := FALSE;
//  searchBtn.kind := bkOK;
  searchBtn.Caption := getTranslation('&Search');
//s@X
  SetControlEnable(true);
  resultTree.SortTree(resultTree.Header.SortColumn, resultTree.Header.SortDirection);
end;

procedure TwpMRAFrm.updateNumResults;
begin
  if N_Allresults > 0 then
    sbar.caption := getTranslation('results: %d from %d', [Nresults, N_Allresults])
   else
    sbar.caption := getTranslation('results: %d', [Nresults]);
end;

procedure TwpMRAFrm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TwpMRAFrm.FormCreate(Sender: TObject);
var
  i : byte;
begin
  thisMRA := TMRASession(MainProto.ProtoElem);

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
  AddToMenu(menu.Items, getTranslation('Save as clb'),
       PIC_SAVE, False, menusaveasclb1Click);

//  ageBox.items.text := CRLF + AgesToStr;
  genderBox.Items.text := CRLF + GendersToStr;
//  countryBox.Items.text := CRLF + CountrysToStr; //countryCodes.strings;
   MRACountrysToCB(countryBox);

{  AgeCPCBox.items.text := CRLF + AgesToStr;
  GenderCPCBox.Items.text := CRLF + GendersToStr;
  CountryCPCBox.Items.text := CRLF + CountrysToStr; //countryCodes.strings;
  LangCPCBox.Items.text := CRLF + LanguagesToStr;

  InterestCombo2.Items.text:=CRLF+InterestsToStr;
  InterestCombo1.Items.text:=CRLF+InterestsToStr;
}
//s@X

  for i := 0 to resultTree.Header.Columns.Count - 1 do
   resultTree.Header.Columns.Items[i].Text :=
     getTranslation(resultTree.Header.Columns.Items[i].Text);
//  results.Columns[6].Caption := getTranslation('Age');
  cleanResults;
  pcSearchChange(pcSearch);
end;

procedure TwpMRAFrm.cleanResults;
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

//procedure TwpMRAFrm.addResult(wp: TwpResult);
procedure TwpMRAFrm.addResult(cnt: TMRAContact);
var
  s: string;
//  i: integer;
//  li : TListItem;
  n : PVirtualNode;
//  r : Tresults;
  tr : Presults;
  cs : TCheckState;
begin
// does already exist ?
  n := resultTree.GetFirst;
  if n <> nil then
   begin
    repeat
      if Tresults(Presults(resultTree.getnodedata(n))^)[2] = cnt.UID then
       exit;
      n := resultTree.GetNext(n);
    until n=nil;
   end;

  inc(Nresults);
//  if Nresults > 1 then
//    results.rowCount:=1+Nresults;

  case cnt.status of
    SC_OFFLINE: s := getTranslation('No');
    SC_UNK: s := '?';
  else
    s := getTranslation('Yes');
  end;

//  li := TListItem.Create(results.Items);
  n := resultTree.AddChild(nil);
  tr := resultTree.GetNodeData(n);
      if cnt.status = SC_OFFLINE then
        begin
         tr^[1] := char(SC_OFFLINE);
         cs := csUncheckedNormal
        end
      else
      if cnt.status = SC_UNK then
        begin
         tr^[1] := char(SC_UNK);
         cs := csMixedNormal;
        end
       else
        begin
         tr^[1] := char(SC_ONLINE);
         cs := csCheckedNormal
        end;
  n.CheckState := cs;
//     tr^.c1 := char;
     tr^[2] := cnt.UID;//wp.uin;
     tr^[3] := cnt.nick;// wp.nick;
     tr^[4] := cnt.first;
     tr^[5] := cnt.last;
//     tr^[6] := wp.email;
     tr^[WP_COLUMN_GENDER] := '';
     if wp.gender > 0 then
       tr^[WP_COLUMN_GENDER] := copy(GendersByID(wp.gender), 1, 1);
{     if wp.age > 0 then
      begin
       if tr^[WP_COLUMN_GENDER] > '' then
        tr^[WP_COLUMN_GENDER] := tr^[WP_COLUMN_GENDER] + '-';
       tr^[WP_COLUMN_GENDER] := tr^[WP_COLUMN_GENDER]  + IntToStr(wp.age);
      end;

     if wp.authRequired then
       tr^[WP_COLUMN_AUTH] := getTranslation('Authorize')
      else
     tr^[WP_COLUMN_AUTH] := getTranslation('Always');
}
     if cnt.birth > 0 then
       tr^[WP_COLUMN_BIRTH] := DateToStr(cnt.birth)
      else
       tr^[WP_COLUMN_BIRTH] := '';

  updatenumResults;
end;

procedure TwpMRAFrm.AddSBClick(Sender: TObject);
begin
  inc(idx);
//   thisICQ.sendWPsearch(wp, idx);
end;

// addResult

function TwpMRAFrm.selectedContact: TRnQContact;
begin
  if resultTree.SelectedCount = 0 then
    result := nil
   else
    result := thisMRA.getContact(Tresults(Presults(resultTree.getnodedata(resultTree.GetFirstSelected))^)[2]);
end;

procedure TwpMRAFrm.Viewinfo1Click(Sender: TObject);
begin
  if resultTree.SelectedCount = 0 then Exit;
//  viewInfoAbout(selectedContact);
  selectedContact.ViewInfo; 
end;

procedure TwpMRAFrm.VTHPMenuPopup(Sender: TObject);
begin
  applyCommonSettings(TControl(Sender));
end;

procedure TwpMRAFrm.uinBoxChange(Sender: TObject);
begin onlyDigits(sender) end;

procedure TwpMRAFrm.resultsDblClick(Sender: TObject);
begin
  viewinfo1click(self);
end;

procedure TwpMRAFrm.resultTreeCompareNodes(Sender: TBaseVirtualTree; Node1,
  Node2: PVirtualNode; Column: TColumnIndex; var Result: Integer);
begin
{  if Column = 0 then
    result:= CompareText(IntToStr(Node1..ImageIndex),  IntToStr(Node2.ImageIndex))
  else
//   if
}
    result:= - CompareText(Tresults(Presults(resultTree.getnodedata(Node1))^)[Column+1],
      Tresults(Presults(resultTree.getnodedata(Node2))^)[Column+1])
end;

procedure TwpMRAFrm.resultTreeDrawNode(Sender: TBaseVirtualTree;
  const PaintInfo: TVTPaintInfo);
var
  cnv: Tcanvas;
  x, y: integer;
  s : Tstatus;
begin
  x:=PaintInfo.ContentRect.left;
  y:=PaintInfo.ContentRect.top;
  cnv:=PaintInfo.Canvas;
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
    statusDrawExt(cnv.Handle, x, y, byte(s));
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
   if thisMRA.readList(LT_ROASTER).exists(thisMRA, Presults(sender.getnodedata(paintinfo.node))^[2]) then
     cnv.font.Color:=clGrayText;
  except
 end;
 cnv.TextRect(PaintInfo.CellRect, x,y, Presults(sender.getnodedata(paintinfo.node))^[PaintInfo.Column+1]);
end;

procedure TwpMRAFrm.resultTreeHeaderClick(Sender: TVTHeader; Column: TColumnIndex;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Column = Sender.SortColumn then
   if Sender.SortDirection = sdAscending then
    Sender.SortDirection := sdDescending
   else Sender.SortDirection := sdAscending
  else
   Sender.SortColumn := Column;
end;

procedure TwpMRAFrm.FormPaint(Sender: TObject);
begin
  wallpaperize(canvas);
end;

procedure TwpMRAFrm.Label12Click(Sender: TObject);
begin with onlineChk do checked := not checked end;

procedure TwpMRAFrm.Sendmessage1Click(Sender: TObject);
begin
  if resultTree.SelectedCount = 0 then Exit;
  chatFrm.openOn(selectedContact)
end;

procedure TwpMRAFrm.addcontactAction(sender: Tobject);
begin
  addToRoaster(selectedContact, (sender as TRQmenuitem).tag)
end;

procedure TwpMRAFrm.destroyHandle; begin inherited end;

procedure TwpMRAFrm.FormShow(Sender: TObject);
begin
  applyTaskButton(self);
  theme.pic2ico(RQteFormIcon, PIC_WP, icon);
end;

procedure TwpMRAFrm.menuPopup(Sender: TObject);
begin
  if resultTree.SelectedCount = 0 then
    begin
      AddToCL.visible := False;
      Exit;
    end
   else
    begin
    end;
  AddToCL.visible:=not thisMRA.readList(LT_ROASTER).exists(selectedContact);
  if AddToCL.visible then
    addGroupsToMenu(self, AddToCL, addcontactAction, True);
//  addGroupsToMenu(self, Addtocontactlist1, addcontactAction);
end;

procedure TwpMRAFrm.FormDestroy(Sender: TObject);
var
  i : Integer;
begin
  for i := 0 to menu.Items.Count-1 do
    menu.Items[0].Free;
  menu.Free;
  wpMRAFrm := NIL;
end;

procedure TwpMRAFrm.Label1Click(Sender: TObject);
begin with accumulateChk do checked := not checked end;

procedure TwpMRAFrm.FormResize(Sender: TObject);
begin
//s@X
  // results.height:=clientHeight-sbar.BoundsRect.bottom-5
end;

procedure TwpMRAFrm.menusaveastxt1Click(Sender: TObject);
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
    if savefile(str, s) then
      msgDlg(getTranslation('Done'), mtInformation)
    else
      msgDlg(getTranslation(Str_Error), mtError);
  end;
end;

procedure TwpMRAFrm.menusaveasclb1Click(Sender: TObject);
var
//  i: integer;
  cl: TRnQCList;
  c: TRnQContact;
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
      c := thisMRA.getContact(res[2]);
      c.nick  := res[3];
      c.first := res[4];
      c.last  := res[5];
//      c.email := res[WP_COLUMN_MALE];
      cl.add(c);
      n := resultTree.GetNext(n);
    until n=nil;
   end;
  str := openSavedlg(self, '', false, 'clb');
  if str > '' then
  begin
    if savefile(str, contactlist2clb(cl)) then
      msgDlg(getTranslation('Done'), mtInformation)
    else
      msgDlg(getTranslation(Str_Error), mtError);
    cl.resetEnumeration();
    while cl.hasMore() do
      cl.getNext.Free();
  end;
  cl.free();
end;

procedure TwpMRAFrm.SetControlEnable(Value: Boolean);
begin
  nickBox.Enabled := Value;
  firstBox.Enabled := Value;
  lastBox.Enabled := Value;
  AgeFromSpin.Enabled := Value;
  AgeToSpin.Enabled := Value;
  countryBox.Enabled := Value;
  cityBox.Enabled := Value;
  stateBox.Enabled := Value;
  genderBox.Enabled := Value;
  onlineChk.Enabled := Value;
  accumulateChk.Enabled := Value;
  Label8.Enabled := Value;
  Label9.Enabled := Value;
  Label5.Enabled := Value;
  Label12.Enabled := Value;
  Label1.Enabled := Value;

  emailBox2.Enabled := Value;
  nickBox2.Enabled := Value;
  firstBox2.Enabled := Value;
  lastBox2.Enabled := Value;
{  uinBox2.Enabled := Value;
  InterestCombo2.Enabled := Value;
  keyBox2.Enabled := Value;

  Label2.Enabled := Value;
}


{  nickCPbox.Enabled := Value;
  CountryCPCBox.Enabled := Value;
  CityCPLEdit.Enabled := Value;
  GenderCPCBox.Enabled := Value;
  AgeCPCBox.Enabled := Value;
  LangCPCBox.Enabled := Value;
}
  if Value then
  begin
    searchBtn.Glyph:= PIC_SEARCH;
//    searchBtn.Invalidate;
//    resultTree.OnCompareNodes:= resultsCompare;
  end
  else
  begin
    searchBtn.Glyph:= PIC_CLOSE;
//    searchBtn.Invalidate;
//    results.OnCompare:= nil;
  end;
//  AddSB.Enabled := searchBtn.Enabled and (Nresults > 0);
  AddSB.Enabled := searchBtn.Enabled and (N_Allresults > Nresults);

end;

procedure TwpMRAFrm.pcSearchChange(Sender: TObject);
const
 l1 = 54;
 l2 = 136;
begin
 searchBtn.Parent:= pcSearch.ActivePage;
// AVI.Parent:= pcSearch.ActivePage;
 Caption:= getTranslation('Search by "%s"', [pcSearch.ActivePage.Caption]);

 case TwpSearchType(pcSearch.ActivePageIndex) of
 wpMail:
   begin
     SearchType:= wpMail;
     pcSearch.height:= l1 + emailBox2.Height;
   end;
 wpInfo:
   begin
     SearchType:= wpInfo;
     pcSearch.height:= l1 + emailBox2.Height;
   end;
 wpFull:
   begin
     SearchType:= wpFull;
     pcSearch.height:= l2;
   end;
 else
     SearchType:= wpFull;
     pcSearch.height:= l2;
 end;

end;



end.
