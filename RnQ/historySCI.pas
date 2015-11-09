{
  This file is part of R&Q.
  Under same license
}
unit historySCI;
{$I RnQConfig.inc}

interface

uses
{$IFDEF USE_GDIPLUS}
  GDIPAPI, GDIPOBJ,
{$ENDIF USE_GDIPLUS}
  Windows, Controls, Classes, Generics.Collections,
  SysUtils, Graphics, Forms, StdCtrls, ExtCtrls,
  Messages, StrUtils, System.UITypes, NetEncoding,
  RDGlobal, history, RnQProtocol, events,
  Sciter, SciterApi;

{$I NoRTTI.inc}

type
  TlinkKind = (LK_FTP, LK_EMAIL, LK_WWW, LK_UIN, LK_ED);
  TDrawStyle = (dsNone, dsBuffer, dsMemory, dsGlobalBuffer32);
  TAutoScrollState = (ASS_FULLSCROLL, // fAutoscroll = True, not2go2end = false
    ASS_ENABLENOTSCROLL, // fAutoscroll = True, not2go2end = True
    ASS_FULLDISABLED); // fAutoscroll = False, not2go2end = Any

  TitemKind = (PK_NONE, PK_HEAD, PK_TEXT, PK_ARROWS_UP, PK_ARROWS_DN, PK_LINK, PK_SMILE, PK_CRYPTED, PK_RQPIC, PK_RQPICEX, PK_RNQBUTTON, PK_EVENT);
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

  TChatItem = record
    kind: TitemKind;
    stringData: String;
    intData: Integer;
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
    evIdx: integer; // -1 for void positions
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
  THistoryBox = class(TSciter)
  private
    //template: TStringList;
    // For History at all
    items: array of ThistoryItem;
    P_lastEventIsFullyVisible: boolean;
    startWithLastLine: boolean;
    P_topEventNrows, P_bottomEvent: integer;
    fAutoScrollState: TAutoScrollState; // auto scrolls along messages
    FOnScroll: TNotifyEvent;

    // For Active History!
    lastTimeClick: TdateTime;
    justTriggeredAlink, dontTriggerLink, just2clicked: boolean;
    lastClickedItem, P_pointedSpace, P_pointedItem: ThistoryItem;
    linkToUnderline: ThistoryLink;
    FOnLinkClick: TLinkClickEvent;
    buffer: TBitmap;

    firstCharactersForSmiles: set of AnsiChar; // for faster smile recognition
  protected
    function getAutoScroll: boolean;
    procedure setAutoScroll(asState: TAutoScrollState);
    procedure setAutoScrollForce(vAS: boolean);
  public
    topVisible, topOfs: integer;
    offsetMsg, offsetAll: integer; // can't show hevents before this
    startSel, endSel: ThistoryPos;
    isWholeEvents: Boolean;
    who: TRnQContact;
    history: Thistory;
    margin: Trect;
    whole: boolean; // see whole history
    rsb_visible: boolean;
    rsb_position: integer;
    rsb_rowPerPos: integer;
    onPainted: TNotifyEvent;
    w2s: String;
    rightClickedChatItem: TChatItem;
    //templateLoaded: Boolean;

    property lastEventIsFullyVisible: boolean read P_lastEventIsFullyVisible;
    property pointedItem: ThistoryItem read P_pointedItem;
    property clickedItem: ThistoryItem read lastClickedItem;
    property pointedSpace: ThistoryItem read P_pointedSpace;
    property topEventNrows: integer read P_topEventNrows;
    property bottomEvent: integer read P_bottomEvent;
    property autoScrollVal: boolean read getAutoScroll write setAutoScrollForce;
    property OnScroll: TNotifyEvent read FOnScroll write FOnScroll;
    property onLinkClick: TLinkClickEvent read FOnLinkClick write FOnLinkClick;

    function escapeQuotes(const text: String): String;
    function escapeNewlines(const text: String): String;

    procedure LoadTemplate;
    procedure ClearTemplate;
    procedure RefreshTemplate;
    procedure ReloadLast;
    procedure InitSmiles;
    procedure RememberScrollPos;
    procedure RestoreScrollPos;
    procedure addChatItem(hev: Thevent; evIdx: Integer; animate: Boolean; last: Boolean = True);

    constructor Create(AOwner: Tcomponent); override;
    destructor Destroy; override;
    procedure go2end();
    function copySel2Clpb: Boolean;
    function getSelBin(): RawByteString;
    function getSelHtml(smiles: boolean): string;
    function getSelHtml2(smiles: boolean): RawByteString;
    function somethingIsSelected(): boolean;
    function wholeEventsAreSelected(): boolean;
    function nothingIsSelected(): boolean;
    function partialTextIsSelected(): boolean;

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
    procedure updateMsgStatus(hev: Thevent);

    procedure MouseWheelHandler(var Message: TMessage); override;
    procedure WMVScroll(var Message: TWMVScroll); message WM_VSCROLL;
    property  Color;
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

  TResourceHandler = class(TCefResourceHandlerOwn)
  private
    FDataStream: TMemoryStream;
    FStatus: Integer;
    FStatusText: string;
    FMimeType: string;
    FRedirectURL: string;
  protected
    function DetectStreamMimeType: String;
    function ProcessRequest(const request: ICefRequest; const callback: ICefCallback): Boolean; override;
    procedure GetResponseHeaders(const response: ICefResponse; out responseLength: Int64; out redirectUrl: ustring); override;
    function ReadResponse(const dataOut: Pointer; bytesToRead: Integer; var bytesRead: Integer; const callback: ICefCallback): Boolean; override;
    procedure SetStatus(status: Integer);
  public
    constructor Create(const browser: ICefBrowser; const frame: ICefFrame;
      const schemeName: ustring; const request: ICefRequest); override;
    destructor Destroy; override;
  end;
}
const
  dStyle = dsGlobalBuffer32;

  // dStyle = dsGlobalBuffer;
  // dStyle = dsMemory; // Bad BG and not so fast :(
  // dStyle = dsNone;
