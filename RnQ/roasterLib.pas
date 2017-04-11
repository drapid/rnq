{
  This file is part of R&Q.
  Under same license
}
unit roasterLib;
{$I RnQConfig.inc}
{$I NoRTTI.inc}

interface

uses
  classes, windows, stdctrls, graphics, VirtualTrees,
  chatDlg, RDGlobal, RnQPics,
  ThemesLib, RnQProtocol;

type
 {$IFDEF CHECK_INVIS}
  Tdivisor = (d_online, d_invis, d_offline, d_contacts, d_nil);
 {$ELSE}
  Tdivisor = (d_online, d_offline, d_contacts, d_nil);
 {$ENDIF}
const
 {$IFDEF CHECK_INVIS}
  divsWithGroups = [d_online, d_contacts, d_offline, d_invis];
  divisor2str: array [Tdivisor] of AnsiString = ('online', 'invisible', 'offline', 'contacts', 'not in list');
  divisor2ShowStr: array [Tdivisor] of string = ('Online', 'Invisible', 'Offline', 'Contacts', 'Not in list');
 {$ELSE}
  divsWithGroups = [d_online, d_contacts, d_offline];
  divisor2str: array [Tdivisor] of AnsiString = ('online', 'offline', 'contacts', 'not in list');
  divisor2ShowStr: array [Tdivisor] of string = ('Online', 'Offline', 'Contacts', 'Not in list');
 {$ENDIF}
  NODE_ROOT = 0;
  NODE_DIV = 1;
  NODE_GROUP = 2;
  NODE_CONTACT = 3;

type
  TRnQCLIconsSet = (CNT_ICON_VIS,
                    CNT_ICON_STS,
                    CNT_ICON_XSTS,
                    CNT_ICON_AUTH, CNT_ICON_LCL,
                    CNT_TEXT,
                    CNT_ICON_BIRTH, CNT_ICON_AVT, CNT_ICON_VER);

  TRnQCLIcons = record
//    IDX: Byte;
    idx: TRnQCLIconsSet;
    Name: String;
    IconName: TPicName;
    PrefText: AnsiString;
//    Cptn: String;
//    DefShortCut: String;
//    ev: procedure;
  end;
const
//  RnQCLIcons: array[0..6] of TRnQCLIcons = (
  RnQCLIcons: array[TRnQCLIconsSet] of TRnQCLIcons = (
  ( IDX: CNT_ICON_VIS;   Name:'I''m visible to'; IconName: PIC_VISIBLE_TO; PrefText : 'visibility-flag'),
  ( IDX: CNT_ICON_STS;   Name:'Status';          IconName: 'status.online'; PrefText : 'show-status'),
 {$IFDEF RNQ_FULL}
  ( IDX: CNT_ICON_XSTS;  Name:'XStatus';         IconName: 'st_custom.cigarette'; PrefText : 'show-xstatus-flag'),
 {$ENDIF RNQ_FULL}
  ( IDX: CNT_ICON_AUTH;  Name:'Not authorized';  IconName: PIC_AUTH_NEED; PrefText : 'show-need-auth-flag'),
  ( IDX: CNT_ICON_LCL;   Name:'Is local';        IconName: PIC_LOCAL; PrefText : 'show-is-local-flag'),
   ( IDX: CNT_TEXT;      Name:'Displayed';       IconName: PIC_INFO; PrefText: 'text'),
  ( IDX: CNT_ICON_BIRTH; Name:'Birthday baloon'; IconName: PIC_BIRTH; PrefText : 'show-birth-day-flag'),
  ( IDX: CNT_ICON_AVT;   Name:'Avatar';          IconName: 'avatar'; PrefText : 'show-avatar-flag'),
  ( IDX: CNT_ICON_VER;   Name:'IM icon';         IconName: PIC_RNQ; PrefText : 'show-client-flag')
  );

var
  SHOW_ICONS_ORDER: array[0.. Byte(High(TRnQCLIconsSet))] of TRnQCLIconsSet;
  TO_SHOW_ICON: array[TRnQCLIconsSet] of boolean;

type
  PNode = ^Tnode;
  Tnode = class
   public
    kind       : integer;
    contact    : TRnQcontact;
    divisor    : Tdivisor;
    groupId    : integer;
    textOfs    : integer;
    outboxRect : Trect;
    treenode   : PVirtualNode;
    order      : integer;
    constructor create(divisor_: Tdivisor); overload;
    constructor create(groupId_: integer; divisor_: Tdivisor); overload;
    constructor create(contact_: TRnQContact); overload;
    destructor Destroy; override;
    procedure setExpanded(val: boolean; recur: boolean=FALSE);
    function  isVisible: boolean;
    function  parent: Tnode;
    function  childrenCount: integer;
    function  firstChild: Tnode;
    function  expanded: boolean;
    function  level: integer;
    function  rect: Trect;
    function  next: Tnode;
    function  prev: Tnode;
  end;

function  contactsUnder(n: Tnode): integer;
procedure updateHiddenNodes;
procedure popup(x: integer=-1; y: integer=-1);
procedure popupOn(n: Tnode; x: integer=-1; y: integer=-1);
function  compareNodes(Node1, Node2: Tnode): integer;
function  str2divisor(const s: AnsiString): Tdivisor;
procedure rebuild;
procedure redraw; overload;
function  redraw(c: TRnQContact): boolean; overload;
function  redraw(n: Tnode): boolean; overload;
function  update(c: TRnQContact): boolean;
//function  exists(c: TRnQContact): boolean;
function  focus(c: TRnQContact): boolean; overload;
function  focus(n: Tnode): boolean; overload;
function  focus(tn: Pvirtualnode): boolean; overload;
function  focusTemp(n: Tnode): boolean;
//function  remove(c: Tcontact): boolean;
function  remove(c: TRnQContact): boolean;
procedure sort(c: TRnQContact); overload;
procedure sort(n: Tnode); overload;
procedure sort(tn: Pvirtualnode); overload;
procedure formresized;
function  onlineMaxY: integer;
function  fullMaxY: integer;
function  addGroup(const name: string): integer;
function  removeGroup(id: integer): boolean;
procedure edit(n: Tnode);
function  focused: Tnode;
function  focusedContact: TRnQContact;
procedure expand(n: Tnode);
procedure collapse(n: Tnode);
function  nodeAt(x, y: integer): Tnode;
procedure focusPrevious;
procedure clear;
procedure setOnlyOnline(v: boolean);
function  getNode(tn: Pvirtualnode): Tnode;
procedure setNewGroupFor(c: TRnQContact; grp: integer);
function  isUnderDiv(n: Tnode): Tdivisor;
//procedure filter(s: string);
  procedure RstrDrawNode(Sender: TBaseVirtualTree; const PaintInfo: TVTPaintInfo; const PPI: Integer);
  function  ICON_ORDER_PREF: RawByteString;
  procedure ICON_ORDER_PREF_parse(const str: RawByteString);

var
  building: boolean = FALSE;
  dragging: boolean = FALSE; // roster.dragging doesn't work
  inplace: record
    edit    : Tedit;
    what    : integer;
    contact : TRnQContact;
    groupId : integer;
    node    : Tnode;
   end;
  contactsPool: Tlist;
  expandedByTempFocus: Tnode;
  FilterTextBy: string;

 {$IFDEF USE_SECUREIM}
  useSecureIM: Boolean;
 {$ENDIF USE_SECUREIM}

implementation

