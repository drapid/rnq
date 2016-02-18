{
  This file is part of R&Q.
  Under same license
}
unit historySCI;
{$I RnQConfig.inc}
{$I NoRTTI.inc}

interface

uses
  Windows, Controls, Classes, Generics.Collections,
  SysUtils, Graphics, Forms, StdCtrls, ExtCtrls,
  Messages, StrUtils, System.UITypes, Variants,
  RDGlobal, history, RnQProtocol, events,
  Sciter, SciterApi, TiScriptApi, SciterNative;


type
  TlinkKind = (LK_FTP, LK_EMAIL, LK_WWW, LK_UIN, LK_ED);
  TAutoScrollState = (ASS_FULLSCROLL, // fAutoscroll = True, not2go2end = false
    ASS_ENABLENOTSCROLL, // fAutoscroll = True, not2go2end = True
    ASS_FULLDISABLED); // fAutoscroll = False, not2go2end = Any

  TitemKind = (PK_NONE, PK_HEAD, PK_TEXT, PK_ARROWS_UP, PK_ARROWS_DN, PK_LINK, PK_SMILE, PK_CRYPTED, PK_RQPIC, PK_RQPICEX, PK_RNQBUTTON);
  PhistoryItem = ^ThistoryItem;

  ThistoryLink = record
    evIdx: integer; // -1 for null links
    str: String;
    from, to_: integer;
    kind: TlinkKind;
    id: integer;
    ev: Thevent;
  end;

  TLinkClickEvent = procedure(const Sender: TObject; const LinkHref: String; const LinkText: String) of object;
  TonShowMenu = procedure (Sender: TObject; const Data: String; clickedTime: TDateTime; linkClicked, imgClicked: Boolean) of Object;

  TChatItem = record
    kind: TitemKind;
    stringData: String;
    timeData: TDateTime;
  end;

  ThistoryItem = record
    kind: TitemKind; // PK_NONE for null items
    ev: Thevent;
    evIdx, ofs, l: integer;
    r: Trect;
    link: ThistoryLink;
  end;

  ThistoryPos = record
    ev: Thevent; // NIL for null positions
    //evIdx: integer; // -1 for void positions
    ofs: integer; // -1 when the whole event is selected
  end;
(*
  ThistoryBoxOld = class(TcustomControl)
  private
    // For History at all
    items: array of ThistoryItem;
    P_lastEventIsFullyVisible: boolean;
    startWithLastLine: boolean;
    P_topEventNrows, P_bottomEvent: integer;
    fAutoScrollState: TAutoScrollState; // auto scrolls along messages
    FOnScroll: TNotifyEvent;
  private
    // For Active History!
    lastTimeClick: TdateTime;
    // avoidErase: boolean;
    selecting: boolean;
    justTriggeredAlink, dontTriggerLink, just2clicked: boolean;
    lastClickedItem, P_pointedSpace, P_pointedItem: ThistoryItem;
    linkToUnderline: ThistoryLink;
    FOnLinkClick: TLinkClickEvent;
    buffer: TBitmap;
    // fAutoscroll:boolean;    // auto scrolls along messages
    // not2go2end : Boolean;
  private
    // Same for all historys
    firstCharactersForSmiles: set of AnsiChar; // for faster smile recognition
    // firstCharactersForSmiles: set of Char; // for faster smile recognition
    lastWidth
    // , lastHeight
      : integer;
    // ----------------------------------------------------------------------------
    // hasDownArrow: Boolean;
    // hDownArrow: Integer;
  protected
    procedure DoBackground(cnv0: Tcanvas; vR: Trect; var SmlBG: TBitmap32);
    // procedure DoBackground(DC: HDC);
    procedure WMEraseBkgnd(var Msg: TWmEraseBkgnd); message WM_ERASEBKGND;
    procedure WMVScroll(var Msg: TWMVScroll); message WM_VSCROLL;
    procedure CreateParams(var Params: TCreateParams); override;
    function getAutoScroll: boolean;
    procedure setAutoScrollForce(vAS: boolean);
    // procedure setAutoScroll(vAS : Boolean);
    // procedure wmPaint(var msg : TWMPaint); message WM_PAINT;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: integer); override;
    procedure Click; override;
    function triggerLink(item: ThistoryItem): boolean;
    function itemAt(pt: Tpoint): ThistoryItem;
    function spaceAt(pt: Tpoint): ThistoryItem;
    procedure updatePointedItem();
  public
    topVisible, topOfs: integer;
    offset: integer; // can't show hevents before this
    startSel, endSel: ThistoryPos;
    who: TRnQContact;
    history: Thistory;
    margin: Trect;
    whole: boolean; // see whole history
    rsb_visible: boolean;
    rsb_position: integer;
    rsb_rowPerPos: integer;
    newSession: integer; // where, in the history, does start new session
    onPainted: TNotifyEvent;
    w2s: String;

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
    property autoScrollVal: boolean read getAutoScroll write setAutoScrollForce;
    property OnScroll: TNotifyEvent read FOnScroll write FOnScroll;
    property onLinkClick: TLinkClickEvent read FOnLinkClick write FOnLinkClick;

    constructor Create(owner_: Tcomponent); override;
    destructor Destroy; override;
    procedure Paint(); override;
    procedure paintOn(cnv: Tcanvas; vR: Trect; const JustCalc: boolean = false);
    procedure go2end(const calcOnly: boolean = false; const precalc: boolean = false);
    function getSelText(): string;
    function getSelBin(): AnsiString;
    function getSelHtml(smiles: boolean): string;
    function getSelHtml2(smiles: boolean): RawByteString;
    function somethingIsSelected(): boolean;
    function wholeEventsAreSelected(): boolean;
    function nothingIsSelected(): boolean;
    function partialTextIsSelected(): boolean;
    procedure ManualRepaint;

    function offsetPos: integer;
    procedure select(from, to_: integer);
    procedure deselect();

    procedure updateRSB(SetPos: boolean; pos: integer = 0; doRedraw: boolean = true);
    procedure addEvent(ev: Thevent);
    function historyNowCount: integer;
    function historyNowOffset: integer;
    procedure trySetNot2go2end;
    procedure histScrollEvent(d: integer);
    procedure histScrollLine(d: integer);
    procedure Scroll;
    function getQuoteByIdx(var pQuoteIdx: integer): String;
  end; // ThistoryBox
*)
  TParams = array of OleVariant;

//  PHistoryBox = ^THistoryBox;

  THistoryBox = class(TSciter)
   private
    class var templateFile: String;
   private
    //template: TStringList;
    // For History at all
    items: array of ThistoryItem;
    P_lastEventIsFullyVisible: boolean;
    P_topEventNrows, P_bottomEvent: integer;
    fAutoScrollState: TAutoScrollState; // auto scrolls along messages
    FOnScroll: TNotifyEvent;

    // For Active History!
    lastTimeClick: TdateTime;
    justTriggeredAlink, dontTriggerLink, just2clicked: boolean;
    lastClickedItem, P_pointedSpace, P_pointedItem: ThistoryItem;
    linkToUnderline: ThistoryLink;
    FOnLinkClick: TLinkClickEvent;
    fOnShowMenu: TonShowMenu;

