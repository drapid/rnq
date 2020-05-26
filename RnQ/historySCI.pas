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
  Messages, StrUtils, System.UITypes, NetEncoding,
  System.Threading, System.Types, PerlRegEx,
  Menus, System.Actions, Vcl.ActnList,
  RDGlobal, history, RnQProtocol, events, Variants,
  Sciter, SciterApi, TiScriptApi, SciterNative, RnQZip;


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
    chatShowDevTools: TMenuItem;
    ActList1: TActionList;
    hAaddtoroaster: TAction;
    hAsaveas: TAction;
    hAdelete: TAction;
    hACopy: TAction;
    hASelectAll: TAction;
    hAViewInfo: TAction;
    hAShowSmiles: TAction;
    ShowStickers: TAction;
    hAShowDevTools: TAction;
    hAOpenChatWith: TAction;
    procedure histmenuPopup(Sender: TObject);
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
    function getCurrentHistBox: THistoryBox;
    procedure onTimer(hb: ThistoryBox);
    procedure addcontactAction(sender: Tobject);
    procedure showHistMenu(Sender: TObject; const Data: String; clickedTime: TDateTime; msgPreview, linkClicked, imgClicked: Boolean);
  end;


  TlinkKind = (LK_FTP, LK_EMAIL, LK_WWW, LK_UIN, LK_ED);
  THistSearchDirection = (hsdFromBegin, hsdAhead, hsdBack, hsdFromEnd);
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

  TVideoFormat = record
    url: String;
    quality: String;
    format: String;
    codecs: String;
    title: String;
  end;

  TParams = array of OleVariant;

  TLinkClickEvent = procedure(const Sender: TObject; const LinkHref: String; const LinkText: String) of object;
  TShowMenuEvent = procedure(Sender: TObject; const Data: String; clickedTime: TDateTime; msgPreview, linkClicked, imgClicked: Boolean) of object;
  TQuoteCallback = procedure(Sender: TObject; selected: String = ''; AddToInput: boolean = true) of object;
  TInputCallback = procedure(Sender: TObject; selected: String = '') of object;

//  PHistoryBox = ^THistoryBox;

  THistoryBox = class(TSciter)
   private
//    class var templateFile: String;
    class var templateZip: TZipFile;
   private
    //template: TStringList;
    // For History at all
    items: array of ThistoryItem;
//    P_lastEventIsFullyVisible: boolean;
//    P_topEventNrows, P_bottomEvent: integer;
    fAutoScrollState: TAutoScrollState; // auto scrolls along messages
    FOnScroll: TNotifyEvent;
    checkTask: ITask;

    // For Active History!
    lastTimeClick: TdateTime;
    justTriggeredAlink, dontTriggerLink, just2clicked: boolean;
    lastClickedItem, P_pointedSpace, P_pointedItem: ThistoryItem;
    linkToUnderline: ThistoryLink;
    FOnLinkClick: TLinkClickEvent;
    fOnShowMenu: TShowMenuEvent;
    FOnQuoteCallback: TQuoteCallback;
    FOnInputCallback: TInputCallback;

    procedure DoShowMenu(const Data: String; clickedTime: TDateTime; msgPreview, linkClicked, imgClicked: Boolean);
    procedure DoSendQuote(const selected: String = ''; AddToInput: boolean = true);
    procedure DoSendInput(const text: String);
  protected
    function  getAutoScroll: boolean;
    procedure setAutoScroll(asState: TAutoScrollState);
    procedure setAutoScrollForce(vAS: boolean);
  public
    selectedText: String;
//    topVisible: TDateTime;
//    topOfs: integer;
//    offset, offsetAll: integer; // can't show hevents before this
    startSel, endSel: ThistoryPos;
    hasEvents, isWholeEvents: Boolean;
    who: TRnQContact;
    history: Thistory;
    margin: Trect;
    onPainted: TNotifyEvent;
    w2s: String;
    clickedItem: TChatItem;
    //templateLoaded: Boolean;
    embeddedImgs: TDictionary<LongWord, RawByteString>;

//    property lastEventIsFullyVisible: boolean read P_lastEventIsFullyVisible;
//    property pointedItem: ThistoryItem read P_pointedItem;
//    property clickedItem: ThistoryItem read lastClickedItem;
//    property pointedSpace: ThistoryItem read P_pointedSpace;
//    property topEventNrows: integer read P_topEventNrows;
//    property bottomEvent: integer read P_bottomEvent;
    property autoScrollVal: boolean read getAutoScroll write setAutoScrollForce;
    property OnScroll: TNotifyEvent read FOnScroll write FOnScroll;
    property onLinkClick: TLinkClickEvent read FOnLinkClick write FOnLinkClick;
    property OnShowMenu: TShowMenuEvent read fOnShowMenu write fOnShowMenu;
    property onQuoteCallback: TQuoteCallback read FOnQuoteCallback write FOnQuoteCallback;
    property onInputCallback: TInputCallback read FOnInputCallback write FOnInputCallback;

    function escapeQuotes(const text: String): String;

    procedure LoadTemplate(msgPreview: Boolean = False);

    class function  PreLoadTemplate: Boolean;
    class procedure UnLoadTemplate;
    procedure InitFunctions;
    procedure LoadEntireHistory;
    procedure ClearEvents;
    procedure DeleteEvents(st, en: TDateTime);
//    procedure ReloadLast;
    procedure InitSettings;
    procedure InitSettingsOnce;
    procedure InitSettingsMsgPreview;
    procedure InitAll;
    procedure InitSmiles;
    procedure UpdateSmiles;
    procedure RememberScrollPos;
    procedure RestoreScrollPos;
    procedure AddChatItem(var params: TParams; hev: Thevent; animate: Boolean);
    procedure SendChatItems(params: TParams; prepend: Boolean = False);
    procedure RememberTopEvent;
    procedure RestoreTopEvent;
    procedure HideLoadingScreen;
    procedure HideHistory;
    procedure ShowLimitWarning;
    procedure ViewInWindow(const title, body: String; const when: String; const formicon: String = '');
    procedure CheckServerHistory;
    procedure ShowServerHistoryNotif;

    procedure ShowDebug;

//    constructor Create(AOwner: Tcomponent; cnt: TRnQContact); override;
    constructor Create(AOwner: Tcomponent; cnt: TRnQContact); OverLoad;
    destructor  Destroy; override;
    procedure move2start();
    procedure move2end(animate: Boolean = False);
    function  moveToTime(time: TDateTime; NeedOpen: Boolean = false; fast: Boolean = False): Boolean;

    function  search(text: String; dir: THistSearchDirection; caseSens: Boolean; useRE: Boolean): Boolean;
    procedure copySel2Clpb;
    function  getSelText: String;
    function  getSelBin(): AnsiString;
    function  getSelHtml(smiles: boolean): String;
    function  somethingIsSelected(): boolean;
    function  wholeEventsAreSelected(): boolean;
    function  nothingIsSelected(): boolean;
    function  partialTextIsSelected(): boolean;
    function  getWhole: Boolean;
    function  AllowShowAll: Boolean;

    procedure select(from, to_: TDateTime);
    procedure deselect;
    procedure selectAll;
    procedure DeleteSelected;

//    procedure updateRSB(SetPos: boolean; pos: integer = 0; doRedraw: boolean = true);
    procedure addEvent(ev: Thevent);
