{
This file is part of R&Q.
Under same license
}
unit viewXMPPinfoDlg;
{$I RnQConfig.inc}
{$I NoRTTI.inc}

interface

uses
  Windows, Messages, Types, SysUtils, Classes, Graphics, Controls, Forms,
  StdCtrls, ExtCtrls, ComCtrls, clipbrd,
  Menus,
  strutils, RnQButtons, RnQSpin,
//  OverbyteIcsWSocket,
//  wsocket,
  {$IFNDEF NOT_USE_GDIPLUS}
    RnQGraphics,
  {$ELSE}
    RnQGraphics32,
  {$ENDIF NOT_USE_GDIPLUS}
  RnQDialogs, RnQNet,
  globalLib, RnQProtocol
  ,XMPPcontacts;

type
//  TviewinfoFrm = class(TForm)
  TviewXMPPinfoFrm = class(TRnQViewInfoForm)
    pagectrl: TPageControl;
    mainSheet: TTabSheet;
    Label7: TLabel;
    Label8: TLabel;
    Label2: TLabel;
    Label14: TLabel;
    Label13: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    Label20: TLabel;
    aboutBox: TMemo;
    ipBox: TEdit;
    genderBox: TComboBox;
    countryBox: TComboBox;
    lang1Box: TComboBox;
    lang2Box: TComboBox;
    lang3Box: TComboBox;
    TabSheet2: TTabSheet;
    dontdeleteChk: TCheckBox;
    mailBtn: TRnQSpeedButton;
    Bevel2: TBevel;
    Label28: TLabel;
    uinlistsBox: TMemo;
    groupBox: TLabeledEdit;
    TabSheet1: TTabSheet;
    notesBox: TMemo;
    publicChk: TCheckBox;
    smsChk: TCheckBox;
    topPnl: TPanel;
    deleteBtn: TRnQSpeedButton;
    saveBtn: TRnQSpeedButton;
    updateBtn: TRnQSpeedButton;
    nickBox: TLabeledEdit;
    lastBox: TLabeledEdit;
    firstBox: TLabeledEdit;
    emailBox: TLabeledEdit;
    displayBox: TLabeledEdit;
    uinBox: TLabeledEdit;
    statusBox: TLabeledEdit;
    cityBox: TLabeledEdit;
    stateBox: TLabeledEdit;
    zipBox: TLabeledEdit;
    timeBox: TLabeledEdit;
    cellularBox: TLabeledEdit;
    homepageBox: TLabeledEdit;
    birthBox: TDateTimePicker;
    ageSpin: TRnQSpinEdit;
    birthageBox: TComboBox;
    birthageLbl: TLabel;
    xstatusBox: TLabeledEdit;
    InterSheet: TTabSheet;
    BirthLBox: TDateTimePicker;
    BirthLChk: TCheckBox;
    Bevel1: TBevel;
    ipbox2: TMemo;
    Label26: TLabel;
    resolveBtn: TRnQSpeedButton;
    copyBtn: TRnQSpeedButton;
    ChkSendTransl: TCheckBox;
    protoBox: TLabeledEdit;
    clientBox: TLabeledEdit;
    GroupBox9: TGroupBox;
    Inter1Box: TComboBox;
    Inter2Box: TComboBox;
    Inter3Box: TComboBox;
    Inter1: TEdit;
    Inter2: TEdit;
    Inter3: TEdit;
    Inter4Box: TComboBox;
    Inter4: TEdit;
    Bevel3: TBevel;
    lastupdateBox: TLabeledEdit;
    membersinceBox: TLabeledEdit;
    onlinesinceBox: TLabeledEdit;
    lastonlineBox: TLabeledEdit;
    lastmsgBox: TLabeledEdit;
    CapsLabel: TLabel;
    XstatusBtn: TRnQSpeedButton;
    CliCapsMemo: TMemo;
 // Avatars
    avtTS: TTabSheet;
    AVTGrp: TGroupBox;
    IcShRGrp: TRadioGroup;
    PhtGrp: TGroupBox;
    RnQSpeedButton2: TRnQSpeedButton;
    StatusBtn: TRnQSpeedButton;
    PhtLoadBtn2: TRnQButton;
    PhtLoadBtn3: TRnQButton;
    AvtPBox: TPaintBox;
    PhotoPBox: TPaintBox;
    ClrAvtLbl: TLabel;
    ClrAvtBtn: TRnQButton;
    avtSaveBtn: TRnQButton;
    avtLoadBtn: TRnQButton;
    PhtLoadBtn: TRnQButton;
    PhtBigLoadBtn: TRnQButton;