var
  // dsNone, dsBuffer, dsGlobalBuffer, dsMemory
  // dStyle: TDrawStyle = dsGlobalBuffer;
  // dStyle: TDrawStyle = dsNone;
  hisBGColor, myBGColor: TColor;
  renderInit: Boolean = False;

implementation

uses
  clipbrd, Types, math,
{$IFDEF UNICODE}
  Character,
  AnsiStrings,
{$ENDIF UNICODE}
  RnQSysUtils, RnQLangs, RnQFileUtil, RDUtils, RnQBinUtils,
  RQUtil, RQThemes, RnQButtons, RnQGlobal, RnQCrypt, RnQPics, RnQNet,
  globalLib, mainDlg, chatDlg, utilLib, Protocols_all,
  roasterLib,
{$IFDEF USE_GDIPLUS}
  // KOLGDIPV2,
{$ENDIF USE_GDIPLUS}
  // historyRnQ,
  Base64,
  ICQConsts, ICQv9,
{$IFDEF USE_GDIPLUS}
  RnQGraphics,
{$ELSE}
  RnQGraphics32,
{$ENDIF USE_GDIPLUS}
  themesLib, menusUnit;

var
  lastBGCnt: TRnQContact;
  lastBGToken: integer;
  vKeyPicElm: TRnQThemedElementDtls;
  globalBuffer32: TBitmap32;

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
    result.evIdx := -1;
  end
  else
  begin
    result.ev := a.ev;
    result.evIdx := a.evIdx;
    result.ofs := a.ofs;
  end
end;

destructor ThistoryBox.Destroy;
begin
  if dStyle = dsBuffer then
    if buffer <> nil then
      buffer.Free;
  if Assigned(Self) then
    inherited Destroy;
  // self := NIL;
end;

function ThistoryBox.getSelBin(): RawByteString;
begin
  result := '';
end;

function ThistoryBox.copySel2Clpb: Boolean;
begin
  Perform(EM_GETSEL, 0, 0);
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
procedure ThistoryBox.go2end();
begin
  Call('chatScrollToBottom', []);
end;

function ThistoryBox.offsetPos(): integer;
begin
  result := topVisible - offsetMsg
end;

function ThistoryBox.wholeEventsAreSelected(): boolean;
begin
  result := (startSel.ev <> nil) and isWholeEvents
end;

function ThistoryBox.nothingIsSelected(): boolean;
begin
  result := startSel.ev = nil;
end;

function ThistoryBox.somethingIsSelected(): boolean;
begin
  result := startSel.ev <> nil;
end;

function ThistoryBox.partialTextIsSelected(): boolean;
begin
  result := (startSel.ev <> nil) and not isWholeEvents
end;

procedure ThistoryBox.select(from, to_: integer);
begin
  startSel.ofs := -1;
  startSel.evIdx := from;
  startSel.ev := history.getAt(from);
  endSel.ofs := -1;
  endSel.evIdx := to_;
  endSel.ev := history.getAt(to_);
  isWholeEvents := True;
  Call('setSelection', [inttostr(from), inttostr(to_)]);
end; // select

procedure ThistoryBox.deselect();
begin
  startSel.ev := nil;
  startSel.evIdx := -1;
  isWholeEvents := False;
  Call('clearSelection', []);