//    function  historyNowCount: integer;
    procedure histScrollEvent(d: integer);
    procedure histScrollLine(d: integer);
    procedure doOnScroll;
    procedure histScrollWheel(d: integer);
    function  getQuoteByIdx(var pQuoteIdx: integer): String;
    procedure requestQuote;
    procedure updateMsgStatus(hev: Thevent);
    procedure InitRequest(ASender: TObject; const url: WideString; resType: SciterResourceType; requestId: Pointer; out discard: Boolean; out delay: Boolean);

    function ParseMessageBody(body: String): String;
    procedure ReplaceSmileMatch(Sender: TObject; var ReplaceWith: PCREString);
    procedure ReplaceOtherMatch(Sender: TObject; var ReplaceWith: PCREString);
    function GetReplacement(args: TStringDynArray): PCREString;
    function ReplaceEmoji(const msg: String): String;
    procedure updateGraphics;

    procedure ReturnFocus(Sender: TObject);
    property  Color;
    property  whole: Boolean read getWhole;
  end;

  TRequestHandler = class
  private
    FHistoryBox: THistoryBox;
    FDataStream: TMemoryStream;
  protected
    procedure ProcessRequest(ASender: TObject; const url: WideString; resType: SciterResourceType; requestId: Pointer; out discard: Boolean; out delay: Boolean);
    procedure CheckAnimatedGifSize(var ms: TMemoryStream);
  public
    constructor Create(Sender: ThistoryBox);
    destructor Destroy; override;
  end;

  TWinBehavior = class(TElement)
  protected
    procedure DoScriptingCall(const Args: TElementOnScriptingCallArgs); override;
  public
    class function BehaviorName: AnsiString; override;
  end;

var
  hisBGColor, myBGColor: TColor;
//  renderInit: Boolean = False;

var
  HistoryData: THistoryData;

implementation

{$R *.dfm}

uses
  clipbrd, math,
  JSON, VarUtils,
{$IFDEF UNICODE}
  Character,
  AnsiStrings, AnsiClasses,
{$ENDIF UNICODE}
  RDFileUtil,
  RnQSysUtils, RnQLangs, RnQFileUtil, RDUtils, RnQBinUtils,
  RQUtil, RQThemes, RnQButtons, RnQGlobal, RnQCrypt, RnQPics, RnQNet,
  globalLib, mainDlg, utilLib, Protocols_all,
  RnQConst,
//  chatDlg,
  ViewPicDimmedDlg, ViewHEventDlg,
  roasterLib,
  // historyRnQ,
  Base64,
  ICQConsts, ICQv9, RQ_ICQ,
{$IFDEF USE_GDIPLUS}
  RnQGraphics,
{$ELSE}
  RnQGraphics32,
{$ENDIF USE_GDIPLUS}
  themesLib, menusUnit, Murmur2;

var
//  lastBGCnt: TRnQContact;
//  lastBGToken: integer;
  vKeyPicElm: TRnQThemedElementDtls;

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
end; // color2html

function ThistoryBox.getSelHtml(smiles: boolean): String;
const
  HTMLTemplate = AnsiString('<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"' + CRLF +
    '"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">' + CRLF + CRLF +
    '<html>' + CRLF + '<head>' + CRLF +
    '  <title>%TITLE%</title>' + CRLF +
    // '  <meta http-equiv="Content-Type" content="text/html; charset=windows-1251"/>' + CRLF +
    '  <meta http-equiv="Content-Type" content="text/html; charset=UTF8"/>' + CRLF +

    '  <style type="text/css">' + CRLF + CRLF +
    // ' %HOSTS%' + CRLF + CRLF+
    ' %BODY%' + CRLF + CRLF +
    ' %HOST%' + CRLF + CRLF +
    ' %GUEST%' + CRLF +
    '  </style>' + CRLF +

    '</head>' + CRLF +
    '<body>' + CRLF +

    ' %CONTENT% ' + CRLF +

    '</body>' + CRLF +
    '</html>');
var
  SOS, EOS: ThistoryPos;
  st, en, i, dim: integer;
  ev: Thevent;
  Content: RawByteString;
  HTMLElement: RawByteString;

  Host, Guest: String;
  HostUIN, GuestUIN: TUID;
  EvHost, EvGuest: Thevent;

  procedure addStr(s: RawByteString);
  begin
    while dim + length(s) > length(Content) do
      setLength(Content, length(Content) + 10000);
    system.move(s[1], Content[dim + 1], length(s));
    inc(dim, length(s));
  end;

  function makeElement(uin: TUID; font: TFont; isMy: Boolean): String;
  begin
    result := '   .uin' + uin + ' {' + CRLF +
              '     color: #333;' + CRLF;
    result := result + '     font-family: "Segoe UI";' + CRLF;
    result := result + '     font-size: 14px;' + CRLF;
    if fsBold in font.Style then
      result := result + '     font-weight: 500;';
    if fsItalic in font.Style then
      result := result + '     text-decoration: italic;';
    if fsUnderline in font.Style then
      result := result + '     text-decoration: underline;';
    result := result + '   }' + CRLF;
    result := result + '   .uin' + uin + ' .title {' + CRLF;
    if isMy then
      result := result + '     color: #283593;' + CRLF
    else
      result := result + '     color: #844103;' + CRLF;
    result := result + '   }';
//             +CRLF;
  end;

var
  fnt: TFont;
  tmp: String;
begin
  result := '';
  dim := 0;
(*
  fnt := TFont.Create;
  fnt.Assign(Self.canvas.Font);

  if (startSel.when = 0) or (endSel.when = 0) then
    Exit;

  if CompareDateTime(endSel.when, startSel.when) >= 0 then
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
  st := history.getIdxBeforeTime(SOS.when, False);
  en := history.getIdxBeforeTime(EOS.when, False);
  for i := st to en do
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

    tmp := AnsiString(CRLF + '<div class="uin' + ev.who.UID2cmp + '"><u class="title">');
    if not (ev.kind = EK_msg) then
      tmp := tmp + StrToUTF8('[' + getTranslation(event2ShowStr[ev.kind]) + '] ');
    tmp := tmp + StrToUTF8(datetimeToStr(ev.when) + ', ' +
                 ev.who.displayed + '</u>' + '<br/>' +
                 str2html2(ev.getBodyText) + '</div>');
    addStr(tmp);
  end;
  setLength(Content, dim);
  //Content := StringReplace(Content, '&', '&amp;', [rfReplaceAll]);

  // %TITLE%
  HTMLElement := StrToUTF8(getTranslation('History between [%s] and [%s]', [Host, Guest]));
  Result := StringReplace(HTMLTemplate, AnsiString('%TITLE%'), HTMLElement, []);

  // %BODY%
  HTMLElement := '    body {' + CRLF +
                 '      background-color: ' + color2html(theme.GetColor(ClrHistBG, clWindow)) + ';' + CRLF +
                 '    }' + CRLF +
                 '    div {' + CRLF +
                 '      margin-top: 5px' + CRLF +
                 '    }' + CRLF;
  Result := StringReplace(Result, AnsiString('%BODY%'), HTMLElement, []);

  // %HOST%
  if Host > '' then
  begin
    fnt.Assign(Screen.MenuFont);
    EvHost.applyFont(fnt);
    HTMLElement := makeElement(HostUIN, fnt, True);
  end else
    HTMLElement := '';
  Result := StringReplace(Result, AnsiString('%HOST%'), HTMLElement, []);

  // %GUEST%
  if Guest > '' then
  begin
    fnt.Assign(Screen.MenuFont);
    EvGuest.applyFont(fnt);
    HTMLElement := makeElement(GuestUIN, fnt, False)
  end else
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
*)
end;

