{
This file is part of R&Q.
Under same license
}
unit RQlog;
{$I ForRnQConfig.inc}

 {$IFDEF COMPILER_14_UP}
  {$WEAKLINKRTTI ON}
  {$RTTI EXPLICIT METHODS([]) FIELDS([]) PROPERTIES([])}
 {$ENDIF COMPILER_14_UP}

interface

uses
  Windows, Messages, SysUtils,
  Classes, Graphics, Controls, Forms,
  StdCtrls, ExtCtrls, Menus, RDGlobal,
//  RQThemes,
  VirtualTrees;

type
  PLogItem = ^TLogItem;
  TLogItem = record
   pkt : Boolean;
   Cpt, Text : String;
   PktData : RawByteString;
   Img : TPicName;
  end;

type
  TlogFrm = class(TForm)
    Splitter1: TSplitter;
    dumpBox: TMemo;
    menu: TPopupMenu;
    Clear1: TMenuItem;
    CopytoClipboard1: TMenuItem;
    procedure LogListDrawNode(Sender: TBaseVirtualTree;
      const PaintInfo: TVTPaintInfo);
    procedure FormCreate(Sender: TObject);
    procedure LogListChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure CopytoClipboard1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure Clear1Click(Sender: TObject);
    procedure LogListFreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);
  public
    LogList: TVirtualDrawTree;
//    procedure DestroyHandle; Override;
    procedure addToLog(pkt : Boolean; const s,Text : String;
                       const data : rawByteString; const Img : TPicName);
  end;

procedure loggaEvtS(s: String; const img : TPicName = '';
                   const pFlush : Boolean = false);
{
procedure loggaEvtA(s: AnsiString; const img : TPicName = '';
                   const pFlush : Boolean = false);
}
procedure logEvPkt(const Head : String; const TextData : String;
                   const data: RawByteString; const img : TPicName;
                   needHex : Boolean = True);
procedure FlushLogEvFile;

var
  logFrm: TlogFrm;

implementation

{$R *.dfm}

uses
//  incapsulate,
  RDUtils, RnQSysUtils,
  RQThemes, RnQGlobal,
  RQutil, RnQFileUtil, Clipbrd,
  RnQGraphics32;

var
  logEvFileData : String;

procedure TlogFrm.addToLog(pkt : Boolean; const s,Text : String;
                     const data : rawByteString; const Img : TPicName);
var
  it : PLogItem;
//  i:integer;
  SetLast : Boolean;
  n : PVirtualNode;
begin
 if LogList.FocusedNode = LogList.GetLast then
   SetLast := True
  else
   SetLast := False;
 n := LogList.AddChild(nil);
 it := LogList.GetNodeData(n);
 it.pkt := pkt;
 it.Cpt := s;
 it.Text := Text;
 it.Img := Img;
 it.PktData := data;

  if SetLast then
   with LogList do
   begin
     FocusedNode := n;
     ClearSelection;
     if n <> NIL then
       Selected[n] := True;
   end;
end; // addToLog


//procedure TlogFrm.destroyHandle;
//begin inherited end;

procedure TlogFrm.FormClose(Sender: TObject; var Action: TCloseAction);
begin {destroyHandle }
//  Action := caFree;
//  LogFrm := nil;
end;

procedure TlogFrm.FormCreate(Sender: TObject);
begin
  LogList := TVirtualDrawTree.Create(self);
  Self.InsertComponent(LogList);
  LogList.Parent := self;
  LogList.NodeDataSize := SizeOf(TlogItem);
  with LogList do
  begin
    Align := alClient;
    DefaultNodeHeight := 16;
    Header.AutoSizeIndex := 0;
{    Header.Font.Charset := DEFAULT_CHARSET
    Header.Font.Color := clWindowText
    Header.Font.Height := -11
    Header.Font.Name := 'Tahoma'
    Header.Font.Style = []
}
    Header.MainColumn := -1;
    Header.Options := [hoColumnResize, hoDrag];
    PopupMenu := menu;
    TabOrder := 1;
    TreeOptions.PaintOptions := [toShowButtons, toShowDropmark, toShowTreeLines, toThemeAware, toUseBlendedImages];
    TreeOptions.SelectionOptions := [toFullRowSelect, toMiddleClickSelect, toRightClickSelect];
    OnChange := LogListChange;
    OnDrawNode := LogListDrawNode;
    OnFreeNode := LogListFreeNode;
  end;
end;

procedure TlogFrm.FormShow(Sender: TObject);
begin
  theme.pic2ico(RQteFormIcon, PIC_HISTORY, icon);
  applyTaskButton(self)
end;