end; // deselect
(*
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
  if equal(oldIt, P_pointedItem) and equal(oldSp, P_pointedSpace) then
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
  // P_pointedItem.link

  // repaint necessary?
  if not equal(linkToUnderline, oldLink) then
  begin
    // avoidErase:=TRUE;
    Paint();
    // avoidErase:=FALSE;
  end;
  // here the selecting management section begins
  if not selecting then
    exit;
  // selecting, no link has to be triggered
  dontTriggerLink := true;
  // updating the selection end point
  if pointedSpace.kind = PK_NONE then
    exit;
  p := historyitem2pos(pointedSpace);
  if minor(startSel, p) then
    inc(p.ofs, pointedSpace.l - 1);
  if equal(endSel, p) then
    exit; // no change?
  endSel := p;
  pEnd := p;
  pEnd.ofs := p.ofs + pointedSpace.l - 1;
  if (pointedSpace.kind = PK_SMILE) and minor(endSel, startSel) and (minor(p, startSel) and minor(startSel, pEnd)) then
    inc(startSel.ofs, pointedSpace.l - 1);

  // some adjustment could be needed
  if nothingIsSelected() then
    startSel := historyitem2pos(pointedItem)
  else if startSel.ofs < 0 then
    endSel.ofs := -1
  else if endSel.ofs < 0 then
    endSel.ofs := 0;
  Paint();
end; // updatePointedItem

function ThistoryBox.triggerLink(item: ThistoryItem): boolean;
var
  s: string;
begin
  result := false;
  if item.kind <> PK_LINK then
    exit;
  s := item.link.str;
  case item.link.kind of
    LK_WWW:
      begin
        if not(Imatches(s, 1, 'http://') or Imatches(s, 1, 'https://')) then
          s := 'http://' + s;
        // if Assigned(onLinkClick) then
        // onLinkClick(self, s, item.link.str);
        openURL(s);
      end;
    LK_FTP:
      begin
        if not(Imatches(s, 1, 'ftp://') or Imatches(s, 1, 'sftp://')) then
          s := 'ftp://' + s;
        openURL(s);
      end;
    LK_EMAIL:
      begin
        if not Imatches(s, 1, 'mailto:') then
          s := 'mailto:' + s;
        exec(s);
      end;
  end;
end; // triggerLink

procedure ThistoryBox.DoBackground(cnv0: Tcanvas; vR: Trect; var SmlBG: TBitmap32);
// procedure ThistoryBox.DoBackground(dc: HDC);
var
{$IFDEF USE_GDIPLUS}
  fnt: TGPFont;
  fmt: TGPStringFormat;
  br: TGPBrush;
  gr: TGPGraphics;
  r: TGPRectF;
{$ELSE USE_GDIPLUS}
  // fnt : TFont;
  r: Trect;
  hnd: THandle;
  // br : hbrush;
{$ENDIF USE_GDIPLUS}
  hasBG0, hasUTP: boolean;
  uidBG, grpBG: TPicName;
  picElm: TRnQThemedElementDtls;
  pt: Tpoint;
  isUseCntThemes: boolean;
begin
  isUseCntThemes := UseContactThemes and Assigned(ContactsTheme) and Assigned(who);

  if isUseCntThemes then
  begin
    uidBG := TPicName(LowerCase(who.UID2cmp)) + '.' + PIC_CHAT_BG;
    grpBG := TPicName('group.') + TPicName(AnsiLowerCase(groups.id2name(who.group))) + '.' + PIC_CHAT_BG
  end
  else
  begin
    uidBG := '';
    grpBG := '';
  end;
{$IFDEF USE_GDIPLUS}
  gr := TGPGraphics.Create(cnv.Handle);
  gr.GetClipBounds(r);
  if r.X < vR.left then
    r.X := vR.left;
  if r.Y < vR.Top then
    r.Y := vR.Top;
  if r.Width > vR.Right - vR.left then
    r.Width := vR.Right - vR.left;
  if r.Height > vR.Bottom - vR.Top then
    r.Height := vR.Bottom - vR.Top;
  gr.Clear(theme.GetAColor(ClrHistBG, clWindow));
{$ELSE USE_GDIPLUS}
  r := cnv0.ClipRect;

  if not Assigned(SmlBG) then
  begin
    SmlBG := TBitmap32.Create;
    SmlBG.SetSize(clientWidth, clientHeight);
  end
  else
  begin
    SmlBG.Height := 0;
    SmlBG.SetSize(clientWidth, clientHeight);
  end;
  // br := CreateSolidBrush(ColorToRGB(theme.GetColor(ClrHistBG, clWindow)));
  SmlBG.canvas.brush.color := theme.GetColor(ClrHistBG, clWindow);
  SmlBG.canvas.fillRect(SmlBG.canvas.ClipRect);
  // Br := TGPSolidBrush.Create(theme.GetAColor(ClrHistBG, clWindow));
  // gr.FillRectangle(br, r);
  // br.Free;
{$ENDIF USE_GDIPLUS}
  { r.X := ClientRect.Left;
    r.Y := ClientRect.Top;
    r.Width := ClientWidth;
    r.Height := ClientHeight; }
  if isUseCntThemes and (ContactsTheme.GetPicSize(RQteDefault, uidBG + '5').cx > 0) then
  begin
    hasBG0 := true;
    ContactsTheme.drawTiled(SmlBG.canvas, uidBG + '5');
  end
  else if isUseCntThemes and (ContactsTheme.GetPicSize(RQteDefault, grpBG + '5').cx > 0) then
  begin
    hasBG0 := true;
    ContactsTheme.drawTiled(SmlBG.canvas, grpBG + '5');
  end
  else if theme.GetPicSize(RQteDefault, PIC_CHAT_BG + '5').cx > 0 then
  begin
    // theme.drawTiled(gr, r, PIC_CHAT_BG+'5');
    theme.drawTiled(SmlBG.canvas, PIC_CHAT_BG + '5');
    hasBG0 := true;
    // theme.Anipicbg := True;
  end
  else
  begin
    hasBG0 := false;
  end;

  hnd := SmlBG.canvas.Handle;

  picElm.Element := RQteDefault;
  picElm.pEnabled := true;

  { if birth then
    with theme.GetPicSize('birthday') do
    if cx > 0 then
    theme.drawPic(cnv, 0, 0, 'birthday'); }

  pt.X := 0;
  pt.Y := 0;
  picElm.ThemeToken := -1;
  picElm.picName := uidBG + '1';
  if isUseCntThemes and (ContactsTheme.GetPicSize(picElm).cx > 0) then
    ContactsTheme.drawPic(hnd, pt, picElm)
  else
  begin
    picElm.ThemeToken := -1;
    picElm.picName := grpBG + '1';
    if isUseCntThemes and (ContactsTheme.GetPicSize(picElm).cx > 0) then
      ContactsTheme.drawPic(hnd, pt, picElm)
    else
      // with theme.GetPicSize(RQteDefault, PIC_CHAT_BG+'1') do
      // if cx > 0 then
      theme.drawPic(hnd, 0, 0, PIC_CHAT_BG + '1');
  end;

  // Right-Top
  pt.Y := 0;
  pt.X := clientWidth;

  hasUTP := false;
  picElm.ThemeToken := -1;
  picElm.picName := uidBG + '2';
  if isUseCntThemes then
  begin
    with ContactsTheme.GetPicSize(picElm) do
      if cx > 0 then
      begin
        hasUTP := true;
        dec(pt.X, cx);
        ContactsTheme.drawPic(hnd, pt, picElm)
      end;
    if not hasUTP then
    begin
      picElm.ThemeToken := -1;
      picElm.picName := grpBG + '2';
      with ContactsTheme.GetPicSize(picElm) do
        if cx > 0 then
        begin
          hasUTP := true;
          dec(pt.X, cx);
          ContactsTheme.drawPic(hnd, pt, picElm)
        end;
    end;
  end;
  if not hasUTP then
  begin
    picElm.ThemeToken := -1;
    picElm.picName := PIC_CHAT_BG + '2';
    with theme.GetPicSize(picElm) do
      if cx > 0 then
      begin
        dec(pt.X, cx);
        theme.drawPic(hnd, pt, picElm);
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
  pt.Y := Height;
  pt.X := 0;

  hasUTP := false;
  picElm.ThemeToken := -1;
  if isUseCntThemes then
  begin
    picElm.picName := uidBG + '3';
    with ContactsTheme.GetPicSize(picElm) do
      if cx > 0 then
      begin
        hasUTP := true;
        dec(pt.Y, cy);
        ContactsTheme.drawPic(hnd, pt, picElm)
      end;
    if not hasUTP then
    begin
      picElm.ThemeToken := -1;
      picElm.picName := grpBG + '3';
      with ContactsTheme.GetPicSize(picElm) do
        if cx > 0 then
        begin
          hasUTP := true;
          dec(pt.Y, cy);
          ContactsTheme.drawPic(hnd, pt, picElm)
        end;
    end;
  end;
  if not hasUTP then
  begin
    picElm.ThemeToken := -1;
    picElm.picName := PIC_CHAT_BG + '3';
    with theme.GetPicSize(picElm) do
      if cx > 0 then
      begin
        dec(pt.Y, cy);
        theme.drawPic(hnd, pt, picElm);
      end;
  end;

  // Right-Bottom
  pt.Y := Height;
  pt.X := clientWidth;

  hasUTP := false;
  picElm.ThemeToken := -1;
  if isUseCntThemes then
  begin
    picElm.picName := uidBG + '4';
    with ContactsTheme.GetPicSize(picElm) do
      if cx > 0 then
      begin
        hasUTP := true;
        dec(pt.X, cx);
        dec(pt.Y, cy);
        ContactsTheme.drawPic(hnd, pt, picElm)
      end;
    if not hasUTP then
    begin
      picElm.ThemeToken := -1;
      picElm.picName := grpBG + '4';
      with ContactsTheme.GetPicSize(picElm) do
        if cx > 0 then
        begin
          hasUTP := true;
          dec(pt.X, cx);
          dec(pt.Y, cy);
          ContactsTheme.drawPic(hnd, pt, picElm)
        end;
    end;
  end;
  if not hasUTP then
  begin
    picElm.ThemeToken := -1;
    picElm.picName := PIC_CHAT_BG + '4';
    with theme.GetPicSize(picElm) do
      if cx > 0 then
      begin
        dec(pt.X, cx);
        dec(pt.Y, cy);
        theme.drawPic(hnd, pt, picElm);
      end;
  end;

  // BitBlt(cnv0.Handle, vR.Left, vR.Top, vR.Right - vR.Left, vR.Top - vR.Bottom,
  // hnd, vR.Left, vR.Top, SRCCOPY);
  // SmlBG.Canvas.Handle, vR.Left, vR.Top, SRCCOPY);
  BitBlt(cnv0.Handle, 0, 0, SmlBG.Width, SmlBG.Height,
    // hnd, vR.Left, vR.Top, SRCCOPY);
    hnd, 0, 0, SRCCOPY);

  if not hasBG0 then
  begin
    if Assigned(SmlBG) then
      SmlBG.Free;
    SmlBG := NIL;
  end;
  // if rqSmiles.useAnimated then

end;
*)
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
  end; }

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
begin
  evIdx := history.add(ev);
  inc(offsetAll);
  if (BE_save in behaviour[ev.kind].trig) and (ev.flags and IF_not_save_hist = 0) then
    inc(offsetMsg);
  addChatItem(ev, evIdx, True);

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
  if fAutoScrollState < ASS_FULLDISABLED then
    Call('setAutoScrollState', ['true'])
  else
    Call('setAutoScrollState', ['false']);
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
    result := history.Count - historyNowOffset
  else
    result := 0;
