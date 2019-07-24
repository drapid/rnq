{
  This file is part of R&Q.
  Under same license
}
unit RQlog;
{$I ForRnQConfig.inc}
{$I NoRTTI.inc}

interface

uses
  Windows, Messages, SysUtils,
  Classes, Graphics, Controls, Forms,
  StdCtrls, ExtCtrls, Menus, RDGlobal,
//  RQThemes,
  VirtualTrees;

type
  TPktType = (ptNone, ptBin, ptJSON, ptXML, ptString, ptUTF8);

  PLogItem = ^TLogItem;
  TLogItem = record
//   pkt: Boolean;
   Cpt, Text: String;
   pktType: TPktType;
   PktData: RawByteString;
   Img: TPicName;
  end;

type
  TlogFrm = class(TForm)
    Splitter1: TSplitter;
    dumpBox: TMemo;
    menu: TPopupMenu;
    Clear1: TMenuItem;
    CopytoClipboard1: TMenuItem;
    Showevents1: TMenuItem;
    Showpackets1: TMenuItem;
    procedure LogListDrawNode(Sender: TBaseVirtualTree;
      const PaintInfo: TVTPaintInfo);
    procedure FormCreate(Sender: TObject);
    procedure LogListChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure CopytoClipboard1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure Clear1Click(Sender: TObject);
    procedure LogListFreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure FormDestroy(Sender: TObject);
    procedure Showevents1Click(Sender: TObject);
    procedure Showpackets1Click(Sender: TObject);
  private
    fShowEvents: Boolean;
    fShowPackets: Boolean;
    SetLast: Boolean;
  public
    LogList: TVirtualDrawTree;
//    procedure DestroyHandle; Override;
    procedure addToLog(pt: TPktType; const s, Text: String;
                       const data: rawByteString; const Img: TPicName);
    procedure HideAllEvents(Sender: TBaseVirtualTree; Node: PVirtualNode; Data: Pointer; var Abort: Boolean);
    procedure updateVisibility;
  end;

procedure loggaEvtS(s: String; const img: TPicName = '';
                   const pFlush: Boolean = false);
{
procedure loggaEvtA(s: AnsiString; const img: TPicName = '';
                   const pFlush: Boolean = false);
}
procedure logEvPkt(const Head: String; const TextData: String;
                   const data: RawByteString; const img: TPicName;
                   pktType: TPktType = ptBin);
procedure FlushLogEvFile;

var
  logFrm: TlogFrm;

implementation

{$R *.dfm}

uses
//  incapsulate,
  Clipbrd, JSON,
  RDUtils, RnQSysUtils, RnQJSON,
  RnQxml, NativeXML,
  RQThemes, RnQGlobal,
  RQutil, RnQFileUtil,
  RnQGraphics32;

var
  logEvFileData: String;

procedure TlogFrm.addToLog(pt: TPktType; const s, Text: String;
                     const data: rawByteString; const Img: TPicName);
var
  it: PLogItem;
//  i: integer;
//  SetLast: Boolean;
  n: PVirtualNode;
begin
  if self.visible then
   if LogList.FocusedNode = LogList.GetLast then
     SetLast := True
    else
     SetLast := False;

 n := LogList.AddChild(nil);
 it := LogList.GetNodeData(n);
 it.pktType := pt;
 it.Cpt := s;
 it.Text := Text;
 it.Img := Img;
 it.PktData := data;

  if (fShowPackets and (pt <> ptNone))or(fShowEvents and (pt = ptNone)) then
    begin
      Include(N.States, vsVisible);
      Exclude(N.States, vsFiltered);
    end
   else
    begin
      Exclude(N.States, vsVisible);
      Include(N.States, vsFiltered);
    end;
  if self.visible then
   begin
    if vsVisible in n.States then
    if SetLast then
     with LogList do
     begin
       FocusedNode := n;
       ClearSelection;
       if n <> NIL then
         Selected[n] := True;
     end;
   end;
end; // addToLog

