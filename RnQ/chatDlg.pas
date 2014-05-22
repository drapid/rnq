{
This file is part of R&Q.
Under same license
}
unit chatDlg;
{$I RnQConfig.inc}

 {$IFDEF COMPILER_14_UP}
  {$WEAKLINKRTTI ON}
  {$RTTI EXPLICIT METHODS([]) FIELDS([]) PROPERTIES([])}
 {$ENDIF COMPILER_14_UP}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  ComCtrls, StdCtrls, Menus, ExtCtrls, ToolWin, ActnList, RnQButtons,
  VirtualTrees, StrUtils,
  history, historyVCL,
  Commctrl, selectContactsDlg,
  ShockwaveFlashObjects_TLB,
//    FlashPlayerControl,
  RDGlobal,
  {$IFNDEF NOT_USE_GDIPLUS}
    RnQGraphics,
  {$ELSE}
    RnQGraphics32,
//    RnQAni,
  {$ENDIF NOT_USE_GDIPLUS}
//  rnqCtrls,
  RnQProtocol,
  incapsulate, events,
  pluginLib, RQMenuItem, System.Actions;

const
  minimizedScroll=5;
  maximizedScroll=16;
  ClrHistBG = 'history.bg';

type
  TscrollBarEx=class(Tscrollbar)
  protected
    P_entering :boolean;
    procedure CMMouseEnter(var msg: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var msg: TMessage); message CM_MOUSELEAVE;
  public
    onEnter, onLeave:procedure of object;
    property entering:boolean read P_entering;
    end;

  TAvatr = record
      AvtPBox : TPaintBox;
//      Pic  : TRnQBitmap;
      PicAni : TRnQAni;
      swf : TShockwaveFlash;
//      swf : TFlashPlayerControl;
//      swf : TTransparentFlashPlayerControl;
    end;
  TChatType = (CT_IM, CT_PLUGING);

  PChatInfo = ^TchatInfo;
  TchatInfo=class
   public
    ID: integer;
    chatType : TChatType;
//    panelID: Integer;
//    who:Tcontact;
    who: TRnQContact;
    single:boolean;        // single-message
//    whole:boolean;         // see whole history
//    autoscroll:boolean;    // auto scrolls along messages
//    newSession:integer;    // where, in the history, does start new session
//    simpleMsg: Boolean;
    lastInputText:string;  // last input.text before quoting sequence
    quoteIdx:integer;
    wasTyped  : boolean; // input was not clear?
    historyBox: ThistoryBox;
    splitter  : Tsplitter;
    inputPnl  : TPanel;
    input     : TMemo;
    btnPnl    : TPanel;
    avtsplitr : Tsplitter;
    avtPic    : TAvatr;