end;

function ThistoryBox.historyNowOffset: integer;
begin
  if whole then
    result := 0
  else
    result := topVisible
end;

procedure ThistoryBox.Scroll;
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

procedure ThistoryBox.updateMsgStatus(hev: Thevent);
var
  evPicRect: TGPRect;
  evPicSpriteName: TPicName;
  picStr: String;
  idx: Integer;
begin
  idx := history.IndexOf(hev);
  evPicRect := theme.GetPicRect(RQteDefault, hev.pic);
  evPicSpriteName := theme.GetPicSprite(RQteDefault, hev.pic);
  picStr := '[ ''' + evPicSpriteName + ''', ' + inttostr(-evPicRect.X) + ', ' + inttostr(-evPicRect.Y) + ', ' + inttostr(evPicRect.Width) + ', ' + inttostr(evPicRect.Height) + ' ]';
  Call('updateMsgStatus', [IntToStr(idx), picStr]);
end;

procedure ThistoryBox.trySetNot2go2end;
// var
// vTopVis : Integer;
begin
  // vTopVis := topVisible;
  // go2end(True, True);
  // if topVisible > vTopVis then

  // not2go2end := True;
  if fAutoScrollState = ASS_FULLSCROLL then
    setAutoScroll(ASS_ENABLENOTSCROLL);

  // topVisible := vTopVis;
end;

procedure ThistoryBox.histScrollEvent(d: integer);
begin
  if not rsb_visible or ((rsb_position = 0) and (d < 0)) or ((rsb_position = historyNowCount - 1) and (d > 0)) then
    exit;
  startWithLastLine := false;
  //previousMsgId := historyNowOffset + min(max(rsb_position + d, 0), historyNowCount - 1);
  updateRSB(false, rsb_position + d, true);
  topOfs := 0;
  // fAutoscroll := False;
  trySetNot2go2end;
  // if selecting then
  // updatePointedItem()
  // else
  // repaint;
  SendMessage(Self.Handle, CM_INVALIDATE, 0, 0);
  Scroll();
end; // histScrollEvent

procedure ThistoryBox.histScrollLine(d: integer);
begin
  startWithLastLine := false;
  // fAutoscroll := False;
  // not2go2end := True;
  if d > 0 then
  begin
    if topOfs < topEventNrows - 1 then
    begin
      inc(topOfs);
    end
    else if topVisible < offsetMsg + historyNowCount - 1 then
    begin
      histScrollEvent(+1);
      exit;
    end;
  end
  else if topOfs > 0 then
  begin
    dec(topOfs);
  end
  else if topVisible > offsetMsg then
  begin
    updateRSB(true, rsb_position - 1, true);
    startWithLastLine := true;
  end;
  trySetNot2go2end;
  // if selecting then
  // updatePointedItem()
  // else
//  repaint;
  Scroll();
end; // histScrollLine
{
procedure ThistoryBox.LoadEnd(Sender: TObject; const browser: ICefBrowser; const frame: ICefFrame; httpStatusCode: Integer);
begin
  if not (frame = nil) and frame.IsMain then
    templateLoaded := True;
end;
}
procedure ThistoryBox.MouseWheelHandler(var Message: TMessage);
begin
  case message.msg of
    WM_MOUSEWHEEL, WM_VSCROLL:
    begin
      //message.WParamHi := round(message.WParamHi / 3);
      {
      if SmallInt(message.WParamHi) > 0 then
        OutputDebugString(PChar('UP!'))
      else
        OutputDebugString(PChar('DOWN!'));
      }
      //message.Msg := 0;
      //OutputDebugString(PChar('ThistoryBox: ' + inttostr(smallint(message.WParamHi))));
      //inherited MouseWheelHandler(Message);
    end;
  end;
end;

procedure ThistoryBox.WMVScroll(var Message: TWMVScroll);
begin
  OutputDebugString(PChar('WMVScroll'));
end;

function ThistoryBox.escapeQuotes(const text: String): String;
begin
  Result := StringReplace(text, '\', '\\', [rfReplaceAll]);
  Result := StringReplace(Result, '''', '\''', [rfReplaceAll]);
end;

function ThistoryBox.escapeNewlines(const text: String): String;
begin
  Result := StringReplace(text, #13#10, '\n', [rfReplaceAll]);
  Result := StringReplace(Result, #13, '\n', [rfReplaceAll]);
  Result := StringReplace(Result, #10, '\n', [rfReplaceAll]);
end;

procedure ThistoryBox.LoadTemplate;
begin
  LoadURL(FilePathToURL(myPath + 'template.htm'))
end;

procedure ThistoryBox.ClearTemplate;
begin
  Call('clearEvents', []);
end;

procedure ThistoryBox.RefreshTemplate;
begin
  RememberScrollPos;
  InitSmiles;
  ReloadLast;
  RestoreScrollPos;
end;

procedure ThistoryBox.InitSmiles;
var
  i, j: Integer;
  smileObj: TSmlObj;
  smiles, content: String;
  smileRect: TGPRect;
begin
  smiles := '{ ';
  if theme.SmilesCount > 0 then
  begin
    for i := 0 to theme.SmilesCount - 1 do
    begin
      smileObj := theme.GetSmileObj(i);
      if smileObj.SmlStr.Count > 0 then
      begin
        smileRect := theme.GetPicRect(RQteDefault, smileObj.SmlStr[0]);
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
  Call('initSmiles', [smiles]);
end;

procedure ThistoryBox.RememberScrollPos;
begin
  Call('chatRememberScrollPos', []);
end;

procedure ThistoryBox.RestoreScrollPos;
begin
  Call('chatRestoreScrollPos', []);
end;

function LooksLikeALink(link: String): Boolean;
begin
  Result := StartsText('http://', link) or StartsText('https://', link) or StartsText('www.', link);
end;

procedure ThistoryBox.addChatItem(hev: Thevent; evIdx: Integer; animate: Boolean; last: Boolean = True);
var
  codeStr, msgText, bodyText, bodyImages, cachedLinks: String;
  evPicRect,
  cryptPicRect,
  statusImg1Rect, statusImg2Rect: TGPRect;
  evPicSpriteName,
  cryptPicSpriteName,
  statusImg1PicName, statusImg2PicName,
  statusImg1PicSpriteName, statusImg2PicSpriteName: TPicName;
  hdr: THeader;
  st: Integer;
  b: Byte;
  sA: RawByteString;
  inv: Boolean;
  imgList: TStringList;
  linkList: TStringDynArray;
  bodyBin: RawByteString;
  i: Integer;
  params: array of OleVariant;
begin
  if hev = nil then
    Exit;

  hdr := hev.getHeaderTexts;
  msgText := hev.getBodyText;
  bodyText := escapeNewlines(escapeQuotes(msgText));
  evPicRect := theme.GetPicRect(RQteDefault, hev.pic);
  evPicSpriteName := theme.GetPicSprite(RQteDefault, hev.pic);
  cryptPicRect := theme.GetPicRect(RQteDefault, vKeyPicElm.picName);
  cryptPicSpriteName := theme.GetPicSprite(RQteDefault, vKeyPicElm.picName);

  SetLength(params, 11);

  bodyBin := hev.getBodyBin;
  bodyImages := 'false';
  if length(bodyBin) > 0 then
  begin
    imgList := TStringList.Create;
    parseMsgImages(bodyBin, imgList);
    if imgList.Count > 0 then
    begin
      bodyImages := '[';
      for i := 0 to imgList.Count - 1 do
      begin
        if i > 0 then
        bodyImages := bodyImages + ', ';
        bodyImages := bodyImages + '"' + imgList.Strings[i] + '"';
      end;
      bodyImages := bodyImages + ']';
    end;
  end;

  cachedLinks := 'false';
  if length(msgText) > 0 then
  begin
    linkList := SplitString(msgText, ' ;,"'''#13#10);
    if Length(linkList) > 0 then
    begin
      cachedLinks := '[';
      for i := Low(linkList) to High(linkList) do
      if LooksLikeALink(linkList[i]) and imgCacheInfo.ValueExists(linkList[i], 'hash') then
      begin
        if Length(cachedLinks) > 1 then
        cachedLinks := cachedLinks + ', ';
        cachedLinks := cachedLinks + '["' + linkList[i] + '", ' +
        IntToStr(imgCacheInfo.ReadInteger(linkList[i], 'width', 50)) + ', ' +
        IntToStr(imgCacheInfo.ReadInteger(linkList[i], 'height', 50)) + ']';
      end;
      cachedLinks := cachedLinks + ']';
    end;
    if cachedLinks = '[]' then
      cachedLinks := 'false';
  end;

  params[0] := '["' + hdr.what + '", "' + hdr.date + '", "' + hdr.prefix + '"]';
  params[1] := '"' + bodyText + '"';
  params[2] := bodyImages;
  params[3] := cachedLinks;
  params[4] := IntToStr(evIdx);
  params[5] := '["' + evPicSpriteName + '", ' + inttostr(-evPicRect.X) + ', ' + inttostr(-evPicRect.Y) + ', ' +
  inttostr(evPicRect.Width) + ', ' + inttostr(evPicRect.Height) + ']';

  if IF_Encrypt and hev.flags > 0 then
  params[6] := '["' + cryptPicSpriteName + '", ' + inttostr(-cryptPicRect.X) + ', ' + inttostr(-cryptPicRect.Y) + ', ' + inttostr(cryptPicRect.Width) + ', ' + inttostr(cryptPicRect.Height) + ']'
    else
  params[6] := 'false';

  case hev.kind of
    EK_INCOMING, EK_STATUSCHANGE:
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
    EK_OUTGOING:
    begin
      statusImg1PicName := status2imgName(Byte(SC_OFFLINE), False);
    end;
  end;

  if not (statusImg1PicName = '') then
  begin
    statusImg1Rect := theme.GetPicRect(RQteDefault, statusImg1PicName);
    statusImg1PicSpriteName := theme.GetPicSprite(RQteDefault, statusImg1PicName);
    params[7] := '["' + statusImg1PicSpriteName + '", ' + inttostr(-statusImg1Rect.X) + ', ' + inttostr(-statusImg1Rect.Y) + ', ' + inttostr(statusImg1Rect.Width) + ', ' + inttostr(statusImg1Rect.Height) + ']'
  end else
    params[7] := 'false';

  if not (statusImg2PicName = '') then
  begin
    statusImg2Rect := theme.GetPicRect(RQteDefault, statusImg2PicName);
    statusImg2PicSpriteName := theme.GetPicSprite(RQteDefault, statusImg2PicName);
    params[8] := '["' + statusImg2PicSpriteName + '", ' + inttostr(-statusImg2Rect.X) + ', ' + inttostr(-statusImg2Rect.Y) + ', ' + inttostr(statusImg2Rect.Width) + ', ' + inttostr(statusImg2Rect.Height) + ']'
  end else
    params[8] := 'false';

  if animate then
    params[9] := 'true'
  else
    params[9] := 'false';

  if last then
    params[10] := 'true'
  else
    params[10] := 'false';

  Call('addEvent', params);
