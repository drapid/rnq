{
  This file is part of R&Q.
  Under same license
}
unit historyVCL;
{$I RnQConfig.inc}
{$I NoRTTI.inc}

interface

uses
  {$IFDEF USE_GDIPLUS}
   GDIPAPI, GDIPOBJ,
  {$ENDIF USE_GDIPLUS}
  windows, controls, classes,
  sysutils, graphics, forms, stdctrls, ExtCtrls,
  messages, strutils, Menus,
  System.Actions, Vcl.ActnList,
  RDGlobal, RnQMenu, RQMenuItem, RQThemes,
  history, RnQProtocol, events;

type
  TlinkKind = (LK_FTP, LK_EMAIL, LK_WWW, LK_UIN, LK_ED);
const
  linksToUnderline: set of TlinkKind = [LK_FTP, LK_EMAIL, LK_WWW, LK_ED];

type

  TscrollBarEx = class(Tscrollbar)
   protected
    P_entering: boolean;
    procedure CMMouseEnter(var msg: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var msg: TMessage); message CM_MOUSELEAVE;
   public
    onEnter, onLeave: procedure of object;
    property entering: boolean read P_entering;
  end;

type
  ThistoryBox = class;

  THistoryData = class(TDataModule)
    histmenu: TPopupMenu;
    add2rstr: TMenuItem;
    copylink2clpbd: TMenuItem;
    copy2clpb: TMenuItem;
    savePicMnu: TMenuItem;
    selectall1: TMenuItem;
    viewmessageinwindow1: TMenuItem;
    saveas1: TMenuItem;
    txt1: TMenuItem;
    html1: TMenuItem;
    addlink2fav: TMenuItem;
    del1: TMenuItem;
    N1: TMenuItem;
    toantispam: TMenuItem;
    N2: TMenuItem;
    Openchatwith1: TMenuItem;
    ViewinfoM: TMenuItem;
    N3: TMenuItem;
    chtShowSmiles: TMenuItem;
    chatshowlsb1: TMenuItem;
    chatpopuplsb1: TMenuItem;
    chatShowDevTools: TMenuItem;
    ActList1: TActionList;
    hAaddtoroaster: TAction;
    hAsaveas: TAction;
    hAdelete: TAction;
    hACopy: TAction;
    hASelectAll: TAction;
    hAchatshowlsb: TAction;
    hAchatpopuplsb: TAction;
    hAViewInfo: TAction;
    hAShowSmiles: TAction;
    ShowStickers: TAction;
    hAShowDevTools: TAction;
    hAOpenChatWith: TAction;
    procedure histmenuPopup(Sender: TObject);
    procedure hAchatshowlsbExecute(Sender: TObject);
    procedure hAchatpopuplsbExecute(Sender: TObject);
    procedure hAchatshowlsbUpdate(Sender: TObject);
    procedure hAchatpopuplsbUpdate(Sender: TObject);
    procedure ANothingExecute(Sender: TObject);
    procedure hAdeleteExecute(Sender: TObject);
    procedure copylink2clpbdClick(Sender: TObject);
    procedure hACopyExecute(Sender: TObject);
    procedure hASelectAllExecute(Sender: TObject);
    procedure hAViewInfoExecute(Sender: TObject);
    procedure savePicMnuClick(Sender: TObject);
    procedure viewmessageinwindow1Click(Sender: TObject);
    procedure txt1Click(Sender: TObject);
    procedure html1Click(Sender: TObject);
    procedure addlink2favClick(Sender: TObject);
    procedure toantispamClick(Sender: TObject);
    procedure chatShowDevToolsClick(Sender: TObject);
    procedure hAShowSmilesExecute(Sender: TObject);
    procedure hAShowSmilesUpdate(Sender: TObject);
    procedure hAOpenChatWithExecute(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    selectedUIN: TUID;
    currentHB: THistoryBox;
  {$IFDEF CHAT_USE_LSB}
    popupLSB,
    showLSB: Boolean;
    hideScrollTimer: integer;
    function getCurrentHistBox: THistoryBox;
  {$ENDIF CHAT_USE_LSB}
  {$IFDEF CHAT_USE_LSB}
    procedure lsbScroll(Sender: TObject; ScrollCode: TScrollCode; var ScrollPos: Integer);
    procedure lsbEnter;
    procedure setLeftSB(visible: Boolean);
  {$ENDIF CHAT_USE_LSB}
    procedure onTimer(hb: ThistoryBox);
    procedure addcontactAction(sender: Tobject);
  end;


  THistSearchDirection = (hsdFromBegin, hsdAhead, hsdBack, hsdFromEnd);
  TDrawStyle = (dsNone, dsBuffer, dsGlobalBuffer, dsMemory, dsGlobalBuffer2);
  TAutoScrollState = (ASS_FULLSCROLL,       // fAutoscroll = True, not2go2end = false
                      ASS_ENABLENOTSCROLL,  // fAutoscroll = True, not2go2end = True
                      ASS_FULLDISABLED);    // fAutoscroll = False, not2go2end = Any

  TitemKind=( PK_NONE, PK_HEAD, PK_TEXT, PK_ARROWS_UP, PK_ARROWS_DN, PK_LINK,
    PK_SMILE, PK_CRYPTED, PK_RQPIC, PK_RQPICEX, PK_RNQBUTTON);

  PhistoryItem = ^ThistoryItem;
  ThistoryLink = record
    evIdx: integer;    // -1 for null links
    str: String;
    from, to_: integer;
    kind: TlinkKind;
    id: integer;
    ev: Thevent;
   end;

  TLinkClickEvent = procedure(
    const Sender: TObject;
    const LinkHref: String;
    const LinkText: String) of object;

  ThistoryItem = record
    kind: TitemKind;   // PK_NONE for null items
    ev: Thevent;
    evIdx, ofs, l: integer;
    r: Trect;
    link: ThistoryLink;
    function equal(const x: ThistoryItem): boolean;
   end;

  ThistoryPos = record
    ev: Thevent;    // NIL for null positions
    evIdx: integer; // -1 for void positions
    ofs: integer;    // -1 when the whole event is selected
   end;

  ThistoryBox = class(TcustomControl)
    popMenu: TRnQPopupMenu;
   private
     class var lastBGCnt: TRnQContact;
     class var lastBGToken: Integer;
     class var vKeyPicElm: TRnQThemedElementDtls;
     class var globalBuffer: TBitmap;
     class constructor Create;
     class destructor Destroy;
   private

   // For History at all
    items: array of ThistoryItem;
    P_lastEventIsFullyVisible: boolean;
    startWithLastLine: boolean;
    P_topEventNrows, P_bottomEvent: integer;
    fAutoScrollState: TAutoScrollState;    // auto scrolls along messages
//    fAutoscroll: boolean;    // auto scrolls along messages
//    not2go2end: Boolean;
   private
    // For Active History!
    lastTimeClick: TdateTime;
//    avoidErase: boolean;
    selecting: boolean;
    justTriggeredAlink, dontTriggerLink, just2clicked: boolean;
    lastClickedItem, P_pointedSpace, P_pointedItem: ThistoryItem;
    linkToUnderline: ThistoryLink;
    FOnLinkClick: TLinkClickEvent;
    buffer: TBitmap;
    lastWidth
//    , lastHeight
       : Integer;
    fDrawDebug: Boolean;
   private
    // Same for all historys
//    firstCharactersForSmiles: set of AnsiChar; // for faster smile recognition
    firstCharactersForSmilesW: String; // for faster smile recognition
    FOnScroll: TNotifyEvent;
  //----------------------------------------------------------------------------
//    hasDownArrow: Boolean;
//    hDownArrow: Integer;
  protected
    procedure DoBackground(cnv0: Tcanvas; vR: TRect; var SmlBG: TBitmap; const PPI: Integer);
    procedure DrawEmoji(Sender: TObject);
//    procedure DoBackground(DC: HDC);
    procedure WMEraseBkgnd(var Msg: TWmEraseBkgnd); message WM_ERASEBKGND;
    procedure WMVScroll(var Msg: TWMVScroll); message WM_VSCROLL;
    procedure CreateParams(var Params: TCreateParams); override;
    function  getAutoScroll: Boolean;
    procedure setAutoScrollForce(vAS: Boolean);
//    procedure setAutoScroll(vAS : Boolean);
//    procedure wmPaint(var msg : TWMPaint); message WM_PAINT;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X,Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X,Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure Click; override;
    function  triggerLink(item: ThistoryItem): boolean;
    function  itemAt(pt: Tpoint): ThistoryItem;
    function  spaceAt(pt: Tpoint): ThistoryItem;
    procedure updatePointedItem();
    procedure PPM_copylink2clpbdClick(Sender: TObject);
    procedure PPM_copy2clpbClick(Sender: TObject);

  public
    topVisible, topOfs: Integer;
    offset: integer; // can't show hevents before this
    startSel, endSel: ThistoryPos;
    who: TRnQContact;
    history: Thistory;
    margin: Trect;
    whole: boolean;         // see whole history
    rsb_visible: Boolean;
    rsb_position: integer;
    rsb_rowPerPos: integer;
    newSession: integer;    // where, in the history, does start new session
    onPainted: TNotifyEvent;
    w2s: String;
{$IFDEF CHAT_USE_LSB}
//    rsb: TscrollBar;
    lsb: TscrollBarEx;
    procedure updateLSB;
{$ENDIF CHAT_USE_LSB}

    property color;
    property canvas;
    property onDragOver;
    property onDragDrop;
    property lastEventIsFullyVisible: boolean read P_lastEventIsFullyVisible;
    property pointedItem: ThistoryItem read P_pointedItem;
    property clickedItem: ThistoryItem read lastClickedItem;
    property pointedSpace: ThistoryItem read P_pointedSpace;
    property topEventNrows: integer read P_topEventNrows;
    property bottomEvent: integer read P_bottomEvent;
    property autoScrollVal: Boolean read getAutoscroll write setAutoScrollForce;
    property OnScroll: TNotifyEvent read FOnScroll write FOnScroll;
    property onLinkClick: TLinkClickEvent read FOnLinkClick write FOnLinkClick;

    constructor Create(owner_: Tcomponent; cnt: TRnQContact); overLoad;
    destructor Destroy; override;

    procedure InitAll;
    class procedure InitMenu(var pm: TPopupMenu; Own: TComponent);

    procedure ShowDebug;
    procedure Paint(); override;
    procedure paintOn(cnv: Tcanvas; vR: TRect; const PPI: Integer; const JustCalc: Boolean = false);
    procedure go2end(const calcOnly: Boolean = False; const precalc: Boolean = False);
    procedure move2start();
    procedure move2end(animate: Boolean = False);
    function  moveToTime(time: TDateTime; NeedOpen: Boolean): Boolean;
    function  search(text: String; dir: THistSearchDirection; caseSens: Boolean; useRE: Boolean): Boolean;
    function  getSelText(): string;
    function  copySel2Clpb(): Boolean;
    function  getSelBin(): AnsiString;
    function  getSelHtml(smiles: boolean): string;
    function  getSelHtml2(smiles: boolean): RawByteString;
    function  somethingIsSelected(): boolean;
    function  wholeEventsAreSelected(): boolean;
    function  nothingIsSelected(): boolean;
    function  partialTextIsSelected(): boolean;

    function  offsetPos: integer;
    procedure select(from, to_: integer);
    procedure selectAll;
    procedure deselect();
    procedure DeleteSelected;

    procedure ManualRepaint;
    procedure updateRSB(SetPos: Boolean; pos: Integer = 0; doRedraw: Boolean = true);
    procedure addEvent(ev: Thevent);
    function  historyNowCount: Integer;
    function  historyNowOffset: Integer;
    procedure trySetNot2go2end;
    procedure histScrollEvent(d: integer);
    procedure histScrollLine(d: integer);
    procedure DoOnScroll;
    function  getQuoteByIdx(var pQuoteIdx: Integer): String;
    procedure setScrollPrefs(ShowAll: Boolean);
    function  AllowShowAll: Boolean;
    function  hasEvents: Boolean;
    procedure updateGraphics;
  end; // ThistoryBox

const
  dStyle = dsGlobalBuffer2;
//    dStyle = dsGlobalBuffer;
//    dStyle = dsMemory; // Bad BG and not so fast :(
//    dStyle = dsNone;

var
    // dsNone, dsBuffer, dsGlobalBuffer, dsMemory
//    dStyle: TDrawStyle = dsGlobalBuffer2;
//    dStyle: TDrawStyle = dsNone;
  hisBGColor, myBGColor: TColor;

const
  aHistMenu: array[0..19] of TbMenuItem =
        ((amiName: 'add2rstr'; amiCaption: 'Add to contact list'; amiImage: 'addedyou'),
         (amiName: 'copylink2clpbd'; amiCaption: 'Copy link'; amiEvName: 'HISTORY.PPM.copylink2clpbd'), //; amiEv: copylink2clpbdClick)
         (amiName: 'copy2clpb'; amiCaption: 'Copy'; amiImage: 'copy'), //; amiEv: copy2clpbClick)
         (amiName: 'savePicMnu'; amiCaption: 'Save pic'), //; amiEv: savePicMnuClick)
         (amiName: 'selectall1'; amiCaption: 'Select all'; amiImage: 'select.all'), //; amiEv: selectall1Click)
         (amiName: 'viewmessageinwindow1'; amiCaption: 'View message in window'), //; amiEv: viewmessageinwindow1Click)
         (amiName: 'saveas1'; amiCaption: 'Save as'; amiImage: 'save'), //; amiEv: NIL)
         (amiName: 'txt1'; amiCaption: 'txt'; amiImage: 'save'; amiParent: 'saveas1'), //; amiEv: txt1Click)
         (amiName: 'html1'; amiCaption: 'html'; amiImage: 'save'; amiParent: 'saveas1'), //; amiEv: html1Click)
         (amiName: 'addlink2fav'; amiCaption: 'Add link to favorites'), //; amiEv: addlink2favClick)
         (amiName: 'del1'; amiCaption: 'Delete selected'; amiImage: 'delete'), //; amiEv: del1Click)
         (amiName: 'N1'; amiCaption: '-'), //; amiEv: NIL)
         (amiName: 'toantispam'; amiCaption: 'To antispam'), //; amiEv: toantispamClick)
         (amiName: 'N2'; amiCaption: '-'), //; amiEv: NIL)
         (amiName: 'Openchatwith1'; amiCaption: 'Open chat with...'; amiImage: 'msg'), //; amiEv: Openchatwith1Click)
         (amiName: 'ViewinfoM'; amiCaption: 'View info'; amiImage: 'info'), //; amiEv: hAViewInfoExecute)
         (amiName: 'N3'; amiCaption: '-'), //; amiEv: NIL)
         (amiName: 'chtShowSmiles'; amiCaption: 'Show graphic smiles'; amiImage: 'smiles'), //; amiEv: hAShowSmilesExecute amiUpd: hAShowSmilesUpdate)
         (amiName: 'chatshowlsb1'; amiCaption: 'Show left scrollbar'; amiImage: 'scroll'), //; amiEv: chatshowlsb1Click amiUpd: hAchatshowlsbUpdate)
         (amiName: 'chatpopuplsb1'; amiCaption: 'Popup left scrollbar'; amiImage: 'scroll') //; amiEv: chatpopuplsb1Click amiUpd: hAchatpopuplsbUpdate)
//         (amiName: 'chatShowDevTools'; amiCaption: 'Show Dev tools'; amiImage: 'develop'), //; amiEv: chatShowDevToolsClick)

         );
const
  minimizedScroll = 5;
  maximizedScroll = 16;

var
  HistoryData: THistoryData;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

uses
  clipbrd, Types, math, UITypes,
 {$IFDEF UNICODE}
   AnsiStrings,
   Character,
 {$ENDIF UNICODE}
 {$IFNDEF DB_ENABLED}
//    RegExpr,
    RegularExpressions,
 {$ENDIF ~DB_ENABLED}
  RnQSysUtils, RnQLangs, RDFileUtil, RnQFileUtil, RDUtils, RnQBinUtils,
  RQUtil, RnQButtons, RnQGlobal, RnQCrypt, RnQPics,
  RnQConst, globalLib, mainDlg, utilLib,
//  chatDlg,
  ViewPicDimmedDlg, ViewHEventDlg,
  EmojiConst,
  roasterLib,
  {$IFDEF USE_GDIPLUS}
//  KOLGDIPV2,
  {$ENDIF USE_GDIPLUS}
//  historyRnQ,
  Base64,
  Protocols_All,
  {$IFDEF USE_GDIPLUS}
    RnQGraphics,
  {$ELSE}
    RnQGraphics32,
  {$ENDIF USE_GDIPLUS}
  themesLib, menusUnit;

function minor(const a, b: ThistoryPos): boolean; overload;
begin
  result := (a.evIdx < b.evIdx) or (a.evIdx = b.evIdx) and (a.ofs < b.ofs)
end;

function equal(const a, b: ThistoryPos): boolean; overload;
begin
  result := (a.evIdx = b.evIdx) and (a.ofs = b.ofs)
end;

function minor(const a, b: ThistoryItem): boolean; overload;
begin
  result := (a.evIdx < b.evIdx) or (a.evIdx = b.evIdx) and (a.ofs < b.ofs)
end;
{
function equal(const a, b: ThistoryItem): boolean; overload;
begin
  result := (a.evIdx = b.evIdx) and (a.ofs = b.ofs) and (a.kind = b.kind)
end;
}
function ThistoryItem.equal(const x: ThistoryItem): boolean;
begin
  result := (self.evIdx = x.evIdx) and (self.ofs = x.ofs) and (self.kind = x.kind)
end;

function equal(const a, b: ThistoryLink): boolean; overload;
begin
  result := (a.evIdx = b.evIdx) and (a.from = b.from) and (a.to_ = b.to_)
end;

function minor(const a, b: Tpoint): boolean; overload;
begin
  result := (a.y < b.y) or (a.y = b.y) and (a.x < b.y)
end;

function isLink(const it: ThistoryItem): boolean; inline;
begin
  result := it.kind = PK_LINK
end;

function historyitem2pos(const a: ThistoryItem): ThistoryPos;
begin
  if a.kind = PK_NONE then
  begin
    result.ev := nil;
    result.evIdx := -1;
  end
  else
  begin
    result.ev := a.ev;
    result.evIdx := a.evIdx;
    result.ofs := a.ofs;
  end
end;

class constructor ThistoryBox.Create;
begin
  if dStyle = dsGlobalBuffer then
  begin
    globalBuffer:= createBitmap(Screen.DesktopWidth, Screen.DesktopHeight);
  end;

  if dStyle = dsGlobalBuffer2 then
  begin
    globalBuffer:= createBitmap(0, 0);
    globalBuffer.PixelFormat := pf32bit;
  end;

  vKeyPicElm.ThemeToken := -1;
  vKeyPicElm.picName := PIC_KEY;
  vKeyPicElm.Element := RQteDefault;
  vKeyPicElm.pEnabled := True;
end;

class destructor ThistoryBox.Destroy;
begin
  if (dStyle = dsGlobalBuffer) or (dStyle = dsGlobalBuffer2) then
    if globalBuffer <> nil then
      globalBuffer.Free;
end;


constructor ThistoryBox.Create(owner_: Tcomponent; cnt: TRnQContact);
begin
  inherited Create(owner_);
  SetParentComponent(Owner_);
  if owner_ is TWinControl then
    Parent :=  TWinControl(Owner_);
  Who := cnt;
//  avoidErase:=FALSE;
  tabStop := False;
  P_lastEventIsFullyVisible := False;
  onPainted := NIL;
//  autoscroll := TRUE;
  fAutoScrollState := ASS_FULLSCROLL;
  newSession := 0;
  offset := 0;
  deselect;
  fDrawDebug := false;

  if dStyle = dsBuffer then
    buffer := TBitmap.Create;

//   history := pTCE(c.data).history as Thistory;
   history := Thistory.create;
   history.Reset;


 {$IFDEF CHAT_USE_LSB}
  lsb := TscrollbarEx.create(owner_);
  with lsb do
  begin
    if owner_ is TWinControl then
      Parent :=  TWinControl(Owner_);
    align := alLeft;
    tabStop := False;
    onScroll := HistoryData.lsbScroll;
    onEnter := HistoryData.lsbEnter;
    onLeave := HistoryData.lsbEnter;
    Kind := sbVertical;
    position := 0;
    min := 0;
    max := 0;
    if HistoryData.popupLSB then
      width := MulDiv(minimizedScroll, GetParentCurrentDpi, cDefaultDPI)
     else
      width := MulDiv(maximizedScroll, GetParentCurrentDpi, cDefaultDPI);
    smallChange := 1;
    largeChange := 5;
    enabled := False;
    visible := HistoryData.showLSB;
    hint := getTranslation('Scrolls the message line by line');
  end;
 {$ENDIF CHAT_USE_LSB}

end; // create

destructor ThistoryBox.Destroy;
begin
  if dStyle = dsBuffer then
    if buffer <> nil then
      buffer.Free;
  if Assigned(Self) then
   inherited Destroy;
//  self := NIL;
end;

procedure ThistoryBox.InitAll;
begin
  ;
end;

procedure ThistoryBox.ShowDebug;
begin
  fDrawDebug := not fDrawDebug;
end;


class procedure ThistoryBox.InitMenu(var pm: TPopupMenu; Own: TComponent);
begin
//  createMenuAs(aHistMenu, pm, Own);
end;

procedure ThistoryBox.paintOn(cnv: Tcanvas; vR: TRect; const PPI: Integer; const JustCalc: Boolean = false);
var
//  vCnvHandle: HDC;
  lineHeight, bodySkipCounter, skippedLines,
  evIdx, Nitems: Integer;
  rightLimit, bottomLimit: Integer;
  SOS, EOS: ThistoryPos;
  ev: Thevent;
//  c: Tcontact;
   selectedClr: Tcolor;
//   selectedMyClr, selectedHisClr : TColor;
  linkTheWholeBody: string;
  foundLink: ThistoryLink;
  mouse: Tpoint;
 {$IFDEF RNQ_FULL}
  foundAniSmile: Boolean;
 {$ENDIF RNQ_FULL}
  eventFullyPainted, firstEvent,
    nowLink, nowBold, nowUnderline,
    pleaseDontDrawUpwardArrows: boolean;
  oldMode: Integer;
  Nrows: integer;
  MaxChatImgWidthVal: Integer;// = 100;
  MaxChatImgHeightVal: Integer;// = 100;
  EmojiAsPic: Boolean;

  procedure newLineH(var x, y: Integer);
  begin
    inc(y, lineHeight);
    x := margin.left;
    lineHeight := 0;
    inc(Nrows);
  end; // newHLine

  function isEmailAddress(const s: string; start: integer; var end_: integer): boolean;
  var
    j: integer;
    existsDot: boolean;
  begin
    result := False;
    j := start;
  // try to find the @
//    while (j <= length(s)) and (s[j] in EMAILCHARS) and (j - start < 30) do
    while (j <= length(s)) and CharInSet(s[j], EMAILCHARS) and (j - start < 30) do
      inc(j);
    if s[j] <> '@' then
      exit;
  // @ found, now skip the @ and search for .
    inc(j);
    existsDot := False;
//    while (j < length(s)) and (s[j+1] in EMAILCHARS) do
    while (j < length(s)) and CharInSet(s[j+1], EMAILCHARS) do
    begin
      if s[j] = '.' then
      begin
        existsDot := True;
        break;
      end;
      inc(j);
    end;
    // at least a valid char after the . must exists
//    if not existsDot or not (s[j] in EMAILCHARS) then
    if not existsDot or not CharInSet(s[j], EMAILCHARS) then
      exit;
    // go forth till we're out or we meet an invalid char
    repeat
      inc(j)
//    until (j > length(s)) or not (s[j] in EMAILCHARS);
    until (j > length(s)) or not CharInSet(s[j], EMAILCHARS);
    end_:=j-1;
    if s[end_] = '.' then
      dec(end_);
    //while s[start-1] in emailChar do dec(start);
    result := True;
  end; // isEmailAddress

  function isUIN(const s: string; start: integer; var end_: integer): boolean;
    function isdig(const ch: char): Boolean; inline;
    begin
     {$IFDEF UNICODE}
      result := ch.IsDigit;
     {$ELSE UNICODE}
      Result := ch in ['0'..'9'];
     {$ENDIF UNICODE}
    end;
  var
    i: integer;
  begin
    result := False;
    i := start;
    if (i > 0)and isdig(s[i-1]) then
      Exit;
    while (i <= length(s)) and isdig(s[i]) and (i - start < 10) do
      inc(i);
    if (i <= length(s)) and isdig(s[i])
//      or ((i < length(s)) and (s[i] in [',','.']) and isdig(s[i+1])) then
      or ((i < length(s)) and CharInSet(s[i], [',','.']) and isdig(s[i+1])) then
//      Result := False
     else 
    if i - start > 5 then
    begin
      end_ := i - 1;
      result := True;
    end;
  end; // isUIN

  procedure newLineHeight(v: integer); overload;
  begin
    if lineHeight < v then
      lineHeight := v
  end;

  procedure newLineHeight(const s: string); overload;
  var
    sz: TSize;
  begin
//    cnv.TextHeight(s);
    GetTextExtentPoint32(Cnv.Handle, PChar(s), Length(s), sz);
//    GetTextExtentPoint32(Cnv.Handle, @s[1], Length(s), sz);
    newLineHeight(sz.cy);
  end;

  function addItem(k: TitemKind; o, l: integer; r: Trect): PhistoryItem;
  begin
    inc(Nitems);
    if length(items) < Nitems then
      setLength(items, length(items)+20);
    result := @items[Nitems-1];
    result.kind := k;
    result.ev := ev;
    result.evIdx := evIdx;
    result.ofs := o;
    result.l := l;
    result.r := r;
    if k=PK_LINK then
      result.link := foundLink;
{     if k = PK_ARROWS_DN then
       begin
         hasDownArrow := true;
         hDownArrow := r.Bottom-r.Top;
       end
     else
       hasDownArrow := false; }
  end; // addItem

  procedure removeLastItemsTo(o: integer);
  begin
    if Nitems <= length(items) then
     while (Nitems > 0)and(items[Nitems-1].evIdx = evIdx) and (items[Nitems-1].ofs > o) do
       dec(Nitems);
  end; // addItem

  function withinTheLink(i: integer): boolean;
  begin
    result := (foundLink.from > 0)
              and (i >= foundLink.from)
              and (i <= foundLink.to_)
  end; // withinTheLink

//  function drawBody(cnv:Tcanvas; pTop : Integer) : Integer;
  function drawBody(pTop: Integer): Integer;
  var
    fndSmileI: Integer;
    fndSmile: String;
    fndSmileN: TPicName;
    fndEmoji: String;
    fndEmojiN: TPicName;
    foundPicSize: Integer;
    RnQPicStream: TMemoryStream;
    BodyText: String;
    BodyCurChar: Char;
    BodyCurMChar: String;
    BodyBin: RawByteString;

    i: Integer;

      function findLink(): boolean;

        procedure setResult(lk: TlinkKind; end_: integer=0);
        const
          allowedChars: array [TlinkKind] of set of AnsiChar=( FTPURLCHARS, EMAILCHARS,
            WEBURLCHARS, ['0'..'9'], EDURLCHARS );
        begin
          if end_ = 0 then
            begin
            end_ := i;
            if lk = LK_WWW then
              begin
                while (end_ < length(BodyText)) and not BodyText[end_+1].IsSeparator
                     and not BodyText[end_+1].IsControl do
                 inc(end_);
//                if TCharacter.IsSeparator(BodyText[end_]) then
//                  dec(end_);
              end
             else
              while (end_ < length(BodyText))
//                     and (BodyText[end_+1] in allowedChars[lk]) do
                     and CharInSet(BodyText[end_+1], allowedChars[lk]) do
                inc(end_);
            end;
          if (end_>0) and (end_<=length(BodyText)) then
//            while BodyText[end_] in ['?',')','.',','] do
//            while CharInSet(BodyText[end_], ['?',')','.',',', '/']) do
            while CharInSet(BodyText[end_], ['?',')','.',',']) do
              dec(end_);
          foundLink.str := copy(BodyText, i, end_-i+1);
          foundLink.from := i;
          foundLink.to_ := end_;
          foundLink.kind := lk;
          inc(foundLink.id);
          result := True;
        end;

      var
        e: integer;
      begin
        result := False;
        if linkTheWholeBody > '' then
          begin
          setResult(LK_WWW, length(BodyText));
          foundLink.str := linkTheWholeBody;
          exit;
          end;
        if isEmailAddress(BodyText, i, e) then
          setResult(LK_EMAIL, e)
        else
          case upcase(BodyText[i]) of
            'H':if Imatches(BodyText,i,'http://') or Imatches(BodyText,i,'https://') then
                  setResult(LK_WWW);
            'W':if Imatches(BodyText,i,'www.') {or Imatches(BodyText,i,'web.')} then
                  setResult(LK_WWW);
            'F':if Imatches(BodyText,i,'ftp://') or Imatches(BodyText,i,'ftp.') then
                  setResult(LK_FTP);
            'S':if Imatches(BodyText,i,'sftp://') or Imatches(BodyText,i,'sftp.') then
                  setResult(LK_FTP);
            'E':if Imatches(BodyText,i,'ed2k://') then
                  setResult(LK_ED);
            '1'..'9': if isUIN(BodyText,i,e) then setResult(LK_UIN, e);
            end;
      end; // findLink

      function findFidonet(sym: Char): boolean;
      var
        j: integer;
      begin
        result := False;
        if (BodyText[i] <> sym)
//           or ((i>1) and not (BodyText[i-1] in WHITESPACES)) // word begin
           or ((i>1) and not CharInSet(BodyText[i-1], WHITESPACES)) // word begin
           or (i+2 > length(BodyText)) then
          exit;
        j := i+1;
        while (j<length(BodyText)) and
 {$IFDEF UNICODE}
        (BodyText[j].IsLetterOrDigit)
 {$ELSE UNICODE}
           (BodyText[j] in ALPHANUMERIC)
 {$ENDIF UNICODE}
        do
          inc(j);
        if (BodyText[j]<>sym) or (j-i=1) then
          exit; // ends with sym, and no 2 sym bound
        result := True;
      end; // findFidonet

      function findSmile(): boolean;
      var
        k, l: integer;
        smileCap: string;
 {$IFDEF UNICODE}
//        sA: AnsiString;
 {$ENDIF UNICODE}
        SmileObj: TSmlObj;
      begin
         result := False;
 {$IFDEF UNICODE}
//        sA := BodyText[i];
        if Pos(BodyText[i], firstCharactersForSmilesW)<= 0 then
//        if not (sA[1] in firstCharactersForSmiles) then
          exit;
 {$ELSE nonUNICODE}
        if not (BodyText[i] in  firstCharactersForSmiles) then
          exit;
 {$ENDIF UNICODE}
//        if not CharInSet(BodyText[i], firstCharactersForSmiles) then exit;
        fndSmileN := '';
        fndSmileI := -1;
    //    foundSmileIdx := -1;
        if theme.SmilesCount > 0 then
        for k := 0 to theme.SmilesCount-1 do
         begin
          SmileObj := theme.GetSmileObj(k);
          for l := 0 to SmileObj.SmlStr.Count-1 do
           begin
            smileCap := SmileObj.SmlStr.Strings[l];
            if (smileCap[1] = BodyText[i]) and
                matches(BodyText, i, smileCap) //and (SmileObj.Smile<>NIL)
                and ((fndSmileI=-1) or (length(smileCap) > length(fndSmile))) then
             begin
    //          if (length(s) >= i+length(smileCap))
    //           and (smileCap[1]=':')
    //           and (s[i+length(smileCap)] in ['a'..'z','0'..'9','A'..'Z',#128..#255])
    //           and (smileCap[length(smileCap)]<>s[i+length(smileCap)])
    //          then continue;
               fndSmile := smileCap;
               {$IFDEF RNQ_FULL}
                foundAniSmile := theme.useAnimated AND SmileObj.Animated;
                if foundAniSmile then
                  fndSmileI := SmileObj.AniIdx
                else
               {$ENDIF RNQ_FULL}
                 fndSmileI := k;
               fndSmileN := theme.GetSmileName(k);
    //           foundSmileIdx:=k;
               result := True;
             end;
           end;
         end;
      end; // findSmile

      function findEmoji(): boolean;
      var
        k, l: integer;
      begin
         result := False;
         if (Length(BodyCurMChar)=1) and (i+1 <= Length(BodyText))
           and (CharInSet(BodyCurChar, ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '#', '*'])
              and (ord(BodyText[i+1]) = $20E3)) then
           begin
             fndEmoji := BodyCurMChar + BodyText[i+1];
           end
          else
         if (Length(BodyCurMChar)=2) and (i+3 <= Length(BodyText))
           and IsSurrogate(BodyText, i+2) and IsSurrogatePair(BodyText, i+2)
           and (IsHighSurrogate(BodyText, i+2)) and (IsLowSurrogate(BodyText, i+3))
           and ((InRange(ord(ConvertToUtf32(BodyText, i)), $1f100, $1f1ff) and InRange(ord(ConvertToUtf32(BodyText, i+2)), $1f100, $1f1ff))
               or (ord(ConvertToUtf32(BodyText, i+2)) = $1f5e8))
          then
             fndEmoji := BodyCurMChar + BodyText[i+2] + BodyText[i+3]
         else
            fndEmoji := BodyCurMChar;
         if EmojiList.TryGetValue(fndEmoji, fndEmojiN) then
           begin
             fndEmojiN := TE2Str[RQteEmoji]+ fndEmojiN;
             if theme.picExists(RQteDefault, fndEmojiN) then
               Result := True;
           end;
         if not Result then
           begin
             fndEmoji := '';
             fndEmojiN := '';
           end;
      end; // findEmoji

      function findRnQPic(): boolean;
      var
        k: integer;
      begin
        result := False;
        if (BodyBin[i] <> '<') then
          exit;