//    firstCharactersForSmiles: set of AnsiChar; // for faster smile recognition

  protected
    function  getAutoScroll: boolean;
    procedure setAutoScroll(asState: TAutoScrollState);
    procedure setAutoScrollForce(vAS: boolean);
  public
    selectedText: String;
    topVisible: TDateTime;
    topOfs: integer;
    offset, offsetAll: integer; // can't show hevents before this
    startSel, endSel: ThistoryPos;
    isWholeEvents: Boolean;
    who: TRnQContact;
    history: Thistory;
    margin: Trect;
    rsb_visible: boolean;
    rsb_position: integer;
    rsb_rowPerPos: integer;
    onPainted: TNotifyEvent;
    w2s: String;
    rightClickedChatItem: TChatItem;
    //templateLoaded: Boolean;
    embeddedImgs: TDictionary<LongWord, RawByteString>;

    property lastEventIsFullyVisible: boolean read P_lastEventIsFullyVisible;
    property pointedItem: ThistoryItem read P_pointedItem;
    property clickedItem: ThistoryItem read lastClickedItem;
    property pointedSpace: ThistoryItem read P_pointedSpace;
    property topEventNrows: integer read P_topEventNrows;
    property bottomEvent: integer read P_bottomEvent;
    property autoScrollVal: boolean read getAutoScroll write setAutoScrollForce;
    property OnScroll: TNotifyEvent read FOnScroll write FOnScroll;
    property onLinkClick: TLinkClickEvent read FOnLinkClick write FOnLinkClick;
    property OnShowMenu: TonShowMenu read fOnShowMenu write fOnShowMenu;

    function escapeQuotes(const text: String): String;
//    function escapeNewlines(const text: String): String;

    procedure LoadTemplate;
    class function  PreLoadTemplate: Boolean;
    procedure InitFunctions;
    procedure ClearEvents;
    procedure ReloadLast;
    procedure InitSettings;
    procedure InitSmiles;
    procedure InitAll;
    procedure UpdateSmiles;
    procedure RememberScrollPos;
    procedure RestoreScrollPos;
    procedure addChatItem(var params: TParams; hev: Thevent; animate: Boolean; last: Boolean = True);
    procedure sendChatItems(params: TParams; prepend: Boolean = False; hidehist: Boolean = False);
    procedure ShowDebug;

//    constructor Create(AOwner: Tcomponent; cnt: TRnQContact); override;
    constructor Create(AOwner: Tcomponent; cnt: TRnQContact); OverLoad;
    destructor  Destroy; override;
    procedure go2start();
    procedure go2end(animate: Boolean = False);
    function  moveToTime(time: TDateTime; NeedOpen: Boolean = false): Boolean;

    function  getSelText: String;
    function  getSelBin(): AnsiString;
    //function  getSelHtml(smiles: boolean): string;
    function  getSelHtml2(smiles: boolean): RawByteString;
    function  somethingIsSelected(): boolean;
    function  wholeEventsAreSelected(): boolean;
    function  nothingIsSelected(): boolean;
    function  partialTextIsSelected(): boolean;
    procedure copySel2Clpb;
    function  getWhole: Boolean;
    function  AllowShowAll: Boolean;

    procedure select(from, to_: TDateTime);
    procedure selectAll;
    procedure deselect();
    procedure DeleteSelected;

    procedure updateRSB(SetPos: boolean; pos: integer = 0; doRedraw: boolean = true);
    procedure addEvent(ev: Thevent);
    function  historyNowCount: integer;
    procedure histScrollEvent(d: integer);
    procedure histScrollLine(d: integer);
    procedure doOnScroll;
    procedure histScrollWheel(d: integer);
    function  getQuoteByIdx(var pQuoteIdx: integer): String;
    procedure requestQuote;
    procedure updateMsgStatus(hev: Thevent);
    procedure InitRequest(ASender: TObject; const url: WideString; resType: SciterResourceType; requestId: Integer; out discard: Boolean);
    procedure ReturnFocus(Sender: TObject);
    procedure DoShowMenu(const Data: String; clickedTime: TDateTime; linkClicked, imgClicked: Boolean);
    property  Color;
    property  whole: Boolean read getWhole;
  end;
{
  TExtension = class(TCefv8HandlerOwn)
  protected
    function Execute(const name: ustring; const obj: ICefv8Value;
                     const arguments: TCefv8ValueArray; var retval: ICefv8Value;
                     var exception: ustring): Boolean; override;
  end;

  TCustomRenderProcessHandler = class(TCefRenderProcessHandlerOwn)
  protected
    procedure OnWebKitInitialized; override;
    function OnProcessMessageReceived(const browser: ICefBrowser; sourceProcess: TCefProcessId; const message: ICefProcessMessage): Boolean; override;
  end;
}
  TRequestHandler = class
  private
    FSciter: TSciter;
    FDataStream: TMemoryStream;
    FStatus: Integer;
    FStatusText: string;
  protected
    procedure ProcessRequest(ASender: TObject; const url: WideString; resType: SciterResourceType; requestId: Integer; out discard: Boolean);
    procedure CheckAnimatedGifSize;
//    procedure GetResponseHeaders(const response: ICefResponse; out responseLength: Int64; out redirectUrl: ustring); override;
  public
    constructor Create(Sciter: TSciter);
    destructor Destroy; override;
  end;

var
  hisBGColor, myBGColor: TColor;
//  renderInit: Boolean = False;

implementation

uses
  clipbrd, Types, math,
{$IFDEF UNICODE}
  Character,
  AnsiStrings, AnsiClasses,
{$ENDIF UNICODE}
  RDFileUtil,
  RnQSysUtils, RnQLangs, RnQFileUtil, RDUtils, RnQBinUtils,
  RQUtil, RQThemes, RnQButtons, RnQGlobal, RnQCrypt, RnQPics, RnQNet,
  globalLib, mainDlg, utilLib, Protocols_all,
//  chatDlg,
  roasterLib,
  // historyRnQ,
  Base64,
  ICQConsts, ICQv9, RQ_ICQ,
{$IFDEF USE_GDIPLUS}
  RnQGraphics,
{$ELSE}
  RnQGraphics32,
{$ENDIF USE_GDIPLUS}
  themesLib, menusUnit, ViewPicDimmedDlg, Murmur2;

var
  lastBGCnt: TRnQContact;
  lastBGToken: integer;
  vKeyPicElm: TRnQThemedElementDtls;
{
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

function equal(const a, b: ThistoryItem): boolean; overload;
begin
  result := (a.evIdx = b.evIdx) and (a.ofs = b.ofs) and (a.kind = b.kind)
end;

function equal(const a, b: ThistoryLink): boolean; overload;
begin
  result := (a.evIdx = b.evIdx) and (a.from = b.from) and (a.to_ = b.to_)
end;
}
function minor(const a, b: Tpoint): boolean; overload;
begin
  result := (a.Y < b.Y) or (a.Y = b.Y) and (a.X < b.Y)
end;

function isLink(const it: ThistoryItem): boolean;
begin
  result := it.kind = PK_LINK
end;

function historyitem2pos(const a: ThistoryItem): ThistoryPos;
begin
  if a.kind = PK_NONE then
  begin
    result.ev := nil;
//    result.evIdx := -1;
  end
  else
  begin
    result.ev := a.ev;
//    result.evIdx := a.evIdx;
    result.ofs := a.ofs;
  end
end;

destructor ThistoryBox.Destroy;
begin
  FreeAndNil(embeddedImgs);

  if Assigned(Self) then
    inherited Destroy;
  // self := NIL;
end;

procedure ThistoryBox.copySel2Clpb;
begin
  Call('copySelected', [])
end;

function ThistoryBox.getSelText: String;
begin
  Result := selectedText;
end;

function ThistoryBox.getSelBin(): AnsiString;
begin
  result := '';
end;

function applyHtmlFont(fnt: Tfont; const s: string): string;
var
  h, q: string;
begin
  h := '<font size=2 face="' + fnt.name + '" color=#' + color2str(fnt.color) + '>';
  q := '</font>';
  if fsItalic in fnt.style then
  begin
    h := h + '<i>';
    q := '</i>' + q;
  end;
  if fsBold in fnt.style then
  begin
    h := h + '<b>';
    q := '</b>' + q;
  end;
  result := h + s + q;