end;

procedure ThistoryBox.ReloadLast;
var
  evId, endId, startId: Integer;
  evIcon: TIcon;
  iconStream: TMemoryStream;
  hev: Thevent;
begin
  ClearTemplate;
  Application.ProcessMessages;
  Exit;

  if whole then
  begin
    if not history.loaded then
    begin
      history.Clear;
      history.Load(who);
      topVisible := history.Count - offsetMsg;
      offsetAll := offsetMsg;
    end
      else
    topVisible := history.Count - offsetAll;
    startId := 0;
  end else
    startId := topVisible;

  for endId := history.Count - 1 downto startId do
  begin
    hev := history.getAt(endId);
    if (BE_save in behaviour[hev.kind].trig) and (hev.flags and IF_not_save_hist = 0) then
      Break;
  end;

  //for evId := startId to history.Count - 1 do
  for evId := history.Count - 1 to history.Count - 1 do
  begin
    hev := history.getAt(evId);
    if (BE_save in behaviour[hev.kind].trig) and (hev.flags and IF_not_save_hist = 0) then
      addChatItem(hev, evId, False, evId = endId);
  end;

  if fAutoScrollState < ASS_FULLDISABLED then
    Call('chatScrollToBottom', []);
end;
{
constructor ThistoryBox.Create(AOwner: Tcomponent);
begin
  inherited Create(AOwner);
  // avoidErase:=FALSE;
  tabStop := false;
  P_lastEventIsFullyVisible := false;
  onPainted := NIL;
  // autoscroll:=TRUE;
  fAutoScrollState := ASS_FULLSCROLL;
  newSession := 0;
  offset := 0;
  deselect;

  if dStyle = dsBuffer then
    buffer := TBitmap.Create;

end; // create
}
constructor ThistoryBox.Create(AOwner: Tcomponent);
begin
  inherited Create(AOwner);
  tabStop := False;
  fAutoScrollState := ASS_FULLSCROLL;
  Color := clBtnFace;
  topVisible := 0;
  offsetMsg := 0;
  offsetAll := 0;
  whole := false;
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
    if (Length(arguments) > 0) and arguments[0].isString then
      chatFrm.quoteCallback(arguments[0].getStringValue, true);
  end else if (name = 'updateSelection') then
  begin
    ch := chatFrm.thisChat;
    if not (ch = nil) then
    if (Length(arguments) > 3) and arguments[0].IsString and arguments[1].IsInt and arguments[2].IsInt and arguments[3].IsBool then
    with ch.historyBox do
    if (arguments[1].getIntValue = -1) or (arguments[2].getIntValue = -1) then
    begin
      startSel.ofs := -1;
      startSel.ev := nil;
      startSel.evIdx := -1;
      endSel.ofs := -1;
      endSel.ev := nil;
      endSel.evIdx := -1;
      isWholeEvents := false;
    end
      else
    begin
      startSel.ofs := -1;
      startSel.evIdx := arguments[1].getIntValue;
      startSel.ev := history.getAt(startSel.evIdx);
      endSel.ofs := -1;
      endSel.evIdx := arguments[2].getIntValue;
      endSel.ev := history.getAt(endSel.evIdx);
      isWholeEvents := arguments[3].getBoolValue
    end;
  end else if (name = 'updateRightClickedItem') then
  begin
    ch := chatFrm.thisChat;
    if not (ch = nil) then
    if (Length(arguments) > 1) and arguments[0].IsInt and arguments[1].IsString then
    if arguments[0].getIntValue >= 0 then
    begin
      ch.historyBox.rightClickedChatItem.kind := PK_EVENT;
      ch.historyBox.rightClickedChatItem.intData := arguments[0].getIntValue;
      ch.historyBox.rightClickedChatItem.stringData := arguments[1].getStringValue;
    end
      else
    begin
      ch.historyBox.rightClickedChatItem.kind := PK_NONE;
      ch.historyBox.rightClickedChatItem.intData := -1;
      ch.historyBox.rightClickedChatItem.stringData := '';
    end
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