//        foundRnQPic := '';
        FreeAndNil(RnQPicStream);
        if matchesA(BodyBin, i, RnQImageTag) then
          begin
            k := PosEx(RnQImageUnTag, BodyBin, i+10);
            if k <= 0 then
              exit;
            foundPicSize := k-i-10;
            RnQPicStream := TMemoryStream.Create;
            RnQPicStream.SetSize(foundPicSize);
            RnQPicStream.Write(BodyBin[i+10], foundPicSize);
//            foundRnQPic:=Copy(s, i+10, k-i-10);
            result := True;
          end;
      end; // findRnQPic

      function findRnQPicEx(): boolean;
      const
        Length_RnQImageExTag = Length(RnQImageExTag);
      var
        k: integer;
        OutSize: DWord;
        PIn, POut: Pointer;
      begin
        result := False;
        if (BodyBin[i] <> '<') then
          exit;
//        foundRnQPic:='';
        FreeAndNil(RnQPicStream);
        if matchesA(BodyBin, i, RnQImageExTag) then
          begin
            k := PosEx(RnQImageExUnTag, BodyBin, i + Length_RnQImageExTag);
            if k <= 0 then
              exit;
            foundPicSize := k-i- Length_RnQImageExTag;
            if (foundPicSize > 0) then
            begin
              try
                PIn := @BodyBin[i+ Length_RnQImageExTag];
                // calculate size for destination
                OutSize := CalcDecodedSize(PIn, foundPicSize);
                // prepare string length to fit result data
                RnQPicStream := TMemoryStream.Create;
                RnQPicStream.SetSize(OutSize);
                RnQPicStream.Position := 0;
                POut := RnQPicStream.Memory;
                // decode !
//                Base64Decode(PIn, foundPicSize, POut);
                Base64Decode(PIn^, foundPicSize, POut^); // Since EurekaLog 6.22 need "^"
                result := True;
              except
                  try
                    FreeAndNil(RnQPicStream);
                    result := false;
                   except
                  end;
              end;
            end;
          end;
      end; // findRnQPicEx

      procedure newLineB(var x, y: Integer);
      var
        k: Integer;
      begin
        if bodySkipCounter <= 0 then
          begin
//            if JustCalc then
//             begin
//              k := Length(ev.preCalcHeights);
//              SetLength(ev.preCalcHeights, k+1);
//              ev.preCalcHeights[k] := lineHeight;
//             end;
            newLineH(x, y);
          end
         else
          begin
            inc(skippedLines);
            dec(bodySkipCounter);
            k := 0;
            newLineH(x, k);
          end;
      end; // newLineB

  var
    quoteCounting: boolean;
    quoteCounter: Integer;
    r, intersect: Trect;
    nowPos: ThistoryPos;
    PntFontIdx: Byte;

    function withinTheSelection(pi: integer): boolean;
    begin
      nowPos.evIdx := evIdx;
      nowPos.ev := ev;
      nowPos.ofs := pi;
      result := (SOS.ev<>NIL) and (EOS.ev<>NIL) and
                 (
                   (SOS.ofs<0) and within(SOS.evIdx, evIdx, EOS.evIdx)
                    or not minor(EOS, nowPos) and minor(SOS, nowpos)
                  );
    end;

    procedure applyFont();
    var
      newPntFontIdx: Byte;
    begin
