{
  This file is part of R&Q.
  Under same license
}
unit mainDlg;
{$I RnQConfig.inc}
{$I NoRTTI.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  StdCtrls, ExtCtrls, Menus, ActiveX, ActnList,
  VirtualTrees, RDGlobal, RQMenuItem, RnQButtons, RnQDialogs, RnQtrayLib,
  pluginLib, RnQProtocol, System.Actions;

const
  WM_RESOLVE_DNS = WM_USER + 687;

type
  TRnQmain = class(TForm)
    roster: TVirtualDrawTree;
    menu: TPopupMenu;
    Status1: TMenuItem;
    byUIN1: TMenuItem;
    Whitepages1: TMenuItem;
    Password1: TMenuItem;
    Showlogwindow1: TMenuItem;
    in_visiblelist1: TMenuItem;
    contactMenu: TPopupMenu;
    Sendmessage1: TMenuItem;
    Sendcontacts1: TMenuItem;
    Viewinfo1: TMenuItem;
    Delete1: TMenuItem;
    Visiblelist1: TMenuItem;
    Invisiblelist1: TMenuItem;
    Addtocontactlist1: TMenuItem;
    N1: TMenuItem;
    UIN1: TMenuItem;
    N2: TMenuItem;
    divisorMenu: TPopupMenu;
    Newgroup1: TMenuItem;
    Rename1: TMenuItem;
    groupMenu: TPopupMenu;
    Renamegroup1: TMenuItem;
    Deletegroup1: TMenuItem;
    N4: TMenuItem;
    Contactsdatabase1: TMenuItem;
    Moveallcontactsto1: TMenuItem;
    IP1: TMenuItem;
    tovisiblelist1: TMenuItem;
    toinvisiblelist1: TMenuItem;
    Allcontactsvisibility1: TMenuItem;
    tonormalvisibility1: TMenuItem;
    Showgroups1: TMenuItem;
    Showgroups2: TMenuItem;
    movetogroup1: TMenuItem;
    Viewinfoof1: TMenuItem;
    Lock1: TMenuItem;
    Sendemail1: TMenuItem;
    N7: TMenuItem;
    Openallgroups1: TMenuItem;
    Closeallgroups1: TMenuItem;
    Deleteallemptygroups1: TMenuItem;
    N6: TMenuItem;
    Readautomessage1: TMenuItem;
    Showonlyonlinecontacts1: TMenuItem;
    Automessages1: TMenuItem;
    Checkforupdates1: TMenuItem;
    SendanSMS1: TMenuItem;
    Newgroup2: TMenuItem;
    N3: TMenuItem;
    timer: TTimer;
    Ignorelist1: TMenuItem;
    Openchatwith1: TMenuItem;
    mainmenuimportclb: TMenuItem;
    mainmenuexportclb: TMenuItem;
    RQhomepage1: TMenuItem;
    menushowonlyimvisibleto1: TMenuItem;
    mainmenusupport1: TMenuItem;
    mainmenuspecial1: TMenuItem;
    mainmenuprivacysecurity1: TMenuItem;
    mainmenuaddcontacts1: TMenuItem;
    mainmenuvisibility1: TMenuItem;
    mainmenuchangeadduser1: TMenuItem;
    mainmenudeleteofflinemsgs1: TMenuItem;
    mainmenugetofflinemsgs1: TMenuItem;
    mainmenuoutbox1: TMenuItem;
    mainmenureloadlang1: TMenuItem;
    N8: TMenuItem;
    N9: TMenuItem;
    bar: TPanel;
    menuBtn: TRnQSpeedButton;
    statusBtn: TRnQSpeedButton;
    visibilityBtn: TRnQSpeedButton;
    menusendaddedyou1: TMenuItem;
    tempvisiblelist1: TMenuItem;
    tempvisiblelist2: TMenuItem;
    ActList: TActionList;
    ASendmessage1: TAction;
    ASendcontacts1: TAction;
    ASendemail1: TAction;
    Amenusendaddedyou1: TAction;
    Asplit1: TAction;
    AViewinfo1: TAction;
    AReadautomessage1: TAction;
    AAddtocontactlist1: TAction;
    cmAmovetogroup: TAction;
    ARename1: TAction;
    ADelete1: TAction;
    Asplit2: TAction;
    AVisiblelist1: TAction;
    AInvisiblelist1: TAction;
    Atempvisiblelist1: TAction;
    AIgnorelist1: TAction;
    Asplit3: TAction;
    AUIN1: TAction;
    AIP1: TAction;
    mainmenuthemes1: TMenuItem;
    mainmenureloadtheme2: TMenuItem;
    mainmenugetthemes1: TMenuItem;
    N10: TMenuItem;
    ANewgroup1: TAction;
    AOpenallgroups1: TAction;
    ACloseallgroups1: TAction;
    ADeleteallemptygroups1: TAction;
    AShowgroups1: TAction;
    AShowonlyonlinecontacts1: TAction;
    Amenushowonlyimvisibleto1: TAction;
    ADivisor1: TAction;
    Adivisor2: TAction;
    gmANewgroup: TAction;
    gmAdivisor1: TAction;
    gmARenamegroup: TAction;
    gmADeletegroup: TAction;
    gmAMoveallcontactsto: TAction;
    gmAAllcontactsvisibility: TAction;
    gmAVtempvisiblelist: TAction;
    gmAVtovisiblelist: TAction;
    gmAVtoinvisiblelist: TAction;
    gmAVtonormalvisibility1: TAction;
    gmADivisor2: TAction;
    gmAShowgroups: TAction;
    mAStatus: TAction;
    mAvisibility: TAction;
    mAaddcontacts: TAction;
    mAWhitepages: TAction;
    mAbyUIN: TAction;
    mAprivacysecurity: TAction;
    mAPassword: TAction;
    mAin_visiblelist: TAction;
    mALock: TAction;
    mAspecial: TAction;
    mAchangeadduser: TAction;
    mAdeleteofflinemsgs: TAction;
    mAgetofflinemsgs: TAction;
    mAoutbox: TAction;
    mAViewinfoof: TAction;
    mAOpenchatwith: TAction;
    mAContactsdatabase: TAction;
    mAShowlogwindow: TAction;
    mASendanSMS: TAction;
    mAAutomessages: TAction;
    mAreloadlang: TAction;
    mAimportclb: TAction;
    mAexportclb: TAction;
    mAreloadtheme: TAction;
    mAsupport: TAction;
    mACheckforupdates: TAction;
    mAthemes: TAction;
    mARequestCL: TAction;
    mmrequestCL: TMenuItem;
    cACheckInvisibility: TAction;
    CheckInvisibility: TMenuItem;
    mmChkInvisAll: TMenuItem;
    mAChkInvisAll: TAction;
    cARemFrHisCL: TAction;
    menuremovedyou1: TMenuItem;
    cAAuthGrant: TAction;
    Authgrant: TMenuItem;
    cAChkInvisList: TAction;
    Checkinginvislist1: TMenuItem;
    mAHistoryUtils: TAction;
    Historyutilities1: TMenuItem;
    mARefreshThemeList: TAction;
    mASinchrCL: TAction;
    mmSinchrServCL: TMenuItem;
    Showallcontactsinone1: TMenuItem;
    AContInOne: TAction;
    Readextstatus1: TMenuItem;
    authReq: TMenuItem;
    Requestavatar1: TMenuItem;
    ARequestAvt: TAction;
    cAAuthReqst: TAction;
    cADeleteWH: TAction;
    Deletewithhistory1: TMenuItem;
    Newcontact1: TMenuItem;
    gmANewContact: TAction;
    Addcontact1: TMenuItem;
    cAReadXst: TAction;
    TopLbl: TLabel;
    FilterBar: TPanel;
    FilterEdit: TEdit;
    FilterClearBtn: TRnQSpeedButton;
    gmANewContactLocal: TAction;
    cAAdd2Server: TAction;
    Addtoserver1: TMenuItem;
    gmAAdd2Server: TAction;
    Addtoserver2: TMenuItem;
    cAMakeLocal: TAction;
    Makelocal1: TMenuItem;
    gmAMakeLocal: TAction;
    Makelocal2: TMenuItem;
    RQHelp1: TMenuItem;
    ViewSSI1: TMenuItem;
    mAThmCntEdt: TAction;
    Opencontactstheme: TMenuItem;
    N5: TMenuItem;
    mAViewSSI: TAction;
    SmilesMenu: TMenuItem;
    mASmiles: TAction;
    SoundsMenu: TMenuItem;
    mASounds: TAction;
    Deleteonlyhistory1: TMenuItem;
    cADeleteOH: TAction;
    Sendfile1: TMenuItem;
    cASendFile: TAction;
    MlCntBtn: TRnQButton;
    SendSMS1: TMenuItem;
    ASendSMS: TAction;
    Openincomingfolder1: TMenuItem;
    MMGenError: TMenuItem;
    procedure cAReadXstUpdate(Sender: TObject);
    procedure mASinchrCLUpdate(Sender: TObject);
    procedure cADeleteWHUpdate(Sender: TObject);
    procedure ADelete1Update(Sender: TObject);
    procedure cADeleteWHExecute(Sender: TObject);
    procedure mAHelpUpdate(Sender: TObject);
    procedure mAHelpExecute(Sender: TObject);
    procedure ARequestAvtUpdate(Sender: TObject);
    procedure Requestavatar1Click(Sender: TObject);
    procedure authReqClick(Sender: TObject);
    procedure Readextstatus1Click(Sender: TObject);
    procedure AContInOneUpdate(Sender: TObject);
    procedure Showallcontactsinone1Click(Sender: TObject);
    procedure menuPopup(Sender: TObject);
    procedure StatusMenuPopup(Sender: TObject);
    procedure Aautomessage1splitUpdate(Sender: TObject);
    procedure mAXStatusUpdate(Sender: TObject);
    procedure mAXStatusExecute(Sender: TObject);
   {$IFDEF RNQ_PLAYER}
    procedure mARnQPlayerExecute(Sender: TObject);
   {$ENDIF RNQ_PLAYER}
    procedure mASinchrCLExecute(Sender: TObject);
    procedure mAChkInvisAllUpdate(Sender: TObject);
    procedure statusBtnMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure mAHistoryUtilsExecute(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure StatusMenuClick(Sender: TObject);
    procedure VisMenuClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure password1Click(Sender: TObject);
    procedure Delete1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure byUIN1Click(Sender: TObject);
    procedure Whitepages1Click(Sender: TObject);
    procedure Sendmessage1Click(Sender: TObject);
    procedure Hide1Click(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure viewinfo1Click(Sender: TObject);
    procedure About1Click(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure Sendcontacts1Click(Sender: TObject);
    procedure in_visiblelist1Click(Sender: TObject);
    procedure Showlogwindow1Click(Sender: TObject);
    procedure Preferences1Click(Sender: TObject);
    procedure Changeoradduser1Click(Sender: TObject);
    procedure Visiblelist1Click(Sender: TObject);
    procedure invisiblelist1Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure Viewmyinfo1Click(Sender: TObject);
    procedure UIN1Click(Sender: TObject);
    procedure Newgroup1Click(Sender: TObject);
    procedure Rename1Click(Sender: TObject);
    procedure Renamegroup1Click(Sender: TObject);
    procedure Opengroup1Click(Sender: TObject);
    procedure Closegroup1Click(Sender: TObject);
    procedure Deletegroup1Click(Sender: TObject);
    procedure Closeallgroups1Click(Sender: TObject);
    procedure Openallgroups1Click(Sender: TObject);
    procedure Contactsdatabase1Click(Sender: TObject);
    procedure Deleteallemptygroups1Click(Sender: TObject);
    procedure movecontactsAction(sender: Tobject);
    procedure displayHint(Sender: TObject);
    procedure IP1Click(Sender: TObject);
    procedure AppActivate(Sender: TObject);
    procedure tovisiblelist1Click(Sender: TObject);
    procedure toinvisiblelist1Click(Sender: TObject);
    procedure tonormalvisibility1Click(Sender: TObject);
    procedure Showgroups1Click(Sender: TObject);
    procedure Showgroups2Click(Sender: TObject);
    procedure Viewinfoof1Click(Sender: TObject);
    procedure Outbox1Click(Sender: TObject);
    procedure Lock1Click(Sender: TObject);
    procedure SendanSMS1Click(Sender: TObject);
    procedure Sendemail1Click(Sender: TObject);
    procedure addcontactAction(sender: Tobject);
    procedure menuBtnClick(Sender: TObject);
    procedure divisorMenuPopup(Sender: TObject);
    procedure groupMenuPopup(Sender: TObject);
    procedure contactMenuPopup(Sender: TObject);
    procedure Automessage1Click(Sender: TObject);
    procedure Showonlyonlinecontacts1Click(Sender: TObject);
    procedure statusBtnClick(Sender: TObject);
    procedure visibilityBtnClick(Sender: TObject);
    procedure Checkforupdates1Click(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure OnTimer(Sender: TObject);
    procedure Ignorelist1Click(Sender: TObject);
    procedure Openchatwith1Click(Sender: TObject);
    procedure Getofflinemessages1Click(Sender: TObject);
    procedure Deleteofflinemessages1Click(Sender: TObject);
    procedure mainmenuimportclbClick(Sender: TObject);
    procedure mainmenuexportclbClick(Sender: TObject);
    procedure RQhomepage1Click(Sender: TObject);
//    procedure RQforum1Click(Sender: TObject);
//    procedure RQwhatsnew1Click(Sender: TObject);
    procedure rosterKeyPress(Sender: TObject; var Key: Char);
    procedure rosterMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure rosterDblClick(Sender: TObject);
    procedure rosterKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure rosterCompareNodes(Sender: TBaseVirtualTree; Node1,
      Node2: PVirtualNode; Column: TColumnIndex; var Result: Integer);
    procedure rosterMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure rosterCollapsed(Sender: TBaseVirtualTree;
      Node: PVirtualNode);
    procedure rosterCollapsing(Sender: TBaseVirtualTree;
      Node: PVirtualNode; var Allowed: Boolean);
    procedure rosterDragOver(Sender: TBaseVirtualTree; Source: TObject;
      Shift: TShiftState; State: TDragState; Pt: TPoint; Mode: TDropMode;
      var Effect: Integer; var Accept: Boolean);
    procedure rosterDragDrop(Sender: TBaseVirtualTree; Source: TObject;
      DataObject: IDataObject; Formats: TFormatArray; Shift: TShiftState;
      Pt: TPoint; var Effect: Integer; Mode: TDropMode);
    procedure rosterFocusChanged(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex);
    procedure menushowonlyimvisibleto1Click(Sender: TObject);
    procedure rosterDrawNode(Sender: TBaseVirtualTree;
      const PaintInfo: TVTPaintInfo);
    procedure rosterFocusChanging(Sender: TBaseVirtualTree; OldNode,
      NewNode: PVirtualNode; OldColumn, NewColumn: TColumnIndex;
      var Allowed: Boolean);
    procedure mainmenureloadtheme1Click(Sender: TObject);
    procedure mainmenureloadlang1Click(Sender: TObject);
    procedure menuDrawItem(Sender: TObject; ACanvas: TCanvas;
      ARect: TRect; State: TOwnerDrawState);
{    procedure menuDrawItem(Sender: TMenu; Item: TMenuItem; R: TRect;
      State: TOwnerDrawState);}
    procedure menuMeasureItem(Sender: TObject; ACanvas: TCanvas;
      var Width, Height: Integer);

    procedure FormCreate(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure rosterKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure menusendaddedyou1Click(Sender: TObject);
    procedure tempvisiblelist1Click(Sender: TObject);
    procedure Readautomessage1Click(Sender: TObject);
    procedure AReadautomessage1Update(Sender: TObject);
    procedure rosterMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure rosterGetHintSize(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex; var R: TRect);
    procedure rosterDrawHint(Sender: TBaseVirtualTree;
      HintCanvas: TCanvas; Node: PVirtualNode; R: TRect;
      Column: TColumnIndex);
    procedure minBtnClick(Sender: TObject);
    procedure tempvisiblelist2Click(Sender: TObject);
    procedure AAutomessage1Update(Sender: TObject);
    procedure AUIN1Update(Sender: TObject);
    procedure AIP1Update(Sender: TObject);
    procedure ASendemail1Update(Sender: TObject);
    procedure cmAmovetogroupUpdate(Sender: TObject);
    procedure Atempvisiblelist1Update(Sender: TObject);
    procedure contactMenuNEWPopup(Sender: TObject);
    procedure mainmenugetthemes1Click(Sender: TObject);
    procedure AShowgroups1Update(Sender: TObject);
    procedure AShowonlyonlinecontacts1Update(Sender: TObject);
    procedure Amenushowonlyimvisibleto1Update(Sender: TObject);
    procedure ANothingExecute(Sender: TObject);
    procedure AVisiblelist1Update(Sender: TObject);
    procedure AInvisiblelist1Update(Sender: TObject);
    procedure AIgnorelist1Update(Sender: TObject);
    procedure mAStatusUpdate(Sender: TObject);
    procedure mAvisibilityUpdate(Sender: TObject);
    procedure mAgetofflinemsgsUpdate(Sender: TObject);
    procedure mAdeleteofflinemsgsUpdate(Sender: TObject);
    procedure mARequestCLExecute(Sender: TObject);
    procedure cACheckInvisibilityExecute(Sender: TObject);
    procedure cACheckInvisibilityUpdate(Sender: TObject);
    procedure mAChkInvisAllExecute(Sender: TObject);
    procedure cARemFrHisCLExecute(Sender: TObject);
    procedure cAAuthGrantExecute(Sender: TObject);
    procedure cAAuthGrantUpdate(Sender: TObject);
    procedure cAChkInvisListExecute(Sender: TObject);
    procedure cAChkInvisListUpdate(Sender: TObject);
    procedure sbarDblClick(Sender: TObject);
    procedure sbarMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure sbarMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure mAhideUpdateEx(Sender: TObject);
    procedure FilterClearBtnClick(Sender: TObject);
    procedure FilterEditChange(Sender: TObject);
    procedure FilterEditKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure TopLblDblClick(Sender: TObject);
    procedure cAAdd2ServerUpdate(Sender: TObject);
    procedure cAAdd2ServerExecute(Sender: TObject);
    procedure ARename1Update(Sender: TObject);
    procedure gmAAdd2ServerUpdate(Sender: TObject);
    procedure gmAAdd2ServerExecute(Sender: TObject);
    procedure cAMakeLocalUpdate(Sender: TObject);
    procedure cAMakeLocalExecute(Sender: TObject);
    procedure gmAMakeLocalUpdate(Sender: TObject);
    procedure gmAMakeLocalExecute(Sender: TObject);
    procedure cAAuthReqstUpdate(Sender: TObject);
    procedure rosterMeasureItem(Sender: TBaseVirtualTree;
      TargetCanvas: TCanvas; Node: PVirtualNode; var NodeHeight: Integer);
    procedure PntBarPaint(Sender: TObject);
    procedure mARequestCLUpdate(Sender: TObject);
    procedure RQHelp1Click(Sender: TObject);
    procedure ViewSSI1Click(Sender: TObject);
    procedure mAThmCntEdtExecute(Sender: TObject);
    procedure cADeleteOHUpdate(Sender: TObject);
    procedure cADeleteOHExecute(Sender: TObject);
    procedure cASendFileUpdate(Sender: TObject);
    procedure cASendFileExecute(Sender: TObject);
    procedure MlCntBtnClick(Sender: TObject);
    procedure ASendSMSUpdate(Sender: TObject);
    procedure ASendSMSExecute(Sender: TObject);
    procedure mAViewSSIUpdate(Sender: TObject);
    procedure Openincomingfolder1Click(Sender: TObject);
  {$IFDEF usesDC}
    procedure WMDROPFILES(var Message: TWMDROPFILES);  message WM_DROPFILES;
  {$ENDIF usesDC}
    procedure WMDNSLookUp(var pMsg: TMessage); message WM_RESOLVE_DNS;
    procedure MMGenErrorClick(Sender: TObject);
    procedure FormAfterMonitorDpiChanged(Sender: TObject; OldDPI,
      NewDPI: Integer);
    procedure onAeroChanged();
    procedure onTrayEvent(sender: Tobject; ev: TtrayEvent);
  private
    FMouseInControl : Boolean;
    toggling        : Boolean;
//    MainPlugBtns    : TPlugButtons;
// {$IFDEF Use_Baloons}
//		procedure offballoons(var msg:tmessage); //message WM_TIMERNOTIFY;
// {$ENDIF Use_Baloons}
//    procedure WMWINDOWPOSCHANGING(Var Msg: TWMWINDOWPOSCHANGING);
//             message WM_WINDOWPOSCHANGING;
    procedure CMMouseEnter(var Msg: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Msg: TMessage); message CM_MOUSELEAVE;
//    procedure trackingMouse(isHov : Boolean);
//    movetogroupNEW : TMenuItem;
//    addtocontactlistNEW : TMenuItem;
    procedure SelectTheme(Sender: TObject);
    procedure SelectSmiles(Sender: TObject);
    procedure SelectSounds(Sender: TObject);
//    procedure UpdatePluginPanel;
   { $IFDEF RNQ_FULL
    procedure ChangeNewStatus(Sender: TObject);
   {$ENDIF}
    procedure CreateMenus;
  public
    clickedOnAcontact: boolean;
    vismenuExt: TPopupMenu;
//    vismenuNEW: TPopupMenu;
    statusMenuNEW: TPopupMenu;
    oldHandle: THandle;
   { $IFDEF RNQ_FULL
//    xStatusMenu: TPopupMenu;
   {$ENDIF}
//    contactMenuNEW: TPopupMenu;
//    PntBar: TPaintBox;
    PntBar: TRnQPntBox;
    procedure ReStart(Sender: TObject);
    procedure splashPaint(Sender: TObject);
    procedure WndProc(var msg: TMessage); override;
    procedure updateCaption;
    function  clickedGroupList: TRnQCList;
    procedure addContactsAction(Sender: TObject);
    procedure sendContactsAction(Sender: TObject);
    procedure toggleVisible;
    procedure doAutosize;
    procedure closeAllChildWindows;
    procedure doSearch;
    procedure dnslookup(sender: Tobject; error: word);
    procedure updateStatusGlyphs;
    procedure roasterKeyEditing(Sender: TObject; var Key: Char);
    procedure roasterStopEditing(sender: Tobject);
    procedure pwdBoxKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
//    procedure CreateParams(var Params: TCreateParams); override;
     PROCEDURE wmNCHitTest(VAR Msg: TWMNCHitTest); message WM_NCHITTEST;
//    function AddMainMenuItem(wPar: WPARAM; lPar: LPARAM): Integer; cdecl;
    function AddContactMenuItem(pMI: PCLISTMENUITEM ): Integer;// cdecl;
{    function  AddContactMenuItem(pPluginProc: Pointer; menuIcon: hIcon; menuCaption: String;
              menuHint: string; //procIdx: Integer;
              position: Integer;
              PopupName: String; popupPosition: Integer;
              hotKey: DWORD; PicName: String = ''): integer;}
//    function  UpdateContactMenuItem(menuHandle: hmenu; pMI: PCLISTMENUITEM): Integer;// cdecl;
    procedure UpdateContactMenuItem(menuHandle: hmenu; pMI: PCLISTMENUITEM);// cdecl;
    procedure DelContactMenuItem(menuHandle: hmenu);
    procedure OnPluginMenuClick(Sender: TObject);
    property  currentPPI: Integer read GetParentCurrentDpi;
  end; // TmainFrm

var
  RnQmain: TRnQmain;

implementation

uses
  Themes, UxTheme, DwmApi, Types,
  Clipbrd, ShellAPI, strutils, math,
  addContactDlg, chatDlg,
   {$IFDEF RNQ_FULL2}
//     importDlg,
   {$ENDIF}
  aboutDlg, selectContactsDlg,
  incapsulate, visibilityDlg, usersDlg, changePwdDlg,// dbDlg,
  outboxDlg, automsgDlg, RnQConst, globalLib, authreqDlg,
  utilLib, events, roasterLib,
  themesLib,
  history, iniLib,
  //smsDlg,
  langLib, outboxLib, uinlistLib,
  pluginutil,
// {$IFNDEF RNQ_LITE}
  prefDlg, RnQPrefsLib,
// {$ENDIF RNQ_LITE}
 {$IFNDEF DB_ENABLED}
  histUtilsDlg,
 {$ENDIF ~DB_ENABLED}
 {$IFDEF RNQ_FULL}
 {$ENDIF}
  hook,
  OverbyteIcsWSocket,
  RnQFileUtil, RDFileUtil, RDUtils, RnQSysUtils, tipDlg,
  RQUtil, RQLog, RQThemes, RnQMenu, RnQPics,
  RnQLangs, RnQStrings, RnQNet, RnQGlobal,
  RnQdbDlg, RnQTips, RnQMacros,
  RnQProtoUtils,
  Protocols_all, // ICQ, MRA
 {$IFDEF PROTOCOL_ICQ}
  ICQv9,
  ICQConsts,
  Protocol_icq,
  ICQcontacts,
 {$ENDIF PROTOCOL_ICQ}

  {$IFDEF USE_GDIPLUS}
    RnQGraphics,
  {$ELSE}
    RnQGraphics32,
  {$ENDIF USE_GDIPLUS}
 {$IFDEF RNQ_PLAYER}
  uSimplePlayer,
 {$ENDIF RNQ_PLAYER}
  menusUnit, statusform;

{$R *.DFM}

procedure TRnQmain.FormShow(Sender: TObject);
begin
  utilLib.dockSet;
  autosizeDelayed := TRUE;
  mainfrmHandleUpdate;
end;

procedure TRnQmain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  canClose := True;
  canClose := not quitconfirmation or (messageDlg(getTranslation('Really quit?'), mtConfirmation, [mbYes,mbNo],0) = mrYes);
//if canclose then quit;
end;

procedure TRnQmain.FormAfterMonitorDpiChanged(Sender: TObject; OldDPI,
  NewDPI: Integer);
begin
  themeslib.applySizes(OldDPI, NewDPI);
end;

procedure TRnQmain.onAeroChanged();
begin
  if StyleServices.Enabled and DwmCompositionEnabled then
    begin
//     bar.BevelEdges := [];
     bar.BevelKind := bkNone;
     roster.DoubleBuffered := True;
     TCustomControl(roster).DoubleBuffered := True;
    end
   else
    begin
     bar.BevelKind := bkFlat;
     roster.DoubleBuffered := False;
     TCustomControl(roster).DoubleBuffered := False;
    end;
end;

procedure TRnQmain.onTrayEvent(sender: Tobject; ev: TtrayEvent);
begin
    if not locked and running then
      case ev of
        TE_CLICK:
           begin
             if (not useSingleClickTray)
//              or (useSingleClickTray and RnQmain.Visible and not alwaysOnTop and not (RnQmain.handle=getForegroundWindow))
              then
               SetForegroundWindow(self.Handle)
              else
               begin
//                mainfrm.toggleVisible
//                if not mainFrm.Visible then
//                  mainFrm.toggleVisible;
                 trayAction;
               end;
           end;
        TE_2CLICK: if (not useSingleClickTray) then trayAction;
        TE_RCLICK:
          if GetAsyncKeyState(VK_CONTROL) shr 7 <> 0 then
            eventQ.clear
          else
            begin
             ForceForegroundWindow(self.handle);
             with mousePos do
               menu.Popup(x, y);
            end;
        end;
end;

procedure TRnQmain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  quit;
end;

procedure TRnQmain.closeAllChildWindows;
var
  i: integer;
  c: Tcomponent;
begin
  i := childWindows.Count-1;
  while i >= 0 do
  begin
   c := childWindows.Items[i];
   if c is Tform then
    with c as Tform do
      if visible then
       begin
//        childWindows.Items[i] := NIL;
        close;
       end;
   dec(i);
  end;

  i := componentcount-1;
  while i >= 0 do
   begin
    c := components[i];
    if c is Tform then
     with c as Tform do
      if visible then
        close;
    dec(i);
   end;
 {$IFDEF RNQ_PLAYER}
  FreeAndNil(RnQPlayer);
 {$ENDIF RNQ_PLAYER}
  FreeAndNil(RnQdbFrm);
end; // closeAllChildWindows

procedure TRnQmain.updateCaption;
var
  MyInf: TRnQContact;
begin
  MyInf := NIL;
  if Assigned(Account.AccProto) then
    MyInf := Account.AccProto.getMyInfo;
  if Assigned(MyInf) then
//     and Assigned(Account.AccProto.MyInfo) then
    with MyInf do
    caption:=template(rosterTitle, [
      '%nick%', nick,
      '%uin%', uin2Show,
      '%build%', IntToStr(RnQBuild)
     ])
   else
    caption:=template(rosterTitle, [
      '%title%', Application.Title,
      '%nick%', Str_unk,
      '%uin%', Str_unk,
      '%build%', IntToStr(RnQBuild)
     ]);

  chatFrm.Caption := RnQmain.Caption+' - '+getTranslation('Chat window');
end; // updateCaption

procedure TRnQmain.toggleVisible;
var
  timeout: integer;
begin
  if toggling then
    Exit;
  try
   toggling := True;
   if bringForeground > 0 then
     Exit;

  if formVisible(self) and (windowstate<>wsMinimized) then
    begin
      if minimizeRoster then
        begin
        { tipfrm is hided anyway, but if we don't do it manually it will reapper
        { just as the roster repops up }
        TipsHideAll;
  //       ShowWindow()
  //      if transparency.forRoster then
  //        AnimateWindow(self.Handle, 1000, AW_HIDE);
  //       else
  //        AnimateWindow(self.Handle, 100, AW_BLEND or AW_HIDE);
         if Self.Floating then
           WindowState := wsMinimized
          else
           if docking.Dock2Chat and docking.Docked2chat then
             chatFrm.WindowState := wsMinimized
           ;
        end;
      { sometimes form is not hided after minimization, maybe it is a matter of
      { timeouts. this loop could fix the problem }
      timeout := 0;
      if docking.Dock2Chat and docking.Docked2chat AND NOT Self.Floating then
        repeat
          if timeout > 0 then
            sleep(10);
          chatFrm.hide;
          inc(timeout);
        until not formVisible(chatFrm) or (timeout=100)
       else
        repeat
          if timeout > 0 then
            sleep(10);
          hide;
          inc(timeout);
        until not formVisible(self) or (timeout=100);
    end
  else
    begin
{      if Self.Floating then
        if windowstate=wsMinimized then
          windowstate:=wsNormal
         else
          windowstate:=wsMinimized;
}
//      if windowstate = wsNormal then
      if docking.Dock2Chat and docking.Docked2chat and not Self.Floating then
       begin
          try
           chatFrm.show;
          except
          end;
          Application.BringToFront;
          bringForeground := chatFrm.Handle;
       end
      else
      begin
        try
    //      if transparency.forRoster then
    //        AnimateWindow(self.Handle, 50, AW_ACTIVATE);
    //       else
    //        AnimateWindow(self.Handle, 100, AW_BLEND);
         if windowstate<>wsMinimized then
           windowstate := wsMinimized;
         windowstate := wsNormal;
         show;
        except
        end;
        Application.BringToFront;
        bringForeground := handle;
      end;
    end;
 finally
  toggling := False;
  mainfrmHandleUpdate;
 end;
end; // toggleVisible

procedure TRnQmain.Exit1Click(Sender: TObject);
begin
  close;
//  Application.Terminate;
end;

procedure TRnQmain.StatusMenuClick(Sender: TObject);
begin
  if sender is TMenuItem then
    Account.AccProto.usersetStatus(TMenuItem(sender).Tag);
end;

procedure TRnQmain.VisMenuClick(Sender: TObject);
begin
  if sender is TMenuItem then
    Account.AccProto.usersetVisibility(TMenuItem(sender).Tag);
end;


procedure TRnQmain.password1Click(Sender: TObject);
begin
if Account.AccProto.isOnline then
  begin
   if not Assigned(changePwdFrm) then
    begin
      changePwdFrm := TchangePwdFrm.Create(Account.AccProto, False);
      translateWindow(changePwdFrm);
    end;
   changePwdFrm.showModal
  end
else
  Account.AccProto.enterPWD;
end;

procedure TRnQmain.Delete1Click(Sender: TObject);
begin
if assigned(clickedContact) then
  if messageDlg(getTranslation('Are you sure you want to delete %s from your list?', [clickedContact.displayed]),mtConfirmation, [mbYes,mbNo], 0) = mrYes then
    removeFromRoster(clickedContact);
end; // delete1click

procedure TRnQmain.byUIN1Click(Sender: TObject);
var
  addContactFrm: TaddContactFrm;
begin
  addContactFrm := TaddContactFrm.Create(self, Account.AccProto);
  translateWindow(addContactFrm);
  showForm(addContactFrm)
end;

procedure TRnQmain.Whitepages1Click(Sender: TObject);
begin
  Account.AccProto.ShowWP;
end;

procedure TRnQmain.Sendmessage1Click(Sender: TObject);
begin
  chatFrm.openOn(clickedContact)
end;

procedure TRnQmain.addContactsAction(Sender: TObject);
var
  wnd: TselectCntsFrm;
  cl: TRnQCList;
begin
  wnd := (sender as Tcontrol).parent as TselectCntsFrm;
  cl := wnd.selectedList;
  cl.resetEnumeration;
  while cl.hasMore do
    addToRoster(cl.getNext);
  cl.free;
  wnd.close;
end;

// addContactsAction

procedure TRnQmain.Hide1Click(Sender: TObject);
begin
  toggleVisible
end;

procedure TRnQmain.FormResize(Sender: TObject);
begin
//exit;
  if rosterbarOnTop then
    begin
     bar.align := alTop;
     bar.BevelEdges := [beBottom];
    end
   else
    begin
     bar.Align := alBottom;
     bar.BevelEdges := [beTop];
    end;

  if filterbarOnTop then
    FilterBar.align := alTop
   else
    FilterBar.align := alBottom;
  FilterClearBtn.Left := FilterBar.Width - FilterClearBtn.Width - 2; 
//  menuBtn.left := 0;
//  statusBtn.left := menuBtn.boundsrect.right+1;
//  visibilityBtn.left := statusBtn.boundsrect.right+1;
{  sbar.left := visibilityBtn.BoundsRect.right+1;
  sbar.width := clientWidth-visibilityBtn.BoundsRect.right-1;
  sbar.top := 0;
  sbar.Height := bar.ClientHeight;
}
//  PntBar.Left := visibilityBtn.BoundsRect.right+1;
{
  if Assigned(PntBar) then
    PntBar.width := max(clientWidth-visibilityBtn.BoundsRect.right-1, 1);
}
//  rosterLib.formresized;
  autosizeDelayed := TRUE;
end;

procedure TRnQmain.viewinfo1Click(Sender: TObject);
begin
  if Assigned(clickedContact) then
    clickedContact.ViewInfo;
end;

procedure TRnQmain.About1Click(Sender: TObject);
//var
//  af : TaboutFrm;
begin
  if not Assigned(aboutFrm) then
  begin
   aboutFrm := TaboutFrm.Create(Application);
   translateWindow(aboutFrm);
  end;
  aboutFrm.view;
end;

procedure TRnQmain.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  function its(sc: Tshortcut): boolean;
  var
    k: Word;
    s: TShiftState;
  begin
   ShortCutToKey(sc, k, s);
   result := (k=key) and (s=shift);
  end; // its
var
  i: Integer;
begin
  if (shift = [ssAlt]) and (key = VK_F4) then
    close
   else
   if (shift = [ssCtrl]) and (key = VK_F) then
   begin
    if not FilterBar.Visible then
     if rosterbarOnTop then
       FilterBar.Top := 100
      else
       FilterBar.Top := 0;
    FilterBar.Visible := not FilterBar.Visible;
    if FilterBar.Visible then
      try
       if RnQmain.Floating then
         ActiveControl := FilterEdit
        else
         chatFrm.ActiveControl := FilterEdit
//      SetFocusedControl(FilterEdit)
       except
      end
     else
     begin
      try
       if RnQmain.Floating then
         ActiveControl := roster
        else
         chatFrm.ActiveControl := roster
//      SetFocusedControl(FilterEdit)
       except
      end;
      if (FilterEdit.Text <> '') or
         (roasterLib.FilterTextBy <> '') then
        FilterClearBtnClick(nil);
     end;
    Key := 0;
   end
  else
  for i:=0 to length(macros)-1 do
   if not macros[i].sw and its(macros[i].hk) then
    executeMacro(macros[i].opcode);
end; // formkeydown

procedure TRnQmain.Sendcontacts1Click(Sender: TObject);
begin
  openSendContacts(clickedContact)
end;

procedure TRnQmain.sendContactsAction(sender: Tobject);
var
//  i: integer;
//  s: String;
  s: RawByteString;
  UID: TUID;
  cnt: TRnQContact;
  wnd: TselectCntsFrm;
  cl: TRnQCList;
begin
 wnd := (sender as Tcontrol).parent as TselectCntsFrm;
 cl := wnd.selectedList;
 if not cl.empty then
  begin
    s := (wnd.extra as Tincapsulate).str;
    UID := Raw2UID(s);
    if UID > '' then
    begin
      cnt := wnd.proto.getContact(UID);
      begin
        Account.outbox.add(OE_CONTACTS, cnt, 0, cl);
        if Assigned(outboxFrm) then
          outboxFrm.updateList;
      end;
    end;
  end;
 cl.free;
 wnd.extra.free;
 wnd.close;
end;

procedure TRnQmain.in_visiblelist1Click(Sender: TObject);
begin
  TvisibilityFrm.ShowVis(self, Account.AccProto);
end;

procedure TRnQmain.Showlogwindow1Click(Sender: TObject);
begin
  if not Assigned(logFrm) then
   begin
    logFrm := TlogFrm.Create(Application);
    translateWindow(logFrm);
   end;
//  BeginThread(NIL, 1024, )
  showForm(logFrm)
end;

procedure TRnQmain.PntBarPaint(Sender: TObject);
var
  x, y: Integer;
  cnv: Tcanvas;
  r: TRect;
  vImgElm: TRnQThemedElementDtls;
//  thmTkn: Integer;
//  picLoc: TPicLocation;
//  picIdx: Integer;
  oldMode: Integer;
//  bmp: TBitmap;
//   TextLen: Integer;
   TextRect: TRect;
//   TextFlags: Cardinal;
//   Options: TDTTOpts;
   PaintOnGlass: Boolean;
  MemDC: HDC;
  PaintBuffer: HPAINTBUFFER;
  br: HBRUSH;
  oldF: HFONT;
  s: String;
  progress: Double;
begin
  cnv := (Sender as TPaintBox).Canvas;
  cnv.Font.Assign(Screen.MenuFont);
  theme.ApplyFont('roaster.bar', cnv.font); //roaster.barfont);
  R := (Sender as TPaintBox).ClientRect;
//  cnv.font.color := clRed;
//  cnv.font.color := clBlack;
//  cnv.font.color := clWhite;
//cnv.brush.color:=statusbar.color;
//cnv.brush.color:= bar.Color;
//cnv.fillRect(r);
//  cnv.fillRect(R);
//  cnv.Lock;
  y := r.top+(r.bottom-r.top-cnv.TextHeight('1')) div 2;

    PaintOnGlass := StyleServices.Enabled and DwmCompositionEnabled and
      not (csDesigning in ComponentState);
    if PaintOnGlass then
    begin
      PaintOnGlass := self.GlassFrame.Enabled and self.GlassFrame.FrameExtended;
    end;
  PaintBuffer := 0;
  progress := 0;
  if progStart > 0 then
    progress := progStart
   else
    if Assigned(Account.AccProto) then
      progress := Account.AccProto.ProtoElem.progLogon;
 if progress>0 then
  begin
    try
      TextRect := rect(r.left, r.Top+2, r.Left+round((r.right-r.left)*progress), r.bottom-2);
      cnv.font.color := clHighlightText;
      if PaintOnGlass then
       begin
        PaintBuffer := BeginBufferedPaint(cnv.Handle, TextRect, BPBF_TOPDOWNDIB, nil, MemDC);
       end
      else
        MemDC := cnv.Handle;
//      br := CreateSolidBrush(ColorToRGB(clHighlight));
      br := GetSysColorBrush(COLOR_HIGHLIGHT);
      FillRect(MemDC, TextRect, br);
//      br := 0;
//      DeleteObject(br);
      oldMode := SetBkMode(MemDC, TRANSPARENT);
      oldF := SelectObject(MemDC, cnv.Font.Handle);
      s := intToStr(round(progress*100))+'%';
      TextOut(MemDC, r.left+2,y, PChar(s), Length(s));
      SetBkMode(MemDC, oldMode);
      SelectObject(MemDC, oldF);
    finally
      if PaintOnGlass then
        begin
         BufferedPaintMakeOpaque(PaintBuffer, @TextRect);
         EndBufferedPaint(PaintBuffer, True);
        end;
    end;
    Application.ProcessMessages;
  end
else
  begin
    if Assigned(Account.outbox) and not Account.outbox.empty then
      begin
        vImgElm.picName := PIC_OUTBOX;
        vImgElm.ThemeToken := -1;
        vImgElm.Element := RQteDefault;
        vImgElm.pEnabled := True;
        with theme.getPicSize(vImgElm, 0, currentPPI) do
//         outboxSbarRect:=rect(r.left+3,r.top+1 + (r.Bottom-r.Top - cy)div 2,r.Left+cx, r.Top+cy);
          outboxSbarRect := rect(r.left+3, 1 + (r.top+r.Bottom - cy)div 2, r.Left+cx, r.Top+cy);
        theme.drawPic(cnv.Handle, outboxSbarRect.TopLeft, vImgElm, GetParentCurrentDpi);
      end
    else
//     if Assigned(MainProto) then
     begin
      outboxSbarRect := rect(-1,-1,-1,-1);
      vImgElm.picName := Protos_getXstsPic(nil, True);
      if vImgElm.picName  > '' then
        begin
          vImgElm.ThemeToken := -1;
          vImgElm.Element := RQteDefault;
          vImgElm.pEnabled := True;
          with theme.getPicSize(vImgElm, 0, currentPPI) do
  //         theme.drawPic(cnv.Handle, Point(r.left+3,r.top+1 + (r.Bottom-r.Top - cy)div 2), vImgElm);
            theme.drawPic(cnv.Handle, Point(r.left+3, 1 + (r.top+r.Bottom - cy)div 2), vImgElm, GetParentCurrentDpi);
        end
     end;
//    TextOut(cnv.Handle, r.Right-cnv.textWidth(contactsPnlStr)-4,y, pansiChar(contactsPnlStr), Length(contactsPnlStr));
    x := cnv.textWidth(contactsPnlStr);
//    bmp := createBitmap(x, r.Bottom - r.Top);
//  if ThemeControl(Self) then
//  begin
    if PaintOnGlass then
     begin
      TextRect := r;
//      TextRect.Left := r.Right - x - 4;
      TextRect.Left := r.Right - x - 10;
      TextRect.Top := y-1;
      DrawText32(cnv.Handle, TextRect, contactsPnlStr, cnv.Font, DT_CENTER or DT_VCENTER);
//      DrawTextTransparent(cnv.Handle, r.Right - x - 4, y-1, contactsPnlStr, cnv.Font, 255, 0);
{      TextLen := Length(contactsPnlStr);
      TextFlags := DT_CENTER or DT_VCENTER;
//      inc(TextRect.Bottom, 1);
      FillChar(Options, SizeOf(Options), 0);
      Options.dwSize := SizeOf(Options);
      Options.dwFlags := DTT_COMPOSITED or DTT_GLOWSIZE or DTT_TEXTCOLOR;
      Options.iGlowSize := 10;
      Options.crText := ColorToRGB(cnv.Font.Color);
//      Options.dwFlags := Options.dwFlags or DTT_FONTPROP;
//      Options.iFontPropId := GetThemeSysFont(nil, 0,
//      FillRect(cnv.Handle, TextRect, GetStockObject(BLACK_BRUSH));
//            DrawThemeTextEx(StyleServices.Theme[teWindow], cnv.Handle, 0, 0,
//                PWideChar(WideString(contactsPnlStr)), TextLen, TextFlags, @TextRect, Options);

      PaintBuffer := BeginBufferedPaint(cnv.Handle, TextRect, BPBF_TOPDOWNDIB, nil, MemDC);
      try
         BufferedPaintClear(PaintBuffer, @TextRect);
          with StyleServices.GetElementDetails(twCaptionActive) do
            DrawThemeTextEx(StyleServices.Theme[element], MemDC, Part, State,
//            with StyleServices.GetElementDetails(teEditTextNormal) do
//              DrawThemeTextEx(StyleServices.Theme[teEdit], Memdc, Part, State,
                PWideChar(WideString(contactsPnlStr)), TextLen, TextFlags, @TextRect, Options);
    //    BufferedPaintMakeOpaque(PaintBuffer, @R);
      finally
        EndBufferedPaint(PaintBuffer, True);
      end;}
     end
    else
     begin
      oldMode := SetBkMode(cnv.handle, TRANSPARENT);
      cnv.textOut(r.Right-x-4, y, contactsPnlStr);
      SetBkMode(cnv.handle, oldMode);
     end;
  end;
//  cnv.Unlock;
end;

procedure TRnQmain.Preferences1Click(Sender: TObject);
begin
  showForm(WF_PREF)
end;

procedure TRnQmain.Changeoradduser1Click(Sender: TObject);
var
  s: String;
  usePass: String;
  vMutex: Cardinal;
  uin2Start: TUID;
begin
  uin2Start := showUsers(usePass);
  if (uin2Start = '')or
    (Assigned(Account.AccProto) and Account.AccProto.getMyInfo.equals(uin2Start)) then
    exit;
  repeat
    s := 'R&Q' + uin2Start;
    vMutex := OpenMutex(MUTEX_MODIFY_STATE, false, PChar(s));
    if vMutex<>0 then
    begin
      CloseHandle(vMutex);
//      mutex := 0;
      msgDlg(Str_already_run, True, mtWarning);
      uin2Start := showUsers(usePass);
      if (uin2Start = '')or
        (Assigned(Account.AccProto) and Account.AccProto.getMyInfo.equals(uin2Start)) then
        Exit;
  //    Halt(0);
    end;
  until vMutex=0;
 if uin2Start = '' then
   exit;
 if Assigned(Account.AccProto) then
  if not Account.AccProto.isOffline then
   begin
    if messageDlg(getTranslation('This is gonna disconnect you. Proceed?'),mtConfirmation,[mbYes,mbNo],0) <> mrYes then
     exit;
    Account.AccProto.disconnect;
   end;

 try
  hideForm(self);
  if Assigned(Account.AccProto) then
    quitUser;
  AccPass := usePass;
  startUser(uin2Start);
  // during resetCFG the form enters a weird state, this should fix
//  ShowWindow(handle,SW_HIDE);
 finally
  if startMinimized = formvisible(self) then
    // temporary fix: showing the form with no delay sometimes causes an AV
  	showRosterTimer:=10;
 end;
end;

// change or add user

procedure TRnQmain.Visiblelist1Click(Sender: TObject);
begin
  if not Assigned(clickedContact) then
    Exit;
  with clickedContact.Proto do
   if isInList(LT_VISIBLE, clickedContact) then
    begin
 {$IFDEF UseNotSSI}
//     if not icq.useSSI then
     if (ProtoElem is TicqSession) and  not TicqSession(ProtoElem).useSSI then
       begin
        readList(LT_VISIBLE).remove(clickedContact)
       end
      else
 {$ENDIF UseNotSSI}
        if {clickedContact.fProto.}isOnline then
         begin
           RemFromList(LT_VISIBLE, clickedContact);
         end
    end
   else
    begin
 {$IFDEF UseNotSSI}
//     if not icq.useSSI then
     if (ProtoElem is TicqSession) and  not TicqSession(ProtoElem).useSSI then
       begin
        readList(LT_INVISIBLE).remove(clickedContact);
        readList(LT_VISIBLE).add(clickedContact);
       end
      else
 {$ENDIF UseNotSSI}
//       if Contact.iProto.isOnline then
        begin
//         invisibleList.remove(Contact);
//         visibleList.add(Contact);
         RemFromList(LT_INVISIBLE, clickedContact);
         AddToList(LT_VISIBLE, clickedContact);
        end;
    end;
 {$IFDEF UseNotSSI}
//ICQ.updateVisibility;
  if (clickedContact.iProto.ProtoElem is TicqSession) then
    TicqSession(clickedContact.iProto.ProtoElem).updateVisibility;
 {$ENDIF UseNotSSI}
  saveListsDelayed := TRUE;
  roasterLib.redraw(clickedContact);
end;

procedure TRnQmain.invisiblelist1Click(Sender: TObject);
begin
  if not Assigned(clickedContact) then
    Exit;
 with clickedContact.Proto do
  if clickedContact.isInList(LT_INVISIBLE) then
  begin
 {$IFDEF UseNotSSI}
//   if not icq.useSSI then
   if (ProtoElem is TicqSession) and  not TicqSession(ProtoElem).useSSI then
     readList(LT_INVISIBLE).remove(clickedContact)
    else
 {$ENDIF UseNotSSI}
     clickedContact.RemFromList(LT_INVISIBLE);
  end
else
  begin
 {$IFDEF UseNotSSI}
//   if not icq.useSSI then
   if (ProtoElem is TicqSession) and  not TicqSession(ProtoElem).useSSI then
     begin
//      ICQ.readVisible.remove(Contact);
      readList(LT_VISIBLE).remove(clickedContact);
//      ICQ.readInvisible.add(Contact);
      readList(LT_INVISIBLE).add(clickedContact);
     end
    else
 {$ENDIF UseNotSSI}
     begin
       clickedContact.RemFromList(LT_VISIBLE);
       clickedContact.AddToList(LT_INVISIBLE);
     end;
  end;
 {$IFDEF UseNotSSI}
//ICQ.updateVisibility;
  if (clickedContact.iProto.ProtoElem is TicqSession) then
    TicqSession(clickedContact.iProto.ProtoElem).updateVisibility;
 {$ENDIF UseNotSSI}
  saveListsDelayed := TRUE;
  roasterLib.redraw(clickedContact);
end;

procedure TRnQmain.tempvisiblelist1Click(Sender: TObject);
begin
  if not Assigned(clickedContact) then
    Exit;
  if clickedContact.isInList(LT_TEMPVIS) then
    clickedContact.RemFromList(LT_TEMPVIS)
   else
    clickedContact.AddToList(LT_TEMPVIS);
  roasterLib.redraw(clickedContact);
end;

procedure TRnQmain.doAutosize;
var
  y, limit, delta: integer;
begin
  if not autoSizeRoster
     or docking.active
     or (not self.Floating )
     or not formVisible(self) then
    exit;
  if autosizeFullRoster then
    y := roasterLib.fullMaxY
   else
    y := roasterLib.onlineMaxY;
  if y > 20 then
    begin
      inc(y, 5);
    //  if bar.Visible then inc(y, sbar.height);
      if bar.Visible       then inc(y, PntBar.height);
      if TopLbl.Visible    then inc(y, TopLbl.height);
      if FilterBar.Visible then inc(y, FilterBar.height);
      if MlCntBtn.Visible  then inc(y, MlCntBtn.height);
    //  limit:=desktopWorkArea.Bottom - self.clientToScreen(point(0, 0)).y;
      if autosizeUp then
        begin
          limit := top+Height - Screen.MonitorFromWindow(self.Handle).WorkareaRect.Top;
        //  limit:= Screen.DesktopTop + Screen.DesktopHeight - clientToScreen(point(0,0)).y;
          if y > limit then
            y := limit;
          delta := y-clientheight;
          Top := Top - delta;
          clientheight := y;
        end
       else
        begin
          limit := Screen.MonitorFromWindow(self.Handle).WorkareaRect.Bottom - self.clientToScreen(point(0, 0)).y;
        //  limit:= Screen.DesktopTop + Screen.DesktopHeight - clientToScreen(point(0,0)).y;
          if y > limit then
            y := limit;
          clientheight := y;
        end;
    end;
end; // doAutosize

procedure TRnQmain.Viewmyinfo1Click(Sender: TObject);
begin
//  viewInfoabout(MainProto.myinfo)
  Account.AccProto.getMyInfo.ViewInfo;
end;

procedure TRnQmain.ViewSSI1Click(Sender: TObject);
begin
  Account.AccProto.ViewSSI;
end;

procedure TRnQmain.UIN1Click(Sender: TObject);
begin
  clipboard.asText := clickedContact.uid
end;

procedure TRnQmain.AppActivate(Sender: TObject);
begin
  inactiveTime := 0;
  TipsShowTop;
  applyTransparency;
end;

procedure TRnQmain.Newgroup1Click(Sender: TObject);
begin
  roasterLib.addGroup(getTranslation('New group'));
  roasterlib.edit(roasterlib.focused);
end;

procedure TRnQmain.Rename1Click(Sender: TObject);
begin
  if not childParent(getFocus, self.handle) then
    roasterlib.focus(chatFrm.thisChat.who);
  roasterlib.edit(roasterlib.focused)
end;

procedure TRnQmain.Renamegroup1Click(Sender: TObject);
begin
  roasterlib.edit(roasterlib.focused)
end;

procedure TRnQmain.Requestavatar1Click(Sender: TObject);
begin
  if Assigned(clickedContact) then
    begin
      reqAvatarsQ.add(clickedContact);
    end;
end;

procedure TRnQmain.authReqClick(Sender: TObject);
var
  rsn, s1, s2: String;
  uid: TUID;
begin
  if not Assigned(clickedContact) or (clickedContact.Proto = NIL) then
    Exit;
  try
    uid := clickedContact.uid;
   except
    uid := '';
  end;
  if uid = '' then
   Exit;
  with clickedContact.Proto.getMyInfo do
    rsn := getTranslation(Str_authRequest) + ' ' + displayed4All+ ' UID#:' + uin2Show;
  s1 := getTranslation('Enter reason to authorize');
  s2 := getTranslation('Reason');
  if InputQueryBig(s1, s2, rsn) then
   begin
    clickedContact.AuthRequest(rsn);
    plugins.castEv( PE_AUTHREQ_SENT, UID, rsn);
   end;
end;

procedure TRnQmain.Opengroup1Click(Sender: TObject);
begin
  roasterlib.expand(roasterlib.focused)
end;

procedure TRnQmain.Openincomingfolder1Click(Sender: TObject);
//var
//  s: String;
begin
  if Assigned(clickedContact) then
   begin
//    s := fileIncomePath(clickedContact);
    if DirectoryExists(Openincomingfolder1.Hint) then
      exec(Openincomingfolder1.Hint);
   end;
end;

procedure TRnQmain.Closegroup1Click(Sender: TObject);
begin
  roasterlib.collapse(roasterlib.focused)
end;

procedure TRnQmain.Deletegroup1Click(Sender: TObject);
var
  id: integer;
  i: Integer;
begin
  if roasterlib.focused=NIL then
    exit;
  id := roasterlib.focused.groupId;
  i := groups.idxOf(id);
  if i >=0 then
  with groups.a[i] do
  if messageDlg(getTranslation('Are you sure you want to delete the group "%s" ?',[name]), mtConfirmation, [mbYes,mbNo], 0) = mrYes then
    begin
    if Account.AccProto.readList(LT_ROSTER).getCount(id) > 0 then
      if messageDlg(getTranslation('This group (%s) is not empty! All contacts in it will be lost!\nAre you sure you want to continue?',[name]),mtWarning, [mbYes,mbNo], 0) = mrNo then
        exit;
    // place over the first instance of the group that contains a contact
    roasterLib.removeGroup(id);
    end;
end; // delete group

procedure TRnQmain.Closeallgroups1Click(Sender: TObject);
var
  i: integer;
  d: Tdivisor;
begin
  if not Assigned(clickedNode) then
    exit;
  for i:=0 to groups.count-1 do
   with groups.a[i] do
    if clickedNode.kind = NODE_DIV then
      roasterLib.collapse(node[clickedNode.divisor])
     else
      for d:=low(Tdivisor) to high(Tdivisor) do
        roasterLib.collapse(node[d]);
end; // close all groups

procedure TRnQmain.Openallgroups1Click(Sender: TObject);
var
  i: integer;
  d: Tdivisor;
begin
  if not Assigned(clickedNode) then
    exit;
  for i:=0 to groups.count-1 do
   with groups.a[i] do
    if clickedNode.kind = NODE_DIV then
      roasterLib.expand(node[clickedNode.divisor])
     else
      for d:=low(Tdivisor) to high(Tdivisor) do
        roasterLib.expand(node[d]);
end; // open all groups

procedure TRnQmain.Contactsdatabase1Click(Sender: TObject);
begin
{ dbFrm := TdbFrm.Create(Application);
 translateWindow(dbFrm);
 showForm(dbFrm);}
 if not Assigned(RnQdbFrm) then
  begin
   RnQdbFrm := TRnQdbFrm.Create(Application);
   applyCommonsettings(RnQdbFrm);
   translateWindow(RnQdbFrm);
  end;
 showForm(RnQdbFrm);
end;

procedure TRnQmain.Deleteallemptygroups1Click(Sender: TObject);
var
  i, id: integer;
begin
  for i:=0 to groups.count-1 do
  begin
    id:=groups.a[i].id;
    if Account.AccProto.readList(LT_ROSTER).getCount(id) = 0 then
      roasterLib.removeGroup(id);
  end;
end;

procedure TRnQmain.movecontactsAction(sender: Tobject);
var
  oldID, newID: integer;
  c: TRnQcontact;
begin
  if roasterlib.focused=NIL then
    exit;
  with roasterlib.focused do
   if kind = NODE_GROUP then
     oldID := groupID
    else
     exit;
  newID := (sender as Tmenuitem).tag;
  if newID = 2000 then
    newID := 0; // 2000 means no group
//roster.hide;
  roster.BeginUpdate;
  try
    for c in Account.AccProto.readList(LT_ROSTER) do
      if c.groupId = oldID then
        setNewGroupFor(c, newID);
   finally
//    roster.show;
    roster.EndUpdate;
  end;
end; // move contacts action

procedure TRnQmain.addcontactAction(sender:Tobject);
begin
  if Assigned(clickedContact) then
    addToRoster(clickedContact, (sender as Tmenuitem).tag,
      clickedContact.CntIsLocal)
end;

procedure TRnQmain.IP1Click(Sender: TObject);
begin
  clipboard.asText := ip2str(clickedContact.getContactIP);
end;

procedure TRnQmain.doSearch;

  function twiceOrMore(const s: string): boolean;
  var
    i: integer;
  begin
    result := TRUE;
    if length(s) < 2 then
      result := FALSE
     else
      for i:=1 to length(s) do
       if s[i]<>s[1] then
        begin
         result := FALSE;
         exit;
        end;
  end; // twiceOrMore

var
  i, cnt, maxcnt: integer;
  node, found: Tnode;
  s: string;
begin
 if twiceOrMore(searching) then
  begin
    // search for next one
    node := roasterLib.focused;
    if Assigned(node) then
     repeat
       node := getNode(roster.GetNextVisible(node.treenode));
     until (node=NIL) or (node.kind=NODE_CONTACT) and AnsiStartsText(searching[1], node.contact.displayed);
    // found, exit
    if node<>NIL then
     begin
      roasterLib.focusTemp(node);
      exit;
     end;
    // not found, restart from top
    node := getNode(roster.GetFirst);
    if Assigned(node) then
     repeat
       node := getNode(roster.GetNextVisible(node.treenode));
     until (node=NIL) or (node.kind=NODE_CONTACT) and AnsiStartsText(searching[1], node.contact.displayed);
    // found
    if node<>NIL then
      roasterLib.focusTemp(node);
    exit;
  end;
// cnt is how many chars of the the current node matches the search
// maxcnt is the highest valor reached by cnt 
  found := NIL;
  maxcnt := 0;
  i := 0;
while i < roasterLib.contactsPool.count do
  begin
  node := Tnode(roasterLib.contactsPool[i]);
  s := uppercase(node.contact.displayed);
  cnt:=0;
  while (cnt<length(s)) and (cnt<length(searching)) and (s[cnt+1]=upcase(searching[cnt+1])) do
    inc(cnt);
  if (cnt > maxcnt) or (cnt = maxcnt) and (found<>NIL) and (found.treenode.index > node.treenode.index) then
    begin
    maxcnt := cnt;
    found := node;
    end;
  if s=searching then
    break;
  inc(i);
  end;
if found<>NIL then
  roasterLib.focusTemp(found);
end; // doSearch

function TRnQmain.clickedGroupList: TRnQCList;
var
  c: TRnQcontact;
begin
  result := TRnQCList.create;
  for c in Account.AccProto.readList(LT_ROSTER) do
      if c.groupId = clickedGroup then
        result.add(c);
end; // clickedGroupList

procedure TRnQmain.tovisiblelist1Click(Sender: TObject);
var
  cl: TRnQCList;
begin
  cl := clickedGroupList;
(* {$IFDEF UseNotSSI}
  if not icq.useSSI then
    begin
      ICQ.readList(LT_VISIBLE).add(cl);
      ICQ.readList(LT_INVISIBLE).remove(cl);
      ICQ.updateVisibility;
    end
   else
 {$ENDIF UseNotSSI}
*)
      Account.AccProto.AddToList(LT_VISIBLE, cl);
  cl.free;
  saveListsDelayed := TRUE;
end; // group to visible

procedure TRnQmain.tempvisiblelist2Click(Sender: TObject);
var
  cl: TRnQCList;
begin
  cl := clickedGroupList;
  Account.AccProto.AddToList(LT_TEMPVIS, cl);
  cl.Free;
//roasterLib.redraw(clickedContact);
end;

procedure TRnQmain.toinvisiblelist1Click(Sender: TObject);
var
  cl: TRnQCList;
begin
  cl := clickedGroupList;
(*
 {$IFDEF UseNotSSI}
  if not icq.useSSI then
    begin
      ICQ.readList(LT_VISIBLE).remove(cl);
      ICQ.readList(LT_INVISIBLE).add(cl);
      ICQ.updateVisibility;
    end
   else
 {$ENDIF UseNotSSI}
//      activeICQ.add2invisible(cl);
*)
      Account.AccProto.AddToList(LT_INVISIBLE, cl);
  cl.free;
  saveListsDelayed := TRUE;
end; // group to invisible

procedure TRnQmain.tonormalvisibility1Click(Sender: TObject);
var
  cl: TRnQCList;
begin
  cl := clickedGroupList;
(* {$IFDEF UseNotSSI}
  if not icq.useSSI then
    begin
      MainProto.readList(LT_INVISIBLE).remove(cl);
      MainProto.readList(LT_VISIBLE).remove(cl);
      ICQ.updateVisibility;
    end
   else
 {$ENDIF UseNotSSI}
*)
    begin
      Account.AccProto.RemFromList(LT_INVISIBLE, cl);
      Account.AccProto.RemFromList(LT_VISIBLE, cl);
    end;
  cl.free;
  saveListsDelayed := TRUE;
end;

procedure TRnQmain.TopLblDblClick(Sender: TObject);
begin
  toggleVisible;
end;

// group to normal

procedure TRnQmain.Showgroups1Click(Sender: TObject);
begin
  toggleShowGroups
end;

procedure TRnQmain.Showgroups2Click(Sender: TObject);
begin
  toggleShowGroups
end;

procedure TRnQmain.sbarMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if button = mbLeft then
    if into(point(x,y), outboxSbarRect) then
     begin
      if not Assigned(outboxfrm) then
       begin
        outboxfrm := ToutboxFrm.Create(Application);
        translateWindow(outboxfrm);
       end;
      outboxfrm.open;
     end;
  if button = mbRight then
//  with boundsrect do
//   menu.Popup(left,utilLib.IfThen(roasterbarOnTop,integer(Top), bottom))
  with bar.boundsrect do
   with ClientToScreen(point(left,bottom)) do
		menu.Popup(X,Y)
end;

procedure TRnQmain.Viewinfoof1Click(Sender: TObject);
var
  uid: TUID;
  cnt: TRnQContact;
begin
  if enterUinDlg(Account.AccProto, uid, getTranslation('View info of...')) then
   begin
//  viewInfoabout(MainProto.getContact(uid));
    cnt := Account.AccProto.getContact(uid);
    if Assigned(cnt) then
      cnt.ViewInfo;
   end;
end;

procedure TRnQmain.Outbox1Click(Sender: TObject);
begin
  if not Assigned(outboxfrm) then
   begin
    outboxfrm := ToutboxFrm.Create(Application);
    translateWindow(outboxfrm);
   end;
 outboxfrm.open
end;

procedure TRnQmain.Lock1Click(Sender: TObject);
begin
  doLock
end;

 {$IFDEF usesDC}
procedure TRnQmain.WMDROPFILES(var Message: TWMDROPFILES);
var
  node: Tnode;
  i, n: integer;
  ss: string;
  buffer: array[0..2000] of char;
begin
  with roster.ScreenToClient(mousePos) do
    node := roasterLib.nodeAt(x,y);
  if (node=NIL) or (node.kind<>NODE_CONTACT) then
    exit;
//  if node.contact.status in [SC_OFFLINE,SC_UNK] then exit;
  ss := '';
  n := DragQueryFile(Message.Drop, cardinal(-1), NIL, 0);
  for i:=0 to n-1 do
    begin
     DragQueryFile(Message.Drop, i, @buffer, sizeof(buffer));
     ss := ss+buffer+CRLF;
    end;
  DragFinish(message.drop);
  if node.contact is TRnQContact then
    node.contact.SendFilesTo(ss);
  ss := '';
end; // WMDROPFILES
 {$ENDIF usesDC}

procedure TRnQmain.SendanSMS1Click(Sender: TObject);
begin
//  TsmsFrm.doAll(self,'','')
end;


procedure TRnQmain.displayHint(Sender: TObject);
begin
  case hintMode of
   HM_comm: chatFrm.setStatusbar(application.Hint);
//   HM_url: chatFrm.setStatusbar(getURLfromFav(application.Hint));
  end;
end;

procedure TRnQmain.Sendemail1Click(Sender: TObject);
begin
  clickedContact.sendEmailTo
end;

{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
procedure TRnQmain.WMDNSLookUp(var pMsg: TMessage);
var
 evInt: Integer;
 vmsg: String;
begin
  try
    resolving := TRUE;
    with Account.AccProto.ProtoElem do
    sock.DnsLookup(aProxy.serv.host);
  except
   on E: Exception do
    begin
      evInt := WSocket_WSAGetLastError;
      vmsg := E.Message;
      Account.AccProto.disconnect;
      resolving := False;
      setProgBar(Account.AccProto, 0);
      msgDlg(getTranslation('DNS error: [%d]\n%s' , [evInt, vmsg]), False, mtError);
    end
   else
    begin
      evInt := WSocket_WSAGetLastError;
      vmsg := WSocketErrorDesc(evInt);
      Account.AccProto.disconnect;
      resolving := False;
      setProgBar(Account.AccProto, 0);
      msgDlg(getTranslation('DNS error: [%d]\n%s' , [evInt, vmsg]), False, mtError);
    end;
  end;
end;

procedure TRnQmain.dnslookup(sender: Tobject; error: word);
begin
  if not resolving then
    exit;
  resolving := FALSE;
  setProgBar(Account.AccProto, 0.5/progLogonTotal);
  if Error = 0 then
   begin
    lastserverAddr := Account.AccProto.ProtoElem.loginServerAddr;
    lastServerIP := Account.AccProto.ProtoElem.sock.DnsResultList[0];
   end
  else
   begin
//   lastServerIP:= '';
    lastserverIP := Account.AccProto.ProtoElem.loginServerAddr;
    lastserverAddr := '';
   end;
  connect_after_dns(Account.AccProto);
end; // dnslookupICQ


procedure TRnQmain.splashPaint(Sender: TObject);
  function IsFormTransparentAvailable: Boolean;
  var
    hdcScreen: HDC;
  begin
    hdcScreen := CreateDC('DISPLAY', nil, nil, nil);
    Result := False;
    if GetDeviceCaps(hdcScreen, BITSPIXEL) >= 16 then
      if @g_pUpdateLayeredWindow <> nil then
        Result := True;
    DeleteDC(hdcScreen);
  end;
var
//  MemDC: HDC;
  r: TRect;
{  PaintBuffer: HPAINTBUFFER;
  br: HBRUSH;
  oldF: HFONT;
  s: String;
}
  blend_function: BLENDFUNCTION;
  p: TPoint;
  hdcScreen, hdcMem: HDC;
  nWidth, nHeight: Integer;
  bitmap_info: BITMAPINFO;
  m_hBmp: HBITMAP;
  m_pBits: Pointer;
  hOldBitmap: HGDIOBJ;
  ptSrc, ptDest: TPoint;
  size: TSize;
  st: Integer;
  is32: Boolean;
begin
//  brF := CreateSolidBrush(RGB($FF, 02, 01))
//   FillRect(splashFrm.Canvas.Handle, splashFrm.Canvas.ClipRect, brF);

//   splashFrm.canvas.Brush.Color := clBlack;
//   splashFrm.canvas.Brush.Color := splashFrm.TransparentColorValue;
//   splashFrm.Canvas.FillRect(splashFrm.Canvas.ClipRect);
//   with theme.GetPicSize(PIC_SPLASH, splashPicTkn, splashPicLoc, splashPicIdx) do
//    OutputDebugString(PChar(Format('%d ms', [ GetTickCount() - dwStartTime ])));
   r := splashFrm.Canvas.ClipRect;
   if (r.right <= r.left)or(r.bottom <= r.top) then
     Exit;

   p := Point(0, 0);
//   PaintBuffer := BeginBufferedPaint(splashFrm.canvas.Handle, splashFrm.Canvas.ClipRect, BPBF_TOPDOWNDIB, nil, MemDC);
//   PaintBuffer := BeginBufferedPaint(splashFrm.canvas.Handle, r, BPBF_COMPATIBLEBITMAP, nil, MemDC);
//   theme.drawPic(splashFrm.canvas.Handle, Point(0, 0), splashImgElm);
//    theme.drawPic(memDC, p, splashImgElm);
//    theme.drawPic(splashFrm.canvas.Handle, p, splashImgElm);
//    theme.getPic(splashFrm.canvas.Handle, p, splashImgElm);
//   BufferedPaintMakeOpaque(PaintBuffer, @TextRect);
//    theme.drawPic(splashFrm.Canvas.Handle, Point(0, 0), splashImgElm);
   if IsFormTransparentAvailable then
   begin
    hdcScreen := CreateDC('DISPLAY', nil, nil, nil);

    hdcMem := CreateCompatibleDC(hdcScreen);

    nWidth := r.right - r.left;
    nHeight := r.bottom - r.top;

    ZeroMemory(@bitmap_info, sizeof(bitmap_info));
    bitmap_info.bmiHeader.biSize := sizeof(bitmap_info.bmiHeader);
    bitmap_info.bmiHeader.biWidth := nWidth;
    bitmap_info.bmiHeader.biHeight := nHeight;
    bitmap_info.bmiHeader.biPlanes := 1;
    bitmap_info.bmiHeader.biBitCount := 32;

      m_hBmp := CreateDIBSection(hdcMem, bitmap_info, DIB_RGB_COLORS, m_pBits, 0, 0);
{
    hOldBitmap := SelectObject(hdcMem, m_hBmpWhite);
    hBrushWhite := CreateSolidBrush(RGB($ff, $ff, $ff));
    FillRect(hdcMem, rc, hBrushWhite);
    DeleteObject(hBrushWhite);
}
    hOldBitmap := SelectObject(hdcMem, m_hBmp);

    FillMemory(m_pBits, 4 * nWidth*nHeight, $FF);
//    FillMemory(m_pBits, 4 * nWidth*nHeight, $00);
//    theme.drawPic(hdcMem, p, splashImgElm);

    theme.getPic(hdcMem, p, splashImgElm, splashFrm.PixelsPerInch, is32);
    if is32 then
      blend_function.AlphaFormat := AC_SRC_ALPHA
     else
      blend_function.AlphaFormat := AC_SRC_OVER;
    blend_function.BlendOp := AC_SRC_OVER;
    blend_function.BlendFlags := 0;
    blend_function.SourceConstantAlpha := 255;

    ptSrc.X := 0; ptSrc.Y := 0;

//    ptDest.X := Parent.Left;
//    ptDest.Y := Parent.Top;
    ptDest.X := splashFrm.Left;
    ptDest.Y := splashFrm.Top;

    size.cx := nWidth; size.cy := nHeight;

    st := GetWindowLong(splashFrm.Handle, GWL_EXSTYLE);
    SetWindowLong(splashFrm.Handle, GWL_EXSTYLE, st and not WS_EX_LAYERED);
    SetWindowLong(splashFrm.Handle, GWL_EXSTYLE, st or WS_EX_LAYERED);


//    UpdateLayeredWindow(splashFrm.Handle,
    g_pUpdateLayeredWindow(splashFrm.Handle,
                           hdcScreen,
                           @ptDest,
                           @size,
                           hdcMem,
                           @ptSrc,
                           0,
                           @blend_function,
                           ULW_ALPHA);

    SelectObject(hdcMem, hOldBitmap);

    if (0 <> m_hBmp) then
      begin
         DeleteObject(m_hBmp);
         m_hBmp := 0;
      end;

    Windows.DeleteDC(hdcMem);
    Windows.DeleteDC(hdcScreen);
   end
   else
    begin
      splashFrm.Canvas.Brush.Color := clWhite;
      splashFrm.Canvas.FillRect(r);
      theme.drawPic(splashFrm.Canvas.Handle, p, splashImgElm, splashFrm.pixelsPerInch);
    end;

//   UpdateLayeredWindow(splashFrm.Handle, 0, 0, 0, MemDC, @p, 0, @blend_function, ULW_ALPHA);
//   UpdateLayeredWindow(splashFrm.Handle, 0, 0, 0, splashFrm.canvas.Handle, @p, 0, @blend_function, ULW_ALPHA);
//   EndBufferedPaint(PaintBuffer, True);

{
    UpdateLayeredWindow(splashFrm.Handle,
                           hdcScreen,
                           @ptDest,
                           @size,
                           hdcMem,
                           @ptSrc,
                           0,
                           @blend_function,
                           ULW_ALPHA);

//     theme.drawPic(splashFrm.Canvas.Handle, (max(cx, 200)- cx) div 2, 30,
//                    PIC_SPLASH, splashPicTkn, splashPicLoc, splashPicIdx);
{   splashFrm.canvas.Font.Size := 18;
   theme.ApplyFont('splash', splashFrm.Canvas.Font);
  SetBKMode(splashFrm.canvas.Handle, TRANSPARENT);
  TextOut(splashFrm.canvas.Handle, 5, 0, 'http://RnQ.ru', length('http://RnQ.ru'));
//  SetBKMode(splashFrm.canvas.Handle, TRANSPARENT);
//            textOut(cnv.handle, x,y, @s[chunkStart], j);
//            SetBKMode(cnv.Handle, oldMode);
//  TextOut(splashFrm.canvas.Handle, 5, 0, rnqSite, length(rnqSite));
//   splashFrm.canvas.TextOut(0, 0, 'http://RnQ.ru');
// theme.drawPic(splashFrm.canvas, 0,0, PIC_SPLASH);
// theme.drawPic(splashFrm.canvas.Handle, 0, 30, PIC_SPLASH,
//                   splashPicTkn, splashPicLoc, splashPicIdx);
}
end;

procedure TRnQmain.menuBtnClick(Sender: TObject);
begin
  with bar.boundsrect do
    with ClientToScreen(point(left,bottom)) do
      menu.Popup(X,Y)
end;

procedure TRnQmain.sbarDblClick(Sender: TObject);
begin
  doConnect
end;

procedure TRnQmain.divisorMenuPopup(Sender: TObject);
begin
  newgroup1.visible := showGroups;
end;

procedure TRnQmain.gmAAdd2ServerExecute(Sender: TObject);
begin
//  if Assigned(clickedNode) then
   if clickedGroup > 0 then
    groups.get(clickedGroup).ServerUpdate;
//    TicqSession(MainProto.ProtoElem).SSIUpdateGroup([clickedGroup]);
end;

procedure TRnQmain.gmAAdd2ServerUpdate(Sender: TObject);
begin
  if clickedGroup > 0 then
   if
 {$IFDEF UseNotSSI}
//     icq.useSSI and
     (not (Account.AccProto.ProtoElem is TicqSession) or (TicqSession(Account.AccProto.ProtoElem).UseSSI)) and
 {$ENDIF UseNotSSI}
     (groups.id2ssi(clickedGroup) = 0) then
     begin
       TAction(Sender).Visible := True;
       TAction(Sender).Enabled := Account.AccProto.isOnline;
     end
    else
     TAction(Sender).Visible := False;
end;

procedure TRnQmain.gmAMakeLocalExecute(Sender: TObject);
begin
   {$IFDEF PROTOCOL_ICQ}
   if clickedGroup > 0 then
    TicqSession(Account.AccProto.ProtoElem).SSIdeleteGroup(clickedGroup);
   {$ENDIF PROTOCOL_ICQ}
end;

procedure TRnQmain.gmAMakeLocalUpdate(Sender: TObject);
begin
  if clickedGroup > 0 then
   if
 {$IFDEF UseNotSSI}
//     icq.useSSI and
     (not (Account.AccProto.ProtoElem is TicqSession) or (TicqSession(Account.AccProto.ProtoElem).UseSSI)) and
 {$ENDIF UseNotSSI}
     (groups.id2ssi(clickedGroup) <> 0) then
     begin
       TAction(Sender).Visible := True;
       TAction(Sender).Enabled := Account.AccProto.isOnline;
     end
    else
     TAction(Sender).Visible := False
  else
     TAction(Sender).Visible := False
  ;
end;

procedure TRnQmain.groupMenuPopup(Sender: TObject);
begin
 {$IFDEF UseNotSSI}
  addGroupsToMenu(self, Moveallcontactsto1, movecontactsAction,
//    not icq.useSSI
     (Account.AccProto.ProtoElem is TicqSession) and not (TicqSession(Account.AccProto.ProtoElem).UseSSI)
  );
 {$ELSE UseNotSSI}
  addGroupsToMenu(self, Moveallcontactsto1, movecontactsAction, false);
 {$ENDIF UseNotSSI}
end;

procedure TRnQmain.contactMenuPopup(Sender: TObject);
var
  showHidden: boolean;
begin
  if clickedContact = NIL then
    Exit;
  showHidden := getShiftState() and (1+2) > 0; // shift OR control
//menusendaddedyou1.tag:=PIC_ADDEDYOU;
  UIN1.caption := getTranslation('%s (copy UIN)', [clickedContact.uin2Show]);
 {$IFDEF PROTOCOL_ICQ}
  if (clickedContact is TRnQContact) and (clickedContact.GetContactIP <> 0) then
    begin
      IP1.visible := TRUE;
      IP1.caption := getTranslation('%s (copy IP)', [ip2str(clickedContact.GetContactIP)] );
    end
   else
 {$ENDIF PROTOCOL_ICQ}
    IP1.visible := FALSE;
  Sendemail1.visible := clickedContact.CanMail;

  movetogroup1.visible := clickedContact.isInRoster;
  if clickedContact.groupId = 0 then
    movetogroup1.caption := getTranslation('Move to group')
   else
    movetogroup1.caption := getTranslation('Move from %s to group', [dupAmperstand(clickedContact.getGroupName)] );
  addtocontactlist1.visible := not movetogroup1.visible;

  if movetogroup1.visible then
    addGroupsToMenu(self, movetogroup1, addcontactAction,
 {$IFDEF UseNotSSI}
//     not icq.useSSI or
     ((clickedContact.Proto.ProtoElem is TicqSession) and not (TicqSession(clickedContact.Proto.ProtoElem).UseSSI)) or
 {$ENDIF UseNotSSI}
     clickedContact.CntIsLocal)
   else
    addGroupsToMenu(self, addtocontactlist1, addcontactAction, True);
  readautomessage1.visible:=
 {$IFDEF PROTOCOL_ICQ}
    (clickedContact is TICQcontact) and
    (showHidden or
      clickedContact.fProto.isOnline and
      (CAPS_sm_ICQSERVERRELAY in TICQContact(clickedContact).capabilitiesSm) and
      (byte(TICQContact(clickedContact).status) in statusWithAutomsg)
    );
 {$ELSE ~PROTOCOL_ICQ}
     false;
 {$ENDIF PROTOCOL_ICQ}

 Openincomingfolder1.Hint := fileIncomePath(clickedContact);
 Openincomingfolder1.Visible := DirectoryExists(Openincomingfolder1.Hint);

end;

procedure TRnQmain.Automessage1Click(Sender: TObject);
begin
  if not Assigned(automsgFrm) then
   begin
    automsgFrm := TautomsgFrm.Create(Application);
    translateWindow(automsgFrm);
   end;
  automsgFrm.show
end;

procedure TRnQmain.Showonlyonlinecontacts1Click(Sender: TObject);
begin
  toggleOnlyOnline
end;

procedure TRnQmain.statusBtnClick(Sender: TObject);
begin
  with mousePos do
    statusMenuNEW.Popup(x,y)
end;

procedure TRnQmain.visibilityBtnClick(Sender: TObject);
begin
  if Assigned(vismenuExt) then
   with mousePos do
     vismenuExt.Popup(x,y)
end;

procedure TRnQmain.updateStatusGlyphs;
var
  i: Integer;
  sa: TStatusArray;
begin
  if Assigned(Account.AccProto) then
    begin
      i := Account.AccProto.getVisibility;
      sa := Account.AccProto.getVisibilities;
      if Assigned(sa) then
        begin
         if (i >= Low(sa)) and
            (i <= High(sa)) then
          visibilityBtn.ImageName := sa[i].ImageName;
        end;

      if Account.AccProto.isOnline then
//        statusBtn.ImageName := Account.AccProto.getStatusImg(Account.AccProto.getStatus)
        statusBtn.ImageName := Account.AccProto.getStatusImg()
       else
        statusBtn.ImageName := status2imgName(byte(SC_OFFLINE), false);
    end
   else
    begin
     statusBtn.ImageName := status2imgName(byte(SC_UNK), FALSE);
     visibilityBtn.ImageName := statusBtn.ImageName;
    end;
{  statusBtn.ImageName := statusImgName;
  //theme.getPic(statusImgName, statusBtn.glyph);
  statusBtn.Repaint;
  visibilityBtn.ImageName := visibilityImgName;
  //theme.getPic(visibilityImgName, visibilityBtn.glyph);
  visibilityBtn.Repaint;}
end;

procedure TRnQmain.Checkforupdates1Click(Sender: TObject);
begin
  checkupdate.autochecking := FALSE;
  check4update
end;

procedure TRnQmain.FilterClearBtnClick(Sender: TObject);
begin
  FilterEdit.Text := '';
  roasterLib.FilterTextBy := '';
  rebuild;
end;

procedure TRnQmain.FilterEditChange(Sender: TObject);
begin
   lastFilterEditTime := now;
end;

procedure TRnQmain.FilterEditKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 formKeyDown(sender,key,shift)
end;

procedure TRnQmain.FormHide(Sender: TObject);
begin
  clickedContact := NIL;
//  dockSet(FALSE);
  docking.appbarFlag := False;
//  utilLib.dockSet;
  dockSet(Self.Handle, FALSE, WM_DOCK);
end;

procedure TRnQmain.WndProc(var msg:TMessage);
var
  i: integer;
  ScrLeft, ScrWidth: Integer;
  r: TRect;
begin
case msg.msg of
 {$IFDEF RNQ_PLAYER}
  WM_USER: begin
   if msg.WParam = IPC_STARTPLAY then
     mARnQPlayerExecute(self)// Запускаем проигрыватель
{    case msg.lParam of // что делаем
      IPC_STARTPLAY: mARnQPlayerExecute(self);// Запускаем проигрыватель
//      IPC_ISPLAYING: executeMacro( := 'is plaing!';
      IPC_SETVOLUME: begin
          if Assigned(frmPlayer) then
            begin
              frmPlayer.volumeslider.Position := msg.wParam; // := 'Set volume';
            end
      end}
    else //Label1.Caption := 'other ipc...'
      inherited;
//    end;
   end;
 {$ENDIF RNQ_PLAYER}
{  WM_COMMAND:
      try
        case TWMCommand(msg).ItemID of
//          WA_FILE_PLAY   : Label1.Caption := 'Play file';
          WINAMP_BUTTON1 : executeMacro(OP_PLR_PREV);  // 'Button prev track';
          WINAMP_BUTTON3 : executeMacro(OP_PLR_PAUSE); //'Play/Stop';
          WINAMP_BUTTON4 : executeMacro(OP_PLR_STOP);  //'Pause';
          WINAMP_BUTTON5 : executeMacro(OP_PLR_NEXT);  //'Button next track';
//          WINAMP_REW5S   : Label1.Caption := 'rewind 5 sec';
//          WINAMP_FFWD5S  : Label1.Caption := 'forward 5 sec'
        else ...
          inherited;
        end;
      except    //showmessage ('WM_COMMAND error!')
      end;
}
  WM_QUIT: begin
             inherited;
             quit;
           end;
  WM_SHOWWINDOW: if ((msg.wparam=0) or running)and Floating then
          inherited;
  WM_HOTKEY: if not locked and hotkeysEnabled then executeMacro(macros[msg.wparam].opcode);

  WM_SYSCOMMAND:
    case msg.WParam and $FFF0 of  // first four bits are reserved
      SC_CLOSE: toggleVisible;
      SC_MINIMIZE: toggleVisible;
      else
        autosizeDelayed := TRUE;
        inherited;
      end;
  WM_MOVING:
    begin
      if not docking.enabled then
        begin
         inherited;
         docking.active := false;
         exit;
        end;
      i := mousepos.x;
  //    ScrWidth := screen.width
  //    r := Screen.MonitorFromWindow(self.Handle).WorkareaRect;
      r := desktopWorkArea(Self.Handle);
       begin
         ScrWidth := r.Right;
         ScrLeft  := r.Left;
       end;
  //    limit:=Screen.MonitorFromWindow(self.Handle).WorkareaRect.Bottom - self.clientToScreen(point(0, 0)).y;
  //    if not docking.active and ((i<DOCK_SNAP) or (i>screen.width-DOCK_SNAP)) then
      if not docking.active and ((i<ScrLeft+DOCK_SNAP) or (i>scrWidth-DOCK_SNAP)) then
        begin
        docking.active := TRUE;
        docking.pos := DP_right;
        if i < ScrLeft+DOCK_SNAP then
          docking.pos := DP_left;
        docking.bakOfs := point(mousepos.x-boundsrect.left, mousepos.y-boundsrect.top);
        docking.bakSize := point(width, height);
        end;
      if docking.active and (i>ScrLeft+DOCK_SNAP) and (i<scrWidth-DOCK_SNAP) then
        begin
        docking.active := False;
        with Trect(pointer(msg.lparam)^) do
          begin
          left  := mousepos.x-docking.bakOfs.x;
          top   := mousepos.y-docking.bakOfs.y;
          right := left+docking.bakSize.x;
          bottom:= top+docking.bakSize.y;
          end;
        end;
      utilLib.dockSet(Trect(pointer(msg.lparam)^));
      if not docking.active then
        inherited;
    end;
  WM_SIZING:
    begin
    if docking.active then
      utilLib.dockSet(Trect(pointer(msg.lparam)^));
    inherited;
    end;
//  WM_MOUSEHOVER:
//    CMMouseEnter(msg);
//  WM_MOUSELEAVE:
//    CMMouseLeave(msg);
  WM_ENTERMENULOOP:
    begin
      inherited;
    end;
  WM_EXITMENULOOP:
    begin
      inherited;
    end;
  WM_WTSSESSION_CHANGE: 
//    begin
     case Msg.wParam of
       WTS_CONSOLE_CONNECT:
           isLocked := False;
//           msgdlg('WTS_CONSOLE_CONNECT', mtInformation);
       WTS_CONSOLE_DISCONNECT:
           isLocked := True;
//           msgdlg('WTS_CONSOLE_DISCONNECT', mtInformation);
       WTS_REMOTE_CONNECT:
           isLocked := False;
//           msgdlg('WTS_REMOTE_CONNECT', mtInformation);
       WTS_REMOTE_DISCONNECT:
           isLocked := True;
//           msgdlg('WTS_REMOTE_DISCONNECT', mtInformation);
       WTS_SESSION_LOGON:
           isLocked := False;
//           msgdlg('WTS_SESSION_LOGON', mtInformation);
       WTS_SESSION_LOGOFF:
           isLocked := True;
//           msgdlg('WTS_SESSION_LOGOFF', mtInformation);
       WTS_SESSION_LOCK:
           isLocked := True;
//           msgdlg('WTS_SESSION_LOCK', mtInformation);
       WTS_SESSION_UNLOCK:
           isLocked := False;
//           msgdlg('WTS_SESSION_UNLOCK', mtInformation);
{       WTS_SESSION_REMOTE_CONTROL:
           begin
             msgdlg('WTS_SESSION_REMOTE_CONTROL', mtInformation);
             // GetSystemMetrics(SM_REMOTECONTROL);
           end;}
//      else
//        msgdlg('WTS_Unknown', mtInformation);
     end;
   WM_DWMCOMPOSITIONCHANGED:
     onAeroChanged;
  else
    inherited;
  end;
end; // wndproc


procedure TRnQmain.OnTimer(Sender: TObject);

  procedure updateClocks;
  var
    i: integer;
  begin
   if Assigned(childWindows) then
   with childWindows do
    begin
     i := count-1;
     while i >= 0 do
      begin
       if Tobject(items[i]) is TRnQViewInfoForm then
         TRnQViewInfoForm(items[i]).UpdateClock;
       dec(i);
      end;
    end;
  end; // updateClocks

  procedure processOutbox;
  var
    oe: Toevent;
  begin
  if outboxCount > 0 then
    dec(outboxCount);
  if outboxCount = 0 then
    if assigned(Account.AccProto) and Account.AccProto.isOnline and outboxprocessChk then
     begin
      oe := Account.outbox.popVisible;
      if oe=NIL then
        exit;
      outboxCount := timeBetweenMsgs;
      if Assigned(outboxFrm) then
       outboxFrm.updateList;
      processOevent(oe);
      oe.free;
     end;
  end; // processOutbox

var
  i: integer;
  vi1: TRnQViewInfoForm;
  Fcs: THandle;
//  cnt: Tcontact;
  cnt1: TRnQContact;
  aNewDawn: boolean;   // TRUE once after each midnight
//  vLastInput: DWord;
  isSSRuning: BOOL;
  b: boolean;
  AwayXsts: TXStatStr;
begin
  aNewDawn := FALSE;

  if not running then
    Exit;


// things to do once per second
{  flapSecs:=succ(flapSecs) mod 10;
 if flapSecs = 0 then
  begin
    if SendedFlaps >= ICQMaxFlaps then
      icq.sock.Resume;
    SendedFlaps := 0;
  end;}
  if not Assigned(Account.AccProto) then
    Exit;
 // Check offline users for Invisibility
 {$IFDEF CHECK_INVIS}
 if (supportInvisCheck)and (CheckInvis.AutoCheck) and (now-checkInvis.lastAllChkTime > CheckInvis.AutoCheckInterval*DTseconds) then
  begin
    mAChkInvisAll.Execute;
  end;

 if abs(now - checkInvis.lastChkTime)> (CheckInvis.ChkInvisInterval + (TList(checkInvQ).count / ChkInvisDiv)) *DTseconds then
  if assigned(checkInvQ) and Assigned(Account.AccProto) and (Account.AccProto.isOnline) and not checkInvQ.empty then
   begin
    checkInvis.lastChkTime := Now;
    while (TList(checkInvQ).count > 0) and (not (checkInvQ.getAt(0)).isInvisible)
          and (not checkInvQ.getAt(0).isOffline) do
      checkInvQ.delete(0);
    if TList(checkInvQ).count > 0 then
    begin
      case CheckInvis.Method of
       0 :
        Account.acks.add(OE_msg, checkInvQ.getAt(0), 0, 'Inv').ID :=
         TicqSession(Account.AccProto.ProtoElem).getUINStatus(checkInvQ.getAt(0).uid);
       else
        Account.acks.add(OE_msg, checkInvQ.getAt(0), 0, 'Inv2').ID :=
         TicqSession(Account.AccProto.ProtoElem).CheckInvisibility2(checkInvQ.getAt(0).uid);
      end;
      if checkInvQ.count > 0 then
       checkInvQ.delete(0);
      checkInvis.lastChkTime := Now;
    end;
   end;
 {$ENDIF}

// keyboard search timeout
if now-lastSearchTime > 1.2*DTseconds then
  begin
  searching := '';
  roasterLib.expandedByTempFocus := NIL;
  end;

// keyboard search timeout
if now-lastFilterEditTime > 1.2*DTseconds then
  if AnsiUpperCase(roasterLib.FilterTextBy) <> AnsiUpperCase(FilterEdit.Text) then
   begin
    roasterLib.FilterTextBy := AnsiUpperCase(FilterEdit.Text);
    rebuild;
//    roasterLib.Filter(roasterLib.FilterTextBy);
    if roasterLib.FilterTextBy > '' then
     try
       if RnQmain.Floating then
         ActiveControl := FilterEdit
        else
         chatFrm.ActiveControl := FilterEdit
//      SetFocusedControl(FilterEdit);
      except
     end;
   end;

// hide taskbar button
hideTaskButtonIfUhave2;
// bring foreground the window
if bringForeground <> 0 then
  if ForceForegroundWindow(bringForeground) then
    begin
    // update transparency on mainfrm (de)selection
      applyTransparency;
      bringForeground := 0;
    end;
//trackingMouse;
longdelayCount := succ(longdelayCount) mod 50;
reconnectdelayCount := succ(reconnectdelayCount) mod boundInt(toReconnectTime, 50, 600);
if longdelayCount = 1 then
  begin
  aNewDawn := trunc(now)-trunc(lastOnTimer) = 1;
  lastOnTimer := now;
  // windows colors could have been changed, so lets recalculate "selectedColor"
  selectedColor := blend(clHighlight, clBtnFace, 0.4);
  // trayicon could disappear on crash, lets replace it
  if assigned(statusIcon) and assigned(statusIcon.trayIcon) then
    statusIcon.trayIcon.update;
  // each 24hours check for updates
  if checkupdate.enabled and (now-checkupdate.last > checkupdate.every)
     and not checkupdate.checking
     and not startingLock then
    begin
      checkupdate.autochecking := TRUE;
      check4update;
    end;
  end;

///////////////////// USER RELATED EVENTS //////////////////////

if usertime < 0 then
  exit;
inc(usertime);    // keep track of user time

// close splash window
//if (usertime=10) and not skipSplash then
if (usertime=20) and not skipSplash then
 begin
  FreeAndNil(splashFrm);
 end;

  if aNewDawn then // if new day begin
   begin
 {$IFDEF PROTOCOL_ICQ}
    if Account.AccProto is TicqSession then
      TicqSession(Account.AccProto).applyBalloon;
 {$ENDIF PROTOCOL_ICQ}
    CheckBDays;
   end;

// have messages been seen
if autoConsumeEvents and assigned(chatFrm) and chatFrm.isVisible then
  chatFrm.sawAllhere;

processOutbox;

// query contacts infos
if usertime mod 20=0 then
 begin
   Process_InfoRetrives;
   Process_xStatusRetrives;

  {$IFDEF RNQ_AVATARS}
   if assigned(reqAvatarsQ) and Account.AccProto.isOnline and not reqAvatarsQ.empty then
    if Protocols_all.try_load_or_req_avatar(reqAvatarsQ.getAt(0)) then
     reqAvatarsQ.delete(0);

   if (ToUploadAvatarFN > '') and Account.AccProto.isOnline then
     if Account.AccProto.uploadAvatar(ToUploadAvatarFN) then
       ToUploadAvatarFN := '';
  {$ENDIF RNQ_AVATARS}
 end;

 if self.Floating then
  begin
   Fcs := GetFocus;
//   Fcs := GetForegroundWindow;
   if ((self.Floating and not childParent(Fcs, self.handle))or (not self.Floating and not childParent(Fcs, chatFrm.handle)))
      and not OpenedXStForm
      then
     inc(inactiveTime)
    else
     inactiveTime := 0;
  end;
{ autohide triggers if
{ - it is enabled
{ - time set has passed
{ - the windows is visible
{ - the mouse is not over the window
}
if inactivehide and (inactiveTime>=inactivehideTime)
and formVisible(self) and not into(mousePos, self.boundsrect)
//and not formVisible(xStatusForm)
//and not formVisible(xMRAStatusForm)
 then
  toggleVisible;

TipsProced;

// decay events
i := 0;
with eventQ do
while i < count do
 try
  with Thevent(items[i]) do
    if expires = 0 then
      begin
      free;
      removeAt(i);
      end
    else
      begin
      if expires > 0 then
        dec(expires);
      inc(i);
      end;
 except
 end;
// do blink!
blinkCount := succ(blinkCount) mod blinkSpeed;
if blinkCount = 0 then
  begin
  blinking := not blinking;
  if Assigned(statusIcon) then
   begin
    if statusIcon.trayIcon.hidden and not BossMode.isBossKeyOn then
       statusIcon.trayIcon.show
     else
    if not statusIcon.trayIcon.hidden and BossMode.isBossKeyOn then
         statusIcon.trayIcon.hide;
    statusIcon.update;
   end;
  // roster blinking
  i := 0;
  with eventQ do
    while i < count do
      begin
       cnt1 := Thevent(items[i]).otherpeer;
       if (cnt1 <> NIL)and(cnt1 is TRnQcontact) then
         roasterLib.redraw(cnt1)
        else
         begin
           cnt1 := Thevent(items[i]).who;
           if (cnt1 <> NIL)and(cnt1 is TRnQcontact) then
             roasterLib.redraw(cnt1);
         end;
       inc(i);
      end;
  end;
// the icon in preferences blinks at a different frequency
// {$IFNDEF RNQ_LITE}
  if assigned(prefFrm) then
    prefFrm.onTimer;
// {$ENDIF RNQ_LITE}

  if assigned(chatFrm) then
    chatFrm.onTimer;

if removeTempVisibleTimer > 0 then
	begin
	dec(removeTempVisibleTimer);
  if removeTempVisibleTimer = 0 then
		Account.AccProto.RemFromList(LT_TEMPVIS, removeTempVisibleContact);
  end;

if saveDBtimer2 > 0 then
  begin
  dec(saveDBtimer2);
  if saveDBtimer2=0 then
//    saveDB;
     begin
      saveListsDelayed := FALSE;
//      saveCfgDelayed := false;
      saveInboxDelayed := FALSE;
      saveOutboxDelayed := FALSE;
      saveGroupsDelayed := FALSE;
      saveAllLists(Account.ProtoPath, Account.AccProto, AllProxies, 'DB timer');
     end;
  if saveDBtimer2 > 3000 then
    saveDBtimer2 := 3000;
  end;

if showRosterTimer > 0 then
  begin
    dec(showRosterTimer);
    if showRosterTimer = 0 then
	  if not formVisible(self) then
        toggleVisible();
  end;

if (reconnectdelayCount = 0) and running then
  begin
    // auto-reconnection
    if stayConnected and Account.AccProto.isOffline and connectionAvailable then
     begin
      setStatus(Account.AccProto, lastStatus, True);
      inc(toReconnectTime, 50);
      boundInt(toReconnectTime, 50, 600);
     end;
    if connectOnConnection
      and Account.AccProto.isOffline
      and not enteringProtoPWD
      and (lastStatusUserSet<>byte(SC_OFFLINE))
      and connectionAvailable then
     setStatus(Account.AccProto, lastStatus, True);
  end;
if longdelayCount = 0 then
  begin
    // screen size could change, so update window position
    if docking.active then
      utilLib.dockSet
    else
      begin
      fixWindowPos(self);
      fixWindowPos(chatFrm);
      end;
    // runs along the whole roster
    b := FALSE;
    i := 0;
    with Account.AccProto, readList(LT_ROSTER) do
      while i<count do
        begin
         with getAt(i) do
          with TCE(data^) do
          if toQuery then
           if
 {$IFDEF UseNotSSI}
//             not icq.useSSI or
             ((ProtoElem is TicqSession) and not (TicqSession(ProtoElem).UseSSI)) or
 {$ENDIF UseNotSSI}
             CntIsLocal or(SSIID > 0)  then
            begin
             b := TRUE;
             toQuery := FALSE;
//             inc(saveDBtimer, saveDBdelay);
             incDBTimer;
             retrieveQ.add(getAt(i));
            end;
        inc(i);
        end;
   saveDBtimer2 := min(saveDBtimer2, 600);
   if not fantomWork then
   begin
    if b then
//      saveRetrieveQ;
      saveListsDelayed := True; 
    // file saving
{    if saveInboxDelayed then
      begin
      saveInboxDelayed:=FALSE;
      saveInbox;
      end;
    if saveOutboxDelayed then
      begin
      saveOutboxDelayed:=FALSE;
      saveOutbox;
      end;
    if saveGroupsDelayed then
      begin
      saveGroupsDelayed:=FALSE;
      groups.save;
      end;}

    if saveCfgDelayed then
     begin
      UpdateProperties;
      saveListsDelayed  := FALSE;
      saveCfgDelayed    := False;
//      savelists(MainProto);
      saveInboxDelayed  := FALSE;
      saveOutboxDelayed := FALSE;
      saveGroupsDelayed := FALSE;
      saveDBtimer2 := 0;
      saveAllLists(Account.ProtoPath, Account.AccProto, AllProxies, 'CFG changed');
     end;
    if saveInboxDelayed or
       saveOutboxDelayed or
       saveListsDelayed or
       saveGroupsDelayed or
       saveCfgDelayed
    then
     begin
      saveListsDelayed := FALSE;
      saveCfgDelayed := false;
//      savelists(MainProto);
      saveInboxDelayed := FALSE;
      saveOutboxDelayed := FALSE;
      saveGroupsDelayed := FALSE;
      saveDBtimer2 := 0;
      saveAllLists(Account.ProtoPath, Account.AccProto, AllProxies, 'delay');
     end;
   end;
  end;

  if autosizeDelayed then
    begin
      PntBar.Invalidate;
      autosizeDelayed := False;
    end;
// things to do twice per second
delayCount:=succ(delayCount) mod 5;
if delayCount = 0 then
  begin
  flushHistoryWritingQ();
  FlushLogPktFile();
  FlushLogEvFile();

  updateClocks();

  with updateViewInfoQ do
    begin
    resetEnumeration;
    while hasMore do
      begin
//       if MainProto.ProtoElem is TicqSession then
         begin
          vi1 := findViewInfo(getNext);
          if assigned(vi1) then
            begin
            vi1.updateInfo;
            if not formVisible(vi1) then
              begin
              showForm(vi1);
{              if vi1.readOnlyContact then
                vi1.displayBox.setFocus
              else
                vi1.nickBox.setFocus;}
              bringForeground := vi1.handle;
              end;
            end;
         end
      end;
    clear;
    end;

  if keepalive.enabled then
   begin
   if (keepalive.timer > 0) then
    begin
    dec(keepalive.timer);
    if keepalive.timer=0 then
      begin
       Account.AccProto.sendkeepalive;
//      avt_icq.sendKeepalive;
      keepalive.timer := keepalive.freq*2;
      end;
    end;
   end;

  // auto-away (isHooked is needed for keyboard handling)

 {$IFDEF PROTOCOL_ICQ}
  if
      isHooked and
      Account.AccProto.isOnline
     and (Account.AccProto.ProtoElem.ProtoID = ICQProtoID)
  then
   begin
//      SystemParametersInfo(SPI_GETSCREENSAVEACTIVE, 0, @isSSActive, 0);
      SystemParametersInfo(SPI_GETSCREENSAVERRUNNING, 0, @isSSRuning, 0);
//    GetLastInputInfo
//    with autoaway do
       inc(autoaway.time, 5);    // we are in delay-block then 0.5s
       if isMoved and not(autoaway.ss and (isSSRuning or isLocked))and not(autoaway.boss and BossMode.isBossKeyOn ) then
        begin
         autoaway.time := 0;
         if (autoaway.autoexit) and (autoaway.triggered<>TR_NONE) then
          exitFromAutoaway();
        end
      else
      if (autoaway.triggered=TR_NONE) and not (Account.AccProto.getStatus in [byte(SC_AWAY),byte(SC_NA),byte(SC_DND)])
      or (autoaway.triggered<>TR_NONE) then
        begin
        if autoaway.away and (autoaway.time >= autoaway.awayTime) and (autoaway.triggered=TR_NONE) then
          begin
          if autoaway.clearXSts and Assigned(Account.AccProto) then
            begin
              autoaway.bakxstatus := Account.AccProto.getXStatus;
              AwayXsts := ExtStsStrings[0];
              AwayXsts.Desc := autoaway.msg;
              autoaway.bakstatus := setStatusFull(Account.AccProto, byte(SC_AWAY),
                                                  0, AwayXsts);
            end
           else
            autoaway.bakstatus := setStatus(Account.AccProto, byte(SC_AWAY));
          autoaway.bakmsg := setAutomsg(autoaway.msg);

          autoaway.triggered := TR_AWAY;  // has to be set AFTER setstatus
          end;
        if (autoaway.na and (autoaway.time >= autoaway.naTime) and (autoaway.triggered<>TR_NA))
          or (autoaway.ss and (isSSRuning or isLocked))
          or (autoaway.boss and BossMode.isBossKeyOn)then
          begin
          if autoaway.triggered=TR_NONE then
            begin
            if autoaway.clearXSts and Assigned(Account.AccProto) then
              begin
                autoaway.bakxstatus := Account.AccProto.getXStatus;
                AwayXsts := ExtStsStrings[0];
                AwayXsts.Desc := autoaway.msg;
                autoaway.bakstatus := setStatusFull(Account.AccProto, byte(SC_NA),
                                                    0, AwayXsts);
              end
             else
              autoaway.bakstatus := setStatus(Account.AccProto, byte(SC_NA));
            autoaway.bakmsg := setAutomsg(autoaway.msg);
            end
          else
            begin
              setStatus(Account.AccProto, byte(SC_NA));
              setAutomsg(autoaway.msg);
            end;
          autoaway.triggered := TR_NA;  // has to be set AFTER setstatus
          end;
        end;
   end;
 {$ENDIF PROTOCOL_ICQ}

  if appBarResizeDelayed then
    begin
    appBarResizeDelayed := FALSE;
    if docking.appBar then
      utilLib.setAppBarSize;
    end;

  self.doAutosize;

  if rosterRebuildDelayed and not roasterLib.building then
    begin
    rosterRepaintDelayed := FALSE;
    rosterRebuildDelayed := FALSE;
    roasterLib.rebuild;
    end;
  if rosterRepaintDelayed then
    begin
    rosterRepaintDelayed := FALSE;
    roster.repaint;
    end;
  if dbUpdateDelayed then
    begin
    dbUpdateDelayed := FALSE;
//    inc(saveDBtimer, saveDBdelay);
    incDBTimer;
    if Assigned(RnQdbFrm) AND (RnQdbFrm.Handle <> 0) then
      RnQdbFrm.updateList;
    end;
  end; // short delay
// update nooncomingcounter
  if noOncomingCounter > 0 then
    dec(noOncomingCounter);

  chatFrm.chats.CheckTypingTimeAll;

// apply alwaysOnTop
  if formVisible(self) and (alwaysOnTop <> isTopMost(self)) then
    setTopMost(self, alwaysOnTop);
  if formVisible(chatFrm) and (chatAlwaysOnTop <> isTopMost(chatFrm)) then
    setTopMost(chatFrm, chatAlwaysOnTop);
  TipsShowTop;

  if MustQuit then
   quit;
end; // ontimer

procedure TRnQmain.Ignorelist1Click(Sender: TObject);
var
  c: TRnQcontact;
begin
  c := TRnQContact(clickedContact);
  if c=NIL then
    exit;
  if ignorelist.exists(c) then
    removeFromIgnorelist(c)
   else
    begin
     addToIgnorelist(c);
     if messageDlg(getTranslation('Do you want to remove %s from your contact list?', [c.displayed]), mtConfirmation, [mbYes,mbNo], 0) = mrYes then
      removeFromRoster(c);
    end;
end;

procedure TRnQmain.Openchatwith1Click(Sender: TObject);
var
  uid: TUID;
begin
 if enterUinDlg(Account.AccProto, uid, getTranslation('Open chat with...')) then
  chatFrm.openOn(Account.AccProto.getContact(uid));
end;

procedure TRnQmain.Getofflinemessages1Click(Sender: TObject);
begin
  Account.AccProto.GetOfflineMSGS;
end;

procedure TRnQmain.Deleteofflinemessages1Click(Sender: TObject);
begin
  Account.AccProto.DelOfflineMSGS;
 {$IFDEF PROTOCOL_ICQ}
  TicqSession(Account.AccProto).offlineMsgsChecked := TRUE;
 {$ENDIF PROTOCOL_ICQ}
end;

procedure TRnQmain.mainmenuimportclbClick(Sender: TObject);
//var
//  fn: string;
//  cl: TRnQCList;
begin
{  fn:=openSavedlg(self, '', True, 'clb');
  if fn = '' then exit;
  cl:=clb2contactlist(loadfileA(fn));
  cl.resetEnumeration;
  roster.hide;
  try
    while cl.hasmore do
      addToRoster(cl.getnext)
   finally
    roster.show
  end;
  cl.free;}
end;

procedure TRnQmain.mainmenuexportclbClick(Sender: TObject);
//var
//  fn: string;
begin
{fn := openSavedlg(self, '', False, 'clb');
if fn = '' then exit;
if savefile(fn, contactlist2clb(Account.AccProto.readList(LT_ROSTER))) then
  msgDlg('Done', True, mtInformation)
else
  msgDlg(Str_Error, True, mtError);}
end;

procedure TRnQmain.RQhomepage1Click(Sender: TObject);
begin
  utilLib.openURL(rnqSite)
end;

procedure TRnQmain.RQHelp1Click(Sender: TObject);
begin
  utilLib.openURL('http://help.rnq.ru')
end;

{procedure TRnQmain.RQforum1Click(Sender: TObject);
begin openURL('http://rnq.ru/forum') end;

procedure TRnQmain.RQwhatsnew1Click(Sender: TObject);
begin openURL('http://RnQ.ru/whatsnew.html') end;}

procedure TRnQmain.rosterKeyPress(Sender: TObject; var Key: Char);
var
  k: char;
begin
  k := upcase(key);
  //k :=AnsiUpperCase(key)[1];
  key := #0;  // avoid beep
case k of
  #8,#27: searching:='';
  #13:
    if roasterLib.focused<>NIL then
      if roasterLib.focused.kind = NODE_DIV then
        toggleOnlyOnline
      else
        chatFrm.openOn(roasterlib.focusedContact);
  'A'..'Z','0'..'9','_','@', '-', '=', '[', ']', 'а'..'я', 'А'..'Я':
    begin
    searching := searching+k;
    doSearch;
    lastSearchTime := now;
    exit;
    end;
  end;
formkeypress(sender, k);
end;

procedure TRnQmain.rosterMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  focused: Tnode;
begin
  focused := roasterLib.focused;
if (button = mbLeft) and (clickedNode<>NIL) then
  case clickedNode.kind of
    NODE_CONTACT:
      if (focused<>NIL) and into(point(x,y-focused.rect.top), focused.outboxRect) then
       begin
        if not Assigned(outboxfrm) then
          begin
            outboxfrm := ToutboxFrm.Create(Application);
            translateWindow(outboxfrm);
          end;
        outboxFrm.open(focused.contact);
       end;
    NODE_GROUP:
      if (focused<>NIL) and into(point(x,y-focused.rect.top), focused.outboxRect) then
        begin
          roster.ToggleNode(focused.treenode);
//          roaster.Expanded[focused.treenode] := not roaster.Expanded[focused.treenode];
        end;
    end;

with roster.ClientToScreen(point(x, y)) do
  if button = mbRight then
    roasterLib.popup(x, y);
end;

procedure TRnQmain.rosterDblClick(Sender: TObject);
var
  ev: Thevent;
begin
  if clickedNode = NIL then
    exit;
case clickedNode.kind of
  NODE_DIV: toggleOnlyOnline;
  NODE_CONTACT:
    begin
    ev := eventQ.firstEventFor(clickedContact);
    if ev=NIL then
      begin
      chatFrm.openOn(clickedContact);
      if chatFrm.Visible then
        chatFrm.setFocus;
      bringForeground := chatFrm.handle;
      end
    else
      begin
//        eventQ.removeEvent(ev.kind, clickedContact);
        eventQ.remove(ev);
        realizeEvent(ev);
//       realizeEvents(ev.kind, clickedContact);
      end;
    end;
  end;
end;

procedure TRnQmain.rosterKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  clickedContact := roasterlib.focusedContact;
  if shift=[] then
    case key of
      VK_HOME, VK_END, VK_PRIOR, VK_NEXT,
      VK_UP, VK_DOWN, VK_RIGHT, VK_LEFT: searching := '';
      VK_DELETE: delete1click(self);
      VK_F2: roasterLib.edit(roasterlib.focused);
      VK_F3: chatFrm.flash();
      VK_APPS: roasterLib.popup();
      end;
  if shift=[ssShift] then
    case key of
      VK_F10: roasterLib.popup();
      end;
end;

procedure TRnQmain.roasterStopEditing(sender:Tobject);
begin
  inplace.edit.hide
end;

procedure TRnQmain.roasterKeyEditing(Sender: TObject; var Key: Char);
begin
 case key of
  #27:
    begin
     key := #0;
     inplace.edit.hide;
     roster.setfocus;
    end;
  #13:
    begin
    key := #0;
    with inplace do
      case what of
        NODE_GROUP:
          if (groups.name2id(edit.text) < 0)
          or (messageDlg(getTranslation('The name %s already exists. Do you want to keep it?',[edit.text]), mtConfirmation, [mbYes,mbNo], 0) = mrYes) then
            begin
             groups.rename(groupId, edit.text);
             saveGroupsDelayed := TRUE;
            end;
        NODE_CONTACT:
          begin
            if edit.text <> contact.displayed then
             begin
              contact.display := edit.text;
             end;
  //                roasterLib.updateHiddenNodes;
  //                chatFrm.userChanged(contact);
                  redraw(contact);
            dbUpdateDelayed := TRUE;
            updateViewInfo(contact);
          end;
        end;
    roasterLib.sort(inplace.node);
    inplace.edit.hide;
     roster.SetFocus;
    exit;
    end;
  end;
end;

procedure TRnQmain.rosterCompareNodes(Sender: TBaseVirtualTree; Node1,
  Node2: PVirtualNode; Column: TColumnIndex; var Result: Integer);
begin
  result:=compareNodes(getnode(node1),getnode(node2))
end;

procedure TRnQmain.rosterMeasureItem(Sender: TBaseVirtualTree;
  TargetCanvas: TCanvas; Node: PVirtualNode; var NodeHeight: Integer);
begin
//  if Node = roaster.focusednode then
//    NodeHeight := TVirtualDrawTree(Sender).DefaultNodeHeight * 2;
end;

procedure TRnQmain.rosterMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
const
  SC_DragMove = $F012;
begin
  roasterlib.focus(roasterlib.nodeAt(x,y));
  {//anfmaker 29.03.2005
   Перемещение формы за DIVISOR
   BEGIN}
  if clickedNode = NIL then
    exit;
  if Self.Floating then
  case clickedNode.kind of
    NODE_DIV:
      begin
        ReleaseCapture;
        Perform(WM_SysCommand, SC_DragMove, 0);
      end;
  end
  {END
   //anfmaker}
end;

procedure TRnQmain.rosterCollapsed(Sender: TBaseVirtualTree; Node: PVirtualNode);
var
  n: Tnode;
  ex: Boolean;
begin
  if roasterLib.building then
    exit;
  autosizeDelayed := TRUE;
  n := getNode(node);
  if n.kind = NODE_GROUP then
    begin
      ex := groups.a[groups.idxOf(n.groupId)].expanded[n.divisor];
      if ex <> (vsExpanded in node.states) then
        begin
          groups.a[groups.idxOf(n.groupId)].expanded[n.divisor] := vsExpanded in node.states;
          saveGroupsDelayed := TRUE;
        end;
    end;
end;

procedure TRnQmain.rosterCollapsing(Sender: TBaseVirtualTree;
  Node: PVirtualNode; var Allowed: Boolean);
var
  n: Tnode;
begin
  n := getNode(node);
  if not assigned(n) then
    exit;
  allowed := n.kind<>NODE_DIV;
end;

procedure TRnQmain.rosterDragOver(Sender: TBaseVirtualTree;
  Source: TObject; Shift: TShiftState; State: TDragState; Pt: TPoint;
  Mode: TDropMode; var Effect: Integer; var Accept: Boolean);
var
  dest, destGrp,destDiv, clickedGrp, clickedDiv: Tnode;
begin
  accept := FALSE;
  if not Sender.Equals(Source) then
    Exit;
  dest := roasterLib.nodeAt(pt.x,pt.y);
  if dest=NIL then
    exit;
  case dest.kind of
   NODE_CONTACT:
    begin
    destGrp := dest.Parent;
    if destGrp.kind = NODE_GROUP then  // it's not sure that contact is under a group
      destDiv := destGrp.parent
    else
      begin
      destDiv := destGrp;
      destGrp := NIL;
      end;
    end;
   NODE_GROUP:
    begin
      destGrp := dest;
      destDiv := destGrp.parent;
    end;
   NODE_DIV:
    begin
      destGrp := NIL;
      destDiv := dest;
    end;
   else
    begin   // should never reach this
      msgDlg('error: drag over: unknown kind', True, mtError);
      exit;
    end;
  end;
if clickedContact <> NIL then
begin
  clickedGrp := Tnode(TCE(clickedContact.data^).node).parent;
  if clickedGrp.kind = NODE_DIV then
    begin
    clickedDiv := clickedGrp;
    clickedGrp := NIL;
    end
  else
    clickedDiv := clickedGrp.parent;
  Accept := (clickedDiv=destDiv) and (clickedContact<>NIL)
            and (clickedGrp<>destGrp);
  if Accept then
    if
 {$IFDEF UseNotSSI}
//      icq.useSSI and
     (not (clickedContact.fProto is TicqSession) or (TicqSession(clickedContact.fProto).UseSSI)) and
 {$ENDIF UseNotSSI}
      not clickedContact.CntIsLocal and
       (clickedContact.Proto.isOffline or not Assigned(destGrp) or (groups.idxOf(destGrp.groupID) < 0) or (groups.get(destGrp.groupID).ssiID = 0)) then
      Accept := False;
end
else
 if clickedGroup > 0 then
  begin
    if Assigned(clickedNode)and(clickedNode.parent <> NIL)and(clickedNode.parent.kind = NODE_DIV)  then
      clickedDiv := clickedNode.parent
     else
      clickedDiv := NIL;
//   clickedGrp:= groups.get(clickedGroup).;
//   clickedDiv := clickedGrp.divisor;
   Accept := //(clickedDiv=destDiv) and
     ((dest.kind = NODE_GROUP) and (clickedGroup<>destGrp.groupID))
     or
     ((dest.kind = NODE_DIV) and (clickedDiv=destDiv))
  end
// divisor must be the same, cannot cross divisors
//if (clickedGroup>0) or (clickedContact<>NIL) then
//  accept:=(clickedDiv=destDiv) and (clickedGrp<>destGrp);
end;

procedure TRnQmain.rosterDragDrop(Sender: TBaseVirtualTree;
  Source: TObject; DataObject: IDataObject; Formats: TFormatArray;
  Shift: TShiftState; Pt: TPoint; var Effect: Integer; Mode: TDropMode);
var
  grpOrDiv, n: Tnode;
  o: integer;
begin
  if not Sender.Equals(Source) then
    Exit;

  roasterLib.dragging := FALSE;
  grpOrDiv := roasterLib.nodeAt(pt.x, pt.y);
  while grpOrDiv.kind=NODE_CONTACT do
    grpOrDiv := grpOrDiv.Parent;
  if clickedContact<>NIL then
    setNewGroupFor(clickedContact, RDUtils.ifThen(grpOrDiv.kind=NODE_GROUP, grpOrDiv.groupId));
  if clickedGroup>0 then
  begin
    n := grpOrDiv;
    if n.kind=NODE_DIV then // we want the group to be the first
      begin
        // n = first group on this div
        n := n.firstChild;
        repeat
          n := n.next;
          if n=NIL then
            exit;
        until n.kind=NODE_GROUP;
        groups.get(clickedGroup).order := n.order-1
      end
    else
      begin
      // is this the last group?
      repeat
        n := n.next
      until (n=NIL) or (n.kind=NODE_GROUP);
      if n=NIL then
        // we want the group to be the last
        groups.get(clickedGroup).order := grpOrDiv.order+1
       else
        begin
          n := grpOrDiv;
          o := n.order-1;
          groups.get(clickedGroup).order := o;
          repeat
          if n.groupID<>clickedGroup then
            begin
            dec(o);
            groups.get(n.groupId).order := o;
            end;
          n := n.prev;
          until (n=NIL) or (n.kind<>NODE_GROUP);
        end;
      end;
    rosterRebuildDelayed := TRUE;
  end;
end;

procedure TRnQmain.rosterFocusChanged(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex);
//var
//  p : Pointer;
begin
  roasterLib.focus(node);
{  if Assigned(node) then
   begin
     p := sender.getnodedata(Node);
     if p <> NIL then
//      if (p^) is TNode then
       if Tnode(p^).kind = NODE_CONTACT then
        Sender.NodeHeight[Node] := TVirtualDrawTree(Sender).DefaultNodeHeight * 2;
   end;}
end;

procedure TRnQmain.menushowonlyimvisibleto1Click(Sender: TObject);
begin
  toggleOnlyImVisibleto
end;

procedure TRnQmain.rosterDrawNode(Sender: TBaseVirtualTree; const PaintInfo: TVTPaintInfo);
begin
  RstrDrawNode(Sender, PaintInfo, GetParentCurrentDpi);
end;

procedure TRnQmain.rosterFocusChanging(Sender: TBaseVirtualTree; OldNode,
  NewNode: PVirtualNode; OldColumn, NewColumn: TColumnIndex;
  var Allowed: Boolean);
begin
  roster.ClearSelection;
//  if NewNode <> OldNode then
//    Sender.NodeHeight[OldNode] := TVirtualDrawTree(Sender).DefaultNodeHeight;
end;

procedure TRnQmain.mainmenureloadtheme1Click(Sender: TObject);
begin
  reloadCurrentTheme()
end;

procedure TRnQmain.mainmenureloadlang1Click(Sender: TObject);
begin
  reloadCurrentLang()
end;

procedure TRnQmain.FormCreate(Sender: TObject);
begin
  self.CreateMenus;
  PntBar := TRnQPntBox.Create(bar);
//  PntBar.ControlStyle := [csOpaque];
  PntBar.Parent := bar;
//  PntBar.Align := alRight;
  PntBar.Align := alClient;
//  PntBar.
  PntBar.OnMouseDown := sbarMouseDown;
  PntBar.OnMouseUp   := sbarMouseUp;
  PntBar.OnDblClick  := sbarDblClick;
  PntBar.OnPaint     := PntBarPaint;

  uninstallHook;
  installHook(self.Handle);
  width := 120;
//contactsPnl := sbar.panels[0];

  application.OnActivate := appActivate;
  application.OnDeActivate := appActivate;
   {Let Windows know we accept dropped files}
   DragAcceptFiles(self.Handle, True);
//  Application.OnMessage := AppMessage;
  oldHandle := 0;
  mainfrmHandleUpdate;
  toggling := False;
  Self.GlassFrame.SheetOfGlass := CheckWin32Version(6);

  onAeroChanged;

// Self.DoubleBuffered := GlassFrame.SheetOfGlass;
// roster.DoubleBuffered := Self.GlassFrame.SheetOfGlass;
// StsBox.DoubleBuffered := True;
// FilterEdit.DoubleBuffered := Self.GlassFrame.SheetOfGlass;
// MlPnl.DoubleBuffered := True;
// MlCntLbl.do
// bar.DoubleBuffered := True;
// PntBar.do
// bar
end;

procedure TRnQmain.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if key=#27 then
    toggleVisible;
end;

procedure TRnQmain.rosterKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  formKeyDown(sender, key, shift)
end;

procedure TRnQmain.menusendaddedyou1Click(Sender: TObject);
begin
  if clickedContact = NIL then
    Exit;
  if messageDlg(getTranslation('You are about to send a notification to %s.\nContinue?',[clickedContact.displayed]),
               	mtConfirmation,	[mbYes,mbNo], 0) = mrYes then
    Account.outbox.add(OE_ADDEDYOU, clickedContact);
  if Assigned(outboxFrm) then
    outboxFrm.updateList;
end;

procedure TRnQmain.Readautomessage1Click(Sender: TObject);
begin
 {$IFDEF PROTOCOL_ICQ}
  if not clickedContact.fProto.isOnline then
    exit;
  if warnVisibilityAutoMsgReq and not clickedContact.imVisibleTo then
    case messageDlg(getTranslation('This action might make you visible to the contact.\nDo you want to continue?'), mtConfirmation, [mbYes,mbYesToAll,mbNo], 0) of
      mrYes: ;
      mrYesToAll: warnVisibilityAutoMsgReq := FALSE;
      else
//       mrNo:
       exit;
      end;
  sendICQautomsgreq(clickedContact)
 {$ENDIF PROTOCOL_ICQ}
end;

procedure TRnQmain.Readextstatus1Click(Sender: TObject);
begin
 {$IFDEF PROTOCOL_ICQ}
  if not Assigned(clickedContact) then
    Exit;
  if not clickedContact.Proto.isOnline then
    exit;
  if warnVisibilityAutoMsgReq and not clickedContact.imVisibleTo then
    case messageDlg(getTranslation('This action might make you visible to the contact.\nDo you want to continue?'), mtConfirmation, [mbYes,mbYesToAll,mbNo], 0) of
      mrYes: ;
      mrYesToAll: warnVisibilityAutoMsgReq := FALSE;
      else
//       mrNo:
       exit;
      end;
  TicqSession(clickedContact.fProto).RequestXStatus(clickedContact.uid);
 {$ENDIF PROTOCOL_ICQ}
end;

procedure TRnQmain.rosterMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
if (ssLeft in shift) and ((clickedContact<>NIL) or (clickedGroup>0)) then
  begin
    roasterLib.dragging := TRUE;
    roster.BeginDrag(FALSE);
  end;
end;

procedure TRnQmain.rosterGetHintSize(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; var R: TRect);
var
  bmp: Tbitmap;
  n: Tnode;
begin
  n := getNode(node);
  if n = nil then
    Exit;

  bmp := createBitmap(1, 1, currentPPI);
  bmp.Canvas.Font := Screen.HintFont;
  drawHint(bmp.canvas, n.kind, n.groupId, n.contact, r, True, currentPPI);
//  drawNodeHint(bmp.canvas, node, r);
  bmp.free;
end;

procedure TRnQmain.rosterDrawHint(Sender: TBaseVirtualTree;
  HintCanvas: TCanvas; Node: PVirtualNode; R: TRect; Column: TColumnIndex);
var
  n: Tnode;
begin
{ pre-paint is made on another canvas, the font is different, and i don't know
{ how to get the system tooltip font size. To get the same font size in paint
{ and pre-paint i set the font to the standard window font }
//hintcanvas.font := font;
//  Sender.
  n := getNode(node);
  if n = nil then
    Exit;
//  drawNodeHint(hintcanvas, node, r);
  drawHint(hintcanvas, n.kind, n.groupId, n.contact, r, false, GetParentCurrentDpi);
end;

procedure TRnQmain.minBtnClick(Sender: TObject);
begin
  toggleVisible
end;

procedure TRnQmain.MlCntBtnClick(Sender: TObject);
begin
  Account.AccProto.OpenMailBox;
end;

procedure TRnQmain.MMGenErrorClick(Sender: TObject);
begin
//  Exception.Create('Error');
  Exception.RaiseOuterException(Exception.Create('Just for info'));
end;

procedure TRnQmain.pwdBoxKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  i: integer;
  s, sub: string;
begin
  if key=VK_RETURN then
    begin
      sub := '';
      if shift=[SSctrl] then
        sub := CRLFs;
      if shift=[SSshift] then
        sub := #13;
      if shift=[SSalt] then
        sub := #10;
  with sender as Tedit do
    begin
    i := selstart;
    s := text;
    insert(sub, s, i+1);
    text := s;
    selstart := i+length(sub);
    end;
  end;
end; // pwdboxKeyDown

procedure TRnQmain.menuDrawItem(Sender: TObject; ACanvas: TCanvas; ARect: TRect; State: TOwnerDrawState);
begin
 {$IFNDEF NO_WIN98}
// if Win32MajorVersion < 5 then
//   drawmenuitemR98(ACanvas, TMenuItem(sender).GetParentMenu, TMenuItem(sender), ARect, false, True, odSelected in State)
//  else
 {$ENDIF WIN98}
   GPdrawmenuitemR7(ACanvas, TMenuItem(sender).GetParentMenu, TMenuItem(sender), ARect, false, True, odSelected in State);
end;

procedure TRnQmain.menuMeasureItem(Sender: TObject; ACanvas: TCanvas; var Width, Height: Integer);
var
  p: Tpoint;
begin
 {$IFNDEF NO_WIN98}
// if Win32MajorVersion < 5 then
//   p := drawmenuitemR98(ACanvas, TmenuItem(sender).GetParentMenu, TmenuItem(sender), rect(0,0,width,height), TRUE)
//  else
 {$ENDIF WIN98}
   p := GPdrawmenuitemR7(ACanvas, TmenuItem(sender).GetParentMenu, TmenuItem(sender), rect(0,0,width,height), TRUE);
  width := p.x;
//  inc(height,2);
  inc(p.y, 2);
  if (not MenuHeightPerm) or (height<p.y) then
    height := p.y;
end;

procedure TRnQmain.CreateMenus;
begin
 InitMenu;
 createMenusExt;
// InitProtoMenus();
end;


procedure TRnQmain.AAutomessage1Update(Sender: TObject);
begin
 {$IFDEF PROTOCOL_ICQ}
  if Sender is TAction then
    TAction(Sender).Visible := Assigned(Account.AccProto) and (Account.AccProto.getStatus in statusWithAutoMsg)
   else
    if Sender is TRQMenuItem then
      TRQMenuItem(Sender).Visible := Assigned(Account.AccProto) and (Account.AccProto.getStatus in statusWithAutoMsg);
 {$ENDIF PROTOCOL_ICQ}
end;

procedure TRnQmain.Aautomessage1splitUpdate(Sender: TObject);
begin
 {$IFDEF PROTOCOL_ICQ}
   { $IFDEF RNQ_FULL}
  if Sender is TAction then
     TAction(Sender).Visible := Assigned(Account.AccProto)and
                               ((Account.AccProto.getStatus in statusWithAutoMsg)or (showXStatusMnu))
   else
    if Sender is TRQMenuItem then
      TRQMenuItem(Sender).Visible := Assigned(Account.AccProto) and
                                    ((Account.AccProto.getStatus in statusWithAutoMsg)or (showXStatusMnu));
   { $ELSE RNQ_FULL}
//  TAction(Sender).Visible := False;
   { $ENDIF RNQ_FULL}
 {$ENDIF PROTOCOL_ICQ}
end;

procedure TRnQmain.AUIN1Update(Sender: TObject);
begin
  if clickedContact <> nil then
    TAction(Sender).Caption := getTranslation('%s (copy UIN)', [clickedContact.uin2Show]);
end;

procedure TRnQmain.AIP1Update(Sender: TObject);
begin
 {$IFDEF PROTOCOL_ICQ}
  if clickedContact <> nil then
    if TICQContact(clickedContact).connection.ip = 0 then
      TAction(Sender).visible:=FALSE
     else
  begin
    TAction(Sender).visible := TRUE;
    TAction(Sender).caption := getTranslation('%s (copy IP)', [ip2str(TICQContact(clickedContact).connection.ip)] );
  end;
 {$ENDIF PROTOCOL_ICQ}
end;

procedure TRnQmain.ASendemail1Update(Sender: TObject);
begin
 {$IFDEF PROTOCOL_ICQ}
  if clickedContact <> nil then
//    TAction(Sender).visible := Contact.email > ''
    TAction(Sender).visible := ((not (clickedContact is TICQcontact)) or (TICQcontact(clickedContact).email > ''))
//                  or (Contact is TMRAcontact)
  else
    TAction(Sender).visible := False;
 {$ENDIF PROTOCOL_ICQ}
end;

procedure TRnQmain.ASendSMSExecute(Sender: TObject);
begin
  clickedContact.SendSMS(self);
end;

procedure TRnQmain.ASendSMSUpdate(Sender: TObject);
begin
  TAction(Sender).Visible := clickedContact.CanSMS;
end;

procedure TRnQmain.cmAmovetogroupUpdate(Sender: TObject);
begin
{if Contact <> nil then
begin
  TAction(Sender).visible := ICQ.readroaster.exists(Contact);
  if Contact.group = 0 then
    TAction(Sender).caption := getTranslation('Move to group')
  else
    TAction(Sender).caption := getTranslation('Move from %s to group', [groups.id2name(Contact.group)] );
end}
  TAction(Sender).Enabled :=
    ( Assigned(clickedContact) and (clickedContact.CntIsLocal or clickedContact.Proto.isOnline
     {$IFDEF UseNotSSI}
//      or not icq.useSSI
      or ((clickedContact.fProto is TicqSession) and not TicqSession(clickedContact.fProto).useSSI)
     {$ENDIF UseNotSSI}
))
end;

procedure TRnQmain.Atempvisiblelist1Update(Sender: TObject);
begin //and tag= 3009
 {$IFDEF PROTOCOL_ICQ}
  if (clickedContact <> nil) {and not useSSI}
     and (clickedContact is TICQcontact)
  then
    with clickedContact.fProto do
     begin
      TAction(Sender).visible := isOnline and isInList(LT_TEMPVIS, clickedContact)
                               or not imVisibleTo(clickedContact);
      if isInList(LT_TEMPVIS, clickedContact) then
        TAction(Sender).HelpKeyword:=PIC_RIGHT
       else
        TAction(Sender).HelpKeyword := '';
     end
   else
 {$ENDIF PROTOCOL_ICQ}
     TAction(Sender).Visible := false;
end;

procedure TRnQmain.AReadautomessage1Update(Sender: TObject);
var
  showHidden: boolean;
begin
 {$IFDEF PROTOCOL_ICQ}
  showHidden := getShiftState() and (1+2)>0; // shift OR control
  if clickedContact <> nil then
   TAction(Sender).visible := showHidden or
    clickedContact.fProto.isOnline and (CAPS_sm_ICQSERVERRELAY in TICQContact(clickedContact).capabilitiesSm) and
    (byte(TICQContact(clickedContact).status) in statusWithAutomsg);
 {$ENDIF PROTOCOL_ICQ}
end;

procedure TRnQmain.ARename1Update(Sender: TObject);
begin
  TAction(Sender).Enabled :=
    ( Assigned(clickedContact) and (clickedContact.CntIsLocal or clickedContact.Proto.isOnline
     {$IFDEF UseNotSSI}
//      or not icq.useSSI
      or ((clickedContact.Proto is TicqSession) and not TicqSession(clickedContact.Proto).useSSI)
     {$ENDIF UseNotSSI}
))
end;

procedure TRnQmain.ARequestAvtUpdate(Sender: TObject);
begin
  {$IFDEF RNQ_AVATARS}
  if clickedContact <> nil then
    TAction(Sender).visible := clickedContact.AvatarNeedToRefresh;
  {$ELSE RNQ_AVATARS}
  TAction(Sender).visible := false;
  {$ENDIF RNQ_AVATARS}
end;

procedure TRnQmain.contactMenuNEWPopup(Sender: TObject);
begin
{  if ICQ.readroaster.exists(clickedContact) then
    addGroupsToMenu(contactMenuNEW, movetogroupNEW, addcontactAction)
  else
    addGroupsToMenu(contactMenuNEW, addtocontactlistNEW, addcontactAction);}
end;

procedure TRnQmain.SelectTheme(Sender: TObject);
var
  i: NativeInt;
begin
  if not(Sender is TRQMenuItem) then
    exit;
  i := TRQMenuItem(Sender).tag;
  if (i >= Low(theme.themelist2)) and
     (i <= High(theme.themelist2)) then
   begin
//    theme.fn:=themelist2[TRQMenuItem(Sender).tag].fn;
    with theme.themelist2[i] do
      theme.load(fn, subFile);
    with RQSmilesPath do
      theme.load(fn, subfn, False, tsc_smiles);
    with RQSoundsPath do
      theme.load(fn, subfn, False, tsc_sounds);
    Theme.loadThemeScript(userthemeFilename, AccPath);
    applyTheme;
//    saveCFG;
    saveCfgDelayed := True;
//    reloadCurrentTheme;
   end
  else
   msgDlg('Not found this theme''s description. Make Refresh-List.', True, mtError);
{  for i := 3 to mainmenuthemes1.Count - 1 do
    if mainmenuthemes1.items[i] is TRQMenuItem then
      TRQMenuItem(mainmenuthemes1.items[i]).ImageName := PIC_UNCHECKED;
  TRQMenuItem(Sender).ImageName := PIC_CHECKED;}
end;

procedure TRnQmain.SelectSmiles(Sender: TObject);
var
  i: NativeInt;
begin
  if not(Sender is TRQMenuItem) then
    exit;
  i := TRQMenuItem(Sender).tag;
  if (i >= Low(theme.smileList)) and
     (i <= High(theme.smileList)) then
   begin
//    theme.fn:=themelist2[TRQMenuItem(Sender).tag].fn;
    with theme.smileList[i] do
    begin
     RQSmilesPath.pathType := pt_path;
     RQSmilesPath.fn := fn;
     RQSmilesPath.subfn := subFile;
     if fn>'' then
       begin
        theme.load(fn, subFile, False, tsc_smiles);
        Theme.loadThemeScript(userthemeFilename, AccPath);
        mainmenugetthemes1Click(nil);
       end
      else
       reloadCurrentTheme();
    end;
//    applyTheme;
//    mainmenugetthemes1Click(nil);
//    chatDlg.chatFrm.pagectrl.Refresh;
//    chatDlg.chatFrm.pagectrl.ActivePage.Invalidate;
      if chatFrm.thisChat<>NIL then
        chatFrm.thisChat.repaint;
//     chatFrm.InValidate;
//    saveCFG;
    saveCfgDelayed := True;
//    reloadCurrentTheme;
   end
  else
   msgDlg('Not found this theme''s description. Make Refresh-List.', True, mtError);
{  for i := 3 to mainmenuthemes1.Count - 1 do
    if mainmenuthemes1.items[i] is TRQMenuItem then
      TRQMenuItem(mainmenuthemes1.items[i]).ImageName := PIC_UNCHECKED;
  TRQMenuItem(Sender).ImageName := PIC_CHECKED;}
end;

procedure TRnQmain.SelectSounds(Sender: TObject);
var
  i: NativeInt;
begin
  if not(Sender is TRQMenuItem) then
    exit;
  i := TRQMenuItem(Sender).tag;
  if (i >= Low(theme.soundList)) and
     (i <= High(theme.soundList)) then
   begin
//    theme.fn:=themelist2[TRQMenuItem(Sender).tag].fn;
    with theme.soundList[i] do
    begin
     RQSoundsPath.pathType := pt_path;
     RQSoundsPath.fn := fn;
     RQSoundsPath.subfn := subFile;
     if fn>'' then
       begin
        theme.load(fn, subFile, False, tsc_sounds);
        Theme.loadThemeScript(userthemeFilename, AccPath);
        mainmenugetthemes1Click(nil);
       end
      else
       reloadCurrentTheme();
    end;
//    applyTheme;
//    mainmenugetthemes1Click(nil);
//    chatDlg.chatFrm.pagectrl.Refresh;
//    chatDlg.chatFrm.pagectrl.ActivePage.Invalidate;
//     chatFrm.thisChat.repaint;
//    saveCFG;
    saveCfgDelayed := True;
//    reloadCurrentTheme;
   end
  else
   msgDlg('Not found this theme''s description. Make Refresh-List.', True, mtError);
end;

procedure TRnQmain.mainmenugetthemes1Click(Sender: TObject);
begin
  theme.refreshThemelist;
  refreshMenuThemelist(mainmenuthemes1, 6, SelectTheme);
  refreshMenuSmileslist(SmilesMenu, 0, SelectSmiles);
  refreshMenuSoundslist(SoundsMenu, 0, SelectSounds);
end;

procedure TRnQmain.AShowgroups1Update(Sender: TObject);
begin
  if showGroups then
    TAction(Sender).HelpKeyword := PIC_RIGHT
   else
    TAction(Sender).HelpKeyword := '';
end;

procedure TRnQmain.AShowonlyonlinecontacts1Update(Sender: TObject);
begin
  if showOnlyOnline then
    TAction(Sender).HelpKeyword := PIC_RIGHT
   else
    TAction(Sender).HelpKeyword := '';
end;

procedure TRnQmain.Amenushowonlyimvisibleto1Update(Sender: TObject);
begin
  if showOnlyImVisibleTo then
    TAction(Sender).HelpKeyword := PIC_RIGHT
   else
    TAction(Sender).HelpKeyword := '';
end;

procedure TRnQmain.ANothingExecute(Sender: TObject);
begin
//
end;

procedure TRnQmain.AVisiblelist1Update(Sender: TObject);
begin //tag = 3000
  if Assigned(clickedContact) and clickedContact.isInList(LT_VISIBLE) then
    TAction(Sender).HelpKeyword := PIC_RIGHT
   else
    TAction(Sender).HelpKeyword := '';
end;

procedure TRnQmain.AInvisiblelist1Update(Sender: TObject);
begin // tag = 3001
  if Assigned(clickedContact) and clickedContact.isInList(LT_INVISIBLE) then
    TAction(Sender).HelpKeyword := PIC_RIGHT
   else
    TAction(Sender).HelpKeyword := '';
end;

procedure TRnQmain.ADelete1Update(Sender: TObject);
//var
//  vs : Boolean;
begin
//  vs := getShiftState() and (1+2)>0; // shift OR control
  TAction(Sender).Visible := getShiftState() and (1+2) = 0;
  TAction(Sender).Enabled := Assigned(clickedContact) and clickedContact.canEdit;
end;

procedure TRnQmain.AIgnorelist1Update(Sender: TObject);
begin //tag = 3007
  if ignoreList.exists(clickedContact) then
    TAction(Sender).HelpKeyword := PIC_RIGHT
   else
    TAction(Sender).HelpKeyword := '';
end;

procedure TRnQmain.mAThmCntEdtExecute(Sender: TObject);
var
  s: String;
begin
  if fantomWork then
    Exit;
  s := AccPath + contactsthemeFilename;
  if not FileExists(s) then
    appendFile(s, '');
  exec(s);
//  ShellExecute()
end;

procedure TRnQmain.mAViewSSIUpdate(Sender: TObject);
begin
 {$IFDEF PROTOCOL_ICQ}
  if Sender is TAction then
    TAction(Sender).Visible := Assigned(Account.AccProto) and
             (Account.AccProto.ProtoElem is TicqSession);
 {$ENDIF PROTOCOL_ICQ}
end;

procedure TRnQmain.mAvisibilityUpdate(Sender: TObject);
var
  b: Boolean;
  visArr: TStatusArray;
begin // tag = 3005
//  TAction(Sender).HelpKeyword := visibilityImgName;
  b := True;
  if Assigned(Account.AccProto) then
    begin
     visArr := Account.AccProto.getVisibilities;
     if Assigned(visArr) then
      begin
       b := False;
       TAction(Sender).HelpKeyword := visArr[Account.AccProto.getVisibility].ImageName;
      end;
    end;
  if b then
    TAction(Sender).HelpKeyword := status2imgName(byte(SC_UNK), FALSE);
end;

procedure TRnQmain.mAStatusUpdate(Sender: TObject);
var
  st: Byte;
begin // tag = 3004
  if Assigned(Account.AccProto) then
    begin
      if Account.AccProto.isOnline then
        begin
          if Account.AccProto.isOnline then
            st := Account.AccProto.getStatus
           else
            st := byte(SC_OFFLINE);
          TAction(Sender).HelpKeyword := String(Account.AccProto.status2imgName(st))
        end
       else
        TAction(Sender).HelpKeyword := status2imgName(byte(SC_OFFLINE), false);
    end
   else
     TAction(Sender).HelpKeyword := status2imgName(byte(SC_UNK), FALSE);
end;

procedure TRnQmain.mAgetofflinemsgsUpdate(Sender: TObject);
begin
 {$IFDEF PROTOCOL_ICQ}
  TAction(Sender).visible := not TicqSession(Account.AccProto).offlineMsgsChecked and
           not getOfflineMsgs and not delOfflineMsgs;
 {$ENDIF PROTOCOL_ICQ}
end;

procedure TRnQmain.mAHelpExecute(Sender: TObject);
begin
  utilLib.openURL(myPath + docsPath + getTranslation(helpFilename));
end;

procedure TRnQmain.mAHelpUpdate(Sender: TObject);
begin
 if Sender is TRQMenuItem then
  TRQMenuItem(Sender).visible:= helpExists;
end;

procedure TRnQmain.mAdeleteofflinemsgsUpdate(Sender: TObject);
begin
 {$IFDEF PROTOCOL_ICQ}
  if Assigned( Account.AccProto ) then
    TAction(Sender).visible := not TicqSession(Account.AccProto).offlineMsgsChecked and not delOfflineMsgs;
 {$ENDIF PROTOCOL_ICQ}
end;

procedure TRnQmain.mARequestCLExecute(Sender: TObject);
begin
 {$IFDEF PROTOCOL_ICQ}
  if OnlFeature(Account.AccProto) then
//    icq.SSIreqRoaster
    TicqSession(Account.AccProto).RequesTContactList();
 {$ENDIF PROTOCOL_ICQ}
end;

procedure TRnQmain.mARequestCLUpdate(Sender: TObject);
begin
 {$IFDEF UseNotSSI}
  TAction(Sender).visible := //not icq.useSSI;
  (Account.AccProto.ProtoElem is TicqSession) and not TicqSession(Account.AccProto.ProtoElem).UseSSI
 {$ELSE UseNotSSI}
  TAction(Sender).visible := False;
 {$ENDIF UseNotSSI}
end;

procedure TRnQmain.cACheckInvisibilityExecute(Sender: TObject);
//var
//  id: Integer;
begin
 {$IFDEF CHECK_INVIS}
  checkInvQ.add(clickedContact);
{  if supportInvisCheck and OnlFeature then
   begin
    id := ICQ.CheckInvisibility(clickedContact.uin);
    acks.add(OE_msg, clickedContact.uin, 0, 'Inv').ID := id;
   end
} {$ENDIF}
end;

procedure TRnQmain.cACheckInvisibilityUpdate(Sender: TObject);
begin
 {$IFDEF CHECK_INVIS}
  if clickedContact <> nil then
    TAction(Sender).Visible := supportInvisCheck and
       ((not clickedContact.isOnline) or (clickedContact.isInvisible));
 {$ELSE}
   TAction(Sender).Visible := false;
 {$ENDIF}
end;

procedure TRnQmain.mAChkInvisAllExecute(Sender: TObject);
//var
//  id: Integer;
begin
 {$IFDEF CHECK_INVIS}
 checkInvis.lastAllChkTime := now;
 checkInvQ.add(CheckInvis.CList);
 checkInvQ.add(autoCheckInvQ);
{ try
  if supportInvisCheck and ICQ.isOnline then
   begin
    CheckInvis.CList.resetEnumeration;
    while CheckInvis.CList.hasMore do
     with CheckInvis.CList.getNext do
      if status in [SC_OFFLINE, SC_UNK] then
       if icq.isOnline then
      begin
        id :=ICQ.CheckInvisibility(uin);
        acks.add(OE_msg, uin, 0, 'InvAll').ID := id;
      end;
   end
  else
    if not CheckInvis.AutoCheck then OnlFeature;
 except
 end;
}  checkInvis.lastAllChkTime := now;
 {$ENDIF}
end;

procedure TRnQmain.cAReadXstUpdate(Sender: TObject);
var
  k: byte;
begin
  TAction(Sender).Visible := False;
 {$IFDEF PROTOCOL_ICQ}
  if (Sender is TAction) and Assigned(clickedContact)
     and (clickedContact is TICQContact) then
    begin
     TAction(Sender).Visible := boolean(getShiftState() and (1+2)) // shift OR control
                               or (TICQContact(clickedContact).capabilitiesXTraz <> []);
     if TAction(Sender).Visible then
       begin
        if TICQContact(clickedContact).capabilitiesXTraz <> [] then
          for k in TICQContact(clickedContact).capabilitiesXTraz do
           begin
            TAction(Sender).HelpKeyword := XStatusArray[k].PicName;
            break;
           end
         else
          TAction(Sender).HelpKeyword := XStatusArray[0].PicName;
       end;
    end;
 {$ENDIF PROTOCOL_ICQ}
end;

procedure TRnQmain.cARemFrHisCLExecute(Sender: TObject);
begin
 {$IFDEF PROTOCOL_ICQ}
  if OnlFeature(Account.AccProto) then
    TicqSession(Account.AccProto.ProtoElem).RemoveMeFromHisCL(clickedContact.uid)
 {$ENDIF PROTOCOL_ICQ}
end;

procedure TRnQmain.cASendFileExecute(Sender: TObject);
var
  fn: String;
begin
 {$IFDEF usesDC}
  fn := openSaveDlg(self, 'Select file to transfer', True);
  if fn > '' then
//  if OpenSaveFileDialog(Application.Handle, '*',
//     'Any file|*.*', '', 'Select file to transfer', fn, True) then
//  if OpenPicDlg.Execute then
  begin
    if not FileExists(fn) then
     begin
       msgDlg('File doesn''t exist', TRUE, mtError);
       exit;
     end;
    if Assigned(clickedContact) then
//      TsendFileFrm.doAll(self, TICQContact(clickedContact), fn);
//      ICQsendfile(TICQContact(clickedContact), fn);
      clickedContact.SendFilesTo(fn);
  end;
 {$ENDIF usesDC}
end;

procedure TRnQmain.cASendFileUpdate(Sender: TObject);
begin
  if Sender is TAction then
   with Sender as TAction do
    begin
     Visible :=
 {$IFDEF usesDC}
        Assigned(clickedContact) and clickedContact.fProto.IsOnline and
         (CAPS_sm_FILE_TRANSFER in TICQContact(clickedContact).capabilitiesSm);
 {$else not usesDC}
        false;
 {$ENDIF  usesDC}
//     if Visible then
{        Enabled := (clickedContact.group <> 0)
//        and (clickedContact.group <> 0)
           and (groups.id2ssi(clickedContact.group) > 0);}
    end;
end;

procedure TRnQmain.cAAdd2ServerExecute(Sender: TObject);
begin
  if Assigned(clickedContact) then
//   if clickedContact.iProto.ProtoElem is TICQSession then
//     TICQSession(clickedContact.iProto.ProtoElem).SSIAddContact(TICQContact(clickedContact))
//    else
     clickedContact.Proto.addContact(clickedContact);
//  ICQ.addContact(clickedContact);
end;

procedure TRnQmain.cAAdd2ServerUpdate(Sender: TObject);
var
  prt: byte;
begin
  if Sender is TAction then
   with Sender as TAction do
    begin
     Visible :=
        Assigned(clickedContact) and clickedContact.CntIsLocal and
        clickedContact.Proto.IsOnline
 {$IFDEF UseNotSSI}
//        icq.useSSI and
        and (not(clickedContact.Proto.ProtoElem is TicqSession) or
             TicqSession(clickedContact.Proto.ProtoElem).UseSSI)
 {$ENDIF UseNotSSI}
         ;
      if Visible then
       begin
        prt := clickedContact.Proto._getProtoID;
        Enabled :=
  {$IFDEF PROTOCOL_XMP}
            (prt=XMPProtoID)or
  {$ENDIF PROTOCOL_XMP}
            ((clickedContact.groupId <> 0)
//        and (clickedContact.group <> 0)
             and (groups.id2ssi(clickedContact.groupId) > 0));
       end;
    end;
end;

procedure TRnQmain.cAAuthGrantExecute(Sender: TObject);
begin
 {$IFDEF PROTOCOL_ICQ}
  if Assigned(clickedContact) then
    TICQSession(clickedContact.fProto).AuthGrant(clickedContact)
 {$ENDIF PROTOCOL_ICQ}
end;

procedure TRnQmain.cAAuthGrantUpdate(Sender: TObject);
begin
  TAction(Sender).Visible := getShiftState() and (1+2)>0; // shift OR control
end;

procedure TRnQmain.cAAuthReqstUpdate(Sender: TObject);
begin
  TAction(Sender).Visible := boolean(getShiftState() and (1+2))
       or (
          Assigned(clickedContact) and not clickedContact.CntIsLocal and not clickedContact.Authorized
          and clickedContact.isInRoster
 {$IFDEF UseNotSSI}
//          and icq.useSSI
          and (not(clickedContact.iProto.ProtoElem is TicqSession) or
               TicqSession(clickedContact.iProto.ProtoElem).UseSSI)
 {$ENDIF UseNotSSI}
          ); // shift OR control
end;

procedure TRnQmain.cAChkInvisListExecute(Sender: TObject);
//var
//  c: Tcontact;
begin
 {$IFDEF CHECK_INVIS}
  if clickedContact=NIL then
    exit;
//  c := TICQContact(clickedContact);
  if CheckInvis.CList.exists(clickedContact) then
    CheckInvis.CList.remove(clickedContact)
  else
    CheckInvis.CList.Add(clickedContact);
  saveListsDelayed := TRUE;
 {$ENDIF}
end;

procedure TRnQmain.cAChkInvisListUpdate(Sender: TObject);
begin
 {$IFDEF PROTOCOL_ICQ}
{ $IFDEF RNQ_FULL}
  TAction(Sender).Visible := supportInvisCheck;
 {$IFDEF CHECK_INVIS}
  if CheckInvis.CList.exists(clickedContact) then
    TAction(Sender).HelpKeyword := PIC_RIGHT
   else
    TAction(Sender).HelpKeyword := '';
 {$ENDIF}
{ $ELSE}
//  TAction(Sender).Visible := false;
{ $ENDIF}
 {$ENDIF PROTOCOL_ICQ}
end;

procedure TRnQmain.cADeleteOHExecute(Sender: TObject);
begin
 if assigned(clickedContact) then
   DelHistWith(clickedContact.UID2cmp);
end;

procedure TRnQmain.cADeleteOHUpdate(Sender: TObject);
begin
 TAction(Sender).Visible := boolean(getShiftState() and (1+2)); // shift OR control
// TAction(Sender).Visible := boolean(getShiftState() and (2)); // shift OR control
// TAction(Sender).Enabled :=
//     ( Assigned(clickedContact) and (clickedContact.CntIsLocal or ActiveProto.isOnline))
end;

procedure TRnQmain.cADeleteWHExecute(Sender: TObject);
begin
 if assigned(clickedContact) then
  if messageDlg(getTranslation('Are you sure you want to delete %s from your list with his history?', [clickedContact.displayed]),mtConfirmation, [mbYes,mbNo], 0) = mrYes then
    removeFromRoster(clickedContact, True);
end;

procedure TRnQmain.cADeleteWHUpdate(Sender: TObject);
begin
 TAction(Sender).Visible := boolean(getShiftState() and (1+2)); // shift OR control
 TAction(Sender).Enabled :=
     ( Assigned(clickedContact) and
       (clickedContact.CntIsLocal or clickedContact.Proto.isOnline
 {$IFDEF UseNotSSI}
//        or not icq.useSSI
       or ((clickedContact.Proto is TicqSession) and
               not TicqSession(clickedContact.Proto).UseSSI)
 {$ENDIF UseNotSSI}
       ))
end;

procedure TRnQmain.cAMakeLocalExecute(Sender: TObject);
begin
 if assigned(clickedContact) and clickedContact.Proto.isOnline then
   clickedContact.DelCntFromSrv;
end;

procedure TRnQmain.cAMakeLocalUpdate(Sender: TObject);
begin
  if Sender is TAction then
   with Sender as TAction do
     Visible :=
        Assigned(clickedContact) and clickedContact.Proto.IsOnline and
        not clickedContact.CntIsLocal and
        (clickedContact.SSIID <> 0) and
//        (TICQContact(clickedContact).SSIID <> 0) and
        clickedContact.isInRoster
 {$IFDEF UseNotSSI}
//        and icq.useSSI
        and (not(clickedContact.fProto is TicqSession) or
               TicqSession(clickedContact.fProto).UseSSI)
 {$ENDIF UseNotSSI}
        ;
end;

{//anfmaker 29.03.2005
Перемещение формы за sbar}
procedure TRnQmain.sbarMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
const
        SC_DragMove = $F012;
begin
  if Self.Floating then
   begin
    ReleaseCapture;
    Perform(WM_SysCommand, SC_DragMove, 0);
   end;
end;

procedure TRnQmain.mAHistoryUtilsExecute(Sender: TObject);
begin
 {$IFNDEF DB_ENABLED}
   if not Assigned(histUtilsFrm) then
    begin
      histUtilsFrm := ThistUtilsFrm.Create(Application);
      translateWindow(histUtilsFrm);
    end;
   histUtilsFrm.show;
 {$ENDIF DB_ENABLED}
end;

procedure TRnQmain.statusBtnMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
//  x1, y1: Integer;
  R: TRect;
begin
  if button = mbRight then
//   with mousePos do xstatusMenu.Popup(x,y)
   begin
    if Self.Floating then
      R := Self.BoundsRect
     else
      begin
//        R := chatFrm.BoundsRect
        r.TopLeft := self.ClientToScreen(Self.BoundsRect.TopLeft);
        r.BottomRight := self.ClientToScreen(Self.BoundsRect.BottomRight);
      end;
     ;
    with Self.ClientToScreen(Point(x,y)) do
     TxStatusForm.ShowNear2(Self, Account.AccProto, R, x, y)
   end;
//  with boundsrect do xstatusMenu.Popup(x,y)
end;

procedure TRnQmain.mAChkInvisAllUpdate(Sender: TObject);
begin
 {$IFDEF PROTOCOL_ICQ}
 { $IFDEF RNQ_FULL}
  TAction(Sender).Visible := supportInvisCheck
 { $ELSE}
//  TAction(Sender).Visible := false;
 { $ENDIF}
 {$ENDIF PROTOCOL_ICQ}
end;

procedure TRnQmain.mASinchrCLExecute(Sender: TObject);
begin
  if Account.AccProto.isOnline then
   begin
//    CLsyncDlg := TCLsyncDlg.Create(self);
//    translateWindow(CLsyncDlg);
//    showForm(CLsyncDlg);
//    RQ_ICQ.saveSSI;
   end
//  else
//    OnlFeature;
end;

 procedure TRnQmain.mASinchrCLUpdate(Sender: TObject);
begin
 {$IFDEF UseNotSSI}
  (sender as TAction).Visible := xxx and
//     not icq.useSSI;
     (Account.AccProto.ProtoElem is TicqSession) and
      not TicqSession(Account.AccProto.ProtoElem).UseSSI
 {$ELSE UseNotSSI}
  (sender as TAction).Visible := False;
 {$ENDIF UseNotSSI}
end;

{$IFDEF RNQ_PLAYER}
procedure TRnQmain.mARnQPlayerExecute(Sender: TObject);
begin
  if not Assigned(RnQPlayer) then
   begin
     RnQPlayer := TRnQPlayer.Create(Application);
//     frmPlayer.Parent :=
     translateWindow(RnQPlayer);
     applyCommonSettings(RnQPlayer);
   end;
  showForm(RnQPlayer);
end;
 {$ENDIF RNQ_PLAYER}

procedure TRnQmain.mAXStatusExecute(Sender: TObject);
var
  x, y: Integer;
  R: TRect;
begin
//  with mousePos do xstatusMenu.Popup(x,y);
    if Self.Floating then
      begin
        x := Self.Left;
        y := Self.Top + Self.Height;
        R := Self.BoundsRect
      end
     else
      begin
//        x := chatFrm.Left + chatFrm.Width;
//        y := chatFrm.Top + chatFrm.Height;
//        R := chatFrm.BoundsRect;
        r.TopLeft := self.ClientToScreen(Self.BoundsRect.TopLeft);
        r.BottomRight := self.ClientToScreen(Self.BoundsRect.BottomRight);
        x := r.Left;
        y := r.Top + Self.Height;
      end;
//    with Self.ClientToScreen(Point(x,y)) do
  TxStatusForm.ShowNear2(Self, Account.AccProto, R, x, y)
end;

procedure TRnQmain.mAXStatusUpdate(Sender: TObject);
begin
 { $IFDEF RNQ_FULL}
 if Sender is TAction then
  begin
     TAction(Sender).Visible := showXStatusMnu;
    if TAction(Sender).Visible then
    try
      TAction(Sender).HelpKeyword := Protocols_all.Protos_getXstsPic(nil, True);
     except
    end;
  end
 else
  if Sender is TRQMenuItem then
   begin
     TRQMenuItem(Sender).Visible := showXStatusMnu;
    if TRQMenuItem(Sender).Visible then
    try
       TRQMenuItem(Sender).ImageName := Protocols_all.Protos_getXstsPic(nil, True);
     except
    end;
   end;
 { $ELSE RNQ_FULL}
//   TAction(Sender).Visible := false;
 { $ENDIF RNQ_FULL}
end;

procedure TRnQmain.mAhideUpdateEx(Sender: TObject);
begin //tag = 3002
  if formVisible(self) then
   begin
     TRQMenuItem(Sender).ImageName := PIC_MINIMIZE;
     TRQMenuItem(Sender).Caption   := getTranslation('Hide');
   end
  else
   begin
     TRQMenuItem(Sender).ImageName := PIC_RESTORE;
     TRQMenuItem(Sender).Caption   := getTranslation('Show');
   end;
end;

procedure TRnQmain.menuPopup(Sender: TObject);
var
//  i: Integer;
  ev: TaMenuItemUpd;
begin
//  for i := Low(aMainMenuUpd) to High(aMainMenuUpd) do
//    aMainMenuUpd[i].amiuEv(aMainMenuUpd[i].amiuMenu);
  for ev in aMainMenuUpd do
    ev.amiuEv(ev.amiuMenu);
  for ev in aMainMenuUpd2 do
   if Assigned(ev.amiuMenu) then
    ev.amiuEv(ev.amiuMenu);
//  for i := Low(aMainMenuUpd2) to High(aMainMenuUpd2) do
//   with aMainMenuUpd2[i]
//    .amiuEv(aMainMenuUpd[i].amiuMenu);
{ not working :(
// Set WS_EX_LAYERED on this window
SetWindowLong(TPopupMenu(Sender).WindowHandle, GWL_EXSTYLE,
        GetWindowLong(TPopupMenu(Sender).WindowHandle, GWL_EXSTYLE) or WS_EX_LAYERED);
// Make this window 70% alpha
SetLayeredWindowAttributes(TPopupMenu(Sender).WindowHandle, 0, (255 * 70) div 100, LWA_ALPHA);
}
end;

procedure TRnQmain.StatusMenuPopup(Sender: TObject);
var
//  i: Integer;
  ev: TaMenuItemUpd;
begin
//  for i := Low(aStatusMenuUpd) to High(aStatusMenuUpd) do
//    aStatusMenuUpd[i].amiuEv(aStatusMenuUpd[i].amiuMenu);
  for ev in aStatusMenuUpd do
   if Assigned(ev.amiuMenu) then
    ev.amiuEv(ev.amiuMenu);
end;

procedure TRnQmain.CMMouseEnter(var Msg: TMessage);
begin
  inherited;
  if Pointer(msg.LParam) = Pointer(roster) then
  if (transparency.chgOnMouse) and not FMouseInControl then
   begin
    if alphablend then
     alphablendvalue := transparency.active;
    FMouseInControl := True;
   end;
//    if mainfrm.alphablendvalue <> transparency.active then
// trackingMouse(false);

end;

procedure TRnQmain.CMMouseLeave(var Msg: TMessage);
begin
  inherited;
  if Pointer(msg.LParam) = Pointer(roster) then
   if (transparency.chgOnMouse) and FMouseInControl then
   begin
    if alphablend then
     if handle <> getForegroundWindow then
      alphablendvalue := transparency.inactive;
    FMouseInControl := False;
   end;
end;

procedure TRnQmain.Showallcontactsinone1Click(Sender: TObject);
begin
  OnlOfflInOne := not OnlOfflInOne;
//design_fr.prefToggleShowGroups;
  rosterRebuildDelayed := TRUE;
end;

procedure TRnQmain.AContInOneUpdate(Sender: TObject);
begin
  if OnlOfflInOne then
    TAction(Sender).HelpKeyword := PIC_RIGHT
   else
    TAction(Sender).HelpKeyword := '';
end;

{procedure TRnQmain.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  with Params do
  begin
//    Style := Style and (not WS_CAPTION);
//    Style := Style and not WS_OVERLAPPEDWINDOW or WS_BORDER and (not WS_CAPTION);
    Style := (Style or WS_POPUP) and (not WS_DLGFRAME);
//    Style := Style or WS_SYSMENU;
//    ExStyle := ExStyle or WS_EX_APPWINDOW or WS_EX_NOPARENTNOTIFY;
  end;
end;
}

PROCEDURE TRnQmain.wmNCHitTest(VAR Msg: TWMNCHitTest);
BEGIN
  Inherited;
  WITH Msg DO
   begin
     if TopLbl.Visible then
      begin
        IF YPos-Top <= TopLbl.Height THEN
         if (XPos - Left < 10)or(XPos - Left - Width > -10) then
           Result := HTSYSMENU
          else
           Result := HTCAPTION;
       if within(0, YPos - Top, 5) then
          if within(-5, XPos - Left - Width,0)then
            Result := HTTOPRIGHT
           else
            if within(0, XPos - Left, 5)then
             Result := HTTOPLEFT;
      end;
     if (within(-5, YPos - ClientRect.Bottom, 0) and within(-5, XPos - ClientRect.Right,0))then
        Result := HTBOTTOMRIGHT;
   end;

END;

(*
procedure TRnQmain.UpdatePluginPanel;
begin
  if not Assigned(MainPlugBtns.PluginsTB) then
   begin
//  usePlugPanel := True;
    if not useMainPlugPanel then
//     MainPlugBtns.PluginsTB := toolbar
    else
     begin
      MainPlugBtns.PluginsTB := TToolBar.Create(Self);
      MainPlugBtns.PluginsTB.Parent := Self;
      MainPlugBtns.PluginsTB.AutoSize := True;
      MainPlugBtns.PluginsTB.Transparent := False;
      MainPlugBtns.PluginsTB.Wrapable := False;
//      plugBtns.PluginsTB.
     end
   end
  else
    if (not useMainPlugPanel) then
      begin
{       if(MainPlugBtns.PluginsTB <> toolbar) then
        begin
          MainPlugBtns.PluginsTB.Free;
          MainPlugBtns.PluginsTB := toolbar;
        end
}
      end
    else
     begin
      MainPlugBtns.PluginsTB := TToolBar.Create(Self);
      MainPlugBtns.PluginsTB.Parent := Self;
      MainPlugBtns.PluginsTB.AutoSize := True;
      MainPlugBtns.PluginsTB.Transparent := False;
      MainPlugBtns.PluginsTB.Wrapable := False;
//      plugBtns.PluginsTB.
     end
end;
*)

procedure TRnQmain.ReStart(Sender: TObject);
begin
  try
   quitUser;
   if Assigned(statusIcon) then
    begin
     if Assigned(statusIcon.trayIcon) then
       statusIcon.trayIcon.hide;
     statusIcon.empty;
    end;
  except
  end;
  RQUtil.restartApp;
end;


//function TRnQmain.AddMainMenuItem(wPar: WPARAM; lPar: LPARAM): Integer; cdecl;
function TRnQmain.AddContactMenuItem(pMI: PCLISTMENUITEM ): Integer;// cdecl;
{function TRnQmain.AddContactMenuItem(pPluginProc: Pointer; menuIcon: hIcon; menuCaption: String;
              menuHint: string; //procIdx: Integer;
              position: Integer;
              PopupName: String; popupPosition: Integer;
              hotKey: DWORD; PicName: String = ''): integer;}
var
//  clMI: TCLISTMENUITEM;
  Str, Str1: String;
  i: Integer;
  MI: TRQMenuItem;
  PM: TRQMenuItem;
  MM: TMenuItem;
//  Ic: TIcon;
//  bmp: TBitmap;
begin
//  Str := String(wPar);
//  clMI := PCLISTMENUITEM(lPar)^;
  if pMI.cbSize <> SizeOf(TCLISTMENUITEM) then
   begin
     Result := 0;
     Exit;
   end;
//  Str := pMI.pszName;
  MI := TRQMenuItem.Create(self);
  MI.Caption := UnUTF(pMI.pszName);
  MI.Hint := UnUTF(pMI.pszHint);
    if (pMI.hIcon <> 0) then
     begin
      ico2bmp2(pMI.hIcon, MI.Bitmap);
     end;
//  MI.ServiceName := clMI.pszService;
  MI.PluginProc := pMI.Proc;
//  MI.Plugin := pPlugin;
//  MI.ProcIdx := procIdx;
  if pMI.Proc = NIL then
    MI.OnClick := NIL
   else
    MI.OnClick := OnPluginMenuClick;
  MI.ImageName := PMI.pszPic;
  mi.Enabled := (pMI.flags and RQFM_DISABLED)=0;
  mi.Visible := (pMI.flags and RQFM_HIDDEN)=0;
  MM := contactMenu.Items;
  Str := UnUTF(pMI.pszPopupName);
  if str <> '' then
   begin
     str1 := str;
     while Str > '' do
      begin
        i := pos('\',Str);
        if i=0 then
          i := length(Str)+1;
        str1 := copy(Str,1,i-1);
        delete(Str, 1, i+length('\')-1);
       if Assigned(MM.Find(str1)) then
         MM := TMenuItem(MM.Find(str1))
        else
        begin
           PM := TRQMenuItem.Create(contactMenu);
           PM.Caption := str1;
           MM.Add(PM);
           MM := PM;
//           PM.Add(MI);
        end;
      end;
   end;
//  else
//    contactMenu.Items.Insert(12, MI);
  MM.Add(MI);
  result := MI.Handle;
end;

//function TRnQmain.UpdateContactMenuItem(menuHandle: hmenu; pMI: PCLISTMENUITEM ): Integer;// cdecl;
Procedure TRnQmain.UpdateContactMenuItem(menuHandle: hmenu; pMI: PCLISTMENUITEM );// cdecl;
  function findItem(item: TMenuItem): TmenuItem;
  var
    I: Integer;
   begin
     Result := NIL;
     if item.Handle = menuHandle then
       result := item
      else
       if item.Count > 0 then
         for I := 0 to item.Count - 1 do
          begin
//           if item.Items[i].Count > 0 then
            result := findItem(item.Items[i]);
            if Result <> NIL then
             Break;
          end;
   end;
var
  mi: TMenuItem;
begin
  mi := findItem(contactMenu.Items);
  if mi <> NIL then
   begin
     if (pMI.flags and RQFM_UPD_CAPTION)>0 then
       MI.Caption := UnUTF( pMI.pszName );
     if (pMI.flags and RQFM_UPD_HINT)>0 then
       MI.Hint := UnUTF( pMI.pszHint );
     if (pMI.flags and RQFM_UPD_ENABLE)>0 then
       mi.Enabled := (pMI.flags and RQFM_DISABLED)=0;
     if (pMI.flags and RQFM_UPD_VISIBLE)>0 then
       mi.Visible := (pMI.flags and RQFM_HIDDEN)=0;
     if (pMI.flags and RQFM_UPD_ICON)>0 then
      if (pMI.hIcon <> 0) then
        ico2bmp2(pMI.hIcon, MI.Bitmap)
       else
        begin
         mi.Bitmap := NIL;//.Empty := True;
        end;
   end;
//  Result := mi
end;

procedure TRnQmain.DelContactMenuItem(menuHandle: hmenu);
  function findItem(item: TMenuItem): TmenuItem;
  var
    I: Integer;
   begin
     Result := NIL;
     if item.Handle = menuHandle then
       result := item
      else
       if item.Count > 0 then
         for I := 0 to item.Count - 1 do
          begin
//           if item.Items[i].Count > 0 then
            result := findItem(item.Items[i]);
            if Result <> NIL then
             Break;
          end;
   end;
var
  item, parItem: TMenuItem;
begin
  item := findItem(contactMenu.Items);
  if item <> NIL then
   begin
    parItem := item.Parent;
    parItem.Remove(item);
    item.Free;
    while (parItem <> contactMenu.Items)and (parItem.Count = 0)  do
     begin
       item := parItem;
       parItem := item.Parent;
       parItem.Remove(item);
       item.Free;
     end;
   end;
end;

procedure TRnQmain.OnPluginMenuClick(Sender: TObject);
var
//  pr: procedure(uid: String);
  pr: procedure(uid: RawByteString);
begin
  if Sender is TRQMenuItem then
   begin
     if TRQMenuItem(Sender).PluginProc <> NIL then
//      if (TRQMenuItem(Sender).Plugin^) is Tplugin then
      begin
       pr := TRQMenuItem(Sender).PluginProc;
       pr(clickedContact.UID2cmp);
//        Tplugin(TRQMenuItem(Sender).Plugin).cast(
//           char(PM_EVENT)+char(PE_CONTACTMENUCLICK)+_int(TRQMenuItem(Sender).ProcIdx)+_int(StrToIntDef(clickedContact.UID, 0))
//          )
      end;
   end;
end;

end.