procedure ThistoryBox.move2start();
begin
  Call('scrollToTop', []);
end;

procedure ThistoryBox.move2end(animate: Boolean = False);
begin
  Call('scrollToBottom', [animate]);
end;

function ThistoryBox.moveToTime(time: TDateTime; NeedOpen: Boolean = false; fast: Boolean = False): Boolean;
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
//  result := search(offset) >= 0;
  result := search(0) >= 0;
  f.Create;
  f.DecimalSeparator := '.';
  Call('moveToTime', [floattostr(time, f), fast]);
end;

function ThistoryBox.search(text: String; dir: THistSearchDirection; caseSens: Boolean; useRE: Boolean): Boolean;
(*var
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
         chatFrm.autoscrollBtn.down := autoScrollVal;
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
*)
begin
  result := False;
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
  args: array of Variant;
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

procedure ThistoryBox.deselect();
begin
  startSel.ev := nil;
  isWholeEvents := False;
  Call('clearSelection', []);
end; // deselect

procedure ThistoryBox.selectAll();
begin
//  select(topVisible, history.getAt(history.count - 1).when);
  Call('selectAll', []);
end;

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



procedure ThistoryBox.addEvent(ev: Thevent);
var
  evIdx: Integer;
  params: TParams;
begin
  evIdx := history.add(ev);
{  inc(offsetAll);
  if (BE_save in behaviour[ev.kind].trig) and (ev.flags and IF_not_save_hist = 0) then
    inc(offset);}
  addChatItem(params, ev, True);
  sendChatItems(params);

  // if autoScroll and (not not2go2end or P_lastEventIsFullyVisible) then
  if (fAutoScrollState = ASS_FULLSCROLL) then //or ((fAutoScrollState = ASS_ENABLENOTSCROLL) and P_lastEventIsFullyVisible) then
  begin
    move2end;
    begin
      // not2go2end := False;
      setAutoScroll(ASS_FULLSCROLL);
//      topOfs := 0;
    end;
  end;

end;

function ThistoryBox.getAutoScroll: boolean;
begin
  // result := fAutoScrollState < ASS_FULLDISABLED;
  // result := fAutoScrollState = ASS_FULLSCROLL;
  result := (fAutoScrollState = ASS_FULLSCROLL) //or ((fAutoScrollState = ASS_ENABLENOTSCROLL) and P_lastEventIsFullyVisible);
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
  Call('setAutoscrollState', [asState = ASS_FULLSCROLL]);
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
//  if vAS then
//    topOfs := 0;
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
      move2end;
end;

procedure ThistoryBox.DoOnScroll;
begin
  if Assigned(FOnScroll) then
    FOnScroll(Self);
end;

procedure ThistoryBox.updateGraphics;
begin
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
//  Call('updateMsgStatus', [evPic]);
  FireRoot($101, evPic);
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

procedure ThistoryBox.DoShowMenu(const Data: String; clickedTime: TDateTime; msgPreview, linkClicked, imgClicked: Boolean);
begin
  if Assigned(fOnShowMenu) then
    fOnShowMenu(Self, data, clickedTime, msgPreview, linkClicked, imgClicked);
end;

procedure ThistoryBox.DoSendQuote(const selected: String = ''; AddToInput: boolean = true);
begin
  if Assigned(FOnQuoteCallback) then
    FOnQuoteCallback(Self, selected, AddToInput);
end;

procedure ThistoryBox.DoSendInput(const text: String);
begin
  if Assigned(FOnInputCallback) then
    FOnInputCallback(Self, text);
end;

//function LoadHistory(vm: HVM): tiscript_value; cdecl;
function LoadHistory(vm: HVM; self: tiscript_value; tag: Pointer): tiscript_value; cdecl;
const
  msgLimit = 5000;
var
//  ch: TchatInfo;
  numOfDays, evId, startId, endId: Integer;
  hev: Thevent;
  topTime: Double;
  params: TParams;
  histObj: tiscript_value;
  hb: THistoryBox;
  limitReached: Boolean;
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

    if numOfDays < -1 then
    begin
      startId := history.Count + numOfDays;
      endId := history.Count - 1;
    end else if numOfDays < 0 then
    begin
      startId := 0;
//      endId := history.Count - 1;
      endId := history.getIdxBeforeTime(topTime);
    end
      else
    begin
      startId := history.getIdxBeforeTime(floor(topTime - numOfDays), False);
      endId := history.getIdxBeforeTime(topTime);
    end;

    limitReached := False;
    RememberTopEvent;
    if endId - startId > msgLimit then
    begin
      startId := endId - msgLimit;
      limitReached := True;
    end;
    if endId >= startId then
    for evId := startId to endId do
    begin
      hev := history.getAt(evId);
      if not (hev = nil) then
      if (BE_save in behaviour[hev.kind].trig) and (hev.flags and IF_not_save_hist = 0) then
      begin
        addChatItem(params, hev, False);//, evId = endId);
//        if length(params) = 1 then
//          topVisible := hev.when;
        hasEvents := True;
//        FreeAndNil(events[evId]);
      end;
    end;

    if Length(params) > 0 then
    try
      SendChatItems(params, True);
    finally
      RestoreTopEvent;
    end;

    if limitReached then
      ShowLimitWarning
    else if (startId <= 0) or (history.Count = 0) then
      HideHistory;
    HideLoadingScreen;
  end;
end;


//function UpdateSelection(vm: HVM): tiscript_value; cdecl;
function UpdateSelection(vm: HVM; self: tiscript_value; tag: Pointer): tiscript_value; cdecl;
var
  text, sOfs, eOfs: PWideChar;
  sOfsT, eOfsT: TDateTime;
  strLen: UINT;
  isWhole: Bool;
  ffs: TFormatSettings;
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

    NI.get_string_value(NI.get_arg_n(vm, 3), sOfs, strLen);
    NI.get_string_value(NI.get_arg_n(vm, 4), eOfs, strLen);
    NI.get_bool_value(NI.get_arg_n(vm, 5), isWhole);

    ffs := TFormatSettings.Create(LOCALE_USER_DEFAULT);
    ffs.DecimalSeparator := '.';
    sOfsT := StrToFloat(sOfs, ffs);
    eOfsT := StrToFloat(eOfs, ffs);

    with hb do
    if (sOfsT <= 0) or (eOfsT <= 0) then
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
      startSel.ev := history.getByTime(sOfsT);
      endSel.ofs := -1;
      endSel.ev := history.getByTime(eOfsT);
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
    hb.DoSendQuote(text, true)
  end;
end;

function SendInput(vm: HVM; self: tiscript_value; tag: Pointer): tiscript_value; cdecl;
var
  text: PWideChar;
  strLen: UINT;
begin
  if tag = nil then
    Exit;

  if (NI.get_arg_count(vm) > 2) then
  begin
    NI.get_string_value(NI.get_arg_n(vm, 2), text, strLen);
    ThistoryBox(tag).DoSendInput(text)
  end;
end;

