{
  This file is part of R&Q.
  Under same license
}
unit historyCEF;
{$I RnQConfig.inc}
{$I NoRTTI.inc}

interface

uses
{$IFDEF USE_GDIPLUS}
  GDIPAPI, GDIPOBJ,
{$ENDIF USE_GDIPLUS}
  Windows, Controls, Classes, Generics.Collections,
  SysUtils, Graphics, Forms, StdCtrls, ExtCtrls,
  Messages, StrUtils, System.UITypes, NetEncoding,
  RDGlobal, history, RnQProtocol, events, iniLib,
  cefvcl, ceflib;


type
  TlinkKind = (LK_FTP, LK_EMAIL, LK_WWW, LK_UIN, LK_ED);
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
  THistoryBox = class(TChromium)
  private
    template: TStringList;
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
//    buffer: TBitmap;

    firstCharactersForSmiles: set of AnsiChar; // for faster smile recognition
  protected
    function getAutoScroll: boolean;
    procedure setAutoScroll(asState: TAutoScrollState);
    procedure setAutoScrollForce(vAS: boolean);
    procedure LoadEnd(Sender: TObject; const browser: ICefBrowser; const frame: ICefFrame; httpStatusCode: Integer);
    procedure LoadError(Sender: TObject; const browser: ICefBrowser; const frame: ICefFrame; errorCode: Integer; const errorText, failedUrl: ustring);
    procedure LoadStart(Sender: TObject; const browser: ICefBrowser; const frame: ICefFrame);
    procedure SetFocus(Sender: TObject; const browser: ICefBrowser; source: TCefFocusSource; out Result: Boolean);
  public
    topVisible, topOfs: integer;
    offset, offsetAll: Int64; // can't show hevents before this
    startSel, endSel: ThistoryPos;
    isWholeEvents: Boolean;
    who: TRnQContact;
    history: Thistory;
    margin: Trect;
    whole: boolean; // see whole history
    rsb_visible: boolean;
    rsb_position: integer;
    rsb_rowPerPos: integer;
    newSession: Int64; // where, in the history, does start new session
    onPainted: TNotifyEvent;
    w2s: String;
    rightClickedChatItem: TChatItem;
    templateLoaded: Boolean;

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

    procedure CreateBrowserInstance;
    procedure LoadTemplate;
    procedure ClearTemplate;
    procedure RefreshTemplate;
    procedure ReloadLast;
    procedure InitSmiles;
    procedure RememberScrollPos;
    procedure RestoreScrollPos;
    procedure addChatItem(hev: Thevent; evIdx: Integer; animate: Boolean);
    procedure addJScode(const code: string; const thread: string = 'default');
    procedure execJS(const thread: string = 'default');
    function hasJScode(const thread: string = 'default'): Boolean;

    constructor Create(AOwner: Tcomponent); override;
    destructor Destroy; override;
    procedure go2end();
    function getSelText(): string;
    function getSelBin(): AnsiString;
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
    procedure setScrollPrefs(ShowAll: Boolean);
    procedure updateMsgStatus(hev: Thevent);
    procedure ManualRepaint;

    procedure MouseWheelHandler(var Message: TMessage); override;
    procedure WMVScroll(var Message: TWMVScroll); message WM_VSCROLL;
    property  offsetMsg : Int64 read offset write offset;
  end;

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

var
  hisBGColor, myBGColor: TColor;
  renderInit: Boolean = False;

implementation

uses
  clipbrd, Types, math,
{$IFDEF UNICODE}
  Character,
  AnsiStrings, AnsiClasses,
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
  ICQConsts, ICQv9, RQ_ICQ,
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
  jscode: TDictionary<String, UTF8String>;

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
  if Assigned(Self) then
    inherited Destroy;
  // self := NIL;