//      cnv.font.Assign(Screen.MenuFont);
//      theme.applyFont(ev.useFont, cnv.font);
//      ev.applyFont(cnv.font);
      if ev.isMyEvent then
        newPntFontIdx := 1
       else
        newPntFontIdx := 2;
      if quoteCounter <> 0 then
        if odd(quoteCounter) xor ev.isMyEvent then
          newPntFontIdx := 3
        else
          newPntFontIdx := 4;
      if PntFontIdx <> newPntFontIdx then
      begin
        PntFontIdx := newPntFontIdx;
        cnv.font.Assign(ev.getFont);
        case newPntFontIdx of
          3: theme.applyFont('history.my.quoted', cnv.font);
          4: theme.applyFont('history.his.quoted', cnv.font);
        end;
       applyUserCharset(font);
      end;
      with cnv.Font do
       begin
        if nowBold then
           begin
            if not(fsBold in style) then
             style := style + [fsBold];
           end;
//          else
//            if (fsBold in style) then
//             style := style - [fsBold];
        if nowUnderline then
          begin
           if not(fsUnderline in style) then
            style := style + [fsUnderline];
          end;
//         else
//           if (fsUnderline in style) then
//            style := style - [fsUnderline];
       end;
      if nowLink then
        theme.applyFont('history.link', cnv.font);
    end; // applyFont
  var
    whatFound: ( _nothing, _wrap, _return, _smile, _link, _bold, _underline,
                 _RnQPic, _RnQPicEx, _aniSmile, _emoji );
    tempColor: TColor;
    chunkStart: Integer;
    len, smileCount: integer;
    size, tempSize: Tsize;
    lastLineStart: Integer;
    lastSmileChar: char;
    fndSmlT2: TPicName;
    fndSmlIT: Integer; fndAniSmlT: Boolean;
    first, bool, wasInsideSelection: boolean;
    SelectionStartPos, SelectionEndPos: Integer;
    k, lx: Integer;


//    vDBPic: TBitmap;
    vPicElm: TRnQThemedElementDtls;
//    vPicLoc: TPicLocation;
//    vThemeTkn: Integer;
//    vPicIdx: Integer;
//    vPicName: String;
    x, y: Integer;
    vRnQPic: TBitmap;
//    gr: TGPGraphics;
    vRnQpicEx: TRnQBitmap;
    hnd: HDC;
    pt: TPoint;

  begin
    x := margin.left;
    y := pTop;
    RnQPicStream := NIL;
    eventFullyPainted := False;
    if JustCalc then
      if (ev.HistoryToken = history.Token) then
       begin
         Result := ev.PaintHeight;
         inc(y, Result);
         if (y <= bottomLimit) then
           eventFullyPainted := True;
         Exit;
       end;
    BodyText := ev.getBodyText;