procedure UpdateTabsVisitor(const doc: ICefDomDocument);
var
  chat: ICefDomNode;
begin
  chat := doc.GetElementById('chat');
  if Assigned(chat) then
  begin
    OutputDebugString(PChar('chat!!!'));
  end;
end;

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

procedure TCustomRenderProcessHandler.OnWebKitInitialized;
begin
  renderInit := True;
  CefRegisterExtension('v8/sendresult', extCode, TExtension.Create as ICefV8Handler);
end;

function TCustomRenderProcessHandler.OnProcessMessageReceived(const browser: ICefBrowser; sourceProcess: TCefProcessId; const message: ICefProcessMessage): Boolean;
begin
  if (message.Name = 'visitdom') then
  begin
    browser.MainFrame.VisitDomProc(UpdateTabsVisitor);
    Result := True;
  end else
    Result := False;
end;

{ TResourceHandler }

constructor TResourceHandler.Create(const browser: ICefBrowser; const frame: ICefFrame;
  const schemeName: ustring; const request: ICefRequest);
begin
  inherited;
  FDataStream := nil;
  FRedirectURL := '';
end;

destructor TResourceHandler.Destroy;
begin
  if FDataStream <> nil then
    FreeAndNil(FDataStream);
  inherited;
end;

function TResourceHandler.DetectStreamMimeType: String;
var
  ff: TPAFormat;