// Work
    WorkTS: TTabSheet;
    WkpgEdt: TLabeledEdit;
    workCityEdt: TLabeledEdit;
    workStateEdt: TLabeledEdit;
    WorkCntryBox: TComboBox;
    workZipEdt: TLabeledEdit;
    Label1: TLabel;
    WorkCellEdit: TLabeledEdit;
    WorkPosEdit: TLabeledEdit;
    WorkDeptEdit: TLabeledEdit;
    WorkCompanyEdit: TLabeledEdit;
    loginMailEdt: TLabeledEdit;
    GoWkPgBtn: TRnQButton;
    goBtn: TRnQButton;
    LUPDDATEEdt: TEdit;
    LInfoDATEEdt: TEdit;
    PrivacyTab: TTabSheet;
    gmtBox: TComboBox;
    MarStsBox: TComboBox;
    Label3: TLabel;
    StsMsgEdit: TLabeledEdit;
    RnQButton2: TRnQButton;
    Label4: TLabel;
    FontSelectBtn: TRnQSpeedButton;
    ssNotesGrp: TGroupBox;
    ssNoteStrEdit: TLabeledEdit;
    localMailEdt: TLabeledEdit;
    CellularEdt: TLabeledEdit;
    ApplyMyTextBtn: TRnQButton;
    lclNoteStrEdit: TLabeledEdit;
    procedure PhtBigLoadBtnClick(Sender: TObject);
    procedure StatusBtnClick(Sender: TObject);
    procedure PhtLoadBtnClick(Sender: TObject);
    procedure avtSaveBtnClick(Sender: TObject);
    procedure avtLoadBtnClick(Sender: TObject);
    procedure XstatusBtnClick(Sender: TObject);
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
    procedure AvtPBoxPaint(Sender: TObject);
    procedure PhotoPBoxPaint(Sender: TObject);
    procedure GoWkPgBtnClick(Sender: TObject);
    procedure ClrAvtBtnClick(Sender: TObject);
    procedure avtTSShow(Sender: TObject);
    procedure pagectrlChange(Sender: TObject);
    procedure PhtLoadBtn2Click(Sender: TObject);
    procedure PhtLoadBtn3Click(Sender: TObject);
    procedure RnQButton2Click(Sender: TObject);
    procedure statusBoxSubLabelDblClick(Sender: TObject);
    procedure RnQButton3Click(Sender: TObject);
    procedure ApplyMyTextBtnClick(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
  protected
    addmenu: TPopupMenu;
    procedure SetPhtBtnEnb(val : Boolean);
   {$IFDEF RNQ_AVATARS}
    procedure TickAniTimer(Sender: TObject);
   {$ENDIF RNQ_AVATARS}
  public
//    contact: TICQContact;
   {$IFDEF RNQ_AVATARS}
    FAniTimer: TTimer;
    contactAvt,
    contactPhoto: TRnQBitmap;
   {$ENDIF RNQ_AVATARS}
    lookup: TRnQSocket;
//    readOnlyContact:boolean;
    procedure updateInfo; OverRide;
    constructor doAll(owner_ :Tcomponent; c: TRnQContact); OverRide;
    procedure UpdateCntAvatar; OverRide;
    procedure ClearAvatar; OverRide;
    procedure UpdateClock; OverRide;

    function isUpToDate:boolean;
    procedure setupBirthage;
    function getCnt: TxmppContact; inline;
    property cnt: TxmppContact read getCnt;
//    property cnt: TxmppContact read contact;
  end;

//var
//  viewXMPPinfoFrm: TviewXMPPinfoFrm;

implementation

uses
  RDUtils, RDGlobal, RnQLangs, RnQStrings,
  RQUtil, RQThemes, RnQSysUtils, RnQPics,
  RQCodes,
  utilLib, RnQConst,
  mainDlg, langLib, roasterLib, chatDlg,
 {$IFDEF RNQ_AVATARS}
  RnQ_Avatars,
//  AsyncCalls,
 {$ENDIF}
  Protocols_all,
  themesLib,
  XMPPv1,
//  RQ_ICQ, ICQConsts, Protocol_ICQ, ICQv9,
  menusUnit;

{$R *.DFM}

procedure TviewXMPPinfoFrm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
 childWindows.remove(self);
  visible := FALSE;
(*
  if displayBox.text <> contact.displayed then
   begin
    contact.display := displayBox.text;
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
 TCE(contact.data^).dontdelete := dontdeleteChk.checked;
 TCE(contact.data^).notes := notesBox.text;
 contact.lclImportant := lclNoteStrEdit.Text;
// TICQcontact(contact).ssImportant := ssNoteStrEdit.Text;
// TICQcontact(contact).ssCell  := CellularEdt.Text;
// TICQcontact(contact).ssMail := localMailEdt.Text;
 contact.SendTransl := ChkSendTransl.checked;

 if contact.icon.ToShow <> IcShRGrp.ItemIndex then
  begin
   case IcShRGrp.ItemIndex of
    0: contact.icon.ToShow := IS_AVATAR;
    1: contact.icon.ToShow := IS_PHOTO;
    2: contact.icon.ToShow := IS_NONE;
   end;
//   updateAvatar(contact);
//   updateAvatarFor(contact);
  end;
  addmenu.Free;
   {$IFDEF RNQ_AVATARS}
  if Assigned(contactAvt) then
    contactAvt.Free;
  contactAvt := NIL;
  if Assigned(contactPhoto) then
    contactPhoto.Free;
  contactPhoto := NIL;
 FreeAndNil(FAniTimer);
   {$ENDIF RNQ_AVATARS}
*)
 action := caFree;
 destroyHandle;
 self := NIL;
end;

function findInStrings(s: string; ss: Tstrings): integer;
begin
  result := 0;
  while result < ss.count do
    if ss[result] = s then
      exit
     else
      inc(result);
  result := -1;
end; // findInStrings

procedure TviewXMPPinfoFrm.updateInfo;

  function gmt2str(gmt: Tdatetime): string;
  var
    halfs: integer;
  begin
//  result := getTranslation('GMT')+' ';
  result := '';
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

  function datetime2str(dt: Tdatetime): string; overload;
  begin
    result := datetimeTostrMinMax(dt,{1980}80*365,now)
  end;
var
  i: Byte;
  j, k: Integer;
  sr: TsearchRec;
  b: Boolean;
  fn: String;
begin
  pagectrl.visible := FALSE;
with TxmppContact(contact) do
  begin
  caption:=getTranslation('%s',[displayed]);
{  if nodb then
    caption:=caption+getTranslation(' -user not found on server')
  else
    if infoUpdatedTo = 0 then
      caption:=caption+getTranslation(' -no info')
    else
      if not isUpToDate then
        caption:=caption+getTranslation(' -newer info available on server');
}
  displayBox.text:=displayed;
  firstBox.text:=first;
  lastBox.text:=last;
  nickBox.text:=nick;
  uinBox.text := uid;
//  emailBox.text:= email;
{
  cityBox.text:=  city;
  stateBox.text:= state;
  aboutBox.text:=unUTF(about);}
{  if contact.fProto.isMyAcc(contact) then
    ipBox.text:= TxmppSession(contact.iProto.ProtoElem).getLocalIPstr
  else
    if connection.ip = 0 then
      ipBox.text:=''
    else
      ipBox.text:=ip2str(connection.ip);
  if ipBox.text='' then
    begin
    ipBox.text:=getTranslation(Str_unk);
    resolveBtn.enabled:=FALSE;
    end
  else
    resolveBtn.enabled:=TRUE;
  copyBtn.enabled:=resolveBtn.enabled;
  ipbox2.text:=ipbox.text;
  if connection.internal_ip<>0 then
    ipBox2.text:=ipBox2.text+CRLF+getTranslation('Internal IP')+': '+ip2str(connection.internal_ip);
  if xStatusStr > '' then
    statusBox.text := xStatusStr
   else
    statusBox.text :=  statusNameExt2(byte(status), xStatus);
}
//  theme.getPic(statusImg, statusImg.Picture.bitmap);
 {$IFDEF RNQ_FULL}
//    xstatusBox.text := xStatusDesc;
//    XstatusBtn.ImageName := XStatusArray[xStatus].PicName;
//    XstatusBtn.Enabled := xStatus.Desc > '';
    XstatusBtn.Enabled := false;
//  theme.getPic(aXStatus[xStatus].PicName, xstatusImg.Picture.bitmap);
 {$ENDIF}
  StatusBtn.ImageName := statusImg;
  if birth > 1 then
    try
       birthBox.date:=birth;
       birthageBox.itemIndex:=1;
    except
       birthBox.date:=now;
       birthageBox.itemIndex:=1;
    end
  else
{    if age > 0 then
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

  notesBox.text := TCE(data^).notes;
{    ssNoteStrEdit.Text := ssImportant;
    ssNoteStrEdit.Enabled := True;
    lclNoteStrEdit.Text := lclImportant;
    lclNoteStrEdit.Enabled := True;
    CellularEdt.Text   := ssCell;
    CellularEdt.Enabled   := True;
    localMailEdt.Text  := ssMail;
    localMailEdt.Enabled  := True;
}
    ApplyMyTextBtn.Enabled :=
 {$IFDEF UseNotSSI}
            TICQSession(contact.iProto.ProtoElem).useSSI and
 {$ENDIF UseNotSSI}
            contact.fProto.isOnline;
  dontdeleteChk.checked:=TCE(data^).dontdelete;
{
  publicChk.checked := pPublicEmail;
  ChkSendTransl.Checked := SendTransl;
}
  lastmsgBox.text:=datetime2str( TCE(data^).lastMsgTime );
  lastonlineBox.text:=datetime2str( lastTimeSeenOnline );
  lastupdateBox.text:=datetime2str( infoUpdatedTo );
{
  onlinesinceBox.text:=datetime2str( onlineSince );
  membersinceBox.text:=datetime2str( memberSince );
}
  lastmsgBox.ReadOnly     := True;
  lastonlineBox.ReadOnly  := True;
  lastupdateBox.ReadOnly  := True;
  onlinesinceBox.ReadOnly := True;
  membersinceBox.ReadOnly := True;
  if contact.group < 0 then
    groupBox.text := '('+getTranslation('Noone')+')'
  else
    groupBox.text := groups.id2name(contact.group);
// end; // end with
  groupBox.ReadOnly := True;
  uinlistsBox.text:='';
  uinlists.resetEnumeration;
  while uinlists.hasMore do
   with uinlists.getNext^ do
    if cl.exists(contact) then
      uinlistsBox.lines.add(name);
  uinlistsBox.ReadOnly := True;
//  RnQSpeedButton1.Enabled := contact.Icon_hash > '';
//  Image1.Picture.Assign(contact.icon);
{
  LUPDDATEEdt.Text  := IntToHex(Integer(TXMPPcontact(contact).lastUpdate_dw), 8);
  LInfoDATEEdt.Text := IntToHex(TXMPPcontact(contact).lastinfoupdate_dw, 8);
}
  LUPDDATEEdt.ReadOnly := True;
  LInfoDATEEdt.ReadOnly := True;

//  clientBox.text := getClientFor(contact, True);
  clientBox.text := contact.ClientDesc;
  if clientBox.text ='' then clientBox.text:=getTranslation(Str_unk);
{  if contact.fProto.isMyAcc(contact) then
   begin
    protoBox.text:='ver.'+intToStr(My_proto_ver);
    loginMailEdt.Text := Attached_login_email;
   end
  else
   begin
    protoBox.text:=ifThen(TICQcontact(contact).proto=0, getTranslation(Str_unk),  'ver.'+intToStr(TICQcontact(contact).proto));
    loginMailEdt.Text := '';
    loginMailEdt.Visible := False;
   end;
}
  CliCapsMemo.Clear;
  if Length(cnt.resources)>0 then
   for j := Low(cnt.resources) to High(cnt.resources) do
    begin
      CliCapsMemo.Lines.Append('>>>>>>>>'+cnt.resources[j].resID );
      if Length(cnt.resources[j].caps)>0 then
       for k := Low(cnt.resources[j].caps) to High(cnt.resources[j].Caps) do
        CliCapsMemo.Lines.Append(cnt.resources[j].Caps[k]);
    end;

  clientBox.ReadOnly    := True;
  protoBox.ReadOnly     := True;
  loginMailEdt.ReadOnly := True;
  CliCapsMemo.ReadOnly  := True;
  ipbox2.ReadOnly       := True;
{
 WkpgEdt.Text := workpage;
 workPosEdit.Text := workPos;
 WorkDeptEdit.Text := workDep;
 workCityEdt.Text := workcity;
 workStateEdt.Text := workstate;
 with WorkCntryBox do itemIndex:=findInStrings(CountriesByID(workCountry), Items);
 workZipEdt.Text := workzip;
 WorkCellEdit.Text := workphone;
 StsMsgEdit.Text := ICQ6Status;
 WorkCompanyEdit.Text := workCompany;
}
   {$IFDEF RNQ_AVATARS}

 b := False;
 if FindFirst(AccPath + avtPath+contact.uid2Cmp + '.photo.*', faAnyFile, sr) = 0 then
 repeat
     b := False;
     if (sr.name<>'.') and (sr.name<>'..') then
 //      if sr.Attr and faDirectory > 0 then
 //        deltree(path+sr.name)
 //      else
       if isSupportedPicFile(AccPath + avtPath+sr.name) then
        begin
//          b := pos('.photo.', sr.Name) > 1;
         loadPic2(AccPath + avtPath+sr.name, contactPhoto);
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
// try_load_avatar3(contactAvt, ICQIcon.hash_safe);
{
 if not LoadAvtByHash(ICQIcon.hash_safe, contactAvt, b, fn) then
   if Assigned(contactAvt) then
     FreeAndNil(contactAvt);
 avtLoadBtn.Enabled := ICQIcon.hash > '';
      if Assigned(contactAvt) and contactAvt.Animated then
        FAniTimer.Enabled := True
       else
        FAniTimer.Enabled := false;
}
   {$ENDIF RNQ_AVATARS}

// avtSaveBtn.Enabled := ism;
// {$IFNDEF RNQ_FULL or $IFDEF RNQ_LITE}
  case contact.icon.ToShow of
    IS_NONE:
      IcShRGrp.ItemIndex := 2;
    IS_AVATAR:
      IcShRGrp.ItemIndex := 0;
    IS_PHOTO:
      IcShRGrp.ItemIndex := 1;
  end;
// MarStsBox.Enabled := False;

  pagectrl.visible:=TRUE;
 end; // end with
end;

procedure TviewXMPPinfoFrm.XstatusBtnClick(Sender: TObject);
begin
//  TICQSession(contact.iProto.ProtoElem).RequestXStatus(contact.uid);
end;

// updateInfo

procedure TviewXMPPinfoFrm.updateBtnClick(Sender: TObject);
var
  wpS: TwpSearch;
begin
  if OnlFeature(contact.fProto) then
    begin
     wpS.email := contact.UID2cmp;
//     TICQSession(contact.iProto.ProtoElem).sendQueryInfo(StrToIntDef(wpS.uin, 0));
//     wpS.token := TICQcontact(contact).InfoToken;
     TXMPPSession(contact.fProto).sendWPsearch(wpS, 0);
    end
end;

procedure TviewXMPPinfoFrm.UpdateClock;
begin
  inherited;

end;

procedure TviewXMPPinfoFrm.UpdateCntAvatar;
var
 fn: String;
 h: RawByteString;
 b1, b: Boolean;
begin
  inherited;
      begin
  //      frm.AvtImg.Picture.Assign(cnt.icon);
        avtLoadBtn.Enabled := TxmppContact(contact).XIcon.hash > '';
        h := TxmppContact(contact).Icon.Hash_safe;
        b := false;
        if h > '' then
          b := LoadAvtByHash(h, contactAvt, b1, fn);
        if not b then
          if Assigned(contactAvt) then
            FreeAndNil(contactAvt);
//          try_load_avatar3(frm.contactAvt, cnt.ICQIcon.hash_safe);
  //      frm.contactAvt := cnt.icon.Bmp.Clone(0, 0, cnt.icon.Bmp.GetWidth,
  //                         cnt.icon.Bmp.GetHeight, cnt.icon.Bmp.GetPixelFormat);
//        frm.AvtPBox.Repaint;
        AvtPBox.Invalidate;
        if Assigned(contactAvt) and contactAvt.Animated then
          FAniTimer.Enabled := True
         else
          FAniTimer.Enabled := false;
  //      frm.AvtImg.Height := cnt.iconBmp.GetHeight;
  //        gr := TGPGraphics.Create(frm.AvtImg.Canvas.Handle);
  //        gr.DrawImage(cnt.iconBmp, 0, 0,
  //                     cnt.iconBmp.GetWidth, cnt.iconBmp.GetHeight);
  //        gr.Free;
      end;
end;

procedure TviewXMPPinfoFrm.ClearAvatar;
begin
  FreeAndNil(contactAvt);
//    frm.AvtPBox.Repaint;
  AvtPBox.Invalidate;

end;


constructor TviewXMPPinfoFrm.doAll(owner_: Tcomponent; c: TRnQcontact);
var
  i: integer;
  comp: Tcomponent;
  itsme: boolean;
begin
  if c=NIL then
    exit;
  inherited create(owner_);
  position := poDefaultPosOnly;
  contact := c;
  itsme := c.fProto.isMyAcc(c);
  readOnlyContact := not itsme;
  applyCommonSettings(self);
(*
//countryBox.Items.text:=CRLF+CountrysToStr;
   CountrysToCB(countryBox);
//WorkCntryBox.Items.text:=countryBox.Items.text;
   CountrysToCB(WorkCntryBox);
genderBox.Items.text:=CRLF+GendersToStr;
lang1Box.Items.text:=CRLF+LanguagesToStr;
lang2Box.Items.text := lang1Box.Items.text;
lang3Box.Items.text := lang1Box.Items.text;
Inter1Box.Items.text:=CRLF+InterestsToStr;
Inter2Box.Items.text:=Inter1Box.Items.text;
Inter3Box.Items.text:=Inter1Box.Items.text;
Inter4Box.Items.text:=Inter1Box.Items.text;
gmtBox.Items.text:=gmtsToStr;
MarStsBox.Items.Text := MarStsToStr;
//if TXMPPContact(contact).infoUpdatedTo = 0 then
//  TXMPPSession(contact.fProto).sendQueryInfo(StrToIntDef(contact.UID2cmp, 0));
theme.pic2ico(RQteFormIcon, PIC_INFO, icon);
  updateBtn.ImageName := PIC_LOAD_NET;
  deleteBtn.ImageName := PIC_DELETE;
  goBtn.ImageName := PIC_URL;
  GoWkPgBtn.ImageName := goBtn.ImageName;
  mailBtn.ImageName := PIC_MAIL;
{  theme.getPic(PIC_LOAD_NET, updateBtn.Glyph );
  theme.getPic(PIC_DELETE, deleteBtn.Glyph);
  theme.getPic(PIC_URL, goBtn.Glyph);
  theme.getPic(PIC_MAIL, mailBtn.glyph);}
 if itsme then
  begin
    birthBox.MinDate := now-120*365;
   //birthBox.MaxDate:=now-13*365;
    birthBox.MaxDate := now;
  end;

  for i:=componentcount-1 downto 0 do
  begin
  comp:=components[i];
  if comp is Tmemo then
        (comp as Tmemo).readonly := not itsme
      else if comp is Tedit then
        (comp as Tedit).readonly := not itsme
      else if comp is Tdatetimepicker then
        (comp as Tdatetimepicker).enabled := itsme
      else if comp is Tlabelededit then
        (comp as Tlabelededit).readonly := not itsme
      else if comp is TComboBox then
        (comp as TComboBox).enabled := itsme
    //else  if (comp is Tcheckbox) then
    //    (comp as Tcheckbox).enabled := itsme;
    { else if (comp is Tdateedit) then
        (comp as Tdateedit).readonly := not itsme; //Rapid}
      else if (comp is TRnQSpinEdit) then
        TRnQSpinEdit(comp).readonly := not itsme;
  end;
publicChk.visible := itsme;
smsChk.Enabled := itsme;

displayBox.ReadOnly := False;
//BirthLBox.Enabled := True;
//displayBox.readonly := itsme;
//displayBox.visible := not itsme;
deleteBtn.visible := not itsme;
dontdeleteChk.visible := not itsme;
ChkSendTransl.visible := not itsme;
notesBox.readonly := FALSE;
ssNoteStrEdit.readonly := false;
lclNoteStrEdit.readonly := false;
localMailEdt.ReadOnly  := False;
CellularEdt.ReadOnly   := False;
ipBox.readonly := TRUE;
statusBox.readonly := TRUE;
 xstatusBox.readonly := True;
//  xstatusBox.readonly := not itsme;
uinBox.readonly := TRUE;
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
  avtSaveBtn.Visible := itsme;
{
  avtTS.TabVisible := AvatarsSupport;
  ClrAvtBtn.Enabled := (itsme and (myAvatarHash > '')) or
     (not itsme and (TICQContact(contact).ICQIcon.Hash_safe > '')and(TICQContact(contact).ICQIcon.hash = ''));
  ClrAvtLbl.Visible := itsme and ClrAvtBtn.Enabled;
}
   {$ENDIF RNQ_AVATARS}
  LUPDDATEEdt.ReadOnly := True;
  LInfoDATEEdt.ReadOnly := True;
  LUPDDATEEdt.Visible := not itsme;
  LInfoDATEEdt.Visible := not itsme;

//  PrivacyTab.TabVisible := UseContactThemes;
  RnQButton2.Visible := itsme;

//  StsMsgEdit.Visible := PREVIEWversion;
//  RnQButton2.Visible := itsme and PREVIEWversion;
//  PrivacyTab.TabVisible := itsme and PREVIEWversion;
//  RnQButton2.Visible := itsme;
//  PrivacyTab.TabVisible := UseContactThemes;
  PrivacyTab.TabVisible := False;
*)
 translateWindow(self);
 childWindows.Add(self);
 updateViewInfo(c);
end; // doAll

procedure TviewXMPPinfoFrm.deleteBtnClick(Sender: TObject);
begin
  if not contact.isInRoster then
    msgDlg('This contact is NOT in your list', True, mtWarning)
   else
    if messageDlg(getTranslation('Are you sure you want to delete %s from your list?',[contact.displayed]), mtConfirmation, [mbYes,mbNo], 0) = mrYes then
      roasterLib.remove(contact);
end;

procedure TviewXMPPinfoFrm.saveBtnClick(Sender: TObject);
var
  c: TXMPPcontact;
//  i, j: Integer;
begin
if not contact.fProto.isMyAcc(contact) then
  begin
//  addGroupsToMenu(self, contact.fProto, addmenu.items, addcontactAction, True);
  addGroupsToMenu(self, addmenu.items, addcontactAction, True);
  with topPnl.clientToScreen(saveBtn.BoundsRect.bottomRight) do
    addmenu.popup(x,y);
  end
else
  if OnlFeature(contact.fProto) then
    begin
//    c:=Tcontact.create(0);
    c := TXMPPcontact(contact.fProto.getMyInfo);
    c.uid:=contact.uid;
    c.nick:=nickBox.text;
    c.first:=firstbox.Text;
    c.last:=lastbox.text;
{    c.email:=emailbox.text;
    c.city:=citybox.text;
    c.state:=statebox.text;
    if TryStrToInt(c.zip, i) then
      c.zip:=zipBox.text
     else
      c.zip := '';
    c.age:=0;
}
    c.birth:=0;
    case birthageBox.itemindex of
      1: c.birth:=birthBox.date;
//      2: c.age:=round(ageSpin.value);
      end;
{    c.cellular:=cellularBox.text;
    c.homepage:=homepageBox.text;
    c.about:=aboutBox.text;
    c.gender:=StrToGenderI(genderBox.text);
//    c.country:=StrToCountryI(countryBox.text);
    c.country:= CB2ID(countryBox);
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
//    c.workCountry := StrToCountryI(WorkCntryBox.text);
     c.workCountry:= CB2ID(WorkCntryBox);
    c.workzip := workZipEdt.Text;
    c.workphone := WorkCellEdit.Text;
    c.ICQ6Status :=  StsMsgEdit.Text;
    c.workCompany := WorkCompanyEdit.Text;

//    ICQ.sendSaveMyInfoAs(c);
    TXMPPSession(c.fProto.ProtoElem).sendsaveMyInfoNew(c);
}
{   // retrieves new datas from the server
    ICQ.sendStatusCode;
    ICQ.sendSimpleQueryInfo(c.uin);}
//    c := NIL;
//    c.free;
    end;
end;

procedure TviewXMPPinfoFrm.FormPaint(Sender: TObject);
begin wallpaperize(canvas)end;

procedure TviewXMPPinfoFrm.goBtnClick(Sender: TObject);
var
  s: string;
begin
  s := homepageBox.text;
  if trim(s)='' then
    exit;
  if not Imatches(s,1,'http://') then
    s := 'http://'+s;
  openURL(s);
end;

procedure TviewXMPPinfoFrm.GoWkPgBtnClick(Sender: TObject);
var
  s: string;
begin
  s := WkpgEdt.text;
  if trim(s)='' then
    exit;
 if not Imatches(s,1,'http://') then
   s:='http://'+s;
 openURL(s);
end;

procedure TviewXMPPinfoFrm.mailBtnClick(Sender: TObject);
begin
  contact.sendEmailTo
end;

procedure TviewXMPPinfoFrm.SetPhtBtnEnb(val : Boolean);
begin
 if Application.Terminated then
  Exit;
 if Assigned(self) and Assigned(PhtLoadBtn) then
  try
     PhtLoadBtn.Enabled    := val;
     PhtBigLoadBtn.Enabled := val;
     PhtLoadBtn2.Enabled   := val;
     PhtLoadBtn3.Enabled   := val;
   except
  end;
end;

procedure TviewXMPPinfoFrm.PhtBigLoadBtnClick(Sender: TObject);
var
 s: String;
begin
   {$IFDEF RNQ_AVATARS}
 s := AccPath + avtPath+ contact.UID2cmp + '.photo.jpeg';
 SetPhtBtnEnb(False);
  if Assigned(contactPhoto) then
    contactPhoto.Free;
  contactPhoto := NIL;
{
 if LoadFromURL(ICQ_PHOTO_URL + contact.UID2cmp, s, 0, True) then
    if Assigned(self) then //and Assigned(PhotoImg)and Assigned(PhotoImg.Picture) then
      begin
        loadPic2(s, contactPhoto);
        if Assigned(self) and Assigned(PhotoPBox) then
          PhotoPBox.Repaint;
      end;
}
 SetPhtBtnEnb(True);
   {$ENDIF RNQ_AVATARS}
end;

procedure TviewXMPPinfoFrm.PhtLoadBtn2Click(Sender: TObject);
var
 s: String;
begin
   {$IFDEF RNQ_AVATARS}
 s := AccPath + avtPath+contact.UID2cmp + '.photo.jpeg';
  if Assigned(contactPhoto) then
    contactPhoto.Free;
  contactPhoto := NIL;
 SetPhtBtnEnb(False);
{
 if LoadFromURL(Format(ICQ_PHOTO_AVATAR, [contact.UID2cmp, TICQcontact(contact).gender]), s, 0, True) then
    if Assigned(self) then //and Assigned(PhotoImg)and Assigned(PhotoImg.Picture) then
      begin
        loadPic2(s, contactPhoto);
        if Assigned(self) and Assigned(PhotoPBox) then
          PhotoPBox.Repaint;
      end;
}
 SetPhtBtnEnb(True);
   {$ENDIF RNQ_AVATARS}
end;

procedure TviewXMPPinfoFrm.PhtLoadBtn3Click(Sender: TObject);
//var
// s: String;
// prm: TLoadURLParams;
// Dir3: IAsyncCall;
begin
(*
   {$IFDEF RNQ_AVATARS}
 prm.fn := AccPath + avtPath+contact.UID2cmp + '.photo.jpeg';
//  if Assigned(contactPhoto) then
//    contactPhoto.Free;
//  contactPhoto := NIL;
 SetPhtBtnEnb(False);
 prm.URL :=ICQ_PHOTO_USER_URL + contact.UID2cmp;
// prm.fn := s;
 prm.Treshold := 0;
 prm.ExtByContent := True;
 prm.UID := contact.UID;
 prm.Proc :=  @OnPhotoDownLoaded;
{
 SetMaxAsyncCallThreads(100);
// Dir3 := AsyncCall(@LoadFromURL2, Integer(@prm));
 Dir3 := AsyncCallEx(@LoadFromURL2, prm);
 while AsyncMultiSync([Dir3], false, 100) < 0 do
    Application.ProcessMessages;}
 LoadFromURL2(prm);
 SetPhtBtnEnb(True);
   {$ENDIF RNQ_AVATARS}
*)
end;

procedure TviewXMPPinfoFrm.PhtLoadBtnClick(Sender: TObject);
var
 s: String;
begin
   {$IFDEF RNQ_AVATARS}
 s := AccPath + avtPath+contact.UID2cmp + '.photo.jpeg';
  if Assigned(contactPhoto) then
    contactPhoto.Free;
 contactPhoto := NIL;
 SetPhtBtnEnb(false);
{
 if LoadFromURL(ICQ_PHOTO_THUMB_URL + contact.UID2cmp, s, 0, True) then
    if Assigned(self) then //and Assigned(PhotoImg)and Assigned(PhotoImg.Picture) then
      begin
        loadPic2(s, contactPhoto);
        if Assigned(self) and Assigned(PhotoPBox) then
          PhotoPBox.Repaint;
      end;
}
 SetPhtBtnEnb(True);
   {$ENDIF RNQ_AVATARS}
end;

procedure TviewXMPPinfoFrm.resolveBtnClick(Sender: TObject);
begin
  lookup.OnDnsLookupDone := dnslookup;
  lookup.reverseDnsLookup(ipbox.text)
end;

procedure TviewXMPPinfoFrm.RnQButton2Click(Sender: TObject);
begin
//  TXMPPSession(contact.fProto.ProtoElem).sendInfoStatus(StsMsgEdit.Text);
//  icq.setStatusStr(StsMsgEdit.Text);
//  sendInfoStatus(s);
end;

procedure TviewXMPPinfoFrm.RnQButton3Click(Sender: TObject);
var
  I: Integer;
begin
{
  if not Assigned(serverSSI.items) then
    RequestContactList(TicqSession(contact.iProto.ProtoElem), false)
   else
    begin
      i := FindSSIItemType(serverSSI, FEEDBAG_CLASS_ID_PDINFO);
      if i >= 0 then
       with TOSSIItem(serverSSI.items.Objects[i]) do
        TicqSession(contact.iProto.ProtoElem).SSI_DeleteItem(GroupID, ItemID, ItemType);
      serverSSI.items.Delete(i);
    end;
}
end;

procedure TviewXMPPinfoFrm.dnslookup(Sender: TObject; Error: Word);
begin
  if ipbox2 = NIL then
    exit;
  if Error = 0 then
    ipbox2.text := ipbox2.text+CRLF+TRnQSocket(sender).DnsResultList.text
   else
    ipbox2.text := ipbox2.text+CRLF+getTranslation(Str_Error)+' '+intToStr(error);
end; // dnslookup

procedure TviewXMPPinfoFrm.copyBtnClick(Sender: TObject);
begin
if ipbox2.Lines.Count > 1 then
  clipboard.astext := ipbox2.lines[1];
end;

procedure TviewXMPPinfoFrm.addcontactAction(sender: Tobject);
begin addToRoster(contact, (sender as Tmenuitem).tag) end;

procedure TviewXMPPinfoFrm.FormShow(Sender: TObject);
begin
  pageCtrl.ActivePageIndex:=0;
  if readOnlyContact then
    displayBox.setFocus
  else
    nickBox.setFocus;

  applyTaskButton(self);
  PhotoPBox.Invalidate;
  AvtPBox.Invalidate;

end;

procedure TviewXMPPinfoFrm.FormCreate(Sender: TObject);
begin
(*
  lookup:=TRnQsocket.create(self);
  lookup.proxySettings(MainProxy);
  addmenu := TPopupMenu.Create(Self);
*)
   {$IFDEF RNQ_AVATARS}
  contactPhoto := NIL;
  contactAvt   := NIL;
  FAniTimer := TTimer.Create(nil);
  FAniTimer.Enabled := false;
  FAniTimer.Interval := 40;
  //timer.Enabled := UseAnime;
  FAniTimer.OnTimer := TickAniTimer;
   {$ENDIF RNQ_AVATARS}
end;

procedure TviewXMPPinfoFrm.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if key = #27 then
   begin
     Close;
     key := #0;
   end;
end;

function TviewXMPPinfoFrm.isUpToDate: boolean;

//  function newer(d: Tdatetime): boolean;
//  begin result := (d>10000) and (d<now) and (d>TXMPPcontact(contact).infoUpdatedTo) end;

begin
//  with TXMPPcontact(contact) do
//    result:=not (newer(lastUpdate) or newer(lastInfoUpdate) or newer(lastStatusUpdate))
  Result := true;
end;
// isUpToDate

function TviewXMPPinfoFrm.getCnt: TxmppContact;
begin
  Result := TxmppContact(contact);
end;

procedure TviewXMPPinfoFrm.birthBoxChange(Sender: TObject);
begin setupBirthAge end;

procedure TviewXMPPinfoFrm.setupBirthage;
var
  i: integer;
begin
  i := birthageBox.itemIndex;
  ageSpin.Visible := i=2;
  birthBox.visible := i=1;
  birthageLbl.visible := i=0;
end;

procedure TviewXMPPinfoFrm.statusBoxSubLabelDblClick(Sender: TObject);
var
  wpS: TwpSearch;
begin
  wpS.email := contact.uid;
//  wpS.token := TICQcontact(contact).InfoToken;
  TXMPPSession(contact.fProto).sendWPsearch(wpS, 0);
end;

procedure TviewXMPPinfoFrm.StatusBtnClick(Sender: TObject);
begin
//  TXMPPSession(contact.fProto).getUINStatus(contact.UID2cmp);
//  getUINStatus
//  contact
end;

procedure TviewXMPPinfoFrm.birthageBoxChange(Sender: TObject);
begin setupBirthage end;

procedure TviewXMPPinfoFrm.OnlyDigitChange(Sender: TObject);
begin onlydigits(sender) end;

procedure TviewXMPPinfoFrm.pagectrlChange(Sender: TObject);
begin
  PhotoPBox.Invalidate;
  AvtPBox.Invalidate;

end;

procedure TviewXMPPinfoFrm.ApplyMyTextBtnClick(Sender: TObject);
begin
{  with TXMPPcontact(contact) do
   begin
    ssImportant := ssNoteStrEdit.Text;
    lclImportant := lclNoteStrEdit.Text;
    ssCell := CellularEdt.Text;
    ssMail := localMailEdt.Text;
   end;}
  if not contact.CntIsLocal and contact.fProto.isOnline then
    TXMPPSession(contact.fProto).SSI_UpdateContact(TXMPPcontact(contact));
end;

procedure TviewXMPPinfoFrm.avtLoadBtnClick(Sender: TObject);
begin
//  avt_icq.RequestIcon(contact);
  reqAvatarsQ.add(contact);
end;

procedure TviewXMPPinfoFrm.AvtPBoxPaint(Sender: TObject);
//var
//  gr: TGPGraphics;
begin
   {$IFDEF RNQ_AVATARS}
  if Assigned(contactAvt) then
   begin
    if contactAvt.Animated and FAniTimer.Enabled then
      TickAniTimer(NIL)
     else
      DrawRbmp(TPaintBox(sender).Canvas.Handle, contactAvt, DestRect(contactAvt.GetWidth, contactAvt.GetHeight,
                  TPaintBox(sender).ClientWidth, TPaintBox(sender).ClientHeight));
{    gr := TGPGraphics.Create(TPaintBox(sender).Canvas.Handle);
    with DestRect(contactAvt.GetWidth, contactAvt.GetHeight,
                  TPaintBox(sender).ClientWidth, TPaintBox(sender).ClientHeight) do
     gr.DrawImage(contactAvt, Left, Top, Right-Left, Bottom - Top);
    gr.Free;}
   end;
   {$ENDIF RNQ_AVATARS}
end;

procedure TviewXMPPinfoFrm.avtSaveBtnClick(Sender: TObject);
var
  fn: String;
begin
   {$IFDEF RNQ_AVATARS}
//  if OpenSaveFileDialog(Application.Handle, '', 'Pictures (*.gif;*.jpg;*.jpeg;*.png;*.bmp;*.xml)|*.gif;*.jpg;*.jpeg;*.png;*.bmp;*.xml'
  if OpenSaveFileDialog(Application.Handle, '', 'Pictures (*.gif;*.jpg;*.jpeg;*.bmp;*.xml)|*.gif;*.jpg;*.jpeg;*.bmp;*.xml'
//     getSupPicExts + ';'#0 + 'R&Q Pics Files|*.wbmp'
     , '', 'Select R&Q Pic File', fn, True) then
   if isSupportedPicFile(fn) or (lowercase(ExtractFileExt(fn))='.xml') then
    ToUploadAvatarFN := fn;
   {$ENDIF RNQ_AVATARS}
end;

procedure TviewXMPPinfoFrm.PhotoPBoxPaint(Sender: TObject);
//var
//  gr: TGPGraphics;
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

procedure TviewXMPPinfoFrm.avtTSShow(Sender: TObject);
begin
//  PhotoPBox.Show;
  PhotoPBox.Invalidate;
  AvtPBox.Invalidate;
//  PhotoPBox.Canvas.Refresh;
  AvtPBoxPaint(AvtPBox);
  PhotoPBoxPaint(PhotoPBox);
end;

procedure TviewXMPPinfoFrm.BirthLChkClick(Sender: TObject);
begin
  BirthLBox.Enabled := BirthLChk.Checked
end;

procedure TviewXMPPinfoFrm.BirthLChkKeyPress(Sender: TObject; var Key: Char);
begin
  BirthLBox.Enabled := BirthLChk.Checked
end;

procedure TviewXMPPinfoFrm.ClrAvtBtnClick(Sender: TObject);
var
  itsme : Boolean;
begin
   {$IFDEF RNQ_AVATARS}
  itsme := contact.fProto.ismyAcc(contact);
{  if itsme then
   begin
    if TXMPPSession(contact.fProto).SSI_deleteAvatar then
     begin
      myAvatarHash := '';
//      updateAvatarFor(contact);
     end;
   end;
}
//   else
    if Assigned(contact) then
    with TXMPPcontact(contact) do
     begin
//       ICQicon.Hash_safe := '';
       if Assigned(icon.Bmp) then
         try
           icon.Bmp.Free;
          except
           icon.Bmp := NIL;
         end;
       icon.Bmp := NIL;
       if Assigned(contactAvt) then
         contactAvt.Free;
       contactAvt := NIL;
//       updateAvatarFor(contact);
     end;
  AvtPBox.Repaint;
{  ClrAvtBtn.Enabled := (itsme and (myAvatarHash > '')) or
     (not itsme and (TICQcontact(contact).ICQIcon.Hash_safe > '')and(TICQcontact(contact).ICQIcon.hash = ''));
  ClrAvtLbl.Visible := itsme and ClrAvtBtn.Enabled;
}
   {$ENDIF RNQ_AVATARS}
end;

   {$IFDEF RNQ_AVATARS}
procedure TviewXMPPinfoFrm.TickAniTimer(Sender: TObject);
var
  b2: TBitmap;
  paramSmile: TAniPicParams;
//  w, h: Integer;
  resW, resH: Integer;
//  ch: TchatInfo;
begin
//  if not UseAnime then Exit;
//  checkGifTime;
//  ch := thisChat;
//  if (ch = NIL)or (ch.chatType <> CT_ICQ)or not (Assigned(ch.avtPic.Pic))  then
  if (contactAvt = NIL)or not contactAvt.Animated  then
   Exit;
  if not Assigned(AvtPBox) then
    Exit;
  if not contactAvt.RnQCheckTime then
    Exit;
//  w := ch.avtPic.PicAni.Width;
//  h := ch.avtPic.PicAni.Height;
  resW := AvtPBox.ClientWidth;
  resH := AvtPBox.ClientHeight;
  paramSmile.Bounds := DestRect(//w, h,
                  contactAvt.Width, contactAvt.Height,
//                  ch.avtPic.AvtPBox.ClientWidth, ch.avtPic.AvtPBox.ClientHeight);
                  resW, resH);
  paramSmile.Canvas := AvtPBox.Canvas;
  paramSmile.Color := AvtPBox.Color;
  paramSmile.selected := false;
  begin
     if Assigned(paramSmile.Canvas) then
      begin
//        gr := TGPGraphics.Create(paramSmile.Canvas.Handle);
//        if gr.IsVisible(MakeRect(paramSmile.Bounds)) then

//         bmp:= TGPBitmap.Create(Width, Height, PixelFormat32bppRGB);
          b2 := createBitmap(resW, resH);
          b2.Canvas.Brush.Color := paramSmile.color;
          b2.Canvas.FillRect(b2.Canvas.ClipRect);
//           DrawRbmp(b2.Canvas.Handle, ch.avtPic.PicAni);
//           ch.avtPic.PicAni.Draw(b2.Canvas.Handle, 0, 0);
           contactAvt.StretchDraw(b2.Canvas.Handle, paramSmile.Bounds);
          if Assigned(paramSmile.Canvas)
//           and (paramSmile.Canvas.HandleAllocated )
          then
           BitBlt(paramSmile.Canvas.Handle, 0, 0, //paramSmile.Bounds.Left, paramSmile.Bounds.Top,
           resW, resH,
//            w, h,
            b2.Canvas.Handle, 0, 0, SRCCOPY);
        b2.Free;
      end;
  end;
end;
   {$ENDIF RNQ_AVATARS}

end.