//    rsb:TscrollBar;
    lsb       : TscrollBarEx;
    constructor create;
    procedure setAutoscroll(v:boolean);
    procedure repaint();
    procedure repaintAndUpdateAutoscroll();
    procedure updateAutoscroll(Sender: TObject);
    procedure updateLSB;
    procedure CheckTypingTime;
   end; // TchatInfo

  Tchats=class(Tlist)
    function validIdx(i:integer):boolean;
    function idxOf(c:TRnQcontact):integer;
    function idxOfUIN(const uin:TUID):integer;
    function byIdx(i:integer):TchatInfo;
    function byContact(c:TRnQcontact):TchatInfo;
    procedure CheckTypingTimeAll;
   end; // Tchats

  TchatFrm = class(TForm)
    pagectrl: TPageControl;
    histmenu: TPopupMenu;
    copylink2clpbd: TMenuItem;
    copy2clpb: TMenuItem;
    selectall1: TMenuItem;
    viewmessageinwindow1: TMenuItem;
    saveas1: TMenuItem;
    html1: TMenuItem;
    txt1: TMenuItem;
    del1: TMenuItem;
    addlink2fav: TMenuItem;
    panel: TPanel;
    sbar: TStatusBar;
    chatshowlsb1: TMenuItem;
    chatpopuplsb1: TMenuItem;
    N1: TMenuItem;
    add2rstr: TMenuItem;
    ActList1: TActionList;
    hAaddtoroaster: TAction;
    hAsaveas: TAction;
    hAdelete: TAction;
    hAchatshowlsb: TAction;
    hAchatpopuplsb: TAction;
    hACopy: TAction;
    hASelectAll: TAction;
    N2: TMenuItem;
    toantispam: TMenuItem;
    sendBtn: TRnQToolButton;
    closeBtn: TRnQToolButton;
    toolbar: TToolBar;
    historyBtn: TRnQSpeedButton;
    findBtn: TRnQSpeedButton;
    smilesBtn: TRnQSpeedButton;
    prefBtn: TRnQSpeedButton;
    autoscrollBtn: TRnQSpeedButton;
    infoBtn: TRnQSpeedButton;
    quoteBtn: TRnQSpeedButton;
    singleBtn: TRnQSpeedButton;
    btnContacts: TRnQSpeedButton;
    RnQPicBtn: TRnQSpeedButton;
    RnQFileBtn: TRnQSpeedButton;
    tb0: TToolBar;
    N3: TMenuItem;
    Openchatwith1: TMenuItem;
    savePicMnu: TMenuItem;
    fp: TBevel;
    caseChk: TCheckBox;
    reChk: TCheckBox;
    directionGrp: TComboBox;
    w2sBox: TEdit;
    SBSearch: TRnQButton;
    CLPanel: TPanel;
    CLSplitter: TSplitter;
    hAViewInfo: TAction;
    ViewinfoM: TMenuItem;
    hAShowSmiles: TAction;
    chtShowSmiles: TMenuItem;
    procedure closemenuPopup(Sender: TObject);
    procedure prefBtnMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure w2sBoxKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure SBSearchClick(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure toantispamClick(Sender: TObject);
    procedure RnQFileBtnClick(Sender: TObject);
    procedure RnQPicBtnClick(Sender: TObject);
    procedure CloseallandAddtoIgnorelist1Click(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure SplitterMoved(Sender: TObject);
    procedure splitterMoving(Sender: TObject; var NewSize: Integer; var Accept: Boolean);
    procedure AvtSplitterMoved(Sender: TObject);
    procedure AvtsplitterMoving(Sender: TObject; var NewSize: Integer; var Accept: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure sendBtnClick(Sender: TObject);
    procedure pagectrl00MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure pagectrlChange(Sender: TObject);
    procedure Close1Click(Sender: TObject);
    procedure Viewinfo1Click(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure selectall1Click(Sender: TObject);
    procedure viewmessageinwindow1Click(Sender: TObject);
    procedure txt1Click(Sender: TObject);
    procedure html1Click(Sender: TObject);
    procedure infoBtnClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure findBtnClick(Sender: TObject);
    procedure quoteBtnClick(Sender: TObject);
    procedure smilesBtnClick(Sender: TObject);
    procedure autoscrollBtnClick(Sender: TObject);
    procedure singleBtnClick(Sender: TObject);
    procedure copylink2clpbdClick(Sender: TObject);
    procedure copy2clpbClick(Sender: TObject);
    procedure btnContactsClick(Sender: TObject);
    procedure chatDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
    procedure chatDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure addlink2favClick(Sender: TObject);
    procedure historyBtnClick(Sender: TObject);
    procedure sbarDrawPanel(StatusBar: TStatusBar; Panel: TStatusPanel; const Rect: TRect);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure sbarMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure Sendwhenimvisibletohimher1Click(Sender: TObject);
    procedure Sendmultiple1Click(Sender: TObject);
    procedure del1Click(Sender: TObject);
    procedure Closeall1Click(Sender: TObject);
    procedure Closeallbutthisone1Click(Sender: TObject);
    procedure CloseallOFFLINEs1Click(Sender: TObject);
    procedure pagectrlChanging(Sender: TObject; var AllowChange: Boolean);
    procedure chatsendmenuopen1Click(Sender: TObject);
    procedure chatcloseignore1Click(Sender: TObject);
    procedure closeBtnClick(Sender: TObject);
    procedure prefBtnClick(Sender: TObject);
  {$IFDEF USE_SMILE_MENU}
    procedure smilesMenuPopup(Sender: TObject);
    procedure smilesMenuClose(Sender: TObject);
  {$ENDIF USE_SMILE_MENU}
    procedure histmenuPopup(Sender: TObject);
    procedure chatshowlsb1Click(Sender: TObject);
    procedure chathide1Click(Sender: TObject);
    procedure chatpopuplsb1Click(Sender: TObject);
    procedure FormMouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure FormMouseWheelDown(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure pagectrl00MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure pagectrlDrawTab(Control: TCustomTabControl;
      TabIndex: Integer; const Rect: TRect; Active: Boolean);
    procedure ANothingExecute(Sender: TObject);
    procedure hAchatshowlsbUpdate(Sender: TObject);
    procedure hAchatpopuplsbUpdate(Sender: TObject);
    procedure pagectrlDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure pagectrlMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure pagectrlDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure savePicMnuClick(Sender: TObject);
    procedure pagectrlMouseLeave(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure CLPanelDockDrop(Sender: TObject; Source: TDragDockObject; X,
      Y: Integer);
    procedure CLPanelDockOver(Sender: TObject; Source: TDragDockObject; X,
      Y: Integer; State: TDragState; var Accept: Boolean);
    procedure CLPanelUnDock(Sender: TObject; Client: TControl;
      NewTarget: TWinControl; var Allow: Boolean);
    procedure quoteBtnMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure findBtnMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure smilesBtnMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure hAViewInfoExecute(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
 {$IFDEF USE_SECUREIM}
    procedure EncryptSendInit(Sender: TObject);
 {$ENDIF USE_SECUREIM}
    procedure EncryptSetPWD(Sender: TObject);
    procedure EncryptClearPWD(Sender: TObject);
    procedure hAShowSmilesUpdate(Sender: TObject);
    procedure hAShowSmilesExecute(Sender: TObject);
    procedure sbarDblClick(Sender: TObject);
  {$IFDEF usesDC}
    procedure WMDROPFILES(var Message: TWMDROPFILES);  message WM_DROPFILES;
  {$ENDIF usesDC}
  protected
    procedure WndProc(var Message: TMessage); override;
//    procedure StartWheelPanning(Position: TPoint); virtual;
//    procedure StopWheelPanning; virtual;
//    procedure CNVScroll(var Message: TWMVScroll); message CN_VSCROLL;
    procedure WMEXITSIZEMOVE(var Message: TMessage);
         message WM_EXITSIZEMOVE;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure ShowTabHint(X, Y: integer);
//    procedure WMEraseBkgnd(var Msg: TWmEraseBkgnd); message WM_ERASEBKGND;

    procedure historyAllShowChange(ch : TchatInfo; histBtnDown : Boolean);
    procedure WMWINDOWPOSCHANGING(Var Msg: TWMWINDOWPOSCHANGING);
             message WM_WINDOWPOSCHANGING;
//    procedure showSmilePanel(p : TPoint);
  private
    lastClick   : Tdatetime;
    lastClickIdx : Integer;
//    lastContact : Tcontact;
    lastContact : TRnQContact;
  //окно хинта для отображения на закладках окна чата
//  hintwnd: TVirtualTreeHintWindow = nil;
	hintwnd: TVirtualTreeHintWindow;
  //будем запоминать параметры хинта, чтобы не создавать несколько раз один и тот же хинт
   LastMousePos: TPoint;
//	hintTab: Integer;
   last_tabindex : integer;
   FAniTimer : TTimer;
    PagesEnumStr : RawByteString;
    procedure TickAniTimer(Sender: TObject);
//    procedure checkGifTime;
//    tZers : TShockwaveFlash;
//    procedure process_tZers(ASender: TObject; percentDone: Integer);
//    procedure state_tZers(ASender: TObject; newState: Integer);
//    procedure BooButton1Click(Sender: TObject);
    procedure inputChange(Sender: TObject);
    procedure inputPopup(sender:Tobject; MousePos: TPoint; var Handled:Boolean);
    procedure inputKeydown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure onHistoryRepaint(sender:TObject);
    procedure searchFrom(const start:integer);
  public
    chats        : Tchats;
    poppedup     : Tpoint;
    selectedUIN  : TUID;
    plugBtns     : TPlugButtons;
    sendMenuExt  : TPopupMenu;
    closeMenuExt : TPopupMenu;
 { $IFDEF USE_SECUREIM}
    EncryptMenyExt : TPopupMenu;
 { $ENDIF USE_SECUREIM}
    enterCount   : integer;
  {$IFDEF USE_SMILE_MENU}
    smile_theme_token : Integer;
    smileMenuExt : TRnQPopupMenu;
  {$ENDIF USE_SMILE_MENU}
    MainFormWidth : Integer;
//    favMenuExt   : TPopupMenu;

    procedure SetSmilePopup(pIsMenu : Boolean);
    procedure UpdatePluginPanel;
    function  isChatOpen(otherHand:TRnQContact):boolean;
    function  openchat(otherHand:TRnQContact; ForceActive : Boolean = false;
                       isAuto : Boolean = false):boolean;
    function  addEvent_openchat(otherhand:TRnQcontact; ev:Thevent):boolean; // opens chat if not already open
//    function  addEvent(uin:TUID; ev:Thevent):boolean; overload;// tells if ev has been inserted in a list, or can be freed
    function  addEvent(c:TRnQcontact; ev:Thevent):boolean; overload; // tells if ev has been inserted in a list, or can be freed
    procedure openOn(c:TRnQContact; focus:boolean=TRUE; pShow : Boolean = True);
//    procedure openOn(uid : TUID; focus:boolean=TRUE);
    procedure open(focus:boolean=TRUE);
    function  newIMchannel(c:TRnQContact):integer;
    function  thisChat:TchatInfo;
    function  thisChatUID:TUID;
    procedure setTab(idx:integer);
    procedure userChanged(c:TRnQContact);
    procedure redrawTab(c:TRnQcontact);
    function  pageIndex:integer;
    procedure closeThisPage;
    procedure closeAllPages(isAuto : Boolean = false);
    procedure closePageAt(idx:integer);
    procedure closeChatWith(c:TRnQContact);
    function  sawAllhere:boolean;
    function  isVisible:boolean;
    procedure applyFormXY;
    procedure lsbScroll(Sender: TObject; ScrollCode: TScrollCode; var ScrollPos: Integer);
    procedure lsbEnter;
    procedure updateContactStatus;
    procedure quote(qs : String = ''; MakeCarret : Boolean = True);
    function  pageIdxAt(x,y:integer):integer;
    procedure setCaptionFor(c:TRnQcontact);
    procedure setCaption(idx : Integer);
    procedure updateChatfrmXY;
    procedure setStatusbar(s:string);
    function  moveToTime(c:TRnQContact; time:Tdatetime; NeedOpen : Boolean = True) : boolean;
    function  moveToTimeOrEnd(c:TRnQcontact; time:Tdatetime; NeedOpen : Boolean = True) : boolean;
    procedure sendMessageAction(sender:Tobject);
    procedure send; overload;
    procedure send(flags_:integer; msg:string=''); overload;
    procedure select(c:TRnQContact);
    function  thisContact:TRnQContact;
    procedure flash;
    function  grabThisText:string;
    function  Pages2String : RawByteString;
//    procedure savePages;
    procedure loadPages(const s : RawByteString);
    procedure updateGraphics;
    procedure addSmileAction(sender:Tobject);
    procedure setLeftSB(visible:boolean);
    procedure addcontactAction(sender:Tobject);
    procedure AvtPBoxPaint(Sender: TObject);
  end; // TchatFrm

  function  CHAT_TAB_ADD(Control: Integer; iIcon : HIcon; const TabCaption: string): Integer;
  procedure CHAT_TAB_MODIFY(Control: Integer; iIcon : HIcon; const TabCaption: string);
  procedure CHAT_TAB_DELETE(Control: Integer);

var
  chatFrm: TchatFrm;


implementation

uses
  Clipbrd, ShellAPI, Themes,
  math, Types,
  Base64,
  RDFileUtil, RQUtil, RDUtils, RnQSysUtils,
  globalLib, viewInfoDlg, //searchhistDlg,
  outboxlib, utilLib, outboxDlg, RnQTips, RnQPics,
  langLib, roasterLib,
 {$IFNDEF DB_ENABLED}
//    RegExpr,
    RegularExpressions,
 {$ENDIF ~DB_ENABLED}
//  prefDlg,
 {$IFDEF RNQ_AVATARS}
  RnQ_Avatars, UxTheme,
 {$ENDIF}
  Protocols_all,
 {$IFDEF PROTOCOL_ICQ}
   Protocol_ICQ, ICQv9, ICQConsts, ICQContacts, RQ_ICQ,
 {$ENDIF PROTOCOL_ICQ}
  RQThemes, themesLib,
 {$IFDEF USE_SECUREIM}
  cryptoppWrap,
 {$ENDIF USE_SECUREIM}
 {$IFDEF UNICODE}
   AnsiStrings,
   Character,
 {$ENDIF UNICODE}
  RnQMenu, RnQLangs, RnQDialogs, menusUnit, RnQGlobal,
  MenuSmiles, mainDlg;
 {$IFDEF SEND_FILE}
  uses
    RnQ_FAM;
 {$ENDIF}

{$R *.DFM}

procedure TscrollbarEx.CMMouseEnter(var msg: TMessage);
begin
P_entering:=TRUE;
if assigned(onEnter) then onEnter
end;

procedure TscrollbarEx.CMMouseLeave(var msg: TMessage);
begin
P_entering:=FALSE;
if assigned(onLeave) then onLeave
end;

constructor TchatInfo.create;
begin
  inherited;
  quoteIdx:=-1;
end;

procedure Tchatinfo.setAutoscroll(v:boolean);
begin
  chatfrm.autoscrollBtn.down:=v;
//  historyBox.autoscroll:=v;
//  historyBox.setAutoScrollForce(v);
  historyBox.autoScrollVal := v;
end;

procedure Tchatinfo.repaint();
begin
  if not Assigned(self) then
    Exit;

  if chatType = CT_IM then
  begin
//    if historyBox.autoscroll then historyBox.go2end
//     else
      if chatFrm.visible {and not IsIconic(chatFrm.handle)} then
        begin
//          needRepaint:= False;
          historyBox.repaint;
        end
//       else
//         needRepaint:= True;
  end;
end;

procedure Tchatinfo.repaintAndUpdateAutoscroll();
begin
  repaint;
  updateAutoscroll(historyBox)
end;

/////////////////////////// Tchats /////////////////////////////////

    {$WARN UNSAFE_CAST OFF}
function Tchats.idxOfUIN(const uin: TUID):integer;
begin
result:=0;
while result<count do
  begin
    if TchatInfo(items[result]).chatType = CT_IM then
     if TchatInfo(items[result]).who.equals(uin) then
      exit;
  inc(result);
  end;
result:=-1;
end; // idxOfUIN

function Tchats.idxOf(c:TRnQcontact):integer;
begin
result:=0;
while result<count do
  begin
   if TchatInfo(items[result]).chatType = CT_IM then
    if TchatInfo(items[result]).who.equals(c) then
    exit;
  inc(result);
  end;
result:=-1;
end; // idxOf

function Tchats.byIdx(i:integer):TchatInfo;
begin
result:=NIL;
if validIdx(i) then
  result:=TchatInfo(items[i])
end; // byIdx
    {$WARN UNSAFE_CAST ON}

function Tchats.byContact(c:TRnQcontact):TchatInfo;
begin result:=byIdx(idxOf(c)) end;

function Tchats.validIdx(i:integer):boolean;
begin result:=(i >= 0) and (i < count) end;

procedure Tchats.CheckTypingTimeAll;
var
  i : Integer;
begin
  if Assigned(Account.AccProto) then

  if (Account.AccProto.SupportTypingNotif)and(Account.AccProto.isSendTypingNotif) then
   if count > 0 then
    for i:= count-1 downto 0 do
     if TchatInfo(items[i]).chatType = CT_IM then
       if Assigned(TchatInfo(items[i]).who) then
         TchatInfo(items[i]).CheckTypingTime;
end;

/////////////////////////////////////////////////////////////////

procedure TchatFrm.FormResize(Sender: TObject);
var
  ch:TchatInfo;
begin
 if (w2sBox.Left + w2sBox.Width + 6) > directionGrp.Left then
   w2sBox.Width := Max(directionGrp.Left - w2sBox.Left - 6, 10);

 updateChatfrmXY;
 ch:=thisChat;
 if ch = NIL then exit;
 if ch.chatType = CT_PLUGING then
    plugins.castEv(PE_SELECTTAB, ch.id)
 else
 begin
   if Assigned(ch.inputPnl) then
    begin
     if (ch.inputPnl.height > pagectrl.ActivePage.ClientHeight)
       and (ch.inputPnl.height > 32) then
      ch.inputPnl.height := pagectrl.ActivePage.ClientHeight - 30
    end
   else
    if (ch.input.height > pagectrl.ActivePage.ClientHeight)
      and (ch.input.height > 32) then
     ch.input.height := pagectrl.ActivePage.ClientHeight - 30;
//   updatea
   ch.repaint;//AndUpdateAutoscroll();
//   ch.repaintAndUpdateAutoscroll();
 end;
end; // formResize

function TchatFrm.addEvent_openchat(otherhand:TRnQcontact; ev:Thevent):boolean;
begin
openchat(otherHand);
result:=addEvent(otherhand, ev);
end; // addEvent_openchat

{function TchatFrm.addEvent(uin: TUID; ev:Thevent):boolean;
var
  i:integer;
  ch : TchatInfo;
begin
  result:=FALSE;
  i:=chats.idxOfUIN(uin);
  ch:=chats.byIdx(i);
  if ch=NIL then
   ev.free
  else
   begin
    result:=TRUE;
    ch.historyBox.history.add(ev);
    if i = pageIndex then
      ch.repaint();
//    ch.repaintAndUpdateAutoscroll();
   end
end; // addEvent }
function TchatFrm.addEvent(c:TRnQcontact; ev:Thevent):boolean; // tells if ev has been inserted in a list, or can be freed
var
  i : integer;
  ch: TchatInfo;
begin
  result:=FALSE;
  i:=chats.idxOf(c);
  ch:=chats.byIdx(i);
  if ch=NIL then
   ev.free
  else
   begin
    result:=TRUE;
    ch.historyBox.addEvent(ev);
{    if i = pageIndex then
      ch.repaint();
}
//    ch.repaintAndUpdateAutoscroll();
   end
end; // addEvent

function TchatFrm.pageIndex:integer;
begin
if pageCtrl.activePage=NIL then
  result:=-1
else
  result:=pageCtrl.activePage.pageIndex
end;

// pageIndex

function TchatFrm.openchat(otherHand:TRnQContact; ForceActive : Boolean = false;
                           isAuto : Boolean = false):boolean;
const
  MaxNILpages = 101;
var
  i, k : integer;
  wasEmpty,alreadyThere:boolean;
  cnt : TRnQContact;
  firstNILpage, NILcount : Integer;
begin
wasEmpty:= pageCtrl.pageCount=0;
i:=chats.idxOf(otherHand);
alreadyThere:= i=pageIndex;
result:=i<0;
if result then
  i:=newIMchannel(otherHand);
if wasEmpty then
  begin
    setTab(i);
    if docking.Docked2chat then
      applyDocking;
  end
else
  begin
    if not alreadyThere then
     begin
      if ForceActive then
       begin
        pageCtrl.activePageIndex := i;
        pageCtrlChange(self);
       end;
     end;
    if isAuto then
    begin // protection against bruteforce
      firstNILpage := -1;
      NILcount := 0;
      for k := 0 to chats.Count-1 do
       begin
         if chats.byIdx(k).chatType = CT_IM then
          begin
           cnt := chats.byIdx(k).who;
           if Assigned(cnt) and notInList.exists(cnt) then
             begin
               inc(NILcount);
               if firstNILpage <0 then
                 firstNILpage := k;
             end;
          end;
       end;
       if (firstNILpage >= 0) and (NILcount > MaxNILpages) then
         closePageAt(firstNILpage);
    end;
  end;
 if ForceActive and not Visible then
  Visible := True;
end;

// openchat

function TchatFrm.isChatOpen(otherHand:TRnQcontact):boolean;
begin result:=chats.idxOf(otherHand) >= 0 end;

procedure TchatFrm.applyFormXY;
begin
with chatfrmXY do
  if width > 0 then
    begin
    if maximized then
      begin
        SetBounds(left,top,width,height);
        windowState:=wsMaximized;
      end
    else
      begin
      SetBounds(left,top,width,height);
      windowState:=wsNormal
      end;
  end;
end; // applyFormXY

procedure TchatFrm.FormCreate(Sender: TObject);
begin
  chats:=Tchats.create;
  plugBtns := TPlugButtons.Create;
  InitMenuChats;
  createMenuAs(aSendMenu, sendMenuExt, self);
  createMenuAs(aCloseMenu, closeMenuExt, self);
 {$IFDEF USE_SECUREIM}
  if useSecureIM then
    createMenuAs(aEncryptMenu, EncryptMenyExt, self);
 {$ENDIF USE_SECUREIM}
  createMenuAs(aEncryptMenu2, EncryptMenyExt, self);

  sendBtn.DropdownMenu  := sendMenuExt;
  closeBtn.DropdownMenu := closeMenuExt;
   {$IFDEF USE_SMILE_MENU}
  smileMenuExt := TRnQPopupMenu.Create(self);
  smileMenuExt.OnPopup := smilesMenuPopup;
  smileMenuExt.OnClose := smilesMenuClose;
//  smilesBtn.PopupMenu := smileMenuExt;
  if Assigned(FSmiles) then
    SetSmilePopup(False)
   else
   {$ENDIF USE_SMILE_MENU}
    SetSmilePopup(True);
//  favMenuExt := TPopupMenu.Create(self);
//  favMenuExt.OnPopup  := favMenuPopup;

  plugBtns.PluginsTB := NIL;
  plugBtns.btnCnt    := 0;
  hintwnd := nil;
  last_tabindex := -1;

  FAniTimer:= TTimer.Create(nil);
  FAniTimer.Enabled := false;
  FAniTimer.Interval:= 40;
  //timer.Enabled:= UseAnime;
  FAniTimer.OnTimer:= TickAniTimer;

//  DoubleBuffered := True;
  sbar.DoubleBuffered := ThemeServices.ThemesEnabled;
//  pagectrl.t
  DragAcceptFiles(self.handle, True);
 applyFormXY;
 applyTaskButton(self);
end;

procedure TchatFrm.setTab(idx:integer);
var
  bool:boolean;
begin
if assigned(pageCtrl.Onchanging) then
  begin
  bool:=TRUE;
  pageCtrl.OnChanging(self, bool);
  if bool=false then
    exit;
  end;
with pageCtrl do
  if idx < pageCount then
    activePage:=pages[idx]
  else
    msgDlg('Error: bad page', True, mtError);  // should never reach this
if assigned(pageCtrl.onChange) then
  pageCtrl.onChange(self);
end; // setTab

procedure TchatFrm.userChanged(c:TRnQContact);
var
  i:integer;
  ch:TchatInfo;
begin
  if c = NIL then Exit;
  ch:=thisChat;
  if (ch=NIL) then exit;
  if c.fProto.isMyAcc(c) then
   begin
    ch.repaint();
//  ch.repaintAndUpdateAutoscroll();
//  exit;
   end;
i:=chats.idxOf(c);
if i < 0 then exit;
setCaptionFor(c);
redrawTab(c);
updateContactStatus;
if i = pageIndex then
  ch.repaint();
//  ch.repaintAndUpdateAutoscroll();
end; // userChanged

procedure TchatFrm.openOn(c:TRnQContact; focus:boolean=TRUE; pShow : Boolean = True);
var
  i:integer;
  wasEmpty:boolean;
begin
  if c=NIL then exit;
  wasEmpty:= pageCtrl.pageCount=0;
  i:=chats.idxOf(c);
  if i < 0 then
    i:=newIMchannel(c);
  setTab(i);
  if wasEmpty then
   if docking.Docked2chat then
    applyDocking;
  if pShow then
    open(focus);
end; // openOn

{procedure TchatFrm.openOn(uid:TUID; focus:boolean=TRUE);
var
  i:integer;
  cnt : Tcontact;
begin
 cnt := contactsDB.get(uid);
if cnt=NIL then exit;
i:=chats.idxOf(cnt);
if i < 0 then
  i:=newIMchannel(cnt);
setTab(i);
open(focus);
end; // openOn}

function TchatFrm.newIMchannel(c:TRnQContact):integer;
var
  sheet:TtabSheet;
  chat:TchatInfo;
  pnl:Tpanel;
begin
 {$IFDEF RNQ_FULL}
//  rqSmiles.ClearAniParams;
  theme.ClearAniParams;
 {$ENDIF RNQ_FULL}
chat := TchatInfo.create;
chat.who := c;
//chat.who := c;
chat.chatType := CT_IM;
chat.single:=singleDefault;
chat.who.typing.bIAmTyping := False;
//if not assigned(pTCE(c.data).history0) then
//  pTCE(c.data).history0:=Thistory.create;

sheet:=TtabSheet.create(self);
chats.Add(chat);
sheet.PageControl:=pageCtrl;
result:=sheet.pageIndex;
setCaption(Result);
sheet.ControlStyle := sheet.ControlStyle + [csOpaque]; 
//setCaptionFor(c);

//sheet.ShowHint := True;
//sheet.Hint := c.display;

pnl:=Tpanel.create(self);
pnl.parent:=sheet;
pnl.align:=alClient;
pnl.BevelInner:=bvNone;
pnl.BevelOuter:=bvNone;
pnl.BorderStyle:=bsSingle;

  chat.historyBox:=ThistoryBox.create(pnl);
  with chat.historyBox do
  begin
   chat.historyBox.Parent := pnl;
   who:=c;
   color:=theme.getColor(ClrHistBG, clWindow);//history.bgcolor;
//   history:=pTCE(c.data).history as Thistory;
   history := Thistory.create;
//   history.Token := 101;
   history.Reset;
   align:=alClient;
   Realign;
   onDragOver:=chatDragOver;
   onDragDrop:=chatDragDrop;
   onPainted:=onHistoryRepaint;
   OnScroll := chat.updateAutoscroll;
  end;

chat.lsb:=TscrollbarEx.create(pnl);
with chat.lsb do
  begin
  parent:=pnl;
  align:=alLeft;
  tabStop:=FALSE;
  onScroll:=lsbScroll;
  onEnter:=lsbEnter;
  onLeave:=lsbEnter;
  Kind:=sbVertical;
  position:=0;
  min:=0;
  max:=0;
  if popupLSB then
    width:=minimizedScroll
  else
    width:=maximizedScroll;
  smallChange:=1;
  largeChange:=5;
  enabled:=FALSE;
  visible:=showLSB;
  hint:=getTranslation('Scrolls the message line by line');
  end;

 {$IFDEF RNQ_FULL}
//  rqSmiles.ClearAniParams;
  theme.ClearAniParams;
 {$ENDIF RNQ_FULL}
//pnl.insertControl(chat.historyBox);


 chat.avtPic.swf := NIL;
 chat.avtPic.PicAni := NIL;
 chat.avtPic.AvtPBox := NIL;
 chat.avtsplitr := NIL;

 if avatarShowInChat then
   begin
    chat.inputPnl := TPanel.create(self);
    chat.inputPnl.parent:=sheet;
    chat.inputPnl.align:=alBottom;
    chat.inputPnl.BorderWidth := 0;
//  chat.inputPnl.BorderStyle := bsNone;
    chat.inputPnl.BevelOuter := bvNone;
    chat.inputPnl.BevelKind := bkNone;
//  chat.inputPnl.BevelKind := bkNone;
///  chat.inputPnl.BevelWidth := 0;

    chat.input := Tmemo.create(chat.inputPnl);
    chat.input.parent := chat.inputPnl;
    chat.input.align  := alClient;
//    sheet.ControlStyle := sheet.ControlStyle + [csOpaque];
//    chat.inputPnl.ControlStyle := chat.inputPnl.ControlStyle + [csOpaque];
    chat.inputPnl.FullRepaint := False;
//    chat.inputPnl.DoubleBuffered := True;
    if splitY > 0 then
      chat.inputPnl.height:=splitY
     else
      chat.inputPnl.height:=50;
  //  chat.avtsplitr.cursor:=crVsplit;
  //  chat.avtsplitr.onMoved:=splitterMoved;
  //  chat.avtsplitr.OnCanResize:=splitterMoving;
   end
  else
   begin
    chat.inputPnl := NIL;
    chat.input := Tmemo.create(sheet);
    chat.input.parent:= sheet;
    chat.input.align := alBottom;
    if splitY > 0 then
      chat.input.height:=splitY
     else
      chat.input.height:=50;
   end;

  chat.input.WordWrap:=TRUE;
   theme.ApplyFont('history.my', chat.input.Font);
  chat.input.ScrollBars:=ssVertical;
  chat.input.onChange:=inputChange;
  chat.input.OnContextPopup:=inputPopup;
  chat.input.onKeyDown  := inputKeydown;
  chat.input.onDragOver := chatDragOver;
  chat.input.onDragDrop := chatDragDrop;
{  if theme.GetPicSize( PIC_CHAT_BG+'5').cx > 0 then
   begin
    if not Assigned(chat.input.Brush.Bitmap) then
      chat.input.Brush.Bitmap := TBitmap.Create;
//   chat.input.Brush.Handle := theme.GetBrush(PIC_CHAT_BG+'5')
    theme.GetPic(PIC_CHAT_BG+'5', chat.input.Brush.Bitmap, false);
   end
  else}
   chat.input.color := theme.getColor(ClrHistBG, clWindow);//history.bgcolor;

  chat.splitter:=Tsplitter.create(self);
  //chat.splitter.ResizeStyle:=rsUpdate;
  chat.splitter.minsize:=1;
  chat.splitter.parent:=sheet;
  chat.splitter.align:=alBottom;
  chat.splitter.cursor:=crVsplit;
  chat.splitter.onMoved:=splitterMoved;
  chat.splitter.OnCanResize:=splitterMoving;

  if usePlugPanel and (plugBtns.PluginsTB <> toolbar) then
  begin
    chat.btnPnl := TPanel.Create(self);
  //  chat.btnPnl.minsize:=1;
    chat.btnPnl.parent := pnl;
    chat.btnPnl.align  := alBottom;
    chat.btnPnl.Height := 24;
    chat.btnPnl.BorderWidth := 0;
    chat.btnPnl.FullRepaint := False;
//  chat.inputPnl.BorderStyle := bsNone;
    chat.btnPnl.BevelOuter := bvLowered;
    chat.btnPnl.BevelKind := bkNone;
    if Assigned(chat.btnPnl) then
     if Assigned(plugBtns) then
      chat.btnPnl.Visible := plugBtns.btnCnt > 0
     else
      chat.btnPnl.Visible := false;
  //  chat.btnPnl.cursor:=crVsplit;
  end;

   {$IFDEF RNQ_AVATARS}
  updateAvatarFor(c);
   {$ENDIF RNQ_AVATARS}
{  chat.avtPic := TImage.create(self);
  chat.avtPic.parent := chat.inputPnl;
  chat.avtPic.align  := alRight;
  if Assigned(c.icon) then
   begin
    chat.avtPic.Width := c.icon.Width + 5;
    chat.avtPic.Picture.Assign(c.icon);
//    chat.avtPic.Picture.Bitmap.TransparentMode := tmAuto;
//    chat.avtPic.Picture.Bitmap.Transparent := True;
    chat.avtPic.Transparent := c.icon.Transparent;
   end
  else
    chat.avtPic.Width := 0;
}
  chat.historyBox.realign;
  resize;
//  savePages;
  saveListsDelayed := True;
 {$IFDEF RNQ_FULL}
//  rqSmiles.ClearAniParams;
  theme.ClearAniParams;
 {$ENDIF RNQ_FULL}
  chat.historyBox.updateRSB(false);
end; // newIMchannel

procedure TchatFrm.lsbScroll(Sender: TObject; ScrollCode: TScrollCode; var ScrollPos: Integer);
var
  ch:TchatInfo;
begin
 with sender as Tscrollbar do
 begin
  if position = scrollpos then
    exit;
  ch:=thisChat;
  if ch=NIL then exit;
  ch.historyBox.topOfs:=scrollpos;
  if ScrollPos > 0 then
    hideScrollTimer:=0;
  ch.historyBox.repaint();
  ch.updateAutoscroll(nil);
 end;
end; // lsbScroll

procedure Tchatinfo.updateLSB;
begin
//if ch=NIL then exit;
if (historyBox.topEventNrows<2) then
 begin
   lsb.enabled:=FALSE;
   if popupLSB then
     lsb.width :=minimizedScroll;
//   updateAutoscroll(nil);
 end
else
  begin
  lsb.min:=0;
  lsb.max:=historyBox.topEventNrows-1;
  lsb.pagesize:=1;
  if lsb.position <> historyBox.topOfs then
    lsb.position:=historyBox.topOfs;

  if lsb.Position > 0 then
    lsb.width := maximizedScroll
   else
    if not lsb.MouseInClient then
      hideScrollTimer := 10;
//  if lsb.Position = 0 then
    lsb.enabled:=TRUE;
  end;
end; // updateLSB

procedure Tchatinfo.CheckTypingTime;
begin
 try
  if (chatType = CT_IM)and Assigned(who) then
   if (who.typing.bIamTyping) and ((now - who.typing.typingTime)*SecsPerDay > typingInterval) then
    who.fProto.InputChangedFor(who, false, True);
 except
 end;
end;


function TchatFrm.thisChat:TchatInfo;
begin
  if (chats.count = 0)or (not Assigned(pageCtrl.ActivePage)) then
    result:=NIL
   else
    result:=chats.byIdx(pageCtrl.ActivePage.pageIndex)
end;

function TchatFrm.thisContact:TRnQcontact;
var
  ch : TchatInfo;
begin
  ch := thisChat;
 if ch=NIL then
   result:=NIL
  else
   if ch.chatType = CT_IM then
     thisContact:= ch.who
    else
     result:=NIL;
end; // thisContact


function TchatFrm.thisChatUID:TUID;
var
  cnt : TRnQContact;
begin
  cnt := thisContact;

  if (cnt <> NIL) then
    Result := cnt.UID2cmp
   else
    Result := '';
end;

procedure TchatFrm.sendBtnClick(Sender: TObject);
begin send end;

function TchatFrm.pageIdxAt(x,y:integer):integer;
var
  R:Trect;
begin
result:=0;
while result < chats.count do
  begin
  SendMessage(pagectrl.Handle, TCM_GETITEMRECT, result, Longint(@R));
  if ptInRect(R, point(x,y)) then
    exit;
  inc(result);
  end;
result:=-1;
end; // pageIdxAt

procedure TchatFrm.pagectrl00MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  diff:TdateTime;
  i:integer;
  ev:Thevent;
  b:boolean;
begin
  case button of
   mbRight:
    begin
    i:=pageIdxAt(x,y);
    if i < 0 then exit;
    if i <> pageIndex then
    	begin
      b:=TRUE;
      pagectrlChanging(sender, b);
      if b then
      	begin
	      pagectrl.ActivePage:=pagectrl.Pages[i];
	      pagectrlChange(sender);
        end;
      end;
    end;
   mbLeft:
    begin
     i:=pageIdxAt(x,y);
     if i = lastClickIdx then
       diff:=now-lastClick
      else
       diff := dblClickTime +1;
     lastClick:=now;
     lastClickIdx := i;
     if diff < dblClickTime then
      begin
      ev:=eventQ.firstEventFor(thisContact);
      if ev<>NIL then
        begin
//          realizeEvents(ev.kind, ev.who);
//         eventQ.removeEvent(ev.kind, ev.who);
         eventQ.remove(ev);
         realizeEvent(ev);
        end
      else
        closeThisPage;
      end;
     pagectrl.BeginDrag(False);
    end;
   mbMiddle:
    begin
      i:=pageIdxAt(x,y);
      if i < 0 then exit;
      if i = pageIndex then
        closeThisPage
      else
       try
        closePageAt(i);
       except
       end;
    end;
  end;
end; // pagectrl mousedown

procedure TchatFrm.closeThisPage;
Var
  ClosePgIdx : Integer;
begin
 if (pageCtrl.activePage = NIL) or (thisChat = NIL) then exit;
 ClosePgIdx := pageCtrl.activePage.TabIndex;
 pagectrl.SelectNextPage(True);
 closePageAt(ClosePgIdx);
end;

procedure TchatFrm.CLPanelDockDrop(Sender: TObject; Source: TDragDockObject; X,
  Y: Integer);
//var
// a : Integer;
begin
//  a := chatFrm.Width;
//  CLPanel.Align := alRight;
//  ChatPnl.Align := alClient;
//  Splitter1.Align := alRight;
  if Source.Control is TRnQmain then
   CLPanel.Width := max(MainFormWidth+2, 42);
  docking.Docked2chat := True;
  docking.active := False;
  mainfrmHandleUpdate;
//  chatFrm.Width := a + 202;
end;

procedure TchatFrm.CLPanelDockOver(Sender: TObject; Source: TDragDockObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
begin
  Accept := Source.Control = MainDlg.RnQmain;
  MainFormWidth := MainDlg.RnQmain.Width;
end;

procedure TchatFrm.CLPanelUnDock(Sender: TObject; Client: TControl;
  NewTarget: TWinControl; var Allow: Boolean);
//var
// a : Integer;
begin
//{  a := CLPanel.Width;
 Allow := True;
 CLPanel.Width := 2;
 if pagectrl.PageCount > 0 then
  docking.Docked2chat := False;
// mainfrmHandleUpdate;
{  CLPanel.Align := alClient;
  ChatPnl.Align := alLeft;
  Splitter1.Align := alLeft;
  if Sender is TPanel then
   TPanel(Sender).Width := 1;
  MainDlg.RnQmain.Width := a + 2;}
end;

// closeThisPage

procedure TchatFrm.updateGraphics;
var
  ch:Tchatinfo;
  i:integer;
begin
  ch:=thisChat;
  if ch=NIL then exit;
  if ch.chatType = CT_PLUGING then Exit;
theme.applyFont('history.my', ch.input.Font);
smilesBtn.down:=useSmiles;
historyBtn.down:=ch.historyBox.whole;
singleBtn.down:=ch.single;
autoscrollBtn.down:=ch.historyBox.autoScrollVal;
//SimplMsgBtn.Down := ch.simpleMsg;
updateContactStatus;
ch.input.color:=theme.getColor(ClrHistBG, clWindow);
 if Assigned(ch.btnPnl) then
  if Assigned(plugBtns) then
    ch.btnPnl.Visible := plugBtns.btnCnt > 0
  else
    ch.btnPnl.Visible := false;
//sbar.panels[0].Width:=80;
 with theme.getPicSize(RQteDefault, PIC_OUTBOX, 16) do
  begin
    sbar.panels[1].Width:=cx+8;
    i:=cy+6;
  end;
 with theme.getPicSize(RQteDefault, PIC_KEY, 16) do
  begin
    sbar.panels[3].Width:=cx+8;
    i:=max(i, cy+6);
  end;
 with theme.getPicSize(RQteDefault, PIC_CLI_QIP, 16) do
  begin
    sbar.panels[3].Width := sbar.panels[3].Width+ cx+3;
    i:=max(i, cy+6);
  end;
 sbar.Height := boundInt(i,22,50);
 sbar.repaint;
 if popupLSB then
   if ch.lsb.Enabled and (ch.lsb.Position > ch.lsb.Min) then
     ch.lsb.width:=maximizedScroll
    else
     ch.lsb.width:=minimizedScroll
  else
   ch.lsb.width:=maximizedScroll;
 ch.historyBox.color:=ch.input.color;
 if chatFrm.visible and not IsIconic(chatFrm.handle) then
  ch.historyBox.repaint;
 panel.Realign;
 panel.repaint;

  i := 21;
  with theme.GetPicSize(RQteButton, status2imgName(byte(SC_ONLINE)), icon_size) do
  begin
    i:=max(i, cy+6);
  end;
  with theme.GetPicSize(RQteButton, PIC_CLOSE, icon_size) do
  begin
    i:=max(i, cy+6);
  end;
  toolbar.Height := i+2;
  toolbar.ButtonHeight := i;
  toolbar.Top:=(panel.ClientHeight - toolbar.Height) div 2;
  SendBtn.Height := i;
  closeBtn.Height := i;
  SendBtn.Top:=(panel.ClientHeight - SendBtn.Height) div 2;
  closeBtn.Top:=(panel.ClientHeight - closeBtn.Height) div 2;
end; // updateGraphics

procedure TchatFrm.pagectrlChanging(Sender: TObject; var AllowChange: Boolean);
begin
  with thisChat do
   begin
    lastContact := who;
    if chatType = CT_PLUGING then
      plugins.castEv(PE_DESELECTTAB, id);
    if Assigned(who) then
      pTCE(who.data).keylay:=GetKeyboardLayout(0)
   end;
end;

procedure TchatFrm.pagectrlChange(Sender: TObject);
var
  ch:TchatInfo;
  I: Integer;
begin
 {$IFDEF RNQ_FULL}
//  rqSmiles.ClearAniParams;
  theme.ClearAniParams;
 {$ENDIF RNQ_FULL}
 ch:=thisChat;
 if ch=NIL then exit;
 if ch.chatType = CT_IM then
 begin
  lastClick:=0;
  inputChange(self);    // update char counter
  setLeftSB(showLSB);
  if autoSwitchKL
  and assigned(lastContact)
  and (lastContact<>ch.who)
  and (pTCE(ch.who.data).keylay<>0) then
    ActivateKeyboardLayout(pTCE(ch.who.data).keylay,0);

  if chatFrm.visible and not IsIconic(chatFrm.handle) then
{    if ch.historyBox.autoscroll then
      ch.historyBox.go2end
    else}
      ch.historyBox.repaint;
  updateGraphics;
   SBSearch.Enabled := True;
   fp.Visible:=findBtn.Down;
//   SearchPnl.Visible := findBtn.Down;
    if usePlugPanel then
      begin
      if plugBtns.PluginsTB <> toolbar then
       begin
        plugBtns.PluginsTB.Parent := ch.btnPnl;
        plugBtns.PluginsTB.Visible := True;
       end;
      end
     else
     for I := Low(plugBtns.btns) to High(plugBtns.btns) do
      if Assigned(plugBtns.btns[i]) then
       if not plugBtns.btns[i].Enabled then
        plugBtns.btns[i].Enabled := True;
  lastContact:=NIL;
//  if Assigned(ch.avtPic.PicAni) then
  if Assigned(ch.avtPic.PicAni) and (ch.avtPic.PicAni.Animated) then
    FAniTimer.Enabled := True
   else
    FAniTimer.Enabled := false;
  if isVisible and enabled and pagectrl.visible and pagectrl.enabled then
   ch.input.setFocus;
   
 end
else
  if (ch.chatType = CT_PLUGING) then
  begin
//    ch.input.visible:= false;
//    ch.splitter.visible:= false;
    if usePlugPanel then
     begin
      if plugBtns.PluginsTB <> toolbar then
      begin
        plugBtns.PluginsTB.Parent := self;
        plugBtns.PluginsTB.Visible := False;
      end;
     end
    else
     for I := Low(plugBtns.btns) to High(plugBtns.btns) do
      if Assigned(plugBtns.btns[i]) then
        plugBtns.btns[i].Enabled := False;
    SBSearch.Enabled := False;

//    fp.Visible:= false;
    plugins.castEv(PE_SELECTTAB, ch.id);
  end;

sendBtn.enabled := ch.chatType <> CT_PLUGING;
historyBtn.enabled  := sendBtn.enabled;
findBtn.enabled     := sendBtn.enabled;
smilesBtn.enabled   := sendBtn.enabled;
autoscrollBtn.enabled := sendBtn.enabled;
infoBtn.enabled     := sendBtn.enabled;
quoteBtn.enabled    := sendBtn.enabled;
btnContacts.enabled := sendBtn.enabled;
singleBtn.enabled   := sendBtn.enabled;
RnQPicBtn.enabled   := sendBtn.enabled;
//SimplMsgBtn.Enabled := sendBtn.Enabled;
//panel.visible:=  ch.who.uin <> 5000;
end; // pageCtrlChange

procedure TchatFrm.inputKeydown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  x,y,i:integer;
  m:Tmemo;
  s:string;
  b : Boolean;
begin
if thisChat <> NIL then
begin
 m:=thisChat.input;
 if shift = [ssCtrl] then
  case key of
    VK_BACK:
      begin
      x:=m.caretpos.x;
      y:=m.CaretPos.y;
      s:=m.lines[y];
      if x=0 then
        if y=0 then
          exit
        else
          begin
          m.lines.Delete(y);
          dec(y);
          x:=length(m.lines[y]);
          m.lines[y]:=m.lines[y]+s;
          end
      else
        begin
        while (x>0) and ((x > Length(s)) or (s[x]=' ')) do
          dec(x);
        i:=x-1;
 {$IFDEF UNICODE}
        b :=  TCharacter.IsLetterOrDigit(s[x]);
        while (i>0) and ((i > Length(s)) or ((b) = TCharacter.IsLetterOrDigit(s[i]))) do
 {$ELSE nonUNICODE}
        b := s[x] in ALPHANUMERIC;
        while (i>0) and ((i > Length(s)) or ((b) = (s[i] in ALPHANUMERIC))) do
 {$ENDIF UNICODE}
          dec(i);
        delete(s,i+1,m.caretpos.x-i);
        m.lines[y]:=s;
        x:=i;
        end;
      m.caretpos:=point(x,y);
      key:=0;
      end;
    end;
end;
end;

procedure TchatFrm.inputPopup(Sender: TObject;
  MousePos: TPoint; var Handled:Boolean);
begin enterCount:=0 end;

procedure TchatFrm.inputChange(Sender: TObject);
var
  ch : TchatInfo;
begin
  ch := thisChat;
  if ch<>NIL then
  with ch do
  begin
    if not Assigned(who) then
      Exit;
   // send typing notify
    sbar.panels[0].text:= getTranslation('Chars:')+' '+intToStr(length(input.Text));
    quoteIdx:=-1;
   { $IFDEF RNQ_FULL}
    who.fProto.InputChangedFor(who, length(input.Text) = 0);
   { $ENDIF}
  end;
end;

procedure TchatFrm.Close1Click(Sender: TObject);
begin closeThisPage end;

procedure TchatFrm.Viewinfo1Click(Sender: TObject);
var
  cnt : TRnQContact;
begin
  cnt := thisContact;
  if Assigned(cnt) then
    cnt.ViewInfo;
end;

function TchatFrm.sawAllhere:boolean;
const
//  clearEvents : array[0..4] of byte = (EK_msg, EK_url, EK_auth, EK_authDenied, EK_addedYou);
  clearEvents = [EK_msg, EK_url, EK_auth, EK_authDenied, EK_addedYou];
var
  c:TRnQcontact;
  ch : TchatInfo;
//  t : byte;
  k : Integer;
  ev0 : Thevent;
  found : Boolean;
begin
  result:= FALSE;
  found := false;
  ch := thisChat;
  if ch=NIL then exit;
   if ch.chatType <> CT_IM then Exit;
  c:= ch.who;
//  for t in clearEvents do
   begin
     k := -1;
     repeat
       k:=eventQ.getNextEventFor(c, k);
//       if (ev0 = nil) then
//         Break;
//       if ev0.kind in clearEvents then
//       begin
//         if not chatFrm.moveToTimeOrEnd(c, ev0.when) then
//            chatFrm.addEvent(c, ev0.clone);
//       k := eventQ.find(t, c);
       if (k >= 0) and (k < eventQ.count) then
         begin
          ev0 := Thevent(eventQ.items[k]);
          if ev0.kind in clearEvents then
           begin
            found := True;
            eventQ.removeAt(k);
            if BE_history in behaviour[ev0.kind].trig then
              if not chatFrm.moveToTimeOrEnd(c, ev0.when, false) then
  //          if fo then
                chatFrm.addEvent(c, ev0.clone);
            try
          //    FreeAndNil(ev);
               ev0.free;
             except
            end;
           end
  //         eventQ.Remove(ev0);
          else
           inc(k);
         end
        else
         k := -1;
     until (k<0);
   end;
{
  if eventQ.removeEvent(EK_msg, c)
    or eventQ.removeEvent(EK_url, c)
    or eventQ.removeEvent(EK_auth, c)
    or eventQ.removeEvent(EK_authDenied, c)
    or eventQ.removeEvent(EK_addedYou, c) then}
   if found then
     begin
      result:=TRUE;
      roasterLib.redraw(c);
      saveinboxDelayed:=TRUE;
     end;

  TipRemove(c);
end; // sawAllHere



procedure TchatFrm.FormKeyPress(Sender: TObject; var Key: Char);
var
  s:string;
  i, l, k : integer;
  ch : TchatInfo;
begin
if key<>#13 then
  enterCount:=0
else
  begin
    ch := thischat;
  if ch <> NIL then
   if ch.chatType = CT_IM then
    if ActiveControl = w2sBox then
     begin
      SBSearchClick(NIL);
      exit;
     end
    else
     if (ActiveControl = ch.input)  then
      begin
       inc(enterCount);
       if (enterCount=sendOnEnter) then
        begin
         s:= ch.input.text;
         l := 2*pred(enterCount);
         k := l;
//         i := 1 + ch.input.SelStart;
         i := ch.input.SelStart;
         while (l >0)and((s[i] = #10)or(s[i]=#13)) do
          begin
           dec(i);
           dec(l);
          end;
         dec(k, l);
//         delete(s,1 + ch.input.SelStart-l, l);
         delete(s,1+i, k);
         ch.input.text:=s;
         key:=#0;
         send;
  //      Exit;
        end;
      end;
  end;
case key of
  #27:begin close; key := #0; end;
  #127,   // ctrl+bs
  #10:key:=#0;
//  else
//   Inherited;
  end;
end;

procedure TchatFrm.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  ch:TchatInfo;
  i : Integer;
  b : Boolean;
//  wm : TWMKey;
begin
ch:=thisChat;
//MainDlg.RnQmain.fin
//if ActiveControl then

if ch = nil then Exit;
if shift = [] then
  case key of
    VK_APPS:
      if Assigned(ch) and (ch.chatType = CT_IM) then
       begin
        clickedContact:=ch.who;
        with ch.historyBox.ClientToScreen(ch.historyBox.margin.TopLeft) do
         MainDlg.RnQmain.contactMenu.popup(x,y);
       end;
    VK_BROWSER_BACK:
      begin
        pageCtrl.SelectNextPage(FALSE);
      end;
    VK_BROWSER_FORWARD:
      begin
        pageCtrl.SelectNextPage(True);
      end;
    end
else
if (shift = [ssAlt]) and (ch.chatType = CT_IM) then
  case key of
    VK_A:
      begin
      with autoscrollBtn do down:=not down;
       autoscrollBtnClick(self);
      end;
    VK_P: prefBtnClick(self);
    VK_I: infoBtnClick(self);
    VK_Q: quote();
    VK_H:
      begin
      with historyBtn do down:=not down;
      historyBtnClick(self);
      end;
    VK_M:
      begin
//       with smilesBtn do down:=not down;
//       smilesBtnClick(self);
        hAShowSmilesExecute(Self);
      end;
    VK_BACK: ch.input.Undo();
    VK_S: begin send; key := 0; end;
  end;
// else                    
if ( not useCtrlNumInstAlt and (shift = [ssAlt])) or
     ( useCtrlNumInstAlt and (shift = [ssCtrl])) then
    case key of
     byte('1')..byte('9'): begin
        i := key-byte('1');
        if chats.validIdx(i) then
        if pagectrl.ActivePageIndex <> i then
        begin
           b := True;
           pagectrlChanging(pagectrl, b);
           if b then
             pagectrl.ActivePageIndex := i;
           pageCtrlChange(pagectrl);
           key := 0;
           Shift := [];
           Exit;
        end;
      end;
    end;

if (shift = [ssAlt]) or (shift = [ssAlt,ssCtrl]) then
  case key of
    VK_LEFT:  pageCtrl.SelectNextPage(FALSE);
    VK_RIGHT: pageCtrl.SelectNextPage(TRUE);
    VK_UP,VK_DOWN,VK_PRIOR,VK_NEXT:
      if ch.chatType = CT_IM then
      case key of
        VK_UP:   ch.historyBox.histScrollEvent(-1);
        VK_DOWN: ch.historyBox.histScrollEvent(+1);
        VK_PRIOR:ch.historyBox.histScrollEvent(-5);
        VK_NEXT: ch.historyBox.histScrollEvent(+5);
        end;
    VK_HOME:
      if ch.chatType = CT_IM then
        ch.historyBox.histScrollEvent(-ch.historyBox.rsb_position);
    VK_END:
      if ch.chatType = CT_IM then
      begin
//       ch.historyBox.setautoscrollForce(TRUE);
//       autoscrollBtn.down := True;
        ch.setAutoscroll(True);
      end;
    end
else
if shift = [ssCtrl] then
  case key of
    VK_PRIOR:
      if ch.chatType = CT_IM then
        ch.historyBox.histScrollEvent(-5);
    VK_NEXT:
      if ch.chatType = CT_IM then
        ch.historyBox.histScrollEvent(+5);
    VK_RETURN:
      if ch.chatType = CT_IM then
      if sendOnEnter = 1 then
        begin
         i := ch.input.SelStart;
         ch.input.Text := Copy(ch.input.Text, 1, i) + CRLF+
         Copy(ch.input.Text, i+1, Length(ch.input.Text) - i);
         ch.input.SelStart := i+2;
         ch.input.Perform(EM_SCROLLCARET, 0, 0);
        end
       else send;
    VK_UP:
      if ch.chatType = CT_IM then
        ch.historyBox.histScrollLine(-1);
    VK_DOWN:
      if ch.chatType = CT_IM then
        ch.historyBox.histScrollLine(+1);
    VK_C:
      if ch.chatType = CT_IM then
        if ch.input.selLength=0 then
         if Length(ch.historyBox.getSelText) > 0 then
           clipboard.asText:=ch.historyBox.getSelText;
    VK_F6: pageCtrl.SelectNextPage(TRUE);
    VK_F4, VK_W: try
            sawAllHere;
            closeThisPage;
            key := 0;
//            Shift := [];
            Exit;
          except
          end;
    VK_S:
      if ch.chatType = CT_IM then
   {$IFDEF USE_SMILE_MENU}
       if Assigned(smilesBtn.PopupMenu) then
         with smilesBtn.ClientOrigin do//ClientToScreen(smilesBtn.ClientOrigin) do
          smileMenuExt.Popup(x, y)
        else
   {$ENDIF USE_SMILE_MENU}
         ShowSmileMenu(smilesBtn.ClientOrigin);
    VK_A:
      if (ch.chatType = CT_IM) then
       begin
        if (ActiveControl= ch.input) then
          ch.input.SelectAll
         else
          selectall1Click(self);
        Key := 0;
       end;
    VK_F:begin
           if not({(ActiveControl = MainDlg.RnQmain.roaster) or
                  (ActiveControl = MainDlg.RnQmain.FilterEdit))}
              childParent(getFocus, MainDlg.RnQmain.handle))  then
            begin
             findbtn.down:=not findbtn.down;
             findBtnClick(self);
             Key := 0;
            end;
       end;
    end;
 if (shift<>[]) or (key <> 13) then
  enterCount:=0;
 if Assigned(ch) and (ch.chatType = CT_PLUGING) then
  begin
   SendMessage(ch.ID, WM_KEYDOWN, Key, 0);
{   wm.Msg := WM_KEYDOWN;
   wm.CharCode := Key;
   wm.KeyData KeyDataToShiftState
   TControl(ch.ID).WindowProc(
   Perform(WM_KEYDOWN, )}
  end;
  inherited;
end; // keydown

procedure TchatFrm.open(focus:boolean=TRUE);
var
  bak:Thandle;
  ch : TchatInfo;
begin
if chats.count = 0 then
  exit;
if not visible then
  bak:=getForegroundWindow
else
  bak:=0;
showForm(self);
if (bak>0) and not focus then
  forceforegroundwindow(bak);
SetWindowPos(Handle, HWND_TOP, 0,0,0,0, SWP_NOMOVE+SWP_NOSIZE); // bring it atop if it is not
ch := thisChat;
if focus then
  begin
   bringForeground:=handle;
   if Assigned(ch) then
    if ch.chatType = CT_IM then
     ch.input.setFocus;
  end
 else
  if isVisible then
   if Assigned(ch) then
    if ch.chatType = CT_IM then
     ch.input.setFocus;
end; // open

function TchatFrm.isVisible:boolean;
begin result:=getForegroundWindow=handle end;

procedure TchatFrm.quote(qs : String = ''; MakeCarret : Boolean = True);
var
  i:integer;
  AddToInput : Boolean;
  oldPos:Tpoint;
  selected,s,result,leading:string;

  function addquote(s:string):string;
  begin
   if (length(leading)>0) and (leading[1] = '>') then
     result:='>' + s
    else
     result:='> '+ s;
  end; // addquote
begin
 if thisChat=NIL then exit;
 with thisChat do
  begin
   if Assigned(input) and (input.Visible)and input.Enabled then
    input.setFocus;
   if Length(qs) > 0 then
     begin
      selected := qs;
      AddToInput := True;
     end
    else
     begin
      if historyBox.history.count = 0 then  // there's nothing to quote for sure
        exit;
      AddToInput := True;
      if quoting.quoteselected then selected:=trim(historyBox.getSelText)
      else selected:='';
      if selected='' then
       begin
        AddToInput := False;
        // save original reply at the beginning of a quoting-cycle
        if quoteIdx < 0 then
          lastInputText:=input.text;

        selected := historyBox.getQuoteByIdx(quoteIdx);
       end;
     end;

  result:='';
  while selected > '' do
   begin
    s:=trimright(chop(#10,selected));
    if s='' then continue;
    leading:=getLeadingInMsg(s);
    if MakeCarret then
      s:=wraptext(s, 50);
    result:=result+addquote(chop(CRLF,s))+CRLF;
    while s > '' do
      result:=result+addquote(chop(CRLF,s))+CRLF;
   end;
  i:=quoteIdx;
//  Delete(result, length(result)-1, 2);
  oldPos:=input.CaretPos;
  if AddToInput then
    input.SelText := result
  else
   begin
    input.text:=lastInputText;
    input.lines.add(result);
    if quoting.cursorBelow then
      input.selStart:=length(input.text)
    else
      input.CaretPos:=oldPos;
   end;
//  input.SelText := result;
  quoteIdx:=i;
  end;
end; // quote

procedure TchatFrm.FormActivate(Sender: TObject);
begin
 {$IFDEF RNQ_FULL}
 if thisChat <> NIL then
   thisChat.repaint;
 {$ENDIF RNQ_FULL}
end;

procedure TchatFrm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
updatechatfrmXY;
//if searchhistFrm <> nil then
//  searchhistFrm.Close;
end; // form close

procedure TchatFrm.selectall1Click(Sender: TObject);
var
  ch:TchatInfo;
begin
  ch:=thischat;
  if ch=NIL then exit;
  with ch.historyBox do
  if historyNowCount > 0 then
   begin
    select(historyNowOffset, history.count-1);
//  clipboard.asText:=getSelText;
    repaint;
    ch.updateAutoscroll(nil);
   end;
end; // select all

procedure TchatFrm.viewmessageinwindow1Click(Sender: TObject);
begin
if thisChat=NIL then exit;
with thisChat.historyBox do
  if somethingIsSelected then
    viewTextWindow(getTranslation('selection'), getSelText)
  else
//    if pointedItem.kind<>PK_NONE then
    if clickedItem.kind<>PK_NONE then
      viewHeventWindow(clickedItem.ev);
end; // open

procedure TchatFrm.txt1Click(Sender: TObject);
var
  fn:string;
begin
if thisChat=NIL then exit;
fn:=openSavedlg(self, 'Save text as UTF-8 file', false, 'txt');
if fn = '' then exit;
savefile2(fn, StrToUTF8(thisChat.historyBox.getSelText));
end; // txt

procedure TchatFrm.html1Click(Sender: TObject);
var
  fn:string;
begin
if thisChat=NIL then exit;
fn:=openSavedlg(self, '', false, 'html');
if fn = '' then exit;
savefile2(fn, thisChat.historyBox.getSelHtml2(FALSE));
end; // html

procedure TchatFrm.infoBtnClick(Sender: TObject);
var
  cnt : TRnQContact;
begin
  cnt := thisContact;
  if Assigned(cnt) then
    cnt.ViewInfo;
end;

procedure TchatFrm.updateContactStatus;
var
  cnt : TRnQContact;
begin
  cnt := thisContact;
  if cnt=NIL then
   begin
    sendBtn.ImageName := status2imgName(byte(SC_UNK), FALSE);
    exit;
   end;
  sendBtn.ImageName := rosterImgNameFor(cnt);
  sendBtn.Invalidate;
  sbar.Invalidate;

  {$IFDEF RNQ_AVATARS}
  if not cnt.icon.IsBmp then
   with thisChat.avtPic do
   if Assigned(swf) then
    // Статусы: stam, smile, laugh, mad, sad, cry, offline, busy, love
       case cnt.GetStatus of
         byte(SC_OCCUPIED)..byte(SC_AWAY) : swf.TGotoLabel('face', 'busy');
         byte(SC_F4C)     :    swf.TGotoLabel('face', 'smile');
         byte(SC_OFFLINE) :    swf.TGotoLabel('face', 'offline');
         byte(SC_UNK)     :    swf.TGotoLabel('face', 'stam');
         byte(SC_Evil)    :    swf.TGotoLabel('face', 'mad');
         byte(SC_Depression) : swf.TGotoLabel('face', 'sad');
         //swf.TGotoFrame('face', 'stam');
         else
            swf.TGotoFrame('face', 0);
       end;
  {$ENDIF RNQ_AVATARS}
end; // updateSendBtn

procedure TchatFrm.closePageAt(idx:integer);
var
  old:TTabSheet;
  oldCh : TchatInfo;
begin
  if (idx<0) or (idx >= pageCtrl.PageCount) then exit;
 {$IFDEF RNQ_FULL}
//  rqSmiles.ClearAniParams;
  theme.ClearAniParams;
 {$ENDIF RNQ_FULL}
  oldCh := chats.byIdx(idx);
//  with  do
   begin
    if plugBtns.PluginsTB.Parent = oldCh.btnPnl then
      plugBtns.PluginsTB.Parent := pagectrl;
    lastContact:= oldCh.who;

    if oldCh.chatType = CT_PLUGING then
     begin
      plugins.castEv(PE_CLOSETAB, oldCh.id);
//    chatFrm.RemoveControl(TWinControl(id));
     end
    else
    if oldCh.chatType = CT_IM then
    begin
     { $IFDEF RNQ_FULL}
     // end typing
      oldCh.who.fProto.InputChangedFor(oldCh.who, True);
     { $ENDIF}
      oldCh.historyBox.newSession:=0;
      if oldCh.historyBox.history<>NIL then
       begin
  //      historyBox.history.reset;
        oldCh.historyBox.history.Free;
        oldCh.historyBox.history := NIL;
       end;

    end;
    old:=pageCtrl.Pages[idx];
//    with old do
      begin
{
        while controlCount > 0 do
//          FreeAndNil(controls[0]);
          controls[0].free;
}
      old.pageControl:=NIL;
  //    free;
      end;
    chats.Delete(idx);
    oldCh.free;
//    chats.byIdx(idx).Free;
    old.free;
   end;
  if pageCtrl.pageCount = 0 then
    begin
     if docking.Docked2chat then
      begin
  //     docking.Dock2Chat := False;
       applyDocking(True);
      end;
     close
    end
   else
    begin
      pagectrl.repaint;
      if pageCtrl.activePage=NIL  then
        pageCtrl.SelectNextPage(true)
       else
        pageCtrlChange(self)
    end;
  if userTime > 0 then
//  savePages;
    saveListsDelayed := True;
end; // closePageAt

procedure TchatFrm.closeChatWith(c:TRnQContact);
begin closePageAt(chats.idxOf(c)) end;

procedure TchatFrm.FormShow(Sender: TObject);
//var
//  i:integer;
begin
//  theme.getIco2(PIC_MSG, icon);
  theme.pic2ico(RQteFormIcon, PIC_MSG, icon);
//icon:=getIco2('msg');
  applyFormXY;
  lastContact:=NIL;
  updateContactStatus;
  if thisChat <> NIL then
   thisChat.repaint();
//  toolbar.buttonheight:=panel.Height -18+5;
//  toolbar.buttonheight:= 21;
  if plugBtns.PluginsTB <> toolbar then
   begin
     if Assigned(plugBtns.PluginsTB) then
      plugBtns.PluginsTB.buttonheight:=21;
   end;

//  i:=getWindowLong(pagectrl.handle, GWL_EXSTYLE);
//  setWindowLong(pagectrl.handle, GWL_EXSTYLE,  i and (not TCS_OWNERDRAWFIXED) );

//  i := GetClassLong(pagectrl.Handle, GCL_STYLE);
//  SetClassLong(pagectrl.Handle, GCL_STYLE, i and (not TCS_OWNERDRAWFIXED));
end;

procedure TchatFrm.findBtnClick(Sender: TObject);
begin
{  if not Assigned(searchHistFrm) then
   begin
     searchHistFrm := TsearchhistFrm.Create(Application);
     translateWindow(searchHistFrm);
   end;
  showForm(searchHistFrm)}
  w2sBox.Visible:=findBtn.Down;
  directionGrp.Visible:=findBtn.Down;
  directionGrp.ItemIndex := 0;
  caseChk.Visible:=findBtn.Down;
  reChk.visible:=findBtn.Down;
  SBSearch.Visible:=findBtn.Down;
  if thisChat <> NIL then
   thisChat.historyBox.w2s := '';
  fp.Visible:=findBtn.Down;
//  SearchPnl.Visible := findBtn.Down;
  if not (historyBtn.Down) and (findBtn.Down)
    then begin historyBtn.down:=true;
      historyBtnClick(sender); end;
  if w2sBox.Visible then
    ActiveControl := w2sBox
  else
   if thisChat <> NIL then
     ActiveControl := thisChat.input;
end;

procedure TchatFrm.findBtnMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbRight then
   showForm(WF_SEARCH);
end;

procedure TchatFrm.quoteBtnClick(Sender: TObject);
begin quote end;

procedure TchatFrm.quoteBtnMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbRight then
//   quote(clipboard.asText, false);
   quote(clipboard.asText, ssCtrl in Shift);
end;

procedure TchatFrm.smilesBtnClick(Sender: TObject);
//var
//  ch:Tchatinfo;
begin
//  ShowSmileMenu(TRnQSpeedButton(Sender).ClientToScreen(Point(
//      TRnQSpeedButton(Sender).Left, TRnQSpeedButton(Sender).Top)));
  ShowSmileMenu(toolbar.ClientToScreen(Point(
      TRnQSpeedButton(Sender).Left, TRnQSpeedButton(Sender).Top)));
  enterCount := 0;
{  useSmiles:=smilesBtn.down;
  ch:=thischat;
  if ch=NIL then exit;
  inc(ch.historyBox.history.Token);
  ch.repaint;
  if visible then
    ch.input.SetFocus;}
end;

procedure TchatFrm.smilesBtnMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if (Button<>mbRight) then exit;
  ShowSmileMenu(TRnQSpeedButton(Sender).ClientToScreen(Point(x,y)));
  enterCount := 0;
end;

procedure TchatFrm.closeAllPages(isAuto : Boolean = false);
begin
  if isAuto then
    PagesEnumStr := Pages2String
   else
    PagesEnumStr := '';
pagectrl.hide;
while pagectrl.PageCount > 1 do
  if pageIndex=0 then
    closePageAt(1)
  else
    closePageAt(0);
closePageAt(0);
pagectrl.show;
end;  // closeAllPages

procedure TchatFrm.autoscrollBtnClick(Sender: TObject);
var
  ch:Tchatinfo;
begin
  ch:=thisChat;
  if ch=NIL then exit;
  ch.setAutoscroll(autoscrollBtn.down);
  ch.repaint();
  if visible then
    ch.input.SetFocus;
end;

procedure TchatFrm.redrawTab(c:TRnQcontact);
var
  i:integer;
  R:Trect;
begin
 i:=chats.IdxOf(c);
 if (i < 0) or (i >= pagectrl.PageCount) then exit;
 SendMessage(pagectrl.Handle, TCM_GETITEMRECT, i, Longint(@R));
 R.right:=R.left+30;
 inc(r.Top, 1);
 dec(r.Bottom, 1);
 invalidateRect(pagectrl.handle, @R, TRUE);
end;

procedure TchatFrm.setCaptionFor(c:TRnQContact);
var
  i:integer;
  w : Integer;
begin
i:=chats.idxOf(c);
if (i >= 0) AND (i < pagectrl.PageCount) then
 begin
  w := max(pagectrl.Canvas.TextWidth('_'), 5);
  pageCtrl.pages[i].caption:=
     // additional spaces for icon
//    StringOfChar('_',2+theme.getPicSize(RQteDefault, status2imgName(byte(SC_ONLINE)), 16).cx div w);
    StringOfChar('_',2+ statusDrawExt(0, 0, 0, byte(SC_ONLINE)).cx div w)
    +dupAmperstand(c.displayed);

 {$IFDEF RNQ_FULL}
 {$IFDEF CHECK_INVIS}
//  if c.invisibleState > 0 then
//  pageCtrl.pages[i].caption := pageCtrl.pages[i].caption +
//    StringOfChar('_',1+theme.getPicSize(status2imgName(SC_ONLINE, true), 5).cx div w);
 {$ENDIF}
//  if c.typing.bIsTyping then
//  pageCtrl.pages[i].caption := pageCtrl.pages[i].caption +
//    StringOfChar('_',1+theme.getPicSize(PIC_TYPING, 5).cx div w);
 {$ENDIF}
 end;
end; // setCaptionFor

procedure TchatFrm.setCaption(idx : Integer);
var
//  i:integer;
  c : TRnQcontact;
  R:Trect;
  w : Integer;
begin
//i:=chats.idxOf(c);
  if not chats.validIdx(idx) then Exit;
  w := max(pagectrl.Canvas.TextWidth('_'), 5);
  if chats.byIdx(idx).chatType = CT_IM then
  begin
   c := chats.byIdx(idx).who;
   begin
    pageCtrl.pages[idx].caption:=
       // additional spaces for icon
//      StringOfChar('_',2+theme.getPicSize(RQteDefault, status2imgName(byte(SC_ONLINE)), 16).cx div w);
      StringOfChar('_',2+ statusDrawExt(0, 0, 0, byte(SC_ONLINE)).cx div w)
      +dupAmperstand(c.displayed);
   {$IFDEF RNQ_FULL}
   {$IFDEF CHECK_INVIS}
//    if c.invisibleState > 0 then
//    pageCtrl.pages[idx].caption := pageCtrl.pages[idx].caption +
//      StringOfChar('_',1+theme.getPicSize(status2imgName(SC_ONLINE, true), 5).cx div w);
   {$ENDIF}
//    if c.typing.bIsTyping then
//    pageCtrl.pages[idx].caption := pageCtrl.pages[idx].caption +
//      StringOfChar('_',1+theme.getPicSize(PIC_TYPING, 5).cx div w);
   {$ENDIF}
   end;
  end
  else
    begin
     pageCtrl.pages[idx].caption:= chats.byIdx(idx).lastInputText+    // additional spaces for icon
      StringOfChar('_',2+theme.getPicSize(RQteDefault, 'plugintab'+IntToStrA(chats.byIdx(idx).ID), 16).cx div w);
     SendMessage(pagectrl.Handle, TCM_GETITEMRECT, idx, Longint(@R));
     //R.right:=R.left+20;
     invalidateRect(pagectrl.handle, @R, TRUE);

    end;
end; // setCaption

procedure TchatFrm.singleBtnClick(Sender: TObject);
begin thisChat.single:=singleBtn.down end;

procedure TchatFrm.WndProc(var Message: TMessage);
//var
//  ShiftState: TShiftState;
//var
// ti : TTCItem;
begin
 case message.msg of
  WM_SYSCOMMAND:
    updatechatfrmXY;

  WM_mousewheel,
    WM_VSCROLL:
   if (Assigned(chats))and(thisChat <> NIL) and (thisChat.chatType = CT_IM) then
    if message.wparam shr 31 > 0 then
      thisChat.historyBox.histScrollEvent(+wheelVelocity)
    else
      thisChat.historyBox.histScrollEvent(-wheelVelocity);
{  WM_VSCROLL:
   if (Assigned(chats))and(thisChat <> NIL) and (thisChat.chatType = CT_IM) then
    if message.wparam shr 31 > 0 then
      thisChat.historyBox.histScrollEvent(+wheelVelocity)
    else
      thisChat.historyBox.histScrollEvent(-wheelVelocity);
}
//  WM_ENTERMENULOOP:
//    begin
//      thisChat.historyBox.histScrollEvent(+wheelVelocity)
//    end;
//  WM_EXITMENULOOP:
//    begin
//      clearMenu(smileMenuExt.Items);
//    end;
//   256:
//     begin
//     end;
  WM_KEYDOWN:
     if (thisChat <> nil) and (thisChat.chatType = CT_PLUGING) then
      begin
       TControl(thisChat.ID).WindowProc(Message);
//       Perform(WM_KEYDOWN, )
      end;
{
    with TWMKey(Message) do
      begin
        ShiftState := KeyDataToShiftState(KeyData);
        if (ssCtrl in ShiftState) and (CharCode = VK_F4) then
          try
            sawAllHere;
            closeThisPage;
            Exit;
          except
          end;
      end;}
  WM_HELP:
    begin
      exit;
    end;
  {
    TCItem.iImage := GetImageIndex(I);
    if SendMessage(Handle, TCM_SETITEM, I,
      Longint(@TCItem)) = 0 then
      TabControlError(Format(sTabFailSet, [FTabs[I], I]));
  end;
  TabsChanged;
  
   }
  end;
inherited;
end; // WMmouseWheel

procedure TchatFrm.copylink2clpbdClick(Sender: TObject);
begin
//with thisChat.historyBox do
//  if pointedItem.kind=PK_LINK then
//    clipboard.asText := pointedItem.link.str;
//with thisChat.historyBox.pointedItem do
  with thisChat.historyBox.ClickedItem do
  if kind=PK_LINK then
    clipboard.asText := link.str;
end;

procedure TchatFrm.copy2clpbClick(Sender: TObject);
begin clipboard.asText:=thisChat.historyBox.getSelText end;

procedure TchatFrm.btnContactsClick(Sender: TObject);
begin openSendContacts(thisContact) end;

procedure TchatFrm.chatDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
begin accept:=source=MainDlg.RnQmain.roster end;

procedure TchatFrm.chatDragDrop(Sender, Source: TObject; X, Y: Integer);
var
  cl:TRnQCList;
begin
  if (clickedContact=NIL)or (thisContact = NIL) then exit;
  cl:=TRnQCList.create;
  cl.add(clickedContact);
   Proto_Outbox_add(OE_contacts, thisContact, 0, cl);
  cl.free;
end;

procedure TchatFrm.addlink2favClick(Sender: TObject);
begin
//with thisChat.historyBox.pointedItem do
 with thisChat.historyBox.clickedItem do
  if kind=PK_LINK then
    addLinkToFavorites(link.str);
end;

procedure TchatFrm.updatechatfrmXY;
begin
  if not visible then exit;
  if windowState <> wsMaximized then
    begin
      chatfrmXY.top:=top;
      chatfrmXY.left:=left;
      chatfrmXY.height:=height;
      chatfrmXY.width:=width;
    end;
  if windowState <> wsMinimized then
    chatfrmXY.maximized:= windowState=wsMaximized;
end; // updatechatfrmXY


procedure TchatFrm.historyAllShowChange(ch : TchatInfo; histBtnDown : Boolean);
var
  olds,news:integer;
//  i : Integer;
  oldTime : TDateTime;
//  ch:TchatInfo;
//  str : TStream;
begin
//  ch:=thisChat;
  if ch=NIL then exit;
  with ch.historyBox do
  begin
    whole:=histBtnDown;
    autoScroll := autoScrollVal;
    if whole then
     begin
      offset:=0;
      with history do
      if not loaded then
        begin
         olds := count;
         if olds > 0 then
           oldTime := getAt(0).when
          else
           oldTime := 0;
         Clear;
//         fromString(loadFile(userPath+historyPath + ch.who.uid));
         load(ch.who);
//         str := GetStream(userPath+historyPath + ch.who.uid);
//         fromSteam(str);
//         str.Free;
         news:=Count;
         if oldTime > 0 then
          begin
//            olds := news;
            while (news >0)and(getAt(news-1).when >= oldTime) do
             Dec(news);
//            dec(news, max(0, olds));
//         news:=count-olds;
          end;
//         with ch.historyBox do
         begin
          inc(newSession, news);
          inc(startSel.evIdx, news);
          inc(endSel.evIdx, news);
          inc(topVisible, news)
         end;
        end
//        else
//         begin
//           go2end;
//         end;
     end
    else
     begin
       autoscroll:=TRUE;
       offset := newSession;
       if topVisible < offset then
         topVisible := offset;
     end;
//    setAutoScrollForce(autoScroll);
    autoScrollVal := autoScroll;
    ch.repaintAndUpdateAutoscroll();
    updateRSB(false, 0, True);
    if self.visible then
     if ch = thischat then
      try
        ch.input.SetFocus;
       except
      end;
  end;
end;

procedure TchatFrm.historyBtnClick(Sender: TObject);
var
//  olds,news:integer;
  ch:TchatInfo;
begin
  ch:=thisChat;
  if ch=NIL then exit;
  historyAllShowChange(ch, historyBtn.down);
end;

procedure TchatFrm.sbarDblClick(Sender: TObject);
var
 ch : TchatInfo;
begin
  with sbar.ScreenToClient(mousePos) do
 case whatStatusPanel(sbar, x) of
  2: begin
       if Assigned(TranslitList) then
        if TranslitList.Count > 0 then
         begin
           ch := thisChat;
           if Assigned(ch) and (ch.chatType = CT_IM) and Assigned(ch.who) then
            begin
             ch.who.SendTransl := not ch.who.SendTransl;
             sbar.Invalidate;
            end;
         end;
     end;
 end;
end;

procedure TchatFrm.sbarDrawPanel(StatusBar: TStatusBar; Panel: TStatusPanel; const Rect: TRect);
var
 Details : TThemedElementDetails;
 ch : TchatInfo;
// s  : String;
 Arect : TRect;
 agR, r2 : TGPRect;
begin
//  statusbar.canvas.Brush.Color := clBtnFace
 StatusBar.Canvas.Font.Assign(Screen.MenuFont);
//  statusbar.canvas.FillRect(rect);
 Arect := rect;
 Arect.Top := 0;
// dec(Arect.Right);
// inc(Arect.Left);
 inc(Arect.Right);
 dec(Arect.Left);
 inc(Arect.Bottom);
 case panel.index of
  1,2,3:
     if ThemeServices.ThemesEnabled then
      begin
//        Details := ThemeServices.GetElementDetails(tsGripperPane);
//        Details := ThemeServices.GetElementDetails(tsStatusDontCare);
//        Details := ThemeServices.GetElementDetails(tsPane);
//        Details := ThemeServices.GetElementDetails(tsPane);
        Details := ThemeServices.GetElementDetails(tsStatusRoot);
//        ThemeServices.DrawElement();
//        ThemeServices.DrawElement(statusbar.canvas.Handle, Details, Rect, nil);
        ThemeServices.DrawElement(statusbar.canvas.Handle, Details, Arect, nil);
//       ThemeServices.DrawParentBackground(StatusBar.Handle, statusbar.canvas.Handle, @Details, false);
      end
      else
        statusbar.canvas.FillRect(rect);
 end;
 ch := thisChat;
 agR.X := Rect.Left;
 agR.Y := Rect.Top+1;
 agR.Width := Rect.Right - Rect.Left;
 agR.Height := Rect.Bottom - Rect.Top;
 case panel.index of
  1: begin
       if Account.outbox.stFor(thisContact) then
         theme.drawPic(statusbar.canvas.Handle, agR, PIC_OUTBOX)
        else
         theme.drawPic(statusbar.canvas.Handle, agR, PIC_OUTBOX_EMPTY, false)
       ;
     end;
  2: if Assigned(ch) then
     begin
//      s := 'TRLT';
      SetBkMode(StatusBar.Canvas.Handle, TRANSPARENT);
      if (ch.chatType = CT_IM) and Assigned(TranslitList) and (TranslitList.Count > 0) then
       begin
       if ch.who.SendTransl then //and Assigned(TranslitList) and (TranslitList.Count > 0) then
         begin
          statusbar.canvas.Font.Style :=  [fsBold];
//         statusbar.canvas.TextRect(Rect, Rect.Left , Rect.Top, 'TRLT')
//          statusbar.canvas.TextRect(Rect, Rect.Left + (36 - statusbar.canvas.TextWidth(s)) div 2 , Rect.Top+2, 'TRLT')
//         statusbar.canvas.TextRect(Rect, s)
         end
        else
         begin
           statusbar.canvas.Font.Color := clGrayText;
//           statusbar.canvas.Font.Color := clInactiveCaptionText;
//           statusbar.canvas.TextRect(Rect, Rect.Left , Rect.Top, 'TRLT');
//         statusbar.canvas.TextRect(Rect, Rect.Left + (36 - statusbar.canvas.TextWidth(s)) div 2 , Rect.Top+2, 'TRLT')
         end;
        DrawText(StatusBar.Canvas.Handle, 'TRLT', 4, ARect, DT_CENTER or DT_SINGLELINE or DT_VCENTER);
       end;
     end;
  3: if Assigned(ch) then
      if ch.chatType = CT_IM then
      if ch.who.fProto.ProtoID = ICQProtoID then
       if TICQSession(ch.who.fProto).UseCryptMsg and
          ( TICQContact(ch.who).crypt.supportCryptMsg
           or
            TICQSession(ch.who.fProto).useMsgType2for(TICQContact(ch.who))
           )
       then
         begin
          if TICQContact(ch.who).crypt.supportCryptMsg then
//           theme.drawPic(statusbar.canvas.Handle, rect.left,rect.top+1, PIC_KEY);
            theme.drawPic(statusbar.canvas.Handle, agR, PIC_KEY)
           else
            if CAPS_big_QIP_SEQURE in TICQContact(ch.who).capabilitiesBig then
             begin
              if TICQContact(ch.who).crypt.qippwd > 0 then
               with theme.GetPicSize(RQteDefault, PIC_CLI_QIP, 16) do
                begin
                  r2 := agR;
                  inc(R2.X, cx+2);
                  dec(R2.Width, cx+3);
                  agR.Width := cx+3;
                  theme.drawPic(statusbar.canvas.Handle, R2, PIC_KEY);
//                    dec(agR.Width, cx+2);
                end;
              theme.drawPic(statusbar.canvas.Handle, agR, PIC_CLI_QIP)
             end;

         end;

 end;

end;

procedure TchatFrm.setStatusbar(s:string);
begin with sbar.Panels do items[count-1].text:=s end;

procedure TchatFrm.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  enterCount := 0;
end;

procedure TchatFrm.FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
//var
//  tabindex : Integer;
begin
  hintMode:=HM_comm;
{  tabindex := pagectrl.IndexOfTabAt(X, Y);
  if tabindex < 0 then
   begin
    FreeAndNil(hintwnd);
    hintTab := -1;
    exit;
   end;
}
end;

procedure TchatFrm.sbarMouseUp(Sender: TObject; Button: TMouseButton;  Shift: TShiftState; X, Y: Integer);
var
  ch : TchatInfo;
begin
 case whatStatusPanel(sbar, x) of
  1: begin
       if not Assigned(outboxFrm) then
        begin
         outboxFrm := ToutboxFrm.Create(Application);
         translateWindow(outboxFrm);
        end;
       outboxFrm.open(thisContact)
     end;
{  2: begin
       if Assigned(TranslitList) then
        if TranslitList.Count > 0 then
         begin
           ch := thisChat;
           if Assigned(ch) and (ch.chatType = CT_IM) and Assigned(ch.who) then
            begin
             ch.who.SendTransl := not ch.who.SendTransl;
             sbar.Invalidate;
            end;
         end;
     end;
}
 { $IFDEF USE_SECUREIM}
   3: begin
//       if (Button = mbRight)and Assigned(EncryptMenyExt) then
       if Assigned(EncryptMenyExt) then
        with sbar.ClientToScreen(Point(x,y)) do
         EncryptMenyExt.Popup(x,y);
      end;
 { $ENDIF USE_SECUREIM}
 end;
end;

function TchatFrm.moveToTimeOrEnd(c:TRnQcontact; time:Tdatetime; NeedOpen : Boolean = True) : Boolean;
var
  ch:TchatInfo;
  ev:Thevent;
  i : Integer;
begin
  Result := False;
  ch:=chats.byContact(c);
  if ch=NIL then exit;
  if ch.historyBox.history.Count = 0 then
//    result := True
   else
    begin
      with ch.historyBox do
       begin
        i := topVisible;
        go2end(True);
        ev:=history.getAt(topVisible);
       end;
      if (ev=NIL) or (ev.when > time) then
        result := moveToTime(c,time, NeedOpen);
      if not Result then
        ev := ch.historyBox.history.getAt(ch.historyBox.history.Count-1);
      if (ev <> NIL) then
        result := ev.when >= time
    end;
end; // moveToTimeOrEnd

function TchatFrm.moveToTime(c:TRnQContact; time:Tdatetime; NeedOpen : Boolean = True) : boolean;
var
  ch:TchatInfo;
  h:Thistory;
  i:integer;

  function search(ofs : Integer):integer;
  begin
  result:=h.Count-1;
//  while result >= 0 do
  while result >= ofs do
    if h.getAt(result).when <= time then
      break
    else
      dec(result);
  if result < ofs then
   Result := -1;
  if result >= ofs then
    if h.getAt(result).when <> time then
      result:=-1;
  end; // search

begin
  result := False;
  ch:=chats.byContact(c);
  if ch=NIL then exit;
  h:=ch.historyBox.history;
  i:=search(ch.historyBox.offset);
  if NeedOpen and (i < 0) and not ch.historyBox.whole then
    begin
      if ch = thisChat then
       historyBtn.down:=TRUE;
      historyAllShowChange(ch, True);
//    historyBtnClick(self);
      i:=search(ch.historyBox.offset);
      if i < 0 then
       begin
        if ch = thisChat then
         historyBtn.down:=FALSE;
        historyAllShowChange(ch, False);
//        historyBtnClick(self);
       end;
    end;
  if i >= 0 then
    with ch.historyBox do
    begin
     Result := True;
      updateRSB(True, i, True);
      topVisible := offset + rsb_position;
      topOfs:=0;
    end;
  ch.historyBox.repaint;
  ch.updateAutoscroll(nil);
end; // moveToTime

procedure TchatFrm.Sendwhenimvisibletohimher1Click(Sender: TObject);
begin
  send(IF_sendWhenImVisible)
end;

procedure TchatFrm.Sendmultiple1Click(Sender: TObject);
var
  wnd:TselectCntsFrm;
  msg:string;
begin
//msg:=grabThisText;
msg := thisChat.input.text;
if trim(msg) = '' then
  begin
  msgDlg('Can''t send an empty message', True, mtWarning);
  exit;
  end;
wnd:= TselectCntsFrm.doAll(MainDlg.RnQmain,
                              'Send multiple', 'Send message',
                              Account.AccProto,
                              Account.AccProto.readList(LT_ROSTER).clone.add(notinlist),
                              sendMessageAction,
                              [sco_multi,sco_groups,sco_predefined],
                              @wnd
                              );
wnd.toggle(thisContact);
//  theme.getIco2(PIC_MSG, wnd.icon);
  theme.pic2ico(RQteFormIcon, PIC_MSG, wnd.icon);
//wnd.extra:=Tincapsulate.aString(msg);
inputChange(self);
end;

procedure TchatFrm.sendMessageAction(sender:Tobject);
var
  wnd:TselectCntsFrm;
  cl:TRnQCList;
  msg:string;
begin
  msg := grabThisText;
  wnd:=(sender as Tcontrol).parent as TselectCntsFrm;
  //msg:=(wnd.extra as Tincapsulate).str;
  cl:=wnd.selectedList;
  wnd.extra.free;
  wnd.close;
  with cl do
   begin
    resetEnumeration;
    while hasMore do
     Proto_Outbox_add(OE_msg, getNext, IF_multiple, msg);
   end;
  cl.free;
end; // sendmessage action

procedure TchatFrm.del1Click(Sender: TObject);
var
  st,en:integer;
begin
with thisChat.historyBox do
  begin
  if not wholeEventsAreSelected then exit;
  st:=startSel.evIdx;
  en:=endSel.evIdx;
  if st > en then swap4(st,en);
//  chatFrm.visible:=FALSE;
  Visible := false;
//  history.deleteFromTo(userPath+historyPath + thisContact.uid, st,en);
  history.deleteFromTo(thisContact.uid, st,en);
  Visible := True;
//  chatFrm.visible:=TRUE;
  deselect();
  thischat.repaintAndUpdateAutoscroll();
  end;
end;

procedure TchatFrm.lsbEnter;
begin
  if not popupLSB then exit;
  with thisChat.lsb do
   if not entering then
     begin
      if position = 0 then
        hideScrollTimer:=10
     end
   else
     begin
      hideScrollTimer:=0;
      width:=maximizedScroll;
     end;
end;

procedure TchatFrm.Closeall1Click(Sender: TObject);
begin closeAllPages end;

procedure TchatFrm.Closeallbutthisone1Click(Sender: TObject);
var
  i,sel:integer;
begin
try
  pagectrl.hide;
  sel:=pageIndex;
  for i:=chats.count-1 downto 0 do
    if i<>sel then
      closePageAt(i);
finally
  pagectrl.show;
end;
end;

procedure TchatFrm.CloseallOFFLINEs1Click(Sender: TObject);
var
  i:integer;
  c:TRnQcontact;
begin
 c:=thisContact;
 try
  pagectrl.hide;
  for i:=chats.count-1 downto 0 do
   if chats.byIdx(i).chatType = CT_IM then
    if chats.byIdx(i).who.isOffline then
      closePageAt(i);
 finally
  pagectrl.show;
  select(c);
 end;
end;

function TchatFrm.grabThisText:string;
begin
result:=thisChat.input.text;
thisChat.input.text:='';
// update char counter
inputChange(self);
end; // grabThisText

procedure TchatFrm.send;
var
  s,s1:string;
  max:integer;
  flag : Integer;
  ch : TchatInfo;
begin
  enterCount:=0;
  flag := 0;
//  if SimplMsgBtn.Down then
//    flag := IF_Simple;
  ch := thisChat;
  if (ch = nil)or(ch.who = nil) THEN Exit;

  max:= ch.who.fProto.maxCharsFor(ch.who);
  if length(ch.input.text) > max then
   if MessageDlg(getTranslation('Your message is too long. Max %d characters.\n\n                       Split the message?',[max]),
                mtInformation, [mbYes, mbNo], 0)=mrYes then
  begin
    s:=grabThisText;
    repeat
      s1:=copy(s,1,max-1);
      delete(s,1,max-1);
      send(flag,s1);
    until length(s)<max;
    send(flag,s);
    exit;
  end else
else
  begin
    s:=grabThisText;
    if trim(s)='' then
      begin
       if closeChatOnSend then
        close
      end
    else
      send(flag,s) end;
end; // send

procedure TchatFrm.send(flags_:integer; msg:string='');
begin
  if (thisChat=NIL) or not sendBtn.Enabled then exit;
  if msg='' then
    msg:=grabThisText;
  if trim(msg) = '' then
    begin
    msgDlg('Can''t send an empty message', True, mtWarning);
    exit;
    end;
  sawAllhere;
  Proto_Outbox_add(OE_msg, thisChat.who, flags_, msg);
  thisChat.input.setFocus;
  if thisChat.single then
   begin
    if ClosePageOnSingle then
      closeThisPage
     else 
      close;
   end;
end; // send

procedure TchatFrm.select(c:TRnQcontact);
var
  i:integer;
begin
if c=NIL then exit;
i:=chats.idxOf(c);
if i >= 0 then setTab(i);
end; // select

procedure TchatFrm.flash;
var
	rec:FLASHWINFO;
begin
//if doFlashChat then
 begin
  rec.cbSize:=sizeOf(rec);
  rec.hwnd:=handle;
  rec.dwFlags:=FLASHW_CAPTION OR FLASHW_TRAY OR FLASHW_TIMERNOFG;
  rec.dwTimeout:=0;
  rec.uCount:=dword(-1);
  flashWindowEx(rec);
 end;
end; // flash

procedure TchatFrm.chatsendmenuopen1Click(Sender: TObject);
var
  i:integer;
  s:string;
begin
 if (thisChat=NIL) or not sendBtn.Enabled then exit;
 s:=grabThisText;
 if trim(s) = '' then
  begin
  msgDlg('Can''t send an empty message', True, mtWarning);
  exit;
  end;
  for i:=0 to chats.count-1 do
   if chats.byIdx(i).chatType = CT_IM then
     Proto_Outbox_add(OE_msg, chats.byIdx(i).who, IF_multiple, s);
  thisChat.input.setFocus;
end;

procedure TchatFrm.chatcloseignore1Click(Sender: TObject);
begin
  sawAllHere;
  addToIgnoreList(thisContact);
  if messageDlg(getTranslation('Do you want to remove %s from your contact list?', [thischat.who.displayed]), mtConfirmation, [mbYes,mbNo], 0) = mrYes then
    removeFromRoster(thisContact);
  closeThisPage;
end;

function TchatFrm.Pages2String : RawByteString;
var
//  cl:TRnQCList;
  i:integer;
begin
  if (userTime < 0) and (chats.count=0) then
    result := PagesEnumStr
   else
    begin
//      cl:=TRnQCList.create;
      Result := '';
      for i:=0 to chats.count-1 do
       if chats.byIdx(i).chatType = CT_IM then
        begin
//          cl.add(chats.byIdx(i).who);
           result:=result + StrToUTF8(chats.byIdx(i).who.UID) + CRLF;
        end;
//      result := cl.toString;
//      cl.free;
    end;
end;

procedure TchatFrm.savePicMnuClick(Sender: TObject);
var
 pic : AnsiString;
 p : string;
 i, k : Integer;
 RnQPicStream //, RnQPicStream2
   : TMemoryStream;
// fmt : TGUID;
begin
  with thisChat.historyBox do
//   if pointedItem.kind=PK_RQPICEX then
   if clickedItem.kind=PK_RQPICEX then
    begin
      pic := clickedItem.ev.getBodyBin;
      i := Pos(RnQImageExTag, pic);
      k := PosEx(RnQImageExUnTag, pic, i+12);
      if (i > 0) and (k > 5) then
      begin
            pic:=Base64DecodeString(Copy(pic, i+12, k-i-12));
//            pic := '';
            RnQPicStream := TMemoryStream.Create;
            RnQPicStream.Write(pic[1], Length(pic));
            pic := '';
            p := PAFormat[DetectFileFormatStream(RnQPicStream)];
           Delete(p, 1, 1);
           p:=openSavedlg(self, '', false, p);
           if p > '' then
             RnQPicStream.SaveToFile(p);
           RnQPicStream.Free;
      end
    end
   else
   if clickedItem.kind=PK_RQPIC then
    begin
      pic := clickedItem.ev.getBodyBin;
      i := Pos(RnQImageTag, pic);
      k := PosEx(RnQImageUnTag, pic, i+10);
      if (i > 0) and (k > 5) then
      begin
        p:=openSavedlg(self, '', false, 'wbmp');
        if p > '' then
         begin
           RnQPicStream := TMemoryStream.Create;
           RnQPicStream.Write(pic[i+10], k-i-10);
           RnQPicStream.SaveToFile(p);
           RnQPicStream.Free;
         end;
      end
    end;
end;

procedure TchatFrm.loadPages(const s : RawByteString);
var
  i:integer;
  s1 : RawByteString;
  ofs : Integer;
  len : Integer;
begin
 ofs := 1;
// i := 1;
 len := Length(s);
 while ofs<Len do
  begin
    i:=posEx(AnsiString(#10),s, ofs);
    if (i>1) and (s[i-1]=#13) then
      dec(i);
    if i=0 then
      i:= Len+1;
    s1 := copy(s, ofs, i-ofs);
    try
      openOn(contactsDB.add(Account.AccProto, UTF8ToStr(s1)), True, False);
     except
//      result:=FALSE
    end;
    if s[i]=#13 then
      inc(i);
  //  system.delete(s,1,i);
    ofs := i+1;
  end;
//  cl.fromString(Account.AccProto, s, contactsDB);
  open(True);
end; // loadPages

procedure TchatFrm.closeBtnClick(Sender: TObject);
begin
sawAllHere;
closeThisPage
end;

procedure TchatFrm.prefBtnClick(Sender: TObject);
//var
//  i : Byte;
begin
  showForm(WF_PREF, 'Chat', vmShort);

{for i := 0 to length(prefPages)-1 do
 if prefPages[i].Cptn = 'Chat' then break;
prefFrm.SetViewMode(vmShort);
prefFrm.pagesBox.ItemIndex:=i;
prefFrm.pagesBoxClick(NIL); }
end;

procedure TchatFrm.prefBtnMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbRight then
   showForm(WF_PREF, 'Plugins', vmShort);
end;

   {$IFDEF USE_SMILE_MENU}
procedure TchatFrm.smilesMenuPopup(Sender: TObject);
//var
// r : TRect;
begin
  if smile_theme_token <> theme.token then
   begin
    addSmilesToMenu(self,smileMenuExt.Items,addSmileAction);
    smile_theme_token := theme.token;
   end;
//  if GetWindowRect(smileMenuExt.WindowHandle, r) then
//   GPFillGradient(GetWindowDC(smileMenuExt.WindowHandle), r, theme.GetAColor('menu.fade1', clMenuBar),
//                  theme.GetAColor('menu.fade2', clMenu));
end;

procedure TchatFrm.smilesMenuClose(Sender: TObject);
begin
//  smileMenuExt.Items.Clear;
 theme.ClearAniMNUParams;
///...
end;
   {$ENDIF USE_SMILE_MENU}

procedure TchatFrm.addSmileAction(sender:Tobject);
begin
 thisChat.input.SelText:=TRQmenuitem(sender).ImageName;
end;

procedure TchatFrm.histmenuPopup(Sender: TObject);
begin
 chatshowlsb1.checked:=showLSB;
 chatpopuplsb1.visible:=showLSB;
 chatpopuplsb1.checked:=popupLSB;
end;

procedure TchatFrm.chatshowlsb1Click(Sender: TObject);
begin setLeftSB(not showLSB) end;

procedure TchatFrm.setLeftSB(visible:boolean);
var
  ch : TChatInfo;
begin
  showLSB:=visible;
  ch := thisChat;
  if (ch <> NIL)and(ch.lsb <> NIL) then
    ch.lsb.visible:=showLSB;
end;

procedure TchatFrm.chathide1Click(Sender: TObject);
begin setLeftSB(FALSE) end;

procedure TchatFrm.chatpopuplsb1Click(Sender: TObject);
begin
popupLSB:=not popupLSB;
updateGraphics;
end;

procedure TchatFrm.FormMouseWheelUp(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
var
  p : TPoint;
  ch : TchatInfo;
begin
 ch := thisChat;
 if Assigned(ch) then
 with ch do
 if chatType = CT_IM then
  begin
   p := input.ScreenToClient(MousePos);
 //  if Assigned(inputPnl) then
   if (p.X > 0) and (p.Y > 0) and
      (p.X < input.Width) and (p.Y < input.height)
      and (input.Lines.Count > 1)
    then
      Exit;
   if Assigned(CLPanel) and docking.Docked2chat then
    begin
     p := CLPanel.ScreenToClient(MousePos);
     if (p.X > 0) and (p.Y > 0) and
        (p.X < CLPanel.Width) and (p.Y < CLPanel.height)
  //      and (input.Lines.Count > 1)
      then
        Exit;
    end;

   if GetKeyState(VK_CONTROL) and $8000 > 0 then
     historyBox.histScrollLine(-wheelVelocity)
    else
     historyBox.histScrollEvent(-wheelVelocity);
   Handled := True;
  end;
end;

procedure TchatFrm.FormMouseWheelDown(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
var
  p : TPoint;
  ch : TchatInfo;
begin
 ch := thisChat;
 if Assigned(ch) then
 with ch do
 if chatType = CT_IM then
  begin
   p := input.ScreenToClient(MousePos);
   if (p.X > 0) and (p.Y > 0) and
      (p.X < input.Width) and (p.Y < input.height)
      and (input.Lines.Count > 1)
    then Exit;
   if Assigned(CLPanel) and docking.Docked2chat then
    begin
     p := CLPanel.ScreenToClient(MousePos);
     if (p.X > 0) and (p.Y > 0) and
        (p.X < CLPanel.Width) and (p.Y < CLPanel.height)
  //      and (input.Lines.Count > 1)
      then
        Exit;
    end;
   if GetKeyState(VK_CONTROL) and $8000 > 0 then
     historyBox.histScrollLine(+wheelVelocity)
    else
     historyBox.histScrollEvent(+wheelVelocity);
   Handled := True;
  end;
end;

procedure TchatFrm.onHistoryRepaint(sender:TObject);
var
  ch:TchatInfo;
begin
  ch:=thischat;
  if Assigned(ch) then
  if ch.chatType = CT_IM then
  begin
    autoscrollBtn.down:=ch.historyBox.autoScrollVal;
    ch.historyBox.updateRSB(false);
    ch.updateLSB;
  end;
end; // onHistoryRepaint

procedure TchatFrm.addcontactAction(sender:Tobject);
var
  cnt : TRnQContact;
begin
  cnt :=  Account.AccProto.getContact(selectedUIN);
  if Assigned(cnt) then
    addToRoster( cnt, (sender as Tmenuitem).tag, cnt.CntIsLocal)
end;

procedure TchatFrm.pagectrl00MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
if button = mbRight then
  begin
  clickedContact := thisContact;
  if clickedContact <> NIL then
    with mousepos do MainDlg.RnQmain.contactMenu.popup(x,y)
  end
end;


procedure TchatFrm.AvtsplitterMoving(Sender: TObject; var NewSize: Integer; var Accept: Boolean);
begin
  Accept := NewSize > 0;
end;

procedure TchatFrm.AvtSplitterMoved(Sender: TObject);
//var
//  ch : TchatInfo;
begin
  with thisChat do
   if Assigned(avtPic.AvtPBox) then
    if avtsplitr.Left > avtPic.AvtPBox.Left then
     avtsplitr.Left := avtPic.AvtPBox.Left - 1;
end;

var
	// backup the values of autoscroll in the current chat
  bakAutoScroll:boolean;

procedure TchatFrm.splitterMoving(Sender: TObject; var NewSize: Integer; var Accept: Boolean);
begin bakAutoScroll:=thisChat.historyBox.autoScrollVal end;

procedure TchatFrm.SplitterMoved(Sender: TObject);
begin
 with thisChat do
 begin
//   historyBox.autoScrollVal :=bakAutoScroll;
   if Assigned(inputPnl) then
     splitY := inputPnl.height
   else
     splitY := input.height
 end;
 formresize(self);
end; // splitterMoved


procedure TchatFrm.pagectrlDragDrop(Sender, Source: TObject; X, Y: Integer);
const
  TCM_GETITEMRECT = $130A;
var
  i: Integer;
  oldTabindex, tabindex: integer;
//  r: TRect;
  p: TchatInfo;
begin
  if not (Sender is TPageControl) then Exit;
  	//получаем таб под курсором
  tabindex := pagectrl.IndexOfTabAt(X, Y);
  oldTabindex := pagectrl.ActivePageIndex;
  if tabindex = oldTabindex then Exit;
  if tabindex < oldTabindex then
    begin
     p := chats[oldTabindex];
     for I := oldTabindex-1 downto tabindex do
      begin
       chats[i+1] := chats[i];
       pagectrl.Pages[i+1].PageIndex := i;
      end;
     chats[Tabindex] := p;
    end
   else
    begin
     p := chats[oldTabindex];
     for I := oldTabindex to tabindex-1 do
      begin
       chats[i] := chats[i+1];
       pagectrl.Pages[i].PageIndex := i+1;
      end;
     chats[Tabindex] := p;
    end;
  //поменяем сведения о чате в активной закладке и в той, на которую навели мышь

  p := chats[tabindex];
	chats[tabindex] := chats[pagectrl.ActivePageIndex];
	chats[pagectrl.ActivePageIndex] := p;


  //устанавливаем таб под курсором в качестве активного
	pagectrl.Pages[pagectrl.ActivePageIndex].PageIndex := tabindex;
{
  with pagectrl do
  begin
    for i := 0 to PageCount - 1 do
    begin
      Perform(TCM_GETITEMRECT, i, lParam(@r));
      if PtInRect(r, Point(X, Y)) then
      begin
        if i <> ActivePage.PageIndex then
          ActivePage.PageIndex := i;
        Exit;
      end;
    end;
  end;
}
end;

procedure TchatFrm.pagectrlDragOver(Sender, Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
var
  i : Integer;
begin
  Accept := False;
//  if (sender is TTabSheet)and (Source is TTabSheet) then
   begin
     i := pagectrl.IndexOfTabAt(X, Y);
//     i:=pageIdxAt(x,y);
//     if i <> TTabSheet(Source).TabIndex then
     if i <> pagectrl.ActivePageIndex then
       Accept := True;
   end
//  else
//    Accept := False;

//  if Sender is TPageControl then
//    Accept := True;

end;

procedure TchatFrm.pagectrlDrawTab(Control: TCustomTabControl;
  TabIndex: Integer; const Rect: TRect; Active: Boolean);
var
  R : Trect;
  c:TRnQcontact;
  ev:Thevent;
  themePage: TThemedTab;
//  themePage: TThemedButton;
  Details: TThemedElementDetails;
//  oldMode: Integer;
  ci : TchatInfo;
  ss  : String;
  p : TPicName;
  fl : Cardinal;
  hnd : HDC;
//  ImElm  : TRnQThemedElementDtls;
  Pic : TPicName;
//  i  : Integer;
begin
// Exit;
  ci := chats.byIdx(tabindex);
  if ci = NIL then Exit;
  c := ci.who;
  R := rect;
//    control.Canvas.Brush.Color := clBlue;
//     control.Canvas.fillrect(r);
//  dec(r.Left, 2);
//  inc(r.Right, 1);
 hnd := control.Canvas.Handle;
 with control.Canvas do
  begin
  if ThemeServices.ThemesEnabled then
    begin
//      fillrect(r);
//      if Parent.DoubleBuffered then
//        PerformEraseBackground(Control, control.Canvas.Handle)
//      else
//        ThemeServices.DrawParentBackground(Control.Handle, control.Canvas.Handle, nil, False)
;
//      inc(r.Left, 2);
//      dec(r.Right, 2);
      inc(r.Top, 1);
//      dec(r.Top, 1);
      if not active then
        inc(r.Right, 1);

//      inc(r.Top, 1);
      fl := BF_LEFT or BF_RIGHT or BF_TOP;
      if active then
        begin
          themePage := ttTopTabItemSelected; //ttTabItemSelected
        end
       else
        begin
          themePage := ttTopTabItemNormal; //ttTabItemNormal;
          inc(fl, BF_BOTTOM);
          dec(r.Left, 2);
          inc(r.Bottom, 3);
        end;
{      if active then
        themePage := ttTopTabItemBothEdgeSelected
       else
        themePage := ttTopTabItemBothEdgeNormal;

//      themePage := tpPageRoot;
      if active then
        themePage := ttTabItemLeftEdgeSelected //ttTabItemSelected
       else
        themePage := ttTabItemLeftEdgeNormal //ttTabItemNormal;}
;
      Details := ThemeServices.GetElementDetails(themePage);
      ThemeServices.DrawElement(hnd, Details, r);
      ThemeServices.DrawEdge(hnd, Details, r, 1, fl);//BF_RECT );
{      rC.Left   := r.Right - 10;
      rC.Right  := rC.Left + 8;
      rC.Top    := r.Top + 2;
      rC.Bottom := rC.Top + 8;
      Details := ThemeServices.GetElementDetails(twSmallCloseButtonNormal);
      ThemeServices.DrawElement(Handle, Details, rC);
}
//      ThemeServices.DrawEdge(Handle, Details, r, 1, BF_LEFT or BF_RIGHT or BF_TOP);

//      Details := ThemeServices.GetElementDetails(themePage);
//      ThemeServices.DrawElement(Handle, Details, r);
//      control.Canvas.MoveTo(r.Left, r.Top);
//      control.Canvas.LineTo(r.Right, r.Bottom);
//      r := ThemeServices.ContentRect(Canvas.Handle, Details, r);
    end
   else
    begin
      fillrect(r);
    end;
  inc(r.left,4);
  inc(r.top, 4);
  dec(r.right); //dec(r.bottom);

//  oldMode:=
 SetBKMode(hnd, TRANSPARENT);
  if ci.chatType = CT_IM then
  begin
    ev:=eventQ.firstEventFor(c);
    if (ev<>NIL) //then
//      begin
//      if
      and ((blinking or c.fProto.getStatusDisable.blinking) or not blinkWithStatus) then
       begin
        if (blinking or c.fProto.getStatusDisable.blinking) then
          inc(R.left, 1 + ev.Draw(hnd, R.left,R.top).cx)
        else
          inc(R.left, 1 + ev.PicSize.cx);
       end
    else
     begin
       {$IFDEF RNQ_FULL}
        if c.typing.bIsTyping then
//          inc(R.left, 1+theme.drawPic(hnd, R.left,R.top, PIC_TYPING).cx)
          pic := PIC_TYPING
        else
       {$ENDIF}
        if showStatusOnTabs then
         begin
          {$IFDEF RNQ_FULL}
           {$IFDEF CHECK_INVIS}
           if c.isInvisible and c.isOffline then
             pic := status2imgName(byte(SC_ONLINE), True)
  //         with theme.GetPicSize('')
//            inc(R.left, 1+ statusDrawExt(hnd, R.left,R.top, byte(SC_ONLINE), True).cx)
           else
  //           theme.drawPic(control.canvas, R.left,R.top, status2imgName(SC_ONLINE, True)).cx);
           {$ENDIF}
          {$ENDIF}
             pic := c.statusImg;
         end;
       inc(R.left, 1 + theme.drawPic(hnd, R.left,R.top, Pic).cx)
     end;
    if active then
      p := 'chat.tab.active'
     else
      p := 'chat.tab.inactive';
    theme.ApplyFont(p, control.Canvas.Font);

    if UseContactThemes and Assigned(ContactsTheme) then
     begin
      ContactsTheme.ApplyFont(TPicName('group.') + TPicName(AnsiLowerCase(groups.id2name(c.group))) + '.'+p, control.Canvas.Font);
      ContactsTheme.ApplyFont(TPicName(c.UID2cmp) + '.'+p, control.Canvas.Font);
     end;
 hnd := control.Canvas.Handle;

  //  Font.Style := Font.Style + [fsStrikeOut];
//    inc(r.top, 2);
    dec(r.Right);

      if active then
       begin
//        inc(r.top, 2);
//        inc(R.left,2);
         dec(R.Bottom, 2);
       end
      else
       ;

//      oldMode:=
//      SetBKMode(control.Canvas.Handle, TRANSPARENT);
//    TextRect(r, r.Left, r.Top, c.displayed);
//      i := TextHeight(c.displayed);
//    TextRect(r, r.Left, r.Top, );
//    TextOut(r.Left, r.Top, c.displayed);
//    textoutExt
//      ss := c.displayed;
        ss := dupAmperstand(c.displayed);
//      Windows.ExtTextOut(control.Canvas.Handle, r.Left, r.Top, ETO_CLIPPED, @R, PChar(s), Length(s), nil);
      DrawText(hnd, PChar(ss), Length(ss), r,
              DT_LEFT or DT_SINGLELINE or DT_VCENTER);// or DT_ DT_END_ELLIPSIS);
//         textOut(handle, x,y, , j);
//         SetBKMode(Handle, oldMode);
  //  DrawText(Handle, PChar(dupAmperstand(c.displayed)), -1, R, DT_SINGLELINE or DT_WORD_ELLIPSIS{or DT_CENTER or DT_VCENTER});
  //  Font.Style := Font.Style - [fsStrikeOut];
  end
  else
    begin
      inc(R.left, 1+theme.drawPic(hnd, R.left,R.top, 'plugintab' + IntToStrA(chats.byIdx(tabindex).id)).cx);
//      oldMode:= SetBKMode(Handle, TRANSPARENT);
      inc(r.top, 2);
      TextOut(r.Left, r.Top, ci.lastInputText);
//            textOut(handle, x,y, , j);
//      SetBKMode(Handle, oldMode);
    end;
 {
   procedure TCustomTabControl.UpdateTabSize;
  begin
    SendMessage(Handle, TCM_SETITEMSIZE, 0, Integer(FTabSize));
    TabsChanged;
  end;

  procedure TCustomTabControl.UpdateTabImages;
  var
    I: Integer;
    TCItem: TTCItem;
  begin
    TCItem.mask := TCIF_IMAGE;
    for I := 0 to FTabs.Count - 1 do
    begin
      TCItem.iImage := GetImageIndex(I);
      if SendMessage(Handle, TCM_SETITEM, I,
        Longint(@TCItem)) = 0 then
        TabControlError(Format(sTabFailSet, [FTabs[I], I]));
    end;
    TabsChanged;
  end;
 }
  end;
{
  if TabIndex < 9 then
   begin
//     s := intToStr(TabIndex);
//     Control.f
     i := control.Canvas.Font.Size;
     control.Canvas.Font.Height := 3;
     control.Canvas.Font.Size := 1;
     control.Canvas.TextOut(r.Right - 8, r.Top, intToStr(TabIndex));
     control.Canvas.Font.Size := i;
   end;
}   
end;

procedure TchatFrm.ShowTabHint(X, Y: integer);
var
  bmp:Tbitmap;
  r: TRect;
  hintdata: TVTHintData;
  tabindex: integer;
  ch : TchatInfo;
begin
  if not ShowHintsInChat then Exit;
  //на всякий случай, убедимся, что старое окно уничтожено
  FreeAndNil(hintwnd);

  //получим индекс закладки
  tabindex := pagectrl.IndexOfTabAt(X, Y);
  ch := NIL;
  if chats.validIdx(tabindex) then
    ch := TchatInfo(chats[tabindex]);
  if not Assigned(ch) then
    Exit;
  if (tabindex < 0)or (ch.chatType = CT_PLUGING) then
		exit;

  if not (Assigned(ch.who.data) and Assigned(TCE(ch.who.data^).node)) then
    Exit;

  //сместим хинт чуть правее и ниже
  X := X + 10;
  Y := Y + 10;

  //вычислим размеры хинта - результат вернется в r
  bmp := createBitmap(1,1);
  bmp.Canvas.Font := Screen.HintFont;
{  r.Left := 0;
  r.Top := 0;
  r.Right := 200;
  r.Bottom := 200;}
//   if ShowHintsInChat2 then
//     chats.byIdx(tabindex).historyBox.paintOn(bmp.Canvas, r, True)
//    else
     drawHint(bmp.canvas, NODE_CONTACT, 0, ch.who, r, True);
//  drawNodeHint(bmp.canvas, TCE(chats.byIdx(tabindex).who.data^).node.treenode, r);
  bmp.free;

	//подготовим данные для отрисовки хинта
  hintdata.HintRect := r;
	hintdata.Tree := MainDlg.RnQmain.roster;

  if Assigned(ch.who.data) and Assigned(TCE(ch.who.data^).node) then
    hintdata.Node := TCE(ch.who.data^).node.treenode
   else
    hintdata.Node := NIL;
  hintdata.HintText := '';
  hintdata.Column := -1;

  r.Left   := r.Left + X;
  r.Top    := r.Top + Y;
  r.Right  := r.Right + X;
  r.Bottom := r.Bottom + Y;
  //переводим прямоугольник хинта к координатам экрана
  //pagectrl.Pages[tabindex].ClientRect.Right
  r.TopLeft :=  pagectrl.ClientToScreen(r.TopLeft);
  r.BottomRight := pagectrl.ClientToScreen(r.BottomRight);

  //и создадим новое
  hintwnd := TVirtualTreeHintWindow.Create(chatFrm);
 	hintwnd.CalcHintRect(10, '', @hintdata); //а эта функция нужна не для того,
  // чтобы рассчитать r, как можно было подумать, а лишь для того, чтобы
  //  передать окну @hintdata

	hintwnd.ActivateHint(r, '');
end;

procedure TchatFrm.pagectrlMouseLeave(Sender: TObject);
var
  hw : TVirtualTreeHintWindow;
begin
  hw := hintwnd;
  hintwnd := NIL;
  if hw <> nil then
    try
      hw.Free;
     except
    end
end;

procedure TchatFrm.pagectrlMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
//  bmp:Tbitmap;
//  r: TRect;
//  hintdata: TVTHintData;
  tabindex: integer;
  MousePos: TPoint;
  //окно хинта для отображения на закладках окна чата
begin
  if Assigned(pagectrl) then
    tabindex := pagectrl.IndexOfTabAt(X, Y)
   else
    tabindex := 0;
  if tabindex < 0 then
  	exit;
  //ShowTabHint(X, Y);
  if hintwnd <> nil then
   begin
    //если хинт существует, переместим его обновим для нового таба
    if (tabindex <> last_tabindex) then
     begin
      if (TchatInfo(chats[tabindex]).chatType = CT_PLUGING) then
       FreeAndNil(hintwnd)
      else
       begin
        last_tabindex := tabindex;
//        MousePos := pagectrl.ScreenToClient(Mouse.CursorPos);
        ShowTabHint(X, Y)
       end;
     end;
    if Assigned(hintwnd) then
     begin
//       hintwnd.Left := Mouse.CursorPos.X + 10;
//       hintwnd.Top := Mouse.CursorPos.Y + 10;
     end;

    //поставим таймер на отключение хинта
    //SetTimer(Handle, HintTimer, 100, nil);
   end
  else
    begin
      //если хинт не существет, запустим таймер для его создания
//      SetTimer(Handle, HintTimer, 500, nil);
     MousePos := pagectrl.ScreenToClient(Mouse.CursorPos);

    //вычислим номер таба под курсором
    //tabindex := pagectrl.IndexOfTabAt(MousePos.X, MousePos.Y);

    //если мышь вышла за пределы контрола, удалим хинт
     if pagectrl.IndexOfTabAt(MousePos.X, MousePos.Y) < 0 then
       FreeAndNil(hintwnd)
      else
       begin
         //если хинта еще нет или поменялся таб, создадим новое окно хинта
         if (hintwnd = nil) {or (pagectrl.IndexOfTabAt(MousePos.X, MousePos.Y) <> last_tabindex)} then
          ShowTabHint(MousePos.X, MousePos.Y);
       end;
    end;

  //запомним координаты и номер таба
  LastMousePos.X := X;
  LastMousePos.Y := Y;
{

  tabindex := pagectrl.IndexOfTabAt(X, Y);
  if tabindex < 0 then
   begin
    FreeAndNil(hintwnd);
    hintTab := -1;
    exit;
   end;
  if (tabindex <> hintTab) then
   begin
    FreeAndNil(hintwnd);
    hintTab := -1;
//    exit;
   end;
  if (tabindex = hintTab) then
   Exit;

  hintTab := tabindex;
  r.Left := 0;
  r.Top := 0;
  r.Right := 0;
  r.Bottom := 0;

  bmp := createBitmap(1,1);
  bmp.Canvas.Font := Screen.HintFont;
  drawNodeHint(bmp.canvas, TCE(chats.byIdx(tabindex).who.data^).node.treenode, r);
  bmp.free;

  hintdata.HintRect := r;
	hintdata.Tree := MainDlg.RnQmain.roster;
  hintdata.Node := TCE(chats.byIdx(tabindex).who.data^).node.treenode;
  hintdata.HintText := '';
  hintdata.Column := -1;

  hintwnd := TVirtualTreeHintWindow.Create(chatFrm);
 	hintwnd.CalcHintRect(10, '', @hintdata);

  r.Left := r.Left + X + 20;
  r.Top := r.Top + Y + 20;
  r.Right := r.Right + X + 20;
  r.Bottom := r.Bottom + Y + 20;
  r.BottomRight := ClientToScreen(r.BottomRight);
  r.TopLeft := ClientToScreen(r.TopLeft);

	hintwnd.ActivateHintData(r, '', @hintdata);
// 	hintwnd.Free;
 }
end;

(*
procedure TchatFrm.pagectrlDrawTab(Control: TCustomTabControl;
  TabIndex: Integer; const Rect: TRect; Active: Boolean);
var
  R : Trect;
  c:Tcontact;
  ev:Thevent;
  themePage: TThemedTab;
//  themePage: TThemedButton;
  Details: TThemedElementDetails;
//  oldMode: Integer;
  ci : TchatInfo;
  dc  : HDC;
  ABitmap : HBITMAP;
  j : Integer;
//  fullR : TRect;
begin
  ci := chats.byIdx(tabindex);
  if ci = NIL then Exit;
  c := ci.who;
  R := rect;
  j := 0;
//with control.Canvas do
  try
    DC := CreateCompatibleDC(control.Canvas.Handle);
    with r do
    begin
      ABitmap := CreateCompatibleBitmap(control.Canvas.Handle, Right-Left, Bottom-Top);
      if (ABitmap = 0) and (Right-Left + Bottom-Top <> 0) then
        raise EOutOfResources.Create('Out of Resources');
      SelectObject(DC, ABitmap);
      SetWindowOrgEx(DC, Left, Top, Nil);
    end;
  finally

  end;

  begin
  if ThemeServices.ThemesEnabled then
    begin
      fillrect(DC, r, Control.Brush.Handle);
      inc(r.Left, 2);
//      dec(r.Right, 2);
//      inc(r.Top, 2);

      inc(r.Top, 1);
      if active then
        themePage := ttTopTabItemSelected //ttTabItemSelected
       else
        themePage := ttTopTabItemNormal //ttTabItemNormal;
;
      Details := ThemeServices.GetElementDetails(themePage);
      ThemeServices.DrawElement(DC, Details, r);
      ThemeServices.DrawEdge(DC, Details, r, 1, BF_LEFT or BF_RIGHT or BF_TOP);
    end
   else
    begin
      fillrect(DC, r, Control.Brush.Handle);
    end;
      inc(r.left,4); inc(r.top,4);
      dec(r.right); //dec(r.bottom);
      if active then
       begin
        inc(r.top, 2);
        inc(R.left,2);
       end;

//  oldMode:=
SetBKMode(Handle, TRANSPARENT);
  if ci.chatType = CT_ICQ then
  begin
    ev:=eventQ.firstEventFor(c);
    if (ev<>NIL) //then
//      begin
//      if
      and (blinking or onStatusDisable[icq.myinfo.status].blinking) then
        inc(R.left, 1 + theme.drawPic(DC, R.left,R.top, ev.pic,
                ev.themeTkn, ev.picLoc, ev.picIdx).cx)
{       else
        inc(R.left, 1 + Theme.getPicSize(ev.pic,
                ev.themeTkn, ev.picLoc, ev.picIdx).cx);
      end}
    else
     {$IFDEF RNQ_FULL}
      if c.typing.bIsTyping then
        inc(R.left, 1+theme.drawPic(DC, R.left,R.top, PIC_TYPING).cx)
      else
     {$ENDIF}
      if showStatusOnTabs then
        inc(R.left, 1+statusDrawExt(DC, R.left,R.top, c.status, c.invisible, c.xStatus).cx);
    {$IFDEF RNQ_FULL}
     {$IFDEF CHECK_INVIS}
    if c.invisibleState > 0 then
     inc(R.left, 1+ statusDrawExt( DC, R.left,R.top, SC_ONLINE, True).cx);
//           theme.drawPic(control.canvas, R.left,R.top, status2imgName(SC_ONLINE, True)).cx);
     {$ENDIF}
    {$ENDIF}
  //  Font.Style := Font.Style + [fsStrikeOut];
//         TextOut(r.Left, r.Top, c.displayed);
         windows.TextOut(DC, r.Left, r.Top, PAnsiChar(c.displayed), j);
//         textOut(handle, x,y, , j);
//         SetBKMode(Handle, oldMode);
  //  DrawText(Handle, PChar(dupAmperstand(c.displayed)), -1, R, DT_SINGLELINE or DT_WORD_ELLIPSIS{or DT_CENTER or DT_VCENTER});
  //  Font.Style := Font.Style - [fsStrikeOut];
  end
  else
    begin
      inc(R.left, 1+theme.drawPic(control.canvas.Handle, R.left,R.top, 'plugintab' + IntToStr(chats.byIdx(tabindex).id)).cx);
//      oldMode:= SetBKMode(Handle, TRANSPARENT);
//      TextOut(r.Left, r.Top, ci.lastInputText);
           windows.TextOut(DC, r.Left, r.Top, PAnsiChar(ci.lastInputText), j);
//      SetBKMode(Handle, oldMode);
    end;
  end;
  BitBlt(Control.Canvas.Handle, rect.Left, rect.Top,
    rect.Right - rect.Left, rect.Bottom - rect.Top,
    dc, rect.Left, rect.Top, SrcCopy);

  DeleteObject(ABitmap);
  DeleteDC(DC);
end; *)

procedure TchatFrm.ANothingExecute(Sender: TObject);
begin
//
end;

procedure TchatFrm.hAchatshowlsbUpdate(Sender: TObject);
begin // 3011
 with TAction(Sender) do
  if showLSB then
     HelpKeyword:=PIC_RIGHT
   else
     HelpKeyword:='';
//    TAction(Sender).HelpKeyword := PIC_CHECKED
//   else
//    TAction(Sender).HelpKeyword := PIC_UNCHECKED;
//  TAction(Sender).HelpKeyword := PIC_CHECK_UN[showLSB];
end;

procedure TchatFrm.hAShowSmilesExecute(Sender: TObject);
var
  ch :TchatInfo;
begin
//  useSmiles := TAction(Sender).Checked;
  useSmiles := not useSmiles;
  ch:=thischat;
  if ch=NIL then exit;
  ch.historyBox.ManualRepaint;
//  inc(ch.historyBox.history.Token);
//  ch.repaint;
end;

procedure TchatFrm.hAShowSmilesUpdate(Sender: TObject);
begin
 with TAction(Sender) do
  begin
    Checked := useSmiles;
    if useSmiles then
       HelpKeyword:=PIC_RIGHT
     else
       HelpKeyword:='';
  end;
end;

procedure TchatFrm.hAViewInfoExecute(Sender: TObject);
begin
  with thisChat.historyBox do
  if Assigned(clickedItem.ev) and Assigned(clickedItem.ev.who) then
    clickedItem.ev.who.ViewInfo;
end;

procedure TchatFrm.hAchatpopuplsbUpdate(Sender: TObject);
begin // 3012
 with TAction(Sender) do
  if popupLSB then
    HelpKeyword:=PIC_RIGHT
   else
    HelpKeyword:='';
//    TAction(Sender).HelpKeyword := PIC_CHECKED
//   else
//    TAction(Sender).HelpKeyword := PIC_UNCHECKED;}
//  TAction(Sender).HelpKeyword := PIC_CHECK_UN[popupLSB];
end;


procedure TchatFrm.CloseallandAddtoIgnorelist1Click(Sender: TObject);
var
  i : Integer;
begin
  if messageDlg(getTranslation('Move to ignorelist all "not in list"?'),
      mtConfirmation, [mbYes,mbNo], 0) <> mrYes then
    Exit;
  try
    pagectrl.hide;
    for i:=chats.count-1 downto 0 do
     if chats.byIdx(i).chatType = CT_IM then
      if notInList.exists(chats.byIdx(i).who) then
     begin
       addToIgnoreList(chats.byIdx(i).who);
       removeFromRoster(chats.byIdx(i).who);
       closePageAt(i);
     end;
  finally
    pagectrl.show;
  end;
end;

procedure TchatFrm.RnQPicBtnClick(Sender: TObject);
var
  fn : String;
  PicMaxSize : Integer;
//  s, s2 : AnsiString;
  s, s2 : RawByteString;
//  bmp : TBitmap;
  fs  : TFileStream;
begin
  PicMaxSize := round(thisChat.who.fProto.maxCharsFor(thisChat.who, True) * 3 / 4 )- 100;
  if OpenSaveFileDialog(Application.Handle, 'wbmp',
     getSupPicExts + ';'#0 + 'R&Q Pics Files (wbmp)|*.wbmp'
     , '', 'Select R&Q Pic File', fn, True) then
//  if OpenPicDlg.Execute then
  begin
    if not FileExists(fn) then
     begin
       msgDlg('File not exists', True, mtError);
       exit;
     end;
    if not isSupportedPicFile(fn) then
     begin
       msgDlg('This picture format is not supported', True, mtError);
       exit;
     end;
    fs := TFileStream.Create(fn, fmOpenRead or fmShareDenyNone);
    if (fs.Size > PicMaxSize) or (fs.Size < 4) then
     begin
       msgDlg('This file is too big', True, mtError);
       fs.Free;
       exit;
     end;
    setLength(s, fs.Size);
    if fs.Size > 1 then
      fs.Read(s[1], length(s))
     else
      s := '';
    fs.Free;
    s2 := Base64EncodeString(s);
    s := '';
      Proto_Outbox_add(OE_msg, thisChat.who, IF_Bin, RnQImageExTag+ s2 + RnQImageExUnTag);
    s2 := '';  

  end;
end;

{procedure TchatFrm.process_tZers(ASender: TObject; percentDone: Integer);
begin
  if percentDone = 100 then
   ASender.Free;
end;

procedure TchatFrm.state_tZers(ASender: TObject; newState: Integer);
begin
// if newState = 4 then
//   ASender.Free;
end;

procedure TchatFrm.RnQSpeedButton1Click(Sender: TObject);
begin
  tZers := TShockwaveFlash.Create(self);
//  tZers.Left := 0;
//  tZers.Top  := 0;
//  tZers.Width := ClientWidth;
//  tZers.Height := ClientHeight;
         tZers.parent := pagectrl;
         tZers.align  := alClient;
  tZers.OnProgress := process_tZers;
  tZers.OnReadyStateChange := state_tZers;
  tZers.BackgroundColor := -1;
  tZers.WMode := 'Transparent';
//  tZers.TSetPropertyNum('/', 6, 1);
  tZers.Movie := myPath + 'boo.swf';
  tZers.Repaint;
  tZers.Play;
end;}

procedure TchatFrm.searchFrom(const start:integer);
var
  i:integer;
  w2s,s:string;
 {$IFNDEF DB_ENABLED}
//  re:Tregexpr;
  re: TRegEx;
  l_RE_opt : TRegExOptions;
 {$ENDIF ~DB_ENABLED}
  use_re, found:boolean;
begin
use_re:=reChk.checked;
w2s:=trim(w2sBox.text);
if not use_re and not caseChk.checked then
  w2s:=uppercase(w2s);
if w2s = '' then
  begin
  sbar.simpletext:=getTranslation('Type what you want to search...!');
  if w2sBox.Enabled and w2sBox.Visible then
    w2sBox.setFocus;
  exit;
  end;
if thisChat<>NIL then with thisChat do
  begin
  if use_re then
    begin
 {$IFNDEF DB_ENABLED}
{    re:=TRegExpr.Create;
    re.ModifierI:=not caseChk.checked;
    re.Expression := w2s;
      try
        re.Compile
      except
        FreeAndNIL(re);
        exit;
      end;}
      l_RE_opt := [roCompiled];
      if not caseChk.Checked then
        Include(l_RE_opt, roIgnoreCase)
       else
        Exclude(l_RE_opt, roIgnoreCase)
      ;
      re:= TRegEx.Create(w2s, l_RE_opt);
 {$ENDIF ~DB_ENABLED}
    end;
  i:=start;
  while (i >= historyBox.historyNowOffset) and (i < historyBox.history.Count) do
    begin
    s:=Thevent(historyBox.history[i]).getBodyText;
 {$IFNDEF DB_ENABLED}
    if use_re then
//     	found:=re.exec(s)
      found:=re.IsMatch(s)
    else
 {$ENDIF ~DB_ENABLED}
      begin
      if not caseChk.checked then
        found := AnsiContainsText(s, w2s)
       else
//        s:=uppercase(s);
        found:=pos(w2s,s) > 0;
//      found:=AnsiPos(w2s,s) > 0;
      end;
    if found then
      begin
//      historyBox.rsb_position:=i-historyBox.offset;
      historyBox.topVisible:=i;
      historyBox.topOfs:=0;
//      if historyBox.autoscroll then
        historyBox.updateRSB(True, i-historyBox.offset, False);
      historyBox.w2s := w2s;
      chatFrm.autoscrollBtn.down:=historyBox.autoScrollVal;
      historyBox.repaint;
//      historyBox.autoscroll:=historyBox.lastEventIsFullyVisible;
      sbar.simpletext:=getTranslation('Found!');
      case directionGrp.itemIndex of
        0: directionGrp.itemIndex:=3;
        1: directionGrp.itemIndex:=2;
        end;
      exit;
      end;
    case directionGrp.itemIndex of
      0,3: inc(i);
      1,2: dec(i);
      end;
    end;
  end;
sbar.simpletext:=getTranslation('Nothing found, sorry');
w2sBox.setFocus;
end; // searchFrom

procedure TchatFrm.SBSearchClick(Sender: TObject);
begin
 if (thisChat<>NIL)and(thisChat.chatType = CT_IM)
 then with thisChat do
  case directionGrp.itemIndex of
    0:searchFrom(historyBox.historyNowOffset);
    1:searchFrom(historyBox.history.count-1);
    2:searchFrom(historyBox.topVisible-1);
    3:searchFrom(historyBox.topVisible+1);
    end;
end;

procedure TchatFrm.w2sBoxKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if key=VK_RETURN then
    SBSearchClick(Sender);
end;

procedure TchatFrm.RnQFileBtnClick(Sender: TObject);
var
  fn : String;
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
       msgDlg('File not exists', True, mtError);
       exit;
     end;
    if Assigned(thisChat.who) then
      ICQSendFile(TICQContact(thisChat.who), fn)
  end;
 {$ENDIF usesDC}

 {$IFDEF SEND_FILE}
  SendFAM(thisChat.who.uin);
 {$ENDIF}
end;

procedure TchatFrm.toantispamClick(Sender: TObject);
begin
  if spamfilter.badwords <> '' then
   spamfilter.badwords := spamfilter.badwords + ';';
  spamfilter.badwords := spamfilter.badwords+thisChat.historyBox.getSelText;
end;

procedure TchatFrm.FormDeactivate(Sender: TObject);
begin
 {$IFDEF RNQ_FULL}
//  theme.ClearAniParams;
 {$ENDIF RNQ_FULL}
end;

procedure TchatFrm.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FAniTimer);
  FreeAndNil(plugBtns);
  FreeAndNil(chats);
end;

procedure TchatFrm.FormHide(Sender: TObject);
begin
 {$IFDEF RNQ_FULL}
//  rqSmiles.ClearAniParams;
  theme.ClearAniParams;
  FSmiles.Hide;
 {$ENDIF RNQ_FULL}
end;


procedure TchatFrm.UpdatePluginPanel;
begin
  if not Assigned(plugBtns.PluginsTB) then
   begin
//  usePlugPanel := True;
    if not usePlugPanel then
     plugBtns.PluginsTB := toolbar
    else
     begin
      plugBtns.PluginsTB := TToolBar.Create(pagectrl);
      plugBtns.PluginsTB.Parent := panel;
      plugBtns.PluginsTB.AutoSize := True;
      plugBtns.PluginsTB.Transparent := False;
      plugBtns.PluginsTB.Wrapable := False;
//      plugBtns.PluginsTB.
     end
   end
  else
    if (not usePlugPanel) then
      begin
       if(plugBtns.PluginsTB <> toolbar) then
        begin
          plugBtns.PluginsTB.Free;
          plugBtns.PluginsTB := toolbar;
        end
      end
    else
     begin
      plugBtns.PluginsTB := TToolBar.Create(pagectrl);
      plugBtns.PluginsTB.Parent := panel;
      plugBtns.PluginsTB.AutoSize := True;
      plugBtns.PluginsTB.Transparent := False;
      plugBtns.PluginsTB.Wrapable := False;
//      plugBtns.PluginsTB.
     end
end;


//----------------------------------------------------------------------------------------------------------------------
procedure TchatInfo.updateAutoscroll(Sender: TObject);
begin
  if Assigned(historyBox) then
  begin
    if Assigned(chatFrm)and Assigned(chatFrm.autoscrollBtn) then
      chatfrm.autoscrollBtn.down := historyBox.autoScrollVal;
//    historyBox.autoscroll := historyBox.autoscroll;
    updateLSB();
  end;
end;

function CHAT_TAB_ADD(Control: Integer; iIcon : HIcon; const TabCaption: string): Integer;
var
  sheet:TtabSheet;
  chat:TchatInfo;
//  pnl,
  pnl2:Tpanel;
  c: TRnQcontact;
  i: Integer;
begin

//  rqSmiles.ClearAniParams;
  theme.ClearAniParams;

  for i:=0 to chatFrm.chats.count-1 do
  begin
    if chatFrm.chats.byIdx(i).ID = Control then
    begin
      chatFrm.setTab(i);
      result:= -1;
      Exit;
    end;
  end;

  with chatFrm do
  begin
//    c := MainProto.getContactClass.create('PLUGIN');
//    c.nick:= TabCaption;
//    c.status:= SC_OFFLINE;
    c := NIL;
    chat:=TchatInfo.create;
//    chat.who:=c;
    chat.who:= NIL;
    chat.chatType := CT_PLUGING;
    chat.single:=singleDefault;
//    if not assigned(pTCE(c.data).history) then
//      pTCE(c.data).history:=Thistory.create;

    sheet:=TtabSheet.create(chatFrm);
    chatFrm.chats.Add(chat);
    sheet.PageControl:=pageCtrl;
    setCaptionFor(c);
    pnl2:=Tpanel.create(sheet);
    pnl2.parent:=sheet;
    pnl2.align:=alClient;
    pnl2.BevelInner:=bvNone;
    pnl2.BevelOuter:=bvNone;
    pnl2.BorderStyle:=bsNone;
    pnl2.BringToFront;
    //pnl2.caption:= TabCaption;
    pnl2.Tag:= 5000;

//    chat.input.visible:= false;
//    chat.splitter.visible:= false;
    chat.id:= Control;
//    chatFrm.InsertControl(TWinControl(Control));
    if iIcon <> 0 then
    begin
//      theme.addprop('plugintab' + intToStr(chat.id), iIcon, True);
      theme.addHIco('plugintab' + intToStrA(chat.id), iIcon, True);
    end;
    chat.lastInputText := TabCaption;
    resize;
//    savePages;
    saveListsDelayed := True;
    pageCtrl.ActivePageIndex:=sheet.pageIndex;

    chatFrm.setCaption(sheet.pageIndex);

    pagectrlChange(pageCtrl);

    result:= Integer(pnl2);
  end;
end;

procedure CHAT_TAB_MODIFY(Control: Integer; iIcon : HIcon; const TabCaption: string);
var
//  sheet:TtabSheet;
  chat:TchatInfo;
//  pnl,
//  pnl2:Tpanel;
//  c: Tcontact;
  i, curIdx: Integer;
begin
  chat := NIL;
  curIdx := -1;
  for i:=0 to chatFrm.chats.count-1 do
  begin
    if chatFrm.chats.byIdx(i).ID = Control then
    begin
      chat := chatFrm.chats.byIdx(i);
      curIdx := i;
//      chat.lastInputText := TabCaption;
      Break;
    end;
  end;
  if chat = NIL then
   Exit;
  if iIcon <> 0 then
  begin
//    theme.addprop('plugintab' + intToStr(chat.id), iIcon, True);
    theme.addHIco('plugintab' + intToStrA(chat.id), iIcon, True);
  end;
    chat.lastInputText := TabCaption;
//    pageCtrl.ActivePageIndex:=sheet.pageIndex;
   chatFrm.setCaption(curIdx);
//  chatFrm.pagectrl.Pages[i].
//  chatFrm.pagectrlChange(NIL);

//    result:= Integer(pnl2);
end;

procedure CHAT_TAB_DELETE(Control: Integer);
var
//  chat:TchatInfo;
//  c: Tcontact;
  //curIdx,
  i : Integer;
begin
//  chat := NIL;
//  curIdx := -1;
  for i:=0 to chatFrm.chats.count-1 do
  begin
    if chatFrm.chats.byIdx(i).ID = Control then
    begin
//      chat := chatFrm.chats.byIdx(i);
//      curIdx := i;
      chatFrm.closePageAt(i);
//      chat.lastInputText := TabCaption;
      Break;
    end;
  end;
end;

procedure TchatFrm.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
{  with Params do
  begin
//    Style := Style and (not WS_CAPTION);
//    Style := Style and not WS_OVERLAPPEDWINDOW or WS_BORDER and (not WS_CAPTION);
//    Style := (Style or WS_POPUP) and (not WS_DLGFRAME);
    Style := Style or WS_SYSMENU;
    ExStyle := ExStyle or WS_EX_APPWINDOW or WS_EX_NOPARENTNOTIFY;
  end;}
end;

procedure TchatFrm.WMEXITSIZEMOVE(var Message: TMessage);
var
  ch:TchatInfo;
begin
  inherited;
  ch:= thisChat;
  if ch = NIL then exit;
  if ch.chatType = CT_PLUGING then
    plugins.castEv(PE_SELECTTAB, ch.id);
end;

procedure TchatFrm.closemenuPopup(Sender: TObject);
var
  ch:TchatInfo;
begin
  ch:= thisChat;
  if ch = NIL then exit;
//  chatcloseignore1.visible:= ch.chatType <> CT_PLUGING;
//  CloseallandAddtoIgnorelist1.visible:= ch.chatType <> CT_PLUGING;
end;

procedure TchatFrm.AvtPBoxPaint(Sender: TObject);
var
//  gr : TGPGraphics;
//  ia : TGPImageAttributes;
  cnt : TRnQcontact;
  ch  : TchatInfo;
begin
  {$IFDEF RNQ_AVATARS}
  ch  := thisChat;
  cnt := thisContact;
  if Assigned(cnt) then
   if Assigned(cnt.icon.Bmp) and not Assigned(ch.avtPic.PicAni) then
   begin
//          TPaintBox(sender).Canvas.Brush.Color := paramSmile.color;
    TPaintBox(sender).Canvas.FillRect(TPaintBox(sender).Canvas.ClipRect);

    DrawRbmp(TPaintBox(sender).Canvas.Handle, cnt.icon.Bmp,
             DestRect(cnt.icon.Bmp.GetWidth, cnt.icon.Bmp.GetHeight,
             TPaintBox(sender).ClientWidth, TPaintBox(sender).ClientHeight));
{    gr := TGPGraphics.Create(TPaintBox(sender).Canvas.Handle);
//    ia.SetWrapMode(w)
    with DestRect(cnt.icon.Bmp.GetWidth, cnt.icon.Bmp.GetHeight,
                  TPaintBox(sender).ClientWidth, TPaintBox(sender).ClientHeight) do
     gr.DrawImage(cnt.icon.Bmp, Left, Top, Right-Left, Bottom - Top);
    gr.Free;}
   end
   else
    if Assigned(ch.avtPic.PicAni) then
     TickAniTimer(Sender);
  {$ENDIF RNQ_AVATARS}
end;
{
procedure TchatFrm.AvtPBoxPaint(Sender: TObject);
var
  gr : TGPGraphics;
//  ia : TGPImageAttributes;
  dc  : HDC;
  ABitmap : HBITMAP;
  fullR : TRect;
  cnt : Tcontact;
begin
  cnt := thisContact;
  if Assigned(cnt) and Assigned(cnt.icon.Bmp) then
   begin
    fullR := TPaintBox(sender).Canvas.ClipRect;
    try
      DC := CreateCompatibleDC(TPaintBox(sender).Canvas.Handle);
      with fullR do
      begin
        ABitmap := CreateCompatibleBitmap(TPaintBox(sender).Canvas.Handle, Right-Left, Bottom-Top);
        if (ABitmap = 0) and (Right-Left + Bottom-Top <> 0) then
          raise EOutOfResources.Create('Out of Resources');
        HOldBmp := SelectObject(DC, ABitmap);
        SetWindowOrgEx(DC, Left, Top, Nil);
      end;
    finally

    end;

    gr :=TGPGraphics.Create(DC);
    gr.Clear(gpColorFromAlphaColor($FF, Self.Brush.Color));
//    gr := TGPGraphics.Create(TPaintBox(sender).Canvas.Handle);
//    ia.SetWrapMode(w)
    with DestRect(cnt.icon.Bmp.GetWidth, cnt.icon.Bmp.GetHeight,
                  TPaintBox(sender).ClientWidth, TPaintBox(sender).ClientHeight) do
     gr.DrawImage(cnt.icon.Bmp, Left, Top, Right-Left, Bottom - Top);
    gr.Free;
    BitBlt(TPaintBox(sender).Canvas.Handle, fullR.Left, fullR.Top,
      fullR.Right - fullR.Left, fullR.Bottom - fullR.Top,
      dc, fullR.Left, fullR.Top, SrcCopy);

    DeleteObject(ABitmap);
    DeleteDC(DC);
   end;
end;}
{
procedure TchatFrm.WMEraseBkgnd(var Msg: TWmEraseBkgnd);
var
 cnv : TCanvas;
begin
  cnv := TCanvas.Create;
  cnv.Handle := msg.DC;
  wallpaperize(cnv);
  cnv.Free;
end;
}

procedure TchatFrm.TickAniTimer(Sender: TObject);
var
  b2 : TBitmap;
  paramSmile: TAniPicParams;
//  w, h : Integer;
  resW, resH : Integer;
  ch : TchatInfo;
{  PaintRect: TRect;
  PaintBuffer: HPAINTBUFFER;
  MemDC: HDC;
  br1 : HBRUSH;
}
begin
//  if not UseAnime then Exit;
//  checkGifTime;
  ch := thisChat;
//  if (ch = NIL)or (ch.chatType <> CT_ICQ)or not (Assigned(ch.avtPic.Pic))  then
  if (ch = NIL)or (ch.chatType <> CT_IM)or not (Assigned(ch.avtPic.PicAni))  then
   Exit;
  if not Assigned(ch.avtPic.AvtPBox) then Exit;
  if not ch.avtPic.PicAni.RnQCheckTime then Exit;
//  w := ch.avtPic.PicAni.Width;
//  h := ch.avtPic.PicAni.Height;
  resW := ch.avtPic.AvtPBox.ClientWidth;
  resH := ch.avtPic.AvtPBox.ClientHeight;
  paramSmile.Bounds := DestRect(//w, h,
                  ch.avtPic.PicAni.Width, ch.avtPic.PicAni.Height,
//                  ch.avtPic.AvtPBox.ClientWidth, ch.avtPic.AvtPBox.ClientHeight);
                  resW, resH);
  paramSmile.Canvas := ch.avtPic.AvtPBox.Canvas;
  paramSmile.Color := ch.avtPic.AvtPBox.Color;
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
           ch.avtPic.PicAni.Draw(b2.Canvas.Handle, paramSmile.Bounds);
          if Assigned(paramSmile.Canvas)
//           and (paramSmile.Canvas.HandleAllocated )
          then
           BitBlt(paramSmile.Canvas.Handle, 0, 0, //paramSmile.Bounds.Left, paramSmile.Bounds.Top,
           resW, resH,
//            w, h,
            b2.Canvas.Handle, 0, 0, SRCCOPY);
        b2.Free;
{
         PaintRect := paramSmile.Canvas.ClipRect;
         PaintBuffer := BeginBufferedPaint(paramSmile.Canvas.Handle, PaintRect, BPBF_TOPDOWNDIB, nil, MemDC);
         BufferedPaintClear(PaintBuffer, @PaintRect);
         br1 := CreateSolidBrush(ColorToRGB(paramSmile.Color));
         FillRect(memDC, PaintRect, br1);
//         ch.avtPic.PicAni.Draw(paramSmile.Canvas.Handle, paramSmile.Bounds);
         ch.avtPic.PicAni.Draw(MemDC, paramSmile.Bounds);
//         BufferedPaintMakeOpaque(PaintBuffer, @PaintRect);
         EndBufferedPaint(PaintBuffer, True);
}
      end;
  end;
end;
{procedure TchatFrm.checkGifTime;
//var
// i : Integer;
begin
//  for I := 0 to chats.Count - 1 do
//   if chats[i] <> NIL then
//     with chats.byIdx(i) do
   if thisChat <> NIL then
    with thisChat do
     if (chatType = CT_ICQ)and (Assigned(avtPic.PicAni))  then
//   TRnQAni(FAniSmls.Objects[I]).RnQCheckTime;
      avtPic.PicAni.RnQCheckTime;
end;}

procedure TchatFrm.WMWINDOWPOSCHANGING(var Msg: TWMWINDOWPOSCHANGING);
const
  chkLeft  = True;
  chkRight = True;
  chkTop   = True;
  chkBottom = True;
var
//  rWorkArea: TRect;
  rMainRect: TRect;
  StickAt : Word;
//  Docked: Boolean;
begin
//  Docked := FALSE;
  if Assigned(MainDlg.RnQmain) then
  if MainDlg.RnQmain.Visible then
 begin
  StickAt := 15;//StrToInt(edStickAt.Text);
  rMainRect := MainDlg.RnQmain.BoundsRect;
//  SystemParametersInfo
//     (SPI_GETWORKAREA, 0, @rWorkArea, 0);

  with Msg.WindowPos^ do begin
    if chkLeft then
//     if ABS(x - rWorkArea.Left) <=  StickAt then begin
//      x := rWorkArea.Left;
     if (ABS(x - rMainRect.Right) <=  StickAt)
       and (y < rMainRect.Bottom)and(y+cy > rMainRect.Top) then
     begin
      x := rMainRect.Right;
//      Docked := TRUE;
     end;

    if chkRight then
//     if abs(x + cx - rWorkArea.Right) <=  StickAt then begin
//      x := rWorkArea.Right - cx;
     if (abs(x + cx - rMainRect.Left) <=  StickAt)
       and (y < rMainRect.Bottom)and(y+cy > rMainRect.Top) then
      begin
       x := rMainRect.Left - cx;
//       Docked := TRUE;
      end;

    if chkTop then
     if (abs(y - rMainRect.Bottom)<=  StickAt)
      and (x < rMainRect.Right)and (x + cx > rMainRect.Left) then
     begin
      y := rMainRect.Bottom;
//      Docked := TRUE;
     end;

    if chkBottom then
     if (abs(y + cy - rMainRect.Top)<= StickAt)
      and (x < rMainRect.Right)and (x + cx > rMainRect.Left) then
     begin
      y := rMainRect.Top - cy;
//      Docked := TRUE;
     end;
(*
    if Docked then begin
      with rWorkArea do begin
      // не должна вылезать за пределы экрана
      if x < Left then x := Left;
      if x + cx > Right then x := Right - cx;
      if y < Top then y := Top;
      if y + cy > Bottom then y := Bottom - cy;
      end; {ширина rWorkArea}
    end; {}
*)
  end; {с Msg.WindowPos^}
 end;
 inherited;
end;

 {$IFDEF USE_SECUREIM}
procedure TchatFrm.EncryptSendInit(Sender: TObject);
begin
// activeICQ.sendSNAC()
//  cpp.
end;
 {$ENDIF USE_SECUREIM}
procedure TchatFrm.EncryptSetPWD(Sender: TObject);
var
  ch : TchatInfo;
  s : String;
  sA : AnsiString;
begin
//  if not UseAnime then Exit;
//  checkGifTime;
  ch := thisChat;
//  if (ch = NIL)or (ch.chatType <> CT_ICQ)or not (Assigned(ch.avtPic.Pic))  then
  if (ch = NIL)or (ch.chatType <> CT_IM) then
    Exit;
  if not (ch.who is TICQcontact) then Exit;

  if enterPwdDlg(s, getTranslation('Enter password for %s', [ch.who.displayed]), 32, True) then
    begin
      sA := s;
      TICQcontact(ch.who).crypt.qippwd := qip_str2pass(sA);
    end;
     ;
  updateContactStatus;
// activeICQ.sendSNAC()
end;

procedure TchatFrm.EncryptClearPWD(Sender: TObject);
var
  ch : TchatInfo;
//  s : AnsiString;
begin
//  if not UseAnime then Exit;
//  checkGifTime;
  ch := thisChat;
//  if (ch = NIL)or (ch.chatType <> CT_ICQ)or not (Assigned(ch.avtPic.Pic))  then
  if (ch = NIL)or (ch.chatType <> CT_IM) then
    Exit;
  if not (ch.who is TICQcontact) then Exit;
  TICQcontact(ch.who).crypt.qippwd := 0;
  updateContactStatus;
// activeICQ.sendSNAC()
end;

procedure TchatFrm.SetSmilePopup(pIsMenu : Boolean);
begin
   {$IFDEF USE_SMILE_MENU}
  if pIsMenu then
    begin
      smilesBtn.PopupMenu := smileMenuExt;
      smilesBtn.OnMouseUp := NIL;
    end
   else
   {$ENDIF USE_SMILE_MENU}
    begin
      smilesBtn.PopupMenu := NIL;
      smilesBtn.OnMouseUp := smilesBtnMouseUp;
    end
end;

 {$IFDEF usesDC}
procedure TchatFrm.WMDROPFILES(var Message: TWMDROPFILES);
var
  ch : TchatInfo;
  cnt : TRnQContact;
  i, n:integer;
  ss:string;
  buffer:array[0..2000] of char;
begin
  ch := thisChat;
 if (ch = NIL) then exit;
 if ch.chatType = CT_IM then
   begin
    cnt := ch.who;
    if cnt = NIL then
      Exit;
    if cnt is TICQcontact then
     begin
      ss:='';
      n:=DragQueryFile(Message.Drop,cardinal(-1),NIL,0);
      for i:=0 to n-1 do
        begin
        DragQueryFile(Message.Drop,i,@buffer,sizeof(buffer));
        ss:=ss+buffer+CRLF;
        end;
      DragFinish(message.drop);
//      TsendFileFrm.doAll(self, TICQContact(cnt), ss);
      ICQsendfile(TICQContact(cnt), ss);
      ss:='';
     end; 
   end;
end; // WMDROPFILES
 {$ENDIF usesDC}

end.