end;
(*
procedure ThistoryBox.paintOn(cnv: Tcanvas; vR: Trect; const JustCalc: boolean = false);
var
  // vCnvHandle : HDC;
  lineHeight, bodySkipCounter, skippedLines, evIdx, Nitems: integer;
  rightLimit, bottomLimit: integer;
  SOS, EOS: ThistoryPos;
  ev: Thevent;
  // c: Tcontact;
  selectedClr: TColor;
  // selectedMyClr, selectedHisClr : TColor;
  linkTheWholeBody: string;
  foundLink: ThistoryLink;
  mouse: Tpoint;
{$IFDEF RNQ_FULL}
  foundAniSmile: boolean;
{$ENDIF RNQ_FULL}
  eventFullyPainted, firstEvent, nowLink, nowBold, nowUnderline, pleaseDontDrawUpwardArrows: boolean;
  oldMode: integer;
  Nrows: integer;

  procedure newLine(var X, Y: integer);
  begin
    if bodySkipCounter <= 0 then
      inc(Y, lineHeight)
    else
      inc(skippedLines);
    X := margin.left;
    lineHeight := 0;
    inc(Nrows);
    dec(bodySkipCounter);
  end; // newLine

  function isEmailAddress(const s: string; start: integer; var end_: integer): boolean;
  var
    j: integer;
    existsDot: boolean;
  begin
    result := false;
    j := start;
    // try to find the @
    while (j <= length(s)) and (s[j] in EMAILCHARS) and (j - start < 30) do
      inc(j);
    if s[j] <> '@' then
      exit;
    // @ found, now skip the @ and search for .
    inc(j);
    existsDot := false;
    while (j < length(s)) and (s[j + 1] in EMAILCHARS) do
    begin
      if s[j] = '.' then
      begin
        existsDot := true;
        break;
      end;
      inc(j);
    end;
    // at least a valid char after the . must exists
    if not existsDot or not(s[j] in EMAILCHARS) then
      exit;
    // go forth till we're out or we meet an invalid char
    repeat
      inc(j)
    until (j > length(s)) or not(s[j] in EMAILCHARS);
    end_ := j - 1;
    if s[end_] = '.' then
      dec(end_);
    // while s[start-1] in emailChar do dec(start);
    result := true;
  end; // isEmailAddress

  function isUIN(const s: string; start: integer; var end_: integer): boolean;
    function isdig(ch: char): boolean; inline;
    begin
{$IFDEF UNICODE}
      result := ch.IsDigit;
{$ELSE UNICODE}
      result := ch in ['0' .. '9'];
{$ENDIF UNICODE}
    end;

  var
    i: integer;
  begin
    result := false;
    i := start;
    if (i > 0) and isdig(s[i - 1]) then
      exit;
    while (i <= length(s)) and isdig(s[i]) and (i - start < 10) do
      inc(i);
    if (i <= length(s)) and isdig(s[i]) or ((i < length(s)) and (s[i] in [',', '.']) and isdig(s[i + 1])) then
      // Result := False
    else if i - start > 5 then
    begin
      end_ := i - 1;
      result := true;
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
    // cnv.TextHeight(s);
    GetTextExtentPoint32(cnv.Handle, PChar(s), length(s), sz);
    // GetTextExtentPoint32(Cnv.Handle, @s[1], Length(s), sz);
    newLineHeight(sz.cy + 2);
  end;

  function addItem(k: TitemKind; o, l: integer; r: Trect): PhistoryItem;
  begin
    inc(Nitems);
    if length(items) < Nitems then
      setLength(items, length(items) + 20);
    result := @items[Nitems - 1];
    result.kind := k;
    result.ev := ev;
    result.evIdx := evIdx;
    result.ofs := o;
    result.l := l;
    result.r := r;
    if k = PK_LINK then
      result.link := foundLink;
    { if k = PK_ARROWS_DN then
      begin
      hasDownArrow:= true;
      hDownArrow:=  r.Bottom-r.Top;
      end
      else
      hasDownArrow:= false; }
  end; // addItem

  function withinTheLink(i: integer): boolean;
  begin
    result := (foundLink.from > 0) and (i >= foundLink.from) and (i <= foundLink.to_)
  end; // withinTheLink

// function drawBody(cnv:Tcanvas; pTop : Integer) : Integer;
  function drawBody(pTop: integer): integer;
  var
    whatFound: (_nothing, _wrap, _return, _smile, _link, _bold, _underline, _RnQPic, _RnQPicEx, _aniSmile);
    fndSmileI: integer;
    fndSmile: String;
    fndSmileN: TPicName;
    foundPicSize: integer;
    RnQPicStream: TMemoryStream;
    BodyText: String;
    BodyCurChar: char;
    BodyBin: RawByteString;

    i, j, chunkStart, quoteCounter: integer;

    function findLink(): boolean;

      procedure setResult(lk: TlinkKind; end_: integer = 0);
      const
        allowedChars: array [TlinkKind] of set of char = (FTPURLCHARS, EMAILCHARS, WEBURLCHARS, ['0' .. '9'], EDURLCHARS);
      begin
        if end_ = 0 then
        begin
          end_ := i;
          if lk = LK_WWW then
          begin
            while (end_ < length(BodyText)) and
              not (BodyText[end_ + 1].IsSeparator) and
              not (BodyText[end_ + 1].IsControl) and
              not (BodyText[end_ + 1] in ['"', '''']) do
              inc(end_);
            // if TCharacter.IsSeparator(BodyText[end_]) then
            // dec(end_);
          end
          else
            while (end_ < length(BodyText)) and (BodyText[end_ + 1] in allowedChars[lk]) do
              inc(end_);
        end;
        if (end_ > 0) and (end_ <= length(BodyText)) then
          // while BodyText[end_] in ['?',')','.',','] do
          // while CharInSet(BodyText[end_], ['?',')','.',',', '/']) do
          while CharInSet(BodyText[end_], ['?', ')', '.', ',']) do
            dec(end_);
        foundLink.str := copy(BodyText, i, end_ - i + 1);
        foundLink.from := i;
        foundLink.to_ := end_;
        foundLink.kind := lk;
        inc(foundLink.id);
        result := true;
      end;

    var
      e: integer;
    begin
      result := false;
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
          'H':
            if Imatches(BodyText, i, 'http://') or Imatches(BodyText, i, 'https://') then
              setResult(LK_WWW);
          'W':
            if Imatches(BodyText, i, 'www.') { or Imatches(BodyText,i,'web.') } then
              setResult(LK_WWW);
          'F':
            if Imatches(BodyText, i, 'ftp://') or Imatches(BodyText, i, 'ftp.') then
              setResult(LK_FTP);
          'S':
            if Imatches(BodyText, i, 'sftp://') or Imatches(BodyText, i, 'sftp.') then
              setResult(LK_FTP);
          'E':
            if Imatches(BodyText, i, 'ed2k://') then
              setResult(LK_ED);
          '1' .. '9':
            if isUIN(BodyText, i, e) then
              setResult(LK_UIN, e);
        end;
    end; // findLink

    function findFidonet(sym: char): boolean;
    var
      j: integer;
    begin
      result := false;
      if (BodyText[i] <> sym) or ((i > 1) and not(BodyText[i - 1] in WHITESPACES)) // word begin
        or (i + 2 > length(BodyText)) then
        exit;
      j := i + 1;
      while (j < length(BodyText)) and
{$IFDEF UNICODE}
        (BodyText[j].IsLetterOrDigit)
{$ELSE UNICODE}
        (BodyText[j] in ALPHANUMERIC)
{$ENDIF UNICODE}
        do
        inc(j);
      if (BodyText[j] <> sym) or (j - i = 1) then
        exit; // ends with sym, and no 2 sym bound
      result := true;
    end; // findFidonet

    function findSmile(): boolean;
    var
      k, l: integer;
      smileCap: string;
{$IFDEF UNICODE}
      sA: AnsiString;
{$ENDIF UNICODE}
      SmileObj: TSmlObj;
    begin
      result := false;
{$IFDEF UNICODE}
      sA := BodyText[i];
      if not(sA[1] in firstCharactersForSmiles) then
        exit;
{$ELSE nonUNICODE}
      if not(BodyText[i] in firstCharactersForSmiles) then
        exit;
{$ENDIF UNICODE}
      // if not CharInSet(BodyText[i], firstCharactersForSmiles) then exit;
      fndSmileN := '';
      fndSmileI := -1;
      // foundSmileIdx := -1;
      if theme.SmilesCount > 0 then
        // if rqSmiles.SmilesCount > 0 then
        for k := 0 to theme.SmilesCount - 1 do
        begin
          SmileObj := theme.GetSmileObj(k);
          for l := 0 to SmileObj.SmlStr.Count - 1 do
          begin
            smileCap := SmileObj.SmlStr.Strings[l];
            if (smileCap[1] = BodyText[i]) and matches(BodyText, i, smileCap) // and (SmileObj.Smile<>NIL)
              and ((fndSmileI = -1) or (length(smileCap) > length(fndSmile))) then
            begin
              // if (length(s) >= i+length(smileCap))
              // and (smileCap[1]=':')
              // and (s[i+length(smileCap)] in ['a'..'z','0'..'9','A'..'Z',#128..#255])
              // and (smileCap[length(smileCap)]<>s[i+length(smileCap)])
              // then continue;
              fndSmile := smileCap;
{$IFDEF RNQ_FULL}
              foundAniSmile := theme.useAnimated AND SmileObj.Animated;
              if foundAniSmile then
                fndSmileI := SmileObj.AniIdx
              else
{$ENDIF RNQ_FULL}
                fndSmileI := k;
              fndSmileN := theme.GetSmileName(k);
              // foundSmileIdx:=k;
              result := true;
            end;
          end;
        end;
    end; // findSmile

    function findRnQPic(): boolean;
    var
      k: integer;
    begin
      result := false;
      if (BodyBin[i] <> '<') then
        exit;
      // foundRnQPic := '';
      FreeAndNil(RnQPicStream);
      if matches(BodyBin, i, RnQImageTag) then
      begin
        k := PosEx(RnQImageUnTag, BodyBin, i + 10);
        if k <= 0 then
          exit;
        foundPicSize := k - i - 10;
        RnQPicStream := TMemoryStream.Create;
        RnQPicStream.SetSize(foundPicSize);
        RnQPicStream.Write(BodyBin[i + 10], foundPicSize);
        // foundRnQPic:=Copy(s, i+10, k-i-10);
        result := true;
      end;
    end; // findRnQPic

    function findRnQPicEx(): boolean;
    var
      k: integer;
      OutSize: DWord;
      PIn, POut: Pointer;
    begin
      result := false;
      if (BodyBin[i] <> '<') then
        exit;
      // foundRnQPic:='';
      FreeAndNil(RnQPicStream);
      if matches(BodyBin, i, RnQImageExTag) then
      begin
        k := PosEx(RnQImageExUnTag, BodyBin, i + length(RnQImageExTag));
        if k <= 0 then
          exit;
        foundPicSize := k - i - length(RnQImageExTag);
        if (foundPicSize > 0) then
        begin
          try
            PIn := @BodyBin[i + length(RnQImageExTag)];
            OutSize := CalcDecodedSize(PIn, foundPicSize);
            // prepare string length to fit result data
            RnQPicStream := TMemoryStream.Create;
            RnQPicStream.SetSize(OutSize);
            RnQPicStream.Position := 0;
            POut := RnQPicStream.Memory;
            // decode !
            Base64Decode(PIn^, foundPicSize, POut^); // Since EurekaLog 6.22 need "^"
            result := true;
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

  var
    quoteCounting: boolean;
    r, intersect: Trect;
    nowPos: ThistoryPos;
    PntFontIdx: Byte;

    function withinTheSelection(i: integer): boolean;
    begin
      nowPos.evIdx := evIdx;
      nowPos.ev := ev;
      nowPos.ofs := i;
      result := (SOS.ev <> NIL) and (EOS.ev <> NIL) and ((SOS.ofs < 0) and within(SOS.evIdx, evIdx, EOS.evIdx) or
        not minor(EOS, nowPos) and minor(SOS, nowPos));
    end;

    procedure applyFont();
    var
      newPntFontIdx: Byte;
    begin
      // cnv.font.Assign(Screen.MenuFont);
      // theme.applyFont(ev.useFont, cnv.font);
      // ev.applyFont(cnv.font);
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
          3:
            theme.applyFont('history.my.quoted', cnv.font);
          4:
            theme.applyFont('history.his.quoted', cnv.font);
        end;
        applyUserCharset(font);
      end;
      with cnv.font do
      begin
        if nowBold then
        begin
          if not(fsBold in style) then
            style := style + [fsBold];
        end;
        // else
        // if (fsBold in style) then
        // style:=style-[fsBold];
        if nowUnderline then
        begin
          if not(fsUnderline in style) then
            style := style + [fsUnderline];
        end;
        // else
        // if (fsUnderline in style) then
        // style:=style-[fsUnderline];
      end;
      if nowLink then
        theme.applyFont('history.link', cnv.font);
    end; // applyFont

  var
    tempColor: TColor;
    len, smileCount: integer;
    size, tempSize: TSize;
    lastLineStart: integer;
    lastSmileChar: char;
    fndSmlT2: TPicName;
    fndSmlIT: integer;
    fndAniSmlT: boolean;
    first, bool, wasInsideSelection: boolean;
    SelectionStartPos, SelectionEndPos: integer;

    // vDBPic: TBitmap;
    vPicElm: TRnQThemedElementDtls;
    // vPicLoc : TPicLocation;
    // vThemeTkn : Integer;
    // vPicIdx : Integer;
    // vPicName : String;
    X, Y: integer;
    vRnQPic: TBitmap32;
    // gr : TGPGraphics;
    vRnQpicEx: TRnQBitmap;
    hnd: HDC;
    pt: Tpoint;

  begin
    X := margin.left;
    Y := pTop;
    RnQPicStream := NIL;
    eventFullyPainted := false;
    if JustCalc then
      if (ev.HistoryToken = history.Token) then
      begin
        result := ev.PaintHeight;
        inc(Y, result);
        if (Y <= bottomLimit) then
          eventFullyPainted := true;
        exit;
      end;
    BodyText := ev.getBodyText;
    // BodyBin  := ev.bInfo;
    BodyBin := ev.getBodyBin;
    if ((length(BodyText) = 0) and (length(BodyBin) <= 10)) or (Y >= bottomLimit) then
    begin
      ev.HistoryToken := history.Token;
      ev.PaintHeight := 0;
      result := 0;
      if (Y <= bottomLimit) then
        eventFullyPainted := true;
      exit;
    end;
    // draw upward arrows
    if firstEvent and (topOfs > 0) then
    begin
      bodySkipCounter := topOfs;
      if not pleaseDontDrawUpwardArrows then
      begin
        // vDBPic := TBitmap.Create;
        // theme.getPic(PIC_SCROLL_UP, pic);
        // theme.getPic(PIC_SCROLL_UP, vDBPic);
        vPicElm.picName := PIC_SCROLL_UP;
        vPicElm.ThemeToken := -1;
        vPicElm.Element := RQteDefault;
        X := margin.left;
        with theme.GetPicSize(vPicElm) do
        begin
          // i := vDBPic.Width;
          if not JustCalc then
          begin
            r := rect(X, Y, rightLimit, Y + cy);
            addItem(PK_ARROWS_UP, 0, 0, r);
            hnd := cnv.Handle;
            pt.Y := Y;
            pt.X := X;
            while pt.X < rightLimit do
            begin
              theme.drawPic(hnd, pt, vPicElm);
              inc(pt.X, cx);
            end;
          end;
          vPicElm.ThemeToken := -1;
          inc(Y, cy);
          // freeAndNil(vDBPic);
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
    X := margin.left;
    cnv.brush.color := TextBGColor; // history.bgcolor;
    // cnv.font.assign(ev.font);
    wasInsideSelection := false;
    len := length(BodyText);
    quoteCounting := true;
    nowBold := false;
    nowUnderline := false;
    nowLink := false;
    // loop until there's text to be painted
    while (Y < bottomLimit) and (i <= len) do
    begin
      chunkStart := i;
      case whatFound of
        _nothing:
          begin
            applyFont();
            j := X;
            // go forth, until sth special is found
            while i <= len do
            begin
              // reached the end of the link, stop, we must paint it underlined
              if (foundLink.from > 0) and (i > foundLink.to_) then
              begin
                // nowLink := False;
                if (foundLink.kind <> LK_UIN) then
                  whatFound := _link;
                break;
              end;
              // reached a selection edge, stop, we must paint it selected
              bool := withinTheSelection(i);
              if wasInsideSelection <> bool then
              begin
                wasInsideSelection := bool;
                if wasInsideSelection then
                  SelectionStartPos := i
                else
                  SelectionEndPos := i;
                break;
              end;
              BodyCurChar := BodyText[i];
              // things to consider only outside a link
              if foundLink.from = 0 then
              begin
                if BodyCurChar in [#10, #13] then
                begin
                  whatFound := _return;
                  break
                end;
                if useSmiles and findSmile() then
                begin
                  whatFound := _smile;
                  break
                end;
                // if findRnQPic() then begin whatFound:=_RnQPic; break end;
                // if findRnQPicEx() then begin whatFound:=_RnQPicEx; break end;
                if BodyCurChar < #32 then
                begin
                  BodyText[i] := #32; // convert control chars
                  BodyCurChar := #32;
                end;
                if findLink() and (foundLink.kind <> LK_UIN) then
                begin
                  // nowLink := True;
                  whatFound := _link;
                  // chunkStart := i;
                  break;
                end;
                if quoteCounting then
                  if BodyCurChar = '>' then
                    inc(quoteCounter)
                  else
                    { quoting sequence terminates where a non-">" char is found
                      { or a non-single blankspace is found or a non-">"-preceeded
                      { blankspace is found }
                    if (BodyCurChar <> ' ') or (quoteCounter = 0) or (i = 1) or (BodyText[i - 1] <> '>') then
                      quoteCounting := false;
                if fontstylecodes.enabled then
                begin
                  if (BodyCurChar = '*') and (nowBold or findFidonet('*')) then
                  begin
                    whatFound := _bold;
                    break
                  end;
                  if (BodyCurChar = '_') and (nowUnderline or findFidonet('_')) then
                  begin
                    whatFound := _underline;
                    break
                  end;
                end;
              end;
              applyFont();
              size := txtSizeL(cnv.Handle, @BodyText[i], 1);
              inc(j, size.cx);
              if j > rightLimit then // no more room
              begin
                // search backward for a good place where to split
                j := i;
                repeat
                  dec(j)
                until (j = lastLineStart) or (BodyText[j] in ['-', ' ', ',', ';', '.']);
                // found. choose it
                if j > chunkStart then
                  i := j + 1
                else if i = lastLineStart then
                  inc(i);
                whatFound := _wrap;
                break
              end;
              if not JustCalc then
              begin
                r := rect(j - size.cx, Y, j, Y + size.cy);
                if bodySkipCounter <= 0 then
                  if withinTheLink(i) then
                    addItem(PK_LINK, i, 1, r)
                  else
                    addItem(PK_TEXT, i, 1, r);
              end;
              inc(i);
            end; // while
            // no text, suddenly a break comes
            if i = chunkStart then
              continue;

            j := i - chunkStart; // = length of text
            applyFont();
            size := txtSizeL(cnv.Handle, @BodyText[chunkStart], j); // size on screen
            // is it a link?
            if withinTheLink(chunkStart) and (evIdx = linkToUnderline.evIdx) and
              within(linkToUnderline.from, chunkStart, linkToUnderline.to_) then
              with cnv.font do
              begin
                style := style + [fsUnderline];
                PntFontIdx := 100;
              end;
            // newLineHeight('I');
            newLineHeight(size.cy + 2);
            if withinTheSelection(chunkStart) then
              cnv.brush.color := selectedClr
            else
              cnv.brush.color := TextBGColor;
            // finally paint the text
            // if bodySkipCounter<=0 then textOut(cnv.handle, x,y+lineHeight-size.cy, @s[chunkStart], j);
            if bodySkipCounter <= 0 then
            begin
              if not withinTheSelection(chunkStart) then
              begin
                oldMode := SetBKMode(cnv.Handle, TRANSPARENT);
                textOut(cnv.Handle, X, Y, @BodyText[chunkStart], j);
                // SetBKMode(cnv.Handle, oldMode);
              end
              else
                textOut(cnv.Handle, X, Y, @BodyText[chunkStart], j);
            end;
            inc(X, size.cx);
            if (i > foundLink.to_) then
              foundLink.from := 0;
            continue;
          end;
        _link:
          begin
            // inc(i);
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
              #10:
                inc(i);
              #13:
                begin
                  inc(i);
                  if (i <= len) and (BodyText[i] = #10) then
                    inc(i);
                end;
            end;
            if nowBold or nowUnderline or nowLink or (quoteCounter > 0) then
            begin
              nowBold := false;
              nowUnderline := false;
              nowLink := false;
              quoteCounter := 0;
              PntFontIdx := 100;
            end;

            quoteCounting := true;
            newLineHeight('I');
            lastLineStart := i;
            newLine(X, Y);
          end;
        _smile:
          begin
            // count times smile has to be repeated by last character
            if length(fndSmile) = 0 then
              break;
            smileCount := 1;
            j := length(fndSmile);
            inc(i, j);
            lastSmileChar := fndSmile[j];
            // fndSmlT1 := fndSmile;
            fndSmlT2 := fndSmileN;
            fndSmlIT := fndSmileI;
            fndAniSmlT := foundAniSmile;
            bool := lastSmileChar in firstCharactersForSmiles;
            while (i <= len) and (BodyText[i] = lastSmileChar) do
            begin
              if bool and findSmile() then
                break;
              inc(i);
              inc(smileCount);
            end;
            // fndSmile  := fndSmlT1;
            fndSmileN := fndSmlT2;
            fndSmileI := fndSmlIT;
            foundAniSmile := fndAniSmlT;
            // vDBPic :=TBitmap.Create;
            // theme.GetPic(theme.GetSmileName(foundSmileIdx), vDBPic);
            // vPicName := ;
            // pic:=theme.GetSmile(foundSmileIdx); //smiles.pics[foundSmileIdx];
            tempSize := theme.GetPicSize(RQteDefault, fndSmileN);
            newLineHeight(tempSize.cy + 2);

            // paint
            // size.cx := tempSize.cx+1;
            // size.cy := tempSize.cy;
            size := tempSize;
            inc(size.cx);
            cnv.brush.color := selectedClr;
            first := true;
            while smileCount > 0 do
            begin
              if X + size.cx > rightLimit then
              begin
                newLine(X, Y);
                newLineHeight(tempSize.cy + 1);
              end;
              // only the first one has full length
              // if first then j:=length(fndSmile) else j:=1;
              if not first then
                j := 1;
              if not JustCalc then
              begin
                r := rect(X, Y, X + size.cx, Y + size.cy + 1);
                if bodySkipCounter <= 0 then
                begin
                  addItem(PK_SMILE, chunkStart, j, r);
                  begin
                    if withinTheSelection(chunkStart) then
                    begin
                      // if not JustCalc then
                      cnv.fillRect(r);
{$IFDEF RNQ_FULL}
                      if foundAniSmile then
                        tempColor := selectedClr;
{$ENDIF RNQ_FULL}
                    end
{$IFDEF RNQ_FULL}
                    else if foundAniSmile then
                      tempColor := color;
                    // tempColor := theme.GetAColor(ClrHistBG, clWindow);
                    if foundAniSmile then
                    begin
                      // if not JustCalc then
                      begin
                        theme.AddAniParam(fndSmileI, RDGlobal.MakeRect(X, Y + (lineHeight - size.cy) div 2, size.cx, size.cy),
                          // gpColorFromAlphaColor($FF, tempColor)
                          tempColor, canvas, cnv, tempColor <> color);

                        // theme.
                        // theme.drawPic(cnv, x, y+(lineHeight-size.cy) div 2, )
                        with theme.GetAniPic(fndSmileI) do
                          Draw(cnv.Handle, X, Y + (lineHeight - size.cy) div 2);
                      end;
                    end
                    else
{$ELSE RNQ_FULL}
                      ;
{$ENDIF RNQ_FULL}
                    // if not JustCalc then
                    theme.drawPic(cnv.Handle, X, Y + (lineHeight - size.cy) div 2, fndSmileN);
                    // cnv.draw(x,y+(lineHeight-size.cy) div 2, vDBPic);
                  end;
                end;
              end; // endif not JustCalc
              // inc(chunkStart);
              inc(chunkStart, j);
              inc(X, size.cx);
              first := false;
              dec(smileCount);
            end;
            // freeAndNil(vDBPic);
          end;
        _wrap:
          begin
            newLine(X, Y);
            lastLineStart := i;
          end;
      end; // case
      whatFound := _nothing;
    end; // while

    eventFullyPainted := (i > len) and (Y <= bottomLimit);

    /// /////////////////// Processing Binaries ////////////////////////////
    len := length(BodyBin);
    i := len + 1;
    if len > 10 then
    // if 1=2 then
    begin
      i := 1;
      newLine(X, Y);
      whatFound := _nothing;
      // PntFontIdx := 101;
      // foundLink.from:=0;
      // lastLineStart:=1;
      lineHeight := 0;
      X := margin.left;
      // cnv.brush.color := TextBGColor; //history.bgcolor;
      // cnv.font.assign(ev.font);
      // wasInsideSelection:=FALSE;

      while (Y < bottomLimit) and (i <= len) do
      begin
        chunkStart := i;
        case whatFound of
          _nothing:
            begin
              j := X;
              // go forth, until sth special is found
              while i <= len do
              begin
                // reached a selection edge, stop, we must paint it selected
                { bool:=withinTheSelection(i);
                  if wasInsideSelection <> bool then
                  begin
                  wasInsideSelection:=bool;
                  break;
                  end; }
                // things to consider only outside a link
                // if BodyBin[i] in [#10,#13] then begin whatFound:=_return; break end;
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
                { if j > rightLimit then // no more room
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
                  whatFound:=_wrap;
                  break
                  end; }
                inc(i);
              end; // while
              // no text, suddenly a break comes
              if i = chunkStart then
                continue;
              {
                if withinTheSelection(chunkStart) then
                cnv.brush.color := selectedClr
                else
                cnv.brush.color := TextBGColor; }
              // inc(x, size.cx);
              continue;
            end;
          _return:
            begin
              case BodyBin[i] of
                #10:
                  inc(i);
                #13:
                  begin
                    inc(i);
                    if (i <= len) and (BodyBin[i] = #10) then
                      inc(i);
                  end;
              end;
              if nowBold or nowUnderline or nowLink or (quoteCounter > 0) then
              begin
                nowBold := false;
                nowUnderline := false;
                nowLink := false;
                quoteCounter := 0;
                PntFontIdx := 100;
              end;

              quoteCounting := true;
              newLineHeight('I');
              lastLineStart := i;
              newLine(X, Y);
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
                  r := rect(X, Y, X + size.cx + 1, Y + size.cy);
                  if bodySkipCounter <= 0 then
                  begin
                    j := foundPicSize + length(RnQImageTag) + length(RnQImageUnTag);
                    addItem(PK_RQPIC, chunkStart, j, r);
                    if withinTheSelection(chunkStart) then
                      cnv.fillRect(r);
                    // if not JustCalc then
                    // cnv.Draw(X, Y + (lineHeight - size.cy) div 2, vRnQPic);
                    vRnQPic.DrawTo(cnv.Handle, X, Y + (lineHeight - size.cy) div 2);
                  end;
                end;
                inc(chunkStart);
                inc(X, size.cx + 1);
                // end;
                if Assigned(vRnQPic) then
                  vRnQPic.Free;
                vRnQPic := NIL;
              end;
            end;
          _RnQPicEx:
            begin
              inc(i, foundPicSize + length(RnQImageExTag) + length(RnQImageExUnTag));

              // RnQPicStream := TMemoryStream.Create;
              // RnQPicStream.SetSize(foundPicSize);
              // RnQPicStream.Write(foundRnQPic[1], Length(foundRnQPic));

              vRnQpicEx := nil;
              // if Assigned(RnQPicStream) then
              // RnQPicStream.position := 0;
              if loadPic(TStream(RnQPicStream), vRnQpicEx, 0, PA_FORMAT_UNK, 'RnQImageEx', true) then
              begin
                size.cx := vRnQpicEx.getWidth + 1;
                size.cy := vRnQpicEx.getHeight;
                newLineHeight(size.cy + 1);
                // paint
                if not JustCalc then
                begin
                  cnv.brush.color := selectedClr;
                  // only the first one has full length
                  r := rect(X, Y, X + size.cx, Y + size.cy);
                  if bodySkipCounter <= 0 then
                  begin
                    j := foundPicSize + length(RnQImageExTag) + length(RnQImageExUnTag);
                    addItem(PK_RQPICEX, chunkStart, j, r);
                    // if not JustCalc then
                    begin
                      if withinTheSelection(chunkStart) then
                        cnv.fillRect(r);
                      cnv.Lock;
                      DrawRbmp(cnv.Handle, vRnQpicEx, X, Y);
                      // gr := TGPGraphics.Create(cnv.Handle);
                      // gr.DrawImage(vRnQpicEx, x,y+(lineHeight-size.cy) div 2, size.cx, size.cy);
                      // gr.Free;
                      cnv.Unlock;
                      // cnv.draw(x,y+(lineHeight-size.cy) div 2, vRnQPic);
                    end;
                  end;
                end;
                if Assigned(vRnQpicEx) then
                  vRnQpicEx.Free;
                vRnQpicEx := NIL;
                inc(chunkStart);
                inc(X, size.cx);
                FreeAndNil(RnQPicStream);
                // Draw Button
                { newLine(x, y);
                  newLineHeight( 21+1);
                  r:=rect(x,y,x+90,y+21);
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
              // end;
              // freeAndNil(vRnQPic);
            end;
          _wrap:
            begin
              newLine(X, Y);
              lastLineStart := i;
            end;
        end; // case
        whatFound := _nothing;
      end;
    end; // while
    if Assigned(RnQPicStream) then
      FreeAndNil(RnQPicStream);

    newLine(X, Y);
    result := Y - pTop;
    ev.HistoryToken := history.Token;
    ev.PaintHeight := result;
    if eventFullyPainted and (i > len) and (Y <= bottomLimit) then
    begin
      eventFullyPainted := true;
      exit;
    end;
    // downward arrows
    vPicElm.ThemeToken := -1;
    vPicElm.picName := PIC_SCROLL_DOWN;
    vPicElm.Element := RQteDefault;
    with theme.GetPicSize(vPicElm) do
    begin
      X := margin.left;
      Y := bottomLimit - cy;
      if not JustCalc then
      begin
        r := rect(X, Y, rightLimit, Y + cy);
        while (Nitems > 0) and Types.intersectRect(intersect, items[Nitems - 1].r, r) do
          dec(Nitems);
        addItem(PK_ARROWS_DN, 0, 0, r);
        pt.Y := Y;
        pt.X := X;
        hnd := cnv.Handle;
        while pt.X < rightLimit do
        begin
          theme.drawPic(hnd, pt, vPicElm);
          inc(pt.X, cx);
        end;
      end;
      vPicElm.ThemeToken := -1;
      inc(Y, cy);
    end;
  end; // drawBody

// function drawHeader(cnv: Tcanvas; pTop : Integer) : Integer;
  function drawHeader(pTop: integer): integer;
  var
    curX, curY, LeftX: integer;
    sA: RawByteString;
    b: Byte;
    st: Byte;
    sz: TSize;
    s: String;
  begin
    lineHeight := 0;
    curX := margin.left;
    curY := pTop;
    // cnv.brush.color := TextBGColor;
    // c := ev.who;
    // shall we paint the header as selected?
    if not JustCalc then
      if wholeEventsAreSelected and within(SOS.evIdx, evIdx, EOS.evIdx) then
        cnv.brush.color := selectedClr
      else
        SetBKMode(cnv.Handle, TRANSPARENT);
    /// draw header

    with ev.PicSize do
    begin
      if not JustCalc then
        ev.Draw(cnv.Handle, curX, curY);
      inc(curX, cx + 3);
      newLineHeight(cy);
    end;

    if IF_Encrypt and ev.flags > 0 then // Сообщение было шифрованным
      with theme.GetPicSize(vKeyPicElm) do
      begin
        if not JustCalc then
          theme.drawPic(cnv.Handle, Types.Point(curX, curY), vKeyPicElm);
        inc(curX, cx + 3);
        newLineHeight(cy);
      end;
    // cnv.font.assign(ev.font);
    // cnv.font.Assign(Screen.MenuFont);
    // ev.applyfont(cnv.font);
    cnv.font.Assign(ev.getFont);
    applyUserCharset(cnv.font);
    // newLineHeight('I');
    s := 'I';
    GetTextExtentPoint32(cnv.Handle, PChar(s), length(s), sz);
    newLineHeight(sz.cy + 1);
    if not JustCalc then
    begin
      // ts := ev.getHeaderText;
      // cnv.textOut(curX, curY + 1, ts);
      cnv.textOut(curX, curY + (lineHeight - sz.cy) + 1 - Round(lineHeight / 10), ev.getHeaderText);
      curX := cnv.penpos.X;

      // some events draws an extra icon on the right
      case ev.kind of
        EK_INCOMING, EK_STATUSCHANGE:
          begin
            // sa := ev.binfo;
            sA := ev.getBodyBin;
            if length(sA) >= 4 then
            begin
              // vPicName := status2imgName(Tstatus(str2int(s)), (length(s)>4) and boolean(s[5]));
              // statusDrawExt(cnv.Handle, curX+2, curY, Tstatus(str2int(s)), (length(s)>4) and boolean(s[5]), infoToXStatus(s))
              st := str2int(sA);
              if st in [Byte(Low(Account.AccProto.statuses)) .. Byte(High(Account.AccProto.statuses))] then
              begin
                b := infoToXStatus(sA);
                // if (not XStatusAsMain) and (st <> SC_ONLINE)and (b>0) then
                if (st <> Byte(SC_ONLINE)) or (not XStatusAsMain) or (b = 0) then
                  with statusDrawExt(cnv.Handle, curX + 2, curY, st, (length(sA) > 4) and boolean(sA[5])) do
                    inc(curX, cx + 2);

                // with statusDrawExt(cnv.Handle, curX+2, curY, Tstatus(str2int(s)), (length(s)>4) and boolean(s[5])) do
                if (b > 0) then
                  inc(curX, theme.drawPic(cnv.Handle, curX + 2, curY, XStatusArray[b].picName).cx + 2);
              end;
            end;
          end;
        EK_XstatusMsg:
          begin
            // sa := ev.binfo;
            sA := ev.getBodyBin;
            if length(sA) >= 1 then
              if (Byte(sA[1]) <= High(XStatusArray)) then
                inc(curX, theme.drawPic(cnv.Handle, curX + 2, curY, XStatusArray[Byte(sA[1])].picName).cx);
            // statusDrawExt(cnv.Handle, x+2,y, SC_UNK, false, ord(s[1]));
            // statusDrawExt(cnv.Handle, curX+2, curY, Tstatus(str2int(s), false, ord(s[1]));
            // vPicName := status2imgName(Tstatus(str2int(s)), (length(s)>4) and boolean(s[5]));
          end;
        EK_OUTGOING:
          statusDrawExt(cnv.Handle, curX + 2, curY, Byte(SC_OFFLINE));
        // vPicName := status2imgName(SC_OFFLINE);
      end;
    end;

    if not JustCalc then
    begin
      addItem(PK_HEAD, -1, 0, rect(margin.left, curY, curX, curY + lineHeight));
      LeftX := curX;
    end;
    inc(lineHeight);
    newLine(curX, curY);
    // underline
    if not JustCalc then
    begin
      cnv.pen.color := selectedClr;
      cnv.moveTo(margin.left - 3, curY - 1);
      cnv.lineTo(LeftX, curY - 1);
    end;
    inc(curY, 3);

    result := curY - pTop;
  end; // drawHeader

var
  i, ii: integer;
  // gr : TGPGraphics;
  // dc : HDC;
  hls: Thls;
  Y: integer;
  tempS: String;
  lGapBtwMsg: Integer;
  vFullR: Trect;
  smlRefresh: boolean;
  ch: AnsiChar;
{$IFDEF UNICODE}
  // chU : Char;
  sA: AnsiString;
{$ENDIF UNICODE}
begin
  if ((Self.Width <> lastWidth) // or(Self.Height <> lastHeight)
    ) or (history.ThemeToken <> theme.Token) or (history.SmilesToken <> theme.Token) then
  begin
    inc(history.fToken);
    history.ThemeToken := theme.Token;
    smlRefresh := history.SmilesToken <> theme.Token;
    history.SmilesToken := theme.Token;
    lastWidth := Self.Width;
    // lastHeight  := Self.Height;
  end;
  // finds all first characters of all smiles
  if smlRefresh or (firstCharactersForSmiles = []) then
  begin
    firstCharactersForSmiles := [];
    for i := 0 to theme.SmilesCount - 1 do
      // if theme.GetSmile(i)<>NIL then //smiles.pics[i]<>NIL then
      with theme.GetSmileObj(i) do
        for ii := 0 to SmlStr.Count - 1 do
        begin
{$IFDEF UNICODE}
          sA := SmlStr.Strings[ii][1];
          ch := sA[1];
{$ELSE nonUNICODE}
          ch := SmlStr.Strings[ii][1];
{$ENDIF UNICODE}
          include(firstCharactersForSmiles, ch); // smiles.ascii[i][1]);
        end;
  end;
  // vCnvHandle := cnv.Handle;
  vFullR := cnv.ClipRect;
  if (vR.Right - vR.left = 0) or (vR.Bottom - vR.Top = 0) then
    exit;
  // vCnvHandle := Cnv.Handle;
  if not JustCalc then
  begin
    theme.ClearAniParams;
    SetBKMode(cnv.Handle, TRANSPARENT);
    // end;
    // if not JustCalc then
    // begin
    // if (vR.Left =0) and (vR.Top =0)and
    // (vR.Right > 0)and(vR.Bottom > 0)  then
    // begin
{$IFDEF RNQ_FULL}
    if Assigned(theme.AnibgPic) and (theme.AnibgPic.Width = vFullR.Right) and (theme.AnibgPic.Height = vFullR.Bottom) and
      (history.ThemeToken = lastBGToken) and (not UseContactThemes or (Self.who = lastBGCnt)) then
      BitBlt(cnv.Handle, vR.left, vR.Top, vR.Right - vR.left, vR.Bottom - vR.Top, theme.AnibgPic.canvas.Handle, vR.left,
        vR.Top, SRCCOPY)
      // BitBlt(cnv.Handle, 0, 0, vFullR.Right, vFullR.Bottom,
      // rqSmiles.AnibgPic.Canvas.Handle, 0, 0, SRCCOPY)
    else
    begin
      lastBGCnt := Self.who;
      lastBGToken := history.ThemeToken;
      // if (vR.Right > rqSmiles.AnibgPic.Width)
      // or (vR.Bottom > rqSmiles.AnibgPic.Height) then
      // begin
      // if Assigned(rqSmiles.AnibgPic) then
      // rqSmiles.AnibgPic.Free;
      // rqSmiles.AnibgPic := NIL;
      // rqSmiles.AnibgPic := createBitmap(vR.Right, vR.Bottom);
      // end;
{$ENDIF RNQ_FULL}
      DoBackground(cnv, vR, theme.AnibgPic);
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
  P_lastEventIsFullyVisible := false;
  P_bottomEvent := -1;

  { cnv.FillRect(margin);

    if not avoidErase then cnv.fillRect(clientRect);

  }
  if topVisible < offset then
  begin
    // if co then
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
      if l > 0.5 then
        l := l - 0.2
      else
        l := l + 0.2;
    selectedClr := hls2color(hls);
  end;
  // if selectedClr = TextBGColor then
  // selectedClr := clMenuHighlight;
  margin := rect(5, 5, 5, 5);
  mouse := screenToClient(mousePos);

  rightLimit := clientWidth - margin.Right;
  bottomLimit := clientHeight - margin.Bottom - 2;
  tempS := theme.GetString('history.gap-between-messages');
  lGapBtwMsg := bound(StrToIntDef(tempS, 13), 0, 30);
  // bottomLimit := vR.Bottom - vr.Top-margin.bottom - 10;
  Y := margin.Top;
  evIdx := topVisible;
  foundLink.id := 0;
  Nrows := 0;
  if not JustCalc then
    P_topEventNrows := 0;
  firstEvent := true;
  skippedLines := 0;
  pleaseDontDrawUpwardArrows := false;
  while (Y < bottomLimit) and (evIdx < history.Count) do
  begin
    ev := history.getAt(evIdx);
    if ev = nil then
    begin
      inc(evIdx);
      continue;
    end;
    foundLink.ev := ev;
    foundLink.evIdx := evIdx;
    eventFullyPainted := false;
    bodySkipCounter := 0;
    // s:=ev.getHeaderText;
    if ev.kind = EK_GCARD then
{$IFDEF DB_ENABLED}
      linkTheWholeBody := ev.txt
{$ELSE ~DB_ENABLED}
      linkTheWholeBody := ev.decrittedInfo
{$ENDIF ~DB_ENABLED}
    else
      linkTheWholeBody := '';
    // inc(y, drawHeader(cnv1, y));
    inc(Y, drawHeader(Y));
    // if there is enough space for the body
    if Y < bottomLimit then
    begin
      // gets the text to be painted
      // s:=ev.getBodyText;
      // eventFullyPainted:= s='';
      if startWithLastLine and firstEvent then
      begin
        pleaseDontDrawUpwardArrows := true;
        topOfs := maxInt;
        inc(Y, drawBody(Y));
        pleaseDontDrawUpwardArrows := false;
        topOfs := skippedLines - 1;
      end;
      // if s = '' then
      if not ev.isHasBody then
        eventFullyPainted := Y < bottomLimit
      else
        inc(Y, drawBody(Y));
      inc(y, lGapBtwMsg);
    end;
    inc(evIdx);
    if not JustCalc then
      if firstEvent then
        P_topEventNrows := Nrows - 1;
    firstEvent := false;
  end; // while
  P_bottomEvent := evIdx - 1;
  P_lastEventIsFullyVisible := eventFullyPainted and (evIdx = history.Count);
  if not JustCalc then
  begin
    setLength(items, Nitems);
    updatePointedItem();
  end;
end; // paintOn

*)

function ThistoryBox.getSelText(): string;
begin
//  addJScode('getQuote();', 'copy');
//  execJS('copy');
  result := '';
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
  addJScode('chatScrollToBottom();', 'scrolling');
  execJS('scrolling');
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
  addJScode('setSelection(' + inttostr(from) + ', ' + inttostr(to_) + ');', 'selection');
  execJS('selection');
end; // select

procedure ThistoryBox.deselect();
begin
  startSel.ev := nil;
  startSel.evIdx := -1;
  isWholeEvents := False;
  addJScode('clearSelection();', 'selection');
  execJS('selection');
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
    inc(offset);
  addChatItem(ev, evIdx, True);
  execJS('events');

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
    addJScode('setAutoScrollState(true);', 'scrolling')
  else
    addJScode('setAutoScrollState(false);', 'scrolling');
  execJS('scrolling');
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
//         fromString(loadFile(userPath+historyPath + ch.who.uid));
         load(who);
//         str := GetStream(userPath+historyPath + ch.who.uid);
//         fromSteam(str);
//         str.Free;
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
  Scroll();
  updateRSB(false, 0, True);
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
//  pe : TRnQThemedElementDtls;
  picStr: String;
  idx: Integer;
begin
  idx := history.IndexOf(hev);
//  pe.picName := hev.pic;
//  pe.ThemeToken := -1;
//  theme.initPic(pe);
  theme.GetPicOrigin(RQteDefault, hev.pic, evPicSpriteName, evPicRect);
  picStr := '[ ''' + evPicSpriteName + ''', ' + inttostr(-evPicRect.X) + ', ' + inttostr(-evPicRect.Y) + ', ' + inttostr(evPicRect.Width) + ', ' + inttostr(evPicRect.Height) + ' ]';
  addJScode('updateMsgStatus(' + IntToStr(idx) + ', ' + picStr + ');', 'msgstatus');
  execJS('msgstatus');
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

procedure ThistoryBox.LoadEnd(Sender: TObject; const browser: ICefBrowser; const frame: ICefFrame; httpStatusCode: Integer);
begin
  if not (frame = nil) and frame.IsMain then
    templateLoaded := True;
end;

procedure ThistoryBox.LoadError(Sender: TObject; const browser: ICefBrowser; const frame: ICefFrame; errorCode: Integer; const errorText, failedUrl: ustring);
begin
end;

procedure ThistoryBox.LoadStart(Sender: TObject; const browser: ICefBrowser; const frame: ICefFrame);
begin
end;

procedure ThistoryBox.SetFocus(Sender: TObject; const browser: ICefBrowser; source: TCefFocusSource; out Result: Boolean);
begin
  Result := True;
  OutputDebugString(PChar('SetFocus'));
end;

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

procedure ThistoryBox.CreateBrowserInstance;
begin
  Self.CreateBrowser;
end;

procedure ThistoryBox.LoadTemplate;
begin
  Browser.MainFrame.LoadString(template.text, 'about:blank');
end;

procedure ThistoryBox.ClearTemplate;
begin
  addJScode('clearEvents();', 'events');
  execJS('events');
end;

procedure ThistoryBox.RefreshTemplate;
begin
  RememberScrollPos;
  InitSmiles;
  ReloadLast;
  RestoreScrollPos;
end;

procedure ThistoryBox.ManualRepaint;
begin
  RefreshTemplate;
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
//          smileRect := theme.GetPicRect(RQteDefault, smileObj.SmlStr[0]);
          theme.GetPicOrigin(RQteDefault, smileObj.SmlStr[0], pic, smileRect);
          smiles := smiles + '''' + escapeQuotes(smileObj.SmlStr[0]) + ''': [ ''n' + IntToStr(i) + ''', ' +
          IntToStr(smileRect.Width) + ', ' + IntToStr(smileRect.Height);
          if smileObj.SmlStr.Count > 1 then
            for j := 1 to smileObj.SmlStr.Count - 1 do
              smiles := smiles + ', ''' + escapeQuotes(smileObj.SmlStr[j]) + '''';
          smiles := smiles +  ' ],';
        end;
      end;
      delete(smiles, length(smiles), 1);
    end;
  smiles := smiles +  ' }';
  addJScode('initSmiles(' + smiles + ');');
  execJS;
end;

procedure ThistoryBox.RememberScrollPos;
begin
  addJScode('chatRememberScrollPos();', 'scrolling');
  execJS('scrolling');
end;

procedure ThistoryBox.RestoreScrollPos;
begin
  addJScode('chatRestoreScrollPos();', 'scrolling');
  execJS('scrolling');
end;

function LooksLikeALink(link: String): Boolean;
begin
  Result := StartsText('http://', link) or StartsText('https://', link) or StartsText('www.', link);
end;

procedure ThistoryBox.addChatItem(hev: Thevent; evIdx: Integer; animate: Boolean);
var
  codeStr, msgText, bodyText, bodyImages, cachedLinks: String;
  evPicRect,
  cryptPicRect,
  statusImg1Rect, statusImg2Rect: TGPRect;
  evPicSpriteName,
  cryptPicSpriteName,
  statusImg1PicName, statusImg2PicName,
  statusImg1PicSpriteName, statusImg2PicSpriteName: TPicName;
  hdr: THeventHeader;
  st: Integer;
  b: Byte;
  sA: RawByteString;
  inv: Boolean;
  imgList: TAnsiStringList;
  linkList: TStringDynArray;
  bodyBin: RawByteString;
  i: Integer;
begin
  if hev = nil then
    Exit;

  hdr := hev.getHeader;
  msgText := hev.getBodyText;
  bodyText := escapeNewlines(escapeQuotes(msgText));
  theme.GetPicOrigin(RQteDefault, hev.pic, evPicSpriteName, evPicRect);
  theme.GetPicOrigin(RQteDefault, vKeyPicElm.picName, cryptPicSpriteName, cryptPicRect);
//  evPicRect := theme.GetPicRect(RQteDefault, hev.pic);
//  evPicSpriteName := theme.GetPicSprite(RQteDefault, hev.pic);
//  cryptPicRect := theme.GetPicRect(RQteDefault, vKeyPicElm.picName);
//  cryptPicSpriteName := theme.GetPicSprite(RQteDefault, vKeyPicElm.picName);

  bodyBin := hev.getBodyBin;
  bodyImages := 'false';
  if length(bodyBin) > 0 then
  begin
    imgList := TAnsiStringList.Create;
    parseMsgImages(bodyBin, imgList);
    if imgList.Count > 0 then
    begin
      bodyImages := '[';
      for i := 0 to imgList.Count - 1 do
      begin
        if i > 0 then
        bodyImages := bodyImages + ', ';
        bodyImages := bodyImages + '''' + imgList.Strings[i] + '''';
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
        cachedLinks := cachedLinks + '[''' + linkList[i] + ''', ' +
        IntToStr(imgCacheInfo.ReadInteger(linkList[i], 'width', 50)) + ', ' +
        IntToStr(imgCacheInfo.ReadInteger(linkList[i], 'height', 50)) + ']';
      end;
      cachedLinks := cachedLinks + ']';
    end;
    if cachedLinks = '[]' then
      cachedLinks := 'false';
  end;

  codeStr := 'addEvent([''' + hdr.what + ''', ''' + hdr.date + ''', ''' + hdr.prefix + '''], ''' +
  bodyText + ''', ' + bodyImages + ', ' + cachedLinks + ', ' + IntToStr(evIdx) + ', ' +
  '[''' + evPicSpriteName + ''', ' + inttostr(-evPicRect.X) + ', ' + inttostr(-evPicRect.Y) + ', ' +
  inttostr(evPicRect.Width) + ', ' + inttostr(evPicRect.Height) + ']';

  if IF_Encrypt and hev.flags > 0 then
  codeStr := codeStr + ', ' +
  '[''' + cryptPicSpriteName + ''', ' + inttostr(-cryptPicRect.X) + ', ' + inttostr(-cryptPicRect.Y) + ', ' + inttostr(cryptPicRect.Width) + ', ' + inttostr(cryptPicRect.Height) + ']'
    else
  codeStr := codeStr + ', false';

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
    EK_offgoing:
    begin
      statusImg1PicName := status2imgName(Byte(SC_OFFLINE), False);
    end;
  end;

  if not (statusImg1PicName = '') then
  begin
    theme.GetPicOrigin(RQteDefault, statusImg1PicName, statusImg1PicSpriteName, statusImg1Rect);
    codeStr := codeStr + ', ' +
    '[''' + statusImg1PicSpriteName + ''', ' + inttostr(-statusImg1Rect.X) + ', ' + inttostr(-statusImg1Rect.Y) + ', ' + inttostr(statusImg1Rect.Width) + ', ' + inttostr(statusImg1Rect.Height) + ']'
  end else
    codeStr := codeStr + ', false';

  if not (statusImg2PicName = '') then
  begin
    theme.GetPicOrigin(RQteDefault, statusImg2PicName, statusImg2PicSpriteName, statusImg2Rect);
    codeStr := codeStr + ', ' +
    '[''' + statusImg2PicSpriteName + ''', ' + inttostr(-statusImg2Rect.X) + ', ' + inttostr(-statusImg2Rect.Y) + ', ' + inttostr(statusImg2Rect.Width) + ', ' + inttostr(statusImg2Rect.Height) + ']'
  end else
    codeStr := codeStr + ', false';

  if animate then
    codeStr := codeStr + ', true'
  else
    codeStr := codeStr + ', false';

  codeStr := codeStr + ');'#13#10;
  addJScode(codeStr, 'events');
end;

procedure ThistoryBox.addJScode(const code: string; const thread: string = 'default');
var
  prevCode: UTF8String;
begin
  prevCode := '';
  if jscode.ContainsKey(thread) then
    jscode.TryGetValue(thread, prevCode)
  else
    jscode.Add(thread, '');

  jscode.AddOrSetValue(thread, prevCode + UTF8String(code));
end;

function ThistoryBox.hasJScode(const thread: string = 'default'): Boolean;
var
  curCode: UTF8String;
begin
  curCode := '';
  if jscode.ContainsKey(thread) then
  jscode.TryGetValue(thread, curCode);

  Result := not (curCode = '');
end;

procedure ThistoryBox.execJS(const thread: string = 'default');
var
  execCode: UTF8String;
begin
  if jscode.ContainsKey(thread) then
  begin
    execCode := '';
    jscode.TryGetValue(thread, execCode);
    if not (execCode = '') then
      Browser.MainFrame.ExecuteJavaScript(execCode, 'about:blank', 0);
    jscode.AddOrSetValue(thread, '');
  end;
end;

procedure ThistoryBox.ReloadLast;
var
  evId, startId: Integer;
  evIcon: TIcon;
  iconStream: TMemoryStream;
  hev: Thevent;
begin
  ClearTemplate;
  Application.ProcessMessages;
  //Browser.SendProcessMessage(PID_RENDERER, TCefProcessMessageRef.New('visitdom'));

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

  for evId := startId to history.Count - 1 do
  begin
    hev := history.getAt(evId);
    if (BE_save in behaviour[hev.kind].trig) and (hev.flags and IF_not_save_hist = 0) then
      addChatItem(hev, evId, False);
  end;
  execJS('events');

  if fAutoScrollState < ASS_FULLDISABLED then
    addJScode('chatScrollToBottom();', 'scrolling');
  execJS('scrolling');
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
  DefaultURL := '';
  templateLoaded := False;
  tabStop := False;
  fAutoScrollState := ASS_FULLSCROLL;
  Color := clBtnFace;
  Options.BackgroundColor := $fff0f0f0;
  Options.ImageLoading := STATE_ENABLED;
  Options.Plugins := STATE_DISABLED;
  Options.WebSecurity := STATE_DISABLED;
  Options.ImageShrinkStandaloneToFit := STATE_ENABLED;
  OnLoadEnd := LoadEnd;
  OnLoadError := LoadError;
  OnLoadStart := LoadStart;
  OnSetFocus := SetFocus;
  topVisible := 0;
  offsetMsg := 0;
  offsetAll := 0;
  newSession := 0;
  whole := false;

  jscode := TDictionary<String, UTF8String>.Create;
  template := TStringList.Create;
  template.LoadFromFile(themesPath + 'template.htm');
end;

{ TExtension }

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
  hash: String;
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
    if theme.GetBigPic(RQteDefault, pic, origPic) then
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

    if theme.GetBigSmile(pic, origPic) then
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
    if LooksLikeALink(request.Url) then
    begin
      hash := imgCacheInfo.ReadString(request.Url, 'hash', '0');
      fn := myPath + 'Cache\Images\' + hash + '.' + imgCacheInfo.ReadString(request.Url, 'ext', 'jpg');
      cached := not (hash = '0') and FileExists(fn);

      if request.Method = 'HEAD' then
      begin
        if cached then
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
          fs := TFileStream.Create(fn, fmOpenRead);
          FDataStream.LoadFromStream(fs);
          SetStatus(200);
        except
          SetStatus(306);
        end;

        if Assigned(fs) then
          fs.Free;
      end;
    end
      else
    SetStatus(306);
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
        FStatusText := 'Cached';
        FMimeType := 'text/html';
      end;
    306:
      begin
        FStatus := 306;
        FStatusText := 'Not Cached';
        FMimeType := 'text/html';
      end;
  end;
end;

initialization

vKeyPicElm.ThemeToken := -1;
vKeyPicElm.picName := PIC_KEY;
vKeyPicElm.Element := RQteDefault;
vKeyPicElm.pEnabled := true;

finalization

end.
