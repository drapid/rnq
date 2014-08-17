{
This file is part of R&Q.
Under same license
}
unit viewSSI;
{$I RnQConfig.inc}
{$I NoRTTI.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls,
  Forms, StdCtrls, VirtualTrees, ExtCtrls, RnQButtons,
  Menus, VTHeaderPopup, ICQv9;

const
  MAX_DATA_LEN = 8192;          //Maximum packet size

type
  TSSIForm = class(TForm)
    CLTree:      TVirtualDrawTree;
    Panel1:      TPanel;
    Panel2:      TPanel;
    GroupBox1:   TGroupBox;
    MemoHexView: TMemo;
    FillBtn: TRnQButton;
    DelBtn: TRnQButton;
    LoadSSIBtn: TRnQButton;
    LoadFileBtn: TRnQButton;
    VTHeaderPopupMenu1: TVTHeaderPopupMenu;
    procedure Button1Click(Sender: TObject);
    procedure CLTreeDrawNode(Sender: TBaseVirtualTree;
      const PaintInfo: TVTPaintInfo);
    procedure CLTreeGetNodeWidth(Sender: TBaseVirtualTree; HintCanvas: TCanvas;
      Node: PVirtualNode; Column: TColumnIndex; var NodeWidth: integer);
    procedure CLTreeFocusChanged(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex);
    procedure DelBtnClick(Sender: TObject);
    procedure LoadSSIBtnClick(Sender: TObject);
    procedure LoadFileBtnClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure CLTreeFreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure VTHeaderPopupMenu1Popup(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
//    procedure parse1306(snac: string; ref: integer);
    //    procedure HSnac1306(Pkt: PRawPkt);
    loadedServerSSI : Boolean;
    procedure FillTree(vSSI : Tssi);
  end;

var
  SSIForm: TSSIForm;

implementation

uses
  dateUtils,
  RDUtils, RQUtil, RDGlobal, RnQBinUtils, RDFileUtil, RnQDialogs,
  RnQSysUtils,
  RQ_ICQ, ICQConsts, utilLib, globalLib, mainDlg;

{$R *.dfm}


type
  PSSIItem = ^TSSIItem;
  TSSIItem = record
    FAuthorized: boolean;
    ItemType,
    ItemID, GroupID: integer;
    FFirstMsg: TDateTime;
    Name, Caption: string;
    Fnote:     string;
    FInfoToken : String;
//    ExtInfo:   string;
    HexInfo : String;
    //    FNick,
    FCellular: ShortString;
    FMail:     ShortString;
  end;


procedure TSSIForm.CLTreeDrawNode(Sender: TBaseVirtualTree;
  const PaintInfo: TVTPaintInfo);
var
  s: string;
  i : NativeInt;
begin
  SetBKMode(PaintInfo.Canvas.Handle, TRANSPARENT);
  if vsSelected in PaintInfo.Node^.States then
    PaintInfo.Canvas.Font.Color := clHighlightText
  else
    PaintInfo.Canvas.Font.Color := clWindowText;
  if vsSelected in PaintInfo.Node^.States then
    PaintInfo.Canvas.Font.Color := clHighlightText
  else
    PaintInfo.Canvas.Font.Color := clWindowText;
  case PaintInfo.Column of
{  -1: begin
         s := PSSIItem(sender.getnodedata(paintinfo.node))^.name
              + ' '+ PSSIItem(sender.getnodedata(paintinfo.node))^.caption;
         PaintInfo.Canvas.textout(PaintInfo.ContentRect.Left,2, s);
      end;
}
    0: // Item
    begin
      s := PSSIItem(Sender.getnodedata(paintinfo.node))^.Name +
        ' ' + PSSIItem(Sender.getnodedata(paintinfo.node))^.Caption;
      if PSSIItem(Sender.getnodedata(paintinfo.node))^.ItemType =
        FEEDBAG_CLASS_ID_GROUP then
        s := s + ' (' + IntToStr(paintinfo.Node.ChildCount) + ')';
      PaintInfo.Canvas.textout(PaintInfo.ContentRect.Left, 2, s);
    end;
    1: // Auth
    begin
      PaintInfo.Canvas.textout(PaintInfo.ContentRect.Left, 2,
        BoolToStr(PSSIItem(Sender.getnodedata(paintinfo.node))^.FAuthorized));
    end;
    2: // Alias
    begin
      PaintInfo.Canvas.textout(PaintInfo.ContentRect.Left, 2,
        PSSIItem(Sender.getnodedata(paintinfo.node))^.Caption);
    end;
    3: // IDs
    begin
      PaintInfo.Canvas.textout(PaintInfo.ContentRect.Left, 2,
        //           PSSIItem(sender.getnodedata(paintinfo.node))^.FMail);
        IntToHex(PSSIItem(Sender.getnodedata(paintinfo.node))^.ItemID, 2) +
        ' - ' + IntToHex(PSSIItem(Sender.getnodedata(paintinfo.node))^.GroupID, 2));
    end;
    4: // E-Mail
    begin
      PaintInfo.Canvas.textout(PaintInfo.ContentRect.Left, 2,
        PSSIItem(Sender.getnodedata(paintinfo.node))^.FMail);
    end;
    5: // Mobile
    begin
      PaintInfo.Canvas.textout(PaintInfo.ContentRect.Left, 2,
        PSSIItem(Sender.getnodedata(paintinfo.node))^.FCellular);
    end;
    6: // Note
    begin
      PaintInfo.Canvas.textout(PaintInfo.ContentRect.Left, 2,
        PSSIItem(Sender.getnodedata(paintinfo.node))^.Fnote);
    end;
    7: // Time
    begin
      if PSSIItem(Sender.getnodedata(paintinfo.node))^.FFirstMsg > 0 then
       PaintInfo.Canvas.textout(PaintInfo.ContentRect.Left, 2,
        DateTimeToStr(PSSIItem(Sender.getnodedata(paintinfo.node))^.FFirstMsg));
    end;
    8: // Type
    begin
      i := PSSIItem(Sender.getnodedata(paintinfo.node))^.ItemType;
      s := IntToHex(i, 2);
      if (i >=0) and (i <= FEEDBAG_CLASS_ID_UNKNOWN) then
        s := s + '; ' + FEEDBAG_CLASS_NAMES[i];
      PaintInfo.Canvas.textout(PaintInfo.ContentRect.Left, 2, s );
    end;
    9: // Ext
    begin
      PaintInfo.Canvas.textout(PaintInfo.ContentRect.Left, 2,
        PSSIItem(Sender.getnodedata(paintinfo.node))^.HexInfo);
    end;
    //   cnv.textout(PaintInfo.ContentRect.Left ,2, c.uinAsStr)
{   2: case PSSIItem(sender.getnodedata(paintinfo.node))^.copyTo of
       CT_SERVER : theme.drawPic(cnv, PaintInfo.ContentRect.Left, 0, PIC_LEFT);
       CT_LOCAL : theme.drawPic(cnv, PaintInfo.ContentRect.Left, 0, PIC_RIGHT);
       CT_NONE : theme.drawPic(cnv, PaintInfo.ContentRect.Left, 0, PIC_EMPTY);
      end;}
  end;
end;

function ExtInfo2Debug(ItemType :Integer; s0 : AnsiString) : String;
var
  ofs00, i : Integer;
  bday : TDateTime;
  vs : String;
begin
        Result := '';
        ofs00 := 1;
        if Length(s0) = 0 then
          Exit;
        s0 := deleteTLV($0131, s0);
//        deleteTLV($0131, Clist);
        s0 := deleteTLV($0137, s0);
        s0 := deleteTLV($013A, s0);
        s0 := deleteTLV($013C, s0);
        s0 := deleteTLV($0145, s0);
        s0 := deleteTLV($0066, s0);
        s0 := deleteTLV($015C, s0); // Token
        //        while word_BEat(@s[ofs00])<>idx do
        try
          while ofs00 < length(s0) do
          begin
            i := word_BEat(@s0[ofs00]);
            case i of
              $6A : vs := 'RECENT_BUDDY';
              $6B : vs := 'BOT';
            else
             begin
  //            Result.Debug := Result.Debug +
              vs := 'TLV(' + IntToHex(i, 2) + ') '+
  //            Result.Debug := Result.Debug +
                str2hexU(Copy(s0, ofs00 + 4, word_BEat(@s0[ofs00 + 2])));
  {            if i = $6D then
               begin
  //              Int64((@bday)^)   := Qword_BEat(@Clist[ofs00 + 4]);
  //              item.ExtInfo := item.ExtInfo +'(' + DateToStr(bDay) + ')';
               end;
  }
              if i = $15D then
               begin
                Int64((@bday)^)   := Qword_BEat(@s0[ofs00 + 4]);
                vS := vs + ' (' + DateTimeToStr(bDay) + ')';
               end
              else
              if (i = $67)or (i = $160)or(i = $6D) then
               begin
                bday := UnixToDateTime(dword_BEat(@s0[ofs00 + 4]));
//                if i = $6D then // The score; higher means more interactions
//                  score := dword_BEat(@s0[ofs00 + 8]));
                if (ItemType = FEEDBAG_CLASS_ID_DELETED)and(i = $6D) then
                  vS := ''
                 else
                  vS := vS + ' (' + DateTimeToStr(bDay) + ')';
               end
              else
               if i=$150 then
                 vS := vS + ' (number of IMs sent)'
              else
               if i=$151 then
                 vS := vS + ' (number of seconds a user is online)'
              else
               if i=$152 then
                 vS := vS + ' (number of times a user has the away message set)'
              else
               if i=$153 then
                 vS := vS + ' (number of IMs received)';
             end;
            end;
//              Result := Result + vS;
            if vS > '' then
              Result := Result + vS+ CRLF;
            Inc(ofs00, word_BEat(@s0[ofs00 + 2]) + 4);
            //          if ofs00 >= length(Clist) then
            //            exit;
          end;
        except
          Result := str2hexU(s0);
        end;
end;

procedure TSSIForm.CLTreeFocusChanged(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex);
begin
  if Assigned(Node) then
    MemoHexView.Text := PSSIItem(Sender.getnodedata(node))^.HexInfo
   else
    MemoHexView.Text := '';
end;

procedure TSSIForm.CLTreeFreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);
begin
  with PSSIItem(Sender.getnodedata(node))^ do
    begin
      SetLength(Name, 0);
      SetLength(Caption, 0);
      SetLength(Fnote, 0);
      SetLength(FInfoToken, 0);
      SetLength(HexInfo, 0);
      SetLength(FCellular, 0);
      SetLength(FMail, 0);
    end;
end;

procedure TSSIForm.CLTreeGetNodeWidth(Sender: TBaseVirtualTree;
  HintCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
  var NodeWidth: integer);
begin
  NodeWidth := 200;
end;

procedure TSSIForm.DelBtnClick(Sender: TObject);
var
  n : PVirtualNode;
begin
  if not OnlFeature(Account.AccProto) then Exit;
  if not loadedServerSSI then
   begin
    msgDlg('Loaded not your SSI', True, mtInformation);
    Exit;
   end;
  n := CLTree.FocusedNode;
  if Assigned(n) then
   begin
    with (PSSIItem(CLTree.GetNodeData(n))^) do
     TicqSession(Account.AccProto.ProtoElem).SSI_DeleteItem(GroupID, ItemID, ItemType);
    CLTree.DeleteNode(n); 
   end;
end;

procedure TSSIForm.FillTree(vSSI : Tssi);
var
  n, fn: PVirtualNode;
  nd:    PSSIItem;
  i, k:  integer;
begin
  CLTree.NodeDataSize := SizeOf(TSSIItem);
  CLTree.Clear;
  if Assigned(vSSI.items) then
  for I := 0 to vSSI.items.Count - 1 do
  begin
    k  := TOSSIItem(vSSI.items.Objects[i]).GroupID;
    fn := nil;
    if k <> 0 then
    begin
      fn := CLTree.GetFirst;
      while fn <> nil do
      begin
        if (PSSIItem(CLTree.GetNodeData(fn)).ItemType =
          FEEDBAG_CLASS_ID_GROUP) and
          (PSSIItem(CLTree.GetNodeData(fn)).GroupID = k) then
          break;
        fn := CLTree.GetNext(fn);
      end;
    end;

    n  := CLTree.AddChild(fn);
    nd := CLTree.GetNodeData(n);
    nd.ItemType := TOSSIItem(vSSI.items.Objects[i]).ItemType;
    nd.Name := unUTF(TOSSIItem(vSSI.items.Objects[i]).ItemName);
    nd.Caption := unUTF(TOSSIItem(vSSI.items.Objects[i]).Caption);
    nd.ItemID := TOSSIItem(vSSI.items.Objects[i]).ItemID;
    nd.FAuthorized := TOSSIItem(vSSI.items.Objects[i]).FAuthorized;
    nd.GroupID := k;
    nd.FFirstMsg := TOSSIItem(vSSI.items.Objects[i]).FFirstMsg;
    nd.Fnote := TOSSIItem(vSSI.items.Objects[i]).Fnote;
    nd.FCellular := TOSSIItem(vSSI.items.Objects[i]).FCellular;
    nd.FMail := TOSSIItem(vSSI.items.Objects[i]).FMail;
    nd.HexInfo :=  ExtInfo2Debug(TOSSIItem(vSSI.items.Objects[i]).ItemType,
                                TOSSIItem(vSSI.items.Objects[i]).ExtData);
    if (FEEDBAG_CLASS_ID_BUDDY = nd.ItemType)
      and (TOSSIItem(vSSI.items.Objects[i]).FInfoToken > '') then
      begin
        nd.HexInfo := nd.HexInfo + CRLF+ 'In his CL'
      end;
    //    nd.name := vSSI.items.Strings[i];
  end;
  CLTree.FullExpand();
end;
procedure TSSIForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
  SSIForm := NIL;
end;

procedure TSSIForm.FormShow(Sender: TObject);
begin
  applyTaskButton(Self);
  LoadSSIBtn.Visible := not masterUseSSI;
end;

procedure TSSIForm.LoadFileBtnClick(Sender: TObject);
var
  fn : String;
  s : RawByteString;
  thisSSI : Tssi;
  b : Boolean;
begin
//  fn:=openSavedlg(rnqMain, True, 'ssi', 'Server Side Information');
  fn:=openSavedlg(Self, '', True, 'ssi', 'Server Side Information');
  if fn= '' then Exit;
  s := loadFileA(fn);
  if s = '' then Exit;

   isImpCL := False;
   thisSSI.items := NIL;
   clearSSIList(thisSSI);
  b := icqdebug;
  icqdebug := False;
  CLPktNUM := 0;
   parse1306(NIL, thisSSI, s, 0);
  icqdebug := b;
  FillTree(thisSSI);
  loadedServerSSI := False;
   clearSSIList(thisSSI);
end;

procedure TSSIForm.LoadSSIBtnClick(Sender: TObject);
begin
 {$IFDEF UseNotSSI}
  if OnlFeature(Account.AccProto) then
   if not TicqSession(Account.AccProto.ProtoElem).useSSI and not Assigned(serverSSI.items) then
    RequestContactList(TicqSession(Account.AccProto.ProtoElem), False);
 {$ENDIF UseNotSSI}
end;

procedure TSSIForm.VTHeaderPopupMenu1Popup(Sender: TObject);
begin
  applyCommonSettings(TControl(Sender));
end;


procedure TSSIForm.Button1Click(Sender: TObject);
{var
  f:    file;
  fn : string;
  //  da : Array of char;
//  Buf:  array[0..8192] of char;
  i, k: integer;
  s:    string;
//  PKT:  TRawPkt;
}
begin
{  if OpenDialog1.Execute then
    fn := OpenDialog1.FileName
   else
    fn := 'ServList.txt';
  if FileExists(fn) then
  begin
    assignFile(f, fn);
    reset(f, 1);
    //GetMem(buf, 2005);
    FillChar(buf, 8000, 0);
    //read
    BlockRead(f, buf, 8000, k);
    closeFile(f);
    //data[i] := #0;
    i := IOResult;
    s := '';
    for i := 0 to k do
      s := S + buf[i];
    //  Pkt.Data[i] := ord(buf[i]);
    Pkt.Len := 0;

    parse1306(s, 0);
    //HSnac1306(@Pkt);
}
    FillTree(Account.AccProto.serverSSI);
    loadedServerSSI := True;
//    Caption := 'Server Contact List' + ' ( '+ fn + ' )';
//  end
//  else
//    Caption := 'Server Contact List';
end;



end.