uses
  UxTheme, DwmApi, Types, UITypes,
  RnQGraphics32, RQUtil, RQThemes,
  RnQStrings, RnQLangs, RDUtils, RnQSysUtils,
  mainDlg, sysutils, utilLib, RnQConst, globalLib,
 {$IFDEF PROTOCOL_ICQ}
  ICQv9, ICQContacts, ICQconsts, Protocol_ICQ,
 {$ENDIF PROTOCOL_ICQ}
  events,
 {$IFDEF USE_SECUREIM}
  cryptoppWrap,
 {$ENDIF USE_SECUREIM}
//  masks,
  StrUtils
  ;
var
  // declared globally to speedup the compare callback functions

  divs: array [Tdivisor] of Tnode;
  buildingOnline: boolean;

function Filtered(c: TRnQcontact): Boolean;
begin
  if FilterTextBy = '' then
   Result := False
  else
   if c = nil then
    Result := True
   else
    if (Pos(FilterTextBy, AnsiUpperCase(c.UID)) = 0) and
       (Pos(FilterTextBy, AnsiUpperCase(c.display)) = 0) and
       (Pos(FilterTextBy, AnsiUpperCase(c.nick)) = 0) and
       (Pos(FilterTextBy, AnsiUpperCase(c.first)) = 0) and
       (Pos(FilterTextBy, AnsiUpperCase(c.last)) = 0)
//       and(Pos(FilterTextBy, AnsiUpperCase(c.email)) = 0)
    then
{
    if (not MatchesMask(c.UID, FilterTextBy)) and
       (not MatchesMask(c.display, FilterTextBy)) and
       (not MatchesMask(c.nick, FilterTextBy)) and
       (not MatchesMask(c.first, FilterTextBy)) and
       (not MatchesMask(c.last, FilterTextBy)) and
       (not MatchesMask(c.email, FilterTextBy)) then
}
       result := True
     else
       result := False;
end;

function getNode(tn: Pvirtualnode): Tnode;
begin
  if tn=NIL then
    result := NIL
   else
    begin
     result := RnQmain.roster.getnodedata(tn);
     if result<>NIL then
       result := Tnode(pointer(result)^);
    end;
end; // getNode

function str2divisor(const s: AnsiString): Tdivisor;
begin
  for result:=low(result) to high(result) do
    if s = divisor2str[result] then
      exit;
  raise Exception.Create('str2divisor');
end; // str2divisor

procedure updateHiddenNode(n: Tnode);
begin
  if (n=NIL) or (n.treenode=NIL) then
   exit;
  RnQmain.roster.isVisible[n.treenode] := not showOnlyImVisibleTo or n.contact.imVisibleTo;
end; // updateHiddenNode

procedure updateHiddenNodes;
var
  i: integer;
begin
if (divs[d_offline]<>NIL) then
  RnQmain.roster.isVisible[divs[d_offline].treenode]:=not showOnlyOnline;
 {$IFDEF CHECK_INVIS}
if (divs[d_invis]<>NIL) then
  RnQmain.roster.isVisible[divs[d_invis].treenode]:=divs[d_invis].treenode.childcount>0;
 {$ENDIF}
for i:=0 to contactsPool.count-1 do
  updateHiddenNode(contactsPool[i]);
end; // updateHiddenNodes

function compareContacts(c1, c2: TRnQContact): integer;
var
  tmpB1, tmpB2: boolean;
  tmpT1, tmpT2: Tdatetime;