begin
  if Assigned(FDataStream) then
  begin
    ff := DetectFileFormatStream(FDataStream);
    if ff = PA_FORMAT_BMP then FMimeType := 'image/bmp'
    else if ff = PA_FORMAT_JPEG then FMimeType := 'image/jpeg'
    else if ff = PA_FORMAT_GIF then FMimeType := 'image/gif'
    else if ff = PA_FORMAT_PNG then FMimeType := 'image/png'
    else if ff = PA_FORMAT_ICO then FMimeType := 'image/x-icon'
    else if ff = PA_FORMAT_TIF then FMimeType := 'image/tiff'
    else if ff = PA_FORMAT_WEBP then FMimeType := 'image/webp'
    else FMimeType := 'image/x-icon';
  end else
    FMimeType := 'text/html';
end;

function TResourceHandler.ProcessRequest(const request: ICefRequest; const callback: ICefCallback): Boolean;
var
  i, j: Integer;
  error, url, fn: String;
  pic: TPicName;
  origPic: TMemoryStream;
  rs: TResourceStream;
  fs: TFileStream;
  cached: Boolean;
begin
  Result := True;

  FDataStream := TMemoryStream.Create;
  if AnsiStartsText('theme:', request.Url) then
  begin
    pic := ReplaceText(copy(request.Url, 7, length(request.Url)), '/', '');
    origPic := nil;
    if theme.GetOrigPic(RQteDefault, pic, origPic) then
    begin
      FDataStream.LoadFromStream(origPic);
      origPic.Free;
      SetStatus(200);
    end
      else
    SetStatus(306);
  end else if AnsiStartsText('smile:', request.Url) then
  begin
    pic := ReplaceText(copy(request.Url, 7, length(request.Url)), '/', '');
    pic := copy(pic, 2, length(pic));
    origPic := nil;

    if theme.GetOrigSmile(pic, origPic) then
    begin
      FDataStream.LoadFromStream(origPic);
      origPic.Free;
      SetStatus(200);
    end
      else
    SetStatus(306);
  end
  else if AnsiStartsText('res:', request.Url) then
  begin
    url := ReplaceText(copy(request.Url, 5, length(request.Url)), '/', '');
    if url = 'load' then
      url := 'dummy';

    rs := TResourceStream.Create(HInstance, uppercase(url), RT_RCDATA);
    try
      rs.SaveToStream(FDataStream);
    finally
      rs.Free;
    end;
    SetStatus(200);
  end
  else
  begin
    if not LooksLikeALink(request.Url) then
    begin
      SetStatus(306);
      Exit;
    end;

    fn := myPath + 'Cache\Images\' + imgCacheInfo.ReadString(request.Url, 'hash', '0') + '.' + imgCacheInfo.ReadString(request.Url, 'ext', 'jpg');
    cached := FileExists(fn);

    if request.Method = 'HEAD' then
    begin
      if cached then
        SetStatus(302)
      else if imgCacheInfo.ValueExists(request.Url, 'mime') and not MatchText(imgCacheInfo.ReadString(request.Url, 'mime', ''), ImageContentTypes) then
        SetStatus(306)
      else if CheckType(request.Url) then
        SetStatus(302)
      else
        SetStatus(306);
    end
      else
    begin
      if not cached then
        cached := DownloadAndCache(request.Url);

      if not cached then
        SetStatus(306)
      else
      try
        fn := myPath + 'Cache\Images\' + imgCacheInfo.ReadString(request.Url, 'hash', '0') + '.' + imgCacheInfo.ReadString(request.Url, 'ext', 'jpg');
        fs := TFileStream.Create(fn, fmOpenRead);
        FDataStream.LoadFromStream(fs);
        SetStatus(200);
      except
        SetStatus(306);
      end;

      if Assigned(fs) then
        fs.Free;
    end;
  end;
  FDataStream.Seek(0, soFromBeginning);

  callback.Cont;