//function OpenChatMenu(vm: HVM): tiscript_value; cdecl;
function OpenChatMenu(vm: HVM; self: tiscript_value; tag: Pointer): tiscript_value; cdecl;
var
  clickedTime, data: PWideChar;
  strLen: UINT;
  msgPreview, linkClicked, imgClicked: LongBool;
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
    msgPreview := False;
    linkClicked := False;
    imgClicked := False;
    NI.get_string_value(NI.get_arg_n(vm, 2), data, strLen);
    NI.get_string_value(NI.get_arg_n(vm, 3), clickedTime, strLen);
    NI.get_bool_value(NI.get_arg_n(vm, 4), msgPreview);
    NI.get_bool_value(NI.get_arg_n(vm, 5), linkClicked);
    NI.get_bool_value(NI.get_arg_n(vm, 6), imgClicked);
    f.DecimalSeparator := '.';
    hb.DoShowMenu(data, StrToFloat(clickedTime, f), msgPreview, linkClicked, imgClicked);
  end;
end;

function GetServerHistory(vm: HVM; self: tiscript_value; tag: Pointer): tiscript_value; cdecl;
begin
  if tag = nil then
    Exit;

  {$IFDEF ICQ_REST_API}
  with THistoryBox(tag) do
  begin
    TICQSession(who.fProto).getServerHistory(who.UID);
    LoadTemplate;
    CheckServerHistory;
  end;
  {$ENDIF ICQ_REST_API}
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

function GetTrans(vm: HVM): tiscript_value; cdecl;
var
  strData: PWideChar;
  itemLen: UINT;
begin
  if (NI.get_arg_count(vm) = 3) then
  begin
    NI.get_string_value(NI.get_arg_n(vm, 2), strData, itemLen);
    strData := PWideChar(getTranslation(strData));
    Result := NI.string_value(vm, strData, Length(strData));
  end;
end;

function GetTranslations(vm: HVM): tiscript_value; cdecl;
var
  arrSize, i: Integer;
  arr: tiscript_value;
  strData: PWideChar;
  tstrData: String;
  itemLen: UINT;
begin
  arr := NI.get_arg_n(vm, 2);
  arrSize := NI.get_array_size(vm, arr);
  for i := 0 to arrSize - 1 do
  if NI.get_string_value(NI.get_elem(vm, arr, i), strData, itemLen) then
  begin
    tstrData := getTranslation(strData);
    NI.set_elem(vm, arr, i, NI.string_value(vm, PWideChar(tstrData), length(tstrData)));
  end;
  Result := arr;
end;

function UploadLastSnapshot(vm: HVM; self: tiscript_value): tiscript_value; cdecl;
begin
{
  if Assigned(chatFrm) then
  begin
    chatFrm.FileUpload(False, cacheDir + 'snapshot.png');
    DeleteFile(cacheDir + 'snapshot.png');
  end;
}
end;

function TrimNewLines(vm: HVM; self: tiscript_value): tiscript_value; cdecl;
var
  str: PWideChar;
  strLen: UINT;