procedure TlogFrm.HideAllEvents(Sender: TBaseVirtualTree; Node: PVirtualNode; Data: Pointer; var Abort: Boolean);
begin
  with TlogItem(PLogItem(Sender.getnodedata(Node))^) do
   begin
     if (fShowPackets and (pktType <> ptNone))or(fShowEvents and (pktType <> ptNone)) then
       begin
         if not(vsVisible in Node.States) then
          begin
           Include(node.States, vsVisible);
           Exclude(node.States, vsFiltered);
          end;
       end
      else
       if vsVisible in Node.States then
         begin
           Exclude(node.States, vsVisible);
           Include(node.States, vsFiltered);
         end;
   end;
end;

procedure TlogFrm.updateVisibility;
begin
  LogList.IterateSubtree(nil, HideAllEvents, NIL);
  LogList.Invalidate;
end;


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
  LogList.NodeDataSize := SizeOf(TLogItem);
  with LogList do
  begin
    Align := alClient;
    DefaultNodeHeight := MulDiv(16, GetParentCurrentDpi, cDefaultDPI);
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
    TreeOptions.PaintOptions := [toShowButtons, toShowDropmark, toShowTreeLines, toThemeAware, toUseBlendedImages, toUseBlendedSelection];
    TreeOptions.SelectionOptions := [toFullRowSelect, toMiddleClickSelect, toRightClickSelect];
    OnChange := LogListChange;
    OnDrawNode := LogListDrawNode;
    OnFreeNode := LogListFreeNode;
  end;
  fShowEvents := Showevents1.Checked;
  fShowPackets := Showpackets1.Checked;
  SetLast := True;
end;

procedure TlogFrm.FormDestroy(Sender: TObject);
begin
  Clear1Click(Self);
  logFrm := nil;
end;

procedure TlogFrm.FormShow(Sender: TObject);
var
  n: PVirtualNode;
begin
  theme.pic2ico(RQteFormIcon, PIC_HISTORY, icon);
  applyTaskButton(self);
  if SetLast then
    begin
     with LogList do
     begin
       n := GetLast;
       FocusedNode := n;
       ClearSelection;
       if n <> NIL then
         Selected[n] := True;
     end;
    end;
end;

procedure TlogFrm.LogListChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
var
  json: TJSONValue;
  xml: TRnQXml;
begin
  if Node = NIL then
    Exit;
  dumpBox.WordWrap := True;
  dumpBox.ScrollBars := ssVertical;
  with TLogItem(PLogItem(LogList.GetNodeData(Node))^) do
   begin
     if (Cpt = Text) then
      dumpBox.Text := Cpt
     else
      if pktType = ptBin then
        begin
          dumpBox.WordWrap := false;
          dumpBox.ScrollBars := ssBoth;
          dumpBox.Text := Cpt + CrLfS + hexDumpS(PktData);
        end
      else if pktType = ptJSON then
        begin
          json := TJSONObject.ParseJSONValue(UTF8String(PktData), true);
          if Assigned(json) then
            begin
              dumpBox.Text := Cpt + CRLF + Trim(formatJSON(json));
              json.Free;
            end
          else
            dumpBox.Text := Cpt + CRLF + UnUTF(PktData);
        end
      else if pktType = ptXML then
        begin
          xml := TRnQXml.Create(nil);
          xml.ReadFromString(UTF8String(PktData));
          if Assigned(xml) then
            begin
              xml.xmlFormat := xfReadable;
              dumpBox.Text := Cpt + CRLF + Trim(xml.WriteToString);
              xml.Free;
            end
          else
            dumpBox.Text := Cpt + CRLF + UnUTF(PktData);
        end
      else if pktType <> ptNone then
        begin
          dumpBox.WordWrap := false;
          dumpBox.ScrollBars := ssBoth;
          dumpBox.Text := Cpt + CrLfS + UnUTF(PktData);
        end
       else
        dumpBox.Text := Cpt + CrLfS + Text;
   end;
//  TlogItem(PLogItem(LogList.getnodedata(Node)^)^).Text;
//  dumpbox.clear;
end;