end;

procedure TResourceHandler.GetResponseHeaders(const response: ICefResponse; out responseLength: Int64; out redirectUrl: ustring);
begin
  if not (FRedirectURL = '') then
  begin
    redirectUrl := FRedirectURL;
    response.MimeType := 'text/html';
    responseLength := 0;
  end
    else
  begin
    response.MimeType := FMimeType;
    responseLength := FDataStream.Size;
  end;
  response.Status := FStatus;
  response.StatusText := FStatusText;
end;

function TResourceHandler.ReadResponse(const dataOut: Pointer; bytesToRead: Integer; var bytesRead: Integer; const callback: ICefCallback): Boolean;
begin
  BytesRead := FDataStream.Read(DataOut^, BytesToRead);
  Result := True;
  callback.Cont;
end;

procedure TResourceHandler.SetStatus(status: Integer);
begin
  case status of
    200:
      begin
        FStatus := 200;
        FStatusText := 'OK';
        DetectStreamMimeType;
      end;
    302:
      begin
        FStatus := 302;
        FStatusText := 'Accept';
        FMimeType := 'text/html';
      end;
    306:
      begin
        FStatus := 306;
        FStatusText := 'Ignore';
        FMimeType := 'text/html';
      end;
  end;
end;
*)
initialization

if dStyle = dsGlobalBuffer32 then
begin
  globalBuffer32 := TBitmap32.Create;
  globalBuffer32.SetSize(0, 0);
end;

vKeyPicElm.ThemeToken := -1;
vKeyPicElm.picName := PIC_KEY;
vKeyPicElm.Element := RQteDefault;
vKeyPicElm.pEnabled := true;

finalization

if dStyle = dsGlobalBuffer32 then
  if globalBuffer32 <> nil then
    globalBuffer32.Free;

end.