begin
  if (NI.get_arg_count(vm) > 2) then
  begin
{    if TrimMsgNewLines then
    begin
      NI.get_string_value(NI.get_arg_n(vm, 2), str, strLen);
      str := PWideChar(String(str).Trim([#13, #10]));
      Result := NI.string_value(vm, str, Length(str));
    end else }
      Result := NI.get_arg_n(vm, 2);
  end;
end;

function DecodeURL(url: String): String;
begin
  Result := TEncoding.UTF8.GetString(TNetEncoding.URL.DecodeStringToBytes(url));
end;

function DecodeFormat(format: String): String;
begin
  format := DecodeURL(format);
  if format.Contains('video/mp4')  then
    Result := 'MP4'
  else if format.Contains('video/webm') then
    Result := 'WEBM'
  else if format.Contains('video/x-flv') then
    Result := 'FLV'
  else if format.Contains('video/3gpp') then
    Result := '3GPP';
end;

function GetYoutubeLinks(vm: HVM; self: tiscript_value): tiscript_value; cdecl;
var
  ytlink: PWideChar;
  ytpage, yturl, yttitle, anchor: RawByteString;
  ytmap, ytitem: TStringList;
  ytfmts: TDictionary<Integer, TVideoFormat>;
  ytfmt: TVideoFormat;
  strLen: UINT;
  fs: TMemoryStream;
  i, j, p, arrsize: Integer;
  ignore3GPP: Boolean;
  tmp: String;
  PreferredResolution: Integer;
begin
  arrsize := 0;
  Result := NI.create_array(vm, arrsize);
  ytlink := '';

  if (NI.get_arg_count(vm) > 2) then
  NI.get_string_value(NI.get_arg_n(vm, 2), ytlink, strLen);

  if ytlink = '' then
    Exit;

  fs := TMemoryStream.Create;
  LoadFromUrl(ytlink, fs);
  SetLength(ytpage, fs.Size);
  fs.ReadBuffer(ytpage[1], fs.Size);
  fs.Free;

  anchor := 'url_encoded_fmt_stream_map":"';
  i := pos(anchor, ytpage);
  if i = 0 then
    Exit;
  yturl := copy(ytpage, i + length(anchor));
  yturl := copy(yturl, 1, pos('"', yturl) - 1);

  anchor := 'property="og:title" content="';
  yttitle := copy(ytpage, pos(anchor, ytpage) + length(anchor));
  yttitle := copy(yttitle, 1, pos('"', yttitle) - 1);
  yttitle := DecodeURL(UTF8ToStr(yttitle));

  ytmap := TStringList.Create;
  ytmap.Delimiter := ',';
  ytmap.DelimitedText := yturl;
  ytmap.StrictDelimiter := true;
  ytmap.Sorted := False;

  ytitem := TStringList.Create;
  ytitem.Delimiter := '|';
  ytitem.StrictDelimiter := true;
  ytitem.Sorted := False;

  ytfmts := TDictionary<Integer, TVideoFormat>.Create();

  for i := 0 to ytmap.Count - 1 do
  begin
    ytitem.Clear;
    ytitem.DelimitedText := ytmap.Strings[i].Replace('\u0026', '|');
    ytfmt := Default(TVideoFormat);
    for j := 0 to ytitem.Count - 1 do
    begin
      if ytitem.Strings[j].StartsWith('url=') then
        ytfmt.url := copy(ytitem.Strings[j], 5)
      else if ytitem.Strings[j].StartsWith('quality=') then
        ytfmt.quality := copy(ytitem.Strings[j], 9)
      else if ytitem.Strings[j].StartsWith('type=') then
      begin
        tmp := copy(ytitem.Strings[j], 6);
        p := pos('%3B+', tmp);
        if p > 0 then
        begin
          ytfmt.format := copy(tmp, 1, p - 1);
          ytfmt.codecs := copy(tmp, p + 4).Replace('codecs%3D', '').Replace('%22', '');
        end else
          ytfmt.format := tmp;
      end
    end;
    ytfmts.Add(i, ytfmt);
  end;

  ignore3GPP := False;
  MainPrefs.getPrefInt('chat-video-preferred-resolution', PreferredResolution);
  for i := 0 to ytfmts.Count - 1 do
  begin
    ytfmts.TryGetValue(i, ytfmt);
    if ((PreferredResolution = 0) and ytfmt.quality.Contains('1080'))
    or ((PreferredResolution = 1) and (ytfmt.quality.Contains('720') or ytfmt.quality.Contains('hd')))
    or ((PreferredResolution = 2) and ytfmt.quality.Contains('medium'))
    or ((PreferredResolution = 3) and ytfmt.quality.Contains('small')) then
    begin
      if ytfmt.format.Contains('video%2F3gpp') and ignore3GPP then
        continue;
      //OutputDebugString(PChar('Preferred: ' + ytfmt.quality + ', ' + ytfmt.format));
      ytlink := PWideChar('{"format":"' + DecodeFormat(ytfmt.format) + '","codecs":"' + DecodeURL(ytfmt.codecs) + '","title":"' + yttitle + '","url":"' + DecodeURL(ytfmt.url) + '"}');
      inc(arrsize);
      NI.set_array_size(vm, Result, arrsize);
      NI.set_elem(vm, Result, arrsize - 1, NI.string_value(vm, ytlink, Length(ytlink)));
      if ytfmt.format.Contains('video%2F3gpp') then
        ignore3GPP := True;
    end;
  end;
  if NI.get_array_size(vm, Result) = 0 then
  begin
    ytfmts.TryGetValue(0, ytfmt);
    //OutputDebugString(PChar('No preferred: ' + ytfmt.quality + ', ' + ytfmt.format));
    ytlink := PWideChar('{"format":"' + DecodeFormat(ytfmt.format) + '","codecs":"' + DecodeURL(ytfmt.codecs) + '","title":"' + yttitle + '","url":"' + DecodeURL(ytfmt.url) + '"}');
    NI.set_array_size(vm, Result, 1);
    NI.set_elem(vm, Result, 0, NI.string_value(vm, ytlink, Length(ytlink)));
  end;
end;

function GetVimeoLinks(vm: HVM; self: tiscript_value): tiscript_value; cdecl;
var
  vmlink: PWideChar;
  vmpage, vmurl, vmtitle, anchor: RawByteString;
  vmmap: TJSONArray;
  vmfmts: TDictionary<Integer, TVideoFormat>;
  vmfmt: TVideoFormat;
  strLen: UINT;
  fs: TMemoryStream;
  i, arrsize: Integer;
  JSONObject: TJSONObject;
  PreferredResolution: Integer;
begin
  arrsize := 0;
  Result := NI.create_array(vm, arrsize);
  vmlink := '';

  if (NI.get_arg_count(vm) > 2) then
  NI.get_string_value(NI.get_arg_n(vm, 2), vmlink, strLen);

  if vmlink = '' then
    Exit;

  fs := TMemoryStream.Create;
  LoadFromUrl(vmlink, fs);
  SetLength(vmpage, fs.Size);
  fs.ReadBuffer(vmpage[1], fs.Size);

  anchor := 'config_url":"';
  i := pos(anchor, vmpage);
  if i = 0 then
    Exit;
  vmurl := copy(vmpage, i + length(anchor));
  vmurl := copy(vmurl, 1, pos('"', vmurl) - 1);
  vmurl := String(DecodeURL(vmurl)).Replace('\/', '/');

  anchor := 'property="og:title" content="';
  vmtitle := copy(vmpage, pos(anchor, vmpage) + length(anchor));
  vmtitle := copy(vmtitle, 1, pos('"', vmtitle) - 1);
  vmtitle := DecodeURL(UTF8ToStr(vmtitle));

  fs.Clear;
  LoadFromUrl(vmurl, fs);
  SetLength(vmpage, fs.Size);
  fs.ReadBuffer(vmpage[1], fs.Size);
  fs.Free;

  vmfmts := TDictionary<Integer, TVideoFormat>.Create();
  JSONObject := TJSONObject.ParseJSONValue(vmpage) as TJSONObject;
  if Assigned(JSONObject) then
  try
    vmmap := (((JSONObject.GetValue('request') as TJSONObject).GetValue('files') as TJSONObject).GetValue('progressive') as TJSONArray);
    for i := 0 to vmmap.Count - 1 do
    begin
      vmfmt.url := (vmmap.Items[i] as TJSONObject).GetValue('url').Value;
      vmfmt.quality := (vmmap.Items[i] as TJSONObject).GetValue('quality').Value;
      vmfmt.format := (vmmap.Items[i] as TJSONObject).GetValue('mime').Value;
      vmfmts.Add(i, vmfmt);
    end;
  except end;

  if vmfmts.Count > 0 then
   begin
    MainPrefs.getPrefInt('chat-video-preferred-resolution', PreferredResolution);
    for i := 0 to vmfmts.Count - 1 do
    begin
      vmfmts.TryGetValue(i, vmfmt);
      if ((PreferredResolution = 0) and (vmfmt.quality = '1080p'))
      or ((PreferredResolution = 1) and (vmfmt.quality = '720p'))
      or ((PreferredResolution = 2) and (vmfmt.quality = '540p'))
      or ((PreferredResolution = 3) and (vmfmt.quality = '360p')) then
      begin
        //OutputDebugString(PChar('Preferred: ' + vmfmt.quality + ', ' + vmfmt.format));
        vmlink := PWideChar('{"format":"' + DecodeFormat(vmfmt.format) + '","codecs":"","title":"' + vmtitle + '","url":"' + DecodeURL(vmfmt.url) + '"}');
        inc(arrsize);
        NI.set_array_size(vm, Result, arrsize);
        NI.set_elem(vm, Result, arrsize - 1, NI.string_value(vm, vmlink, Length(vmlink)));
      end;
    end;
   end;
  if NI.get_array_size(vm, Result) = 0 then
  begin
    vmfmts.TryGetValue(0, vmfmt);
    //OutputDebugString(PChar('No preferred: ' + vmfmt.quality + ', ' + vmfmt.format));
    vmlink := PWideChar('{"format":"' + DecodeFormat(vmfmt.format) + '","codecs":"","title":"' + vmtitle + '","url":"' + DecodeURL(vmfmt.url) + '"}');
    NI.set_array_size(vm, Result, 1);
    NI.set_elem(vm, Result, 0, NI.string_value(vm, vmlink, Length(vmlink)));
  end;
end;

function GetVolumeLevel(vm: HVM; self: tiscript_value): tiscript_value; cdecl;
var
  level: String;
  leveldb: Double;
begin
  MainPrefs.getPrefStr('chat-video-volume-level', level);
  if TryStrToFloat(level, leveldb) then
    Result := NI.float_value(leveldb)
  else
    Result := NI.float_value(0.85); // Volume 50%
end;

function SaveVolumeLevel(vm: HVM; self: tiscript_value): tiscript_value; cdecl;
var
  level: Double;
begin
  level := 0;
  if (NI.get_arg_count(vm) > 2) then
  NI.get_float_value(NI.get_arg_n(vm, 2), level);
  MainPrefs.addPrefStr('chat-video-volume-level', FloatToStr(level));
end;

function DetectFileFormat(vm: HVM): tiscript_value; cdecl;
var
  pb: System.PByte;
  pblen: UINT;
  str: TMemoryStream;
  strData: PWideChar;
begin
  if (NI.get_arg_count(vm) = 3) then
  begin
    NI.get_bytes(NI.get_arg_n(vm, 2), pb, pblen);
    str := TMemoryStream.Create;
    str.Write(pb^, pblen);
    case DetectFileFormatStream(str) of
      PA_FORMAT_BMP: strData := 'BMP';
      PA_FORMAT_JPEG: strData := 'JPEG';
      PA_FORMAT_PNG: strData := 'PNG';
      PA_FORMAT_TIF: strData := 'TIFF';
      PA_FORMAT_WEBP: strData := 'WEBP';
      PA_FORMAT_GIF: strData := 'GIF';
      PA_FORMAT_ICO: strData := 'ICO';
      PA_FORMAT_UNK: strData := '';
    end;
    Result := NI.string_value(vm, strData, Length(strData));
  end;
end;

procedure ThistoryBox.InitFunctions;
var
  ns: tiscript_value;
begin
  SciterRegisterBehavior(TWinBehavior);
  API.SciterGetElementNamespace(Self.Root.Handle, ns);
  RegisterNativeFunctionTag('LoadHistory', @LoadHistory, ns, Pointer(Self));
  RegisterNativeFunctionTag('UpdateSelection', @UpdateSelection, ns, Pointer(Self));
  RegisterNativeFunctionTag('SendQuote', @SendQuote, ns, Pointer(Self));
  RegisterNativeFunctionTag('SendInput', @SendInput, ns, Pointer(Self));
  RegisterNativeFunctionTag('OpenChatMenu', @OpenChatMenu, ns, Pointer(Self));
  RegisterNativeFunctionTag('GetServerHistory', @GetServerHistory, ns, Pointer(Self));
  RegisterNativeFunction('GetYoutubeLinks', @GetYoutubeLinks);
  RegisterNativeFunction('GetVimeoLinks', @GetVimeoLinks);
  RegisterNativeFunction('GetVolumeLevel', @GetVolumeLevel);
  RegisterNativeFunction('SaveVolumeLevel', @SaveVolumeLevel);
  RegisterNativeFunction('ShowPreview', @ShowPreview);
  RegisterNativeFunction('GetTranslation', @GetTrans);
  RegisterNativeFunction('DetectFileFormat', @DetectFileFormat);
  RegisterNativeFunction('UploadLastSnapshot', @UploadLastSnapshot);
  RegisterNativeFunction('TrimNewLines', @TrimNewLines);
end;

procedure ThistoryBox.LoadTemplate(msgPreview: Boolean = False);
var
 fn: String;
begin
  fn := themesPath + 'template.zip';
  if not FileExists(fn) then
    msgDlg(getTranslation('Chat template not found at "%s"', [fn]), false, mtError)
   else
    begin
//      LoadHtml(templateFile, 'template');
//      LoadURL(FilePathToURL(myPath + 'Themes\template.zip#template.htm'));
      LoadURL(FilePathToURL(fn + '#template.htm'));

      InitFunctions;

      InitSettings;
      if msgPreview then
        InitSettingsMsgPreview
       else
        InitSettingsOnce;
      InitSmiles;
    end;
end;

procedure ThistoryBox.LoadEntireHistory;
begin
  Call('loadAll', []);
end;

class function ThistoryBox.PreLoadTemplate: Boolean;
var
 fn: String;
 t: RawByteString;
begin
//  Result := templateFile > '';
  Result := templateZip <> NIL;
  if Result then
    Exit;
//  fn := themesPath + 'template.htm';
  fn := themesPath + 'template.zip';
  if not FileExists(fn) then
    msgDlg(getTranslation('Chat template not found at "%s"', [fn]), false, mtError)
   else
    begin
//      t := loadFileA(fn);
//      templateFile := unutf(t);
//      templateFile := t;
      templateZip := TZipFile.Create;
      templateZip.LoadFromFile(fn);
      result := templateZip.Count > 0;
//      LoadURL(FilePathToURL(fn));
    end;
end;

class procedure ThistoryBox.UnLoadTemplate;
begin
  if Assigned(templateZip) then
    freeAndNil(templateZip);
end;


procedure ThistoryBox.ClearEvents;
begin
  Call('clearEvents', []);
end;

procedure ThistoryBox.DeleteEvents(st, en: TDateTime);
var
  ffs: TFormatSettings;
begin
  ffs := TFormatSettings.Create(LOCALE_USER_DEFAULT);
  ffs.DecimalSeparator := '.';
  Call('deleteEvents', [floattostr(st, ffs), floattostr(en, ffs)]);
end;

procedure ThistoryBox.InitSettings;
var
  args: array of OleVariant;
  LimitMaxChatImgWidth,
  LimitMaxChatImgHeight : Boolean;
  ChatSmoothFontRendering : Boolean;
  isUseCntThemes: boolean;
  uidBG, grpBG: TPicName;
  cacheDir: String;
  tmp: String;
begin
  SetLength(args, 18);
  args[0] := autocopyHist;
  args[1] := useSmiles;
  args[2] := wheelVelocity;
  args[3] := //ChatImageQuality;
             MainPrefs.getPrefIntDef('chat-images-resample-preset', 0);

  ChatSmoothFontRendering := MainPrefs.getPrefBoolDef('chat-font-rendering', True);
  args[4] := ChatSmoothFontRendering;

  LimitMaxChatImgWidth := MainPrefs.getPrefBoolDef('chat-images-limit-width', True);
  LimitMaxChatImgHeight := MainPrefs.getPrefBoolDef('chat-images-limit-height', True);

  if LimitMaxChatImgWidth then
    args[5] := MainPrefs.getPrefIntDef('chat-images-width-value', 512)
  else
    args[5] := 0;

  if LimitMaxChatImgHeight then
    args[6] := MainPrefs.getPrefIntDef('chat-images-height-value', 512)
  else
    args[6] := 0;

//  args[6] := EnableImgLinksIn;
//  args[7] := EnableImgLinksOut;
  args[7] := MainPrefs.getPrefBoolDef('chat-parse-image-links-in', True);
  args[8] := MainPrefs.getPrefBoolDef('chat-parse-image-links-out', True);
  args[9] := FontStyleCodes.Enabled;

  isUseCntThemes := UseContactThemes and Assigned(ContactsTheme) and Assigned(who);
  if isUseCntThemes then
  begin
    uidBG := TPicName(LowerCase(who.UID2cmp)) + '.' + PIC_CHAT_BG;
    grpBG := TPicName('group.') + TPicName(AnsiLowerCase(groups.id2name(who.group))) + '.' + PIC_CHAT_BG;
  end;

  // Tiled background image
  args[10] := '';
  if isUseCntThemes and (ContactsTheme.GetPicSize(RQteDefault, uidBG + '5').cx > 0) then
    args[10] := 'contactpic:' + uidBG + '5'
  else if isUseCntThemes and (ContactsTheme.GetPicSize(RQteDefault, grpBG + '5').cx > 0) then
    args[10] := 'contactpic:' + grpBG + '5'
  else if theme.GetPicSize(RQteDefault, PIC_CHAT_BG + '5').cx > 0 then
    args[10] := 'themepic:' + PIC_CHAT_BG + '5';

  // Positioned background image
  args[11] := '';
  if isUseCntThemes then
  if ContactsTheme.GetPicSize(RQteDefault, uidBG + '1').cx > 0 then
    args[11] := 'contactpic:' + uidBG + '1'
  else if ContactsTheme.GetPicSize(RQteDefault, uidBG + '2').cx > 0 then
    args[11] := 'contactpic:' + uidBG + '2'
  else if ContactsTheme.GetPicSize(RQteDefault, uidBG + '3').cx > 0 then
    args[11] := 'contactpic:' + uidBG + '3'
  else if ContactsTheme.GetPicSize(RQteDefault, uidBG + '4').cx > 0 then
    args[11] := 'contactpic:' + uidBG + '4';

  if isUseCntThemes and (args[11] = '') then
  if ContactsTheme.GetPicSize(RQteDefault, grpBG + '1').cx > 0 then
    args[11] := 'contactpic:' + grpBG + '1'
  else if ContactsTheme.GetPicSize(RQteDefault, grpBG + '2').cx > 0 then
    args[11] := 'contactpic:' + grpBG + '2'
  else if ContactsTheme.GetPicSize(RQteDefault, grpBG + '3').cx > 0 then
    args[11] := 'contactpic:' + grpBG + '3'
  else if ContactsTheme.GetPicSize(RQteDefault, grpBG + '4').cx > 0 then
    args[11] := 'contactpic:' + grpBG + '4';

  if args[11] = '' then
  if theme.GetPicSize(RQteDefault, PIC_CHAT_BG + '1').cx > 0 then
    args[11] := 'themepic:' + PIC_CHAT_BG + '1'
  else if theme.GetPicSize(RQteDefault, PIC_CHAT_BG + '2').cx > 0 then
    args[11] := 'themepic:' + PIC_CHAT_BG + '2'
  else if theme.GetPicSize(RQteDefault, PIC_CHAT_BG + '3').cx > 0 then
    args[11] := 'themepic:' + PIC_CHAT_BG + '3'
  else if theme.GetPicSize(RQteDefault, PIC_CHAT_BG + '4').cx > 0 then
    args[11] := 'themepic:' + PIC_CHAT_BG + '4';

  cacheDir := ExtractFilePath(paramStr(0)) + 'Cache\';
  args[12] := FilePathToURL(cacheDir);

  args[13] := MainPrefs.getPrefBoolDef('chat-video-links-thumbnails', True);
  args[14] := MainPrefs.getPrefIntDef('chat-video-preferred-resolution', 0);

  try
    args[15] := 22;
    tmp := theme.GetString('emoji.size');
    if not (tmp = '') then
      args[15] := StrToInt(tmp);
  except
    args[15] := 22;
  end;
  try
    args[16] := 36;
    tmp := theme.GetString('emoji.inarow');
    if not (tmp = '') then
      args[16] := StrToInt(tmp);
  except
    args[16] := 36;
  end;

  args[17] := MainPrefs.getPrefBoolDef('hist-msg-view-wrap', True); // bViewTextWrap;

  try
    Call('initSettings', [args]);
  except
    on e: ESciterCallException do
      msgDlg('Error in InitSettings: ' + e.Message, false, mtError);
  end;
end;

procedure ThistoryBox.InitSettingsOnce;
var
  args: array of Variant;
begin
  SetLength(args, 1);
//  args[0] := ShowHistoryRanges;
  args[0] := MainPrefs.getPrefBoolDef('chat-history-auto-show', False);


  try
    Call('initSettingsOnce', args);
  except
    on e: ESciterCallException do
      msgDlg('Error in InitSettingsOnce: ' + e.Message, false, mtError);
  end;
end;

procedure ThistoryBox.InitSettingsMsgPreview;
var
  args: array of Variant;
begin
  SetLength(args, 1);
  args[0] := GetTranslation('Select message to render its full version here');

  try
    Call('initSettingsMsgPreview', args);
  except
    on e: ESciterCallException do
      msgDlg('Error in InitSettingsMsgPreview: ' + e.Message, false, mtError);
  end;
end;

procedure ThistoryBox.InitSmiles;
var
  i, j: Integer;
  smileObj: TSmlObj;
  smiles, content: String;
  smileRect: TGPRect;
  pic: TPicName;
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
//      InitFunctions;
end;

procedure ThistoryBox.UpdateSmiles;
begin
//  Call('updateSmiles', []);
  FireRoot($102);
end;

procedure ThistoryBox.RememberScrollPos;
begin
  Call('rememberScrollPos', []);
end;

procedure ThistoryBox.RestoreScrollPos;
begin
  Call('restoreScrollPos', []);

end;

procedure ThistoryBox.ShowDebug;
begin
  SetOption(SCITER_SET_DEBUG_MODE, UINT_PTR(True));
end;


function LooksLikeALink(link: String): Boolean;
begin
  Result := StartsText('http://', link) or StartsText('https://', link) or StartsText('www.', link);
end;

procedure ThistoryBox.AddChatItem(var params: TParams; hev: Thevent; animate: Boolean);
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
//  params[pos][11] := last;
end;

procedure ThistoryBox.SendChatItems(params: TParams; prepend: Boolean = False);
begin
  Call('addEvents', [params, prepend]);
end;

procedure ThistoryBox.RememberTopEvent;
begin
  Call('rememberTopEvent', []);
end;

procedure ThistoryBox.RestoreTopEvent;
begin
  Call('restoreTopEvent', []);
end;

procedure ThistoryBox.HideLoadingScreen;
begin
  Call('hideHistoryLoading', []);
end;

procedure ThistoryBox.HideHistory;
begin
  Call('hideHistory', []);
end;

procedure ThistoryBox.ShowLimitWarning;
begin
  Call('showLimitWarning', []);
end;

procedure ThistoryBox.ViewInWindow(const title, body: String; const when: String; const formicon: String = '');
begin
  Call('viewInWindow', [title, body, when, formicon]);
end;

{
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
    move2end;

  GC;
//QueryPerformanceCounter(StopCount);
//TimingSeconds := (StopCount - StartCount) / Freq;
//OutputDebugString(PChar(floattostr(TimingSeconds)));
end;
}

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
//  topVisible := 0;
//  offset := 0;
//  offsetAll := 0;

  embeddedImgs := TDictionary<LongWord, RawByteString>.Create;

  OnLoadData := InitRequest;
//  OnFocus := ReturnFocus;

//   history:=pTCE(c.data).history as Thistory;
   history := Thistory.create;
   history.Reset;

//   SetOption(SCITER_SET_DEBUG_MODE, UINT_PTR(True));
  SetOption(SCITER_SMOOTH_SCROLL, UINT_PTR(True));
//  SetOption(SCITER_SET_DEBUG_MODE, UINT_PTR(DevMode));

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

procedure ThistoryBox.CheckServerHistory;
begin
  {$IFDEF ICQ_REST_API}
  if Assigned(who) and Assigned(who.fProto) and who.fProto.isOnline then
  begin
    checkTask := TTask.Create(procedure
    begin
      Sleep(2000);
      if not (TTask.CurrentTask.Status = TTaskStatus.Canceled) and Assigned(who) and Assigned(who.fProto) then
      TThread.Queue(nil, procedure
      begin
        TICQSession(who.fProto).checkServerHistory(who.UID);
      end);
    end);
    checkTask.Start;
  end;
  {$ENDIF ICQ_REST_API}
end;

procedure ThistoryBox.ShowServerHistoryNotif;
begin
  FireRoot($103);
end;

procedure ThistoryBox.InitRequest(ASender: TObject; const url: WideString; resType: SciterResourceType; requestId: Pointer; out discard: Boolean; out delay: Boolean);
var
  handler: TRequestHandler;
begin
  handler := TRequestHandler.Create(Self);
  handler.ProcessRequest(ASender, url, resType, requestId, discard, delay);
end;

{ TRequestHandler }

constructor TRequestHandler.Create(Sender: ThistoryBox);
begin
  inherited Create;
  FHistoryBox := Sender;
  FDataStream := nil;
end;

destructor TRequestHandler.Destroy;
begin
  if Assigned(FDataStream) then
    FreeAndNil(FDataStream);
  inherited;
end;

procedure TRequestHandler.CheckAnimatedGifSize(var ms: TMemoryStream);
var
//  aGif: TGIFImage;
  sz: Single;
  FStreamFormat: TPAFormat;
begin
  FStreamFormat := DetectFileFormatStream(ms);
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

procedure TRequestHandler.ProcessRequest(ASender: TObject; const url: WideString; resType: SciterResourceType; requestId: Pointer; out discard: Boolean; out delay: Boolean);
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
  cached, isimg, check, ignore, async: Boolean;
begin
  ignore := False;
  async := False;
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
  end else if StartsText('contactpic:', url) and UseContactThemes and Assigned(ContactsTheme) then
  begin
    pic := copy(url, 12, length(url));
    origPic := nil;
    if ContactsTheme.GetBigPic(pic, origPic) then
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
    if Assigned(FHistoryBox) then
      FHistoryBox.DoShowMenu(url, 0, false, true, false);
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
  end else if StartsText('open:', url) then
  begin
    realurl := copy(url, 6, length(url));
{    if (realurl = 'search') and Assigned(chatFrm) then
      chatFrm.findBtn.Click;
}
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
      CheckAnimatedGifSize(FDataStream);
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
        async := True;
    end else
      ignore := True;
  end else
  begin
    FreeAndNil(FDataStream);
    discard := False;
    delay := False;
    Exit;
  end;


  if not ignore then
  begin
    if not async then
    begin
      delay := False;
      FDataStream.Seek(0, soFromBeginning);
      FHistoryBox.DataReady(url, FDataStream.Memory, FDataStream.Size);
    end
      else
    begin
      delay := True;
      TTask.Run(procedure()
      var
        ms: TMemoryStream;
        fs: TFileStream;
      begin
        if not cached then
          cached := DownloadAndCache(realurl);

        if cached then
        try
          fn := myPath + 'Cache\Images\' + imgCacheInfo.ReadString(realurl, 'hash', '0') + '.' + imgCacheInfo.ReadString(realurl, 'ext', 'jpg');
          fs := TFileStream.Create(fn, fmOpenRead);
          ms := TMemoryStream.Create;
          ms.LoadFromStream(fs);
          CheckAnimatedGifSize(ms);
          //TThread.Synchronize(nil, procedure begin
          FHistoryBox.DataReadyAsync(url, ms.Memory, ms.Size, requestId);
          //end);
        except end;

        if Assigned(fs) then
          FreeAndNil(fs);
        if Assigned(ms) then
          FreeAndNil(ms);
      end);
    end;
    discard := False;
  end else
    discard := True;

  FreeAndNil(FDataStream);
end;

class function TWinBehavior.BehaviorName: AnsiString;
begin
  Result := 'WinBehavior';
end;

procedure TWinBehavior.DoScriptingCall(const Args: TElementOnScriptingCallArgs);

  function TryVarAsType(AVariant: OleVariant; const AVarType: TVarType): Boolean;
  var
    SourceType: TVarType;
  begin
    SourceType := TVarData(AVariant).VType;
    if (AVarType and varTypeMask < varInt64) and (SourceType and varTypeMask < varInt64) then
      Result := (SourceType = AVarType) or (VariantChangeTypeEx(TVarData(AVariant), TVarData(AVariant), VAR_LOCALE_USER_DEFAULT, 0, AVarType) = VAR_OK)
    else
      Result := False;
  end;

var
  HIco: HIcon;
  Icon: TIcon;
  Pic: String;
begin
  if (Args.Method = 'SetFormIcon') and (Args.Element.GetHWND > 0) and (TryVarAsType(Args.Argument[0], varOleStr) or TryVarAsType(Args.Argument[0], varString)) then
  begin
    Icon := TIcon.Create;
    try
      Pic := String(Args.Argument[0]);
      if not (Pic = '') then
      begin
        theme.pic2ico(RQteFormIcon, Pic, Icon);
        HIco := Icon.Handle;
      end else
        HIco := Application.Icon.Handle;

      SendMessage(Args.Element.GetHWND, WM_SETICON, 0, HIco);
      SendMessage(Args.Element.GetHWND, WM_SETICON, 1, HIco);
    except
      Icon.Free;
    end;
    Args.Handled := True;
  end;
end;


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

function stripProtocol(const stringData: String): String;
begin
  if StartsText('uin:', stringData) then
    Result := copy(stringData, 5, length(stringData))
  else if StartsText('link:', stringData) then
    Result := copy(stringData, 6, length(stringData))
  else if StartsText('mailto:', stringData) then
    Result := copy(stringData, 8, length(stringData))
  else
    Result := stringData;
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

procedure THistoryData.showHistMenu(Sender: TObject; const Data: String; clickedTime: TDateTime; msgPreview, linkClicked, imgClicked: Boolean);
var
  hb: THistoryBox;
begin
  if not (Sender is THistoryBox) then
   Exit;
  hb := Sender as THistoryBox;

  hb.clickedItem.timeData := clickedTime;
  with hb do
  if linkClicked then
  begin
    clickedItem.kind := PK_LINK;
    clickedItem.stringData := Data;
  end else if imgClicked then
  begin
    if StartsText('embedded:', Data) then
      clickedItem.kind := PK_RQPIC
    else if StartsText('download:', Data) then
      clickedItem.kind := PK_RQPICEX;
    clickedItem.stringData := Data;
  end else
    clickedItem.kind := PK_NONE;

  del1.enabled := hb.wholeEventsAreSelected;
  saveas1.enabled := hb.somethingIsSelected;
  copy2clpb.visible := hb.somethingIsSelected;
  toantispam.visible := hb.somethingIsSelected;
  N2.visible := hb.somethingIsSelected;
  copylink2clpbd.visible := linkClicked;
  addlink2fav.visible := linkClicked and StartsText('url:', Data);
  savePicMnu.visible := imgClicked;
  ViewinfoM.visible := clickedTime > 0;
  viewmessageinwindow1.enabled := hb.somethingIsSelected or (clickedTime > 0);
  selectall1.enabled := hb.hasEvents;

  add2rstr.visible := linkClicked and StartsText('uin:', Data);
  if add2rstr.visible then
  try
    selectedUIN := copy(Data, 5, length(Data));
    addGroupsToMenu(Self, add2rstr, addcontactAction, not hb.who.fProto.isOnline
      or hb.who.fProto.canAddCntOutOfGroup); // false);
  except
    add2rstr.visible := false;
  end;

//  lastClickedItem := pointedItem;
//  popupHistmenu(MousePos.X, MousePos.Y);
  histmenu.popup(mousePos.X, mousePos.Y);
end;

initialization

vKeyPicElm.ThemeToken := -1;
vKeyPicElm.picName := PIC_KEY;
vKeyPicElm.Element := RQteDefault;
vKeyPicElm.pEnabled := true;

finalization

ThistoryBox.UnLoadTemplate;


end.