//    BodyBin  := ev.bInfo;
    BodyBin  := ev.getBodyBin;
    if ((Length(BodyText) = 0) and (Length(BodyBin) <= 10)) or (y >= bottomLimit) then
     begin
      ev.HistoryToken := history.Token;
      ev.PaintHeight := 0;
      Result := 0;
      if (y <= bottomLimit) then
         eventFullyPainted := True;
      exit;
     end;
  // draw upward arrows
    if firstEvent and (topOfs > 0) then
      begin
        bodySkipCounter := topOfs;
        if not pleaseDontDrawUpwardArrows then
        begin
  //        vDBPic := TBitmap.Create;
  //        theme.getPic(PIC_SCROLL_UP, pic);
  //        theme.getPic(PIC_SCROLL_UP, vDBPic);
          vPicElm.picName := PIC_SCROLL_UP;
          vPicElm.ThemeToken := -1;
          vPicElm.Element := RQteDefault;
          x := margin.left;
          with theme.GetPicSize(vPicElm, 0, PPI) do
           begin
  //        i := vDBPic.Width;
             if not JustCalc then
              begin
               r := rect(x, y, rightLimit, y+cy);
               addItem(PK_ARROWS_UP, 0, 0, r);
               hnd := Cnv.Handle;
               pt.Y := y;
               pt.X := x;
               while pt.X < rightLimit do
                begin
                  theme.drawPic(hnd, pt, vPicElm, PPI);
                  inc(pt.X, cx);
                end;
              end;
             vPicElm.ThemeToken := -1;
             inc(y, cy);
  //        freeAndNil(vDBPic);
           end;
        end;
      end
     else
      bodySkipCounter := 0;

    quoteCounter := 0;
    whatFound := _nothing;
    PntFontIdx := 101;
    i := 1;
    foundLink.from := 0;
    lastLineStart := 1;
    lineHeight := 0;
    x := margin.left;
    cnv.brush.color := TextBGColor; //history.bgcolor;
  //  cnv.font.assign(ev.font);
    wasInsideSelection := False;
    len := length(BodyText);
    quoteCounting := True;
    nowBold := False;
    nowUnderline := False;
    nowLink := False;
    // loop until there's text to be painted
    while (y < bottomLimit) and (i <= len) do
     begin
      chunkStart := i;
      case whatFound of
        _nothing:
          begin
           applyFont();
           lx := x;
           // go forth, until sth special is found
           while i <= len do
            begin
              // reached the end of the link, stop, we must paint it underlined
              if (foundLink.from > 0) and (i > foundLink.to_) then
               begin
    //            nowLink := False;
                if (foundLink.kind <> LK_UIN) then
                  whatFound := _link;
                break;
               end;

              BodyCurChar := BodyText[i];
              if BodyCurChar.IsSurrogate then
                begin
                 k := i+1;
                  while (k<=Length(BodyText)) and BodyText[k].IsLowSurrogate do
                   inc(k);
                 dec(k);
                 boundInt(k, i, Length(BodyText));
                 BodyCurMChar := Copy(BodyText, i, k-i+1);
                end
               else
                BodyCurMChar := BodyCurChar;

              // reached a selection edge, stop, we must paint it selected
              bool := withinTheSelection(i);
              if wasInsideSelection <> bool then
                begin
                 wasInsideSelection := bool;
                 if bool then
                   begin
                     SelectionStartPos := i;
  //                   inc(i, Length(BodyCurMChar));
                   end
                  else
                   begin
  //                   inc(i, Length(BodyCurMChar)-1);
                     SelectionEndPos := i;
  //                   inc(i);
                   end;
                 break;
                end;

              // things to consider only outside a link
              if foundLink.from = 0 then
                begin
  //                  if BodyCurChar in [#10, #13] then
                    if CharInSet(BodyCurChar, [#10, #13]) then
                    begin
                      whatFound := _return;
                      break
                    end;
                    if useSmiles and findSmile() then
                    begin
                      whatFound := _smile;
                      break
                    end;
                    if EmojiAsPic and findEmoji() then
                    begin
                      whatFound := _emoji;
                      break
                    end;
    //            if findRnQPic() then begin whatFound:=_RnQPic; break end;
    //            if findRnQPicEx() then begin whatFound:=_RnQPicEx; break end;
                if BodyCurChar < #32 then
                  begin
                   BodyText[i] := #32; // convert control chars
                   BodyCurChar := #32;
                  end;
                if findLink() and (foundLink.kind <> LK_UIN) then
                  begin
    //                nowLink := True;
                    whatFound := _link;
    //                chunkStart := i;
                    break;
                  end;
                if quoteCounting then
                  if BodyCurChar = '>' then
                    inc(quoteCounter)
                   else
                    { quoting sequence terminates where a non-">" char is found
                    { or a non-single blankspace is found or a non-">"-preceeded
                    { blankspace is found }
                    if (BodyCurChar<>' ') or (quoteCounter=0) or (i=1) or (BodyText[i-1]<>'>') then
                      quoteCounting := False;
                if fontstylecodes.enabled then
                  begin
                  if (BodyCurChar='*') and (nowBold or findFidonet('*')) then
                      begin
                        whatFound := _bold;
                        break
                      end;
                  if (BodyCurChar='_') and (nowUnderline or findFidonet('_')) then
                      begin
                        whatFound := _underline;
                        break
                      end;
                  end;
                end;
              applyFont();
              size := txtSizeL(Cnv.Handle, @BodyCurMChar[1], Length(BodyCurMChar));
              inc(lx, size.cx);
              if lx > rightLimit then // no more room
               begin
                // search backward for a good place where to split
                k := i;
                repeat
                  dec(k)
                until (k=lastLineStart) or
  //                    (BodyText[k] in ['-', ' ', ',', ';', '.']);
                      CharInSet(BodyText[k], ['-', ' ', ',', ';', '.']);
                // found. choose it
                if k>chunkStart then
                  i := k+1
                 else
                  if i = lastLineStart then
                   inc(i);
                removeLastItemsTo(i);
                whatFound := _wrap;
                break
               end;
              if not JustCalc then
               begin
                r := rect(lx-size.cx, y, lx, y+size.cy);
                if bodySkipCounter<=0 then
                  if withinTheLink(i) then
                    addItem(PK_LINK, i, Length(BodyCurMChar), r)
                   else
                    addItem(PK_TEXT, i, Length(BodyCurMChar), r);
               end;
              inc(i, Length(BodyCurMChar));
            end; //while
          // no text, suddenly a break comes
            if i = chunkStart then
              continue;

            k := i-chunkStart; // = length of text
            applyFont();
            size := txtSizeL(Cnv.Handle, @BodyText[chunkStart], k); // size on screen
          // is it a link?
            if withinTheLink(chunkStart)
              and (evIdx = linkToUnderline.evIdx)
              and within(linkToUnderline.from, chunkStart, linkToUnderline.to_) then
             with cnv.font do
              begin
               style := style+[fsUnderline];
               PntFontIdx := 100;
              end;
  //          newLineHeight('I');
            newLineHeight(size.cy);
            if withinTheSelection(chunkStart) then
              cnv.brush.color := selectedClr
             else
              cnv.brush.color := TextBGColor;
          // finally paint the text
  //        if bodySkipCounter<=0 then textOut(cnv.handle, x,y+lineHeight-size.cy, @s[chunkStart], k);
            if bodySkipCounter<=0 then
             begin
              if not withinTheSelection(chunkStart) then
                begin
                 oldMode := SetBKMode(Cnv.Handle, TRANSPARENT);
                 textOut(Cnv.Handle, x, y, @BodyText[chunkStart], k);
     //            SetBKMode(cnv.Handle, oldMode);
                end
               else
                textOut(Cnv.Handle, x, y, @BodyText[chunkStart], k);
             end;
            inc(x, size.cx);
            if (i > foundLink.to_) then
              foundLink.from := 0;
            continue;
          end;
        _link:
          begin
  //         inc(i);
           nowLink := not nowLink;
           PntFontIdx := 100;
          end;
        _underline:
          begin
           inc(i);
           nowUnderline := not nowUnderline;
           PntFontIdx := 100;
          end;
        _bold:
          begin
           inc(i);
           nowBold := not nowBold;
           PntFontIdx := 100;
          end;
        _return:
          begin
            case BodyText[i] of
              #10: inc(i);
              #13: begin
                    inc(i);
                    if (i<=len) and (BodyText[i]=#10) then inc(i);
                   end;
             end;
            if nowBold or nowUnderline or nowLink or (quoteCounter > 0) then
             begin
              nowBold := False;
              nowUnderline := False;
              nowLink := False;
              quoteCounter := 0;
              PntFontIdx := 100;
             end;

            quoteCounting := True;
            newLineHeight('I');
            lastLineStart := i;
            newLineB(x, y);
          end;
        _smile:
          begin
            // count times smile has to be repeated by last character
            if Length(fndSmile) = 0 then
              break;
            smileCount := 1;
            k := length(fndSmile);
            inc(i, k);
            lastSmileChar := fndSmile[k];
  //          fndSmlT1 := fndSmile;
            fndSmlT2 := fndSmileN;
            fndSmlIT := fndSmileI;
            fndAniSmlT := foundAniSmile;
  //          bool := lastSmileChar in firstCharactersForSmiles;
            bool := Pos(lastSmileChar, firstCharactersForSmilesW)>0;
            while (i<=len) and (BodyText[i]=lastSmileChar) do
             begin
              if bool and findSmile() then
                break;
              inc(i);
              inc(smileCount);
             end;
  //          fndSmile  := fndSmlT1;
            fndSmileN := fndSmlT2;
            fndSmileI := fndSmlIT;
            foundAniSmile := fndAniSmlT;
            tempSize := theme.GetPicSize(RQteSmile, fndSmileN, 0, PPI);
            newLineHeight(tempSize.cy+2);

           // paint
  //            size.cx := tempSize.cx+1;
  //            size.cy := tempSize.cy;
              size := tempSize;
              inc(size.cx);
              cnv.brush.color := selectedClr;
              first := True;
              while smileCount > 0 do
               begin
                if x+size.cx > rightLimit then
                  begin
                   newLineB(x, y);
                   newLineHeight(tempSize.cy+1);
                  end;
                // only the first one has full length
  //              if first then j:=length(fndSmile) else j:=1;
                if not first then
                  k := 1;
                if not JustCalc then
                 begin
                  r := rect(x, y, x+size.cx, y+size.cy + 1);
                  if bodySkipCounter<=0 then
                    begin
                     addItem( PK_SMILE, chunkStart, k, r);
                     begin
                      if withinTheSelection(chunkStart) then
                        begin
  //                       if not JustCalc then
                          cnv.fillRect(r);
                         {$IFDEF RNQ_FULL}
                          if foundAniSmile then
                            tempColor := selectedClr;
                         {$ENDIF RNQ_FULL}
                        end
                    {$IFDEF RNQ_FULL}
                       else
                        if foundAniSmile then
                          tempColor := color;
    //                      tempColor := theme.GetAColor(ClrHistBG, clWindow);
                      if foundAniSmile then
                        begin
  //                       if not JustCalc then
                         begin
                          theme.AddAniParam(fndSmileI,
                             MakeRect(x, y+(lineHeight-size.cy) div 2, size.cx, size.cy),
      //                       gpColorFromAlphaColor($FF, tempColor)
                             tempColor, canvas, cnv, tempColor <> color);

      //                    theme.drawPic(cnv, x, y+(lineHeight-size.cy) div 2, )
                          SetStretchBltMode(Cnv.Handle, HALFTONE);
                          with theme.GetAniPic(fndSmileI) do
                            StretchDraw(Cnv.Handle, MakeRect(x, y+(lineHeight-size.cy) div 2, size.cx, size.cy));
                         end;
                        end
                         else
                    {$ELSE RNQ_FULL}
                      ;
                    {$ENDIF RNQ_FULL}
  //                     if not JustCalc then
                        theme.drawPic(Cnv.Handle, x, y+(lineHeight-size.cy) div 2, fndSmileN, True, PPI);
    //                    cnv.draw(x,y+(lineHeight-size.cy) div 2, vDBPic);
                     end;
                    end;
                 end; // endif not JustCalc
  //          inc(chunkStart);
            inc(chunkStart, k);
            inc(x, size.cx);
            first := False;
            dec(smileCount);
            end;
  //         freeAndNil(vDBPic);
          end;
        _emoji:
          begin
            tempSize := theme.GetPicSize(RQteDefault, fndEmojiN, 0, PPI);
            k := length(fndEmoji);
            inc(i, k);
            newLineHeight(tempSize.cy+2);

           // paint
              size := tempSize;
              inc(size.cx);
              if not JustCalc then
                begin
                  cnv.brush.color := selectedClr;
                  r := rect(x, y, x+size.cx, y+size.cy + 1);
                  if bodySkipCounter<=0 then
                    begin
                      addItem( PK_SMILE, chunkStart, k, r);
                      if withinTheSelection(chunkStart) then
                          cnv.fillRect(r);
                     theme.drawPic(Cnv.Handle, x, y+(lineHeight-size.cy) div 2, fndEmojiN, True, PPI);
                    end;
                end; // endif not JustCalc
            inc(chunkStart, k);
            inc(x, size.cx);
          end;
        _wrap:
          begin
            newLineB(x, y);
            lastLineStart := i;
          end;
        end; //case
      whatFound := _nothing;
      end; //while

    eventFullyPainted := (i > len) and (y <= bottomLimit);

 ////////////////////// Processing Binaries ////////////////////////////
    len := length(BodyBin);
    i := len+1;
    if len > 10 then
  //  if 1=2 then
      begin
        i := 1;
        newLineB(x, y);
        whatFound := _nothing;
    //    PntFontIdx := 101;
    //    foundLink.from:=0;
    //    lastLineStart:=1;
        lineHeight := 0;
        x := margin.left;
    //    cnv.brush.color := TextBGColor; //history.bgcolor;
      //  cnv.font.assign(ev.font);
    //    wasInsideSelection:=FALSE;

        while (y < bottomLimit) and (i <= len) do
         begin
          chunkStart := i;
          case whatFound of
            _nothing:
              begin
               lx := x;
               // go forth, until sth special is found
               while i <= len do
                begin
                 // reached a selection edge, stop, we must paint it selected
     {            bool := withinTheSelection(i);
                 if wasInsideSelection <> bool then
                  begin
                   wasInsideSelection := bool;
                   break;
                  end;}
                // things to consider only outside a link
    //              if BodyBin[i] in [#10,#13] then begin whatFound:=_return; break end;
                 if findRnQPic() then
                   begin
                     whatFound := _RnQPic;
                    break
                   end;
                  if findRnQPicEx() then
                   begin
                    whatFound := _RnQPicEx;
                    break
                   end;
                  if BodyBin[i] < #32 then
                    BodyBin[i] := #32; // convert control chars
      {          if j > rightLimit then // no more room
                  begin
                  // search backward for a good place where to split
                  j:=i;
                  repeat dec(j) until (j=lastLineStart) or (BodyText[j] in ['-',' ']);
                  // found. choose it
                  if j>chunkStart then
                    i:=j+1
                   else
                    if i = lastLineStart then
                     inc(i);
                  whatFound := _wrap;
                  break
                  end;}
                 inc(i);
               end; //while
              // no text, suddenly a break comes
              if i = chunkStart then
                continue;
    {
                if withinTheSelection(chunkStart) then
                  cnv.brush.color := selectedClr
                 else
                  cnv.brush.color := TextBGColor;}
        //        inc(x, size.cx);
                continue;
              end;
            _return:
              begin
                case BodyBin[i] of
                  #10: inc(i);
                  #13: begin
                         inc(i);
                         if (i<=len) and (BodyBin[i]=#10) then
                           inc(i);
                       end;
                  end;
                if nowBold or nowUnderline or nowLink or (quoteCounter > 0) then
                 begin
                  nowBold := False;
                  nowUnderline := False;
                  nowLink := False;
                  quoteCounter := 0;
                  PntFontIdx := 100;
                 end;

                quoteCounting := True;
                newLineHeight('I');
                lastLineStart := i;
                newLineB(x, y);
              end;
            _RnQPic:
              begin
                vRnQPic := NIL;
                inc(i, foundPicSize + length(RnQImageTag) + length(RnQImageUnTag));
                size := wbmp2bmp(RnQPicStream, vRnQPic, JustCalc);
                if Assigned(vRnQPic) or JustCalc then
                 begin
                  newLineHeight(size.cy + 1);
                   // paint
                  if not JustCalc then
                   begin
                    cnv.brush.color := selectedClr;
                    // only the first one has full length
                    r := rect(x, y, x+size.cx + 1, y+size.cy);
                    if bodySkipCounter<=0 then
                      begin
                        k := foundPicSize + length(RnQImageTag) + length(RnQImageUnTag);
                        addItem( PK_RQPIC, chunkStart, k, r);
                        if withinTheSelection(chunkStart) then
                          cnv.fillRect(r);
    //                  if not JustCalc then
                         cnv.draw(x, y+(lineHeight-size.cy) div 2, vRnQPic);
                      end;
                  end;
                  inc(chunkStart);
                  inc(x, size.cx+1);
          //          end;
                  if Assigned(vRnQPic) then
                    vRnQPic.Free;
                  vRnQPic := NIL;
                end;
              end;
            _RnQPicEx:
              begin
               inc(i, foundPicSize + length(RnQImageExTag) + length(RnQImageExUnTag));

       //        RnQPicStream := TMemoryStream.Create;
       //        RnQPicStream.SetSize(foundPicSize);
       //        RnQPicStream.Write(foundRnQPic[1], Length(foundRnQPic));

               vRnQpicEx := nil;
       //        if Assigned(RnQPicStream) then
       //          RnQPicStream.position := 0;
               if loadPic(TStream(RnQPicStream), vRnQpicEx, 0, PA_FORMAT_UNK, 'RnQImageEx') then
                begin
    //             size.cx:=vRnQpicEx.getWidth+1;
    //             size.cy:=vRnQpicEx.getHeight;
                 size := BoundsSize(vRnQpicEx.getWidth + 1, vRnQpicEx.getHeight, MaxChatImgWidthVal, MaxChatImgHeightVal);
                 newLineHeight(size.cy+1);
                 // paint
                 if not JustCalc then
                  begin
                   // only the first one has full length
                   r := rect(x, y, x+size.cx, y+size.cy);
                   if bodySkipCounter<=0 then
                    begin
                      k := foundPicSize + 25; // 25=length(RnQImageExTag) + length(RnQImageExUnTag);
                      addItem( PK_RQPICEX, chunkStart, k, r);
      //                if not JustCalc then
                       begin
                         if withinTheSelection(chunkStart) then
                          begin
                           cnv.brush.color := selectedClr;
                           cnv.fillRect(r);
                          end;
                         cnv.Lock;
                         DrawRbmp(Cnv.Handle, vRnQpicEx,
                                  MakeRect(x, y+(lineHeight-size.cy) div 2, size.cx, size.cy));
      //                   gr := TGPGraphics.Create(cnv.Handle);
      //                   gr.DrawImage(vRnQpicEx, x,y+(lineHeight-size.cy) div 2, size.cx, size.cy);
      //                   gr.Free;
                         cnv.Unlock;
      //                   cnv.draw(x,y+(lineHeight-size.cy) div 2, vRnQPic);
                       end;
                    end;
                 end;
               if Assigned(vRnQpicEx) then
                 vRnQpicEx.Free;
               vRnQpicEx := NIL;
               inc(chunkStart);
               inc(x, size.cx);
               RnQPicStream := NIL; // It's already freed in loadPic
               // Draw Button
   {            newLine(x, y);
               newLineHeight( 21+1);
               r := rect(x,y,x+90,y+21);
               addItem( PK_RNQBUTTON, chunkStart,j, r);
               RnQButtonDrawFull(cnv, r, getTranslation('Save'), blGlyphLeft, 3,
                    3, bsUp, False, False, DrawTextBiDiModeFlags(0), 'save',
                    vThemeTkn, vPicLoc, vPicIdx);
      }
                end
               else
                try
                  FreeAndNil(RnQPicStream);
                 except
                end;
    //          end;
    //         freeAndNil(vRnQPic);
              end;
            _wrap:
              begin
                newLineB(x, y);
                lastLineStart := i;
              end;
            end;//case
          whatFound := _nothing;
         end;
      end; //while
    if Assigned(RnQPicStream) then
      FreeAndNil(RnQPicStream);

    newLineB(x, y);
    Result := y - pTop;
    ev.HistoryToken := history.Token;
    ev.PaintHeight := Result;
    if eventFullyPainted and (i > len) and (y <= bottomLimit) then
      begin
       eventFullyPainted := True;
       exit;
      end;
    // downward arrows
    vPicElm.ThemeToken := -1;
    vPicElm.PicName := PIC_SCROLL_DOWN;
    vPicElm.Element := RQteDefault;
    with theme.GetPicSize(vPicElm, 0, PPI) do
     begin
      x := margin.left;
      y := bottomLimit - cy;
      if not JustCalc then
       begin
        r := rect(x, y, rightLimit, y+cy);
        while (Nitems > 0) and intersectRect(intersect, items[Nitems-1].r, r) do
          dec(Nitems);
        addItem(PK_ARROWS_DN, 0, 0, r);
        pt.Y := y;
        pt.X := x;
        hnd := cnv.Handle;
        while pt.x < rightLimit do
         begin
          theme.drawPic(hnd, pt, vPicElm, PPI);
          inc(pt.x, cx);
         end;
       end;
      vPicElm.ThemeToken := -1;
      inc(y, cy);
     end;
  end; // drawBody

//  function drawHeader(cnv: Tcanvas; pTop: Integer): Integer;
  function drawHeader(pTop: Integer): Integer;
  var
    curX, curY, LeftX: integer;
    sz: TSize;
    s: String;
    pic1, pic2: TPicName;
  begin
    lineHeight := 0;
    curX := margin.left;
    curY := pTop;
//    cnv.brush.color := TextBGColor;
//    c := ev.who;
  // shall we paint the header as selected?
    if not JustCalc then
      if wholeEventsAreSelected and within(SOS.evIdx, evIdx, EOS.evIdx) then
        cnv.brush.color := selectedClr
       else
        SetBKMode(Cnv.Handle, TRANSPARENT);
  /// draw header

    with ev.PicSize(PPI) do
    begin
     if not JustCalc then
       ev.Draw(Cnv.Handle, curX, curY, PPI);
     inc(curX, cx + 3);
     newLineHeight(cy);
    end;

    if IF_Encrypt and ev.flags > 0 then // Сообщение было шифрованным
     with theme.GetPicSize(vKeyPicElm, 0, PPI) do
     begin
      if not JustCalc then
        theme.drawPic(Cnv.Handle, Point(curX, curY), vKeyPicElm, PPI);
      inc(curX, cx + 3);
      newLineHeight(cy);
     end;
//    cnv.font.assign(ev.font);
//     cnv.font.Assign(Screen.MenuFont);
//     ev.applyfont(cnv.font);
     cnv.font.Assign(ev.getFont);
    applyUserCharset(cnv.font);
//    newLineHeight('I');
    s := 'I';
    GetTextExtentPoint32(Cnv.Handle, PChar(s), Length(s), sz);
    newLineHeight(sz.cy+1);
    if not JustCalc then
    begin
//     ts := ev.getHeaderText;
//     cnv.textOut(curX, curY + 1, ts);
     cnv.textOut(curX, curY + (lineHeight - sz.cy), ev.getHeaderText);
     curX := cnv.penpos.x;

   // some events draws an extra icon on the right
     case ev.kind of
       EK_ONCOMING,
       EK_STATUSCHANGE,
       EK_XstatusMsg,
       EK_OFFGOING:
         begin
           who.fProto.EventExtraPics(ev.kind, ev.getBodyBin,
            pic1, pic2);
           if pic1 > '' then
             with theme.drawPic(Cnv.Handle, curX+2, curY, pic1, True, PPI) do
               inc(curX, cx+2);

           if pic2 > '' then
             with theme.drawPic(Cnv.Handle, curX+2, curY, pic2, True, PPI) do
               inc(curX, cx+2);
         end;
     end;
    end;

    if not JustCalc then
     begin
      addItem(PK_HEAD, -1, 0, rect(margin.left, curY, curX, curY+lineHeight));
      LeftX := curX;
     end;
    inc(lineHeight);
    newLineH(curX, curY);
  // underline
    if not JustCalc then
    begin
      cnv.pen.color := selectedClr;
      cnv.moveTo(0, curY-1); cnv.lineTo(LeftX, curY-1);
    end;
    inc(curY, 1);

    Result := curY - pTop;
  end; // drawHeader


var
  i, ii: Integer;
//  gr: TGPGraphics;
//  dc: HDC;
  hls: Thls;
  y: Integer;
  tempS: String;
  lGapBtwMsg: Integer;
  vFullR, R: TRect;
  smlRefresh: Boolean;
//  ch: AnsiChar;
 {$IFDEF UNICODE}
//  chU: Char;
//  sA: AnsiString;
 {$ENDIF UNICODE}
begin
  if ((Self.Width <> lastWidth)//or(Self.Height <> lastHeight)
     )
     or (history.themeToken <> theme.token)or(history.SmilesToken <> theme.token) then
   begin
    inc(history.fToken);
    history.themeToken := theme.Token;
    history.SmilesToken := theme.Token;
    lastWidth   := Self.Width;
//    lastHeight  := Self.Height;
   end;
  smlRefresh := history.SmilesToken <> theme.Token;
// finds all first characters of all smiles
 {$IFDEF UNICODE}
  if smlRefresh or (firstCharactersForSmilesW='') then
   begin
    firstCharactersForSmilesW := '';
    for i := 0 to theme.SmilesCount-1 do
     with theme.GetSmileObj(i) do
      for ii := 0 to SmlStr.Count-1 do
       begin
        if Pos(SmlStr.Strings[ii][1], firstCharactersForSmilesW)<=0 then
          firstCharactersForSmilesW := firstCharactersForSmilesW + SmlStr.Strings[ii][1];
       end;
   end;

 {$ELSE nonUNICODE}

  if smlRefresh or (firstCharactersForSmiles=[]) then
   begin
    firstCharactersForSmiles := [];
    for i := 0 to theme.SmilesCount-1 do
  // if theme.GetSmile(i)<>NIL then //smiles.pics[i]<>NIL then
     with theme.GetSmileObj(i) do
      for ii := 0 to SmlStr.Count-1 do
       begin
        ch := SmlStr.Strings[ii][1];
        include(firstCharactersForSmiles, ch); //smiles.ascii[i][1]);
       end;
   end;
 {$ENDIF UNICODE}
//  vCnvHandle := cnv.Handle;
  vFullR := cnv.ClipRect;
  if (vR.Right - vR.Left = 0)or(vR.Bottom - vR.Top = 0) then
    Exit;
//  vCnvHandle := Cnv.Handle;
  if not JustCalc then
   begin
    theme.ClearAniParams;
    SetBKMode(Cnv.Handle, TRANSPARENT);
//   end;
//  if not JustCalc then
//  begin
//    if (vR.Left =0) and (vR.Top =0)and
//       (vR.Right > 0)and(vR.Bottom > 0)  then
//    begin
     {$IFDEF RNQ_FULL}
      if Assigned(theme.AnibgPic)and
         (theme.AnibgPic.Width = vFullR.Right)and
         (theme.AnibgPic.Height = vFullR.Bottom)and(history.themeToken = lastBGToken)
         and(not UseContactThemes  or (Self.who = lastBGCnt))
      then
        BitBlt(Cnv.Handle, vR.Left, vR.Top, vR.Right - vR.Left, vR.Bottom - vR.Top,
               theme.AnibgPic.Canvas.Handle, vR.Left, vR.Top, SRCCOPY)
//        BitBlt(cnv.Handle, 0, 0, vFullR.Right, vFullR.Bottom,
//               rqSmiles.AnibgPic.Canvas.Handle, 0, 0, SRCCOPY)
       else
        begin
          lastBGCnt := Self.who;
          lastBGToken := history.themeToken;
//         if (vR.Right > rqSmiles.AnibgPic.Width)
//            or (vR.Bottom > rqSmiles.AnibgPic.Height) then
//          begin
//             if Assigned(rqSmiles.AnibgPic) then
//               rqSmiles.AnibgPic.Free;
//             rqSmiles.AnibgPic := NIL;
//           rqSmiles.AnibgPic := createBitmap(vR.Right, vR.Bottom);
//          end;
     {$ENDIF RNQ_FULL}
          DoBackground(cnv, vR, theme.AnibgPic, PPI);
          theme.AnibgPicPPI := PPI;
     {$IFDEF RNQ_FULL}
        end;
      {$ENDIF RNQ_FULL}
   end;

  if not JustCalc then
   begin
    Nitems := 0;
    setLength(items, 0);
    cnv.brush.color := TextBGColor;
   end;
  P_lastEventIsFullyVisible := False;
  P_bottomEvent := -1;

{  cnv.FillRect(margin);

  if not avoidErase then cnv.fillRect(clientRect);

}
  if topVisible < offset then
    begin
//     if co then
      exit;
    end;

// sort startsel and endSel
  if minor(startSel, endSel) then
  begin
    SOS := startSel;
    EOS := endSel;
  end
  else
  begin
    SOS := endSel;
    EOS := startSel;
  end;
  if not JustCalc then
  begin
  // calculates a darker/brighter color
    hls := color2hls(TextBGColor);
    with hls do
     if l>0.5 then
       l := l-0.2
      else
       l := l+0.2;
    selectedClr := hls2color(hls);
  end;
//  if selectedClr = TextBGColor then
//    selectedClr := clMenuHighlight;
  margin := rect(2, 2, 2, 2);
  mouse := screenToClient(mousePos);

  rightLimit := clientWidth-margin.Right;
  bottomLimit := clientHeight-margin.Bottom-2;
  if MainPrefs.getPrefBoolDef('chat-images-limit', True) then
    begin
     MaxChatImgWidthVal := MainPrefs.getPrefIntDef('chat-images-width-value', 300);
     MaxChatImgHeightVal := MainPrefs.getPrefIntDef('chat-images-height-value', 300);
    end
   else
    begin
     MaxChatImgWidthVal := 30000;
     MaxChatImgHeightVal := 30000;
    end;

  tempS := theme.GetString('history.gap-between-messages');
  lGapBtwMsg := bound(StrToIntDef(tempS, 1), 0, 30);
//  bottomLimit := vR.Bottom - vr.Top-margin.bottom - 10;
  y := margin.Top;
  evIdx := topVisible;
  foundLink.id := 0;
  Nrows := 0;
  if not JustCalc then
    P_topEventNrows := 0;
  firstEvent := True;
  skippedLines := 0;
  pleaseDontDrawUpwardArrows := False;
  EmojiAsPic := MainPrefs.getPrefBoolDef('hist-emoji-draw', True);

  while (y < bottomLimit) and (evIdx < history.Count) do
    begin
     ev := history.getAt(evIdx);
     if ev = nil then
       begin
        inc(evIdx);
        continue;
       end;
     foundLink.ev := ev;
     foundLink.evIdx := evIdx;
     eventFullyPainted := False;
     bodySkipCounter := 0;
  //  s := ev.getHeaderText;
     if ev.kind = EK_GCARD then
      {$IFDEF DB_ENABLED}
       linkTheWholeBody := ev.txt
      {$ELSE ~DB_ENABLED}
       linkTheWholeBody := ev.decrittedInfo
      {$ENDIF ~DB_ENABLED}
      else
       linkTheWholeBody := '';
  //  inc(y, drawHeader(cnv1, y));
     inc(y, drawHeader(y));
  // if there is enough space for the body
     if y < bottomLimit then
       begin
    // gets the text to be painted
    //    s:=ev.getBodyText;
    //    eventFullyPainted:= s='';
        if startWithLastLine and firstEvent then
          begin
           pleaseDontDrawUpwardArrows := TRUE;
           topOfs := maxInt;
           inc(y, drawBody(y));
           pleaseDontDrawUpwardArrows := FALSE;
           topOfs := skippedLines-1;
          end;
   //    if s = '' then
        if not ev.isHasBody then
          eventFullyPainted := y < bottomLimit
         else
          inc(y, drawBody(y));
        inc(y, lGapBtwMsg);
      end;
    inc(evIdx);
    if not JustCalc then
     if firstEvent then
       P_topEventNrows := Nrows-1;
    firstEvent := False;
  end; //while

// For DEBUG of paints
  if fDrawDebug then
   if length(Items) > 0 then
    begin
     cnv.Brush.Style := bsClear;
     cnv.Pen.Color := clRed;
     for I := 0 to length(Items)-1 do
       begin
         r := Items[i].r;
         Rectangle(Cnv.Handle, r.Left, r.Top, R.Right, r.Bottom);
       end;
    end;

 P_bottomEvent := evIdx-1;
 P_lastEventIsFullyVisible := eventFullyPainted and (evIdx=history.count);
 if not JustCalc then
   begin
    setLength(items, Nitems);
    updatePointedItem();
   end;
end; // paintOn

procedure ThistoryBox.Paint();
var
  MemDC: HDC;
  ABitmap, HOldBmp: HBITMAP;
  ARect: TRect;
  tmpCanvas: TCanvas;
  a, b: Integer;
begin
//  if autoScroll and (TopOfs=0) then
  if fAutoScrollState < ASS_FULLDISABLED  then
    go2end(True);
  case  dStyle of
   dsNone:
    paintOn(Canvas, Canvas.ClipRect, GetParentCurrentDpi);

   dsBuffer:
    begin
      with Canvas.ClipRect do
        begin
         a := Right  - Left;
         b := Bottom - Top;
        end;
//      buffer.Width:=  Canvas.ClipRect.Right - Canvas.ClipRect.Left;
//      buffer.Height:= Canvas.ClipRect.Bottom- Canvas.ClipRect.Top;
      if (a <> buffer.Width)or(b <> buffer.Height) then
       begin
        buffer.Height := 0;
        buffer.SetSize(a, b);
       end;
      buffer.Canvas.Lock;
      paintOn(buffer.Canvas, Canvas.ClipRect, GetParentCurrentDpi);
      buffer.Canvas.UnLock;

      Canvas.Draw(0, 0, buffer);
    end;

   dsGlobalBuffer:
    begin
      paintOn(globalBuffer.Canvas, Canvas.ClipRect, GetParentCurrentDpi);
      Canvas.Draw(0, 0, globalBuffer);
    end;

  dsGlobalBuffer2:
    begin
//      globalBuffer.Width :=  Canvas.ClipRect.Right - Canvas.ClipRect.Left;
//      globalBuffer.Height := Canvas.ClipRect.Bottom - Canvas.ClipRect.Top;
      if (globalBuffer.Width <> ClientWidth) or
         (globalBuffer.Height <> ClientHeight) then
        begin
          globalBuffer.Height := 0;
          globalBuffer.SetSize(ClientWidth, ClientHeight);
        end;
//      globalBuffer.ClipRect := Canvas.ClipRect;
      ARect := Canvas.ClipRect;
      globalBuffer.Canvas.Font.PixelsPerInch := GetParentCurrentDpi;
//      globalBuffer.Canvas.MoveTo(0, 0);
//      Canvas.MoveTo(0, 0);
      globalBuffer.Canvas.Lock;
      paintOn(globalBuffer.Canvas, ARect, GetParentCurrentDpi);
      BitBlt(Canvas.Handle, ARect.Left, ARect.Top,
              ARect.Right  - ARect.Left,
              ARect.Bottom - ARect.Top,
              globalBuffer.Canvas.Handle,
              ARect.Left, ARect.Top, SRCCOPY);
      globalBuffer.Canvas.UnLock;
//      Canvas.Draw(0,0, globalBuffer);
    end;

  dsMemory:
    begin
      ARect := Canvas.ClipRect;
      tmpCanvas := TCanvas.Create;   {paint on a memory DC}
      try
        MemDC := CreateCompatibleDC(Canvas.Handle);
        ABitmap := 0;
        HOldBmp := 0;
        try
          with ARect do
          begin
            ABitmap := CreateCompatibleBitmap(Canvas.Handle, Right-Left, Bottom-Top);
            if (ABitmap = 0) and (Right-Left + Bottom-Top <> 0) then
               raise EOutOfResources.Create('Out of Resources');

            try
              HOldBmp := SelectObject(MemDC, ABitmap);
              SetWindowOrgEx(memDC, Left, Top, Nil);
              tmpCanvas.Handle := MemDC;

              paintOn(tmpCanvas, Canvas.ClipRect, GetParentCurrentDpi);

              BitBlt(Canvas.Handle, Left, Top, Right-Left, Bottom-Top,
                MemDC, Left, Top, SrcCopy);
            finally
              tmpCanvas.Handle := 0;
            end;
          end;
        finally
          SelectObject(MemDC, HOldBmp);
          DeleteObject(ABitmap);
          DeleteDC(MemDC);
        end;
      finally
        FreeAndNil(tmpCanvas);
      end;
    end;
  end;

//  until (topVisible < offset) or not lastEventIsFullyVisible;
//  if (dStyle = dsGlobalBuffer)or(dStyle = dsGlobalBuffer2) then
//   else
//    bmp.free;
//  topOfs := oldTopOfs;
//  inc(topVisible);
//  if not precalc then
{  if not fautoScroll then
   if not2go2end then
    if lastEventIsFullyVisible then
      begin
//        topVisible := oldTopVis;
//        fAutoscroll := True;
//        Exit;
      end
     else
      begin
//        topVisible := oldTopVis;
        Autoscroll := False;
      end;
}
{  // Already executed go2end
 if fAutoScrollState = ASS_ENABLENOTSCROLL then
    if lastEventIsFullyVisible then
      begin
//        topVisible := oldTopVis;
//        fAutoscroll := True;
//        Exit;
      end
     else
      begin
//        topVisible := oldTopVis;
//        Autoscroll := True;
        Autoscroll := False;
//        fAutoScrollState := ASS_FULLSCROLL;
      end;
}

 updateRSB(false);
 updateLSB;

 if assigned(onPainted) //and (cnv=canvas)
  then
   onPainted(self);
end;


function ThistoryBox.getSelText(): string;
var
  SOS, EOS: ThistoryPos;
  i: integer;
  dim: integer;
  ev: Thevent;

  procedure addStr(s: String);
  begin
    while dim+length(s) > length(result) do
      setLength(result, length(result)+10000);
  {$IFDEF UNICODE}
    system.move(s[1], result[dim+1], ByteLength(s) );
  {$ELSE nonUNICODE}
    system.move(s[1], result[dim+1], length(s));
  {$ENDIF UNICODE}
    inc(dim, length(s));
  end; // addStr

begin
  result := '';
  dim := 0;

  if startSel.ev = NIL then
    exit;

  if minor(startSel, endSel) then
  begin
    SOS := startsel;
    EOS := endSel;
  end
  else
  begin
    SOS := endSel;
    EOS := startsel;
    if (lastClickedItem.kind = PK_SMILE) and
       (lastClickedItem.evIdx = EOS.evIdx)and
       (lastClickedItem.ofs = EOS.ofs)then
      inc(EOS.ofs, lastClickedItem.l);
  end;

  if (history.getAt(SOS.evIdx) = NIL)or (history.getAt(EOS.evIdx) = NIL) then
    Exit;

  if startSel.ofs < 0 then
  begin
    for i := SOS.evIdx to EOS.evIdx do
    begin
      ev := history.getAt(i);
      addStr(ev.getHeaderText+CRLF+ev.getBodyText);
      if dim > 0 then
//        if result[dim] = #10 then
          addStr(CRLF)
//        else
//          addStr(CRLF + CRLF);
    end;
    setLength(result, dim);
    exit;
  end;

  if SOS.evIdx = EOS.evIdx then
    addStr( copy(history.getAt(SOS.evIdx).getBodyText, SOS.ofs+1, EOS.ofs-SOS.ofs))
  else
  begin
    addStr( copy(history.getAt(SOS.evIdx).getBodyText, SOS.ofs+1, 99999)+CRLF);
    i := SOS.evIdx + 1;
    while i < EOS.evIdx do
    begin
      addStr(history.getAt(i).getBodyText+CRLF);
      inc(i);
    end;
    addstr(copy(history.getAt(EOS.evIdx).getBodyText, 1, EOS.ofs));
  end;

  setLength(result, dim);
end; // getSelText

function ThistoryBox.getSelBin(): AnsiString;
begin
  Result := '';
end;

function ThistoryBox.copySel2Clpb(): Boolean;
var
  s: String;
begin
  s := getSelText;
  Result := s > '';
  if Result then
    clipboard.asText := s;
end;

function applyHtmlFont(fnt: Tfont; const s: string): string;
var
  h, q: string;
begin
  h := '<font size=2 face="' + fnt.name+ '" color=#' + color2strU(fnt.color) +'>';
  q := '</font>';
  if fsItalic in fnt.style then
    begin
     h := h+'<i>';
     q := '</i>'+q;
    end;
  if fsBold in fnt.style then
    begin
     h := h+'<b>';
     q := '</b>'+q;
    end;
  result := h+s+q;
end; // applyHtmlFont


function ThistoryBox.getSelHtml(smiles: boolean): string;
var
  SOS, EOS: ThistoryPos;
  i, dim: integer;
  ev: Thevent;

  procedure addStr(const s: string);
  begin
  while dim+length(s) > length(result) do
    setLength(result, length(result)+10000);
  system.move(s[1], result[dim+1], length(s));
  inc(dim, length(s));
  end; // addStr

var
  fnt: TFont;
begin
  result := '';
  dim := 0;
  fnt := TFont.Create;
//  fnt.Assign(Self.canvas.Font);
  fnt.Assign(Screen.MenuFont);
  if startSel.ev = NIL then
    exit;
  if minor(startSel, endSel) then
  begin
    SOS := startsel;
    EOS := endSel;
  end
  else
  begin
    SOS := endSel;
    EOS := startsel;
  end;
  addStr('<html><head></head><body bgcolor=#'+color2strU(TextBGColor)+'>');
  for i := SOS.evIdx to EOS.evIdx do
  begin
    ev := history.getAt(i);
//    ev.applyFont(fnt);
    fnt.Assign(ev.getFont);
    addStr( CRLF+
      applyHtmlFont(fnt,
      '<u>['+getTranslation(event2ShowStr[ev.kind])+'] '+datetimeToStr(ev.when)+', '
      +ev.who.displayed+'</u>'+'<br>'+str2html(ev.getBodyText)+'<br><br>' )
      );
  end;
  addStr(CRLF+'</body></html>');

  setLength(result, dim);
  fnt.free;
end; // getSelHtml

function str2html2(s: string): string;
begin
result := template(s, [
  '&', '&amp;',
  '<', '&lt;',
  '>', '&gt;',
  CRLF, '<br/>',
  #13, '<br/>',
  #10, '<br/>'
]);
end; // str2html

function color2html(color: Tcolor): AnsiString;
begin
//  if not ColorToIdent(Color, Result) then
    begin
      color := ABCD_ADCB(ColorToRGB(color));
      result := '#'+IntToHexA(color,6);
    end;
end; // color2html


function ThistoryBox.getSelHtml2(smiles: boolean): RawByteString;

const
  HTMLTemplate = AnsiString('<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"'+ CRLF +
                 '"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">'+ CRLF + CRLF +
                 '<html>' + CRLF +
                 '<head>' + CRLF +
                 '  <title>%TITLE%</title>' + CRLF +
//                 '  <meta http-equiv="Content-Type" content="text/html; charset=windows-1251"/>' + CRLF +
                 '  <meta http-equiv="Content-Type" content="text/html; charset=UTF8"/>' + CRLF +

                 '  <style type="text/css">' + CRLF + CRLF +
//                 ' %HOSTS%' + CRLF + CRLF+
                 ' %BODY%' + CRLF + CRLF +
                 ' %HOST%' + CRLF + CRLF+
                 ' %GUEST%' + CRLF +
                 '  </style>' + CRLF +

                 '</head>' + CRLF +
                 '<body>' + CRLF +

                 ' %CONTENT% ' + CRLF +

                 '</body>' + CRLF +
                 '</html>');

var
  SOS, EOS: ThistoryPos;
  i, dim: integer;
  ev: Thevent;
//  Content: String;
  Content: RawByteString;
  HTMLElement: RawByteString;

  Host, Guest: String;
  HostUIN, GuestUIN: TUID;
  EvHost, EvGuest: Thevent;

//  procedure addStr(s:string);
//  begin
//    while dim+length(s) > length(Content) do
//      setLength(Content, length(Content)+10000);
//   system.move(s[1], Content[dim+1], length(s));
//   inc(dim, length(s));
//  end; // addStr
  procedure addStr(s: RawByteString);
  begin
    while dim+length(s) > length(Content) do
      setLength(Content, length(Content)+10000);
   system.move(s[1], Content[dim+1], length(s));
   inc(dim, length(s));
  end; // addStr

  function makeElement(uin: TUID; font: TFont): RawByteString;
  begin
    result := '   .uin'+ UTF8Encode(uin) + ' {' + CRLF+
              '     color: '+ color2html(font.color)+';'+CRLF;
    result := result + '     font-family: "'+ AnsiString(font.Name)+'";'+CRLF;
    result := result + '     font-size: '+IntToStrA(ABS(font.Height))+'px;'+CRLF;
    if fsBold in font.Style then
      result := result + '     font-weight: bold;';
    if fsItalic in font.Style then
      result := result + '     text-decoration: italic;';
    if fsUnderline in font.Style then
      result := result + '     text-decoration: underline;';
    result := result + '   }'
//             +CRLF;
  end;

var
  fnt: TFont;
begin
  result := '';
  dim := 0;
  EvHost := NIL;
  EvGuest := NIL;
  fnt := TFont.Create;
  fnt.Assign(Self.canvas.Font);

  if startSel.ev = NIL then
    exit;
  if minor(startSel, endSel) then
  begin
    SOS := startsel;
    EOS := endSel;
  end
  else
  begin
    SOS := endSel;
    EOS := startsel;
  end;

  Host := '';
  Guest := '';
  Content := '';
  for i := SOS.evIdx to EOS.evIdx do
  begin
    ev := history.getAt(i);

    if (Host = '') or (Guest = '') then
    begin
      if ev.isMyEvent then
      begin
        EvHost := history.getAt(i);
        Host := ev.who.displayed;
        HostUIN := ev.who.UID;
      end
      else
      begin
        EvGuest := history.getAt(i);
        Guest := ev.who.displayed;
        GuestUIN := ev.who.UID;
      end;
    end;

    addStr( AnsiString(CRLF+ '<div class="uin'+ev.who.UID2cmp+'">'+'<u>[')+
            StrToUTF8(getTranslation(event2ShowStr[ev.kind])+'] '+
                      datetimeToStr(ev.when)+', '+
                      ev.who.displayed+'</u>'+'<br/>'+
                      str2html2(ev.getBodyText)
                     )+'</div>'
         );
  end;
  setLength(Content, dim);
  //Content := StringReplace(Content, '&', '&amp;', [rfReplaceAll]);

  // %TITLE%
  HTMLElement := StrToUTF8(getTranslation( 'History [%s] with [%s]', [Host, Guest]));
  Result := StringReplace(HTMLTemplate, AnsiString('%TITLE%'), HTMLElement, []);

  // %BODY%
  HTMLElement := '    body {'+CRLF+
                 '      background-color: '+color2html(theme.GetColor(ClrHistBG, clWindow))+';'+CRLF+
                 '    }'+CRLF;
  Result := StringReplace(Result, AnsiString('%BODY%'), HTMLElement, []);

  // %HOST%
  if Host > '' then
    begin
     fnt.Assign(Screen.MenuFont);
     EvHost.applyFont(fnt);
     HTMLElement := makeElement(HostUIN, fnt);
    end
   else
    HTMLElement := '';
  Result := StringReplace(Result, AnsiString('%HOST%'), HTMLElement, []);

  // %GUEST%
  if Guest > '' then
    begin
     fnt.Assign(Screen.MenuFont);
     EvGuest.applyFont(fnt);
     HTMLElement := makeElement(GuestUIN, fnt)
    end
   else
    HTMLElement := '';
  Result := StringReplace(Result, AnsiString('%GUEST%'), HTMLElement, []);

  Result := StringReplace(Result, AnsiString('%CONTENT%'), Content, []);

//  EvHost:= nil;
//  EvGuest:= nil;

  Host := '';
  Guest := '';
  Content := '';
  HTMLElement := '';
  fnt.Free;
end; // getSelHtml2

procedure ThistoryBox.mouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);

  function doubleClick: boolean;
  begin
   result := just2clicked;
   if just2clicked and not justTriggeredAlink and lastClickedItem.equal(pointedItem) then
    begin
      if ((lastClickedItem.Kind = PK_RQPIC) or (lastClickedItem.Kind = PK_RQPICEX)) and not (lastClickedItem.ev.getBodyBin = '') then
        viewImageDimmed(self.Parent, clickedItem.ev.getBodyBin, clickedItem.ofs)
       else
        viewHeventWindow(history.getAt(endSel.evIdx));
    end;
  end; // doubleClick

begin
  dontTriggerLink := FALSE;
  just2clicked := now-lastTimeClick < dblClickTime;
  if shift=[ssRight] then
  begin
    updatePointedItem();
//    chatFrm.poppedup := point(x, y);
    HistoryData.del1.enabled := wholeEventsAreSelected;
    HistoryData.saveas1.enabled := somethingIsSelected;
    HistoryData.copy2clpb.visible := somethingIsSelected;
    HistoryData.toantispam.visible := somethingIsSelected;
    HistoryData.N2.visible := somethingIsSelected;
    HistoryData.savePicMnu.Visible := (pointedItem.kind=PK_RQPICEX)or (pointedItem.kind=PK_RQPIC);
    HistoryData.copylink2clpbd.visible := pointedItem.kind=PK_LINK;
    HistoryData.addlink2fav.visible := (pointedItem.kind=PK_LINK)
      and (pointedItem.link.kind in [LK_WWW, LK_FTP]);
    HistoryData.add2rstr.visible := (pointedItem.kind=PK_LINK)
      and (pointedItem.link.kind=LK_UIN);
    if HistoryData.add2rstr.visible then
      try
        HistoryData.selectedUIN := pointedItem.link.str;
        addGroupsToMenu(self, HistoryData.add2rstr, HistoryData.addcontactAction,
          who.fProto.canAddCntOutOfGroup or not who.fProto.isOnline);
      except
        HistoryData.add2rstr.visible := FALSE;
      end;
    HistoryData.ViewinfoM.Visible := Assigned(pointedItem.ev) and Assigned(pointedItem.ev.who);
    HistoryData.viewmessageinwindow1.enabled := historyNowCount>0;
    HistoryData.selectall1.enabled := historyNowCount>0;
    lastClickedItem := pointedItem;
    with clientToScreen(point(x,y)) do
      HistoryData.histMenu.popup(x,y);
//    startSel.ofs := -1; endSel.ofs := -1;
    exit;
  end;
  if ssShift in shift then
  begin
    if pointedSpace.kind<>PK_NONE then
      begin
      endSel := historyitem2pos(pointedSpace);
      repaint();
      end;
    inherited;
    exit;
  end;
  deselect();
  case pointedSpace.kind of
    PK_NONE: selecting := TRUE;
    PK_CRYPTED:
      if enterPwdDlg(histcrypt.pwd) then
        histcrypt.pwdkey := calculate_KEY(histcrypt.pwd);
    PK_HEAD, PK_TEXT, PK_LINK, PK_SMILE:
      if ((pointedSpace.kind<>PK_HEAD) or (pointedItem.kind = PK_HEAD))
        and not DoubleClick then

      begin
        selecting := TRUE;
        startsel := historyitem2pos(pointedSpace);
        endSel := startsel;
      end;
    PK_ARROWS_UP:
      begin
        histScrollLine(-1);
        exit; // prevent redundant repaint
      end;
    PK_ARROWS_DN:
      begin
        histScrollLine(+1);
        exit; // prevent redundant repaint
      end;
  else
    exit;
  end;
  lastTimeClick := now;
  repaint;
  if pointedItem.kind = PK_NONE then
    lastClickedItem := pointedSpace
   else
    lastClickedItem := pointedItem;
  updatePointedItem();
  inherited;
end; // mouseDown

procedure ThistoryBox.click();
begin
  if not dontTriggerLink
    and (pointedItem.kind = lastClickedItem.kind)
    and (pointedItem.link.id = lastClickedItem.link.id) then
   begin
    selecting := FALSE;
    triggerLink(pointedItem);
   end;
end;

procedure ThistoryBox.mouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  s: string;
begin
//  if selecting then
//  begin
  selecting := FALSE;
  if somethingIsSelected then
  begin
    if autocopyHist then
    begin
      s := getSelText;
      if s > '' then
        clipboard.asText := s
    end
  end;
  if autoDeselect then
  begin
    deselect();
    repaint;
  end;
  inherited;
end; // mouseUp

function ThistoryBox.spaceAt(pt: Tpoint): ThistoryItem;
var
  i, j, m, l: integer;
  r: Trect;
begin
  result.kind := PK_NONE;
  i := 0;
  l := length(items)-1;
  if l<0 then
    exit;
  j := l;
  m := -1;
  // search for an item on the same row
  while i<=j do
  begin
    m := (i+j) div 2;
    r := items[m].r;
    if within(r.Top, pt.Y, r.bottom) then
      break;
    if (pt.y < r.top) or (pt.y < r.bottom) and (pt.x < r.left) then
      j := m-1
     else
      i := m+1;
  end;
// if no item is matching the Y, move backward until the item is behind PT
  while m > 0 do
  begin
    if pt.y < items[m-1].r.top then
      dec(m)
     else
      break
  end;
// without leaving this row, move backward searching for a better matching item
  while m>0 do
  begin
    r := items[m-1].r;
    if within(r.Top, pt.Y, r.bottom) and (pt.X <= r.right) then
      dec(m)
     else
      break
  end;
  // same, but move forward
  while m<l do
  begin
    r := items[m+1].r;
    if within(r.Top, pt.Y, r.bottom) and (pt.X >= r.left) then
      inc(m)
     else
      break
  end;
  // do we have a valid item?
  if m>=0 then
  begin
    result := items[m];
    // if pt is on the first half of the item then move behind 
    if pt.X < centerPoint(result.r).x then
     dec(result.ofs);
  end;
end; // spaceAt

function ThistoryBox.itemAt(pt: Tpoint): ThistoryItem;
var
  i, j, m: integer;
  r: Trect;
begin
  result.kind := PK_NONE;
  i := 0;
  j := length(items)-1;
  while i<=j do
    begin
    m := (i+j) div 2;
    r := items[m].r;
    if ptInRect( r, pt ) then
      begin
      result := items[m];
      break;
      end;
    if (pt.y < r.top) or ((pt.y < r.bottom) and (pt.x < r.left)) then
      j := m-1
     else
      i := m+1;
    end;
end; // itemAt

procedure ThistoryBox.mouseMove(Shift: TShiftState; X, Y: Integer);
begin
  updatePointedItem()
end; // mouseMove

procedure ThistoryBox.go2end(const calcOnly: Boolean = False; const precalc: Boolean = False);
var
  bmp: Tbitmap;
//  secs: Cardinal;
//  s: String;
  oldTopOfs: Integer;
  oldTopVis: Integer;
  safeLastEventIsFullyVisible: Boolean;
begin
//  bmp := createBitmap(canvas.ClipRect.Right ClientWidth, ClientHeight);
//  bmp := createBitmap(canvas.ClipRect.Right, canvas.ClipRect.Bottom);
  if not Assigned(history) or (history.count <= offset) then
    Exit;
  if (dStyle = dsGlobalBuffer)or(dStyle = dsGlobalBuffer2) then
    begin
     bmp := globalBuffer;
     if dStyle = dsGlobalBuffer2 then
       bmp.SetSize(ClientWidth, ClientHeight);
    end
   else
    bmp := createBitmap(canvas.ClipRect.Right, canvas.ClipRect.Bottom);

  oldTopVis := topVisible;
  topVisible := history.count - 1;
  oldTopOfs := topOfs;
  topOfs := 0;
  safeLastEventIsFullyVisible := lastEventIsFullyVisible;
//  s := '';
//  secs :=  GetTickCount;
  repeat
    dec(topVisible);
    paintOn(bmp.canvas, bmp.Canvas.ClipRect, GetParentCurrentDpi, True);
//    s := s + CRLF + '--' + intToStr(topVisible) + '---' + intToStr(GetTickCount - secs);
//    secs :=  GetTickCount;
  until (topVisible < offset) or not lastEventIsFullyVisible;
  if (dStyle = dsGlobalBuffer)or(dStyle = dsGlobalBuffer2) then
   else
    bmp.free;
  P_lastEventIsFullyVisible := safeLastEventIsFullyVisible;
  topOfs := oldTopOfs;
  inc(topVisible);
  if not precalc then
//   if not2go2end then
   if fAutoScrollState > ASS_FULLSCROLL then
    begin
      topVisible := oldTopVis;
//      Autoscroll := oldTopVis >= topVisible;
    end;
//  secs :=  GetTickCount;
  if not calcOnly and not precalc then
    repaint();
//  s := s + CRLF + '-Paint-' + intToStr(topVisible) + '---' + intToStr(GetTickCount - secs) + CRLF+'==================';
//  appendFile(myPath+'Paint.txt', s);
end; // go2end

procedure ThistoryBox.move2start();
begin
  histScrollEvent(-rsb_position);
end;

procedure ThistoryBox.move2end(animate: Boolean = False);
begin
//  chatFrm.autoscrollBtn.down := v;
//  autoscroll := True;
  autoScrollVal := True;
  setAutoScrollForce(True);
end;


function ThistoryBox.moveToTime(time: TDateTime; NeedOpen: Boolean): Boolean;
var
  h: Thistory;
  i: integer;

  function search(ofs: Integer): Integer;
  begin
    result := h.Count-1;
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
        result := -1;
  end; // search
begin
  Result := False;
  h := history;
  i := search(offset);
  if NeedOpen and (i < 0) and not whole then
    begin
//      if ch = thisChat then
//       historyBtn.down := TRUE;
//      historyAllShowChange(ch, True);

      setScrollPrefs(True);
//    historyBtnClick(self);
      i := search(offset);
      if i < 0 then
       begin
//        if ch = thisChat then
//         historyBtn.down := FALSE;
//        historyAllShowChange(ch, False);
         setScrollPrefs(False);
       end;
    end;
  if i >= 0 then
    begin
     Result := True;
      updateRSB(True, i, True);
      topVisible := offset + rsb_position;
      topOfs := 0;
    end;
  repaint;
  DoOnScroll;
end;

function ThistoryBox.search(text: String; dir: THistSearchDirection; caseSens: Boolean; useRE: Boolean): Boolean;
var
  start: integer;
  i: integer;
  s: string;
 {$IFNDEF DB_ENABLED}
//  re:Tregexpr;
  re: TRegEx;
  l_RE_opt: TRegExOptions;
 {$ENDIF ~DB_ENABLED}
  found: boolean;
begin
  if not useRE and not caseSens then
    text := uppercase(text);
  if text = '' then
    begin
      exit(false);
    end;
  if useRE then
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
        if not caseSens then
          Include(l_RE_opt, roIgnoreCase)
         else
          Exclude(l_RE_opt, roIgnoreCase)
        ;
        re := TRegEx.Create(text, l_RE_opt);
   {$ENDIF ~DB_ENABLED}
    end;
  case dir of
    hsdFromBegin: start := historyNowOffset;
    hsdAhead:     start := topVisible+1;
    hsdBack:      start := topVisible-1;
    hsdFromEnd:   start := history.count-1;
   else
    start := historyNowOffset;
  end;
  i := start;
  while (i >= historyNowOffset) and (i < history.Count) do
//    while (i >= historyBox.topVisible) and (i < historyBox.history.count) do
    begin
      s := Thevent(history[i]).getBodyText;
   {$IFNDEF DB_ENABLED}
      if useRE then
  //     	found := re.exec(s)
        found := re.IsMatch(s)
      else
   {$ENDIF ~DB_ENABLED}
        begin
        if not caseSens then
          found := AnsiContainsText(s, text)
         else
  //        s := uppercase(s);
          found := pos(text, s) > 0;
  //      found := AnsiPos(w2s, s) > 0;
        end;
      if found then
        begin
  //      historyBox.rsb_position := i-historyBox.offset;
  //      historyBox.topVisible := i;
  //      historyBox.topOfs := 0;
         self.w2s := w2s;
         updateRSB(true, i - offset, True);
         topVisible := offset + rsb_position;
         topOfs := 0;
//         chatFrm.autoscrollBtn.down := autoScrollVal;
         repaint;
         DoOnScroll;
  //      historyBox.repaint;
         exit(True);
        end;
      case dir of
        hsdFromBegin,
        hsdAhead: inc(i);
        hsdBack,
        hsdFromEnd: dec(i);
      end;
    end;
  result := False;
end;

function ThistoryBox.offsetPos(): integer;
begin
  result := topVisible-offset
end;

function ThistoryBox.wholeEventsAreSelected(): boolean;
begin
  result := (startSel.ev<>NIL) and (startSel.ofs<0)
end;

function ThistoryBox.nothingIsSelected(): boolean;
begin
  result := startSel.ev=NIL
end;

function ThistoryBox.somethingIsSelected(): boolean;
begin
  result := startSel.ev<>NIL
end;

function ThistoryBox.partialTextIsSelected(): boolean;
begin
  result := (startSel.ev<>NIL) and (startSel.ofs>=0)
end;

procedure ThistoryBox.select(from, to_: integer);
begin
  startSel.ofs := -1;
  startSel.evIdx := from;
  startSel.ev := history.getAt(from);
  endSel.ofs := -1;
  endSel.evIdx := history.count - 1;
  endSel.ev := history.getAt(to_);
end; // select

procedure ThistoryBox.selectAll;
begin
  if historyNowCount > 0 then
   begin
    select(historyNowOffset, history.count-1);
    repaint;
    DoOnScroll;
   end;
end;

procedure ThistoryBox.deselect();
begin
  startSel.ev := NIL;
  startSel.evIdx := -1;
end; // deselect

procedure ThistoryBox.DeleteSelected;
var
  st, en: Integer;
begin
  if not history.loaded then
  begin
    MsgDlg('Load the whole history before removing messages', True, mtInformation);
    Exit;
  end;

   begin
    if not wholeEventsAreSelected then
      exit;
    st := startSel.evIdx;
    en := endSel.evIdx;
    if st > en then
      swap4(st, en);
//  chatFrm.visible := False;
    Visible := false;
    history.deleteFromTo(who.uid, st, en);
    Visible := True;
//  chatFrm.visible:=TRUE;
    deselect();
    repaint;
    DoOnScroll;
   end;
end;

procedure ThistoryBox.updatePointedItem();
var
  p, pEnd: ThistoryPos;
  oldIt, oldSp: ThistoryItem;
  oldLink: ThistoryLink;
  pt: Tpoint;
begin
  pt := screenToClient(mousePos);
  oldIt := P_pointedItem;
  oldSp := P_pointedSpace;
  oldLink := linkToUnderline;
  P_pointedItem := itemAt(pt);
  P_pointedSpace := spaceAt(pt);
// no interesting movement
  if oldIt.equal(P_pointedItem) and oldSp.equal(P_pointedSpace) then
    exit;
// link underlining, mouse cursor shape
  if isLink(pointedItem) and (pointedItem.link.kind in linksToUnderline) then
    begin
     linkToUnderline := pointedItem.link;
     cursor := crHandPoint
    end
   else
    begin
     linkToUnderline.evIdx := -1;
     cursor := crDefault;
    end;
// if pointedItem.kind = PK_RNQBUTTON then
//   P_pointedItem.link

// repaint necessary?
  if not equal(linkToUnderline, oldLink) then
   begin
  //  avoidErase := TRUE;
     paint();
  //  avoidErase := FALSE;
   end;
// here the selecting management section begins
  if not selecting then
    exit;
// selecting, no link has to be triggered
  dontTriggerLink := TRUE;
// updating the selection end point
  if pointedSpace.kind=PK_NONE then
    exit;
  p := historyitem2pos(pointedSpace);
  if minor(startSel, p) then
    inc(p.ofs, pointedSpace.l-1);
  if equal(endSel, p) then
    exit; // no change?
  endSel := p;
  pEnd := p;
  pEnd.ofs := p.ofs + pointedSpace.l-1;
  if (pointedSpace.kind = PK_SMILE) and
     minor(endSel, startSel) and
     (minor(p, startSel) and minor(startSel, pEnd)) then
    inc(startSel.ofs, pointedSpace.l-1);
  
  // some adjustment could be needed
  if nothingIsSelected() then
    startSel := historyitem2pos(pointedItem)
   else
    if startSel.ofs < 0 then
      endSel.ofs := -1
    else
      if endSel.ofs < 0 then
        endSel.ofs := 0;
//  repaint();
  invalidate();
end; // updatePointedItem

function ThistoryBox.triggerLink(item: ThistoryItem): boolean;
var
  s: string;
begin
  result := FALSE;
  if item.kind<>PK_LINK then
    exit;
  s := item.link.str;
  case item.link.kind of
    LK_WWW:
      begin
        if not (Imatches(s,1,'http://') or Imatches(s,1,'https://')) then
          s := 'http://'+s;
//        if Assigned(onLinkClick) then
//          onLinkClick(self, s, item.link.str);
        openURL(s);
      end;
    LK_FTP:
      begin
        if not (Imatches(s,1,'ftp://')or Imatches(s,1,'sftp://')) then
          s := 'ftp://'+s;
        openURL(s);
      end;
    LK_EMAIL:
      begin
        if not Imatches(s,1,'mailto:') then
          s:='mailto:'+s;
        exec(s);
      end;
  end;
end; // triggerLink

procedure ThistoryBox.ManualRepaint;
begin
  inc(history.fToken);
  repaint;
end;

procedure ThistoryBox.WMEraseBkgnd(var Msg: TWmEraseBkgnd);
//var
// cnv : TCanvas;
// ps: tagPAINTSTRUCT;
begin
// if self.history.Count > 0 then
//  Msg.Result:= 1
// else
 begin
//   msg.
{   cnv := TCanvas.Create;

    SaveIndex := SaveDC(hDC);
    FCanvas.Lock;
    try
      FCanvas.Handle := hDC;
      Draw(FCanvas);
    finally
      FCanvas.Handle := 0;
      FCanvas.Unlock;
      RestoreDC(hDC, SaveIndex);

   cnv.Handle := Msg.DC;
//   DoBackground(Msg.DC);
//  BeginPaint(Msg.DC, ps);
//   DoBackground(Msg.DC);
//  EndPaint(Msg.DC, ps);
   if (cnv.ClipRect.Left = 0) and (cnv.ClipRect.Top = 0) and
      (cnv.ClipRect.Right > 0) and (cnv.ClipRect.Bottom > 0) then
    begin
//     DoBackground(Cnv, cnv.ClipRect);
    end;
//   DoBackground(Canvas);
   cnv.Free;          }
   msg.Result := 1;
   msg.Msg := 0;
 end;
end;

procedure ThistoryBox.DoBackground(cnv0: Tcanvas; vR: TRect; var SmlBG: TBitmap; const PPI: Integer);
//procedure ThistoryBox.DoBackground(dc: HDC);
var
  {$IFDEF USE_GDIPLUS}
  fnt : TGPFont;
  fmt : TGPStringFormat;
  br  : TGPBrush;
  gr  : TGPGraphics;
  r: TGPRectF;
  {$ELSE NOT USE_GDIPLUS}
//  fnt : TFont;
  R: TRect;
  hnd : THandle;
//   br : hbrush;
  {$ENDIF USE_GDIPLUS}
  hasBG0, hasUTP : Boolean;
  uidBG, grpBG : TPicName;
  picElm : TRnQThemedElementDtls;
  pt : TPoint;
  isUseCntThemes : Boolean;
begin
  isUseCntThemes := UseContactThemes and Assigned(ContactsTheme) and Assigned(who);

  if isUseCntThemes then
    begin
      uidBG := TPicName(LowerCase(who.uid2cmp)) + '.'+PIC_CHAT_BG;
      grpBG := TPicName('group.') + TPicName(AnsiLowerCase(groups.id2name(who.group))) + '.'+PIC_CHAT_BG
    end
   else
    begin
      uidBG := '';
      grpBG := '';
    end;
  {$IFDEF USE_GDIPLUS}
  gr := TGPGraphics.Create(cnv.Handle);
  gr.GetClipBounds(r);
  if r.X < vr.Left then
    r.X := vR.Left;
  if r.Y < vr.Top then
    r.Y := vR.Top;
  if r.Width > vr.Right - vr.Left then
   r.Width := vr.Right - vr.Left;
  if r.Height > vr.Bottom - vr.Top then
   r.Height := vr.Bottom - vr.Top;
  gr.Clear(theme.GetAColor(ClrHistBG, clWindow));
{$ELSE NOT USE_GDIPLUS}
  r := cnv0.ClipRect;

  if not Assigned(SmlBG) then
    begin
     SmlBG := createBitmap(clientWidth, ClientHeight);
    end
   else
    begin
      SmlBG.Height := 0;
      SmlBG.SetSize(clientWidth, ClientHeight);
    end;
//     br := CreateSolidBrush(ColorToRGB(theme.GetColor(ClrHistBG, clWindow)));
  SmlBG.Canvas.Brush.Color := theme.GetColor(ClrHistBG, clWindow);
  SmlBG.Canvas.FillRect(SmlBG.Canvas.ClipRect);
//   Br := TGPSolidBrush.Create(theme.GetAColor(ClrHistBG, clWindow));
//   gr.FillRectangle(br, r);
//   br.Free;
  {$ENDIF USE_GDIPLUS}
{   r.X := ClientRect.Left;
   r.Y := ClientRect.Top;
   r.Width := ClientWidth;
   r.Height := ClientHeight;}
(*  if theme.GetPicSize( PIC_CHAT_BG+'6').cx > 0 then
  begin
    theme.drawStratch(gr, r, PIC_CHAT_BG+'6');
    {$IFDEF RNQ_FULL}
     if theme.useAnimated and not Assigned(SmlBG) then
      begin
//       theme.AnibgPic := TGPBitmap.Create(cnv.ClipRect.Right, cnv.ClipRect.Bottom, PixelFormat24bppRGB);
       theme.AnibgPic := createBitmap(cnv.ClipRect.Right, cnv.ClipRect.Bottom);
//       theme.Anipicbg := True;
      end;
    {$ENDIF RNQ_FULL}
   end
  else*)
  if isUseCntThemes and
      (ContactsTheme.GetPicSize(RQteDefault, uidBG+'5', 0, PPI).cx > 0) then
     begin
      hasBG0 := True;
      ContactsTheme.drawTiled(SmlBG.Canvas, uidBG+'5');
     end
   else
  if isUseCntThemes and
      (ContactsTheme.GetPicSize(RQteDefault, grpBG+'5', 0, PPI).cx > 0) then
     begin
      hasBG0 := True;
      ContactsTheme.drawTiled(SmlBG.Canvas, grpBG+'5');
     end
   else
  if theme.GetPicSize(RQteDefault, PIC_CHAT_BG+'5', 0, PPI).cx > 0 then
  begin
//    theme.drawTiled(gr, r, PIC_CHAT_BG+'5');
    theme.drawTiled(SmlBG.Canvas, PIC_CHAT_BG+'5');
    hasBG0 := True;
//     theme.Anipicbg := True;
   end
  else
    begin
      hasBG0 := False;
    end;

  hnd := SmlBG.Canvas.Handle;

  picElm.Element := RQteDefault;
  picElm.pEnabled := True;


{  if birth then
  with theme.GetPicSize('birthday') do
   if cx > 0 then
      theme.drawPic(cnv, 0, 0, 'birthday');}

  pt.X := 0; pt.Y := 0;
  picElm.ThemeToken := -1;
  picElm.picName := uidBG+'1';
  if isUseCntThemes and
      (ContactsTheme.GetPicSize(picElm, 0, PPI).cx > 0) then
     ContactsTheme.drawPic(hnd, pt, picElm, PPI)
   else
    begin
      picElm.ThemeToken := -1;
      picElm.picName := grpBG+'1';
      if isUseCntThemes and
          (ContactsTheme.GetPicSize(picElm, 0, PPI).cx > 0) then
         ContactsTheme.drawPic(hnd, pt, picElm, PPI)
       else
//      with theme.GetPicSize(RQteDefault, PIC_CHAT_BG+'1') do
//       if cx > 0 then
          theme.drawPic(hnd, 0, 0, PIC_CHAT_BG+'1');
    end;


// Right-Top
  pt.Y := 0; pt.X := clientWidth;

  hasUTP := False;
  picElm.ThemeToken := -1;
  picElm.picName := uidBG+'2';
  if isUseCntThemes then
   begin
    with ContactsTheme.GetPicSize(picElm, 0, PPI) do
      if cx > 0 then
       begin
        hasUTP := True;
        Dec(pt.x, cx);
        ContactsTheme.drawPic(hnd, pt, picElm, PPI)
       end;
    if not hasUTP then
    begin
     picElm.ThemeToken := -1;
     picElm.picName := grpBG+'2';
      with ContactsTheme.GetPicSize(picElm, 0, PPI) do
        if cx > 0 then
         begin
          hasUTP := True;
          Dec(pt.x, cx);
          ContactsTheme.drawPic(hnd, pt, picElm, PPI)
         end;
    end;
   end;
  if not hasUTP then
  begin
   picElm.ThemeToken := -1;
   picElm.picName := PIC_CHAT_BG+'2';
   with theme.GetPicSize(picElm, 0, PPI) do
    if cx > 0 then
     begin
      Dec(pt.x, cx);
      theme.drawPic(hnd, pt, picElm, PPI);
     end;
  end;

// Draw BirthDay Balloon
{
  pt.Y := 2; pt.X := clientWidth;
  picElm.ThemeToken := -1;
//   picElm.picName := PIC_CHAT_BG+'2';
           case who.Days2Bd of
             0: picElm.picName := PIC_BIRTH;
             1: picElm.picName := PIC_BIRTH1;
             2: picElm.picName := PIC_BIRTH2;
             else picElm.picName := '';
           end;
           if picElm.picName > '' then
             begin
//              if pIsRight then
                with theme.GetPicSize(picElm) do
//                  newX := x - cx
//               else
//                 newX := x;
                  dec(pt.X, cx+2);
               theme.drawPic(hnd, pt, picElm);
             end;
}
// Left-Bottom
  pt.Y := Height; pt.X := 0;

  hasUTP := False;
   picElm.ThemeToken := -1;
  if isUseCntThemes then
   begin
    picElm.picName := uidBG+'3';
    with ContactsTheme.GetPicSize(picElm, 0, PPI) do
      if cx > 0 then
       begin
        hasUTP := True;
          Dec(pt.Y, cy);
        ContactsTheme.drawPic(hnd, pt, picElm, PPI)
       end;
    if not hasUTP then
    begin
     picElm.ThemeToken := -1;
     picElm.picName := grpBG+'3';
      with ContactsTheme.GetPicSize(picElm, 0, PPI) do
        if cx > 0 then
         begin
          hasUTP := True;
            Dec(pt.Y, cy);
          ContactsTheme.drawPic(hnd, pt, picElm, PPI)
         end;
    end;
   end;
  if not hasUTP then
  begin
   picElm.ThemeToken := -1;
   picElm.picName := PIC_CHAT_BG+'3';
   with theme.GetPicSize(picElm, 0, PPI) do
    if cx > 0 then
     begin
          Dec(pt.Y, cy);
      theme.drawPic(hnd, pt, picElm, PPI);
     end;
  end;

// Right-Bottom
  pt.Y := Height; pt.X := clientWidth;

  hasUTP := False;
  picElm.ThemeToken := -1;
  if isUseCntThemes then
   begin
    picElm.picName := uidBG+'4';
    with ContactsTheme.GetPicSize(picElm, 0, PPI) do
      if cx > 0 then
       begin
        hasUTP := True;
        Dec(pt.X, cx);
        Dec(pt.Y, cy);
        ContactsTheme.drawPic(hnd, pt, picElm, PPI)
       end;
    if not hasUTP then
    begin
     picElm.ThemeToken := -1;
     picElm.picName := grpBG+'4';
      with ContactsTheme.GetPicSize(picElm, 0, PPI) do
        if cx > 0 then
         begin
          hasUTP := True;
          Dec(pt.X, cx);
          Dec(pt.Y, cy);
          ContactsTheme.drawPic(hnd, pt, picElm, PPI)
         end;
    end;
   end;
  if not hasUTP then
  begin
   picElm.ThemeToken := -1;
   picElm.picName := PIC_CHAT_BG+'4';
   with theme.GetPicSize(picElm, 0, PPI) do
    if cx > 0 then
     begin
        Dec(pt.X, cx);
        Dec(pt.Y, cy);
      theme.drawPic(hnd, pt, picElm, PPI);
     end;
  end;

(*

  {$IFDEF USE_GDIPLUS}
        Fnt := TGPFont.Create('Arial', 200, FontStyleBold or FontStyleItalic);
        Br := TGPSolidBrush.Create($016666FF);
        fmt := TGPStringFormat.Create(StringFormatFlagsNoClip);//([SFNoWrap, SFNoClip]);
        fmt.SetAlignment(StringAlignmentCenter);
{        if TestVersion then
          fnt.LineAlignment := SFAlignmentNear
         else
          fnt.LineAlignment := SFAlignmentCenter;}
//        Brush := NewGPSolidBrush(tomato);
        gr.DrawString(wideString('R&Q'), 3, fnt,
          r, fmt, br);
        br.Free;
//        font.Free;
//        Brush.Free;
{        if TestVersion then
         begin
          Brush := NewGPSolidBrush($030000FF);
          fnt.LineAlignment := SFAlignmentFar;
//        Brush := NewGPSolidBrush(tomato);
          DrawString ('Testing', ClientRect, fnt);
         end;}
        fnt.Free;
        fmt.Free;
//    end;

  gr.Free;
  {$ELSE NOT USE_GDIPLUS}
  fnt := TFont.Create;
  fnt.Name := 'Arial';
  fnt.Height := 300;
  fnt.Style := [fsBold, fsItalic];
//  fnt.Color := $6666FF;
  fnt.Color := $FF6666;

 {$IFDEF DB_ENABLED}
  DrawTextTransparent(hnd, 80, 10, 'R&Q2',fnt, 1, DT_NOPREFIX or DT_EXTERNALLEADING);//DT_SINGLELINE or DT_CENTER);
 {$ELSE ~DB_ENABLED}
//  DrawTextTransparent(hnd, 80, 10, 'R&Q',fnt, 1, DT_NOPREFIX or DT_EXTERNALLEADING);//DT_SINGLELINE or DT_CENTER);
  DrawTextTransparent(hnd, 80, 10, 'R&Q',fnt, 201, DT_NOPREFIX or DT_EXTERNALLEADING);//DT_SINGLELINE or DT_CENTER);
 {$ENDIF ~DB_ENABLED}
//      DrawText32(hnd, r, 'R&Q', Font, DT_CENTER or DT_VCENTER);
  fnt.Free;
  {$ENDIF USE_GDIPLUS}

//  cnv.Font := theme.GetFont('history.his');
//  DrawTextTransparent(cnv.Handle, clientWidth - 120, 10, 'бла-бла-бла',cnv.Font, 10);

  cnv0.Brush.Color := clRed;
  cnv0.FillRect(vR);
*)
//  BitBlt(cnv0.Handle, vR.Left, vR.Top, vR.Right - vR.Left, vR.Top - vR.Bottom,
//          hnd, vR.Left, vR.Top, SRCCOPY);
//          SmlBG.Canvas.Handle, vR.Left, vR.Top, SRCCOPY);
  BitBlt(cnv0.Handle, 0, 0, SmlBG.Width, SmlBG.Height,
//          hnd, vR.Left, vR.Top, SRCCOPY);
          hnd, 0, 0, SRCCOPY);

  if not hasBG0 then
    begin
      if Assigned(SmlBG) then
        SmlBG.Free;
      SmlBG := NIL;
    end;
//     if rqSmiles.useAnimated then

end;

{
procedure ThistoryBox.wmPaint(var msg : TWMPaint);
var
  ps : TPaintStruct;
  hdc : THandle;
begin
//  hdc := BeginPaint(self.Handle, ps);
  if msg.DC = 0 then
   Exit;
  hdc := msg.DC;
//  GetClientRect
//  GetClientRect(self.Handle, &rc);
  SetMapMode(hdc, MM_ANISOTROPIC);
  SetWindowExtEx(hdc, 100, 100, NIL);
//  SetViewportExtEx(hdc, rc.right, rc.bottom, NULL);
  SetViewportExtEx(hdc, ps.rcPaint.Left, ps.rcPaint.bottom, NIL);
//  Polyline(hdc, ppt, cpt);
  Rectangle(hdc, 20, 20, 80, 80);
//  EndPaint(self.Handle, ps);
  msg.Result := 1;
//  msg.Msg := 0;
end;}

procedure ThistoryBox.CreateParams(var Params: TCreateParams);
//const
//  ScrollBar: array[TScrollStyle] of Cardinal = (0, WS_HSCROLL, WS_VSCROLL, WS_HSCROLL or WS_VSCROLL);
begin
  inherited CreateParams(Params);

  with Params do
  begin
    Style := Style or WS_VSCROLL;
  end;
end;

procedure ThistoryBox.updateRSB(setPos: Boolean; pos: Integer = 0; doRedraw: Boolean = true);
var
  SI0, ScrollInfo: TScrollInfo;
//  vSBI: TScrollBarInfo;
begin
  if historyNowCount<2 then
    begin
//      ScrollInfo.cbSize := SizeOf(ScrollInfo);
//      ScrollInfo.fMask := SIF_DISABLENOSCROLL; //SIF_ALL;
//      SetScrollInfo(Handle, SB_VERT, ScrollInfo, doRedraw);
      ShowScrollBar(Handle, SB_VERT, False);
      rsb_visible := false;
    end
  else
    begin

      SI0.cbSize := SizeOf(SI0);
      SI0.fMask := SIF_ALL;
      GetScrollInfo(Handle, SB_VERT, SI0);

      ScrollInfo := SI0;

      if not rsb_visible then
       begin
         ShowScrollBar(Handle, SB_VERT, True);
//         GetScrollBarInfo(Handle, SB_VERT, vSBI);
//         sgf
         rsb_visible := True;
       end;

      ScrollInfo.nMin := 0;
      ScrollInfo.nMax := historyNowCount-1;
      if SetPos then
        begin
//         not2go2end := True;
         if fAutoScrollState = ASS_FULLSCROLL then
           fAutoScrollState := ASS_ENABLENOTSCROLL;
         rsb_position  := pos
        end
       else
        rsb_position  := topVisible-historyNowOffset;
      if rsb_position > ScrollInfo.nMax then
        rsb_position := ScrollInfo.nMax
       else
        if rsb_position < ScrollInfo.nMin then
          rsb_position := ScrollInfo.nMin;

      ScrollInfo.nPos := rsb_position;
      ScrollInfo.nPage := 0;

//      ScrollInfo.nPage := Max(0, ClientHeight + 1);
      ScrollInfo.fMask := SIF_RANGE or SIF_POS or SIF_PAGE; //SIF_ALL;
      if (SI0.nMin <> ScrollInfo.nMin)or
         (SI0.nMax <> ScrollInfo.nMax)or
         (SI0.nPage <> ScrollInfo.nPage)or
         (SI0.nPos <> ScrollInfo.nPos)or
         (SI0.nTrackPos <> ScrollInfo.nTrackPos) then
        SetScrollInfo(Handle, SB_VERT, ScrollInfo, doRedraw);
    end;
end; // updateRSB

procedure ThistoryBox.updateGraphics;
begin
  {$IFDEF CHAT_USE_LSB}
  if historyData.popupLSB then
    if lsb.Enabled and (lsb.Position > lsb.Min) then
      lsb.width := MulDiv(maximizedScroll, GetParentCurrentDpi, cDefaultDPI)
     else
      lsb.width := MulDiv(minimizedScroll, GetParentCurrentDpi, cDefaultDPI)
   else
    lsb.width := MulDiv(maximizedScroll, GetParentCurrentDpi, cDefaultDPI);
  {$ENDIF CHAT_USE_LSB}
end;

procedure ThistoryBox.addEvent(ev: Thevent);
var
  i: Integer;
begin
  history.add(ev);
//  if autoScroll and (not not2go2end or P_lastEventIsFullyVisible) then
  if (fAutoScrollState = ASS_FULLSCROLL)or
     ((fAutoScrollState = ASS_ENABLENOTSCROLL)and P_lastEventIsFullyVisible) then
   begin
    i := topVisible;
    go2end(True, True);
    if topVisible > i then
     begin
//      not2go2end := False;
      fAutoScrollState := ASS_FULLSCROLL;
      topOfs := 0;
     end;
    topVisible := i;
   end;

  SendMessage(Self.Handle, CM_INVALIDATE, 0, 0);
//  Repaint;
end;

function ThistoryBox.getAutoScroll: Boolean;
begin
//  result := fAutoScrollState < ASS_FULLDISABLED;
//  result := fAutoScrollState = ASS_FULLSCROLL;
  result := (fAutoScrollState = ASS_FULLSCROLL)
    or ((fAutoScrollState = ASS_ENABLENOTSCROLL)
        and P_lastEventIsFullyVisible
    );
end;

{procedure ThistoryBox.setAutoScroll(vAS : Boolean);
begin
  if (fAutoScrollState < ASS_FULLDISABLED)  <> vAS then
   begin
     if vAS then
      begin
       not2go2end := False;
       topOfs := 0;
      end;
     fAutoscroll := vAS;
     Repaint;
   end
end;}

procedure ThistoryBox.setAutoScrollForce(vAS: Boolean);
var
  changed: boolean;
begin
{//  if fAutoscroll <> vAS then
  if (fAutoScrollState < ASS_FULLDISABLED)  <> vAS then
   begin
    if vAS then
     begin
       not2go2end := False;
       topOfs := 0;
     end;
    fAutoscroll := vAS;
    Repaint;
   end
  else
  if vAS and not2go2end then
   begin
     not2go2end := False;
     topOfs := 0;
     Repaint;
   end;}
 if vAS then
   topOfs := 0;
 changed := false;
 case fAutoScrollState of
   ASS_FULLSCROLL:
       if not vAS then
         begin
           fAutoScrollState := ASS_FULLDISABLED;
           changed := True;
         end;
   ASS_ENABLENOTSCROLL:
       if vAS then
         begin
           fAutoScrollState := ASS_FULLSCROLL;
           changed := True;
         end
        else 
         begin
           fAutoScrollState := ASS_FULLDISABLED;
           changed := True;
         end;
   ASS_FULLDISABLED:
       if vAS then
         begin
           fAutoScrollState := ASS_FULLSCROLL;
           changed := True;
         end;
 end;
 if changed then
   Repaint;
end;

procedure ThistoryBox.setScrollPrefs(ShowAll: Boolean);
var
  olds, news: integer;
//  i: Integer;
  oldTime: TDateTime;
  autoscr: Boolean;
begin
    whole := ShowAll;
    autoscr := autoScrollVal;
    if whole then
     begin
      offset := 0;
      with history do
      if not loaded then
        begin
         olds := count;
         if olds > 0 then
           oldTime := getAt(0).when
          else
           oldTime := 0;
         Clear;
         load(who);
         news := Count;
         if oldTime > 0 then
          begin
//            olds := news;
            while (news >0) and (getAt(news-1).when >= oldTime) do
             Dec(news);
//            dec(news, max(0, olds));
//         news := count-olds;
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
       autoscr := TRUE;
       offset := newSession;
       if topVisible < offset then
         topVisible := offset;
     end;
//    setAutoScrollForce(autoScroll);
  autoScrollVal := autoscr;
  repaint;
  DoOnScroll();
  updateRSB(false, 0, True);
end;

function ThistoryBox.AllowShowAll: Boolean;
begin
  Result := True;
end;

function ThistoryBox.hasEvents: Boolean;
begin
  Result := topVisible > 0;
end;

function ThistoryBox.historyNowCount: Integer;
begin
  if Assigned(history) then
    result := history.count-historyNowOffset
   else
    Result := 0;
end;

function ThistoryBox.historyNowOffset: Integer;
begin
  if whole then
    result := 0
   else
    result := newSession
end;

procedure ThistoryBox.DoOnScroll;
begin
  if Assigned(FOnScroll) then
    FOnScroll(Self);
end;

function  ThistoryBox.getQuoteByIdx(var pQuoteIdx: Integer): String;
var
  i: Integer;
  he: Thevent;
begin
  Result := '';
  with history do
   begin
    // search for a msg to quote
    if pQuoteIdx < 0 then
      i := Count - 1
     else
      i := pQuoteIdx - 1;
    he := NIL;
    if i>=0 then
     begin
      he := getAt(i);
      while (i>=0) and (he.who.isMyAcc
        or not (he.kind in [EK_msg, EK_url, EK_automsg])) do
       begin
        dec(i);
        if i>=0 then
          he := getAt(i);
       end;
     end;
    if i < 0 then  // nothing found, try restarting search from the end
      begin
      i := count-1;
      if i>=0 then
       begin
        he := getAt(i);
        while (i>=0) and (he.who.isMyAcc
        or not (he.kind in [EK_msg, EK_url, EK_automsg])) do
          begin
            dec(i);
            if i>=0 then
              he := getAt(i);
          end;
       end;
      end;
    if i < 0 then
      exit; // nothing found, really
    pQuoteIdx := i;
     theme.applyFont('history.my', self.canvas.font);
//        selected:=getAt(i).getBodyText();
    Result := he.getBodyText();
   end;
end;

procedure ThistoryBox.trySetNot2go2end;
//var
//  vTopVis : Integer;
begin
//   vTopVis := topVisible;
//   go2end(True, True);
//   if topVisible > vTopVis then

//     not2go2end := True;
  if fAutoScrollState = ASS_FULLSCROLL then
    fAutoScrollState := ASS_ENABLENOTSCROLL;

//   topVisible := vTopVis;
end;
procedure ThistoryBox.histScrollEvent(d: integer);
begin
  if not rsb_visible
  or ((rsb_position=0) and (d<0))
  or ((rsb_position = historyNowCount-1) and (d>0)) then
    exit;
  startWithLastLine := FALSE;
  topVisible := historyNowOffset + min(max(rsb_position+d, 0),  historyNowCount-1);
  updateRSB(False, rsb_position+d, True);
  topOfs := 0;
  updateLSB;
//  fAutoscroll := False;
   trySetnot2go2end;
//  if selecting then
//    updatePointedItem()
//   else
//    repaint;
  SendMessage(Self.Handle, CM_INVALIDATE, 0, 0);
  DoOnScroll();
end; // histScrollEvent

procedure ThistoryBox.histScrollLine(d: integer);
begin
  startWithLastLine := False;
//  fAutoscroll := False;
//  not2go2end := True;
  if d > 0 then
    begin
    if topOfs < topEventNrows-1 then
      begin
        inc(topOfs);
      end
    else
      if topVisible < offset + historyNowCount-1 then
       begin
        histScrollEvent(+1);
        exit;
       end;
    end
  else
    if topOfs > 0 then
      begin
        dec(topOfs);
      end
    else
      if topVisible > offset then
        begin
          updateRSB(True, rsb_position-1, True);
          topVisible := offset + rsb_position;
          startWithLastLine := TRUE;
        end;
    trySetNot2go2end;
//  if selecting then
//    updatePointedItem()
//   else
    repaint;
  DoOnScroll();
end; // histScrollLine


procedure ThistoryBox.WMVScroll(var Msg: TWMVScroll);
var
//  i: Integer;
  si: SCROLLINFO;
begin
  case Msg.ScrollCode of
    SB_BOTTOM:
//      with chatFrm.thisChat do
      begin
//        autoscroll := TRUE;
        autoScrollVal := TRUE;
//        repaint;//AndUpdateAutoscroll();
      end;
    SB_TOP:
      begin
        histScrollEvent(-rsb_position);
      end;
    SB_ENDSCROLL:
      begin

      end;
    SB_PAGEUP:
      begin
        histScrollEvent(-5);
      end;
    SB_PAGEDOWN:
      begin
        histScrollEvent(+5);
      end;

    SB_LINEUP:
      begin
        if GetKeyState(VK_CONTROL) and $8000 > 0 then
          histScrollLine(-wheelVelocity)
         else
          histScrollEvent(-wheelVelocity)
      end;
    SB_LINEDOWN:
      begin
        if GetKeyState(VK_CONTROL) and $8000 > 0 then
          histScrollLine(+wheelVelocity)
         else
          histScrollEvent(+wheelVelocity);
      end;
    SB_THUMBPOSITION,
    SB_THUMBTRACK:
      begin
        si.cbSize := sizeof(si);
        si.fMask := SIF_TRACKPOS;

      // Call GetScrollInfo to get current tracking
      //    position in si.nTrackPos
        if not GetScrollInfo(Handle, SB_VERT, si) then
            msg.Result := 1; // GetScrollInfo failed
        if si.nTrackPos = rsb_position then
          exit;
        topVisible:= si.nTrackPos + offset;
        topOfs:=0;
        updateRSB(True, si.nTrackPos, True);
        repaint;
        DoOnScroll();
      end;
    else
//     Msg.Result := 0;
     exit;
  end;
//  Msg.Result := 0;
end;

procedure THistoryBox.DrawEmoji(Sender: TObject);
(*var
   LCanvas: TDirect2DCanvas;
begin
   LCanvas := TDirect2DCanvas.Create(Canvas, ClientRect);
   LCanvas.BeginDraw;

   try
     { Drawing goes here }
     LCanvas.Brush.Color := clRed;
     LCanvas.Pen.Color := clBlue;
     LCanvas.Rectangle(100, 100, 200, 200);

   finally
     LCanvas.EndDraw;
     LCanvas.Free;
   end;
*)begin
end;

procedure ThistoryBox.PPM_copylink2clpbdClick(Sender: TObject);
begin
//with thisChat.historyBox do
//  if pointedItem.kind=PK_LINK then
//    clipboard.asText := pointedItem.link.str;
//with thisChat.historyBox.pointedItem do
  with ClickedItem do
  if kind = PK_LINK then
    clipboard.asText := link.str;
end;

procedure ThistoryBox.PPM_copy2clpbClick(Sender: TObject);
begin
  copySel2Clpb;
end;


procedure TscrollBarEx.CMMouseEnter(var msg: TMessage);
begin
  P_entering := True;
  if Assigned(onEnter) then
    onEnter
end;

procedure TscrollBarEx.CMMouseLeave(var msg: TMessage);
begin
  P_entering := False;
  if Assigned(onLeave) then
    onLeave
end;

 {$IFDEF CHAT_USE_LSB}
procedure THistoryData.lsbScroll(Sender: TObject; ScrollCode: TScrollCode; var ScrollPos: Integer);
var
//  ch: TchatInfo;
  hb: THistoryBox;
begin
 with sender as Tscrollbar do
 begin
  if position = scrollpos then
    exit;
//  ch := thisChat;
  hb := getCurrentHistBox;
  if hb=NIL then
    exit;
  hb.topOfs := scrollpos;
  if ScrollPos > 0 then
    hideScrollTimer := 0;
  hb.repaint();
  hb.DoOnScroll;
//  ch.updateAutoscroll(nil);
 end;
end; // lsbScroll

procedure THistoryBox.updateLSB;
begin
//if ch=NIL then exit;
  if (topEventNrows<2) then
    begin
     lsb.enabled := False;
     if HistoryData.popupLSB then
       lsb.width := MulDiv(minimizedScroll, GetParentCurrentDpi, cDefaultDPI)
//   updateAutoscroll(nil);
    end
   else
    begin
     lsb.min := 0;
     lsb.max := topEventNrows-1;
     lsb.pagesize := 1;
     if lsb.position <> topOfs then
       lsb.position := topOfs;

     if lsb.Position > 0 then
       lsb.width := MulDiv(maximizedScroll, GetParentCurrentDpi, cDefaultDPI)
      else
       if not lsb.MouseInClient then
         HistoryData.hideScrollTimer := 10;
 //  if lsb.Position = 0 then
    lsb.enabled := True;
  end;
end; // updateLSB

procedure THistoryData.lsbEnter;
var
  hb: THistoryBox;
begin
  if not popupLSB then
    exit;
  hb := getCurrentHistBox;
  if hb=NIL then
    exit;
  with hb.lsb do
   if not entering then
     begin
      if position = 0 then
        hideScrollTimer := 10
     end
   else
     begin
      hideScrollTimer := 0;
      width := MulDiv(maximizedScroll, GetParentCurrentDpi, cDefaultDPI);
     end;
end;

procedure THistoryData.setLeftSB(visible: boolean);
var
//  ch: TChatInfo;
  hb: THistoryBox;
begin
  showLSB := visible;
//  ch := thisChat;
  hb := getCurrentHistBox;
  if hb=NIL then
    exit;
  if (hb.lsb <> NIL) then
    hb.lsb.visible := showLSB;
end;

 {$ENDIF CHAT_USE_LSB}

function THistoryData.getCurrentHistBox: THistoryBox;
begin
//  Result := ThisChat.HistoryBox;
  Result := currentHB;
end;

procedure THistoryData.onTimer(hb: ThistoryBox);
var
  h: ThistoryBox;
begin
  if hb = NIL then
    h := getCurrentHistBox
   else
    h := hb;
{$IFDEF CHAT_USE_LSB}
  // hide message scrollbar
  if popupLSB and (hideScrollTimer>0) then
    begin
     dec(hideScrollTimer);
     if hideScrollTimer=0 then
       begin
         if h<>NIL then
           if Assigned(h.lsb) then
             h.lsb.width := MulDiv(minimizedScroll, h.GetParentCurrentDpi, cDefaultDPI);
       end;
    end;
{$ENDIF CHAT_USE_LSB}
end;

procedure THistoryData.savePicMnuClick(Sender: TObject);
var
 pic: AnsiString;
 p: string;
 i, k: Integer;
 RnQPicStream //, RnQPicStream2
   : TMemoryStream;
// fmt: TGUID;
  hb: THistoryBox;
begin
  hb := getCurrentHistBox;
  if hb=NIL then
    exit;
  {$IFNDEF CHAT_SCI}
  with hb do
//   if pointedItem.kind=PK_RQPICEX then
   if clickedItem.kind=PK_RQPICEX then
    begin
      pic := clickedItem.ev.getBodyBin;
      i := Pos(RnQImageExTag, pic);
      k := PosEx(RnQImageExUnTag, pic, i+12);
      if (i > 0) and (k > 5) then
      begin
            pic := Base64DecodeString(Copy(pic, i+12, k-i-12));
//            pic := '';
            RnQPicStream := TMemoryStream.Create;
 {$WARN UNSAFE_CODE OFF}
            RnQPicStream.Write(pic[1], Length(pic));
 {$WARN UNSAFE_CODE ON}
            pic := '';
            p := PAFormat[DetectFileFormatStream(RnQPicStream)];
           Delete(p, 1, 1);
           p := openSavedlg(Application.mainForm, '', false, p);
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
        p := openSavedlg(Application.mainForm, '', false, 'wbmp');
        if p > '' then
         begin
           RnQPicStream := TMemoryStream.Create;
 {$WARN UNSAFE_CODE OFF}
           RnQPicStream.Write(pic[i+10], k-i-10);
 {$WARN UNSAFE_CODE ON}
           RnQPicStream.SaveToFile(p);
           RnQPicStream.Free;
         end;
      end
    end;
  {$ENDIF ~CHAT_SCI}
end;

procedure THistoryData.toantispamClick(Sender: TObject);
var
  hb: THistoryBox;
begin
  hb := getCurrentHistBox;
  if hb=NIL then
    exit;
  if spamfilter.badwords <> '' then
   spamfilter.badwords := spamfilter.badwords + ';';
  spamfilter.badwords := spamfilter.badwords + hb.getSelText;
end;

procedure THistoryData.txt1Click(Sender: TObject);
var
  fn: string;
  hb: THistoryBox;
begin
  hb := getCurrentHistBox;
  if hb=NIL then
    exit;
  fn := openSavedlg(Application.mainForm, 'Save text as UTF-8 file', false, 'txt');
  if fn = '' then
    exit;
  saveTextFile(fn, hb.getSelText);
end;

procedure THistoryData.viewmessageinwindow1Click(Sender: TObject);
var
  hb: THistoryBox;
begin
  hb := getCurrentHistBox;
  if hb=NIL then
    exit;
  with hb do
    if somethingIsSelected then
      viewTextWindow(MainPrefs, getTranslation('selection'), getSelText)
 {$IFNDEF CHAT_CEF} // Chromium
 {$IFNDEF CHAT_SCI}
  else
//    if pointedItem.kind<>PK_NONE then
    if clickedItem.kind<>PK_NONE then
      if ((clickedItem.Kind = PK_RQPIC) or (clickedItem.Kind = PK_RQPICEX)) and not (clickedItem.ev.getBodyBin = '')then
        viewImageDimmed(hb.parent, clickedItem.ev.getBodyBin, clickedItem.ofs)
      else
        viewHeventWindow(clickedItem.ev);
 {$ENDIF ~CHAT_SCI}
 {$ENDIF ~CHAT_CEF} // Chromium
end;

procedure THistoryData.addcontactAction(sender: Tobject);
var
  hb: THistoryBox;
  cnt: TRnQContact;
begin
  hb := getCurrentHistBox;
  if hb=NIL then
    exit;
  cnt := hb.who;
  if Assigned(cnt) then
    cnt := cnt.fProto.getContact(selectedUIN);
  if Assigned(cnt) then
    addToRoster(cnt, (sender as Tmenuitem).tag, cnt.CntIsLocal)
end;

procedure THistoryData.addlink2favClick(Sender: TObject);
var
  hb: THistoryBox;
begin
  hb := getCurrentHistBox;
  if hb=NIL then
    exit;
 {$IFDEF CHAT_SCI}
  with hb.clickedItem do
    if Kind = PK_LINK then
      addLinkToFavorites(stripProtocol(stringData));
 {$ELSE ~CHAT_SCI}
//with thisChat.historyBox.pointedItem do
 with hb.clickedItem do
  if kind=PK_LINK then
    addLinkToFavorites(link.str);
 {$ENDIF ~CHAT_SCI}
end;

procedure THistoryData.ANothingExecute(Sender: TObject);
begin
  ;;;
end;

procedure THistoryData.chatShowDevToolsClick(Sender: TObject);
var
  hb: THistoryBox;
begin
  hb := getCurrentHistBox;
  if hb=NIL then
    exit;
  hb.ShowDebug;
end;

procedure THistoryData.copylink2clpbdClick(Sender: TObject);
var
  hb: THistoryBox;
begin
  hb := getCurrentHistBox;
  if hb=NIL then
    exit;
 {$IFDEF CHAT_SCI}
  with hb.clickedItem do
    if Kind = PK_LINK then
      clipboard.asText := stripProtocol(stringData);
 {$ELSE}
//with thisChat.historyBox do
//  if pointedItem.kind=PK_LINK then
//    clipboard.asText := pointedItem.link.str;
//with thisChat.historyBox.pointedItem do
  with hb.ClickedItem do
  if kind=PK_LINK then
    clipboard.asText := link.str;
 {$ENDIF ~CHAT_SCI}
end;

procedure THistoryData.hAchatpopuplsbExecute(Sender: TObject);
var
  hb: THistoryBox;
begin
 {$IFDEF CHAT_USE_LSB}
  popupLSB := not popupLSB;
 {$ENDIF CHAT_CEF}
  hb := getCurrentHistBox;
  if hb=NIL then
    exit;
  hb.updateGraphics;
end;

procedure THistoryData.hAchatpopuplsbUpdate(Sender: TObject);
begin
 {$IFDEF CHAT_USE_LSB}
  with TAction(Sender) do
   if popupLSB then
     HelpKeyword := PIC_RIGHT
    else
     HelpKeyword := '';
 {$ENDIF CHAT_CEF}
//    TAction(Sender).HelpKeyword := PIC_CHECKED
//   else
//    TAction(Sender).HelpKeyword := PIC_UNCHECKED;}
//  TAction(Sender).HelpKeyword := PIC_CHECK_UN[popupLSB];
end;

procedure THistoryData.hAchatshowlsbExecute(Sender: TObject);
begin
 {$IFDEF CHAT_USE_LSB}
  setLeftSB(not showLSB)
 {$ENDIF ~CHAT_USE_LBM}
end;

procedure THistoryData.hAchatshowlsbUpdate(Sender: TObject);
begin
 {$IFDEF CHAT_USE_LSB}
  with TAction(Sender) do
   if showLSB then
     HelpKeyword := PIC_RIGHT
    else
     HelpKeyword := '';
 {$ENDIF CHAT_CEF}
//    TAction(Sender).HelpKeyword := PIC_CHECKED
//   else
//    TAction(Sender).HelpKeyword := PIC_UNCHECKED;
//  TAction(Sender).HelpKeyword := PIC_CHECK_UN[showLSB];
end;

procedure THistoryData.hACopyExecute(Sender: TObject);
var
  hb: THistoryBox;
begin
  hb := getCurrentHistBox;
  if hb=NIL then
    exit;
  hb.copySel2Clpb;
end;

procedure THistoryData.hAdeleteExecute(Sender: TObject);
var
  hb: THistoryBox;
begin
  hb := getCurrentHistBox;
  if hb=NIL then
    exit;
  hb.DeleteSelected;
end;

procedure THistoryData.hAOpenChatWithExecute(Sender: TObject);
var
//  uid: TUID;
  hb: THistoryBox;
begin
  hb := getCurrentHistBox;
  if hb=NIL then
    exit;
{
  if Assigned(hb.who) then
    if enterUinDlg(hb.who.fProto, uid, getTranslation('Open chat with...')) then
//      if who.fProto.validUid1(uid) then
      ChatFrm.openOn(hb.who.fProto.getContact(uid));
}
end;

procedure THistoryData.hASelectAllExecute(Sender: TObject);
var
  hb: THistoryBox;
begin
  hb := getCurrentHistBox;
  if hb=NIL then
    exit;
  hb.SelectAll;
end;

procedure THistoryData.hAShowSmilesExecute(Sender: TObject);
var
//  ch: TchatInfo;
  b: Boolean;
var
  hb: THistoryBox;
begin
//  useSmiles := TAction(Sender).Checked;
  b := MainPrefs.getPrefBoolDef('use-smiles', True);
  MainPrefs.addPrefBool('use-smiles', not b);
  hb := getCurrentHistBox;
  if hb=NIL then
    exit;
{$IFDEF CHAT_SCI}
  UpdateChatSettings;
  UpdateChatSmiles;
{$ELSE ~CHAT_SCI}
  hb.ManualRepaint;
{$ENDIF ~CHAT_SCI}
end;

procedure THistoryData.hAShowSmilesUpdate(Sender: TObject);
begin
 with TAction(Sender) do
  begin
    Checked := MainPrefs.getPrefBoolDef('use-smiles', True);
    if Checked then
       HelpKeyword := PIC_RIGHT
     else
       HelpKeyword := '';
  end;
end;

procedure THistoryData.hAViewInfoExecute(Sender: TObject);
var
  hb: THistoryBox;
begin
  hb := getCurrentHistBox;
  if hb=NIL then
    exit;
{$IFNDEF CHAT_SCI}
  with hb do
  if Assigned(clickedItem.ev) and Assigned(clickedItem.ev.who) then
    clickedItem.ev.who.ViewInfo;
{$ENDIF ~CHAT_SCI}
end;

procedure THistoryData.histmenuPopup(Sender: TObject);
begin
  chatShowDevTools.Visible := cmdLinePar.Debug;
 {$IFDEF CHAT_USE_LSB}
  chatshowlsb1.checked := showLSB;
  chatpopuplsb1.visible := showLSB;
  chatpopuplsb1.checked := popupLSB;
 {$ELSE CHAT_USE_LSB}
  chatshowlsb1.Visible := false;
  chatpopuplsb1.visible := false;
//  chatShowDevTools.Visible := True;
 {$ENDIF ~CHAT_USE_LSB}
end;

procedure THistoryData.html1Click(Sender: TObject);
var
  fn: string;
  hb: THistoryBox;
begin
  hb := getCurrentHistBox;
  if hb=NIL then
    exit;
  fn := openSavedlg(Application.mainForm, '', false, 'html');
  if fn = '' then
    exit;
  saveTextFile(fn, hb.getSelHtml(FALSE));
end;

end.