procedure TlogFrm.LogListChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
begin
  if node = NIL then
    Exit;
  with TlogItem(PLogItem(LogList.getnodedata(Node))^) do
   begin
     if (Cpt = Text) then
      dumpbox.text := Cpt
     else
      if pkt then
        dumpbox.text := Cpt + CrLfS + hexDumpS(PktData)
       else
        dumpbox.text := Cpt + CrLfS + Text;
   end;
//  TlogItem(PLogItem(LogList.getnodedata(Node)^)^).Text;
//  dumpbox.clear;
end;

procedure TlogFrm.LogListDrawNode(Sender: TBaseVirtualTree;
  const PaintInfo: TVTPaintInfo);
var
  s : String;
  x : Integer;
  r : tgprect;
begin
 with TlogItem(PLogItem(LogList.getnodedata(PaintInfo.Node))^) do
 begin
  s := Cpt;
  if vsSelected in PaintInfo.Node.States then
   begin
    if Sender.Focused then
      PaintInfo.Canvas.Font.Color := clHighlightText
    else
      PaintInfo.Canvas.Font.Color := clWindowText;
   end
  else
    PaintInfo.Canvas.Font.Color := clWindowText;
  r.X := PaintInfo.ContentRect.Left +1;
  r.Y := 0;
  r.Height := PaintInfo.ContentRect.Bottom;
  r.Width  := r.Height;
  theme.drawPic(PaintInfo.Canvas.Handle, r, Img);
  x := r.X + r.Width;
//       theme.drawPic(PaintInfo.Canvas.Handle, PaintInfo.ContentRect.Left +3, 0,
//         Img).cx+6;
//       .cx+2;

    SetBkMode(PaintInfo.Canvas.Handle, TRANSPARENT);
    PaintInfo.Canvas.textout(PaintInfo.ContentRect.Left +x,2, s);
 end;
end;

procedure TlogFrm.LogListFreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);
begin
  with PLogItem(LogList.getnodedata(Node))^ do
  begin
   SetLength(Cpt, 0);
   SetLength(Text, 0);
   SetLength(Img, 0);
  end;
end;

procedure TlogFrm.Clear1Click(Sender: TObject);
//var
//  i:integer;
begin
 LogList.Clear;
 dumpBox.Clear;
//pktsBox.clear;
end;

procedure TlogFrm.CopytoClipboard1Click(Sender: TObject);
var
 s : String;
begin
  if LogList.FocusedNode = NIL then Exit;
  s := TlogItem(PLogItem(LogList.getnodedata(LogList.FocusedNode))^).Text;
  s := BetterStrS(s);
  clipboard.asText := s;
end;
{
procedure loggaEvtA(s: AnsiString; const img : TPicName = '';
                   const pFlush : Boolean = false);
var
  h:AnsiString;
begin
  h:='';
  while s>'' do
    h:=h+chopline(RawByteString(s))+CRLF;
  while h[length(h)] in [#10, #13] do
    SetLength(h, length(h)-1);
//  h :=
  s:=logtimestamp+h;

  if logpref.evts.onfile then
    logEvFileData := logEvFileData + s + CRLF;

  if pFlush then
    FlushLogEvFile;

  if logpref.evts.onwindow and assigned(logfrm) then
    begin
    h:=s;
    logFrm.addToLog(False, chopline(RawByteString(h)), s, '', img);
    end;

end; // loggaEvt
}
procedure loggaEvtS(s: String; const img : TPicName = '';
                   const pFlush : Boolean = false);
var
  h : String;
begin
  h:='';
  while s>'' do
    h:=h+chopline(s)+CRLF;
//  while h[length(h)] in [#10, #13] do
  while CharInSet( h[length(h)], [#10, #13] ) do
    SetLength(h, length(h)-1);
//  h :=
  s:=logtimestamp+h;

  if logpref.evts.onfile then
    logEvFileData := logEvFileData + s + CRLF;

  if pFlush then
    FlushLogEvFile;

  if logpref.evts.onwindow and assigned(logfrm) then
    begin
    h:=s;
    logFrm.addToLog(False, chopline(h), s, '', img);
    end;

end; // loggaEvt

procedure logEvPkt(const Head : String; const TextData : String;
      const data: RawByteString; const img : TPicName; needHex : Boolean = True);
//var
//  h:string;
begin
//  h:='';
//  s:=logtimestamp+h;
//  if logpref.evts.onwindow and assigned(logfrm) then
  if logpref.pkts.onwindow and assigned(logfrm) then
    begin
//    h:=s;
    logFrm.addToLog(needHex, Head, TextData, Data, img);
    end;

//  if logpref.evts.onfile then
//    appendFile(logPath+eventslogFilename, s + CRLF);
end; // loggaEvt


procedure FlushLogEvFile;
begin
  if Length(logEvFileData) > 0 then
   if appendFile(logPath+eventslogFilename, StrToUTF8(logEvFileData))
      or (Length(logEvFileData) > MByte) then
    logEvFileData := '';
end;

end.