end; // applyHtmlFont
{
function ThistoryBox.getSelHtml(smiles: boolean): string;
var
  SOS, EOS: ThistoryPos;
  i, dim: integer;
  ev: Thevent;

  procedure addStr(const s: string);
  begin
    while dim + length(s) > length(result) do
      setLength(result, length(result) + 10000);
    system.move(s[1], result[dim + 1], length(s));
    inc(dim, length(s));
  end; // addStr

var
  fnt: Tfont;
begin
  result := '';
  dim := 0;
  fnt := Tfont.Create;
  // fnt.Assign(Self.canvas.Font);
  fnt.Assign(Screen.MenuFont);
  if startSel.ev = NIL then
    exit;
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
  addStr('<html><head></head><body bgcolor=#' + color2str(TextBGColor) + '>');
  for i := SOS.evIdx to EOS.evIdx do
  begin
    ev := history.getAt(i);
    // ev.applyFont(fnt);
    fnt.Assign(ev.getFont);
    addStr(CRLF + applyHtmlFont(fnt, '<u>[' + getTranslation(event2ShowStr[ev.kind]) + '] ' + datetimeToStr(ev.when) + ', ' +
      ev.who.displayed + '</u>' + '<br>' + str2html(ev.getBodyText) + '<br><br>'));
  end;
  addStr(CRLF + '</body></html>');

  setLength(result, dim);
  fnt.Free;
end; // getSelHtml
}
function str2html2(const s: string): string;
begin
  result := template(s, ['&', '&amp;', '<', '&lt;', '>', '&gt;', CRLF, '<br/>', #13, '<br/>', #10, '<br/>']);
end; // str2html

function color2html(color: TColor): AnsiString;
begin
  // if not ColorToIdent(Color, Result) then
  begin
    color := ABCD_ADCB(ColorToRGB(color));
    result := '#' + IntToHexA(color, 6);
  end;
end; // color2str

function ThistoryBox.getSelHtml2(smiles: boolean): RawByteString;
const
  HTMLTemplate = AnsiString('<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"' + CRLF +
    '"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">' + CRLF + CRLF + '<html>' + CRLF + '<head>' + CRLF +
    '  <title>%TITLE%</title>' + CRLF +
    // '  <meta http-equiv="Content-Type" content="text/html; charset=windows-1251"/>' + CRLF +
    '  <meta http-equiv="Content-Type" content="text/html; charset=UTF8"/>' + CRLF +

    '  <style type="text/css">' + CRLF + CRLF +
    // ' %HOSTS%' + CRLF + CRLF+
    ' %BODY%' + CRLF + CRLF + ' %HOST%' + CRLF + CRLF + ' %GUEST%' + CRLF + '  </style>' + CRLF +

    '</head>' + CRLF + '<body>' + CRLF +

    ' %CONTENT% ' + CRLF +

    '</body>' + CRLF + '</html>');
begin
  // TODO
end;
(*
procedure ThistoryBox.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: integer);

  function doubleClick: boolean;
  begin
    result := just2clicked;
    if just2clicked and not justTriggeredAlink and equal(lastClickedItem, pointedItem) then
    begin
      if ((lastClickedItem.Kind = PK_RQPIC) or (lastClickedItem.Kind = PK_RQPICEX)) and not (lastClickedItem.ev.getBodyBin = '') then
        viewImageDimmed(clickedItem.ev.getBodyBin, clickedItem.ofs)
      else
        viewHeventWindow(history.getAt(endSel.evIdx));
    end;
  end; // doubleClick

begin
  dontTriggerLink := false;
  just2clicked := now - lastTimeClick < dblClickTime;
  if Shift = [ssRight] then
  begin

  end;
  if ssShift in Shift then
  begin
    if pointedSpace.kind <> PK_NONE then
    begin
      endSel := historyitem2pos(pointedSpace);
      repaint();
    end;
    inherited;
    exit;
  end;

  if chatFrm.menuWasCancelled then
  begin
    chatFrm.menuWasCancelled := false;
    exit;
  end;

  deselect();
  case pointedSpace.kind of
    PK_NONE:
      selecting := true;
    PK_CRYPTED:
      if enterPwdDlg(histcrypt.pwd) then
        histcrypt.pwdkey := calculate_KEY1(histcrypt.pwd);
    PK_HEAD, PK_TEXT, PK_LINK, PK_SMILE, PK_RQPIC, PK_RQPICEX:
      if ((pointedSpace.kind <> PK_HEAD) or (pointedItem.kind = PK_HEAD)) and not doubleClick then
      begin
        selecting := true;
        startSel := historyitem2pos(pointedSpace);
        endSel := startSel;
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

procedure ThistoryBox.Click();
begin
  if not dontTriggerLink and (pointedItem.kind = lastClickedItem.kind) and (pointedItem.link.id = lastClickedItem.link.id) then
  begin
    selecting := false;
    triggerLink(pointedItem);
  end;
end;

procedure ThistoryBox.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: integer);
var
  s: string;
begin
  // if selecting then
  // begin
  selecting := false;
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
  l := length(items) - 1;
  if l < 0 then
    exit;
  j := l;
  m := -1;
  // search for an item on the same row
  while i <= j do
  begin
    m := (i + j) div 2;
    r := items[m].r;
    if within(r.Top, pt.Y, r.Bottom) then
      break;
    if (pt.Y < r.Top) or (pt.Y < r.Bottom) and (pt.X < r.left) then
      j := m - 1
    else
      i := m + 1;
  end;
  // if no item is matching the Y, move backward until the item is behind PT
  while m > 0 do
  begin
    if pt.Y < items[m - 1].r.Top then
      dec(m)
    else
      break
  end;
  // without leaving this row, move backward searching for a better matching item
  while m > 0 do
  begin
    r := items[m - 1].r;
    if within(r.Top, pt.Y, r.Bottom) and (pt.X <= r.Right) then
      dec(m)
    else
      break
  end;
  // same, but move forward
  while m < l do
  begin
    r := items[m + 1].r;
    if within(r.Top, pt.Y, r.Bottom) and (pt.X >= r.left) then
      inc(m)
    else
      break
  end;
  // do we have a valid item?
  if m >= 0 then
  begin
    result := items[m];
    // if pt is on the first half of the item then move behind
    if pt.X < centerPoint(result.r).X then
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
  j := length(items) - 1;

  while i <= j do
  begin
    m := (i + j) div 2;
    r := items[m].r;
    if Types.ptInRect(r, pt) then
    begin
      result := items[m];
      break;
    end;
    if (pt.Y < r.Top) or (pt.Y < r.Bottom) and (pt.X < r.left) then
      j := m - 1
    else
      i := m + 1;
  end;
end; // itemAt

procedure ThistoryBox.MouseMove(Shift: TShiftState; X, Y: integer);
begin
  updatePointedItem()
end; // mouseMove
*)
procedure ThistoryBox.go2start();
begin
  Call('chatScrollToTop', []);
end;

procedure ThistoryBox.go2end(animate: Boolean = False);
begin
  Call('chatScrollToBottom', [animate]);
end;

function ThistoryBox.moveToTime(time: TDateTime; NeedOpen: Boolean): Boolean;
var
  f: TFormatSettings;

  function search(ofs: Integer): Integer;
  begin
    result := history.Count-1;
  //  while result >= 0 do
    while result >= ofs do
      if history.getAt(result).when <= time then
        break
      else
        dec(result);
    if result < ofs then
     Result := -1;
    if result >= ofs then
      if history.getAt(result).when <> time then
        result := -1;
  end; // search

begin
  result := search(offset) >= 0;
  f.Create;
  f.DecimalSeparator := '.';
  Call('moveToTime', [floattostr(time, f)]);
end;

function ThistoryBox.getWhole: Boolean;
begin
  result := false;
end;

function ThistoryBox.AllowShowAll: Boolean;
begin
  result := false;
end;

function ThistoryBox.wholeEventsAreSelected(): boolean;
begin
  result := (startSel.ev <> nil) and (endSel.ev <> nil) and isWholeEvents
end;

function ThistoryBox.nothingIsSelected(): boolean;
begin
  result := selectedText = '';
end;

function ThistoryBox.somethingIsSelected(): boolean;
begin
  result := not (selectedText = '');
end;