begin
  result := 0;
  if (c1=c2) or (c1=NIL) or (c2=NIL) then
    exit;
  if OnlOfflInOne then
   begin
{    tmpB1 := not c1.isOnline;
    tmpB2 := not c2.isOnline;
    if tmpb1  then
      Inc(result); //:=+1
    if tmpb2 then
      dec(result); //:=-1}
    if not c1.isOnline  then
      Inc(result); //:=+1
    if not c2.isOnline then
      dec(result); //:=-1}
   end;
  if Result <> 0 then
   Exit;
case sortBy of
  SB_alpha:
     result := compareText(c1.displayed, c2.displayed);
  SB_event:
    begin
      tmpT1 := TCE(c1.data^).lastMsgTime;
      tmpT2 := TCE(c2.data^).lastMsgTime;
    tmpB1 := TRUE;
    if (tmpT1 < startTime) and (tmpT2 < startTime) then
      if not(c1.isOnline or c2.isOnline) then
        begin
        tmpT1 := TCE(c1.data^).lastEventTime;
        tmpT2 := TCE(c2.data^).lastEventTime;
        if (tmpT1 < startTime) and (tmpT2 < startTime) then
          tmpB1 := FALSE
        end
      else
        tmpB1 := FALSE;

    if not tmpB1 then
      result := compareText(c1.displayed, c2.displayed)
    else
      if tmpT1 > tmpT2 then
        result := -1
       else
        if tmpT1 < tmpT2 then
          result := +1;
    end;
  SB_STATUS:
    begin
      if c1.fProto = c2.fProto then
       begin
        Result := c1.fProto.compareStatusFor(c1, c2);
        if Result = 0 then
          result := compareText(c1.displayed, c2.displayed);
       end
      else
       result := compareInt(cardinal(c1.fProto), cardinal(c2.fProto));
    end;
  else
    begin
    tmpB1 := c1.imVisibleTo;
    tmpB2 := c2.imVisibleTo;
    if tmpb1 and not tmpb2 then
      result := -1
     else
    if tmpb2 and not tmpb1 then
      result := +1
     else
      result := compareText(c1.displayed, c2.displayed);
    end;
  end;
end; // compareContacts

// this sort criteria is deeper than compareContacts one, sit has to think about groups and online status
function compareContacts4build(item1, item2: pointer): integer;
var
  tmpC1, tmpC2: TRnQContact;
  t1, t2: byte;
  tmpI1, tmpI2: integer;
begin
  result := 0;
  if (item1=item2) or (item1=NIL) or (item2=NIL) then
    exit;
  tmpC1 := TRnQContact(item1);
  tmpC2 := TRnQContact(item2);
  if tmpC1.isOnline then
    t1 := 3
   else
    if tmpC1.isOffline then
      t1 := 2
     else
      t1 := 1; 
  if tmpC2.isOnline then
    t2 := 3
   else
    if tmpC2.isOffline then
      t2 := 2
     else
      t2 := 1; 
// different sections?
if buildingOnline then
  if t1<>t2 then
    if t2>t1 then
      result := +1
     else
      result := -1;
{  case tmpC1.status of
    SC_UNK:
      case tmpC2.status of
        SC_OFFLINE: result:=+1;
        SC_UNK: ;
        else result:=+1;
        end;
    SC_OFFLINE:
      case tmpC2.status of
        SC_OFFLINE: ;
        SC_UNK: result:=-1;
        else result:=+1;
        end;
    else
      case tmpC2.status of
        SC_OFFLINE: result:=-1;
        SC_UNK: result:=-1;
        end;
    end;}
{  case t1 of
    1: //SC_UNK:
      case t2 of
        1: ;
        2: result:=+1;
        else result:=+1;
        end;
    2: //SC_OFFLINE:
      case t2 of
        1: result:=-1;
        2: ;
        else result:=+1;
        end;
    else
      case t2 of
        1: result:=-1;
        2: result:=-1;
        end;
    end;
}
if result<>0 then
  exit;
// different groups?
if showGroups and (tmpC1.group <> tmpC2.group) then
  begin
  if tmpC1.group = 0 then
    result := -1
  else
    if tmpC2.group = 0 then
      result := +1
    else
      begin
      tmpI1 := groups.get(tmpC1.group).order;
      tmpI2 := groups.get(tmpC2.group).order;
      if tmpI1=tmpI2 then
        result := compareText(groups.id2name(tmpC1.group), groups.id2name(tmpC2.group))
      else
        if tmpI1<tmpI2 then
          result := -1
         else
          result := +1;
      end;
  exit;
  end;
result := compareContacts(tmpC1, tmpC2);
end; // compareContacts4build

function compareNodes(Node1, Node2: Tnode): integer;
var
  l1, l2: Integer;
begin
  result := 0;
  if (node1=NIL) or (node2=NIL) or (node1=node2) then
    exit;
  l1 := node1.level;
  l2 := node2.level;
  if l1 < l2 then
    result := -1
   else
    if l1 > l2 then
     result := +1;
  if result<>0 then
    exit;
  if (node1.kind=node2.kind) and (node1.order<>node2.order) then
   begin
    if node1.order < node2.order then
      result := -1
     else
      result := +1;
    exit;
   end;
 case node1.kind of
  NODE_DIV:
    if node2.kind <> NODE_DIV then
      result := -1
     else
      result := compareInt(ord(node1.divisor),ord(node2.divisor));
  NODE_GROUP:
    case node2.kind of
      NODE_DIV: result := +1;
      NODE_CONTACT: result := +1;
      NODE_GROUP:
        result := compareText( groups.id2name(node1.groupId),
          groups.id2name(node2.groupId) );
      end;
  NODE_CONTACT:
    case node2.kind of
      NODE_DIV: result := +1;
      NODE_GROUP: result := -1;
      NODE_CONTACT: result := compareContacts(node1.contact, node2.contact);
      end;
  end;
end; // compareNodes

constructor Tnode.create(divisor_: Tdivisor);
begin
  inherited create;
  kind    := NODE_DIV;
  divisor := divisor_;
end; // create

constructor Tnode.create(groupId_: integer; divisor_: Tdivisor);
begin
  inherited create;
  kind    := NODE_GROUP;
  groupId := groupId_;
  divisor := divisor_;
end; // create

constructor Tnode.create(contact_: TRnQContact);
begin
  inherited create;
  kind    := NODE_CONTACT;
  contact := contact_;
  groupId := contact_.group;
  TCE(contact_.data^).node := self;
  contactsPool.add(self);
end; // create

destructor Tnode.Destroy;
begin
case kind of
  NODE_CONTACT:
    begin
    contactsPool.remove(self);
    TCE(contact.data^).node := NIL;
    end;
  NODE_GROUP: groups.a[groups.idxOf(groupId)].node[divisor]:=NIL;
  NODE_DIV: divs[divisor] := NIL;
  end;
inherited;
end; // destroy

function Tnode.parent: Tnode;
begin
  if treenode.parent=NIL then
    result := NIL
   else
    result := getNode(treenode.parent)
end;

function Tnode.childrenCount: integer;
begin
  result := treenode.childcount
end;

function Tnode.firstChild: Tnode;
begin
  result := getNode(treenode.FirstChild)
end;

function Tnode.next: Tnode;
begin
  result := getNode(treenode.NextSibling)
end;

function Tnode.prev: Tnode;
begin
  result := getNode(treenode.PrevSibling)
end;

function Tnode.expanded: boolean;
begin
  result := vsExpanded in treenode.states
end;

function Tnode.level: integer;
begin
  result := RnQmain.roster.getnodelevel(treenode)
end;

function Tnode.isVisible: boolean;
var
  n, root: Pvirtualnode;
begin
  n := treenode;
  root := RnQmain.roster.rootnode;

  result := vsVisible in n.states;
  repeat
  n := n.parent;
  if n<>root then
    result := (vsVisible in n.states) and (vsExpanded in n.states);
  until not result or (n=root);
end; // isVisible

procedure Tnode.setExpanded(val: boolean; recur: boolean = FALSE);
begin
  if not recur then
    RnQmain.roster.expanded[treenode] := val
   else
    if val then
      RnQmain.roster.FullExpand(treenode)
     else
      RnQmain.roster.FullCollapse(treenode);
end; // setexpanded

function Tnode.rect: Trect;
begin
  result := RnQmain.roster.GetDisplayRect(treenode, -1, FALSE)
end;

/////////////////////////////////////////////////////////////

function insertNode(d: Tdivisor): Tnode; overload;
var
  a: Tnode;
begin
  Result := NIL;
  if not (d in [Low(Tdivisor)..High(Tdivisor)]) then
    Exit;
  result := divs[d];
  if assigned(result) then
    exit;

  a := Tnode.create(d);
  result := a;
  result.treenode := RnQmain.roster.addchild(NIL, result);
  divs[d] := result;
  if not building then
    sort(result);
end; // insertNode

function insertNode(id: integer; d: Tdivisor): Tnode; overload;
var
  idx: integer;
begin
  idx := groups.idxOf(id);
  result := groups.a[idx].node[d];
  if assigned(result) then
    exit;
  insertNode(d); // ensure divisor existence
  result := Tnode.create(id, d);
  result.order := groups.a[idx].order;
  result.treenode := RnQmain.roster.addChild(divs[d].treenode, result);
  groups.a[idx].node[d] := result;
  if not building then
   sort(result);
end; // insertNode

function shouldBeUnder(c: TRnQContact; d: Tdivisor): Tnode;
begin
  result := insertNode(d);
  if (c.group = 0) or not showGroups or not (d in divsWithGroups) then
    exit;
  if not groups.exists(c.group) then
    c.group := 0
   else
    result := insertNode(c.group, d);
end; // shouldBeUnder

function insertNode(c: TRnQContact; under: Tnode): Tnode; overload;

  procedure checkExpansion;
  var
    n: Tnode;
    d: Tdivisor;
  begin
    n := result.parent;
    repeat
    case n.kind of
      NODE_GROUP:
        begin
        d := n.parent.divisor;
        n.setexpanded(groups.a[groups.idxOf(n.groupId)].expanded[d]);
        end;
      NODE_DIV:
        begin
        n.setexpanded(TRUE);
        break;
        end;
      end;
    n := n.parent;
    until n=NIL;
  end; // checkExpansion

begin
  result := Tnode.create(c);

  result.treenode := RnQmain.roster.addChild(under.treenode, result);
//Result.groupId := under.groupId;
  updateHiddenNode(result);
  if not building then
    checkExpansion;
  autosizeDelayed := TRUE;
  if not building then
    sort(result);
end; // insertNode

function insertNode(c: TRnQcontact; d: Tdivisor): Tnode; overload;
begin
  result := insertNode(c, shouldBeUnder(c, d))
end;

function GetContactDiv(c: TRnQContact; isRoster: Boolean = false): Tdivisor;
begin
  if (not isRoster) and notinlist.exists(c) then
    result := d_nil
   else
    if (not isRoster) and not c.isInRoster then
      result := Tdivisor(13)
     else
      if buildingOnline and not OnlOfflInOne then
      {$IFDEF CHECK_INVIS}
      if supportInvisCheck and (c.isInvisible) then
        result := d_invis
       else
      {$ENDIF}
        if c.isOffline or (showUnkAsOffline and not c.isOnline) then
          result := d_offline
         else
          result := d_online
      else
       if buildingOnline and showOnlyOnline and not c.isOnline then
         Result := d_offline
        else
         result := d_contacts
end;

function insertNode(c: TRnQContact): Tnode; overload;
var
  d: Tdivisor;
begin
  if filtered(c) then
    Exit(nil);
  d := GetContactDiv(c);
//  if d in [d_online..d_nil] then
  if d in [Low(Tdivisor).. High(Tdivisor)] then
    result := insertNode(c, d)
   else
    Result := nil;
end; // insertNode

function removeNode(n: Tnode): boolean; overload;
var
  parent: Tnode;
begin
  result := assigned(n);
  if not result then
    exit;

  while n.childrenCount > 0 do
    removeNode(n.firstChild);

  parent := n.parent;
  RnQmain.roster.deleteNode(n.treenode);
  n.free;

  if parent=NIL then
    exit;
  if parent.childrenCount=0 then
   case parent.kind of
     NODE_GROUP: removeNode(parent);
     NODE_DIV: if parent.divisor in [d_nil, d_contacts] then
                 removeNode(parent);
    end;
  autosizeDelayed := TRUE;
end; // removeNode

function removeNode(c: TRnQContact): boolean; overload;
var
  n: Tnode;
  tn: PVirtualNode;
begin
  n := TCE(c.data^).node;
  if Assigned(n) and (n.treenode <> NIL) then
   if RnQmain.roster.IsVisible[n.treenode] and
      (RnQmain.roster.FocusedNode = n.treenode)
   then
    begin
      tn := RnQmain.roster.GetNextVisibleSibling(n.treenode);
      if tn <> NIL then
        RnQmain.roster.FocusedNode := tn
       else
        begin
          tn := RnQmain.roster.GetPreviousVisibleSibling(n.treenode);
          if tn <> NIL then
            RnQmain.roster.FocusedNode := tn
        end;
    end;

  result := removeNode(TCE(c.data^).node);
  if Result then
    autosizeDelayed := TRUE;

  TCE(c.data^).node := NIL;
end;

procedure rebuild;
var
  i: integer;
  rosterList: TRnQCList;
  d: Tdivisor;
  c: TRnQContact;
  oldFocusedContact: TRnQContact;
//  oldtopnode: PVirtualNode;
begin
  if building then
    Exit;
  FilterTextBy := AnsiUpperCase(FilterTextBy);
  oldFocusedContact := focusedContact;
//  oldtopnode := RnQmain.roster.TopNode;
 try
  building := TRUE;
  //with RnQmain.roster.treeoptions do autooptions:=autoOptions-[toAutosort];
  // reset
  RnQmain.roster.BeginUpdate;
  clear;

  fillChar(divs, sizeOf(divs), 0);
  if groups=NIL then
    exit;
  for i:=0 to groups.count-1 do
    with groups.a[i] do
      fillchar(node, sizeOf(node), 0);
  // roster section
  rosterList := Account.AccProto.readList(LT_ROSTER).clone;
  rosterList.sort(compareContacts4build);

  buildingOnline := Account.AccProto.isOnline;
  if buildingOnline  and not OnlOfflInOne then
    begin
    insertNode(d_online);
   {$IFDEF CHECK_INVIS}
    insertNode(d_invis);
   {$ENDIF}
    insertNode(d_offline);
    end;
  for c in rosterList do
   begin
    if Filtered(c) then
     Continue;
    d := GetContactDiv(c, True);
    insertNode(c, d);
   end;

  rosterList.free;
  // NIL section
  if assigned(notInList) then
    with notInList do
     begin
      resetEnumeration;
      while hasMore do
       begin
        c := getNext;
        if not Filtered(c) then
         insertNode(c, d_nil);
       end;
     end;

  // expands all divs
  for d:=low(d) to high(d) do
    if assigned(divs[d]) then
      begin
      divs[d].setExpanded(TRUE);
      for i:=0 to groups.count-1 do
        with groups.a[i] do
          if node[d]<>NIL then
            node[d].setexpanded(expanded[d])
      end;

  updateHiddenNodes;
  //with RnQmain.roster.treeoptions do autooptions:=autoOptions+[toAutosort];
  autosizeDelayed := TRUE;
finally
  building := FALSE;
  RnQmain.roster.EndUpdate;
//sort(RnQmain.roster.rootnode);
with RnQmain.roster do
  begin
  show;
//  if RnQmain.visible then
//    setFocus;
  if oldFocusedContact<>NIL then
   begin
    focus(oldFocusedContact);
//    topnode := oldtopnode;
   end
  else
    if totalcount > 0 then
      begin
      focusedNode := RootNode.firstchild;
      topnode := RootNode.firstchild;
      end;
  end;
end;
end; // rebuild

procedure redraw;
begin
  RnQmain.roster.repaint
end;

function redraw(c: TRnQContact): boolean;
begin
  result := FALSE;
  if c=NIL then
    exit;
 try
   result := redraw(TCE(c.data^).node);
  except
 end;
updateHiddenNode(TCE(c.data^).node);
if chatFrm<>NIL then
 begin
  try
   chatFrm.setCaptionFor(c);
   chatFrm.redrawTab(c);
   chatFrm.updateContactStatus;
  except

  end;
//  updateContactStatus;
 end;
end; // redraw

function redraw(n: Tnode): boolean;
var
  r: Trect;
begin
  result := FALSE;
  if (n=NIL) or (n.treenode=NIL) then
    exit;
  R := RnQmain.roster.GetDisplayRect(n.treenode, -1, FALSE);
  InvalidateRect(RnQmain.roster.handle, @R, True);
end; // redraw

function update(c: TRnQContact): boolean;
var
  d: Tdivisor;
  wasFocused: boolean;
  n: Tnode;
begin
  result := FALSE;
  if c=NIL then
    exit;
  wasFocused := c=focusedContact;
  n := TCE(c.data^).node;
  if Assigned(n) and
     (isUnderDiv(n) = GetContactDiv(c)) then
    begin
      if n.groupId <> c.group then
       begin
        removeNode(c);
        n := insertNode(c);
       end;
    end
   else
    begin
      removeNode(c);
      n := insertNode(c);
    end;
  if n=NIL then
    exit;
  d := isUnderDiv(n);
  if assigned(divs[d]) then
    divs[d].setExpanded(TRUE);
  sort(c);
  if wasFocused then
    focus(c);
end; // update

function remove(c: TRnQContact): boolean;
begin
  Result := false;
  if not Assigned(c) then
    Exit;
  with c.fProto do
  begin
//    Result := notInList.remove(c);
    result := removeContact(c) or Result;
//    if isOnline then
      begin
       RemFromList(LT_VISIBLE, c);
       readList(LT_VISIBLE).remove(c);
      end;
  end;
saveListsDelayed := TRUE;
removeNode(c);
if chatFrm<>NIL then
  chatFrm.userChanged(c);
end; // remove

function exists(c: TRnQContact): boolean;
begin
  result:=(c<>NIL) and (c.data<>NIL) and (TCE(c.data^).node<>NIL)
end;

function focus(tn: Pvirtualnode): boolean; overload;
begin
  result := focus(getnode(tn))
end;

function focus(n: Tnode): boolean; overload;
begin
  result := assigned(n) and assigned(n.treenode);
  if result then
    RnQmain.roster.focusedNode := n.treenode
   else
    RnQmain.roster.focusednode := NIL;
  clickedNode := n;
  clickedContact := focusedContact;
//  clickedContact := NIL;
//focusedCnt := focusedContact;
  clickedGroup := -1;
  if clickedNode=NIL then
    exit;
  if clickedNode.kind=NODE_GROUP then
    clickedGroup := clickedNode.groupId;
end; // focus

function focus(c: TRnQContact): boolean; overload;
begin
  result := (c<>NIL) and focus(TCE(c.data^).node)
end;

procedure formresized;
var
  d: Tdivisor;
begin
  if not RnQmain.visible then
    exit;
  for d:=low(Tdivisor) to high(Tdivisor) do
    redraw(divs[d]);
end;

procedure clear;
var
  d: Tdivisor;
begin
  RnQmain.roster.clear;
//  RnQmain.roster.
  while contactsPool.count > 0 do
   begin
    Tnode(contactsPool.last).free;
//    contactsPool.last
   end;
  for d:=low(Tdivisor) to high(Tdivisor) do
    FreeAndNil(divs[d]);
//    divs[d].Free;
end; // clear

function lowestVisibleNodeFrom(n: PVirtualNode): PvirtualNode;
begin
while RnQmain.roster.expanded[n] and (n.childcount>0) do
  n := RnQmain.roster.getLastVisibleChild(n);
result := n;
end;

function nodeBottomSide(n: PvirtualNode): integer;
begin
  if n <> nil then
    result := RnQmain.roster.GetDisplayRect(n, -1, FALSE).bottom
             -RnQmain.roster.GetDisplayRect(RnQmain.roster.rootnode.FirstChild, -1, FALSE).top
   else
    result := 0;
end;

function onlineMaxY: integer;
begin
  if divs[d_online]=NIL then
    result := -1
   else
    result := nodeBottomSide( lowestVisibleNodeFrom(divs[d_online].treenode) );
 {$IFDEF CHECK_INVIS}
  if divs[d_invis]=NIL then
    exit //result := -1
   else
    if RnQmain.roster.isVisible[divs[d_invis].treenode] then
      result := nodeBottomSide( lowestVisibleNodeFrom(divs[d_invis].treenode) );
 {$ENDIF}
end; // onlineMaxY

function fullMaxY: integer;
begin
  if RnQmain.roster.RootNodeCount = 0 then
    result := -1
   else
    result := nodeBottomSide( lowestVisibleNodeFrom(RnQmain.roster.rootnode) )
end;

function addGroup(const name: string): integer;
var
  d: Tdivisor;
  first: Tnode;
begin
// create the new group
  result := groups.add;
  groups.a[groups.idxOf(result)].name := name;
// add it to divisors, and focus on the first one
  first := NIL;
  for d:=high(d) downto low(d) do
    if (d in divsWithGroups) and assigned(divs[d]) then
      first := insertNode(result, d);
  focus(first);
  saveGroupsDelayed := TRUE;
end; // addGroup

function removeGroup(id: integer): boolean;
var
  cl: TRnQCList;
  c: TRnQContact;
  d: Tdivisor;
begin
  result := groups.exists(id);
  if not result then
    exit;
  cl := Account.AccProto.readList(LT_ROSTER).clone;
  for c in cl do
    if c.group = id then
      remove(c);
  cl.free;
  with groups.a[groups.idxOf(id)] do
   begin
    for d:=low(d) to high(d) do
      removeNode(node[d]);
   end;
  groups.delete(id);
  saveGroupsDelayed := TRUE;
end; // removeGroup

procedure edit(n: Tnode);
begin
  FreeAndNil(inplace.edit);
  if (n=NIL) or (n.treenode=NIL) then
    exit;
  if not (n.kind in [NODE_GROUP, NODE_CONTACT]) then
    exit;
  if not formVisible(RnQmain) then
    RnQmain.toggleVisible();
  if (n.kind = NODE_CONTACT) and not n.contact.canEdit then
    Exit;
//if (n.kind = NODE_GROUP) and useSSI and
//    not n.groupId then Exit;
  if not formVisible(RnQmain) then
    Exit;
focus(n);
inplace.edit := Tedit.create(RnQmain.roster);
inplace.edit.hide;
inplace.edit.parentFont := FALSE;
inplace.edit.parent := RnQmain.roster;
inplace.edit.DoubleBuffered := DwmCompositionEnabled;
inplace.node := n;
with n.rect do
  inplace.edit.SetBounds(n.textOfs,top,right-n.textofs-1,bottom-top);
case n.kind of
  NODE_CONTACT:
    begin
    inplace.what := NODE_CONTACT;
    inplace.contact := n.contact;
    inplace.edit.text := inplace.contact.displayed;
    end;
  NODE_GROUP:
    begin
    with inplace.edit.font do
      style := style+[fsBold];
    inplace.what := NODE_GROUP;
    inplace.groupId := n.groupId;
    inplace.edit.text := groups.id2name(n.groupId);
    end;
  end;
inplace.edit.show;
inplace.edit.SetFocus;
inplace.edit.onExit := RnQmain.roasterStopEditing;
inplace.edit.onKeyPress := RnQmain.roasterKeyEditing;
end; // edit

function focused: Tnode;
begin
with RnQmain.roster do
  if focusedNode=NIL then
    result := NIL
   else
    result := getNode(focusednode)
end; // focused

function focusedContact: TRnQContact;
var
  n: Tnode;
begin
  result := NIL;
  n := focused;
  if (n<>NIL) and (n.kind = NODE_CONTACT) then
    result := n.contact
end; // focusedContact

procedure expand(n: Tnode);
begin
  if n<>NIL then
    n.setExpanded(TRUE)
end;

procedure collapse(n: Tnode);
begin
  if n<>NIL then
    n.setExpanded(FALSE)
end;

function nodeAt(x, y: integer): Tnode;
var
  n: Pvirtualnode;
begin
with RnQmain.roster do
  begin
  n := getNodeAt(x, y);
  if n=NIL then
    result := NIL
  else
    result := getNode(n)
  end;
end; // nodeAt

procedure focusPrevious;
begin
  with RnQmain.roster do
    focusedNode := GetPreviousVisible(focusedNode)
end;

procedure setOnlyOnline(v: boolean);
begin
  showOnlyOnline := v;
  saveCfgDelayed := True;
  if OnlOfflInOne then
    Rebuild
   else
    updateHiddenNodes;
end; // setOnlyOnline

procedure sort(c: TRnQContact);
begin
  if c<>NIL then
    sort(TCE(c.data^).node)
end;

procedure sort(n: Tnode);
begin
  if n<>NIL then
    sort(n.treenode.parent)
end;

procedure sort(tn: Pvirtualnode);
begin
  if tn<>NIL then
    RnQmain.roster.sort(tn, 0, sdAscending, FALSE)
end;

procedure setNewGroupFor(c: TRnQContact; grp: integer);
begin
  c.group := grp;
  c.fProto.updateGroupOf(c);
  update(c);
  dbUpdateDelayed := TRUE;
end; // setNewGroupFor

function isUnderDiv(n: Tnode): Tdivisor;
begin
  result := d_contacts;
  while n<>NIL do
  if n.kind = NODE_DIV then
    begin
      result := n.divisor;
      exit;
    end
   else
    n := n.parent;
enD; // isUnderDiv

function focusTemp(n: Tnode): boolean;
var
  p: Tnode;
  bak: boolean;
begin
  bak := setRosterAnimation(FALSE);
  if (expandedByTempFocus<>NIL) and (n<>expandedByTempFocus) then
    begin
      p := expandedByTempFocus.parent;
      if p.kind = NODE_GROUP then
        p.setExpanded(FALSE);
    end;
  if not n.isVisible then
    expandedByTempFocus := n;
  result := focus(n);
  setRosterAnimation(bak);
end; // focusTemp

procedure popup(x: integer = -1; y: integer = -1);
begin
  popupOn(clickedNode)
end;

procedure popupOn(n: Tnode; x: integer = -1; y: integer = -1);
begin
  if x<0 then
  begin
    x := mousePos.x;
    y := mousePos.y;
  end;
  if n=NIL then
    RnQmain.divisorMenu.popup(x, y)
   else
    case n.kind of
      NODE_GROUP: RnQmain.groupMenu.popup(x, y);
      NODE_CONTACT: RnQmain.contactMenu.popup(x, y);
      else RnQmain.divisorMenu.popup(x, y);
    end;
end; // popupOn

function contactsUnder(n: Tnode): integer;
begin
  result := 0;
  n := n.firstChild;
  while n<>NIL do
   begin
    if n.childrenCount > 0 then
      inc(result, contactsUnder(n));
    if n.kind = NODE_CONTACT then
      inc(result);
    n := n.next;
   end;
end; // contactsUnder


procedure RstrDrawNode(Sender: TBaseVirtualTree; const PaintInfo: TVTPaintInfo; const PPI: Integer);
var
  n: Tnode;
//  function DrawContactIcon(DC : THandle; pIcon : Byte; x, y : Integer; Cnt : TContact; pIsRight : boolean = false) : TSize;
//  function DrawContactIcon(DC : THandle; pIcon : TRnQCLIconsSet; x, y : Integer;
  function DrawContactIcon(DC: THandle; pIcon: TRnQCLIconsSet; p: TPoint;
                           Cnt: TRnQContact; pIsRight: boolean = false): TSize;
  var
//    newX Integer;
    po: TRnQThemedElementDtls;
//    s : String;
//    rB: Trect;
    rB: TGPRect;
    ev: Thevent;
  begin
    Result.cx := 0; Result.cy := 0;
    po.ThemeToken := -1;
    po.Element := RQteDefault;
    po.pEnabled := True;
    if pIcon in [CNT_ICON_VIS, CNT_ICON_AUTH, CNT_ICON_LCL] then
     begin
      po.picName := RnQCLIcons[pIcon].IconName;
      if pIsRight then
        with theme.GetPicSize(po, 0, PPI) do
          dec(p.X, cx);
     end;
    case pIcon of
      CNT_ICON_VIS:
//         if imVisibleTo(cnt) then
         if (cnt.imVisibleTo) then
           result := theme.drawPic(DC, p, po, PPI)
          else
           if showVisAndLevelling and cnt.fProto.isOnline then
            result := theme.GetPicSize(po, 0, PPI);
      CNT_ICON_STS:
        begin
          ev := eventQ.firstEventFor(cnt);
          Result.cx := 0;

          if (ev=NIL) or (blinkWithStatus and not(blinking or cnt.fProto.getStatusDisable.blinking)) then
            begin
          {$IFDEF CHECK_INVIS}
      //      if (c.invisibleState = 2)or(c.status <> SC_OFFLINE) then
          {$ENDIF}
             if notinlist.exists(cnt) then
              begin
                po.picName := PIC_STATUS_UNK;
                if pIsRight then
                    with theme.GetPicSize(po, 0, PPI) do
                      dec(p.X, cx);
                Result := theme.drawPic(DC, p, po, PPI);
              end
             else
 {$IFDEF PROTOCOL_ICQ}
              if cnt is TICQcontact then
      //         if not(not XStatusAsMain and showXStatus and (c.xStatus>0) and (c.status = SC_ONLINE) ) then
                begin
                  if pIsRight then
                   begin
                    Result := ICQstatusDrawExt(0, 0, 0, byte(cnt.status),
                                 cnt.isInvisible, TICQcontact(cnt).xStatus, PPI);
                    dec(p.X, Result.cx);
                   end;
                  Result := ICQstatusDrawExt(DC, p.X, p.Y, byte(cnt.status),
                                 cnt.isInvisible, TICQcontact(cnt).xStatus, PPI);
                end
      //         size:=theme.drawPic(cnv, x,y+1, rosterImgNameFor(c))
               else
 {$ENDIF PROTOCOL_ICQ}
                begin
                  if pIsRight then
                   begin
                    Result := theme.GetPicSize(RQteDefault, cnt.statusImg, PPI);
                    dec(p.X, Result.cx);
                   end;
                  Result := theme.drawPic(DC, p.X, p.Y, cnt.statusImg, True, PPI)
                end;
          {$IFDEF CHECK_INVIS}
      //      else
      //        size.cx := 0
          {$ENDIF}
            end
          else
           begin
            Result := ev.PicSize(PPI);
            if pIsRight then
              dec(p.X, Result.cx);
            if blinking or cnt.fProto.getStatusDisable.blinking then
              ev.Draw(DC, p.X, p.Y, PPI)
           end;
        end;
 {$IFDEF PROTOCOL_ICQ}
      CNT_ICON_XSTS:
       if (cnt is TICQcontact) then
         begin
          if not XStatusAsMain and (TICQcontact(cnt).xStatus>0) then
           begin
            po.picName := XStatusArray[TICQcontact(cnt).xStatus].PicName;
              if pIsRight then
                with theme.GetPicSize(po, 0, PPI) do
                  dec(p.X, cx);
            Result := theme.drawPic(DC, p, po, PPI);
           end;
         end;
 {$ENDIF PROTOCOL_ICQ}
      CNT_ICON_AUTH:
 {$IFDEF PROTOCOL_ICQ}
       if (cnt is TICQcontact) then
        begin
          if
   {$IFDEF UseNotSSI}
//           icq.useSSI and
           (TicqSession(cnt.iProto.ProtoElem).UseSSI) and
   {$ENDIF UseNotSSI}
            not cnt.Authorized and not cnt.CntIsLocal
            and (cnt.SSIID <> 0) then
           result := theme.drawPic(DC, p, po, PPI);
        end
       else
 {$ENDIF PROTOCOL_ICQ}
        if not cnt.Authorized then
           result := theme.drawPic(DC, p, po, PPI);

      CNT_ICON_LCL:
         if (cnt.CntIsLocal) then
         result := theme.drawPic(DC, p, po, PPI);
      CNT_ICON_VER:
         begin
//          po.picName := cnt.ClientStr;
          po.picName := cnt.ClientPic;
          if po.picName >'' then
             begin
              if pIsRight then
                with theme.GetPicSize(po, 0, PPI) do
//                  newX := x - cx
                  dec(p.X, cx);
//               else
//                 newX := x;
              Result := theme.drawPic(DC, p, po, PPI);
             end;
         end;
      CNT_ICON_BIRTH:
         begin
           case Cnt.Days2Bd of
             0: po.picName := PIC_BIRTH;
             1: po.picName := PIC_BIRTH1;
             2: po.picName := PIC_BIRTH2;
             else po.picName := '';
           end;
           if po.picName > '' then
             begin
              if pIsRight then
                with theme.GetPicSize(po, 0, PPI) do
//                  newX := x - cx
//               else
//                 newX := x;
                  dec(p.X, cx);
               Result := theme.drawPic(DC, p, po, PPI);
             end;
         end;
      CNT_TEXT:
         begin
         {$IFDEF CHECK_INVIS}
      {    if CheckInvis.ShowInvisibility then
           if c.invisibleState=1 then
            inc(x, theme.drawPic(cnv, x,y+1, status2imgName(SC_ONLINE, true)).cx+2)
            else
           if c.invisibleState=2 then
            inc(x, theme.drawPic(cnv, x,y+1, status2imgName(SC_ONLINE, false)).cx+2);
      }
         {$ENDIF}
          if cnt.typing.bIsTyping then
            Result := theme.drawPic(DC, p.x, p.y, PIC_TYPING, True, PPI);
          if Account.outbox.stFor(cnt) then
            begin
             with theme.GetPicSize(RQteDefault, PIC_OUTBOX, PPI) do
               n.outboxRect := rect(p.x, p.y, p.x+cx, p.y+cy);
             Result := theme.drawPic(DC, p.x, p.y, PIC_OUTBOX, True, PPI);
            end
          else
            n.outboxRect := rect(-1,-1,-1,-1);
         end;
   {$IFDEF RNQ_AVATARS}
      CNT_ICON_AVT:
         begin
          with cnt.icon do
          if Assigned(Bmp) then
           begin
            Rb := DestRect(Bmp.Width, Bmp.Height, paintinfo.node.NodeHeight-1, paintinfo.node.NodeHeight-1);
    //        w := Rb.Right - Rb.Left;
            if pIsRight then
              begin
                inc(Rb.X, p.X - paintinfo.node.NodeHeight);
//                inc(Rb.Right, x - paintinfo.node.NodeHeight);
              end
             else
              begin
                inc(Rb.X, p.X);
//                inc(Rb.Right, x);
              end;
            inc(Rb.Y, p.y);
//            inc(Rb.Bottom, y);
            SetStretchBltMode(DC, HALFTONE);
            DrawRbmp(DC, Bmp, Rb);
            Result.cx := paintinfo.node.NodeHeight;
//            Result.cy := paintinfo.node.NodeHeight;
            Result.cy := Result.cx
           end;
         end
   {$ENDIF RNQ_AVATARS}
     else
       begin
       end;
    end;
    if Result.cx > 0 then
      Inc(Result.cx, 2);
  end;
const
  f1n = 'roaster.group'; //roaster.groupfont);
  f2n = 'roaster.group.num'; //roaster.groupfont);
var
  bakmode: integer;
  cnv: Tcanvas;
  R, rB: Trect;
  cntTxt: TRect;
  s: string;
  b, isNIL: boolean;
  isOnRight: Boolean;
  ico: TRnQCLIconsSet;
  p: TPoint;
  i: Integer;
  w: Smallint;
  size: Tsize;
  res: Tsize;
  vPicName: TPicName;
  dx: Integer;
  x, y: integer;
  oldCol: TColor;
  FadeColor1, FadeColor2: Cardinal;
  dd: TDateTime;
//  gr: TGPGraphics;
//  br: TGPBrush;
//  pen: TGPPen;
   TextLen: Integer;
   TextRect: TRect;
   TextFlags: Cardinal;
   Options: TDTTOpts;
begin

  cnv := paintinfo.canvas;
  cnv.Font.Assign(sender.Font);
  R := paintinfo.CellRect;
  n := Tnode(PNode(sender.getnodedata(paintinfo.node))^);
//  inc(r.Right);
 if paintinfo.node = sender.focusednode then
  begin
    rB := R;
   rB.Bottom := r.Top + (r.Bottom - r.Top) div 2+1;
//   inc(rB.Right, 2);

   FadeColor2 := AlphaMask or theme.GetAColor('roaster.selection', clMenuHighlight);
   FadeColor1 := AlphaMask or MidColor(clWhite, FadeColor2, 0.4);

   if Win32MajorVersion >=6 then
    begin
        FadeColor1 := FadeColor1 and $D0FFFFFF;
        FadeColor2 := FadeColor2 and $D0FFFFFF;
    end;

   FillGradient(cnv.Handle, rB,  FadeColor1,  MidColor(FadeColor1, FadeColor2, 0.66),  gdVertical);
   rB.Top := rB.Bottom;
   rB.Bottom := r.Bottom;
   FillGradient(cnv.Handle, rB,  FadeColor2,  MidColor(FadeColor1, FadeColor2, 0.66),  gdVertical);

    oldCol := cnv.Brush.Color;
    cnv.Brush.Color := theme.GetColor('roaster.selection', clMenuHighlight);
    cnv.FrameRect(r);
    cnv.Brush.Color := oldCol;
//  cnv.Brush.color:=theme.GetColor('roaster.selection', clGrayText); //roaster.selectioncolor;
//  cnv.fillrect(r);
  end;
  theme.ApplyFont(Str_roster, cnv.font);
  bakmode := getbkmode(cnv.handle);
  SetBkMode(cnv.handle, TRANSPARENT);
//Dec(R.Bottom);
  Dec(R.Right);
  x := 0;
  y := 0;
case n.kind of
  NODE_CONTACT:
    begin
    inc(x, 2);
    if n.contact.UID = '' then
      Exit;
    isNIL := notinlist.exists(n.contact);
    if indentRoster and showgroups and (n.contact.group>0) and not isNIL then
      inc(x, theme.getPicSize(RQteDefault, PIC_CLOSE_GROUP, 0, PPI).cx);

{
    if TO_SHOW_ICON[CNT_ICON_VIS] then
      inc(x, DrawContactIcon(cnv.Handle, CNT_ICON_VIS,Point(x, y+1), n.contact).cx);
}

    isOnRight := False; // Ещё не доходили до текста
    dx := 1; // Отступа справа пока нет
    i := Byte(low(TRnQCLIconsSet));
    while ((not isOnRight) or (SHOW_ICONS_ORDER[i] <> CNT_TEXT))
          and (i in [Byte(low(TRnQCLIconsSet))..Byte(High(TRnQCLIconsSet))]) do
     begin
      ico := SHOW_ICONS_ORDER[i];
      if ico = CNT_TEXT then
       begin
        p := Point(x, y+1);
//         size := DrawContactIcon(cnv.Handle, ico, p, n.contact, isOnRight);
         size := DrawContactIcon(cnv.Handle, ico, p, n.contact, False);
//         if isOnRight then
//           inc(dx, size.cx)
//          else
           inc(x, size.cx);
        isOnRight := True;
        i := Byte(High(TRnQCLIconsSet));
        Continue;
       end;
      if isOnRight then
        p := Point(R.Right-dx-1,y+1)
       else
        p := Point(x, y+1);
      if TO_SHOW_ICON[ico] then
        begin
         size := DrawContactIcon(cnv.Handle, ico, p, n.contact, isOnRight);
         if isOnRight then
           inc(dx, size.cx)
          else
           inc(x, size.cx);
        end;
      if isOnRight then
        dec(i)
       else
        inc(i);
     end;

    // Text
    if isNIL then
        theme.ApplyFont('roaster.notinlist', cnv.font)
     else
        if n.contact.fProto.isOnline then
         if n.contact.isOnline then
           begin
             theme.ApplyFont('roaster.online', cnv.font);
 {$IFDEF PROTOCOL_ICQ}
             if (n.contact is TICQContact) and (n.contact as TICQContact).noClient then
               theme.ApplyFont('roaster.noclient', cnv.font);
 {$ENDIF PROTOCOL_ICQ}
           end
          else
           if n.contact.isOffline then
             theme.ApplyFont('roaster.offline', cnv.font);
    if paintinfo.node = sender.focusednode then
      cnv.font.color := theme.GetColor('roaster.font.selected', cnv.font.color); //roaster.selectionTextColor
    if UseContactThemes and Assigned(ContactsTheme) then
     begin
      ContactsTheme.ApplyFont(TPicName('group.') + TPicName(AnsiLowerCase(groups.id2name(n.contact.group))) + '.roaster', cnv.font);
      ContactsTheme.ApplyFont(TPicName(n.contact.UID2cmp) + '.roaster', cnv.font);
     end;
    case rosterItalic of
      RI_LIST: b := n.contact.fProto.readList(LT_VISIBLE).exists(n.contact);
      RI_VISIBLETO: b := n.contact.imVisibleTo;
      else b := FALSE;
      end;
    if b then
      if fsItalic in cnv.font.style then
        cnv.font.style := cnv.font.style-[fsItalic]
      else
        cnv.font.style := cnv.font.style+[fsItalic];
    n.textOfs := x;
    cntTxt := R;
    cntTxt.Left := x;
    Dec(cntTxt.Right, dx);
    // -=S@x
    //cnv.textout(x, y+2, c.displayed);
    // S@x=-
     // -=S@x
        s := dupAmperstand(n.contact.displayed);
{
        TextLen := Length(s);
        TextFlags := DT_CENTER or DT_VCENTER;
//        TextFlags := DT_LEFT or DT_SINGLELINE or DT_VCENTER or DT_END_ELLIPSIS;
        TextRect := cntTxt;
//        TextRect.Left := cntTxt.;
//        TextRect.Top := y-1;
  //      inc(TextRect.Bottom, 1);
        FillChar(Options, SizeOf(Options), 0);
        Options.dwSize := SizeOf(Options);
        Options.dwFlags := DTT_COMPOSITED or DTT_TEXTCOLOR;
//        Options.iGlowSize := 2;
        Options.crText := ColorToRGB(cnv.Font.Color);
          with StyleServices.GetElementDetails(twCaptionActive) do
            DrawThemeTextEx(StyleServices.Theme[teWindow], cnv.Handle, Part, State,
//            with StyleServices.GetElementDetails(teEditTextNormal) do
//              DrawThemeTextEx(StyleServices.Theme[teEdit], Memdc, Part, State,
                PWideChar(WideString(s)), TextLen, TextFlags, @TextRect, Options);
}


//     DrawText32(cnv.Handle, cntTxt, s, cnv.Font, DT_CENTER or DT_VCENTER);

     DrawText(cnv.Handle, PChar(s),  Length(s), cntTxt,
              DT_LEFT or DT_SINGLELINE or DT_VCENTER or DT_END_ELLIPSIS);

//     DrawText32(cnv.Handle, cntTxt, s, cnv.Font, DT_LEFT or DT_SINGLELINE or DT_VCENTER or DT_END_ELLIPSIS);
//        DrawTextTransparent(cnv.Handle, cntTxt.Left, cntTxt.Top, s, cnv.Font,
//              200, DT_LEFT or DT_SINGLELINE or DT_VCENTER or DT_END_ELLIPSIS);
     // S@x=-
    end;
  NODE_GROUP:
    begin
      theme.ApplyFont(f1n, cnv.font);
//      if n.expanded and (n.childrenCount>0) then
      if n.expanded or (n.childrenCount=0) then
        vPicName := PIC_OPEN_GROUP
       else
        vPicName := PIC_CLOSE_GROUP;
      inc(x, theme.drawPic(cnv.Handle, x+2,y, vPicName, True, PPI).cx+4);
      n.outboxRect := rect(2,2,x-2,r.bottom-1);

      n.textOfs := x;
      s := groups.id2name(n.groupId);
  //    cnv.textout(x,y+2,s);
      cnv.textout(x, y+2, s);
      GetTextExtentPoint32(cnv.handle, pchar(s), length(s), res);
      x := x+res.cx;
      cnv.textout(x, y+2, ' (');
      GetTextExtentPoint32(cnv.handle,' (', 2, res);
      x := x+res.cx;
  //    cnv.font:=f2;
       cnv.Font.Assign(sender.Font);
       theme.ApplyFont(f2n, cnv.font);

      if OnlOfflInOne then
        s := intToStr(Account.AccProto.readList(LT_ROSTER).getCount(n.groupID, True))
       else
        s := intToStr(n.childrenCount);
      cnv.textout(x, y+2, s);
      GetTextExtentPoint32(cnv.handle, pchar(s), length(s), res);
  //    s := '';
      x := x+res.cx;
  //    cnv.font:=f1;
      cnv.Font.Assign(sender.Font);
      theme.ApplyFont(f1n, cnv.font);
      cnv.textout(x, y+2, '/');
      GetTextExtentPoint32(cnv.handle, '/', 1, res);
      x := x+res.cx;
  //    cnv.font:=f2;
      cnv.Font.Assign(sender.Font);
      theme.ApplyFont(f2n, cnv.font);
      s := intToStr(Account.AccProto.readList(LT_ROSTER).getCount(n.groupID));
      cnv.textout(x, y+2, s);
      GetTextExtentPoint32(cnv.handle, pchar(s), length(s), res);
      x := x+res.cx;
  //    cnv.font:=f1;
      cnv.Font.Assign(sender.Font);
      theme.ApplyFont(f1n, cnv.font);
      cnv.textout(x, y+2, ')');
    end;
  NODE_DIV:
    begin
      theme.ApplyFont('roaster.divisor', cnv.font);
      cnv.pen.color := cnv.font.color;
      s := getTranslation(divisor2ShowStr[Tdivisor(n.divisor)])+' '+intToStr(contactsUnder(n));
      size := txtSize(cnv.handle, s);
      x := (r.right+r.left-size.cx) div 2;
      y := (r.bottom+r.top-size.cy) div 2;
      if x < 10 then
        x := 10;
      n.textOfs := x;

      cnv.textout(x, y, s);

      y := (r.top+r.bottom) div 2-2;
      cnv.moveTo(r.left, y);
      cnv.lineTo(x-1, cnv.penpos.y);
      cnv.moveTo(x+size.cx+3, cnv.penpos.y);
      cnv.lineTo(r.right, cnv.penpos.y);
    end;
  end;//case
 SetBkMode(cnv.handle, bakmode);
end;

function ICON_ORDER_PREF: RawByteString;
var
  a: TRnQCLIconsSet;
begin
  Result := ';';
  for a in SHOW_ICONS_ORDER do
    Result := Result + RnQCLIcons[a].PrefText + ';';
end;

procedure ICON_ORDER_PREF_parse(const str: RawByteString);
  function can_add(idx: byte; a: TRnQCLIconsSet): Boolean;
  var
    I: Integer;
  begin
    Result := True;
    for I := 0 to idx - 1 do
     if SHOW_ICONS_ORDER[i] = a then
      begin
       Result := false;
       Break;
      end;
  end;
var
  a: TRnQCLIconsSet;
  cur: Byte;
  s: RawByteString;
  ss: RawByteString;
begin
  cur := Byte(low(TRnQCLIconsSet));
  ss := str;
  while (s = '')and(ss > '') do
    s := chop(AnsiString(';'), ss);
  while (s > '') and (ss > '') do
   begin
    for a in [low(TRnQCLIconsSet)..High(TRnQCLIconsSet)] do
     if (s = RnQCLIcons[a].PrefText)
        and can_add(cur, a) then
      begin
       SHOW_ICONS_ORDER[cur] := a;
       inc(cur);
      end;
    s := chop(AnsiString(';'), ss);
   end;
  if cur <= Byte(High(TRnQCLIconsSet)) then
    for a in [low(TRnQCLIconsSet)..High(TRnQCLIconsSet)] do
     if can_add(cur, a) then
      begin
       SHOW_ICONS_ORDER[cur] := a;
       inc(cur);
      end;
end;


INITIALIZATION

contactsPool := Tlist.create;
sortBy := SB_event;
//ContactThemes := TRQtheme.Create;
 {$IFDEF USE_SECUREIM}
  useSecureIM := loadlib;
 {$ENDIF USE_SECUREIM}


FINALIZATION

  contactsPool.free;
  contactsPool := NIL;
  if Assigned(ContactsTheme) then
   ContactsTheme.free;
  ContactsTheme := NIL;

end.
