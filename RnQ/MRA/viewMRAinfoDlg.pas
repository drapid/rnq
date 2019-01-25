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
unit viewMRAinfoDlg;
{$I Compilers.inc}
{$I RnQConfig.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  StdCtrls, ExtCtrls, ComCtrls, clipbrd,
  Menus,
//  OverbyteIcsWSocket,
//  wsocket,
  {$IFNDEF NOT_USE_GDIPLUS}
    RnQGraphics,
  {$ELSE}
    RnQGraphics32,
  {$ENDIF NOT_USE_GDIPLUS}
  strutils, RnQButtons, RnQDialogs, RnQSpin, RnQNet,
  globalLib, RnQProtocol;

type
  TviewMRAinfoFrm = class(TRnQViewInfoForm)
    pagectrl: TPageControl;
    mainSheet: TTabSheet;
    Label8: TLabel;
    Label2: TLabel;
    Label14: TLabel;
    ipBox: TEdit;
    genderBox: TComboBox;
    countryBox: TComboBox;
    TabSheet2: TTabSheet;
    dontdeleteChk: TCheckBox;
    mailBtn: TRnQSpeedButton;
    Label28: TLabel;
    uinlistsBox: TMemo;
    groupBox: TLabeledEdit;
    TabSheet1: TTabSheet;
    notesBox: TMemo;
    topPnl: TPanel;
    deleteBtn: TRnQSpeedButton;
    saveBtn: TRnQSpeedButton;
    updateBtn: TRnQSpeedButton;
    nickBox: TLabeledEdit;
    lastBox: TLabeledEdit;
    firstBox: TLabeledEdit;
    emailBox: TLabeledEdit;
    displayBox: TLabeledEdit;
    statusBox: TLabeledEdit;
    cityBox: TLabeledEdit;
    LocBox: TLabeledEdit;
    cellularBox: TLabeledEdit;
    birthBox: TDateTimePicker;
    ageSpin: TRnQSpinEdit;
    birthageBox: TComboBox;
    birthageLbl: TLabel;
    xstatusBox: TLabeledEdit;
    BirthLBox: TDateTimePicker;
    BirthLChk: TCheckBox;
    lastupdateBox: TLabeledEdit;
    lastonlineBox: TLabeledEdit;
    lastmsgBox: TLabeledEdit;
    StatusBtn: TRnQSpeedButton;
    ssNotesGrp: TGroupBox;
    CellularEdt: TLabeledEdit;
    ApplyMyTextBtn: TRnQButton;
    lclNoteStrEdit: TLabeledEdit;
    Bevel3: TBevel;
    ChkSendTransl: TCheckBox;
    protoBox: TLabeledEdit;
    clientBox: TLabeledEdit;
    Bevel1: TBevel;
    Label26: TLabel;
    resolveBtn: TRnQSpeedButton;
    copyBtn: TRnQSpeedButton;
    ipbox2: TMemo;
    PhtGrp: TGroupBox;
    PhotoPBox: TPaintBox;
    PhtLoadBtn: TRnQButton;
    PhtBigLoadBtn: TRnQButton;
    IcShRGrp: TRadioGroup;
    Label1: TLabel;
    ZodiacBox: TComboBox;
    Cellular2Edt: TLabeledEdit;
    Cellular3Edt: TLabeledEdit;
    procedure PhtBigLoadBtnClick(Sender: TObject);
    procedure StatusBtnClick(Sender: TObject);
    procedure PhtLoadBtnClick(Sender: TObject);
    procedure BirthLChkKeyPress(Sender: TObject; var Key: Char);
    procedure BirthLChkClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure updateBtnClick(Sender: TObject);
    procedure deleteBtnClick(Sender: TObject);
    procedure saveBtnClick(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure goBtnClick(Sender: TObject);
    procedure mailBtnClick(Sender: TObject);
    procedure resolveBtnClick(Sender: TObject);
    procedure dnslookup(Sender: TObject; Error: Word);
    procedure copyBtnClick(Sender: TObject);
    procedure addcontactAction(sender:Tobject);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure birthBoxChange(Sender: TObject);
    procedure birthageBoxChange(Sender: TObject);
    procedure OnlyDigitChange(Sender: TObject);
    procedure PhotoPBoxPaint(Sender: TObject);
    procedure avtTSShow(Sender: TObject);
    procedure pagectrlChange(Sender: TObject);
    procedure RnQButton2Click(Sender: TObject);
    procedure statusBoxSubLabelDblClick(Sender: TObject);
    procedure ApplyMyTextBtnClick(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
  protected
    addmenu: TPopupMenu;
    procedure SetPhtBtnEnb(val : Boolean);
  public
//    contact: TMRAContact;
   {$IFDEF RNQ_AVATARS}
//    contactAvt,
    contactPhoto : TRnQBitmap;
   {$ENDIF RNQ_AVATARS}
    lookup : TRnQSocket;
    readOnlyContact:boolean;
    procedure updateInfo; OverRide;
    constructor doAll(owner_ :Tcomponent; c: TRnQContact); OverRide;
    function isUpToDate:boolean;
    procedure setupBirthage;
  end;

var
  viewMRAinfoFrm: TviewMRAinfoFrm;

implementation

uses
  flap, RQCodes, utilLib, mainDlg, langLib, roasterLib, chatDlg,
  RnQLangs, RnQStrings,
 {$IFDEF RNQ_AVATARS}
  RnQ_Avatars,
//  AsyncCalls,
 {$ENDIF}
  RQUtil, RQGlobal, RQThemes, themesLib,
  MRA_proto, MRAContacts, MRAv1,
  menusUnit;

{$R *.DFM}

procedure TviewMRAinfoFrm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
 childWindows.remove(self);
  visible:=FALSE;
  if displayBox.text <> contact.displayed then
   begin
    contact.display:=displayBox.text;
//   SSI_UpdateContact  -- In Contacts.pas

    roasterLib.sort(contact);
    chatFrm.userChanged(contact);
   end;
  if BirthLChk.Checked then
   begin
     contact.birthL := BirthLBox.Date;
   end
  else
    contact.birthL := 0;
//  if contact = ICQ.myInfo then
//    curXStatusStr := xstatusBox.Text;
//  if xstatusBox.Text <> contact.xStatusStr then
//   contact.xStatusStr := xstatusBox.Text;
 TCE(contact.data^).dontdelete:=dontdeleteChk.checked;
 TCE(contact.data^).notes:=notesBox.text;
 contact.lclImportant := lclNoteStrEdit.Text;
 TMRAContact(contact).ssCells  := CellularEdt.Text;
 contact.SendTransl:=ChkSendTransl.checked;

 if (contact.icon.ToShow = IS_PHOTO) xor (IcShRGrp.ItemIndex=0) then
  begin
   case IcShRGrp.ItemIndex of
    0: contact.icon.ToShow := IS_PHOTO;
    1: contact.icon.ToShow := IS_NONE;
   end;
   updateAvatar(contact);
   updateAvatarFor(contact);
  end;
  addmenu.Free;
   {$IFDEF RNQ_AVATARS}
  if Assigned(contactPhoto) then
    contactPhoto.Free;
  contactPhoto := NIL;
   {$ENDIF RNQ_AVATARS}
 action:=caFree;
 destroyHandle;
// self := NIL;
end;

function findInStrings(s:string;ss:Tstrings):integer;
begin
result:=0;
while result < ss.count do
  if ss[result] = s then
    exit
  else
    inc(result);
result:=-1;
end; // findInStrings

procedure TviewMRAinfoFrm.updateInfo;

  function gmt2str(gmt:Tdatetime):string;
  var
    halfs:integer;
  begin
//  result:=getTranslation('GMT')+' ';
  result:='';
  if gmt < 0 then
    begin
    result:=result+'-';
    gmt:=-gmt;
    end
  else
    result:=result+'+';
  halfs:=round(gmt*48);
  if halfs = 100 then
    begin
    result:='';
    exit;
    end;
  result:=result+intToStr(halfs div 2);
  if odd(halfs) then
    result:=result+':30'
  else
    result:=result+':00';
  end; // gmt2str

  function datetime2str(dt:Tdatetime):string; overload;
  begin result:=datetimeTostrMinMax(dt,{1980}80*365,now) end;
var
//  i : Byte;
  sr:TsearchRec;
  b : Boolean;
begin
pagectrl.visible:=FALSE;
with TMRAContact(contact) do
  begin
  caption:=getTranslation('%s',[displayed]);
{  if nodb then
    caption:=caption+getTranslation(' -user not found on server')
  else}
    if infoUpdatedTo = 0 then
      caption:=caption+getTranslation(' -no info')
    else
      if not isUpToDate then
        caption:=caption+getTranslation(' -newer info available on server');
  displayBox.text:=displayed;
  firstBox.text:=first;
  lastBox.text:=last;
  emailBox.text:=UID;
//  cityBox.text:= '';
  cityBox.text:= IntToStr(City_id);
  LocBox.text:= IntToStr(Location_id);
  nickBox.text:=nick;

//  uinBox.text := uid;
{  if contact.iProto.myinfo.equals(contact) then
    ipBox.text:= TICQSession(contact.iProto.ProtoElem).getLocalIPstr
  else
    if connection.ip = 0 then
      ipBox.text:=''
    else
      ipBox.text:=ip2str(connection.ip);
} ipBox.text:='';
  if ipBox.text='' then
    begin
    ipBox.text:=getTranslation(Str_unk);
    resolveBtn.enabled:=FALSE;
    end
  else
    resolveBtn.enabled:=TRUE;
  copyBtn.enabled:=resolveBtn.enabled;
  ipbox2.text:=ipbox.text;
//  if connection.internal_ip<>0 then
//    ipBox2.text:=ipBox2.text+CRLF+getTranslation('Internal IP')+': '+ip2str(connection.internal_ip);
   ipBox2.text:='';
  statusBox.text := getStatusName;
  StatusBtn.ImageName := statusImg;
//  theme.getPic(statusImg, statusImg.Picture.bitmap);
 {$IFDEF RNQ_FULL}
    xstatusBox.text := xStatus.Desc;
 {$ENDIF}
//  cellularBox.text:=hisPhones;
  cellularBox.text:=ssCells;
  
  with genderBox do itemIndex:=findInStrings(GendersByID(gender), Items);
  with countryBox do itemIndex:=findInStrings(MRACountriesByID(Country_id), Items);
  with ZodiacBox do itemIndex:=findInStrings(MRAZodiacsByID(Zodiac), Items);
//  i := interests.Count;
  if birth > 1 then
    try
       birthBox.date:=birth;
       birthageBox.itemIndex:=1;
    except
       birthBox.date:=now;
       birthageBox.itemIndex:=1;
    end
  else
{    if contact.age > 0 then
      begin
      ageSpin.value:=age;
      birthageBox.itemIndex:=2
      end
    else}
      birthageBox.itemIndex:=0;
  setupbirthage;
  if birthL = 0 then  // Установка Birthday By self!!!
   begin
     BirthLBox.Date := Date;
     BirthLChk.Checked := false;
     BirthLBox.Enabled := False;
   end
  else
   begin
     BirthLBox.Date := birthL;
     BirthLChk.Checked := True;
     BirthLBox.Enabled := True;
   end;

  notesBox.text:=TCE(data^).notes;
    lclNoteStrEdit.Text := lclImportant;
    lclNoteStrEdit.Enabled := True;
    CellularEdt.Text   := ssCells;
    CellularEdt.Enabled   := True;

    ApplyMyTextBtn.Enabled :=
            contact.iProto.isOnline;
  dontdeleteChk.checked:=TCE(data^).dontdelete;
  ChkSendTransl.Checked := SendTransl;
  ChkSendTransl.WordWrap := True;

  lastmsgBox.text:=datetime2str( TCE(data^).lastMsgTime );
  lastonlineBox.text:=datetime2str( lastTimeSeenOnline );
  lastupdateBox.text:=datetime2str( infoUpdatedTo );
  lastmsgBox.ReadOnly     := True;
  lastonlineBox.ReadOnly  := True;
  lastupdateBox.ReadOnly  := True;
  if contact.group=0 then
    groupBox.text:='('+getTranslation('Noone')+')'
  else
    groupBox.text:=groups.id2name(contact.group);
  end;
  groupBox.ReadOnly := True;
uinlistsBox.text:='';
uinlists.resetEnumeration;
while uinlists.hasMore do
  with uinlists.getNext^ do
    if cl.exists(contact) then
      uinlistsBox.lines.add(name);
  uinlistsBox.ReadOnly := True;

  clientBox.text:= getClientFor(contact);
  if clientBox.text ='' then clientBox.text:=getTranslation(Str_unk);
  if contact.iProto.isMyAcc(contact) then
   begin
    protoBox.text:='ver.'+intToStr(PROTO_VERSION);
   end
  else
   begin
    protoBox.text:='';//ifThen(contact.proto=0, getTranslation(Str_unk),  'ver.'+intToStr(contact.proto));
   end;

  clientBox.ReadOnly    := True;
  protoBox.ReadOnly     := True;
  ipbox2.ReadOnly       := True;

   {$IFDEF RNQ_AVATARS}

 b := False;
 if FindFirst(userPath + avtPath+contact.UID2cmp + '.photo.*', faAnyFile, sr) = 0 then
 repeat
     b := False;
     if (sr.name<>'.') and (sr.name<>'..') then
 //      if sr.Attr and faDirectory > 0 then
 //        deltree(path+sr.name)
 //      else
       if isSupportedPicFile(userPath + avtPath+sr.name) then
        begin
//          b := pos('.photo.', sr.Name) > 1;
         loadPic(userPath + avtPath+sr.name, contactPhoto);
         b := True;
         Break;
        end;
 until findNext(sr) <> 0;
 findClose(sr);

// if FileExists(userPath + avtPath+contact.uinAsStr + '.photo.jpeg') then
//  loadPic(userPath + avtPath+contact.uinAsStr + '.photo.jpeg', contactPhoto)
//  else
  if not b then
   try
     if Assigned(contactPhoto) then
       contactPhoto.Free;
     contactPhoto := NIL;
    except
   end;
// PhotoPBox.Invalidate;
{
 if Assigned(contact.icon) then
  begin
   AvtImg.Picture.Assign(contact.icon);
   AvtImg.Transparent := contact.icon.Transparent;
  end;
 if FileExists(userPath + avtPath+str2hex(contact.Icon_hash_safe) + '.*') then
  loadPic(userPath + avtPath+contact.uinAsStr + '.photo.jpeg', PhotoImg.Picture.Bitmap);
}
// PhotoImg.Height := 10;
// try_load_avatar3(contactAvt, contact.ICQIcon.hash_safe);
   {$ENDIF RNQ_AVATARS}

// avtSaveBtn.Enabled := ism;
// {$IFNDEF RNQ_FULL or $IFDEF RNQ_LITE}
(*
 {$IFDEF RNQ_LITE}
 PhtLoadBtn.Enabled := False;
 PhtBigLoadBtn.Enabled := False;
 PhtLoadBtn2.Enabled := False;
 PhtLoadBtn3.Enabled := False;
 {$ENDIF RNQ_FULL}
*)
 case contact.icon.ToShow of
  IS_NONE:
    IcShRGrp.ItemIndex := 1;
  IS_PHOTO:
    IcShRGrp.ItemIndex := 0;
 end;
// MarStsBox.Enabled := False;
  pagectrl.visible:=TRUE;

end;

// updateInfo

procedure TviewMRAinfoFrm.updateBtnClick(Sender: TObject);
//var
//  wpS : TwpSearch;
begin
//{  wpS.uin := contact.UID2cmp;
  if OnlFeature(contact.iProto) then
    begin
     TMRASession(contact.iProto.ProtoElem).ReqUserInfo(contact);
    end
end;

constructor TviewMRAinfoFrm.doAll(owner_ :Tcomponent; c:TRnQcontact);
var
  i:integer;
  comp:Tcomponent;
  itsme:boolean;
begin
if c=NIL then exit;
inherited create(owner_);
position:=poDefaultPosOnly;
contact:=c;
applyCommonSettings(self);

//countryBox.Items.text:=CRLF+MRACountrysToStr;
 MRACountrysToCB(countryBox);
genderBox.Items.text:=CRLF+GendersToStr;
//ZodiacBox.Items.text:=CRLF+MRAZodiacsToStr;
  MRAZodiacsToCB(ZodiacBox);
//if contact.infoUpdatedTo = 0 then
//  TICQSession(contact.iProto.ProtoElem).sendQueryInfo(StrToIntDef(contact.UID2cmp, 0));
itsme:= c.iProto.isMyAcc(c);
theme.pic2ico(RQteFormIcon, PIC_INFO, icon);
  updateBtn.ImageName := PIC_LOAD_NET;
  deleteBtn.ImageName := PIC_DELETE;
  mailBtn.ImageName := PIC_MAIL;
{  theme.getPic(PIC_LOAD_NET, updateBtn.Glyph );
  theme.getPic(PIC_DELETE, deleteBtn.Glyph);
  theme.getPic(PIC_URL, goBtn.Glyph);
  theme.getPic(PIC_MAIL, mailBtn.glyph);}
 if itsme then
  begin
    birthBox.MinDate:=now-120*365;
   //birthBox.MaxDate:=now-13*365;
    birthBox.MaxDate:=now;
  end;

for i:=componentcount-1 downto 0 do
  begin
  comp:=components[i];
  if comp is Tmemo then
    (comp as Tmemo).readonly:=not itsme;
  if comp is Tedit then
    (comp as Tedit).readonly:=not itsme;
  if comp is Tdatetimepicker then
    (comp as Tdatetimepicker).enabled:=itsme;
  if comp is Tlabelededit then
    (comp as Tlabelededit).readonly:=not itsme;
  if comp is TComboBox then
    (comp as TComboBox).enabled:=itsme;
//  if (comp is Tcheckbox) then
//    (comp as Tcheckbox).enabled:=itsme;
{  if (comp is Tdateedit) then
    (comp as Tdateedit).readonly:=not itsme; //Rapid}
  if (comp is TRnQSpinEdit) then
    TRnQSpinEdit(comp).readonly:=not itsme;
  end;

displayBox.ReadOnly := False;
//BirthLBox.Enabled := True;
//displayBox.readonly:=itsme;
//displayBox.visible:=not itsme;
deleteBtn.visible:=not itsme;
dontdeleteChk.visible:=not itsme;
ChkSendTransl.visible:=not itsme;
notesBox.readonly:=FALSE;
lclNoteStrEdit.readonly := false;
CellularEdt.ReadOnly   := False;
ipBox.readonly:=TRUE;
statusBox.readonly:=TRUE;
 xstatusBox.readonly := True;
//  xstatusBox.readonly := not itsme;
//uinBox.readonly:=TRUE;
emailBox.readonly:=TRUE;
if itsme then
  begin
   saveBtn.caption:=getTranslation('save my info');
   saveBtn.ImageName := PIC_SAVE_NET;
//  theme.getPic(PIC_SAVE_NET, saveBtn.Glyph);
  end
else
  begin
   saveBtn.caption:=getTranslation('add to list');
   saveBtn.ImageName := PIC_ADD_CONTACT;
//  theme.getPic(PIC_ADD_CONTACT, saveBtn.Glyph);
  end;
   {$IFDEF RNQ_AVATARS}
//  avtSaveBtn.Enabled := itsme;
   {$ENDIF RNQ_AVATARS}

//  StsMsgEdit.Visible := PREVIEWversion;
//  RnQButton2.Visible := itsme and PREVIEWversion;
//  PrivacyTab.TabVisible := itsme and PREVIEWversion;
//  RnQButton2.Visible := itsme;
//  PrivacyTab.TabVisible := UseContactThemes;

 translateWindow(self);
 childWindows.Add(self);
 updateViewInfo(c);
end; // doAll

procedure TviewMRAinfoFrm.deleteBtnClick(Sender: TObject);
begin
if not roasterLib.exists(contact) then
  msgDlg(getTranslation('This contact is NOT in your list'),mtWarning)
else
  if messageDlg(getTranslation('Are you sure you want to delete %s from your list?',[contact.displayed]),mtConfirmation, [mbYes,mbNo], 0) = mrYes then
    roasterLib.remove(contact);
end;

procedure TviewMRAinfoFrm.saveBtnClick(Sender: TObject);
var
  c : TMRAcontact;
//  i, j : Integer;
begin
if not contact.iProto.isMyAcc(contact) then
  begin
  addGroupsToMenu(self,addmenu.items, addcontactAction, True);
  with topPnl.clientToScreen(saveBtn.BoundsRect.bottomRight) do
    addmenu.popup(x,y);
  end
else
  if OnlFeature(contact.iProto) then
    begin
//    c:=Tcontact.create(0);
    c := TMRAContact(contact.iProto.getMyInfo);
    c.uid:=contact.uid;
    c.nick:=nickBox.text;
    c.first:=firstbox.Text;
    c.last:=lastbox.text;
//    c.email:=emailbox.text;

//    c.Country_id:= StrToMRACountryI(countryBox.text);
    c.Country_id:= Integer(countryBox.Items.Objects[countryBox.ItemIndex]);

{    c.city:=citybox.text;
    c.state:=statebox.text;
    if TryStrToInt(c.zip, i) then
      c.zip:=zipBox.text
     else
      c.zip := '';
    c.age:=0;
    c.birth:=0;
    case birthageBox.itemindex of
      1: c.birth:=birthBox.date;
      2: c.age:=round(ageSpin.value);
      end;
    c.cellular:=cellularBox.text;
    c.homepage:=homepageBox.text;
    c.about:=aboutBox.text;
    c.gender:=StrToGenderI(genderBox.text);
    c.lang[1]:=StrToLanguageI(lang1Box.text);
    c.lang[2]:=StrToLanguageI(lang2Box.text);
    c.lang[3]:=StrToLanguageI(lang3Box.text);
    c.MarStatus := StrToMarStI(MarStsBox.Text);
    c.interests.InterestBlock[0].Code := StrToInterestI(Inter1Box.text);
    c.interests.InterestBlock[1].Code := StrToInterestI(Inter2Box.text);
    c.interests.InterestBlock[2].Code := StrToInterestI(Inter3Box.text);
    c.interests.InterestBlock[3].Code := StrToInterestI(Inter4Box.text);
    for i := Low(c.Interests.InterestBlock) to High(c.Interests.InterestBlock) do
     if not Assigned(c.Interests.InterestBlock[i].Names) then
       c.Interests.InterestBlock[i].Names:=TStringList.Create
     else
      c.Interests.InterestBlock[i].Names.Clear;
    c.interests.Count := 0;
    if c.interests.InterestBlock[0].Code > 0 then
     begin
      str2strings(',',Inter1.Text, c.interests.InterestBlock[0].Names);
      inc(c.interests.Count);
     end;
    if c.interests.InterestBlock[1].Code > 0 then
     begin
      str2strings(',',Inter2.Text, c.interests.InterestBlock[1].Names);
      inc(c.interests.Count);
     end;
    if c.interests.InterestBlock[2].Code > 0 then
     begin
      str2strings(',',Inter3.Text, c.interests.InterestBlock[2].Names);
      inc(c.interests.Count);
     end;
    if c.interests.InterestBlock[3].Code > 0 then
     begin
      str2strings(',',Inter4.Text, c.interests.InterestBlock[3].Names);
      inc(c.interests.Count);
     end;
    for i := Low(c.Interests.InterestBlock) to High(c.Interests.InterestBlock) do
      for j := 0 to c.interests.InterestBlock[i].Names.Count-1 do
        c.interests.InterestBlock[i].Names[j] := Trim(c.interests.InterestBlock[i].Names[j]);
    c.GMThalfs:=StrToGMTI(gmtBox.text);
//    c.xStatusStr := xstatusBox.Text;
    pPublicEmail:=publicChk.checked;

    c.workpage := WkpgEdt.Text;
    c.workPos := workPosEdit.Text;
    c.workDep := WorkDeptEdit.Text;
    c.workcity := workCityEdt.Text;
    c.workstate := workStateEdt.Text;
    c.workCountry := StrToCountryI(WorkCntryBox.text);
    c.workzip := workZipEdt.Text;
    c.workphone := WorkCellEdit.Text;
    c.ICQ6Status :=  StsMsgEdit.Text;
    c.workCompany := WorkCompanyEdit.Text;

//    ICQ.sendSaveMyInfoAs(c);
    TicqSession(c.iProto.ProtoElem).sendsaveMyInfoNew(c);
{   // retrieves new datas from the server
    ICQ.sendStatusCode;
    ICQ.sendSimpleQueryInfo(c.uin);}
//    c := NIL;
//    c.free;

    end;
end;

procedure TviewMRAinfoFrm.FormPaint(Sender: TObject);
begin wallpaperize(canvas)end;

procedure TviewMRAinfoFrm.goBtnClick(Sender: TObject);
var
  s:string;
begin
//s:=homepageBox.text;
if trim(s)='' then exit;
if not Imatches(s,1,'http://') then
  s:='http://'+s;
openURL(s);
end;

procedure TviewMRAinfoFrm.mailBtnClick(Sender: TObject);
begin sendEmailTo(contact) end;

procedure TviewMRAinfoFrm.SetPhtBtnEnb(val : Boolean);
begin
 if Application.Terminated then
  Exit;
 if Assigned(self) and Assigned(PhtLoadBtn) then
  try
     PhtLoadBtn.Enabled    := val;
     PhtBigLoadBtn.Enabled := val;
   except
  end;
end;

procedure TviewMRAinfoFrm.PhtBigLoadBtnClick(Sender: TObject);
var
 s : String;
 u, d : AnsiString;
begin
   {$IFDEF RNQ_AVATARS}
 s := userPath + avtPath+contact.UID2cmp + '.photo.jpeg';
 SetPhtBtnEnb(False);
  if Assigned(contactPhoto) then
    contactPhoto.Free;
  contactPhoto := NIL;
 TMRAContact(contact).GetDomUser(d, u);
 if LoadFromURL(format(MRA_PHOTO_URL, [d, u]), s, 0, True) then
    if Assigned(self) then //and Assigned(PhotoImg)and Assigned(PhotoImg.Picture) then
      begin
        loadPic(s, contactPhoto);
        if Assigned(self) and Assigned(PhotoPBox) then
          PhotoPBox.Repaint;
      end;
 SetPhtBtnEnb(True);
   {$ENDIF RNQ_AVATARS}
end;

procedure TviewMRAinfoFrm.PhtLoadBtnClick(Sender: TObject);
var
 s : String;
 u, d : AnsiString;
begin
   {$IFDEF RNQ_AVATARS}
 s := userPath + avtPath+contact.UID2cmp + '.photo.jpeg';
  if Assigned(contactPhoto) then
    contactPhoto.Free;
 contactPhoto := NIL;
 SetPhtBtnEnb(false);
 TMRAContact(contact).GetDomUser(d, u);
 if LoadFromURL(format(MRA_PHOTO_THUMB_URL, [d, u]), s, 0, True) then
    if Assigned(self) then //and Assigned(PhotoImg)and Assigned(PhotoImg.Picture) then
      begin
        loadPic(s, contactPhoto);
        if Assigned(self) and Assigned(PhotoPBox) then
          PhotoPBox.Repaint;
      end;
 SetPhtBtnEnb(True);
   {$ENDIF RNQ_AVATARS}
end;

procedure TviewMRAinfoFrm.resolveBtnClick(Sender: TObject);
begin
  lookup.OnDnsLookupDone:=dnslookup;
  lookup.reverseDnsLookup(ipbox.text)
end;

procedure TviewMRAinfoFrm.RnQButton2Click(Sender: TObject);
begin
//  TicqSession(MainProto.ProtoElem).sendInfoStatus(StsMsgEdit.Text);
//  icq.setStatusStr(StsMsgEdit.Text);
//  sendInfoStatus(s);
end;

procedure TviewMRAinfoFrm.dnslookup(Sender: TObject; Error: Word);
begin
if ipbox2=NIL then exit;
if Error = 0 then
  ipbox2.text:=ipbox2.text+CRLF+TRnQSocket(sender).DnsResultList.text
else
  ipbox2.text:=ipbox2.text+CRLF+getTranslation(Str_Error)+' '+intToStr(error);
end; // dnslookup

procedure TviewMRAinfoFrm.copyBtnClick(Sender: TObject);
begin
if ipbox2.Lines.Count > 1 then
  clipboard.astext:=ipbox2.lines[1];
end;

procedure TviewMRAinfoFrm.addcontactAction(sender:Tobject);
begin addToRoaster(contact, (sender as Tmenuitem).tag) end;

procedure TviewMRAinfoFrm.FormShow(Sender: TObject);
begin
pageCtrl.ActivePageIndex:=0;
applyTaskButton(self);
  PhotoPBox.Invalidate;

end;

procedure TviewMRAinfoFrm.FormCreate(Sender: TObject);
begin
  lookup:=TRnQsocket.create(self);
  proxySettings(MainProxy, lookup);
  addmenu := TPopupMenu.Create(Self);
   {$IFDEF RNQ_AVATARS}
  contactPhoto := NIL;
   {$ENDIF RNQ_AVATARS}
end;

procedure TviewMRAinfoFrm.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if key = #27 then
   begin
     Close;
     key := #0;
   end;
end;

function TviewMRAinfoFrm.isUpToDate:boolean;

  function newer(d:Tdatetime):boolean;
  begin result:=(d>10000) and (d<now) and (d>TMRAContact(contact).infoUpdatedTo) end;

begin
//result:=not (newer(TMRAContact(contact).lastUpdate) //or newer(contact.lastInfoUpdate) or newer(contact.lastStatusUpdate))
result:=True
end;

// isUpToDate

procedure TviewMRAinfoFrm.birthBoxChange(Sender: TObject);
begin setupBirthAge end;

procedure TviewMRAinfoFrm.setupBirthage;
var
  i:integer;
begin
i:=birthageBox.itemIndex;
ageSpin.Visible:= i=2;
birthBox.visible:= i=1;
birthageLbl.visible:= i=0;
end;

procedure TviewMRAinfoFrm.statusBoxSubLabelDblClick(Sender: TObject);
//var
//  wpS : TwpSearch;
begin
//  wpS.uin := contact.uid;
//  wpS.token := contact.InfoToken;
//  TicqSession(contact.iProto.ProtoElem).sendWPsearch2(wpS, 0, False);
end;

procedure TviewMRAinfoFrm.StatusBtnClick(Sender: TObject);
begin
//  TicqSession(contact.iProto.ProtoElem).getUINStatus(contact.UID2cmp);
//  getUINStatus
//  contact
end;

procedure TviewMRAinfoFrm.birthageBoxChange(Sender: TObject);
begin setupBirthage end;

procedure TviewMRAinfoFrm.OnlyDigitChange(Sender: TObject);
begin onlydigits(sender) end;

procedure TviewMRAinfoFrm.pagectrlChange(Sender: TObject);
begin
  PhotoPBox.Invalidate;

end;

procedure TviewMRAinfoFrm.ApplyMyTextBtnClick(Sender: TObject);
begin
 contact.lclImportant := lclNoteStrEdit.Text;
 TMRAContact(contact).ssCells := CellularEdt.Text;
// contact.ssMail := localMailEdt.Text;
  if not contact.CntIsLocal and contact.iProto.isOnline then
    TMRASession(contact.iProto.ProtoElem).SSI_UpdateContact(TMRAContact(contact));
end;

procedure TviewMRAinfoFrm.PhotoPBoxPaint(Sender: TObject);
//var
//  gr : TGPGraphics;
begin
   {$IFDEF RNQ_AVATARS}
  if Assigned(contactPhoto) then
   begin
    DrawRbmp(TPaintBox(PhotoPBox).Canvas.Handle, contactPhoto, DestRect(contactPhoto.GetWidth, contactPhoto.GetHeight,
                  TPaintBox(PhotoPBox).ClientWidth, TPaintBox(PhotoPBox).ClientHeight))
{    gr := TGPGraphics.Create(TPaintBox(sender).Canvas.Handle);
    with DestRect(contactPhoto.GetWidth, contactPhoto.GetHeight,
                  TPaintBox(sender).ClientWidth, TPaintBox(sender).ClientHeight) do
     gr.DrawImage(contactPhoto, Left, Top, Right-Left, Bottom - Top);
    gr.Free;}
   end;
   {$ENDIF RNQ_AVATARS}
end;

procedure TviewMRAinfoFrm.avtTSShow(Sender: TObject);
begin
//  PhotoPBox.Show;
  PhotoPBox.Invalidate;
//  PhotoPBox.Canvas.Refresh;
  PhotoPBoxPaint(PhotoPBox);
end;

procedure TviewMRAinfoFrm.BirthLChkClick(Sender: TObject);
begin
  BirthLBox.Enabled := BirthLChk.Checked
end;

procedure TviewMRAinfoFrm.BirthLChkKeyPress(Sender: TObject; var Key: Char);
begin
  BirthLBox.Enabled := BirthLChk.Checked
end;

end.