function ThistoryBox.partialTextIsSelected(): boolean;
begin
  result := not (selectedText = '') and not isWholeEvents
end;

procedure ThistoryBox.select(from, to_: TDateTime);
var
  args: array of OleVariant;
  f: TFormatSettings;
begin
  startSel.ofs := -1;
  startSel.ev := history.getByTime(from);
  endSel.ofs := -1;
  endSel.ev := history.getByTime(to_);
  isWholeEvents := True;
  SetLength(args, 2);
  f.DecimalSeparator := '.';
  args[0] := FloatToStr(from, f);
  args[1] := FloatToStr(to_, f);
  Call('setSelection', args);
end; // select

procedure ThistoryBox.selectAll;
begin
  select(topVisible, history.getAt(history.count - 1).when);
end;

procedure ThistoryBox.deselect();
begin
  startSel.ev := nil;
  isWholeEvents := False;
  Call('clearSelection', []);
end; // deselect

procedure ThistoryBox.DeleteSelected;
var
  st, en: TDateTime;
  f: TFormatSettings;
  t: TDateTime;
begin
  begin
    if not history.loaded then
    begin
      history.Clear;
      history.Load(who);
      //MessageDlg(getTranslation('Load the whole history before removing messages'), mtInformation, [mbOK], 0);
      //Exit;
    end;

    if not wholeEventsAreSelected then
      Exit;

    st := startSel.ev.when;
    en := endSel.ev.when;
    if st > en then
      begin
//        swap(st, en);
        t := st;
        st := en;
        en := t;
      end;

    // history.deleteFromTo(userPath+historyPath + thisContact.uid, st,en);
    history.deleteFromToTime(Who.uid, st, en);
    F.DecimalSeparator := '.';
    Call('deleteEvents', [floattostr(st, f), floattostr(en, f)]);
    deselect();
  end;

end;


procedure ThistoryBox.updateRSB(SetPos: boolean; pos: integer = 0; doRedraw: boolean = true);
var
  ScrollInfo: TScrollInfo;
  // vSBI : TScrollBarInfo;
begin
{
  if historyNowCount < 2 then
  begin
    // ScrollInfo.cbSize := SizeOf(ScrollInfo);
    // ScrollInfo.fMask := SIF_DISABLENOSCROLL; //SIF_ALL;
    // SetScrollInfo(Handle, SB_VERT, ScrollInfo, doRedraw);
    ShowScrollBar(Handle, SB_VERT, false);
    rsb_visible := false;
  end
  else
  begin
    ScrollInfo.cbSize := SizeOf(ScrollInfo);
    ScrollInfo.fMask := SIF_ALL;
    GetScrollInfo(Handle, SB_VERT, ScrollInfo);

    if not rsb_visible then
    begin
      ShowScrollBar(Handle, SB_VERT, true);
      // GetScrollBarInfo(Handle, SB_VERT, vSBI);
      // sgf
      rsb_visible := true;
    end;

    ScrollInfo.nMin := 0;
    ScrollInfo.nMax := historyNowCount - 1;
    if SetPos then
    begin
      // not2go2end := True;
      if fAutoScrollState = ASS_FULLSCROLL then
        fAutoScrollState := ASS_ENABLENOTSCROLL;
      rsb_position := pos
    end
    else
      rsb_position := topVisible - historyNowOffset;
    if rsb_position > ScrollInfo.nMax then
      rsb_position := ScrollInfo.nMax
    else if rsb_position < ScrollInfo.nMin then
      rsb_position := ScrollInfo.nMin;

    ScrollInfo.nPos := rsb_position;
    ScrollInfo.nPage := 0;

    // ScrollInfo.nPage := Max(0, ClientHeight + 1);
    ScrollInfo.fMask := SIF_RANGE or SIF_POS or SIF_PAGE; // SIF_ALL;
    SetScrollInfo(Handle, SB_VERT, ScrollInfo, doRedraw);
  end;
}
end; // updateRSB

procedure ThistoryBox.addEvent(ev: Thevent);
var
  evIdx: Integer;
  params: TParams;
begin
  evIdx := history.add(ev);
  inc(offsetAll);
  if (BE_save in behaviour[ev.kind].trig) and (ev.flags and IF_not_save_hist = 0) then
    inc(offset);
  addChatItem(params, ev, True);
  sendChatItems(params);

  // if autoScroll and (not not2go2end or P_lastEventIsFullyVisible) then
  if (fAutoScrollState = ASS_FULLSCROLL) or ((fAutoScrollState = ASS_ENABLENOTSCROLL) and P_lastEventIsFullyVisible) then
  begin
    go2end;
    begin
      // not2go2end := False;
      setAutoScroll(ASS_FULLSCROLL);
      topOfs := 0;
    end;
  end;

end;

function ThistoryBox.getAutoScroll: boolean;
begin
  // result := fAutoScrollState < ASS_FULLDISABLED;
  // result := fAutoScrollState = ASS_FULLSCROLL;
  result := (fAutoScrollState = ASS_FULLSCROLL) or ((fAutoScrollState = ASS_ENABLENOTSCROLL) and P_lastEventIsFullyVisible);
end;

{ procedure ThistoryBox.setAutoScroll(vAS : Boolean);
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
  end; }

procedure ThistoryBox.setAutoScroll(asState: TAutoScrollState);
begin
  fAutoScrollState := asState;
end;

procedure ThistoryBox.setAutoScrollForce(vAS: boolean);
var
  changed: boolean;
begin
  { //  if fAutoscroll <> vAS then
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
    end; }
  if vAS then
    topOfs := 0;
  changed := false;
  case fAutoScrollState of
    ASS_FULLSCROLL:
      if not vAS then
      begin
        setAutoScroll(ASS_FULLDISABLED);
        changed := true;
      end;
    ASS_ENABLENOTSCROLL:
      if vAS then
      begin
        setAutoScroll(ASS_FULLSCROLL);
        changed := true;
      end
      else
      begin
        setAutoScroll(ASS_FULLDISABLED);
        changed := true;
      end;
    ASS_FULLDISABLED:
      if vAS then
      begin
        setAutoScroll(ASS_FULLSCROLL);
        changed := true;
      end;
  end;
  if changed then
    if fAutoScrollState < ASS_FULLDISABLED then
      go2end;
end;

function ThistoryBox.historyNowCount: integer;
begin
  if Assigned(history) then
    result := history.getIdxBeforeTime(topVisible, False)
  else
    result := 0;
end;

procedure ThistoryBox.DoOnScroll;
begin
  if Assigned(FOnScroll) then
    FOnScroll(Self);
end;

function ThistoryBox.getQuoteByIdx(var pQuoteIdx: integer): String;
var
  i: integer;
  he: Thevent;
begin
  result := '';
  with history do
  begin
    // search for a msg to quote
    if pQuoteIdx < 0 then
      i := Count - 1
    else
      i := pQuoteIdx - 1;
    he := nil;
    if i >= 0 then
    begin
      he := getAt(i);
      while (i >= 0) and (he.who.fProto.isMyAcc(he.who) or not(he.kind in [EK_msg, EK_url, EK_automsg])) do
      begin
        dec(i);
        if i >= 0 then
          he := getAt(i);
      end;
    end;
    if i < 0 then // nothing found, try restarting search from the end
    begin
      i := Count - 1;
      if i >= 0 then
      begin
        he := getAt(i);
        while (i >= 0) and (he.who.fProto.isMyAcc(he.who) or not(he.kind in [EK_msg, EK_url, EK_automsg])) do
        begin
          dec(i);
          if i >= 0 then
            he := getAt(i);
        end;
      end;
    end;
    if i < 0 then
      exit; // nothing found, really
    pQuoteIdx := i;
    //theme.applyFont('history.my', Self.canvas.font);
    // selected:=getAt(i).getBodyText();
    result := he.getBodyText();
  end;
end;

procedure ThistoryBox.requestQuote;
begin
  Call('getQuote', [])
end;