procedure TlogFrm.LogListDrawNode(Sender: TBaseVirtualTree;
  const PaintInfo: TVTPaintInfo);
var
  s: String;
  x: Integer;
  r: tgprect;
begin
 with TLogItem(PLogItem(LogList.GetNodeData(PaintInfo.Node))^) do
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
  theme.drawPic(PaintInfo.Canvas.Handle, r, Img, True, GetParentCurrentDpi);
  x := r.X + r.Width;
//       theme.drawPic(PaintInfo.Canvas.Handle, PaintInfo.ContentRect.Left +3, 0,
//         Img).cx+6;
//       .cx+2;

    SetBkMode(PaintInfo.Canvas.Handle, TRANSPARENT);
    PaintInfo.Canvas.textout(PaintInfo.ContentRect.Left + x, 2, s);
 end;
end;

procedure TlogFrm.LogListFreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);
begin
  with PLogItem(LogList.GetNodeData(Node))^ do
  begin
   SetLength(Cpt, 0);
   SetLength(Text, 0);
   SetLength(Img, 0);
   SetLength(PktData, 0);
  end;
end;

procedure TlogFrm.Showevents1Click(Sender: TObject);
begin
  fShowEvents := Showevents1.Checked;
  updateVisibility;
end;

procedure TlogFrm.Showpackets1Click(Sender: TObject);
begin
  fShowPackets := Showpackets1.Checked;
  updateVisibility;
end;

procedure TlogFrm.Clear1Click(Sender: TObject);
//var
//  i: integer;
begin
  LogList.Clear;
  dumpBox.Clear;
//pktsBox.clear;
end;

procedure TlogFrm.CopytoClipboard1Click(Sender: TObject);
var
 s: String;
begin
  if LogList.FocusedNode = NIL then
    Exit;
  s := TLogItem(PLogItem(LogList.GetNodeData(LogList.FocusedNode))^).Text;
  s := BetterStrS(s);
  clipboard.asText := s;
end;
{
procedure loggaEvtA(s: AnsiString; const img: TPicName = '';
                   const pFlush: Boolean = false);
var
  h: AnsiString;
begin
  h := '';
  while s>'' do
    h := h+chopline(RawByteString(s))+CRLF;
  while h[length(h)] in [#10, #13] do
    SetLength(h, length(h)-1);
//  h :=
  s := logtimestamp+h;

  if logpref.evts.onfile then
    logEvFileData := logEvFileData + s + CRLF;

  if pFlush then
    FlushLogEvFile;

  if logpref.evts.onwindow and assigned(logfrm) then
    begin
    h := s;
    logFrm.addToLog(False, chopline(RawByteString(h)), s, '', img);
    end;

end; // loggaEvt
}
procedure loggaEvtS(s: String; const img: TPicName = '';
                   const pFlush: Boolean = false);
var
  h: String;
begin
  h := '';
  while s>'' do
    h := h+chopline(s)+CRLF;
//  while h[length(h)] in [#10, #13] do
  while CharInSet( h[length(h)], [#10, #13] ) do
    SetLength(h, length(h)-1);
//  h :=
  s := logtimestamp+h;

  if logpref.evts.onfile then
    logEvFileData := logEvFileData + s + CRLF;

  if pFlush then
    FlushLogEvFile;

  if logpref.evts.onwindow and assigned(logFrm) then
    begin
    h := s;
    logFrm.addToLog(ptNone, chopline(h), s, '', img);
    end;

end; // loggaEvt

procedure logEvPkt(const Head: String; const TextData: String;
      const data: RawByteString; const img: TPicName; pktType: TPktType = ptBin);
//var
//  h: string;
begin
//  h := '';
//  s := logtimestamp+h;
//  if logpref.evts.onwindow and assigned(logfrm) then
  if logpref.pkts.onwindow and assigned(logFrm) then
    begin
//    h := s;
    logFrm.addToLog(pktType, Head, TextData, Data, img);
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