procedure ThistoryBox.updateMsgStatus(hev: Thevent);
var
  evPic: array of OleVariant;
  evPicRect: TGPRect;
  evPicSpriteName: TPicName;
  f: TFormatSettings;
begin
//  evPicRect := theme.GetPicRect(RQteDefault, hev.pic);
  SetLength(evPic, 6);
  theme.GetPicOrigin(hev.pic, evPicSpriteName, evPicRect);

  f.DecimalSeparator := '.';
  evPic[0] := FloatToStr(hev.when, f);
  evPic[1] := evPicSpriteName;
  evPic[2] := -evPicRect.X;
  evPic[3] := -evPicRect.Y;
  evPic[4] := evPicRect.Width;
  evPic[5] := evPicRect.Height;
  Call('updateMsgStatus', [evPic]);
end;

procedure ThistoryBox.histScrollEvent(d: integer);
begin
  Call('scrollEvent', [d]);
end;

procedure ThistoryBox.histScrollLine(d: integer);
begin
  Call('scrollLine', [d]);
end;

procedure ThistoryBox.histScrollWheel(d: integer);
begin
  Call('scrollWheel', [d]);
end;
{
procedure ThistoryBox.LoadEnd(Sender: TObject; const browser: ICefBrowser; const frame: ICefFrame; httpStatusCode: Integer);
begin
  if not (frame = nil) and frame.IsMain then
    templateLoaded := True;
end;
}
function ThistoryBox.escapeQuotes(const text: String): String;
begin
  Result := StringReplace(text, '\', '\\', [rfReplaceAll]);
  Result := StringReplace(Result, '"', '\"', [rfReplaceAll]);
end;
{
function ThistoryBox.escapeNewlines(const text: String): String;
begin
  Result := StringReplace(text, #13#10, '\n', [rfReplaceAll]);
  Result := StringReplace(Result, #13, '\n', [rfReplaceAll]);
  Result := StringReplace(Result, #10, '\n', [rfReplaceAll]);
end;
}
procedure ThistoryBox.LoadTemplate;
//var
// fn: String;
begin
//  fn := themesPath + 'template.htm';
//  if not FileExists(fn) then
//    msgDlg(getTranslation('Chat template not found at "%s"', [fn]), false, mtError)
//   else
    begin
      LoadHtml(templateFile, 'template');
      InitSettings;
      InitSmiles;
    end;
end;

class function ThistoryBox.PreLoadTemplate: Boolean;
var
 fn: String;
 t: RawByteString;
begin
  Result := templateFile > '';
  if Result then
    Exit;
  fn := themesPath + 'template.htm';
  if not FileExists(fn) then
    msgDlg(getTranslation('Chat template not found at "%s"', [fn]), false, mtError)
   else
    begin
      t := loadFileA(fn);
      templateFile := unutf(t);
      result := templateFile > '';
//      LoadURL(FilePathToURL(fn));
    end;
end;

procedure ThistoryBox.ClearEvents;
begin
  Call('clearEvents', []);
end;

procedure ThistoryBox.InitSettings;
var
  args: array of OleVariant;
  LimitMaxChatImgWidth,
  LimitMaxChatImgHeight : Boolean;
begin
  SetLength(args, 9);
  args[0] := autocopyHist;
  args[1] := useSmiles;
  args[2] := wheelVelocity;
  args[3] := //ChatImageQuality;
             MainPrefs.getPrefIntDef('chat-images-resample-preset', 0);

  LimitMaxChatImgWidth := MainPrefs.getPrefBoolDef('chat-images-limit-width', True);
  LimitMaxChatImgHeight := MainPrefs.getPrefBoolDef('chat-images-limit-height', True);

  if LimitMaxChatImgWidth then
    args[4] := MainPrefs.getPrefIntDef('chat-images-width-value', 512)
  else
    args[4] := 0;

  if LimitMaxChatImgHeight then
    args[5] := MainPrefs.getPrefIntDef('chat-images-height-value', 512)
  else
    args[5] := 0;

//  args[6] := EnableImgLinksIn;
//  args[7] := EnableImgLinksOut;
  args[6] := MainPrefs.getPrefBoolDef('chat-parse-image-links-in', True);
  args[7] := MainPrefs.getPrefBoolDef('chat-parse-image-links-out', True);
  args[8] := FontStyleCodes.Enabled;

  try
    Call('initSettings', args);
  except
    on e: ESciterCallException do
      msgDlg('Error in InitSettings: ' + e.Message, false, mtError);
  end;
end;

procedure ThistoryBox.InitSmiles;
var
  i, j: Integer;
  smileObj: TSmlObj;
  smiles, content: String;
  smileRect: TGPRect;
  pic : TPicName;
begin
  smiles := '{ ';
  if useSmiles then
    if theme.SmilesCount > 0 then
    begin
      for i := 0 to theme.SmilesCount - 1 do
      begin
        smileObj := theme.GetSmileObj(i);
        if smileObj.SmlStr.Count > 0 then
        begin
          theme.GetPicOrigin(smileObj.SmlStr[0], pic, smileRect);
          smiles := smiles + '"' + escapeQuotes(smileObj.SmlStr[0]) + '": [ "n' + IntToStr(i) + '", ' +
          IntToStr(smileRect.Width) + ', ' + IntToStr(smileRect.Height);
          if smileObj.SmlStr.Count > 1 then
          for j := 1 to smileObj.SmlStr.Count - 1 do
          smiles := smiles + ', "' + escapeQuotes(smileObj.SmlStr[j]) + '"';
          smiles := smiles +  ' ],';
        end;
      end;
      delete(smiles, length(smiles), 1);
    end;
  smiles := smiles +  ' }';
  try
    Call('initSmiles', [smiles]);
  except
    on e: ESciterCallException do
      msgDlg('Error in InitSmiles: ' + e.Message, false, mtError);
  end;
end;

procedure ThistoryBox.InitAll;
begin
      LoadTemplate;
      InitFunctions;
end;

procedure ThistoryBox.UpdateSmiles;
begin
  Call('updateSmiles', []);
end;

procedure ThistoryBox.RememberScrollPos;
begin
  Call('chatRememberScrollPos', []);
end;

procedure ThistoryBox.RestoreScrollPos;
begin
  Call('chatRestoreScrollPos', []);
end;

procedure ThistoryBox.ShowDebug;
begin
  SetOption(SCITER_SET_DEBUG_MODE, UINT_PTR(True));
end;


function LooksLikeALink(link: String): Boolean;
begin
  Result := StartsText('http://', link) or StartsText('https://', link) or StartsText('www.', link);
end;

procedure ThistoryBox.addChatItem(var params: TParams; hev: Thevent; animate: Boolean; last: Boolean = True);
var
  headerText, bodyImages, cachedLink, cachedLinks, evPic, cryptPic, statusImg1, statusImg2: array of OleVariant;
  codeStr, msgText: String;
  evPicRect,
  cryptPicRect,
  statusImg1Rect, statusImg2Rect: TGPRect;
  evPicSpriteName,
  cryptPicSpriteName,
  statusImg1PicName, statusImg2PicName: TPicName;
  statusImg1PicSpriteName, statusImg2PicSpriteName: TPicName;
  hdr: THEventHeader;
  st: Integer;
  b: Byte;
  sA: RawByteString;
  inv: Boolean;
  imgList: TAnsiStringList;
  linkList: TStringDynArray;
  bodyBin: RawByteString;
  i, pos: Integer;
  hash: LongWord;
  f: TFormatSettings;
begin
  if hev = nil then
    Exit;

  hdr := hev.getHeader;
  msgText := hev.getBodyText;
  theme.GetPicOrigin(hev.pic, evPicSpriteName, evPicRect);
  theme.GetPicOrigin(vKeyPicElm.picName, cryptPicSpriteName, cryptPicRect);


  SetLength(params, Length(params) + 1);
  pos := Length(params) - 1;
  params[pos] := VarArrayCreate([0, 11], varVariant);

  SetLength(headerText, 3);
  headerText[0] := hdr.what;
  headerText[1] := hdr.date;
  headerText[2] := hdr.prefix;

  params[pos][0] := hev.isMyEvent;
  params[pos][1] := headerText;
  params[pos][2] := msgText;

  bodyBin := hev.getBodyBin;
  params[pos][3] := False;
  if length(bodyBin) > 0 then
  begin
    imgList := TAnsiStringList.Create;
    parseMsgImages(bodyBin, imgList);
    if Assigned(embeddedImgs) and (imgList.Count > 0) then
    begin
      for i := 0 to imgList.Count - 1 do
      begin
        SetLength(bodyImages, Length(bodyImages) + 1);
        hash := CalcMurmur2(TBytes(imgList.Strings[i]));
        if not embeddedImgs.ContainsKey(hash) then
          embeddedImgs.Add(hash, imgList.Strings[i]);
        bodyImages[Length(bodyImages) - 1] := IntToStr(hash);
      end;
      params[pos][3] := bodyImages;
    end;
    imgList.Free;
  end;

  params[pos][4] := False;
  if length(msgText) > 0 then
  begin
    linkList := SplitString(msgText, ' ;,"'''#13#10);
    if Length(linkList) > 0 then
    begin
      for i := Low(linkList) to High(linkList) do
      if LooksLikeALink(linkList[i]) and imgCacheInfo.ValueExists(linkList[i], 'hash') then
      begin
        SetLength(cachedLinks, Length(cachedLinks) + 1);
        SetLength(cachedLink, 3);
        cachedLink[0] := linkList[i];
        cachedLink[1] := imgCacheInfo.ReadInteger(linkList[i], 'width', 50);
        cachedLink[2] := imgCacheInfo.ReadInteger(linkList[i], 'height', 50);
        cachedLinks[Length(cachedLinks) - 1] := cachedLink;
      end;
      if Length(cachedLinks) > 0 then
        params[pos][4] := cachedLinks;
    end;
  end;

  f.DecimalSeparator := '.';
  params[pos][5] := floattostr(hev.when, f);

  SetLength(evPic, 5);
  evPic[0] := evPicSpriteName;
  evPic[1] := -evPicRect.X;
  evPic[2] := -evPicRect.Y;
  evPic[3] := evPicRect.Width;
  evPic[4] := evPicRect.Height;
  params[pos][6] := evPic;

  if IF_Encrypt and hev.flags > 0 then
  begin
    SetLength(cryptPic, 5);
    cryptPic[0] := cryptPicSpriteName;
    cryptPic[1] := -cryptPicRect.X;
    cryptPic[2] := -cryptPicRect.Y;
    cryptPic[3] := cryptPicRect.Width;
    cryptPic[4] := cryptPicRect.Height;
    params[pos][7] := cryptPic;
  end else
    params[pos][7] := False;

  case hev.kind of
    EK_ONCOMING, EK_STATUSCHANGE:
    begin
      sA := hev.getBodyBin;
      if length(sA) >= 4 then
      begin
        st := str2int(sA);
        if st in [Byte(Low(Account.AccProto.statuses)) .. Byte(High(Account.AccProto.statuses))] then
        begin
          b := infoToXStatus(sA);
          if (st <> Byte(SC_ONLINE)) or (not XStatusAsMain) or (b = 0) then
          begin
            inv := (length(sA) > 4) and boolean(sA[5]);
            statusImg1PicName := status2imgName(st, inv);
          end;

          if (b > 0) then
            statusImg2PicName := XStatusArray[b].picName;
        end;
      end;
    end;
    EK_XstatusMsg:
    begin
      sA := hev.getBodyBin;
      if length(sA) >= 1 then
        if (Byte(sA[1]) <= High(XStatusArray)) then
          statusImg1PicName := XStatusArray[Byte(sA[1])].picName;
    end;
    EK_OFFGOING:
    begin
      statusImg1PicName := status2imgName(Byte(SC_OFFLINE), False);
    end;
  end;

  if not (statusImg1PicName = '') then
  begin
    theme.GetPicOrigin(statusImg1PicName, statusImg1PicSpriteName, statusImg1Rect);

    SetLength(statusImg1, 5);
    statusImg1[0] := statusImg1PicSpriteName;
    statusImg1[1] := -statusImg1Rect.X;
    statusImg1[2] := -statusImg1Rect.Y;
    statusImg1[3] := statusImg1Rect.Width;
    statusImg1[4] := statusImg1Rect.Height;
    params[pos][8] := statusImg1;
  end else
    params[pos][8] := False;

  if not (statusImg2PicName = '') then
  begin
    theme.GetPicOrigin(statusImg2PicName, statusImg2PicSpriteName, statusImg2Rect);
    SetLength(statusImg2, 5);
    statusImg2[0] := statusImg2PicSpriteName;
    statusImg2[1] := -statusImg2Rect.X;
    statusImg2[2] := -statusImg2Rect.Y;
    statusImg2[3] := statusImg2Rect.Width;
    statusImg2[4] := statusImg2Rect.Height;
    params[pos][9] := statusImg2;
  end else
    params[pos][9] := False;

  params[pos][10] := animate;
  params[pos][11] := last;
end;

procedure ThistoryBox.sendChatItems(params: TParams; prepend: Boolean = False; hidehist: Boolean = False);
begin
  Call('addEvents', [params, prepend, hidehist]);
end;

procedure ThistoryBox.ReloadLast;
var
  evId, endId, startId: Integer;
  evIcon: TIcon;
  iconStream: TMemoryStream;
  hev: Thevent;
  params: TParams;

//  Freq, StartCount, StopCount: Int64;
  TimingSeconds: real;
begin
//QueryPerformanceFrequency(Freq);
//Freq := Freq div 1000;
//QueryPerformanceCounter(StartCount);
  if history.Count = 0 then
    Exit;

  if not history.loaded then
    startId := history.Count - offset
  else
    startId := history.Count - offsetAll;

  for endId := history.Count - 1 downto startId do
  begin
    hev := history.getAt(endId);
    if (BE_save in behaviour[hev.kind].trig) and (hev.flags and IF_not_save_hist = 0) then
      Break;
  end;

  OutputDebugString(PChar('startId: ' + inttostr(startId)));
  OutputDebugString(PChar('endId: ' + inttostr(endId)));
  OutputDebugString(PChar('history.Count-1: ' + inttostr(history.Count - 1)));

  for evId := startId to history.Count - 1 do
  begin
    hev := history.getAt(evId);
    if (BE_save in behaviour[hev.kind].trig) and (hev.flags and IF_not_save_hist = 0) then
    begin
      addChatItem(params, hev, False, evId = endId);
      if length(params) = 1 then
        topVisible := hev.when;
    end;
  end;
  sendChatItems(params);

  if fAutoScrollState < ASS_FULLDISABLED then
    go2end;

  GC;
//QueryPerformanceCounter(StopCount);
//TimingSeconds := (StopCount - StartCount) / Freq;
//OutputDebugString(PChar(floattostr(TimingSeconds)));
end;

procedure ThistoryBox.DoShowMenu(const Data: String; clickedTime: TDateTime; linkClicked, imgClicked: Boolean);
begin
  if Assigned(fOnShowMenu) then
    fOnShowMenu(Self, Data, clickedTime, linkClicked, imgClicked);
end;

//function LoadHistory(vm: HVM): tiscript_value; cdecl;
function LoadHistory(vm: HVM; self: tiscript_value; tag: Pointer): tiscript_value; cdecl;
var
//  ch: TchatInfo;
  numOfDays, evId, startId, endId: Integer;
  hev: Thevent;
  topTime: Double;
  params: TParams;
  histObj: tiscript_value;
  hb: THistoryBox;
begin
  if tag = nil then
    Exit;
  hb := THistoryBox(tag);
  if hb = NIL then
    Exit;

  if (NI.get_arg_count(vm) = 4) then
  begin
    numOfDays := 1;
    topTime := 0;
    NI.get_int_value(NI.get_arg_n(vm, 2), numOfDays);
    NI.get_float_value(NI.get_arg_n(vm, 3), topTime);
  end;

  with hb do
  begin
    if not history.loaded then
    begin
      history.Clear;
      history.Load(who);
    end;

    if topTime = 0 then
      topTime := now;

    if numOfDays < 0 then
    begin
      startId := 0;
      endId := history.Count - 1;
    end
      else
    begin
      startId := history.getIdxBeforeTime(floor(topTime - numOfDays), False);
      endId := history.getIdxBeforeTime(topTime);
    end;

    if endId >= startId then
    for evId := startId to endId do
    begin
      hev := history.getAt(evId);
      if not (hev = nil) then
      if (BE_save in behaviour[hev.kind].trig) and (hev.flags and IF_not_save_hist = 0) then
      begin
        addChatItem(params, hev, False, evId = endId);
        if length(params) = 1 then
          topVisible := hev.when;
      end;
    end;

    if Length(params) > 0 then
      sendChatItems(params, True, startId <= 0);
  end;
end;

//function UpdateSelection(vm: HVM): tiscript_value; cdecl;
function UpdateSelection(vm: HVM; self: tiscript_value; tag: Pointer): tiscript_value; cdecl;
var
  text: PWideChar;
  strLen: UINT;
  sOfs, eOfs: Double;
  isWhole: Bool;
  hb: THistoryBox;
begin
  if tag = nil then
    Exit;
  hb := THistoryBox(tag);
  if hb = NIL then
    Exit;


  if (NI.get_arg_count(vm) = 6) then
  begin
    NI.get_string_value(NI.get_arg_n(vm, 2), text, strLen);
    hb.selectedText := text;

    NI.get_float_value(NI.get_arg_n(vm, 3), sOfs);
    NI.get_float_value(NI.get_arg_n(vm, 4), eOfs);
    NI.get_bool_value(NI.get_arg_n(vm, 5), isWhole);

    with hb do
    if (sOfs = -1) or (eOfs = -1) then
    begin
      startSel.ofs := -1;
      startSel.ev := nil;
      endSel.ofs := -1;
      endSel.ev := nil;
      isWholeEvents := false;
    end
      else
    begin
      startSel.ofs := -1;
      startSel.ev := history.getByTime(sOfs);
      endSel.ofs := -1;
      endSel.ev := history.getByTime(eOfs);
      isWholeEvents := isWhole;
    end;
  end;
end;

//function SendQuote(vm: HVM): tiscript_value; cdecl;
function SendQuote(vm: HVM; self: tiscript_value; tag: Pointer): tiscript_value; cdecl;
var
  text: PWideChar;
  strLen: UINT;
  hb: THistoryBox;
begin
  if tag = nil then
    Exit;
  hb := THistoryBox(tag);
  if hb = NIL then
    Exit;

  if (NI.get_arg_count(vm) > 2) then
  begin
    NI.get_string_value(NI.get_arg_n(vm, 2), text, strLen);
//    chatFrm.quoteCallback(text, true);
  end;
end;

//function OpenChatMenu(vm: HVM): tiscript_value; cdecl;
function OpenChatMenu(vm: HVM; self: tiscript_value; tag: Pointer): tiscript_value; cdecl;
var
  clickedTime, data: PWideChar;
  strLen: UINT;
  linkClicked, imgClicked: LongBool;
  hb: THistoryBox;
  f: TFormatSettings;
begin
  if tag = nil then
    Exit;
  hb := THistoryBox(tag);
  if hb = NIL then
    Exit;

  if (NI.get_arg_count(vm) > 2) then
  begin
    data := '';
    linkClicked := False;
    imgClicked := False;
    NI.get_string_value(NI.get_arg_n(vm, 2), data, strLen);
    NI.get_string_value(NI.get_arg_n(vm, 3), clickedTime, strLen);
    NI.get_bool_value(NI.get_arg_n(vm, 4), linkClicked);
    NI.get_bool_value(NI.get_arg_n(vm, 5), imgClicked);
    f.DecimalSeparator := '.';
    hb.DoShowMenu(data, StrToFloat(clickedTime, f), linkClicked, imgClicked);
//    chatFrm.showHistMenu(data, StrToFloat(clickedTime), linkClicked, imgClicked);
  end;
end;

//function ShowPreview(vm: HVM): tiscript_value; cdecl;
function ShowPreview(vm: HVM; self: tiscript_value; tag: Pointer): tiscript_value; cdecl;
var
  strdata: PWideChar;
  eventImages: TStringList;
  imgLinks, arrItem: tiscript_value;
  selImg, arrSize, i: Integer;
  itemLen: UINT;
  bytedata: PByte;
  rbs: RawByteString;
  hb: THistoryBox;
begin
  if tag = nil then
    Exit;
  hb := THistoryBox(tag);
  if hb = NIL then
    Exit;

  if (NI.get_arg_count(vm) = 4) then
  begin
    strdata := '';
    selImg := 0;
    imgLinks := NI.get_arg_n(vm, 2);
    arrSize := NI.get_array_size(vm, imgLinks);
{ ToDo
    eventImages := TStringList.Create;
    eventImages.Sorted := False;
    for i := 0 to arrSize - 1 do
      if NI.get_string_value(NI.get_elem(vm, imgLinks, i), strdata, itemLen) then
        eventImages.Add(strdata);
    NI.get_int_value(NI.get_arg_n(vm, 3), selImg);

//    if eventImages.Count > 0 then
//      viewImageDimmed(eventImages, selImg);
}
  end;
end;

procedure ThistoryBox.InitFunctions;
begin
  RegisterNativeFunctionTag('LoadHistory', @LoadHistory, Pointer(Self));
  RegisterNativeFunctionTag('UpdateSelection', @UpdateSelection, Pointer(Self));
  RegisterNativeFunctionTag('SendQuote', @SendQuote, Pointer(Self));
  RegisterNativeFunctionTag('OpenChatMenu', @OpenChatMenu, Pointer(Self));
  RegisterNativeFunctionTag('ShowPreview', @ShowPreview, Pointer(Self));
end;


constructor ThistoryBox.Create(AOwner: Tcomponent; cnt: TRnQContact);
begin
  inherited Create(AOwner);
  SetParentComponent(AOwner);
  if aowner is TWinControl then
    Parent := TWinControl(AOwner);
  Who := cnt;

  tabStop := False;
  fAutoScrollState := ASS_FULLSCROLL;
  Color := $00F6F6F6;
  topVisible := 0;
  offset := 0;
  offsetAll := 0;

  embeddedImgs := TDictionary<LongWord, RawByteString>.Create;

  OnLoadData := InitRequest;
//  OnFocus := ReturnFocus;

//   history:=pTCE(c.data).history as Thistory;
   history := Thistory.create;
   history.Reset;

//   SetOption(SCITER_SET_DEBUG_MODE, UINT_PTR(True));
   SetOption(SCITER_SMOOTH_SCROLL, UINT_PTR(True));

end;

procedure ThistoryBox.ReturnFocus(Sender: TObject);
//var
//  ch: TchatInfo;
begin
//  ch := chatFrm.thisChat;
//  if ch = nil then
//    Exit;

//  PostMessage(chatFrm.handle, WM_NEXTDLGCTL, ch.input.handle, 1);
//  PostMessage(ParentWindow, WM_NEXTDLGCTL, ch.input.handle, 1);

end;

procedure ThistoryBox.InitRequest(ASender: TObject; const url: WideString; resType: SciterResourceType; requestId: Integer; out discard: Boolean);
var
  handler: TRequestHandler;
begin
  handler := TRequestHandler.Create(Self);
  handler.ProcessRequest(ASender, url, resType, requestId, discard);
end;

{ TExtension }
(*
function TExtension.Execute(const name: ustring; const obj: ICefv8Value;
                            const arguments: TCefv8ValueArray; var retval: ICefv8Value;
                            var exception: ustring): Boolean;
var
  ch: TchatInfo;
begin
  if Assigned(chatFrm) then
  if (name = 'sendQuote') then
  begin

  end else if (name = 'updateSelection') then
  begin

  end else if (name = 'updateAutoscroll') then
  begin
    //autoScrollVal
    ch := chatFrm.thisChat;
    if not (ch = nil) then
    if (Length(arguments) > 0) and arguments[0].IsBool then
    begin
      ch.historyBox.autoScrollVal := arguments[0].getBoolValue;
      ch.historyBox.Scroll;
    end;
  end else
    Result := false;
end;

{ TCustomRenderProcessHandler }

const
  extCode =
  'var cef;' +
  'if (!cef)' +
  '  cef = {};' +
  '(function() {' +
  '  cef.sendQuote = function(res) {' +
  '    native function sendQuote();' +
  '    sendQuote(res);' +
  '  };' +
  '  cef.updateSelection = function(text, start, end, isWholeEvents) {' +
  '    native function updateSelection();' +
  '    updateSelection(text, start, end, isWholeEvents);' +
  '  };' +
  '  cef.updateRightClickedItem = function(idx, text) {' +
  '    native function updateRightClickedItem();' +
  '    updateRightClickedItem(idx, text);' +
  '  };' +
  '  cef.updateAutoscroll = function(bottom) {' +
  '    native function updateAutoscroll();' +
  '    updateAutoscroll(bottom);' +
  '  };' +
  '})();';
*)
{ TRequestHandler }

constructor TRequestHandler.Create(Sciter: TSciter);
begin
  inherited Create;
  FSciter := Sciter;
  FDataStream := nil;
end;

destructor TRequestHandler.Destroy;
begin
  if Assigned(FDataStream) then
    FreeAndNil(FDataStream);
  inherited;
end;

procedure TRequestHandler.CheckAnimatedGifSize;
var
//  aGif: TGIFImage;
  sz: Single;
  FStreamFormat: TPAFormat;
begin
  FStreamFormat := DetectFileFormatStream(FDataStream);
  if (FStreamFormat = PA_FORMAT_GIF) then
  begin
{
    aGif := TGIFImage.Create;
    FDataStream.Seek(0, soFromBeginning);
    aGif.LoadFromStream(FDataStream);

    with aGif do
    if Images.Count > 1 then
    begin
      sz := 4.85 * Images.Count * Width * Height / 1048576;
      if sz > 50 then
      try
        FDataStream.Clear;
        aGif.Images[0].Bitmap.SaveToStream(FDataStream);
        FDataStream.Seek(0, soFromBeginning);
      except end;
    end;
    aGif.Free;
}
  end;
end;

procedure TRequestHandler.ProcessRequest(ASender: TObject; const url: WideString; resType: SciterResourceType; requestId: Integer; out discard: Boolean);
var
  i: Integer;
  hash: LongWord;
  PIn, POut: Pointer;
  OutSize: Cardinal;
  img: RawByteString;
  realurl, fn: String;
  response: TStringStream;
  pic: TPicName;
  origPic: TMemoryStream;
  rs: TResourceStream;
  fs: TFileStream;
  cached, isimg, check, ignore: Boolean;
begin
  ignore := False;
  FDataStream := TMemoryStream.Create;

  if StartsText('themepic:', url) then
  begin
    pic := copy(url, 10, length(url));
    origPic := nil;
    if theme.GetBigPic(pic, origPic) then
    begin
      FDataStream.LoadFromStream(origPic);
      origPic.Free;
    end
  end else if StartsText('smile:', url) then
  begin
    pic := copy(url, 7, length(url));
    pic := copy(pic, 2, length(pic));
    origPic := nil;

    if theme.GetBigSmile(pic, origPic) then
    begin
      FDataStream.LoadFromStream(origPic);
      origPic.Free;
    end
  end else if StartsText('resource:', url) then
  begin
    ignore := True;
//    realurl := copy(url, 10, length(url));
//    rs := TResourceStream.Create(HInstance, uppercase(realurl), RT_RCDATA);
//    try
//      rs.SaveToStream(FDataStream);
//    finally
//      rs.Free;
//    end;
  end else if StartsText('uin:', url) then
  begin
//    if Assigned(chatFrm) then
//      chatFrm.showHistMenu(url, 0, true, false);
    ignore := True;
  end else if StartsText('link:', url) then
  begin
    realurl := copy(url, 6, length(url));
    if StartsText('www.', realurl) then
      realurl := 'http://' + realurl;
    openURL(realurl);
    ignore := True;
  end else if StartsText('mailto:', url) then
  begin
    openURL(url);
    ignore := True;
  end else if StartsText('embedded:', url) then
  begin
    ignore := True;
    //if url = 'embedded:1284491416' then
    //begin
    //  ignore := True;
    //  Exit;
    //end;
{ ToDo
    if TryStrToLongWord(copy(url, 10, length(url)), hash) and Assigned(embeddedImgs) and embeddedImgs.TryGetValue(hash, img) then
    begin
      PIn := @img[1];
      OutSize := CalcDecodedSize(PIn, Length(img));
      origPic := TMemoryStream.Create;
      origPic.SetSize(OutSize);
      origPic.position := 0;
      POut := origPic.Memory;
      Base64Decode(PIn^, Length(img), POut^);
      FDataStream.LoadFromStream(origPic);
      origPic.Free;
      CheckAnimatedGifSize;
    end;
}
  end else if StartsText('check:', url) or StartsText('download:', url) then
  begin
    if StartsText('check:', url) then
    begin
      check := True;
      realurl := copy(url, 7, length(url))
    end
      else
    begin
      check := False;
      realurl := copy(url, 10, length(url));
    end;

    if LooksLikeALink(realurl) then
    begin
      fn := myPath + 'Cache\Images\' + imgCacheInfo.ReadString(realurl, 'hash', '0') + '.' + imgCacheInfo.ReadString(realurl, 'ext', 'jpg');
      cached := FileExists(fn);
      isimg := False;

      if check then
      begin
        if cached then
          isimg := True
        else if imgCacheInfo.ValueExists(realurl, 'mime') and not MatchText(imgCacheInfo.ReadString(realurl, 'mime', ''), ImageContentTypes) then
          isimg := False
        else if CheckType(realurl) then
          isimg := True
        else
          isimg := False;

        if isimg then
          i := 1
        else
          i := 0;

        response := TStringStream.Create('{ isImg: ' + IntToStr(i) + ', link: "' + realurl + '" }', TEncoding.UTF8);
        FDataStream.WriteBuffer(response.Memory, response.Size);
        response.Free;
      end
        else
      begin
        if not cached then
          cached := DownloadAndCache(realurl);

        if not cached then
          ignore := True
        else
        try
          fn := myPath + 'Cache\Images\' + imgCacheInfo.ReadString(realurl, 'hash', '0') + '.' + imgCacheInfo.ReadString(realurl, 'ext', 'jpg');
          fs := TFileStream.Create(fn, fmOpenRead);
          FDataStream.LoadFromStream(fs);
          CheckAnimatedGifSize;
        except
          ignore := True;
        end;

        if Assigned(fs) then
          fs.Free;
      end;
    end else
      ignore := True;
  end else
  begin
    FDataStream.Free;
    discard := False;
    Exit;
  end;

  if not ignore then
  begin
    FDataStream.Seek(0, soFromBeginning);
    FSciter.DataReady(url, FDataStream.Memory, FDataStream.Size);
    discard := False;
  end else
    discard := True;

  if Assigned(FDataStream) then
    FDataStream.Free;
end;

initialization


vKeyPicElm.ThemeToken := -1;
vKeyPicElm.picName := PIC_KEY;
vKeyPicElm.Element := RQteDefault;
vKeyPicElm.pEnabled := true;

end.
